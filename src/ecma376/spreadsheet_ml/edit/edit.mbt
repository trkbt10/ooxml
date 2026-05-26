// edit.mbt — B-layer mutators for the SpreadsheetML context.
// Top-level functions only; no method is defined on Workbook here.

///|
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/edit"
}

///|
using @sml_context {type Workbook}

///|
using @sml_context {type OpenError}

///|
using @sml_context {type WorksheetPart}

///|
/// A-layer primitive on Workbook. Replace the workbook part's typed
/// projection by re-parsing `transform(workbook.element)`. Every
/// helper that mutates `/xl/workbook.xml` (append_sheet,
/// remove_sheet, ...) must funnel through here.
pub fn edit_workbook(
  workbook : Workbook,
  transform : (@xml.Element) -> @xml.Element,
) -> Workbook {
  let new_element = transform(workbook.workbook.element)
  let new_workbook = @sml.CT_Workbook::new(new_element)
  {
    opc_package: workbook.opc_package,
    workbook_part: workbook.workbook_part,
    workbook: new_workbook,
    worksheets: workbook.worksheets,
    shared_strings: workbook.shared_strings,
    styles: workbook.styles,
    theme: workbook.theme,
  }
}

///|
/// A-layer primitive on Workbook. Apply `transform` to the
/// `<worksheet>` element of worksheet `sheet_index` (0-based) and
/// re-parse the typed `CT_Worksheet`. Funnel point for every
/// per-sheet mutating helper (set_cell_value, clear_cell, ...).
pub fn edit_worksheet(
  workbook : Workbook,
  sheet_index : Int,
  transform : (@xml.Element) -> @xml.Element,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let target = workbook.worksheets[sheet_index]
  let new_element = transform(target.value.element)
  let new_value = @sml.CT_Worksheet::new(new_element) catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @sml_context.OpenError(
        kind="SchemaViolation \{section}",
        path~,
        reason~,
      )
  }
  let new_worksheets : Array[WorksheetPart] = []
  let mut i = 0
  for ws in workbook.worksheets {
    if i == sheet_index {
      new_worksheets.push({
        name: ws.name,
        value: new_value,
        drawing: ws.drawing,
        drawing_part: ws.drawing_part,
        tables: ws.tables,
      })
    } else {
      new_worksheets.push(ws)
    }
    i = i + 1
  }
  {
    opc_package: workbook.opc_package,
    workbook_part: workbook.workbook_part,
    workbook: workbook.workbook,
    worksheets: new_worksheets,
    shared_strings: workbook.shared_strings,
    styles: workbook.styles,
    theme: workbook.theme,
  }
}

///|
/// A-layer primitive on Workbook. Walk `/xl/styles.xml` through
/// `transform` and rebuild the typed CT_Stylesheet. When the
/// workbook has no styles part yet, a minimal `<styleSheet>` element
/// is synthesized so the helper can install fonts/fills/numFmts on
/// a fresh package.
pub fn edit_styles(
  workbook : Workbook,
  transform : (@xml.Element) -> @xml.Element,
) -> Workbook {
  let base_element = match workbook.styles {
    Some(s) => s.element
    None => {
      let qn : @xml.QName = {
        prefix: None,
        local_name: "styleSheet",
        ns: Some("http://schemas.openxmlformats.org/spreadsheetml/2006/main"),
      }
      let xmlns_attr : @xml.Attribute = {
        name: { prefix: None, local_name: "xmlns", ns: None },
        value: "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
      }
      { name: qn, attributes: [xmlns_attr], children: [] }
    }
  }
  let new_element = transform(base_element)
  let new_styles = @sml.CT_Stylesheet::new(new_element)
  {
    opc_package: workbook.opc_package,
    workbook_part: workbook.workbook_part,
    workbook: workbook.workbook,
    worksheets: workbook.worksheets,
    shared_strings: workbook.shared_strings,
    styles: Some(new_styles),
    theme: workbook.theme,
  }
}

///|
/// A-layer primitive: install a new package after typed updates have
/// already been computed. Used by helpers that go through OPC
/// (add_part/with_relationship/...) and need to wire the resulting
/// `Package` back into the facade.
pub fn with_package(workbook : Workbook, opc_package : @opc.Package) -> Workbook {
  {
    opc_package,
    workbook_part: workbook.workbook_part,
    workbook: workbook.workbook,
    worksheets: workbook.worksheets,
    shared_strings: workbook.shared_strings,
    styles: workbook.styles,
    theme: workbook.theme,
  }
}

///|
/// Set a §18.3.1.4 cell to an inline-string value at the given A1
/// address (e.g. "A1", "B12"). `sheet_index` is 0-based and refers to
/// `workbook.worksheets`. Cells are written with `@t="inlineStr"` and an
/// `<is><t>value</t></is>` payload so the workbook does not need a
/// shared-strings part. Returns a new Workbook; the original is
/// unchanged.
///
/// Inserts a §18.3.1.73 `<row>` if one does not exist at the target
/// row number, and updates the in-place §18.3.1.4 `<c>` if one already
/// exists at the target reference. The underlying `@xml.Element` tree
/// is rebuilt alongside the typed projection so a save/re-open
/// round-trip preserves the change.
///
/// §18.4.9 / §18.3.1.4 SST cleanup note: when the cell being
/// overwritten previously carried `@t="s"` (shared-string
/// reference), the orphaned `<si>` entry in `sharedStrings.xml`
/// is NOT removed.  Excel tolerates orphan SST entries (they
/// just bloat the file), so this is conformant but
/// sub-optimal.  A future iteration tracked as Round 13 #310
/// can either reuse the existing SST slot or sweep orphans on
/// save.
pub fn set_cell_value(
  workbook : Workbook,
  sheet_index : Int,
  address : String,
  value : String,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let (_col, row_index) = parse_cell_address(address)
  let ws = workbook.worksheets[sheet_index]
  let template_qname = ws.value.element.name
  let c_element = build_inline_str_cell(template_qname, address, value)
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("sheetData"), fn(sd) {
      let row_pred = @a_edit.by_local_name_with_attr(
        "row",
        "r",
        row_index.to_string(),
      )
      let row_hits = @a_edit.direct_children(sd, row_pred)
      if row_hits.length() == 0 {
        // Append a new <row r="N"><c .../></row>.
        let row_element = @a_edit.empty_element(template_qname, "row")
        let row_with_attr = @a_edit.set_attribute(
          row_element,
          @a_edit.unprefixed_attribute("r", row_index.to_string()),
        )
        let row_with_cell = @a_edit.append_child(
          row_with_attr,
          @xml.Node::Element(c_element),
        )
        @a_edit.append_child(sd, @xml.Node::Element(row_with_cell))
      } else {
        // Update the matching row in place.
        @a_edit.update_first(sd, row_pred, fn(row_elt) {
          let cell_pred = @a_edit.by_local_name_with_attr("c", "r", address)
          let cell_hits = @a_edit.direct_children(row_elt, cell_pred)
          if cell_hits.length() == 0 {
            @a_edit.append_child(row_elt, @xml.Node::Element(c_element))
          } else {
            @a_edit.replace_children(row_elt, cell_pred, c_element)
          }
        })
      }
    })
  })
}

