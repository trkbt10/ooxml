///|
/// Part 1 §17.18.59 ST_NumberFormat — the canonical numFmt values used
/// in §17.9.17 numFmt. The spec lists 30+ formats; this evaluator
/// covers the 11 that drive the common bullet / counter rendering and
/// downgrades the rest to decimal at format time, recording the
/// downgrade so renderers can warn.
pub(all) enum NumFormat {
  /// §17.18.59 decimal — Arabic numerals.
  NfDecimal
  /// §17.18.59 upperRoman — uppercase Roman numerals (I, II, III, …).
  NfUpperRoman
  /// §17.18.59 lowerRoman — lowercase Roman numerals.
  NfLowerRoman
  /// §17.18.59 upperLetter — A, B, …, Z, AA, …
  NfUpperLetter
  /// §17.18.59 lowerLetter — a, b, …, z, aa, …
  NfLowerLetter
  /// §17.18.59 ordinal — 1st, 2nd, 3rd, 4th, …
  NfOrdinal
  /// §17.18.59 cardinalText — One, Two, Three, … (English).
  NfCardinalText
  /// §17.18.59 ordinalText — First, Second, Third, …
  NfOrdinalText
  /// §17.18.59 bullet — the literal lvlText character.
  NfBullet
  /// §17.18.59 none — no counter.
  NfNone
  /// §17.18.59 decimalZero — leading-zero decimal (01, 02, …, 09, 10).
  NfDecimalZero
} derive(Eq, Debug)

///|
/// Part 1 §17.18.59 — decode a ST_NumberFormat lexical value. Unknown
/// values from the wider spec table fall through to `NfDecimal` so the
/// resolver always returns something renderable; the diagnostic is
/// preserved by `NumFormat::from_attr_strict` (used by tests).
pub fn NumFormat::from_attr(value : String) -> NumFormat {
  match value {
    "decimal" => NfDecimal
    "upperRoman" => NfUpperRoman
    "lowerRoman" => NfLowerRoman
    "upperLetter" => NfUpperLetter
    "lowerLetter" => NfLowerLetter
    "ordinal" => NfOrdinal
    "cardinalText" => NfCardinalText
    "ordinalText" => NfOrdinalText
    "bullet" => NfBullet
    "none" => NfNone
    "decimalZero" => NfDecimalZero
    _ => NfDecimal
  }
}

///|
/// Part 1 §17.18.59 — strict variant that raises on unknown lexical
/// values. Useful for tests; the renderer should use `from_attr` and
/// log when the format falls through.
pub fn NumFormat::from_attr_strict(
  value : String,
) -> NumFormat raise @opc_errors.SchemaViolation {
  match value {
    "decimal" => NfDecimal
    "upperRoman" => NfUpperRoman
    "lowerRoman" => NfLowerRoman
    "upperLetter" => NfUpperLetter
    "lowerLetter" => NfLowerLetter
    "ordinal" => NfOrdinal
    "cardinalText" => NfCardinalText
    "ordinalText" => NfOrdinalText
    "bullet" => NfBullet
    "none" => NfNone
    "decimalZero" => NfDecimalZero
    _ =>
      raise @opc_errors.SchemaViolation(
        section=numbering_section,
        path="lvl/numFmt/@val",
        reason="unknown ST_NumberFormat lexical value: " + value,
      )
  }
}

///|
/// Part 1 §17.9.11 lvlText / §17.18.59 — render a counter value using
/// the supplied NumFormat. `NfBullet` and `NfNone` return the empty
/// string (callers use the literal lvlText separately for bullets);
/// the unsupported / fall-through formats round-trip to decimal.
pub fn NumFormat::format(self : NumFormat, value : Int) -> String {
  match self {
    NfDecimal => value.to_string()
    NfDecimalZero =>
      if value < 10 {
        "0" + value.to_string()
      } else {
        value.to_string()
      }
    NfUpperRoman => to_roman(value, true)
    NfLowerRoman => to_roman(value, false)
    NfUpperLetter => to_letter(value, true)
    NfLowerLetter => to_letter(value, false)
    NfOrdinal => to_ordinal(value)
    NfCardinalText => to_cardinal_text(value)
    NfOrdinalText => to_ordinal_text(value)
    NfBullet => ""
    NfNone => ""
  }
}

///|
/// Part 1 §17.18.46 ST_Jc — justification for the lvlJc element. Five
/// values: start, center, end, both, num (legacy `left` and `right`
/// aliases collapse to `start` / `end` per the §17.18.46 table).
pub(all) enum LvlJustification {
  JcStart
  JcCenter
  JcEnd
  JcBoth
  JcNum
} derive(Eq, Debug)

