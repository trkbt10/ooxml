///|
fn relationship_transform_algorithm() -> String {
  @opc_namespaces.ns_relationships_transform()
}

///|
fn c14n_algorithm() -> String {
  @opc_namespaces.ns_c14n()
}

///|
fn sha1_algorithm() -> String {
  @opc_namespaces.ns_xmldsig_sha1()
}

///|
fn sha256_algorithm() -> String {
  @opc_namespaces.ns_xmlenc_sha256()
}

///|
fn sha384_algorithm() -> String {
  @opc_namespaces.ns_xmldsig_more_sha384()
}

///|
fn sha512_algorithm() -> String {
  @opc_namespaces.ns_xmlenc_sha512()
}

///|
fn relationships_namespace() -> String {
  @opc_namespaces.ns_relationships()
}

///|
fn digital_signature_namespace() -> String {
  @opc_namespaces.ns_digital_signature()
}

///|
fn xmldsig_namespace_for_algorithm() -> String {
  @opc_namespaces.ns_xmldsig()
}

///|
priv struct RelationshipTransformEntry {
  id : String
  type_uri : String
  target : String
  target_mode : String?
}

///|
priv struct NamespaceForCanonicalXml {
  prefix : String?
  uri : String
} derive(Eq)

///|
priv struct ReferenceProcessingData {
  reference : Reference
  transforms : Array[Transform]
  digest_method : DigestMethod
}

///|
/// §10.6 Relationships Transform Algorithm. Parses a relationships part,
/// selects the requested Relationship elements, sorts them by Id, and emits the
/// canonical UTF-8 byte stream consumed by XML-Signature digest processing.
pub fn apply_relationships_transform(
  source : Bytes,
  filter : Array[String]?,
) -> Bytes raise @opc_errors.SchemaViolation {
  let doc = @xml.parse(source) catch {
    _ =>
      raise @opc_errors.SchemaViolation(
        section="10.6",
        path="/",
        reason="relationships part is not well-formed XML",
      )
  }
  if !is_algorithm_element(doc.root, "Relationships", relationships_namespace()) {
    raise @opc_errors.SchemaViolation(
      section="10.6",
      path="/",
      reason="expected Relationships in the relationships namespace",
    )
  }
  let selected : Array[RelationshipTransformEntry] = []
  for child in algorithm_element_children(doc.root, "/Relationships", "10.6") {
    if !is_algorithm_element(child, "Relationship", relationships_namespace()) {
      raise @opc_errors.SchemaViolation(
        section="10.6",
        path="/Relationships/" + child.name.local_name,
        reason="Relationships may contain only Relationship elements",
      )
    }
    let id = algorithm_required_attribute(
      child, "Id", "/Relationships/Relationship/@Id", "10.6",
    )
    if relationship_filter_contains(filter, id) {
      selected.push({
        id,
        type_uri: algorithm_required_attribute(
          child, "Type", "/Relationships/Relationship/@Type", "10.6",
        ),
        target: algorithm_required_attribute(
          child, "Target", "/Relationships/Relationship/@Target", "10.6",
        ),
        target_mode: algorithm_optional_attribute(child, "TargetMode"),
      })
    }
  }
  sort_relationship_transform_entries(selected)
  write_relationships_transform_entries(selected)
}

///|
/// §10.8 Generating Signatures. Applies each Reference transform, computes
/// SHA-256 digest values, canonicalizes SignedInfo with W3C C14N
/// `http://www.w3.org/TR/2001/REC-xml-c14n-20010315`, and delegates the
/// SignatureMethod primitive to the supplied signing callback.
pub fn generate_signature(
  signed_info : SignedInfo,
  resolve : (String) -> Bytes,
  sign : (Bytes) -> Bytes,
) -> Signature raise @opc_errors.SchemaViolation {
  let populated_signed_info = populate_reference_digests(signed_info, resolve)
  let canonical_signed_info = canonicalize_xml(
    write_signed_info(populated_signed_info),
  )
  let signature_value = @base64.encode(sign(canonical_signed_info)[:])
  Signature::new(None, [
    Element(signed_info_element(populated_signed_info)),
    Element(xmldsig_text_element("SignatureValue", signature_value)),
  ])
}

