///|
/// OPC §9 Thumbnails, OPC §6.2.2 Part names, and PackagePart domain value.
pub(all) struct PartName {
  value : String
} derive(Eq, Debug)

///|
/// Create a PartName for OPC §9 Thumbnails and PackagePart name validation.
pub fn PartName::parse(value : String) -> PartName raise PartError {
  if !value.has_prefix("/") {
    raise PartError::SchemaViolation(
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
    raise PartError::SchemaViolation(
      section="9",
      path="PartName",
      reason="part name contains a disallowed segment",
    )
  }
  { value, }
}

///|
/// Return the OPC §9 Thumbnails PartName lexical form.
pub fn PartName::to_string(self : PartName) -> String {
  self.value
}

///|
/// Return the ZIP item name for an OPC §9 Thumbnails PartName.
pub fn PartName::zip_item_name(self : PartName) -> String {
  self.value[1:].to_owned()
}

///|
/// OPC §9 Thumbnails and OPC §6.3 PackUri value.
pub(all) struct PackUri {
  value : String
} derive(Eq, Debug)

///|
/// Create a PackUri for OPC §9 Thumbnails package resource addressing.
pub fn PackUri::parse(value : String) -> PackUri raise PartError {
  if value == "" {
    raise PartError::SchemaViolation(
      section="9",
      path="PackUri",
      reason="pack uri must not be empty",
    )
  }
  { value, }
}

///|
/// Return the OPC §9 Thumbnails PackUri lexical form.
pub fn PackUri::to_string(self : PackUri) -> String {
  self.value
}

///|
/// OPC §9 Thumbnails PackagePart record.
pub(all) struct PackagePart {
  name : PartName
  content_type : String
  data : Bytes
} derive(Eq, Debug)

///|
/// Create an OPC §9 Thumbnails PackagePart.
pub fn PackagePart::new(
  name : PartName,
  content_type : String,
  data : Bytes,
) -> PackagePart raise PartError {
  if content_type == "" {
    raise PartError::SchemaViolation(
      section="9",
      path="PackagePart/@contentType",
      reason="content type must not be empty",
    )
  }
  { name, content_type, data }
}

///|
/// CT_Keyword value for opc-coreProperties.xsd coreProperties.
pub(all) struct CoreKeyword {
  value : String
} derive(Eq, Debug)

///|
/// Build CT_Keyword for coreProperties.
pub fn CoreKeyword::new(value : String) -> CoreKeyword {
  { value, }
}

///|
/// CT_Keywords value for opc-coreProperties.xsd coreProperties.
pub(all) struct CoreKeywords {
  values : Array[CoreKeyword]
} derive(Eq, Debug)

///|
/// Build CT_Keywords for coreProperties.
pub fn CoreKeywords::new(values : Array[String]) -> CoreKeywords {
  { values: values.map(fn(value) { CoreKeyword::new(value) }) }
}

///|
/// coreProperties element and CT_CoreProperties in
/// http://schemas.openxmlformats.org/package/2006/metadata/core-properties.
pub(all) struct CoreProperties {
  document : @xml.Document
} derive(Eq, Debug)

///|
/// Create a coreProperties CT_CoreProperties wrapper.
pub fn CoreProperties::new(document : @xml.Document) -> CoreProperties {
  { document, }
}

///|
/// RelationshipReference element and CT_RelationshipReference.
pub(all) struct RelationshipReference {
  source_id : String
} derive(Eq, Debug)

///|
/// Build CT_RelationshipReference.
pub fn RelationshipReference::new(
  source_id : String,
) -> RelationshipReference raise PartError {
  if source_id == "" {
    raise PartError::SchemaViolation(
      section="9",
      path="RelationshipReference/@SourceId",
      reason="SourceId must not be empty",
    )
  }
  { source_id, }
}

///|
/// RelationshipsGroupReference element and CT_RelationshipsGroupReference.
pub(all) struct RelationshipsGroupReference {
  source_type : String
} derive(Eq, Debug)

///|
/// Build CT_RelationshipsGroupReference.
pub fn RelationshipsGroupReference::new(
  source_type : String,
) -> RelationshipsGroupReference raise PartError {
  if source_type == "" {
    raise PartError::SchemaViolation(
      section="9",
      path="RelationshipsGroupReference/@SourceType",
      reason="SourceType must not be empty",
    )
  }
  { source_type, }
}

///|
/// ST_Format simple type for SignatureTime.
pub(all) struct SignatureTimeFormat {
  value : String
} derive(Eq, Debug)

///|
/// Build ST_Format for SignatureTime.
pub fn SignatureTimeFormat::new(
  value : String,
) -> SignatureTimeFormat raise PartError {
  if value == "" {
    raise PartError::SchemaViolation(
      section="9",
      path="SignatureTime/Format",
      reason="ST_Format must not be empty",
    )
  }
  { value, }
}

///|
/// ST_Value simple type for SignatureTime.
pub(all) struct SignatureTimeValue {
  value : String
} derive(Eq, Debug)

///|
/// Build ST_Value for SignatureTime.
pub fn SignatureTimeValue::new(
  value : String,
) -> SignatureTimeValue raise PartError {
  if value == "" {
    raise PartError::SchemaViolation(
      section="9",
      path="SignatureTime/Value",
      reason="ST_Value must not be empty",
    )
  }
  { value, }
}

///|
/// SignatureTime element and CT_SignatureTime.
pub(all) struct SignatureTime {
  format : SignatureTimeFormat
  value : SignatureTimeValue
} derive(Eq, Debug)

///|
/// Build CT_SignatureTime.
pub fn SignatureTime::new(
  format : SignatureTimeFormat,
  value : SignatureTimeValue,
) -> SignatureTime {
  { format, value }
}
