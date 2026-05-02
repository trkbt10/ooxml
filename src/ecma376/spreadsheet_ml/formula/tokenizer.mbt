///|
let formula_syntax_section = "Part 1 §18.17.2"

///|
let formula_constant_section = "Part 1 §18.17.2.1"

///|
let formula_reference_section = "Part 1 §18.17.2.3"

///|
let formula_path = "SpreadsheetML formula"

///|
priv struct RawToken {
  token : Token
  leading_space : Bool
}

///|
priv struct NumberScan {
  end : Int
  value : Double
}

///|
priv struct StringScan {
  end : Int
  value : String
}

///|
priv struct ReferenceScan {
  end : Int
  value : String
  function_name : Bool
}

///|
/// §18.17.2, §18.17.2.1, §18.17.2.2, §18.17.2.3, §18.17.2.4, and
/// §18.17.2.5 — tokenize a SpreadsheetML formula string into lexical tokens.
/// Raises SchemaViolation for malformed numeric literals, unterminated
/// strings, malformed reference fragments, or unknown characters.
pub fn tokenize(
  source : String,
) -> Array[Token] raise @opc_errors.SchemaViolation {
  let raw = Array::new()
  let length = source.length()
  let mut pos = 0
  let mut had_space = false
  while pos < length {
    let ch = source.code_unit_at(pos)
    if ch == ' ' {
      had_space = true
      pos += 1
      continue
    }
    let start = pos
    let kind = match ch {
      '+' => {
        pos += 1
        Plus
      }
      '-' => {
        pos += 1
        Minus
      }
      '*' => {
        pos += 1
        Star
      }
      '/' => {
        pos += 1
        Slash
      }
      '^' => {
        pos += 1
        Caret
      }
      '&' => {
        pos += 1
        Ampersand
      }
      '=' => {
        pos += 1
        Equal
      }
      '<' =>
        if pos + 1 < length && source.code_unit_at(pos + 1) == '>' {
          pos += 2
          NotEqual
        } else if pos + 1 < length && source.code_unit_at(pos + 1) == '=' {
          pos += 2
          LessEqual
        } else {
          pos += 1
          Less
        }
      '>' =>
        if pos + 1 < length && source.code_unit_at(pos + 1) == '=' {
          pos += 2
          GreaterEqual
        } else {
          pos += 1
          Greater
        }
      '%' => {
        pos += 1
        Percent
      }
      ':' => {
        pos += 1
        RangeColon
      }
      ',' => {
        pos += 1
        Comma
      }
      '(' => {
        pos += 1
        LParen
      }
      ')' => {
        pos += 1
        RParen
      }
      '{' => {
        pos += 1
        LBrace
      }
      '}' => {
        pos += 1
        RBrace
      }
      ';' => {
        pos += 1
        Semicolon
      }
      '"' => {
        let scan = scan_string(source, pos)
        pos = scan.end
        StringConstant(scan.value)
      }
      '#' => {
        let scan = scan_error_constant(source, pos)
        pos = scan.end
        ErrorConst(scan.value)
      }
      '\'' => {
        let scan = scan_reference(source, pos)
        pos = scan.end
        Reference(scan.value)
      }
      '.' =>
        if pos + 1 < length && is_digit(source.code_unit_at(pos + 1)) {
          let scan = scan_number(source, pos)
          pos = scan.end
          Number(scan.value)
        } else {
          formula_violation(
            formula_syntax_section,
            "unknown character `\{ch.to_string()}`",
          )
        }
      _ =>
        if is_digit(ch) {
          let scan = scan_number(source, pos)
          pos = scan.end
          Number(scan.value)
        } else if is_reference_start(ch) {
          let scan = scan_reference(source, pos)
          pos = scan.end
          let upper = ascii_upper(scan.value)
          if scan.function_name {
            FunctionName(scan.value)
          } else if upper == "TRUE" {
            Boolean(true)
          } else if upper == "FALSE" {
            Boolean(false)
          } else {
            Reference(scan.value)
          }
        } else if ch == '$' {
          let scan = scan_reference(source, pos)
          pos = scan.end
          Reference(scan.value)
        } else {
          formula_violation(
            formula_syntax_section,
            "unknown character `\{ch.to_string()}`",
          )
        }
    }
    raw.push({ token: { kind, start, end: pos }, leading_space: had_space })
    had_space = false
  }
  insert_space_operators(raw)
}

