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
