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
fn wml_test_element_with_val(local_name : String, val : String) -> @xml.Element {
  {
    name: {
      prefix: Some("w"),
      local_name,
      ns: Some("http://schemas.openxmlformats.org/wordprocessingml/2006/main"),
    },
    attributes: [
      {
        name: {
          prefix: Some("w"),
          local_name: "val",
          ns: Some(
            "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
          ),
        },
        value: val,
      },
    ],
    children: [],
  }
}

///|
test "WML complex type wrappers preserve source elements" {
  let p = try! CT_P::parse(wml_test_element("p"))
  assert_eq(p.to_element().name.local_name, "p")
  let r = CT_R::parse(wml_test_element("r"))
  assert_eq(r.to_element().name.local_name, "r")
  let style = try! CT_String::new(
    wml_test_element_with_val("styleId", "Heading1"),
  )
  assert_eq(style.to_element().name.local_name, "styleId")
  assert_eq(style.val, "Heading1")
}

///|
test "WML schema-tail complex type wrappers preserve source elements" {
  let document = CT_Document::parse(wml_test_element("document"))
  assert_eq(document.to_element().name.local_name, "document")
  let styles = CT_Styles::new(wml_test_element("styles"))
  assert_eq(styles.to_element().name.local_name, "styles")
  let numbering = try! CT_Numbering::parse(wml_test_element("numbering"))
  assert_eq(numbering.to_element().name.local_name, "numbering")
  let settings = CT_Settings::new(wml_test_element("settings"))
  assert_eq(settings.to_element().name.local_name, "settings")
}

///|
test "VML wordprocessingDrawing CT_AnchorLock and CT_Wrap preserve source elements" {
  let anchor_lock = CT_AnchorLock::parse(wml_test_element("anchorlock"))
  assert_eq(anchor_lock.to_element().name.local_name, "anchorlock")
  let wrap = CT_Wrap::parse(wml_test_element("wrap"))
  assert_eq(wrap.to_element().name.local_name, "wrap")
}
