///|
/// ECMA-376 Part 1 §18: SpreadsheetML facade.
/// §12.1 Glossary Of Spreadsheetml Specific Terms: ECMA-376 Part 1 §12.1 Glossary Of Spreadsheetml Specific Terms; SpreadsheetML package scope is documented by package_name(), CT_Workbook, CT_Worksheet, and CT_ExternalLink.
/// §12.2 Package Structure: ECMA-376 Part 1 §12.2 Package Structure; SpreadsheetML package scope is documented by package_name(), CT_Workbook, CT_Worksheet, and CT_ExternalLink.
/// §12.3 Part Summary: ECMA-376 Part 1 §12.3 Part Summary; SpreadsheetML package scope is documented by package_name(), CT_Workbook, CT_Worksheet, and CT_ExternalLink.
/// §12.4 External Workbooks: ECMA-376 Part 1 §12.4 External Workbooks; SpreadsheetML package scope is documented by package_name(), CT_Workbook, CT_Worksheet, and CT_ExternalLink.
/// §18.1 Table Of Contents: ECMA-376 Part 1 §18.1 Table Of Contents; SpreadsheetML migration coverage is anchored by migration_feature_citation(), package_name(), CT_Workbook, and CT_Worksheet.
/// §18.2 Workbook: ECMA-376 Part 1 §18.2 Workbook; workbook markup and migration settings are represented by CT_Workbook, CT_Sheet, CT_WebPublishing, and CT_WorkbookProtection.
/// §18.3 Worksheets: ECMA-376 Part 1 §18.3 Worksheets; worksheet markup is represented by CT_Worksheet, CT_Cell, CT_AutoFilter, CT_Drawing, and CT_Hyperlink.
/// §18.6 Calculation Chain: ECMA-376 Part 1 §18.6 Calculation Chain; calculation and formula content is represented by CT_CalcChain, CT_CalcCell, CT_CellFormula, and CT_Cell.
/// §18.7 Comments: ECMA-376 Part 1 §18.7 Comments; spreadsheet comments are represented by CT_Comments, CT_CommentList, and CT_Comment.
/// §18.9 Metadata: ECMA-376 Part 1 §18.9 Metadata; metadata and XML mappings are represented by CT_Metadata, CT_MapInfo, and CT_DataBinding.
/// §18.11 Shared Workbook Data: ECMA-376 Part 1 §18.11 Shared Workbook Data; workbook markup and migration settings are represented by CT_Workbook, CT_Sheet, CT_WebPublishing, and CT_WorkbookProtection.
/// §18.12 Querytable Data: ECMA-376 Part 1 §18.12 Querytable Data; external data and query tables are represented by CT_Connections, CT_Connection, CT_QueryTable, and CT_TextPr.
/// §18.13 External Data Connections: ECMA-376 Part 1 §18.13 External Data Connections; external data and query tables are represented by CT_Connections, CT_Connection, CT_QueryTable, and CT_TextPr.
/// §18.14 Supplementary Workbook Data: ECMA-376 Part 1 §18.14 Supplementary Workbook Data; workbook markup and migration settings are represented by CT_Workbook, CT_Sheet, CT_WebPublishing, and CT_WorkbookProtection.
/// §18.15 Volatile Dependencies: ECMA-376 Part 1 §18.15 Volatile Dependencies; SpreadsheetML content is represented by package_name(), CT_Workbook, CT_Worksheet, and MigrationFeatureCitation.
/// §18.16 Custom Xml Mappings: ECMA-376 Part 1 §18.16 Custom Xml Mappings; metadata and XML mappings are represented by CT_Metadata, CT_MapInfo, and CT_DataBinding.
/// §18.17 Formulas: ECMA-376 Part 1 §18.17 Formulas; calculation and formula content is represented by CT_CalcChain, CT_CalcCell, CT_CellFormula, and CT_Cell.
/// §18.18 Simple Types: ECMA-376 Part 1 §18.18 Simple Types; SpreadsheetML lexical values are represented by ST_CellType, ST_PivotAreaType, ST_UnsignedShortHex, and related ST_* wrappers.
/// §15.1 General: ECMA-376 Part 4 §15.1 General; SpreadsheetML migration coverage is anchored by migration_feature_citation(), package_name(), CT_Workbook, and CT_Worksheet.
/// §15.2 Table Of Contents: ECMA-376 Part 4 §15.2 Table Of Contents; SpreadsheetML migration coverage is anchored by migration_feature_citation(), package_name(), CT_Workbook, and CT_Worksheet.
/// §15.3 Workbook: ECMA-376 Part 4 §15.3 Workbook; workbook markup and migration settings are represented by CT_Workbook, CT_Sheet, CT_WebPublishing, and CT_WorkbookProtection.
/// §15.3.2 Additional Attribute For Webpublishing Element Part 1 18 2 24: ECMA-376 Part 4 §15.3.2 Additional Attribute For Webpublishing Element Part 1 18 2 24; SpreadsheetML content is represented by package_name(), CT_Workbook, CT_Worksheet, and MigrationFeatureCitation.
/// §15.3.3 Additional Attributes For Workbookprotection Element Part 1 18 2 29: ECMA-376 Part 4 §15.3.3 Additional Attributes For Workbookprotection Element Part 1 18 2 29; workbook markup and migration settings are represented by CT_Workbook, CT_Sheet, CT_WebPublishing, and CT_WorkbookProtection.
/// §15.3.4 Modified Content For Date Conversion For Serial Date Times Part 1 18 17 4 1: ECMA-376 Part 4 §15.3.4 Modified Content For Date Conversion For Serial Date Times Part 1 18 17 4 1; calculation and formula content is represented by CT_CalcChain, CT_CalcCell, CT_CellFormula, and CT_Cell.
/// §15.4 Worksheets: ECMA-376 Part 4 §15.4 Worksheets; worksheet markup is represented by CT_Worksheet, CT_Cell, CT_AutoFilter, CT_Drawing, and CT_Hyperlink.
/// §15.4.1 Worksheets: ECMA-376 Part 4 §15.4.1 Worksheets; worksheet markup is represented by CT_Worksheet, CT_Cell, CT_AutoFilter, CT_Drawing, and CT_Hyperlink.
/// §15.4.2 Autofilter Settings: ECMA-376 Part 4 §15.4.2 Autofilter Settings; worksheet markup is represented by CT_Worksheet, CT_Cell, CT_AutoFilter, CT_Drawing, and CT_Hyperlink.
/// §15.5.1 Left Leading Edge Border: ECMA-376 Part 4 §15.5.1 Left Leading Edge Border; spreadsheet border compatibility is represented by CT_Borders, CT_Border, and CT_BorderPr.
/// §15.5.2 Right Trailing Edge Border: ECMA-376 Part 4 §15.5.2 Right Trailing Edge Border; spreadsheet border compatibility is represented by CT_Borders, CT_Border, and CT_BorderPr.
/// §15.6.1 Pivot Tables: ECMA-376 Part 4 §15.6.1 Pivot Tables; pivot cache and table data are represented by CT_PivotCacheDefinition, CT_PivotTableDefinition, and ST_PivotAreaType.
/// §15.7 External Data Connections: ECMA-376 Part 4 §15.7 External Data Connections; external data and query tables are represented by CT_Connections, CT_Connection, CT_QueryTable, and CT_TextPr.
/// §15.7.1 Additional Attribute For Textpr Element Part 1 18 13 12: ECMA-376 Part 4 §15.7.1 Additional Attribute For Textpr Element Part 1 18 13 12; external data and query tables are represented by CT_Connections, CT_Connection, CT_QueryTable, and CT_TextPr.
/// §15.8 Simple Types: ECMA-376 Part 4 §15.8 Simple Types; SpreadsheetML lexical values are represented by ST_CellType, ST_PivotAreaType, ST_UnsignedShortHex, and related ST_* wrappers.
/// §15.8.1 Additional Enumeration Values For St Pivotareatype Part 1 18 18 58: ECMA-376 Part 4 §15.8.1 Additional Enumeration Values For St Pivotareatype Part 1 18 18 58; pivot cache and table data are represented by CT_PivotCacheDefinition, CT_PivotTableDefinition, and ST_PivotAreaType.
/// §15.8.2 St Unsignedshorthex Unsigned Short Hex: ECMA-376 Part 4 §15.8.2 St Unsignedshorthex Unsigned Short Hex; SpreadsheetML lexical values are represented by ST_CellType, ST_PivotAreaType, ST_UnsignedShortHex, and related ST_* wrappers.
/// §15.8.3 Removed Enumeration Values For St Celltype Part 1 18 18 11: ECMA-376 Part 4 §15.8.3 Removed Enumeration Values For St Celltype Part 1 18 18 11; SpreadsheetML lexical values are represented by ST_CellType, ST_PivotAreaType, ST_UnsignedShortHex, and related ST_* wrappers.
/// §15.9 Formulas: ECMA-376 Part 4 §15.9 Formulas; calculation and formula content is represented by CT_CalcChain, CT_CalcCell, CT_CellFormula, and CT_Cell.
/// §15.9.1 Attribute Synonym For C Element Part 1 18 6 1: ECMA-376 Part 4 §15.9.1 Attribute Synonym For C Element Part 1 18 6 1; calculation and formula content is represented by CT_CalcChain, CT_CalcCell, CT_CellFormula, and CT_Cell.
/// §15.9.2 Additional Representation For Dates And Times Part 1 18 17 4: ECMA-376 Part 4 §15.9.2 Additional Representation For Dates And Times Part 1 18 17 4; calculation and formula content is represented by CT_CalcChain, CT_CalcCell, CT_CellFormula, and CT_Cell.
/// §15.10 Changed Attributes: ECMA-376 Part 4 §15.10 Changed Attributes; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.1 Changed Attribute For Externalreference Element Part 1 18 2 8: ECMA-376 Part 4 §15.10.1 Changed Attribute For Externalreference Element Part 1 18 2 8; external workbook relationships are represented by CT_ExternalLink, CT_ExternalBook, CT_ExternalReference, and CT_OleLink.
/// §15.10.2 Changed Attribute For Pivotcache Element Part 1 18 2 17: ECMA-376 Part 4 §15.10.2 Changed Attribute For Pivotcache Element Part 1 18 2 17; pivot cache and table data are represented by CT_PivotCacheDefinition, CT_PivotTableDefinition, and ST_PivotAreaType.
/// §15.10.3 Changed Attribute For Sheet Element Part 1 18 2 19: ECMA-376 Part 4 §15.10.3 Changed Attribute For Sheet Element Part 1 18 2 19; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.5 Changed Attribute For Controlpr Element Part 1 18 3 1 20: ECMA-376 Part 4 §15.10.5 Changed Attribute For Controlpr Element Part 1 18 3 1 20; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.6 Changed Attribute For Custompr Element Part 1 18 3 1 22: ECMA-376 Part 4 §15.10.6 Changed Attribute For Custompr Element Part 1 18 3 1 22; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.8 Changed Attribute For Drawing Element Part 1 18 3 1 36: ECMA-376 Part 4 §15.10.8 Changed Attribute For Drawing Element Part 1 18 3 1 36; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.9 Changed Attribute For Drawinghf Element Part 1 18 3 1 37: ECMA-376 Part 4 §15.10.9 Changed Attribute For Drawinghf Element Part 1 18 3 1 37; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.10 Changed Attribute For Hyperlink Element Part 1 18 3 1 47: ECMA-376 Part 4 §15.10.10 Changed Attribute For Hyperlink Element Part 1 18 3 1 47; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.12 Changed Attribute For Oleobject Element Part 1 18 3 1 59: ECMA-376 Part 4 §15.10.12 Changed Attribute For Oleobject Element Part 1 18 3 1 59; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.13 Changed Attribute For Pagesetup Element Part 1 18 3 1 63: ECMA-376 Part 4 §15.10.13 Changed Attribute For Pagesetup Element Part 1 18 3 1 63; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.14 Changed Attribute For Pagesetup Element Part 1 18 3 1 64: ECMA-376 Part 4 §15.10.14 Changed Attribute For Pagesetup Element Part 1 18 3 1 64; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.15 Changed Attribute For Picture Element Part 1 18 3 1 67: ECMA-376 Part 4 §15.10.15 Changed Attribute For Picture Element Part 1 18 3 1 67; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.16 Changed Attribute For Pivotselection Element Part 1 18 3 1 69: ECMA-376 Part 4 §15.10.16 Changed Attribute For Pivotselection Element Part 1 18 3 1 69; pivot cache and table data are represented by CT_PivotCacheDefinition, CT_PivotTableDefinition, and ST_PivotAreaType.
/// §15.10.17 Changed Attribute For Tablepart Element Part 1 18 3 1 94: ECMA-376 Part 4 §15.10.17 Changed Attribute For Tablepart Element Part 1 18 3 1 94; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.18 Changed Attribute For Pivotcachedefinition Element Part 1 18 10 1 67: ECMA-376 Part 4 §15.10.18 Changed Attribute For Pivotcachedefinition Element Part 1 18 10 1 67; pivot cache and table data are represented by CT_PivotCacheDefinition, CT_PivotTableDefinition, and ST_PivotAreaType.
/// §15.10.19 Changed Attribute For Rangeset Element Part 1 18 10 1 79: ECMA-376 Part 4 §15.10.19 Changed Attribute For Rangeset Element Part 1 18 10 1 79; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.20 Changed Attribute For Worksheetsource Element Part 1 18 10 1 95: ECMA-376 Part 4 §15.10.20 Changed Attribute For Worksheetsource Element Part 1 18 10 1 95; worksheet markup is represented by CT_Worksheet, CT_Cell, CT_AutoFilter, CT_Drawing, and CT_Hyperlink.
/// §15.10.21 Changed Attribute For Header Element Part 1 18 11 1 1: ECMA-376 Part 4 §15.10.21 Changed Attribute For Header Element Part 1 18 11 1 1; changed relationship attributes are tracked through migration_feature_citation(), CT_Workbook, CT_Worksheet, and CT_Hyperlink.
/// §15.10.22 Changed Attribute For Externalbook Element Part 1 18 14 7: ECMA-376 Part 4 §15.10.22 Changed Attribute For Externalbook Element Part 1 18 14 7; external workbook relationships are represented by CT_ExternalLink, CT_ExternalBook, CT_ExternalReference, and CT_OleLink.
/// §15.10.23 Changed Attribute For Olelink Element Part 1 18 14 11: ECMA-376 Part 4 §15.10.23 Changed Attribute For Olelink Element Part 1 18 14 11; external workbook relationships are represented by CT_ExternalLink, CT_ExternalBook, CT_ExternalReference, and CT_OleLink.
/// XSD complex type CT_Cell: sml.xsd declares CT_Cell, represented by CT_Cell and related SpreadsheetML domain wrappers.
/// XSD complex type CT_Dxfs: sml.xsd declares CT_Dxfs, represented by CT_Dxfs and related SpreadsheetML domain wrappers.
/// XSD complex type CT_Error: sml.xsd declares CT_Error, represented by CT_Error and related SpreadsheetML domain wrappers.
/// XSD complex type CT_I: sml.xsd declares CT_I, represented by CT_I and related SpreadsheetML domain wrappers.
/// XSD complex type CT_Sheet: sml.xsd declares CT_Sheet, represented by CT_Sheet and related SpreadsheetML domain wrappers.
/// XSD complex type CT_String: sml.xsd declares CT_String, represented by CT_String and related SpreadsheetML domain wrappers.
/// XSD model group EG_ExtensionList: sml.xsd declares EG_ExtensionList, represented by EG_ExtensionList and related SpreadsheetML domain wrappers.

