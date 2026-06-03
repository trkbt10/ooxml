///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "SML top-level readers round trip through builders" {
  let calc_chain = read_calc_chain(bytes("<s:calcChain xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_calc_chain(@builder.write_calc_chain(calc_chain)).element.name.local_name,
    "calcChain",
  )
  let comments = read_comments(bytes("<s:comments xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_comments(@builder.write_comments(comments)).element.name.local_name,
    "comments",
  )
  let map_info = read_map_info(bytes("<s:MapInfo xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_map_info(@builder.write_map_info(map_info)).element.name.local_name,
    "MapInfo",
  )
  let connections = read_connections(
    bytes("<s:connections xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_connections(@builder.write_connections(connections)).element.name.local_name,
    "connections",
  )
  let pivot_cache_definition = read_pivot_cache_definition(
    bytes("<s:pivotCacheDefinition xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_pivot_cache_definition(
      @builder.write_pivot_cache_definition(pivot_cache_definition),
    ).element.name.local_name,
    "pivotCacheDefinition",
  )
  let pivot_cache_records = read_pivot_cache_records(
    bytes("<s:pivotCacheRecords xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_pivot_cache_records(
      @builder.write_pivot_cache_records(pivot_cache_records),
    ).element.name.local_name,
    "pivotCacheRecords",
  )
  let pivot_table_definition = read_pivot_table_definition(
    bytes("<s:pivotTableDefinition xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_pivot_table_definition(
      @builder.write_pivot_table_definition(pivot_table_definition),
    ).element.name.local_name,
    "pivotTableDefinition",
  )
  let query_table = read_query_table(bytes("<s:queryTable xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_query_table(@builder.write_query_table(query_table)).element.name.local_name,
    "queryTable",
  )
  let sst = read_sst(bytes("<s:sst xmlns:s=\"urn:s\"/>"))
  assert_eq(read_sst(@builder.write_sst(sst)).element.name.local_name, "sst")
  let shared_strings = read_shared_strings(
    bytes("<s:sharedStrings xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_shared_strings(@builder.write_shared_strings(shared_strings)).element.name.local_name,
    "sharedStrings",
  )
  let headers = read_headers(bytes("<s:headers xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_headers(@builder.write_headers(headers)).element.name.local_name,
    "headers",
  )
  let revisions = read_revisions(bytes("<s:revisions xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_revisions(@builder.write_revisions(revisions)).element.name.local_name,
    "revisions",
  )
  let users = read_users(bytes("<s:users xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_users(@builder.write_users(users)).element.name.local_name,
    "users",
  )
  let worksheet = read_worksheet(bytes("<s:worksheet xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_worksheet(@builder.write_worksheet(worksheet)).element.name.local_name,
    "worksheet",
  )
  let chartsheet = read_chartsheet(bytes("<s:chartsheet xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_chartsheet(@builder.write_chartsheet(chartsheet)).element.name.local_name,
    "chartsheet",
  )
  let dialogsheet = read_dialogsheet(
    bytes("<s:dialogsheet xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_dialogsheet(@builder.write_dialogsheet(dialogsheet)).element.name.local_name,
    "dialogsheet",
  )
  let vol_types = read_vol_types(bytes("<s:volTypes xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_vol_types(@builder.write_vol_types(vol_types)).element.name.local_name,
    "volTypes",
  )
  let metadata = read_metadata(bytes("<s:metadata xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_metadata(@builder.write_metadata(metadata)).element.name.local_name,
    "metadata",
  )
  let single_xml_cells = read_single_xml_cells(
    bytes("<s:singleXmlCells xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_single_xml_cells(@builder.write_single_xml_cells(single_xml_cells)).element.name.local_name,
    "singleXmlCells",
  )
  let table_single_cells = read_table_single_cells(
    bytes("<s:tableSingleCells xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_table_single_cells(
      @builder.write_table_single_cells(table_single_cells),
    ).element.name.local_name,
    "tableSingleCells",
  )
  let style_sheet = read_style_sheet(bytes("<s:styleSheet xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_style_sheet(@builder.write_style_sheet(style_sheet)).element.name.local_name,
    "styleSheet",
  )
  let table = read_table(bytes("<s:table xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_table(@builder.write_table(table)).element.name.local_name,
    "table",
  )
  let workbook = read_workbook(bytes("<s:workbook xmlns:s=\"urn:s\"/>"))
  assert_eq(
    read_workbook(@builder.write_workbook(workbook)).element.name.local_name,
    "workbook",
  )
  let external_link = read_external_link(
    bytes("<s:externalLink xmlns:s=\"urn:s\"/>"),
  )
  assert_eq(
    read_external_link(@builder.write_external_link(external_link)).element.name.local_name,
    "externalLink",
  )
}

///|
test "SML top-level readers reject the wrong root element" {
  let invalid = try? read_worksheet(bytes("<s:chartsheet xmlns:s=\"urn:s\"/>"))
  assert_true(invalid is Err(SchemaViolation(_)))
}

///|
fn assert_style_sheet_schema_violation(body : String) -> Unit raise {
  let invalid = try? read_style_sheet(
    bytes("<s:styleSheet xmlns:s=\"urn:s\">" + body + "</s:styleSheet>"),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_style_xf_bool_schema_violation(local_name : String) -> Unit raise {
  assert_style_sheet_schema_violation(
    "<s:cellXfs><s:xf " + local_name + "=\"maybe\"/></s:cellXfs>",
  )
}

///|
fn assert_style_alignment_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_style_sheet_schema_violation(
    "<s:cellXfs><s:xf><s:alignment " +
    local_name +
    "=\"maybe\"/></s:xf></s:cellXfs>",
  )
}

///|
fn assert_style_border_bool_schema_violation(local_name : String) -> Unit raise {
  assert_style_sheet_schema_violation(
    "<s:borders><s:border " + local_name + "=\"maybe\"/></s:borders>",
  )
}

///|
fn assert_style_cell_protection_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_style_sheet_schema_violation(
    "<s:cellXfs><s:xf><s:protection " +
    local_name +
    "=\"maybe\"/></s:xf></s:cellXfs>",
  )
}

///|
fn assert_style_cell_style_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_style_sheet_schema_violation(
    "<s:cellStyles><s:cellStyle xfId=\"0\" " +
    local_name +
    "=\"maybe\"/></s:cellStyles>",
  )
}

///|
fn assert_table_style_bool_schema_violation(local_name : String) -> Unit raise {
  assert_style_sheet_schema_violation(
    "<s:tableStyles><s:tableStyle name=\"Custom\" " +
    local_name +
    "=\"maybe\"/></s:tableStyles>",
  )
}

///|
test "SML styleSheet reader rejects malformed style booleans" {
  assert_style_alignment_bool_schema_violation("wrapText")
  assert_style_alignment_bool_schema_violation("justifyLastLine")
  assert_style_alignment_bool_schema_violation("shrinkToFit")
  assert_style_border_bool_schema_violation("diagonalUp")
  assert_style_border_bool_schema_violation("diagonalDown")
  assert_style_border_bool_schema_violation("outline")
  assert_style_sheet_schema_violation(
    "<s:borders><s:border><s:top><s:color auto=\"maybe\"/></s:top></s:border></s:borders>",
  )
  assert_style_cell_protection_bool_schema_violation("locked")
  assert_style_cell_protection_bool_schema_violation("hidden")
  assert_style_xf_bool_schema_violation("quotePrefix")
  assert_style_xf_bool_schema_violation("pivotButton")
  assert_style_xf_bool_schema_violation("applyNumberFormat")
  assert_style_xf_bool_schema_violation("applyFont")
  assert_style_xf_bool_schema_violation("applyFill")
  assert_style_xf_bool_schema_violation("applyBorder")
  assert_style_xf_bool_schema_violation("applyAlignment")
  assert_style_xf_bool_schema_violation("applyProtection")
  assert_style_cell_style_bool_schema_violation("hidden")
  assert_style_cell_style_bool_schema_violation("customBuiltin")
  assert_table_style_bool_schema_violation("pivot")
  assert_table_style_bool_schema_violation("table")
  assert_style_sheet_schema_violation(
    "<s:fonts><s:font><s:b val=\"maybe\"/></s:font></s:fonts>",
  )
  assert_style_sheet_schema_violation(
    "<s:colors><s:mruColors><s:color auto=\"maybe\"/></s:mruColors></s:colors>",
  )
}

///|
test "SML styleSheet reader rejects malformed style unsigned integers" {
  assert_style_sheet_schema_violation("<s:fonts count=\"abc\"/>")
  assert_style_sheet_schema_violation(
    "<s:numFmts><s:numFmt numFmtId=\"abc\"/></s:numFmts>",
  )
  assert_style_sheet_schema_violation(
    "<s:cellXfs><s:xf fontId=\"abc\"/></s:cellXfs>",
  )
  assert_style_sheet_schema_violation(
    "<s:tableStyles><s:tableStyle name=\"Custom\">" +
    "<s:tableStyleElement size=\"abc\"/>" +
    "</s:tableStyle></s:tableStyles>",
  )
}

///|
test "SML styleSheet reader rejects malformed style signed integers" {
  assert_style_sheet_schema_violation(
    "<s:cellXfs><s:xf><s:alignment relativeIndent=\"abc\"/></s:xf></s:cellXfs>",
  )
  assert_style_sheet_schema_violation(
    "<s:fonts><s:font><s:charset val=\"abc\"/></s:font></s:fonts>",
  )
}

///|
test "SML styleSheet reader rejects malformed style doubles" {
  assert_style_sheet_schema_violation(
    "<s:fills><s:fill><s:gradientFill degree=\"abc\"/></s:fill></s:fills>",
  )
  assert_style_sheet_schema_violation(
    "<s:fills><s:fill><s:gradientFill><s:stop position=\"abc\"/>" +
    "</s:gradientFill></s:fill></s:fills>",
  )
  assert_style_sheet_schema_violation(
    "<s:fonts><s:font><s:sz val=\"abc\"/></s:font></s:fonts>",
  )
  assert_style_sheet_schema_violation(
    "<s:colors><s:mruColors><s:color tint=\"abc\"/></s:mruColors></s:colors>",
  )
}

///|
test "SML styleSheet reader rejects malformed style hex integers" {
  assert_style_sheet_schema_violation(
    "<s:colors><s:indexedColors><s:rgbColor rgb=\"nothex\"/></s:indexedColors></s:colors>",
  )
}

///|
fn assert_sst_schema_violation(body : String) -> Unit raise {
  let invalid = try? read_sst(
    bytes("<s:sst xmlns:s=\"urn:s\">" + body + "</s:sst>"),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_sst_source_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_sst(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML shared-string reader rejects malformed rich-text booleans" {
  assert_sst_schema_violation(
    "<s:si><s:r><s:rPr><s:b val=\"maybe\"/></s:rPr><s:t>x</s:t></s:r></s:si>",
  )
  assert_sst_schema_violation(
    "<s:si><s:r><s:rPr><s:color auto=\"maybe\"/></s:rPr><s:t>x</s:t></s:r></s:si>",
  )
}

///|
test "SML shared-string reader rejects malformed root unsigned integers" {
  assert_sst_source_schema_violation("<s:sst xmlns:s=\"urn:s\" count=\"abc\"/>")
  let invalid_shared_strings = try? read_shared_strings(
    bytes("<s:sharedStrings xmlns:s=\"urn:s\" uniqueCount=\"abc\"/>"),
  )
  assert_true(invalid_shared_strings is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML shared-string reader rejects malformed phonetic unsigned integers" {
  assert_sst_schema_violation(
    "<s:si><s:rPh sb=\"abc\" eb=\"1\"><s:t>x</s:t></s:rPh></s:si>",
  )
  assert_sst_schema_violation(
    "<s:si><s:rPh sb=\"0\" eb=\"abc\"><s:t>x</s:t></s:rPh></s:si>",
  )
  assert_sst_schema_violation("<s:si><s:phoneticPr fontId=\"abc\"/></s:si>")
}

///|
fn assert_workbook_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_workbook(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML workbook reader rejects malformed file recovery booleans" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:fileRecoveryPr autoRecover=\"maybe\"/>" +
    "</s:workbook>",
  )
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:fileRecoveryPr crashSave=\"maybe\"/>" +
    "</s:workbook>",
  )
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:fileRecoveryPr dataExtractLoad=\"maybe\"/>" +
    "</s:workbook>",
  )
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:fileRecoveryPr repairLoad=\"maybe\"/>" +
    "</s:workbook>",
  )
}

///|
fn assert_workbook_calc_pr_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:calcPr " +
    local_name +
    "=\"maybe\"/></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed calculation property booleans" {
  assert_workbook_calc_pr_bool_schema_violation("fullCalcOnLoad")
  assert_workbook_calc_pr_bool_schema_violation("iterate")
  assert_workbook_calc_pr_bool_schema_violation("fullPrecision")
  assert_workbook_calc_pr_bool_schema_violation("calcCompleted")
  assert_workbook_calc_pr_bool_schema_violation("calcOnSave")
  assert_workbook_calc_pr_bool_schema_violation("concurrentCalc")
  assert_workbook_calc_pr_bool_schema_violation("forceFullCalc")
}

///|
fn assert_workbook_calc_pr_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:calcPr " +
    local_name +
    "=\"abc\"/></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed calculation property numerics" {
  assert_workbook_calc_pr_numeric_schema_violation("calcId")
  assert_workbook_calc_pr_numeric_schema_violation("iterateCount")
  assert_workbook_calc_pr_numeric_schema_violation("iterateDelta")
  assert_workbook_calc_pr_numeric_schema_violation("concurrentManualCount")
}

///|
test "SML workbook reader rejects malformed file sharing booleans" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\">" +
    "<s:fileSharing readOnlyRecommended=\"maybe\"/>" +
    "</s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed file sharing unsigned integers" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:fileSharing spinCount=\"abc\"/>" +
    "</s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed smart tag property booleans" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:smartTagPr embed=\"maybe\"/>" +
    "</s:workbook>",
  )
}

///|
fn assert_workbook_web_publishing_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:webPublishing " +
    local_name +
    "=\"maybe\"/></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed web publishing booleans" {
  assert_workbook_web_publishing_bool_schema_violation("css")
  assert_workbook_web_publishing_bool_schema_violation("thicket")
  assert_workbook_web_publishing_bool_schema_violation("longFileNames")
  assert_workbook_web_publishing_bool_schema_violation("vml")
  assert_workbook_web_publishing_bool_schema_violation("allowPng")
}

///|
fn assert_workbook_web_publishing_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:webPublishing " +
    local_name +
    "=\"abc\"/></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed web publishing numerics" {
  assert_workbook_web_publishing_numeric_schema_violation("dpi")
  assert_workbook_web_publishing_numeric_schema_violation("codePage")
}

///|
fn assert_workbook_defined_name_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:definedNames><s:definedName name=\"n\" " +
    local_name +
    "=\"maybe\">Sheet1!$A$1</s:definedName></s:definedNames></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed defined name booleans" {
  assert_workbook_defined_name_bool_schema_violation("hidden")
  assert_workbook_defined_name_bool_schema_violation("function")
  assert_workbook_defined_name_bool_schema_violation("vbProcedure")
  assert_workbook_defined_name_bool_schema_violation("xlm")
  assert_workbook_defined_name_bool_schema_violation("publishToServer")
  assert_workbook_defined_name_bool_schema_violation("workbookParameter")
}

///|
fn assert_workbook_defined_name_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:definedNames><s:definedName name=\"n\" " +
    local_name +
    "=\"abc\">Sheet1!$A$1</s:definedName></s:definedNames></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed defined name numerics" {
  assert_workbook_defined_name_numeric_schema_violation("localSheetId")
  assert_workbook_defined_name_numeric_schema_violation("functionGroupId")
}

///|
fn assert_workbook_pr_bool_schema_violation(local_name : String) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:workbookPr " +
    local_name +
    "=\"maybe\"/></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed workbook property booleans" {
  assert_workbook_pr_bool_schema_violation("date1904")
  assert_workbook_pr_bool_schema_violation("showBorderUnselectedTables")
  assert_workbook_pr_bool_schema_violation("filterPrivacy")
  assert_workbook_pr_bool_schema_violation("promptedSolutions")
  assert_workbook_pr_bool_schema_violation("showInkAnnotation")
  assert_workbook_pr_bool_schema_violation("backupFile")
  assert_workbook_pr_bool_schema_violation("saveExternalLinkValues")
  assert_workbook_pr_bool_schema_violation("hidePivotFieldList")
  assert_workbook_pr_bool_schema_violation("showPivotChartFilter")
  assert_workbook_pr_bool_schema_violation("allowRefreshQuery")
  assert_workbook_pr_bool_schema_violation("publishItems")
  assert_workbook_pr_bool_schema_violation("checkCompatibility")
  assert_workbook_pr_bool_schema_violation("autoCompressPictures")
  assert_workbook_pr_bool_schema_violation("refreshAllConnections")
}

///|
test "SML workbook reader rejects malformed workbook property unsigned integers" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:workbookPr defaultThemeVersion=\"abc\"/>" +
    "</s:workbook>",
  )
}

///|
fn assert_workbook_protection_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:workbookProtection " +
    local_name +
    "=\"maybe\"/></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed workbook protection booleans" {
  assert_workbook_protection_bool_schema_violation("lockStructure")
  assert_workbook_protection_bool_schema_violation("lockWindows")
  assert_workbook_protection_bool_schema_violation("lockRevision")
}

///|
test "SML workbook reader rejects malformed workbook protection unsigned integers" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\">" +
    "<s:workbookProtection revisionsSpinCount=\"abc\"/>" +
    "</s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed web publish object booleans" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:webPublishObjects>" +
    "<s:webPublishObject id=\"1\" divId=\"d1\" sourceObject=\"Sheet1\" " +
    "destinationFile=\"out.htm\" autoRepublish=\"maybe\"/>" +
    "</s:webPublishObjects></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed web publish object unsigned integers" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:webPublishObjects count=\"abc\">" +
    "<s:webPublishObject id=\"1\" divId=\"d1\" sourceObject=\"Sheet1\" " +
    "destinationFile=\"out.htm\"/>" +
    "</s:webPublishObjects></s:workbook>",
  )
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:webPublishObjects>" +
    "<s:webPublishObject id=\"abc\" divId=\"d1\" sourceObject=\"Sheet1\" " +
    "destinationFile=\"out.htm\"/>" +
    "</s:webPublishObjects></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed function group unsigned integers" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:functionGroups builtInGroupCount=\"abc\"/>" +
    "</s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed sheet unsigned integers" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:sheets><s:sheet name=\"Sheet1\" sheetId=\"abc\"/></s:sheets></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed pivot cache unsigned integers" {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:pivotCaches>" +
    "<s:pivotCache cacheId=\"abc\"/>" +
    "</s:pivotCaches></s:workbook>",
  )
}

///|
fn assert_workbook_view_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:bookViews><s:workbookView " +
    local_name +
    "=\"maybe\"/></s:bookViews></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed workbook view booleans" {
  assert_workbook_view_bool_schema_violation("showSheetTabs")
  assert_workbook_view_bool_schema_violation("showHorizontalScroll")
  assert_workbook_view_bool_schema_violation("showVerticalScroll")
  assert_workbook_view_bool_schema_violation("minimized")
  assert_workbook_view_bool_schema_violation("autoFilterDateGrouping")
}

///|
fn assert_workbook_view_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:bookViews><s:workbookView " +
    local_name +
    "=\"abc\"/></s:bookViews></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed workbook view numerics" {
  assert_workbook_view_numeric_schema_violation("activeTab")
  assert_workbook_view_numeric_schema_violation("firstSheet")
  assert_workbook_view_numeric_schema_violation("xWindow")
  assert_workbook_view_numeric_schema_violation("yWindow")
  assert_workbook_view_numeric_schema_violation("windowWidth")
  assert_workbook_view_numeric_schema_violation("windowHeight")
  assert_workbook_view_numeric_schema_violation("tabRatio")
}

///|
fn assert_custom_workbook_view_bool_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:customWorkbookViews>" +
    "<s:customWorkbookView name=\"View\" guid=\"{GUID}\" " +
    local_name +
    "=\"maybe\"/></s:customWorkbookViews></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed custom workbook view booleans" {
  assert_custom_workbook_view_bool_schema_violation("maximized")
  assert_custom_workbook_view_bool_schema_violation("showHorizontalScroll")
  assert_custom_workbook_view_bool_schema_violation("showVerticalScroll")
  assert_custom_workbook_view_bool_schema_violation("showSheetTabs")
  assert_custom_workbook_view_bool_schema_violation("autoUpdate")
  assert_custom_workbook_view_bool_schema_violation("changesSavedWin")
  assert_custom_workbook_view_bool_schema_violation("onlySync")
  assert_custom_workbook_view_bool_schema_violation("personalView")
  assert_custom_workbook_view_bool_schema_violation("includePrintSettings")
  assert_custom_workbook_view_bool_schema_violation("includeHiddenRowCol")
  assert_custom_workbook_view_bool_schema_violation("minimized")
  assert_custom_workbook_view_bool_schema_violation("showFormulaBar")
  assert_custom_workbook_view_bool_schema_violation("showStatusbar")
}

///|
fn assert_custom_workbook_view_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_workbook_schema_violation(
    "<s:workbook xmlns:s=\"urn:s\"><s:customWorkbookViews>" +
    "<s:customWorkbookView name=\"View\" guid=\"{GUID}\" " +
    local_name +
    "=\"abc\"/></s:customWorkbookViews></s:workbook>",
  )
}

///|
test "SML workbook reader rejects malformed custom workbook view numerics" {
  assert_custom_workbook_view_numeric_schema_violation("activeSheetId")
  assert_custom_workbook_view_numeric_schema_violation("xWindow")
  assert_custom_workbook_view_numeric_schema_violation("yWindow")
  assert_custom_workbook_view_numeric_schema_violation("windowWidth")
  assert_custom_workbook_view_numeric_schema_violation("windowHeight")
  assert_custom_workbook_view_numeric_schema_violation("tabRatio")
  assert_custom_workbook_view_numeric_schema_violation("mergeInterval")
}

///|
test "SML metadata reader rejects malformed metadataType booleans" {
  let invalid = try? read_metadata(
    bytes(
      "<s:metadata xmlns:s=\"urn:s\">" +
      "<s:metadataTypes>" +
      "<s:metadataType name=\"XLMDX\" minSupportedVersion=\"120000\" copy=\"maybe\"/>" +
      "</s:metadataTypes>" +
      "</s:metadata>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_headers_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_headers(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML headers reader rejects malformed revision-header booleans" {
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\" shared=\"maybe\"/>",
  )
}

///|
test "SML headers reader rejects malformed revision-header unsigned integers" {
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\" revisionId=\"abc\"/>",
  )
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\" preserveHistory=\"abc\"/>",
  )
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\"><s:header maxSheetId=\"abc\"/></s:headers>",
  )
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\"><s:header minRId=\"abc\"/></s:headers>",
  )
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\"><s:header>" +
    "<s:sheetIdMap count=\"abc\"/></s:header></s:headers>",
  )
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\"><s:header>" +
    "<s:sheetIdMap><s:sheetId val=\"abc\"/></s:sheetIdMap>" +
    "</s:header></s:headers>",
  )
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\"><s:header>" +
    "<s:reviewedList count=\"abc\"/></s:header></s:headers>",
  )
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\"><s:header>" +
    "<s:reviewedList><s:reviewed rId=\"abc\"/></s:reviewedList>" +
    "</s:header></s:headers>",
  )
}

///|
test "SML headers reader rejects malformed revision-header signed integers" {
  assert_headers_schema_violation(
    "<s:headers xmlns:s=\"urn:s\" version=\"abc\"/>",
  )
}

///|
fn assert_connections_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_connections(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_connection_child_schema_violation(source : String) -> Unit raise {
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection>" +
    source +
    "</s:connection></s:connections>",
  )
}

///|
test "SML connections reader rejects malformed connection booleans" {
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection keepAlive=\"maybe\"/>" +
    "</s:connections>",
  )
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection savePassword=\"maybe\"/>" +
    "</s:connections>",
  )
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection new=\"maybe\"/>" +
    "</s:connections>",
  )
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection deleted=\"maybe\"/>" +
    "</s:connections>",
  )
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection onlyUseConnectionFile=\"maybe\"/>" +
    "</s:connections>",
  )
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection background=\"maybe\"/>" +
    "</s:connections>",
  )
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection refreshOnLoad=\"maybe\"/>" +
    "</s:connections>",
  )
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection saveData=\"maybe\"/>" +
    "</s:connections>",
  )
}

