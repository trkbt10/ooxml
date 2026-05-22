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
    "ST_AlignH" => ";left;right;center;inside;outside;"
    "ST_AlignV" => ";top;bottom;center;inside;outside;"
    _ => ""
  }
}

///|
/// XSD simple type ST_WrapDistance — Part 1 §20.4.3.6.
/// Restriction of xsd:unsignedInt — a one-dimensional distance stored in EMUs.
/// Carried as Int64 because xsd:unsignedInt covers 0..2^32-1.
pub struct ST_WrapDistance {
  emus : Int64
} derive(Eq, Debug)

///|
/// Parse the ST_WrapDistance lexical value (unsigned integer EMUs).
pub fn ST_WrapDistance::parse(
  s : String,
) -> ST_WrapDistance raise SchemaViolation {
  if s.length() == 0 {
    raise_schema_violation("ST_WrapDistance", s, "empty lexical value")
  }
  let mut i = 0
  let mut n : Int64 = 0L
  while i < s.length() {
    let ch = s[i:i + 1]
    if ch < "0" || ch > "9" {
      raise_schema_violation(
        "ST_WrapDistance", s, "non-digit in unsignedInt lexical form",
      )
    }
    let d = (ch[0].to_int() - "0"[0].to_int()).to_int64()
    n = n * 10L + d
    i = i + 1
  }
  { emus: n }
}

///|
/// Construct ST_WrapDistance while enforcing the xsd:unsignedInt lexical form.
pub fn ST_WrapDistance::new(
  s : String,
) -> ST_WrapDistance raise SchemaViolation {
  ST_WrapDistance::parse(s)
}

///|
/// Read the typed distance value in EMUs.
pub fn ST_WrapDistance::value(self : ST_WrapDistance) -> Int64 {
  self.emus
}

///|
/// Return the canonical lexical value for ST_WrapDistance.
pub fn ST_WrapDistance::to_string(self : ST_WrapDistance) -> String {
  self.emus.to_string()
}

///|
/// XSD simple type ST_WrapText — Part 1 §20.4.3.7.
/// Restriction of xsd:token to the 4-value wrap-side enumeration.
pub(all) enum ST_WrapText {
  WrapTextBothSides
  WrapTextLargest
  WrapTextLeft
  WrapTextRight
} derive(Eq, Debug)