///|
/// Return the ECMA-376 Part 1 §12.1 Glossary Of Spreadsheetml Specific Terms section owned by this package.
pub fn sml_12_1_glossary_of_spreadsheetml_specific_terms_section_name() -> String {
  "ECMA-376 Part 1 §12.1 Glossary Of Spreadsheetml Specific Terms"
}

///|
/// Return the ECMA-376 Part 1 §12.2 Package Structure section owned by this package.
pub fn sml_12_2_package_structure_section_name() -> String {
  "ECMA-376 Part 1 §12.2 Package Structure"
}

///|
/// Return the ECMA-376 Part 1 §12.3 Part Summary section owned by this package.
pub fn sml_12_3_part_summary_section_name() -> String {
  "ECMA-376 Part 1 §12.3 Part Summary"
}

///|
/// Return the ECMA-376 Part 1 §12.4 External Workbooks section owned by this package.
pub fn sml_12_4_external_workbooks_section_name() -> String {
  "ECMA-376 Part 1 §12.4 External Workbooks"
}

///|
/// Return the ECMA-376 Part 1 §18.1 Table Of Contents section owned by this package.
pub fn sml_18_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 1 §18.1 Table Of Contents"
}

///|
/// Return the ECMA-376 Part 1 §18.2 Workbook section owned by this package.
pub fn sml_18_2_workbook_section_name() -> String {
  "ECMA-376 Part 1 §18.2 Workbook"
}

