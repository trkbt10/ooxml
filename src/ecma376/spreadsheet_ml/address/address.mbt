///|
let max_columns = 16384

///|
let max_rows = 1048576

///|
/// §18.18.7 ST_CellRef. Column-letter + 1-based row, with optional `$`
/// absolute markers and an optional sheet qualifier.
///
/// [Example: `A1` identifies column A row 1. end example]
/// [Example: `'Bob''s sheet'!$B$2` identifies an absolute cell on a quoted sheet. end example]
pub(all) struct CellAddress {
  col_zero_based : Int
  row_zero_based : Int
  col_absolute : Bool
  row_absolute : Bool
  sheet : String?
} derive(Eq, Debug)

///|
/// §18.18.62 ST_Ref. Cell, row, or column range reference.
///
/// [Example: `A1:B10` identifies a rectangular cell range. end example]
/// [Example: `1:5` identifies whole rows 1 through 5. end example]
pub(all) struct CellRange {
  start_col_zero_based : Int?
  start_row_zero_based : Int?
  end_col_zero_based : Int?
  end_row_zero_based : Int?
  start_col_absolute : Bool
  start_row_absolute : Bool
  end_col_absolute : Bool
  end_row_absolute : Bool
  sheet : String?
} derive(Eq, Debug)

///|
/// §18.18.76 ST_Sqref. Space-separated list of ST_Ref references.
///
/// [Example: `A1 B2` identifies two single-cell references. end example]
/// [Example: `A1:B2 C:C` combines cell and column ranges. end example]
pub(all) struct Sqref {
  ranges : Array[CellRange]
} derive(Eq, Debug)

///|
/// §18.18.64 ST_RefMode workbook reference style selector.
///
/// [Example: `A1` uses letters for columns and numbers for rows. end example]
/// [Example: `R1C1` uses numbers for both rows and columns. end example]
pub(all) enum RefMode {
  A1
  R1C1
} derive(Eq, Debug)

///|
struct ParsedRefBody {
  col : Int?
  row : Int?
  col_absolute : Bool
  row_absolute : Bool
} derive(Eq, Debug)

///|
struct SheetAndBody {
  sheet : String?
  body : String
} derive(Eq, Debug)

///|
/// §18.18.7 ST_CellRef parser for A1 mode.
///
/// [Example: `A1` parses to column 0 and row 0. end example]
/// [Example: `$B$2` parses with both absolute flags set. end example]
pub fn CellAddress::parse_a1(
  value : String,
) -> CellAddress raise @opc_errors.SchemaViolation {
  let pieces = split_sheet_and_body(value, "ST_CellRef")
  let body = parse_a1_ref_body(pieces.body, "ST_CellRef")
  require_true(body.col is Some(_), "18.18.7", "ST_CellRef", "missing column")
  require_true(body.row is Some(_), "18.18.7", "ST_CellRef", "missing row")
  {
    col_zero_based: body.col.unwrap(),
    row_zero_based: body.row.unwrap(),
    col_absolute: body.col_absolute,
    row_absolute: body.row_absolute,
    sheet: pieces.sheet,
  }
}

///|
/// §18.18.7 ST_CellRef parser for R1C1 mode.
///
/// [Example: `R1C1` parses absolute row 1 column 1. end example]
/// [Example: `RC[-2]` parses current row and a relative column offset. end example]
pub fn CellAddress::parse_r1c1(
  value : String,
) -> CellAddress raise @opc_errors.SchemaViolation {
  let pieces = split_sheet_and_body(value, "ST_CellRef")
  let chars = pieces.body.to_array()
  let mut pos = 0
  if chars.length() == 0 || chars.get(pos) != Some('R') {
    violation("18.18.7", "ST_CellRef", "R1C1 reference must start with R")
  }
  pos += 1
  let (row, row_absolute, next) = parse_r1c1_axis(chars, pos, 'C')
  pos = next
  if chars.get(pos) != Some('C') {
    violation("18.18.7", "ST_CellRef", "R1C1 reference must contain C")
  }
  pos += 1
  let (col, col_absolute, done) = parse_r1c1_axis(chars, pos, '\u{0}')
  if done != chars.length() {
    violation("18.18.7", "ST_CellRef", "trailing characters in R1C1 reference")
  }
  if row_absolute {
    require_range(
      row + 1,
      1,
      max_rows,
      "18.18.7",
      "ST_CellRef",
      "row is outside worksheet bounds",
    )
  }
  if col_absolute {
    require_range(
      col + 1,
      1,
      max_columns,
      "18.18.7",
      "ST_CellRef",
      "column is outside worksheet bounds",
    )
  }
  {
    col_zero_based: col,
    row_zero_based: row,
    col_absolute,
    row_absolute,
    sheet: pieces.sheet,
  }
}

