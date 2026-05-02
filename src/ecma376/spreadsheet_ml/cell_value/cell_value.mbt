///|
/// §18.18.11 ST_CellType discriminator value, as a typed enum after
/// XML decoding. Variants mirror the 7 spec values: b, d, e, inlineStr,
/// n, s, str.
pub(all) enum CellValue {
  /// §18.18.11 b — boolean. <v>1</v> = true, <v>0</v> = false.
  Boolean(Bool)
  /// §18.18.11 d — date in ISO 8601 format.
  Date(@date_serial.CalendarDateTime)
  /// §18.18.11 e — error literal as the spec error string.
  Error(String)
  /// §18.18.11 inlineStr — rich-text string carried in <is>.
  InlineString(String)
  /// §18.18.11 n — number parsed as Double.
  Number(Double)
  /// §18.18.11 s — shared string index.
  SharedStringIndex(Int)
  /// §18.18.11 str — formula-result string.
  FormulaString(String)
  /// §18.3.1.4 — empty cell with no @t and no <v>.
  Empty
} derive(Eq, Debug)

///|
let cell_value_section = "Part 1 §18.18.11 / §18.3.1.4"

///|
let cell_value_errors : ReadOnlyArray[String] = [
  "#DIV/0!", "#N/A", "#NAME?", "#NULL!", "#NUM!", "#REF!", "#VALUE!",
]

///|
/// §18.3.1.4 — decode a CT_Cell element's typed value according to
/// §18.18.11 ST_CellType. Shared string indices remain unresolved.
pub fn decode_cell_value(
  cell : @domain.CT_Cell,
) -> CellValue raise @opc_errors.SchemaViolation {
  decode_cell_value_with_sst(cell, None)
}

///|
/// §18.3.1.4 — decode a CT_Cell element's typed value according to
/// §18.18.11 ST_CellType, resolving @t="s" through CT_Sst when supplied.
pub fn decode_cell_value_with_sst(
  cell : @domain.CT_Cell,
  sst : @domain.CT_Sst?,
) -> CellValue raise @opc_errors.SchemaViolation {
  let cell_type = cell_value_attr(cell.element, "t")
  let raw_value = cell_value_child_text(cell.element, "v")
  let inline = cell_value_child_element(cell.element, "is")
  match cell_type {
    None =>
      match raw_value {
        Some(value) => Number(cell_value_parse_double(value, "c/v"))
        None => Empty
      }
    Some("b") =>
      Boolean(cell_value_parse_bool(cell_value_require(raw_value, "c/v")))
    Some("d") =>
      Date(cell_value_parse_date_time(cell_value_require(raw_value, "c/v")))
    Some("e") =>
      Error(cell_value_parse_error(cell_value_require(raw_value, "c/v")))
    Some("inlineStr") =>
      match inline {
        Some(element) =>
          InlineString(@domain.CT_Rst::new(element).to_plain_text())
        None =>
          cell_value_violation(
            "c/is", "inlineStr cell has no inline string payload",
          )
      }
    Some("n") =>
      Number(
        cell_value_parse_double(cell_value_require(raw_value, "c/v"), "c/v"),
      )
    Some("s") => {
      let index = cell_value_parse_index(cell_value_require(raw_value, "c/v"))
      match sst {
        None => SharedStringIndex(index)
        Some(table) =>
          match table.lookup(index) {
            Some(text) => InlineString(text)
            None =>
              cell_value_violation(
                "c/v", "shared string index is outside the SST",
              )
          }
      }
    }
    Some("str") => FormulaString(cell_value_require(raw_value, "c/v"))
    Some(other) =>
      cell_value_violation("c/@t", "unknown ST_CellType `\{other}`")
  }
}

///|
/// §18.18.11 — coerce a CellValue to its display text per Excel's
/// default coercion rules for decoded §18.3.1.4 cell values.
pub fn CellValue::to_display_text(self : CellValue) -> String {
  match self {
    Boolean(value) => if value { "TRUE" } else { "FALSE" }
    Date(value) => cell_value_format_date_time(value)
    Error(value) => value
    InlineString(value) => value
    Number(value) => value.to_string()
    SharedStringIndex(value) => value.to_string()
    FormulaString(value) => value
    Empty => ""
  }
}

///|
/// §18.18.11 — coerce a CellValue to a numeric Double per Excel's
/// implicit math coercion rules for decoded §18.3.1.4 cell values.
pub fn CellValue::to_number(
  self : CellValue,
  date_system : @date_serial.DateSystem,
) -> Double raise @opc_errors.SchemaViolation {
  match self {
    Number(value) => value
    Boolean(value) => if value { 1.0 } else { 0.0 }
    Empty => 0.0
    Date(value) => @date_serial.date_time_to_serial(value, date_system)
    InlineString(_) =>
      cell_value_violation(
        "CellValue", "inline strings cannot be coerced to number",
      )
    SharedStringIndex(_) =>
      cell_value_violation(
        "CellValue", "unresolved shared strings cannot be coerced to number",
      )
    FormulaString(_) =>
      cell_value_violation(
        "CellValue", "formula strings cannot be coerced to number",
      )
    Error(value) =>
      cell_value_violation(
        "CellValue",
        "error value `\{value}` cannot be coerced to number",
      )
  }
}

///|
fn cell_value_attr(element : @xml.Element, local_name : String) -> String? {
  let _ = @address.RefMode::A1
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return Some(attr.value)
    }
  }
  None
}

///|
fn cell_value_child_element(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return Some(child_element)
        }
      _ => ()
    }
  }
  None
}

///|
fn cell_value_child_text(
  element : @xml.Element,
  local_name : String,
) -> String? {
  match cell_value_child_element(element, local_name) {
    Some(child_element) => Some(cell_value_text(child_element))
    None => None
  }
}

