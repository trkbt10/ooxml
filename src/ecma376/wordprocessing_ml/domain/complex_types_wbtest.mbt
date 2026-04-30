///|
fn wml_test_element(local_name : String) -> @xml.Element {
  {
    name: {
      prefix: Some("w"),
      local_name,
      ns: Some("http://schemas.openxmlformats.org/wordprocessingml/2006/main"),
    },
    attributes: [],
    children: [],
  }
}

///|
test "WML complex type wrappers preserve source elements" {
  let p = CT_P::parse(wml_test_element("p"))
  assert_eq(p.to_element().name.local_name, "p")
  let r = CT_R::parse(wml_test_element("r"))
  assert_eq(r.to_element().name.local_name, "r")
  let style = CT_String::new(wml_test_element("styleId"))
  assert_eq(style.to_element().name.local_name, "styleId")
}

///|
test "WML schema-tail complex type wrappers preserve source elements" {
  let document = CT_Document::parse(wml_test_element("document"))
  assert_eq(document.to_element().name.local_name, "document")
  let styles = CT_Styles::new(wml_test_element("styles"))
  assert_eq(styles.to_element().name.local_name, "styles")
  let numbering = CT_Numbering::parse(wml_test_element("numbering"))
  assert_eq(numbering.to_element().name.local_name, "numbering")
  let settings = CT_Settings::new(wml_test_element("settings"))
  assert_eq(settings.to_element().name.local_name, "settings")
}
