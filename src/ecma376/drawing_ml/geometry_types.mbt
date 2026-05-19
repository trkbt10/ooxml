// ECMA-376 Part 1 §20.1.7 (transform / coordinate primitives) and
// §20.1.9 (custom and preset geometry) complex types. XSD definitions
// live in Annex A.4.1 dml-main.xsd at the following line ranges:
//
//   CT_Angle                     lines  216..218 (§20.1.7.1)
//   CT_PositiveFixedAngle        lines  231..233 (§20.1.7.5)
//   CT_Percentage                lines  237..239 (§20.1.7.4)
//   CT_PositivePercentage        lines  243..245 (§20.1.7.6)
//   CT_FixedPercentage           lines  249..251 (§20.1.7.3)
//   CT_PositiveFixedPercentage   lines  255..257 (§20.1.7.7)
//   CT_Ratio                     lines  258..261 (§20.1.7.10)
//   CT_Point2D                   lines  262..265 (§20.1.7.10 sub)
//   CT_PositiveSize2D            lines  266..269 (§20.1.7.13)
//   CT_Scale2D                   lines  607..612 (§20.1.7.8)
//   CT_Transform2D               lines  613..621 (§20.1.7.6 xfrm)
//   CT_GroupTransform2D          lines  622..632 (§20.1.7.5 xfrm grpSp)
//   CT_Point3D                   lines  633..637 (§20.1.7.18)
//   CT_Vector3D                  lines  638..642 (§20.1.7.27)
//   CT_SphereCoords              lines  643..647 (§20.1.7.20)
//   CT_RelativeRect              lines  648..653 (§20.1.7.30)
//   CT_GeomGuide                 lines 1937..1940 (§20.1.9.11)
//   CT_GeomGuideList             lines 1941..1945 (§20.1.9.12)
//   CT_AdjPoint2D                lines 1952..1955 (§20.1.9.2)
//   CT_GeomRect                  lines 1956..1961 (§20.1.9.13)
//   CT_XYAdjustHandle            lines 1962..1972 (§20.1.9.21)
//   CT_PolarAdjustHandle         lines 1973..1983 (§20.1.9.20)
//   CT_ConnectionSite            lines 1984..1989 (§20.1.9.10)
//   CT_AdjustHandleList          lines 1990..1995 (§20.1.9.1)
//   CT_ConnectionSiteList        lines 1996..2000 (§20.1.9.9)
//   CT_Connection                lines 2001..2004 (§20.1.9.8)
//   CT_Path2DMoveTo              lines 2005..2009 (§20.1.9.18)
//   CT_Path2DLineTo              lines 2010..2014 (§20.1.9.16)
//   CT_Path2DArcTo               lines 2015..2020 (§20.1.9.14)
//   CT_Path2DQuadBezierTo        lines 2021..2025 (§20.1.9.19)
//   CT_Path2DCubicBezierTo       lines 2026..2030 (§20.1.9.15)
//   CT_Path2DClose               line  2031       (§20.1.9.17)
//   CT_Path2D                    lines 2042..2056 (§20.1.9.15 path)
//   CT_Path2DList                lines 2057..2061 (§20.1.9.6 pathLst)
//   CT_PresetGeometry2D          lines 2062..2067 (§20.1.9.18 prstGeom)
//   CT_PresetTextShape           lines 2068..2073 (§20.1.10.55 prstTxWarp)
//   CT_CustomGeometry2D          lines 2074..2083 (§20.1.9.8 custGeom)
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit attribute / child-element fields decoded from the
// source `@xml.Element`. The element is preserved so the builder can
// round-trip unmodelled content (the `to_element` writer returns the
// captured element verbatim).
//
// Union-typed attributes (ST_AdjCoordinate = ST_Coordinate | ST_GeomGuideName,
// ST_AdjAngle = ST_Angle | ST_GeomGuideName, ST_PathFillMode and ST_ShapeType
// for which no MoonBit projection currently exists in this package) are
// captured as raw lexical `String`. The shared `validate_main_element`
// guard in `schema_error.mbt` already enforces non-empty lexical forms
// for those attributes at the top-level reader entry.

///|
/// XSD complex type CT_Angle — Part 1 §20.1.7.1. Annex A.4.1 lines
/// 216..218. Single required `val` attribute of type ST_Angle
/// (sixty-thousandths of a degree).
pub(all) struct CT_Angle {
  /// @val — ST_Angle (required).
  val : ST_Angle
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Angle::new(element : @xml.Element) -> CT_Angle raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_Angle/@val")
  let val = ST_Angle::parse(lex)
  { val, element }
}

///|
pub fn CT_Angle::to_element(self : CT_Angle) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PositiveFixedAngle — Part 1 §20.1.7.5. Annex
/// A.4.1 lines 231..233. Single required `val` attribute of type
/// ST_PositiveFixedAngle (0 ≤ value < 21,600,000 sixty-thousandths of
/// a degree, i.e. 0° ≤ value < 360°).
pub(all) struct CT_PositiveFixedAngle {
  /// @val — ST_PositiveFixedAngle (required).
  val : ST_PositiveFixedAngle
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PositiveFixedAngle::new(
  element : @xml.Element,
) -> CT_PositiveFixedAngle raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_PositiveFixedAngle/@val")
  let val = ST_PositiveFixedAngle::parse(lex)
  { val, element }
}

