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
  scx_render_chart(plot_area, scx_scatter())
}

///|
fn scx_render_chart(plot_area : @xml.Element, scatter : @xml.Element) -> String {
  let axes = collect_axes_info(plot_area)
  let nodes = render_scatter_chart(
    scatter,
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    scx_style(),
    SvgDefsCollector::new(),
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
fn scx_count(haystack : String, needle : String) -> Int {
  let mut count = 0
  let mut i = 0
  while i + needle.length() <= haystack.length() {
    if haystack[i:i + needle.length()].to_owned() == needle {
      count = count + 1
      i = i + needle.length()
    } else {
      i = i + 1
    }
  }
  count
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

///|
test "scatter chart renders every series, not only the first ser" {
  let plot_area = scx_elem("plotArea", [], [
    scx_node("valAx", [], []),
    scx_node("valAx", [], []),
  ])
  let ser1 = scx_node("ser", [], [
    scx_node("xVal", [], [scx_numlit(["1", "2"])]),
    scx_node("yVal", [], [scx_numlit(["10", "20"])]),
  ])
  let ser2 = scx_node("ser", [], [
    scx_node("xVal", [], [scx_numlit(["3", "4"])]),
    scx_node("yVal", [], [scx_numlit(["30", "40"])]),
  ])
  let scatter = scx_elem("scatterChart", [], [
    scx_node("scatterStyle", [("val", "marker")], []),
    ser1,
    ser2,
  ])
  let svg = scx_render_chart(plot_area, scatter)
  assert_eq(scx_count(svg, "<circle "), 4)
  assert_true(svg.contains("fill=\"#4472c4\""))
  assert_true(svg.contains("fill=\"#ed7d31\""))
}
