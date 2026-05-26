///|
/// XSD complex type CT_ColorScheme — Part 1 §20.1.6.2. Required attribute
/// `name` (xsd:string) and required ordered children `dk1`, `lt1`, `dk2`,
/// `lt2`, `accent1`..`accent6`, `hlink`, `folHlink` (each CT_Color) plus an
/// optional `extLst` (CT_OfficeArtExtensionList).
pub(all) struct CT_ColorScheme {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (xsd:string) — required.
  name : String
  /// Local names of named slot children in document order.
  slot_names : Array[String]
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  has_ext_lst : Bool
} derive(Eq, Debug)

///|
pub fn CT_ColorScheme::new(
  element : @xml.Element,
) -> CT_ColorScheme raise SchemaViolation {
  let name = require_attr(element, "name", "CT_ColorScheme/@name")
  let slot_names : Array[String] = []
  let mut has_ext = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let local_name = child_element.name.local_name
      if local_name == "extLst" {
        has_ext = true
      } else {
        slot_names.push(local_name)
      }
    }
  }
  { element, name, slot_names, has_ext_lst: has_ext }
}

///|
/// XSD complex type CT_CustomColor — Part 1 §20.1.4.1.8. Optional `name`
/// attribute (xsd:string, default "") and a required EG_ColorChoice child
/// (one of scrgbClr/srgbClr/hslClr/sysClr/schemeClr/prstClr).
pub(all) struct CT_CustomColor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (xsd:string) — optional, default "".
  name : String?
  /// Local name of the chosen EG_ColorChoice child.
  color_child_name : String
} derive(Eq, Debug)

///|
pub fn CT_CustomColor::new(
  element : @xml.Element,
) -> CT_CustomColor raise SchemaViolation {
  let color = required_color_choice(element, "CT_CustomColor")
  { element, name: attr(element, "name"), color_child_name: color }
}

///|
/// XSD complex type CT_CustomColorList — Part 1 §20.1.4.1.9. Optional
/// unbounded sequence of `custClr` (CT_CustomColor) children.
pub(all) struct CT_CustomColorList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <custClr>* (CT_CustomColor) — zero or more.
  custom_color_count : Int
} derive(Eq, Debug)

///|
pub fn CT_CustomColorList::new(element : @xml.Element) -> CT_CustomColorList {
  let mut count = 0
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "custClr" {
        count = count + 1
      }
    }
  }
  { element, custom_color_count: count }
}

///|
/// XSD complex type CT_ScRgbColor — Part 1 §20.1.2.3.30. Required attributes
/// `r`, `g`, `b` (ST_Percentage) plus an optional EG_ColorTransform sequence
/// preserved here as raw child local names.
pub(all) struct CT_ScRgbColor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r (ST_Percentage) — required.
  r : String
  /// @g (ST_Percentage) — required.
  g : String
  /// @b (ST_Percentage) — required.
  b : String
  /// EG_ColorTransform child local names in document order.
  transform_names : Array[String]
} derive(Eq, Debug)

///|
pub fn CT_ScRgbColor::new(
  element : @xml.Element,
) -> CT_ScRgbColor raise SchemaViolation {
  let r = require_attr(element, "r", "CT_ScRgbColor/@r")
  let g = require_attr(element, "g", "CT_ScRgbColor/@g")
  let b = require_attr(element, "b", "CT_ScRgbColor/@b")
  let transform_names = collect_transform_children(element)
  { element, r, g, b, transform_names }
}

///|
/// XSD complex type CT_SRgbColor — Part 1 §20.1.2.3.32. Required `val`
/// attribute (s:ST_HexColorRGB) plus an optional EG_ColorTransform sequence.
pub(all) struct CT_SRgbColor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (s:ST_HexColorRGB) — required.
  val : String
  /// EG_ColorTransform child local names in document order.
  transform_names : Array[String]
} derive(Eq, Debug)

///|
pub fn CT_SRgbColor::new(
  element : @xml.Element,
) -> CT_SRgbColor raise SchemaViolation {
  let val = require_attr(element, "val", "CT_SRgbColor/@val")
  { element, val, transform_names: collect_transform_children(element) }
}

