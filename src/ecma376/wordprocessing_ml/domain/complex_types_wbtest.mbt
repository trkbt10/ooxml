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
fn wml_test_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name, ns: None }, value }
}

///|
fn wml_test_rel_attr(local_name : String, value : String) -> @xml.Attribute {
  {
    name: {
      prefix: Some("r"),
      local_name,
      ns: Some(
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      ),
    },
    value,
  }
}

///|
fn wml_test_element_with_attrs(
  local_name : String,
  attrs : Array[@xml.Attribute],
) -> @xml.Element {
  {
    name: {
      prefix: Some("w"),
      local_name,
      ns: Some("http://schemas.openxmlformats.org/wordprocessingml/2006/main"),
    },
    attributes: attrs,
    children: [],
  }
}

///|
fn wml_test_element_with_children(
  local_name : String,
  children : Array[@xml.Node],
) -> @xml.Element {
  let element = wml_test_element_with_attrs(local_name, [])
  { ..element, children, }
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
  let wrap = try! CT_Wrap::parse(wml_test_element("wrap"))
  assert_eq(wrap.to_element().name.local_name, "wrap")
}

///|
test "WML relationship holders require relationships namespace for r:id" {
  let link = try! CT_Hyperlink::new(
    wml_test_element_with_attrs("hyperlink", [
      wml_test_attr("id", "bareId"),
      wml_test_rel_attr("id", "rIdHyperlink"),
    ]),
  )
  assert_eq(link.r_id, Some("rIdHyperlink"))
  let local_only = try! CT_Hyperlink::new(
    wml_test_element_with_attrs("hyperlink", [wml_test_attr("id", "bareId")]),
  )
  assert_eq(local_only.r_id, None)
  let control = CT_Control::new(
    wml_test_element_with_attrs("control", [
      wml_test_rel_attr("id", "rIdControl"),
    ]),
  )
  assert_eq(control.r_id, Some("rIdControl"))
}

///|
test "WML required relationship holders reject unqualified id" {
  assert_true(
    (try? CT_Rel::new(
      wml_test_element_with_attrs("movie", [wml_test_attr("id", "bareId")]),
    ))
    is Err(SchemaViolation(_)),
  )
  assert_true(
    (try? CT_ObjectEmbed::new(
      wml_test_element_with_attrs("objectEmbed", [wml_test_attr("id", "bareId")]),
    ))
    is Err(SchemaViolation(_)),
  )
  let font_rel = try! CT_FontRel::new(
    wml_test_element_with_attrs("embedRegular", [
      wml_test_rel_attr("id", "rIdFont"),
    ]),
  )
  assert_eq(font_rel.r_id, "rIdFont")
}

///|
test "WML form checkbox checked state is typed domain state" {
  let checked = try! CT_FFCheckBox::new(
    wml_test_element_with_children("checkBox", [
      @xml.Element(
        wml_test_element_with_attrs("checked", [wml_test_attr("val", "1")]),
      ),
    ]),
  )
  assert_true(checked.checked_state())
  let default_checked = try! CT_FFCheckBox::new(
    wml_test_element_with_children("checkBox", [
      @xml.Element(
        wml_test_element_with_attrs("default", [wml_test_attr("val", "true")]),
      ),
    ]),
  )
  assert_true(default_checked.checked_state())
  let unchecked = try! CT_FFCheckBox::new(
    wml_test_element_with_children("checkBox", [
      @xml.Element(
        wml_test_element_with_attrs("checked", [wml_test_attr("val", "0")]),
      ),
    ]),
  )
  assert_true(!unchecked.checked_state())
  let absent = try! CT_FFCheckBox::new(
    wml_test_element_with_attrs("checkBox", []),
  )
  assert_true(!absent.checked_state())
}
