// ECMA-376 Part 1 §20.1.10 DrawingML simple types — typed representations.
//
// Every type below mirrors the schema content model from Annex A.4.1
// (DrawingML Main) rather than carrying the lexical String through to
// callers. Doc comments retain the §-anchor required by the drift gate.

///|
/// XSD simple type ST_UniversalMeasure — Part 1 §22.9.2.15. The DrawingML
/// union types pull this in alongside their EMU/int branches, so we keep a
/// typed magnitude+unit pair here to share with both branches.
pub struct ST_UniversalMeasure {
  magnitude : Double
  unit : UniversalMeasureUnit
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.15 — the six universal measure unit suffixes: millimetre,
/// centimetre, inch, point, pica, and pi (didot point).
pub(all) enum UniversalMeasureUnit {
  /// §22.9.2.15 "mm"
  Millimetre
  /// §22.9.2.15 "cm"
  Centimetre
  /// §22.9.2.15 "in"
  Inch
  /// §22.9.2.15 "pt"
  Point
  /// §22.9.2.15 "pc"
  Pica
  /// §22.9.2.15 "pi"
  PiPoint
} derive(Eq, Debug)

///|
fn UniversalMeasureUnit::from_lexical(
  s : String,
) -> UniversalMeasureUnit raise SchemaViolation {
  match s {
    "mm" => Millimetre
    "cm" => Centimetre
    "in" => Inch
    "pt" => Point
    "pc" => Pica
    "pi" => PiPoint
    _ => measure_violation("UniversalMeasureUnit")
  }
}

///|
pub fn UniversalMeasureUnit::to_string(self : UniversalMeasureUnit) -> String {
  match self {
    Millimetre => "mm"
    Centimetre => "cm"
    Inch => "in"
    Point => "pt"
    Pica => "pc"
    PiPoint => "pi"
  }
}

///|
/// Part 1 §22.9.2.15 — decode the lexical "decimal + unit" form.
pub fn ST_UniversalMeasure::new(
  s : String,
) -> ST_UniversalMeasure raise SchemaViolation {
  if !is_universal_measure(s) {
    measure_violation("ST_UniversalMeasure")
  }
  let split = s.length() - 2
  let magnitude_text = s.unsafe_substring(start=0, end=split)
  let unit_text = s.unsafe_substring(start=split, end=s.length())
  let magnitude = parse_decimal_double(magnitude_text)
  let unit = UniversalMeasureUnit::from_lexical(unit_text)
  { magnitude, unit }
}

///|
pub fn ST_UniversalMeasure::to_string(self : ST_UniversalMeasure) -> String {
  format_decimal(self.magnitude) + self.unit.to_string()
}

///|
pub fn ST_UniversalMeasure::magnitude_value(
  self : ST_UniversalMeasure,
) -> Double {
  self.magnitude
}

///|
pub fn ST_UniversalMeasure::unit_of(
  self : ST_UniversalMeasure,
) -> UniversalMeasureUnit {
  self.unit
}

///|
/// XSD simple type ST_CoordinateUnqualified — Part 1 §20.1.10.19. xsd:long
/// EMU coordinate restricted to [-27 273 042 329 600, 27 273 042 316 900].
/// Stored as Int64 so arithmetic happens on the spec's value space.
pub struct ST_CoordinateUnqualified {
  emu : Int64
} derive(Eq, Debug)

///|
/// Lower inclusive bound from §20.1.10.19.
const ST_COORDINATE_UNQUALIFIED_MIN : Int64 = -27273042329600L

///|
/// Upper inclusive bound from §20.1.10.19.
const ST_COORDINATE_UNQUALIFIED_MAX : Int64 = 27273042316900L

///|
pub fn ST_CoordinateUnqualified::parse(
  s : String,
) -> ST_CoordinateUnqualified raise SchemaViolation {
  let emu = parse_long_or_violate("ST_CoordinateUnqualified", s)
  range_check_long(
    "ST_CoordinateUnqualified",
    emu,
    ST_COORDINATE_UNQUALIFIED_MIN,
    ST_COORDINATE_UNQUALIFIED_MAX,
  )
  { emu, }
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
  self.emu.to_string()
}

///|
pub fn ST_CoordinateUnqualified::to_int64(
  self : ST_CoordinateUnqualified,
) -> Int64 {
  self.emu
}

///|
/// XSD simple type ST_Coordinate — Part 1 §20.1.10.16. Union of
/// ST_CoordinateUnqualified (raw EMU long) and ST_UniversalMeasure
/// (decimal + unit suffix). Discriminated so neither branch is lost.
pub(all) enum ST_Coordinate {
  /// §20.1.10.16 EMU long branch.
  CoordEmu(ST_CoordinateUnqualified)
  /// §20.1.10.16 universal-measure branch.
  CoordMeasure(ST_UniversalMeasure)
} derive(Eq, Debug)

///|
pub fn ST_Coordinate::parse(s : String) -> ST_Coordinate raise SchemaViolation {
  if is_universal_measure(s) {
    CoordMeasure(ST_UniversalMeasure::new(s))
  } else {
    CoordEmu(ST_CoordinateUnqualified::parse(s))
  }
}

///|
pub fn ST_Coordinate::new(s : String) -> ST_Coordinate raise SchemaViolation {
  ST_Coordinate::parse(s)
}

///|
pub fn ST_Coordinate::to_string(self : ST_Coordinate) -> String {
  match self {
    CoordEmu(value) => value.to_string()
    CoordMeasure(value) => value.to_string()
  }
}

///|
/// XSD simple type ST_Coordinate32Unqualified — Part 1 §20.1.10.18. xsd:int
/// (signed 32-bit) EMU coordinate.
pub struct ST_Coordinate32Unqualified {
  emu : Int
} derive(Eq, Debug)

///|
pub fn ST_Coordinate32Unqualified::parse(
  s : String,
) -> ST_Coordinate32Unqualified raise SchemaViolation {
  let emu = parse_int_or_violate("ST_Coordinate32Unqualified", s)
  { emu, }
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
  self.emu.to_string()
}

///|
pub fn ST_Coordinate32Unqualified::to_int(
  self : ST_Coordinate32Unqualified,
) -> Int {
  self.emu
}

///|
/// XSD simple type ST_Coordinate32 — Part 1 §20.1.10.17. Union of
/// ST_Coordinate32Unqualified and ST_UniversalMeasure.
pub(all) enum ST_Coordinate32 {
  /// §20.1.10.17 32-bit EMU branch.
  Coord32Emu(ST_Coordinate32Unqualified)
  /// §20.1.10.17 universal-measure branch.
  Coord32Measure(ST_UniversalMeasure)
} derive(Eq, Debug)

///|
pub fn ST_Coordinate32::parse(
  s : String,
) -> ST_Coordinate32 raise SchemaViolation {
  if is_universal_measure(s) {
    Coord32Measure(ST_UniversalMeasure::new(s))
  } else {
    Coord32Emu(ST_Coordinate32Unqualified::parse(s))
  }
}

///|
pub fn ST_Coordinate32::new(
  s : String,
) -> ST_Coordinate32 raise SchemaViolation {
  ST_Coordinate32::parse(s)
}

///|
pub fn ST_Coordinate32::to_string(self : ST_Coordinate32) -> String {
  match self {
    Coord32Emu(value) => value.to_string()
    Coord32Measure(value) => value.to_string()
  }
}

///|
/// XSD simple type ST_PositiveCoordinate — Part 1 §20.1.10.42. xsd:long EMU
/// coordinate restricted to [0, 27 273 042 316 900].
pub struct ST_PositiveCoordinate {
  emu : Int64
} derive(Eq, Debug)

///|
pub fn ST_PositiveCoordinate::parse(
  s : String,
) -> ST_PositiveCoordinate raise SchemaViolation {
  let emu = parse_long_or_violate("ST_PositiveCoordinate", s)
  range_check_long(
    "ST_PositiveCoordinate",
    emu,
    0L,
    ST_COORDINATE_UNQUALIFIED_MAX,
  )
  { emu, }
}

///|
pub fn ST_PositiveCoordinate::new(
  s : String,
) -> ST_PositiveCoordinate raise SchemaViolation {
  ST_PositiveCoordinate::parse(s)
}

///|
pub fn ST_PositiveCoordinate::to_string(self : ST_PositiveCoordinate) -> String {
  self.emu.to_string()
}

///|
pub fn ST_PositiveCoordinate::to_int64(self : ST_PositiveCoordinate) -> Int64 {
  self.emu
}

///|
/// XSD simple type ST_PositiveCoordinate32 — Part 1 §20.1.10.43. xsd:int EMU
/// coordinate restricted to ≥ 0.
pub struct ST_PositiveCoordinate32 {
  emu : Int
} derive(Eq, Debug)

///|
pub fn ST_PositiveCoordinate32::parse(
  s : String,
) -> ST_PositiveCoordinate32 raise SchemaViolation {
  let emu = parse_int_or_violate("ST_PositiveCoordinate32", s)
  if emu < 0 {
    measure_violation("ST_PositiveCoordinate32")
  }
  { emu, }
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
  self.emu.to_string()
}

///|
pub fn ST_PositiveCoordinate32::to_int(self : ST_PositiveCoordinate32) -> Int {
  self.emu
}

///|
/// XSD simple type ST_Angle — Part 1 §20.1.10.3. xsd:int storing an angle
/// in 60 000ths of a degree (positive = clockwise).
pub struct ST_Angle {
  sixty_thousandths : Int
} derive(Eq, Debug)

///|
pub fn ST_Angle::parse(s : String) -> ST_Angle raise SchemaViolation {
  let v = parse_int_or_violate("ST_Angle", s)
  { sixty_thousandths: v }
}

///|
pub fn ST_Angle::new(s : String) -> ST_Angle raise SchemaViolation {
  ST_Angle::parse(s)
}

///|
pub fn ST_Angle::to_string(self : ST_Angle) -> String {
  self.sixty_thousandths.to_string()
}

///|
pub fn ST_Angle::sixty_thousandths_of_degree(self : ST_Angle) -> Int {
  self.sixty_thousandths
}

///|
/// XSD simple type ST_FixedAngle — Part 1 §20.1.10.23. Restriction of
/// ST_Angle with -5 400 000 < value < 5 400 000 (i.e. open interval).
pub struct ST_FixedAngle {
  sixty_thousandths : Int
} derive(Eq, Debug)

///|
pub fn ST_FixedAngle::parse(s : String) -> ST_FixedAngle raise SchemaViolation {
  let v = parse_int_or_violate("ST_FixedAngle", s)
  if v <= -5400000 || v >= 5400000 {
    measure_violation("ST_FixedAngle")
  }
  { sixty_thousandths: v }
}

///|
pub fn ST_FixedAngle::new(s : String) -> ST_FixedAngle raise SchemaViolation {
  ST_FixedAngle::parse(s)
}

///|
pub fn ST_FixedAngle::to_string(self : ST_FixedAngle) -> String {
  self.sixty_thousandths.to_string()
}

///|
pub fn ST_FixedAngle::sixty_thousandths_of_degree(self : ST_FixedAngle) -> Int {
  self.sixty_thousandths
}

///|
/// XSD simple type ST_PositiveFixedAngle — Part 1 §20.1.10.44. Restriction
/// of ST_Angle with 0 ≤ value < 21 600 000 (half-open interval).
pub struct ST_PositiveFixedAngle {
  sixty_thousandths : Int
} derive(Eq, Debug)

///|
pub fn ST_PositiveFixedAngle::parse(
  s : String,
) -> ST_PositiveFixedAngle raise SchemaViolation {
  let v = parse_int_or_violate("ST_PositiveFixedAngle", s)
  if v < 0 || v >= 21600000 {
    measure_violation("ST_PositiveFixedAngle")
  }
  { sixty_thousandths: v }
}

///|
pub fn ST_PositiveFixedAngle::new(
  s : String,
) -> ST_PositiveFixedAngle raise SchemaViolation {
  ST_PositiveFixedAngle::parse(s)
}

///|
pub fn ST_PositiveFixedAngle::to_string(self : ST_PositiveFixedAngle) -> String {
  self.sixty_thousandths.to_string()
}

///|
pub fn ST_PositiveFixedAngle::sixty_thousandths_of_degree(
  self : ST_PositiveFixedAngle,
) -> Int {
  self.sixty_thousandths
}

///|
/// XSD simple type ST_Percentage — Part 1 §20.1.10.40 (strict) and Part 4
/// §A.4.1 ST_Percentage (transitional). The transitional union admits both
/// the raw xsd:int `ST_PercentageDecimal` branch (already scaled by 1000)
/// and the shared §22.9.2.9 `s:ST_Percentage` lexical "<decimal>%" branch;
/// both are stored as 1000ths-of-percent so callers compare numerically.
pub struct ST_Percentage {
  /// 1000ths of a percent; e.g. "12.345%" → 12345; "12345" → 12345.
  thousandths : Int64
} derive(Eq, Debug)

///|
pub fn ST_Percentage::parse(s : String) -> ST_Percentage raise SchemaViolation {
  let thousandths = parse_percent_thousandths(
    "ST_Percentage",
    s,
    positive=false,
    fixed=false,
  )
  { thousandths, }
}

///|
pub fn ST_Percentage::new(s : String) -> ST_Percentage raise SchemaViolation {
  ST_Percentage::parse(s)
}

///|
pub fn ST_Percentage::to_string(self : ST_Percentage) -> String {
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
pub fn ST_Percentage::thousandths_of_percent(self : ST_Percentage) -> Int64 {
  self.thousandths
}

///|
/// XSD simple type ST_PositivePercentage — Part 1 §20.1.10.46. Restriction
/// of ST_Percentage with magnitude ≥ 0%.
pub struct ST_PositivePercentage {
  thousandths : Int64
} derive(Eq, Debug)

///|
pub fn ST_PositivePercentage::parse(
  s : String,
) -> ST_PositivePercentage raise SchemaViolation {
  let thousandths = parse_percent_thousandths(
    "ST_PositivePercentage",
    s,
    positive=true,
    fixed=false,
  )
  { thousandths, }
}

///|
pub fn ST_PositivePercentage::new(
  s : String,
) -> ST_PositivePercentage raise SchemaViolation {
  ST_PositivePercentage::parse(s)
}

///|
pub fn ST_PositivePercentage::to_string(self : ST_PositivePercentage) -> String {
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
pub fn ST_PositivePercentage::thousandths_of_percent(
  self : ST_PositivePercentage,
) -> Int64 {
  self.thousandths
}

///|
/// XSD simple type ST_FixedPercentage — Part 1 §20.1.10.24. Restriction of
/// ST_Percentage to |value| ≤ 100%.
pub struct ST_FixedPercentage {
  thousandths : Int64
} derive(Eq, Debug)

///|
pub fn ST_FixedPercentage::parse(
  s : String,
) -> ST_FixedPercentage raise SchemaViolation {
  let thousandths = parse_percent_thousandths(
    "ST_FixedPercentage",
    s,
    positive=false,
    fixed=true,
  )
  { thousandths, }
}

///|
pub fn ST_FixedPercentage::new(
  s : String,
) -> ST_FixedPercentage raise SchemaViolation {
  ST_FixedPercentage::parse(s)
}

///|
pub fn ST_FixedPercentage::to_string(self : ST_FixedPercentage) -> String {
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
pub fn ST_FixedPercentage::thousandths_of_percent(
  self : ST_FixedPercentage,
) -> Int64 {
  self.thousandths
}

///|
/// XSD simple type ST_PositiveFixedPercentage — Part 1 §20.1.10.45.
/// Restriction of ST_Percentage to 0% ≤ value ≤ 100%.
pub struct ST_PositiveFixedPercentage {
  thousandths : Int64
} derive(Eq, Debug)

///|
pub fn ST_PositiveFixedPercentage::parse(
  s : String,
) -> ST_PositiveFixedPercentage raise SchemaViolation {
  let thousandths = parse_percent_thousandths(
    "ST_PositiveFixedPercentage",
    s,
    positive=true,
    fixed=true,
  )
  { thousandths, }
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
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
pub fn ST_PositiveFixedPercentage::thousandths_of_percent(
  self : ST_PositiveFixedPercentage,
) -> Int64 {
  self.thousandths
}

///|
/// XSD simple type ST_TextFontScalePercentOrPercentString — Part 1
/// §20.1.10.67. Union over the shared §22.9.2.9 ST_Percentage so the lexical
/// form is "<decimal>%". Stored as 1000ths-of-percent identically to
/// ST_Percentage.
pub struct ST_TextFontScalePercentOrPercentString {
  thousandths : Int64
} derive(Eq, Debug)

///|
pub fn ST_TextFontScalePercentOrPercentString::parse(
  s : String,
) -> ST_TextFontScalePercentOrPercentString raise SchemaViolation {
  let thousandths = parse_percent_thousandths(
    "ST_TextFontScalePercentOrPercentString",
    s,
    positive=false,
    fixed=false,
  )
  { thousandths, }
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
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
pub fn ST_TextFontScalePercentOrPercentString::thousandths_of_percent(
  self : ST_TextFontScalePercentOrPercentString,
) -> Int64 {
  self.thousandths
}

///|
/// XSD simple type ST_TextSpacingPercentOrPercentString — Part 1
/// §20.1.10.77. Union over §22.9.2.9 ST_Percentage; same encoding as
/// ST_Percentage.
pub struct ST_TextSpacingPercentOrPercentString {
  thousandths : Int64
} derive(Eq, Debug)

///|
pub fn ST_TextSpacingPercentOrPercentString::parse(
  s : String,
) -> ST_TextSpacingPercentOrPercentString raise SchemaViolation {
  let thousandths = parse_percent_thousandths(
    "ST_TextSpacingPercentOrPercentString",
    s,
    positive=false,
    fixed=false,
  )
  { thousandths, }
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
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
pub fn ST_TextSpacingPercentOrPercentString::thousandths_of_percent(
  self : ST_TextSpacingPercentOrPercentString,
) -> Int64 {
  self.thousandths
}

///|
/// XSD simple type ST_TextFontSize — Part 1 §20.1.10.68. xsd:int in
/// hundredths of a point, restricted to [100, 400 000].
pub struct ST_TextFontSize {
  hundredths_of_point : Int
} derive(Eq, Debug)

///|
pub fn ST_TextFontSize::parse(
  s : String,
) -> ST_TextFontSize raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextFontSize", s)
  if v < 100 || v > 400000 {
    measure_violation("ST_TextFontSize")
  }
  { hundredths_of_point: v }
}

///|
pub fn ST_TextFontSize::new(
  s : String,
) -> ST_TextFontSize raise SchemaViolation {
  ST_TextFontSize::parse(s)
}

///|
pub fn ST_TextFontSize::to_string(self : ST_TextFontSize) -> String {
  self.hundredths_of_point.to_string()
}

///|
pub fn ST_TextFontSize::hundredths_of_point(self : ST_TextFontSize) -> Int {
  self.hundredths_of_point
}

///|
/// XSD simple type ST_TextTypeface — Part 1 §20.1.10.81. xsd:string (no
/// further restriction). Wrapped in a typed nominal so callers can tell it
/// apart from generic strings.
pub struct ST_TextTypeface {
  lexical : String
} derive(Eq, Debug)

///|
pub fn ST_TextTypeface::parse(
  s : String,
) -> ST_TextTypeface raise SchemaViolation {
  if s.length() == 0 {
    measure_violation("ST_TextTypeface")
  }
  { lexical: s }
}

///|
pub fn ST_TextTypeface::new(
  s : String,
) -> ST_TextTypeface raise SchemaViolation {
  ST_TextTypeface::parse(s)
}

///|
pub fn ST_TextTypeface::to_string(self : ST_TextTypeface) -> String {
  self.lexical
}

///|
/// XSD simple type ST_PitchFamily — Part 1 §20.1.10.41. xsd:byte enumeration
/// where the high nibble is the font family and the low nibble is the font
/// pitch. Stored as the raw byte value.
pub(all) enum ST_PitchFamily {
  /// §20.1.10.41 "00" — DEFAULT PITCH + UNKNOWN FONT FAMILY
  PitchFamily00
  /// §20.1.10.41 "01" — FIXED PITCH + UNKNOWN FONT FAMILY
  PitchFamily01
  /// §20.1.10.41 "02" — VARIABLE PITCH + UNKNOWN FONT FAMILY
  PitchFamily02
  /// §20.1.10.41 "16" — DEFAULT PITCH + ROMAN FONT FAMILY
  PitchFamily16
  /// §20.1.10.41 "17" — FIXED PITCH + ROMAN FONT FAMILY
  PitchFamily17
  /// §20.1.10.41 "18" — VARIABLE PITCH + ROMAN FONT FAMILY
  PitchFamily18
  /// §20.1.10.41 "32" — DEFAULT PITCH + SWISS FONT FAMILY
  PitchFamily32
  /// §20.1.10.41 "33" — FIXED PITCH + SWISS FONT FAMILY
  PitchFamily33
  /// §20.1.10.41 "34" — VARIABLE PITCH + SWISS FONT FAMILY
  PitchFamily34
  /// §20.1.10.41 "48" — DEFAULT PITCH + MODERN FONT FAMILY
  PitchFamily48
  /// §20.1.10.41 "49" — FIXED PITCH + MODERN FONT FAMILY
  PitchFamily49
  /// §20.1.10.41 "50" — VARIABLE PITCH + MODERN FONT FAMILY
  PitchFamily50
  /// §20.1.10.41 "64" — DEFAULT PITCH + SCRIPT FONT FAMILY
  PitchFamily64
  /// §20.1.10.41 "65" — FIXED PITCH + SCRIPT FONT FAMILY
  PitchFamily65
  /// §20.1.10.41 "66" — VARIABLE PITCH + SCRIPT FONT FAMILY
  PitchFamily66
  /// §20.1.10.41 "80" — DEFAULT PITCH + DECORATIVE FONT FAMILY
  PitchFamily80
  /// §20.1.10.41 "81" — FIXED PITCH + DECORATIVE FONT FAMILY
  PitchFamily81
  /// §20.1.10.41 "82" — VARIABLE PITCH + DECORATIVE FONT FAMILY
  PitchFamily82
} derive(Eq, Debug)

///|
pub fn ST_PitchFamily::parse(
  s : String,
) -> ST_PitchFamily raise SchemaViolation {
  match s {
    "00" => PitchFamily00
    "01" => PitchFamily01
    "02" => PitchFamily02
    "16" => PitchFamily16
    "17" => PitchFamily17
    "18" => PitchFamily18
    "32" => PitchFamily32
    "33" => PitchFamily33
    "34" => PitchFamily34
    "48" => PitchFamily48
    "49" => PitchFamily49
    "50" => PitchFamily50
    "64" => PitchFamily64
    "65" => PitchFamily65
    "66" => PitchFamily66
    "80" => PitchFamily80
    "81" => PitchFamily81
    "82" => PitchFamily82
    _ => enum_violation("ST_PitchFamily")
  }
}

///|
pub fn ST_PitchFamily::new(s : String) -> ST_PitchFamily raise SchemaViolation {
  ST_PitchFamily::parse(s)
}

///|
pub fn ST_PitchFamily::to_string(self : ST_PitchFamily) -> String {
  match self {
    PitchFamily00 => "00"
    PitchFamily01 => "01"
    PitchFamily02 => "02"
    PitchFamily16 => "16"
    PitchFamily17 => "17"
    PitchFamily18 => "18"
    PitchFamily32 => "32"
    PitchFamily33 => "33"
    PitchFamily34 => "34"
    PitchFamily48 => "48"
    PitchFamily49 => "49"
    PitchFamily50 => "50"
    PitchFamily64 => "64"
    PitchFamily65 => "65"
    PitchFamily66 => "66"
    PitchFamily80 => "80"
    PitchFamily81 => "81"
    PitchFamily82 => "82"
  }
}

///|
/// XSD simple type ST_TextFontAlignType — Part 1 §20.1.10.66. xsd:token
/// enumeration of five anchor positions.
pub(all) enum ST_TextFontAlignType {
  /// §20.1.10.66 "auto"
  FontAlignAuto
  /// §20.1.10.66 "t"
  FontAlignTop
  /// §20.1.10.66 "ctr"
  FontAlignCenter
  /// §20.1.10.66 "base"
  FontAlignBaseline
  /// §20.1.10.66 "b"
  FontAlignBottom
} derive(Eq, Debug)

///|
pub fn ST_TextFontAlignType::parse(
  s : String,
) -> ST_TextFontAlignType raise SchemaViolation {
  match s {
    "auto" => FontAlignAuto
    "t" => FontAlignTop
    "ctr" => FontAlignCenter
    "base" => FontAlignBaseline
    "b" => FontAlignBottom
    _ => enum_violation("ST_TextFontAlignType")
  }
}

///|
pub fn ST_TextFontAlignType::new(
  s : String,
) -> ST_TextFontAlignType raise SchemaViolation {
  ST_TextFontAlignType::parse(s)
}

///|
pub fn ST_TextFontAlignType::to_string(self : ST_TextFontAlignType) -> String {
  match self {
    FontAlignAuto => "auto"
    FontAlignTop => "t"
    FontAlignCenter => "ctr"
    FontAlignBaseline => "base"
    FontAlignBottom => "b"
  }
}

///|
/// XSD simple type ST_TextShapeType — Part 1 §20.1.10.76. xsd:token
/// enumeration of preset text-warp shapes.
pub(all) enum ST_TextShapeType {
  /// §20.1.10.76 "textNoShape"
  TextNoShape
  /// §20.1.10.76 "textPlain"
  TextPlain
  /// §20.1.10.76 "textStop"
  TextStop
  /// §20.1.10.76 "textTriangle"
  TextTriangle
  /// §20.1.10.76 "textTriangleInverted"
  TextTriangleInverted
  /// §20.1.10.76 "textChevron"
  TextChevron
  /// §20.1.10.76 "textChevronInverted"
  TextChevronInverted
  /// §20.1.10.76 "textRingInside"
  TextRingInside
  /// §20.1.10.76 "textRingOutside"
  TextRingOutside
  /// §20.1.10.76 "textArchUp"
  TextArchUp
  /// §20.1.10.76 "textArchDown"
  TextArchDown
  /// §20.1.10.76 "textCircle"
  TextCircle
  /// §20.1.10.76 "textButton"
  TextButton
  /// §20.1.10.76 "textArchUpPour"
  TextArchUpPour
  /// §20.1.10.76 "textArchDownPour"
  TextArchDownPour
  /// §20.1.10.76 "textCirclePour"
  TextCirclePour
  /// §20.1.10.76 "textButtonPour"
  TextButtonPour
  /// §20.1.10.76 "textCurveUp"
  TextCurveUp
  /// §20.1.10.76 "textCurveDown"
  TextCurveDown
  /// §20.1.10.76 "textCanUp"
  TextCanUp
  /// §20.1.10.76 "textCanDown"
  TextCanDown
  /// §20.1.10.76 "textWave1"
  TextWave1
  /// §20.1.10.76 "textWave2"
  TextWave2
  /// §20.1.10.76 "textDoubleWave1"
  TextDoubleWave1
  /// §20.1.10.76 "textWave4"
  TextWave4
  /// §20.1.10.76 "textInflate"
  TextInflate
  /// §20.1.10.76 "textDeflate"
  TextDeflate
  /// §20.1.10.76 "textInflateBottom"
  TextInflateBottom
  /// §20.1.10.76 "textDeflateBottom"
  TextDeflateBottom
  /// §20.1.10.76 "textInflateTop"
  TextInflateTop
  /// §20.1.10.76 "textDeflateTop"
  TextDeflateTop
  /// §20.1.10.76 "textDeflateInflate"
  TextDeflateInflate
  /// §20.1.10.76 "textDeflateInflateDeflate"
  TextDeflateInflateDeflate
  /// §20.1.10.76 "textFadeRight"
  TextFadeRight
  /// §20.1.10.76 "textFadeLeft"
  TextFadeLeft
  /// §20.1.10.76 "textFadeUp"
  TextFadeUp
  /// §20.1.10.76 "textFadeDown"
  TextFadeDown
  /// §20.1.10.76 "textSlantUp"
  TextSlantUp
  /// §20.1.10.76 "textSlantDown"
  TextSlantDown
  /// §20.1.10.76 "textCascadeUp"
  TextCascadeUp
  /// §20.1.10.76 "textCascadeDown"
  TextCascadeDown
} derive(Eq, Debug)

///|
pub fn ST_TextShapeType::parse(
  s : String,
) -> ST_TextShapeType raise SchemaViolation {
  match s {
    "textNoShape" => TextNoShape
    "textPlain" => TextPlain
    "textStop" => TextStop
    "textTriangle" => TextTriangle
    "textTriangleInverted" => TextTriangleInverted
    "textChevron" => TextChevron
    "textChevronInverted" => TextChevronInverted
    "textRingInside" => TextRingInside
    "textRingOutside" => TextRingOutside
    "textArchUp" => TextArchUp
    "textArchDown" => TextArchDown
    "textCircle" => TextCircle
    "textButton" => TextButton
    "textArchUpPour" => TextArchUpPour
    "textArchDownPour" => TextArchDownPour
    "textCirclePour" => TextCirclePour
    "textButtonPour" => TextButtonPour
    "textCurveUp" => TextCurveUp
    "textCurveDown" => TextCurveDown
    "textCanUp" => TextCanUp
    "textCanDown" => TextCanDown
    "textWave1" => TextWave1
    "textWave2" => TextWave2
    "textDoubleWave1" => TextDoubleWave1
    "textWave4" => TextWave4
    "textInflate" => TextInflate
    "textDeflate" => TextDeflate
    "textInflateBottom" => TextInflateBottom
    "textDeflateBottom" => TextDeflateBottom
    "textInflateTop" => TextInflateTop
    "textDeflateTop" => TextDeflateTop
    "textDeflateInflate" => TextDeflateInflate
    "textDeflateInflateDeflate" => TextDeflateInflateDeflate
    "textFadeRight" => TextFadeRight
    "textFadeLeft" => TextFadeLeft
    "textFadeUp" => TextFadeUp
    "textFadeDown" => TextFadeDown
    "textSlantUp" => TextSlantUp
    "textSlantDown" => TextSlantDown
    "textCascadeUp" => TextCascadeUp
    "textCascadeDown" => TextCascadeDown
    _ => enum_violation("ST_TextShapeType")
  }
}

///|
pub fn ST_TextShapeType::new(
  s : String,
) -> ST_TextShapeType raise SchemaViolation {
  ST_TextShapeType::parse(s)
}

///|
pub fn ST_TextShapeType::to_string(self : ST_TextShapeType) -> String {
  match self {
    TextNoShape => "textNoShape"
    TextPlain => "textPlain"
    TextStop => "textStop"
    TextTriangle => "textTriangle"
    TextTriangleInverted => "textTriangleInverted"
    TextChevron => "textChevron"
    TextChevronInverted => "textChevronInverted"
    TextRingInside => "textRingInside"
    TextRingOutside => "textRingOutside"
    TextArchUp => "textArchUp"
    TextArchDown => "textArchDown"
    TextCircle => "textCircle"
    TextButton => "textButton"
    TextArchUpPour => "textArchUpPour"
    TextArchDownPour => "textArchDownPour"
    TextCirclePour => "textCirclePour"
    TextButtonPour => "textButtonPour"
    TextCurveUp => "textCurveUp"
    TextCurveDown => "textCurveDown"
    TextCanUp => "textCanUp"
    TextCanDown => "textCanDown"
    TextWave1 => "textWave1"
    TextWave2 => "textWave2"
    TextDoubleWave1 => "textDoubleWave1"
    TextWave4 => "textWave4"
    TextInflate => "textInflate"
    TextDeflate => "textDeflate"
    TextInflateBottom => "textInflateBottom"
    TextDeflateBottom => "textDeflateBottom"
    TextInflateTop => "textInflateTop"
    TextDeflateTop => "textDeflateTop"
    TextDeflateInflate => "textDeflateInflate"
    TextDeflateInflateDeflate => "textDeflateInflateDeflate"
    TextFadeRight => "textFadeRight"
    TextFadeLeft => "textFadeLeft"
    TextFadeUp => "textFadeUp"
    TextFadeDown => "textFadeDown"
    TextSlantUp => "textSlantUp"
    TextSlantDown => "textSlantDown"
    TextCascadeUp => "textCascadeUp"
    TextCascadeDown => "textCascadeDown"
  }
}

///|
/// XSD simple type ST_TextAnchoringType — Part 1 §20.1.10.60. Anchor
/// positions inside the text bounding box.
pub(all) enum ST_TextAnchoringType {
  /// §20.1.10.60 "t"
  AnchorTop
  /// §20.1.10.60 "ctr"
  AnchorCenter
  /// §20.1.10.60 "b"
  AnchorBottom
  /// §20.1.10.60 "just"
  AnchorJustified
  /// §20.1.10.60 "dist"
  AnchorDistributed
} derive(Eq, Debug)

///|
pub fn ST_TextAnchoringType::parse(
  s : String,
) -> ST_TextAnchoringType raise SchemaViolation {
  match s {
    "t" => AnchorTop
    "ctr" => AnchorCenter
    "b" => AnchorBottom
    "just" => AnchorJustified
    "dist" => AnchorDistributed
    _ => enum_violation("ST_TextAnchoringType")
  }
}

///|
pub fn ST_TextAnchoringType::new(
  s : String,
) -> ST_TextAnchoringType raise SchemaViolation {
  ST_TextAnchoringType::parse(s)
}

///|
pub fn ST_TextAnchoringType::to_string(self : ST_TextAnchoringType) -> String {
  match self {
    AnchorTop => "t"
    AnchorCenter => "ctr"
    AnchorBottom => "b"
    AnchorJustified => "just"
    AnchorDistributed => "dist"
  }
}

///|
/// XSD simple type ST_TextVertOverflowType — Part 1 §20.1.10.84.
pub(all) enum ST_TextVertOverflowType {
  /// §20.1.10.84 "overflow"
  VertOverflow
  /// §20.1.10.84 "ellipsis"
  VertEllipsis
  /// §20.1.10.84 "clip"
  VertClip
} derive(Eq, Debug)

///|
pub fn ST_TextVertOverflowType::parse(
  s : String,
) -> ST_TextVertOverflowType raise SchemaViolation {
  match s {
    "overflow" => VertOverflow
    "ellipsis" => VertEllipsis
    "clip" => VertClip
    _ => enum_violation("ST_TextVertOverflowType")
  }
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
  match self {
    VertOverflow => "overflow"
    VertEllipsis => "ellipsis"
    VertClip => "clip"
  }
}

///|
/// XSD simple type ST_TextHorzOverflowType — Part 1 §20.1.10.69.
pub(all) enum ST_TextHorzOverflowType {
  /// §20.1.10.69 "overflow"
  HorzOverflow
  /// §20.1.10.69 "clip"
  HorzClip
} derive(Eq, Debug)

///|
pub fn ST_TextHorzOverflowType::parse(
  s : String,
) -> ST_TextHorzOverflowType raise SchemaViolation {
  match s {
    "overflow" => HorzOverflow
    "clip" => HorzClip
    _ => enum_violation("ST_TextHorzOverflowType")
  }
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
  match self {
    HorzOverflow => "overflow"
    HorzClip => "clip"
  }
}

///|
/// XSD simple type ST_TextVerticalType — Part 1 §20.1.10.83.
pub(all) enum ST_TextVerticalType {
  /// §20.1.10.83 "horz"
  TextHorz
  /// §20.1.10.83 "vert"
  TextVert
  /// §20.1.10.83 "vert270"
  TextVert270
  /// §20.1.10.83 "wordArtVert"
  TextWordArtVert
  /// §20.1.10.83 "eaVert"
  TextEaVert
  /// §20.1.10.83 "mongolianVert"
  TextMongolianVert
  /// §20.1.10.83 "wordArtVertRtl"
  TextWordArtVertRtl
} derive(Eq, Debug)

///|
pub fn ST_TextVerticalType::parse(
  s : String,
) -> ST_TextVerticalType raise SchemaViolation {
  match s {
    "horz" => TextHorz
    "vert" => TextVert
    "vert270" => TextVert270
    "wordArtVert" => TextWordArtVert
    "eaVert" => TextEaVert
    "mongolianVert" => TextMongolianVert
    "wordArtVertRtl" => TextWordArtVertRtl
    _ => enum_violation("ST_TextVerticalType")
  }
}

///|
pub fn ST_TextVerticalType::new(
  s : String,
) -> ST_TextVerticalType raise SchemaViolation {
  ST_TextVerticalType::parse(s)
}

///|
pub fn ST_TextVerticalType::to_string(self : ST_TextVerticalType) -> String {
  match self {
    TextHorz => "horz"
    TextVert => "vert"
    TextVert270 => "vert270"
    TextWordArtVert => "wordArtVert"
    TextEaVert => "eaVert"
    TextMongolianVert => "mongolianVert"
    TextWordArtVertRtl => "wordArtVertRtl"
  }
}

///|
/// XSD simple type ST_TextWrappingType — Part 1 §20.1.10.85.
pub(all) enum ST_TextWrappingType {
  /// §20.1.10.85 "none"
  WrapNone
  /// §20.1.10.85 "square"
  WrapSquare
} derive(Eq, Debug)

///|
pub fn ST_TextWrappingType::parse(
  s : String,
) -> ST_TextWrappingType raise SchemaViolation {
  match s {
    "none" => WrapNone
    "square" => WrapSquare
    _ => enum_violation("ST_TextWrappingType")
  }
}

///|
pub fn ST_TextWrappingType::new(
  s : String,
) -> ST_TextWrappingType raise SchemaViolation {
  ST_TextWrappingType::parse(s)
}

///|
pub fn ST_TextWrappingType::to_string(self : ST_TextWrappingType) -> String {
  match self {
    WrapNone => "none"
    WrapSquare => "square"
  }
}

///|
/// XSD simple type ST_TextColumnCount — Part 1 §20.1.10.65. xsd:int in
/// [1, 16].
pub struct ST_TextColumnCount {
  count : Int
} derive(Eq, Debug)

///|
pub fn ST_TextColumnCount::parse(
  s : String,
) -> ST_TextColumnCount raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextColumnCount", s)
  if v < 1 || v > 16 {
    measure_violation("ST_TextColumnCount")
  }
  { count: v }
}

///|
pub fn ST_TextColumnCount::new(
  s : String,
) -> ST_TextColumnCount raise SchemaViolation {
  ST_TextColumnCount::parse(s)
}

///|
pub fn ST_TextColumnCount::to_string(self : ST_TextColumnCount) -> String {
  self.count.to_string()
}

///|
pub fn ST_TextColumnCount::to_int(self : ST_TextColumnCount) -> Int {
  self.count
}

///|
/// XSD simple type ST_TextBulletStartAtNum — Part 1 §20.1.10.63. xsd:int in
/// [1, 32767].
pub struct ST_TextBulletStartAtNum {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_TextBulletStartAtNum::parse(
  s : String,
) -> ST_TextBulletStartAtNum raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextBulletStartAtNum", s)
  if v < 1 || v > 32767 {
    measure_violation("ST_TextBulletStartAtNum")
  }
  { value: v }
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
  self.value.to_string()
}

///|
pub fn ST_TextBulletStartAtNum::to_int(self : ST_TextBulletStartAtNum) -> Int {
  self.value
}

///|
/// XSD simple type ST_TextAutonumberScheme — Part 1 §20.1.10.61. xsd:token
/// enumeration of automatic numbering presets.
pub(all) enum ST_TextAutonumberScheme {
  /// §20.1.10.61 "alphaLcParenBoth"
  AlphaLcParenBoth
  /// §20.1.10.61 "alphaUcParenBoth"
  AlphaUcParenBoth
  /// §20.1.10.61 "alphaLcParenR"
  AlphaLcParenR
  /// §20.1.10.61 "alphaUcParenR"
  AlphaUcParenR
  /// §20.1.10.61 "alphaLcPeriod"
  AlphaLcPeriod
  /// §20.1.10.61 "alphaUcPeriod"
  AlphaUcPeriod
  /// §20.1.10.61 "arabicParenBoth"
  ArabicParenBoth
  /// §20.1.10.61 "arabicParenR"
  ArabicParenR
  /// §20.1.10.61 "arabicPeriod"
  ArabicPeriod
  /// §20.1.10.61 "arabicPlain"
  ArabicPlain
  /// §20.1.10.61 "romanLcParenBoth"
  RomanLcParenBoth
  /// §20.1.10.61 "romanUcParenBoth"
  RomanUcParenBoth
  /// §20.1.10.61 "romanLcParenR"
  RomanLcParenR
  /// §20.1.10.61 "romanUcParenR"
  RomanUcParenR
  /// §20.1.10.61 "romanLcPeriod"
  RomanLcPeriod
  /// §20.1.10.61 "romanUcPeriod"
  RomanUcPeriod
  /// §20.1.10.61 "circleNumDbPlain"
  CircleNumDbPlain
  /// §20.1.10.61 "circleNumWdBlackPlain"
  CircleNumWdBlackPlain
  /// §20.1.10.61 "circleNumWdWhitePlain"
  CircleNumWdWhitePlain
  /// §20.1.10.61 "arabicDbPeriod"
  ArabicDbPeriod
  /// §20.1.10.61 "arabicDbPlain"
  ArabicDbPlain
  /// §20.1.10.61 "ea1ChsPeriod"
  Ea1ChsPeriod
  /// §20.1.10.61 "ea1ChsPlain"
  Ea1ChsPlain
  /// §20.1.10.61 "ea1ChtPeriod"
  Ea1ChtPeriod
  /// §20.1.10.61 "ea1ChtPlain"
  Ea1ChtPlain
  /// §20.1.10.61 "ea1JpnChsDbPeriod"
  Ea1JpnChsDbPeriod
  /// §20.1.10.61 "ea1JpnKorPlain"
  Ea1JpnKorPlain
  /// §20.1.10.61 "ea1JpnKorPeriod"
  Ea1JpnKorPeriod
  /// §20.1.10.61 "arabic1Minus"
  Arabic1Minus
  /// §20.1.10.61 "arabic2Minus"
  Arabic2Minus
  /// §20.1.10.61 "hebrew2Minus"
  Hebrew2Minus
  /// §20.1.10.61 "thaiAlphaPeriod"
  ThaiAlphaPeriod
  /// §20.1.10.61 "thaiAlphaParenR"
  ThaiAlphaParenR
  /// §20.1.10.61 "thaiAlphaParenBoth"
  ThaiAlphaParenBoth
  /// §20.1.10.61 "thaiNumPeriod"
  ThaiNumPeriod
  /// §20.1.10.61 "thaiNumParenR"
  ThaiNumParenR
  /// §20.1.10.61 "thaiNumParenBoth"
  ThaiNumParenBoth
  /// §20.1.10.61 "hindiAlphaPeriod"
  HindiAlphaPeriod
  /// §20.1.10.61 "hindiNumPeriod"
  HindiNumPeriod
  /// §20.1.10.61 "hindiNumParenR"
  HindiNumParenR
  /// §20.1.10.61 "hindiAlpha1Period"
  HindiAlpha1Period
} derive(Eq, Debug)

///|
pub fn ST_TextAutonumberScheme::parse(
  s : String,
) -> ST_TextAutonumberScheme raise SchemaViolation {
  match s {
    "alphaLcParenBoth" => AlphaLcParenBoth
    "alphaUcParenBoth" => AlphaUcParenBoth
    "alphaLcParenR" => AlphaLcParenR
    "alphaUcParenR" => AlphaUcParenR
    "alphaLcPeriod" => AlphaLcPeriod
    "alphaUcPeriod" => AlphaUcPeriod
    "arabicParenBoth" => ArabicParenBoth
    "arabicParenR" => ArabicParenR
    "arabicPeriod" => ArabicPeriod
    "arabicPlain" => ArabicPlain
    "romanLcParenBoth" => RomanLcParenBoth
    "romanUcParenBoth" => RomanUcParenBoth
    "romanLcParenR" => RomanLcParenR
    "romanUcParenR" => RomanUcParenR
    "romanLcPeriod" => RomanLcPeriod
    "romanUcPeriod" => RomanUcPeriod
    "circleNumDbPlain" => CircleNumDbPlain
    "circleNumWdBlackPlain" => CircleNumWdBlackPlain
    "circleNumWdWhitePlain" => CircleNumWdWhitePlain
    "arabicDbPeriod" => ArabicDbPeriod
    "arabicDbPlain" => ArabicDbPlain
    "ea1ChsPeriod" => Ea1ChsPeriod
    "ea1ChsPlain" => Ea1ChsPlain
    "ea1ChtPeriod" => Ea1ChtPeriod
    "ea1ChtPlain" => Ea1ChtPlain
    "ea1JpnChsDbPeriod" => Ea1JpnChsDbPeriod
    "ea1JpnKorPlain" => Ea1JpnKorPlain
    "ea1JpnKorPeriod" => Ea1JpnKorPeriod
    "arabic1Minus" => Arabic1Minus
    "arabic2Minus" => Arabic2Minus
    "hebrew2Minus" => Hebrew2Minus
    "thaiAlphaPeriod" => ThaiAlphaPeriod
    "thaiAlphaParenR" => ThaiAlphaParenR
    "thaiAlphaParenBoth" => ThaiAlphaParenBoth
    "thaiNumPeriod" => ThaiNumPeriod
    "thaiNumParenR" => ThaiNumParenR
    "thaiNumParenBoth" => ThaiNumParenBoth
    "hindiAlphaPeriod" => HindiAlphaPeriod
    "hindiNumPeriod" => HindiNumPeriod
    "hindiNumParenR" => HindiNumParenR
    "hindiAlpha1Period" => HindiAlpha1Period
    _ => enum_violation("ST_TextAutonumberScheme")
  }
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
  match self {
    AlphaLcParenBoth => "alphaLcParenBoth"
    AlphaUcParenBoth => "alphaUcParenBoth"
    AlphaLcParenR => "alphaLcParenR"
    AlphaUcParenR => "alphaUcParenR"
    AlphaLcPeriod => "alphaLcPeriod"
    AlphaUcPeriod => "alphaUcPeriod"
    ArabicParenBoth => "arabicParenBoth"
    ArabicParenR => "arabicParenR"
    ArabicPeriod => "arabicPeriod"
    ArabicPlain => "arabicPlain"
    RomanLcParenBoth => "romanLcParenBoth"
    RomanUcParenBoth => "romanUcParenBoth"
    RomanLcParenR => "romanLcParenR"
    RomanUcParenR => "romanUcParenR"
    RomanLcPeriod => "romanLcPeriod"
    RomanUcPeriod => "romanUcPeriod"
    CircleNumDbPlain => "circleNumDbPlain"
    CircleNumWdBlackPlain => "circleNumWdBlackPlain"
    CircleNumWdWhitePlain => "circleNumWdWhitePlain"
    ArabicDbPeriod => "arabicDbPeriod"
    ArabicDbPlain => "arabicDbPlain"
    Ea1ChsPeriod => "ea1ChsPeriod"
    Ea1ChsPlain => "ea1ChsPlain"
    Ea1ChtPeriod => "ea1ChtPeriod"
    Ea1ChtPlain => "ea1ChtPlain"
    Ea1JpnChsDbPeriod => "ea1JpnChsDbPeriod"
    Ea1JpnKorPlain => "ea1JpnKorPlain"
    Ea1JpnKorPeriod => "ea1JpnKorPeriod"
    Arabic1Minus => "arabic1Minus"
    Arabic2Minus => "arabic2Minus"
    Hebrew2Minus => "hebrew2Minus"
    ThaiAlphaPeriod => "thaiAlphaPeriod"
    ThaiAlphaParenR => "thaiAlphaParenR"
    ThaiAlphaParenBoth => "thaiAlphaParenBoth"
    ThaiNumPeriod => "thaiNumPeriod"
    ThaiNumParenR => "thaiNumParenR"
    ThaiNumParenBoth => "thaiNumParenBoth"
    HindiAlphaPeriod => "hindiAlphaPeriod"
    HindiNumPeriod => "hindiNumPeriod"
    HindiNumParenR => "hindiNumParenR"
    HindiAlpha1Period => "hindiAlpha1Period"
  }
}

///|
/// XSD simple type ST_TextBulletSizePercent — Part 1 §20.1.10.62. xsd:string
/// pattern `0*((2[5-9])|([3-9][0-9])|([1-3][0-9][0-9])|400)%`. The pattern
/// is strictly integer-percent in [25, 400]. Stored as the integer percent
/// value.
pub struct ST_TextBulletSizePercent {
  percent : Int
} derive(Eq, Debug)

///|
pub fn ST_TextBulletSizePercent::parse(
  s : String,
) -> ST_TextBulletSizePercent raise SchemaViolation {
  let percent = parse_bullet_size_percent(s)
  { percent, }
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
  self.percent.to_string() + "%"
}

///|
pub fn ST_TextBulletSizePercent::to_int(self : ST_TextBulletSizePercent) -> Int {
  self.percent
}

///|
/// XSD simple type ST_TextBulletSize — Part 1 §20.1.10.87 and Part 4
/// §A.4.1. Union of ST_TextBulletSizePercent (`<int>%` lexical) and the
/// transitional ST_TextBulletSizeDecimal (xsd:int in [25000, 400000],
/// 1000ths of a percent). Stored as 1000ths-of-percent so both branches
/// share a single integer representation.
pub struct ST_TextBulletSize {
  thousandths : Int
} derive(Eq, Debug)

///|
pub fn ST_TextBulletSize::parse(
  s : String,
) -> ST_TextBulletSize raise SchemaViolation {
  let thousandths = if s.length() > 0 &&
    s.unsafe_substring(start=s.length() - 1, end=s.length()) == "%" {
    let percent = parse_bullet_size_percent(s)
    percent * 1000
  } else {
    if !is_signed_digits(s) {
      measure_violation("ST_TextBulletSize")
    }
    let v = parse_int_lexical(s)
    if v < 25000 || v > 400000 {
      measure_violation("ST_TextBulletSize")
    }
    v
  }
  { thousandths, }
}

///|
pub fn ST_TextBulletSize::new(
  s : String,
) -> ST_TextBulletSize raise SchemaViolation {
  ST_TextBulletSize::parse(s)
}

///|
pub fn ST_TextBulletSize::to_string(self : ST_TextBulletSize) -> String {
  self.thousandths.to_string()
}

///|
pub fn ST_TextBulletSize::thousandths_of_percent(
  self : ST_TextBulletSize,
) -> Int {
  self.thousandths
}

///|
/// Decode "<int>%" for ST_TextBulletSizePercent / ST_TextBulletSize. The
/// pattern `0*((2[5-9])|([3-9][0-9])|([1-3][0-9][0-9])|400)%` accepts
/// integer percents in [25, 400] (with optional leading zeros).
fn parse_bullet_size_percent(s : String) -> Int raise SchemaViolation {
  if s.length() < 2 ||
    s.unsafe_substring(start=s.length() - 1, end=s.length()) != "%" {
    measure_violation("ST_TextBulletSizePercent")
  }
  let digits = s.unsafe_substring(start=0, end=s.length() - 1)
  if digits.length() == 0 || !all_digits(digits) {
    measure_violation("ST_TextBulletSizePercent")
  }
  let value = parse_int_digits(digits)
  if value < 25 || value > 400 {
    measure_violation("ST_TextBulletSizePercent")
  }
  value
}

///|
/// XSD simple type ST_TextPoint — Part 1 §20.1.10.74. Union of
/// ST_TextPointUnqualified (xsd:int in [-400000, 400000]) and
/// ST_UniversalMeasure.
pub(all) enum ST_TextPoint {
  /// §20.1.10.74 hundredths-of-point integer branch.
  TextPointUnq(ST_TextPointUnqualified)
  /// §20.1.10.74 universal-measure branch.
  TextPointMeasure(ST_UniversalMeasure)
} derive(Eq, Debug)

///|
pub fn ST_TextPoint::parse(s : String) -> ST_TextPoint raise SchemaViolation {
  if is_universal_measure(s) {
    TextPointMeasure(ST_UniversalMeasure::new(s))
  } else {
    TextPointUnq(ST_TextPointUnqualified::parse(s))
  }
}

///|
pub fn ST_TextPoint::new(s : String) -> ST_TextPoint raise SchemaViolation {
  ST_TextPoint::parse(s)
}

///|
pub fn ST_TextPoint::to_string(self : ST_TextPoint) -> String {
  match self {
    TextPointUnq(value) => value.to_string()
    TextPointMeasure(value) => value.to_string()
  }
}

///|
/// XSD simple type ST_TextPointUnqualified — Part 1 §20.1.10.75. xsd:int in
/// [-400000, 400000] (hundredths of a point).
pub struct ST_TextPointUnqualified {
  hundredths_of_point : Int
} derive(Eq, Debug)

///|
pub fn ST_TextPointUnqualified::parse(
  s : String,
) -> ST_TextPointUnqualified raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextPointUnqualified", s)
  if v < -400000 || v > 400000 {
    measure_violation("ST_TextPointUnqualified")
  }
  { hundredths_of_point: v }
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
  self.hundredths_of_point.to_string()
}

///|
pub fn ST_TextPointUnqualified::hundredths_of_point(
  self : ST_TextPointUnqualified,
) -> Int {
  self.hundredths_of_point
}

///|
/// XSD simple type ST_TextNonNegativePoint — Part 1 §20.1.10.73. xsd:int in
/// [0, 400000].
pub struct ST_TextNonNegativePoint {
  hundredths_of_point : Int
} derive(Eq, Debug)

///|
pub fn ST_TextNonNegativePoint::parse(
  s : String,
) -> ST_TextNonNegativePoint raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextNonNegativePoint", s)
  if v < 0 || v > 400000 {
    measure_violation("ST_TextNonNegativePoint")
  }
  { hundredths_of_point: v }
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
  self.hundredths_of_point.to_string()
}

///|
pub fn ST_TextNonNegativePoint::hundredths_of_point(
  self : ST_TextNonNegativePoint,
) -> Int {
  self.hundredths_of_point
}

///|
/// XSD simple type ST_TextUnderlineType — Part 1 §20.1.10.82.
pub(all) enum ST_TextUnderlineType {
  /// §20.1.10.82 "none"
  UnderlineNone
  /// §20.1.10.82 "words"
  UnderlineWords
  /// §20.1.10.82 "sng"
  UnderlineSng
  /// §20.1.10.82 "dbl"
  UnderlineDbl
  /// §20.1.10.82 "heavy"
  UnderlineHeavy
  /// §20.1.10.82 "dotted"
  UnderlineDotted
  /// §20.1.10.82 "dottedHeavy"
  UnderlineDottedHeavy
  /// §20.1.10.82 "dash"
  UnderlineDash
  /// §20.1.10.82 "dashHeavy"
  UnderlineDashHeavy
  /// §20.1.10.82 "dashLong"
  UnderlineDashLong
  /// §20.1.10.82 "dashLongHeavy"
  UnderlineDashLongHeavy
  /// §20.1.10.82 "dotDash"
  UnderlineDotDash
  /// §20.1.10.82 "dotDashHeavy"
  UnderlineDotDashHeavy
  /// §20.1.10.82 "dotDotDash"
  UnderlineDotDotDash
  /// §20.1.10.82 "dotDotDashHeavy"
  UnderlineDotDotDashHeavy
  /// §20.1.10.82 "wavy"
  UnderlineWavy
  /// §20.1.10.82 "wavyHeavy"
  UnderlineWavyHeavy
  /// §20.1.10.82 "wavyDbl"
  UnderlineWavyDbl
} derive(Eq, Debug)

///|
pub fn ST_TextUnderlineType::parse(
  s : String,
) -> ST_TextUnderlineType raise SchemaViolation {
  match s {
    "none" => UnderlineNone
    "words" => UnderlineWords
    "sng" => UnderlineSng
    "dbl" => UnderlineDbl
    "heavy" => UnderlineHeavy
    "dotted" => UnderlineDotted
    "dottedHeavy" => UnderlineDottedHeavy
    "dash" => UnderlineDash
    "dashHeavy" => UnderlineDashHeavy
    "dashLong" => UnderlineDashLong
    "dashLongHeavy" => UnderlineDashLongHeavy
    "dotDash" => UnderlineDotDash
    "dotDashHeavy" => UnderlineDotDashHeavy
    "dotDotDash" => UnderlineDotDotDash
    "dotDotDashHeavy" => UnderlineDotDotDashHeavy
    "wavy" => UnderlineWavy
    "wavyHeavy" => UnderlineWavyHeavy
    "wavyDbl" => UnderlineWavyDbl
    _ => enum_violation("ST_TextUnderlineType")
  }
}

///|
pub fn ST_TextUnderlineType::new(
  s : String,
) -> ST_TextUnderlineType raise SchemaViolation {
  ST_TextUnderlineType::parse(s)
}

///|
pub fn ST_TextUnderlineType::to_string(self : ST_TextUnderlineType) -> String {
  match self {
    UnderlineNone => "none"
    UnderlineWords => "words"
    UnderlineSng => "sng"
    UnderlineDbl => "dbl"
    UnderlineHeavy => "heavy"
    UnderlineDotted => "dotted"
    UnderlineDottedHeavy => "dottedHeavy"
    UnderlineDash => "dash"
    UnderlineDashHeavy => "dashHeavy"
    UnderlineDashLong => "dashLong"
    UnderlineDashLongHeavy => "dashLongHeavy"
    UnderlineDotDash => "dotDash"
    UnderlineDotDashHeavy => "dotDashHeavy"
    UnderlineDotDotDash => "dotDotDash"
    UnderlineDotDotDashHeavy => "dotDotDashHeavy"
    UnderlineWavy => "wavy"
    UnderlineWavyHeavy => "wavyHeavy"
    UnderlineWavyDbl => "wavyDbl"
  }
}

///|
/// XSD simple type ST_TextStrikeType — Part 1 §20.1.10.79.
pub(all) enum ST_TextStrikeType {
  /// §20.1.10.79 "noStrike"
  NoStrike
  /// §20.1.10.79 "sngStrike"
  SngStrike
  /// §20.1.10.79 "dblStrike"
  DblStrike
} derive(Eq, Debug)

///|
pub fn ST_TextStrikeType::parse(
  s : String,
) -> ST_TextStrikeType raise SchemaViolation {
  match s {
    "noStrike" => NoStrike
    "sngStrike" => SngStrike
    "dblStrike" => DblStrike
    _ => enum_violation("ST_TextStrikeType")
  }
}

///|
pub fn ST_TextStrikeType::new(
  s : String,
) -> ST_TextStrikeType raise SchemaViolation {
  ST_TextStrikeType::parse(s)
}

///|
pub fn ST_TextStrikeType::to_string(self : ST_TextStrikeType) -> String {
  match self {
    NoStrike => "noStrike"
    SngStrike => "sngStrike"
    DblStrike => "dblStrike"
  }
}

///|
/// XSD simple type ST_TextCapsType — Part 1 §20.1.10.64.
pub(all) enum ST_TextCapsType {
  /// §20.1.10.64 "none"
  CapsNone
  /// §20.1.10.64 "small"
  CapsSmall
  /// §20.1.10.64 "all"
  CapsAll
} derive(Eq, Debug)

///|
pub fn ST_TextCapsType::parse(
  s : String,
) -> ST_TextCapsType raise SchemaViolation {
  match s {
    "none" => CapsNone
    "small" => CapsSmall
    "all" => CapsAll
    _ => enum_violation("ST_TextCapsType")
  }
}

///|
pub fn ST_TextCapsType::new(
  s : String,
) -> ST_TextCapsType raise SchemaViolation {
  ST_TextCapsType::parse(s)
}

///|
pub fn ST_TextCapsType::to_string(self : ST_TextCapsType) -> String {
  match self {
    CapsNone => "none"
    CapsSmall => "small"
    CapsAll => "all"
  }
}

///|
/// XSD simple type ST_TextSpacingPoint — Part 1 §20.1.10.78. xsd:int in
/// [0, 158400].
pub struct ST_TextSpacingPoint {
  hundredths_of_point : Int
} derive(Eq, Debug)

///|
pub fn ST_TextSpacingPoint::parse(
  s : String,
) -> ST_TextSpacingPoint raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextSpacingPoint", s)
  if v < 0 || v > 158400 {
    measure_violation("ST_TextSpacingPoint")
  }
  { hundredths_of_point: v }
}

///|
pub fn ST_TextSpacingPoint::new(
  s : String,
) -> ST_TextSpacingPoint raise SchemaViolation {
  ST_TextSpacingPoint::parse(s)
}

///|
pub fn ST_TextSpacingPoint::to_string(self : ST_TextSpacingPoint) -> String {
  self.hundredths_of_point.to_string()
}

///|
pub fn ST_TextSpacingPoint::hundredths_of_point(
  self : ST_TextSpacingPoint,
) -> Int {
  self.hundredths_of_point
}

///|
/// XSD simple type ST_TextMargin — Part 1 §20.1.10.72. Restriction of
/// ST_Coordinate32Unqualified in [0, 51 206 400].
pub struct ST_TextMargin {
  emu : Int
} derive(Eq, Debug)

///|
pub fn ST_TextMargin::parse(s : String) -> ST_TextMargin raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextMargin", s)
  if v < 0 || v > 51206400 {
    measure_violation("ST_TextMargin")
  }
  { emu: v }
}

///|
pub fn ST_TextMargin::new(s : String) -> ST_TextMargin raise SchemaViolation {
  ST_TextMargin::parse(s)
}

///|
pub fn ST_TextMargin::to_string(self : ST_TextMargin) -> String {
  self.emu.to_string()
}

///|
pub fn ST_TextMargin::to_int(self : ST_TextMargin) -> Int {
  self.emu
}

///|
/// XSD simple type ST_TextIndent — Part 1 §20.1.10.70. Restriction of
/// ST_Coordinate32Unqualified in [-51 206 400, 51 206 400].
pub struct ST_TextIndent {
  emu : Int
} derive(Eq, Debug)

///|
pub fn ST_TextIndent::parse(s : String) -> ST_TextIndent raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextIndent", s)
  if v < -51206400 || v > 51206400 {
    measure_violation("ST_TextIndent")
  }
  { emu: v }
}