///|
/// Parse the ST_WrapText schema lexical value.
pub fn ST_WrapText::parse(s : String) -> ST_WrapText raise SchemaViolation {
  match s {
    "bothSides" => WrapTextBothSides
    "largest" => WrapTextLargest
    "left" => WrapTextLeft
    "right" => WrapTextRight
    _ => raise_schema_violation("ST_WrapText", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_WrapText while enforcing the dml-wordprocessingDrawing.xsd
/// enumeration.
pub fn ST_WrapText::new(s : String) -> ST_WrapText raise SchemaViolation {
  ST_WrapText::parse(s)
}

///|
/// Return the schema lexical value for ST_WrapText.
pub fn ST_WrapText::to_string(self : ST_WrapText) -> String {
  match self {
    WrapTextBothSides => "bothSides"
    WrapTextLargest => "largest"
    WrapTextLeft => "left"
    WrapTextRight => "right"
  }
}

///|
/// XSD simple type ST_PositionOffset — Part 1 §20.4.3.3 absolute
/// position offset (`<xsd:int>`, signed 32-bit integer in English
/// Metric Units). Stored as a native `Int` so callers can read the
/// offset directly without re-parsing the lexical form.
pub struct ST_PositionOffset {
  emus : Int
} derive(Eq, Debug)

///|
/// Part 1 §20.4.3.3 — decode the signed-integer lexical form.
pub fn ST_PositionOffset::parse(
  s : String,
) -> ST_PositionOffset raise SchemaViolation {
  { emus: parse_wml_signed_int("ST_PositionOffset", s) }
}

///|
pub fn ST_PositionOffset::new(
  s : String,
) -> ST_PositionOffset raise SchemaViolation {
  ST_PositionOffset::parse(s)
}

///|
/// Render the offset back to its canonical decimal lexical form.
pub fn ST_PositionOffset::to_string(self : ST_PositionOffset) -> String {
  self.emus.to_string()
}

///|
/// Numeric accessor — the offset in English Metric Units.
pub fn ST_PositionOffset::to_int(self : ST_PositionOffset) -> Int {
  self.emus
}

///|
/// XSD simple type ST_AlignH — Part 1 §20.4.3.1.
/// Restriction of xsd:token to {left, right, center, inside, outside},
/// the horizontal alignment positions relative to the parent
/// alignment base.
pub(all) enum ST_AlignH {
  AlignHLeft
  AlignHRight
  AlignHCenter
  AlignHInside
  AlignHOutside
} derive(Eq, Debug)

///|
/// Parse the ST_AlignH schema lexical value.
pub fn ST_AlignH::parse(s : String) -> ST_AlignH raise SchemaViolation {
  match s {
    "left" => AlignHLeft
    "right" => AlignHRight
    "center" => AlignHCenter
    "inside" => AlignHInside
    "outside" => AlignHOutside
    _ => raise_schema_violation("ST_AlignH", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_AlignH while enforcing the
/// dml-wordprocessingDrawing.xsd enumeration.
pub fn ST_AlignH::new(s : String) -> ST_AlignH raise SchemaViolation {
  ST_AlignH::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_AlignH.
pub fn ST_AlignH::to_string(self : ST_AlignH) -> String {
  match self {
    AlignHLeft => "left"
    AlignHRight => "right"
    AlignHCenter => "center"
    AlignHInside => "inside"
    AlignHOutside => "outside"
  }
}

///|
/// XSD simple type ST_RelFromH — Part 1 §20.4.3.4 horizontal
/// relative-positioning anchor enumeration. Eight lexical values as
/// listed in dml-wordprocessingDrawing.xsd §20.4.
pub(all) enum ST_RelFromH {
  /// §20.4.3.4 "margin"
  RelFromHMargin
  /// §20.4.3.4 "page"
  RelFromHPage
  /// §20.4.3.4 "column"
  RelFromHColumn
  /// §20.4.3.4 "character"
  RelFromHCharacter
  /// §20.4.3.4 "leftMargin"
  RelFromHLeftMargin
  /// §20.4.3.4 "rightMargin"
  RelFromHRightMargin
  /// §20.4.3.4 "insideMargin"
  RelFromHInsideMargin
  /// §20.4.3.4 "outsideMargin"
  RelFromHOutsideMargin
} derive(Eq, Debug)

///|
/// Part 1 §20.4.3.4 — decode the horizontal anchor lexical token.
pub fn ST_RelFromH::parse(s : String) -> ST_RelFromH raise SchemaViolation {
  match s {
    "margin" => RelFromHMargin
    "page" => RelFromHPage
    "column" => RelFromHColumn
    "character" => RelFromHCharacter
    "leftMargin" => RelFromHLeftMargin
    "rightMargin" => RelFromHRightMargin
    "insideMargin" => RelFromHInsideMargin
    "outsideMargin" => RelFromHOutsideMargin
    _ => raise_schema_violation("ST_RelFromH", s, "unknown enumeration value")
  }
}

///|
pub fn ST_RelFromH::new(s : String) -> ST_RelFromH raise SchemaViolation {
  ST_RelFromH::parse(s)
}

///|
pub fn ST_RelFromH::to_string(self : ST_RelFromH) -> String {
  match self {
    RelFromHMargin => "margin"
    RelFromHPage => "page"
    RelFromHColumn => "column"
    RelFromHCharacter => "character"
    RelFromHLeftMargin => "leftMargin"
    RelFromHRightMargin => "rightMargin"
    RelFromHInsideMargin => "insideMargin"
    RelFromHOutsideMargin => "outsideMargin"
  }
}

///|
/// XSD simple type ST_AlignV — Part 1 §20.4.3.2.
/// Restriction of xsd:token to {top, bottom, center, inside, outside},
/// the vertical alignment positions relative to the parent alignment
/// base.
pub(all) enum ST_AlignV {
  AlignVTop
  AlignVBottom
  AlignVCenter
  AlignVInside
  AlignVOutside
} derive(Eq, Debug)

///|
/// Parse the ST_AlignV schema lexical value.
pub fn ST_AlignV::parse(s : String) -> ST_AlignV raise SchemaViolation {
  match s {
    "top" => AlignVTop
    "bottom" => AlignVBottom
    "center" => AlignVCenter
    "inside" => AlignVInside
    "outside" => AlignVOutside
    _ => raise_schema_violation("ST_AlignV", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_AlignV while enforcing the
/// dml-wordprocessingDrawing.xsd enumeration.
pub fn ST_AlignV::new(s : String) -> ST_AlignV raise SchemaViolation {
  ST_AlignV::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_AlignV.
pub fn ST_AlignV::to_string(self : ST_AlignV) -> String {
  match self {
    AlignVTop => "top"
    AlignVBottom => "bottom"
    AlignVCenter => "center"
    AlignVInside => "inside"
    AlignVOutside => "outside"
  }
}

///|
/// XSD simple type ST_RelFromV — Part 1 §20.4.3.5 vertical
/// relative-positioning anchor enumeration. Eight lexical values per
/// dml-wordprocessingDrawing.xsd §20.4. Variant names are prefixed
/// `RelFromV` to avoid clashing with the horizontal counterpart's
/// shared `margin`/`page`/`insideMargin`/`outsideMargin` tokens.
pub(all) enum ST_RelFromV {
  /// §20.4.3.5 "margin"
  RelFromVMargin
  /// §20.4.3.5 "page"
  RelFromVPage
  /// §20.4.3.5 "paragraph"
  RelFromVParagraph
  /// §20.4.3.5 "line"
  RelFromVLine
  /// §20.4.3.5 "topMargin"
  RelFromVTopMargin
  /// §20.4.3.5 "bottomMargin"
  RelFromVBottomMargin
  /// §20.4.3.5 "insideMargin"
  RelFromVInsideMargin
  /// §20.4.3.5 "outsideMargin"
  RelFromVOutsideMargin
} derive(Eq, Debug)

///|
/// Part 1 §20.4.3.5 — decode the vertical anchor lexical token.
pub fn ST_RelFromV::parse(s : String) -> ST_RelFromV raise SchemaViolation {
  match s {
    "margin" => RelFromVMargin
    "page" => RelFromVPage
    "paragraph" => RelFromVParagraph
    "line" => RelFromVLine
    "topMargin" => RelFromVTopMargin
    "bottomMargin" => RelFromVBottomMargin
    "insideMargin" => RelFromVInsideMargin
    "outsideMargin" => RelFromVOutsideMargin
    _ => raise_schema_violation("ST_RelFromV", s, "unknown enumeration value")
  }
}

///|
pub fn ST_RelFromV::new(s : String) -> ST_RelFromV raise SchemaViolation {
  ST_RelFromV::parse(s)
}

///|
pub fn ST_RelFromV::to_string(self : ST_RelFromV) -> String {
  match self {
    RelFromVMargin => "margin"
    RelFromVPage => "page"
    RelFromVParagraph => "paragraph"
    RelFromVLine => "line"
    RelFromVTopMargin => "topMargin"
    RelFromVBottomMargin => "bottomMargin"
    RelFromVInsideMargin => "insideMargin"
    RelFromVOutsideMargin => "outsideMargin"
  }
}

///|
/// XSD simple type ST_WrapType — Part 4 §A.6.3 (vml-wordprocessingDrawing.xsd
/// `ST_WrapType`). Restriction of xsd:string to the five legacy VML wrap
/// modes: `topAndBottom`, `square`, `none`, `tight`, `through`.
pub(all) enum ST_WrapType {
  WrapTypeTopAndBottom
  WrapTypeSquare
  WrapTypeNone
  WrapTypeTight
  WrapTypeThrough
} derive(Eq, Debug)

///|
pub fn ST_WrapType::parse(s : String) -> ST_WrapType raise SchemaViolation {
  match s {
    "topAndBottom" => WrapTypeTopAndBottom
    "square" => WrapTypeSquare
    "none" => WrapTypeNone
    "tight" => WrapTypeTight
    "through" => WrapTypeThrough
    _ => raise_schema_violation("ST_WrapType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_WrapType::to_string(self : ST_WrapType) -> String {
  match self {
    WrapTypeTopAndBottom => "topAndBottom"
    WrapTypeSquare => "square"
    WrapTypeNone => "none"
    WrapTypeTight => "tight"
    WrapTypeThrough => "through"
  }
}

///|
/// XSD simple type ST_WrapSide — Part 4 §A.6.3 (vml-wordprocessingDrawing.xsd
/// `ST_WrapSide`). Restriction of xsd:string to `both`, `left`, `right`,
/// `largest`.
pub(all) enum ST_WrapSide {
  WrapSideBoth
  WrapSideLeft
  WrapSideRight
  WrapSideLargest
} derive(Eq, Debug)

///|
pub fn ST_WrapSide::parse(s : String) -> ST_WrapSide raise SchemaViolation {
  match s {
    "both" => WrapSideBoth
    "left" => WrapSideLeft
    "right" => WrapSideRight
    "largest" => WrapSideLargest
    _ => raise_schema_violation("ST_WrapSide", s, "unknown enumeration value")
  }
}

///|
pub fn ST_WrapSide::to_string(self : ST_WrapSide) -> String {
  match self {
    WrapSideBoth => "both"
    WrapSideLeft => "left"
    WrapSideRight => "right"
    WrapSideLargest => "largest"
  }
}

///|
/// XSD simple type ST_HorizontalAnchor — Part 4 §A.6.3
/// (vml-wordprocessingDrawing.xsd `ST_HorizontalAnchor`). Restriction
/// of xsd:string to `margin`, `page`, `text`, `char`.
pub(all) enum ST_HorizontalAnchor {
  HorizontalAnchorMargin
  HorizontalAnchorPage
  HorizontalAnchorText
  HorizontalAnchorChar
} derive(Eq, Debug)

///|
pub fn ST_HorizontalAnchor::parse(
  s : String,
) -> ST_HorizontalAnchor raise SchemaViolation {
  match s {
    "margin" => HorizontalAnchorMargin
    "page" => HorizontalAnchorPage
    "text" => HorizontalAnchorText
    "char" => HorizontalAnchorChar
    _ =>
      raise_schema_violation(
        "ST_HorizontalAnchor", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_HorizontalAnchor::to_string(self : ST_HorizontalAnchor) -> String {
  match self {
    HorizontalAnchorMargin => "margin"
    HorizontalAnchorPage => "page"
    HorizontalAnchorText => "text"
    HorizontalAnchorChar => "char"
  }
}

///|
/// XSD simple type ST_VerticalAnchor — Part 4 §A.6.3
/// (vml-wordprocessingDrawing.xsd `ST_VerticalAnchor`). Restriction
/// of xsd:string to `margin`, `page`, `text`, `line`.
pub(all) enum ST_VerticalAnchor {
  VerticalAnchorMargin
  VerticalAnchorPage
  VerticalAnchorText
  VerticalAnchorLine
} derive(Eq, Debug)

///|
pub fn ST_VerticalAnchor::parse(
  s : String,
) -> ST_VerticalAnchor raise SchemaViolation {
  match s {
    "margin" => VerticalAnchorMargin
    "page" => VerticalAnchorPage
    "text" => VerticalAnchorText
    "line" => VerticalAnchorLine
    _ =>
      raise_schema_violation(
        "ST_VerticalAnchor", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_VerticalAnchor::to_string(self : ST_VerticalAnchor) -> String {
  match self {
    VerticalAnchorMargin => "margin"
    VerticalAnchorPage => "page"
    VerticalAnchorText => "text"
    VerticalAnchorLine => "line"
  }
}

///|
/// Parse an xsd:boolean lexical value (`true`/`false`/`1`/`0`).
fn wml_drawing_parse_boolean(
  type_name : String,
  attr_name : String,
  raw : String,
) -> Bool raise SchemaViolation {
  match raw {
    "true" | "1" => true
    "false" | "0" => false
    _ =>
      raise_schema_violation(
        type_name,
        attr_name,
        "non-boolean lexical value: " + raw,
      )
  }
}

///|
/// Parse an xsd:unsignedInt lexical value (decimal, 0..2^32-1) into Int64.
fn wml_drawing_parse_unsigned_int(
  type_name : String,
  attr_name : String,
  raw : String,
) -> Int64 raise SchemaViolation {
  if raw.length() == 0 {
    raise_schema_violation(
      type_name, attr_name, "empty unsignedInt lexical value",
    )
  }
  let mut n : Int64 = 0L
  let mut i = 0
  while i < raw.length() {
    let ch = raw[i:i + 1]
    if ch < "0" || ch > "9" {
      raise_schema_violation(
        type_name,
        attr_name,
        "non-digit in unsignedInt lexical value: " + raw,
      )
    }
    let d = (ch[0].to_int() - "0"[0].to_int()).to_int64()
    n = n * 10L + d
    i = i + 1
  }
  n
}

///|
/// Parse an xsd:unsignedShort lexical value (decimal, 0..65535) into Int.
fn wml_drawing_parse_unsigned_short(
  type_name : String,
  attr_name : String,
  raw : String,
) -> Int raise SchemaViolation {
  let n = wml_drawing_parse_unsigned_int(type_name, attr_name, raw)
  if n < 0L || n > 65535L {
    raise_schema_violation(
      type_name,
      attr_name,
      "unsignedShort value outside 0..65535 range: " + raw,
    )
  }
  n.to_int()
}

///|
/// XSD complex type CT_AnchorLock — Part 4 §A.7.3
/// (vml-wordprocessingDrawing.xsd `CT_AnchorLock`). Empty content
/// model — the `w10:anchorlock` marker signals that a VML shape anchor
/// cannot be relocated by consumers and declares no attributes or
/// children. The QName of the source element is retained alongside the
/// raw element so a writer can re-emit the empty marker without
/// re-parsing.
pub(all) struct CT_AnchorLock {
  /// §A.1 — qualified name of the source element (e.g. `w10:anchorlock`).
  name : @xml.QName
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnchorLock::new(element : @xml.Element) -> CT_AnchorLock {
  { name: element.name, element }
}

///|
pub fn CT_AnchorLock::parse(element : @xml.Element) -> CT_AnchorLock {
  CT_AnchorLock::new(element)
}

///|
pub fn CT_AnchorLock::to_element(self : CT_AnchorLock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Wrap — Part 4 §A.7.3 (vml-wordprocessingDrawing.xsd
/// `CT_Wrap`). Empty-content element with four optional attributes
/// (`type`/`side`/`anchorx`/`anchory`) selecting how the VML shape
/// interacts with surrounding text.
pub(all) struct CT_Wrap {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §19.3.2.6 @type (ST_WrapType) — optional wrap mode.
  type_ : ST_WrapType?
  /// §19.3.2.6 @side (ST_WrapSide) — optional wrap side.
  side : ST_WrapSide?
  /// §19.3.2.6 @anchorx (ST_HorizontalAnchor) — optional horizontal anchor.
  anchorx : ST_HorizontalAnchor?
  /// §19.3.2.6 @anchory (ST_VerticalAnchor) — optional vertical anchor.
  anchory : ST_VerticalAnchor?
} derive(Eq, Debug)

///|
pub fn CT_Wrap::new(element : @xml.Element) -> CT_Wrap raise SchemaViolation {
  let type_ = match wml_ct_chunk4_attr(element, "type") {
    Some(text) => Some(ST_WrapType::parse(text))
    None => None
  }
  let side = match wml_ct_chunk4_attr(element, "side") {
    Some(text) => Some(ST_WrapSide::parse(text))
    None => None
  }
  let anchorx = match wml_ct_chunk4_attr(element, "anchorx") {
    Some(text) => Some(ST_HorizontalAnchor::parse(text))
    None => None
  }
  let anchory = match wml_ct_chunk4_attr(element, "anchory") {
    Some(text) => Some(ST_VerticalAnchor::parse(text))
    None => None
  }
  { element, type_, side, anchorx, anchory }
}

///|
pub fn CT_Wrap::parse(element : @xml.Element) -> CT_Wrap raise SchemaViolation {
  CT_Wrap::new(element)
}

///|
pub fn CT_Wrap::to_element(self : CT_Wrap) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EffectExtent — Part 1 §20.4.2.6
/// (dml-wordprocessingDrawing.xsd `CT_EffectExtent`). Four required
/// `a:ST_Coordinate` (EMU) attributes describing the additional
/// rendering-effect padding on each side of the parent extent — the
/// lexical form is preserved as a String because ST_Coordinate lives in
/// the DrawingML package outside this package's typed scope.
pub(all) struct CT_EffectExtent {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.6 @l (a:ST_Coordinate) — required left padding (lex).
  l : String
  /// §20.4.2.6 @t (a:ST_Coordinate) — required top padding (lex).
  t : String
  /// §20.4.2.6 @r (a:ST_Coordinate) — required right padding (lex).
  r : String
  /// §20.4.2.6 @b (a:ST_Coordinate) — required bottom padding (lex).
  b : String
} derive(Eq, Debug)

///|
pub fn CT_EffectExtent::new(
  element : @xml.Element,
) -> CT_EffectExtent raise SchemaViolation {
  let l = wml_ct_chunk4_required_attr(
    element, "l", "CT_EffectExtent", "Part 1 §20.4.2.6 a:ST_Coordinate",
  )
  let t = wml_ct_chunk4_required_attr(
    element, "t", "CT_EffectExtent", "Part 1 §20.4.2.6 a:ST_Coordinate",
  )
  let r = wml_ct_chunk4_required_attr(
    element, "r", "CT_EffectExtent", "Part 1 §20.4.2.6 a:ST_Coordinate",
  )
  let b = wml_ct_chunk4_required_attr(
    element, "b", "CT_EffectExtent", "Part 1 §20.4.2.6 a:ST_Coordinate",
  )
  { element, l, t, r, b }
}

///|
pub fn CT_EffectExtent::parse(
  element : @xml.Element,
) -> CT_EffectExtent raise SchemaViolation {
  CT_EffectExtent::new(element)
}

///|
pub fn CT_EffectExtent::to_element(self : CT_EffectExtent) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Inline — Part 1 §20.4.2.8
/// (dml-wordprocessingDrawing.xsd `CT_Inline`). An inline anchor
/// carrying a required `<extent>` (a:CT_PositiveSize2D), optional
/// `<effectExtent>` (CT_EffectExtent), required `<docPr>`
/// (a:CT_NonVisualDrawingProps), optional `<cNvGraphicFramePr>`
/// (a:CT_NonVisualGraphicFrameProperties), required `<a:graphic>`
/// element ref, plus four optional ST_WrapDistance attributes for
/// distance-from-text on every side. DrawingML-namespaced children are
/// preserved as raw `@xml.Element` because their typed projection lives
/// in the DrawingML package outside this package's dependency set.
pub(all) struct CT_Inline {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.7 `<extent>` (a:CT_PositiveSize2D) — required positive size.
  extent : @xml.Element
  /// §20.4.2.6 `<effectExtent>` (CT_EffectExtent) — optional padding.
  effect_extent : CT_EffectExtent?
  /// §20.4.2.5 `<docPr>` (a:CT_NonVisualDrawingProps) — required.
  doc_pr : @xml.Element
  /// §20.4.2.4 `<cNvGraphicFramePr>` — optional non-visual graphic-frame
  /// properties (a:CT_NonVisualGraphicFrameProperties).
  c_nv_graphic_frame_pr : @xml.Element?
  /// §20.1.2.2.16 `<a:graphic>` (a:CT_GraphicalObject) — required.
  graphic : @xml.Element
  /// §20.4.2.8 @distT (ST_WrapDistance) — optional top distance.
  dist_t : ST_WrapDistance?
  /// §20.4.2.8 @distB (ST_WrapDistance) — optional bottom distance.
  dist_b : ST_WrapDistance?
  /// §20.4.2.8 @distL (ST_WrapDistance) — optional left distance.
  dist_l : ST_WrapDistance?
  /// §20.4.2.8 @distR (ST_WrapDistance) — optional right distance.
  dist_r : ST_WrapDistance?
} derive(Eq, Debug)

///|
pub fn CT_Inline::new(
  element : @xml.Element,
) -> CT_Inline raise SchemaViolation {
  let extent = match wml_ct_chunk4_first_child(element, "extent") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_Inline", "extent", "Part 1 §20.4.2.8: required <wp:extent> missing",
      )
  }
  let effect_extent = match wml_ct_chunk4_first_child(element, "effectExtent") {
    Some(child) => Some(CT_EffectExtent::new(child))
    None => None
  }
  let doc_pr = match wml_ct_chunk4_first_child(element, "docPr") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_Inline", "docPr", "Part 1 §20.4.2.8: required <wp:docPr> missing",
      )
  }
  let c_nv_graphic_frame_pr = wml_ct_chunk4_first_child(
    element, "cNvGraphicFramePr",
  )
  let graphic = match wml_ct_chunk4_first_child(element, "graphic") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_Inline", "graphic", "Part 1 §20.4.2.8: required <a:graphic> missing",
      )
  }
  let dist_t = match wml_ct_chunk4_attr(element, "distT") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_b = match wml_ct_chunk4_attr(element, "distB") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_l = match wml_ct_chunk4_attr(element, "distL") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_r = match wml_ct_chunk4_attr(element, "distR") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  {
    element,
    extent,
    effect_extent,
    doc_pr,
    c_nv_graphic_frame_pr,
    graphic,
    dist_t,
    dist_b,
    dist_l,
    dist_r,
  }
}

///|
pub fn CT_Inline::parse(
  element : @xml.Element,
) -> CT_Inline raise SchemaViolation {
  CT_Inline::new(element)
}

///|
pub fn CT_Inline::to_element(self : CT_Inline) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapPath — Part 1 §20.4.2.16
/// (dml-wordprocessingDrawing.xsd `CT_WrapPath`). Required `<start>`
/// (a:CT_Point2D) followed by two or more `<lineTo>` (a:CT_Point2D)
/// vertices, plus an optional xsd:boolean `@edited` attribute. The
/// DrawingML point elements live outside this package; they are
/// preserved as raw `@xml.Element` here.
pub(all) struct CT_WrapPath {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.15 `<start>` (a:CT_Point2D) — required first vertex.
  start : @a.CT_Point2D
  /// §20.4.2.13 `<lineTo>` (a:CT_Point2D) — at least two further
  /// vertices.
  line_to : Array[@a.CT_Point2D]
  /// §20.4.2.16 @edited (xsd:boolean) — optional edit flag.
  edited : Bool?
} derive(Eq, Debug)

///|
pub fn CT_WrapPath::new(
  element : @xml.Element,
) -> CT_WrapPath raise SchemaViolation {
  let start_el = match wml_ct_chunk4_first_child(element, "start") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_WrapPath", "start", "Part 1 §20.4.2.16: required <wp:start> missing",
      )
  }
  let start = wrap_a_violation(
    fn() { @a.CT_Point2D::new(start_el) },
    "CT_WrapPath/start",
  )
  let line_to_raw = wml_ct_chunk4_children(element, "lineTo")
  if line_to_raw.length() < 2 {
    raise_schema_violation(
      "CT_WrapPath", "lineTo", "Part 1 §20.4.2.16: at least two <wp:lineTo> vertices required",
    )
  }
  let line_to : Array[@a.CT_Point2D] = []
  for p in line_to_raw {
    line_to.push(
      wrap_a_violation(fn() { @a.CT_Point2D::new(p) }, "CT_WrapPath/lineTo"),
    )
  }
  let edited = match wml_ct_chunk4_attr(element, "edited") {
    Some(text) => Some(wml_drawing_parse_boolean("CT_WrapPath", "edited", text))
    None => None
  }
  { element, start, line_to, edited }
}

///|
pub fn CT_WrapPath::parse(
  element : @xml.Element,
) -> CT_WrapPath raise SchemaViolation {
  CT_WrapPath::new(element)
}

///|
pub fn CT_WrapPath::to_element(self : CT_WrapPath) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapNone — Part 1 §20.4.2.14
/// (dml-wordprocessingDrawing.xsd `CT_WrapNone`). Empty content model
/// signalling that text flows behind / in front of the anchored object
/// without any side wrapping. The QName is preserved alongside the raw
/// element so writers can re-emit the empty marker.
pub(all) struct CT_WrapNone {
  /// §A.1 — qualified name of the source element (e.g. `wp:wrapNone`).
  name : @xml.QName
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WrapNone::new(element : @xml.Element) -> CT_WrapNone {
  { name: element.name, element }
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
/// XSD complex type CT_WrapSquare — Part 1 §20.4.2.17
/// (dml-wordprocessingDrawing.xsd `CT_WrapSquare`). Optional
/// `<effectExtent>` (CT_EffectExtent), required `@wrapText`
/// (ST_WrapText), and four optional ST_WrapDistance attributes for
/// distance-from-text on every side.
pub(all) struct CT_WrapSquare {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.6 `<effectExtent>` (CT_EffectExtent) — optional padding.
  effect_extent : CT_EffectExtent?
  /// §20.4.2.17 @wrapText (ST_WrapText) — required wrap-side selector.
  wrap_text : ST_WrapText
  /// §20.4.2.17 @distT (ST_WrapDistance) — optional top distance.
  dist_t : ST_WrapDistance?
  /// §20.4.2.17 @distB (ST_WrapDistance) — optional bottom distance.
  dist_b : ST_WrapDistance?
  /// §20.4.2.17 @distL (ST_WrapDistance) — optional left distance.
  dist_l : ST_WrapDistance?
  /// §20.4.2.17 @distR (ST_WrapDistance) — optional right distance.
  dist_r : ST_WrapDistance?
} derive(Eq, Debug)

///|
pub fn CT_WrapSquare::new(
  element : @xml.Element,
) -> CT_WrapSquare raise SchemaViolation {
  let effect_extent = match wml_ct_chunk4_first_child(element, "effectExtent") {
    Some(child) => Some(CT_EffectExtent::new(child))
    None => None
  }
  let raw_wrap_text = wml_ct_chunk4_required_attr(
    element, "wrapText", "CT_WrapSquare", "Part 1 §20.4.2.17 ST_WrapText",
  )
  let wrap_text = ST_WrapText::parse(raw_wrap_text)
  let dist_t = match wml_ct_chunk4_attr(element, "distT") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_b = match wml_ct_chunk4_attr(element, "distB") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_l = match wml_ct_chunk4_attr(element, "distL") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_r = match wml_ct_chunk4_attr(element, "distR") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  { element, effect_extent, wrap_text, dist_t, dist_b, dist_l, dist_r }
}

///|
pub fn CT_WrapSquare::parse(
  element : @xml.Element,
) -> CT_WrapSquare raise SchemaViolation {
  CT_WrapSquare::new(element)
}

///|
pub fn CT_WrapSquare::to_element(self : CT_WrapSquare) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapTight — Part 1 §20.4.2.18
/// (dml-wordprocessingDrawing.xsd `CT_WrapTight`). Required
/// `<wrapPolygon>` (CT_WrapPath) plus a required `@wrapText`
/// (ST_WrapText) and optional left/right ST_WrapDistance.
pub(all) struct CT_WrapTight {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.19 `<wrapPolygon>` (CT_WrapPath) — required polygon.
  wrap_polygon : CT_WrapPath
  /// §20.4.2.18 @wrapText (ST_WrapText) — required wrap-side selector.
  wrap_text : ST_WrapText
  /// §20.4.2.18 @distL (ST_WrapDistance) — optional left distance.
  dist_l : ST_WrapDistance?
  /// §20.4.2.18 @distR (ST_WrapDistance) — optional right distance.
  dist_r : ST_WrapDistance?
} derive(Eq, Debug)

///|
pub fn CT_WrapTight::new(
  element : @xml.Element,
) -> CT_WrapTight raise SchemaViolation {
  let wrap_polygon = match wml_ct_chunk4_first_child(element, "wrapPolygon") {
    Some(child) => CT_WrapPath::new(child)
    None =>
      raise_schema_violation(
        "CT_WrapTight", "wrapPolygon", "Part 1 §20.4.2.18: required <wp:wrapPolygon> missing",
      )
  }
  let raw_wrap_text = wml_ct_chunk4_required_attr(
    element, "wrapText", "CT_WrapTight", "Part 1 §20.4.2.18 ST_WrapText",
  )
  let wrap_text = ST_WrapText::parse(raw_wrap_text)
  let dist_l = match wml_ct_chunk4_attr(element, "distL") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_r = match wml_ct_chunk4_attr(element, "distR") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  { element, wrap_polygon, wrap_text, dist_l, dist_r }
}

///|
pub fn CT_WrapTight::parse(
  element : @xml.Element,
) -> CT_WrapTight raise SchemaViolation {
  CT_WrapTight::new(element)
}

///|
pub fn CT_WrapTight::to_element(self : CT_WrapTight) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapThrough — Part 1 §20.4.2.20
/// (dml-wordprocessingDrawing.xsd `CT_WrapThrough`). Identical content
/// model to CT_WrapTight (required wrapPolygon + ST_WrapText +
/// left/right distance) — the spec uses the distinct type so writers
/// know which `<w:wrap*>` element to emit.
pub(all) struct CT_WrapThrough {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.19 `<wrapPolygon>` (CT_WrapPath) — required polygon.
  wrap_polygon : CT_WrapPath
  /// §20.4.2.20 @wrapText (ST_WrapText) — required wrap-side selector.
  wrap_text : ST_WrapText
  /// §20.4.2.20 @distL (ST_WrapDistance) — optional left distance.
  dist_l : ST_WrapDistance?
  /// §20.4.2.20 @distR (ST_WrapDistance) — optional right distance.
  dist_r : ST_WrapDistance?
} derive(Eq, Debug)

///|
pub fn CT_WrapThrough::new(
  element : @xml.Element,
) -> CT_WrapThrough raise SchemaViolation {
  let wrap_polygon = match wml_ct_chunk4_first_child(element, "wrapPolygon") {
    Some(child) => CT_WrapPath::new(child)
    None =>
      raise_schema_violation(
        "CT_WrapThrough", "wrapPolygon", "Part 1 §20.4.2.20: required <wp:wrapPolygon> missing",
      )
  }
  let raw_wrap_text = wml_ct_chunk4_required_attr(
    element, "wrapText", "CT_WrapThrough", "Part 1 §20.4.2.20 ST_WrapText",
  )
  let wrap_text = ST_WrapText::parse(raw_wrap_text)
  let dist_l = match wml_ct_chunk4_attr(element, "distL") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_r = match wml_ct_chunk4_attr(element, "distR") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  { element, wrap_polygon, wrap_text, dist_l, dist_r }
}

///|
pub fn CT_WrapThrough::parse(
  element : @xml.Element,
) -> CT_WrapThrough raise SchemaViolation {
  CT_WrapThrough::new(element)
}

///|
pub fn CT_WrapThrough::to_element(self : CT_WrapThrough) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WrapTopBottom — Part 1 §20.4.2.21
/// (dml-wordprocessingDrawing.xsd `CT_WrapTopBottom`). Optional
/// `<effectExtent>` (CT_EffectExtent) plus optional top / bottom
/// ST_WrapDistance attributes (no @wrapText — text only flows above /
/// below the object).
pub(all) struct CT_WrapTopBottom {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.6 `<effectExtent>` (CT_EffectExtent) — optional padding.
  effect_extent : CT_EffectExtent?
  /// §20.4.2.21 @distT (ST_WrapDistance) — optional top distance.
  dist_t : ST_WrapDistance?
  /// §20.4.2.21 @distB (ST_WrapDistance) — optional bottom distance.
  dist_b : ST_WrapDistance?
} derive(Eq, Debug)

///|
pub fn CT_WrapTopBottom::new(
  element : @xml.Element,
) -> CT_WrapTopBottom raise SchemaViolation {
  let effect_extent = match wml_ct_chunk4_first_child(element, "effectExtent") {
    Some(child) => Some(CT_EffectExtent::new(child))
    None => None
  }
  let dist_t = match wml_ct_chunk4_attr(element, "distT") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_b = match wml_ct_chunk4_attr(element, "distB") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  { element, effect_extent, dist_t, dist_b }
}

///|
pub fn CT_WrapTopBottom::parse(
  element : @xml.Element,
) -> CT_WrapTopBottom raise SchemaViolation {
  CT_WrapTopBottom::new(element)
}

///|
pub fn CT_WrapTopBottom::to_element(self : CT_WrapTopBottom) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PosH — Part 1 §20.4.2.10
/// (dml-wordprocessingDrawing.xsd `CT_PosH`). Required xsd:choice
/// between `<align>` (ST_AlignH text content) and `<posOffset>`
/// (ST_PositionOffset text content). Required `@relativeFrom`
/// (ST_RelFromH) selects the base coordinate.
pub(all) struct CT_PosH {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.1 `<align>` (ST_AlignH) — selected when present.
  align : ST_AlignH?
  /// §20.4.2.11 `<posOffset>` (ST_PositionOffset) — selected when present.
  pos_offset : ST_PositionOffset?
  /// §20.4.2.10 @relativeFrom (ST_RelFromH) — required anchor base.
  relative_from : ST_RelFromH
} derive(Eq, Debug)

///|
pub fn CT_PosH::new(element : @xml.Element) -> CT_PosH raise SchemaViolation {
  let raw_rel = wml_ct_chunk4_required_attr(
    element, "relativeFrom", "CT_PosH", "Part 1 §20.4.2.10 ST_RelFromH",
  )
  let relative_from = ST_RelFromH::parse(raw_rel)
  let mut align : ST_AlignH? = None
  let mut pos_offset : ST_PositionOffset? = None
  match wml_ct_chunk7_first_choice(element, ["align", "posOffset"]) {
    Some((child, "align")) => {
      let text = wml_ct_chunk7_text_content(child)
      align = Some(ST_AlignH::parse(text))
    }
    Some((child, "posOffset")) => {
      let text = wml_ct_chunk7_text_content(child)
      pos_offset = Some(ST_PositionOffset::parse(text))
    }
    Some(_) => ()
    None =>
      raise_schema_violation(
        "CT_PosH", "align|posOffset", "Part 1 §20.4.2.10: required xsd:choice <wp:align>|<wp:posOffset> missing",
      )
  }
  { element, align, pos_offset, relative_from }
}

///|
pub fn CT_PosH::parse(element : @xml.Element) -> CT_PosH raise SchemaViolation {
  CT_PosH::new(element)
}

///|
pub fn CT_PosH::to_element(self : CT_PosH) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PosV — Part 1 §20.4.2.12
/// (dml-wordprocessingDrawing.xsd `CT_PosV`). Required xsd:choice
/// between `<align>` (ST_AlignV text content) and `<posOffset>`
/// (ST_PositionOffset text content). Required `@relativeFrom`
/// (ST_RelFromV) selects the base coordinate.
pub(all) struct CT_PosV {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.1 `<align>` (ST_AlignV) — selected when present.
  align : ST_AlignV?
  /// §20.4.2.11 `<posOffset>` (ST_PositionOffset) — selected when present.
  pos_offset : ST_PositionOffset?
  /// §20.4.2.12 @relativeFrom (ST_RelFromV) — required anchor base.
  relative_from : ST_RelFromV
} derive(Eq, Debug)

///|
pub fn CT_PosV::new(element : @xml.Element) -> CT_PosV raise SchemaViolation {
  let raw_rel = wml_ct_chunk4_required_attr(
    element, "relativeFrom", "CT_PosV", "Part 1 §20.4.2.12 ST_RelFromV",
  )
  let relative_from = ST_RelFromV::parse(raw_rel)
  let mut align : ST_AlignV? = None
  let mut pos_offset : ST_PositionOffset? = None
  match wml_ct_chunk7_first_choice(element, ["align", "posOffset"]) {
    Some((child, "align")) => {
      let text = wml_ct_chunk7_text_content(child)
      align = Some(ST_AlignV::parse(text))
    }
    Some((child, "posOffset")) => {
      let text = wml_ct_chunk7_text_content(child)
      pos_offset = Some(ST_PositionOffset::parse(text))
    }
    Some(_) => ()
    None =>
      raise_schema_violation(
        "CT_PosV", "align|posOffset", "Part 1 §20.4.2.12: required xsd:choice <wp:align>|<wp:posOffset> missing",
      )
  }
  { element, align, pos_offset, relative_from }
}

///|
pub fn CT_PosV::parse(element : @xml.Element) -> CT_PosV raise SchemaViolation {
  CT_PosV::new(element)
}

///|
pub fn CT_PosV::to_element(self : CT_PosV) -> @xml.Element {
  self.element
}

///|
/// Concatenate every text node child of `element` (preserving CDATA and
/// whitespace) into a single String. CT_PosH / CT_PosV use this helper
/// to extract the text-content payload of their `<align>` / `<posOffset>`
/// children, which the XSD declares as direct simple-type values.
fn wml_ct_chunk7_text_content(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Text(t) => buf.write_string(t)
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// XSD complex type CT_Anchor — Part 1 §20.4.2.3
/// (dml-wordprocessingDrawing.xsd `CT_Anchor`). Positioned drawing
/// anchor: required `<simplePos>` (a:CT_Point2D), `<positionH>`
/// (CT_PosH), `<positionV>` (CT_PosV), `<extent>` (a:CT_PositiveSize2D),
/// optional `<effectExtent>` (CT_EffectExtent), required EG_WrapType
/// choice (`wrapNone`|`wrapSquare`|`wrapTight`|`wrapThrough`|
/// `wrapTopAndBottom`), required `<docPr>` (a:CT_NonVisualDrawingProps),
/// optional `<cNvGraphicFramePr>`
/// (a:CT_NonVisualGraphicFrameProperties), required `<a:graphic>`
/// element ref. DrawingML-namespaced children stay as raw
/// `@xml.Element`. Attribute set: four optional ST_WrapDistance, an
/// optional xsd:boolean `@simplePos`, a required xsd:unsignedInt
/// `@relativeHeight` (Int64), required xsd:boolean
/// `@behindDoc`/`@locked`/`@layoutInCell`/`@allowOverlap`, and an
/// optional `@hidden`.
pub(all) struct CT_Anchor {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.13 `<simplePos>` (a:CT_Point2D) — required simple position.
  simple_pos_child : @xml.Element
  /// §20.4.2.10 `<positionH>` (CT_PosH) — required horizontal positioning.
  position_h : CT_PosH
  /// §20.4.2.12 `<positionV>` (CT_PosV) — required vertical positioning.
  position_v : CT_PosV
  /// §20.4.2.7 `<extent>` (a:CT_PositiveSize2D) — required positive size.
  extent : @xml.Element
  /// §20.4.2.6 `<effectExtent>` (CT_EffectExtent) — optional padding.
  effect_extent : CT_EffectExtent?
  /// EG_WrapType (wrapNone / wrapSquare / wrapTight / wrapThrough /
  /// wrapTopAndBottom) — exactly one child must be present. The
  /// matched local-name is retained so writers can rebuild the element
  /// without reflective inspection.
  wrap_kind : String
  /// EG_WrapType — the typed projection of the matched wrap child
  /// (kept as raw `@xml.Element` to avoid a sum-type encoding).
  wrap_element : @xml.Element
  /// §20.4.2.5 `<docPr>` (a:CT_NonVisualDrawingProps) — required.
  doc_pr : @xml.Element
  /// §20.4.2.4 `<cNvGraphicFramePr>` — optional non-visual graphic-frame
  /// properties.
  c_nv_graphic_frame_pr : @xml.Element?
  /// §20.1.2.2.16 `<a:graphic>` — required graphical object.
  graphic : @xml.Element
  /// §20.4.2.3 @distT (ST_WrapDistance) — optional top distance.
  dist_t : ST_WrapDistance?
  /// §20.4.2.3 @distB (ST_WrapDistance) — optional bottom distance.
  dist_b : ST_WrapDistance?
  /// §20.4.2.3 @distL (ST_WrapDistance) — optional left distance.
  dist_l : ST_WrapDistance?
  /// §20.4.2.3 @distR (ST_WrapDistance) — optional right distance.
  dist_r : ST_WrapDistance?
  /// §20.4.2.3 @simplePos (xsd:boolean) — optional simple-pos flag.
  simple_pos : Bool?
  /// §20.4.2.3 @relativeHeight (xsd:unsignedInt) — required Z-order.
  relative_height : Int64
  /// §20.4.2.3 @behindDoc (xsd:boolean) — required behind-text flag.
  behind_doc : Bool
  /// §20.4.2.3 @locked (xsd:boolean) — required lock flag.
  locked : Bool
  /// §20.4.2.3 @layoutInCell (xsd:boolean) — required layout-in-cell flag.
  layout_in_cell : Bool
  /// §20.4.2.3 @hidden (xsd:boolean) — optional hidden flag.
  hidden : Bool?
  /// §20.4.2.3 @allowOverlap (xsd:boolean) — required allow-overlap flag.
  allow_overlap : Bool
} derive(Eq, Debug)

///|
pub fn CT_Anchor::new(
  element : @xml.Element,
) -> CT_Anchor raise SchemaViolation {
  let simple_pos_child = match wml_ct_chunk4_first_child(element, "simplePos") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_Anchor", "simplePos", "Part 1 §20.4.2.3: required <wp:simplePos> child missing",
      )
  }
  let position_h = match wml_ct_chunk4_first_child(element, "positionH") {
    Some(child) => CT_PosH::new(child)
    None =>
      raise_schema_violation(
        "CT_Anchor", "positionH", "Part 1 §20.4.2.3: required <wp:positionH> child missing",
      )
  }
  let position_v = match wml_ct_chunk4_first_child(element, "positionV") {
    Some(child) => CT_PosV::new(child)
    None =>
      raise_schema_violation(
        "CT_Anchor", "positionV", "Part 1 §20.4.2.3: required <wp:positionV> child missing",
      )
  }
  let extent = match wml_ct_chunk4_first_child(element, "extent") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_Anchor", "extent", "Part 1 §20.4.2.3: required <wp:extent> child missing",
      )
  }
  let effect_extent = match wml_ct_chunk4_first_child(element, "effectExtent") {
    Some(child) => Some(CT_EffectExtent::new(child))
    None => None
  }
  let (wrap_element, wrap_kind) = match
    wml_ct_chunk7_first_choice(element, [
      "wrapNone", "wrapSquare", "wrapTight", "wrapThrough", "wrapTopAndBottom",
    ]) {
    Some((child, name)) => (child, name)
    None =>
      raise_schema_violation(
        "CT_Anchor", "wrap", "Part 1 §20.4.2.3: required EG_WrapType child missing",
      )
  }
  let doc_pr = match wml_ct_chunk4_first_child(element, "docPr") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_Anchor", "docPr", "Part 1 §20.4.2.3: required <wp:docPr> child missing",
      )
  }
  let c_nv_graphic_frame_pr = wml_ct_chunk4_first_child(
    element, "cNvGraphicFramePr",
  )
  let graphic = match wml_ct_chunk4_first_child(element, "graphic") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_Anchor", "graphic", "Part 1 §20.4.2.3: required <a:graphic> child missing",
      )
  }
  let dist_t = match wml_ct_chunk4_attr(element, "distT") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_b = match wml_ct_chunk4_attr(element, "distB") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_l = match wml_ct_chunk4_attr(element, "distL") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let dist_r = match wml_ct_chunk4_attr(element, "distR") {
    Some(text) => Some(ST_WrapDistance::parse(text))
    None => None
  }
  let simple_pos = match wml_ct_chunk4_attr(element, "simplePos") {
    Some(text) =>
      Some(wml_drawing_parse_boolean("CT_Anchor", "simplePos", text))
    None => None
  }
  let raw_rh = wml_ct_chunk4_required_attr(
    element, "relativeHeight", "CT_Anchor", "Part 1 §20.4.2.3 xsd:unsignedInt",
  )
  let relative_height = wml_drawing_parse_unsigned_int(
    "CT_Anchor", "relativeHeight", raw_rh,
  )
  let raw_bd = wml_ct_chunk4_required_attr(
    element, "behindDoc", "CT_Anchor", "Part 1 §20.4.2.3 xsd:boolean",
  )
  let behind_doc = wml_drawing_parse_boolean("CT_Anchor", "behindDoc", raw_bd)
  let raw_lk = wml_ct_chunk4_required_attr(
    element, "locked", "CT_Anchor", "Part 1 §20.4.2.3 xsd:boolean",
  )
  let locked = wml_drawing_parse_boolean("CT_Anchor", "locked", raw_lk)
  let raw_lic = wml_ct_chunk4_required_attr(
    element, "layoutInCell", "CT_Anchor", "Part 1 §20.4.2.3 xsd:boolean",
  )
  let layout_in_cell = wml_drawing_parse_boolean(
    "CT_Anchor", "layoutInCell", raw_lic,
  )
  let hidden = match wml_ct_chunk4_attr(element, "hidden") {
    Some(text) => Some(wml_drawing_parse_boolean("CT_Anchor", "hidden", text))
    None => None
  }
  let raw_ao = wml_ct_chunk4_required_attr(
    element, "allowOverlap", "CT_Anchor", "Part 1 §20.4.2.3 xsd:boolean",
  )
  let allow_overlap = wml_drawing_parse_boolean(
    "CT_Anchor", "allowOverlap", raw_ao,
  )
  {
    element,
    simple_pos_child,
    position_h,
    position_v,
    extent,
    effect_extent,
    wrap_kind,
    wrap_element,
    doc_pr,
    c_nv_graphic_frame_pr,
    graphic,
    dist_t,
    dist_b,
    dist_l,
    dist_r,
    simple_pos,
    relative_height,
    behind_doc,
    locked,
    layout_in_cell,
    hidden,
    allow_overlap,
  }
}

///|
pub fn CT_Anchor::parse(
  element : @xml.Element,
) -> CT_Anchor raise SchemaViolation {
  CT_Anchor::new(element)
}

///|
pub fn CT_Anchor::to_element(self : CT_Anchor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TxbxContent — Part 1 §20.4.2.22
/// (dml-wordprocessingDrawing.xsd `CT_TxbxContent`). Wraps
/// `xsd:group ref="w:EG_BlockLevelElts" minOccurs="1"
/// maxOccurs="unbounded"` — typed block-level children in document
/// order.
pub(all) struct CT_TxbxContent {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.2.2 EG_BlockLevelElts (1..unbounded) — typed block-level
  /// projections in document order.
  block_level_elts : Array[EG_BlockLevelElts]
} derive(Eq, Debug)

///|
pub fn CT_TxbxContent::new(
  element : @xml.Element,
) -> CT_TxbxContent raise SchemaViolation {
  let raw : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => raw.push(e)
      _ => ()
    }
  }
  let block_level_elts = collect_block_level_elements(raw)
  { element, block_level_elts }
}

///|
pub fn CT_TxbxContent::parse(
  element : @xml.Element,
) -> CT_TxbxContent raise SchemaViolation {
  CT_TxbxContent::new(element)
}

///|
pub fn CT_TxbxContent::to_element(self : CT_TxbxContent) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextboxInfo — Part 1 §20.4.2.24
/// (dml-wordprocessingDrawing.xsd `CT_TextboxInfo`). Sequence: required
/// `<txbxContent>` (CT_TxbxContent) and optional `<extLst>`
/// (a:CT_OfficeArtExtensionList — preserved raw because the typed
/// projection lives in the DrawingML package). Optional `@id`
/// (xsd:unsignedShort, default 0).
pub(all) struct CT_TextboxInfo {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.22 `<txbxContent>` (CT_TxbxContent) — required.
  txbx_content : CT_TxbxContent
  /// §20.1.2.2.15 `<extLst>`? — optional extension list (raw element).
  ext_lst : @xml.Element?
  /// §20.4.2.24 @id (xsd:unsignedShort) — optional textbox id (default 0).
  id : Int?
} derive(Eq, Debug)

///|
pub fn CT_TextboxInfo::new(
  element : @xml.Element,
) -> CT_TextboxInfo raise SchemaViolation {
  let txbx_content = match wml_ct_chunk4_first_child(element, "txbxContent") {
    Some(child) => CT_TxbxContent::new(child)
    None =>
      raise_schema_violation(
        "CT_TextboxInfo", "txbxContent", "Part 1 §20.4.2.24: required <wp:txbxContent> child missing",
      )
  }
  let ext_lst = wml_ct_chunk4_first_child(element, "extLst")
  let id = match wml_ct_chunk4_attr(element, "id") {
    Some(text) =>
      Some(wml_drawing_parse_unsigned_short("CT_TextboxInfo", "id", text))
    None => None
  }
  { element, txbx_content, ext_lst, id }
}

///|
pub fn CT_TextboxInfo::parse(
  element : @xml.Element,
) -> CT_TextboxInfo raise SchemaViolation {
  CT_TextboxInfo::new(element)
}

///|
pub fn CT_TextboxInfo::to_element(self : CT_TextboxInfo) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LinkedTextboxInformation — Part 1 §20.4.2.9
/// (dml-wordprocessingDrawing.xsd `CT_LinkedTextboxInformation`).
/// Optional `<extLst>` (a:CT_OfficeArtExtensionList — raw) plus two
/// required xsd:unsignedShort attributes (`@id`, `@seq`) linking the
/// textbox into a chain.
pub(all) struct CT_LinkedTextboxInformation {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.1.2.2.15 `<extLst>`? — optional extension list (raw element).
  ext_lst : @xml.Element?
  /// §20.4.2.9 @id (xsd:unsignedShort) — required textbox id.
  id : Int
  /// §20.4.2.9 @seq (xsd:unsignedShort) — required chain sequence id.
  seq : Int
} derive(Eq, Debug)

///|
pub fn CT_LinkedTextboxInformation::new(
  element : @xml.Element,
) -> CT_LinkedTextboxInformation raise SchemaViolation {
  let ext_lst = wml_ct_chunk4_first_child(element, "extLst")
  let raw_id = wml_ct_chunk4_required_attr(
    element, "id", "CT_LinkedTextboxInformation", "Part 1 §20.4.2.9 xsd:unsignedShort",
  )
  let id = wml_drawing_parse_unsigned_short(
    "CT_LinkedTextboxInformation", "id", raw_id,
  )
  let raw_seq = wml_ct_chunk4_required_attr(
    element, "seq", "CT_LinkedTextboxInformation", "Part 1 §20.4.2.9 xsd:unsignedShort",
  )
  let seq = wml_drawing_parse_unsigned_short(
    "CT_LinkedTextboxInformation", "seq", raw_seq,
  )
  { element, ext_lst, id, seq }
}

///|
pub fn CT_LinkedTextboxInformation::parse(
  element : @xml.Element,
) -> CT_LinkedTextboxInformation raise SchemaViolation {
  CT_LinkedTextboxInformation::new(element)
}

///|
pub fn CT_LinkedTextboxInformation::to_element(
  self : CT_LinkedTextboxInformation,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WordprocessingShape — Part 1 §20.4.2.26
/// (dml-wordprocessingDrawing.xsd `CT_WordprocessingShape`). Sequence:
///   `<cNvPr>`? + xsd:choice (`<cNvSpPr>`|`<cNvCnPr>`) + `<spPr>` +
///   `<style>`? + `<extLst>`? + xsd:choice (`<txbx>`|`<linkedTxbx>`)? +
///   `<bodyPr>`. The DrawingML children are preserved as raw
///   `@xml.Element` because their typed projection lives outside this
///   package's dependency set. `<txbx>` and `<linkedTxbx>` are typed
///   because they live in the wordprocessingDrawing schema. Optional
///   xsd:boolean `@normalEastAsianFlow` (default `false`).
pub(all) struct CT_WordprocessingShape {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.5 `<cNvPr>` (a:CT_NonVisualDrawingProps) — optional.
  c_nv_pr : @xml.Element?
  /// EG_NonVisualShapeProps — selected `<cNvSpPr>` or `<cNvCnPr>` (raw).
  /// Required choice; the matched local name is preserved separately.
  non_visual_shape_kind : String
  /// The matched `<cNvSpPr>` / `<cNvCnPr>` payload (raw element).
  non_visual_shape_element : @xml.Element
  /// §20.4.2.27 `<spPr>` (a:CT_ShapeProperties) — required.
  sp_pr : @xml.Element
  /// §20.4.2.23 `<style>` (a:CT_ShapeStyle) — optional.
  style : @xml.Element?
  /// §20.1.2.2.15 `<extLst>` — optional extension list (raw).
  ext_lst : @xml.Element?
  /// `<txbx>` (CT_TextboxInfo) — selected when present; mutually
  /// exclusive with `<linkedTxbx>`.
  txbx : CT_TextboxInfo?
  /// `<linkedTxbx>` (CT_LinkedTextboxInformation) — selected when
  /// present; mutually exclusive with `<txbx>`.
  linked_txbx : CT_LinkedTextboxInformation?
  /// §20.4.2.2 `<bodyPr>` (a:CT_TextBodyProperties) — required.
  body_pr : @xml.Element
  /// §20.4.2.26 @normalEastAsianFlow (xsd:boolean, default false).
  normal_east_asian_flow : Bool?
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingShape::new(
  element : @xml.Element,
) -> CT_WordprocessingShape raise SchemaViolation {
  let c_nv_pr = wml_ct_chunk4_first_child(element, "cNvPr")
  let (non_visual_shape_element, non_visual_shape_kind) = match
    wml_ct_chunk7_first_choice(element, ["cNvSpPr", "cNvCnPr"]) {
    Some((child, name)) => (child, name)
    None =>
      raise_schema_violation(
        "CT_WordprocessingShape", "cNvSpPr|cNvCnPr", "Part 1 §20.4.2.26: required xsd:choice <wp:cNvSpPr>|<wp:cNvCnPr> missing",
      )
  }
  let sp_pr = match wml_ct_chunk4_first_child(element, "spPr") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_WordprocessingShape", "spPr", "Part 1 §20.4.2.26: required <wp:spPr> child missing",
      )
  }
  let style = wml_ct_chunk4_first_child(element, "style")
  let ext_lst = wml_ct_chunk4_first_child(element, "extLst")
  let txbx = match wml_ct_chunk4_first_child(element, "txbx") {
    Some(child) => Some(CT_TextboxInfo::new(child))
    None => None
  }
  let linked_txbx = match wml_ct_chunk4_first_child(element, "linkedTxbx") {
    Some(child) => Some(CT_LinkedTextboxInformation::new(child))
    None => None
  }
  let body_pr = match wml_ct_chunk4_first_child(element, "bodyPr") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_WordprocessingShape", "bodyPr", "Part 1 §20.4.2.26: required <wp:bodyPr> child missing",
      )
  }
  let normal_east_asian_flow = match
    wml_ct_chunk4_attr(element, "normalEastAsianFlow") {
    Some(text) =>
      Some(
        wml_drawing_parse_boolean(
          "CT_WordprocessingShape", "normalEastAsianFlow", text,
        ),
      )
    None => None
  }
  {
    element,
    c_nv_pr,
    non_visual_shape_kind,
    non_visual_shape_element,
    sp_pr,
    style,
    ext_lst,
    txbx,
    linked_txbx,
    body_pr,
    normal_east_asian_flow,
  }
}

///|
pub fn CT_WordprocessingShape::parse(
  element : @xml.Element,
) -> CT_WordprocessingShape raise SchemaViolation {
  CT_WordprocessingShape::new(element)
}

///|
pub fn CT_WordprocessingShape::to_element(
  self : CT_WordprocessingShape,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicFrame — Part 1 §20.4.2.7
/// (dml-wordprocessingDrawing.xsd `CT_GraphicFrame`). Sequence: required
/// `<cNvPr>`, `<cNvFrPr>`, `<xfrm>`, `<a:graphic>`, plus optional
/// `<extLst>`. DrawingML-namespaced children are preserved as raw
/// `@xml.Element` because their typed projection lives outside this
/// package's dependency set.
pub(all) struct CT_GraphicFrame {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.5 `<cNvPr>` (a:CT_NonVisualDrawingProps) — required.
  c_nv_pr : @xml.Element
  /// §20.4.2.4 `<cNvFrPr>` (a:CT_NonVisualGraphicFrameProperties) — required.
  c_nv_fr_pr : @xml.Element
  /// §20.1.7.6 `<xfrm>` (a:CT_Transform2D) — required transform.
  xfrm : @xml.Element
  /// §20.1.2.2.16 `<a:graphic>` — required graphical object.
  graphic : @xml.Element
  /// §20.1.2.2.15 `<extLst>` — optional extension list.
  ext_lst : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_GraphicFrame::new(
  element : @xml.Element,
) -> CT_GraphicFrame raise SchemaViolation {
  let c_nv_pr = match wml_ct_chunk4_first_child(element, "cNvPr") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_GraphicFrame", "cNvPr", "Part 1 §20.4.2.7: required <wp:cNvPr> child missing",
      )
  }
  let c_nv_fr_pr = match wml_ct_chunk4_first_child(element, "cNvFrPr") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_GraphicFrame", "cNvFrPr", "Part 1 §20.4.2.7: required <wp:cNvFrPr> child missing",
      )
  }
  let xfrm = match wml_ct_chunk4_first_child(element, "xfrm") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_GraphicFrame", "xfrm", "Part 1 §20.4.2.7: required <wp:xfrm> child missing",
      )
  }
  let graphic = match wml_ct_chunk4_first_child(element, "graphic") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_GraphicFrame", "graphic", "Part 1 §20.4.2.7: required <a:graphic> child missing",
      )
  }
  let ext_lst = wml_ct_chunk4_first_child(element, "extLst")
  { element, c_nv_pr, c_nv_fr_pr, xfrm, graphic, ext_lst }
}