///|
/// XSD complex type CT_HslColor — Part 1 §20.1.2.3.13. Required attributes
/// `hue` (ST_PositiveFixedAngle), `sat`, `lum` (ST_Percentage) plus an
/// optional EG_ColorTransform sequence.
pub(all) struct CT_HslColor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @hue (ST_PositiveFixedAngle) — required.
  hue : String
  /// @sat (ST_Percentage) — required.
  sat : String
  /// @lum (ST_Percentage) — required.
  lum : String
  /// EG_ColorTransform child local names in document order.
  transform_names : Array[String]
} derive(Eq, Debug)

///|
pub fn CT_HslColor::new(
  element : @xml.Element,
) -> CT_HslColor raise SchemaViolation {
  let hue = require_attr(element, "hue", "CT_HslColor/@hue")
  let sat = require_attr(element, "sat", "CT_HslColor/@sat")
  let lum = require_attr(element, "lum", "CT_HslColor/@lum")
  {
    element,
    hue,
    sat,
    lum,
    transform_names: collect_transform_children(element),
  }
}

///|
/// XSD complex type CT_SystemColor — Part 1 §20.1.2.3.33. Required `val`
/// attribute (ST_SystemColorVal), optional `lastClr` (s:ST_HexColorRGB), plus
/// an optional EG_ColorTransform sequence.
pub(all) struct CT_SystemColor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (ST_SystemColorVal) — required.
  val : String
  /// @lastClr (s:ST_HexColorRGB) — optional.
  last_clr : String?
  /// EG_ColorTransform child local names in document order.
  transform_names : Array[String]
} derive(Eq, Debug)

///|
pub fn CT_SystemColor::new(
  element : @xml.Element,
) -> CT_SystemColor raise SchemaViolation {
  let val = require_attr(element, "val", "CT_SystemColor/@val")
  ST_SystemColorVal::parse(val) |> ignore
  {
    element,
    val,
    last_clr: attr(element, "lastClr"),
    transform_names: collect_transform_children(element),
  }
}

///|
/// XSD complex type CT_SchemeColor — Part 1 §20.1.2.3.29. Required `val`
/// attribute (ST_SchemeColorVal) plus an optional EG_ColorTransform sequence.
pub(all) struct CT_SchemeColor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (ST_SchemeColorVal) — required.
  val : String
  /// EG_ColorTransform child local names in document order.
  transform_names : Array[String]
} derive(Eq, Debug)

///|
pub fn CT_SchemeColor::new(
  element : @xml.Element,
) -> CT_SchemeColor raise SchemaViolation {
  let val = require_attr(element, "val", "CT_SchemeColor/@val")
  ST_SchemeColorVal::parse(val) |> ignore
  { element, val, transform_names: collect_transform_children(element) }
}

///|
/// XSD complex type CT_PresetColor — Part 1 §20.1.2.3.22. Required `val`
/// attribute (ST_PresetColorVal) plus an optional EG_ColorTransform sequence.
pub(all) struct CT_PresetColor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (ST_PresetColorVal) — required.
  val : String
  /// EG_ColorTransform child local names in document order.
  transform_names : Array[String]
} derive(Eq, Debug)

///|
pub fn CT_PresetColor::new(
  element : @xml.Element,
) -> CT_PresetColor raise SchemaViolation {
  let val = require_attr(element, "val", "CT_PresetColor/@val")
  ST_PresetColorVal::parse(val) |> ignore
  { element, val, transform_names: collect_transform_children(element) }
}

///|
/// XSD complex type CT_Color — Part 1 §20.1.2.3.9. Single EG_ColorChoice
/// child (one of scrgbClr/srgbClr/hslClr/sysClr/schemeClr/prstClr).
pub(all) struct CT_Color {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local name of the chosen EG_ColorChoice child.
  color_child_name : String
} derive(Eq, Debug)

///|
pub fn CT_Color::new(element : @xml.Element) -> CT_Color raise SchemaViolation {
  let color = required_color_choice(element, "CT_Color")
  { element, color_child_name: color }
}

///|
/// XSD complex type CT_ColorMRU — Part 1 §20.1.2.3.16. Optional unbounded
/// EG_ColorChoice sequence (most-recently-used colors).
pub(all) struct CT_ColorMRU {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// EG_ColorChoice child local names in document order.
  color_child_names : Array[String]
} derive(Eq, Debug)

///|
pub fn CT_ColorMRU::new(element : @xml.Element) -> CT_ColorMRU {
  let color_child_names : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let local_name = child_element.name.local_name
      if is_color_choice_name(local_name) {
        color_child_names.push(local_name)
      }
    }
  }
  { element, color_child_names }
}