///|
pub fn ST_TextIndent::new(s : String) -> ST_TextIndent raise SchemaViolation {
  ST_TextIndent::parse(s)
}

///|
pub fn ST_TextIndent::to_string(self : ST_TextIndent) -> String {
  self.emu.to_string()
}

///|
pub fn ST_TextIndent::to_int(self : ST_TextIndent) -> Int {
  self.emu
}

///|
/// XSD simple type ST_TextTabAlignType — Part 1 §20.1.10.80.
pub(all) enum ST_TextTabAlignType {
  /// §20.1.10.80 "l"
  TabAlignLeft
  /// §20.1.10.80 "ctr"
  TabAlignCenter
  /// §20.1.10.80 "r"
  TabAlignRight
  /// §20.1.10.80 "dec"
  TabAlignDecimal
} derive(Eq, Debug)

///|
pub fn ST_TextTabAlignType::parse(
  s : String,
) -> ST_TextTabAlignType raise SchemaViolation {
  match s {
    "l" => TabAlignLeft
    "ctr" => TabAlignCenter
    "r" => TabAlignRight
    "dec" => TabAlignDecimal
    _ => enum_violation("ST_TextTabAlignType")
  }
}

///|
pub fn ST_TextTabAlignType::new(
  s : String,
) -> ST_TextTabAlignType raise SchemaViolation {
  ST_TextTabAlignType::parse(s)
}

