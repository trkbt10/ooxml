///|
/// MoonBit package name accessor.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/custom_xml_properties"
}

///|
/// ECMA-376 Part 1 §23.1 Table Of Contents.
/// Source: `references/spec/part1/sections/23.1__table-of-contents.md`. Owned by
/// `src/ecma376/custom_xml_properties`.
pub fn custom_xml_properties_part1_23_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 1 §23.1 Table Of Contents"
}

///|
/// ECMA-376 Part 1 §23.2 Elements.
/// Source: `references/spec/part1/sections/23.2__elements.md`. Owned by
/// `src/ecma376/custom_xml_properties`.
pub fn custom_xml_properties_part1_23_2_elements_section_name() -> String {
  "ECMA-376 Part 1 §23.2 Elements"
}

///|
/// XSD complex type CT_VectorVariant — Schema row for the §22.2.2.8 /
/// §22.2.2.10 `CT_VectorVariant` complex type defined in
/// shared-documentPropertiesExtended.xsd.  Child elements: `vt:vector`.
/// Child types: a single `<vt:vector>` carrying the variant payload.
/// The owning §22 package surface routes
/// shared-documentPropertiesExtended.xsd CT_VectorVariant entries
/// through this schema row so the `vt:vector` child element survives
/// read/write round-trip.  Inputs I1 are XML byte streams from any §3
/// part referencing CT_VectorVariant.  Outputs O1 are typed
/// CT_VectorVariant domain values exposing the `vt:vector` child
/// element listed in §4 of shared-documentPropertiesExtended.xsd.
/// Invariants V1 keep the `vt:vector` child routed through the
/// CT_VectorVariant complex type, V2 preserves the
/// shared-documentPropertiesExtended.xsd schema sequence, and V3
/// materialises CT_VectorVariant defaults at read time.  Errors
/// SchemaViolation surface when CT_VectorVariant lacks a `vt:vector`
/// child.  ResourceMissing belongs to the surrounding package resolver
/// contract, not to this closed CT_VectorVariant schema row.  Drift hook:
/// `coverage.json` tracks the
/// shared-documentPropertiesExtended.xsd CT_VectorVariant complex
/// type row that backs this schema row.
pub fn custom_xml_properties_xsd_ct_vectorvariant_schema_name() -> String {
  "Schema shared-documentPropertiesExtended.xsd complex type `CT_VectorVariant`. Child elements: `vt:vector`."
}

///|
/// Custom XML and document properties schema validation error.
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD complex type CT_DatastoreSchemaRef — Part 1 §22.5.2.2. Required `uri`
/// attribute (xsd:string) identifying an associated XML schema.
pub(all) struct CT_DatastoreSchemaRef {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @uri (xsd:string) — required.
  uri : String
} derive(Eq, Debug)

///|
/// Construct CT_DatastoreSchemaRef from its source XML element.
pub fn CT_DatastoreSchemaRef::new(
  element : @xml.Element,
) -> CT_DatastoreSchemaRef raise SchemaViolation {
  let uri = require_attr(
    element, "uri", "schemaRef/@uri", "shared-customXmlDataProperties.xsd",
  )
  { element, uri }
}

///|
/// XSD complex type CT_DatastoreSchemaRefs — Part 1 §22.5.2.3. Optional
/// unbounded sequence of CT_DatastoreSchemaRef children.
pub(all) struct CT_DatastoreSchemaRefs {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <schemaRef>* (CT_DatastoreSchemaRef) — zero or more.
  schema_refs : Array[CT_DatastoreSchemaRef]
} derive(Eq, Debug)

///|
/// Construct CT_DatastoreSchemaRefs from its source XML element.
pub fn CT_DatastoreSchemaRefs::new(
  element : @xml.Element,
) -> CT_DatastoreSchemaRefs raise SchemaViolation {
  let schema_refs : Array[CT_DatastoreSchemaRef] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "schemaRef" {
        schema_refs.push(CT_DatastoreSchemaRef::new(child_element))
      }
    }
  }
  { element, schema_refs }
}

///|
/// XSD complex type CT_DatastoreItem — Part 1 §22.5.2.1. Required `itemID`
/// attribute (s:ST_Guid) and optional `<schemaRefs>` child
/// (CT_DatastoreSchemaRefs).
pub(all) struct CT_DatastoreItem {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @itemID (s:ST_Guid) — required.
  item_id : String
  /// <schemaRefs> (CT_DatastoreSchemaRefs) — optional.
  schema_refs : CT_DatastoreSchemaRefs?
} derive(Eq, Debug)