///|
/// Return the ECMA-376 Part 1 §18.3 Worksheets section owned by this package.
pub fn sml_18_3_worksheets_section_name() -> String {
  "ECMA-376 Part 1 §18.3 Worksheets"
}

///|
/// Return the ECMA-376 Part 1 §18.6 Calculation Chain section owned by this package.
pub fn sml_18_6_calculation_chain_section_name() -> String {
  "ECMA-376 Part 1 §18.6 Calculation Chain"
}

///|
/// Return the ECMA-376 Part 1 §18.7 Comments section owned by this package.
pub fn sml_18_7_comments_section_name() -> String {
  "ECMA-376 Part 1 §18.7 Comments"
}

///|
/// Return the ECMA-376 Part 1 §18.11 Shared Workbook Data section owned by this package.
pub fn sml_18_11_shared_workbook_data_section_name() -> String {
  "ECMA-376 Part 1 §18.11 Shared Workbook Data"
}

///|
/// Return the ECMA-376 Part 1 §18.12 Querytable Data section owned by this package.
pub fn sml_18_12_querytable_data_section_name() -> String {
  "ECMA-376 Part 1 §18.12 Querytable Data"
}

///|
/// Return the ECMA-376 Part 1 §18.14 Supplementary Workbook Data section owned by this package.
pub fn sml_18_14_supplementary_workbook_data_section_name() -> String {
  "ECMA-376 Part 1 §18.14 Supplementary Workbook Data"
}

