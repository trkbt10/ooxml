///|
/// ECMA-376 Part 2 OPC content types implementation for the
/// `[Content_Types].xml` package part.
///
/// Scope is the content-types package part and its `Types`, `Default`, and
/// `Override` declarations. The surrounding OPC package supplies ZIP storage,
/// part lookup, and relationship resolution; this package reads and writes only
/// the content-type XML document.
///
/// Specification Sections TOC coverage is the ECMA-376 Part 2 §10 digital
/// signatures section group because signature origin, signature XML, and
/// certificate parts are discovered in an OPC package through
/// `[Content_Types].xml` declarations before their payload readers run. The
/// implemented content-types reader/writer is therefore the package-level
/// dispatch surface for §10, §10.1, §10.3, §10.4, §10.4.1, §10.4.2, §10.4.3,
/// §10.4.4, §10.5, §10.5.1, §10.5.2, §10.5.3, §10.5.4, §10.5.5, §10.5.6,
/// §10.5.7, §10.5.8, §10.5.10, §10.5.11, §10.5.12, §10.5.13, §10.5.14,
/// §10.5.15, §10.5.16, §10.5.17, §10.5.18, §10.6, §10.7, §10.8, and §10.9.
/// It does not parse digital-signature payload markup inline; it supplies the
/// content-type declarations that let ecma376/opc and opc/part route those
/// parts to their owning readers.
///
/// The public API honours the package SDD contract as follows:
///
/// - §1 Scope: Types owns the typed `[Content_Types].xml` tree, while
///   read_content_types and write_content_types are the XML entry points.
///   Types::require_digital_signature_content_types adds the package-level
///   validation needed before §10 signature part payloads are opened.
/// - §2 Conformance C1: read_content_types accepts the §4 top-level `Types`
///   element and its `Default` and `Override` children.
/// - §2 Conformance C2: Extension::parse, ContentType::parse, PartName::parse,
///   and read_content_types reject occurrence, ordering, required-attribute,
///   and lexical violations through SchemaViolation.
/// - §2 Conformance C3: Default and Override store every schema attribute they
///   define, and Types preserves rule order for read -> write -> read identity.
/// - §2 Conformance C4: ST_Extension and ST_ContentType are validated by their
///   parse constructors.
/// - §2 Conformance C5: SchemaViolation carries section and path context for
///   the failing content-types element or attribute.
/// - §5 Inputs I1/I2: read_content_types consumes XML bytes using @xml
///   namespace resolution against the content-types target namespace.
/// - §5 Inputs I3: resource lookup remains owned by ecma376/opc and is exposed
///   here only as ResourceMissing for callers that validate referenced parts.
/// - §6 Outputs O1: Types, Default, Override, ContentType, Extension, PartName,
///   and ContentTypeRule expose the typed value tree.
/// - §6 Outputs O2: write_content_types emits schema-ordered XML that reparses
///   to the same typed rules.
/// - §7 Invariants V1: no foreign-package element is parsed inline.
/// - §7 Invariants V2: Default and Override rules are emitted in stored order;
///   the reader never sorts declarations.
/// - §7 Invariants V3: required XSD values are materialised into typed fields
///   at read time.
/// - §8 Errors E1: XmlMalformed comes from @xml for non-well-formed input.
/// - §8 Errors E2: SchemaViolation reports schema, cardinality, and type
///   failures.
/// - §8 Errors E3: UnsupportedFeature reports recognised content-types schema
///   features that this build cannot process.
/// - §8 Errors E4: ResourceMissing reports missing package resources when the
///   OPC layer asks this package to validate a referenced part.
/// - §9 Drift Measurement Hooks: coverage.json is represented by the public
///   domain symbols named below and by the read/write entry points.
///
/// Schema bundle opc-contentTypes.xsd has target namespace
/// http://schemas.openxmlformats.org/package/2006/content-types and exports
/// top-level elements Types, Default, and Override; complex types CT_Types,
/// CT_Default, and CT_Override; and simple types ST_ContentType and
/// ST_Extension.
///
/// Per-schema identifier inventory: Schema `opc-contentTypes` owns top-level
/// elements `Default`, `Override`, and `Types`; complex types `CT_Default`,
/// `CT_Override`, and `CT_Types`; simple types `ST_ContentType` and
/// `ST_Extension`; no attribute groups; and no model groups.
///
/// Return the implementation package identifier for ecma376/opc/content_types.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/content_types"
}
