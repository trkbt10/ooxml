///|
test "chart simple type parse and format" {
  assert_eq(ST_LayoutTarget::parse("inner").to_string(), "inner")
  assert_eq(ST_BarDir::parse("col").to_string(), "col")
  assert_true((try? ST_BarDir::parse("sideways")) is Err(SchemaViolation(_)))
  assert_eq(ST_RotX::parse("45").to_string(), "45")
  assert_true((try? ST_RotX::parse("north")) is Err(SchemaViolation(_)))
}

///|
test "chart numeric simple types expose typed integer accessors" {
  // §21.2.3.38 ST_RotX — xsd:byte restricted to -90..90.
  let neg = ST_RotX::parse("-30")
  assert_eq(neg.degrees(), -30)
  assert_eq(neg.to_string(), "-30")
  assert_true((try? ST_RotX::parse("91")) is Err(SchemaViolation(_)))
  assert_true((try? ST_RotX::parse("-91")) is Err(SchemaViolation(_)))

  // §21.2.3.39 ST_RotY — xsd:unsignedShort restricted to 0..360.
  let roty = ST_RotY::parse("180")
  assert_eq(roty.degrees(), 180)
  assert_true((try? ST_RotY::parse("361")) is Err(SchemaViolation(_)))

  // §21.2.3.26 ST_MarkerSize — xsd:unsignedByte 2..72.
  assert_eq(ST_MarkerSize::parse("7").points(), 7)
  assert_true((try? ST_MarkerSize::parse("1")) is Err(SchemaViolation(_)))
  assert_true((try? ST_MarkerSize::parse("73")) is Err(SchemaViolation(_)))

  // §21.2.3.29 ST_Order — xsd:unsignedByte 2..6.
  assert_eq(ST_Order::parse("4").value(), 4)
  assert_true((try? ST_Order::parse("7")) is Err(SchemaViolation(_)))

  // §21.2.3.34 ST_Perspective — xsd:unsignedByte 0..240.
  assert_eq(ST_Perspective::parse("240").value(), 240)
  assert_true((try? ST_Perspective::parse("241")) is Err(SchemaViolation(_)))

  // §21.2.3.46 ST_Style — xsd:unsignedByte 1..48.
  assert_eq(ST_Style::parse("48").value(), 48)
  assert_true((try? ST_Style::parse("0")) is Err(SchemaViolation(_)))
  assert_true((try? ST_Style::parse("49")) is Err(SchemaViolation(_)))

  // §21.2.3.15 ST_FirstSliceAng — xsd:unsignedShort 0..360.
  assert_eq(ST_FirstSliceAng::parse("0").degrees(), 0)
  assert_eq(ST_FirstSliceAng::parse("360").degrees(), 360)
  assert_true((try? ST_FirstSliceAng::parse("361")) is Err(SchemaViolation(_)))

  // §21.2.3.33 ST_Period — xsd:unsignedInt ≥ 2; widened to Int64.
  assert_eq(ST_Period::parse("2").value(), 2L)
  assert_eq(ST_Period::parse("4294967295").value(), 4294967295L)
  assert_true((try? ST_Period::parse("1")) is Err(SchemaViolation(_)))

  // §21.2.3.44 ST_Skip — xsd:unsignedInt ≥ 1.
  assert_eq(ST_Skip::parse("1").value(), 1L)
  assert_true((try? ST_Skip::parse("0")) is Err(SchemaViolation(_)))
}

///|
test "chart double simple types expose typed Double accessors" {
  // §21.2.3.1 ST_AxisUnit — xsd:double > 0.
  let unit = ST_AxisUnit::parse("2.5")
  assert_true(unit.value() == 2.5)
  assert_true((try? ST_AxisUnit::parse("0")) is Err(SchemaViolation(_)))
  assert_true((try? ST_AxisUnit::parse("-1.0")) is Err(SchemaViolation(_)))
  // Integer-valued doubles round-trip without a decimal point.
  assert_eq(ST_AxisUnit::parse("5").to_string(), "5")

  // §21.2.3.25 ST_LogBase — xsd:double in [2, 1000].
  assert_true((try? ST_LogBase::parse("1.5")) is Err(SchemaViolation(_)))
  assert_true((try? ST_LogBase::parse("1001")) is Err(SchemaViolation(_)))
  assert_true(ST_LogBase::parse("2").value() == 2.0)
  assert_true(ST_LogBase::parse("1000").value() == 1000.0)

  // §21.2.3.36 ST_PictureStackUnit — xsd:double > 0.
  assert_true(ST_PictureStackUnit::parse("0.5").value() == 0.5)
  assert_true((try? ST_PictureStackUnit::parse("0")) is Err(SchemaViolation(_)))

  // §21.3.3.1 ST_MarkerCoordinate — xsd:double in [0, 1].
  assert_true(ST_MarkerCoordinate::parse("0").value() == 0.0)
  assert_true(ST_MarkerCoordinate::parse("1").value() == 1.0)
  assert_true(ST_MarkerCoordinate::parse("0.25").value() == 0.25)
  assert_true(
    (try? ST_MarkerCoordinate::parse("1.5")) is Err(SchemaViolation(_)),
  )
  assert_true(
    (try? ST_MarkerCoordinate::parse("-0.5")) is Err(SchemaViolation(_)),
  )
}

