///|
/// Write top-level XSD element chartSpace (§21.2).
pub fn write_chart_space(value : ChartSpace) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element userShapes (§21.2).
pub fn write_user_shapes(value : UserShapes) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element chart (§21.2).
pub fn write_chart(value : Chart) -> Bytes {
  write_element(value.element)
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}
