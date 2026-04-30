///|
/// OPC relationships §8 Errors E2 schema error for XML that is well-formed but
/// violates opc-relationships.xsd constraints.
pub suberror SchemaViolation {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC relationships §8 Errors E3 feature error for recognised schema content
/// this build cannot process.
pub suberror UnsupportedFeature {
  UnsupportedFeature(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC relationships §8 Errors E4 resolver error for a relationship target the
/// surrounding OPC package cannot supply.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// Enforce an E3 capability check with relationship path context.
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
/// Enforce the package-level resolver contract for relationship targets.
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
