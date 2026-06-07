// §21.2.2.27 CT_ChartLines — chart line carrier elements consume
// DrawingML line properties instead of renderer-local fixed strokes.

///|
fn cl_c(
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
fn cl_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(cl_c(tag, attrs, kids))
}

///|
fn cl_a(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: None, local_name: k, ns: None }, value: v })
  }
  @xml.Node::Element({
    name: { prefix: Some("a"), local_name: tag, ns: None },
    attributes: a,
    children: kids,
  })
}

///|
fn cl_numval(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, v in vals {
    pts.push(
      cl_cn("pt", [("idx", i.to_string())], [
        cl_cn("v", [], [@xml.Node::Text(v)]),
      ]),
    )
  }
  cl_cn("val", [], [cl_cn("numLit", [], pts)])
}

///|
fn cl_ser(vals : Array[String]) -> @xml.Node {
  cl_cn("ser", [], [cl_numval(vals)])
}

///|
fn cl_sp_pr_line(
  color : String,
  width : String,
  dash? : String? = None,
  cap? : String? = None,
) -> @xml.Node {
  let ln_kids : Array[@xml.Node] = [
    cl_a("solidFill", [], [cl_a("srgbClr", [("val", color)], [])]),
  ]
  match dash {
    Some(v) => ln_kids.push(cl_a("prstDash", [("val", v)], []))
    None => ()
  }
  let attrs : Array[(String, String)] = [("w", width)]
  match cap {
    Some(v) => attrs.push(("cap", v))
    None => ()
  }
  cl_cn("spPr", [], [cl_a("ln", attrs, ln_kids)])
}

///|
fn cl_chart_line(tag : String, sp_pr : @xml.Node) -> @xml.Node {
  cl_cn(tag, [], [sp_pr])
}

///|
fn cl_chart_space(
  chart_tag : String,
  chart_kids : Array[@xml.Node],
) -> @xml.Element {
  cl_c("chartSpace", [], [
    cl_cn("chart", [], [
      cl_cn("plotArea", [], [cl_cn(chart_tag, [], chart_kids)]),
    ]),
  ])
}

///|
fn cl_chart_space_with_plot(plot_kids : Array[@xml.Node]) -> @xml.Element {
  cl_c("chartSpace", [], [
    cl_cn("chart", [], [cl_cn("plotArea", [], plot_kids)]),
  ])
}

///|
fn cl_render(chart_tag : String, chart_kids : Array[@xml.Node]) -> String {
  let node = render_chart_space(
    cl_chart_space(chart_tag, chart_kids),
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
fn cl_render_plot(plot_kids : Array[@xml.Node]) -> String {
  let node = render_chart_space(
    cl_chart_space_with_plot(plot_kids),
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
test "dropLines spPr drives rendered stroke" {
  let svg = cl_render("lineChart", [
    cl_ser(["10", "20", "30"]),
    cl_chart_line(
      "dropLines",
      cl_sp_pr_line("8090A0", "19050", dash=Some("dash"), cap=Some("rnd")),
    ),
  ])
  assert_true(svg.contains("stroke=\"#8090a0\""))
  assert_true(svg.contains("stroke-width=\"2\""))
  assert_true(svg.contains("stroke-dasharray=\"8 6\""))
  assert_true(svg.contains("stroke-linecap=\"round\""))
}

///|
test "hiLowLines spPr drives rendered stroke" {
  let svg = cl_render("lineChart", [
    cl_ser(["10", "25", "30"]),
    cl_ser(["18", "15", "40"]),
    cl_chart_line("hiLowLines", cl_sp_pr_line("123456", "28575")),
  ])
  assert_true(svg.contains("stroke=\"#123456\""))
  assert_true(svg.contains("stroke-width=\"3\""))
}

///|
test "bar serLines spPr drives rendered stroke" {
  let svg = cl_render("barChart", [
    cl_cn("barDir", [("val", "col")], []),
    cl_cn("grouping", [("val", "stacked")], []),
    cl_ser(["10", "20", "30"]),
    cl_ser(["15", "25", "35"]),
    cl_chart_line("serLines", cl_sp_pr_line("A0B0C0", "19050")),
  ])
  assert_true(svg.contains("stroke=\"#a0b0c0\""))
  assert_true(svg.contains("stroke-width=\"2\""))
}

///|
test "majorGridlines spPr drives value-axis grid stroke" {
  let svg = cl_render_plot([
    cl_cn("lineChart", [], [cl_ser(["10", "20", "30"])]),
    cl_cn("valAx", [], [
      cl_chart_line(
        "majorGridlines",
        cl_sp_pr_line("445566", "19050", dash=Some("dash")),
      ),
    ]),
  ])
  assert_true(svg.contains("stroke=\"#445566\""))
  assert_true(svg.contains("stroke-width=\"2\""))
  assert_true(svg.contains("stroke-dasharray=\"8 6\""))
}

///|
test "minorGridlines spPr drives value-axis grid stroke" {
  let svg = cl_render_plot([
    cl_cn("lineChart", [], [cl_ser(["10", "20", "30"])]),
    cl_cn("valAx", [], [
      cl_chart_line(
        "minorGridlines",
        cl_sp_pr_line("778899", "9525", dash=Some("dot"), cap=Some("sq")),
      ),
    ]),
  ])
  assert_true(svg.contains("stroke=\"#778899\""))
  assert_true(svg.contains("stroke-width=\"1\""))
  assert_true(svg.contains("stroke-dasharray=\"1 2\""))
  assert_true(svg.contains("stroke-linecap=\"square\""))
}

///|
test "chartLines noFill suppresses stroke style" {
  let chart_lines = cl_c("serLines", [], [
    cl_cn("spPr", [], [cl_a("ln", [], [cl_a("noFill", [], [])])]),
  ])
  match
    chart_lines_style(
      chart_lines,
      ColorResolveContext::empty(),
      SvgDefsCollector::new(),
      "chart-lines-nofill",
      "#bfbfbf",
      1.0,
    ) {
    None => ()
    Some(_) => fail("a:noFill must suppress CT_ChartLines")
  }
}
