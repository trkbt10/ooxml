///|
test "ST_Lang accepts xsd:string values" {
  assert_eq((try! ST_Lang::new("en-US")).to_string(), "en-US")
  assert_eq((try! ST_Lang::new("")).to_string(), "")
}

///|
test "ST_HexColorRGB validates fixed hex length" {
  assert_eq((try! ST_HexColorRGB::new("A1b2C3")).to_string(), "A1b2C3")
  let invalid = try? ST_HexColorRGB::new("A1b2CG")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_Panose validates fixed hex length" {
  assert_eq(
    (try! ST_Panose::new("00112233445566778899")).to_string(),
    "00112233445566778899",
  )
  let invalid = try? ST_Panose::new("0011223344556677889")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_CalendarType validates enumeration" {
  assert_eq(
    (try! ST_CalendarType::new("gregorianUs")).to_string(),
    "gregorianUs",
  )
  let invalid = try? ST_CalendarType::new("lunar")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_Guid validates brace-delimited hexadecimal UUID" {
  assert_eq(
    (try! ST_Guid::new("{00112233-4455-6677-8899-AABBCCDDEEFF}")).to_string(),
    "{00112233-4455-6677-8899-AABBCCDDEEFF}",
  )
  let invalid = try? ST_Guid::new("00112233-4455-6677-8899-AABBCCDDEEFF")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_OnOff parses schema boolean spellings" {
  assert_eq((try! ST_OnOff::new("on")).to_string(), "true")
  assert_true(!(try! ST_OnOff::new("0")).to_bool())
  let invalid = try? ST_OnOff::new("yes")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_String accepts xsd:string values" {
  assert_eq((try! ST_String::new("plain text")).to_string(), "plain text")
  assert_eq((try! ST_String::new("")).to_string(), "")
}

///|
test "ST_XmlName validates NCName lexical form" {
  assert_eq((try! ST_XmlName::new("_name-1.2")).to_string(), "_name-1.2")
  let invalid = try? ST_XmlName::new("p:name")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_UnsignedDecimalNumber validates unsignedLong range" {
  assert_eq(
    (try! ST_UnsignedDecimalNumber::new("18446744073709551615")).to_string(),
    "18446744073709551615",
  )
  let invalid = try? ST_UnsignedDecimalNumber::new("18446744073709551616")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_TwipsMeasure accepts unsigned decimals or positive universal measures" {
  assert_eq((try! ST_TwipsMeasure::new("1440")).to_string(), "1440")
  assert_eq((try! ST_TwipsMeasure::new("12.5pt")).to_string(), "12.5pt")
  let invalid = try? ST_TwipsMeasure::new("-1pt")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_VerticalAlignRun validates enumeration" {
  assert_eq(
    (try! ST_VerticalAlignRun::new("superscript")).to_string(),
    "superscript",
  )
  let invalid = try? ST_VerticalAlignRun::new("middle")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_Xstring accepts xsd:string values" {
  assert_eq((try! ST_Xstring::new("_x0041_")).to_string(), "_x0041_")
  assert_eq((try! ST_Xstring::new("")).to_string(), "")
}

///|
test "ST_XAlign validates enumeration" {
  assert_eq((try! ST_XAlign::new("inside")).to_string(), "inside")
  let invalid = try? ST_XAlign::new("top")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_YAlign validates enumeration" {
  assert_eq((try! ST_YAlign::new("bottom")).to_string(), "bottom")
  let invalid = try? ST_YAlign::new("left")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_ConformanceClass validates enumeration" {
  assert_eq((try! ST_ConformanceClass::new("strict")).to_string(), "strict")
  let invalid = try? ST_ConformanceClass::new("extended")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_UniversalMeasure validates signed decimal measures" {
  assert_eq((try! ST_UniversalMeasure::new("-12.5mm")).to_string(), "-12.5mm")
  let invalid = try? ST_UniversalMeasure::new("12px")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_PositiveUniversalMeasure rejects negative measures" {
  assert_eq((try! ST_PositiveUniversalMeasure::new("0cm")).to_string(), "0cm")
  let invalid = try? ST_PositiveUniversalMeasure::new("-0.1cm")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_Percentage validates signed decimal percent" {
  assert_eq((try! ST_Percentage::new("-12.5%")).to_string(), "-12.5%")
  let invalid = try? ST_Percentage::new("12.5")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_FixedPercentage validates signed range" {
  assert_eq((try! ST_FixedPercentage::new("-100.0%")).to_string(), "-100.0%")
  let invalid = try? ST_FixedPercentage::new("100.1%")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_PositivePercentage rejects negative values" {
  assert_eq((try! ST_PositivePercentage::new("12.5%")).to_string(), "12.5%")
  let invalid = try? ST_PositivePercentage::new("-0.1%")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_PositiveFixedPercentage validates non-negative fixed range" {
  assert_eq((try! ST_PositiveFixedPercentage::new("100%")).to_string(), "100%")
  let invalid = try? ST_PositiveFixedPercentage::new("-1%")
  assert_true(invalid is Err(SchemaViolation(_)))
}
