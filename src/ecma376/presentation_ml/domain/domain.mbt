///|
/// PresentationML domain: presentation, slide, slideLayout, slideMaster, notesMaster, handoutMaster.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/domain"
}

///|
/// Schema pml.xsd complex type CT_Empty — Part 1 §A.3 (pml.xsd
/// annex). The schema pml.xsd definition is literally
/// `<xsd:complexType name="CT_Empty"/>`: zero attributes and zero
/// children.  CT_Empty is reused as the body of many marker
/// elements — `<p:sldAll>` (§19.2.1.32), `<p:present>` (§19.2.1.25),
/// `<p:bg>` (§19.5.10 timing), `<p:bldAsOne>` (§19.5.15),
/// `<p:sldTgt>` (§19.5.69), and the §19.5.50 preset transitions
/// (`<p:circle>`, `<p:diamond>`, `<p:dissolve>`, `<p:newsflash>`,
/// `<p:plus>`, `<p:random>`, `<p:wedge>`). The only information a
/// typed view must preserve is the element's QName so the writer
/// can round-trip the original tag regardless of which slot the
/// type occupies.
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
/// XSD complex type CT_HeaderFooter — Part 1 §19.3.1.25 hf. Slide-level
/// header/footer toggle: optional `<extLst>` (CT_ExtensionListModify
/// §19.3.1.20) plus four optional xsd:boolean attributes (`@sldNum`,
/// `@hdr`, `@ftr`, `@dt`, each default `true`).
pub(all) struct CT_HeaderFooter {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @sldNum (xsd:boolean, default `true`); `None` ⇔ absent.
  sld_num : Bool?
  /// @hdr (xsd:boolean, default `true`); `None` ⇔ absent.
  hdr : Bool?
  /// @ftr (xsd:boolean, default `true`); `None` ⇔ absent.
  ftr : Bool?
  /// @dt (xsd:boolean, default `true`); `None` ⇔ absent.
  dt : Bool?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_HeaderFooter::parse(
  element : @xml.Element,
) -> CT_HeaderFooter raise SchemaViolation {
  let sld_num = pml_optional_bool(element, "sldNum", "CT_HeaderFooter/@sldNum")
  let hdr = pml_optional_bool(element, "hdr", "CT_HeaderFooter/@hdr")
  let ftr = pml_optional_bool(element, "ftr", "CT_HeaderFooter/@ftr")
  let dt = pml_optional_bool(element, "dt", "CT_HeaderFooter/@dt")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, sld_num, hdr, ftr, dt, ext_lst }
}

///|
pub fn CT_HeaderFooter::new(element : @xml.Element) -> CT_HeaderFooter {
  CT_HeaderFooter::parse(element) catch {
    _ =>
      { element, sld_num: None, hdr: None, ftr: None, dt: None, ext_lst: None }
  }
}

///|
pub fn CT_HeaderFooter::to_element(self : CT_HeaderFooter) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ApplicationNonVisualDrawingProps — Part 1
/// §19.3.1.33 nvPr. Shape application non-visual properties:
/// optional `<ph>` (CT_Placeholder §19.3.1.36); optional `a:EG_Media`
/// model-group payload (one of `audioCd`, `wavAudioFile`, `audioFile`,
/// `videoFile`, `quickTimeFile`; DrawingML-owned so kept as raw
/// element); optional `<custDataLst>` (CT_CustomerDataList §19.3.1.18);
/// optional `<extLst>` (CT_ExtensionList §19.2.1.13). Optional
/// attributes: `@isPhoto` (xsd:boolean, default `false`), `@userDrawn`
/// (xsd:boolean, default `false`).
pub(all) struct CT_ApplicationNonVisualDrawingProps {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @isPhoto (xsd:boolean, default `false`).
  is_photo : Bool?
  /// @userDrawn (xsd:boolean, default `false`).
  user_drawn : Bool?
  /// <ph>? (CT_Placeholder §19.3.1.36).
  ph : CT_Placeholder?
  /// `a:EG_Media`? — the matched raw element (audioCd / wavAudioFile /
  /// audioFile / videoFile / quickTimeFile) preserved verbatim because
  /// DrawingML owns the media types.
  media : @xml.Element?
  /// <custDataLst>? (CT_CustomerDataList §19.3.1.18).
  cust_data_lst : CT_CustomerDataList?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ApplicationNonVisualDrawingProps::parse(
  element : @xml.Element,
) -> CT_ApplicationNonVisualDrawingProps raise SchemaViolation {
  let is_photo = pml_optional_bool(
    element, "isPhoto", "CT_ApplicationNonVisualDrawingProps/@isPhoto",
  )
  let user_drawn = pml_optional_bool(
    element, "userDrawn", "CT_ApplicationNonVisualDrawingProps/@userDrawn",
  )
  let ph = match pml_first_child(element, "ph") {
    Some(c) => Some(CT_Placeholder::from_element(c))
    None => None
  }
  let media = match
    pml_first_choice(element, [
      "audioCd", "wavAudioFile", "audioFile", "videoFile", "quickTimeFile",
    ]) {
    Some((c, _)) => Some(c)
    None => None
  }
  let cust_data_lst = match pml_first_child(element, "custDataLst") {
    Some(c) => Some(CT_CustomerDataList::parse(c))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, is_photo, user_drawn, ph, media, cust_data_lst, ext_lst }
}

///|
pub fn CT_ApplicationNonVisualDrawingProps::new(
  element : @xml.Element,
) -> CT_ApplicationNonVisualDrawingProps {
  CT_ApplicationNonVisualDrawingProps::parse(element) catch {
    _ =>
      {
        element,
        is_photo: None,
        user_drawn: None,
        ph: None,
        media: None,
        cust_data_lst: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_ApplicationNonVisualDrawingProps::to_element(
  self : CT_ApplicationNonVisualDrawingProps,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShapeNonVisual — Part 1 §19.3.1.34 nvSpPr. Three
/// required children carrying shape non-visual properties: `<cNvPr>`
/// (a:CT_NonVisualDrawingProps §19.3.1.12, DrawingML-owned),
/// `<cNvSpPr>` (a:CT_NonVisualDrawingShapeProps §19.3.1.13, DrawingML),
/// `<nvPr>` (CT_ApplicationNonVisualDrawingProps §19.3.1.33).
pub(all) struct CT_ShapeNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps §19.3.1.12) — required. Kept
  /// as raw element because CT_NonVisualDrawingProps is owned by the
  /// DrawingML domain package.
  c_nv_pr : @xml.Element
  /// <cNvSpPr> (a:CT_NonVisualDrawingShapeProps §19.3.1.13) — required;
  /// raw (DrawingML).
  c_nv_sp_pr : @xml.Element
  /// <nvPr> (CT_ApplicationNonVisualDrawingProps §19.3.1.33) — required.
  nv_pr : CT_ApplicationNonVisualDrawingProps
} derive(Eq, Debug)

///|
pub fn CT_ShapeNonVisual::parse(
  element : @xml.Element,
) -> CT_ShapeNonVisual raise SchemaViolation {
  let c_nv_pr = match pml_first_child(element, "cNvPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_ShapeNonVisual/<cNvPr>",
        value="",
        reason="required child missing",
      )
  }
  let c_nv_sp_pr = match pml_first_child(element, "cNvSpPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_ShapeNonVisual/<cNvSpPr>",
        value="",
        reason="required child missing",
      )
  }
  let nv_pr = match pml_first_child(element, "nvPr") {
    Some(c) => CT_ApplicationNonVisualDrawingProps::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_ShapeNonVisual/<nvPr>",
        value="",
        reason="required child missing",
      )
  }
  { element, c_nv_pr, c_nv_sp_pr, nv_pr }
}

///|
pub fn CT_ShapeNonVisual::new(element : @xml.Element) -> CT_ShapeNonVisual {
  CT_ShapeNonVisual::parse(element) catch {
    _ =>
      {
        element,
        c_nv_pr: element,
        c_nv_sp_pr: element,
        nv_pr: CT_ApplicationNonVisualDrawingProps::new(element),
      }
  }
}

///|
pub fn CT_ShapeNonVisual::to_element(self : CT_ShapeNonVisual) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Shape — Part 1 §19.3.1.43 sp. A slide shape:
/// required `<nvSpPr>` (CT_ShapeNonVisual §19.3.1.34), required
/// `<spPr>` (a:CT_ShapeProperties §19.3.1.44, DrawingML), optional
/// `<style>` (a:CT_ShapeStyle §19.3.1.46, DrawingML), optional
/// `<txBody>` (a:CT_TextBody §21.1.2.2.2, DrawingML), optional
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20). Optional
/// `@useBgFill` (xsd:boolean, default `false`).
pub(all) struct CT_Shape {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @useBgFill (xsd:boolean, default `false`).
  use_bg_fill : Bool?
  /// <nvSpPr> (CT_ShapeNonVisual §19.3.1.34) — required.
  nv_sp_pr : CT_ShapeNonVisual
  /// <spPr> (a:CT_ShapeProperties §19.3.1.44) — required; raw element
  /// (DrawingML-owned type).
  sp_pr : @xml.Element
  /// <style>? (a:CT_ShapeStyle §19.3.1.46) — raw (DrawingML).
  style : @xml.Element?
  /// <txBody>? (a:CT_TextBody §21.1.2.2.2) — raw (DrawingML).
  tx_body : @xml.Element?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_Shape::parse(
  element : @xml.Element,
) -> CT_Shape raise SchemaViolation {
  let use_bg_fill = pml_optional_bool(
    element, "useBgFill", "CT_Shape/@useBgFill",
  )
  let nv_sp_pr = match pml_first_child(element, "nvSpPr") {
    Some(c) => CT_ShapeNonVisual::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_Shape/<nvSpPr>",
        value="",
        reason="required child missing",
      )
  }
  let sp_pr = match pml_first_child(element, "spPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_Shape/<spPr>",
        value="",
        reason="required child missing",
      )
  }
  let style = pml_first_child(element, "style")
  let tx_body = pml_first_child(element, "txBody")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, use_bg_fill, nv_sp_pr, sp_pr, style, tx_body, ext_lst }
}

///|
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape {
  CT_Shape::parse(element) catch {
    _ =>
      {
        element,
        use_bg_fill: None,
        nv_sp_pr: CT_ShapeNonVisual::new(element),
        sp_pr: element,
        style: None,
        tx_body: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_Shape::to_element(self : CT_Shape) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ConnectorNonVisual — Part 1 §19.3.1.29
/// nvCxnSpPr. Three required children: `<cNvPr>`
/// (a:CT_NonVisualDrawingProps §19.3.1.12, DrawingML), `<cNvCxnSpPr>`
/// (a:CT_NonVisualConnectorProperties §19.3.1.8, DrawingML), `<nvPr>`
/// (CT_ApplicationNonVisualDrawingProps §19.3.1.33).
pub(all) struct CT_ConnectorNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps §19.3.1.12) — required raw element.
  c_nv_pr : @xml.Element
  /// <cNvCxnSpPr> (a:CT_NonVisualConnectorProperties §19.3.1.8) —
  /// required raw element (DrawingML).
  c_nv_cxn_sp_pr : @xml.Element
  /// <nvPr> (CT_ApplicationNonVisualDrawingProps §19.3.1.33) — required.
  nv_pr : CT_ApplicationNonVisualDrawingProps
} derive(Eq, Debug)

///|
pub fn CT_ConnectorNonVisual::parse(
  element : @xml.Element,
) -> CT_ConnectorNonVisual raise SchemaViolation {
  let c_nv_pr = match pml_first_child(element, "cNvPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_ConnectorNonVisual/<cNvPr>",
        value="",
        reason="required child missing",
      )
  }
  let c_nv_cxn_sp_pr = match pml_first_child(element, "cNvCxnSpPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_ConnectorNonVisual/<cNvCxnSpPr>",
        value="",
        reason="required child missing",
      )
  }
  let nv_pr = match pml_first_child(element, "nvPr") {
    Some(c) => CT_ApplicationNonVisualDrawingProps::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_ConnectorNonVisual/<nvPr>",
        value="",
        reason="required child missing",
      )
  }
  { element, c_nv_pr, c_nv_cxn_sp_pr, nv_pr }
}

