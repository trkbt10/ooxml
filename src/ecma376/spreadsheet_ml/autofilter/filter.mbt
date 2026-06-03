///|
/// §18.3.2 — typed view of one cell in a candidate row, supplied to the
/// filter evaluator. Runtime-only: no XSD analogue. The evaluator does not
/// fetch cell content itself.
pub(all) struct CandidateRow {
  values : Array[@formula.FormulaValue]
  row_index : Int
} derive(Eq, Debug)

///|
/// §18.3.2.1 / §18.3.2.9 — runtime formatting facts for one AutoFilter
/// candidate cell. Producers resolve these through their own style / CF
/// source of truth; this package only compares the resolved facts to the
/// active colorFilter / iconFilter rule. Colour strings may be supplied as
/// CSS `#RRGGBB`, raw `RRGGBB`, or OOXML `AARRGGBB`; comparison is
/// canonicalized in this package.
pub(all) struct CandidateCellFormat {
  value : @formula.FormulaValue
  fill_color : String?
  font_color : String?
  rich_text_font_colors : Array[String]
  icon_set : String?
  icon_id : Int?
} derive(Eq, Debug)

///|
/// Runtime candidate row carrying both scalar values and resolved format
/// facts. `cells[N]` corresponds to AutoFilter `filterColumn/@colId=N`.
pub(all) struct FormattedCandidateRow {
  cells : Array[CandidateCellFormat]
  row_index : Int
} derive(Eq, Debug)

///|
/// Runtime projection of a referenced differential format (`dxfId`) into
/// the only facts AutoFilter needs: fill and font colours. The stylesheet
/// resolver owns conversion from CT_Dxf/theme/indexed colour into these
/// strings; AutoFilter owns the rule comparison and colour-token
/// canonicalization.
pub(all) struct FilterDxfFormat {
  dxf_id : Int
  fill_color : String?
  font_color : String?
} derive(Eq, Debug)

///|
/// §18.3.1.2 / §18.3.2.7 — decode a `<autoFilter ref="...">` XML element
/// into the typed `@domain.CT_AutoFilter`.
pub fn parse_auto_filter(
  element : @xml.Element,
) -> @domain.CT_AutoFilter raise @opc_errors.SchemaViolation {
  parse_auto_filter_with_ref(element, None)
}

///|
/// §18.3.1.2 — decode `<autoFilter>` using `default_ref` when the XML omits
/// `@ref`.  Table markup supplies the table range as the owning context; the
/// parsing of `filterColumn` and its presentation flags remains shared here.
pub fn parse_auto_filter_with_default_ref(
  element : @xml.Element,
  default_ref : String,
) -> @domain.CT_AutoFilter raise @opc_errors.SchemaViolation {
  parse_auto_filter_with_ref(element, Some(default_ref))
}

///|
fn parse_auto_filter_with_ref(
  element : @xml.Element,
  default_ref : String?,
) -> @domain.CT_AutoFilter raise @opc_errors.SchemaViolation {
  let ref_value = match attr(element, "ref") {
    Some(value) => value
    None =>
      match default_ref {
        Some(value) => value
        None => require_attr(element, "ref", "autoFilter/@ref")
      }
  }
  let range = @address.CellRange::parse_a1(ref_value) catch {
    _ =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.1.2",
        path="autoFilter/@ref",
        reason="invalid ST_Ref range",
      )
  }
  let filter_columns = Array::new()
  for child in element.children {
    match child {
      @xml.Node::Element(e) =>
        if e.name.local_name == "filterColumn" {
          filter_columns.push(parse_filter_column(e))
        }
      _ => ()
    }
  }
  { range, filter_columns }
}

///|
/// §18.3.2.7 — return true if `row` should be visible after applying every
/// FilterColumn rule that can be evaluated without the full candidate set.
pub fn row_visible(
  filter : @domain.CT_AutoFilter,
  row : CandidateRow,
  date_system : @date_serial.DateSystem,
) -> Bool {
  row_visible_internal(filter, row, date_system, None, None)
}

///|
/// §18.3.2.5 — value-only row visibility with an explicit date anchor for
/// dynamic filters (`today`, `thisMonth`, `yearToDate`, ...).  The legacy
/// `row_visible` API is retained for deterministic callers; interactive
/// renderers should pass their host/workbook "today" through this entry point.
pub fn row_visible_at(
  filter : @domain.CT_AutoFilter,
  row : CandidateRow,
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime,
) -> Bool {
  row_visible_internal(filter, row, date_system, Some(today), None)
}

///|
fn row_visible_internal(
  filter : @domain.CT_AutoFilter,
  row : CandidateRow,
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime?,
  format_context : FilterFormatContext?,
) -> Bool {
  for column in filter.filter_columns {
    let value = match row.values.get(column.col_id) {
      Some(v) => v
      None => @formula.FormulaValue::VEmpty
    }
    if !rule_visible(
        column.rule,
        column.col_id,
        value,
        date_system,
        today,
        format_context,
      ) {
      return false
    }
  }
  true
}

