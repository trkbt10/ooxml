// SpreadsheetML PIVOT TABLES — ECMA-376 §18.10.
//
// Each fixture supplies four `@xml.Element` trees that
// `xlsx_package_with_pivot` in verify.mbt wires into a complete
// `.xlsx` package:
//
//   * `content` — the worksheet `<sheetData>` (source table the
//     pivot summarises plus a few blank rows under the pivot's
//     `<location/@ref>`).
//   * `cache_def` — the §18.10.1.67 `<pivotCacheDefinition>` with
//     `<cacheSource>` + `<cacheFields>` (one per source column).
//   * `cache_records` — the §18.10.1.68 `<pivotCacheRecords>`,
//     one `<r>` per source row referencing shared-items indices.
//   * `pivot_def` — the §18.10.1.73 `<pivotTableDefinition>` with
//     `<location/@ref>`, `<pivotFields>`, `<rowFields>`,
//     `<colFields>`, `<dataFields>`, etc.
//
// The builder forces `@cacheId="0"` on the workbook's
// `<pivotCaches>` entry, so every `pivot_def` here uses `cacheId="0"`.
//
// Renderer support (svg_render.mbt → pivot_render.mbt, this round):
//   * Materializes the pivot via `@pivot_table.materialize_pivot_table`
//     at facade time (`Workbook::to_svg`).
//   * Paints the resulting row × col × data-field grid at
//     `<location/@ref>` with a single-row header band, a single
//     row-axis caption column, bold formatting for headers /
//     totals, a top-border on the row grand-total, a left-border
//     on the col grand-total, and a double-border on the overall
//     grand-total cell.
//
// Deferred features (called out per fixture below):
//   * `<pivotTableStyleInfo>` table-style chrome (no banded fills /
//     theme-driven header colours).
//   * `<conditionalFormatting>` overlays on pivot cells (§18.10.1.20).
//   * `<calculatedFields>` (§18.10.1.11) — the materializer treats
//     them as plain cache fields if shared items are present;
//     otherwise the bucket is empty.
//   * `<filters>` / `<pageFields>` dropdown chrome (the records are
//     filtered; the dropdown UI is not drawn).
//   * Compact / outline layouts (`@compact`, `@outline`).
//   * Multi-level row / col grouping (§18.10.1.44 `@r` repeat-count
//     collapse) — every row / col key renders as a single label cell
//     joined by " / ".

///|
/// SpreadsheetML namespace shorthand local to this file.
const NS_S_PVT : String = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"

// ---- file-local element / record helpers --------------------------

///|
/// `<cacheSource type="worksheet"><worksheetSource ref="..."
/// sheet="..."/></cacheSource>` — §18.10.1.7 / §18.10.1.95.
fn cache_source_worksheet(sheet : String, ref_ : String) -> @xml.Element {
  xe(NS_S_PVT, "cacheSource", [xa("type", "worksheet")], [
    Element(
      xe(NS_S_PVT, "worksheetSource", [xa("ref", ref_), xa("sheet", sheet)], []),
    ),
  ])
}

///|
/// `<cacheField name="..."><sharedItems>…<s v="…"/>…</sharedItems></cacheField>`
/// for a string-valued column. §18.10.1.3 + §18.10.1.90.
fn cache_field_strings(name : String, values : Array[String]) -> @xml.Element {
  let item_nodes : Array[@xml.Node] = []
  for v in values {
    item_nodes.push(Element(xe(NS_S_PVT, "s", [xa("v", v)], [])))
  }
  let shared_items_attrs : Array[@xml.Attribute] = [
    xa("count", values.length().to_string()),
  ]
  xe(NS_S_PVT, "cacheField", [xa("name", name), xa("numFmtId", "0")], [
    Element(xe(NS_S_PVT, "sharedItems", shared_items_attrs, item_nodes)),
  ])
}

