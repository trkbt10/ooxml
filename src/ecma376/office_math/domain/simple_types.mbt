///|
/// Schema shared-math.xsd validation error for OMML (§22.1).
pub(all) suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String)
} derive(Debug)

///|
/// XSD simple type ST_Char — Part 1 §22.1.3.3 single-character string
/// (xsd:string restricted to maximum length 1). The character is stored
/// as a typed `Char` (Unicode scalar value), not the raw lexical string,
/// so callers can interrogate the character without re-parsing.
pub struct ST_Char {
  character : Char
} derive(Eq, Debug)

///|
/// Part 1 §22.1.3.3 — decode the lexical form to a single Unicode
/// scalar. Empty strings and strings holding more than one Unicode
/// character (including BMP code units that aren't surrogate-paired
/// with their other half) are rejected per the "max length 1" facet.
pub fn ST_Char::parse(s : String) -> ST_Char raise SchemaViolation {
  match decode_single_char(s) {
    Some(ch) => { character: ch }
    None => invalid("ST_Char", s)
  }
}

///|
/// Render the single character back to its canonical lexical form.
pub fn ST_Char::to_string(self : ST_Char) -> String {
  self.character.to_string()
}

///|
/// Accessor — the wrapped Unicode scalar.
pub fn ST_Char::to_char(self : ST_Char) -> Char {
  self.character
}

///|
/// XSD simple type ST_Integer2 — Part 1 §22.1.3.5 xsd:integer
/// restricted to the closed range [-2, +2]. Stored as a native `Int`
/// so callers do not have to re-parse the lexical form.
pub struct ST_Integer2 {
  value : Int
} derive(Eq, Debug)

///|
/// Part 1 §22.1.3.5 — decode the signed-integer lexical form, raising
/// when the value falls outside [-2, +2].
pub fn ST_Integer2::parse(s : String) -> ST_Integer2 raise SchemaViolation {
  let value = parse_signed_int("ST_Integer2", s)
  if value < -2 || value > 2 {
    invalid("ST_Integer2", s)
  }
  { value, }
}

///|
/// Render the integer back to its canonical lexical form (no leading
/// `+`, matching xsd:integer's canonical representation).
pub fn ST_Integer2::to_string(self : ST_Integer2) -> String {
  self.value.to_string()
}

///|
/// Numeric accessor.
pub fn ST_Integer2::to_int(self : ST_Integer2) -> Int {
  self.value
}

///|
/// XSD simple type ST_Integer255 — Part 1 §22.1.3.6 xsd:integer
/// restricted to the closed range [1, 255]. Stored as a native `Int`.
pub struct ST_Integer255 {
  value : Int
} derive(Eq, Debug)

///|
/// Part 1 §22.1.3.6 — decode the signed-integer lexical form, raising
/// when the value falls outside [1, 255].
pub fn ST_Integer255::parse(s : String) -> ST_Integer255 raise SchemaViolation {
  let value = parse_signed_int("ST_Integer255", s)
  if value < 1 || value > 255 {
    invalid("ST_Integer255", s)
  }
  { value, }
}

///|
/// Render the integer back to its canonical lexical form.
pub fn ST_Integer255::to_string(self : ST_Integer255) -> String {
  self.value.to_string()
}

///|
/// Numeric accessor.
pub fn ST_Integer255::to_int(self : ST_Integer255) -> Int {
  self.value
}

///|
/// XSD simple type ST_SpacingRule — Part 1 §22.1.3.11 xsd:integer
/// restricted to the closed range [0, 4] (the five matrix row-spacing
/// rules). Stored as a native `Int`.
pub struct ST_SpacingRule {
  value : Int
} derive(Eq, Debug)

///|
/// Part 1 §22.1.3.11 — decode the signed-integer lexical form, raising
/// when the value falls outside [0, 4].
pub fn ST_SpacingRule::parse(
  s : String,
) -> ST_SpacingRule raise SchemaViolation {
  let value = parse_signed_int("ST_SpacingRule", s)
  if value < 0 || value > 4 {
    invalid("ST_SpacingRule", s)
  }
  { value, }
}

