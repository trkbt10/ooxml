///|
/// PresentationML domain: presentation, slide, slideLayout, slideMaster, notesMaster, handoutMaster.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/domain"
}

///|
/// XSD complex type CT_Empty from pml.xsd (§19).
pub(all) struct CT_Empty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Empty::new(element : @xml.Element) -> CT_Empty {
  { element, }
}

///|
pub fn CT_Empty::parse(element : @xml.Element) -> CT_Empty {
  CT_Empty::new(element)
}

///|
pub fn CT_Empty::to_element(self : CT_Empty) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_IndexRange from pml.xsd (§19).
pub(all) struct CT_IndexRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_IndexRange::new(element : @xml.Element) -> CT_IndexRange {
  { element, }
}

///|
pub fn CT_IndexRange::parse(element : @xml.Element) -> CT_IndexRange {
  CT_IndexRange::new(element)
}

///|
pub fn CT_IndexRange::to_element(self : CT_IndexRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideRelationshipListEntry from pml.xsd (§19).
pub(all) struct CT_SlideRelationshipListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideRelationshipListEntry::new(
  element : @xml.Element,
) -> CT_SlideRelationshipListEntry {
  { element, }
}

///|
pub fn CT_SlideRelationshipListEntry::parse(
  element : @xml.Element,
) -> CT_SlideRelationshipListEntry {
  CT_SlideRelationshipListEntry::new(element)
}

///|
pub fn CT_SlideRelationshipListEntry::to_element(
  self : CT_SlideRelationshipListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideRelationshipList from pml.xsd (§19).
pub(all) struct CT_SlideRelationshipList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideRelationshipList::new(
  element : @xml.Element,
) -> CT_SlideRelationshipList {
  { element, }
}

///|
pub fn CT_SlideRelationshipList::parse(
  element : @xml.Element,
) -> CT_SlideRelationshipList {
  CT_SlideRelationshipList::new(element)
}

///|
pub fn CT_SlideRelationshipList::to_element(
  self : CT_SlideRelationshipList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShowId from pml.xsd (§19).
pub(all) struct CT_CustomShowId {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomShowId::new(element : @xml.Element) -> CT_CustomShowId {
  { element, }
}

///|
pub fn CT_CustomShowId::parse(element : @xml.Element) -> CT_CustomShowId {
  CT_CustomShowId::new(element)
}

///|
pub fn CT_CustomShowId::to_element(self : CT_CustomShowId) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomerData from pml.xsd (§19).
pub(all) struct CT_CustomerData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomerData::new(element : @xml.Element) -> CT_CustomerData {
  { element, }
}

///|
pub fn CT_CustomerData::parse(element : @xml.Element) -> CT_CustomerData {
  CT_CustomerData::new(element)
}

///|
pub fn CT_CustomerData::to_element(self : CT_CustomerData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TagsData from pml.xsd (§19).
pub(all) struct CT_TagsData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TagsData::new(element : @xml.Element) -> CT_TagsData {
  { element, }
}

///|
pub fn CT_TagsData::parse(element : @xml.Element) -> CT_TagsData {
  CT_TagsData::new(element)
}

///|
pub fn CT_TagsData::to_element(self : CT_TagsData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomerDataList from pml.xsd (§19).
pub(all) struct CT_CustomerDataList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomerDataList::new(element : @xml.Element) -> CT_CustomerDataList {
  { element, }
}

///|
pub fn CT_CustomerDataList::parse(
  element : @xml.Element,
) -> CT_CustomerDataList {
  CT_CustomerDataList::new(element)
}

///|
pub fn CT_CustomerDataList::to_element(
  self : CT_CustomerDataList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Extension from pml.xsd (§19).
pub(all) struct CT_Extension {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Extension::new(element : @xml.Element) -> CT_Extension {
  { element, }
}

///|
pub fn CT_Extension::parse(element : @xml.Element) -> CT_Extension {
  CT_Extension::new(element)
}

///|
pub fn CT_Extension::to_element(self : CT_Extension) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ExtensionList from pml.xsd (§19).
pub(all) struct CT_ExtensionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExtensionList::new(element : @xml.Element) -> CT_ExtensionList {
  { element, }
}

///|
pub fn CT_ExtensionList::parse(element : @xml.Element) -> CT_ExtensionList {
  CT_ExtensionList::new(element)
}

///|
pub fn CT_ExtensionList::to_element(self : CT_ExtensionList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ExtensionListModify from pml.xsd (§19).
pub(all) struct CT_ExtensionListModify {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExtensionListModify::new(
  element : @xml.Element,
) -> CT_ExtensionListModify {
  { element, }
}

///|
pub fn CT_ExtensionListModify::parse(
  element : @xml.Element,
) -> CT_ExtensionListModify {
  CT_ExtensionListModify::new(element)
}

///|
pub fn CT_ExtensionListModify::to_element(
  self : CT_ExtensionListModify,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentAuthor from pml.xsd (§19).
pub(all) struct CT_CommentAuthor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommentAuthor::new(element : @xml.Element) -> CT_CommentAuthor {
  { element, }
}

///|
pub fn CT_CommentAuthor::parse(element : @xml.Element) -> CT_CommentAuthor {
  CT_CommentAuthor::new(element)
}

///|
pub fn CT_CommentAuthor::to_element(self : CT_CommentAuthor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentAuthorList from pml.xsd (§19).
pub(all) struct CT_CommentAuthorList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommentAuthorList::new(
  element : @xml.Element,
) -> CT_CommentAuthorList {
  { element, }
}

///|
pub fn CT_CommentAuthorList::parse(
  element : @xml.Element,
) -> CT_CommentAuthorList {
  CT_CommentAuthorList::new(element)
}

///|
pub fn CT_CommentAuthorList::to_element(
  self : CT_CommentAuthorList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Comment from pml.xsd (§19).
pub(all) struct CT_Comment {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Comment::new(element : @xml.Element) -> CT_Comment {
  { element, }
}

///|
pub fn CT_Comment::parse(element : @xml.Element) -> CT_Comment {
  CT_Comment::new(element)
}

///|
pub fn CT_Comment::to_element(self : CT_Comment) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentList from pml.xsd (§19).
pub(all) struct CT_CommentList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommentList::new(element : @xml.Element) -> CT_CommentList {
  { element, }
}

///|
pub fn CT_CommentList::parse(element : @xml.Element) -> CT_CommentList {
  CT_CommentList::new(element)
}

///|
pub fn CT_CommentList::to_element(self : CT_CommentList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OleObjectEmbed from pml.xsd (§19).
pub(all) struct CT_OleObjectEmbed {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleObjectEmbed::new(element : @xml.Element) -> CT_OleObjectEmbed {
  { element, }
}

///|
pub fn CT_OleObjectEmbed::parse(element : @xml.Element) -> CT_OleObjectEmbed {
  CT_OleObjectEmbed::new(element)
}

///|
pub fn CT_OleObjectEmbed::to_element(self : CT_OleObjectEmbed) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OleObjectLink from pml.xsd (§19).
pub(all) struct CT_OleObjectLink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleObjectLink::new(element : @xml.Element) -> CT_OleObjectLink {
  { element, }
}

///|
pub fn CT_OleObjectLink::parse(element : @xml.Element) -> CT_OleObjectLink {
  CT_OleObjectLink::new(element)
}

///|
pub fn CT_OleObjectLink::to_element(self : CT_OleObjectLink) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OleObject from pml.xsd (§19).
pub(all) struct CT_OleObject {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleObject::new(element : @xml.Element) -> CT_OleObject {
  { element, }
}

///|
pub fn CT_OleObject::parse(element : @xml.Element) -> CT_OleObject {
  CT_OleObject::new(element)
}

///|
pub fn CT_OleObject::to_element(self : CT_OleObject) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Control from pml.xsd (§19).
pub(all) struct CT_Control {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Control::new(element : @xml.Element) -> CT_Control {
  { element, }
}

///|
pub fn CT_Control::parse(element : @xml.Element) -> CT_Control {
  CT_Control::new(element)
}

///|
pub fn CT_Control::to_element(self : CT_Control) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ControlList from pml.xsd (§19).
pub(all) struct CT_ControlList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ControlList::new(element : @xml.Element) -> CT_ControlList {
  { element, }
}

///|
pub fn CT_ControlList::parse(element : @xml.Element) -> CT_ControlList {
  CT_ControlList::new(element)
}

///|
pub fn CT_ControlList::to_element(self : CT_ControlList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideIdListEntry from pml.xsd (§19).
pub(all) struct CT_SlideIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideIdListEntry::new(element : @xml.Element) -> CT_SlideIdListEntry {
  { element, }
}

///|
pub fn CT_SlideIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideIdListEntry {
  CT_SlideIdListEntry::new(element)
}

///|
pub fn CT_SlideIdListEntry::to_element(
  self : CT_SlideIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideIdList from pml.xsd (§19).
pub(all) struct CT_SlideIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideIdList::new(element : @xml.Element) -> CT_SlideIdList {
  { element, }
}

///|
pub fn CT_SlideIdList::parse(element : @xml.Element) -> CT_SlideIdList {
  CT_SlideIdList::new(element)
}

///|
pub fn CT_SlideIdList::to_element(self : CT_SlideIdList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterIdListEntry from pml.xsd (§19).
pub(all) struct CT_SlideMasterIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_SlideMasterIdListEntry {
  { element, }
}

///|
pub fn CT_SlideMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideMasterIdListEntry {
  CT_SlideMasterIdListEntry::new(element)
}

///|
pub fn CT_SlideMasterIdListEntry::to_element(
  self : CT_SlideMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterIdList from pml.xsd (§19).
pub(all) struct CT_SlideMasterIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterIdList::new(
  element : @xml.Element,
) -> CT_SlideMasterIdList {
  { element, }
}

///|
pub fn CT_SlideMasterIdList::parse(
  element : @xml.Element,
) -> CT_SlideMasterIdList {
  CT_SlideMasterIdList::new(element)
}

///|
pub fn CT_SlideMasterIdList::to_element(
  self : CT_SlideMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMasterIdListEntry from pml.xsd (§19).
pub(all) struct CT_NotesMasterIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_NotesMasterIdListEntry {
  { element, }
}

///|
pub fn CT_NotesMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_NotesMasterIdListEntry {
  CT_NotesMasterIdListEntry::new(element)
}

///|
pub fn CT_NotesMasterIdListEntry::to_element(
  self : CT_NotesMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMasterIdList from pml.xsd (§19).
pub(all) struct CT_NotesMasterIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesMasterIdList::new(
  element : @xml.Element,
) -> CT_NotesMasterIdList {
  { element, }
}

///|
pub fn CT_NotesMasterIdList::parse(
  element : @xml.Element,
) -> CT_NotesMasterIdList {
  CT_NotesMasterIdList::new(element)
}

///|
pub fn CT_NotesMasterIdList::to_element(
  self : CT_NotesMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMasterIdListEntry from pml.xsd (§19).
pub(all) struct CT_HandoutMasterIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HandoutMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_HandoutMasterIdListEntry {
  { element, }
}

///|
pub fn CT_HandoutMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_HandoutMasterIdListEntry {
  CT_HandoutMasterIdListEntry::new(element)
}

///|
pub fn CT_HandoutMasterIdListEntry::to_element(
  self : CT_HandoutMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMasterIdList from pml.xsd (§19).
pub(all) struct CT_HandoutMasterIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HandoutMasterIdList::new(
  element : @xml.Element,
) -> CT_HandoutMasterIdList {
  { element, }
}

///|
pub fn CT_HandoutMasterIdList::parse(
  element : @xml.Element,
) -> CT_HandoutMasterIdList {
  CT_HandoutMasterIdList::new(element)
}

///|
pub fn CT_HandoutMasterIdList::to_element(
  self : CT_HandoutMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontDataId from pml.xsd (§19).
pub(all) struct CT_EmbeddedFontDataId {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontDataId::new(
  element : @xml.Element,
) -> CT_EmbeddedFontDataId {
  { element, }
}

///|
pub fn CT_EmbeddedFontDataId::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontDataId {
  CT_EmbeddedFontDataId::new(element)
}

///|
pub fn CT_EmbeddedFontDataId::to_element(
  self : CT_EmbeddedFontDataId,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontListEntry from pml.xsd (§19).
pub(all) struct CT_EmbeddedFontListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontListEntry::new(
  element : @xml.Element,
) -> CT_EmbeddedFontListEntry {
  { element, }
}

///|
pub fn CT_EmbeddedFontListEntry::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontListEntry {
  CT_EmbeddedFontListEntry::new(element)
}

///|
pub fn CT_EmbeddedFontListEntry::to_element(
  self : CT_EmbeddedFontListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontList from pml.xsd (§19).
pub(all) struct CT_EmbeddedFontList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontList::new(element : @xml.Element) -> CT_EmbeddedFontList {
  { element, }
}

///|
pub fn CT_EmbeddedFontList::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontList {
  CT_EmbeddedFontList::new(element)
}

///|
pub fn CT_EmbeddedFontList::to_element(
  self : CT_EmbeddedFontList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTags from pml.xsd (§19).
pub(all) struct CT_SmartTags {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTags::new(element : @xml.Element) -> CT_SmartTags {
  { element, }
}

///|
pub fn CT_SmartTags::parse(element : @xml.Element) -> CT_SmartTags {
  CT_SmartTags::new(element)
}

///|
pub fn CT_SmartTags::to_element(self : CT_SmartTags) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShow from pml.xsd (§19).
pub(all) struct CT_CustomShow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomShow::new(element : @xml.Element) -> CT_CustomShow {
  { element, }
}

///|
pub fn CT_CustomShow::parse(element : @xml.Element) -> CT_CustomShow {
  CT_CustomShow::new(element)
}

///|
pub fn CT_CustomShow::to_element(self : CT_CustomShow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShowList from pml.xsd (§19).
pub(all) struct CT_CustomShowList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomShowList::new(element : @xml.Element) -> CT_CustomShowList {
  { element, }
}

///|
pub fn CT_CustomShowList::parse(element : @xml.Element) -> CT_CustomShowList {
  CT_CustomShowList::new(element)
}

///|
pub fn CT_CustomShowList::to_element(self : CT_CustomShowList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PhotoAlbum from pml.xsd (§19).
pub(all) struct CT_PhotoAlbum {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PhotoAlbum::new(element : @xml.Element) -> CT_PhotoAlbum {
  { element, }
}

///|
pub fn CT_PhotoAlbum::parse(element : @xml.Element) -> CT_PhotoAlbum {
  CT_PhotoAlbum::new(element)
}

///|
pub fn CT_PhotoAlbum::to_element(self : CT_PhotoAlbum) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSize from pml.xsd (§19).
pub(all) struct CT_SlideSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideSize::new(element : @xml.Element) -> CT_SlideSize {
  { element, }
}

///|
pub fn CT_SlideSize::parse(element : @xml.Element) -> CT_SlideSize {
  CT_SlideSize::new(element)
}

///|
pub fn CT_SlideSize::to_element(self : CT_SlideSize) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Kinsoku from pml.xsd (§19).
pub(all) struct CT_Kinsoku {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Kinsoku::new(element : @xml.Element) -> CT_Kinsoku {
  { element, }
}

///|
pub fn CT_Kinsoku::parse(element : @xml.Element) -> CT_Kinsoku {
  CT_Kinsoku::new(element)
}

///|
pub fn CT_Kinsoku::to_element(self : CT_Kinsoku) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ModifyVerifier from pml.xsd (§19).
pub(all) struct CT_ModifyVerifier {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ModifyVerifier::new(element : @xml.Element) -> CT_ModifyVerifier {
  { element, }
}

///|
pub fn CT_ModifyVerifier::parse(element : @xml.Element) -> CT_ModifyVerifier {
  CT_ModifyVerifier::new(element)
}

///|
pub fn CT_ModifyVerifier::to_element(self : CT_ModifyVerifier) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Presentation from pml.xsd (§19).
pub(all) struct CT_Presentation {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Presentation::new(element : @xml.Element) -> CT_Presentation {
  { element, }
}

///|
pub fn CT_Presentation::parse(element : @xml.Element) -> CT_Presentation {
  CT_Presentation::new(element)
}

///|
pub fn CT_Presentation::to_element(self : CT_Presentation) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HtmlPublishProperties from pml.xsd (§19).
pub(all) struct CT_HtmlPublishProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HtmlPublishProperties::new(
  element : @xml.Element,
) -> CT_HtmlPublishProperties {
  { element, }
}

///|
pub fn CT_HtmlPublishProperties::parse(
  element : @xml.Element,
) -> CT_HtmlPublishProperties {
  CT_HtmlPublishProperties::new(element)
}

///|
pub fn CT_HtmlPublishProperties::to_element(
  self : CT_HtmlPublishProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PrintProperties from pml.xsd (§19).
pub(all) struct CT_PrintProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PrintProperties::new(element : @xml.Element) -> CT_PrintProperties {
  { element, }
}

///|
pub fn CT_PrintProperties::parse(element : @xml.Element) -> CT_PrintProperties {
  CT_PrintProperties::new(element)
}

///|
pub fn CT_PrintProperties::to_element(
  self : CT_PrintProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShowInfoBrowse from pml.xsd (§19).
pub(all) struct CT_ShowInfoBrowse {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShowInfoBrowse::new(element : @xml.Element) -> CT_ShowInfoBrowse {
  { element, }
}

///|
pub fn CT_ShowInfoBrowse::parse(element : @xml.Element) -> CT_ShowInfoBrowse {
  CT_ShowInfoBrowse::new(element)
}

///|
pub fn CT_ShowInfoBrowse::to_element(self : CT_ShowInfoBrowse) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShowInfoKiosk from pml.xsd (§19).
pub(all) struct CT_ShowInfoKiosk {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShowInfoKiosk::new(element : @xml.Element) -> CT_ShowInfoKiosk {
  { element, }
}

///|
pub fn CT_ShowInfoKiosk::parse(element : @xml.Element) -> CT_ShowInfoKiosk {
  CT_ShowInfoKiosk::new(element)
}

///|
pub fn CT_ShowInfoKiosk::to_element(self : CT_ShowInfoKiosk) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShowProperties from pml.xsd (§19).
pub(all) struct CT_ShowProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShowProperties::new(element : @xml.Element) -> CT_ShowProperties {
  { element, }
}

///|
pub fn CT_ShowProperties::parse(element : @xml.Element) -> CT_ShowProperties {
  CT_ShowProperties::new(element)
}

///|
pub fn CT_ShowProperties::to_element(self : CT_ShowProperties) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresentationProperties from pml.xsd (§19).
pub(all) struct CT_PresentationProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresentationProperties::new(
  element : @xml.Element,
) -> CT_PresentationProperties {
  { element, }
}

///|
pub fn CT_PresentationProperties::parse(
  element : @xml.Element,
) -> CT_PresentationProperties {
  CT_PresentationProperties::new(element)
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
