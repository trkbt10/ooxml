///|
test "round-trip line properties" {
  let value = read_line_properties(
    bytes(
      "<a:ln xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" w=\"12700\" cap=\"rnd\" cmpd=\"sng\" algn=\"ctr\"><a:solidFill><a:srgbClr val=\"000000\"/></a:solidFill><a:prstDash val=\"dash\"/><a:miter lim=\"800000\"/><a:headEnd type=\"triangle\" w=\"sm\" len=\"lg\"/><a:tailEnd type=\"none\"/></a:ln>",
    ),
  )
  assert_eq(value.element.name.local_name, "ln")
  let reparsed = read_line_properties(write_line_properties(value))
  assert_eq(reparsed.element.name.local_name, "ln")
}

///|
test "round-trip preset line dash properties" {
  let value = read_preset_line_dash_properties(
    bytes(
      "<a:prstDash xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" val=\"lgDashDot\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "prstDash")
  let reparsed = read_preset_line_dash_properties(
    write_preset_line_dash_properties(value),
  )
  assert_eq(reparsed.element.name.local_name, "prstDash")
}

///|
test "reject invalid preset line dash value" {
  try {
    read_preset_line_dash_properties(
      bytes(
        "<a:prstDash xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" val=\"broken\"/>",
      ),
    )
    |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