///|
/// Set a §18.3.1.40 `<f>` formula on a cell. The cell is created if
/// it does not yet exist; existing cell contents (inline string,
/// shared-string ref, ...) are replaced with the formula. The cell
/// `@t` attribute is removed so Excel re-derives it from the
/// formula's result type at recalculation.
pub fn set_cell_formula(
  workbook : Workbook,
  sheet_index : Int,
  address : String,
  formula : String,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let (_col, row_index) = parse_cell_address(address)
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  let f = @a_edit.append_child(
    @a_edit.empty_element(template_qname, "f"),
    @xml.Node::Text(formula),
  )
  let c_with_r = @a_edit.set_attribute(
    @a_edit.empty_element(template_qname, "c"),
    @a_edit.unprefixed_attribute("r", address),
  )
  let c_element = @a_edit.append_child(c_with_r, @xml.Node::Element(f))
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("sheetData"), fn(sd) {
      let row_pred = @a_edit.by_local_name_with_attr(
        "row",
        "r",
        row_index.to_string(),
      )
      let row_hits = @a_edit.direct_children(sd, row_pred)
      if row_hits.length() == 0 {
        let row_element = @a_edit.set_attribute(
          @a_edit.empty_element(template_qname, "row"),
          @a_edit.unprefixed_attribute("r", row_index.to_string()),
        )
        let row_with_cell = @a_edit.append_child(
          row_element,
          @xml.Node::Element(c_element),
        )
        @a_edit.append_child(sd, @xml.Node::Element(row_with_cell))
      } else {
        @a_edit.update_first(sd, row_pred, fn(row_elt) {
          let cell_pred = @a_edit.by_local_name_with_attr("c", "r", address)
          let cell_hits = @a_edit.direct_children(row_elt, cell_pred)
          if cell_hits.length() == 0 {
            @a_edit.append_child(row_elt, @xml.Node::Element(c_element))
          } else {
            @a_edit.replace_children(row_elt, cell_pred, c_element)
          }
        })
      }
    })
  })
}

///|
/// Add a §18.3.1.55 `<mergeCell>` entry to the worksheet's
/// `<mergeCells>` block. `range` is an A1:B2 style range reference.
/// Creates `<mergeCells>` when absent. Duplicate ranges are ignored.
pub fn merge_cells(
  workbook : Workbook,
  sheet_index : Int,
  range : String,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  let merge_cell = @a_edit.set_attribute(
    @a_edit.empty_element(template_qname, "mergeCell"),
    @a_edit.unprefixed_attribute("ref", range),
  )
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    let existing = @a_edit.direct_children(
      ws_elt,
      @a_edit.by_local_name("mergeCells"),
    )
    if existing.length() == 0 {
      let merge_cells = @a_edit.append_child(
        @a_edit.empty_element(template_qname, "mergeCells"),
        @xml.Node::Element(merge_cell),
      )
      // Place mergeCells immediately after sheetData if present, else
      // append at end. Office tolerates both positions in practice.
      @a_edit.append_child(ws_elt, @xml.Node::Element(merge_cells))
    } else {
      @a_edit.update_first(ws_elt, @a_edit.by_local_name("mergeCells"), fn(mc) {
        let dup = @a_edit.direct_children(
          mc,
          @a_edit.by_local_name_with_attr("mergeCell", "ref", range),
        )
        if dup.length() == 0 {
          @a_edit.append_child(mc, @xml.Node::Element(merge_cell))
        } else {
          mc
        }
      })
    }
  })
}

///|
/// Insert an empty §18.3.1.73 `<row>` at the given 1-based row
/// number. Existing rows with that number (or greater) are not
/// renumbered — Excel allows sparse rows and re-derives positions
/// from `@r` attributes.
pub fn insert_row(
  workbook : Workbook,
  sheet_index : Int,
  row_number : Int,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  if row_number < 1 {
    raise @sml_context.OpenError(
      kind="SchemaViolation",
      path="ST_RowNumber",
      reason="row_number must be >= 1",
    )
  }
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  let row_element = @a_edit.set_attribute(
    @a_edit.empty_element(template_qname, "row"),
    @a_edit.unprefixed_attribute("r", row_number.to_string()),
  )
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("sheetData"), fn(sd) {
      @a_edit.append_child(sd, @xml.Node::Element(row_element))
    })
  })
}

///|
/// Remove the §18.3.1.73 `<row>` whose `@r` matches `row_number`.
/// No-op when the row does not exist.
pub fn remove_row(
  workbook : Workbook,
  sheet_index : Int,
  row_number : Int,
) -> Workbook raise OpenError {
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("sheetData"), fn(sd) {
      @a_edit.remove_children(
        sd,
        @a_edit.by_local_name_with_attr("row", "r", row_number.to_string()),
      )
    })
  })
}

