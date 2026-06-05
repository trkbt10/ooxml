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
//   * Calculated cache fields (`<cacheField @formula>` §18.10.1.3)
//     are materialized and filtered through `pivot-filter-calc-value`.
//     Calculated items / members remain deferred.
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
/// Calculated cache field (§18.10.1.3) carrying a formula instead of
/// per-record values. Pivot cache records omit cells for these fields.
fn cache_field_calculated(name : String, formula : String) -> @xml.Element {
  xe(
    NS_S_PVT,
    "cacheField",
    [
      xa("name", name),
      xa("numFmtId", "0"),
      xa("databaseField", "0"),
      xa("formula", formula),
    ],
    [
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
    ],
  )
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
  pivot_field_with_hidden_items(axis, data_field, items_count, [])
}

///|
/// `<pivotField …>` variant that marks selected shared-item indices hidden.
/// Real spreadsheet applications use this item visibility state when
/// opening cached PivotTables; the `<filters>` element records the advanced
/// filter definition.
fn pivot_field_with_hidden_items(
  axis : String,
  data_field : Bool,
  items_count : Int,
  hidden_items : Array[Int],
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
      let item_attrs = [xa("x", i.to_string())]
      if int_array_contains(hidden_items, i) {
        item_attrs.push(xa("h", "1"))
      }
      item_kids.push(Element(xe(NS_S_PVT, "item", item_attrs, [])))
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
fn int_array_contains(values : Array[Int], target : Int) -> Bool {
  for value in values {
    if value == target {
      return true
    }
  }
  false
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
/// `<dataField name="..." fld="..." subtotal="..."/>` — §18.10.1.22.
/// `baseField` / `baseItem` are only meaningful with showDataAs
/// calculations; emitting them on plain aggregate fields makes Excel
/// repair the pivotTable part.
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
/// `<filters><filter><autoFilter>…</autoFilter></filter></filters>`
/// — §18.10.1.33 / §18.10.1.34 PivotTable advanced filter wrapper.
fn pivot_filters_wrap(filters : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for filter in filters {
    kids.push(Element(filter))
  }
  xe(NS_S_PVT, "filters", [xa("count", filters.length().to_string())], kids)
}

///|
/// Label filter for one cache field, expressed through the shared
/// SpreadsheetML AutoFilter child. The materializer delegates the
/// comparison to `spreadsheet_ml/autofilter`.
fn pivot_caption_equals_filter(
  fld : Int,
  id : Int,
  value : String,
) -> @xml.Element {
  xe(
    NS_S_PVT,
    "filter",
    [
      xa("fld", fld.to_string()),
      xa("type", "captionEqual"),
      xa("id", id.to_string()),
      xa("stringValue1", value),
    ],
    [
      Element(
        xe(NS_S_PVT, "autoFilter", [xa("ref", "A1")], [
          Element(
            xe(NS_S_PVT, "filterColumn", [xa("colId", "0")], [
              Element(
                xe(NS_S_PVT, "filters", [], [
                  Element(xe(NS_S_PVT, "filter", [xa("val", value)], [])),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    ],
  )
}

///|
/// Value filter for one row/column field. The candidate value is the
/// selected data-field aggregate; PivotTable materialization delegates the
/// custom comparison to the shared SpreadsheetML AutoFilter evaluator.
fn pivot_sum_greater_than_filter(
  fld : Int,
  id : Int,
  data_field_index : Int,
  threshold : String,
) -> @xml.Element {
  xe(
    NS_S_PVT,
    "filter",
    [
      xa("fld", fld.to_string()),
      xa("type", "sum"),
      xa("id", id.to_string()),
      xa("iMeasureFld", data_field_index.to_string()),
    ],
    [
      Element(
        xe(NS_S_PVT, "autoFilter", [xa("ref", "A1")], [
          Element(
            xe(NS_S_PVT, "filterColumn", [xa("colId", "0")], [
              Element(
                xe(NS_S_PVT, "customFilters", [], [
                  Element(
                    xe(
                      NS_S_PVT,
                      "customFilter",
                      [xa("operator", "greaterThan"), xa("val", threshold)],
                      [],
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    ],
  )
}

///|
/// Append a `<filters>` collection to a pivotTableDefinition produced by
/// `pivot_def_root`. This keeps the common root helper stable while adding
/// the §18.10.1.34 child in schema order after `<pivotTableStyleInfo>`.
fn pivot_def_with_filters(
  root : @xml.Element,
  filters : @xml.Element,
) -> @xml.Element {
  let children : Array[@xml.Node] = []
  for child in root.children {
    children.push(child)
  }
  children.push(Element(filters))
  { name: root.name, attributes: root.attributes, children }
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
  kids.push(Element(row_items_el))
  match col_fields_el {
    Some(cf) => kids.push(Element(cf))
    None => ()
  }
  kids.push(Element(col_items_el))
  kids.push(Element(data_fields_el))
  kids.push(
    Element(
      xe(
        NS_S_PVT,
        "pivotTableStyleInfo",
        [
          xa("name", "PivotStyleLight16"),
          xa("showRowHeaders", "1"),
          xa("showColHeaders", "1"),
          xa("showRowStripes", "0"),
          xa("showColStripes", "0"),
          xa("showLastColumn", "0"),
        ],
        [],
      ),
    ),
  )
  xe(NS_S_PVT, "pivotTableDefinition", attrs, kids)
}

///|
/// Pivot-area scope reused by calculated items, formats, chart formats,
/// conditional formats, and auto-sort scopes. It targets one concrete
/// item in a single field so the schema-visible reference chain
/// (`pivotArea` → `references` → `reference` → `x`) is exercised.
fn pivot_area_scope(
  field : Int,
  axis : String,
  item_index : Int,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    xa("field", field.to_string()),
    xa("type", "normal"),
    xa("axis", axis),
    xa("fieldPosition", "0"),
  ]
  xe(NS_S_PVT, "pivotArea", attrs, [
    Element(
      xe(NS_S_PVT, "references", [xa("count", "1")], [
        Element(
          xe(
            NS_S_PVT,
            "reference",
            [xa("field", field.to_string()), xa("count", "1")],
            [Element(xe(NS_S_PVT, "x", [xa("v", item_index.to_string())], []))],
          ),
        ),
      ]),
    ),
  ])
}

///|
/// Region cache field with grouping and member-property map children.
/// The operational pivot still uses the ordinary sharedItems table;
/// `fieldGroup`, `discretePr`, `groupItems`, and `mpMap` are present
/// to drive the schema/domain readers through the deeper cache-field
/// branches without changing the rendered aggregate.
fn grouped_region_cache_field() -> @xml.Element {
  xe(NS_S_PVT, "cacheField", [xa("name", "Region"), xa("numFmtId", "0")], [
    Element(
      xe(NS_S_PVT, "sharedItems", [xa("count", "3")], [
        Element(xe(NS_S_PVT, "s", [xa("v", "North")], [])),
        Element(xe(NS_S_PVT, "s", [xa("v", "South")], [])),
        Element(xe(NS_S_PVT, "s", [xa("v", "East")], [])),
      ]),
    ),
    Element(
      xe(NS_S_PVT, "fieldGroup", [xa("base", "0")], [
        Element(
          xe(
            NS_S_PVT,
            "rangePr",
            [
              xa("autoStart", "0"),
              xa("autoEnd", "0"),
              xa("groupBy", "range"),
              xa("startNum", "0"),
              xa("endNum", "2"),
              xa("groupInterval", "1"),
            ],
            [],
          ),
        ),
        Element(
          xe(NS_S_PVT, "discretePr", [xa("count", "2")], [
            Element(xe(NS_S_PVT, "x", [xa("v", "0")], [])),
            Element(xe(NS_S_PVT, "x", [xa("v", "1")], [])),
          ]),
        ),
        Element(
          xe(NS_S_PVT, "groupItems", [xa("count", "6")], [
            Element(xe(NS_S_PVT, "m", [], [])),
            Element(xe(NS_S_PVT, "n", [xa("v", "1")], [])),
            Element(xe(NS_S_PVT, "b", [xa("v", "1")], [])),
            Element(xe(NS_S_PVT, "e", [xa("v", "#N/A")], [])),
            Element(xe(NS_S_PVT, "s", [xa("v", "Grouped")], [])),
            Element(xe(NS_S_PVT, "d", [xa("v", "2026-01-01T00:00:00Z")], [])),
          ]),
        ),
      ]),
    ),
    Element(xe(NS_S_PVT, "mpMap", [xa("v", "0")], [])),
  ])
}

///|
/// Rich pivotCacheDefinition observation payload. The first two
/// required children remain a normal worksheet-backed cache; subsequent
/// optional branches cover OLAP metadata containers that are parsed and
/// schema-validated but intentionally ignored by the non-OLAP renderer.
fn observation_cache_def() -> @xml.Element {
  xe(
    NS_S_PVT,
    "pivotCacheDefinition",
    [
      xa("recordCount", "6"),
      xa("createdVersion", "3"),
      xa("refreshedVersion", "3"),
      xa("minRefreshableVersion", "3"),
      xa("tupleCache", "1"),
      xa("supportSubquery", "1"),
      xa("supportAdvancedDrill", "1"),
    ],
    [
      Element(cache_source_worksheet("S1", "A1:C7")),
      Element(
        cache_fields_wrap([
          grouped_region_cache_field(),
          cache_field_strings("Product", ["Apple", "Bread"]),
          cache_field_numbers_inline("Sales"),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "cacheHierarchies", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "cacheHierarchy",
              [
                xa("uniqueName", "[Region]"),
                xa("caption", "Region"),
                xa("count", "1"),
                xa("oneField", "1"),
              ],
              [
                Element(
                  xe(NS_S_PVT, "fieldsUsage", [xa("count", "1")], [
                    Element(xe(NS_S_PVT, "fieldUsage", [xa("x", "0")], [])),
                  ]),
                ),
                Element(
                  xe(NS_S_PVT, "groupLevels", [xa("count", "1")], [
                    Element(
                      xe(
                        NS_S_PVT,
                        "groupLevel",
                        [
                          xa("uniqueName", "[Region].[Grouped]"),
                          xa("caption", "Grouped"),
                        ],
                        [
                          Element(
                            xe(NS_S_PVT, "groups", [xa("count", "1")], [
                              Element(
                                xe(
                                  NS_S_PVT,
                                  "group",
                                  [
                                    xa("name", "Core"),
                                    xa(
                                      "uniqueName", "[Region].[Grouped].[Core]",
                                    ),
                                    xa("caption", "Core"),
                                    xa("id", "1"),
                                  ],
                                  [
                                    Element(
                                      xe(
                                        NS_S_PVT,
                                        "groupMembers",
                                        [xa("count", "2")],
                                        [
                                          Element(
                                            xe(
                                              NS_S_PVT,
                                              "groupMember",
                                              [
                                                xa(
                                                  "uniqueName", "[Region].[North]",
                                                ),
                                              ],
                                              [],
                                            ),
                                          ),
                                          Element(
                                            xe(
                                              NS_S_PVT,
                                              "groupMember",
                                              [
                                                xa(
                                                  "uniqueName", "[Region].[South]",
                                                ),
                                              ],
                                              [],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "kpis", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "kpi",
              [
                xa("uniqueName", "[Measures].[Sales KPI]"),
                xa("caption", "Sales KPI"),
                xa("value", "[Measures].[Sales]"),
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "tupleCache", [], [
          Element(
            xe(NS_S_PVT, "entries", [xa("count", "1")], [
              Element(xe(NS_S_PVT, "s", [xa("v", "[Region].[North]")], [])),
            ]),
          ),
          Element(
            xe(NS_S_PVT, "sets", [xa("count", "1")], [
              Element(
                xe(
                  NS_S_PVT,
                  "set",
                  [
                    xa("count", "1"),
                    xa("maxRank", "1"),
                    xa("setDefinition", "{[Region].[North]}"),
                  ],
                  [
                    Element(
                      xe(NS_S_PVT, "tpls", [xa("c", "1")], [
                        Element(
                          xe(
                            NS_S_PVT,
                            "tpl",
                            [xa("fld", "0"), xa("hier", "0"), xa("item", "0")],
                            [],
                          ),
                        ),
                      ]),
                    ),
                    Element(
                      xe(NS_S_PVT, "sortByTuple", [xa("c", "1")], [
                        Element(
                          xe(
                            NS_S_PVT,
                            "tpl",
                            [xa("fld", "0"), xa("hier", "0"), xa("item", "0")],
                            [],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Element(
            xe(NS_S_PVT, "queryCache", [xa("count", "1")], [
              Element(
                xe(
                  NS_S_PVT,
                  "query",
                  [xa("mdx", "SELECT {[Region].[North]} ON 0")],
                  [
                    Element(
                      xe(NS_S_PVT, "tpls", [xa("c", "1")], [
                        Element(
                          xe(
                            NS_S_PVT,
                            "tpl",
                            [xa("fld", "0"), xa("hier", "0"), xa("item", "0")],
                            [],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Element(
            xe(NS_S_PVT, "serverFormats", [xa("count", "1")], [
              Element(
                xe(
                  NS_S_PVT,
                  "serverFormat",
                  [xa("culture", "en-US"), xa("format", "General")],
                  [],
                ),
              ),
            ]),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "calculatedItems", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "calculatedItem",
              [xa("field", "0"), xa("formula", "North+South")],
              [Element(pivot_area_scope(0, "axisRow", 0))],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "calculatedMembers", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "calculatedMember",
              [
                xa("name", "NorthAndSouth"),
                xa("mdx", "[Region].[North]+[Region].[South]"),
                xa("hierarchy", "[Region]"),
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "dimensions", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "dimension",
              [
                xa("name", "Region"),
                xa("uniqueName", "[Region]"),
                xa("caption", "Region"),
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "measureGroups", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "measureGroup",
              [xa("name", "Sales"), xa("caption", "Sales")],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "maps", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "map",
              [xa("measureGroup", "0"), xa("dimension", "0")],
              [],
            ),
          ),
        ]),
      ),
    ],
  )
}

///|
/// Pivot field variant that places an `autoSortScope` after the normal
/// item dictionary, matching CT_PivotField child order.
fn pivot_field_with_autosort(
  axis : String,
  data_field : Bool,
  items_count : Int,
  sort_field : Int,
) -> @xml.Element {
  let base = pivot_field(axis, data_field, items_count)
  let kids : Array[@xml.Node] = []
  for child in base.children {
    kids.push(child)
  }
  kids.push(
    Element(
      xe(NS_S_PVT, "autoSortScope", [], [
        Element(pivot_area_scope(sort_field, axis, 0)),
      ]),
    ),
  )
  { name: base.name, attributes: base.attributes, children: kids }
}

///|
/// PivotTableDefinition with schema-rich optional branches after the
/// operational row/page/data-field core. The renderer uses the core
/// fields; validators and domain readers traverse the format, chart,
/// hierarchy-usage, and pivot-area subtrees.
fn observation_pivot_def() -> @xml.Element {
  xe(
    NS_S_PVT,
    "pivotTableDefinition",
    [
      xa("name", "PivotObservationRich"),
      xa("cacheId", "0"),
      xa("dataCaption", "Values"),
      xa("createdVersion", "3"),
      xa("updatedVersion", "3"),
      xa("minRefreshableVersion", "3"),
      xa("rowGrandTotals", "0"),
      xa("colGrandTotals", "0"),
      xa("compact", "0"),
      xa("compactData", "0"),
      xa("gridDropZones", "1"),
    ],
    [
      Element(pivot_location("E1:F5", 0, 1, 1)),
      Element(
        pivot_fields_wrap([
          pivot_field_with_autosort("axisRow", false, 3, 0),
          pivot_field("axisPage", false, 2),
          pivot_field("", true, 0),
        ]),
      ),
      Element(axis_fields("rowFields", [0])),
      Element(
        axis_items_wrap("rowItems", [
          pivot_axis_item([0], false),
          pivot_axis_item([1], false),
          pivot_axis_item([2], false),
        ]),
      ),
      Element(axis_items_wrap("colItems", [pivot_axis_item([], false)])),
      Element(
        xe(NS_S_PVT, "pageFields", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "pageField",
              [
                xa("fld", "1"),
                xa("item", "0"),
                xa("hier", "0"),
                xa("name", "Product"),
                xa("cap", "Apple"),
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(data_fields_wrap([data_field_entry("Sum of Sales", 2, "sum")])),
      Element(
        xe(NS_S_PVT, "formats", [xa("count", "1")], [
          Element(
            xe(NS_S_PVT, "format", [xa("action", "formatting")], [
              Element(pivot_area_scope(0, "axisRow", 0)),
            ]),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "conditionalFormats", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "conditionalFormat",
              [xa("priority", "1"), xa("scope", "selection"), xa("type", "all")],
              [
                Element(
                  xe(NS_S_PVT, "pivotAreas", [xa("count", "1")], [
                    Element(pivot_area_scope(0, "axisRow", 0)),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "chartFormats", [xa("count", "1")], [
          Element(
            xe(NS_S_PVT, "chartFormat", [xa("chart", "0"), xa("format", "0")], [
              Element(pivot_area_scope(0, "axisRow", 0)),
            ]),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "pivotHierarchies", [xa("count", "1")], [
          Element(
            xe(
              NS_S_PVT,
              "pivotHierarchy",
              [
                xa("outline", "1"),
                xa("subtotalTop", "1"),
                xa("caption", "Region"),
              ],
              [
                Element(
                  xe(NS_S_PVT, "mps", [xa("count", "1")], [
                    Element(
                      xe(
                        NS_S_PVT,
                        "mp",
                        [
                          xa("field", "0"),
                          xa("name", "Region Label"),
                          xa("showCell", "1"),
                          xa("showTip", "1"),
                        ],
                        [],
                      ),
                    ),
                  ]),
                ),
                Element(
                  xe(
                    NS_S_PVT,
                    "members",
                    [xa("count", "2"), xa("level", "0")],
                    [
                      Element(xe(NS_S_PVT, "member", [xa("name", "North")], [])),
                      Element(xe(NS_S_PVT, "member", [xa("name", "South")], [])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
      Element(
        xe(
          NS_S_PVT,
          "pivotTableStyleInfo",
          [
            xa("name", "PivotStyleLight16"),
            xa("showRowHeaders", "1"),
            xa("showColHeaders", "1"),
            xa("showRowStripes", "0"),
            xa("showColStripes", "0"),
            xa("showLastColumn", "0"),
          ],
          [],
        ),
      ),
      Element(
        xe(NS_S_PVT, "rowHierarchiesUsage", [xa("count", "1")], [
          Element(
            xe(NS_S_PVT, "rowHierarchyUsage", [xa("hierarchyUsage", "0")], []),
          ),
        ]),
      ),
      Element(
        xe(NS_S_PVT, "colHierarchiesUsage", [xa("count", "1")], [
          Element(
            xe(NS_S_PVT, "colHierarchyUsage", [xa("hierarchyUsage", "0")], []),
          ),
        ]),
      ),
    ],
  )
}

// ---- PivotedCase extender ----------------------------------------

///|
/// §18.10 PivotTable fixtures.  Eight distinct shapes:
///
///   1. `pivot-2field-sum`     — one row + one col + sum value
///   2. `pivot-filter-caption` — one row + one col + caption
///                                advanced filter.
///   3. `pivot-filter-value`   — one row + one col + aggregate value
///                                advanced filter.
///   4. `pivot-filter-calc-value` — calculated-field aggregate value
///                                  advanced filter.
///   5. `pivot-grand-totals`   — same shape with row + col grand
///                                totals on (spec defaults).
///   6. `pivot-multi-values`   — two data fields (sum + count) on a
///                                single row axis.
///   7. `pivot-row-grouping`   — two row fields nested (Region/City).
///   8. `pivot-no-grand`       — explicit `rowGrandTotals="0"` +
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
  fn calc_source_sheet() -> @xml.Element {
    xe(NS_S_PVT, "sheetData", [], [
      Element(
        s_row("1", [
          s_inline("A1", "Region"),
          s_inline("B1", "Units"),
          s_inline("C1", "Price"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "East"),
          s_cell("B2", "2"),
          s_cell("C2", "10"),
        ]),
      ),
      Element(
        s_row("3", [
          s_inline("A3", "East"),
          s_cell("B3", "3"),
          s_cell("C3", "10"),
        ]),
      ),
      Element(
        s_row("4", [
          s_inline("A4", "West"),
          s_cell("B4", "1"),
          s_cell("C4", "20"),
        ]),
      ),
    ])
  }
  fn calc_cache_def() -> @xml.Element {
    cache_def_root(
      cache_source_worksheet("S1", "A1:C4"),
      cache_fields_wrap([
        cache_field_strings("Region", ["East", "West"]),
        cache_field_numbers_inline("Units"),
        cache_field_numbers_inline("Price"),
        cache_field_calculated("Revenue", "Units*Price"),
      ]),
      3,
    )
  }
  fn calc_cache_records() -> @xml.Element {
    records_root([
      record_row([rec_x(0), rec_n("2"), rec_n("10")]),
      record_row([rec_x(0), rec_n("3"), rec_n("10")]),
      record_row([rec_x(1), rec_n("1"), rec_n("20")]),
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
  // ---- 1b. PivotTable advanced caption filter -------------------
  // §18.10.1.33 filter / §18.10.1.34 filters — Region is restricted
  // to "North" through the child §18.3.1.2 autoFilter.
  let pivot_def_filter_caption = pivot_def_with_filters(
    pivot_def_root(
      "PivotFilterCaption",
      pivot_location("E1:H4", 0, 2, 1),
      pivot_fields_wrap([
        pivot_field_with_hidden_items("axisRow", false, 3, [1, 2]),
        pivot_field("axisCol", false, 2),
        pivot_field("", true, 0),
      ]),
      Some(axis_fields("rowFields", [0])),
      Some(axis_fields("colFields", [1])),
      axis_items_wrap("rowItems", [pivot_axis_item([0], false)]),
      axis_items_wrap("colItems", [
        pivot_axis_item([0], false),
        pivot_axis_item([1], false),
      ]),
      data_fields_wrap([data_field_entry("Sum of Sales", 2, "sum")]),
      false,
      false,
    ),
    pivot_filters_wrap([pivot_caption_equals_filter(0, 1, "North")]),
  )
  pcases.push({
    id: "pivot-filter-caption",
    format: "xlsx",
    category: "pivot",
    content: source_sheet(),
    cache_def: shared_cache_def(),
    cache_records: shared_cache_records(),
    pivot_def: pivot_def_filter_caption,
  })
  // ---- 1c. PivotTable advanced aggregate value filter ------------
  // §18.10.1.33 type="sum" — Region is restricted to members whose
  // Sum of Sales exceeds 150. The `<pivotField>/<item h="1">` state is
  // mirrored so spreadsheet applications opening the cached pivot display
  // the same result without refreshing.
  let pivot_def_filter_value = pivot_def_with_filters(
    pivot_def_root(
      "PivotFilterValue",
      pivot_location("E1:H4", 0, 2, 1),
      pivot_fields_wrap([
        pivot_field_with_hidden_items("axisRow", false, 3, [0, 2]),
        pivot_field("axisCol", false, 2),
        pivot_field("", true, 0),
      ]),
      Some(axis_fields("rowFields", [0])),
      Some(axis_fields("colFields", [1])),
      axis_items_wrap("rowItems", [pivot_axis_item([1], false)]),
      axis_items_wrap("colItems", [
        pivot_axis_item([0], false),
        pivot_axis_item([1], false),
      ]),
      data_fields_wrap([data_field_entry("Sum of Sales", 2, "sum")]),
      false,
      false,
    ),
    pivot_filters_wrap([pivot_sum_greater_than_filter(0, 2, 0, "150")]),
  )
  pcases.push({
    id: "pivot-filter-value",
    format: "xlsx",
    category: "pivot",
    content: source_sheet(),
    cache_def: shared_cache_def(),
    cache_records: shared_cache_records(),
    pivot_def: pivot_def_filter_value,
  })
  // ---- 1d. Calculated-field aggregate value filter --------------
  // §18.10.1.3 calculated cacheField Revenue = Units*Price, filtered by
  // §18.10.1.33 type="sum". The kept member is East because the
  // calculated field SoT evaluates SUM(Units) * SUM(Price) = 100.
  let pivot_def_filter_calc_value = pivot_def_with_filters(
    pivot_def_root(
      "PivotFilterCalcValue",
      pivot_location("E1:F4", 0, 1, 1),
      pivot_fields_wrap([
        pivot_field_with_hidden_items("axisRow", false, 2, [1]),
        pivot_field("", false, 0),
        pivot_field("", false, 0),
        pivot_field("", true, 0),
      ]),
      Some(axis_fields("rowFields", [0])),
      None,
      axis_items_wrap("rowItems", [pivot_axis_item([0], false)]),
      axis_items_wrap("colItems", [pivot_axis_item([], false)]),
      data_fields_wrap([data_field_entry("Sum of Revenue", 3, "sum")]),
      false,
      false,
    ),
    pivot_filters_wrap([pivot_sum_greater_than_filter(0, 3, 0, "75")]),
  )
  pcases.push({
    id: "pivot-filter-calc-value",
    format: "xlsx",
    category: "pivot",
    content: calc_source_sheet(),
    cache_def: calc_cache_def(),
    cache_records: calc_cache_records(),
    pivot_def: pivot_def_filter_calc_value,
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
  // §18.10.1.44 `@r` repeat-count grouping is handled by the
  // materializer; this fixture uses explicit full tuples so the
  // rendered labels remain easy to audit.
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
  // ---- 6. Rich schema observation pivot -------------------------
  // This is intentionally an observation fixture rather than a new
  // renderer feature. The visible pivot remains a simple row-axis
  // aggregate, while the package parts carry deeper §18.10 optional
  // branches so XSD validation and the domain readers exercise:
  // cacheHierarchy / fieldUsage / groupLevel / tupleCache /
  // calculatedItems / calculatedMembers / pivotArea references /
  // conditionalFormats / chartFormats / pivotHierarchies /
  // hierarchyUsage. These are not claimed as full semantic or
  // Office-interop support; they are coverage probes.
  pcases.push({
    id: "pivot-schema-observation-rich",
    format: "xlsx",
    category: "pivot",
    content: source_sheet(),
    cache_def: observation_cache_def(),
    cache_records: shared_cache_records(),
    pivot_def: observation_pivot_def(),
  })
}
