///|
/// SpreadsheetML shared string types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn shared_string_type_group_name() -> String {
  "spreadsheet_ml.shared_string"
}

///|
/// XSD complex type CT_XStringElement.
pub(all) struct CT_XStringElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_XStringElement::new(element : @xml.Element) -> CT_XStringElement {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_String: pivot cache string item with tuple and index children plus v, u, f, c, cp, in, bc, fc, i, un, st, b attributes.
pub(all) struct CT_String {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_String::new(element : @xml.Element) -> CT_String {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Sst.
pub(all) struct CT_Sst {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Sst::new(element : @xml.Element) -> CT_Sst {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PhoneticRun.
pub(all) struct CT_PhoneticRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PhoneticRun::new(element : @xml.Element) -> CT_PhoneticRun {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RElt.
pub(all) struct CT_RElt {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RElt::new(element : @xml.Element) -> CT_RElt {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RPrElt: rich text run properties with font, charset, family, bold, italic, strike, color, size, underline, vertical alignment, scheme children.
pub(all) struct CT_RPrElt {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RPrElt::new(element : @xml.Element) -> CT_RPrElt {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Rst.
pub(all) struct CT_Rst {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rst::new(element : @xml.Element) -> CT_Rst {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PhoneticPr.
pub(all) struct CT_PhoneticPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PhoneticPr::new(element : @xml.Element) -> CT_PhoneticPr {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}
