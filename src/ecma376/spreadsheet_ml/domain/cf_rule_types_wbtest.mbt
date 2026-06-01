// Tests for §18.3.1 conditional-formatting typed model.

///|
fn cf_attr_test(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name, ns: None }, value }
}

///|
fn cf_elem_test(
  local_name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  {
    name: {
      prefix: None,
      local_name,
      ns: Some("http://schemas.openxmlformats.org/spreadsheetml/2006/main"),
    },
    attributes: attrs,
    children,
  }
}

///|
test "§18.3.1.28 CT_DataBar decodes typed display metadata" {
  let bar = try! CT_DataBar::new(
    cf_elem_test(
      "dataBar",
      [
        cf_attr_test("axisPosition", "middle"),
        cf_attr_test("direction", "rightToLeft"),
      ],
      [
        @xml.Node::Element(
          cf_elem_test("cfvo", [cf_attr_test("type", "min")], []),
        ),
        @xml.Node::Element(
          cf_elem_test("cfvo", [cf_attr_test("type", "max")], []),
        ),
        @xml.Node::Element(
          cf_elem_test("color", [cf_attr_test("rgb", "FF0000FF")], []),
        ),
        @xml.Node::Element(
          cf_elem_test("negativeFillColor", [cf_attr_test("rgb", "FFFF0000")], []),
        ),
      ],
    ),
  )
  assert_eq(bar.axis_position, "middle")
  assert_eq(bar.direction, "rightToLeft")
  match bar.negative_color {
    Some(c) => {
      assert_eq(c.red, 255)
      assert_eq(c.green, 0)
      assert_eq(c.blue, 0)
    }
    None => assert_true(false)
  }
}

///|
fn icon_set_for_test(attrs : Array[@xml.Attribute]) -> @xml.Element {
  cf_elem_test("iconSet", attrs, [
    @xml.Node::Element(cf_elem_test("cfvo", [cf_attr_test("type", "min")], [])),
    @xml.Node::Element(cf_elem_test("cfvo", [cf_attr_test("type", "max")], [])),
  ])
}

///|
test "§18.3.1.49 CT_IconSet validates ST_IconSetType and keeps schema default" {
  let explicit = try! CT_IconSet::new(
    icon_set_for_test([cf_attr_test("iconSet", "4ArrowsGray")]),
  )
  assert_eq(explicit.set_name, "4ArrowsGray")
  let defaulted = try! CT_IconSet::new(icon_set_for_test([]))
  assert_eq(defaulted.set_name, "3TrafficLights1")
}

///|
test "§18.3.1.49 CT_IconSet rejects invalid ST_IconSetType" {
  assert_true(
    (try? CT_IconSet::new(
      icon_set_for_test([cf_attr_test("iconSet", "NoSuchIconSet")]),
    ))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}
