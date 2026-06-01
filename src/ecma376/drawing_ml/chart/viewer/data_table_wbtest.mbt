// §21.2.2.54 CT_DTable — chart data-table frame/key rendering.

///|
fn dt_c(
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
fn dt_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(dt_c(tag, attrs, kids))
}

///|
fn dt_numval(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, v in vals {
    pts.push(
      dt_cn("pt", [("idx", i.to_string())], [
        dt_cn("v", [], [@xml.Node::Text(v)]),
      ]),
    )
  }
  dt_cn("val", [], [dt_cn("numLit", [], pts)])
}

///|
fn dt_ser(name : String, vals : Array[String]) -> @xml.Node {
  dt_ser_with_extra(name, vals, [])
}

///|
fn dt_ser_with_extra(
  name : String,
  vals : Array[String],
  extra : Array[@xml.Node],
) -> @xml.Node {
  let kids : Array[@xml.Node] = [
    dt_cn("tx", [], [dt_cn("v", [], [@xml.Node::Text(name)])]),
    dt_numval(vals),
  ]
  for node in extra {
    kids.push(node)
  }
  dt_cn("ser", [], kids)
}

///|
fn dt_chart_space_with_series(
  dtable_kids : Array[@xml.Node],
  series : Array[@xml.Node],
) -> @xml.Element {
  let dtable = dt_cn("dTable", [], dtable_kids)
  let bar_kids : Array[@xml.Node] = [dt_cn("barDir", [("val", "col")], [])]
  for ser in series {
    bar_kids.push(ser)
  }
  let bar = dt_cn("barChart", [], bar_kids)
  dt_c("chartSpace", [], [
    dt_cn("chart", [], [dt_cn("plotArea", [], [bar, dtable])]),
  ])
}

///|
fn dt_render(dtable_kids : Array[@xml.Node]) -> String {
  dt_render_with_series(dtable_kids, [
    dt_ser("North", ["10", "20", "30"]),
    dt_ser("South", ["12", "18", "25"]),
  ])
}

///|
fn dt_render_with_series(
  dtable_kids : Array[@xml.Node],
  series : Array[@xml.Node],
) -> String {
  let node = render_chart_space(
    dt_chart_space_with_series(dtable_kids, series),
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
fn dt_count(s : String, needle : String) -> Int {
  if needle.length() == 0 {
    return 0
  }
  let mut count = 0
  let mut i = 0
  while i + needle.length() <= s.length() {
    if s[i:i + needle.length()] == needle {
      count = count + 1
      i = i + needle.length()
    } else {
      i = i + 1
    }
  }
  count
}

///|
test "dTable default renders outline and border grid" {
  let svg = dt_render([])
  assert_true(svg.contains("data-ooxml=\"chart-dtable\""))
  assert_true(svg.contains("stroke=\"#bfbfbf\""))
  assert_true(svg.contains("data-ooxml=\"chart-dtable-hborder\""))
  assert_true(svg.contains("data-ooxml=\"chart-dtable-vborder\""))
  assert_true(!svg.contains("data-ooxml=\"chart-dtable-key\""))
}

///|
test "dTable border flags suppress horizontal vertical and outline strokes" {
  let svg = dt_render([
    dt_cn("showHorzBorder", [("val", "0")], []),
    dt_cn("showVertBorder", [("val", "0")], []),
    dt_cn("showOutline", [("val", "0")], []),
  ])
  assert_true(svg.contains("data-ooxml=\"chart-dtable\""))
  assert_true(svg.contains("stroke=\"none\""))
  assert_true(!svg.contains("data-ooxml=\"chart-dtable-hborder\""))
  assert_true(!svg.contains("data-ooxml=\"chart-dtable-vborder\""))
}

///|
test "dTable border flags honour xsd boolean false token" {
  let svg = dt_render([
    dt_cn("showHorzBorder", [("val", "false")], []),
    dt_cn("showVertBorder", [("val", "false")], []),
    dt_cn("showOutline", [("val", "false")], []),
  ])
  assert_true(svg.contains("data-ooxml=\"chart-dtable\""))
  assert_true(svg.contains("stroke=\"none\""))
  assert_true(!svg.contains("data-ooxml=\"chart-dtable-hborder\""))
  assert_true(!svg.contains("data-ooxml=\"chart-dtable-vborder\""))
}

///|
test "dTable showKeys renders one swatch per series without legend" {
  let svg = dt_render([dt_cn("showKeys", [("val", "1")], [])])
  assert_eq(dt_count(svg, "data-ooxml=\"chart-dtable-key\""), 2)
  assert_true(svg.contains("fill=\"#4472c4\""))
  assert_true(svg.contains("fill=\"#ed7d31\""))
}

///|
test "dTable showKeys uses the same series spPr colour as chart rendering" {
  let svg = dt_render_with_series([dt_cn("showKeys", [("val", "1")], [])], [
    dt_ser_with_extra("North", ["10", "20", "30"], [
      dt_cn("spPr", [], [
        dt_cn("solidFill", [], [dt_cn("srgbClr", [("val", "00ff00")], [])]),
      ]),
    ]),
    dt_ser("South", ["12", "18", "25"]),
  ])
  assert_true(svg.contains("data-ooxml=\"chart-dtable-key\""))
  assert_true(svg.contains("fill=\"#00ff00\""))
}

///|
test "dTable showKeys without val uses CT_Boolean default true" {
  let svg = dt_render([dt_cn("showKeys", [], [])])
  assert_eq(dt_count(svg, "data-ooxml=\"chart-dtable-key\""), 2)
}
