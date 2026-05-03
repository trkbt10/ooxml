///|
/// §18.3.1.40 shared formulas and §18.18.7 cell refs — shift every
/// Reference node in `ast` by `(delta_row, delta_col)`, respecting absolute
/// markers. Range references shift both endpoints; defined names are not
/// shifted. The function is pure and produces a new AST.
pub fn shift_ast(
  ast : FormulaAst,
  delta_row : Int,
  delta_col : Int,
) -> FormulaAst {
  match ast {
    Literal(value) => Literal(value)
    Reference(lexeme) =>
      Reference(shift_reference_lexeme(lexeme, delta_row, delta_col))
    Function(name, args) => {
      let shifted = Array::new(capacity=args.length())
      for arg in args {
        shifted.push(shift_ast(arg, delta_row, delta_col))
      }
      Function(name, shifted)
    }
    Unary(op, inner) => Unary(op, shift_ast(inner, delta_row, delta_col))
    Binary(op, left, right) =>
      Binary(
        op,
        shift_ast(left, delta_row, delta_col),
        shift_ast(right, delta_row, delta_col),
      )
    Array2D(rows) => {
      let shifted_rows = Array::new(capacity=rows.length())
      for row in rows {
        let shifted_row = Array::new(capacity=row.length())
        for cell in row {
          shifted_row.push(shift_ast(cell, delta_row, delta_col))
        }
        shifted_rows.push(shifted_row)
      }
      Array2D(shifted_rows)
    }
  }
}

///|
/// §18.3.1.40 shared formulas and §18.18.7 cell refs — given a master cell's
/// address and AST plus a dependent cell's address, return the dependent
/// cell's effective AST by shifting relative references by the dependent
/// offset.
pub fn expand_shared_formula(
  master_address : @address.CellAddress,
  master_ast : FormulaAst,
  dependent_address : @address.CellAddress,
) -> FormulaAst {
  shift_ast(
    master_ast,
    dependent_address.row_zero_based - master_address.row_zero_based,
    dependent_address.col_zero_based - master_address.col_zero_based,
  )
}

///|
/// §18.3.1.40 shared formulas and §18.18.7 cell refs — parse the master
/// formula text and expand it for a dependent cell. Raises SchemaViolation
/// when the master formula text does not parse.
pub fn expand_shared_formula_text(
  master_address : @address.CellAddress,
  master_formula : String,
  dependent_address : @address.CellAddress,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  expand_shared_formula(
    master_address,
    parse_formula(master_formula),
    dependent_address,
  )
}

///|
fn shift_reference_lexeme(
  lexeme : String,
  delta_row : Int,
  delta_col : Int,
) -> String {
  match try_parse_cell(lexeme) {
    Some(cell) => format_shifted_cell(cell, delta_row, delta_col)
    None =>
      if lexeme.contains_char(':') {
        match try_parse_range(lexeme) {
          Some(range) => format_shifted_range(range, delta_row, delta_col)
          None => lexeme
        }
      } else {
        lexeme
      }
  }
}

///|
fn try_parse_cell(lexeme : String) -> @address.CellAddress? {
  Some(@address.CellAddress::parse_a1(lexeme)) catch {
    _ => None
  }
}

///|
fn try_parse_range(lexeme : String) -> @address.CellRange? {
  Some(@address.CellRange::parse_a1(lexeme)) catch {
    _ => None
  }
}

///|
fn format_shifted_cell(
  cell : @address.CellAddress,
  delta_row : Int,
  delta_col : Int,
) -> String {
  format_shifted_ref_body(
    Some(shift_axis(cell.col_zero_based, cell.col_absolute, delta_col)),
    Some(shift_axis(cell.row_zero_based, cell.row_absolute, delta_row)),
    cell.col_absolute,
    cell.row_absolute,
    cell.sheet,
  )
}

///|
fn format_shifted_range(
  range : @address.CellRange,
  delta_row : Int,
  delta_col : Int,
) -> String {
  let start = shifted_ref_body(
    range.start_col_zero_based,
    range.start_row_zero_based,
    range.start_col_absolute,
    range.start_row_absolute,
    delta_row,
    delta_col,
  )
  let end = shifted_ref_body(
    range.end_col_zero_based,
    range.end_row_zero_based,
    range.end_col_absolute,
    range.end_row_absolute,
    delta_row,
    delta_col,
  )
  if start == end {
    format_shifted_sheet(range.sheet) + start
  } else {
    format_shifted_sheet(range.sheet) + start + ":" + end
  }
}

///|
fn shifted_ref_body(
  col : Int?,
  row : Int?,
  col_absolute : Bool,
  row_absolute : Bool,
  delta_row : Int,
  delta_col : Int,
) -> String {
  format_shifted_ref_body(
    col.map(fn(value) { shift_axis(value, col_absolute, delta_col) }),
    row.map(fn(value) { shift_axis(value, row_absolute, delta_row) }),
    col_absolute,
    row_absolute,
    None,
  )
}

///|
fn shift_axis(value : Int, absolute : Bool, delta : Int) -> Int {
  if absolute {
    value
  } else {
    value + delta
  }
}

///|
fn format_shifted_ref_body(
  col : Int?,
  row : Int?,
  col_absolute : Bool,
  row_absolute : Bool,
  sheet : String?,
) -> String {
  let out = StringBuilder::new()
  out.write_string(format_shifted_sheet(sheet))
  if col is Some(c) {
    if col_absolute {
      out.write_char('$')
    }
    out.write_string(format_shifted_column(c))
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
fn format_shifted_column(index : Int) -> String {
  if index < 0 {
    ""
  } else {
    let out = StringBuilder::new()
    let mut n = index + 1
    while n > 0 {
      let rem = (n - 1) % 26
      out.write_char(('A'.to_int() + rem).unsafe_to_char())
      n = (n - 1) / 26
    }
    reverse_ascii(out.to_string())
  }
}

///|
fn reverse_ascii(value : String) -> String {
  let chars = value.to_array()
  let out = StringBuilder::new()
  for i in 0..<chars.length() {
    out.write_char(chars[chars.length() - i - 1])
  }
  out.to_string()
}

///|
fn format_shifted_sheet(sheet : String?) -> String {
  match sheet {
    None => ""
    Some(name) =>
      if shifted_sheet_requires_quotes(name) {
        "'" + escape_shifted_sheet_name(name) + "'!"
      } else {
        name + "!"
      }
  }
}

///|
fn shifted_sheet_requires_quotes(name : String) -> Bool {
  if name == "" {
    true
  } else {
    let mut needs = false
    for ch in name {
      if !(shifted_is_ascii_letter(ch) ||
        shifted_is_ascii_digit(ch) ||
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
fn escape_shifted_sheet_name(name : String) -> String {
  let out = StringBuilder::new()
  for ch in name {
    if ch == '\'' {
      out.write_string("''")
    } else {
      out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn shifted_is_ascii_letter(ch : Char) -> Bool {
  (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z')
}

///|
fn shifted_is_ascii_digit(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}
