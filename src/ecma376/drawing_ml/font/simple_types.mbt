///|
/// Schema validation error for ECMA-376 DrawingML font (§20.1.4).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD simple type ST_TextFontScalePercentOrPercentString (§20.1.10).
pub struct ST_TextFontScalePercentOrPercentString {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextFontScalePercentOrPercentString::parse(
  s : String,
) -> ST_TextFontScalePercentOrPercentString raise SchemaViolation {
  validate_non_empty("ST_TextFontScalePercentOrPercentString", s)
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
  validate_int("ST_TextFontSize", s)
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
  validate_non_empty("ST_TextTypeface", s)
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
  validate_enum("ST_PitchFamily", s, [
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
  validate_enum("ST_TextFontAlignType", s, ["auto", "t", "ctr", "base", "b"])
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
fn validate_enum(
  type_name : String,
  value : String,
  allowed : Array[String],
) -> Unit raise SchemaViolation {
  let mut found = false
  for item in allowed {
    found = found || item == value
  }
  if !found {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="invalid enumeration value",
    )
  }
}

///|
fn validate_non_empty(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="empty value",
    )
  }
}

///|
fn validate_int(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if !is_int(value) {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="invalid xsd:int value",
    )
  }
}

///|
fn is_int(s : String) -> Bool {
  if s.length() == 0 {
    false
  } else {
    let mut start = 0
    if s[0:1] == "-" || s[0:1] == "+" {
      start = 1
    }
    start < s.length() && digits(s, start, s.length())
  }
}

///|
fn digits(s : String, start : Int, end : Int) -> Bool {
  let mut ok = start >= 0 && end <= s.length() && start < end
  for i in start..<end {
    let ch = s[i:i + 1]
    ok = ok && ch >= "0" && ch <= "9"
  }
  ok
}
