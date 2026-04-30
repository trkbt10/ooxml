///|
/// ECMA-376 Part 1 §22.6 Bibliography.
/// ECMA-376 §22.6 Bibliography part.
///
/// Schema shared-bibliography.xsd owns top-level XSD element Sources,
/// CT_Sources, CT_SourceType, CT_AuthorType, CT_NameOrCorporateType,
/// CT_NameType, CT_PersonType, CT_NameListType, and ST_SourceType.
/// Source anchor: references/spec/part1/sections/22.6__bibliography.md.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/bibliography"
}

///|
/// Bibliography schema validation error.
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String)
} derive(Debug)

///|
/// XSD simple type ST_SourceType from shared-bibliography.xsd.
/// ResourceMissing belongs to the surrounding package resolver contract, not
/// to this closed source-type enumeration.
pub(all) enum ST_SourceType {
  ArticleInAPeriodical
  Book
  BookSection
  JournalArticle
  ConferenceProceedings
  Report
  SoundRecording
  Performance
  Art
  DocumentFromInternetSite
  InternetSite
  Film
  Interview
  Patent
  ElectronicSource
  Case
  Misc
} derive(Eq, Debug)

///|
/// Parse ST_SourceType enumeration values.
pub fn ST_SourceType::parse(s : String) -> ST_SourceType raise SchemaViolation {
  match s {
    "ArticleInAPeriodical" => ArticleInAPeriodical
    "Book" => Book
    "BookSection" => BookSection
    "JournalArticle" => JournalArticle
    "ConferenceProceedings" => ConferenceProceedings
    "Report" => Report
    "SoundRecording" => SoundRecording
    "Performance" => Performance
    "Art" => Art
    "DocumentFromInternetSite" => DocumentFromInternetSite
    "InternetSite" => InternetSite
    "Film" => Film
    "Interview" => Interview
    "Patent" => Patent
    "ElectronicSource" => ElectronicSource
    "Case" => Case
    "Misc" => Misc
    _ => raise SchemaViolation(type_name="ST_SourceType", value=s)
  }
}

///|
/// Return the ST_SourceType schema lexical value.
pub fn ST_SourceType::to_string(self : ST_SourceType) -> String {
  match self {
    ArticleInAPeriodical => "ArticleInAPeriodical"
    Book => "Book"
    BookSection => "BookSection"
    JournalArticle => "JournalArticle"
    ConferenceProceedings => "ConferenceProceedings"
    Report => "Report"
    SoundRecording => "SoundRecording"
    Performance => "Performance"
    Art => "Art"
    DocumentFromInternetSite => "DocumentFromInternetSite"
    InternetSite => "InternetSite"
    Film => "Film"
    Interview => "Interview"
    Patent => "Patent"
    ElectronicSource => "ElectronicSource"
    Case => "Case"
    Misc => "Misc"
  }
}

///|
/// XSD complex type CT_PersonType with Last, First, and Middle children.
pub(all) struct CT_PersonType {
  last : String?
  first : String?
  middle : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_NameListType containing Person values.
pub(all) struct CT_NameListType {
  persons : Array[CT_PersonType]
} derive(Eq, Debug)

///|
/// XSD complex type CT_NameType containing one NameList.
pub(all) struct CT_NameType {
  name_list : CT_NameListType
} derive(Eq, Debug)

///|
/// XSD complex type CT_NameOrCorporateType, a choice of NameList or Corporate.
pub(all) enum CT_NameOrCorporateType {
  NameList(CT_NameListType)
  Corporate(String)
} derive(Eq, Debug)

///|
/// Named CT_AuthorType contribution such as Author, Editor, Translator, or
/// Performer.
pub(all) enum BibliographyContributor {
  Name(String, CT_NameType)
  NameOrCorporate(String, CT_NameOrCorporateType)
} derive(Eq, Debug)

///|
/// XSD complex type CT_AuthorType wraps author role children.
pub(all) struct CT_AuthorType {
  contributors : Array[BibliographyContributor]
} derive(Eq, Debug)

///|
/// XSD complex type CT_SourceType represents one Source entry.
pub(all) struct CT_SourceType {
  source_type : ST_SourceType?
  author : CT_AuthorType?
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Sources and top-level Sources element.
pub(all) struct CT_Sources {
  selected_style : String?
  style_name : String?
  uri : String?
  sources : Array[CT_SourceType]
} derive(Eq, Debug)

///|
/// Top-level XSD element Sources.
pub type Sources = CT_Sources

///|
/// Read the top-level Sources element.
pub fn read_sources(bytes : Bytes) -> Sources raise {
  let doc = @xml.parse(bytes)
  parse_sources_element(doc.root)
}

///|
/// Write the top-level Sources element.
pub fn write_sources(sources : Sources) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: sources.to_element() })
}