///|
pub fn ST_TextTabAlignType::to_string(self : ST_TextTabAlignType) -> String {
  match self {
    TabAlignLeft => "l"
    TabAlignCenter => "ctr"
    TabAlignRight => "r"
    TabAlignDecimal => "dec"
  }
}

///|
/// XSD simple type ST_TextAlignType — Part 1 §20.1.10.59.
pub(all) enum ST_TextAlignType {
  /// §20.1.10.59 "l"
  AlignLeft
  /// §20.1.10.59 "ctr"
  AlignCenter
  /// §20.1.10.59 "r"
  AlignRight
  /// §20.1.10.59 "just"
  AlignJustified
  /// §20.1.10.59 "justLow"
  AlignJustifiedLow
  /// §20.1.10.59 "dist"
  AlignDistributed
  /// §20.1.10.59 "thaiDist"
  AlignThaiDistributed
} derive(Eq, Debug)

///|
pub fn ST_TextAlignType::parse(
  s : String,
) -> ST_TextAlignType raise SchemaViolation {
  match s {
    "l" => AlignLeft
    "ctr" => AlignCenter
    "r" => AlignRight
    "just" => AlignJustified
    "justLow" => AlignJustifiedLow
    "dist" => AlignDistributed
    "thaiDist" => AlignThaiDistributed
    _ => enum_violation("ST_TextAlignType")
  }
}

