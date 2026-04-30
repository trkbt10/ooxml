///|
test "WML simple types parse and format lexical values" {
  assert_eq((try! ST_LongHexNumber::parse("00A1B2C3")).to_string(), "00A1B2C3")
  assert_eq((try! ST_DecimalNumber::parse("42")).to_string(), "42")
  assert_eq(
    (try! ST_DateTime::parse("2026-05-01T00:00:00Z")).to_string(),
    "2026-05-01T00:00:00Z",
  )
}

///|
test "WML enumeration simple types reject unknown values" {
  assert_eq((try! ST_Underline::parse("single")).to_string(), "single")
  assert_true(
    (try? ST_Underline::parse("underline")) is Err(SchemaViolation(_)),
  )
  assert_eq((try! ST_NumberFormat::parse("decimal")).to_string(), "decimal")
  assert_true(
    (try? ST_NumberFormat::parse("arabicDecimal")) is Err(SchemaViolation(_)),
  )
}

///|
test "WML simple types reject empty lexical values" {
  assert_true((try? ST_MacroName::parse("")) is Err(SchemaViolation(_)))
  assert_true((try? ST_HighlightColor::parse("")) is Err(SchemaViolation(_)))
}
