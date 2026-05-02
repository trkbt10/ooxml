///|
/// §18.17.4 / §18.18.5 — coerce a SpreadsheetML formula value to a numeric
/// scalar for arithmetic operators. Errors propagate, empty cells become zero,
/// booleans become 1 or 0, and numeric text parses as a finite Double.
pub fn coerce_to_number(
  v : FormulaValue,
  date_system : @date_serial.DateSystem,
) -> FormulaValue {
  let _ = date_system
  match v.first_scalar() {
    VNumber(value) =>
      if value.is_nan() || value.is_inf() {
        VError(Num)
      } else {
        VNumber(value)
      }
    VBool(value) => VNumber(if value { 1.0 } else { 0.0 })
    VEmpty => VNumber(0.0)
    VError(err) => VError(err)
    VString(text) => {
      let number : Double = try
        @strconv.from_str(text.trim().to_owned())
      catch {
        _ => return VError(Value)
      } noraise {
        parsed => parsed
      }
      if number.is_nan() || number.is_inf() {
        VError(Value)
      } else {
        VNumber(number)
      }
    }
    VArray(_) => VError(Value)
  }
}

///|
/// §18.17.4 — coerce a SpreadsheetML formula value to text for the `&`
/// operator and text-oriented function arguments. Errors become their literal
/// spellings, booleans become `TRUE`/`FALSE`, and empty cells become `""`.
pub fn coerce_to_text(v : FormulaValue) -> FormulaValue {
  match v.first_scalar() {
    VString(value) => VString(value)
    VNumber(value) =>
      if value.is_nan() || value.is_inf() {
        VError(Num)
      } else {
        VString(value.to_string())
      }
    VBool(value) => VString(if value { "TRUE" } else { "FALSE" })
    VEmpty => VString("")
    VError(err) => VString(err.to_literal())
    VArray(_) => VError(Value)
  }
}

///|
/// §18.17.4 — coerce a SpreadsheetML formula value to logical truth. Numeric
/// zero is false and non-zero numbers are true; `TRUE` and `FALSE` text values
/// are accepted case-insensitively; other text cannot be coerced.
pub fn coerce_to_bool(v : FormulaValue) -> FormulaValue {
  match v.first_scalar() {
    VBool(value) => VBool(value)
    VNumber(value) =>
      if value.is_nan() || value.is_inf() {
        VError(Value)
      } else {
        VBool(value != 0.0)
      }
    VString(value) => {
      let upper = formula_ascii_upper(value.trim().to_owned())
      match upper {
        "TRUE" => VBool(true)
        "FALSE" => VBool(false)
        _ => VError(Value)
      }
    }
    VEmpty => VBool(false)
    VError(err) => VError(err)
    VArray(_) => VError(Value)
  }
}