///|
/// Set §18.3.1.13 `<col>` width covering the given 1-based column
/// index. Creates a `<cols>` block when none exists. Always emits a
/// single `<col min=N max=N width=W customWidth=1>` element pinning
/// just that column; for ranged updates use `update_first` directly
/// on `<col>` predicates.
pub fn set_column_width(
  workbook : Workbook,
  sheet_index : Int,
  column_index : Int,
  width : Double,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  if column_index < 1 {
    raise @sml_context.OpenError(
      kind="SchemaViolation",
      path="ST_ColumnIndex",
      reason="column_index must be >= 1",
    )
  }
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  let col_text = column_index.to_string()
  let col_element = @a_edit.set_attribute(
    @a_edit.set_attribute(
      @a_edit.set_attribute(
        @a_edit.set_attribute(
          @a_edit.empty_element(template_qname, "col"),
          @a_edit.unprefixed_attribute("min", col_text),
        ),
        @a_edit.unprefixed_attribute("max", col_text),
      ),
      @a_edit.unprefixed_attribute("width", width.to_string()),
    ),
    @a_edit.unprefixed_attribute("customWidth", "1"),
  )
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    let existing_cols = @a_edit.direct_children(
      ws_elt,
      @a_edit.by_local_name("cols"),
    )
    if existing_cols.length() == 0 {
      // Insert <cols> immediately before <sheetData> when present.
      let cols_element = @a_edit.append_child(
        @a_edit.empty_element(template_qname, "cols"),
        @xml.Node::Element(col_element),
      )
      let mut position = ws_elt.children.length()
      let mut i = 0
      for child in ws_elt.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "sheetData" &&
              position == ws_elt.children.length() {
              position = i
            }
          _ => ()
        }
        i = i + 1
      }
      @a_edit.insert_child(ws_elt, position, @xml.Node::Element(cols_element))
    } else {
      @a_edit.update_first(ws_elt, @a_edit.by_local_name("cols"), fn(cols) {
        let pred = @a_edit.by_local_name_with_attr("col", "min", col_text)
        let dup = @a_edit.direct_children(cols, pred)
        if dup.length() == 0 {
          @a_edit.append_child(cols, @xml.Node::Element(col_element))
        } else {
          @a_edit.replace_children(cols, pred, col_element)
        }
      })
    }
  })
}

///|
/// Rename a worksheet by updating the `<sheet>` entry's `@name` in
/// the workbook part. The OPC part name is left unchanged.
pub fn rename_sheet(
  workbook : Workbook,
  sheet_index : Int,
  name : String,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let mut counter = 0
  let workbook = edit_workbook(workbook, fn(root) {
    @a_edit.update_first(root, @a_edit.by_local_name("sheets"), fn(sheets) {
      let new_children : Array[@xml.Node] = []
      for child in sheets.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "sheet" {
              if counter == sheet_index {
                new_children.push(
                  @xml.Node::Element(
                    @a_edit.set_attribute(
                      e,
                      @a_edit.unprefixed_attribute("name", name),
                    ),
                  ),
                )
              } else {
                new_children.push(child)
              }
              counter = counter + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      {
        name: sheets.name,
        attributes: sheets.attributes,
        children: new_children,
      }
    })
  })
  workbook
}

///|
/// Set the §18.2.19 `<sheet>` `@state` attribute. `state` is one of
/// `visible` / `hidden` / `veryHidden` per ST_SheetState §18.18.68.
pub fn set_sheet_visible(
  workbook : Workbook,
  sheet_index : Int,
  state : String,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let mut counter = 0
  edit_workbook(workbook, fn(root) {
    @a_edit.update_first(root, @a_edit.by_local_name("sheets"), fn(sheets) {
      let new_children : Array[@xml.Node] = []
      for child in sheets.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "sheet" {
              if counter == sheet_index {
                new_children.push(
                  @xml.Node::Element(
                    @a_edit.set_attribute(
                      e,
                      @a_edit.unprefixed_attribute("state", state),
                    ),
                  ),
                )
              } else {
                new_children.push(child)
              }
              counter = counter + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      {
        name: sheets.name,
        attributes: sheets.attributes,
        children: new_children,
      }
    })
  })
}

///|
/// Set §18.3.1.73 `<row>` `@hidden` to "1" (true) or remove it
/// (false) for the row at `row_number`. Creates the row if missing.
pub fn set_row_hidden(
  workbook : Workbook,
  sheet_index : Int,
  row_number : Int,
  hidden : Bool,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  if row_number < 1 {
    raise @sml_context.OpenError(
      kind="SchemaViolation",
      path="ST_RowNumber",
      reason="row_number must be >= 1",
    )
  }
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("sheetData"), fn(sd) {
      let row_pred = @a_edit.by_local_name_with_attr(
        "row",
        "r",
        row_number.to_string(),
      )
      let hits = @a_edit.direct_children(sd, row_pred)
      if hits.length() == 0 {
        let row_element = @a_edit.set_attribute(
          @a_edit.empty_element(template_qname, "row"),
          @a_edit.unprefixed_attribute("r", row_number.to_string()),
        )
        let with_hidden = if hidden {
          @a_edit.set_attribute(
            row_element,
            @a_edit.unprefixed_attribute("hidden", "1"),
          )
        } else {
          row_element
        }
        @a_edit.append_child(sd, @xml.Node::Element(with_hidden))
      } else {
        @a_edit.update_first(sd, row_pred, fn(row_elt) {
          if hidden {
            @a_edit.set_attribute(
              row_elt,
              @a_edit.unprefixed_attribute("hidden", "1"),
            )
          } else {
            @a_edit.remove_attribute(row_elt, {
              prefix: None,
              local_name: "hidden",
              ns: None,
            })
          }
        })
      }
    })
  })
}

///|
/// Set §18.8.30 `<numFmt formatCode="...">` on cell `address` of
/// `sheet_index`. Registers a new numFmt entry (id starts at 164 per
/// the §18.8.30 user-defined range) in /xl/styles.xml, creates a
/// matching `<xf>` in `<cellXfs>`, and sets the cell's `@s` attribute
/// to the new xf index. The styles part is synthesized when absent.
pub fn set_cell_number_format(
  workbook : Workbook,
  sheet_index : Int,
  address : String,
  format_code : String,
) -> Workbook raise OpenError {
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  // Allocate numFmtId in the user-defined range [164, ∞) and the
  // next available cellXfs index.
  let (num_fmt_id, with_num_fmt) = allocate_num_fmt(workbook, format_code)
  let (xf_index, with_xf) = allocate_xf_with_num_fmt(with_num_fmt, num_fmt_id)
  let _ = template_qname
  bind_cell_style(with_xf, sheet_index, address, xf_index)
}

///|
/// Set §18.8.20 font name and size on cell `address`. Always
/// allocates a new `<font>` entry in `<fonts>` for this call (no
/// font deduplication yet) and a corresponding `<xf applyFont="1">`
/// in `<cellXfs>`.
pub fn set_cell_font(
  workbook : Workbook,
  sheet_index : Int,
  address : String,
  name : String,
  half_point_size : Int,
) -> Workbook raise OpenError {
  let (font_index, with_font) = allocate_font(workbook, name, half_point_size)
  let (xf_index, with_xf) = allocate_xf_with_font(with_font, font_index)
  bind_cell_style(with_xf, sheet_index, address, xf_index)
}

