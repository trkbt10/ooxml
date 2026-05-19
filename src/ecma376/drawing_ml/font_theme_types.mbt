// ECMA-376 Part 1 §20.1.4 (font scheme) and §20.1.6 (theme) complex
// types plus §20.1.2 (OfficeArt extensions). XSD definitions live in
// Annex A.4.1 dml-main.xsd at the following line ranges:
//
//   CT_SupplementalFont          lines  109..112
//   CT_FontCollection            lines  118..126
//   CT_FontScheme                lines  134..141
//   CT_BaseStyles                lines  173..180
//   CT_OfficeArtExtension        lines  181..186
//   CT_FontReference             lines 2252..2257
//   CT_OfficeStyleSheet          lines 2321..2330
//   CT_BaseStylesOverride        lines 2331..2337
//   CT_TextFont                  lines 2814..2819
//   CT_OfficeArtExtensionList    -- declared inline at every callsite
//                                    via xsd:element name="extLst"
//                                    type="CT_OfficeArtExtensionList";
//                                    the complex type itself is the
//                                    standard `ext`* wrapper
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit attribute / child-element fields decoded from the
// source `@xml.Element`. The element is preserved so the builder can
// round-trip unmodelled content (the `to_element` writer returns the
// captured element verbatim).

///|
/// XSD complex type CT_TextFont — Part 1 §20.1.4.1.28. Annex A.4.1
/// lines 2814..2819. Required `typeface` (ST_TextTypeface) and three
/// optional attributes: `panose` (s:ST_Panose hexBinary length 10),
/// `pitchFamily` (ST_PitchFamily, default 0) and `charset` (xsd:byte,
/// default 1).
pub(all) struct CT_TextFont {
  /// @typeface — ST_TextTypeface (required).
  typeface : ST_TextTypeface
  /// @panose — s:ST_Panose (optional). Raw lexical form preserved
  /// because no typed projection for the shared-commonSimpleTypes
  /// ST_Panose hexBinary length-10 token exists in this package.
  panose : String?
  /// @pitchFamily — ST_PitchFamily (optional, default 0 = unknown).
  pitch_family : ST_PitchFamily
  /// @charset — xsd:byte (optional, default 1 = default charset).
  /// Stored as Int because xsd:byte is a signed 8-bit integer.
  charset : Int
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextFont::new(
  element : @xml.Element,
) -> CT_TextFont raise SchemaViolation {
  let typeface_lex = ct_required_string(
    element, "typeface", "CT_TextFont/@typeface",
  )
  let typeface = ST_TextTypeface::parse(typeface_lex)
  let panose = ct_attr(element, "panose")
  let pitch_family = match ct_attr(element, "pitchFamily") {
    Some(v) => ST_PitchFamily::parse(v)
    None => PitchFamily00
  }
  let charset = match ct_attr(element, "charset") {
    Some(v) => ct_parse_byte_lex(v, "CT_TextFont/@charset")
    None => 1
  }
  { typeface, panose, pitch_family, charset, element }
}

///|
pub fn CT_TextFont::to_element(self : CT_TextFont) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SupplementalFont — Part 1 §20.1.4.1.27. Annex
/// A.4.1 lines 109..112. Required `script` (xsd:string) and `typeface`
/// (ST_TextTypeface) attributes.
pub(all) struct CT_SupplementalFont {
  /// @script — xsd:string (required).
  script : String
  /// @typeface — ST_TextTypeface (required).
  typeface : ST_TextTypeface
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SupplementalFont::new(
  element : @xml.Element,
) -> CT_SupplementalFont raise SchemaViolation {
  let script = ct_required_string(
    element, "script", "CT_SupplementalFont/@script",
  )
  let typeface_lex = ct_required_string(
    element, "typeface", "CT_SupplementalFont/@typeface",
  )
  let typeface = ST_TextTypeface::parse(typeface_lex)
  { script, typeface, element }
}

///|
pub fn CT_SupplementalFont::to_element(
  self : CT_SupplementalFont,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontCollection — Part 1 §20.1.4.1.9. Annex A.4.1
/// lines 118..126. Three required `latin`, `ea`, `cs` (CT_TextFont)
/// children plus unbounded `font` (CT_SupplementalFont) and optional
/// `extLst` (CT_OfficeArtExtensionList).
pub(all) struct CT_FontCollection {
  /// <latin> (CT_TextFont) — required.
  latin : CT_TextFont
  /// <ea> (CT_TextFont) — required (East Asian).
  ea : CT_TextFont
  /// <cs> (CT_TextFont) — required (Complex Script).
  cs : CT_TextFont
  /// <font>* (CT_SupplementalFont) — script-specific font overrides.
  fonts : Array[CT_SupplementalFont]
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontCollection::new(
  element : @xml.Element,
) -> CT_FontCollection raise SchemaViolation {
  let latin = match ct_first_child(element, "latin") {
    Some(c) => CT_TextFont::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_FontCollection/latin",
        reason="missing required child element <latin>",
      )
  }
  let ea = match ct_first_child(element, "ea") {
    Some(c) => CT_TextFont::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_FontCollection/ea",
        reason="missing required child element <ea>",
      )
  }
  let cs = match ct_first_child(element, "cs") {
    Some(c) => CT_TextFont::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_FontCollection/cs",
        reason="missing required child element <cs>",
      )
  }
  let fonts : Array[CT_SupplementalFont] = []
  for child in ct_children(element, "font") {
    fonts.push(CT_SupplementalFont::new(child))
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { latin, ea, cs, fonts, ext_lst, element }
}

///|
pub fn CT_FontCollection::to_element(self : CT_FontCollection) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontScheme — Part 1 §20.1.4.1.18 fontScheme.
/// Annex A.4.1 lines 134..141. Two required font collections
/// (`majorFont`, `minorFont`), optional `extLst` and required `name`
/// (xsd:string).
pub(all) struct CT_FontScheme {
  /// <majorFont> (CT_FontCollection) — required.
  major_font : CT_FontCollection
  /// <minorFont> (CT_FontCollection) — required.
  minor_font : CT_FontCollection
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @name — xsd:string (required).
  name : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontScheme::new(
  element : @xml.Element,
) -> CT_FontScheme raise SchemaViolation {
  let major_font = match ct_first_child(element, "majorFont") {
    Some(c) => CT_FontCollection::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_FontScheme/majorFont",
        reason="missing required child element <majorFont>",
      )
  }
  let minor_font = match ct_first_child(element, "minorFont") {
    Some(c) => CT_FontCollection::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_FontScheme/minorFont",
        reason="missing required child element <minorFont>",
      )
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let name = ct_required_string(element, "name", "CT_FontScheme/@name")
  { major_font, minor_font, ext_lst, name, element }
}

///|
pub fn CT_FontScheme::to_element(self : CT_FontScheme) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontReference — Part 1 §20.1.4.1.17 fontRef.
/// Annex A.4.1 lines 2252..2257. Optional EG_ColorChoice arm and
/// required `idx` (ST_FontCollectionIndex) — the font slot to
/// reference.
pub(all) struct CT_FontReference {
  /// EG_ColorChoice — optional CT_Color projection (text/major/minor
  /// font collection accent colour overlay).
  color : CT_Color?
  /// @idx — ST_FontCollectionIndex (required).
  idx : ST_FontCollectionIndex
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontReference::new(
  element : @xml.Element,
) -> CT_FontReference raise SchemaViolation {
  let color = if has_any_color_choice_child(element) {
    Some(CT_Color::new(element))
  } else {
    None
  }
  let idx_lex = ct_required_string(element, "idx", "CT_FontReference/@idx")
  let idx = ST_FontCollectionIndex::parse(idx_lex)
  { color, idx, element }
}

///|
pub fn CT_FontReference::to_element(self : CT_FontReference) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BaseStyles — Part 1 §20.1.6.10 themeElements.
/// Annex A.4.1 lines 173..180. Three required theme child collections
/// (`clrScheme` CT_ColorScheme, `fontScheme` CT_FontScheme,
/// `fmtScheme` CT_StyleMatrix) plus optional `extLst`. CT_ColorScheme
/// and CT_StyleMatrix are not yet typed in this chunk and are kept as
/// raw `@xml.Element` references for downstream chunks to upgrade.
pub(all) struct CT_BaseStyles {
  /// <clrScheme> (CT_ColorScheme) — required. Raw element pending typed
  /// projection in a later chunk.
  clr_scheme : @xml.Element
  /// <fontScheme> (CT_FontScheme) — required.
  font_scheme : CT_FontScheme
  /// <fmtScheme> (CT_StyleMatrix) — required. Raw element pending typed
  /// projection in a later chunk.
  fmt_scheme : @xml.Element
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BaseStyles::new(
  element : @xml.Element,
) -> CT_BaseStyles raise SchemaViolation {
  let clr_scheme = match ct_first_child(element, "clrScheme") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_BaseStyles/clrScheme",
        reason="missing required child element <clrScheme>",
      )
  }
  let font_scheme = match ct_first_child(element, "fontScheme") {
    Some(c) => CT_FontScheme::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_BaseStyles/fontScheme",
        reason="missing required child element <fontScheme>",
      )
  }
  let fmt_scheme = match ct_first_child(element, "fmtScheme") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_BaseStyles/fmtScheme",
        reason="missing required child element <fmtScheme>",
      )
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { clr_scheme, font_scheme, fmt_scheme, ext_lst, element }
}

