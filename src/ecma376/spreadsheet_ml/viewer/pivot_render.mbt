// =============================================================================
// SpreadsheetML §18.10 PivotTable rendering.
//
// The pivot machinery lives in `…/pivot_table/` (decode, materialize,
// aggregate) but the SVG renderer never visited the output until now.
// This file adds:
//
//   * `@pivot_table.MaterializedPivotTable` — the bundle of
//     (definition + cache + materialization) the SML facade
//     (`Workbook::to_svg`) hands to `render_svg`. The materialization
//     is computed once at facade time so this file only needs display.
//
//   * `render_pivot_overlay` — given the sheet layout and a materialized
//     pivot, emits an `<g class="pivot-table">` rooted at the pivot's
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
// Implemented beyond the basic grid:
//   * Calculated cache fields (§18.10.1.3 `<cacheField @formula>`) —
//     each calculated-field cell is derived by applying the field's
//     formula to the SUMMED operands of that cell (the documented
//     calc-field semantics); see
//     `pivot_table/calc_fields.mbt`.
//   * Multi-level ROW and COLUMN groupings render tabular — one leading
//     column per row field / one header row per column field — with
//     §18.10.1.44 repeat-key collapse (a key segment is blanked when it
//     and its parents match the previous row / column).
//
//   * `<pivotTableStyleInfo>` (§18.10.1.74) — the style name + band /
//     header toggles are surfaced as spec-anchored `data-ooxml-pivot-*`
//     metadata on the pivot group.  The built-in table-style stripe
//     COLOURS are application-defined (not carried in the file), so —
//     as with iconSet — the viewer emits the identity for a consumer to
//     apply rather than fabricating colours.
//
//   * Conditional formatting on pivot value cells (§18.3.1.18) — Excel
//     stores pivot CF as a worksheet `<conditionalFormatting>` block
//     whose sqref covers the pivot region, so each pivot value cell is
//     run through the same `apply_cf_overlay` evaluator (synthesizing a
//     `<c>` from its aggregate); the dxf fill / colour-scale / font
//     font override is applied to the cell.
//
//   * `<pageFields>` (§18.10.1.62) — the records are filtered by
//     `apply_page_filter` and the active per-field selection is rendered
//     in the page-field area reserved by `location/@rowPageCount`.
//   * `@compact` / `@outline` are display-layout flags; the renderer
//     emits the content-equivalent TABULAR layout (one column per row
//     field) — the cell values and grouping are identical, only the
//     indentation style differs.

///|
/// §18.10.1.73 — paint one pivot table over the worksheet cell grid.
/// The pivot's `<location/@ref>` selects the top-left cell; the
/// renderer extends the painted region across `header_cols` axis
/// columns + `data_cols` value columns × `header_rows` header rows
/// + `data_rows` body rows. Cells outside the worksheet's nominal
/// dimension are still allowed: the snapshot harness compares
/// against the reference renderer which auto-extends the printable
/// region to cover the pivot, so the renderer mirrors that.
fn render_pivot_overlay(
  pivot : @pivot_table.MaterializedPivotTable,
  layout : SheetLayout,
  options : SheetRenderOptions,
  cf_blocks : Array[@domain.CT_ConditionalFormatting],
  cf_stats : Array[CfRulePopulation],
  styles : @domain.CT_Stylesheet?,
  shared_strings : @domain.CT_Sst?,
  theme_map : SmlThemeColorMap,
  theme_fonts : SmlThemeFontMap,
  max_digit_width_px~ : Double,
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
  let grid_start_row = start_row + location.first_header_row
  let row_keys = pivot.materialization.row_keys
  let col_keys = pivot.materialization.col_keys
  let data_field_count = pivot.materialization.data_field_count
  if row_keys.length() == 0 || col_keys.length() == 0 || data_field_count == 0 {
    return []
  }
  if pivot.definition.data_on_rows && data_field_count > 1 {
    return render_pivot_overlay_data_on_rows(
      pivot,
      layout,
      options,
      cf_blocks,
      cf_stats,
      styles,
      shared_strings,
      theme_map,
      theme_fonts,
      start_col,
      grid_start_row,
      row_keys,
      col_keys,
      data_field_count,
      max_digit_width_px~,
    )
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
  // Row labels — one for every materialized row key.
  let row_labels = pivot_axis_key_labels(
    row_keys,
    pivot,
    pivot.definition.row_fields,
  )
  // §18.10.1.44 — per-field labels for the multi-level tabular layout
  // (one leading column per row field; repeated parent keys blanked).
  let row_field_labels = pivot_axis_key_field_labels(
    row_keys,
    pivot,
    pivot.definition.row_fields,
  )
  let col_labels = pivot_axis_key_labels(
    col_keys,
    pivot,
    pivot.definition.col_fields,
  )
  // §18.10.1.44 — per-field col labels for the multi-level column
  // header (one header row per col field; repeated parent keys blanked
  // horizontally).
  let col_field_labels = pivot_axis_key_field_labels(
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
    let (x, w) = pivot_column_geometry(
      layout,
      options,
      absolute_col,
      max_digit_width_px~,
    )
    xs.push(x)
    ws.push(w)
  }
  let ys : Array[Double] = []
  let hs : Array[Double] = []
  for ri in 0..<total_rows {
    let absolute_row = grid_start_row + ri
    let (y, h) = pivot_row_geometry(layout, options, absolute_row)
    ys.push(y)
    hs.push(h)
  }
  // Detect grand-total row / col positions (the materializer appends
  // them as the last entries when the spec flags are set).
  let row_grand_idx = pivot_grand_index(row_keys)
  let col_grand_idx = pivot_grand_index(col_keys)
  let nodes : Array[@xml.Node] = []
  for
    n in render_pivot_page_fields(
      pivot,
      layout,
      options,
      start_col,
      start_row,
      max_digit_width_px~,
    ) {
    nodes.push(n)
  }
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
  // Column-key labels above the data band.
  let label_row = leading_rows - 1
  // Width spanning the `data_field_count` value columns of col-key `ci`.
  fn col_key_span_w(ci : Int) -> Double {
    let base_col = leading_cols + ci * data_field_count
    let mut acc = 0.0
    for d in 0..<data_field_count {
      acc = acc + ws[base_col + d]
    }
    acc
  }

  if col_axis_count >= 2 {
    // §18.10.1.44 multi-level columns — header row `f` carries each
    // col-key's field-`f` value, blanked when it (and its parents)
    // repeat the previous col-key (horizontal grouping collapse).
    for f in 0..<col_axis_count {
      for ci in 0..<col_keys.length() {
        let base_col = leading_cols + ci * data_field_count
        let is_grand = match col_grand_idx {
          Some(g) => g == ci
          None => false
        }
        let fields = col_field_labels[ci]
        let label = if is_grand {
          if f == 0 {
            "Grand Total"
          } else {
            ""
          }
        } else if f < fields.length() {
          fields[f]
        } else {
          ""
        }
        // Collapse against the previous col-key when neither it nor the
        // previous one is a grand-total column.
        let collapsed = if is_grand || ci == 0 {
          false
        } else if (match col_grand_idx {
            Some(g) => g == ci - 1
            None => false
          }) {
          false
        } else {
          let pf = col_field_labels[ci - 1]
          let mut same = true
          for k in 0..<=f {
            let a = if k < fields.length() { fields[k] } else { "" }
            let b = if k < pf.length() { pf[k] } else { "" }
            if a != b {
              same = false
              break
            }
          }
          same
        }
        nodes.push(
          pivot_cell(
            xs[base_col],
            ys[f],
            col_key_span_w(ci),
            hs[f],
            if collapsed {
              ""
            } else {
              label
            },
            options,
            true,
            false,
            is_grand,
            false,
          ),
        )
      }
    }
  } else {
    for ci in 0..<col_keys.length() {
      let base_col = leading_cols + ci * data_field_count
      let is_grand = match col_grand_idx {
        Some(g) => g == ci
        None => false
      }
      nodes.push(
        pivot_cell(
          xs[base_col],
          ys[label_row],
          col_key_span_w(ci),
          hs[label_row],
          col_labels[ci],
          options,
          true,
          false,
          is_grand,
          false,
        ),
      )
    }
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
    let is_row_subtotal = pivot_axis_key_is_row_subtotal(row_keys[ri])
    // Row label(s).  §18.10.1.44 — with two or more row fields the
    // TABULAR layout gives each field its own leading column and blanks
    // a key segment that repeats the previous row's value (its parent
    // segments matching), so the grouping reads as a hierarchy rather
    // than a fully-repeated key on every row.  A single row field (or a
    // grand-total row) keeps the compact spanning cell.
    let tabular = row_axis_count >= 2 && !is_row_grand && !is_row_subtotal
    if tabular {
      let fields = row_field_labels[ri]
      let prev = if ri > 0 { Some(row_field_labels[ri - 1]) } else { None }
      for ci in 0..<leading_cols {
        let label = if ci < fields.length() { fields[ci] } else { "" }
        // Blank this segment when it and every ancestor segment match
        // the previous row (the parent group is unchanged).
        let collapsed = match prev {
          Some(pf) => {
            let mut same = true
            for k in 0..<=ci {
              let a = if k < fields.length() { fields[k] } else { "" }
              let b = if k < pf.length() { pf[k] } else { "" }
              if a != b {
                same = false
                break
              }
            }
            same
          }
          None => false
        }
        nodes.push(
          pivot_cell(
            xs[ci],
            row_y,
            ws[ci],
            row_h,
            if collapsed {
              ""
            } else {
              label
            },
            options,
            false,
            false,
            false,
            false,
          ),
        )
      }
    } else {
      // Compact display — span every leading col with the joined label.
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
          is_row_grand || is_row_subtotal,
          is_row_grand || is_row_subtotal,
          false,
          false,
        ),
      )
    }
    // Value cells.
    for ci in 0..<col_keys.length() {
      let base_col = leading_cols + ci * data_field_count
      let is_col_grand = match col_grand_idx {
        Some(g) => g == ci
        None => false
      }
      for d in 0..<data_field_count {
        let found = pivot.materialization.find(row_keys[ri], col_keys[ci], d)
        let cell_value = match found {
          Some(rc) => format_pivot_value(rc.aggregated_value)
          None => ""
        }
        let bold = is_row_grand || is_row_subtotal || is_col_grand
        let top_border = is_row_grand || is_row_subtotal
        let left_border = is_col_grand
        let overall = is_row_grand && is_col_grand
        // §18.3.1.18 — apply any worksheet conditional formatting whose
        // sqref covers this pivot value cell (Excel stores pivot CF as a
        // worksheet `<conditionalFormatting>` block over the pivot
        // region).  The sheet position is the pivot origin plus the
        // cell's grid offset.
        let (format_fill, format_font) = match found {
          Some(_) =>
            pivot_value_format_style(
              pivot,
              row_keys[ri],
              col_keys[ci],
              options,
              styles,
              theme_map,
              theme_fonts,
            )
          None => (None, None)
        }
        let (cf_fill, cf_font) = match found {
          Some(rc) =>
            pivot_value_cf_style(
              grid_start_row + body_top + ri,
              start_col + base_col + d,
              rc.aggregated_value,
              options,
              cf_blocks,
              cf_stats,
              styles,
              shared_strings,
              theme_map,
              theme_fonts,
            )
          None => (None, None)
        }
        let fill = match cf_fill {
          Some(_) => cf_fill
          None => format_fill
        }
        let font = match cf_font {
          Some(_) => cf_font
          None => format_font
        }
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
            fill_override=fill,
            text_font=font,
          ),
        )
      }
    }
  }
  // ---- 5. Outer border around the entire pivot region.
  push_pivot_outer_border(nodes, xs, ys, ws, hs)
  [svg_elem("g", pivot_group_attrs(pivot), nodes)]
}

