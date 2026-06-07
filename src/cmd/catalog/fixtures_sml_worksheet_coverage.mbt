// SpreadsheetML worksheet coverage fixtures. These cases use the plain
// xlsx worksheet host and avoid elements that require additional OPC
// relationships.

///|
fn sml_ws_nodes(elements : Array[@xml.Element]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for e in elements {
    nodes.push(Element(e))
  }
  nodes
}

///|
fn sml_ws_el(
  name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Element],
) -> @xml.Element {
  xe(NS_S, name, attrs, sml_ws_nodes(children))
}

///|
fn sml_ws_text(name : String, text : String) -> @xml.Element {
  xe(NS_S, name, [], [Text(text)])
}

///|
fn sml_ws_color(name : String, hex : String) -> @xml.Element {
  xe(NS_S, name, [xa("rgb", hex)], [])
}

///|
/// Worksheet elements whose semantics are already consumed by the
/// SpreadsheetML SVG renderer, but whose schema-synthesized singleton
/// probe may not include enough surrounding sheet content to make the
/// consumption visible.  The catalog routes these through a real
/// worksheet root with deterministic cells so the verifier measures the
/// renderer path, not an empty wrapper.
fn is_sml_worksheet_render_target(
  local_name : String,
  type_name : String,
  ns : String,
) -> Bool {
  if strip_ns(ns) != "spreadsheetml/main" {
    return false
  }
  let type_local = catalog_type_local(type_name)
  match local_name {
    "dimension" => type_local == "CT_SheetDimension"
    "sheetFormatPr" => type_local == "CT_SheetFormatPr"
    "cols" => type_local == "CT_Cols"
    "col" => type_local == "CT_Col"
    "sheetData" => type_local == "CT_SheetData"
    "row" => type_local == "CT_Row"
    "c" => type_local == "CT_Cell"
    "mergeCells" => type_local == "CT_MergeCells"
    "mergeCell" => type_local == "CT_MergeCell"
    "conditionalFormatting" => type_local == "CT_ConditionalFormatting"
    "cfRule" => type_local == "CT_CfRule"
    "colorScale" => type_local == "CT_ColorScale"
    "dataBar" => type_local == "CT_DataBar"
    "iconSet" => type_local == "CT_IconSet"
    "cfvo" => type_local == "CT_Cfvo"
    "color" => type_local == "CT_Color"
    _ => false
  }
}

///|
fn sml_layout_nodes(elements : Array[@xml.Element]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for e in elements {
    nodes.push(Element(e))
  }
  nodes
}

///|
fn sml_layout_el(
  ns : String,
  name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Element],
) -> @xml.Element {
  xe(ns, name, attrs, sml_layout_nodes(children))
}

///|
fn sml_layout_inline_cell(
  ns : String,
  ref_ : String,
  text : String,
) -> @xml.Element {
  sml_layout_el(ns, "c", [xa("r", ref_), xa("t", "inlineStr")], [
    sml_layout_el(ns, "is", [], [xe(ns, "t", [], [Text(text)])]),
  ])
}

///|
fn sml_layout_row(
  ns : String,
  num : String,
  cells : Array[@xml.Element],
) -> @xml.Element {
  sml_layout_el(ns, "row", [xa("r", num)], cells)
}

///|
fn sml_layout_sheet_data(ns : String) -> @xml.Element {
  sml_layout_el(ns, "sheetData", [], [
    sml_layout_row(ns, "1", [
      sml_layout_inline_cell(ns, "A1", "Catalog"),
      sml_layout_inline_cell(ns, "B1", "Width"),
      sml_layout_inline_cell(ns, "C1", "Height"),
    ]),
    sml_layout_row(ns, "2", [
      sml_layout_inline_cell(ns, "A2", "Sheet"),
      sml_layout_inline_cell(ns, "B2", "16"),
      sml_layout_inline_cell(ns, "C2", "24"),
    ]),
  ])
}

///|
fn sml_layout_dimension(ns : String, ref_ : String) -> @xml.Element {
  xe(ns, "dimension", [xa("ref", ref_)], [])
}

