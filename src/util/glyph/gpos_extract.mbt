// Run-time GPOS Pair Adjustment extractor.
//
// Replaces the auto-generated hard-coded tables in `gpos_kern_table.mbt`
// with a real OpenType GPOS parser. The bundled TTFs (Carlito, Liberation
// Sans / Serif / Mono) keep their ASCII kerning in GPOS lookups of:
//
//   - Lookup Type 2 (Pair Adjustment), SubTable Format 1 (specific pairs)
//   - Lookup Type 2 (Pair Adjustment), SubTable Format 2 (class-based)
//   - Lookup Type 9 (Extension) wrapping either of the above
//
// `extract_gpos_kern_pairs` walks the GPOS table directly and returns the
// same `GposKernEntry` records that the previous pre-baked tables held,
// so it can be swapped in at `FontMeasurer::with_gpos_kern` time without
// any downstream change. The output is restricted to ASCII printable
// codepoints (0x20–0x7E) to match the historical scope; widening it is a
// matter of changing one loop bound.
//
// References:
//   - OpenType spec, "GPOS — Glyph Positioning Table" (Adobe / Microsoft).
//   - The Python prototype in `scripts/extract_gpos_kern.py` (which this
//     module supersedes).

///|
/// Lowest ASCII printable codepoint included in the extraction. Match the
/// historical pre-baked tables; widening only requires changing this and
/// `ASCII_END`.
const ASCII_START : Int = 0x20

///|
/// Highest ASCII printable codepoint included (inclusive).
const ASCII_END : Int = 0x7E

///|
/// `GPOS` tag as a big-endian uint32 (0x47504F53).
const GPOS_TAG_U32 : Int = 0x47504F53

///|
/// Bit 0x0004 in `valueFormat` — the only `ValueRecord` field this
/// extractor consumes (XAdvance). The other bits are skipped past.
const VF_X_ADVANCE : Int = 0x0004

///|
/// Extract every GPOS class-based / pair-based kerning entry for ASCII
/// printable codepoints from a TTF/OTF byte stream. Returns an empty
/// array when the font has no GPOS table, no `kern` feature, or only
/// non-Pair-Adjustment lookups (e.g. MarkToMark).
///
/// The result is the run-time equivalent of the pre-generated tables in
/// `gpos_kern_table.mbt` — same `GposKernEntry { first, second, x_advance }`
/// records, same order-agnostic semantics (the caller in
/// `font_measurer.mbt::build_gpos_kern_map` builds a `Map` keyed by
/// `(first, second)` so duplicates collapse to the last write).
pub fn extract_gpos_kern_pairs(bytes : Bytes) -> Array[GposKernEntry] {
  // Need at least the sfnt header (12 bytes) and a minimal GPOS layout
  // before any table access can succeed.
  if bytes.length() < 12 {
    return []
  }
  // We rely on `TTFont` purely for cmap lookups (codepoint → glyph_id);
  // every byte of the GPOS table is parsed in this file because mizchi/
  // font's `TTFont` deliberately ignores GPOS today.
  let tt = match @font.parse_font(bytes) {
    None => return []
    Some(t) => t
  }
  let gpos_offset = find_gpos_offset(bytes)
  if gpos_offset < 0 {
    return []
  }
  // Pre-compute the relevant glyph IDs and the reverse mapping back to
  // codepoints so we don't pay a Map lookup per (g1, g2) pair below.
  let relevant_gids : Array[Int] = []
  let cp_by_gid : Map[Int, Int] = Map([], capacity=ASCII_END - ASCII_START + 1)
  for cp in ASCII_START..<=ASCII_END {
    let gid = tt.glyph_index(cp)
    // glyph_index returns 0 (`.notdef`) when the cmap has no entry; we
    // skip those because every face we care about *does* have an ASCII
    // glyph for the printable range and a 0-gid would otherwise alias.
    if gid != 0 {
      relevant_gids.push(gid)
      cp_by_gid[gid] = cp
    }
  }
  let reader = @font.BinaryReader::new(bytes)
  let pairs : Map[Int, Int] = Map([], capacity=1024)
  collect_kern_pairs(reader, gpos_offset, relevant_gids, cp_by_gid, pairs)
  // Emit in deterministic (first, second) order so two runs against the
  // same TTF produce byte-identical output — important when we compare
  // against the pre-baked tables.
  let entries : Array[GposKernEntry] = []
  let keys : Array[Int] = []
  for k, _ in pairs {
    keys.push(k)
  }
  keys.sort()
  for k in keys {
    let first = k / GPOS_PAIR_KEY_SHIFT
    let second = k % GPOS_PAIR_KEY_SHIFT
    let adv = pairs.get(k).unwrap()
    entries.push({ first, second, x_advance: adv })
  }
  entries
}

