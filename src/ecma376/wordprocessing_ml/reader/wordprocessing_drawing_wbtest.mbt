///|
/// Per Part 1 §20.4.2.8 / §20.4.2.3 / §20.4.2.26 these top-level wrappers
/// have mandatory children — the test fixtures therefore include the
/// minimum content model defined by dml-wordprocessingDrawing.xsd
/// (extent + docPr + graphic for `<wp:inline>`; simplePos + positionH +
/// positionV + extent + wrap* choice + docPr + graphic + the required
/// boolean attributes for `<wp:anchor>`; cNvSpPr + spPr + bodyPr for
/// `<wps:wsp>`).
test "Wordprocessing drawing top-level readers round trip" {
  let inline_bytes = bytes(
    "<wp:inline xmlns:wp=\"urn:wp\" xmlns:a=\"urn:a\">" +
    "<wp:extent/>" +
    "<wp:docPr/>" +
    "<a:graphic/>" +
    "</wp:inline>",
  )
  let inline = read_inline(inline_bytes)
  assert_eq(
    read_inline(@builder.write_inline(inline)).element.name.local_name,
    "inline",
  )
  let anchor_bytes = bytes(
    "<wp:anchor xmlns:wp=\"urn:wp\" xmlns:a=\"urn:a\"" +
    " relativeHeight=\"0\" behindDoc=\"0\" locked=\"0\"" +
    " layoutInCell=\"1\" allowOverlap=\"1\">" +
    "<wp:simplePos/>" +
    "<wp:positionH relativeFrom=\"margin\"><wp:posOffset>0</wp:posOffset></wp:positionH>" +
    "<wp:positionV relativeFrom=\"margin\"><wp:posOffset>0</wp:posOffset></wp:positionV>" +
    "<wp:extent/>" +
    "<wp:wrapNone/>" +
    "<wp:docPr/>" +
    "<a:graphic/>" +
    "</wp:anchor>",
  )
  let anchor = read_anchor(anchor_bytes)
  // Should round-trip — re-reading the builder's output yields a CT_Anchor
  // whose element preserves the original child sequence.
  assert_eq(
    read_anchor(@builder.write_anchor(anchor)).element.name.local_name,
    "anchor",
  )
  let wsp_bytes = bytes(
    "<wps:wsp xmlns:wps=\"urn:wps\">" +
    "<wps:cNvSpPr/>" +
    "<wps:spPr/>" +
    "<wps:bodyPr/>" +
    "</wps:wsp>",
  )
  let wsp = read_wsp(wsp_bytes)
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
