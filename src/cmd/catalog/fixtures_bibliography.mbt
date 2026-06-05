// Bibliography Custom XML Data Storage fixtures.
//
// Word stores bibliography sources as Custom XML Data Storage parts
// (`customXml/item*.xml`) with a companion `customXmlProps` part.  The
// fixture below is intentionally metadata-rich: it exercises every
// `shared-bibliography.xsd` element QName plus the three
// `shared-customXmlDataProperties.xsd` element QNames inside one real
// `.docx` package graph.

///|
const NS_BIBLIOGRAPHY : String = "http://schemas.openxmlformats.org/officeDocument/2006/bibliography"

///|
const NS_CUSTOM_XML_PROPS : String = "http://schemas.openxmlformats.org/officeDocument/2006/customXml"

///|
fn bibliography_nodes(elements : Array[@xml.Element]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for e in elements {
    nodes.push(Element(e))
  }
  nodes
}

///|
fn b_text(name : String, value : String) -> @xml.Element {
  xep("b", NS_BIBLIOGRAPHY, name, [], [Text(value)])
}

///|
fn bibliography_person(suffix : String) -> @xml.Element {
  xep("b", NS_BIBLIOGRAPHY, "Person", [], [
    Element(b_text("Last", "Doe-" + suffix)),
    Element(b_text("First", "Alex")),
    Element(b_text("Middle", "Q")),
  ])
}

///|
fn bibliography_name_list(suffix : String) -> @xml.Element {
  xep("b", NS_BIBLIOGRAPHY, "NameList", [], [
    Element(bibliography_person(suffix)),
  ])
}

///|
fn bibliography_name_role(name : String) -> @xml.Element {
  xep("b", NS_BIBLIOGRAPHY, name, [], [Element(bibliography_name_list(name))])
}

///|
fn bibliography_corporate_role(name : String, value : String) -> @xml.Element {
  xep("b", NS_BIBLIOGRAPHY, name, [], [Element(b_text("Corporate", value))])
}

///|
fn bibliography_author() -> @xml.Element {
  let roles : Array[@xml.Element] = []
  for
    name in [
      "Artist", "Author", "BookAuthor", "Compiler", "Composer", "Conductor", "Counsel",
      "Director", "Editor", "Interviewee", "Interviewer", "Inventor",
    ] {
    roles.push(bibliography_name_role(name))
  }
  roles.push(bibliography_corporate_role("Performer", "MoonBit Ensemble"))
  for name in ["ProducerName", "Translator", "Writer"] {
    roles.push(bibliography_name_role(name))
  }
  xep("b", NS_BIBLIOGRAPHY, "Author", [], bibliography_nodes(roles))
}

///|
fn bibliography_simple_fields() -> Array[@xml.Element] {
  let fields : Array[@xml.Element] = []
  for
    field in [
      ("AbbreviatedCaseNumber", "AC-1"),
      ("AlbumTitle", "Fixture Album"),
      ("BookTitle", "OOXML Fixture Book"),
      ("Broadcaster", "Catalog Radio"),
      ("BroadcastTitle", "Coverage Hour"),
      ("CaseNumber", "CASE-376"),
      ("ChapterNumber", "22"),
      ("City", "Tokyo"),
      ("Comments", "Schema-valid bibliography source"),
      ("ConferenceName", "ECMA Coverage Conference"),
      ("CountryRegion", "JP"),
      ("Court", "Fixture Court"),
      ("Day", "5"),
      ("DayAccessed", "5"),
      ("Department", "Documentation"),
      ("Distributor", "MoonBit"),
      ("Edition", "1"),
      ("Guid", "{00112233-4455-6677-8899-AABBCCDDEEFF}"),
      ("Institution", "OOXML Catalog"),
      ("InternetSiteTitle", "OOXML Fixture Site"),
      ("Issue", "6"),
      ("JournalName", "Schema Journal"),
      ("LCID", "en-US"),
      ("Medium", "Web"),
      ("Month", "6"),
      ("MonthAccessed", "6"),
      ("NumberVolumes", "1"),
      ("Pages", "1-9"),
      ("PatentNumber", "JP-OOXML-1"),
      ("PeriodicalTitle", "Fixture Periodical"),
      ("ProductionCompany", "Catalog Productions"),
      ("PublicationTitle", "Coverage Proceedings"),
      ("Publisher", "MoonBit OOXML"),
      ("RecordingNumber", "REC-1"),
      ("RefOrder", "1"),
      ("Reporter", "Catalog Reporter"),
      ("SourceType", "Book"),
      ("ShortTitle", "OOXML Fixture"),
      ("StandardNumber", "ECMA-376"),
      ("StateProvince", "Tokyo"),
      ("Station", "CAT-1"),
      ("Tag", "coverage"),
      ("Theater", "Fixture Theater"),
      ("ThesisType", "Technical report"),
      ("Title", "Bibliography Source Coverage"),
      ("Type", "Reference"),
      ("URL", "https://example.test/ooxml/bibliography"),
      ("Version", "1.0"),
      ("Volume", "1"),
      ("Year", "2026"),
      ("YearAccessed", "2026"),
    ] {
    let (name, value) = field
    fields.push(b_text(name, value))
  }
  fields
}

///|
fn bibliography_sources() -> @xml.Element {
  let source_children : Array[@xml.Element] = []
  for e in bibliography_simple_fields() {
    source_children.push(e)
  }
  source_children.push(bibliography_author())
  let source = xep(
    "b",
    NS_BIBLIOGRAPHY,
    "Source",
    [],
    bibliography_nodes(source_children),
  )
  xep(
    "b",
    NS_BIBLIOGRAPHY,
    "Sources",
    [
      xa("SelectedStyle", "APA"),
      xa("StyleName", "APA"),
      xa("URI", "urn:ooxml:catalog:bibliography"),
    ],
    [Element(source)],
  )
}

///|
fn custom_xml_props_attr(name : String, value : String) -> @xml.Attribute {
  {
    name: {
      prefix: Some("ds"),
      local_name: name,
      ns: Some(NS_CUSTOM_XML_PROPS),
    },
    value,
  }
}

///|
fn bibliography_custom_xml_properties() -> @xml.Element {
  xep(
    "ds",
    NS_CUSTOM_XML_PROPS,
    "datastoreItem",
    [custom_xml_props_attr("itemID", "{11111111-2222-3333-4444-555555555555}")],
    [
      Element(
        xep("ds", NS_CUSTOM_XML_PROPS, "schemaRefs", [], [
          Element(
            xep(
              "ds",
              NS_CUSTOM_XML_PROPS,
              "schemaRef",
              [custom_xml_props_attr("uri", NS_BIBLIOGRAPHY)],
              [],
            ),
          ),
        ]),
      ),
    ],
  )
}

///|
fn extras_bibliography_custom_xml(cases : Array[CustomXmlCase]) -> Unit {
  cases.push({
    id: "sources-rich",
    format: "docx",
    category: "bibliography",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Bibliography custom XML coverage")])),
    ]),
    custom_xml: bibliography_sources(),
    custom_xml_properties: bibliography_custom_xml_properties(),
  })
}
