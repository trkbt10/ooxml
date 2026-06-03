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
    bytes(
      // §17.7.4.17 requires w:styleId and w:type on a CT_Style child.
      "<w:styles xmlns:w=\"urn:w\"><w:style w:styleId=\"Body\" w:type=\"paragraph\"/></w:styles>",
    ),
  )
  assert_eq(
    read_styles(@builder.write_styles(styles)).element.name.local_name,
    "styles",
  )
  // Numbering uses CT_Numbering::parse which enforces §17.9.15
  // num/@numId + abstractNumId; provide a complete num so the
  // round-trip exercises the typed decoder.
  let numbering = read_numbering(
    bytes(
      "<w:numbering xmlns:w=\"urn:w\"><w:num w:numId=\"1\"><w:abstractNumId w:val=\"0\"/></w:num></w:numbering>",
    ),
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

///|
test "WML settings reader rejects invalid ST_OnOff values" {
  let invalid = try? read_settings(
    bytes(
      "<w:settings xmlns:w=\"urn:w\"><w:trackRevisions w:val=\"yes\"/></w:settings>",
    ),
  )
  assert_true(invalid is Err(@domain.SchemaViolation(_)))
}

///|
test "WML document reader rejects malformed embedded OMML values" {
  let invalid = try? read_document(
    bytes(
      "<w:document xmlns:w=\"urn:w\" xmlns:m=\"urn:math\">" +
      "<w:body><w:p>" +
      "<m:oMath>" +
      "<m:rad>" +
      "<m:radPr><m:degHide m:val=\"maybe\"/></m:radPr>" +
      "<m:deg/>" +
      "<m:e/>" +
      "</m:rad>" +
      "</m:oMath>" +
      "</w:p></w:body>" +
      "</w:document>",
    ),
  )
  assert_true(invalid is Err(@domain.SchemaViolation(_)))
}
