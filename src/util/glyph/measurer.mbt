// Public text-measurement API.
//
// Every entrypoint here resolves through `default_font_set()` and a
// concrete `FontMeasurer` (real TTF, real `hmtx`). The previous
// statistical em-ratio path is gone — see `font_registry.mbt` for
// the rationale.
//
// External callers go through:
//
//   - `pt_to_px` / `px_to_pt`           — unit conversion constants
//   - `measure_text_width(...)`         — total advance for a string
//   - `estimate_text_width_fallback(.)` — same, kept under the old
//                                          name so renderer callsites
//                                          don't need a global
//                                          rename. The body is no
//                                          longer "fallback" — it
//                                          calls the real measurer
//                                          like every other path.
//   - `calculate_char_width(...)`       — per-character bundle with
//                                          kerning context
//   - `measure_text_detailed(...)`      — per-character cumulative
//                                          x-offsets for tspan
//                                          placement

///|
/// Points-to-pixels conversion factor used throughout the codebase.
/// 96 DPI / 72 pt-per-inch = 1.333…
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
/// All fields are in pixels.
pub struct CharWidthResult {
  /// Character width in pixels (real `hmtx` advance × font_size_px /
  /// units_per_em).
  width : Double
  /// Kerning adjustment from the previous character in pixels.
  /// Negative = tighter than default spacing.
  kerning_adjust : Double
  /// `width + kerning_adjust`. Pre-computed for convenience.
  total_width : Double
}

///|
/// Per-character measurement bundle used for precise tspan placement.
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
/// Resolve the measurer for `(family, weight)` — prefer an
/// explicitly-supplied one (e.g. a PPTX caller that pre-loaded a
/// specific TTF) but otherwise consult the default registry.
fn pick_measurer(
  measurer : FontMeasurer?,
  family : String?,
  weight : Int,
) -> FontMeasurer {
  match measurer {
    Some(m) => m
    None => default_font_set().measurer_for(family, weight)
  }
}

///|
/// Calculate the width of a single character with kerning context.
///
/// - `font_size_pt`: font size in points.
/// - `font_family`: family name (`None` resolves to the default
///   sans-serif face for the platform — see `font_registry.mbt`).
/// - `font_weight`: 400 (regular) / 700 (bold) — selects the bold
///   cut from the registry when ≥ 700.
pub fn calculate_char_width(
  char : Char,
  prev_char? : Char? = None,
  font_size_pt~ : Double,
  font_family~ : String?,
  font_weight? : Int = 400,
) -> CharWidthResult {
  let m = pick_measurer(None, font_family, font_weight)
  let width = m.char_advance(char, font_size_pt~)
  let kerning_adjust = match prev_char {
    None => 0.0
    Some(p) => m.kerning_adjust(p, char, font_size_pt~)
  }
  { width, kerning_adjust, total_width: width + kerning_adjust }
}

///|
/// Total text width for `text` using real-font advances.
///
/// `letter_spacing_px` adds extra spacing between every adjacent
/// pair (not after the last character), matching the historical
/// `index > 0 ? letterSpacingPx : 0` convention.
///
/// Despite the historical name, this is no longer a "fallback" —
/// it always walks the real TTF (`hmtx` + kern table). The name is
/// preserved because every renderer call-site reads it.
pub fn estimate_text_width_fallback(
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px~ : Double,
  font_family~ : String?,
  font_weight? : Int = 400,
) -> Double {
  let m = pick_measurer(None, font_family, font_weight)
  m.measure_text(text, font_size_pt~, letter_spacing_px~)
}

///|
/// Public text-width measurement. When `measurer` is `Some`, uses
/// that pre-loaded TTF directly; otherwise the family / weight are
/// looked up in the default registry.
///
/// All paths read the real `hmtx` table — no statistical
/// approximation remains.
pub fn measure_text_width(
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px~ : Double,
  font_family~ : String?,
  font_weight? : Int = 400,
  measurer? : FontMeasurer? = None,
) -> Double {
  let m = pick_measurer(measurer, font_family, font_weight)
  m.measure_text(text, font_size_pt~, letter_spacing_px~)
}

///|
/// Detailed per-character measurement (positions + per-glyph widths
/// with kerning context).
pub fn measure_text_detailed(
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px~ : Double,
  font_family~ : String?,
  font_weight? : Int = 400,
) -> DetailedMeasurement {
  let m = pick_measurer(None, font_family, font_weight)
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
    let advance = m.char_advance(chars[i], font_size_pt~)
    let kerning_adjust = match prev {
      None => 0.0
      Some(p) => m.kerning_adjust(p, chars[i], font_size_pt~)
    }
    let total = advance + kerning_adjust
    let r : CharWidthResult = {
      width: advance,
      kerning_adjust,
      total_width: total,
    }
    positions.push(acc.val)
    widths.push(r)
    let spacing = if i > 0 { letter_spacing_px } else { 0.0 }
    acc.val = acc.val + total + spacing
  }
  { total_width: acc.val, char_widths: widths, positions }
}

///|
/// Ascender ratio for `font_family` — the fraction of the font size
/// from the baseline to the top of the line box. Read from the
/// font's `hhea` (or OS/2) table via the registry; no hardcoded
/// table.
///
/// For weight selection we always pick the regular cut: ascender /
/// descender are typically identical between Regular and Bold for a
/// given family, so caching one face is enough.
pub fn get_ascender_ratio(font_family : String?) -> Double {
  let m = default_font_set().measurer_for(font_family, 400)
  m.ascender_ratio()
}

///|
/// Descender ratio (positive value).
pub fn get_descender_ratio(font_family : String?) -> Double {
  let m = default_font_set().measurer_for(font_family, 400)
  m.descender_ratio()
}

///|
/// Line-gap ratio (additional leading recommended by the font's
/// `hhea` line_gap).
pub fn get_line_gap_ratio(font_family : String?) -> Double {
  let m = default_font_set().measurer_for(font_family, 400)
  m.line_gap_ratio()
}
