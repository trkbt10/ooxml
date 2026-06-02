// Text-width measurement helpers built on `@glyph.measure_text_width`.
// All widths come back in pixels at 96 DPI.

///|
/// Measure a single `LayoutSpan`. Line-break spans always have
/// width 0. Raises `@glyph.FontUnresolvedError` when the font
/// resolver cannot satisfy the span's family.
pub fn measure_span(
  span : LayoutSpan,
) -> MeasuredSpan raise @glyph.FontUnresolvedError {
  if span.is_break {
    return { span, width: 0.0 }
  }
  let w = @glyph.measure_text_width(
    span.text,
    font_size_pt=span.font_size,
    letter_spacing_px=span.letter_spacing,
    family=span.font_family,
    weight=span.font_weight,
  )
  { span, width: w }
}

///|
/// Measure every span in an array.
pub fn measure_spans(
  spans : Array[LayoutSpan],
) -> Array[MeasuredSpan] raise @glyph.FontUnresolvedError {
  let result : Array[MeasuredSpan] = []
  for s in spans {
    result.push(measure_span(s))
  }
  result
}

///|
/// Estimate the width of a bullet character. Per §21.1.2.2.7 the
/// spacing between bullet and text is governed by `indent`, not by
/// padding the bullet's own width.
pub fn estimate_bullet_width(
  bullet_char : String,
  font_size : Double,
  font_family : String,
) -> Double raise @glyph.FontUnresolvedError {
  @glyph.measure_text_width(
    bullet_char,
    font_size_pt=font_size,
    letter_spacing_px=0.0,
    family=font_family,
  )
}