///|
fn sml_layout_visible_col(ns : String) -> @xml.Element {
  xe(
    ns,
    "col",
    [
      xa("min", "2"),
      xa("max", "2"),
      xa("width", "24"),
      xa("customWidth", "1"),
      xa("outlineLevel", "1"),
    ],
    [],
  )
}

///|
fn sml_layout_merge_cell(ns : String, ref_ : String) -> @xml.Element {
  xe(ns, "mergeCell", [xa("ref", ref_)], [])
}

///|
fn sml_layout_numeric_cell(
  ns : String,
  ref_ : String,
  value : String,
) -> @xml.Element {
  sml_layout_el(ns, "c", [xa("r", ref_)], [xe(ns, "v", [], [Text(value)])])
}

///|
fn sml_layout_numeric_sheet_data(ns : String) -> @xml.Element {
  sml_layout_el(ns, "sheetData", [], [
    sml_layout_row(ns, "1", [sml_layout_numeric_cell(ns, "A1", "10")]),
    sml_layout_row(ns, "2", [sml_layout_numeric_cell(ns, "A2", "30")]),
    sml_layout_row(ns, "3", [sml_layout_numeric_cell(ns, "A3", "20")]),
    sml_layout_row(ns, "4", [sml_layout_numeric_cell(ns, "A4", "40")]),
  ])
}

///|
fn sml_layout_cfvo(ns : String, type_ : String, val : String?) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [xa("type", type_)]
  match val {
    Some(v) => attrs.push(xa("val", v))
    None => ()
  }
  xe(ns, "cfvo", attrs, [])
}

///|
fn sml_layout_cf_color(ns : String, argb : String) -> @xml.Element {
  xe(ns, "color", [xa("rgb", argb)], [])
}

///|
fn sml_layout_data_bar_children(ns : String) -> Array[@xml.Element] {
  [
    sml_layout_cfvo(ns, "min", None),
    sml_layout_cfvo(ns, "max", None),
    sml_layout_cf_color(ns, "FF638EC6"),
  ]
}

///|
fn sml_layout_data_bar(ns : String) -> @xml.Element {
  sml_layout_el(ns, "dataBar", [], sml_layout_data_bar_children(ns))
}

///|
fn sml_layout_cf_rule(
  ns : String,
  type_ : String,
  child : @xml.Element,
) -> @xml.Element {
  sml_layout_el(ns, "cfRule", [xa("type", type_), xa("priority", "1")], [child])
}

///|
fn sml_layout_conditional_formatting(
  ns : String,
  rules : Array[@xml.Element],
) -> @xml.Element {
  sml_layout_el(ns, "conditionalFormatting", [xa("sqref", "A1:A4")], rules)
}

///|
fn sml_layout_cf_worksheet(
  ns : String,
  conditional_formatting : @xml.Element,
) -> @xml.Element {
  sml_layout_worksheet(ns, [
    sml_layout_dimension(ns, "A1:A4"),
    sml_layout_numeric_sheet_data(ns),
    conditional_formatting,
  ])
}

///|
fn sml_layout_target_with_attrs(
  target : @xml.Element,
  attrs : Array[(String, String)],
) -> @xml.Element {
  {
    name: target.name,
    attributes: catalog_force_attrs(target.attributes, attrs),
    children: target.children,
  }
}

///|
fn sml_layout_target_with_children(
  target : @xml.Element,
  children : Array[@xml.Node],
) -> @xml.Element {
  { name: target.name, attributes: target.attributes, children }
}

///|
fn sml_layout_worksheet(
  ns : String,
  children : Array[@xml.Element],
) -> @xml.Element {
  sml_layout_el(ns, "worksheet", [], children)
}

