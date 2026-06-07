// §21.2.2.20 / §21.2.2.21 CT_BubbleChart — bubble charts use two
// value axes. The horizontal axis must therefore follow the value-axis
// deletion state rather than the missing category-axis state.

///|
fn bcx_elem(
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
fn bcx_node(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(bcx_elem(tag, attrs, kids))
}

///|
fn bcx_numlit(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for v in vals {
    pts.push(bcx_node("pt", [], [bcx_node("v", [], [@xml.Node::Text(v)])]))
  }
  bcx_node("numLit", [], pts)
}

///|
fn bcx_bubble() -> @xml.Element {
  let ser = bcx_node("ser", [], [
    bcx_node("xVal", [], [bcx_numlit(["1", "2", "3"])]),
    bcx_node("yVal", [], [bcx_numlit(["10", "20", "30"])]),
    bcx_node("bubbleSize", [], [bcx_numlit(["3", "6", "9"])]),
  ])
  bcx_elem("bubbleChart", [], [ser])
}

///|
fn bcx_style() -> ChartStyleDefaults {
  ChartStyleDefaults::{
    text_color: "#000000",
    font_family: "sans-serif",
    axis_color: "#333333",
    grid_color: "#cccccc",
  }
}

///|
fn bcx_render(plot_area : @xml.Element) -> String {
  bcx_render_chart(plot_area, bcx_bubble())
}

///|
fn bcx_render_chart(plot_area : @xml.Element, bubble : @xml.Element) -> String {
  let axes = collect_axes_info(plot_area)
  let nodes = render_bubble_chart(
    bubble,
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    bcx_style(),
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
fn bcx_count(haystack : String, needle : String) -> Int {
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
test "bubble chart renders X-axis ticks when value axes present" {
  let plot_area = bcx_elem("plotArea", [], [
    bcx_node("valAx", [], []),
    bcx_node("valAx", [], []),
  ])
  let svg = bcx_render(plot_area)
  assert_true(svg.contains("dominant-baseline=\"hanging\""))
}

///|
test "bubble chart suppresses X-axis ticks when value axis deleted" {
  let plot_area = bcx_elem("plotArea", [], [
    bcx_node("valAx", [], [bcx_node("delete", [("val", "1")], [])]),
  ])
  let svg = bcx_render(plot_area)
  assert_true(!svg.contains("dominant-baseline=\"hanging\""))
}

///|
test "bubble chart showNegBubbles=false suppresses negative bubble sizes" {
  let plot_area = bcx_elem("plotArea", [], [
    bcx_node("valAx", [], []),
    bcx_node("valAx", [], []),
  ])
  let ser = bcx_node("ser", [], [
    bcx_node("xVal", [], [bcx_numlit(["1", "2"])]),
    bcx_node("yVal", [], [bcx_numlit(["10", "20"])]),
    bcx_node("bubbleSize", [], [bcx_numlit(["-9", "9"])]),
  ])
  let bubble = bcx_elem("bubbleChart", [], [
    bcx_node("showNegBubbles", [("val", "0")], []),
    ser,
  ])
  let svg = bcx_render_chart(plot_area, bubble)
  assert_eq(bcx_count(svg, "<circle "), 1)
}

///|
test "bubble chart showNegBubbles=true renders negative bubble magnitude" {
  let plot_area = bcx_elem("plotArea", [], [
    bcx_node("valAx", [], []),
    bcx_node("valAx", [], []),
  ])
  let ser = bcx_node("ser", [], [
    bcx_node("xVal", [], [bcx_numlit(["1", "2"])]),
    bcx_node("yVal", [], [bcx_numlit(["10", "20"])]),
    bcx_node("bubbleSize", [], [bcx_numlit(["-9", "9"])]),
  ])
  let bubble = bcx_elem("bubbleChart", [], [
    bcx_node("showNegBubbles", [("val", "1")], []),
    ser,
  ])
  let svg = bcx_render_chart(plot_area, bubble)
  assert_eq(bcx_count(svg, "<circle "), 2)
}

///|
test "bubble chart renders every series, not only the first ser" {
  let plot_area = bcx_elem("plotArea", [], [
    bcx_node("valAx", [], []),
    bcx_node("valAx", [], []),
  ])
  let ser1 = bcx_node("ser", [], [
    bcx_node("xVal", [], [bcx_numlit(["1", "2"])]),
    bcx_node("yVal", [], [bcx_numlit(["10", "20"])]),
    bcx_node("bubbleSize", [], [bcx_numlit(["3", "6"])]),
  ])
  let ser2 = bcx_node("ser", [], [
    bcx_node("xVal", [], [bcx_numlit(["3", "4"])]),
    bcx_node("yVal", [], [bcx_numlit(["30", "40"])]),
    bcx_node("bubbleSize", [], [bcx_numlit(["9", "12"])]),
  ])
  let bubble = bcx_elem("bubbleChart", [], [ser1, ser2])
  let svg = bcx_render_chart(plot_area, bubble)
  assert_eq(bcx_count(svg, "<circle "), 4)
  assert_true(svg.contains("fill=\"#4472c4\""))
  assert_true(svg.contains("fill=\"#ed7d31\""))
}

///|
test "bubble chart data labels consume showBubbleSize" {
  let plot_area = bcx_elem("plotArea", [], [
    bcx_node("valAx", [], [bcx_node("axPos", [("val", "b")], [])]),
    bcx_node("valAx", [], [bcx_node("axPos", [("val", "l")], [])]),
  ])
  let ser = bcx_node("ser", [], [
    bcx_node("xVal", [], [bcx_numlit(["1", "2"])]),
    bcx_node("yVal", [], [bcx_numlit(["10", "20"])]),
    bcx_node("bubbleSize", [], [bcx_numlit(["7", "11"])]),
  ])
  let bubble = bcx_elem("bubbleChart", [], [
    ser,
    bcx_node("dLbls", [], [
      bcx_node("showBubbleSize", [("val", "1")], []),
      bcx_node("showVal", [("val", "0")], []),
    ]),
  ])
  let svg = bcx_render_chart(plot_area, bubble)
  assert_true(svg.contains(">7<"))
  assert_true(svg.contains(">11<"))
}
