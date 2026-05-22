// ECMA-376 Part 1 §20.1.2.3 / §20.1.4 / §20.1.6 / §20.1.8 / §20.1.10
// DrawingML color complex types. XSD definitions live in Annex A.4.1
// dml-main.xsd at the following line ranges:
//
//   CT_ColorScheme              lines  85..102
//   CT_CustomColor              lines 103..108
//   CT_CustomColorList          lines 113..117
//   CT_ScRgbColor               lines 307..314
//   CT_SRgbColor                lines 315..320
//   CT_HslColor                 lines 321..328
//   CT_SystemColor              lines 363..369
//   CT_SchemeColor              lines 391..396
//   CT_PresetColor              lines 591..596
//   CT_Color                    lines 677..681
//   CT_ColorMRU                 lines 682..686
//   CT_ColorChangeEffect        lines 1268..1274
//   CT_ColorReplaceEffect       lines 1275..1279
//   CT_SolidColorFillProperties lines 1391..1395
//   CT_ColorMapping             lines 2284..2300
//   CT_ColorMappingOverride     lines 2301..2308
//   CT_ColorSchemeAndMapping    lines 2309..2314
//   CT_ColorSchemeList          lines 2315..2320
//   CT_TextBulletColorFollowText line 2711
//   EG_ColorTransform           lines  56..84 (the 28-arm choice
//                                            shared by every CT_*Color)
//
// Each typed projection captures the schema-mandated attributes and
// child elements while preserving the source `@xml.Element` for
// builder round-trip (ct-typing protocol).


