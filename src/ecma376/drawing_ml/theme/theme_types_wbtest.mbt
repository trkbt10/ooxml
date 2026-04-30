///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "round-trip DrawingML theme" {
  let value = read_theme(
    bytes(
      "<a:theme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:themeElements/></a:theme>",
    ),
  )
  assert_eq(value.element.name.local_name, "theme")
  let reparsed = read_theme(write_theme(value))
  assert_eq(reparsed.element.name.local_name, "theme")
}

///|
test "round-trip DrawingML theme override" {
  let value = read_theme_override(
    bytes(
      "<a:themeOverride xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:fontScheme name=\"Office\"/></a:themeOverride>",
    ),
  )
  assert_eq(value.element.name.local_name, "themeOverride")
  let reparsed = read_theme_override(write_theme_override(value))
  assert_eq(reparsed.element.name.local_name, "themeOverride")
}

///|
test "round-trip DrawingML theme manager" {
  let value = read_theme_manager(
    bytes(
      "<a:themeManager xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "themeManager")
  let reparsed = read_theme_manager(write_theme_manager(value))
  assert_eq(reparsed.element.name.local_name, "themeManager")
}
