///|
/// ECMA-376 Part 2 OPC parts implementation for coreProperties,
/// digital-signature reference parts, and the §9 Thumbnail image part.
///
/// Scope is intentionally narrow: this package implements part payloads, not
/// the package container or relationship graph. Specification Sections TOC
/// coverage is the single owned Part 2 section, §9 Thumbnails, plus the two
/// OPC schemas listed below.
///
/// Conformance is enforced by public constructors, readers, writers, and error
/// types. C1 is the accepted schema-element surface, C2 is structural
/// rejection for occurrence/cardinality/type failures, C3 is read/write
/// attribute preservation, C4 is simple-type lexical rejection, and C5 is the
/// section/path metadata carried on SchemaViolation.
///
/// The public API honours the package SDD contract as follows:
///
/// - §1 Scope: this package owns OPC part payloads below the package and
///   relationship layers, including core properties XML, digital-signature XML,
///   and thumbnail binary parts.
/// - §2 Conformance C1: read_core_properties, read_relationship_reference,
///   read_relationships_group_reference, and read_signature_time accept the
///   top-level elements exported by the owned schemas.
/// - §2 Conformance C2: PartName::parse, PackagePart::new, and the XML readers
///   reject structural violations through SchemaViolation.
/// - §2 Conformance C3: CoreProperties stores the parsed @xml.Document, while
///   the writer functions preserve recognised attributes and children across a
///   read -> write round trip.
/// - §2 Conformance C4: SignatureTimeFormat::new and SignatureTimeValue::new
///   enforce the ST_Format and ST_Value lexical constraints.
/// - §2 Conformance C5: SchemaViolation carries the originating section and
///   local element or attribute path.
/// - §5 Inputs I1: XML byte streams enter through the read_* functions.
/// - §5 Inputs I2: namespace context is resolved against the core-properties
///   and digital-signature target namespaces by the XML readers.
/// - §5 Inputs I3: package resource resolution is delegated to ecma376/opc and
///   reported here with require_resource when a target is missing.
/// - §6 Outputs O1: public domain values expose the typed tree for part names,
///   coreProperties, RelationshipReference, RelationshipsGroupReference,
///   SignatureTime, and ThumbnailPart.
/// - §6 Outputs O2: write_core_properties, write_relationship_reference,
///   write_relationships_group_reference, write_signature_time, and
///   write_thumbnail_part return round-trip byte streams.
/// - §7 Invariants V1: foreign package elements are not parsed inline; callers
///   use the surrounding package APIs for cross-package references.
/// - §7 Invariants V2: writer functions emit complex-type children in schema
///   order and do not silently reorder parsed XML.
/// - §7 Invariants V3: constructors normalise validated values so consumers see
///   populated domain structures after read time.
/// - §8 Errors E1: XmlMalformed is raised by @xml when the XML byte stream is
///   not well-formed.
/// - §8 Errors E2: SchemaViolation reports schema, cardinality, required
///   attribute, type, and enumeration failures.
/// - §8 Errors E3: UnsupportedFeature reports recognised schema features that
///   this build cannot process.
/// - §8 Errors E4: ResourceMissing reports relationship or part targets the OPC
///   resolver cannot supply.
///
/// Schema bundle opc-coreProperties.xsd has target namespace
/// http://schemas.openxmlformats.org/package/2006/metadata/core-properties and
/// exports the coreProperties element with CT_CoreProperties, CT_Keyword, and
/// CT_Keywords.
///
/// Schema bundle opc-digSig.xsd has target namespace
/// http://schemas.openxmlformats.org/package/2006/digital-signature and exports
/// the RelationshipReference, RelationshipsGroupReference, and SignatureTime
/// elements with CT_RelationshipReference, CT_RelationshipsGroupReference,
/// CT_SignatureTime, ST_Format, and ST_Value.
///
/// Return the implementation package identifier for ecma376/opc/part.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/part"
}
