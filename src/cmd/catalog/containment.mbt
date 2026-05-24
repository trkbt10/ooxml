// Schema containment graph + upward host-path resolution.
//
// An element whose namespace has no standalone document part (a
// DrawingML path command, a VML drawing element, a chart sub-element)
// cannot be verified by dropping it at a document body — it is only
// schema-valid inside a specific parent chain.  This module derives,
// mechanically from the XSD, the chain of wrapper elements from a
// document-part root down to any element, so the verifier can embed
// each element where the schema actually permits it.

///|
/// A (element-name, type-local-name) pair — the node identity in the
/// containment graph.  Keyed as "name\u{0000}type" in maps.
fn nt_key(name : String, type_ln : String) -> String {
  name + "\u{0000}" + type_ln
}

///|
/// The element-name part of an `nt_key`.
fn nt_name(key : String) -> String {
  match key.find("\u{0000}") {
    Some(i) => key[0:i].to_string()
    None => key
  }
}

///|
/// The (name, type) of one `<xsd:element>` particle — resolving a
/// `ref=` element through the referenced top-level declaration.
fn element_nt(schema : Schema, el : @xml.Element) -> (String, String) {
  // An element `ref` keeps its bare name (elements resolve by name);
  // a `type` is an already-resolved `ns#localname` key.
  let nm = match attr(el, "name") {
    Some(n) => n
    None =>
      match attr(el, "ref") {
        Some(r) => local_name(r)
        None => ""
      }
  }
  let ty = match attr(el, "type") {
    Some(t) => t
    None =>
      match attr(el, "ref") {
        Some(r) =>
          match schema.top_elements.get(local_name(r)) {
            Some((top, _)) =>
              match attr(top, "type") {
                Some(tt) => tt
                None => "__inline__"
              }
            None => "__inline__"
          }
        None => "__inline__"
      }
  }
  (nm, ty)
}

///|
/// The set of child (name, type) pairs a complexType can contain.
/// Group references are expanded *transitively* — `<w:p>` lives many
/// nested groups deep under `CT_Body` (EG_BlockLevelElts ->
/// EG_ContentBlockContent -> p), so a one-level expansion misses it.
fn type_children(schema : Schema, ct : @xml.Element) -> Array[(String, String)] {
  let out : Array[(String, String)] = []
  // Direct `<xsd:element>` children, plus those inside any
  // (transitively) referenced group.  `seen_groups` guards against a
  // group that references itself.
  let seen_groups : Map[String, Bool] = Map::new()
  fn collect(node : @xml.Element) -> Unit {
    // Walk this node's whole subtree; for every `<xsd:element>`
    // record it, and for every `<xsd:group ref>` recurse into the
    // referenced group definition.
    fn walk(e : @xml.Element) -> Unit {
      if is_xsd(e, "element") {
        let (nm, ty) = element_nt(schema, e)
        if nm != "" {
          out.push((nm, ty))
        }
        // An element node has no particle children to follow.
        return
      }
      if is_xsd(e, "group") {
        match attr(e, "ref") {
          Some(gname) =>
            // `ref` on a group is an already-resolved `ns#localname`.
            if not(seen_groups.contains(gname)) {
              seen_groups[gname] = true
              match schema.groups.get(gname) {
                Some(gp) => collect(gp)
                None => ()
              }
            }
          None =>
            // A named group *definition* nested inline: descend.
            for child in e.children {
              match child {
                Element(c) => walk(c)
                _ => ()
              }
            }
        }
        return
      }
      // sequence / choice / all / complexContent / extension / … —
      // descend into the particle structure.
      for child in e.children {
        match child {
          Element(c) => walk(c)
          _ => ()
        }
      }
    }

    walk(node)
  }

  collect(ct)
  out
}

///|
/// True when a complexType's content model contains an `<xsd:any>`
/// wildcard — an open extension point (e.g. `CT_GraphicalObjectData`,
/// where DrawingML tables / charts / diagrams are spliced in).  Such
/// a type can legally contain any element.
fn type_has_any(ct : @xml.Element) -> Bool {
  xsd_descendants(ct, "any").length() > 0
}

///|
/// The three document-part root elements a fixture can be built
/// around, with their type names.
fn part_roots(schema : Schema) -> Array[(String, String)] {
  let roots : Array[(String, String)] = []
  for name in ["document", "worksheet", "sld"] {
    match schema.top_elements.get(name) {
      Some((el, _)) =>
        // The root element's `type` is a resolved `ns#localname`.
        match attr(el, "type") {
          Some(t) => roots.push((name, t))
          None => ()
        }
      None => ()
    }
  }
  roots
}

