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
  clr_scheme : @a.CT_ColorScheme
  /// <fontScheme> (CT_FontScheme) — required.
  font_scheme : @a.CT_FontScheme
  /// <fmtScheme> (CT_StyleMatrix) — required.
  fmt_scheme : @a.CT_StyleMatrix
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : @a.CT_OfficeArtExtensionList?
} derive(Eq, Debug)

///|
/// Construct CT_BaseStyles from its source XML element.
pub fn CT_BaseStyles::new(
  element : @xml.Element,
) -> CT_BaseStyles raise SchemaViolation {
  let clr_el = required_child(element, "clrScheme", "CT_BaseStyles/clrScheme")
  let font_el = required_child(
    element, "fontScheme", "CT_BaseStyles/fontScheme",
  )
  let fmt_el = required_child(element, "fmtScheme", "CT_BaseStyles/fmtScheme")
  let clr_scheme = wrap_a_violation(
    () => @a.CT_ColorScheme::new(clr_el),
    "CT_BaseStyles/clrScheme",
  )
  let font_scheme = wrap_a_violation(
    () => @a.CT_FontScheme::new(font_el),
    "CT_BaseStyles/fontScheme",
  )
  let fmt_scheme = wrap_a_violation(
    () => @a.CT_StyleMatrix::new(fmt_el),
    "CT_BaseStyles/fmtScheme",
  )
  let ext_lst = match optional_child(element, "extLst") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(
          () => @a.CT_OfficeArtExtensionList::new(e),
          "CT_BaseStyles/extLst",
        ),
      )
  }
  { element, clr_scheme, font_scheme, fmt_scheme, ext_lst }
}

///|
/// XSD complex type CT_OfficeStyleSheet — Part 1 §20.1.6.9.
pub(all) struct CT_OfficeStyleSheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (xsd:string) — optional, default "".
  name : String?
  /// <themeElements> (CT_BaseStyles) — required.
  theme_elements : CT_BaseStyles
  /// <objectDefaults> (CT_ObjectStyleDefaults) — optional.
  object_defaults : @a.CT_ObjectStyleDefaults?
  /// <extraClrSchemeLst> (CT_ColorSchemeList) — optional.
  extra_clr_scheme_lst : @a.CT_ColorSchemeList?
  /// <custClrLst> (CT_CustomColorList) — optional.
  cust_clr_lst : @a.CT_CustomColorList?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : @a.CT_OfficeArtExtensionList?
} derive(Eq, Debug)

///|
/// Construct CT_OfficeStyleSheet from its source XML element.
pub fn CT_OfficeStyleSheet::new(
  element : @xml.Element,
) -> CT_OfficeStyleSheet raise SchemaViolation {
  let theme_el = required_child(
    element, "themeElements", "CT_OfficeStyleSheet/themeElements",
  )
  let theme_elements = CT_BaseStyles::new(theme_el)
  let object_defaults = match optional_child(element, "objectDefaults") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(
          () => @a.CT_ObjectStyleDefaults::new(e),
          "CT_OfficeStyleSheet/objectDefaults",
        ),
      )
  }
  let extra_clr_scheme_lst = match
    optional_child(element, "extraClrSchemeLst") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(
          () => @a.CT_ColorSchemeList::new(e),
          "CT_OfficeStyleSheet/extraClrSchemeLst",
        ),
      )
  }
  let cust_clr_lst = match optional_child(element, "custClrLst") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(
          () => @a.CT_CustomColorList::new(e),
          "CT_OfficeStyleSheet/custClrLst",
        ),
      )
  }
  let ext_lst = match optional_child(element, "extLst") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(
          () => @a.CT_OfficeArtExtensionList::new(e),
          "CT_OfficeStyleSheet/extLst",
        ),
      )
  }
  {
    element,
    name: attr(element, "name"),
    theme_elements,
    object_defaults,
    extra_clr_scheme_lst,
    cust_clr_lst,
    ext_lst,
  }
}

