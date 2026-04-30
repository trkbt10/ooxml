///|
/// Schema shared-math.xsd validation error for OMML (§22.1).
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String)
} derive(Debug)

///|
/// XSD simple type ST_Integer255 (§22.1.x).
pub struct ST_Integer255 {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Integer255::parse(s : String) -> ST_Integer255 raise SchemaViolation {
  validate_int("ST_Integer255", s)
  { value: s }
}

///|
pub fn ST_Integer255::to_string(self : ST_Integer255) -> String {
  self.value
}

///|
/// XSD simple type ST_Integer2 (§22.1.x).
pub struct ST_Integer2 {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Integer2::parse(s : String) -> ST_Integer2 raise SchemaViolation {
  validate_int("ST_Integer2", s)
  { value: s }
}

///|
pub fn ST_Integer2::to_string(self : ST_Integer2) -> String {
  self.value
}

///|
/// XSD simple type ST_SpacingRule (§22.1.x).
pub struct ST_SpacingRule {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SpacingRule::parse(
  s : String,
) -> ST_SpacingRule raise SchemaViolation {
  validate_int("ST_SpacingRule", s)
  { value: s }
}

///|
pub fn ST_SpacingRule::to_string(self : ST_SpacingRule) -> String {
  self.value
}

///|
/// XSD simple type ST_UnSignedInteger (§22.1.x).
pub struct ST_UnSignedInteger {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_UnSignedInteger::parse(
  s : String,
) -> ST_UnSignedInteger raise SchemaViolation {
  validate_unsigned_int("ST_UnSignedInteger", s)
  { value: s }
}

///|
pub fn ST_UnSignedInteger::to_string(self : ST_UnSignedInteger) -> String {
  self.value
}

///|
/// XSD simple type ST_Char (§22.1.x).
pub struct ST_Char {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Char::parse(s : String) -> ST_Char raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_Char", s)
  }
  { value: s }
}

///|
pub fn ST_Char::to_string(self : ST_Char) -> String {
  self.value
}

///|
/// XSD simple type ST_Shp (§22.1.x).
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
fn validate_int(type_name : String, s : String) -> Unit raise SchemaViolation {
  if !is_int(s) {
    invalid(type_name, s)
  }
}

///|
fn validate_unsigned_int(
  type_name : String,
  s : String,
) -> Unit raise SchemaViolation {
  if !is_unsigned_int(s) {
    invalid(type_name, s)
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
fn is_unsigned_int(s : String) -> Bool {
  s.length() > 0 && digits(s, 0, s.length())
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
