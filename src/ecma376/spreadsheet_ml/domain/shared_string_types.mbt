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
/// XSD complex type CT_String: Schema sml.xsd complex type `CT_String` has
/// attributes `v`, `u`, `f`, `c`, `cp`, `in`, `bc`, `fc`, `i`, `un`, `st`,
/// and `b`, with `tpls` and `x` children; CT_String and CT_String::new own
/// that pivot cache string item.
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

///|
fn shared_string_is_element(
  element : @xml.Element,
  local_name : String,
) -> Bool {
  element.name.local_name == local_name
}

///|
fn shared_string_text_element_value(element : @xml.Element) -> String {
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
/// §18.4 — concatenate the rich-text run elements of CT_Rst into the
/// plain-text string value the cell would display. Joins each CT_RElt
/// `t` (text) child verbatim, dropping rPr formatting markup.
pub fn CT_Rst::to_plain_text(self : CT_Rst) -> String {
  let mut out = ""
  for child in self.element.children {
    match child {
      @xml.Node::Element(element) =>
        if shared_string_is_element(element, "t") {
          out = out + shared_string_text_element_value(element)
        } else if shared_string_is_element(element, "r") {
          out = out + CT_RElt::new(element).to_plain_text()
        }
      _ => ()
    }
  }
  out
}

///|
/// §18.4 — return the entries of the shared string table as an array
/// of CT_Rst values in document order. Index 0 corresponds to the first
/// `<si>` child of `<sst>`. Iterates element children once and skips
/// foreign or whitespace nodes.
pub fn CT_Sst::entries(self : CT_Sst) -> Array[CT_Rst] {
  let entries : Array[CT_Rst] = []
  for child in self.element.children {
    match child {
      @xml.Node::Element(element) =>
        if shared_string_is_element(element, "si") {
          entries.push(CT_Rst::new(element))
        }
      _ => ()
    }
  }
  entries
}

///|
/// §18.4 — resolve a 0-based SST index to its plain-text representation.
/// Returns None if the index is out of range. The resolved string is
/// the concatenation of the entry's run-element text per to_plain_text.
pub fn CT_Sst::lookup(self : CT_Sst, index : Int) -> String? {
  if index < 0 {
    None
  } else {
    match self.entries().get(index) {
      Some(entry) => Some(entry.to_plain_text())
      None => None
    }
  }
}

///|
/// §18.4 — number of entries in the shared string table.
pub fn CT_Sst::count(self : CT_Sst) -> Int {
  let mut count = 0
  for child in self.element.children {
    match child {
      @xml.Node::Element(element) =>
        if shared_string_is_element(element, "si") {
          count += 1
        }
      _ => ()
    }
  }
  count
}

///|
/// §18.4 — extract plain text from the rich-text run element. The
/// run's text is in the `<t>` child; rPr formatting markup is ignored
/// for the purposes of cell-display value computation.
pub fn CT_RElt::to_plain_text(self : CT_RElt) -> String {
  let mut out = ""
  for child in self.element.children {
    match child {
      @xml.Node::Element(element) =>
        if shared_string_is_element(element, "t") {
          out = out + shared_string_text_element_value(element)
        }
      _ => ()
    }
  }
  out
}
