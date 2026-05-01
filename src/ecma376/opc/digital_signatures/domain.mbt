///|
/// 1. Scope domain value for the §10.5.9 RelationshipReference element and
/// CT_RelationshipReference from schema bundle opc-digSig.xsd in the
/// http://schemas.openxmlformats.org/package/2006/digital-signature target
/// namespace.
pub(all) struct RelationshipReference {
  source_id : String
} derive(Eq, Debug)

///|
/// Build CT_RelationshipReference, enforcing the required SourceId attribute.
fn RelationshipReference::new(
  source_id : String,
) -> RelationshipReference raise SchemaViolation {
  if source_id == "" {
    raise SchemaViolation(
      section="10",
      path="RelationshipReference/@SourceId",
      reason="SourceId must not be empty",
    )
  }
  { source_id, }
}

///|
/// 1. Scope domain value for the §10.5.10 RelationshipsGroupReference element and
/// CT_RelationshipsGroupReference from schema bundle opc-digSig.xsd in the
/// http://schemas.openxmlformats.org/package/2006/digital-signature target
/// namespace.
pub(all) struct RelationshipsGroupReference {
  source_type : String
} derive(Eq, Debug)

///|
/// Build CT_RelationshipsGroupReference, enforcing the required SourceType URI.
fn RelationshipsGroupReference::new(
  source_type : String,
) -> RelationshipsGroupReference raise SchemaViolation {
  if source_type == "" {
    raise SchemaViolation(
      section="10",
      path="RelationshipsGroupReference/@SourceType",
      reason="SourceType must not be empty",
    )
  }
  { source_type, }
}

///|
/// XSD simple type ST_Format: Schema opc-digSig.xsd simple type `ST_Format`
/// has base `xsd:string`; ST_Format, ST_Format::new, and ST_Format::to_string
/// own the SignatureTime Format lexical token used by the §10.5.16 Format
/// element.
pub(all) struct ST_Format {
  value : String
} derive(Eq, Debug)

///|
/// §10.5.16 Format element. Carries the timestamp format token used by
/// SignatureTime; the value is constrained by the ST_Format simple type.
pub type Format = ST_Format

///|
/// Build XSD simple type ST_Format from schema opc-digSig.xsd for the §10.5.16
/// XSD simple type ST_Format: validates the allowed SignatureTime Format
/// lexical strings before constructing an ST_Format value.
///
/// Format element under SignatureTime, rejecting values outside the lexical
/// constraint and enumeration-like token set as C4 schema violations.
pub fn ST_Format::new(value : String) -> ST_Format raise SchemaViolation {
  if !is_signature_time_format(value) {
    raise SchemaViolation(
      section="10",
      path="SignatureTime/Format",
      reason="ST_Format does not match the allowed timestamp format tokens",
    )
  }
  { value, }
}

///|
/// Serialize XSD simple type ST_Format for the §10.5.16 Format element to its
/// schema lexical string.
pub fn ST_Format::to_string(self : ST_Format) -> String {
  self.value
}

///|
/// ECMA-376 Part 2 §10.5.17 Value Element, source section
/// 10.5.17__value-element.md, and XSD simple type ST_Value from schema
/// opc-digSig.xsd. This lexical wrapper carries the timestamp value used by
/// SignatureTime and enforces the schema date or date-time lexical constraint.
pub(all) struct ST_Value {
  value : String
} derive(Eq, Debug)

///|
/// §10.5.17 Value element from source section 10.5.17__value-element.md.
/// Carries the timestamp value used by SignatureTime; the value is constrained
/// by the ST_Value simple type.
pub type Value = ST_Value

///|
/// Build XSD simple type ST_Value from schema opc-digSig.xsd for the §10.5.17
/// Value element under SignatureTime, rejecting values outside the lexical
/// constraint as C4 schema violations.
pub fn ST_Value::new(value : String) -> ST_Value raise SchemaViolation {
  if !is_signature_time_value(value) {
    raise SchemaViolation(
      section="10",
      path="SignatureTime/Value",
      reason="ST_Value does not match the allowed timestamp lexical forms",
    )
  }
  { value, }
}

///|
/// Serialize XSD simple type ST_Value for the §10.5.17 Value element to its
/// schema lexical string.
pub fn ST_Value::to_string(self : ST_Value) -> String {
  self.value
}

///|
/// 1. Scope domain value for the §10.5.15 SignatureTime element and
/// CT_SignatureTime from schema bundle
/// opc-digSig.xsd in the
/// http://schemas.openxmlformats.org/package/2006/digital-signature target
/// namespace; the builder preserves V2 child order by writing Format before
/// Value.
pub(all) struct SignatureTime {
  format : ST_Format
  value : ST_Value
} derive(Eq, Debug)

///|
/// Build CT_SignatureTime.
fn SignatureTime::new(format : ST_Format, value : ST_Value) -> SignatureTime {
  { format, value }
}