///|
pub fn CT_GraphicFrame::parse(
  element : @xml.Element,
) -> CT_GraphicFrame raise SchemaViolation {
  CT_GraphicFrame::new(element)
}

///|
pub fn CT_GraphicFrame::to_element(self : CT_GraphicFrame) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WordprocessingContentPartNonVisual — Part 1
/// §20.4.2.25 (dml-wordprocessingDrawing.xsd
/// `CT_WordprocessingContentPartNonVisual`). Two optional children
/// (`<cNvPr>` / `<cNvContentPartPr>`) — DrawingML-namespaced and kept
/// as raw `@xml.Element` because their typed projections live outside
/// this package's dependency set.
pub(all) struct CT_WordprocessingContentPartNonVisual {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.5 `<cNvPr>` (a:CT_NonVisualDrawingProps) — optional.
  c_nv_pr : @xml.Element?
  /// §20.4.2.3 `<cNvContentPartPr>` (a:CT_NonVisualContentPartProperties) — optional.
  c_nv_content_part_pr : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingContentPartNonVisual::new(
  element : @xml.Element,
) -> CT_WordprocessingContentPartNonVisual {
  let c_nv_pr = wml_ct_chunk4_first_child(element, "cNvPr")
  let c_nv_content_part_pr = wml_ct_chunk4_first_child(
    element, "cNvContentPartPr",
  )
  { element, c_nv_pr, c_nv_content_part_pr }
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
/// XSD complex type CT_WordprocessingContentPart — Part 1 §20.4.2.4a
/// (dml-wordprocessingDrawing.xsd `CT_WordprocessingContentPart`).
/// Optional `<nvContentPartPr>` (CT_WordprocessingContentPartNonVisual),
/// optional `<xfrm>` (a:CT_Transform2D — raw), optional `<extLst>`
/// (a:CT_OfficeArtExtensionList — raw). Optional `@bwMode`
/// (a:ST_BlackWhiteMode — preserved lexically because the typed simple
/// type lives in the DrawingML package) and required `@r:id`
/// (relationships namespace, preserved lexically).
pub(all) struct CT_WordprocessingContentPart {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.25 `<nvContentPartPr>` — optional non-visual properties.
  nv_content_part_pr : CT_WordprocessingContentPartNonVisual?
  /// §20.1.7.6 `<xfrm>` — optional transform (raw element).
  xfrm : @xml.Element?
  /// §20.1.2.2.15 `<extLst>` — optional extension list (raw element).
  ext_lst : @xml.Element?
  /// @bwMode (a:ST_BlackWhiteMode) — optional black/white-mode token,
  /// preserved lexically because the typed enum lives outside this
  /// package's typed scope.
  bw_mode : String?
  /// @r:id (xsd:string) — required relationship id, preserved lexically.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingContentPart::new(
  element : @xml.Element,
) -> CT_WordprocessingContentPart raise SchemaViolation {
  let nv_content_part_pr = match
    wml_ct_chunk4_first_child(element, "nvContentPartPr") {
    Some(child) => Some(CT_WordprocessingContentPartNonVisual::new(child))
    None => None
  }
  let xfrm = wml_ct_chunk4_first_child(element, "xfrm")
  let ext_lst = wml_ct_chunk4_first_child(element, "extLst")
  let bw_mode = wml_ct_chunk4_attr(element, "bwMode")
  let r_id = wml_ct_chunk4_required_attr(
    element, "id", "CT_WordprocessingContentPart", "Part 1 §20.4.2.4a r:id (relationships namespace)",
  )
  { element, nv_content_part_pr, xfrm, ext_lst, bw_mode, r_id }
}

///|
pub fn CT_WordprocessingContentPart::parse(
  element : @xml.Element,
) -> CT_WordprocessingContentPart raise SchemaViolation {
  CT_WordprocessingContentPart::new(element)
}

///|
pub fn CT_WordprocessingContentPart::to_element(
  self : CT_WordprocessingContentPart,
) -> @xml.Element {
  self.element
}

///|
/// XSD model group choice for `<wp:wgp>` body — Part 1 §20.4.2.28.
/// Each entry surfaces the typed projection of the chosen child
/// element (wsp / grpSp / graphicFrame / dpct:pic / contentPart).
pub(all) enum WpGroupChild {
  /// <wp:wsp> — CT_WordprocessingShape.
  Wsp(CT_WordprocessingShape)
  /// <wp:grpSp> — CT_WordprocessingGroup (recursive).
  GrpSp(CT_WordprocessingGroup)
  /// <wp:graphicFrame> — CT_GraphicFrame.
  GraphicFrame(CT_GraphicFrame)
  /// <dpct:pic> — drawing_ml/picture CT_Picture.
  Pic(@dml_pic.CT_Picture)
  /// <wp:contentPart> — CT_WordprocessingContentPart.
  ContentPart(CT_WordprocessingContentPart)
} derive(Eq, Debug)

///|
/// XSD complex type CT_WordprocessingGroup — Part 1 §20.4.2.28
/// (dml-wordprocessingDrawing.xsd `CT_WordprocessingGroup`).
pub(all) struct CT_WordprocessingGroup {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.4.2.5 `<cNvPr>` (a:CT_NonVisualDrawingProps) — optional.
  c_nv_pr : @a.CT_NonVisualDrawingProps?
  /// §20.4.2.4 `<cNvGrpSpPr>` (a:CT_NonVisualGroupDrawingShapeProps)
  /// — required.
  c_nv_grp_sp_pr : @a.CT_NonVisualGroupDrawingShapeProps
  /// §20.1.2.2.18 `<grpSpPr>` (a:CT_GroupShapeProperties) — required.
  grp_sp_pr : @a.CT_GroupShapeProperties
  /// xsd:choice body — typed projections of wsp / grpSp /
  /// graphicFrame / dpct:pic / contentPart in document order.
  group_body : Array[WpGroupChild]
  /// §20.1.2.2.15 `<extLst>` (a:CT_OfficeArtExtensionList) — optional.
  ext_lst : @a.CT_OfficeArtExtensionList?
} derive(Eq, Debug)

///|
/// Bridge `@dml_pic.SchemaViolation` into our local SchemaViolation.
fn wrap_dml_pic_violation[T](
  body : () -> T raise @dml_pic.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @dml_pic.SchemaViolation(_) =>
      raise SchemaViolation(
        type_name=path,
        value="",
        reason="dml-picture.xsd child failed validation",
      )
  }
}

///|
pub fn CT_WordprocessingGroup::new(
  element : @xml.Element,
) -> CT_WordprocessingGroup raise SchemaViolation {
  let c_nv_pr = match wml_ct_chunk4_first_child(element, "cNvPr") {
    Some(c) =>
      Some(
        wrap_a_violation(
          fn() { @a.CT_NonVisualDrawingProps::new(c) },
          "CT_WordprocessingGroup/cNvPr",
        ),
      )
    None => None
  }
  let c_nv_grp_sp_pr_el = match wml_ct_chunk4_first_child(element, "cNvGrpSpPr") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_WordprocessingGroup", "cNvGrpSpPr", "Part 1 §20.4.2.28: required <wp:cNvGrpSpPr> child missing",
      )
  }
  let c_nv_grp_sp_pr = wrap_a_violation(
    fn() { @a.CT_NonVisualGroupDrawingShapeProps::new(c_nv_grp_sp_pr_el) },
    "CT_WordprocessingGroup/cNvGrpSpPr",
  )
  let grp_sp_pr_el = match wml_ct_chunk4_first_child(element, "grpSpPr") {
    Some(child) => child
    None =>
      raise_schema_violation(
        "CT_WordprocessingGroup", "grpSpPr", "Part 1 §20.4.2.28: required <wp:grpSpPr> child missing",
      )
  }
  let grp_sp_pr = wrap_a_violation(
    fn() { @a.CT_GroupShapeProperties::new(grp_sp_pr_el) },
    "CT_WordprocessingGroup/grpSpPr",
  )
  let group_body : Array[WpGroupChild] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "cNvPr" | "cNvGrpSpPr" | "grpSpPr" | "extLst" => ()
          "wsp" => group_body.push(Wsp(CT_WordprocessingShape::new(e)))
          "grpSp" => group_body.push(GrpSp(CT_WordprocessingGroup::new(e)))
          "graphicFrame" => group_body.push(GraphicFrame(CT_GraphicFrame::new(e)))
          "pic" =>
            group_body.push(
              Pic(
                wrap_dml_pic_violation(
                  fn() { @dml_pic.CT_Picture::new(e) },
                  "CT_WordprocessingGroup/pic",
                ),
              ),
            )
          "contentPart" =>
            group_body.push(ContentPart(CT_WordprocessingContentPart::new(e)))
          other =>
            raise SchemaViolation(
              type_name="CT_WordprocessingGroup",
              value=other,
              reason="Part 1 §20.4.2.28: unknown group body child element",
            )
        }
      _ => ()
    }
  }
  let ext_lst = match wml_ct_chunk4_first_child(element, "extLst") {
    Some(c) =>
      Some(
        wrap_a_violation(
          fn() { @a.CT_OfficeArtExtensionList::new(c) },
          "CT_WordprocessingGroup/extLst",
        ),
      )
    None => None
  }
  { element, c_nv_pr, c_nv_grp_sp_pr, grp_sp_pr, group_body, ext_lst }
}

