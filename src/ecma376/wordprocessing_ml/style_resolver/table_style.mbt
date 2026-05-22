// =============================================================================
// §17.7.6 — table-style conditional formatting resolver. The base
// `<w:style>` cascade in `effective_properties` already handles
// pPr / rPr / tblPr / trPr / tcPr inheritance via `basedOn`; this
// module layers the §17.7.6 `<w:tblStylePr w:type="...">` overrides
// on top, gated by `<w:tblPr>/<w:tblLook>` flags and the cell's
// position (firstRow / lastRow / firstColumn / lastColumn /
// banding / corner).
//
// The §17.7.6 override precedence (per spec, weakest → strongest):
//   wholeTable
//   band1Vert / band2Vert (banded columns)
//   band1Horz / band2Horz (banded rows)
//   firstCol / lastCol
//   firstRow / lastRow
//   nwCell / neCell / swCell / seCell (corners)
//   direct formatting
//
// We expose `resolve_cell` which takes the cell's coordinates and
// returns merged pPr/rPr/tblPr/trPr/tcPr ready for the renderer.
// =============================================================================

///|
/// Cached projection of a `<w:style w:type="table">` so the per-cell
/// resolver does not re-parse the tblStylePr children for every cell.
pub(all) struct ResolvedTableStyle {
  /// §17.7.4 base — fully resolved properties after walking the
  /// basedOn chain (no §17.7.6 conditional overrides applied yet).
  base : EffectiveProperties
  /// §17.7.6 — conditional overrides keyed by ST_TblStyleOverrideType.
  /// Stored as raw XML elements (the `<w:pPr>` / `<w:rPr>` / etc.
  /// children of `<w:tblStylePr>`) so they go through the same
  /// `merge_property_element` machinery as direct formatting.
  whole_table : EffectiveProperties
  first_row : EffectiveProperties
  last_row : EffectiveProperties
  first_col : EffectiveProperties
  last_col : EffectiveProperties
  band1_horz : EffectiveProperties
  band2_horz : EffectiveProperties
  band1_vert : EffectiveProperties
  band2_vert : EffectiveProperties
  nw_cell : EffectiveProperties
  ne_cell : EffectiveProperties
  sw_cell : EffectiveProperties
  se_cell : EffectiveProperties
} derive(Eq, Debug)

///|
/// §17.4.6 `<w:tblLook>` — gating bits that say which §17.7.6
/// conditional sets are active for this table. We carry the four
/// boolean flags the spec defines on CT_TblLook plus the two
/// no-banding flags (semantics: when true, the corresponding banded
/// override set is DISABLED).
pub(all) struct TblLook {
  first_row : Bool
  last_row : Bool
  first_column : Bool
  last_column : Bool
  no_h_band : Bool
  no_v_band : Bool
} derive(Eq, Debug)

///|
/// Default TblLook — Microsoft's default when `<w:tblLook>` is
/// absent is `0x04A0`, which sets firstRow + firstColumn and
/// disables banding. We follow that convention so untagged tables
/// pick up firstRow / firstColumn overrides automatically.
pub fn TblLook::default_() -> TblLook {
  {
    first_row: true,
    last_row: false,
    first_column: true,
    last_column: false,
    no_h_band: true,
    no_v_band: true,
  }
}