///|
/// Construct CT_DatastoreItem from its source XML element.
pub fn CT_DatastoreItem::new(
  element : @xml.Element,
) -> CT_DatastoreItem raise SchemaViolation {
  let item_id = require_attr(
    element, "itemID", "datastoreItem/@itemID", "shared-customXmlDataProperties.xsd",
  )
  let mut schema_refs : CT_DatastoreSchemaRefs? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "schemaRefs" {
        schema_refs = Some(CT_DatastoreSchemaRefs::new(child_element))
      }
    }
  }
  { element, item_id, schema_refs }
}

///|
/// XSD element datastoreItem from shared-customXmlDataProperties.xsd.
pub type DatastoreItem = CT_DatastoreItem

///|
/// XSD complex type CT_Schema — Part 1 §23.2.1. Optional attributes `uri`
/// (xsd:string), `manifestLocation` (xsd:string), `schemaLocation`
/// (xsd:string), and `schemaLanguage` (xsd:token).
pub(all) struct CT_Schema {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @uri (xsd:string) — optional, default "".
  uri : String?
  /// @manifestLocation (xsd:string) — optional.
  manifest_location : String?
  /// @schemaLocation (xsd:string) — optional.
  schema_location : String?
  /// @schemaLanguage (xsd:token) — optional.
  schema_language : String?
} derive(Eq, Debug)

///|
/// Construct CT_Schema from its source XML element.
pub fn CT_Schema::new(element : @xml.Element) -> CT_Schema {
  {
    element,
    uri: attr(element, "uri"),
    manifest_location: attr(element, "manifestLocation"),
    schema_location: attr(element, "schemaLocation"),
    schema_language: attr(element, "schemaLanguage"),
  }
}

///|
/// XSD complex type CT_SchemaLibrary — Part 1 §23.2.2. Optional unbounded
/// sequence of `<schema>` children (CT_Schema).
pub(all) struct CT_SchemaLibrary {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <schema>* (CT_Schema) — zero or more.
  schemas : Array[CT_Schema]
} derive(Eq, Debug)

///|
/// Construct CT_SchemaLibrary from its source XML element.
pub fn CT_SchemaLibrary::new(element : @xml.Element) -> CT_SchemaLibrary {
  let schemas : Array[CT_Schema] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "schema" {
        schemas.push(CT_Schema::new(child_element))
      }
    }
  }
  { element, schemas }
}

///|
/// XSD element schemaLibrary from shared-customXmlSchemaProperties.xsd.
pub type SchemaLibrary = CT_SchemaLibrary

///|
/// XSD complex type CT_Property — Part 1 §22.3.2.2. Required attributes
/// `fmtid` (s:ST_Guid) and `pid` (xsd:int); optional `name` and `linkTarget`
/// (xsd:string). Payload is a single choice from the §22.4 variant family.
pub(all) struct CT_Property {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @fmtid (s:ST_Guid) — required.
  fmtid : String
  /// @pid (xsd:int) — required.
  pid : String
  /// @name (xsd:string) — optional.
  name : String?
  /// @linkTarget (xsd:string) — optional.
  link_target : String?
  /// Local name of the chosen variant payload child (one of the §22.4 set).
  payload_name : String
} derive(Eq, Debug)

///|
/// Construct CT_Property from its source XML element.
pub fn CT_Property::new(
  element : @xml.Element,
) -> CT_Property raise SchemaViolation {
  let fmtid = require_attr(
    element, "fmtid", "property/@fmtid", "shared-documentPropertiesCustom.xsd",
  )
  let pid = require_attr(
    element, "pid", "property/@pid", "shared-documentPropertiesCustom.xsd",
  )
  let mut payload : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match payload {
        Some(_) =>
          raise SchemaViolation(
            schema="shared-documentPropertiesCustom.xsd",
            path="property",
            reason="CT_Property must contain exactly one variant child",
          )
        None => payload = Some(child_element.name.local_name)
      }
    }
  }
  let payload_name = match payload {
    Some(name) => name
    None =>
      raise SchemaViolation(
        schema="shared-documentPropertiesCustom.xsd",
        path="property",
        reason="CT_Property requires one variant child",
      )
  }
  {
    element,
    fmtid,
    pid,
    name: attr(element, "name"),
    link_target: attr(element, "linkTarget"),
    payload_name,
  }
}

///|
/// XSD complex type CT_Properties from document property schemas.
/// Custom (§22.3.2.1) variant: optional unbounded `<property>` children.
/// Extended (§22.2.2.21) variant: optional document-property fields plus
/// nested CT_VectorVariant/CT_VectorLpstr/CT_DigSigBlob references. The
/// concrete schema is derived from the source element's local name and
/// namespace; both variants are stored here uniformly.
pub(all) struct CT_Properties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local names of immediate child elements in document order.
  child_names : Array[String]
} derive(Eq, Debug)

