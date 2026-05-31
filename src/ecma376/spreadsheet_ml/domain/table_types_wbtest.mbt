// Tests for the §18.5.1 SpreadsheetML structured-table typed model
// (CT_Table / CT_TableColumns / CT_TableColumn / CT_TableParts).

///|
fn tbl_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name, ns: None }, value }
}

///|
fn tbl_elem(
  local_name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  {
    name: {
      prefix: None,
      local_name,
      ns: Some("http://schemas.openxmlformats.org/spreadsheetml/2006/main"),
    },
    attributes: attrs,
    children,
  }
}

///|
test "CT_Table projects name / ref / header counts and columns" {
  let col1 = @xml.Node::Element(
    tbl_elem("tableColumn", [tbl_attr("id", "1"), tbl_attr("name", "Region")], []),
  )
  let col2 = @xml.Node::Element(
    tbl_elem("tableColumn", [tbl_attr("id", "2"), tbl_attr("name", "Sales")], [
      @xml.Node::Element(
        tbl_elem("calculatedColumnFormula", [], [@xml.Node::Text("SUM(1)")]),
      ),
    ]),
  )
  let cols = @xml.Node::Element(
    tbl_elem("tableColumns", [tbl_attr("count", "2")], [col1, col2]),
  )
  let table = tbl_elem(
    "table",
    [
      tbl_attr("id", "1"),
      tbl_attr("name", "Table1"),
      tbl_attr("displayName", "Table1"),
      tbl_attr("ref", "A1:B5"),
      tbl_attr("headerRowCount", "1"),
      tbl_attr("totalsRowCount", "1"),
    ],
    [cols],
  )
  let t = CT_Table::new(table)
  inspect(t.name, content="Table1")
  inspect(t.ref_range, content="A1:B5")
  inspect(t.header_row_count, content="1")
  inspect(t.totals_row_count, content="1")
  // The typed column projection captured both columns.
  match t.table_columns {
    Some(tc) => {
      inspect(tc.columns.length(), content="2")
      inspect(tc.columns[0].name, content="Region")
      inspect(tc.columns[1].name, content="Sales")
      match tc.columns[1].calculated_column_formula {
        Some(f) => inspect(f, content="SUM(1)")
        None => fail("expected calculatedColumnFormula on column 2")
      }
    }
    None => fail("expected typed tableColumns projection")
  }
}

///|
test "CT_TableParts projects its tablePart relationship ids" {
  let p1 = @xml.Node::Element(
    tbl_elem("tablePart", [tbl_attr("id", "rId3")], []),
  )
  let parts = CT_TableParts::new(
    tbl_elem("tableParts", [tbl_attr("count", "1")], [p1]),
  )
  inspect(parts.count, content="1")
  inspect(parts.parts.length(), content="1")
  inspect(parts.parts[0].r_id, content="rId3")
}

///|
test "CT_Sheet projects name / sheetId / state / r:id" {
  let s = CT_Sheet::new(
    tbl_elem(
      "sheet",
      [
        tbl_attr("name", "Summary"),
        tbl_attr("sheetId", "3"),
        tbl_attr("state", "hidden"),
        tbl_attr("id", "rId2"),
      ],
      [],
    ),
  )
  inspect(s.name, content="Summary")
  inspect(s.sheet_id, content="3")
  inspect(s.state, content="hidden")
  inspect(s.r_id, content="rId2")
}

///|
test "CT_Sheet defaults state to visible" {
  let s = CT_Sheet::new(tbl_elem("sheet", [tbl_attr("name", "S")], []))
  inspect(s.state, content="visible")
}

///|
test "CT_Sheets projects its sheet entries as typed children" {
  let s1 = @xml.Node::Element(
    tbl_elem("sheet", [tbl_attr("name", "One"), tbl_attr("sheetId", "1")], []),
  )
  let s2 = @xml.Node::Element(
    tbl_elem(
      "sheet",
      [
        tbl_attr("name", "Two"),
        tbl_attr("sheetId", "2"),
        tbl_attr("state", "hidden"),
      ],
      [],
    ),
  )
  let sheets = CT_Sheets::new(tbl_elem("sheets", [], [s1, s2]))
  inspect(sheets.sheets.length(), content="2")
  inspect(sheets.sheets[0].name, content="One")
  inspect(sheets.sheets[1].state, content="hidden")
}

///|
test "CT_IgnoredError projects sqref and suppression flags" {
  let e = CT_IgnoredError::new(
    tbl_elem(
      "ignoredError",
      [tbl_attr("sqref", "A1:A9"), tbl_attr("numberStoredAsText", "1")],
      [],
    ),
  )
  inspect(e.sqref, content="A1:A9")
  inspect(e.number_stored_as_text, content="true")
  inspect(e.eval_error, content="false")
}

///|
test "CT_ControlPr defaults and r:id projection" {
  let c = CT_ControlPr::new(
    tbl_elem("controlPr", [tbl_attr("id", "rId5"), tbl_attr("disabled", "1")], []),
  )
  inspect(c.r_id, content="rId5")
  inspect(c.disabled, content="true")
  // Spec defaults preserved.
  inspect(c.locked, content="true")
  inspect(c.auto_line, content="true")
}

///|
test "CT_CustomWorkbookView projects name / guid / window geometry" {
  let v = CT_CustomWorkbookView::new(
    tbl_elem(
      "customWorkbookView",
      [
        tbl_attr("name", "MyView"),
        tbl_attr("guid", "{GUID}"),
        tbl_attr("windowWidth", "800"),
        tbl_attr("activeSheetId", "2"),
      ],
      [],
    ),
  )
  inspect(v.name, content="MyView")
  inspect(v.guid, content="{GUID}")
  inspect(v.window_width, content="800")
  inspect(v.active_sheet_id, content="2")
}

///|
test "CT_BookView projects activeTab and visibility toggles" {
  let v = CT_BookView::new(
    tbl_elem(
      "workbookView",
      [tbl_attr("activeTab", "2"), tbl_attr("showSheetTabs", "0")],
      [],
    ),
  )
  inspect(v.active_tab, content="2")
  inspect(v.show_sheet_tabs, content="false")
  // Defaults preserved for unspecified toggles.
  inspect(v.show_vertical_scroll, content="true")
}

///|
test "CT_Table defaults: headerRowCount=1, totalsRowShown=true" {
  let t = CT_Table::new(tbl_elem("table", [tbl_attr("displayName", "T")], []))
  inspect(t.header_row_count, content="1")
  inspect(t.totals_row_count, content="0")
  inspect(t.totals_row_shown, content="true")
}
