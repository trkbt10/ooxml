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
/// ResourceMissing is reserved for OPC relationship targets referenced by §22.4 values.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
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
/// XSD complex type CT_Empty from shared-documentPropertiesVariantTypes.xsd.
pub(all) struct CT_Empty {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Null from shared-documentPropertiesVariantTypes.xsd.
pub(all) struct CT_Null {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Vector from shared-documentPropertiesVariantTypes.xsd.
pub(all) struct CT_Vector {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Array from shared-documentPropertiesVariantTypes.xsd.
pub(all) struct CT_Array {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Variant from shared-documentPropertiesVariantTypes.xsd.
pub(all) struct CT_Variant {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Vstream from shared-documentPropertiesVariantTypes.xsd.
pub(all) struct CT_Vstream {
  element : @xml.Element
} derive(Eq, Debug)

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
  { element: root }
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
  match attr(root, "baseType") {
    Some(value) => ST_VectorBaseType::new(value) |> ignore
    None => ()
  }
  { element: root }
}

///|
/// Write a top-level vt:vector element.
pub fn write_vector(value : VectorElement) -> Bytes {
  write_element(value.element)
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
    "array" => VtArray({ element, })
    "blob" => VtBlob({ element, })
    "bool" => VtBool({ element, })
    "bstr" => VtBstr({ element, })
    "clsid" => VtClsid({ element, })
    "cy" => VtCy({ element, })
    "date" => VtDate({ element, })
    "decimal" => VtDecimal({ element, })
    "empty" => VtEmpty({ element, })
    "error" => VtError({ element, })
    "filetime" => VtFiletime({ element, })
    "i1" => VtI1({ element, })
    "i2" => VtI2({ element, })
    "i4" => VtI4({ element, })
    "i8" => VtI8({ element, })
    "int" => VtInt({ element, })
    "lpstr" => VtLpstr({ element, })
    "lpwstr" => VtLpwstr({ element, })
    "null" => VtNull({ element, })
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
    "variant" => VtVariant({ element, })
    "vector" => VtVector({ element, })
    "vstream" => VtVstream({ element, })
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