///|
/// Catalog host for worksheet render targets. Each branch places the
/// target in its ECMA-376 worksheet slot and supplies only the
/// surrounding facts required by the existing renderer to make that
/// target observable: dimensions, column definitions, rows, cells, and
/// conditional-formatting populations.
fn catalog_sml_worksheet_render_root(target : @xml.Element) -> @xml.Element {
  let ns = target.name.ns.unwrap_or(NS_S)
  match target.name.local_name {
    "dimension" => {
      let dim = sml_layout_target_with_attrs(target, [("ref", "A1:C3")])
      sml_layout_worksheet(ns, [
        dim,
        sml_layout_el(ns, "sheetData", [], [
          sml_layout_row(ns, "1", [
            sml_layout_inline_cell(ns, "A1", "Dimension"),
          ]),
        ]),
      ])
    }
    "sheetFormatPr" => {
      let fmt = sml_layout_target_with_attrs(target, [
        ("defaultColWidth", "16"),
        ("defaultRowHeight", "24"),
      ])
      sml_layout_worksheet(ns, [
        sml_layout_dimension(ns, "A1:C2"),
        fmt,
        sml_layout_sheet_data(ns),
      ])
    }
    "cols" => {
      let cols = sml_layout_target_with_children(target, [
        Element(sml_layout_visible_col(ns)),
      ])
      sml_layout_worksheet(ns, [
        sml_layout_dimension(ns, "A1:C2"),
        cols,
        sml_layout_sheet_data(ns),
      ])
    }
    "col" => {
      let col = sml_layout_target_with_attrs(target, [
        ("min", "2"),
        ("max", "2"),
        ("width", "24"),
        ("customWidth", "1"),
        ("outlineLevel", "1"),
      ])
      sml_layout_worksheet(ns, [
        sml_layout_dimension(ns, "A1:C2"),
        sml_layout_el(ns, "cols", [], [col]),
        sml_layout_sheet_data(ns),
      ])
    }
    "sheetData" => {
      let sheet_data = sml_layout_target_with_children(target, [
        Element(
          sml_layout_row(ns, "1", [
            sml_layout_inline_cell(ns, "A1", TEXT_MARKER),
            sml_layout_inline_cell(ns, "B1", "Data"),
          ]),
        ),
      ])
      sml_layout_worksheet(ns, [sml_layout_dimension(ns, "A1:B1"), sheet_data])
    }
    "row" => {
      let row : @xml.Element = {
        name: target.name,
        attributes: catalog_force_attrs(target.attributes, [
          ("r", "1"),
          ("ht", "24"),
          ("customHeight", "1"),
        ]),
        children: [
          @xml.Node::Element(sml_layout_inline_cell(ns, "A1", TEXT_MARKER)),
          @xml.Node::Element(sml_layout_inline_cell(ns, "B1", "Row")),
        ],
      }
      sml_layout_worksheet(ns, [
        sml_layout_dimension(ns, "A1:B1"),
        sml_layout_el(ns, "sheetData", [], [row]),
      ])
    }
    "c" => {
      let cell : @xml.Element = {
        name: target.name,
        attributes: catalog_force_attrs(target.attributes, [
          ("r", "A1"),
          ("t", "inlineStr"),
        ]),
        children: [
          @xml.Node::Element(
            sml_layout_el(ns, "is", [], [xe(ns, "t", [], [Text(TEXT_MARKER)])]),
          ),
        ],
      }
      sml_layout_worksheet(ns, [
        sml_layout_dimension(ns, "A1:B1"),
        sml_layout_el(ns, "sheetData", [], [
          sml_layout_row(ns, "1", [
            cell,
            sml_layout_inline_cell(ns, "B1", "Cell"),
          ]),
        ]),
      ])
    }
    "mergeCells" => {
      let merge_cells = sml_layout_target_with_attrs(
        sml_layout_target_with_children(target, [
          Element(sml_layout_merge_cell(ns, "A1:B1")),
        ]),
        [("count", "1")],
      )
      sml_layout_worksheet(ns, [
        sml_layout_dimension(ns, "A1:B1"),
        merge_cells,
        sml_layout_el(ns, "sheetData", [], [
          sml_layout_row(ns, "1", [
            sml_layout_inline_cell(ns, "A1", "Merged"),
            sml_layout_inline_cell(ns, "B1", "Hidden"),
          ]),
        ]),
      ])
    }
    "mergeCell" => {
      let merge_cell = sml_layout_target_with_attrs(target, [("ref", "A1:B1")])
      sml_layout_worksheet(ns, [
        sml_layout_dimension(ns, "A1:B1"),
        sml_layout_el(ns, "mergeCells", [xa("count", "1")], [merge_cell]),
        sml_layout_el(ns, "sheetData", [], [
          sml_layout_row(ns, "1", [
            sml_layout_inline_cell(ns, "A1", "Merged"),
            sml_layout_inline_cell(ns, "B1", "Hidden"),
          ]),
        ]),
      ])
    }
    "conditionalFormatting" => {
      let conditional_formatting = sml_layout_target_with_attrs(
        sml_layout_target_with_children(target, [
          Element(sml_layout_cf_rule(ns, "dataBar", sml_layout_data_bar(ns))),
        ]),
        [("sqref", "A1:A4")],
      )
      sml_layout_cf_worksheet(ns, conditional_formatting)
    }
    "cfRule" => {
      let cf_rule = sml_layout_target_with_attrs(
        sml_layout_target_with_children(target, [
          Element(sml_layout_data_bar(ns)),
        ]),
        [("type", "dataBar"), ("priority", "1")],
      )
      sml_layout_cf_worksheet(
        ns,
        sml_layout_conditional_formatting(ns, [cf_rule]),
      )
    }
    "dataBar" => {
      let data_bar = sml_layout_target_with_children(
        target,
        sml_layout_nodes(sml_layout_data_bar_children(ns)),
      )
      sml_layout_cf_worksheet(
        ns,
        sml_layout_conditional_formatting(ns, [
          sml_layout_cf_rule(ns, "dataBar", data_bar),
        ]),
      )
    }
    "colorScale" => {
      let color_scale = sml_layout_target_with_children(target, [
        Element(sml_layout_cfvo(ns, "min", None)),
        Element(sml_layout_cfvo(ns, "max", None)),
        Element(sml_layout_cf_color(ns, "FFFFFFFF")),
        Element(sml_layout_cf_color(ns, "FFFF0000")),
      ])
      sml_layout_cf_worksheet(
        ns,
        sml_layout_conditional_formatting(ns, [
          sml_layout_cf_rule(ns, "colorScale", color_scale),
        ]),
      )
    }
    "iconSet" => {
      let icon_set = sml_layout_target_with_attrs(
        sml_layout_target_with_children(target, [
          Element(sml_layout_cfvo(ns, "percent", Some("0"))),
          Element(sml_layout_cfvo(ns, "percent", Some("33"))),
          Element(sml_layout_cfvo(ns, "percent", Some("67"))),
        ]),
        [("iconSet", "3TrafficLights1")],
      )
      sml_layout_cf_worksheet(
        ns,
        sml_layout_conditional_formatting(ns, [
          sml_layout_cf_rule(ns, "iconSet", icon_set),
        ]),
      )
    }
    "cfvo" => {
      let cfvo = sml_layout_target_with_attrs(target, [("type", "max")])
      let data_bar = sml_layout_el(ns, "dataBar", [], [
        sml_layout_cfvo(ns, "min", None),
        cfvo,
        sml_layout_cf_color(ns, "FF638EC6"),
      ])
      sml_layout_cf_worksheet(
        ns,
        sml_layout_conditional_formatting(ns, [
          sml_layout_cf_rule(ns, "dataBar", data_bar),
        ]),
      )
    }
    "color" => {
      let color = sml_layout_target_with_attrs(target, [("rgb", "FF638EC6")])
      let data_bar = sml_layout_el(ns, "dataBar", [], [
        sml_layout_cfvo(ns, "min", None),
        sml_layout_cfvo(ns, "max", None),
        color,
      ])
      sml_layout_cf_worksheet(
        ns,
        sml_layout_conditional_formatting(ns, [
          sml_layout_cf_rule(ns, "dataBar", data_bar),
        ]),
      )
    }
    _ => target
  }
}