///|
pub fn CT_ConnectorNonVisual::new(
  element : @xml.Element,
) -> CT_ConnectorNonVisual {
  CT_ConnectorNonVisual::parse(element) catch {
    _ =>
      {
        element,
        c_nv_pr: element,
        c_nv_cxn_sp_pr: element,
        nv_pr: CT_ApplicationNonVisualDrawingProps::new(element),
      }
  }
}

///|
pub fn CT_ConnectorNonVisual::to_element(
  self : CT_ConnectorNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Connector — Part 1 §19.3.1.19 cxnSp. Connection
/// shape: required `<nvCxnSpPr>` (CT_ConnectorNonVisual §19.3.1.29),
/// required `<spPr>` (a:CT_ShapeProperties §19.3.1.44, DrawingML),
/// optional `<style>` (a:CT_ShapeStyle §19.3.1.46, DrawingML), optional
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20).
pub(all) struct CT_Connector {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvCxnSpPr> (CT_ConnectorNonVisual §19.3.1.29) — required.
  nv_cxn_sp_pr : CT_ConnectorNonVisual
  /// <spPr> (a:CT_ShapeProperties §19.3.1.44) — required raw element.
  sp_pr : @xml.Element
  /// <style>? (a:CT_ShapeStyle §19.3.1.46) — raw (DrawingML).
  style : @xml.Element?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_Connector::parse(
  element : @xml.Element,
) -> CT_Connector raise SchemaViolation {
  let nv_cxn_sp_pr = match pml_first_child(element, "nvCxnSpPr") {
    Some(c) => CT_ConnectorNonVisual::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_Connector/<nvCxnSpPr>",
        value="",
        reason="required child missing",
      )
  }
  let sp_pr = match pml_first_child(element, "spPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_Connector/<spPr>",
        value="",
        reason="required child missing",
      )
  }
  let style = pml_first_child(element, "style")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, nv_cxn_sp_pr, sp_pr, style, ext_lst }
}

///|
pub fn CT_Connector::new(element : @xml.Element) -> CT_Connector {
  CT_Connector::parse(element) catch {
    _ =>
      {
        element,
        nv_cxn_sp_pr: CT_ConnectorNonVisual::new(element),
        sp_pr: element,
        style: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_Connector::to_element(self : CT_Connector) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PictureNonVisual — Part 1 §19.3.1.32 nvPicPr.
/// Three required children: `<cNvPr>` (a:CT_NonVisualDrawingProps
/// §19.3.1.12, DrawingML), `<cNvPicPr>` (a:CT_NonVisualPictureProperties
/// §19.3.1.11, DrawingML), `<nvPr>`
/// (CT_ApplicationNonVisualDrawingProps §19.3.1.33).
pub(all) struct CT_PictureNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps §19.3.1.12) — required raw element.
  c_nv_pr : @xml.Element
  /// <cNvPicPr> (a:CT_NonVisualPictureProperties §19.3.1.11) — required raw
  /// element (DrawingML).
  c_nv_pic_pr : @xml.Element
  /// <nvPr> (CT_ApplicationNonVisualDrawingProps §19.3.1.33) — required.
  nv_pr : CT_ApplicationNonVisualDrawingProps
} derive(Eq, Debug)

///|
pub fn CT_PictureNonVisual::parse(
  element : @xml.Element,
) -> CT_PictureNonVisual raise SchemaViolation {
  let c_nv_pr = match pml_first_child(element, "cNvPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_PictureNonVisual/<cNvPr>",
        value="",
        reason="required child missing",
      )
  }
  let c_nv_pic_pr = match pml_first_child(element, "cNvPicPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_PictureNonVisual/<cNvPicPr>",
        value="",
        reason="required child missing",
      )
  }
  let nv_pr = match pml_first_child(element, "nvPr") {
    Some(c) => CT_ApplicationNonVisualDrawingProps::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_PictureNonVisual/<nvPr>",
        value="",
        reason="required child missing",
      )
  }
  { element, c_nv_pr, c_nv_pic_pr, nv_pr }
}

///|
pub fn CT_PictureNonVisual::new(element : @xml.Element) -> CT_PictureNonVisual {
  CT_PictureNonVisual::parse(element) catch {
    _ =>
      {
        element,
        c_nv_pr: element,
        c_nv_pic_pr: element,
        nv_pr: CT_ApplicationNonVisualDrawingProps::new(element),
      }
  }
}

///|
pub fn CT_PictureNonVisual::to_element(
  self : CT_PictureNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Picture — Part 1 §19.3.1.37 pic. Slide picture:
/// required `<nvPicPr>` (CT_PictureNonVisual §19.3.1.32), required
/// `<blipFill>` (a:CT_BlipFillProperties §19.3.1.4, DrawingML),
/// required `<spPr>` (a:CT_ShapeProperties §19.3.1.44, DrawingML),
/// optional `<style>` (a:CT_ShapeStyle §19.3.1.46, DrawingML), optional
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20).
pub(all) struct CT_Picture {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvPicPr> (CT_PictureNonVisual §19.3.1.32) — required.
  nv_pic_pr : CT_PictureNonVisual
  /// <blipFill> (a:CT_BlipFillProperties §19.3.1.4) — required raw element.
  blip_fill : @xml.Element
  /// <spPr> (a:CT_ShapeProperties §19.3.1.44) — required raw element.
  sp_pr : @xml.Element
  /// <style>? (a:CT_ShapeStyle §19.3.1.46) — raw (DrawingML).
  style : @xml.Element?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_Picture::parse(
  element : @xml.Element,
) -> CT_Picture raise SchemaViolation {
  let nv_pic_pr = match pml_first_child(element, "nvPicPr") {
    Some(c) => CT_PictureNonVisual::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_Picture/<nvPicPr>",
        value="",
        reason="required child missing",
      )
  }
  let blip_fill = match pml_first_child(element, "blipFill") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_Picture/<blipFill>",
        value="",
        reason="required child missing",
      )
  }
  let sp_pr = match pml_first_child(element, "spPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_Picture/<spPr>",
        value="",
        reason="required child missing",
      )
  }
  let style = pml_first_child(element, "style")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, nv_pic_pr, blip_fill, sp_pr, style, ext_lst }
}

///|
pub fn CT_Picture::new(element : @xml.Element) -> CT_Picture {
  CT_Picture::parse(element) catch {
    _ =>
      {
        element,
        nv_pic_pr: CT_PictureNonVisual::new(element),
        blip_fill: element,
        sp_pr: element,
        style: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_Picture::to_element(self : CT_Picture) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicalObjectFrameNonVisual — Part 1
/// §19.3.1.30 nvGraphicFramePr. Three required children: `<cNvPr>`
/// (a:CT_NonVisualDrawingProps §19.3.1.12, DrawingML),
/// `<cNvGraphicFramePr>` (a:CT_NonVisualGraphicFrameProperties
/// §19.3.1.9, DrawingML), `<nvPr>` (CT_ApplicationNonVisualDrawingProps
/// §19.3.1.33).
pub(all) struct CT_GraphicalObjectFrameNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps §19.3.1.12) — required raw element.
  c_nv_pr : @xml.Element
  /// <cNvGraphicFramePr> (a:CT_NonVisualGraphicFrameProperties §19.3.1.9)
  /// — required raw element (DrawingML).
  c_nv_graphic_frame_pr : @xml.Element
  /// <nvPr> (CT_ApplicationNonVisualDrawingProps §19.3.1.33) — required.
  nv_pr : CT_ApplicationNonVisualDrawingProps
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectFrameNonVisual::parse(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameNonVisual raise SchemaViolation {
  let c_nv_pr = match pml_first_child(element, "cNvPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_GraphicalObjectFrameNonVisual/<cNvPr>",
        value="",
        reason="required child missing",
      )
  }
  let c_nv_graphic_frame_pr = match
    pml_first_child(element, "cNvGraphicFramePr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_GraphicalObjectFrameNonVisual/<cNvGraphicFramePr>",
        value="",
        reason="required child missing",
      )
  }
  let nv_pr = match pml_first_child(element, "nvPr") {
    Some(c) => CT_ApplicationNonVisualDrawingProps::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_GraphicalObjectFrameNonVisual/<nvPr>",
        value="",
        reason="required child missing",
      )
  }
  { element, c_nv_pr, c_nv_graphic_frame_pr, nv_pr }
}

///|
pub fn CT_GraphicalObjectFrameNonVisual::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameNonVisual {
  CT_GraphicalObjectFrameNonVisual::parse(element) catch {
    _ =>
      {
        element,
        c_nv_pr: element,
        c_nv_graphic_frame_pr: element,
        nv_pr: CT_ApplicationNonVisualDrawingProps::new(element),
      }
  }
}

///|
pub fn CT_GraphicalObjectFrameNonVisual::to_element(
  self : CT_GraphicalObjectFrameNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicalObjectFrame — Part 1 §19.3.1.21
/// graphicFrame. Required children: `<nvGraphicFramePr>`
/// (CT_GraphicalObjectFrameNonVisual §19.3.1.30), `<xfrm>`
/// (a:CT_Transform2D §20.1.7.6, DrawingML), `<a:graphic>`
/// (a:CT_GraphicalObject §20.1.2.2.16, DrawingML element ref); optional
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20). Optional `@bwMode`
/// (a:ST_BlackWhiteMode §20.1.10.10).
pub(all) struct CT_GraphicalObjectFrame {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @bwMode (a:ST_BlackWhiteMode §20.1.10.10) — raw token preserved
  /// because DrawingML owns ST_BlackWhiteMode.
  bw_mode : String?
  /// <nvGraphicFramePr> (CT_GraphicalObjectFrameNonVisual §19.3.1.30) — required.
  nv_graphic_frame_pr : CT_GraphicalObjectFrameNonVisual
  /// <xfrm> (a:CT_Transform2D §20.1.7.6) — required raw element (DrawingML).
  xfrm : @xml.Element
  /// `<a:graphic>` (a:CT_GraphicalObject §20.1.2.2.16) — required raw
  /// element reference (DrawingML).
  graphic : @xml.Element
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectFrame::parse(
  element : @xml.Element,
) -> CT_GraphicalObjectFrame raise SchemaViolation {
  let bw_mode = pml_attr(element, "bwMode")
  let nv_graphic_frame_pr = match pml_first_child(element, "nvGraphicFramePr") {
    Some(c) => CT_GraphicalObjectFrameNonVisual::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_GraphicalObjectFrame/<nvGraphicFramePr>",
        value="",
        reason="required child missing",
      )
  }
  let xfrm = match pml_first_child(element, "xfrm") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_GraphicalObjectFrame/<xfrm>",
        value="",
        reason="required child missing",
      )
  }
  let graphic = match pml_first_child(element, "graphic") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_GraphicalObjectFrame/<a:graphic>",
        value="",
        reason="required child missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, bw_mode, nv_graphic_frame_pr, xfrm, graphic, ext_lst }
}