///|
/// Key shift used to pack `(first_cp, second_cp)` into a single `Int` for
/// the dedup map. Codepoints are bounded by `ASCII_END < 0x80`, so any
/// shift ≥ 128 works; 2^16 keeps the keys readable when debugging.
const GPOS_PAIR_KEY_SHIFT : Int = 0x10000

///|
/// Locate the GPOS table inside an sfnt-formatted TTF/OTF. Returns the
/// table's absolute byte offset on success, or `-1` when the font has no
/// GPOS table. We re-walk the sfnt directory rather than threading it
/// through `TTFont` because mizchi/font's `TableRecord` strips the
/// length field we don't need anyway (we never read past valid offsets).
fn find_gpos_offset(bytes : Bytes) -> Int {
  let r = @font.BinaryReader::new(bytes)
  // sfntVersion (4) is irrelevant — TTF, OTF and "true" all use the
  // same table directory format we're about to read.
  let _ = r.read_uint32()
  let num_tables = r.read_uint16()
  // searchRange / entrySelector / rangeShift — derived fields, unused
  // for direct lookup.
  let _ = r.read_uint16()
  let _ = r.read_uint16()
  let _ = r.read_uint16()
  for _ in 0..<num_tables {
    // Read the tag as a uint32 instead of `read_tag` so we can compare
    // against `0x47504F53` directly — avoids the per-iteration String
    // allocation in `read_tag`.
    let tag_u32 = r.read_uint32()
    let _checksum = r.read_uint32()
    let offset = r.read_uint32()
    let _length = r.read_uint32()
    if tag_u32 == GPOS_TAG_U32 {
      return offset
    }
  }
  -1
}

///|
/// Walk the GPOS header → FeatureList → LookupList → Pair Adjustment
/// subtables, accumulating ASCII (codepoint, codepoint) → x_advance
/// entries into `pairs`.
fn collect_kern_pairs(
  reader : @font.BinaryReader,
  gpos_offset : Int,
  relevant_gids : Array[Int],
  cp_by_gid : Map[Int, Int],
  pairs : Map[Int, Int],
) -> Unit {
  // GPOS Header (v1.0 and v1.1 both work; the version-1.1-only
  // featureVariationsOffset is ignored).
  reader.seek(gpos_offset)
  let _major = reader.read_uint16()
  let _minor = reader.read_uint16()
  let _script_list_offset = reader.read_uint16()
  let feature_list_offset = reader.read_uint16()
  let lookup_list_offset = reader.read_uint16()
  // FeatureList — gather all lookup indices tagged with 'kern'.
  let feature_list_abs = gpos_offset + feature_list_offset
  let lookup_indices = collect_kern_lookup_indices(reader, feature_list_abs)
  // LookupList — for every 'kern' lookup, decode its Pair Adjustment
  // subtables (and unwrap any Extension wrappers).
  let lookup_list_abs = gpos_offset + lookup_list_offset
  reader.seek(lookup_list_abs)
  let lookup_count = reader.read_uint16()
  // lookupOffsets[] — captured into an Array up-front so we can index
  // them via the indices we collected from the feature list (avoids a
  // nested seek inside the feature-tag loop).
  let lookup_offsets : Array[Int] = []
  for _ in 0..<lookup_count {
    lookup_offsets.push(reader.read_uint16())
  }
  for idx in lookup_indices {
    if idx < 0 || idx >= lookup_count {
      continue
    }
    let lookup_abs = lookup_list_abs + lookup_offsets[idx]
    process_lookup(reader, lookup_abs, relevant_gids, cp_by_gid, pairs)
  }
}

