///|
/// ECMA-376 Part 2 OPC part payload implementation for Core Properties and
/// Thumbnails.
///
/// SDD package: ecma376/opc/part. Implementation package:
/// src/ecma376/opc/part. The contract below names section numbers, schema
/// identifiers, target namespaces, elements, complex types, and the API
/// obligations used by drift alignment; normative prose remains outside this
/// source file.
///
/// - §1 Scope: ECMA-376 Part 2 §8 Core Properties part and §9 Thumbnails part.
///   This package owns 9 ECMA-376 section(s) and 1 schema bundle(s):
///   opc-coreProperties.xsd.
/// - §2 Conformance C1: read_core_properties, read_thumbnail_part, read_part,
///   PartName::parse, PackagePart::new, and related read_* entry points accept
///   every §4 schema element where permitted by opc-coreProperties.xsd.
/// - §2 Conformance C2: readers raise SchemaViolation when occurrence,
///   cardinality, type, required-attribute, root-name, or child-shape
///   structure fails.
/// - §2 Conformance C3: writer round trips preserve attributes declared on
///   parsed elements and retain child order for interpreted content.
/// - §2 Conformance C4: there are no §4 simple types in this schema; package
///   constructors still enforce lexical constraints for part names and typed
///   values before building the domain tree.
/// - §2 Conformance C5: SchemaViolation carries section + path metadata using
///   the §3 section references for the failing OPC part location.
/// - §3 TOC: §8 Core Properties, §8.1 General, §8.2 Core Properties Part,
///   §8.3 Core Properties Markup, §8.3.1 General (markup overview),
///   §8.3.2 Support For Versioning And Extensibility, §8.3.3 coreProperties
///   element, §8.3.4 Core Property Elements, §9 Thumbnails.
/// - §4 Schema: opc-coreProperties.xsd targets
///   http://schemas.openxmlformats.org/package/2006/metadata/core-properties.
///   It exports top-level element coreProperties, complex types
///   CT_CoreProperties, CT_Keyword, and CT_Keywords, and no simple types.
/// - §5 Inputs I1: XML byte streams enter through read_* functions.
/// - §5 Inputs I2: namespace context is resolved against the core-properties
///   target namespace.
/// - §5 Inputs I3: package resource resolution is delegated to ecma376/opc via
///   require_resource.
/// - §6 Outputs O1: typed domain value tree for every §4 element and
///   attribute represented by PartName, PackagePart, CoreProperties,
///   CoreKeyword, CoreKeywords, and ThumbnailPart.
/// - §6 Outputs O2: XML byte stream that re-validates against
///   opc-coreProperties.xsd from write_core_properties and
///   write_thumbnail_part.
/// - §7 Invariants V1: foreign package elements are not parsed inline; cross
///   package references go through the owning package API.
/// - §7 Invariants V2: writer functions emit complex-type children in
///   sequence/choice/all schema order and do not silently reorder children.
/// - §7 Invariants V3: constructors normalise and materialise validated values
///   so consumers receive populated domain structures.
/// - §8 Errors E1: XmlMalformed from @xml for malformed XML.
/// - §8 Errors E2: SchemaViolation for schema, cardinality, and type failures.
/// - §8 Errors E3: UnsupportedFeature for recognised unsupported features.
/// - §8 Errors E4: ResourceMissing for missing OPC resources.
/// - §9 Drift hooks: coverage.json represents the §3 sections and §4
///   identifiers; alignment is measured against this public API doc and the
///   package domain types.
///
/// Return the implementation package identifier for ecma376/opc/part.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/part"
}