///|
pub fn CT_GraphicalObjectFrame::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrame {
  CT_GraphicalObjectFrame::parse(element) catch {
    _ =>
      {
        element,
        bw_mode: None,
        nv_graphic_frame_pr: CT_GraphicalObjectFrameNonVisual::new(element),
        xfrm: element,
        graphic: element,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_GraphicalObjectFrame::to_element(
  self : CT_GraphicalObjectFrame,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GroupShapeNonVisual — Part 1 §19.3.1.31
/// nvGrpSpPr. Three required children: `<cNvPr>`
/// (a:CT_NonVisualDrawingProps §19.3.1.12, DrawingML), `<cNvGrpSpPr>`
/// (a:CT_NonVisualGroupDrawingShapeProps §19.3.1.10, DrawingML),
/// `<nvPr>` (CT_ApplicationNonVisualDrawingProps §19.3.1.33).
pub(all) struct CT_GroupShapeNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps §19.3.1.12) — required raw element.
  c_nv_pr : @xml.Element
  /// <cNvGrpSpPr> (a:CT_NonVisualGroupDrawingShapeProps §19.3.1.10) —
  /// required raw element (DrawingML).
  c_nv_grp_sp_pr : @xml.Element
  /// <nvPr> (CT_ApplicationNonVisualDrawingProps §19.3.1.33) — required.
  nv_pr : CT_ApplicationNonVisualDrawingProps
} derive(Eq, Debug)

///|
pub fn CT_GroupShapeNonVisual::parse(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual raise SchemaViolation {
  let c_nv_pr = match pml_first_child(element, "cNvPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_GroupShapeNonVisual/<cNvPr>",
        value="",
        reason="required child missing",
      )
  }
  let c_nv_grp_sp_pr = match pml_first_child(element, "cNvGrpSpPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_GroupShapeNonVisual/<cNvGrpSpPr>",
        value="",
        reason="required child missing",
      )
  }
  let nv_pr = match pml_first_child(element, "nvPr") {
    Some(c) => CT_ApplicationNonVisualDrawingProps::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_GroupShapeNonVisual/<nvPr>",
        value="",
        reason="required child missing",
      )
  }
  { element, c_nv_pr, c_nv_grp_sp_pr, nv_pr }
}

///|
pub fn CT_GroupShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual {
  CT_GroupShapeNonVisual::parse(element) catch {
    _ =>
      {
        element,
        c_nv_pr: element,
        c_nv_grp_sp_pr: element,
        nv_pr: CT_ApplicationNonVisualDrawingProps::new(element),
      }
  }
}

///|
pub fn CT_GroupShapeNonVisual::to_element(
  self : CT_GroupShapeNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// PmlGroupShapeChild — typed encoding of the inner `xsd:choice`
/// (minOccurs=0, maxOccurs=unbounded) inside CT_GroupShape (§19.3.1.22
/// grpSp). The six recognised children dispatch by local name to the
/// matching domain type.
pub(all) enum PmlGroupShapeChild {
  /// `<sp>` (CT_Shape §19.3.1.43).
  PmlGroupShapeSp(CT_Shape)
  /// `<grpSp>` (CT_GroupShape §19.3.1.22) — recursive nested group.
  PmlGroupShapeGrp(CT_GroupShape)
  /// `<graphicFrame>` (CT_GraphicalObjectFrame §19.3.1.21).
  PmlGroupShapeGraphicFrame(CT_GraphicalObjectFrame)
  /// `<cxnSp>` (CT_Connector §19.3.1.19).
  PmlGroupShapeCxnSp(CT_Connector)
  /// `<pic>` (CT_Picture §19.3.1.37).
  PmlGroupShapePic(CT_Picture)
  /// `<contentPart>` (CT_Rel §19.3.1.14).
  PmlGroupShapeContentPart(CT_Rel)
} derive(Eq, Debug)

///|
/// XSD complex type CT_GroupShape — Part 1 §19.3.1.22 grpSp. Required
/// `<nvGrpSpPr>` (CT_GroupShapeNonVisual §19.3.1.31), required
/// `<grpSpPr>` (a:CT_GroupShapeProperties §19.3.1.23, DrawingML),
/// `xsd:choice` (zero or more) over `<sp>` / `<grpSp>` /
/// `<graphicFrame>` / `<cxnSp>` / `<pic>` / `<contentPart>`, optional
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20).
pub(all) struct CT_GroupShape {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvGrpSpPr> (CT_GroupShapeNonVisual §19.3.1.31) — required.
  nv_grp_sp_pr : CT_GroupShapeNonVisual
  /// <grpSpPr> (a:CT_GroupShapeProperties §19.3.1.23) — required raw
  /// element (DrawingML-owned).
  grp_sp_pr : @xml.Element
  /// xsd:choice (0..unbounded) over the six recognised shape kinds, in
  /// document order.
  shapes : Array[PmlGroupShapeChild]
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_GroupShape::parse(
  element : @xml.Element,
) -> CT_GroupShape raise SchemaViolation {
  let nv_grp_sp_pr = match pml_first_child(element, "nvGrpSpPr") {
    Some(c) => CT_GroupShapeNonVisual::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_GroupShape/<nvGrpSpPr>",
        value="",
        reason="required child missing",
      )
  }
  let grp_sp_pr = match pml_first_child(element, "grpSpPr") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_GroupShape/<grpSpPr>",
        value="",
        reason="required child missing",
      )
  }
  let shapes : Array[PmlGroupShapeChild] = []
  for child in element.children {
    match child {
      @xml.Element(c) =>
        match c.name.local_name {
          "sp" => shapes.push(PmlGroupShapeSp(CT_Shape::parse(c)))
          "grpSp" => shapes.push(PmlGroupShapeGrp(CT_GroupShape::parse(c)))
          "graphicFrame" =>
            shapes.push(
              PmlGroupShapeGraphicFrame(CT_GraphicalObjectFrame::parse(c)),
            )
          "cxnSp" => shapes.push(PmlGroupShapeCxnSp(CT_Connector::parse(c)))
          "pic" => shapes.push(PmlGroupShapePic(CT_Picture::parse(c)))
          "contentPart" =>
            shapes.push(PmlGroupShapeContentPart(CT_Rel::parse(c)))
          _ => ()
        }
      _ => ()
    }
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, nv_grp_sp_pr, grp_sp_pr, shapes, ext_lst }
}

///|
pub fn CT_GroupShape::new(element : @xml.Element) -> CT_GroupShape {
  CT_GroupShape::parse(element) catch {
    _ =>
      {
        element,
        nv_grp_sp_pr: CT_GroupShapeNonVisual::new(element),
        grp_sp_pr: element,
        shapes: [],
        ext_lst: None,
      }
  }
}

