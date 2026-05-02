///|
/// OPC §8 Errors E2 schema error for XML that is well-formed but violates the
/// §4 opc-coreProperties or opc-digSig schema constraints. The section, path,
/// and reason fields let callers map occurrence, cardinality, required
/// attribute, type, and enumeration failures back to the package contract.
/// Canonical type: `@opc_errors.SchemaViolation`.
///
/// Part anchor: this package owns package part names, core-properties payloads,
/// and XML validation paths for §9 package parts. Its schema paths intentionally
/// name part-local elements such as `/coreProperties/keywords`.

///|
/// OPC §8 Errors E3 feature error for a valid §4 element or attribute that
/// this build recognizes but cannot process yet. Canonical type:
/// `@opc_errors.UnsupportedFeature`.
///
/// Part anchor: unsupported-feature checks are scoped to package-part payload
/// features, including optional core-property and digital-signature content.

///|
/// OPC §8 Errors E4 resolver error for a part or relationship target that the
/// surrounding OPC package cannot supply for §5 Inputs I3 resource resolution.
/// Canonical type: `@opc_errors.ResourceMissing`.
///
/// Part anchor: resource failures preserve the local part path and the missing
/// target supplied by the OPC package resolver.
