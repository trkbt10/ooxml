///|
test "Wordprocessing drawing top-level readers round trip" {
  let inline = read_inline(
    bytes("<wp:inline xmlns:wp=\"urn:wp\"><wp:extent/></wp:inline>"),
  )
  assert_eq(
    read_inline(@builder.write_inline(inline)).element.name.local_name,
    "inline",
  )
  let anchor = read_anchor(
    bytes("<wp:anchor xmlns:wp=\"urn:wp\"><wp:extent/></wp:anchor>"),
  )
  assert_eq(
    read_anchor(@builder.write_anchor(anchor)).element.children.length(),
    1,
  )
  let wsp = read_wsp(
    bytes("<wps:wsp xmlns:wps=\"urn:wps\"><wps:txbx/></wps:wsp>"),
  )
  assert_eq(read_wsp(@builder.write_wsp(wsp)).element.name.local_name, "wsp")
}

///|
test "Wordprocessing drawing simple types validate enumerations" {
  assert_eq(
    (try! @domain.ST_WrapText::parse("bothSides")).to_string(),
    "bothSides",
  )
  assert_true(
    (try? @domain.ST_WrapText::parse("both")) is Err(@domain.SchemaViolation(_)),
  )
  assert_eq((try! @domain.ST_RelFromH::parse("margin")).to_string(), "margin")
}
