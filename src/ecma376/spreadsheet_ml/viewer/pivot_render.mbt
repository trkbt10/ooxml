// =============================================================================
// SpreadsheetML §18.10 PivotTable rendering.
//
// The pivot machinery lives in `…/pivot_table/` (decode, materialize,
// aggregate) but the SVG renderer never visited the output until now.
// This file adds:
//
//   * `SheetPivot` — the bundle of (definition + cache + records +
//     materialization) the SML facade (`Workbook::to_svg`) hands to
//     `render_svg`. The materialization is computed once at facade
//     time so this file only needs to deal with display.
//
//   * `render_pivot_overlay` — given the sheet layout and a `SheetPivot`,
//     emits an `<g class="pivot-table">` rooted at the pivot's
//     `<location/@ref>` rectangle, painted on top of the empty cell
//     grid the worksheet itself produces. Every cell is an `@xml`
//     element tree built with the same `svg_elem` / `svg_attr` helpers
//     the rest of the renderer uses.
//
// Styling (minimal, ECMA-376 mandated):
//   * Row 0 + column 0 — bold (header band; §18.10.1.73 reserves the
//     first row/column for axis captions).
//   * Last row when `row_grand_totals=true` — bold + top border
//     (§18.10.1.73 row grand-total band).
//   * Last column when `col_grand_totals=true` — bold + left border.
//   * The bottom-right cell when BOTH grand-total flags are on —
//     double border on top and left (§18.10.1.73 overall grand).
//
// Deferred features (each pivot fixture's comment notes which apply):
//   * `<pivotTableStyleInfo>` band styling.
//   * `<conditionalFormatting>` overlays on pivot cells (§18.10.1.20).
//   * `<calculatedFields>` (§18.10.1.11) — the materializer treats
//     them as plain cache fields if the source XML exposes a value,
//     otherwise the bucket is empty.
//   * `<filters>` / `<pageFields>` selector chrome (the value still
//     filters the records, only the dropdown is omitted).
//   * Compact / outline layout (`@compact`, `@outline`) — every fixture
//     uses the default tabular layout the materializer emits.
//   * Multi-level row / col groupings: row / column axes with two or
//     more fields render every key as a single cell; the spec's
//     §18.10.1.44 `@r` repeat-count grouping is not collapsed.

///|
/// One pivot table the facade discovered for the current worksheet,
/// ready for the renderer. Bundles the typed definition (carries the
/// `<location/@ref>` rectangle and the field captions), the cache
/// (for cache-field captions + shared items used to label row/col
/// keys), and the materialization (the actual row × col × dataField
/// grid the renderer paints).
pub(all) struct SheetPivot {
  definition : @pivot_table.PivotTableDefinition
  cache : @pivot_table.PivotCacheDefinition
  materialization : @pivot_table.PivotMaterialization
}

