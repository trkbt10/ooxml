///|
test "round-trip text font" {
  let value = read_text_font(
    bytes(
      "<a:latin xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" typeface=\"Aptos\" pitchFamily=\"34\" charset=\"00\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "latin")
  let reparsed = read_text_font(write_text_font(value))
  assert_eq(reparsed.element.name.local_name, "latin")
}

///|
test "round-trip font scheme" {
  // Each <a:majorFont>/<a:minorFont> requires <latin>, <ea>, <cs>
  // children per dml-main.xsd CT_FontCollection (Annex A.4.1 lines
  // 118..126); test fixture extended to satisfy the typed projection.
  let value = read_font_scheme(
    bytes(
      "<a:fontScheme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:majorFont><a:latin typeface=\"Aptos Display\"/><a:ea typeface=\"East Asian\"/><a:cs typeface=\"Complex Script\"/></a:majorFont><a:minorFont><a:latin typeface=\"Aptos\"/><a:ea typeface=\"East Asian\"/><a:cs typeface=\"Complex Script\"/></a:minorFont></a:fontScheme>",
    ),
  )
  assert_eq(value.element.name.local_name, "fontScheme")
  let reparsed = read_font_scheme(write_font_scheme(value))
  assert_eq(reparsed.element.name.local_name, "fontScheme")
}

///|
test "round-trip theme" {
  // CT_BaseStyles requires clrScheme + fontScheme + fmtScheme per
  // dml-main.xsd (Annex A.4.1 lines 173..180), and each font
  // collection requires latin/ea/cs children; fixture expanded to
  // satisfy the typed projection.
  let value = read_theme(
    bytes(
      "<a:theme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:themeElements><a:clrScheme name=\"Office\"><a:dk1><a:sysClr val=\"windowText\" lastClr=\"000000\"/></a:dk1></a:clrScheme><a:fontScheme name=\"Office\"><a:majorFont><a:latin typeface=\"Aptos Display\"/><a:ea typeface=\"East Asian\"/><a:cs typeface=\"Complex Script\"/></a:majorFont><a:minorFont><a:latin typeface=\"Aptos\"/><a:ea typeface=\"East Asian\"/><a:cs typeface=\"Complex Script\"/></a:minorFont></a:fontScheme><a:fmtScheme/></a:themeElements></a:theme>",
    ),
  )
  assert_eq(value.element.name.local_name, "theme")
  let reparsed = read_theme(write_theme(value))
  assert_eq(reparsed.element.name.local_name, "theme")
  // Lossless round-trip proven by full structural identity, not just
  // the tag. CT_BaseStyles (<themeElements>) preserves its source
  // element and to_element returns it verbatim, so parse∘serialize is
  // the identity on the whole subtree. This is the catalog L2b axis's
  // one host-de-dup `fy-ambiguous` singleton, proved directly here:
  // the theme — and its themeElements — round-trip with zero drift.
  assert_true(reparsed.element == value.element)
  assert_true(reparsed.theme_elements == value.theme_elements)
  assert_true(
    reparsed.theme_elements.to_element() == value.theme_elements.to_element(),
  )
}

///|
test "round-trip theme override" {
  let value = read_theme_override(
    bytes(
      "<a:themeOverride xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:clrScheme name=\"Override\"/></a:themeOverride>",
    ),
  )
  assert_eq(value.element.name.local_name, "themeOverride")
  let reparsed = read_theme_override(write_theme_override(value))
  assert_eq(reparsed.element.name.local_name, "themeOverride")
}

///|
test "round-trip theme manager" {
  let value = read_theme_manager(
    bytes(
      "<a:themeManager xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "themeManager")
  let reparsed = read_theme_manager(write_theme_manager(value))
  assert_eq(reparsed.element.name.local_name, "themeManager")
}

///|
test "reject invalid pitch family token" {
  try {
    ST_PitchFamily::parse("99") |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
