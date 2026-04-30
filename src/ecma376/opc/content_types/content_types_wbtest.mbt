///|
test "content types round trip preserves rules" {
  let source = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
  )
  let parsed = try! read_content_types(source)
  let reparsed = try! read_content_types(write_content_types(parsed))
  assert_true(reparsed == parsed)
  let part = try! PartName::parse("/word/document.xml")
  let actual = match parsed.content_type_for_part(part) {
    Some(t) => t.to_string()
    None => ""
  }
  assert_eq(
    actual, "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
  )
}

///|
test "default rule resolves by extension" {
  let types = try! Types::new([
    Default(
      Default::new(
        try! Extension::parse("rels"),
        try! ContentType::parse(
          "application/vnd.openxmlformats-package.relationships+xml",
        ),
      ),
    ),
  ])
  let part = try! PartName::parse("/_rels/.rels")
  let actual = match types.content_type_for_part(part) {
    Some(t) => t.to_string()
    None => ""
  }
  assert_eq(actual, "application/vnd.openxmlformats-package.relationships+xml")
}

///|
test "digital signature content type validation" {
  let origin = try! PartName::parse(
    "/package/services/digital-signature/origin.psdsor",
  )
  let signature = try! PartName::parse(
    "/package/services/digital-signature/xml-signature/sig1.xml",
  )
  let cert = try! PartName::parse(
    "/package/services/digital-signature/certificate/cert1.crt",
  )
  let types = try! Types::new([
    Override(Override::new(origin, digital_signature_origin_content_type())),
    Override(
      Override::new(signature, digital_signature_xml_signature_content_type()),
    ),
    Override(Override::new(cert, digital_signature_certificate_content_type())),
  ])
  try! types.require_digital_signature_content_types(
    origin,
    signature,
    Some(cert),
  )
}

///|
test "reject malformed content types xml" {
  let missing = try? read_content_types(
    b(
      "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default ContentType=\"application/xml\"/></Types>",
    ),
  )
  assert_true(missing is Err(SchemaViolation(_)))
  let duplicate = try? read_content_types(
    b(
      "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Default Extension=\"xml\" ContentType=\"text/xml\"/></Types>",
    ),
  )
  assert_true(duplicate is Err(SchemaViolation(_)))
}

///|
test "public E3 and E4 errors carry content-types context" {
  require_supported_feature(
    false,
    section="10.1",
    path="/Types",
    reason="recognized but not implemented",
  ) catch {
    UnsupportedFeature(section="10.1", path="/Types", reason=_reason) => ()
    _ => fail("expected UnsupportedFeature")
  }
  require_resource(
    false,
    section="10.1",
    path="/Types/Override",
    target="/word/document.xml",
  ) catch {
    ResourceMissing(section="10.1", path="/Types/Override", target=_target) =>
      ()
    _ => fail("expected ResourceMissing")
  }
}

///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}
