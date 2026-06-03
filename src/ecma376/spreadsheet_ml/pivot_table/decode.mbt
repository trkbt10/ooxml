///|
/// Part 1 §18.10.1.67 pivotCacheDefinition — decode the typed
/// CT_PivotCacheDefinition wrapper into a `PivotCacheDefinition`.
/// All refresh-metadata attributes are optional in the spec; only
/// `cacheSource` and `cacheFields` children are normally required
/// (the schema allows them to be absent but real workbooks always
/// emit them — we treat absence as an empty list rather than
/// raising).
pub fn decode_pivot_cache_definition(
  definition : @domain.CT_PivotCacheDefinition,
) -> PivotCacheDefinition raise @opc_errors.SchemaViolation {
  let element = definition.element
  let refreshed_by = attr(element, "refreshedBy")
  let refreshed_date_iso = attr(element, "refreshedDateIso")
  let record_count = decode_optional_int(
    element, "recordCount", "pivotCacheDefinition/@recordCount",
  )
  let created_version = decode_optional_int(
    element, "createdVersion", "pivotCacheDefinition/@createdVersion",
  )
  let refreshed_version = decode_optional_int(
    element, "refreshedVersion", "pivotCacheDefinition/@refreshedVersion",
  )
  let min_refreshable_version = decode_optional_int(
    element, "minRefreshableVersion", "pivotCacheDefinition/@minRefreshableVersion",
  )
  let save_data = decode_bool_attr(element, "saveData", true)
  let invalid = decode_bool_attr(element, "invalid", false)
  let refresh_on_load = decode_bool_attr(element, "refreshOnLoad", false)
  let mut cache_source : CacheSource? = None
  let cache_fields : Array[CacheField] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let name = child_element.name.local_name
        if name == "cacheSource" {
          cache_source = Some(decode_cache_source(child_element))
        } else if name == "cacheFields" {
          for inner in child_element.children {
            match inner {
              @xml.Element(field_element) =>
                if field_element.name.local_name == "cacheField" {
                  cache_fields.push(decode_cache_field(field_element))
                }
              _ => ()
            }
          }
        }
      }
      _ => ()
    }
  }
  let resolved_source = match cache_source {
    Some(source) => source
    None =>
      raise @opc_errors.SchemaViolation(
        section=pivot_cache_definition_part1_18_10_1_67_section_name(),
        path="pivotCacheDefinition/cacheSource",
        reason="pivotCacheDefinition requires a cacheSource child",
      )
  }
  {
    cache_source: resolved_source,
    cache_fields,
    refreshed_by,
    refreshed_date_iso,
    record_count,
    created_version,
    refreshed_version,
    min_refreshable_version,
    save_data,
    invalid,
    refresh_on_load,
  }
}

///|
/// Part 1 §18.10.1.7 cacheSource — decode the @type discriminator
/// and the embedded worksheetSource child when present. The schema
/// allows additional children for the consolidation and tupleCache
/// variants; Phase 1 ignores them and leaves them for renderers to
/// inspect on the raw @xml.Element.
fn decode_cache_source(
  element : @xml.Element,
) -> CacheSource raise @opc_errors.SchemaViolation {
  let source_type = attr_or(element, "type", "worksheet")
  let connection_id = decode_optional_int(
    element, "connectionId", "cacheSource/@connectionId",
  )
  let mut worksheet_source : WorksheetSource? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "worksheetSource" {
          worksheet_source = Some(decode_worksheet_source(child_element))
        }
      _ => ()
    }
  }
  { source_type, connection_id, worksheet_source }
}

///|
/// Part 1 §18.10.1.95 worksheetSource — decode the four optional
/// attributes. `@ref`, when present, is parsed via `@address` so
/// out-of-range syntax surfaces as a SchemaViolation immediately.
fn decode_worksheet_source(
  element : @xml.Element,
) -> WorksheetSource raise @opc_errors.SchemaViolation {
  let sheet = attr(element, "sheet")
  let name = attr(element, "name")
  let ref_range = match attr(element, "ref") {
    Some(text) => Some(@address.CellRange::parse_a1(text))
    None => None
  }
  let relationship_id = attr(element, "id")
  { sheet, name, ref_range, relationship_id }
}

