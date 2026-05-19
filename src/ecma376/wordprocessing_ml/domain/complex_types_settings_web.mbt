///|
/// XSD complex type CT_RecipientData — Part 1 §17.14.30 (recipientData
/// Mail Merge Single Recipient Data). Sequence: optional `<w:active>`
/// (CT_OnOff per §17.17.4) marking whether the recipient is selected,
/// required `<w:column>` (CT_DecimalNumber per §17.18.10) naming the
/// data-source column index and required `<w:uniqueTag>`
/// (CT_Base64Binary per §17.14.31) carrying the recipient's unique
/// identifier as a base64 binary value.
pub(all) struct CT_RecipientData {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.17.4 `<w:active>` (CT_OnOff) — optional selected-flag child.
  active : CT_OnOff?
  /// §17.18.10 `<w:column>` (CT_DecimalNumber) — required column index.
  column : CT_DecimalNumber
  /// §17.14.31 `<w:uniqueTag>` (CT_Base64Binary) — required unique identifier.
  unique_tag : CT_Base64Binary
} derive(Eq, Debug)

///|
/// XSD complex type CT_RecipientData — Part 1 §17.14.30. Decode the
/// optional `<w:active>` and both required children, raising
/// SchemaViolation when either required child is absent or invalid.
pub fn CT_RecipientData::new(
  element : @xml.Element,
) -> CT_RecipientData raise SchemaViolation {
  let active = match wml_ct_chunk2_first_child(element, "active") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let column = match wml_ct_chunk2_first_child(element, "column") {
    Some(child) => CT_DecimalNumber::new(child)
    None =>
      raise_schema_violation(
        "CT_RecipientData", "column", "Part 1 §17.14.30: required child <w:column> is missing",
      )
  }
  let unique_tag = match wml_ct_chunk2_first_child(element, "uniqueTag") {
    Some(child) => CT_Base64Binary::new(child)
    None =>
      raise_schema_violation(
        "CT_RecipientData", "uniqueTag", "Part 1 §17.14.30: required child <w:uniqueTag> is missing",
      )
  }
  { element, active, column, unique_tag }
}

///|
/// XSD complex type CT_RecipientData — Part 1 §17.14.30.
pub fn CT_RecipientData::parse(
  element : @xml.Element,
) -> CT_RecipientData raise SchemaViolation {
  CT_RecipientData::new(element)
}

