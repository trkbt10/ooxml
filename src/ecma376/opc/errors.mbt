///|
/// OPC §8 Errors E2 package-level schema error.
pub suberror SchemaViolation {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC §8 Errors E3 package feature error.
pub suberror UnsupportedFeature {
  UnsupportedFeature(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC §8 Errors E4 unresolved package resource error.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// Enforce an OPC package schema condition.
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
