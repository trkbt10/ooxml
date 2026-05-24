// SpreadsheetML fixtures — cells, formulas, multi-row sheets.  Use
// `s_cell`, `s_row`, `s_inline`, `s_formula` from
// `fixtures_helpers.mbt`.  For styled fixtures that need a
// `styles.xml` part, push to `extra_extended_cases()` instead.

///|
/// A SpreadsheetML boolean cell — `<c t="b"><v>1</v></c>` (TRUE) or
/// `<c t="b"><v>0</v></c>` (FALSE).  ECMA-376 §18.3.1.4 / §18.18.11
/// type `b`.
fn s_bool(ref_ : String, true_ : Bool) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_), xa("t", "b")], [
    Element(xe(NS_S, "v", [], [Text(if true_ { "1" } else { "0" })])),
  ])
}

///|
/// A SpreadsheetML error cell — `<c t="e"><v>#DIV/0!</v></c>`.
/// ECMA-376 §18.18.11 type `e`; the value is one of the error-string
/// literals (#NULL!, #DIV/0!, #VALUE!, #REF!, #NAME?, #NUM!, #N/A).
fn s_error(ref_ : String, err : String) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_), xa("t", "e")], [
    Element(xe(NS_S, "v", [], [Text(err)])),
  ])
}

///|
/// A SpreadsheetML formula cell with NO cached `<v>` value — the
/// reader has to compute the result itself.  Exercises the recalc
/// branch of the loader where the cached value is absent.
fn s_formula_no_cache(ref_ : String, formula : String) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_)], [Element(xe(NS_S, "f", [], [Text(formula)]))])
}

