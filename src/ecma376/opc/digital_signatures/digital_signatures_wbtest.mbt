///|
test "signature time round trip identity" {
  let signature_time = CT_SignatureTime::new(
    try! ST_Format::new("YYYY-MM-DDThh:mm:ssTZD"),
    try! ST_Value::new("2026-04-30T00:00:00Z"),
  )
  let parsed = try! read_signature_time(write_signature_time(signature_time))
  assert_true(parsed == signature_time)
}

///|
test "digital signature references round trip identity" {
  let reference = try! CT_RelationshipReference::new("rId5")
  let parsed_reference = try! read_relationship_reference(
    write_relationship_reference(reference),
  )
  assert_true(parsed_reference == reference)
  let group = try! CT_RelationshipsGroupReference::new(
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
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
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
test "relationships transform canonicalizes and sorts relationships" {
  let source = relationships_xml([
    "<Relationship Id=\"rId3\" Type=\"type-c\" Target=\"c.xml\" TargetMode=\"External\"/>",
    "<Relationship Id=\"rId1\" Type=\"type-a\" Target=\"a.xml\"/>", "<Relationship Id=\"rId2\" Type=\"type-b\" Target=\"b.xml\" TargetMode=\"Internal\"/>",
  ])
  let expected = b(
    "<Relationship xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\" Id=\"rId1\" Type=\"type-a\" Target=\"a.xml\"></Relationship>" +
    "<Relationship Id=\"rId2\" Type=\"type-b\" Target=\"b.xml\"></Relationship>" +
    "<Relationship Id=\"rId3\" Type=\"type-c\" Target=\"c.xml\" TargetMode=\"External\"></Relationship>",
  )
  assert_eq(try! apply_relationships_transform(source, None), expected)
}

///|
test "relationships transform applies source id filter" {
  let source = relationships_xml([
    "<Relationship Id=\"rId1\" Type=\"type-a\" Target=\"a.xml\"/>", "<Relationship Id=\"rId2\" Type=\"type-b\" Target=\"b.xml\"/>",
    "<Relationship Id=\"rId3\" Type=\"type-c\" Target=\"c.xml\"/>",
  ])
  assert_eq(
    try! apply_relationships_transform(source, Some(["rId2"])),
    b(
      "<Relationship xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\" Id=\"rId2\" Type=\"type-b\" Target=\"b.xml\"></Relationship>",
    ),
  )
}

///|
test "relationships transform returns empty bytes for empty filter" {
  let source = relationships_xml([
    "<Relationship Id=\"rId1\" Type=\"type-a\" Target=\"a.xml\"/>",
  ])
  assert_eq(try! apply_relationships_transform(source, Some([])), b(""))
}

///|
test "generate signature populates digest and signs canonical signed info" {
  let signed_info = sample_signed_info(with_relationship_transform=false)
  let signature = try! generate_signature(
    signed_info,
    fn(_uri) { b("<Payload z=\"2\" a=\"1\">text</Payload>") },
    hmac_sha256_sign,
  )
  let generated_signed_info = try! signature_signed_info(signature)
  let expected_signature = @base64.encode(
    hmac_sha256_sign(
      try! canonicalize_xml(write_signed_info(generated_signed_info)),
    )[:],
  )
  assert_eq(signature_value_text(signature), expected_signature)
}

///|
test "generate signature applies relationships transform before digest" {
  let signed_info = sample_signed_info(with_relationship_transform=true)
  let relationships = relationships_xml([
    "<Relationship Id=\"rId1\" Type=\"type-a\" Target=\"a.xml\"/>", "<Relationship Id=\"rId2\" Type=\"type-b\" Target=\"b.xml\" TargetMode=\"External\"/>",
  ])
  let signature = try! generate_signature(
    signed_info,
    fn(_uri) { relationships },
    hmac_sha256_sign,
  )
  let generated_signed_info = try! signature_signed_info(signature)
  let references = try! signed_info_references(generated_signed_info)
  let canonical_relationships = try! apply_relationships_transform(
    relationships,
    Some(["rId2"]),
  )
  let expected_digest = @base64.encode(
    @crypto.sha256(canonical_relationships).unsafe_reinterpret_as_bytes()[:],
  )
  assert_true(
    reference_digest_value(references[0].reference) == Some(expected_digest),
  )
}

///|
test "validate signature accepts generated signature round trip" {
  let signature = try! generate_signature(
    sample_signed_info(with_relationship_transform=false),
    fn(_uri) { b("<Payload z=\"2\" a=\"1\">text</Payload>") },
    hmac_sha256_sign,
  )
  assert_true(
    try! validate_signature(
      signature,
      fn(_uri) { b("<Payload z=\"2\" a=\"1\">text</Payload>") },
      hmac_sha256_verify,
    ),
  )
}

///|
test "validate signature rejects mutated signed info" {
  let signature = try! generate_signature(
    sample_signed_info(with_relationship_transform=false),
    fn(_uri) { b("<Payload z=\"2\" a=\"1\">text</Payload>") },
    hmac_sha256_sign,
  )
  let mutated = mutate_signed_info_id(signature)
  let valid = try! validate_signature(
    mutated,
    fn(_uri) { b("<Payload z=\"2\" a=\"1\">text</Payload>") },
    hmac_sha256_verify,
  )
  assert_true(!valid)
}

///|
test "validate signature rejects mutated reference source bytes" {
  let signature = try! generate_signature(
    sample_signed_info(with_relationship_transform=false),
    fn(_uri) { b("<Payload z=\"2\" a=\"1\">text</Payload>") },
    hmac_sha256_sign,
  )
  let valid = try! validate_signature(
    signature,
    fn(_uri) { b("<Payload z=\"3\" a=\"1\">text</Payload>") },
    hmac_sha256_verify,
  )
  assert_true(!valid)
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

///|
fn relationships_xml(children : Array[String]) -> Bytes {
  let out = StringBuilder::new()
  out.write_string(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">",
  )
  for child in children {
    out.write_string(child)
  }
  out.write_string("</Relationships>")
  b(out.to_string())
}

///|
fn sample_signed_info(with_relationship_transform~ : Bool) -> SignedInfo {
  let transform_children : Array[@xml.Node] = if with_relationship_transform {
    [
      Element({
        name: {
          prefix: Some("mdssi"),
          local_name: "RelationshipReference",
          ns: Some(digital_signature_namespace()),
        },
        attributes: [
          {
            name: { prefix: None, local_name: "SourceId", ns: None },
            value: "rId2",
          },
        ],
        children: [],
      }),
    ]
  } else {
    []
  }
  let transform_algorithm = if with_relationship_transform {
    relationship_transform_algorithm()
  } else {
    c14n_algorithm()
  }
  SignedInfo::new(None, [
    Element({
      name: xmldsig_test_name("CanonicalizationMethod"),
      attributes: [xmldsig_test_attribute("Algorithm", c14n_algorithm())],
      children: [],
    }),
    Element({
      name: xmldsig_test_name("SignatureMethod"),
      attributes: [xmldsig_test_attribute("Algorithm", "urn:test:hmac-sha256")],
      children: [],
    }),
    Element({
      name: xmldsig_test_name("Reference"),
      attributes: [xmldsig_test_attribute("URI", "/payload.xml")],
      children: [
        Element({
          name: xmldsig_test_name("Transforms"),
          attributes: [],
          children: [
            Element({
              name: xmldsig_test_name("Transform"),
              attributes: [
                xmldsig_test_attribute("Algorithm", transform_algorithm),
              ],
              children: transform_children,
            }),
          ],
        }),
        Element({
          name: xmldsig_test_name("DigestMethod"),
          attributes: [xmldsig_test_attribute("Algorithm", sha256_algorithm())],
          children: [],
        }),
      ],
    }),
  ])
}

///|
fn hmac_sha256_sign(canonical_signed_info : Bytes) -> Bytes {
  Bytes::from_array(
    @crypto.hmac(@crypto.SHA256::new(), b("key")[:], canonical_signed_info[:])[:],
  )
}

///|
fn hmac_sha256_verify(
  canonical_signed_info : Bytes,
  signature_value : Bytes,
) -> Bool {
  hmac_sha256_sign(canonical_signed_info) == signature_value
}

///|
fn signature_value_text(signature : Signature) -> String {
  for child in signature.children {
    if child is Element(element) && element.name.local_name == "SignatureValue" {
      return element_text_for_algorithm(element)
    }
  }
  ""
}

///|
fn mutate_signed_info_id(signature : Signature) -> Signature {
  let children : Array[@xml.Node] = []
  for child in signature.children {
    if child is Element(element) && element.name.local_name == "SignedInfo" {
      children.push(
        Element({
          name: element.name,
          attributes: [xmldsig_test_attribute("Id", "mutated")],
          children: element.children,
        }),
      )
    } else {
      children.push(child)
    }
  }
  Signature::new(signature.id, children)
}

///|
fn xmldsig_test_name(local_name : String) -> @xml.QName {
  {
    prefix: Some("ds"),
    local_name,
    ns: Some(xmldsig_namespace_for_algorithm()),
  }
}

///|
fn xmldsig_test_attribute(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name: name, ns: None }, value }
}
