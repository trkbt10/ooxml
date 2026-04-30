///|
pub struct ST_Coordinate {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Coordinate::parse(s : String) -> ST_Coordinate raise SchemaViolation {
  validate_measure("ST_Coordinate", s)
  { value: s }
}

///|
pub fn ST_Coordinate::new(s : String) -> ST_Coordinate raise SchemaViolation {
  ST_Coordinate::parse(s)
}

///|
pub fn ST_Coordinate::to_string(self : ST_Coordinate) -> String {
  self.value
}

///|
pub struct ST_CoordinateUnqualified {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CoordinateUnqualified::parse(
  s : String,
) -> ST_CoordinateUnqualified raise SchemaViolation {
  validate_int_token("ST_CoordinateUnqualified", s)
  { value: s }
}

///|
pub fn ST_CoordinateUnqualified::new(
  s : String,
) -> ST_CoordinateUnqualified raise SchemaViolation {
  ST_CoordinateUnqualified::parse(s)
}

///|
pub fn ST_CoordinateUnqualified::to_string(
  self : ST_CoordinateUnqualified,
) -> String {
  self.value
}

///|
pub struct ST_Coordinate32 {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Coordinate32::parse(
  s : String,
) -> ST_Coordinate32 raise SchemaViolation {
  validate_measure("ST_Coordinate32", s)
  { value: s }
}

///|
pub fn ST_Coordinate32::new(
  s : String,
) -> ST_Coordinate32 raise SchemaViolation {
  ST_Coordinate32::parse(s)
}

///|
pub fn ST_Coordinate32::to_string(self : ST_Coordinate32) -> String {
  self.value
}

///|
pub struct ST_Coordinate32Unqualified {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Coordinate32Unqualified::parse(
  s : String,
) -> ST_Coordinate32Unqualified raise SchemaViolation {
  validate_int_token("ST_Coordinate32Unqualified", s)
  { value: s }
}

///|
pub fn ST_Coordinate32Unqualified::new(
  s : String,
) -> ST_Coordinate32Unqualified raise SchemaViolation {
  ST_Coordinate32Unqualified::parse(s)
}

///|
pub fn ST_Coordinate32Unqualified::to_string(
  self : ST_Coordinate32Unqualified,
) -> String {
  self.value
}

///|
pub struct ST_PositiveCoordinate {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PositiveCoordinate::parse(
  s : String,
) -> ST_PositiveCoordinate raise SchemaViolation {
  validate_non_negative_measure("ST_PositiveCoordinate", s)
  { value: s }
}

///|
pub fn ST_PositiveCoordinate::new(
  s : String,
) -> ST_PositiveCoordinate raise SchemaViolation {
  ST_PositiveCoordinate::parse(s)
}

///|
pub fn ST_PositiveCoordinate::to_string(self : ST_PositiveCoordinate) -> String {
  self.value
}

///|
pub struct ST_PositiveCoordinate32 {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PositiveCoordinate32::parse(
  s : String,
) -> ST_PositiveCoordinate32 raise SchemaViolation {
  validate_non_negative_measure("ST_PositiveCoordinate32", s)
  { value: s }
}

///|
pub fn ST_PositiveCoordinate32::new(
  s : String,
) -> ST_PositiveCoordinate32 raise SchemaViolation {
  ST_PositiveCoordinate32::parse(s)
}

///|
pub fn ST_PositiveCoordinate32::to_string(
  self : ST_PositiveCoordinate32,
) -> String {
  self.value
}

///|
pub struct ST_Angle {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Angle::parse(s : String) -> ST_Angle raise SchemaViolation {
  validate_int_token("ST_Angle", s)
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
pub struct ST_FixedAngle {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FixedAngle::parse(s : String) -> ST_FixedAngle raise SchemaViolation {
  validate_int_token("ST_FixedAngle", s)
  { value: s }
}

///|
pub fn ST_FixedAngle::new(s : String) -> ST_FixedAngle raise SchemaViolation {
  ST_FixedAngle::parse(s)
}

///|
pub fn ST_FixedAngle::to_string(self : ST_FixedAngle) -> String {
  self.value
}

///|
pub struct ST_PositiveFixedAngle {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PositiveFixedAngle::parse(
  s : String,
) -> ST_PositiveFixedAngle raise SchemaViolation {
  validate_non_negative_int("ST_PositiveFixedAngle", s)
  { value: s }
}

///|
pub fn ST_PositiveFixedAngle::new(
  s : String,
) -> ST_PositiveFixedAngle raise SchemaViolation {
  ST_PositiveFixedAngle::parse(s)
}

///|
pub fn ST_PositiveFixedAngle::to_string(self : ST_PositiveFixedAngle) -> String {
  self.value
}

///|
pub struct ST_Percentage {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Percentage::parse(s : String) -> ST_Percentage raise SchemaViolation {
  validate_measure("ST_Percentage", s)
  { value: s }
}

///|
pub fn ST_Percentage::new(s : String) -> ST_Percentage raise SchemaViolation {
  ST_Percentage::parse(s)
}

///|
pub fn ST_Percentage::to_string(self : ST_Percentage) -> String {
  self.value
}

///|
pub struct ST_PositivePercentage {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PositivePercentage::parse(
  s : String,
) -> ST_PositivePercentage raise SchemaViolation {
  validate_non_negative_measure("ST_PositivePercentage", s)
  { value: s }
}

///|
pub fn ST_PositivePercentage::new(
  s : String,
) -> ST_PositivePercentage raise SchemaViolation {
  ST_PositivePercentage::parse(s)
}

///|
pub fn ST_PositivePercentage::to_string(self : ST_PositivePercentage) -> String {
  self.value
}

///|
pub struct ST_FixedPercentage {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FixedPercentage::parse(
  s : String,
) -> ST_FixedPercentage raise SchemaViolation {
  validate_measure("ST_FixedPercentage", s)
  { value: s }
}

///|
pub fn ST_FixedPercentage::new(
  s : String,
) -> ST_FixedPercentage raise SchemaViolation {
  ST_FixedPercentage::parse(s)
}

///|
pub fn ST_FixedPercentage::to_string(self : ST_FixedPercentage) -> String {
  self.value
}

///|
pub struct ST_PositiveFixedPercentage {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PositiveFixedPercentage::parse(
  s : String,
) -> ST_PositiveFixedPercentage raise SchemaViolation {
  validate_non_negative_measure("ST_PositiveFixedPercentage", s)
  { value: s }
}

///|
pub fn ST_PositiveFixedPercentage::new(
  s : String,
) -> ST_PositiveFixedPercentage raise SchemaViolation {
  ST_PositiveFixedPercentage::parse(s)
}

///|
pub fn ST_PositiveFixedPercentage::to_string(
  self : ST_PositiveFixedPercentage,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextFontScalePercentOrPercentString (§20.1.10).
pub struct ST_TextFontScalePercentOrPercentString {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextFontScalePercentOrPercentString::parse(
  s : String,
) -> ST_TextFontScalePercentOrPercentString raise SchemaViolation {
  validate_non_empty_token("ST_TextFontScalePercentOrPercentString", s)
  { value: s }
}

///|
pub fn ST_TextFontScalePercentOrPercentString::new(
  s : String,
) -> ST_TextFontScalePercentOrPercentString raise SchemaViolation {
  ST_TextFontScalePercentOrPercentString::parse(s)
}

///|
pub fn ST_TextFontScalePercentOrPercentString::to_string(
  self : ST_TextFontScalePercentOrPercentString,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextFontSize (§20.1.10).
pub struct ST_TextFontSize {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextFontSize::parse(
  s : String,
) -> ST_TextFontSize raise SchemaViolation {
  validate_int_token("ST_TextFontSize", s)
  { value: s }
}

///|
pub fn ST_TextFontSize::new(
  s : String,
) -> ST_TextFontSize raise SchemaViolation {
  ST_TextFontSize::parse(s)
}

///|
pub fn ST_TextFontSize::to_string(self : ST_TextFontSize) -> String {
  self.value
}

///|
/// XSD simple type ST_TextTypeface (§20.1.4).
pub struct ST_TextTypeface {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextTypeface::parse(
  s : String,
) -> ST_TextTypeface raise SchemaViolation {
  validate_non_empty_token("ST_TextTypeface", s)
  { value: s }
}

///|
pub fn ST_TextTypeface::new(
  s : String,
) -> ST_TextTypeface raise SchemaViolation {
  ST_TextTypeface::parse(s)
}

///|
pub fn ST_TextTypeface::to_string(self : ST_TextTypeface) -> String {
  self.value
}

///|
/// XSD simple type ST_PitchFamily (§20.1.4).
pub struct ST_PitchFamily {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PitchFamily::parse(
  s : String,
) -> ST_PitchFamily raise SchemaViolation {
  validate_main_enum("ST_PitchFamily", s, [
    "00", "01", "02", "16", "17", "18", "32", "33", "34", "48", "49", "50", "64",
    "65", "66", "80", "81", "82",
  ])
  { value: s }
}

///|
pub fn ST_PitchFamily::new(s : String) -> ST_PitchFamily raise SchemaViolation {
  ST_PitchFamily::parse(s)
}

///|
pub fn ST_PitchFamily::to_string(self : ST_PitchFamily) -> String {
  self.value
}

///|
/// XSD simple type ST_TextFontAlignType (§20.1.10).
pub struct ST_TextFontAlignType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextFontAlignType::parse(
  s : String,
) -> ST_TextFontAlignType raise SchemaViolation {
  validate_main_enum("ST_TextFontAlignType", s, [
    "auto", "t", "ctr", "base", "b",
  ])
  { value: s }
}

///|
pub fn ST_TextFontAlignType::new(
  s : String,
) -> ST_TextFontAlignType raise SchemaViolation {
  ST_TextFontAlignType::parse(s)
}

///|
pub fn ST_TextFontAlignType::to_string(self : ST_TextFontAlignType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextShapeType (§20.1.10).
pub struct ST_TextShapeType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextShapeType::parse(
  s : String,
) -> ST_TextShapeType raise SchemaViolation {
  validate_main_enum("ST_TextShapeType", s, text_shape_type_values())
  { value: s }
}

///|
pub fn ST_TextShapeType::new(
  s : String,
) -> ST_TextShapeType raise SchemaViolation {
  ST_TextShapeType::parse(s)
}

///|
pub fn ST_TextShapeType::to_string(self : ST_TextShapeType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextAnchoringType (§20.1.10).
pub struct ST_TextAnchoringType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextAnchoringType::parse(
  s : String,
) -> ST_TextAnchoringType raise SchemaViolation {
  validate_main_enum("ST_TextAnchoringType", s, [
    "t", "ctr", "b", "just", "dist",
  ])
  { value: s }
}

///|
pub fn ST_TextAnchoringType::new(
  s : String,
) -> ST_TextAnchoringType raise SchemaViolation {
  ST_TextAnchoringType::parse(s)
}

///|
pub fn ST_TextAnchoringType::to_string(self : ST_TextAnchoringType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextVertOverflowType (§20.1.10).
pub struct ST_TextVertOverflowType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextVertOverflowType::parse(
  s : String,
) -> ST_TextVertOverflowType raise SchemaViolation {
  validate_main_enum("ST_TextVertOverflowType", s, [
    "overflow", "ellipsis", "clip",
  ])
  { value: s }
}

///|
pub fn ST_TextVertOverflowType::new(
  s : String,
) -> ST_TextVertOverflowType raise SchemaViolation {
  ST_TextVertOverflowType::parse(s)
}

///|
pub fn ST_TextVertOverflowType::to_string(
  self : ST_TextVertOverflowType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextHorzOverflowType (§20.1.10).
pub struct ST_TextHorzOverflowType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextHorzOverflowType::parse(
  s : String,
) -> ST_TextHorzOverflowType raise SchemaViolation {
  validate_main_enum("ST_TextHorzOverflowType", s, ["overflow", "clip"])
  { value: s }
}

///|
pub fn ST_TextHorzOverflowType::new(
  s : String,
) -> ST_TextHorzOverflowType raise SchemaViolation {
  ST_TextHorzOverflowType::parse(s)
}

///|
pub fn ST_TextHorzOverflowType::to_string(
  self : ST_TextHorzOverflowType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextVerticalType (§20.1.10).
pub struct ST_TextVerticalType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextVerticalType::parse(
  s : String,
) -> ST_TextVerticalType raise SchemaViolation {
  validate_main_enum("ST_TextVerticalType", s, [
    "horz", "vert", "vert270", "wordArtVert", "eaVert", "mongolianVert", "wordArtVertRtl",
  ])
  { value: s }
}

///|
pub fn ST_TextVerticalType::new(
  s : String,
) -> ST_TextVerticalType raise SchemaViolation {
  ST_TextVerticalType::parse(s)
}

///|
pub fn ST_TextVerticalType::to_string(self : ST_TextVerticalType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextWrappingType (§20.1.10).
pub struct ST_TextWrappingType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextWrappingType::parse(
  s : String,
) -> ST_TextWrappingType raise SchemaViolation {
  validate_main_enum("ST_TextWrappingType", s, ["none", "square"])
  { value: s }
}

///|
pub fn ST_TextWrappingType::new(
  s : String,
) -> ST_TextWrappingType raise SchemaViolation {
  ST_TextWrappingType::parse(s)
}

///|
pub fn ST_TextWrappingType::to_string(self : ST_TextWrappingType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextColumnCount (§20.1.10).
pub struct ST_TextColumnCount {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextColumnCount::parse(
  s : String,
) -> ST_TextColumnCount raise SchemaViolation {
  validate_non_negative_int("ST_TextColumnCount", s)
  { value: s }
}

///|
pub fn ST_TextColumnCount::new(
  s : String,
) -> ST_TextColumnCount raise SchemaViolation {
  ST_TextColumnCount::parse(s)
}

///|
pub fn ST_TextColumnCount::to_string(self : ST_TextColumnCount) -> String {
  self.value
}

///|
/// XSD simple type ST_TextBulletStartAtNum (§20.1.10).
pub struct ST_TextBulletStartAtNum {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextBulletStartAtNum::parse(
  s : String,
) -> ST_TextBulletStartAtNum raise SchemaViolation {
  validate_non_negative_int("ST_TextBulletStartAtNum", s)
  { value: s }
}

///|
pub fn ST_TextBulletStartAtNum::new(
  s : String,
) -> ST_TextBulletStartAtNum raise SchemaViolation {
  ST_TextBulletStartAtNum::parse(s)
}

///|
pub fn ST_TextBulletStartAtNum::to_string(
  self : ST_TextBulletStartAtNum,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextAutonumberScheme (§20.1.10).
pub struct ST_TextAutonumberScheme {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextAutonumberScheme::parse(
  s : String,
) -> ST_TextAutonumberScheme raise SchemaViolation {
  validate_main_enum("ST_TextAutonumberScheme", s, text_autonumber_values())
  { value: s }
}

///|
pub fn ST_TextAutonumberScheme::new(
  s : String,
) -> ST_TextAutonumberScheme raise SchemaViolation {
  ST_TextAutonumberScheme::parse(s)
}

///|
pub fn ST_TextAutonumberScheme::to_string(
  self : ST_TextAutonumberScheme,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextBulletSize (§20.1.10).
pub struct ST_TextBulletSize {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextBulletSize::parse(
  s : String,
) -> ST_TextBulletSize raise SchemaViolation {
  validate_measure("ST_TextBulletSize", s)
  { value: s }
}

///|
pub fn ST_TextBulletSize::new(
  s : String,
) -> ST_TextBulletSize raise SchemaViolation {
  ST_TextBulletSize::parse(s)
}

///|
pub fn ST_TextBulletSize::to_string(self : ST_TextBulletSize) -> String {
  self.value
}

///|
/// XSD simple type ST_TextBulletSizePercent (§20.1.10).
pub struct ST_TextBulletSizePercent {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextBulletSizePercent::parse(
  s : String,
) -> ST_TextBulletSizePercent raise SchemaViolation {
  validate_measure("ST_TextBulletSizePercent", s)
  { value: s }
}

///|
pub fn ST_TextBulletSizePercent::new(
  s : String,
) -> ST_TextBulletSizePercent raise SchemaViolation {
  ST_TextBulletSizePercent::parse(s)
}

///|
pub fn ST_TextBulletSizePercent::to_string(
  self : ST_TextBulletSizePercent,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextPoint (§20.1.10).
pub struct ST_TextPoint {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextPoint::parse(s : String) -> ST_TextPoint raise SchemaViolation {
  validate_measure("ST_TextPoint", s)
  { value: s }
}

///|
pub fn ST_TextPoint::new(s : String) -> ST_TextPoint raise SchemaViolation {
  ST_TextPoint::parse(s)
}

///|
pub fn ST_TextPoint::to_string(self : ST_TextPoint) -> String {
  self.value
}

///|
/// XSD simple type ST_TextPointUnqualified (§20.1.10).
pub struct ST_TextPointUnqualified {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextPointUnqualified::parse(
  s : String,
) -> ST_TextPointUnqualified raise SchemaViolation {
  validate_int_token("ST_TextPointUnqualified", s)
  { value: s }
}

///|
pub fn ST_TextPointUnqualified::new(
  s : String,
) -> ST_TextPointUnqualified raise SchemaViolation {
  ST_TextPointUnqualified::parse(s)
}

///|
pub fn ST_TextPointUnqualified::to_string(
  self : ST_TextPointUnqualified,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextNonNegativePoint (§20.1.10).
pub struct ST_TextNonNegativePoint {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextNonNegativePoint::parse(
  s : String,
) -> ST_TextNonNegativePoint raise SchemaViolation {
  validate_non_negative_int("ST_TextNonNegativePoint", s)
  { value: s }
}

///|
pub fn ST_TextNonNegativePoint::new(
  s : String,
) -> ST_TextNonNegativePoint raise SchemaViolation {
  ST_TextNonNegativePoint::parse(s)
}

///|
pub fn ST_TextNonNegativePoint::to_string(
  self : ST_TextNonNegativePoint,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextUnderlineType (§20.1.10).
pub struct ST_TextUnderlineType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextUnderlineType::parse(
  s : String,
) -> ST_TextUnderlineType raise SchemaViolation {
  validate_main_enum("ST_TextUnderlineType", s, [
    "none", "words", "sng", "dbl", "heavy", "dotted", "dottedHeavy", "dash", "dashHeavy",
    "dashLong", "dashLongHeavy", "dotDash", "dotDashHeavy", "dotDotDash", "dotDotDashHeavy",
    "wavy", "wavyHeavy", "wavyDbl",
  ])
  { value: s }
}

///|
pub fn ST_TextUnderlineType::new(
  s : String,
) -> ST_TextUnderlineType raise SchemaViolation {
  ST_TextUnderlineType::parse(s)
}

///|
pub fn ST_TextUnderlineType::to_string(self : ST_TextUnderlineType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextStrikeType (§20.1.10).
pub struct ST_TextStrikeType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextStrikeType::parse(
  s : String,
) -> ST_TextStrikeType raise SchemaViolation {
  validate_main_enum("ST_TextStrikeType", s, [
    "noStrike", "sngStrike", "dblStrike",
  ])
  { value: s }
}

///|
pub fn ST_TextStrikeType::new(
  s : String,
) -> ST_TextStrikeType raise SchemaViolation {
  ST_TextStrikeType::parse(s)
}

///|
pub fn ST_TextStrikeType::to_string(self : ST_TextStrikeType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextCapsType (§20.1.10).
pub struct ST_TextCapsType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextCapsType::parse(
  s : String,
) -> ST_TextCapsType raise SchemaViolation {
  validate_main_enum("ST_TextCapsType", s, ["none", "small", "all"])
  { value: s }
}

///|
pub fn ST_TextCapsType::new(
  s : String,
) -> ST_TextCapsType raise SchemaViolation {
  ST_TextCapsType::parse(s)
}

///|
pub fn ST_TextCapsType::to_string(self : ST_TextCapsType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextSpacingPoint (§20.1.10).
pub struct ST_TextSpacingPoint {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextSpacingPoint::parse(
  s : String,
) -> ST_TextSpacingPoint raise SchemaViolation {
  validate_int_token("ST_TextSpacingPoint", s)
  { value: s }
}

///|
pub fn ST_TextSpacingPoint::new(
  s : String,
) -> ST_TextSpacingPoint raise SchemaViolation {
  ST_TextSpacingPoint::parse(s)
}

///|
pub fn ST_TextSpacingPoint::to_string(self : ST_TextSpacingPoint) -> String {
  self.value
}

///|
/// XSD simple type ST_TextSpacingPercentOrPercentString (§20.1.10).
pub struct ST_TextSpacingPercentOrPercentString {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextSpacingPercentOrPercentString::parse(
  s : String,
) -> ST_TextSpacingPercentOrPercentString raise SchemaViolation {
  validate_measure("ST_TextSpacingPercentOrPercentString", s)
  { value: s }
}

///|
pub fn ST_TextSpacingPercentOrPercentString::new(
  s : String,
) -> ST_TextSpacingPercentOrPercentString raise SchemaViolation {
  ST_TextSpacingPercentOrPercentString::parse(s)
}

///|
pub fn ST_TextSpacingPercentOrPercentString::to_string(
  self : ST_TextSpacingPercentOrPercentString,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TextMargin (§20.1.10).
pub struct ST_TextMargin {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextMargin::parse(s : String) -> ST_TextMargin raise SchemaViolation {
  validate_int_token("ST_TextMargin", s)
  { value: s }
}

///|
pub fn ST_TextMargin::new(s : String) -> ST_TextMargin raise SchemaViolation {
  ST_TextMargin::parse(s)
}

///|
pub fn ST_TextMargin::to_string(self : ST_TextMargin) -> String {
  self.value
}

///|
/// XSD simple type ST_TextIndent (§20.1.10).
pub struct ST_TextIndent {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextIndent::parse(s : String) -> ST_TextIndent raise SchemaViolation {
  validate_int_token("ST_TextIndent", s)
  { value: s }
}

///|
pub fn ST_TextIndent::new(s : String) -> ST_TextIndent raise SchemaViolation {
  ST_TextIndent::parse(s)
}

///|
pub fn ST_TextIndent::to_string(self : ST_TextIndent) -> String {
  self.value
}

///|
/// XSD simple type ST_TextTabAlignType (§20.1.10).
pub struct ST_TextTabAlignType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextTabAlignType::parse(
  s : String,
) -> ST_TextTabAlignType raise SchemaViolation {
  validate_main_enum("ST_TextTabAlignType", s, ["l", "ctr", "r", "dec"])
  { value: s }
}

///|
pub fn ST_TextTabAlignType::new(
  s : String,
) -> ST_TextTabAlignType raise SchemaViolation {
  ST_TextTabAlignType::parse(s)
}

///|
pub fn ST_TextTabAlignType::to_string(self : ST_TextTabAlignType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextAlignType (§20.1.10).
pub struct ST_TextAlignType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextAlignType::parse(
  s : String,
) -> ST_TextAlignType raise SchemaViolation {
  validate_main_enum("ST_TextAlignType", s, [
    "l", "ctr", "r", "just", "justLow", "dist", "thaiDist",
  ])
  { value: s }
}

///|
pub fn ST_TextAlignType::new(
  s : String,
) -> ST_TextAlignType raise SchemaViolation {
  ST_TextAlignType::parse(s)
}

///|
pub fn ST_TextAlignType::to_string(self : ST_TextAlignType) -> String {
  self.value
}

///|
/// XSD simple type ST_TextIndentLevelType (§20.1.10).
pub struct ST_TextIndentLevelType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextIndentLevelType::parse(
  s : String,
) -> ST_TextIndentLevelType raise SchemaViolation {
  validate_non_negative_int("ST_TextIndentLevelType", s)
  { value: s }
}

///|
pub fn ST_TextIndentLevelType::new(
  s : String,
) -> ST_TextIndentLevelType raise SchemaViolation {
  ST_TextIndentLevelType::parse(s)
}

///|
pub fn ST_TextIndentLevelType::to_string(
  self : ST_TextIndentLevelType,
) -> String {
  self.value
}

///|
pub struct ST_RectAlignment {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RectAlignment::parse(
  s : String,
) -> ST_RectAlignment raise SchemaViolation {
  validate_main_enum("ST_RectAlignment", s, [
    "tl", "t", "tr", "l", "ctr", "r", "bl", "b", "br",
  ])
  { value: s }
}

///|
pub fn ST_RectAlignment::new(
  s : String,
) -> ST_RectAlignment raise SchemaViolation {
  ST_RectAlignment::parse(s)
}

///|
pub fn ST_RectAlignment::to_string(self : ST_RectAlignment) -> String {
  self.value
}

///|
pub struct ST_PathShadeType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PathShadeType::parse(
  s : String,
) -> ST_PathShadeType raise SchemaViolation {
  validate_main_enum("ST_PathShadeType", s, ["shape", "circle", "rect"])
  { value: s }
}

///|
pub fn ST_PathShadeType::new(
  s : String,
) -> ST_PathShadeType raise SchemaViolation {
  ST_PathShadeType::parse(s)
}

///|
pub fn ST_PathShadeType::to_string(self : ST_PathShadeType) -> String {
  self.value
}

///|
pub struct ST_TileFlipMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TileFlipMode::parse(
  s : String,
) -> ST_TileFlipMode raise SchemaViolation {
  validate_main_enum("ST_TileFlipMode", s, ["none", "x", "y", "xy"])
  { value: s }
}

///|
pub fn ST_TileFlipMode::new(
  s : String,
) -> ST_TileFlipMode raise SchemaViolation {
  ST_TileFlipMode::parse(s)
}

///|
pub fn ST_TileFlipMode::to_string(self : ST_TileFlipMode) -> String {
  self.value
}

///|
pub struct ST_PresetPatternVal {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PresetPatternVal::parse(
  s : String,
) -> ST_PresetPatternVal raise SchemaViolation {
  validate_main_enum("ST_PresetPatternVal", s, preset_pattern_values())
  { value: s }
}

///|
pub fn ST_PresetPatternVal::new(
  s : String,
) -> ST_PresetPatternVal raise SchemaViolation {
  ST_PresetPatternVal::parse(s)
}

///|
pub fn ST_PresetPatternVal::to_string(self : ST_PresetPatternVal) -> String {
  self.value
}

///|
fn preset_pattern_values() -> Array[String] {
  [
    "pct5", "pct10", "pct20", "pct25", "pct30", "pct40", "pct50", "pct60", "pct70",
    "pct75", "pct80", "pct90", "horz", "vert", "ltHorz", "ltVert", "dkHorz", "dkVert",
    "narHorz", "narVert", "dashHorz", "dashVert", "cross", "dnDiag", "upDiag", "ltDnDiag",
    "ltUpDiag", "dkDnDiag", "dkUpDiag", "wdDnDiag", "wdUpDiag", "dashDnDiag", "dashUpDiag",
    "diagCross", "smCheck", "lgCheck", "smGrid", "lgGrid", "dotGrid", "smConfetti",
    "lgConfetti", "horzBrick", "diagBrick", "solidDmnd", "openDmnd", "dotDmnd", "plaid",
    "sphere", "weave", "divot", "shingle", "wave", "trellis", "zigZag",
  ]
}

///|
fn text_shape_type_values() -> Array[String] {
  [
    "textNoShape", "textPlain", "textStop", "textTriangle", "textTriangleInverted",
    "textChevron", "textChevronInverted", "textRingInside", "textRingOutside", "textArchUp",
    "textArchDown", "textCircle", "textButton", "textArchUpPour", "textArchDownPour",
    "textCirclePour", "textButtonPour", "textCurveUp", "textCurveDown", "textCanUp",
    "textCanDown", "textWave1", "textWave2", "textDoubleWave1", "textWave4", "textInflate",
    "textDeflate", "textInflateBottom", "textDeflateBottom", "textInflateTop", "textDeflateTop",
    "textDeflateInflate", "textDeflateInflateDeflate", "textFadeRight", "textFadeLeft",
    "textFadeUp", "textFadeDown", "textSlantUp", "textSlantDown", "textCascadeUp",
    "textCascadeDown",
  ]
}

///|
fn text_autonumber_values() -> Array[String] {
  [
    "alphaLcParenBoth", "alphaUcParenBoth", "alphaLcParenR", "alphaUcParenR", "alphaLcPeriod",
    "alphaUcPeriod", "arabicParenBoth", "arabicParenR", "arabicPeriod", "arabicPlain",
    "romanLcParenBoth", "romanUcParenBoth", "romanLcParenR", "romanUcParenR", "romanLcPeriod",
    "romanUcPeriod", "circleNumDbPlain", "circleNumWdBlackPlain", "circleNumWdWhitePlain",
    "arabicDbPeriod", "arabicDbPlain", "ea1ChsPeriod", "ea1ChsPlain", "ea1ChtPeriod",
    "ea1ChtPlain", "ea1JpnChsDbPeriod", "ea1JpnKorPlain", "ea1JpnKorPeriod", "arabic1Minus",
    "arabic2Minus", "hebrew2Minus", "thaiAlphaPeriod", "thaiAlphaParenR", "thaiAlphaParenBoth",
    "thaiNumPeriod", "thaiNumParenR", "thaiNumParenBoth", "hindiAlphaPeriod", "hindiNumPeriod",
    "hindiNumParenR", "hindiAlpha1Period",
  ]
}

///|
pub struct ST_LineCap {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_LineCap::parse(s : String) -> ST_LineCap raise SchemaViolation {
  validate_main_enum("ST_LineCap", s, ["rnd", "sq", "flat"])
  { value: s }
}

///|
pub fn ST_LineCap::new(s : String) -> ST_LineCap raise SchemaViolation {
  ST_LineCap::parse(s)
}

///|
pub fn ST_LineCap::to_string(self : ST_LineCap) -> String {
  self.value
}

///|
pub struct ST_CompoundLine {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CompoundLine::parse(
  s : String,
) -> ST_CompoundLine raise SchemaViolation {
  validate_main_enum("ST_CompoundLine", s, [
    "sng", "dbl", "thickThin", "thinThick", "tri",
  ])
  { value: s }
}

///|
pub fn ST_CompoundLine::new(
  s : String,
) -> ST_CompoundLine raise SchemaViolation {
  ST_CompoundLine::parse(s)
}

///|
pub fn ST_CompoundLine::to_string(self : ST_CompoundLine) -> String {
  self.value
}

///|
pub struct ST_PenAlignment {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PenAlignment::parse(
  s : String,
) -> ST_PenAlignment raise SchemaViolation {
  validate_main_enum("ST_PenAlignment", s, ["ctr", "in"])
  { value: s }
}

///|
pub fn ST_PenAlignment::new(
  s : String,
) -> ST_PenAlignment raise SchemaViolation {
  ST_PenAlignment::parse(s)
}

///|
pub fn ST_PenAlignment::to_string(self : ST_PenAlignment) -> String {
  self.value
}

///|
pub struct ST_LineEndType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_LineEndType::parse(
  s : String,
) -> ST_LineEndType raise SchemaViolation {
  validate_main_enum("ST_LineEndType", s, [
    "none", "triangle", "stealth", "diamond", "oval", "arrow",
  ])
  { value: s }
}

///|
pub fn ST_LineEndType::new(s : String) -> ST_LineEndType raise SchemaViolation {
  ST_LineEndType::parse(s)
}

///|
pub fn ST_LineEndType::to_string(self : ST_LineEndType) -> String {
  self.value
}

///|
pub struct ST_LineEndWidth {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_LineEndWidth::parse(
  s : String,
) -> ST_LineEndWidth raise SchemaViolation {
  validate_main_enum("ST_LineEndWidth", s, ["sm", "med", "lg"])
  { value: s }
}

///|
pub fn ST_LineEndWidth::new(
  s : String,
) -> ST_LineEndWidth raise SchemaViolation {
  ST_LineEndWidth::parse(s)
}

///|
pub fn ST_LineEndWidth::to_string(self : ST_LineEndWidth) -> String {
  self.value
}

///|
pub struct ST_LineEndLength {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_LineEndLength::parse(
  s : String,
) -> ST_LineEndLength raise SchemaViolation {
  validate_main_enum("ST_LineEndLength", s, ["sm", "med", "lg"])
  { value: s }
}

///|
pub fn ST_LineEndLength::new(
  s : String,
) -> ST_LineEndLength raise SchemaViolation {
  ST_LineEndLength::parse(s)
}

///|
pub fn ST_LineEndLength::to_string(self : ST_LineEndLength) -> String {
  self.value
}

///|
pub struct ST_PresetLineDashVal {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PresetLineDashVal::parse(
  s : String,
) -> ST_PresetLineDashVal raise SchemaViolation {
  validate_main_enum("ST_PresetLineDashVal", s, [
    "solid", "dot", "dash", "lgDash", "dashDot", "lgDashDot", "lgDashDotDot", "sysDash",
    "sysDot", "sysDashDot", "sysDashDotDot",
  ])
  { value: s }
}

///|
pub fn ST_PresetLineDashVal::new(
  s : String,
) -> ST_PresetLineDashVal raise SchemaViolation {
  ST_PresetLineDashVal::parse(s)
}

///|
pub fn ST_PresetLineDashVal::to_string(self : ST_PresetLineDashVal) -> String {
  self.value
}

///|
fn validate_measure(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if !has_measure_token(value) {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="invalid numeric token",
    )
  }
}

///|
fn validate_non_negative_measure(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  validate_measure(type_name, value)
  if value.length() > 0 && value[0:1] == "-" {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="negative value is not allowed",
    )
  }
}

///|
fn validate_int_token(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if !is_signed_digits(value) {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="invalid integer token",
    )
  }
}

///|
fn validate_non_negative_int(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  validate_int_token(type_name, value)
  if value.length() > 0 && value[0:1] == "-" {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="negative value is not allowed",
    )
  }
}

///|
fn validate_non_empty_token(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="empty token",
    )
  }
}

///|
fn has_measure_token(value : String) -> Bool {
  if value.length() == 0 {
    false
  } else {
    let mut seen_digit = false
    let mut ok = true
    for i in 0..<value.length() {
      let ch = value[i:i + 1]
      if ch >= "0" && ch <= "9" {
        seen_digit = true
      } else if ch == "-" || ch == "+" || ch == "." || ch == "%" {
        ok = ok && true
      } else {
        ok = ok && ch >= "a" && ch <= "z"
      }
    }
    ok && seen_digit
  }
}

///|
fn is_signed_digits(value : String) -> Bool {
  if value.length() == 0 {
    false
  } else {
    let mut start = 0
    if value[0:1] == "-" || value[0:1] == "+" {
      start = 1
    }
    let mut ok = start < value.length()
    for i in start..<value.length() {
      let ch = value[i:i + 1]
      ok = ok && ch >= "0" && ch <= "9"
    }
    ok
  }
}