///|
fn assert_connection_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_connections_schema_violation(
    "<s:connections xmlns:s=\"urn:s\"><s:connection " +
    local_name +
    "=\"abc\"/></s:connections>",
  )
}

///|
test "SML connections reader rejects malformed connection unsigned integers" {
  assert_connection_numeric_schema_violation("id")
  assert_connection_numeric_schema_violation("interval")
  assert_connection_numeric_schema_violation("type")
  assert_connection_numeric_schema_violation("reconnectionMethod")
  assert_connection_numeric_schema_violation("refreshedVersion")
  assert_connection_numeric_schema_violation("minRefreshableVersion")
}

///|
test "SML connections reader rejects malformed connection property booleans" {
  assert_connection_child_schema_violation("<s:olapPr local=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:olapPr localRefresh=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:olapPr sendLocale=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:olapPr serverFill=\"maybe\"/>")
  assert_connection_child_schema_violation(
    "<s:olapPr serverNumberFormat=\"maybe\"/>",
  )
  assert_connection_child_schema_violation("<s:olapPr serverFont=\"maybe\"/>")
  assert_connection_child_schema_violation(
    "<s:olapPr serverFontColor=\"maybe\"/>",
  )
  assert_connection_child_schema_violation("<s:webPr xml=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:webPr sourceData=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:webPr parsePre=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:webPr consecutive=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:webPr firstRow=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:webPr xl97=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:webPr textDates=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:webPr xl2000=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:webPr htmlTables=\"maybe\"/>")
  assert_connection_child_schema_violation(
    "<s:parameters><s:parameter refreshOnChange=\"maybe\"/></s:parameters>",
  )
  assert_connection_child_schema_violation(
    "<s:parameters><s:parameter boolean=\"maybe\"/></s:parameters>",
  )
  assert_connection_child_schema_violation("<s:textPr prompt=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:textPr delimited=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:textPr tab=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:textPr space=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:textPr comma=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:textPr semicolon=\"maybe\"/>")
  assert_connection_child_schema_violation("<s:textPr consecutive=\"maybe\"/>")
}

