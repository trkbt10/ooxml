///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "round-trip DrawingML text font" {
  let value = read_text_font(
    bytes(
      "<a:latin xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" typeface=\"Aptos\" pitchFamily=\"34\" charset=\"0\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "latin")
  let reparsed = read_text_font(write_text_font(value))
  assert_eq(reparsed.element.name.local_name, "latin")
}

///|
test "round-trip DrawingML font scheme" {
  let value = read_font_scheme(
    bytes(
      "<a:fontScheme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:majorFont><a:latin typeface=\"Aptos Display\"/></a:majorFont><a:minorFont><a:latin typeface=\"Aptos\"/></a:minorFont></a:fontScheme>",
    ),
  )
  assert_eq(value.element.name.local_name, "fontScheme")
  let reparsed = read_font_scheme(write_font_scheme(value))
  assert_eq(reparsed.element.name.local_name, "fontScheme")
}

///|
test "reject invalid pitch family" {
  try {
    ST_PitchFamily::parse("99") |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
