///|
/// SpreadsheetML metadata external types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn metadata_external_type_group_name() -> String {
  "spreadsheet_ml.metadata_external"
}

///|
/// XSD complex type CT_MapInfo.
pub(all) struct CT_MapInfo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MapInfo::new(element : @xml.Element) -> CT_MapInfo {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Schema.
pub(all) struct CT_Schema {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Schema::new(element : @xml.Element) -> CT_Schema {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Map: custom XML map with DataBinding child and ID, Name, RootElement, SchemaID, import/export validation attributes.
pub(all) struct CT_Map {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Map::new(element : @xml.Element) -> CT_Map {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Boolean.
pub(all) struct CT_Boolean {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Boolean::new(element : @xml.Element) -> CT_Boolean {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetIdMap.
pub(all) struct CT_SheetIdMap {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetIdMap::new(element : @xml.Element) -> CT_SheetIdMap {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_OleObjects.
pub(all) struct CT_OleObjects {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleObjects::new(element : @xml.Element) -> CT_OleObjects {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_OleObject.
pub(all) struct CT_OleObject {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleObject::new(element : @xml.Element) -> CT_OleObject {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Metadata.
pub(all) struct CT_Metadata {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Metadata::new(element : @xml.Element) -> CT_Metadata {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MetadataTypes.
pub(all) struct CT_MetadataTypes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MetadataTypes::new(element : @xml.Element) -> CT_MetadataTypes {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MetadataType.
pub(all) struct CT_MetadataType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MetadataType::new(element : @xml.Element) -> CT_MetadataType {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MetadataBlocks.
pub(all) struct CT_MetadataBlocks {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MetadataBlocks::new(element : @xml.Element) -> CT_MetadataBlocks {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MetadataBlock.
pub(all) struct CT_MetadataBlock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MetadataBlock::new(element : @xml.Element) -> CT_MetadataBlock {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MetadataRecord.
pub(all) struct CT_MetadataRecord {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MetadataRecord::new(element : @xml.Element) -> CT_MetadataRecord {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FutureMetadata.
pub(all) struct CT_FutureMetadata {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FutureMetadata::new(element : @xml.Element) -> CT_FutureMetadata {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FutureMetadataBlock.
pub(all) struct CT_FutureMetadataBlock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FutureMetadataBlock::new(
  element : @xml.Element,
) -> CT_FutureMetadataBlock {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MetadataStringIndex.
pub(all) struct CT_MetadataStringIndex {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MetadataStringIndex::new(
  element : @xml.Element,
) -> CT_MetadataStringIndex {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MetadataStrings.
pub(all) struct CT_MetadataStrings {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MetadataStrings::new(element : @xml.Element) -> CT_MetadataStrings {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SingleXmlCells.
pub(all) struct CT_SingleXmlCells {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SingleXmlCells::new(element : @xml.Element) -> CT_SingleXmlCells {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SingleXmlCell.
pub(all) struct CT_SingleXmlCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SingleXmlCell::new(element : @xml.Element) -> CT_SingleXmlCell {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_XmlCellPr.
pub(all) struct CT_XmlCellPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_XmlCellPr::new(element : @xml.Element) -> CT_XmlCellPr {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_XmlPr.
pub(all) struct CT_XmlPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_XmlPr::new(element : @xml.Element) -> CT_XmlPr {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalLink.
pub(all) struct CT_ExternalLink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalLink::new(element : @xml.Element) -> CT_ExternalLink {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalBook.
pub(all) struct CT_ExternalBook {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalBook::new(element : @xml.Element) -> CT_ExternalBook {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalSheetNames.
pub(all) struct CT_ExternalSheetNames {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalSheetNames::new(
  element : @xml.Element,
) -> CT_ExternalSheetNames {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalSheetName.
pub(all) struct CT_ExternalSheetName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalSheetName::new(
  element : @xml.Element,
) -> CT_ExternalSheetName {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalDefinedNames.
pub(all) struct CT_ExternalDefinedNames {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalDefinedNames::new(
  element : @xml.Element,
) -> CT_ExternalDefinedNames {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalDefinedName.
pub(all) struct CT_ExternalDefinedName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalDefinedName::new(
  element : @xml.Element,
) -> CT_ExternalDefinedName {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalSheetData.
pub(all) struct CT_ExternalSheetData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalSheetData::new(
  element : @xml.Element,
) -> CT_ExternalSheetData {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalRow.
pub(all) struct CT_ExternalRow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalRow::new(element : @xml.Element) -> CT_ExternalRow {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalCell.
pub(all) struct CT_ExternalCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalCell::new(element : @xml.Element) -> CT_ExternalCell {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DdeLink.
pub(all) struct CT_DdeLink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DdeLink::new(element : @xml.Element) -> CT_DdeLink {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DdeItems.
pub(all) struct CT_DdeItems {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DdeItems::new(element : @xml.Element) -> CT_DdeItems {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DdeItem. DDE item definition with attributes `name`,
/// `ole`, `advise`, and `preferPic`, and optional `values` child element of
/// type CT_DdeValues.
pub(all) struct CT_DdeItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DdeItem::new(element : @xml.Element) -> CT_DdeItem {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DdeValues.
pub(all) struct CT_DdeValues {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DdeValues::new(element : @xml.Element) -> CT_DdeValues {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DdeValue.
pub(all) struct CT_DdeValue {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DdeValue::new(element : @xml.Element) -> CT_DdeValue {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_OleLink.
pub(all) struct CT_OleLink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleLink::new(element : @xml.Element) -> CT_OleLink {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_OleItems.
pub(all) struct CT_OleItems {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleItems::new(element : @xml.Element) -> CT_OleItems {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_OleItem.
pub(all) struct CT_OleItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleItem::new(element : @xml.Element) -> CT_OleItem {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_XmlColumnPr.
pub(all) struct CT_XmlColumnPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_XmlColumnPr::new(element : @xml.Element) -> CT_XmlColumnPr {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_VolTypes.
pub(all) struct CT_VolTypes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VolTypes::new(element : @xml.Element) -> CT_VolTypes {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_VolType.
pub(all) struct CT_VolType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VolType::new(element : @xml.Element) -> CT_VolType {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_VolMain.
pub(all) struct CT_VolMain {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VolMain::new(element : @xml.Element) -> CT_VolMain {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_VolTopic.
pub(all) struct CT_VolTopic {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VolTopic::new(element : @xml.Element) -> CT_VolTopic {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_VolTopicRef.
pub(all) struct CT_VolTopicRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VolTopicRef::new(element : @xml.Element) -> CT_VolTopicRef {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalReferences.
pub(all) struct CT_ExternalReferences {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalReferences::new(
  element : @xml.Element,
) -> CT_ExternalReferences {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalReference.
pub(all) struct CT_ExternalReference {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalReference::new(
  element : @xml.Element,
) -> CT_ExternalReference {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_OleSize.
pub(all) struct CT_OleSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleSize::new(element : @xml.Element) -> CT_OleSize {
  let group_name = metadata_external_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}