///|
/// Render the integer back to its canonical lexical form.
pub fn ST_SpacingRule::to_string(self : ST_SpacingRule) -> String {
  self.value.to_string()
}

///|
/// Numeric accessor.
pub fn ST_SpacingRule::to_int(self : ST_SpacingRule) -> Int {
  self.value
}

///|
/// XSD simple type ST_UnSignedInteger — Part 1 §22.1.3.14
/// xsd:unsignedInt (0 to 2^32 − 1). Stored as a native `UInt` so
/// callers can do arithmetic without re-parsing the lexical form.
pub struct ST_UnSignedInteger {
  value : UInt
} derive(Eq, Debug)

///|
/// Part 1 §22.1.3.14 — decode the unsigned-integer lexical form.
pub fn ST_UnSignedInteger::parse(
  s : String,
) -> ST_UnSignedInteger raise SchemaViolation {
  if !is_unsigned_int_lexical(s) {
    invalid("ST_UnSignedInteger", s)
  }
  match parse_uint32(s) {
    Some(value) => { value, }
    None => invalid("ST_UnSignedInteger", s)
  }
}

///|
/// Render the value back to its canonical decimal lexical form.
pub fn ST_UnSignedInteger::to_string(self : ST_UnSignedInteger) -> String {
  self.value.to_string()
}

///|
/// Numeric accessor.
pub fn ST_UnSignedInteger::to_uint(self : ST_UnSignedInteger) -> UInt {
  self.value
}

///|
/// XSD simple type ST_Shp (§22.1.x).
/// OMML shape enumeration with centered and match values.
pub(all) enum ST_Shp {
  Centered
  Match
} derive(Eq, Debug)

///|
pub fn ST_Shp::parse(s : String) -> ST_Shp raise SchemaViolation {
  match s {
    "centered" => Centered
    "match" => Match
    _ => invalid("ST_Shp", s)
  }
}

///|
pub fn ST_Shp::to_string(self : ST_Shp) -> String {
  match self {
    Centered => "centered"
    Match => "match"
  }
}

///|
/// XSD simple type ST_FType (§22.1.x).
pub(all) enum ST_FType {
  Bar
  Skw
  Lin
  NoBar
} derive(Eq, Debug)

///|
pub fn ST_FType::parse(s : String) -> ST_FType raise SchemaViolation {
  match s {
    "bar" => Bar
    "skw" => Skw
    "lin" => Lin
    "noBar" => NoBar
    _ => invalid("ST_FType", s)
  }
}

///|
pub fn ST_FType::to_string(self : ST_FType) -> String {
  match self {
    Bar => "bar"
    Skw => "skw"
    Lin => "lin"
    NoBar => "noBar"
  }
}

///|
/// XSD simple type ST_LimLoc (§22.1.x).
pub(all) enum ST_LimLoc {
  UndOvr
  SubSup
} derive(Eq, Debug)

///|
pub fn ST_LimLoc::parse(s : String) -> ST_LimLoc raise SchemaViolation {
  match s {
    "undOvr" => UndOvr
    "subSup" => SubSup
    _ => invalid("ST_LimLoc", s)
  }
}

///|
pub fn ST_LimLoc::to_string(self : ST_LimLoc) -> String {
  match self {
    UndOvr => "undOvr"
    SubSup => "subSup"
  }
}

///|
/// XSD simple type ST_TopBot (§22.1.x).
pub(all) enum ST_TopBot {
  Top
  Bot
} derive(Eq, Debug)

///|
pub fn ST_TopBot::parse(s : String) -> ST_TopBot raise SchemaViolation {
  match s {
    "top" => Top
    "bot" => Bot
    _ => invalid("ST_TopBot", s)
  }
}

///|
pub fn ST_TopBot::to_string(self : ST_TopBot) -> String {
  match self {
    Top => "top"
    Bot => "bot"
  }
}