///|
/// For every reachable (element, type) pair, the wrapper chain — as
/// (name, type) pairs — from a part-root element down to (and
/// excluding) it.  BFS over the containment graph; each complexType
/// is expanded once.  The chain's first entry is always a part root
/// (`document` / `worksheet` / `sld`).
fn build_ancestry(schema : Schema) -> Map[String, Array[(String, String)]] {
  let ancestry : Map[String, Array[(String, String)]] = Map::new()
  let expanded : Map[String, Bool] = Map::new()
  // Queue of (name, type, path-of-(name,type)-down-to-parent).
  let queue : Array[(String, String, Array[(String, String)])] = []
  for root in part_roots(schema) {
    let (rname, rtype) = root
    queue.push((rname, rtype, []))
  }
  // `xsd:any`-bearing types reached during the named BFS, recorded
  // with the path down to their content slot — used only as a
  // fallback after the named graph is exhausted.
  let any_hosts : Array[Array[(String, String)]] = []
  let mut head = 0
  // Phase 1: named-containment BFS to its fixpoint.  Every element
  // reachable through named element / group particles gets its
  // *proper* schema path — this is shortest-first by queue order.
  while head < queue.length() {
    let (cur_name, cur_type, path) = queue[head]
    head = head + 1
    let key = nt_key(cur_name, cur_type)
    if not(ancestry.contains(key)) {
      ancestry[key] = path
    }
    if expanded.get(cur_type) is Some(_) {
      continue
    }
    expanded[cur_type] = true
    match schema.complex_types.get(cur_type) {
      None => ()
      Some(ct) => {
        let child_path = path + [(cur_name, cur_type)]
        for child in type_children(schema, ct) {
          let (cname, ctype) = child
          let ckey = nt_key(cname, ctype)
          if not(ancestry.contains(ckey)) {
            ancestry[ckey] = child_path
            queue.push((cname, ctype, child_path))
          }
        }
        if type_has_any(ct) {
          any_hosts.push(child_path)
        }
      }
    }
  }
  // Phase 2: an `<xsd:any>` extension point (e.g.
  // CT_GraphicalObjectData) legally accepts any element.  Route only
  // the elements the named BFS could NOT reach through such a host,
  // so an element that has a real named path keeps it.
  for host_path in any_hosts {
    for _k, decl in schema.all_elements {
      let ckey = nt_key(decl.name, decl.type_name)
      if not(ancestry.contains(ckey)) {
        ancestry[ckey] = host_path
      }
    }
  }
  ancestry
}

///|
/// Wrap `target` in its schema ancestry chain so the result is a
/// schema-valid `@xml.Element` subtree of a document part.
///
/// Built inside-out as a real element tree: at each ancestry level
/// the wrapper element is fully synthesised (`synth_element` — every
/// required attribute and child, including the correct branch of a
/// required `<xsd:choice>` such as `EG_WrapType`), then the
/// already-built `inner` element replaces the wrapper's child of the
/// same name (or is appended when the wrapper declares that child
/// only optionally — most container nesting).
///
/// `skip_depth` leading ancestry elements are omitted — the caller's
/// host package already supplies them (the part-root element).
fn wrap_in_ancestry(
  schema : Schema,
  path : Array[(String, String)],
  skip_depth : Int,
  target : @xml.Element,
) -> @xml.Element {
  let mut inner = target
  let mut i = path.length() - 1
  while i >= skip_depth {
    let (wname, wtype) = path[i]
    // The element name the ancestry continues through: the next
    // path element, or — at the innermost wrapper — the target.
    let path_child = if i + 1 < path.length() {
      path[i + 1].0
    } else {
      target.name.local_name
    }
    let wrapper = match schema.complex_types.get(wtype) {
      Some(wct) => {
        let stack : StrSet = Map::new()
        stack[wtype] = true
        // Ancestry wrappers are synthesised with a modest rich budget
        // so the immediate context is non-degenerate: the `<w:r>`
        // that wraps an `<w:rPr>` (which holds the element under
        // test, e.g. `<w:b>`) then carries a `<w:t>` text sibling, so
        // a formatting property has something visible to act on.
        // The SAME wrapper noise appears in both the present and
        // absent differential trees, so the diff still isolates the
        // target element itself.
        synth_element(
          schema,
          wct,
          schema.type_ns.get(wtype).unwrap_or(""),
          wname,
          stack,
          1,
          WRAPPER_RICH_BUDGET,
        )
      }
      None =>
        // No type info — a bare wrapper element.
        elem(schema.type_ns.get(wtype).unwrap_or(""), wname, [], [])
    }
    inner = insert_path_child(wrapper, path_child, inner)
    i = i - 1
  }
  inner
}

///|
/// Return a copy of `wrapper` whose child element named `child_name`
/// is replaced by `inner`.  When `wrapper` has no such child (the
/// content model declared it only optionally) `inner` is appended as
/// a child instead.
fn insert_path_child(
  wrapper : @xml.Element,
  child_name : String,
  inner : @xml.Element,
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut replaced = false
  for child in wrapper.children {
    match child {
      Element(c) if c.name.local_name == child_name && not(replaced) => {
        kids.push(Element(inner))
        replaced = true
      }
      other => kids.push(other)
    }
  }
  if not(replaced) {
    kids.push(Element(inner))
  }
  { name: wrapper.name, attributes: wrapper.attributes, children: kids }
}
