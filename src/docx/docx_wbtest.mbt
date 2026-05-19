///|
fn fixture_bytes() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
      ),
    ),
    (
      "word/document.xml",
      bytes(
        "<w:document xmlns:w=\"urn:w\"><w:body><w:p><w:r><w:t>Hello docx</w:t></w:r></w:p></w:body></w:document>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
test "docx facade opens and saves minimal package" {
  let document = open(fixture_bytes())
  assert_eq(document.main_part, "/word/document.xml")
  let reopened = open(document.save())
  assert_eq(reopened.main.element.name.local_name, "document")
}

///|
test "docx facade renders minimal html" {
  let html = open(fixture_bytes()).to_html()
  assert_true(html.contains("data-ooxml=\"docx\""))
  assert_true(html.contains("Hello docx"))
}

///|
test "docx facade appends paragraph and round-trips" {
  let document = open(fixture_bytes())
  let with_para = try? document.append_paragraph("appended line")
  match with_para {
    Ok(modified) => {
      let saved = modified.save()
      let reopened = open(saved)
      assert_true(reopened.to_html().contains("appended line"))
      // original 'Hello docx' still present
      assert_true(reopened.to_html().contains("Hello docx"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "docx facade preserves text across two save cycles" {
  let initial = open(fixture_bytes())
  let cycle1_bytes = initial.save()
  let cycle1 = open(cycle1_bytes)
  let cycle2_bytes = cycle1.save()
  let cycle2 = open(cycle2_bytes)
  assert_true(cycle1.to_html().contains("Hello docx"))
  assert_true(cycle2.to_html().contains("Hello docx"))
  assert_eq(
    initial.main.element.name.local_name,
    cycle2.main.element.name.local_name,
  )
}

///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}
