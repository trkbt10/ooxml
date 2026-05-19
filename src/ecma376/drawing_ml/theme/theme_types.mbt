///|
/// Schema validation error for ECMA-376 DrawingML theme (§20.1.6).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD complex type CT_BaseStyles — Part 1 §20.1.6.4. Required children
/// `clrScheme` (CT_ColorScheme), `fontScheme` (CT_FontScheme), `fmtScheme`
/// (CT_StyleMatrix), plus optional `extLst` (CT_OfficeArtExtensionList).
pub(all) struct CT_BaseStyles {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <clrScheme> (CT_ColorScheme) — required.
  clr_scheme_child_name : String
  /// <fontScheme> (CT_FontScheme) — required.
  font_scheme_child_name : String
  /// <fmtScheme> (CT_StyleMatrix) — required.
  fmt_scheme_child_name : String
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  has_ext_lst : Bool
} derive(Eq, Debug)

///|
/// Construct CT_BaseStyles from its source XML element.
pub fn CT_BaseStyles::new(element : @xml.Element) -> CT_BaseStyles {
  let mut clr = ""
  let mut font = ""
  let mut fmt = ""
  let mut has_ext = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "clrScheme" => clr = "clrScheme"
        "fontScheme" => font = "fontScheme"
        "fmtScheme" => fmt = "fmtScheme"
        "extLst" => has_ext = true
        _ => ()
      }
    }
  }
  {
    element,
    clr_scheme_child_name: clr,
    font_scheme_child_name: font,
    fmt_scheme_child_name: fmt,
    has_ext_lst: has_ext,
  }
}

///|
/// XSD complex type CT_OfficeStyleSheet — Part 1 §20.1.6.9. Optional `name`
/// attribute (xsd:string, default ""), required `themeElements` (CT_BaseStyles)
/// child, plus optional `objectDefaults`, `extraClrSchemeLst`, `custClrLst`,
/// and `extLst` children.
pub(all) struct CT_OfficeStyleSheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (xsd:string) — optional, default "".
  name : String?
  /// <themeElements> (CT_BaseStyles) — required.
  theme_elements_child_name : String
  /// <objectDefaults> (CT_ObjectStyleDefaults) — optional.
  has_object_defaults : Bool
  /// <extraClrSchemeLst> (CT_ColorSchemeList) — optional.
  has_extra_clr_scheme_lst : Bool
  /// <custClrLst> (CT_CustomColorList) — optional.
  has_cust_clr_lst : Bool
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  has_ext_lst : Bool
} derive(Eq, Debug)

///|
/// Construct CT_OfficeStyleSheet from its source XML element.
pub fn CT_OfficeStyleSheet::new(element : @xml.Element) -> CT_OfficeStyleSheet {
  let mut theme = ""
  let mut obj = false
  let mut extra = false
  let mut cust = false
  let mut ext = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "themeElements" => theme = "themeElements"
        "objectDefaults" => obj = true
        "extraClrSchemeLst" => extra = true
        "custClrLst" => cust = true
        "extLst" => ext = true
        _ => ()
      }
    }
  }
  {
    element,
    name: attr(element, "name"),
    theme_elements_child_name: theme,
    has_object_defaults: obj,
    has_extra_clr_scheme_lst: extra,
    has_cust_clr_lst: cust,
    has_ext_lst: ext,
  }
}

///|
/// XSD complex type CT_BaseStylesOverride — Part 1 §20.1.6.5. Optional children
/// `clrScheme` (CT_ColorScheme), `fontScheme` (CT_FontScheme), and `fmtScheme`
/// (CT_StyleMatrix).
pub(all) struct CT_BaseStylesOverride {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <clrScheme> (CT_ColorScheme) — optional.
  has_clr_scheme : Bool
  /// <fontScheme> (CT_FontScheme) — optional.
  has_font_scheme : Bool
  /// <fmtScheme> (CT_StyleMatrix) — optional.
  has_fmt_scheme : Bool
} derive(Eq, Debug)

///|
/// Construct CT_BaseStylesOverride from its source XML element.
pub fn CT_BaseStylesOverride::new(
  element : @xml.Element,
) -> CT_BaseStylesOverride {
  let mut clr = false
  let mut font = false
  let mut fmt = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "clrScheme" => clr = true
        "fontScheme" => font = true
        "fmtScheme" => fmt = true
        _ => ()
      }
    }
  }
  { element, has_clr_scheme: clr, has_font_scheme: font, has_fmt_scheme: fmt }
}

///|
/// XSD complex type CT_OfficeArtExtension — Part 1 §20.1.2.2.14. Required
/// `uri` attribute (xsd:token) and an unbounded xsd:any sequence preserved as
/// raw payload.
pub(all) struct CT_OfficeArtExtension {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @uri (xsd:token) — required.
  uri : String
  /// Local names of preserved xsd:any payload children.
  payload_names : Array[String]
} derive(Eq, Debug)

///|
/// Construct CT_OfficeArtExtension from its source XML element.
pub fn CT_OfficeArtExtension::new(
  element : @xml.Element,
) -> CT_OfficeArtExtension raise SchemaViolation {
  let uri = require_attr(element, "uri", "CT_OfficeArtExtension/@uri")
  let payload_names : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      payload_names.push(child_element.name.local_name)
    }
  }
  { element, uri, payload_names }
}

///|
/// XSD complex type CT_OfficeArtExtensionList — Part 1 §20.1.2.2.15. Wraps an
/// unbounded sequence of `ext` (CT_OfficeArtExtension) children.
pub(all) struct CT_OfficeArtExtensionList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <ext>* (CT_OfficeArtExtension) — zero or more extension entries.
  extension_count : Int
} derive(Eq, Debug)

///|
/// Construct CT_OfficeArtExtensionList from its source XML element.
pub fn CT_OfficeArtExtensionList::new(
  element : @xml.Element,
) -> CT_OfficeArtExtensionList {
  let mut count = 0
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "ext" {
        count = count + 1
      }
    }
  }
  { element, extension_count: count }
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
fn attr(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
fn require_attr(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise SchemaViolation {
  match attr(element, local_name) {
    Some(value) => value
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path~,
        reason="required attribute missing",
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
