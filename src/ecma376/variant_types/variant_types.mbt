///|
/// ECMA-376 Part 1 §22.4 Variant Types.
/// Schema shared-documentPropertiesVariantTypes.xsd, namespace
/// http://purl.oclc.org/ooxml/officeDocument/docPropsVTypes.
/// Bundle strict/transitional with 34 top-level elements, 6 complex types,
/// and 4 simple types.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/variant_types"
}

///|
/// Variant type schema validation error.
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD simple type ST_VectorBaseType from shared-documentPropertiesVariantTypes.xsd.
pub struct ST_VectorBaseType {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_VectorBaseType and enforce its vector base-type enumeration.
pub fn ST_VectorBaseType::new(
  s : String,
) -> ST_VectorBaseType raise SchemaViolation {
  if !is_vector_base_type(s) {
    invalid("ST_VectorBaseType", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_VectorBaseType value.
pub fn ST_VectorBaseType::to_string(self : ST_VectorBaseType) -> String {
  self.value
}

///|
/// XSD simple type ST_ArrayBaseType from shared-documentPropertiesVariantTypes.xsd.
pub struct ST_ArrayBaseType {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_ArrayBaseType and enforce its array base-type enumeration.
pub fn ST_ArrayBaseType::new(
  s : String,
) -> ST_ArrayBaseType raise SchemaViolation {
  if !is_array_base_type(s) {
    invalid("ST_ArrayBaseType", s)
  }
  { value: s }
}

///|
/// Return the lexical ST_ArrayBaseType value.
pub fn ST_ArrayBaseType::to_string(self : ST_ArrayBaseType) -> String {
  self.value
}

///|
/// XSD simple type ST_Cy from shared-documentPropertiesVariantTypes.xsd.
pub struct ST_Cy {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_Cy currency text.
pub fn ST_Cy::new(s : String) -> ST_Cy {
  { value: s }
}

///|
/// Return the lexical ST_Cy value.
pub fn ST_Cy::to_string(self : ST_Cy) -> String {
  self.value
}

///|
/// XSD simple type ST_Error from shared-documentPropertiesVariantTypes.xsd.
pub struct ST_Error {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_Error status text.
pub fn ST_Error::new(s : String) -> ST_Error {
  { value: s }
}

///|
/// Return the lexical ST_Error value.
pub fn ST_Error::to_string(self : ST_Error) -> String {
  self.value
}

///|
/// Shared raw XML holder for scalar top-level variant elements.
pub(all) struct VariantAtom {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Empty — Part 1 §22.4.2.9. Empty element with no
/// attributes and no children; preserves source element for round-trip.
pub(all) struct CT_Empty {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Sentinel marking empty content (xsd:complexType CT_Empty has no payload).
  is_empty : Bool
} derive(Eq, Debug)

///|
/// Construct CT_Empty from its source XML element.
pub fn CT_Empty::new(element : @xml.Element) -> CT_Empty {
  { element, is_empty: true }
}

///|
/// XSD complex type CT_Null — Part 1 §22.4.2.19. Empty element with no
/// attributes and no children; preserves source element for round-trip.
pub(all) struct CT_Null {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Sentinel marking null content (xsd:complexType CT_Null has no payload).
  is_null : Bool
} derive(Eq, Debug)

///|
/// Construct CT_Null from its source XML element.
pub fn CT_Null::new(element : @xml.Element) -> CT_Null {
  { element, is_null: true }
}

///|
/// XSD complex type CT_Vector — Part 1 §22.4.2.33. Required attributes
/// `baseType` (ST_VectorBaseType) and `size` (xsd:unsignedInt) plus an
/// unbounded choice of variant payload elements.
pub(all) struct CT_Vector {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @baseType (ST_VectorBaseType) — required.
  base_type : ST_VectorBaseType
  /// @size (xsd:unsignedInt) — required.
  size : String
  /// Vector item element local names in document order.
  item_names : Array[String]
} derive(Eq, Debug)

///|
/// Construct CT_Vector by parsing attributes and items from the XML element.
pub fn CT_Vector::new(
  element : @xml.Element,
) -> CT_Vector raise SchemaViolation {
  let base_type_value = require_attr(element, "baseType", "vector/@baseType")
  let base_type = ST_VectorBaseType::new(base_type_value)
  let size = require_attr(element, "size", "vector/@size")
  let item_names : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      item_names.push(child_element.name.local_name)
    }
  }
  { element, base_type, size, item_names }
}

///|
/// XSD complex type CT_Array — Part 1 §22.4.2.1. Required attributes
/// `lBounds`, `uBounds` (xsd:int) and `baseType` (ST_ArrayBaseType) plus an
/// unbounded choice of variant payload elements.
pub(all) struct CT_Array {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @lBounds (xsd:int) — required.
  l_bounds : String
  /// @uBounds (xsd:int) — required.
  u_bounds : String
  /// @baseType (ST_ArrayBaseType) — required.
  base_type : ST_ArrayBaseType
  /// Array item element local names in document order.
  item_names : Array[String]
} derive(Eq, Debug)

///|
/// Construct CT_Array by parsing attributes and items from the XML element.
pub fn CT_Array::new(element : @xml.Element) -> CT_Array raise SchemaViolation {
  let l_bounds = require_attr(element, "lBounds", "array/@lBounds")
  let u_bounds = require_attr(element, "uBounds", "array/@uBounds")
  let base_type_value = require_attr(element, "baseType", "array/@baseType")
  let base_type = ST_ArrayBaseType::new(base_type_value)
  let item_names : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      item_names.push(child_element.name.local_name)
    }
  }
  { element, l_bounds, u_bounds, base_type, item_names }
}

///|
/// XSD complex type CT_Variant — Part 1 §22.4.2.32. Single-choice payload of
/// one variant element from the §22.4 family.
pub(all) struct CT_Variant {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local name of the chosen variant payload element.
  payload_name : String
} derive(Eq, Debug)

///|
/// Construct CT_Variant by extracting the single payload child name.
pub fn CT_Variant::new(
  element : @xml.Element,
) -> CT_Variant raise SchemaViolation {
  let mut payload : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match payload {
        Some(_) =>
          raise SchemaViolation(
            schema="shared-documentPropertiesVariantTypes.xsd",
            path="variant",
            reason="CT_Variant must contain exactly one child",
          )
        None => payload = Some(child_element.name.local_name)
      }
    }
  }
  let payload_name = match payload {
    Some(name) => name
    None =>
      raise SchemaViolation(
        schema="shared-documentPropertiesVariantTypes.xsd",
        path="variant",
        reason="CT_Variant requires one child element",
      )
  }
  { element, payload_name }
}

///|
/// XSD complex type CT_Vstream — Part 1 §22.4.2.34. xsd:base64Binary
/// extension with optional `version` attribute (ST_Guid).
pub(all) struct CT_Vstream {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @version (s:ST_Guid) — optional.
  version : String?
  /// Base64 binary text content.
  content : String
} derive(Eq, Debug)

///|
/// Construct CT_Vstream by parsing optional version attribute and text body.
pub fn CT_Vstream::new(element : @xml.Element) -> CT_Vstream {
  let version = attr(element, "version")
  let content = text(element)
  { element, version, content }
}

///|
/// Variant value union for §22.4 top-level variant flavours.
pub(all) enum Variant {
  VtArray(CT_Array)
  VtBlob(VariantAtom)
  VtBool(VariantAtom)
  VtBstr(VariantAtom)
  VtClsid(VariantAtom)
  VtCy(VariantAtom)
  VtDate(VariantAtom)
  VtDecimal(VariantAtom)
  VtEmpty(CT_Empty)
  VtError(VariantAtom)
  VtFiletime(VariantAtom)
  VtI1(VariantAtom)
  VtI2(VariantAtom)
  VtI4(VariantAtom)
  VtI8(VariantAtom)
  VtInt(VariantAtom)
  VtLpstr(VariantAtom)
  VtLpwstr(VariantAtom)
  VtNull(CT_Null)
  VtOblob(VariantAtom)
  VtOstorage(VariantAtom)
  VtOstream(VariantAtom)
  VtR4(VariantAtom)
  VtR8(VariantAtom)
  VtStorage(VariantAtom)
  VtStream(VariantAtom)
  VtUi1(VariantAtom)
  VtUi2(VariantAtom)
  VtUi4(VariantAtom)
  VtUi8(VariantAtom)
  VtUint(VariantAtom)
  VtVariant(CT_Variant)
  VtVector(CT_Vector)
  VtVstream(CT_Vstream)
} derive(Eq, Debug)

///|
/// XSD element array.
pub type ArrayElement = CT_Array

///|
/// XSD element blob.
pub type Blob = VariantAtom

///|
/// XSD element bool.
pub type BoolElement = VariantAtom

///|
/// XSD element bstr.
pub type Bstr = VariantAtom

///|
/// XSD element clsid.
pub type Clsid = VariantAtom

///|
/// XSD element cy.
pub type Cy = VariantAtom

///|
/// XSD element date.
pub type DateElement = VariantAtom

///|
/// XSD element decimal.
pub type DecimalElement = VariantAtom

///|
/// XSD element empty.
pub type EmptyElement = CT_Empty

///|
/// XSD element error.
pub type ErrorElement = VariantAtom

///|
/// XSD element filetime.
pub type Filetime = VariantAtom

///|
/// XSD element i1.
pub type I1 = VariantAtom

///|
/// XSD element i2.
pub type I2 = VariantAtom

///|
/// XSD element i4.
pub type I4 = VariantAtom

///|
/// XSD element i8.
pub type I8 = VariantAtom

///|
/// XSD element int.
pub type IntElement = VariantAtom

///|
/// XSD element lpstr.
pub type Lpstr = VariantAtom

///|
/// XSD element lpwstr.
pub type Lpwstr = VariantAtom

///|
/// XSD element null.
pub type NullElement = CT_Null

///|
/// XSD element oblob.
pub type Oblob = VariantAtom

///|
/// XSD element ostorage.
pub type Ostorage = VariantAtom

///|
/// XSD element ostream.
pub type Ostream = VariantAtom

///|
/// XSD element r4.
pub type R4 = VariantAtom

///|
/// XSD element r8.
pub type R8 = VariantAtom

///|
/// XSD element storage.
pub type Storage = VariantAtom

///|
/// XSD element stream.
pub type Stream = VariantAtom

///|
/// XSD element ui1.
pub type Ui1 = VariantAtom

///|
/// XSD element ui2.
pub type Ui2 = VariantAtom

///|
/// XSD element ui4.
pub type Ui4 = VariantAtom

///|
/// XSD element ui8.
pub type Ui8 = VariantAtom

///|
/// XSD element uint.
pub type UintElement = VariantAtom

///|
/// XSD element variant.
pub type VariantElement = CT_Variant

///|
/// XSD element vector.
pub type VectorElement = CT_Vector

///|
/// XSD element vstream.
pub type VstreamElement = CT_Vstream

///|
/// Read a top-level vt:variant element.
pub fn read_variant(bytes : Bytes) -> VariantElement raise {
  let root = @xml.parse(bytes).root
  require_local(root, "variant", "variant")
  CT_Variant::new(root)
}

///|
/// Write a top-level vt:variant element.
pub fn write_variant(value : VariantElement) -> Bytes {
  write_element(value.element)
}

///|
/// Read a top-level vt:vector element.
pub fn read_vector(bytes : Bytes) -> VectorElement raise {
  let root = @xml.parse(bytes).root
  require_local(root, "vector", "vector")
  CT_Vector::new(root)
}

///|
/// Write a top-level vt:vector element.
pub fn write_vector(value : VectorElement) -> Bytes {
  write_element(value.element)
}

///|
/// Read a top-level vt:array element (XSD §22.4 element `array`).
pub fn read_array(bytes : Bytes) -> ArrayElement raise {
  let root = @xml.parse(bytes).root
  require_local(root, "array", "array")
  CT_Array::new(root)
}

///|
/// Read a top-level vt:blob element (XSD §22.4 element `blob`, xsd:base64Binary).
pub fn read_blob(bytes : Bytes) -> Blob raise {
  read_atom(bytes, "blob")
}

///|
/// Read a top-level vt:bool element (XSD §22.4 element `bool`, xsd:boolean).
pub fn read_bool(bytes : Bytes) -> BoolElement raise {
  read_atom(bytes, "bool")
}

///|
/// Read a top-level vt:bstr element (XSD §22.4 element `bstr`, xsd:string).
pub fn read_bstr(bytes : Bytes) -> Bstr raise {
  read_atom(bytes, "bstr")
}

///|
/// Read a top-level vt:clsid element (XSD §22.4 element `clsid`, s:ST_Guid).
pub fn read_clsid(bytes : Bytes) -> Clsid raise {
  read_atom(bytes, "clsid")
}

///|
/// Read a top-level vt:cy element (XSD §22.4 element `cy`, ST_Cy).
pub fn read_cy(bytes : Bytes) -> Cy raise {
  read_atom(bytes, "cy")
}

///|
/// Read a top-level vt:date element (XSD §22.4 element `date`, xsd:dateTime).
pub fn read_date(bytes : Bytes) -> DateElement raise {
  read_atom(bytes, "date")
}

///|
/// Read a top-level vt:decimal element (XSD §22.4 element `decimal`, xsd:decimal).
pub fn read_decimal(bytes : Bytes) -> DecimalElement raise {
  read_atom(bytes, "decimal")
}

///|
/// Read a top-level vt:empty element (XSD §22.4 element `empty`, CT_Empty).
pub fn read_empty(bytes : Bytes) -> EmptyElement raise {
  let root = @xml.parse(bytes).root
  require_local(root, "empty", "empty")
  CT_Empty::new(root)
}

///|
/// Read a top-level vt:error element (XSD §22.4 element `error`, ST_Error).
pub fn read_error(bytes : Bytes) -> ErrorElement raise {
  read_atom(bytes, "error")
}

///|
/// Read a top-level vt:filetime element (XSD §22.4 element `filetime`, xsd:dateTime).
pub fn read_filetime(bytes : Bytes) -> Filetime raise {
  read_atom(bytes, "filetime")
}

///|
/// Read a top-level vt:i1 element (XSD §22.4 element `i1`, xsd:byte).
pub fn read_i1(bytes : Bytes) -> I1 raise {
  read_atom(bytes, "i1")
}

///|
/// Read a top-level vt:i2 element (XSD §22.4 element `i2`, xsd:short).
pub fn read_i2(bytes : Bytes) -> I2 raise {
  read_atom(bytes, "i2")
}

///|
/// Read a top-level vt:i4 element (XSD §22.4 element `i4`, xsd:int).
pub fn read_i4(bytes : Bytes) -> I4 raise {
  read_atom(bytes, "i4")
}

///|
/// Read a top-level vt:i8 element (XSD §22.4 element `i8`, xsd:long).
pub fn read_i8(bytes : Bytes) -> I8 raise {
  read_atom(bytes, "i8")
}

///|
/// Read a top-level vt:int element (XSD §22.4 element `int`, xsd:int).
pub fn read_int(bytes : Bytes) -> IntElement raise {
  read_atom(bytes, "int")
}

///|
/// Read a top-level vt:lpstr element (XSD §22.4 element `lpstr`, xsd:string).
pub fn read_lpstr(bytes : Bytes) -> Lpstr raise {
  read_atom(bytes, "lpstr")
}

///|
/// Read a top-level vt:lpwstr element (XSD §22.4 element `lpwstr`, xsd:string).
pub fn read_lpwstr(bytes : Bytes) -> Lpwstr raise {
  read_atom(bytes, "lpwstr")
}

///|
/// Read a top-level vt:null element (XSD §22.4 element `null`, CT_Null).
pub fn read_null(bytes : Bytes) -> NullElement raise {
  let root = @xml.parse(bytes).root
  require_local(root, "null", "null")
  CT_Null::new(root)
}

///|
/// Read a top-level vt:oblob element (XSD §22.4 element `oblob`, xsd:base64Binary).
pub fn read_oblob(bytes : Bytes) -> Oblob raise {
  read_atom(bytes, "oblob")
}

///|
/// Read a top-level vt:ostorage element (XSD §22.4 element `ostorage`, xsd:base64Binary).
pub fn read_ostorage(bytes : Bytes) -> Ostorage raise {
  read_atom(bytes, "ostorage")
}

///|
/// Read a top-level vt:ostream element (XSD §22.4 element `ostream`, xsd:base64Binary).
pub fn read_ostream(bytes : Bytes) -> Ostream raise {
  read_atom(bytes, "ostream")
}

///|
/// Read a top-level vt:r4 element (XSD §22.4 element `r4`, xsd:float).
pub fn read_r4(bytes : Bytes) -> R4 raise {
  read_atom(bytes, "r4")
}

///|
/// Read a top-level vt:r8 element (XSD §22.4 element `r8`, xsd:double).
pub fn read_r8(bytes : Bytes) -> R8 raise {
  read_atom(bytes, "r8")
}

///|
/// Read a top-level vt:storage element (XSD §22.4 element `storage`, xsd:base64Binary).
pub fn read_storage(bytes : Bytes) -> Storage raise {
  read_atom(bytes, "storage")
}

///|
/// Read a top-level vt:stream element (XSD §22.4 element `stream`, xsd:base64Binary).
pub fn read_stream(bytes : Bytes) -> Stream raise {
  read_atom(bytes, "stream")
}

///|
/// Read a top-level vt:ui1 element (XSD §22.4 element `ui1`, xsd:unsignedByte).
pub fn read_ui1(bytes : Bytes) -> Ui1 raise {
  read_atom(bytes, "ui1")
}

///|
/// Read a top-level vt:ui2 element (XSD §22.4 element `ui2`, xsd:unsignedShort).
pub fn read_ui2(bytes : Bytes) -> Ui2 raise {
  read_atom(bytes, "ui2")
}

///|
/// Read a top-level vt:ui4 element (XSD §22.4 element `ui4`, xsd:unsignedInt).
pub fn read_ui4(bytes : Bytes) -> Ui4 raise {
  read_atom(bytes, "ui4")
}

///|
/// Read a top-level vt:ui8 element (XSD §22.4 element `ui8`, xsd:unsignedLong).
pub fn read_ui8(bytes : Bytes) -> Ui8 raise {
  read_atom(bytes, "ui8")
}

///|
/// Read a top-level vt:uint element (XSD §22.4 element `uint`, xsd:unsignedInt).
pub fn read_uint(bytes : Bytes) -> UintElement raise {
  read_atom(bytes, "uint")
}

///|
/// Read a top-level vt:vstream element (XSD §22.4 element `vstream`, CT_Vstream).
pub fn read_vstream(bytes : Bytes) -> VstreamElement raise {
  let root = @xml.parse(bytes).root
  require_local(root, "vstream", "vstream")
  CT_Vstream::new(root)
}

///|
/// Parse `bytes` as a top-level §22.4 scalar variant atom with required local name.
fn read_atom(bytes : Bytes, local_name : String) -> VariantAtom raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name, local_name)
  { element: root }
}

