///|
/// OPC §9 Thumbnails use PartName to identify the image part reached from a
/// package or part relationship.
pub(all) struct PartName {
  value : String
} derive(Eq, Debug)

///|
/// Parse a package part name for OPC §9 Thumbnails. This enforces §2
/// Conformance C2 by rejecting malformed part names that violate structural
/// constraints, and C5 by reporting SchemaViolation with the §9 section
/// reference and local path.
pub fn PartName::parse(value : String) -> PartName raise SchemaViolation {
  if !value.has_prefix("/") {
    raise SchemaViolation(
      section="9",
      path="PartName",
      reason="part name must start with /",
    )
  }
  if value.contains("\\") ||
    value.contains("//") ||
    value.has_suffix("/") ||
    value.contains("/../") ||
    value.contains("/./") {
    raise SchemaViolation(
      section="9",
      path="PartName",
      reason="part name contains a disallowed segment",
    )
  }
  { value, }
}

///|
/// Return the OPC §6 Outputs O1 typed domain value as the lexical part-name
/// attribute used by §9 Thumbnails relationship targets.
pub fn PartName::to_string(self : PartName) -> String {
  self.value
}

///|
/// OPC §9 Thumbnails binary image part identified by a package relationship
/// or a part relationship.
pub(all) struct ThumbnailPart {
  name : PartName
  data : Bytes
} derive(Eq, Debug)

///|
/// Build an OPC §9 Thumbnails binary image part without XML parsing; the
/// writer returns these bytes unchanged.
fn ThumbnailPart::new(name : PartName, data : Bytes) -> ThumbnailPart {
  { name, data }
}

///|
/// OPC §9 Thumbnails generic package part record used by the surrounding OPC
/// resolver when it supplies embedded resources.
pub(all) struct PackagePart {
  name : PartName
  content_type : String
  data : Bytes
} derive(Eq, Debug)

///|
/// Create an OPC §9 Thumbnails PackagePart.
fn PackagePart::new(
  name : PartName,
  content_type : String,
  data : Bytes,
) -> PackagePart raise SchemaViolation {
  if content_type == "" {
    raise SchemaViolation(
      section="9",
      path="PackagePart/@contentType",
      reason="content type must not be empty",
    )
  }
  { name, content_type, data }
}

///|
/// CT_Keyword value from schema bundle opc-coreProperties.xsd in the
/// http://schemas.openxmlformats.org/package/2006/metadata/core-properties
/// target namespace. It contributes to the coreProperties top-level element
/// and the CT_Keywords container.
pub(all) struct CoreKeyword {
  value : String
} derive(Eq, Debug)

///|
/// CT_Keywords container from schema bundle opc-coreProperties.xsd in the
/// http://schemas.openxmlformats.org/package/2006/metadata/core-properties
/// target namespace. The values array preserves the CT_Keyword value sequence
/// exposed by the coreProperties element.
pub(all) struct CoreKeywords {
  values : Array[CoreKeyword]
} derive(Eq, Debug)

///|
/// coreProperties element and CT_CoreProperties preserve the parsed XML
/// document so C3 attributes and child ordering survive read/write round trip.
pub(all) struct CoreProperties {
  document : @xml.Document
} derive(Eq, Debug)

///|
/// Create a coreProperties CT_CoreProperties wrapper around validated XML.
fn CoreProperties::new(document : @xml.Document) -> CoreProperties {
  { document, }
}

///|
/// RelationshipReference top-level element and CT_RelationshipReference from
/// schema bundle opc-digSig.xsd in the
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
      section="9",
      path="RelationshipReference/@SourceId",
      reason="SourceId must not be empty",
    )
  }
  { source_id, }
}

///|
/// RelationshipsGroupReference top-level element and
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
      section="9",
      path="RelationshipsGroupReference/@SourceType",
      reason="SourceType must not be empty",
    )
  }
  { source_type, }
}

///|
/// ST_Format simple type for SignatureTime from schema bundle opc-digSig.xsd
/// in the http://schemas.openxmlformats.org/package/2006/digital-signature
/// target namespace.
pub(all) struct SignatureTimeFormat {
  value : String
} derive(Eq, Debug)

///|
/// Build ST_Format for SignatureTime, rejecting values outside the XSD pattern
/// as C4 schema violations.
fn SignatureTimeFormat::new(
  value : String,
) -> SignatureTimeFormat raise SchemaViolation {
  if !is_signature_time_format(value) {
    raise SchemaViolation(
      section="9",
      path="SignatureTime/Format",
      reason="ST_Format does not match the allowed timestamp format tokens",
    )
  }
  { value, }
}

///|
/// ST_Value simple type for SignatureTime from schema bundle opc-digSig.xsd in
/// the http://schemas.openxmlformats.org/package/2006/digital-signature target
/// namespace.
pub(all) struct SignatureTimeValue {
  value : String
} derive(Eq, Debug)

///|
/// Build ST_Value for SignatureTime, rejecting values outside the XSD pattern
/// as C4 schema violations.
fn SignatureTimeValue::new(
  value : String,
) -> SignatureTimeValue raise SchemaViolation {
  if !is_signature_time_value(value) {
    raise SchemaViolation(
      section="9",
      path="SignatureTime/Value",
      reason="ST_Value does not match the allowed timestamp lexical forms",
    )
  }
  { value, }
}

///|
/// SignatureTime top-level element and CT_SignatureTime from schema bundle
/// opc-digSig.xsd in the
/// http://schemas.openxmlformats.org/package/2006/digital-signature target
/// namespace; the builder preserves V2 child order by writing Format before
/// Value.
pub(all) struct SignatureTime {
  format : SignatureTimeFormat
  value : SignatureTimeValue
} derive(Eq, Debug)

///|
/// Build CT_SignatureTime.
fn SignatureTime::new(
  format : SignatureTimeFormat,
  value : SignatureTimeValue,
) -> SignatureTime {
  { format, value }
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