///|
/// §18.10.1.73 @dataOnRows — when multiple data fields are placed
/// on the row axis, the materialized values remain addressed by
/// `(row_key, col_key, data_field_index)`; only the display projection
/// changes. This renderer branch keeps all value lookup through the
/// same `PivotMaterialization` SoT and expands each row key into one
/// visible row per data field.
fn render_pivot_overlay_data_on_rows(
  pivot : @pivot_table.MaterializedPivotTable,
  layout : SheetLayout,
  options : SheetRenderOptions,
  cf_blocks : Array[@domain.CT_ConditionalFormatting],
  cf_stats : Array[CfRulePopulation],
  styles : @domain.CT_Stylesheet?,
  shared_strings : @domain.CT_Sst?,
  theme_map : SmlThemeColorMap,
  theme_fonts : SmlThemeFontMap,
  start_col : Int,
  start_row : Int,
  row_keys : Array[@pivot_table.PivotAxisKey],
  col_keys : Array[@pivot_table.PivotAxisKey],
  data_field_count : Int,
  max_digit_width_px~ : Double,
) -> Array[@xml.Node] {
  let row_slots = pivot_data_on_rows_slots(pivot.definition.row_fields)
  let row_axis_caps = pivot_axis_slot_captions(
    pivot.cache,
    pivot.definition,
    row_slots,
  )
  let row_axis_count = row_slots.length()
  let real_row_positions = pivot_axis_real_positions(
    pivot.definition.row_fields,
  )
  let row_labels = pivot_axis_key_labels(
    row_keys,
    pivot,
    pivot.definition.row_fields,
  )
  let col_axis_caps = pivot_axis_captions(
    pivot.cache,
    pivot.definition,
    pivot.definition.col_fields,
  )
  let col_axis_count = col_axis_caps.length()
  let row_field_labels = pivot_axis_key_field_labels(
    row_keys,
    pivot,
    pivot.definition.row_fields,
  )
  let col_labels = pivot_axis_key_labels(
    col_keys,
    pivot,
    pivot.definition.col_fields,
  )
  let col_field_labels = pivot_axis_key_field_labels(
    col_keys,
    pivot,
    pivot.definition.col_fields,
  )
  let data_field_names = pivot_data_field_names(pivot)
  let leading_cols = if row_axis_count == 0 { 1 } else { row_axis_count }
  let leading_rows = if col_axis_count == 0 { 1 } else { col_axis_count }
  let value_cols = col_keys.length()
  let total_cols = leading_cols + value_cols
  let total_rows = leading_rows + row_keys.length() * data_field_count
  let xs : Array[Double] = []
  let ws : Array[Double] = []
  for ci in 0..<total_cols {
    let absolute_col = start_col + ci
    let (x, w) = pivot_column_geometry(
      layout,
      options,
      absolute_col,
      max_digit_width_px~,
    )
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
  let row_grand_idx = pivot_grand_index(row_keys)
  let col_grand_idx = pivot_grand_index(col_keys)
  let nodes : Array[@xml.Node] = []
  let page_start_row = match pivot.definition.location {
    Some(loc) => start_row - loc.first_header_row
    None => start_row
  }
  for
    n in render_pivot_page_fields(
      pivot,
      layout,
      options,
      start_col,
      page_start_row,
      max_digit_width_px~,
    ) {
    nodes.push(n)
  }
  for ax in 0..<col_axis_count {
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
  let label_row = leading_rows - 1
  if col_axis_count >= 2 {
    for f in 0..<col_axis_count {
      for ci in 0..<col_keys.length() {
        let base_col = leading_cols + ci
        let is_grand = match col_grand_idx {
          Some(g) => g == ci
          None => false
        }
        let fields = col_field_labels[ci]
        let label = if is_grand {
          if f == 0 {
            "Grand Total"
          } else {
            ""
          }
        } else if f < fields.length() {
          fields[f]
        } else {
          ""
        }
        let collapsed = if is_grand || ci == 0 {
          false
        } else if (match col_grand_idx {
            Some(g) => g == ci - 1
            None => false
          }) {
          false
        } else {
          let pf = col_field_labels[ci - 1]
          let mut same = true
          for k in 0..<=f {
            let a = if k < fields.length() { fields[k] } else { "" }
            let b = if k < pf.length() { pf[k] } else { "" }
            if a != b {
              same = false
              break
            }
          }
          same
        }
        nodes.push(
          pivot_cell(
            xs[base_col],
            ys[f],
            ws[base_col],
            hs[f],
            if collapsed {
              ""
            } else {
              label
            },
            options,
            true,
            false,
            is_grand,
            false,
          ),
        )
      }
    }
  } else {
    for ci in 0..<col_keys.length() {
      let base_col = leading_cols + ci
      let is_grand = match col_grand_idx {
        Some(g) => g == ci
        None => false
      }
      nodes.push(
        pivot_cell(
          xs[base_col],
          ys[label_row],
          ws[base_col],
          hs[label_row],
          col_labels[ci],
          options,
          true,
          false,
          is_grand,
          false,
        ),
      )
    }
  }
  for ax in 0..<row_axis_count {
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
  let body_top = leading_rows
  for ri in 0..<row_keys.length() {
    let is_row_grand = match row_grand_idx {
      Some(g) => g == ri
      None => false
    }
    let is_row_subtotal = pivot_axis_key_is_row_subtotal(row_keys[ri])
    let fields = row_field_labels[ri]
    let prev = if ri > 0 { Some(row_field_labels[ri - 1]) } else { None }
    for d in 0..<data_field_count {
      let grid_row = body_top + ri * data_field_count + d
      let row_y = ys[grid_row]
      let row_h = hs[grid_row]
      for slot_idx in 0..<leading_cols {
        let slot = row_slots[slot_idx]
        let label = if slot == -2 {
          data_field_names[d]
        } else if is_row_grand {
          if slot_idx == 0 && d == 0 {
            "Grand Total"
          } else {
            ""
          }
        } else if is_row_subtotal {
          if slot_idx == 0 && d == 0 {
            row_labels[ri]
          } else {
            ""
          }
        } else if d > 0 {
          ""
        } else {
          match pivot_axis_slot_ordinal(real_row_positions, slot) {
            Some(real_idx) =>
              if real_idx < fields.length() {
                let collapsed = match prev {
                  Some(pf) => {
                    let mut same = true
                    for k in 0..<=real_idx {
                      let a = if k < fields.length() { fields[k] } else { "" }
                      let b = if k < pf.length() { pf[k] } else { "" }
                      if a != b {
                        same = false
                        break
                      }
                    }
                    same
                  }
                  None => false
                }
                if collapsed {
                  ""
                } else {
                  fields[real_idx]
                }
              } else {
                ""
              }
            None => ""
          }
        }
        let top_border = (is_row_grand || is_row_subtotal) && d == 0
        nodes.push(
          pivot_cell(
            xs[slot_idx],
            row_y,
            ws[slot_idx],
            row_h,
            label,
            options,
            is_row_grand || is_row_subtotal || slot == -2,
            top_border,
            false,
            false,
          ),
        )
      }
      for ci in 0..<col_keys.length() {
        let base_col = leading_cols + ci
        let is_col_grand = match col_grand_idx {
          Some(g) => g == ci
          None => false
        }
        let found = pivot.materialization.find(row_keys[ri], col_keys[ci], d)
        let cell_value = match found {
          Some(rc) => format_pivot_value(rc.aggregated_value)
          None => ""
        }
        let bold = is_row_grand || is_row_subtotal || is_col_grand
        let top_border = (is_row_grand || is_row_subtotal) && d == 0
        let left_border = is_col_grand
        let overall = is_row_grand && is_col_grand
        let (format_fill, format_font) = match found {
          Some(_) =>
            pivot_value_format_style(
              pivot,
              row_keys[ri],
              col_keys[ci],
              options,
              styles,
              theme_map,
              theme_fonts,
            )
          None => (None, None)
        }
        let (cf_fill, cf_font) = match found {
          Some(rc) =>
            pivot_value_cf_style(
              start_row + grid_row,
              start_col + base_col,
              rc.aggregated_value,
              options,
              cf_blocks,
              cf_stats,
              styles,
              shared_strings,
              theme_map,
              theme_fonts,
            )
          None => (None, None)
        }
        let fill = match cf_fill {
          Some(_) => cf_fill
          None => format_fill
        }
        let font = match cf_font {
          Some(_) => cf_font
          None => format_font
        }
        nodes.push(
          pivot_cell(
            xs[base_col],
            row_y,
            ws[base_col],
            row_h,
            cell_value,
            options,
            bold,
            top_border,
            left_border,
            overall,
            fill_override=fill,
            text_font=font,
          ),
        )
      }
    }
  }
  push_pivot_outer_border(nodes, xs, ys, ws, hs)
  [svg_elem("g", pivot_group_attrs(pivot), nodes)]
}

///|
fn render_pivot_page_fields(
  pivot : @pivot_table.MaterializedPivotTable,
  layout : SheetLayout,
  options : SheetRenderOptions,
  start_col : Int,
  start_row : Int,
  max_digit_width_px~ : Double,
) -> Array[@xml.Node] {
  let location = match pivot.definition.location {
    Some(loc) => loc
    None => return []
  }
  if pivot.definition.page_fields.length() == 0 || location.row_page_count <= 0 {
    return []
  }
  let nodes : Array[@xml.Node] = []
  let mut row_offset = 0
  for pf in pivot.definition.page_fields {
    if row_offset >= location.row_page_count {
      break
    }
    let (label_x, label_w) = pivot_column_geometry(
      layout,
      options,
      start_col,
      max_digit_width_px~,
    )
    let (value_x, value_w) = pivot_column_geometry(
      layout,
      options,
      start_col + 1,
      max_digit_width_px~,
    )
    let (row_y, row_h) = pivot_row_geometry(
      layout,
      options,
      start_row + row_offset,
    )
    nodes.push(
      pivot_cell(
        label_x,
        row_y,
        label_w,
        row_h,
        pivot_page_field_label(pivot, pf),
        options,
        true,
        false,
        false,
        false,
      ),
    )
    nodes.push(
      pivot_cell(
        value_x,
        row_y,
        value_w,
        row_h,
        pivot_page_field_selection(pivot, pf),
        options,
        false,
        false,
        false,
        false,
      ),
    )
    for
      arrow in render_autofilter_arrow(
        (value_x, row_y, value_w, row_h),
        pivot_page_field_is_filtered(pf),
      ) {
      nodes.push(arrow)
    }
    row_offset = row_offset + 1
  }
  if nodes.length() == 0 {
    []
  } else {
    [svg_elem("g", [svg_attr("class", "pivot-page-fields")], nodes)]
  }
}

///|
fn pivot_page_field_label(
  pivot : @pivot_table.MaterializedPivotTable,
  pf : @pivot_table.PageFieldDef,
) -> String {
  match pf.caption {
    Some(caption) => caption
    None =>
      match pf.name {
        Some(name) => name
        None =>
          if pf.fld >= 0 && pf.fld < pivot.cache.cache_fields.length() {
            let field = pivot.cache.cache_fields[pf.fld]
            match field.caption {
              Some(caption) => caption
              None => field.name
            }
          } else {
            ""
          }
      }
  }
}

///|
fn pivot_page_field_selection(
  pivot : @pivot_table.MaterializedPivotTable,
  pf : @pivot_table.PageFieldDef,
) -> String {
  match pf.item {
    Some(idx) => pivot_shared_item_caption(pivot.cache, pf.fld, idx)
    None => "(All)"
  }
}

///|
fn pivot_page_field_is_filtered(pf : @pivot_table.PageFieldDef) -> Bool {
  match pf.item {
    Some(_) => true
    None => false
  }
}

///|
fn push_pivot_outer_border(
  nodes : Array[@xml.Node],
  xs : Array[Double],
  ys : Array[Double],
  ws : Array[Double],
  hs : Array[Double],
) -> Unit {
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
}

///|
fn pivot_group_attrs(
  pivot : @pivot_table.MaterializedPivotTable,
) -> Array[@xml.Attribute] {
  // §18.10.1.74 pivotTableStyleInfo — the built-in table-style colours
  // (`PivotStyleMedium9`, …) are application-defined and not carried in
  // the file, so surface the style name + band/header toggles as
  // spec-anchored metadata on the pivot group (the iconSet pattern) for
  // a consumer to apply, rather than fabricating stripe colours.
  let group_attrs : Array[@xml.Attribute] = [svg_attr("class", "pivot-table")]
  match pivot.definition.style_info {
    Some(si) => {
      match si.name {
        Some(nm) => group_attrs.push(svg_attr("data-ooxml-pivot-style", nm))
        None => ()
      }
      if si.show_row_stripes {
        group_attrs.push(svg_attr("data-ooxml-pivot-row-stripes", "1"))
      }
      if si.show_col_stripes {
        group_attrs.push(svg_attr("data-ooxml-pivot-col-stripes", "1"))
      }
      if si.show_row_headers {
        group_attrs.push(svg_attr("data-ooxml-pivot-row-headers", "1"))
      }
      if si.show_col_headers {
        group_attrs.push(svg_attr("data-ooxml-pivot-col-headers", "1"))
      }
      if si.show_last_column {
        group_attrs.push(svg_attr("data-ooxml-pivot-last-column", "1"))
      }
    }
    None => ()
  }
  emit_pivot_field_metadata_attrs(pivot.definition, group_attrs)
  emit_pivot_format_metadata_attrs(pivot.definition, group_attrs)
  emit_pivot_hierarchy_metadata_attrs(pivot.definition, group_attrs)
  emit_pivot_cache_metadata_attrs(pivot.cache, group_attrs)
  // §18.10.1.62 pageFields — the active page-field filters (the data is
  // already filtered by `apply_page_filter`; surface the current
  // selection per field as metadata, e.g. "Region=East", so a consumer
  // can render the page-field/dropdown chrome above the pivot).
  for pf in pivot.definition.page_fields {
    let field_name = if pf.fld >= 0 &&
      pf.fld < pivot.cache.cache_fields.length() {
      pivot.cache.cache_fields[pf.fld].name
    } else {
      ""
    }
    let selected = match pf.item {
      Some(idx) => pivot_shared_item_caption(pivot.cache, pf.fld, idx)
      None => "(All)"
    }
    if field_name.length() > 0 {
      group_attrs.push(
        svg_attr("data-ooxml-pivot-page-field", field_name + "=" + selected),
      )
    }
  }
  group_attrs
}

///|
fn emit_pivot_field_metadata_attrs(
  definition : @pivot_table.PivotTableDefinition,
  out : Array[@xml.Attribute],
) -> Unit {
  if definition.pivot_fields.length() == 0 {
    return
  }
  out.push(
    svg_attr(
      "data-ooxml-pivot-fields-count",
      definition.pivot_fields.length().to_string(),
    ),
  )
  for i, field in definition.pivot_fields {
    let prefix = "data-ooxml-pivot-field-" + i.to_string()
    match field.axis {
      None => ()
      Some(axis) => out.push(svg_attr(prefix + "-axis", pivot_axis_attr(axis)))
    }
    out.push(svg_attr(prefix + "-data-field", bool_data_attr(field.data_field)))
    out.push(
      svg_attr(
        prefix + "-include-new-items-in-filter",
        bool_data_attr(field.include_new_items_in_filter),
      ),
    )
    push_data_attr_opt(out, prefix + "-name", field.name)
    push_data_attr_opt(
      out,
      prefix + "-subtotal-caption",
      field.subtotal_caption,
    )
    out.push(svg_attr(prefix + "-outline", bool_data_attr(field.outline)))
    out.push(
      svg_attr(prefix + "-subtotal-top", bool_data_attr(field.subtotal_top)),
    )
    out.push(
      svg_attr(
        prefix + "-default-subtotal",
        bool_data_attr(field.default_subtotal),
      ),
    )
    out.push(
      svg_attr(prefix + "-items-count", field.items.length().to_string()),
    )
    push_data_attr_int_opt(
      out,
      prefix + "-items-declared-count",
      field.items_declared_count,
    )
    match field.auto_sort_scope {
      None => ()
      Some(scope) => {
        emit_source_element_attrs(
          prefix + "-auto-sort-scope",
          scope.element,
          out,
        )
        emit_pivot_area_attrs(
          scope.pivot_area,
          prefix + "-auto-sort-scope-area",
          out,
        )
      }
    }
  }
}

///|
fn pivot_axis_attr(axis : @pivot_table.PivotAxis) -> String {
  match axis {
    AxisRow => "axisRow"
    AxisCol => "axisCol"
    AxisPage => "axisPage"
    AxisValues => "axisValues"
  }
}

///|
fn emit_pivot_format_metadata_attrs(
  definition : @pivot_table.PivotTableDefinition,
  out : Array[@xml.Attribute],
) -> Unit {
  match definition.formats {
    None => ()
    Some(formats) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-formats-count",
          formats.format.length().to_string(),
        ),
      )
      out.push(
        svg_attr(
          "data-ooxml-pivot-formats-declared-count",
          formats.count.to_string(),
        ),
      )
      for i, format in formats.format {
        let prefix = "data-ooxml-pivot-format-" + i.to_string()
        out.push(svg_attr(prefix + "-action", format.action))
        push_data_attr_int_opt(out, prefix + "-dxf-id", format.dxf_id)
        emit_pivot_area_attrs(format.pivot_area, prefix + "-area", out)
      }
    }
  }
  match definition.conditional_formats {
    None => ()
    Some(formats) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-conditional-formats-count",
          formats.conditional_format.length().to_string(),
        ),
      )
      out.push(
        svg_attr(
          "data-ooxml-pivot-conditional-formats-declared-count",
          formats.count.to_string(),
        ),
      )
      for i, format in formats.conditional_format {
        let prefix = "data-ooxml-pivot-conditional-format-" + i.to_string()
        out.push(svg_attr(prefix + "-scope", format.scope))
        out.push(svg_attr(prefix + "-type", format.type_))
        out.push(svg_attr(prefix + "-priority", format.priority.to_string()))
        match format.pivot_areas {
          None => ()
          Some(areas) => {
            out.push(
              svg_attr(
                prefix + "-areas-count",
                areas.pivot_areas.length().to_string(),
              ),
            )
            push_data_attr_int_opt(
              out,
              prefix + "-areas-declared-count",
              areas.count,
            )
            for j, area in areas.pivot_areas {
              emit_pivot_area_attrs(
                area,
                prefix + "-area-" + j.to_string(),
                out,
              )
            }
          }
        }
      }
    }
  }
  match definition.chart_formats {
    None => ()
    Some(formats) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-chart-formats-count",
          formats.chart_format.length().to_string(),
        ),
      )
      out.push(
        svg_attr(
          "data-ooxml-pivot-chart-formats-declared-count",
          formats.count.to_string(),
        ),
      )
      for i, format in formats.chart_format {
        let prefix = "data-ooxml-pivot-chart-format-" + i.to_string()
        out.push(svg_attr(prefix + "-chart", format.chart.to_string()))
        out.push(svg_attr(prefix + "-format", format.format.to_string()))
        out.push(svg_attr(prefix + "-series", bool_data_attr(format.series)))
        match format.pivot_area {
          None => ()
          Some(area) => emit_pivot_area_attrs(area, prefix + "-area", out)
        }
      }
    }
  }
}

