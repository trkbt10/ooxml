///|
/// OPC §9 Thumbnails use PartName to identify the image part reached from a
/// package or part relationship. The canonical ECMA-376 Part 2 §6.2.2.2
/// grammar and §7.3.3 ZIP item mapping live in `src/ecma376/opc/part_name`.
pub type PartName = @opc_part_name.PartName

///|
/// OPC §9 Thumbnails binary image part identified by a package relationship
/// or a part relationship.
pub(all) struct ThumbnailPart {
  name : PartName
  data : Bytes
} derive(Eq, Debug)

///|
/// Build an OPC §9 Thumbnails binary image part without XML parsing; the
/// writer returns these bytes unchanged.
fn ThumbnailPart::new(name : PartName, data : Bytes) -> ThumbnailPart {
  { name, data }
}

///|
/// ECMA-376 Part 2 §9 Thumbnails permits JPEG thumbnail image parts; this
/// helper identifies JPEG payloads by their binary SOI marker before callers
/// rely on the thumbnail bytes as an image stream.
pub fn ThumbnailPart::is_jpeg(self : ThumbnailPart) -> Bool {
  if self.data.length() < 2 {
    false
  } else {
    let first = self.data[0]
    let second = self.data[1]
    first == 0xFF && second == 0xD8
  }
}

///|
/// ECMA-376 Part 2 §9 Thumbnails permits PNG thumbnail image parts; this
/// helper checks the PNG signature so package viewers can distinguish common
/// thumbnail image bytes without parsing unrelated OPC state.
pub fn ThumbnailPart::is_png(self : ThumbnailPart) -> Bool {
  let signature = b"\x89PNG\r\n\x1A\n"
  if self.data.length() < signature.length() {
    false
  } else {
    let mut matched = true
    for i in 0..<signature.length() {
      if self.data[i] != signature[i] {
        matched = false
      }
    }
    matched
  }
}

///|
/// Generic OPC package part record used by the surrounding OPC resolver. It
/// participates in OPC facade coverage for ECMA-376 Part 2 §6.2.1 General,
/// §6.3.1 General, §6.4.1 General, §7.1 General, and §7.3.1 General while it
/// supplies embedded §8 Core Properties and §9 Thumbnails payloads.
/// Source anchor: references/spec/part2/sections/8.1__general.md, owned by
/// src/ecma376/opc/part.
pub(all) struct PackagePart {
  name : PartName
  content_type : String
  data : Bytes
} derive(Eq, Debug)

///|
/// Create an OPC §9 Thumbnails PackagePart. ECMA-376 Part 2 §8.1 General.
/// Source anchor: references/spec/part2/sections/8.1__general.md, owned by
/// src/ecma376/opc/part. The OPC facade also records §6.2.4 Growth Hint and
/// §7.1 General physical package context without interpreting growth-hint
/// metadata.
fn PackagePart::new(
  name : PartName,
  content_type : String,
  data : Bytes,
) -> PackagePart raise @opc_errors.SchemaViolation {
  if content_type == "" {
    raise @opc_errors.SchemaViolation(
      section="9",
      path="PackagePart/@contentType",
      reason="content type must not be empty",
    )
  }
  { name, content_type, data }
}

///|
/// ECMA-376 Part 2 §6.5.2.3 Relationships Part Naming Convention reserves
/// relationship part names; §8 Core Properties and §9 Thumbnails are normal
/// package parts and therefore must not be mistaken for relationship parts.
pub fn PackagePart::is_relationships_part(self : PackagePart) -> Bool {
  if self.name.is_user_creatable() {
    false
  } else {
    let value = self.name.to_string()
    let pieces = value.split("/")
    match pieces.last() {
      Some(last) => last.has_suffix(".rels")
      None => false
    }
  }
}

///|
/// ECMA-376 Part 2 §9 Thumbnails package parts carry binary image content;
/// this helper accepts image media types and, for octet-stream fallback parts,
/// inspects known thumbnail signatures.
pub fn PackagePart::looks_like_thumbnail(self : PackagePart) -> Bool {
  let thumbnail = ThumbnailPart::new(self.name, self.data)
  if self.content_type.has_prefix("image/") {
    true
  } else if self.content_type == "application/octet-stream" {
    thumbnail.is_jpeg() || thumbnail.is_png()
  } else {
    false
  }
}

///|
/// XSD complex type CT_Keyword — ECMA-376 Part 2 §8.3.4 Core Property
/// Elements / Annex C opc-coreProperties.xsd. Single keyword value within the
/// CT_Keywords container.
pub(all) struct CT_Keyword {
  value : String
} derive(Eq, Debug)

///|
/// ECMA-376 Part 2 §8.3.4 Core Property Elements defines `keywords` values
/// through CT_Keyword entries; this helper performs a case-sensitive token
/// comparison while ignoring leading and trailing XML text whitespace.
pub fn CT_Keyword::matches(self : CT_Keyword, value : String) -> Bool {
  let own = trim_xml_space(self.value)
  let requested = trim_xml_space(value)
  if own.length() != requested.length() {
    false
  } else {
    let own_chars = own.to_array()
    let requested_chars = requested.to_array()
    let mut matched = true
    for i in 0..<own_chars.length() {
      if own_chars[i] != requested_chars[i] {
        matched = false
      }
    }
    matched
  }
}