///|
/// Part 1 §17.18.46 — decode a ST_Jc lexical value for §17.9.7 lvlJc.
/// `left` collapses to `JcStart`, `right` to `JcEnd`, per the legacy
/// aliases footnote in §17.18.46.
pub fn LvlJustification::from_attr(
  value : String,
) -> LvlJustification raise @opc_errors.SchemaViolation {
  match value {
    "start" => JcStart
    "left" => JcStart
    "center" => JcCenter
    "end" => JcEnd
    "right" => JcEnd
    "both" => JcBoth
    "num" => JcNum
    _ =>
      raise @opc_errors.SchemaViolation(
        section=numbering_section,
        path="lvl/lvlJc/@val",
        reason="unknown ST_Jc lexical value: " + value,
      )
  }
}

///|
/// Part 1 §17.9.27 suff — what character follows the lvlText. Three
/// values: tab, space, nothing.
pub(all) enum LvlSuffix {
  SuffTab
  SuffSpace
  SuffNothing
} derive(Eq, Debug)

///|
/// Part 1 §17.9.27 — decode a `suff` lexical value.
pub fn LvlSuffix::from_attr(
  value : String,
) -> LvlSuffix raise @opc_errors.SchemaViolation {
  match value {
    "tab" => SuffTab
    "space" => SuffSpace
    "nothing" => SuffNothing
    _ =>
      raise @opc_errors.SchemaViolation(
        section=numbering_section,
        path="lvl/suff/@val",
        reason="unknown lvl suffix lexical value: " + value,
      )
  }
}

///|
/// Part 1 §17.9.12 multiLevelType — abstract numbering definition
/// kind. Three values: singleLevel, multilevel, hybridMultilevel.
pub(all) enum MultiLevelType {
  MltSingleLevel
  MltMultilevel
  MltHybridMultilevel
} derive(Eq, Debug)

