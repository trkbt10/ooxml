///|
/// PresentationML XML → domain reader.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/reader"
}

///|
/// Read top-level XSD element cmAuthorLst as CT_CommentAuthorList (§19).
pub fn read_cm_author_lst(bytes : Bytes) -> @domain.CT_CommentAuthorList raise {
  @domain.cm_author_lst(read_pml_root(bytes, "cmAuthorLst"))
}

///|
/// Read top-level XSD element cmLst as CT_CommentList (§19).
pub fn read_cm_lst(bytes : Bytes) -> @domain.CT_CommentList raise {
  @domain.cm_lst(read_pml_root(bytes, "cmLst"))
}

///|
/// Read top-level XSD element oleObj as CT_OleObject (§19).
pub fn read_ole_obj(bytes : Bytes) -> @domain.CT_OleObject raise {
  @domain.ole_obj(read_pml_root(bytes, "oleObj"))
}

///|
/// Read top-level XSD element presentation as CT_Presentation (§19).
pub fn read_presentation(bytes : Bytes) -> @domain.CT_Presentation raise {
  @domain.presentation(read_pml_root(bytes, "presentation"))
}

///|
/// Read top-level XSD element presentationPr as CT_PresentationProperties (§19).
pub fn read_presentation_pr(
  bytes : Bytes,
) -> @domain.CT_PresentationProperties raise {
  @domain.presentation_pr(read_pml_root(bytes, "presentationPr"))
}

///|
/// Read top-level XSD element sld as CT_Slide (§19).
pub fn read_sld(bytes : Bytes) -> @domain.CT_Slide raise {
  @domain.sld(read_pml_root(bytes, "sld"))
}

///|
/// Read top-level XSD element sldLayout as CT_SlideLayout (§19).
pub fn read_sld_layout(bytes : Bytes) -> @domain.CT_SlideLayout raise {
  @domain.sld_layout(read_pml_root(bytes, "sldLayout"))
}

///|
/// Read top-level XSD element sldMaster as CT_SlideMaster (§19).
pub fn read_sld_master(bytes : Bytes) -> @domain.CT_SlideMaster raise {
  @domain.sld_master(read_pml_root(bytes, "sldMaster"))
}

///|
/// Read top-level XSD element handoutMaster as CT_HandoutMaster (§19).
pub fn read_handout_master(bytes : Bytes) -> @domain.CT_HandoutMaster raise {
  @domain.handout_master(read_pml_root(bytes, "handoutMaster"))
}

///|
/// Read top-level XSD element notesMaster as CT_NotesMaster (§19).
pub fn read_notes_master(bytes : Bytes) -> @domain.CT_NotesMaster raise {
  @domain.notes_master(read_pml_root(bytes, "notesMaster"))
}

///|
/// Read top-level XSD element notes as CT_NotesSlide (§19).
pub fn read_notes(bytes : Bytes) -> @domain.CT_NotesSlide raise {
  @domain.notes(read_pml_root(bytes, "notes"))
}

///|
/// Read top-level XSD element sldSyncPr as CT_SlideSyncProperties (§19).
pub fn read_sld_sync_pr(bytes : Bytes) -> @domain.CT_SlideSyncProperties raise {
  @domain.sld_sync_pr(read_pml_root(bytes, "sldSyncPr"))
}

///|
/// Read top-level XSD element tagLst as CT_TagList (§19).
pub fn read_tag_lst(bytes : Bytes) -> @domain.CT_TagList raise {
  @domain.tag_lst(read_pml_root(bytes, "tagLst"))
}

///|
/// Read top-level XSD element viewPr as CT_ViewProperties (§19).
pub fn read_view_pr(bytes : Bytes) -> @domain.CT_ViewProperties raise {
  @domain.view_pr(read_pml_root(bytes, "viewPr"))
}

///|
/// Read top-level VML presentationDrawing element iscomment as VmlPresentationDrawing_CT_Empty (Part 4 §16).
pub fn read_vml_presentation_drawing_iscomment(
  bytes : Bytes,
) -> @domain.VmlPresentationDrawing_CT_Empty raise {
  @domain.vml_presentation_drawing_iscomment(read_pml_root(bytes, "iscomment"))
}

///|
/// Read top-level VML presentationDrawing element textdata as VmlPresentationDrawing_CT_Rel (Part 4 §16).
pub fn read_vml_presentation_drawing_textdata(
  bytes : Bytes,
) -> @domain.VmlPresentationDrawing_CT_Rel raise {
  @domain.vml_presentation_drawing_textdata(read_pml_root(bytes, "textdata"))
}

///|
fn read_pml_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name)
  root
}

///|
fn require_local(element : @xml.Element, expected : String) -> Unit raise {
  if element.name.local_name != expected {
    @domain.raise_schema_violation(
      "pml.xsd top-level element",
      element.name.local_name,
      "expected " + expected,
    )
  }
}
