// §21.2.2.48 dLblPos="outEnd" + §21.2.2.92 leaderLines — pie data
// labels placed outside the pie get connector lines to each slice.

///|
fn ce(
  local : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: None, local_name: k, ns: None }, value: v })
  }
  @xml.Node::Element({
    name: { prefix: Some("c"), local_name: local, ns: None },
    attributes: a,
    children: kids,
  })
}

///|
fn pie_with_dlbls(dlbl_kids : Array[@xml.Node]) -> @xml.Element {
  // values 30,50,20 via <c:val><c:numRef><c:numCache><c:pt><c:v>.
  let pts = [
    ce("pt", [("idx", "0")], [ce("v", [], [@xml.Node::Text("30")])]),
    ce("pt", [("idx", "1")], [ce("v", [], [@xml.Node::Text("50")])]),
    ce("pt", [("idx", "2")], [ce("v", [], [@xml.Node::Text("20")])]),
  ]
  let val = ce("val", [], [ce("numRef", [], [ce("numCache", [], pts)])])
  let ser = ce("ser", [], [val])
  {
    name: { prefix: Some("c"), local_name: "pieChart", ns: None },
    attributes: [],
    children: [ce("dLbls", [], dlbl_kids), ser],
  }
}

///|
test "pie dLblPos=outEnd + leaderLines emits connector lines + side-anchored labels" {
  let dlbls = [
    ce("showVal", [("val", "1")], []),
    ce("dLblPos", [("val", "outEnd")], []),
    ce("leaderLines", [], []),
  ]
  let elem = pie_with_dlbls(dlbls)
  let nodes = render_pie_chart(
    elem,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
    hole_percent=None,
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  let svg = sb.to_string()
  // External labels → leader <line> connectors present.
  assert_true(svg.contains("<line "))
  // External labels are side-anchored (start/end), not "middle".
  assert_true(
    svg.contains("text-anchor=\"start\"") || svg.contains("text-anchor=\"end\""),
  )
}

///|
test "pie default label position stays inside (no leader lines)" {
  let dlbls = [ce("showVal", [("val", "1")], [])]
  let elem = pie_with_dlbls(dlbls)
  let nodes = render_pie_chart(
    elem,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
    hole_percent=None,
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  let svg = sb.to_string()
  // Inside labels → no leader connectors, centre-anchored.
  assert_true(!svg.contains("<line "))
  assert_true(svg.contains("text-anchor=\"middle\""))
}

///|
test "pie showLeaderLines honours xsd boolean false token" {
  let dlbls = [
    ce("showVal", [("val", "1")], []),
    ce("dLblPos", [("val", "outEnd")], []),
    ce("showLeaderLines", [("val", "false")], []),
    ce("leaderLines", [], []),
  ]
  let elem = pie_with_dlbls(dlbls)
  let nodes = render_pie_chart(
    elem,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
    hole_percent=None,
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  assert_true(!sb.to_string().contains("<line "))
}

///|
test "pie showVal without val uses CT_Boolean default true" {
  let dlbls = [ce("showVal", [], [])]
  let elem = pie_with_dlbls(dlbls)
  let nodes = render_pie_chart(
    elem,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
    hole_percent=None,
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  assert_true(sb.to_string().contains(">30<"))
}