///|
fn sml_ws_pane() -> @xml.Element {
  xe(
    NS_S,
    "pane",
    [
      xa("xSplit", "1"),
      xa("ySplit", "1"),
      xa("topLeftCell", "B2"),
      xa("activePane", "bottomRight"),
      xa("state", "frozenSplit"),
    ],
    [],
  )
}

///|
fn sml_ws_selection() -> @xml.Element {
  xe(
    NS_S,
    "selection",
    [
      xa("pane", "bottomRight"),
      xa("activeCell", "B2"),
      xa("activeCellId", "0"),
      xa("sqref", "B2:C3"),
    ],
    [],
  )
}

///|
fn sml_ws_pivot_area() -> @xml.Element {
  sml_ws_el(
    "pivotArea",
    [
      xa("field", "0"),
      xa("type", "normal"),
      xa("dataOnly", "1"),
      xa("labelOnly", "0"),
      xa("grandRow", "0"),
      xa("grandCol", "0"),
      xa("cacheIndex", "0"),
      xa("outline", "1"),
      xa("offset", "A1"),
      xa("collapsedLevelsAreSubtotals", "0"),
      xa("axis", "axisRow"),
      xa("fieldPosition", "0"),
    ],
    [
      sml_ws_el("references", [xa("count", "1")], [
        sml_ws_el(
          "reference",
          [
            xa("field", "0"),
            xa("count", "1"),
            xa("selected", "1"),
            xa("byPosition", "0"),
            xa("relative", "0"),
            xa("defaultSubtotal", "0"),
            xa("sumSubtotal", "1"),
            xa("countASubtotal", "0"),
            xa("avgSubtotal", "0"),
            xa("maxSubtotal", "0"),
            xa("minSubtotal", "0"),
            xa("productSubtotal", "0"),
            xa("countSubtotal", "0"),
            xa("stdDevSubtotal", "0"),
            xa("stdDevPSubtotal", "0"),
            xa("varSubtotal", "0"),
            xa("varPSubtotal", "0"),
          ],
          [xe(NS_S, "x", [xa("v", "0")], [])],
        ),
      ]),
    ],
  )
}

