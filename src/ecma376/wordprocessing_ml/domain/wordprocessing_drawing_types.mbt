///|
fn validate_wordprocessing_drawing_simple_type(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise_schema_violation(type_name, value, "empty lexical value")
  }
  let allowed = wordprocessing_drawing_simple_type_values(type_name)
  if allowed.length() > 0 && !allowed.contains(";" + value + ";") {
    raise_schema_violation(type_name, value, "unknown enumeration value")
  }
}

///|
fn wordprocessing_drawing_simple_type_values(type_name : String) -> String {
  match type_name {
    "ST_WrapText" => ";bothSides;left;right;largest;"
    "ST_AlignH" => ";left;right;center;inside;outside;"
    "ST_RelFromH" =>
      ";margin;page;column;character;leftMargin;rightMargin;insideMargin;outsideMargin;"
    "ST_AlignV" => ";top;bottom;center;inside;outside;"
    "ST_RelFromV" =>
      ";margin;page;paragraph;line;topMargin;bottomMargin;insideMargin;outsideMargin;"
    _ => ""
  }
}

///|
/// XSD simple type ST_WrapDistance from dml-wordprocessingDrawing.xsd (§20.4).
pub struct ST_WrapDistance {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_WrapDistance::parse(
  s : String,
) -> ST_WrapDistance raise SchemaViolation {
  validate_wordprocessing_drawing_simple_type("ST_WrapDistance", s)
  { value: s }
}

///|
pub fn ST_WrapDistance::new(
  s : String,
) -> ST_WrapDistance raise SchemaViolation {
  ST_WrapDistance::parse(s)
}

///|
pub fn ST_WrapDistance::to_string(self : ST_WrapDistance) -> String {
  self.value
}

///|
/// XSD simple type ST_WrapText from dml-wordprocessingDrawing.xsd (§20.4).
pub struct ST_WrapText {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_WrapText::parse(s : String) -> ST_WrapText raise SchemaViolation {
  validate_wordprocessing_drawing_simple_type("ST_WrapText", s)
  { value: s }
}

///|
pub fn ST_WrapText::new(s : String) -> ST_WrapText raise SchemaViolation {
  ST_WrapText::parse(s)
}

///|
pub fn ST_WrapText::to_string(self : ST_WrapText) -> String {
  self.value
}

///|
/// XSD simple type ST_PositionOffset from dml-wordprocessingDrawing.xsd (§20.4).
pub struct ST_PositionOffset {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PositionOffset::parse(
  s : String,
) -> ST_PositionOffset raise SchemaViolation {
  validate_wordprocessing_drawing_simple_type("ST_PositionOffset", s)
  { value: s }
}

///|
pub fn ST_PositionOffset::new(
  s : String,
) -> ST_PositionOffset raise SchemaViolation {
  ST_PositionOffset::parse(s)
}

///|
pub fn ST_PositionOffset::to_string(self : ST_PositionOffset) -> String {
  self.value
}

///|
/// XSD simple type ST_AlignH from dml-wordprocessingDrawing.xsd (§20.4).
pub struct ST_AlignH {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_AlignH::parse(s : String) -> ST_AlignH raise SchemaViolation {
  validate_wordprocessing_drawing_simple_type("ST_AlignH", s)
  { value: s }
}

///|
pub fn ST_AlignH::new(s : String) -> ST_AlignH raise SchemaViolation {
  ST_AlignH::parse(s)
}

///|
pub fn ST_AlignH::to_string(self : ST_AlignH) -> String {
  self.value
}

///|
/// XSD simple type ST_RelFromH from dml-wordprocessingDrawing.xsd (§20.4).
pub struct ST_RelFromH {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RelFromH::parse(s : String) -> ST_RelFromH raise SchemaViolation {
  validate_wordprocessing_drawing_simple_type("ST_RelFromH", s)
  { value: s }
}

///|
pub fn ST_RelFromH::new(s : String) -> ST_RelFromH raise SchemaViolation {
  ST_RelFromH::parse(s)
}

///|
pub fn ST_RelFromH::to_string(self : ST_RelFromH) -> String {
  self.value
}

///|
/// XSD simple type ST_AlignV from dml-wordprocessingDrawing.xsd (§20.4).
pub struct ST_AlignV {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_AlignV::parse(s : String) -> ST_AlignV raise SchemaViolation {
  validate_wordprocessing_drawing_simple_type("ST_AlignV", s)
  { value: s }
}

///|
pub fn ST_AlignV::new(s : String) -> ST_AlignV raise SchemaViolation {
  ST_AlignV::parse(s)
}

///|
pub fn ST_AlignV::to_string(self : ST_AlignV) -> String {
  self.value
}

///|
/// XSD simple type ST_RelFromV from dml-wordprocessingDrawing.xsd (§20.4).
pub struct ST_RelFromV {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RelFromV::parse(s : String) -> ST_RelFromV raise SchemaViolation {
  validate_wordprocessing_drawing_simple_type("ST_RelFromV", s)
  { value: s }
}

///|
pub fn ST_RelFromV::new(s : String) -> ST_RelFromV raise SchemaViolation {
  ST_RelFromV::parse(s)
}

///|
pub fn ST_RelFromV::to_string(self : ST_RelFromV) -> String {
  self.value
}

///|
/// XSD complex type CT_EffectExtent from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_EffectExtent {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectExtent::new(element : @xml.Element) -> CT_EffectExtent {
  { element, }
}

///|
pub fn CT_EffectExtent::parse(element : @xml.Element) -> CT_EffectExtent {
  CT_EffectExtent::new(element)
}

///|
pub fn CT_EffectExtent::to_element(self : CT_EffectExtent) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Inline from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_Inline {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Inline::new(element : @xml.Element) -> CT_Inline {
  { element, }
}

///|
pub fn CT_Inline::parse(element : @xml.Element) -> CT_Inline {
  CT_Inline::new(element)
}

///|
pub fn CT_Inline::to_element(self : CT_Inline) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapPath from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WrapPath {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WrapPath::new(element : @xml.Element) -> CT_WrapPath {
  { element, }
}

///|
pub fn CT_WrapPath::parse(element : @xml.Element) -> CT_WrapPath {
  CT_WrapPath::new(element)
}

///|
pub fn CT_WrapPath::to_element(self : CT_WrapPath) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapNone from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WrapNone {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WrapNone::new(element : @xml.Element) -> CT_WrapNone {
  { element, }
}

///|
pub fn CT_WrapNone::parse(element : @xml.Element) -> CT_WrapNone {
  CT_WrapNone::new(element)
}

///|
pub fn CT_WrapNone::to_element(self : CT_WrapNone) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapSquare from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WrapSquare {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WrapSquare::new(element : @xml.Element) -> CT_WrapSquare {
  { element, }
}

///|
pub fn CT_WrapSquare::parse(element : @xml.Element) -> CT_WrapSquare {
  CT_WrapSquare::new(element)
}

///|
pub fn CT_WrapSquare::to_element(self : CT_WrapSquare) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapTight from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WrapTight {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WrapTight::new(element : @xml.Element) -> CT_WrapTight {
  { element, }
}

///|
pub fn CT_WrapTight::parse(element : @xml.Element) -> CT_WrapTight {
  CT_WrapTight::new(element)
}

///|
pub fn CT_WrapTight::to_element(self : CT_WrapTight) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapThrough from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WrapThrough {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WrapThrough::new(element : @xml.Element) -> CT_WrapThrough {
  { element, }
}

///|
pub fn CT_WrapThrough::parse(element : @xml.Element) -> CT_WrapThrough {
  CT_WrapThrough::new(element)
}

///|
pub fn CT_WrapThrough::to_element(self : CT_WrapThrough) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapTopBottom from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WrapTopBottom {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WrapTopBottom::new(element : @xml.Element) -> CT_WrapTopBottom {
  { element, }
}

///|
pub fn CT_WrapTopBottom::parse(element : @xml.Element) -> CT_WrapTopBottom {
  CT_WrapTopBottom::new(element)
}

///|
pub fn CT_WrapTopBottom::to_element(self : CT_WrapTopBottom) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PosH from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_PosH {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PosH::new(element : @xml.Element) -> CT_PosH {
  { element, }
}

///|
pub fn CT_PosH::parse(element : @xml.Element) -> CT_PosH {
  CT_PosH::new(element)
}

///|
pub fn CT_PosH::to_element(self : CT_PosH) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PosV from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_PosV {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PosV::new(element : @xml.Element) -> CT_PosV {
  { element, }
}

///|
pub fn CT_PosV::parse(element : @xml.Element) -> CT_PosV {
  CT_PosV::new(element)
}

///|
pub fn CT_PosV::to_element(self : CT_PosV) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Anchor from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_Anchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Anchor::new(element : @xml.Element) -> CT_Anchor {
  { element, }
}

///|
pub fn CT_Anchor::parse(element : @xml.Element) -> CT_Anchor {
  CT_Anchor::new(element)
}

///|
pub fn CT_Anchor::to_element(self : CT_Anchor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TxbxContent from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_TxbxContent {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TxbxContent::new(element : @xml.Element) -> CT_TxbxContent {
  { element, }
}

///|
pub fn CT_TxbxContent::parse(element : @xml.Element) -> CT_TxbxContent {
  CT_TxbxContent::new(element)
}

///|
pub fn CT_TxbxContent::to_element(self : CT_TxbxContent) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextboxInfo from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_TextboxInfo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextboxInfo::new(element : @xml.Element) -> CT_TextboxInfo {
  { element, }
}

///|
pub fn CT_TextboxInfo::parse(element : @xml.Element) -> CT_TextboxInfo {
  CT_TextboxInfo::new(element)
}

///|
pub fn CT_TextboxInfo::to_element(self : CT_TextboxInfo) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LinkedTextboxInformation from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_LinkedTextboxInformation {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LinkedTextboxInformation::new(
  element : @xml.Element,
) -> CT_LinkedTextboxInformation {
  { element, }
}

///|
pub fn CT_LinkedTextboxInformation::parse(
  element : @xml.Element,
) -> CT_LinkedTextboxInformation {
  CT_LinkedTextboxInformation::new(element)
}

///|
pub fn CT_LinkedTextboxInformation::to_element(
  self : CT_LinkedTextboxInformation,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WordprocessingShape from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WordprocessingShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingShape::new(
  element : @xml.Element,
) -> CT_WordprocessingShape {
  { element, }
}

///|
pub fn CT_WordprocessingShape::parse(
  element : @xml.Element,
) -> CT_WordprocessingShape {
  CT_WordprocessingShape::new(element)
}

///|
pub fn CT_WordprocessingShape::to_element(
  self : CT_WordprocessingShape,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicFrame from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_GraphicFrame {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicFrame::new(element : @xml.Element) -> CT_GraphicFrame {
  { element, }
}

///|
pub fn CT_GraphicFrame::parse(element : @xml.Element) -> CT_GraphicFrame {
  CT_GraphicFrame::new(element)
}

///|
pub fn CT_GraphicFrame::to_element(self : CT_GraphicFrame) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WordprocessingContentPartNonVisual from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WordprocessingContentPartNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingContentPartNonVisual::new(
  element : @xml.Element,
) -> CT_WordprocessingContentPartNonVisual {
  { element, }
}

///|
pub fn CT_WordprocessingContentPartNonVisual::parse(
  element : @xml.Element,
) -> CT_WordprocessingContentPartNonVisual {
  CT_WordprocessingContentPartNonVisual::new(element)
}

///|
pub fn CT_WordprocessingContentPartNonVisual::to_element(
  self : CT_WordprocessingContentPartNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WordprocessingContentPart from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WordprocessingContentPart {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingContentPart::new(
  element : @xml.Element,
) -> CT_WordprocessingContentPart {
  { element, }
}

///|
pub fn CT_WordprocessingContentPart::parse(
  element : @xml.Element,
) -> CT_WordprocessingContentPart {
  CT_WordprocessingContentPart::new(element)
}

///|
pub fn CT_WordprocessingContentPart::to_element(
  self : CT_WordprocessingContentPart,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WordprocessingGroup from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WordprocessingGroup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingGroup::new(
  element : @xml.Element,
) -> CT_WordprocessingGroup {
  { element, }
}

///|
pub fn CT_WordprocessingGroup::parse(
  element : @xml.Element,
) -> CT_WordprocessingGroup {
  CT_WordprocessingGroup::new(element)
}

///|
pub fn CT_WordprocessingGroup::to_element(
  self : CT_WordprocessingGroup,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WordprocessingCanvas from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct CT_WordprocessingCanvas {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingCanvas::new(
  element : @xml.Element,
) -> CT_WordprocessingCanvas {
  { element, }
}

///|
pub fn CT_WordprocessingCanvas::parse(
  element : @xml.Element,
) -> CT_WordprocessingCanvas {
  CT_WordprocessingCanvas::new(element)
}

///|
pub fn CT_WordprocessingCanvas::to_element(
  self : CT_WordprocessingCanvas,
) -> @xml.Element {
  self.element
}

///|
/// XSD model group EG_WrapType from dml-wordprocessingDrawing.xsd (§20.4).
pub(all) struct EG_WrapType {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_WrapType::new(elements : Array[@xml.Element]) -> EG_WrapType {
  { elements, }
}

///|
pub fn EG_WrapType::count(self : EG_WrapType) -> Int {
  self.elements.length()
}

///|
pub fn EG_WrapType::contains(self : EG_WrapType, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}
