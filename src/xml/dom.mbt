///|
/// XML declaration metadata from the document prolog.
pub(all) struct XmlDeclaration {
  version : String
  encoding : String?
  standalone : Bool?
} derive(Eq, Debug)

///|
/// Expanded XML name: optional lexical prefix, local name, and resolved namespace URI.
pub(all) struct QName {
  prefix : String?
  local_name : String
  ns : String?
} derive(Eq, Debug)

///|
/// Attribute with an expanded name and entity-expanded value.
pub(all) struct Attribute {
  name : QName
  value : String
} derive(Eq, Debug)

///|
/// XML element with expanded name, attributes in source order, and child nodes.
pub(all) struct Element {
  name : QName
  attributes : Array[Attribute]
  children : Array[Node]
} derive(Eq, Debug)

///|
/// XML document root: optional declaration, optional doctype text, and one root element.
pub(all) struct Document {
  declaration : XmlDeclaration?
  doctype : String?
  root : Element
} derive(Eq, Debug)

///|
/// Processing instruction target and data.
pub(all) struct ProcessingInstruction {
  target : String
  data : String
} derive(Eq, Debug)

///|
/// XML node kinds preserved by the DOM builder.
pub(all) enum Node {
  Element(Element)
  Text(String)
  CData(String)
  Comment(String)
  ProcessingInstruction(ProcessingInstruction)
} derive(Eq, Debug)

///|
/// Namespace prefix binding active for an element subtree.
pub(all) struct NamespaceBinding {
  prefix : String?
  uri : String
} derive(Eq, Debug)

///|
/// Stack of namespace prefix scopes used while reading or writing XML Namespaces 1.0 names.
pub struct NamespaceContext {
  priv scopes : Array[Array[NamespaceBinding]]
} derive(Debug)

///|
/// Create a namespace context with the predefined `xml` prefix.
pub fn NamespaceContext::new() -> NamespaceContext {
  {
    scopes: [
      [{ prefix: Some("xml"), uri: "http://www.w3.org/XML/1998/namespace" }],
    ],
  }
}

///|
/// Push a new namespace scope.
pub fn NamespaceContext::push_scope(self : NamespaceContext) -> Unit {
  self.scopes.push([])
}

///|
/// Pop the current namespace scope.
pub fn NamespaceContext::pop_scope(self : NamespaceContext) -> Unit {
  if self.scopes.length() > 1 {
    self.scopes.pop() |> ignore
  }
}

///|
/// Bind a prefix in the current namespace scope.
pub fn NamespaceContext::bind(
  self : NamespaceContext,
  prefix : String?,
  uri : String,
) -> Unit {
  match self.scopes.last() {
    Some(scope) => scope.push({ prefix, uri })
    None => self.scopes.push([{ prefix, uri }])
  }
}

///|
/// Resolve a namespace prefix using the active scope stack.
pub fn NamespaceContext::resolve(
  self : NamespaceContext,
  prefix : String?,
) -> String? {
  let mut result : String? = None
  for scope in self.scopes {
    for binding in scope {
      if binding.prefix == prefix {
        result = Some(binding.uri)
      }
    }
  }
  result
}
