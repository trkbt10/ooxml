///|
/// §10.5.3 Signature element. Top-level W3C XML-Signature container.
pub(all) struct Signature {
  id : String?
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.3 Signature Element domain shell.
pub fn Signature::new(id : String?, children : Array[@xml.Node]) -> Signature {
  { id, children }
}

///|
/// Read the §10.5.3 Signature Element from W3C XML-Signature XML bytes.
pub fn read_signature(bytes : Bytes) -> Signature raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "Signature")
  Signature::new(optional_attribute(root, "Id"), root.children)
}

///|
/// Write the §10.5.3 Signature Element to W3C XML-Signature XML bytes.
pub fn write_signature(value : Signature) -> Bytes {
  write_xmldsig_element(
    "Signature",
    optional_attributes([("Id", value.id)]),
    value.children,
  )
}

///|
/// §10.5.4 SignedInfo element from source section
/// 10.5.4__signedinfo-element.md. Captures canonicalization, signature method,
/// and Reference children for XML-Signature SignedInfo markup.
pub(all) struct SignedInfo {
  id : String?
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.4 SignedInfo Element domain shell.
pub fn SignedInfo::new(id : String?, children : Array[@xml.Node]) -> SignedInfo {
  { id, children }
}

///|
/// §10.5.4 SignedInfo element reader. Parses a SignedInfo XML element from
/// W3C XML-Signature bytes, preserving canonicalization, signature method, and
/// Reference children in the SignedInfo domain shell.
pub fn read_signed_info(bytes : Bytes) -> SignedInfo raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "SignedInfo")
  SignedInfo::new(optional_attribute(root, "Id"), root.children)
}

///|
/// §10.5.4 SignedInfo element writer. Emits a SignedInfo XML element back to
/// W3C XML-Signature bytes with preserved canonicalization, signature method,
/// and Reference children.
pub fn write_signed_info(value : SignedInfo) -> Bytes {
  write_xmldsig_element(
    "SignedInfo",
    optional_attributes([("Id", value.id)]),
    value.children,
  )
}

///|
/// §10.5.5 CanonicalizationMethod element. Captures the required Algorithm
/// attribute and any extension children.
pub(all) struct CanonicalizationMethod {
  algorithm : String
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.5 CanonicalizationMethod Element domain shell.
pub fn CanonicalizationMethod::new(
  algorithm : String,
  children : Array[@xml.Node],
) -> CanonicalizationMethod raise SchemaViolation {
  require_non_empty_attribute(
    algorithm, "10.5.5", "CanonicalizationMethod/@Algorithm",
  )
  { algorithm, children }
}

///|
/// Read the §10.5.5 CanonicalizationMethod Element from XML-Signature bytes.
pub fn read_canonicalization_method(
  bytes : Bytes,
) -> CanonicalizationMethod raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "CanonicalizationMethod")
  CanonicalizationMethod::new(
    required_attribute(root, "Algorithm", "/CanonicalizationMethod/@Algorithm"),
    root.children,
  )
}

///|
/// Write the §10.5.5 CanonicalizationMethod Element to XML-Signature bytes.
pub fn write_canonicalization_method(value : CanonicalizationMethod) -> Bytes {
  write_xmldsig_element(
    "CanonicalizationMethod",
    [xmldsig_attribute("Algorithm", value.algorithm)],
    value.children,
  )
}

///|
/// §10.5.6 SignatureMethod element. Captures the required Algorithm
/// attribute and any extension children.
pub(all) struct SignatureMethod {
  algorithm : String
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.6 SignatureMethod Element domain shell.
pub fn SignatureMethod::new(
  algorithm : String,
  children : Array[@xml.Node],
) -> SignatureMethod raise SchemaViolation {
  require_non_empty_attribute(algorithm, "10.5.6", "SignatureMethod/@Algorithm")
  { algorithm, children }
}

///|
/// Read the §10.5.6 SignatureMethod Element from XML-Signature bytes.
pub fn read_signature_method(
  bytes : Bytes,
) -> SignatureMethod raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "SignatureMethod")
  SignatureMethod::new(
    required_attribute(root, "Algorithm", "/SignatureMethod/@Algorithm"),
    root.children,
  )
}

///|
/// Write the §10.5.6 SignatureMethod Element to XML-Signature bytes.
pub fn write_signature_method(value : SignatureMethod) -> Bytes {
  write_xmldsig_element(
    "SignatureMethod",
    [xmldsig_attribute("Algorithm", value.algorithm)],
    value.children,
  )
}

