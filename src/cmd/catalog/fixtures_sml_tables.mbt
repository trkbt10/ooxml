// SpreadsheetML TABLES (Excel "ListObject" tables) — ECMA-376 §18.5.
//
// A table is a named, structured region inside a worksheet that the
// reader (and conformant viewers) renders with banded fills + a header band
// + optional totals row.  The on-disk shape is:
//
//   xl/worksheets/sheet1.xml          carries `<tableParts>` referencing
//                                     the table parts by rId
//   xl/worksheets/_rels/sheet1.xml.rels  maps each rId → ../tables/tableN.xml
//   xl/tables/tableN.xml              the `<table>` element (CT_Table)
//
// `xlsx_package_with_tables` in `verify.mbt` owns the rId numbering,
// the worksheet `_rels` file, and the `[Content_Types]` override; the
// fixtures here only supply the `<sheetData>` and the `<table>`
// element.  Every element is built as an `@xml.Element` tree — no XML
// strings.
//
// What this file covers (§18.5.1.2 CT_Table):
//
//   * simple table with header row
//   * table with totals row (`totalsRowCount="1"` + a `<tableColumn>`
//     `totalsRowFunction` per column)
//   * table with `<tableStyleInfo>` naming a built-in style
//     ("TableStyleMedium2"), with row stripes
//   * table with `<autoFilter>` inside the table element
//   * two adjacent tables on the same sheet (exercises the multi-part
//     pathway in `xlsx_package_with_tables`)
//
// AutoFilter-only fixtures (no table parts at all) are pushed via
// `extras_sml_autofilter_inline` as plain `VisualCase`s — those use
// `xlsx_package` directly.  AutoFilter is also §18.5.1 territory
// because the table machinery overlays the same filter dropdown.
//
// Renderer support note: the context loader resolves
// `<tableParts>/<tablePart r:id="…">` to table parts and the SML
// viewer can paint table chrome in editing-view mode via
// `show_table_chrome`. The default catalog/page-render path leaves
// that chrome suppressed to match reference print export, while the
// dedicated viewer tests exercise the header band, stripes, totals
// border, and autofilter dropdown arrows.

// ---- file-local helpers ----------------------------------------------

///|
/// SpreadsheetML namespace shorthand local to this file.
const NS_S_TBL : String = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"

///|
/// One `<tableColumn id="N" name="...">` entry.  §18.5.1.3.
fn tbl_column(id : String, name : String) -> @xml.Element {
  xe(NS_S_TBL, "tableColumn", [xa("id", id), xa("name", name)], [])
}

///|
/// `<tableColumn id="N" name="..." totalsRowFunction="...">`.  The
/// `totalsRowFunction` attribute is one of `none|sum|min|max|average
/// |count|countNums|stdDev|var|custom` (§18.18.84 ST_TotalsRowFunction).
fn tbl_column_totals(
  id : String,
  name : String,
  totals_fn : String,
) -> @xml.Element {
  xe(
    NS_S_TBL,
    "tableColumn",
    [xa("id", id), xa("name", name), xa("totalsRowFunction", totals_fn)],
    [],
  )
}

///|
/// `<tableColumn id="N" name="..." totalsRowLabel="...">`.  Use on the
/// FIRST column of a totals row to label the band (e.g. "Total").
fn tbl_column_totals_label(
  id : String,
  name : String,
  label : String,
) -> @xml.Element {
  xe(
    NS_S_TBL,
    "tableColumn",
    [xa("id", id), xa("name", name), xa("totalsRowLabel", label)],
    [],
  )
}

///|
/// `<tableColumns count="N">` wrapper.  §18.5.1.4.
fn tbl_columns(cols : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cols {
    kids.push(Element(c))
  }
  xe(NS_S_TBL, "tableColumns", [xa("count", cols.length().to_string())], kids)
}

