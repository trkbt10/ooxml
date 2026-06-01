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
  let types = try! CT_Types::new([
    Default(
      CT_Default::new(
        try! Extension::parse("rels"),
        try! ContentType::parse(
          "application/vnd.openxmlformats-package.relationships+xml",
        ),
      ),
    ),
  ])
  let part = try! PartName::__from_trusted("/_rels/.rels")
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
  let types = try! CT_Types::new([
    Override(CT_Override::new(origin, digital_signature_origin_content_type())),
    Override(
      CT_Override::new(
        signature,
        digital_signature_xml_signature_content_type(),
      ),
    ),
    Override(
      CT_Override::new(cert, digital_signature_certificate_content_type()),
    ),
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
  assert_true(missing is Err(@opc_errors.SchemaViolation(_)))
  let duplicate = try? read_content_types(
    b(
      "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Default Extension=\"xml\" ContentType=\"text/xml\"/></Types>",
    ),
  )
  assert_true(duplicate is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "ST_ContentType accepts media type parameters from opc-contentTypes.xsd" {
  assert_eq(
    (try! ContentType::parse("text/plain; charset=utf-8")).to_string(),
    "text/plain; charset=utf-8",
  )
  assert_eq(
    (try! ContentType::parse(
      "application/example ; name=\"quoted value\"; version=1",
    )).to_string(),
    "application/example ; name=\"quoted value\"; version=1",
  )
  assert_eq(
    (try! ContentType::parse("text/plain; title=\"caf\u{00e9}\"")).to_string(),
    "text/plain; title=\"caf\u{00e9}\"",
  )
}

///|
test "ST_ContentType rejects malformed media type parameters" {
  for
    invalid in [
      "application", "application/", "/xml", "application/xml;", "application/xml; charset",
      "application/xml; charset=", "application/xml; bad name=utf-8", "application/xml; name=\"unterminated",
      "application/xml; name=\"bad\nline\"",
    ] {
    let result = try? ContentType::parse(invalid)
    assert_true(result is Err(@opc_errors.SchemaViolation(_)))
  }
}

///|
test "ST_Extension follows opc-contentTypes.xsd extension pattern" {
  for valid in ["rels", "x%2B", "a+b", "x@y", "weird,=!"] {
    assert_eq((try! Extension::parse(valid)).to_string(), valid)
  }
  for invalid in ["", "bad space", "png.ext", "foo/bar", "%", "%Z0"] {
    let result = try? Extension::parse(invalid)
    assert_true(result is Err(@opc_errors.SchemaViolation(_)))
  }
}

///|
test "content types round trip preserves parameterized content type" {
  let source = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"txt\" ContentType=\"text/plain; charset=utf-8\"/></Types>",
  )
  let parsed = try! read_content_types(source)
  let reparsed = try! read_content_types(write_content_types(parsed))
  assert_true(reparsed == parsed)
  let part = try! PartName::parse("/doc/readme.txt")
  let actual = match parsed.content_type_for_part(part) {
    Some(t) => t.to_string()
    None => ""
  }
  assert_eq(actual, "text/plain; charset=utf-8")
}

///|
test "public E3 and E4 errors carry content-types context" {
  @opc_errors.require_supported_feature(
    false,
    section="10.1",
    path="/Types",
    reason="recognized but not implemented",
  ) catch {
    @opc_errors.UnsupportedFeature(
      section="10.1",
      path="/Types",
      reason=_reason
    ) => ()
    _ => fail("expected @opc_errors.UnsupportedFeature")
  }
  @opc_errors.require_resource(
    false,
    section="10.1",
    path="/Types/Override",
    target="/word/document.xml",
  ) catch {
    @opc_errors.ResourceMissing(
      section="10.1",
      path="/Types/Override",
      target=_target
    ) => ()
    _ => fail("expected @opc_errors.ResourceMissing")
  }
}

///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
/// Part 2 §10.1.2.2.1 — the CT_Default extension comparison is
/// case-insensitive ASCII.  A part `image.JPEG` must resolve
/// against `<Default Extension="jpeg">`.
test "default extension match is case-insensitive" {
  let types = try! CT_Types::new([
    Default(
      CT_Default::new(
        try! Extension::parse("jpeg"),
        try! ContentType::parse("image/jpeg"),
      ),
    ),
  ])
  // Part name with an uppercase extension.
  let part = try! PartName::__from_trusted("/word/media/photo.JPEG")
  let actual = match types.content_type_for_part(part) {
    Some(t) => t.to_string()
    None => ""
  }
  assert_eq(actual, "image/jpeg")
}

///|
/// Part 2 §10.1.2.2.2 — the CT_Override PartName comparison is
/// case-insensitive ASCII.
test "override partName match is case-insensitive" {
  let override_part = try! PartName::__from_trusted("/word/document.xml")
  let types = try! CT_Types::new([
    Override(
      CT_Override::new(
        override_part,
        try! ContentType::parse(
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
        ),
      ),
    ),
  ])
  // Look up with a different-cased part name.
  let lookup = try! PartName::__from_trusted("/Word/Document.XML")
  let actual = match types.content_type_for_part(lookup) {
    Some(t) => t.to_string()
    None => ""
  }
  assert_eq(
    actual, "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
  )
}