///|
/// SpreadsheetML fixtures — pushes 20+ visual cases covering distinct
/// SML features not covered by the original `visual_cases()` list:
/// boolean / error cells, larger grids, mixed text+numeric layouts,
/// text and date / lookup formulas, cells with no cached value,
/// single-row / single-column / single-cell edge cases.
fn extras_sml(cases : Array[VisualCase]) -> Unit {
  // ---- xlsx / cell — edge-case shapes ---------------------------
  // A single isolated cell — smallest possible sheetData.
  cases.push({
    id: "cell-single",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Only")])),
    ]),
  })
  // A single row of many columns — wide-and-thin geometry.
  let wide_cells : Array[@xml.Element] = []
  let wide_cols = ["A", "B", "C", "D", "E", "F", "G", "H"]
  for ci, col in wide_cols {
    wide_cells.push(s_cell(col + "1", (ci * 10 + 1).to_string()))
  }
  cases.push({
    id: "cell-single-row-wide",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [Element(s_row("1", wide_cells))]),
  })
  // A single column of many rows — tall-and-thin geometry.
  let tall_rows : Array[@xml.Node] = []
  for r in 1..<13 {
    tall_rows.push(
      Element(
        s_row(r.to_string(), [s_cell("A" + r.to_string(), (r * 7).to_string())]),
      ),
    )
  }
  cases.push({
    id: "cell-single-column-tall",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], tall_rows),
  })

  // ---- xlsx / cell — typed values -------------------------------
  // Boolean cells in a tiny truth-table layout.
  cases.push({
    id: "cell-boolean",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Flag"), s_inline("B1", "Value")])),
      Element(s_row("2", [s_inline("A2", "Yes"), s_bool("B2", true)])),
      Element(s_row("3", [s_inline("A3", "No"), s_bool("B3", false)])),
    ]),
  })
  // Error-typed cells — one row per ECMA-376 error literal.
  cases.push({
    id: "cell-errors",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_inline("A1", "DivByZero"), s_error("B1", "#DIV/0!")]),
      ),
      Element(s_row("2", [s_inline("A2", "Value"), s_error("B2", "#VALUE!")])),
      Element(s_row("3", [s_inline("A3", "Ref"), s_error("B3", "#REF!")])),
      Element(s_row("4", [s_inline("A4", "Name"), s_error("B4", "#NAME?")])),
      Element(s_row("5", [s_inline("A5", "Num"), s_error("B5", "#NUM!")])),
      Element(s_row("6", [s_inline("A6", "NA"), s_error("B6", "#N/A")])),
    ]),
  })

  // ---- xlsx / cell — mixed text + numeric layouts ----------------
  // A two-column "label : value" table — common spreadsheet idiom.
  cases.push({
    id: "cell-label-value",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Name"), s_inline("B1", "Alice")])),
      Element(s_row("2", [s_inline("A2", "Age"), s_cell("B2", "30")])),
      Element(s_row("3", [s_inline("A3", "Salary"), s_cell("B3", "75000")])),
      Element(s_row("4", [s_inline("A4", "Years"), s_cell("B4", "5.5")])),
      Element(s_row("5", [s_inline("A5", "Manager"), s_inline("B5", "Bob")])),
    ]),
  })
  // A small invoice-like table — header row + data rows of mixed
  // types, exercising the inline-string + numeric pairing.
  cases.push({
    id: "cell-invoice-table",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Item"),
          s_inline("B1", "Qty"),
          s_inline("C1", "Price"),
          s_inline("D1", "Total"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "Apple"),
          s_cell("B2", "3"),
          s_cell("C2", "1.50"),
          s_cell("D2", "4.50"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "Bread"),
          s_cell("B3", "2"),
          s_cell("C3", "3.25"),
          s_cell("D3", "6.50"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "Cheese"),
          s_cell("B4", "1"),
          s_cell("C4", "8.00"),
          s_cell("D4", "8.00"),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cell — larger grids -------------------------------
  // A 10x10 numeric grid.  Stresses the renderer at scale and is
  // big enough that the layout / column auto-sizing must hold.
  let grid_10 : Array[@xml.Node] = []
  let cols10 = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
  for r in 1..<11 {
    let cells : Array[@xml.Element] = []
    for ci, col in cols10 {
      cells.push(s_cell(col + r.to_string(), (r * 10 + ci).to_string()))
    }
    grid_10.push(Element(s_row(r.to_string(), cells)))
  }
  cases.push({
    id: "cell-grid-10x10",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], grid_10),
  })
  // A 20x5 grid — tall, exercises the row-band rendering.
  let grid_tall : Array[@xml.Node] = []
  let cols5 = ["A", "B", "C", "D", "E"]
  for r in 1..<21 {
    let cells : Array[@xml.Element] = []
    for ci, col in cols5 {
      cells.push(s_cell(col + r.to_string(), (r + ci * 100).to_string()))
    }
    grid_tall.push(Element(s_row(r.to_string(), cells)))
  }
  cases.push({
    id: "cell-grid-20x5",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], grid_tall),
  })
  // A sparse grid — only a handful of cells with explicit refs
  // skipping intermediate rows / columns.  Exercises ref-based
  // (not positional) cell placement.
  cases.push({
    id: "cell-sparse",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_cell("A1", "1"), s_cell("E1", "5")])),
      Element(s_row("3", [s_cell("C3", "33")])),
      Element(s_row("5", [s_cell("A5", "51"), s_cell("E5", "55")])),
    ]),
  })

  // ---- xlsx / cell — number-shape variety -----------------------
  // Negative numbers, decimals, scientific notation.
  cases.push({
    id: "cell-number-shapes",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "neg"), s_cell("B1", "-42")])),
      Element(s_row("2", [s_inline("A2", "dec"), s_cell("B2", "3.14159")])),
      Element(s_row("3", [s_inline("A3", "sci"), s_cell("B3", "1.5E+10")])),
      Element(s_row("4", [s_inline("A4", "zero"), s_cell("B4", "0")])),
      Element(s_row("5", [s_inline("A5", "big"), s_cell("B5", "9999999")])),
    ]),
  })

  // ---- xlsx / cell — explicit row numbering ---------------------
  // A `<row>` may carry an explicit `customHeight` and gap-numbered
  // row indices (rows 1, 3, 5).  Tests the sheetData reader's
  // handling of non-sequential `r=` attributes.
  cases.push({
    id: "cell-row-gaps",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Top")])),
      Element(s_row("3", [s_inline("A3", "Middle")])),
      Element(s_row("5", [s_inline("A5", "Bottom")])),
    ]),
  })

  // ---- xlsx / formula — function categories ---------------------
  // Text functions: CONCAT / CONCATENATE / LEFT / RIGHT / LEN.
  cases.push({
    id: "formula-text",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Hello"), s_inline("B1", "World")])),
      Element(
        s_row("2", [
          s_inline("A2", "concat"),
          s_formula("B2", "CONCATENATE(A1,\" \",B1)", "Hello World"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "left"),
          s_formula("B3", "LEFT(A1,3)", "Hel"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "right"),
          s_formula("B4", "RIGHT(B1,3)", "rld"),
        ]),
      ),
      Element(
        s_row("5", [s_inline("A5", "len"), s_formula("B5", "LEN(A1)", "5")]),
      ),
      Element(
        s_row("6", [
          s_inline("A6", "upper"),
          s_formula("B6", "UPPER(A1)", "HELLO"),
        ]),
      ),
    ]),
  })
  // Lookup / boolean logic functions: IF / AND / OR / NOT.
  cases.push({
    id: "formula-logic",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_cell("A1", "10"), s_cell("B1", "20"), s_cell("C1", "30")]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "and"),
          s_formula("B2", "AND(A1>5,B1>5)", "TRUE"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "or"),
          s_formula("B3", "OR(A1>50,B1>15)", "TRUE"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "not"),
          s_formula("B4", "NOT(A1>100)", "TRUE"),
        ]),
      ),
      Element(
        s_row("5", [
          s_inline("A5", "if-nested"),
          s_formula("B5", "IF(A1>20,\"big\",IF(A1>5,\"mid\",\"small\"))", "mid"),
        ]),
      ),
    ]),
  })
  // Date / time functions — TODAY / NOW / YEAR / MONTH / DAY.
  // Cached values match an arbitrary 2024-01-15 reference.
  cases.push({
    id: "formula-datetime",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "ref"), s_cell("B1", "45306")])),
      Element(
        s_row("2", [s_inline("A2", "year"), s_formula("B2", "YEAR(B1)", "2024")]),
      ),
      Element(
        s_row("3", [s_inline("A3", "month"), s_formula("B3", "MONTH(B1)", "1")]),
      ),
      Element(
        s_row("4", [s_inline("A4", "day"), s_formula("B4", "DAY(B1)", "15")]),
      ),
    ]),
  })
  // Lookup functions — VLOOKUP / INDEX / MATCH.
  cases.push({
    id: "formula-lookup",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Key"), s_inline("B1", "Value")])),
      Element(s_row("2", [s_inline("A2", "x"), s_cell("B2", "100")])),
      Element(s_row("3", [s_inline("A3", "y"), s_cell("B3", "200")])),
      Element(s_row("4", [s_inline("A4", "z"), s_cell("B4", "300")])),
      Element(
        s_row("5", [
          s_inline("A5", "vlookup"),
          s_formula("B5", "VLOOKUP(\"y\",A2:B4,2,FALSE)", "200"),
        ]),
      ),
      Element(
        s_row("6", [
          s_inline("A6", "match"),
          s_formula("B6", "MATCH(\"z\",A2:A4,0)", "3"),
        ]),
      ),
    ]),
  })
  // Rounding / math functions — ROUND / ABS / SQRT / POWER.
  cases.push({
    id: "formula-math",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_cell("A1", "3.14159"), s_cell("B1", "-7")])),
      Element(
        s_row("2", [
          s_inline("A2", "round"),
          s_formula("B2", "ROUND(A1,2)", "3.14"),
        ]),
      ),
      Element(
        s_row("3", [s_inline("A3", "abs"), s_formula("B3", "ABS(B1)", "7")]),
      ),
      Element(
        s_row("4", [s_inline("A4", "sqrt"), s_formula("B4", "SQRT(16)", "4")]),
      ),
      Element(
        s_row("5", [
          s_inline("A5", "power"),
          s_formula("B5", "POWER(2,8)", "256"),
        ]),
      ),
      Element(
        s_row("6", [s_inline("A6", "mod"), s_formula("B6", "MOD(10,3)", "1")]),
      ),
    ]),
  })
  // Conditional aggregates — COUNTIF / SUMIF.
  cases.push({
    id: "formula-countif-sumif",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_cell("A1", "5"),
          s_cell("B1", "10"),
          s_cell("C1", "15"),
          s_cell("D1", "20"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "count>10"),
          s_formula("B2", "COUNTIF(A1:D1,\">10\")", "2"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "sum>=10"),
          s_formula("B3", "SUMIF(A1:D1,\">=10\")", "45"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "average"),
          s_formula("B4", "AVERAGEIF(A1:D1,\">5\")", "15"),
        ]),
      ),
    ]),
  })
  // Formulas WITHOUT a cached `<v>` — exercises the reader path
  // where the loader has nothing to display until it computes the
  // result itself.  Excel writes cached values, but the OOXML spec
  // permits omitting them.
  cases.push({
    id: "formula-no-cache",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_cell("A1", "1"), s_cell("B1", "2"), s_cell("C1", "3")]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "sum"),
          s_formula_no_cache("B2", "SUM(A1:C1)"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "product"),
          s_formula_no_cache("B3", "PRODUCT(A1:C1)"),
        ]),
      ),
    ]),
  })

  // ---- xlsx / sheet — full-worksheet shapes ---------------------
  // A worksheet with explicit `<dimension>` declaring the used
  // range — readers may use this to size the grid up front instead
  // of scanning `<sheetData>`.
  cases.push({
    id: "sheet-dimension",
    format: "xlsx",
    category: "sheet",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "dimension", [xa("ref", "A1:C3")], [])),
      Element(
        xe(NS_S, "sheetData", [], [
          Element(
            s_row("1", [
              s_inline("A1", "X"),
              s_inline("B1", "Y"),
              s_inline("C1", "Z"),
            ]),
          ),
          Element(
            s_row("2", [s_cell("A2", "1"), s_cell("B2", "2"), s_cell("C2", "3")]),
          ),
          Element(
            s_row("3", [s_cell("A3", "4"), s_cell("B3", "5"), s_cell("C3", "6")]),
          ),
        ]),
      ),
    ]),
  })
  // A worksheet with FROZEN PANES via `<sheetViews>` — the first
  // row is frozen so the header sticks during scroll.  Exercises
  // the sheet-view reader.
  cases.push({
    id: "sheet-frozen-header",
    format: "xlsx",
    category: "sheet",
    content: xe(NS_S, "worksheet", [], [
      Element(
        xe(NS_S, "sheetViews", [], [
          Element(
            xe(NS_S, "sheetView", [xa("workbookViewId", "0")], [
              Element(
                xe(
                  NS_S,
                  "pane",
                  [
                    xa("ySplit", "1"),
                    xa("topLeftCell", "A2"),
                    xa("activePane", "bottomLeft"),
                    xa("state", "frozen"),
                  ],
                  [],
                ),
              ),
            ]),
          ),
        ]),
      ),
      Element(
        xe(NS_S, "sheetData", [], [
          Element(
            s_row("1", [
              s_inline("A1", "Hdr1"),
              s_inline("B1", "Hdr2"),
              s_inline("C1", "Hdr3"),
            ]),
          ),
          Element(
            s_row("2", [
              s_cell("A2", "11"),
              s_cell("B2", "22"),
              s_cell("C2", "33"),
            ]),
          ),
          Element(
            s_row("3", [
              s_cell("A3", "44"),
              s_cell("B3", "55"),
              s_cell("C3", "66"),
            ]),
          ),
        ]),
      ),
    ]),
  })
  // A worksheet with MULTIPLE merged ranges — both a header
  // (A1:C1) and a side label (D2:D3).  Exercises the merge-list
  // accumulator.
  cases.push({
    id: "sheet-multi-merge",
    format: "xlsx",
    category: "sheet",
    content: xe(NS_S, "worksheet", [], [
      Element(
        xe(NS_S, "sheetData", [], [
          Element(s_row("1", [s_inline("A1", "Sales by Region")])),
          Element(
            s_row("2", [
              s_inline("A2", "N"),
              s_inline("B2", "S"),
              s_inline("C2", "E"),
              s_inline("D2", "Note"),
            ]),
          ),
          Element(
            s_row("3", [
              s_cell("A3", "100"),
              s_cell("B3", "150"),
              s_cell("C3", "200"),
            ]),
          ),
        ]),
      ),
      Element(
        xe(NS_S, "mergeCells", [xa("count", "2")], [
          Element(xe(NS_S, "mergeCell", [xa("ref", "A1:D1")], [])),
          Element(xe(NS_S, "mergeCell", [xa("ref", "D2:D3")], [])),
        ]),
      ),
    ]),
  })
  // A worksheet with explicit row HEIGHTS — `<row ht="...">` sets
  // a custom height per row.  Tests the row-height reader.
  cases.push({
    id: "sheet-row-heights",
    format: "xlsx",
    category: "sheet",
    content: xe(NS_S, "worksheet", [], [
      Element(
        xe(NS_S, "sheetData", [], [
          Element(
            xe(
              NS_S,
              "row",
              [xa("r", "1"), xa("ht", "30"), xa("customHeight", "1")],
              [
                Element(s_inline("A1", "Tall")),
                Element(s_inline("B1", "Header")),
              ],
            ),
          ),
          Element(
            xe(
              NS_S,
              "row",
              [xa("r", "2"), xa("ht", "15"), xa("customHeight", "1")],
              [Element(s_cell("A2", "1")), Element(s_cell("B2", "2"))],
            ),
          ),
          Element(
            xe(
              NS_S,
              "row",
              [xa("r", "3"), xa("ht", "45"), xa("customHeight", "1")],
              [Element(s_cell("A3", "3")), Element(s_cell("B3", "4"))],
            ),
          ),
        ]),
      ),
    ]),
  })
  // A worksheet with mixed wide / narrow COLUMN widths — three
  // explicit columns at 5 / 25 / 10 character units.
  cases.push({
    id: "sheet-mixed-col-widths",
    format: "xlsx",
    category: "sheet",
    content: xe(NS_S, "worksheet", [], [
      Element(
        xe(NS_S, "cols", [], [
          Element(
            xe(
              NS_S,
              "col",
              [
                xa("min", "1"),
                xa("max", "1"),
                xa("width", "5"),
                xa("customWidth", "1"),
              ],
              [],
            ),
          ),
          Element(
            xe(
              NS_S,
              "col",
              [
                xa("min", "2"),
                xa("max", "2"),
                xa("width", "25"),
                xa("customWidth", "1"),
              ],
              [],
            ),
          ),
          Element(
            xe(
              NS_S,
              "col",
              [
                xa("min", "3"),
                xa("max", "3"),
                xa("width", "10"),
                xa("customWidth", "1"),
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S, "sheetData", [], [
          Element(
            s_row("1", [
              s_inline("A1", "#"),
              s_inline("B1", "Long Description Column"),
              s_inline("C1", "Amount"),
            ]),
          ),
          Element(
            s_row("2", [
              s_cell("A2", "1"),
              s_inline("B2", "First quarter total revenue"),
              s_cell("C2", "1200"),
            ]),
          ),
          Element(
            s_row("3", [
              s_cell("A3", "2"),
              s_inline("B3", "Second quarter total revenue"),
              s_cell("C3", "1450"),
            ]),
          ),
        ]),
      ),
    ]),
  })
}
