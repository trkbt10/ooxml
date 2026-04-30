///|
fn wml_attr_test_element(local_name : String) -> @xml.Element {
  {
    name: { prefix: Some("w"), local_name, ns: Some("urn:w") },
    attributes: [
      {
        name: { prefix: Some("w"), local_name: "val", ns: Some("urn:w") },
        value: "1",
      },
    ],
    children: [],
  }
}

///|
test "WML model group holders expose member names" {
  let group = EG_PContent::new([
    wml_test_element("r"),
    wml_test_element("proofErr"),
  ])
  assert_eq(group.count(), 2)
  assert_true(group.contains("r"))
  assert_eq(group.member_names()[0], "r")
}

///|
test "WML attribute group holders expose attribute names" {
  let group = AG_Password::new(wml_attr_test_element("writeProtection"))
  assert_true(group.has_attribute("val"))
  assert_eq(group.attribute_names()[0], "val")
  let sect = AG_SectPrAttributes::new(wml_attr_test_element("sectPr"))
  assert_true(sect.has_attribute("val"))
}
