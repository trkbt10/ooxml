///|
test "ST_Lang validates xsd:language lexical form (BCP-47)" {
  assert_eq((try! ST_Lang::new("en-US")).to_string(), "en-US")
  assert_eq((try! ST_Lang::new("ja")).to_string(), "ja")
  // §22.9.2.6 xsd:language pattern requires a leading letter.
  let empty = try? ST_Lang::new("")
  assert_true(empty is Err(SchemaViolation(_)))
  let digits = try? ST_Lang::new("1234")
  assert_true(digits is Err(SchemaViolation(_)))
}

///|
test "ST_HexColorRGB decodes RGB channels and renders canonical uppercase" {
  let color = try! ST_HexColorRGB::new("A1b2C3")
  assert_eq(color.r(), 0xA1)
  assert_eq(color.g(), 0xB2)
  assert_eq(color.b(), 0xC3)
  // Canonical lexical form is uppercase six-hex-digit.
  assert_eq(color.to_string(), "A1B2C3")
  let invalid = try? ST_HexColorRGB::new("A1b2CG")
  assert_true(invalid is Err(SchemaViolation(_)))
  let short = try? ST_HexColorRGB::new("A1B2C")
  assert_true(short is Err(SchemaViolation(_)))
}

///|
test "ST_Panose decodes ten classification bytes" {
  let panose = try! ST_Panose::new("00112233445566778899")
  assert_eq(panose.byte_at(0), 0x00)
  assert_eq(panose.byte_at(4), 0x44)
  assert_eq(panose.byte_at(9), 0x99)
  assert_eq(panose.to_string(), "00112233445566778899")
  let short = try? ST_Panose::new("0011223344556677889")
  assert_true(short is Err(SchemaViolation(_)))
}

///|
test "ST_CalendarType validates enumeration" {
  assert_eq(
    (try! ST_CalendarType::new("gregorianUs")).to_string(),
    "gregorianUs",
  )
  assert_true(
    (try! ST_CalendarType::new("gregorianUs")).uses_gregorian_fields(),
  )
  assert_true(!(try! ST_CalendarType::new("hijri")).uses_gregorian_fields())
  let invalid = try? ST_CalendarType::new("lunar")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_Guid decodes 16 raw bytes and renders canonical lexical form" {
  let guid = try! ST_Guid::new("{00112233-4455-6677-8899-AABBCCDDEEFF}")
  assert_eq(guid.byte_at(0), 0x00)
  assert_eq(guid.byte_at(3), 0x33)
  assert_eq(guid.byte_at(4), 0x44)
  assert_eq(guid.byte_at(15), 0xFF)
  assert_eq(guid.to_string(), "{00112233-4455-6677-8899-AABBCCDDEEFF}")
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
  assert_eq(ST_String::new("plain text").to_string(), "plain text")
  assert_eq(ST_String::new("").to_string(), "")
}

///|
test "ST_XmlName validates NCName lexical form" {
  assert_eq((try! ST_XmlName::new("_name-1.2")).to_string(), "_name-1.2")
  assert_eq((try! ST_XmlName::new("名1")).to_string(), "名1")
  let invalid = try? ST_XmlName::new("p:name")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_UnsignedDecimalNumber decodes to UInt64" {
  let v = try! ST_UnsignedDecimalNumber::new("18446744073709551615")
  assert_eq(v.to_uint64(), 18446744073709551615UL)
  assert_eq(v.to_string(), "18446744073709551615")
  let small = try! ST_UnsignedDecimalNumber::new("0")
  assert_eq(small.to_uint64(), 0UL)
  let invalid = try? ST_UnsignedDecimalNumber::new("18446744073709551616")
  assert_true(invalid is Err(SchemaViolation(_)))
  let negative = try? ST_UnsignedDecimalNumber::new("-1")
  assert_true(negative is Err(SchemaViolation(_)))
}

///|
test "ST_TwipsMeasure discriminates twips vs universal measure" {
  let twips = try! ST_TwipsMeasure::new("1440")
  match twips {
    Twips(value) => assert_eq(value, 1440UL)
    _ => assert_true(false)
  }
  assert_eq(twips.to_string(), "1440")
  let measure = try! ST_TwipsMeasure::new("12.5pt")
  match measure {
    Measure(m) => {
      assert_eq(m.value(), 12.5)
      assert_true(m.unit_of() == Point)
    }
    _ => assert_true(false)
  }
  assert_eq(measure.to_string(), "12.5pt")
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
  assert_eq(ST_Xstring::new("_x0041_").to_string(), "_x0041_")
  assert_eq(ST_Xstring::new("").to_string(), "")
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
test "ST_UniversalMeasure decodes signed magnitude + unit" {
  let m = try! ST_UniversalMeasure::new("-12.5mm")
  assert_eq(m.value(), -12.5)
  assert_true(m.unit_of() == Millimetre)
  assert_eq(m.to_string(), "-12.5mm")
  let invalid = try? ST_UniversalMeasure::new("12px")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_PositiveUniversalMeasure rejects negative magnitudes" {
  let m = try! ST_PositiveUniversalMeasure::new("0cm")
  assert_eq(m.value(), 0.0)
  assert_true(m.unit_of() == Centimetre)
  assert_eq(m.to_string(), "0cm")
  let invalid = try? ST_PositiveUniversalMeasure::new("-0.1cm")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_Percentage decodes signed decimal percent at 1000ths precision" {
  let p = try! ST_Percentage::new("-12.5%")
  assert_eq(p.thousandths_of_percent(), -12500L)
  assert_eq(p.to_string(), "-12.5%")
  let zero = try! ST_Percentage::new("0%")
  assert_eq(zero.thousandths_of_percent(), 0L)
  assert_eq(zero.to_string(), "0%")
  let invalid = try? ST_Percentage::new("12.5")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_FixedPercentage validates signed range [-100, 100]" {
  let p = try! ST_FixedPercentage::new("-100.0%")
  assert_eq(p.thousandths_of_percent(), -100000L)
  assert_eq(p.to_string(), "-100%")
  let invalid = try? ST_FixedPercentage::new("100.1%")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_PositivePercentage rejects negative values" {
  let p = try! ST_PositivePercentage::new("12.5%")
  assert_eq(p.thousandths_of_percent(), 12500L)
  assert_eq(p.to_string(), "12.5%")
  let invalid = try? ST_PositivePercentage::new("-0.1%")
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
test "ST_PositiveFixedPercentage validates non-negative fixed range" {
  let p = try! ST_PositiveFixedPercentage::new("100%")
  assert_eq(p.thousandths_of_percent(), 100000L)
  assert_eq(p.to_string(), "100%")
  let invalid = try? ST_PositiveFixedPercentage::new("-1%")
  assert_true(invalid is Err(SchemaViolation(_)))
  let too_high = try? ST_PositiveFixedPercentage::new("100.1%")
  assert_true(too_high is Err(SchemaViolation(_)))
}
