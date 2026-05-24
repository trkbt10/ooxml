// SpreadsheetML advanced fixtures — covers grid shapes, sheet
// formatting properties, boolean / empty cells, very-long inline
// strings, extreme numeric values, accounting / calendar layouts and
// cross-row formula references not yet exercised by
// `fixtures_sml.mbt`.
//
// All helpers used here (`s_cell`, `s_row`, `s_inline`, `s_formula`,
// `xe`, `xa`, `NS_S`) live in `fixtures_helpers.mbt`.

///|
/// Build an empty SpreadsheetML cell — `<c r="A1"/>` with neither
/// type nor value.  Per ECMA-376 §18.3.1.4 a cell with no inner
/// element and no `t=` attribute still carries layout weight (it
/// reserves a column position) but has no displayable content.
fn s_empty_cell(ref_ : String) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_)], [])
}

///|
/// Build a `<sheetFormatPr>` element with the requested default
/// column width and / or default row height.  Either value can be
/// the empty string to omit it.  ECMA-376 §18.3.1.81.
fn s_sheet_format_pr(
  default_col_width : String,
  default_row_height : String,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  if default_col_width != "" {
    attrs.push(xa("defaultColWidth", default_col_width))
  }
  if default_row_height != "" {
    attrs.push(xa("defaultRowHeight", default_row_height))
  }
  xe(NS_S, "sheetFormatPr", attrs, [])
}