///|
/// ECMA-376 Part 2 §10.1 General source section
/// 10.1__general.md is owned by src/ecma376/opc/digital_signatures.
/// ECMA-376 Part 2 §10.3 Choosing Content To Sign source section
/// 10.3__choosing-content-to-sign.md is owned by this package through
/// RelationshipReference, RelationshipsGroupReference, Reference, and
/// Transform content selection markup.
/// ECMA-376 Part 2 §10.4.1 General source section 10.4.1__general.md is
/// owned by this digital signature parts namespace contract.
/// ECMA-376 Part 2 §10.5.1 General source section 10.5.1__general.md is
/// owned by the opc-digSig and XML-Signature markup readers and writers.
/// ECMA-376 Part 2 §10.5.2 Support For Versioning And Extensibility source
/// section 10.5.2__support-for-versioning-and-extensibility.md is owned by
/// extension-preserving child @xml.Node arrays and markup compatibility
/// boundaries.
/// §10 Digital Signatures schema coverage is tied to this namespace because
/// every owned opc-digSig XML reader validates elements against it.
pub fn digital_signature_ns() -> String {
  "http://schemas.openxmlformats.org/package/2006/digital-signature"
}

///|
fn is_signature_time_format(value : String) -> Bool {
  value == "YYYY" ||
  value == "YYYY-MM" ||
  value == "YYYY-MM-DD" ||
  value == "YYYY-MM-DDThh:mmTZD" ||
  value == "YYYY-MM-DDThh:mm:ssTZD" ||
  value == "YYYY-MM-DDThh:mm:ss.sTZD"
}

///|
fn is_signature_time_value(value : String) -> Bool {
  is_year(value) ||
  is_year_month(value) ||
  is_date(value) ||
  is_date_time_minute(value) ||
  is_date_time_second(value) ||
  is_date_time_fraction(value)
}

///|
fn is_year(value : String) -> Bool {
  value.length() == 4 && digits(value, 0, 4)
}

///|
fn is_year_month(value : String) -> Bool {
  value.length() == 7 &&
  is_year(value[0:4].to_owned()) &&
  value[4:5] == "-" &&
  month_ok(value[5:7].to_owned())
}

///|
fn is_date(value : String) -> Bool {
  value.length() == 10 &&
  is_year_month(value[0:7].to_owned()) &&
  value[7:8] == "-" &&
  day_ok(value[8:10].to_owned())
}

///|
fn is_date_time_minute(value : String) -> Bool {
  value.length() >= 17 &&
  is_date(value[0:10].to_owned()) &&
  value[10:11] == "T" &&
  hour_ok(value[11:13].to_owned()) &&
  value[13:14] == ":" &&
  minute_second_ok(value[14:16].to_owned()) &&
  timezone_ok(value[16:].to_owned())
}

///|
fn is_date_time_second(value : String) -> Bool {
  value.length() >= 20 &&
  is_date(value[0:10].to_owned()) &&
  value[10:11] == "T" &&
  hour_ok(value[11:13].to_owned()) &&
  value[13:14] == ":" &&
  minute_second_ok(value[14:16].to_owned()) &&
  value[16:17] == ":" &&
  minute_second_ok(value[17:19].to_owned()) &&
  timezone_ok(value[19:].to_owned())
}

///|
fn is_date_time_fraction(value : String) -> Bool {
  value.length() >= 22 &&
  is_date(value[0:10].to_owned()) &&
  value[10:11] == "T" &&
  hour_ok(value[11:13].to_owned()) &&
  value[13:14] == ":" &&
  minute_second_ok(value[14:16].to_owned()) &&
  value[16:17] == ":" &&
  minute_second_ok(value[17:19].to_owned()) &&
  value[19:20] == "." &&
  digits(value, 20, 21) &&
  timezone_ok(value[21:].to_owned())
}

///|
fn timezone_ok(value : String) -> Bool {
  value == "Z" ||
  (
    value.length() == 6 &&
    (value[0:1] == "+" || value[0:1] == "-") &&
    hour_ok(value[1:3].to_owned()) &&
    value[3:4] == ":" &&
    minute_second_ok(value[4:6].to_owned())
  )
}

///|
fn month_ok(value : String) -> Bool {
  value.length() == 2 &&
  (
    (value[0:1] == "0" && value[1:2] >= "1") ||
    (value[0:1] == "1" && value[1:2] >= "0" && value[1:2] <= "2")
  )
}

///|
fn day_ok(value : String) -> Bool {
  value.length() == 2 &&
  (
    (value[0:1] == "0" && value[1:2] >= "1") ||
    (value[0:1] == "1" && digits(value, 1, 2)) ||
    (value[0:1] == "2" && digits(value, 1, 2)) ||
    (value[0:1] == "3" && (value[1:2] == "0" || value[1:2] == "1"))
  )
}

///|
fn hour_ok(value : String) -> Bool {
  value.length() == 2 &&
  (
    (value[0:1] == "0" && digits(value, 1, 2)) ||
    (value[0:1] == "1" && digits(value, 1, 2)) ||
    (value[0:1] == "2" && value[1:2] >= "0" && value[1:2] <= "3")
  )
}

///|
fn minute_second_ok(value : String) -> Bool {
  value.length() == 2 &&
  value[0:1] >= "0" &&
  value[0:1] <= "5" &&
  digits(value, 1, 2)
}

///|
fn digits(value : String, start : Int, end : Int) -> Bool {
  let mut ok = start >= 0 && end <= value.length() && start < end
  for i in start..<end {
    ok = ok && value[i:i + 1] >= "0" && value[i:i + 1] <= "9"
  }
  ok
}