///|
/// XSD complex type CT_ColorChangeEffect — Part 1 §20.1.8.16. Required
/// `<clrFrom>` and `<clrTo>` (CT_Color) children plus optional `useA`
/// attribute (xsd:boolean, default true).
pub(all) struct CT_ColorChangeEffect {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <clrFrom> (CT_Color) — required.
  clr_from_child_name : String
  /// <clrTo> (CT_Color) — required.
  clr_to_child_name : String
  /// @useA (xsd:boolean) — optional, default "true".
  use_a : String?
} derive(Eq, Debug)

///|
pub fn CT_ColorChangeEffect::new(
  element : @xml.Element,
) -> CT_ColorChangeEffect {
  let mut from = ""
  let mut to = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "clrFrom" => from = "clrFrom"
        "clrTo" => to = "clrTo"
        _ => ()
      }
    }
  }
  {
    element,
    clr_from_child_name: from,
    clr_to_child_name: to,
    use_a: attr(element, "useA"),
  }
}

///|
/// XSD complex type CT_ColorReplaceEffect — Part 1 §20.1.8.18. Required
/// EG_ColorChoice child (one of scrgbClr/srgbClr/hslClr/sysClr/schemeClr/
/// prstClr) replacing the source color.
pub(all) struct CT_ColorReplaceEffect {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local name of the chosen EG_ColorChoice child.
  color_child_name : String
} derive(Eq, Debug)

///|
pub fn CT_ColorReplaceEffect::new(
  element : @xml.Element,
) -> CT_ColorReplaceEffect raise SchemaViolation {
  let color = required_color_choice(element, "CT_ColorReplaceEffect")
  { element, color_child_name: color }
}

///|
/// XSD complex type CT_SolidColorFillProperties — Part 1 §20.1.8.54. Optional
/// EG_ColorChoice child (one of scrgbClr/srgbClr/hslClr/sysClr/schemeClr/
/// prstClr).
pub(all) struct CT_SolidColorFillProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local name of the optional EG_ColorChoice child, if present.
  color_child_name : String?
} derive(Eq, Debug)

///|
pub fn CT_SolidColorFillProperties::new(
  element : @xml.Element,
) -> CT_SolidColorFillProperties {
  let mut color : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let local_name = child_element.name.local_name
      if is_color_choice_name(local_name) {
        color = Some(local_name)
      }
    }
  }
  { element, color_child_name: color }
}

///|
/// XSD complex type CT_ColorMapping — Part 1 §20.1.6.3. Required attributes
/// `bg1`, `tx1`, `bg2`, `tx2`, `accent1`..`accent6`, `hlink`, `folHlink`
/// (each ST_ColorSchemeIndex), plus an optional `extLst`
/// (CT_OfficeArtExtensionList) child.
pub(all) struct CT_ColorMapping {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @bg1 (ST_ColorSchemeIndex) — required.
  bg1 : String
  /// @tx1 (ST_ColorSchemeIndex) — required.
  tx1 : String
  /// @bg2 (ST_ColorSchemeIndex) — required.
  bg2 : String
  /// @tx2 (ST_ColorSchemeIndex) — required.
  tx2 : String
  /// @accent1 (ST_ColorSchemeIndex) — required.
  accent1 : String
  /// @accent2 (ST_ColorSchemeIndex) — required.
  accent2 : String
  /// @accent3 (ST_ColorSchemeIndex) — required.
  accent3 : String
  /// @accent4 (ST_ColorSchemeIndex) — required.
  accent4 : String
  /// @accent5 (ST_ColorSchemeIndex) — required.
  accent5 : String
  /// @accent6 (ST_ColorSchemeIndex) — required.
  accent6 : String
  /// @hlink (ST_ColorSchemeIndex) — required.
  hlink : String
  /// @folHlink (ST_ColorSchemeIndex) — required.
  fol_hlink : String
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  has_ext_lst : Bool
} derive(Eq, Debug)

