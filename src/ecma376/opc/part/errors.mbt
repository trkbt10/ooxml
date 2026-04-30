///|
/// OPC §8 Errors E2 schema error for XML that is well-formed but violates the
/// §4 opc-coreProperties or opc-digSig schema constraints. The section, path,
/// and reason fields let callers map occurrence, cardinality, required
/// attribute, type, and enumeration failures back to the package contract.
pub suberror SchemaViolation {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC §8 Errors E3 feature error for a valid §4 element or attribute that
/// this build recognizes but cannot process yet.
pub suberror UnsupportedFeature {
  UnsupportedFeature(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// OPC §8 Errors E4 resolver error for a part or relationship target that the
/// surrounding OPC package cannot supply for §5 Inputs I3 resource resolution.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// Enforce an OPC §8 Errors E3 capability check for a §4 feature known by this
/// package but not supported by the current build. The package error surface is
/// E1 XmlMalformed from @xml, E2 SchemaViolation for XSD constraints, E3
/// UnsupportedFeature for implemented-schema gaps, and E4 ResourceMissing for
/// unresolved OPC relationship targets; callers receive the originating
/// section and local element or attribute path.
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
/// Enforce the §5 Inputs I3 package-level resource resolver contract delegated
/// to ecma376/opc. The surrounding OPC package supplies relationship targets,
/// embedded media, and theme references; this helper raises OPC §8 Errors E4
/// ResourceMissing when the resolver cannot supply the target.
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