///|
pub fn ST_TextAlignType::new(
  s : String,
) -> ST_TextAlignType raise SchemaViolation {
  ST_TextAlignType::parse(s)
}

///|
pub fn ST_TextAlignType::to_string(self : ST_TextAlignType) -> String {
  match self {
    AlignLeft => "l"
    AlignCenter => "ctr"
    AlignRight => "r"
    AlignJustified => "just"
    AlignJustifiedLow => "justLow"
    AlignDistributed => "dist"
    AlignThaiDistributed => "thaiDist"
  }
}

///|
/// XSD simple type ST_TextIndentLevelType — Part 1 §20.1.10.71. xsd:int in
/// [0, 8].
pub struct ST_TextIndentLevelType {
  level : Int
} derive(Eq, Debug)

///|
pub fn ST_TextIndentLevelType::parse(
  s : String,
) -> ST_TextIndentLevelType raise SchemaViolation {
  let v = parse_int_or_violate("ST_TextIndentLevelType", s)
  if v < 0 || v > 8 {
    measure_violation("ST_TextIndentLevelType")
  }
  { level: v }
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
  self.level.to_string()
}

///|
pub fn ST_TextIndentLevelType::to_int(self : ST_TextIndentLevelType) -> Int {
  self.level
}

///|
/// XSD simple type ST_RectAlignment — Part 1 §20.1.10.53. Nine-position
/// alignment grid.
pub(all) enum ST_RectAlignment {
  /// §20.1.10.53 "tl"
  RectTopLeft
  /// §20.1.10.53 "t"
  RectTop
  /// §20.1.10.53 "tr"
  RectTopRight
  /// §20.1.10.53 "l"
  RectLeft
  /// §20.1.10.53 "ctr"
  RectCenter
  /// §20.1.10.53 "r"
  RectRight
  /// §20.1.10.53 "bl"
  RectBottomLeft
  /// §20.1.10.53 "b"
  RectBottom
  /// §20.1.10.53 "br"
  RectBottomRight
} derive(Eq, Debug)