///|
/// §10.9 Validating Signatures. Canonicalizes SignedInfo, verifies
/// SignatureValue through the supplied XML-Signature SignatureMethod callback,
/// then recomputes every Reference digest after applying the declared
/// transform chain.
pub fn validate_signature(
  signature : Signature,
  resolve : (String) -> Bytes,
  verify : (Bytes, Bytes) -> Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  let signed_info = signature_signed_info(signature)
  let signature_value = signature_value_bytes(signature)
  let canonical_signed_info = canonicalize_xml(write_signed_info(signed_info))
  if !verify(canonical_signed_info, signature_value) {
    return false
  }
  for item in signed_info_references(signed_info) {
    let source = resolve(item.reference.uri.unwrap_or(""))
    let transformed = apply_transforms(source, item.transforms)
    let digest = digest_reference_bytes(transformed, item.digest_method)
    match reference_digest_value(item.reference) {
      Some(value) => if value != digest { return false }
      None => return false
    }
  }
  true
}

///|
fn populate_reference_digests(
  signed_info : SignedInfo,
  resolve : (String) -> Bytes,
) -> SignedInfo raise @opc_errors.SchemaViolation {
  let children : Array[@xml.Node] = []
  for child in signed_info.children {
    match child {
      Element(element) =>
        if is_algorithm_element(
            element,
            "Reference",
            xmldsig_namespace_for_algorithm(),
          ) {
          let item = read_reference_processing_data(element)
          let source = resolve(item.reference.uri.unwrap_or(""))
          let transformed = apply_transforms(source, item.transforms)
          let digest_value = digest_reference_bytes(
            transformed,
            item.digest_method,
          )
          children.push(
            Element(reference_element_with_digest(item, digest_value)),
          )
        } else {
          children.push(child)
        }
      _ => children.push(child)
    }
  }
  SignedInfo::new(signed_info.id, children)
}

///|
fn apply_transforms(
  source : Bytes,
  transforms : Array[Transform],
) -> Bytes raise @opc_errors.SchemaViolation {
  let mut current = source
  for transform in transforms {
    if transform.algorithm == relationship_transform_algorithm() {
      current = apply_relationships_transform(
        current,
        Some(relationship_reference_filter(transform.children)),
      )
    } else if transform.algorithm == c14n_algorithm() {
      current = canonicalize_xml(current)
    } else if transform.algorithm == c14n_with_comments_algorithm() {
      current = canonicalize_xml(current, with_comments=true)
    } else if transform.algorithm == base64_transform_algorithm() {
      current = apply_base64_transform(current)
    } else {
      raise @opc_errors.SchemaViolation(
        section="10.8",
        path="/SignedInfo/Reference/Transforms/Transform/@Algorithm",
        reason="unsupported transform algorithm: " + transform.algorithm,
      )
    }
  }
  current
}

///|
fn c14n_with_comments_algorithm() -> String {
  @opc_namespaces.ns_c14n_with_comments()
}

///|
fn base64_transform_algorithm() -> String {
  @opc_namespaces.ns_transform_base64()
}

///|
/// W3C XML-Signature §6.6.2 base64 transform.  When the input parses as XML
/// its text-node content is concatenated; otherwise the whole octet stream is
/// taken as the base64 text.  Surrounding whitespace is ignored, then the
/// text is base64-decoded to the octet stream consumed by the next transform
/// or by digest processing.
fn apply_base64_transform(
  source : Bytes,
) -> Bytes raise @opc_errors.SchemaViolation {
  let text = StringBuilder::new()
  let parsed : @xml.Document? = try @xml.parse(source) catch {
    _ => None
  } noraise {
    document => Some(document)
  }
  match parsed {
    Some(document) => collect_element_text(document.root, text)
    None => text.write_string(@utf8.decode(source[:]) catch { _ => "" })
  }
  // The base64 alphabet excludes whitespace, so all ASCII whitespace (the
  // line breaks XML tools insert into long base64 payloads) is dropped before
  // decoding rather than only trimmed at the ends.
  let cleaned = StringBuilder::new()
  text
  .to_string()
  .iter()
  .each(fn(ch) {
    if ch != ' ' && ch != '\n' && ch != '\r' && ch != '\t' {
      cleaned.write_char(ch)
    }
  })
  @base64.decode(cleaned.to_string()[:]) catch {
    _ =>
      raise @opc_errors.SchemaViolation(
        section="10.8",
        path="/SignedInfo/Reference/Transforms/Transform[@Algorithm='base64']",
        reason="base64 transform input is not valid base64",
      )
  }
}