///|
fn cell_value_text(element : @xml.Element) -> String {
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
fn cell_value_require(
  value : String?,
  path : String,
) -> String raise @opc_errors.SchemaViolation {
  match value {
    Some(value) => value
    None => cell_value_violation(path, "cell type requires a value payload")
  }
}

///|
fn cell_value_parse_bool(
  value : String,
) -> Bool raise @opc_errors.SchemaViolation {
  match value {
    "1" | "true" => true
    "0" | "false" => false
    other =>
      cell_value_violation("c/v", "invalid boolean cell value `\{other}`")
  }
}

///|
fn cell_value_parse_error(
  value : String,
) -> String raise @opc_errors.SchemaViolation {
  for error in cell_value_errors {
    if value == error {
      return value
    }
  }
  cell_value_violation("c/v", "invalid error cell value `\{value}`")
}

///|
fn cell_value_parse_index(
  value : String,
) -> Int raise @opc_errors.SchemaViolation {
  let index : Int = try @strconv.from_str(value) catch {
    _ => cell_value_violation("c/v", "shared string index is not an integer")
  } noraise {
    parsed => parsed
  }
  if index < 0 {
    cell_value_violation("c/v", "shared string index is negative")
  } else {
    index
  }
}

///|
fn cell_value_parse_double(
  value : String,
  path : String,
) -> Double raise @opc_errors.SchemaViolation {
  let number : Double = try @strconv.from_str(value) catch {
    _ => cell_value_violation(path, "numeric cell value is not a Double")
  } noraise {
    parsed => parsed
  }
  if number.is_nan() || number.is_inf() {
    cell_value_violation(path, "numeric cell value is not finite")
  } else {
    number
  }
}

///|
fn cell_value_parse_date_time(
  value : String,
) -> @date_serial.CalendarDateTime raise @opc_errors.SchemaViolation {
  let length = value.length()
  if length != 19 && length != 20 && length < 21 {
    cell_value_violation("c/v", "date cell value is not an ISO 8601 dateTime")
  }
  let has_z = value.code_unit_at(length - 1) == 'Z'
  let end = if has_z { length - 1 } else { length }
  if end < 19 ||
    value.code_unit_at(4) != '-' ||
    value.code_unit_at(7) != '-' ||
    value.code_unit_at(10) != 'T' ||
    value.code_unit_at(13) != ':' ||
    value.code_unit_at(16) != ':' {
    cell_value_violation("c/v", "date cell value is not an ISO 8601 dateTime")
  }
  let year = cell_value_parse_fixed_int(value, 0, 4, "year")
  let month = cell_value_parse_fixed_int(value, 5, 7, "month")
  let day = cell_value_parse_fixed_int(value, 8, 10, "day")
  let hour = cell_value_parse_fixed_int(value, 11, 13, "hour")
  let minute = cell_value_parse_fixed_int(value, 14, 16, "minute")
  let second = cell_value_parse_fixed_int(value, 17, 19, "second")
  let millisecond = if end == 19 {
    0
  } else if value.code_unit_at(19) == '.' {
    cell_value_parse_fraction_millis(value, 20, end)
  } else {
    cell_value_violation("c/v", "date cell timezone offsets are not accepted")
  }
  let dt = @date_serial.CalendarDateTime::{
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
  }
  @date_serial.date_time_to_serial(dt, @date_serial.DateSystem::Serial1900)
  |> ignore
  dt
}

///|
fn cell_value_parse_fixed_int(
  value : String,
  start : Int,
  end : Int,
  field : String,
) -> Int raise @opc_errors.SchemaViolation {
  let mut out = 0
  for index in start..<end {
    let ch = value.code_unit_at(index)
    if ch < '0' || ch > '9' {
      cell_value_violation("c/v", "date cell \{field} contains a non-digit")
    }
    out = out * 10 + (ch.to_int() - '0'.to_int())
  }
  out
}

///|
fn cell_value_parse_fraction_millis(
  value : String,
  start : Int,
  end : Int,
) -> Int raise @opc_errors.SchemaViolation {
  if start >= end {
    cell_value_violation("c/v", "date cell fractional second is empty")
  }
  let mut millis = 0
  let mut scale = 100
  for index in start..<end {
    let ch = value.code_unit_at(index)
    if ch < '0' || ch > '9' {
      cell_value_violation(
        "c/v", "date cell fractional second contains a non-digit",
      )
    }
    if scale > 0 {
      millis = millis + (ch.to_int() - '0'.to_int()) * scale
      scale = scale / 10
    }
  }
  millis
}

///|
fn cell_value_format_date_time(dt : @date_serial.CalendarDateTime) -> String {
  let base = cell_value_pad4(dt.year) +
    "-" +
    cell_value_pad2(dt.month) +
    "-" +
    cell_value_pad2(dt.day) +
    "T" +
    cell_value_pad2(dt.hour) +
    ":" +
    cell_value_pad2(dt.minute) +
    ":" +
    cell_value_pad2(dt.second)
  if dt.millisecond == 0 {
    base
  } else {
    base + "." + cell_value_pad3(dt.millisecond)
  }
}

///|
fn cell_value_pad2(value : Int) -> String {
  if value < 10 {
    "0" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
fn cell_value_pad3(value : Int) -> String {
  if value < 10 {
    "00" + value.to_string()
  } else if value < 100 {
    "0" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
fn cell_value_pad4(value : Int) -> String {
  if value < 10 {
    "000" + value.to_string()
  } else if value < 100 {
    "00" + value.to_string()
  } else if value < 1000 {
    "0" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
fn[T] cell_value_violation(
  path : String,
  reason : String,
) -> T raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(section=cell_value_section, path~, reason~)
}