///|
/// §18.3.2.10 / §18.3.2.5 — return visible row indices from candidate rows,
/// including set-wide evaluation needed by top10 and average dynamic
/// filters.
pub fn filter_rows(
  filter : @domain.CT_AutoFilter,
  rows : Array[CandidateRow],
  date_system : @date_serial.DateSystem,
) -> Array[Int] {
  filter_rows_internal(filter, rows, date_system, None, fn(_, _) { None })
}

///|
/// §18.3.2.5 / §18.3.2.10 — value-only candidate-set filtering with an
/// explicit date anchor for dynamic filters.
pub fn filter_rows_at(
  filter : @domain.CT_AutoFilter,
  rows : Array[CandidateRow],
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime,
) -> Array[Int] {
  filter_rows_internal(filter, rows, date_system, Some(today), fn(_, _) { None })
}

///|
/// §18.3.2 — evaluate row visibility from scalar values plus resolved
/// cell-format facts. Callers own style / dxf / icon resolution;
/// AutoFilter remains the single source of truth for `colorFilter` /
/// `iconFilter` comparison semantics.
pub fn row_visible_with_formats(
  filter : @domain.CT_AutoFilter,
  row : FormattedCandidateRow,
  dxf_formats : Array[FilterDxfFormat],
  date_system : @date_serial.DateSystem,
) -> Bool {
  row_visible_with_formats_at_internal(
    filter,
    row,
    dxf_formats,
    date_system,
    None,
  )
}

///|
/// §18.3.2 — formatted row visibility with an explicit date anchor for
/// dynamic filters. Formatting facts are still supplied by the caller; this
/// package remains the single comparison SoT.
pub fn row_visible_with_formats_at(
  filter : @domain.CT_AutoFilter,
  row : FormattedCandidateRow,
  dxf_formats : Array[FilterDxfFormat],
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime,
) -> Bool {
  row_visible_with_formats_at_internal(
    filter,
    row,
    dxf_formats,
    date_system,
    Some(today),
  )
}

///|
fn row_visible_with_formats_at_internal(
  filter : @domain.CT_AutoFilter,
  row : FormattedCandidateRow,
  dxf_formats : Array[FilterDxfFormat],
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime?,
) -> Bool {
  let candidate = candidate_row_from_formatted(row)
  row_visible_internal(
    filter,
    candidate,
    date_system,
    today,
    Some({ row, dxf_formats }),
  )
}

///|
/// §18.3.2 — evaluate a candidate set from scalar values plus resolved
/// cell-format facts. Returns visible row indices, including set-wide
/// Top10 / aboveAverage / belowAverage handling.
pub fn filter_formatted_rows(
  filter : @domain.CT_AutoFilter,
  rows : Array[FormattedCandidateRow],
  dxf_formats : Array[FilterDxfFormat],
  date_system : @date_serial.DateSystem,
) -> Array[Int] {
  filter_formatted_rows_at_internal(
    filter,
    rows,
    dxf_formats,
    date_system,
    None,
  )
}

///|
/// §18.3.2 — formatted candidate-set filtering with an explicit date anchor
/// for dynamic filters.
pub fn filter_formatted_rows_at(
  filter : @domain.CT_AutoFilter,
  rows : Array[FormattedCandidateRow],
  dxf_formats : Array[FilterDxfFormat],
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime,
) -> Array[Int] {
  filter_formatted_rows_at_internal(
    filter,
    rows,
    dxf_formats,
    date_system,
    Some(today),
  )
}

///|
fn filter_formatted_rows_at_internal(
  filter : @domain.CT_AutoFilter,
  rows : Array[FormattedCandidateRow],
  dxf_formats : Array[FilterDxfFormat],
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime?,
) -> Array[Int] {
  let candidates = Array::new()
  for row in rows {
    candidates.push(candidate_row_from_formatted(row))
  }
  filter_rows_internal(filter, candidates, date_system, today, fn(_, ordinal) {
    match rows.get(ordinal) {
      Some(row) => Some({ row, dxf_formats })
      None => None
    }
  })
}

///|
fn filter_rows_internal(
  filter : @domain.CT_AutoFilter,
  rows : Array[CandidateRow],
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime?,
  format_context_for_row : (CandidateRow, Int) -> FilterFormatContext?,
) -> Array[Int] {
  let base = Array::new()
  for ordinal, row in rows {
    if row_visible_internal(
        filter,
        row,
        date_system,
        today,
        format_context_for_row(row, ordinal),
      ) {
      base.push(row)
    }
  }
  let visible = Array::new()
  for row in base {
    if row_visible_with_context(filter, row, rows, date_system) {
      visible.push(row.row_index)
    }
  }
  visible
}

///|
fn candidate_row_from_formatted(row : FormattedCandidateRow) -> CandidateRow {
  let values = Array::new()
  for cell in row.cells {
    values.push(cell.value)
  }
  { values, row_index: row.row_index }
}

///|
fn formatted_filter_matches(
  row : FormattedCandidateRow,
  dxf_formats : Array[FilterDxfFormat],
  column_id : Int,
  choice : @domain.CT_FilterColumn_Choice,
) -> Bool {
  let cell = match row.cells.get(column_id) {
    Some(c) => c
    None => return false
  }
  match choice {
    @domain.CT_FilterColumn_Choice::ColorFilter(filter) => {
      let target = dxf_color_for_filter(dxf_formats, filter)
      if filter.cell_color {
        optional_color_equal(cell.fill_color, target)
      } else {
        candidate_font_color_matches(cell, target)
      }
    }
    IconFilter(filter) =>
      cell.icon_set == Some(filter.icon_set) && cell.icon_id == filter.icon_id
    _ => false
  }
}

