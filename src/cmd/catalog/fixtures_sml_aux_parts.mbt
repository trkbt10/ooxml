// SpreadsheetML auxiliary-part fixtures. These cases exercise ECMA-376
// section 18 part roots through the real xlsx OPC host instead of
// embedding their children in a worksheet fragment.

///|
fn sml_aux_rel_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("r"), local_name, ns: Some(NS_OFFICE_REL) }, value }
}

///|
fn sml_aux_nodes(elements : Array[@xml.Element]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for e in elements {
    nodes.push(Element(e))
  }
  nodes
}

///|
fn sml_aux_el(
  name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Element],
) -> @xml.Element {
  xe(NS_S, name, attrs, sml_aux_nodes(children))
}

///|
fn sml_aux_text(name : String, text : String) -> @xml.Element {
  xe(NS_S, name, [], [Text(text)])
}

///|
fn sml_aux_val(name : String, value : String) -> @xml.Element {
  xe(NS_S, name, [xa("val", value)], [])
}

///|
fn sml_aux_color(hex : String) -> @xml.Element {
  xe(NS_S, "color", [xa("rgb", hex)], [])
}

///|
fn sml_aux_font_run_properties() -> @xml.Element {
  sml_aux_el("rPr", [], [
    sml_aux_val("rFont", "Catalog Sans"),
    sml_aux_val("charset", "1"),
    sml_aux_val("family", "2"),
    sml_aux_val("b", "1"),
    sml_aux_val("i", "1"),
    sml_aux_val("strike", "1"),
    sml_aux_val("outline", "1"),
    sml_aux_val("shadow", "1"),
    sml_aux_val("condense", "1"),
    sml_aux_val("extend", "1"),
    sml_aux_color("FFFF0000"),
    sml_aux_val("sz", "11"),
    sml_aux_val("u", "double"),
    sml_aux_val("vertAlign", "superscript"),
    sml_aux_val("scheme", "minor"),
  ])
}

///|
fn sml_aux_font() -> @xml.Element {
  sml_aux_el("font", [], [
    sml_aux_val("name", "Catalog Sans"),
    sml_aux_val("charset", "1"),
    sml_aux_val("family", "2"),
    sml_aux_val("b", "1"),
    sml_aux_val("i", "1"),
    sml_aux_val("strike", "1"),
    sml_aux_val("outline", "1"),
    sml_aux_val("shadow", "1"),
    sml_aux_val("condense", "1"),
    sml_aux_val("extend", "1"),
    sml_aux_color("FF4472C4"),
    sml_aux_val("sz", "11"),
    sml_aux_val("u", "single"),
    sml_aux_val("vertAlign", "baseline"),
    sml_aux_val("scheme", "minor"),
  ])
}

///|
fn sml_aux_alignment() -> @xml.Element {
  xe(
    NS_S,
    "alignment",
    [
      xa("horizontal", "center"),
      xa("vertical", "center"),
      xa("textRotation", "45"),
      xa("wrapText", "1"),
      xa("indent", "1"),
      xa("relativeIndent", "0"),
      xa("justifyLastLine", "1"),
      xa("shrinkToFit", "0"),
      xa("readingOrder", "1"),
    ],
    [],
  )
}

///|
fn sml_aux_protection() -> @xml.Element {
  xe(NS_S, "protection", [xa("locked", "1"), xa("hidden", "0")], [])
}

///|
fn sml_aux_border_side(
  name : String,
  style : String,
  color : String,
) -> @xml.Element {
  sml_aux_el(name, [xa("style", style)], [sml_aux_color(color)])
}

///|
fn sml_aux_border() -> @xml.Element {
  sml_aux_el(
    "border",
    [xa("diagonalUp", "1"), xa("diagonalDown", "1"), xa("outline", "1")],
    [
      sml_aux_border_side("start", "thin", "FF4472C4"),
      sml_aux_border_side("end", "medium", "FF70AD47"),
      sml_aux_border_side("left", "dashed", "FFFF0000"),
      sml_aux_border_side("right", "dotted", "FFFFFF00"),
      sml_aux_border_side("top", "double", "FF7030A0"),
      sml_aux_border_side("bottom", "hair", "FF5B9BD5"),
      sml_aux_border_side("diagonal", "dashDot", "FFFFC000"),
      sml_aux_border_side("vertical", "mediumDashDot", "FF00B050"),
      sml_aux_border_side("horizontal", "slantDashDot", "FFC00000"),
    ],
  )
}

///|
fn sml_aux_pattern_fill() -> @xml.Element {
  sml_aux_el("fill", [], [
    sml_aux_el("patternFill", [xa("patternType", "solid")], [
      xe(NS_S, "fgColor", [xa("rgb", "FFDAE8FC")], []),
      xe(NS_S, "bgColor", [xa("rgb", "FFFFFFFF")], []),
    ]),
  ])
}