///|
/// §18.10.1.73 — paint one pivot table over the worksheet cell grid.
/// The pivot's `<location/@ref>` selects the top-left cell; the
/// renderer extends the painted region across `header_cols` axis
/// columns + `data_cols` value columns × `header_rows` header rows
/// + `data_rows` body rows. Cells outside the worksheet's nominal
/// dimension are still allowed: the snapshot harness compares
/// against LibreOffice's PDF export which auto-extends the printable
/// region to cover the pivot, so the renderer mirrors that.
fn render_pivot_overlay(
  pivot : SheetPivot,
  layout : SheetLayout,
  options : SheetRenderOptions,
) -> Array[@xml.Node] {
  let location = match pivot.definition.location {
    Some(loc) => loc
    None => return []
  }
  let start_col = match location.ref_range.start_col_zero_based {
    Some(c) => c
    None => return []
  }
  let start_row = match location.ref_range.start_row_zero_based {
    Some(r) => r
    None => return []
  }
  let row_keys = pivot.materialization.row_keys
  let col_keys = pivot.materialization.col_keys
  let data_field_count = pivot.materialization.data_field_count
  if row_keys.length() == 0 || col_keys.length() == 0 || data_field_count == 0 {
    return []
  }
  // Captions for each row / column axis position.
  let row_axis_caps = pivot_axis_captions(
    pivot.cache,
    pivot.definition,
    pivot.definition.row_fields,
  )
  let col_axis_caps = pivot_axis_captions(
    pivot.cache,
    pivot.definition,
    pivot.definition.col_fields,
  )
  let row_axis_count = row_axis_caps.length()
  let col_axis_count = col_axis_caps.length()
  // Row labels — one for every materialized row key (Items / RowGrand).
  let row_labels = pivot_axis_key_labels(
    row_keys,
    pivot,
    pivot.definition.row_fields,
  )
  let col_labels = pivot_axis_key_labels(
    col_keys,
    pivot,
    pivot.definition.col_fields,
  )
  let data_field_names = pivot_data_field_names(pivot)
  // Layout:
  //   • leading `row_axis_count` cols are the row-axis captions / values
  //   • then each col_key occupies `data_field_count` cols (one per
  //     data field) so a multi-value pivot fans out
  //   • header rows = `col_axis_count` (one per column axis field) +
  //     1 row for data-field names when data_field_count > 1
  //   • body rows = row_keys.length()
  let leading_cols = if row_axis_count == 0 { 1 } else { row_axis_count }
  let leading_rows = if col_axis_count == 0 { 1 } else { col_axis_count }
  let value_cols = col_keys.length() * data_field_count
  let total_cols = leading_cols + value_cols
  let multi_data = data_field_count > 1
  let data_field_row = if multi_data { 1 } else { 0 }
  let total_rows = leading_rows + data_field_row + row_keys.length()
  // Pre-compute per-grid pixel coords using the sheet layout. The
  // pivot grid uses the worksheet's own column widths / row heights
  // so the overlay stays aligned with merged cells, the existing
  // grid lines, and the print margin translate.
  let xs : Array[Double] = []
  let ws : Array[Double] = []
  for ci in 0..<total_cols {
    let absolute_col = start_col + ci
    let (x, w) = pivot_column_geometry(layout, options, absolute_col)
    xs.push(x)
    ws.push(w)
  }
  let ys : Array[Double] = []
  let hs : Array[Double] = []
  for ri in 0..<total_rows {
    let absolute_row = start_row + ri
    let (y, h) = pivot_row_geometry(layout, options, absolute_row)
    ys.push(y)
    hs.push(h)
  }
  // Detect grand-total row / col positions (the materializer appends
  // them as the last entries when the spec flags are set).
  let row_grand_idx = pivot_grand_index(row_keys)
  let col_grand_idx = pivot_grand_index(col_keys)
  let nodes : Array[@xml.Node] = []
  // ---- 1. Header band: column-axis captions ---------------------
  for ax in 0..<col_axis_count {
    // Cell at (leading_cols-1, ax) carries the axis name in the
    // last leading column; cells across the value bands stay blank
    // until they reach the per-col_key label band below.
    nodes.push(
      pivot_cell(
        xs[leading_cols - 1],
        ys[ax],
        ws[leading_cols - 1],
        hs[ax],
        col_axis_caps[ax],
        options,
        true,
        false,
        false,
        false,
      ),
    )
  }
  // Column-key labels in the row immediately above the data band.
  let label_row = leading_rows - 1
  for ci in 0..<col_keys.length() {
    let base_col = leading_cols + ci * data_field_count
    let label = col_labels[ci]
    let col_span_w = {
      let mut acc = 0.0
      for d in 0..<data_field_count {
        acc = acc + ws[base_col + d]
      }
      acc
    }
    let is_grand = match col_grand_idx {
      Some(g) => g == ci
      None => false
    }
    nodes.push(
      pivot_cell(
        xs[base_col],
        ys[label_row],
        col_span_w,
        hs[label_row],
        label,
        options,
        true,
        false,
        is_grand,
        false,
      ),
    )
  }
  // ---- 2. Multi-data band: per-data-field names below the column labels.
  if multi_data {
    let band_row = leading_rows
    for ci in 0..<col_keys.length() {
      let base_col = leading_cols + ci * data_field_count
      for d in 0..<data_field_count {
        let is_grand = match col_grand_idx {
          Some(g) => g == ci
          None => false
        }
        nodes.push(
          pivot_cell(
            xs[base_col + d],
            ys[band_row],
            ws[base_col + d],
            hs[band_row],
            data_field_names[d],
            options,
            true,
            false,
            is_grand,
            false,
          ),
        )
      }
    }
  }
  // ---- 3. Row-axis captions on the leading column header row.
  for ax in 0..<row_axis_count {
    // Cell at (ax, label_row) — sits in the corner where the column
    // labels meet the row-axis caption band.
    nodes.push(
      pivot_cell(
        xs[ax],
        ys[label_row],
        ws[ax],
        hs[label_row],
        row_axis_caps[ax],
        options,
        true,
        false,
        false,
        false,
      ),
    )
  }
  // ---- 4. Body rows: row labels in the leading cols, then values.
  let body_top = leading_rows + data_field_row
  for ri in 0..<row_keys.length() {
    let row_y = ys[body_top + ri]
    let row_h = hs[body_top + ri]
    let is_row_grand = match row_grand_idx {
      Some(g) => g == ri
      None => false
    }
    // Row label — span every leading col (compact display).
    let leading_w = {
      let mut acc = 0.0
      for ci in 0..<leading_cols {
        acc = acc + ws[ci]
      }
      acc
    }
    nodes.push(
      pivot_cell(
        xs[0],
        row_y,
        leading_w,
        row_h,
        row_labels[ri],
        options,
        is_row_grand,
        is_row_grand,
        false,
        false,
      ),
    )
    // Value cells.
    for ci in 0..<col_keys.length() {
      let base_col = leading_cols + ci * data_field_count
      let is_col_grand = match col_grand_idx {
        Some(g) => g == ci
        None => false
      }
      for d in 0..<data_field_count {
        let cell_value = match
          pivot.materialization.find(row_keys[ri], col_keys[ci], d) {
          Some(rc) => format_pivot_value(rc.aggregated_value)
          None => ""
        }
        let bold = is_row_grand || is_col_grand
        let top_border = is_row_grand
        let left_border = is_col_grand
        let overall = is_row_grand && is_col_grand
        nodes.push(
          pivot_cell(
            xs[base_col + d],
            row_y,
            ws[base_col + d],
            row_h,
            cell_value,
            options,
            bold,
            top_border,
            left_border,
            overall,
          ),
        )
      }
    }
  }
  // ---- 5. Outer border around the entire pivot region.
  let pivot_x = xs[0]
  let pivot_y = ys[0]
  let pivot_w = {
    let mut acc = 0.0
    for w in ws {
      acc = acc + w
    }
    acc
  }
  let pivot_h = {
    let mut acc = 0.0
    for h in hs {
      acc = acc + h
    }
    acc
  }
  nodes.push(
    svg_elem(
      "rect",
      [
        svg_attr("x", format_d(pivot_x)),
        svg_attr("y", format_d(pivot_y)),
        svg_attr("width", format_d(pivot_w)),
        svg_attr("height", format_d(pivot_h)),
        svg_attr("fill", "none"),
        svg_attr("stroke", "#808080"),
        svg_attr("stroke-width", "0.75"),
      ],
      [],
    ),
  )
  nodes
}

