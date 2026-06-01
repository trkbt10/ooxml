///|
/// §18.17.7 GETPIVOTDATA — resolve a formula-level request against the
/// materialized PivotTables discovered for the worksheet. The formula
/// package supplies only parsed argument text and an anchor cell; this
/// package owns field captions, shared item captions, grand-total
/// selection, and the final lookup into `PivotMaterialization`.
pub fn get_pivot_data(
  pivots : Array[MaterializedPivotTable],
  request : @formula.GetPivotDataRequest,
) -> @formula.FormulaValue? {
  for pivot in pivots {
    if !pivot_contains_anchor(pivot, request.anchor) {
      continue
    }
    match get_pivot_data_from_table(pivot, request) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn get_pivot_data_from_table(
  pivot : MaterializedPivotTable,
  request : @formula.GetPivotDataRequest,
) -> @formula.FormulaValue? {
  let data_field_index = match
    find_data_field_index(pivot.definition, pivot.cache, request.data_field) {
    Some(idx) => idx
    None => return None
  }
  let filter_map = build_filter_item_map(pivot.definition, pivot.cache, request)
  match filter_map {
    None => return None
    Some(filters) => {
      if !page_filters_match_request(pivot.definition, filters) {
        return None
      }
      let row_key = match
        axis_key_for_request(
          pivot.definition.row_fields,
          filters,
          pivot.materialization,
          true,
        ) {
        Some(key) => key
        None => return None
      }
      let col_key = match
        axis_key_for_request(
          pivot.definition.col_fields,
          filters,
          pivot.materialization,
          false,
        ) {
        Some(key) => key
        None => return None
      }
      match pivot.materialization.find(row_key, col_key, data_field_index) {
        Some(cell) => Some(cell.aggregated_value)
        None => None
      }
    }
  }
}

///|
fn pivot_contains_anchor(
  pivot : MaterializedPivotTable,
  anchor : @address.CellAddress,
) -> Bool {
  let location = match pivot.definition.location {
    Some(loc) => loc
    None => return false
  }
  let range = location.ref_range
  match (range.sheet, anchor.sheet) {
    (Some(left), Some(right)) => if !caption_equal(left, right) { return false }
    _ => ()
  }
  let start_col = match range.start_col_zero_based {
    Some(v) => v
    None => return false
  }
  let end_col = match range.end_col_zero_based {
    Some(v) => v
    None => return false
  }
  let start_row = match range.start_row_zero_based {
    Some(v) => v
    None => return false
  }
  let end_row = match range.end_row_zero_based {
    Some(v) => v
    None => return false
  }
  anchor.col_zero_based >= start_col &&
  anchor.col_zero_based <= end_col &&
  anchor.row_zero_based >= start_row &&
  anchor.row_zero_based <= end_row
}

///|
fn find_data_field_index(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  requested : String,
) -> Int? {
  for idx in 0..<definition.data_fields.length() {
    match data_field_display_name(definition, cache, idx) {
      Some(name) => if caption_equal(name, requested) { return Some(idx) }
      None => ()
    }
    let data_field = definition.data_fields[idx]
    match data_field.name {
      Some(name) => if caption_equal(name, requested) { return Some(idx) }
      None => ()
    }
    if data_field.fld >= 0 && data_field.fld < cache.cache_fields.length() {
      let cache_field = cache.cache_fields[data_field.fld]
      if caption_equal(cache_field.name, requested) {
        return Some(idx)
      }
      match cache_field.caption {
        Some(caption) =>
          if caption_equal(caption, requested) {
            return Some(idx)
          }
        None => ()
      }
    }
  }
  None
}

///|
fn build_filter_item_map(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  request : @formula.GetPivotDataRequest,
) -> @hashmap.HashMap[Int, Int]? {
  let filters : @hashmap.HashMap[Int, Int] = @hashmap.HashMap([], capacity=0)
  for filter in request.filters {
    let field_idx = match
      find_cache_field_index(definition, cache, filter.field) {
      Some(idx) => idx
      None => return None
    }
    if !field_is_query_axis_or_page(definition, field_idx) {
      return None
    }
    let item_idx = match find_shared_item_index(cache, field_idx, filter.item) {
      Some(idx) => idx
      None => return None
    }
    match filters.get(field_idx) {
      Some(existing) => if existing != item_idx { return None }
      None => filters.set(field_idx, item_idx)
    }
  }
  Some(filters)
}

///|
fn find_cache_field_index(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  requested : String,
) -> Int? {
  for idx in 0..<cache.cache_fields.length() {
    let field = cache.cache_fields[idx]
    if caption_equal(field.name, requested) {
      return Some(idx)
    }
    match field.caption {
      Some(caption) => if caption_equal(caption, requested) { return Some(idx) }
      None => ()
    }
    if idx < definition.pivot_fields.length() {
      match definition.pivot_fields[idx].name {
        Some(name) => if caption_equal(name, requested) { return Some(idx) }
        None => ()
      }
    }
  }
  for page in definition.page_fields {
    match page.name {
      Some(name) => if caption_equal(name, requested) { return Some(page.fld) }
      None => ()
    }
    match page.caption {
      Some(caption) =>
        if caption_equal(caption, requested) {
          return Some(page.fld)
        }
      None => ()
    }
  }
  None
}

///|
fn field_is_query_axis_or_page(
  definition : PivotTableDefinition,
  field_idx : Int,
) -> Bool {
  for entry in definition.row_fields {
    if entry == field_idx {
      return true
    }
  }
  for entry in definition.col_fields {
    if entry == field_idx {
      return true
    }
  }
  for page in definition.page_fields {
    if page.fld == field_idx {
      return true
    }
  }
  false
}

///|
fn find_shared_item_index(
  cache : PivotCacheDefinition,
  field_idx : Int,
  requested : String,
) -> Int? {
  if field_idx < 0 || field_idx >= cache.cache_fields.length() {
    return None
  }
  let items = cache.cache_fields[field_idx].shared_items.items
  for idx in 0..<items.length() {
    if caption_equal(shared_item_value_to_caption(items[idx]), requested) {
      return Some(idx)
    }
  }
  None
}

///|
fn page_filters_match_request(
  definition : PivotTableDefinition,
  filters : @hashmap.HashMap[Int, Int],
) -> Bool {
  for page in definition.page_fields {
    match filters.get(page.fld) {
      Some(requested) =>
        match page.item {
          Some(selected) => if requested != selected { return false }
          None => ()
        }
      None => ()
    }
  }
  true
}

///|
fn axis_key_for_request(
  fields : Array[Int],
  filters : @hashmap.HashMap[Int, Int],
  materialization : PivotMaterialization,
  row_axis : Bool,
) -> PivotAxisKey? {
  let real_fields = extract_real_field_positions(fields)
  if real_fields.length() == 0 {
    return Some(Items([]))
  }
  let item_indices : Array[Int] = []
  let mut matched = 0
  for field_idx in real_fields {
    match filters.get(field_idx) {
      Some(item_idx) => {
        item_indices.push(item_idx)
        matched = matched + 1
      }
      None => ()
    }
  }
  if matched == real_fields.length() {
    return Some(Items(item_indices))
  }
  if matched > 0 {
    return None
  }
  let grand = if row_axis { RowGrand } else { ColGrand }
  if materialization_has_axis_key(materialization, grand, row_axis) {
    Some(grand)
  } else {
    None
  }
}

///|
fn materialization_has_axis_key(
  materialization : PivotMaterialization,
  key : PivotAxisKey,
  row_axis : Bool,
) -> Bool {
  let keys = if row_axis {
    materialization.row_keys
  } else {
    materialization.col_keys
  }
  for existing in keys {
    if existing == key {
      return true
    }
  }
  false
}

///|
fn caption_equal(left : String, right : String) -> Bool {
  left.trim().to_owned().to_upper() == right.trim().to_owned().to_upper()
}
