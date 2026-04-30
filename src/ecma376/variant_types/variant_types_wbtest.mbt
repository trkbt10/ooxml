///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "variant scalar round trip" {
  let xml = bytes(
    "<vt:lpwstr xmlns:vt=\"http://purl.oclc.org/ooxml/officeDocument/docPropsVTypes\">Title</vt:lpwstr>",
  )
  let value = read_value(xml)
  assert_true(value is VtLpwstr(_))
  let reparsed = read_value(write_value(value))
  assert_true(reparsed is VtLpwstr(_))
}

///|
test "variant element round trip" {
  let xml = bytes(
    "<vt:variant xmlns:vt=\"http://purl.oclc.org/ooxml/officeDocument/docPropsVTypes\"><vt:i4>42</vt:i4></vt:variant>",
  )
  let value = read_variant(xml)
  assert_eq(value.element.name.local_name, "variant")
  let reparsed = read_variant(write_variant(value))
  assert_eq(reparsed.element.children.length(), 1)
}

///|
test "vector validates baseType and round trips" {
  let xml = bytes(
    "<vt:vector xmlns:vt=\"http://purl.oclc.org/ooxml/officeDocument/docPropsVTypes\" baseType=\"lpstr\" size=\"2\"><vt:lpstr>A</vt:lpstr><vt:lpstr>B</vt:lpstr></vt:vector>",
  )
  let value = read_vector(xml)
  assert_eq(value.element.name.local_name, "vector")
  let reparsed = read_vector(write_vector(value))
  assert_eq(reparsed.element.children.length(), 2)
}