///|
/// `<cacheField name="..."><sharedItems containsNumber="1" .../></cacheField>`
/// for a numeric column that the data field summarises. The shared-
/// items table is left empty (§18.10.1.90 — `<sharedItems/>` is
/// permitted; the records use inline `<n v="…">` literals) so the
/// fixture stays compact.
fn cache_field_numbers_inline(name : String) -> @xml.Element {
  xe(NS_S_PVT, "cacheField", [xa("name", name), xa("numFmtId", "0")], [
    Element(
      xe(
        NS_S_PVT,
        "sharedItems",
        [
          xa("containsSemiMixedTypes", "0"),
          xa("containsString", "0"),
          xa("containsNumber", "1"),
        ],
        [],
      ),
    ),
  ])
}

///|
/// `<cacheFields count="N">` wrapper.
fn cache_fields_wrap(fields : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for f in fields {
    kids.push(Element(f))
  }
  xe(NS_S_PVT, "cacheFields", [xa("count", fields.length().to_string())], kids)
}

///|
/// Wrap a `<cacheSource>` + `<cacheFields>` into a
/// `<pivotCacheDefinition>`. The minimal spec-valid root.
fn cache_def_root(
  source : @xml.Element,
  fields : @xml.Element,
  record_count : Int,
) -> @xml.Element {
  xe(
    NS_S_PVT,
    "pivotCacheDefinition",
    [
      xa("recordCount", record_count.to_string()),
      xa("createdVersion", "3"),
      xa("refreshedVersion", "3"),
    ],
    [Element(source), Element(fields)],
  )
}

///|
/// `<r>` row child — `<x v="N"/>` for shared-items references at
/// the positions listed in `ref_columns`, `<n v="…">` for the
/// numeric inline values at the positions listed in
/// `num_columns`. The two collections are zipped against
/// `total_columns` so the row carries one cell per cacheField.
fn record_row(cells : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cells {
    kids.push(Element(c))
  }
  xe(NS_S_PVT, "r", [], kids)
}

///|
/// `<x v="N"/>` — shared-items reference cell.
fn rec_x(idx : Int) -> @xml.Element {
  xe(NS_S_PVT, "x", [xa("v", idx.to_string())], [])
}

///|
/// `<n v="…"/>` — numeric inline literal cell.
fn rec_n(value : String) -> @xml.Element {
  xe(NS_S_PVT, "n", [xa("v", value)], [])
}

///|
/// Wrap a list of `<r>` rows into `<pivotCacheRecords count="N">`.
fn records_root(rows : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for r in rows {
    kids.push(Element(r))
  }
  xe(
    NS_S_PVT,
    "pivotCacheRecords",
    [xa("count", rows.length().to_string())],
    kids,
  )
}

///|
/// `<location ref="..." firstHeaderRow="..." firstDataRow="..."
/// firstDataCol="..."/>` — §18.10.1.49.
fn pivot_location(
  ref_ : String,
  first_header_row : Int,
  first_data_row : Int,
  first_data_col : Int,
) -> @xml.Element {
  xe(
    NS_S_PVT,
    "location",
    [
      xa("ref", ref_),
      xa("firstHeaderRow", first_header_row.to_string()),
      xa("firstDataRow", first_data_row.to_string()),
      xa("firstDataCol", first_data_col.to_string()),
    ],
    [],
  )
}

///|
/// `<pivotField …>` with an optional `<items>` child for the per-
/// field item dictionary. `axis`: `"axisRow"` / `"axisCol"` /
/// `"axisPage"` / `""` (omitted). `data_field`: when true, sets
/// `dataField="1"`. `items_count`: when > 0, emits `<items
/// count="N+1">` with N concrete `<item x="0..N-1"/>` followed by
/// `<item t="default"/>`.
fn pivot_field(
  axis : String,
  data_field : Bool,
  items_count : Int,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  if axis != "" {
    attrs.push(xa("axis", axis))
  }
  if data_field {
    attrs.push(xa("dataField", "1"))
  }
  attrs.push(xa("compact", "0"))
  attrs.push(xa("outline", "0"))
  attrs.push(xa("showAll", "0"))
  let kids : Array[@xml.Node] = []
  if items_count > 0 {
    let item_kids : Array[@xml.Node] = []
    for i in 0..<items_count {
      item_kids.push(
        Element(xe(NS_S_PVT, "item", [xa("x", i.to_string())], [])),
      )
    }
    item_kids.push(Element(xe(NS_S_PVT, "item", [xa("t", "default")], [])))
    kids.push(
      Element(
        xe(
          NS_S_PVT,
          "items",
          [xa("count", (items_count + 1).to_string())],
          item_kids,
        ),
      ),
    )
  }
  xe(NS_S_PVT, "pivotField", attrs, kids)
}