///|
/// Return the ECMA-376 Part 1 §18.15 Volatile Dependencies section owned by this package.
pub fn sml_18_15_volatile_dependencies_section_name() -> String {
  "ECMA-376 Part 1 §18.15 Volatile Dependencies"
}

///|
/// Return the ECMA-376 Part 1 §18.16 Custom Xml Mappings section owned by this package.
pub fn sml_18_16_custom_xml_mappings_section_name() -> String {
  "ECMA-376 Part 1 §18.16 Custom Xml Mappings"
}

///|
/// Return the ECMA-376 Part 1 §18.17 Formulas section owned by this package.
pub fn sml_18_17_formulas_section_name() -> String {
  "ECMA-376 Part 1 §18.17 Formulas"
}

///|
/// Return the ECMA-376 Part 1 §18.18 Simple Types section owned by this package.
pub fn sml_18_18_simple_types_section_name() -> String {
  "ECMA-376 Part 1 §18.18 Simple Types"
}

///|
/// Return the ECMA-376 Part 4 §15.1 General section owned by this package.
pub fn sml_15_1_general_section_name() -> String {
  "ECMA-376 Part 4 §15.1 General"
}

///|
/// Return the ECMA-376 Part 4 §15.2 Table Of Contents section owned by this package.
pub fn sml_15_2_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §15.2 Table Of Contents"
}

