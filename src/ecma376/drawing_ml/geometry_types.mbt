///|
/// XSD complex type CT_Angle (§20.1.7).
pub(all) struct CT_Angle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Angle::new(element : @xml.Element) -> CT_Angle {
  { element, }
}

///|
/// XSD complex type CT_PositiveFixedAngle (§20.1.7).
pub(all) struct CT_PositiveFixedAngle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PositiveFixedAngle::new(
  element : @xml.Element,
) -> CT_PositiveFixedAngle {
  { element, }
}

///|
/// XSD complex type CT_Percentage (§20.1.7).
pub(all) struct CT_Percentage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Percentage::new(element : @xml.Element) -> CT_Percentage {
  { element, }
}

///|
/// XSD complex type CT_PositivePercentage (§20.1.7).
pub(all) struct CT_PositivePercentage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PositivePercentage::new(
  element : @xml.Element,
) -> CT_PositivePercentage {
  { element, }
}

///|
/// XSD complex type CT_FixedPercentage (§20.1.7).
pub(all) struct CT_FixedPercentage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FixedPercentage::new(element : @xml.Element) -> CT_FixedPercentage {
  { element, }
}

///|
/// XSD complex type CT_PositiveFixedPercentage (§20.1.7).
pub(all) struct CT_PositiveFixedPercentage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PositiveFixedPercentage::new(
  element : @xml.Element,
) -> CT_PositiveFixedPercentage {
  { element, }
}