///|
/// Collect the union of `LookupListIndex` values across every Feature
/// record tagged 'kern'. The same lookup may be shared by multiple
/// features (e.g. `kern` + script-specific `kern_latn`); deduping via a
/// Map keeps the LookupList walk linear.
fn collect_kern_lookup_indices(
  reader : @font.BinaryReader,
  feature_list_abs : Int,
) -> Array[Int] {
  reader.seek(feature_list_abs)
  let feature_count = reader.read_uint16()
  // Record (FeatureRecord) = tag (4) + featureOffset (2).
  let feature_records : Array[(Int, Int)] = []
  for _ in 0..<feature_count {
    let tag_u32 = reader.read_uint32()
    let feat_offset = reader.read_uint16()
    feature_records.push((tag_u32, feat_offset))
  }
  // 'kern' = 0x6B65726E
  let kern_tag = 0x6B65726E
  let seen : Map[Int, Unit] = Map([], capacity=16)
  let out : Array[Int] = []
  for rec in feature_records {
    let (tag_u32, feat_offset) = rec
    if tag_u32 != kern_tag {
      continue
    }
    // Feature Table: featureParamsOffset (2, ignored), lookupIndexCount,
    // lookupListIndices[lookupIndexCount].
    let feat_abs = feature_list_abs + feat_offset
    reader.seek(feat_abs)
    let _params = reader.read_uint16()
    let lookup_index_count = reader.read_uint16()
    for _ in 0..<lookup_index_count {
      let lidx = reader.read_uint16()
      if !seen.contains(lidx) {
        seen[lidx] = ()
        out.push(lidx)
      }
    }
  }
  out
}

///|
/// Decode a single Lookup Table at absolute offset `lookup_abs` and
/// dispatch each subtable to the Pair Adjustment handlers. Extension
/// lookups (type 9) are unwrapped to their inner subtable on the fly.
fn process_lookup(
  reader : @font.BinaryReader,
  lookup_abs : Int,
  relevant_gids : Array[Int],
  cp_by_gid : Map[Int, Int],
  pairs : Map[Int, Int],
) -> Unit {
  reader.seek(lookup_abs)
  let lookup_type = reader.read_uint16()
  let _lookup_flag = reader.read_uint16()
  let subtable_count = reader.read_uint16()
  let subtable_offsets : Array[Int] = []
  for _ in 0..<subtable_count {
    subtable_offsets.push(reader.read_uint16())
  }
  // markFilteringSet (2) follows if `lookup_flag & 0x0010` is set, but
  // it's a glyph-class index we don't use, so skipping the read is
  // safe.
  for st_offset in subtable_offsets {
    let st_abs = lookup_abs + st_offset
    if lookup_type == 2 {
      process_pair_adjustment(reader, st_abs, relevant_gids, cp_by_gid, pairs)
    } else if lookup_type == 9 {
      // Extension Positioning subtable:
      //   posFormat (uint16, always 1)
      //   extensionLookupType (uint16) — actual type
      //   extensionOffset (uint32) — offset from this subtable
      reader.seek(st_abs)
      let _pos_format = reader.read_uint16()
      let ext_type = reader.read_uint16()
      let ext_offset = reader.read_uint32()
      if ext_type == 2 {
        process_pair_adjustment(
          reader,
          st_abs + ext_offset,
          relevant_gids,
          cp_by_gid,
          pairs,
        )
      }
    }
    // Other lookup types (single, cursive, mark-to-base, …) cannot
    // produce pair kerning; ignoring them matches the Python prototype.
  }
}