///|
/// §18.18.7 ST_CellRef formatter for A1 mode.
///
/// [Example: an absolute column and row formats as `$A$1`. end example]
/// [Example: a sheet name containing spaces is single-quoted. end example]
pub fn CellAddress::to_a1(self : CellAddress) -> String {
  format_sheet(self.sheet) +
  (if self.col_absolute { "$" } else { "" }) +
  (column_index_to_letter(self.col_zero_based) catch { _ => "" }) +
  (if self.row_absolute { "$" } else { "" }) +
  (self.row_zero_based + 1).to_string()
}

///|
/// §18.18.64 ST_RefMode R1C1 formatter.
///
/// [Example: absolute row and column 1 formats as `R1C1`. end example]
/// [Example: relative column -2 formats as `RC[-2]`. end example]
pub fn CellAddress::to_r1c1(self : CellAddress) -> String {
  format_sheet(self.sheet) +
  format_r1c1_axis("R", self.row_zero_based, self.row_absolute) +
  format_r1c1_axis("C", self.col_zero_based, self.col_absolute)
}

///|
/// §18.18.62 ST_Ref parser for A1 mode.
///
/// [Example: `A1:B10` parses a rectangular range. end example]
/// [Example: `A:C` parses a whole-column range. end example]
pub fn CellRange::parse_a1(
  value : String,
) -> CellRange raise @opc_errors.SchemaViolation {
  let pieces = split_sheet_and_body(value, "ST_Ref")
  if pieces.body == "" {
    violation("18.18.62", "ST_Ref", "empty reference")
  }
  let parts = split_to_array(pieces.body, ":")
  if parts.length() > 2 {
    violation("18.18.62", "ST_Ref", "range contains too many separators")
  }
  let start = parse_a1_ref_body(parts[0], "ST_Ref")
  let end = if parts.length() == 1 {
    start
  } else {
    parse_a1_ref_body(parts[1], "ST_Ref")
  }
  normalize_range(start, end, pieces.sheet)
}

///|
/// §18.18.62 ST_Ref formatter for A1 mode.
///
/// [Example: a single-cell range formats as `A1`. end example]
/// [Example: a whole-row range formats as `1:5`. end example]
pub fn CellRange::to_a1(self : CellRange) -> String {
  let start = format_ref_body(
    self.start_col_zero_based,
    self.start_row_zero_based,
    self.start_col_absolute,
    self.start_row_absolute,
  )
  let end = format_ref_body(
    self.end_col_zero_based,
    self.end_row_zero_based,
    self.end_col_absolute,
    self.end_row_absolute,
  )
  if start == end {
    format_sheet(self.sheet) + start
  } else {
    format_sheet(self.sheet) + start + ":" + end
  }
}

///|
/// §18.18.76 ST_Sqref parser for space-delimited ST_Ref values.
///
/// [Example: `A1 B2` parses two references. end example]
/// [Example: `A1:B2 C:D` parses mixed reference kinds. end example]
pub fn Sqref::parse_a1(
  value : String,
) -> Sqref raise @opc_errors.SchemaViolation {
  if value == "" {
    violation("18.18.76", "ST_Sqref", "empty reference sequence")
  }
  let ranges : Array[CellRange] = []
  for token in value.split(" ") {
    if token == "" {
      violation("18.18.76", "ST_Sqref", "empty reference token")
    }
    ranges.push(CellRange::parse_a1(token.to_owned()))
  }
  { ranges, }
}