///|
/// Part 1 §18.10.1.3 cacheField — decode the typed
/// `CacheField` view: name, caption, numFmtId, databaseField,
/// formula, plus the optional sharedItems child. When the
/// sharedItems element is absent the decoder produces an empty
/// `SharedItems` so callers do not have to test for `None`.
fn decode_cache_field(
  element : @xml.Element,
) -> CacheField raise @opc_errors.SchemaViolation {
  let name = require_attr(element, "name", "cacheField/@name")
  let caption = attr(element, "caption")
  let num_fmt_id = decode_optional_int(
    element, "numFmtId", "cacheField/@numFmtId",
  )
  let database_field = decode_bool_attr(element, "databaseField", true)
  let formula = attr(element, "formula")
  let mut shared_items : SharedItems? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "sharedItems" {
          shared_items = Some(decode_shared_items(child_element))
        }
      _ => ()
    }
  }
  let resolved = match shared_items {
    Some(items) => items
    None => empty_shared_items()
  }
  { name, caption, num_fmt_id, database_field, formula, shared_items: resolved }
}

///|
/// Empty sharedItems placeholder used when the source XML omits
/// the element. All type-witness booleans default to false, both
/// numeric / date bounds default to None, and the items list is
/// empty.
fn empty_shared_items() -> SharedItems {
  {
    items: [],
    contains_blank: false,
    contains_date: false,
    contains_integer: false,
    contains_mixed_types: false,
    contains_non_date: false,
    contains_number: false,
    contains_semi_mixed_types: false,
    contains_string: false,
    long_text: false,
    min_value: None,
    max_value: None,
    min_date: None,
    max_date: None,
  }
}

///|
/// Part 1 §18.10.1.90 sharedItems — decode the per-field shared
/// values table. Every value-child (`<s>`, `<n>`, `<d>`, `<b>`,
/// `<e>`, `<m>`) is decoded in document order; the
/// type-witness booleans (`containsString`, `containsNumber`,
/// `containsBlank`, …) and the numeric / date bounds attributes
/// are pulled out of the element's attribute list.
fn decode_shared_items(
  element : @xml.Element,
) -> SharedItems raise @opc_errors.SchemaViolation {
  let contains_blank = decode_bool_attr(element, "containsBlank", false)
  let contains_date = decode_bool_attr(element, "containsDate", false)
  let contains_integer = decode_bool_attr(element, "containsInteger", false)
  let contains_mixed_types = decode_bool_attr(
    element, "containsMixedTypes", false,
  )
  let contains_non_date = decode_bool_attr(element, "containsNonDate", true)
  let contains_number = decode_bool_attr(element, "containsNumber", false)
  let contains_semi_mixed_types = decode_bool_attr(
    element, "containsSemiMixedTypes", true,
  )
  let contains_string = decode_bool_attr(element, "containsString", true)
  let long_text = decode_bool_attr(element, "longText", false)
  let min_value = decode_optional_double(
    element, "minValue", "sharedItems/@minValue",
  )
  let max_value = decode_optional_double(
    element, "maxValue", "sharedItems/@maxValue",
  )
  let min_date = attr(element, "minDate")
  let max_date = attr(element, "maxDate")
  let items : Array[SharedItemValue] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        match decode_shared_item_value_opt(child_element) {
          Some(value) => items.push(value)
          None => ()
        }
      _ => ()
    }
  }
  {
    items,
    contains_blank,
    contains_date,
    contains_integer,
    contains_mixed_types,
    contains_non_date,
    contains_number,
    contains_semi_mixed_types,
    contains_string,
    long_text,
    min_value,
    max_value,
    min_date,
    max_date,
  }
}

///|
/// Part 1 §18.10.1.{60,21,2,27,50} — decode one of the six
/// pivotcache value forms (`<n>`, `<d>`, `<b>`, `<e>`, `<m>`) plus
/// the implicit `<s>` form. Returns `None` for unknown element
/// names so the caller can simply skip non-value children.
fn decode_shared_item_value_opt(
  element : @xml.Element,
) -> SharedItemValue? raise @opc_errors.SchemaViolation {
  let name = element.name.local_name
  match name {
    "s" => Some(SharedString(attr_or(element, "v", "")))
    "n" => Some(SharedNumber(decode_required_double(element, "v", "n/@v")))
    "b" => {
      let value = match attr(element, "v") {
        Some(raw) => parse_bool_text(raw, "b/@v")
        None => false
      }
      Some(SharedBool(value))
    }
    "d" => Some(SharedDate(attr_or(element, "v", "")))
    "e" => Some(SharedError(attr_or(element, "v", "#VALUE!")))
    "m" => Some(SharedMissing)
    _ => None
  }
}

