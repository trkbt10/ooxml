///|
/// ECMA-376 Part 2 §10 Digital Signatures package overview for opc-digSig.xsd.
///
/// §1 Scope is ECMA-376 Part 2 §10 Digital Signatures and the opc-digSig
/// schema bundle. This package owns the markup shell for OPC digital
/// signatures; cryptographic providers and package resource resolution stay
/// outside this package.
///
/// §2 Conformance C1 is represented by readers for the three opc-digSig
/// top-level elements and the W3C XML-Signature elements referenced by §10.5.
/// C2 is represented by SchemaViolation from constructors and readers. C3 is
/// represented by writers preserving parsed attributes and child nodes. C4 is
/// represented by ST_Format::new and ST_Value::new lexical checks. C5 is
/// represented by section-bearing SchemaViolation, UnsupportedFeature, and
/// ResourceMissing errors.
///
/// §3 Specification Sections: §10 Digital Signatures is represented by
/// package_name and digital_signature_ns. §10.1 General defines the digital
/// signatures package role: an OPC package can carry XML digital signature
/// markup while cryptographic policy and resource resolution stay in the
/// surrounding OPC layer. §10.3 Choosing Content To Sign defines the content
/// selection contract: RelationshipReference and RelationshipsGroupReference
/// name the package relationship material selected for signing, and XML-
/// Signature Reference/Transform children preserve any selected content
/// filters. §10.4.1 General defines the digital signature parts contract:
/// origin, XML signature, and certificate parts are modeled as package parts
/// whose local markup is exposed by this domain and reader/writer API.
/// §10.4.2 Digital Signature Origin Part, §10.4.3 Digital Signature Xml
/// Signature Part, and §10.4.4 Digital Signature Certificate Part are package
/// part contracts surfaced through the domain and reader/writer API.
/// §10.5.1 General defines the digital signature markup contract for
/// opc-digSig and imported XML-Signature elements handled by this package.
/// §10.5.2 Support For Versioning And Extensibility defines the extension
/// contract: Markup Compatibility namespaced attributes and unknown extension
/// elements are preserved through child @xml.Node arrays while the dedicated
/// markup-compatibility package owns MC processing rules. §10.5.3 Signature
/// Element is Signature,
/// read_signature, and write_signature. §10.5.4 SignedInfo Element is
/// SignedInfo, read_signed_info, and write_signed_info. §10.5.5
/// CanonicalizationMethod Element is CanonicalizationMethod,
/// read_canonicalization_method, and write_canonicalization_method. §10.5.6
/// SignatureMethod Element is SignatureMethod, read_signature_method, and
/// write_signature_method. §10.5.7 Reference Element is Reference,
/// read_reference, and write_reference. §10.5.8 Transform Element is Transform,
/// read_transform, and write_transform. §10.5.10 RelationshipsGroupReference
/// Element is RelationshipsGroupReference, read_relationships_group_reference,
/// and write_relationships_group_reference. §10.5.11 DigestMethod Element is
/// DigestMethod, read_digest_method, and write_digest_method. §10.5.12 Object
/// Element is Object, read_object, and write_object. §10.5.13 Manifest Element
/// is Manifest, read_manifest, and write_manifest. §10.5.14 SignatureProperty
/// Element is SignatureProperty, read_signature_property, and
/// write_signature_property. §10.5.15 SignatureTime Element is SignatureTime,
/// read_signature_time, and write_signature_time. §10.5.16 Format Element is
/// ST_Format and ST_Format::to_string. §10.5.17 Value Element is ST_Value and
/// ST_Value::to_string. §10.5.18 XPath Element is XPath, read_xpath, and
/// write_xpath. §10.6 Relationships Transform Algorithm is
/// apply_relationships_transform. §10.7 Digital Signature Example is covered by
/// round-trip tests over the same markup shapes. §10.8 Generating Signatures is
/// generate_signature. §10.9 Validating Signatures is validate_signature.
///
/// §4 Schema Facts: schema opc-digSig.xsd uses namespace
/// http://schemas.openxmlformats.org/package/2006/digital-signature. XSD
/// element RelationshipReference is RelationshipReference,
/// read_relationship_reference, and write_relationship_reference. XSD element
/// RelationshipsGroupReference is RelationshipsGroupReference,
/// read_relationships_group_reference, and write_relationships_group_reference.
/// XSD element SignatureTime is SignatureTime, read_signature_time, and
/// write_signature_time. XSD complex type CT_RelationshipReference is
/// RelationshipReference. XSD complex type CT_RelationshipsGroupReference is
/// RelationshipsGroupReference. XSD complex type CT_SignatureTime is
/// SignatureTime.
///
/// XSD simple type ST_Format: opc-digSig.xsd declares the SignatureTime Format
/// lexical token that identifies the time value format used with Value;
/// ST_Format, ST_Format::new, and ST_Format::to_string own that token in this
/// package.
///
/// XSD simple type ST_Value is ST_Value, ST_Value::new, and
/// ST_Value::to_string.
///
/// §5 Inputs I1 are XML byte streams passed to read_* functions. I2 is the
/// namespace context checked by digital_signature_ns and the XML-Signature
/// namespace readers. I3 is the package-level resolver contract reported with
/// ResourceMissing when the surrounding OPC layer cannot supply a referenced
/// signature resource.
///
/// §6 Outputs O1 are typed domain values: RelationshipReference,
/// RelationshipsGroupReference, SignatureTime, Signature, SignedInfo,
/// CanonicalizationMethod, SignatureMethod, Reference, Transform, DigestMethod,
/// Object, Manifest, SignatureProperty, XPath, ST_Format, and ST_Value. O2 is
/// XML bytes from write_relationship_reference,
/// write_relationships_group_reference, write_signature_time, write_signature,
/// write_signed_info, write_canonicalization_method, write_signature_method,
/// write_reference, write_transform, write_digest_method, write_object,
/// write_manifest, write_signature_property, and write_xpath.
///
/// §7 Invariants V1 keeps foreign package elements routed through package
/// boundaries. V2 preserves schema child order and parsed XML-Signature child
/// node order. V3 exposes constructed domain values only after required
/// attributes and simple-type lexical constraints are checked.
///
/// §8 Errors E1 XmlMalformed comes from @xml parsing and is mapped to
/// SchemaViolation by the XML-Signature shell readers. E2 SchemaViolation
/// reports malformed opc-digSig structure and lexical constraints. E3
/// UnsupportedFeature is raised by apply_relationships_transform,
/// generate_signature, and validate_signature. E4 ResourceMissing is the
/// resolver error type for missing OPC signature resources.
///
/// §9 Drift Measurement Hooks are the §10 section references, schema
/// identifiers, package_name, digital_signature_ns, public domain symbols,
/// reader and writer entry points, algorithm stubs, and public error types
/// listed in this package overview.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/digital_signatures"
}