///|
pub fn CT_WordprocessingGroup::parse(
  element : @xml.Element,
) -> CT_WordprocessingGroup raise SchemaViolation {
  CT_WordprocessingGroup::new(element)
}

///|
pub fn CT_WordprocessingGroup::to_element(
  self : CT_WordprocessingGroup,
) -> @xml.Element {
  self.element
}

///|
/// XSD model group choice for `<wp:wpc>` body — Part 1 §20.4.2.29.
pub(all) enum WpCanvasChild {
  /// <wp:wsp> — CT_WordprocessingShape.
  Wsp(CT_WordprocessingShape)
  /// <dpct:pic> — drawing_ml/picture CT_Picture.
  Pic(@dml_pic.CT_Picture)
  /// <wp:contentPart> — CT_WordprocessingContentPart.
  ContentPart(CT_WordprocessingContentPart)
  /// <wp:wgp> — CT_WordprocessingGroup.
  Wgp(CT_WordprocessingGroup)
  /// <wp:graphicFrame> — CT_GraphicFrame.
  GraphicFrame(CT_GraphicFrame)
} derive(Eq, Debug)

///|
/// XSD complex type CT_WordprocessingCanvas — Part 1 §20.4.2.29
/// (dml-wordprocessingDrawing.xsd `CT_WordprocessingCanvas`).
pub(all) struct CT_WordprocessingCanvas {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §20.1.2.2.4 `<bg>` (a:CT_BackgroundFormatting) — optional.
  bg : @a.CT_BackgroundFormatting?
  /// §20.1.2.2.34 `<whole>` (a:CT_WholeE2oFormatting) — optional.
  whole : @a.CT_WholeE2oFormatting?
  /// xsd:choice body — typed projections of wsp / dpct:pic /
  /// contentPart / wgp / graphicFrame in document order.
  canvas_body : Array[WpCanvasChild]
  /// §20.1.2.2.15 `<extLst>` (a:CT_OfficeArtExtensionList) — optional.
  ext_lst : @a.CT_OfficeArtExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_WordprocessingCanvas::new(
  element : @xml.Element,
) -> CT_WordprocessingCanvas raise SchemaViolation {
  let bg = match wml_ct_chunk4_first_child(element, "bg") {
    Some(c) =>
      Some(
        wrap_a_violation(
          fn() { @a.CT_BackgroundFormatting::new(c) },
          "CT_WordprocessingCanvas/bg",
        ),
      )
    None => None
  }
  let whole = match wml_ct_chunk4_first_child(element, "whole") {
    Some(c) =>
      Some(
        wrap_a_violation(
          fn() { @a.CT_WholeE2oFormatting::new(c) },
          "CT_WordprocessingCanvas/whole",
        ),
      )
    None => None
  }
  let canvas_body : Array[WpCanvasChild] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "bg" | "whole" | "extLst" => ()
          "wsp" => canvas_body.push(Wsp(CT_WordprocessingShape::new(e)))
          "pic" =>
            canvas_body.push(
              Pic(
                wrap_dml_pic_violation(
                  fn() { @dml_pic.CT_Picture::new(e) },
                  "CT_WordprocessingCanvas/pic",
                ),
              ),
            )
          "contentPart" =>
            canvas_body.push(ContentPart(CT_WordprocessingContentPart::new(e)))
          "wgp" => canvas_body.push(Wgp(CT_WordprocessingGroup::new(e)))
          "graphicFrame" =>
            canvas_body.push(GraphicFrame(CT_GraphicFrame::new(e)))
          other =>
            raise SchemaViolation(
              type_name="CT_WordprocessingCanvas",
              value=other,
              reason="Part 1 §20.4.2.29: unknown canvas body child element",
            )
        }
      _ => ()
    }
  }
  let ext_lst = match wml_ct_chunk4_first_child(element, "extLst") {
    Some(c) =>
      Some(
        wrap_a_violation(
          fn() { @a.CT_OfficeArtExtensionList::new(c) },
          "CT_WordprocessingCanvas/extLst",
        ),
      )
    None => None
  }
  { element, bg, whole, canvas_body, ext_lst }
}

