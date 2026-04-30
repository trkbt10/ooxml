///|
test "WML migration txbxContent round trips" {
  let value = read_txbx_content(
    bytes("<w:txbxContent xmlns:w=\"urn:w\"><w:p/></w:txbxContent>"),
  )
  assert_eq(
    read_txbx_content(@builder.write_txbx_content(value)).element.children.length(),
    1,
  )
}

///|
test "WML migration simple types preserve lexical values" {
  assert_eq(
    (try! @domain.ST_Cnf::parse("101010101010")).to_string(),
    "101010101010",
  )
  assert_eq((try! @domain.ST_TextScaleDecimal::parse("100")).to_string(), "100")
  assert_true(
    (try? @domain.ST_UnqualifiedPercentage::parse(""))
    is Err(@domain.SchemaViolation(_)),
  )
}