///|
/// §17.4.6 — decode a typed `<w:tblLook>` element into the runtime
/// TblLook view. Accepts the modern boolean-child form as well as
/// the legacy `@w:val` hex-mask attribute.
pub fn TblLook::from_element(
  element : @xml.Element,
) -> TblLook {
  let mut first_row = false
  let mut last_row = false
  let mut first_column = false
  let mut last_column = false
  let mut no_h_band = false
  let mut no_v_band = false
  // First honour the legacy `w:val` hex mask if present (e.g.
  // "04A0" = 0x04A0). Bits per §17.4.6: 0x0020 firstRow,
  // 0x0040 lastRow, 0x0080 firstColumn, 0x0100 lastColumn,
  // 0x0200 noHBand, 0x0400 noVBand.
  match attr_value(element, "val") {
    Some(hex_text) =>
      match parse_hex(hex_text) {
        Some(bits) => {
          first_row = (bits & 0x0020) != 0
          last_row = (bits & 0x0040) != 0
          first_column = (bits & 0x0080) != 0
          last_column = (bits & 0x0100) != 0
          no_h_band = (bits & 0x0200) != 0
          no_v_band = (bits & 0x0400) != 0
        }
        None => ()
      }
    None => ()
  }
  // The modern boolean-attribute form (`w:firstRow="1"`) overrides
  // each bit independently. We treat any of "1", "true", "on" as
  // truthy and "0", "false", "off" as falsy.
  match attr_value(element, "firstRow") {
    Some(v) => first_row = parse_on_off_simple(v)
    None => ()
  }
  match attr_value(element, "lastRow") {
    Some(v) => last_row = parse_on_off_simple(v)
    None => ()
  }
  match attr_value(element, "firstColumn") {
    Some(v) => first_column = parse_on_off_simple(v)
    None => ()
  }
  match attr_value(element, "lastColumn") {
    Some(v) => last_column = parse_on_off_simple(v)
    None => ()
  }
  match attr_value(element, "noHBand") {
    Some(v) => no_h_band = parse_on_off_simple(v)
    None => ()
  }
  match attr_value(element, "noVBand") {
    Some(v) => no_v_band = parse_on_off_simple(v)
    None => ()
  }
  { first_row, last_row, first_column, last_column, no_h_band, no_v_band }
}

///|
/// §22.9.2.7 ST_OnOff — closed-6 enum:
///   `1`, `0`, `true`, `false`, `on`, `off`.
/// Values outside the closed set are schema violations; we
/// return false (the spec-permitted default when the attribute
/// is omitted) so the toggle does not silently flip to true on
/// garbage input.
fn parse_on_off_simple(v : String) -> Bool {
  match v {
    "1" => true
    "true" => true
    "on" => true
    "0" => false
    "false" => false
    "off" => false
    // Schema violation — value outside ST_OnOff.
    _ => false
  }
}

///|
fn parse_hex(text : String) -> Int? {
  if text.length() == 0 {
    return None
  }
  let mut value = 0
  for i in 0..<text.length() {
    let ch = text.code_unit_at(i).to_int()
    let digit = if ch >= 0x30 && ch <= 0x39 {
      ch - 0x30
    } else if ch >= 0x41 && ch <= 0x46 {
      ch - 0x41 + 10
    } else if ch >= 0x61 && ch <= 0x66 {
      ch - 0x61 + 10
    } else {
      return None
    }
    value = (value * 16) + digit
  }
  Some(value)
}

