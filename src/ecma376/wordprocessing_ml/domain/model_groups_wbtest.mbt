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
fn wml_proof_err_element() -> @xml.Element {
  {
    name: {
      prefix: Some("w"),
      local_name: "proofErr",
      ns: Some("http://schemas.openxmlformats.org/wordprocessingml/2006/main"),
    },
    attributes: [
      {
        name: {
          prefix: Some("w"),
          local_name: "type",
          ns: Some(
            "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
          ),
        },
        value: "gramStart",
      },
    ],
    children: [],
  }
}

///|
test "WML EG_PContent typed projection of <w:r> children" {
  let elements = [wml_test_element("r"), wml_proof_err_element()]
  let typed = collect_pcontent(elements)
  assert_eq(typed.length(), 2)
  match typed[0] {
    RunContent(R(_)) => assert_true(true)
    _ => fail("expected RunContent(R(_)) for first child")
  }
  match typed[1] {
    RunContent(RunLevel(ProofErr(_))) => assert_true(true)
    _ => fail("expected RunContent(RunLevel(ProofErr(_))) for second child")
  }
}

///|
test "WML attribute group holders expose attribute names" {
  let group = AG_Password::new(wml_attr_test_element("writeProtection"))
  assert_true(group.has_attribute("val"))
  assert_eq(group.attribute_names()[0], "val")
  let sect = AG_SectPrAttributes::new(wml_attr_test_element("sectPr"))
  assert_true(sect.has_attribute("val"))
}