///|
/// Emit one pivot cell — a `<rect>` background, optional border
/// strokes for the grand-total bands, and a `<text>` carrying the
/// label centred-vertically within the cell. The cell stays inside
/// a single `<g>` so the consumer can group / hide them per pivot.
fn pivot_cell(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  text : String,
  options : SheetRenderOptions,
  bold : Bool,
  top_border : Bool,
  left_border : Bool,
  overall : Bool,
) -> @xml.Node {
  let kids : Array[@xml.Node] = []
  // Background — header / totals row a light tone, body white.
  let fill = if overall {
    "#D9D9D9"
  } else if bold {
    "#F2F2F2"
  } else {
    "#FFFFFF"
  }
  kids.push(
    svg_elem(
      "rect",
      [
        svg_attr("x", format_d(x)),
        svg_attr("y", format_d(y)),
        svg_attr("width", format_d(w)),
        svg_attr("height", format_d(h)),
        svg_attr("fill", fill),
        svg_attr("stroke", "#B0B0B0"),
        svg_attr("stroke-width", "0.5"),
      ],
      [],
    ),
  )
  // Grand-total band stroke — double border when `overall`, single
  // bold otherwise. We emit the lines as separate `<line>` elements
  // so the basic cell rectangle keeps its uniform stroke.
  if top_border {
    let stroke_width = if overall { 0.5 } else { 1.0 }
    kids.push(
      svg_elem(
        "line",
        [
          svg_attr("x1", format_d(x)),
          svg_attr("y1", format_d(y)),
          svg_attr("x2", format_d(x + w)),
          svg_attr("y2", format_d(y)),
          svg_attr("stroke", "#000000"),
          svg_attr("stroke-width", format_d(stroke_width)),
        ],
        [],
      ),
    )
    if overall {
      // Inner stroke 2px down — double-border effect.
      kids.push(
        svg_elem(
          "line",
          [
            svg_attr("x1", format_d(x)),
            svg_attr("y1", format_d(y + 2.0)),
            svg_attr("x2", format_d(x + w)),
            svg_attr("y2", format_d(y + 2.0)),
            svg_attr("stroke", "#000000"),
            svg_attr("stroke-width", "0.5"),
          ],
          [],
        ),
      )
    }
  }
  if left_border {
    let stroke_width = if overall { 0.5 } else { 1.0 }
    kids.push(
      svg_elem(
        "line",
        [
          svg_attr("x1", format_d(x)),
          svg_attr("y1", format_d(y)),
          svg_attr("x2", format_d(x)),
          svg_attr("y2", format_d(y + h)),
          svg_attr("stroke", "#000000"),
          svg_attr("stroke-width", format_d(stroke_width)),
        ],
        [],
      ),
    )
    if overall {
      kids.push(
        svg_elem(
          "line",
          [
            svg_attr("x1", format_d(x + 2.0)),
            svg_attr("y1", format_d(y)),
            svg_attr("x2", format_d(x + 2.0)),
            svg_attr("y2", format_d(y + h)),
            svg_attr("stroke", "#000000"),
            svg_attr("stroke-width", "0.5"),
          ],
          [],
        ),
      )
    }
  }
  if text != "" {
    let padding = 2.0
    let text_attrs : Array[@xml.Attribute] = [
      svg_attr("x", format_d(x + padding)),
      svg_attr("y", format_d(y + h / 2.0 + options.default_font_size * 0.35)),
      svg_attr("font-family", options.default_font_family),
      svg_attr("font-size", format_d(options.default_font_size)),
      svg_attr("fill", "#000000"),
    ]
    if bold {
      text_attrs.push(svg_attr("font-weight", "bold"))
    }
    kids.push(svg_elem("text", text_attrs, [svg_text(text)]))
  }
  svg_elem("g", [svg_attr("class", "pivot-cell")], kids)
}

