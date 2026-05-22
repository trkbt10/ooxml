///|
/// Predicate over an XML element. A-layer primitives accept a
/// predicate so that selectors can match by local_name, namespace,
/// attribute value, or any combination — without the primitive
/// having to know about XPath syntax.
pub type ElementPredicate = (@xml.Element) -> Bool

///|
/// Match by `local_name` only (ignores namespace). Useful for
/// well-known OOXML tags whose namespace is implied by the part
/// (every `<w:p>` in /word/document.xml is the §17.3.1.22 paragraph).
pub fn by_local_name(name : String) -> ElementPredicate {
  fn(e) { e.name.local_name == name }
}

///|
/// Match by full QName: requires `local_name` and `ns` (namespace
/// URI) to match. Prefix is ignored. Use when disambiguating tags
/// shared across namespaces (e.g. `<a:p>` vs `<w:p>`).
pub fn by_qname(local_name : String, ns : String) -> ElementPredicate {
  fn(e) {
    e.name.local_name == local_name && e.name.ns is Some(uri) && uri == ns
  }
}

///|
/// Match by local_name plus an attribute value (also matched by
/// local_name only — typical for OOXML attributes which carry no
/// prefix, e.g. `r="A1"` on `<c>`).
pub fn by_local_name_with_attr(
  name : String,
  attr_local : String,
  attr_value : String,
) -> ElementPredicate {
  fn(e) {
    if e.name.local_name != name {
      false
    } else {
      let mut hit = false
      for a in e.attributes {
        if a.name.local_name == attr_local && a.value == attr_value {
          hit = true
        }
      }
      hit
    }
  }
}

///|
/// Return the first descendant (depth-first, pre-order) of `root`
/// matching `pred`, or None.
pub fn find_first(
  root : @xml.Element,
  pred : ElementPredicate,
) -> @xml.Element? {
  if pred(root) {
    return Some(root)
  }
  for child in root.children {
    match child {
      @xml.Element(e) =>
        match find_first(e, pred) {
          Some(hit) => return Some(hit)
          None => ()
        }
      _ => ()
    }
  }
  None
}

///|
/// Return every descendant (depth-first, pre-order) of `root`
/// matching `pred`. Includes `root` itself when it matches.
pub fn find_all(
  root : @xml.Element,
  pred : ElementPredicate,
) -> Array[@xml.Element] {
  let result : Array[@xml.Element] = []
  collect_matches(root, pred, result)
  result
}

///|
fn collect_matches(
  root : @xml.Element,
  pred : ElementPredicate,
  out : Array[@xml.Element],
) -> Unit {
  if pred(root) {
    out.push(root)
  }
  for child in root.children {
    match child {
      @xml.Element(e) => collect_matches(e, pred, out)
      _ => ()
    }
  }
}

///|
/// Return the immediate (direct) children of `parent` that match the
/// predicate. Does not recurse into grandchildren.
pub fn direct_children(
  parent : @xml.Element,
  pred : ElementPredicate,
) -> Array[@xml.Element] {
  let result : Array[@xml.Element] = []
  for child in parent.children {
    match child {
      @xml.Element(e) => if pred(e) { result.push(e) }
      _ => ()
    }
  }
  result
}

///|
/// Return a new element with `attr` appended (or, when an attribute
/// with the same QName already exists, replaced). Other attributes
/// are preserved in source order.
pub fn set_attribute(
  element : @xml.Element,
  attr : @xml.Attribute,
) -> @xml.Element {
  let new_attrs : Array[@xml.Attribute] = []
  let mut replaced = false
  for a in element.attributes {
    if a.name == attr.name {
      new_attrs.push(attr)
      replaced = true
    } else {
      new_attrs.push(a)
    }
  }
  if !replaced {
    new_attrs.push(attr)
  }
  { name: element.name, attributes: new_attrs, children: element.children }
}

