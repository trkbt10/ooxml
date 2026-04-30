///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "round-trip srgb color" {
  let value = read_s_rgb_color(
    bytes(
      "<a:srgbClr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" val=\"FFCC00\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "srgbClr")
  let reparsed = read_s_rgb_color(write_s_rgb_color(value))
  assert_eq(reparsed.element.name.local_name, "srgbClr")
}

///|
test "round-trip system color" {
  let value = read_system_color(
    bytes(
      "<a:sysClr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" val=\"windowText\" lastClr=\"000000\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "sysClr")
  let reparsed = read_system_color(write_system_color(value))
  assert_eq(reparsed.element.name.local_name, "sysClr")
}

///|
test "round-trip scheme color" {
  let value = read_scheme_color(
    bytes(
      "<a:schemeClr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" val=\"accent1\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "schemeClr")
  let reparsed = read_scheme_color(write_scheme_color(value))
  assert_eq(reparsed.element.name.local_name, "schemeClr")
}

///|
test "round-trip preset color" {
  let value = read_preset_color(
    bytes(
      "<a:prstClr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" val=\"cornflowerBlue\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "prstClr")
  let reparsed = read_preset_color(write_preset_color(value))
  assert_eq(reparsed.element.name.local_name, "prstClr")
}

///|
test "round-trip color scheme" {
  let value = read_color_scheme(
    bytes(
      "<a:clrScheme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:dk1><a:sysClr val=\"windowText\" lastClr=\"000000\"/></a:dk1><a:lt1><a:sysClr val=\"window\" lastClr=\"FFFFFF\"/></a:lt1></a:clrScheme>",
    ),
  )
  assert_eq(value.element.name.local_name, "clrScheme")
  let reparsed = read_color_scheme(write_color_scheme(value))
  assert_eq(reparsed.element.name.local_name, "clrScheme")
}

///|
test "round-trip color mapping" {
  let value = read_color_mapping(
    bytes(
      "<a:clrMap xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" bg1=\"lt1\" tx1=\"dk1\" bg2=\"lt2\" tx2=\"dk2\" accent1=\"accent1\" accent2=\"accent2\" accent3=\"accent3\" accent4=\"accent4\" accent5=\"accent5\" accent6=\"accent6\" hlink=\"hlink\" folHlink=\"folHlink\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "clrMap")
  let reparsed = read_color_mapping(write_color_mapping(value))
  assert_eq(reparsed.element.name.local_name, "clrMap")
}

///|
test "reject invalid preset color token" {
  try {
    ST_PresetColorVal::parse("notAColor") |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
