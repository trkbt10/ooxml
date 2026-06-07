// §21.2.2.55 CT_ErrBars / §21.2.2.57 errBarType.

///|
fn err_bar_test_elem(
  tag : String,
  attrs : Array[(String, String)],
  children : Array[@xml.Node],
) -> @xml.Element {
  let xml_attrs : Array[@xml.Attribute] = []
  for kv in attrs {
    let (name, value) = kv
    xml_attrs.push({ name: { prefix: None, local_name: name, ns: None }, value })
  }
  {
    name: { prefix: Some("c"), local_name: tag, ns: None },
    attributes: xml_attrs,
    children,
  }
}

///|
fn err_bar_test_svg(nodes : Array[@xml.Node]) -> String {
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
test "read_err_bars reads errBarType" {
  let ser = err_bar_test_elem("ser", [], [
    @xml.Node::Element(
      err_bar_test_elem("errBars", [], [
        @xml.Node::Element(
          err_bar_test_elem("errBarType", [("val", "minus")], []),
        ),
        @xml.Node::Element(
          err_bar_test_elem("errValType", [("val", "fixedVal")], []),
        ),
        @xml.Node::Element(err_bar_test_elem("val", [("val", "10")], [])),
      ]),
    ),
  ])
  match read_err_bars(ser) {
    Some(cfg) => assert_eq(cfg.err_bar_type, "minus")
    None => fail("errBars should be readable")
  }
}

///|
test "errBarType plus draws only the plus side" {
  let cfg : ErrBarConfig = {
    err_dir: "y",
    err_bar_type: "plus",
    err_val_type: "fixedVal",
    val: 10.0,
    no_end_cap: false,
    plus_values: [],
    minus_values: [],
  }
  let nodes = render_err_bars(cfg, [(50.0, 50.0)], 100.0, 100.0, "#111111", 2.0)
  let svg = err_bar_test_svg(nodes)
  assert_eq(nodes.length(), 2)
  assert_true(svg.contains("y1=\"40\""))
  assert_true(svg.contains("y2=\"50\""))
  assert_false(svg.contains("y2=\"60\""))
}

///|
test "errBarType minus draws only the minus side" {
  let cfg : ErrBarConfig = {
    err_dir: "y",
    err_bar_type: "minus",
    err_val_type: "fixedVal",
    val: 10.0,
    no_end_cap: false,
    plus_values: [],
    minus_values: [],
  }
  let nodes = render_err_bars(cfg, [(50.0, 50.0)], 100.0, 100.0, "#111111", 2.0)
  let svg = err_bar_test_svg(nodes)
  assert_eq(nodes.length(), 2)
  assert_true(svg.contains("y1=\"50\""))
  assert_true(svg.contains("y2=\"60\""))
  assert_false(svg.contains("y1=\"40\""))
}
