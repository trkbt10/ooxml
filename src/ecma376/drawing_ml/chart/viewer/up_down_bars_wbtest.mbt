// §21.2.2.218 upDownBars — up/down bars in a line/stock chart render
// as filled rects (white when the last series rose above the first,
// black otherwise) spanning first→last series values per category.

///|
fn udb_elem(children : Array[@xml.Node]) -> @xml.Element {
  {
    name: { prefix: Some("c"), local_name: "lineChart", ns: None },
    attributes: [],
    children,
  }
}

///|
fn udb_child(
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
test "upDownBars render up=white / down=black rects per category" {
  let elem = udb_elem([udb_child("upDownBars", [], [])])
  let series : Array[(Array[String], Array[Double])] = [
    (["a", "b", "c"], [10.0, 20.0, 30.0]), // first series
    (["a", "b", "c"], [15.0, 18.0, 40.0]), // last series
  ]
  let nodes = render_up_down_bars(
    elem,
    series,
    0.0,
    0.0,
    100.0,
    50.0,
    40.0,
    ColorResolveContext::empty(),
    3,
    false,
    false,
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  let svg = sb.to_string()
  // 3 categories → 3 rects.
  assert_eq(nodes.length(), 3)
  // cat0 (10→15) and cat2 (30→40) rose → white up bars.
  assert_true(svg.contains("fill=\"#ffffff\""))
  // cat1 (20→18) fell → black down bar.
  assert_true(svg.contains("fill=\"#000000\""))
}

///|
test "no upDownBars element → no bars" {
  let elem = udb_elem([])
  let series : Array[(Array[String], Array[Double])] = [
    (["a"], [10.0]),
    (["a"], [20.0]),
  ]
  let nodes = render_up_down_bars(
    elem,
    series,
    0.0,
    0.0,
    100.0,
    50.0,
    40.0,
    ColorResolveContext::empty(),
    1,
    false,
    false,
  )
  assert_eq(nodes.length(), 0)
}

///|
test "upDownBars need at least two series" {
  let elem = udb_elem([udb_child("upDownBars", [], [])])
  let series : Array[(Array[String], Array[Double])] = [(["a"], [10.0])]
  let nodes = render_up_down_bars(
    elem,
    series,
    0.0,
    0.0,
    100.0,
    50.0,
    40.0,
    ColorResolveContext::empty(),
    1,
    false,
    false,
  )
  assert_eq(nodes.length(), 0)
}
