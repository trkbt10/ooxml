///|
/// Construct top-level XSD element recipients as CT_Recipients (§17).
/// Raises SchemaViolation when a `<w:recipientData>` child is missing a
/// required field per Part 1 §17.14.30 / §17.14.31.
pub fn recipients(
  element : @xml.Element,
) -> CT_Recipients raise SchemaViolation {
  CT_Recipients::new(element)
}

///|
/// Construct top-level XSD element comments as CT_Comments (§17.13.4.6).
/// Decoding the children may raise `SchemaViolation` when a required
/// `<comment>` `@id` / `@author` attribute is missing or malformed (per
/// the CT_Comment §17.13.4.2 contract).
pub fn comments(element : @xml.Element) -> CT_Comments raise SchemaViolation {
  CT_Comments::new(element)
}

///|
/// Construct top-level XSD element footnotes as CT_Footnotes (§17.11.16).
/// Raises SchemaViolation when a footnote's required `@id` is missing
/// or malformed per the typed CT_FtnEdn contract.
pub fn footnotes(element : @xml.Element) -> CT_Footnotes raise SchemaViolation {
  CT_Footnotes::new(element)
}

///|
/// Construct top-level XSD element endnotes as CT_Endnotes (§17.11.9).
/// Raises SchemaViolation when an endnote's required `@id` is missing
/// or malformed per the typed CT_FtnEdn contract.
pub fn endnotes(element : @xml.Element) -> CT_Endnotes raise SchemaViolation {
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
/// Construct top-level XSD element fonts as CT_FontsList (§17.8.2.11).
/// Raises SchemaViolation when a `<w:font>` child is missing its
/// required `@name` or has a malformed typed descriptor per CT_Font.
pub fn fonts(element : @xml.Element) -> CT_FontsList raise SchemaViolation {
  CT_FontsList::new(element)
}

///|
/// Construct top-level XSD element numbering as CT_Numbering (§17.9.16).
/// Decoding the children may raise `SchemaViolation` when a required
/// attribute is missing or malformed.
pub fn numbering(element : @xml.Element) -> CT_Numbering raise SchemaViolation {
  CT_Numbering::parse(element)
}

///|
/// Construct top-level XSD element styles as CT_Styles (§17.7.4.18).
/// Raises SchemaViolation when any `<w:style>` child fails the
/// CT_Style contract (missing styleId or unknown ST_StyleType).
pub fn styles(element : @xml.Element) -> CT_Styles raise SchemaViolation {
  CT_Styles::new(element)
}

///|
/// Construct top-level XSD element document as CT_Document (§17.2.4).
/// Raises SchemaViolation when the optional `<w:background>` or
/// `<w:body>` payload contains a typed sub-tree that violates its
/// CT_X contract.
pub fn document(element : @xml.Element) -> CT_Document raise SchemaViolation {
  CT_Document::new(element)
}

///|
/// Construct top-level XSD element glossaryDocument as CT_GlossaryDocument
/// (§11.3.5). Raises SchemaViolation when the optional `<w:docParts>`
/// payload violates the CT_DocParts contract.
pub fn glossary_document(
  element : @xml.Element,
) -> CT_GlossaryDocument raise SchemaViolation {
  CT_GlossaryDocument::new(element)
}
