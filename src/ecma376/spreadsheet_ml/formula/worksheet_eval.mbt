///|
/// §18.3 / §18.17 — minimal worksheet snapshot for formula evaluation. It
/// carries the cells keyed by address, shared strings, date system, and
/// shared-formula masters needed to evaluate formulas against worksheet data.
pub(all) struct WorksheetSnapshot {
  cells : @hashmap.HashMap[String, @domain.CT_Cell]
  sst : @domain.CT_Sst?
  date_system : @date_serial.DateSystem
  shared_formulas : @hashmap.HashMap[Int, (@address.CellAddress, String)]
  workbook_name : String?
  current_sheet : String
} derive(Eq, Debug)

///|
/// §18.3 / §18.17 — construct an empty worksheet snapshot for evaluating cells
/// on `current_sheet` with the workbook date system.
pub fn WorksheetSnapshot::new(
  current_sheet : String,
  date_system : @date_serial.DateSystem,
) -> WorksheetSnapshot {
  {
    cells: @hashmap.new(),
    sst: None,
    date_system,
    shared_formulas: @hashmap.new(),
    workbook_name: None,
    current_sheet,
  }
}

///|
/// §18.3 / §18.17 — return this snapshot after recording a CT_Cell at its A1
/// address. Unqualified addresses are keyed as `A1`; sheet-qualified addresses
/// are keyed as `Sheet!A1`.
pub fn WorksheetSnapshot::with_cell(
  self : WorksheetSnapshot,
  address : @address.CellAddress,
  cell : @domain.CT_Cell,
) -> WorksheetSnapshot {
  self.cells.set(worksheet_eval_key_for_store(address), cell)
  self
}

///|
/// §18.3 / §18.17 — return this snapshot after scanning a parsed CT_Worksheet's
/// sheetData rows and recording each `<c r="...">` cell.
pub fn WorksheetSnapshot::with_worksheet(
  self : WorksheetSnapshot,
  worksheet : @domain.CT_Worksheet,
) -> WorksheetSnapshot {
  for child in worksheet.element.children {
    match child {
      @xml.Node::Element(sheet_data) =>
        if worksheet_eval_is_element(sheet_data, "sheetData") {
          self.add_sheet_data(sheet_data)
        }
      _ => ()
    }
  }
  self
}

///|
/// §18.3 / §18.17 — return this snapshot after attaching the workbook shared
/// string table used to resolve `t="s"` cell values during evaluation.
pub fn WorksheetSnapshot::with_sst(
  self : WorksheetSnapshot,
  sst : @domain.CT_Sst,
) -> WorksheetSnapshot {
  { ..self, sst: Some(sst) }
}

///|
/// §18.3 / §18.17 — return this snapshot after registering a shared-formula
/// master by `si` for later dependent-cell expansion.
pub fn WorksheetSnapshot::with_shared_master(
  self : WorksheetSnapshot,
  si : Int,
  master_address : @address.CellAddress,
  master_text : String,
) -> WorksheetSnapshot {
  self.shared_formulas.set(si, (master_address, master_text))
  self
}

///|
/// §18.3 / §18.17 — evaluate the formula or literal value at `address` against
/// the worksheet snapshot. Formula errors are returned as FormulaValue::VError
/// values rather than raised.
pub fn evaluate_cell(
  snapshot : WorksheetSnapshot,
  address : @address.CellAddress,
) -> FormulaValue {
  let in_progress : @hashmap.HashMap[String, Bool] = @hashmap.new()
  worksheet_eval_cell(snapshot, address, in_progress)
}

///|
/// §18.3 / §18.17 — evaluate every formula cell in the snapshot's current
/// sheet, returning a fresh address-to-result map. Cycles return `#REF!` as the
/// integration sentinel.
pub fn evaluate_sheet(
  snapshot : WorksheetSnapshot,
) -> @hashmap.HashMap[String, FormulaValue] {
  let results : @hashmap.HashMap[String, FormulaValue] = @hashmap.new()
  snapshot.cells.each(fn(key, cell) {
    if worksheet_eval_cell_in_current_sheet(snapshot, key) &&
      worksheet_eval_formula_element(cell) is Some(_) {
      match worksheet_eval_address_from_key(snapshot, key) {
        Some(address) =>
          results.set(address.to_a1(), evaluate_cell(snapshot, address))
        None => ()
      }
    }
  })
  results
}

///|
fn WorksheetSnapshot::add_sheet_data(
  self : WorksheetSnapshot,
  sheet_data : @xml.Element,
) -> Unit {
  for row in sheet_data.children {
    match row {
      @xml.Node::Element(row_element) =>
        if worksheet_eval_is_element(row_element, "row") {
          self.add_row(row_element)
        }
      _ => ()
    }
  }
}

