///|
/// Part 1 §18.3.1.10 — case-insensitive substring search used by
/// `containsText`, `notContainsText`, `beginsWith`, `endsWith`, and the
/// §18.18.15 `OpContainsText` / `OpNotContains` / `OpBeginsWith` /
/// `OpEndsWith` cellIs operators. Returns true when `needle` appears at
/// or after position 0 in `haystack` after both are upper-cased; mirrors
/// the SEARCH() reference in §18.18.12 ContainsText.
fn contains_ci(haystack : String, needle : String) -> Bool {
  if needle.length() == 0 {
    return true
  }
  let h = haystack.to_upper()
  let n = needle.to_upper()
  if n.length() > h.length() {
    return false
  }
  for pos in 0..<=(h.length() - n.length()) {
    let mut matched = true
    for i in 0..<n.length() {
      if h.code_unit_at(pos + i) != n.code_unit_at(i) {
        matched = false
        break
      }
    }
    if matched {
      return true
    }
  }
  false
}

///|
/// Case-insensitive prefix test for `beginsWith` rules (§18.18.12).
fn starts_with_ci(haystack : String, needle : String) -> Bool {
  if needle.length() > haystack.length() {
    return false
  }
  let h = haystack.to_upper()
  let n = needle.to_upper()
  for i in 0..<n.length() {
    if h.code_unit_at(i) != n.code_unit_at(i) {
      return false
    }
  }
  true
}

///|
/// Case-insensitive suffix test for `endsWith` rules (§18.18.12).
fn ends_with_ci(haystack : String, needle : String) -> Bool {
  if needle.length() > haystack.length() {
    return false
  }
  let h = haystack.to_upper()
  let n = needle.to_upper()
  let offset = h.length() - n.length()
  for i in 0..<n.length() {
    if h.code_unit_at(offset + i) != n.code_unit_at(i) {
      return false
    }
  }
  true
}