///|
fn dxf_color_for_filter(
  dxf_formats : Array[FilterDxfFormat],
  filter : @domain.CT_ColorFilter,
) -> String? {
  match filter.dxf_id {
    Some(id) =>
      for dxf in dxf_formats {
        if dxf.dxf_id == id {
          return if filter.cell_color { dxf.fill_color } else { dxf.font_color }
        }
      }
    None => ()
  }
  None
}

///|
fn candidate_font_color_matches(
  cell : CandidateCellFormat,
  target : String?,
) -> Bool {
  if optional_color_equal(cell.font_color, target) {
    return true
  }
  for color in cell.rich_text_font_colors {
    if optional_color_equal(Some(color), target) {
      return true
    }
  }
  false
}

///|
fn optional_color_equal(left : String?, right : String?) -> Bool {
  match (left, right) {
    (Some(a), Some(b)) => canonical_filter_color(a) == canonical_filter_color(b)
    _ => false
  }
}

///|
priv struct FilterFormatContext {
  row : FormattedCandidateRow
  dxf_formats : Array[FilterDxfFormat]
}

///|
fn row_visible_with_context(
  filter : @domain.CT_AutoFilter,
  row : CandidateRow,
  rows : Array[CandidateRow],
  date_system : @date_serial.DateSystem,
) -> Bool {
  for column in filter.filter_columns {
    let value = match row.values.get(column.col_id) {
      Some(v) => v
      None => @formula.FormulaValue::VEmpty
    }
    match column.rule {
      Some(@domain.CT_FilterColumn_Choice::Top10(top10)) =>
        if !top10_passes(rows, column.col_id, value, date_system, top10) {
          return false
        }
      Some(
        @domain.CT_FilterColumn_Choice::DynamicFilter(
          { kind: AboveAverage, .. }
        )
      ) =>
        if !average_passes(rows, column.col_id, value, date_system, true) {
          return false
        }
      Some(
        @domain.CT_FilterColumn_Choice::DynamicFilter(
          { kind: BelowAverage, .. }
        )
      ) =>
        if !average_passes(rows, column.col_id, value, date_system, false) {
          return false
        }
      _ => ()
    }
  }
  true
}

///|
fn parse_filter_column(
  element : @xml.Element,
) -> @domain.CT_FilterColumn raise @opc_errors.SchemaViolation {
  let col_id = parse_required_int(element, "colId", "filterColumn/@colId")
  let hidden_button = parse_bool_attr(element, "hiddenButton", false)
  let show_button = parse_bool_attr(element, "showButton", true)
  let mut rule : @domain.CT_FilterColumn_Choice? = None
  for child in element.children {
    match child {
      @xml.Node::Element(e) =>
        match e.name.local_name {
          "filters" => rule = Some(Filters(parse_filters(e)))
          "customFilters" => rule = Some(CustomFilters(parse_custom_filters(e)))
          "dynamicFilter" => rule = Some(DynamicFilter(parse_dynamic_filter(e)))
          "colorFilter" => rule = Some(ColorFilter(parse_color_filter(e)))
          "iconFilter" => rule = Some(IconFilter(parse_icon_filter(e)))
          "top10" => rule = Some(Top10(parse_top10(e)))
          _ => ()
        }
      _ => ()
    }
  }
  { col_id, hidden_button, show_button, rule }
}

///|
fn parse_filters(
  element : @xml.Element,
) -> @domain.CT_Filters raise @opc_errors.SchemaViolation {
  let blank = parse_bool_attr(element, "blank", false)
  let calendar_type = parse_calendar_type_attr(
    attr_or(element, "calendarType", "none"),
    "filters/@calendarType",
  )
  let filters : Array[@domain.CT_Filter] = Array::new()
  let date_group_items : Array[@domain.CT_DateGroupItem] = Array::new()
  for child in element.children {
    match child {
      @xml.Node::Element(e) =>
        match e.name.local_name {
          "filter" =>
            filters.push({ val: require_attr(e, "val", "filter/@val") })
          "dateGroupItem" => date_group_items.push(parse_date_group_item(e))
          _ => ()
        }
      _ => ()
    }
  }
  { filters, date_group_items, blank, calendar_type }
}

///|
fn parse_custom_filters(
  element : @xml.Element,
) -> @domain.CT_CustomFilters raise @opc_errors.SchemaViolation {
  let and_op = parse_bool_attr(element, "and", false)
  let criteria : Array[@domain.CT_CustomFilter] = Array::new()
  for child in element.children {
    match child {
      @xml.Node::Element(e) =>
        if e.name.local_name == "customFilter" {
          let operator = parse_filter_operator(attr_or(e, "operator", "equal"))
          let val = require_attr(e, "val", "customFilter/@val")
          criteria.push({ operator, val })
        }
      _ => ()
    }
  }
  { criteria, and_op }
}

