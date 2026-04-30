///|
/// XSD complex type CT_LineProperties (§20.1.8): attributes w, cap, cmpd, algn; children headEnd, tailEnd, extLst.
pub(all) struct CT_LineProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineProperties::new(element : @xml.Element) -> CT_LineProperties {
  { element, }
}

///|
/// XSD complex type CT_LineEndProperties (§20.1.8): attributes type, w, len.
pub(all) struct CT_LineEndProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineEndProperties::new(
  element : @xml.Element,
) -> CT_LineEndProperties {
  { element, }
}

///|
/// XSD complex type CT_LineJoinBevel (§20.1.8).
pub(all) struct CT_LineJoinBevel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineJoinBevel::new(element : @xml.Element) -> CT_LineJoinBevel {
  { element, }
}

///|
/// XSD complex type CT_LineJoinRound (§20.1.8).
pub(all) struct CT_LineJoinRound {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineJoinRound::new(element : @xml.Element) -> CT_LineJoinRound {
  { element, }
}

///|
/// XSD complex type CT_LineJoinMiterProperties (§20.1.8): attribute lim.
pub(all) struct CT_LineJoinMiterProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineJoinMiterProperties::new(
  element : @xml.Element,
) -> CT_LineJoinMiterProperties {
  { element, }
}

///|
/// XSD complex type CT_DashStop (§20.1.8): attributes d, sp.
pub(all) struct CT_DashStop {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DashStop::new(element : @xml.Element) -> CT_DashStop {
  { element, }
}

///|
/// XSD complex type CT_DashStopList (§20.1.8): child ds.
pub(all) struct CT_DashStopList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DashStopList::new(element : @xml.Element) -> CT_DashStopList {
  { element, }
}

///|
/// XSD complex type CT_PresetLineDashProperties (§20.1.8): attribute val.
pub(all) struct CT_PresetLineDashProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetLineDashProperties::new(
  element : @xml.Element,
) -> CT_PresetLineDashProperties {
  { element, }
}

///|
pub fn read_line_properties(bytes : Bytes) -> CT_LineProperties raise {
  CT_LineProperties::new(read_main_root(bytes, "ln"))
}

///|
pub fn write_line_properties(value : CT_LineProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_preset_line_dash_properties(
  bytes : Bytes,
) -> CT_PresetLineDashProperties raise {
  CT_PresetLineDashProperties::new(read_main_root(bytes, "prstDash"))
}

///|
pub fn write_preset_line_dash_properties(
  value : CT_PresetLineDashProperties,
) -> Bytes {
  write_element(value.element)
}
