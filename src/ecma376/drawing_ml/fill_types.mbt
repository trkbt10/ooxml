///|
/// XSD complex type CT_FillProperties (§20.1.8).
pub(all) struct CT_FillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FillProperties::new(element : @xml.Element) -> CT_FillProperties {
  { element, }
}

///|
/// XSD complex type CT_NoFillProperties (§20.1.8).
pub(all) struct CT_NoFillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NoFillProperties::new(element : @xml.Element) -> CT_NoFillProperties {
  { element, }
}

///|
/// XSD complex type CT_GradientFillProperties (§20.1.8): attributes flip, rotWithShape; children gsLst, tileRect.
pub(all) struct CT_GradientFillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GradientFillProperties::new(
  element : @xml.Element,
) -> CT_GradientFillProperties {
  { element, }
}

///|
/// XSD complex type CT_BlipFillProperties (§20.1.8): attributes dpi, rotWithShape; children blip, srcRect.
pub(all) struct CT_BlipFillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BlipFillProperties::new(
  element : @xml.Element,
) -> CT_BlipFillProperties {
  { element, }
}

///|
/// XSD complex type CT_PatternFillProperties (§20.1.8): attribute prst; children fgClr, bgClr.
pub(all) struct CT_PatternFillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PatternFillProperties::new(
  element : @xml.Element,
) -> CT_PatternFillProperties {
  { element, }
}

///|
/// XSD complex type CT_GroupFillProperties (§20.1.8).
pub(all) struct CT_GroupFillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupFillProperties::new(
  element : @xml.Element,
) -> CT_GroupFillProperties {
  { element, }
}

///|
/// XSD complex type CT_GradientStopList (§20.1.8): child gs.
pub(all) struct CT_GradientStopList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GradientStopList::new(element : @xml.Element) -> CT_GradientStopList {
  { element, }
}

///|
/// XSD complex type CT_GradientStop (§20.1.8): attribute pos.
pub(all) struct CT_GradientStop {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GradientStop::new(element : @xml.Element) -> CT_GradientStop {
  { element, }
}

///|
/// XSD complex type CT_LinearShadeProperties (§20.1.8): attributes ang, scaled.
pub(all) struct CT_LinearShadeProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LinearShadeProperties::new(
  element : @xml.Element,
) -> CT_LinearShadeProperties {
  { element, }
}

///|
/// XSD complex type CT_PathShadeProperties (§20.1.8): attribute path; child fillToRect.
pub(all) struct CT_PathShadeProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PathShadeProperties::new(
  element : @xml.Element,
) -> CT_PathShadeProperties {
  { element, }
}

///|
/// XSD complex type CT_TileInfoProperties (§20.1.8): attributes tx, ty, sx, sy, flip, algn.
pub(all) struct CT_TileInfoProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TileInfoProperties::new(
  element : @xml.Element,
) -> CT_TileInfoProperties {
  { element, }
}

///|
/// XSD complex type CT_StretchInfoProperties (§20.1.8): child fillRect.
pub(all) struct CT_StretchInfoProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StretchInfoProperties::new(
  element : @xml.Element,
) -> CT_StretchInfoProperties {
  { element, }
}

///|
pub fn read_no_fill_properties(bytes : Bytes) -> CT_NoFillProperties raise {
  CT_NoFillProperties::new(read_main_root(bytes, "noFill"))
}

///|
pub fn write_no_fill_properties(value : CT_NoFillProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_solid_color_fill_properties(
  bytes : Bytes,
) -> CT_SolidColorFillProperties raise {
  CT_SolidColorFillProperties::new(read_main_root(bytes, "solidFill"))
}

///|
pub fn write_solid_color_fill_properties(
  value : CT_SolidColorFillProperties,
) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_gradient_fill_properties(
  bytes : Bytes,
) -> CT_GradientFillProperties raise {
  CT_GradientFillProperties::new(read_main_root(bytes, "gradFill"))
}

///|
pub fn write_gradient_fill_properties(
  value : CT_GradientFillProperties,
) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_blip_fill_properties(bytes : Bytes) -> CT_BlipFillProperties raise {
  CT_BlipFillProperties::new(read_main_root(bytes, "blipFill"))
}

///|
pub fn write_blip_fill_properties(value : CT_BlipFillProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_pattern_fill_properties(
  bytes : Bytes,
) -> CT_PatternFillProperties raise {
  CT_PatternFillProperties::new(read_main_root(bytes, "pattFill"))
}

///|
pub fn write_pattern_fill_properties(value : CT_PatternFillProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_group_fill_properties(
  bytes : Bytes,
) -> CT_GroupFillProperties raise {
  CT_GroupFillProperties::new(read_main_root(bytes, "grpFill"))
}

///|
pub fn write_group_fill_properties(value : CT_GroupFillProperties) -> Bytes {
  write_element(value.element)
}
