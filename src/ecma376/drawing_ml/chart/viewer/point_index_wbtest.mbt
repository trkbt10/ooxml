// §21.2 chart cache points — c:pt/@idx is the point identity.

///|
fn pi_c(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Element {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: None, local_name: k, ns: None }, value: v })
  }
  {
    name: { prefix: Some("c"), local_name: tag, ns: None },
    attributes: a,
    children: kids,
  }
}

///|
fn pi_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(pi_c(tag, attrs, kids))
}

///|
test "§21.2.2.150 numCache projects sparse points by idx" {
  let cache = pi_c("numCache", [], [
    pi_cn("ptCount", [("val", "3")], []),
    pi_cn("pt", [("idx", "2")], [pi_cn("v", [], [@xml.Node::Text("30")])]),
  ])
  let values = collect_pt_values(cache)
  assert_eq(values.length(), 3)
  assert_eq(values[0], "")
  assert_eq(values[1], "")
  assert_eq(values[2], "30")
}

///|
test "§21.2.2.151 strCache projects sparse labels by idx" {
  let cache = pi_c("strCache", [], [
    pi_cn("ptCount", [("val", "2")], []),
    pi_cn("pt", [("idx", "1")], [pi_cn("v", [], [@xml.Node::Text("West")])]),
  ])
  let values = collect_pt_values(cache)
  assert_eq(values.length(), 2)
  assert_eq(values[0], "")
  assert_eq(values[1], "West")
}

///|
test "§21.2.2.46 dispBlanksAs schema default is zero" {
  let chart = pi_c("chart", [], [])
  assert_eq(chart_disp_blanks_as(chart).to_string(), "zero")
  let span = pi_c("chart", [], [pi_cn("dispBlanksAs", [("val", "span")], [])])
  assert_eq(chart_disp_blanks_as(span).to_string(), "span")
  let bad = pi_c("chart", [], [pi_cn("dispBlanksAs", [("val", "bogus")], [])])
  assert_eq(chart_disp_blanks_as(bad).to_string(), "zero")
}

///|
fn pi_sparse_val() -> @xml.Node {
  pi_cn("val", [], [
    pi_cn("numLit", [], [
      pi_cn("ptCount", [("val", "3")], []),
      pi_cn("pt", [("idx", "0")], [pi_cn("v", [], [@xml.Node::Text("10")])]),
      pi_cn("pt", [("idx", "2")], [pi_cn("v", [], [@xml.Node::Text("30")])]),
    ]),
  ])
}

///|
fn pi_sparse_axis(name : String) -> @xml.Node {
  pi_cn(name, [], [
    pi_cn("numLit", [], [
      pi_cn("ptCount", [("val", "3")], []),
      pi_cn("pt", [("idx", "0")], [pi_cn("v", [], [@xml.Node::Text("10")])]),
      pi_cn("pt", [("idx", "2")], [pi_cn("v", [], [@xml.Node::Text("30")])]),
    ]),
  ])
}

///|
fn pi_chart_space(chart_kind : String, disp : String?) -> @xml.Element {
  let chart_kids : Array[@xml.Node] = []
  match disp {
    Some(v) => chart_kids.push(pi_cn("dispBlanksAs", [("val", v)], []))
    None => ()
  }
  chart_kids.push(
    pi_cn("plotArea", [], [
      pi_cn(chart_kind, [], [pi_cn("ser", [], [pi_sparse_val()])]),
    ]),
  )
  pi_c("chartSpace", [], [pi_cn("chart", [], chart_kids)])
}