///|
pub fn ST_RectAlignment::parse(
  s : String,
) -> ST_RectAlignment raise SchemaViolation {
  match s {
    "tl" => RectTopLeft
    "t" => RectTop
    "tr" => RectTopRight
    "l" => RectLeft
    "ctr" => RectCenter
    "r" => RectRight
    "bl" => RectBottomLeft
    "b" => RectBottom
    "br" => RectBottomRight
    _ => enum_violation("ST_RectAlignment")
  }
}

///|
pub fn ST_RectAlignment::new(
  s : String,
) -> ST_RectAlignment raise SchemaViolation {
  ST_RectAlignment::parse(s)
}

///|
pub fn ST_RectAlignment::to_string(self : ST_RectAlignment) -> String {
  match self {
    RectTopLeft => "tl"
    RectTop => "t"
    RectTopRight => "tr"
    RectLeft => "l"
    RectCenter => "ctr"
    RectRight => "r"
    RectBottomLeft => "bl"
    RectBottom => "b"
    RectBottomRight => "br"
  }
}

///|
/// XSD simple type ST_PathShadeType — Part 1 §20.1.10.38.
pub(all) enum ST_PathShadeType {
  /// §20.1.10.38 "shape"
  PathShape
  /// §20.1.10.38 "circle"
  PathCircle
  /// §20.1.10.38 "rect"
  PathRect
} derive(Eq, Debug)