///|
pub fn CT_WordprocessingCanvas::parse(
  element : @xml.Element,
) -> CT_WordprocessingCanvas raise SchemaViolation {
  CT_WordprocessingCanvas::new(element)
}

///|
pub fn CT_WordprocessingCanvas::to_element(
  self : CT_WordprocessingCanvas,
) -> @xml.Element {
  self.element
}

///|
/// XSD model group EG_WrapType — dml-wordprocessingDrawing.xsd (§20.4).
/// Required choice of one wrap-mode child: wrapNone / wrapSquare /
/// wrapTight / wrapThrough / wrapTopAndBottom.
pub(all) enum EG_WrapType {
  WrapNone(CT_WrapNone)
  WrapSquare(CT_WrapSquare)
  WrapTight(CT_WrapTight)
  WrapThrough(CT_WrapThrough)
  WrapTopAndBottom(CT_WrapTopBottom)
} derive(Eq, Debug)

///|
pub fn parse_wrap_type_child(
  element : @xml.Element,
) -> EG_WrapType? raise SchemaViolation {
  match element.name.local_name {
    "wrapNone" => Some(WrapNone(CT_WrapNone::new(element)))
    "wrapSquare" => Some(WrapSquare(CT_WrapSquare::new(element)))
    "wrapTight" => Some(WrapTight(CT_WrapTight::new(element)))
    "wrapThrough" => Some(WrapThrough(CT_WrapThrough::new(element)))
    "wrapTopAndBottom" => Some(WrapTopAndBottom(CT_WrapTopBottom::new(element)))
    _ => None
  }
}

///|
pub fn find_wrap_type_child(
  element : @xml.Element,
) -> EG_WrapType? raise SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(e) {
      match parse_wrap_type_child(e) {
        Some(w) => return Some(w)
        None => ()
      }
    }
  }
  None
}

///|
/// Bridge `@a.SchemaViolation` into the local one so DrawingML
/// projections (CT_Point2D, CT_PositiveSize2D, CT_GraphicalObject,
/// etc.) raise this package's SchemaViolation when consumed.
fn wrap_a_violation[T](
  body : () -> T raise @a.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @a.SchemaViolation(schema=_, path=p, reason~) =>
      raise SchemaViolation(
        type_name=path + " (" + p + ")",
        value="",
        reason~,
      )
  }
}
