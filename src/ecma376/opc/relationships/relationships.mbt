///|
/// ECMA-376 OPC relationships implementation for `.rels` parts.
///
/// Scope is the relationships package part and its `Relationships` root with
/// child `Relationship` entries. The public API maps to the package SDD:
/// §1 Scope is represented by Relationships plus read_relationships and
/// write_relationships; §2 Conformance C1-C5 is enforced by the reader,
/// constructors, ST_TargetMode parser, and SchemaViolation paths; §4 Schema
/// Facts are represented by top-level elements Relationship and Relationships,
/// complex types CT_Relationship and CT_Relationships, and simple type
/// ST_TargetMode in the
/// http://schemas.openxmlformats.org/package/2006/relationships namespace;
/// §5 Inputs I1/I2 are XML bytes and namespace-resolved names; §5 I3 remains
/// owned by ecma376/opc and reports ResourceMissing through require_resource;
/// §6 Outputs O1/O2 are the typed domain tree and round-trip XML writer; §7
/// Invariants V1-V3 keep targets as references, preserve relationship order,
/// and materialise TargetMode="Internal" when omitted; §8 Errors E1-E4 are
/// XmlMalformed from @xml, SchemaViolation, UnsupportedFeature, and
/// ResourceMissing; §9 Drift Measurement Hooks are backed by coverage.json and
/// the public symbols listed here.
///
/// Schema bundle opc-relationships.xsd exports top-level elements
/// Relationship and Relationships, complex types CT_Relationship and
/// CT_Relationships, simple type ST_TargetMode, and enumeration members
/// Internal and External.
///
/// Return the implementation package identifier for ecma376/opc/relationships.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/relationships"
}
