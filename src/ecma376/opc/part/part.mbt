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
/// - §2 Conformance C2: readers raise @opc_errors.SchemaViolation when occurrence,
///   cardinality, type, required-attribute, root-name, or child-shape
///   structure fails.
/// - §2 Conformance C3: writer round trips preserve attributes declared on
///   parsed elements and retain child order for interpreted content.
/// - §2 Conformance C4: there are no §4 simple types in this schema; package
///   constructors still enforce lexical constraints for part names and typed
///   values before building the domain tree.
/// - §2 Conformance C5: @opc_errors.SchemaViolation carries section + path metadata using
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
///   attribute represented by PartName, PackagePart, CT_CoreProperties,
///   CT_Keyword, CT_Keywords, and ThumbnailPart.
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
/// - §8 Errors E2: @opc_errors.SchemaViolation for schema, cardinality, and type failures.
/// - §8 Errors E3: @opc_errors.UnsupportedFeature for recognised unsupported features.
/// - §8 Errors E4: @opc_errors.ResourceMissing for missing OPC resources.
/// - §9 Drift hooks: coverage.json represents the §3 sections and §4
///   identifiers; alignment is measured against this public API doc and the
///   package domain types.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc/part"
}

///|
/// ECMA-376 Part 2 §8.1 General
pub fn opc_part_part2_8_1_general_section_name() -> String {
  "ECMA-376 Part 2 §8.1 General"
}

///|
/// ECMA-376 Part 4 §13.1 General
pub fn opc_part_part4_13_1_general_section_name() -> String {
  "ECMA-376 Part 4 §13.1 General"
}

///|
/// ECMA-376 Part 4 §13.2 Part Summary Part 1 15 2
pub fn opc_part_part4_13_2_part_summary_part_1_15_2_section_name() -> String {
  "ECMA-376 Part 4 §13.2 Part Summary Part 1 15 2"
}

///|
/// ECMA-376 Part 4 §13.2.2 Audio Part Part 1 15 2 2
pub fn opc_part_part4_13_2_2_audio_part_part_1_15_2_2_section_name() -> String {
  "ECMA-376 Part 4 §13.2.2 Audio Part Part 1 15 2 2"
}

///|
/// ECMA-376 Part 4 §13.2.4 Content Part Part 1 15 2 4
pub fn opc_part_part4_13_2_4_content_part_part_1_15_2_4_section_name() -> String {
  "ECMA-376 Part 4 §13.2.4 Content Part Part 1 15 2 4"
}

///|
/// ECMA-376 Part 4 §13.2.7 Embedded Control Persistence Part Part 1 15 2 9
pub fn opc_part_part4_13_2_7_embedded_control_persistence_part_part_1_15_2_9_section_name() -> String {
  "ECMA-376 Part 4 §13.2.7 Embedded Control Persistence Part Part 1 15 2 9"
}

///|
/// ECMA-376 Part 4 §13.2.8 Embedded Object Part Part 1 15 2 10
pub fn opc_part_part4_13_2_8_embedded_object_part_part_1_15_2_10_section_name() -> String {
  "ECMA-376 Part 4 §13.2.8 Embedded Object Part Part 1 15 2 10"
}

///|
/// ECMA-376 Part 4 §13.2.11 Custom File Properties Part Part 1 15 2 12 2
pub fn opc_part_part4_13_2_11_custom_file_properties_part_part_1_15_2_12_2_section_name() -> String {
  "ECMA-376 Part 4 §13.2.11 Custom File Properties Part Part 1 15 2 12 2"
}

///|
/// ECMA-376 Part 4 §13.2.15 Printer Settings Part Part 1 15 2 15
pub fn opc_part_part4_13_2_15_printer_settings_part_part_1_15_2_15_section_name() -> String {
  "ECMA-376 Part 4 §13.2.15 Printer Settings Part Part 1 15 2 15"
}

///|
/// ECMA-376 Part 2 §8.3.2 Support For Versioning And Extensibility.
/// Source:
/// `references/spec/part2/sections/8.3.2__support-for-versioning-and-extensibility.md`.
/// Owned by `src/ecma376/opc/part`.
pub fn opc_part_part2_8_3_2_support_for_versioning_and_extensibility_section_name() -> String {
  "ECMA-376 Part 2 §8.3.2 Support For Versioning And Extensibility"
}