///|
fn sml_ws_page_breaks(name : String) -> @xml.Element {
  sml_ws_el(name, [xa("count", "1"), xa("manualBreakCount", "1")], [
    xe(
      NS_S,
      "brk",
      [
        xa("id", "2"),
        xa("min", "0"),
        xa("max", "16383"),
        xa("man", "1"),
        xa("pt", "0"),
      ],
      [],
    ),
  ])
}

///|
fn sml_ws_page_margins() -> @xml.Element {
  xe(
    NS_S,
    "pageMargins",
    [
      xa("left", "0.7"),
      xa("right", "0.7"),
      xa("top", "0.75"),
      xa("bottom", "0.75"),
      xa("header", "0.3"),
      xa("footer", "0.3"),
    ],
    [],
  )
}

///|
fn sml_ws_print_options() -> @xml.Element {
  xe(
    NS_S,
    "printOptions",
    [
      xa("horizontalCentered", "1"),
      xa("verticalCentered", "0"),
      xa("headings", "1"),
      xa("gridLines", "1"),
      xa("gridLinesSet", "1"),
    ],
    [],
  )
}

///|
fn sml_ws_page_setup() -> @xml.Element {
  xe(
    NS_S,
    "pageSetup",
    [
      xa("paperSize", "9"),
      xa("paperHeight", "11in"),
      xa("paperWidth", "8.5in"),
      xa("scale", "100"),
      xa("firstPageNumber", "1"),
      xa("fitToWidth", "1"),
      xa("fitToHeight", "1"),
      xa("pageOrder", "downThenOver"),
      xa("orientation", "portrait"),
      xa("usePrinterDefaults", "1"),
      xa("blackAndWhite", "0"),
      xa("draft", "0"),
      xa("cellComments", "asDisplayed"),
      xa("useFirstPageNumber", "1"),
      xa("errors", "displayed"),
      xa("horizontalDpi", "600"),
      xa("verticalDpi", "600"),
      xa("copies", "1"),
    ],
    [],
  )
}