///|
/// XSD simple type ST_Script (§22.1.x).
/// OMML script enumeration with roman, script, fraktur, double-struck, sans-serif, and monospace values.
pub(all) enum ST_Script {
  Roman
  Script
  Fraktur
  DoubleStruck
  SansSerif
  Monospace
} derive(Eq, Debug)

///|
pub fn ST_Script::parse(s : String) -> ST_Script raise SchemaViolation {
  match s {
    "roman" => Roman
    "script" => Script
    "fraktur" => Fraktur
    "double-struck" => DoubleStruck
    "sans-serif" => SansSerif
    "monospace" => Monospace
    _ => invalid("ST_Script", s)
  }
}

///|
pub fn ST_Script::to_string(self : ST_Script) -> String {
  match self {
    Roman => "roman"
    Script => "script"
    Fraktur => "fraktur"
    DoubleStruck => "double-struck"
    SansSerif => "sans-serif"
    Monospace => "monospace"
  }
}

///|
/// XSD simple type ST_Style (§22.1.x).
pub(all) enum ST_Style {
  Plain
  Bold
  Italic
  BoldItalic
} derive(Eq, Debug)

///|
pub fn ST_Style::parse(s : String) -> ST_Style raise SchemaViolation {
  match s {
    "p" => Plain
    "b" => Bold
    "i" => Italic
    "bi" => BoldItalic
    _ => invalid("ST_Style", s)
  }
}

///|
pub fn ST_Style::to_string(self : ST_Style) -> String {
  match self {
    Plain => "p"
    Bold => "b"
    Italic => "i"
    BoldItalic => "bi"
  }
}

///|
/// XSD simple type ST_Jc (§22.1.x).
/// OMML math justification enumeration: left, right, center, centerGroup.
pub(all) enum ST_Jc {
  Left
  Right
  Center
  CenterGroup
} derive(Eq, Debug)

///|
pub fn ST_Jc::parse(s : String) -> ST_Jc raise SchemaViolation {
  match s {
    "left" => Left
    "right" => Right
    "center" => Center
    "centerGroup" => CenterGroup
    _ => invalid("ST_Jc", s)
  }
}

///|
pub fn ST_Jc::to_string(self : ST_Jc) -> String {
  match self {
    Left => "left"
    Right => "right"
    Center => "center"
    CenterGroup => "centerGroup"
  }
}

///|
/// XSD simple type ST_BreakBin (§22.1.x).
pub(all) enum ST_BreakBin {
  Before
  After
  Repeat
} derive(Eq, Debug)

///|
pub fn ST_BreakBin::parse(s : String) -> ST_BreakBin raise SchemaViolation {
  match s {
    "before" => Before
    "after" => After
    "repeat" => Repeat
    _ => invalid("ST_BreakBin", s)
  }
}

///|
pub fn ST_BreakBin::to_string(self : ST_BreakBin) -> String {
  match self {
    Before => "before"
    After => "after"
    Repeat => "repeat"
  }
}

///|
/// XSD simple type ST_BreakBinSub (§22.1.x).
pub(all) enum ST_BreakBinSub {
  MinusMinus
  MinusPlus
  PlusMinus
} derive(Eq, Debug)

///|
pub fn ST_BreakBinSub::parse(
  s : String,
) -> ST_BreakBinSub raise SchemaViolation {
  match s {
    "--" => MinusMinus
    "-+" => MinusPlus
    "+-" => PlusMinus
    _ => invalid("ST_BreakBinSub", s)
  }
}

///|
pub fn ST_BreakBinSub::to_string(self : ST_BreakBinSub) -> String {
  match self {
    MinusMinus => "--"
    MinusPlus => "-+"
    PlusMinus => "+-"
  }
}

///|
fn[T] invalid(type_name : String, value : String) -> T raise SchemaViolation {
  raise SchemaViolation(type_name~, value~)
}

