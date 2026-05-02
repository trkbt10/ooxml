///|
/// §18.17.2 — result of evaluating a SpreadsheetML formula expression. This
/// mirrors scalar cell values after shared-string resolution and adds a 2-D
/// array carrier for array constants and reference ranges.
pub(all) enum FormulaValue {
  VNumber(Double)
  VString(String)
  VBool(Bool)
  VError(FormulaError)
  VEmpty
  VArray(Array[Array[FormulaValue]])
} derive(Eq, Debug)

///|
fn FormulaValue::first_scalar(self : FormulaValue) -> FormulaValue {
  match self {
    VArray(rows) =>
      match rows.get(0) {
        Some(row) =>
          match row.get(0) {
            Some(value) => value
            None => VEmpty
          }
        None => VEmpty
      }
    other => other
  }
}

///|
fn FormulaValue::first_error(self : FormulaValue) -> FormulaError? {
  match self {
    VError(err) => Some(err)
    VArray(rows) => {
      for row in rows {
        for value in row {
          if value.first_error() is Some(err) {
            return Some(err)
          }
        }
      }
      None
    }
    _ => None
  }
}
