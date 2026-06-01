// Small XML / numeric helpers the chart renderer needs, kept local
// to the package so it stays independent of any ML chapter.
//
// `first_child_named`, `attr_value` mirror the same-named helpers in
// `presentation_ml/viewer/viewer.mbt`; `format_double` mirrors the
// helper in `presentation_ml/viewer/transform.mbt`.  Each is small
// enough that duplicating it here is preferable to pulling the host
// viewer into this package's dependencies.

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
fn child_elements_named(
  element : @xml.Element,
  name : String,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      Element(e) => if e.name.local_name == name { out.push(e) }
      _ => ()
    }
  }
  out
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

///|
/// Format a Double for SVG attribute output: integers print without
/// the trailing `.0`, fractional values defer to `to_string`.
fn format_double(value : Double) -> String {
  if value == value.to_int().to_double() {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}