///|
/// Decode a string to a single Unicode scalar value, returning None
/// when the string is empty or contains more than one Unicode
/// character. Handles UTF-16 surrogate pairs so that non-BMP scalars
/// (encoded as two code units in MoonBit's UTF-16 String) still count
/// as one logical character.
fn decode_single_char(s : String) -> Char? {
  let len = s.length()
  if len == 0 {
    None
  } else {
    let first = s.code_unit_at(0).to_int()
    if first >= 0xD800 && first <= 0xDBFF {
      // High surrogate — expect a low surrogate to complete the pair.
      if len != 2 {
        None
      } else {
        let second = s.code_unit_at(1).to_int()
        if second < 0xDC00 || second > 0xDFFF {
          None
        } else {
          let scalar = 0x10000 + (first - 0xD800) * 0x400 + (second - 0xDC00)
          Some(scalar.unsafe_to_char())
        }
      }
    } else if first >= 0xDC00 && first <= 0xDFFF {
      // Stray low surrogate is not a valid character.
      None
    } else if len != 1 {
      None
    } else {
      Some(first.unsafe_to_char())
    }
  }
}

///|
/// Lexical check for xsd:integer: optional sign followed by one or
/// more ASCII decimal digits.
fn is_signed_int_lexical(s : String) -> Bool {
  if s.length() == 0 {
    false
  } else {
    let mut start = 0
    if s[0:1] == "-" || s[0:1] == "+" {
      start = 1
    }
    start < s.length() && all_digits(s, start, s.length())
  }
}

///|
/// Lexical check for xsd:unsignedInt: one or more ASCII decimal
/// digits (no sign).
fn is_unsigned_int_lexical(s : String) -> Bool {
  s.length() > 0 && all_digits(s, 0, s.length())
}

///|
fn all_digits(s : String, start : Int, end : Int) -> Bool {
  let mut ok = start >= 0 && end <= s.length() && start < end
  for i in start..<end {
    let ch = s[i:i + 1]
    ok = ok && ch >= "0" && ch <= "9"
  }
  ok
}

///|
/// Decode an xsd:integer lexical form to a native Int, raising on any
/// lexical mismatch. Numeric overflow (beyond Int's 32-bit range) also
/// raises so that downstream code never silently mis-stores a value.
fn parse_signed_int(
  type_name : String,
  s : String,
) -> Int raise SchemaViolation {
  if !is_signed_int_lexical(s) {
    invalid(type_name, s)
  }
  let mut start = 0
  let mut negative = false
  if s[0:1] == "-" {
    negative = true
    start = 1
  } else if s[0:1] == "+" {
    start = 1
  }
  // Detect overflow: 2^31 = 2147483648 (10 digits). Anything longer
  // than 10 digits is guaranteed overflow.
  let digit_count = s.length() - start
  if digit_count > 10 {
    invalid(type_name, s)
  }
  let mut acc : Int64 = 0L
  for i in start..<s.length() {
    let d = (s.code_unit_at(i).to_int() - 0x30).to_int64()
    acc = acc * 10L + d
  }
  let limit_positive : Int64 = 2147483647L
  let limit_negative : Int64 = 2147483648L
  if negative {
    if acc > limit_negative {
      invalid(type_name, s)
    }
    (-acc).to_int()
  } else {
    if acc > limit_positive {
      invalid(type_name, s)
    }
    acc.to_int()
  }
}

///|
/// Decode an xsd:unsignedInt lexical form (already validated as
/// digits-only by the caller) to a UInt, returning None on overflow.
fn parse_uint32(s : String) -> UInt? {
  // 2^32 − 1 = 4294967295 (10 digits). Strings longer than 10 digits
  // are guaranteed to overflow.
  if s.length() > 10 {
    None
  } else {
    let mut acc : UInt64 = 0UL
    for i in 0..<s.length() {
      let d = (s.code_unit_at(i).to_int() - 0x30).to_uint64()
      acc = acc * 10UL + d
    }
    let limit : UInt64 = 4294967295UL
    if acc > limit {
      None
    } else {
      Some(acc.to_uint())
    }
  }
}
