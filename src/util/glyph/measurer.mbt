// Public text-measurement API.
//
// Every entry point goes through `default_font_set()` and a
// `FontMeasurer` parsed from real TTF bytes returned by the
// `FontResolver`. There is one canonical request shape
// (`FontFaceRequest`) and one canonical method
// (`FontSet::measurer_for_request`); legacy `(family?, weight)`
// overloads have been removed in favour of explicit request
// construction by the caller.
//
// Failure mode: when no driver can satisfy a request the call
// raises `FontUnresolvedError`. Callers either:
//   - retry with a different stack (the ECMA-376 substitution chain
//     in `font_substitution_chain.mbt` does this), or
//   - propagate the error so the document-producer sees that the
//     requested font is missing and ships embeddedFont / altName.
//
// The renderer must NOT silently fall back to statistical metrics.

///|
/// Points-to-pixels conversion factor. 96 DPI / 72 pt-per-inch.
pub let pt_to_px : Double = 96.0 / 72.0

///|
/// Pixels-to-points conversion factor.
pub let px_to_pt : Double = 72.0 / 96.0

///|
pub fn points_to_pixels(points : Double) -> Double {
  points * pt_to_px
}

///|
pub fn pixels_to_points(pixels : Double) -> Double {
  pixels * px_to_pt
}

///|
/// Per-character measurement bundle: real `hmtx` advance plus the
/// kerning adjustment contributed by the previous character.
pub struct CharWidthResult {
  width : Double
  kerning_adjust : Double
  total_width : Double
}

///|
/// Per-character measurement of a whole string, used for precise
/// tspan placement (positions[i] is the x at which char i begins).
pub struct DetailedMeasurement {
  total_width : Double
  char_widths : Array[CharWidthResult]
  positions : Array[Double]
}

///|
/// Build a single-name request and resolve it through the default
/// font set. Raises `FontUnresolvedError` on miss.
fn resolve_measurer(
  family : String,
  weight : Int,
  italic : Bool,
) -> FontMeasurer raise FontUnresolvedError {
  default_font_set().measurer_for_request(
    FontFaceRequest::of_name(family, weight~, italic~),
  )
}

///|
/// Total text width for `text` measured against `family` at the
/// given weight / italic. Raises `FontUnresolvedError` when the
/// host has no copy of the requested family — callers that want a
/// retry through the ECMA-376 chain wrap the call in `try?`.
pub fn measure_text_width(
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px~ : Double,
  family~ : String,
  weight~ : Int = 400,
  italic~ : Bool = false,
) -> Double raise FontUnresolvedError {
  let m = resolve_measurer(family, weight, italic)
  m.measure_text(text, font_size_pt~, letter_spacing_px~)
}

///|
/// Single-character width with kerning context (the previous
/// character contributes the kern adjustment).
pub fn calculate_char_width(
  char : Char,
  prev_char~ : Char? = None,
  font_size_pt~ : Double,
  family~ : String,
  weight~ : Int = 400,
  italic~ : Bool = false,
) -> CharWidthResult raise FontUnresolvedError {
  let m = resolve_measurer(family, weight, italic)
  let width = m.char_advance(char, font_size_pt~)
  let kerning_adjust = match prev_char {
    None => 0.0
    Some(p) => m.kerning_adjust(p, char, font_size_pt~)
  }
  { width, kerning_adjust, total_width: width + kerning_adjust }
}

///|
/// Per-character cumulative measurement: positions + per-glyph
/// widths with kerning context.
pub fn measure_text_detailed(
  text : String,
  font_size_pt~ : Double,
  letter_spacing_px~ : Double,
  family~ : String,
  weight~ : Int = 400,
  italic~ : Bool = false,
) -> DetailedMeasurement raise FontUnresolvedError {
  let m = resolve_measurer(family, weight, italic)
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
/// Ascender ratio for `family`. Reads `ascent / units_per_em` from
/// the font's `hhea` table. Raises `FontUnresolvedError` when the
/// family is missing.
pub fn get_ascender_ratio(
  family : String,
  weight~ : Int = 400,
  italic~ : Bool = false,
) -> Double raise FontUnresolvedError {
  resolve_measurer(family, weight, italic).ascender_ratio()
}

///|
/// Descender ratio (positive value, even though `descent` is
/// negative in TrueType conventions).
pub fn get_descender_ratio(
  family : String,
  weight~ : Int = 400,
  italic~ : Bool = false,
) -> Double raise FontUnresolvedError {
  resolve_measurer(family, weight, italic).descender_ratio()
}

///|
/// Line-gap ratio (additional leading recommended by the font's
/// `hhea` `lineGap`).
pub fn get_line_gap_ratio(
  family : String,
  weight~ : Int = 400,
  italic~ : Bool = false,
) -> Double raise FontUnresolvedError {
  resolve_measurer(family, weight, italic).line_gap_ratio()
}
