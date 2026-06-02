// complexType -> minimal valid instance, built as an `@xml.Element`
// tree.
//
// Every synthesised node is a real `@xml.Element`; the tree is
// serialised once by `@xml.write`, which escapes text and attribute
// values.  No XML is ever assembled by string concatenation — a
// `<`/`&` in a sample value can never break the markup.

///|
/// Placeholder token emitted as `simpleContent` text.  The verifier
/// substitutes a per-element unique marker for it and then asserts
/// the marker survives into the rendered SVG — distinguishing a
/// genuinely rendered element from one the renderer silently drops.
const TEXT_MARKER : String = "CATMARK"

///|
/// Synthesis budget for the element UNDER TEST.  A schema-minimal
/// instance is frequently visually degenerate (an empty paragraph, a
/// row-less table) and renders to nothing; with this budget the
/// synthesiser also emits each optional particle once, for several
/// nesting levels, so the instance carries the content the renderer
/// needs to actually draw something.
const RICH_BUDGET : Int = 4

///|
/// Synthesis budget for an ancestry WRAPPER element.  A wrapper needs
/// enough optional content that the element under test has a visible
/// context to act on — a `<w:r>` wrapper carrying a `<w:t>` text
/// sibling, so an embedded `<w:b>` actually bolds something.  Kept
/// modest so the wrapper subtree stays small; the same wrapper noise
/// appears in BOTH differential trees, so it never confounds the diff.
const WRAPPER_RICH_BUDGET : Int = 3

///|
/// Namespace-URI -> short prefix mapping, installed once by `main`.
/// Every synthesised element carries the prefix and namespace of its
/// OWN namespace (`<xsd:element>` `__ns`), not its type's namespace.
let g_ns_prefix : Ref[(String) -> String] = { val: fn(_ns) { "x" } }

///|
/// Build an `@xml.QName` for an element/attribute in namespace `ns`.
fn qname(ns : String, local_name : String) -> @xml.QName {
  { prefix: Some((g_ns_prefix.val)(ns)), local_name, ns: Some(ns) }
}

///|
/// True when the synthesized element has at least one Element child.
fn has_element_children(el : @xml.Element) -> Bool {
  for child in el.children {
    if child is Element(_) {
      return true
    }
  }
  false
}

///|
/// True when the complex type has at least one required (minOccurs>=1)
/// child element particle at the top level of its content model.
/// Used by cycle detection: an empty element of such a type is
/// schema-invalid (e.g. CT_Divs requires ≥1 <div>).
fn has_required_child_elements(ct : @xml.Element) -> Bool {
  fn scan(node : @xml.Element) -> Bool {
    for child in node.children {
      match child {
        Element(c) =>
          if is_xsd(c, "element") {
            let min = (try? @string.parse_int(
              attr(c, "minOccurs").unwrap_or("1"),
            )).unwrap_or(1)
            if min >= 1 {
              return true
            }
          } else if is_xsd(c, "sequence") ||
            is_xsd(c, "all") ||
            is_xsd(c, "choice") {
            if scan(c) {
              return true
            }
          }
        _ => ()
      }
    }
    false
  }

  scan(ct)
}

///|
/// Build an `@xml.Element` with the given namespace, name, attributes
/// and children.
fn elem(
  ns : String,
  name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  { name: qname(ns, name), attributes: attrs, children }
}

///|
fn is_spreadsheet_drawing_ns(ns : String) -> Bool {
  ns == "http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing" ||
  ns == "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
}

///|
/// Keep synthesised SpreadsheetDrawing anchors non-degenerate. The
/// generic simple-type sample for ST_ColID / ST_RowID is "1"; when
/// both `<xdr:from>` and `<xdr:to>` inherit that value the SML viewer
/// correctly skips the zero-sized anchor. Normalize only the marker
/// endpoints here so every catalog host observes the same fixture.
fn normalize_spreadsheet_drawing_marker(el : @xml.Element) -> @xml.Element {
  let ns = match el.name.ns {
    Some(v) => v
    None => ""
  }
  if !is_spreadsheet_drawing_ns(ns) ||
    (el.name.local_name != "from" && el.name.local_name != "to") {
    return el
  }
  let col = if el.name.local_name == "to" { "3" } else { "0" }
  let row = if el.name.local_name == "to" { "5" } else { "0" }
  let children : Array[@xml.Node] = []
  for child in el.children {
    match child {
      Element(ce) => {
        let value = match ce.name.local_name {
          "col" => Some(col)
          "row" => Some(row)
          "colOff" | "rowOff" => Some("0")
          _ => None
        }
        match value {
          Some(v) =>
            children.push(
              Element({
                name: ce.name,
                attributes: ce.attributes,
                children: [Text(v)],
              }),
            )
          None => children.push(child)
        }
      }
      _ => children.push(child)
    }
  }
  { name: el.name, attributes: el.attributes, children }
}