///|
/// Parse a Sources element as CT_Sources.
pub fn parse_sources_element(
  element : @xml.Element,
) -> Sources raise SchemaViolation {
  require_local(element, "Sources", "Sources")
  let sources : Array[CT_SourceType] = []
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == "Source" {
          sources.push(CT_SourceType::parse(child_element))
        }
      _ => ()
    }
  }
  {
    selected_style: attr(element, "SelectedStyle"),
    style_name: attr(element, "StyleName"),
    uri: attr(element, "URI"),
    sources,
  }
}

///|
/// Serialize CT_Sources as the Sources element.
pub fn CT_Sources::to_element(self : CT_Sources) -> @xml.Element {
  let attributes : Array[@xml.Attribute] = []
  push_attr(attributes, "SelectedStyle", self.selected_style)
  push_attr(attributes, "StyleName", self.style_name)
  push_attr(attributes, "URI", self.uri)
  let children : Array[@xml.Node] = []
  for source in self.sources {
    children.push(@xml.Node::Element(source.to_element()))
  }
  { name: bib_name("Sources"), attributes, children }
}

///|
/// Parse CT_SourceType.
pub fn CT_SourceType::parse(
  element : @xml.Element,
) -> CT_SourceType raise SchemaViolation {
  require_local(element, "Source", "Source")
  let preserved : Array[@xml.Element] = []
  let mut source_type : ST_SourceType? = None
  let mut author : CT_AuthorType? = None
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        match child_element.name.local_name {
          "SourceType" =>
            source_type = Some(ST_SourceType::parse(text(child_element)))
          "Author" => author = Some(CT_AuthorType::parse(child_element))
          _ => preserved.push(child_element)
        }
      _ => ()
    }
  }
  { source_type, author, elements: preserved }
}

///|
/// Serialize CT_SourceType as Source.
pub fn CT_SourceType::to_element(self : CT_SourceType) -> @xml.Element {
  let children : Array[@xml.Node] = []
  match self.source_type {
    Some(source_type) =>
      children.push(text_element("SourceType", source_type.to_string()))
    None => ()
  }
  match self.author {
    Some(author) => children.push(@xml.Node::Element(author.to_element()))
    None => ()
  }
  for element in self.elements {
    children.push(@xml.Node::Element(element))
  }
  { name: bib_name("Source"), attributes: [], children }
}

///|
/// Parse CT_AuthorType role children.
pub fn CT_AuthorType::parse(
  element : @xml.Element,
) -> CT_AuthorType raise SchemaViolation {
  require_local(element, "Author", "Author")
  let contributors : Array[BibliographyContributor] = []
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) => {
        let role = child_element.name.local_name
        if role == "Author" || role == "Performer" {
          contributors.push(
            NameOrCorporate(role, CT_NameOrCorporateType::parse(child_element)),
          )
        } else {
          contributors.push(Name(role, CT_NameType::parse(child_element)))
        }
      }
      _ => ()
    }
  }
  { contributors, }
}

///|
/// Serialize CT_AuthorType.
pub fn CT_AuthorType::to_element(self : CT_AuthorType) -> @xml.Element {
  let children : Array[@xml.Node] = []
  for contributor in self.contributors {
    match contributor {
      Name(role, value) =>
        children.push(@xml.Node::Element(value.to_element(role)))
      NameOrCorporate(role, value) =>
        children.push(@xml.Node::Element(value.to_element(role)))
    }
  }
  { name: bib_name("Author"), attributes: [], children }
}

///|
/// Parse CT_NameType.
pub fn CT_NameType::parse(
  element : @xml.Element,
) -> CT_NameType raise SchemaViolation {
  { name_list: CT_NameListType::parse(required_child(element, "NameList")) }
}