///|
pub fn ST_PathShadeType::parse(
  s : String,
) -> ST_PathShadeType raise SchemaViolation {
  match s {
    "shape" => PathShape
    "circle" => PathCircle
    "rect" => PathRect
    _ => enum_violation("ST_PathShadeType")
  }
}

///|
pub fn ST_PathShadeType::new(
  s : String,
) -> ST_PathShadeType raise SchemaViolation {
  ST_PathShadeType::parse(s)
}

///|
pub fn ST_PathShadeType::to_string(self : ST_PathShadeType) -> String {
  match self {
    PathShape => "shape"
    PathCircle => "circle"
    PathRect => "rect"
  }
}

///|
/// XSD simple type ST_TileFlipMode — Part 1 §20.1.10.86.
pub(all) enum ST_TileFlipMode {
  /// §20.1.10.86 "none"
  TileFlipNone
  /// §20.1.10.86 "x"
  TileFlipX
  /// §20.1.10.86 "y"
  TileFlipY
  /// §20.1.10.86 "xy"
  TileFlipXY
} derive(Eq, Debug)

///|
pub fn ST_TileFlipMode::parse(
  s : String,
) -> ST_TileFlipMode raise SchemaViolation {
  match s {
    "none" => TileFlipNone
    "x" => TileFlipX
    "y" => TileFlipY
    "xy" => TileFlipXY
    _ => enum_violation("ST_TileFlipMode")
  }
}

///|
pub fn ST_TileFlipMode::new(
  s : String,
) -> ST_TileFlipMode raise SchemaViolation {
  ST_TileFlipMode::parse(s)
}

///|
pub fn ST_TileFlipMode::to_string(self : ST_TileFlipMode) -> String {
  match self {
    TileFlipNone => "none"
    TileFlipX => "x"
    TileFlipY => "y"
    TileFlipXY => "xy"
  }
}

///|
/// XSD simple type ST_PresetPatternVal — Part 1 §20.1.10.51. Enumeration
/// of preset fill patterns.
pub(all) enum ST_PresetPatternVal {
  /// §20.1.10.51 "pct5"
  Pct5
  /// §20.1.10.51 "pct10"
  Pct10
  /// §20.1.10.51 "pct20"
  Pct20
  /// §20.1.10.51 "pct25"
  Pct25
  /// §20.1.10.51 "pct30"
  Pct30
  /// §20.1.10.51 "pct40"
  Pct40
  /// §20.1.10.51 "pct50"
  Pct50
  /// §20.1.10.51 "pct60"
  Pct60
  /// §20.1.10.51 "pct70"
  Pct70
  /// §20.1.10.51 "pct75"
  Pct75
  /// §20.1.10.51 "pct80"
  Pct80
  /// §20.1.10.51 "pct90"
  Pct90
  /// §20.1.10.51 "horz"
  PatHorz
  /// §20.1.10.51 "vert"
  PatVert
  /// §20.1.10.51 "ltHorz"
  LtHorz
  /// §20.1.10.51 "ltVert"
  LtVert
  /// §20.1.10.51 "dkHorz"
  DkHorz
  /// §20.1.10.51 "dkVert"
  DkVert
  /// §20.1.10.51 "narHorz"
  NarHorz
  /// §20.1.10.51 "narVert"
  NarVert
  /// §20.1.10.51 "dashHorz"
  DashHorz
  /// §20.1.10.51 "dashVert"
  DashVert
  /// §20.1.10.51 "cross"
  Cross
  /// §20.1.10.51 "dnDiag"
  DnDiag
  /// §20.1.10.51 "upDiag"
  UpDiag
  /// §20.1.10.51 "ltDnDiag"
  LtDnDiag
  /// §20.1.10.51 "ltUpDiag"
  LtUpDiag
  /// §20.1.10.51 "dkDnDiag"
  DkDnDiag
  /// §20.1.10.51 "dkUpDiag"
  DkUpDiag
  /// §20.1.10.51 "wdDnDiag"
  WdDnDiag
  /// §20.1.10.51 "wdUpDiag"
  WdUpDiag
  /// §20.1.10.51 "dashDnDiag"
  DashDnDiag
  /// §20.1.10.51 "dashUpDiag"
  DashUpDiag
  /// §20.1.10.51 "diagCross"
  DiagCross
  /// §20.1.10.51 "smCheck"
  SmCheck
  /// §20.1.10.51 "lgCheck"
  LgCheck
  /// §20.1.10.51 "smGrid"
  SmGrid
  /// §20.1.10.51 "lgGrid"
  LgGrid
  /// §20.1.10.51 "dotGrid"
  DotGrid
  /// §20.1.10.51 "smConfetti"
  SmConfetti
  /// §20.1.10.51 "lgConfetti"
  LgConfetti
  /// §20.1.10.51 "horzBrick"
  HorzBrick
  /// §20.1.10.51 "diagBrick"
  DiagBrick
  /// §20.1.10.51 "solidDmnd"
  SolidDmnd
  /// §20.1.10.51 "openDmnd"
  OpenDmnd
  /// §20.1.10.51 "dotDmnd"
  DotDmnd
  /// §20.1.10.51 "plaid"
  Plaid
  /// §20.1.10.51 "sphere"
  Sphere
  /// §20.1.10.51 "weave"
  Weave
  /// §20.1.10.51 "divot"
  Divot
  /// §20.1.10.51 "shingle"
  Shingle
  /// §20.1.10.51 "wave"
  Wave
  /// §20.1.10.51 "trellis"
  Trellis
  /// §20.1.10.51 "zigZag"
  ZigZag
} derive(Eq, Debug)

///|
pub fn ST_PresetPatternVal::parse(
  s : String,
) -> ST_PresetPatternVal raise SchemaViolation {
  match s {
    "pct5" => Pct5
    "pct10" => Pct10
    "pct20" => Pct20
    "pct25" => Pct25
    "pct30" => Pct30
    "pct40" => Pct40
    "pct50" => Pct50
    "pct60" => Pct60
    "pct70" => Pct70
    "pct75" => Pct75
    "pct80" => Pct80
    "pct90" => Pct90
    "horz" => PatHorz
    "vert" => PatVert
    "ltHorz" => LtHorz
    "ltVert" => LtVert
    "dkHorz" => DkHorz
    "dkVert" => DkVert
    "narHorz" => NarHorz
    "narVert" => NarVert
    "dashHorz" => DashHorz
    "dashVert" => DashVert
    "cross" => Cross
    "dnDiag" => DnDiag
    "upDiag" => UpDiag
    "ltDnDiag" => LtDnDiag
    "ltUpDiag" => LtUpDiag
    "dkDnDiag" => DkDnDiag
    "dkUpDiag" => DkUpDiag
    "wdDnDiag" => WdDnDiag
    "wdUpDiag" => WdUpDiag
    "dashDnDiag" => DashDnDiag
    "dashUpDiag" => DashUpDiag
    "diagCross" => DiagCross
    "smCheck" => SmCheck
    "lgCheck" => LgCheck
    "smGrid" => SmGrid
    "lgGrid" => LgGrid
    "dotGrid" => DotGrid
    "smConfetti" => SmConfetti
    "lgConfetti" => LgConfetti
    "horzBrick" => HorzBrick
    "diagBrick" => DiagBrick
    "solidDmnd" => SolidDmnd
    "openDmnd" => OpenDmnd
    "dotDmnd" => DotDmnd
    "plaid" => Plaid
    "sphere" => Sphere
    "weave" => Weave
    "divot" => Divot
    "shingle" => Shingle
    "wave" => Wave
    "trellis" => Trellis
    "zigZag" => ZigZag
    _ => enum_violation("ST_PresetPatternVal")
  }
}

///|
pub fn ST_PresetPatternVal::new(
  s : String,
) -> ST_PresetPatternVal raise SchemaViolation {
  ST_PresetPatternVal::parse(s)
}

///|
pub fn ST_PresetPatternVal::to_string(self : ST_PresetPatternVal) -> String {
  match self {
    Pct5 => "pct5"
    Pct10 => "pct10"
    Pct20 => "pct20"
    Pct25 => "pct25"
    Pct30 => "pct30"
    Pct40 => "pct40"
    Pct50 => "pct50"
    Pct60 => "pct60"
    Pct70 => "pct70"
    Pct75 => "pct75"
    Pct80 => "pct80"
    Pct90 => "pct90"
    PatHorz => "horz"
    PatVert => "vert"
    LtHorz => "ltHorz"
    LtVert => "ltVert"
    DkHorz => "dkHorz"
    DkVert => "dkVert"
    NarHorz => "narHorz"
    NarVert => "narVert"
    DashHorz => "dashHorz"
    DashVert => "dashVert"
    Cross => "cross"
    DnDiag => "dnDiag"
    UpDiag => "upDiag"
    LtDnDiag => "ltDnDiag"
    LtUpDiag => "ltUpDiag"
    DkDnDiag => "dkDnDiag"
    DkUpDiag => "dkUpDiag"
    WdDnDiag => "wdDnDiag"
    WdUpDiag => "wdUpDiag"
    DashDnDiag => "dashDnDiag"
    DashUpDiag => "dashUpDiag"
    DiagCross => "diagCross"
    SmCheck => "smCheck"
    LgCheck => "lgCheck"
    SmGrid => "smGrid"
    LgGrid => "lgGrid"
    DotGrid => "dotGrid"
    SmConfetti => "smConfetti"
    LgConfetti => "lgConfetti"
    HorzBrick => "horzBrick"
    DiagBrick => "diagBrick"
    SolidDmnd => "solidDmnd"
    OpenDmnd => "openDmnd"
    DotDmnd => "dotDmnd"
    Plaid => "plaid"
    Sphere => "sphere"
    Weave => "weave"
    Divot => "divot"
    Shingle => "shingle"
    Wave => "wave"
    Trellis => "trellis"
    ZigZag => "zigZag"
  }
}

///|
/// XSD simple type ST_LineCap — Part 1 §20.1.10.31.
pub(all) enum ST_LineCap {
  /// §20.1.10.31 "rnd"
  CapRound
  /// §20.1.10.31 "sq"
  CapSquare
  /// §20.1.10.31 "flat"
  CapFlat
} derive(Eq, Debug)

///|
pub fn ST_LineCap::parse(s : String) -> ST_LineCap raise SchemaViolation {
  match s {
    "rnd" => CapRound
    "sq" => CapSquare
    "flat" => CapFlat
    _ => enum_violation("ST_LineCap")
  }
}

///|
pub fn ST_LineCap::new(s : String) -> ST_LineCap raise SchemaViolation {
  ST_LineCap::parse(s)
}

///|
pub fn ST_LineCap::to_string(self : ST_LineCap) -> String {
  match self {
    CapRound => "rnd"
    CapSquare => "sq"
    CapFlat => "flat"
  }
}

///|
/// XSD simple type ST_CompoundLine — Part 1 §20.1.10.15.
pub(all) enum ST_CompoundLine {
  /// §20.1.10.15 "sng"
  CompoundSng
  /// §20.1.10.15 "dbl"
  CompoundDbl
  /// §20.1.10.15 "thickThin"
  CompoundThickThin
  /// §20.1.10.15 "thinThick"
  CompoundThinThick
  /// §20.1.10.15 "tri"
  CompoundTri
} derive(Eq, Debug)

///|
pub fn ST_CompoundLine::parse(
  s : String,
) -> ST_CompoundLine raise SchemaViolation {
  match s {
    "sng" => CompoundSng
    "dbl" => CompoundDbl
    "thickThin" => CompoundThickThin
    "thinThick" => CompoundThinThick
    "tri" => CompoundTri
    _ => enum_violation("ST_CompoundLine")
  }
}

///|
pub fn ST_CompoundLine::new(
  s : String,
) -> ST_CompoundLine raise SchemaViolation {
  ST_CompoundLine::parse(s)
}

///|
pub fn ST_CompoundLine::to_string(self : ST_CompoundLine) -> String {
  match self {
    CompoundSng => "sng"
    CompoundDbl => "dbl"
    CompoundThickThin => "thickThin"
    CompoundThinThick => "thinThick"
    CompoundTri => "tri"
  }
}

///|
/// XSD simple type ST_PenAlignment — Part 1 §20.1.10.39.
pub(all) enum ST_PenAlignment {
  /// §20.1.10.39 "ctr"
  PenCenter
  /// §20.1.10.39 "in"
  PenInset
} derive(Eq, Debug)

///|
pub fn ST_PenAlignment::parse(
  s : String,
) -> ST_PenAlignment raise SchemaViolation {
  match s {
    "ctr" => PenCenter
    "in" => PenInset
    _ => enum_violation("ST_PenAlignment")
  }
}

///|
pub fn ST_PenAlignment::new(
  s : String,
) -> ST_PenAlignment raise SchemaViolation {
  ST_PenAlignment::parse(s)
}

///|
pub fn ST_PenAlignment::to_string(self : ST_PenAlignment) -> String {
  match self {
    PenCenter => "ctr"
    PenInset => "in"
  }
}

///|
/// XSD simple type ST_LineEndType — Part 1 §20.1.10.33.
pub(all) enum ST_LineEndType {
  /// §20.1.10.33 "none"
  LineEndNone
  /// §20.1.10.33 "triangle"
  LineEndTriangle
  /// §20.1.10.33 "stealth"
  LineEndStealth
  /// §20.1.10.33 "diamond"
  LineEndDiamond
  /// §20.1.10.33 "oval"
  LineEndOval
  /// §20.1.10.33 "arrow"
  LineEndArrow
} derive(Eq, Debug)

