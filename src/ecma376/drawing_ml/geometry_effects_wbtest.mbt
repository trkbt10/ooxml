///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "round-trip transform2d" {
  let value = read_transform2d(
    bytes(
      "<a:xfrm xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" rot=\"60000\"><a:off x=\"0\" y=\"0\"/><a:ext cx=\"914400\" cy=\"914400\"/></a:xfrm>",
    ),
  )
  assert_eq(value.element.name.local_name, "xfrm")
  let reparsed = read_transform2d(write_transform2d(value))
  assert_eq(reparsed.element.name.local_name, "xfrm")
}

///|
test "round-trip preset geometry2d" {
  let value = read_preset_geometry2d(
    bytes(
      "<a:prstGeom xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" prst=\"rect\"><a:avLst/></a:prstGeom>",
    ),
  )
  assert_eq(value.element.name.local_name, "prstGeom")
  let reparsed = read_preset_geometry2d(write_preset_geometry2d(value))
  assert_eq(reparsed.element.name.local_name, "prstGeom")
}

///|
test "round-trip custom geometry2d" {
  let value = read_custom_geometry2d(
    bytes(
      "<a:custGeom xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:avLst><a:gd name=\"adj\" fmla=\"val 50000\"/></a:avLst><a:rect l=\"l\" t=\"t\" r=\"r\" b=\"b\"/><a:pathLst/></a:custGeom>",
    ),
  )
  assert_eq(value.element.name.local_name, "custGeom")
  let reparsed = read_custom_geometry2d(write_custom_geometry2d(value))
  assert_eq(reparsed.element.name.local_name, "custGeom")
}

///|
test "round-trip blur effect" {
  let value = read_blur_effect(
    bytes(
      "<a:blur xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" rad=\"12700\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "blur")
  let reparsed = read_blur_effect(write_blur_effect(value))
  assert_eq(reparsed.element.name.local_name, "blur")
}

///|
test "round-trip effect list" {
  let value = read_effect_list(
    bytes(
      "<a:effectLst xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:outerShdw blurRad=\"40000\" dist=\"20000\" dir=\"5400000\"/></a:effectLst>",
    ),
  )
  assert_eq(value.element.name.local_name, "effectLst")
  let reparsed = read_effect_list(write_effect_list(value))
  assert_eq(reparsed.element.name.local_name, "effectLst")
}

///|
test "reject empty geometry attribute" {
  try {
    read_preset_geometry2d(
      bytes(
        "<a:prstGeom xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" prst=\"\"/>",
      ),
    )
    |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
