///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_Lang, an xsd:string
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// language tag value in the sharedTypes namespace.
pub struct ST_Lang {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_Lang and carry SchemaViolation context for this simple type.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_Lang::new(s : String) -> ST_Lang raise SchemaViolation {
  validate_xsd_string("ST_Lang", s)
  { value: s }
}

///|
/// Return the lexical ST_Lang simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_Lang::to_string(self : ST_Lang) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_HexColorRGB, exactly
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// three bytes represented as six hex digits.
pub struct ST_HexColorRGB {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_HexColorRGB and enforce its hexBinary length constraint.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_HexColorRGB::new(s : String) -> ST_HexColorRGB raise SchemaViolation {
  if !fixed_hex(s, 6) {
    violation("ST_HexColorRGB", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_HexColorRGB simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_HexColorRGB::to_string(self : ST_HexColorRGB) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_Panose, exactly ten bytes
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// represented as twenty hex digits.
pub struct ST_Panose {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_Panose and enforce its hexBinary length constraint.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_Panose::new(s : String) -> ST_Panose raise SchemaViolation {
  if !fixed_hex(s, 20) {
    violation("ST_Panose", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_Panose simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_Panose::to_string(self : ST_Panose) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_CalendarType,
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// calendar-system enumeration.
pub(all) enum ST_CalendarType {
  Gregorian
  GregorianUs
  GregorianMeFrench
  GregorianArabic
  Hijri
  Hebrew
  Taiwan
  Japan
  Thai
  Korea
  Saka
  GregorianXlitEnglish
  GregorianXlitFrench
  NoneCalendar
} derive(Eq, Debug)

///|
/// Construct ST_CalendarType from its schema enumeration value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_CalendarType::new(
  s : String,
) -> ST_CalendarType raise SchemaViolation {
  match s {
    "gregorian" => Gregorian
    "gregorianUs" => GregorianUs
    "gregorianMeFrench" => GregorianMeFrench
    "gregorianArabic" => GregorianArabic
    "hijri" => Hijri
    "hebrew" => Hebrew
    "taiwan" => Taiwan
    "japan" => Japan
    "thai" => Thai
    "korea" => Korea
    "saka" => Saka
    "gregorianXlitEnglish" => GregorianXlitEnglish
    "gregorianXlitFrench" => GregorianXlitFrench
    "none" => NoneCalendar
    _ => violation("ST_CalendarType", s)
  }
}

///|
/// Return the lexical ST_CalendarType simple-type enumeration member.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_CalendarType::to_string(self : ST_CalendarType) -> String {
  match self {
    Gregorian => "gregorian"
    GregorianUs => "gregorianUs"
    GregorianMeFrench => "gregorianMeFrench"
    GregorianArabic => "gregorianArabic"
    Hijri => "hijri"
    Hebrew => "hebrew"
    Taiwan => "taiwan"
    Japan => "japan"
    Thai => "thai"
    Korea => "korea"
    Saka => "saka"
    GregorianXlitEnglish => "gregorianXlitEnglish"
    GregorianXlitFrench => "gregorianXlitFrench"
    NoneCalendar => "none"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_Guid, a token in
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// brace-delimited hexadecimal UUID form.
pub struct ST_Guid {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_Guid and enforce its lexical pattern.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_Guid::new(s : String) -> ST_Guid raise SchemaViolation {
  if !is_guid(s) {
    violation("ST_Guid", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_Guid simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_Guid::to_string(self : ST_Guid) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_OnOff, a boolean-like
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// shared value.
pub struct ST_OnOff {
  value : Bool
} derive(Eq, Debug)

///|
/// Construct ST_OnOff from true/false, 1/0, or on/off lexical values.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_OnOff::new(s : String) -> ST_OnOff raise SchemaViolation {
  match s {
    "true" | "1" | "on" => { value: true }
    "false" | "0" | "off" => { value: false }
    _ => violation("ST_OnOff", s)
  }
}

///|
/// Return the boolean value carried by ST_OnOff.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_OnOff::to_bool(self : ST_OnOff) -> Bool {
  self.value
}

///|
/// Return the canonical lexical ST_OnOff simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_OnOff::to_string(self : ST_OnOff) -> String {
  if self.value {
    "true"
  } else {
    "false"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_String, an
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// unconstrained xsd:string shared value.
pub struct ST_String {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_String and carry SchemaViolation context for this simple type.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_String::new(s : String) -> ST_String raise SchemaViolation {
  validate_xsd_string("ST_String", s)
  { value: s }
}

///|
/// Return the lexical ST_String simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_String::to_string(self : ST_String) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_XmlName, an xsd:NCName
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// value.
pub struct ST_XmlName {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_XmlName and enforce its NCName lexical constraint.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_XmlName::new(s : String) -> ST_XmlName raise SchemaViolation {
  if !is_ncname(s) {
    violation("ST_XmlName", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_XmlName simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_XmlName::to_string(self : ST_XmlName) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_UnsignedDecimalNumber,
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// an xsd:unsignedLong decimal lexical value.
pub struct ST_UnsignedDecimalNumber {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_UnsignedDecimalNumber and enforce its unsignedLong range.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_UnsignedDecimalNumber::new(
  s : String,
) -> ST_UnsignedDecimalNumber raise SchemaViolation {
  if !is_unsigned_long(s) {
    violation("ST_UnsignedDecimalNumber", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_UnsignedDecimalNumber simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_UnsignedDecimalNumber::to_string(
  self : ST_UnsignedDecimalNumber,
) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_TwipsMeasure, either an
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// unsigned decimal number or a positive universal measure.
pub struct ST_TwipsMeasure {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_TwipsMeasure and enforce its union lexical constraint.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_TwipsMeasure::new(
  s : String,
) -> ST_TwipsMeasure raise SchemaViolation {
  if !is_unsigned_long(s) && !is_universal_measure(s, positive=true) {
    violation("ST_TwipsMeasure", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_TwipsMeasure simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_TwipsMeasure::to_string(self : ST_TwipsMeasure) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_VerticalAlignRun, run
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// vertical-alignment enumeration.
pub(all) enum ST_VerticalAlignRun {
  Baseline
  Superscript
  Subscript
} derive(Eq, Debug)

///|
/// Construct ST_VerticalAlignRun from its schema enumeration value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_VerticalAlignRun::new(
  s : String,
) -> ST_VerticalAlignRun raise SchemaViolation {
  match s {
    "baseline" => Baseline
    "superscript" => Superscript
    "subscript" => Subscript
    _ => violation("ST_VerticalAlignRun", s)
  }
}

///|
/// Return the lexical ST_VerticalAlignRun simple-type enumeration member.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_VerticalAlignRun::to_string(self : ST_VerticalAlignRun) -> String {
  match self {
    Baseline => "baseline"
    Superscript => "superscript"
    Subscript => "subscript"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_Xstring, an
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// unconstrained shared xstring value.
pub struct ST_Xstring {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_Xstring and carry SchemaViolation context for this simple type.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_Xstring::new(s : String) -> ST_Xstring raise SchemaViolation {
  validate_xsd_string("ST_Xstring", s)
  { value: s }
}

///|
/// Return the lexical ST_Xstring simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_Xstring::to_string(self : ST_Xstring) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_XAlign, horizontal
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// alignment enumeration.
pub(all) enum ST_XAlign {
  Left
  Center
  Right
  Inside
  Outside
} derive(Eq, Debug)

///|
/// Construct ST_XAlign from its schema enumeration value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_XAlign::new(s : String) -> ST_XAlign raise SchemaViolation {
  match s {
    "left" => Left
    "center" => Center
    "right" => Right
    "inside" => Inside
    "outside" => Outside
    _ => violation("ST_XAlign", s)
  }
}

///|
/// Return the lexical ST_XAlign simple-type enumeration member.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_XAlign::to_string(self : ST_XAlign) -> String {
  match self {
    Left => "left"
    Center => "center"
    Right => "right"
    Inside => "inside"
    Outside => "outside"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_YAlign, vertical
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// alignment enumeration.
pub(all) enum ST_YAlign {
  Inline
  Top
  YCenter
  Bottom
  YInside
  YOutside
} derive(Eq, Debug)

///|
/// Construct ST_YAlign from its schema enumeration value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_YAlign::new(s : String) -> ST_YAlign raise SchemaViolation {
  match s {
    "inline" => Inline
    "top" => Top
    "center" => YCenter
    "bottom" => Bottom
    "inside" => YInside
    "outside" => YOutside
    _ => violation("ST_YAlign", s)
  }
}

///|
/// Return the lexical ST_YAlign simple-type enumeration member.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_YAlign::to_string(self : ST_YAlign) -> String {
  match self {
    Inline => "inline"
    Top => "top"
    YCenter => "center"
    Bottom => "bottom"
    YInside => "inside"
    YOutside => "outside"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_ConformanceClass,
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// document conformance enumeration.
pub(all) enum ST_ConformanceClass {
  Strict
  Transitional
} derive(Eq, Debug)

///|
/// Construct ST_ConformanceClass from its schema enumeration value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_ConformanceClass::new(
  s : String,
) -> ST_ConformanceClass raise SchemaViolation {
  match s {
    "strict" => Strict
    "transitional" => Transitional
    _ => violation("ST_ConformanceClass", s)
  }
}

///|
/// Return the lexical ST_ConformanceClass simple-type enumeration member.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_ConformanceClass::to_string(self : ST_ConformanceClass) -> String {
  match self {
    Strict => "strict"
    Transitional => "transitional"
  }
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_UniversalMeasure, signed
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// decimal measure with a fixed unit suffix.
pub struct ST_UniversalMeasure {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_UniversalMeasure and enforce its lexical pattern.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_UniversalMeasure::new(
  s : String,
) -> ST_UniversalMeasure raise SchemaViolation {
  if !is_universal_measure(s, positive=false) {
    violation("ST_UniversalMeasure", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_UniversalMeasure simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_UniversalMeasure::to_string(self : ST_UniversalMeasure) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_PositiveUniversalMeasure,
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// non-negative universal measure.
pub struct ST_PositiveUniversalMeasure {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_PositiveUniversalMeasure and enforce its non-negative range.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_PositiveUniversalMeasure::new(
  s : String,
) -> ST_PositiveUniversalMeasure raise SchemaViolation {
  if !is_universal_measure(s, positive=true) {
    violation("ST_PositiveUniversalMeasure", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_PositiveUniversalMeasure simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_PositiveUniversalMeasure::to_string(
  self : ST_PositiveUniversalMeasure,
) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_Percentage, signed
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// decimal percentage.
pub struct ST_Percentage {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_Percentage and enforce its lexical pattern.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_Percentage::new(s : String) -> ST_Percentage raise SchemaViolation {
  if !is_percentage(s, positive=false, fixed=false) {
    violation("ST_Percentage", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_Percentage simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_Percentage::to_string(self : ST_Percentage) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_FixedPercentage, signed
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// percentage in the closed range -100% to 100%.
pub struct ST_FixedPercentage {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_FixedPercentage and enforce its fixed percentage range.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_FixedPercentage::new(
  s : String,
) -> ST_FixedPercentage raise SchemaViolation {
  if !is_percentage(s, positive=false, fixed=true) {
    violation("ST_FixedPercentage", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_FixedPercentage simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_FixedPercentage::to_string(self : ST_FixedPercentage) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_PositivePercentage,
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// non-negative decimal percentage.
pub struct ST_PositivePercentage {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_PositivePercentage and enforce its non-negative range.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_PositivePercentage::new(
  s : String,
) -> ST_PositivePercentage raise SchemaViolation {
  if !is_percentage(s, positive=true, fixed=false) {
    violation("ST_PositivePercentage", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_PositivePercentage simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_PositivePercentage::to_string(self : ST_PositivePercentage) -> String {
  self.value
}

///|
/// Schema shared-commonSimpleTypes.xsd simple type ST_PositiveFixedPercentage,
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: ST_CalendarType, ST_ConformanceClass, ST_FixedPercentage, ST_Guid, ST_HexColorRGB, ST_Lang, ST_OnOff, ST_Panose, ST_Percentage, ST_PositiveFixedPercentage, ST_PositivePercentage, ST_PositiveUniversalMeasure, ST_String, ST_TwipsMeasure, ST_UniversalMeasure, ST_UnsignedDecimalNumber, ST_VerticalAlignRun, ST_XAlign, ST_XmlName, ST_Xstring, ST_YAlign.
/// non-negative percentage up to 100%.
pub struct ST_PositiveFixedPercentage {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_PositiveFixedPercentage and enforce its non-negative fixed range.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Constructor raises SchemaViolation for lexical or enumeration constraints.
pub fn ST_PositiveFixedPercentage::new(
  s : String,
) -> ST_PositiveFixedPercentage raise SchemaViolation {
  if !is_percentage(s, positive=true, fixed=true) {
    violation("ST_PositiveFixedPercentage", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_PositiveFixedPercentage simple-type value.
/// Schema shared-commonSimpleTypes.xsd.
/// Bundle `strict/transitional`. Target namespace `http://purl.oclc.org/ooxml/officeDocument/sharedTypes`. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0.
/// Simple types: `ST_CalendarType`, `ST_ConformanceClass`, `ST_FixedPercentage`, `ST_Guid`, `ST_HexColorRGB`, `ST_Lang`, `ST_OnOff`, `ST_Panose`, `ST_Percentage`, `ST_PositiveFixedPercentage`, `ST_PositivePercentage`, `ST_PositiveUniversalMeasure`, `ST_String`, `ST_TwipsMeasure`, `ST_UniversalMeasure`, `ST_UnsignedDecimalNumber`, `ST_VerticalAlignRun`, `ST_XAlign`, `ST_XmlName`, `ST_Xstring`, `ST_YAlign`.
/// The same data, in machine-readable form, is in `coverage.json`.
/// I1 XML byte stream of any part listed in §3, well-formed per W3C XML 1.0 (Fifth Edition). I2 a namespace context resolved against the target namespaces of §4. I3 a package-level resource resolver supplied by the surrounding OPC package (relationship targets, embedded media, theme references); the resolver contract is owned by `src/ecma376/opc`.
/// O1 a typed domain value tree exposing every element/attribute listed in §4; domain types are private to this package and consumers see only the public API in `pkg.generated.mbti`. O2 on the writer side, an XML byte stream that re-validates against the XSD schemas listed in §4 (round-trip identity for every element/attribute the reader successfully parsed).
/// V1 no element defined by another package is parsed inline; cross-package element references go through the foreign package's reader/builder API. V2 element ordering inside any complex type follows the schema's sequence/choice/all model; the implementation never silently reorders children. V3 default values declared in the XSD are materialised at read time so consumers see fully populated structures regardless of whether the source document set them explicitly.
/// E1 `SchemaViolation` — a value does not satisfy the lexical or enumeration constraint of the simple type it was constructed from. Every error carries the simple-type name and the offending input.
/// Schema shared-commonSimpleTypes.xsd. Bundle strict/transitional. Target namespace http://purl.oclc.org/ooxml/officeDocument/sharedTypes. Identifier counts: elements=0, complexTypes=0, simpleTypes=21, attributeGroups=0, groups=0. Formatter preserves the simple-type lexical value.
pub fn ST_PositiveFixedPercentage::to_string(
  self : ST_PositiveFixedPercentage,
) -> String {
  self.value
}

///|
fn[T] violation(type_name : String, value : String) -> T raise SchemaViolation {
  raise SchemaViolation(type_name~, value~)
}

///|
fn validate_xsd_string(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() < 0 {
    violation(type_name, value)
  }
}

///|
fn fixed_hex(s : String, len : Int) -> Bool {
  s.length() == len && hex_digits(s, 0, len)
}

///|
fn is_guid(s : String) -> Bool {
  s.length() == 38 &&
  s[0:1] == "{" &&
  hex_digits(s, 1, 9) &&
  s[9:10] == "-" &&
  hex_digits(s, 10, 14) &&
  s[14:15] == "-" &&
  hex_digits(s, 15, 19) &&
  s[19:20] == "-" &&
  hex_digits(s, 20, 24) &&
  s[24:25] == "-" &&
  hex_digits(s, 25, 37) &&
  s[37:38] == "}"
}

///|
fn is_universal_measure(s : String, positive~ : Bool) -> Bool {
  if s.length() < 3 {
    false
  } else {
    let unit = s[s.length() - 2:].to_owned()
    let number_end = s.length() - 2
    is_measure_unit(unit) &&
    is_decimal(s, 0, number_end) &&
    (!positive || decimal_non_negative(s, 0, number_end))
  }
}

///|
fn is_measure_unit(unit : String) -> Bool {
  unit == "mm" ||
  unit == "cm" ||
  unit == "in" ||
  unit == "pt" ||
  unit == "pc" ||
  unit == "pi"
}

///|
fn is_percentage(s : String, positive~ : Bool, fixed~ : Bool) -> Bool {
  if s.length() < 2 || s[s.length() - 1:] != "%" {
    false
  } else {
    let number_end = s.length() - 1
    is_decimal(s, 0, number_end) &&
    (!positive || decimal_non_negative(s, 0, number_end)) &&
    (!fixed || decimal_abs_le_100(s, 0, number_end))
  }
}

///|
fn is_decimal(s : String, start : Int, end : Int) -> Bool {
  if start >= end {
    false
  } else {
    let mut pos = start
    if s[pos:pos + 1] == "-" {
      pos = pos + 1
    }
    let digits_start = pos
    while pos < end && is_digit_at(s, pos) {
      pos = pos + 1
    }
    let whole_digits = pos > digits_start
    if pos < end && s[pos:pos + 1] == "." {
      pos = pos + 1
      let fraction_start = pos
      while pos < end && is_digit_at(s, pos) {
        pos = pos + 1
      }
      whole_digits && pos > fraction_start && pos == end
    } else {
      whole_digits && pos == end
    }
  }
}

///|
fn decimal_non_negative(s : String, start : Int, end : Int) -> Bool {
  if s[start:start + 1] != "-" {
    true
  } else {
    decimal_is_zero(s, start + 1, end)
  }
}

///|
fn decimal_is_zero(s : String, start : Int, end : Int) -> Bool {
  let mut zero = true
  for i in start..<end {
    let ch = s[i:i + 1]
    if ch != "." && ch != "0" {
      zero = false
    }
  }
  zero
}

///|
fn decimal_abs_le_100(s : String, start : Int, end : Int) -> Bool {
  let mut pos = start
  if s[pos:pos + 1] == "-" {
    pos = pos + 1
  }
  let whole_start = pos
  while pos < end && is_digit_at(s, pos) {
    pos = pos + 1
  }
  let whole = trim_leading_zeroes(s, whole_start, pos)
  if whole.length() < 3 {
    true
  } else if whole.length() > 3 || whole != "100" {
    false
  } else if pos == end {
    true
  } else {
    decimal_is_zero(s, pos + 1, end)
  }
}

///|
fn is_unsigned_long(s : String) -> Bool {
  if s.length() == 0 || !digits(s, 0, s.length()) {
    false
  } else {
    let trimmed = trim_leading_zeroes(s, 0, s.length())
    let max = "18446744073709551615"
    trimmed.length() < max.length() ||
    (trimmed.length() == max.length() && trimmed <= max)
  }
}

///|
fn trim_leading_zeroes(s : String, start : Int, end : Int) -> String {
  let mut pos = start
  while pos < end - 1 && s[pos:pos + 1] == "0" {
    pos = pos + 1
  }
  s[pos:end].to_owned()
}

///|
fn is_ncname(s : String) -> Bool {
  if s.length() == 0 || !is_ncname_start_at(s, 0) {
    false
  } else {
    let mut ok = true
    for i in 1..<s.length() {
      ok = ok && is_ncname_char_at(s, i)
    }
    ok
  }
}

///|
fn is_ncname_start_at(s : String, index : Int) -> Bool {
  is_ascii_alpha_at(s, index) || s[index:index + 1] == "_"
}

///|
fn is_ncname_char_at(s : String, index : Int) -> Bool {
  is_ncname_start_at(s, index) ||
  is_digit_at(s, index) ||
  s[index:index + 1] == "-" ||
  s[index:index + 1] == "."
}

///|
fn digits(s : String, start : Int, end : Int) -> Bool {
  let mut ok = start >= 0 && end <= s.length() && start < end
  for i in start..<end {
    ok = ok && is_digit_at(s, i)
  }
  ok
}

///|
fn hex_digits(s : String, start : Int, end : Int) -> Bool {
  let mut ok = start >= 0 && end <= s.length() && start < end
  for i in start..<end {
    ok = ok && is_hex_at(s, i)
  }
  ok
}

///|
fn is_digit_at(s : String, index : Int) -> Bool {
  s[index:index + 1] >= "0" && s[index:index + 1] <= "9"
}

///|
fn is_ascii_alpha_at(s : String, index : Int) -> Bool {
  (s[index:index + 1] >= "A" && s[index:index + 1] <= "Z") ||
  (s[index:index + 1] >= "a" && s[index:index + 1] <= "z")
}

///|
fn is_hex_at(s : String, index : Int) -> Bool {
  is_digit_at(s, index) ||
  (s[index:index + 1] >= "A" && s[index:index + 1] <= "F") ||
  (s[index:index + 1] >= "a" && s[index:index + 1] <= "f")
}