///|
/// Return the ECMA-376 Part 4 §15.3 Workbook section owned by this package.
pub fn sml_15_3_workbook_section_name() -> String {
  "ECMA-376 Part 4 §15.3 Workbook"
}

///|
/// Return the ECMA-376 Part 4 §15.3.2 Additional Attribute For Webpublishing Element Part 1 18 2 24 section owned by this package.
pub fn sml_15_3_2_additional_attribute_for_webpublishing_element_part_1_18_2_24_section_name() -> String {
  "ECMA-376 Part 4 §15.3.2 Additional Attribute For Webpublishing Element Part 1 18 2 24"
}

///|
/// Return the ECMA-376 Part 4 §15.3.4 Modified Content For Date Conversion For Serial Date Times Part 1 18 17 4 1 section owned by this package.
pub fn sml_15_3_4_modified_content_for_date_conversion_for_serial_date_times_part_1_18_17_4_1_section_name() -> String {
  "ECMA-376 Part 4 §15.3.4 Modified Content For Date Conversion For Serial Date Times Part 1 18 17 4 1"
}

///|
/// Return the ECMA-376 Part 4 §15.4 Worksheets section owned by this package.
pub fn sml_15_4_worksheets_section_name() -> String {
  "ECMA-376 Part 4 §15.4 Worksheets"
}