///|
pub fn CT_ColorMapping::new(
  element : @xml.Element,
) -> CT_ColorMapping raise SchemaViolation {
  let bg1 = require_mapping(element, "bg1")
  let tx1 = require_mapping(element, "tx1")
  let bg2 = require_mapping(element, "bg2")
  let tx2 = require_mapping(element, "tx2")
  let accent1 = require_mapping(element, "accent1")
  let accent2 = require_mapping(element, "accent2")
  let accent3 = require_mapping(element, "accent3")
  let accent4 = require_mapping(element, "accent4")
  let accent5 = require_mapping(element, "accent5")
  let accent6 = require_mapping(element, "accent6")
  let hlink = require_mapping(element, "hlink")
  let fol_hlink = require_mapping(element, "folHlink")
  let mut has_ext = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        has_ext = true
      }
    }
  }
  {
    element,
    bg1,
    tx1,
    bg2,
    tx2,
    accent1,
    accent2,
    accent3,
    accent4,
    accent5,
    accent6,
    hlink,
    fol_hlink,
    has_ext_lst: has_ext,
  }
}

///|
/// XSD complex type CT_ColorMappingOverride — Part 1 §20.1.6.10. Single
/// required choice of `<masterClrMapping>` (CT_EmptyElement) or
/// `<overrideClrMapping>` (CT_ColorMapping).
pub(all) struct CT_ColorMappingOverride {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// True when the chosen child is `<masterClrMapping>`.
  is_master : Bool
  /// True when the chosen child is `<overrideClrMapping>`.
  is_override : Bool
} derive(Eq, Debug)

///|
pub fn CT_ColorMappingOverride::new(
  element : @xml.Element,
) -> CT_ColorMappingOverride raise SchemaViolation {
  let mut master = false
  let mut override_ = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "masterClrMapping" => master = true
        "overrideClrMapping" => override_ = true
        _ => ()
      }
    }
  }
  if !(master || override_) {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path="CT_ColorMappingOverride",
      reason="requires masterClrMapping or overrideClrMapping child",
    )
  }
  { element, is_master: master, is_override: override_ }
}

///|
/// XSD complex type CT_ColorSchemeAndMapping — Part 1 §20.1.6.13. Required
/// `<clrScheme>` (CT_ColorScheme) child plus optional `<clrMap>`
/// (CT_ColorMapping) child.
pub(all) struct CT_ColorSchemeAndMapping {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <clrScheme> (CT_ColorScheme) — required.
  clr_scheme_child_name : String
  /// <clrMap> (CT_ColorMapping) — optional.
  has_clr_map : Bool
} derive(Eq, Debug)

///|
pub fn CT_ColorSchemeAndMapping::new(
  element : @xml.Element,
) -> CT_ColorSchemeAndMapping {
  let mut scheme = ""
  let mut map = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "clrScheme" => scheme = "clrScheme"
        "clrMap" => map = true
        _ => ()
      }
    }
  }
  { element, clr_scheme_child_name: scheme, has_clr_map: map }
}

///|
/// XSD complex type CT_ColorSchemeList — Part 1 §20.1.6.14. Optional unbounded
/// sequence of `<extraClrScheme>` (CT_ColorSchemeAndMapping) children.
pub(all) struct CT_ColorSchemeList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <extraClrScheme>* (CT_ColorSchemeAndMapping) — zero or more.
  extra_scheme_count : Int
} derive(Eq, Debug)

///|
pub fn CT_ColorSchemeList::new(element : @xml.Element) -> CT_ColorSchemeList {
  let mut count = 0
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extraClrScheme" {
        count = count + 1
      }
    }
  }
  { element, extra_scheme_count: count }
}

///|
/// XSD complex type CT_TextBulletColorFollowText — Part 1 §21.1.2.4.3. Empty
/// element used as the `<buClrTx>` marker that bullet color follows text.
pub(all) struct CT_TextBulletColorFollowText {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Sentinel marking empty content (xsd:complexType CT_TextBulletColorFollowText has no payload).
  is_empty : Bool
} derive(Eq, Debug)

///|
pub fn CT_TextBulletColorFollowText::new(
  element : @xml.Element,
) -> CT_TextBulletColorFollowText {
  { element, is_empty: true }
}

///|
pub fn read_color_scheme(bytes : Bytes) -> CT_ColorScheme raise {
  CT_ColorScheme::new(read_color_root(bytes, "clrScheme"))
}

///|
pub fn write_color_scheme(value : CT_ColorScheme) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_sc_rgb_color(bytes : Bytes) -> CT_ScRgbColor raise {
  CT_ScRgbColor::new(read_color_root(bytes, "scrgbClr"))
}

