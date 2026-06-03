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