///|
/// Decode a Pair Adjustment subtable at absolute offset `st_abs`. Routes
/// to Format-1 (explicit (firstGlyph, secondGlyph) pairs) or Format-2
/// (class-based grid) based on the leading `posFormat`.
fn process_pair_adjustment(
  reader : @font.BinaryReader,
  st_abs : Int,
  relevant_gids : Array[Int],
  cp_by_gid : Map[Int, Int],
  pairs : Map[Int, Int],
) -> Unit {
  reader.seek(st_abs)
  let pos_format = reader.read_uint16()
  match pos_format {
    1 => process_pair_pos_format1(reader, st_abs, cp_by_gid, pairs)
    2 =>
      process_pair_pos_format2(reader, st_abs, relevant_gids, cp_by_gid, pairs)
    _ => ()
  }
}

///|
/// Pair Adjustment Format 1: an explicit table of `(firstGlyph,
/// secondGlyph) → ValueRecord` entries. We read the Coverage to learn
/// every first-glyph, then walk each PairSet to pick up each second-
/// glyph and its XAdvance. Pairs whose first or second glyph is outside
/// the ASCII range or whose adjustment is zero are dropped.
fn process_pair_pos_format1(
  reader : @font.BinaryReader,
  st_abs : Int,
  cp_by_gid : Map[Int, Int],
  pairs : Map[Int, Int],
) -> Unit {
  // PairPosFormat1: posFormat (already consumed), coverageOffset (2),
  //   valueFormat1 (2), valueFormat2 (2), pairSetCount (2),
  //   pairSetOffsets[pairSetCount] (2 each).
  let coverage_offset = reader.read_uint16()
  let value_format1 = reader.read_uint16()
  let value_format2 = reader.read_uint16()
  let pair_set_count = reader.read_uint16()
  let pair_set_offsets : Array[Int] = []
  for _ in 0..<pair_set_count {
    pair_set_offsets.push(reader.read_uint16())
  }
  let first_glyphs = read_coverage(reader, st_abs + coverage_offset)
  // Each ValueRecord's byte size is fixed by the format flags; cache it
  // to avoid recomputing inside the inner loop.
  let vr1_size = value_record_size(value_format1)
  let vr2_size = value_record_size(value_format2)
  // Coverage glyphCount and pairSetCount are required by the spec to be
  // equal — pair them up by index.
  let n = if first_glyphs.length() < pair_set_count {
    first_glyphs.length()
  } else {
    pair_set_count
  }
  for i in 0..<n {
    let first_gid = first_glyphs[i]
    // Skip first-glyphs outside our ASCII range up front — saves
    // decoding the entire PairSet when it can't contribute.
    if !cp_by_gid.contains(first_gid) {
      continue
    }
    let first_cp = cp_by_gid.get(first_gid).unwrap()
    let ps_abs = st_abs + pair_set_offsets[i]
    reader.seek(ps_abs)
    let pair_value_count = reader.read_uint16()
    // PairValueRecord: secondGlyph (2), value1 (vr1_size), value2 (vr2_size).
    for _ in 0..<pair_value_count {
      let second_gid = reader.read_uint16()
      let x_advance = read_value_record_x_advance(reader, value_format1)
      // Skip the rest of value1 + the entire value2; we never consume
      // them but we need the cursor positioned for the next iteration.
      skip_rest_of_value_record(reader, value_format1)
      reader.skip(vr2_size)
      if !cp_by_gid.contains(second_gid) {
        continue
      }
      if x_advance == 0 {
        continue
      }
      let second_cp = cp_by_gid.get(second_gid).unwrap()
      let key = first_cp * GPOS_PAIR_KEY_SHIFT + second_cp
      pairs[key] = x_advance
    }
    // `vr1_size` is implicit through the read_value_record_x_advance +
    // skip_rest_of_value_record calls; the variable is retained for
    // self-documenting code.
    let _ = vr1_size
  }
}