///|
fn sml_aux_gradient_fill() -> @xml.Element {
  sml_aux_el("fill", [], [
    sml_aux_el(
      "gradientFill",
      [
        xa("type", "linear"),
        xa("degree", "45"),
        xa("left", "0"),
        xa("right", "0"),
        xa("top", "0"),
        xa("bottom", "1"),
      ],
      [
        sml_aux_el("stop", [xa("position", "0")], [sml_aux_color("FFFFFFFF")]),
        sml_aux_el("stop", [xa("position", "1")], [sml_aux_color("FF4472C4")]),
      ],
    ),
  ])
}

///|
fn sml_aux_xf(num_fmt_id : String) -> @xml.Element {
  sml_aux_el(
    "xf",
    [
      xa("numFmtId", num_fmt_id),
      xa("fontId", "0"),
      xa("fillId", "0"),
      xa("borderId", "0"),
      xa("xfId", "0"),
      xa("quotePrefix", "0"),
      xa("pivotButton", "0"),
      xa("applyNumberFormat", "1"),
      xa("applyFont", "1"),
      xa("applyFill", "1"),
      xa("applyBorder", "1"),
      xa("applyAlignment", "1"),
      xa("applyProtection", "1"),
    ],
    [sml_aux_alignment(), sml_aux_protection()],
  )
}

///|
fn sml_aux_stylesheet_part() -> @xml.Element {
  sml_aux_el("styleSheet", [], [
    sml_aux_el("numFmts", [xa("count", "1")], [
      xe(NS_S, "numFmt", [xa("numFmtId", "164"), xa("formatCode", "0.00")], []),
    ]),
    sml_aux_el("fonts", [xa("count", "1")], [sml_aux_font()]),
    sml_aux_el("fills", [xa("count", "2")], [
      sml_aux_pattern_fill(),
      sml_aux_gradient_fill(),
    ]),
    sml_aux_el("borders", [xa("count", "1")], [sml_aux_border()]),
    sml_aux_el("cellStyleXfs", [xa("count", "1")], [sml_aux_xf("0")]),
    sml_aux_el("cellXfs", [xa("count", "2")], [
      sml_aux_xf("0"),
      sml_aux_xf("164"),
    ]),
    sml_aux_el("cellStyles", [xa("count", "1")], [
      xe(
        NS_S,
        "cellStyle",
        [
          xa("name", "CatalogStyle"),
          xa("xfId", "0"),
          xa("builtinId", "0"),
          xa("iLevel", "0"),
          xa("hidden", "0"),
          xa("customBuiltin", "1"),
        ],
        [],
      ),
    ]),
    sml_aux_el("dxfs", [xa("count", "1")], [
      sml_aux_el("dxf", [], [
        sml_aux_font(),
        xe(NS_S, "numFmt", [xa("numFmtId", "165"), xa("formatCode", "#,##0")], []),
        sml_aux_pattern_fill(),
        sml_aux_alignment(),
        sml_aux_border(),
        sml_aux_protection(),
      ]),
    ]),
    sml_aux_el(
      "tableStyles",
      [
        xa("count", "1"),
        xa("defaultTableStyle", "CatalogTable"),
        xa("defaultPivotStyle", "CatalogPivot"),
      ],
      [
        sml_aux_el(
          "tableStyle",
          [
            xa("name", "CatalogTable"),
            xa("pivot", "1"),
            xa("table", "1"),
            xa("count", "1"),
          ],
          [
            xe(
              NS_S,
              "tableStyleElement",
              [xa("type", "wholeTable"), xa("size", "1"), xa("dxfId", "0")],
              [],
            ),
          ],
        ),
      ],
    ),
    sml_aux_el("colors", [], [
      sml_aux_el("indexedColors", [], [
        xe(NS_S, "rgbColor", [xa("rgb", "FF000000")], []),
      ]),
      sml_aux_el("mruColors", [], [sml_aux_color("FF4472C4")]),
    ]),
  ])
}

///|
fn sml_aux_shared_strings_part() -> @xml.Element {
  sml_aux_el("sst", [xa("count", "2"), xa("uniqueCount", "2")], [
    sml_aux_el("si", [], [
      sml_aux_text("t", "Catalog"),
      sml_aux_el("r", [], [
        sml_aux_font_run_properties(),
        sml_aux_text("t", " rich"),
      ]),
      sml_aux_el("rPh", [xa("sb", "0"), xa("eb", "7")], [
        sml_aux_text("t", "Catalog phonetic"),
      ]),
      xe(
        NS_S,
        "phoneticPr",
        [xa("fontId", "0"), xa("type", "Hiragana"), xa("alignment", "center")],
        [],
      ),
    ]),
    sml_aux_el("si", [], [sml_aux_text("t", "Catalog plain")]),
  ])
}

///|
fn sml_aux_comment_anchor() -> @xml.Element {
  sml_aux_el("anchor", [xa("moveWithCells", "1"), xa("sizeWithCells", "1")], [
    xdr_marker("from", "0", "0"),
    xdr_marker("to", "3", "4"),
  ])
}

