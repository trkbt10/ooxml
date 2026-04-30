///|
/// OPC §9 Thumbnails error surface for XmlMalformed, SchemaViolation,
/// UnsupportedFeature, and ResourceMissing.
pub(all) suberror PartError {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
  UnsupportedFeature(section~ : String, path~ : String, reason~ : String)
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)