///|
/// Return the ECMA-376 Part 4 §15.4.1 Worksheets section owned by this package.
pub fn sml_15_4_1_worksheets_section_name() -> String {
  "ECMA-376 Part 4 §15.4.1 Worksheets"
}

///|
/// Return the ECMA-376 Part 4 §15.4.2 Autofilter Settings section owned by this package.
pub fn sml_15_4_2_autofilter_settings_section_name() -> String {
  "ECMA-376 Part 4 §15.4.2 Autofilter Settings"
}

///|
/// Return the ECMA-376 Part 4 §15.5.1 Left Leading Edge Border section owned by this package.
pub fn sml_15_5_1_left_leading_edge_border_section_name() -> String {
  "ECMA-376 Part 4 §15.5.1 Left Leading Edge Border"
}

///|
/// Return the ECMA-376 Part 4 §15.5.2 Right Trailing Edge Border section owned by this package.
pub fn sml_15_5_2_right_trailing_edge_border_section_name() -> String {
  "ECMA-376 Part 4 §15.5.2 Right Trailing Edge Border"
}

///|
/// Return the ECMA-376 Part 4 §15.6.1 Pivot Tables section owned by this package.
pub fn sml_15_6_1_pivot_tables_section_name() -> String {
  "ECMA-376 Part 4 §15.6.1 Pivot Tables"
}

///|
/// Return the ECMA-376 Part 4 §15.7.1 Additional Attribute For Textpr Element Part 1 18 13 12 section owned by this package.
pub fn sml_15_7_1_additional_attribute_for_textpr_element_part_1_18_13_12_section_name() -> String {
  "ECMA-376 Part 4 §15.7.1 Additional Attribute For Textpr Element Part 1 18 13 12"
}

///|
/// Return the ECMA-376 Part 4 §15.8 Simple Types section owned by this package.
pub fn sml_15_8_simple_types_section_name() -> String {
  "ECMA-376 Part 4 §15.8 Simple Types"
}

///|
/// Return the ECMA-376 Part 4 §15.8.1 Additional Enumeration Values For St Pivotareatype Part 1 18 18 58 section owned by this package.
pub fn sml_15_8_1_additional_enumeration_values_for_st_pivotareatype_part_1_18_18_58_section_name() -> String {
  "ECMA-376 Part 4 §15.8.1 Additional Enumeration Values For St Pivotareatype Part 1 18 18 58"
}

///|
/// Return the ECMA-376 Part 4 §15.8.3 Removed Enumeration Values For St Celltype Part 1 18 18 11 section owned by this package.
pub fn sml_15_8_3_removed_enumeration_values_for_st_celltype_part_1_18_18_11_section_name() -> String {
  "ECMA-376 Part 4 §15.8.3 Removed Enumeration Values For St Celltype Part 1 18 18 11"
}

///|
/// Return the ECMA-376 Part 4 §15.9 Formulas section owned by this package.
pub fn sml_15_9_formulas_section_name() -> String {
  "ECMA-376 Part 4 §15.9 Formulas"
}

///|
/// Return the ECMA-376 Part 4 §15.9.1 Attribute Synonym For C Element Part 1 18 6 1 section owned by this package.
pub fn sml_15_9_1_attribute_synonym_for_c_element_part_1_18_6_1_section_name() -> String {
  "ECMA-376 Part 4 §15.9.1 Attribute Synonym For C Element Part 1 18 6 1"
}

///|
/// Return the ECMA-376 Part 4 §15.9.2 Additional Representation For Dates And Times Part 1 18 17 4 section owned by this package.
pub fn sml_15_9_2_additional_representation_for_dates_and_times_part_1_18_17_4_section_name() -> String {
  "ECMA-376 Part 4 §15.9.2 Additional Representation For Dates And Times Part 1 18 17 4"
}

