///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "WML top-level readers round trip through builders" {
  let document = read_document(
    bytes("<w:document xmlns:w=\"urn:w\"><w:body/></w:document>"),
  )
  assert_eq(
    read_document(@builder.write_document(document)).element.children.length(),
    1,
  )
  let styles = read_styles(
    bytes("<w:styles xmlns:w=\"urn:w\"><w:style/></w:styles>"),
  )
  assert_eq(
    read_styles(@builder.write_styles(styles)).element.name.local_name,
    "styles",
  )
  let numbering = read_numbering(
    bytes("<w:numbering xmlns:w=\"urn:w\"><w:num/></w:numbering>"),
  )
  assert_eq(
    read_numbering(@builder.write_numbering(numbering)).element.children.length(),
    1,
  )
  let settings = read_settings(
    bytes("<w:settings xmlns:w=\"urn:w\"><w:compat/></w:settings>"),
  )
  assert_eq(
    read_settings(@builder.write_settings(settings)).element.name.local_name,
    "settings",
  )
}

///|
test "WML top-level readers reject the wrong root element" {
  let invalid = try? read_document(bytes("<w:styles xmlns:w=\"urn:w\"/>"))
  assert_true(invalid is Err(@domain.SchemaViolation(_)))
}