///|
/// §18.18.76 ST_Sqref formatter for space-delimited ST_Ref values.
///
/// [Example: two cells format as `A1 B2`. end example]
/// [Example: ranges retain their normalized A1 form. end example]
pub fn Sqref::to_a1(self : Sqref) -> String {
  let out : Array[String] = []
  for range in self.ranges {
    out.push(range.to_a1())
  }
  out.join(" ")
}

///|
/// §18.18.7 ST_CellRef column-letter helper.
///
/// [Example: `A` maps to 0. end example]
/// [Example: `AA` maps to 26. end example]
pub fn column_letter_to_index(
  letters : String,
) -> Int raise @opc_errors.SchemaViolation {
  let chars = letters.to_array()
  if chars.length() < 1 || chars.length() > 3 {
    violation("18.18.7", "ST_CellRef", "column must be 1 to 3 letters")
  }
  let mut value = 0
  for ch in chars {
    let upper = ascii_upper(ch)
    if !is_ascii_letter(upper) {
      violation("18.18.7", "ST_CellRef", "column contains non-letter")
    }
    value = value * 26 + (upper.to_int() - 'A'.to_int() + 1)
  }
  require_range(
    value, 1, max_columns, "18.18.7", "ST_CellRef", "column is outside worksheet bounds",
  )
  value - 1
}

///|
/// §18.18.7 ST_CellRef column-letter formatter.
///
/// [Example: 0 maps to `A`. end example]
/// [Example: 26 maps to `AA`. end example]
pub fn column_index_to_letter(
  index : Int,
) -> String raise @opc_errors.SchemaViolation {
  require_range(
    index,
    0,
    max_columns - 1,
    "18.18.7",
    "ST_CellRef",
    "column index is outside worksheet bounds",
  )
  let out = StringBuilder::new()
  let mut n = index + 1
  let reversed : Array[Char] = []
  while n > 0 {
    let rem = (n - 1) % 26
    reversed.push(('A'.to_int() + rem).unsafe_to_char())
    n = (n - 1) / 26
  }
  for i in 0..<reversed.length() {
    out.write_char(reversed[reversed.length() - i - 1])
  }
  out.to_string()
}

///|
fn split_sheet_and_body(
  value : String,
  path : String,
) -> SheetAndBody raise @opc_errors.SchemaViolation {
  if value == "" {
    violation(section_for(path), path, "empty reference")
  }
  let chars = value.to_array()
  if chars[0] == '\'' {
    let sheet = StringBuilder::new()
    let mut pos = 1
    let mut closed = false
    while pos < chars.length() && !closed {
      if chars[pos] == '\'' {
        if pos + 1 < chars.length() && chars[pos + 1] == '\'' {
          sheet.write_char('\'')
          pos += 2
        } else {
          closed = true
          pos += 1
        }
      } else {
        sheet.write_char(chars[pos])
        pos += 1
      }
    }
    if !closed || pos >= chars.length() || chars[pos] != '!' {
      violation(section_for(path), path, "malformed quoted sheet qualifier")
    }
    {
      sheet: Some(sheet.to_string()),
      body: chars_to_string(chars, pos + 1, chars.length()),
    }
  } else {
    let mut bang = -1
    for i in 0..<chars.length() {
      if chars[i] == '!' {
        if bang != -1 {
          violation(section_for(path), path, "multiple sheet separators")
        }
        bang = i
      }
    }
    if bang == -1 {
      { sheet: None, body: value }
    } else if bang == 0 || bang == chars.length() - 1 {
      violation(section_for(path), path, "empty sheet qualifier or reference")
    } else {
      {
        sheet: Some(chars_to_string(chars, 0, bang)),
        body: chars_to_string(chars, bang + 1, chars.length()),
      }
    }
  }
}