///|
/// XSD complex type CT_BaseStylesOverride — Part 1 §20.1.6.5.
pub(all) struct CT_BaseStylesOverride {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <clrScheme> (CT_ColorScheme) — optional.
  clr_scheme : @a.CT_ColorScheme?
  /// <fontScheme> (CT_FontScheme) — optional.
  font_scheme : @a.CT_FontScheme?
  /// <fmtScheme> (CT_StyleMatrix) — optional.
  fmt_scheme : @a.CT_StyleMatrix?
} derive(Eq, Debug)

///|
/// Construct CT_BaseStylesOverride from its source XML element.
pub fn CT_BaseStylesOverride::new(
  element : @xml.Element,
) -> CT_BaseStylesOverride raise SchemaViolation {
  let clr_scheme = match optional_child(element, "clrScheme") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(
          () => @a.CT_ColorScheme::new(e),
          "CT_BaseStylesOverride/clrScheme",
        ),
      )
  }
  let font_scheme = match optional_child(element, "fontScheme") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(
          () => @a.CT_FontScheme::new(e),
          "CT_BaseStylesOverride/fontScheme",
        ),
      )
  }
  let fmt_scheme = match optional_child(element, "fmtScheme") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(
          () => @a.CT_StyleMatrix::new(e),
          "CT_BaseStylesOverride/fmtScheme",
        ),
      )
  }
  { element, clr_scheme, font_scheme, fmt_scheme }
}

///|
/// XSD complex type CT_OfficeArtExtension — Part 1 §20.1.2.2.14.
/// Required `uri` attribute and an unbounded xsd:any sequence
/// preserved as raw child XML nodes.
pub(all) struct CT_OfficeArtExtension {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @uri (xsd:token) — required.
  uri : String
  /// xsd:any payload children, preserved as parsed @xml.Element values
  /// in document order. Since the schema permits any element under
  /// any namespace, we keep the raw XML rather than synthesising a
  /// typed projection (this is the one place where opaque payload is
  /// the contract, not a sub-task to project).
  payload : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// Construct CT_OfficeArtExtension from its source XML element.
pub fn CT_OfficeArtExtension::new(
  element : @xml.Element,
) -> CT_OfficeArtExtension raise SchemaViolation {
  let uri = require_attr(element, "uri", "CT_OfficeArtExtension/@uri")
  let payload : Array[@xml.Element] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      payload.push(child_element)
    }
  }
  { element, uri, payload }
}

///|
/// XSD complex type CT_OfficeArtExtensionList — Part 1 §20.1.2.2.15.
pub(all) struct CT_OfficeArtExtensionList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <ext>* (CT_OfficeArtExtension) — zero or more extension entries.
  extensions : Array[CT_OfficeArtExtension]
} derive(Eq, Debug)

///|
/// Construct CT_OfficeArtExtensionList from its source XML element.
pub fn CT_OfficeArtExtensionList::new(
  element : @xml.Element,
) -> CT_OfficeArtExtensionList raise SchemaViolation {
  let extensions : Array[CT_OfficeArtExtension] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "ext" {
        extensions.push(CT_OfficeArtExtension::new(child_element))
      }
    }
  }
  { element, extensions }
}

///|
/// Locate a required child element by local name.
fn required_child(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> @xml.Element raise SchemaViolation {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return child_element
        }
      _ => ()
    }
  }
  raise SchemaViolation(
    schema="dml-main.xsd",
    path~,
    reason="required child element is missing",
  )
}

///|
fn optional_child(element : @xml.Element, local_name : String) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return Some(child_element)
        }
      _ => ()
    }
  }
  None
}

///|
fn[T] wrap_a_violation(
  body : () -> T raise @a.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @a.SchemaViolation(schema=_, path=p, reason~) =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path=path + " (" + p + ")",
        reason~,
      )
  }
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