///|
/// §10.5.7 Reference element. Captures Id, Type, URI, and nested
/// XML-Signature transform and digest markup.
pub(all) struct Reference {
  id : String?
  type_ : String?
  uri : String?
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.7 Reference Element domain shell.
pub fn Reference::new(
  id : String?,
  type_ : String?,
  uri : String?,
  children : Array[@xml.Node],
) -> Reference {
  { id, type_, uri, children }
}

///|
/// Read the §10.5.7 Reference Element from XML-Signature bytes.
pub fn read_reference(bytes : Bytes) -> Reference raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "Reference")
  Reference::new(
    optional_attribute(root, "Id"),
    optional_attribute(root, "Type"),
    optional_attribute(root, "URI"),
    root.children,
  )
}

///|
/// Write the §10.5.7 Reference Element to XML-Signature bytes.
pub fn write_reference(value : Reference) -> Bytes {
  write_xmldsig_element(
    "Reference",
    optional_attributes([
      ("Id", value.id),
      ("Type", value.type_),
      ("URI", value.uri),
    ]),
    value.children,
  )
}

///|
/// §10.5.8 Transform element. Captures the required Algorithm attribute and
/// transform-specific child content.
pub(all) struct Transform {
  algorithm : String
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.8 Transform Element domain shell.
pub fn Transform::new(
  algorithm : String,
  children : Array[@xml.Node],
) -> Transform raise SchemaViolation {
  require_non_empty_attribute(algorithm, "10.5.8", "Transform/@Algorithm")
  { algorithm, children }
}

///|
/// §10.5.8 Transform element reader. Parses a Transform XML element from
/// XML-Signature bytes, including the Algorithm attribute and optional XPath or
/// transform-specific child content, into the Transform domain type imported
/// through schema opc-digSig.xsd.
pub fn read_transform(bytes : Bytes) -> Transform raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "Transform")
  Transform::new(
    required_attribute(root, "Algorithm", "/Transform/@Algorithm"),
    root.children,
  )
}

///|
/// §10.5.8 Transform element writer. Emits a Transform XML element with the
/// Algorithm attribute and preserved optional XPath or transform-specific child
/// content back to XML-Signature bytes for schema opc-digSig.xsd.
pub fn write_transform(value : Transform) -> Bytes {
  write_xmldsig_element(
    "Transform",
    [xmldsig_attribute("Algorithm", value.algorithm)],
    value.children,
  )
}

///|
/// §10.5.11 DigestMethod element. Captures the required Algorithm attribute
/// and any extension children.
pub(all) struct DigestMethod {
  algorithm : String
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.11 DigestMethod Element domain shell.
pub fn DigestMethod::new(
  algorithm : String,
  children : Array[@xml.Node],
) -> DigestMethod raise SchemaViolation {
  require_non_empty_attribute(algorithm, "10.5.11", "DigestMethod/@Algorithm")
  { algorithm, children }
}

///|
/// §10.5.11 DigestMethod element reader. Parses a DigestMethod XML element
/// from XML-Signature bytes, including the required Algorithm attribute and
/// extension children, into the DigestMethod domain type referenced by
/// opc-digSig.xsd.
pub fn read_digest_method(bytes : Bytes) -> DigestMethod raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "DigestMethod")
  DigestMethod::new(
    required_attribute(root, "Algorithm", "/DigestMethod/@Algorithm"),
    root.children,
  )
}

///|
/// §10.5.11 DigestMethod element writer. Emits a DigestMethod XML element with
/// its Algorithm attribute and preserved extension children back to XML-
/// Signature bytes for the opc-digSig.xsd signature markup contract.
pub fn write_digest_method(value : DigestMethod) -> Bytes {
  write_xmldsig_element(
    "DigestMethod",
    [xmldsig_attribute("Algorithm", value.algorithm)],
    value.children,
  )
}

///|
/// §10.5.12 Object element. Captures Id and nested XML-Signature object
/// content.
pub(all) struct Object {
  id : String?
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.12 Object Element domain shell.
pub fn Object::new(id : String?, children : Array[@xml.Node]) -> Object {
  { id, children }
}

///|
/// §10.5.12 Object element reader. Parses an Object XML element from XML-
/// Signature bytes, preserving the optional Id attribute and nested object
/// children in the Object domain type used by opc-digSig.xsd.
pub fn read_object(bytes : Bytes) -> Object raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "Object")
  Object::new(optional_attribute(root, "Id"), root.children)
}

///|
/// §10.5.12 Object element writer. Emits an Object XML element with the
/// optional Id attribute and preserved nested object children back to XML-
/// Signature bytes for the opc-digSig.xsd markup surface.
pub fn write_object(value : Object) -> Bytes {
  write_xmldsig_element(
    "Object",
    optional_attributes([("Id", value.id)]),
    value.children,
  )
}

