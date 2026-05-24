// Real font measurement on top of mizchi/font.
//
// `FontMeasurer` wraps a parsed `TTFont` and exposes the small
// surface the renderer needs: per-character advance with kerning,
// total text width, ascender/descender/line-gap ratios.
//
// Kerning composes the legacy `kern` table (decoded by mizchi/font)
// with a pre-parsed GPOS pair-adjustment map (extracted at load
// time from the same bytes by `gpos_extract.mbt`). The two paths
// are summed so a font that ships kerning in either table — or
// both — measures correctly.

///|
/// Wraps a parsed TTFont with the GPOS pair-kerning map attached at
/// `with_gpos_kern` time.
pub struct FontMeasurer {
  ttfont : @font.TTFont
  /// `units_per_em` from the head table — used to scale every
  /// `hmtx` value into pixels.
  units_per_em : Int
  /// Pre-extracted GPOS pair kerning, keyed by
  /// `(first_cp * GPOS_KERN_KEY_SHIFT) | second_cp`. Empty when the
  /// font has no GPOS `kern` feature or the registry has not yet
  /// attached the map.
  gpos_kern_map : Map[Int, Int]
}

///|
/// One Pair Adjustment entry recovered from the GPOS table.
/// Codepoints are Unicode scalars (ASCII printable for the
/// extractor's current scope). `x_advance` is in font units and is
/// scaled by `font_size_px / units_per_em` like every other `hmtx`
/// value.
pub(all) struct GposKernEntry {
  first : Int
  second : Int
  x_advance : Int
}

///|
/// Parse `bytes` (TTF/OTF payload) into a `FontMeasurer`. Returns
/// `None` if the data is not a recognised font format. The
/// returned measurer has an empty GPOS map; callers attach one via
/// `with_gpos_kern`.
pub fn make_font_measurer(bytes : Bytes) -> FontMeasurer? {
  match @font.parse_font(bytes) {
    None => None
    Some(tt) =>
      Some({
        ttfont: tt,
        units_per_em: tt.units_per_em,
        gpos_kern_map: Map([], capacity=0),
      })
  }
}

///|
/// Parse a face out of a TTC container by index. `ttc_index=None`
/// falls back to `make_font_measurer` for plain TTF. Mirrors
/// `@font.parse_font_at` in `mizchi/font/src/ttc.mbt`.
///
/// macOS and CJK Noto faces ship multiple cuts in a single `.ttc`
/// file; without this entry point the resolver could only read
/// single-face TTFs and every host with `.ttc` system fonts would
/// require repackaging.
pub fn make_font_measurer_at(
  bytes : Bytes,
  ttc_index : Int?,
) -> FontMeasurer? {
  match ttc_index {
    None => make_font_measurer(bytes)
    Some(idx) =>
      match @font.parse_font_at(bytes, idx) {
        None => None
        Some(tt) =>
          Some({
            ttfont: tt,
            units_per_em: tt.units_per_em,
            gpos_kern_map: Map([], capacity=0),
          })
      }
  }
}

///|
/// Key multiplier for `gpos_kern_map`. Chosen as 2^21 so it
/// comfortably exceeds any Unicode scalar (max 0x10FFFF). The
/// caller computes `first * shift + second`.
const GPOS_KERN_KEY_SHIFT : Int = 0x200000

///|
/// Build the `(first, second) → x_advance` map consumed by
/// `kerning_adjust`. Duplicate pairs collapse to the last entry.
fn build_gpos_kern_map(entries : Array[GposKernEntry]) -> Map[Int, Int] {
  let m : Map[Int, Int] = Map([], capacity=entries.length())
  for e in entries {
    let key = e.first * GPOS_KERN_KEY_SHIFT + e.second
    m[key] = e.x_advance
  }
  m
}

///|
/// Return a copy of `self` with the GPOS kerning map attached.
/// Called by the registry immediately after `make_font_measurer*`
/// so every measurement on the returned instance sees the map.
pub fn FontMeasurer::with_gpos_kern(
  self : FontMeasurer,
  entries : Array[GposKernEntry],
) -> FontMeasurer {
  { ..self, gpos_kern_map: build_gpos_kern_map(entries) }
}

///|
/// Resolve a Unicode code point to the font's glyph id, or 0 (the
/// `.notdef` glyph) when the cmap has no entry.
pub fn FontMeasurer::glyph_index(self : FontMeasurer, codepoint : Int) -> Int {
  self.ttfont.glyph_index(codepoint)
}

