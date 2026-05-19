///|
/// ECMA-376 Part 2 OPC relationships implementation for `.rels` parts.
///
/// - §1 Scope: ECMA-376 Part 2 §6.5 Relationships and ECMA-376 Part 2
///   §6.5.1 General relationship markup sections. Source anchor:
///   references/spec/part2/sections/6.5.1__general.md, owned by
///   src/ecma376/opc/relationships. This package owns 5 ECMA-376 sections and
///   2 schema bundles: opc-relationships.xsd and
///   shared-relationshipReference.xsd.
/// - §2 Conformance C1: read_relationships accepts every §4 element where the
///   schema permits it: Relationship and Relationships.
/// - §2 Conformance C2: TargetMode::parse, CT_Relationship::new,
///   CT_Relationships::new, and read_relationships raise
///   @opc_errors.SchemaViolation for structural failures, duplicate Id values,
///   missing attributes, and invalid lexical values.
/// - §2 Conformance C3: writer round trips preserve relationship attributes
///   and relationship child order.
/// - §2 Conformance C4: ST_TargetMode and ST_RelationshipId constructors
///   enforce their lexical domains.
/// - §2 Conformance C5: @opc_errors.SchemaViolation carries section + path metadata for
///   the failing relationship element or attribute.
/// - §3 TOC: §6.5 Relationships; §6.5.1 General; §6.5.2 Relationships Part;
///   §6.5.3 Relationship Markup; §6.5.4 Examples.
/// - §4 Schema: opc-relationships.xsd targets
///   http://schemas.openxmlformats.org/package/2006/relationships and exports
///   top-level elements Relationship and Relationships, complex types
///   CT_Relationship and CT_Relationships, and simple type ST_TargetMode.
///   shared-relationshipReference.xsd targets
///   http://purl.oclc.org/ooxml/officeDocument/relationships and contributes
///   simple type ST_RelationshipId.
/// - §5 Inputs I1: XML byte streams enter through read_relationships.
/// - §5 Inputs I2: namespace context is resolved against the relationships
///   target namespace and shared relationship-reference namespace.
/// - §5 Inputs I3: package resource resolution is delegated to ecma376/opc via
///   require_resource and reported as @opc_errors.ResourceMissing.
/// - §6 Outputs O1: typed domain value tree for Relationships, Relationship,
///   TargetMode, and RelationshipId.
/// - §6 Outputs O2: XML byte stream that re-validates from write_relationships.
/// - §7 Invariants V1: relationship targets remain references and foreign
///   package elements are not parsed inline.
/// - §7 Invariants V2: writer functions preserve relationship order and emit
///   complex-type children in schema order.
/// - §7 Invariants V3: TargetMode defaults are materialised as Internal and
///   constructors normalise validated values.
/// - §8 Errors E1: XmlMalformed from @xml for malformed XML.
/// - §8 Errors E2: @opc_errors.SchemaViolation for schema, cardinality, type, and
///   required-attribute failures.
/// - §8 Errors E3: @opc_errors.UnsupportedFeature for recognised unsupported features.
/// - §8 Errors E4: @opc_errors.ResourceMissing for missing OPC resources.
/// - §9 Drift hooks: coverage.json represents the §3 sections and §4
///   identifiers; alignment is measured against this public API doc and the
///   package domain types.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/relationships"
}