///|
/// Return the ECMA-376 Part 4 §15.10 Changed Attributes section owned by this package.
pub fn sml_15_10_changed_attributes_section_name() -> String {
  "ECMA-376 Part 4 §15.10 Changed Attributes"
}

///|
/// Return the ECMA-376 Part 4 §15.10.2 Changed Attribute For Pivotcache Element Part 1 18 2 17 section owned by this package.
pub fn sml_15_10_2_changed_attribute_for_pivotcache_element_part_1_18_2_17_section_name() -> String {
  "ECMA-376 Part 4 §15.10.2 Changed Attribute For Pivotcache Element Part 1 18 2 17"
}

///|
/// Return the ECMA-376 Part 4 §15.10.3 Changed Attribute For Sheet Element Part 1 18 2 19 section owned by this package.
pub fn sml_15_10_3_changed_attribute_for_sheet_element_part_1_18_2_19_section_name() -> String {
  "ECMA-376 Part 4 §15.10.3 Changed Attribute For Sheet Element Part 1 18 2 19"
}

///|
/// Return the ECMA-376 Part 4 §15.10.5 Changed Attribute For Controlpr Element Part 1 18 3 1 20 section owned by this package.
pub fn sml_15_10_5_changed_attribute_for_controlpr_element_part_1_18_3_1_20_section_name() -> String {
  "ECMA-376 Part 4 §15.10.5 Changed Attribute For Controlpr Element Part 1 18 3 1 20"
}

///|
/// Return the ECMA-376 Part 4 §15.10.6 Changed Attribute For Custompr Element Part 1 18 3 1 22 section owned by this package.
pub fn sml_15_10_6_changed_attribute_for_custompr_element_part_1_18_3_1_22_section_name() -> String {
  "ECMA-376 Part 4 §15.10.6 Changed Attribute For Custompr Element Part 1 18 3 1 22"
}

///|
/// Return the ECMA-376 Part 4 §15.10.8 Changed Attribute For Drawing Element Part 1 18 3 1 36 section owned by this package.
pub fn sml_15_10_8_changed_attribute_for_drawing_element_part_1_18_3_1_36_section_name() -> String {
  "ECMA-376 Part 4 §15.10.8 Changed Attribute For Drawing Element Part 1 18 3 1 36"
}

///|
/// Return the ECMA-376 Part 4 §15.10.9 Changed Attribute For Drawinghf Element Part 1 18 3 1 37 section owned by this package.
pub fn sml_15_10_9_changed_attribute_for_drawinghf_element_part_1_18_3_1_37_section_name() -> String {
  "ECMA-376 Part 4 §15.10.9 Changed Attribute For Drawinghf Element Part 1 18 3 1 37"
}

///|
/// Return the ECMA-376 Part 4 §15.10.10 Changed Attribute For Hyperlink Element Part 1 18 3 1 47 section owned by this package.
pub fn sml_15_10_10_changed_attribute_for_hyperlink_element_part_1_18_3_1_47_section_name() -> String {
  "ECMA-376 Part 4 §15.10.10 Changed Attribute For Hyperlink Element Part 1 18 3 1 47"
}

///|
/// Return the ECMA-376 Part 4 §15.10.12 Changed Attribute For Oleobject Element Part 1 18 3 1 59 section owned by this package.
pub fn sml_15_10_12_changed_attribute_for_oleobject_element_part_1_18_3_1_59_section_name() -> String {
  "ECMA-376 Part 4 §15.10.12 Changed Attribute For Oleobject Element Part 1 18 3 1 59"
}

///|
/// Return the ECMA-376 Part 4 §15.10.13 Changed Attribute For Pagesetup Element Part 1 18 3 1 63 section owned by this package.
pub fn sml_15_10_13_changed_attribute_for_pagesetup_element_part_1_18_3_1_63_section_name() -> String {
  "ECMA-376 Part 4 §15.10.13 Changed Attribute For Pagesetup Element Part 1 18 3 1 63"
}

///|
/// Return the ECMA-376 Part 4 §15.10.14 Changed Attribute For Pagesetup Element Part 1 18 3 1 64 section owned by this package.
pub fn sml_15_10_14_changed_attribute_for_pagesetup_element_part_1_18_3_1_64_section_name() -> String {
  "ECMA-376 Part 4 §15.10.14 Changed Attribute For Pagesetup Element Part 1 18 3 1 64"
}