///|
pub fn ST_LineEndType::parse(
  s : String,
) -> ST_LineEndType raise SchemaViolation {
  match s {
    "none" => LineEndNone
    "triangle" => LineEndTriangle
    "stealth" => LineEndStealth
    "diamond" => LineEndDiamond
    "oval" => LineEndOval
    "arrow" => LineEndArrow
    _ => enum_violation("ST_LineEndType")
  }
}

///|
pub fn ST_LineEndType::new(s : String) -> ST_LineEndType raise SchemaViolation {
  ST_LineEndType::parse(s)
}

///|
pub fn ST_LineEndType::to_string(self : ST_LineEndType) -> String {
  match self {
    LineEndNone => "none"
    LineEndTriangle => "triangle"
    LineEndStealth => "stealth"
    LineEndDiamond => "diamond"
    LineEndOval => "oval"
    LineEndArrow => "arrow"
  }
}

///|
/// XSD simple type ST_LineEndWidth — Part 1 §20.1.10.34.
pub(all) enum ST_LineEndWidth {
  /// §20.1.10.34 "sm"
  LineEndWidthSmall
  /// §20.1.10.34 "med"
  LineEndWidthMedium
  /// §20.1.10.34 "lg"
  LineEndWidthLarge
} derive(Eq, Debug)

///|
pub fn ST_LineEndWidth::parse(
  s : String,
) -> ST_LineEndWidth raise SchemaViolation {
  match s {
    "sm" => LineEndWidthSmall
    "med" => LineEndWidthMedium
    "lg" => LineEndWidthLarge
    _ => enum_violation("ST_LineEndWidth")
  }
}

///|
pub fn ST_LineEndWidth::new(
  s : String,
) -> ST_LineEndWidth raise SchemaViolation {
  ST_LineEndWidth::parse(s)
}

///|
pub fn ST_LineEndWidth::to_string(self : ST_LineEndWidth) -> String {
  match self {
    LineEndWidthSmall => "sm"
    LineEndWidthMedium => "med"
    LineEndWidthLarge => "lg"
  }
}

///|
/// XSD simple type ST_LineEndLength — Part 1 §20.1.10.32.
pub(all) enum ST_LineEndLength {
  /// §20.1.10.32 "sm"
  LineEndLenSmall
  /// §20.1.10.32 "med"
  LineEndLenMedium
  /// §20.1.10.32 "lg"
  LineEndLenLarge
} derive(Eq, Debug)

///|
pub fn ST_LineEndLength::parse(
  s : String,
) -> ST_LineEndLength raise SchemaViolation {
  match s {
    "sm" => LineEndLenSmall
    "med" => LineEndLenMedium
    "lg" => LineEndLenLarge
    _ => enum_violation("ST_LineEndLength")
  }
}

///|
pub fn ST_LineEndLength::new(
  s : String,
) -> ST_LineEndLength raise SchemaViolation {
  ST_LineEndLength::parse(s)
}

///|
pub fn ST_LineEndLength::to_string(self : ST_LineEndLength) -> String {
  match self {
    LineEndLenSmall => "sm"
    LineEndLenMedium => "med"
    LineEndLenLarge => "lg"
  }
}

///|
/// XSD simple type ST_PresetLineDashVal — Part 1 §20.1.10.49.
pub(all) enum ST_PresetLineDashVal {
  /// §20.1.10.49 "solid"
  DashSolid
  /// §20.1.10.49 "dot"
  DashDot
  /// §20.1.10.49 "dash"
  DashDash
  /// §20.1.10.49 "lgDash"
  DashLgDash
  /// §20.1.10.49 "dashDot"
  DashDashDot
  /// §20.1.10.49 "lgDashDot"
  DashLgDashDot
  /// §20.1.10.49 "lgDashDotDot"
  DashLgDashDotDot
  /// §20.1.10.49 "sysDash"
  DashSysDash
  /// §20.1.10.49 "sysDot"
  DashSysDot
  /// §20.1.10.49 "sysDashDot"
  DashSysDashDot
  /// §20.1.10.49 "sysDashDotDot"
  DashSysDashDotDot
} derive(Eq, Debug)

///|
pub fn ST_PresetLineDashVal::parse(
  s : String,
) -> ST_PresetLineDashVal raise SchemaViolation {
  match s {
    "solid" => DashSolid
    "dot" => DashDot
    "dash" => DashDash
    "lgDash" => DashLgDash
    "dashDot" => DashDashDot
    "lgDashDot" => DashLgDashDot
    "lgDashDotDot" => DashLgDashDotDot
    "sysDash" => DashSysDash
    "sysDot" => DashSysDot
    "sysDashDot" => DashSysDashDot
    "sysDashDotDot" => DashSysDashDotDot
    _ => enum_violation("ST_PresetLineDashVal")
  }
}

///|
pub fn ST_PresetLineDashVal::new(
  s : String,
) -> ST_PresetLineDashVal raise SchemaViolation {
  ST_PresetLineDashVal::parse(s)
}

///|
pub fn ST_PresetLineDashVal::to_string(self : ST_PresetLineDashVal) -> String {
  match self {
    DashSolid => "solid"
    DashDot => "dot"
    DashDash => "dash"
    DashLgDash => "lgDash"
    DashDashDot => "dashDot"
    DashLgDashDot => "lgDashDot"
    DashLgDashDotDot => "lgDashDotDot"
    DashSysDash => "sysDash"
    DashSysDot => "sysDot"
    DashSysDashDot => "sysDashDot"
    DashSysDashDotDot => "sysDashDotDot"
  }
}

///|
/// XSD simple type ST_BlendMode — Part 1 §20.1.10.11. Composition mode
/// for the `blend` (§20.1.8.12) and `fillOverlay` (§20.1.8.29) effects.
pub(all) enum ST_BlendMode {
  /// §20.1.10.11 "over"
  BlendOver
  /// §20.1.10.11 "mult"
  BlendMult
  /// §20.1.10.11 "screen"
  BlendScreen
  /// §20.1.10.11 "darken"
  BlendDarken
  /// §20.1.10.11 "lighten"
  BlendLighten
} derive(Eq, Debug)

///|
pub fn ST_BlendMode::parse(s : String) -> ST_BlendMode raise SchemaViolation {
  match s {
    "over" => BlendOver
    "mult" => BlendMult
    "screen" => BlendScreen
    "darken" => BlendDarken
    "lighten" => BlendLighten
    _ => enum_violation("ST_BlendMode")
  }
}

///|
pub fn ST_BlendMode::new(s : String) -> ST_BlendMode raise SchemaViolation {
  ST_BlendMode::parse(s)
}

///|
pub fn ST_BlendMode::to_string(self : ST_BlendMode) -> String {
  match self {
    BlendOver => "over"
    BlendMult => "mult"
    BlendScreen => "screen"
    BlendDarken => "darken"
    BlendLighten => "lighten"
  }
}

///|
/// XSD simple type ST_EffectContainerType — Part 1 §20.1.10.24. Selects
/// whether a `CT_EffectContainer` aggregates sibling effects (`sib`) or
/// child effects in tree order (`tree`).
pub(all) enum ST_EffectContainerType {
  /// §20.1.10.24 "sib"
  EffectContainerSib
  /// §20.1.10.24 "tree"
  EffectContainerTree
} derive(Eq, Debug)

///|
pub fn ST_EffectContainerType::parse(
  s : String,
) -> ST_EffectContainerType raise SchemaViolation {
  match s {
    "sib" => EffectContainerSib
    "tree" => EffectContainerTree
    _ => enum_violation("ST_EffectContainerType")
  }
}

///|
pub fn ST_EffectContainerType::new(
  s : String,
) -> ST_EffectContainerType raise SchemaViolation {
  ST_EffectContainerType::parse(s)
}

///|
pub fn ST_EffectContainerType::to_string(
  self : ST_EffectContainerType,
) -> String {
  match self {
    EffectContainerSib => "sib"
    EffectContainerTree => "tree"
  }
}

///|
/// XSD simple type ST_PresetShadowVal — Part 1 §20.1.10.52. Enumerates
/// the twenty named preset shadow styles used by `prstShdw`
/// (§20.1.8.49) via its `prst` attribute.
pub(all) enum ST_PresetShadowVal {
  /// §20.1.10.52 "shdw1"
  PresetShadow1
  /// §20.1.10.52 "shdw2"
  PresetShadow2
  /// §20.1.10.52 "shdw3"
  PresetShadow3
  /// §20.1.10.52 "shdw4"
  PresetShadow4
  /// §20.1.10.52 "shdw5"
  PresetShadow5
  /// §20.1.10.52 "shdw6"
  PresetShadow6
  /// §20.1.10.52 "shdw7"
  PresetShadow7
  /// §20.1.10.52 "shdw8"
  PresetShadow8
  /// §20.1.10.52 "shdw9"
  PresetShadow9
  /// §20.1.10.52 "shdw10"
  PresetShadow10
  /// §20.1.10.52 "shdw11"
  PresetShadow11
  /// §20.1.10.52 "shdw12"
  PresetShadow12
  /// §20.1.10.52 "shdw13"
  PresetShadow13
  /// §20.1.10.52 "shdw14"
  PresetShadow14
  /// §20.1.10.52 "shdw15"
  PresetShadow15
  /// §20.1.10.52 "shdw16"
  PresetShadow16
  /// §20.1.10.52 "shdw17"
  PresetShadow17
  /// §20.1.10.52 "shdw18"
  PresetShadow18
  /// §20.1.10.52 "shdw19"
  PresetShadow19
  /// §20.1.10.52 "shdw20"
  PresetShadow20
} derive(Eq, Debug)

///|
pub fn ST_PresetShadowVal::parse(
  s : String,
) -> ST_PresetShadowVal raise SchemaViolation {
  match s {
    "shdw1" => PresetShadow1
    "shdw2" => PresetShadow2
    "shdw3" => PresetShadow3
    "shdw4" => PresetShadow4
    "shdw5" => PresetShadow5
    "shdw6" => PresetShadow6
    "shdw7" => PresetShadow7
    "shdw8" => PresetShadow8
    "shdw9" => PresetShadow9
    "shdw10" => PresetShadow10
    "shdw11" => PresetShadow11
    "shdw12" => PresetShadow12
    "shdw13" => PresetShadow13
    "shdw14" => PresetShadow14
    "shdw15" => PresetShadow15
    "shdw16" => PresetShadow16
    "shdw17" => PresetShadow17
    "shdw18" => PresetShadow18
    "shdw19" => PresetShadow19
    "shdw20" => PresetShadow20
    _ => enum_violation("ST_PresetShadowVal")
  }
}

///|
pub fn ST_PresetShadowVal::new(
  s : String,
) -> ST_PresetShadowVal raise SchemaViolation {
  ST_PresetShadowVal::parse(s)
}

///|
pub fn ST_PresetShadowVal::to_string(self : ST_PresetShadowVal) -> String {
  match self {
    PresetShadow1 => "shdw1"
    PresetShadow2 => "shdw2"
    PresetShadow3 => "shdw3"
    PresetShadow4 => "shdw4"
    PresetShadow5 => "shdw5"
    PresetShadow6 => "shdw6"
    PresetShadow7 => "shdw7"
    PresetShadow8 => "shdw8"
    PresetShadow9 => "shdw9"
    PresetShadow10 => "shdw10"
    PresetShadow11 => "shdw11"
    PresetShadow12 => "shdw12"
    PresetShadow13 => "shdw13"
    PresetShadow14 => "shdw14"
    PresetShadow15 => "shdw15"
    PresetShadow16 => "shdw16"
    PresetShadow17 => "shdw17"
    PresetShadow18 => "shdw18"
    PresetShadow19 => "shdw19"
    PresetShadow20 => "shdw20"
  }
}

///|
/// XSD simple type ST_BlackWhiteMode — Part 1 §20.1.10.10. Enumeration of
/// colour rendering modes used by `bwMode` attributes on shape /
/// group-shape property containers.
pub(all) enum ST_BlackWhiteMode {
  /// §20.1.10.10 "clr"
  BwModeClr
  /// §20.1.10.10 "auto"
  BwModeAuto
  /// §20.1.10.10 "gray"
  BwModeGray
  /// §20.1.10.10 "ltGray"
  BwModeLtGray
  /// §20.1.10.10 "invGray"
  BwModeInvGray
  /// §20.1.10.10 "grayWhite"
  BwModeGrayWhite
  /// §20.1.10.10 "blackGray"
  BwModeBlackGray
  /// §20.1.10.10 "blackWhite"
  BwModeBlackWhite
  /// §20.1.10.10 "black"
  BwModeBlack
  /// §20.1.10.10 "white"
  BwModeWhite
  /// §20.1.10.10 "hidden"
  BwModeHidden
} derive(Eq, Debug)

///|
pub fn ST_BlackWhiteMode::parse(
  s : String,
) -> ST_BlackWhiteMode raise SchemaViolation {
  match s {
    "clr" => BwModeClr
    "auto" => BwModeAuto
    "gray" => BwModeGray
    "ltGray" => BwModeLtGray
    "invGray" => BwModeInvGray
    "grayWhite" => BwModeGrayWhite
    "blackGray" => BwModeBlackGray
    "blackWhite" => BwModeBlackWhite
    "black" => BwModeBlack
    "white" => BwModeWhite
    "hidden" => BwModeHidden
    _ => enum_violation("ST_BlackWhiteMode")
  }
}

///|
pub fn ST_BlackWhiteMode::new(
  s : String,
) -> ST_BlackWhiteMode raise SchemaViolation {
  ST_BlackWhiteMode::parse(s)
}

