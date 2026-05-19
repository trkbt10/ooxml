// ECMA-376 Part 1 §20.1.8 DrawingML fill complex types. XSD definitions
// live in Annex A.4.1 dml-main.xsd at the following line ranges:
//
//   CT_NoFillProperties          line  1390
//   CT_LinearShadeProperties     lines 1396..1399
//   CT_PathShadeProperties       lines 1407..1412
//   CT_GradientStop              lines 1427..1432
//   CT_GradientStopList          lines 1433..1437
//   CT_GradientFillProperties    lines 1438..1446
//   CT_TileInfoProperties        lines 1447..1454
//   CT_StretchInfoProperties     lines 1455..1459
//   CT_BlipFillProperties        lines 1502..1510
//   CT_PatternFillProperties     lines 1569..1575
//   CT_GroupFillProperties       line  1576
//   CT_FillProperties            lines 1587..1591
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit attribute / child-element fields decoded from the
// source `@xml.Element`. The element is preserved so the builder can
// round-trip unmodelled content (the `to_element` writer returns the
// captured element verbatim).

///|
/// XSD complex type CT_FillProperties — Part 1 §20.1.8 EG_FillProperties.
/// Annex A.4.1 lines 1587..1591. Single required EG_FillProperties
/// choice arm (`noFill`, `solidFill`, `gradFill`, `blipFill`,
/// `pattFill`, `grpFill`). The projection captures all six arms as
/// Options; exactly one is populated for a valid document.
pub(all) struct CT_FillProperties {
  /// <noFill> (CT_NoFillProperties) choice arm.
  no_fill : CT_NoFillProperties?
  /// <solidFill> (CT_SolidColorFillProperties) choice arm.
  solid_fill : CT_SolidColorFillProperties?
  /// <gradFill> (CT_GradientFillProperties) choice arm.
  grad_fill : CT_GradientFillProperties?
  /// <blipFill> (CT_BlipFillProperties) choice arm.
  blip_fill : CT_BlipFillProperties?
  /// <pattFill> (CT_PatternFillProperties) choice arm.
  patt_fill : CT_PatternFillProperties?
  /// <grpFill> (CT_GroupFillProperties) choice arm.
  grp_fill : CT_GroupFillProperties?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FillProperties::new(
  element : @xml.Element,
) -> CT_FillProperties raise SchemaViolation {
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
  let blip_fill = match ct_first_child(element, "blipFill") {
    Some(c) => Some(CT_BlipFillProperties::new(c))
    None => None
  }
  let patt_fill = match ct_first_child(element, "pattFill") {
    Some(c) => Some(CT_PatternFillProperties::new(c))
    None => None
  }
  let grp_fill = match ct_first_child(element, "grpFill") {
    Some(c) => Some(CT_GroupFillProperties::new(c))
    None => None
  }
  { no_fill, solid_fill, grad_fill, blip_fill, patt_fill, grp_fill, element }
}

///|
pub fn CT_FillProperties::to_element(self : CT_FillProperties) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NoFillProperties — Part 1 §20.1.8.44 noFill.
/// Annex A.4.1 line 1390. Empty complex type — presence alone selects
/// "no fill" for the parent shape / cell / background.
pub(all) struct CT_NoFillProperties {
  /// Empty-XSD-type marker (always true once decoded).
  fill : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NoFillProperties::new(element : @xml.Element) -> CT_NoFillProperties {
  { fill: true, element }
}

///|
pub fn CT_NoFillProperties::to_element(
  self : CT_NoFillProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GradientFillProperties — Part 1 §20.1.8.33
/// gradFill. Annex A.4.1 lines 1438..1446. Optional `gsLst`
/// (CT_GradientStopList), optional EG_ShadeProperties choice (`lin`
/// CT_LinearShadeProperties or `path` CT_PathShadeProperties), optional
/// `tileRect` (CT_RelativeRect); plus optional `flip` (ST_TileFlipMode,
/// default none) and `rotWithShape` (xsd:boolean).
pub(all) struct CT_GradientFillProperties {
  /// <gsLst> (CT_GradientStopList) — optional.
  gs_lst : CT_GradientStopList?
  /// <lin> (CT_LinearShadeProperties) choice arm — optional.
  lin : CT_LinearShadeProperties?
  /// <path> (CT_PathShadeProperties) choice arm — optional.
  path : CT_PathShadeProperties?
  /// <tileRect> (CT_RelativeRect) — optional.
  tile_rect : CT_RelativeRect?
  /// @flip — ST_TileFlipMode (optional, default none).
  flip : ST_TileFlipMode
  /// @rotWithShape — xsd:boolean (optional).
  rot_with_shape : Bool?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GradientFillProperties::new(
  element : @xml.Element,
) -> CT_GradientFillProperties raise SchemaViolation {
  let gs_lst = match ct_first_child(element, "gsLst") {
    Some(c) => Some(CT_GradientStopList::new(c))
    None => None
  }
  let lin = match ct_first_child(element, "lin") {
    Some(c) => Some(CT_LinearShadeProperties::new(c))
    None => None
  }
  let path = match ct_first_child(element, "path") {
    Some(c) => Some(CT_PathShadeProperties::new(c))
    None => None
  }
  let tile_rect = match ct_first_child(element, "tileRect") {
    Some(c) => Some(CT_RelativeRect::new(c))
    None => None
  }
  let flip = match ct_attr(element, "flip") {
    Some(v) => ST_TileFlipMode::parse(v)
    None => TileFlipNone
  }
  let rot_with_shape = match ct_attr(element, "rotWithShape") {
    Some(v) =>
      Some(ct_parse_bool_lex(v, "CT_GradientFillProperties/@rotWithShape"))
    None => None
  }
  { gs_lst, lin, path, tile_rect, flip, rot_with_shape, element }
}

///|
pub fn CT_GradientFillProperties::to_element(
  self : CT_GradientFillProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BlipFillProperties — Part 1 §20.1.8.14 blipFill.
/// Annex A.4.1 lines 1502..1510. Optional `blip` (CT_Blip), optional
/// `srcRect` (CT_RelativeRect), optional EG_FillModeProperties choice
/// (`tile` CT_TileInfoProperties or `stretch` CT_StretchInfoProperties);
/// plus optional `dpi` (xsd:unsignedInt) and `rotWithShape`
/// (xsd:boolean).
pub(all) struct CT_BlipFillProperties {
  /// <blip> (CT_Blip) — optional.
  blip : CT_Blip?
  /// <srcRect> (CT_RelativeRect) — optional.
  src_rect : CT_RelativeRect?
  /// <tile> (CT_TileInfoProperties) choice arm — optional.
  tile : CT_TileInfoProperties?
  /// <stretch> (CT_StretchInfoProperties) choice arm — optional.
  stretch : CT_StretchInfoProperties?
  /// @dpi — xsd:unsignedInt (optional).
  dpi : UInt?
  /// @rotWithShape — xsd:boolean (optional).
  rot_with_shape : Bool?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BlipFillProperties::new(
  element : @xml.Element,
) -> CT_BlipFillProperties raise SchemaViolation {
  let blip = match ct_first_child(element, "blip") {
    Some(c) => Some(CT_Blip::new(c))
    None => None
  }
  let src_rect = match ct_first_child(element, "srcRect") {
    Some(c) => Some(CT_RelativeRect::new(c))
    None => None
  }
  let tile = match ct_first_child(element, "tile") {
    Some(c) => Some(CT_TileInfoProperties::new(c))
    None => None
  }
  let stretch = match ct_first_child(element, "stretch") {
    Some(c) => Some(CT_StretchInfoProperties::new(c))
    None => None
  }
  let dpi = match ct_attr(element, "dpi") {
    Some(v) => Some(ct_parse_uint_lex(v, "CT_BlipFillProperties/@dpi"))
    None => None
  }
  let rot_with_shape = match ct_attr(element, "rotWithShape") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_BlipFillProperties/@rotWithShape"))
    None => None
  }
  { blip, src_rect, tile, stretch, dpi, rot_with_shape, element }
}

///|
pub fn CT_BlipFillProperties::to_element(
  self : CT_BlipFillProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PatternFillProperties — Part 1 §20.1.8.47
/// pattFill. Annex A.4.1 lines 1569..1575. Two optional colour-choice
/// containers `fgClr` and `bgClr` (CT_Color), plus optional `prst`
/// (ST_PresetPatternVal).
pub(all) struct CT_PatternFillProperties {
  /// <fgClr> (CT_Color) — optional foreground colour.
  fg_clr : CT_Color?
  /// <bgClr> (CT_Color) — optional background colour.
  bg_clr : CT_Color?
  /// @prst — ST_PresetPatternVal (optional).
  prst : ST_PresetPatternVal?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PatternFillProperties::new(
  element : @xml.Element,
) -> CT_PatternFillProperties raise SchemaViolation {
  let fg_clr = match ct_first_child(element, "fgClr") {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
  let bg_clr = match ct_first_child(element, "bgClr") {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
  let prst = match ct_attr(element, "prst") {
    Some(v) => Some(ST_PresetPatternVal::parse(v))
    None => None
  }
  { fg_clr, bg_clr, prst, element }
}

///|
pub fn CT_PatternFillProperties::to_element(
  self : CT_PatternFillProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GroupFillProperties — Part 1 §20.1.8.35 grpFill.
/// Annex A.4.1 line 1576. Empty complex type — presence selects "use
/// the parent group's fill" for the current shape.
pub(all) struct CT_GroupFillProperties {
  /// Empty-XSD-type marker (always true once decoded).
  fill : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupFillProperties::new(
  element : @xml.Element,
) -> CT_GroupFillProperties {
  { fill: true, element }
}

///|
pub fn CT_GroupFillProperties::to_element(
  self : CT_GroupFillProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GradientStopList — Part 1 §20.1.8.37 gsLst. Annex
/// A.4.1 lines 1433..1437. Required two-or-more `gs` (CT_GradientStop)
/// children in document order.
pub(all) struct CT_GradientStopList {
  /// <gs>+ (CT_GradientStop) — two or more gradient stops in document order.
  gs : Array[CT_GradientStop]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GradientStopList::new(
  element : @xml.Element,
) -> CT_GradientStopList raise SchemaViolation {
  let gs : Array[CT_GradientStop] = []
  for child in ct_children(element, "gs") {
    gs.push(CT_GradientStop::new(child))
  }
  { gs, element }
}

///|
pub fn CT_GradientStopList::to_element(
  self : CT_GradientStopList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GradientStop — Part 1 §20.1.8.36 gs. Annex A.4.1
/// lines 1427..1432. Required single EG_ColorChoice arm and required
/// `pos` (ST_PositiveFixedPercentage) — position of the stop along the
/// gradient (0% .. 100%).
pub(all) struct CT_GradientStop {
  /// EG_ColorChoice (required) captured as a CT_Color projection.
  color : CT_Color
  /// @pos — ST_PositiveFixedPercentage (required).
  pos : ST_PositiveFixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GradientStop::new(
  element : @xml.Element,
) -> CT_GradientStop raise SchemaViolation {
  let color = CT_Color::new(element)
  let pos_lex = ct_required_string(element, "pos", "CT_GradientStop/@pos")
  let pos = ST_PositiveFixedPercentage::parse(pos_lex)
  { color, pos, element }
}

///|
pub fn CT_GradientStop::to_element(self : CT_GradientStop) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LinearShadeProperties — Part 1 §20.1.8.41 lin.
/// Annex A.4.1 lines 1396..1399. Two optional attributes: `ang`
/// (ST_PositiveFixedAngle) — gradient direction — and `scaled`
/// (xsd:boolean) — whether the gradient scales with the shape.
pub(all) struct CT_LinearShadeProperties {
  /// @ang — ST_PositiveFixedAngle (optional).
  ang : ST_PositiveFixedAngle?
  /// @scaled — xsd:boolean (optional).
  scaled : Bool?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LinearShadeProperties::new(
  element : @xml.Element,
) -> CT_LinearShadeProperties raise SchemaViolation {
  let ang = match ct_attr(element, "ang") {
    Some(v) => Some(ST_PositiveFixedAngle::parse(v))
    None => None
  }
  let scaled = match ct_attr(element, "scaled") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_LinearShadeProperties/@scaled"))
    None => None
  }
  { ang, scaled, element }
}

///|
pub fn CT_LinearShadeProperties::to_element(
  self : CT_LinearShadeProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PathShadeProperties — Part 1 §20.1.8.46 path.
/// Annex A.4.1 lines 1407..1412. Optional `fillToRect`
/// (CT_RelativeRect) child describing the inner fill rectangle, and
/// optional `path` (ST_PathShadeType) attribute selecting shape /
/// circle / rect path mode.
pub(all) struct CT_PathShadeProperties {
  /// <fillToRect> (CT_RelativeRect) — optional.
  fill_to_rect : CT_RelativeRect?
  /// @path — ST_PathShadeType (optional).
  path : ST_PathShadeType?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PathShadeProperties::new(
  element : @xml.Element,
) -> CT_PathShadeProperties raise SchemaViolation {
  let fill_to_rect = match ct_first_child(element, "fillToRect") {
    Some(c) => Some(CT_RelativeRect::new(c))
    None => None
  }
  let path = match ct_attr(element, "path") {
    Some(v) => Some(ST_PathShadeType::parse(v))
    None => None
  }
  { fill_to_rect, path, element }
}

///|
pub fn CT_PathShadeProperties::to_element(
  self : CT_PathShadeProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TileInfoProperties — Part 1 §20.1.8.58 tile.
/// Annex A.4.1 lines 1447..1454. Six optional attributes describing the
/// tile origin offset (`tx`/`ty`), tile scale (`sx`/`sy`), tile flip
/// mode (`flip`, default none) and tile alignment (`algn`).
pub(all) struct CT_TileInfoProperties {
  /// @tx — ST_Coordinate (optional).
  tx : ST_Coordinate?
  /// @ty — ST_Coordinate (optional).
  ty : ST_Coordinate?
  /// @sx — ST_Percentage (optional).
  sx : ST_Percentage?
  /// @sy — ST_Percentage (optional).
  sy : ST_Percentage?
  /// @flip — ST_TileFlipMode (optional, default none).
  flip : ST_TileFlipMode
  /// @algn — ST_RectAlignment (optional).
  algn : ST_RectAlignment?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TileInfoProperties::new(
  element : @xml.Element,
) -> CT_TileInfoProperties raise SchemaViolation {
  let tx = match ct_attr(element, "tx") {
    Some(v) => Some(ST_Coordinate::parse(v))
    None => None
  }
  let ty = match ct_attr(element, "ty") {
    Some(v) => Some(ST_Coordinate::parse(v))
    None => None
  }
  let sx = match ct_attr(element, "sx") {
    Some(v) => Some(ST_Percentage::parse(v))
    None => None
  }
  let sy = match ct_attr(element, "sy") {
    Some(v) => Some(ST_Percentage::parse(v))
    None => None
  }
  let flip = match ct_attr(element, "flip") {
    Some(v) => ST_TileFlipMode::parse(v)
    None => TileFlipNone
  }
  let algn = match ct_attr(element, "algn") {
    Some(v) => Some(ST_RectAlignment::parse(v))
    None => None
  }
  { tx, ty, sx, sy, flip, algn, element }
}

///|
pub fn CT_TileInfoProperties::to_element(
  self : CT_TileInfoProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StretchInfoProperties — Part 1 §20.1.8.56
/// stretch. Annex A.4.1 lines 1455..1459. Optional `fillRect`
/// (CT_RelativeRect) child describing the rectangle within the source
/// blip to stretch into the shape.
pub(all) struct CT_StretchInfoProperties {
  /// <fillRect> (CT_RelativeRect) — optional.
  fill_rect : CT_RelativeRect?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StretchInfoProperties::new(
  element : @xml.Element,
) -> CT_StretchInfoProperties {
  let fill_rect = match ct_first_child(element, "fillRect") {
    Some(c) => Some(CT_RelativeRect::new(c))
    None => None
  }
  { fill_rect, element }
}

///|
pub fn CT_StretchInfoProperties::to_element(
  self : CT_StretchInfoProperties,
) -> @xml.Element {
  self.element
}

///|
pub fn read_no_fill_properties(bytes : Bytes) -> CT_NoFillProperties raise {
  CT_NoFillProperties::new(read_main_root(bytes, "noFill"))
}

///|
pub fn write_no_fill_properties(value : CT_NoFillProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_solid_color_fill_properties(
  bytes : Bytes,
) -> CT_SolidColorFillProperties raise {
  CT_SolidColorFillProperties::new(read_main_root(bytes, "solidFill"))
}

///|
pub fn write_solid_color_fill_properties(
  value : CT_SolidColorFillProperties,
) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_gradient_fill_properties(
  bytes : Bytes,
) -> CT_GradientFillProperties raise {
  CT_GradientFillProperties::new(read_main_root(bytes, "gradFill"))
}

///|
pub fn write_gradient_fill_properties(
  value : CT_GradientFillProperties,
) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_blip_fill_properties(bytes : Bytes) -> CT_BlipFillProperties raise {
  CT_BlipFillProperties::new(read_main_root(bytes, "blipFill"))
}

///|
pub fn write_blip_fill_properties(value : CT_BlipFillProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_pattern_fill_properties(
  bytes : Bytes,
) -> CT_PatternFillProperties raise {
  CT_PatternFillProperties::new(read_main_root(bytes, "pattFill"))
}

///|
pub fn write_pattern_fill_properties(value : CT_PatternFillProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_group_fill_properties(
  bytes : Bytes,
) -> CT_GroupFillProperties raise {
  CT_GroupFillProperties::new(read_main_root(bytes, "grpFill"))
}

///|
pub fn write_group_fill_properties(value : CT_GroupFillProperties) -> Bytes {
  write_element(value.element)
}