///|
fn emit_pivot_area_attrs(
  area : @domain.CT_PivotArea,
  prefix : String,
  out : Array[@xml.Attribute],
) -> Unit {
  push_data_attr_int_opt(out, prefix + "-field", area.field)
  out.push(svg_attr(prefix + "-type", area.type_))
  out.push(svg_attr(prefix + "-data-only", bool_data_attr(area.data_only)))
  out.push(svg_attr(prefix + "-label-only", bool_data_attr(area.label_only)))
  out.push(svg_attr(prefix + "-grand-row", bool_data_attr(area.grand_row)))
  out.push(svg_attr(prefix + "-grand-col", bool_data_attr(area.grand_col)))
  out.push(svg_attr(prefix + "-cache-index", bool_data_attr(area.cache_index)))
  out.push(svg_attr(prefix + "-outline", bool_data_attr(area.outline)))
  push_data_attr_opt(out, prefix + "-offset", area.offset)
  out.push(
    svg_attr(
      prefix + "-collapsed-levels-are-subtotals",
      bool_data_attr(area.collapsed_levels_are_subtotals),
    ),
  )
  push_data_attr_opt(out, prefix + "-axis", area.axis)
  push_data_attr_int_opt(out, prefix + "-field-position", area.field_position)
  match area.references {
    None => ()
    Some(refs) => {
      out.push(
        svg_attr(
          prefix + "-references-count",
          refs.reference.length().to_string(),
        ),
      )
      push_data_attr_int_opt(
        out,
        prefix + "-references-declared-count",
        refs.count,
      )
      for i, reference in refs.reference {
        let ref_prefix = prefix + "-reference-" + i.to_string()
        push_data_attr_int_opt(out, ref_prefix + "-field", reference.field)
        push_data_attr_int_opt(
          out,
          ref_prefix + "-declared-count",
          reference.count,
        )
        out.push(
          svg_attr(ref_prefix + "-selected", bool_data_attr(reference.selected)),
        )
        out.push(
          svg_attr(ref_prefix + "-x-count", reference.x.length().to_string()),
        )
        for j, index in reference.x {
          let index_prefix = ref_prefix + "-x-" + j.to_string()
          emit_source_element_attrs(index_prefix, index.element, out)
          out.push(svg_attr(index_prefix + "-v", index.v.to_string()))
        }
      }
    }
  }
}

