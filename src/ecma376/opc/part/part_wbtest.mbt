///|
test "part name validation and zip item" {
  let name = try! PartName::parse("/docProps/core.xml")
  inspect(name.to_string(), content="/docProps/core.xml")
  let invalid = try? PartName::parse("docProps/core.xml")
  assert_true(
    invalid
    is Err(
      SchemaViolation(
        section="9",
        path="PartName",
        reason="part name must start with /"
      )
    ),
  )
}

///|
test "thumbnail part round trip preserves bytes" {
  let name = try! PartName::parse("/docProps/thumbnail.jpeg")
  let bytes = b("jpeg bytes")
  let thumbnail = read_thumbnail_part(name, bytes)
  assert_eq(thumbnail.name.to_string(), "/docProps/thumbnail.jpeg")
  assert_true(bytes_equal(write_thumbnail_part(thumbnail), bytes))
}

///|
test "core properties XML round trip preserves parsed document" {
  let source = b(
    "<coreProperties xmlns=\"http://schemas.openxmlformats.org/package/2006/metadata/core-properties\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\"><dc:title xml:lang=\"en\">Title</dc:title><keywords xml:lang=\"en\"><value>one</value><value>two</value></keywords></coreProperties>",
  )
  let parsed = try! read_core_properties(source)
  let reparsed = try! read_core_properties(write_core_properties(parsed))
  assert_true(reparsed == parsed)
}

///|
test "public E3 and E4 error variants carry section context" {
  require_supported_feature(
    false,
    section="9",
    path="/SignatureTime",
    reason="recognized but not implemented",
  ) catch {
    UnsupportedFeature(section="9", path="/SignatureTime", reason=_reason) => ()
    _ => fail("expected UnsupportedFeature")
  }
  require_resource(
    false,
    section="9",
    path="/Thumbnail",
    target="/docProps/thumbnail.jpeg",
  ) catch {
    ResourceMissing(section="9", path="/Thumbnail", target=_target) => ()
    _ => fail("expected ResourceMissing")
  }
}

///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn bytes_equal(a : Bytes, b : Bytes) -> Bool {
  if a.length() != b.length() {
    false
  } else {
    let mut ok = true
    for i in 0..<a.length() {
      if a[i] != b[i] {
        ok = false
      }
    }
    ok
  }
}
