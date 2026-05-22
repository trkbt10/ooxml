///|
/// XSD simple type ST_Ext (§20.1.16): view, edit, backwardCompatible.
pub struct ST_Ext {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Ext::parse(s : String) -> ST_Ext raise SchemaViolation {
  validate_token("ST_Ext", s, ["view", "edit", "backwardCompatible"])
  { value: s }
}

///|
pub fn ST_Ext::new(s : String) -> ST_Ext raise SchemaViolation {
  ST_Ext::parse(s)
}

///|
pub fn ST_Ext::to_string(self : ST_Ext) -> String {
  self.value
}

///|
/// XSD simple type ST_FillType (§20.1.16): solid, gradient, gradientRadial, tile, pattern, frame, gradientCenter, gradientUnscaled, background.
pub struct ST_FillType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FillType::parse(s : String) -> ST_FillType raise SchemaViolation {
  validate_token("ST_FillType", s, [
    "solid", "gradient", "gradientRadial", "tile", "pattern", "frame", "gradientCenter",
    "gradientUnscaled", "background",
  ])
  { value: s }
}

///|
pub fn ST_FillType::new(s : String) -> ST_FillType raise SchemaViolation {
  ST_FillType::parse(s)
}

///|
pub fn ST_FillType::to_string(self : ST_FillType) -> String {
  self.value
}

///|
/// XSD simple type ST_FillMethod (§20.1.16): none, linear, sigma, any, linear sigma.
pub struct ST_FillMethod {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FillMethod::parse(s : String) -> ST_FillMethod raise SchemaViolation {
  validate_token("ST_FillMethod", s, [
    "none", "linear", "sigma", "any", "linear sigma",
  ])
  { value: s }
}

///|
pub fn ST_FillMethod::new(s : String) -> ST_FillMethod raise SchemaViolation {
  ST_FillMethod::parse(s)
}

///|
pub fn ST_FillMethod::to_string(self : ST_FillMethod) -> String {
  self.value
}

///|
/// XSD simple type ST_ShadowType (§20.1.16): single, double, emboss, perspective.
pub struct ST_ShadowType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ShadowType::parse(s : String) -> ST_ShadowType raise SchemaViolation {
  validate_token("ST_ShadowType", s, [
    "single", "double", "emboss", "perspective",
  ])
  { value: s }
}

///|
pub fn ST_ShadowType::new(s : String) -> ST_ShadowType raise SchemaViolation {
  ST_ShadowType::parse(s)
}

///|
pub fn ST_ShadowType::to_string(self : ST_ShadowType) -> String {
  self.value
}

///|
/// XSD simple type ST_StrokeLineStyle (§20.1.16): single, thinThin, thinThick, thickThin, thickBetweenThin.
pub struct ST_StrokeLineStyle {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_StrokeLineStyle::parse(
  s : String,
) -> ST_StrokeLineStyle raise SchemaViolation {
  validate_token("ST_StrokeLineStyle", s, [
    "single", "thinThin", "thinThick", "thickThin", "thickBetweenThin",
  ])
  { value: s }
}

///|
pub fn ST_StrokeLineStyle::new(
  s : String,
) -> ST_StrokeLineStyle raise SchemaViolation {
  ST_StrokeLineStyle::parse(s)
}

///|
pub fn ST_StrokeLineStyle::to_string(self : ST_StrokeLineStyle) -> String {
  self.value
}

///|
/// XSD simple type ST_StrokeJoinStyle (§20.1.16): round, bevel, miter.
pub struct ST_StrokeJoinStyle {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_StrokeJoinStyle::parse(
  s : String,
) -> ST_StrokeJoinStyle raise SchemaViolation {
  validate_token("ST_StrokeJoinStyle", s, ["round", "bevel", "miter"])
  { value: s }
}

///|
pub fn ST_StrokeJoinStyle::new(
  s : String,
) -> ST_StrokeJoinStyle raise SchemaViolation {
  ST_StrokeJoinStyle::parse(s)
}

///|
pub fn ST_StrokeJoinStyle::to_string(self : ST_StrokeJoinStyle) -> String {
  self.value
}

///|
/// XSD simple type ST_StrokeEndCap (§20.1.16): flat, square, round.
pub struct ST_StrokeEndCap {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_StrokeEndCap::parse(
  s : String,
) -> ST_StrokeEndCap raise SchemaViolation {
  validate_token("ST_StrokeEndCap", s, ["flat", "square", "round"])
  { value: s }
}

///|
pub fn ST_StrokeEndCap::new(
  s : String,
) -> ST_StrokeEndCap raise SchemaViolation {
  ST_StrokeEndCap::parse(s)
}

///|
pub fn ST_StrokeEndCap::to_string(self : ST_StrokeEndCap) -> String {
  self.value
}

///|
/// XSD simple type ST_StrokeArrowLength (§20.1.16): short, medium, long.
pub struct ST_StrokeArrowLength {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_StrokeArrowLength::parse(
  s : String,
) -> ST_StrokeArrowLength raise SchemaViolation {
  validate_token("ST_StrokeArrowLength", s, ["short", "medium", "long"])
  { value: s }
}

///|
pub fn ST_StrokeArrowLength::new(
  s : String,
) -> ST_StrokeArrowLength raise SchemaViolation {
  ST_StrokeArrowLength::parse(s)
}

///|
pub fn ST_StrokeArrowLength::to_string(self : ST_StrokeArrowLength) -> String {
  self.value
}

///|
/// XSD simple type ST_StrokeArrowWidth (§20.1.16): narrow, medium, wide.
pub struct ST_StrokeArrowWidth {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_StrokeArrowWidth::parse(
  s : String,
) -> ST_StrokeArrowWidth raise SchemaViolation {
  validate_token("ST_StrokeArrowWidth", s, ["narrow", "medium", "wide"])
  { value: s }
}

///|
pub fn ST_StrokeArrowWidth::new(
  s : String,
) -> ST_StrokeArrowWidth raise SchemaViolation {
  ST_StrokeArrowWidth::parse(s)
}

///|
pub fn ST_StrokeArrowWidth::to_string(self : ST_StrokeArrowWidth) -> String {
  self.value
}

///|
/// XSD simple type ST_StrokeArrowType (§20.1.16): none, block, classic, oval, diamond, open.
pub struct ST_StrokeArrowType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_StrokeArrowType::parse(
  s : String,
) -> ST_StrokeArrowType raise SchemaViolation {
  validate_token("ST_StrokeArrowType", s, [
    "none", "block", "classic", "oval", "diamond", "open",
  ])
  { value: s }
}

///|
pub fn ST_StrokeArrowType::new(
  s : String,
) -> ST_StrokeArrowType raise SchemaViolation {
  ST_StrokeArrowType::parse(s)
}

///|
pub fn ST_StrokeArrowType::to_string(self : ST_StrokeArrowType) -> String {
  self.value
}

///|
/// XSD simple type ST_ImageAspect (§20.1.16): ignore, atMost, atLeast.
pub struct ST_ImageAspect {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ImageAspect::parse(
  s : String,
) -> ST_ImageAspect raise SchemaViolation {
  validate_token("ST_ImageAspect", s, ["ignore", "atMost", "atLeast"])
  { value: s }
}

///|
pub fn ST_ImageAspect::new(s : String) -> ST_ImageAspect raise SchemaViolation {
  ST_ImageAspect::parse(s)
}

///|
pub fn ST_ImageAspect::to_string(self : ST_ImageAspect) -> String {
  self.value
}

///|
/// XSD simple type ST_EditAs (§20.1.16): canvas, orgchart, radial, cycle, stacked, venn, bullseye.
pub struct ST_EditAs {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_EditAs::parse(s : String) -> ST_EditAs raise SchemaViolation {
  validate_token("ST_EditAs", s, [
    "canvas", "orgchart", "radial", "cycle", "stacked", "venn", "bullseye",
  ])
  { value: s }
}

///|
pub fn ST_EditAs::new(s : String) -> ST_EditAs raise SchemaViolation {
  ST_EditAs::parse(s)
}

///|
pub fn ST_EditAs::to_string(self : ST_EditAs) -> String {
  self.value
}

///|
/// XSD simple type ST_AlternateMathContentType (§20.1.16).
pub struct ST_AlternateMathContentType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_AlternateMathContentType::parse(
  s : String,
) -> ST_AlternateMathContentType raise SchemaViolation {
  validate_token("ST_AlternateMathContentType", s, [])
  { value: s }
}

///|
pub fn ST_AlternateMathContentType::new(
  s : String,
) -> ST_AlternateMathContentType raise SchemaViolation {
  ST_AlternateMathContentType::parse(s)
}

///|
pub fn ST_AlternateMathContentType::to_string(
  self : ST_AlternateMathContentType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_RType (§20.1.16): arc, callout, connector, align.
pub struct ST_RType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RType::parse(s : String) -> ST_RType raise SchemaViolation {
  validate_token("ST_RType", s, ["arc", "callout", "connector", "align"])
  { value: s }
}

///|
pub fn ST_RType::new(s : String) -> ST_RType raise SchemaViolation {
  ST_RType::parse(s)
}

///|
pub fn ST_RType::to_string(self : ST_RType) -> String {
  self.value
}

///|
/// XSD simple type ST_How (§20.1.16): top, middle, bottom, left, center, right.
pub struct ST_How {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_How::parse(s : String) -> ST_How raise SchemaViolation {
  validate_token("ST_How", s, [
    "top", "middle", "bottom", "left", "center", "right",
  ])
  { value: s }
}

///|
pub fn ST_How::new(s : String) -> ST_How raise SchemaViolation {
  ST_How::parse(s)
}

///|
pub fn ST_How::to_string(self : ST_How) -> String {
  self.value
}

///|
/// XSD simple type ST_BWMode (§20.1.16): color, auto, grayScale, lightGrayscale, inverseGray, grayOutline, highContrast, black, white, hide, undrawn, blackTextAndLines.
pub struct ST_BWMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_BWMode::parse(s : String) -> ST_BWMode raise SchemaViolation {
  validate_token("ST_BWMode", s, [
    "color", "auto", "grayScale", "lightGrayscale", "inverseGray", "grayOutline",
    "highContrast", "black", "white", "hide", "undrawn", "blackTextAndLines",
  ])
  { value: s }
}

///|
pub fn ST_BWMode::new(s : String) -> ST_BWMode raise SchemaViolation {
  ST_BWMode::parse(s)
}

///|
pub fn ST_BWMode::to_string(self : ST_BWMode) -> String {
  self.value
}

///|
/// XSD simple type ST_ScreenSize (§20.1.16): 544,376, 640,480, 720,512, 800,600, 1024,768, 1152,862.
pub struct ST_ScreenSize {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ScreenSize::parse(s : String) -> ST_ScreenSize raise SchemaViolation {
  validate_token("ST_ScreenSize", s, [
    "544,376", "640,480", "720,512", "800,600", "1024,768", "1152,862",
  ])
  { value: s }
}

///|
pub fn ST_ScreenSize::new(s : String) -> ST_ScreenSize raise SchemaViolation {
  ST_ScreenSize::parse(s)
}

///|
pub fn ST_ScreenSize::to_string(self : ST_ScreenSize) -> String {
  self.value
}

///|
/// XSD simple type ST_InsetMode (§20.1.16): auto, custom.
pub struct ST_InsetMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_InsetMode::parse(s : String) -> ST_InsetMode raise SchemaViolation {
  validate_token("ST_InsetMode", s, ["auto", "custom"])
  { value: s }
}

///|
pub fn ST_InsetMode::new(s : String) -> ST_InsetMode raise SchemaViolation {
  ST_InsetMode::parse(s)
}

///|
pub fn ST_InsetMode::to_string(self : ST_InsetMode) -> String {
  self.value
}

///|
/// XSD simple type ST_ColorMode (§20.1.16): auto, custom.
pub struct ST_ColorMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ColorMode::parse(s : String) -> ST_ColorMode raise SchemaViolation {
  validate_token("ST_ColorMode", s, ["auto", "custom"])
  { value: s }
}

///|
pub fn ST_ColorMode::new(s : String) -> ST_ColorMode raise SchemaViolation {
  ST_ColorMode::parse(s)
}

///|
pub fn ST_ColorMode::to_string(self : ST_ColorMode) -> String {
  self.value
}

///|
/// XSD simple type ST_ContentType (§20.1.16).
pub struct ST_ContentType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ContentType::parse(
  s : String,
) -> ST_ContentType raise SchemaViolation {
  validate_token("ST_ContentType", s, [])
  { value: s }
}

///|
pub fn ST_ContentType::new(s : String) -> ST_ContentType raise SchemaViolation {
  ST_ContentType::parse(s)
}

///|
pub fn ST_ContentType::to_string(self : ST_ContentType) -> String {
  self.value
}

///|
/// XSD simple type ST_DiagramLayout (§20.1.16): 0, 1, 2, 3.
pub struct ST_DiagramLayout {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DiagramLayout::parse(
  s : String,
) -> ST_DiagramLayout raise SchemaViolation {
  validate_token("ST_DiagramLayout", s, ["0", "1", "2", "3"])
  { value: s }
}

///|
pub fn ST_DiagramLayout::new(
  s : String,
) -> ST_DiagramLayout raise SchemaViolation {
  ST_DiagramLayout::parse(s)
}

///|
pub fn ST_DiagramLayout::to_string(self : ST_DiagramLayout) -> String {
  self.value
}

///|
/// XSD simple type ST_ExtrusionType (§20.1.16): perspective, parallel.
pub struct ST_ExtrusionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ExtrusionType::parse(
  s : String,
) -> ST_ExtrusionType raise SchemaViolation {
  validate_token("ST_ExtrusionType", s, ["perspective", "parallel"])
  { value: s }
}

///|
pub fn ST_ExtrusionType::new(
  s : String,
) -> ST_ExtrusionType raise SchemaViolation {
  ST_ExtrusionType::parse(s)
}

///|
pub fn ST_ExtrusionType::to_string(self : ST_ExtrusionType) -> String {
  self.value
}

///|
/// XSD simple type ST_ExtrusionRender (§20.1.16): solid, wireFrame, boundingCube.
pub struct ST_ExtrusionRender {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ExtrusionRender::parse(
  s : String,
) -> ST_ExtrusionRender raise SchemaViolation {
  validate_token("ST_ExtrusionRender", s, ["solid", "wireFrame", "boundingCube"])
  { value: s }
}

///|
pub fn ST_ExtrusionRender::new(
  s : String,
) -> ST_ExtrusionRender raise SchemaViolation {
  ST_ExtrusionRender::parse(s)
}

///|
pub fn ST_ExtrusionRender::to_string(self : ST_ExtrusionRender) -> String {
  self.value
}

///|
/// XSD simple type ST_ExtrusionPlane (§20.1.16): XY, ZX, YZ.
pub struct ST_ExtrusionPlane {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ExtrusionPlane::parse(
  s : String,
) -> ST_ExtrusionPlane raise SchemaViolation {
  validate_token("ST_ExtrusionPlane", s, ["XY", "ZX", "YZ"])
  { value: s }
}

///|
pub fn ST_ExtrusionPlane::new(
  s : String,
) -> ST_ExtrusionPlane raise SchemaViolation {
  ST_ExtrusionPlane::parse(s)
}

///|
pub fn ST_ExtrusionPlane::to_string(self : ST_ExtrusionPlane) -> String {
  self.value
}

///|
/// XSD simple type ST_Angle (§20.1.16): any, 30, 45, 60, 90, auto.
pub struct ST_Angle {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Angle::parse(s : String) -> ST_Angle raise SchemaViolation {
  validate_token("ST_Angle", s, ["any", "30", "45", "60", "90", "auto"])
  { value: s }
}

///|
pub fn ST_Angle::new(s : String) -> ST_Angle raise SchemaViolation {
  ST_Angle::parse(s)
}

///|
pub fn ST_Angle::to_string(self : ST_Angle) -> String {
  self.value
}

///|
/// XSD simple type ST_CalloutDrop (§20.1.16).
pub struct ST_CalloutDrop {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CalloutDrop::parse(
  s : String,
) -> ST_CalloutDrop raise SchemaViolation {
  validate_token("ST_CalloutDrop", s, [])
  { value: s }
}

///|
pub fn ST_CalloutDrop::new(s : String) -> ST_CalloutDrop raise SchemaViolation {
  ST_CalloutDrop::parse(s)
}

///|
pub fn ST_CalloutDrop::to_string(self : ST_CalloutDrop) -> String {
  self.value
}

///|
/// XSD simple type ST_CalloutPlacement (§20.1.16): top, center, bottom, user.
pub struct ST_CalloutPlacement {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CalloutPlacement::parse(
  s : String,
) -> ST_CalloutPlacement raise SchemaViolation {
  validate_token("ST_CalloutPlacement", s, ["top", "center", "bottom", "user"])
  { value: s }
}

///|
pub fn ST_CalloutPlacement::new(
  s : String,
) -> ST_CalloutPlacement raise SchemaViolation {
  ST_CalloutPlacement::parse(s)
}

///|
pub fn ST_CalloutPlacement::to_string(self : ST_CalloutPlacement) -> String {
  self.value
}

///|
/// XSD simple type ST_ConnectorType (§20.1.16): none, straight, elbow, curved.
pub struct ST_ConnectorType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ConnectorType::parse(
  s : String,
) -> ST_ConnectorType raise SchemaViolation {
  validate_token("ST_ConnectorType", s, ["none", "straight", "elbow", "curved"])
  { value: s }
}

///|
pub fn ST_ConnectorType::new(
  s : String,
) -> ST_ConnectorType raise SchemaViolation {
  ST_ConnectorType::parse(s)
}

///|
pub fn ST_ConnectorType::to_string(self : ST_ConnectorType) -> String {
  self.value
}

///|
/// XSD simple type ST_HrAlign (§20.1.16): left, right, center.
pub struct ST_HrAlign {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HrAlign::parse(s : String) -> ST_HrAlign raise SchemaViolation {
  validate_token("ST_HrAlign", s, ["left", "right", "center"])
  { value: s }
}

///|
pub fn ST_HrAlign::new(s : String) -> ST_HrAlign raise SchemaViolation {
  ST_HrAlign::parse(s)
}

///|
pub fn ST_HrAlign::to_string(self : ST_HrAlign) -> String {
  self.value
}

///|
/// XSD simple type ST_ConnectType (§20.1.16): none, rect, segments, custom.
pub struct ST_ConnectType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ConnectType::parse(
  s : String,
) -> ST_ConnectType raise SchemaViolation {
  validate_token("ST_ConnectType", s, ["none", "rect", "segments", "custom"])
  { value: s }
}

///|
pub fn ST_ConnectType::new(s : String) -> ST_ConnectType raise SchemaViolation {
  ST_ConnectType::parse(s)
}

///|
pub fn ST_ConnectType::to_string(self : ST_ConnectType) -> String {
  self.value
}

///|
/// XSD simple type ST_OLELinkType (§20.1.16).
pub struct ST_OLELinkType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_OLELinkType::parse(
  s : String,
) -> ST_OLELinkType raise SchemaViolation {
  validate_token("ST_OLELinkType", s, [])
  { value: s }
}

///|
pub fn ST_OLELinkType::new(s : String) -> ST_OLELinkType raise SchemaViolation {
  ST_OLELinkType::parse(s)
}

///|
pub fn ST_OLELinkType::to_string(self : ST_OLELinkType) -> String {
  self.value
}

///|
/// XSD simple type ST_OLEType (§20.1.16): Embed, Link.
pub struct ST_OLEType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_OLEType::parse(s : String) -> ST_OLEType raise SchemaViolation {
  validate_token("ST_OLEType", s, ["Embed", "Link"])
  { value: s }
}

///|
pub fn ST_OLEType::new(s : String) -> ST_OLEType raise SchemaViolation {
  ST_OLEType::parse(s)
}

///|
pub fn ST_OLEType::to_string(self : ST_OLEType) -> String {
  self.value
}

///|
/// XSD simple type ST_OLEDrawAspect (§20.1.16): Content, Icon.
pub struct ST_OLEDrawAspect {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_OLEDrawAspect::parse(
  s : String,
) -> ST_OLEDrawAspect raise SchemaViolation {
  validate_token("ST_OLEDrawAspect", s, ["Content", "Icon"])
  { value: s }
}

///|
pub fn ST_OLEDrawAspect::new(
  s : String,
) -> ST_OLEDrawAspect raise SchemaViolation {
  ST_OLEDrawAspect::parse(s)
}

///|
pub fn ST_OLEDrawAspect::to_string(self : ST_OLEDrawAspect) -> String {
  self.value
}

///|
/// XSD simple type ST_OLEUpdateMode (§20.1.16): Always, OnCall.
pub struct ST_OLEUpdateMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_OLEUpdateMode::parse(
  s : String,
) -> ST_OLEUpdateMode raise SchemaViolation {
  validate_token("ST_OLEUpdateMode", s, ["Always", "OnCall"])
  { value: s }
}

///|
pub fn ST_OLEUpdateMode::new(
  s : String,
) -> ST_OLEUpdateMode raise SchemaViolation {
  ST_OLEUpdateMode::parse(s)
}

///|
pub fn ST_OLEUpdateMode::to_string(self : ST_OLEUpdateMode) -> String {
  self.value
}

///|
/// XSD simple type ST_BorderType from vml-wordprocessingDrawing.xsd
/// (Part 4 §14.3.2.6 wrap parent border).  Enumeration values:
/// none, single, thick, double, hairline, dot, dash, dotDash,
/// dashDotDot, triple, thinThickSmall, thickThinSmall,
/// thickBetweenThinSmall, thinThick, thickThin, thickBetweenThin,
/// thinThickLarge, thickThinLarge, thickBetweenThinLarge, wave,
/// doubleWave, dashedSmall, dashDotStroked, threeDEmboss, threeDEngrave,
/// HTMLOutset, HTMLInset.
pub struct ST_BorderType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_BorderType::parse(s : String) -> ST_BorderType raise SchemaViolation {
  validate_token("ST_BorderType", s, [
    "none", "single", "thick", "double", "hairline", "dot", "dash", "dotDash", "dashDotDot",
    "triple", "thinThickSmall", "thickThinSmall", "thickBetweenThinSmall", "thinThick",
    "thickThin", "thickBetweenThin", "thinThickLarge", "thickThinLarge", "thickBetweenThinLarge",
    "wave", "doubleWave", "dashedSmall", "dashDotStroked", "threeDEmboss", "threeDEngrave",
    "HTMLOutset", "HTMLInset",
  ])
  { value: s }
}

///|
pub fn ST_BorderType::new(s : String) -> ST_BorderType raise SchemaViolation {
  ST_BorderType::parse(s)
}

///|
pub fn ST_BorderType::to_string(self : ST_BorderType) -> String {
  self.value
}

///|
/// XSD simple type ST_BorderShadow from vml-wordprocessingDrawing.xsd
/// (Part 4 §14.3.2.6 wrap parent border shadow).  Enumeration values:
/// t, true, f, false.
pub struct ST_BorderShadow {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_BorderShadow::parse(
  s : String,
) -> ST_BorderShadow raise SchemaViolation {
  validate_token("ST_BorderShadow", s, ["t", "true", "f", "false"])
  { value: s }
}

///|
pub fn ST_BorderShadow::new(
  s : String,
) -> ST_BorderShadow raise SchemaViolation {
  ST_BorderShadow::parse(s)
}

///|
pub fn ST_BorderShadow::to_string(self : ST_BorderShadow) -> String {
  self.value
}