///|
/// Concatenate every descendant text/CDATA node of `element` into `out`.
fn collect_element_text(element : @xml.Element, out : StringBuilder) -> Unit {
  for child in element.children {
    match child {
      Text(value) | CData(value) => out.write_string(value)
      Element(child_element) => collect_element_text(child_element, out)
      _ => ()
    }
  }
}

///|
/// §10.5 / Part 2 §B — compute the Reference's digest.
///
/// XML-Signature §6.4.x registers SHA-1, SHA-256, SHA-384 and SHA-512 as
/// Reference digest algorithms.  Office authoring tools used SHA-1 for
/// backward compatibility through Office 2007, SHA-256 from Office 2010, and
/// SHA-512 in newer generations.  SHA-1 and SHA-256 come from `@crypto`;
/// the 64-bit SHA-2 variants (SHA-384 / SHA-512), which `@crypto` does not
/// expose, are supplied by this package's FIPS 180-4 implementation in
/// `sha512.mbt`.  An identifier outside this registry is reported as a §8 E2
/// SchemaViolation, the conformant response for an unsupported algorithm.
fn digest_reference_bytes(
  bytes : Bytes,
  digest_method : DigestMethod,
) -> String raise @opc_errors.SchemaViolation {
  let algorithm = digest_method.algorithm
  let raw : FixedArray[Byte] = if algorithm == sha1_algorithm() {
    @crypto.sha1(bytes)
  } else if algorithm == sha256_algorithm() {
    @crypto.sha256(bytes)
  } else if algorithm == sha384_algorithm() {
    sha384_bytes(bytes)
  } else if algorithm == sha512_algorithm() {
    sha512_bytes(bytes)
  } else {
    raise @opc_errors.SchemaViolation(
      section="10.8",
      path="/SignedInfo/Reference/DigestMethod/@Algorithm",
      reason="unsupported digest algorithm (SHA-1, SHA-256, SHA-384 and SHA-512 are implemented): " +
        algorithm,
    )
  }
  @base64.encode(raw.unsafe_reinterpret_as_bytes()[:])
}

///|
fn read_reference_processing_data(
  element : @xml.Element,
) -> ReferenceProcessingData raise @opc_errors.SchemaViolation {
  let reference = Reference::new(
    algorithm_optional_attribute(element, "Id"),
    algorithm_optional_attribute(element, "Type"),
    algorithm_optional_attribute(element, "URI"),
    element.children,
  )
  let transforms : Array[Transform] = []
  let mut digest_method : DigestMethod? = None
  for child in element.children {
    if child is Element(child_element) {
      if is_algorithm_element(
          child_element,
          "Transforms",
          xmldsig_namespace_for_algorithm(),
        ) {
        for
          transform_element in algorithm_element_children(
            child_element, "/Reference/Transforms", "10.8",
          ) {
          if !is_algorithm_element(
              transform_element,
              "Transform",
              xmldsig_namespace_for_algorithm(),
            ) {
            raise @opc_errors.SchemaViolation(
              section="10.8",
              path="/Reference/Transforms/" + transform_element.name.local_name,
              reason="Transforms may contain only Transform elements",
            )
          }
          transforms.push(
            Transform::new(
              algorithm_required_attribute(
                transform_element, "Algorithm", "/Reference/Transforms/Transform/@Algorithm",
                "10.8",
              ),
              transform_element.children,
            ),
          )
        }
      } else if is_algorithm_element(
          child_element,
          "DigestMethod",
          xmldsig_namespace_for_algorithm(),
        ) {
        digest_method = Some(
          DigestMethod::new(
            algorithm_required_attribute(
              child_element, "Algorithm", "/Reference/DigestMethod/@Algorithm", "10.8",
            ),
            child_element.children,
          ),
        )
      }
    }
  }
  match digest_method {
    Some(value) => { reference, transforms, digest_method: value }
    None =>
      raise @opc_errors.SchemaViolation(
        section="10.8",
        path="/Reference/DigestMethod",
        reason="Reference requires a DigestMethod",
      )
  }
}

