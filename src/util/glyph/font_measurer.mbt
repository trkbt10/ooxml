// Real font measurement based on mizchi/font (TTF/OTF parser).
//
// The earlier `measurer.mbt` / `font_metrics.mbt` only do *statistical*
// estimation — they are accurate for unembedded common fonts but
// cannot reflect actual font metrics when a TTF/OTF is available
// (custom fonts, CJK fonts, designer-tuned widths).  This module
// fixes that gap by walking the cmap + hmtx + kern tables of a real
// font file and producing pixel-perfect advances.
//
// Mirrors web-pptx's `@aurochs/glyph/src/measure/measurer.ts` Canvas
// path (which calls `ctx.measureText(text)` for real measurement);
// we cannot use Canvas in a non-browser MoonBit target, but TTF
// metrics are equivalent for glyph-level advance computation.

///|
/// Wraps a parsed TTFont so callers don't have to recompute
/// `units_per_em` on every measurement.
pub struct FontMeasurer {
  ttfont : @font.TTFont
  /// `units_per_em` from the head table.  All advance/bearing values
  /// in the font are in this unit; we divide by `units_per_em` to
  /// reach em-space.
  units_per_em : Int
}

///|
/// Parse `bytes` (TTF/OTF/TTC payload) into a `FontMeasurer`.  Returns
/// `None` if the data is not a recognised font format.  Mirrors the
/// `parse_font` entry point in `mizchi/font/src/parser.mbt`.
pub fn make_font_measurer(bytes : Bytes) -> FontMeasurer? {
  match @font.parse_font(bytes) {
    None => None
    Some(tt) => Some({ ttfont: tt, units_per_em: tt.units_per_em })
  }
}

///|
/// Resolve a Unicode code point to the font's glyph id, or 0 (the
/// `.notdef` glyph) when the cmap has no entry.  Mirrors
/// `TTFont::glyph_index` in `mizchi/font/src/parser.mbt:224`.
pub fn FontMeasurer::glyph_index(self : FontMeasurer, codepoint : Int) -> Int {
  self.ttfont.glyph_index(codepoint)
}

///|
/// Real advance width of `char` at `font_size_pt`.  Computed as
/// `advance_units * font_size_px / units_per_em`.
///
/// `font_size_pt` is in points; the result is in pixels at 96 DPI.
pub fn FontMeasurer::char_advance(
  self : FontMeasurer,
  char : Char,
  font_size_pt~ : Double,
) -> Double {
  let glyph_id = self.ttfont.glyph_index(char.to_int())
  let metrics = self.ttfont.glyph_metrics(glyph_id)
  let font_size_px = font_size_pt * pt_to_px
  let scale = font_size_px / self.units_per_em.to_double()
  metrics.advance_width.to_double() * scale
}

///|
/// Real kerning adjustment for the pair `(prev, char)`, expressed in
/// pixels at `font_size_pt`.  Returns 0.0 when the font has no kern
/// table entry for the pair.
pub fn FontMeasurer::kerning_adjust(
  self : FontMeasurer,
  prev : Char,
  char : Char,
  font_size_pt~ : Double,
) -> Double {
  let lhs = self.ttfont.glyph_index(prev.to_int())
  let rhs = self.ttfont.glyph_index(char.to_int())
  // mizchi/font stores kern entries keyed by (lhs << 16) | rhs.
  let key = lhs * 65536 + rhs
  match self.ttfont.kern_pairs.get(key) {
    None => 0.0
    Some(adjust) => {
      let font_size_px = font_size_pt * pt_to_px
      let scale = font_size_px / self.units_per_em.to_double()
      adjust.to_double() * scale
    }
  }
}

///|
/// Real text width for an entire string.  Sums per-character
/// `char_advance` with kern adjustments between adjacent characters.
/// `letter_spacing_px` adds extra spacing between every adjacent pair
/// (not after the last character), matching the TS reference's
/// `index > 0 ? letterSpacingPx : 0` convention.
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
/// Real ascender ratio.  `ascent / units_per_em` — the fraction of
/// the font size that the baseline sits below the top of the line.
/// This replaces the hard-coded table in `font_metrics.mbt` when a
/// real font is available.
pub fn FontMeasurer::ascender_ratio(self : FontMeasurer) -> Double {
  if self.units_per_em == 0 {
    return 0.8
  }
  self.ttfont.ascent.to_double() / self.units_per_em.to_double()
}

///|
/// Real descender ratio (positive value, even though `descent` is
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
/// Real line-gap ratio (additional leading recommended by the font).
pub fn FontMeasurer::line_gap_ratio(self : FontMeasurer) -> Double {
  if self.units_per_em == 0 {
    return 0.0
  }
  self.ttfont.line_gap.to_double() / self.units_per_em.to_double()
}
