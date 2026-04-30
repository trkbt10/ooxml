///|
test "round-trip no fill properties" {
  let value = read_no_fill_properties(
    bytes("<a:noFill xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>"),
  )
  assert_eq(value.element.name.local_name, "noFill")
  let reparsed = read_no_fill_properties(write_no_fill_properties(value))
  assert_eq(reparsed.element.name.local_name, "noFill")
}

///|
test "round-trip gradient fill properties" {
  let value = read_gradient_fill_properties(
    bytes(
      "<a:gradFill xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" flip=\"x\" rotWithShape=\"1\"><a:gsLst><a:gs pos=\"0\"><a:srgbClr val=\"FF0000\"/></a:gs><a:gs pos=\"100000\"><a:srgbClr val=\"0000FF\"/></a:gs></a:gsLst><a:lin ang=\"5400000\" scaled=\"1\"/><a:tileRect l=\"0\" t=\"0\" r=\"0\" b=\"0\"/></a:gradFill>",
    ),
  )
  assert_eq(value.element.name.local_name, "gradFill")
  let reparsed = read_gradient_fill_properties(
    write_gradient_fill_properties(value),
  )
  assert_eq(reparsed.element.name.local_name, "gradFill")
}

///|
test "round-trip blip fill properties" {
  let value = read_blip_fill_properties(
    bytes(
      "<a:blipFill xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" dpi=\"300\" rotWithShape=\"0\"><a:blip/><a:srcRect l=\"0\" t=\"0\" r=\"0\" b=\"0\"/><a:stretch><a:fillRect/></a:stretch></a:blipFill>",
    ),
  )
  assert_eq(value.element.name.local_name, "blipFill")
  let reparsed = read_blip_fill_properties(write_blip_fill_properties(value))
  assert_eq(reparsed.element.name.local_name, "blipFill")
}

///|
test "round-trip pattern fill properties" {
  let value = read_pattern_fill_properties(
    bytes(
      "<a:pattFill xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" prst=\"diagCross\"><a:fgClr><a:schemeClr val=\"accent1\"/></a:fgClr><a:bgClr><a:srgbClr val=\"FFFFFF\"/></a:bgClr></a:pattFill>",
    ),
  )
  assert_eq(value.element.name.local_name, "pattFill")
  let reparsed = read_pattern_fill_properties(
    write_pattern_fill_properties(value),
  )
  assert_eq(reparsed.element.name.local_name, "pattFill")
}

///|
test "reject invalid fill enum attribute" {
  try {
    read_gradient_fill_properties(
      bytes(
        "<a:gradFill xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" flip=\"z\"/>",
      ),
    )
    |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