///|
fn reference_element_with_digest(
  item : ReferenceProcessingData,
  digest_value : String,
) -> @xml.Element {
  let children : Array[@xml.Node] = []
  let mut replaced = false
  for child in item.reference.children {
    match child {
      Element(element) =>
        if is_algorithm_element(
            element,
            "DigestValue",
            xmldsig_namespace_for_algorithm(),
          ) {
          children.push(
            Element(xmldsig_text_element("DigestValue", digest_value)),
          )
          replaced = true
        } else {
          children.push(child)
        }
      _ => children.push(child)
    }
  }
  if !replaced {
    children.push(Element(xmldsig_text_element("DigestValue", digest_value)))
  }
  {
    name: xmldsig_name_for_algorithm("Reference"),
    attributes: optional_algorithm_attributes([
      ("Id", item.reference.id),
      ("Type", item.reference.type_),
      ("URI", item.reference.uri),
    ]),
    children,
  }
}

///|
fn signed_info_element(value : SignedInfo) -> @xml.Element {
  {
    name: xmldsig_name_for_algorithm("SignedInfo"),
    attributes: optional_algorithm_attributes([("Id", value.id)]),
    children: value.children,
  }
}

///|
fn signature_signed_info(
  signature : Signature,
) -> SignedInfo raise @opc_errors.SchemaViolation {
  for child in signature.children {
    if child is Element(element) &&
      is_algorithm_element(
        element,
        "SignedInfo",
        xmldsig_namespace_for_algorithm(),
      ) {
      return SignedInfo::new(
        algorithm_optional_attribute(element, "Id"),
        element.children,
      )
    }
  }
  raise @opc_errors.SchemaViolation(
    section="10.9",
    path="/Signature/SignedInfo",
    reason="Signature requires SignedInfo",
  )
}

///|
fn signature_value_bytes(
  signature : Signature,
) -> Bytes raise @opc_errors.SchemaViolation {
  for child in signature.children {
    if child is Element(element) &&
      is_algorithm_element(
        element,
        "SignatureValue",
        xmldsig_namespace_for_algorithm(),
      ) {
      return @base64.decode(element_text_for_algorithm(element)[:]) catch {
        _ =>
          raise @opc_errors.SchemaViolation(
            section="10.9",
            path="/Signature/SignatureValue",
            reason="SignatureValue is not valid base64",
          )
      }
    }
  }
  raise @opc_errors.SchemaViolation(
    section="10.9",
    path="/Signature/SignatureValue",
    reason="Signature requires SignatureValue",
  )
}

///|
fn signed_info_references(
  signed_info : SignedInfo,
) -> Array[ReferenceProcessingData] raise @opc_errors.SchemaViolation {
  let references : Array[ReferenceProcessingData] = []
  for child in signed_info.children {
    if child is Element(element) &&
      is_algorithm_element(
        element,
        "Reference",
        xmldsig_namespace_for_algorithm(),
      ) {
      references.push(read_reference_processing_data(element))
    }
  }
  references
}

///|
fn reference_digest_value(reference : Reference) -> String? {
  for child in reference.children {
    if child is Element(element) &&
      is_algorithm_element(
        element,
        "DigestValue",
        xmldsig_namespace_for_algorithm(),
      ) {
      return Some(element_text_for_algorithm(element))
    }
  }
  None
}

///|
fn relationship_reference_filter(children : Array[@xml.Node]) -> Array[String] {
  let filter : Array[String] = []
  for child in children {
    if child is Element(element) &&
      is_algorithm_element(
        element,
        "RelationshipReference",
        digital_signature_namespace(),
      ) {
      match algorithm_optional_attribute(element, "SourceId") {
        Some(source_id) => filter.push(source_id)
        None => ()
      }
    }
  }
  filter
}

///|
fn relationship_filter_contains(filter : Array[String]?, id : String) -> Bool {
  match filter {
    Some(values) => values.contains(id)
    None => true
  }
}

