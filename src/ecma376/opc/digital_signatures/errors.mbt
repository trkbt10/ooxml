///|
/// 8. Errors E2 schema error for XML that is well-formed but violates
/// the opc-digSig schema constraints. The section, path, and reason fields let
/// callers map occurrence, cardinality, required attribute, type, and pattern
/// failures back to the digital-signature contract.
pub suberror SchemaViolation {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// 8. Errors E3 feature error for a valid digital-signature element or
/// attribute that this build recognizes but cannot process yet.
pub suberror UnsupportedFeature {
  UnsupportedFeature(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// 8. Errors E4 resolver error for a relationship target or signature
/// resource that the surrounding OPC package cannot supply.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// Enforce the 8. Errors E3 capability check for a known digital-signature
/// feature that is outside the current build.
fn require_supported_feature(
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
/// Enforce the §5 Inputs I3 package-level resource resolver contract delegated
/// to ecma376/opc. Missing relationship targets and signature resources are
/// reported with 8. Errors E4 ResourceMissing.
fn require_resource(
  available : Bool,
  section~ : String,
  path~ : String,
  target~ : String,
) -> Unit raise ResourceMissing {
  if !available {
    raise ResourceMissing(section~, path~, target~)
  }
}
