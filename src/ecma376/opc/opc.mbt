///|
/// ECMA-376 Part 2 OPC facade over abstract and physical package models.
///
/// SDD package: ecma376/opc. Implementation package: src/ecma376/opc.
/// Specification source: ECMA-376, with identifiers, section numbers, section
/// titles, and implementation contract tracked in coverage.json.
///
/// - §1 Scope: OPC abstract + physical package model facade over zip,
///   content_types, relationships, part, and digital_signatures sub-packages.
///   This package owns Part 2 §6-§7, 30 ECMA-376 sections, and no schema bundle
///   of its own.
/// - §2 Conformance C1-C5: schema acceptance, structural rejection, attribute
///   preservation, lexical checks, and section/path errors are delegated to the
///   sub-packages; Package::open and Package::save enforce the facade contract
///   by composing those readers, writers, constructors, and ResourceMissing
///   checks.
/// - §3 TOC coverage, Part 2: §6 Abstract Package Model; §6.1 General; §6.2
///   Parts; §6.2.1 General; §6.2.2 Part Names; §6.2.4 Growth Hint; §6.2.5 Xml
///   Usage; §6.3.1 General; §6.3.2 Pack Scheme; §6.3.3 Resolving A Pack Iri To
///   A Resource; §6.3.4 Composing A Pack Iri; §6.3.5 Equivalence; §6.4
///   Resolving Relative References; §6.4.1 General; §6.4.2 Base Iris; §6.4.3
///   Examples; §6.5 Relationships; §7 Physical Package Model; §7.1 General;
///   §7.2.1 Using Features Of Physical Formats for generic ZIP features;
///   §7.2.2 Mapped Components determining which ZIP items hold OPC parts;
///   §7.2.3 Mapping Media Types To Parts; §7.2.4 Interleaving; §7.2.5 Mapping
///   Part Names To Physical Package Item Names; §7.3 Mapping To A Zip File;
///   §7.3.1 General; §7.3.2 Mapping Part Data; §7.3.3 Zip Item Names; §7.3.6
///   Zip Package Limitations; §7.3.7 Mapping The Media Types Stream for
///   `[Content_Types].xml`; §7.3.8 Mapping The Growth Hint.
/// - §3 Facade anchors: §6.3.3 Resolving A Pack Iri To A Resource is exposed
///   by Package::part(name); §7.3 Mapping To A Zip File is exposed by
///   Package::open(bytes) and Package::save(); §7.3.3 Zip Item Names is
///   implemented by PartName::zip_item_name in opc/part and by the facade ZIP
///   name mapping; §7.3.7 Mapping The Media Types Stream is the
///   `[Content_Types].xml` read/write path delegated to content_types.
/// - §4 Schema: none directly; content_types, relationships, part, and
///   digital_signatures own their schema bundles.
/// - §5 Inputs I1: this facade consumes no XML byte streams directly; ZIP byte
///   stream input for §7.3 enters through Package::open.
/// - §5 Inputs I2: content_types, relationships, part, and digital_signatures
///   supply XML namespace and schema contracts through their public APIs.
/// - §5 Inputs I3: resource resolution is performed by the package part table
///   and require_resource-style checks.
/// - §6 Outputs: this facade produces no XML byte streams directly; Package
///   read/save round-trip is represented by Package::open, Package::save,
///   Package, and PackagePart.
/// - §7 Invariants V1: no element defined by another package is parsed inline;
///   foreign ML payloads remain bytes and cross-package elements go through
///   sub-package reader/builder APIs.
/// - §7 Invariants V2: complex-type ordering follows the owning schema package;
///   this facade preserves ZIP entries, content-types rules, and relationships
///   in deterministic order.
/// - §7 Invariants V3: defaults declared by schema-owning packages, including
///   relationship TargetMode, are materialised before consumers observe the
///   opened Package.
/// - §8 Errors: this facade owns no schema error type; XmlMalformed,
///   SchemaViolation, and ResourceMissing are delegated from sub-packages, and
///   ZIP errors come from @zip.
/// - §9 Drift hooks: coverage.json represents §6 and §7 section headings;
///   alignment is measured against Package, PackagePart, PackUri, open/save,
///   and delegated facade APIs.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/opc"
}
