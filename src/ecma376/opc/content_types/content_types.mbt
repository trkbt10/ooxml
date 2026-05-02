///|
/// ECMA-376 Part 2 OPC content types implementation for `[Content_Types].xml`.
///
/// - §1 Scope: ECMA-376 Part 2 §6.2.3 Media types and the
///   `[Content_Types].xml` part. This package owns 1 ECMA-376 section and 1
///   schema bundle: opc-contentTypes.xsd.
/// - §2 Conformance C1: read_content_types accepts every §4 element where the
///   schema permits it: Types, Default, and Override.
/// - §2 Conformance C2: Extension::parse, ContentType::parse, PartName::parse,
///   and read_content_types raise @opc_errors.SchemaViolation for structural failures,
///   duplicate keys, missing required attributes, and invalid lexical values.
/// - §2 Conformance C3: Default and Override preserve their schema attributes,
///   and Types preserves rule order across read -> write round trips.
/// - §2 Conformance C4: ST_ContentType and ST_Extension constructors enforce
///   their lexical constraints.
/// - §2 Conformance C5: @opc_errors.SchemaViolation carries section + path metadata for
///   the failing content-types element or attribute.
/// - §3 TOC: §6.2.3 Media Types.
/// - §4 Schema: opc-contentTypes.xsd targets
///   http://schemas.openxmlformats.org/package/2006/content-types. Top-level
///   elements are Default, Override, and Types. Complex types are CT_Default,
///   CT_Override, and CT_Types. Simple types are ST_ContentType and
///   ST_Extension.
/// - §5 Inputs I1: XML byte streams enter through read_content_types.
/// - §5 Inputs I2: namespace context is resolved against the content-types
///   target namespace.
/// - §5 Inputs I3: package resource resolution is delegated to ecma376/opc via
///   require_resource and surfaced as @opc_errors.ResourceMissing for referenced parts.
/// - §6 Outputs O1: typed domain value tree for Types, Default, Override,
///   ContentType, Extension, PartName, and ContentTypeRule.
/// - §6 Outputs O2: XML byte stream that re-validates from write_content_types.
/// - §7 Invariants V1: foreign package elements are not parsed inline.
/// - §7 Invariants V2: writer functions emit complex-type children in schema
///   order and preserve stored Default/Override order.
/// - §7 Invariants V3: constructors normalise validated values before they
///   enter the typed tree.
/// - §8 Errors E1: XmlMalformed from @xml for malformed XML.
/// - §8 Errors E2: @opc_errors.SchemaViolation for schema, cardinality, type, and
///   required-attribute failures.
/// - §8 Errors E3: @opc_errors.UnsupportedFeature for recognised unsupported features.
/// - §8 Errors E4: @opc_errors.ResourceMissing for missing OPC resources.
/// - §9 Drift hooks: coverage.json represents the §3 section and §4
///   identifiers; alignment is measured against this public API doc and the
///   package domain types.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/content_types"
}
