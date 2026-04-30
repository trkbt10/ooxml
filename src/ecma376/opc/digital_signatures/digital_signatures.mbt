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
/// SDD 1. Scope: ECMA-376 Part 2 §10 Digital Signatures part and the
/// opc-digSig schema are represented by the package identifier, the
/// digital_signature_ns namespace helper, the typed domain values, and the XML
/// reader/builder entry points. The owned scope is the 30 ECMA-376 sections
/// listed above and the single opc-digSig schema bundle.
///
/// - §1 Scope: RelationshipReference, RelationshipsGroupReference, and
///   SignatureTime model the opc-digSig XML values used by signature
///   references, relationship-group references, and signature timestamps.
/// - §2 Conformance C1: read_relationship_reference,
///   read_relationships_group_reference, and read_signature_time accept the
///   top-level elements owned by opc-digSig.xsd.
/// - §2 Conformance C2: RelationshipReference::new,
///   RelationshipsGroupReference::new, ST_Format::new,
///   ST_Value::new, and the XML readers reject missing attributes,
///   unexpected elements, and invalid child structure through SchemaViolation.
/// - §2 Conformance C3: the writer functions preserve the required attributes
///   and child values when converting typed values back to XML.
/// - §2 Conformance C4: ST_Format::new and ST_Value::new enforce ST_Format
///   and ST_Value lexical forms.
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
///
/// SDD 6. Outputs: O1 is a typed domain value tree exposing the elements and
/// attributes listed in the opc-digSig schema: RelationshipReference,
/// RelationshipsGroupReference, SignatureTime, CT_RelationshipReference,
/// CT_RelationshipsGroupReference, CT_SignatureTime, ST_Format, and ST_Value.
/// O2 is produced by write_relationship_reference,
/// write_relationships_group_reference, and write_signature_time as an XML
/// byte stream that re-validates against opc-digSig.xsd and preserves
/// read/write round-trip identity for parsed element and attribute data.
///
/// SDD 7. Invariants: V1 keeps elements from other packages out of this parser
/// and routes cross-package references through the OPC layer; V2 keeps complex
/// type element ordering in schema sequence, including CT_SignatureTime Format
/// before Value; V3 materialises validated domain structures through
/// constructors before consumers receive them.
///
/// SDD 8. Errors: E1 XmlMalformed is raised by @xml for invalid XML bytes; E2
/// SchemaViolation reports occurrence, cardinality, required-attribute, type,
/// and enumeration or pattern failures against opc-digSig.xsd; E3
/// UnsupportedFeature identifies known §10 constructs outside this build; E4
/// ResourceMissing identifies unresolved relationship targets or signature
/// resources delegated to the surrounding OPC package resolver. Each public
/// error carries a section number and local element or attribute path when
/// known.
///
/// SDD 9. Drift Measurement Hooks: coverage.json is represented by source
/// references to the §10 sections, the schema identifiers, package_name,
/// digital_signature_ns, the public domain symbols, the read/write entry
/// points, and the error helpers. Public symbols in this package are expected
/// to trace back to those section or schema identifiers.
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