///|
fn insert_space_operators(raw : Array[RawToken]) -> Array[Token] {
  let out = Array::new()
  for index in 0..<raw.length() {
    let item = raw[index]
    if index > 0 &&
      item.leading_space &&
      is_reference_like(raw[index - 1].token.kind) &&
      is_reference_like(item.token.kind) {
      let start = raw[index - 1].token.end
      out.push({ kind: SpaceOp, start, end: item.token.start })
    }
    out.push(item.token)
  }
  out
}

///|
fn is_reference_like(kind : FormulaToken) -> Bool {
  match kind {
    Reference(_) => true
    _ => false
  }
}

///|
fn scan_string(
  source : String,
  start : Int,
) -> StringScan raise @opc_errors.SchemaViolation {
  let out = StringBuilder::new()
  let length = source.length()
  let mut pos = start + 1
  while pos < length {
    let ch = source.code_unit_at(pos)
    if ch == '"' {
      if pos + 1 < length && source.code_unit_at(pos + 1) == '"' {
        out.write_char('"')
        pos += 2
      } else {
        return { end: pos + 1, value: out.to_string() }
      }
    } else {
      out.write_char(ch.to_char().unwrap())
      pos += 1
    }
  }
  formula_violation(formula_constant_section, "unterminated string constant")
}

///|
fn scan_error_constant(
  source : String,
  start : Int,
) -> StringScan raise @opc_errors.SchemaViolation {
  let errors = [
    "#GETTING_DATA", "#DIV/0!", "#VALUE!", "#NAME?", "#NULL!", "#NUM!", "#REF!",
    "#N/A",
  ]
  for error in errors {
    if starts_with_at(source, start, error) {
      return { end: start + error.length(), value: error }
    }
  }
  formula_violation(formula_constant_section, "unknown error constant")
}

///|
fn scan_number(
  source : String,
  start : Int,
) -> NumberScan raise @opc_errors.SchemaViolation {
  let length = source.length()
  let mut pos = start
  let mut int_digits = 0
  while pos < length && is_digit(source.code_unit_at(pos)) {
    int_digits += 1
    pos += 1
  }
  let mut frac_digits = 0
  if pos < length && source.code_unit_at(pos) == '.' {
    pos += 1
    while pos < length && is_digit(source.code_unit_at(pos)) {
      frac_digits += 1
      pos += 1
    }
  }
  if int_digits == 0 && frac_digits == 0 {
    formula_violation(formula_constant_section, "malformed numeric literal")
  }
  if pos < length &&
    (source.code_unit_at(pos) == 'e' || source.code_unit_at(pos) == 'E') {
    pos += 1
    if pos < length &&
      (source.code_unit_at(pos) == '+' || source.code_unit_at(pos) == '-') {
      pos += 1
    }
    let exp_start = pos
    while pos < length && is_digit(source.code_unit_at(pos)) {
      pos += 1
    }
    if pos == exp_start {
      formula_violation(
        formula_constant_section, "numeric exponent has no digits",
      )
    }
  }
  if pos < length &&
    (
      source.code_unit_at(pos) == '.' ||
      is_reference_start(source.code_unit_at(pos))
    ) {
    formula_violation(formula_constant_section, "malformed numeric literal")
  }
  { end: pos, value: parse_scanned_number(source, start, pos) }
}

///|
fn parse_scanned_number(source : String, start : Int, end : Int) -> Double {
  let mut pos = start
  let mut value = 0.0
  while pos < end && is_digit(source.code_unit_at(pos)) {
    value = value * 10.0 + digit_value(source.code_unit_at(pos)).to_double()
    pos += 1
  }
  if pos < end && source.code_unit_at(pos) == '.' {
    pos += 1
    let mut place = 0.1
    while pos < end && is_digit(source.code_unit_at(pos)) {
      value += digit_value(source.code_unit_at(pos)).to_double() * place
      place = place / 10.0
      pos += 1
    }
  }
  if pos < end &&
    (source.code_unit_at(pos) == 'e' || source.code_unit_at(pos) == 'E') {
    pos += 1
    let mut negative = false
    if pos < end && source.code_unit_at(pos) == '-' {
      negative = true
      pos += 1
    } else if pos < end && source.code_unit_at(pos) == '+' {
      pos += 1
    }
    let mut exponent = 0
    while pos < end && is_digit(source.code_unit_at(pos)) {
      exponent = exponent * 10 + digit_value(source.code_unit_at(pos))
      pos += 1
    }
    if negative {
      for _ in 0..<exponent {
        value = value / 10.0
      }
    } else {
      for _ in 0..<exponent {
        value = value * 10.0
      }
    }
  }
  value
}

