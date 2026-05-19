///|
fn fixture_bytes() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/ppt/presentation.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml\"/><Override PartName=\"/ppt/slides/slide1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.slide+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"ppt/presentation.xml\"/></Relationships>",
      ),
    ),
    (
      "ppt/_rels/presentation.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide\" Target=\"slides/slide1.xml\"/></Relationships>",
      ),
    ),
    ("ppt/presentation.xml", bytes("<p:presentation xmlns:p=\"urn:p\"/>")),
    (
      "ppt/slides/slide1.xml",
      bytes(
        "<p:sld xmlns:p=\"urn:p\"><p:cSld><p:spTree><p:sp><p:txBody><p:p><p:r><p:t>Hello pptx</p:t></p:r></p:p></p:txBody></p:sp></p:spTree></p:cSld></p:sld>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
test "pptx facade opens and saves minimal package" {
  let presentation = open(fixture_bytes())
  assert_eq(presentation.presentation_part, "/ppt/presentation.xml")
  assert_eq(presentation.slides.length(), 1)
  let reopened = open(presentation.save())
  assert_eq(reopened.presentation.element.name.local_name, "presentation")
}

///|
test "pptx facade renders minimal html" {
  let html = open(fixture_bytes()).to_html()
  assert_true(html.contains("data-ooxml=\"pptx\""))
  assert_true(html.contains("Hello pptx"))
}

///|
test "pptx facade preserves slide content across two save cycles" {
  let initial = open(fixture_bytes())
  let cycle1 = open(initial.save())
  let cycle2 = open(cycle1.save())
  assert_eq(initial.slides.length(), cycle2.slides.length())
  assert_true(cycle1.to_html().contains("Hello pptx"))
  assert_true(cycle2.to_html().contains("Hello pptx"))
}

///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}
