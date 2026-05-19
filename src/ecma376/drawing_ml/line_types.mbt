// ECMA-376 Part 1 §20.1.8 DrawingML line complex types. XSD definitions
// live in Annex A.4.1 dml-main.xsd at the following line ranges:
//
//   CT_LineEndProperties           lines 2120..2124
//   CT_LineJoinBevel               line  2133
//   CT_LineJoinRound               line  2134
//   CT_LineJoinMiterProperties     lines 2135..2137
//   CT_PresetLineDashProperties    lines 2160..2162
//   CT_DashStop                    lines 2163..2166
//   CT_DashStopList                lines 2167..2171
//   CT_LineProperties              lines 2206..2219
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit attribute / child-element fields decoded from the
// source `@xml.Element`. The element is preserved so the builder can
// round-trip unmodelled content (the `to_element` writer returns the
// captured element verbatim).

///|
/// XSD complex type CT_LineProperties — Part 1 §20.1.2.2.24 ln (Outline).
/// Annex A.4.1 lines 2206..2219. Optional EG_LineFillProperties choice
/// (`noFill` | `solidFill` | `gradFill` | `pattFill`), optional
/// EG_LineDashProperties choice (`prstDash` | `custDash`), optional
/// EG_LineJoinProperties choice (`round` | `bevel` | `miter`), optional
/// `headEnd` / `tailEnd` (CT_LineEndProperties), optional `extLst`
/// (CT_OfficeArtExtensionList); plus four optional attributes — `w`
/// (ST_LineWidth), `cap` (ST_LineCap), `cmpd` (ST_CompoundLine), `algn`
/// (ST_PenAlignment).
pub(all) struct CT_LineProperties {
  /// <noFill> (CT_NoFillProperties) — EG_LineFillProperties choice arm.
  no_fill : CT_NoFillProperties?
  /// <solidFill> (CT_SolidColorFillProperties) — EG_LineFillProperties arm.
  solid_fill : CT_SolidColorFillProperties?
  /// <gradFill> (CT_GradientFillProperties) — EG_LineFillProperties arm.
  grad_fill : CT_GradientFillProperties?
  /// <pattFill> (CT_PatternFillProperties) — EG_LineFillProperties arm.
  patt_fill : CT_PatternFillProperties?
  /// <prstDash> (CT_PresetLineDashProperties) — EG_LineDashProperties arm.
  prst_dash : CT_PresetLineDashProperties?
  /// <custDash> (CT_DashStopList) — EG_LineDashProperties arm.
  cust_dash : CT_DashStopList?
  /// <round> (CT_LineJoinRound) — EG_LineJoinProperties arm.
  round : CT_LineJoinRound?
  /// <bevel> (CT_LineJoinBevel) — EG_LineJoinProperties arm.
  bevel : CT_LineJoinBevel?
  /// <miter> (CT_LineJoinMiterProperties) — EG_LineJoinProperties arm.
  miter : CT_LineJoinMiterProperties?
  /// <headEnd> (CT_LineEndProperties) — optional.
  head_end : CT_LineEndProperties?
  /// <tailEnd> (CT_LineEndProperties) — optional.
  tail_end : CT_LineEndProperties?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @w — ST_LineWidth (optional).
  w : ST_LineWidth?
  /// @cap — ST_LineCap (optional).
  cap : ST_LineCap?
  /// @cmpd — ST_CompoundLine (optional).
  cmpd : ST_CompoundLine?
  /// @algn — ST_PenAlignment (optional).
  algn : ST_PenAlignment?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineProperties::new(
  element : @xml.Element,
) -> CT_LineProperties raise SchemaViolation {
  let no_fill = match ct_first_child(element, "noFill") {
    Some(c) => Some(CT_NoFillProperties::new(c))
    None => None
  }
  let solid_fill = match ct_first_child(element, "solidFill") {
    Some(c) => Some(CT_SolidColorFillProperties::new(c))
    None => None
  }
  let grad_fill = match ct_first_child(element, "gradFill") {
    Some(c) => Some(CT_GradientFillProperties::new(c))
    None => None
  }
  let patt_fill = match ct_first_child(element, "pattFill") {
    Some(c) => Some(CT_PatternFillProperties::new(c))
    None => None
  }
  let prst_dash = match ct_first_child(element, "prstDash") {
    Some(c) => Some(CT_PresetLineDashProperties::new(c))
    None => None
  }
  let cust_dash = match ct_first_child(element, "custDash") {
    Some(c) => Some(CT_DashStopList::new(c))
    None => None
  }
  let round = match ct_first_child(element, "round") {
    Some(c) => Some(CT_LineJoinRound::new(c))
    None => None
  }
  let bevel = match ct_first_child(element, "bevel") {
    Some(c) => Some(CT_LineJoinBevel::new(c))
    None => None
  }
  let miter = match ct_first_child(element, "miter") {
    Some(c) => Some(CT_LineJoinMiterProperties::new(c))
    None => None
  }
  let head_end = match ct_first_child(element, "headEnd") {
    Some(c) => Some(CT_LineEndProperties::new(c))
    None => None
  }
  let tail_end = match ct_first_child(element, "tailEnd") {
    Some(c) => Some(CT_LineEndProperties::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let w = match ct_attr(element, "w") {
    Some(v) => Some(ST_LineWidth::parse(v))
    None => None
  }
  let cap = match ct_attr(element, "cap") {
    Some(v) => Some(ST_LineCap::parse(v))
    None => None
  }
  let cmpd = match ct_attr(element, "cmpd") {
    Some(v) => Some(ST_CompoundLine::parse(v))
    None => None
  }
  let algn = match ct_attr(element, "algn") {
    Some(v) => Some(ST_PenAlignment::parse(v))
    None => None
  }
  {
    no_fill,
    solid_fill,
    grad_fill,
    patt_fill,
    prst_dash,
    cust_dash,
    round,
    bevel,
    miter,
    head_end,
    tail_end,
    ext_lst,
    w,
    cap,
    cmpd,
    algn,
    element,
  }
}

///|
pub fn CT_LineProperties::to_element(self : CT_LineProperties) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LineEndProperties — Part 1 §20.1.8.38 (used by
/// `headEnd` and `tailEnd` children of `ln`). Annex A.4.1 lines
/// 2120..2124. Three optional attributes: `type` (ST_LineEndType,
/// default `none`), `w` (ST_LineEndWidth), `len` (ST_LineEndLength).
pub(all) struct CT_LineEndProperties {
  /// @type — ST_LineEndType (optional, default none).
  end_type : ST_LineEndType
  /// @w — ST_LineEndWidth (optional).
  w : ST_LineEndWidth?
  /// @len — ST_LineEndLength (optional).
  len : ST_LineEndLength?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineEndProperties::new(
  element : @xml.Element,
) -> CT_LineEndProperties raise SchemaViolation {
  let end_type = match ct_attr(element, "type") {
    Some(v) => ST_LineEndType::parse(v)
    None => LineEndNone
  }
  let w = match ct_attr(element, "w") {
    Some(v) => Some(ST_LineEndWidth::parse(v))
    None => None
  }
  let len = match ct_attr(element, "len") {
    Some(v) => Some(ST_LineEndLength::parse(v))
    None => None
  }
  { end_type, w, len, element }
}

///|
pub fn CT_LineEndProperties::to_element(
  self : CT_LineEndProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LineJoinBevel — Part 1 §20.1.8.9 bevel (Line
/// Join Bevel). Annex A.4.1 line 2133. Empty complex type — presence
/// of `bevel` alone selects the bevel join arm of EG_LineJoinProperties.
pub(all) struct CT_LineJoinBevel {
  /// Empty-XSD-type marker (always true once decoded).
  join : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineJoinBevel::new(element : @xml.Element) -> CT_LineJoinBevel {
  { join: true, element }
}

///|
pub fn CT_LineJoinBevel::to_element(self : CT_LineJoinBevel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LineJoinRound — Part 1 §20.1.8.52 round (Line
/// Join Round). Annex A.4.1 line 2134. Empty complex type — presence
/// of `round` alone selects the round join arm of EG_LineJoinProperties.
pub(all) struct CT_LineJoinRound {
  /// Empty-XSD-type marker (always true once decoded).
  join : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineJoinRound::new(element : @xml.Element) -> CT_LineJoinRound {
  { join: true, element }
}

///|
pub fn CT_LineJoinRound::to_element(self : CT_LineJoinRound) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LineJoinMiterProperties — Part 1 §20.1.8.43 miter
/// (Miter Line Join). Annex A.4.1 lines 2135..2137. Optional `lim`
/// (ST_PositivePercentage) — the miter-join limit (extension ratio at
/// which the join falls back to bevel).
pub(all) struct CT_LineJoinMiterProperties {
  /// @lim — ST_PositivePercentage (optional).
  lim : ST_PositivePercentage?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineJoinMiterProperties::new(
  element : @xml.Element,
) -> CT_LineJoinMiterProperties raise SchemaViolation {
  let lim = match ct_attr(element, "lim") {
    Some(v) => Some(ST_PositivePercentage::parse(v))
    None => None
  }
  { lim, element }
}

///|
pub fn CT_LineJoinMiterProperties::to_element(
  self : CT_LineJoinMiterProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DashStop — Part 1 §20.1.8.21 ds (Dash Stop).
/// Annex A.4.1 lines 2163..2166. Two required attributes — `d`
/// (ST_PositivePercentage) and `sp` (ST_PositivePercentage) — encoding
/// the dash length and the trailing space length as positive
/// percentages of the line width.
pub(all) struct CT_DashStop {
  /// @d — ST_PositivePercentage (required).
  d : ST_PositivePercentage
  /// @sp — ST_PositivePercentage (required).
  sp : ST_PositivePercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DashStop::new(
  element : @xml.Element,
) -> CT_DashStop raise SchemaViolation {
  let d_lex = ct_required_string(element, "d", "CT_DashStop/@d")
  let d = ST_PositivePercentage::parse(d_lex)
  let sp_lex = ct_required_string(element, "sp", "CT_DashStop/@sp")
  let sp = ST_PositivePercentage::parse(sp_lex)
  { d, sp, element }
}

///|
pub fn CT_DashStop::to_element(self : CT_DashStop) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DashStopList — Part 1 §20.1.8.20 custDash (Custom
/// Dash). Annex A.4.1 lines 2167..2171. Zero-or-more `ds` (CT_DashStop)
/// children encoding the custom dash pattern.
pub(all) struct CT_DashStopList {
  /// <ds>* (CT_DashStop) — zero or more dash stops in document order.
  ds : Array[CT_DashStop]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DashStopList::new(
  element : @xml.Element,
) -> CT_DashStopList raise SchemaViolation {
  let ds : Array[CT_DashStop] = []
  for child in ct_children(element, "ds") {
    ds.push(CT_DashStop::new(child))
  }
  { ds, element }
}

///|
pub fn CT_DashStopList::to_element(self : CT_DashStopList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresetLineDashProperties — Part 1 §20.1.8.48
/// prstDash (Preset Dash). Annex A.4.1 lines 2160..2162. Optional
/// attribute `val` (ST_PresetLineDashVal) — preset dash pattern.
pub(all) struct CT_PresetLineDashProperties {
  /// @val — ST_PresetLineDashVal (optional).
  val : ST_PresetLineDashVal?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetLineDashProperties::new(
  element : @xml.Element,
) -> CT_PresetLineDashProperties raise SchemaViolation {
  let val = match ct_attr(element, "val") {
    Some(v) => Some(ST_PresetLineDashVal::parse(v))
    None => None
  }
  { val, element }
}

///|
pub fn CT_PresetLineDashProperties::to_element(
  self : CT_PresetLineDashProperties,
) -> @xml.Element {
  self.element
}

///|
pub fn read_line_properties(bytes : Bytes) -> CT_LineProperties raise {
  CT_LineProperties::new(read_main_root(bytes, "ln"))
}

///|
pub fn write_line_properties(value : CT_LineProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_preset_line_dash_properties(
  bytes : Bytes,
) -> CT_PresetLineDashProperties raise {
  CT_PresetLineDashProperties::new(read_main_root(bytes, "prstDash"))
}

///|
pub fn write_preset_line_dash_properties(
  value : CT_PresetLineDashProperties,
) -> Bytes {
  write_element(value.element)
}
