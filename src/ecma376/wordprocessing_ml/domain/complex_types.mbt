///|
/// XSD complex type CT_Empty from wml.xsd (§17).
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
/// XSD complex type CT_OnOff from wml.xsd (§17).
pub(all) struct CT_OnOff {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OnOff::new(element : @xml.Element) -> CT_OnOff {
  { element, }
}

///|
pub fn CT_OnOff::parse(element : @xml.Element) -> CT_OnOff {
  CT_OnOff::new(element)
}

///|
pub fn CT_OnOff::to_element(self : CT_OnOff) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LongHexNumber from wml.xsd (§17).
pub(all) struct CT_LongHexNumber {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LongHexNumber::new(element : @xml.Element) -> CT_LongHexNumber {
  { element, }
}

///|
pub fn CT_LongHexNumber::parse(element : @xml.Element) -> CT_LongHexNumber {
  CT_LongHexNumber::new(element)
}

///|
pub fn CT_LongHexNumber::to_element(self : CT_LongHexNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Charset from wml.xsd (§17).
pub(all) struct CT_Charset {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Charset::new(element : @xml.Element) -> CT_Charset {
  { element, }
}

///|
pub fn CT_Charset::parse(element : @xml.Element) -> CT_Charset {
  CT_Charset::new(element)
}

///|
pub fn CT_Charset::to_element(self : CT_Charset) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DecimalNumber from wml.xsd (§17).
pub(all) struct CT_DecimalNumber {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DecimalNumber::new(element : @xml.Element) -> CT_DecimalNumber {
  { element, }
}

///|
pub fn CT_DecimalNumber::parse(element : @xml.Element) -> CT_DecimalNumber {
  CT_DecimalNumber::new(element)
}

///|
pub fn CT_DecimalNumber::to_element(self : CT_DecimalNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_UnsignedDecimalNumber from wml.xsd (§17).
pub(all) struct CT_UnsignedDecimalNumber {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_UnsignedDecimalNumber::new(
  element : @xml.Element,
) -> CT_UnsignedDecimalNumber {
  { element, }
}

///|
pub fn CT_UnsignedDecimalNumber::parse(
  element : @xml.Element,
) -> CT_UnsignedDecimalNumber {
  CT_UnsignedDecimalNumber::new(element)
}

///|
pub fn CT_UnsignedDecimalNumber::to_element(
  self : CT_UnsignedDecimalNumber,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DecimalNumberOrPrecent from wml.xsd (§17).
pub(all) struct CT_DecimalNumberOrPrecent {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DecimalNumberOrPrecent::new(
  element : @xml.Element,
) -> CT_DecimalNumberOrPrecent {
  { element, }
}

///|
pub fn CT_DecimalNumberOrPrecent::parse(
  element : @xml.Element,
) -> CT_DecimalNumberOrPrecent {
  CT_DecimalNumberOrPrecent::new(element)
}

///|
pub fn CT_DecimalNumberOrPrecent::to_element(
  self : CT_DecimalNumberOrPrecent,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TwipsMeasure from wml.xsd (§17).
pub(all) struct CT_TwipsMeasure {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TwipsMeasure::new(element : @xml.Element) -> CT_TwipsMeasure {
  { element, }
}

///|
pub fn CT_TwipsMeasure::parse(element : @xml.Element) -> CT_TwipsMeasure {
  CT_TwipsMeasure::new(element)
}

///|
pub fn CT_TwipsMeasure::to_element(self : CT_TwipsMeasure) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SignedTwipsMeasure from wml.xsd (§17).
pub(all) struct CT_SignedTwipsMeasure {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SignedTwipsMeasure::new(
  element : @xml.Element,
) -> CT_SignedTwipsMeasure {
  { element, }
}

///|
pub fn CT_SignedTwipsMeasure::parse(
  element : @xml.Element,
) -> CT_SignedTwipsMeasure {
  CT_SignedTwipsMeasure::new(element)
}

///|
pub fn CT_SignedTwipsMeasure::to_element(
  self : CT_SignedTwipsMeasure,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PixelsMeasure from wml.xsd (§17).
pub(all) struct CT_PixelsMeasure {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PixelsMeasure::new(element : @xml.Element) -> CT_PixelsMeasure {
  { element, }
}

///|
pub fn CT_PixelsMeasure::parse(element : @xml.Element) -> CT_PixelsMeasure {
  CT_PixelsMeasure::new(element)
}

///|
pub fn CT_PixelsMeasure::to_element(self : CT_PixelsMeasure) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HpsMeasure from wml.xsd (§17).
pub(all) struct CT_HpsMeasure {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HpsMeasure::new(element : @xml.Element) -> CT_HpsMeasure {
  { element, }
}

///|
pub fn CT_HpsMeasure::parse(element : @xml.Element) -> CT_HpsMeasure {
  CT_HpsMeasure::new(element)
}

///|
pub fn CT_HpsMeasure::to_element(self : CT_HpsMeasure) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SignedHpsMeasure from wml.xsd (§17).
pub(all) struct CT_SignedHpsMeasure {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SignedHpsMeasure::new(element : @xml.Element) -> CT_SignedHpsMeasure {
  { element, }
}

///|
pub fn CT_SignedHpsMeasure::parse(
  element : @xml.Element,
) -> CT_SignedHpsMeasure {
  CT_SignedHpsMeasure::new(element)
}

///|
pub fn CT_SignedHpsMeasure::to_element(
  self : CT_SignedHpsMeasure,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MacroName from wml.xsd (§17).
pub(all) struct CT_MacroName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MacroName::new(element : @xml.Element) -> CT_MacroName {
  { element, }
}

///|
pub fn CT_MacroName::parse(element : @xml.Element) -> CT_MacroName {
  CT_MacroName::new(element)
}

///|
pub fn CT_MacroName::to_element(self : CT_MacroName) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_String from wml.xsd (§17).
pub(all) struct CT_String {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_String::new(element : @xml.Element) -> CT_String {
  { element, }
}

///|
pub fn CT_String::parse(element : @xml.Element) -> CT_String {
  CT_String::new(element)
}

///|
pub fn CT_String::to_element(self : CT_String) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextScale from wml.xsd (§17).
pub(all) struct CT_TextScale {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextScale::new(element : @xml.Element) -> CT_TextScale {
  { element, }
}

///|
pub fn CT_TextScale::parse(element : @xml.Element) -> CT_TextScale {
  CT_TextScale::new(element)
}

///|
pub fn CT_TextScale::to_element(self : CT_TextScale) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Highlight from wml.xsd (§17).
pub(all) struct CT_Highlight {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Highlight::new(element : @xml.Element) -> CT_Highlight {
  { element, }
}

///|
pub fn CT_Highlight::parse(element : @xml.Element) -> CT_Highlight {
  CT_Highlight::new(element)
}

///|
pub fn CT_Highlight::to_element(self : CT_Highlight) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Color from wml.xsd (§17).
pub(all) struct CT_Color {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Color::new(element : @xml.Element) -> CT_Color {
  { element, }
}

///|
pub fn CT_Color::parse(element : @xml.Element) -> CT_Color {
  CT_Color::new(element)
}

///|
pub fn CT_Color::to_element(self : CT_Color) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Lang from wml.xsd (§17).
pub(all) struct CT_Lang {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Lang::new(element : @xml.Element) -> CT_Lang {
  { element, }
}

///|
pub fn CT_Lang::parse(element : @xml.Element) -> CT_Lang {
  CT_Lang::new(element)
}

///|
pub fn CT_Lang::to_element(self : CT_Lang) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Guid from wml.xsd (§17).
pub(all) struct CT_Guid {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Guid::new(element : @xml.Element) -> CT_Guid {
  { element, }
}

///|
pub fn CT_Guid::parse(element : @xml.Element) -> CT_Guid {
  CT_Guid::new(element)
}

///|
pub fn CT_Guid::to_element(self : CT_Guid) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Underline from wml.xsd (§17).
pub(all) struct CT_Underline {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Underline::new(element : @xml.Element) -> CT_Underline {
  { element, }
}

///|
pub fn CT_Underline::parse(element : @xml.Element) -> CT_Underline {
  CT_Underline::new(element)
}

///|
pub fn CT_Underline::to_element(self : CT_Underline) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextEffect from wml.xsd (§17).
pub(all) struct CT_TextEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextEffect::new(element : @xml.Element) -> CT_TextEffect {
  { element, }
}

///|
pub fn CT_TextEffect::parse(element : @xml.Element) -> CT_TextEffect {
  CT_TextEffect::new(element)
}

///|
pub fn CT_TextEffect::to_element(self : CT_TextEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Border from wml.xsd (§17).
pub(all) struct CT_Border {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Border::new(element : @xml.Element) -> CT_Border {
  { element, }
}

///|
pub fn CT_Border::parse(element : @xml.Element) -> CT_Border {
  CT_Border::new(element)
}

///|
pub fn CT_Border::to_element(self : CT_Border) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Shd from wml.xsd (§17).
pub(all) struct CT_Shd {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shd::new(element : @xml.Element) -> CT_Shd {
  { element, }
}

///|
pub fn CT_Shd::parse(element : @xml.Element) -> CT_Shd {
  CT_Shd::new(element)
}

///|
pub fn CT_Shd::to_element(self : CT_Shd) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_VerticalAlignRun from wml.xsd (§17).
pub(all) struct CT_VerticalAlignRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VerticalAlignRun::new(element : @xml.Element) -> CT_VerticalAlignRun {
  { element, }
}

///|
pub fn CT_VerticalAlignRun::parse(
  element : @xml.Element,
) -> CT_VerticalAlignRun {
  CT_VerticalAlignRun::new(element)
}

///|
pub fn CT_VerticalAlignRun::to_element(
  self : CT_VerticalAlignRun,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FitText from wml.xsd (§17).
pub(all) struct CT_FitText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FitText::new(element : @xml.Element) -> CT_FitText {
  { element, }
}

///|
pub fn CT_FitText::parse(element : @xml.Element) -> CT_FitText {
  CT_FitText::new(element)
}

///|
pub fn CT_FitText::to_element(self : CT_FitText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Em from wml.xsd (§17).
pub(all) struct CT_Em {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Em::new(element : @xml.Element) -> CT_Em {
  { element, }
}

///|
pub fn CT_Em::parse(element : @xml.Element) -> CT_Em {
  CT_Em::new(element)
}

///|
pub fn CT_Em::to_element(self : CT_Em) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Language from wml.xsd (§17).
pub(all) struct CT_Language {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Language::new(element : @xml.Element) -> CT_Language {
  { element, }
}

///|
pub fn CT_Language::parse(element : @xml.Element) -> CT_Language {
  CT_Language::new(element)
}

///|
pub fn CT_Language::to_element(self : CT_Language) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EastAsianLayout from wml.xsd (§17).
pub(all) struct CT_EastAsianLayout {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EastAsianLayout::new(element : @xml.Element) -> CT_EastAsianLayout {
  { element, }
}

///|
pub fn CT_EastAsianLayout::parse(element : @xml.Element) -> CT_EastAsianLayout {
  CT_EastAsianLayout::new(element)
}

///|
pub fn CT_EastAsianLayout::to_element(
  self : CT_EastAsianLayout,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FramePr from wml.xsd (§17).
pub(all) struct CT_FramePr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FramePr::new(element : @xml.Element) -> CT_FramePr {
  { element, }
}

///|
pub fn CT_FramePr::parse(element : @xml.Element) -> CT_FramePr {
  CT_FramePr::new(element)
}

///|
pub fn CT_FramePr::to_element(self : CT_FramePr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TabStop from wml.xsd (§17).
pub(all) struct CT_TabStop {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TabStop::new(element : @xml.Element) -> CT_TabStop {
  { element, }
}

///|
pub fn CT_TabStop::parse(element : @xml.Element) -> CT_TabStop {
  CT_TabStop::new(element)
}

///|
pub fn CT_TabStop::to_element(self : CT_TabStop) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Spacing from wml.xsd (§17).
pub(all) struct CT_Spacing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Spacing::new(element : @xml.Element) -> CT_Spacing {
  { element, }
}

///|
pub fn CT_Spacing::parse(element : @xml.Element) -> CT_Spacing {
  CT_Spacing::new(element)
}

///|
pub fn CT_Spacing::to_element(self : CT_Spacing) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Ind from wml.xsd (§17).
pub(all) struct CT_Ind {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Ind::new(element : @xml.Element) -> CT_Ind {
  { element, }
}

///|
pub fn CT_Ind::parse(element : @xml.Element) -> CT_Ind {
  CT_Ind::new(element)
}

///|
pub fn CT_Ind::to_element(self : CT_Ind) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Jc from wml.xsd (§17).
pub(all) struct CT_Jc {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Jc::new(element : @xml.Element) -> CT_Jc {
  { element, }
}

///|
pub fn CT_Jc::parse(element : @xml.Element) -> CT_Jc {
  CT_Jc::new(element)
}

///|
pub fn CT_Jc::to_element(self : CT_Jc) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_JcTable from wml.xsd (§17).
pub(all) struct CT_JcTable {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_JcTable::new(element : @xml.Element) -> CT_JcTable {
  { element, }
}

///|
pub fn CT_JcTable::parse(element : @xml.Element) -> CT_JcTable {
  CT_JcTable::new(element)
}

///|
pub fn CT_JcTable::to_element(self : CT_JcTable) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_View from wml.xsd (§17).
pub(all) struct CT_View {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_View::new(element : @xml.Element) -> CT_View {
  { element, }
}

///|
pub fn CT_View::parse(element : @xml.Element) -> CT_View {
  CT_View::new(element)
}

///|
pub fn CT_View::to_element(self : CT_View) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Zoom from wml.xsd (§17).
pub(all) struct CT_Zoom {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Zoom::new(element : @xml.Element) -> CT_Zoom {
  { element, }
}

///|
pub fn CT_Zoom::parse(element : @xml.Element) -> CT_Zoom {
  CT_Zoom::new(element)
}

///|
pub fn CT_Zoom::to_element(self : CT_Zoom) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WritingStyle from wml.xsd (§17).
pub(all) struct CT_WritingStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WritingStyle::new(element : @xml.Element) -> CT_WritingStyle {
  { element, }
}

///|
pub fn CT_WritingStyle::parse(element : @xml.Element) -> CT_WritingStyle {
  CT_WritingStyle::new(element)
}

///|
pub fn CT_WritingStyle::to_element(self : CT_WritingStyle) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Proof from wml.xsd (§17).
pub(all) struct CT_Proof {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Proof::new(element : @xml.Element) -> CT_Proof {
  { element, }
}

///|
pub fn CT_Proof::parse(element : @xml.Element) -> CT_Proof {
  CT_Proof::new(element)
}

///|
pub fn CT_Proof::to_element(self : CT_Proof) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocType from wml.xsd (§17).
pub(all) struct CT_DocType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocType::new(element : @xml.Element) -> CT_DocType {
  { element, }
}

///|
pub fn CT_DocType::parse(element : @xml.Element) -> CT_DocType {
  CT_DocType::new(element)
}

///|
pub fn CT_DocType::to_element(self : CT_DocType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocProtect from wml.xsd (§17).
pub(all) struct CT_DocProtect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocProtect::new(element : @xml.Element) -> CT_DocProtect {
  { element, }
}

///|
pub fn CT_DocProtect::parse(element : @xml.Element) -> CT_DocProtect {
  CT_DocProtect::new(element)
}

///|
pub fn CT_DocProtect::to_element(self : CT_DocProtect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeDocType from wml.xsd (§17).
pub(all) struct CT_MailMergeDocType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MailMergeDocType::new(element : @xml.Element) -> CT_MailMergeDocType {
  { element, }
}

///|
pub fn CT_MailMergeDocType::parse(
  element : @xml.Element,
) -> CT_MailMergeDocType {
  CT_MailMergeDocType::new(element)
}

///|
pub fn CT_MailMergeDocType::to_element(
  self : CT_MailMergeDocType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeDataType from wml.xsd (§17).
pub(all) struct CT_MailMergeDataType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MailMergeDataType::new(
  element : @xml.Element,
) -> CT_MailMergeDataType {
  { element, }
}

///|
pub fn CT_MailMergeDataType::parse(
  element : @xml.Element,
) -> CT_MailMergeDataType {
  CT_MailMergeDataType::new(element)
}

///|
pub fn CT_MailMergeDataType::to_element(
  self : CT_MailMergeDataType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeDest from wml.xsd (§17).
pub(all) struct CT_MailMergeDest {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MailMergeDest::new(element : @xml.Element) -> CT_MailMergeDest {
  { element, }
}

///|
pub fn CT_MailMergeDest::parse(element : @xml.Element) -> CT_MailMergeDest {
  CT_MailMergeDest::new(element)
}

///|
pub fn CT_MailMergeDest::to_element(self : CT_MailMergeDest) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeOdsoFMDFieldType from wml.xsd (§17).
pub(all) struct CT_MailMergeOdsoFMDFieldType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MailMergeOdsoFMDFieldType::new(
  element : @xml.Element,
) -> CT_MailMergeOdsoFMDFieldType {
  { element, }
}

///|
pub fn CT_MailMergeOdsoFMDFieldType::parse(
  element : @xml.Element,
) -> CT_MailMergeOdsoFMDFieldType {
  CT_MailMergeOdsoFMDFieldType::new(element)
}

///|
pub fn CT_MailMergeOdsoFMDFieldType::to_element(
  self : CT_MailMergeOdsoFMDFieldType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChangesView from wml.xsd (§17).
pub(all) struct CT_TrackChangesView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrackChangesView::new(element : @xml.Element) -> CT_TrackChangesView {
  { element, }
}

///|
pub fn CT_TrackChangesView::parse(
  element : @xml.Element,
) -> CT_TrackChangesView {
  CT_TrackChangesView::new(element)
}

///|
pub fn CT_TrackChangesView::to_element(
  self : CT_TrackChangesView,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Kinsoku from wml.xsd (§17).
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
/// XSD complex type CT_TextDirection from wml.xsd (§17).
pub(all) struct CT_TextDirection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextDirection::new(element : @xml.Element) -> CT_TextDirection {
  { element, }
}

///|
pub fn CT_TextDirection::parse(element : @xml.Element) -> CT_TextDirection {
  CT_TextDirection::new(element)
}

///|
pub fn CT_TextDirection::to_element(self : CT_TextDirection) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextAlignment from wml.xsd (§17).
pub(all) struct CT_TextAlignment {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextAlignment::new(element : @xml.Element) -> CT_TextAlignment {
  { element, }
}

///|
pub fn CT_TextAlignment::parse(element : @xml.Element) -> CT_TextAlignment {
  CT_TextAlignment::new(element)
}

///|
pub fn CT_TextAlignment::to_element(self : CT_TextAlignment) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Markup from wml.xsd (§17).
pub(all) struct CT_Markup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Markup::new(element : @xml.Element) -> CT_Markup {
  { element, }
}

///|
pub fn CT_Markup::parse(element : @xml.Element) -> CT_Markup {
  CT_Markup::new(element)
}

///|
pub fn CT_Markup::to_element(self : CT_Markup) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChange from wml.xsd (§17).
pub(all) struct CT_TrackChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrackChange::new(element : @xml.Element) -> CT_TrackChange {
  { element, }
}

///|
pub fn CT_TrackChange::parse(element : @xml.Element) -> CT_TrackChange {
  CT_TrackChange::new(element)
}

///|
pub fn CT_TrackChange::to_element(self : CT_TrackChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CellMergeTrackChange from wml.xsd (§17).
pub(all) struct CT_CellMergeTrackChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellMergeTrackChange::new(
  element : @xml.Element,
) -> CT_CellMergeTrackChange {
  { element, }
}

///|
pub fn CT_CellMergeTrackChange::parse(
  element : @xml.Element,
) -> CT_CellMergeTrackChange {
  CT_CellMergeTrackChange::new(element)
}

///|
pub fn CT_CellMergeTrackChange::to_element(
  self : CT_CellMergeTrackChange,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChangeRange from wml.xsd (§17).
pub(all) struct CT_TrackChangeRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrackChangeRange::new(element : @xml.Element) -> CT_TrackChangeRange {
  { element, }
}

///|
pub fn CT_TrackChangeRange::parse(
  element : @xml.Element,
) -> CT_TrackChangeRange {
  CT_TrackChangeRange::new(element)
}

///|
pub fn CT_TrackChangeRange::to_element(
  self : CT_TrackChangeRange,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MarkupRange from wml.xsd (§17).
pub(all) struct CT_MarkupRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MarkupRange::new(element : @xml.Element) -> CT_MarkupRange {
  { element, }
}

///|
pub fn CT_MarkupRange::parse(element : @xml.Element) -> CT_MarkupRange {
  CT_MarkupRange::new(element)
}

///|
pub fn CT_MarkupRange::to_element(self : CT_MarkupRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BookmarkRange from wml.xsd (§17).
pub(all) struct CT_BookmarkRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BookmarkRange::new(element : @xml.Element) -> CT_BookmarkRange {
  { element, }
}

///|
pub fn CT_BookmarkRange::parse(element : @xml.Element) -> CT_BookmarkRange {
  CT_BookmarkRange::new(element)
}

///|
pub fn CT_BookmarkRange::to_element(self : CT_BookmarkRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Bookmark from wml.xsd (§17).
pub(all) struct CT_Bookmark {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Bookmark::new(element : @xml.Element) -> CT_Bookmark {
  { element, }
}

///|
pub fn CT_Bookmark::parse(element : @xml.Element) -> CT_Bookmark {
  CT_Bookmark::new(element)
}

///|
pub fn CT_Bookmark::to_element(self : CT_Bookmark) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MoveBookmark from wml.xsd (§17).
pub(all) struct CT_MoveBookmark {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MoveBookmark::new(element : @xml.Element) -> CT_MoveBookmark {
  { element, }
}

///|
pub fn CT_MoveBookmark::parse(element : @xml.Element) -> CT_MoveBookmark {
  CT_MoveBookmark::new(element)
}

///|
pub fn CT_MoveBookmark::to_element(self : CT_MoveBookmark) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Comment from wml.xsd (§17).
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
/// XSD complex type CT_TblPrExChange from wml.xsd (§17).
pub(all) struct CT_TblPrExChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPrExChange::new(element : @xml.Element) -> CT_TblPrExChange {
  { element, }
}

///|
pub fn CT_TblPrExChange::parse(element : @xml.Element) -> CT_TblPrExChange {
  CT_TblPrExChange::new(element)
}

///|
pub fn CT_TblPrExChange::to_element(self : CT_TblPrExChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TcPrChange from wml.xsd (§17).
pub(all) struct CT_TcPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TcPrChange::new(element : @xml.Element) -> CT_TcPrChange {
  { element, }
}

///|
pub fn CT_TcPrChange::parse(element : @xml.Element) -> CT_TcPrChange {
  CT_TcPrChange::new(element)
}

///|
pub fn CT_TcPrChange::to_element(self : CT_TcPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrPrChange from wml.xsd (§17).
pub(all) struct CT_TrPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrPrChange::new(element : @xml.Element) -> CT_TrPrChange {
  { element, }
}

///|
pub fn CT_TrPrChange::parse(element : @xml.Element) -> CT_TrPrChange {
  CT_TrPrChange::new(element)
}

///|
pub fn CT_TrPrChange::to_element(self : CT_TrPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblGridChange from wml.xsd (§17).
pub(all) struct CT_TblGridChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblGridChange::new(element : @xml.Element) -> CT_TblGridChange {
  { element, }
}

///|
pub fn CT_TblGridChange::parse(element : @xml.Element) -> CT_TblGridChange {
  CT_TblGridChange::new(element)
}

///|
pub fn CT_TblGridChange::to_element(self : CT_TblGridChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrChange from wml.xsd (§17).
pub(all) struct CT_TblPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPrChange::new(element : @xml.Element) -> CT_TblPrChange {
  { element, }
}

///|
pub fn CT_TblPrChange::parse(element : @xml.Element) -> CT_TblPrChange {
  CT_TblPrChange::new(element)
}

///|
pub fn CT_TblPrChange::to_element(self : CT_TblPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPrChange from wml.xsd (§17).
pub(all) struct CT_SectPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SectPrChange::new(element : @xml.Element) -> CT_SectPrChange {
  { element, }
}

///|
pub fn CT_SectPrChange::parse(element : @xml.Element) -> CT_SectPrChange {
  CT_SectPrChange::new(element)
}

///|
pub fn CT_SectPrChange::to_element(self : CT_SectPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrChange from wml.xsd (§17).
pub(all) struct CT_PPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PPrChange::new(element : @xml.Element) -> CT_PPrChange {
  { element, }
}

///|
pub fn CT_PPrChange::parse(element : @xml.Element) -> CT_PPrChange {
  CT_PPrChange::new(element)
}

///|
pub fn CT_PPrChange::to_element(self : CT_PPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPrChange from wml.xsd (§17).
pub(all) struct CT_RPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RPrChange::new(element : @xml.Element) -> CT_RPrChange {
  { element, }
}

///|
pub fn CT_RPrChange::parse(element : @xml.Element) -> CT_RPrChange {
  CT_RPrChange::new(element)
}

///|
pub fn CT_RPrChange::to_element(self : CT_RPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPrChange from wml.xsd (§17).
pub(all) struct CT_ParaRPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ParaRPrChange::new(element : @xml.Element) -> CT_ParaRPrChange {
  { element, }
}

///|
pub fn CT_ParaRPrChange::parse(element : @xml.Element) -> CT_ParaRPrChange {
  CT_ParaRPrChange::new(element)
}

///|
pub fn CT_ParaRPrChange::to_element(self : CT_ParaRPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RunTrackChange from wml.xsd (§17).
pub(all) struct CT_RunTrackChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RunTrackChange::new(element : @xml.Element) -> CT_RunTrackChange {
  { element, }
}

///|
pub fn CT_RunTrackChange::parse(element : @xml.Element) -> CT_RunTrackChange {
  CT_RunTrackChange::new(element)
}

///|
pub fn CT_RunTrackChange::to_element(self : CT_RunTrackChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NumPr from wml.xsd (§17).
pub(all) struct CT_NumPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NumPr::new(element : @xml.Element) -> CT_NumPr {
  { element, }
}

///|
pub fn CT_NumPr::parse(element : @xml.Element) -> CT_NumPr {
  CT_NumPr::new(element)
}

///|
pub fn CT_NumPr::to_element(self : CT_NumPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PBdr from wml.xsd (§17).
pub(all) struct CT_PBdr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PBdr::new(element : @xml.Element) -> CT_PBdr {
  { element, }
}

///|
pub fn CT_PBdr::parse(element : @xml.Element) -> CT_PBdr {
  CT_PBdr::new(element)
}

///|
pub fn CT_PBdr::to_element(self : CT_PBdr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Tabs from wml.xsd (§17).
pub(all) struct CT_Tabs {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Tabs::new(element : @xml.Element) -> CT_Tabs {
  { element, }
}

///|
pub fn CT_Tabs::parse(element : @xml.Element) -> CT_Tabs {
  CT_Tabs::new(element)
}

///|
pub fn CT_Tabs::to_element(self : CT_Tabs) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextboxTightWrap from wml.xsd (§17).
pub(all) struct CT_TextboxTightWrap {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextboxTightWrap::new(element : @xml.Element) -> CT_TextboxTightWrap {
  { element, }
}

///|
pub fn CT_TextboxTightWrap::parse(
  element : @xml.Element,
) -> CT_TextboxTightWrap {
  CT_TextboxTightWrap::new(element)
}

///|
pub fn CT_TextboxTightWrap::to_element(
  self : CT_TextboxTightWrap,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPr from wml.xsd (§17).
pub(all) struct CT_PPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PPr::new(element : @xml.Element) -> CT_PPr {
  { element, }
}

///|
pub fn CT_PPr::parse(element : @xml.Element) -> CT_PPr {
  CT_PPr::new(element)
}

///|
pub fn CT_PPr::to_element(self : CT_PPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrBase from wml.xsd (§17).
pub(all) struct CT_PPrBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PPrBase::new(element : @xml.Element) -> CT_PPrBase {
  { element, }
}

///|
pub fn CT_PPrBase::parse(element : @xml.Element) -> CT_PPrBase {
  CT_PPrBase::new(element)
}

///|
pub fn CT_PPrBase::to_element(self : CT_PPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrGeneral from wml.xsd (§17).
pub(all) struct CT_PPrGeneral {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PPrGeneral::new(element : @xml.Element) -> CT_PPrGeneral {
  { element, }
}

///|
pub fn CT_PPrGeneral::parse(element : @xml.Element) -> CT_PPrGeneral {
  CT_PPrGeneral::new(element)
}

///|
pub fn CT_PPrGeneral::to_element(self : CT_PPrGeneral) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Control from wml.xsd (§17).
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
/// XSD complex type CT_Background from wml.xsd (§17).
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
/// XSD complex type CT_Rel from wml.xsd (§17).
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
/// XSD complex type CT_Object from wml.xsd (§17).
pub(all) struct CT_Object {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Object::new(element : @xml.Element) -> CT_Object {
  { element, }
}

///|
pub fn CT_Object::parse(element : @xml.Element) -> CT_Object {
  CT_Object::new(element)
}

///|
pub fn CT_Object::to_element(self : CT_Object) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ObjectEmbed from wml.xsd (§17).
pub(all) struct CT_ObjectEmbed {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ObjectEmbed::new(element : @xml.Element) -> CT_ObjectEmbed {
  { element, }
}

///|
pub fn CT_ObjectEmbed::parse(element : @xml.Element) -> CT_ObjectEmbed {
  CT_ObjectEmbed::new(element)
}

///|
pub fn CT_ObjectEmbed::to_element(self : CT_ObjectEmbed) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ObjectLink from wml.xsd (§17).
pub(all) struct CT_ObjectLink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ObjectLink::new(element : @xml.Element) -> CT_ObjectLink {
  { element, }
}

///|
pub fn CT_ObjectLink::parse(element : @xml.Element) -> CT_ObjectLink {
  CT_ObjectLink::new(element)
}

///|
pub fn CT_ObjectLink::to_element(self : CT_ObjectLink) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Drawing from wml.xsd (§17).
pub(all) struct CT_Drawing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Drawing::new(element : @xml.Element) -> CT_Drawing {
  { element, }
}

///|
pub fn CT_Drawing::parse(element : @xml.Element) -> CT_Drawing {
  CT_Drawing::new(element)
}

///|
pub fn CT_Drawing::to_element(self : CT_Drawing) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SimpleField from wml.xsd (§17).
pub(all) struct CT_SimpleField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SimpleField::new(element : @xml.Element) -> CT_SimpleField {
  { element, }
}

///|
pub fn CT_SimpleField::parse(element : @xml.Element) -> CT_SimpleField {
  CT_SimpleField::new(element)
}

///|
pub fn CT_SimpleField::to_element(self : CT_SimpleField) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFTextType from wml.xsd (§17).
pub(all) struct CT_FFTextType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFTextType::new(element : @xml.Element) -> CT_FFTextType {
  { element, }
}

///|
pub fn CT_FFTextType::parse(element : @xml.Element) -> CT_FFTextType {
  CT_FFTextType::new(element)
}

///|
pub fn CT_FFTextType::to_element(self : CT_FFTextType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFName from wml.xsd (§17).
pub(all) struct CT_FFName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFName::new(element : @xml.Element) -> CT_FFName {
  { element, }
}

///|
pub fn CT_FFName::parse(element : @xml.Element) -> CT_FFName {
  CT_FFName::new(element)
}

///|
pub fn CT_FFName::to_element(self : CT_FFName) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FldChar from wml.xsd (§17).
pub(all) struct CT_FldChar {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FldChar::new(element : @xml.Element) -> CT_FldChar {
  { element, }
}

///|
pub fn CT_FldChar::parse(element : @xml.Element) -> CT_FldChar {
  CT_FldChar::new(element)
}

///|
pub fn CT_FldChar::to_element(self : CT_FldChar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Hyperlink from wml.xsd (§17).
pub(all) struct CT_Hyperlink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Hyperlink::new(element : @xml.Element) -> CT_Hyperlink {
  { element, }
}

///|
pub fn CT_Hyperlink::parse(element : @xml.Element) -> CT_Hyperlink {
  CT_Hyperlink::new(element)
}

///|
pub fn CT_Hyperlink::to_element(self : CT_Hyperlink) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFData from wml.xsd (§17).
pub(all) struct CT_FFData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFData::new(element : @xml.Element) -> CT_FFData {
  { element, }
}

///|
pub fn CT_FFData::parse(element : @xml.Element) -> CT_FFData {
  CT_FFData::new(element)
}

///|
pub fn CT_FFData::to_element(self : CT_FFData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFHelpText from wml.xsd (§17).
pub(all) struct CT_FFHelpText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFHelpText::new(element : @xml.Element) -> CT_FFHelpText {
  { element, }
}

///|
pub fn CT_FFHelpText::parse(element : @xml.Element) -> CT_FFHelpText {
  CT_FFHelpText::new(element)
}

///|
pub fn CT_FFHelpText::to_element(self : CT_FFHelpText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFStatusText from wml.xsd (§17).
pub(all) struct CT_FFStatusText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFStatusText::new(element : @xml.Element) -> CT_FFStatusText {
  { element, }
}

///|
pub fn CT_FFStatusText::parse(element : @xml.Element) -> CT_FFStatusText {
  CT_FFStatusText::new(element)
}

///|
pub fn CT_FFStatusText::to_element(self : CT_FFStatusText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFCheckBox from wml.xsd (§17).
pub(all) struct CT_FFCheckBox {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFCheckBox::new(element : @xml.Element) -> CT_FFCheckBox {
  { element, }
}

///|
pub fn CT_FFCheckBox::parse(element : @xml.Element) -> CT_FFCheckBox {
  CT_FFCheckBox::new(element)
}

///|
pub fn CT_FFCheckBox::to_element(self : CT_FFCheckBox) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFDDList from wml.xsd (§17).
pub(all) struct CT_FFDDList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFDDList::new(element : @xml.Element) -> CT_FFDDList {
  { element, }
}

///|
pub fn CT_FFDDList::parse(element : @xml.Element) -> CT_FFDDList {
  CT_FFDDList::new(element)
}

///|
pub fn CT_FFDDList::to_element(self : CT_FFDDList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFTextInput from wml.xsd (§17).
pub(all) struct CT_FFTextInput {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFTextInput::new(element : @xml.Element) -> CT_FFTextInput {
  { element, }
}

///|
pub fn CT_FFTextInput::parse(element : @xml.Element) -> CT_FFTextInput {
  CT_FFTextInput::new(element)
}

///|
pub fn CT_FFTextInput::to_element(self : CT_FFTextInput) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectType from wml.xsd (§17).
pub(all) struct CT_SectType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SectType::new(element : @xml.Element) -> CT_SectType {
  { element, }
}

///|
pub fn CT_SectType::parse(element : @xml.Element) -> CT_SectType {
  CT_SectType::new(element)
}

///|
pub fn CT_SectType::to_element(self : CT_SectType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PaperSource from wml.xsd (§17).
pub(all) struct CT_PaperSource {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PaperSource::new(element : @xml.Element) -> CT_PaperSource {
  { element, }
}

///|
pub fn CT_PaperSource::parse(element : @xml.Element) -> CT_PaperSource {
  CT_PaperSource::new(element)
}

///|
pub fn CT_PaperSource::to_element(self : CT_PaperSource) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageSz from wml.xsd (§17).
pub(all) struct CT_PageSz {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageSz::new(element : @xml.Element) -> CT_PageSz {
  { element, }
}

///|
pub fn CT_PageSz::parse(element : @xml.Element) -> CT_PageSz {
  CT_PageSz::new(element)
}

///|
pub fn CT_PageSz::to_element(self : CT_PageSz) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageMar from wml.xsd (§17).
pub(all) struct CT_PageMar {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageMar::new(element : @xml.Element) -> CT_PageMar {
  { element, }
}

///|
pub fn CT_PageMar::parse(element : @xml.Element) -> CT_PageMar {
  CT_PageMar::new(element)
}

///|
pub fn CT_PageMar::to_element(self : CT_PageMar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageBorders from wml.xsd (§17).
pub(all) struct CT_PageBorders {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageBorders::new(element : @xml.Element) -> CT_PageBorders {
  { element, }
}

///|
pub fn CT_PageBorders::parse(element : @xml.Element) -> CT_PageBorders {
  CT_PageBorders::new(element)
}

///|
pub fn CT_PageBorders::to_element(self : CT_PageBorders) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageBorder from wml.xsd (§17).
pub(all) struct CT_PageBorder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageBorder::new(element : @xml.Element) -> CT_PageBorder {
  { element, }
}

///|
pub fn CT_PageBorder::parse(element : @xml.Element) -> CT_PageBorder {
  CT_PageBorder::new(element)
}

///|
pub fn CT_PageBorder::to_element(self : CT_PageBorder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BottomPageBorder from wml.xsd (§17).
pub(all) struct CT_BottomPageBorder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BottomPageBorder::new(element : @xml.Element) -> CT_BottomPageBorder {
  { element, }
}

///|
pub fn CT_BottomPageBorder::parse(
  element : @xml.Element,
) -> CT_BottomPageBorder {
  CT_BottomPageBorder::new(element)
}

///|
pub fn CT_BottomPageBorder::to_element(
  self : CT_BottomPageBorder,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TopPageBorder from wml.xsd (§17).
pub(all) struct CT_TopPageBorder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TopPageBorder::new(element : @xml.Element) -> CT_TopPageBorder {
  { element, }
}

///|
pub fn CT_TopPageBorder::parse(element : @xml.Element) -> CT_TopPageBorder {
  CT_TopPageBorder::new(element)
}

///|
pub fn CT_TopPageBorder::to_element(self : CT_TopPageBorder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LineNumber from wml.xsd (§17).
pub(all) struct CT_LineNumber {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineNumber::new(element : @xml.Element) -> CT_LineNumber {
  { element, }
}

///|
pub fn CT_LineNumber::parse(element : @xml.Element) -> CT_LineNumber {
  CT_LineNumber::new(element)
}

///|
pub fn CT_LineNumber::to_element(self : CT_LineNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageNumber from wml.xsd (§17).
pub(all) struct CT_PageNumber {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageNumber::new(element : @xml.Element) -> CT_PageNumber {
  { element, }
}

///|
pub fn CT_PageNumber::parse(element : @xml.Element) -> CT_PageNumber {
  CT_PageNumber::new(element)
}

///|
pub fn CT_PageNumber::to_element(self : CT_PageNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Column from wml.xsd (§17).
pub(all) struct CT_Column {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Column::new(element : @xml.Element) -> CT_Column {
  { element, }
}

///|
pub fn CT_Column::parse(element : @xml.Element) -> CT_Column {
  CT_Column::new(element)
}

///|
pub fn CT_Column::to_element(self : CT_Column) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Columns from wml.xsd (§17).
pub(all) struct CT_Columns {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Columns::new(element : @xml.Element) -> CT_Columns {
  { element, }
}

///|
pub fn CT_Columns::parse(element : @xml.Element) -> CT_Columns {
  CT_Columns::new(element)
}

///|
pub fn CT_Columns::to_element(self : CT_Columns) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_VerticalJc from wml.xsd (§17).
pub(all) struct CT_VerticalJc {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VerticalJc::new(element : @xml.Element) -> CT_VerticalJc {
  { element, }
}

///|
pub fn CT_VerticalJc::parse(element : @xml.Element) -> CT_VerticalJc {
  CT_VerticalJc::new(element)
}

///|
pub fn CT_VerticalJc::to_element(self : CT_VerticalJc) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocGrid from wml.xsd (§17).
pub(all) struct CT_DocGrid {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocGrid::new(element : @xml.Element) -> CT_DocGrid {
  { element, }
}

///|
pub fn CT_DocGrid::parse(element : @xml.Element) -> CT_DocGrid {
  CT_DocGrid::new(element)
}

///|
pub fn CT_DocGrid::to_element(self : CT_DocGrid) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HdrFtrRef from wml.xsd (§17).
pub(all) struct CT_HdrFtrRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HdrFtrRef::new(element : @xml.Element) -> CT_HdrFtrRef {
  { element, }
}

///|
pub fn CT_HdrFtrRef::parse(element : @xml.Element) -> CT_HdrFtrRef {
  CT_HdrFtrRef::new(element)
}

///|
pub fn CT_HdrFtrRef::to_element(self : CT_HdrFtrRef) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HdrFtr from wml.xsd (§17).
pub(all) struct CT_HdrFtr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HdrFtr::new(element : @xml.Element) -> CT_HdrFtr {
  { element, }
}

///|
pub fn CT_HdrFtr::parse(element : @xml.Element) -> CT_HdrFtr {
  CT_HdrFtr::new(element)
}

///|
pub fn CT_HdrFtr::to_element(self : CT_HdrFtr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPrBase from wml.xsd (§17).
pub(all) struct CT_SectPrBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SectPrBase::new(element : @xml.Element) -> CT_SectPrBase {
  { element, }
}

///|
pub fn CT_SectPrBase::parse(element : @xml.Element) -> CT_SectPrBase {
  CT_SectPrBase::new(element)
}

///|
pub fn CT_SectPrBase::to_element(self : CT_SectPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPr from wml.xsd (§17).
pub(all) struct CT_SectPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SectPr::new(element : @xml.Element) -> CT_SectPr {
  { element, }
}

///|
pub fn CT_SectPr::parse(element : @xml.Element) -> CT_SectPr {
  CT_SectPr::new(element)
}

///|
pub fn CT_SectPr::to_element(self : CT_SectPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Br from wml.xsd (§17).
pub(all) struct CT_Br {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Br::new(element : @xml.Element) -> CT_Br {
  { element, }
}

///|
pub fn CT_Br::parse(element : @xml.Element) -> CT_Br {
  CT_Br::new(element)
}

///|
pub fn CT_Br::to_element(self : CT_Br) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PTab from wml.xsd (§17).
pub(all) struct CT_PTab {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PTab::new(element : @xml.Element) -> CT_PTab {
  { element, }
}

///|
pub fn CT_PTab::parse(element : @xml.Element) -> CT_PTab {
  CT_PTab::new(element)
}

///|
pub fn CT_PTab::to_element(self : CT_PTab) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Sym from wml.xsd (§17).
pub(all) struct CT_Sym {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Sym::new(element : @xml.Element) -> CT_Sym {
  { element, }
}

///|
pub fn CT_Sym::parse(element : @xml.Element) -> CT_Sym {
  CT_Sym::new(element)
}

///|
pub fn CT_Sym::to_element(self : CT_Sym) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ProofErr from wml.xsd (§17).
pub(all) struct CT_ProofErr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ProofErr::new(element : @xml.Element) -> CT_ProofErr {
  { element, }
}

///|
pub fn CT_ProofErr::parse(element : @xml.Element) -> CT_ProofErr {
  CT_ProofErr::new(element)
}

///|
pub fn CT_ProofErr::to_element(self : CT_ProofErr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Perm from wml.xsd (§17).
pub(all) struct CT_Perm {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Perm::new(element : @xml.Element) -> CT_Perm {
  { element, }
}

///|
pub fn CT_Perm::parse(element : @xml.Element) -> CT_Perm {
  CT_Perm::new(element)
}

///|
pub fn CT_Perm::to_element(self : CT_Perm) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PermStart from wml.xsd (§17).
pub(all) struct CT_PermStart {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PermStart::new(element : @xml.Element) -> CT_PermStart {
  { element, }
}

///|
pub fn CT_PermStart::parse(element : @xml.Element) -> CT_PermStart {
  CT_PermStart::new(element)
}

///|
pub fn CT_PermStart::to_element(self : CT_PermStart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Text from wml.xsd (§17).
pub(all) struct CT_Text {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Text::new(element : @xml.Element) -> CT_Text {
  { element, }
}

///|
pub fn CT_Text::parse(element : @xml.Element) -> CT_Text {
  CT_Text::new(element)
}

///|
pub fn CT_Text::to_element(self : CT_Text) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_R from wml.xsd (§17).
pub(all) struct CT_R {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_R::new(element : @xml.Element) -> CT_R {
  { element, }
}

///|
pub fn CT_R::parse(element : @xml.Element) -> CT_R {
  CT_R::new(element)
}

///|
pub fn CT_R::to_element(self : CT_R) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Fonts from wml.xsd (§17).
pub(all) struct CT_Fonts {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Fonts::new(element : @xml.Element) -> CT_Fonts {
  { element, }
}

///|
pub fn CT_Fonts::parse(element : @xml.Element) -> CT_Fonts {
  CT_Fonts::new(element)
}

///|
pub fn CT_Fonts::to_element(self : CT_Fonts) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPr from wml.xsd (§17).
pub(all) struct CT_RPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RPr::new(element : @xml.Element) -> CT_RPr {
  { element, }
}

///|
pub fn CT_RPr::parse(element : @xml.Element) -> CT_RPr {
  CT_RPr::new(element)
}

///|
pub fn CT_RPr::to_element(self : CT_RPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MathCtrlIns from wml.xsd (§17).
pub(all) struct CT_MathCtrlIns {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MathCtrlIns::new(element : @xml.Element) -> CT_MathCtrlIns {
  { element, }
}

///|
pub fn CT_MathCtrlIns::parse(element : @xml.Element) -> CT_MathCtrlIns {
  CT_MathCtrlIns::new(element)
}

///|
pub fn CT_MathCtrlIns::to_element(self : CT_MathCtrlIns) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MathCtrlDel from wml.xsd (§17).
pub(all) struct CT_MathCtrlDel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MathCtrlDel::new(element : @xml.Element) -> CT_MathCtrlDel {
  { element, }
}

///|
pub fn CT_MathCtrlDel::parse(element : @xml.Element) -> CT_MathCtrlDel {
  CT_MathCtrlDel::new(element)
}

///|
pub fn CT_MathCtrlDel::to_element(self : CT_MathCtrlDel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPrOriginal from wml.xsd (§17).
pub(all) struct CT_RPrOriginal {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RPrOriginal::new(element : @xml.Element) -> CT_RPrOriginal {
  { element, }
}

///|
pub fn CT_RPrOriginal::parse(element : @xml.Element) -> CT_RPrOriginal {
  CT_RPrOriginal::new(element)
}

///|
pub fn CT_RPrOriginal::to_element(self : CT_RPrOriginal) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPrOriginal from wml.xsd (§17).
pub(all) struct CT_ParaRPrOriginal {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ParaRPrOriginal::new(element : @xml.Element) -> CT_ParaRPrOriginal {
  { element, }
}

///|
pub fn CT_ParaRPrOriginal::parse(element : @xml.Element) -> CT_ParaRPrOriginal {
  CT_ParaRPrOriginal::new(element)
}

///|
pub fn CT_ParaRPrOriginal::to_element(
  self : CT_ParaRPrOriginal,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPr from wml.xsd (§17).
pub(all) struct CT_ParaRPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ParaRPr::new(element : @xml.Element) -> CT_ParaRPr {
  { element, }
}

///|
pub fn CT_ParaRPr::parse(element : @xml.Element) -> CT_ParaRPr {
  CT_ParaRPr::new(element)
}

///|
pub fn CT_ParaRPr::to_element(self : CT_ParaRPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AltChunk from wml.xsd (§17).
pub(all) struct CT_AltChunk {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AltChunk::new(element : @xml.Element) -> CT_AltChunk {
  { element, }
}

///|
pub fn CT_AltChunk::parse(element : @xml.Element) -> CT_AltChunk {
  CT_AltChunk::new(element)
}

///|
pub fn CT_AltChunk::to_element(self : CT_AltChunk) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AltChunkPr from wml.xsd (§17).
pub(all) struct CT_AltChunkPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AltChunkPr::new(element : @xml.Element) -> CT_AltChunkPr {
  { element, }
}

///|
pub fn CT_AltChunkPr::parse(element : @xml.Element) -> CT_AltChunkPr {
  CT_AltChunkPr::new(element)
}

///|
pub fn CT_AltChunkPr::to_element(self : CT_AltChunkPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyAlign from wml.xsd (§17).
pub(all) struct CT_RubyAlign {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RubyAlign::new(element : @xml.Element) -> CT_RubyAlign {
  { element, }
}

///|
pub fn CT_RubyAlign::parse(element : @xml.Element) -> CT_RubyAlign {
  CT_RubyAlign::new(element)
}

///|
pub fn CT_RubyAlign::to_element(self : CT_RubyAlign) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyPr from wml.xsd (§17).
pub(all) struct CT_RubyPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RubyPr::new(element : @xml.Element) -> CT_RubyPr {
  { element, }
}

///|
pub fn CT_RubyPr::parse(element : @xml.Element) -> CT_RubyPr {
  CT_RubyPr::new(element)
}

///|
pub fn CT_RubyPr::to_element(self : CT_RubyPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyContent from wml.xsd (§17).
pub(all) struct CT_RubyContent {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RubyContent::new(element : @xml.Element) -> CT_RubyContent {
  { element, }
}

///|
pub fn CT_RubyContent::parse(element : @xml.Element) -> CT_RubyContent {
  CT_RubyContent::new(element)
}

///|
pub fn CT_RubyContent::to_element(self : CT_RubyContent) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Ruby from wml.xsd (§17).
pub(all) struct CT_Ruby {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Ruby::new(element : @xml.Element) -> CT_Ruby {
  { element, }
}

///|
pub fn CT_Ruby::parse(element : @xml.Element) -> CT_Ruby {
  CT_Ruby::new(element)
}

///|
pub fn CT_Ruby::to_element(self : CT_Ruby) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Lock from wml.xsd (§17).
pub(all) struct CT_Lock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Lock::new(element : @xml.Element) -> CT_Lock {
  { element, }
}

///|
pub fn CT_Lock::parse(element : @xml.Element) -> CT_Lock {
  CT_Lock::new(element)
}

///|
pub fn CT_Lock::to_element(self : CT_Lock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtListItem from wml.xsd (§17).
pub(all) struct CT_SdtListItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtListItem::new(element : @xml.Element) -> CT_SdtListItem {
  { element, }
}

///|
pub fn CT_SdtListItem::parse(element : @xml.Element) -> CT_SdtListItem {
  CT_SdtListItem::new(element)
}

///|
pub fn CT_SdtListItem::to_element(self : CT_SdtListItem) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDateMappingType from wml.xsd (§17).
pub(all) struct CT_SdtDateMappingType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtDateMappingType::new(
  element : @xml.Element,
) -> CT_SdtDateMappingType {
  { element, }
}

///|
pub fn CT_SdtDateMappingType::parse(
  element : @xml.Element,
) -> CT_SdtDateMappingType {
  CT_SdtDateMappingType::new(element)
}

///|
pub fn CT_SdtDateMappingType::to_element(
  self : CT_SdtDateMappingType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CalendarType from wml.xsd (§17).
pub(all) struct CT_CalendarType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CalendarType::new(element : @xml.Element) -> CT_CalendarType {
  { element, }
}

///|
pub fn CT_CalendarType::parse(element : @xml.Element) -> CT_CalendarType {
  CT_CalendarType::new(element)
}

///|
pub fn CT_CalendarType::to_element(self : CT_CalendarType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDate from wml.xsd (§17).
pub(all) struct CT_SdtDate {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtDate::new(element : @xml.Element) -> CT_SdtDate {
  { element, }
}

///|
pub fn CT_SdtDate::parse(element : @xml.Element) -> CT_SdtDate {
  CT_SdtDate::new(element)
}

///|
pub fn CT_SdtDate::to_element(self : CT_SdtDate) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtComboBox from wml.xsd (§17).
pub(all) struct CT_SdtComboBox {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtComboBox::new(element : @xml.Element) -> CT_SdtComboBox {
  { element, }
}

///|
pub fn CT_SdtComboBox::parse(element : @xml.Element) -> CT_SdtComboBox {
  CT_SdtComboBox::new(element)
}

///|
pub fn CT_SdtComboBox::to_element(self : CT_SdtComboBox) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDocPart from wml.xsd (§17).
pub(all) struct CT_SdtDocPart {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtDocPart::new(element : @xml.Element) -> CT_SdtDocPart {
  { element, }
}

///|
pub fn CT_SdtDocPart::parse(element : @xml.Element) -> CT_SdtDocPart {
  CT_SdtDocPart::new(element)
}

///|
pub fn CT_SdtDocPart::to_element(self : CT_SdtDocPart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDropDownList from wml.xsd (§17).
pub(all) struct CT_SdtDropDownList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtDropDownList::new(element : @xml.Element) -> CT_SdtDropDownList {
  { element, }
}

///|
pub fn CT_SdtDropDownList::parse(element : @xml.Element) -> CT_SdtDropDownList {
  CT_SdtDropDownList::new(element)
}

///|
pub fn CT_SdtDropDownList::to_element(
  self : CT_SdtDropDownList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Placeholder from wml.xsd (§17).
pub(all) struct CT_Placeholder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Placeholder::new(element : @xml.Element) -> CT_Placeholder {
  { element, }
}

///|
pub fn CT_Placeholder::parse(element : @xml.Element) -> CT_Placeholder {
  CT_Placeholder::new(element)
}

///|
pub fn CT_Placeholder::to_element(self : CT_Placeholder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtText from wml.xsd (§17).
pub(all) struct CT_SdtText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtText::new(element : @xml.Element) -> CT_SdtText {
  { element, }
}

///|
pub fn CT_SdtText::parse(element : @xml.Element) -> CT_SdtText {
  CT_SdtText::new(element)
}

///|
pub fn CT_SdtText::to_element(self : CT_SdtText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DataBinding from wml.xsd (§17).
pub(all) struct CT_DataBinding {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataBinding::new(element : @xml.Element) -> CT_DataBinding {
  { element, }
}

///|
pub fn CT_DataBinding::parse(element : @xml.Element) -> CT_DataBinding {
  CT_DataBinding::new(element)
}

///|
pub fn CT_DataBinding::to_element(self : CT_DataBinding) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtPr from wml.xsd (§17).
pub(all) struct CT_SdtPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtPr::new(element : @xml.Element) -> CT_SdtPr {
  { element, }
}

///|
pub fn CT_SdtPr::parse(element : @xml.Element) -> CT_SdtPr {
  CT_SdtPr::new(element)
}

///|
pub fn CT_SdtPr::to_element(self : CT_SdtPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtEndPr from wml.xsd (§17).
pub(all) struct CT_SdtEndPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtEndPr::new(element : @xml.Element) -> CT_SdtEndPr {
  { element, }
}

///|
pub fn CT_SdtEndPr::parse(element : @xml.Element) -> CT_SdtEndPr {
  CT_SdtEndPr::new(element)
}

///|
pub fn CT_SdtEndPr::to_element(self : CT_SdtEndPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DirContentRun from wml.xsd (§17).
pub(all) struct CT_DirContentRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DirContentRun::new(element : @xml.Element) -> CT_DirContentRun {
  { element, }
}

///|
pub fn CT_DirContentRun::parse(element : @xml.Element) -> CT_DirContentRun {
  CT_DirContentRun::new(element)
}

///|
pub fn CT_DirContentRun::to_element(self : CT_DirContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BdoContentRun from wml.xsd (§17).
pub(all) struct CT_BdoContentRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BdoContentRun::new(element : @xml.Element) -> CT_BdoContentRun {
  { element, }
}

///|
pub fn CT_BdoContentRun::parse(element : @xml.Element) -> CT_BdoContentRun {
  CT_BdoContentRun::new(element)
}

///|
pub fn CT_BdoContentRun::to_element(self : CT_BdoContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentRun from wml.xsd (§17).
pub(all) struct CT_SdtContentRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtContentRun::new(element : @xml.Element) -> CT_SdtContentRun {
  { element, }
}

///|
pub fn CT_SdtContentRun::parse(element : @xml.Element) -> CT_SdtContentRun {
  CT_SdtContentRun::new(element)
}

///|
pub fn CT_SdtContentRun::to_element(self : CT_SdtContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentBlock from wml.xsd (§17).
pub(all) struct CT_SdtContentBlock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtContentBlock::new(element : @xml.Element) -> CT_SdtContentBlock {
  { element, }
}

///|
pub fn CT_SdtContentBlock::parse(element : @xml.Element) -> CT_SdtContentBlock {
  CT_SdtContentBlock::new(element)
}

///|
pub fn CT_SdtContentBlock::to_element(
  self : CT_SdtContentBlock,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentRow from wml.xsd (§17).
pub(all) struct CT_SdtContentRow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtContentRow::new(element : @xml.Element) -> CT_SdtContentRow {
  { element, }
}

///|
pub fn CT_SdtContentRow::parse(element : @xml.Element) -> CT_SdtContentRow {
  CT_SdtContentRow::new(element)
}

///|
pub fn CT_SdtContentRow::to_element(self : CT_SdtContentRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentCell from wml.xsd (§17).
pub(all) struct CT_SdtContentCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtContentCell::new(element : @xml.Element) -> CT_SdtContentCell {
  { element, }
}

///|
pub fn CT_SdtContentCell::parse(element : @xml.Element) -> CT_SdtContentCell {
  CT_SdtContentCell::new(element)
}

///|
pub fn CT_SdtContentCell::to_element(self : CT_SdtContentCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtBlock from wml.xsd (§17).
pub(all) struct CT_SdtBlock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtBlock::new(element : @xml.Element) -> CT_SdtBlock {
  { element, }
}

///|
pub fn CT_SdtBlock::parse(element : @xml.Element) -> CT_SdtBlock {
  CT_SdtBlock::new(element)
}

///|
pub fn CT_SdtBlock::to_element(self : CT_SdtBlock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtRun from wml.xsd (§17).
pub(all) struct CT_SdtRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtRun::new(element : @xml.Element) -> CT_SdtRun {
  { element, }
}

///|
pub fn CT_SdtRun::parse(element : @xml.Element) -> CT_SdtRun {
  CT_SdtRun::new(element)
}

///|
pub fn CT_SdtRun::to_element(self : CT_SdtRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtCell from wml.xsd (§17).
pub(all) struct CT_SdtCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtCell::new(element : @xml.Element) -> CT_SdtCell {
  { element, }
}

///|
pub fn CT_SdtCell::parse(element : @xml.Element) -> CT_SdtCell {
  CT_SdtCell::new(element)
}

///|
pub fn CT_SdtCell::to_element(self : CT_SdtCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtRow from wml.xsd (§17).
pub(all) struct CT_SdtRow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtRow::new(element : @xml.Element) -> CT_SdtRow {
  { element, }
}

///|
pub fn CT_SdtRow::parse(element : @xml.Element) -> CT_SdtRow {
  CT_SdtRow::new(element)
}

///|
pub fn CT_SdtRow::to_element(self : CT_SdtRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Attr from wml.xsd (§17).
pub(all) struct CT_Attr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Attr::new(element : @xml.Element) -> CT_Attr {
  { element, }
}

///|
pub fn CT_Attr::parse(element : @xml.Element) -> CT_Attr {
  CT_Attr::new(element)
}

///|
pub fn CT_Attr::to_element(self : CT_Attr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlRun from wml.xsd (§17).
pub(all) struct CT_CustomXmlRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlRun::new(element : @xml.Element) -> CT_CustomXmlRun {
  { element, }
}

///|
pub fn CT_CustomXmlRun::parse(element : @xml.Element) -> CT_CustomXmlRun {
  CT_CustomXmlRun::new(element)
}

///|
pub fn CT_CustomXmlRun::to_element(self : CT_CustomXmlRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTagRun from wml.xsd (§17).
pub(all) struct CT_SmartTagRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTagRun::new(element : @xml.Element) -> CT_SmartTagRun {
  { element, }
}

///|
pub fn CT_SmartTagRun::parse(element : @xml.Element) -> CT_SmartTagRun {
  CT_SmartTagRun::new(element)
}

///|
pub fn CT_SmartTagRun::to_element(self : CT_SmartTagRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlBlock from wml.xsd (§17).
pub(all) struct CT_CustomXmlBlock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlBlock::new(element : @xml.Element) -> CT_CustomXmlBlock {
  { element, }
}

///|
pub fn CT_CustomXmlBlock::parse(element : @xml.Element) -> CT_CustomXmlBlock {
  CT_CustomXmlBlock::new(element)
}

///|
pub fn CT_CustomXmlBlock::to_element(self : CT_CustomXmlBlock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlPr from wml.xsd (§17).
pub(all) struct CT_CustomXmlPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlPr::new(element : @xml.Element) -> CT_CustomXmlPr {
  { element, }
}

///|
pub fn CT_CustomXmlPr::parse(element : @xml.Element) -> CT_CustomXmlPr {
  CT_CustomXmlPr::new(element)
}

///|
pub fn CT_CustomXmlPr::to_element(self : CT_CustomXmlPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlRow from wml.xsd (§17).
pub(all) struct CT_CustomXmlRow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlRow::new(element : @xml.Element) -> CT_CustomXmlRow {
  { element, }
}

///|
pub fn CT_CustomXmlRow::parse(element : @xml.Element) -> CT_CustomXmlRow {
  CT_CustomXmlRow::new(element)
}

///|
pub fn CT_CustomXmlRow::to_element(self : CT_CustomXmlRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlCell from wml.xsd (§17).
pub(all) struct CT_CustomXmlCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlCell::new(element : @xml.Element) -> CT_CustomXmlCell {
  { element, }
}

///|
pub fn CT_CustomXmlCell::parse(element : @xml.Element) -> CT_CustomXmlCell {
  CT_CustomXmlCell::new(element)
}

///|
pub fn CT_CustomXmlCell::to_element(self : CT_CustomXmlCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTagPr from wml.xsd (§17).
pub(all) struct CT_SmartTagPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTagPr::new(element : @xml.Element) -> CT_SmartTagPr {
  { element, }
}

///|
pub fn CT_SmartTagPr::parse(element : @xml.Element) -> CT_SmartTagPr {
  CT_SmartTagPr::new(element)
}

///|
pub fn CT_SmartTagPr::to_element(self : CT_SmartTagPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_P from wml.xsd (§17).
pub(all) struct CT_P {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_P::new(element : @xml.Element) -> CT_P {
  { element, }
}

///|
pub fn CT_P::parse(element : @xml.Element) -> CT_P {
  CT_P::new(element)
}

///|
pub fn CT_P::to_element(self : CT_P) -> @xml.Element {
  self.element
}