///|
/// `<pivotFields count="N">` wrapper.
fn pivot_fields_wrap(fields : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for f in fields {
    kids.push(Element(f))
  }
  xe(NS_S_PVT, "pivotFields", [xa("count", fields.length().to_string())], kids)
}

///|
/// `<rowFields count="N"><field x="..."/></rowFields>` — list of
/// cacheField indices that partition the rows. §18.10.1.83.
fn axis_fields(name : String, indices : Array[Int]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for i in indices {
    kids.push(Element(xe(NS_S_PVT, "field", [xa("x", i.to_string())], [])))
  }
  xe(NS_S_PVT, name, [xa("count", indices.length().to_string())], kids)
}

///|
/// `<dataField name="..." fld="..." subtotal="..." baseField="0"
/// baseItem="0"/>` — §18.10.1.22.
fn data_field_entry(
  name : String,
  fld : Int,
  subtotal : String,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    xa("name", name),
    xa("fld", fld.to_string()),
  ]
  if subtotal != "sum" {
    attrs.push(xa("subtotal", subtotal))
  }
  attrs.push(xa("baseField", "0"))
  attrs.push(xa("baseItem", "0"))
  xe(NS_S_PVT, "dataField", attrs, [])
}

///|
/// `<dataFields count="N">` wrapper.
fn data_fields_wrap(fields : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for f in fields {
    kids.push(Element(f))
  }
  xe(NS_S_PVT, "dataFields", [xa("count", fields.length().to_string())], kids)
}

///|
/// Build a single-row item entry `<i><x v="N"/></i>` or
/// `<i t="grand"><x/></i>` for the rowItems / colItems lists.
fn pivot_axis_item(indices : Array[Int], grand : Bool) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  if grand {
    attrs.push(xa("t", "grand"))
  }
  let kids : Array[@xml.Node] = []
  for i in indices {
    kids.push(Element(xe(NS_S_PVT, "x", [xa("v", i.to_string())], [])))
  }
  if indices.length() == 0 {
    kids.push(Element(xe(NS_S_PVT, "x", [], [])))
  }
  xe(NS_S_PVT, "i", attrs, kids)
}

///|
/// `<rowItems count="N">` / `<colItems count="N">` wrapper.
fn axis_items_wrap(name : String, items : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for it in items {
    kids.push(Element(it))
  }
  xe(NS_S_PVT, name, [xa("count", items.length().to_string())], kids)
}

///|
/// Assemble a `<pivotTableDefinition>` root from the building
/// blocks. The optional `row_grand` / `col_grand` flags override the
/// spec defaults (both true) when the fixture wants to test
/// suppression. §18.10.1.73.
fn pivot_def_root(
  name : String,
  location : @xml.Element,
  pivot_fields : @xml.Element,
  row_fields_el : @xml.Element?,
  col_fields_el : @xml.Element?,
  row_items_el : @xml.Element,
  col_items_el : @xml.Element,
  data_fields_el : @xml.Element,
  row_grand : Bool,
  col_grand : Bool,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    xa("name", name),
    xa("cacheId", "0"),
    xa("dataCaption", "Values"),
    xa("createdVersion", "3"),
    xa("updatedVersion", "3"),
    xa("minRefreshableVersion", "3"),
    xa("useAutoFormatting", "1"),
    xa("itemPrintTitles", "1"),
    xa("indent", "0"),
    xa("compact", "0"),
    xa("compactData", "0"),
    xa("gridDropZones", "1"),
  ]
  if !row_grand {
    attrs.push(xa("rowGrandTotals", "0"))
  }
  if !col_grand {
    attrs.push(xa("colGrandTotals", "0"))
  }
  let kids : Array[@xml.Node] = [Element(location), Element(pivot_fields)]
  match row_fields_el {
    Some(rf) => kids.push(Element(rf))
    None => ()
  }
  match col_fields_el {
    Some(cf) => kids.push(Element(cf))
    None => ()
  }
  kids.push(Element(row_items_el))
  kids.push(Element(col_items_el))
  kids.push(Element(data_fields_el))
  xe(NS_S_PVT, "pivotTableDefinition", attrs, kids)
}