///|
pub fn CT_GroupShape::to_element(self : CT_GroupShape) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Rel — Part 1 §19.3.1.14 contentPart. Backs the
/// `<contentPart>` element with a single required `@r:id`
/// (ST_RelationshipId) attribute. (A second, namesake `CT_Rel` lives
/// in vml-presentationDrawing.xsd and is exposed as
/// `VmlPresentationDrawing_CT_Rel` in this package.)
pub(all) struct CT_Rel {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_Rel::parse(element : @xml.Element) -> CT_Rel raise SchemaViolation {
  let r_id = pml_require_attr(element, "id", "CT_Rel/@r:id")
  { element, r_id }
}

///|
pub fn CT_Rel::new(element : @xml.Element) -> CT_Rel {
  CT_Rel::parse(element) catch {
    _ => { element, r_id: "" }
  }
}

///|
pub fn CT_Rel::to_element(self : CT_Rel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BackgroundProperties — Part 1 §19.3.1.2 bgPr.
/// Background fill: required `a:EG_FillProperties` model-group payload
/// (one of `noFill`, `solidFill`, `gradFill`, `blipFill`, `pattFill`,
/// `grpFill`; DrawingML-owned, kept raw), optional `a:EG_EffectProperties`
/// (DrawingML, kept raw), optional `<extLst>` (CT_ExtensionList §19.2.1.13).
/// Optional `@shadeToTitle` (xsd:boolean, default `false`).
pub(all) struct CT_BackgroundProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @shadeToTitle (xsd:boolean, default `false`).
  shade_to_title : Bool?
  /// `a:EG_FillProperties` — the matched raw element (noFill / solidFill
  /// / gradFill / blipFill / pattFill / grpFill); required.
  fill : @xml.Element
  /// `a:EG_EffectProperties`? — optional raw element (effectLst /
  /// effectDag).
  effect : @xml.Element?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_BackgroundProperties::parse(
  element : @xml.Element,
) -> CT_BackgroundProperties raise SchemaViolation {
  let shade_to_title = pml_optional_bool(
    element, "shadeToTitle", "CT_BackgroundProperties/@shadeToTitle",
  )
  let fill = match
    pml_first_choice(element, [
      "noFill", "solidFill", "gradFill", "blipFill", "pattFill", "grpFill",
    ]) {
    Some((c, _)) => c
    None =>
      raise SchemaViolation(
        type_name="CT_BackgroundProperties/EG_FillProperties",
        value="",
        reason="required fill child missing",
      )
  }
  let effect = match pml_first_choice(element, ["effectLst", "effectDag"]) {
    Some((c, _)) => Some(c)
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, shade_to_title, fill, effect, ext_lst }
}

///|
pub fn CT_BackgroundProperties::new(
  element : @xml.Element,
) -> CT_BackgroundProperties {
  CT_BackgroundProperties::parse(element) catch {
    _ =>
      {
        element,
        shade_to_title: None,
        fill: element,
        effect: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_BackgroundProperties::to_element(
  self : CT_BackgroundProperties,
) -> @xml.Element {
  self.element
}

///|
/// PmlBackgroundChoice — typed encoding of the XSD model group
/// EG_Background used inside CT_Background. Schema xsd:choice between
/// `<bgPr>` (CT_BackgroundProperties §19.3.1.2) and `<bgRef>`
/// (a:CT_StyleMatrixReference §20.1.4.2.3, DrawingML-owned — raw
/// element).
pub(all) enum PmlBackgroundChoice {
  /// `<bgPr>` (CT_BackgroundProperties §19.3.1.2).
  PmlBackgroundPr(CT_BackgroundProperties)
  /// `<bgRef>` (a:CT_StyleMatrixReference §20.1.4.2.3) — raw element
  /// preserved because the type is DrawingML-owned.
  PmlBackgroundRef(@xml.Element)
} derive(Eq, Debug)

///|
/// XSD complex type CT_Background — Part 1 §19.3.1.1 bg. Required
/// EG_Background model-group (PmlBackgroundChoice) plus optional
/// `@bwMode` (a:ST_BlackWhiteMode §20.1.10.10, default `"white"`).
pub(all) struct CT_Background {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @bwMode (a:ST_BlackWhiteMode §20.1.10.10) — raw token preserved
  /// because DrawingML owns ST_BlackWhiteMode.
  bw_mode : String?
  /// PmlBackgroundChoice — required (one of `<bgPr>` / `<bgRef>`).
  background : PmlBackgroundChoice
} derive(Eq, Debug)

///|
pub fn CT_Background::parse(
  element : @xml.Element,
) -> CT_Background raise SchemaViolation {
  let bw_mode = pml_attr(element, "bwMode")
  let background = match pml_first_choice(element, ["bgPr", "bgRef"]) {
    Some((c, "bgPr")) => PmlBackgroundPr(CT_BackgroundProperties::parse(c))
    Some((c, "bgRef")) => PmlBackgroundRef(c)
    _ =>
      raise SchemaViolation(
        type_name="CT_Background/EG_Background",
        value="",
        reason="required xsd:choice missing",
      )
  }
  { element, bw_mode, background }
}

///|
pub fn CT_Background::new(element : @xml.Element) -> CT_Background {
  CT_Background::parse(element) catch {
    _ => { element, bw_mode: None, background: PmlBackgroundRef(element) }
  }
}

///|
pub fn CT_Background::to_element(self : CT_Background) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonSlideData — Part 1 §19.3.1.16 cSld. Slide
/// content backbone: optional `<bg>` (CT_Background §19.3.1.1),
/// required `<spTree>` (CT_GroupShape §19.3.1.22, slide shape tree),
/// optional `<custDataLst>` (CT_CustomerDataList §19.3.1.18), optional
/// `<controls>` (CT_ControlList §19.3.1.15), optional `<extLst>`
/// (CT_ExtensionList §19.2.1.13). Optional `@name` (xsd:string, default `""`).
pub(all) struct CT_CommonSlideData {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (xsd:string, default `""`).
  name : String?
  /// <bg>? (CT_Background §19.3.1.1).
  bg : CT_Background?
  /// <spTree> (CT_GroupShape §19.3.1.22) — required slide shape tree.
  sp_tree : CT_GroupShape
  /// <custDataLst>? (CT_CustomerDataList §19.3.1.18).
  cust_data_lst : CT_CustomerDataList?
  /// <controls>? (CT_ControlList §19.3.1.15).
  controls : CT_ControlList?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CommonSlideData::parse(
  element : @xml.Element,
) -> CT_CommonSlideData raise SchemaViolation {
  let name = pml_attr(element, "name")
  let bg = match pml_first_child(element, "bg") {
    Some(c) => Some(CT_Background::parse(c))
    None => None
  }
  let sp_tree = match pml_first_child(element, "spTree") {
    Some(c) => CT_GroupShape::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_CommonSlideData/<spTree>",
        value="",
        reason="required child missing",
      )
  }
  let cust_data_lst = match pml_first_child(element, "custDataLst") {
    Some(c) => Some(CT_CustomerDataList::parse(c))
    None => None
  }
  let controls = match pml_first_child(element, "controls") {
    Some(c) => Some(CT_ControlList::parse(c))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, name, bg, sp_tree, cust_data_lst, controls, ext_lst }
}

///|
pub fn CT_CommonSlideData::new(element : @xml.Element) -> CT_CommonSlideData {
  CT_CommonSlideData::parse(element) catch {
    _ =>
      {
        element,
        name: None,
        bg: None,
        sp_tree: CT_GroupShape::new(element),
        cust_data_lst: None,
        controls: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_CommonSlideData::to_element(
  self : CT_CommonSlideData,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Slide — Part 1 §19.3.1.38 sld. Slide root.
/// Required `<cSld>` (CT_CommonSlideData §19.3.1.16); optional
/// EG_ChildSlide group (`<clrMapOvr>` raw — DrawingML); optional
/// `<transition>` (CT_SlideTransition §19.5.50), `<timing>`
/// (CT_SlideTiming §19.5.49), `<extLst>` (CT_ExtensionListModify
/// §19.3.1.20). Optional AG_ChildSlide attributes (`@showMasterSp`,
/// `@showMasterPhAnim`, each xsd:boolean default `true`) plus `@show`
/// (xsd:boolean, default `true`).
pub(all) struct CT_Slide {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @showMasterSp (AG_ChildSlide, xsd:boolean default `true`).
  show_master_sp : Bool?
  /// @showMasterPhAnim (AG_ChildSlide, xsd:boolean default `true`).
  show_master_ph_anim : Bool?
  /// @show (xsd:boolean, default `true`).
  show : Bool?
  /// <cSld> (CT_CommonSlideData §19.3.1.16) — required.
  c_sld : CT_CommonSlideData
  /// EG_ChildSlide `<clrMapOvr>`? (a:CT_ColorMappingOverride §19.3.1.7)
  /// — raw element (DrawingML).
  clr_map_ovr : @xml.Element?
  /// <transition>? (CT_SlideTransition §19.5.50).
  transition : CT_SlideTransition?
  /// <timing>? (CT_SlideTiming §19.5.49).
  timing : CT_SlideTiming?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_Slide::parse(
  element : @xml.Element,
) -> CT_Slide raise SchemaViolation {
  let show_master_sp = pml_optional_bool(
    element, "showMasterSp", "CT_Slide/@showMasterSp",
  )
  let show_master_ph_anim = pml_optional_bool(
    element, "showMasterPhAnim", "CT_Slide/@showMasterPhAnim",
  )
  let show = pml_optional_bool(element, "show", "CT_Slide/@show")
  let c_sld = match pml_first_child(element, "cSld") {
    Some(c) => CT_CommonSlideData::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_Slide/<cSld>",
        value="",
        reason="required child missing",
      )
  }
  let clr_map_ovr = pml_first_child(element, "clrMapOvr")
  let transition = match pml_first_child(element, "transition") {
    Some(c) => Some(CT_SlideTransition::parse(c))
    None => None
  }
  let timing = match pml_first_child(element, "timing") {
    Some(c) => Some(CT_SlideTiming::new(c))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  {
    element,
    show_master_sp,
    show_master_ph_anim,
    show,
    c_sld,
    clr_map_ovr,
    transition,
    timing,
    ext_lst,
  }
}

///|
pub fn CT_Slide::new(element : @xml.Element) -> CT_Slide {
  CT_Slide::parse(element) catch {
    _ =>
      {
        element,
        show_master_sp: None,
        show_master_ph_anim: None,
        show: None,
        c_sld: CT_CommonSlideData::new(element),
        clr_map_ovr: None,
        transition: None,
        timing: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_Slide::to_element(self : CT_Slide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayout — Part 1 §19.3.1.39 sldLayout. Slide
/// layout root. Required `<cSld>` (CT_CommonSlideData §19.3.1.16);
/// optional EG_ChildSlide `<clrMapOvr>` (raw — DrawingML); optional
/// `<transition>` (CT_SlideTransition §19.5.50), `<timing>`
/// (CT_SlideTiming §19.5.49), `<hf>` (CT_HeaderFooter §19.3.1.25),
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20). Optional
/// AG_ChildSlide attributes plus `@matchingName` (xsd:string default
/// `""`), `@type` (ST_SlideLayoutType §19.7.15 default `cust`),
/// `@preserve` (xsd:boolean default `false`), `@userDrawn` (xsd:boolean
/// default `false`).
pub(all) struct CT_SlideLayout {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @showMasterSp (AG_ChildSlide, xsd:boolean default `true`).
  show_master_sp : Bool?
  /// @showMasterPhAnim (AG_ChildSlide, xsd:boolean default `true`).
  show_master_ph_anim : Bool?
  /// @matchingName (xsd:string, default `""`).
  matching_name : String?
  /// @type (ST_SlideLayoutType §19.7.15, default `cust`).
  layout_type : ST_SlideLayoutType?
  /// @preserve (xsd:boolean, default `false`).
  preserve : Bool?
  /// @userDrawn (xsd:boolean, default `false`).
  user_drawn : Bool?
  /// <cSld> (CT_CommonSlideData §19.3.1.16) — required.
  c_sld : CT_CommonSlideData
  /// EG_ChildSlide `<clrMapOvr>`? (a:CT_ColorMappingOverride §19.3.1.7)
  /// — raw element (DrawingML).
  clr_map_ovr : @xml.Element?
  /// <transition>? (CT_SlideTransition §19.5.50).
  transition : CT_SlideTransition?
  /// <timing>? (CT_SlideTiming §19.5.49).
  timing : CT_SlideTiming?
  /// <hf>? (CT_HeaderFooter §19.3.1.25).
  hf : CT_HeaderFooter?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_SlideLayout::parse(
  element : @xml.Element,
) -> CT_SlideLayout raise SchemaViolation {
  let show_master_sp = pml_optional_bool(
    element, "showMasterSp", "CT_SlideLayout/@showMasterSp",
  )
  let show_master_ph_anim = pml_optional_bool(
    element, "showMasterPhAnim", "CT_SlideLayout/@showMasterPhAnim",
  )
  let matching_name = pml_attr(element, "matchingName")
  let layout_type = match pml_attr(element, "type") {
    Some(v) => Some(ST_SlideLayoutType::parse(v))
    None => None
  }
  let preserve = pml_optional_bool(
    element, "preserve", "CT_SlideLayout/@preserve",
  )
  let user_drawn = pml_optional_bool(
    element, "userDrawn", "CT_SlideLayout/@userDrawn",
  )
  let c_sld = match pml_first_child(element, "cSld") {
    Some(c) => CT_CommonSlideData::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_SlideLayout/<cSld>",
        value="",
        reason="required child missing",
      )
  }
  let clr_map_ovr = pml_first_child(element, "clrMapOvr")
  let transition = match pml_first_child(element, "transition") {
    Some(c) => Some(CT_SlideTransition::parse(c))
    None => None
  }
  let timing = match pml_first_child(element, "timing") {
    Some(c) => Some(CT_SlideTiming::new(c))
    None => None
  }
  let hf = match pml_first_child(element, "hf") {
    Some(c) => Some(CT_HeaderFooter::parse(c))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  {
    element,
    show_master_sp,
    show_master_ph_anim,
    matching_name,
    layout_type,
    preserve,
    user_drawn,
    c_sld,
    clr_map_ovr,
    transition,
    timing,
    hf,
    ext_lst,
  }
}

///|
pub fn CT_SlideLayout::new(element : @xml.Element) -> CT_SlideLayout {
  CT_SlideLayout::parse(element) catch {
    _ =>
      {
        element,
        show_master_sp: None,
        show_master_ph_anim: None,
        matching_name: None,
        layout_type: None,
        preserve: None,
        user_drawn: None,
        c_sld: CT_CommonSlideData::new(element),
        clr_map_ovr: None,
        transition: None,
        timing: None,
        hf: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_SlideLayout::to_element(self : CT_SlideLayout) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterTextStyles — Part 1 §19.3.1.52
/// txStyles. Sequence of three optional `<titleStyle>` / `<bodyStyle>`
/// / `<otherStyle>` children (each a:CT_TextListStyle §21.1.2.4.12,
/// DrawingML-owned — kept raw) plus optional `<extLst>`
/// (CT_ExtensionList §19.2.1.13).
pub(all) struct CT_SlideMasterTextStyles {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <titleStyle>? (a:CT_TextListStyle §21.1.2.4.12) — raw (DrawingML).
  title_style : @xml.Element?
  /// <bodyStyle>? (a:CT_TextListStyle §21.1.2.4.12) — raw (DrawingML).
  body_style : @xml.Element?
  /// <otherStyle>? (a:CT_TextListStyle §21.1.2.4.12) — raw (DrawingML).
  other_style : @xml.Element?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterTextStyles::parse(
  element : @xml.Element,
) -> CT_SlideMasterTextStyles raise SchemaViolation {
  let title_style = pml_first_child(element, "titleStyle")
  let body_style = pml_first_child(element, "bodyStyle")
  let other_style = pml_first_child(element, "otherStyle")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, title_style, body_style, other_style, ext_lst }
}

///|
pub fn CT_SlideMasterTextStyles::new(
  element : @xml.Element,
) -> CT_SlideMasterTextStyles {
  CT_SlideMasterTextStyles::parse(element) catch {
    _ =>
      {
        element,
        title_style: None,
        body_style: None,
        other_style: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_SlideMasterTextStyles::to_element(
  self : CT_SlideMasterTextStyles,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayoutIdListEntry — Part 1 §19.3.1.40
/// sldLayoutId. Optional `<extLst>` (CT_ExtensionList §19.2.1.13);
/// optional `@id` (ST_SlideLayoutId §19.7.14 — xsd:unsignedInt with
/// minInclusive 2147483648); required `@r:id` (ST_RelationshipId).
pub(all) struct CT_SlideLayoutIdListEntry {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (ST_SlideLayoutId §19.7.14) — optional.
  id : ST_SlideLayoutId?
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SlideLayoutIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideLayoutIdListEntry raise SchemaViolation {
  let id = match pml_attr(element, "id") {
    Some(v) => Some(ST_SlideLayoutId::parse(v))
    None => None
  }
  let r_id = pml_require_attr(element, "id", "CT_SlideLayoutIdListEntry/@r:id")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, id, r_id, ext_lst }
}

///|
pub fn CT_SlideLayoutIdListEntry::new(
  element : @xml.Element,
) -> CT_SlideLayoutIdListEntry {
  CT_SlideLayoutIdListEntry::parse(element) catch {
    _ => { element, id: None, r_id: "", ext_lst: None }
  }
}

///|
pub fn CT_SlideLayoutIdListEntry::to_element(
  self : CT_SlideLayoutIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayoutIdList — Part 1 §19.3.1.41
/// sldLayoutIdLst. Zero or more `<sldLayoutId>`
/// (CT_SlideLayoutIdListEntry §19.3.1.40) entries.
pub(all) struct CT_SlideLayoutIdList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sldLayoutId>* (CT_SlideLayoutIdListEntry §19.3.1.40) — zero or more.
  sld_layout_id : Array[CT_SlideLayoutIdListEntry]
} derive(Eq, Debug)

///|
pub fn CT_SlideLayoutIdList::parse(
  element : @xml.Element,
) -> CT_SlideLayoutIdList raise SchemaViolation {
  let sld_layout_id : Array[CT_SlideLayoutIdListEntry] = []
  for child in pml_children(element, "sldLayoutId") {
    sld_layout_id.push(CT_SlideLayoutIdListEntry::parse(child))
  }
  { element, sld_layout_id }
}

///|
pub fn CT_SlideLayoutIdList::new(
  element : @xml.Element,
) -> CT_SlideLayoutIdList {
  CT_SlideLayoutIdList::parse(element) catch {
    _ => { element, sld_layout_id: [] }
  }
}

///|
pub fn CT_SlideLayoutIdList::to_element(
  self : CT_SlideLayoutIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMaster — Part 1 §19.3.1.42 sldMaster. Slide
/// master root. Required `<cSld>` (CT_CommonSlideData §19.3.1.16);
/// required EG_TopLevelSlide `<clrMap>` (a:CT_ColorMapping §19.3.1.6,
/// DrawingML — raw); optional `<sldLayoutIdLst>` (CT_SlideLayoutIdList
/// §19.3.1.41), `<transition>` (CT_SlideTransition §19.5.50),
/// `<timing>` (CT_SlideTiming §19.5.49), `<hf>` (CT_HeaderFooter
/// §19.3.1.25), `<txStyles>` (CT_SlideMasterTextStyles §19.3.1.52),
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20). Optional `@preserve`
/// (xsd:boolean, default `false`).
pub(all) struct CT_SlideMaster {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @preserve (xsd:boolean, default `false`).
  preserve : Bool?
  /// <cSld> (CT_CommonSlideData §19.3.1.16) — required.
  c_sld : CT_CommonSlideData
  /// EG_TopLevelSlide `<clrMap>` (a:CT_ColorMapping §19.3.1.6) —
  /// required raw element (DrawingML).
  clr_map : @xml.Element
  /// <sldLayoutIdLst>? (CT_SlideLayoutIdList §19.3.1.41).
  sld_layout_id_lst : CT_SlideLayoutIdList?
  /// <transition>? (CT_SlideTransition §19.5.50).
  transition : CT_SlideTransition?
  /// <timing>? (CT_SlideTiming §19.5.49).
  timing : CT_SlideTiming?
  /// <hf>? (CT_HeaderFooter §19.3.1.25).
  hf : CT_HeaderFooter?
  /// <txStyles>? (CT_SlideMasterTextStyles §19.3.1.52).
  tx_styles : CT_SlideMasterTextStyles?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_SlideMaster::parse(
  element : @xml.Element,
) -> CT_SlideMaster raise SchemaViolation {
  let preserve = pml_optional_bool(
    element, "preserve", "CT_SlideMaster/@preserve",
  )
  let c_sld = match pml_first_child(element, "cSld") {
    Some(c) => CT_CommonSlideData::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_SlideMaster/<cSld>",
        value="",
        reason="required child missing",
      )
  }
  let clr_map = match pml_first_child(element, "clrMap") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_SlideMaster/<clrMap>",
        value="",
        reason="required child missing",
      )
  }
  let sld_layout_id_lst = match pml_first_child(element, "sldLayoutIdLst") {
    Some(c) => Some(CT_SlideLayoutIdList::parse(c))
    None => None
  }
  let transition = match pml_first_child(element, "transition") {
    Some(c) => Some(CT_SlideTransition::parse(c))
    None => None
  }
  let timing = match pml_first_child(element, "timing") {
    Some(c) => Some(CT_SlideTiming::new(c))
    None => None
  }
  let hf = match pml_first_child(element, "hf") {
    Some(c) => Some(CT_HeaderFooter::parse(c))
    None => None
  }
  let tx_styles = match pml_first_child(element, "txStyles") {
    Some(c) => Some(CT_SlideMasterTextStyles::parse(c))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  {
    element,
    preserve,
    c_sld,
    clr_map,
    sld_layout_id_lst,
    transition,
    timing,
    hf,
    tx_styles,
    ext_lst,
  }
}

///|
pub fn CT_SlideMaster::new(element : @xml.Element) -> CT_SlideMaster {
  CT_SlideMaster::parse(element) catch {
    _ =>
      {
        element,
        preserve: None,
        c_sld: CT_CommonSlideData::new(element),
        clr_map: element,
        sld_layout_id_lst: None,
        transition: None,
        timing: None,
        hf: None,
        tx_styles: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_SlideMaster::to_element(self : CT_SlideMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMaster — Part 1 §19.3.1.24
/// handoutMaster. Required `<cSld>` (CT_CommonSlideData §19.3.1.16);
/// required EG_TopLevelSlide `<clrMap>` (a:CT_ColorMapping §19.3.1.6,
/// DrawingML — raw); optional `<hf>` (CT_HeaderFooter §19.3.1.25),
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20).
pub(all) struct CT_HandoutMaster {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cSld> (CT_CommonSlideData §19.3.1.16) — required.
  c_sld : CT_CommonSlideData
  /// EG_TopLevelSlide `<clrMap>` (a:CT_ColorMapping §19.3.1.6) —
  /// required raw element (DrawingML).
  clr_map : @xml.Element
  /// <hf>? (CT_HeaderFooter §19.3.1.25).
  hf : CT_HeaderFooter?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_HandoutMaster::parse(
  element : @xml.Element,
) -> CT_HandoutMaster raise SchemaViolation {
  let c_sld = match pml_first_child(element, "cSld") {
    Some(c) => CT_CommonSlideData::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_HandoutMaster/<cSld>",
        value="",
        reason="required child missing",
      )
  }
  let clr_map = match pml_first_child(element, "clrMap") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_HandoutMaster/<clrMap>",
        value="",
        reason="required child missing",
      )
  }
  let hf = match pml_first_child(element, "hf") {
    Some(c) => Some(CT_HeaderFooter::parse(c))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, c_sld, clr_map, hf, ext_lst }
}

///|
pub fn CT_HandoutMaster::new(element : @xml.Element) -> CT_HandoutMaster {
  CT_HandoutMaster::parse(element) catch {
    _ =>
      {
        element,
        c_sld: CT_CommonSlideData::new(element),
        clr_map: element,
        hf: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_HandoutMaster::to_element(self : CT_HandoutMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMaster — Part 1 §19.3.1.27 notesMaster.
/// Required `<cSld>` (CT_CommonSlideData §19.3.1.16); required
/// EG_TopLevelSlide `<clrMap>` (a:CT_ColorMapping §19.3.1.6,
/// DrawingML — raw); optional `<hf>` (CT_HeaderFooter §19.3.1.25),
/// `<notesStyle>` (a:CT_TextListStyle §21.1.2.4.12, DrawingML — raw),
/// `<extLst>` (CT_ExtensionListModify §19.3.1.20).
pub(all) struct CT_NotesMaster {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cSld> (CT_CommonSlideData §19.3.1.16) — required.
  c_sld : CT_CommonSlideData
  /// EG_TopLevelSlide `<clrMap>` (a:CT_ColorMapping §19.3.1.6) —
  /// required raw element (DrawingML).
  clr_map : @xml.Element
  /// <hf>? (CT_HeaderFooter §19.3.1.25).
  hf : CT_HeaderFooter?
  /// <notesStyle>? (a:CT_TextListStyle §21.1.2.4.12) — raw (DrawingML).
  notes_style : @xml.Element?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_NotesMaster::parse(
  element : @xml.Element,
) -> CT_NotesMaster raise SchemaViolation {
  let c_sld = match pml_first_child(element, "cSld") {
    Some(c) => CT_CommonSlideData::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_NotesMaster/<cSld>",
        value="",
        reason="required child missing",
      )
  }
  let clr_map = match pml_first_child(element, "clrMap") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_NotesMaster/<clrMap>",
        value="",
        reason="required child missing",
      )
  }
  let hf = match pml_first_child(element, "hf") {
    Some(c) => Some(CT_HeaderFooter::parse(c))
    None => None
  }
  let notes_style = pml_first_child(element, "notesStyle")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, c_sld, clr_map, hf, notes_style, ext_lst }
}

///|
pub fn CT_NotesMaster::new(element : @xml.Element) -> CT_NotesMaster {
  CT_NotesMaster::parse(element) catch {
    _ =>
      {
        element,
        c_sld: CT_CommonSlideData::new(element),
        clr_map: element,
        hf: None,
        notes_style: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_NotesMaster::to_element(self : CT_NotesMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesSlide — Part 1 §19.3.1.26 notes. Notes
/// slide root. Required `<cSld>` (CT_CommonSlideData §19.3.1.16);
/// optional EG_ChildSlide `<clrMapOvr>` (raw — DrawingML), `<extLst>`
/// (CT_ExtensionListModify §19.3.1.20). Optional AG_ChildSlide
/// attributes `@showMasterSp` / `@showMasterPhAnim` (xsd:boolean each
/// default `true`).
pub(all) struct CT_NotesSlide {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @showMasterSp (AG_ChildSlide, xsd:boolean default `true`).
  show_master_sp : Bool?
  /// @showMasterPhAnim (AG_ChildSlide, xsd:boolean default `true`).
  show_master_ph_anim : Bool?
  /// <cSld> (CT_CommonSlideData §19.3.1.16) — required.
  c_sld : CT_CommonSlideData
  /// EG_ChildSlide `<clrMapOvr>`? (a:CT_ColorMappingOverride §19.3.1.7)
  /// — raw element (DrawingML).
  clr_map_ovr : @xml.Element?
  /// <extLst>? (CT_ExtensionListModify §19.3.1.20).
  ext_lst : CT_ExtensionListModify?
} derive(Eq, Debug)

///|
pub fn CT_NotesSlide::parse(
  element : @xml.Element,
) -> CT_NotesSlide raise SchemaViolation {
  let show_master_sp = pml_optional_bool(
    element, "showMasterSp", "CT_NotesSlide/@showMasterSp",
  )
  let show_master_ph_anim = pml_optional_bool(
    element, "showMasterPhAnim", "CT_NotesSlide/@showMasterPhAnim",
  )
  let c_sld = match pml_first_child(element, "cSld") {
    Some(c) => CT_CommonSlideData::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_NotesSlide/<cSld>",
        value="",
        reason="required child missing",
      )
  }
  let clr_map_ovr = pml_first_child(element, "clrMapOvr")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionListModify::parse(c))
    None => None
  }
  { element, show_master_sp, show_master_ph_anim, c_sld, clr_map_ovr, ext_lst }
}

///|
pub fn CT_NotesSlide::new(element : @xml.Element) -> CT_NotesSlide {
  CT_NotesSlide::parse(element) catch {
    _ =>
      {
        element,
        show_master_sp: None,
        show_master_ph_anim: None,
        c_sld: CT_CommonSlideData::new(element),
        clr_map_ovr: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_NotesSlide::to_element(self : CT_NotesSlide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSyncProperties — Part 1 §19.6.1 sldSyncPr.
/// Slide synchronisation root. Optional `<extLst>` (CT_ExtensionList
/// §19.2.1.13). Required attributes `@serverSldId` (xsd:string),
/// `@serverSldModifiedTime` (xsd:dateTime), `@clientInsertedTime`
/// (xsd:dateTime). The dateTime values are preserved as their lexical
/// strings because the kernel does not have a calendar type.
pub(all) struct CT_SlideSyncProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @serverSldId (xsd:string) — required.
  server_sld_id : String
  /// @serverSldModifiedTime (xsd:dateTime) — required (lexical form).
  server_sld_modified_time : String
  /// @clientInsertedTime (xsd:dateTime) — required (lexical form).
  client_inserted_time : String
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SlideSyncProperties::parse(
  element : @xml.Element,
) -> CT_SlideSyncProperties raise SchemaViolation {
  let server_sld_id = pml_require_attr(
    element, "serverSldId", "CT_SlideSyncProperties/@serverSldId",
  )
  let server_sld_modified_time = pml_require_attr(
    element, "serverSldModifiedTime", "CT_SlideSyncProperties/@serverSldModifiedTime",
  )
  let client_inserted_time = pml_require_attr(
    element, "clientInsertedTime", "CT_SlideSyncProperties/@clientInsertedTime",
  )
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  {
    element,
    server_sld_id,
    server_sld_modified_time,
    client_inserted_time,
    ext_lst,
  }
}

///|
pub fn CT_SlideSyncProperties::new(
  element : @xml.Element,
) -> CT_SlideSyncProperties {
  CT_SlideSyncProperties::parse(element) catch {
    _ =>
      {
        element,
        server_sld_id: "",
        server_sld_modified_time: "",
        client_inserted_time: "",
        ext_lst: None,
      }
  }
}

///|
pub fn CT_SlideSyncProperties::to_element(
  self : CT_SlideSyncProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StringTag — Part 1 §19.3.3.1 tag. Programmable
/// extensibility tag carrying two required xsd:string attributes:
/// `@name`, `@val`.
pub(all) struct CT_StringTag {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (xsd:string) — required.
  name : String
  /// @val (xsd:string) — required.
  val : String
} derive(Eq, Debug)

///|
pub fn CT_StringTag::parse(
  element : @xml.Element,
) -> CT_StringTag raise SchemaViolation {
  let name = pml_require_attr(element, "name", "CT_StringTag/@name")
  let val = pml_require_attr(element, "val", "CT_StringTag/@val")
  { element, name, val }
}

///|
pub fn CT_StringTag::new(element : @xml.Element) -> CT_StringTag {
  CT_StringTag::parse(element) catch {
    _ => { element, name: "", val: "" }
  }
}

///|
pub fn CT_StringTag::to_element(self : CT_StringTag) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TagList — Part 1 §19.3.3.2 tagLst. Sequence of
/// zero or more `<tag>` (CT_StringTag §19.3.3.1) entries.
pub(all) struct CT_TagList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <tag>* (CT_StringTag §19.3.3.1) — zero or more.
  tag : Array[CT_StringTag]
} derive(Eq, Debug)

///|
pub fn CT_TagList::parse(
  element : @xml.Element,
) -> CT_TagList raise SchemaViolation {
  let tag : Array[CT_StringTag] = []
  for child in pml_children(element, "tag") {
    tag.push(CT_StringTag::parse(child))
  }
  { element, tag }
}

///|
pub fn CT_TagList::new(element : @xml.Element) -> CT_TagList {
  CT_TagList::parse(element) catch {
    _ => { element, tag: [] }
  }
}

///|
pub fn CT_TagList::to_element(self : CT_TagList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NormalViewPortion — Part 1 §19.2.2.11
/// restoredLeft / §19.2.2.12 restoredTop. Required `@sz`
/// (a:ST_PositiveFixedPercentage §20.1.10.45, raw lexical form
/// preserved as String); optional `@autoAdjust` (xsd:boolean, default
/// `true`).
pub(all) struct CT_NormalViewPortion {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @sz (a:ST_PositiveFixedPercentage §20.1.10.45) — required lexical form.
  sz : String
  /// @autoAdjust (xsd:boolean, default `true`).
  auto_adjust : Bool?
} derive(Eq, Debug)

///|
pub fn CT_NormalViewPortion::parse(
  element : @xml.Element,
) -> CT_NormalViewPortion raise SchemaViolation {
  let sz = pml_require_attr(element, "sz", "CT_NormalViewPortion/@sz")
  let auto_adjust = pml_optional_bool(
    element, "autoAdjust", "CT_NormalViewPortion/@autoAdjust",
  )
  { element, sz, auto_adjust }
}

///|
pub fn CT_NormalViewPortion::new(
  element : @xml.Element,
) -> CT_NormalViewPortion {
  CT_NormalViewPortion::parse(element) catch {
    _ => { element, sz: "", auto_adjust: None }
  }
}

///|
pub fn CT_NormalViewPortion::to_element(
  self : CT_NormalViewPortion,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NormalViewProperties — Part 1 §19.2.2.6
/// normalViewPr. Required `<restoredLeft>` (CT_NormalViewPortion
/// §19.2.2.11) and `<restoredTop>` (CT_NormalViewPortion §19.2.2.12);
/// optional `<extLst>` (CT_ExtensionList §19.2.1.13). Optional
/// attributes `@showOutlineIcons` (xsd:boolean default `true`),
/// `@snapVertSplitter` (xsd:boolean default `false`), `@vertBarState`
/// (ST_SplitterBarState §19.7.19 default `restored`), `@horzBarState`
/// (ST_SplitterBarState §19.7.19 default `restored`),
/// `@preferSingleView` (xsd:boolean default `false`).
pub(all) struct CT_NormalViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @showOutlineIcons (xsd:boolean, default `true`).
  show_outline_icons : Bool?
  /// @snapVertSplitter (xsd:boolean, default `false`).
  snap_vert_splitter : Bool?
  /// @vertBarState (ST_SplitterBarState §19.7.19, default `restored`).
  vert_bar_state : ST_SplitterBarState?
  /// @horzBarState (ST_SplitterBarState §19.7.19, default `restored`).
  horz_bar_state : ST_SplitterBarState?
  /// @preferSingleView (xsd:boolean, default `false`).
  prefer_single_view : Bool?
  /// <restoredLeft> (CT_NormalViewPortion §19.2.2.11) — required.
  restored_left : CT_NormalViewPortion
  /// <restoredTop> (CT_NormalViewPortion §19.2.2.12) — required.
  restored_top : CT_NormalViewPortion
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_NormalViewProperties::parse(
  element : @xml.Element,
) -> CT_NormalViewProperties raise SchemaViolation {
  let show_outline_icons = pml_optional_bool(
    element, "showOutlineIcons", "CT_NormalViewProperties/@showOutlineIcons",
  )
  let snap_vert_splitter = pml_optional_bool(
    element, "snapVertSplitter", "CT_NormalViewProperties/@snapVertSplitter",
  )
  let vert_bar_state = match pml_attr(element, "vertBarState") {
    Some(v) => Some(ST_SplitterBarState::parse(v))
    None => None
  }
  let horz_bar_state = match pml_attr(element, "horzBarState") {
    Some(v) => Some(ST_SplitterBarState::parse(v))
    None => None
  }
  let prefer_single_view = pml_optional_bool(
    element, "preferSingleView", "CT_NormalViewProperties/@preferSingleView",
  )
  let restored_left = match pml_first_child(element, "restoredLeft") {
    Some(c) => CT_NormalViewPortion::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_NormalViewProperties/<restoredLeft>",
        value="",
        reason="required child missing",
      )
  }
  let restored_top = match pml_first_child(element, "restoredTop") {
    Some(c) => CT_NormalViewPortion::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_NormalViewProperties/<restoredTop>",
        value="",
        reason="required child missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  {
    element,
    show_outline_icons,
    snap_vert_splitter,
    vert_bar_state,
    horz_bar_state,
    prefer_single_view,
    restored_left,
    restored_top,
    ext_lst,
  }
}

///|
pub fn CT_NormalViewProperties::new(
  element : @xml.Element,
) -> CT_NormalViewProperties {
  CT_NormalViewProperties::parse(element) catch {
    _ =>
      {
        element,
        show_outline_icons: None,
        snap_vert_splitter: None,
        vert_bar_state: None,
        horz_bar_state: None,
        prefer_single_view: None,
        restored_left: CT_NormalViewPortion::new(element),
        restored_top: CT_NormalViewPortion::new(element),
        ext_lst: None,
      }
  }
}

///|
pub fn CT_NormalViewProperties::to_element(
  self : CT_NormalViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonViewProperties — Part 1 §19.2.2.2 cViewPr.
/// Required `<scale>` (a:CT_Scale2D §20.1.7.5, DrawingML — raw),
/// `<origin>` (a:CT_Point2D §20.1.2.2.30, DrawingML — raw); optional
/// `@varScale` (xsd:boolean, default `false`).
pub(all) struct CT_CommonViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @varScale (xsd:boolean, default `false`).
  var_scale : Bool?
  /// <scale> (a:CT_Scale2D §20.1.7.5) — required raw element (DrawingML).
  scale : @xml.Element
  /// <origin> (a:CT_Point2D §20.1.2.2.30) — required raw element (DrawingML).
  origin : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommonViewProperties::parse(
  element : @xml.Element,
) -> CT_CommonViewProperties raise SchemaViolation {
  let var_scale = pml_optional_bool(
    element, "varScale", "CT_CommonViewProperties/@varScale",
  )
  let scale = match pml_first_child(element, "scale") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_CommonViewProperties/<scale>",
        value="",
        reason="required child missing",
      )
  }
  let origin = match pml_first_child(element, "origin") {
    Some(c) => c
    None =>
      raise SchemaViolation(
        type_name="CT_CommonViewProperties/<origin>",
        value="",
        reason="required child missing",
      )
  }
  { element, var_scale, scale, origin }
}

///|
pub fn CT_CommonViewProperties::new(
  element : @xml.Element,
) -> CT_CommonViewProperties {
  CT_CommonViewProperties::parse(element) catch {
    _ => { element, var_scale: None, scale: element, origin: element }
  }
}

///|
pub fn CT_CommonViewProperties::to_element(
  self : CT_CommonViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesTextViewProperties — Part 1 §19.2.2.7
/// notesTextViewPr. Required `<cViewPr>` (CT_CommonViewProperties
/// §19.2.2.2); optional `<extLst>` (CT_ExtensionList §19.2.1.13).
pub(all) struct CT_NotesTextViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cViewPr> (CT_CommonViewProperties §19.2.2.2) — required.
  c_view_pr : CT_CommonViewProperties
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_NotesTextViewProperties::parse(
  element : @xml.Element,
) -> CT_NotesTextViewProperties raise SchemaViolation {
  let c_view_pr = match pml_first_child(element, "cViewPr") {
    Some(c) => CT_CommonViewProperties::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_NotesTextViewProperties/<cViewPr>",
        value="",
        reason="required child missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, c_view_pr, ext_lst }
}

///|
pub fn CT_NotesTextViewProperties::new(
  element : @xml.Element,
) -> CT_NotesTextViewProperties {
  CT_NotesTextViewProperties::parse(element) catch {
    _ =>
      {
        element,
        c_view_pr: CT_CommonViewProperties::new(element),
        ext_lst: None,
      }
  }
}

///|
pub fn CT_NotesTextViewProperties::to_element(
  self : CT_NotesTextViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewSlideEntry — Part 1 §19.2.2.14 sld
/// (outline view). Required `@r:id` (ST_RelationshipId); optional
/// `@collapse` (xsd:boolean, default `false`).
pub(all) struct CT_OutlineViewSlideEntry {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
  /// @collapse (xsd:boolean, default `false`).
  collapse : Bool?
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewSlideEntry::parse(
  element : @xml.Element,
) -> CT_OutlineViewSlideEntry raise SchemaViolation {
  let r_id = pml_require_attr(element, "id", "CT_OutlineViewSlideEntry/@r:id")
  let collapse = pml_optional_bool(
    element, "collapse", "CT_OutlineViewSlideEntry/@collapse",
  )
  { element, r_id, collapse }
}

///|
pub fn CT_OutlineViewSlideEntry::new(
  element : @xml.Element,
) -> CT_OutlineViewSlideEntry {
  CT_OutlineViewSlideEntry::parse(element) catch {
    _ => { element, r_id: "", collapse: None }
  }
}

///|
pub fn CT_OutlineViewSlideEntry::to_element(
  self : CT_OutlineViewSlideEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewSlideList — Part 1 §19.2.2.15 sldLst.
/// Zero or more `<sld>` (CT_OutlineViewSlideEntry §19.2.2.14) entries.
pub(all) struct CT_OutlineViewSlideList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sld>* (CT_OutlineViewSlideEntry §19.2.2.14) — zero or more.
  sld : Array[CT_OutlineViewSlideEntry]
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewSlideList::parse(
  element : @xml.Element,
) -> CT_OutlineViewSlideList raise SchemaViolation {
  let sld : Array[CT_OutlineViewSlideEntry] = []
  for child in pml_children(element, "sld") {
    sld.push(CT_OutlineViewSlideEntry::parse(child))
  }
  { element, sld }
}

///|
pub fn CT_OutlineViewSlideList::new(
  element : @xml.Element,
) -> CT_OutlineViewSlideList {
  CT_OutlineViewSlideList::parse(element) catch {
    _ => { element, sld: [] }
  }
}

///|
pub fn CT_OutlineViewSlideList::to_element(
  self : CT_OutlineViewSlideList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewProperties — Part 1 §19.2.2.10
/// outlineViewPr. Required `<cViewPr>` (CT_CommonViewProperties
/// §19.2.2.2); optional `<sldLst>` (CT_OutlineViewSlideList §19.2.2.15),
/// `<extLst>` (CT_ExtensionList §19.2.1.13).
pub(all) struct CT_OutlineViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cViewPr> (CT_CommonViewProperties §19.2.2.2) — required.
  c_view_pr : CT_CommonViewProperties
  /// <sldLst>? (CT_OutlineViewSlideList §19.2.2.15).
  sld_lst : CT_OutlineViewSlideList?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewProperties::parse(
  element : @xml.Element,
) -> CT_OutlineViewProperties raise SchemaViolation {
  let c_view_pr = match pml_first_child(element, "cViewPr") {
    Some(c) => CT_CommonViewProperties::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_OutlineViewProperties/<cViewPr>",
        value="",
        reason="required child missing",
      )
  }
  let sld_lst = match pml_first_child(element, "sldLst") {
    Some(c) => Some(CT_OutlineViewSlideList::parse(c))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, c_view_pr, sld_lst, ext_lst }
}

///|
pub fn CT_OutlineViewProperties::new(
  element : @xml.Element,
) -> CT_OutlineViewProperties {
  CT_OutlineViewProperties::parse(element) catch {
    _ =>
      {
        element,
        c_view_pr: CT_CommonViewProperties::new(element),
        sld_lst: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_OutlineViewProperties::to_element(
  self : CT_OutlineViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSorterViewProperties — Part 1 §19.2.2.17
/// sorterViewPr. Required `<cViewPr>` (CT_CommonViewProperties
/// §19.2.2.2); optional `<extLst>` (CT_ExtensionList §19.2.1.13).
/// Optional `@showFormatting` (xsd:boolean, default `true`).
pub(all) struct CT_SlideSorterViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @showFormatting (xsd:boolean, default `true`).
  show_formatting : Bool?
  /// <cViewPr> (CT_CommonViewProperties §19.2.2.2) — required.
  c_view_pr : CT_CommonViewProperties
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SlideSorterViewProperties::parse(
  element : @xml.Element,
) -> CT_SlideSorterViewProperties raise SchemaViolation {
  let show_formatting = pml_optional_bool(
    element, "showFormatting", "CT_SlideSorterViewProperties/@showFormatting",
  )
  let c_view_pr = match pml_first_child(element, "cViewPr") {
    Some(c) => CT_CommonViewProperties::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_SlideSorterViewProperties/<cViewPr>",
        value="",
        reason="required child missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, show_formatting, c_view_pr, ext_lst }
}

///|
pub fn CT_SlideSorterViewProperties::new(
  element : @xml.Element,
) -> CT_SlideSorterViewProperties {
  CT_SlideSorterViewProperties::parse(element) catch {
    _ =>
      {
        element,
        show_formatting: None,
        c_view_pr: CT_CommonViewProperties::new(element),
        ext_lst: None,
      }
  }
}

///|
pub fn CT_SlideSorterViewProperties::to_element(
  self : CT_SlideSorterViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// Schema pml.xsd complex type CT_Guide — Part 1 §19.2.2.4 guide.
/// A single guide line.  Attributes: `orient`, `pos`.  Optional
/// `@orient` (ST_Direction §19.7.2, default `vert`); optional
/// `@pos` (a:ST_Coordinate32 §20.1.10.18, lexical form preserved as
/// String, default `"0"`).
pub(all) struct CT_Guide {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @orient (ST_Direction §19.7.2, default `vert`).
  orient : ST_Direction?
  /// @pos (a:ST_Coordinate32 §20.1.10.18) — raw lexical form preserved.
  pos : String?
} derive(Eq, Debug)

///|
pub fn CT_Guide::parse(
  element : @xml.Element,
) -> CT_Guide raise SchemaViolation {
  let orient = match pml_attr(element, "orient") {
    Some(v) => Some(ST_Direction::parse(v))
    None => None
  }
  let pos = pml_attr(element, "pos")
  { element, orient, pos }
}

///|
pub fn CT_Guide::new(element : @xml.Element) -> CT_Guide {
  CT_Guide::parse(element) catch {
    _ => { element, orient: None, pos: None }
  }
}

///|
pub fn CT_Guide::to_element(self : CT_Guide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GuideList — Part 1 §19.2.2.5 guideLst. Optional
/// sequence of zero or more `<guide>` (CT_Guide §19.2.2.4) entries.
pub(all) struct CT_GuideList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <guide>* (CT_Guide §19.2.2.4) — zero or more.
  guide : Array[CT_Guide]
} derive(Eq, Debug)

///|
pub fn CT_GuideList::parse(
  element : @xml.Element,
) -> CT_GuideList raise SchemaViolation {
  let guide : Array[CT_Guide] = []
  for child in pml_children(element, "guide") {
    guide.push(CT_Guide::parse(child))
  }
  { element, guide }
}

///|
pub fn CT_GuideList::new(element : @xml.Element) -> CT_GuideList {
  CT_GuideList::parse(element) catch {
    _ => { element, guide: [] }
  }
}

///|
pub fn CT_GuideList::to_element(self : CT_GuideList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonSlideViewProperties — Part 1 §19.2.2.1
/// cSldViewPr. Required `<cViewPr>` (CT_CommonViewProperties §19.2.2.2)
/// and optional `<guideLst>` (CT_GuideList §19.2.2.5). Optional
/// xsd:boolean attributes `@snapToGrid` (default `true`),
/// `@snapToObjects` (default `false`), `@showGuides` (default `false`).
pub(all) struct CT_CommonSlideViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @snapToGrid (xsd:boolean, default `true`).
  snap_to_grid : Bool?
  /// @snapToObjects (xsd:boolean, default `false`).
  snap_to_objects : Bool?
  /// @showGuides (xsd:boolean, default `false`).
  show_guides : Bool?
  /// <cViewPr> (CT_CommonViewProperties §19.2.2.2) — required.
  c_view_pr : CT_CommonViewProperties
  /// <guideLst>? (CT_GuideList §19.2.2.5).
  guide_lst : CT_GuideList?
} derive(Eq, Debug)

///|
pub fn CT_CommonSlideViewProperties::parse(
  element : @xml.Element,
) -> CT_CommonSlideViewProperties raise SchemaViolation {
  let snap_to_grid = pml_optional_bool(
    element, "snapToGrid", "CT_CommonSlideViewProperties/@snapToGrid",
  )
  let snap_to_objects = pml_optional_bool(
    element, "snapToObjects", "CT_CommonSlideViewProperties/@snapToObjects",
  )
  let show_guides = pml_optional_bool(
    element, "showGuides", "CT_CommonSlideViewProperties/@showGuides",
  )
  let c_view_pr = match pml_first_child(element, "cViewPr") {
    Some(c) => CT_CommonViewProperties::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_CommonSlideViewProperties/<cViewPr>",
        value="",
        reason="required child missing",
      )
  }
  let guide_lst = match pml_first_child(element, "guideLst") {
    Some(c) => Some(CT_GuideList::parse(c))
    None => None
  }
  { element, snap_to_grid, snap_to_objects, show_guides, c_view_pr, guide_lst }
}

///|
pub fn CT_CommonSlideViewProperties::new(
  element : @xml.Element,
) -> CT_CommonSlideViewProperties {
  CT_CommonSlideViewProperties::parse(element) catch {
    _ =>
      {
        element,
        snap_to_grid: None,
        snap_to_objects: None,
        show_guides: None,
        c_view_pr: CT_CommonViewProperties::new(element),
        guide_lst: None,
      }
  }
}

///|
pub fn CT_CommonSlideViewProperties::to_element(
  self : CT_CommonSlideViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideViewProperties — Part 1 §19.2.2.16
/// slideViewPr. Required `<cSldViewPr>` (CT_CommonSlideViewProperties
/// §19.2.2.1); optional `<extLst>` (CT_ExtensionList §19.2.1.13).
pub(all) struct CT_SlideViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cSldViewPr> (CT_CommonSlideViewProperties §19.2.2.1) — required.
  c_sld_view_pr : CT_CommonSlideViewProperties
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SlideViewProperties::parse(
  element : @xml.Element,
) -> CT_SlideViewProperties raise SchemaViolation {
  let c_sld_view_pr = match pml_first_child(element, "cSldViewPr") {
    Some(c) => CT_CommonSlideViewProperties::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_SlideViewProperties/<cSldViewPr>",
        value="",
        reason="required child missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, c_sld_view_pr, ext_lst }
}

///|
pub fn CT_SlideViewProperties::new(
  element : @xml.Element,
) -> CT_SlideViewProperties {
  CT_SlideViewProperties::parse(element) catch {
    _ =>
      {
        element,
        c_sld_view_pr: CT_CommonSlideViewProperties::new(element),
        ext_lst: None,
      }
  }
}

///|
pub fn CT_SlideViewProperties::to_element(
  self : CT_SlideViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesViewProperties — Part 1 §19.2.2.8
/// notesViewPr. Required `<cSldViewPr>` (CT_CommonSlideViewProperties
/// §19.2.2.1); optional `<extLst>` (CT_ExtensionList §19.2.1.13).
pub(all) struct CT_NotesViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cSldViewPr> (CT_CommonSlideViewProperties §19.2.2.1) — required.
  c_sld_view_pr : CT_CommonSlideViewProperties
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_NotesViewProperties::parse(
  element : @xml.Element,
) -> CT_NotesViewProperties raise SchemaViolation {
  let c_sld_view_pr = match pml_first_child(element, "cSldViewPr") {
    Some(c) => CT_CommonSlideViewProperties::parse(c)
    None =>
      raise SchemaViolation(
        type_name="CT_NotesViewProperties/<cSldViewPr>",
        value="",
        reason="required child missing",
      )
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  { element, c_sld_view_pr, ext_lst }
}

///|
pub fn CT_NotesViewProperties::new(
  element : @xml.Element,
) -> CT_NotesViewProperties {
  CT_NotesViewProperties::parse(element) catch {
    _ =>
      {
        element,
        c_sld_view_pr: CT_CommonSlideViewProperties::new(element),
        ext_lst: None,
      }
  }
}

///|
pub fn CT_NotesViewProperties::to_element(
  self : CT_NotesViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ViewProperties — Part 1 §19.2.2.18 viewPr.
/// Optional sequence over `<normalViewPr>` (CT_NormalViewProperties
/// §19.2.2.6), `<slideViewPr>` (CT_SlideViewProperties §19.2.2.16),
/// `<outlineViewPr>` (CT_OutlineViewProperties §19.2.2.10),
/// `<notesTextViewPr>` (CT_NotesTextViewProperties §19.2.2.7),
/// `<sorterViewPr>` (CT_SlideSorterViewProperties §19.2.2.17),
/// `<notesViewPr>` (CT_NotesViewProperties §19.2.2.8), `<gridSpacing>`
/// (a:CT_PositiveSize2D §20.1.7.3, DrawingML — raw), `<extLst>`
/// (CT_ExtensionList §19.2.1.13). Optional `@lastView` (ST_ViewType
/// §19.7.55, default `sldView`), `@showComments` (xsd:boolean default `true`).
pub(all) struct CT_ViewProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @lastView (ST_ViewType §19.7.55, default `sldView`).
  last_view : ST_ViewType?
  /// @showComments (xsd:boolean, default `true`).
  show_comments : Bool?
  /// <normalViewPr>? (CT_NormalViewProperties §19.2.2.6).
  normal_view_pr : CT_NormalViewProperties?
  /// <slideViewPr>? (CT_SlideViewProperties §19.2.2.16).
  slide_view_pr : CT_SlideViewProperties?
  /// <outlineViewPr>? (CT_OutlineViewProperties §19.2.2.10).
  outline_view_pr : CT_OutlineViewProperties?
  /// <notesTextViewPr>? (CT_NotesTextViewProperties §19.2.2.7).
  notes_text_view_pr : CT_NotesTextViewProperties?
  /// <sorterViewPr>? (CT_SlideSorterViewProperties §19.2.2.17).
  sorter_view_pr : CT_SlideSorterViewProperties?
  /// <notesViewPr>? (CT_NotesViewProperties §19.2.2.8).
  notes_view_pr : CT_NotesViewProperties?
  /// <gridSpacing>? (a:CT_PositiveSize2D §20.1.7.3) — raw (DrawingML).
  grid_spacing : @xml.Element?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ViewProperties::parse(
  element : @xml.Element,
) -> CT_ViewProperties raise SchemaViolation {
  let last_view = match pml_attr(element, "lastView") {
    Some(v) => Some(ST_ViewType::parse(v))
    None => None
  }
  let show_comments = pml_optional_bool(
    element, "showComments", "CT_ViewProperties/@showComments",
  )
  let normal_view_pr = match pml_first_child(element, "normalViewPr") {
    Some(c) => Some(CT_NormalViewProperties::parse(c))
    None => None
  }
  let slide_view_pr = match pml_first_child(element, "slideViewPr") {
    Some(c) => Some(CT_SlideViewProperties::parse(c))
    None => None
  }
  let outline_view_pr = match pml_first_child(element, "outlineViewPr") {
    Some(c) => Some(CT_OutlineViewProperties::parse(c))
    None => None
  }
  let notes_text_view_pr = match pml_first_child(element, "notesTextViewPr") {
    Some(c) => Some(CT_NotesTextViewProperties::parse(c))
    None => None
  }
  let sorter_view_pr = match pml_first_child(element, "sorterViewPr") {
    Some(c) => Some(CT_SlideSorterViewProperties::parse(c))
    None => None
  }
  let notes_view_pr = match pml_first_child(element, "notesViewPr") {
    Some(c) => Some(CT_NotesViewProperties::parse(c))
    None => None
  }
  let grid_spacing = pml_first_child(element, "gridSpacing")
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  {
    element,
    last_view,
    show_comments,
    normal_view_pr,
    slide_view_pr,
    outline_view_pr,
    notes_text_view_pr,
    sorter_view_pr,
    notes_view_pr,
    grid_spacing,
    ext_lst,
  }
}

///|
pub fn CT_ViewProperties::new(element : @xml.Element) -> CT_ViewProperties {
  CT_ViewProperties::parse(element) catch {
    _ =>
      {
        element,
        last_view: None,
        show_comments: None,
        normal_view_pr: None,
        slide_view_pr: None,
        outline_view_pr: None,
        notes_text_view_pr: None,
        sorter_view_pr: None,
        notes_view_pr: None,
        grid_spacing: None,
        ext_lst: None,
      }
  }
}

///|
pub fn CT_ViewProperties::to_element(self : CT_ViewProperties) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WebProperties — Part 4 §16.3.1.2 webPr.
/// Web-publish configuration. Optional `<extLst>` (CT_ExtensionList
/// §19.2.1.13). Optional attributes: `@showAnimation` (xsd:boolean
/// default `false`), `@resizeGraphics` (xsd:boolean default `true`),
/// `@allowPng` (xsd:boolean default `false`), `@relyOnVml` (xsd:boolean
/// default `false`), `@organizeInFolders` (xsd:boolean default `true`),
/// `@useLongFilenames` (xsd:boolean default `true`), `@imgSz`
/// (ST_WebScreenSize §16.5.x default `800x600`), `@encoding`
/// (ST_WebEncoding xsd:string default `""`), `@clr` (ST_WebColorType
/// §16.5.1 default `whiteTextOnBlack`).
pub(all) struct CT_WebProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @showAnimation (xsd:boolean, default `false`).
  show_animation : Bool?
  /// @resizeGraphics (xsd:boolean, default `true`).
  resize_graphics : Bool?
  /// @allowPng (xsd:boolean, default `false`).
  allow_png : Bool?
  /// @relyOnVml (xsd:boolean, default `false`).
  rely_on_vml : Bool?
  /// @organizeInFolders (xsd:boolean, default `true`).
  organize_in_folders : Bool?
  /// @useLongFilenames (xsd:boolean, default `true`).
  use_long_filenames : Bool?
  /// @imgSz (ST_WebScreenSize, default `800x600`).
  img_sz : ST_WebScreenSize?
  /// @encoding (ST_WebEncoding xsd:string, default `""`).
  encoding : ST_WebEncoding?
  /// @clr (ST_WebColorType §16.5.1, default `whiteTextOnBlack`).
  clr : ST_WebColorType?
  /// <extLst>? (CT_ExtensionList §19.2.1.13).
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_WebProperties::parse(
  element : @xml.Element,
) -> CT_WebProperties raise SchemaViolation {
  let show_animation = pml_optional_bool(
    element, "showAnimation", "CT_WebProperties/@showAnimation",
  )
  let resize_graphics = pml_optional_bool(
    element, "resizeGraphics", "CT_WebProperties/@resizeGraphics",
  )
  let allow_png = pml_optional_bool(
    element, "allowPng", "CT_WebProperties/@allowPng",
  )
  let rely_on_vml = pml_optional_bool(
    element, "relyOnVml", "CT_WebProperties/@relyOnVml",
  )
  let organize_in_folders = pml_optional_bool(
    element, "organizeInFolders", "CT_WebProperties/@organizeInFolders",
  )
  let use_long_filenames = pml_optional_bool(
    element, "useLongFilenames", "CT_WebProperties/@useLongFilenames",
  )
  let img_sz = match pml_attr(element, "imgSz") {
    Some(v) => Some(ST_WebScreenSize::parse(v))
    None => None
  }
  let encoding = match pml_attr(element, "encoding") {
    Some(v) => Some(ST_WebEncoding::parse(v))
    None => None
  }
  let clr = match pml_attr(element, "clr") {
    Some(v) => Some(ST_WebColorType::parse(v))
    None => None
  }
  let ext_lst = match pml_first_child(element, "extLst") {
    Some(c) => Some(CT_ExtensionList::parse(c))
    None => None
  }
  {
    element,
    show_animation,
    resize_graphics,
    allow_png,
    rely_on_vml,
    organize_in_folders,
    use_long_filenames,
    img_sz,
    encoding,
    clr,
    ext_lst,
  }
}

///|
pub fn CT_WebProperties::new(element : @xml.Element) -> CT_WebProperties {
  CT_WebProperties::parse(element) catch {
    _ =>
      {
        element,
        show_animation: None,
        resize_graphics: None,
        allow_png: None,
        rely_on_vml: None,
        organize_in_folders: None,
        use_long_filenames: None,
        img_sz: None,
        encoding: None,
        clr: None,
        ext_lst: None,
      }
  }
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