///|
/// §17.7.6 — resolve a table-style id into a `ResolvedTableStyle`.
/// The base cascade is the standard `effective_properties` (basedOn
/// chain + docDefaults); the conditional buckets are populated by
/// scanning the requested style's element directly (we read
/// `<w:tblStylePr w:type="...">` children rather than walking the
/// typed projection because `CT_Style` does not surface them yet —
/// see complex_types_table.mbt:1923).
pub fn resolve_table_style(
  table : @domain.CT_Styles,
  style_id : @domain.StyleId,
) -> ResolvedTableStyle {
  let base = effective_properties(table, style_id)
  let style_el = lookup_style_element(table, style_id)
  let mut whole_table = empty_effective_view()
  let mut first_row = empty_effective_view()
  let mut last_row = empty_effective_view()
  let mut first_col = empty_effective_view()
  let mut last_col = empty_effective_view()
  let mut band1_horz = empty_effective_view()
  let mut band2_horz = empty_effective_view()
  let mut band1_vert = empty_effective_view()
  let mut band2_vert = empty_effective_view()
  let mut nw_cell = empty_effective_view()
  let mut ne_cell = empty_effective_view()
  let mut sw_cell = empty_effective_view()
  let mut se_cell = empty_effective_view()
  match style_el {
    None => ()
    Some(e) =>
      for child in e.children {
        match child {
          @xml.Element(el) =>
            if el.name.local_name == "tblStylePr" {
              let bucket = bucket_for(el)
              let view = extract_view(el)
              // §17.7.6 ST_TblStyleOverrideType — closed-13.
              // Each bucket maps a conditional-formatting context
              // (whole-table → row/col bands → corner cells).
              match bucket {
                Some("wholeTable") => whole_table = view
                Some("firstRow") => first_row = view
                Some("lastRow") => last_row = view
                Some("firstCol") => first_col = view
                Some("lastCol") => last_col = view
                Some("band1Horz") => band1_horz = view
                Some("band2Horz") => band2_horz = view
                Some("band1Vert") => band1_vert = view
                Some("band2Vert") => band2_vert = view
                Some("nwCell") => nw_cell = view
                Some("neCell") => ne_cell = view
                Some("swCell") => sw_cell = view
                Some("seCell") => se_cell = view
                // Schema violation — value outside
                // ST_TblStyleOverrideType.  Drop silently so the
                // remaining buckets keep cascading.
                Some(_) => ()
                None => ()
              }
            }
          _ => ()
        }
      }
  }
  {
    base,
    whole_table,
    first_row,
    last_row,
    first_col,
    last_col,
    band1_horz,
    band2_horz,
    band1_vert,
    band2_vert,
    nw_cell,
    ne_cell,
    sw_cell,
    se_cell,
  }
}

///|
/// §17.7.6 — resolve a single cell's effective properties by
/// layering, in spec-mandated order:
///   base → wholeTable → bandVert(if applicable) → bandHorz(if
///   applicable) → firstCol/lastCol(gated by tbl_look) →
///   firstRow/lastRow(gated by tbl_look) → corner cell → direct.
pub fn resolve_cell(
  resolved : ResolvedTableStyle,
  tbl_look : TblLook,
  row_index : Int,
  col_index : Int,
  row_count : Int,
  col_count : Int,
  direct_p_pr : @xml.Element?,
  direct_r_pr : @xml.Element?,
  direct_tc_pr : @xml.Element?,
  direct_tr_pr : @xml.Element?,
) -> EffectiveProperties {
  let mut acc = resolved.base
  acc = merge_effective_pub(acc, resolved.whole_table)
  // §17.7.6.4-5 — banded columns/rows. Banding starts AFTER the
  // first/last column/row if those are reserved by tbl_look.
  if !tbl_look.no_v_band {
    let band = vertical_band(col_index, col_count, tbl_look)
    match band {
      1 => acc = merge_effective_pub(acc, resolved.band1_vert)
      2 => acc = merge_effective_pub(acc, resolved.band2_vert)
      _ => ()
    }
  }
  if !tbl_look.no_h_band {
    let band = horizontal_band(row_index, row_count, tbl_look)
    match band {
      1 => acc = merge_effective_pub(acc, resolved.band1_horz)
      2 => acc = merge_effective_pub(acc, resolved.band2_horz)
      _ => ()
    }
  }
  if tbl_look.first_column && col_index == 0 {
    acc = merge_effective_pub(acc, resolved.first_col)
  }
  if tbl_look.last_column && col_count > 0 && col_index == col_count - 1 {
    acc = merge_effective_pub(acc, resolved.last_col)
  }
  if tbl_look.first_row && row_index == 0 {
    acc = merge_effective_pub(acc, resolved.first_row)
  }
  if tbl_look.last_row && row_count > 0 && row_index == row_count - 1 {
    acc = merge_effective_pub(acc, resolved.last_row)
  }
  // Corner cells take precedence over the row/column bucket they
  // share an edge with.
  let is_top = tbl_look.first_row && row_index == 0
  let is_bot = tbl_look.last_row && row_count > 0 && row_index == row_count - 1
  let is_left = tbl_look.first_column && col_index == 0
  let is_right = tbl_look.last_column && col_count > 0 && col_index == col_count - 1
  if is_top && is_left {
    acc = merge_effective_pub(acc, resolved.nw_cell)
  }
  if is_top && is_right {
    acc = merge_effective_pub(acc, resolved.ne_cell)
  }
  if is_bot && is_left {
    acc = merge_effective_pub(acc, resolved.sw_cell)
  }
  if is_bot && is_right {
    acc = merge_effective_pub(acc, resolved.se_cell)
  }
  // Direct formatting wins over every conditional set.
  let direct = {
    p_pr: direct_p_pr,
    r_pr: direct_r_pr,
    tbl_pr: None,
    tr_pr: direct_tr_pr,
    tc_pr: direct_tc_pr,
  }
  merge_effective_pub(acc, direct)
}

