///|
/// XSD complex type CT_FtnPos from wml.xsd (§17).
pub(all) struct CT_FtnPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FtnPos::new(element : @xml.Element) -> CT_FtnPos {
  { element, }
}

///|
pub fn CT_FtnPos::parse(element : @xml.Element) -> CT_FtnPos {
  CT_FtnPos::new(element)
}

///|
pub fn CT_FtnPos::to_element(self : CT_FtnPos) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EdnPos from wml.xsd (§17).
pub(all) struct CT_EdnPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EdnPos::new(element : @xml.Element) -> CT_EdnPos {
  { element, }
}

///|
pub fn CT_EdnPos::parse(element : @xml.Element) -> CT_EdnPos {
  CT_EdnPos::new(element)
}

///|
pub fn CT_EdnPos::to_element(self : CT_EdnPos) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnEdnRef from wml.xsd (§17).
pub(all) struct CT_FtnEdnRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FtnEdnRef::new(element : @xml.Element) -> CT_FtnEdnRef {
  { element, }
}

///|
pub fn CT_FtnEdnRef::parse(element : @xml.Element) -> CT_FtnEdnRef {
  CT_FtnEdnRef::new(element)
}

///|
pub fn CT_FtnEdnRef::to_element(self : CT_FtnEdnRef) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnEdnSepRef from wml.xsd (§17).
pub(all) struct CT_FtnEdnSepRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FtnEdnSepRef::new(element : @xml.Element) -> CT_FtnEdnSepRef {
  { element, }
}

///|
pub fn CT_FtnEdnSepRef::parse(element : @xml.Element) -> CT_FtnEdnSepRef {
  CT_FtnEdnSepRef::new(element)
}

///|
pub fn CT_FtnEdnSepRef::to_element(self : CT_FtnEdnSepRef) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnEdn from wml.xsd (§17).
pub(all) struct CT_FtnEdn {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FtnEdn::new(element : @xml.Element) -> CT_FtnEdn {
  { element, }
}

///|
pub fn CT_FtnEdn::parse(element : @xml.Element) -> CT_FtnEdn {
  CT_FtnEdn::new(element)
}

///|
pub fn CT_FtnEdn::to_element(self : CT_FtnEdn) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnProps from wml.xsd (§17).
pub(all) struct CT_FtnProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FtnProps::new(element : @xml.Element) -> CT_FtnProps {
  { element, }
}

///|
pub fn CT_FtnProps::parse(element : @xml.Element) -> CT_FtnProps {
  CT_FtnProps::new(element)
}

///|
pub fn CT_FtnProps::to_element(self : CT_FtnProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EdnProps from wml.xsd (§17).
pub(all) struct CT_EdnProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EdnProps::new(element : @xml.Element) -> CT_EdnProps {
  { element, }
}

///|
pub fn CT_EdnProps::parse(element : @xml.Element) -> CT_EdnProps {
  CT_EdnProps::new(element)
}

///|
pub fn CT_EdnProps::to_element(self : CT_EdnProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnDocProps from wml.xsd (§17).
pub(all) struct CT_FtnDocProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FtnDocProps::new(element : @xml.Element) -> CT_FtnDocProps {
  { element, }
}

///|
pub fn CT_FtnDocProps::parse(element : @xml.Element) -> CT_FtnDocProps {
  CT_FtnDocProps::new(element)
}

///|
pub fn CT_FtnDocProps::to_element(self : CT_FtnDocProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EdnDocProps from wml.xsd (§17).
pub(all) struct CT_EdnDocProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EdnDocProps::new(element : @xml.Element) -> CT_EdnDocProps {
  { element, }
}

///|
pub fn CT_EdnDocProps::parse(element : @xml.Element) -> CT_EdnDocProps {
  CT_EdnDocProps::new(element)
}

///|
pub fn CT_EdnDocProps::to_element(self : CT_EdnDocProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Footnotes from wml.xsd (§17).
pub(all) struct CT_Footnotes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Footnotes::new(element : @xml.Element) -> CT_Footnotes {
  { element, }
}

///|
pub fn CT_Footnotes::parse(element : @xml.Element) -> CT_Footnotes {
  CT_Footnotes::new(element)
}

///|
pub fn CT_Footnotes::to_element(self : CT_Footnotes) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Endnotes from wml.xsd (§17).
pub(all) struct CT_Endnotes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Endnotes::new(element : @xml.Element) -> CT_Endnotes {
  { element, }
}

///|
pub fn CT_Endnotes::parse(element : @xml.Element) -> CT_Endnotes {
  CT_Endnotes::new(element)
}

///|
pub fn CT_Endnotes::to_element(self : CT_Endnotes) -> @xml.Element {
  self.element
}