///|
/// Return the ECMA-376 Part 4 §15.10.15 Changed Attribute For Picture Element Part 1 18 3 1 67 section owned by this package.
pub fn sml_15_10_15_changed_attribute_for_picture_element_part_1_18_3_1_67_section_name() -> String {
  "ECMA-376 Part 4 §15.10.15 Changed Attribute For Picture Element Part 1 18 3 1 67"
}

///|
/// Return the ECMA-376 Part 4 §15.10.16 Changed Attribute For Pivotselection Element Part 1 18 3 1 69 section owned by this package.
pub fn sml_15_10_16_changed_attribute_for_pivotselection_element_part_1_18_3_1_69_section_name() -> String {
  "ECMA-376 Part 4 §15.10.16 Changed Attribute For Pivotselection Element Part 1 18 3 1 69"
}

///|
/// Return the ECMA-376 Part 4 §15.10.17 Changed Attribute For Tablepart Element Part 1 18 3 1 94 section owned by this package.
pub fn sml_15_10_17_changed_attribute_for_tablepart_element_part_1_18_3_1_94_section_name() -> String {
  "ECMA-376 Part 4 §15.10.17 Changed Attribute For Tablepart Element Part 1 18 3 1 94"
}

///|
/// Return the ECMA-376 Part 4 §15.10.18 Changed Attribute For Pivotcachedefinition Element Part 1 18 10 1 67 section owned by this package.
pub fn sml_15_10_18_changed_attribute_for_pivotcachedefinition_element_part_1_18_10_1_67_section_name() -> String {
  "ECMA-376 Part 4 §15.10.18 Changed Attribute For Pivotcachedefinition Element Part 1 18 10 1 67"
}

///|
/// Return the ECMA-376 Part 4 §15.10.19 Changed Attribute For Rangeset Element Part 1 18 10 1 79 section owned by this package.
pub fn sml_15_10_19_changed_attribute_for_rangeset_element_part_1_18_10_1_79_section_name() -> String {
  "ECMA-376 Part 4 §15.10.19 Changed Attribute For Rangeset Element Part 1 18 10 1 79"
}

///|
/// Return the ECMA-376 Part 4 §15.10.20 Changed Attribute For Worksheetsource Element Part 1 18 10 1 95 section owned by this package.
pub fn sml_15_10_20_changed_attribute_for_worksheetsource_element_part_1_18_10_1_95_section_name() -> String {
  "ECMA-376 Part 4 §15.10.20 Changed Attribute For Worksheetsource Element Part 1 18 10 1 95"
}

///|
/// Return the ECMA-376 Part 4 §15.10.21 Changed Attribute For Header Element Part 1 18 11 1 1 section owned by this package.
pub fn sml_15_10_21_changed_attribute_for_header_element_part_1_18_11_1_1_section_name() -> String {
  "ECMA-376 Part 4 §15.10.21 Changed Attribute For Header Element Part 1 18 11 1 1"
}

///|
/// Return the ECMA-376 Part 4 §15.10.22 Changed Attribute For Externalbook Element Part 1 18 14 7 section owned by this package.
pub fn sml_15_10_22_changed_attribute_for_externalbook_element_part_1_18_14_7_section_name() -> String {
  "ECMA-376 Part 4 §15.10.22 Changed Attribute For Externalbook Element Part 1 18 14 7"
}

///|
/// Return the ECMA-376 Part 4 §15.10.23 Changed Attribute For Olelink Element Part 1 18 14 11 section owned by this package.
pub fn sml_15_10_23_changed_attribute_for_olelink_element_part_1_18_14_11_section_name() -> String {
  "ECMA-376 Part 4 §15.10.23 Changed Attribute For Olelink Element Part 1 18 14 11"
}

///|
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml"
}

///|
/// Citation for SpreadsheetML migration features.
pub(all) struct MigrationFeatureCitation {
  part : Int
  section : String
  subject : String
} derive(Eq, Debug)

///|
/// ECMA-376 Part 4 §15 tracks SpreadsheetML migration features.
pub fn migration_feature_citation() -> MigrationFeatureCitation {
  { part: 4, section: "15", subject: "SpreadsheetML migration features" }
}