///|
/// Pair Adjustment Format 2: a `Class1Count × Class2Count` matrix of
/// ValueRecords indexed by per-glyph class assignments. For every
/// (first_gid ∈ coverage ∩ ASCII) × (second_gid ∈ ASCII), look up the
/// (c1, c2) cell and emit a kerning entry when XAdvance is non-zero.
///
/// This is the most important format for the bundled fonts — Carlito
/// keeps *all* of its ASCII kerning here and the legacy `kern` table is
/// empty.
fn process_pair_pos_format2(
  reader : @font.BinaryReader,
  st_abs : Int,
  relevant_gids : Array[Int],
  cp_by_gid : Map[Int, Int],
  pairs : Map[Int, Int],
) -> Unit {
  // PairPosFormat2: posFormat (consumed), coverageOffset (2),
  //   valueFormat1 (2), valueFormat2 (2),
  //   classDef1Offset (2), classDef2Offset (2),
  //   class1Count (2), class2Count (2),
  //   class1Record[class1Count] of:
  //     class2Record[class2Count] of: value1, value2.
  let coverage_offset = reader.read_uint16()
  let value_format1 = reader.read_uint16()
  let value_format2 = reader.read_uint16()
  let class_def1_offset = reader.read_uint16()
  let class_def2_offset = reader.read_uint16()
  let class1_count = reader.read_uint16()
  let class2_count = reader.read_uint16()
  // We're now positioned at the start of class1Records. Stash the
  // absolute offset before we wander off to read coverage / class defs.
  let class_records_abs = reader.position()
  let vr1_size = value_record_size(value_format1)
  let vr2_size = value_record_size(value_format2)
  let pair_size = vr1_size + vr2_size
  let row_size = class2_count * pair_size
  let coverage_glyphs = read_coverage(reader, st_abs + coverage_offset)
  // Build a Set-like Map for O(1) "is this glyph in coverage?".
  let cov_set : Map[Int, Unit] = Map([], capacity=coverage_glyphs.length())
  for g in coverage_glyphs {
    cov_set[g] = ()
  }
  let class_def1 = read_class_def(reader, st_abs + class_def1_offset)
  let class_def2 = read_class_def(reader, st_abs + class_def2_offset)
  for g1 in relevant_gids {
    if !cov_set.contains(g1) {
      continue
    }
    // class_def1 omits glyphs whose class is 0; treat absence as class
    // 0, which matches the OpenType default-class rule.
    let c1 = class_def1.get(g1).unwrap_or(0)
    if c1 < 0 || c1 >= class1_count {
      continue
    }
    let row_abs = class_records_abs + c1 * row_size
    let cp1 = cp_by_gid.get(g1).unwrap()
    for g2 in relevant_gids {
      let c2 = class_def2.get(g2).unwrap_or(0)
      if c2 < 0 || c2 >= class2_count {
        continue
      }
      let cell_abs = row_abs + c2 * pair_size
      reader.seek(cell_abs)
      let x_advance = read_value_record_x_advance(reader, value_format1)
      if x_advance == 0 {
        continue
      }
      let cp2 = cp_by_gid.get(g2).unwrap()
      let key = cp1 * GPOS_PAIR_KEY_SHIFT + cp2
      pairs[key] = x_advance
    }
  }
  // value_format2 is consumed via the `pair_size` arithmetic; suppress
  // the unused-variable warning without leaking a `let _` into runtime.
  let _ = value_format2
}

///|
/// Decode a Coverage Table (Format 1 or 2) at the given absolute
/// offset. Returns the glyph IDs in coverage order (Format 1) or in
/// (start, end) range order (Format 2 expanded). The order matters for
/// Format-1 pair-set indexing but is irrelevant for Format-2.
fn read_coverage(reader : @font.BinaryReader, abs_offset : Int) -> Array[Int] {
  reader.seek(abs_offset)
  let format = reader.read_uint16()
  let out : Array[Int] = []
  match format {
    1 => {
      // CoverageFormat1: glyphCount, glyphArray[glyphCount] uint16.
      let glyph_count = reader.read_uint16()
      for _ in 0..<glyph_count {
        out.push(reader.read_uint16())
      }
    }
    2 => {
      // CoverageFormat2: rangeCount, rangeRecord[]
      //   { startGlyphID (2), endGlyphID (2), startCoverageIndex (2) }.
      // The startCoverageIndex is irrelevant to us — we only need the
      // set membership, not the coverage-index value.
      let range_count = reader.read_uint16()
      for _ in 0..<range_count {
        let start_gid = reader.read_uint16()
        let end_gid = reader.read_uint16()
        let _start_cov_index = reader.read_uint16()
        for g in start_gid..<=end_gid {
          out.push(g)
        }
      }
    }
    _ => ()
  }
  out
}

