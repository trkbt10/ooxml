// @source web-pptx packages/@aurochs-renderer/pptx/src/text-layout/measurer.ts
//
// Text-width measurement.  Delegates to `@glyph` for both real TTF
// measurement (when a `FontMeasurer` is supplied) and statistical
// fallback (when no font file is available).  All widths come back
// in pixels.

///|
/// Measure a single `LayoutSpan`.  Mirrors `measureSpan` in
/// `text-layout/measurer.ts:119`.  Line-break spans always have width
/// 0.  When `measurer` is `Some`, walks the real TTF cmap/hmtx for
/// pixel-perfect advances; otherwise falls back to statistical
/// em-ratio tables.
pub fn measure_span(
  span : LayoutSpan,
  measurer? : @glyph.FontMeasurer? = None,
) -> MeasuredSpan {
  if span.is_break {
    return { span, width: 0.0 }
  }
  let w = @glyph.measure_text_width(
    span.text,
    font_size_pt=span.font_size,
    letter_spacing_px=span.letter_spacing,
    font_family=Some(span.font_family),
    font_weight=span.font_weight,
    measurer~,
  )
  { span, width: w }
}

///|
/// Measure every span in an array.  Mirrors `measureSpans` in
/// `text-layout/measurer.ts:164`.  Threads the same `measurer` to
/// every span so the whole paragraph uses one TTF instance.
pub fn measure_spans(
  spans : Array[LayoutSpan],
  measurer? : @glyph.FontMeasurer? = None,
) -> Array[MeasuredSpan] {
  let result : Array[MeasuredSpan] = []
  for s in spans {
    result.push(measure_span(s, measurer~))
  }
  result
}

///|
/// Estimate the width of a bullet character.  Mirrors
/// `estimateBulletWidth` in `text-layout/measurer.ts:178`.
///
/// Per §21.1.2.2.7 the spacing between bullet and text is governed by
/// `indent`, not by adding extra space to the bullet's own width.
pub fn estimate_bullet_width(
  bullet_char : String,
  font_size : Double,
  font_family : String,
  measurer? : @glyph.FontMeasurer? = None,
) -> Double {
  @glyph.measure_text_width(
    bullet_char,
    font_size_pt=font_size,
    letter_spacing_px=0.0,
    font_family=Some(font_family),
    measurer~,
  )
}
