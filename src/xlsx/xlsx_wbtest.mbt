///|
fn fixture_bytes() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/><Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/></Relationships>",
      ),
    ),
    (
      "xl/_rels/workbook.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/></Relationships>",
      ),
    ),
    ("xl/workbook.xml", bytes("<s:workbook xmlns:s=\"urn:s\"/>")),
    (
      "xl/worksheets/sheet1.xml",
      bytes(
        "<s:worksheet xmlns:s=\"urn:s\"><s:sheetData><s:row><s:c><s:v>Hello xlsx</s:v></s:c></s:row></s:sheetData></s:worksheet>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
test "xlsx facade opens and saves minimal package" {
  let workbook = open(fixture_bytes())
  assert_eq(workbook.workbook_part, "/xl/workbook.xml")
  assert_eq(workbook.worksheets.length(), 1)
  let reopened = open(workbook.save())
  assert_eq(reopened.workbook.element.name.local_name, "workbook")
}

///|
test "xlsx facade renders minimal html" {
  let html = open(fixture_bytes()).to_html()
  assert_true(html.contains("data-ooxml=\"xlsx\""))
  assert_true(html.contains("Hello xlsx"))
}

///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}