///|
fn scan_reference(
  source : String,
  start : Int,
) -> ReferenceScan raise @opc_errors.SchemaViolation {
  if source.code_unit_at(start) == '\'' {
    scan_quoted_sheet_reference(source, start)
  } else {
    scan_plain_reference(source, start)
  }
}

///|
fn scan_quoted_sheet_reference(
  source : String,
  start : Int,
) -> ReferenceScan raise @opc_errors.SchemaViolation {
  let length = source.length()
  let mut pos = start + 1
  while pos < length {
    if source.code_unit_at(pos) == '\'' {
      if pos + 1 < length && source.code_unit_at(pos + 1) == '\'' {
        pos += 2
      } else {
        pos += 1
        if pos >= length || source.code_unit_at(pos) != '!' {
          formula_violation(
            formula_reference_section, "quoted sheet reference must be followed by `!`",
          )
        }
        pos += 1
        let body_end = scan_reference_body(source, pos)
        if body_end == pos {
          formula_violation(
            formula_reference_section, "sheet reference has no reference body",
          )
        }
        return {
          end: body_end,
          value: source.unsafe_substring(start~, end=body_end),
          function_name: false,
        }
      }
    } else {
      pos += 1
    }
  }
  formula_violation(formula_reference_section, "unterminated quoted sheet name")
}

///|
fn scan_plain_reference(
  source : String,
  start : Int,
) -> ReferenceScan raise @opc_errors.SchemaViolation {
  let simple_end = scan_reference_body(source, start)
  if simple_end == start {
    formula_violation(formula_reference_section, "malformed reference")
  }
  if simple_end < source.length() && source.code_unit_at(simple_end) == '!' {
    let body_start = simple_end + 1
    let body_end = scan_reference_body(source, body_start)
    if body_end == body_start {
      formula_violation(
        formula_reference_section, "sheet reference has no reference body",
      )
    }
    {
      end: body_end,
      value: source.unsafe_substring(start~, end=body_end),
      function_name: false,
    }
  } else {
    {
      end: simple_end,
      value: source.unsafe_substring(start~, end=simple_end),
      function_name: simple_end < source.length() &&
      source.code_unit_at(simple_end) == '(',
    }
  }
}

///|
fn scan_reference_body(source : String, start : Int) -> Int {
  let mut pos = start
  while pos < source.length() && is_reference_char(source.code_unit_at(pos)) {
    pos += 1
  }
  pos
}

///|
fn starts_with_at(source : String, start : Int, prefix : String) -> Bool {
  if start + prefix.length() > source.length() {
    false
  } else {
    let mut ok = true
    for index in 0..<prefix.length() {
      if source.code_unit_at(start + index) != prefix.code_unit_at(index) {
        ok = false
      }
    }
    ok
  }
}

///|
fn ascii_upper(value : String) -> String {
  let out = StringBuilder::new()
  for ch in value {
    if ch >= 'a' && ch <= 'z' {
      out.write_char((ch.to_int() - 32).unsafe_to_char())
    } else {
      out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn is_digit(ch : UInt16) -> Bool {
  ch.to_int() >= '0'.to_int() && ch.to_int() <= '9'.to_int()
}

///|
fn digit_value(ch : UInt16) -> Int {
  ch.to_int() - '0'.to_int()
}

///|
fn is_ascii_letter(ch : UInt16) -> Bool {
  (ch.to_int() >= 'A'.to_int() && ch.to_int() <= 'Z'.to_int()) ||
  (ch.to_int() >= 'a'.to_int() && ch.to_int() <= 'z'.to_int())
}

///|
fn is_reference_start(ch : UInt16) -> Bool {
  is_ascii_letter(ch) || ch.to_int() == '_'.to_int()
}

///|
fn is_reference_char(ch : UInt16) -> Bool {
  is_ascii_letter(ch) ||
  is_digit(ch) ||
  ch.to_int() == '_'.to_int() ||
  ch.to_int() == '.'.to_int() ||
  ch.to_int() == '$'.to_int()
}

///|
fn[T] formula_violation(
  section : String,
  reason : String,
) -> T raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(section~, path=formula_path, reason~)
}