///|
fn emit_pivot_hierarchy_metadata_attrs(
  definition : @pivot_table.PivotTableDefinition,
  out : Array[@xml.Attribute],
) -> Unit {
  match definition.pivot_hierarchies {
    None => ()
    Some(hierarchies) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-hierarchies-count",
          hierarchies.pivot_hierarchies.length().to_string(),
        ),
      )
      push_data_attr_int_opt(
        out,
        "data-ooxml-pivot-hierarchies-declared-count",
        hierarchies.count,
      )
      for i, hierarchy in hierarchies.pivot_hierarchies {
        let prefix = "data-ooxml-pivot-hierarchy-" + i.to_string()
        push_data_attr_opt(out, prefix + "-caption", hierarchy.caption)
        out.push(
          svg_attr(prefix + "-outline", bool_data_attr(hierarchy.outline)),
        )
        out.push(
          svg_attr(
            prefix + "-multiple-item-selection-allowed",
            bool_data_attr(hierarchy.multiple_item_selection_allowed),
          ),
        )
        out.push(
          svg_attr(
            prefix + "-show-in-field-list",
            bool_data_attr(hierarchy.show_in_field_list),
          ),
        )
        match hierarchy.mps {
          None => ()
          Some(mps) => {
            out.push(
              svg_attr(prefix + "-mps-count", mps.mp.length().to_string()),
            )
            push_data_attr_int_opt(
              out,
              prefix + "-mps-declared-count",
              mps.count,
            )
            for j, mp in mps.mp {
              let mp_prefix = prefix + "-mp-" + j.to_string()
              out.push(svg_attr(mp_prefix + "-field", mp.field.to_string()))
              push_data_attr_opt(out, mp_prefix + "-name", mp.name)
              out.push(
                svg_attr(mp_prefix + "-show-cell", bool_data_attr(mp.show_cell)),
              )
              out.push(
                svg_attr(mp_prefix + "-show-tip", bool_data_attr(mp.show_tip)),
              )
              out.push(
                svg_attr(
                  mp_prefix + "-show-as-caption",
                  bool_data_attr(mp.show_as_caption),
                ),
              )
            }
          }
        }
        out.push(
          svg_attr(
            prefix + "-members-groups-count",
            hierarchy.members.length().to_string(),
          ),
        )
        for j, members in hierarchy.members {
          let members_prefix = prefix + "-members-" + j.to_string()
          push_data_attr_int_opt(
            out,
            members_prefix + "-declared-count",
            members.count,
          )
          push_data_attr_int_opt(out, members_prefix + "-level", members.level)
          out.push(
            svg_attr(
              members_prefix + "-member-count",
              members.member_entries.length().to_string(),
            ),
          )
          for k, member_entry in members.member_entries {
            out.push(
              svg_attr(
                members_prefix + "-member-" + k.to_string() + "-name",
                member_entry.name,
              ),
            )
          }
        }
      }
    }
  }
  match definition.row_hierarchies_usage {
    None => ()
    Some(usages) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-row-hierarchies-usage-count",
          usages.row_hierarchy_usages.length().to_string(),
        ),
      )
      push_data_attr_int_opt(
        out,
        "data-ooxml-pivot-row-hierarchies-usage-declared-count",
        usages.count,
      )
      for i, usage in usages.row_hierarchy_usages {
        out.push(
          svg_attr(
            "data-ooxml-pivot-row-hierarchy-usage-" +
            i.to_string() +
            "-hierarchy-usage",
            usage.hierarchy_usage.to_string(),
          ),
        )
      }
    }
  }
  match definition.col_hierarchies_usage {
    None => ()
    Some(usages) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-col-hierarchies-usage-count",
          usages.col_hierarchy_usage.length().to_string(),
        ),
      )
      push_data_attr_int_opt(
        out,
        "data-ooxml-pivot-col-hierarchies-usage-declared-count",
        usages.count,
      )
      for i, usage in usages.col_hierarchy_usage {
        out.push(
          svg_attr(
            "data-ooxml-pivot-col-hierarchy-usage-" +
            i.to_string() +
            "-hierarchy-usage",
            usage.hierarchy_usage.to_string(),
          ),
        )
      }
    }
  }
}

