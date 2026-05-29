// §21.2 — Inline DrawingML chart renderer for the WML viewer.
//
// `<w:drawing>/<wp:inline|wp:anchor>/<a:graphic>/<a:graphicData
//   uri=".../chart">/<c:chart r:id="rIdN"/>` — when this URI is
// present the actual chart geometry lives in
// `word/charts/chartN.xml` (resolved through the document part's
// relationships).  This module is the WML-side bridge into the
// shared chart renderer (`drawing_ml/chart/viewer`): it locates the
// chart-bearing `<a:graphicFrame>` underneath the inline / anchor
// wrapper, asks the supplied `chart_resolver` closure to materialise
// the chart's SVG geometry, and lifts the result into a
// `MathPayload` so the line emitter places it on the baseline
// alongside surrounding glyphs.

///|
/// `<a:graphicData @uri>` token identifying a DrawingML chart
/// payload (§21.2).  Used to discriminate chart drawings from
/// picture / shape / VML / diagram drawings in `emit_drawing_span`.
const CHART_GRAPHIC_DATA_URI : String = "http://schemas.openxmlformats.org/drawingml/2006/chart"

///|
/// Synthesise a `<wp:inline>`-style `<a:graphicFrame>` element from a
/// `<w:drawing>` so the chart renderer's frame-walker sees the same
/// `<a:graphic>/<a:graphicData>/<c:chart>` payload it expects from a
/// presentation slide.  The chart renderer reads the URI off
/// `<a:graphicData>` (already present here) and the `r:id` off
/// `<c:chart>` (already present here), so the synthetic frame is a
/// thin wrapper preserving the same children.
fn drawing_chart_frame(drawing : @xml.Element) -> @xml.Element? {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "graphic") {
            Some(g) =>
              match first_child_named(g, "graphicData") {
                Some(gd) => {
                  let uri = match attr_value(gd, "uri") {
                    Some(v) => v
                    None => ""
                  }
                  if uri == CHART_GRAPHIC_DATA_URI {
                    return Some(c)
                  }
                }
                None => ()
              }
            None => ()
          }
        }
      _ => ()
    }
  }
  None
}

///|
/// Attempt to build a rendered chart payload for a `<w:drawing>` whose
/// `<a:graphicData>` URI matches the §21.2 chart namespace.  The
/// supplied `chart_resolver` closure captures the document-scoped
/// theme + chart-part lookups; this helper only forwards the matched
/// inline / anchor wrapper to it and wraps the resulting SVG node in
/// a `MathPayload` shifted up by `h_px` so its bottom edge lands on
/// the line baseline (matching Word's anchor behaviour).
///
/// Returns `None` when the drawing carries no chart URI, when the
/// extent is degenerate, or when the resolver returns `None` (no
/// chart part wired through the document's relationships).
fn build_inline_chart(
  drawing : @xml.Element,
  chart_resolver : (@xml.Element) -> @xml.Node?,
) -> MathPayload? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let frame = match drawing_chart_frame(drawing) {
    Some(f) => f
    None => return None
  }
  let chart_node = match chart_resolver(frame) {
    Some(n) => n
    None => return None
  }
  // The chart renderer emits geometry with `(0, 0)` at the
  // graphic-frame's top-left.  Shift the group up by `h_px` so its
  // bottom edge lands on the line baseline — the math-payload slot
  // the line emitter already understands.
  let group : @xml.Element = {
    name: @markup.qname_ns("g", @markup.svg_ns),
    attributes: [
      @markup.attr("transform", "translate(0," + fmt_double(-h_px) + ")"),
    ],
    children: [chart_node],
  }
  Some({ group, width_px: w_px, ascent_px: h_px, descent_px: 0.0 })
}
