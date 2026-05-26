///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parse_element(source : String) -> @xml.Element raise {
  @xml.parse(bytes(source)).root
}

///|
test "CT_Border accepts valid attributes" {
  let element = parse_element(
    "<w10:bordertop xmlns:w10=\"urn:schemas-microsoft-com:office:word\" type=\"single\" width=\"4\" shadow=\"t\"/>",
  )
  let value = CT_Border::new(element)
  assert_string_some(value.type_, "single")
  assert_string_some(value.width, "4")
  assert_string_some(value.shadow, "t")
}

///|
fn assert_string_some(value : String?, expected : String) -> Unit raise {
  match value {
    Some(actual) => assert_eq(actual, expected)
    None => fail("expected Some(" + expected + ")")
  }
}

///|
test "CT_Border rejects enum value outside ST_BorderType" {
  let element = parse_element(
    "<w10:bordertop xmlns:w10=\"urn:schemas-microsoft-com:office:word\" type=\"diamond\"/>",
  )
  try {
    CT_Border::new(element) |> ignore
    fail("expected SchemaViolation for invalid ST_BorderType")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_Border rejects non-positive width" {
  let element = parse_element(
    "<w10:bordertop xmlns:w10=\"urn:schemas-microsoft-com:office:word\" width=\"0\"/>",
  )
  try {
    CT_Border::new(element) |> ignore
    fail("expected SchemaViolation for non-positive width")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_Border rejects unknown attribute" {
  let element = parse_element(
    "<w10:bordertop xmlns:w10=\"urn:schemas-microsoft-com:office:word\" foo=\"bar\"/>",
  )
  try {
    CT_Border::new(element) |> ignore
    fail("expected SchemaViolation for unknown attribute")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_Border rejects element children" {
  let element = parse_element(
    "<w10:bordertop xmlns:w10=\"urn:schemas-microsoft-com:office:word\"><w10:nested/></w10:bordertop>",
  )
  try {
    CT_Border::new(element) |> ignore
    fail("expected SchemaViolation for child element")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_Wrap accepts valid enum attributes" {
  let element = parse_element(
    "<w10:wrap xmlns:w10=\"urn:schemas-microsoft-com:office:word\" type=\"square\" side=\"both\" anchorx=\"margin\" anchory=\"page\"/>",
  )
  let value = CT_Wrap::new(element)
  assert_string_some(value.type_, "square")
  assert_string_some(value.side, "both")
  assert_string_some(value.anchorx, "margin")
  assert_string_some(value.anchory, "page")
}

///|
test "CT_Wrap rejects enum value outside ST_WrapType" {
  let element = parse_element(
    "<w10:wrap xmlns:w10=\"urn:schemas-microsoft-com:office:word\" type=\"diagonal\"/>",
  )
  try {
    CT_Wrap::new(element) |> ignore
    fail("expected SchemaViolation for invalid ST_WrapType")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_AnchorLock accepts empty element" {
  let element = parse_element(
    "<w10:anchorlock xmlns:w10=\"urn:schemas-microsoft-com:office:word\"/>",
  )
  CT_AnchorLock::new(element) |> ignore
}

///|
test "CT_AnchorLock rejects attributes" {
  let element = parse_element(
    "<w10:anchorlock xmlns:w10=\"urn:schemas-microsoft-com:office:word\" foo=\"bar\"/>",
  )
  try {
    CT_AnchorLock::new(element) |> ignore
    fail("expected SchemaViolation for attribute on CT_AnchorLock")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
