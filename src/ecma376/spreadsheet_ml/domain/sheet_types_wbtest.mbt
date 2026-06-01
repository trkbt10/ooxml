// Tests for §18.3 worksheet typed model.

///|
fn sheet_attr_test(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name, ns: None }, value }
}

///|
fn sheet_elem_test(
  local_name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  {
    name: {
      prefix: None,
      local_name,
      ns: Some("http://schemas.openxmlformats.org/spreadsheetml/2006/main"),
    },
    attributes: attrs,
    children,
  }
}

///|
fn data_validation_for_test(attrs : Array[@xml.Attribute]) -> @xml.Element {
  sheet_elem_test("dataValidation", attrs, [])
}

///|
test "§18.3.1.32 CT_DataValidation validates ST attributes and keeps defaults" {
  let explicit = try! CT_DataValidation::new(
    data_validation_for_test([
      sheet_attr_test("type", "list"),
      sheet_attr_test("errorStyle", "warning"),
      sheet_attr_test("imeMode", "hiragana"),
      sheet_attr_test("operator", "notBetween"),
      sheet_attr_test("sqref", "A1"),
    ]),
  )
  assert_eq(explicit.type_, "list")
  assert_eq(explicit.error_style, "warning")
  assert_eq(explicit.ime_mode, "hiragana")
  assert_eq(explicit.operator, "notBetween")
  let defaulted = try! CT_DataValidation::new(
    data_validation_for_test([sheet_attr_test("sqref", "A1")]),
  )
  assert_eq(defaulted.type_, "none")
  assert_eq(defaulted.error_style, "stop")
  assert_eq(defaulted.ime_mode, "noControl")
  assert_eq(defaulted.operator, "between")
}

///|
test "§18.3.1.32 CT_DataValidation rejects invalid ST attributes" {
  assert_true(
    (try? CT_DataValidation::new(
      data_validation_for_test([
        sheet_attr_test("type", "notAValidationType"),
        sheet_attr_test("sqref", "A1"),
      ]),
    ))
    is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? CT_DataValidation::new(
      data_validation_for_test([
        sheet_attr_test("errorStyle", "loud"),
        sheet_attr_test("sqref", "A1"),
      ]),
    ))
    is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? CT_DataValidation::new(
      data_validation_for_test([
        sheet_attr_test("imeMode", "emoji"),
        sheet_attr_test("sqref", "A1"),
      ]),
    ))
    is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? CT_DataValidation::new(
      data_validation_for_test([
        sheet_attr_test("operator", "roughlyEqual"),
        sheet_attr_test("sqref", "A1"),
      ]),
    ))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
test "§18.3.1.33 CT_DataValidations propagates child schema violations" {
  let container = sheet_elem_test("dataValidations", [], [
    @xml.Node::Element(
      data_validation_for_test([
        sheet_attr_test("type", "whole"),
        sheet_attr_test("operator", "roughlyEqual"),
        sheet_attr_test("sqref", "A1"),
      ]),
    ),
  ])
  assert_true(
    (try? CT_DataValidations::new(container))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}