///|
/// §18.10.1.49 — find the pixel rect for the worksheet's column at
/// `col_zero` (an absolute 0-based column index). Returns
/// `(x, width)`. When the column index falls outside the layout's
/// `column_positions`, the renderer extends from the last known
/// column using `column_width_to_pixels(options.default_column_width)`.
fn pivot_column_geometry(
  layout : SheetLayout,
  options : SheetRenderOptions,
  col_zero : Int,
) -> (Double, Double) {
  let default_w = column_width_to_pixels(options.default_column_width)
  if col_zero < layout.column_positions.length() {
    (layout.column_positions[col_zero], layout.column_widths[col_zero])
  } else {
    // Extend past the worksheet's nominal dimension using the
    // renderer's default column width — matches how LibreOffice's
    // PDF export auto-extends the printable region to fit the pivot.
    let overflow = col_zero - layout.column_positions.length() + 1
    let base_x = if layout.column_positions.length() == 0 {
      0.0
    } else {
      let last_idx = layout.column_positions.length() - 1
      layout.column_positions[last_idx] + layout.column_widths[last_idx]
    }
    (base_x + (overflow - 1).to_double() * default_w, default_w)
  }
}

///|
/// §18.10.1.49 — find the pixel rect for the worksheet's row at
/// `row_zero` (an absolute 0-based row index). Returns `(y, height)`.
fn pivot_row_geometry(
  layout : SheetLayout,
  options : SheetRenderOptions,
  row_zero : Int,
) -> (Double, Double) {
  let default_h = row_height_to_pixels(options.default_row_height)
  if row_zero < layout.row_positions.length() {
    (layout.row_positions[row_zero], layout.row_heights[row_zero])
  } else {
    let overflow = row_zero - layout.row_positions.length() + 1
    let base_y = if layout.row_positions.length() == 0 {
      0.0
    } else {
      let last_idx = layout.row_positions.length() - 1
      layout.row_positions[last_idx] + layout.row_heights[last_idx]
    }
    (base_y + (overflow - 1).to_double() * default_h, default_h)
  }
}

