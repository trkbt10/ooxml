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
test "signature element round trip identity" {
  let xml = ds_payload("Signature", " Id=\"sig1\"", "<ds:Object Id=\"obj1\"/>")
  let parsed = try! read_signature(xml)
  assert_true(parsed.id == Some("sig1"))
  assert_true(write_signature(parsed) == xml)
}

///|
test "signed info element round trip identity" {
  let xml = ds_payload(
    "SignedInfo", " Id=\"si1\"", "<ds:CanonicalizationMethod Algorithm=\"urn:c14n\"/>",
  )
  let parsed = try! read_signed_info(xml)
  assert_true(parsed.id == Some("si1"))
  assert_true(write_signed_info(parsed) == xml)
}

///|
test "canonicalization method element round trip identity" {
  let xml = ds_empty("CanonicalizationMethod", " Algorithm=\"urn:c14n\"")
  let parsed = try! read_canonicalization_method(xml)
  assert_true(parsed.algorithm == "urn:c14n")
  assert_true(write_canonicalization_method(parsed) == xml)
}

///|
test "signature method element round trip identity" {
  let xml = ds_empty("SignatureMethod", " Algorithm=\"urn:rsa-sha256\"")
  let parsed = try! read_signature_method(xml)
  assert_true(parsed.algorithm == "urn:rsa-sha256")
  assert_true(write_signature_method(parsed) == xml)
}

///|
test "reference element round trip identity" {
  let xml = ds_payload(
    "Reference", " Id=\"ref1\" Type=\"urn:type\" URI=\"#obj1\"", "<ds:Transforms><ds:Transform Algorithm=\"urn:transform\"/></ds:Transforms>",
  )
  let parsed = try! read_reference(xml)
  assert_true(parsed.id == Some("ref1"))
  assert_true(parsed.type_ == Some("urn:type"))
  assert_true(parsed.uri == Some("#obj1"))
  assert_true(write_reference(parsed) == xml)
}

///|
test "transform element round trip identity" {
  let xml = ds_payload(
    "Transform", " Algorithm=\"urn:transform\"", "<ds:XPath Id=\"xp1\">/</ds:XPath>",
  )
  let parsed = try! read_transform(xml)
  assert_true(parsed.algorithm == "urn:transform")
  assert_true(write_transform(parsed) == xml)
}

///|
test "digest method element round trip identity" {
  let xml = ds_empty("DigestMethod", " Algorithm=\"urn:sha256\"")
  let parsed = try! read_digest_method(xml)
  assert_true(parsed.algorithm == "urn:sha256")
  assert_true(write_digest_method(parsed) == xml)
}

///|
test "object element round trip identity" {
  let xml = ds_payload(
    "Object", " Id=\"obj1\"", "<ds:Manifest Id=\"manifest1\"/>",
  )
  let parsed = try! read_object(xml)
  assert_true(parsed.id == Some("obj1"))
  assert_true(write_object(parsed) == xml)
}

///|
test "manifest element round trip identity" {
  let xml = ds_payload(
    "Manifest", " Id=\"manifest1\"", "<ds:Reference URI=\"#obj1\"/>",
  )
  let parsed = try! read_manifest(xml)
  assert_true(parsed.id == Some("manifest1"))
  assert_true(write_manifest(parsed) == xml)
}

///|
test "signature property element round trip identity" {
  let xml = ds_payload(
    "SignatureProperty", " Id=\"prop1\" Target=\"#sig1\"", "<ds:XPath Id=\"xp1\">/</ds:XPath>",
  )
  let parsed = try! read_signature_property(xml)
  assert_true(parsed.id == Some("prop1"))
  assert_true(parsed.target == "#sig1")
  assert_true(write_signature_property(parsed) == xml)
}

///|
test "xpath element round trip identity" {
  let xml = ds_payload("XPath", " Id=\"xp1\"", "/ds:Signature")
  let parsed = try! read_xpath(xml)
  assert_true(parsed.id == Some("xp1"))
  assert_true(write_xpath(parsed) == xml)
}

///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn ds_payload(name : String, attrs : String, body : String) -> Bytes {
  b(
    "<ds:" +
    name +
    " xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"" +
    attrs +
    ">" +
    body +
    "</ds:" +
    name +
    ">",
  )
}

///|
fn ds_empty(name : String, attrs : String) -> Bytes {
  b(
    "<ds:" +
    name +
    " xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"" +
    attrs +
    "/>",
  )
}
