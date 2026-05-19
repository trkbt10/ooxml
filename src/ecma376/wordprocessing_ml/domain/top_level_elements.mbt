///|
/// Construct top-level XSD element recipients as CT_Recipients (§17).
pub fn recipients(element : @xml.Element) -> CT_Recipients {
  CT_Recipients::new(element)
}

///|
/// Construct top-level XSD element comments as CT_Comments (§17).
pub fn comments(element : @xml.Element) -> CT_Comments {
  CT_Comments::new(element)
}

///|
/// Construct top-level XSD element footnotes as CT_Footnotes (§17).
pub fn footnotes(element : @xml.Element) -> CT_Footnotes {
  CT_Footnotes::new(element)
}

///|
/// Construct top-level XSD element endnotes as CT_Endnotes (§17).
pub fn endnotes(element : @xml.Element) -> CT_Endnotes {
  CT_Endnotes::new(element)
}

///|
/// Construct top-level XSD element hdr as CT_HdrFtr (§17).
pub fn hdr(element : @xml.Element) -> CT_HdrFtr {
  CT_HdrFtr::new(element)
}

///|
/// Construct top-level XSD element ftr as CT_HdrFtr (§17).
pub fn ftr(element : @xml.Element) -> CT_HdrFtr {
  CT_HdrFtr::new(element)
}

///|
/// Construct top-level XSD element settings as CT_Settings (§17).
pub fn settings(element : @xml.Element) -> CT_Settings {
  CT_Settings::new(element)
}

///|
/// Construct top-level XSD element webSettings as CT_WebSettings (§17).
pub fn web_settings(element : @xml.Element) -> CT_WebSettings {
  CT_WebSettings::new(element)
}

///|
/// Construct top-level XSD element fonts as CT_FontsList (§17).
pub fn fonts(element : @xml.Element) -> CT_FontsList {
  CT_FontsList::new(element)
}

///|
/// Construct top-level XSD element numbering as CT_Numbering (§17).
pub fn numbering(element : @xml.Element) -> CT_Numbering {
  CT_Numbering::new(element)
}

///|
/// Construct top-level XSD element styles as CT_Styles (§17.7.4.18).
/// Raises SchemaViolation when any `<w:style>` child fails the
/// CT_Style contract (missing styleId or unknown ST_StyleType).
pub fn styles(element : @xml.Element) -> CT_Styles raise SchemaViolation {
  CT_Styles::new(element)
}

///|
/// Construct top-level XSD element document as CT_Document (§17).
pub fn document(element : @xml.Element) -> CT_Document {
  CT_Document::new(element)
}

///|
/// Construct top-level XSD element glossaryDocument as CT_GlossaryDocument (§11).
pub fn glossary_document(element : @xml.Element) -> CT_GlossaryDocument {
  CT_GlossaryDocument::new(element)
}