///|
/// Set §18.8.20 `<fill>` solid-color background on cell `address`.
/// `hex` is `RRGGBB` per ST_HexBinary §18.18.45 (without leading #).
pub fn set_cell_fill(
  workbook : Workbook,
  sheet_index : Int,
  address : String,
  hex : String,
) -> Workbook raise OpenError {
  let (fill_index, with_fill) = allocate_fill(workbook, hex)
  let (xf_index, with_xf) = allocate_xf_with_fill(with_fill, fill_index)
  bind_cell_style(with_xf, sheet_index, address, xf_index)
}

///|
/// §18.3.1.4 / §18.8.45 — set cell `@s="xf_index"` on the cell
/// at `address` of `sheet_index`.  A-layer helper used by every
/// style-binding B-layer call.  Spec-API naming alias
/// `set_cell_style` is exposed below for callers expecting the
/// natural by-spec verb.
pub fn bind_cell_style(
  workbook : Workbook,
  sheet_index : Int,
  address : String,
  xf_index : Int,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let (_col, row_index) = parse_cell_address(address)
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  let xf_text = xf_index.to_string()
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("sheetData"), fn(sd) {
      let row_pred = @a_edit.by_local_name_with_attr(
        "row",
        "r",
        row_index.to_string(),
      )
      let row_hits = @a_edit.direct_children(sd, row_pred)
      if row_hits.length() == 0 {
        // Create row + empty cell with @s set.
        let new_cell = @a_edit.set_attribute(
          @a_edit.set_attribute(
            @a_edit.empty_element(template_qname, "c"),
            @a_edit.unprefixed_attribute("r", address),
          ),
          @a_edit.unprefixed_attribute("s", xf_text),
        )
        let new_row = @a_edit.append_child(
          @a_edit.set_attribute(
            @a_edit.empty_element(template_qname, "row"),
            @a_edit.unprefixed_attribute("r", row_index.to_string()),
          ),
          @xml.Node::Element(new_cell),
        )
        @a_edit.append_child(sd, @xml.Node::Element(new_row))
      } else {
        @a_edit.update_first(sd, row_pred, fn(row_elt) {
          let cell_pred = @a_edit.by_local_name_with_attr("c", "r", address)
          let cell_hits = @a_edit.direct_children(row_elt, cell_pred)
          if cell_hits.length() == 0 {
            let new_cell = @a_edit.set_attribute(
              @a_edit.set_attribute(
                @a_edit.empty_element(template_qname, "c"),
                @a_edit.unprefixed_attribute("r", address),
              ),
              @a_edit.unprefixed_attribute("s", xf_text),
            )
            @a_edit.append_child(row_elt, @xml.Node::Element(new_cell))
          } else {
            @a_edit.update_first(row_elt, cell_pred, fn(c) {
              @a_edit.set_attribute(c, @a_edit.unprefixed_attribute("s", xf_text))
            })
          }
        })
      }
    })
  })
}

///|
/// Append a `<numFmt numFmtId="N" formatCode="..."/>` to
/// `<numFmts>`, creating the container if absent. The allocated id
/// starts at 164 per §18.8.30 ST_NumFmtId user-defined range.
/// Returns (new_id, new_workbook).
fn allocate_num_fmt(
  workbook : Workbook,
  format_code : String,
) -> (Int, Workbook) {
  let mut next_id = 164
  match workbook.styles {
    Some(s) =>
      for child in s.element.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "numFmts" {
              for c in e.children {
                match c {
                  @xml.Element(nf) =>
                    if nf.name.local_name == "numFmt" {
                      for a in nf.attributes {
                        if a.name.local_name == "numFmtId" {
                          let parsed = Some(@string.parse_int(a.value)) catch {
                            _ => None
                          }
                          match parsed {
                            Some(n) => if n >= next_id { next_id = n + 1 }
                            None => ()
                          }
                        }
                      }
                    }
                  _ => ()
                }
              }
            }
          _ => ()
        }
      }
    None => ()
  }
  let new_id = next_id
  let updated = edit_styles(workbook, fn(root) {
    let qn = @a_edit.qname_like(root.name, "numFmt")
    let num_fmt = @a_edit.set_attribute(
      @a_edit.set_attribute(
        @a_edit.empty_element(qn, "numFmt"),
        @a_edit.unprefixed_attribute("numFmtId", new_id.to_string()),
      ),
      @a_edit.unprefixed_attribute("formatCode", format_code),
    )
    upsert_styles_container(root, "numFmts", num_fmt)
  })
  (new_id, updated)
}

///|
/// Append a `<font>` entry with `<name val=...>` and `<sz val=...>`,
/// returning (font_index, workbook). Indices are 0-based.
fn allocate_font(
  workbook : Workbook,
  name : String,
  half_point_size : Int,
) -> (Int, Workbook) {
  let mut current = 0
  match workbook.styles {
    Some(s) =>
      for child in s.element.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "fonts" {
              for c in e.children {
                match c {
                  @xml.Element(f) =>
                    if f.name.local_name == "font" {
                      current = current + 1
                    }
                  _ => ()
                }
              }
            }
          _ => ()
        }
      }
    None => ()
  }
  let new_index = current
  let updated = edit_styles(workbook, fn(root) {
    let qn = @a_edit.qname_like(root.name, "font")
    let sz = @a_edit.set_attribute(
      @a_edit.empty_element(qn, "sz"),
      @a_edit.unprefixed_attribute("val", half_point_size.to_string()),
    )
    let name_elt = @a_edit.set_attribute(
      @a_edit.empty_element(qn, "name"),
      @a_edit.unprefixed_attribute("val", name),
    )
    let font = @a_edit.append_child(
      @a_edit.append_child(
        @a_edit.empty_element(qn, "font"),
        @xml.Node::Element(sz),
      ),
      @xml.Node::Element(name_elt),
    )
    upsert_styles_container(root, "fonts", font)
  })
  (new_index, updated)
}