///|
pub fn CT_RecipientData::to_element(self : CT_RecipientData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Recipients — Part 1 §17.14.31 (recipients Mail
/// Merge Recipient Information). Sequence container holding one or
/// more `<w:recipientData>` children (CT_RecipientData per §17.14.30).
pub(all) struct CT_Recipients {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.14.30 `<w:recipientData>` (CT_RecipientData)+ — recipient entries.
  recipient_data : Array[CT_RecipientData]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Recipients — Part 1 §17.14.31. Decode each
/// `<w:recipientData>` child, propagating SchemaViolation from the
/// typed CT_RecipientData constructor.
pub fn CT_Recipients::new(
  element : @xml.Element,
) -> CT_Recipients raise SchemaViolation {
  let recipient_data : Array[CT_RecipientData] = []
  for child in wml_ct_chunk2_children(element, "recipientData") {
    recipient_data.push(CT_RecipientData::new(child))
  }
  { element, recipient_data }
}

///|
/// XSD complex type CT_Recipients — Part 1 §17.14.31.
pub fn CT_Recipients::parse(
  element : @xml.Element,
) -> CT_Recipients raise SchemaViolation {
  CT_Recipients::new(element)
}

///|
pub fn CT_Recipients::to_element(self : CT_Recipients) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OdsoFieldMapData from wml.xsd (§17).
pub(all) struct CT_OdsoFieldMapData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OdsoFieldMapData::new(element : @xml.Element) -> CT_OdsoFieldMapData {
  { element, }
}

///|
pub fn CT_OdsoFieldMapData::parse(
  element : @xml.Element,
) -> CT_OdsoFieldMapData {
  CT_OdsoFieldMapData::new(element)
}

///|
pub fn CT_OdsoFieldMapData::to_element(
  self : CT_OdsoFieldMapData,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeSourceType from wml.xsd (§17).
pub(all) struct CT_MailMergeSourceType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MailMergeSourceType::new(
  element : @xml.Element,
) -> CT_MailMergeSourceType {
  { element, }
}

///|
pub fn CT_MailMergeSourceType::parse(
  element : @xml.Element,
) -> CT_MailMergeSourceType {
  CT_MailMergeSourceType::new(element)
}

///|
pub fn CT_MailMergeSourceType::to_element(
  self : CT_MailMergeSourceType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Odso from wml.xsd (§17).
pub(all) struct CT_Odso {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Odso::new(element : @xml.Element) -> CT_Odso {
  { element, }
}

///|
pub fn CT_Odso::parse(element : @xml.Element) -> CT_Odso {
  CT_Odso::new(element)
}

///|
pub fn CT_Odso::to_element(self : CT_Odso) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMerge from wml.xsd (§17).
pub(all) struct CT_MailMerge {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MailMerge::new(element : @xml.Element) -> CT_MailMerge {
  { element, }
}

///|
pub fn CT_MailMerge::parse(element : @xml.Element) -> CT_MailMerge {
  CT_MailMerge::new(element)
}

///|
pub fn CT_MailMerge::to_element(self : CT_MailMerge) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TargetScreenSz from wml.xsd (§17).
pub(all) struct CT_TargetScreenSz {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TargetScreenSz::new(element : @xml.Element) -> CT_TargetScreenSz {
  { element, }
}

///|
pub fn CT_TargetScreenSz::parse(element : @xml.Element) -> CT_TargetScreenSz {
  CT_TargetScreenSz::new(element)
}

///|
pub fn CT_TargetScreenSz::to_element(self : CT_TargetScreenSz) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Compat from wml.xsd (§17).
pub(all) struct CT_Compat {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Compat::new(element : @xml.Element) -> CT_Compat {
  { element, }
}

///|
pub fn CT_Compat::parse(element : @xml.Element) -> CT_Compat {
  CT_Compat::new(element)
}

///|
pub fn CT_Compat::to_element(self : CT_Compat) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CompatSetting from wml.xsd (§17).
pub(all) struct CT_CompatSetting {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CompatSetting::new(element : @xml.Element) -> CT_CompatSetting {
  { element, }
}

///|
pub fn CT_CompatSetting::parse(element : @xml.Element) -> CT_CompatSetting {
  CT_CompatSetting::new(element)
}

///|
pub fn CT_CompatSetting::to_element(self : CT_CompatSetting) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocVar from wml.xsd (§17).
pub(all) struct CT_DocVar {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocVar::new(element : @xml.Element) -> CT_DocVar {
  { element, }
}

///|
pub fn CT_DocVar::parse(element : @xml.Element) -> CT_DocVar {
  CT_DocVar::new(element)
}

///|
pub fn CT_DocVar::to_element(self : CT_DocVar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocVars from wml.xsd (§17).
pub(all) struct CT_DocVars {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocVars::new(element : @xml.Element) -> CT_DocVars {
  { element, }
}

///|
pub fn CT_DocVars::parse(element : @xml.Element) -> CT_DocVars {
  CT_DocVars::new(element)
}

///|
pub fn CT_DocVars::to_element(self : CT_DocVars) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocRsids from wml.xsd (§17).
pub(all) struct CT_DocRsids {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocRsids::new(element : @xml.Element) -> CT_DocRsids {
  { element, }
}

///|
pub fn CT_DocRsids::parse(element : @xml.Element) -> CT_DocRsids {
  CT_DocRsids::new(element)
}

///|
pub fn CT_DocRsids::to_element(self : CT_DocRsids) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CharacterSpacing from wml.xsd (§17).
pub(all) struct CT_CharacterSpacing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CharacterSpacing::new(element : @xml.Element) -> CT_CharacterSpacing {
  { element, }
}

///|
pub fn CT_CharacterSpacing::parse(
  element : @xml.Element,
) -> CT_CharacterSpacing {
  CT_CharacterSpacing::new(element)
}

///|
pub fn CT_CharacterSpacing::to_element(
  self : CT_CharacterSpacing,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SaveThroughXslt from wml.xsd (§17).
pub(all) struct CT_SaveThroughXslt {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SaveThroughXslt::new(element : @xml.Element) -> CT_SaveThroughXslt {
  { element, }
}

///|
pub fn CT_SaveThroughXslt::parse(element : @xml.Element) -> CT_SaveThroughXslt {
  CT_SaveThroughXslt::new(element)
}

///|
pub fn CT_SaveThroughXslt::to_element(
  self : CT_SaveThroughXslt,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorSchemeMapping from wml.xsd (§17).
pub(all) struct CT_ColorSchemeMapping {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorSchemeMapping::new(
  element : @xml.Element,
) -> CT_ColorSchemeMapping {
  { element, }
}

///|
pub fn CT_ColorSchemeMapping::parse(
  element : @xml.Element,
) -> CT_ColorSchemeMapping {
  CT_ColorSchemeMapping::new(element)
}

///|
pub fn CT_ColorSchemeMapping::to_element(
  self : CT_ColorSchemeMapping,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ReadingModeInkLockDown from wml.xsd (§17).
pub(all) struct CT_ReadingModeInkLockDown {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ReadingModeInkLockDown::new(
  element : @xml.Element,
) -> CT_ReadingModeInkLockDown {
  { element, }
}

///|
pub fn CT_ReadingModeInkLockDown::parse(
  element : @xml.Element,
) -> CT_ReadingModeInkLockDown {
  CT_ReadingModeInkLockDown::new(element)
}

///|
pub fn CT_ReadingModeInkLockDown::to_element(
  self : CT_ReadingModeInkLockDown,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WriteProtection from wml.xsd (§17).
pub(all) struct CT_WriteProtection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WriteProtection::new(element : @xml.Element) -> CT_WriteProtection {
  { element, }
}

///|
pub fn CT_WriteProtection::parse(element : @xml.Element) -> CT_WriteProtection {
  CT_WriteProtection::new(element)
}

///|
pub fn CT_WriteProtection::to_element(
  self : CT_WriteProtection,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Settings from wml.xsd (§17).
pub(all) struct CT_Settings {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Settings::new(element : @xml.Element) -> CT_Settings {
  { element, }
}

///|
pub fn CT_Settings::parse(element : @xml.Element) -> CT_Settings {
  CT_Settings::new(element)
}

///|
pub fn CT_Settings::to_element(self : CT_Settings) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WebSettings from wml.xsd (§17).
pub(all) struct CT_WebSettings {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebSettings::new(element : @xml.Element) -> CT_WebSettings {
  { element, }
}

///|
pub fn CT_WebSettings::parse(element : @xml.Element) -> CT_WebSettings {
  CT_WebSettings::new(element)
}

///|
pub fn CT_WebSettings::to_element(self : CT_WebSettings) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FrameScrollbar from wml.xsd (§17).
pub(all) struct CT_FrameScrollbar {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FrameScrollbar::new(element : @xml.Element) -> CT_FrameScrollbar {
  { element, }
}

///|
pub fn CT_FrameScrollbar::parse(element : @xml.Element) -> CT_FrameScrollbar {
  CT_FrameScrollbar::new(element)
}

///|
pub fn CT_FrameScrollbar::to_element(self : CT_FrameScrollbar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OptimizeForBrowser from wml.xsd (§17).
pub(all) struct CT_OptimizeForBrowser {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OptimizeForBrowser::new(
  element : @xml.Element,
) -> CT_OptimizeForBrowser {
  { element, }
}

///|
pub fn CT_OptimizeForBrowser::parse(
  element : @xml.Element,
) -> CT_OptimizeForBrowser {
  CT_OptimizeForBrowser::new(element)
}

///|
pub fn CT_OptimizeForBrowser::to_element(
  self : CT_OptimizeForBrowser,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Frame from wml.xsd (§17).
pub(all) struct CT_Frame {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Frame::new(element : @xml.Element) -> CT_Frame {
  { element, }
}

///|
pub fn CT_Frame::parse(element : @xml.Element) -> CT_Frame {
  CT_Frame::new(element)
}

///|
pub fn CT_Frame::to_element(self : CT_Frame) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FrameLayout from wml.xsd (§17).
pub(all) struct CT_FrameLayout {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FrameLayout::new(element : @xml.Element) -> CT_FrameLayout {
  { element, }
}

///|
pub fn CT_FrameLayout::parse(element : @xml.Element) -> CT_FrameLayout {
  CT_FrameLayout::new(element)
}

///|
pub fn CT_FrameLayout::to_element(self : CT_FrameLayout) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FramesetSplitbar from wml.xsd (§17).
pub(all) struct CT_FramesetSplitbar {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FramesetSplitbar::new(element : @xml.Element) -> CT_FramesetSplitbar {
  { element, }
}

///|
pub fn CT_FramesetSplitbar::parse(
  element : @xml.Element,
) -> CT_FramesetSplitbar {
  CT_FramesetSplitbar::new(element)
}

///|
pub fn CT_FramesetSplitbar::to_element(
  self : CT_FramesetSplitbar,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Frameset from wml.xsd (§17).
pub(all) struct CT_Frameset {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Frameset::new(element : @xml.Element) -> CT_Frameset {
  { element, }
}

///|
pub fn CT_Frameset::parse(element : @xml.Element) -> CT_Frameset {
  CT_Frameset::new(element)
}

///|
pub fn CT_Frameset::to_element(self : CT_Frameset) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DivBdr from wml.xsd (§17).
pub(all) struct CT_DivBdr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DivBdr::new(element : @xml.Element) -> CT_DivBdr {
  { element, }
}

///|
pub fn CT_DivBdr::parse(element : @xml.Element) -> CT_DivBdr {
  CT_DivBdr::new(element)
}

///|
pub fn CT_DivBdr::to_element(self : CT_DivBdr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Div from wml.xsd (§17).
pub(all) struct CT_Div {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Div::new(element : @xml.Element) -> CT_Div {
  { element, }
}

///|
pub fn CT_Div::parse(element : @xml.Element) -> CT_Div {
  CT_Div::new(element)
}

///|
pub fn CT_Div::to_element(self : CT_Div) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Divs from wml.xsd (§17).
pub(all) struct CT_Divs {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Divs::new(element : @xml.Element) -> CT_Divs {
  { element, }
}

///|
pub fn CT_Divs::parse(element : @xml.Element) -> CT_Divs {
  CT_Divs::new(element)
}

///|
pub fn CT_Divs::to_element(self : CT_Divs) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Caption from wml.xsd (§17).
pub(all) struct CT_Caption {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Caption::new(element : @xml.Element) -> CT_Caption {
  { element, }
}

///|
pub fn CT_Caption::parse(element : @xml.Element) -> CT_Caption {
  CT_Caption::new(element)
}

///|
pub fn CT_Caption::to_element(self : CT_Caption) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AutoCaption from wml.xsd (§17).
pub(all) struct CT_AutoCaption {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AutoCaption::new(element : @xml.Element) -> CT_AutoCaption {
  { element, }
}

///|
pub fn CT_AutoCaption::parse(element : @xml.Element) -> CT_AutoCaption {
  CT_AutoCaption::new(element)
}

///|
pub fn CT_AutoCaption::to_element(self : CT_AutoCaption) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AutoCaptions from wml.xsd (§17).
pub(all) struct CT_AutoCaptions {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AutoCaptions::new(element : @xml.Element) -> CT_AutoCaptions {
  { element, }
}

///|
pub fn CT_AutoCaptions::parse(element : @xml.Element) -> CT_AutoCaptions {
  CT_AutoCaptions::new(element)
}

///|
pub fn CT_AutoCaptions::to_element(self : CT_AutoCaptions) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Captions from wml.xsd (§17).
pub(all) struct CT_Captions {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Captions::new(element : @xml.Element) -> CT_Captions {
  { element, }
}

///|
pub fn CT_Captions::parse(element : @xml.Element) -> CT_Captions {
  CT_Captions::new(element)
}

///|
pub fn CT_Captions::to_element(self : CT_Captions) -> @xml.Element {
  self.element
}