///|
/// Public-ish helper for callers that already have a pivotcache
/// value element in hand (e.g. an inline `<n>` inside a `<r>` row).
/// Raises SchemaViolation when the element is not one of the six
/// known forms.
fn decode_shared_item_value(
  element : @xml.Element,
) -> SharedItemValue raise @opc_errors.SchemaViolation {
  match decode_shared_item_value_opt(element) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.10.1",
        path="record/" + element.name.local_name,
        reason="unknown pivot cache value element: " + element.name.local_name,
      )
  }
}

///|
/// Part 1 §18.10.1.68 pivotCacheRecords — decode the `<r>` rows
/// into a typed `PivotCacheRecords`. Calculated cache fields
/// (§18.10.1.3 `@formula`) are not stored per record, so rows that
/// omit those cells are expanded here into cache-field order with a
/// missing placeholder at each calculated-field position. Downstream
/// materialization then has one canonical row shape.
pub fn decode_pivot_cache_records(
  records : @domain.CT_PivotCacheRecords,
  cache_fields : Array[CacheField],
) -> PivotCacheRecords raise @opc_errors.SchemaViolation {
  let element = records.element
  let count = decode_optional_int(element, "count", "pivotCacheRecords/@count")
  let rows : Array[PivotCacheRow] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "r" {
          let raw_cells = decode_pivot_cache_row(child_element)
          let cells = align_pivot_cache_row(raw_cells, cache_fields)
          rows.push({ cells, })
        }
      _ => ()
    }
  }
  { count, rows }
}

///|
fn align_pivot_cache_row(
  raw_cells : Array[PivotRecordCell],
  cache_fields : Array[CacheField],
) -> Array[PivotRecordCell] raise @opc_errors.SchemaViolation {
  let expected = cache_fields.length()
  if expected == 0 || raw_cells.length() == expected {
    return raw_cells
  }
  let mut stored_field_count = 0
  for field in cache_fields {
    if !cache_field_is_calculated(field) {
      stored_field_count += 1
    }
  }
  if raw_cells.length() == stored_field_count {
    let cells : Array[PivotRecordCell] = []
    let mut raw_index = 0
    for field in cache_fields {
      if cache_field_is_calculated(field) {
        cells.push(Inline(SharedMissing))
      } else {
        cells.push(raw_cells[raw_index])
        raw_index += 1
      }
    }
    return cells
  }
  raise @opc_errors.SchemaViolation(
    section=pivot_cache_records_part1_18_10_1_68_section_name(),
    path="pivotCacheRecords/r",
    reason="row width " +
      raw_cells.length().to_string() +
      " does not match cacheFields count " +
      expected.to_string() +
      " or stored database-field count " +
      stored_field_count.to_string(),
  )
}

///|
/// Decode a single `<r>` row: walk its children in order and
/// produce one `PivotRecordCell` per child element. `<x>` becomes
/// a `RefShared` index; the other six forms become an `Inline`
/// value.
fn decode_pivot_cache_row(
  element : @xml.Element,
) -> Array[PivotRecordCell] raise @opc_errors.SchemaViolation {
  let cells : Array[PivotRecordCell] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let name = child_element.name.local_name
        if name == "x" {
          let value = decode_optional_int(child_element, "v", "r/x/@v").unwrap_or(
            0,
          )
          cells.push(RefShared(value))
        } else {
          let value = decode_shared_item_value(child_element)
          cells.push(Inline(value))
        }
      }
      _ => ()
    }
  }
  cells
}

///|
/// Resolve a `PivotRecordCell` to its `@formula.FormulaValue`.
/// `RefShared(i)` indexes into `field.shared_items.items`; an
/// out-of-range index raises SchemaViolation with the field name
/// so the caller can report which column was malformed.
pub fn pivot_record_cell_to_formula_value(
  cell : PivotRecordCell,
  field : CacheField,
) -> @formula.FormulaValue raise @opc_errors.SchemaViolation {
  match cell {
    Inline(value) => value.to_formula_value()
    RefShared(index) => {
      let mut current = 0
      for item in field.shared_items.items {
        if current == index {
          return item.to_formula_value()
        }
        current = current + 1
      }
      raise @opc_errors.SchemaViolation(
        section=pivot_cache_records_part1_18_10_1_68_section_name(),
        path="pivotCacheRecords/r/x[field=" + field.name + "]",
        reason="shared item index " +
          index.to_string() +
          " is out of range (field has " +
          current.to_string() +
          " items)",
      )
    }
  }
}

