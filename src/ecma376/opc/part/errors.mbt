///|
/// OPC §8 E2 schema error for XML that is well-formed but violates the
/// §4 opc-coreProperties or opc-digSig schema constraints.
pub suberror SchemaViolation {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC §8 E3 feature error for a valid §4 element or attribute that this
/// build recognizes but cannot process yet.
pub suberror UnsupportedFeature {
  UnsupportedFeature(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC §8 E4 resolver error for a part or relationship target that the
/// surrounding OPC package cannot supply.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// Enforce an OPC §8 Errors E3 capability check for a §4 feature known by this
/// package but not supported by the current build; callers receive the
/// originating section and local element or attribute path.
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
/// Enforce an OPC §8 Errors E4 resolver check for a relationship target that
/// should have been supplied by the surrounding OPC package.
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