///|
pub fn write_sc_rgb_color(value : CT_ScRgbColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_s_rgb_color(bytes : Bytes) -> CT_SRgbColor raise {
  CT_SRgbColor::new(read_color_root(bytes, "srgbClr"))
}

///|
pub fn write_s_rgb_color(value : CT_SRgbColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_hsl_color(bytes : Bytes) -> CT_HslColor raise {
  CT_HslColor::new(read_color_root(bytes, "hslClr"))
}

///|
pub fn write_hsl_color(value : CT_HslColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_system_color(bytes : Bytes) -> CT_SystemColor raise {
  CT_SystemColor::new(read_color_root(bytes, "sysClr"))
}

///|
pub fn write_system_color(value : CT_SystemColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_scheme_color(bytes : Bytes) -> CT_SchemeColor raise {
  CT_SchemeColor::new(read_color_root(bytes, "schemeClr"))
}

///|
pub fn write_scheme_color(value : CT_SchemeColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_preset_color(bytes : Bytes) -> CT_PresetColor raise {
  CT_PresetColor::new(read_color_root(bytes, "prstClr"))
}

///|
pub fn write_preset_color(value : CT_PresetColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_color_mapping(bytes : Bytes) -> CT_ColorMapping raise {
  CT_ColorMapping::new(read_color_root(bytes, "clrMap"))
}

///|
pub fn write_color_mapping(value : CT_ColorMapping) -> Bytes {
  write_element(value.element)
}

///|
fn read_color_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name, local_name)
  validate_color_element(root)
  root
}

///|
fn validate_color_element(element : @xml.Element) -> Unit raise SchemaViolation {
  validate_color_attributes(element)
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      validate_color_element(child_element)
    }
  }
}

///|
fn validate_color_attributes(
  element : @xml.Element,
) -> Unit raise SchemaViolation {
  for attribute in element.attributes {
    let local_name = attribute.name.local_name
    let value = attribute.value
    match (element.name.local_name, local_name) {
      ("sysClr", "val") => ST_SystemColorVal::parse(value) |> ignore
      ("schemeClr", "val") => ST_SchemeColorVal::parse(value) |> ignore
      ("prstClr", "val") => ST_PresetColorVal::parse(value) |> ignore
      ("clrMap", "bg1")
      | ("clrMap", "tx1")
      | ("clrMap", "bg2")
      | ("clrMap", "tx2")
      | ("clrMap", "accent1")
      | ("clrMap", "accent2")
      | ("clrMap", "accent3")
      | ("clrMap", "accent4")
      | ("clrMap", "accent5")
      | ("clrMap", "accent6")
      | ("clrMap", "hlink")
      | ("clrMap", "folHlink") => ST_ColorSchemeIndex::parse(value) |> ignore
      (_, "val")
      | (_, "lastClr")
      | (_, "r")
      | (_, "g")
      | (_, "b")
      | (_, "hue")
      | (_, "sat")
      | (_, "lum")
      | (_, "name")
      | (_, "useA") => validate_non_empty(local_name, value)
      _ => ()
    }
  }
}

///|
fn validate_non_empty(
  path : String,
  value : String,
) -> Unit raise SchemaViolation {
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
fn require_mapping(
  element : @xml.Element,
  local_name : String,
) -> String raise SchemaViolation {
  let value = require_attr(
    element,
    local_name,
    "CT_ColorMapping/@" + local_name,
  )
  ST_ColorSchemeIndex::parse(value) |> ignore
  value
}

///|
fn is_color_choice_name(local_name : String) -> Bool {
  match local_name {
    "scrgbClr" | "srgbClr" | "hslClr" | "sysClr" | "schemeClr" | "prstClr" =>
      true
    _ => false
  }
}

///|
fn required_color_choice(
  element : @xml.Element,
  type_path : String,
) -> String raise SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let local_name = child_element.name.local_name
      if is_color_choice_name(local_name) {
        return local_name
      }
    }
  }
  raise SchemaViolation(
    schema="dml-main.xsd",
    path=type_path,
    reason="required EG_ColorChoice child missing",
  )
}

///|
fn collect_transform_children(element : @xml.Element) -> Array[String] {
  let out : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      out.push(child_element.name.local_name)
    }
  }
  out
}