///|
/// Resolve a `PivotRecordCell` to the shared item index it
/// references, if any. Used by the page-field filter to decide
/// whether a row matches a `pageField/@item` selection without
/// projecting the value back through `to_formula_value`.
pub fn pivot_record_cell_shared_index(cell : PivotRecordCell) -> Int? {
  match cell {
    RefShared(index) => Some(index)
    Inline(_) => None
  }
}

///|
/// Part 1 §18.10.1.73 pivotTableDefinition — decode the typed
/// CT_pivotTableDefinition wrapper. The decoder walks the
/// well-known children (`location`, `pivotFields`, `rowFields`,
/// `rowItems`, `colFields`, `colItems`, `pageFields`,
/// `dataFields`) in order; the already-typed domain `filters`
/// child supplies advanced PivotTable filters, avoiding a second XML
/// traversal for that subtree. Unknown children are ignored so future
/// schema additions do not break the parser.
pub fn decode_pivot_table_definition(
  definition : @domain.CT_pivotTableDefinition,
) -> PivotTableDefinition raise @opc_errors.SchemaViolation {
  let element = definition.element
  let name = require_attr(element, "name", "pivotTableDefinition/@name")
  let data_caption = attr(element, "dataCaption")
  let cache_id = decode_optional_int(
    element, "cacheId", "pivotTableDefinition/@cacheId",
  )
  let row_grand_totals = decode_bool_attr(element, "rowGrandTotals", true)
  let col_grand_totals = decode_bool_attr(element, "colGrandTotals", true)
  let data_on_rows = decode_bool_attr(element, "dataOnRows", false)
  let mut location : PivotLocation? = None
  let pivot_fields : Array[PivotFieldDef] = []
  let row_fields : Array[Int] = []
  let col_fields : Array[Int] = []
  let row_items : Array[PivotAxisItem] = []
  let col_items : Array[PivotAxisItem] = []
  let page_fields : Array[PageFieldDef] = []
  let pivot_filters : Array[PivotFilterDef] = []
  let data_fields : Array[DataFieldDef] = []
  let mut style_info : PivotTableStyleInfo? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let lname = child_element.name.local_name
        if lname == "location" {
          location = Some(decode_location(child_element))
        } else if lname == "pivotFields" {
          for inner in child_element.children {
            match inner {
              @xml.Element(field_element) =>
                if field_element.name.local_name == "pivotField" {
                  pivot_fields.push(decode_pivot_field(field_element))
                }
              _ => ()
            }
          }
        } else if lname == "rowFields" {
          for index in decode_field_list(child_element) {
            row_fields.push(index)
          }
        } else if lname == "colFields" {
          for index in decode_field_list(child_element) {
            col_fields.push(index)
          }
        } else if lname == "rowItems" {
          for axis_item in decode_axis_items(child_element) {
            row_items.push(axis_item)
          }
        } else if lname == "colItems" {
          for axis_item in decode_axis_items(child_element) {
            col_items.push(axis_item)
          }
        } else if lname == "pageFields" {
          for inner in child_element.children {
            match inner {
              @xml.Element(page_element) =>
                if page_element.name.local_name == "pageField" {
                  page_fields.push(decode_page_field(page_element))
                }
              _ => ()
            }
          }
        } else if lname == "dataFields" {
          for inner in child_element.children {
            match inner {
              @xml.Element(data_element) =>
                if data_element.name.local_name == "dataField" {
                  data_fields.push(decode_data_field(data_element))
                }
              _ => ()
            }
          }
        } else if lname == "pivotTableStyleInfo" {
          // §18.10.1.74 — name + band / header toggles.
          style_info = Some({
            name: attr(child_element, "name"),
            show_row_headers: decode_bool_attr(
              child_element, "showRowHeaders", false,
            ),
            show_col_headers: decode_bool_attr(
              child_element, "showColHeaders", false,
            ),
            show_row_stripes: decode_bool_attr(
              child_element, "showRowStripes", false,
            ),
            show_col_stripes: decode_bool_attr(
              child_element, "showColStripes", false,
            ),
            show_last_column: decode_bool_attr(
              child_element, "showLastColumn", false,
            ),
          })
        }
      }
      _ => ()
    }
  }
  match definition.filters {
    Some(filters) =>
      for filter in filters.filter {
        pivot_filters.push(decode_pivot_filter(filter))
      }
    None => ()
  }
  {
    name,
    data_caption,
    cache_id,
    row_grand_totals,
    col_grand_totals,
    data_on_rows,
    location,
    pivot_fields,
    row_fields,
    col_fields,
    row_items,
    col_items,
    page_fields,
    filters: pivot_filters,
    data_fields,
    style_info,
  }
}

