///|
/// ECMA-376 Part 2 §10 Digital Signatures part implementation for the
/// opc-digSig schema bundle.
///
/// 1. Scope: this package owns ECMA-376 Part 2 §10 Digital Signatures XML and
/// the opc-digSig.xsd schema. It does not sign cryptographic bytes itself;
/// it models the OPC signature reference markup consumed by the surrounding
/// package layer.
///
/// 3. Specification Sections TOC coverage: owned sections are §10 Digital
/// Signatures, §10.1 General, §10.3 Choosing Content To Sign, §10.4 Digital
/// Signature Parts, §10.4.1 General, §10.4.2 Digital Signature Origin Part,
/// §10.4.3 Digital Signature Xml Signature Part, §10.4.4 Digital Signature
/// Certificate Part, §10.5 Digital Signature Markup, §10.5.1 General,
/// §10.5.2 Support For Versioning And Extensibility, §10.5.3 Signature
/// Element, §10.5.4 SignedInfo Element, §10.5.5 CanonicalizationMethod
/// Element, §10.5.6 SignatureMethod Element, §10.5.7 Reference Element,
/// §10.5.8 Transform Element, §10.5.10 RelationshipsGroupReference Element,
/// §10.5.11 DigestMethod Element, §10.5.12 Object Element, §10.5.13 Manifest
/// Element, §10.5.14 SignatureProperty Element, §10.5.15 SignatureTime
/// Element, §10.5.16 Format Element, §10.5.17 Value Element, §10.5.18 XPath
/// Element, §10.6 Relationships Transform Algorithm, §10.7 Digital Signature
/// Example, §10.8 Generating Signatures, and §10.9 Validating Signatures.
///
/// The public API honours the package SDD contract as follows:
///
/// - §1 Scope: RelationshipReference, RelationshipsGroupReference, and
///   SignatureTime model the opc-digSig XML values used by signature
///   references, relationship-group references, and signature timestamps.
/// - §2 Conformance C1: read_relationship_reference,
///   read_relationships_group_reference, and read_signature_time accept the
///   top-level elements owned by opc-digSig.xsd.
/// - §2 Conformance C2: RelationshipReference::new,
///   RelationshipsGroupReference::new, SignatureTimeFormat::new,
///   SignatureTimeValue::new, and the XML readers reject missing attributes,
///   unexpected elements, and invalid child structure through SchemaViolation.
/// - §2 Conformance C3: the writer functions preserve the required attributes
///   and child values when converting typed values back to XML.
/// - §2 Conformance C4: SignatureTimeFormat::new and
///   SignatureTimeValue::new enforce ST_Format and ST_Value lexical forms.
/// - §2 Conformance C5: SchemaViolation carries the §10 section and local
///   element or attribute path for diagnostics.
/// - 9. Drift Measurement Hooks: coverage.json is represented by the public
///   domain symbols named below, the read/write entry points, and the
///   package_name overview.
/// - §5 Inputs I1: XML byte streams enter through the read_* functions.
/// - §5 Inputs I2: digital_signature_ns supplies the namespace context for
///   http://schemas.openxmlformats.org/package/2006/digital-signature.
/// - §5 Inputs I3: require_resource records missing signature resources that
///   the surrounding OPC package resolver could not supply.
/// - §6 Outputs O1: public domain values expose typed relationship references,
///   relationship-group references, SignatureTime, ST_Format, and ST_Value.
/// - §6 Outputs O2: write_relationship_reference,
///   write_relationships_group_reference, and write_signature_time emit
///   schema-valid XML byte streams for the typed values.
/// - 7. Invariants V1: XML outside opc-digSig is not parsed inline; package,
///   relationship, and content-type resolution stays in the OPC facade
///   packages.
/// - 7. Invariants V2: SignatureTime is written in CT_SignatureTime child order
///   with Format before Value.
/// - 7. Invariants V3: constructors validate and normalise populated domain
///   values before consumers receive them.
/// - §8 Errors E1: XmlMalformed is raised by @xml for invalid XML bytes.
/// - §8 Errors E2: SchemaViolation reports schema, cardinality, required
///   attribute, type, and pattern failures.
/// - §8 Errors E3: UnsupportedFeature reports a recognised digital-signature
///   construct outside the current implementation.
/// - §8 Errors E4: ResourceMissing reports signature relationships or parts
///   that the OPC resolver cannot supply.
///
/// Schema bundle opc-digSig.xsd has target namespace
/// http://schemas.openxmlformats.org/package/2006/digital-signature. Its
/// top-level elements are RelationshipReference,
/// RelationshipsGroupReference, and SignatureTime; its complex types are
/// CT_RelationshipReference, CT_RelationshipsGroupReference, and
/// CT_SignatureTime; its simple types are ST_Format and ST_Value.
///
/// Return the implementation package identifier for
/// ecma376/opc/digital_signatures.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/digital_signatures"
}