///|
pub fn CT_BaseStyles::to_element(self : CT_BaseStyles) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OfficeStyleSheet — Part 1 §20.1.6.9 theme. Annex
/// A.4.1 lines 2321..2330. Required `themeElements` (CT_BaseStyles),
/// optional `objectDefaults` (CT_ObjectStyleDefaults), optional
/// `extraClrSchemeLst` (CT_ColorSchemeList), optional `custClrLst`
/// (CT_CustomColorList), optional `extLst` and optional `name`
/// (xsd:string, default ""). The object-defaults / extra-clr-scheme
/// / custom-colour children are not typed in this chunk and are kept
/// as raw `@xml.Element` references for downstream chunks to upgrade.
pub(all) struct CT_OfficeStyleSheet {
  /// <themeElements> (CT_BaseStyles) — required.
  theme_elements : CT_BaseStyles
  /// <objectDefaults> (CT_ObjectStyleDefaults) — optional. Raw element
  /// pending typed projection in a later chunk.
  object_defaults : @xml.Element?
  /// <extraClrSchemeLst> (CT_ColorSchemeList) — optional. Raw element
  /// pending typed projection in a later chunk.
  extra_clr_scheme_lst : @xml.Element?
  /// <custClrLst> (CT_CustomColorList) — optional. Raw element pending
  /// typed projection in a later chunk.
  cust_clr_lst : @xml.Element?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @name — xsd:string (optional, default "").
  name : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeStyleSheet::new(
  element : @xml.Element,
) -> CT_OfficeStyleSheet raise SchemaViolation {
  let theme_elements = match ct_first_child(element, "themeElements") {
    Some(c) => CT_BaseStyles::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_OfficeStyleSheet/themeElements",
        reason="missing required child element <themeElements>",
      )
  }
  let object_defaults = ct_first_child(element, "objectDefaults")
  let extra_clr_scheme_lst = ct_first_child(element, "extraClrSchemeLst")
  let cust_clr_lst = ct_first_child(element, "custClrLst")
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let name = ct_optional_string(element, "name", default="")
  {
    theme_elements,
    object_defaults,
    extra_clr_scheme_lst,
    cust_clr_lst,
    ext_lst,
    name,
    element,
  }
}