///|
/// §18.10.1.73 — collect the captions for the axis (rowFields /
/// colFields) cacheField indices. The sentinel `-2` denotes the
/// data-field pseudo-position; it appears in
/// `(dataCaption|"Values")` and is included in the caption list so
/// the renderer can label that band on the corner header.
fn pivot_axis_captions(
  cache : @pivot_table.PivotCacheDefinition,
  definition : @pivot_table.PivotTableDefinition,
  field_list : Array[Int],
) -> Array[String] {
  let captions : Array[String] = []
  for axis_idx in field_list {
    if axis_idx == -2 {
      // §18.10.1.22 — data-field pseudo-position; use the explicit
      // `dataCaption` (§18.10.1.73 @dataCaption) when provided,
      // otherwise the canonical Excel label "Values".
      let caption = match definition.data_caption {
        Some(v) => v
        None => "Values"
      }
      captions.push(caption)
    } else if axis_idx >= 0 && axis_idx < cache.cache_fields.length() {
      let field = cache.cache_fields[axis_idx]
      let caption = match field.caption {
        Some(v) => v
        None => field.name
      }
      captions.push(caption)
    }
  }
  captions
}

///|
/// Build the labels for each materialized axis key. `Items(indices)`
/// joins the resolved shared-item captions with " / "; `RowGrand` /
/// `ColGrand` use the spec's "Grand Total" caption (the spec allows
/// override via `<pivotField/@grandTotalCaption>` per §18.10.1.73, but
/// we leave the default — fixture comments call this out).
fn pivot_axis_key_labels(
  keys : Array[@pivot_table.PivotAxisKey],
  pivot : SheetPivot,
  field_list : Array[Int],
) -> Array[String] {
  let labels : Array[String] = []
  let positions : Array[Int] = []
  for axis_idx in field_list {
    if axis_idx != -2 {
      positions.push(axis_idx)
    }
  }
  for key in keys {
    match key {
      @pivot_table.PivotAxisKey::Items(indices) => {
        let parts : Array[String] = []
        for i, idx in indices {
          if i < positions.length() {
            parts.push(
              pivot_shared_item_caption(pivot.cache, positions[i], idx),
            )
          }
        }
        labels.push(join_strings(parts, " / "))
      }
      @pivot_table.PivotAxisKey::RowGrand => labels.push("Grand Total")
      @pivot_table.PivotAxisKey::ColGrand => labels.push("Grand Total")
    }
  }
  labels
}

///|
/// Find the caption for a shared-items entry in cache field
/// `field_idx`. Returns the canonical text for each `SharedItemValue`
/// variant; `SharedMissing` resolves to the literal "(blank)" used by
/// Excel for missing values.
fn pivot_shared_item_caption(
  cache : @pivot_table.PivotCacheDefinition,
  field_idx : Int,
  item_idx : Int,
) -> String {
  if field_idx < 0 || field_idx >= cache.cache_fields.length() {
    return ""
  }
  let items = cache.cache_fields[field_idx].shared_items.items
  if item_idx < 0 || item_idx >= items.length() {
    return ""
  }
  shared_item_value_to_caption(items[item_idx])
}

