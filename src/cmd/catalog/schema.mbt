// Global schema symbol table + minimal-instance synthesiser.
//
// Loads every XSD across the ECMA-376 schema sets into one symbol
// table.  Crucially, every type / group / base reference is resolved
// to a *namespace-qualified* key (`ns#localname`) at load time, so a
// type name that exists in several namespaces — `CT_R` is both the
// WordprocessingML run and the Office-Math run — never collides.
//
// For each named element it then synthesises a minimal schema-valid
// XML instance: required attributes get a facet-valid value, required
// child elements (minOccurs >= 1) are recursed, group /
// attributeGroup references are expanded, and extension / restriction
// bases are merged.  Recursion is depth-bounded and cycle-guarded.

///|
/// Build the namespace-qualified key `ns#localname` for a symbol.
fn qkey(ns : String, local : String) -> String {
  ns + "#" + local
}

///|
/// One element declaration: its (name, resolved-type) pair plus the
/// schema lineages it appears in.
struct ElemDecl {
  name : String
  /// Resolved type key `ns#localname`, or "__inline__" / "__empty__".
  type_name : String
  /// The XSD `<element>` node (so an inline type can be recovered).
  node : @xml.Element
  /// Target namespace of the schema file the declaration came from.
  namespace : String
  /// Schema generations the declaration appears in.
  lineages : Array[String]
}

///|
/// The merged global symbol table across every loaded XSD.  All four
/// symbol maps are keyed by the qualified `ns#localname`.
struct Schema {
  complex_types : Map[String, @xml.Element]
  simple_types : Map[String, @xml.Element]
  groups : Map[String, @xml.Element]
  attr_groups : Map[String, @xml.Element]
  /// Qualified type key -> the namespace it was declared in.
  type_ns : Map[String, String]
  /// Top-level element name -> (node, target namespace).
  top_elements : Map[String, (@xml.Element, String)]
  /// Every (element name, resolved-type) declaration, keyed
  /// "name\u{0000}type" so distinct (name, type) pairs are separate.
  all_elements : Map[String, ElemDecl]
}

///|
/// Construct an empty symbol table.
fn Schema::new() -> Schema {
  {
    complex_types: Map::new(),
    simple_types: Map::new(),
    groups: Map::new(),
    attr_groups: Map::new(),
    type_ns: Map::new(),
    top_elements: Map::new(),
    all_elements: Map::new(),
  }
}

///|
/// Build a file's prefix -> namespace map from the `xmlns:*` (and
/// default `xmlns`) declarations on its `<xsd:schema>` root.
///
/// The XML parser consumes namespace declarations into its internal
/// context — they are NOT retained on `Element.attributes` — so the
/// map is recovered by scanning the raw XSD text for the root tag's
/// `xmlns` attributes.  An unprefixed type reference resolves through
/// the default namespace; in the OOXML XSDs that is the schema's own
/// target namespace.
fn prefix_map(xsd_text : String) -> Map[String, String] {
  let m : Map[String, String] = Map::new()
  // Limit the scan to the opening `<xsd:schema …>` tag.
  let tag_end = find_at(xsd_text, ">", find_schema_tag(xsd_text)).unwrap_or(
    xsd_text.length(),
  )
  let head = xsd_text[0:tag_end].to_string()
  // Scan for `xmlns` / `xmlns:prefix` = "uri" occurrences.
  let mut i = 0
  while i < head.length() {
    match find_at(head, "xmlns", i) {
      None => break
      Some(pos) => {
        let mut j = pos + 5
        let mut prefix = ""
        if j < head.length() && head.code_unit_at(j) == ':' {
          j = j + 1
          let pstart = j
          while j < head.length() && head.code_unit_at(j) != '=' {
            j = j + 1
          }
          // The slice between `:` and `=` is the prefix, modulo
          // surrounding whitespace.
          let mut ps = pstart
          let mut pe = j
          while ps < pe && head.code_unit_at(ps) == ' ' {
            ps = ps + 1
          }
          while pe > ps && head.code_unit_at(pe - 1) == ' ' {
            pe = pe - 1
          }
          prefix = head[ps:pe].to_string()
        } else {
          // Skip whitespace to the '='.
          while j < head.length() &&
                head.code_unit_at(j) != '=' &&
                head.code_unit_at(j) != ' ' {
            break
          }
        }
        // Step to the quoted value.
        match find_at(head, "\"", j) {
          None => {
            i = pos + 5
            continue
          }
          Some(q1) =>
            match find_at(head, "\"", q1 + 1) {
              None => {
                i = pos + 5
                continue
              }
              Some(q2) => {
                let uri = head[q1 + 1:q2].to_string()
                m[prefix] = uri
                i = q2 + 1
              }
            }
        }
      }
    }
  }
  m
}

///|
/// Index of the `<xsd:schema` / `<xs:schema` / `<schema` root tag.
fn find_schema_tag(text : String) -> Int {
  match find_at(text, "schema", 0) {
    Some(i) => i
    None => 0
  }
}

///|
/// Resolve an XSD QName reference (`type` / `ref` / `base` value) to
/// the qualified key `ns#localname`, using the declaring file's
/// prefix map.  An unprefixed name uses the default namespace.
fn resolve_qname(qname : String, prefixes : Map[String, String]) -> String {
  match qname.find(":") {
    Some(i) => {
      let pfx = qname[0:i].to_string()
      let local = qname[i + 1:].to_string()
      let ns = prefixes.get(pfx).unwrap_or("")
      qkey(ns, local)
    }
    None => {
      let ns = prefixes.get("").unwrap_or("")
      qkey(ns, qname)
    }
  }
}