///|
fn WorksheetSnapshot::add_row(
  self : WorksheetSnapshot,
  row_element : @xml.Element,
) -> Unit {
  for child in row_element.children {
    match child {
      @xml.Node::Element(cell_element) =>
        if worksheet_eval_is_element(cell_element, "c") {
          match worksheet_eval_attr(cell_element, "r") {
            Some(reference) =>
              match worksheet_eval_parse_address(reference) {
                Some(address) =>
                  self.cells.set(
                    worksheet_eval_key_for_store(address),
                    @domain.CT_Cell::new(cell_element),
                  )
                None => ()
              }
            None => ()
          }
        }
      _ => ()
    }
  }
}

///|
fn worksheet_eval_cell(
  snapshot : WorksheetSnapshot,
  address : @address.CellAddress,
  in_progress : @hashmap.HashMap[String, Bool],
) -> FormulaValue {
  let key = worksheet_eval_key(snapshot, address)
  if in_progress.contains(key) {
    return VError(Ref)
  }
  let cell = match worksheet_eval_lookup_cell(snapshot, address) {
    Some(cell) => cell
    None => return VEmpty
  }
  match worksheet_eval_formula_element(cell) {
    None => worksheet_eval_literal(cell, snapshot)
    Some(formula_element) => {
      in_progress.set(key, true)
      let result = worksheet_eval_formula_cell(
        snapshot, address, formula_element, in_progress,
      )
      in_progress.remove(key)
      result
    }
  }
}

///|
fn worksheet_eval_formula_cell(
  snapshot : WorksheetSnapshot,
  address : @address.CellAddress,
  formula_element : @xml.Element,
  in_progress : @hashmap.HashMap[String, Bool],
) -> FormulaValue {
  let formula_type = worksheet_eval_attr(formula_element, "t")
  let body = worksheet_eval_text(formula_element)
  let ast = match formula_type {
    Some("shared") =>
      worksheet_eval_shared_ast(snapshot, address, formula_element, body)
    Some("array") | None | Some("normal") => worksheet_eval_parse_formula(body)
    Some(_) => worksheet_eval_parse_formula(body)
  }
  match ast {
    Some(ast) =>
      evaluate(ast, worksheet_eval_context(snapshot, address, in_progress))
    None => VError(Value)
  }
}

///|
fn worksheet_eval_shared_ast(
  snapshot : WorksheetSnapshot,
  address : @address.CellAddress,
  formula_element : @xml.Element,
  body : String,
) -> FormulaAst? {
  let si = worksheet_eval_shared_index(formula_element)
  if body != "" {
    match si {
      Some(index) =>
        if !snapshot.shared_formulas.contains(index) {
          snapshot.shared_formulas.set(index, (address, body))
        }
      None => ()
    }
    worksheet_eval_parse_formula(body)
  } else {
    match si {
      Some(index) =>
        match snapshot.shared_formulas.get(index) {
          Some((master_address, master_text)) =>
            Some(
              expand_shared_formula_text(master_address, master_text, address),
            ) catch {
              _ => None
            }
          None => None
        }
      None => None
    }
  }
}

///|
fn worksheet_eval_context(
  snapshot : WorksheetSnapshot,
  address : @address.CellAddress,
  in_progress : @hashmap.HashMap[String, Bool],
) -> EvalContext {
  let registry = FunctionRegistry::new()
  register_builtin_functions(registry)
  {
    current_sheet: snapshot.current_sheet,
    current_cell: address,
    sst: snapshot.sst,
    date_system: snapshot.date_system,
    registry,
    resolve_cell: fn(target) {
      worksheet_eval_cell(snapshot, target, in_progress)
    },
    resolve_name: fn(_) { None },
  }
}

///|
fn worksheet_eval_literal(
  cell : @domain.CT_Cell,
  snapshot : WorksheetSnapshot,
) -> FormulaValue {
  let decoded = try? @cell_value.decode_cell_value_with_sst(cell, snapshot.sst)
  match decoded {
    Ok(value) =>
      worksheet_eval_cell_value_to_formula(value, snapshot.date_system)
    Err(_) => VError(Value)
  }
}

///|
fn worksheet_eval_cell_value_to_formula(
  value : @cell_value.CellValue,
  date_system : @date_serial.DateSystem,
) -> FormulaValue {
  match value {
    @cell_value.Boolean(value) => VBool(value)
    @cell_value.Date(value) =>
      VNumber(@date_serial.date_time_to_serial(value, date_system)) catch {
        _ => VError(Value)
      }
    @cell_value.Error(value) =>
      match FormulaError::from_literal(value) {
        Some(error) => VError(error)
        None => VError(Value)
      }
    @cell_value.InlineString(value) => VString(value)
    @cell_value.Number(value) => VNumber(value)
    @cell_value.SharedStringIndex(_) => VError(Value)
    @cell_value.FormulaString(value) => VString(value)
    @cell_value.Empty => VEmpty
  }
}

