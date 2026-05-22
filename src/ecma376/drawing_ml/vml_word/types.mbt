// vml-wordprocessingDrawing.xsd typed CT projections — Part 4 §A.6.64..§A.6.66.
// Target namespace: urn:schemas-microsoft-com:office:word (`w10:` prefix).
// Schema: dml-wordprocessingDrawing.xsd companion vml-*.xsd bundle.

///|
/// Schema validation error raised by the typed CT readers in this
/// package.
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// Look up an attribute on an element by local name. The four CT
/// types in this package only carry unqualified attributes (the
/// namespace prefix is captured by the parent element's qualifier).
fn w10_attr(element : @xml.Element, name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == name {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// XSD complex type CT_Border — Part 4 §A.6.64 (vml-wordprocessingDrawing.xsd).
/// Shape border declaration. Attributes: @type (ST_BorderType),
/// @width (xsd:positiveInteger), @shadow (ST_BorderShadow). Used by
/// `w10:bordertop`, `w10:borderleft`, `w10:borderright`,
/// `w10:borderbottom`.
pub(all) struct CT_Border {
  /// @type — border line style.
  type_ : String?
  /// @width — border width in 1/8 point units.
  width : String?
  /// @shadow — border shadow flag.
  shadow : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Border::new(element : @xml.Element) -> CT_Border {
  let type_ = w10_attr(element, "type")
  let width = w10_attr(element, "width")
  let shadow = w10_attr(element, "shadow")
  { type_, width, shadow, raw_element: element }
}

///|
pub fn CT_Border::to_element(self : CT_Border) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Wrap — Part 4 §A.6.65 (vml-wordprocessingDrawing.xsd).
/// WordprocessingML text-wrap declaration. Attributes: @type (ST_WrapType),
/// @side (ST_WrapSide), @anchorx (ST_HorizontalAnchor), @anchory
/// (ST_VerticalAnchor).
pub(all) struct CT_Wrap {
  /// @type — wrap mode (topAndBottom, square, none, tight, through).
  type_ : String?
  /// @side — wrap side (both, left, right, largest).
  side : String?
  /// @anchorx — horizontal anchor (margin, page, text, char).
  anchorx : String?
  /// @anchory — vertical anchor (margin, page, text, line).
  anchory : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Wrap::new(element : @xml.Element) -> CT_Wrap {
  let type_ = w10_attr(element, "type")
  let side = w10_attr(element, "side")
  let anchorx = w10_attr(element, "anchorx")
  let anchory = w10_attr(element, "anchory")
  { type_, side, anchorx, anchory, raw_element: element }
}

///|
pub fn CT_Wrap::to_element(self : CT_Wrap) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_AnchorLock — Part 4 §A.6.66 (vml-wordprocessingDrawing.xsd).
/// Empty sentinel element that locks an anchored shape to its current
/// position.
pub(all) struct CT_AnchorLock {
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnchorLock::new(element : @xml.Element) -> CT_AnchorLock {
  { raw_element: element }
}

///|
pub fn CT_AnchorLock::to_element(self : CT_AnchorLock) -> @xml.Element {
  self.raw_element
}
