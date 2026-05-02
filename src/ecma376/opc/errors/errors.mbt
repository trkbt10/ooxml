///|
/// OPC §8 Errors E2 package-level schema error.
pub(all) suberror SchemaViolation {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC §8 Errors E3 package feature error.
pub(all) suberror UnsupportedFeature {
  UnsupportedFeature(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC §8 Errors E4 unresolved package resource error.
pub(all) suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// Enforce an OPC package schema condition, including ECMA-376 Part 2 §6.2.5
/// Xml Usage constraints delegated by XML-owning OPC sub-packages.
pub fn require_schema(
  valid : Bool,
  section~ : String,
  path~ : String,
  reason~ : String,
) -> Unit raise SchemaViolation {
  if !valid {
    raise SchemaViolation(section~, path~, reason~)
  }
}

///|
/// Enforce an OPC package capability check.
pub fn require_supported_feature(
  supported : Bool,
  section~ : String,
  path~ : String,
  reason~ : String,
) -> Unit raise UnsupportedFeature {
  if !supported {
    raise UnsupportedFeature(section~, path~, reason~)
  }
}

///|
/// Enforce an OPC package resource resolution check.
pub fn require_resource(
  available : Bool,
  section~ : String,
  path~ : String,
  target~ : String,
) -> Unit raise ResourceMissing {
  if !available {
    raise ResourceMissing(section~, path~, target~)
  }
}