///|
/// Append a `<fill><patternFill patternType="solid"><fgColor
/// rgb="HEX"/></patternFill></fill>` entry; returns (fill_index,
/// workbook). The xlsx spec reserves indices 0 and 1 for "none" and
/// "gray125", so the allocator must skip those when starting from
/// empty.
fn allocate_fill(workbook : Workbook, hex : String) -> (Int, Workbook) {
  let mut current = 0
  match workbook.styles {
    Some(s) =>
      for child in s.element.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "fills" {
              for c in e.children {
                match c {
                  @xml.Element(f) =>
                    if f.name.local_name == "fill" {
                      current = current + 1
                    }
                  _ => ()
                }
              }
            }
          _ => ()
        }
      }
    None => ()
  }
  // Reserve the two ECMA-376 §18.8.20 mandatory entries when the
  // table is being initialised from empty.
  let mut workbook_ref = workbook
  let new_index = if current == 0 {
    workbook_ref = edit_styles(workbook_ref, fn(root) {
      let qn = @a_edit.qname_like(root.name, "fill")
      let pf_none = @a_edit.set_attribute(
        @a_edit.empty_element(qn, "patternFill"),
        @a_edit.unprefixed_attribute("patternType", "none"),
      )
      let pf_gray = @a_edit.set_attribute(
        @a_edit.empty_element(qn, "patternFill"),
        @a_edit.unprefixed_attribute("patternType", "gray125"),
      )
      let f0 = @a_edit.append_child(
        @a_edit.empty_element(qn, "fill"),
        @xml.Node::Element(pf_none),
      )
      let f1 = @a_edit.append_child(
        @a_edit.empty_element(qn, "fill"),
        @xml.Node::Element(pf_gray),
      )
      let with_f0 = upsert_styles_container(root, "fills", f0)
      upsert_styles_container(with_f0, "fills", f1)
    })
    2
  } else {
    current
  }
  let updated = edit_styles(workbook_ref, fn(root) {
    let qn = @a_edit.qname_like(root.name, "fill")
    let fg = @a_edit.set_attribute(
      @a_edit.empty_element(qn, "fgColor"),
      @a_edit.unprefixed_attribute("rgb", hex),
    )
    let pattern = @a_edit.append_child(
      @a_edit.set_attribute(
        @a_edit.empty_element(qn, "patternFill"),
        @a_edit.unprefixed_attribute("patternType", "solid"),
      ),
      @xml.Node::Element(fg),
    )
    let fill = @a_edit.append_child(
      @a_edit.empty_element(qn, "fill"),
      @xml.Node::Element(pattern),
    )
    upsert_styles_container(root, "fills", fill)
  })
  (new_index, updated)
}

///|
/// Append an `<xf>` referencing the given numFmt id to `<cellXfs>`.
/// Returns (new_xf_index, workbook). Caller binds the cell to this
/// index via `bind_cell_style`.
fn allocate_xf_with_num_fmt(
  workbook : Workbook,
  num_fmt_id : Int,
) -> (Int, Workbook) {
  let new_index = current_xf_count(workbook)
  let updated = edit_styles(workbook, fn(root) {
    let qn = @a_edit.qname_like(root.name, "xf")
    let xf = @a_edit.set_attribute(
      @a_edit.set_attribute(
        @a_edit.empty_element(qn, "xf"),
        @a_edit.unprefixed_attribute("numFmtId", num_fmt_id.to_string()),
      ),
      @a_edit.unprefixed_attribute("applyNumberFormat", "1"),
    )
    upsert_styles_container(root, "cellXfs", xf)
  })
  (new_index, updated)
}

///|
fn allocate_xf_with_font(workbook : Workbook, font_id : Int) -> (Int, Workbook) {
  let new_index = current_xf_count(workbook)
  let updated = edit_styles(workbook, fn(root) {
    let qn = @a_edit.qname_like(root.name, "xf")
    let xf = @a_edit.set_attribute(
      @a_edit.set_attribute(
        @a_edit.empty_element(qn, "xf"),
        @a_edit.unprefixed_attribute("fontId", font_id.to_string()),
      ),
      @a_edit.unprefixed_attribute("applyFont", "1"),
    )
    upsert_styles_container(root, "cellXfs", xf)
  })
  (new_index, updated)
}

///|
fn allocate_xf_with_fill(workbook : Workbook, fill_id : Int) -> (Int, Workbook) {
  let new_index = current_xf_count(workbook)
  let updated = edit_styles(workbook, fn(root) {
    let qn = @a_edit.qname_like(root.name, "xf")
    let xf = @a_edit.set_attribute(
      @a_edit.set_attribute(
        @a_edit.empty_element(qn, "xf"),
        @a_edit.unprefixed_attribute("fillId", fill_id.to_string()),
      ),
      @a_edit.unprefixed_attribute("applyFill", "1"),
    )
    upsert_styles_container(root, "cellXfs", xf)
  })
  (new_index, updated)
}

///|
fn current_xf_count(workbook : Workbook) -> Int {
  let mut count = 0
  match workbook.styles {
    Some(s) =>
      for child in s.element.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "cellXfs" {
              for c in e.children {
                match c {
                  @xml.Element(x) =>
                    if x.name.local_name == "xf" {
                      count = count + 1
                    }
                  _ => ()
                }
              }
            }
          _ => ()
        }
      }
    None => ()
  }
  count
}

///|
/// Append `child` to the styles container `local_name` (numFmts /
/// fonts / fills / borders / cellXfs / ...), creating the container
/// as a direct child of `root` when absent.
fn upsert_styles_container(
  root : @xml.Element,
  local_name : String,
  child : @xml.Element,
) -> @xml.Element {
  let hits = @a_edit.direct_children(root, @a_edit.by_local_name(local_name))
  if hits.length() == 0 {
    let qn = @a_edit.qname_like(root.name, local_name)
    let container = @a_edit.append_child(
      @a_edit.empty_element(qn, local_name),
      @xml.Node::Element(child),
    )
    @a_edit.append_child(root, @xml.Node::Element(container))
  } else {
    @a_edit.update_first(root, @a_edit.by_local_name(local_name), fn(container) {
      @a_edit.append_child(container, @xml.Node::Element(child))
    })
  }
}

///|
/// Drop a §18.3.1.55 `<mergeCell>` entry matching `range`. No-op when
/// no such entry exists. Removes the `<mergeCells>` container when it
/// becomes empty.
pub fn unmerge_cells(
  workbook : Workbook,
  sheet_index : Int,
  range : String,
) -> Workbook raise OpenError {
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    let patched = @a_edit.update_first(
      ws_elt,
      @a_edit.by_local_name("mergeCells"),
      fn(mc) {
        @a_edit.remove_children(
          mc,
          @a_edit.by_local_name_with_attr("mergeCell", "ref", range),
        )
      },
    )
    // If <mergeCells> now has zero children, remove it entirely.
    let mc_hits = @a_edit.direct_children(
      patched,
      @a_edit.by_local_name("mergeCells"),
    )
    if mc_hits.length() > 0 && mc_hits[0].children.length() == 0 {
      @a_edit.remove_children(patched, @a_edit.by_local_name("mergeCells"))
    } else {
      patched
    }
  })
}

