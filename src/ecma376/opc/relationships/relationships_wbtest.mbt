///|
test "relationships round trip preserves values" {
  let source = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/><Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink\" Target=\"https://example.com\" TargetMode=\"External\"/></Relationships>",
  )
  let parsed = try! read_relationships(source)
  let reparsed = try! read_relationships(write_relationships(parsed))
  assert_true(reparsed == parsed)
  match parsed.find_by_id("rId2") {
    Some(rel) => assert_eq(rel.target_mode.to_string(), "External")
    None => fail("expected relationship")
  }
}

///|
test "relationships reject schema violations" {
  let invalid_mode = try? read_relationships(
    b(
      "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"t\" Target=\"x\" TargetMode=\"Remote\"/></Relationships>",
    ),
  )
  assert_true(invalid_mode is Err(SchemaViolation(_)))
  let duplicate = try? read_relationships(
    b(
      "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"t\" Target=\"x\"/><Relationship Id=\"rId1\" Type=\"t\" Target=\"y\"/></Relationships>",
    ),
  )
  assert_true(duplicate is Err(SchemaViolation(_)))
}

///|
test "public relationships E3 and E4 errors carry context" {
  require_supported_feature(
    false,
    section="",
    path="/Relationships",
    reason="recognized but not implemented",
  ) catch {
    UnsupportedFeature(section="", path="/Relationships", reason=_reason) => ()
    _ => fail("expected UnsupportedFeature")
  }
  require_resource(
    false,
    section="",
    path="/Relationships/Relationship",
    target="missing.xml",
  ) catch {
    ResourceMissing(
      section="",
      path="/Relationships/Relationship",
      target=_target
    ) => ()
    _ => fail("expected ResourceMissing")
  }
}

///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}