///|
fn emit_pivot_cache_metadata_attrs(
  cache : @pivot_table.PivotCacheDefinition,
  out : Array[@xml.Attribute],
) -> Unit {
  match cache.cache_hierarchies {
    None => ()
    Some(value) =>
      emit_sml_pivot_cache_hierarchies_metadata_attrs(
        "data-ooxml-pivot-cache-hierarchies", value, out,
      )
  }
  match cache.kpis {
    None => ()
    Some(value) =>
      emit_sml_pivot_kpis_metadata_attrs(
        "data-ooxml-pivot-cache-kpis", value, out,
      )
  }
  match cache.tuple_cache {
    None => ()
    Some(value) =>
      emit_sml_pivot_tuple_cache_metadata_attrs(
        "data-ooxml-pivot-cache-tuple-cache", value, out,
      )
  }
  match cache.calculated_items {
    None => ()
    Some(value) =>
      emit_sml_pivot_calculated_items_metadata_attrs(
        "data-ooxml-pivot-cache-calculated-items", value, out,
      )
  }
  match cache.calculated_members {
    None => ()
    Some(value) =>
      emit_sml_pivot_calculated_members_metadata_attrs(
        "data-ooxml-pivot-cache-calculated-members", value, out,
      )
  }
  match cache.dimensions {
    None => ()
    Some(dimensions) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-cache-dimensions-count",
          dimensions.dimension.length().to_string(),
        ),
      )
      push_data_attr_int_opt(
        out,
        "data-ooxml-pivot-cache-dimensions-declared-count",
        dimensions.count,
      )
      for i, dimension in dimensions.dimension {
        let prefix = "data-ooxml-pivot-cache-dimension-" + i.to_string()
        out.push(svg_attr(prefix + "-name", dimension.name))
        out.push(svg_attr(prefix + "-unique-name", dimension.unique_name))
        out.push(svg_attr(prefix + "-caption", dimension.caption))
        out.push(
          svg_attr(prefix + "-measure", bool_data_attr(dimension.measure)),
        )
      }
    }
  }
  match cache.measure_groups {
    None => ()
    Some(groups) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-cache-measure-groups-count",
          groups.measure_group.length().to_string(),
        ),
      )
      push_data_attr_int_opt(
        out,
        "data-ooxml-pivot-cache-measure-groups-declared-count",
        groups.count,
      )
      for i, group in groups.measure_group {
        let prefix = "data-ooxml-pivot-cache-measure-group-" + i.to_string()
        out.push(svg_attr(prefix + "-name", group.name))
        out.push(svg_attr(prefix + "-caption", group.caption))
      }
    }
  }
  match cache.maps {
    None => ()
    Some(maps) => {
      out.push(
        svg_attr(
          "data-ooxml-pivot-cache-maps-count",
          maps.map.length().to_string(),
        ),
      )
      push_data_attr_int_opt(
        out,
        "data-ooxml-pivot-cache-maps-declared-count",
        maps.count,
      )
      for i, map in maps.map {
        let prefix = "data-ooxml-pivot-cache-map-" + i.to_string()
        push_data_attr_int_opt(
          out,
          prefix + "-measure-group",
          map.measure_group,
        )
        push_data_attr_int_opt(out, prefix + "-dimension", map.dimension)
      }
    }
  }
}

///|
fn emit_sml_pivot_cache_hierarchies_metadata_attrs(
  prefix : String,
  value : @domain.CT_CacheHierarchies,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(
    svg_attr(prefix + "-count", value.cache_hierarchies.length().to_string()),
  )
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, hierarchy in value.cache_hierarchies {
    let hierarchy_prefix = prefix + "-hierarchy-" + i.to_string()
    emit_sml_pivot_cache_hierarchy_metadata_attrs(
      hierarchy_prefix, hierarchy, out,
    )
  }
}

///|
fn emit_sml_pivot_cache_hierarchy_metadata_attrs(
  prefix : String,
  hierarchy : @domain.CT_CacheHierarchy,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, hierarchy.element, out)
  out.push(svg_attr(prefix + "-unique-name", hierarchy.unique_name))
  push_data_attr_opt(out, prefix + "-caption", hierarchy.caption)
  out.push(svg_attr(prefix + "-measure", bool_data_attr(hierarchy.measure)))
  out.push(svg_attr(prefix + "-set", bool_data_attr(hierarchy.set_)))
  push_data_attr_int_opt(out, prefix + "-parent-set", hierarchy.parent_set)
  out.push(svg_attr(prefix + "-icon-set", hierarchy.icon_set.to_string()))
  out.push(svg_attr(prefix + "-attribute", bool_data_attr(hierarchy.attribute)))
  out.push(svg_attr(prefix + "-time", bool_data_attr(hierarchy.time)))
  out.push(
    svg_attr(prefix + "-key-attribute", bool_data_attr(hierarchy.key_attribute)),
  )
  push_data_attr_opt(
    out,
    prefix + "-default-member-unique-name",
    hierarchy.default_member_unique_name,
  )
  push_data_attr_opt(
    out,
    prefix + "-all-unique-name",
    hierarchy.all_unique_name,
  )
  push_data_attr_opt(out, prefix + "-all-caption", hierarchy.all_caption)
  push_data_attr_opt(
    out,
    prefix + "-dimension-unique-name",
    hierarchy.dimension_unique_name,
  )
  push_data_attr_opt(out, prefix + "-display-folder", hierarchy.display_folder)
  push_data_attr_opt(out, prefix + "-measure-group", hierarchy.measure_group)
  out.push(svg_attr(prefix + "-measures", bool_data_attr(hierarchy.measures)))
  out.push(svg_attr(prefix + "-count", hierarchy.count.to_string()))
  out.push(svg_attr(prefix + "-one-field", bool_data_attr(hierarchy.one_field)))
  push_data_attr_int_opt(
    out,
    prefix + "-member-value-datatype",
    hierarchy.member_value_datatype,
  )
  push_data_attr_bool_opt(out, prefix + "-unbalanced", hierarchy.unbalanced)
  push_data_attr_bool_opt(
    out,
    prefix + "-unbalanced-group",
    hierarchy.unbalanced_group,
  )
  out.push(svg_attr(prefix + "-hidden", bool_data_attr(hierarchy.hidden)))
  match hierarchy.fields_usage {
    None => ()
    Some(fields_usage) =>
      emit_sml_pivot_fields_usage_metadata_attrs(
        prefix + "-fields-usage",
        fields_usage,
        out,
      )
  }
  match hierarchy.group_levels {
    None => ()
    Some(group_levels) =>
      emit_sml_pivot_group_levels_metadata_attrs(
        prefix + "-group-levels",
        group_levels,
        out,
      )
  }
}

///|
fn emit_sml_pivot_fields_usage_metadata_attrs(
  prefix : String,
  value : @domain.CT_FieldsUsage,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(svg_attr(prefix + "-count", value.field_usage.length().to_string()))
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, usage in value.field_usage {
    let usage_prefix = prefix + "-field-usage-" + i.to_string()
    emit_source_element_attrs(usage_prefix, usage.element, out)
    out.push(svg_attr(usage_prefix + "-x", usage.x.to_string()))
  }
}

///|
fn emit_sml_pivot_group_levels_metadata_attrs(
  prefix : String,
  value : @domain.CT_GroupLevels,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(svg_attr(prefix + "-count", value.group_level.length().to_string()))
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, level in value.group_level {
    emit_sml_pivot_group_level_metadata_attrs(
      prefix + "-group-level-" + i.to_string(),
      level,
      out,
    )
  }
}