///|
/// Read any top-level §22.4 variant flavour as Variant.
pub fn read_value(bytes : Bytes) -> Variant raise {
  let root = @xml.parse(bytes).root
  variant_from_element(root)
}

///|
/// Write any top-level §22.4 variant flavour.
pub fn write_value(value : Variant) -> Bytes {
  write_element(value.to_element())
}

///|
/// Parse a preserved XML element into the Variant union.
pub fn variant_from_element(
  element : @xml.Element,
) -> Variant raise SchemaViolation {
  match element.name.local_name {
    "array" => VtArray(CT_Array::new(element))
    "blob" => VtBlob({ element, })
    "bool" => VtBool({ element, })
    "bstr" => VtBstr({ element, })
    "clsid" => VtClsid({ element, })
    "cy" => VtCy({ element, })
    "date" => VtDate({ element, })
    "decimal" => VtDecimal({ element, })
    "empty" => VtEmpty(CT_Empty::new(element))
    "error" => VtError({ element, })
    "filetime" => VtFiletime({ element, })
    "i1" => VtI1({ element, })
    "i2" => VtI2({ element, })
    "i4" => VtI4({ element, })
    "i8" => VtI8({ element, })
    "int" => VtInt({ element, })
    "lpstr" => VtLpstr({ element, })
    "lpwstr" => VtLpwstr({ element, })
    "null" => VtNull(CT_Null::new(element))
    "oblob" => VtOblob({ element, })
    "ostorage" => VtOstorage({ element, })
    "ostream" => VtOstream({ element, })
    "r4" => VtR4({ element, })
    "r8" => VtR8({ element, })
    "storage" => VtStorage({ element, })
    "stream" => VtStream({ element, })
    "ui1" => VtUi1({ element, })
    "ui2" => VtUi2({ element, })
    "ui4" => VtUi4({ element, })
    "ui8" => VtUi8({ element, })
    "uint" => VtUint({ element, })
    "variant" => VtVariant(CT_Variant::new(element))
    "vector" => VtVector(CT_Vector::new(element))
    "vstream" => VtVstream(CT_Vstream::new(element))
    _ =>
      raise SchemaViolation(
        schema="shared-documentPropertiesVariantTypes.xsd",
        path=element.name.local_name,
        reason="unexpected variant element",
      )
  }
}

