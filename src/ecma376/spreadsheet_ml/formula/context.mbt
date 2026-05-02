///|
/// §18.17 — workbook context for SpreadsheetML formula evaluation. The formula
/// package owns expression semantics, while callers provide workbook-specific
/// cell lookup, defined-name expansion, shared strings, date system, and the
/// function dispatch table.
pub(all) struct EvalContext {
  current_sheet : String
  current_cell : @address.CellAddress
  sst : @domain.CT_Sst?
  date_system : @date_serial.DateSystem
  registry : FunctionRegistry
  resolve_cell : (@address.CellAddress) -> FormulaValue
  resolve_name : (String) -> FormulaAst?
}

///|
fn EvalContext::current_sheet_or(
  self : EvalContext,
  sheet : String?,
) -> String? {
  match sheet {
    Some(name) => Some(name)
    None =>
      if self.current_sheet == "" {
        None
      } else {
        Some(self.current_sheet)
      }
  }
}
