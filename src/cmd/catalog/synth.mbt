// Minimal schema-valid instance synthesiser.

///|
/// Sample value for a built-in xsd primitive, or "" when unknown.
fn primitive_sample(local : String) -> String {
  match local {
    "string" | "token" | "normalizedString" | "NCName" | "QName" => "x"
    "ID" | "IDREF" => "id1"
    "anyURI" => "rId1"
    "boolean" => "true"
    "int" | "integer" | "long" | "short" | "byte" => "1"
    "unsignedInt" | "unsignedLong" | "unsignedShort" | "unsignedByte" => "1"
    "nonNegativeInteger" | "positiveInteger" => "1"
    "decimal" | "double" | "float" => "1"
    "nonPositiveInteger" => "0"
    "negativeInteger" => "-1"
    "base64Binary" => "AA=="
    "hexBinary" => "00"
    "dateTime" => "2024-01-01T00:00:00Z"
    "date" => "2024-01-01"
    "time" => "00:00:00"
    "duration" => "P1D"
    "gYear" => "2024"
    _ => ""
  }
}

///|
/// A facet-valid sample value for the named simpleType or xsd
/// primitive.  Resolves restriction enumerations, unions and lists;
/// depth-bounded against cyclic type definitions.
fn sample_for_simple(
  schema : Schema,
  type_name : String,
  depth : Int,
) -> String {
  // `type_name` is a resolved `ns#localname` key (or, for an XSD
  // built-in, `http://www.w3.org/2001/XMLSchema#int` etc.).
  let local = match type_name.rev_find("#") {
    Some(i) => type_name[i + 1:].to_string()
    None => type_name
  }
  let prim = primitive_sample(local)
  if prim != "" {
    return prim
  }
  if depth > 8 {
    return "0"
  }
  match schema.simple_types.get(type_name) {
    None => "0"
    Some(st) => {
      // restriction -> first enumeration, else recurse on base.
      match xsd_child(st, "restriction") {
        Some(restr) => {
          let enums = xsd_children(restr, "enumeration")
          if enums.length() > 0 {
            return attr(enums[0], "value").unwrap_or("0")
          }
          match attr(restr, "base") {
            Some(base) => return sample_for_simple(schema, base, depth + 1)
            None => return "0"
          }
        }
        None => ()
      }
      // union -> first member type's sample.
      match xsd_child(st, "union") {
        Some(union) => {
          match attr(union, "memberTypes") {
            Some(members) => {
              let parts = members.split(" ")
              for part in parts {
                let p = part.to_string()
                if p.length() > 0 {
                  return sample_for_simple(schema, p, depth + 1)
                }
              }
            }
            None => ()
          }
          let inner = xsd_children(union, "simpleType")
          if inner.length() > 0 {
            match xsd_child(inner[0], "restriction") {
              Some(r) => {
                let e = xsd_children(r, "enumeration")
                if e.length() > 0 {
                  return attr(e[0], "value").unwrap_or("0")
                }
                match attr(r, "base") {
                  Some(b) => return sample_for_simple(schema, b, depth + 1)
                  None => ()
                }
              }
              None => ()
            }
          }
        }
        None => ()
      }
      // list -> a single item.
      match xsd_child(st, "list") {
        Some(lst) =>
          match attr(lst, "itemType") {
            Some(it) => return sample_for_simple(schema, it, depth + 1)
            None => ()
          }
        None => ()
      }
      "0"
    }
  }
}

///|
/// A facet-valid value for one `<xsd:attribute>` node.
fn attr_value_sample(schema : Schema, attribute : @xml.Element) -> String {
  match attr(attribute, "type") {
    Some(t) => sample_for_simple(schema, t, 0)
    None =>
      match xsd_child(attribute, "simpleType") {
        Some(inner) =>
          match xsd_child(inner, "restriction") {
            Some(r) => {
              let e = xsd_children(r, "enumeration")
              if e.length() > 0 {
                attr(e[0], "value").unwrap_or("0")
              } else {
                match attr(r, "base") {
                  Some(b) => sample_for_simple(schema, b, 0)
                  None => "0"
                }
              }
            }
            None => "0"
          }
        None => "0"
      }
  }
}

///|
/// A string set backed by a Map (the project does not depend on a
/// dedicated set package).
type StrSet = Map[String, Bool]

///|
/// True when `s` contains `k`.
fn set_has(s : StrSet, k : String) -> Bool {
  s.get(k) is Some(_)
}

///|
/// Collect the required (name -> value) attributes of `ct`, following
/// extension / restriction bases and attributeGroup references so an
/// attribute declared on an ancestor type is not missed.
fn collect_attrs(
  schema : Schema,
  ct : @xml.Element,
  found : Map[String, String],
  ct_stack : StrSet,
  ag_stack : StrSet,
) -> Unit {
  // Required <xsd:attribute> nodes anywhere in this type's subtree.
  let _ = schema
  for a in xsd_descendants(ct, "attribute") {
    if attr(a, "use") == Some("required") {
      // For an inline-declared attribute the key is the bare local
      // name; for `<xsd:attribute ref="prefix:name">` the key is
      // `prefix:name` so the downstream synthesiser (`synth_attrs`)
      // can split it back into a (prefix, local) pair and place
      // the attribute in the referenced attribute's namespace.
      // The diagram renderer reads `<dgm:relIds r:dm="..."/>` by
      // probing the `r:` (officedoc relationships) URI; without
      // namespace preservation the attribute would land in the
      // element's own namespace and the dispatcher would miss it.
      let key = match attr(a, "name") {
        Some(n) => n
        None =>
          match attr(a, "ref") {
            Some(r) => r
            None => ""
          }
      }
      if key != "" && !found.contains(key) {
        found[key] = attr_value_sample(schema, a)
      }
    }
  }
  // attributeGroup references — `ref` is an already-resolved
  // `ns#localname` key.
  for agref in xsd_descendants(ct, "attributeGroup") {
    match attr(agref, "ref") {
      Some(ref_key) =>
        if !set_has(ag_stack, ref_key) {
          match schema.attr_groups.get(ref_key) {
            Some(ag) => {
              ag_stack[ref_key] = true
              collect_attrs(schema, ag, found, ct_stack, ag_stack)
            }
            None => ()
          }
        }
      None => ()
    }
  }
  // extension / restriction base type — `base` is a resolved key.
  match xsd_child(ct, "complexContent") {
    Some(content) =>
      for kind in ["extension", "restriction"] {
        match xsd_child(content, kind) {
          Some(ext) =>
            match attr(ext, "base") {
              Some(base) =>
                if !set_has(ct_stack, base) {
                  match schema.complex_types.get(base) {
                    Some(base_ct) => {
                      ct_stack[base] = true
                      collect_attrs(schema, base_ct, found, ct_stack, ag_stack)
                    }
                    None => ()
                  }
                }
              None => ()
            }
          None => ()
        }
      }
    None => ()
  }
}