///|
pub fn CT_OfficeStyleSheet::to_element(
  self : CT_OfficeStyleSheet,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BaseStylesOverride — Part 1 §20.1.6.11
/// themeOverride. Annex A.4.1 lines 2331..2337. Three optional theme
/// children for partial override: `clrScheme` (CT_ColorScheme),
/// `fontScheme` (CT_FontScheme), `fmtScheme` (CT_StyleMatrix). The
/// colour-scheme / style-matrix arms are kept as raw `@xml.Element`
/// references pending a typed projection in a later chunk.
pub(all) struct CT_BaseStylesOverride {
  /// <clrScheme> (CT_ColorScheme) — optional. Raw element pending typed
  /// projection in a later chunk.
  clr_scheme : @xml.Element?
  /// <fontScheme> (CT_FontScheme) — optional.
  font_scheme : CT_FontScheme?
  /// <fmtScheme> (CT_StyleMatrix) — optional. Raw element pending typed
  /// projection in a later chunk.
  fmt_scheme : @xml.Element?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BaseStylesOverride::new(
  element : @xml.Element,
) -> CT_BaseStylesOverride raise SchemaViolation {
  let clr_scheme = ct_first_child(element, "clrScheme")
  let font_scheme = match ct_first_child(element, "fontScheme") {
    Some(c) => Some(CT_FontScheme::new(c))
    None => None
  }
  let fmt_scheme = ct_first_child(element, "fmtScheme")
  { clr_scheme, font_scheme, fmt_scheme, element }
}

///|
pub fn CT_BaseStylesOverride::to_element(
  self : CT_BaseStylesOverride,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OfficeArtExtension — Part 1 §20.1.2.2.14 ext.
/// Annex A.4.1 lines 181..186. Accepts any well-formed XML children
/// (`xsd:any processContents="lax"`) and requires `uri` (xsd:token)
/// — the unique identifier for the extension namespace.
pub(all) struct CT_OfficeArtExtension {
  /// @uri — xsd:token (required).
  uri : String
  /// xsd:any* children captured as raw elements (lax processing — any
  /// XML allowed; the extension consumer interprets them).
  any : Array[@xml.Element]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeArtExtension::new(
  element : @xml.Element,
) -> CT_OfficeArtExtension raise SchemaViolation {
  let uri = ct_required_string(element, "uri", "CT_OfficeArtExtension/@uri")
  let any : Array[@xml.Element] = []
  for node in element.children {
    match node {
      @xml.Element(child) => any.push(child)
      _ => ()
    }
  }
  { uri, any, element }
}

///|
pub fn CT_OfficeArtExtension::to_element(
  self : CT_OfficeArtExtension,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OfficeArtExtensionList — Part 1 §20.1.2.2.15
/// extLst. The DML extension list complex type collects an unbounded
/// sequence of `ext` (CT_OfficeArtExtension) children. The XSD body is
/// declared inline at every callsite via `xsd:element name="extLst"
/// type="CT_OfficeArtExtensionList"` so the typed projection here
/// codifies the shared shape used by every extLst occurrence.
pub(all) struct CT_OfficeArtExtensionList {
  /// <ext>* (CT_OfficeArtExtension) — zero or more extension entries.
  ext : Array[CT_OfficeArtExtension]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OfficeArtExtensionList::new(
  element : @xml.Element,
) -> CT_OfficeArtExtensionList raise SchemaViolation {
  let ext : Array[CT_OfficeArtExtension] = []
  for child in ct_children(element, "ext") {
    ext.push(CT_OfficeArtExtension::new(child))
  }
  { ext, element }
}

///|
pub fn CT_OfficeArtExtensionList::to_element(
  self : CT_OfficeArtExtensionList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmptyElement — Part 1 §20.1.6.7 themeManager.
/// Annex A.4.1 line 2283. Empty complex type used as a marker for
/// `themeManager` and other "presence only" elements.
pub(all) struct CT_EmptyElement {
  /// Empty-XSD-type marker (always true once decoded).
  marker : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmptyElement::new(element : @xml.Element) -> CT_EmptyElement {
  { marker: true, element }
}

///|
pub fn CT_EmptyElement::to_element(self : CT_EmptyElement) -> @xml.Element {
  self.element
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