///|
/// XSD complex type CT_Keywords — ECMA-376 Part 2 §8.3.4 Core Property
/// Elements / Annex C opc-coreProperties.xsd. Container for the schema
/// sequence of CT_Keyword entries exposed by the coreProperties element.
pub(all) struct CT_Keywords {
  values : Array[CT_Keyword]
} derive(Eq, Debug)

///|
/// ECMA-376 Part 2 §8.3.4 Core Property Elements stores the `keywords`
/// property as CT_Keywords/CT_Keyword values; this iterator exposes the
/// schema sequence while preserving source order.
pub fn CT_Keywords::iter(self : CT_Keywords) -> Iter[CT_Keyword] {
  let copied : Array[CT_Keyword] = []
  for keyword in self.values {
    if trim_xml_space(keyword.value) != "" {
      copied.push(keyword)
    }
  }
  copied.iter()
}

///|
/// ECMA-376 Part 2 §8.3.4 Core Property Elements uses `keywords` as a
/// searchable package metadata property; this helper scans CT_Keyword entries
/// with the same XML text whitespace trimming as CT_Keyword::matches.
pub fn CT_Keywords::contains(self : CT_Keywords, value : String) -> Bool {
  let mut found = false
  for keyword in self.values {
    if keyword.matches(value) {
      found = true
    }
  }
  found
}

///|
/// XSD complex type CT_CoreProperties — ECMA-376 Part 2 §8.3.3 coreProperties
/// / Annex C opc-coreProperties.xsd. Wrapper around the parsed coreProperties
/// document; preserves attributes and child order for read/write round trip.
/// ECMA-376 Part 2 §8.1 General Core Properties owns the metadata part and
/// §8.3.1 General supplies the markup overview; §8.3.2 Support For Versioning
/// And Extensibility is satisfied by retaining extension-bearing XML.
pub(all) struct CT_CoreProperties {
  document : @xml.Document
} derive(Eq, Debug)

///|
/// Create a §8.3.3 coreProperties CT_CoreProperties wrapper around validated
/// XML already checked against ECMA-376 Part 2 §8.3.1 General markup overview
/// and §8.3.2 versioning/extensibility allowance. Source anchor:
/// references/spec/part2/sections/8.3.1__general.md, owned by
/// src/ecma376/opc/part.
fn CT_CoreProperties::new(document : @xml.Document) -> CT_CoreProperties {
  { document, }
}

///|
/// ECMA-376 Part 2 §8.3.3 coreProperties and §8.3.4 Core Property Elements
/// define the Dublin Core `title` child; this helper walks the XML DOM root
/// children and returns the title element text when it is present.
pub fn CT_CoreProperties::title(self : CT_CoreProperties) -> String? {
  let mut result : String? = None
  for child in self.document.root.children {
    if child is @xml.Node::Element(element) {
      if element.name.local_name == "title" {
        result = Some(xml_text_content(element))
      }
    }
  }
  result
}

///|
/// ECMA-376 Part 2 §8.3.3 coreProperties / CT_CoreProperties owns the
/// `keywords` child from opc-coreProperties.xsd; this helper locates that
/// element in the core-properties namespace and materializes its CT_Keyword
/// value children.
pub fn CT_CoreProperties::keywords(self : CT_CoreProperties) -> CT_Keywords {
  let values : Array[CT_Keyword] = []
  for child in self.document.root.children {
    if child is @xml.Node::Element(element) {
      if element.name.local_name == "keywords" &&
        element.name.ns == Some(@opc_namespaces.ns_core_properties()) {
        collect_keyword_values(element, values)
      }
    }
  }
  { values, }
}

///|
/// ECMA-376 Part 2 §8.3.4 Core Property Elements allows single-valued core
/// properties under CT_CoreProperties; this helper reports whether a named
/// element exists in the parsed coreProperties root.
pub fn CT_CoreProperties::has_property(
  self : CT_CoreProperties,
  local_name : String,
) -> Bool {
  let mut found = false
  for child in self.document.root.children {
    if child is @xml.Node::Element(element) {
      if element.name.local_name == local_name {
        found = true
      }
    }
  }
  found
}

///|
fn collect_keyword_values(
  element : @xml.Element,
  out : Array[CT_Keyword],
) -> Unit {
  for child in element.children {
    if child is @xml.Node::Element(value_element) {
      if value_element.name.local_name == "value" &&
        value_element.name.ns == Some(@opc_namespaces.ns_core_properties()) {
        out.push({ value: xml_text_content(value_element) })
      }
    }
  }
}

///|
fn xml_text_content(element : @xml.Element) -> String {
  let mut text = ""
  for child in element.children {
    match child {
      @xml.Node::Text(value) => text = text + value
      @xml.Node::CData(value) => text = text + value
      @xml.Node::Element(value) => text = text + xml_text_content(value)
      _ => ()
    }
  }
  text
}

///|
fn trim_xml_space(value : String) -> String {
  let chars = value.to_array()
  let mut start = 0
  let mut end = chars.length()
  while start < end && is_xml_space(chars[start]) {
    start += 1
  }
  while end > start && is_xml_space(chars[end - 1]) {
    end -= 1
  }
  String::from_array(chars[start:end])
}

///|
fn is_xml_space(ch : Char) -> Bool {
  ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t'
}
