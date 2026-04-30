///|
/// XSD complex type CT_Panose from wml.xsd (§17).
pub(all) struct CT_Panose {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Panose::new(element : @xml.Element) -> CT_Panose {
  { element, }
}

///|
pub fn CT_Panose::parse(element : @xml.Element) -> CT_Panose {
  CT_Panose::new(element)
}

///|
pub fn CT_Panose::to_element(self : CT_Panose) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontFamily from wml.xsd (§17).
pub(all) struct CT_FontFamily {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontFamily::new(element : @xml.Element) -> CT_FontFamily {
  { element, }
}

///|
pub fn CT_FontFamily::parse(element : @xml.Element) -> CT_FontFamily {
  CT_FontFamily::new(element)
}

///|
pub fn CT_FontFamily::to_element(self : CT_FontFamily) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Pitch from wml.xsd (§17).
pub(all) struct CT_Pitch {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Pitch::new(element : @xml.Element) -> CT_Pitch {
  { element, }
}

///|
pub fn CT_Pitch::parse(element : @xml.Element) -> CT_Pitch {
  CT_Pitch::new(element)
}

///|
pub fn CT_Pitch::to_element(self : CT_Pitch) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontSig from wml.xsd (§17).
pub(all) struct CT_FontSig {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontSig::new(element : @xml.Element) -> CT_FontSig {
  { element, }
}

///|
pub fn CT_FontSig::parse(element : @xml.Element) -> CT_FontSig {
  CT_FontSig::new(element)
}

///|
pub fn CT_FontSig::to_element(self : CT_FontSig) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontRel from wml.xsd (§17).
pub(all) struct CT_FontRel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontRel::new(element : @xml.Element) -> CT_FontRel {
  { element, }
}

///|
pub fn CT_FontRel::parse(element : @xml.Element) -> CT_FontRel {
  CT_FontRel::new(element)
}

///|
pub fn CT_FontRel::to_element(self : CT_FontRel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Font from wml.xsd (§17).
pub(all) struct CT_Font {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Font::new(element : @xml.Element) -> CT_Font {
  { element, }
}

///|
pub fn CT_Font::parse(element : @xml.Element) -> CT_Font {
  CT_Font::new(element)
}

///|
pub fn CT_Font::to_element(self : CT_Font) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontsList from wml.xsd (§17).
pub(all) struct CT_FontsList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontsList::new(element : @xml.Element) -> CT_FontsList {
  { element, }
}

///|
pub fn CT_FontsList::parse(element : @xml.Element) -> CT_FontsList {
  CT_FontsList::new(element)
}

///|
pub fn CT_FontsList::to_element(self : CT_FontsList) -> @xml.Element {
  self.element
}
