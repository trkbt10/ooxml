///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "ST_SourceType parses and formats schema values" {
  assert_true(ST_SourceType::parse("Book") == Book)
  assert_true(ST_SourceType::parse("JournalArticle") == JournalArticle)
  assert_eq(
    ST_SourceType::parse("ConferenceProceedings").to_string(),
    "ConferenceProceedings",
  )
}

///|
test "read and write Sources with a book author" {
  let xml = bytes(
    "<b:Sources xmlns:b=\"http://purl.oclc.org/ooxml/officeDocument/bibliography\" SelectedStyle=\"APA\"><b:Source><b:SourceType>Book</b:SourceType><b:Author><b:Author><b:NameList><b:Person><b:Last>Lovelace</b:Last><b:First>Ada</b:First></b:Person></b:NameList></b:Author></b:Author><b:Title>Notes</b:Title><b:Year>1843</b:Year></b:Source></b:Sources>",
  )
  let sources = read_sources(xml)
  assert_true(sources.selected_style == Some("APA"))
  assert_eq(sources.sources.length(), 1)
  assert_true(sources.sources[0].source_type == Some(Book))
  let written = write_sources(sources)
  let reparsed = read_sources(written)
  assert_true(reparsed.sources[0].source_type == Some(Book))
  assert_eq(reparsed.sources[0].elements.length(), 2)
}

///|
test "read and write Sources with a corporate web source" {
  let xml = bytes(
    "<b:Sources xmlns:b=\"http://purl.oclc.org/ooxml/officeDocument/bibliography\"><b:Source><b:SourceType>InternetSite</b:SourceType><b:Author><b:Author><b:Corporate>Example Org</b:Corporate></b:Author></b:Author><b:URL>https://example.test</b:URL></b:Source></b:Sources>",
  )
  let sources = read_sources(xml)
  assert_true(sources.sources[0].source_type == Some(InternetSite))
  let round_trip = read_sources(write_sources(sources))
  assert_true(round_trip.sources[0].source_type == Some(InternetSite))
}

///|
test "ST_SourceType rejects unknown source types" {
  try {
    ST_SourceType::parse("Blog") |> ignore
    fail("expected ST_SourceType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
