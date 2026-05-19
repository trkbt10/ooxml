///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "round-trip VML shape" {
  let value = read_vml_shape(
    bytes(
      "<v:shape xmlns:v=\"urn:schemas-microsoft-com:vml\" id=\"shape1\" style=\"width:10pt;height:10pt\"><v:path textpathok=\"t\"/><v:fill color=\"red\"/></v:shape>",
    ),
  )
  assert_eq(value.raw_element.name.local_name, "shape")
  assert_eq(value.id, Some("shape1"))
  assert_eq(value.style, Some("width:10pt;height:10pt"))
  assert_eq(value.shape_children.length(), 2)
  let reparsed = read_vml_shape(write_vml_shape(value))
  assert_eq(reparsed.raw_element.name.local_name, "shape")
  assert_eq(reparsed.id, Some("shape1"))
}

///|
test "round-trip Office VML shape defaults" {
  let value = read_vml_shapedefaults(
    bytes(
      "<o:shapedefaults xmlns:o=\"urn:schemas-microsoft-com:office:office\" spidmax=\"1024\"><o:colormru colors=\"red blue\"/></o:shapedefaults>",
    ),
  )
  assert_eq(value.raw_element.name.local_name, "shapedefaults")
  assert_eq(value.spidmax, Some("1024"))
  match value.colormru {
    Some(menu) => assert_eq(menu.colors, Some("red blue"))
    None => fail("expected colormru child")
  }
  let reparsed = read_vml_shapedefaults(write_vml_shapedefaults(value))
  assert_eq(reparsed.raw_element.name.local_name, "shapedefaults")
}

///|
test "validate VML simple type enumerations" {
  assert_eq(ST_StrokeJoinStyle::parse("miter").to_string(), "miter")
  try {
    ST_StrokeJoinStyle::parse("square") |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "collect VML model group child names" {
  let value = read_vml_shape(
    bytes(
      "<v:shape xmlns:v=\"urn:schemas-microsoft-com:vml\"><v:path/><v:fill/><v:stroke/></v:shape>",
    ),
  )
  let names = EG_ShapeElements::new(value.raw_element).child_names()
  assert_eq(names.length(), 3)
  assert_eq(names[0], "path")
  // Also assert typed children are preserved on CT_Shape directly.
  assert_eq(value.shape_children.length(), 3)
  assert_eq(value.shape_children[0].name.local_name, "path")
}

///|
test "decode VML stroke attributes into typed enums" {
  let value = read_vml_stroke(
    bytes(
      "<v:stroke xmlns:v=\"urn:schemas-microsoft-com:vml\" joinstyle=\"miter\" endcap=\"round\" startarrow=\"classic\"/>",
    ),
  )
  match value.joinstyle {
    Some(style) => assert_eq(style.to_string(), "miter")
    None => fail("joinstyle should be decoded")
  }
  match value.endcap {
    Some(cap) => assert_eq(cap.to_string(), "round")
    None => fail("endcap should be decoded")
  }
  match value.startarrow {
    Some(arrow) => assert_eq(arrow.to_string(), "classic")
    None => fail("startarrow should be decoded")
  }
}

///|
test "decode VML fill attributes and child" {
  let value = read_vml_fill(
    bytes(
      "<v:fill xmlns:v=\"urn:schemas-microsoft-com:vml\" type=\"solid\" color=\"red\" on=\"t\" aspect=\"atMost\"/>",
    ),
  )
  match value.type_ {
    Some(t) => assert_eq(t.to_string(), "solid")
    None => fail("type should decode")
  }
  assert_eq(value.color, Some("red"))
  assert_eq(value.on, Some(true))
  match value.aspect {
    Some(a) => assert_eq(a.to_string(), "atMost")
    None => fail("aspect should decode")
  }
}
