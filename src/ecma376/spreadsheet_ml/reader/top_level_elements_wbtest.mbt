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
test "SML headers reader rejects malformed revision-header booleans" {
  let invalid = try? read_headers(
    bytes("<s:headers xmlns:s=\"urn:s\" shared=\"maybe\"/>"),
  )
  assert_true(invalid is Err(@opc_errors.SchemaViolation(_)))
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
test "SML pivotCacheDefinition reader rejects malformed definition booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\" saveData=\"maybe\"/>",
  )
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\" supportAdvancedDrill=\"maybe\"/>",
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
test "SML pivotCacheDefinition reader rejects malformed tuple-set booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:tupleCache><s:sets><s:set queryFailed=\"maybe\"/></s:sets></s:tupleCache>" +
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
test "SML pivotCacheDefinition reader rejects malformed pivot-dimension booleans" {
  assert_pivot_cache_definition_schema_violation(
    "<s:pivotCacheDefinition xmlns:s=\"urn:s\">" +
    "<s:dimensions><s:dimension measure=\"maybe\"/></s:dimensions>" +
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
test "SML pivotTableDefinition reader rejects malformed chart-format booleans" {
  assert_pivot_table_definition_schema_violation(
    "<s:pivotTableDefinition xmlns:s=\"urn:s\">" +
    "<s:chartFormats><s:chartFormat chart=\"0\" format=\"0\" series=\"maybe\"/>" +
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