///|
test "SML connections reader rejects malformed connection property numerics" {
  assert_connection_child_schema_violation("<s:dbPr commandType=\"abc\"/>")
  assert_connection_child_schema_violation("<s:olapPr rowDrillCount=\"abc\"/>")
  assert_connection_child_schema_violation(
    "<s:webPr><s:tables count=\"abc\"/></s:webPr>",
  )
  assert_connection_child_schema_violation("<s:parameters count=\"abc\"/>")
  assert_connection_child_schema_violation(
    "<s:parameters><s:parameter sqlType=\"abc\"/></s:parameters>",
  )
  assert_connection_child_schema_violation(
    "<s:parameters><s:parameter double=\"abc\"/></s:parameters>",
  )
  assert_connection_child_schema_violation(
    "<s:parameters><s:parameter integer=\"abc\"/></s:parameters>",
  )
  assert_connection_child_schema_violation("<s:textPr codePage=\"abc\"/>")
  assert_connection_child_schema_violation("<s:textPr firstRow=\"abc\"/>")
  assert_connection_child_schema_violation(
    "<s:textPr><s:textFields count=\"abc\"/></s:textPr>",
  )
  assert_connection_child_schema_violation(
    "<s:textPr><s:textFields><s:textField position=\"abc\"/>" +
    "</s:textFields></s:textPr>",
  )
}

///|
fn assert_revisions_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_revisions(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML revisions reader rejects malformed revision booleans" {
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rrc ua=\"maybe\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rm><s:undo ref3D=\"maybe\"/>" +
    "</s:rm></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcc odxf=\"maybe\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:raf applyNumberFormats=\"maybe\"/>" +
    "</s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rdn customView=\"maybe\"/>" +
    "</s:revisions>",
  )
}

///|
test "SML revisions reader rejects malformed query-table field numerics" {
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rqt sheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rqt fieldId=\"abc\"/></s:revisions>",
  )
}

///|
test "SML revisions reader rejects malformed sheet revision numerics" {
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rrc rId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rrc sId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rsnm rId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rsnm sheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:ris rId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:ris sheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:ris sheetPosition=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcc rId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcc sId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcc numFmtId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rm><s:undo index=\"abc\"/>" +
    "</s:rm></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rm><s:undo sId=\"abc\"/>" +
    "</s:rm></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rm rId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rm sheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rm sourceSheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rfmt sheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rfmt start=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rfmt length=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:raf sheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:raf autoFormatId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcmt sheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcmt oldLength=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcmt newLength=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rdn rId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rdn localSheetId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rdn functionGroupId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rdn oldFunctionGroupId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rdn shortcutKey=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rdn oldShortcutKey=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcft rId=\"abc\"/></s:revisions>",
  )
  assert_revisions_schema_violation(
    "<s:revisions xmlns:s=\"urn:s\"><s:rcft sheetId=\"abc\"/></s:revisions>",
  )
}

///|
fn assert_users_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_users(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML users reader rejects malformed numerics" {
  assert_users_schema_violation("<s:users xmlns:s=\"urn:s\" count=\"abc\"/>")
  assert_users_schema_violation(
    "<s:users xmlns:s=\"urn:s\"><s:userInfo id=\"abc\"/></s:users>",
  )
}

///|
fn assert_metadata_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_metadata(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML metadata reader rejects malformed MDX tuple booleans" {
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:t i=\"maybe\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
}

///|
test "SML metadata reader rejects malformed MDX member index booleans" {
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:ms><s:n s=\"maybe\"/></s:ms></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
}

///|
test "SML metadata reader rejects malformed unsigned integers" {
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:metadataTypes count=\"abc\"/>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:cellMetadata><s:bk><s:rc t=\"abc\" v=\"0\"/></s:bk></s:cellMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata count=\"abc\"/>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx n=\"abc\"/></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:t c=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:t si=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:t fi=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:ms ns=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:ms c=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:p n=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:p np=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:k n=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
  assert_metadata_schema_violation(
    "<s:metadata xmlns:s=\"urn:s\">" +
    "<s:mdxMetadata><s:mdx><s:k np=\"abc\"/></s:mdx></s:mdxMetadata>" +
    "</s:metadata>",
  )
}