///|
/// Return a new element whose attributes no longer include any whose
/// QName matches `name`.
pub fn remove_attribute(
  element : @xml.Element,
  name : @xml.QName,
) -> @xml.Element {
  let new_attrs : Array[@xml.Attribute] = []
  for a in element.attributes {
    if a.name != name {
      new_attrs.push(a)
    }
  }
  { name: element.name, attributes: new_attrs, children: element.children }
}

///|
/// Return a new element with `node` appended to the end of its
/// `children`. Source attributes and prior children are preserved.
pub fn append_child(parent : @xml.Element, node : @xml.Node) -> @xml.Element {
  let new_children : Array[@xml.Node] = []
  for c in parent.children {
    new_children.push(c)
  }
  new_children.push(node)
  { name: parent.name, attributes: parent.attributes, children: new_children }
}

///|
/// Return a new element with `node` inserted at index `position` in
/// `children`. `position` is clamped to [0, children.length()].
pub fn insert_child(
  parent : @xml.Element,
  position : Int,
  node : @xml.Node,
) -> @xml.Element {
  let new_children : Array[@xml.Node] = []
  let len = parent.children.length()
  let clamped = if position < 0 {
    0
  } else if position > len {
    len
  } else {
    position
  }
  let mut i = 0
  for c in parent.children {
    if i == clamped {
      new_children.push(node)
    }
    new_children.push(c)
    i = i + 1
  }
  if clamped == len {
    new_children.push(node)
  }
  { name: parent.name, attributes: parent.attributes, children: new_children }
}

///|
/// Return a new element with every direct child element matching
/// `pred` removed. Non-element nodes (Text/CData/Comment/PI) are
/// preserved. Use `map_subtree` for recursive removal.
pub fn remove_children(
  parent : @xml.Element,
  pred : ElementPredicate,
) -> @xml.Element {
  let new_children : Array[@xml.Node] = []
  for child in parent.children {
    match child {
      @xml.Element(e) => if !pred(e) { new_children.push(child) }
      other => new_children.push(other)
    }
  }
  { name: parent.name, attributes: parent.attributes, children: new_children }
}

///|
/// Return a new element with every direct child element matching
/// `pred` replaced by `replacement`. Non-matching children are
/// preserved.
pub fn replace_children(
  parent : @xml.Element,
  pred : ElementPredicate,
  replacement : @xml.Element,
) -> @xml.Element {
  let new_children : Array[@xml.Node] = []
  for child in parent.children {
    match child {
      @xml.Element(e) =>
        if pred(e) {
          new_children.push(@xml.Node::Element(replacement))
        } else {
          new_children.push(child)
        }
      other => new_children.push(other)
    }
  }
  { name: parent.name, attributes: parent.attributes, children: new_children }
}

///|
/// Walk `root` depth-first and apply `transform` to every element
/// (including `root`). The transformer receives the element after
/// its children have been recursively transformed, so transformers
/// see the rewritten subtree. Return the new root.
pub fn map_subtree(
  root : @xml.Element,
  transform : (@xml.Element) -> @xml.Element,
) -> @xml.Element {
  let new_children : Array[@xml.Node] = []
  for child in root.children {
    match child {
      @xml.Element(e) =>
        new_children.push(@xml.Node::Element(map_subtree(e, transform)))
      other => new_children.push(other)
    }
  }
  let rewritten : @xml.Element = {
    name: root.name,
    attributes: root.attributes,
    children: new_children,
  }
  transform(rewritten)
}

///|
/// Return a new element produced by applying `update` to the first
/// descendant matching `pred`. The rest of the tree is preserved.
/// If no element matches, the tree is returned unchanged.
pub fn update_first(
  root : @xml.Element,
  pred : ElementPredicate,
  update : (@xml.Element) -> @xml.Element,
) -> @xml.Element {
  let (result, _done) = update_first_helper(root, pred, update, false)
  result
}