// ---- PivotedCase extender ----------------------------------------

///|
/// §18.10 PivotTable fixtures.  Five distinct shapes:
///
///   1. `pivot-2field-sum`     — one row + one col + sum value
///   2. `pivot-grand-totals`   — same shape with row + col grand
///                                totals on (spec defaults).
///   3. `pivot-multi-values`   — two data fields (sum + count) on a
///                                single row axis.
///   4. `pivot-row-grouping`   — two row fields nested (Region/City).
///   5. `pivot-no-grand`       — explicit `rowGrandTotals="0"` +
///                                `colGrandTotals="0"` to verify the
///                                materializer suppresses the
///                                grand-total band.
///
/// Each fixture sits in the `pivot` category so the snapshot harness
/// groups them under `.snapshots/fixtures/xlsx/pivot/<id>.xlsx`.
fn extras_sml_pivots(pcases : Array[PivotedCase]) -> Unit {
  // ---- shared source-data block ---------------------------------
  // Six source rows × three columns:
  //   Region (string)  | Product (string) | Sales (number)
  // The source range is A1:C7 on the worksheet; the pivot is drawn
  // below the data starting at row 10 so the two grids do not
  // overlap.
  fn source_sheet() -> @xml.Element {
    xe(NS_S_PVT, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Region"),
          s_inline("B1", "Product"),
          s_inline("C1", "Sales"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "North"),
          s_inline("B2", "Apple"),
          s_cell("C2", "100"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "North"),
          s_inline("B3", "Bread"),
          s_cell("C3", "50"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "South"),
          s_inline("B4", "Apple"),
          s_cell("C4", "80"),
        ]),
      ),
      Element(
        s_row("5", [
          s_inline("A5", "South"),
          s_inline("B5", "Bread"),
          s_cell("C5", "120"),
        ]),
      ),
      Element(
        s_row("6", [
          s_inline("A6", "East"),
          s_inline("B6", "Apple"),
          s_cell("C6", "60"),
        ]),
      ),
      Element(
        s_row("7", [
          s_inline("A7", "East"),
          s_inline("B7", "Bread"),
          s_cell("C7", "40"),
        ]),
      ),
    ])
  }
  // Shared cache definition: three fields. Region's shared items are
  // [North, South, East]; Product's are [Apple, Bread]; Sales is
  // inline numeric.
  fn shared_cache_def() -> @xml.Element {
    cache_def_root(
      cache_source_worksheet("S1", "A1:C7"),
      cache_fields_wrap([
        cache_field_strings("Region", ["North", "South", "East"]),
        cache_field_strings("Product", ["Apple", "Bread"]),
        cache_field_numbers_inline("Sales"),
      ]),
      6,
    )
  }
  // Shared records: six rows referencing the shared items by index
  // for Region (0/1/2) and Product (0/1), with inline numeric Sales.
  fn shared_cache_records() -> @xml.Element {
    records_root([
      // North/Apple/100, North/Bread/50, South/Apple/80, South/Bread/120,
      // East/Apple/60,  East/Bread/40.
      record_row([rec_x(0), rec_x(0), rec_n("100")]),
      record_row([rec_x(0), rec_x(1), rec_n("50")]),
      record_row([rec_x(1), rec_x(0), rec_n("80")]),
      record_row([rec_x(1), rec_x(1), rec_n("120")]),
      record_row([rec_x(2), rec_x(0), rec_n("60")]),
      record_row([rec_x(2), rec_x(1), rec_n("40")]),
    ])
  }
  // ---- 1. 2-field pivot: one row, one column, sum value --------
  // §18.10.1.83 rowFields=[Region]; §18.10.1.14 colFields=[Product];
  // §18.10.1.22 dataFields=[Sum of Sales]. Default grand totals OFF
  // for the smallest possible body grid.
  // Deferred: pivotTableStyleInfo bands, conditional formatting.
  let pivot_def_2field = pivot_def_root(
    "Pivot2Field",
    // Row range covers the header (3) + axis caption row + 3 region
    // data rows; columns cover the row-axis caption + 2 product
    // values.
    pivot_location("E1:H6", 0, 2, 1),
    pivot_fields_wrap([
      // Region (axisRow)
      pivot_field("axisRow", false, 3),
      // Product (axisCol)
      pivot_field("axisCol", false, 2),
      // Sales (data)
      pivot_field("", true, 0),
    ]),
    Some(axis_fields("rowFields", [0])),
    Some(axis_fields("colFields", [1])),
    axis_items_wrap("rowItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
      pivot_axis_item([2], false),
    ]),
    axis_items_wrap("colItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
    ]),
    data_fields_wrap([data_field_entry("Sum of Sales", 2, "sum")]),
    false,
    false,
  )
  pcases.push({
    id: "pivot-2field-sum",
    format: "xlsx",
    category: "pivot",
    content: source_sheet(),
    cache_def: shared_cache_def(),
    cache_records: shared_cache_records(),
    pivot_def: pivot_def_2field,
  })
  // ---- 2. Grand totals on both axes ------------------------------
  // §18.10.1.73 rowGrandTotals / colGrandTotals default to true; this
  // fixture relies on the defaults (no override attribute) and the
  // resulting pivot grows by one row + one column for the grand
  // totals, plus a single bottom-right "overall" grand cell.
  // Deferred: same as fixture 1.
  let pivot_def_grand = pivot_def_root(
    "PivotGrand",
    pivot_location("E1:H8", 0, 2, 1),
    pivot_fields_wrap([
      pivot_field("axisRow", false, 3),
      pivot_field("axisCol", false, 2),
      pivot_field("", true, 0),
    ]),
    Some(axis_fields("rowFields", [0])),
    Some(axis_fields("colFields", [1])),
    axis_items_wrap("rowItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
      pivot_axis_item([2], false),
      pivot_axis_item([], true),
    ]),
    axis_items_wrap("colItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
      pivot_axis_item([], true),
    ]),
    data_fields_wrap([data_field_entry("Sum of Sales", 2, "sum")]),
    true,
    true,
  )
  pcases.push({
    id: "pivot-grand-totals",
    format: "xlsx",
    category: "pivot",
    content: source_sheet(),
    cache_def: shared_cache_def(),
    cache_records: shared_cache_records(),
    pivot_def: pivot_def_grand,
  })
  // ---- 3. Multiple value fields (sum + count) -------------------
  // §18.10.1.22 — two `<dataField>` entries on the same value
  // (Sales): the first sums, the second counts. The materializer
  // emits one cell per (row, col, dataField) so the column band
  // fans out to 2 × col_keys cells (sum / count per Product).
  // Deferred: pivotField/@dataField bit (Excel marks the dataField
  // pivotField; we do this on the third pivotField below but the
  // renderer does not use the flag).
  let pivot_def_multi_values = pivot_def_root(
    "PivotMultiValues",
    pivot_location("E1:I7", 0, 3, 1),
    pivot_fields_wrap([
      pivot_field("axisRow", false, 3),
      pivot_field("axisCol", false, 2),
      pivot_field("", true, 0),
    ]),
    Some(axis_fields("rowFields", [0])),
    // The data-field pseudo-position belongs on the colFields when
    // multiple values share one column band; we encode -2 as the
    // unsigned `4294967294` per §18.10.1.83.
    Some(
      xe(NS_S_PVT, "colFields", [xa("count", "2")], [
        Element(xe(NS_S_PVT, "field", [xa("x", "1")], [])),
        Element(xe(NS_S_PVT, "field", [xa("x", "-2")], [])),
      ]),
    ),
    axis_items_wrap("rowItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
      pivot_axis_item([2], false),
    ]),
    axis_items_wrap("colItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
    ]),
    data_fields_wrap([
      data_field_entry("Sum of Sales", 2, "sum"),
      data_field_entry("Count of Sales", 2, "count"),
    ]),
    false,
    false,
  )
  pcases.push({
    id: "pivot-multi-values",
    format: "xlsx",
    category: "pivot",
    content: source_sheet(),
    cache_def: shared_cache_def(),
    cache_records: shared_cache_records(),
    pivot_def: pivot_def_multi_values,
  })
  // ---- 4. Row grouping (Region + Product on the row axis) -------
  // §18.10.1.83 — two row fields nested. The materializer interns
  // the tuple `(Region, Product)` so the row axis carries one cell
  // per unique pair. No column axis fields → a single
  // "Values" column.
  // Deferred: §18.10.1.44 `@r` repeat-count grouping — every nested
  // tuple renders as one cell joined by " / ".
  let pivot_def_grouping = pivot_def_root(
    "PivotGrouping",
    pivot_location("E1:F9", 0, 1, 1),
    pivot_fields_wrap([
      pivot_field("axisRow", false, 3),
      pivot_field("axisRow", false, 2),
      pivot_field("", true, 0),
    ]),
    Some(axis_fields("rowFields", [0, 1])),
    None,
    axis_items_wrap("rowItems", [
      pivot_axis_item([0, 0], false),
      pivot_axis_item([0, 1], false),
      pivot_axis_item([1, 0], false),
      pivot_axis_item([1, 1], false),
      pivot_axis_item([2, 0], false),
      pivot_axis_item([2, 1], false),
    ]),
    axis_items_wrap("colItems", [pivot_axis_item([], false)]),
    data_fields_wrap([data_field_entry("Sum of Sales", 2, "sum")]),
    false,
    false,
  )
  pcases.push({
    id: "pivot-row-grouping",
    format: "xlsx",
    category: "pivot",
    content: source_sheet(),
    cache_def: shared_cache_def(),
    cache_records: shared_cache_records(),
    pivot_def: pivot_def_grouping,
  })
  // ---- 5. Explicit no-grand-totals (rowGrandTotals="0" +
  //                                    colGrandTotals="0") --------
  // §18.10.1.73 — overrides both grand-total flags so the
  // materializer does NOT append `RowGrand` / `ColGrand` sentinels
  // and the renderer paints a plain 3 × 2 body.
  let pivot_def_no_grand = pivot_def_root(
    "PivotNoGrand",
    pivot_location("E1:G5", 0, 2, 1),
    pivot_fields_wrap([
      pivot_field("axisRow", false, 3),
      pivot_field("axisCol", false, 2),
      pivot_field("", true, 0),
    ]),
    Some(axis_fields("rowFields", [0])),
    Some(axis_fields("colFields", [1])),
    axis_items_wrap("rowItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
      pivot_axis_item([2], false),
    ]),
    axis_items_wrap("colItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
    ]),
    data_fields_wrap([data_field_entry("Sum of Sales", 2, "sum")]),
    false,
    false,
  )
  pcases.push({
    id: "pivot-no-grand",
    format: "xlsx",
    category: "pivot",
    content: source_sheet(),
    cache_def: shared_cache_def(),
    cache_records: shared_cache_records(),
    pivot_def: pivot_def_no_grand,
  })
}