///|
fn parse_dynamic_filter(
  element : @xml.Element,
) -> @domain.CT_DynamicFilter raise @opc_errors.SchemaViolation {
  let kind = parse_dynamic_filter_type(
    require_attr(element, "type", "dynamicFilter/@type"),
  )
  let val = parse_optional_double(element, "val", "dynamicFilter/@val")
  let max_val = parse_optional_double(
    element, "maxVal", "dynamicFilter/@maxVal",
  )
  { kind, val, max_val }
}

///|
fn parse_color_filter(
  element : @xml.Element,
) -> @domain.CT_ColorFilter raise @opc_errors.SchemaViolation {
  let dxf_id = parse_optional_int(element, "dxfId", "colorFilter/@dxfId")
  let cell_color = parse_bool_attr(element, "cellColor", true)
  { dxf_id, cell_color }
}

///|
fn parse_icon_filter(
  element : @xml.Element,
) -> @domain.CT_IconFilter raise @opc_errors.SchemaViolation {
  let icon_set = parse_icon_set_type(
    require_attr(element, "iconSet", "iconFilter/@iconSet"),
  )
  let icon_id = parse_optional_int(element, "iconId", "iconFilter/@iconId")
  { icon_set, icon_id }
}

///|
fn parse_icon_set_type(
  value : String,
) -> String raise @opc_errors.SchemaViolation {
  try @sml_types.ST_IconSetType::new(value) catch {
    @sml_types.SchemaViolation(_) =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.18.42",
        path="iconFilter/@iconSet",
        reason="value is outside ST_IconSetType enumeration",
      )
  } noraise {
    parsed => parsed.to_string()
  }
}

///|
fn parse_top10(
  element : @xml.Element,
) -> @domain.CT_Top10 raise @opc_errors.SchemaViolation {
  let top = parse_bool_attr(element, "top", true)
  let percent = parse_bool_attr(element, "percent", false)
  let val = parse_required_double(element, "val", "top10/@val")
  let filter_val = parse_optional_double(
    element, "filterVal", "top10/@filterVal",
  )
  { top, percent, val, filter_val }
}

///|
fn parse_date_group_item(
  element : @xml.Element,
) -> @domain.CT_DateGroupItem raise @opc_errors.SchemaViolation {
  let year = parse_required_int(element, "year", "dateGroupItem/@year")
  let month = parse_optional_int(element, "month", "dateGroupItem/@month")
  let day = parse_optional_int(element, "day", "dateGroupItem/@day")
  let hour = parse_optional_int(element, "hour", "dateGroupItem/@hour")
  let minute = parse_optional_int(element, "minute", "dateGroupItem/@minute")
  let second = parse_optional_int(element, "second", "dateGroupItem/@second")
  let date_time_grouping = parse_date_time_grouping(
    attr_or(element, "dateTimeGrouping", "year"),
  )
  { year, month, day, hour, minute, second, date_time_grouping }
}

///|
fn rule_visible(
  rule : @domain.CT_FilterColumn_Choice?,
  column_id : Int,
  value : @formula.FormulaValue,
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime?,
  format_context : FilterFormatContext?,
) -> Bool {
  match rule {
    None => true
    Some(choice) =>
      match choice {
        @domain.CT_FilterColumn_Choice::Filters(filters) =>
          filters_pass(value, filters, date_system)
        CustomFilters(custom) => custom_filters_pass(value, custom, date_system)
        DynamicFilter({ kind: AboveAverage, .. }) => true
        DynamicFilter({ kind: BelowAverage, .. }) => true
        DynamicFilter(dynamic) =>
          dynamic_filter_pass(value, dynamic, date_system, today)
        ColorFilter(_) | IconFilter(_) =>
          match format_context {
            Some(ctx) =>
              formatted_filter_matches(
                ctx.row,
                ctx.dxf_formats,
                column_id,
                choice,
              )
            None => false
          }
        Top10(_) => true
      }
  }
}

///|
fn filters_pass(
  value : @formula.FormulaValue,
  filters : @domain.CT_Filters,
  date_system : @date_serial.DateSystem,
) -> Bool {
  if formula_is_blank(value) {
    return filters.blank
  }
  let text = formula_to_text(value)
  for literal in filters.filters {
    if text == literal.val {
      return true
    }
  }
  for group in filters.date_group_items {
    if calendar_type_uses_gregorian_fields(filters.calendar_type) &&
      date_group_matches(value, group, date_system) {
      return true
    }
  }
  false
}

///|
fn calendar_type_uses_gregorian_fields(calendar_type : String) -> Bool {
  try @simple_types.ST_CalendarType::new(calendar_type) catch {
    @simple_types.SchemaViolation(_) => false
  } noraise {
    calendar => calendar.uses_gregorian_fields()
  }
}

///|
fn custom_filters_pass(
  value : @formula.FormulaValue,
  custom : @domain.CT_CustomFilters,
  date_system : @date_serial.DateSystem,
) -> Bool {
  if custom.criteria.length() == 0 {
    return true
  }
  let mut passed = custom.and_op
  for criterion in custom.criteria {
    let current = custom_criterion_pass(value, criterion, date_system)
    if custom.and_op {
      passed = passed && current
    } else {
      passed = passed || current
    }
  }
  passed
}