///|
/// XSD complex type CT_Color — Part 1 §20.1.2.3.5 (color choice
/// container). Annex A.4.1 lines 677..681. Wraps the
/// EG_ColorChoice group (one of scrgbClr, srgbClr, hslClr, sysClr,
/// schemeClr, prstClr).
pub(all) struct CT_Color {
  /// <scrgbClr> arm of EG_ColorChoice (CT_ScRgbColor), when present.
  scrgb_clr : CT_ScRgbColor?
  /// <srgbClr> arm of EG_ColorChoice (CT_SRgbColor), when present.
  srgb_clr : CT_SRgbColor?
  /// <hslClr> arm of EG_ColorChoice (CT_HslColor), when present.
  hsl_clr : CT_HslColor?
  /// <sysClr> arm of EG_ColorChoice (CT_SystemColor), when present.
  sys_clr : CT_SystemColor?
  /// <schemeClr> arm of EG_ColorChoice (CT_SchemeColor), when present.
  scheme_clr : CT_SchemeColor?
  /// <prstClr> arm of EG_ColorChoice (CT_PresetColor), when present.
  prst_clr : CT_PresetColor?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Color::new(element : @xml.Element) -> CT_Color raise SchemaViolation {
  let scrgb_clr = match ct_first_child(element, "scrgbClr") {
    Some(c) => Some(CT_ScRgbColor::new(c))
    None => None
  }
  let srgb_clr = match ct_first_child(element, "srgbClr") {
    Some(c) => Some(CT_SRgbColor::new(c))
    None => None
  }
  let hsl_clr = match ct_first_child(element, "hslClr") {
    Some(c) => Some(CT_HslColor::new(c))
    None => None
  }
  let sys_clr = match ct_first_child(element, "sysClr") {
    Some(c) => Some(CT_SystemColor::new(c))
    None => None
  }
  let scheme_clr = match ct_first_child(element, "schemeClr") {
    Some(c) => Some(CT_SchemeColor::new(c))
    None => None
  }
  let prst_clr = match ct_first_child(element, "prstClr") {
    Some(c) => Some(CT_PresetColor::new(c))
    None => None
  }
  { scrgb_clr, srgb_clr, hsl_clr, sys_clr, scheme_clr, prst_clr, element }
}

///|
pub fn CT_Color::to_element(self : CT_Color) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ScRgbColor — Part 1 §20.1.2.3.30. Annex A.4.1
/// lines 307..314. Carries the EG_ColorTransform group (unbounded)
/// and the three required ST_Percentage channel attributes `r`, `g`,
/// `b`. The transform children are captured as raw elements pending
/// the typed color-transform projection in a later chunk.
pub(all) struct CT_ScRgbColor {
  /// @r — ST_Percentage (required).
  r : ST_Percentage
  /// @g — ST_Percentage (required).
  g : ST_Percentage
  /// @b — ST_Percentage (required).
  b : ST_Percentage
  /// EG_ColorTransform children in document order — typed per
  /// Annex A.4.1 lines 56..84. Unknown / future-extension children
  /// (xsd:any) are silently skipped; known ones with malformed
  /// attributes raise SchemaViolation at construction time.
  color_transforms : Array[EG_ColorTransform]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ScRgbColor::new(
  element : @xml.Element,
) -> CT_ScRgbColor raise SchemaViolation {
  let r_lex = ct_required_string(element, "r", "CT_ScRgbColor/@r")
  let g_lex = ct_required_string(element, "g", "CT_ScRgbColor/@g")
  let b_lex = ct_required_string(element, "b", "CT_ScRgbColor/@b")
  let r = ST_Percentage::parse(r_lex)
  let g = ST_Percentage::parse(g_lex)
  let b = ST_Percentage::parse(b_lex)
  let color_transforms = collect_color_transforms(element)
  { r, g, b, color_transforms, element }
}

///|
pub fn CT_ScRgbColor::to_element(self : CT_ScRgbColor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SRgbColor — Part 1 §20.1.2.3.32 srgbClr.
/// Annex A.4.1 lines 315..320. Carries the EG_ColorTransform group
/// (unbounded) and a required ST_HexColorRGB `val` attribute.
pub(all) struct CT_SRgbColor {
  /// @val — s:ST_HexColorRGB (required, RRGGBB hex lexical form).
  val : String
  /// EG_ColorTransform children in document order — typed per
  /// Annex A.4.1 lines 56..84. Unknown / future-extension children
  /// (xsd:any) are silently skipped; known ones with malformed
  /// attributes raise SchemaViolation at construction time.
  color_transforms : Array[EG_ColorTransform]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SRgbColor::new(
  element : @xml.Element,
) -> CT_SRgbColor raise SchemaViolation {
  let val = ct_required_string(element, "val", "CT_SRgbColor/@val")
  let color_transforms = collect_color_transforms(element)
  { val, color_transforms, element }
}

///|
pub fn CT_SRgbColor::to_element(self : CT_SRgbColor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HslColor — Part 1 §20.1.2.3.13 hslClr. Annex
/// A.4.1 lines 321..328. Carries the EG_ColorTransform group
/// (unbounded) and the required `hue` / `sat` / `lum` attributes.
pub(all) struct CT_HslColor {
  /// @hue — ST_PositiveFixedAngle (required).
  hue : ST_PositiveFixedAngle
  /// @sat — ST_Percentage (required).
  sat : ST_Percentage
  /// @lum — ST_Percentage (required).
  lum : ST_Percentage
  /// EG_ColorTransform children in document order — typed per
  /// Annex A.4.1 lines 56..84. Unknown / future-extension children
  /// (xsd:any) are silently skipped; known ones with malformed
  /// attributes raise SchemaViolation at construction time.
  color_transforms : Array[EG_ColorTransform]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HslColor::new(
  element : @xml.Element,
) -> CT_HslColor raise SchemaViolation {
  let hue_lex = ct_required_string(element, "hue", "CT_HslColor/@hue")
  let sat_lex = ct_required_string(element, "sat", "CT_HslColor/@sat")
  let lum_lex = ct_required_string(element, "lum", "CT_HslColor/@lum")
  let hue = ST_PositiveFixedAngle::parse(hue_lex)
  let sat = ST_Percentage::parse(sat_lex)
  let lum = ST_Percentage::parse(lum_lex)
  let color_transforms = collect_color_transforms(element)
  { hue, sat, lum, color_transforms, element }
}

///|
pub fn CT_HslColor::to_element(self : CT_HslColor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SystemColor — Part 1 §20.1.2.3.33 sysClr.
/// Annex A.4.1 lines 363..369. Carries the EG_ColorTransform group
/// (unbounded), required `val` (ST_SystemColorVal) and optional
/// `lastClr` (s:ST_HexColorRGB) snapshot of the resolved color.
pub(all) struct CT_SystemColor {
  /// @val — ST_SystemColorVal (required).
  val : ST_SystemColorVal
  /// @lastClr — s:ST_HexColorRGB (optional). When present this is the
  /// most-recently-resolved RGB snapshot of the system color.
  last_clr : String?
  /// EG_ColorTransform children in document order — typed per
  /// Annex A.4.1 lines 56..84. Unknown / future-extension children
  /// (xsd:any) are silently skipped; known ones with malformed
  /// attributes raise SchemaViolation at construction time.
  color_transforms : Array[EG_ColorTransform]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SystemColor::new(
  element : @xml.Element,
) -> CT_SystemColor raise SchemaViolation {
  let val_lex = ct_required_string(element, "val", "CT_SystemColor/@val")
  let val = ST_SystemColorVal::parse(val_lex)
  let last_clr = ct_attr(element, "lastClr")
  let color_transforms = collect_color_transforms(element)
  { val, last_clr, color_transforms, element }
}

///|
pub fn CT_SystemColor::to_element(self : CT_SystemColor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SchemeColor — Part 1 §20.1.2.3.29 schemeClr.
/// Annex A.4.1 lines 391..396. Carries the EG_ColorTransform group
/// (unbounded) and required `val` (ST_SchemeColorVal).
pub(all) struct CT_SchemeColor {
  /// @val — ST_SchemeColorVal (required).
  val : ST_SchemeColorVal
  /// EG_ColorTransform children in document order — typed per
  /// Annex A.4.1 lines 56..84. Unknown / future-extension children
  /// (xsd:any) are silently skipped; known ones with malformed
  /// attributes raise SchemaViolation at construction time.
  color_transforms : Array[EG_ColorTransform]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SchemeColor::new(
  element : @xml.Element,
) -> CT_SchemeColor raise SchemaViolation {
  let val_lex = ct_required_string(element, "val", "CT_SchemeColor/@val")
  let val = ST_SchemeColorVal::parse(val_lex)
  let color_transforms = collect_color_transforms(element)
  { val, color_transforms, element }
}

///|
pub fn CT_SchemeColor::to_element(self : CT_SchemeColor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresetColor — Part 1 §20.1.2.3.22 prstClr.
/// Annex A.4.1 lines 591..596. Carries the EG_ColorTransform group
/// (unbounded) and required `val` (ST_PresetColorVal).
pub(all) struct CT_PresetColor {
  /// @val — ST_PresetColorVal (required).
  val : ST_PresetColorVal
  /// EG_ColorTransform children in document order — typed per
  /// Annex A.4.1 lines 56..84. Unknown / future-extension children
  /// (xsd:any) are silently skipped; known ones with malformed
  /// attributes raise SchemaViolation at construction time.
  color_transforms : Array[EG_ColorTransform]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetColor::new(
  element : @xml.Element,
) -> CT_PresetColor raise SchemaViolation {
  let val_lex = ct_required_string(element, "val", "CT_PresetColor/@val")
  let val = ST_PresetColorVal::parse(val_lex)
  let color_transforms = collect_color_transforms(element)
  { val, color_transforms, element }
}

///|
pub fn CT_PresetColor::to_element(self : CT_PresetColor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomColor — Part 1 §20.1.4.1.8 custClr.
/// Annex A.4.1 lines 103..108. Wraps the EG_ColorChoice group via
/// a CT_Color and optional `name` (xsd:string, default "").
pub(all) struct CT_CustomColor {
  /// @name — xsd:string (optional, default "").
  name : String
  /// EG_ColorChoice arms — captured as a CT_Color projection because
  /// the choice machinery is shared with CT_Color (one of scrgbClr,
  /// srgbClr, hslClr, sysClr, schemeClr, prstClr). Stored as Option
  /// because the inner color-choice may be absent in tolerant
  /// inputs; the spec requires it.
  color : CT_Color?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomColor::new(
  element : @xml.Element,
) -> CT_CustomColor raise SchemaViolation {
  let name = ct_optional_string(element, "name", default="")
  // Re-use CT_Color's decoder by treating the custClr body as a
  // CT_Color projection — the EG_ColorChoice arms are the same.
  let color = if has_any_color_choice_child(element) {
    Some(CT_Color::new(element))
  } else {
    None
  }
  { name, color, element }
}

///|
pub fn CT_CustomColor::to_element(self : CT_CustomColor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomColorList — Part 1 §20.1.6.3 custClrLst.
/// Annex A.4.1 lines 113..117. Sequence of zero or more
/// `custClr` (CT_CustomColor) children.
pub(all) struct CT_CustomColorList {
  /// <custClr>* — zero or more CT_CustomColor children in document order.
  cust_clr : Array[CT_CustomColor]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomColorList::new(
  element : @xml.Element,
) -> CT_CustomColorList raise SchemaViolation {
  let children = ct_children(element, "custClr")
  let cust_clr : Array[CT_CustomColor] = []
  for c in children {
    cust_clr.push(CT_CustomColor::new(c))
  }
  { cust_clr, element }
}

///|
pub fn CT_CustomColorList::to_element(
  self : CT_CustomColorList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorScheme — Part 1 §20.1.6.2 clrScheme.
/// Annex A.4.1 lines 85..102. Required `name` attribute plus the
/// thirteen required CT_Color slots (dk1, lt1, dk2, lt2,
/// accent1..accent6, hlink, folHlink) and the optional
/// CT_OfficeArtExtensionList `extLst`.
///
/// Slots are modelled as `CT_Color?` so the decoder tolerates input
/// fixtures that exercise a subset of the scheme; the schema declares
/// each slot `minOccurs=1`.
pub(all) struct CT_ColorScheme {
  /// @name — xsd:string (required).
  name : String
  /// <dk1> — CT_Color (required per spec).
  dk1 : CT_Color?
  /// <lt1> — CT_Color (required per spec).
  lt1 : CT_Color?
  /// <dk2> — CT_Color (required per spec).
  dk2 : CT_Color?
  /// <lt2> — CT_Color (required per spec).
  lt2 : CT_Color?
  /// <accent1> — CT_Color (required per spec).
  accent1 : CT_Color?
  /// <accent2> — CT_Color (required per spec).
  accent2 : CT_Color?
  /// <accent3> — CT_Color (required per spec).
  accent3 : CT_Color?
  /// <accent4> — CT_Color (required per spec).
  accent4 : CT_Color?
  /// <accent5> — CT_Color (required per spec).
  accent5 : CT_Color?
  /// <accent6> — CT_Color (required per spec).
  accent6 : CT_Color?
  /// <hlink> — CT_Color (required per spec).
  hlink : CT_Color?
  /// <folHlink> — CT_Color (required per spec).
  fol_hlink : CT_Color?
  /// <extLst> — CT_OfficeArtExtensionList (optional). Raw element
  /// pending the typed extension-list projection.
  ext_lst : @xml.Element?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorScheme::new(
  element : @xml.Element,
) -> CT_ColorScheme raise SchemaViolation {
  let name = ct_required_string(element, "name", "CT_ColorScheme/@name")
  let dk1 = decode_optional_color_slot(element, "dk1")
  let lt1 = decode_optional_color_slot(element, "lt1")
  let dk2 = decode_optional_color_slot(element, "dk2")
  let lt2 = decode_optional_color_slot(element, "lt2")
  let accent1 = decode_optional_color_slot(element, "accent1")
  let accent2 = decode_optional_color_slot(element, "accent2")
  let accent3 = decode_optional_color_slot(element, "accent3")
  let accent4 = decode_optional_color_slot(element, "accent4")
  let accent5 = decode_optional_color_slot(element, "accent5")
  let accent6 = decode_optional_color_slot(element, "accent6")
  let hlink = decode_optional_color_slot(element, "hlink")
  let fol_hlink = decode_optional_color_slot(element, "folHlink")
  let ext_lst = ct_first_child(element, "extLst")
  {
    name,
    dk1,
    lt1,
    dk2,
    lt2,
    accent1,
    accent2,
    accent3,
    accent4,
    accent5,
    accent6,
    hlink,
    fol_hlink,
    ext_lst,
    element,
  }
}

///|
pub fn CT_ColorScheme::to_element(self : CT_ColorScheme) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorMRU — Part 1 §20.1.6.4 clrMru. Annex
/// A.4.1 lines 682..686. EG_ColorChoice group with minOccurs=0,
/// maxOccurs=unbounded; each MRU slot stored as a typed CT_Color.
pub(all) struct CT_ColorMRU {
  /// EG_ColorChoice* — zero or more CT_Color entries in document
  /// order. Each entry projects the choice arms inline; the typed
  /// CT_Color decoder picks the arm that is present.
  colors : Array[CT_Color]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMRU::new(
  element : @xml.Element,
) -> CT_ColorMRU raise SchemaViolation {
  let colors : Array[CT_Color] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        if is_color_choice_local_name(child.name.local_name) {
          colors.push(CT_Color::new(synth_color_wrapper(child)))
        }
      _ => ()
    }
  }
  { colors, element }
}

///|
pub fn CT_ColorMRU::to_element(self : CT_ColorMRU) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorChangeEffect — Part 1 §20.1.8.16 clrChange.
/// Annex A.4.1 lines 1268..1274. Required `clrFrom` and `clrTo`
/// CT_Color children plus optional `useA` xsd:boolean (default true).
pub(all) struct CT_ColorChangeEffect {
  /// @useA — xsd:boolean (optional, default true).
  use_a : Bool
  /// <clrFrom> — CT_Color (required per spec).
  clr_from : CT_Color?
  /// <clrTo> — CT_Color (required per spec).
  clr_to : CT_Color?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorChangeEffect::new(
  element : @xml.Element,
) -> CT_ColorChangeEffect raise SchemaViolation {
  let use_a = ct_optional_bool(
    element,
    "useA",
    default=true,
    "CT_ColorChangeEffect/@useA",
  )
  let clr_from = match ct_first_child(element, "clrFrom") {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
  let clr_to = match ct_first_child(element, "clrTo") {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
  { use_a, clr_from, clr_to, element }
}

///|
pub fn CT_ColorChangeEffect::to_element(
  self : CT_ColorChangeEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorReplaceEffect — Part 1 §20.1.8.18 clrRepl.
/// Annex A.4.1 lines 1275..1279. EG_ColorChoice group (minOccurs=1,
/// maxOccurs=1).
pub(all) struct CT_ColorReplaceEffect {
  /// EG_ColorChoice arm captured as a CT_Color projection. None when
  /// the choice arm is omitted in tolerant inputs.
  color : CT_Color?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorReplaceEffect::new(
  element : @xml.Element,
) -> CT_ColorReplaceEffect raise SchemaViolation {
  let color = if has_any_color_choice_child(element) {
    Some(CT_Color::new(element))
  } else {
    None
  }
  { color, element }
}

///|
pub fn CT_ColorReplaceEffect::to_element(
  self : CT_ColorReplaceEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SolidColorFillProperties — Part 1 §20.1.8.54
/// solidFill. Annex A.4.1 lines 1391..1395. EG_ColorChoice group
/// (minOccurs=0, maxOccurs=1) — the color choice itself is optional.
pub(all) struct CT_SolidColorFillProperties {
  /// EG_ColorChoice arm when present, captured as a CT_Color.
  color : CT_Color?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SolidColorFillProperties::new(
  element : @xml.Element,
) -> CT_SolidColorFillProperties raise SchemaViolation {
  let color = if has_any_color_choice_child(element) {
    Some(CT_Color::new(element))
  } else {
    None
  }
  { color, element }
}

///|
pub fn CT_SolidColorFillProperties::to_element(
  self : CT_SolidColorFillProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorMapping — Part 1 §20.1.6.5 clrMap. Annex
/// A.4.1 lines 2284..2300. Twelve required ST_ColorSchemeIndex
/// attributes mapping the scheme slots plus the optional
/// CT_OfficeArtExtensionList `extLst`.
pub(all) struct CT_ColorMapping {
  /// @bg1 — ST_ColorSchemeIndex (required).
  bg1 : ST_ColorSchemeIndex
  /// @tx1 — ST_ColorSchemeIndex (required).
  tx1 : ST_ColorSchemeIndex
  /// @bg2 — ST_ColorSchemeIndex (required).
  bg2 : ST_ColorSchemeIndex
  /// @tx2 — ST_ColorSchemeIndex (required).
  tx2 : ST_ColorSchemeIndex
  /// @accent1 — ST_ColorSchemeIndex (required).
  accent1 : ST_ColorSchemeIndex
  /// @accent2 — ST_ColorSchemeIndex (required).
  accent2 : ST_ColorSchemeIndex
  /// @accent3 — ST_ColorSchemeIndex (required).
  accent3 : ST_ColorSchemeIndex
  /// @accent4 — ST_ColorSchemeIndex (required).
  accent4 : ST_ColorSchemeIndex
  /// @accent5 — ST_ColorSchemeIndex (required).
  accent5 : ST_ColorSchemeIndex
  /// @accent6 — ST_ColorSchemeIndex (required).
  accent6 : ST_ColorSchemeIndex
  /// @hlink — ST_ColorSchemeIndex (required).
  hlink : ST_ColorSchemeIndex
  /// @folHlink — ST_ColorSchemeIndex (required).
  fol_hlink : ST_ColorSchemeIndex
  /// <extLst> — CT_OfficeArtExtensionList (optional). Raw element.
  ext_lst : @xml.Element?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMapping::new(
  element : @xml.Element,
) -> CT_ColorMapping raise SchemaViolation {
  let bg1 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "bg1", "CT_ColorMapping/@bg1"),
  )
  let tx1 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "tx1", "CT_ColorMapping/@tx1"),
  )
  let bg2 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "bg2", "CT_ColorMapping/@bg2"),
  )
  let tx2 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "tx2", "CT_ColorMapping/@tx2"),
  )
  let accent1 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "accent1", "CT_ColorMapping/@accent1"),
  )
  let accent2 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "accent2", "CT_ColorMapping/@accent2"),
  )
  let accent3 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "accent3", "CT_ColorMapping/@accent3"),
  )
  let accent4 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "accent4", "CT_ColorMapping/@accent4"),
  )
  let accent5 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "accent5", "CT_ColorMapping/@accent5"),
  )
  let accent6 = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "accent6", "CT_ColorMapping/@accent6"),
  )
  let hlink = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "hlink", "CT_ColorMapping/@hlink"),
  )
  let fol_hlink = ST_ColorSchemeIndex::parse(
    ct_required_string(element, "folHlink", "CT_ColorMapping/@folHlink"),
  )
  let ext_lst = ct_first_child(element, "extLst")
  {
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
    ext_lst,
    element,
  }
}

///|
pub fn CT_ColorMapping::to_element(self : CT_ColorMapping) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorMappingOverride — Part 1 §20.1.6.6
/// clrMapOvr. Annex A.4.1 lines 2301..2308. Choice between
/// `masterClrMapping` (CT_EmptyElement marker) and
/// `overrideClrMapping` (CT_ColorMapping). `master` arm has no
/// content so it is modelled as a bool flag.
pub(all) struct CT_ColorMappingOverride {
  /// True when the `masterClrMapping` arm is selected.
  master : Bool
  /// <overrideClrMapping> — CT_ColorMapping (when that arm is selected).
  override_clr_mapping : CT_ColorMapping?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMappingOverride::new(
  element : @xml.Element,
) -> CT_ColorMappingOverride raise SchemaViolation {
  let master = match ct_first_child(element, "masterClrMapping") {
    Some(_) => true
    None => false
  }
  let override_clr_mapping = match
    ct_first_child(element, "overrideClrMapping") {
    Some(c) => Some(CT_ColorMapping::new(c))
    None => None
  }
  { master, override_clr_mapping, element }
}

///|
pub fn CT_ColorMappingOverride::to_element(
  self : CT_ColorMappingOverride,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorSchemeAndMapping — Part 1 §20.1.6.7
/// extraClrScheme. Annex A.4.1 lines 2309..2314. Required
/// `clrScheme` (CT_ColorScheme) and optional `clrMap`
/// (CT_ColorMapping).
pub(all) struct CT_ColorSchemeAndMapping {
  /// <clrScheme> — CT_ColorScheme (required per spec).
  clr_scheme : CT_ColorScheme?
  /// <clrMap> — CT_ColorMapping (optional minOccurs=0).
  clr_map : CT_ColorMapping?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorSchemeAndMapping::new(
  element : @xml.Element,
) -> CT_ColorSchemeAndMapping raise SchemaViolation {
  let clr_scheme = match ct_first_child(element, "clrScheme") {
    Some(c) => Some(CT_ColorScheme::new(c))
    None => None
  }
  let clr_map = match ct_first_child(element, "clrMap") {
    Some(c) => Some(CT_ColorMapping::new(c))
    None => None
  }
  { clr_scheme, clr_map, element }
}

///|
pub fn CT_ColorSchemeAndMapping::to_element(
  self : CT_ColorSchemeAndMapping,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorSchemeList — Part 1 §20.1.6.8
/// extraClrSchemeLst. Annex A.4.1 lines 2315..2320. Sequence of zero
/// or more `extraClrScheme` (CT_ColorSchemeAndMapping) children.
pub(all) struct CT_ColorSchemeList {
  /// <extraClrScheme>* — CT_ColorSchemeAndMapping (zero or more).
  extra_clr_scheme : Array[CT_ColorSchemeAndMapping]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorSchemeList::new(
  element : @xml.Element,
) -> CT_ColorSchemeList raise SchemaViolation {
  let raw = ct_children(element, "extraClrScheme")
  let extra_clr_scheme : Array[CT_ColorSchemeAndMapping] = []
  for c in raw {
    extra_clr_scheme.push(CT_ColorSchemeAndMapping::new(c))
  }
  { extra_clr_scheme, element }
}

///|
pub fn CT_ColorSchemeList::to_element(
  self : CT_ColorSchemeList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextBulletColorFollowText — Part 1
/// §21.1.2.4.2 buClrTx. Annex A.4.1 line 2711. Empty complex type —
/// the element's presence alone indicates "follow text" semantics.
/// The struct intentionally carries no schema attributes/children;
/// the preserved element plus the `marker` flag confirm typed origin.
pub(all) struct CT_TextBulletColorFollowText {
  /// XSD empty complexType: this marker is always true once decoded
  /// to confirm the schema empty-content semantics were respected.
  follow_text : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletColorFollowText::new(
  element : @xml.Element,
) -> CT_TextBulletColorFollowText {
  { follow_text: true, element }
}

///|
pub fn CT_TextBulletColorFollowText::to_element(
  self : CT_TextBulletColorFollowText,
) -> @xml.Element {
  self.element
}


///|
/// Internal: EG_ColorChoice child local names per Annex A.4.1 lines
/// 667..676. Used by CT_Color / CT_CustomColor / CT_ColorReplaceEffect
/// / CT_SolidColorFillProperties to decide whether a choice arm is
/// present in the source element.
fn is_color_choice_local_name(name : String) -> Bool {
  match name {
    "scrgbClr" | "srgbClr" | "hslClr" | "sysClr" | "schemeClr" | "prstClr" =>
      true
    _ => false
  }
}

///|
fn has_any_color_choice_child(element : @xml.Element) -> Bool {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        if is_color_choice_local_name(child.name.local_name) {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
/// Internal: decode an optional CT_ColorScheme slot (dk1, lt1, ...,
/// folHlink). Each slot wraps a CT_Color body.
fn decode_optional_color_slot(
  element : @xml.Element,
  local_name : String,
) -> CT_Color? raise SchemaViolation {
  match ct_first_child(element, local_name) {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
}

///|
/// Internal: synthesise a one-arm color-choice wrapper around a raw
/// EG_ColorChoice child so CT_ColorMRU can re-use the typed CT_Color
/// decoder. The wrapper preserves the original element as the sole
/// child so `CT_Color::new` finds the choice arm.
fn synth_color_wrapper(child : @xml.Element) -> @xml.Element {
  @xml.Element::{
    name: @xml.QName::{
      prefix: None,
      local_name: "_ct_color_wrapper",
      ns: None,
    },
    attributes: [],
    children: [@xml.Element(child)],
  }
}

///|
pub fn read_color_scheme(bytes : Bytes) -> CT_ColorScheme raise {
  CT_ColorScheme::new(read_main_root(bytes, "clrScheme"))
}

///|
pub fn write_color_scheme(value : CT_ColorScheme) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_sc_rgb_color(bytes : Bytes) -> CT_ScRgbColor raise {
  CT_ScRgbColor::new(read_main_root(bytes, "scrgbClr"))
}

///|
pub fn write_sc_rgb_color(value : CT_ScRgbColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_s_rgb_color(bytes : Bytes) -> CT_SRgbColor raise {
  CT_SRgbColor::new(read_main_root(bytes, "srgbClr"))
}

///|
pub fn write_s_rgb_color(value : CT_SRgbColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_hsl_color(bytes : Bytes) -> CT_HslColor raise {
  CT_HslColor::new(read_main_root(bytes, "hslClr"))
}

///|
pub fn write_hsl_color(value : CT_HslColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_system_color(bytes : Bytes) -> CT_SystemColor raise {
  CT_SystemColor::new(read_main_root(bytes, "sysClr"))
}

///|
pub fn write_system_color(value : CT_SystemColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_scheme_color(bytes : Bytes) -> CT_SchemeColor raise {
  CT_SchemeColor::new(read_main_root(bytes, "schemeClr"))
}

///|
pub fn write_scheme_color(value : CT_SchemeColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_preset_color(bytes : Bytes) -> CT_PresetColor raise {
  CT_PresetColor::new(read_main_root(bytes, "prstClr"))
}

///|
pub fn write_preset_color(value : CT_PresetColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_color_mapping(bytes : Bytes) -> CT_ColorMapping raise {
  CT_ColorMapping::new(read_main_root(bytes, "clrMap"))
}

///|
pub fn write_color_mapping(value : CT_ColorMapping) -> Bytes {
  write_element(value.element)
}
