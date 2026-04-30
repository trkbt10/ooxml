///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "read and write minimal DML pic element" {
  let xml = bytes(
    "<pic:pic xmlns:pic=\"http://purl.oclc.org/ooxml/drawingml/picture\" xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><pic:nvPicPr><pic:cNvPr id=\"1\" name=\"Picture 1\"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip/></pic:blipFill><pic:spPr/></pic:pic>",
  )
  let picture = read_pic(xml)
  assert_eq(picture.nv_pic_pr.c_nv_pr.name.local_name, "cNvPr")
  assert_eq(picture.blip_fill.name.local_name, "blipFill")
  let reparsed = read_pic(write_pic(picture))
  assert_eq(reparsed.sp_pr.name.local_name, "spPr")
}

///|
test "read_pic rejects payloads without CT_Picture children" {
  try {
    read_pic(
      bytes(
        "<pic:pic xmlns:pic=\"http://purl.oclc.org/ooxml/drawingml/picture\"/>",
      ),
    )
    |> ignore
    fail("expected CT_Picture validation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
