///|
/// XSD simple type ST_Lang — Part 1 §22.9.2.6 BCP-47 language tag
/// carried as a typed xsd:language lexical value. The lexical form is
/// preserved so callers can hand it straight back to the XML
/// serializer; the constructor enforces "non-empty and starts with an
/// ASCII letter" which is the conformance constraint the spec text
/// leans on.
pub struct ST_Lang {
  lexical : String
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.6 — decode a lexical language tag. Empty values
/// raise because xsd:language is `[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*`.
pub fn ST_Lang::new(s : String) -> ST_Lang raise SchemaViolation {
  if s.length() == 0 {
    violation("ST_Lang", s)
  }
  if !is_ascii_alpha_at(s, 0) {
    violation("ST_Lang", s)
  }
  { lexical: s }
}

///|
/// Render back to the lexical language tag.
pub fn ST_Lang::to_string(self : ST_Lang) -> String {
  self.lexical
}

///|
/// Part 1 §22.9.2.5 ST_HexColorRGB — six-hex-digit ARGB-less colour.
/// Stored as three 0..255 channel integers so callers can use the
/// channels directly without re-parsing the lexical form.
pub struct ST_HexColorRGB {
  red : Int
  green : Int
  blue : Int
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.5 — decode a six-hex-digit colour string. The
/// constructor folds the lexical hex to three integer channels.
pub fn ST_HexColorRGB::new(s : String) -> ST_HexColorRGB raise SchemaViolation {
  if !fixed_hex(s, 6) {
    violation("ST_HexColorRGB", s)
  }
  { red: hex_pair(s, 0), green: hex_pair(s, 2), blue: hex_pair(s, 4) }
}

///|
/// Render the colour back to a six-hex-digit lexical form (uppercase
/// per the canonical XML output convention).
pub fn ST_HexColorRGB::to_string(self : ST_HexColorRGB) -> String {
  hex_byte(self.red) + hex_byte(self.green) + hex_byte(self.blue)
}

///|
/// Channel accessor — the red channel as a 0..255 integer.
pub fn ST_HexColorRGB::r(self : ST_HexColorRGB) -> Int {
  self.red
}

///|
/// Channel accessor — the green channel as a 0..255 integer.
pub fn ST_HexColorRGB::g(self : ST_HexColorRGB) -> Int {
  self.green
}

///|
/// Channel accessor — the blue channel as a 0..255 integer.
pub fn ST_HexColorRGB::b(self : ST_HexColorRGB) -> Int {
  self.blue
}

///|
/// Part 1 §22.9.2.7 ST_Panose — ten-byte Panose-1 font classification
/// stored as a fixed 10-byte array. The XML form is twenty hex digits.
pub struct ST_Panose {
  bytes : FixedArray[Byte]
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.7 — decode the twenty-hex-digit lexical form to the
/// ten Panose-1 bytes. Each pair of hex digits is one classification
/// byte (family kind, serif style, weight, proportion, …).
pub fn ST_Panose::new(s : String) -> ST_Panose raise SchemaViolation {
  if !fixed_hex(s, 20) {
    violation("ST_Panose", s)
  }
  let bytes : FixedArray[Byte] = FixedArray::make(10, b'\x00')
  for i in 0..<10 {
    bytes[i] = hex_pair(s, i * 2).to_byte()
  }
  { bytes, }
}

///|
/// Render the Panose classification back to its twenty-hex-digit form.
pub fn ST_Panose::to_string(self : ST_Panose) -> String {
  let buf = StringBuilder::new()
  for i in 0..<10 {
    buf.write_string(hex_byte(self.bytes[i].to_int()))
  }
  buf.to_string()
}

///|
/// Access the i-th classification byte (0..9).
pub fn ST_Panose::byte_at(self : ST_Panose, index : Int) -> Int {
  self.bytes[index].to_int()
}

///|
/// Part 1 §22.9.2.4 ST_CalendarType — calendar-system enumeration.
/// Fourteen lexical values per the §22.9.2.4 table.
pub(all) enum ST_CalendarType {
  /// §22.9.2.4 "gregorian"
  Gregorian
  /// §22.9.2.4 "gregorianUs"
  GregorianUs
  /// §22.9.2.4 "gregorianMeFrench"
  GregorianMeFrench
  /// §22.9.2.4 "gregorianArabic"
  GregorianArabic
  /// §22.9.2.4 "hijri"
  Hijri
  /// §22.9.2.4 "hebrew"
  Hebrew
  /// §22.9.2.4 "taiwan"
  Taiwan
  /// §22.9.2.4 "japan"
  Japan
  /// §22.9.2.4 "thai"
  Thai
  /// §22.9.2.4 "korea"
  Korea
  /// §22.9.2.4 "saka"
  Saka
  /// §22.9.2.4 "gregorianXlitEnglish"
  GregorianXlitEnglish
  /// §22.9.2.4 "gregorianXlitFrench"
  GregorianXlitFrench
  /// §22.9.2.4 "none" (renamed to avoid colliding with Option::None).
  NoneCalendar
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.4 — decode a lexical calendar-system token.
pub fn ST_CalendarType::new(
  s : String,
) -> ST_CalendarType raise SchemaViolation {
  match s {
    "gregorian" => Gregorian
    "gregorianUs" => GregorianUs
    "gregorianMeFrench" => GregorianMeFrench
    "gregorianArabic" => GregorianArabic
    "hijri" => Hijri
    "hebrew" => Hebrew
    "taiwan" => Taiwan
    "japan" => Japan
    "thai" => Thai
    "korea" => Korea
    "saka" => Saka
    "gregorianXlitEnglish" => GregorianXlitEnglish
    "gregorianXlitFrench" => GregorianXlitFrench
    "none" => NoneCalendar
    _ => violation("ST_CalendarType", s)
  }
}

///|
/// Render the calendar-system enumeration value back to its lexical
/// form.
pub fn ST_CalendarType::to_string(self : ST_CalendarType) -> String {
  match self {
    Gregorian => "gregorian"
    GregorianUs => "gregorianUs"
    GregorianMeFrench => "gregorianMeFrench"
    GregorianArabic => "gregorianArabic"
    Hijri => "hijri"
    Hebrew => "hebrew"
    Taiwan => "taiwan"
    Japan => "japan"
    Thai => "thai"
    Korea => "korea"
    Saka => "saka"
    GregorianXlitEnglish => "gregorianXlitEnglish"
    GregorianXlitFrench => "gregorianXlitFrench"
    NoneCalendar => "none"
  }
}

///|
/// Part 1 §22.9.2.4 — true when this calendar token uses Gregorian
/// year/month/day fields for consumers that compare date components.
pub fn ST_CalendarType::uses_gregorian_fields(self : ST_CalendarType) -> Bool {
  match self {
    Gregorian
    | GregorianUs
    | GregorianMeFrench
    | GregorianArabic
    | GregorianXlitEnglish
    | GregorianXlitFrench
    | NoneCalendar => true
    _ => false
  }
}

///|
/// XSD simple type ST_Guid — Part 1 §22.9.2.3 brace-delimited GUID
/// stored as the 16 raw bytes (network byte order, matching the
/// lexical form's reading order). The lexical form is
/// `{HHHHHHHH-HHHH-HHHH-HHHH-HHHHHHHHHHHH}`.
pub struct ST_Guid {
  bytes : FixedArray[Byte]
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.3 — decode the brace-delimited UUID lexical form
/// into 16 raw bytes (groups 4-2-2-2-6).
pub fn ST_Guid::new(s : String) -> ST_Guid raise SchemaViolation {
  if !is_guid(s) {
    violation("ST_Guid", s)
  }
  let bytes : FixedArray[Byte] = FixedArray::make(16, b'\x00')
  // Layout: { HH HH HH HH - HH HH - HH HH - HH HH - HH HH HH HH HH HH }
  // Offsets in s: 1..9, 10..14, 15..19, 20..24, 25..37.
  let groups : Array[(Int, Int, Int)] = [
    (1, 0, 4), // first 4 bytes
    (10, 4, 2), // next 2 bytes
    (15, 6, 2), // next 2 bytes
    (20, 8, 2), // next 2 bytes
    (25, 10, 6), // final 6 bytes
  ]
  for entry in groups {
    let (lex_start, byte_start, byte_count) = entry
    for i in 0..<byte_count {
      bytes[byte_start + i] = hex_pair(s, lex_start + i * 2).to_byte()
    }
  }
  { bytes, }
}

///|
/// Render the GUID back to its brace-delimited lexical form.
pub fn ST_Guid::to_string(self : ST_Guid) -> String {
  let buf = StringBuilder::new()
  buf.write_char('{')
  let segments = [(0, 4), (4, 6), (6, 8), (8, 10), (10, 16)]
  let mut first = true
  for entry in segments {
    if !first {
      buf.write_char('-')
    }
    first = false
    let (start, end) = entry
    for i in start..<end {
      buf.write_string(hex_byte(self.bytes[i].to_int()))
    }
  }
  buf.write_char('}')
  buf.to_string()
}

///|
/// Access the i-th raw byte (0..15).
pub fn ST_Guid::byte_at(self : ST_Guid, index : Int) -> Int {
  self.bytes[index].to_int()
}

///|
/// Part 1 §22.9.2.7 ST_OnOff — Office's xsd:boolean variant. Stored as
/// a plain Bool. The canonical lexical form rendered by `to_string`
/// is `true` / `false`; `new` also accepts `1` / `0` / `on` / `off`.
pub struct ST_OnOff {
  value : Bool
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.7 — decode one of `true`, `false`, `1`, `0`, `on`,
/// `off` to a Bool. Everything else raises SchemaViolation.
pub fn ST_OnOff::new(s : String) -> ST_OnOff raise SchemaViolation {
  match s {
    "true" | "1" | "on" => { value: true }
    "false" | "0" | "off" => { value: false }
    _ => violation("ST_OnOff", s)
  }
}

///|
/// Project the value to a raw Bool.
pub fn ST_OnOff::to_bool(self : ST_OnOff) -> Bool {
  self.value
}

///|
/// Render the value to the canonical "true" / "false" lexical form.
pub fn ST_OnOff::to_string(self : ST_OnOff) -> String {
  if self.value {
    "true"
  } else {
    "false"
  }
}

///|
/// Part 1 §22.9.2.13 ST_String — unconstrained xsd:string. The lexical
/// form is kept verbatim; this typed wrapper exists so callers can
/// distinguish a spec-typed string carrier from an arbitrary String.
pub struct ST_String {
  lexical : String
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.13 — wrap any xsd:string lexical value.
pub fn ST_String::new(s : String) -> ST_String {
  { lexical: s }
}

///|
/// Return the wrapped lexical form.
pub fn ST_String::to_string(self : ST_String) -> String {
  self.lexical
}

///|
/// Part 1 §22.9.2.15 ST_XmlName — xsd:NCName lexical value. The
/// constructor enforces the NCName production from XML 1.0 §3.
pub struct ST_XmlName {
  lexical : String
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.15 — decode an NCName lexical value.
pub fn ST_XmlName::new(s : String) -> ST_XmlName raise SchemaViolation {
  if !@xml.is_ncname(s) {
    violation("ST_XmlName", s)
  }
  { lexical: s }
}

///|
/// Render the NCName back to its lexical form.
pub fn ST_XmlName::to_string(self : ST_XmlName) -> String {
  self.lexical
}

///|
/// Part 1 §22.9.2.16 ST_UnsignedDecimalNumber — xsd:unsignedLong (a
/// non-negative integer up to 2^64 − 1). Stored as a UInt64 so
/// arithmetic uses native semantics, not lexical-string juggling.
pub struct ST_UnsignedDecimalNumber {
  value : UInt64
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.16 — decode the decimal lexical form to UInt64.
pub fn ST_UnsignedDecimalNumber::new(
  s : String,
) -> ST_UnsignedDecimalNumber raise SchemaViolation {
  if !is_unsigned_long(s) {
    violation("ST_UnsignedDecimalNumber", s)
  }
  let value = parse_unsigned_long(s)
  { value, }
}

///|
/// Render the integer value back to its canonical decimal lexical form.
pub fn ST_UnsignedDecimalNumber::to_string(
  self : ST_UnsignedDecimalNumber,
) -> String {
  self.value.to_string()
}

///|
/// Numeric accessor.
pub fn ST_UnsignedDecimalNumber::to_uint64(
  self : ST_UnsignedDecimalNumber,
) -> UInt64 {
  self.value
}

///|
/// Part 1 §22.9.2.14 ST_UniversalMeasure — signed decimal magnitude
/// plus a unit suffix. Stored as the magnitude (Double) plus a typed
/// `UniversalMeasureUnit` so downstream code can convert without
/// re-parsing the lexical form.
pub struct ST_UniversalMeasure {
  magnitude : Double
  unit : UniversalMeasureUnit
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.14 — the six universal measure unit suffixes:
/// millimetre, centimetre, inch, point, pica, and pi (didot point).
pub(all) enum UniversalMeasureUnit {
  /// §22.9.2.14 "mm"
  Millimetre
  /// §22.9.2.14 "cm"
  Centimetre
  /// §22.9.2.14 "in"
  Inch
  /// §22.9.2.14 "pt"
  Point
  /// §22.9.2.14 "pc"
  Pica
  /// §22.9.2.14 "pi"
  PiPoint
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.14 — decode the unit suffix lexical token.
pub fn UniversalMeasureUnit::from_lexical(
  s : String,
) -> UniversalMeasureUnit raise SchemaViolation {
  match s {
    "mm" => Millimetre
    "cm" => Centimetre
    "in" => Inch
    "pt" => Point
    "pc" => Pica
    "pi" => PiPoint
    _ => violation("UniversalMeasureUnit", s)
  }
}

///|
/// Render the unit suffix back to its canonical lexical token.
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
/// Part 1 §22.9.2.14 — decode the lexical "decimal + unit" form.
pub fn ST_UniversalMeasure::new(
  s : String,
) -> ST_UniversalMeasure raise SchemaViolation {
  if !is_universal_measure(s, positive=false) {
    violation("ST_UniversalMeasure", s)
  }
  let split = s.length() - 2
  let magnitude_text = s.unsafe_substring(start=0, end=split)
  let unit_text = s.unsafe_substring(start=split, end=s.length())
  let magnitude = parse_decimal_double(magnitude_text)
  let unit = UniversalMeasureUnit::from_lexical(unit_text)
  { magnitude, unit }
}

///|
/// Render the typed measure back to its canonical lexical form.
pub fn ST_UniversalMeasure::to_string(self : ST_UniversalMeasure) -> String {
  format_decimal(self.magnitude) + self.unit.to_string()
}

///|
/// Numeric accessor for the magnitude.
pub fn ST_UniversalMeasure::value(self : ST_UniversalMeasure) -> Double {
  self.magnitude
}

///|
/// Unit accessor.
pub fn ST_UniversalMeasure::unit_of(
  self : ST_UniversalMeasure,
) -> UniversalMeasureUnit {
  self.unit
}

///|
/// Part 1 §22.9.2.12 ST_PositiveUniversalMeasure — non-negative
/// universal measure. Stored as the typed magnitude + unit; the
/// constructor enforces magnitude ≥ 0.
pub struct ST_PositiveUniversalMeasure {
  magnitude : Double
  unit : UniversalMeasureUnit
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.12 — decode the lexical form, raising when the
/// magnitude is negative.
pub fn ST_PositiveUniversalMeasure::new(
  s : String,
) -> ST_PositiveUniversalMeasure raise SchemaViolation {
  if !is_universal_measure(s, positive=true) {
    violation("ST_PositiveUniversalMeasure", s)
  }
  let split = s.length() - 2
  let magnitude_text = s.unsafe_substring(start=0, end=split)
  let unit_text = s.unsafe_substring(start=split, end=s.length())
  let magnitude = parse_decimal_double(magnitude_text)
  let unit = UniversalMeasureUnit::from_lexical(unit_text)
  { magnitude, unit }
}

///|
/// Render back to the canonical lexical form.
pub fn ST_PositiveUniversalMeasure::to_string(
  self : ST_PositiveUniversalMeasure,
) -> String {
  format_decimal(self.magnitude) + self.unit.to_string()
}

///|
/// Numeric accessor for the magnitude.
pub fn ST_PositiveUniversalMeasure::value(
  self : ST_PositiveUniversalMeasure,
) -> Double {
  self.magnitude
}

///|
/// Unit accessor.
pub fn ST_PositiveUniversalMeasure::unit_of(
  self : ST_PositiveUniversalMeasure,
) -> UniversalMeasureUnit {
  self.unit
}

///|
/// Part 1 §22.9.2.10 ST_TwipsMeasure — either an unsigned decimal
/// (interpreted as twentieths-of-a-point — `twips`) or a positive
/// universal measure. The typed discriminator preserves the
/// distinction so callers don't lose information across the union.
pub enum ST_TwipsMeasure {
  /// §22.9.2.10 unsigned-long branch: raw twips.
  Twips(UInt64)
  /// §22.9.2.10 universal-measure branch: typed magnitude + unit.
  Measure(ST_PositiveUniversalMeasure)
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.10 — decode the union lexical form.
pub fn ST_TwipsMeasure::new(
  s : String,
) -> ST_TwipsMeasure raise SchemaViolation {
  if is_unsigned_long(s) {
    Twips(parse_unsigned_long(s))
  } else if is_universal_measure(s, positive=true) {
    Measure(ST_PositiveUniversalMeasure::new(s))
  } else {
    violation("ST_TwipsMeasure", s)
  }
}

///|
/// Render the value back to its canonical lexical form.
pub fn ST_TwipsMeasure::to_string(self : ST_TwipsMeasure) -> String {
  match self {
    Twips(value) => value.to_string()
    Measure(measure) => measure.to_string()
  }
}

///|
/// Part 1 §22.9.2.8 ST_VerticalAlignRun — vertical-alignment for runs.
pub(all) enum ST_VerticalAlignRun {
  /// §22.9.2.8 "baseline"
  Baseline
  /// §22.9.2.8 "superscript"
  Superscript
  /// §22.9.2.8 "subscript"
  Subscript
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.8 — decode the vertical-alignment lexical token.
pub fn ST_VerticalAlignRun::new(
  s : String,
) -> ST_VerticalAlignRun raise SchemaViolation {
  match s {
    "baseline" => Baseline
    "superscript" => Superscript
    "subscript" => Subscript
    _ => violation("ST_VerticalAlignRun", s)
  }
}

///|
/// Render the vertical-alignment enumeration back to its lexical
/// token.
pub fn ST_VerticalAlignRun::to_string(self : ST_VerticalAlignRun) -> String {
  match self {
    Baseline => "baseline"
    Superscript => "superscript"
    Subscript => "subscript"
  }
}

///|
/// Part 1 §22.9.2.17 ST_Xstring — unconstrained xstring shared value.
/// Same lexical surface as ST_String but distinguished at the type
/// level so the schema's separate names remain visible.
pub struct ST_Xstring {
  lexical : String
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.17 — wrap any xstring lexical value.
pub fn ST_Xstring::new(s : String) -> ST_Xstring {
  { lexical: s }
}

///|
/// Return the wrapped lexical form.
pub fn ST_Xstring::to_string(self : ST_Xstring) -> String {
  self.lexical
}

///|
/// XSD simple type ST_XAlign — Part 1 §22.9.2.18 horizontal-alignment
/// enumeration.
pub(all) enum ST_XAlign {
  /// §22.9.2.18 "left"
  Left
  /// §22.9.2.18 "center"
  Center
  /// §22.9.2.18 "right"
  Right
  /// §22.9.2.18 "inside"
  Inside
  /// §22.9.2.18 "outside"
  Outside
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.18 — decode the horizontal-alignment lexical token.
pub fn ST_XAlign::new(s : String) -> ST_XAlign raise SchemaViolation {
  match s {
    "left" => Left
    "center" => Center
    "right" => Right
    "inside" => Inside
    "outside" => Outside
    _ => violation("ST_XAlign", s)
  }
}

///|
/// Render back to lexical token.
pub fn ST_XAlign::to_string(self : ST_XAlign) -> String {
  match self {
    Left => "left"
    Center => "center"
    Right => "right"
    Inside => "inside"
    Outside => "outside"
  }
}

///|
/// Part 1 §22.9.2.19 ST_YAlign — vertical-alignment enumeration.
/// Variant names are prefixed with `Y` where they would otherwise
/// collide with ST_XAlign members.
pub(all) enum ST_YAlign {
  /// §22.9.2.19 "inline"
  Inline
  /// §22.9.2.19 "top"
  Top
  /// §22.9.2.19 "center"
  YCenter
  /// §22.9.2.19 "bottom"
  Bottom
  /// §22.9.2.19 "inside"
  YInside
  /// §22.9.2.19 "outside"
  YOutside
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.19 — decode the vertical-alignment lexical token.
pub fn ST_YAlign::new(s : String) -> ST_YAlign raise SchemaViolation {
  match s {
    "inline" => Inline
    "top" => Top
    "center" => YCenter
    "bottom" => Bottom
    "inside" => YInside
    "outside" => YOutside
    _ => violation("ST_YAlign", s)
  }
}

///|
/// Render back to lexical token.
pub fn ST_YAlign::to_string(self : ST_YAlign) -> String {
  match self {
    Inline => "inline"
    Top => "top"
    YCenter => "center"
    Bottom => "bottom"
    YInside => "inside"
    YOutside => "outside"
  }
}

///|
/// Part 1 §22.9.2.2 ST_ConformanceClass — document conformance
/// enumeration: strict or transitional.
pub(all) enum ST_ConformanceClass {
  /// §22.9.2.2 "strict"
  Strict
  /// §22.9.2.2 "transitional"
  Transitional
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.2 — decode the conformance lexical token.
pub fn ST_ConformanceClass::new(
  s : String,
) -> ST_ConformanceClass raise SchemaViolation {
  match s {
    "strict" => Strict
    "transitional" => Transitional
    _ => violation("ST_ConformanceClass", s)
  }
}

///|
/// Render the conformance class back to its lexical token.
pub fn ST_ConformanceClass::to_string(self : ST_ConformanceClass) -> String {
  match self {
    Strict => "strict"
    Transitional => "transitional"
  }
}

///|
/// Part 1 §22.9.2.9 ST_Percentage — signed decimal percentage stored
/// as the lexical magnitude scaled by 1000 so callers compare /
/// arithmetic at integer precision (the canonical encoding the
/// DrawingML chapter uses for percent attributes).
pub struct ST_Percentage {
  /// 1000ths of a percent. e.g. "12.345%" → 12345.
  thousandths : Int64
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.9 — decode the "<decimal>%" lexical form.
pub fn ST_Percentage::new(s : String) -> ST_Percentage raise SchemaViolation {
  if !is_percentage(s, positive=false, fixed=false) {
    violation("ST_Percentage", s)
  }
  let magnitude_text = s.unsafe_substring(start=0, end=s.length() - 1)
  let thousandths = parse_decimal_scaled(magnitude_text, 3)
  { thousandths, }
}

///|
/// Render back to the lexical "<decimal>%" form. Trailing zeros are
/// trimmed.
pub fn ST_Percentage::to_string(self : ST_Percentage) -> String {
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
/// Numeric accessor for downstream calculations.
pub fn ST_Percentage::thousandths_of_percent(self : ST_Percentage) -> Int64 {
  self.thousandths
}

///|
/// Part 1 §22.9.2.1 ST_FixedPercentage — signed percentage in the
/// closed range −100% to 100%. Same encoding as ST_Percentage.
pub struct ST_FixedPercentage {
  thousandths : Int64
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.1 — decode with the fixed range constraint.
pub fn ST_FixedPercentage::new(
  s : String,
) -> ST_FixedPercentage raise SchemaViolation {
  if !is_percentage(s, positive=false, fixed=true) {
    violation("ST_FixedPercentage", s)
  }
  let magnitude_text = s.unsafe_substring(start=0, end=s.length() - 1)
  let thousandths = parse_decimal_scaled(magnitude_text, 3)
  { thousandths, }
}

///|
/// Render back to the lexical "<decimal>%" form.
pub fn ST_FixedPercentage::to_string(self : ST_FixedPercentage) -> String {
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
/// Numeric accessor.
pub fn ST_FixedPercentage::thousandths_of_percent(
  self : ST_FixedPercentage,
) -> Int64 {
  self.thousandths
}

///|
/// Part 1 §22.9.2.11 ST_PositivePercentage — non-negative percentage.
pub struct ST_PositivePercentage {
  thousandths : Int64
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.11 — decode with the non-negative range constraint.
pub fn ST_PositivePercentage::new(
  s : String,
) -> ST_PositivePercentage raise SchemaViolation {
  if !is_percentage(s, positive=true, fixed=false) {
    violation("ST_PositivePercentage", s)
  }
  let magnitude_text = s.unsafe_substring(start=0, end=s.length() - 1)
  let thousandths = parse_decimal_scaled(magnitude_text, 3)
  { thousandths, }
}

///|
/// Render back to the lexical "<decimal>%" form.
pub fn ST_PositivePercentage::to_string(self : ST_PositivePercentage) -> String {
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
/// Numeric accessor.
pub fn ST_PositivePercentage::thousandths_of_percent(
  self : ST_PositivePercentage,
) -> Int64 {
  self.thousandths
}

///|
/// Part 1 §22.9.2.0 ST_PositiveFixedPercentage — non-negative
/// percentage up to 100%.
pub struct ST_PositiveFixedPercentage {
  thousandths : Int64
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.0 — decode with the non-negative + ≤100 constraint.
pub fn ST_PositiveFixedPercentage::new(
  s : String,
) -> ST_PositiveFixedPercentage raise SchemaViolation {
  if !is_percentage(s, positive=true, fixed=true) {
    violation("ST_PositiveFixedPercentage", s)
  }
  let magnitude_text = s.unsafe_substring(start=0, end=s.length() - 1)
  let thousandths = parse_decimal_scaled(magnitude_text, 3)
  { thousandths, }
}

///|
/// Render back to the lexical "<decimal>%" form.
pub fn ST_PositiveFixedPercentage::to_string(
  self : ST_PositiveFixedPercentage,
) -> String {
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
/// Numeric accessor.
pub fn ST_PositiveFixedPercentage::thousandths_of_percent(
  self : ST_PositiveFixedPercentage,
) -> Int64 {
  self.thousandths
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_AlgClass` —
/// §22.9.2 hash-algorithm class enumeration. Base `xsd:string`.
/// Enumeration values: `hash`, `custom`.
pub(all) enum ST_AlgClass {
  /// Algorithm class denoting a cryptographic hash function.
  AlgClassHash
  /// Algorithm class delegated to a producer-specific definition.
  AlgClassCustom
} derive(Eq, Debug)

///|
/// Parse the ST_AlgClass lexical token, rejecting anything outside the
/// schema-permitted enumeration.
pub fn ST_AlgClass::parse(s : String) -> ST_AlgClass raise SchemaViolation {
  match s {
    "hash" => AlgClassHash
    "custom" => AlgClassCustom
    _ => violation("ST_AlgClass", s)
  }
}

///|
pub fn ST_AlgClass::new(s : String) -> ST_AlgClass raise SchemaViolation {
  ST_AlgClass::parse(s)
}

///|
pub fn ST_AlgClass::to_string(self : ST_AlgClass) -> String {
  match self {
    AlgClassHash => "hash"
    AlgClassCustom => "custom"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_AlgType` —
/// §22.9.2 hash-algorithm type enumeration. Base `xsd:string`.
/// Enumeration values: `typeAny`, `custom`.
pub(all) enum ST_AlgType {
  /// Producer/consumer accepts any algorithm advertised by the file.
  AlgTypeAny
  /// Algorithm whose type is delegated to a producer-specific definition.
  AlgTypeCustom
} derive(Eq, Debug)

///|
pub fn ST_AlgType::parse(s : String) -> ST_AlgType raise SchemaViolation {
  match s {
    "typeAny" => AlgTypeAny
    "custom" => AlgTypeCustom
    _ => violation("ST_AlgType", s)
  }
}

///|
pub fn ST_AlgType::new(s : String) -> ST_AlgType raise SchemaViolation {
  ST_AlgType::parse(s)
}

///|
pub fn ST_AlgType::to_string(self : ST_AlgType) -> String {
  match self {
    AlgTypeAny => "typeAny"
    AlgTypeCustom => "custom"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_CryptProv` —
/// §22.9.2 cryptographic-service-provider class enumeration. Base
/// `xsd:string`. Enumeration values: `rsaAES`, `rsaFull`, `custom`.
pub(all) enum ST_CryptProv {
  /// RSA + AES (Microsoft Enhanced RSA and AES Cryptographic Provider).
  CryptProvRsaAes
  /// RSA Full (Microsoft Base / Enhanced Cryptographic Provider).
  CryptProvRsaFull
  /// Producer-specific custom provider.
  CryptProvCustom
} derive(Eq, Debug)

///|
pub fn ST_CryptProv::parse(s : String) -> ST_CryptProv raise SchemaViolation {
  match s {
    "rsaAES" => CryptProvRsaAes
    "rsaFull" => CryptProvRsaFull
    "custom" => CryptProvCustom
    _ => violation("ST_CryptProv", s)
  }
}

///|
pub fn ST_CryptProv::new(s : String) -> ST_CryptProv raise SchemaViolation {
  ST_CryptProv::parse(s)
}

///|
pub fn ST_CryptProv::to_string(self : ST_CryptProv) -> String {
  match self {
    CryptProvRsaAes => "rsaAES"
    CryptProvRsaFull => "rsaFull"
    CryptProvCustom => "custom"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_ColorType` —
/// §22.9.2 colour-token carrier. Base `xsd:string` (no further
/// restriction); the lexical form is preserved verbatim so callers can
/// distinguish a spec-typed colour string from an arbitrary String.
pub struct ST_ColorType {
  lexical : String
} derive(Eq, Debug)

///|
pub fn ST_ColorType::new(s : String) -> ST_ColorType {
  { lexical: s }
}

///|
pub fn ST_ColorType::to_string(self : ST_ColorType) -> String {
  self.lexical
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_OnOff1` —
/// §22.9.2 on/off lexical-only twin of ST_OnOff. Base `xsd:string`.
/// Enumeration values: `on`, `off`. (ST_OnOff itself is the union over
/// xsd:boolean and ST_OnOff1.)
pub(all) enum ST_OnOff1 {
  /// Lexical "on" — the truthy branch.
  OnOff1On
  /// Lexical "off" — the falsy branch.
  OnOff1Off
} derive(Eq, Debug)

///|
pub fn ST_OnOff1::parse(s : String) -> ST_OnOff1 raise SchemaViolation {
  match s {
    "on" => OnOff1On
    "off" => OnOff1Off
    _ => violation("ST_OnOff1", s)
  }
}

///|
pub fn ST_OnOff1::new(s : String) -> ST_OnOff1 raise SchemaViolation {
  ST_OnOff1::parse(s)
}

///|
pub fn ST_OnOff1::to_bool(self : ST_OnOff1) -> Bool {
  match self {
    OnOff1On => true
    OnOff1Off => false
  }
}

///|
pub fn ST_OnOff1::to_string(self : ST_OnOff1) -> String {
  match self {
    OnOff1On => "on"
    OnOff1Off => "off"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_TrueFalse` —
/// §22.9.2 case-sensitive boolean lexical token. Base `xsd:string`.
/// Enumeration values: `t`, `f`, `true`, `false`. The short forms are
/// the canonical lexical output of legacy VML attributes.
pub(all) enum ST_TrueFalse {
  /// Lexical "t" — short truthy form.
  TrueFalseT
  /// Lexical "f" — short falsy form.
  TrueFalseF
  /// Lexical "true" — long truthy form.
  TrueFalseTrue
  /// Lexical "false" — long falsy form.
  TrueFalseFalse
} derive(Eq, Debug)

///|
pub fn ST_TrueFalse::parse(s : String) -> ST_TrueFalse raise SchemaViolation {
  match s {
    "t" => TrueFalseT
    "f" => TrueFalseF
    "true" => TrueFalseTrue
    "false" => TrueFalseFalse
    _ => violation("ST_TrueFalse", s)
  }
}

///|
pub fn ST_TrueFalse::new(s : String) -> ST_TrueFalse raise SchemaViolation {
  ST_TrueFalse::parse(s)
}

///|
pub fn ST_TrueFalse::to_bool(self : ST_TrueFalse) -> Bool {
  match self {
    TrueFalseT | TrueFalseTrue => true
    TrueFalseF | TrueFalseFalse => false
  }
}

///|
pub fn ST_TrueFalse::to_string(self : ST_TrueFalse) -> String {
  match self {
    TrueFalseT => "t"
    TrueFalseF => "f"
    TrueFalseTrue => "true"
    TrueFalseFalse => "false"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_TrueFalseBlank` —
/// §22.9.2 case-sensitive boolean lexical token with empty + capitalised
/// extensions. Base `xsd:string`. Enumeration values: `t`, `f`, `true`,
/// `false`, ``, `True`, `False`. The empty string is the spec-mandated
/// blank carrier used by VML for "no explicit value supplied".
pub(all) enum ST_TrueFalseBlank {
  /// Lexical "t" — short truthy form.
  TrueFalseBlankT
  /// Lexical "f" — short falsy form.
  TrueFalseBlankF
  /// Lexical "true" — long truthy form.
  TrueFalseBlankTrue
  /// Lexical "false" — long falsy form.
  TrueFalseBlankFalse
  /// Empty lexical — VML "no explicit value" carrier.
  TrueFalseBlankBlank
  /// Lexical "True" — Pascal-case truthy form.
  TrueFalseBlankCapTrue
  /// Lexical "False" — Pascal-case falsy form.
  TrueFalseBlankCapFalse
} derive(Eq, Debug)

///|
pub fn ST_TrueFalseBlank::parse(
  s : String,
) -> ST_TrueFalseBlank raise SchemaViolation {
  match s {
    "t" => TrueFalseBlankT
    "f" => TrueFalseBlankF
    "true" => TrueFalseBlankTrue
    "false" => TrueFalseBlankFalse
    "" => TrueFalseBlankBlank
    "True" => TrueFalseBlankCapTrue
    "False" => TrueFalseBlankCapFalse
    _ => violation("ST_TrueFalseBlank", s)
  }
}

///|
pub fn ST_TrueFalseBlank::new(
  s : String,
) -> ST_TrueFalseBlank raise SchemaViolation {
  ST_TrueFalseBlank::parse(s)
}

///|
/// Project the blank/capitalised lexical variants to a Bool. Blank is
/// treated as `false` per legacy VML "missing value" semantics.
pub fn ST_TrueFalseBlank::to_bool(self : ST_TrueFalseBlank) -> Bool {
  match self {
    TrueFalseBlankT | TrueFalseBlankTrue | TrueFalseBlankCapTrue => true
    TrueFalseBlankF
    | TrueFalseBlankFalse
    | TrueFalseBlankCapFalse
    | TrueFalseBlankBlank => false
  }
}

///|
pub fn ST_TrueFalseBlank::to_string(self : ST_TrueFalseBlank) -> String {
  match self {
    TrueFalseBlankT => "t"
    TrueFalseBlankF => "f"
    TrueFalseBlankTrue => "true"
    TrueFalseBlankFalse => "false"
    TrueFalseBlankBlank => ""
    TrueFalseBlankCapTrue => "True"
    TrueFalseBlankCapFalse => "False"
  }
}

// === Private helpers ===

///|
fn[T] violation(type_name : String, value : String) -> T raise SchemaViolation {
  raise SchemaViolation(type_name~, value~)
}

///|
fn fixed_hex(s : String, len : Int) -> Bool {
  s.length() == len && hex_digits(s, 0, len)
}

///|
fn hex_pair(s : String, offset : Int) -> Int {
  hex_digit_value(s.code_unit_at(offset).to_int()) * 16 +
  hex_digit_value(s.code_unit_at(offset + 1).to_int())
}

///|
fn hex_digit_value(unit : Int) -> Int {
  if unit >= 0x30 && unit <= 0x39 {
    unit - 0x30
  } else if unit >= 0x41 && unit <= 0x46 {
    unit - 0x41 + 10
  } else if unit >= 0x61 && unit <= 0x66 {
    unit - 0x61 + 10
  } else {
    0
  }
}

///|
fn decimal_digit_value_at(s : String, index : Int) -> Int {
  let unit = s.code_unit_at(index).to_int()
  if unit >= 0x30 && unit <= 0x39 {
    unit - 0x30
  } else {
    0
  }
}

///|
fn hex_byte(value : Int) -> String {
  let high = value / 16 % 16
  let low = value % 16
  hex_digit_string(high) + hex_digit_string(low)
}

///|
fn hex_digit_string(value : Int) -> String {
  match value {
    0 => "0"
    1 => "1"
    2 => "2"
    3 => "3"
    4 => "4"
    5 => "5"
    6 => "6"
    7 => "7"
    8 => "8"
    9 => "9"
    10 => "A"
    11 => "B"
    12 => "C"
    13 => "D"
    14 => "E"
    15 => "F"
    _ => "0"
  }
}

///|
fn is_guid(s : String) -> Bool {
  s.length() == 38 &&
  s[0:1] == "{" &&
  hex_digits(s, 1, 9) &&
  s[9:10] == "-" &&
  hex_digits(s, 10, 14) &&
  s[14:15] == "-" &&
  hex_digits(s, 15, 19) &&
  s[19:20] == "-" &&
  hex_digits(s, 20, 24) &&
  s[24:25] == "-" &&
  hex_digits(s, 25, 37) &&
  s[37:38] == "}"
}

///|
fn is_universal_measure(s : String, positive~ : Bool) -> Bool {
  if s.length() < 3 {
    false
  } else {
    let unit = s[s.length() - 2:].to_owned()
    let number_end = s.length() - 2
    is_measure_unit(unit) &&
    is_decimal(s, 0, number_end) &&
    (!positive || decimal_non_negative(s, 0, number_end))
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
fn is_percentage(s : String, positive~ : Bool, fixed~ : Bool) -> Bool {
  if s.length() < 2 || s[s.length() - 1:] != "%" {
    false
  } else {
    let number_end = s.length() - 1
    is_decimal(s, 0, number_end) &&
    (!positive || decimal_non_negative(s, 0, number_end)) &&
    (!fixed || decimal_abs_le_100(s, 0, number_end))
  }
}

///|
fn is_decimal(s : String, start : Int, end : Int) -> Bool {
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
fn is_unsigned_long(s : String) -> Bool {
  if s.length() == 0 || !digits(s, 0, s.length()) {
    false
  } else {
    let trimmed = trim_leading_zeroes(s, 0, s.length())
    let max = "18446744073709551615"
    trimmed.length() < max.length() ||
    (trimmed.length() == max.length() && trimmed <= max)
  }
}

///|
fn parse_unsigned_long(s : String) -> UInt64 {
  let mut value : UInt64 = 0UL
  for i in 0..<s.length() {
    let digit = decimal_digit_value_at(s, i).to_uint64()
    value = value * 10UL + digit
  }
  value
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
    let digit = decimal_digit_value_at(s, pos).to_double()
    whole = whole * 10.0 + digit
    pos = pos + 1
  }
  let mut fraction = 0.0
  let mut scale = 1.0
  if pos < s.length() && s[pos:pos + 1] == "." {
    pos = pos + 1
    while pos < s.length() && is_digit_at(s, pos) {
      scale = scale * 10.0
      let digit = decimal_digit_value_at(s, pos).to_double()
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
    let digit = decimal_digit_value_at(s, pos).to_int64()
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
      let digit = decimal_digit_value_at(s, pos).to_int64()
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
  // Trim trailing zeros from the fractional part.
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
  // Match the lexical form ECMA-376 emits: integer-only when value
  // is mathematically integral, otherwise the platform Double::to_string.
  if value == value.trunc() && value.abs() < 1.0e15 {
    value.to_int64().to_string()
  } else {
    value.to_string()
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
fn digits(s : String, start : Int, end : Int) -> Bool {
  let mut ok = start >= 0 && end <= s.length() && start < end
  for i in start..<end {
    ok = ok && is_digit_at(s, i)
  }
  ok
}

///|
fn hex_digits(s : String, start : Int, end : Int) -> Bool {
  let mut ok = start >= 0 && end <= s.length() && start < end
  for i in start..<end {
    ok = ok && is_hex_at(s, i)
  }
  ok
}

///|
fn is_digit_at(s : String, index : Int) -> Bool {
  s[index:index + 1] >= "0" && s[index:index + 1] <= "9"
}

///|
fn is_ascii_alpha_at(s : String, index : Int) -> Bool {
  (s[index:index + 1] >= "A" && s[index:index + 1] <= "Z") ||
  (s[index:index + 1] >= "a" && s[index:index + 1] <= "z")
}

///|
fn is_hex_at(s : String, index : Int) -> Bool {
  is_digit_at(s, index) ||
  (s[index:index + 1] >= "A" && s[index:index + 1] <= "F") ||
  (s[index:index + 1] >= "a" && s[index:index + 1] <= "f")
}