///|
fn custom_criterion_pass(
  value : @formula.FormulaValue,
  criterion : @domain.CT_CustomFilter,
  date_system : @date_serial.DateSystem,
) -> Bool {
  let lhs_number = formula_to_number(value, date_system)
  let rhs_number = parse_double(criterion.val)
  if lhs_number is Some(left) && rhs_number is Some(right) {
    return compare_double(left, right, criterion.operator)
  }
  let left = formula_to_text(value)
  let right = criterion.val
  if right.contains_char('*') || right.contains_char('?') {
    let matched = wildcard_match(left, right)
    match criterion.operator {
      Equal => matched
      NotEqual => !matched
      _ => compare_string(left, right, criterion.operator)
    }
  } else {
    compare_string(left, right, criterion.operator)
  }
}

///|
fn dynamic_filter_pass(
  value : @formula.FormulaValue,
  dynamic : @domain.CT_DynamicFilter,
  date_system : @date_serial.DateSystem,
  today : @date_serial.CalendarDateTime?,
) -> Bool {
  if dynamic.val is Some(min_value) && dynamic.max_val is Some(max_value) {
    return formula_to_number(value, date_system) is Some(n) &&
      n >= min_value &&
      n < max_value
  }
  match dynamic_interval(dynamic.kind, date_system, today) {
    Some((start, end)) =>
      match formula_to_number(value, date_system) {
        Some(n) => n >= start && n < end
        None => false
      }
    None => false
  }
}

///|
fn average_passes(
  rows : Array[CandidateRow],
  column_id : Int,
  value : @formula.FormulaValue,
  date_system : @date_serial.DateSystem,
  above : Bool,
) -> Bool {
  let values = Array::new()
  for row in rows {
    let cell = row.values
      .get(column_id)
      .unwrap_or(@formula.FormulaValue::VEmpty)
    match formula_to_number(cell, date_system) {
      Some(n) => values.push(n)
      None => ()
    }
  }
  if values.length() == 0 {
    return false
  }
  let mut total = 0.0
  for n in values {
    total += n
  }
  match formula_to_number(value, date_system) {
    Some(n) =>
      if above {
        n > total / values.length().to_double()
      } else {
        n < total / values.length().to_double()
      }
    None => false
  }
}

///|
fn top10_passes(
  rows : Array[CandidateRow],
  column_id : Int,
  value : @formula.FormulaValue,
  date_system : @date_serial.DateSystem,
  top10 : @domain.CT_Top10,
) -> Bool {
  let candidate = match formula_to_number(value, date_system) {
    Some(n) => n
    None => return false
  }
  let threshold = match top10.filter_val {
    Some(n) => Some(n)
    None => top10_threshold_from_rows(rows, column_id, date_system, top10)
  }
  match threshold {
    Some(n) => if top10.top { candidate >= n } else { candidate <= n }
    None => false
  }
}

///|
fn top10_threshold_from_rows(
  rows : Array[CandidateRow],
  column_id : Int,
  date_system : @date_serial.DateSystem,
  top10 : @domain.CT_Top10,
) -> Double? {
  let numbers = Array::new()
  for row in rows {
    let cell = row.values
      .get(column_id)
      .unwrap_or(@formula.FormulaValue::VEmpty)
    match formula_to_number(cell, date_system) {
      Some(n) => numbers.push(n)
      None => ()
    }
  }
  if numbers.length() == 0 {
    return None
  }
  let sorted = sorted_numbers(numbers)
  let requested = if top10.percent {
    (numbers.length().to_double() * top10.val / 100.0).ceil().to_int()
  } else {
    top10.val.floor().to_int()
  }
  let count = clamp_int(requested, 1, numbers.length())
  let threshold = if top10.top {
    sorted[sorted.length() - count]
  } else {
    sorted[count - 1]
  }
  Some(threshold)
}

///|
fn date_group_matches(
  value : @formula.FormulaValue,
  group : @domain.CT_DateGroupItem,
  date_system : @date_serial.DateSystem,
) -> Bool {
  let serial = match formula_to_number(value, date_system) {
    Some(n) => n
    None => return false
  }
  let dt = @date_serial.serial_to_date_time(serial, date_system) catch {
    _ => return false
  }
  match group.date_time_grouping {
    Year => dt.year == group.year
    Month => dt.year == group.year && group.month == Some(dt.month)
    Day =>
      dt.year == group.year &&
      group.month == Some(dt.month) &&
      group.day == Some(dt.day)
    Hour =>
      dt.year == group.year &&
      group.month == Some(dt.month) &&
      group.day == Some(dt.day) &&
      group.hour == Some(dt.hour)
    Minute =>
      dt.year == group.year &&
      group.month == Some(dt.month) &&
      group.day == Some(dt.day) &&
      group.hour == Some(dt.hour) &&
      group.minute == Some(dt.minute)
    Second =>
      dt.year == group.year &&
      group.month == Some(dt.month) &&
      group.day == Some(dt.day) &&
      group.hour == Some(dt.hour) &&
      group.minute == Some(dt.minute) &&
      group.second == Some(dt.second)
  }
}

