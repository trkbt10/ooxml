///|
/// PresentationML domain: presentation, slide, slideLayout, slideMaster, notesMaster, handoutMaster.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/domain"
}

///|
/// XSD complex type CT_Empty — Part 1 §A.3 (pml.xsd annex). The schema
/// definition is literally `<xsd:complexType name="CT_Empty"/>`: zero
/// attributes and zero children. CT_Empty is reused as the body of
/// many marker elements — `<p:sldAll>` (§19.2.1.32), `<p:present>`
/// (§19.2.1.25), `<p:bg>` (§19.5.10 timing), `<p:bldAsOne>`
/// (§19.5.15), `<p:sldTgt>` (§19.5.69), and the §19.5.50 preset
/// transitions (`<p:circle>`, `<p:diamond>`, `<p:dissolve>`,
/// `<p:newsflash>`, `<p:plus>`, `<p:random>`, `<p:wedge>`). The only
/// information a typed view must preserve is the element's QName so
/// the writer can round-trip the original tag regardless of which
/// slot the type occupies.
pub(all) struct CT_Empty {
  /// Source-element QName preserved for round-trip. CT_Empty has no
  /// attributes or children per pml.xsd, so this is the typed
  /// replacement for the legacy element-only wrapper field.
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_Empty::new(element : @xml.Element) -> CT_Empty {
  { element_name: element.name }
}

///|
pub fn CT_Empty::parse(element : @xml.Element) -> CT_Empty {
  CT_Empty::new(element)
}

///|
pub fn CT_Empty::to_element(self : CT_Empty) -> @xml.Element {
  { name: self.element_name, attributes: [], children: [] }
}

///|
/// XSD complex type CT_IndexRange — Part 1 §19.3.1.34 (pml.xsd). Backs
/// `<p:sldRg>` (§19.3.1.42) and the timing `<p:charRg>` / `<p:pRg>`
/// elements. Required `@st` and `@end` indices (ST_Index, §19.7.3
/// xsd:unsignedInt).
pub(all) struct CT_IndexRange {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @st (ST_Index §19.7.3) — required start index.
  st : ST_Index
  /// @end (ST_Index §19.7.3) — required end index.
  end_index : ST_Index
} derive(Eq, Debug)

///|
pub fn CT_IndexRange::parse(
  element : @xml.Element,
) -> CT_IndexRange raise SchemaViolation {
  let st = ST_Index::parse(pml_require_attr(element, "st", "CT_IndexRange/@st"))
  let end_index = ST_Index::parse(
    pml_require_attr(element, "end", "CT_IndexRange/@end"),
  )
  { element, st, end_index }
}

///|
pub fn CT_IndexRange::new(element : @xml.Element) -> CT_IndexRange {
  CT_IndexRange::parse(element) catch {
    _ => { element, st: { value: 0U }, end_index: { value: 0U } }
  }
}

///|
pub fn CT_IndexRange::to_element(self : CT_IndexRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideRelationshipListEntry — Part 1 §19.3.1.42
/// (pml.xsd). One `<p:sld>` reference inside a slide-relationship list
/// (slide synchronisation, custom show). Required `@r:id` relationship
/// attribute.
pub(all) struct CT_SlideRelationshipListEntry {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_SlideRelationshipListEntry::parse(
  element : @xml.Element,
) -> CT_SlideRelationshipListEntry raise SchemaViolation {
  let r_id = pml_require_attr(
    element, "id", "CT_SlideRelationshipListEntry/@r:id",
  )
  { element, r_id }
}

///|
pub fn CT_SlideRelationshipListEntry::new(
  element : @xml.Element,
) -> CT_SlideRelationshipListEntry {
  CT_SlideRelationshipListEntry::parse(element) catch {
    _ => { element, r_id: "" }
  }
}

///|
pub fn CT_SlideRelationshipListEntry::to_element(
  self : CT_SlideRelationshipListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideRelationshipList — Part 1 §19.3.1.43
/// (pml.xsd). Sequence of zero or more `<p:sld>` entries
/// (CT_SlideRelationshipListEntry) backing `<p:sldLst>` inside
/// custom-show / slide-sync structures.
pub(all) struct CT_SlideRelationshipList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sld>* (CT_SlideRelationshipListEntry, §19.3.1.42) — zero or more.
  sld : Array[CT_SlideRelationshipListEntry]
} derive(Eq, Debug)

///|
pub fn CT_SlideRelationshipList::parse(
  element : @xml.Element,
) -> CT_SlideRelationshipList raise SchemaViolation {
  let sld : Array[CT_SlideRelationshipListEntry] = []
  for child in pml_children(element, "sld") {
    sld.push(CT_SlideRelationshipListEntry::parse(child))
  }
  { element, sld }
}

///|
pub fn CT_SlideRelationshipList::new(
  element : @xml.Element,
) -> CT_SlideRelationshipList {
  CT_SlideRelationshipList::parse(element) catch {
    _ => { element, sld: [] }
  }
}

///|
pub fn CT_SlideRelationshipList::to_element(
  self : CT_SlideRelationshipList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShowId — Part 1 §19.3.1.16 (pml.xsd). Backs
/// `<p:custShow>` as a slide-list discriminator. Required `@id`
/// (xsd:unsignedInt) referencing a `<p:custShow>` entry on the
/// presentation.
pub(all) struct CT_CustomShowId {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt) — required.
  id : UInt
} derive(Eq, Debug)

///|
pub fn CT_CustomShowId::parse(
  element : @xml.Element,
) -> CT_CustomShowId raise SchemaViolation {
  let id = pml_require_unsigned_int(element, "id", "CT_CustomShowId/@id")
  { element, id }
}

///|
pub fn CT_CustomShowId::new(element : @xml.Element) -> CT_CustomShowId {
  CT_CustomShowId::parse(element) catch {
    _ => { element, id: 0U }
  }
}

///|
pub fn CT_CustomShowId::to_element(self : CT_CustomShowId) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomerData — Part 1 §19.3.1.17 (pml.xsd).
/// Single required `@r:id` relationship attribute referencing customer
/// (third-party) data attached to the slide.
pub(all) struct CT_CustomerData {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_CustomerData::parse(
  element : @xml.Element,
) -> CT_CustomerData raise SchemaViolation {
  let r_id = pml_require_attr(element, "id", "CT_CustomerData/@r:id")
  { element, r_id }
}

///|
pub fn CT_CustomerData::new(element : @xml.Element) -> CT_CustomerData {
  CT_CustomerData::parse(element) catch {
    _ => { element, r_id: "" }
  }
}

///|
pub fn CT_CustomerData::to_element(self : CT_CustomerData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TagsData — Part 1 §19.3.1.47 (pml.xsd). Single
/// required `@r:id` relationship attribute referencing a programmable
/// tag list part attached to the slide.
pub(all) struct CT_TagsData {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_TagsData::parse(
  element : @xml.Element,
) -> CT_TagsData raise SchemaViolation {
  let r_id = pml_require_attr(element, "id", "CT_TagsData/@r:id")
  { element, r_id }
}

///|
pub fn CT_TagsData::new(element : @xml.Element) -> CT_TagsData {
  CT_TagsData::parse(element) catch {
    _ => { element, r_id: "" }
  }
}

///|
pub fn CT_TagsData::to_element(self : CT_TagsData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomerDataList — Part 1 §19.3.1.18 (pml.xsd).
/// Optional sequence containing zero or more `<p:custData>`
/// (CT_CustomerData) followed by an optional `<p:tags>` (CT_TagsData).
pub(all) struct CT_CustomerDataList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <custData>* (CT_CustomerData, §19.3.1.17) — zero or more.
  cust_data : Array[CT_CustomerData]
  /// <tags>? (CT_TagsData, §19.3.1.47) — optional.
  tags : CT_TagsData?
} derive(Eq, Debug)

///|
pub fn CT_CustomerDataList::parse(
  element : @xml.Element,
) -> CT_CustomerDataList raise SchemaViolation {
  let cust_data : Array[CT_CustomerData] = []
  for child in pml_children(element, "custData") {
    cust_data.push(CT_CustomerData::parse(child))
  }
  let tags = match pml_first_child(element, "tags") {
    Some(c) => Some(CT_TagsData::parse(c))
    None => None
  }
  { element, cust_data, tags }
}

///|
pub fn CT_CustomerDataList::new(element : @xml.Element) -> CT_CustomerDataList {
  CT_CustomerDataList::parse(element) catch {
    _ => { element, cust_data: [], tags: None }
  }
}

///|
pub fn CT_CustomerDataList::to_element(
  self : CT_CustomerDataList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Extension — Part 1 §19.2.1.12 (pml.xsd). Single
/// required `@uri` token plus open content (xsd:any from any
/// namespace). The open content payload is preserved verbatim through
/// the source element for round-trip; only the URI is typed.
pub(all) struct CT_Extension {
  /// Preserve source XML element for byte-identical round-trip (carries
  /// the open `xsd:any` payload).
  element : @xml.Element
  /// @uri (xsd:token) — required.
  uri : String
} derive(Eq, Debug)

///|
pub fn CT_Extension::parse(
  element : @xml.Element,
) -> CT_Extension raise SchemaViolation {
  let uri = pml_require_attr(element, "uri", "CT_Extension/@uri")
  { element, uri }
}

///|
pub fn CT_Extension::new(element : @xml.Element) -> CT_Extension {
  CT_Extension::parse(element) catch {
    _ => { element, uri: "" }
  }
}

///|
pub fn CT_Extension::to_element(self : CT_Extension) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ExtensionList — Part 1 §19.2.1.13 (pml.xsd).
/// EG_ExtensionList wrapper: zero or more `<p:ext>` (CT_Extension).
pub(all) struct CT_ExtensionList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <ext>* (CT_Extension, §19.2.1.12) — zero or more.
  ext : Array[CT_Extension]
} derive(Eq, Debug)

///|
pub fn CT_ExtensionList::parse(
  element : @xml.Element,
) -> CT_ExtensionList raise SchemaViolation {
  let ext : Array[CT_Extension] = []
  for child in pml_children(element, "ext") {
    ext.push(CT_Extension::parse(child))
  }
  { element, ext }
}

///|
pub fn CT_ExtensionList::new(element : @xml.Element) -> CT_ExtensionList {
  CT_ExtensionList::parse(element) catch {
    _ => { element, ext: [] }
  }
}

///|
pub fn CT_ExtensionList::to_element(self : CT_ExtensionList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ExtensionListModify — Part 1 §19.2.1.14 (pml.xsd).
/// CT_ExtensionList with the optional `@mod` flag (xsd:boolean, default
/// `false`) indicating that any extensions inside have been modified
/// since the document was last opened.
pub(all) struct CT_ExtensionListModify {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <ext>* (CT_Extension, §19.2.1.12) — zero or more.
  ext : Array[CT_Extension]
  /// @mod (xsd:boolean, default `false`); `None` ⇔ attribute absent.
  mod_ : Bool?
} derive(Eq, Debug)

///|
pub fn CT_ExtensionListModify::parse(
  element : @xml.Element,
) -> CT_ExtensionListModify raise SchemaViolation {
  let ext : Array[CT_Extension] = []
  for child in pml_children(element, "ext") {
    ext.push(CT_Extension::parse(child))
  }
  let mod_ = pml_optional_bool(element, "mod", "CT_ExtensionListModify/@mod")
  { element, ext, mod_ }
}

///|
pub fn CT_ExtensionListModify::new(
  element : @xml.Element,
) -> CT_ExtensionListModify {
  CT_ExtensionListModify::parse(element) catch {
    _ => { element, ext: [], mod_: None }
  }
}

///|
pub fn CT_ExtensionListModify::to_element(
  self : CT_ExtensionListModify,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentAuthor — Part 1 §19.4.2 cmAuthor. A single
/// author entry inside `<p:cmAuthorLst>`. Required attributes describe
/// the author's identity (`@id`, `@name`, `@initials`), running comment
/// counter (`@lastIdx`), and 0-based palette index (`@clrIdx`).
pub(all) struct CT_CommentAuthor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt) — required author id.
  id : UInt
  /// @name (ST_Name §19.7.5) — required author name.
  name : ST_Name
  /// @initials (ST_Name §19.7.5) — required author initials.
  initials : ST_Name
  /// @lastIdx (xsd:unsignedInt) — required highest comment index seen
  /// for this author.
  last_idx : UInt
  /// @clrIdx (xsd:unsignedInt) — required color-palette index for
  /// rendering the comment annotation.
  clr_idx : UInt
  /// <extLst>? (CT_ExtensionList §19.2.1.13) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CommentAuthor::parse(
  element : @xml.Element,
) -> CT_CommentAuthor raise SchemaViolation {
  let id = pml_require_unsigned_int(element, "id", "CT_CommentAuthor/@id")
  let name = ST_Name::parse(
    pml_require_attr(element, "name", "CT_CommentAuthor/@name"),
  )
  let initials = ST_Name::parse(
    pml_require_attr(element, "initials", "CT_CommentAuthor/@initials"),
  )
  let last_idx = pml_require_unsigned_int(
    element, "lastIdx", "CT_CommentAuthor/@lastIdx",
  )
  let clr_idx = pml_require_unsigned_int(
    element, "clrIdx", "CT_CommentAuthor/@clrIdx",
  )
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, id, name, initials, last_idx, clr_idx, ext_lst }
}

///|
pub fn CT_CommentAuthor::new(element : @xml.Element) -> CT_CommentAuthor {
  CT_CommentAuthor::parse(element) catch {
    _ =>
      {
        element,
        id: 0U,
        name: ST_Name::parse(""),
        initials: ST_Name::parse(""),
        last_idx: 0U,
        clr_idx: 0U,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_CommentAuthor::to_element(self : CT_CommentAuthor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentAuthorList — Part 1 §19.4.3 cmAuthorLst.
/// Sequence of zero or more `<p:cmAuthor>` entries (CT_CommentAuthor).
pub(all) struct CT_CommentAuthorList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cmAuthor>* (CT_CommentAuthor §19.4.2) — zero or more.
  cm_author : Array[CT_CommentAuthor]
} derive(Eq, Debug)

///|
pub fn CT_CommentAuthorList::parse(
  element : @xml.Element,
) -> CT_CommentAuthorList raise SchemaViolation {
  let cm_author : Array[CT_CommentAuthor] = []
  for child in pml_children(element, "cmAuthor") {
    cm_author.push(CT_CommentAuthor::parse(child))
  }
  { element, cm_author }
}

///|
pub fn CT_CommentAuthorList::new(
  element : @xml.Element,
) -> CT_CommentAuthorList {
  CT_CommentAuthorList::parse(element) catch {
    _ => { element, cm_author: [] }
  }
}

///|
pub fn CT_CommentAuthorList::to_element(
  self : CT_CommentAuthorList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Comment — Part 1 §19.4.1 cm. One slide comment.
/// Required children `<pos>` (a:CT_Point2D, §19.4.5) and `<text>`
/// (xsd:string text payload, §19.4.6); optional `<extLst>`
/// (CT_ExtensionListModify §19.3.1.20). Required `@authorId`
/// (xsd:unsignedInt) referencing a `<cmAuthor>` entry, optional `@dt`
/// (xsd:dateTime), required `@idx` (ST_Index §19.7.3) unique within
/// the author's running comment counter.
pub(all) struct CT_Comment {
  /// Preserve source XML element for byte-identical round-trip; carries
  /// the `<pos>` payload as `a:CT_Point2D` from DrawingML which the
  /// domain package does not re-decode.
  element : @xml.Element
  /// @authorId (xsd:unsignedInt) — required.
  author_id : UInt
  /// @dt (xsd:dateTime) — optional creation timestamp.
  dt : String?
  /// @idx (ST_Index §19.7.3) — required.
  idx : ST_Index
  /// <pos> (a:CT_Point2D §19.4.5) — required; preserved verbatim because
  /// CT_Point2D is owned by the DrawingML domain package.
  pos : @xml.Element
  /// <text> (xsd:string §19.4.6) — required textual content.
  text : String
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20) — optional.
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_Comment::parse(
  element : @xml.Element,
) -> CT_Comment raise SchemaViolation {
  let author_id = pml_require_unsigned_int(
    element, "authorId", "CT_Comment/@authorId",
  )
  let dt = pml_attr(element, "dt")
  let idx = ST_Index::parse(pml_require_attr(element, "idx", "CT_Comment/@idx"))
  let pos = match pml_first_child(element, "pos") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_Comment/<pos>",
        value="",
        reason="required child missing",
      )
  }
  let text = match pml_first_child(element, "text") {
    Some(c) => collect_text(c)
    None =>
      raise SchemaViolation(
        type_name="CT_Comment/<text>",
        value="",
        reason="required child missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, author_id, dt, idx, pos, text, ext_lst }
}

///|
pub fn CT_Comment::new(element : @xml.Element) -> CT_Comment {
  CT_Comment::parse(element) catch {
    _ =>
      {
        element,
        author_id: 0U,
        dt: None,
        idx: { value: 0U },
        pos: element,
        text: "",
        ext_lst: None,
      }
  }
}

///|
pub fn CT_Comment::to_element(self : CT_Comment) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentList — Part 1 §19.4.4 cmLst. Sequence of
/// zero or more `<p:cm>` entries (CT_Comment).
pub(all) struct CT_CommentList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cm>* (CT_Comment §19.4.1) — zero or more.
  cm : Array[CT_Comment]
} derive(Eq, Debug)

///|
pub fn CT_CommentList::parse(
  element : @xml.Element,
) -> CT_CommentList raise SchemaViolation {
  let cm : Array[CT_Comment] = []
  for child in pml_children(element, "cm") {
    cm.push(CT_Comment::parse(child))
  }
  { element, cm }
}

///|
pub fn CT_CommentList::new(element : @xml.Element) -> CT_CommentList {
  CT_CommentList::parse(element) catch {
    _ => { element, cm: [] }
  }
}

///|
pub fn CT_CommentList::to_element(self : CT_CommentList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OleObjectEmbed — Part 1 §19.3.2.2 embed. Marker
/// that wraps an embedded OLE object. Optional `@followColorScheme`
/// attribute (ST_OleObjectFollowColorScheme §19.7.6, default `"none"`)
/// describing how the embedded object should follow the host's color
/// scheme; optional `<extLst>` child (CT_ExtensionList).
pub(all) struct CT_OleObjectEmbed {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @followColorScheme (ST_OleObjectFollowColorScheme §19.7.6, default
  /// `OleColorNone`); `None` ⇔ attribute absent.
  follow_color_scheme : ST_OleObjectFollowColorScheme?
  /// <extLst>? (CT_ExtensionList §19.2.1.13) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_OleObjectEmbed::parse(
  element : @xml.Element,
) -> CT_OleObjectEmbed raise SchemaViolation {
  let follow_color_scheme = match pml_attr(element, "followColorScheme") {
    Some(v) => Some(ST_OleObjectFollowColorScheme::parse(v))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, follow_color_scheme, ext_lst }
}

///|
pub fn CT_OleObjectEmbed::new(element : @xml.Element) -> CT_OleObjectEmbed {
  CT_OleObjectEmbed::parse(element) catch {
    _ => { element, follow_color_scheme: None, ext_lst: None }
  }
}

///|
pub fn CT_OleObjectEmbed::to_element(self : CT_OleObjectEmbed) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OleObjectLink — Part 1 §19.3.2.3 link. Marker
/// that wraps a linked OLE object. Optional `@updateAutomatic`
/// (xsd:boolean, default `false`) and optional `<extLst>` child.
pub(all) struct CT_OleObjectLink {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @updateAutomatic (xsd:boolean, default `false`); `None` ⇔ absent.
  update_automatic : Bool?
  /// <extLst>? (CT_ExtensionList §19.2.1.13) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_OleObjectLink::parse(
  element : @xml.Element,
) -> CT_OleObjectLink raise SchemaViolation {
  let update_automatic = pml_optional_bool(
    element, "updateAutomatic", "CT_OleObjectLink/@updateAutomatic",
  )
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, update_automatic, ext_lst }
}

///|
pub fn CT_OleObjectLink::new(element : @xml.Element) -> CT_OleObjectLink {
  CT_OleObjectLink::parse(element) catch {
    _ => { element, update_automatic: None, ext_lst: None }
  }
}

///|
pub fn CT_OleObjectLink::to_element(self : CT_OleObjectLink) -> @xml.Element {
  self.element
}

///|
/// CT_OleObject @embed-or-link discriminator. Mirrors the §19.3.2.4
/// `xsd:choice` between the `<embed>` (CT_OleObjectEmbed) and `<link>`
/// (CT_OleObjectLink) branches.
pub(all) enum CT_OleObject_Choice {
  /// §19.3.2.2 embed branch.
  OleEmbed(CT_OleObjectEmbed)
  /// §19.3.2.3 link branch.
  OleLink(CT_OleObjectLink)
} derive(Eq, Debug)

///|
/// XSD complex type CT_OleObject — Part 1 §19.3.2.4 oleObj. Embedded OLE
/// object or ActiveX control on a slide. Required `<embed|link>` choice
/// (CT_OleObjectEmbed | CT_OleObjectLink), required `<pic>` thumbnail
/// (CT_Picture). Attributes via AG_Ole attribute group: optional
/// `@name`, `@showAsIcon`, `@r:id`, `@imgW`, `@imgH`, plus optional
/// `@progId` xsd:string.
pub(all) struct CT_OleObject {
  /// Preserve source XML element for byte-identical round-trip; the
  /// `<pic>` thumbnail is owned by CT_Picture (chunk1/3) so we keep
  /// the raw element for byte-identical round-trip.
  element : @xml.Element
  /// AG_Ole @name (xsd:string, default ""); `None` ⇔ attribute absent.
  name : String?
  /// AG_Ole @showAsIcon (xsd:boolean, default `false`); `None` ⇔ absent.
  show_as_icon : Bool?
  /// AG_Ole @r:id (ST_RelationshipId, optional).
  r_id : String?
  /// AG_Ole @imgW (a:ST_PositiveCoordinate32, EMU); `None` ⇔ absent.
  img_w : UInt?
  /// AG_Ole @imgH (a:ST_PositiveCoordinate32, EMU); `None` ⇔ absent.
  img_h : UInt?
  /// @progId (xsd:string) — optional ProgID for the embedded server.
  prog_id : String?
  /// §19.3.2.4 `<embed>` | `<link>` xsd:choice — required.
  choice : CT_OleObject_Choice
} derive(Eq, Debug)

///|
pub fn CT_OleObject::parse(
  element : @xml.Element,
) -> CT_OleObject raise SchemaViolation {
  let name = pml_attr(element, "name")
  let show_as_icon = pml_optional_bool(
    element, "showAsIcon", "CT_OleObject/@showAsIcon",
  )
  let r_id = pml_attr(element, "id")
  let img_w = pml_optional_unsigned_int(element, "imgW", "CT_OleObject/@imgW")
  let img_h = pml_optional_unsigned_int(element, "imgH", "CT_OleObject/@imgH")
  let prog_id = pml_attr(element, "progId")
  let choice = match pml_first_choice(element, ["embed", "link"]) {
    Some((c, "embed")) => OleEmbed(CT_OleObjectEmbed::parse(c))
    Some((c, "link")) => OleLink(CT_OleObjectLink::parse(c))
    _ =>
      raise SchemaViolation(
        type_name="CT_OleObject/<embed|link>",
        value="",
        reason="required xsd:choice missing",
      )
  }
  { element, name, show_as_icon, r_id, img_w, img_h, prog_id, choice }
}

///|
pub fn CT_OleObject::new(element : @xml.Element) -> CT_OleObject {
  CT_OleObject::parse(element) catch {
    _ =>
      {
        element,
        name: None,
        show_as_icon: None,
        r_id: None,
        img_w: None,
        img_h: None,
        prog_id: None,
        choice: OleEmbed({ element, follow_color_scheme: None, ext_lst: None }),
      }
  }
}

///|
pub fn CT_OleObject::to_element(self : CT_OleObject) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Control — Part 1 §19.3.2.1 control. Embedded
/// ActiveX-control reference on a slide. Optional `<extLst>` and
/// optional `<pic>` thumbnail children. Attributes via AG_Ole: `@name`,
/// `@showAsIcon`, `@r:id`, `@imgW`, `@imgH`.
pub(all) struct CT_Control {
  /// Preserve source XML element for byte-identical round-trip; the
  /// `<pic>` payload is owned by CT_Picture (chunk1/3).
  element : @xml.Element
  /// AG_Ole @name (xsd:string, default ""); `None` ⇔ absent.
  name : String?
  /// AG_Ole @showAsIcon (xsd:boolean, default `false`); `None` ⇔ absent.
  show_as_icon : Bool?
  /// AG_Ole @r:id (ST_RelationshipId, optional).
  r_id : String?
  /// AG_Ole @imgW (a:ST_PositiveCoordinate32, EMU); `None` ⇔ absent.
  img_w : UInt?
  /// AG_Ole @imgH (a:ST_PositiveCoordinate32, EMU); `None` ⇔ absent.
  img_h : UInt?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Control::parse(
  element : @xml.Element,
) -> CT_Control raise SchemaViolation {
  let name = pml_attr(element, "name")
  let show_as_icon = pml_optional_bool(
    element, "showAsIcon", "CT_Control/@showAsIcon",
  )
  let r_id = pml_attr(element, "id")
  let img_w = pml_optional_unsigned_int(element, "imgW", "CT_Control/@imgW")
  let img_h = pml_optional_unsigned_int(element, "imgH", "CT_Control/@imgH")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, name, show_as_icon, r_id, img_w, img_h, ext_lst }
}

///|
pub fn CT_Control::new(element : @xml.Element) -> CT_Control {
  CT_Control::parse(element) catch {
    _ =>
      {
        element,
        name: None,
        show_as_icon: None,
        r_id: None,
        img_w: None,
        img_h: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_Control::to_element(self : CT_Control) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ControlList — Part 1 §19.3.1.15 controls.
/// Sequence of zero or more `<p:control>` entries (CT_Control).
pub(all) struct CT_ControlList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <control>* (CT_Control §19.3.2.1) — zero or more.
  control : Array[CT_Control]
} derive(Eq, Debug)

///|
pub fn CT_ControlList::parse(
  element : @xml.Element,
) -> CT_ControlList raise SchemaViolation {
  let control : Array[CT_Control] = []
  for child in pml_children(element, "control") {
    control.push(CT_Control::parse(child))
  }
  { element, control }
}

///|
pub fn CT_ControlList::new(element : @xml.Element) -> CT_ControlList {
  CT_ControlList::parse(element) catch {
    _ => { element, control: [] }
  }
}

///|
pub fn CT_ControlList::to_element(self : CT_ControlList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideIdListEntry — Part 1 §19.2.1.33 sldId. One
/// slide reference inside `<p:sldIdLst>`. Required `@id` (ST_SlideId
/// §19.7.13) and `@r:id` (ST_RelationshipId) referencing the slide
/// part; optional `<extLst>` child (CT_ExtensionList).
pub(all) struct CT_SlideIdListEntry {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (ST_SlideId §19.7.13) — required, in [256, 2147483648).
  id : ST_SlideId
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
  /// <extLst>? (CT_ExtensionList §19.2.1.13) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SlideIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideIdListEntry raise SchemaViolation {
  let id = ST_SlideId::parse(
    pml_require_attr(element, "id", "CT_SlideIdListEntry/@id"),
  )
  let r_id = pml_require_attr(element, "id", "CT_SlideIdListEntry/@r:id")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, id, r_id, ext_lst }
}

///|
pub fn CT_SlideIdListEntry::new(element : @xml.Element) -> CT_SlideIdListEntry {
  CT_SlideIdListEntry::parse(element) catch {
    _ => { element, id: { value: 256U }, r_id: "", ext_lst: None }
  }
}

///|
pub fn CT_SlideIdListEntry::to_element(
  self : CT_SlideIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideIdList — Part 1 §19.2.1.34 sldIdLst.
/// Sequence of zero or more `<p:sldId>` entries (CT_SlideIdListEntry).
pub(all) struct CT_SlideIdList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sldId>* (CT_SlideIdListEntry §19.2.1.33) — zero or more.
  sld_id : Array[CT_SlideIdListEntry]
} derive(Eq, Debug)

///|
pub fn CT_SlideIdList::parse(
  element : @xml.Element,
) -> CT_SlideIdList raise SchemaViolation {
  let sld_id : Array[CT_SlideIdListEntry] = []
  for child in pml_children(element, "sldId") {
    sld_id.push(CT_SlideIdListEntry::parse(child))
  }
  { element, sld_id }
}

///|
pub fn CT_SlideIdList::new(element : @xml.Element) -> CT_SlideIdList {
  CT_SlideIdList::parse(element) catch {
    _ => { element, sld_id: [] }
  }
}

///|
pub fn CT_SlideIdList::to_element(self : CT_SlideIdList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterIdListEntry — Part 1 §19.2.1.36
/// sldMasterId. One slide-master reference inside `<p:sldMasterIdLst>`.
/// Optional `@id` (ST_SlideMasterId §19.7.16, ≥ 2147483648) and
/// required `@r:id` (ST_RelationshipId) referencing the slide-master
/// part; optional `<extLst>` child (CT_ExtensionList).
pub(all) struct CT_SlideMasterIdListEntry {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (ST_SlideMasterId §19.7.16, optional, ≥ 2147483648).
  id : ST_SlideMasterId?
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
  /// <extLst>? (CT_ExtensionList §19.2.1.13) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideMasterIdListEntry raise SchemaViolation {
  let id = match pml_attr(element, "id") {
    Some(v) => Some(ST_SlideMasterId::parse(v))
    None => None
  }
  let r_id = pml_require_attr(element, "id", "CT_SlideMasterIdListEntry/@r:id")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, id, r_id, ext_lst }
}

///|
pub fn CT_SlideMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_SlideMasterIdListEntry {
  CT_SlideMasterIdListEntry::parse(element) catch {
    _ => { element, id: None, r_id: "", ext_lst: None }
  }
}

///|
pub fn CT_SlideMasterIdListEntry::to_element(
  self : CT_SlideMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterIdList — Part 1 §19.2.1.37
/// sldMasterIdLst. Sequence of zero or more `<p:sldMasterId>` entries
/// (CT_SlideMasterIdListEntry).
pub(all) struct CT_SlideMasterIdList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sldMasterId>* (CT_SlideMasterIdListEntry §19.2.1.36).
  sld_master_id : Array[CT_SlideMasterIdListEntry]
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterIdList::parse(
  element : @xml.Element,
) -> CT_SlideMasterIdList raise SchemaViolation {
  let sld_master_id : Array[CT_SlideMasterIdListEntry] = []
  for child in pml_children(element, "sldMasterId") {
    sld_master_id.push(CT_SlideMasterIdListEntry::parse(child))
  }
  { element, sld_master_id }
}

///|
pub fn CT_SlideMasterIdList::new(
  element : @xml.Element,
) -> CT_SlideMasterIdList {
  CT_SlideMasterIdList::parse(element) catch {
    _ => { element, sld_master_id: [] }
  }
}

///|
pub fn CT_SlideMasterIdList::to_element(
  self : CT_SlideMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMasterIdListEntry — Part 1 §19.2.1.20
/// notesMasterId. Single `<p:notesMasterId>` entry with required
/// `@r:id` (ST_RelationshipId) and optional `<extLst>` child.
pub(all) struct CT_NotesMasterIdListEntry {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
  /// <extLst>? (CT_ExtensionList §19.2.1.13) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_NotesMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_NotesMasterIdListEntry raise SchemaViolation {
  let r_id = pml_require_attr(element, "id", "CT_NotesMasterIdListEntry/@r:id")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, r_id, ext_lst }
}

///|
pub fn CT_NotesMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_NotesMasterIdListEntry {
  CT_NotesMasterIdListEntry::parse(element) catch {
    _ => { element, r_id: "", ext_lst: None }
  }
}

///|
pub fn CT_NotesMasterIdListEntry::to_element(
  self : CT_NotesMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMasterIdList — Part 1 §19.2.1.21
/// notesMasterIdLst. Sequence containing at most one `<p:notesMasterId>`
/// entry (CT_NotesMasterIdListEntry).
pub(all) struct CT_NotesMasterIdList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <notesMasterId>? (CT_NotesMasterIdListEntry §19.2.1.20) — at most
  /// one occurrence per schema.
  notes_master_id : CT_NotesMasterIdListEntry?
} derive(Eq, Debug)

///|
pub fn CT_NotesMasterIdList::parse(
  element : @xml.Element,
) -> CT_NotesMasterIdList raise SchemaViolation {
  let notes_master_id = match pml_first_child(element, "notesMasterId") {
    Some(c) => Some(CT_NotesMasterIdListEntry::parse(c))
    None => None
  }
  { element, notes_master_id }
}

///|
pub fn CT_NotesMasterIdList::new(
  element : @xml.Element,
) -> CT_NotesMasterIdList {
  CT_NotesMasterIdList::parse(element) catch {
    _ => { element, notes_master_id: None }
  }
}

///|
pub fn CT_NotesMasterIdList::to_element(
  self : CT_NotesMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMasterIdListEntry — Part 1 §19.2.1.14
/// handoutMasterId. Single `<p:handoutMasterId>` entry with required
/// `@r:id` (ST_RelationshipId) and optional `<extLst>` child.
pub(all) struct CT_HandoutMasterIdListEntry {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
  /// <extLst>? (CT_ExtensionList §19.2.1.13) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_HandoutMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_HandoutMasterIdListEntry raise SchemaViolation {
  let r_id = pml_require_attr(
    element, "id", "CT_HandoutMasterIdListEntry/@r:id",
  )
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, r_id, ext_lst }
}

///|
pub fn CT_HandoutMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_HandoutMasterIdListEntry {
  CT_HandoutMasterIdListEntry::parse(element) catch {
    _ => { element, r_id: "", ext_lst: None }
  }
}

///|
pub fn CT_HandoutMasterIdListEntry::to_element(
  self : CT_HandoutMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMasterIdList — Part 1 §19.2.1.15
/// handoutMasterIdLst. Sequence containing at most one
/// `<p:handoutMasterId>` entry (CT_HandoutMasterIdListEntry).
pub(all) struct CT_HandoutMasterIdList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <handoutMasterId>? (CT_HandoutMasterIdListEntry §19.2.1.14).
  handout_master_id : CT_HandoutMasterIdListEntry?
} derive(Eq, Debug)

///|
pub fn CT_HandoutMasterIdList::parse(
  element : @xml.Element,
) -> CT_HandoutMasterIdList raise SchemaViolation {
  let handout_master_id = match pml_first_child(element, "handoutMasterId") {
    Some(c) => Some(CT_HandoutMasterIdListEntry::parse(c))
    None => None
  }
  { element, handout_master_id }
}

///|
pub fn CT_HandoutMasterIdList::new(
  element : @xml.Element,
) -> CT_HandoutMasterIdList {
  CT_HandoutMasterIdList::parse(element) catch {
    _ => { element, handout_master_id: None }
  }
}

///|
pub fn CT_HandoutMasterIdList::to_element(
  self : CT_HandoutMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontDataId — Part 1 §19.2.1.29 regular
/// (also §19.2.1.1 bold, §19.2.1.2 boldItalic, §19.2.1.16 italic). One
/// face-style slot inside `<p:embeddedFont>`. Required `@r:id`
/// (ST_RelationshipId) referencing the embedded font part.
pub(all) struct CT_EmbeddedFontDataId {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontDataId::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontDataId raise SchemaViolation {
  let r_id = pml_require_attr(element, "id", "CT_EmbeddedFontDataId/@r:id")
  { element, r_id }
}

///|
pub fn CT_EmbeddedFontDataId::new(
  element : @xml.Element,
) -> CT_EmbeddedFontDataId {
  CT_EmbeddedFontDataId::parse(element) catch {
    _ => { element, r_id: "" }
  }
}

///|
pub fn CT_EmbeddedFontDataId::to_element(
  self : CT_EmbeddedFontDataId,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontListEntry — Part 1 §19.2.1.9
/// embeddedFont. One embedded-font definition: required `<font>` child
/// (`a:CT_TextFont` §19.2.1.13 — DrawingML; preserved as raw element
/// because it lives in the DrawingML domain), plus optional `<regular>`,
/// `<bold>`, `<italic>`, `<boldItalic>` face slots
/// (CT_EmbeddedFontDataId).
pub(all) struct CT_EmbeddedFontListEntry {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <font> (a:CT_TextFont) — required; preserved as raw element since
  /// the DrawingML domain owns CT_TextFont.
  font : @xml.Element
  /// <regular>? (CT_EmbeddedFontDataId §19.2.1.29).
  regular : CT_EmbeddedFontDataId?
  /// <bold>? (CT_EmbeddedFontDataId §19.2.1.1).
  bold : CT_EmbeddedFontDataId?
  /// <italic>? (CT_EmbeddedFontDataId §19.2.1.16).
  italic : CT_EmbeddedFontDataId?
  /// <boldItalic>? (CT_EmbeddedFontDataId §19.2.1.2).
  bold_italic : CT_EmbeddedFontDataId?
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontListEntry::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontListEntry raise SchemaViolation {
  let font = match pml_first_child(element, "font") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_EmbeddedFontListEntry/<font>",
        value="",
        reason="required child missing",
      )
  }
  let regular = match pml_first_child(element, "regular") {
    Some(c) => Some(CT_EmbeddedFontDataId::parse(c))
    None => None
  }
  let bold = match pml_first_child(element, "bold") {
    Some(c) => Some(CT_EmbeddedFontDataId::parse(c))
    None => None
  }
  let italic = match pml_first_child(element, "italic") {
    Some(c) => Some(CT_EmbeddedFontDataId::parse(c))
    None => None
  }
  let bold_italic = match pml_first_child(element, "boldItalic") {
    Some(c) => Some(CT_EmbeddedFontDataId::parse(c))
    None => None
  }
  { element, font, regular, bold, italic, bold_italic }
}

///|
pub fn CT_EmbeddedFontListEntry::new(
  element : @xml.Element,
) -> CT_EmbeddedFontListEntry {
  CT_EmbeddedFontListEntry::parse(element) catch {
    _ =>
      {
        element,
        font: element,
        regular: None,
        bold: None,
        italic: None,
        bold_italic: None,
      }
  }
}

///|
pub fn CT_EmbeddedFontListEntry::to_element(
  self : CT_EmbeddedFontListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontList — Part 1 §19.2.1.10
/// embeddedFontLst. Sequence of zero or more `<p:embeddedFont>` entries
/// (CT_EmbeddedFontListEntry).
pub(all) struct CT_EmbeddedFontList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <embeddedFont>* (CT_EmbeddedFontListEntry §19.2.1.9).
  embedded_font : Array[CT_EmbeddedFontListEntry]
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontList::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontList raise SchemaViolation {
  let embedded_font : Array[CT_EmbeddedFontListEntry] = []
  for child in pml_children(element, "embeddedFont") {
    embedded_font.push(CT_EmbeddedFontListEntry::parse(child))
  }
  { element, embedded_font }
}

///|
pub fn CT_EmbeddedFontList::new(element : @xml.Element) -> CT_EmbeddedFontList {
  CT_EmbeddedFontList::parse(element) catch {
    _ => { element, embedded_font: [] }
  }
}

///|
pub fn CT_EmbeddedFontList::to_element(
  self : CT_EmbeddedFontList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTags — Part 1 §19.2.1.40 smartTags. Required
/// `@r:id` (ST_RelationshipId) referencing the smart-tags part for the
/// presentation.
pub(all) struct CT_SmartTags {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_SmartTags::parse(
  element : @xml.Element,
) -> CT_SmartTags raise SchemaViolation {
  let r_id = pml_require_attr(element, "id", "CT_SmartTags/@r:id")
  { element, r_id }
}

///|
pub fn CT_SmartTags::new(element : @xml.Element) -> CT_SmartTags {
  CT_SmartTags::parse(element) catch {
    _ => { element, r_id: "" }
  }
}

///|
pub fn CT_SmartTags::to_element(self : CT_SmartTags) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShow — Part 1 §19.2.1.6 custShow. One
/// custom-show definition. Required `<sldLst>` child
/// (CT_SlideRelationshipList §19.3.1.43) plus optional `<extLst>`
/// (CT_ExtensionList). Required `@name` (ST_Name §19.7.5) and `@id`
/// (xsd:unsignedInt).
pub(all) struct CT_CustomShow {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (ST_Name §19.7.5) — required.
  name : ST_Name
  /// @id (xsd:unsignedInt) — required.
  id : UInt
  /// <sldLst> (CT_SlideRelationshipList §19.3.1.43) — required.
  sld_lst : CT_SlideRelationshipList
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CustomShow::parse(
  element : @xml.Element,
) -> CT_CustomShow raise SchemaViolation {
  let name = ST_Name::parse(
    pml_require_attr(element, "name", "CT_CustomShow/@name"),
  )
  let id = pml_require_unsigned_int(element, "id", "CT_CustomShow/@id")
  let sld_lst = match pml_first_child(element, "sldLst") {
    Some(c) => CT_SlideRelationshipList::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_CustomShow/<sldLst>",
        value="",
        reason="required child missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, name, id, sld_lst, ext_lst }
}

///|
pub fn CT_CustomShow::new(element : @xml.Element) -> CT_CustomShow {
  CT_CustomShow::parse(element) catch {
    _ =>
      {
        element,
        name: ST_Name::parse(""),
        id: 0U,
        sld_lst: { element, sld: [] },
        ext_lst: None,
      }
  }
}

///|
pub fn CT_CustomShow::to_element(self : CT_CustomShow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShowList — Part 1 §19.2.1.7 custShowLst.
/// Sequence of zero or more `<p:custShow>` entries (CT_CustomShow).
pub(all) struct CT_CustomShowList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <custShow>* (CT_CustomShow §19.2.1.6).
  cust_show : Array[CT_CustomShow]
} derive(Eq, Debug)

///|
pub fn CT_CustomShowList::parse(
  element : @xml.Element,
) -> CT_CustomShowList raise SchemaViolation {
  let cust_show : Array[CT_CustomShow] = []
  for child in pml_children(element, "custShow") {
    cust_show.push(CT_CustomShow::parse(child))
  }
  { element, cust_show }
}

///|
pub fn CT_CustomShowList::new(element : @xml.Element) -> CT_CustomShowList {
  CT_CustomShowList::parse(element) catch {
    _ => { element, cust_show: [] }
  }
}

///|
pub fn CT_CustomShowList::to_element(self : CT_CustomShowList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PhotoAlbum — Part 1 §19.2.1.24 photoAlbum.
/// Optional `<extLst>` child plus four optional attributes describing
/// the photo-album layout: `@bw` (xsd:boolean, default `false`),
/// `@showCaptions` (xsd:boolean, default `false`), `@layout`
/// (ST_PhotoAlbumLayout §19.7.8, default `"fitToSlide"`), `@frame`
/// (ST_PhotoAlbumFrameShape §19.7.7, default `"frameStyle1"`).
pub(all) struct CT_PhotoAlbum {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @bw (xsd:boolean, default `false`); `None` ⇔ absent.
  bw : Bool?
  /// @showCaptions (xsd:boolean, default `false`); `None` ⇔ absent.
  show_captions : Bool?
  /// @layout (ST_PhotoAlbumLayout §19.7.8, default `AlbumFitToSlide`).
  layout : ST_PhotoAlbumLayout?
  /// @frame (ST_PhotoAlbumFrameShape §19.7.7, default `FrameStyle1`).
  frame : ST_PhotoAlbumFrameShape?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PhotoAlbum::parse(
  element : @xml.Element,
) -> CT_PhotoAlbum raise SchemaViolation {
  let bw = pml_optional_bool(element, "bw", "CT_PhotoAlbum/@bw")
  let show_captions = pml_optional_bool(
    element, "showCaptions", "CT_PhotoAlbum/@showCaptions",
  )
  let layout = match pml_attr(element, "layout") {
    Some(v) => Some(ST_PhotoAlbumLayout::parse(v))
    None => None
  }
  let frame = match pml_attr(element, "frame") {
    Some(v) => Some(ST_PhotoAlbumFrameShape::parse(v))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, bw, show_captions, layout, frame, ext_lst }
}

///|
pub fn CT_PhotoAlbum::new(element : @xml.Element) -> CT_PhotoAlbum {
  CT_PhotoAlbum::parse(element) catch {
    _ =>
      {
        element,
        bw: None,
        show_captions: None,
        layout: None,
        frame: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_PhotoAlbum::to_element(self : CT_PhotoAlbum) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSize — Part 1 §19.2.1.39 sldSz. Required
/// `@cx` and `@cy` slide-size coordinates (ST_SlideSizeCoordinate
/// §19.7.17, EMU in [914400, 51206400]); optional `@type`
/// (ST_SlideSizeType §19.7.18, default `"custom"`).
pub(all) struct CT_SlideSize {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @cx (ST_SlideSizeCoordinate §19.7.17) — required slide width EMU.
  cx : ST_SlideSizeCoordinate
  /// @cy (ST_SlideSizeCoordinate §19.7.17) — required slide height EMU.
  cy : ST_SlideSizeCoordinate
  /// @type (ST_SlideSizeType §19.7.18, default `SlideSizeCustom`).
  size_type : ST_SlideSizeType?
} derive(Eq, Debug)

///|
pub fn CT_SlideSize::parse(
  element : @xml.Element,
) -> CT_SlideSize raise SchemaViolation {
  let cx = ST_SlideSizeCoordinate::parse(
    pml_require_attr(element, "cx", "CT_SlideSize/@cx"),
  )
  let cy = ST_SlideSizeCoordinate::parse(
    pml_require_attr(element, "cy", "CT_SlideSize/@cy"),
  )
  let size_type = match pml_attr(element, "type") {
    Some(v) => Some(ST_SlideSizeType::parse(v))
    None => None
  }
  { element, cx, cy, size_type }
}

///|
pub fn CT_SlideSize::new(element : @xml.Element) -> CT_SlideSize {
  CT_SlideSize::parse(element) catch {
    _ => { element, cx: { emu: 914400 }, cy: { emu: 914400 }, size_type: None }
  }
}

///|
pub fn CT_SlideSize::to_element(self : CT_SlideSize) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Kinsoku — Part 1 §19.2.1.17 kinsoku. East-Asian
/// kinsoku-shori character rules for the presentation. Optional `@lang`
/// (xsd:string, BCP-47 language tag); required `@invalStChars`
/// (xsd:string — characters not allowed at the start of a line) and
/// `@invalEndChars` (xsd:string — characters not allowed at the end).
pub(all) struct CT_Kinsoku {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @lang (xsd:string) — optional language tag.
  lang : String?
  /// @invalStChars (xsd:string) — required start-of-line forbidden set.
  inval_st_chars : String
  /// @invalEndChars (xsd:string) — required end-of-line forbidden set.
  inval_end_chars : String
} derive(Eq, Debug)

///|
pub fn CT_Kinsoku::parse(
  element : @xml.Element,
) -> CT_Kinsoku raise SchemaViolation {
  let lang = pml_attr(element, "lang")
  let inval_st_chars = pml_require_attr(
    element, "invalStChars", "CT_Kinsoku/@invalStChars",
  )
  let inval_end_chars = pml_require_attr(
    element, "invalEndChars", "CT_Kinsoku/@invalEndChars",
  )
  { element, lang, inval_st_chars, inval_end_chars }
}

///|
pub fn CT_Kinsoku::new(element : @xml.Element) -> CT_Kinsoku {
  CT_Kinsoku::parse(element) catch {
    _ => { element, lang: None, inval_st_chars: "", inval_end_chars: "" }
  }
}

///|
pub fn CT_Kinsoku::to_element(self : CT_Kinsoku) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ModifyVerifier — Part 1 §19.2.1.19 modifyVerifier.
/// Read-only password verifier for the presentation. All attributes are
/// optional: `@algorithmName` (xsd:string), `@hashValue`
/// (xsd:base64Binary), `@saltValue` (xsd:base64Binary), `@spinValue`
/// (xsd:unsignedInt).
pub(all) struct CT_ModifyVerifier {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @algorithmName (xsd:string) — optional.
  algorithm_name : String?
  /// @hashValue (xsd:base64Binary) — optional; preserved as lexical
  /// base64 string (decoding happens in the encryption layer).
  hash_value : String?
  /// @saltValue (xsd:base64Binary) — optional.
  salt_value : String?
  /// @spinValue (xsd:unsignedInt) — optional iteration count.
  spin_value : UInt?
} derive(Eq, Debug)

///|
pub fn CT_ModifyVerifier::parse(
  element : @xml.Element,
) -> CT_ModifyVerifier raise SchemaViolation {
  let algorithm_name = pml_attr(element, "algorithmName")
  let hash_value = pml_attr(element, "hashValue")
  let salt_value = pml_attr(element, "saltValue")
  let spin_value = pml_optional_unsigned_int(
    element, "spinValue", "CT_ModifyVerifier/@spinValue",
  )
  { element, algorithm_name, hash_value, salt_value, spin_value }
}

///|
pub fn CT_ModifyVerifier::new(element : @xml.Element) -> CT_ModifyVerifier {
  CT_ModifyVerifier::parse(element) catch {
    _ =>
      {
        element,
        algorithm_name: None,
        hash_value: None,
        salt_value: None,
        spin_value: None,
      }
  }
}

///|
pub fn CT_ModifyVerifier::to_element(self : CT_ModifyVerifier) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Presentation — Part 1 §19.2.1.26 presentation.
/// Root of the PresentationML presentation part. Optional children in
/// xsd:sequence order: `<sldMasterIdLst>` (CT_SlideMasterIdList),
/// `<notesMasterIdLst>` (CT_NotesMasterIdList), `<handoutMasterIdLst>`
/// (CT_HandoutMasterIdList), `<sldIdLst>` (CT_SlideIdList), `<sldSz>`
/// (CT_SlideSize), required `<notesSz>` (a:CT_PositiveSize2D — owned
/// by DrawingML, preserved as raw element), `<smartTags>` (CT_SmartTags),
/// `<embeddedFontLst>` (CT_EmbeddedFontList), `<custShowLst>`
/// (CT_CustomShowList), `<photoAlbum>` (CT_PhotoAlbum), `<custDataLst>`
/// (CT_CustomerDataList), `<kinsoku>` (CT_Kinsoku), `<defaultTextStyle>`
/// (a:CT_TextListStyle, raw), `<modifyVerifier>` (CT_ModifyVerifier),
/// `<extLst>` (CT_ExtensionList). Attributes (all optional with
/// schema defaults): `@serverZoom` (a:ST_Percentage, default "50%"),
/// `@firstSlideNum` (xsd:int, default 1), `@showSpecialPlsOnTitleSld`
/// (xsd:boolean, default `true`), `@rtl` (xsd:boolean, default `false`),
/// `@removePersonalInfoOnSave` (xsd:boolean, default `false`),
/// `@compatMode` (xsd:boolean, default `false`),
/// `@strictFirstAndLastChars` (xsd:boolean, default `true`),
/// `@embedTrueTypeFonts` (xsd:boolean, default `false`),
/// `@saveSubsetFonts` (xsd:boolean, default `false`),
/// `@autoCompressPictures` (xsd:boolean, default `true`),
/// `@bookmarkIdSeed` (ST_BookmarkIdSeed §19.7.1, default `1`),
/// `@conformance` (s:ST_ConformanceClass) — preserved as lexical token
/// since the schema's owner package is `shared`.
pub(all) struct CT_Presentation {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @serverZoom (a:ST_Percentage, default "50%"); preserved as lexical
  /// string because DrawingML owns the percentage type.
  server_zoom : String?
  /// @firstSlideNum (xsd:int, default 1); `None` ⇔ attribute absent.
  first_slide_num : Int?
  /// @showSpecialPlsOnTitleSld (xsd:boolean, default `true`).
  show_special_pls_on_title_sld : Bool?
  /// @rtl (xsd:boolean, default `false`).
  rtl : Bool?
  /// @removePersonalInfoOnSave (xsd:boolean, default `false`).
  remove_personal_info_on_save : Bool?
  /// @compatMode (xsd:boolean, default `false`).
  compat_mode : Bool?
  /// @strictFirstAndLastChars (xsd:boolean, default `true`).
  strict_first_and_last_chars : Bool?
  /// @embedTrueTypeFonts (xsd:boolean, default `false`).
  embed_true_type_fonts : Bool?
  /// @saveSubsetFonts (xsd:boolean, default `false`).
  save_subset_fonts : Bool?
  /// @autoCompressPictures (xsd:boolean, default `true`).
  auto_compress_pictures : Bool?
  /// @bookmarkIdSeed (ST_BookmarkIdSeed §19.7.1, default 1).
  bookmark_id_seed : ST_BookmarkIdSeed?
  /// @conformance (s:ST_ConformanceClass) — lexical token preserved.
  conformance : String?
  /// <sldMasterIdLst>? (CT_SlideMasterIdList §19.2.1.37).
  sld_master_id_lst : CT_SlideMasterIdList?
  /// <notesMasterIdLst>? (CT_NotesMasterIdList §19.2.1.21).
  notes_master_id_lst : CT_NotesMasterIdList?
  /// <handoutMasterIdLst>? (CT_HandoutMasterIdList §19.2.1.15).
  handout_master_id_lst : CT_HandoutMasterIdList?
  /// <sldIdLst>? (CT_SlideIdList §19.2.1.34).
  sld_id_lst : CT_SlideIdList?
  /// <sldSz>? (CT_SlideSize §19.2.1.39).
  sld_sz : CT_SlideSize?
  /// <notesSz> (a:CT_PositiveSize2D §19.2.1.22) — required; preserved
  /// as raw element because the DrawingML domain owns CT_PositiveSize2D.
  notes_sz : @xml.Element
  /// <smartTags>? (CT_SmartTags §19.2.1.40).
  smart_tags : CT_SmartTags?
  /// <embeddedFontLst>? (CT_EmbeddedFontList §19.2.1.10).
  embedded_font_lst : CT_EmbeddedFontList?
  /// <custShowLst>? (CT_CustomShowList §19.2.1.7).
  cust_show_lst : CT_CustomShowList?
  /// <photoAlbum>? (CT_PhotoAlbum §19.2.1.24).
  photo_album : CT_PhotoAlbum?
  /// <custDataLst>? (CT_CustomerDataList §19.3.1.18).
  cust_data_lst : CT_CustomerDataList?
  /// <kinsoku>? (CT_Kinsoku §19.2.1.17).
  kinsoku : CT_Kinsoku?
  /// <defaultTextStyle>? (a:CT_TextListStyle §19.2.1.8) — preserved as
  /// raw element because DrawingML owns CT_TextListStyle.
  default_text_style : @xml.Element?
  /// <modifyVerifier>? (CT_ModifyVerifier §19.2.1.19).
  modify_verifier : CT_ModifyVerifier?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Presentation::parse(
  element : @xml.Element,
) -> CT_Presentation raise SchemaViolation {
  let server_zoom = pml_attr(element, "serverZoom")
  let first_slide_num = pml_optional_int(
    element, "firstSlideNum", "CT_Presentation/@firstSlideNum",
  )
  let show_special_pls_on_title_sld = pml_optional_bool(
    element, "showSpecialPlsOnTitleSld", "CT_Presentation/@showSpecialPlsOnTitleSld",
  )
  let rtl = pml_optional_bool(element, "rtl", "CT_Presentation/@rtl")
  let remove_personal_info_on_save = pml_optional_bool(
    element, "removePersonalInfoOnSave", "CT_Presentation/@removePersonalInfoOnSave",
  )
  let compat_mode = pml_optional_bool(
    element, "compatMode", "CT_Presentation/@compatMode",
  )
  let strict_first_and_last_chars = pml_optional_bool(
    element, "strictFirstAndLastChars", "CT_Presentation/@strictFirstAndLastChars",
  )
  let embed_true_type_fonts = pml_optional_bool(
    element, "embedTrueTypeFonts", "CT_Presentation/@embedTrueTypeFonts",
  )
  let save_subset_fonts = pml_optional_bool(
    element, "saveSubsetFonts", "CT_Presentation/@saveSubsetFonts",
  )
  let auto_compress_pictures = pml_optional_bool(
    element, "autoCompressPictures", "CT_Presentation/@autoCompressPictures",
  )
  let bookmark_id_seed = match pml_attr(element, "bookmarkIdSeed") {
    Some(v) => Some(ST_BookmarkIdSeed::parse(v))
    None => None
  }
  let conformance = pml_attr(element, "conformance")
  let sld_master_id_lst = match pml_first_child(element, "sldMasterIdLst") {
    Some(c) => Some(CT_SlideMasterIdList::parse(c))
    None => None
  }
  let notes_master_id_lst = match pml_first_child(element, "notesMasterIdLst") {
    Some(c) => Some(CT_NotesMasterIdList::parse(c))
    None => None
  }
  let handout_master_id_lst = match
    pml_first_child(element, "handoutMasterIdLst") {
    Some(c) => Some(CT_HandoutMasterIdList::parse(c))
    None => None
  }
  let sld_id_lst = match pml_first_child(element, "sldIdLst") {
    Some(c) => Some(CT_SlideIdList::parse(c))
    None => None
  }
  let sld_sz = match pml_first_child(element, "sldSz") {
    Some(c) => Some(CT_SlideSize::parse(c))
    None => None
  }
  let notes_sz = match pml_first_child(element, "notesSz") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_Presentation/<notesSz>",
        value="",
        reason="required child missing",
      )
  }
  let smart_tags = match pml_first_child(element, "smartTags") {
    Some(c) => Some(CT_SmartTags::parse(c))
    None => None
  }
  let embedded_font_lst = match pml_first_child(element, "embeddedFontLst") {
    Some(c) => Some(CT_EmbeddedFontList::parse(c))
    None => None
  }
  let cust_show_lst = match pml_first_child(element, "custShowLst") {
    Some(c) => Some(CT_CustomShowList::parse(c))
    None => None
  }
  let photo_album = match pml_first_child(element, "photoAlbum") {
    Some(c) => Some(CT_PhotoAlbum::parse(c))
    None => None
  }
  let cust_data_lst = match pml_first_child(element, "custDataLst") {
    Some(c) => Some(CT_CustomerDataList::parse(c))
    None => None
  }
  let kinsoku = match pml_first_child(element, "kinsoku") {
    Some(c) => Some(CT_Kinsoku::parse(c))
    None => None
  }
  let default_text_style = pml_first_child(element, "defaultTextStyle")
  let modify_verifier = match pml_first_child(element, "modifyVerifier") {
    Some(c) => Some(CT_ModifyVerifier::parse(c))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  {
    element,
    server_zoom,
    first_slide_num,
    show_special_pls_on_title_sld,
    rtl,
    remove_personal_info_on_save,
    compat_mode,
    strict_first_and_last_chars,
    embed_true_type_fonts,
    save_subset_fonts,
    auto_compress_pictures,
    bookmark_id_seed,
    conformance,
    sld_master_id_lst,
    notes_master_id_lst,
    handout_master_id_lst,
    sld_id_lst,
    sld_sz,
    notes_sz,
    smart_tags,
    embedded_font_lst,
    cust_show_lst,
    photo_album,
    cust_data_lst,
    kinsoku,
    default_text_style,
    modify_verifier,
    ext_lst,
  }
}

///|
pub fn CT_Presentation::new(element : @xml.Element) -> CT_Presentation {
  CT_Presentation::parse(element) catch {
    _ =>
      {
        element,
        server_zoom: None,
        first_slide_num: None,
        show_special_pls_on_title_sld: None,
        rtl: None,
        remove_personal_info_on_save: None,
        compat_mode: None,
        strict_first_and_last_chars: None,
        embed_true_type_fonts: None,
        save_subset_fonts: None,
        auto_compress_pictures: None,
        bookmark_id_seed: None,
        conformance: None,
        sld_master_id_lst: None,
        notes_master_id_lst: None,
        handout_master_id_lst: None,
        sld_id_lst: None,
        sld_sz: None,
        notes_sz: element,
        smart_tags: None,
        embedded_font_lst: None,
        cust_show_lst: None,
        photo_album: None,
        cust_data_lst: None,
        kinsoku: None,
        default_text_style: None,
        modify_verifier: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_Presentation::to_element(self : CT_Presentation) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HtmlPublishProperties — Part 1 §A.3 (pml.xsd
/// annex). HTML-publish slide-list configuration. Required
/// EG_SlideListChoice (xsd:group) xsd:choice — typed via
/// PmlSlideListChoice (one of `<sldAll>` / `<sldRg>` / `<custShow>`)
/// — plus optional `<extLst>`. Attributes: `@showSpeakerNotes`
/// (xsd:boolean, default `true`), `@target` (xsd:string, optional),
/// `@title` (xsd:string, default `""`), required `@r:id`
/// (ST_RelationshipId).
pub(all) struct CT_HtmlPublishProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @showSpeakerNotes (xsd:boolean, default `true`).
  show_speaker_notes : Bool?
  /// @target (xsd:string) — optional URI for the HTML publish target.
  target : String?
  /// @title (xsd:string, default `""`).
  title : String?
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
  /// PmlSlideListChoice xsd:choice — required. Each variant stores the
  /// raw element to preserve `<sldAll>` (CT_Empty), `<sldRg>`
  /// (CT_IndexRange) or `<custShow>` (CT_CustomShowId).
  slide_list_choice : PmlSlideListChoice
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
/// PmlSlideListChoice — typed encoding of the XSD model group
/// EG_SlideListChoice used by CT_HtmlPublishProperties and
/// CT_ShowProperties. Mirrors the schema's xsd:choice between
/// `<sldAll>` (CT_Empty), `<sldRg>` (CT_IndexRange), and `<custShow>`
/// (CT_CustomShowId). The `Pml` prefix avoids collision with the
/// legacy `EG_SlideListChoice` element-only wrapper that exposes
/// `child_names()` for compatibility callers.
pub(all) enum PmlSlideListChoice {
  /// `<sldAll>` (CT_Empty §A.3).
  PmlSlideListAll(CT_Empty)
  /// `<sldRg>` (CT_IndexRange §19.3.1.34).
  PmlSlideListRange(CT_IndexRange)
  /// `<custShow>` (CT_CustomShowId §19.3.1.16).
  PmlSlideListCustomShow(CT_CustomShowId)
} derive(Eq, Debug)

///|
pub fn CT_HtmlPublishProperties::parse(
  element : @xml.Element,
) -> CT_HtmlPublishProperties raise SchemaViolation {
  let show_speaker_notes = pml_optional_bool(
    element, "showSpeakerNotes", "CT_HtmlPublishProperties/@showSpeakerNotes",
  )
  let target = pml_attr(element, "target")
  let title = pml_attr(element, "title")
  let r_id = pml_require_attr(element, "id", "CT_HtmlPublishProperties/@r:id")
  let slide_list_choice = match
    pml_first_choice(element, ["sldAll", "sldRg", "custShow"]) {
    Some((c, "sldAll")) => PmlSlideListAll(CT_Empty::new(c))
    Some((c, "sldRg")) => PmlSlideListRange(CT_IndexRange::parse(c))
    Some((c, "custShow")) => PmlSlideListCustomShow(CT_CustomShowId::parse(c))
    _ =>
      raise SchemaViolation(
        type_name="CT_HtmlPublishProperties/PmlSlideListChoice",
        value="",
        reason="required xsd:choice missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  {
    element,
    show_speaker_notes,
    target,
    title,
    r_id,
    slide_list_choice,
    ext_lst,
  }
}

///|
pub fn CT_HtmlPublishProperties::new(
  element : @xml.Element,
) -> CT_HtmlPublishProperties {
  CT_HtmlPublishProperties::parse(element) catch {
    _ =>
      {
        element,
        show_speaker_notes: None,
        target: None,
        title: None,
        r_id: "",
        slide_list_choice: PmlSlideListAll(CT_Empty::new(element)),
        ext_lst: None,
      }
  }
}

///|
pub fn CT_HtmlPublishProperties::to_element(
  self : CT_HtmlPublishProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PrintProperties — Part 1 §19.2.1.28 prnPr.
/// Optional `<extLst>` plus five optional print-configuration
/// attributes: `@prnWhat` (ST_PrintWhat §19.7.12, default `"slides"`),
/// `@clrMode` (ST_PrintColorMode §19.7.11, default `"clr"`),
/// `@hiddenSlides` / `@scaleToFitPaper` / `@frameSlides` (xsd:boolean,
/// each default `false`).
pub(all) struct CT_PrintProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @prnWhat (ST_PrintWhat §19.7.12, default `PrintSlides`).
  prn_what : ST_PrintWhat?
  /// @clrMode (ST_PrintColorMode §19.7.11, default `PrintClr`).
  clr_mode : ST_PrintColorMode?
  /// @hiddenSlides (xsd:boolean, default `false`).
  hidden_slides : Bool?
  /// @scaleToFitPaper (xsd:boolean, default `false`).
  scale_to_fit_paper : Bool?
  /// @frameSlides (xsd:boolean, default `false`).
  frame_slides : Bool?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PrintProperties::parse(
  element : @xml.Element,
) -> CT_PrintProperties raise SchemaViolation {
  let prn_what = match pml_attr(element, "prnWhat") {
    Some(v) => Some(ST_PrintWhat::parse(v))
    None => None
  }
  let clr_mode = match pml_attr(element, "clrMode") {
    Some(v) => Some(ST_PrintColorMode::parse(v))
    None => None
  }
  let hidden_slides = pml_optional_bool(
    element, "hiddenSlides", "CT_PrintProperties/@hiddenSlides",
  )
  let scale_to_fit_paper = pml_optional_bool(
    element, "scaleToFitPaper", "CT_PrintProperties/@scaleToFitPaper",
  )
  let frame_slides = pml_optional_bool(
    element, "frameSlides", "CT_PrintProperties/@frameSlides",
  )
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  {
    element,
    prn_what,
    clr_mode,
    hidden_slides,
    scale_to_fit_paper,
    frame_slides,
    ext_lst,
  }
}

///|
pub fn CT_PrintProperties::new(element : @xml.Element) -> CT_PrintProperties {
  CT_PrintProperties::parse(element) catch {
    _ =>
      {
        element,
        prn_what: None,
        clr_mode: None,
        hidden_slides: None,
        scale_to_fit_paper: None,
        frame_slides: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_PrintProperties::to_element(
  self : CT_PrintProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShowInfoBrowse — Part 1 §19.2.1.3 browse. Marker
/// element for the "browse" slide-show mode. Optional `@showScrollbar`
/// (xsd:boolean, default `true`).
pub(all) struct CT_ShowInfoBrowse {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @showScrollbar (xsd:boolean, default `true`); `None` ⇔ absent.
  show_scrollbar : Bool?
} derive(Eq, Debug)

///|
pub fn CT_ShowInfoBrowse::parse(
  element : @xml.Element,
) -> CT_ShowInfoBrowse raise SchemaViolation {
  let show_scrollbar = pml_optional_bool(
    element, "showScrollbar", "CT_ShowInfoBrowse/@showScrollbar",
  )
  { element, show_scrollbar }
}

///|
pub fn CT_ShowInfoBrowse::new(element : @xml.Element) -> CT_ShowInfoBrowse {
  CT_ShowInfoBrowse::parse(element) catch {
    _ => { element, show_scrollbar: None }
  }
}

///|
pub fn CT_ShowInfoBrowse::to_element(self : CT_ShowInfoBrowse) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShowInfoKiosk — Part 1 §19.2.1.18 kiosk. Marker
/// element for the "kiosk" slide-show mode. Optional `@restart`
/// (xsd:unsignedInt, default `300000` ms) — restart timeout after the
/// show ends.
pub(all) struct CT_ShowInfoKiosk {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @restart (xsd:unsignedInt, default 300000); `None` ⇔ absent.
  restart : UInt?
} derive(Eq, Debug)

///|
pub fn CT_ShowInfoKiosk::parse(
  element : @xml.Element,
) -> CT_ShowInfoKiosk raise SchemaViolation {
  let restart = pml_optional_unsigned_int(
    element, "restart", "CT_ShowInfoKiosk/@restart",
  )
  { element, restart }
}

///|
pub fn CT_ShowInfoKiosk::new(element : @xml.Element) -> CT_ShowInfoKiosk {
  CT_ShowInfoKiosk::parse(element) catch {
    _ => { element, restart: None }
  }
}

///|
pub fn CT_ShowInfoKiosk::to_element(self : CT_ShowInfoKiosk) -> @xml.Element {
  self.element
}

///|
/// PmlShowType — typed encoding of the XSD model group EG_ShowType used
/// by CT_ShowProperties. Mirrors the schema's xsd:choice between
/// `<present>` (CT_Empty), `<browse>` (CT_ShowInfoBrowse) and
/// `<kiosk>` (CT_ShowInfoKiosk). The `Pml` prefix avoids collision
/// with the legacy `EG_ShowType` element-only wrapper that exposes
/// `child_names()`.
pub(all) enum PmlShowType {
  /// `<present>` (CT_Empty §19.2.1.25).
  PmlShowTypePresent(CT_Empty)
  /// `<browse>` (CT_ShowInfoBrowse §19.2.1.3).
  PmlShowTypeBrowse(CT_ShowInfoBrowse)
  /// `<kiosk>` (CT_ShowInfoKiosk §19.2.1.18).
  PmlShowTypeKiosk(CT_ShowInfoKiosk)
} derive(Eq, Debug)

///|
/// XSD complex type CT_ShowProperties — Part 1 §19.2.1.30 showPr.
/// Slide-show presentation configuration. Optional sequence: an
/// optional PmlShowType (`<present>` / `<browse>` / `<kiosk>`), an
/// optional PmlSlideListChoice (`<sldAll>` / `<sldRg>` / `<custShow>`),
/// optional `<penClr>` (a:CT_Color, raw — DrawingML), optional
/// `<extLst>` (CT_ExtensionList). Optional attributes: `@loop`,
/// `@showNarration` (default `false`), `@showAnimation`, `@useTimings`
/// (default `true`).
pub(all) struct CT_ShowProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @loop (xsd:boolean, default `false`).
  loop_ : Bool?
  /// @showNarration (xsd:boolean, default `false`).
  show_narration : Bool?
  /// @showAnimation (xsd:boolean, default `true`).
  show_animation : Bool?
  /// @useTimings (xsd:boolean, default `true`).
  use_timings : Bool?
  /// PmlShowType? (xsd:choice — optional).
  show_type : PmlShowType?
  /// PmlSlideListChoice? (xsd:choice — optional).
  slide_list_choice : PmlSlideListChoice?
  /// <penClr>? (a:CT_Color §19.2.1.23) — raw element preserved because
  /// CT_Color is owned by DrawingML.
  pen_clr : @xml.Element?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ShowProperties::parse(
  element : @xml.Element,
) -> CT_ShowProperties raise SchemaViolation {
  let loop_ = pml_optional_bool(element, "loop", "CT_ShowProperties/@loop")
  let show_narration = pml_optional_bool(
    element, "showNarration", "CT_ShowProperties/@showNarration",
  )
  let show_animation = pml_optional_bool(
    element, "showAnimation", "CT_ShowProperties/@showAnimation",
  )
  let use_timings = pml_optional_bool(
    element, "useTimings", "CT_ShowProperties/@useTimings",
  )
  let show_type = match
    pml_first_choice(element, ["present", "browse", "kiosk"]) {
    Some((c, "present")) => Some(PmlShowTypePresent(CT_Empty::new(c)))
    Some((c, "browse")) => Some(PmlShowTypeBrowse(CT_ShowInfoBrowse::parse(c)))
    Some((c, "kiosk")) => Some(PmlShowTypeKiosk(CT_ShowInfoKiosk::parse(c)))
    _ => None
  }
  let slide_list_choice = match
    pml_first_choice(element, ["sldAll", "sldRg", "custShow"]) {
    Some((c, "sldAll")) => Some(PmlSlideListAll(CT_Empty::new(c)))
    Some((c, "sldRg")) => Some(PmlSlideListRange(CT_IndexRange::parse(c)))
    Some((c, "custShow")) =>
      Some(PmlSlideListCustomShow(CT_CustomShowId::parse(c)))
    _ => None
  }
  let pen_clr = pml_first_child(element, "penClr")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  {
    element,
    loop_,
    show_narration,
    show_animation,
    use_timings,
    show_type,
    slide_list_choice,
    pen_clr,
    ext_lst,
  }
}

///|
pub fn CT_ShowProperties::new(element : @xml.Element) -> CT_ShowProperties {
  CT_ShowProperties::parse(element) catch {
    _ =>
      {
        element,
        loop_: None,
        show_narration: None,
        show_animation: None,
        use_timings: None,
        show_type: None,
        slide_list_choice: None,
        pen_clr: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_ShowProperties::to_element(self : CT_ShowProperties) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresentationProperties — Part 1 §19.2.1.27
/// presentationPr. Root of the presentationPr part. Optional children:
/// `<prnPr>` (CT_PrintProperties §19.2.1.28), `<showPr>`
/// (CT_ShowProperties §19.2.1.30), `<clrMru>` (a:CT_ColorMRU §19.2.1.4
/// — DrawingML, raw element), `<extLst>` (CT_ExtensionList).
pub(all) struct CT_PresentationProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <prnPr>? (CT_PrintProperties §19.2.1.28).
  prn_pr : CT_PrintProperties?
  /// <showPr>? (CT_ShowProperties §19.2.1.30).
  show_pr : CT_ShowProperties?
  /// <clrMru>? (a:CT_ColorMRU §19.2.1.4) — raw element preserved
  /// because DrawingML owns CT_ColorMRU.
  clr_mru : @xml.Element?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PresentationProperties::parse(
  element : @xml.Element,
) -> CT_PresentationProperties raise SchemaViolation {
  let prn_pr = match pml_first_child(element, "prnPr") {
    Some(c) => Some(CT_PrintProperties::parse(c))
    None => None
  }
  let show_pr = match pml_first_child(element, "showPr") {
    Some(c) => Some(CT_ShowProperties::parse(c))
    None => None
  }
  let clr_mru = pml_first_child(element, "clrMru")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, prn_pr, show_pr, clr_mru, ext_lst }
}

///|
pub fn CT_PresentationProperties::new(
  element : @xml.Element,
) -> CT_PresentationProperties {
  CT_PresentationProperties::parse(element) catch {
    _ => { element, prn_pr: None, show_pr: None, clr_mru: None, ext_lst: None }
  }
}

///|
pub fn CT_PresentationProperties::to_element(
  self : CT_PresentationProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HeaderFooter from pml.xsd (§19).
pub(all) struct CT_HeaderFooter {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HeaderFooter::new(element : @xml.Element) -> CT_HeaderFooter {
  { element, }
}

///|
pub fn CT_HeaderFooter::parse(element : @xml.Element) -> CT_HeaderFooter {
  CT_HeaderFooter::new(element)
}

///|
pub fn CT_HeaderFooter::to_element(self : CT_HeaderFooter) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ApplicationNonVisualDrawingProps from pml.xsd (§19).
pub(all) struct CT_ApplicationNonVisualDrawingProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ApplicationNonVisualDrawingProps::new(
  element : @xml.Element,
) -> CT_ApplicationNonVisualDrawingProps {
  { element, }
}

///|
pub fn CT_ApplicationNonVisualDrawingProps::parse(
  element : @xml.Element,
) -> CT_ApplicationNonVisualDrawingProps {
  CT_ApplicationNonVisualDrawingProps::new(element)
}

///|
pub fn CT_ApplicationNonVisualDrawingProps::to_element(
  self : CT_ApplicationNonVisualDrawingProps,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShapeNonVisual from pml.xsd (§19).
pub(all) struct CT_ShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeNonVisual::new(element : @xml.Element) -> CT_ShapeNonVisual {
  { element, }
}

///|
pub fn CT_ShapeNonVisual::parse(element : @xml.Element) -> CT_ShapeNonVisual {
  CT_ShapeNonVisual::new(element)
}

///|
pub fn CT_ShapeNonVisual::to_element(self : CT_ShapeNonVisual) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Shape: Schema pml.xsd complex type `CT_Shape` has
/// attribute `useBgFill` and child elements `nvSpPr`, `spPr`, `style`,
/// `txBody`, and `extLst`; CT_Shape, CT_Shape::new, CT_Shape::parse, and
/// CT_Shape::to_element own that slide shape payload.
pub(all) struct CT_Shape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape {
  { element, }
}

///|
pub fn CT_Shape::parse(element : @xml.Element) -> CT_Shape {
  CT_Shape::new(element)
}

///|
pub fn CT_Shape::to_element(self : CT_Shape) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ConnectorNonVisual from pml.xsd (§19).
pub(all) struct CT_ConnectorNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectorNonVisual::new(
  element : @xml.Element,
) -> CT_ConnectorNonVisual {
  { element, }
}

///|
pub fn CT_ConnectorNonVisual::parse(
  element : @xml.Element,
) -> CT_ConnectorNonVisual {
  CT_ConnectorNonVisual::new(element)
}

///|
pub fn CT_ConnectorNonVisual::to_element(
  self : CT_ConnectorNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Connector from pml.xsd (§19).
pub(all) struct CT_Connector {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Connector::new(element : @xml.Element) -> CT_Connector {
  { element, }
}

///|
pub fn CT_Connector::parse(element : @xml.Element) -> CT_Connector {
  CT_Connector::new(element)
}

///|
pub fn CT_Connector::to_element(self : CT_Connector) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PictureNonVisual from pml.xsd (§19).
pub(all) struct CT_PictureNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PictureNonVisual::new(element : @xml.Element) -> CT_PictureNonVisual {
  { element, }
}

///|
pub fn CT_PictureNonVisual::parse(
  element : @xml.Element,
) -> CT_PictureNonVisual {
  CT_PictureNonVisual::new(element)
}

///|
pub fn CT_PictureNonVisual::to_element(
  self : CT_PictureNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Picture from pml.xsd (§19).
pub(all) struct CT_Picture {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Picture::new(element : @xml.Element) -> CT_Picture {
  { element, }
}

///|
pub fn CT_Picture::parse(element : @xml.Element) -> CT_Picture {
  CT_Picture::new(element)
}

///|
pub fn CT_Picture::to_element(self : CT_Picture) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicalObjectFrameNonVisual from pml.xsd (§19).
pub(all) struct CT_GraphicalObjectFrameNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectFrameNonVisual::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameNonVisual {
  { element, }
}

///|
pub fn CT_GraphicalObjectFrameNonVisual::parse(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameNonVisual {
  CT_GraphicalObjectFrameNonVisual::new(element)
}

///|
pub fn CT_GraphicalObjectFrameNonVisual::to_element(
  self : CT_GraphicalObjectFrameNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicalObjectFrame from pml.xsd (§19).
pub(all) struct CT_GraphicalObjectFrame {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectFrame::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrame {
  { element, }
}

///|
pub fn CT_GraphicalObjectFrame::parse(
  element : @xml.Element,
) -> CT_GraphicalObjectFrame {
  CT_GraphicalObjectFrame::new(element)
}

///|
pub fn CT_GraphicalObjectFrame::to_element(
  self : CT_GraphicalObjectFrame,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GroupShapeNonVisual from pml.xsd (§19).
pub(all) struct CT_GroupShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual {
  { element, }
}

///|
pub fn CT_GroupShapeNonVisual::parse(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual {
  CT_GroupShapeNonVisual::new(element)
}

///|
pub fn CT_GroupShapeNonVisual::to_element(
  self : CT_GroupShapeNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GroupShape from pml.xsd (§19).
pub(all) struct CT_GroupShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupShape::new(element : @xml.Element) -> CT_GroupShape {
  { element, }
}

///|
pub fn CT_GroupShape::parse(element : @xml.Element) -> CT_GroupShape {
  CT_GroupShape::new(element)
}

///|
pub fn CT_GroupShape::to_element(self : CT_GroupShape) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Rel: Schema pml.xsd complex type `CT_Rel` references
/// the `r:id` relationship attribute group; CT_Rel, CT_Rel::new,
/// CT_Rel::parse, and CT_Rel::to_element own that relationship payload.
/// The package also cites Schema vml-presentationDrawing.xsd complex type
/// `CT_Rel` with attribute `id`, represented by VmlPresentationDrawing_CT_Rel
/// in the VML presentation drawing domain file.
pub(all) struct CT_Rel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rel::new(element : @xml.Element) -> CT_Rel {
  { element, }
}

///|
pub fn CT_Rel::parse(element : @xml.Element) -> CT_Rel {
  CT_Rel::new(element)
}

///|
pub fn CT_Rel::to_element(self : CT_Rel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BackgroundProperties from pml.xsd (§19).
pub(all) struct CT_BackgroundProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BackgroundProperties::new(
  element : @xml.Element,
) -> CT_BackgroundProperties {
  { element, }
}

///|
pub fn CT_BackgroundProperties::parse(
  element : @xml.Element,
) -> CT_BackgroundProperties {
  CT_BackgroundProperties::new(element)
}

///|
pub fn CT_BackgroundProperties::to_element(
  self : CT_BackgroundProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Background from pml.xsd (§19).
pub(all) struct CT_Background {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Background::new(element : @xml.Element) -> CT_Background {
  { element, }
}

///|
pub fn CT_Background::parse(element : @xml.Element) -> CT_Background {
  CT_Background::new(element)
}

///|
pub fn CT_Background::to_element(self : CT_Background) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonSlideData from pml.xsd (§19).
pub(all) struct CT_CommonSlideData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommonSlideData::new(element : @xml.Element) -> CT_CommonSlideData {
  { element, }
}

///|
pub fn CT_CommonSlideData::parse(element : @xml.Element) -> CT_CommonSlideData {
  CT_CommonSlideData::new(element)
}

///|
pub fn CT_CommonSlideData::to_element(
  self : CT_CommonSlideData,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Slide from pml.xsd (§19).
pub(all) struct CT_Slide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Slide::new(element : @xml.Element) -> CT_Slide {
  { element, }
}

///|
pub fn CT_Slide::parse(element : @xml.Element) -> CT_Slide {
  CT_Slide::new(element)
}

///|
pub fn CT_Slide::to_element(self : CT_Slide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayout from pml.xsd (§19).
pub(all) struct CT_SlideLayout {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideLayout::new(element : @xml.Element) -> CT_SlideLayout {
  { element, }
}

///|
pub fn CT_SlideLayout::parse(element : @xml.Element) -> CT_SlideLayout {
  CT_SlideLayout::new(element)
}

///|
pub fn CT_SlideLayout::to_element(self : CT_SlideLayout) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterTextStyles from pml.xsd (§19).
pub(all) struct CT_SlideMasterTextStyles {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterTextStyles::new(
  element : @xml.Element,
) -> CT_SlideMasterTextStyles {
  { element, }
}

///|
pub fn CT_SlideMasterTextStyles::parse(
  element : @xml.Element,
) -> CT_SlideMasterTextStyles {
  CT_SlideMasterTextStyles::new(element)
}

///|
pub fn CT_SlideMasterTextStyles::to_element(
  self : CT_SlideMasterTextStyles,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayoutIdListEntry from pml.xsd (§19).
pub(all) struct CT_SlideLayoutIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideLayoutIdListEntry::new(
  element : @xml.Element,
) -> CT_SlideLayoutIdListEntry {
  { element, }
}

///|
pub fn CT_SlideLayoutIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideLayoutIdListEntry {
  CT_SlideLayoutIdListEntry::new(element)
}

///|
pub fn CT_SlideLayoutIdListEntry::to_element(
  self : CT_SlideLayoutIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayoutIdList from pml.xsd (§19).
pub(all) struct CT_SlideLayoutIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideLayoutIdList::new(
  element : @xml.Element,
) -> CT_SlideLayoutIdList {
  { element, }
}

///|
pub fn CT_SlideLayoutIdList::parse(
  element : @xml.Element,
) -> CT_SlideLayoutIdList {
  CT_SlideLayoutIdList::new(element)
}

///|
pub fn CT_SlideLayoutIdList::to_element(
  self : CT_SlideLayoutIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMaster from pml.xsd (§19).
pub(all) struct CT_SlideMaster {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideMaster::new(element : @xml.Element) -> CT_SlideMaster {
  { element, }
}

///|
pub fn CT_SlideMaster::parse(element : @xml.Element) -> CT_SlideMaster {
  CT_SlideMaster::new(element)
}

///|
pub fn CT_SlideMaster::to_element(self : CT_SlideMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMaster from pml.xsd (§19).
pub(all) struct CT_HandoutMaster {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HandoutMaster::new(element : @xml.Element) -> CT_HandoutMaster {
  { element, }
}

///|
pub fn CT_HandoutMaster::parse(element : @xml.Element) -> CT_HandoutMaster {
  CT_HandoutMaster::new(element)
}

///|
pub fn CT_HandoutMaster::to_element(self : CT_HandoutMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMaster from pml.xsd (§19).
pub(all) struct CT_NotesMaster {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesMaster::new(element : @xml.Element) -> CT_NotesMaster {
  { element, }
}

///|
pub fn CT_NotesMaster::parse(element : @xml.Element) -> CT_NotesMaster {
  CT_NotesMaster::new(element)
}

///|
pub fn CT_NotesMaster::to_element(self : CT_NotesMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesSlide from pml.xsd (§19).
pub(all) struct CT_NotesSlide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesSlide::new(element : @xml.Element) -> CT_NotesSlide {
  { element, }
}

///|
pub fn CT_NotesSlide::parse(element : @xml.Element) -> CT_NotesSlide {
  CT_NotesSlide::new(element)
}

///|
pub fn CT_NotesSlide::to_element(self : CT_NotesSlide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSyncProperties from pml.xsd (§19).
pub(all) struct CT_SlideSyncProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideSyncProperties::new(
  element : @xml.Element,
) -> CT_SlideSyncProperties {
  { element, }
}

///|
pub fn CT_SlideSyncProperties::parse(
  element : @xml.Element,
) -> CT_SlideSyncProperties {
  CT_SlideSyncProperties::new(element)
}

///|
pub fn CT_SlideSyncProperties::to_element(
  self : CT_SlideSyncProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StringTag from pml.xsd (§19).
pub(all) struct CT_StringTag {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StringTag::new(element : @xml.Element) -> CT_StringTag {
  { element, }
}

///|
pub fn CT_StringTag::parse(element : @xml.Element) -> CT_StringTag {
  CT_StringTag::new(element)
}

///|
pub fn CT_StringTag::to_element(self : CT_StringTag) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TagList from pml.xsd (§19).
pub(all) struct CT_TagList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TagList::new(element : @xml.Element) -> CT_TagList {
  { element, }
}

///|
pub fn CT_TagList::parse(element : @xml.Element) -> CT_TagList {
  CT_TagList::new(element)
}

///|
pub fn CT_TagList::to_element(self : CT_TagList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NormalViewPortion from pml.xsd (§19).
pub(all) struct CT_NormalViewPortion {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NormalViewPortion::new(
  element : @xml.Element,
) -> CT_NormalViewPortion {
  { element, }
}

///|
pub fn CT_NormalViewPortion::parse(
  element : @xml.Element,
) -> CT_NormalViewPortion {
  CT_NormalViewPortion::new(element)
}

///|
pub fn CT_NormalViewPortion::to_element(
  self : CT_NormalViewPortion,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NormalViewProperties from pml.xsd (§19).
pub(all) struct CT_NormalViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NormalViewProperties::new(
  element : @xml.Element,
) -> CT_NormalViewProperties {
  { element, }
}

///|
pub fn CT_NormalViewProperties::parse(
  element : @xml.Element,
) -> CT_NormalViewProperties {
  CT_NormalViewProperties::new(element)
}

///|
pub fn CT_NormalViewProperties::to_element(
  self : CT_NormalViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonViewProperties from pml.xsd (§19).
pub(all) struct CT_CommonViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommonViewProperties::new(
  element : @xml.Element,
) -> CT_CommonViewProperties {
  { element, }
}

///|
pub fn CT_CommonViewProperties::parse(
  element : @xml.Element,
) -> CT_CommonViewProperties {
  CT_CommonViewProperties::new(element)
}

///|
pub fn CT_CommonViewProperties::to_element(
  self : CT_CommonViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesTextViewProperties from pml.xsd (§19).
pub(all) struct CT_NotesTextViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesTextViewProperties::new(
  element : @xml.Element,
) -> CT_NotesTextViewProperties {
  { element, }
}

///|
pub fn CT_NotesTextViewProperties::parse(
  element : @xml.Element,
) -> CT_NotesTextViewProperties {
  CT_NotesTextViewProperties::new(element)
}

///|
pub fn CT_NotesTextViewProperties::to_element(
  self : CT_NotesTextViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewSlideEntry from pml.xsd (§19).
pub(all) struct CT_OutlineViewSlideEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewSlideEntry::new(
  element : @xml.Element,
) -> CT_OutlineViewSlideEntry {
  { element, }
}

///|
pub fn CT_OutlineViewSlideEntry::parse(
  element : @xml.Element,
) -> CT_OutlineViewSlideEntry {
  CT_OutlineViewSlideEntry::new(element)
}

///|
pub fn CT_OutlineViewSlideEntry::to_element(
  self : CT_OutlineViewSlideEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewSlideList from pml.xsd (§19).
pub(all) struct CT_OutlineViewSlideList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewSlideList::new(
  element : @xml.Element,
) -> CT_OutlineViewSlideList {
  { element, }
}

///|
pub fn CT_OutlineViewSlideList::parse(
  element : @xml.Element,
) -> CT_OutlineViewSlideList {
  CT_OutlineViewSlideList::new(element)
}

///|
pub fn CT_OutlineViewSlideList::to_element(
  self : CT_OutlineViewSlideList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewProperties from pml.xsd (§19).
pub(all) struct CT_OutlineViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewProperties::new(
  element : @xml.Element,
) -> CT_OutlineViewProperties {
  { element, }
}

///|
pub fn CT_OutlineViewProperties::parse(
  element : @xml.Element,
) -> CT_OutlineViewProperties {
  CT_OutlineViewProperties::new(element)
}

///|
pub fn CT_OutlineViewProperties::to_element(
  self : CT_OutlineViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSorterViewProperties from pml.xsd (§19).
pub(all) struct CT_SlideSorterViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideSorterViewProperties::new(
  element : @xml.Element,
) -> CT_SlideSorterViewProperties {
  { element, }
}

///|
pub fn CT_SlideSorterViewProperties::parse(
  element : @xml.Element,
) -> CT_SlideSorterViewProperties {
  CT_SlideSorterViewProperties::new(element)
}

///|
pub fn CT_SlideSorterViewProperties::to_element(
  self : CT_SlideSorterViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Guide from pml.xsd (§19).
pub(all) struct CT_Guide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Guide::new(element : @xml.Element) -> CT_Guide {
  { element, }
}

///|
pub fn CT_Guide::parse(element : @xml.Element) -> CT_Guide {
  CT_Guide::new(element)
}

///|
pub fn CT_Guide::to_element(self : CT_Guide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GuideList from pml.xsd (§19).
pub(all) struct CT_GuideList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GuideList::new(element : @xml.Element) -> CT_GuideList {
  { element, }
}

///|
pub fn CT_GuideList::parse(element : @xml.Element) -> CT_GuideList {
  CT_GuideList::new(element)
}

///|
pub fn CT_GuideList::to_element(self : CT_GuideList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonSlideViewProperties from pml.xsd (§19).
pub(all) struct CT_CommonSlideViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommonSlideViewProperties::new(
  element : @xml.Element,
) -> CT_CommonSlideViewProperties {
  { element, }
}

///|
pub fn CT_CommonSlideViewProperties::parse(
  element : @xml.Element,
) -> CT_CommonSlideViewProperties {
  CT_CommonSlideViewProperties::new(element)
}

///|
pub fn CT_CommonSlideViewProperties::to_element(
  self : CT_CommonSlideViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideViewProperties from pml.xsd (§19).
pub(all) struct CT_SlideViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideViewProperties::new(
  element : @xml.Element,
) -> CT_SlideViewProperties {
  { element, }
}

///|
pub fn CT_SlideViewProperties::parse(
  element : @xml.Element,
) -> CT_SlideViewProperties {
  CT_SlideViewProperties::new(element)
}

///|
pub fn CT_SlideViewProperties::to_element(
  self : CT_SlideViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesViewProperties from pml.xsd (§19).
pub(all) struct CT_NotesViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesViewProperties::new(
  element : @xml.Element,
) -> CT_NotesViewProperties {
  { element, }
}

///|
pub fn CT_NotesViewProperties::parse(
  element : @xml.Element,
) -> CT_NotesViewProperties {
  CT_NotesViewProperties::new(element)
}

///|
pub fn CT_NotesViewProperties::to_element(
  self : CT_NotesViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ViewProperties from pml.xsd (§19).
pub(all) struct CT_ViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ViewProperties::new(element : @xml.Element) -> CT_ViewProperties {
  { element, }
}

///|
pub fn CT_ViewProperties::parse(element : @xml.Element) -> CT_ViewProperties {
  CT_ViewProperties::new(element)
}

///|
pub fn CT_ViewProperties::to_element(self : CT_ViewProperties) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WebProperties from pml.xsd (Part 4 §16).
pub(all) struct CT_WebProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebProperties::new(element : @xml.Element) -> CT_WebProperties {
  { element, }
}

///|
pub fn CT_WebProperties::parse(element : @xml.Element) -> CT_WebProperties {
  CT_WebProperties::new(element)
}

///|
pub fn CT_WebProperties::to_element(self : CT_WebProperties) -> @xml.Element {
  self.element
}

///|
/// XSD attribute group AG_TLBuild from pml.xsd (§19).
pub(all) struct AG_TLBuild {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_TLBuild::new(element : @xml.Element) -> AG_TLBuild {
  { element, }
}

///|
pub fn AG_TLBuild::attribute_names(self : AG_TLBuild) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_TLBuild::has_attribute(
  self : AG_TLBuild,
  local_name : String,
) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// XSD attribute group AG_Ole from pml.xsd (§19).
pub(all) struct AG_Ole {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Ole::new(element : @xml.Element) -> AG_Ole {
  { element, }
}

///|
pub fn AG_Ole::attribute_names(self : AG_Ole) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_Ole::has_attribute(self : AG_Ole, local_name : String) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// XSD attribute group AG_ChildSlide from pml.xsd (§19).
pub(all) struct AG_ChildSlide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_ChildSlide::new(element : @xml.Element) -> AG_ChildSlide {
  { element, }
}

///|
pub fn AG_ChildSlide::attribute_names(self : AG_ChildSlide) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_ChildSlide::has_attribute(
  self : AG_ChildSlide,
  local_name : String,
) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// XSD model group EG_SlideListChoice from pml.xsd (§19).
pub(all) struct EG_SlideListChoice {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_SlideListChoice::new(element : @xml.Element) -> EG_SlideListChoice {
  { element, }
}

///|
pub fn EG_SlideListChoice::child_names(
  self : EG_SlideListChoice,
) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_ExtensionList from pml.xsd (§19).
pub(all) struct EG_ExtensionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ExtensionList::new(element : @xml.Element) -> EG_ExtensionList {
  { element, }
}

///|
pub fn EG_ExtensionList::child_names(self : EG_ExtensionList) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_ShowType from pml.xsd (§19).
pub(all) struct EG_ShowType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ShowType::new(element : @xml.Element) -> EG_ShowType {
  { element, }
}

///|
pub fn EG_ShowType::child_names(self : EG_ShowType) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_TopLevelSlide from pml.xsd (§19).
pub(all) struct EG_TopLevelSlide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TopLevelSlide::new(element : @xml.Element) -> EG_TopLevelSlide {
  { element, }
}

///|
pub fn EG_TopLevelSlide::child_names(self : EG_TopLevelSlide) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_ChildSlide from pml.xsd (§19).
pub(all) struct EG_ChildSlide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ChildSlide::new(element : @xml.Element) -> EG_ChildSlide {
  { element, }
}

///|
pub fn EG_ChildSlide::child_names(self : EG_ChildSlide) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_Background from pml.xsd (§19).
pub(all) struct EG_Background {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_Background::new(element : @xml.Element) -> EG_Background {
  { element, }
}

///|
pub fn EG_Background::child_names(self : EG_Background) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// Construct top-level pml.xsd element cmAuthorLst as CT_CommentAuthorList (§19).
pub fn cm_author_lst(element : @xml.Element) -> CT_CommentAuthorList {
  CT_CommentAuthorList::new(element)
}

///|
/// Construct top-level pml.xsd element cmLst as CT_CommentList (§19).
pub fn cm_lst(element : @xml.Element) -> CT_CommentList {
  CT_CommentList::new(element)
}

///|
/// Construct top-level pml.xsd element oleObj as CT_OleObject (§19).
pub fn ole_obj(element : @xml.Element) -> CT_OleObject {
  CT_OleObject::new(element)
}

///|
/// Construct top-level pml.xsd element presentation as CT_Presentation (§19).
pub fn presentation(element : @xml.Element) -> CT_Presentation {
  CT_Presentation::new(element)
}

///|
/// Construct top-level pml.xsd element presentationPr as CT_PresentationProperties (§19).
pub fn presentation_pr(element : @xml.Element) -> CT_PresentationProperties {
  CT_PresentationProperties::new(element)
}

///|
/// Construct top-level pml.xsd element sld as CT_Slide (§19).
pub fn sld(element : @xml.Element) -> CT_Slide {
  CT_Slide::new(element)
}

///|
/// Construct top-level pml.xsd element sldLayout as CT_SlideLayout (§19).
pub fn sld_layout(element : @xml.Element) -> CT_SlideLayout {
  CT_SlideLayout::new(element)
}

///|
/// Construct top-level pml.xsd element sldMaster as CT_SlideMaster (§19).
pub fn sld_master(element : @xml.Element) -> CT_SlideMaster {
  CT_SlideMaster::new(element)
}

///|
/// Construct top-level pml.xsd element handoutMaster as CT_HandoutMaster (§19).
pub fn handout_master(element : @xml.Element) -> CT_HandoutMaster {
  CT_HandoutMaster::new(element)
}

///|
/// Construct top-level pml.xsd element notesMaster as CT_NotesMaster (§19).
pub fn notes_master(element : @xml.Element) -> CT_NotesMaster {
  CT_NotesMaster::new(element)
}

///|
/// Construct top-level pml.xsd element notes as CT_NotesSlide (§19).
pub fn notes(element : @xml.Element) -> CT_NotesSlide {
  CT_NotesSlide::new(element)
}

///|
/// Construct top-level pml.xsd element sldSyncPr as CT_SlideSyncProperties (§19).
pub fn sld_sync_pr(element : @xml.Element) -> CT_SlideSyncProperties {
  CT_SlideSyncProperties::new(element)
}

///|
/// Construct top-level pml.xsd element tagLst as CT_TagList (§19).
pub fn tag_lst(element : @xml.Element) -> CT_TagList {
  CT_TagList::new(element)
}

///|
/// Construct top-level pml.xsd element viewPr as CT_ViewProperties (§19).
pub fn view_pr(element : @xml.Element) -> CT_ViewProperties {
  CT_ViewProperties::new(element)
}
