///|
/// Schema validation error for ECMA-376 DrawingML theme (§20.1.6).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD complex type CT_BaseStyles (§20.1.6): theme element collection.
pub(all) struct CT_BaseStyles {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BaseStyles::new(element : @xml.Element) -> CT_BaseStyles {
  { element, }
}

///|
/// XSD complex type CT_OfficeStyleSheet (§20.1.6): theme part root.
pub(all) struct CT_OfficeStyleSheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeStyleSheet::new(element : @xml.Element) -> CT_OfficeStyleSheet {
  { element, }
}

///|
/// XSD complex type CT_BaseStylesOverride (§20.1.6): theme override root.
pub(all) struct CT_BaseStylesOverride {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BaseStylesOverride::new(
  element : @xml.Element,
) -> CT_BaseStylesOverride {
  { element, }
}

///|
/// XSD complex type CT_OfficeArtExtension (§20.1.2): OfficeArt extension.
pub(all) struct CT_OfficeArtExtension {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeArtExtension::new(
  element : @xml.Element,
) -> CT_OfficeArtExtension {
  { element, }
}

///|
/// XSD complex type CT_OfficeArtExtensionList (§20.1.2): extension list.
pub(all) struct CT_OfficeArtExtensionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeArtExtensionList::new(
  element : @xml.Element,
) -> CT_OfficeArtExtensionList {
  { element, }
}

///|
pub type Theme = CT_OfficeStyleSheet

///|
pub type ThemeOverride = CT_BaseStylesOverride

///|
pub type ThemeManager = CT_OfficeArtExtensionList

///|
pub fn read_theme(bytes : Bytes) -> Theme raise {
  CT_OfficeStyleSheet::new(read_theme_root(bytes, "theme"))
}

///|
pub fn write_theme(value : Theme) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_theme_override(bytes : Bytes) -> ThemeOverride raise {
  CT_BaseStylesOverride::new(read_theme_root(bytes, "themeOverride"))
}

///|
pub fn write_theme_override(value : ThemeOverride) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_theme_manager(bytes : Bytes) -> ThemeManager raise {
  CT_OfficeArtExtensionList::new(read_theme_root(bytes, "themeManager"))
}

///|
pub fn write_theme_manager(value : ThemeManager) -> Bytes {
  write_element(value.element)
}

///|
fn read_theme_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name, local_name)
  validate_theme_element(root)
  root
}

///|
fn validate_theme_element(element : @xml.Element) -> Unit raise SchemaViolation {
  validate_theme_attributes(element)
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      validate_theme_element(child_element)
    }
  }
}

///|
fn validate_theme_attributes(
  element : @xml.Element,
) -> Unit raise SchemaViolation {
  for attribute in element.attributes {
    let name = attribute.name.local_name
    let value = attribute.value
    match name {
      "name" | "uri" => validate_attr(name, value)
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