///|
fn sml_aux_comments_part() -> @xml.Element {
  sml_aux_el("comments", [], [
    sml_aux_el("authors", [], [sml_aux_text("author", "Catalog Author")]),
    sml_aux_el("commentList", [], [
      sml_aux_el(
        "comment",
        [
          xa("ref", "A1"),
          xa("authorId", "0"),
          xa("guid", "{00112233-4455-6677-8899-AABBCCDDEEFF}"),
          xa("shapeId", "0"),
        ],
        [
          sml_aux_el("text", [], [
            sml_aux_text("t", "Catalog comment"),
            sml_aux_el("r", [], [
              sml_aux_font_run_properties(),
              sml_aux_text("t", " with rich text"),
            ]),
            sml_aux_el("rPh", [xa("sb", "0"), xa("eb", "7")], [
              sml_aux_text("t", "Comment phonetic"),
            ]),
            xe(
              NS_S,
              "phoneticPr",
              [
                xa("fontId", "0"),
                xa("type", "fullwidthKatakana"),
                xa("alignment", "left"),
              ],
              [],
            ),
          ]),
          sml_aux_el(
            "commentPr",
            [
              xa("locked", "1"),
              xa("defaultSize", "0"),
              xa("print", "1"),
              xa("disabled", "0"),
              xa("autoFill", "1"),
              xa("autoLine", "1"),
              xa("altText", "Catalog comment"),
              xa("textHAlign", "center"),
              xa("textVAlign", "center"),
              xa("lockText", "1"),
              xa("justLastX", "0"),
              xa("autoScale", "0"),
            ],
            [sml_aux_comment_anchor()],
          ),
        ],
      ),
    ]),
  ])
}

