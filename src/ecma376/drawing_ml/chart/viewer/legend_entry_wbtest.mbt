// §21.2.2.101 CT_LegendEntry — deleted legend entries suppress only
// the legend item, not the underlying series.

///|
fn le_c(
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
fn le_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(le_c(tag, attrs, kids))
}

///|
fn le_num_val(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, v in vals {
    pts.push(
      le_cn("pt", [("idx", i.to_string())], [
        le_cn("v", [], [@xml.Node::Text(v)]),
      ]),
    )
  }
  le_cn("val", [], [le_cn("numLit", [], pts)])
}

///|
fn le_ser(name : String, vals : Array[String]) -> @xml.Node {
  le_cn("ser", [], [
    le_cn("tx", [], [le_cn("v", [], [@xml.Node::Text(name)])]),
    le_num_val(vals),
  ])
}

///|
fn le_chart_space() -> @xml.Element {
  le_c("chartSpace", [], [
    le_cn("chart", [], [
      le_cn("legend", [], [
        le_cn("legendPos", [("val", "r")], []),
        le_cn("legendEntry", [], [
          le_cn("idx", [("val", "1")], []),
          le_cn("delete", [("val", "1")], []),
        ]),
      ]),
      le_cn("plotArea", [], [
        le_cn("barChart", [], [
          le_cn("barDir", [("val", "col")], []),
          le_ser("Keep", ["10", "20"]),
          le_ser("Drop", ["12", "18"]),
          le_ser("Again", ["14", "22"]),
        ]),
      ]),
    ]),
  ])
}

///|
fn le_render() -> String {
  let node = render_chart_space(
    le_chart_space(),
    (0.0, 0.0, 420.0, 300.0),
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
test "§21.2.2.101 legendEntry delete hides only the matching legend item" {
  let svg = le_render()
  assert_true(svg.contains(">Keep</text>"))
  assert_true(!svg.contains(">Drop</text>"))
  assert_true(svg.contains(">Again</text>"))
  assert_true(svg.contains("fill=\"#a5a5a5\""))
}