///|
fn emit_sml_pivot_group_level_metadata_attrs(
  prefix : String,
  level : @domain.CT_GroupLevel,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, level.element, out)
  out.push(svg_attr(prefix + "-unique-name", level.unique_name))
  out.push(svg_attr(prefix + "-caption", level.caption))
  out.push(svg_attr(prefix + "-user", bool_data_attr(level.user)))
  out.push(
    svg_attr(prefix + "-custom-roll-up", bool_data_attr(level.custom_roll_up)),
  )
  match level.groups {
    None => ()
    Some(groups) =>
      emit_sml_pivot_groups_metadata_attrs(prefix + "-groups", groups, out)
  }
}

///|
fn emit_sml_pivot_groups_metadata_attrs(
  prefix : String,
  value : @domain.CT_Groups,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(svg_attr(prefix + "-count", value.group.length().to_string()))
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, group in value.group {
    emit_sml_pivot_level_group_metadata_attrs(
      prefix + "-group-" + i.to_string(),
      group,
      out,
    )
  }
}

///|
fn emit_sml_pivot_level_group_metadata_attrs(
  prefix : String,
  group : @domain.CT_LevelGroup,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, group.element, out)
  out.push(svg_attr(prefix + "-name", group.name))
  out.push(svg_attr(prefix + "-unique-name", group.unique_name))
  out.push(svg_attr(prefix + "-caption", group.caption))
  push_data_attr_opt(out, prefix + "-unique-parent", group.unique_parent)
  push_data_attr_int_opt(out, prefix + "-id", group.id)
  emit_sml_pivot_group_members_metadata_attrs(
    prefix + "-group-members",
    group.group_members,
    out,
  )
}

///|
fn emit_sml_pivot_group_members_metadata_attrs(
  prefix : String,
  value : @domain.CT_GroupMembers,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(
    svg_attr(prefix + "-count", value.group_members.length().to_string()),
  )
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, group_member in value.group_members {
    let member_prefix = prefix + "-member-" + i.to_string()
    emit_source_element_attrs(member_prefix, group_member.element, out)
    out.push(svg_attr(member_prefix + "-unique-name", group_member.unique_name))
    out.push(
      svg_attr(member_prefix + "-group", bool_data_attr(group_member.group)),
    )
  }
}

///|
fn emit_sml_pivot_kpis_metadata_attrs(
  prefix : String,
  value : @domain.CT_PCDKPIs,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(svg_attr(prefix + "-count", value.kpis.length().to_string()))
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, kpi in value.kpis {
    let kpi_prefix = prefix + "-kpi-" + i.to_string()
    emit_source_element_attrs(kpi_prefix, kpi.element, out)
    out.push(svg_attr(kpi_prefix + "-unique-name", kpi.unique_name))
    out.push(svg_attr(kpi_prefix + "-value", kpi.value))
    push_data_attr_opt(out, kpi_prefix + "-caption", kpi.caption)
    push_data_attr_opt(out, kpi_prefix + "-display-folder", kpi.display_folder)
    push_data_attr_opt(out, kpi_prefix + "-measure-group", kpi.measure_group)
    push_data_attr_opt(out, kpi_prefix + "-parent", kpi.parent)
    push_data_attr_opt(out, kpi_prefix + "-goal", kpi.goal)
    push_data_attr_opt(out, kpi_prefix + "-status", kpi.status)
    push_data_attr_opt(out, kpi_prefix + "-trend", kpi.trend)
    push_data_attr_opt(out, kpi_prefix + "-weight", kpi.weight)
    push_data_attr_opt(out, kpi_prefix + "-time", kpi.time)
  }
}

///|
fn emit_sml_pivot_tuple_cache_metadata_attrs(
  prefix : String,
  value : @domain.CT_TupleCache,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  match value.entries {
    None => ()
    Some(entries) =>
      emit_sml_pivot_tuple_entries_metadata_attrs(
        prefix + "-entries",
        entries,
        out,
      )
  }
  match value.sets {
    None => ()
    Some(sets) =>
      emit_sml_pivot_sets_metadata_attrs(prefix + "-sets", sets, out)
  }
  match value.query_cache {
    None => ()
    Some(cache) =>
      emit_sml_pivot_query_cache_metadata_attrs(
        prefix + "-query-cache",
        cache,
        out,
      )
  }
  match value.server_formats {
    None => ()
    Some(formats) =>
      emit_sml_pivot_server_formats_metadata_attrs(
        prefix + "-server-formats",
        formats,
        out,
      )
  }
}

///|
fn emit_sml_pivot_tuple_entries_metadata_attrs(
  prefix : String,
  value : @domain.CT_PCDSDTCEntries,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  out.push(
    svg_attr(prefix + "-missing-count", value.missings.length().to_string()),
  )
  out.push(
    svg_attr(prefix + "-number-count", value.numbers.length().to_string()),
  )
  out.push(svg_attr(prefix + "-error-count", value.errors.length().to_string()))
  out.push(
    svg_attr(prefix + "-string-count", value.strings.length().to_string()),
  )
  for i, missing in value.missings {
    emit_source_element_attrs(
      prefix + "-missing-" + i.to_string(),
      missing.element,
      out,
    )
  }
  for i, number in value.numbers {
    emit_source_element_attrs(
      prefix + "-number-" + i.to_string(),
      number.element,
      out,
    )
  }
  for i, error in value.errors {
    emit_source_element_attrs(
      prefix + "-error-" + i.to_string(),
      error.element,
      out,
    )
  }
  for i, string in value.strings {
    emit_source_element_attrs(
      prefix + "-string-" + i.to_string(),
      string.element,
      out,
    )
  }
}

///|
fn emit_sml_pivot_sets_metadata_attrs(
  prefix : String,
  value : @domain.CT_Sets,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(svg_attr(prefix + "-count", value.sets.length().to_string()))
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, set in value.sets {
    emit_sml_pivot_set_metadata_attrs(
      prefix + "-set-" + i.to_string(),
      set,
      out,
    )
  }
}

///|
fn emit_sml_pivot_set_metadata_attrs(
  prefix : String,
  set : @domain.CT_Set,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, set.element, out)
  push_data_attr_int_opt(out, prefix + "-count", set.count)
  out.push(svg_attr(prefix + "-max-rank", set.max_rank.to_string()))
  out.push(svg_attr(prefix + "-set-definition", set.set_definition))
  push_data_attr_opt(out, prefix + "-sort-type", set.sort_type)
  out.push(svg_attr(prefix + "-query-failed", bool_data_attr(set.query_failed)))
  out.push(svg_attr(prefix + "-tpls-count", set.tpls.length().to_string()))
  for i, tuples in set.tpls {
    emit_sml_pivot_tuples_metadata_attrs(
      prefix + "-tpls-" + i.to_string(),
      tuples,
      out,
    )
  }
  match set.sort_by_tuple {
    None => ()
    Some(tuples) =>
      emit_sml_pivot_tuples_metadata_attrs(
        prefix + "-sort-by-tuple",
        tuples,
        out,
      )
  }
}

///|
fn emit_sml_pivot_tuples_metadata_attrs(
  prefix : String,
  tuples : @domain.CT_Tuples,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, tuples.element, out)
  push_data_attr_int_opt(out, prefix + "-declared-count", tuples.c)
  out.push(svg_attr(prefix + "-tuple-count", tuples.tpls.length().to_string()))
  for i, tuple in tuples.tpls {
    let tuple_prefix = prefix + "-tuple-" + i.to_string()
    emit_source_element_attrs(tuple_prefix, tuple.element, out)
    push_data_attr_int_opt(out, tuple_prefix + "-field", tuple.fld)
    push_data_attr_int_opt(out, tuple_prefix + "-hierarchy", tuple.hier)
    out.push(svg_attr(tuple_prefix + "-item", tuple.item.to_string()))
  }
}

///|
fn emit_sml_pivot_query_cache_metadata_attrs(
  prefix : String,
  value : @domain.CT_QueryCache,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(svg_attr(prefix + "-count", value.queries.length().to_string()))
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, query in value.queries {
    let query_prefix = prefix + "-query-" + i.to_string()
    emit_source_element_attrs(query_prefix, query.element, out)
    out.push(svg_attr(query_prefix + "-mdx", query.mdx))
    match query.tpls {
      None => ()
      Some(tuples) =>
        emit_sml_pivot_tuples_metadata_attrs(
          query_prefix + "-tpls",
          tuples,
          out,
        )
    }
  }
}

///|
fn emit_sml_pivot_server_formats_metadata_attrs(
  prefix : String,
  value : @domain.CT_ServerFormats,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(
    svg_attr(prefix + "-count", value.server_format.length().to_string()),
  )
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, format in value.server_format {
    let format_prefix = prefix + "-server-format-" + i.to_string()
    emit_source_element_attrs(format_prefix, format.element, out)
    push_data_attr_opt(out, format_prefix + "-culture", format.culture)
    push_data_attr_opt(out, format_prefix + "-format", format.format)
  }
}