///|
/// Part 1 §18.18.12 — `containsBlanks` / `notContainsBlanks` rules use
/// `LEN(TRIM(value)) = 0`. An empty cell is blank; a cell whose value is
/// only whitespace is blank.
fn is_blank_value(value : @formula.FormulaValue) -> Bool {
  match value {
    @formula.VEmpty => true
    @formula.VString(text) => {
      for i in 0..<text.length() {
        let unit = text.code_unit_at(i).to_int()
        if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
/// Part 1 §18.18.12 — `containsErrors` / `notContainsErrors`. Matches
/// the seven canonical error literals carried by `VError`.
fn is_error_value(value : @formula.FormulaValue) -> Bool {
  match value {
    @formula.VError(_) => true
    _ => false
  }
}

///|
/// Part 1 §18.17 — coerce a scalar `FormulaValue` to a `Double` when
/// possible. Booleans collapse to 1.0/0.0 per Excel; strings parse via
/// `@string::parse_double_lenient`; errors and arrays return None so
/// the caller treats them as "no comparison".
fn to_number_opt(value : @formula.FormulaValue) -> Double? {
  match value {
    @formula.VNumber(n) => Some(n)
    @formula.VBool(true) => Some(1.0)
    @formula.VBool(false) => Some(0.0)
    @formula.VString(text) => parse_double_lenient(text)
    @formula.VEmpty => Some(0.0)
    _ => None
  }
}

///|
/// Part 1 §18.17 — display-string form of a scalar value, used by the
/// text predicate rules. Numbers render through `Double::to_string` so
/// the lexical form matches SpreadsheetML's general number format.
fn to_display_string(value : @formula.FormulaValue) -> String {
  match value {
    @formula.VString(text) => text
    @formula.VNumber(n) => format_number_for_display(n)
    @formula.VBool(true) => "TRUE"
    @formula.VBool(false) => "FALSE"
    @formula.VError(err) => err.to_literal()
    @formula.VEmpty => ""
    _ => ""
  }
}

///|
/// Drop trailing ".0" for integral doubles so display-only text
/// comparisons against literal strings (e.g. `text="100"`) match what a
/// user would see in a worksheet cell.
fn format_number_for_display(value : Double) -> String {
  if value.is_nan() || value.is_inf() {
    return value.to_string()
  }
  if value == value.trunc() && value.abs() < 1.0e15 {
    let as_int = value.to_int64()
    as_int.to_string()
  } else {
    value.to_string()
  }
}

///|
/// Lenient `String -> Double` parser. Returns None on any leading /
/// trailing junk; accepts a leading sign and a single decimal point.
/// Used both by `to_number_opt` and by `decode.mbt` cfvo numeric parser.
fn parse_double_lenient(text : String) -> Double? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try {
    let value : Double = @strconv.from_str(trimmed)
    if value.is_nan() {
      None
    } else {
      Some(value)
    }
  } catch {
    _ => None
  }
}

///|
fn trim_whitespace(text : String) -> String {
  let mut start = 0
  while start < text.length() {
    let unit = text.code_unit_at(start).to_int()
    if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
      break
    }
    start = start + 1
  }
  let mut end = text.length()
  while end > start {
    let unit = text.code_unit_at(end - 1).to_int()
    if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
      break
    }
    end = end - 1
  }
  text.unsafe_substring(start~, end~)
}

///|
/// Part 1 §18.18.15 — apply a comparison operator. Number / number
/// comparisons use Double ordering; string / string comparisons use
/// case-insensitive lexicographic order; mixed comparisons coerce to
/// the comparand's natural representation. Returns None when the
/// operator is one of the text-predicate ones (those are dispatched by
/// `cellis_match` directly).
fn compare_with_operator(
  cell : @formula.FormulaValue,
  op : CfOperator,
  rhs : @formula.FormulaValue,
) -> Bool {
  match op {
    OpEqual => equals_loose(cell, rhs)
    OpNotEqual => !equals_loose(cell, rhs)
    OpGreaterThan => greater_than(cell, rhs)
    OpGreaterThanOrEqual => greater_than(cell, rhs) || equals_loose(cell, rhs)
    OpLessThan => less_than(cell, rhs)
    OpLessThanOrEqual => less_than(cell, rhs) || equals_loose(cell, rhs)
    _ => false
  }
}

///|
fn equals_loose(a : @formula.FormulaValue, b : @formula.FormulaValue) -> Bool {
  match (a, b) {
    (@formula.VNumber(x), @formula.VNumber(y)) => x == y
    (@formula.VBool(x), @formula.VBool(y)) => x == y
    (@formula.VString(x), @formula.VString(y)) => x.to_upper() == y.to_upper()
    (@formula.VEmpty, @formula.VEmpty) => true
    (@formula.VEmpty, @formula.VNumber(y)) => y == 0.0
    (@formula.VNumber(x), @formula.VEmpty) => x == 0.0
    (@formula.VEmpty, @formula.VString(y)) => y.length() == 0
    (@formula.VString(x), @formula.VEmpty) => x.length() == 0
    _ =>
      match (to_number_opt(a), to_number_opt(b)) {
        (Some(x), Some(y)) => x == y
        _ => false
      }
  }
}

///|
fn greater_than(a : @formula.FormulaValue, b : @formula.FormulaValue) -> Bool {
  match (a, b) {
    (@formula.VNumber(x), @formula.VNumber(y)) => x > y
    (@formula.VString(x), @formula.VString(y)) => compare_strings_ci(x, y) > 0
    _ =>
      match (to_number_opt(a), to_number_opt(b)) {
        (Some(x), Some(y)) => x > y
        _ => false
      }
  }
}

///|
fn less_than(a : @formula.FormulaValue, b : @formula.FormulaValue) -> Bool {
  match (a, b) {
    (@formula.VNumber(x), @formula.VNumber(y)) => x < y
    (@formula.VString(x), @formula.VString(y)) => compare_strings_ci(x, y) < 0
    _ =>
      match (to_number_opt(a), to_number_opt(b)) {
        (Some(x), Some(y)) => x < y
        _ => false
      }
  }
}

///|
fn compare_strings_ci(a : String, b : String) -> Int {
  let x = a.to_upper()
  let y = b.to_upper()
  let limit = if x.length() < y.length() { x.length() } else { y.length() }
  for i in 0..<limit {
    let ai = x.code_unit_at(i)
    let bi = y.code_unit_at(i)
    if ai != bi {
      return if ai < bi { -1 } else { 1 }
    }
  }
  if x.length() == y.length() {
    0
  } else if x.length() < y.length() {
    -1
  } else {
    1
  }
}

///|
/// Part 1 §18.3.1.10 — cellIs rule evaluation. The decoded operator
/// dispatches to either `compare_with_operator` (six relational
/// operators), the two-bounded between/notBetween operators, or one
/// of the four text-predicate operators. Per §18.3.1.10 the rule's
/// `formulas` list supplies the comparison RHS; between needs two.
fn cellis_match(
  cell : @formula.FormulaValue,
  op : CfOperator,
  rhs_first : @formula.FormulaValue,
  rhs_second : @formula.FormulaValue?,
) -> Bool {
  match op {
    OpBetween =>
      match rhs_second {
        Some(b) =>
          (greater_than(cell, rhs_first) || equals_loose(cell, rhs_first)) &&
          (less_than(cell, b) || equals_loose(cell, b))
        None => false
      }
    OpNotBetween =>
      match rhs_second {
        Some(b) =>
          !((greater_than(cell, rhs_first) || equals_loose(cell, rhs_first)) &&
          (less_than(cell, b) || equals_loose(cell, b)))
        None => false
      }
    OpContainsText =>
      contains_ci(to_display_string(cell), to_display_string(rhs_first))
    OpNotContains =>
      !contains_ci(to_display_string(cell), to_display_string(rhs_first))
    OpBeginsWith =>
      starts_with_ci(to_display_string(cell), to_display_string(rhs_first))
    OpEndsWith =>
      ends_with_ci(to_display_string(cell), to_display_string(rhs_first))
    _ => compare_with_operator(cell, op, rhs_first)
  }
}
