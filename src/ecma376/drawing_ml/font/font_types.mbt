///|
/// XSD complex type CT_TextFont — Part 1 §20.1.4.1.28. Required attribute
/// `typeface` (ST_TextTypeface), optional `panose` (s:ST_Panose),
/// `pitchFamily` (ST_PitchFamily, default "0"), and `charset` (xsd:byte,
/// default "1").
pub(all) struct CT_TextFont {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @typeface (ST_TextTypeface) — required.
  typeface : String
  /// @panose (s:ST_Panose) — optional.
  panose : String?
  /// @pitchFamily (ST_PitchFamily) — optional, default "0".
  pitch_family : String?
  /// @charset (xsd:byte) — optional, default "1".
  charset : String?
} derive(Eq, Debug)

///|
/// Construct CT_TextFont from its source XML element.
pub fn CT_TextFont::new(
  element : @xml.Element,
) -> CT_TextFont raise SchemaViolation {
  let typeface = require_attr(element, "typeface", "CT_TextFont/@typeface")
  ST_TextTypeface::parse(typeface) |> ignore
  {
    element,
    typeface,
    panose: attr(element, "panose"),
    pitch_family: attr(element, "pitchFamily"),
    charset: attr(element, "charset"),
  }
}

///|
/// XSD complex type CT_SupplementalFont — Part 1 §20.1.4.1.27. Required
/// attributes `script` (xsd:string) and `typeface` (ST_TextTypeface).
pub(all) struct CT_SupplementalFont {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @script (xsd:string) — required.
  script : String
  /// @typeface (ST_TextTypeface) — required.
  typeface : String
} derive(Eq, Debug)

///|
/// Construct CT_SupplementalFont from its source XML element.
pub fn CT_SupplementalFont::new(
  element : @xml.Element,
) -> CT_SupplementalFont raise SchemaViolation {
  let script = require_attr(element, "script", "CT_SupplementalFont/@script")
  let typeface = require_attr(
    element, "typeface", "CT_SupplementalFont/@typeface",
  )
  ST_TextTypeface::parse(typeface) |> ignore
  { element, script, typeface }
}

///|
/// XSD complex type CT_FontCollection — Part 1 §20.1.4.1.9. Required children
/// `latin`, `ea`, `cs` (CT_TextFont) plus unbounded `font` (CT_SupplementalFont)
/// and optional `extLst` (CT_OfficeArtExtensionList).
pub(all) struct CT_FontCollection {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <latin> (CT_TextFont) — required.
  latin_child_name : String
  /// <ea> (CT_TextFont) — required.
  ea_child_name : String
  /// <cs> (CT_TextFont) — required.
  cs_child_name : String
  /// <font>* (CT_SupplementalFont) — zero or more script-specific fonts.
  supplemental_count : Int
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  has_ext_lst : Bool
} derive(Eq, Debug)

///|
/// Construct CT_FontCollection from its source XML element.
pub fn CT_FontCollection::new(element : @xml.Element) -> CT_FontCollection {
  let mut latin = ""
  let mut ea = ""
  let mut cs = ""
  let mut supplemental = 0
  let mut has_ext = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "latin" => latin = "latin"
        "ea" => ea = "ea"
        "cs" => cs = "cs"
        "font" => supplemental = supplemental + 1
        "extLst" => has_ext = true
        _ => ()
      }
    }
  }
  {
    element,
    latin_child_name: latin,
    ea_child_name: ea,
    cs_child_name: cs,
    supplemental_count: supplemental,
    has_ext_lst: has_ext,
  }
}

///|
/// XSD complex type CT_FontScheme — Part 1 §20.1.4.1.18. Required attribute
/// `name` (xsd:string) and required children `majorFont` and `minorFont`
/// (CT_FontCollection) plus optional `extLst` (CT_OfficeArtExtensionList).
pub(all) struct CT_FontScheme {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (xsd:string) — required.
  name : String
  /// <majorFont> (CT_FontCollection) — required.
  major_font_child_name : String
  /// <minorFont> (CT_FontCollection) — required.
  minor_font_child_name : String
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  has_ext_lst : Bool
} derive(Eq, Debug)

///|
/// Construct CT_FontScheme from its source XML element.
pub fn CT_FontScheme::new(
  element : @xml.Element,
) -> CT_FontScheme raise SchemaViolation {
  let name = require_attr(element, "name", "CT_FontScheme/@name")
  let mut major = ""
  let mut minor = ""
  let mut has_ext = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "majorFont" => major = "majorFont"
        "minorFont" => minor = "minorFont"
        "extLst" => has_ext = true
        _ => ()
      }
    }
  }
  {
    element,
    name,
    major_font_child_name: major,
    minor_font_child_name: minor,
    has_ext_lst: has_ext,
  }
}

///|
/// XSD complex type CT_FontReference — Part 1 §20.1.4.1.17. Required attribute
/// `idx` (ST_FontCollectionIndex); optional EG_ColorChoice child (preserved
/// raw because the EG group is consumed elsewhere).
pub(all) struct CT_FontReference {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @idx (ST_FontCollectionIndex) — required.
  idx : String
  /// Local name of the optional EG_ColorChoice child, if present.
  color_choice_child_name : String?
} derive(Eq, Debug)

///|
/// Construct CT_FontReference from its source XML element.
pub fn CT_FontReference::new(
  element : @xml.Element,
) -> CT_FontReference raise SchemaViolation {
  let idx = require_attr(element, "idx", "CT_FontReference/@idx")
  validate_font_collection_index(idx)
  let mut color : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "scrgbClr"
        | "srgbClr"
        | "hslClr"
        | "sysClr"
        | "schemeClr"
        | "prstClr" => color = Some(child_element.name.local_name)
        _ => ()
      }
    }
  }
  { element, idx, color_choice_child_name: color }
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

///|
/// Validate ST_FontCollectionIndex per dml-main.xsd (§20.1.4): major, minor,
/// none.
fn validate_font_collection_index(value : String) -> Unit raise SchemaViolation {
  match value {
    "major" | "minor" | "none" => ()
    _ =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="ST_FontCollectionIndex",
        reason="invalid enumeration value",
      )
  }
}