///|
/// The namespace an `<xsd:element>` node declares its instance in
/// (its `__ns` stamp), or "" when unstamped.
fn element_ns(el : @xml.Element) -> String {
  attr(el, "__ns").unwrap_or("")
}

///|
/// True when any node in `nodes` carries a `TEXT_MARKER` text node
/// somewhere in its subtree — i.e. the branch leads to traceable,
/// renderable text.
fn nodes_have_marker(nodes : Array[@xml.Node]) -> Bool {
  fn node_has(n : @xml.Node) -> Bool {
    match n {
      Text(t) => t == TEXT_MARKER
      Element(e) => {
        for c in e.children {
          if node_has(c) {
            return true
          }
        }
        false
      }
      _ => false
    }
  }

  for n in nodes {
    if node_has(n) {
      return true
    }
  }
  false
}

///|
/// Collect the required (name -> value) attributes of `ct`, as
/// `@xml.Attribute`s in namespace `ns`.
fn synth_attrs(
  schema : Schema,
  ct : @xml.Element,
  ns : String,
  include_optional? : Bool = false,
) -> Array[@xml.Attribute] {
  let found : Map[String, String] = Map([], capacity=0)
  collect_attrs(
    schema,
    ct,
    found,
    Map([], capacity=0),
    Map([], capacity=0),
    include_optional~,
  )
  let out : Array[@xml.Attribute] = []
  for key, value in found {
    // `key` is either a bare local name (inline `<xsd:attribute
    // name="x"/>`) or `prefix:localname` (a `ref="prefix:name"`
    // reference — `<xsd:attribute ref="r:dm"/>` keeps its raw
    // prefix because rewrite_refs leaves attribute refs alone, see
    // the comment there).  An inline attribute inherits the
    // element's own namespace; a prefixed-ref attribute carries
    // the namespace the prefix resolves to (so `r:` maps to the
    // officedoc-relationships URI the diagram renderer reads).
    match key.find(":") {
      None => out.push({ name: qname(ns, key), value })
      Some(i) => {
        let prefix = key[0:i].to_owned()
        let local_name = key[i + 1:].to_owned()
        let attr_ns = (g_prefix_ns.val)(prefix)
        out.push({ name: qname(attr_ns, local_name), value })
      }
    }
  }
  out
}

///|
/// Prefix → namespace URI mapping, installed once by `main`.  Used
/// by `synth_attrs` to recover the namespace of an
/// `<xsd:attribute ref="prefix:name">` reference whose raw prefix
/// stays in the synthesised key (rewrite_refs intentionally leaves
/// attribute refs alone to avoid a slow in-place tree mutation).
let g_prefix_ns : Ref[(String) -> String] = { val: fn(_p) { "" } }

///|
/// Synthesise the children of a sequence / choice / all particle list
/// as `@xml.Node`s.
///
/// `rich` is a synthesis budget.  At `rich == 0` only the schema
/// MINIMUM is emitted (`minOccurs`-many of each required particle) —
/// the instance is the smallest schema-valid one.  At `rich >= 1`
/// each OPTIONAL particle (`minOccurs="0"`) is additionally emitted
/// once: a paragraph then gets a run, a table a row, a shape a
/// geometry — a visually non-degenerate instance the renderer can
/// actually draw.  The budget decrements with element nesting (see
/// `element_instance`) so the enriched subtree stays bounded.
///
/// For a `choice`, exactly one branch is taken regardless of `rich`.
fn model_particles(
  schema : Schema,
  container : @xml.Element,
  stack : StrSet,
  depth : Int,
  choice : Bool,
  rich : Int,
) -> Array[@xml.Node] {
  let branches : Array[Array[@xml.Node]] = []
  for child in container.children {
    match child {
      Element(p) => {
        let min_occurs = (try? @string.parse_int(
          attr(p, "minOccurs").unwrap_or("1"),
        )).unwrap_or(1)
        // A particle is emitted when it is required (`minOccurs>=1`),
        // or it is a choice branch (selecting a choice picks ONE
        // branch — `CT_Drawing`'s `minOccurs="1"` choice has both
        // branches at `minOccurs="0"`, so without this an empty
        // element results, which the reader rejects), or the rich
        // budget asks for optional content too.
        let eligible = choice || min_occurs >= 1 || rich >= 1
        if is_xsd(p, "element") {
          if eligible {
            // Emit `max(minOccurs,1)` copies — a content model such
            // as `CT_ColorScale` mandates `minOccurs="2"` `<cfvo>` /
            // `<color>` (one occurrence is invalid); a `minOccurs="0"`
            // particle still appears once to be meaningful.  Cap the
            // repetition so an unbounded-but-large minimum cannot
            // explode the tree.
            let want = if min_occurs < 1 { 1 } else { min_occurs }
            let reps = if want > 4 { 4 } else { want }
            match element_instance(schema, p, stack, depth, rich) {
              Some(node) => {
                let group : Array[@xml.Node] = []
                for _r in 0..<reps {
                  group.push(node)
                }
                branches.push(group)
              }
              None => branches.push([])
            }
          }
        } else if is_xsd(p, "sequence") || is_xsd(p, "all") {
          if eligible {
            branches.push(model_particles(schema, p, stack, depth, false, rich))
          }
        } else if is_xsd(p, "choice") {
          if eligible {
            branches.push(model_particles(schema, p, stack, depth, true, rich))
          }
        } else if is_xsd(p, "group") {
          if eligible {
            match attr(p, "ref") {
              Some(ref_key) =>
                if !set_has(stack, ref_key) {
                  match schema.groups.get(ref_key) {
                    Some(gp) => {
                      let sub = copy_set(stack)
                      sub[ref_key] = true
                      branches.push(
                        model_children(schema, gp, sub, depth + 1, rich),
                      )
                    }
                    None => ()
                  }
                }
              None => ()
            }
          }
        }
      }
      _ => ()
    }
  }
  if choice {
    // One branch satisfies a choice.  Prefer a branch whose subtree
    // carries a `TEXT_MARKER` — that is the branch the renderer can
    // actually draw and the verifier can trace (e.g. the paragraph
    // content choice picks the run branch, which leads to `<w:t>`,
    // over the `customXml` branch, which renders to nothing).
    // Otherwise fall back to the first non-empty branch.
    for b in branches {
      if b.length() > 0 && nodes_have_marker(b) {
        return b
      }
    }
    for b in branches {
      if b.length() > 0 {
        return b
      }
    }
    return []
  }
  let out : Array[@xml.Node] = []
  for b in branches {
    for n in b {
      out.push(n)
    }
  }
  out
}