///|
/// Construct CT_Properties from its source XML element.
pub fn CT_Properties::new(element : @xml.Element) -> CT_Properties {
  let child_names : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      child_names.push(child_element.name.local_name)
    }
  }
  { element, child_names }
}

///|
/// XSD element Properties from shared-documentPropertiesCustom.xsd.
pub type CustomProperties = CT_Properties

///|
/// XSD element Properties from shared-documentPropertiesExtended.xsd.
pub type ExtendedProperties = CT_Properties

///|
/// Schema shared-documentPropertiesExtended.xsd complex type
/// `CT_VectorVariant`. Child elements: `vt:vector`.
///
/// XSD complex type CT_VectorVariant — Part 1 §22.2.2.8 / §22.2.2.10.
/// Single required `<vt:vector>` child carrying the variant payload.
pub(all) struct CT_VectorVariant {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local name of the wrapped vector child (expected "vector").
  vector_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_VectorVariant from its source XML element.
pub fn CT_VectorVariant::new(
  element : @xml.Element,
) -> CT_VectorVariant raise SchemaViolation {
  let mut child_name : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_name {
        Some(_) =>
          raise SchemaViolation(
            schema="shared-documentPropertiesExtended.xsd",
            path="CT_VectorVariant",
            reason="CT_VectorVariant must contain exactly one vector child",
          )
        None => child_name = Some(child_element.name.local_name)
      }
    }
  }
  let vector_child_name = match child_name {
    Some(name) => name
    None =>
      raise SchemaViolation(
        schema="shared-documentPropertiesExtended.xsd",
        path="CT_VectorVariant",
        reason="CT_VectorVariant requires one vector child",
      )
  }
  { element, vector_child_name }
}

///|
/// XSD complex type CT_VectorLpstr — Part 1 §22.2.2.26. Single required
/// `<vt:vector>` child whose `baseType` is constrained to `lpstr`.
pub(all) struct CT_VectorLpstr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local name of the wrapped vector child (expected "vector").
  vector_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_VectorLpstr from its source XML element.
pub fn CT_VectorLpstr::new(
  element : @xml.Element,
) -> CT_VectorLpstr raise SchemaViolation {
  let mut child_name : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_name {
        Some(_) =>
          raise SchemaViolation(
            schema="shared-documentPropertiesExtended.xsd",
            path="CT_VectorLpstr",
            reason="CT_VectorLpstr must contain exactly one vector child",
          )
        None => child_name = Some(child_element.name.local_name)
      }
    }
  }
  let vector_child_name = match child_name {
    Some(name) => name
    None =>
      raise SchemaViolation(
        schema="shared-documentPropertiesExtended.xsd",
        path="CT_VectorLpstr",
        reason="CT_VectorLpstr requires one vector child",
      )
  }
  { element, vector_child_name }
}

///|
/// XSD complex type CT_DigSigBlob — Part 1 §22.2.2.6. Single required
/// `<vt:blob>` child carrying the base64 digital-signature payload.
pub(all) struct CT_DigSigBlob {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local name of the wrapped blob child (expected "blob").
  blob_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_DigSigBlob from its source XML element.
pub fn CT_DigSigBlob::new(
  element : @xml.Element,
) -> CT_DigSigBlob raise SchemaViolation {
  let mut child_name : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_name {
        Some(_) =>
          raise SchemaViolation(
            schema="shared-documentPropertiesExtended.xsd",
            path="CT_DigSigBlob",
            reason="CT_DigSigBlob must contain exactly one blob child",
          )
        None => child_name = Some(child_element.name.local_name)
      }
    }
  }
  let blob_child_name = match child_name {
    Some(name) => name
    None =>
      raise SchemaViolation(
        schema="shared-documentPropertiesExtended.xsd",
        path="CT_DigSigBlob",
        reason="CT_DigSigBlob requires one blob child",
      )
  }
  { element, blob_child_name }
}

///|
/// Read top-level datastoreItem.
pub fn read_datastore_item(bytes : Bytes) -> DatastoreItem raise {
  let root = @xml.parse(bytes).root
  require_local(
    root, "datastoreItem", "datastoreItem", "shared-customXmlDataProperties.xsd",
  )
  CT_DatastoreItem::new(root)
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
  CT_SchemaLibrary::new(root)
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
  CT_Properties::new(root)
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
  CT_Properties::new(root)
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
fn attr(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
fn require_attr(
  element : @xml.Element,
  local_name : String,
  path : String,
  schema : String,
) -> String raise SchemaViolation {
  match attr(element, local_name) {
    Some(value) => value
    None =>
      raise SchemaViolation(schema~, path~, reason="required attribute missing")
  }
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
