///|
fn ml_elem(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Element {
  let xml_attrs : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    xml_attrs.push({
      name: { prefix: Some("c"), local_name: k, ns: None },
      value: v,
    })
  }
  {
    name: { prefix: Some("c"), local_name: tag, ns: None },
    attributes: xml_attrs,
    children: kids,
  }
}

///|
fn ml_node(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(ml_elem(tag, attrs, kids))
}

///|
test "plotArea manualLayout outer edge resolves against chart frame" {
  let plot_area = ml_elem("plotArea", [], [
    ml_node("layout", [], [
      ml_node("manualLayout", [], [
        ml_node("layoutTarget", [("val", "outer")], []),
        ml_node("xMode", [("val", "edge")], []),
        ml_node("yMode", [("val", "edge")], []),
        ml_node("wMode", [("val", "edge")], []),
        ml_node("hMode", [("val", "edge")], []),
        ml_node("x", [("val", "0.1")], []),
        ml_node("y", [("val", "0.2")], []),
        ml_node("w", [("val", "0.8")], []),
        ml_node("h", [("val", "0.9")], []),
      ]),
    ]),
  ])
  let (x, y, w, h) = chart_plot_area_manual_rect(
    plot_area, 10.0, 20.0, 200.0, 100.0, 400.0, 300.0,
  )
  assert_eq(x, 40.0)
  assert_eq(y, 60.0)
  assert_eq(w, 280.0)
  assert_eq(h, 210.0)
}

///|
test "plotArea without manualLayout preserves automatic inner rect" {
  let plot_area = ml_elem("plotArea", [], [ml_node("layout", [], [])])
  let (x, y, w, h) = chart_plot_area_manual_rect(
    plot_area, 10.0, 20.0, 200.0, 100.0, 400.0, 300.0,
  )
  assert_eq(x, 10.0)
  assert_eq(y, 20.0)
  assert_eq(w, 200.0)
  assert_eq(h, 100.0)
}
