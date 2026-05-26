// vml-wordprocessingDrawing.xsd typed CT projections — Part 4 §A.7.3.
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
/// XSD complex type CT_Border — Part 4 §A.7.3 (vml-wordprocessingDrawing.xsd).
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
/// Validate the border content model and produce a `CT_Border`. Per
/// Part 4 §A.7.3, `CT_Border` carries the optional `@type`
/// (ST_BorderType enum), `@width` (xsd:positiveInteger), and `@shadow`
/// (ST_BorderShadow enum) attributes and no element children; raises
/// `SchemaViolation` on attribute names or enumeration values outside
/// the schema.
pub fn CT_Border::new(element : @xml.Element) -> CT_Border raise SchemaViolation {
  validate_no_element_children(element, "CT_Border")
  for attribute in element.attributes {
    match attribute.name.local_name {
      "type" => check_enum(attribute.value, "CT_Border/@type", is_border_type)
      "width" => check_positive_integer(attribute.value, "CT_Border/@width")
      "shadow" =>
        check_enum(attribute.value, "CT_Border/@shadow", is_border_shadow)
      other =>
        raise SchemaViolation(
          schema="vml-wordprocessingDrawing.xsd",
          path="CT_Border/@" + other,
          reason="CT_Border does not declare this attribute",
        )
    }
  }
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
/// XSD complex type CT_Wrap — Part 4 §A.7.3 (vml-wordprocessingDrawing.xsd).
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
/// Validate the wrap content model and produce a `CT_Wrap`. Per Part
/// 4 §A.7.3, `CT_Wrap` carries optional `@type` (ST_WrapType),
/// `@side` (ST_WrapSide), `@anchorx` (ST_HorizontalAnchor), and
/// `@anchory` (ST_VerticalAnchor) attributes and no element children;
/// raises `SchemaViolation` on attribute names or enumeration values
/// outside the schema.
pub fn CT_Wrap::new(element : @xml.Element) -> CT_Wrap raise SchemaViolation {
  validate_no_element_children(element, "CT_Wrap")
  for attribute in element.attributes {
    match attribute.name.local_name {
      "type" => check_enum(attribute.value, "CT_Wrap/@type", is_wrap_type)
      "side" => check_enum(attribute.value, "CT_Wrap/@side", is_wrap_side)
      "anchorx" =>
        check_enum(attribute.value, "CT_Wrap/@anchorx", is_horizontal_anchor)
      "anchory" =>
        check_enum(attribute.value, "CT_Wrap/@anchory", is_vertical_anchor)
      other =>
        raise SchemaViolation(
          schema="vml-wordprocessingDrawing.xsd",
          path="CT_Wrap/@" + other,
          reason="CT_Wrap does not declare this attribute",
        )
    }
  }
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
/// XSD complex type CT_AnchorLock — Part 4 §A.7.3 (vml-wordprocessingDrawing.xsd).
/// Empty sentinel element that locks an anchored shape to its current
/// position.
pub(all) struct CT_AnchorLock {
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
/// Validate the empty content model and produce a `CT_AnchorLock`.
/// Per Part 4 §A.7.3, `CT_AnchorLock` is an empty complex type with
/// no attributes and no element children; raises `SchemaViolation` if
/// the source element carries either.
pub fn CT_AnchorLock::new(
  element : @xml.Element,
) -> CT_AnchorLock raise SchemaViolation {
  if element.attributes.length() > 0 {
    raise SchemaViolation(
      schema="vml-wordprocessingDrawing.xsd",
      path="CT_AnchorLock/@*",
      reason="CT_AnchorLock must not declare any attributes",
    )
  }
  validate_no_element_children(element, "CT_AnchorLock")
  { raw_element: element }
}

///|
fn validate_no_element_children(
  element : @xml.Element,
  type_name : String,
) -> Unit raise SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(_) {
      raise SchemaViolation(
        schema="vml-wordprocessingDrawing.xsd",
        path=type_name + "/*",
        reason=type_name + " must not contain element children",
      )
    }
  }
}

///|
fn check_enum(
  value : String,
  path : String,
  predicate : (String) -> Bool,
) -> Unit raise SchemaViolation {
  if !predicate(value) {
    raise SchemaViolation(
      schema="vml-wordprocessingDrawing.xsd",
      path~,
      reason="value not in enumeration: " + value,
    )
  }
}

///|
fn check_positive_integer(
  value : String,
  path : String,
) -> Unit raise SchemaViolation {
  let mut is_positive = value.length() > 0
  let mut all_digits = true
  let mut non_zero = false
  for ch in value {
    if ch < '0' || ch > '9' {
      all_digits = false
      break
    }
    if ch != '0' {
      non_zero = true
    }
  }
  if !all_digits || !non_zero {
    is_positive = false
  }
  if !is_positive {
    raise SchemaViolation(
      schema="vml-wordprocessingDrawing.xsd",
      path~,
      reason="xsd:positiveInteger required: " + value,
    )
  }
}

///|
fn is_border_type(value : String) -> Bool {
  match value {
    "none"
    | "single"
    | "thick"
    | "double"
    | "hairline"
    | "dot"
    | "dash"
    | "dotDash"
    | "dashDotDot"
    | "triple"
    | "thinThickSmall"
    | "thickThinSmall"
    | "thickBetweenThinSmall"
    | "thinThick"
    | "thickThin"
    | "thickBetweenThin"
    | "thinThickLarge"
    | "thickThinLarge"
    | "thickBetweenThinLarge"
    | "wave"
    | "doubleWave"
    | "dashedSmall"
    | "dashDotStroked"
    | "threeDEmboss"
    | "threeDEngrave"
    | "HTMLOutset"
    | "HTMLInset" => true
    _ => false
  }
}

///|
fn is_border_shadow(value : String) -> Bool {
  match value {
    "t" | "true" | "f" | "false" => true
    _ => false
  }
}

///|
fn is_wrap_type(value : String) -> Bool {
  match value {
    "topAndBottom" | "square" | "none" | "tight" | "through" => true
    _ => false
  }
}

///|
fn is_wrap_side(value : String) -> Bool {
  match value {
    "both" | "left" | "right" | "largest" => true
    _ => false
  }
}

///|
fn is_horizontal_anchor(value : String) -> Bool {
  match value {
    "margin" | "page" | "text" | "char" => true
    _ => false
  }
}

///|
fn is_vertical_anchor(value : String) -> Bool {
  match value {
    "margin" | "page" | "text" | "line" => true
    _ => false
  }
}

///|
pub fn CT_AnchorLock::to_element(self : CT_AnchorLock) -> @xml.Element {
  self.raw_element
}