///|
fn write_relationships_transform_entries(
  entries : Array[RelationshipTransformEntry],
) -> Bytes {
  let out = StringBuilder::new()
  let mut first = true
  for entry in entries {
    out.write_string("<Relationship")
    if first {
      out.write_string(" xmlns=\"")
      out.write_string(@xml.escape_attribute_c14n(relationships_namespace()))
      out.write_string("\"")
      first = false
    }
    out.write_string(" Id=\"")
    out.write_string(@xml.escape_attribute_c14n(entry.id))
    out.write_string("\" Type=\"")
    out.write_string(@xml.escape_attribute_c14n(entry.type_uri))
    out.write_string("\" Target=\"")
    out.write_string(@xml.escape_attribute_c14n(entry.target))
    out.write_string("\"")
    match entry.target_mode {
      Some("External") => out.write_string(" TargetMode=\"External\"")
      _ => ()
    }
    out.write_string("></Relationship>")
  }
  @utf8.encode(out.to_string()[:])
}

///|
fn sort_relationship_transform_entries(
  entries : Array[RelationshipTransformEntry],
) -> Unit {
  for i in 1..<entries.length() {
    let current = entries[i]
    let mut j = i
    while j > 0 && current.id.lexical_compare(entries[j - 1].id) < 0 {
      entries[j] = entries[j - 1]
      j -= 1
    }
    entries[j] = current
  }
}

///|
fn canonicalize_xml(
  bytes : Bytes,
  with_comments~ : Bool = false,
) -> Bytes raise @opc_errors.SchemaViolation {
  let doc = @xml.parse(bytes) catch {
    _ =>
      raise @opc_errors.SchemaViolation(
        section="10.8",
        path="/",
        reason="XML input is not well-formed for canonicalization",
      )
  }
  let out = StringBuilder::new()
  write_canonical_element(
    out,
    doc.root,
    [{ prefix: Some("xml"), uri: @opc_namespaces.ns_xml_1998() }],
    with_comments~,
  )
  @utf8.encode(out.to_string()[:])
}

///|
fn write_canonical_element(
  out : StringBuilder,
  element : @xml.Element,
  inherited : Array[NamespaceForCanonicalXml],
  with_comments~ : Bool,
) -> Unit {
  out.write_string("<")
  out.write_string(format_algorithm_qname(element.name))
  let active = inherited.copy()
  let namespaces : Array[NamespaceForCanonicalXml] = []
  collect_namespace_if_needed(
    namespaces,
    active,
    element.name.prefix,
    element.name.ns,
  )
  for attr in element.attributes {
    if attr.name.prefix is Some(_) {
      collect_namespace_if_needed(
        namespaces,
        active,
        attr.name.prefix,
        attr.name.ns,
      )
    }
  }
  sort_canonical_namespaces(namespaces)
  for ns in namespaces {
    out.write_string(" ")
    match ns.prefix {
      Some(prefix) => {
        out.write_string("xmlns:")
        out.write_string(prefix)
      }
      None => out.write_string("xmlns")
    }
    out.write_string("=\"")
    out.write_string(@xml.escape_attribute_c14n(ns.uri))
    out.write_string("\"")
    active.push(ns)
  }
  let attributes = element.attributes.copy()
  sort_canonical_attributes(attributes)
  for attr in attributes {
    out.write_string(" ")
    out.write_string(format_algorithm_qname(attr.name))
    out.write_string("=\"")
    out.write_string(@xml.escape_attribute_c14n(attr.value))
    out.write_string("\"")
  }
  out.write_string(">")
  for child in element.children {
    match child {
      Element(child_element) =>
        write_canonical_element(out, child_element, active, with_comments~)
      Text(text) | CData(text) => out.write_string(@xml.escape_text_c14n(text))
      Comment(text) =>
        if with_comments {
          out.write_string("<!--")
          out.write_string(text)
          out.write_string("-->")
        }
      ProcessingInstruction(pi) => {
        out.write_string("<?")
        out.write_string(pi.target)
        if pi.data != "" {
          out.write_string(" ")
          out.write_string(pi.data)
        }
        out.write_string("?>")
      }
    }
  }
  out.write_string("</")
  out.write_string(format_algorithm_qname(element.name))
  out.write_string(">")
}

///|
fn collect_namespace_if_needed(
  namespaces : Array[NamespaceForCanonicalXml],
  active : Array[NamespaceForCanonicalXml],
  prefix : String?,
  ns : String?,
) -> Unit {
  match ns {
    Some(uri) =>
      if lookup_canonical_namespace(active, prefix) != Some(uri) &&
        !namespaces.contains({ prefix, uri }) {
        namespaces.push({ prefix, uri })
      }
    None =>
      if prefix == None &&
        lookup_canonical_namespace(active, None) is Some(current) &&
        current != "" {
        namespaces.push({ prefix: None, uri: "" })
      }
  }
}