///|
/// Walk the direct sequence / choice / all / group particles of a
/// content-model node (one level).  `rich` is the synthesis budget,
/// threaded into `model_particles` (see there).
fn model_children(
  schema : Schema,
  node : @xml.Element,
  stack : StrSet,
  depth : Int,
  rich : Int,
) -> Array[@xml.Node] {
  // Past the depth bound, stop the OPTIONAL (rich) expansion only —
  // required children must still be emitted at any depth or the
  // instance is schema-INVALID (a `minOccurs="1"` child silently
  // dropped).  True cycles are caught by the `stack` guard, not here.
  let rich = if depth > 8 { 0 } else { rich }
  let out : Array[@xml.Node] = []
  for child in node.children {
    match child {
      Element(c) =>
        if is_xsd(c, "sequence") || is_xsd(c, "all") {
          for n in model_particles(schema, c, stack, depth, false, rich) {
            out.push(n)
          }
        } else if is_xsd(c, "choice") {
          for n in model_particles(schema, c, stack, depth, true, rich) {
            out.push(n)
          }
        } else if is_xsd(c, "group") {
          let min_occurs = (try? @string.parse_int(
            attr(c, "minOccurs").unwrap_or("1"),
          )).unwrap_or(1)
          match attr(c, "ref") {
            Some(ref_key) =>
              if (min_occurs >= 1 || rich >= 1) && !set_has(stack, ref_key) {
                match schema.groups.get(ref_key) {
                  Some(gp) => {
                    let sub = copy_set(stack)
                    sub[ref_key] = true
                    for n in model_children(schema, gp, sub, depth + 1, rich) {
                      out.push(n)
                    }
                  }
                  None => ()
                }
              }
            None => ()
          }
        }
      _ => ()
    }
  }
  out
}

///|
/// The child nodes of a complexType, merging the content of its
/// extension / restriction base.  `rich` is the synthesis budget.
fn children_nodes(
  schema : Schema,
  ct : @xml.Element,
  stack : StrSet,
  depth : Int,
  rich : Int,
) -> Array[@xml.Node] {
  // See `model_children`: the depth bound throttles only the
  // optional (rich) expansion; required children are always emitted.
  let rich = if depth > 8 { 0 } else { rich }
  let out : Array[@xml.Node] = []
  match xsd_child(ct, "complexContent") {
    Some(content) =>
      for kind in ["extension", "restriction"] {
        match xsd_child(content, kind) {
          Some(ext) => {
            match attr(ext, "base") {
              Some(base) =>
                if !set_has(stack, base) {
                  match schema.complex_types.get(base) {
                    Some(base_ct) => {
                      let sub = copy_set(stack)
                      sub[base] = true
                      for
                        n in children_nodes(
                          schema,
                          base_ct,
                          sub,
                          depth + 1,
                          rich,
                        ) {
                        out.push(n)
                      }
                    }
                    None => ()
                  }
                }
              None => ()
            }
            for n in model_children(schema, ext, stack, depth, rich) {
              out.push(n)
            }
          }
          None => ()
        }
      }
    None => ()
  }
  for n in model_children(schema, ct, stack, depth, rich) {
    out.push(n)
  }
  out
}

