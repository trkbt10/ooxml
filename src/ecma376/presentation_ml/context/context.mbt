///|
/// PresentationML context layer for the reader -> context -> builder/viewer
/// pipeline.
///
/// The context carries OPC relationships and content types from ECMA-376 Part
/// 2, DrawingML theme data from Part 1 §20.1, and PresentationML §19 state used
/// while resolving slide masters, slide layouts, placeholders, notes, handouts,
/// comments, and timing relationships.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/context"
}

///|
/// Shared parser/rendering state for PresentationML §19 packages.
pub(all) struct Context {
  relationships : @relationships.CT_Relationships?
  content_types : @content_types.CT_Types?
  theme : @theme.CT_OfficeStyleSheet?
  slide_master : @domain.CT_SlideMaster?
  slide_layout : @domain.CT_SlideLayout?
} derive(Eq, Debug)

///|
/// Create an empty PresentationML context with no resolved slide hierarchy.
pub fn Context::new() -> Context {
  {
    relationships: None,
    content_types: None,
    theme: None,
    slide_master: None,
    slide_layout: None,
  }
}

///|
/// Resolve an OPC relationship id against the relationships part in this
/// PresentationML context.
pub fn Context::resolve_relationship(
  self : Context,
  id : String,
) -> @relationships.CT_Relationship? {
  match self.relationships {
    Some(relationships) => relationships.find_by_id(id)
    None => None
  }
}
