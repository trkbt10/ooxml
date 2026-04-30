///|
/// PresentationML domain/context → XML writer.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/builder"
}

///|
/// Write top-level XSD element cmAuthorLst from CT_CommentAuthorList (§19).
pub fn write_cm_author_lst(value : @domain.CT_CommentAuthorList) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element cmLst from CT_CommentList (§19).
pub fn write_cm_lst(value : @domain.CT_CommentList) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element oleObj from CT_OleObject (§19).
pub fn write_ole_obj(value : @domain.CT_OleObject) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element presentation from CT_Presentation (§19).
pub fn write_presentation(value : @domain.CT_Presentation) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element presentationPr from CT_PresentationProperties (§19).
pub fn write_presentation_pr(
  value : @domain.CT_PresentationProperties,
) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element sld from CT_Slide (§19).
pub fn write_sld(value : @domain.CT_Slide) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element sldLayout from CT_SlideLayout (§19).
pub fn write_sld_layout(value : @domain.CT_SlideLayout) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element sldMaster from CT_SlideMaster (§19).
pub fn write_sld_master(value : @domain.CT_SlideMaster) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element handoutMaster from CT_HandoutMaster (§19).
pub fn write_handout_master(value : @domain.CT_HandoutMaster) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element notesMaster from CT_NotesMaster (§19).
pub fn write_notes_master(value : @domain.CT_NotesMaster) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element notes from CT_NotesSlide (§19).
pub fn write_notes(value : @domain.CT_NotesSlide) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element sldSyncPr from CT_SlideSyncProperties (§19).
pub fn write_sld_sync_pr(value : @domain.CT_SlideSyncProperties) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element tagLst from CT_TagList (§19).
pub fn write_tag_lst(value : @domain.CT_TagList) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element viewPr from CT_ViewProperties (§19).
pub fn write_view_pr(value : @domain.CT_ViewProperties) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level VML presentationDrawing element iscomment from VmlPresentationDrawing_CT_Empty (Part 4 §16).
pub fn write_vml_presentation_drawing_iscomment(
  value : @domain.VmlPresentationDrawing_CT_Empty,
) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level VML presentationDrawing element textdata from VmlPresentationDrawing_CT_Rel (Part 4 §16).
pub fn write_vml_presentation_drawing_textdata(
  value : @domain.VmlPresentationDrawing_CT_Rel,
) -> Bytes {
  write_element(value.element)
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}
