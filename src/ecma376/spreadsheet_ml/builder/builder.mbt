///|
/// SpreadsheetML domain/context → XML writer.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/builder"
}

///|
/// Write top-level XSD element calcChain from CT_CalcChain (§18).
pub fn write_calc_chain(value : @domain.CT_CalcChain) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element comments from CT_Comments (§18).
pub fn write_comments(value : @domain.CT_Comments) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element MapInfo from CT_MapInfo (§18).
pub fn write_map_info(value : @domain.CT_MapInfo) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element connections from CT_Connections (§18).
pub fn write_connections(value : @domain.CT_Connections) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element pivotCacheDefinition from CT_PivotCacheDefinition (§18).
pub fn write_pivot_cache_definition(
  value : @domain.CT_PivotCacheDefinition,
) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element pivotCacheRecords from CT_PivotCacheRecords (§18).
pub fn write_pivot_cache_records(value : @domain.CT_PivotCacheRecords) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element pivotTableDefinition from CT_pivotTableDefinition (§18).
pub fn write_pivot_table_definition(
  value : @domain.CT_pivotTableDefinition,
) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element queryTable from CT_QueryTable (§18).
pub fn write_query_table(value : @domain.CT_QueryTable) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element sst from CT_Sst (§18).
pub fn write_sst(value : @domain.CT_Sst) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level sharedStrings element from CT_Sst (§18 compatibility spelling).
pub fn write_shared_strings(value : @domain.CT_Sst) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element headers from CT_RevisionHeaders (§18).
pub fn write_headers(value : @domain.CT_RevisionHeaders) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element revisions from CT_Revisions (§18).
pub fn write_revisions(value : @domain.CT_Revisions) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element users from CT_Users (§18).
pub fn write_users(value : @domain.CT_Users) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element worksheet from CT_Worksheet (§18).
pub fn write_worksheet(value : @domain.CT_Worksheet) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element chartsheet from CT_Chartsheet (§18).
pub fn write_chartsheet(value : @domain.CT_Chartsheet) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element dialogsheet from CT_Dialogsheet (§18).
pub fn write_dialogsheet(value : @domain.CT_Dialogsheet) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element volTypes from CT_VolTypes (§18).
pub fn write_vol_types(value : @domain.CT_VolTypes) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element metadata from CT_Metadata (§18).
pub fn write_metadata(value : @domain.CT_Metadata) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element singleXmlCells from CT_SingleXmlCells (§18).
pub fn write_single_xml_cells(value : @domain.CT_SingleXmlCells) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level tableSingleCells element from CT_SingleXmlCells (§18 compatibility spelling).
pub fn write_table_single_cells(value : @domain.CT_SingleXmlCells) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element styleSheet from CT_Stylesheet (§18).
pub fn write_style_sheet(value : @domain.CT_Stylesheet) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element externalLink from CT_ExternalLink (§18).
pub fn write_external_link(value : @domain.CT_ExternalLink) -> Bytes {
  write_element(value.element)
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}