///|
/// §10.5.13 Manifest element. Captures Id and Reference children.
pub(all) struct Manifest {
  id : String?
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.13 Manifest Element domain shell.
pub fn Manifest::new(id : String?, children : Array[@xml.Node]) -> Manifest {
  { id, children }
}

///|
/// §10.5.13 Manifest element reader. Parses a Manifest XML element from XML-
/// Signature bytes, preserving the optional Id attribute and Reference child
/// content in the Manifest domain type referenced by opc-digSig.xsd.
pub fn read_manifest(bytes : Bytes) -> Manifest raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "Manifest")
  Manifest::new(optional_attribute(root, "Id"), root.children)
}

///|
/// §10.5.13 Manifest element writer. Emits a Manifest XML element with the
/// optional Id attribute and preserved Reference child content back to XML-
/// Signature bytes for the opc-digSig.xsd markup contract.
pub fn write_manifest(value : Manifest) -> Bytes {
  write_xmldsig_element(
    "Manifest",
    optional_attributes([("Id", value.id)]),
    value.children,
  )
}

///|
/// §10.5.14 SignatureProperty element. Captures required Target, optional Id,
/// and property children.
pub(all) struct SignatureProperty {
  id : String?
  target : String
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.14 SignatureProperty Element domain shell.
pub fn SignatureProperty::new(
  id : String?,
  target : String,
  children : Array[@xml.Node],
) -> SignatureProperty raise SchemaViolation {
  require_non_empty_attribute(target, "10.5.14", "SignatureProperty/@Target")
  { id, target, children }
}

///|
/// Read the §10.5.14 SignatureProperty Element from XML-Signature bytes.
pub fn read_signature_property(
  bytes : Bytes,
) -> SignatureProperty raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "SignatureProperty")
  SignatureProperty::new(
    optional_attribute(root, "Id"),
    required_attribute(root, "Target", "/SignatureProperty/@Target"),
    root.children,
  )
}

///|
/// Write the §10.5.14 SignatureProperty Element to XML-Signature bytes.
pub fn write_signature_property(value : SignatureProperty) -> Bytes {
  write_xmldsig_element(
    "SignatureProperty",
    optional_attributes([("Id", value.id), ("Target", Some(value.target))]),
    value.children,
  )
}

///|
/// §10.5.18 XPath element. Captures Id and XPath text or extension children.
pub(all) struct XPath {
  id : String?
  children : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Construct the §10.5.18 XPath Element domain shell.
pub fn XPath::new(id : String?, children : Array[@xml.Node]) -> XPath {
  { id, children }
}

///|
/// Read the §10.5.18 XPath Element from XML-Signature bytes.
pub fn read_xpath(bytes : Bytes) -> XPath raise SchemaViolation {
  let root = read_xmldsig_root(bytes, "XPath")
  XPath::new(optional_attribute(root, "Id"), root.children)
}

///|
/// Write the §10.5.18 XPath Element to XML-Signature bytes.
pub fn write_xpath(value : XPath) -> Bytes {
  write_xmldsig_element(
    "XPath",
    optional_attributes([("Id", value.id)]),
    value.children,
  )
}

///|
fn xmldsig_ns() -> String {
  "http://www.w3.org/2000/09/xmldsig#"
}

///|
fn read_xmldsig_root(
  bytes : Bytes,
  local_name : String,
) -> @xml.Element raise SchemaViolation {
  let doc = @xml.parse(bytes) catch {
    _ =>
      raise SchemaViolation(
        section="10.5",
        path="/",
        reason="input is not well-formed XML-Signature markup",
      )
  }
  if !is_element(doc.root, local_name, xmldsig_ns()) {
    raise SchemaViolation(
      section="10.5",
      path="/",
      reason="expected " + local_name + " in the XML-Signature namespace",
    )
  }
  doc.root
}

///|
fn write_xmldsig_element(
  local_name : String,
  attributes : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> Bytes {
  @xml.write({
    declaration: None,
    doctype: None,
    root: { name: xmldsig_name(local_name), attributes, children },
  })
}

///|
fn xmldsig_name(local_name : String) -> @xml.QName {
  { prefix: Some("ds"), local_name, ns: Some(xmldsig_ns()) }
}

///|
fn xmldsig_attribute(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name: name, ns: None }, value }
}

///|
fn optional_attributes(
  values : Array[(String, String?)],
) -> Array[@xml.Attribute] {
  let attributes : Array[@xml.Attribute] = []
  for item in values {
    match item {
      (name, Some(value)) => attributes.push(xmldsig_attribute(name, value))
      (_, None) => ()
    }
  }
  attributes
}

///|
fn optional_attribute(element : @xml.Element, name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == name && attr.name.ns == None {
      return Some(attr.value)
    }
  }
  None
}

///|
fn require_non_empty_attribute(
  value : String,
  section : String,
  path : String,
) -> Unit raise SchemaViolation {
  if value == "" {
    raise SchemaViolation(
      section~,
      path~,
      reason="required attribute must not be empty",
    )
  }
}
