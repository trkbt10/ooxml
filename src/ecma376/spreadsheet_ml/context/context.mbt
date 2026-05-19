///|
/// SpreadsheetML context layer for the reader -> context -> builder/viewer
/// pipeline.
///
/// The context carries OPC relationships and content types from ECMA-376 Part
/// 2, DrawingML theme data from Part 1 §20.1, and SpreadsheetML §18 state used
/// while resolving shared strings, styles, sheet indexes, formulas, and
/// workbook relationships.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/context"
}

///|
/// Shared parser/rendering state for SpreadsheetML §18 packages.
pub(all) struct Context {
  relationships : @relationships.CT_Relationships?
  content_types : @content_types.CT_Types?
  theme : @theme.CT_OfficeStyleSheet?
  sst : @domain.CT_Sst?
  styles : @domain.CT_Stylesheet?
} derive(Eq, Debug)

///|
/// Create an empty SpreadsheetML context with no resolved workbook parts.
pub fn Context::new() -> Context {
  {
    relationships: None,
    content_types: None,
    theme: None,
    sst: None,
    styles: None,
  }
}

///|
/// Resolve an OPC relationship id against the relationships part in this
/// SpreadsheetML context.
pub fn Context::resolve_relationship(
  self : Context,
  id : String,
) -> @relationships.CT_Relationship? {
  match self.relationships {
    Some(relationships) => relationships.find_by_id(id)
    None => None
  }
}
