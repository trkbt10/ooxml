///|
/// Represents dml-diagram.xsd XSD attribute group AG_IteratorAttributes (§21.4).
/// This iterator attribute-group domain value carries axis, ptType,
/// hideLastTrans, st, cnt, and step so reader output and writer input keep
/// layout traversal attributes reachable from the package API.
pub(all) struct AG_IteratorAttributes {
  axis : String?
  pt_type : String?
  hide_last_trans : String?
  st : String?
  cnt : String?
  step : String?
} derive(Eq, Debug)

///|
/// Construct an empty XSD attribute group AG_IteratorAttributes (§21.4) value.
pub fn AG_IteratorAttributes::empty() -> AG_IteratorAttributes {
  {
    axis: None,
    pt_type: None,
    hide_last_trans: None,
    st: None,
    cnt: None,
    step: None,
  }
}