///|
fn pi_xy_chart_space(chart_kind : String, disp : String?) -> @xml.Element {
  let chart_kids : Array[@xml.Node] = []
  match disp {
    Some(v) => chart_kids.push(pi_cn("dispBlanksAs", [("val", v)], []))
    None => ()
  }
  let chart_children : Array[@xml.Node] = []
  if chart_kind == "scatterChart" {
    chart_children.push(pi_cn("scatterStyle", [("val", "lineMarker")], []))
  }
  chart_children.push(
    pi_cn("ser", [], [
      pi_sparse_axis("xVal"),
      pi_sparse_axis("yVal"),
      pi_sparse_axis("bubbleSize"),
    ]),
  )
  chart_kids.push(
    pi_cn("plotArea", [], [pi_cn(chart_kind, [], chart_children)]),
  )
  pi_c("chartSpace", [], [pi_cn("chart", [], chart_kids)])
}

///|
fn pi_render(chart_kind : String, disp : String?) -> String {
  let node = render_chart_space(
    pi_chart_space(chart_kind, disp),
    (0.0, 0.0, 400.0, 300.0),
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
fn pi_xy_render(chart_kind : String, disp : String?) -> String {
  let node = render_chart_space(
    pi_xy_chart_space(chart_kind, disp),
    (0.0, 0.0, 400.0, 300.0),
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
fn pi_count(haystack : String, needle : String) -> Int {
  if needle.length() == 0 {
    return 0
  }
  let mut count = 0
  let mut i = 0
  while i + needle.length() <= haystack.length() {
    if haystack[i:i + needle.length()] == needle {
      count = count + 1
      i = i + needle.length()
    } else {
      i = i + 1
    }
  }
  count
}

///|
test "§21.2.2.46 line chart absent dispBlanksAs plots sparse blank as zero" {
  let svg = pi_render("lineChart", None)
  assert_eq(pi_count(svg, "<polyline"), 1)
  assert_eq(pi_count(svg, "<circle"), 3)
}

///|
test "§21.2.2.46 line chart gap breaks sparse blank point" {
  let svg = pi_render("lineChart", Some("gap"))
  assert_eq(pi_count(svg, "<polyline"), 0)
  assert_eq(pi_count(svg, "<circle"), 2)
}

///|
test "§21.2.2.46 line chart span connects around sparse blank point" {
  let svg = pi_render("lineChart", Some("span"))
  assert_eq(pi_count(svg, "<polyline"), 1)
  assert_eq(pi_count(svg, "<circle"), 2)
}

///|
test "§21.2.2.46 area chart gap splits sparse blank into separate areas" {
  let svg = pi_render("areaChart", Some("gap"))
  assert_eq(pi_count(svg, "<polygon"), 2)
}

///|
test "§21.2.2.46 bar chart absent dispBlanksAs plots sparse blank as zero" {
  let svg = pi_render("barChart", None)
  assert_eq(pi_count(svg, "<rect"), 4)
}

///|
test "§21.2.2.46 bar chart gap suppresses sparse blank bar" {
  let svg = pi_render("barChart", Some("gap"))
  assert_eq(pi_count(svg, "<rect"), 3)
}

///|
test "§21.2.2.46 scatter chart absent dispBlanksAs plots sparse blank as zero" {
  let svg = pi_xy_render("scatterChart", None)
  assert_eq(pi_count(svg, "<polyline"), 1)
  assert_eq(pi_count(svg, "<circle"), 3)
}

///|
test "§21.2.2.46 scatter chart gap breaks sparse blank point" {
  let svg = pi_xy_render("scatterChart", Some("gap"))
  assert_eq(pi_count(svg, "<polyline"), 0)
  assert_eq(pi_count(svg, "<circle"), 2)
}

///|
test "§21.2.2.46 scatter chart span connects around sparse blank point" {
  let svg = pi_xy_render("scatterChart", Some("span"))
  assert_eq(pi_count(svg, "<polyline"), 1)
  assert_eq(pi_count(svg, "<circle"), 2)
}

///|
test "§21.2.2.46 bubble chart gap suppresses sparse blank bubble" {
  let svg = pi_xy_render("bubbleChart", Some("gap"))
  assert_eq(pi_count(svg, "<circle"), 2)
}