///|
/// SpreadsheetML advanced fixtures — pushes 15 visual cases covering
/// SML features not exercised by `extras_sml()`:
/// larger and varied grid shapes, sheetFormatPr defaults, boolean
/// cells at varied positions, intermixed empty / valued cells, very
/// long inline strings, extreme numeric magnitudes, multi-row
/// header+data tables, an income-statement layout, a calendar grid
/// and cross-row formula references.
fn extras_sml_advanced(cases : Array[VisualCase]) -> Unit {
  // ---- xlsx / cell — varied grid shapes -------------------------
  // 1. A long-tail 50x3 grid — many rows × few columns.  Stresses
  // row-band rendering at scale.
  let cols3 = ["A", "B", "C"]
  let grid_50x3 : Array[@xml.Node] = []
  for r in 1..<51 {
    let cells : Array[@xml.Element] = []
    for ci, col in cols3 {
      cells.push(s_cell(col + r.to_string(), (r * 3 + ci).to_string()))
    }
    grid_50x3.push(Element(s_row(r.to_string(), cells)))
  }
  cases.push({
    id: "cell-grid-50x3",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], grid_50x3),
  })

  // 2. A 3x30 grid — few rows × many columns.  Exercises the
  // column-band path in the opposite direction.
  let cols30 = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
    "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA", "AB", "AC", "AD",
  ]
  let grid_3x30 : Array[@xml.Node] = []
  for r in 1..<4 {
    let cells : Array[@xml.Element] = []
    for ci, col in cols30 {
      cells.push(s_cell(col + r.to_string(), (r * 100 + ci).to_string()))
    }
    grid_3x30.push(Element(s_row(r.to_string(), cells)))
  }
  cases.push({
    id: "cell-grid-3x30",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], grid_3x30),
  })

  // 3. A 7x12 mixed-content grid — text headers + numeric body.
  // Closer to a real spreadsheet shape than the pure-numeric grids.
  let cols7 = ["A", "B", "C", "D", "E", "F", "G"]
  let day_names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  let grid_7x12 : Array[@xml.Node] = []
  // Header row 1 — day-of-week labels.
  let header_cells : Array[@xml.Element] = []
  for ci, col in cols7 {
    header_cells.push(s_inline(col + "1", day_names[ci]))
  }
  grid_7x12.push(Element(s_row("1", header_cells)))
  // 11 data rows with mixed text+numbers.
  for r in 2..<13 {
    let cells : Array[@xml.Element] = []
    for ci, col in cols7 {
      if ci == 0 {
        // First column = a label like "Week N".
        cells.push(s_inline(col + r.to_string(), "Wk" + (r - 1).to_string()))
      } else {
        cells.push(s_cell(col + r.to_string(), ((r - 1) * 7 + ci).to_string()))
      }
    }
    grid_7x12.push(Element(s_row(r.to_string(), cells)))
  }
  cases.push({
    id: "cell-grid-7x12-mixed",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], grid_7x12),
  })

  // ---- xlsx / sheet — sheetFormatPr defaults --------------------
  // 4. A worksheet with explicit `defaultColWidth` — every column
  // without a `<col>` override uses this width.
  cases.push({
    id: "sheet-default-col-width",
    format: "xlsx",
    category: "sheet",
    content: xe(NS_S, "worksheet", [], [
      Element(s_sheet_format_pr("18", "")),
      Element(
        xe(NS_S, "sheetData", [], [
          Element(
            s_row("1", [
              s_inline("A1", "Wide"),
              s_inline("B1", "Default"),
              s_inline("C1", "Cols"),
            ]),
          ),
          Element(
            s_row("2", [
              s_cell("A2", "10"),
              s_cell("B2", "20"),
              s_cell("C2", "30"),
            ]),
          ),
        ]),
      ),
    ]),
  })

  // 5. A worksheet with explicit `defaultRowHeight` — every row
  // without a `<row ht=...>` override uses this height.
  cases.push({
    id: "sheet-default-row-height",
    format: "xlsx",
    category: "sheet",
    content: xe(NS_S, "worksheet", [], [
      Element(s_sheet_format_pr("", "24")),
      Element(
        xe(NS_S, "sheetData", [], [
          Element(s_row("1", [s_inline("A1", "Row1")])),
          Element(s_row("2", [s_inline("A2", "Row2")])),
          Element(s_row("3", [s_inline("A3", "Row3")])),
          Element(s_row("4", [s_inline("A4", "Row4")])),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cell — boolean cells at varied positions ----------
  // 6. Boolean cells distributed across columns (not just B-column)
  // and rows — exercises the `t="b"` reader at varied refs.
  cases.push({
    id: "cell-boolean-scattered",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "P"),
          s_inline("B1", "Q"),
          s_inline("C1", "R"),
          s_inline("D1", "S"),
        ]),
      ),
      Element(
        s_row("2", [
          s_bool("A2", true),
          s_bool("B2", false),
          s_bool("C2", true),
          s_bool("D2", false),
        ]),
      ),
      Element(
        s_row("3", [
          s_bool("A3", false),
          s_bool("B3", true),
          s_bool("C3", false),
          s_bool("D3", true),
        ]),
      ),
      Element(
        s_row("4", [
          s_bool("A4", true),
          s_bool("B4", true),
          s_bool("C4", false),
          s_bool("D4", false),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cell — empty cells interspersed with valued -------
  // 7. A row with empty cells (`<c r="..."/>`) gap-spaced between
  // valued cells — the renderer must reserve column positions for
  // the empties so subsequent valued cells land in the right
  // columns.
  cases.push({
    id: "cell-empty-interspersed",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "A"),
          s_empty_cell("B1"),
          s_inline("C1", "C"),
          s_empty_cell("D1"),
          s_inline("E1", "E"),
        ]),
      ),
      Element(
        s_row("2", [
          s_empty_cell("A2"),
          s_cell("B2", "2"),
          s_empty_cell("C2"),
          s_cell("D2", "4"),
          s_empty_cell("E2"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "X"),
          s_empty_cell("B3"),
          s_empty_cell("C3"),
          s_empty_cell("D3"),
          s_inline("E3", "Y"),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cell — very long inline strings -------------------
  // 8. A single very long inline string — exercises the text-layout
  // overflow / column-extension path.
  let long_text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed " +
    "do eiusmod tempor incididunt ut labore et dolore magna aliqua. " +
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco."
  cases.push({
    id: "cell-long-inline-string",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Note"), s_inline("B1", long_text)])),
      Element(s_row("2", [s_inline("A2", "OK"), s_cell("B2", "1")])),
    ]),
  })

  // ---- xlsx / cell — extreme numeric magnitudes -----------------
  // 9. Mixed extreme numeric magnitudes — negative, very small, very
  // large, zero, common.  Exercises the numeric-formatter at the
  // ends of its supported range.
  cases.push({
    id: "cell-number-extremes",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_inline("A1", "neg-big"), s_cell("B1", "-1234567890")]),
      ),
      Element(
        s_row("2", [s_inline("A2", "neg-small"), s_cell("B2", "-0.0001")]),
      ),
      Element(s_row("3", [s_inline("A3", "tiny"), s_cell("B3", "1E-10")])),
      Element(s_row("4", [s_inline("A4", "huge"), s_cell("B4", "1E+15")])),
      Element(s_row("5", [s_inline("A5", "zero"), s_cell("B5", "0")])),
      Element(s_row("6", [s_inline("A6", "one"), s_cell("B6", "1")])),
    ]),
  })

  // ---- xlsx / cell — multi-row tables ---------------------------
  // 10. A header + 6 data rows table — common spreadsheet shape.
  cases.push({
    id: "cell-multi-row-table",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "ID"),
          s_inline("B1", "Name"),
          s_inline("C1", "Score"),
          s_inline("D1", "Grade"),
        ]),
      ),
      Element(
        s_row("2", [
          s_cell("A2", "101"),
          s_inline("B2", "Alice"),
          s_cell("C2", "95"),
          s_inline("D2", "A"),
        ]),
      ),
      Element(
        s_row("3", [
          s_cell("A3", "102"),
          s_inline("B3", "Bob"),
          s_cell("C3", "82"),
          s_inline("D3", "B"),
        ]),
      ),
      Element(
        s_row("4", [
          s_cell("A4", "103"),
          s_inline("B4", "Carol"),
          s_cell("C4", "76"),
          s_inline("D4", "C"),
        ]),
      ),
      Element(
        s_row("5", [
          s_cell("A5", "104"),
          s_inline("B5", "Dave"),
          s_cell("C5", "89"),
          s_inline("D5", "B"),
        ]),
      ),
      Element(
        s_row("6", [
          s_cell("A6", "105"),
          s_inline("B6", "Eve"),
          s_cell("C6", "67"),
          s_inline("D6", "D"),
        ]),
      ),
      Element(
        s_row("7", [
          s_cell("A7", "106"),
          s_inline("B7", "Frank"),
          s_cell("C7", "91"),
          s_inline("D7", "A"),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cell — income-statement layout --------------------
  // 11. 3-column accounting-style table: label + amount + total.
  // Exercises right-aligned numeric content in a layout typical of
  // financial statements.
  cases.push({
    id: "cell-income-statement",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Item"),
          s_inline("B1", "Amount"),
          s_inline("C1", "Total"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "Revenue"),
          s_cell("B2", "120000"),
          s_cell("C2", "120000"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "Cost of Goods"),
          s_cell("B3", "-45000"),
          s_cell("C3", "75000"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "Operating Expenses"),
          s_cell("B4", "-25000"),
          s_cell("C4", "50000"),
        ]),
      ),
      Element(
        s_row("5", [
          s_inline("A5", "Net Income"),
          s_cell("B5", "0"),
          s_cell("C5", "50000"),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cell — calendar layout ----------------------------
  // 12. 7-col × 5-row calendar grid with day-of-month numbers (mix
  // of empty cells at start, then sequential 1..31).  Real-world
  // layout pattern.
  let cal_cols = ["A", "B", "C", "D", "E", "F", "G"]
  let cal_rows : Array[@xml.Node] = []
  // Header row — day names.
  let cal_header : Array[@xml.Element] = []
  for ci, col in cal_cols {
    cal_header.push(s_inline(col + "1", day_names[ci]))
  }
  cal_rows.push(Element(s_row("1", cal_header)))
  // Build a 4-week + partial calendar starting Wed (skip Mon-Tue
  // in week 1).
  let mut day = 0
  for week in 1..<6 {
    let row_cells : Array[@xml.Element] = []
    for ci, col in cal_cols {
      let cell_ref = col + (week + 1).to_string()
      if week == 1 && ci < 2 {
        // Leading empties for Mon-Tue of week 1.
        row_cells.push(s_empty_cell(cell_ref))
      } else if day >= 31 {
        row_cells.push(s_empty_cell(cell_ref))
      } else {
        day = day + 1
        row_cells.push(s_cell(cell_ref, day.to_string()))
      }
    }
    cal_rows.push(Element(s_row((week + 1).to_string(), row_cells)))
  }
  cases.push({
    id: "cell-calendar-7x5",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], cal_rows),
  })

  // ---- xlsx / formula — cross-row references --------------------
  // 13. Formulas referencing across rows: a running-total column
  // built from the previous row's running total plus the current
  // row's amount.
  cases.push({
    id: "formula-running-total",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Item"),
          s_inline("B1", "Amount"),
          s_inline("C1", "Running"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "a"),
          s_cell("B2", "10"),
          s_formula("C2", "B2", "10"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "b"),
          s_cell("B3", "20"),
          s_formula("C3", "C2+B3", "30"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "c"),
          s_cell("B4", "30"),
          s_formula("C4", "C3+B4", "60"),
        ]),
      ),
      Element(
        s_row("5", [
          s_inline("A5", "d"),
          s_cell("B5", "40"),
          s_formula("C5", "C4+B5", "100"),
        ]),
      ),
    ]),
  })

  // 14. Formulas referencing cells in distant rows — a "totals at
  // bottom" pattern where row N references rows 2..N-1.
  cases.push({
    id: "formula-bottom-totals",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Q"), s_inline("B1", "Sales")])),
      Element(s_row("2", [s_inline("A2", "Q1"), s_cell("B2", "100")])),
      Element(s_row("3", [s_inline("A3", "Q2"), s_cell("B3", "150")])),
      Element(s_row("4", [s_inline("A4", "Q3"), s_cell("B4", "175")])),
      Element(s_row("5", [s_inline("A5", "Q4"), s_cell("B5", "225")])),
      Element(
        s_row("6", [s_inline("A6", "Sum"), s_formula("B6", "SUM(B2:B5)", "650")]),
      ),
      Element(
        s_row("7", [
          s_inline("A7", "Avg"),
          s_formula("B7", "AVERAGE(B2:B5)", "162.5"),
        ]),
      ),
      Element(
        s_row("8", [s_inline("A8", "Max"), s_formula("B8", "MAX(B2:B5)", "225")]),
      ),
      Element(
        s_row("9", [s_inline("A9", "Min"), s_formula("B9", "MIN(B2:B5)", "100")]),
      ),
    ]),
  })

  // 15. Sheet combining sheetFormatPr defaults with a real data
  // layout — both `defaultColWidth` and `defaultRowHeight` set.
  cases.push({
    id: "sheet-defaults-combined",
    format: "xlsx",
    category: "sheet",
    content: xe(NS_S, "worksheet", [], [
      Element(s_sheet_format_pr("15", "20")),
      Element(
        xe(NS_S, "sheetData", [], [
          Element(
            s_row("1", [
              s_inline("A1", "Item"),
              s_inline("B1", "Qty"),
              s_inline("C1", "Price"),
            ]),
          ),
          Element(
            s_row("2", [
              s_inline("A2", "Pen"),
              s_cell("B2", "5"),
              s_cell("C2", "1.25"),
            ]),
          ),
          Element(
            s_row("3", [
              s_inline("A3", "Pad"),
              s_cell("B3", "2"),
              s_cell("C3", "3.50"),
            ]),
          ),
          Element(
            s_row("4", [
              s_inline("A4", "Clip"),
              s_cell("B4", "10"),
              s_cell("C4", "0.10"),
            ]),
          ),
        ]),
      ),
    ]),
  })
}
