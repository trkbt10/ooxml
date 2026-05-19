///|
/// XSD complex type CT_Height — Part 1 §17.4.80 trHeight (Table Row Height).
/// Two optional attributes: `@val` (s:ST_TwipsMeasure §22.9.2.10) carries the
/// row-height twentieths-of-a-point measurement and `@hRule` (ST_HeightRule
/// §17.18.37) selects the auto/exact/atLeast sizing rule. The schema declares
/// no children.
pub(all) struct CT_Height {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.10 @val (s:ST_TwipsMeasure) — optional row-height measurement,
  /// preserved as the schema lexical form so the union of unsigned-decimal /
  /// universal-measure literals round-trips byte-for-byte.
  val : String?
  /// §17.18.37 @hRule (ST_HeightRule) — optional auto/exact/atLeast rule.
  h_rule : ST_HeightRule?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Height — Part 1 §17.4.80 trHeight. Decode the optional
/// `@val` (preserved lexically) and `@hRule` (enumerated) attributes.
pub fn CT_Height::new(
  element : @xml.Element,
) -> CT_Height raise SchemaViolation {
  let val = wml_ct_chunk4_attr(element, "val")
  let h_rule = match wml_ct_chunk4_attr(element, "hRule") {
    Some(text) => Some(ST_HeightRule::parse(text))
    None => None
  }
  { element, val, h_rule }
}

///|
/// XSD complex type CT_Height — Part 1 §17.4.80.
pub fn CT_Height::parse(
  element : @xml.Element,
) -> CT_Height raise SchemaViolation {
  CT_Height::new(element)
}

///|
/// XSD complex type CT_Height — return the preserved element for writers.
pub fn CT_Height::to_element(self : CT_Height) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Headers — Part 1 §17.4.19 headers (Header Cells
/// Associated With Table Cell). Wraps an `xsd:sequence minOccurs="0"
/// maxOccurs="unbounded"` of `<header>` (CT_String §22.9.2.13 carrying the
/// header-cell name) and declares no attributes.
pub(all) struct CT_Headers {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.18 `<header>`* (CT_String) — zero or more associated header-cell
  /// references, each carrying the header-cell `@val` name string.
  header : Array[CT_String]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Headers — Part 1 §17.4.19. Decode the unbounded
/// `<header>` (CT_String) sequence.
pub fn CT_Headers::new(
  element : @xml.Element,
) -> CT_Headers raise SchemaViolation {
  let header_elements = wml_ct_chunk4_children(element, "header")
  let header : Array[CT_String] = []
  for e in header_elements {
    header.push(CT_String::new(e))
  }
  { element, header }
}

///|
/// XSD complex type CT_Headers — Part 1 §17.4.19.
pub fn CT_Headers::parse(
  element : @xml.Element,
) -> CT_Headers raise SchemaViolation {
  CT_Headers::new(element)
}

///|
/// XSD complex type CT_Headers — return the preserved element for writers.
pub fn CT_Headers::to_element(self : CT_Headers) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Base64Binary — Part 1 §17.14.35 uniqueTag (Unique
/// Value for Record). Carries a required `@val` (xsd:base64Binary)
/// preserved as the lexical Base64 string so encoder choices are
/// round-tripped verbatim. No children.
pub(all) struct CT_Base64Binary {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.14.35 @val (xsd:base64Binary) — required Base64 payload, stored
  /// as the schema lexical form to keep producer-chosen line-wrapping
  /// and whitespace intact for the writer.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Base64Binary — Part 1 §17.14.35. Decode the required
/// xsd:base64Binary `@val` attribute.
pub fn CT_Base64Binary::new(
  element : @xml.Element,
) -> CT_Base64Binary raise SchemaViolation {
  let val = wml_ct_chunk4_required_attr(
    element, "val", "CT_Base64Binary", "Part 1 §17.14.35 xsd:base64Binary",
  )
  { element, val }
}

///|
/// XSD complex type CT_Base64Binary — Part 1 §17.14.35.
pub fn CT_Base64Binary::parse(
  element : @xml.Element,
) -> CT_Base64Binary raise SchemaViolation {
  CT_Base64Binary::new(element)
}

///|
/// XSD complex type CT_Base64Binary — return the preserved element for writers.
pub fn CT_Base64Binary::to_element(self : CT_Base64Binary) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Body — Part 1 §17.2.2 body (Document Body). Wraps an
/// `xsd:sequence` of EG_BlockLevelElts* (block-level content: paragraphs,
/// tables, SDT blocks, custom-XML blocks, run-level marks) followed by an
/// optional `<sectPr>` (CT_SectPr §17.6.18) carrying the final section
/// properties. No attributes. Block-level children are preserved as raw
/// elements wrapped in `EG_BlockLevelElts` so the typed block readers can
/// project them under their own schema while CT_Body keeps the source
/// element for round-trip.
pub(all) struct CT_Body {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.2.2 EG_BlockLevelElts* — zero or more block-level elements in
  /// document order. Stored as the EG model-group wrapper so typed readers
  /// can dispatch on the projected member set without re-walking the source.
  block_level_elts : EG_BlockLevelElts
  /// §17.6.18 `<sectPr>` (CT_SectPr) — optional final section properties.
  sect_pr : CT_SectPr?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Body — Part 1 §17.2.2. Decode the EG_BlockLevelElts*
/// children and the optional `<sectPr>` (CT_SectPr).
pub fn CT_Body::new(element : @xml.Element) -> CT_Body raise SchemaViolation {
  // Collect block-level children excluding the trailing sectPr so the model
  // group only carries EG_BlockLevelElts members.
  let block_level_elements : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name != "sectPr" {
          block_level_elements.push(e)
        }
      _ => ()
    }
  }
  let block_level_elts = EG_BlockLevelElts::new(block_level_elements)
  let sect_pr = match wml_ct_chunk4_first_child(element, "sectPr") {
    Some(e) => Some(CT_SectPr::new(e))
    None => None
  }
  { element, block_level_elts, sect_pr }
}

///|
/// XSD complex type CT_Body — Part 1 §17.2.2.
pub fn CT_Body::parse(element : @xml.Element) -> CT_Body raise SchemaViolation {
  CT_Body::new(element)
}

///|
/// XSD complex type CT_Body — return the preserved element for writers.
pub fn CT_Body::to_element(self : CT_Body) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Comments — Part 1 §17.13.4.6 comments (Comments
/// Collection). Wraps an `xsd:sequence minOccurs="0" maxOccurs="unbounded"`
/// of `<comment>` (CT_Comment §17.13.4.2) child elements. No attributes.
pub(all) struct CT_Comments {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.13.4.2 `<comment>`* (CT_Comment) — zero or more comment payloads
  /// in document order; the CT_Comment decoder validates each `@id`,
  /// `@author`, `@date` and `@initials` per the schema.
  comment : Array[CT_Comment]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Comments — Part 1 §17.13.4.6. Decode each
/// `<comment>` child via CT_Comment::new, which raises SchemaViolation when
/// a required `@id` / `@author` attribute is missing.
pub fn CT_Comments::new(
  element : @xml.Element,
) -> CT_Comments raise SchemaViolation {
  let comment_elements = wml_ct_chunk4_children(element, "comment")
  let comment : Array[CT_Comment] = []
  for e in comment_elements {
    comment.push(CT_Comment::new(e))
  }
  { element, comment }
}

///|
/// XSD complex type CT_Comments — Part 1 §17.13.4.6.
pub fn CT_Comments::parse(
  element : @xml.Element,
) -> CT_Comments raise SchemaViolation {
  CT_Comments::new(element)
}

///|
/// XSD complex type CT_Comments — return the preserved element for writers.
pub fn CT_Comments::to_element(self : CT_Comments) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTagType — Part 1 §17.15.1.79 smartTagType (Smart
/// Tag Type Declaration; recorded in the document settings). Three optional
/// attributes (all s:ST_String): `@namespaceuri` declares the smart-tag
/// namespace URI, `@name` the smart-tag local name and `@url` the optional
/// recognizer URL. No children.
pub(all) struct CT_SmartTagType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.15.1.79 @namespaceuri (s:ST_String) — optional smart-tag
  /// namespace URI string (no QName resolution applied).
  namespaceuri : String?
  /// §17.15.1.79 @name (s:ST_String) — optional smart-tag local name.
  name : String?
  /// §17.15.1.79 @url (s:ST_String) — optional recognizer URL.
  url : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SmartTagType — Part 1 §17.15.1.79. Decode the three
/// optional attributes verbatim as strings.
pub fn CT_SmartTagType::new(element : @xml.Element) -> CT_SmartTagType {
  let namespaceuri = wml_ct_chunk4_attr(element, "namespaceuri")
  let name = wml_ct_chunk4_attr(element, "name")
  let url = wml_ct_chunk4_attr(element, "url")
  { element, namespaceuri, name, url }
}

///|
/// XSD complex type CT_SmartTagType — Part 1 §17.15.1.79.
pub fn CT_SmartTagType::parse(element : @xml.Element) -> CT_SmartTagType {
  CT_SmartTagType::new(element)
}

///|
/// XSD complex type CT_SmartTagType — return the preserved element for writers.
pub fn CT_SmartTagType::to_element(self : CT_SmartTagType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartBehavior — Part 1 §17.12.1 behavior (Entry
/// Insertion Behavior). Carries a required `@val` (ST_DocPartBehavior
/// §17.18.13) selecting `content` / `p` / `pg` insertion semantics. No
/// children.
pub(all) struct CT_DocPartBehavior {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.13 @val (ST_DocPartBehavior) — required insertion-behavior
  /// enumeration; `content` for inline, `p` for paragraph and `pg` for page.
  val : ST_DocPartBehavior
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocPartBehavior — Part 1 §17.12.1. Decode the required
/// ST_DocPartBehavior `@val` attribute.
pub fn CT_DocPartBehavior::new(
  element : @xml.Element,
) -> CT_DocPartBehavior raise SchemaViolation {
  let raw = wml_ct_chunk4_required_attr(
    element, "val", "CT_DocPartBehavior", "Part 1 §17.18.13 ST_DocPartBehavior",
  )
  let val = ST_DocPartBehavior::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_DocPartBehavior — Part 1 §17.12.1.
pub fn CT_DocPartBehavior::parse(
  element : @xml.Element,
) -> CT_DocPartBehavior raise SchemaViolation {
  CT_DocPartBehavior::new(element)
}

///|
/// XSD complex type CT_DocPartBehavior — return the preserved element for
/// writers.
pub fn CT_DocPartBehavior::to_element(
  self : CT_DocPartBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartBehaviors — Part 1 §17.12.2 behaviors (Entry
/// Insertion Behaviors). Wraps an `xsd:choice` containing `<behavior>`
/// (CT_DocPartBehavior §17.12.1) elements with `maxOccurs="unbounded"`
/// (and the default `minOccurs="1"`, so at least one `<behavior>` is
/// expected by the schema). No attributes.
pub(all) struct CT_DocPartBehaviors {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.12.1 `<behavior>`+ (CT_DocPartBehavior) — one or more entry
  /// insertion-behavior children. Each carries the required `@val`
  /// (ST_DocPartBehavior) enumeration validated by CT_DocPartBehavior::new.
  behavior : Array[CT_DocPartBehavior]
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocPartBehaviors — Part 1 §17.12.2. Decode each
/// `<behavior>` child via CT_DocPartBehavior::new (raises on missing `@val`).
pub fn CT_DocPartBehaviors::new(
  element : @xml.Element,
) -> CT_DocPartBehaviors raise SchemaViolation {
  let behavior_elements = wml_ct_chunk4_children(element, "behavior")
  let behavior : Array[CT_DocPartBehavior] = []
  for e in behavior_elements {
    behavior.push(CT_DocPartBehavior::new(e))
  }
  { element, behavior }
}

///|
/// XSD complex type CT_DocPartBehaviors — Part 1 §17.12.2.
pub fn CT_DocPartBehaviors::parse(
  element : @xml.Element,
) -> CT_DocPartBehaviors raise SchemaViolation {
  CT_DocPartBehaviors::new(element)
}

///|
/// XSD complex type CT_DocPartBehaviors — return the preserved element for
/// writers.
pub fn CT_DocPartBehaviors::to_element(
  self : CT_DocPartBehaviors,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartType — Part 1 §17.12.15 type (Entry Type).
/// Carries a required `@val` (ST_DocPartType §17.18.14) selecting the
/// glossary-document-entry type (`none` / `normal` / `autoExp` / `toolbar`
/// / `speller` / `formFld` / `bbPlcHdr`). No children.
pub(all) struct CT_DocPartType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.14 @val (ST_DocPartType) — required entry-type enumeration.
  val : ST_DocPartType
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocPartType — Part 1 §17.12.15. Decode the required
/// ST_DocPartType `@val` attribute.
pub fn CT_DocPartType::new(
  element : @xml.Element,
) -> CT_DocPartType raise SchemaViolation {
  let raw = wml_ct_chunk4_required_attr(
    element, "val", "CT_DocPartType", "Part 1 §17.18.14 ST_DocPartType",
  )
  let val = ST_DocPartType::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_DocPartType — Part 1 §17.12.15.
pub fn CT_DocPartType::parse(
  element : @xml.Element,
) -> CT_DocPartType raise SchemaViolation {
  CT_DocPartType::new(element)
}

///|
/// XSD complex type CT_DocPartType — return the preserved element for writers.
pub fn CT_DocPartType::to_element(self : CT_DocPartType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartTypes from wml.xsd (§17).
pub(all) struct CT_DocPartTypes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPartTypes::new(element : @xml.Element) -> CT_DocPartTypes {
  { element, }
}

///|
pub fn CT_DocPartTypes::parse(element : @xml.Element) -> CT_DocPartTypes {
  CT_DocPartTypes::new(element)
}

///|
pub fn CT_DocPartTypes::to_element(self : CT_DocPartTypes) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartGallery from wml.xsd (§17).
pub(all) struct CT_DocPartGallery {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPartGallery::new(element : @xml.Element) -> CT_DocPartGallery {
  { element, }
}

///|
pub fn CT_DocPartGallery::parse(element : @xml.Element) -> CT_DocPartGallery {
  CT_DocPartGallery::new(element)
}

///|
pub fn CT_DocPartGallery::to_element(self : CT_DocPartGallery) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartCategory from wml.xsd (§17).
pub(all) struct CT_DocPartCategory {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPartCategory::new(element : @xml.Element) -> CT_DocPartCategory {
  { element, }
}

///|
pub fn CT_DocPartCategory::parse(element : @xml.Element) -> CT_DocPartCategory {
  CT_DocPartCategory::new(element)
}

///|
pub fn CT_DocPartCategory::to_element(
  self : CT_DocPartCategory,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartName from wml.xsd (§17).
pub(all) struct CT_DocPartName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPartName::new(element : @xml.Element) -> CT_DocPartName {
  { element, }
}

///|
pub fn CT_DocPartName::parse(element : @xml.Element) -> CT_DocPartName {
  CT_DocPartName::new(element)
}

///|
pub fn CT_DocPartName::to_element(self : CT_DocPartName) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartPr from wml.xsd (§17).
pub(all) struct CT_DocPartPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPartPr::new(element : @xml.Element) -> CT_DocPartPr {
  { element, }
}

///|
pub fn CT_DocPartPr::parse(element : @xml.Element) -> CT_DocPartPr {
  CT_DocPartPr::new(element)
}

///|
pub fn CT_DocPartPr::to_element(self : CT_DocPartPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPart from wml.xsd (§17).
pub(all) struct CT_DocPart {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPart::new(element : @xml.Element) -> CT_DocPart {
  { element, }
}

///|
pub fn CT_DocPart::parse(element : @xml.Element) -> CT_DocPart {
  CT_DocPart::new(element)
}

///|
pub fn CT_DocPart::to_element(self : CT_DocPart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocParts from wml.xsd (§17).
pub(all) struct CT_DocParts {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocParts::new(element : @xml.Element) -> CT_DocParts {
  { element, }
}

///|
pub fn CT_DocParts::parse(element : @xml.Element) -> CT_DocParts {
  CT_DocParts::new(element)
}

///|
pub fn CT_DocParts::to_element(self : CT_DocParts) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocumentBase from wml.xsd (§17).
pub(all) struct CT_DocumentBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocumentBase::new(element : @xml.Element) -> CT_DocumentBase {
  { element, }
}

///|
pub fn CT_DocumentBase::parse(element : @xml.Element) -> CT_DocumentBase {
  CT_DocumentBase::new(element)
}

///|
pub fn CT_DocumentBase::to_element(self : CT_DocumentBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Document from wml.xsd (§17).
pub(all) struct CT_Document {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Document::new(element : @xml.Element) -> CT_Document {
  { element, }
}

///|
pub fn CT_Document::parse(element : @xml.Element) -> CT_Document {
  CT_Document::new(element)
}

///|
pub fn CT_Document::to_element(self : CT_Document) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GlossaryDocument from wml.xsd (§17).
pub(all) struct CT_GlossaryDocument {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GlossaryDocument::new(element : @xml.Element) -> CT_GlossaryDocument {
  { element, }
}

///|
pub fn CT_GlossaryDocument::parse(
  element : @xml.Element,
) -> CT_GlossaryDocument {
  CT_GlossaryDocument::new(element)
}

///|
pub fn CT_GlossaryDocument::to_element(
  self : CT_GlossaryDocument,
) -> @xml.Element {
  self.element
}