///|
fn parse_a1_ref_body(
  value : String,
  path : String,
) -> ParsedRefBody raise @opc_errors.SchemaViolation {
  let section = section_for(path)
  let chars = value.to_array()
  if chars.length() == 0 {
    violation(section, path, "empty reference body")
  }
  let mut pos = 0
  let mut col_absolute = false
  let mut row_absolute = false
  if chars.get(pos) == Some('$') {
    col_absolute = true
    pos += 1
  }
  let col_start = pos
  while pos < chars.length() && is_ascii_letter(chars[pos]) {
    pos += 1
  }
  let col = if pos > col_start {
    Some(column_letter_to_index(chars_to_string(chars, col_start, pos)))
  } else {
    None
  }
  if chars.get(pos) == Some('$') {
    row_absolute = true
    pos += 1
  }
  let row_start = pos
  while pos < chars.length() && is_ascii_digit(chars[pos]) {
    pos += 1
  }
  let row = if pos > row_start {
    let parsed = parse_positive_decimal(chars, row_start, pos, section, path)
    require_range(
      parsed, 1, max_rows, section, path, "row is outside worksheet bounds",
    )
    Some(parsed - 1)
  } else {
    None
  }
  if pos != chars.length() {
    violation(section, path, "malformed reference body")
  }
  if col_absolute && col is None {
    violation(section, path, "column absolute marker must precede a column")
  }
  if row_absolute && row is None {
    violation(section, path, "row absolute marker must precede a row")
  }
  if col is None && row is None {
    violation(section, path, "reference must contain a row or column")
  }
  if col is Some(_) && row is None && row_absolute {
    violation(section, path, "row absolute marker is misplaced")
  }
  { col, row, col_absolute, row_absolute }
}

///|
fn normalize_range(
  start : ParsedRefBody,
  end : ParsedRefBody,
  sheet : String?,
) -> CellRange raise @opc_errors.SchemaViolation {
  let same_shape = (start.col is Some(_)) == (end.col is Some(_)) &&
    (start.row is Some(_)) == (end.row is Some(_))
  if !same_shape {
    violation("18.18.62", "ST_Ref", "range endpoints must have matching shapes")
  }
  let (start_col, end_col, start_col_abs, end_col_abs) = normalize_axis(
    start.col,
    end.col,
    start.col_absolute,
    end.col_absolute,
  )
  let (start_row, end_row, start_row_abs, end_row_abs) = normalize_axis(
    start.row,
    end.row,
    start.row_absolute,
    end.row_absolute,
  )
  {
    start_col_zero_based: start_col,
    start_row_zero_based: start_row,
    end_col_zero_based: end_col,
    end_row_zero_based: end_row,
    start_col_absolute: start_col_abs,
    start_row_absolute: start_row_abs,
    end_col_absolute: end_col_abs,
    end_row_absolute: end_row_abs,
    sheet,
  }
}

///|
fn normalize_axis(
  start : Int?,
  end : Int?,
  start_abs : Bool,
  end_abs : Bool,
) -> (Int?, Int?, Bool, Bool) {
  match (start, end) {
    (Some(s), Some(e)) =>
      if s <= e {
        (start, end, start_abs, end_abs)
      } else {
        (end, start, end_abs, start_abs)
      }
    _ => (start, end, start_abs, end_abs)
  }
}

///|
fn format_ref_body(
  col : Int?,
  row : Int?,
  col_absolute : Bool,
  row_absolute : Bool,
) -> String {
  let out = StringBuilder::new()
  if col is Some(c) {
    if col_absolute {
      out.write_char('$')
    }
    out.write_string(column_index_to_letter(c) catch { _ => "" })
  }
  if row is Some(r) {
    if row_absolute {
      out.write_char('$')
    }
    out.write_string((r + 1).to_string())
  }
  out.to_string()
}

///|
fn parse_r1c1_axis(
  chars : Array[Char],
  pos : Int,
  stop : Char,
) -> (Int, Bool, Int) raise @opc_errors.SchemaViolation {
  if pos < chars.length() && chars[pos] == '[' {
    let mut cursor = pos + 1
    let sign = if cursor < chars.length() && chars[cursor] == '-' {
      cursor += 1
      -1
    } else {
      if cursor < chars.length() && chars[cursor] == '+' {
        cursor += 1
      }
      1
    }
    let digits = cursor
    while cursor < chars.length() && is_ascii_digit(chars[cursor]) {
      cursor += 1
    }
    if digits == cursor || cursor >= chars.length() || chars[cursor] != ']' {
      violation("18.18.7", "ST_CellRef", "malformed R1C1 relative axis")
    }
    (
      sign *
      parse_positive_decimal(chars, digits, cursor, "18.18.7", "ST_CellRef"),
      false,
      cursor + 1,
    )
  } else {
    let digits = pos
    let mut cursor = pos
    while cursor < chars.length() && is_ascii_digit(chars[cursor]) {
      cursor += 1
    }
    if cursor > digits {
      let value = parse_positive_decimal(
        chars, digits, cursor, "18.18.7", "ST_CellRef",
      )
      if value < 1 {
        violation(
          "18.18.7", "ST_CellRef", "absolute R1C1 axis must be positive",
        )
      }
      (value - 1, true, cursor)
    } else if stop != '\u{0}' &&
      cursor < chars.length() &&
      chars[cursor] == stop {
      (0, false, cursor)
    } else if stop == '\u{0}' && cursor == chars.length() {
      (0, false, cursor)
    } else {
      violation("18.18.7", "ST_CellRef", "malformed R1C1 axis")
    }
  }
}

