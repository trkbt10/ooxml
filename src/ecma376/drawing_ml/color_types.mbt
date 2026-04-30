///|
/// XSD complex type CT_ColorScheme (§20.1.2): theme color scheme.
pub(all) struct CT_ColorScheme {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorScheme::new(element : @xml.Element) -> CT_ColorScheme {
  { element, }
}

///|
/// XSD complex type CT_CustomColor (§20.1.2): named custom color.
pub(all) struct CT_CustomColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomColor::new(element : @xml.Element) -> CT_CustomColor {
  { element, }
}

///|
/// XSD complex type CT_CustomColorList (§20.1.2): custom color list.
pub(all) struct CT_CustomColorList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomColorList::new(element : @xml.Element) -> CT_CustomColorList {
  { element, }
}

///|
/// XSD complex type CT_ScRgbColor (§20.1.2): scRGB color.
pub(all) struct CT_ScRgbColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ScRgbColor::new(element : @xml.Element) -> CT_ScRgbColor {
  { element, }
}

///|
/// XSD complex type CT_SRgbColor (§20.1.2): sRGB color.
pub(all) struct CT_SRgbColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SRgbColor::new(element : @xml.Element) -> CT_SRgbColor {
  { element, }
}

///|
/// XSD complex type CT_HslColor (§20.1.2): HSL color.
pub(all) struct CT_HslColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HslColor::new(element : @xml.Element) -> CT_HslColor {
  { element, }
}

///|
/// XSD complex type CT_SystemColor (§20.1.2): system color.
pub(all) struct CT_SystemColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SystemColor::new(element : @xml.Element) -> CT_SystemColor {
  { element, }
}

///|
/// XSD complex type CT_SchemeColor (§20.1.2): scheme color.
pub(all) struct CT_SchemeColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SchemeColor::new(element : @xml.Element) -> CT_SchemeColor {
  { element, }
}

///|
/// XSD complex type CT_PresetColor (§20.1.2): preset color.
pub(all) struct CT_PresetColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetColor::new(element : @xml.Element) -> CT_PresetColor {
  { element, }
}

///|
/// XSD complex type CT_Color (§20.1.2): color choice container.
pub(all) struct CT_Color {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Color::new(element : @xml.Element) -> CT_Color {
  { element, }
}

///|
/// XSD complex type CT_ColorMRU (§20.1.2): color most-recently-used list.
pub(all) struct CT_ColorMRU {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMRU::new(element : @xml.Element) -> CT_ColorMRU {
  { element, }
}

///|
/// XSD complex type CT_ColorChangeEffect (§20.1.8): color change effect.
pub(all) struct CT_ColorChangeEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorChangeEffect::new(
  element : @xml.Element,
) -> CT_ColorChangeEffect {
  { element, }
}

///|
/// XSD complex type CT_ColorReplaceEffect (§20.1.8): color replacement effect.
pub(all) struct CT_ColorReplaceEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorReplaceEffect::new(
  element : @xml.Element,
) -> CT_ColorReplaceEffect {
  { element, }
}

///|
/// XSD complex type CT_SolidColorFillProperties (§20.1.8): solid color fill.
pub(all) struct CT_SolidColorFillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SolidColorFillProperties::new(
  element : @xml.Element,
) -> CT_SolidColorFillProperties {
  { element, }
}

///|
/// XSD complex type CT_ColorMapping (§20.1.6): theme color mapping.
pub(all) struct CT_ColorMapping {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMapping::new(element : @xml.Element) -> CT_ColorMapping {
  { element, }
}

///|
/// XSD complex type CT_ColorMappingOverride (§20.1.6): color mapping override.
pub(all) struct CT_ColorMappingOverride {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMappingOverride::new(
  element : @xml.Element,
) -> CT_ColorMappingOverride {
  { element, }
}

///|
/// XSD complex type CT_ColorSchemeAndMapping (§20.1.6): color scheme plus mapping.
pub(all) struct CT_ColorSchemeAndMapping {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorSchemeAndMapping::new(
  element : @xml.Element,
) -> CT_ColorSchemeAndMapping {
  { element, }
}

///|
/// XSD complex type CT_ColorSchemeList (§20.1.6): additional color schemes.
pub(all) struct CT_ColorSchemeList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorSchemeList::new(element : @xml.Element) -> CT_ColorSchemeList {
  { element, }
}

///|
/// XSD complex type CT_TextBulletColorFollowText (§20.1.10): follow text bullet color.
pub(all) struct CT_TextBulletColorFollowText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletColorFollowText::new(
  element : @xml.Element,
) -> CT_TextBulletColorFollowText {
  { element, }
}

///|
pub fn read_color_scheme(bytes : Bytes) -> CT_ColorScheme raise {
  CT_ColorScheme::new(read_main_root(bytes, "clrScheme"))
}

///|
pub fn write_color_scheme(value : CT_ColorScheme) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_sc_rgb_color(bytes : Bytes) -> CT_ScRgbColor raise {
  CT_ScRgbColor::new(read_main_root(bytes, "scrgbClr"))
}

///|
pub fn write_sc_rgb_color(value : CT_ScRgbColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_s_rgb_color(bytes : Bytes) -> CT_SRgbColor raise {
  CT_SRgbColor::new(read_main_root(bytes, "srgbClr"))
}

///|
pub fn write_s_rgb_color(value : CT_SRgbColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_hsl_color(bytes : Bytes) -> CT_HslColor raise {
  CT_HslColor::new(read_main_root(bytes, "hslClr"))
}

///|
pub fn write_hsl_color(value : CT_HslColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_system_color(bytes : Bytes) -> CT_SystemColor raise {
  CT_SystemColor::new(read_main_root(bytes, "sysClr"))
}

///|
pub fn write_system_color(value : CT_SystemColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_scheme_color(bytes : Bytes) -> CT_SchemeColor raise {
  CT_SchemeColor::new(read_main_root(bytes, "schemeClr"))
}

///|
pub fn write_scheme_color(value : CT_SchemeColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_preset_color(bytes : Bytes) -> CT_PresetColor raise {
  CT_PresetColor::new(read_main_root(bytes, "prstClr"))
}

///|
pub fn write_preset_color(value : CT_PresetColor) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_color_mapping(bytes : Bytes) -> CT_ColorMapping raise {
  CT_ColorMapping::new(read_main_root(bytes, "clrMap"))
}

///|
pub fn write_color_mapping(value : CT_ColorMapping) -> Bytes {
  write_element(value.element)
}