///|
fn sml_aux_workbook_part() -> @xml.Element {
  sml_aux_el("workbook", [xa("conformance", "transitional")], [
    xe(
      NS_S,
      "fileVersion",
      [
        xa("appName", "xl"),
        xa("lastEdited", "7"),
        xa("lowestEdited", "7"),
        xa("rupBuild", "24629"),
      ],
      [],
    ),
    xe(
      NS_S,
      "fileSharing",
      [
        xa("readOnlyRecommended", "1"),
        xa("userName", "catalog"),
        xa("reservationPassword", "0000"),
      ],
      [],
    ),
    xe(
      NS_S,
      "workbookPr",
      [
        xa("date1904", "0"),
        xa("showObjects", "all"),
        xa("filterPrivacy", "1"),
        xa("backupFile", "1"),
        xa("updateLinks", "never"),
        xa("codeName", "ThisWorkbook"),
        xa("checkCompatibility", "1"),
        xa("defaultThemeVersion", "124226"),
      ],
      [],
    ),
    xe(
      NS_S,
      "workbookProtection",
      [
        xa("workbookPassword", "0000"),
        xa("lockStructure", "1"),
        xa("lockWindows", "1"),
        xa("lockRevision", "1"),
      ],
      [],
    ),
    sml_aux_el("bookViews", [], [
      xe(
        NS_S,
        "workbookView",
        [
          xa("visibility", "visible"),
          xa("minimized", "0"),
          xa("showHorizontalScroll", "1"),
          xa("showVerticalScroll", "1"),
          xa("showSheetTabs", "1"),
          xa("xWindow", "0"),
          xa("yWindow", "0"),
          xa("windowWidth", "16000"),
          xa("windowHeight", "9000"),
          xa("tabRatio", "600"),
          xa("firstSheet", "0"),
          xa("activeTab", "0"),
          xa("autoFilterDateGrouping", "1"),
        ],
        [],
      ),
    ]),
    sml_aux_el("sheets", [], [
      xe(
        NS_S,
        "sheet",
        [
          xa("name", "S1"),
          xa("sheetId", "1"),
          xa("state", "visible"),
          sml_aux_rel_attr("id", "rId1"),
        ],
        [],
      ),
    ]),
    sml_aux_el("functionGroups", [xa("builtInGroupCount", "16")], [
      xe(NS_S, "functionGroup", [xa("name", "Catalog")], []),
    ]),
    sml_aux_el("definedNames", [], [
      xe(
        NS_S,
        "definedName",
        [
          xa("name", "CatalogName"),
          xa("comment", "Catalog defined name"),
          xa("customMenu", "Catalog"),
          xa("description", "Fixture defined name"),
          xa("help", "Fixture help"),
          xa("statusBar", "Ready"),
          xa("localSheetId", "0"),
          xa("hidden", "1"),
          xa("function", "1"),
          xa("vbProcedure", "0"),
          xa("xlm", "0"),
          xa("functionGroupId", "1"),
          xa("shortcutKey", "C"),
          xa("publishToServer", "0"),
          xa("workbookParameter", "0"),
        ],
        [Text("S1!$A$1")],
      ),
    ]),
    xe(
      NS_S,
      "calcPr",
      [
        xa("calcId", "191029"),
        xa("calcMode", "auto"),
        xa("fullCalcOnLoad", "1"),
        xa("refMode", "A1"),
        xa("iterate", "1"),
        xa("iterateCount", "10"),
        xa("iterateDelta", "0.001"),
        xa("fullPrecision", "1"),
        xa("calcCompleted", "1"),
        xa("calcOnSave", "1"),
        xa("concurrentCalc", "1"),
        xa("concurrentManualCount", "2"),
        xa("forceFullCalc", "1"),
      ],
      [],
    ),
    xe(NS_S, "oleSize", [xa("ref", "A1:C3")], []),
    sml_aux_el("customWorkbookViews", [], [
      xe(
        NS_S,
        "customWorkbookView",
        [
          xa("name", "CatalogView"),
          xa("guid", "{11223344-5566-7788-99AA-BBCCDDEEFF00}"),
          xa("autoUpdate", "0"),
          xa("mergeInterval", "0"),
          xa("changesSavedWin", "0"),
          xa("onlySync", "0"),
          xa("personalView", "0"),
          xa("includePrintSettings", "1"),
          xa("includeHiddenRowCol", "1"),
          xa("maximized", "0"),
          xa("minimized", "0"),
          xa("showHorizontalScroll", "1"),
          xa("showVerticalScroll", "1"),
          xa("showSheetTabs", "1"),
          xa("xWindow", "0"),
          xa("yWindow", "0"),
          xa("windowWidth", "16000"),
          xa("windowHeight", "9000"),
          xa("tabRatio", "600"),
          xa("activeSheetId", "1"),
          xa("showFormulaBar", "1"),
          xa("showStatusbar", "1"),
          xa("showComments", "commIndicator"),
          xa("showObjects", "all"),
        ],
        [],
      ),
    ]),
    xe(NS_S, "smartTagPr", [xa("embed", "1"), xa("show", "all")], []),
    sml_aux_el("smartTagTypes", [], [
      xe(
        NS_S,
        "smartTagType",
        [
          xa("namespaceUri", "urn:ooxml:catalog"),
          xa("name", "CatalogTag"),
          xa("url", "https://example.invalid/catalog-tag"),
        ],
        [],
      ),
    ]),
    xe(
      NS_S,
      "webPublishing",
      [
        xa("css", "1"),
        xa("thicket", "0"),
        xa("longFileNames", "1"),
        xa("vml", "0"),
        xa("allowPng", "1"),
        xa("targetScreenSize", "1024x768"),
        xa("dpi", "96"),
        xa("codePage", "65001"),
        xa("characterSet", "utf-8"),
      ],
      [],
    ),
    xe(
      NS_S,
      "fileRecoveryPr",
      [
        xa("autoRecover", "1"),
        xa("crashSave", "1"),
        xa("dataExtractLoad", "1"),
        xa("repairLoad", "1"),
      ],
      [],
    ),
    sml_aux_el("webPublishObjects", [xa("count", "1")], [
      xe(
        NS_S,
        "webPublishObject",
        [
          xa("id", "1"),
          xa("divId", "CatalogDiv"),
          xa("sourceObject", "S1"),
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
fn sml_aux_calc_chain_part() -> @xml.Element {
  sml_aux_el("calcChain", [], [
    sml_aux_el(
      "c",
      [
        xa("r", "A1"),
        xa("ref", "A1"),
        xa("i", "1"),
        xa("s", "1"),
        xa("l", "0"),
        xa("t", "0"),
        xa("a", "1"),
      ],
      [],
    ),
  ])
}

///|
fn sml_aux_xml_maps_part() -> @xml.Element {
  // CT_Schema / CT_DataBinding require strict xsd:any children.
  // Use a globally declared SML element so the fixture stays XSD-valid
  // with the vendored ECMA schema set.
  let any_payload = sml_aux_el("metadata", [], [])
  sml_aux_el(
    "MapInfo",
    [xa("SelectionNamespaces", "xmlns:cat='urn:ooxml:catalog'")],
    [
      sml_aux_el(
        "Schema",
        [
          xa("ID", "schema1"),
          xa("Namespace", "urn:ooxml:catalog"),
          xa("SchemaLanguage", "XML Schema"),
        ],
        [any_payload],
      ),
      sml_aux_el(
        "Map",
        [
          xa("ID", "1"),
          xa("Name", "CatalogMap"),
          xa("RootElement", "root"),
          xa("SchemaID", "schema1"),
          xa("ShowImportExportValidationErrors", "0"),
          xa("AutoFit", "1"),
          xa("Append", "0"),
          xa("PreserveSortAFLayout", "1"),
          xa("PreserveFormat", "1"),
        ],
        [
          sml_aux_el(
            "DataBinding",
            [
              xa("DataBindingLoadMode", "1"),
              xa("DataBindingName", "CatalogBinding"),
              xa("FileBinding", "1"),
              xa("ConnectionID", "1"),
              xa("FileBindingName", "catalog.xml"),
            ],
            [sml_aux_calc_chain_part()],
          ),
        ],
      ),
    ],
  )
}

///|
fn sml_aux_connections_part() -> @xml.Element {
  sml_aux_el("connections", [], [
    sml_aux_el(
      "connection",
      [
        xa("id", "1"),
        xa("refreshedVersion", "3"),
        xa("name", "CatalogConnection"),
        xa("description", "Catalog coverage connection"),
        xa("type", "1"),
        xa("saveData", "1"),
        xa("background", "0"),
        xa("refreshOnLoad", "0"),
      ],
      [
        xe(
          NS_S,
          "dbPr",
          [
            xa("connection", "Provider=MSDASQL;Data Source=Catalog;"),
            xa("command", "SELECT 1"),
            xa("commandType", "2"),
          ],
          [],
        ),
        xe(
          NS_S,
          "olapPr",
          [xa("local", "0"), xa("localRefresh", "1"), xa("rowDrillCount", "2")],
          [],
        ),
        sml_aux_el(
          "webPr",
          [
            xa("xml", "1"),
            xa("sourceData", "1"),
            xa("htmlTables", "1"),
            xa("htmlFormat", "all"),
            xa("url", "https://example.invalid/catalog"),
          ],
          [
            sml_aux_el("tables", [xa("count", "3")], [
              xe(NS_S, "m", [], []),
              xe(NS_S, "s", [xa("v", "CatalogTable")], []),
              xe(NS_S, "x", [xa("v", "0")], []),
            ]),
          ],
        ),
        sml_aux_el(
          "textPr",
          [
            xa("fileType", "win"),
            xa("firstRow", "1"),
            xa("delimited", "1"),
            xa("comma", "1"),
            xa("qualifier", "doubleQuote"),
          ],
          [
            sml_aux_el("textFields", [xa("count", "1")], [
              xe(
                NS_S,
                "textField",
                [xa("type", "general"), xa("position", "1")],
                [],
              ),
            ]),
          ],
        ),
        sml_aux_el("parameters", [xa("count", "1")], [
          xe(
            NS_S,
            "parameter",
            [
              xa("name", "Region"),
              xa("sqlType", "12"),
              xa("parameterType", "value"),
              xa("refreshOnChange", "0"),
              xa("string", "North"),
            ],
            [],
          ),
        ]),
      ],
    ),
  ])
}

///|
fn sml_aux_metadata_part() -> @xml.Element {
  sml_aux_el("metadata", [], [
    sml_aux_el("metadataTypes", [xa("count", "1")], [
      xe(
        NS_S,
        "metadataType",
        [
          xa("name", "CatalogMeta"),
          xa("minSupportedVersion", "1"),
          xa("assign", "1"),
          xa("copy", "1"),
          xa("pasteAll", "1"),
          xa("cellMeta", "1"),
        ],
        [],
      ),
    ]),
    sml_aux_el("metadataStrings", [xa("count", "2")], [
      xe(NS_S, "s", [xa("v", "CatalogCube")], []),
      xe(NS_S, "s", [xa("v", "CatalogMember")], []),
    ]),
    sml_aux_el("mdxMetadata", [xa("count", "4")], [
      sml_aux_el("mdx", [xa("n", "0"), xa("f", "m")], [
        sml_aux_el("t", [xa("c", "1")], [xe(NS_S, "n", [xa("x", "0")], [])]),
      ]),
      sml_aux_el("mdx", [xa("n", "1"), xa("f", "s")], [
        sml_aux_el("ms", [xa("ns", "1"), xa("c", "1"), xa("o", "a")], [
          xe(NS_S, "n", [xa("x", "1")], []),
        ]),
      ]),
      sml_aux_el("mdx", [xa("n", "2"), xa("f", "p")], [
        xe(NS_S, "p", [xa("n", "0"), xa("np", "1")], []),
      ]),
      sml_aux_el("mdx", [xa("n", "3"), xa("f", "k")], [
        xe(NS_S, "k", [xa("n", "0"), xa("np", "1"), xa("p", "v")], []),
      ]),
    ]),
    sml_aux_el(
      "futureMetadata",
      [xa("name", "CatalogFuture"), xa("count", "1")],
      [xe(NS_S, "bk", [], [])],
    ),
    sml_aux_el("cellMetadata", [xa("count", "1")], [
      sml_aux_el("bk", [], [xe(NS_S, "rc", [xa("t", "0"), xa("v", "0")], [])]),
    ]),
    sml_aux_el("valueMetadata", [xa("count", "1")], [
      sml_aux_el("bk", [], [xe(NS_S, "rc", [xa("t", "0"), xa("v", "0")], [])]),
    ]),
  ])
}

///|
fn sml_aux_query_table_part() -> @xml.Element {
  sml_aux_el(
    "queryTable",
    [
      xa("name", "CatalogQuery"),
      xa("connectionId", "1"),
      xa("headers", "1"),
      xa("refreshOnLoad", "0"),
      xa("preserveFormatting", "1"),
      xa("adjustColumnWidth", "1"),
    ],
    [
      sml_aux_el(
        "queryTableRefresh",
        [xa("nextId", "3"), xa("preserveSortFilterLayout", "1")],
        [
          sml_aux_el("queryTableFields", [xa("count", "2")], [
            xe(
              NS_S,
              "queryTableField",
              [xa("id", "1"), xa("name", "Region"), xa("tableColumnId", "1")],
              [],
            ),
            xe(
              NS_S,
              "queryTableField",
              [
                xa("id", "2"),
                xa("name", "Sales"),
                xa("dataBound", "1"),
                xa("tableColumnId", "2"),
              ],
              [],
            ),
          ]),
          sml_aux_el("queryTableDeletedFields", [xa("count", "1")], [
            xe(NS_S, "deletedField", [xa("name", "OldField")], []),
          ]),
        ],
      ),
    ],
  )
}

///|
fn sml_aux_revision_headers_part() -> @xml.Element {
  sml_aux_el(
    "headers",
    [
      xa("guid", "{233BEE23-EB5C-4542-905D-0230EFFED88B}"),
      xa("diskRevisions", "1"),
      xa("revisionId", "12"),
      xa("version", "3"),
    ],
    [
      sml_aux_el(
        "header",
        [
          xa("guid", "{A5A4B6F1-2B31-4B09-9AC8-000000000011}"),
          xa("dateTime", "2026-06-06T00:00:00Z"),
          xa("maxSheetId", "1"),
          xa("userName", "Catalog User"),
          sml_aux_rel_attr("id", "rId1"),
          xa("minRId", "1"),
          xa("maxRId", "12"),
        ],
        [
          sml_aux_el("sheetIdMap", [xa("count", "1")], [
            sml_aux_el("sheetId", [xa("val", "1")], []),
          ]),
          sml_aux_el("reviewedList", [xa("count", "1")], [
            sml_aux_el("reviewed", [xa("rId", "12")], []),
          ]),
        ],
      ),
    ],
  )
}

///|
fn sml_aux_revision_cell(
  name : String,
  ref_ : String,
  value : String,
) -> @xml.Element {
  sml_aux_el(name, [xa("r", ref_), xa("t", "str")], [sml_aux_text("v", value)])
}

///|
fn sml_aux_revision_log_part() -> @xml.Element {
  sml_aux_el("revisions", [], [
    sml_aux_el(
      "rrc",
      [
        xa("rId", "1"),
        xa("sId", "1"),
        xa("ref", "A1:A1"),
        xa("action", "insertRow"),
      ],
      [
        sml_aux_el(
          "undo",
          [
            xa("index", "0"),
            xa("exp", "ref"),
            xa("dr", "A1"),
            xa("r", "A1"),
            xa("sId", "1"),
          ],
          [],
        ),
      ],
    ),
    sml_aux_el(
      "rm",
      [
        xa("rId", "2"),
        xa("sheetId", "1"),
        xa("source", "A1:A1"),
        xa("destination", "B1:B1"),
      ],
      [],
    ),
    sml_aux_el(
      "rcv",
      [
        xa("guid", "{A5A4B6F1-2B31-4B09-9AC8-000000000012}"),
        xa("action", "add"),
      ],
      [],
    ),
    sml_aux_el(
      "rsnm",
      [
        xa("rId", "3"),
        xa("sheetId", "1"),
        xa("oldName", "OldName"),
        xa("newName", "S1"),
      ],
      [],
    ),
    sml_aux_el(
      "ris",
      [
        xa("rId", "4"),
        xa("sheetId", "1"),
        xa("name", "S1"),
        xa("sheetPosition", "0"),
      ],
      [],
    ),
    sml_aux_el(
      "rcc",
      [xa("rId", "5"), xa("sId", "1"), xa("dxf", "1"), xa("odxf", "1")],
      [
        sml_aux_revision_cell("oc", "A1", "old"),
        sml_aux_revision_cell("nc", "A1", "new"),
        sml_aux_el("odxf", [], []),
        sml_aux_el("ndxf", [], []),
      ],
    ),
    sml_aux_el(
      "rfmt",
      [
        xa("sheetId", "1"),
        xa("sqref", "A1:B2"),
        xa("start", "0"),
        xa("length", "1"),
      ],
      [sml_aux_el("dxf", [], [])],
    ),
    sml_aux_el(
      "raf",
      [
        xa("sheetId", "1"),
        xa("ref", "A1:B2"),
        xa("autoFormatId", "1"),
        xa("applyNumberFormats", "1"),
        xa("applyFontFormats", "1"),
      ],
      [],
    ),
    sml_aux_el("rdn", [xa("rId", "6"), xa("name", "CatalogName")], [
      sml_aux_text("formula", "S1!$A$1"),
      sml_aux_text("oldFormula", "S1!$B$1"),
    ]),
    sml_aux_el(
      "rcmt",
      [
        xa("sheetId", "1"),
        xa("cell", "A1"),
        xa("guid", "{A5A4B6F1-2B31-4B09-9AC8-000000000013}"),
        xa("action", "add"),
        xa("author", "Catalog User"),
        xa("newLength", "7"),
      ],
      [],
    ),
    sml_aux_el(
      "rqt",
      [xa("sheetId", "1"), xa("ref", "A1:B2"), xa("fieldId", "1")],
      [],
    ),
    sml_aux_el("rcft", [xa("rId", "7"), xa("sheetId", "1")], []),
  ])
}

///|
fn sml_aux_users_part() -> @xml.Element {
  sml_aux_el("users", [xa("count", "1")], [
    sml_aux_el(
      "userInfo",
      [
        xa("guid", "{A5A4B6F1-2B31-4B09-9AC8-000000000014}"),
        xa("name", "Catalog User"),
        xa("id", "1"),
        xa("dateTime", "2026-06-06T00:00:00Z"),
      ],
      [],
    ),
  ])
}

///|
fn sml_aux_volatile_dependencies_part() -> @xml.Element {
  sml_aux_el("volTypes", [], [
    sml_aux_el("volType", [xa("type", "realTimeData")], [
      sml_aux_el("main", [xa("first", "RTD")], [
        sml_aux_el("tp", [xa("t", "s")], [
          sml_aux_text("v", "CatalogTopic"),
          sml_aux_text("stp", "Server"),
          sml_aux_el("tr", [xa("r", "A1"), xa("s", "1")], []),
        ]),
      ]),
    ]),
  ])
}

///|
fn sml_aux_object_anchor() -> @xml.Element {
  sml_aux_el("anchor", [xa("moveWithCells", "1"), xa("sizeWithCells", "1")], [
    xdr_marker("from", "0", "0"),
    xdr_marker("to", "3", "5"),
  ])
}

///|
fn sml_aux_custom_properties() -> @xml.Element {
  sml_aux_el("customProperties", [], [
    xe(
      NS_S,
      "customPr",
      [xa("name", "CatalogProperty"), sml_aux_rel_attr("id", "rIdCustom")],
      [],
    ),
  ])
}

///|
fn sml_aux_legacy_drawing_hf() -> @xml.Element {
  xe(NS_S, "legacyDrawingHF", [sml_aux_rel_attr("id", "rIdLegacyHF")], [])
}

///|
fn sml_aux_drawing_hf() -> @xml.Element {
  xe(
    NS_S,
    "drawingHF",
    [
      sml_aux_rel_attr("id", "rIdDrawingHF"),
      xa("lho", "1"),
      xa("lhe", "2"),
      xa("lhf", "3"),
      xa("cho", "4"),
      xa("che", "5"),
      xa("chf", "6"),
    ],
    [],
  )
}

///|
fn sml_aux_picture() -> @xml.Element {
  xe(NS_S, "picture", [sml_aux_rel_attr("id", "rIdPicture")], [])
}

///|
fn sml_aux_ole_objects() -> @xml.Element {
  sml_aux_el("oleObjects", [], [
    sml_aux_el(
      "oleObject",
      [xa("shapeId", "1"), xa("progId", "Forms.TextBox.1"), xa("autoLoad", "1")],
      [
        sml_aux_el(
          "objectPr",
          [
            xa("locked", "0"),
            xa("defaultSize", "0"),
            xa("print", "1"),
            xa("disabled", "0"),
            xa("autoFill", "0"),
            xa("autoLine", "0"),
            xa("altText", "Catalog OLE object"),
          ],
          [sml_aux_object_anchor()],
        ),
      ],
    ),
  ])
}

///|
fn sml_aux_controls() -> @xml.Element {
  sml_aux_el("controls", [], [
    sml_aux_el(
      "control",
      [
        xa("shapeId", "2"),
        xa("name", "CatalogControl"),
        sml_aux_rel_attr("id", "rIdControl"),
      ],
      [
        sml_aux_el(
          "controlPr",
          [
            xa("locked", "0"),
            xa("defaultSize", "0"),
            xa("print", "0"),
            xa("disabled", "1"),
            xa("recalcAlways", "1"),
            xa("autoFill", "0"),
            xa("autoLine", "0"),
            xa("autoPict", "0"),
            xa("linkedCell", "$A$1"),
            xa("listFillRange", "$A$1:$A$3"),
            xa("cf", "pict"),
            xa("altText", "Catalog embedded control"),
          ],
          [sml_aux_object_anchor()],
        ),
      ],
    ),
  ])
}

///|
fn sml_aux_worksheet_refs_part() -> @xml.Element {
  sml_aux_el("worksheet", [], [
    xe(NS_S, "dimension", [xa("ref", "A1:C3")], []),
    sml_aux_el("sheetData", [], [
      sml_aux_el("row", [xa("r", "1")], [
        xe(NS_S, "c", [xa("r", "A1"), xa("t", "str")], [
          Element(xe(NS_S, "v", [], [Text("control")])),
        ]),
      ]),
    ]),
    sml_aux_custom_properties(),
    sml_aux_legacy_drawing_hf(),
    sml_aux_drawing_hf(),
    sml_aux_picture(),
    sml_aux_ole_objects(),
    sml_aux_controls(),
  ])
}

///|
fn sml_aux_chartsheet_part() -> @xml.Element {
  sml_aux_el("chartsheet", [], [
    sml_aux_el("sheetViews", [], [
      xe(NS_S, "sheetView", [xa("workbookViewId", "0"), xa("zoomToFit", "1")], []),
    ]),
    xe(NS_S, "drawing", [sml_aux_rel_attr("id", "rIdDrawing")], []),
    sml_aux_legacy_drawing_hf(),
    sml_aux_drawing_hf(),
    sml_aux_picture(),
  ])
}

///|
fn sml_aux_dialogsheet_part() -> @xml.Element {
  sml_aux_el("dialogsheet", [], [
    sml_aux_legacy_drawing_hf(),
    sml_aux_drawing_hf(),
    sml_aux_ole_objects(),
    sml_aux_controls(),
  ])
}

///|
fn sml_aux_single_xml_cells_part() -> @xml.Element {
  catalog_sml_single_xml_cells_minimal()
}

///|
fn extras_sml_aux_parts(cases : Array[VisualCase]) -> Unit {
  cases.push({
    id: "workbook-aux-rich",
    format: "xlsx:workbook",
    category: "sml-aux",
    content: sml_aux_workbook_part(),
  })
  cases.push({
    id: "shared-strings-rich",
    format: "xlsx:sharedStrings",
    category: "sml-aux",
    content: sml_aux_shared_strings_part(),
  })
  cases.push({
    id: "styles-rich",
    format: "xlsx:styles",
    category: "sml-aux",
    content: sml_aux_stylesheet_part(),
  })
  cases.push({
    id: "comments-rich",
    format: "xlsx:comments",
    category: "sml-aux",
    content: sml_aux_comments_part(),
  })
  cases.push({
    id: "calc-chain-rich",
    format: "xlsx:calcChain",
    category: "sml-aux",
    content: sml_aux_calc_chain_part(),
  })
  cases.push({
    id: "xml-maps-rich",
    format: "xlsx:xmlMaps",
    category: "sml-aux",
    content: sml_aux_xml_maps_part(),
  })
  cases.push({
    id: "connections-rich",
    format: "xlsx:connections",
    category: "sml-aux",
    content: sml_aux_connections_part(),
  })
  cases.push({
    id: "metadata-rich",
    format: "xlsx:metadata",
    category: "sml-aux",
    content: sml_aux_metadata_part(),
  })
  cases.push({
    id: "query-table-rich",
    format: "xlsx:queryTable",
    category: "sml-aux",
    content: sml_aux_query_table_part(),
  })
  cases.push({
    id: "revision-headers-rich",
    format: "xlsx:revisionHeaders",
    category: "sml-aux",
    content: sml_aux_revision_headers_part(),
  })
  cases.push({
    id: "revision-log-rich",
    format: "xlsx:revisionLog",
    category: "sml-aux",
    content: sml_aux_revision_log_part(),
  })
  cases.push({
    id: "shared-users-rich",
    format: "xlsx:userNames",
    category: "sml-aux",
    content: sml_aux_users_part(),
  })
  cases.push({
    id: "volatile-dependencies-rich",
    format: "xlsx:volatileDependencies",
    category: "sml-aux",
    content: sml_aux_volatile_dependencies_part(),
  })
  cases.push({
    id: "worksheet-refs-rich",
    format: "xlsx:worksheetRefs",
    category: "sml-aux",
    content: sml_aux_worksheet_refs_part(),
  })
  cases.push({
    id: "chartsheet-rich",
    format: "xlsx:chartsheet",
    category: "sml-aux",
    content: sml_aux_chartsheet_part(),
  })
  cases.push({
    id: "dialogsheet-rich",
    format: "xlsx:dialogsheet",
    category: "sml-aux",
    content: sml_aux_dialogsheet_part(),
  })
  cases.push({
    id: "single-xml-cells-rich",
    format: "xlsx:tableSingleCells",
    category: "sml-aux",
    content: sml_aux_single_xml_cells_part(),
  })
}

///|
fn sml_aux_style_probe_worksheet() -> @xml.Element {
  sml_aux_el("worksheet", [], [
    xe(NS_S, "dimension", [xa("ref", "A1:A1")], []),
    sml_aux_el("sheetData", [], [
      sml_aux_el("row", [xa("r", "1")], [
        xe(NS_S, "c", [xa("r", "A1"), xa("s", "1")], [
          Element(xe(NS_S, "v", [], [Text("1234.5")])),
        ]),
      ]),
    ]),
  ])
}

///|
fn extras_sml_aux_parts_styled(xcases : Array[ExtendedCase]) -> Unit {
  xcases.push({
    id: "styles-rich-full",
    format: "xlsx",
    category: "sml-aux",
    content: sml_aux_style_probe_worksheet(),
    styles: Some(sml_aux_stylesheet_part()),
    numbering: None,
    doc_styles: None,
  })
}
