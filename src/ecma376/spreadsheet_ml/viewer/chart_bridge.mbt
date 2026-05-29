// §21.2 DrawingML chart bridge.  Adapts SpreadsheetML's local theme
// map / part resolution onto the chart-renderer package
// (`drawing_ml/chart/viewer`).  The chart renderer owns the SVG
// geometry; this bridge only translates the SML-side inputs (the
// workbook theme, the worksheet-drawing's `r:id` table) into the
// shape the renderer's `@chart_viewer.render_chart_graphic_frame`
// expects.

///|
/// Build a `@paint.ColorResolveContext` from a SML-side theme map.
/// Maps the §18.8.3 SML slot ordering (lt1/dk1/lt2/dk2/accent1..6/
/// hlink/folHlink) onto the §20.1.4.1.6 DML scheme-color name keys
/// the chart renderer looks up via `@paint.get_scheme_color`.  When
/// the theme map is empty the context falls back to the renderer's
/// baked Office 2013+ palette automatically.
fn paint_ctx_from_sml_theme(
  theme_map : SmlThemeColorMap,
) -> @paint.ColorResolveContext {
  let scheme : Map[String, String] = Map([], capacity=0)
  let names = [
    "lt1", "dk1", "lt2", "dk2", "accent1", "accent2", "accent3", "accent4",
    "accent5", "accent6", "hlink", "folHlink",
  ]
  for i, name in names {
    match theme_map.lookup(i) {
      Some(hex) => scheme[name] = hex
      None => ()
    }
  }
  @paint.ColorResolveContext::empty().with_color_scheme(scheme)
}

///|
/// Render a `<xdr:graphicFrame>` carrying a §21.2 chart payload.
/// Returns `Some(node)` when the frame's `<a:graphicData>` URI
/// matches the chart namespace AND the `r:id` resolves through
/// `part_resolver`; `None` otherwise so the caller falls back to the
/// labelled placeholder.
fn render_drawing_chart(
  gf : @drawing.CT_GraphicalObjectFrame,
  bounds : DrawingBounds,
  theme_map : SmlThemeColorMap,
  part_resolver : (String) -> @xml.Element?,
) -> @xml.Node? {
  if !@chart_viewer.is_chart_graphic_frame(gf.element) {
    return None
  }
  let ctx = paint_ctx_from_sml_theme(theme_map)
  let defs = @paint.SvgDefsCollector::new()
  let nodes = @chart_viewer.render_chart_graphic_frame(
    gf.element,
    bounds.width,
    bounds.height,
    ctx,
    defs,
    part_resolver,
  )
  if nodes.length() == 0 {
    return None
  }
  // The chart renderer emits geometry in coordinates local to the
  // graphic-frame's `(0, 0)` corner.  The caller wraps the result in
  // a translate group that places `(0, 0)` at `bounds.x`/`bounds.y`,
  // so we return a single `<g>` carrying the renderer's payload
  // unchanged.
  Some(svg_elem("g", [svg_attr("class", "chart")], nodes))
}