///|
/// Part 1 §17.9.12 — decode a multiLevelType lexical value. Unknown
/// values raise so the document is rejected (matches the spec
/// restriction list).
pub fn MultiLevelType::from_attr(
  value : String,
) -> MultiLevelType raise @opc_errors.SchemaViolation {
  match value {
    "singleLevel" => MltSingleLevel
    "multilevel" => MltMultilevel
    "hybridMultilevel" => MltHybridMultilevel
    _ =>
      raise @opc_errors.SchemaViolation(
        section=numbering_section,
        path="abstractNum/multiLevelType/@val",
        reason="unknown multiLevelType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §17.9.6 lvl — typed view of a single numbering level. Every
/// per-lvl property is captured; the pPr / rPr child elements are
/// preserved as `@xml.Element?` so the renderer can pass them through
/// to the DML / wml property merge unchanged.
pub(all) struct Lvl {
  ilvl : Int
  start : Int?
  num_fmt : NumFormat?
  lvl_text : String?
  lvl_jc : LvlJustification?
  lvl_restart : Int?
  p_style : String?
  suff : LvlSuffix?
  is_lgl : Bool
  lvl_pic_bullet_id : Int?
  p_pr_element : @xml.Element?
  r_pr_element : @xml.Element?
} derive(Eq, Debug)

///|
/// Lvl::has_pic_bullet — true when `lvl_pic_bullet_id` is set; useful
/// for renderers that swap the lvlText for a picture glyph.
pub fn Lvl::has_pic_bullet(self : Lvl) -> Bool {
  match self.lvl_pic_bullet_id {
    Some(id) => if id >= 0 { true } else { false }
    None => false
  }
}

///|
/// Part 1 §17.9.1 abstractNum — typed view of an abstract numbering
/// definition. `lvls` is sorted ascending by `ilvl` so callers can
/// binary-search if they want; the resolver does a linear scan.
pub(all) struct AbstractNum {
  abstract_num_id : Int
  multi_level_type : MultiLevelType?
  name : String?
  nsid : String?
  tmpl : String?
  style_link : String?
  num_style_link : String?
  lvls : Array[Lvl]
} derive(Eq, Debug)

///|
/// Part 1 §17.9.8 lvlOverride — per-ilvl override carried on a num.
/// Either `start_override` (§17.9.26 startOverride) or a complete
/// `lvl` substitution from §17.9.5.
pub(all) struct LvlOverride {
  ilvl : Int
  start_override : Int?
  lvl : Lvl?
} derive(Eq, Debug)

///|
/// Part 1 §17.9.15 num — numbering definition instance. Carries the
/// `numId` (referenced from `p/pPr/numPr/numId`) and the link to its
/// `abstractNumId` plus the lvlOverride entries.
pub(all) struct Num {
  num_id : Int
  abstract_num_id : Int
  lvl_overrides : Array[LvlOverride]
} derive(Eq, Debug)

///|
/// Part 1 §17.9 — the numbering table: every abstractNum keyed by
/// `abstractNumId` and every num keyed by `numId`. Pic bullets are
/// indexed separately so the renderer can resolve `lvl_pic_bullet_id`
/// without re-scanning.
pub(all) struct NumberingTable {
  abstract_nums : @hashmap.HashMap[Int, AbstractNum]
  nums : @hashmap.HashMap[Int, Num]
  pic_bullets : @hashmap.HashMap[Int, @xml.Element]
}

///|
/// LevelOrigin — provenance of a resolved level. Used by renderers
/// that want to audit whether the level came from a num's
/// lvlOverride, from the directly-referenced abstractNum, or from a
/// numStyleLink chain follow-up.
pub(all) enum LevelOrigin {
  SourceOverride
  SourceAbstract
  SourceLinkedAbstract
} derive(Eq, Debug)

///|
/// Result of `NumberingTable::resolve_level`. Carries the chosen lvl
/// plus the origin for diagnostics.
pub(all) struct ResolvedLvl {
  lvl : Lvl
  origin : LevelOrigin
} derive(Eq, Debug)

///|
let numbering_section : String = "Part 1 §17.9"

///|
/// Part 1 §17.9 — citation helper exposed so callers can include the
/// canonical section anchor in their own diagnostics.
pub fn numbering_part1_17_9_section_name() -> String {
  numbering_section
}

///|
/// Roman-numeral conversion shared by `NfUpperRoman` / `NfLowerRoman`.
/// Supports 1..3999 with the standard subtractive notation; values
/// outside that range fall back to decimal so callers always get a
/// non-empty string.
fn to_roman(value : Int, upper : Bool) -> String {
  if value < 1 || value > 3999 {
    return value.to_string()
  }
  let symbols_upper = [
    "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I",
  ]
  let symbols_lower = [
    "m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i",
  ]
  let values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
  let symbols = if upper { symbols_upper } else { symbols_lower }
  let buf = StringBuilder::new()
  let mut remaining = value
  for i in 0..<values.length() {
    while remaining >= values[i] {
      buf.write_string(symbols[i])
      remaining = remaining - values[i]
    }
  }
  buf.to_string()
}

///|
/// Spreadsheet-style letter conversion shared by `NfUpperLetter` /
/// `NfLowerLetter`. 1 → A, 26 → Z, 27 → AA, 53 → BA, …
fn to_letter(value : Int, upper : Bool) -> String {
  if value < 1 {
    return value.to_string()
  }
  let base : Int = if upper { 0x41 } else { 0x61 }
  let buf : Array[Int] = []
  let mut remaining = value
  while remaining > 0 {
    let zero_based = (remaining - 1) % 26
    buf.push(base + zero_based)
    remaining = (remaining - 1) / 26
  }
  let chars : Array[Char] = []
  let mut i = buf.length() - 1
  while i >= 0 {
    chars.push(buf[i].to_char().unwrap())
    i = i - 1
  }
  let sb = StringBuilder::new()
  for ch in chars {
    sb.write_char(ch)
  }
  sb.to_string()
}

///|
/// English ordinal suffix table. Word's `ordinal` rule: 1st, 2nd, 3rd,
/// 4th, … with the 11/12/13 exception.
fn to_ordinal(value : Int) -> String {
  let suffix = ordinal_suffix(value)
  value.to_string() + suffix
}

///|
fn ordinal_suffix(value : Int) -> String {
  let abs_v = if value < 0 { -value } else { value }
  let last_two = abs_v % 100
  if last_two >= 11 && last_two <= 13 {
    return "th"
  }
  let last = abs_v % 10
  if last == 1 {
    "st"
  } else if last == 2 {
    "nd"
  } else if last == 3 {
    "rd"
  } else {
    "th"
  }
}

///|
/// English cardinal text for the 1..20 range. Outside that range the
/// formatter falls back to decimal because the spec's "cardinalText"
/// behaviour beyond 20 is locale-dependent.
fn to_cardinal_text(value : Int) -> String {
  let table = [
    "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
    "Eighteen", "Nineteen", "Twenty",
  ]
  if value >= 0 && value < table.length() {
    table[value]
  } else {
    value.to_string()
  }
}

///|
/// English ordinal text for the 1..20 range with the same fall-back.
fn to_ordinal_text(value : Int) -> String {
  let table = [
    "Zeroth", "First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh",
    "Eighth", "Ninth", "Tenth", "Eleventh", "Twelfth", "Thirteenth", "Fourteenth",
    "Fifteenth", "Sixteenth", "Seventeenth", "Eighteenth", "Nineteenth", "Twentieth",
  ]
  if value >= 0 && value < table.length() {
    table[value]
  } else {
    value.to_string()
  }
}