///|
fn sml_ws_header_footer() -> @xml.Element {
  sml_ws_el(
    "headerFooter",
    [
      xa("differentOddEven", "1"),
      xa("differentFirst", "1"),
      xa("scaleWithDoc", "1"),
      xa("alignWithMargins", "1"),
    ],
    [
      sml_ws_text("oddHeader", "&CCatalog"),
      sml_ws_text("oddFooter", "&P / &N"),
      sml_ws_text("evenHeader", "&LFixture"),
      sml_ws_text("evenFooter", "&RGenerated"),
      sml_ws_text("firstHeader", "&CFirst"),
      sml_ws_text("firstFooter", "&CFirst footer"),
    ],
  )
}

///|
fn sml_ws_sheet_view() -> @xml.Element {
  sml_ws_el(
    "sheetView",
    [
      xa("windowProtection", "0"),
      xa("showFormulas", "0"),
      xa("showGridLines", "1"),
      xa("showRowColHeaders", "1"),
      xa("showZeros", "1"),
      xa("rightToLeft", "0"),
      xa("tabSelected", "1"),
      xa("showRuler", "1"),
      xa("showOutlineSymbols", "1"),
      xa("defaultGridColor", "1"),
      xa("showWhiteSpace", "1"),
      xa("view", "normal"),
      xa("topLeftCell", "A1"),
      xa("colorId", "64"),
      xa("zoomScale", "100"),
      xa("zoomScaleNormal", "100"),
      xa("zoomScaleSheetLayoutView", "100"),
      xa("zoomScalePageLayoutView", "100"),
      xa("workbookViewId", "0"),
    ],
    [
      sml_ws_pane(),
      sml_ws_selection(),
      sml_ws_el(
        "pivotSelection",
        [
          xa("pane", "bottomRight"),
          xa("showHeader", "1"),
          xa("label", "1"),
          xa("data", "1"),
          xa("extendable", "1"),
          xa("count", "1"),
          xa("axis", "axisRow"),
          xa("dimension", "0"),
          xa("start", "0"),
          xa("min", "0"),
          xa("max", "1"),
          xa("activeRow", "0"),
          xa("activeCol", "0"),
          xa("previousRow", "0"),
          xa("previousCol", "0"),
          xa("click", "1"),
        ],
        [sml_ws_pivot_area()],
      ),
    ],
  )
}

///|
fn sml_ws_custom_sheet_view() -> @xml.Element {
  sml_ws_el(
    "customSheetView",
    [
      xa("guid", "{22334455-6677-8899-AABB-CCDDEEFF0011}"),
      xa("scale", "100"),
      xa("colorId", "64"),
      xa("showPageBreaks", "1"),
      xa("showFormulas", "0"),
      xa("showGridLines", "1"),
      xa("showRowCol", "1"),
      xa("outlineSymbols", "1"),
      xa("zeroValues", "1"),
      xa("fitToPage", "1"),
      xa("printArea", "0"),
      xa("filter", "0"),
      xa("showAutoFilter", "0"),
      xa("hiddenRows", "0"),
      xa("hiddenColumns", "0"),
      xa("state", "visible"),
      xa("filterUnique", "0"),
      xa("view", "normal"),
      xa("showRuler", "1"),
      xa("topLeftCell", "A1"),
    ],
    [
      sml_ws_pane(),
      sml_ws_selection(),
      sml_ws_page_breaks("rowBreaks"),
      sml_ws_page_breaks("colBreaks"),
      sml_ws_page_margins(),
      sml_ws_print_options(),
      sml_ws_page_setup(),
      sml_ws_header_footer(),
    ],
  )
}

///|
fn sml_ws_sheet_protection() -> @xml.Element {
  xe(
    NS_S,
    "sheetProtection",
    [
      xa("password", "0000"),
      xa("sheet", "1"),
      xa("objects", "1"),
      xa("scenarios", "1"),
      xa("formatCells", "0"),
      xa("formatColumns", "0"),
      xa("formatRows", "0"),
      xa("insertColumns", "0"),
      xa("insertRows", "0"),
      xa("insertHyperlinks", "0"),
      xa("deleteColumns", "0"),
      xa("deleteRows", "0"),
      xa("selectLockedCells", "1"),
      xa("sort", "0"),
      xa("autoFilter", "0"),
      xa("pivotTables", "0"),
      xa("selectUnlockedCells", "1"),
    ],
    [],
  )
}