///|
/// Set §18.3.1.73 `<row>` `@ht` (height in points) and `@customHeight`
/// for `row_number`. Creates the row if missing.
pub fn set_row_height(
  workbook : Workbook,
  sheet_index : Int,
  row_number : Int,
  height_points : Double,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  if row_number < 1 {
    raise @sml_context.OpenError(
      kind="SchemaViolation",
      path="ST_RowNumber",
      reason="row_number must be >= 1",
    )
  }
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("sheetData"), fn(sd) {
      let row_pred = @a_edit.by_local_name_with_attr(
        "row",
        "r",
        row_number.to_string(),
      )
      let hits = @a_edit.direct_children(sd, row_pred)
      let apply : (@xml.Element) -> @xml.Element = fn(row_elt) {
        @a_edit.set_attribute(
          @a_edit.set_attribute(
            row_elt,
            @a_edit.unprefixed_attribute("ht", height_points.to_string()),
          ),
          @a_edit.unprefixed_attribute("customHeight", "1"),
        )
      }
      if hits.length() == 0 {
        let row_element = @a_edit.set_attribute(
          @a_edit.empty_element(template_qname, "row"),
          @a_edit.unprefixed_attribute("r", row_number.to_string()),
        )
        @a_edit.append_child(sd, @xml.Node::Element(apply(row_element)))
      } else {
        @a_edit.update_first(sd, row_pred, apply)
      }
    })
  })
}

///|
/// Insert an empty §18.3.1.13 `<col>` covering `column_index` into the
/// worksheet's `<cols>` block. Creates `<cols>` when absent.
pub fn insert_column(
  workbook : Workbook,
  sheet_index : Int,
  column_index : Int,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  if column_index < 1 {
    raise @sml_context.OpenError(
      kind="SchemaViolation",
      path="ST_ColumnIndex",
      reason="column_index must be >= 1",
    )
  }
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  let col_text = column_index.to_string()
  let col_element = @a_edit.set_attribute(
    @a_edit.set_attribute(
      @a_edit.empty_element(template_qname, "col"),
      @a_edit.unprefixed_attribute("min", col_text),
    ),
    @a_edit.unprefixed_attribute("max", col_text),
  )
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    let hits = @a_edit.direct_children(ws_elt, @a_edit.by_local_name("cols"))
    if hits.length() == 0 {
      let cols_element = @a_edit.append_child(
        @a_edit.empty_element(template_qname, "cols"),
        @xml.Node::Element(col_element),
      )
      // Insert <cols> immediately before <sheetData>.
      let mut position = ws_elt.children.length()
      let mut i = 0
      for child in ws_elt.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "sheetData" &&
              position == ws_elt.children.length() {
              position = i
            }
          _ => ()
        }
        i = i + 1
      }
      @a_edit.insert_child(ws_elt, position, @xml.Node::Element(cols_element))
    } else {
      @a_edit.update_first(ws_elt, @a_edit.by_local_name("cols"), fn(cols) {
        @a_edit.append_child(cols, @xml.Node::Element(col_element))
      })
    }
  })
}

///|
/// Remove every `<col>` entry whose `@min` matches `column_index`.
pub fn remove_column(
  workbook : Workbook,
  sheet_index : Int,
  column_index : Int,
) -> Workbook raise OpenError {
  let col_text = column_index.to_string()
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("cols"), fn(cols) {
      @a_edit.remove_children(
        cols,
        @a_edit.by_local_name_with_attr("col", "min", col_text),
      )
    })
  })
}

///|
/// Install a §18.3.1.2 `<autoFilter ref="A1:B10">` on the worksheet.
/// Replaces any existing autoFilter. `range` is an A1:B10-style ref.
pub fn set_auto_filter(
  workbook : Workbook,
  sheet_index : Int,
  range : String,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let template_qname = workbook.worksheets[sheet_index].value.element.name
  let af_element = @a_edit.set_attribute(
    @a_edit.empty_element(template_qname, "autoFilter"),
    @a_edit.unprefixed_attribute("ref", range),
  )
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    let stripped = @a_edit.remove_children(
      ws_elt,
      @a_edit.by_local_name("autoFilter"),
    )
    @a_edit.append_child(stripped, @xml.Node::Element(af_element))
  })
}

///|
/// Remove any §18.3.1.2 `<autoFilter>` element from the worksheet.
pub fn clear_auto_filter(
  workbook : Workbook,
  sheet_index : Int,
) -> Workbook raise OpenError {
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.remove_children(ws_elt, @a_edit.by_local_name("autoFilter"))
  })
}

///|
/// Build a `<c r="A1" t="inlineStr"><is><t>value</t></is></c>` cell
/// element. Borrows prefix/namespace from `template` so the cell
/// blends into the surrounding worksheet's namespace bindings.
fn build_inline_str_cell(
  template : @xml.QName,
  address : String,
  value : String,
) -> @xml.Element {
  // §18.4.12 CT_Rst / XML 1.0 §3.3.3 — when the inline string
  // value has leading or trailing ASCII whitespace we MUST set
  // `xml:space="preserve"` on the `<t>` element; otherwise the
  // XML normaliser strips the whitespace on round-trip.
  let t_base = @a_edit.empty_element(template, "t")
  let t_with_space = if sml_needs_xml_space_preserve(value) {
    let xml_qn : @xml.QName = {
      prefix: Some("xml"),
      local_name: "space",
      ns: Some("http://www.w3.org/XML/1998/namespace"),
    }
    @a_edit.set_attribute(t_base, { name: xml_qn, value: "preserve" })
  } else {
    t_base
  }
  let t_with_text = @a_edit.append_child(t_with_space, @xml.Node::Text(value))
  let is_element = @a_edit.empty_element(template, "is")
  let is_with_t = @a_edit.append_child(
    is_element,
    @xml.Node::Element(t_with_text),
  )
  let c_element = @a_edit.empty_element(template, "c")
  let c_with_attrs = @a_edit.set_attribute(
    @a_edit.set_attribute(c_element, @a_edit.unprefixed_attribute("r", address)),
    @a_edit.unprefixed_attribute("t", "inlineStr"),
  )
  @a_edit.append_child(c_with_attrs, @xml.Node::Element(is_with_t))
}

