///|
/// SpreadsheetML XML → domain reader.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/reader"
}

///|
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// Read top-level XSD element calcChain as CT_CalcChain (§18).
pub fn read_calc_chain(bytes : Bytes) -> @domain.CT_CalcChain raise {
  @domain.CT_CalcChain::new(read_sml_root(bytes, "calcChain"))
}

///|
/// Read top-level XSD element comments as CT_Comments (§18).
pub fn read_comments(bytes : Bytes) -> @domain.CT_Comments raise {
  @domain.CT_Comments::new(read_sml_root(bytes, "comments"))
}

///|
/// Read top-level XSD element MapInfo as CT_MapInfo (§18).
pub fn read_map_info(bytes : Bytes) -> @domain.CT_MapInfo raise {
  @domain.CT_MapInfo::new(read_sml_root(bytes, "MapInfo"))
}

///|
/// Read top-level XSD element connections as CT_Connections (§18).
pub fn read_connections(bytes : Bytes) -> @domain.CT_Connections raise {
  @domain.CT_Connections::new(read_sml_root(bytes, "connections"))
}

///|
/// Read top-level XSD element pivotCacheDefinition as CT_PivotCacheDefinition (§18).
pub fn read_pivot_cache_definition(
  bytes : Bytes,
) -> @domain.CT_PivotCacheDefinition raise {
  @domain.CT_PivotCacheDefinition::new(
    read_sml_root(bytes, "pivotCacheDefinition"),
  )
}

///|
/// Read top-level XSD element pivotCacheRecords as CT_PivotCacheRecords (§18).
pub fn read_pivot_cache_records(
  bytes : Bytes,
) -> @domain.CT_PivotCacheRecords raise {
  @domain.CT_PivotCacheRecords::new(read_sml_root(bytes, "pivotCacheRecords"))
}

///|
/// Read top-level XSD element pivotTableDefinition as CT_pivotTableDefinition (§18).
pub fn read_pivot_table_definition(
  bytes : Bytes,
) -> @domain.CT_pivotTableDefinition raise {
  @domain.CT_pivotTableDefinition::new(
    read_sml_root(bytes, "pivotTableDefinition"),
  )
}

///|
/// Read top-level XSD element queryTable as CT_QueryTable (§18).
pub fn read_query_table(bytes : Bytes) -> @domain.CT_QueryTable raise {
  @domain.CT_QueryTable::new(read_sml_root(bytes, "queryTable"))
}

///|
/// Read top-level XSD element sst as CT_Sst (§18).
pub fn read_sst(bytes : Bytes) -> @domain.CT_Sst raise {
  @domain.CT_Sst::new(read_sml_root(bytes, "sst"))
}

///|
/// Read top-level sharedStrings element as CT_Sst (§18 compatibility spelling).
pub fn read_shared_strings(bytes : Bytes) -> @domain.CT_Sst raise {
  @domain.CT_Sst::new(read_sml_root(bytes, "sharedStrings"))
}

///|
/// Read top-level XSD element headers as CT_RevisionHeaders (§18).
pub fn read_headers(bytes : Bytes) -> @domain.CT_RevisionHeaders raise {
  @domain.CT_RevisionHeaders::new(read_sml_root(bytes, "headers"))
}

///|
/// Read top-level XSD element revisions as CT_Revisions (§18).
pub fn read_revisions(bytes : Bytes) -> @domain.CT_Revisions raise {
  @domain.CT_Revisions::new(read_sml_root(bytes, "revisions"))
}

///|
/// Read top-level XSD element users as CT_Users (§18).
pub fn read_users(bytes : Bytes) -> @domain.CT_Users raise {
  @domain.CT_Users::new(read_sml_root(bytes, "users"))
}

///|
/// Read top-level XSD element worksheet as CT_Worksheet (§18).
pub fn read_worksheet(bytes : Bytes) -> @domain.CT_Worksheet raise {
  @domain.CT_Worksheet::new(read_sml_root(bytes, "worksheet"))
}

///|
/// Read top-level XSD element chartsheet as CT_Chartsheet (§18).
pub fn read_chartsheet(bytes : Bytes) -> @domain.CT_Chartsheet raise {
  @domain.CT_Chartsheet::new(read_sml_root(bytes, "chartsheet"))
}

///|
/// Read top-level XSD element dialogsheet as CT_Dialogsheet (§18).
pub fn read_dialogsheet(bytes : Bytes) -> @domain.CT_Dialogsheet raise {
  @domain.CT_Dialogsheet::new(read_sml_root(bytes, "dialogsheet"))
}

///|
/// Read top-level XSD element volTypes as CT_VolTypes (§18).
pub fn read_vol_types(bytes : Bytes) -> @domain.CT_VolTypes raise {
  @domain.CT_VolTypes::new(read_sml_root(bytes, "volTypes"))
}

///|
/// Read top-level XSD element metadata as CT_Metadata (§18).
pub fn read_metadata(bytes : Bytes) -> @domain.CT_Metadata raise {
  @domain.CT_Metadata::new(read_sml_root(bytes, "metadata"))
}

///|
/// Read top-level XSD element singleXmlCells as CT_SingleXmlCells (§18).
pub fn read_single_xml_cells(bytes : Bytes) -> @domain.CT_SingleXmlCells raise {
  @domain.CT_SingleXmlCells::new(read_sml_root(bytes, "singleXmlCells"))
}

///|
/// Read top-level tableSingleCells element as CT_SingleXmlCells (§18 compatibility spelling).
pub fn read_table_single_cells(
  bytes : Bytes,
) -> @domain.CT_SingleXmlCells raise {
  @domain.CT_SingleXmlCells::new(read_sml_root(bytes, "tableSingleCells"))
}

///|
/// Read top-level XSD element styleSheet as CT_Stylesheet (§18).
pub fn read_style_sheet(bytes : Bytes) -> @domain.CT_Stylesheet raise {
  @domain.CT_Stylesheet::new(read_sml_root(bytes, "styleSheet"))
}

///|
/// Read top-level XSD element externalLink as CT_ExternalLink (§18).
pub fn read_external_link(bytes : Bytes) -> @domain.CT_ExternalLink raise {
  @domain.CT_ExternalLink::new(read_sml_root(bytes, "externalLink"))
}

///|
fn read_sml_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name)
  root
}

///|
fn require_local(element : @xml.Element, expected : String) -> Unit raise {
  if element.name.local_name != expected {
    raise SchemaViolation(
      schema="sml.xsd top-level element",
      path=element.name.local_name,
      reason="expected " + expected,
    )
  }
}