///|
/// Synthesise one child element occurrence as an `@xml.Element`
/// node, or None when it cannot be built.  `rich` is the synthesis
/// budget; it is decremented one level on each descent so the
/// enriched subtree stays bounded.
fn element_instance(
  schema : Schema,
  el : @xml.Element,
  stack : StrSet,
  depth : Int,
  rich : Int,
) -> @xml.Node? {
  let mut name = attr(el, "name").unwrap_or("")
  let mut etype = attr(el, "type")
  let mut ens = element_ns(el)
  // A `ref=` element borrows the referenced top-level declaration.
  match attr(el, "ref") {
    Some(r) => {
      let rl = local_name(r)
      name = rl
      match schema.top_elements.get(rl) {
        Some((top, _tns)) => {
          etype = attr(top, "type")
          ens = element_ns(top)
        }
        None => ()
      }
    }
    None => ()
  }
  if name == "" {
    return None
  }
  // Descending one element level spends one unit of the rich budget.
  let sub_rich = if rich > 0 { rich - 1 } else { 0 }
  match etype {
    Some(t) => {
      if set_has(stack, t) {
        // Cycle: stop the recursion by emitting the element with no
        // CHILDREN — but still synthesise its required ATTRIBUTES
        // (those carry no recursion).  `CT_CustomXmlBlock` nests
        // itself; an attribute-less `<w:customXml/>` is missing its
        // required `@w:element` and the reader rejects it.
        //
        // However, if the type REQUIRES child elements (minOccurs>=1
        // particles), an empty element violates the schema and the
        // reader rejects it — e.g. CT_Divs requires ≥1 <div>.
        // In that case, skip the element entirely (return None) so
        // the parent does not contain an invalid empty child.
        match schema.complex_types.get(t) {
          Some(ct) =>
            if has_required_child_elements(ct) {
              return None
            } else {
              let cyc_attrs = synth_attrs(schema, ct, ens)
              return Some(Element(elem(ens, name, cyc_attrs, [])))
            }
          None => return Some(Element(elem(ens, name, [], [])))
        }
      }
      match schema.complex_types.get(t) {
        Some(ct) => {
          let sub = copy_set(stack)
          sub[t] = true
          let el = synth_element(
            schema,
            ct,
            ens,
            name,
            sub,
            depth + 1,
            sub_rich,
          )
          if has_required_child_elements(ct) && !has_element_children(el) {
            None
          } else {
            Some(Element(el))
          }
        }
        None => {
          // A simple-type-typed element carries its value as text.
          let is_simple = schema.simple_types.get(t) is Some(_) ||
            t.has_prefix("http://www.w3.org/2001/XMLSchema#")
          if is_simple {
            Some(
              Element(
                elem(ens, name, [], [Text(sample_for_simple(schema, t, 0))]),
              ),
            )
          } else {
            Some(Element(elem(ens, name, [], [])))
          }
        }
      }
    }
    None =>
      match xsd_child(el, "complexType") {
        Some(inline) =>
          Some(
            Element(
              synth_element(
                schema,
                inline,
                ens,
                name,
                stack,
                depth + 1,
                sub_rich,
              ),
            ),
          )
        None => Some(Element(elem(ens, name, [], [])))
      }
  }
}

///|
/// Synthesise an `@xml.Element` named `name` in namespace `ns` for
/// complexType `ct`: required attributes, child content, and — for a
/// `simpleContent` type with no element children — a `TEXT_MARKER`
/// text node.  `rich` is the synthesis budget (see `model_particles`).
fn synth_element(
  schema : Schema,
  ct : @xml.Element,
  ns : String,
  name : String,
  stack : StrSet,
  depth : Int,
  rich : Int,
  include_optional_attrs? : Bool = false,
) -> @xml.Element {
  let attrs = synth_attrs(
    schema,
    ct,
    ns,
    include_optional=include_optional_attrs,
  )
  let children = children_nodes(schema, ct, stack, depth, rich)
  if children.length() == 0 && xsd_child(ct, "simpleContent") is Some(_) {
    children.push(Text(TEXT_MARKER))
  }
  normalize_spreadsheet_drawing_marker({
    name: qname(ns, name),
    attributes: attrs,
    children,
  })
}

///|
/// Shallow copy of a string set (for cycle-guard branches).
fn copy_set(s : StrSet) -> StrSet {
  let out : StrSet = Map([], capacity=0)
  for k, v in s {
    out[k] = v
  }
  out
}