///|
fn lookup_canonical_namespace(
  active : Array[NamespaceForCanonicalXml],
  prefix : String?,
) -> String? {
  let mut found : String? = None
  for item in active {
    if item.prefix == prefix {
      found = Some(item.uri)
    }
  }
  found
}

///|
fn sort_canonical_namespaces(items : Array[NamespaceForCanonicalXml]) -> Unit {
  for i in 1..<items.length() {
    let current = items[i]
    let mut j = i
    while j > 0 &&
          namespace_sort_key(current).lexical_compare(
            namespace_sort_key(items[j - 1]),
          ) <
          0 {
      items[j] = items[j - 1]
      j -= 1
    }
    items[j] = current
  }
}

///|
fn sort_canonical_attributes(items : Array[@xml.Attribute]) -> Unit {
  for i in 1..<items.length() {
    let current = items[i]
    let mut j = i
    while j > 0 &&
          attribute_sort_key(current).lexical_compare(
            attribute_sort_key(items[j - 1]),
          ) <
          0 {
      items[j] = items[j - 1]
      j -= 1
    }
    items[j] = current
  }
}

///|
fn namespace_sort_key(item : NamespaceForCanonicalXml) -> String {
  item.prefix.unwrap_or("")
}

///|
fn attribute_sort_key(item : @xml.Attribute) -> String {
  item.name.ns.unwrap_or("") + "\u{0}" + item.name.local_name
}

///|
fn algorithm_element_children(
  element : @xml.Element,
  path : String,
  section : String,
) -> Array[@xml.Element] raise @opc_errors.SchemaViolation {
  let children : Array[@xml.Element] = []
  for child in element.children {
    match child {
      Element(element) => children.push(element)
      Text(text) | CData(text) =>
        if text.trim() != "" {
          raise @opc_errors.SchemaViolation(
            section~,
            path~,
            reason="element-only content contains non-whitespace text",
          )
        }
      _ => ()
    }
  }
  children
}

///|
fn algorithm_required_attribute(
  element : @xml.Element,
  name : String,
  path : String,
  section : String,
) -> String raise @opc_errors.SchemaViolation {
  match algorithm_optional_attribute(element, name) {
    Some(value) =>
      if value == "" {
        raise @opc_errors.SchemaViolation(
          section~,
          path~,
          reason="required attribute is empty",
        )
      } else {
        value
      }
    None =>
      raise @opc_errors.SchemaViolation(
        section~,
        path~,
        reason="required attribute is missing",
      )
  }
}

///|
fn algorithm_optional_attribute(
  element : @xml.Element,
  name : String,
) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == name && attr.name.ns == None {
      return Some(attr.value)
    }
  }
  None
}

///|
fn optional_algorithm_attributes(
  values : Array[(String, String?)],
) -> Array[@xml.Attribute] {
  let attributes : Array[@xml.Attribute] = []
  for item in values {
    match item {
      (name, Some(value)) =>
        attributes.push({
          name: { prefix: None, local_name: name, ns: None },
          value,
        })
      (_, None) => ()
    }
  }
  attributes
}

///|
fn xmldsig_text_element(local_name : String, text : String) -> @xml.Element {
  {
    name: xmldsig_name_for_algorithm(local_name),
    attributes: [],
    children: [Text(text)],
  }
}

///|
fn xmldsig_name_for_algorithm(local_name : String) -> @xml.QName {
  {
    prefix: Some("ds"),
    local_name,
    ns: Some(xmldsig_namespace_for_algorithm()),
  }
}

///|
fn format_algorithm_qname(name : @xml.QName) -> String {
  match name.prefix {
    Some(prefix) => prefix + ":" + name.local_name
    None => name.local_name
  }
}

///|
fn is_algorithm_element(
  element : @xml.Element,
  local_name : String,
  ns : String,
) -> Bool {
  element.name.local_name == local_name && element.name.ns == Some(ns)
}

///|
fn element_text_for_algorithm(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(text) | CData(text) => out.write_string(text)
      _ => ()
    }
  }
  out.to_string()
}