///|
/// `<tableStyleInfo name="..." showFirstColumn="..." showLastColumn="..."
/// showRowStripes="..." showColumnStripes="..."/>`.  §18.5.1.5.  The
/// `name` references a built-in or custom style — built-ins are
/// `TableStyleLight1..21`, `TableStyleMedium1..28`, `TableStyleDark1..11`.
fn tbl_style_info(
  name : String,
  row_stripes : Bool,
  col_stripes : Bool,
) -> @xml.Element {
  xe(
    NS_S_TBL,
    "tableStyleInfo",
    [
      xa("name", name),
      xa("showFirstColumn", "0"),
      xa("showLastColumn", "0"),
      xa("showRowStripes", if row_stripes { "1" } else { "0" }),
      xa("showColumnStripes", if col_stripes { "1" } else { "0" }),
    ],
    [],
  )
}

///|
/// `<autoFilter ref="...">` element — embedded inside a `<table>` or
/// directly under `<worksheet>` (the two locations have identical
/// schema).  §18.3.1.2 CT_AutoFilter.
fn tbl_auto_filter(ref_ : String) -> @xml.Element {
  xe(NS_S_TBL, "autoFilter", [xa("ref", ref_)], [])
}

///|
/// Build a `<table>` element (§18.5.1.2 CT_Table).  Required attrs:
/// `id`, `name`, `displayName`, `ref`.  Children appended in spec
/// order: optional `<autoFilter>`, required `<tableColumns>`, optional
/// `<tableStyleInfo>`.
fn tbl_table(
  id : String,
  name : String,
  display_name : String,
  ref_ : String,
  totals_row_count : Int,
  auto_filter : @xml.Element?,
  columns : @xml.Element,
  style_info : @xml.Element?,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    xa("id", id),
    xa("name", name),
    xa("displayName", display_name),
    xa("ref", ref_),
  ]
  if totals_row_count > 0 {
    attrs.push(xa("totalsRowCount", totals_row_count.to_string()))
  }
  let kids : Array[@xml.Node] = []
  match auto_filter {
    Some(af) => kids.push(Element(af))
    None => ()
  }
  kids.push(Element(columns))
  match style_info {
    Some(si) => kids.push(Element(si))
    None => ()
  }
  xe(NS_S_TBL, "table", attrs, kids)
}

// ---- VisualCase extender: AUTOFILTER-ONLY fixtures (no table parts) ----