///|
/// Public wrapper around `merge_effective` so the per-cell resolver
/// can compose `EffectiveProperties` views without forcing every
/// caller to import the private helper.
pub fn merge_effective_pub(
  base : EffectiveProperties,
  derived : EffectiveProperties,
) -> EffectiveProperties {
  merge_effective(base, derived)
}

///|
fn empty_effective_view() -> EffectiveProperties {
  { p_pr: None, r_pr: None, tbl_pr: None, tr_pr: None, tc_pr: None }
}

///|
/// §17.7.6 — read the `<w:tblStylePr>` child elements directly so
/// we get the raw XML the merge machinery expects.
fn extract_view(tbl_style_pr : @xml.Element) -> EffectiveProperties {
  let mut p_pr : @xml.Element? = None
  let mut r_pr : @xml.Element? = None
  let mut tbl_pr : @xml.Element? = None
  let mut tr_pr : @xml.Element? = None
  let mut tc_pr : @xml.Element? = None
  for child in tbl_style_pr.children {
    match child {
      @xml.Element(el) =>
        match el.name.local_name {
          "pPr" => p_pr = Some(el)
          "rPr" => r_pr = Some(el)
          "tblPr" => tbl_pr = Some(el)
          "trPr" => tr_pr = Some(el)
          "tcPr" => tc_pr = Some(el)
          _ => ()
        }
      _ => ()
    }
  }
  { p_pr, r_pr, tbl_pr, tr_pr, tc_pr }
}

///|
fn bucket_for(tbl_style_pr : @xml.Element) -> String? {
  for a in tbl_style_pr.attributes {
    if a.name.local_name == "type" {
      return Some(a.value)
    }
  }
  None
}

///|
fn lookup_style_element(
  table : @domain.CT_Styles,
  style_id : @domain.StyleId,
) -> @xml.Element? {
  for child in table.element.children {
    match child {
      @xml.Element(el) =>
        if el.name.local_name == "style" {
          for a in el.attributes {
            if a.name.local_name == "styleId" && a.value == style_id.value {
              return Some(el)
            }
          }
        }
      _ => ()
    }
  }
  None
}

///|
/// §17.7.6.4 — banded columns: even/odd pattern excluding the
/// first/last column when those buckets are active.
fn vertical_band(col : Int, col_count : Int, tbl_look : TblLook) -> Int {
  let first_offset = if tbl_look.first_column { 1 } else { 0 }
  let last_offset = if tbl_look.last_column { 1 } else { 0 }
  if col < first_offset {
    return 0
  }
  if col_count > 0 && col >= col_count - last_offset {
    return 0
  }
  let rel = col - first_offset
  if rel % 2 == 0 {
    1
  } else {
    2
  }
}

///|
fn horizontal_band(row : Int, row_count : Int, tbl_look : TblLook) -> Int {
  let first_offset = if tbl_look.first_row { 1 } else { 0 }
  let last_offset = if tbl_look.last_row { 1 } else { 0 }
  if row < first_offset {
    return 0
  }
  if row_count > 0 && row >= row_count - last_offset {
    return 0
  }
  let rel = row - first_offset
  if rel % 2 == 0 {
    1
  } else {
    2
  }
}

