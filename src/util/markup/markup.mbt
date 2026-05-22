///|
/// Structured markup construction for the SVG renderers.
///
/// The renderers build their SVG output as an `@xml.Element` tree
/// and serialise it once via `serialize_svg`.  Serialisation
/// delegates to `@xml.write`, which escapes every attribute value
/// and text node, so no OOXML payload can break out of its element
/// / attribute context.  No output XML is ever assembled by string
/// concatenation.

///|
/// The SVG namespace URI (SVG 1.1 §1.3).  An SVG document tree
/// built for `serialize_svg` carries this URI on every element so
/// the `@xml` writer emits a single `xmlns` declaration on the
/// root and none on the descendants.
pub let svg_ns : String = "http://www.w3.org/2000/svg"

///|
/// The XLink namespace URI (used by SVG `xlink:href`).
pub let xlink_ns : String = "http://www.w3.org/1999/xlink"

///|
/// Build a `QName` with no prefix and no namespace.
fn qname(name : String) -> @xml.QName {
  { prefix: None, local_name: name, ns: None }
}

///|
/// Build a `QName` in the given default namespace (no prefix).
/// Every element of a namespaced tree (e.g. SVG) must carry the
/// same URI so the writer emits exactly one `xmlns` declaration
/// on the root.
pub fn qname_ns(name : String, ns : String) -> @xml.QName {
  { prefix: None, local_name: name, ns: Some(ns) }
}

///|
/// Build an attribute (name + value).  The value is escaped by
/// the writer at serialisation time, never here.
pub fn attr(name : String, value : String) -> @xml.Attribute {
  { name: qname(name), value }
}

///|
/// Build a prefixed attribute in the given namespace, e.g.
/// `xlink:href`.  The prefix is declared on the element that
/// first carries it.
pub fn attr_ns(
  prefix : String,
  name : String,
  ns : String,
  value : String,
) -> @xml.Attribute {
  { name: { prefix: Some(prefix), local_name: name, ns: Some(ns) }, value }
}

///|
/// Build an element node in the given default namespace.
pub fn elem_ns(
  tag : String,
  ns : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element({ name: qname_ns(tag, ns), attributes: attrs, children })
}

///|
/// Wrap a raw string as an XML text node.  The string is escaped
/// by the writer at serialisation time.
pub fn text(value : String) -> @xml.Node {
  @xml.Node::Text(value)
}

///|
/// Serialise a single element (and its subtree) to a string
/// fragment — declaration-less and doctype-less, so the result
/// is exactly the element's own markup, ready for embedding.
///
/// The `@xml.write` writer always produces well-formed UTF-8, so
/// `decode_lossy` never actually substitutes; it merely avoids
/// propagating an unreachable decode error.
pub fn serialize(root : @xml.Element) -> String {
  let doc : @xml.Document = { declaration: None, doctype: None, root }
  @utf8.decode_lossy(@xml.write(doc)[:])
}

///|
/// Serialise an SVG root element to a string fragment.  The root
/// element must already be built in `svg_ns` (via `elem_ns` /
/// `qname_ns`); the writer then emits one `xmlns` declaration on
/// the `<svg>` root.
pub fn serialize_svg(root : @xml.Element) -> String {
  serialize(root)
}