///|
test "SML MapInfo reader rejects malformed Map booleans" {
  let invalid = try? read_map_info(
    bytes(
      "<s:MapInfo xmlns:s=\"urn:s\">" +
      "<s:Map AutoFit=\"maybe\"/>" +
      "</s:MapInfo>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML MapInfo reader rejects malformed DataBinding booleans" {
  let invalid = try? read_map_info(
    bytes(
      "<s:MapInfo xmlns:s=\"urn:s\">" +
      "<s:Map><s:DataBinding FileBinding=\"maybe\"/></s:Map>" +
      "</s:MapInfo>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML MapInfo reader rejects malformed unsigned integers" {
  let invalid = try? read_map_info(
    bytes(
      "<s:MapInfo xmlns:s=\"urn:s\">" + "<s:Map ID=\"abc\"/>" + "</s:MapInfo>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
  let invalid_connection = try? read_map_info(
    bytes(
      "<s:MapInfo xmlns:s=\"urn:s\">" +
      "<s:Map><s:DataBinding ConnectionID=\"abc\"/></s:Map>" +
      "</s:MapInfo>",
    ),
  )
  assert_true(invalid_connection is Err(@opc_errors.SchemaViolation(_)))
  let invalid_load_mode = try? read_map_info(
    bytes(
      "<s:MapInfo xmlns:s=\"urn:s\">" +
      "<s:Map><s:DataBinding DataBindingLoadMode=\"abc\"/></s:Map>" +
      "</s:MapInfo>",
    ),
  )
  assert_true(invalid_load_mode is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML singleXmlCells reader rejects malformed unsigned integers" {
  let invalid = try? read_single_xml_cells(
    bytes(
      "<s:singleXmlCells xmlns:s=\"urn:s\">" +
      "<s:singleXmlCell id=\"abc\" r=\"A1\" connectionId=\"1\"/>" +
      "</s:singleXmlCells>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_external_link_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_external_link(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_pivot_cache_definition_schema_violation(
  source : String,
) -> Unit raise {
  let invalid = try? read_pivot_cache_definition(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_pivot_table_definition_schema_violation(
  source : String,
) -> Unit raise {
  let invalid = try? read_pivot_table_definition(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_pivot_table_item_schema_violation(item_attr : String) -> Unit raise {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotFields><s:pivotField><s:items><s:item " +
    item_attr +
    "/></s:items></s:pivotField></s:pivotFields>" +
    "</s:pivotTableDefinition>",
  )
}

///|
fn assert_pivot_cache_shared_items_schema_violation(
  shared_items_attr : String,
) -> Unit raise {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField><s:sharedItems " +
    shared_items_attr +
    "/></s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
fn assert_pivot_cache_shared_item_schema_violation(
  item_xml : String,
) -> Unit raise {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField><s:sharedItems>" +
    item_xml +
    "</s:sharedItems></s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
fn assert_pivot_cache_field_group_schema_violation(
  field_group_xml : String,
) -> Unit raise {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField>" +
    field_group_xml +
    "</s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
fn assert_query_table_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_query_table(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML queryTable reader rejects malformed booleans" {
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\" headers=\"maybe\"/>",
  )
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\" applyNumberFormats=\"maybe\"/>",
  )
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\">" +
    "<s:queryTableRefresh preserveSortFilterLayout=\"maybe\"/>" +
    "</s:queryTable>",
  )
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\">" +
    "<s:queryTableRefresh><s:queryTableFields>" +
    "<s:queryTableField dataBound=\"maybe\"/>" +
    "</s:queryTableFields></s:queryTableRefresh>" +
    "</s:queryTable>",
  )
}

///|
fn assert_query_table_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\" " + local_name + "=\"abc\"/>",
  )
}

///|
fn assert_query_table_refresh_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\"><s:queryTableRefresh " +
    local_name +
    "=\"abc\"/></s:queryTable>",
  )
}

///|
test "SML queryTable reader rejects malformed unsigned integers" {
  assert_query_table_numeric_schema_violation("connectionId")
  assert_query_table_numeric_schema_violation("autoFormatId")
  assert_query_table_refresh_numeric_schema_violation("minimumVersion")
  assert_query_table_refresh_numeric_schema_violation("nextId")
  assert_query_table_refresh_numeric_schema_violation("unboundColumnsLeft")
  assert_query_table_refresh_numeric_schema_violation("unboundColumnsRight")
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\"><s:queryTableRefresh>" +
    "<s:queryTableDeletedFields count=\"abc\"/>" +
    "</s:queryTableRefresh></s:queryTable>",
  )
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\"><s:queryTableRefresh>" +
    "<s:queryTableFields count=\"abc\"/>" +
    "</s:queryTableRefresh></s:queryTable>",
  )
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\"><s:queryTableRefresh>" +
    "<s:queryTableFields><s:queryTableField id=\"abc\"/>" +
    "</s:queryTableFields></s:queryTableRefresh></s:queryTable>",
  )
  assert_query_table_schema_violation(
    "<s:queryTable xmlns:s=\"urn:s\"><s:queryTableRefresh>" +
    "<s:queryTableFields><s:queryTableField tableColumnId=\"abc\"/>" +
    "</s:queryTableFields></s:queryTableRefresh></s:queryTable>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed definition booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\" saveData=\"maybe\"/>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\" supportAdvancedDrill=\"maybe\"/>",
  )
}

///|
fn assert_pivot_cache_definition_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\" " + local_name + "=\"abc\"/>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed definition unsigned integers" {
  assert_pivot_cache_definition_numeric_schema_violation("missingItemsLimit")
  assert_pivot_cache_definition_numeric_schema_violation("createdVersion")
  assert_pivot_cache_definition_numeric_schema_violation("refreshedVersion")
  assert_pivot_cache_definition_numeric_schema_violation(
    "minRefreshableVersion",
  )
  assert_pivot_cache_definition_numeric_schema_violation("recordCount")
}

///|
test "SML pivotCacheDefinition reader rejects malformed cache-source booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource type=\"consolidation\">" +
    "<s:consolidation autoPage=\"maybe\"><s:rangeSets/></s:consolidation>" +
    "</s:cacheSource>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed cache-source unsigned integers" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource connectionId=\"abc\"/>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed consolidation numerics" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource type=\"consolidation\"><s:consolidation>" +
    "<s:pages count=\"abc\"/><s:rangeSets/>" +
    "</s:consolidation></s:cacheSource>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource type=\"consolidation\"><s:consolidation>" +
    "<s:pages><s:page count=\"abc\"/></s:pages><s:rangeSets/>" +
    "</s:consolidation></s:cacheSource>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource type=\"consolidation\"><s:consolidation>" +
    "<s:rangeSets count=\"abc\"/>" +
    "</s:consolidation></s:cacheSource>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource type=\"consolidation\"><s:consolidation>" +
    "<s:rangeSets><s:rangeSet i1=\"abc\"/></s:rangeSets>" +
    "</s:consolidation></s:cacheSource>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource type=\"consolidation\"><s:consolidation>" +
    "<s:rangeSets><s:rangeSet i2=\"abc\"/></s:rangeSets>" +
    "</s:consolidation></s:cacheSource>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource type=\"consolidation\"><s:consolidation>" +
    "<s:rangeSets><s:rangeSet i3=\"abc\"/></s:rangeSets>" +
    "</s:consolidation></s:cacheSource>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheSource type=\"consolidation\"><s:consolidation>" +
    "<s:rangeSets><s:rangeSet i4=\"abc\"/></s:rangeSets>" +
    "</s:consolidation></s:cacheSource>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed KPI numerics" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:kpis count=\"abc\"/>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed cache-field booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField serverField=\"maybe\"/></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField memberPropertyField=\"maybe\"/></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed cache-field numerics" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields count=\"abc\"/></s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField sqlType=\"abc\"/></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField hierarchy=\"abc\"/></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField level=\"abc\"/></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField mappingCount=\"abc\"/></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField><s:mpMap v=\"abc\"/></s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed cache-hierarchy booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy measure=\"maybe\"/></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy unbalancedGroup=\"maybe\"/></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed cache-hierarchy numerics" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies count=\"abc\"/>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy parentSet=\"abc\"/>" +
    "</s:cacheHierarchies></s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy iconSet=\"abc\"/>" +
    "</s:cacheHierarchies></s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy count=\"abc\"/>" +
    "</s:cacheHierarchies></s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy memberValueDatatype=\"abc\"/>" +
    "</s:cacheHierarchies></s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy><s:fieldsUsage count=\"abc\"/>" +
    "</s:cacheHierarchy></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy><s:fieldsUsage>" +
    "<s:fieldUsage x=\"abc\"/>" +
    "</s:fieldsUsage></s:cacheHierarchy></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy><s:groupLevels count=\"abc\"/>" +
    "</s:cacheHierarchy></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy><s:groupLevels>" +
    "<s:groupLevel><s:groups count=\"abc\"/></s:groupLevel>" +
    "</s:groupLevels></s:cacheHierarchy></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy><s:groupLevels>" +
    "<s:groupLevel><s:groups><s:group id=\"abc\"/></s:groups></s:groupLevel>" +
    "</s:groupLevels></s:cacheHierarchy></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy><s:groupLevels>" +
    "<s:groupLevel><s:groups><s:group>" +
    "<s:groupMembers count=\"abc\"/>" +
    "</s:group></s:groups></s:groupLevel>" +
    "</s:groupLevels></s:cacheHierarchy></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed group-level booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField>" +
    "<s:fieldGroup><s:rangePr autoStart=\"maybe\"/></s:fieldGroup>" +
    "</s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField>" +
    "<s:fieldGroup><s:rangePr autoEnd=\"maybe\"/></s:fieldGroup>" +
    "</s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy><s:groupLevels>" +
    "<s:groupLevel user=\"maybe\"/>" +
    "</s:groupLevels></s:cacheHierarchy></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheHierarchies><s:cacheHierarchy><s:groupLevels>" +
    "<s:groupLevel><s:groups><s:group>" +
    "<s:groupMembers><s:groupMember group=\"maybe\"/></s:groupMembers>" +
    "</s:group></s:groups></s:groupLevel>" +
    "</s:groupLevels></s:cacheHierarchy></s:cacheHierarchies>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed field-group numerics" {
  assert_pivot_cache_field_group_schema_violation("<s:fieldGroup par=\"abc\"/>")
  assert_pivot_cache_field_group_schema_violation(
    "<s:fieldGroup base=\"abc\"/>",
  )
  assert_pivot_cache_field_group_schema_violation(
    "<s:fieldGroup><s:rangePr startNum=\"abc\"/></s:fieldGroup>",
  )
  assert_pivot_cache_field_group_schema_violation(
    "<s:fieldGroup><s:rangePr endNum=\"abc\"/></s:fieldGroup>",
  )
  assert_pivot_cache_field_group_schema_violation(
    "<s:fieldGroup><s:rangePr groupInterval=\"abc\"/></s:fieldGroup>",
  )
  assert_pivot_cache_field_group_schema_violation(
    "<s:fieldGroup><s:discretePr count=\"abc\"/></s:fieldGroup>",
  )
  assert_pivot_cache_field_group_schema_violation(
    "<s:fieldGroup><s:discretePr><s:x v=\"abc\"/></s:discretePr></s:fieldGroup>",
  )
  assert_pivot_cache_field_group_schema_violation(
    "<s:fieldGroup><s:groupItems count=\"abc\"/></s:fieldGroup>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed shared-item booleans" {
  assert_pivot_cache_shared_items_schema_violation(
    "containsSemiMixedTypes=\"maybe\"",
  )
  assert_pivot_cache_shared_items_schema_violation("containsNonDate=\"maybe\"")
  assert_pivot_cache_shared_items_schema_violation("containsDate=\"maybe\"")
  assert_pivot_cache_shared_items_schema_violation("containsString=\"maybe\"")
  assert_pivot_cache_shared_items_schema_violation("containsBlank=\"maybe\"")
  assert_pivot_cache_shared_items_schema_violation(
    "containsMixedTypes=\"maybe\"",
  )
  assert_pivot_cache_shared_items_schema_violation("containsNumber=\"maybe\"")
  assert_pivot_cache_shared_items_schema_violation("containsInteger=\"maybe\"")
  assert_pivot_cache_shared_items_schema_violation("longText=\"maybe\"")
  assert_pivot_cache_shared_item_schema_violation("<s:m u=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:m f=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:m i=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:m un=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:m st=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:m b=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"1\" u=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"1\" f=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"1\" i=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"1\" un=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"1\" st=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"1\" b=\"maybe\"/>")
  assert_pivot_cache_shared_item_schema_violation(
    "<s:e v=\"#N/A\" u=\"maybe\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:e v=\"#N/A\" f=\"maybe\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:e v=\"#N/A\" i=\"maybe\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:e v=\"#N/A\" un=\"maybe\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:e v=\"#N/A\" st=\"maybe\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:e v=\"#N/A\" b=\"maybe\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:d v=\"2020-01-01T00:00:00\" u=\"maybe\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:d v=\"2020-01-01T00:00:00\" f=\"maybe\"/>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField>" +
    "<s:sharedItems><s:b v=\"1\" u=\"maybe\"/></s:sharedItems>" +
    "</s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField>" +
    "<s:fieldGroup><s:groupItems><s:b v=\"maybe\"/></s:groupItems></s:fieldGroup>" +
    "</s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:cacheFields><s:cacheField>" +
    "<s:sharedItems><s:s v=\"East\" i=\"maybe\"/></s:sharedItems>" +
    "</s:cacheField></s:cacheFields>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:entries><s:s v=\"East\" b=\"maybe\"/></s:entries></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed shared-item numerics" {
  assert_pivot_cache_shared_items_schema_violation("minValue=\"abc\"")
  assert_pivot_cache_shared_items_schema_violation("maxValue=\"abc\"")
  assert_pivot_cache_shared_items_schema_violation("count=\"abc\"")
  assert_pivot_cache_shared_item_schema_violation("<s:m cp=\"abc\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:m in=\"abc\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"abc\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"1\" cp=\"abc\"/>")
  assert_pivot_cache_shared_item_schema_violation("<s:n v=\"1\" in=\"abc\"/>")
  assert_pivot_cache_shared_item_schema_violation(
    "<s:e v=\"#N/A\" cp=\"abc\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:e v=\"#N/A\" in=\"abc\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:d v=\"2020-01-01T00:00:00\" cp=\"abc\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation("<s:m><s:x v=\"abc\"/></s:m>")
}

///|
test "SML pivotCacheDefinition reader rejects malformed shared string numerics" {
  assert_pivot_cache_shared_item_schema_violation(
    "<s:s v=\"East\" cp=\"abc\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:s v=\"East\" in=\"abc\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:s v=\"East\" bc=\"nothex\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:s v=\"East\" fc=\"nothex\"/>",
  )
  assert_pivot_cache_shared_item_schema_violation(
    "<s:s v=\"East\"><s:x v=\"abc\"/></s:s>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed tuple-set booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set queryFailed=\"maybe\"/></s:sets></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed tuple-set numerics" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:entries count=\"abc\"/></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets count=\"abc\"/></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set count=\"abc\"/></s:sets></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set maxRank=\"abc\"/></s:sets></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set><s:tpls c=\"abc\"/></s:set></s:sets></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set><s:sortByTuple c=\"abc\"/></s:set></s:sets></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set><s:tpls><s:tpl fld=\"abc\"/></s:tpls></s:set></s:sets></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set><s:tpls><s:tpl hier=\"abc\"/></s:tpls></s:set></s:sets></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set><s:tpls><s:tpl item=\"abc\"/></s:tpls></s:set></s:sets></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:queryCache count=\"abc\"/></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:queryCache><s:query><s:tpls c=\"abc\"/></s:query></s:queryCache></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:serverFormats count=\"abc\"/></s:tupleCache>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed calculated-member booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:calculatedMembers><s:calculatedMember set=\"maybe\"/></s:calculatedMembers>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed calculated numerics" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:calculatedItems count=\"abc\"/>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:calculatedItems><s:calculatedItem field=\"abc\"/></s:calculatedItems>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:calculatedMembers count=\"abc\"/>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:calculatedMembers><s:calculatedMember solveOrder=\"abc\"/></s:calculatedMembers>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed pivot-dimension booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:dimensions><s:dimension measure=\"maybe\"/></s:dimensions>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotCacheDefinition reader rejects malformed measure-map numerics" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:dimensions count=\"abc\"/>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:measureGroups count=\"abc\"/>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:maps count=\"abc\"/>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:maps><s:map measureGroup=\"abc\"/></s:maps>" +
    "</s:pivotCacheDefinition>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:maps><s:map dimension=\"abc\"/></s:maps>" +
    "</s:pivotCacheDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed definition booleans" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\" dataOnRows=\"maybe\"/>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\" fieldListSortAscending=\"maybe\"/>",
  )
}

///|
fn assert_pivot_table_definition_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\" " + local_name + "=\"abc\"/>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed definition numerics" {
  assert_pivot_table_definition_numeric_schema_violation("cacheId")
  assert_pivot_table_definition_numeric_schema_violation("dataPosition")
  assert_pivot_table_definition_numeric_schema_violation("updatedVersion")
  assert_pivot_table_definition_numeric_schema_violation(
    "minRefreshableVersion",
  )
  assert_pivot_table_definition_numeric_schema_violation("pageWrap")
  assert_pivot_table_definition_numeric_schema_violation("createdVersion")
  assert_pivot_table_definition_numeric_schema_violation("indent")
  assert_pivot_table_definition_numeric_schema_violation("chartFormat")
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:location firstHeaderRow=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:location firstDataRow=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:location firstDataCol=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:location rowPageCount=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:location colPageCount=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed pivot-field booleans" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotFields><s:pivotField dataField=\"maybe\"/></s:pivotFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotFields><s:pivotField dataSourceSort=\"maybe\"/></s:pivotFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_item_schema_violation("h=\"maybe\"")
  assert_pivot_table_item_schema_violation("s=\"maybe\"")
  assert_pivot_table_item_schema_violation("sd=\"maybe\"")
  assert_pivot_table_item_schema_violation("f=\"maybe\"")
  assert_pivot_table_item_schema_violation("m=\"maybe\"")
  assert_pivot_table_item_schema_violation("c=\"maybe\"")
  assert_pivot_table_item_schema_violation("d=\"maybe\"")
  assert_pivot_table_item_schema_violation("e=\"maybe\"")
}

///|
test "SML pivotTableDefinition reader rejects malformed pivot-field numerics" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotFields count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotFields><s:pivotField itemPageCount=\"abc\"/></s:pivotFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotFields><s:pivotField rankBy=\"abc\"/></s:pivotFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotFields><s:pivotField><s:items count=\"abc\"/></s:pivotField></s:pivotFields>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed field item numerics" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:rowFields count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:colFields count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:rowItems count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:rowItems><s:i r=\"abc\"/></s:rowItems>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:rowItems><s:i i=\"abc\"/></s:rowItems>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:rowItems><s:i><s:x v=\"abc\"/></s:i></s:rowItems>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:colItems count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:rowFields><s:field x=\"abc\"/></s:rowFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:pageFields count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pageFields><s:pageField fld=\"abc\"/></s:pageFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pageFields><s:pageField item=\"abc\"/></s:pageFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pageFields><s:pageField hier=\"abc\"/></s:pageFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\"><s:dataFields count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:dataFields><s:dataField fld=\"abc\"/></s:dataFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:dataFields><s:dataField baseField=\"abc\"/></s:dataFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:dataFields><s:dataField baseItem=\"abc\"/></s:dataFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:dataFields><s:dataField numFmtId=\"abc\"/></s:dataFields>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotFields><s:pivotField><s:items><s:item x=\"abc\"/></s:items></s:pivotField></s:pivotFields>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed pivot-hierarchy booleans" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy outline=\"maybe\"/></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy includeNewItemsInFilter=\"maybe\"/></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed pivot-hierarchy numerics" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:mps count=\"abc\"/></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:mps><s:mp nameLen=\"abc\"/></s:mps></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:mps><s:mp pPos=\"abc\"/></s:mps></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:mps><s:mp pLen=\"abc\"/></s:mps></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:mps><s:mp level=\"abc\"/></s:mps></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:mps><s:mp field=\"abc\"/></s:mps></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:members count=\"abc\"/></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:members level=\"abc\"/></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed hierarchy-usage numerics" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:rowHierarchiesUsage count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:rowHierarchiesUsage><s:rowHierarchyUsage hierarchyUsage=\"abc\"/></s:rowHierarchiesUsage>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:colHierarchiesUsage count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:colHierarchiesUsage><s:colHierarchyUsage hierarchyUsage=\"abc\"/></s:colHierarchiesUsage>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed style booleans" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotTableStyleInfo showRowHeaders=\"maybe\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotTableStyleInfo showLastColumn=\"maybe\"/>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed filter numerics" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:filters count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:filters><s:filter fld=\"abc\"/></s:filters>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:filters><s:filter mpFld=\"abc\"/></s:filters>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:filters><s:filter evalOrder=\"abc\"/></s:filters>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:filters><s:filter id=\"abc\"/></s:filters>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:filters><s:filter iMeasureHier=\"abc\"/></s:filters>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:filters><s:filter iMeasureFld=\"abc\"/></s:filters>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed pivot-area booleans" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format><s:pivotArea dataOnly=\"maybe\"/></s:format></s:formats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format><s:pivotArea>" +
    "<s:references><s:reference selected=\"maybe\"/></s:references>" +
    "</s:pivotArea></s:format></s:formats>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed pivot-area numerics" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:conditionalFormats count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:conditionalFormats><s:conditionalFormat priority=\"abc\"/></s:conditionalFormats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:conditionalFormats><s:conditionalFormat>" +
    "<s:pivotAreas count=\"abc\"/>" +
    "</s:conditionalFormat></s:conditionalFormats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format dxfId=\"abc\"/></s:formats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format><s:pivotArea field=\"abc\"/></s:format></s:formats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format><s:pivotArea fieldPosition=\"abc\"/></s:format></s:formats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format><s:pivotArea>" +
    "<s:references count=\"abc\"/>" +
    "</s:pivotArea></s:format></s:formats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format><s:pivotArea>" +
    "<s:references><s:reference field=\"abc\"/></s:references>" +
    "</s:pivotArea></s:format></s:formats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format><s:pivotArea>" +
    "<s:references><s:reference count=\"abc\"/></s:references>" +
    "</s:pivotArea></s:format></s:formats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:formats><s:format><s:pivotArea>" +
    "<s:references><s:reference><s:x v=\"abc\"/></s:reference></s:references>" +
    "</s:pivotArea></s:format></s:formats>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed chart-format booleans" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:chartFormats><s:chartFormat chart=\"0\" format=\"0\" series=\"maybe\"/>" +
    "</s:chartFormats>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed chart-format numerics" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:chartFormats count=\"abc\"/>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:chartFormats><s:chartFormat chart=\"abc\" format=\"0\"/>" +
    "</s:chartFormats>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:chartFormats><s:chartFormat chart=\"0\" format=\"abc\"/>" +
    "</s:chartFormats>" +
    "</s:pivotTableDefinition>",
  )
}

///|
test "SML pivotTableDefinition reader rejects malformed member-property booleans" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:mps><s:mp field=\"0\" showCell=\"maybe\"/></s:mps></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:pivotHierarchies><s:pivotHierarchy><s:mps><s:mp field=\"0\" showAsCaption=\"maybe\"/></s:mps></s:pivotHierarchy></s:pivotHierarchies>" +
    "</s:pivotTableDefinition>",
  )
}

///|
fn assert_pivot_cache_records_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_pivot_cache_records(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML pivotCacheRecords reader rejects malformed top-level numerics" {
  assert_pivot_cache_records_schema_violation(
    "<s:pivotCacheRecords xmlns:s=\"urn:s\" count=\"abc\"/>",
  )
}

///|
test "SML pivotCacheRecords reader rejects malformed record booleans" {
  let invalid = try? read_pivot_cache_records(
    bytes(
      "<s:pivotCacheRecords xmlns:s=\"urn:s\">" +
      "<s:r><s:b v=\"1\" f=\"maybe\"/></s:r>" +
      "</s:pivotCacheRecords>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
  let invalid_string = try? read_pivot_cache_records(
    bytes(
      "<s:pivotCacheRecords xmlns:s=\"urn:s\">" +
      "<s:r><s:s v=\"East\" f=\"maybe\"/></s:r>" +
      "</s:pivotCacheRecords>",
    ),
  )
  assert_true(invalid_string is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_table_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_table(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML table reader rejects malformed table booleans" {
  assert_table_schema_violation(
    "<s:table xmlns:s=\"urn:s\" totalsRowShown=\"maybe\"/>",
  )
}

///|
fn assert_table_attr_schema_violation(local_name : String) -> Unit raise {
  assert_table_schema_violation(
    "<s:table xmlns:s=\"urn:s\" " + local_name + "=\"abc\"/>",
  )
}

///|
fn assert_table_column_attr_schema_violation(local_name : String) -> Unit raise {
  assert_table_schema_violation(
    "<s:table xmlns:s=\"urn:s\"><s:tableColumns><s:tableColumn " +
    local_name +
    "=\"abc\"/></s:tableColumns></s:table>",
  )
}

///|
test "SML table reader rejects malformed table unsigned integers" {
  assert_table_attr_schema_violation("id")
  assert_table_attr_schema_violation("headerRowCount")
  assert_table_attr_schema_violation("totalsRowCount")
  assert_table_attr_schema_violation("connectionId")
  assert_table_attr_schema_violation("headerRowDxfId")
  assert_table_attr_schema_violation("dataDxfId")
  assert_table_attr_schema_violation("totalsRowDxfId")
  assert_table_attr_schema_violation("headerRowBorderDxfId")
  assert_table_attr_schema_violation("tableBorderDxfId")
  assert_table_attr_schema_violation("totalsRowBorderDxfId")
  assert_table_schema_violation(
    "<s:table xmlns:s=\"urn:s\"><s:tableColumns count=\"abc\"/></s:table>",
  )
  assert_table_column_attr_schema_violation("id")
  assert_table_column_attr_schema_violation("queryTableFieldId")
  assert_table_column_attr_schema_violation("headerRowDxfId")
  assert_table_column_attr_schema_violation("dataDxfId")
  assert_table_column_attr_schema_violation("totalsRowDxfId")
}

///|
test "SML table reader rejects malformed table formula booleans" {
  assert_table_schema_violation(
    "<s:table xmlns:s=\"urn:s\">" +
    "<s:tableColumns><s:tableColumn>" +
    "<s:calculatedColumnFormula array=\"maybe\"/>" +
    "</s:tableColumn></s:tableColumns>" +
    "</s:table>",
  )
}

///|
test "SML table reader rejects malformed table style booleans" {
  assert_table_schema_violation(
    "<s:table xmlns:s=\"urn:s\">" +
    "<s:tableStyleInfo showRowStripes=\"maybe\"/>" +
    "</s:table>",
  )
}

///|
test "SML table reader rejects malformed XML column booleans" {
  assert_table_schema_violation(
    "<s:table xmlns:s=\"urn:s\">" +
    "<s:tableColumns><s:tableColumn>" +
    "<s:xmlColumnPr denormalized=\"maybe\"/>" +
    "</s:tableColumn></s:tableColumns>" +
    "</s:table>",
  )
}

///|
test "SML table reader rejects malformed XML column unsigned integers" {
  assert_table_schema_violation(
    "<s:table xmlns:s=\"urn:s\">" +
    "<s:tableColumns><s:tableColumn>" +
    "<s:xmlColumnPr mapId=\"abc\"/>" +
    "</s:tableColumn></s:tableColumns>" +
    "</s:table>",
  )
}

///|
test "SML externalLink reader rejects malformed sheet data booleans" {
  assert_external_link_schema_violation(
    "<s:externalLink xmlns:s=\"urn:s\">" +
    "<s:externalBook>" +
    "<s:sheetDataSet><s:sheetData refreshError=\"maybe\"/></s:sheetDataSet>" +
    "</s:externalBook>" +
    "</s:externalLink>",
  )
}

///|
test "SML externalLink reader rejects malformed DDE booleans" {
  assert_external_link_schema_violation(
    "<s:externalLink xmlns:s=\"urn:s\">" +
    "<s:ddeLink><s:ddeItems><s:ddeItem advise=\"maybe\"/></s:ddeItems></s:ddeLink>" +
    "</s:externalLink>",
  )
}

///|
test "SML externalLink reader rejects malformed OLE booleans" {
  assert_external_link_schema_violation(
    "<s:externalLink xmlns:s=\"urn:s\">" +
    "<s:oleLink><s:oleItems><s:oleItem name=\"Item\" icon=\"maybe\"/></s:oleItems></s:oleLink>" +
    "</s:externalLink>",
  )
}

///|
test "SML externalLink reader rejects malformed unsigned integers" {
  assert_external_link_schema_violation(
    "<s:externalLink xmlns:s=\"urn:s\">" +
    "<s:externalBook><s:definedNames>" +
    "<s:definedName name=\"n\" sheetId=\"abc\"/>" +
    "</s:definedNames></s:externalBook>" +
    "</s:externalLink>",
  )
  assert_external_link_schema_violation(
    "<s:externalLink xmlns:s=\"urn:s\">" +
    "<s:ddeLink><s:ddeItems><s:ddeItem><s:values rows=\"abc\"/></s:ddeItem></s:ddeItems></s:ddeLink>" +
    "</s:externalLink>",
  )
}

///|
test "SML worksheet reader rejects malformed OLE object booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:oleObjects><s:oleObject autoLoad=\"maybe\"/></s:oleObjects>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed OLE object unsigned integers" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:oleObjects><s:oleObject shapeId=\"abc\"/></s:oleObjects>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML volTypes reader rejects malformed unsigned integers" {
  let invalid = try? read_vol_types(
    bytes(
      "<s:volTypes xmlns:s=\"urn:s\">" +
      "<s:volType><s:main><s:tp><s:v>x</s:v><s:tr r=\"A1\" s=\"abc\"/></s:tp></s:main></s:volType>" +
      "</s:volTypes>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed object property booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:oleObjects><s:oleObject shapeId=\"1\">" +
      "<s:objectPr defaultSize=\"maybe\"/>" +
      "</s:oleObject></s:oleObjects>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed pivot-selection booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetViews><s:sheetView><s:pivotSelection showHeader=\"maybe\"/></s:sheetView></s:sheetViews>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_pivot_selection_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView><s:pivotSelection " +
    local_name +
    "=\"abc\"/></s:sheetView></s:sheetViews>",
  )
}

///|
test "SML worksheet reader rejects malformed pivot-selection numerics" {
  assert_pivot_selection_numeric_schema_violation("count")
  assert_pivot_selection_numeric_schema_violation("dimension")
  assert_pivot_selection_numeric_schema_violation("start")
  assert_pivot_selection_numeric_schema_violation("min")
  assert_pivot_selection_numeric_schema_violation("max")
  assert_pivot_selection_numeric_schema_violation("activeRow")
  assert_pivot_selection_numeric_schema_violation("activeCol")
  assert_pivot_selection_numeric_schema_violation("previousRow")
  assert_pivot_selection_numeric_schema_violation("previousCol")
  assert_pivot_selection_numeric_schema_violation("click")
}

///|
test "SML worksheet reader rejects malformed page-setup-pr booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetPr><s:pageSetUpPr autoPageBreaks=\"maybe\"/></s:sheetPr>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_outline_pr_schema_violation(outline_pr_attr : String) -> Unit raise {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetPr><s:outlinePr " +
      outline_pr_attr +
      "/></s:sheetPr>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed outline properties booleans" {
  assert_outline_pr_schema_violation("applyStyles=\"maybe\"")
  assert_outline_pr_schema_violation("summaryBelow=\"maybe\"")
  assert_outline_pr_schema_violation("summaryRight=\"maybe\"")
  assert_outline_pr_schema_violation("showOutlineSymbols=\"maybe\"")
}

///|
test "SML worksheet reader rejects malformed page-setup booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:pageSetup usePrinterDefaults=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_page_setup_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  assert_worksheet_body_schema_violation(
    "<s:pageSetup " + local_name + "=\"abc\"/>",
  )
}

///|
test "SML worksheet reader rejects malformed page-setup numerics" {
  assert_page_setup_numeric_schema_violation("paperSize")
  assert_page_setup_numeric_schema_violation("scale")
  assert_page_setup_numeric_schema_violation("firstPageNumber")
  assert_page_setup_numeric_schema_violation("fitToWidth")
  assert_page_setup_numeric_schema_violation("fitToHeight")
  assert_page_setup_numeric_schema_violation("horizontalDpi")
  assert_page_setup_numeric_schema_violation("verticalDpi")
  assert_page_setup_numeric_schema_violation("copies")
}

///|
test "SML worksheet reader rejects malformed custom-sheet-view page-setup booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:customSheetViews><s:customSheetView>" +
      "<s:pageSetup blackAndWhite=\"maybe\"/>" +
      "</s:customSheetView></s:customSheetViews>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed custom-sheet-view page-setup numerics" {
  assert_worksheet_body_schema_violation(
    "<s:customSheetViews><s:customSheetView><s:pageSetup copies=\"abc\"/>" +
    "</s:customSheetView></s:customSheetViews>",
  )
}

///|
test "SML chartsheet reader rejects malformed page-setup booleans" {
  let invalid = try? read_chartsheet(
    bytes(
      "<s:chartsheet xmlns:s=\"urn:s\">" +
      "<s:pageSetup draft=\"maybe\"/>" +
      "</s:chartsheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_chartsheet_page_setup_numeric_schema_violation(
  local_name : String,
) -> Unit raise {
  let invalid = try? read_chartsheet(
    bytes(
      "<s:chartsheet xmlns:s=\"urn:s\"><s:pageSetup " +
      local_name +
      "=\"abc\"/></s:chartsheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML chartsheet reader rejects malformed page-setup numerics" {
  assert_chartsheet_page_setup_numeric_schema_violation("paperSize")
  assert_chartsheet_page_setup_numeric_schema_violation("firstPageNumber")
  assert_chartsheet_page_setup_numeric_schema_violation("horizontalDpi")
  assert_chartsheet_page_setup_numeric_schema_violation("verticalDpi")
  assert_chartsheet_page_setup_numeric_schema_violation("copies")
}

///|
test "SML worksheet reader rejects malformed print-options booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:printOptions gridLinesSet=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed header-footer booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:headerFooter scaleWithDoc=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML chartsheet reader rejects malformed header-footer booleans" {
  let invalid = try? read_chartsheet(
    bytes(
      "<s:chartsheet xmlns:s=\"urn:s\">" +
      "<s:headerFooter alignWithMargins=\"maybe\"/>" +
      "</s:chartsheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_chartsheet_schema_violation(source : String) -> Unit raise {
  let invalid = try? read_chartsheet(bytes(source))
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML chartsheet reader rejects malformed chartsheet booleans" {
  let invalid_pr = try? read_chartsheet(
    bytes(
      "<s:chartsheet xmlns:s=\"urn:s\">" +
      "<s:sheetPr published=\"maybe\"/>" +
      "</s:chartsheet>",
    ),
  )
  assert_true(invalid_pr is Err(@opc_errors.SchemaViolation(_)))
  let invalid_view_tab = try? read_chartsheet(
    bytes(
      "<s:chartsheet xmlns:s=\"urn:s\">" +
      "<s:sheetViews><s:sheetView tabSelected=\"maybe\"/></s:sheetViews>" +
      "</s:chartsheet>",
    ),
  )
  assert_true(invalid_view_tab is Err(@opc_errors.SchemaViolation(_)))
  let invalid_view_zoom = try? read_chartsheet(
    bytes(
      "<s:chartsheet xmlns:s=\"urn:s\">" +
      "<s:sheetViews><s:sheetView zoomToFit=\"maybe\"/></s:sheetViews>" +
      "</s:chartsheet>",
    ),
  )
  assert_true(invalid_view_zoom is Err(@opc_errors.SchemaViolation(_)))
  let invalid_custom_view = try? read_chartsheet(
    bytes(
      "<s:chartsheet xmlns:s=\"urn:s\">" +
      "<s:customSheetViews><s:customSheetView zoomToFit=\"maybe\"/>" +
      "</s:customSheetViews>" +
      "</s:chartsheet>",
    ),
  )
  assert_true(invalid_custom_view is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML chartsheet reader rejects malformed chartsheet unsigned integers" {
  assert_chartsheet_schema_violation(
    "<s:chartsheet xmlns:s=\"urn:s\">" +
    "<s:sheetViews><s:sheetView zoomScale=\"abc\"/></s:sheetViews>" +
    "</s:chartsheet>",
  )
  assert_chartsheet_schema_violation(
    "<s:chartsheet xmlns:s=\"urn:s\">" +
    "<s:sheetViews><s:sheetView workbookViewId=\"abc\"/></s:sheetViews>" +
    "</s:chartsheet>",
  )
  assert_chartsheet_schema_violation(
    "<s:chartsheet xmlns:s=\"urn:s\">" +
    "<s:customSheetViews><s:customSheetView scale=\"abc\"/>" +
    "</s:customSheetViews></s:chartsheet>",
  )
}

///|
test "SML worksheet reader rejects malformed data-validations booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:dataValidations disablePrompts=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed data-validation booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:dataValidations><s:dataValidation allowBlank=\"maybe\"/></s:dataValidations>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed sort-state booleans" {
  let invalid_state = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sortState ref=\"A1\" columnSort=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid_state is Err(@opc_errors.SchemaViolation(_)))
  let invalid_condition = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sortState ref=\"A1\">" +
      "<s:sortCondition ref=\"A1\" descending=\"maybe\"/>" +
      "</s:sortState>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid_condition is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed sort-condition unsigned integers" {
  assert_worksheet_body_schema_violation(
    "<s:sortState ref=\"A1\">" +
    "<s:sortCondition ref=\"A1\" dxfId=\"abc\"/>" +
    "</s:sortState>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sortState ref=\"A1\">" +
    "<s:sortCondition ref=\"A1\" iconId=\"abc\"/>" +
    "</s:sortState>",
  )
}

///|
test "SML worksheet reader rejects malformed sheet properties booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetPr syncHorizontal=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_worksheet_body_schema_violation(body : String) -> Unit raise {
  let invalid = try? read_worksheet(
    bytes("<s:worksheet xmlns:s=\"urn:s\">" + body + "</s:worksheet>"),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
fn assert_worksheet_cell_schema_violation(cell_markup : String) -> Unit raise {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetData><s:row>" +
      cell_markup +
      "</s:row></s:sheetData>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed cell booleans" {
  assert_worksheet_cell_schema_violation("<s:c ph=\"maybe\"/>")
}

///|
test "SML worksheet reader rejects malformed cell unsigned integers" {
  assert_worksheet_cell_schema_violation("<s:c s=\"abc\"/>")
  assert_worksheet_cell_schema_violation("<s:c cm=\"abc\"/>")
  assert_worksheet_cell_schema_violation("<s:c vm=\"abc\"/>")
}

///|
fn assert_cell_formula_bool_schema_violation(local_name : String) -> Unit raise {
  assert_worksheet_cell_schema_violation(
    "<s:c r=\"A1\"><s:f " + local_name + "=\"maybe\">A1</s:f></s:c>",
  )
}

///|
test "SML worksheet reader rejects malformed cell formula booleans" {
  assert_cell_formula_bool_schema_violation("aca")
  assert_cell_formula_bool_schema_violation("dt2D")
  assert_cell_formula_bool_schema_violation("dtr")
  assert_cell_formula_bool_schema_violation("del1")
  assert_cell_formula_bool_schema_violation("del2")
  assert_cell_formula_bool_schema_violation("ca")
  assert_cell_formula_bool_schema_violation("bx")
}

///|
test "SML worksheet reader rejects malformed cell formula unsigned integers" {
  assert_worksheet_cell_schema_violation(
    "<s:c r=\"A1\"><s:f si=\"abc\">A1</s:f></s:c>",
  )
}

///|
fn assert_sheet_protection_schema_violation(
  protection_attr : String,
) -> Unit raise {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetProtection " +
      protection_attr +
      "/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed sheet protection booleans" {
  assert_sheet_protection_schema_violation("sheet=\"maybe\"")
  assert_sheet_protection_schema_violation("objects=\"maybe\"")
  assert_sheet_protection_schema_violation("scenarios=\"maybe\"")
  assert_sheet_protection_schema_violation("formatCells=\"maybe\"")
  assert_sheet_protection_schema_violation("formatColumns=\"maybe\"")
  assert_sheet_protection_schema_violation("formatRows=\"maybe\"")
  assert_sheet_protection_schema_violation("insertColumns=\"maybe\"")
  assert_sheet_protection_schema_violation("insertRows=\"maybe\"")
  assert_sheet_protection_schema_violation("insertHyperlinks=\"maybe\"")
  assert_sheet_protection_schema_violation("deleteColumns=\"maybe\"")
  assert_sheet_protection_schema_violation("deleteRows=\"maybe\"")
  assert_sheet_protection_schema_violation("selectLockedCells=\"maybe\"")
  assert_sheet_protection_schema_violation("sort=\"maybe\"")
  assert_sheet_protection_schema_violation("autoFilter=\"maybe\"")
  assert_sheet_protection_schema_violation("pivotTables=\"maybe\"")
  assert_sheet_protection_schema_violation("selectUnlockedCells=\"maybe\"")
}

///|
test "SML worksheet reader rejects malformed sheet protection unsigned integers" {
  assert_sheet_protection_schema_violation("spinCount=\"abc\"")
}

///|
fn assert_chartsheet_protection_schema_violation(
  protection_attr : String,
) -> Unit raise {
  let invalid = try? read_chartsheet(
    bytes(
      "<s:chartsheet xmlns:s=\"urn:s\">" +
      "<s:sheetProtection " +
      protection_attr +
      "/>" +
      "</s:chartsheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML chartsheet reader rejects malformed sheet protection booleans" {
  assert_chartsheet_protection_schema_violation("content=\"maybe\"")
  assert_chartsheet_protection_schema_violation("objects=\"maybe\"")
}

///|
test "SML chartsheet reader rejects malformed sheet protection unsigned integers" {
  assert_chartsheet_protection_schema_violation("spinCount=\"abc\"")
}

///|
test "SML worksheet reader rejects malformed sheet view booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetViews><s:sheetView workbookViewId=\"0\" showGridLines=\"maybe\"/></s:sheetViews>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed sheet view numerics" {
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView colorId=\"abc\"/></s:sheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView zoomScale=\"abc\"/></s:sheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView zoomScaleNormal=\"abc\"/></s:sheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView zoomScaleSheetLayoutView=\"abc\"/></s:sheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView zoomScalePageLayoutView=\"abc\"/></s:sheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView workbookViewId=\"abc\"/></s:sheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView><s:pane xSplit=\"abc\"/></s:sheetView></s:sheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView><s:pane ySplit=\"abc\"/></s:sheetView></s:sheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetViews><s:sheetView><s:selection activeCellId=\"abc\"/></s:sheetView></s:sheetViews>",
  )
}

///|
test "SML worksheet reader rejects malformed custom sheet view booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:customSheetViews><s:customSheetView guid=\"{00000000-0000-0000-0000-000000000000}\" showPageBreaks=\"maybe\"/></s:customSheetViews>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed custom sheet view numerics" {
  assert_worksheet_body_schema_violation(
    "<s:customSheetViews><s:customSheetView scale=\"abc\"/></s:customSheetViews>",
  )
  assert_worksheet_body_schema_violation(
    "<s:customSheetViews><s:customSheetView colorId=\"abc\"/></s:customSheetViews>",
  )
}

///|
test "SML worksheet reader rejects malformed sheet calculation booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetCalcPr fullCalcOnLoad=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed sheet format booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetFormatPr defaultRowHeight=\"15\" customHeight=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed sheet format numerics" {
  assert_worksheet_body_schema_violation(
    "<s:sheetFormatPr baseColWidth=\"abc\"/>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetFormatPr defaultColWidth=\"abc\"/>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetFormatPr defaultRowHeight=\"abc\"/>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetFormatPr outlineLevelRow=\"abc\"/>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetFormatPr outlineLevelCol=\"abc\"/>",
  )
}

///|
test "SML dialogsheet reader rejects malformed sheet format booleans" {
  let invalid = try? read_dialogsheet(
    bytes(
      "<s:dialogsheet xmlns:s=\"urn:s\">" +
      "<s:sheetFormatPr defaultRowHeight=\"15\" zeroHeight=\"maybe\"/>" +
      "</s:dialogsheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML dialogsheet reader rejects malformed sheet format numerics" {
  let invalid = try? read_dialogsheet(
    bytes(
      "<s:dialogsheet xmlns:s=\"urn:s\">" +
      "<s:sheetFormatPr defaultRowHeight=\"abc\"/>" +
      "</s:dialogsheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML calc chain reader rejects malformed calc cell booleans" {
  let invalid = try? read_calc_chain(
    bytes(
      "<s:calcChain xmlns:s=\"urn:s\">" +
      "<s:c r=\"A1\" s=\"maybe\"/>" +
      "</s:calcChain>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML calc chain reader rejects malformed calc cell numerics" {
  let invalid = try? read_calc_chain(
    bytes(
      "<s:calcChain xmlns:s=\"urn:s\">" +
      "<s:c r=\"A1\" i=\"abc\"/>" +
      "</s:calcChain>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML comments reader rejects malformed comment presentation booleans" {
  let invalid = try? read_comments(
    bytes(
      "<s:comments xmlns:s=\"urn:s\">" +
      "<s:authors><s:author>A</s:author></s:authors>" +
      "<s:commentList><s:comment ref=\"A1\" authorId=\"0\">" +
      "<s:text/><s:commentPr locked=\"maybe\"/>" +
      "</s:comment></s:commentList>" +
      "</s:comments>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML comments reader rejects malformed comment unsigned integers" {
  let invalid_author_id = try? read_comments(
    bytes(
      "<s:comments xmlns:s=\"urn:s\">" +
      "<s:authors><s:author>A</s:author></s:authors>" +
      "<s:commentList><s:comment ref=\"A1\" authorId=\"abc\">" +
      "<s:text/>" +
      "</s:comment></s:commentList>" +
      "</s:comments>",
    ),
  )
  assert_true(invalid_author_id is Err(@opc_errors.SchemaViolation(_)))
  let invalid_shape_id = try? read_comments(
    bytes(
      "<s:comments xmlns:s=\"urn:s\">" +
      "<s:authors><s:author>A</s:author></s:authors>" +
      "<s:commentList><s:comment ref=\"A1\" authorId=\"0\" shapeId=\"abc\">" +
      "<s:text/>" +
      "</s:comment></s:commentList>" +
      "</s:comments>",
    ),
  )
  assert_true(invalid_shape_id is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML comments reader rejects malformed comment anchor booleans" {
  let invalid = try? read_comments(
    bytes(
      "<s:comments xmlns:s=\"urn:s\">" +
      "<s:authors><s:author>A</s:author></s:authors>" +
      "<s:commentList><s:comment ref=\"A1\" authorId=\"0\">" +
      "<s:text/><s:commentPr><s:anchor moveWithCells=\"maybe\"/>" +
      "</s:commentPr></s:comment></s:commentList>" +
      "</s:comments>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed column booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:cols><s:col min=\"1\" max=\"1\" hidden=\"maybe\"/></s:cols>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed column numerics" {
  assert_worksheet_body_schema_violation(
    "<s:cols><s:col min=\"abc\" max=\"1\"/></s:cols>",
  )
  assert_worksheet_body_schema_violation(
    "<s:cols><s:col min=\"1\" max=\"abc\"/></s:cols>",
  )
  assert_worksheet_body_schema_violation(
    "<s:cols><s:col min=\"1\" max=\"1\" width=\"abc\"/></s:cols>",
  )
  assert_worksheet_body_schema_violation(
    "<s:cols><s:col min=\"1\" max=\"1\" style=\"abc\"/></s:cols>",
  )
  assert_worksheet_body_schema_violation(
    "<s:cols><s:col min=\"1\" max=\"1\" outlineLevel=\"abc\"/></s:cols>",
  )
}

///|
test "SML worksheet reader rejects malformed row booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:sheetData><s:row r=\"1\" hidden=\"maybe\"/></s:sheetData>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed row numerics" {
  assert_worksheet_body_schema_violation(
    "<s:sheetData><s:row r=\"abc\"/></s:sheetData>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetData><s:row s=\"abc\"/></s:sheetData>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetData><s:row ht=\"abc\"/></s:sheetData>",
  )
  assert_worksheet_body_schema_violation(
    "<s:sheetData><s:row outlineLevel=\"abc\"/></s:sheetData>",
  )
}

///|
test "SML worksheet reader rejects malformed page margin doubles" {
  assert_worksheet_body_schema_violation("<s:pageMargins left=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:pageMargins right=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:pageMargins top=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:pageMargins bottom=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:pageMargins header=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:pageMargins footer=\"abc\"/>")
}

///|
test "SML worksheet reader rejects malformed merge cell numerics" {
  assert_worksheet_body_schema_violation(
    "<s:mergeCells count=\"abc\"><s:mergeCell ref=\"A1:A1\"/></s:mergeCells>",
  )
}

///|
test "SML worksheet reader rejects malformed data consolidation booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:dataConsolidate startLabels=\"maybe\"/>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed data consolidation numerics" {
  assert_worksheet_body_schema_violation(
    "<s:dataConsolidate><s:dataRefs count=\"abc\"/></s:dataConsolidate>",
  )
}

///|
test "SML worksheet reader rejects malformed page break booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:rowBreaks><s:brk id=\"1\" man=\"maybe\"/></s:rowBreaks>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed page break numerics" {
  assert_worksheet_body_schema_violation(
    "<s:rowBreaks count=\"abc\"><s:brk id=\"1\"/></s:rowBreaks>",
  )
  assert_worksheet_body_schema_violation(
    "<s:rowBreaks manualBreakCount=\"abc\"><s:brk id=\"1\"/></s:rowBreaks>",
  )
  assert_worksheet_body_schema_violation(
    "<s:rowBreaks><s:brk id=\"abc\"/></s:rowBreaks>",
  )
  assert_worksheet_body_schema_violation(
    "<s:rowBreaks><s:brk id=\"1\" min=\"abc\"/></s:rowBreaks>",
  )
  assert_worksheet_body_schema_violation(
    "<s:rowBreaks><s:brk id=\"1\" max=\"abc\"/></s:rowBreaks>",
  )
}

///|
test "SML worksheet reader rejects malformed smart tag booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:smartTags><s:cellSmartTags r=\"A1\">" +
      "<s:cellSmartTag type=\"1\" deleted=\"maybe\"/>" +
      "</s:cellSmartTags></s:smartTags>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed smart tag unsigned integers" {
  assert_worksheet_body_schema_violation(
    "<s:smartTags><s:cellSmartTags r=\"A1\"><s:cellSmartTag type=\"abc\"/></s:cellSmartTags></s:smartTags>",
  )
}

///|
test "SML worksheet reader rejects malformed drawingHF unsigned integers" {
  assert_worksheet_body_schema_violation("<s:drawingHF lho=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF lhe=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF lhf=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF cho=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF che=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF chf=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF rho=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF rhe=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF rhf=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF lfo=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF lfe=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF lff=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF cfo=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF cfe=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF cff=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF rfo=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF rfe=\"abc\"/>")
  assert_worksheet_body_schema_violation("<s:drawingHF rff=\"abc\"/>")
}

///|
test "SML worksheet reader rejects malformed ignored error booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:ignoredErrors>" +
      "<s:ignoredError sqref=\"A1\" numberStoredAsText=\"maybe\"/>" +
      "</s:ignoredErrors>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed web publish item booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:webPublishItems>" +
      "<s:webPublishItem id=\"1\" divId=\"d1\" sourceType=\"sheet\" " +
      "destinationFile=\"out.htm\" autoRepublish=\"maybe\"/>" +
      "</s:webPublishItems>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed web publish item numerics" {
  assert_worksheet_body_schema_violation(
    "<s:webPublishItems count=\"abc\">" +
    "<s:webPublishItem id=\"1\" divId=\"d1\" sourceType=\"sheet\" " +
    "destinationFile=\"out.htm\"/>" +
    "</s:webPublishItems>",
  )
  assert_worksheet_body_schema_violation(
    "<s:webPublishItems>" +
    "<s:webPublishItem id=\"abc\" divId=\"d1\" sourceType=\"sheet\" " +
    "destinationFile=\"out.htm\"/>" +
    "</s:webPublishItems>",
  )
}

///|
test "SML worksheet reader rejects malformed scenario booleans" {
  let invalid_scenario = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:scenarios><s:scenario name=\"Case\" locked=\"maybe\"/>" +
      "</s:scenarios>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid_scenario is Err(@opc_errors.SchemaViolation(_)))
  let invalid_input_cell = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:scenarios><s:scenario name=\"Case\">" +
      "<s:inputCells r=\"A1\" val=\"1\" deleted=\"maybe\"/>" +
      "</s:scenario></s:scenarios>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid_input_cell is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed scenario unsigned integers" {
  assert_worksheet_body_schema_violation(
    "<s:scenarios current=\"abc\"><s:scenario name=\"Case\"/></s:scenarios>",
  )
  assert_worksheet_body_schema_violation(
    "<s:scenarios show=\"abc\"><s:scenario name=\"Case\"/></s:scenarios>",
  )
  assert_worksheet_body_schema_violation(
    "<s:scenarios><s:scenario name=\"Case\" count=\"abc\"/></s:scenarios>",
  )
  assert_worksheet_body_schema_violation(
    "<s:scenarios><s:scenario name=\"Case\"><s:inputCells r=\"A1\" val=\"1\" numFmtId=\"abc\"/></s:scenario></s:scenarios>",
  )
}

///|
test "SML worksheet reader rejects malformed protected range unsigned integers" {
  assert_worksheet_body_schema_violation(
    "<s:protectedRanges><s:protectedRange sqref=\"A1\" name=\"r\" spinCount=\"abc\"/></s:protectedRanges>",
  )
}

///|
test "SML worksheet reader rejects malformed data validation unsigned integers" {
  assert_worksheet_body_schema_violation(
    "<s:dataValidations xWindow=\"abc\"><s:dataValidation sqref=\"A1\"/></s:dataValidations>",
  )
  assert_worksheet_body_schema_violation(
    "<s:dataValidations yWindow=\"abc\"><s:dataValidation sqref=\"A1\"/></s:dataValidations>",
  )
  assert_worksheet_body_schema_violation(
    "<s:dataValidations count=\"abc\"><s:dataValidation sqref=\"A1\"/></s:dataValidations>",
  )
}

///|
test "SML worksheet reader rejects malformed control property booleans" {
  let invalid = try? read_worksheet(
    bytes(
      "<s:worksheet xmlns:s=\"urn:s\">" +
      "<s:controls><s:control shapeId=\"1\">" +
      "<s:controlPr disabled=\"maybe\"/>" +
      "</s:control></s:controls>" +
      "</s:worksheet>",
    ),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "SML worksheet reader rejects malformed control unsigned integers" {
  assert_worksheet_body_schema_violation(
    "<s:controls><s:control shapeId=\"abc\"/></s:controls>",
  )
}

///|
test "SML worksheet reader rejects malformed table parts unsigned integers" {
  assert_worksheet_body_schema_violation(
    "<s:tableParts count=\"abc\"><s:tablePart id=\"rId1\"/></s:tableParts>",
  )
}
