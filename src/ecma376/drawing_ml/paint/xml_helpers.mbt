// Local copies of two small XML traversal helpers the painter needs
// to avoid pulling in the entire PML viewer.  Identical to the
// definitions that live in `presentation_ml/viewer/viewer.mbt` at
// HEAD; the duplication keeps the paint package self-contained and
// independent of any ML chapter.

///|
fn first_child_named(element : @xml.Element, name : String) -> @xml.Element? {
  for child in element.children {
    match child {
      Element(e) => if e.name.local_name == name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
fn attr_value(element : @xml.Element, local_name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return Some(attr.value)
    }
  }
  None
}