///|
/// Return the preserved XML element for a Variant.
pub fn Variant::to_element(self : Variant) -> @xml.Element {
  match self {
    VtArray(value) => value.element
    VtBlob(value) => value.element
    VtBool(value) => value.element
    VtBstr(value) => value.element
    VtClsid(value) => value.element
    VtCy(value) => value.element
    VtDate(value) => value.element
    VtDecimal(value) => value.element
    VtEmpty(value) => value.element
    VtError(value) => value.element
    VtFiletime(value) => value.element
    VtI1(value) => value.element
    VtI2(value) => value.element
    VtI4(value) => value.element
    VtI8(value) => value.element
    VtInt(value) => value.element
    VtLpstr(value) => value.element
    VtLpwstr(value) => value.element
    VtNull(value) => value.element
    VtOblob(value) => value.element
    VtOstorage(value) => value.element
    VtOstream(value) => value.element
    VtR4(value) => value.element
    VtR8(value) => value.element
    VtStorage(value) => value.element
    VtStream(value) => value.element
    VtUi1(value) => value.element
    VtUi2(value) => value.element
    VtUi4(value) => value.element
    VtUi8(value) => value.element
    VtUint(value) => value.element
    VtVariant(value) => value.element
    VtVector(value) => value.element
    VtVstream(value) => value.element
  }
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
) -> String raise SchemaViolation {
  match attr(element, local_name) {
    Some(value) => value
    None =>
      raise SchemaViolation(
        schema="shared-documentPropertiesVariantTypes.xsd",
        path~,
        reason="required attribute missing",
      )
  }
}

