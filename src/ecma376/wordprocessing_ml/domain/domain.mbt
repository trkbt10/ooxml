///|
/// ECMA-376 Part 1 WordprocessingML domain model for §17 document markup and
/// the package-level WordprocessingML parts in §11.
///
/// This package owns the typed wrappers used by the reader/context/builder
/// pipeline: top-level constructors such as document, styles, numbering,
/// settings, comments, footnotes, endnotes, hdr, and ftr; complex types such
/// as CT_Document, CT_Body, CT_P, CT_R, CT_Tbl, CT_Styles, CT_Numbering,
/// CT_Settings, CT_FontsList, and CT_GlossaryDocument; model-group wrappers
/// such as EG_PContentBase and EG_RunInnerContent; simple types such as
/// ST_OnOff, ST_String, ST_DecimalNumber, and ST_HexColor; and schema error
/// type SchemaViolation.
///
/// §3 TOC coverage from .kiro/specs/ecma376/wordprocessing_ml/coverage.json
/// includes Part 1 §11.1-§11.9 package structure, §17.1 table of contents,
/// §17.3 paragraphs and rich formatting, §17.5 custom markup, §17.8 fonts,
/// §17.9 numbering, §17.10 headers and footers, §17.11 footnotes/endnotes,
/// §17.12 glossary documents, §17.13 annotations, §17.14 mail merge, §17.15
/// settings, §17.16 fields and hyperlinks, §17.17 miscellaneous topics, and
/// §17.18 simple types, plus the tracked Part 4 migration sections for
/// paragraphs, tables, fonts, numbering, annotations, and settings.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/domain"
}