///|
/// §18.3.1.2 `<autoFilter ref="...">` placed directly on the
/// `<worksheet>` — the simplest filter dropdown attachment.  Uses
/// `xlsx_package` (no aux parts).
///
/// Pushed onto the regular `VisualCase` array via `extra_cases()` in
/// `fixtures_categories.mbt`. In the default page-render path the
/// dropdown chrome is intentionally suppressed; editing-view tests
/// enable `show_table_chrome` to validate the §18.3.1.2 glyph path.
fn extras_sml_autofilter_inline(cases : Array[VisualCase]) -> Unit {
  // A 4-row sheet (header + 3 data rows) with `<autoFilter
  // ref="A1:C4">` — the canonical "click the column header to filter"
  // layout.
  cases.push({
    id: "autofilter-basic",
    format: "xlsx",
    category: "table",
    content: xe(NS_S_TBL, "worksheet", [], [
      Element(
        xe(NS_S_TBL, "sheetData", [], [
          Element(
            s_row("1", [
              s_inline("A1", "Region"),
              s_inline("B1", "Quarter"),
              s_inline("C1", "Sales"),
            ]),
          ),
          Element(
            s_row("2", [
              s_inline("A2", "North"),
              s_inline("B2", "Q1"),
              s_cell("C2", "120"),
            ]),
          ),
          Element(
            s_row("3", [
              s_inline("A3", "South"),
              s_inline("B3", "Q1"),
              s_cell("C3", "95"),
            ]),
          ),
          Element(
            s_row("4", [
              s_inline("A4", "East"),
              s_inline("B4", "Q1"),
              s_cell("C4", "180"),
            ]),
          ),
        ]),
      ),
      Element(tbl_auto_filter("A1:C4")),
    ]),
  })
  // AutoFilter with a `<filterColumn>` child carrying a `<filters>`
  // value list (§18.3.2.4 CT_Filter): only "North" rows visible.  The
  // viewer routes the row decision through
  // `spreadsheet_ml/autofilter/filter.mbt`, the same SoT used by the
  // public context API.
  cases.push({
    id: "autofilter-filtered",
    format: "xlsx",
    category: "table",
    content: xe(NS_S_TBL, "worksheet", [], [
      Element(
        xe(NS_S_TBL, "sheetData", [], [
          Element(
            s_row("1", [s_inline("A1", "Region"), s_inline("B1", "Sales")]),
          ),
          Element(s_row("2", [s_inline("A2", "North"), s_cell("B2", "120")])),
          Element(
            s_row_hidden("3", [s_inline("A3", "South"), s_cell("B3", "95")]),
          ),
          Element(
            s_row_hidden("4", [s_inline("A4", "East"), s_cell("B4", "180")]),
          ),
          Element(s_row("5", [s_inline("A5", "North"), s_cell("B5", "150")])),
        ]),
      ),
      Element(
        xe(NS_S_TBL, "autoFilter", [xa("ref", "A1:B5")], [
          Element(
            xe(NS_S_TBL, "filterColumn", [xa("colId", "0")], [
              Element(
                xe(NS_S_TBL, "filters", [], [
                  Element(xe(NS_S_TBL, "filter", [xa("val", "North")], [])),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    ]),
  })
  // AutoFilter with §18.3.2.10 `<top10>` carrying `filterVal`, the
  // persisted comparison threshold.  Rows filtered out by the saved
  // view are also persisted with `hidden="1"` so Office/Calc open the
  // generated fixture in the same view state.
  cases.push({
    id: "autofilter-top10-filterval",
    format: "xlsx",
    category: "table",
    content: xe(NS_S_TBL, "worksheet", [], [
      Element(
        xe(NS_S_TBL, "sheetData", [], [
          Element(
            s_row("1", [s_inline("A1", "Score"), s_inline("B1", "Label")]),
          ),
          Element(
            s_row_hidden("2", [s_cell("A2", "1"), s_inline("B2", "Drop one")]),
          ),
          Element(
            s_row_hidden("3", [s_cell("A3", "2"), s_inline("B3", "Drop two")]),
          ),
          Element(
            s_row_hidden("4", [s_cell("A4", "3"), s_inline("B4", "Drop three")]),
          ),
          Element(
            s_row_hidden("5", [s_cell("A5", "4"), s_inline("B5", "Drop four")]),
          ),
          Element(
            s_row_hidden("6", [s_cell("A6", "5"), s_inline("B6", "Drop five")]),
          ),
          Element(s_row("7", [s_cell("A7", "6"), s_inline("B7", "Keep six")])),
        ]),
      ),
      Element(
        xe(NS_S_TBL, "autoFilter", [xa("ref", "A1:B7")], [
          Element(
            xe(NS_S_TBL, "filterColumn", [xa("colId", "0")], [
              Element(
                xe(
                  NS_S_TBL,
                  "top10",
                  [xa("percent", "1"), xa("val", "50"), xa("filterVal", "6")],
                  [],
                ),
              ),
            ]),
          ),
        ]),
      ),
    ]),
  })
  // AutoFilter with §18.3.2.9 `<iconFilter>`. The worksheet also carries
  // §18.3.1.18 conditionalFormatting / §18.3.1.49 iconSet so a conformant
  // renderer can resolve each candidate row's icon bucket before the
  // AutoFilter package applies the iconFilter comparison. Filtered-out
  // rows are persisted with `hidden="1"` so Office/Calc open the saved
  // view in the same state as this package's renderer.
  cases.push({
    id: "autofilter-iconfilter-cf",
    format: "xlsx",
    category: "table",
    content: xe(NS_S_TBL, "worksheet", [], [
      Element(xe(NS_S_TBL, "dimension", [xa("ref", "A1:B4")], [])),
      Element(
        xe(NS_S_TBL, "sheetData", [], [
          Element(
            s_row("1", [s_inline("A1", "Score"), s_inline("B1", "Label")]),
          ),
          Element(
            s_row_hidden("2", [s_cell("A2", "10"), s_inline("B2", "Drop low")]),
          ),
          Element(
            s_row_hidden("3", [s_cell("A3", "30"), s_inline("B3", "Drop mid")]),
          ),
          Element(s_row("4", [s_cell("A4", "50"), s_inline("B4", "Keep high")])),
        ]),
      ),
      Element(
        xe(NS_S_TBL, "autoFilter", [xa("ref", "A1:B4")], [
          Element(
            xe(NS_S_TBL, "filterColumn", [xa("colId", "0")], [
              Element(
                xe(
                  NS_S_TBL,
                  "iconFilter",
                  [xa("iconSet", "3TrafficLights1"), xa("iconId", "2")],
                  [],
                ),
              ),
            ]),
          ),
        ]),
      ),
      Element(
        s_conditional_formatting("A2:A4", [
          s_cf_rule_icon_set("1", "3TrafficLights1", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("33")),
            s_cfvo("percent", Some("67")),
          ]),
        ]),
      ),
    ]),
  })
}

///|
/// Styled worksheet-level AutoFilter fixtures. These need `styles.xml`
/// because §18.3.2.1 colorFilter compares the candidate cell's resolved
/// style with the referenced `<dxf>` entry.
fn extras_sml_autofilter_styled(xcases : Array[ExtendedCase]) -> Unit {
  let autofilter_styles = xe(NS_S_TBL, "styleSheet", [], [
    Element(
      xe(NS_S_TBL, "fonts", [xa("count", "1")], [
        Element(ss_font("11", "Calibri", [])),
      ]),
    ),
    Element(
      xe(NS_S_TBL, "fills", [xa("count", "4")], [
        Element(ss_fill_none()),
        Element(ss_fill_gray125()),
        Element(ss_pattern_fill("solid", Some("FFFF0000"), None)),
        Element(ss_pattern_fill("solid", Some("FF00FF00"), None)),
      ]),
    ),
    Element(
      xe(NS_S_TBL, "borders", [xa("count", "1")], [Element(ss_border_none())]),
    ),
    Element(
      xe(NS_S_TBL, "cellXfs", [xa("count", "3")], [
        Element(ss_cell_xf("0", "0", "0", "0", None)),
        Element(ss_cell_xf("0", "0", "2", "0", None)),
        Element(ss_cell_xf("0", "0", "3", "0", None)),
      ]),
    ),
    Element(cf_dxfs([cf_dxf_solid_fill("FFFF0000")])),
  ])
  xcases.push({
    id: "autofilter-colorfilter-styled",
    format: "xlsx",
    category: "table",
    content: xe(NS_S_TBL, "worksheet", [], [
      Element(xe(NS_S_TBL, "dimension", [xa("ref", "A1:A4")], [])),
      Element(
        xe(NS_S_TBL, "sheetData", [], [
          Element(s_row("1", [s_inline("A1", "Status")])),
          Element(s_row("2", [s_inline_styled_x("A2", "Keep red", "1")])),
          Element(
            s_row_hidden("3", [s_inline_styled_x("A3", "Drop green", "2")]),
          ),
          Element(s_row("4", [s_inline_styled_x("A4", "Keep red again", "1")])),
        ]),
      ),
      Element(
        xe(NS_S_TBL, "autoFilter", [xa("ref", "A1:A4")], [
          Element(
            xe(NS_S_TBL, "filterColumn", [xa("colId", "0")], [
              Element(
                xe(
                  NS_S_TBL,
                  "colorFilter",
                  [xa("dxfId", "0"), xa("cellColor", "1")],
                  [],
                ),
              ),
            ]),
          ),
        ]),
      ),
    ]),
    styles: Some(autofilter_styles),
    numbering: None,
    doc_styles: None,
  })
}

// ---- TabledCase extender: TABLES with <tableParts> -----------------

///|
/// §18.5.1.2 `<table>` fixtures.  Each pushes one or more `<table>`
/// parts that the `xlsx_package_with_tables` builder turns into
/// `xl/tables/table{i+1}.xml` parts, wired into
/// `xl/worksheets/_rels/sheet1.xml.rels` and `<tableParts>` on the
/// worksheet automatically.  The fixture's `content` MUST NOT carry
/// its own `<tableParts>` — the builder appends it.
///
/// Pushed onto the `TabledCase` array via `tabled_cases()` in
/// `fixtures.mbt`.
fn extras_sml_tables(tcases : Array[TabledCase]) -> Unit {
  // ---- 1. Simple table with header row (no totals / no style) -----
  // §18.5.1.2 — minimum spec-valid table: id, name, displayName, ref,
  // and a `<tableColumns>` with one `<tableColumn>` per data column.
  // The header row is the FIRST row inside `ref` (`headerRowCount`
  // defaults to 1).
  tcases.push({
    id: "table-simple-header",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Name"),
          s_inline("B1", "Score"),
          s_inline("C1", "Rank"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "Alice"),
          s_cell("B2", "92"),
          s_cell("C2", "1"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "Bob"),
          s_cell("B3", "85"),
          s_cell("C3", "2"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "Carol"),
          s_cell("B4", "78"),
          s_cell("C4", "3"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Scores",
        "A1:C4",
        0,
        None,
        tbl_columns([
          tbl_column("1", "Name"),
          tbl_column("2", "Score"),
          tbl_column("3", "Rank"),
        ]),
        None,
      ),
    ],
  })
  // ---- 2. Table with a TOTALS ROW -------------------------------
  // §18.5.1.2 `totalsRowCount="1"` + per-column
  // `totalsRowFunction="..."` on data columns; the first column gets
  // `totalsRowLabel="Total"` so the band has a leading label.  Note
  // the `ref` spans the data PLUS the totals row at the bottom.
  tcases.push({
    id: "table-totals-row",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Item"),
          s_inline("B1", "Qty"),
          s_inline("C1", "Price"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "Apple"),
          s_cell("B2", "3"),
          s_cell("C2", "1.50"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "Bread"),
          s_cell("B3", "2"),
          s_cell("C3", "3.25"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "Cheese"),
          s_cell("B4", "1"),
          s_cell("C4", "8.00"),
        ]),
      ),
      // Totals row — formulas mirror what Excel inserts when totals
      // is enabled; conformant viewers paint them via the table band style.
      Element(
        s_row("5", [
          s_inline("A5", "Total"),
          s_formula("B5", "SUBTOTAL(109,B2:B4)", "6"),
          s_formula("C5", "SUBTOTAL(109,C2:C4)", "12.75"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "InvoiceTotals",
        "A1:C5",
        1,
        None,
        tbl_columns([
          tbl_column_totals_label("1", "Item", "Total"),
          tbl_column_totals("2", "Qty", "sum"),
          tbl_column_totals("3", "Price", "sum"),
        ]),
        None,
      ),
    ],
  })
  // ---- 3. Table with <tableStyleInfo> naming a built-in -----------
  // §18.5.1.5 — `name="TableStyleMedium2"` is the most common Excel
  // default.  `showRowStripes="1"` triggers the alternating-band
  // pattern that the renderer would paint on top of the cell fills.
  tcases.push({
    id: "table-styled-medium2",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Project"),
          s_inline("B1", "Owner"),
          s_inline("C1", "Status"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "Alpha"),
          s_inline("B2", "Alice"),
          s_inline("C2", "Done"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "Beta"),
          s_inline("B3", "Bob"),
          s_inline("C3", "WIP"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "Gamma"),
          s_inline("B4", "Carol"),
          s_inline("C4", "Open"),
        ]),
      ),
      Element(
        s_row("5", [
          s_inline("A5", "Delta"),
          s_inline("B5", "Dave"),
          s_inline("C5", "Open"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Projects",
        "A1:C5",
        0,
        None,
        tbl_columns([
          tbl_column("1", "Project"),
          tbl_column("2", "Owner"),
          tbl_column("3", "Status"),
        ]),
        Some(tbl_style_info("TableStyleMedium2", true, false)),
      ),
    ],
  })
  // ---- 4. Table with EMBEDDED <autoFilter> -----------------------
  // §18.5.1.2 — `<autoFilter>` inside `<table>` enables the
  // header-cell dropdown filter on every column of the table region.
  // Pairs well with the styled band so the filter arrows sit on a
  // banded header.
  tcases.push({
    id: "table-with-autofilter",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Region"),
          s_inline("B1", "Quarter"),
          s_inline("C1", "Revenue"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "North"),
          s_inline("B2", "Q1"),
          s_cell("C2", "120"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "North"),
          s_inline("B3", "Q2"),
          s_cell("C3", "140"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "South"),
          s_inline("B4", "Q1"),
          s_cell("C4", "95"),
        ]),
      ),
      Element(
        s_row("5", [
          s_inline("A5", "South"),
          s_inline("B5", "Q2"),
          s_cell("C5", "110"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Sales",
        "A1:C5",
        0,
        Some(tbl_auto_filter("A1:C5")),
        tbl_columns([
          tbl_column("1", "Region"),
          tbl_column("2", "Quarter"),
          tbl_column("3", "Revenue"),
        ]),
        Some(tbl_style_info("TableStyleLight9", true, false)),
      ),
    ],
  })
  // ---- 5. TWO ADJACENT TABLES on the same sheet -----------------
  // Exercises the multi-part pathway in `xlsx_package_with_tables`:
  // tables[0] → table1.xml (rId1), tables[1] → table2.xml (rId2),
  // both wired into the worksheet's `<tableParts>` in order.  The
  // two `<table>` regions are spatially disjoint (left + right
  // halves of the sheet) so the bands do not overlap.
  tcases.push({
    id: "table-adjacent-pair",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          // Left table header (cols A-B).
          s_inline("A1", "Fruit"),
          s_inline("B1", "Stock"),
          // Right table header (cols D-E) — column C is the gap.
          s_inline("D1", "Tool"),
          s_inline("E1", "Count"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "Apple"),
          s_cell("B2", "40"),
          s_inline("D2", "Hammer"),
          s_cell("E2", "12"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "Pear"),
          s_cell("B3", "25"),
          s_inline("D3", "Saw"),
          s_cell("E3", "8"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "Plum"),
          s_cell("B4", "18"),
          s_inline("D4", "Drill"),
          s_cell("E4", "5"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Fruits",
        "A1:B4",
        0,
        None,
        tbl_columns([tbl_column("1", "Fruit"), tbl_column("2", "Stock")]),
        Some(tbl_style_info("TableStyleMedium2", true, false)),
      ),
      tbl_table(
        "2",
        "Table2",
        "Tools",
        "D1:E4",
        0,
        None,
        tbl_columns([tbl_column("1", "Tool"), tbl_column("2", "Count")]),
        Some(tbl_style_info("TableStyleMedium6", true, false)),
      ),
    ],
  })
  // ---- 6. TABLE STYLE LIGHT 9 (header row only, no stripes) -----
  // §18.5.1.5 / §18.8.43 — `TableStyleLight9` is a popular pale
  // accent-blue style (light header band, no row striping, gray
  // accent border).  Exercises the chrome renderer's "header band
  // alone" code path on the same `<tableStyleInfo>` flag matrix Excel
  // ships by default for a freshly-inserted Light table.
  tcases.push({
    id: "table-styled-light9",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Sprint"),
          s_inline("B1", "Owner"),
          s_inline("C1", "Points"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "S1"),
          s_inline("B2", "Alice"),
          s_cell("C2", "13"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "S2"),
          s_inline("B3", "Bob"),
          s_cell("C3", "21"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "S3"),
          s_inline("B4", "Carol"),
          s_cell("C4", "8"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Sprints",
        "A1:C4",
        0,
        None,
        tbl_columns([
          tbl_column("1", "Sprint"),
          tbl_column("2", "Owner"),
          tbl_column("3", "Points"),
        ]),
        Some(tbl_style_info("TableStyleLight9", false, false)),
      ),
    ],
  })
  // ---- 7. TABLE STYLE MEDIUM 14 (red theme) ---------------------
  // §18.5.1.5 / §18.8.43 — `TableStyleMedium14` rotates the accent
  // palette to the red bucket (accent14 mod 7 = accent7 → dark blue
  // in our mapping; an Office "red" themed style ships as accent2-
  // orange-shifted in custom themes).  This fixture exercises a
  // higher-numbered medium suffix that exits the 1..7 base accent
  // range, validating the modulo wrap in `lookup_table_style_palette`.
  tcases.push({
    id: "table-styled-medium14",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Severity"),
          s_inline("B1", "Count"),
          s_inline("C1", "Trend"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "Critical"),
          s_cell("B2", "2"),
          s_inline("C2", "down"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "High"),
          s_cell("B3", "11"),
          s_inline("C3", "up"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "Medium"),
          s_cell("B4", "23"),
          s_inline("C4", "flat"),
        ]),
      ),
      Element(
        s_row("5", [
          s_inline("A5", "Low"),
          s_cell("B5", "37"),
          s_inline("C5", "down"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Alerts",
        "A1:C5",
        0,
        None,
        tbl_columns([
          tbl_column("1", "Severity"),
          tbl_column("2", "Count"),
          tbl_column("3", "Trend"),
        ]),
        Some(tbl_style_info("TableStyleMedium14", true, false)),
      ),
    ],
  })
  // ---- 8. COLUMN STRIPES ONLY (showColumnStripes="1") -----------
  // §18.5.1.5 — `showColumnStripes="1"` flips the chrome to band
  // columns instead of rows; alternates of the column stripe colour
  // every other DATA column.  Exercises the column-axis branch of
  // `render_table_chrome_under` independent of the row-stripe path.
  tcases.push({
    id: "table-column-stripes",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Region"),
          s_inline("B1", "Q1"),
          s_inline("C1", "Q2"),
          s_inline("D1", "Q3"),
          s_inline("E1", "Q4"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "North"),
          s_cell("B2", "12"),
          s_cell("C2", "15"),
          s_cell("D2", "18"),
          s_cell("E2", "20"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "South"),
          s_cell("B3", "9"),
          s_cell("C3", "11"),
          s_cell("D3", "14"),
          s_cell("E3", "16"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "East"),
          s_cell("B4", "18"),
          s_cell("C4", "22"),
          s_cell("D4", "25"),
          s_cell("E4", "27"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Quarterly",
        "A1:E4",
        0,
        None,
        tbl_columns([
          tbl_column("1", "Region"),
          tbl_column("2", "Q1"),
          tbl_column("3", "Q2"),
          tbl_column("4", "Q3"),
          tbl_column("5", "Q4"),
        ]),
        Some(tbl_style_info("TableStyleMedium2", false, true)),
      ),
    ],
  })
  // ---- 9. TABLE WITH EXPLICIT <colorFilter> AFTER SORT ----------
  // §18.3.2.6 CT_ColorFilter — the worksheet declares a sort state
  // (§18.3.2.6 `<sortState>`) AND a `<filterColumn>` carrying a
  // `<colorFilter dxfId="0">` child, which restricts visible rows
  // to those whose resolved cell-fill colour matches `dxfId=0`. The
  // renderer resolves the candidate cell format once, then delegates
  // colorFilter comparison to the AutoFilter package; the same payload
  // also keeps exercising OPC round-trip + autofilter chrome rendering
  // for non-value-based filters.
  let table_filter_styles = xe(NS_S_TBL, "styleSheet", [], [
    Element(
      xe(NS_S_TBL, "fonts", [xa("count", "1")], [
        Element(ss_font("11", "Calibri", [])),
      ]),
    ),
    Element(
      xe(NS_S_TBL, "fills", [xa("count", "4")], [
        Element(ss_fill_none()),
        Element(ss_fill_gray125()),
        Element(ss_pattern_fill("solid", Some("FFFF0000"), None)),
        Element(ss_pattern_fill("solid", Some("FF00FF00"), None)),
      ]),
    ),
    Element(
      xe(NS_S_TBL, "borders", [xa("count", "1")], [Element(ss_border_none())]),
    ),
    Element(
      xe(NS_S_TBL, "cellXfs", [xa("count", "3")], [
        Element(ss_cell_xf("0", "0", "0", "0", None)),
        Element(ss_cell_xf("0", "0", "2", "0", None)),
        Element(ss_cell_xf("0", "0", "3", "0", None)),
      ]),
    ),
    Element(cf_dxfs([cf_dxf_solid_fill("FFFF0000")])),
  ])
  tcases.push({
    id: "table-color-filter-after-sort",
    format: "xlsx",
    category: "table",
    styles: Some(table_filter_styles),
    content: xe(NS_S_TBL, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Item"),
          s_inline("B1", "Status"),
          s_inline("C1", "Owner"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "Alpha"),
          s_inline_styled_x("B2", "Open", "1"),
          s_inline("C2", "Alice"),
        ]),
      ),
      Element(
        s_row_hidden("3", [
          s_inline("A3", "Beta"),
          s_inline_styled_x("B3", "Done", "2"),
          s_inline("C3", "Bob"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "Gamma"),
          s_inline_styled_x("B4", "Open", "1"),
          s_inline("C4", "Carol"),
        ]),
      ),
      Element(
        s_row_hidden("5", [
          s_inline("A5", "Delta"),
          s_inline_styled_x("B5", "WIP", "2"),
          s_inline("C5", "Dave"),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Items",
        "A1:C5",
        0,
        // The autoFilter carries a filterColumn whose body is a
        // <colorFilter dxfId="0"/> per §18.3.2.6.  We also inline a
        // <sortState> sibling per §18.3.2.6 so the column-filter
        // round-trips alongside its sort context.
        Some(
          xe(NS_S_TBL, "autoFilter", [xa("ref", "A1:C5")], [
            Element(
              xe(NS_S_TBL, "filterColumn", [xa("colId", "1")], [
                Element(
                  xe(
                    NS_S_TBL,
                    "colorFilter",
                    [xa("dxfId", "0"), xa("cellColor", "1")],
                    [],
                  ),
                ),
              ]),
            ),
            Element(
              xe(NS_S_TBL, "sortState", [xa("ref", "A2:C5")], [
                Element(xe(NS_S_TBL, "sortCondition", [xa("ref", "A2:A5")], [])),
              ]),
            ),
          ]),
        ),
        tbl_columns([
          tbl_column("1", "Item"),
          tbl_column("2", "Status"),
          tbl_column("3", "Owner"),
        ]),
        Some(tbl_style_info("TableStyleMedium4", true, false)),
      ),
    ],
  })
  // ---- 10. TABLE WITH iconFilter FED BY worksheet iconSet --------
  // §18.3.2.9 CT_IconFilter inside the table part consumes the same
  // resolved §18.3.1.49 conditional-formatting bucket facts as a
  // worksheet-level AutoFilter. Rows hidden in the sheet keep the
  // persisted Office/Calc view aligned with the renderer's filter pass.
  tcases.push({
    id: "table-icon-filter-cf",
    format: "xlsx",
    category: "table",
    styles: None,
    content: xe(NS_S_TBL, "worksheet", [], [
      Element(xe(NS_S_TBL, "dimension", [xa("ref", "A1:B4")], [])),
      Element(
        xe(NS_S_TBL, "sheetData", [], [
          Element(
            s_row("1", [s_inline("A1", "Score"), s_inline("B1", "Label")]),
          ),
          Element(
            s_row_hidden("2", [s_cell("A2", "10"), s_inline("B2", "Drop low")]),
          ),
          Element(
            s_row_hidden("3", [s_cell("A3", "30"), s_inline("B3", "Drop mid")]),
          ),
          Element(s_row("4", [s_cell("A4", "50"), s_inline("B4", "Keep high")])),
        ]),
      ),
      Element(
        s_conditional_formatting("A2:A4", [
          s_cf_rule_icon_set("1", "3TrafficLights1", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("33")),
            s_cfvo("percent", Some("67")),
          ]),
        ]),
      ),
    ]),
    tables: [
      tbl_table(
        "1",
        "Table1",
        "Scores",
        "A1:B4",
        0,
        Some(
          xe(NS_S_TBL, "autoFilter", [xa("ref", "A1:B4")], [
            Element(
              xe(NS_S_TBL, "filterColumn", [xa("colId", "0")], [
                Element(
                  xe(
                    NS_S_TBL,
                    "iconFilter",
                    [xa("iconSet", "3TrafficLights1"), xa("iconId", "2")],
                    [],
                  ),
                ),
              ]),
            ),
          ]),
        ),
        tbl_columns([tbl_column("1", "Score"), tbl_column("2", "Label")]),
        Some(tbl_style_info("TableStyleMedium2", true, false)),
      ),
    ],
  })
}

// ---- PIVOT TABLES (§18.10) -------------------------------------
//
// Pivot fixtures are covered by `fixtures_sml_pivots.mbt`, using
// `xlsx_package_with_pivot` in verify.mbt to wire the worksheet,
// pivotTable, pivotCacheDefinition, and pivotCacheRecords parts into
// the same OPC relationship graph Excel emits.

// ---- SPARKLINES (§18.7 / x14:sparklineGroups) — gap documentation ----
//
// Sparklines are covered by `fixtures_sml_sparklines.mbt`, using the
// same namespace and extension URI SoT as `spreadsheet_ml/sparkline`.