///|
fn update_first_helper(
  root : @xml.Element,
  pred : ElementPredicate,
  update : (@xml.Element) -> @xml.Element,
  done : Bool,
) -> (@xml.Element, Bool) {
  if done {
    return (root, true)
  }
  if pred(root) {
    return (update(root), true)
  }
  let new_children : Array[@xml.Node] = []
  let mut local_done = false
  for child in root.children {
    match child {
      @xml.Element(e) =>
        if !local_done {
          let (rewritten, child_done) = update_first_helper(
            e, pred, update, false,
          )
          if child_done {
            local_done = true
          }
          new_children.push(@xml.Node::Element(rewritten))
        } else {
          new_children.push(@xml.Node::Element(e))
        }
      other => new_children.push(other)
    }
  }
  let rewritten_root : @xml.Element = {
    name: root.name,
    attributes: root.attributes,
    children: new_children,
  }
  (rewritten_root, local_done)
}

///|
/// Return the concatenated text content of `element` (every Text /
/// CData node found by depth-first walk, in document order).
/// Element / Comment / PI nodes contribute nothing. This is the
/// `text()` primitive used by higher-level helpers.
pub fn text_content(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  collect_text(element, buf)
  buf.to_string()
}

///|
fn collect_text(element : @xml.Element, buf : StringBuilder) -> Unit {
  for child in element.children {
    match child {
      @xml.Text(t) => buf.write_string(t)
      @xml.CData(t) => buf.write_string(t)
      @xml.Element(e) => collect_text(e, buf)
      _ => ()
    }
  }
}

///|
/// Look up an attribute by its full QName. Returns the value, or
/// None when no attribute matches.
pub fn attribute(element : @xml.Element, name : @xml.QName) -> String? {
  for a in element.attributes {
    if a.name == name {
      return Some(a.value)
    }
  }
  None
}

///|
/// Look up an attribute by local_name only (any prefix / namespace).
/// Returns the value of the first match.
pub fn attribute_by_local_name(
  element : @xml.Element,
  local_name : String,
) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
/// Convenience: build a QName inheriting prefix + namespace from
/// `template`. Used when constructing new children that need to
/// blend into the source package's namespace declarations.
pub fn qname_like(template : @xml.QName, local_name : String) -> @xml.QName {
  { prefix: template.prefix, local_name, ns: template.ns }
}

///|
/// Convenience: construct an Element with no attributes / children
/// using the namespace declarations carried by `template`. Combine
/// with append_child / set_attribute to build full subtrees.
pub fn empty_element(
  template : @xml.QName,
  local_name : String,
) -> @xml.Element {
  { name: qname_like(template, local_name), attributes: [], children: [] }
}

///|
/// Convenience: build an unprefixed attribute (no namespace). Most
/// OOXML attributes (`r="A1"`, `id="42"`, etc.) carry no namespace,
/// so this is the common path.
pub fn unprefixed_attribute(
  local_name : String,
  value : String,
) -> @xml.Attribute {
  { name: { prefix: None, local_name, ns: None }, value }
}

///|
/// XML 1.0 §3.3.3 — `xml:space="preserve"` is required on a text
/// element when its content has leading or trailing whitespace
/// that an XML parser would otherwise normalise away.  The four
/// characters normalised per §3.3.3 are ASCII space (U+0020),
/// tab (U+0009), LF (U+000A), and CR (U+000D); checking those
/// at the head and tail of the string is necessary and
/// sufficient.  Lifted from per-package duplicates so WML
/// (§17.17.3), SML (§18.4.12), and PML (§19.3.1.51) share one
/// implementation.
pub fn needs_xml_space_preserve(text : String) -> Bool {
  if text.length() == 0 {
    return false
  }
  let is_ws = fn(c : Int) -> Bool {
    c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D
  }
  let first = is_ws(text.code_unit_at(0).to_int())
  let last = is_ws(text.code_unit_at(text.length() - 1).to_int())
  first || last
}