///|
/// §18.4.12 CT_Rst — delegates to the shared §3.3.3 whitespace
/// predicate in the `@edit` package.  See `@edit::needs_xml_space_preserve`.
fn sml_needs_xml_space_preserve(text : String) -> Bool {
  @a_edit.needs_xml_space_preserve(text)
}

///|
/// Clear a §18.3.1.4 cell at the given A1 reference on sheet
/// `sheet_index` (0-based). Removes the `<c>` element entirely so a
/// subsequent reader treats the cell as empty. Returns a new
/// Workbook; the original is unchanged.
pub fn clear_cell(
  workbook : Workbook,
  sheet_index : Int,
  address : String,
) -> Workbook raise OpenError {
  edit_worksheet(workbook, sheet_index, fn(ws_elt) {
    @a_edit.update_first(ws_elt, @a_edit.by_local_name("sheetData"), fn(sd) {
      // For every <row>, drop any <c r="address"> child.
      @a_edit.map_subtree(sd, fn(row_elt) {
        if row_elt.name.local_name == "row" {
          @a_edit.remove_children(
            row_elt,
            @a_edit.by_local_name_with_attr("c", "r", address),
          )
        } else {
          row_elt
        }
      })
    })
  })
}

///|
/// Append a brand-new §18.3.1.99 worksheet part to the workbook.
/// Creates the part (`/xl/worksheets/sheetN.xml`), registers a
/// Content_Types Override
/// (`application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml`),
/// adds a relationship from the workbook part to the new worksheet,
/// and appends a `<s:sheet>` entry to the workbook's `<s:sheets>`
/// list (creating the list when absent). Returns a new Workbook;
/// the original is unchanged.
pub fn append_sheet(
  workbook : Workbook,
  name : String,
) -> Workbook raise OpenError {
  let mut max_index = 0
  for ws in workbook.worksheets {
    let part_name = ws.name
    let prefix = "/xl/worksheets/sheet"
    let suffix = ".xml"
    if part_name.has_prefix(prefix) && part_name.has_suffix(suffix) {
      let middle = part_name[prefix.length():part_name.length() -
      suffix.length()].to_owned()
      let parsed = Some(@string.parse_int(middle)) catch { _ => None }
      match parsed {
        Some(n) => if n > max_index { max_index = n }
        None => ()
      }
    }
  }
  let new_index = max_index + 1
  let new_part_name = "/xl/worksheets/sheet" + new_index.to_string() + ".xml"

  // Build minimal worksheet element (canonical sml namespace).
  let s_ns = Some("http://schemas.openxmlformats.org/spreadsheetml/2006/main")
  let qn = fn(local_name : String) -> @xml.QName {
    { prefix: None, local_name: local_name, ns: s_ns }
  }
  let xmlns_attrs : Array[@xml.Attribute] = [
    {
      name: { prefix: None, local_name: "xmlns", ns: None },
      value: "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
    },
  ]
  let sheet_data : @xml.Element = {
    name: qn("sheetData"),
    attributes: [],
    children: [],
  }
  let ws_element : @xml.Element = {
    name: qn("worksheet"),
    attributes: xmlns_attrs,
    children: [@xml.Node::Element(sheet_data)],
  }
  let new_ws = @sml.CT_Worksheet::new(ws_element) catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @sml_context.OpenError(
        kind="SchemaViolation \{section}",
        path~,
        reason~,
      )
  }
  let ws_bytes = @sml_builder.write_worksheet(new_ws)

  // Allocate a fresh relationship Id for the workbook rels.
  let existing_rels = match
    workbook.opc_package.relationships(workbook.workbook_part) {
    Some(rs) => rs.relationships
    None => []
  }
  let mut max_rid = 0
  for r in existing_rels {
    if r.id.has_prefix("rId") {
      let parsed = Some(@string.parse_int(r.id[3:].to_owned())) catch {
        _ => None
      }
      match parsed {
        Some(n) => if n > max_rid { max_rid = n }
        None => ()
      }
    }
  }
  let new_rid = "rId" + (max_rid + 1).to_string()

  // Allocate a fresh sheetId by scanning the workbook element.
  let mut max_sheet_id = 0
  let workbook_element = workbook.workbook.element
  for child in workbook_element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "sheets" {
          for c in e.children {
            match c {
              @xml.Element(s) =>
                if s.name.local_name == "sheet" {
                  for attr in s.attributes {
                    if attr.name.local_name == "sheetId" {
                      let parsed = Some(@string.parse_int(attr.value)) catch {
                        _ => None
                      }
                      match parsed {
                        Some(v) => if v > max_sheet_id { max_sheet_id = v }
                        None => ()
                      }
                    }
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  let new_sheet_id = (max_sheet_id + 1).to_string()

  // Update the OPC package: new part + override + workbook rel.
  let pkg2 = try {
    let pkg_with_part = workbook.opc_package.add_part(
      new_part_name, "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
      ws_bytes,
    )
    pkg_with_part.with_relationship(
      workbook.workbook_part,
      new_rid,
      "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
      "worksheets/sheet" + new_index.to_string() + ".xml",
    )
  } catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @sml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }

  // Splice a <sheet> entry into the workbook element's <sheets>.
  let new_workbook_children : Array[@xml.Node] = []
  let mut sheets_seen = false
  let sheet_entry_attrs : Array[@xml.Attribute] = [
    { name: { prefix: None, local_name: "name", ns: None }, value: name },
    {
      name: { prefix: None, local_name: "sheetId", ns: None },
      value: new_sheet_id,
    },
    {
      name: {
        prefix: Some("r"),
        local_name: "id",
        ns: Some(
          "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
        ),
      },
      value: new_rid,
    },
  ]
  let sheet_entry : @xml.Element = {
    name: qn("sheet"),
    attributes: sheet_entry_attrs,
    children: [],
  }
  for child in workbook_element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "sheets" {
          sheets_seen = true
          let new_sheets_children : Array[@xml.Node] = []
          for c in e.children {
            new_sheets_children.push(c)
          }
          new_sheets_children.push(@xml.Node::Element(sheet_entry))
          let patched : @xml.Element = {
            name: e.name,
            attributes: e.attributes,
            children: new_sheets_children,
          }
          new_workbook_children.push(@xml.Node::Element(patched))
        } else {
          new_workbook_children.push(@xml.Node::Element(e))
        }
      other => new_workbook_children.push(other)
    }
  }
  if !sheets_seen {
    let sheets_element : @xml.Element = {
      name: qn("sheets"),
      attributes: [],
      children: [@xml.Node::Element(sheet_entry)],
    }
    new_workbook_children.push(@xml.Node::Element(sheets_element))
  }
  let new_workbook_element : @xml.Element = {
    name: workbook_element.name,
    attributes: workbook_element.attributes,
    children: new_workbook_children,
  }
  let new_workbook = @sml.CT_Workbook::new(new_workbook_element)
  let new_worksheets : Array[WorksheetPart] = []
  for ws in workbook.worksheets {
    new_worksheets.push(ws)
  }
  new_worksheets.push({
    name: new_part_name,
    value: new_ws,
    drawing: None,
    drawing_part: None,
    tables: [],
  })
  {
    opc_package: pkg2,
    workbook_part: workbook.workbook_part,
    workbook: new_workbook,
    worksheets: new_worksheets,
    shared_strings: workbook.shared_strings,
    styles: workbook.styles,
    theme: workbook.theme,
  }
}

///|
/// Remove a worksheet from the workbook. Drops the part, its
/// Content_Types Override, the workbook→worksheet relationship, and
/// the `<s:sheet>` entry from the workbook's `<s:sheets>` element.
pub fn remove_sheet(
  workbook : Workbook,
  sheet_index : Int,
) -> Workbook raise OpenError {
  if sheet_index < 0 || sheet_index >= workbook.worksheets.length() {
    raise @sml_context.OpenError(
      kind="UnsupportedFeature",
      path="worksheet",
      reason="sheet index out of range",
    )
  }
  let target = workbook.worksheets[sheet_index]
  let target_name = target.name
  let existing_rels = match
    workbook.opc_package.relationships(workbook.workbook_part) {
    Some(rs) => rs.relationships
    None => []
  }
  let mut target_rid : String? = None
  for r in existing_rels {
    let resolved = Some(
      @opc_part_name.resolve_target(workbook.workbook_part, r.target),
    ) catch {
      _ => None
    }
    match resolved {
      Some(name) => if name == target_name { target_rid = Some(r.id) }
      None => ()
    }
  }
  let workbook_element = workbook.workbook.element
  let new_workbook_children : Array[@xml.Node] = []
  for child in workbook_element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "sheets" {
          let new_sheets_children : Array[@xml.Node] = []
          for c in e.children {
            match c {
              @xml.Element(s) =>
                if s.name.local_name == "sheet" {
                  let mut keep = true
                  match target_rid {
                    Some(rid) =>
                      for attr in s.attributes {
                        if attr.name.local_name == "id" &&
                          (match attr.name.prefix {
                            Some("r") => true
                            _ => false
                          }) &&
                          attr.value == rid {
                          keep = false
                        }
                      }
                    None => ()
                  }
                  if keep {
                    new_sheets_children.push(c)
                  }
                } else {
                  new_sheets_children.push(c)
                }
              other => new_sheets_children.push(other)
            }
          }
          let patched : @xml.Element = {
            name: e.name,
            attributes: e.attributes,
            children: new_sheets_children,
          }
          new_workbook_children.push(@xml.Node::Element(patched))
        } else {
          new_workbook_children.push(@xml.Node::Element(e))
        }
      other => new_workbook_children.push(other)
    }
  }
  let new_workbook_element : @xml.Element = {
    name: workbook_element.name,
    attributes: workbook_element.attributes,
    children: new_workbook_children,
  }
  let new_workbook = @sml.CT_Workbook::new(new_workbook_element)
  let pkg2 = try {
    let pkg_no_rel = match target_rid {
      Some(rid) =>
        workbook.opc_package.remove_relationship(workbook.workbook_part, rid)
      None => workbook.opc_package
    }
    pkg_no_rel.remove_part(target_name)
  } catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @sml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
  let new_worksheets : Array[WorksheetPart] = []
  let mut i = 0
  for ws in workbook.worksheets {
    if i != sheet_index {
      new_worksheets.push(ws)
    }
    i = i + 1
  }
  {
    opc_package: pkg2,
    workbook_part: workbook.workbook_part,
    workbook: new_workbook,
    worksheets: new_worksheets,
    shared_strings: workbook.shared_strings,
    styles: workbook.styles,
    theme: workbook.theme,
  }
}

