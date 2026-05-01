///|
/// ECMA-376 Part 1 SpreadsheetML domain model for §18 workbook, worksheet,
/// style, shared string, metadata, pivot, and external data markup.
///
/// This package owns the typed wrappers consumed by the SpreadsheetML
/// reader/context/builder pipeline: CT_Workbook, CT_Worksheet, CT_Sst,
/// CT_Rst, CT_Stylesheet, CT_Cell, CT_Row, CT_SheetData, CT_DefinedNames,
/// CT_PivotCacheDefinition, CT_Connection, CT_Metadata, and related CT_* groups
/// in sheet_types.mbt, shared_string_types.mbt, style_types.mbt,
/// pivot_types.mbt, metadata_external_types.mbt, and
/// workbook_connection_types.mbt.
///
/// §3 TOC coverage from .kiro/specs/ecma376/spreadsheet_ml/coverage.json
/// includes Part 1 §12.1-§12.4 package structure and external workbooks,
/// §18.1 table of contents, §18.2 workbook, §18.3 worksheets, §18.6
/// calculation chain, §18.7 comments, §18.9 metadata, §18.11 shared workbook
/// data, §18.12 query tables, §18.13 external data connections, §18.14
/// supplementary workbook data, §18.15 volatile dependencies, §18.16 custom
/// XML mappings, §18.17 formulas, and §18.18 simple types, plus tracked Part 4
/// migration sections for workbook, worksheet, styles, pivot, external data,
/// simple types, formulas, and changed attributes.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/domain"
}
