///|
/// OPC §6 Outputs O1/O2 round-trip writer for OPC §9 Thumbnails; thumbnail
/// image bytes are emitted unchanged.
pub fn write_thumbnail_part(value : ThumbnailPart) -> Bytes {
  value.data
}

///|
/// OPC §6 Outputs O1/O2 round-trip writer for generic OPC §9 package part
/// bytes supplied by the resolver.
pub fn write_part(value : PackagePart) -> Bytes {
  value.data
}

///|
/// OPC §6 Outputs O1/O2 round-trip writer for coreProperties and
/// CT_CoreProperties XML, preserving the parsed document and its attributes.
pub fn write_core_properties(value : CoreProperties) -> Bytes {
  @xml.write(value.document)
}