///|
fn dynamic_interval(
  kind : @domain.ST_DynamicFilterType,
  date_system : @date_serial.DateSystem,
  today_anchor : @date_serial.CalendarDateTime?,
) -> (Double, Double)? {
  let today = match today_anchor {
    Some(value) => value
    None =>
      @date_serial.serial_to_date_time(0.0, date_system) catch {
        _ => return None
      }
  }
  let today_start = serial_for_date(
    today.year,
    today.month,
    today.day,
    date_system,
  )
  match kind {
    Null => None
    Today => Some((today_start, today_start + 1.0))
    Yesterday => Some((today_start - 1.0, today_start))
    Tomorrow => Some((today_start + 1.0, today_start + 2.0))
    LastWeek => week_interval(today_start - 7.0)
    ThisWeek => week_interval(today_start)
    NextWeek => week_interval(today_start + 7.0)
    LastMonth => month_interval(today.year, today.month - 1, date_system)
    ThisMonth => month_interval(today.year, today.month, date_system)
    NextMonth => month_interval(today.year, today.month + 1, date_system)
    LastQuarter =>
      quarter_interval(
        today.year,
        quarter_of_month(today.month) - 1,
        date_system,
      )
    ThisQuarter =>
      quarter_interval(today.year, quarter_of_month(today.month), date_system)
    NextQuarter =>
      quarter_interval(
        today.year,
        quarter_of_month(today.month) + 1,
        date_system,
      )
    LastYear => year_interval(today.year - 1, date_system)
    ThisYear => year_interval(today.year, date_system)
    NextYear => year_interval(today.year + 1, date_system)
    YearToDate =>
      Some((serial_for_date(today.year, 1, 1, date_system), today_start + 1.0))
    Q1 => quarter_interval(today.year, 1, date_system)
    Q2 => quarter_interval(today.year, 2, date_system)
    Q3 => quarter_interval(today.year, 3, date_system)
    Q4 => quarter_interval(today.year, 4, date_system)
    M1 => month_interval(today.year, 1, date_system)
    M2 => month_interval(today.year, 2, date_system)
    M3 => month_interval(today.year, 3, date_system)
    M4 => month_interval(today.year, 4, date_system)
    M5 => month_interval(today.year, 5, date_system)
    M6 => month_interval(today.year, 6, date_system)
    M7 => month_interval(today.year, 7, date_system)
    M8 => month_interval(today.year, 8, date_system)
    M9 => month_interval(today.year, 9, date_system)
    M10 => month_interval(today.year, 10, date_system)
    M11 => month_interval(today.year, 11, date_system)
    M12 => month_interval(today.year, 12, date_system)
    AboveAverage => None
    BelowAverage => None
  }
}

///|
fn week_interval(day_serial : Double) -> (Double, Double)? {
  let start = (day_serial / 7.0).floor() * 7.0
  Some((start, start + 7.0))
}

///|
fn month_interval(
  year : Int,
  month : Int,
  date_system : @date_serial.DateSystem,
) -> (Double, Double)? {
  let normalized_year = year + floor_div(month - 1, 12)
  let normalized_month = modulo(month - 1, 12) + 1
  Some(
    (
      serial_for_date(normalized_year, normalized_month, 1, date_system),
      serial_for_date(
        normalized_year + (if normalized_month == 12 { 1 } else { 0 }),
        if normalized_month == 12 {
          1
        } else {
          normalized_month + 1
        },
        1,
        date_system,
      ),
    ),
  )
}

///|
fn quarter_interval(
  year : Int,
  quarter : Int,
  date_system : @date_serial.DateSystem,
) -> (Double, Double)? {
  let normalized_year = year + floor_div(quarter - 1, 4)
  let normalized_quarter = modulo(quarter - 1, 4) + 1
  let start_month = (normalized_quarter - 1) * 3 + 1
  Some(
    (
      serial_for_date(normalized_year, start_month, 1, date_system),
      serial_for_date(
        normalized_year + (if start_month == 10 { 1 } else { 0 }),
        if start_month == 10 {
          1
        } else {
          start_month + 3
        },
        1,
        date_system,
      ),
    ),
  )
}

///|
fn year_interval(
  year : Int,
  date_system : @date_serial.DateSystem,
) -> (Double, Double)? {
  Some(
    (
      serial_for_date(year, 1, 1, date_system),
      serial_for_date(year + 1, 1, 1, date_system),
    ),
  )
}

///|
fn serial_for_date(
  year : Int,
  month : Int,
  day : Int,
  date_system : @date_serial.DateSystem,
) -> Double {
  @date_serial.date_time_to_serial(
    { year, month, day, hour: 0, minute: 0, second: 0, millisecond: 0 },
    date_system,
  ) catch {
    _ => 0.0
  }
}

///|
fn canonical_filter_color(value : String) -> String {
  let lower = value.trim().to_owned().to_lower()
  let stripped = if lower.has_prefix("#") {
    lower[1:].to_owned()
  } else {
    lower
  }
  let rgb = if stripped.length() == 8 && is_ascii_hex(stripped) {
    stripped[2:].to_owned()
  } else {
    stripped
  }
  if rgb.length() == 6 && is_ascii_hex(rgb) {
    "#" + rgb
  } else {
    rgb
  }
}

