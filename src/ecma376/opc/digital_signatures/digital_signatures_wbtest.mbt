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
/// FIPS 180-4 SHA-512 verified against the NIST published vectors for the
/// one-byte, empty, and two-block messages.
test "sha512 matches NIST vectors" {
  assert_eq(
    sha512_hex(b("abc")),
    "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f",
  )
  assert_eq(
    sha512_hex(b("")),
    "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e",
  )
  // 112-byte message → two 1024-bit blocks, exercising the multi-block path.
  assert_eq(
    sha512_hex(
      b(
        "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
      ),
    ),
    "8e959b75dae313da8cf4f72814fc143f8f7779c6eb9f7fa17299aeadb6889018501d289e4900f7e4331b99dec4b5433ac7d329eeb6dd26545e96e55b874be909",
  )
}

///|
/// FIPS 180-4 SHA-384 verified against the NIST published vectors.
test "sha384 matches NIST vectors" {
  assert_eq(
    sha384_hex(b("abc")),
    "cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7",
  )
  assert_eq(
    sha384_hex(b("")),
    "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b",
  )
}

///|
/// The Reference digest dispatch routes each registered algorithm URI to the
/// matching hash and rejects anything outside the registry.
test "digest reference honours the SHA-1/256/384/512 registry" {
  let payload = b("the quick brown fox")
  assert_eq(
    try! digest_reference_bytes(
      payload,
      DigestMethod::new("http://www.w3.org/2000/09/xmldsig#sha1", []),
    ),
    @base64.encode(@crypto.sha1(payload).unsafe_reinterpret_as_bytes()[:]),
  )
  assert_eq(
    try! digest_reference_bytes(
      payload,
      DigestMethod::new("http://www.w3.org/2001/04/xmlenc#sha256", []),
    ),
    @base64.encode(@crypto.sha256(payload).unsafe_reinterpret_as_bytes()[:]),
  )
  assert_eq(
    try! digest_reference_bytes(
      payload,
      DigestMethod::new("http://www.w3.org/2001/04/xmldsig-more#sha384", []),
    ),
    @base64.encode(sha384_bytes(payload).unsafe_reinterpret_as_bytes()[:]),
  )
  assert_eq(
    try! digest_reference_bytes(
      payload,
      DigestMethod::new("http://www.w3.org/2001/04/xmlenc#sha512", []),
    ),
    @base64.encode(sha512_bytes(payload).unsafe_reinterpret_as_bytes()[:]),
  )
  // An identifier outside the registry is a conformant rejection.
  let unsupported = try? digest_reference_bytes(
    payload,
    DigestMethod::new("http://www.w3.org/2001/04/xmlenc#ripemd160", []),
  )
  assert_true(unsupported is Err(_))
}

///|
/// `apply_transforms` recognises the comment-retaining C14N variant; plain
/// C14N still drops comment nodes.
test "c14n with comments transform retains comment nodes" {
  let input = b("<a><!--keep--><b>x</b></a>")
  let with_comments = try! apply_transforms(input, [
    Transform::new(
      "http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments",
      [],
    ),
  ])
  assert_true(decode_utf8(with_comments).contains("<!--keep-->"))
  let without = try! apply_transforms(input, [
    Transform::new("http://www.w3.org/TR/2001/REC-xml-c14n-20010315", []),
  ])
  assert_true(!decode_utf8(without).contains("<!--keep-->"))
}

///|
/// The base64 transform concatenates the element text (ignoring the line
/// breaks XML tools insert) and decodes it to the original octets.
test "base64 transform decodes wrapped payload" {
  // base64("OOXML") == "T09YTUw=", here split across lines inside an element.
  let input = b("<Object>\n  T09Y\n  TUw=\n</Object>")
  let decoded = try! apply_transforms(input, [
    Transform::new("http://www.w3.org/2000/09/xmldsig#base64", []),
  ])
  assert_eq(decode_utf8(decoded), "OOXML")
}

///|
fn decode_utf8(bytes : Bytes) -> String {
  @utf8.decode(bytes[:]) catch {
    _ => ""
  }
}

///|
fn sha512_hex(input : Bytes) -> String {
  bytes_to_lower_hex(sha512_bytes(input))
}

///|
fn sha384_hex(input : Bytes) -> String {
  bytes_to_lower_hex(sha384_bytes(input))
}

///|
fn bytes_to_lower_hex(bytes : FixedArray[Byte]) -> String {
  let digits = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
  ]
  let out = StringBuilder::new()
  for byte in bytes {
    let value = byte.to_int()
    out.write_char(digits[value >> 4])
    out.write_char(digits[value & 0xF])
  }
  out.to_string()
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