///|
/// Decode a ClassDef Table (Format 1 or 2) into `glyph_id → class`. Any
/// glyph not present is implicitly class 0 (the OpenType default).
fn read_class_def(
  reader : @font.BinaryReader,
  abs_offset : Int,
) -> Map[Int, Int] {
  reader.seek(abs_offset)
  let format = reader.read_uint16()
  let out : Map[Int, Int] = Map([], capacity=64)
  match format {
    1 => {
      // ClassDefFormat1: startGlyphID (2), glyphCount (2),
      //   classValueArray[glyphCount] uint16.
      let start_gid = reader.read_uint16()
      let glyph_count = reader.read_uint16()
      for i in 0..<glyph_count {
        let cls = reader.read_uint16()
        if cls != 0 {
          out[start_gid + i] = cls
        }
      }
    }
    2 => {
      // ClassDefFormat2: classRangeCount (2),
      //   classRangeRecord[] { startGlyphID, endGlyphID, class }.
      let range_count = reader.read_uint16()
      for _ in 0..<range_count {
        let start_gid = reader.read_uint16()
        let end_gid = reader.read_uint16()
        let cls = reader.read_uint16()
        if cls != 0 {
          for g in start_gid..<=end_gid {
            out[g] = cls
          }
        }
      }
    }
    _ => ()
  }
  out
}

///|
/// Size in bytes of a `ValueRecord` for the given `valueFormat`. Each
/// bit in `value_format` (low 8 bits, since bits 0–7 are the standard
/// value-record fields) selects a uint16 field.
fn value_record_size(value_format : Int) -> Int {
  let mut count = 0
  let mut bits = value_format & 0xFF
  while bits != 0 {
    if (bits & 1) != 0 {
      count = count + 1
    }
    bits = bits >> 1
  }
  count * 2
}

///|
/// Read a `ValueRecord` at the current cursor and return only its
/// XAdvance field. Any preceding fields (XPlacement, YPlacement) are
/// skipped past; subsequent fields are left for the caller to skip via
/// `skip_rest_of_value_record`.
///
/// Returns 0 when the record has no XAdvance bit set.
fn read_value_record_x_advance(
  reader : @font.BinaryReader,
  value_format : Int,
) -> Int {
  // ValueRecord field order (OpenType spec):
  //   bit 0x0001 XPlacement
  //   bit 0x0002 YPlacement
  //   bit 0x0004 XAdvance
  //   bit 0x0008 YAdvance
  //   bit 0x0010 XPlacementDevice (uint16 device-table offset)
  //   bit 0x0020 YPlacementDevice
  //   bit 0x0040 XAdvanceDevice
  //   bit 0x0080 YAdvanceDevice
  if (value_format & 0x0001) != 0 {
    let _ = reader.read_int16()
  }
  if (value_format & 0x0002) != 0 {
    let _ = reader.read_int16()
  }
  if (value_format & VF_X_ADVANCE) != 0 {
    return reader.read_int16()
  }
  0
}

///|
/// Skip past any ValueRecord fields that come *after* XAdvance. Called
/// immediately after `read_value_record_x_advance` so the cursor lands
/// at the start of the next record.
fn skip_rest_of_value_record(
  reader : @font.BinaryReader,
  value_format : Int,
) -> Unit {
  let mut remaining = 0
  if (value_format & 0x0008) != 0 {
    remaining = remaining + 2
  }
  if (value_format & 0x0010) != 0 {
    remaining = remaining + 2
  }
  if (value_format & 0x0020) != 0 {
    remaining = remaining + 2
  }
  if (value_format & 0x0040) != 0 {
    remaining = remaining + 2
  }
  if (value_format & 0x0080) != 0 {
    remaining = remaining + 2
  }
  reader.skip(remaining)
}