///|
pub fn CT_PositiveFixedAngle::to_element(
  self : CT_PositiveFixedAngle,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Percentage — Part 1 §20.1.7.4. Annex A.4.1 lines
/// 237..239. Single required `val` attribute of type ST_Percentage
/// (1/1000 of a percent; "12.345%" or raw "12345").
pub(all) struct CT_Percentage {
  /// @val — ST_Percentage (required).
  val : ST_Percentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Percentage::new(
  element : @xml.Element,
) -> CT_Percentage raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_Percentage/@val")
  let val = ST_Percentage::parse(lex)
  { val, element }
}

///|
pub fn CT_Percentage::to_element(self : CT_Percentage) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PositivePercentage — Part 1 §20.1.7.6. Annex
/// A.4.1 lines 243..245. Single required `val` attribute of type
/// ST_PositivePercentage (value ≥ 0%).
pub(all) struct CT_PositivePercentage {
  /// @val — ST_PositivePercentage (required).
  val : ST_PositivePercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PositivePercentage::new(
  element : @xml.Element,
) -> CT_PositivePercentage raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_PositivePercentage/@val")
  let val = ST_PositivePercentage::parse(lex)
  { val, element }
}

///|
pub fn CT_PositivePercentage::to_element(
  self : CT_PositivePercentage,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FixedPercentage — Part 1 §20.1.7.3. Annex A.4.1
/// lines 249..251. Single required `val` attribute of type
/// ST_FixedPercentage (|value| ≤ 100%).
pub(all) struct CT_FixedPercentage {
  /// @val — ST_FixedPercentage (required).
  val : ST_FixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FixedPercentage::new(
  element : @xml.Element,
) -> CT_FixedPercentage raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_FixedPercentage/@val")
  let val = ST_FixedPercentage::parse(lex)
  { val, element }
}

///|
pub fn CT_FixedPercentage::to_element(
  self : CT_FixedPercentage,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PositiveFixedPercentage — Part 1 §20.1.7.7.
/// Annex A.4.1 lines 255..257. Single required `val` attribute of
/// type ST_PositiveFixedPercentage (0% ≤ value ≤ 100%).
pub(all) struct CT_PositiveFixedPercentage {
  /// @val — ST_PositiveFixedPercentage (required).
  val : ST_PositiveFixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PositiveFixedPercentage::new(
  element : @xml.Element,
) -> CT_PositiveFixedPercentage raise SchemaViolation {
  let lex = ct_required_string(
    element, "val", "CT_PositiveFixedPercentage/@val",
  )
  let val = ST_PositiveFixedPercentage::parse(lex)
  { val, element }
}

///|
pub fn CT_PositiveFixedPercentage::to_element(
  self : CT_PositiveFixedPercentage,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Ratio — Part 1 §20.1.7.10. Annex A.4.1 lines
/// 258..261. Two required `xsd:long` attributes `n` (numerator) and
/// `d` (denominator) representing the rational scale factor.
pub(all) struct CT_Ratio {
  /// @n — xsd:long numerator (required).
  n : Int64
  /// @d — xsd:long denominator (required).
  d : Int64
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Ratio::new(element : @xml.Element) -> CT_Ratio raise SchemaViolation {
  let n_lex = ct_required_string(element, "n", "CT_Ratio/@n")
  let n = parse_long_or_violate("CT_Ratio/@n", n_lex)
  let d_lex = ct_required_string(element, "d", "CT_Ratio/@d")
  let d = parse_long_or_violate("CT_Ratio/@d", d_lex)
  { n, d, element }
}

///|
pub fn CT_Ratio::to_element(self : CT_Ratio) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Point2D — Part 1 §20.1.7.10 (`off` etc.). Annex
/// A.4.1 lines 262..265. Two required ST_Coordinate attributes (EMU or
/// universal measure units).
pub(all) struct CT_Point2D {
  /// @x — ST_Coordinate (required).
  x : ST_Coordinate
  /// @y — ST_Coordinate (required).
  y : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Point2D::new(
  element : @xml.Element,
) -> CT_Point2D raise SchemaViolation {
  let x_lex = ct_required_string(element, "x", "CT_Point2D/@x")
  let x = ST_Coordinate::parse(x_lex)
  let y_lex = ct_required_string(element, "y", "CT_Point2D/@y")
  let y = ST_Coordinate::parse(y_lex)
  { x, y, element }
}

///|
pub fn CT_Point2D::to_element(self : CT_Point2D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PositiveSize2D — Part 1 §20.1.7.13 (`ext`).
/// Annex A.4.1 lines 266..269. Two required ST_PositiveCoordinate
/// attributes `cx`, `cy` (width, height in EMU).
pub(all) struct CT_PositiveSize2D {
  /// @cx — ST_PositiveCoordinate (required).
  cx : ST_PositiveCoordinate
  /// @cy — ST_PositiveCoordinate (required).
  cy : ST_PositiveCoordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PositiveSize2D::new(
  element : @xml.Element,
) -> CT_PositiveSize2D raise SchemaViolation {
  let cx_lex = ct_required_string(element, "cx", "CT_PositiveSize2D/@cx")
  let cx = ST_PositiveCoordinate::parse(cx_lex)
  let cy_lex = ct_required_string(element, "cy", "CT_PositiveSize2D/@cy")
  let cy = ST_PositiveCoordinate::parse(cy_lex)
  { cx, cy, element }
}

///|
pub fn CT_PositiveSize2D::to_element(self : CT_PositiveSize2D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Scale2D — Part 1 §20.1.7.8 (`scale`). Annex
/// A.4.1 lines 607..612. Two required child CT_Ratio elements `sx`,
/// `sy` (horizontal and vertical scale factors).
pub(all) struct CT_Scale2D {
  /// <sx> (CT_Ratio) — required horizontal scale.
  sx : CT_Ratio
  /// <sy> (CT_Ratio) — required vertical scale.
  sy : CT_Ratio
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Scale2D::new(
  element : @xml.Element,
) -> CT_Scale2D raise SchemaViolation {
  let sx = match ct_first_child(element, "sx") {
    Some(c) => CT_Ratio::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Scale2D/sx",
        reason="missing required child element <sx>",
      )
  }
  let sy = match ct_first_child(element, "sy") {
    Some(c) => CT_Ratio::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Scale2D/sy",
        reason="missing required child element <sy>",
      )
  }
  { sx, sy, element }
}

///|
pub fn CT_Scale2D::to_element(self : CT_Scale2D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Transform2D — Part 1 §20.1.7.6 (`xfrm`). Annex
/// A.4.1 lines 613..621. Optional `off` (CT_Point2D) and `ext`
/// (CT_PositiveSize2D) children; optional `rot` (ST_Angle, default 0),
/// `flipH` (xsd:boolean, default false), `flipV` (xsd:boolean, default
/// false).
pub(all) struct CT_Transform2D {
  /// <off> (CT_Point2D) — optional translation offset.
  off : CT_Point2D?
  /// <ext> (CT_PositiveSize2D) — optional extents.
  ext : CT_PositiveSize2D?
  /// @rot — ST_Angle (optional, default 0).
  rot : ST_Angle
  /// @flipH — xsd:boolean (optional, default false).
  flip_h : Bool
  /// @flipV — xsd:boolean (optional, default false).
  flip_v : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Transform2D::new(
  element : @xml.Element,
) -> CT_Transform2D raise SchemaViolation {
  let off = match ct_first_child(element, "off") {
    Some(c) => Some(CT_Point2D::new(c))
    None => None
  }
  let ext = match ct_first_child(element, "ext") {
    Some(c) => Some(CT_PositiveSize2D::new(c))
    None => None
  }
  let rot = match ct_attr(element, "rot") {
    Some(v) => ST_Angle::parse(v)
    None => ST_Angle::parse("0")
  }
  let flip_h = ct_optional_bool(
    element,
    "flipH",
    default=false,
    "CT_Transform2D/@flipH",
  )
  let flip_v = ct_optional_bool(
    element,
    "flipV",
    default=false,
    "CT_Transform2D/@flipV",
  )
  { off, ext, rot, flip_h, flip_v, element }
}

///|
pub fn CT_Transform2D::to_element(self : CT_Transform2D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GroupTransform2D — Part 1 §20.1.7.5 (`xfrm`
/// inside `grpSpPr`). Annex A.4.1 lines 622..632. Optional `off`
/// (CT_Point2D), `ext` (CT_PositiveSize2D), `chOff` (CT_Point2D) and
/// `chExt` (CT_PositiveSize2D) children; same three optional
/// attributes as CT_Transform2D (`rot`, `flipH`, `flipV`).
pub(all) struct CT_GroupTransform2D {
  /// <off> (CT_Point2D) — optional translation offset.
  off : CT_Point2D?
  /// <ext> (CT_PositiveSize2D) — optional extents.
  ext : CT_PositiveSize2D?
  /// <chOff> (CT_Point2D) — optional child-coordinate translation.
  ch_off : CT_Point2D?
  /// <chExt> (CT_PositiveSize2D) — optional child-coordinate extents.
  ch_ext : CT_PositiveSize2D?
  /// @rot — ST_Angle (optional, default 0).
  rot : ST_Angle
  /// @flipH — xsd:boolean (optional, default false).
  flip_h : Bool
  /// @flipV — xsd:boolean (optional, default false).
  flip_v : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupTransform2D::new(
  element : @xml.Element,
) -> CT_GroupTransform2D raise SchemaViolation {
  let off = match ct_first_child(element, "off") {
    Some(c) => Some(CT_Point2D::new(c))
    None => None
  }
  let ext = match ct_first_child(element, "ext") {
    Some(c) => Some(CT_PositiveSize2D::new(c))
    None => None
  }
  let ch_off = match ct_first_child(element, "chOff") {
    Some(c) => Some(CT_Point2D::new(c))
    None => None
  }
  let ch_ext = match ct_first_child(element, "chExt") {
    Some(c) => Some(CT_PositiveSize2D::new(c))
    None => None
  }
  let rot = match ct_attr(element, "rot") {
    Some(v) => ST_Angle::parse(v)
    None => ST_Angle::parse("0")
  }
  let flip_h = ct_optional_bool(
    element,
    "flipH",
    default=false,
    "CT_GroupTransform2D/@flipH",
  )
  let flip_v = ct_optional_bool(
    element,
    "flipV",
    default=false,
    "CT_GroupTransform2D/@flipV",
  )
  { off, ext, ch_off, ch_ext, rot, flip_h, flip_v, element }
}

///|
pub fn CT_GroupTransform2D::to_element(
  self : CT_GroupTransform2D,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Point3D — Part 1 §20.1.7.18 (`anchor`). Annex
/// A.4.1 lines 633..637. Three required ST_Coordinate attributes `x`,
/// `y`, `z`.
pub(all) struct CT_Point3D {
  /// @x — ST_Coordinate (required).
  x : ST_Coordinate
  /// @y — ST_Coordinate (required).
  y : ST_Coordinate
  /// @z — ST_Coordinate (required).
  z : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Point3D::new(
  element : @xml.Element,
) -> CT_Point3D raise SchemaViolation {
  let x_lex = ct_required_string(element, "x", "CT_Point3D/@x")
  let x = ST_Coordinate::parse(x_lex)
  let y_lex = ct_required_string(element, "y", "CT_Point3D/@y")
  let y = ST_Coordinate::parse(y_lex)
  let z_lex = ct_required_string(element, "z", "CT_Point3D/@z")
  let z = ST_Coordinate::parse(z_lex)
  { x, y, z, element }
}

///|
pub fn CT_Point3D::to_element(self : CT_Point3D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Vector3D — Part 1 §20.1.7.27 (`norm`). Annex
/// A.4.1 lines 638..642. Three required ST_Coordinate attributes `dx`,
/// `dy`, `dz` (direction-cosine deltas).
pub(all) struct CT_Vector3D {
  /// @dx — ST_Coordinate (required).
  dx : ST_Coordinate
  /// @dy — ST_Coordinate (required).
  dy : ST_Coordinate
  /// @dz — ST_Coordinate (required).
  dz : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Vector3D::new(
  element : @xml.Element,
) -> CT_Vector3D raise SchemaViolation {
  let dx_lex = ct_required_string(element, "dx", "CT_Vector3D/@dx")
  let dx = ST_Coordinate::parse(dx_lex)
  let dy_lex = ct_required_string(element, "dy", "CT_Vector3D/@dy")
  let dy = ST_Coordinate::parse(dy_lex)
  let dz_lex = ct_required_string(element, "dz", "CT_Vector3D/@dz")
  let dz = ST_Coordinate::parse(dz_lex)
  { dx, dy, dz, element }
}

///|
pub fn CT_Vector3D::to_element(self : CT_Vector3D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SphereCoords — Part 1 §20.1.7.20 (`rot`). Annex
/// A.4.1 lines 643..647. Three required ST_PositiveFixedAngle attributes
/// `lat` (latitude), `lon` (longitude) and `rev` (revolution).
pub(all) struct CT_SphereCoords {
  /// @lat — ST_PositiveFixedAngle (required).
  lat : ST_PositiveFixedAngle
  /// @lon — ST_PositiveFixedAngle (required).
  lon : ST_PositiveFixedAngle
  /// @rev — ST_PositiveFixedAngle (required).
  rev : ST_PositiveFixedAngle
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SphereCoords::new(
  element : @xml.Element,
) -> CT_SphereCoords raise SchemaViolation {
  let lat_lex = ct_required_string(element, "lat", "CT_SphereCoords/@lat")
  let lat = ST_PositiveFixedAngle::parse(lat_lex)
  let lon_lex = ct_required_string(element, "lon", "CT_SphereCoords/@lon")
  let lon = ST_PositiveFixedAngle::parse(lon_lex)
  let rev_lex = ct_required_string(element, "rev", "CT_SphereCoords/@rev")
  let rev = ST_PositiveFixedAngle::parse(rev_lex)
  { lat, lon, rev, element }
}

///|
pub fn CT_SphereCoords::to_element(self : CT_SphereCoords) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RelativeRect — Part 1 §20.1.7.30 (`fillRect`,
/// `srcRect`, `tileRect`). Annex A.4.1 lines 648..653. Four optional
/// ST_Percentage attributes `l`, `t`, `r`, `b` each defaulting to
/// "0%".
pub(all) struct CT_RelativeRect {
  /// @l — ST_Percentage (optional, default "0%").
  l : ST_Percentage
  /// @t — ST_Percentage (optional, default "0%").
  t : ST_Percentage
  /// @r — ST_Percentage (optional, default "0%").
  r : ST_Percentage
  /// @b — ST_Percentage (optional, default "0%").
  b : ST_Percentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RelativeRect::new(
  element : @xml.Element,
) -> CT_RelativeRect raise SchemaViolation {
  let l = match ct_attr(element, "l") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("0%")
  }
  let t = match ct_attr(element, "t") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("0%")
  }
  let r = match ct_attr(element, "r") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("0%")
  }
  let b = match ct_attr(element, "b") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("0%")
  }
  { l, t, r, b, element }
}

///|
pub fn CT_RelativeRect::to_element(self : CT_RelativeRect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GeomGuide — Part 1 §20.1.9.11 (`gd`). Annex
/// A.4.1 lines 1937..1940. Two required attributes: `name`
/// (ST_GeomGuideName = xsd:token) and `fmla` (ST_GeomGuideFormula =
/// xsd:string). Lexical forms are kept as raw strings because the
/// expression language of `fmla` is parsed by the geometry evaluator
/// (`drawing_ml/preset_geometry`) at render time, not at decode time.
pub(all) struct CT_GeomGuide {
  /// @name — ST_GeomGuideName (required).
  name : String
  /// @fmla — ST_GeomGuideFormula (required).
  fmla : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GeomGuide::new(
  element : @xml.Element,
) -> CT_GeomGuide raise SchemaViolation {
  let name = ct_required_string(element, "name", "CT_GeomGuide/@name")
  let fmla = ct_required_string(element, "fmla", "CT_GeomGuide/@fmla")
  { name, fmla, element }
}

///|
pub fn CT_GeomGuide::to_element(self : CT_GeomGuide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GeomGuideList — Part 1 §20.1.9.12 (`avLst`,
/// `gdLst`). Annex A.4.1 lines 1941..1945. Zero or more `gd`
/// (CT_GeomGuide) children.
pub(all) struct CT_GeomGuideList {
  /// <gd>* (CT_GeomGuide).
  gd : Array[CT_GeomGuide]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GeomGuideList::new(
  element : @xml.Element,
) -> CT_GeomGuideList raise SchemaViolation {
  let gd : Array[CT_GeomGuide] = []
  for child in ct_children(element, "gd") {
    gd.push(CT_GeomGuide::new(child))
  }
  { gd, element }
}

///|
pub fn CT_GeomGuideList::to_element(self : CT_GeomGuideList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AdjPoint2D — Part 1 §20.1.9.2 (`pt`). Annex
/// A.4.1 lines 1952..1955. Two required ST_AdjCoordinate attributes
/// (`x`, `y`). ST_AdjCoordinate is the union of ST_Coordinate and
/// ST_GeomGuideName; the lexical form is kept as raw `String` because
/// guide-name references are resolved by the geometry evaluator at
/// render time.
pub(all) struct CT_AdjPoint2D {
  /// @x — ST_AdjCoordinate (required, raw lexical form).
  x : String
  /// @y — ST_AdjCoordinate (required, raw lexical form).
  y : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AdjPoint2D::new(
  element : @xml.Element,
) -> CT_AdjPoint2D raise SchemaViolation {
  let x = ct_required_string(element, "x", "CT_AdjPoint2D/@x")
  let y = ct_required_string(element, "y", "CT_AdjPoint2D/@y")
  { x, y, element }
}

///|
pub fn CT_AdjPoint2D::to_element(self : CT_AdjPoint2D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GeomRect — Part 1 §20.1.9.13 (`rect` text
/// rectangle). Annex A.4.1 lines 1956..1961. Four required
/// ST_AdjCoordinate attributes `l`, `t`, `r`, `b`. Lexical forms are
/// preserved verbatim — see CT_AdjPoint2D.
pub(all) struct CT_GeomRect {
  /// @l — ST_AdjCoordinate (required, raw lexical form).
  l : String
  /// @t — ST_AdjCoordinate (required, raw lexical form).
  t : String
  /// @r — ST_AdjCoordinate (required, raw lexical form).
  r : String
  /// @b — ST_AdjCoordinate (required, raw lexical form).
  b : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GeomRect::new(
  element : @xml.Element,
) -> CT_GeomRect raise SchemaViolation {
  let l = ct_required_string(element, "l", "CT_GeomRect/@l")
  let t = ct_required_string(element, "t", "CT_GeomRect/@t")
  let r = ct_required_string(element, "r", "CT_GeomRect/@r")
  let b = ct_required_string(element, "b", "CT_GeomRect/@b")
  { l, t, r, b, element }
}

///|
pub fn CT_GeomRect::to_element(self : CT_GeomRect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_XYAdjustHandle — Part 1 §20.1.9.21 (`ahXY`).
/// Annex A.4.1 lines 1962..1972. Required `pos` (CT_AdjPoint2D) child
/// plus six optional attributes that bind the adjust handle to a
/// guide and clamp its X / Y range: `gdRefX`, `minX`, `maxX`, `gdRefY`,
/// `minY`, `maxY`. All values are kept as raw strings because the
/// adjust handle clamps reference guide-name or coordinate expressions
/// that the geometry evaluator resolves at render time.
pub(all) struct CT_XYAdjustHandle {
  /// <pos> (CT_AdjPoint2D) — required.
  pos : CT_AdjPoint2D
  /// @gdRefX — ST_GeomGuideName (optional).
  gd_ref_x : String?
  /// @minX — ST_AdjCoordinate (optional, raw lexical form).
  min_x : String?
  /// @maxX — ST_AdjCoordinate (optional, raw lexical form).
  max_x : String?
  /// @gdRefY — ST_GeomGuideName (optional).
  gd_ref_y : String?
  /// @minY — ST_AdjCoordinate (optional, raw lexical form).
  min_y : String?
  /// @maxY — ST_AdjCoordinate (optional, raw lexical form).
  max_y : String?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_XYAdjustHandle::new(
  element : @xml.Element,
) -> CT_XYAdjustHandle raise SchemaViolation {
  let pos = match ct_first_child(element, "pos") {
    Some(c) => CT_AdjPoint2D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_XYAdjustHandle/pos",
        reason="missing required child element <pos>",
      )
  }
  let gd_ref_x = ct_attr(element, "gdRefX")
  let min_x = ct_attr(element, "minX")
  let max_x = ct_attr(element, "maxX")
  let gd_ref_y = ct_attr(element, "gdRefY")
  let min_y = ct_attr(element, "minY")
  let max_y = ct_attr(element, "maxY")
  { pos, gd_ref_x, min_x, max_x, gd_ref_y, min_y, max_y, element }
}

///|
pub fn CT_XYAdjustHandle::to_element(self : CT_XYAdjustHandle) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PolarAdjustHandle — Part 1 §20.1.9.20 (`ahPolar`).
/// Annex A.4.1 lines 1973..1983. Required `pos` (CT_AdjPoint2D) child
/// plus six optional attributes: `gdRefR`, `minR`, `maxR`, `gdRefAng`,
/// `minAng`, `maxAng`. R-attributes are ST_AdjCoordinate; Ang-attributes
/// are ST_AdjAngle. Raw lexical forms preserved.
pub(all) struct CT_PolarAdjustHandle {
  /// <pos> (CT_AdjPoint2D) — required.
  pos : CT_AdjPoint2D
  /// @gdRefR — ST_GeomGuideName (optional).
  gd_ref_r : String?
  /// @minR — ST_AdjCoordinate (optional, raw lexical form).
  min_r : String?
  /// @maxR — ST_AdjCoordinate (optional, raw lexical form).
  max_r : String?
  /// @gdRefAng — ST_GeomGuideName (optional).
  gd_ref_ang : String?
  /// @minAng — ST_AdjAngle (optional, raw lexical form).
  min_ang : String?
  /// @maxAng — ST_AdjAngle (optional, raw lexical form).
  max_ang : String?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PolarAdjustHandle::new(
  element : @xml.Element,
) -> CT_PolarAdjustHandle raise SchemaViolation {
  let pos = match ct_first_child(element, "pos") {
    Some(c) => CT_AdjPoint2D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_PolarAdjustHandle/pos",
        reason="missing required child element <pos>",
      )
  }
  let gd_ref_r = ct_attr(element, "gdRefR")
  let min_r = ct_attr(element, "minR")
  let max_r = ct_attr(element, "maxR")
  let gd_ref_ang = ct_attr(element, "gdRefAng")
  let min_ang = ct_attr(element, "minAng")
  let max_ang = ct_attr(element, "maxAng")
  { pos, gd_ref_r, min_r, max_r, gd_ref_ang, min_ang, max_ang, element }
}

///|
pub fn CT_PolarAdjustHandle::to_element(
  self : CT_PolarAdjustHandle,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AdjustHandleList — Part 1 §20.1.9.1 (`ahLst`).
/// Annex A.4.1 lines 1990..1995. Zero or more choice items: `ahXY`
/// (CT_XYAdjustHandle) or `ahPolar` (CT_PolarAdjustHandle). To preserve
/// document order across the heterogeneous choice the projection
/// collects each variant in order.
pub(all) enum AdjustHandle {
  /// <ahXY> (CT_XYAdjustHandle) choice variant.
  AhXY(CT_XYAdjustHandle)
  /// <ahPolar> (CT_PolarAdjustHandle) choice variant.
  AhPolar(CT_PolarAdjustHandle)
} derive(Eq, Debug)

///|
pub(all) struct CT_AdjustHandleList {
  /// (ahXY | ahPolar)* — ordered sequence of adjust-handle choice
  /// variants.
  handles : Array[AdjustHandle]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AdjustHandleList::new(
  element : @xml.Element,
) -> CT_AdjustHandleList raise SchemaViolation {
  let handles : Array[AdjustHandle] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match child.name.local_name {
          "ahXY" => handles.push(AhXY(CT_XYAdjustHandle::new(child)))
          "ahPolar" => handles.push(AhPolar(CT_PolarAdjustHandle::new(child)))
          _ => ()
        }
      _ => ()
    }
  }
  { handles, element }
}

///|
pub fn CT_AdjustHandleList::to_element(
  self : CT_AdjustHandleList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ConnectionSite — Part 1 §20.1.9.10 (`cxn`).
/// Annex A.4.1 lines 1984..1989. Required `pos` (CT_AdjPoint2D) child
/// and required `ang` (ST_AdjAngle, raw lexical form) attribute that
/// fixes the connector's outgoing direction at the site.
pub(all) struct CT_ConnectionSite {
  /// <pos> (CT_AdjPoint2D) — required.
  pos : CT_AdjPoint2D
  /// @ang — ST_AdjAngle (required, raw lexical form).
  ang : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectionSite::new(
  element : @xml.Element,
) -> CT_ConnectionSite raise SchemaViolation {
  let pos = match ct_first_child(element, "pos") {
    Some(c) => CT_AdjPoint2D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_ConnectionSite/pos",
        reason="missing required child element <pos>",
      )
  }
  let ang = ct_required_string(element, "ang", "CT_ConnectionSite/@ang")
  { pos, ang, element }
}

///|
pub fn CT_ConnectionSite::to_element(self : CT_ConnectionSite) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ConnectionSiteList — Part 1 §20.1.9.9 (`cxnLst`).
/// Annex A.4.1 lines 1996..2000. Zero or more `cxn` (CT_ConnectionSite)
/// children.
pub(all) struct CT_ConnectionSiteList {
  /// <cxn>* (CT_ConnectionSite).
  cxn : Array[CT_ConnectionSite]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectionSiteList::new(
  element : @xml.Element,
) -> CT_ConnectionSiteList raise SchemaViolation {
  let cxn : Array[CT_ConnectionSite] = []
  for child in ct_children(element, "cxn") {
    cxn.push(CT_ConnectionSite::new(child))
  }
  { cxn, element }
}

///|
pub fn CT_ConnectionSiteList::to_element(
  self : CT_ConnectionSiteList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Connection — Part 1 §20.1.9.8 (`stCxn`, `endCxn`).
/// Annex A.4.1 lines 2001..2004. Two required attributes: `id`
/// (ST_DrawingElementId = xsd:unsignedInt) and `idx` (xsd:unsignedInt)
/// identifying the target shape and its connection-site index.
pub(all) struct CT_Connection {
  /// @id — ST_DrawingElementId (required).
  id : UInt
  /// @idx — xsd:unsignedInt (required).
  idx : UInt
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Connection::new(
  element : @xml.Element,
) -> CT_Connection raise SchemaViolation {
  let id_lex = ct_required_string(element, "id", "CT_Connection/@id")
  let id = ct_parse_uint_lex(id_lex, "CT_Connection/@id")
  let idx_lex = ct_required_string(element, "idx", "CT_Connection/@idx")
  let idx = ct_parse_uint_lex(idx_lex, "CT_Connection/@idx")
  { id, idx, element }
}

///|
pub fn CT_Connection::to_element(self : CT_Connection) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Path2DMoveTo — Part 1 §20.1.9.18 (`moveTo`).
/// Annex A.4.1 lines 2005..2009. Required single `pt` (CT_AdjPoint2D)
/// child.
pub(all) struct CT_Path2DMoveTo {
  /// <pt> (CT_AdjPoint2D) — required target point.
  pt : CT_AdjPoint2D
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DMoveTo::new(
  element : @xml.Element,
) -> CT_Path2DMoveTo raise SchemaViolation {
  let pt = match ct_first_child(element, "pt") {
    Some(c) => CT_AdjPoint2D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Path2DMoveTo/pt",
        reason="missing required child element <pt>",
      )
  }
  { pt, element }
}

///|
pub fn CT_Path2DMoveTo::to_element(self : CT_Path2DMoveTo) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Path2DLineTo — Part 1 §20.1.9.16 (`lnTo`).
/// Annex A.4.1 lines 2010..2014. Required single `pt` (CT_AdjPoint2D)
/// child.
pub(all) struct CT_Path2DLineTo {
  /// <pt> (CT_AdjPoint2D) — required target point.
  pt : CT_AdjPoint2D
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DLineTo::new(
  element : @xml.Element,
) -> CT_Path2DLineTo raise SchemaViolation {
  let pt = match ct_first_child(element, "pt") {
    Some(c) => CT_AdjPoint2D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Path2DLineTo/pt",
        reason="missing required child element <pt>",
      )
  }
  { pt, element }
}

///|
pub fn CT_Path2DLineTo::to_element(self : CT_Path2DLineTo) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Path2DArcTo — Part 1 §20.1.9.14 (`arcTo`). Annex
/// A.4.1 lines 2015..2020. Four required attributes: `wR` and `hR`
/// (ST_AdjCoordinate ellipse radii) plus `stAng` and `swAng`
/// (ST_AdjAngle start and sweep angles). All raw lexical forms.
pub(all) struct CT_Path2DArcTo {
  /// @wR — ST_AdjCoordinate (required, raw lexical form).
  w_r : String
  /// @hR — ST_AdjCoordinate (required, raw lexical form).
  h_r : String
  /// @stAng — ST_AdjAngle (required, raw lexical form).
  st_ang : String
  /// @swAng — ST_AdjAngle (required, raw lexical form).
  sw_ang : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DArcTo::new(
  element : @xml.Element,
) -> CT_Path2DArcTo raise SchemaViolation {
  let w_r = ct_required_string(element, "wR", "CT_Path2DArcTo/@wR")
  let h_r = ct_required_string(element, "hR", "CT_Path2DArcTo/@hR")
  let st_ang = ct_required_string(element, "stAng", "CT_Path2DArcTo/@stAng")
  let sw_ang = ct_required_string(element, "swAng", "CT_Path2DArcTo/@swAng")
  { w_r, h_r, st_ang, sw_ang, element }
}

///|
pub fn CT_Path2DArcTo::to_element(self : CT_Path2DArcTo) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Path2DQuadBezierTo — Part 1 §20.1.9.19
/// (`quadBezTo`). Annex A.4.1 lines 2021..2025. Required exactly two
/// `pt` (CT_AdjPoint2D) children: the control and end points.
pub(all) struct CT_Path2DQuadBezierTo {
  /// <pt>[0] (CT_AdjPoint2D) — required control point.
  pt0 : CT_AdjPoint2D
  /// <pt>[1] (CT_AdjPoint2D) — required end point.
  pt1 : CT_AdjPoint2D
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DQuadBezierTo::new(
  element : @xml.Element,
) -> CT_Path2DQuadBezierTo raise SchemaViolation {
  let points : Array[CT_AdjPoint2D] = []
  for child in ct_children(element, "pt") {
    points.push(CT_AdjPoint2D::new(child))
  }
  if points.length() != 2 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path="CT_Path2DQuadBezierTo/pt",
      reason="expected exactly 2 <pt> children, got " +
        points.length().to_string(),
    )
  }
  { pt0: points[0], pt1: points[1], element }
}

///|
pub fn CT_Path2DQuadBezierTo::to_element(
  self : CT_Path2DQuadBezierTo,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Path2DCubicBezierTo — Part 1 §20.1.9.15
/// (`cubicBezTo`). Annex A.4.1 lines 2026..2030. Required exactly three
/// `pt` (CT_AdjPoint2D) children: two controls and one end point.
pub(all) struct CT_Path2DCubicBezierTo {
  /// <pt>[0] (CT_AdjPoint2D) — required first control point.
  pt0 : CT_AdjPoint2D
  /// <pt>[1] (CT_AdjPoint2D) — required second control point.
  pt1 : CT_AdjPoint2D
  /// <pt>[2] (CT_AdjPoint2D) — required end point.
  pt2 : CT_AdjPoint2D
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DCubicBezierTo::new(
  element : @xml.Element,
) -> CT_Path2DCubicBezierTo raise SchemaViolation {
  let points : Array[CT_AdjPoint2D] = []
  for child in ct_children(element, "pt") {
    points.push(CT_AdjPoint2D::new(child))
  }
  if points.length() != 3 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path="CT_Path2DCubicBezierTo/pt",
      reason="expected exactly 3 <pt> children, got " +
        points.length().to_string(),
    )
  }
  { pt0: points[0], pt1: points[1], pt2: points[2], element }
}

///|
pub fn CT_Path2DCubicBezierTo::to_element(
  self : CT_Path2DCubicBezierTo,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Path2DClose — Part 1 §20.1.9.17 (`close`). Annex
/// A.4.1 line 2031. Empty complex type — presence alone closes the
/// current sub-path.
pub(all) struct CT_Path2DClose {
  /// Empty-XSD-type marker (always true once decoded).
  marker : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DClose::new(element : @xml.Element) -> CT_Path2DClose {
  { marker: true, element }
}

///|
pub fn CT_Path2DClose::to_element(self : CT_Path2DClose) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Path2D — Part 1 §20.1.9.15 (`path` inside
/// `pathLst`). Annex A.4.1 lines 2042..2056. A choice of path commands
/// in document order: `close`, `moveTo`, `lnTo`, `arcTo`, `quadBezTo`,
/// `cubicBezTo`. Plus five optional attributes:
///   • `w` (ST_PositiveCoordinate, default 0) — path bounding-box width;
///   • `h` (ST_PositiveCoordinate, default 0) — path bounding-box height;
///   • `fill` (ST_PathFillMode, default `norm`) — preserved as raw
///     lexical form (no MoonBit enum projection in this package);
///   • `stroke` (xsd:boolean, default true) — whether the path is
///     stroked;
///   • `extrusionOk` (xsd:boolean, default true) — whether the path may
///     participate in 3D extrusion.
pub(all) enum Path2DCommand {
  /// <close> (CT_Path2DClose) variant.
  PathClose(CT_Path2DClose)
  /// <moveTo> (CT_Path2DMoveTo) variant.
  PathMoveTo(CT_Path2DMoveTo)
  /// <lnTo> (CT_Path2DLineTo) variant.
  PathLineTo(CT_Path2DLineTo)
  /// <arcTo> (CT_Path2DArcTo) variant.
  PathArcTo(CT_Path2DArcTo)
  /// <quadBezTo> (CT_Path2DQuadBezierTo) variant.
  PathQuadBezTo(CT_Path2DQuadBezierTo)
  /// <cubicBezTo> (CT_Path2DCubicBezierTo) variant.
  PathCubicBezTo(CT_Path2DCubicBezierTo)
} derive(Eq, Debug)

///|
pub(all) struct CT_Path2D {
  /// (close | moveTo | lnTo | arcTo | quadBezTo | cubicBezTo)* —
  /// ordered sequence of path commands.
  commands : Array[Path2DCommand]
  /// @w — ST_PositiveCoordinate (optional, default 0).
  w : ST_PositiveCoordinate
  /// @h — ST_PositiveCoordinate (optional, default 0).
  h : ST_PositiveCoordinate
  /// @fill — ST_PathFillMode (optional, default "norm", raw lexical
  /// form because no MoonBit enum projection exists yet).
  fill : String
  /// @stroke — xsd:boolean (optional, default true).
  stroke : Bool
  /// @extrusionOk — xsd:boolean (optional, default true).
  extrusion_ok : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2D::new(
  element : @xml.Element,
) -> CT_Path2D raise SchemaViolation {
  let commands : Array[Path2DCommand] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match child.name.local_name {
          "close" => commands.push(PathClose(CT_Path2DClose::new(child)))
          "moveTo" => commands.push(PathMoveTo(CT_Path2DMoveTo::new(child)))
          "lnTo" => commands.push(PathLineTo(CT_Path2DLineTo::new(child)))
          "arcTo" => commands.push(PathArcTo(CT_Path2DArcTo::new(child)))
          "quadBezTo" =>
            commands.push(PathQuadBezTo(CT_Path2DQuadBezierTo::new(child)))
          "cubicBezTo" =>
            commands.push(PathCubicBezTo(CT_Path2DCubicBezierTo::new(child)))
          _ => ()
        }
      _ => ()
    }
  }
  let w = match ct_attr(element, "w") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let h = match ct_attr(element, "h") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let fill = ct_optional_string(element, "fill", default="norm")
  let stroke = ct_optional_bool(
    element,
    "stroke",
    default=true,
    "CT_Path2D/@stroke",
  )
  let extrusion_ok = ct_optional_bool(
    element,
    "extrusionOk",
    default=true,
    "CT_Path2D/@extrusionOk",
  )
  { commands, w, h, fill, stroke, extrusion_ok, element }
}

///|
pub fn CT_Path2D::to_element(self : CT_Path2D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Path2DList — Part 1 §20.1.9.6 (`pathLst`).
/// Annex A.4.1 lines 2057..2061. Zero or more `path` (CT_Path2D)
/// children.
pub(all) struct CT_Path2DList {
  /// <path>* (CT_Path2D) — ordered sequence of paths.
  path : Array[CT_Path2D]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DList::new(
  element : @xml.Element,
) -> CT_Path2DList raise SchemaViolation {
  let path : Array[CT_Path2D] = []
  for child in ct_children(element, "path") {
    path.push(CT_Path2D::new(child))
  }
  { path, element }
}

///|
pub fn CT_Path2DList::to_element(self : CT_Path2DList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresetGeometry2D — Part 1 §20.1.9.18
/// (`prstGeom`). Annex A.4.1 lines 2062..2067. Optional `avLst`
/// (CT_GeomGuideList) child plus required `prst` (ST_ShapeType =
/// xsd:token enumeration of preset shape names). The lexical form of
/// `prst` is preserved verbatim because the preset shape enumeration
/// lives in the `preset_geometry` sub-package and is validated by the
/// shared `validate_main_element` guard at reader entry.
pub(all) struct CT_PresetGeometry2D {
  /// <avLst> (CT_GeomGuideList) — optional adjust-value list.
  av_lst : CT_GeomGuideList?
  /// @prst — ST_ShapeType (required, raw lexical form).
  prst : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetGeometry2D::new(
  element : @xml.Element,
) -> CT_PresetGeometry2D raise SchemaViolation {
  let av_lst = match ct_first_child(element, "avLst") {
    Some(c) => Some(CT_GeomGuideList::new(c))
    None => None
  }
  let prst = ct_required_string(element, "prst", "CT_PresetGeometry2D/@prst")
  { av_lst, prst, element }
}

///|
pub fn CT_PresetGeometry2D::to_element(
  self : CT_PresetGeometry2D,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresetTextShape — Part 1 §20.1.10.55
/// (`prstTxWarp`). Annex A.4.1 lines 2068..2073. Optional `avLst`
/// (CT_GeomGuideList) child plus required `prst` (ST_TextShapeType
/// enumeration). ST_TextShapeType is typed in
/// `simple_types.mbt::ST_TextShapeType` so the decoder validates the
/// preset token against the closed enumeration.
pub(all) struct CT_PresetTextShape {
  /// <avLst> (CT_GeomGuideList) — optional adjust-value list.
  av_lst : CT_GeomGuideList?
  /// @prst — ST_TextShapeType (required).
  prst : ST_TextShapeType
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetTextShape::new(
  element : @xml.Element,
) -> CT_PresetTextShape raise SchemaViolation {
  let av_lst = match ct_first_child(element, "avLst") {
    Some(c) => Some(CT_GeomGuideList::new(c))
    None => None
  }
  let prst_lex = ct_required_string(element, "prst", "CT_PresetTextShape/@prst")
  let prst = ST_TextShapeType::parse(prst_lex)
  { av_lst, prst, element }
}

///|
pub fn CT_PresetTextShape::to_element(
  self : CT_PresetTextShape,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomGeometry2D — Part 1 §20.1.9.8 (`custGeom`).
/// Annex A.4.1 lines 2074..2083. Six children: `avLst?`, `gdLst?`,
/// `ahLst?`, `cxnLst?`, `rect?` and required `pathLst`. The custom
/// geometry container marshals every aspect of a user-defined shape.
pub(all) struct CT_CustomGeometry2D {
  /// <avLst> (CT_GeomGuideList) — optional adjust-value list.
  av_lst : CT_GeomGuideList?
  /// <gdLst> (CT_GeomGuideList) — optional geometry-guide list.
  gd_lst : CT_GeomGuideList?
  /// <ahLst> (CT_AdjustHandleList) — optional adjust-handle list.
  ah_lst : CT_AdjustHandleList?
  /// <cxnLst> (CT_ConnectionSiteList) — optional connection-site list.
  cxn_lst : CT_ConnectionSiteList?
  /// <rect> (CT_GeomRect) — optional text rectangle.
  rect : CT_GeomRect?
  /// <pathLst> (CT_Path2DList) — required path list.
  path_lst : CT_Path2DList
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomGeometry2D::new(
  element : @xml.Element,
) -> CT_CustomGeometry2D raise SchemaViolation {
  let av_lst = match ct_first_child(element, "avLst") {
    Some(c) => Some(CT_GeomGuideList::new(c))
    None => None
  }
  let gd_lst = match ct_first_child(element, "gdLst") {
    Some(c) => Some(CT_GeomGuideList::new(c))
    None => None
  }
  let ah_lst = match ct_first_child(element, "ahLst") {
    Some(c) => Some(CT_AdjustHandleList::new(c))
    None => None
  }
  let cxn_lst = match ct_first_child(element, "cxnLst") {
    Some(c) => Some(CT_ConnectionSiteList::new(c))
    None => None
  }
  let rect = match ct_first_child(element, "rect") {
    Some(c) => Some(CT_GeomRect::new(c))
    None => None
  }
  let path_lst = match ct_first_child(element, "pathLst") {
    Some(c) => CT_Path2DList::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_CustomGeometry2D/pathLst",
        reason="missing required child element <pathLst>",
      )
  }
  { av_lst, gd_lst, ah_lst, cxn_lst, rect, path_lst, element }
}

///|
pub fn CT_CustomGeometry2D::to_element(
  self : CT_CustomGeometry2D,
) -> @xml.Element {
  self.element
}

///|
pub fn read_transform2d(bytes : Bytes) -> CT_Transform2D raise {
  CT_Transform2D::new(read_main_root(bytes, "xfrm"))
}

///|
pub fn write_transform2d(value : CT_Transform2D) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_preset_geometry2d(bytes : Bytes) -> CT_PresetGeometry2D raise {
  CT_PresetGeometry2D::new(read_main_root(bytes, "prstGeom"))
}

///|
pub fn write_preset_geometry2d(value : CT_PresetGeometry2D) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_custom_geometry2d(bytes : Bytes) -> CT_CustomGeometry2D raise {
  CT_CustomGeometry2D::new(read_main_root(bytes, "custGeom"))
}

///|
pub fn write_custom_geometry2d(value : CT_CustomGeometry2D) -> Bytes {
  write_element(value.element)
}