///|
/// Serialize CT_NameType under its role element.
pub fn CT_NameType::to_element(
  self : CT_NameType,
  role : String,
) -> @xml.Element {
  {
    name: bib_name(role),
    attributes: [],
    children: [@xml.Node::Element(self.name_list.to_element())],
  }
}

///|
/// Parse CT_NameOrCorporateType.
pub fn CT_NameOrCorporateType::parse(
  element : @xml.Element,
) -> CT_NameOrCorporateType raise SchemaViolation {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        match child_element.name.local_name {
          "NameList" => return NameList(CT_NameListType::parse(child_element))
          "Corporate" => return Corporate(text(child_element))
          _ => ()
        }
      _ => ()
    }
  }
  raise SchemaViolation(
    type_name="CT_NameOrCorporateType",
    value=element.name.local_name,
  )
}

///|
/// Serialize CT_NameOrCorporateType under its role element.
pub fn CT_NameOrCorporateType::to_element(
  self : CT_NameOrCorporateType,
  role : String,
) -> @xml.Element {
  let child = match self {
    NameList(name_list) => @xml.Node::Element(name_list.to_element())
    Corporate(value) => text_element("Corporate", value)
  }
  { name: bib_name(role), attributes: [], children: [child] }
}

///|
/// Parse CT_NameListType.
pub fn CT_NameListType::parse(
  element : @xml.Element,
) -> CT_NameListType raise SchemaViolation {
  require_local(element, "NameList", "NameList")
  let persons : Array[CT_PersonType] = []
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == "Person" {
          persons.push(CT_PersonType::parse(child_element))
        }
      _ => ()
    }
  }
  { persons, }
}

///|
/// Serialize CT_NameListType.
pub fn CT_NameListType::to_element(self : CT_NameListType) -> @xml.Element {
  let children : Array[@xml.Node] = []
  for person in self.persons {
    children.push(@xml.Node::Element(person.to_element()))
  }
  { name: bib_name("NameList"), attributes: [], children }
}

///|
/// Parse CT_PersonType.
pub fn CT_PersonType::parse(
  element : @xml.Element,
) -> CT_PersonType raise SchemaViolation {
  require_local(element, "Person", "Person")
  {
    last: child_text(element, "Last"),
    first: child_text(element, "First"),
    middle: child_text(element, "Middle"),
  }
}

///|
/// Serialize CT_PersonType.
pub fn CT_PersonType::to_element(self : CT_PersonType) -> @xml.Element {
  let children : Array[@xml.Node] = []
  push_text_child(children, "Last", self.last)
  push_text_child(children, "First", self.first)
  push_text_child(children, "Middle", self.middle)
  { name: bib_name("Person"), attributes: [], children }
}

///|
fn attr(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
fn push_attr(
  attributes : Array[@xml.Attribute],
  local_name : String,
  value : String?,
) -> Unit {
  match value {
    Some(value) => attributes.push({ name: bib_name(local_name), value })
    None => ()
  }
}

///|
fn child_text(element : @xml.Element, local_name : String) -> String? {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return Some(text(child_element))
        }
      _ => ()
    }
  }
  None
}

///|
fn required_child(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element raise SchemaViolation {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return child_element
        }
      _ => ()
    }
  }
  raise SchemaViolation(type_name="required child", value=local_name)
}

///|
fn text(element : @xml.Element) -> String {
  let mut out = ""
  for child in element.children {
    match child {
      @xml.Node::Text(value) => out = out + value
      @xml.Node::CData(value) => out = out + value
      _ => ()
    }
  }
  out
}

///|
fn text_element(local_name : String, value : String) -> @xml.Node {
  @xml.Node::Element({
    name: bib_name(local_name),
    attributes: [],
    children: [@xml.Node::Text(value)],
  })
}

///|
fn push_text_child(
  children : Array[@xml.Node],
  local_name : String,
  value : String?,
) -> Unit {
  match value {
    Some(value) => children.push(text_element(local_name, value))
    None => ()
  }
}

///|
fn require_local(
  element : @xml.Element,
  expected : String,
  type_name : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != expected {
    raise SchemaViolation(type_name~, value=element.name.local_name)
  }
}

///|
fn bib_name(local_name : String) -> @xml.QName {
  {
    prefix: Some("b"),
    local_name,
    ns: Some("http://purl.oclc.org/ooxml/officeDocument/bibliography"),
  }
}
