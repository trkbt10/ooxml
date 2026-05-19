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

///|
test "WML chunk2 enumerations map lexical tokens to typed variants" {
  // §17.18.40 highlight-colour enumeration.
  assert_true((try! ST_HighlightColor::parse("darkBlue")) is HlDarkBlue)
  assert_true(
    (try? ST_HighlightColor::parse("teal")) is Err(SchemaViolation(_)),
  )
  // §17.18.44 / §17.18.45 — Jc and JcTable variant prefixing keeps the
  // overlapping `start` / `center` / `end` tokens distinct.
  assert_true((try! ST_Jc::parse("highKashida")) is JcHighKashida)
  assert_true((try! ST_JcTable::parse("start")) is JcTableStart)
  // §17.18.41 — XSD restricts ST_Hint to {default, eastAsia} only.
  assert_true((try! ST_Hint::parse("eastAsia")) is HintEastAsia)
  assert_true((try? ST_Hint::parse("cs")) is Err(SchemaViolation(_)))
  // §17.18.55 — `null` is reserved on MoonBit so the variant name is
  // prefixed.
  assert_true(
    (try! ST_MailMergeOdsoFMDFieldType::parse("null")) is MailMergeOdsoNull,
  )
  // §17.18.59 — every named NumberFormat token round-trips.
  assert_eq(
    (try! ST_NumberFormat::parse("hindiCounting")).to_string(),
    "hindiCounting",
  )
}

///|
test "WML chunk2 union types preserve their branch identity" {
  // §17.18.38 — ST_HexColor union surfaces auto vs RGB as separate
  // variants instead of an undifferentiated string.
  assert_true((try! ST_HexColor::parse("auto")) is HexColorAuto)
  let red = try! ST_HexColor::parse("FF0000")
  assert_true(red is HexColorRgb(255, 0, 0))
  // §17.18.42 — ST_HpsMeasure round-trips a raw half-point integer and
  // a universal measure through the typed discriminator.
  let half = try! ST_HpsMeasure::parse("24")
  assert_true(half is HpsHalfPoints(24UL))
  assert_eq(half.to_string(), "24")
  let measure = try! ST_HpsMeasure::parse("12pt")
  assert_eq(measure.to_string(), "12pt")
  // §17.18.107 — ST_MeasurementOrPercent discriminates percent vs
  // universal-measure branches; percent magnitude is preserved as
  // 1000ths.
  let pct = try! ST_MeasurementOrPercent::parse("12.345%")
  assert_true(pct is MeasOrPctPercent(12345L))
  assert_eq(pct.to_string(), "12.345%")
}

///|
test "WML chunk2 numeric carriers expose typed accessors" {
  // §17.18.50 — ST_LongHexNumber decodes to four typed octets, not a
  // raw lexical string.
  let rsid = try! ST_LongHexNumber::parse("00BE2C6C")
  assert_eq(rsid.byte_at(0), 0x00)
  assert_eq(rsid.byte_at(1), 0xBE)
  assert_eq(rsid.byte_at(2), 0x2C)
  assert_eq(rsid.byte_at(3), 0x6C)
  assert_eq(rsid.to_string(), "00BE2C6C")
  assert_true(
    (try? ST_LongHexNumber::parse("00BE2C")) is Err(SchemaViolation(_)),
  )
  // §17.18.67 / §17.18.68 — measure types expose UInt64 accessors.
  assert_eq((try! ST_PixelsMeasure::parse("96")).to_uint64(), 96UL)
  assert_eq((try! ST_PointMeasure::parse("12")).to_uint64(), 12UL)
  // §17.18.51 — ST_MacroName enforces the maxLength=33 facet.
  assert_true(
    (try? ST_MacroName::parse(
      "ThisMacroNameIsExactlyThirtyFourLong",
    ))
    is Err(SchemaViolation(_)),
  )
  // §17.18.52 — ST_MailMergeDataType accepts any non-empty xsd:string
  // because the XSD imposes no enumeration facet.
  assert_eq(
    (try! ST_MailMergeDataType::parse("custom-provider")).to_string(),
    "custom-provider",
  )
}

///|
test "WML drawing chunk2 types decode positioning anchors" {
  // §20.4.3.3 — ST_PositionOffset stores a typed Int (EMUs).
  let offset = try! ST_PositionOffset::parse("914400")
  assert_eq(offset.to_int(), 914400)
  assert_eq(offset.to_string(), "914400")
  // §20.4.3.4 / §20.4.3.5 — RelFromH / RelFromV enumerations preserve
  // their full eight-value lexical surface.
  assert_true((try! ST_RelFromH::parse("insideMargin")) is RelFromHInsideMargin)
  assert_true(
    (try! ST_RelFromV::parse("outsideMargin")) is RelFromVOutsideMargin,
  )
  assert_true(
    (try? ST_RelFromH::parse("paragraph")) is Err(SchemaViolation(_)),
  )
}