///|
/// Project a `SharedItemValue` into its display caption.
fn shared_item_value_to_caption(value : @pivot_table.SharedItemValue) -> String {
  match value {
    @pivot_table.SharedItemValue::SharedString(s) => s
    @pivot_table.SharedItemValue::SharedNumber(n) => format_pivot_number(n)
    @pivot_table.SharedItemValue::SharedBool(b) =>
      if b {
        "TRUE"
      } else {
        "FALSE"
      }
    @pivot_table.SharedItemValue::SharedDate(iso) => iso
    @pivot_table.SharedItemValue::SharedError(lit) => lit
    @pivot_table.SharedItemValue::SharedMissing => "(blank)"
  }
}

///|
/// §18.10.1.22 — collect the display names for every data field. The
/// `@name` attribute overrides; fallback uses the cacheField name
/// prefixed by the consolidation function (matches Excel's default
/// "Sum of Sales" / "Count of Orders" caption).
fn pivot_data_field_names(pivot : SheetPivot) -> Array[String] {
  let names : Array[String] = []
  for data_field in pivot.definition.data_fields {
    let display = match data_field.name {
      Some(v) => v
      None => {
        let fld_idx = data_field.fld
        let base = if fld_idx >= 0 &&
          fld_idx < pivot.cache.cache_fields.length() {
          pivot.cache.cache_fields[fld_idx].name
        } else {
          ""
        }
        consolidate_function_prefix(data_field.subtotal) + " of " + base
      }
    }
    names.push(display)
  }
  names
}

///|
/// §18.18.17 — return the canonical "Sum"/"Count"/… prefix used by
/// Excel when auto-naming a data field.
fn consolidate_function_prefix(
  fn_ : @pivot_table.DataConsolidateFunction,
) -> String {
  match fn_ {
    @pivot_table.DataConsolidateFunction::Sum => "Sum"
    @pivot_table.DataConsolidateFunction::Average => "Average"
    @pivot_table.DataConsolidateFunction::Count => "Count"
    @pivot_table.DataConsolidateFunction::CountNums => "Count"
    @pivot_table.DataConsolidateFunction::Max => "Max"
    @pivot_table.DataConsolidateFunction::Min => "Min"
    @pivot_table.DataConsolidateFunction::Product => "Product"
    @pivot_table.DataConsolidateFunction::StdDev => "StdDev"
    @pivot_table.DataConsolidateFunction::StdDevP => "StdDevp"
    @pivot_table.DataConsolidateFunction::Var => "Var"
    @pivot_table.DataConsolidateFunction::VarP => "Varp"
  }
}

///|
/// Find the index of the grand-total entry in the materialized axis
/// keys, if any. Returns `None` when no `RowGrand` / `ColGrand`
/// sentinel was appended.
fn pivot_grand_index(keys : Array[@pivot_table.PivotAxisKey]) -> Int? {
  let mut idx = 0
  for key in keys {
    if key.is_grand() {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
/// Format a `@formula.FormulaValue` into the cell-display string used
/// for pivot value cells. Numbers use the spec's General format
/// (drop trailing `.0` for integers); booleans use TRUE/FALSE;
/// errors use the spec literal (`#DIV/0!`, `#N/A`, …).
fn format_pivot_value(value : @formula.FormulaValue) -> String {
  match value {
    @formula.VNumber(n) => format_pivot_number(n)
    @formula.VString(s) => s
    @formula.VBool(true) => "TRUE"
    @formula.VBool(false) => "FALSE"
    @formula.VError(err) => @formula.FormulaError::to_literal(err)
    @formula.VEmpty => ""
    @formula.VArray(_) => ""
  }
}

///|
/// Format a double using Excel's General-format heuristic: drop the
/// fractional component when the value is integral so a sum of 12
/// renders as "12" rather than "12.0".
fn format_pivot_number(value : Double) -> String {
  if value == value.to_int().to_double() && value.abs() < 1.0e15 {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}

///|
/// Join an array of strings with the given separator. Mirrors the
/// standard-library `Array::join` used in other languages without
/// depending on a moonbitlang/core helper for two-element joins.
fn join_strings(parts : Array[String], sep : String) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for p in parts {
    if !first {
      buf.write_string(sep)
    }
    buf.write_string(p)
    first = false
  }
  buf.to_string()
}