///|
fn emit_sml_pivot_calculated_items_metadata_attrs(
  prefix : String,
  value : @domain.CT_CalculatedItems,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(
    svg_attr(prefix + "-count", value.calculated_items.length().to_string()),
  )
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, item in value.calculated_items {
    let item_prefix = prefix + "-item-" + i.to_string()
    emit_source_element_attrs(item_prefix, item.element, out)
    push_data_attr_int_opt(out, item_prefix + "-field", item.field)
    push_data_attr_opt(out, item_prefix + "-formula", item.formula)
    match item.pivot_area {
      None => ()
      Some(area) => emit_pivot_area_attrs(area, item_prefix + "-area", out)
    }
  }
}

///|
fn emit_sml_pivot_calculated_members_metadata_attrs(
  prefix : String,
  value : @domain.CT_CalculatedMembers,
  out : Array[@xml.Attribute],
) -> Unit {
  emit_source_element_attrs(prefix, value.element, out)
  out.push(
    svg_attr(prefix + "-count", value.calculated_members.length().to_string()),
  )
  push_data_attr_int_opt(out, prefix + "-declared-count", value.count)
  for i, calculated_member in value.calculated_members {
    let member_prefix = prefix + "-member-" + i.to_string()
    emit_source_element_attrs(member_prefix, calculated_member.element, out)
    out.push(svg_attr(member_prefix + "-name", calculated_member.name))
    out.push(svg_attr(member_prefix + "-mdx", calculated_member.mdx))
    push_data_attr_opt(
      out,
      member_prefix + "-member-name",
      calculated_member.member_name,
    )
    push_data_attr_opt(
      out,
      member_prefix + "-hierarchy",
      calculated_member.hierarchy,
    )
    push_data_attr_opt(out, member_prefix + "-parent", calculated_member.parent)
    out.push(
      svg_attr(
        member_prefix + "-solve-order",
        calculated_member.solve_order.to_string(),
      ),
    )
    out.push(
      svg_attr(member_prefix + "-set", bool_data_attr(calculated_member.set_)),
    )
  }
}

///|
/// Emit one pivot cell — a `<rect>` background, optional border
/// strokes for the grand-total bands, and a `<text>` carrying the
/// label centred-vertically within the cell. The cell stays inside
/// a single `<g>` so the consumer can group / hide them per pivot.
/// §18.3.1.18 — resolve any worksheet conditional-formatting that
/// covers a pivot VALUE cell at sheet position `(abs_row, abs_col)`
/// (Excel stores pivot CF as a `<conditionalFormatting>` block whose
/// sqref covers the pivot region, cross-referenced by the pivot's
/// `<conditionalFormats>` priority).  Synthesizes a one-cell `<c>` from
/// the aggregated numeric value and reuses the same `apply_cf_overlay`
/// evaluator as ordinary cells, returning `(dxf fill override, font
/// override)` for `pivot_cell`.  Non-numeric values get no CF.
fn pivot_value_cf_style(
  abs_row : Int,
  abs_col : Int,
  value : @formula.FormulaValue,
  options : SheetRenderOptions,
  cf_blocks : Array[@domain.CT_ConditionalFormatting],
  cf_stats : Array[CfRulePopulation],
  styles : @domain.CT_Stylesheet?,
  shared_strings : @domain.CT_Sst?,
  theme_map : SmlThemeColorMap,
  theme_fonts : SmlThemeFontMap,
) -> (String?, ResolvedFont?) {
  if cf_blocks.length() == 0 {
    return (None, None)
  }
  guard value is @formula.VNumber(num) else { return (None, None) }
  let letter = (try? @address.column_index_to_letter(abs_col)).to_option()
  let cell_ref = match letter {
    Some(l) => l + (abs_row + 1).to_string()
    None => return (None, None)
  }
  // Synthesize `<c r="…"><v>num</v></c>` so the shared CF evaluator can
  // read the cell value through its usual `<v>` path.
  let v_el : @xml.Element = {
    name: { prefix: None, local_name: "v", ns: None },
    attributes: [],
    children: [@xml.Node::Text(num.to_string())],
  }
  let c_el : @xml.Element = {
    name: { prefix: None, local_name: "c", ns: None },
    attributes: [
      { name: { prefix: None, local_name: "r", ns: None }, value: cell_ref },
    ],
    children: [@xml.Node::Element(v_el)],
  }
  let base = default_cell_style(options)
  let styled = apply_cf_overlay(
    cell_ref,
    c_el,
    base,
    cf_blocks,
    cf_stats,
    styles,
    shared_strings,
    theme_map~,
    theme_fonts~,
  )
  let fill = match styled.fill {
    FillSolid(c) => Some(c)
    _ => None
  }
  let font = if resolved_font_eq(styled.font, base.font) {
    None
  } else {
    Some(styled.font)
  }
  (fill, font)
}

///|
/// §18.10.1.30 / §18.10.1.65 / §18.10.1.66 — PivotTable `<format>`
/// entries apply a stylesheet `<dxf>` to cells selected by their
/// `<pivotArea>`.  This renderer supports the data-area path used by
/// value cells: a `type="data"` area optionally narrows the match with
/// `<reference field="…"><x v="…"/></reference>` constraints whose
/// `v` values are the same shared-item indices carried by
/// `PivotAxisKey::Items`.
fn pivot_value_format_style(
  pivot : @pivot_table.MaterializedPivotTable,
  row_key : @pivot_table.PivotAxisKey,
  col_key : @pivot_table.PivotAxisKey,
  options : SheetRenderOptions,
  styles : @domain.CT_Stylesheet?,
  theme_map : SmlThemeColorMap,
  theme_fonts : SmlThemeFontMap,
) -> (String?, ResolvedFont?) {
  let formats = match pivot.definition.formats {
    Some(value) => value
    None => return (None, None)
  }
  let dxfs = match styles {
    Some(sheet_styles) =>
      match sheet_styles.dxfs {
        Some(value) => value
        None => return (None, None)
      }
    None => return (None, None)
  }
  let base = default_cell_style(options)
  let mut styled = base
  let mut changed = false
  for format in formats.format {
    if format.action != "formatting" {
      continue
    }
    let dxf_id = match format.dxf_id {
      Some(value) => value
      None => continue
    }
    if dxf_id < 0 || dxf_id >= dxfs.dxf.length() {
      continue
    }
    if !pivot_format_area_matches_value_cell(
        format.pivot_area,
        pivot.definition,
        row_key,
        col_key,
      ) {
      continue
    }
    styled = overlay_dxf_on_style(
      styled,
      dxfs.dxf[dxf_id],
      theme_map~,
      theme_fonts~,
    )
    changed = true
  }
  if !changed {
    return (None, None)
  }
  let fill = match styled.fill {
    FillSolid(color) => Some(color)
    _ => None
  }
  let font = if resolved_font_eq(styled.font, base.font) {
    None
  } else {
    Some(styled.font)
  }
  (fill, font)
}

///|
fn pivot_format_area_matches_value_cell(
  area : @domain.CT_PivotArea,
  definition : @pivot_table.PivotTableDefinition,
  row_key : @pivot_table.PivotAxisKey,
  col_key : @pivot_table.PivotAxisKey,
) -> Bool {
  if area.type_ != "data" {
    return false
  }
  match area.references {
    None => true
    Some(refs) => {
      if refs.reference.length() == 0 {
        return true
      }
      for reference in refs.reference {
        if !pivot_format_reference_matches_value_cell(
            reference, definition, row_key, col_key,
          ) {
          return false
        }
      }
      true
    }
  }
}

///|
fn pivot_format_reference_matches_value_cell(
  reference : @domain.CT_PivotAreaReference,
  definition : @pivot_table.PivotTableDefinition,
  row_key : @pivot_table.PivotAxisKey,
  col_key : @pivot_table.PivotAxisKey,
) -> Bool {
  let field = match reference.field {
    Some(value) => value
    None => return true
  }
  let item = match
    pivot_axis_field_item(definition.row_fields, field, row_key) {
    Some(value) => Some(value)
    None => pivot_axis_field_item(definition.col_fields, field, col_key)
  }
  match item {
    Some(value) =>
      if reference.x.length() == 0 {
        reference.count.unwrap_or(0) == 0
      } else {
        pivot_reference_indexes_contain(reference.x, value)
      }
    None => false
  }
}

///|
fn pivot_axis_field_item(
  axis_fields : Array[Int],
  field : Int,
  key : @pivot_table.PivotAxisKey,
) -> Int? {
  let mut position = 0
  for axis_field in axis_fields {
    if axis_field == -2 {
      continue
    }
    if axis_field == field {
      return pivot_axis_key_item_at(key, position)
    }
    position = position + 1
  }
  None
}

///|
fn pivot_axis_key_item_at(
  key : @pivot_table.PivotAxisKey,
  position : Int,
) -> Int? {
  match key {
    @pivot_table.PivotAxisKey::Items(indices) =>
      if position >= 0 && position < indices.length() {
        Some(indices[position])
      } else {
        None
      }
    @pivot_table.PivotAxisKey::RowSubtotal(prefix) =>
      if position >= 0 && position < prefix.length() {
        Some(prefix[position])
      } else {
        None
      }
    _ => None
  }
}

