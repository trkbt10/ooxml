///|
/// ECMA-376 Part 1 §22.9 shared common simple types.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
///
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target
/// namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier
/// counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0,
/// groups=0.
///
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage,
/// ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage,
/// ST_PositiveFixedPercentage, ST_PositivePercentage,
/// ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure,
/// ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun,
/// ST_XAlign, ST_XmlName, ST_Xstring, and ST_YAlign.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/simple_types"
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_Guid`. Base:
/// `xsd:token`.  Lexical form: `{HHHHHHHH-HHHH-HHHH-HHHH-HHHHHHHHHHHH}`
/// with uppercase hex.  See `ST_Guid::new` / `ST_Guid::parse` in
/// `types.mbt`.
pub fn simple_types_xsd_st_guid_schema_name() -> String {
  "Schema shared-commonSimpleTypes.xsd simple type `ST_Guid`. Base: `xsd:token`."
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_Lang`. Base:
/// `xsd:string`.  Language code per RFC 4646 / BCP 47.
pub fn simple_types_xsd_st_lang_schema_name() -> String {
  "Schema shared-commonSimpleTypes.xsd simple type `ST_Lang`. Base: `xsd:string`."
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type `ST_XAlign`. Base:
/// `xsd:string`. Enumeration values: `left`, `center`, `right`,
/// `inside`, `outside`.
pub fn simple_types_xsd_st_xalign_schema_name() -> String {
  "Schema shared-commonSimpleTypes.xsd simple type `ST_XAlign`. Base: `xsd:string`. Enumeration values: `left`, `center`, `right`, `inside`, `outside`."
}