///|
test "chart percent simple types decode to typed integer values" {
  // §21.2.3.52 ST_HPercentWithSymbol — 5..500%.
  let h = ST_HPercentWithSymbol::parse("250%")
  assert_eq(h.percent(), 250)
  assert_eq(h.to_string(), "250%")
  // The xsd pattern admits a `0*` prefix; canonical form drops it.
  assert_eq(ST_HPercentWithSymbol::parse("005%").percent(), 5)
  assert_eq(ST_HPercentWithSymbol::parse("005%").to_string(), "5%")
  assert_true(
    (try? ST_HPercentWithSymbol::parse("4%")) is Err(SchemaViolation(_)),
  )
  assert_true(
    (try? ST_HPercentWithSymbol::parse("501%")) is Err(SchemaViolation(_)),
  )
  assert_true(
    (try? ST_HPercentWithSymbol::parse("100")) is Err(SchemaViolation(_)),
  )

  // §21.2.3.19 ST_HPercent — xsd:union wrapping the typed inner.
  let outer = ST_HPercent::parse("250%")
  assert_eq(outer.percent(), 250)
  assert_eq(outer.to_string(), "250%")

  // §21.2.3.51 ST_DepthPercentWithSymbol — 20..2000%.
  assert_eq(ST_DepthPercentWithSymbol::parse("2000%").percent(), 2000)
  assert_true(
    (try? ST_DepthPercentWithSymbol::parse("19%")) is Err(SchemaViolation(_)),
  )

  // §21.2.3.53 ST_GapAmountPercent — 0..500%.
  assert_eq(ST_GapAmountPercent::parse("0%").percent(), 0)
  assert_eq(ST_GapAmountPercent::parse("500%").percent(), 500)
  assert_true(
    (try? ST_GapAmountPercent::parse("501%")) is Err(SchemaViolation(_)),
  )

  // §21.2.3.55 ST_HoleSizePercent — 1..90%.
  assert_eq(ST_HoleSizePercent::parse("90%").percent(), 90)
  assert_true((try? ST_HoleSizePercent::parse("0%")) is Err(SchemaViolation(_)))
  assert_true(
    (try? ST_HoleSizePercent::parse("91%")) is Err(SchemaViolation(_)),
  )

  // §21.2.3.54 ST_SecondPieSizePercent — 5..200%.
  assert_eq(ST_SecondPieSizePercent::parse("200%").percent(), 200)
  assert_true(
    (try? ST_SecondPieSizePercent::parse("4%")) is Err(SchemaViolation(_)),
  )

  // §21.2.3.56 ST_LblOffsetPercent — 0..1000%.
  assert_eq(ST_LblOffsetPercent::parse("1000%").percent(), 1000)
  assert_true(
    (try? ST_LblOffsetPercent::parse("1001%")) is Err(SchemaViolation(_)),
  )

  // §21.2.3.57 ST_OverlapPercent — signed percent in [-100, 100].
  let neg = ST_OverlapPercent::parse("-25%")
  assert_eq(neg.percent(), -25)
  assert_eq(neg.to_string(), "-25%")
  assert_eq(ST_OverlapPercent::parse("100%").percent(), 100)
  assert_true(
    (try? ST_OverlapPercent::parse("101%")) is Err(SchemaViolation(_)),
  )
  assert_true(
    (try? ST_OverlapPercent::parse("-101%")) is Err(SchemaViolation(_)),
  )

  // §21.2.3.58 ST_BubbleScalePercent — 0..300%.
  assert_eq(ST_BubbleScalePercent::parse("300%").percent(), 300)
  assert_true(
    (try? ST_BubbleScalePercent::parse("301%")) is Err(SchemaViolation(_)),
  )

  // §21.2.3.60 ST_ThicknessPercent — free [0-9]+%.
  assert_eq(ST_ThicknessPercent::parse("12345%").percent(), 12345)
  assert_eq(ST_ThicknessPercent::parse("000123%").to_string(), "123%")
  assert_true(
    (try? ST_ThicknessPercent::parse("-1%")) is Err(SchemaViolation(_)),
  )
  assert_true((try? ST_ThicknessPercent::parse("%")) is Err(SchemaViolation(_)))

  // §21.2.3.59 ST_Thickness — xsd:union wrapping the typed inner.
  assert_eq(ST_Thickness::parse("50%").percent(), 50)
  assert_eq(ST_Thickness::parse("50%").to_string(), "50%")
}
