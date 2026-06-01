///|
/// §18.17.7 GETPIVOTDATA — one `(field, item)` selector supplied
/// after the `data_field` and `pivot_table` arguments. Formula
/// evaluation owns only the argument contract; the PivotTable
/// package owns field/item resolution against materialized pivots.
pub(all) struct GetPivotDataFilter {
  field : String
  item : String
} derive(Eq, Debug)

///|
/// §18.17.7 GETPIVOTDATA — neutral request object passed from the
/// formula evaluator to the workbook/pivot owner. Keeping this type
/// in the formula package avoids a formula -> pivot_table dependency
/// cycle while preserving the PivotTable materializer as the only
/// source of aggregation semantics.
pub(all) struct GetPivotDataRequest {
  data_field : String
  anchor : @address.CellAddress
  filters : Array[GetPivotDataFilter]
} derive(Eq, Debug)

///|
/// §18.17 — workbook context for SpreadsheetML formula evaluation. The formula
/// package owns expression semantics, while callers provide workbook-specific
/// cell lookup, defined-name expansion, shared strings, date system, and the
/// function dispatch table. Pivot lookup is supplied as a callback so the
/// PivotTable materializer remains the aggregation source of truth.
pub(all) struct EvalContext {
  current_sheet : String
  current_cell : @address.CellAddress
  sst : @domain.CT_Sst?
  date_system : @date_serial.DateSystem
  registry : FunctionRegistry
  resolve_cell : (@address.CellAddress) -> FormulaValue
  resolve_name : (String) -> FormulaAst?
  resolve_pivot_data : (GetPivotDataRequest) -> FormulaValue?
}

///|
fn no_pivot_data(_request : GetPivotDataRequest) -> FormulaValue? {
  None
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