///|
/// XSD complex type CT_Ratio (§20.1.7).
pub(all) struct CT_Ratio {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Ratio::new(element : @xml.Element) -> CT_Ratio {
  { element, }
}

///|
/// XSD complex type CT_Point2D (§20.1.7).
pub(all) struct CT_Point2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Point2D::new(element : @xml.Element) -> CT_Point2D {
  { element, }
}

///|
/// XSD complex type CT_PositiveSize2D (§20.1.7).
pub(all) struct CT_PositiveSize2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PositiveSize2D::new(element : @xml.Element) -> CT_PositiveSize2D {
  { element, }
}

///|
/// XSD complex type CT_Scale2D (§20.1.7).
pub(all) struct CT_Scale2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Scale2D::new(element : @xml.Element) -> CT_Scale2D {
  { element, }
}

///|
/// XSD complex type CT_Transform2D (§20.1.7).
pub(all) struct CT_Transform2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Transform2D::new(element : @xml.Element) -> CT_Transform2D {
  { element, }
}

///|
/// XSD complex type CT_GroupTransform2D (§20.1.7).
pub(all) struct CT_GroupTransform2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupTransform2D::new(element : @xml.Element) -> CT_GroupTransform2D {
  { element, }
}

///|
/// XSD complex type CT_Point3D (§20.1.7).
pub(all) struct CT_Point3D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Point3D::new(element : @xml.Element) -> CT_Point3D {
  { element, }
}

///|
/// XSD complex type CT_Vector3D (§20.1.7).
pub(all) struct CT_Vector3D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Vector3D::new(element : @xml.Element) -> CT_Vector3D {
  { element, }
}

///|
/// XSD complex type CT_SphereCoords (§20.1.7).
pub(all) struct CT_SphereCoords {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SphereCoords::new(element : @xml.Element) -> CT_SphereCoords {
  { element, }
}

///|
/// XSD complex type CT_RelativeRect (§20.1.7).
pub(all) struct CT_RelativeRect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RelativeRect::new(element : @xml.Element) -> CT_RelativeRect {
  { element, }
}

///|
/// XSD complex type CT_GeomGuide (§20.1.9).
pub(all) struct CT_GeomGuide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GeomGuide::new(element : @xml.Element) -> CT_GeomGuide {
  { element, }
}

///|
/// XSD complex type CT_GeomGuideList (§20.1.9).
pub(all) struct CT_GeomGuideList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GeomGuideList::new(element : @xml.Element) -> CT_GeomGuideList {
  { element, }
}

///|
/// XSD complex type CT_AdjPoint2D (§20.1.9).
pub(all) struct CT_AdjPoint2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AdjPoint2D::new(element : @xml.Element) -> CT_AdjPoint2D {
  { element, }
}

///|
/// XSD complex type CT_GeomRect (§20.1.9).
pub(all) struct CT_GeomRect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GeomRect::new(element : @xml.Element) -> CT_GeomRect {
  { element, }
}

///|
/// XSD complex type CT_XYAdjustHandle (§20.1.9).
pub(all) struct CT_XYAdjustHandle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_XYAdjustHandle::new(element : @xml.Element) -> CT_XYAdjustHandle {
  { element, }
}

///|
/// XSD complex type CT_PolarAdjustHandle (§20.1.9).
pub(all) struct CT_PolarAdjustHandle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PolarAdjustHandle::new(
  element : @xml.Element,
) -> CT_PolarAdjustHandle {
  { element, }
}

///|
/// XSD complex type CT_AdjustHandleList (§20.1.9).
pub(all) struct CT_AdjustHandleList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AdjustHandleList::new(element : @xml.Element) -> CT_AdjustHandleList {
  { element, }
}

///|
/// XSD complex type CT_ConnectionSite (§20.1.9).
pub(all) struct CT_ConnectionSite {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectionSite::new(element : @xml.Element) -> CT_ConnectionSite {
  { element, }
}

///|
/// XSD complex type CT_ConnectionSiteList (§20.1.9).
pub(all) struct CT_ConnectionSiteList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectionSiteList::new(
  element : @xml.Element,
) -> CT_ConnectionSiteList {
  { element, }
}

///|
/// XSD complex type CT_Connection (§20.1.9).
pub(all) struct CT_Connection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Connection::new(element : @xml.Element) -> CT_Connection {
  { element, }
}

///|
/// XSD complex type CT_Path2DMoveTo (§20.1.9).
pub(all) struct CT_Path2DMoveTo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DMoveTo::new(element : @xml.Element) -> CT_Path2DMoveTo {
  { element, }
}

///|
/// XSD complex type CT_Path2DLineTo (§20.1.9).
pub(all) struct CT_Path2DLineTo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DLineTo::new(element : @xml.Element) -> CT_Path2DLineTo {
  { element, }
}

///|
/// XSD complex type CT_Path2DArcTo (§20.1.9).
pub(all) struct CT_Path2DArcTo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DArcTo::new(element : @xml.Element) -> CT_Path2DArcTo {
  { element, }
}

///|
/// XSD complex type CT_Path2DQuadBezierTo (§20.1.9).
pub(all) struct CT_Path2DQuadBezierTo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DQuadBezierTo::new(
  element : @xml.Element,
) -> CT_Path2DQuadBezierTo {
  { element, }
}

///|
/// XSD complex type CT_Path2DCubicBezierTo (§20.1.9).
pub(all) struct CT_Path2DCubicBezierTo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DCubicBezierTo::new(
  element : @xml.Element,
) -> CT_Path2DCubicBezierTo {
  { element, }
}

///|
/// XSD complex type CT_Path2DClose (§20.1.9).
pub(all) struct CT_Path2DClose {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DClose::new(element : @xml.Element) -> CT_Path2DClose {
  { element, }
}

///|
/// XSD complex type CT_Path2D (§20.1.9).
pub(all) struct CT_Path2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2D::new(element : @xml.Element) -> CT_Path2D {
  { element, }
}

///|
/// XSD complex type CT_Path2DList (§20.1.9).
pub(all) struct CT_Path2DList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path2DList::new(element : @xml.Element) -> CT_Path2DList {
  { element, }
}

///|
/// XSD complex type CT_PresetGeometry2D (§20.1.9).
pub(all) struct CT_PresetGeometry2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetGeometry2D::new(element : @xml.Element) -> CT_PresetGeometry2D {
  { element, }
}

///|
/// XSD complex type CT_PresetTextShape (§20.1.9).
pub(all) struct CT_PresetTextShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetTextShape::new(element : @xml.Element) -> CT_PresetTextShape {
  { element, }
}

///|
/// XSD complex type CT_CustomGeometry2D (§20.1.9).
pub(all) struct CT_CustomGeometry2D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomGeometry2D::new(element : @xml.Element) -> CT_CustomGeometry2D {
  { element, }
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
