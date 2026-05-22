///|
/// WordprocessingML domain/context → XML writer.
///
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/builder"
}

///|
/// Write top-level XSD element recipients from CT_Recipients (§17).
pub fn write_recipients(value : @domain.CT_Recipients) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element comments from CT_Comments (§17).
pub fn write_comments(value : @domain.CT_Comments) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element footnotes from CT_Footnotes (§17).
pub fn write_footnotes(value : @domain.CT_Footnotes) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element endnotes from CT_Endnotes (§17).
pub fn write_endnotes(value : @domain.CT_Endnotes) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element hdr from CT_HdrFtr (§17).
pub fn write_hdr(value : @domain.CT_HdrFtr) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element ftr from CT_HdrFtr (§17).
pub fn write_ftr(value : @domain.CT_HdrFtr) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element settings from CT_Settings (§17).
pub fn write_settings(value : @domain.CT_Settings) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element webSettings from CT_WebSettings (§17).
pub fn write_web_settings(value : @domain.CT_WebSettings) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element fonts from CT_FontsList (§17).
pub fn write_fonts(value : @domain.CT_FontsList) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element numbering from CT_Numbering (§17).
pub fn write_numbering(value : @domain.CT_Numbering) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element styles from CT_Styles (§17).
pub fn write_styles(value : @domain.CT_Styles) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element document from CT_Document (§17).
pub fn write_document(value : @domain.CT_Document) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element glossaryDocument from CT_GlossaryDocument (§11).
pub fn write_glossary_document(value : @domain.CT_GlossaryDocument) -> Bytes {
  write_element(value.element)
}

///|
/// ECMA-376 Part 2 §10.1 / OPC §10.1.2 mandate XML 1.0 for every
/// package part, and Office consumers expect the explicit XML
/// declaration with UTF-8 encoding and `standalone="yes"`.
/// Emitting it satisfies Word's strict validator on every part
/// type we produce (`document.xml`, `styles.xml`, `numbering.xml`,
/// header/footer, comments/footnotes/endnotes, glossary).
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({
    declaration: Some({
      version: "1.0",
      encoding: Some("UTF-8"),
      standalone: Some(true),
    }),
    doctype: None,
    root: element,
  })
}
