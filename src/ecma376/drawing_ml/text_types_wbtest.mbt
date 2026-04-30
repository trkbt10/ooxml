///|
test "round-trip text body" {
  let value = read_text_body(
    bytes(
      "<a:txBody xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:bodyPr vert=\"horz\" wrap=\"square\" anchor=\"ctr\"><a:noAutofit/></a:bodyPr><a:lstStyle/><a:p><a:pPr algn=\"ctr\"><a:defRPr sz=\"1800\" b=\"1\" u=\"sng\"><a:latin typeface=\"Aptos\"/></a:defRPr></a:pPr><a:r><a:rPr lang=\"en-US\"/><a:t>Hello</a:t></a:r><a:endParaRPr lang=\"en-US\"/></a:p></a:txBody>",
    ),
  )
  assert_eq(value.element.name.local_name, "txBody")
  let reparsed = read_text_body(write_text_body(value))
  assert_eq(reparsed.element.name.local_name, "txBody")
}

///|
test "round-trip text body properties" {
  let value = read_text_body_properties(
    bytes(
      "<a:bodyPr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" rot=\"0\" vertOverflow=\"clip\" horzOverflow=\"overflow\" vert=\"horz\" wrap=\"square\" numCol=\"2\" anchor=\"ctr\"><a:normAutofit fontScale=\"90000\" lnSpcReduction=\"10000\"/></a:bodyPr>",
    ),
  )
  assert_eq(value.element.name.local_name, "bodyPr")
  let reparsed = read_text_body_properties(write_text_body_properties(value))
  assert_eq(reparsed.element.name.local_name, "bodyPr")
}

///|
test "round-trip text paragraph" {
  let value = read_text_paragraph(
    bytes(
      "<a:p xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:pPr marL=\"0\" lvl=\"0\" algn=\"l\"><a:lnSpc><a:spcPct val=\"100000\"/></a:lnSpc><a:buAutoNum type=\"arabicPeriod\" startAt=\"1\"/></a:pPr><a:r><a:rPr strike=\"noStrike\" cap=\"none\"/><a:t>Item</a:t></a:r></a:p>",
    ),
  )
  assert_eq(value.element.name.local_name, "p")
  let reparsed = read_text_paragraph(write_text_paragraph(value))
  assert_eq(reparsed.element.name.local_name, "p")
}

///|
test "reject invalid text enum value" {
  try {
    read_text_body_properties(
      bytes(
        "<a:bodyPr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" anchor=\"broken\"/>",
      ),
    )
    |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