///|
/// Real advance width of `char` at `font_size_pt`. Computed as
/// `advance_units * font_size_px / units_per_em`. Result is in
/// pixels at 96 DPI.
///
/// CJK fallback: when the loaded font has no cmap entry for `char`
/// AND the codepoint sits in a CJK block, the `.notdef` rectangle
/// advance is replaced with a full em-square (`font_size_px`). This
/// matches the layout behaviour every CJK system font produces
/// (one em-square per ideograph) so the renderer's line breaker
/// computes correct wrap points when a body face lacks CJK
/// coverage and the host's CJK fallback face fills in at paint
/// time.
pub fn FontMeasurer::char_advance(
  self : FontMeasurer,
  char : Char,
  font_size_pt~ : Double,
) -> Double {
  let glyph_id = self.ttfont.glyph_index(char.to_int())
  let font_size_px = font_size_pt * pt_to_px
  if glyph_id == 0 && is_cjk_char(char) {
    return font_size_px
  }
  let metrics = self.ttfont.glyph_metrics(glyph_id)
  let scale = font_size_px / self.units_per_em.to_double()
  metrics.advance_width.to_double() * scale
}

///|
/// Kerning adjustment for the pair `(prev, char)`, in pixels at
/// `font_size_pt`. Consults two sources in order:
///
///   1. The legacy TrueType `kern` table (decoded by mizchi/font).
///   2. The pre-extracted GPOS pair map attached at load time.
///
/// Returns 0.0 when neither source has an entry for the pair.
pub fn FontMeasurer::kerning_adjust(
  self : FontMeasurer,
  prev : Char,
  char : Char,
  font_size_pt~ : Double,
) -> Double {
  let font_size_px = font_size_pt * pt_to_px
  let scale = font_size_px / self.units_per_em.to_double()
  let lhs = self.ttfont.glyph_index(prev.to_int())
  let rhs = self.ttfont.glyph_index(char.to_int())
  let key = lhs * 65536 + rhs
  match self.ttfont.kern_pairs.get(key) {
    Some(adjust) => return adjust.to_double() * scale
    None => ()
  }
  if self.gpos_kern_map.length() > 0 {
    let cp_key = prev.to_int() * GPOS_KERN_KEY_SHIFT + char.to_int()
    match self.gpos_kern_map.get(cp_key) {
      Some(adjust) => return adjust.to_double() * scale
      None => ()
    }
  }
  0.0
}

///|
/// Total text width for `text`. Sums per-character `char_advance`
/// with kern adjustments between adjacent characters.
/// `letter_spacing_px` adds extra spacing between every adjacent
/// pair (not after the last character).
pub fn FontMeasurer::measure_text(
  self : FontMeasurer,
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px? : Double = 0.0,
) -> Double {
  let chars : Array[Char] = []
  for c in text {
    chars.push(c)
  }
  let n = chars.length()
  let mut total = 0.0
  for i in 0..<n {
    total = total + self.char_advance(chars[i], font_size_pt~)
    if i > 0 {
      total = total +
        self.kerning_adjust(chars[i - 1], chars[i], font_size_pt~) +
        letter_spacing_px
    }
  }
  total
}

///|
/// Ascender ratio. `ascent / units_per_em` — the fraction of the
/// font size from the baseline to the top of the line box.
pub fn FontMeasurer::ascender_ratio(self : FontMeasurer) -> Double {
  if self.units_per_em == 0 {
    return 0.8
  }
  self.ttfont.ascent.to_double() / self.units_per_em.to_double()
}

///|
/// Descender ratio (positive value, even though `descent` is
/// typically negative in TrueType conventions).
pub fn FontMeasurer::descender_ratio(self : FontMeasurer) -> Double {
  if self.units_per_em == 0 {
    return 0.2
  }
  let d = self.ttfont.descent.to_double()
  let abs_d = if d < 0.0 { -d } else { d }
  abs_d / self.units_per_em.to_double()
}

///|
/// Line-gap ratio (additional leading recommended by the font's
/// `hhea` line_gap).
pub fn FontMeasurer::line_gap_ratio(self : FontMeasurer) -> Double {
  if self.units_per_em == 0 {
    return 0.0
  }
  self.ttfont.line_gap.to_double() / self.units_per_em.to_double()
}