///|
fn sml_ws_worksheet_part() -> @xml.Element {
  sml_ws_el("worksheet", [], [
    sml_ws_el(
      "sheetPr",
      [
        xa("syncHorizontal", "0"),
        xa("syncVertical", "0"),
        xa("syncRef", "A1:B2"),
        xa("transitionEvaluation", "0"),
        xa("transitionEntry", "0"),
        xa("published", "1"),
        xa("codeName", "Sheet1"),
        xa("filterMode", "0"),
        xa("enableFormatConditionsCalculation", "1"),
      ],
      [
        sml_ws_color("tabColor", "FF4472C4"),
        xe(
          NS_S,
          "outlinePr",
          [
            xa("applyStyles", "1"),
            xa("summaryBelow", "1"),
            xa("summaryRight", "1"),
            xa("showOutlineSymbols", "1"),
          ],
          [],
        ),
        xe(
          NS_S,
          "pageSetUpPr",
          [xa("autoPageBreaks", "1"), xa("fitToPage", "1")],
          [],
        ),
      ],
    ),
    xe(NS_S, "dimension", [xa("ref", "A1:C4")], []),
    sml_ws_el("sheetViews", [], [sml_ws_sheet_view()]),
    xe(
      NS_S,
      "sheetFormatPr",
      [
        xa("baseColWidth", "8"),
        xa("defaultColWidth", "11"),
        xa("defaultRowHeight", "15"),
        xa("customHeight", "0"),
        xa("zeroHeight", "0"),
        xa("thickTop", "0"),
        xa("thickBottom", "0"),
        xa("outlineLevelRow", "1"),
        xa("outlineLevelCol", "1"),
      ],
      [],
    ),
    sml_ws_el("cols", [], [
      xe(
        NS_S,
        "col",
        [
          xa("min", "1"),
          xa("max", "3"),
          xa("width", "12"),
          xa("style", "0"),
          xa("hidden", "0"),
          xa("bestFit", "1"),
          xa("customWidth", "1"),
          xa("phonetic", "0"),
          xa("outlineLevel", "1"),
          xa("collapsed", "0"),
        ],
        [],
      ),
    ]),
    sml_ws_el("sheetData", [], [
      s_row("1", [
        s_inline("A1", "Catalog"),
        s_cell("B1", "1"),
        s_cell("C1", "2"),
      ]),
      s_row("2", [s_inline("A2", "Value"), s_cell("B2", "3"), s_cell("C2", "4")]),
    ]),
    xe(NS_S, "sheetCalcPr", [xa("fullCalcOnLoad", "1")], []),
    sml_ws_sheet_protection(),
    sml_ws_el("protectedRanges", [], [
      sml_ws_el(
        "protectedRange",
        [
          xa("password", "0000"),
          xa("sqref", "A1:B2"),
          xa("name", "CatalogProtected"),
          xa("securityDescriptor", "CatalogDescriptor"),
        ],
        [sml_ws_text("securityDescriptor", "CatalogDescriptor")],
      ),
    ]),
    sml_ws_el(
      "scenarios",
      [xa("current", "0"), xa("show", "0"), xa("sqref", "B2")],
      [
        sml_ws_el(
          "scenario",
          [
            xa("name", "CatalogScenario"),
            xa("locked", "1"),
            xa("hidden", "0"),
            xa("count", "1"),
            xa("user", "catalog"),
            xa("comment", "fixture"),
          ],
          [
            xe(
              NS_S,
              "inputCells",
              [
                xa("r", "B2"),
                xa("deleted", "0"),
                xa("undone", "0"),
                xa("val", "42"),
                xa("numFmtId", "0"),
              ],
              [],
            ),
          ],
        ),
      ],
    ),
    sml_ws_el(
      "dataConsolidate",
      [
        xa("function", "sum"),
        xa("startLabels", "1"),
        xa("leftLabels", "1"),
        xa("topLabels", "1"),
        xa("link", "0"),
      ],
      [
        sml_ws_el("dataRefs", [xa("count", "1")], [
          xe(
            NS_S,
            "dataRef",
            [xa("ref", "A1:B2"), xa("name", "CatalogRange"), xa("sheet", "S1")],
            [],
          ),
        ]),
      ],
    ),
    sml_ws_el("customSheetViews", [], [sml_ws_custom_sheet_view()]),
    sml_ws_el("mergeCells", [xa("count", "1")], [
      xe(NS_S, "mergeCell", [xa("ref", "A4:C4")], []),
    ]),
    xe(
      NS_S,
      "phoneticPr",
      [xa("fontId", "0"), xa("type", "Hiragana"), xa("alignment", "center")],
      [],
    ),
    sml_ws_el(
      "dataValidations",
      [
        xa("disablePrompts", "0"),
        xa("xWindow", "0"),
        xa("yWindow", "0"),
        xa("count", "1"),
      ],
      [
        sml_ws_el(
          "dataValidation",
          [
            xa("type", "whole"),
            xa("errorStyle", "warning"),
            xa("imeMode", "off"),
            xa("operator", "between"),
            xa("allowBlank", "1"),
            xa("showDropDown", "0"),
            xa("showInputMessage", "1"),
            xa("showErrorMessage", "1"),
            xa("errorTitle", "Catalog error"),
            xa("error", "Value out of range"),
            xa("promptTitle", "Catalog prompt"),
            xa("prompt", "Enter a value"),
            xa("sqref", "B2"),
          ],
          [sml_ws_text("formula1", "1"), sml_ws_text("formula2", "10")],
        ),
      ],
    ),
    sml_ws_el("hyperlinks", [], [
      xe(
        NS_S,
        "hyperlink",
        [
          xa("ref", "A1"),
          xa("location", "S1!A1"),
          xa("tooltip", "Catalog link"),
          xa("display", "Catalog"),
        ],
        [],
      ),
    ]),
    sml_ws_print_options(),
    sml_ws_page_margins(),
    sml_ws_page_setup(),
    sml_ws_header_footer(),
    sml_ws_page_breaks("rowBreaks"),
    sml_ws_page_breaks("colBreaks"),
    sml_ws_el("cellWatches", [], [xe(NS_S, "cellWatch", [xa("r", "B2")], [])]),
    sml_ws_el("ignoredErrors", [], [
      xe(
        NS_S,
        "ignoredError",
        [
          xa("sqref", "A1:C4"),
          xa("evalError", "1"),
          xa("twoDigitTextYear", "1"),
          xa("numberStoredAsText", "1"),
          xa("formula", "1"),
          xa("formulaRange", "1"),
          xa("unlockedFormula", "1"),
          xa("emptyCellReference", "1"),
          xa("listDataValidation", "1"),
          xa("calculatedColumn", "1"),
        ],
        [],
      ),
    ]),
    sml_ws_el("smartTags", [], [
      sml_ws_el("cellSmartTags", [xa("r", "A1")], [
        sml_ws_el(
          "cellSmartTag",
          [xa("type", "0"), xa("deleted", "0"), xa("xmlBased", "1")],
          [
            xe(
              NS_S,
              "cellSmartTagPr",
              [xa("key", "catalog"), xa("val", "fixture")],
              [],
            ),
          ],
        ),
      ]),
    ]),
    sml_ws_el("webPublishItems", [xa("count", "1")], [
      xe(
        NS_S,
        "webPublishItem",
        [
          xa("id", "1"),
          xa("divId", "CatalogDiv"),
          xa("sourceType", "range"),
          xa("sourceRef", "A1:B2"),
          xa("sourceObject", "CatalogRange"),
          xa("destinationFile", "catalog.htm"),
          xa("title", "Catalog"),
          xa("autoRepublish", "1"),
        ],
        [],
      ),
    ]),
  ])
}

///|
fn extras_sml_worksheet_coverage(cases : Array[VisualCase]) -> Unit {
  cases.push({
    id: "worksheet-rich-view-print-protection",
    format: "xlsx",
    category: "worksheet",
    content: sml_ws_worksheet_part(),
  })
}