///|
/// Merge one parsed XSD root into the symbol table, tagging every
/// declaration it introduces with `lineage`.
fn Schema::load(
  self : Schema,
  root : @xml.Element,
  xsd_text : String,
  lineage : String,
) -> Unit {
  let tns = attr(root, "targetNamespace").unwrap_or("")
  let prefixes = prefix_map(xsd_text)
  // Resolve every QName reference in the file to `ns#localname` form,
  // rewriting the attribute in place so all downstream lookups are
  // namespace-correct without threading file context.
  rewrite_refs(root, prefixes)
  // Stamp every `<xsd:element>` with the file's target namespace via
  // a synthetic `__ns` attribute.  `elementFormDefault="qualified"`
  // in every OOXML XSD means a locally-declared element lives in its
  // schema's target namespace — and that, NOT the element's type's
  // namespace, is the namespace the instance element must carry.
  for el in xsd_descendants(root, "element") {
    if attr(el, "__ns") is None {
      el.attributes.push({
        name: { prefix: None, local_name: "__ns", ns: None },
        value: tns,
      })
    }
  }

  for ct in xsd_children(root, "complexType") {
    match attr(ct, "name") {
      Some(name) => {
        let key = qkey(tns, name)
        if !self.complex_types.contains(key) {
          self.complex_types[key] = ct
        }
        self.type_ns[key] = tns
      }
      None => ()
    }
  }
  for st in xsd_children(root, "simpleType") {
    match attr(st, "name") {
      Some(name) => {
        let key = qkey(tns, name)
        if !self.simple_types.contains(key) {
          self.simple_types[key] = st
        }
        self.type_ns[key] = tns
      }
      None => ()
    }
  }
  for gp in xsd_children(root, "group") {
    match attr(gp, "name") {
      Some(name) => {
        let key = qkey(tns, name)
        if !self.groups.contains(key) {
          self.groups[key] = gp
        }
      }
      None => ()
    }
  }
  for ag in xsd_children(root, "attributeGroup") {
    match attr(ag, "name") {
      Some(name) => {
        let key = qkey(tns, name)
        if !self.attr_groups.contains(key) {
          self.attr_groups[key] = ag
        }
      }
      None => ()
    }
  }
  for el in xsd_children(root, "element") {
    match attr(el, "name") {
      Some(name) =>
        if !self.top_elements.contains(name) {
          self.top_elements[name] = (el, tns)
        }
      None => ()
    }
  }
  // Harvest every element declaration anywhere in the file —
  // top-level and nested in complexType / group content models.
  for el in xsd_descendants(root, "element") {
    match attr(el, "name") {
      None => ()
      Some(name) => {
        // `type` is now an already-resolved `ns#localname` (or
        // absent -> inline / empty).
        let etype = match attr(el, "type") {
          Some(t) => t
          None =>
            match xsd_child(el, "complexType") {
              Some(_) => "__inline__"
              None => "__empty__"
            }
        }
        let key = name + "\u{0000}" + etype
        match self.all_elements.get(key) {
          Some(decl) =>
            if !decl.lineages.contains(lineage) {
              decl.lineages.push(lineage)
            }
          None =>
            self.all_elements[key] = {
              name,
              type_name: etype,
              node: el,
              namespace: tns,
              lineages: [lineage],
            }
        }
      }
    }
  }
}

///|
/// Rewrite every XSD QName-valued attribute in the subtree — `type`,
/// `base`, `itemType`, `ref`, `substitutionGroup`, `memberTypes` — to
/// the resolved `ns#localname` form, in place.  `ref` on an element
/// is left as a bare local name (element refs resolve by element
/// name, looked up in `top_elements`); only type-space references are
/// qualified.
fn rewrite_refs(root : @xml.Element, prefixes : Map[String, String]) -> Unit {
  fn visit(el : @xml.Element) -> Unit {
    let is_attr_group = is_xsd(el, "attributeGroup")
    let is_group = is_xsd(el, "group")
    let attrs = el.attributes
    for i in 0..<attrs.length() {
      let a = attrs[i]
      let nm = a.name.local_name
      let rewrite = match nm {
        "type" | "base" | "itemType" => true
        // `ref` is qualified only for group / attributeGroup refs;
        // an element `ref` keeps its bare name.
        "ref" => is_group || is_attr_group
        _ => false
      }
      if rewrite {
        attrs[i] = { name: a.name, value: resolve_qname(a.value, prefixes) }
      } else if nm == "memberTypes" {
        // A union's memberTypes is a space-separated QName list.
        let parts = a.value.split(" ")
        let out = StringBuilder::new()
        let mut first = true
        for part in parts {
          let p = part.to_string()
          if p.length() > 0 {
            if not(first) {
              out.write_char(' ')
            }
            first = false
            out.write_string(resolve_qname(p, prefixes))
          }
        }
        attrs[i] = { name: a.name, value: out.to_string() }
      }
    }
    for child in el.children {
      match child {
        Element(c) => visit(c)
        _ => ()
      }
    }
  }

  visit(root)
}
