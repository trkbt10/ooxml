///|
/// OPC content-types §8 Errors E2 schema error for XML that is well-formed but
/// violates opc-contentTypes.xsd constraints in §4.
pub suberror SchemaViolation {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC content-types §8 Errors E3 feature error for a recognised §4 element or
/// attribute this build cannot process.
pub suberror UnsupportedFeature {
  UnsupportedFeature(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC content-types §8 Errors E4 resolver error for a referenced package part
/// that cannot be supplied by the surrounding OPC layer.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// Enforce an E3 capability check while keeping the originating section and
/// content-types path on the error value.
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
/// Report E4 when the OPC package cannot resolve a part referenced by an
/// Override declaration or by later package validation.
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
