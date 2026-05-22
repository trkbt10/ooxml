// @source web-pptx packages/@aurochs/glyph/src/measure/measurer.ts
//
// Pure-statistics text-width estimation.  The browser version uses a
// Canvas to call `ctx.measureText(text)`; in a non-browser context
// (server, MoonBit native, MoonBit wasm-gc) it falls back to the same
// algorithm as `estimateTextWidthFallback` in `measurer.ts:243`.  We
// implement only the fallback — equivalent to wasm-side execution.

///|
/// Points-to-pixels conversion factor used throughout web-pptx.
/// 96 DPI / 72 pt-per-inch = 1.333… Mirrors `PT_TO_PX` in
/// `measure/units.ts`.
pub let pt_to_px : Double = 96.0 / 72.0

///|
/// Pixels-to-points conversion factor.
pub let px_to_pt : Double = 72.0 / 96.0

///|
/// Convert points to pixels at 96 DPI.
pub fn points_to_pixels(points : Double) -> Double {
  points * pt_to_px
}

///|
/// Convert pixels to points at 96 DPI.
pub fn pixels_to_points(pixels : Double) -> Double {
  pixels * px_to_pt
}

///|
/// Result of calculating one character's width with kerning context.
/// All fields are in pixels.  Mirrors `CharWidthResult` in
/// `measurer.ts:128`.
pub struct CharWidthResult {
  /// Character width in pixels (font_size_px × em-ratio).
  width : Double
  /// Kerning adjustment from the previous character in pixels.
  /// Negative = tighter than default spacing.
  kerning_adjust : Double
  /// `width + kerning_adjust`.  Pre-computed for convenience.
  total_width : Double
}

///|
/// Kerning adjustment resolver.  Mirrors `resolveKerningAdjust` in
/// `measurer.ts:176`.  Returns 0 when there is no previous character
/// (start of string) or the font is monospaced.
fn resolve_kerning_adjust(
  prev_char : Char?,
  char : Char,
  font_size_px : Double,
  font_family : String?,
) -> Double {
  match prev_char {
    None => 0.0
    Some(p) => {
      if is_monospace(font_family) {
        return 0.0
      }
      let buf = StringBuilder::new()
      buf.write_char(p)
      buf.write_char(char)
      let kerning_em = get_kerning_adjustment(buf.to_string(), font_family)
      font_size_px * kerning_em
    }
  }
}

///|
/// Calculate the width of a single character with kerning context.
/// Mirrors `calculateCharWidth` in `measurer.ts:147`.
///
/// - `font_size_pt`: font size in points.
/// - `font_family`: family name (`None` falls back to sans-serif).
/// - `font_weight`: 400 (regular) / 700 (bold) trigger thresholds.
pub fn calculate_char_width(
  char : Char,
  prev_char? : Char? = None,
  font_size_pt~ : Double,
  font_family~ : String?,
  font_weight? : Int = 400,
) -> CharWidthResult {
  let font_size_px = font_size_pt * pt_to_px
  let is_cjk = is_cjk_char(char)
  let width_ratio = get_char_width(char, font_family, is_cjk, font_weight~)
  let width = font_size_px * width_ratio
  let kerning_adjust = resolve_kerning_adjust(
    prev_char, char, font_size_px, font_family,
  )
  { width, kerning_adjust, total_width: width + kerning_adjust }
}

///|
/// Estimate text width using only statistical font metrics.
/// Mirrors `estimateTextWidthFallback` in `measurer.ts:243`.
///
/// - `letter_spacing_px`: extra letter-spacing applied *between*
///   adjacent characters (not after the last one), matching the TS
///   behaviour `index > 0 ? letterSpacingPx : 0`.
pub fn estimate_text_width_fallback(
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px~ : Double,
  font_family~ : String?,
  font_weight? : Int = 400,
) -> Double {
  let chars : Array[Char] = []
  for c in text {
    chars.push(c)
  }
  let n = chars.length()
  let acc : Ref[Double] = { val: 0.0 }
  for i in 0..<n {
    let prev = if i == 0 { None } else { Some(chars[i - 1]) }
    let r = calculate_char_width(
      chars[i],
      prev_char=prev,
      font_size_pt~,
      font_family~,
      font_weight~,
    )
    let spacing = if i > 0 { letter_spacing_px } else { 0.0 }
    acc.val = acc.val + r.total_width + spacing
  }
  acc.val
}

///|
/// Public text-width measurement.  When `measurer` is `Some`, walks
/// the real TTF cmap/hmtx/kern tables for pixel-perfect advances.
/// When `None`, falls back to the statistical em-ratio tables.
///
/// This mirrors the dual code path in web-pptx's
/// `measureTextWidth` (`measurer.ts:211`), which calls Canvas
/// `measureText` when available and falls back to statistical
/// estimation otherwise.  The MoonBit port replaces Canvas with the
/// `FontMeasurer` wrapper around `mizchi/font::TTFont`.
pub fn measure_text_width(
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px~ : Double,
  font_family~ : String?,
  font_weight? : Int = 400,
  measurer? : FontMeasurer? = None,
) -> Double {
  match measurer {
    Some(m) => m.measure_text(text, font_size_pt~, letter_spacing_px~)
    None =>
      estimate_text_width_fallback(
        text,
        font_size_pt~,
        letter_spacing_px~,
        font_family~,
        font_weight~,
      )
  }
}

///|
/// Per-character measurement bundle used for precise tspan placement.
/// Mirrors `DetailedMeasurement` in `measurer.ts:271`.
pub struct DetailedMeasurement {
  /// Total width of the laid-out span in pixels.
  total_width : Double
  /// One `CharWidthResult` per character (in input order).
  char_widths : Array[CharWidthResult]
  /// Cumulative x-offset for each character (positions[i] is the x
  /// at which char i begins).
  positions : Array[Double]
}

///|
/// Detailed per-character measurement.  Mirrors `measureTextDetailed`
/// in `measurer.ts:291`.
pub fn measure_text_detailed(
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px~ : Double,
  font_family~ : String?,
  font_weight? : Int = 400,
) -> DetailedMeasurement {
  let chars : Array[Char] = []
  for c in text {
    chars.push(c)
  }
  let n = chars.length()
  let positions : Array[Double] = []
  let widths : Array[CharWidthResult] = []
  let acc : Ref[Double] = { val: 0.0 }
  for i in 0..<n {
    let prev = if i == 0 { None } else { Some(chars[i - 1]) }
    let r = calculate_char_width(
      chars[i],
      prev_char=prev,
      font_size_pt~,
      font_family~,
      font_weight~,
    )
    let spacing = if i > 0 {
      letter_spacing_px_px(letter_spacing_px, i)
    } else {
      0.0
    }
    positions.push(acc.val)
    widths.push(r)
    acc.val = acc.val + r.total_width + spacing
  }
  { total_width: acc.val, char_widths: widths, positions }
}

///|
/// Helper that wraps the `index > 0 ? letterSpacingPx : 0` ternary
/// from `measurer.ts:305` so the call site reads linearly.
fn letter_spacing_px_px(letter_spacing_px : Double, index : Int) -> Double {
  if index > 0 {
    letter_spacing_px
  } else {
    0.0
  }
}
