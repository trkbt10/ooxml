// §21.2.2.176 CT_ScatterChart — the scatter chart's X axis is a value
// axis (two <c:valAx>, no <c:catAx>).  The renderer must emit X-axis
// ticks/labels gated on the value-axis deletion flag, not cat_deleted()
// (which is always true for a scatter chart and previously suppressed
// the X axis entirely).

///|
/// Build a `c:`-prefixed element.
fn scx_elem(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Element {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: Some("c"), local_name: k, ns: None }, value: v })
  }
  {
    name: { prefix: Some("c"), local_name: tag, ns: None },
    attributes: a,
    children: kids,
  }
}

///|
fn scx_node(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(scx_elem(tag, attrs, kids))
}

///|
/// A `<c:numLit>` cache from a list of point values.
fn scx_numlit(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for v in vals {
    pts.push(scx_node("pt", [], [scx_node("v", [], [@xml.Node::Text(v)])]))
  }
  scx_node("numLit", [], pts)
}

///|
/// A minimal scatter `<c:scatterChart>` with one XY series.
fn scx_scatter() -> @xml.Element {
  let ser = scx_node("ser", [], [
    scx_node("xVal", [], [scx_numlit(["1", "2", "3"])]),
    scx_node("yVal", [], [scx_numlit(["10", "20", "30"])]),
  ])
  scx_elem("scatterChart", [], [
    scx_node("scatterStyle", [("val", "lineMarker")], []),
    ser,
  ])
}

///|
fn scx_style() -> ChartStyleDefaults {
  ChartStyleDefaults::{
    text_color: "#000000",
    font_family: "sans-serif",
    axis_color: "#333333",
    grid_color: "#cccccc",
  }
}

///|
fn scx_render(plot_area : @xml.Element) -> String {
  let axes = collect_axes_info(plot_area)
  let nodes = render_scatter_chart(
    scx_scatter(),
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    scx_style(),
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  sb.to_string()
}

///|
test "scatter chart renders X-axis ticks when value axes present" {
  // Two non-deleted value axes → val_deleted() is false.
  let plot_area = scx_elem("plotArea", [], [
    scx_node("valAx", [], []),
    scx_node("valAx", [], []),
  ])
  let svg = scx_render(plot_area)
  // X-axis tick labels hang below the plot (dominant-baseline="hanging");
  // y-axis labels use "middle".  Presence proves the X axis rendered.
  assert_true(svg.contains("dominant-baseline=\"hanging\""))
}

///|
test "scatter chart suppresses X-axis ticks when value axis deleted" {
  // A deleted value axis → val_deleted() true → no axis ticks at all.
  let plot_area = scx_elem("plotArea", [], [
    scx_node("valAx", [], [scx_node("delete", [("val", "1")], [])]),
  ])
  let svg = scx_render(plot_area)
  assert_true(!svg.contains("dominant-baseline=\"hanging\""))
}