///|
fn pivot_reference_indexes_contain(
  indexes : Array[@domain.CT_Index],
  value : Int,
) -> Bool {
  for index in indexes {
    if index.v == value {
      return true
    }
  }
  false
}

///|
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
  fill_override? : String? = None,
  text_color? : String = "#000000",
  text_font? : ResolvedFont? = None,
) -> @xml.Node {
  let kids : Array[@xml.Node] = []
  // §18.3.1.18 — a conditional-format dxf fill (resolved by the caller
  // from the worksheet CF covering the pivot region) overrides the
  // default header / totals / body background.
  let fill = match fill_override {
    Some(c) => c
    None =>
      if overall {
        "#D9D9D9"
      } else if bold {
        "#F2F2F2"
      } else {
        "#FFFFFF"
      }
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
    let font_family = match text_font {
      Some(font) => "'" + font.family + "', sans-serif"
      None => options.default_font_family
    }
    let font_size = match text_font {
      Some(font) => font.size
      None => options.default_font_size
    }
    let resolved_text_color = match text_font {
      Some(font) =>
        match font.color {
          Some(color) => color
          None => text_color
        }
      None => text_color
    }
    let text_attrs : Array[@xml.Attribute] = [
      svg_attr("x", format_d(x + padding)),
      svg_attr("y", format_d(y + h / 2.0 + font_size * 0.35)),
      svg_attr("font-family", font_family),
      svg_attr("font-size", format_d(font_size)),
      svg_attr("fill", resolved_text_color),
    ]
    let font_bold = match text_font {
      Some(font) => font.bold
      None => false
    }
    if bold || font_bold {
      text_attrs.push(svg_attr("font-weight", "bold"))
    }
    match text_font {
      Some(font) => {
        if font.italic {
          text_attrs.push(svg_attr("font-style", "italic"))
        }
        let decorations : Array[String] = []
        if font.underline {
          decorations.push("underline")
        }
        if font.strikethrough {
          decorations.push("line-through")
        }
        if decorations.length() > 0 {
          let mut decoration = ""
          let mut first = true
          for part in decorations {
            if first {
              first = false
              decoration = part
            } else {
              decoration = decoration + " " + part
            }
          }
          text_attrs.push(svg_attr("text-decoration", decoration))
        }
      }
      None => ()
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
/// column using the same default-width + Normal-style MDW path as
/// `compute_sheet_layout`.
fn pivot_column_geometry(
  layout : SheetLayout,
  options : SheetRenderOptions,
  col_zero : Int,
  max_digit_width_px~ : Double,
) -> (Double, Double) {
  let default_w = column_width_to_pixels(
    options.default_column_width,
    mdw_px=max_digit_width_px,
  )
  if col_zero < layout.column_positions.length() {
    (layout.column_positions[col_zero], layout.column_widths[col_zero])
  } else {
    // Extend past the worksheet's nominal dimension using the
    // renderer's default column width — matches how the reference renderer's
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
fn pivot_axis_real_positions(field_list : Array[Int]) -> Array[Int] {
  let positions : Array[Int] = []
  for axis_idx in field_list {
    if axis_idx != -2 {
      positions.push(axis_idx)
    }
  }
  positions
}

///|
fn pivot_data_on_rows_slots(field_list : Array[Int]) -> Array[Int] {
  let slots : Array[Int] = []
  let mut has_data_slot = false
  for axis_idx in field_list {
    if axis_idx == -2 {
      if !has_data_slot {
        slots.push(axis_idx)
        has_data_slot = true
      }
    } else {
      slots.push(axis_idx)
    }
  }
  if !has_data_slot {
    slots.push(-2)
  }
  slots
}

///|
fn pivot_axis_slot_captions(
  cache : @pivot_table.PivotCacheDefinition,
  definition : @pivot_table.PivotTableDefinition,
  slots : Array[Int],
) -> Array[String] {
  let captions : Array[String] = []
  for slot in slots {
    if slot == -2 {
      let caption = match definition.data_caption {
        Some(v) => v
        None => "Values"
      }
      captions.push(caption)
    } else if slot >= 0 && slot < cache.cache_fields.length() {
      let field = cache.cache_fields[slot]
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
fn pivot_axis_slot_ordinal(positions : Array[Int], slot : Int) -> Int? {
  for i, position in positions {
    if position == slot {
      return Some(i)
    }
  }
  None
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
  pivot_axis_slot_captions(cache, definition, field_list)
}

///|
/// Build the labels for each materialized axis key. `Items(indices)`
/// joins the resolved shared-item captions with " / "; `RowSubtotal`
/// labels the subtotaled group; `RowGrand` / `ColGrand` use the spec's
/// "Grand Total" caption (the spec allows override via
/// `<pivotField/@grandTotalCaption>` per §18.10.1.73, but we leave the
/// default — fixture comments call this out).
fn pivot_axis_key_labels(
  keys : Array[@pivot_table.PivotAxisKey],
  pivot : @pivot_table.MaterializedPivotTable,
  field_list : Array[Int],
) -> Array[String] {
  let labels : Array[String] = []
  let positions = pivot_axis_real_positions(field_list)
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
      @pivot_table.PivotAxisKey::RowSubtotal(prefix) =>
        labels.push(pivot_row_subtotal_label(prefix, pivot, positions))
      @pivot_table.PivotAxisKey::RowGrand => labels.push("Grand Total")
      @pivot_table.PivotAxisKey::ColGrand => labels.push("Grand Total")
    }
  }
  labels
}

///|
/// §18.10.1.44 — per-FIELD captions for each axis key (one entry per
/// row/col field position), used for the multi-level TABULAR layout
/// where each field occupies its own leading column.  A grand-total
/// key yields a single subtotal / grand-total element.
fn pivot_axis_key_field_labels(
  keys : Array[@pivot_table.PivotAxisKey],
  pivot : @pivot_table.MaterializedPivotTable,
  field_list : Array[Int],
) -> Array[Array[String]] {
  let positions = pivot_axis_real_positions(field_list)
  let out : Array[Array[String]] = []
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
        out.push(parts)
      }
      @pivot_table.PivotAxisKey::RowSubtotal(prefix) =>
        out.push([pivot_row_subtotal_label(prefix, pivot, positions)])
      @pivot_table.PivotAxisKey::RowGrand
      | @pivot_table.PivotAxisKey::ColGrand => out.push(["Grand Total"])
    }
  }
  out
}

///|
fn pivot_row_subtotal_label(
  prefix : Array[Int],
  pivot : @pivot_table.MaterializedPivotTable,
  positions : Array[Int],
) -> String {
  if prefix.length() == 0 {
    return pivot_row_subtotal_caption(prefix, pivot, positions)
  }
  let last = prefix.length() - 1
  let base = if last < positions.length() {
    pivot_shared_item_caption(pivot.cache, positions[last], prefix[last])
  } else {
    ""
  }
  let caption = pivot_row_subtotal_caption(prefix, pivot, positions)
  if base.length() == 0 {
    caption
  } else if caption.length() == 0 {
    base
  } else {
    base + " " + caption
  }
}

///|
fn pivot_row_subtotal_caption(
  prefix : Array[Int],
  pivot : @pivot_table.MaterializedPivotTable,
  positions : Array[Int],
) -> String {
  if prefix.length() > 0 {
    let ordinal = prefix.length() - 1
    if ordinal < positions.length() {
      match pivot.definition.pivot_fields.get(positions[ordinal]) {
        Some(field) =>
          match field.subtotal_caption {
            Some(caption) => return caption
            None => ()
          }
        None => ()
      }
    }
  }
  "Result"
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
  cache.shared_item_caption(field_idx, item_idx)
}

///|
/// §18.10.1.22 — collect the display names for every data field. The
/// `@name` attribute overrides; fallback uses the cacheField name
/// prefixed by the consolidation function (matches Excel's default
/// "Sum of Sales" / "Count of Orders" caption).
fn pivot_data_field_names(
  pivot : @pivot_table.MaterializedPivotTable,
) -> Array[String] {
  @pivot_table.data_field_display_names(pivot.definition, pivot.cache)
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
fn pivot_axis_key_is_row_subtotal(key : @pivot_table.PivotAxisKey) -> Bool {
  match key {
    @pivot_table.PivotAxisKey::RowSubtotal(_) => true
    _ => false
  }
}

///|
/// Format a `@formula.FormulaValue` into the cell-display string used
/// for pivot value cells. Numbers use the spec's General format
/// (drop trailing `.0` for integers); booleans use TRUE/FALSE;
/// errors use the spec literal (`#DIV/0!`, `#N/A`, …).
fn format_pivot_value(value : @formula.FormulaValue) -> String {
  match value {
    @formula.VNumber(n) => @pivot_table.format_pivot_number(n)
    @formula.VString(s) => s
    @formula.VBool(true) => "TRUE"
    @formula.VBool(false) => "FALSE"
    @formula.VError(err) => @formula.FormulaError::to_literal(err)
    @formula.VEmpty => ""
    @formula.VArray(_) => ""
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
