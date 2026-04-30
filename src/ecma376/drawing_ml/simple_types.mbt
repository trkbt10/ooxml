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
