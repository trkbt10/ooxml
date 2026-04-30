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
  assert_eq(value.element.name.local_name, "shape")
  let reparsed = read_vml_shape(write_vml_shape(value))
  assert_eq(reparsed.element.name.local_name, "shape")
}

///|
test "round-trip Office VML shape defaults" {
  let value = read_vml_shapedefaults(
    bytes(
      "<o:shapedefaults xmlns:o=\"urn:schemas-microsoft-com:office:office\" spidmax=\"1024\"><o:colormru colors=\"red blue\"/></o:shapedefaults>",
    ),
  )
  assert_eq(value.element.name.local_name, "shapedefaults")
  let reparsed = read_vml_shapedefaults(write_vml_shapedefaults(value))
  assert_eq(reparsed.element.name.local_name, "shapedefaults")
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
  let names = EG_ShapeElements::new(value.element).child_names()
  assert_eq(names.length(), 3)
  assert_eq(names[0], "path")
}
