///|
/// WordprocessingML XML → domain reader.
///
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/reader"
}

///|
/// Read top-level XSD element recipients as CT_Recipients (§17).
pub fn read_recipients(bytes : Bytes) -> @domain.CT_Recipients raise {
  @domain.recipients(read_wml_root(bytes, "recipients"))
}

///|
/// Read top-level XSD element comments as CT_Comments (§17).
pub fn read_comments(bytes : Bytes) -> @domain.CT_Comments raise {
  @domain.comments(read_wml_root(bytes, "comments"))
}

///|
/// Read top-level XSD element footnotes as CT_Footnotes (§17).
pub fn read_footnotes(bytes : Bytes) -> @domain.CT_Footnotes raise {
  @domain.footnotes(read_wml_root(bytes, "footnotes"))
}

///|
/// Read top-level XSD element endnotes as CT_Endnotes (§17).
pub fn read_endnotes(bytes : Bytes) -> @domain.CT_Endnotes raise {
  @domain.endnotes(read_wml_root(bytes, "endnotes"))
}

///|
/// Read top-level XSD element hdr as CT_HdrFtr (§17).
pub fn read_hdr(bytes : Bytes) -> @domain.CT_HdrFtr raise {
  @domain.hdr(read_wml_root(bytes, "hdr"))
}

///|
/// Read top-level XSD element ftr as CT_HdrFtr (§17).
pub fn read_ftr(bytes : Bytes) -> @domain.CT_HdrFtr raise {
  @domain.ftr(read_wml_root(bytes, "ftr"))
}

///|
/// Read top-level XSD element settings as CT_Settings (§17).
pub fn read_settings(bytes : Bytes) -> @domain.CT_Settings raise {
  @domain.settings(read_wml_root(bytes, "settings"))
}

///|
/// Read top-level XSD element webSettings as CT_WebSettings (§17).
pub fn read_web_settings(bytes : Bytes) -> @domain.CT_WebSettings raise {
  @domain.web_settings(read_wml_root(bytes, "webSettings"))
}

///|
/// Read top-level XSD element fonts as CT_FontsList (§17).
pub fn read_fonts(bytes : Bytes) -> @domain.CT_FontsList raise {
  @domain.fonts(read_wml_root(bytes, "fonts"))
}

///|
/// Read top-level XSD element numbering as CT_Numbering (§17).
pub fn read_numbering(bytes : Bytes) -> @domain.CT_Numbering raise {
  @domain.numbering(read_wml_root(bytes, "numbering"))
}

///|
/// Read top-level XSD element styles as CT_Styles (§17).
pub fn read_styles(bytes : Bytes) -> @domain.CT_Styles raise {
  @domain.styles(read_wml_root(bytes, "styles"))
}

///|
/// Read top-level XSD element document as CT_Document (§17).
pub fn read_document(bytes : Bytes) -> @domain.CT_Document raise {
  @domain.document(read_wml_root(bytes, "document"))
}

///|
/// Read top-level XSD element glossaryDocument as CT_GlossaryDocument (§11).
pub fn read_glossary_document(
  bytes : Bytes,
) -> @domain.CT_GlossaryDocument raise {
  @domain.glossary_document(read_wml_root(bytes, "glossaryDocument"))
}

///|
fn read_wml_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name)
  root
}

///|
fn require_local(element : @xml.Element, expected : String) -> Unit raise {
  if element.name.local_name != expected {
    @domain.raise_schema_violation(
      "wml.xsd top-level element",
      element.name.local_name,
      "expected " + expected,
    )
  }
}