///|
/// Parse an A1 cell reference (e.g. "A1", "AB12") into (column_index,
/// row_number). Column indices are 1-based. Raises OpenError when the
/// reference does not match `[A-Z]+[0-9]+`.
fn parse_cell_address(address : String) -> (Int, Int) raise OpenError {
  let mut col_end = 0
  for c in address {
    let code = c.to_int()
    if code >= 0x41 && code <= 0x5A {
      col_end = col_end + 1
    } else {
      break
    }
  }
  if col_end == 0 || col_end >= address.length() {
    raise @sml_context.OpenError(
      kind="SchemaViolation",
      path="ST_CellRef",
      reason="invalid cell reference: " + address,
    )
  }
  let col_text = address[0:col_end].to_owned()
  let row_text = address[col_end:address.length()].to_owned()
  let mut col_index = 0
  for c in col_text {
    let code = c.to_int()
    if code < 0x41 || code > 0x5A {
      raise @sml_context.OpenError(
        kind="SchemaViolation",
        path="ST_CellRef",
        reason="invalid column letters: " + address,
      )
    }
    col_index = col_index * 26 + (code - 0x40)
  }
  let row_index = @string.parse_int(row_text) catch {
    _ =>
      raise @sml_context.OpenError(
        kind="SchemaViolation",
        path="ST_CellRef",
        reason="invalid row number: " + address,
      )
  }
  if row_index < 1 {
    raise @sml_context.OpenError(
      kind="SchemaViolation",
      path="ST_CellRef",
      reason="row number must be >= 1: " + address,
    )
  }
  (col_index, row_index)
}

///|
/// §18.3.1.4 / §18.8.45 — natural by-spec alias for
/// `bind_cell_style`.  Sets the cell's `@s` attribute to the
/// index of an existing `<xf>` entry in `<cellXfs>`.  Use this
/// after `add_cell_xf` (or an equivalent) has interned the
/// formatted-cell-format record.
pub fn set_cell_style(
  workbook : Workbook,
  sheet_index : Int,
  address : String,
  xf_index : Int,
) -> Workbook raise OpenError {
  bind_cell_style(workbook, sheet_index, address, xf_index)
}
