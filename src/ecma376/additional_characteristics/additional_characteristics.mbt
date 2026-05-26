///|
/// ECMA-376 Part 1 §22.7 Additional Characteristics.
///
/// Schema shared-additionalCharacteristics.xsd contains the top-level
/// additionalCharacteristics element, CT_AdditionalCharacteristics,
/// CT_Characteristic, and XSD simple type ST_Relation.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/additional_characteristics"
}

///|
/// Schema shared-additionalCharacteristics.xsd validation error.
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String)
} derive(Debug)

///|
/// XSD simple type ST_Relation. Enumerates the relation between an additional
/// characteristic value and the document property: ge, le, gt, lt, eq.
/// ResourceMissing belongs to the surrounding package resolver contract, not
/// to this closed string enumeration.
pub(all) enum ST_Relation {
  Ge
  Le
  Gt
  Lt
  Eq
} derive(Eq, Debug)

///|
/// Parse the ST_Relation simple-type lexical value.
pub fn ST_Relation::parse(s : String) -> ST_Relation raise SchemaViolation {
  match s {
    "ge" => Ge
    "le" => Le
    "gt" => Gt
    "lt" => Lt
    "eq" => Eq
    _ => raise SchemaViolation(type_name="ST_Relation", value=s)
  }
}

///|
/// Return the schema lexical value for ST_Relation.
pub fn ST_Relation::to_string(self : ST_Relation) -> String {
  match self {
    Ge => "ge"
    Le => "le"
    Gt => "gt"
    Lt => "lt"
    Eq => "eq"
  }
}

///|
/// XSD complex type CT_Characteristic — Part 1 §22.6.2.2 / Annex A.6.7. A
/// single entry in the additionalCharacteristics root carrying the required
/// `name`, `relation`, `val` attributes and an optional `vocabulary` URI.
pub(all) struct CT_Characteristic {
  name : String
  relation : ST_Relation
  val : String
  vocabulary : String?
} derive(Eq, Debug)

///|
/// Build CT_Characteristic, enforcing the required attribute set defined by
/// shared-additionalCharacteristics.xsd (§22.6.2.2).
pub fn CT_Characteristic::new(
  name~ : String,
  relation~ : ST_Relation,
  val~ : String,
  vocabulary? : String? = None,
) -> CT_Characteristic raise SchemaViolation {
  if name.length() == 0 {
    raise SchemaViolation(type_name="CT_Characteristic/@name", value=name)
  }
  if val.length() == 0 {
    raise SchemaViolation(type_name="CT_Characteristic/@val", value=val)
  }
  { name, relation, val, vocabulary }
}

///|
/// XSD complex type CT_AdditionalCharacteristics — Part 1 §22.6.2.1 / Annex
/// A.6.7. Root of the additionalCharacteristics document with zero or more
/// CT_Characteristic children, preserving schema order.
pub(all) struct CT_AdditionalCharacteristics {
  characteristics : Array[CT_Characteristic]
} derive(Eq, Debug)

///|
/// Build CT_AdditionalCharacteristics from a possibly empty characteristic
/// sequence; sequence order is preserved for §22.6.2.1 conformance.
pub fn CT_AdditionalCharacteristics::new(
  characteristics : Array[CT_Characteristic],
) -> CT_AdditionalCharacteristics {
  { characteristics, }
}

///|
/// Iterate the CT_Characteristic children in document order.
pub fn CT_AdditionalCharacteristics::iter(
  self : CT_AdditionalCharacteristics,
) -> Iter[CT_Characteristic] {
  self.characteristics.iter()
}

///|
/// Read top-level XSD element additionalCharacteristics (§22.6.2.1) into
/// CT_AdditionalCharacteristics by parsing the XML bytes, validating the
/// root element name, and materialising every CT_Characteristic child in
/// document order.
pub fn read_additional_characteristics(
  bytes : Bytes,
) -> CT_AdditionalCharacteristics raise {
  let root = @xml.parse(bytes).root
  if root.name.local_name != "additionalCharacteristics" {
    raise SchemaViolation(
      type_name="additionalCharacteristics",
      value=root.name.local_name,
    )
  }
  let characteristics : Array[CT_Characteristic] = []
  for child in root.children {
    match child {
      Element(child_element) => {
        if child_element.name.local_name != "characteristic" {
          continue
        }
        let name = attr_value(child_element, "name")
        let relation_raw = attr_value(child_element, "relation")
        let val = attr_value(child_element, "val")
        let vocabulary = optional_attr_value(child_element, "vocabulary")
        let relation = ST_Relation::parse(relation_raw)
        characteristics.push(
          CT_Characteristic::new(name~, relation~, val~, vocabulary~),
        )
      }
      _ => ()
    }
  }
  CT_AdditionalCharacteristics::new(characteristics)
}

///|
/// §22.6.2.1 — serialize a `CT_AdditionalCharacteristics` value
/// to the canonical `<additionalCharacteristics>` XML byte
/// stream.  Every `<characteristic>` child is emitted with its
/// `name`, `relation`, `val`, and optional `vocabulary`
/// attributes; the root element carries the spec-mandated
/// `xmlns="http://schemas.openxmlformats.org/officeDocument/2006/characteristics"`
/// namespace declaration so consumers can round-trip the part.
///
/// Mirrors `read_additional_characteristics` so the pair forms
/// a lossless round-trip (modulo attribute ordering, which is
/// canonicalised to `name relation val vocabulary` for
/// determinism).
pub fn write_additional_characteristics(
  value : CT_AdditionalCharacteristics,
) -> Bytes {
  let ns_chars = "http://schemas.openxmlformats.org/officeDocument/2006/characteristics"
  let root_qn : @xml.QName = {
    prefix: None,
    local_name: "additionalCharacteristics",
    ns: Some(ns_chars),
  }
  let attr_qn = fn(local_name : String) -> @xml.QName {
    { prefix: None, local_name: local_name, ns: None }
  }
  let attrs : Array[@xml.Attribute] = [
    // §22.6.2.1 — single mandatory namespace declaration.
    {
      name: { prefix: Some("xmlns"), local_name: "", ns: None },
      value: ns_chars,
    },
  ]
  let children : Array[@xml.Node] = []
  for ch in value.characteristics {
    let ch_attrs : Array[@xml.Attribute] = [
      { name: attr_qn("name"), value: ch.name },
      { name: attr_qn("relation"), value: ch.relation.to_string() },
      { name: attr_qn("val"), value: ch.val },
    ]
    match ch.vocabulary {
      Some(v) => ch_attrs.push({ name: attr_qn("vocabulary"), value: v })
      None => ()
    }
    let elt : @xml.Element = {
      name: { prefix: None, local_name: "characteristic", ns: Some(ns_chars) },
      attributes: ch_attrs,
      children: [],
    }
    children.push(@xml.Node::Element(elt))
  }
  let root : @xml.Element = { name: root_qn, attributes: attrs, children }
  @xml.write({
    declaration: Some({
      version: "1.0",
      encoding: Some("UTF-8"),
      standalone: Some(true),
    }),
    doctype: None,
    root,
  })
}

///|
/// Return the unprefixed value for the named attribute or raise a
/// SchemaViolation if missing.
fn attr_value(
  element : @xml.Element,
  local_name : String,
) -> String raise SchemaViolation {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return attribute.value
    }
  }
  raise SchemaViolation(type_name="CT_Characteristic/@" + local_name, value="")
}

///|
/// Return the unprefixed value for the named attribute, or None.
fn optional_attr_value(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}
