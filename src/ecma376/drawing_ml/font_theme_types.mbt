///|
/// XSD complex type CT_TextFont (§20.1.4): typeface descriptor.
pub(all) struct CT_TextFont {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextFont::new(element : @xml.Element) -> CT_TextFont {
  { element, }
}

///|
/// XSD complex type CT_SupplementalFont (§20.1.4): script-specific font.
pub(all) struct CT_SupplementalFont {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SupplementalFont::new(element : @xml.Element) -> CT_SupplementalFont {
  { element, }
}

///|
/// XSD complex type CT_FontCollection (§20.1.4): major or minor font set.
pub(all) struct CT_FontCollection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontCollection::new(element : @xml.Element) -> CT_FontCollection {
  { element, }
}

///|
/// XSD complex type CT_FontScheme (§20.1.4): theme font scheme.
pub(all) struct CT_FontScheme {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontScheme::new(element : @xml.Element) -> CT_FontScheme {
  { element, }
}

///|
/// XSD complex type CT_FontReference (§20.1.4): font collection reference.
pub(all) struct CT_FontReference {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontReference::new(element : @xml.Element) -> CT_FontReference {
  { element, }
}

///|
/// XSD complex type CT_BaseStyles (§20.1.6): theme element collection.
pub(all) struct CT_BaseStyles {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BaseStyles::new(element : @xml.Element) -> CT_BaseStyles {
  { element, }
}

///|
/// XSD complex type CT_OfficeStyleSheet (§20.1.6): theme part root.
pub(all) struct CT_OfficeStyleSheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeStyleSheet::new(element : @xml.Element) -> CT_OfficeStyleSheet {
  { element, }
}

///|
/// XSD complex type CT_BaseStylesOverride (§20.1.6): theme override root.
pub(all) struct CT_BaseStylesOverride {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BaseStylesOverride::new(
  element : @xml.Element,
) -> CT_BaseStylesOverride {
  { element, }
}

///|
/// XSD complex type CT_OfficeArtExtension (§20.1.2): OfficeArt extension.
pub(all) struct CT_OfficeArtExtension {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeArtExtension::new(
  element : @xml.Element,
) -> CT_OfficeArtExtension {
  { element, }
}

///|
/// XSD complex type CT_OfficeArtExtensionList (§20.1.2): extension list.
pub(all) struct CT_OfficeArtExtensionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeArtExtensionList::new(
  element : @xml.Element,
) -> CT_OfficeArtExtensionList {
  { element, }
}

///|
/// XSD complex type CT_EmptyElement (§20.1): empty theme manager element.
pub(all) struct CT_EmptyElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmptyElement::new(element : @xml.Element) -> CT_EmptyElement {
  { element, }
}

///|
pub type Theme = CT_OfficeStyleSheet

///|
pub type ThemeOverride = CT_BaseStylesOverride

///|
pub type ThemeManager = CT_EmptyElement

///|
pub fn read_text_font(bytes : Bytes) -> CT_TextFont raise {
  CT_TextFont::new(read_main_root(bytes, "latin"))
}

///|
pub fn write_text_font(value : CT_TextFont) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_font_scheme(bytes : Bytes) -> CT_FontScheme raise {
  CT_FontScheme::new(read_main_root(bytes, "fontScheme"))
}

///|
pub fn write_font_scheme(value : CT_FontScheme) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_theme(bytes : Bytes) -> Theme raise {
  CT_OfficeStyleSheet::new(read_main_root(bytes, "theme"))
}

///|
pub fn write_theme(value : Theme) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_theme_override(bytes : Bytes) -> ThemeOverride raise {
  CT_BaseStylesOverride::new(read_main_root(bytes, "themeOverride"))
}

///|
pub fn write_theme_override(value : ThemeOverride) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_theme_manager(bytes : Bytes) -> ThemeManager raise {
  CT_EmptyElement::new(read_main_root(bytes, "themeManager"))
}

///|
pub fn write_theme_manager(value : ThemeManager) -> Bytes {
  write_element(value.element)
}
