///|
/// WordprocessingML context layer for the reader -> context -> builder/viewer
/// pipeline.
///
/// The context carries OPC relationships and content types from ECMA-376 Part
/// 2, DrawingML theme data from Part 1 §20.1, and WordprocessingML §17 state
/// used while resolving style and numbering inheritance for paragraphs, runs,
/// tables, sections, headers, and footers.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/context"
}

///|
/// Shared parser/rendering state for WordprocessingML §17 packages.
pub(all) struct Context {
  relationships : @relationships.CT_Relationships?
  content_types : @content_types.CT_Types?
  theme : @theme.CT_OfficeStyleSheet?
  current_style_id : String?
  current_numbering_id : String?
} derive(Eq, Debug)

///|
/// Create an empty WordprocessingML context with no resolved package parts.
pub fn Context::new() -> Context {
  {
    relationships: None,
    content_types: None,
    theme: None,
    current_style_id: None,
    current_numbering_id: None,
  }
}

///|
/// Resolve an OPC relationship id against the relationships part in this
/// WordprocessingML context.
pub fn Context::resolve_relationship(
  self : Context,
  id : String,
) -> @relationships.CT_Relationship? {
  match self.relationships {
    Some(relationships) => relationships.find_by_id(id)
    None => None
  }
}
