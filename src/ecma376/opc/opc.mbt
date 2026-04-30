///|
/// ECMA-376 Part 2 Open Packaging Conventions facade over ZIP,
/// `[Content_Types].xml`, package parts, and `.rels` relationship parts.
///
/// Package::open implements the reader -> context step for OPC. It parses the
/// ZIP physical package (§7.3), reads the media types stream
/// `[Content_Types].xml` (§7.3.7), records package and part data (§6.2),
/// reads relationship parts (§6.5.2/§6.5.3), and validates that internal
/// relationship targets resolve through the package resource table (§6.4).
/// Package::save emits a ZIP archive from the stored parts and regenerated
/// content-types and relationships XML. Package::part and
/// Package::relationships are the public accessors used by format facades.
///
/// The public API maps to the SDD clauses as follows: §1 Scope is Package and
/// PackagePart; §2 Conformance C1-C5 is delegated to content_types and
/// relationships readers plus ResourceMissing for unresolved targets; §3 TOC
/// coverage is the OPC package model, ZIP mapping, parts, relationships, core
/// properties, and format part-summary sections routed through this facade; §4
/// Schema Facts has no top-level schema in this package; §5 Inputs are package
/// bytes and resource resolution; §6 Outputs are typed Package values and ZIP
/// bytes; §7 Invariants keep foreign ML payloads as bytes, preserve entry
/// order, and materialise relationship target mode defaults through the
/// relationships package; §8 Errors are XmlMalformed/ZipMalformed from
/// dependencies, SchemaViolation, UnsupportedFeature, and ResourceMissing; §9
/// Drift Measurement Hooks are represented by these public symbols and
/// coverage.json.
///
/// Return the implementation package identifier for ecma376/opc.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc"
}