///|
pub fn ST_BlackWhiteMode::to_string(self : ST_BlackWhiteMode) -> String {
  match self {
    BwModeClr => "clr"
    BwModeAuto => "auto"
    BwModeGray => "gray"
    BwModeLtGray => "ltGray"
    BwModeInvGray => "invGray"
    BwModeGrayWhite => "grayWhite"
    BwModeBlackGray => "blackGray"
    BwModeBlackWhite => "blackWhite"
    BwModeBlack => "black"
    BwModeWhite => "white"
    BwModeHidden => "hidden"
  }
}

///|
/// XSD simple type ST_OnOffStyleType — Part 1 §20.1.10.41. Three-state
/// override used by `CT_TableStyleTextStyle` attributes `b` / `i` so a
/// table style can force bold / italic on, off, or fall back to the
/// theme default.
pub(all) enum ST_OnOffStyleType {
  /// §20.1.10.41 "on"
  OnOffStyleOn
  /// §20.1.10.41 "off"
  OnOffStyleOff
  /// §20.1.10.41 "def"
  OnOffStyleDef
} derive(Eq, Debug)

///|
pub fn ST_OnOffStyleType::parse(
  s : String,
) -> ST_OnOffStyleType raise SchemaViolation {
  match s {
    "on" => OnOffStyleOn
    "off" => OnOffStyleOff
    "def" => OnOffStyleDef
    _ => enum_violation("ST_OnOffStyleType")
  }
}

///|
pub fn ST_OnOffStyleType::new(
  s : String,
) -> ST_OnOffStyleType raise SchemaViolation {
  ST_OnOffStyleType::parse(s)
}

///|
pub fn ST_OnOffStyleType::to_string(self : ST_OnOffStyleType) -> String {
  match self {
    OnOffStyleOn => "on"
    OnOffStyleOff => "off"
    OnOffStyleDef => "def"
  }
}

///|
/// XSD simple type ST_LineWidth — Part 1 §20.1.10.34. A restriction of
/// `ST_Coordinate32Unqualified` (xsd:int EMU magnitude) bounded to the
/// closed interval `[0, 20116800]`. Used by `CT_LineProperties/@w` to
/// express line stroke width in EMU.
pub struct ST_LineWidth {
  /// Raw lexical EMU value (xsd:int).
  emu : Int
} derive(Eq, Debug)

///|
pub fn ST_LineWidth::parse(s : String) -> ST_LineWidth raise SchemaViolation {
  let v = parse_int_or_violate("ST_LineWidth", s)
  if v < 0 || v > 20116800 {
    measure_violation("ST_LineWidth")
  }
  { emu: v }
}

///|
pub fn ST_LineWidth::new(s : String) -> ST_LineWidth raise SchemaViolation {
  ST_LineWidth::parse(s)
}

///|
pub fn ST_LineWidth::to_string(self : ST_LineWidth) -> String {
  self.emu.to_string()
}

///|
pub fn ST_LineWidth::to_int(self : ST_LineWidth) -> Int {
  self.emu
}

// === Private helpers ===

///|
fn[T] enum_violation(type_name : String) -> T raise SchemaViolation {
  raise SchemaViolation(
    schema="dml-main.xsd",
    path=type_name,
    reason="invalid enumeration value",
  )
}

///|
fn[T] measure_violation(type_name : String) -> T raise SchemaViolation {
  raise SchemaViolation(
    schema="dml-main.xsd",
    path=type_name,
    reason="value outside the schema-permitted range",
  )
}

///|
fn parse_int_or_violate(
  type_name : String,
  s : String,
) -> Int raise SchemaViolation {
  if !is_signed_digits(s) {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="invalid integer token",
    )
  }
  parse_int_lexical(s)
}

///|
fn parse_long_or_violate(
  type_name : String,
  s : String,
) -> Int64 raise SchemaViolation {
  if !is_signed_digits(s) {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="invalid integer token",
    )
  }
  parse_int64_lexical(s)
}

///|
fn range_check_long(
  type_name : String,
  value : Int64,
  min : Int64,
  max : Int64,
) -> Unit raise SchemaViolation {
  if value < min || value > max {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="value outside the schema-permitted range",
    )
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
    if start >= value.length() {
      false
    } else {
      let mut ok = true
      for i in start..<value.length() {
        let ch = value[i:i + 1]
        ok = ok && ch >= "0" && ch <= "9"
      }
      ok
    }
  }
}

///|
fn all_digits(value : String) -> Bool {
  if value.length() == 0 {
    false
  } else {
    let mut ok = true
    for i in 0..<value.length() {
      let ch = value[i:i + 1]
      ok = ok && ch >= "0" && ch <= "9"
    }
    ok
  }
}

///|
fn parse_int_digits(s : String) -> Int {
  let mut value = 0
  for i in 0..<s.length() {
    let digit = s.code_unit_at(i).to_int() - 0x30
    value = value * 10 + digit
  }
  value
}

///|
fn parse_int_lexical(s : String) -> Int {
  let mut negative = false
  let mut start = 0
  if s.length() > 0 {
    let first = s[0:1]
    if first == "-" {
      negative = true
      start = 1
    } else if first == "+" {
      start = 1
    }
  }
  let mut value = 0
  for i in start..<s.length() {
    let digit = s.code_unit_at(i).to_int() - 0x30
    value = value * 10 + digit
  }
  if negative {
    -value
  } else {
    value
  }
}

///|
fn parse_int64_lexical(s : String) -> Int64 {
  let mut negative = false
  let mut start = 0
  if s.length() > 0 {
    let first = s[0:1]
    if first == "-" {
      negative = true
      start = 1
    } else if first == "+" {
      start = 1
    }
  }
  let mut value : Int64 = 0L
  for i in start..<s.length() {
    let digit = (s.code_unit_at(i).to_int() - 0x30).to_int64()
    value = value * 10L + digit
  }
  if negative {
    -value
  } else {
    value
  }
}

///|
fn is_universal_measure(s : String) -> Bool {
  if s.length() < 3 {
    false
  } else {
    let unit = s.unsafe_substring(start=s.length() - 2, end=s.length())
    let number_end = s.length() - 2
    is_measure_unit(unit) && is_decimal_range(s, 0, number_end)
  }
}

///|
fn is_measure_unit(unit : String) -> Bool {
  unit == "mm" ||
  unit == "cm" ||
  unit == "in" ||
  unit == "pt" ||
  unit == "pc" ||
  unit == "pi"
}

///|
/// Decode a transitional DrawingML percent attribute. Accepts either the
/// strict `<decimal>%` lexical form (s:ST_Percentage / §22.9.2.9) or the
/// transitional `ST_PercentageDecimal` xsd:int form (Part 4 §A.4.1) and
/// returns the value in 1000ths-of-percent. The `positive` and `fixed`
/// flags apply the corresponding restrictions on top of the base type.
fn parse_percent_thousandths(
  type_name : String,
  s : String,
  positive~ : Bool,
  fixed~ : Bool,
) -> Int64 raise SchemaViolation {
  let value : Int64 = if s.length() > 0 &&
    s.unsafe_substring(start=s.length() - 1, end=s.length()) == "%" {
    if !is_percentage(s, positive~, fixed~) {
      raise SchemaViolation(
        schema="dml-main.xsd",
        path=type_name,
        reason="invalid percent lexical form",
      )
    }
    let magnitude_text = s.unsafe_substring(start=0, end=s.length() - 1)
    parse_decimal_scaled(magnitude_text, 3)
  } else {
    // Transitional `ST_PercentageDecimal` is xsd:int already encoded as
    // 1000ths of a percent.
    if !is_signed_digits(s) {
      raise SchemaViolation(
        schema="dml-main.xsd",
        path=type_name,
        reason="invalid percent lexical form",
      )
    }
    parse_int64_lexical(s)
  }
  if positive && value < 0L {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="negative value is not allowed",
    )
  }
  if fixed {
    // |value| ≤ 100% = 100 000 thousandths.
    let abs = if value < 0L { -value } else { value }
    if abs > 100000L {
      raise SchemaViolation(
        schema="dml-main.xsd",
        path=type_name,
        reason="value exceeds the schema-permitted range",
      )
    }
  }
  value
}

///|
fn is_percentage(s : String, positive~ : Bool, fixed~ : Bool) -> Bool {
  if s.length() < 2 ||
    s.unsafe_substring(start=s.length() - 1, end=s.length()) != "%" {
    false
  } else {
    let number_end = s.length() - 1
    is_decimal_range(s, 0, number_end) &&
    (!positive || decimal_non_negative(s, 0, number_end)) &&
    (!fixed || decimal_abs_le_100(s, 0, number_end))
  }
}

///|
fn is_decimal_range(s : String, start : Int, end : Int) -> Bool {
  if start >= end {
    false
  } else {
    let mut pos = start
    if s[pos:pos + 1] == "-" {
      pos = pos + 1
    }
    let digits_start = pos
    while pos < end && is_digit_at(s, pos) {
      pos = pos + 1
    }
    let whole_digits = pos > digits_start
    if pos < end && s[pos:pos + 1] == "." {
      pos = pos + 1
      let fraction_start = pos
      while pos < end && is_digit_at(s, pos) {
        pos = pos + 1
      }
      whole_digits && pos > fraction_start && pos == end
    } else {
      whole_digits && pos == end
    }
  }
}

///|
fn decimal_non_negative(s : String, start : Int, end : Int) -> Bool {
  if s[start:start + 1] != "-" {
    true
  } else {
    decimal_is_zero(s, start + 1, end)
  }
}

///|
fn decimal_is_zero(s : String, start : Int, end : Int) -> Bool {
  let mut zero = true
  for i in start..<end {
    let ch = s[i:i + 1]
    if ch != "." && ch != "0" {
      zero = false
    }
  }
  zero
}

///|
fn decimal_abs_le_100(s : String, start : Int, end : Int) -> Bool {
  let mut pos = start
  if s[pos:pos + 1] == "-" {
    pos = pos + 1
  }
  let whole_start = pos
  while pos < end && is_digit_at(s, pos) {
    pos = pos + 1
  }
  let whole = trim_leading_zeroes(s, whole_start, pos)
  if whole.length() < 3 {
    true
  } else if whole.length() > 3 || whole != "100" {
    false
  } else if pos == end {
    true
  } else {
    decimal_is_zero(s, pos + 1, end)
  }
}

///|
fn trim_leading_zeroes(s : String, start : Int, end : Int) -> String {
  let mut pos = start
  while pos < end - 1 && s[pos:pos + 1] == "0" {
    pos = pos + 1
  }
  s[pos:end].to_owned()
}

///|
fn is_digit_at(s : String, index : Int) -> Bool {
  s[index:index + 1] >= "0" && s[index:index + 1] <= "9"
}

///|
fn parse_decimal_double(s : String) -> Double {
  let mut sign = 1.0
  let mut pos = 0
  if pos < s.length() && s[pos:pos + 1] == "-" {
    sign = -1.0
    pos = pos + 1
  }
  let mut whole = 0.0
  while pos < s.length() && is_digit_at(s, pos) {
    let digit = (s.code_unit_at(pos).to_int() - 0x30).to_double()
    whole = whole * 10.0 + digit
    pos = pos + 1
  }
  let mut fraction = 0.0
  let mut scale = 1.0
  if pos < s.length() && s[pos:pos + 1] == "." {
    pos = pos + 1
    while pos < s.length() && is_digit_at(s, pos) {
      scale = scale * 10.0
      let digit = (s.code_unit_at(pos).to_int() - 0x30).to_double()
      fraction = fraction + digit / scale
      pos = pos + 1
    }
  }
  sign * (whole + fraction)
}

///|
fn parse_decimal_scaled(s : String, decimal_places : Int) -> Int64 {
  let mut sign : Int64 = 1L
  let mut pos = 0
  if pos < s.length() && s[pos:pos + 1] == "-" {
    sign = -1L
    pos = pos + 1
  }
  let mut whole : Int64 = 0L
  while pos < s.length() && is_digit_at(s, pos) {
    let digit = (s.code_unit_at(pos).to_int() - 0x30).to_int64()
    whole = whole * 10L + digit
    pos = pos + 1
  }
  let mut multiplier : Int64 = 1L
  for _ in 0..<decimal_places {
    multiplier = multiplier * 10L
  }
  let mut scaled = whole * multiplier
  if pos < s.length() && s[pos:pos + 1] == "." {
    pos = pos + 1
    let mut consumed = 0
    while pos < s.length() && is_digit_at(s, pos) && consumed < decimal_places {
      let digit = (s.code_unit_at(pos).to_int() - 0x30).to_int64()
      multiplier = multiplier / 10L
      scaled = scaled + digit * multiplier
      pos = pos + 1
      consumed = consumed + 1
    }
  }
  sign * scaled
}

///|
fn format_scaled_decimal(value : Int64, decimal_places : Int) -> String {
  let negative = value < 0L
  let magnitude = if negative { -value } else { value }
  let mut divisor : Int64 = 1L
  for _ in 0..<decimal_places {
    divisor = divisor * 10L
  }
  let whole = magnitude / divisor
  let fraction = magnitude - whole * divisor
  let mut frac_text = fraction.to_string()
  while frac_text.length() < decimal_places {
    frac_text = "0" + frac_text
  }
  let mut end = frac_text.length()
  while end > 0 && frac_text[end - 1:end] == "0" {
    end = end - 1
  }
  let body = if end == 0 {
    whole.to_string()
  } else {
    whole.to_string() + "." + frac_text.unsafe_substring(start=0, end~)
  }
  if negative {
    "-" + body
  } else {
    body
  }
}

///|
fn format_decimal(value : Double) -> String {
  if value == value.trunc() && value.abs() < 1.0e15 {
    value.to_int64().to_string()
  } else {
    value.to_string()
  }
}
