///|
test "part name validation and zip item" {
  let name = try! PartName::parse("/docProps/core.xml")
  inspect(name.zip_item_name(), content="docProps/core.xml")
  let invalid = try? PartName::parse("docProps/core.xml")
  assert_true(
    invalid
    is Err(
      PartError::SchemaViolation(
        section="9",
        path="PartName",
        reason="part name must start with /"
      )
    ),
  )
}

///|
test "signature time round trip" {
  let signature_time = SignatureTime::new(
    try! SignatureTimeFormat::new("YYYY-MM-DDThh:mm:ssTZD"),
    try! SignatureTimeValue::new("2026-04-30T00:00:00Z"),
  )
  let parsed = try! read_signature_time(write_signature_time(signature_time))
  inspect(parsed.value.value, content="2026-04-30T00:00:00Z")
}
