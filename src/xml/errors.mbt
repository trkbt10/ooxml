///|
/// XML well-formedness error with one-based source line and column.
pub suberror XmlMalformed {
  XmlMalformed(line~ : Int, col~ : Int, reason~ : String)
}

///|
/// Namespace prefix was used without an active binding.
pub suberror UndeclaredPrefix {
  UndeclaredPrefix(prefix~ : String)
}

///|
/// An element start tag declared the same expanded attribute name more than once.
pub suberror DuplicateAttribute {
  DuplicateAttribute(name~ : String)
}