///|
fn worksheet_eval_parse_formula(source : String) -> FormulaAst? {
  Some(parse_formula(source)) catch {
    _ => None
  }
}

///|
fn worksheet_eval_lookup_cell(
  snapshot : WorksheetSnapshot,
  address : @address.CellAddress,
) -> @domain.CT_Cell? {
  let primary = worksheet_eval_key(snapshot, address)
  match snapshot.cells.get(primary) {
    Some(cell) => Some(cell)
    None => {
      let unqualified = worksheet_eval_unqualified_key(address)
      match snapshot.cells.get(unqualified) {
        Some(cell) => Some(cell)
        None =>
          match address.sheet {
            Some(sheet) =>
              if sheet == snapshot.current_sheet {
                snapshot.cells.get(worksheet_eval_unqualified_key(address))
              } else {
                None
              }
            None =>
              snapshot.cells.get(
                snapshot.current_sheet +
                "!" +
                worksheet_eval_unqualified_key(address),
              )
          }
      }
    }
  }
}

///|
fn worksheet_eval_formula_element(cell : @domain.CT_Cell) -> @xml.Element? {
  worksheet_eval_child_element(cell.element, "f")
}

///|
fn worksheet_eval_child_element(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if worksheet_eval_is_element(child_element, local_name) {
          return Some(child_element)
        }
      _ => ()
    }
  }
  None
}

///|
fn worksheet_eval_attr(element : @xml.Element, local_name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return Some(attr.value)
    }
  }
  None
}

///|
fn worksheet_eval_text(element : @xml.Element) -> String {
  let mut out = ""
  for child in element.children {
    match child {
      @xml.Node::Text(value) => out = out + value
      @xml.Node::CData(value) => out = out + value
      _ => ()
    }
  }
  out
}

///|
fn worksheet_eval_shared_index(formula_element : @xml.Element) -> Int? {
  match worksheet_eval_attr(formula_element, "si") {
    Some(value) => Some(@strconv.from_str(value)) catch { _ => None }
    None => None
  }
}

///|
fn worksheet_eval_key(
  snapshot : WorksheetSnapshot,
  address : @address.CellAddress,
) -> String {
  match address.sheet {
    Some(sheet) => sheet + "!" + worksheet_eval_unqualified_key(address)
    None =>
      if snapshot.current_sheet == "" {
        worksheet_eval_unqualified_key(address)
      } else {
        snapshot.current_sheet + "!" + worksheet_eval_unqualified_key(address)
      }
  }
}

///|
fn worksheet_eval_key_for_store(address : @address.CellAddress) -> String {
  match address.sheet {
    Some(sheet) => sheet + "!" + worksheet_eval_unqualified_key(address)
    None => worksheet_eval_unqualified_key(address)
  }
}

///|
/// §18.18.62 — the column index of a well-formed CellAddress
/// (the dispatch only fires from CellAddress::parse paths that
/// reject negative columns) is always in 0..16383, so the
/// `column_index_to_letter` raise path is unreachable in
/// practice.  The defensive empty-string fallback is preserved
/// only so a hand-built CellAddress with a negative column
/// fails loudly downstream rather than crashing the eval loop.
fn worksheet_eval_unqualified_key(address : @address.CellAddress) -> String {
  (@address.column_index_to_letter(address.col_zero_based) catch { _ => "" }) +
  (address.row_zero_based + 1).to_string()
}

///|
fn worksheet_eval_cell_in_current_sheet(
  snapshot : WorksheetSnapshot,
  key : String,
) -> Bool {
  match key.split_once("!") {
    Some((sheet, _)) => sheet.to_owned() == snapshot.current_sheet
    None => true
  }
}

///|
fn worksheet_eval_address_from_key(
  snapshot : WorksheetSnapshot,
  key : String,
) -> @address.CellAddress? {
  let ref_text = match key.split_once("!") {
    Some((sheet, body)) =>
      if sheet.to_owned() == snapshot.current_sheet {
        body.to_owned()
      } else {
        key
      }
    None => key
  }
  worksheet_eval_parse_address(ref_text)
}

///|
fn worksheet_eval_parse_address(value : String) -> @address.CellAddress? {
  Some(@address.CellAddress::parse_a1(value)) catch {
    _ => None
  }
}

///|
fn worksheet_eval_is_element(
  element : @xml.Element,
  local_name : String,
) -> Bool {
  element.name.local_name == local_name
}