///|
/// Part 1 §18.10.1.33 filter — decode the operational PivotTable
/// filter fields. The embedded AutoFilter child is parsed by the
/// AutoFilter package so comparison semantics have one source.
fn decode_pivot_filter(
  filter : @domain.CT_PivotFilter,
) -> PivotFilterDef raise @opc_errors.SchemaViolation {
  let auto_filter = match filter.auto_filter {
    Some(element) => @autofilter.parse_auto_filter(element)
    None =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.10.1.33",
        path="filter/autoFilter",
        reason="pivot filter requires an autoFilter child",
      )
  }
  {
    fld: filter.fld,
    mp_fld: filter.mp_fld,
    type_: filter.type_,
    eval_order: filter.eval_order,
    id: filter.id,
    i_measure_hier: filter.i_measure_hier,
    i_measure_fld: filter.i_measure_fld,
    name: filter.name,
    description: filter.description,
    string_value1: filter.string_value1,
    string_value2: filter.string_value2,
    auto_filter,
  }
}

///|
/// Part 1 §18.10.1.49 location — decode the rectangle plus the
/// four offset attributes. `@firstHeaderRow`, `@firstDataRow`,
/// `@firstDataCol` default to 0; `@rowPageCount` and
/// `@colPageCount` default to 0 as well.
fn decode_location(
  element : @xml.Element,
) -> PivotLocation raise @opc_errors.SchemaViolation {
  let ref_text = require_attr(element, "ref", "location/@ref")
  let ref_range = @address.CellRange::parse_a1(ref_text)
  let first_header_row = decode_optional_int(
    element, "firstHeaderRow", "location/@firstHeaderRow",
  ).unwrap_or(0)
  let first_data_row = decode_optional_int(
    element, "firstDataRow", "location/@firstDataRow",
  ).unwrap_or(0)
  let first_data_col = decode_optional_int(
    element, "firstDataCol", "location/@firstDataCol",
  ).unwrap_or(0)
  let row_page_count = decode_optional_int(
    element, "rowPageCount", "location/@rowPageCount",
  ).unwrap_or(0)
  let col_page_count = decode_optional_int(
    element, "colPageCount", "location/@colPageCount",
  ).unwrap_or(0)
  {
    ref_range,
    first_header_row,
    first_data_row,
    first_data_col,
    row_page_count,
    col_page_count,
  }
}

