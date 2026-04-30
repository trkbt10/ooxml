///|
test "open save package facade" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
  )
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("_rels/.rels", rels),
    ("word/document.xml", b("<document/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  match pkg.part("/word/document.xml") {
    Some(part) =>
      assert_eq(
        part.content_type,
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
      )
    None => fail("expected part")
  }
  let reopened = try! Package::open(try! pkg.save())
  assert_true(reopened.part("/word/document.xml") is Some(_))
}

///|
test "open reports unresolved internal relationship target" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/></Types>",
  )
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"t\" Target=\"missing.xml\"/></Relationships>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("_rels/.rels", rels),
  ])
  let opened = try? Package::open(try! @zip.write(archive))
  assert_true(opened is Err(ResourceMissing(_)))
}

///|
test "pack uri parses composed value" {
  let uri = PackUri::compose("example.com", "/word/document.xml")
  assert_eq(uri.to_string(), "pack://example.com/word/document.xml")
  let parsed = try! PackUri::parse(uri.to_string())
  assert_true(parsed == uri)
}

///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}