///|
fn text(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Node::Text(value) | @xml.Node::CData(value) =>
        out.write_string(value)
      _ => ()
    }
  }
  out.to_string()
}

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(
      schema="shared-documentPropertiesVariantTypes.xsd",
      path~,
      reason="unexpected element name",
    )
  }
}

///|
fn invalid(path : String, value : String) -> Unit raise SchemaViolation {
  raise SchemaViolation(
    schema="shared-documentPropertiesVariantTypes.xsd",
    path~,
    reason="invalid value: \{value}",
  )
}

///|
fn is_vector_base_type(s : String) -> Bool {
  match s {
    "variant"
    | "i1"
    | "i2"
    | "i4"
    | "i8"
    | "ui1"
    | "ui2"
    | "ui4"
    | "ui8"
    | "r4"
    | "r8"
    | "lpstr"
    | "lpwstr"
    | "bstr"
    | "date"
    | "filetime"
    | "bool"
    | "cy"
    | "error"
    | "clsid" => true
    _ => false
  }
}

///|
fn is_array_base_type(s : String) -> Bool {
  match s {
    "variant"
    | "i1"
    | "i2"
    | "i4"
    | "int"
    | "ui1"
    | "ui2"
    | "ui4"
    | "uint"
    | "r4"
    | "r8"
    | "decimal"
    | "bstr"
    | "date"
    | "bool"
    | "cy"
    | "error" => true
    _ => false
  }
}
