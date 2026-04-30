///|
/// XSD complex type CT_Height from wml.xsd (§17).
pub(all) struct CT_Height {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Height::new(element : @xml.Element) -> CT_Height {
  { element, }
}

///|
pub fn CT_Height::parse(element : @xml.Element) -> CT_Height {
  CT_Height::new(element)
}

///|
pub fn CT_Height::to_element(self : CT_Height) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Headers from wml.xsd (§17).
pub(all) struct CT_Headers {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Headers::new(element : @xml.Element) -> CT_Headers {
  { element, }
}

///|
pub fn CT_Headers::parse(element : @xml.Element) -> CT_Headers {
  CT_Headers::new(element)
}

///|
pub fn CT_Headers::to_element(self : CT_Headers) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Base64Binary from wml.xsd (§17).
pub(all) struct CT_Base64Binary {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Base64Binary::new(element : @xml.Element) -> CT_Base64Binary {
  { element, }
}

///|
pub fn CT_Base64Binary::parse(element : @xml.Element) -> CT_Base64Binary {
  CT_Base64Binary::new(element)
}

///|
pub fn CT_Base64Binary::to_element(self : CT_Base64Binary) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Body from wml.xsd (§17).
pub(all) struct CT_Body {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Body::new(element : @xml.Element) -> CT_Body {
  { element, }
}

///|
pub fn CT_Body::parse(element : @xml.Element) -> CT_Body {
  CT_Body::new(element)
}

///|
pub fn CT_Body::to_element(self : CT_Body) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Comments from wml.xsd (§17).
pub(all) struct CT_Comments {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Comments::new(element : @xml.Element) -> CT_Comments {
  { element, }
}

///|
pub fn CT_Comments::parse(element : @xml.Element) -> CT_Comments {
  CT_Comments::new(element)
}

///|
pub fn CT_Comments::to_element(self : CT_Comments) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTagType from wml.xsd (§17).
pub(all) struct CT_SmartTagType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTagType::new(element : @xml.Element) -> CT_SmartTagType {
  { element, }
}

///|
pub fn CT_SmartTagType::parse(element : @xml.Element) -> CT_SmartTagType {
  CT_SmartTagType::new(element)
}

///|
pub fn CT_SmartTagType::to_element(self : CT_SmartTagType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartBehavior from wml.xsd (§17).
pub(all) struct CT_DocPartBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPartBehavior::new(element : @xml.Element) -> CT_DocPartBehavior {
  { element, }
}

///|
pub fn CT_DocPartBehavior::parse(element : @xml.Element) -> CT_DocPartBehavior {
  CT_DocPartBehavior::new(element)
}

///|
pub fn CT_DocPartBehavior::to_element(
  self : CT_DocPartBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartBehaviors from wml.xsd (§17).
pub(all) struct CT_DocPartBehaviors {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPartBehaviors::new(element : @xml.Element) -> CT_DocPartBehaviors {
  { element, }
}

///|
pub fn CT_DocPartBehaviors::parse(
  element : @xml.Element,
) -> CT_DocPartBehaviors {
  CT_DocPartBehaviors::new(element)
}

///|
pub fn CT_DocPartBehaviors::to_element(
  self : CT_DocPartBehaviors,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocPartType from wml.xsd (§17).
pub(all) struct CT_DocPartType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocPartType::new(element : @xml.Element) -> CT_DocPartType {
  { element, }
}

///|
pub fn CT_DocPartType::parse(element : @xml.Element) -> CT_DocPartType {
  CT_DocPartType::new(element)
}

///|
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
