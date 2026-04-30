///|
/// XSD complex type CT_TextFont (§20.1.4): typeface descriptor.
pub(all) struct CT_TextFont {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextFont::new(element : @xml.Element) -> CT_TextFont {
  { element, }
}

///|
/// XSD complex type CT_SupplementalFont (§20.1.4): script-specific font.
pub(all) struct CT_SupplementalFont {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SupplementalFont::new(element : @xml.Element) -> CT_SupplementalFont {
  { element, }
}

///|
/// XSD complex type CT_FontCollection (§20.1.4): major or minor font set.
pub(all) struct CT_FontCollection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontCollection::new(element : @xml.Element) -> CT_FontCollection {
  { element, }
}

///|
/// XSD complex type CT_FontScheme (§20.1.4): theme font scheme.
pub(all) struct CT_FontScheme {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontScheme::new(element : @xml.Element) -> CT_FontScheme {
  { element, }
}

///|
/// XSD complex type CT_FontReference (§20.1.4): font collection reference.
pub(all) struct CT_FontReference {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontReference::new(element : @xml.Element) -> CT_FontReference {
  { element, }
}

///|
pub fn read_text_font(bytes : Bytes) -> CT_TextFont raise {
  CT_TextFont::new(read_font_root(bytes, "latin"))
}

///|
pub fn write_text_font(value : CT_TextFont) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_font_scheme(bytes : Bytes) -> CT_FontScheme raise {
  CT_FontScheme::new(read_font_root(bytes, "fontScheme"))
}

///|
pub fn write_font_scheme(value : CT_FontScheme) -> Bytes {
  write_element(value.element)
}

///|
fn read_font_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name, local_name)
  validate_font_element(root)
  root
}

///|
fn validate_font_element(element : @xml.Element) -> Unit raise SchemaViolation {
  validate_font_attributes(element)
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      validate_font_element(child_element)
    }
  }
}

///|
fn validate_font_attributes(
  element : @xml.Element,
) -> Unit raise SchemaViolation {
  for attribute in element.attributes {
    let name = attribute.name.local_name
    let value = attribute.value
    match name {
      "typeface" => ST_TextTypeface::parse(value) |> ignore
      "pitchFamily" => ST_PitchFamily::parse(value) |> ignore
      "charset" | "panose" | "name" | "script" => validate_attr(name, value)
      "idx" => validate_attr(name, value)
      _ => ()
    }
  }
}

///|
fn validate_attr(path : String, value : String) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="empty attribute value",
    )
  }
}

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="unexpected element name",
    )
  }
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}
