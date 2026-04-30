///|
/// ECMA-376 Part 1 §22.2 Extended Properties, §22.3 Custom Properties,
/// §22.5 Custom XML Data Properties, and §23 Custom XML schema.
/// Schemas: shared-customXmlDataProperties.xsd,
/// shared-customXmlSchemaProperties.xsd, shared-documentPropertiesCustom.xsd,
/// and shared-documentPropertiesExtended.xsd.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/custom_xml_properties"
}

///|
/// Custom XML and document properties schema validation error.
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// ResourceMissing reports OPC resolver failures for §3 package resources.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// XSD complex type CT_DatastoreSchemaRef from shared-customXmlDataProperties.xsd.
pub(all) struct CT_DatastoreSchemaRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DatastoreSchemaRefs from shared-customXmlDataProperties.xsd.
pub(all) struct CT_DatastoreSchemaRefs {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DatastoreItem from shared-customXmlDataProperties.xsd.
pub(all) struct CT_DatastoreItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD element datastoreItem from shared-customXmlDataProperties.xsd.
pub type DatastoreItem = CT_DatastoreItem

///|
/// XSD complex type CT_Schema from shared-customXmlSchemaProperties.xsd.
pub(all) struct CT_Schema {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SchemaLibrary from shared-customXmlSchemaProperties.xsd.
pub(all) struct CT_SchemaLibrary {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD element schemaLibrary from shared-customXmlSchemaProperties.xsd.
pub type SchemaLibrary = CT_SchemaLibrary

///|
/// XSD complex type CT_Property from shared-documentPropertiesCustom.xsd.
pub(all) struct CT_Property {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Properties from document property schemas.
/// Covers shared-documentPropertiesCustom.xsd and shared-documentPropertiesExtended.xsd.
pub(all) struct CT_Properties {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD element Properties from shared-documentPropertiesCustom.xsd.
pub type CustomProperties = CT_Properties

///|
/// XSD element Properties from shared-documentPropertiesExtended.xsd.
pub type ExtendedProperties = CT_Properties

///|
/// XSD complex type CT_VectorVariant from shared-documentPropertiesExtended.xsd, with §3 ResourceMissing handling.
/// CT_VectorVariant preserves variant vectors from extended properties.
pub(all) struct CT_VectorVariant {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_VectorLpstr from shared-documentPropertiesExtended.xsd.
pub(all) struct CT_VectorLpstr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DigSigBlob from shared-documentPropertiesExtended.xsd.
pub(all) struct CT_DigSigBlob {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Read top-level datastoreItem.
pub fn read_datastore_item(bytes : Bytes) -> DatastoreItem raise {
  let root = @xml.parse(bytes).root
  require_local(
    root, "datastoreItem", "datastoreItem", "shared-customXmlDataProperties.xsd",
  )
  { element: root }
}

///|
/// Write top-level datastoreItem.
pub fn write_datastore_item(value : DatastoreItem) -> Bytes {
  write_element(value.element)
}

///|
/// Read top-level schemaLibrary.
pub fn read_schema_library(bytes : Bytes) -> SchemaLibrary raise {
  let root = @xml.parse(bytes).root
  require_local(
    root, "schemaLibrary", "schemaLibrary", "shared-customXmlSchemaProperties.xsd",
  )
  { element: root }
}

///|
/// Write top-level schemaLibrary.
pub fn write_schema_library(value : SchemaLibrary) -> Bytes {
  write_element(value.element)
}

///|
/// Read top-level Properties from shared-documentPropertiesCustom.xsd.
pub fn read_custom_properties(bytes : Bytes) -> CustomProperties raise {
  let root = @xml.parse(bytes).root
  require_local(
    root, "Properties", "Properties", "shared-documentPropertiesCustom.xsd",
  )
  { element: root }
}

///|
/// Write top-level Properties from shared-documentPropertiesCustom.xsd.
pub fn write_custom_properties(value : CustomProperties) -> Bytes {
  write_element(value.element)
}

///|
/// Read top-level Properties from shared-documentPropertiesExtended.xsd.
pub fn read_extended_properties(bytes : Bytes) -> ExtendedProperties raise {
  let root = @xml.parse(bytes).root
  require_local(
    root, "Properties", "Properties", "shared-documentPropertiesExtended.xsd",
  )
  { element: root }
}

///|
/// Write top-level Properties from shared-documentPropertiesExtended.xsd.
pub fn write_extended_properties(value : ExtendedProperties) -> Bytes {
  write_element(value.element)
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
  path : String,
  schema : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(schema~, path~, reason="unexpected element name")
  }
}