///|
/// Part 1 §18.10.1.69 pivotField — decode the field-level
/// attributes plus the inner `<items>` list. The `<items>` decode
/// is shallow: each `<item>` keeps its `@x`, `@t`, `@h`, `@s`,
/// `@n` for the renderer.
fn decode_pivot_field(
  element : @xml.Element,
) -> PivotFieldDef raise @opc_errors.SchemaViolation {
  let axis = match attr(element, "axis") {
    Some(text) => Some(PivotAxis::from_attr(text))
    None => None
  }
  let data_field = decode_bool_attr(element, "dataField", false)
  let include_new_items_in_filter = decode_bool_attr(
    element, "includeNewItemsInFilter", false,
  )
  let name = attr(element, "name")
  let subtotal_caption = attr(element, "subtotalCaption")
  let outline = decode_bool_attr(element, "outline", true)
  let subtotal_top = decode_bool_attr(element, "subtotalTop", true)
  let default_subtotal = decode_bool_attr(element, "defaultSubtotal", true)
  let items : Array[PivotItemDef] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "items" {
          for inner in child_element.children {
            match inner {
              @xml.Element(item_element) =>
                if item_element.name.local_name == "item" {
                  items.push(decode_pivot_item(item_element))
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  {
    axis,
    data_field,
    include_new_items_in_filter,
    name,
    subtotal_caption,
    outline,
    subtotal_top,
    default_subtotal,
    items,
  }
}

///|
/// Part 1 §18.10.1.45 item — decode one item entry. `@x` is
/// optional (a subtotal marker carries `@t="default"` and no
/// `@x`); the boolean flags default per the spec.
fn decode_pivot_item(
  element : @xml.Element,
) -> PivotItemDef raise @opc_errors.SchemaViolation {
  let item_index = decode_optional_int(element, "x", "item/@x")
  let item_type = match attr(element, "t") {
    Some(text) => Some(ItemType::from_attr(text))
    None => None
  }
  let hidden = decode_bool_attr(element, "h", false)
  let caption = attr(element, "n")
  let character = decode_bool_attr(element, "s", false)
  { item_index, item_type, hidden, caption, character }
}

///|
/// Part 1 §18.10.1.22 dataField — decode the value-region field
/// definition. `@subtotal` defaults to `sum` per the spec note in
/// §18.10.1.22 + §18.18.17.
fn decode_data_field(
  element : @xml.Element,
) -> DataFieldDef raise @opc_errors.SchemaViolation {
  let name = attr(element, "name")
  let fld = decode_required_int(element, "fld", "dataField/@fld")
  let subtotal = match attr(element, "subtotal") {
    Some(text) => DataConsolidateFunction::from_attr(text)
    None => Sum
  }
  let base_field = decode_optional_int(
    element, "baseField", "dataField/@baseField",
  )
  let base_item = decode_optional_int(
    element, "baseItem", "dataField/@baseItem",
  )
  let num_fmt_id = decode_optional_int(
    element, "numFmtId", "dataField/@numFmtId",
  )
  let show_data_as = match attr(element, "showDataAs") {
    Some(text) =>
      Some(
        @sml_types.ST_ShowDataAs::parse(text) catch {
          @sml_types.SchemaViolation(schema~, path~, reason~) =>
            raise @opc_errors.SchemaViolation(
              section="Part 1 §18.10.1.22",
              path="dataField/@showDataAs",
              reason=schema + " " + path + ": " + reason,
            )
        },
      )
    None => None
  }
  { name, fld, subtotal, base_field, base_item, num_fmt_id, show_data_as }
}

///|
/// Part 1 §18.10.1.62 pageField — decode the report-filter field.
fn decode_page_field(
  element : @xml.Element,
) -> PageFieldDef raise @opc_errors.SchemaViolation {
  let fld = decode_required_int(element, "fld", "pageField/@fld")
  let item = decode_optional_int(element, "item", "pageField/@item")
  let hier = decode_optional_int(element, "hier", "pageField/@hier")
  let name = attr(element, "name")
  let caption = attr(element, "cap")
  { fld, item, hier, name, caption }
}

///|
/// Part 1 §18.10.1.14 / §18.10.1.83 — decode a `<rowFields>` or
/// `<colFields>` container into its list of cacheField indices,
/// in document order. Each `<field>` child carries an `@x` integer;
/// the sentinel `-2` (encoded `4294967294` in XSD unsignedInt) is
/// the data-field pseudo position and is preserved verbatim so
/// the materializer can skip it.
fn decode_field_list(
  element : @xml.Element,
) -> Array[Int] raise @opc_errors.SchemaViolation {
  let indices : Array[Int] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "field" {
          let x_text = require_attr(child_element, "x", "field/@x")
          let value = parse_signed_or_unsigned(x_text, "field/@x")
          indices.push(value)
        }
      _ => ()
    }
  }
  indices
}

///|
/// Part 1 §18.10.1.44 i — decode a `<rowItems>` or `<colItems>`
/// container. Each `<i>` element produces one `PivotAxisItem`.
fn decode_axis_items(
  element : @xml.Element,
) -> Array[PivotAxisItem] raise @opc_errors.SchemaViolation {
  let items : Array[PivotAxisItem] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "i" {
          let repeat_count = decode_optional_int(child_element, "r", "i/@r").unwrap_or(
            0,
          )
          let item_type = match attr(child_element, "t") {
            Some(text) => Some(ItemType::from_attr(text))
            None => None
          }
          let data_field_index = decode_optional_int(child_element, "i", "i/@i")
          let item_indices : Array[Int] = []
          for inner in child_element.children {
            match inner {
              @xml.Element(x_element) =>
                if x_element.name.local_name == "x" {
                  let value = decode_optional_int(x_element, "v", "i/x/@v").unwrap_or(
                    0,
                  )
                  item_indices.push(value)
                }
              _ => ()
            }
          }
          items.push({ repeat_count, item_type, data_field_index, item_indices })
        }
      _ => ()
    }
  }
  items
}

