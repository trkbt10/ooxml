///|
test "signature time round trip identity" {
  let signature_time = SignatureTime::new(
    try! ST_Format::new("YYYY-MM-DDThh:mm:ssTZD"),
    try! ST_Value::new("2026-04-30T00:00:00Z"),
  )
  let parsed = try! read_signature_time(write_signature_time(signature_time))
  assert_true(parsed == signature_time)
}

///|
test "digital signature references round trip identity" {
  let reference = try! RelationshipReference::new("rId5")
  let parsed_reference = try! read_relationship_reference(
    write_relationship_reference(reference),
  )
  assert_true(parsed_reference == reference)
  let group = try! RelationshipsGroupReference::new(
    "http://schemas.openxmlformats.org/officeDocument/2006/relationships/metadata/core-properties",
  )
  let parsed_group = try! read_relationships_group_reference(
    write_relationships_group_reference(group),
  )
  assert_true(parsed_group == group)
}

///|
test "reject missing signature time value" {
  let invalid = try? read_signature_time(
    b(
      "<SignatureTime xmlns=\"http://schemas.openxmlformats.org/package/2006/digital-signature\"><Format>YYYY</Format></SignatureTime>",
    ),
  )
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}