///|
fn format_r1c1_axis(prefix : String, value : Int, absolute : Bool) -> String {
  if absolute {
    prefix + (value + 1).to_string()
  } else if value == 0 {
    prefix
  } else {
    prefix + "[" + value.to_string() + "]"
  }
}

///|
fn format_sheet(sheet : String?) -> String {
  match sheet {
    None => ""
    Some(name) =>
      if sheet_requires_quotes(name) {
        "'" + escape_sheet_name(name) + "'!"
      } else {
        name + "!"
      }
  }
}

///|
fn sheet_requires_quotes(name : String) -> Bool {
  if name == "" {
    true
  } else {
    let mut needs = false
    for ch in name.to_array() {
      if !(is_ascii_letter(ch) ||
        is_ascii_digit(ch) ||
        ch == '_' ||
        ch == '.' ||
        ch == '[' ||
        ch == ']') {
        needs = true
      }
    }
    needs
  }
}

///|
fn escape_sheet_name(name : String) -> String {
  let out = StringBuilder::new()
  for ch in name.to_array() {
    if ch == '\'' {
      out.write_string("''")
    } else {
      out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn chars_to_string(chars : Array[Char], start : Int, end : Int) -> String {
  let out = StringBuilder::new()
  for i in start..<end {
    out.write_char(chars[i])
  }
  out.to_string()
}

///|
fn split_to_array(value : String, separator : String) -> Array[String] {
  let out : Array[String] = []
  for part in value.split(separator) {
    out.push(part.to_owned())
  }
  out
}

///|
fn parse_positive_decimal(
  chars : Array[Char],
  start : Int,
  end : Int,
  section : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  let mut value = 0
  for i in start..<end {
    if !is_ascii_digit(chars[i]) {
      violation(section, path, "expected decimal digit")
    }
    value = value * 10 + (chars[i].to_int() - '0'.to_int())
    if value > max_rows && path != "ST_CellRef:R1C1Column" {
      ()
    }
  }
  if value < 1 {
    violation(section, path, "decimal value must be positive")
  }
  value
}

///|
fn is_ascii_digit(ch : Char) -> Bool {
  '0' <= ch && ch <= '9'
}

///|
fn is_ascii_letter(ch : Char) -> Bool {
  ('A' <= ch && ch <= 'Z') || ('a' <= ch && ch <= 'z')
}

///|
fn ascii_upper(ch : Char) -> Char {
  if 'a' <= ch && ch <= 'z' {
    (ch.to_int() - 'a'.to_int() + 'A'.to_int()).unsafe_to_char()
  } else {
    ch
  }
}

///|
fn section_for(path : String) -> String {
  match path {
    "ST_Sqref" => "18.18.76"
    "ST_Ref" => "18.18.62"
    _ => "18.18.7"
  }
}

///|
fn require_true(
  valid : Bool,
  section : String,
  path : String,
  reason : String,
) -> Unit raise @opc_errors.SchemaViolation {
  if !valid {
    violation(section, path, reason)
  }
}

///|
fn require_range(
  value : Int,
  min : Int,
  max : Int,
  section : String,
  path : String,
  reason : String,
) -> Unit raise @opc_errors.SchemaViolation {
  if value < min || value > max {
    violation(section, path, reason)
  }
}

///|
fn[T] violation(
  section : String,
  path : String,
  reason : String,
) -> T raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(section~, path~, reason~)
}
