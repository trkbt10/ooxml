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

///|
test "resolve_blip_target raises ResourceMissing only when target is non-empty and unresolved" {
  let xml = bytes(
    "<pic:pic xmlns:pic=\"http://purl.oclc.org/ooxml/drawingml/picture\" xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" xmlns:r=\"http://purl.oclc.org/ooxml/officeDocument/relationships\"><pic:nvPicPr><pic:cNvPr id=\"1\" name=\"P\"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed=\"rIdMissing\"/></pic:blipFill><pic:spPr/></pic:pic>",
  )
  let picture = read_pic(xml)
  try {
    picture.resolve_blip_target(fn(_target) { None }) |> ignore
    fail("expected ResourceMissing")
  } catch {
    ResourceMissing(target~, ..) => assert_eq(target, "rIdMissing")
    _ => fail("expected ResourceMissing")
  }
}

///|
test "resolve_blip_target returns None when blip has no r:embed/r:link (AG_Blob default=\"\")" {
  let xml = bytes(
    "<pic:pic xmlns:pic=\"http://purl.oclc.org/ooxml/drawingml/picture\" xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><pic:nvPicPr><pic:cNvPr id=\"1\" name=\"P\"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip/></pic:blipFill><pic:spPr/></pic:pic>",
  )
  let picture = read_pic(xml)
  assert_true(picture.resolve_blip_target(fn(_t) { None }) is None)
}

///|
test "resolve_blip_target returns resolved element when resolver answers" {
  let xml = bytes(
    "<pic:pic xmlns:pic=\"http://purl.oclc.org/ooxml/drawingml/picture\" xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" xmlns:r=\"http://purl.oclc.org/ooxml/officeDocument/relationships\"><pic:nvPicPr><pic:cNvPr id=\"1\" name=\"P\"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed=\"rId1\"/></pic:blipFill><pic:spPr/></pic:pic>",
  )
  let picture = read_pic(xml)
  let resolved : @xml.Element = {
    name: { prefix: None, local_name: "part", ns: None },
    attributes: [],
    children: [],
  }
  let out = picture.resolve_blip_target(fn(target) {
    if target == "rId1" {
      Some(resolved)
    } else {
      None
    }
  })
  match out {
    Some(e) => assert_eq(e.name.local_name, "part")
    None => fail("expected Some")
  }
}