///|
/// Parse a `field/@x` text into a signed integer. The XSD schema
/// types `@x` as `xsd:int` for `<field>` (allowing the `-2`
/// data-field sentinel), but some serialisers emit
/// `4294967294` (the unsigned 32-bit wraparound). Both are
/// accepted.
fn parse_signed_or_unsigned(
  text : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  let trimmed = trim_whitespace(text)
  if trimmed == "4294967294" {
    return -2
  }
  match parse_int(trimmed) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path~,
        reason="integer attribute is malformed: " + text,
      )
  }
}

///|
fn parse_bool_text(
  text : String,
  path : String,
) -> Bool raise @opc_errors.SchemaViolation {
  decode_bool_text(text, path, "Part 1 §18.10.1.2")
}

///|
fn decode_bool_text(
  text : String,
  path : String,
  section : String,
) -> Bool raise @opc_errors.SchemaViolation {
  match text {
    "1" => true
    "true" => true
    "0" => false
    "false" => false
    _ =>
      raise @opc_errors.SchemaViolation(
        section~,
        path~,
        reason="xsd:boolean value is malformed: " + text,
      )
  }
}

///|
fn pivot_decode_section_for_element(element : @xml.Element) -> String {
  match element.name.local_name {
    "pivotCacheDefinition" | "cacheField" | "sharedItems" =>
      pivot_cache_definition_part1_18_10_1_67_section_name()
    _ => pivot_table_definition_part1_18_10_1_73_section_name()
  }
}

///|
fn attr(element : @xml.Element, local_name : String) -> String? {
  for entry in element.attributes {
    if entry.name.local_name == local_name {
      return Some(entry.value)
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
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path~,
        reason="required attribute is missing",
      )
  }
}

///|
fn decode_bool_attr(
  element : @xml.Element,
  local_name : String,
  fallback : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      decode_bool_text(
        value,
        element.name.local_name + "/@" + local_name,
        pivot_decode_section_for_element(element),
      )
    None => fallback
  }
}

///|
fn decode_required_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  let value = require_attr(element, local_name, path)
  match parse_int(value) {
    Some(n) => n
    None =>
      raise @opc_errors.SchemaViolation(
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path~,
        reason="integer attribute is malformed: " + value,
      )
  }
}

///|
fn decode_optional_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_int(value) {
        Some(n) => Some(n)
        None =>
          raise @opc_errors.SchemaViolation(
            section=pivot_table_definition_part1_18_10_1_73_section_name(),
            path~,
            reason="integer attribute is malformed: " + value,
          )
      }
    None => None
  }
}

///|
fn decode_required_double(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Double raise @opc_errors.SchemaViolation {
  let value = require_attr(element, local_name, path)
  match parse_double(value) {
    Some(n) => n
    None =>
      raise @opc_errors.SchemaViolation(
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path~,
        reason="numeric attribute is malformed: " + value,
      )
  }
}

///|
fn decode_optional_double(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Double? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_double(value) {
        Some(n) => Some(n)
        None =>
          raise @opc_errors.SchemaViolation(
            section=pivot_table_definition_part1_18_10_1_73_section_name(),
            path~,
            reason="numeric attribute is malformed: " + value,
          )
      }
    None => None
  }
}

///|
fn parse_int(text : String) -> Int? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try {
    let value : Int64 = @strconv.from_str(trimmed)
    Some(value.to_int())
  } catch {
    _ => None
  }
}

///|
fn parse_double(text : String) -> Double? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try {
    let value : Double = @strconv.from_str(trimmed)
    Some(value)
  } catch {
    _ => None
  }
}

///|
fn trim_whitespace(text : String) -> String {
  let length = text.length()
  let mut start = 0
  while start < length && is_whitespace_at(text, start) {
    start = start + 1
  }
  let mut end = length
  while end > start && is_whitespace_at(text, end - 1) {
    end = end - 1
  }
  if start == 0 && end == length {
    text
  } else {
    text.unsafe_substring(start~, end~)
  }
}

///|
fn is_whitespace_at(text : String, index : Int) -> Bool {
  let code = text.code_unit_at(index).to_int()
  code == 0x20 || code == 0x09 || code == 0x0A || code == 0x0D
}