///|
fn is_ascii_hex(value : String) -> Bool {
  for ch in value {
    let code = ch.to_int()
    if !((code >= 0x30 && code <= 0x39) || (code >= 0x61 && code <= 0x66)) {
      return false
    }
  }
  true
}

///|
fn formula_to_cell_value(
  value : @formula.FormulaValue,
) -> @cell_value.CellValue {
  match value {
    @formula.FormulaValue::VNumber(n) => @cell_value.CellValue::Number(n)
    VString(s) => @cell_value.CellValue::FormulaString(s)
    VBool(b) => @cell_value.CellValue::Boolean(b)
    VEmpty => @cell_value.CellValue::Empty
    VError(err) => @cell_value.CellValue::Error(err.to_literal())
    VArray(rows) =>
      match rows.get(0) {
        Some(row) =>
          match row.get(0) {
            Some(cell) => formula_to_cell_value(cell)
            None => @cell_value.CellValue::Empty
          }
        None => @cell_value.CellValue::Empty
      }
  }
}

///|
fn formula_to_text(value : @formula.FormulaValue) -> String {
  formula_to_cell_value(value).to_display_text()
}

///|
fn formula_to_number(
  value : @formula.FormulaValue,
  date_system : @date_serial.DateSystem,
) -> Double? {
  let number = formula_to_cell_value(value).to_number(date_system) catch {
    _ => return None
  }
  Some(number)
}

///|
fn formula_is_blank(value : @formula.FormulaValue) -> Bool {
  match value {
    @formula.FormulaValue::VEmpty => true
    VString(s) => s == ""
    VArray(rows) =>
      match rows.get(0) {
        Some(row) =>
          match row.get(0) {
            Some(cell) => formula_is_blank(cell)
            None => true
          }
        None => true
      }
    _ => false
  }
}

///|
fn compare_double(
  left : Double,
  right : Double,
  op : @domain.ST_FilterOperator,
) -> Bool {
  match op {
    Equal => left == right
    NotEqual => left != right
    GreaterThan => left > right
    GreaterThanOrEqual => left >= right
    LessThan => left < right
    LessThanOrEqual => left <= right
  }
}

///|
fn compare_string(
  left : String,
  right : String,
  op : @domain.ST_FilterOperator,
) -> Bool {
  match op {
    Equal => left == right
    NotEqual => left != right
    GreaterThan => left > right
    GreaterThanOrEqual => left >= right
    LessThan => left < right
    LessThanOrEqual => left <= right
  }
}

///|
fn wildcard_match(text : String, pattern : String) -> Bool {
  wildcard_match_at(text, 0, pattern, 0)
}

///|
fn wildcard_match_at(
  text : String,
  ti : Int,
  pattern : String,
  pi : Int,
) -> Bool {
  if pi == pattern.length() {
    return ti == text.length()
  }
  if pattern.code_unit_at(pi) == '*' {
    let mut scan = ti
    while scan <= text.length() {
      if wildcard_match_at(text, scan, pattern, pi + 1) {
        return true
      }
      scan += 1
    }
    return false
  }
  ti < text.length() &&
  (
    pattern.code_unit_at(pi) == '?' ||
    pattern.code_unit_at(pi) == text.code_unit_at(ti)
  ) &&
  wildcard_match_at(text, ti + 1, pattern, pi + 1)
}

///|
fn sorted_numbers(values : Array[Double]) -> Array[Double] {
  let out = values.copy()
  for i in 1..<out.length() {
    let key = out[i]
    let mut j = i
    while j > 0 && out[j - 1] > key {
      out[j] = out[j - 1]
      j -= 1
    }
    out[j] = key
  }
  out
}

///|
fn parse_filter_operator(
  value : String,
) -> @domain.ST_FilterOperator raise @opc_errors.SchemaViolation {
  match value {
    "equal" => Equal
    "notEqual" => NotEqual
    "greaterThan" => GreaterThan
    "greaterThanOrEqual" => GreaterThanOrEqual
    "lessThan" => LessThan
    "lessThanOrEqual" => LessThanOrEqual
    _ =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.18.31",
        path="customFilter/@operator",
        reason="unknown ST_FilterOperator value",
      )
  }
}

///|
fn parse_dynamic_filter_type(
  value : String,
) -> @domain.ST_DynamicFilterType raise @opc_errors.SchemaViolation {
  match value {
    "null" => Null
    "today" => Today
    "yesterday" => Yesterday
    "tomorrow" => Tomorrow
    "lastWeek" => LastWeek
    "thisWeek" => ThisWeek
    "nextWeek" => NextWeek
    "lastMonth" => LastMonth
    "thisMonth" => ThisMonth
    "nextMonth" => NextMonth
    "lastQuarter" => LastQuarter
    "thisQuarter" => ThisQuarter
    "nextQuarter" => NextQuarter
    "lastYear" => LastYear
    "thisYear" => ThisYear
    "nextYear" => NextYear
    "yearToDate" => YearToDate
    "Q1" => Q1
    "Q2" => Q2
    "Q3" => Q3
    "Q4" => Q4
    "M1" => M1
    "M2" => M2
    "M3" => M3
    "M4" => M4
    "M5" => M5
    "M6" => M6
    "M7" => M7
    "M8" => M8
    "M9" => M9
    "M10" => M10
    "M11" => M11
    "M12" => M12
    "aboveAverage" => AboveAverage
    "belowAverage" => BelowAverage
    _ =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.18.26",
        path="dynamicFilter/@type",
        reason="unknown ST_DynamicFilterType value",
      )
  }
}

///|
fn parse_date_time_grouping(
  value : String,
) -> @domain.ST_DateTimeGrouping raise @opc_errors.SchemaViolation {
  match value {
    "year" => Year
    "month" => Month
    "day" => Day
    "hour" => Hour
    "minute" => Minute
    "second" => Second
    _ =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.18.22",
        path="dateGroupItem/@dateTimeGrouping",
        reason="unknown ST_DateTimeGrouping value",
      )
  }
}

///|
fn parse_calendar_type_attr(
  value : String,
  path : String,
) -> String raise @opc_errors.SchemaViolation {
  try @simple_types.ST_CalendarType::new(value) catch {
    @simple_types.SchemaViolation(_) =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §22.9.2.4",
        path~,
        reason="unknown ST_CalendarType value",
      )
  } noraise {
    calendar => calendar.to_string()
  }
}

///|
fn attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
fn attr_or(
  element : @xml.Element,
  local_name : String,
  fallback : String,
) -> String {
  attr(element, local_name).unwrap_or(fallback)
}

///|
fn require_attr(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.2",
        path~,
        reason="required attribute is missing",
      )
  }
}

///|
fn parse_bool_attr(
  element : @xml.Element,
  local_name : String,
  fallback : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some("1") | Some("true") => true
    Some("0") | Some("false") => false
    Some(value) =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.2",
        path=element.name.local_name + "/@" + local_name,
        reason="xsd:boolean value is malformed: " + value,
      )
    None => fallback
  }
}

///|
fn parse_required_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  match parse_int(require_attr(element, local_name, path)) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.2",
        path~,
        reason="integer attribute is malformed",
      )
  }
}

///|
fn parse_optional_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_int(value) {
        Some(parsed) => Some(parsed)
        None =>
          raise @opc_errors.SchemaViolation(
            section="Part 1 §18.3.2",
            path~,
            reason="integer attribute is malformed",
          )
      }
    None => None
  }
}

///|
fn parse_required_double(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Double raise @opc_errors.SchemaViolation {
  match parse_double(require_attr(element, local_name, path)) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.2",
        path~,
        reason="double attribute is malformed",
      )
  }
}

///|
fn parse_optional_double(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Double? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_double(value) {
        Some(parsed) => Some(parsed)
        None =>
          raise @opc_errors.SchemaViolation(
            section="Part 1 §18.3.2",
            path~,
            reason="double attribute is malformed",
          )
      }
    None => None
  }
}

///|
fn parse_int(value : String) -> Int? {
  if value.length() == 0 {
    return None
  }
  let mut sign = 1
  let mut pos = 0
  if value.code_unit_at(0) == '-' {
    sign = -1
    pos = 1
  }
  if pos == value.length() {
    return None
  }
  let mut out = 0
  while pos < value.length() {
    let ch = value.code_unit_at(pos)
    if ch < '0' || ch > '9' {
      return None
    }
    out = out * 10 + (ch.to_int() - '0'.to_int())
    pos += 1
  }
  Some(out * sign)
}

///|
fn parse_double(value : String) -> Double? {
  if value.length() == 0 {
    return None
  }
  let mut sign = 1.0
  let mut pos = 0
  if value.code_unit_at(0) == '-' {
    sign = -1.0
    pos = 1
  } else if value.code_unit_at(0) == '+' {
    pos = 1
  }
  let mut whole = 0.0
  let mut seen_digit = false
  while pos < value.length() &&
        value.code_unit_at(pos) >= '0' &&
        value.code_unit_at(pos) <= '9' {
    seen_digit = true
    whole = whole * 10.0 +
      (value.code_unit_at(pos).to_int() - '0'.to_int()).to_double()
    pos += 1
  }
  let mut fraction = 0.0
  let mut place = 0.1
  if pos < value.length() && value.code_unit_at(pos) == '.' {
    pos += 1
    while pos < value.length() &&
          value.code_unit_at(pos) >= '0' &&
          value.code_unit_at(pos) <= '9' {
      seen_digit = true
      fraction += (value.code_unit_at(pos).to_int() - '0'.to_int()).to_double() *
        place
      place *= 0.1
      pos += 1
    }
  }
  if !seen_digit || pos != value.length() {
    None
  } else {
    Some(sign * (whole + fraction))
  }
}

///|
fn floor_div(value : Int, divisor : Int) -> Int {
  let q = value / divisor
  let r = value % divisor
  if r != 0 && (r < 0) != (divisor < 0) {
    q - 1
  } else {
    q
  }
}

///|
fn modulo(value : Int, divisor : Int) -> Int {
  let r = value % divisor
  if r < 0 {
    r + divisor
  } else {
    r
  }
}

///|
fn quarter_of_month(month : Int) -> Int {
  (month - 1) / 3 + 1
}

///|
fn clamp_int(value : Int, min : Int, max : Int) -> Int {
  if value < min {
    min
  } else if value > max {
    max
  } else {
    value
  }
}
