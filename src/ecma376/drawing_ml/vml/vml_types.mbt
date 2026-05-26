// VML drawing schemas — Part 4 §A.6 / §15 — typed CT_* views over the
// XSD-defined attribute and child element vocabulary. Each struct fully
// enumerates the attribute groups and child element list of its source
// XSD complex type. The original `@xml.Element` is preserved as
// `raw_element` so writers can round-trip the source bytes verbatim
// while consumers query typed accessors instead of poking raw XML.

///|
/// EG_ShapeElements + the three extra CT_Shape/CT_Group choices
/// (o:ink / pvml:iscomment / o:equationxml). Mirrors the
/// unbounded choice declared in vml-main.xsd at:
///
///   <xsd:group name="EG_ShapeElements">
///   <xsd:complexType name="CT_Shape">
///   <xsd:complexType name="CT_Group">
///
/// Every arm is typed — cross-namespace elements (`o:*` / `w10:*` /
/// `x:*` / `pvml:*`) dispatch through the dedicated companion
/// packages (`vml_word`, `vml_excel`, `vml_presentation`). The
/// remaining `o:*` CT_* projections still live in this file and
/// will be split off in a follow-up to `vml_office`. There is no
/// untyped fallback arm — schema-unknown children raise
/// SchemaViolation at construction time so callers can't silently
/// drop content.
pub(all) enum VmlShapeChild {
  /// <v:path …/> — CT_Path.
  Path(CT_Path)
  /// <v:formulas …/> — CT_Formulas.
  Formulas(CT_Formulas)
  /// <v:handles …/> — CT_Handles.
  Handles(CT_Handles)
  /// <v:fill …/> — CT_Fill.
  Fill(CT_Fill)
  /// <v:stroke …/> — CT_Stroke.
  Stroke(CT_Stroke)
  /// <v:shadow …/> — CT_Shadow.
  Shadow(CT_Shadow)
  /// <v:textbox …/> — CT_Textbox.
  Textbox(CT_Textbox)
  /// <v:textpath …/> — CT_TextPath.
  Textpath(CT_TextPath)
  /// <v:imagedata …/> — CT_ImageData.
  Imagedata(CT_ImageData)
  /// <o:skew …/> — CT_Skew.
  Skew(CT_Skew)
  /// <o:extrusion …/> — CT_Extrusion.
  Extrusion(CT_Extrusion)
  /// <o:callout …/> — CT_Callout.
  Callout(CT_Callout)
  /// <o:lock …/> — CT_Lock.
  Lock(CT_Lock)
  /// <o:clippath …/> — CT_ClipPath.
  Clippath(CT_ClipPath)
  /// <o:signatureline …/> — CT_SignatureLine.
  SignatureLine(CT_SignatureLine)
  /// <o:ink …/> — CT_Ink (CT_Shape/CT_Group extra).
  Ink(CT_Ink)
  /// <o:equationxml …/> — CT_EquationXml (CT_Shape/CT_Group extra).
  EquationXml(CT_EquationXml)
  /// <w10:wrap …/> — CT_Wrap (vml_word).
  Wrap(@vml_word.CT_Wrap)
  /// <w10:anchorlock/> — CT_AnchorLock (vml_word).
  AnchorLock(@vml_word.CT_AnchorLock)
  /// <w10:bordertop …/> — CT_Border (vml_word).
  BorderTop(@vml_word.CT_Border)
  /// <w10:borderbottom …/> — CT_Border (vml_word).
  BorderBottom(@vml_word.CT_Border)
  /// <w10:borderleft …/> — CT_Border (vml_word).
  BorderLeft(@vml_word.CT_Border)
  /// <w10:borderright …/> — CT_Border (vml_word).
  BorderRight(@vml_word.CT_Border)
  /// <x:ClientData …/> — CT_ClientData (vml_excel).
  ClientData(@vml_excel.CT_ClientData)
  /// <pvml:iscomment/> — CT_Empty (vml_presentation).
  Iscomment(@vml_presentation.CT_Empty)
  /// <pvml:textdata …/> — CT_Rel (vml_presentation).
  Textdata(@vml_presentation.CT_Rel)
} derive(Eq, Debug)

///|
/// Bridge `@vml_excel.SchemaViolation` into this package's local one.
fn[T] wrap_vml_excel_violation(
  body : () -> T raise @vml_excel.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @vml_excel.SchemaViolation(schema=_, path=p, reason~) =>
      raise SchemaViolation(
        schema="vml-spreadsheetDrawing.xsd",
        path=path + " (" + p + ")",
        reason~,
      )
  }
}

///|
/// Bridge `@vml_presentation.SchemaViolation` into this package's local one.
fn[T] wrap_vml_presentation_violation(
  body : () -> T raise @vml_presentation.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @vml_presentation.SchemaViolation(schema=_, path=p, reason~) =>
      raise SchemaViolation(
        schema="vml-presentationDrawing.xsd",
        path=path + " (" + p + ")",
        reason~,
      )
  }
}

///|
/// Bridge `@vml_word.SchemaViolation` into this package's local one.
fn[T] wrap_vml_word_violation(
  body : () -> T raise @vml_word.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @vml_word.SchemaViolation(schema=_, path=p, reason~) =>
      raise SchemaViolation(
        schema="vml-wordprocessingDrawing.xsd",
        path=path + " (" + p + ")",
        reason~,
      )
  }
}

///|
/// Parse a single VML shape-element child into the typed sum. Every
/// EG_ShapeElements / CT_Shape extra / CT_Group extra arm declared by
/// vml-main.xsd, vml-officeDrawing.xsd, vml-wordprocessingDrawing.xsd,
/// vml-spreadsheetDrawing.xsd and vml-presentationDrawing.xsd is
/// handled. Elements whose local name doesn't match any schema arm
/// raise SchemaViolation — no untyped passthrough.
pub fn parse_vml_shape_child(
  element : @xml.Element,
) -> VmlShapeChild raise SchemaViolation {
  match element.name.local_name {
    // EG_ShapeElements — local v: arm.
    "path" => Path(CT_Path::new(element))
    "formulas" => Formulas(CT_Formulas::new(element))
    "handles" => Handles(CT_Handles::new(element))
    "fill" => Fill(CT_Fill::new(element))
    "stroke" => Stroke(CT_Stroke::new(element))
    "shadow" => Shadow(CT_Shadow::new(element))
    "textbox" => Textbox(CT_Textbox::new(element))
    "textpath" => Textpath(CT_TextPath::new(element))
    "imagedata" => Imagedata(CT_ImageData::new(element))
    // EG_ShapeElements — o: arm (vml-officeDrawing.xsd).
    "skew" => Skew(CT_Skew::new(element))
    "extrusion" => Extrusion(CT_Extrusion::new(element))
    "callout" => Callout(CT_Callout::new(element))
    "lock" => Lock(CT_Lock::new(element))
    "clippath" => Clippath(CT_ClipPath::new(element))
    "signatureline" => SignatureLine(CT_SignatureLine::new(element))
    // CT_Shape / CT_Group extras (still o:).
    "ink" => Ink(CT_Ink::new(element))
    "equationxml" => EquationXml(CT_EquationXml::new(element))
    // EG_ShapeElements — w10: arm (vml-wordprocessingDrawing.xsd).
    "wrap" =>
      Wrap(
        wrap_vml_word_violation(
          () => @vml_word.CT_Wrap::new(element),
          "VmlShapeChild/w10:wrap",
        ),
      )
    "anchorlock" =>
      AnchorLock(
        wrap_vml_word_violation(
          () => @vml_word.CT_AnchorLock::new(element),
          "VmlShapeChild/w10:anchorlock",
        ),
      )
    "bordertop" =>
      BorderTop(
        wrap_vml_word_violation(
          () => @vml_word.CT_Border::new(element),
          "VmlShapeChild/w10:bordertop",
        ),
      )
    "borderbottom" =>
      BorderBottom(
        wrap_vml_word_violation(
          () => @vml_word.CT_Border::new(element),
          "VmlShapeChild/w10:borderbottom",
        ),
      )
    "borderleft" =>
      BorderLeft(
        wrap_vml_word_violation(
          () => @vml_word.CT_Border::new(element),
          "VmlShapeChild/w10:borderleft",
        ),
      )
    "borderright" =>
      BorderRight(
        wrap_vml_word_violation(
          () => @vml_word.CT_Border::new(element),
          "VmlShapeChild/w10:borderright",
        ),
      )
    // EG_ShapeElements — x: arm (vml-spreadsheetDrawing.xsd).
    "ClientData" =>
      ClientData(
        wrap_vml_excel_violation(
          () => @vml_excel.CT_ClientData::new(element),
          "VmlShapeChild/x:ClientData",
        ),
      )
    // CT_Shape / CT_Group extras — pvml: arm
    // (vml-presentationDrawing.xsd).
    "iscomment" =>
      Iscomment(
        wrap_vml_presentation_violation(
          () => @vml_presentation.CT_Empty::new(element),
          "VmlShapeChild/pvml:iscomment",
        ),
      )
    "textdata" =>
      Textdata(
        wrap_vml_presentation_violation(
          () => @vml_presentation.CT_Rel::new(element),
          "VmlShapeChild/pvml:textdata",
        ),
      )
    other =>
      raise SchemaViolation(
        schema="vml-main.xsd",
        path="VmlShapeChild",
        reason="unknown EG_ShapeElements / CT_Shape / CT_Group choice arm: " +
          other,
      )
  }
}

///|
/// Collect every VML shape-element child of `element` into typed
/// projections in document order. Used by CT_Shape / CT_Shapetype
/// readers.
pub fn collect_vml_shape_children(
  element : @xml.Element,
) -> Array[VmlShapeChild] raise SchemaViolation {
  let out : Array[VmlShapeChild] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      out.push(parse_vml_shape_child(child_element))
    }
  }
  out
}

///|
/// CT_Group child elements per vml-main.xsd. CT_Group's choice is
/// EG_ShapeElements + 12 shape sub-types (arc/curve/image/line/oval/
/// polyline/rect/roundrect/shape/shapetype/group/o:diagram). Embeds
/// `VmlShapeChild` for the shared shape-element arms.
pub(all) enum VmlGroupChild {
  /// Any of the EG_ShapeElements / o:* / w10:* arms.
  ShapeElement(VmlShapeChild)
  /// <v:group …/> — CT_Group (recursive).
  Group(CT_Group)
  /// <v:shape …/> — CT_Shape.
  Shape(CT_Shape)
  /// <v:shapetype …/> — CT_Shapetype.
  Shapetype(CT_Shapetype)
  /// <v:arc …/> — CT_Arc.
  Arc(CT_Arc)
  /// <v:curve …/> — CT_Curve.
  Curve(CT_Curve)
  /// <v:image …/> — CT_Image.
  Image(CT_Image)
  /// <v:line …/> — CT_Line.
  Line(CT_Line)
  /// <v:oval …/> — CT_Oval.
  Oval(CT_Oval)
  /// <v:polyline …/> — CT_PolyLine.
  PolyLine(CT_PolyLine)
  /// <v:rect …/> — CT_Rect.
  Rect(CT_Rect)
  /// <v:roundrect …/> — CT_RoundRect.
  RoundRect(CT_RoundRect)
  /// <o:diagram …/> — CT_Diagram.
  Diagram(CT_Diagram)
} derive(Eq, Debug)

///|
pub fn parse_vml_group_child(
  element : @xml.Element,
) -> VmlGroupChild raise SchemaViolation {
  match element.name.local_name {
    "group" => Group(CT_Group::new(element))
    "shape" => Shape(CT_Shape::new(element))
    "shapetype" => Shapetype(CT_Shapetype::new(element))
    "arc" => Arc(CT_Arc::new(element))
    "curve" => Curve(CT_Curve::new(element))
    "image" => Image(CT_Image::new(element))
    "line" => Line(CT_Line::new(element))
    "oval" => Oval(CT_Oval::new(element))
    "polyline" => PolyLine(CT_PolyLine::new(element))
    "rect" => Rect(CT_Rect::new(element))
    "roundrect" => RoundRect(CT_RoundRect::new(element))
    "diagram" => Diagram(CT_Diagram::new(element))
    _ => ShapeElement(parse_vml_shape_child(element))
  }
}

///|
pub fn collect_vml_group_children(
  element : @xml.Element,
) -> Array[VmlGroupChild] raise SchemaViolation {
  let out : Array[VmlGroupChild] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      out.push(parse_vml_group_child(child_element))
    }
  }
  out
}

///|
/// Look up an attribute on an element by local name. VML attribute
/// names are unqualified in the source schema, so we ignore the
/// namespace prefix and match the local name directly.
fn vml_attr(element : @xml.Element, name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == name {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// Collect the first child element with the given local name.
fn vml_first_child(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == local_name {
        return Some(child_element)
      }
    }
  }
  None
}

///|
/// Collect every child element with the given local name in source order.
fn vml_children(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let result : Array[@xml.Element] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == local_name {
        result.push(child_element)
      }
    }
  }
  result
}

///|
/// Parse an `s:ST_TrueFalse` token reported via XSD. Accepts the
/// `t`/`f` / `true`/`false` / `1`/`0` lexical forms specified in
/// ECMA-376 shared simple types. Returns `None` only for the empty
/// string sentinel used by `s:ST_TrueFalseBlank` callers.
fn parse_truefalse(
  attr_name : String,
  raw : String,
) -> Bool raise SchemaViolation {
  match raw {
    "t" | "true" | "True" | "1" => true
    "f" | "false" | "False" | "0" => false
    _ =>
      raise SchemaViolation(
        schema=attr_name,
        path="value",
        reason="not a boolean token",
      )
  }
}

///|
/// XSD complex type CT_Shape — Part 4 §A.6.1 (vml-main.xsd). Element-rich
/// shape carrier: attribute groups AG_AllCoreAttributes, AG_AllShapeAttributes,
/// AG_Type, AG_Adj, AG_Path; additional attributes `equationxml` and the
/// ref `o:gfxdata`; choice content of EG_ShapeElements, `o:ink`,
/// `pvml:iscomment`, `o:equationxml`.
pub(all) struct CT_Shape {
  /// @id (AG_Id, optional).
  id : String?
  /// @style (AG_Style, optional). Consumers needing a typed
  /// projection should call `parse_vml_style(s)` (declared in
  /// `vml_inline_style.mbt`) per Part 4 §6.1; round-trip via
  /// `format_vml_style`.
  style : String?
  /// @href (AG_CoreAttributes, optional).
  href : String?
  /// @target (AG_CoreAttributes, optional).
  target : String?
  /// @class (AG_CoreAttributes, optional).
  class_ : String?
  /// @title (AG_CoreAttributes, optional).
  title : String?
  /// @alt (AG_CoreAttributes, optional).
  alt : String?
  /// @coordsize (AG_CoreAttributes, optional).
  coordsize : String?
  /// @coordorigin (AG_CoreAttributes, optional).
  coordorigin : String?
  /// @wrapcoords (AG_CoreAttributes, optional). Polyline path
  /// string per Part 4 §6.1; no typed projection because the
  /// grammar is `x,y` coordinate pairs with no enum constraint.
  wrapcoords : String?
  /// @print (AG_CoreAttributes, optional, s:ST_TrueFalse).
  print : Bool?
  /// @opacity (AG_ShapeAttributes, optional).
  opacity : String?
  /// @stroked (AG_ShapeAttributes, optional, s:ST_TrueFalse).
  stroked : Bool?
  /// @strokecolor (AG_ShapeAttributes, optional).
  strokecolor : String?
  /// @strokeweight (AG_ShapeAttributes, optional).
  strokeweight : String?
  /// @insetpen (AG_ShapeAttributes, optional, s:ST_TrueFalse).
  insetpen : Bool?
  /// @chromakey (AG_Chromakey, optional).
  chromakey : String?
  /// @filled (AG_Fill, optional, s:ST_TrueFalse).
  filled : Bool?
  /// @fillcolor (AG_Fill, optional).
  fillcolor : String?
  /// @type (AG_Type, optional). VML shape template reference.
  type_ : String?
  /// @adj (AG_Adj, optional).
  adj : String?
  /// @path (AG_Path, optional).
  path : String?
  /// @equationxml (optional).
  equationxml : String?
  /// AG_OfficeCoreAttributes and AG_OfficeShapeAttributes carry many
  /// `o:`-prefixed attributes (spid, oned, regroupid, etc.). They are
  /// preserved verbatim via `office_attributes` keyed by local name.
  office_attributes : Array[@xml.Attribute]
  /// EG_ShapeElements / `o:ink` / `pvml:iscomment` / `o:equationxml`
  /// children preserved as raw nodes so the writer can round-trip the
  /// source bytes. Each entry's `name.local_name` identifies the kind.
  shape_children : Array[VmlShapeChild]
  /// Source element preserved for byte-perfect round-trip writing.
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
/// Split attributes between the typed accessor list and the bag of
/// office attributes preserved verbatim.
fn collect_office_attributes(element : @xml.Element) -> Array[@xml.Attribute] {
  let bag : Array[@xml.Attribute] = []
  for attribute in element.attributes {
    match attribute.name.prefix {
      Some(prefix) => if prefix == "o" || prefix == "r" { bag.push(attribute) }
      None => ()
    }
  }
  bag
}

///|
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape raise SchemaViolation {
  let id = vml_attr(element, "id")
  let style = vml_attr(element, "style")
  let href = vml_attr(element, "href")
  let target = vml_attr(element, "target")
  let class_ = vml_attr(element, "class")
  let title = vml_attr(element, "title")
  let alt = vml_attr(element, "alt")
  let coordsize = vml_attr(element, "coordsize")
  let coordorigin = vml_attr(element, "coordorigin")
  let wrapcoords = vml_attr(element, "wrapcoords")
  let print = match vml_attr(element, "print") {
    Some(value) => Some(parse_truefalse("CT_Shape/@print", value))
    None => None
  }
  let opacity = vml_attr(element, "opacity")
  let stroked = match vml_attr(element, "stroked") {
    Some(value) => Some(parse_truefalse("CT_Shape/@stroked", value))
    None => None
  }
  let strokecolor = vml_attr(element, "strokecolor")
  let strokeweight = vml_attr(element, "strokeweight")
  let insetpen = match vml_attr(element, "insetpen") {
    Some(value) => Some(parse_truefalse("CT_Shape/@insetpen", value))
    None => None
  }
  let chromakey = vml_attr(element, "chromakey")
  let filled = match vml_attr(element, "filled") {
    Some(value) => Some(parse_truefalse("CT_Shape/@filled", value))
    None => None
  }
  let fillcolor = vml_attr(element, "fillcolor")
  let type_ = vml_attr(element, "type")
  let adj = vml_attr(element, "adj")
  let path = vml_attr(element, "path")
  let equationxml = vml_attr(element, "equationxml")
  let office_attributes = collect_office_attributes(element)
  let shape_children = collect_vml_shape_children(element)
  {
    id,
    style,
    href,
    target,
    class_,
    title,
    alt,
    coordsize,
    coordorigin,
    wrapcoords,
    print,
    opacity,
    stroked,
    strokecolor,
    strokeweight,
    insetpen,
    chromakey,
    filled,
    fillcolor,
    type_,
    adj,
    path,
    equationxml,
    office_attributes,
    shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_Shape::to_element(self : CT_Shape) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Shapetype — Part 4 §A.6.2 (vml-main.xsd). Mirrors
/// CT_Shape attributes (AG_AllCoreAttributes, AG_AllShapeAttributes,
/// AG_Adj, AG_Path) plus `o:master`; sequence of EG_ShapeElements and an
/// optional `o:complex`.
pub(all) struct CT_Shapetype {
  /// @id (AG_Id).
  id : String?
  /// @style (AG_Style). Use `parse_vml_style(...)` for the
  /// typed projection per Part 4 §6.1.
  style : String?
  /// AG_CoreAttributes string-valued attributes (href .. wrapcoords).
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  /// @print (AG_CoreAttributes, s:ST_TrueFalse).
  print : Bool?
  /// AG_ShapeAttributes opacity .. insetpen.
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  /// @chromakey (AG_Chromakey).
  chromakey : String?
  /// AG_Fill.
  filled : Bool?
  fillcolor : String?
  /// @adj (AG_Adj).
  adj : String?
  /// @path (AG_Path).
  path : String?
  /// o:master attribute reference.
  master : String?
  /// AG_OfficeCoreAttributes / AG_OfficeShapeAttributes verbatim.
  office_attributes : Array[@xml.Attribute]
  /// EG_ShapeElements children in source order.
  shape_children : Array[VmlShapeChild]
  /// <o:complex> optional child (CT_Complex).
  complex : CT_Complex?
  /// Source element preserved for round-trip writing.
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shapetype::new(
  element : @xml.Element,
) -> CT_Shapetype raise SchemaViolation {
  let id = vml_attr(element, "id")
  let style = vml_attr(element, "style")
  let href = vml_attr(element, "href")
  let target = vml_attr(element, "target")
  let class_ = vml_attr(element, "class")
  let title = vml_attr(element, "title")
  let alt = vml_attr(element, "alt")
  let coordsize = vml_attr(element, "coordsize")
  let coordorigin = vml_attr(element, "coordorigin")
  let wrapcoords = vml_attr(element, "wrapcoords")
  let print = match vml_attr(element, "print") {
    Some(v) => Some(parse_truefalse("CT_Shapetype/@print", v))
    None => None
  }
  let opacity = vml_attr(element, "opacity")
  let stroked = match vml_attr(element, "stroked") {
    Some(v) => Some(parse_truefalse("CT_Shapetype/@stroked", v))
    None => None
  }
  let strokecolor = vml_attr(element, "strokecolor")
  let strokeweight = vml_attr(element, "strokeweight")
  let insetpen = match vml_attr(element, "insetpen") {
    Some(v) => Some(parse_truefalse("CT_Shapetype/@insetpen", v))
    None => None
  }
  let chromakey = vml_attr(element, "chromakey")
  let filled = match vml_attr(element, "filled") {
    Some(v) => Some(parse_truefalse("CT_Shapetype/@filled", v))
    None => None
  }
  let fillcolor = vml_attr(element, "fillcolor")
  let adj = vml_attr(element, "adj")
  let path = vml_attr(element, "path")
  let master = vml_attr(element, "master")
  let office_attributes = collect_office_attributes(element)
  let shape_children : Array[VmlShapeChild] = []
  let mut complex : CT_Complex? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "complex" {
        complex = Some(CT_Complex::new(child_element))
      } else {
        shape_children.push(parse_vml_shape_child(child_element))
      }
    }
  }
  {
    id,
    style,
    href,
    target,
    class_,
    title,
    alt,
    coordsize,
    coordorigin,
    wrapcoords,
    print,
    opacity,
    stroked,
    strokecolor,
    strokeweight,
    insetpen,
    chromakey,
    filled,
    fillcolor,
    adj,
    path,
    master,
    office_attributes,
    shape_children,
    complex,
    raw_element: element,
  }
}

///|
pub fn CT_Shapetype::to_element(self : CT_Shapetype) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Group — Part 4 §A.6.3 (vml-main.xsd). Group of
/// VML primitive shapes. Attributes: AG_AllCoreAttributes, AG_Fill,
/// @editas (ST_EditAs, optional), o:tableproperties, o:tablelimits.
/// Choice content: EG_ShapeElements / group / shape / shapetype / arc /
/// curve / image / line / oval / polyline / rect / roundrect / o:diagram.
pub(all) struct CT_Group {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  /// AG_Fill.
  filled : Bool?
  fillcolor : String?
  /// @editas — ST_EditAs lexical token (canvas / orgchart / radial / ...).
  editas : ST_EditAs?
  /// AG_OfficeCoreAttributes plus o:tableproperties / o:tablelimits.
  office_attributes : Array[@xml.Attribute]
  /// Shape choice children preserved in source order.
  group_children : Array[VmlGroupChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Group::new(element : @xml.Element) -> CT_Group raise SchemaViolation {
  let id = vml_attr(element, "id")
  let style = vml_attr(element, "style")
  let href = vml_attr(element, "href")
  let target = vml_attr(element, "target")
  let class_ = vml_attr(element, "class")
  let title = vml_attr(element, "title")
  let alt = vml_attr(element, "alt")
  let coordsize = vml_attr(element, "coordsize")
  let coordorigin = vml_attr(element, "coordorigin")
  let wrapcoords = vml_attr(element, "wrapcoords")
  let print = match vml_attr(element, "print") {
    Some(v) => Some(parse_truefalse("CT_Group/@print", v))
    None => None
  }
  let filled = match vml_attr(element, "filled") {
    Some(v) => Some(parse_truefalse("CT_Group/@filled", v))
    None => None
  }
  let fillcolor = vml_attr(element, "fillcolor")
  let editas = match vml_attr(element, "editas") {
    Some(v) => Some(ST_EditAs::parse(v))
    None => None
  }
  let office_attributes = collect_office_attributes(element)
  let group_children = collect_vml_group_children(element)
  {
    id,
    style,
    href,
    target,
    class_,
    title,
    alt,
    coordsize,
    coordorigin,
    wrapcoords,
    print,
    filled,
    fillcolor,
    editas,
    office_attributes,
    group_children,
    raw_element: element,
  }
}

///|
pub fn CT_Group::to_element(self : CT_Group) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Background — Part 4 §A.6.4 (vml-main.xsd).
/// Attributes: AG_Id, AG_Fill, plus o:bwmode, o:bwpure, o:bwnormal,
/// o:targetscreensize. Optional `fill` (CT_Fill) child.
pub(all) struct CT_Background {
  /// @id (AG_Id).
  id : String?
  /// AG_Fill.
  filled : Bool?
  fillcolor : String?
  /// Office attribute refs (bwmode, bwpure, bwnormal, targetscreensize).
  office_attributes : Array[@xml.Attribute]
  /// <fill> optional child.
  fill : CT_Fill?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Background::new(
  element : @xml.Element,
) -> CT_Background raise SchemaViolation {
  let id = vml_attr(element, "id")
  let filled = match vml_attr(element, "filled") {
    Some(v) => Some(parse_truefalse("CT_Background/@filled", v))
    None => None
  }
  let fillcolor = vml_attr(element, "fillcolor")
  let office_attributes = collect_office_attributes(element)
  let fill = match vml_first_child(element, "fill") {
    Some(child) => Some(CT_Fill::new(child))
    None => None
  }
  { id, filled, fillcolor, office_attributes, fill, raw_element: element }
}

///|
pub fn CT_Background::to_element(self : CT_Background) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Fill — Part 4 §A.6.5 (vml-main.xsd). VML fill
/// definition mirroring DrawingML fills. Attributes: AG_Id, @type
/// (ST_FillType), @on (s:ST_TrueFalse), @color (s:ST_ColorType),
/// @opacity, @color2, @src, @size, @origin, @position, @aspect
/// (ST_ImageAspect), @colors, @angle, @alignshape, @focus, @focussize,
/// @focusposition, @method (ST_FillMethod), @recolor, @rotate, plus
/// office attribute refs (href, althref, detectmouseclick, title,
/// opacity2, r:id, o:relid). Optional `o:fill` child.
pub(all) struct CT_Fill {
  /// @id (AG_Id).
  id : String?
  /// @type — fill method discriminator (solid, gradient, ...).
  type_ : ST_FillType?
  /// @on — visibility toggle (s:ST_TrueFalse).
  on : Bool?
  /// @color — primary fill colour.
  color : String?
  /// @opacity — opacity expression.
  opacity : String?
  /// @color2 — secondary colour for gradients / patterns.
  color2 : String?
  /// @src — image source URL for image fills.
  src : String?
  /// @size — tile size.
  size : String?
  /// @origin — tile origin.
  origin : String?
  /// @position — tile position.
  position : String?
  /// @aspect — image fill aspect ratio mode.
  aspect : ST_ImageAspect?
  /// @colors — gradient stop list.
  colors : String?
  /// @angle — gradient angle (decimal token).
  angle : String?
  /// @alignshape (s:ST_TrueFalse).
  alignshape : Bool?
  /// @focus — gradient focus percent.
  focus : String?
  /// @focussize — focus size token.
  focussize : String?
  /// @focusposition — focus position token.
  focusposition : String?
  /// @method — gradient fill method.
  fill_method : ST_FillMethod?
  /// @recolor (s:ST_TrueFalse).
  recolor : Bool?
  /// @rotate (s:ST_TrueFalse).
  rotate : Bool?
  /// Office attribute refs (o:href, o:althref, o:detectmouseclick,
  /// o:title, o:opacity2, r:id, o:relid).
  office_attributes : Array[@xml.Attribute]
  /// Optional `<o:fill>` extension.
  office_fill : @xml.Element?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Fill::new(element : @xml.Element) -> CT_Fill raise SchemaViolation {
  let id = vml_attr(element, "id")
  let type_ = match vml_attr(element, "type") {
    Some(v) => Some(ST_FillType::parse(v))
    None => None
  }
  let on = match vml_attr(element, "on") {
    Some(v) => Some(parse_truefalse("CT_Fill/@on", v))
    None => None
  }
  let color = vml_attr(element, "color")
  let opacity = vml_attr(element, "opacity")
  let color2 = vml_attr(element, "color2")
  let src = vml_attr(element, "src")
  let size = vml_attr(element, "size")
  let origin = vml_attr(element, "origin")
  let position = vml_attr(element, "position")
  let aspect = match vml_attr(element, "aspect") {
    Some(v) => Some(ST_ImageAspect::parse(v))
    None => None
  }
  let colors = vml_attr(element, "colors")
  let angle = vml_attr(element, "angle")
  let alignshape = match vml_attr(element, "alignshape") {
    Some(v) => Some(parse_truefalse("CT_Fill/@alignshape", v))
    None => None
  }
  let focus = vml_attr(element, "focus")
  let focussize = vml_attr(element, "focussize")
  let focusposition = vml_attr(element, "focusposition")
  let fill_method = match vml_attr(element, "method") {
    Some(v) => Some(ST_FillMethod::parse(v))
    None => None
  }
  let recolor = match vml_attr(element, "recolor") {
    Some(v) => Some(parse_truefalse("CT_Fill/@recolor", v))
    None => None
  }
  let rotate = match vml_attr(element, "rotate") {
    Some(v) => Some(parse_truefalse("CT_Fill/@rotate", v))
    None => None
  }
  let office_attributes = collect_office_attributes(element)
  let office_fill = vml_first_child(element, "fill")
  {
    id,
    type_,
    on,
    color,
    opacity,
    color2,
    src,
    size,
    origin,
    position,
    aspect,
    colors,
    angle,
    alignshape,
    focus,
    focussize,
    focusposition,
    fill_method,
    recolor,
    rotate,
    office_attributes,
    office_fill,
    raw_element: element,
  }
}

///|
pub fn CT_Fill::to_element(self : CT_Fill) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Formulas — Part 4 §A.6.6 (vml-main.xsd). Sequence
/// of zero or more `<f>` (CT_F) children.
pub(all) struct CT_Formulas {
  /// `<f>*` formulas.
  f : Array[CT_F]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Formulas::new(
  element : @xml.Element,
) -> CT_Formulas {
  let f : Array[CT_F] = []
  for child in vml_children(element, "f") {
    f.push(CT_F::new(child))
  }
  { f, raw_element: element }
}

///|
pub fn CT_Formulas::to_element(self : CT_Formulas) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_F — Part 4 §A.6.7 (vml-main.xsd). Single VML
/// formula. Attribute: @eqn (xsd:string, the formula text).
pub(all) struct CT_F {
  /// @eqn — formula expression.
  eqn : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_F::new(element : @xml.Element) -> CT_F {
  let eqn = vml_attr(element, "eqn")
  { eqn, raw_element: element }
}

///|
pub fn CT_F::to_element(self : CT_F) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Handles — Part 4 §A.6.8 (vml-main.xsd). Sequence
/// of zero or more `<h>` (CT_H) handle definitions.
pub(all) struct CT_Handles {
  /// `<h>*` handles.
  h : Array[CT_H]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Handles::new(
  element : @xml.Element,
) -> CT_Handles raise SchemaViolation {
  let h : Array[CT_H] = []
  for child in vml_children(element, "h") {
    h.push(CT_H::new(child))
  }
  { h, raw_element: element }
}

///|
pub fn CT_Handles::to_element(self : CT_Handles) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_H — Part 4 §A.6.9 (vml-main.xsd). Single VML
/// handle: @position, @polar, @map, @invx (s:ST_TrueFalse), @invy
/// (s:ST_TrueFalse), @switch (s:ST_TrueFalseBlank), @xrange, @yrange,
/// @radiusrange.
pub(all) struct CT_H {
  position : String?
  polar : String?
  map_ : String?
  invx : Bool?
  invy : Bool?
  /// @switch — `t`/`f` token or empty (ST_TrueFalseBlank). Stored as
  /// raw string to preserve the empty sentinel.
  switch_ : String?
  xrange : String?
  yrange : String?
  radiusrange : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_H::new(element : @xml.Element) -> CT_H raise SchemaViolation {
  let position = vml_attr(element, "position")
  let polar = vml_attr(element, "polar")
  let map_ = vml_attr(element, "map")
  let invx = match vml_attr(element, "invx") {
    Some(v) => Some(parse_truefalse("CT_H/@invx", v))
    None => None
  }
  let invy = match vml_attr(element, "invy") {
    Some(v) => Some(parse_truefalse("CT_H/@invy", v))
    None => None
  }
  let switch_ = vml_attr(element, "switch")
  let xrange = vml_attr(element, "xrange")
  let yrange = vml_attr(element, "yrange")
  let radiusrange = vml_attr(element, "radiusrange")
  {
    position,
    polar,
    map_,
    invx,
    invy,
    switch_,
    xrange,
    yrange,
    radiusrange,
    raw_element: element,
  }
}

///|
pub fn CT_H::to_element(self : CT_H) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_ImageData — Part 4 §A.6.10 (vml-main.xsd).
/// Attributes: AG_Id, AG_ImageAttributes, AG_Chromakey, @embosscolor
/// (s:ST_ColorType), @recolortarget; office attribute refs o:href,
/// o:althref, o:title, o:oleid, o:detectmouseclick, o:movie, o:relid,
/// r:id, r:pict, r:href.
pub(all) struct CT_ImageData {
  /// @id (AG_Id).
  id : String?
  /// AG_ImageAttributes src .. bilevel.
  src : String?
  cropleft : String?
  croptop : String?
  cropright : String?
  cropbottom : String?
  gain : String?
  blacklevel : String?
  gamma : String?
  grayscale : Bool?
  bilevel : Bool?
  /// @chromakey (AG_Chromakey).
  chromakey : String?
  /// @embosscolor.
  embosscolor : String?
  /// @recolortarget.
  recolortarget : String?
  /// Office / relationship attribute refs.
  office_attributes : Array[@xml.Attribute]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ImageData::new(
  element : @xml.Element,
) -> CT_ImageData raise SchemaViolation {
  let id = vml_attr(element, "id")
  let src = vml_attr(element, "src")
  let cropleft = vml_attr(element, "cropleft")
  let croptop = vml_attr(element, "croptop")
  let cropright = vml_attr(element, "cropright")
  let cropbottom = vml_attr(element, "cropbottom")
  let gain = vml_attr(element, "gain")
  let blacklevel = vml_attr(element, "blacklevel")
  let gamma = vml_attr(element, "gamma")
  let grayscale = match vml_attr(element, "grayscale") {
    Some(v) => Some(parse_truefalse("CT_ImageData/@grayscale", v))
    None => None
  }
  let bilevel = match vml_attr(element, "bilevel") {
    Some(v) => Some(parse_truefalse("CT_ImageData/@bilevel", v))
    None => None
  }
  let chromakey = vml_attr(element, "chromakey")
  let embosscolor = vml_attr(element, "embosscolor")
  let recolortarget = vml_attr(element, "recolortarget")
  let office_attributes = collect_office_attributes(element)
  {
    id,
    src,
    cropleft,
    croptop,
    cropright,
    cropbottom,
    gain,
    blacklevel,
    gamma,
    grayscale,
    bilevel,
    chromakey,
    embosscolor,
    recolortarget,
    office_attributes,
    raw_element: element,
  }
}

///|
pub fn CT_ImageData::to_element(self : CT_ImageData) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Path — Part 4 §A.6.11 (vml-main.xsd). Attributes:
/// AG_Id, @v (path command string), @limo, @textboxrect, @fillok,
/// @strokeok, @shadowok, @arrowok, @gradientshapeok, @textpathok,
/// @insetpenok (all s:ST_TrueFalse); office attribute refs
/// o:connecttype, o:connectlocs, o:connectangles, o:extrusionok.
pub(all) struct CT_Path {
  /// @id (AG_Id).
  id : String?
  /// @v — VML path command list.
  v : String?
  /// @limo — limit origin token.
  limo : String?
  /// @textboxrect — text box rectangle coords.
  textboxrect : String?
  /// @fillok.
  fillok : Bool?
  /// @strokeok.
  strokeok : Bool?
  /// @shadowok.
  shadowok : Bool?
  /// @arrowok.
  arrowok : Bool?
  /// @gradientshapeok.
  gradientshapeok : Bool?
  /// @textpathok.
  textpathok : Bool?
  /// @insetpenok.
  insetpenok : Bool?
  /// Office attribute refs (connecttype, connectlocs, connectangles,
  /// extrusionok).
  office_attributes : Array[@xml.Attribute]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path::new(element : @xml.Element) -> CT_Path raise SchemaViolation {
  let id = vml_attr(element, "id")
  let v = vml_attr(element, "v")
  let limo = vml_attr(element, "limo")
  let textboxrect = vml_attr(element, "textboxrect")
  let fillok = match vml_attr(element, "fillok") {
    Some(value) => Some(parse_truefalse("CT_Path/@fillok", value))
    None => None
  }
  let strokeok = match vml_attr(element, "strokeok") {
    Some(value) => Some(parse_truefalse("CT_Path/@strokeok", value))
    None => None
  }
  let shadowok = match vml_attr(element, "shadowok") {
    Some(value) => Some(parse_truefalse("CT_Path/@shadowok", value))
    None => None
  }
  let arrowok = match vml_attr(element, "arrowok") {
    Some(value) => Some(parse_truefalse("CT_Path/@arrowok", value))
    None => None
  }
  let gradientshapeok = match vml_attr(element, "gradientshapeok") {
    Some(value) => Some(parse_truefalse("CT_Path/@gradientshapeok", value))
    None => None
  }
  let textpathok = match vml_attr(element, "textpathok") {
    Some(value) => Some(parse_truefalse("CT_Path/@textpathok", value))
    None => None
  }
  let insetpenok = match vml_attr(element, "insetpenok") {
    Some(value) => Some(parse_truefalse("CT_Path/@insetpenok", value))
    None => None
  }
  let office_attributes = collect_office_attributes(element)
  {
    id,
    v,
    limo,
    textboxrect,
    fillok,
    strokeok,
    shadowok,
    arrowok,
    gradientshapeok,
    textpathok,
    insetpenok,
    office_attributes,
    raw_element: element,
  }
}

///|
pub fn CT_Path::to_element(self : CT_Path) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Shadow — Part 4 §A.6.12 (vml-main.xsd).
/// Attributes: AG_Id, @on, @type (ST_ShadowType), @obscured, @color,
/// @opacity, @offset, @color2, @offset2, @origin, @matrix.
pub(all) struct CT_Shadow {
  /// @id (AG_Id).
  id : String?
  /// @on (s:ST_TrueFalse).
  on : Bool?
  /// @type — shadow rendering mode.
  type_ : ST_ShadowType?
  /// @obscured (s:ST_TrueFalse).
  obscured : Bool?
  /// @color.
  color : String?
  /// @opacity.
  opacity : String?
  /// @offset.
  offset : String?
  /// @color2.
  color2 : String?
  /// @offset2.
  offset2 : String?
  /// @origin.
  origin : String?
  /// @matrix.
  matrix : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shadow::new(
  element : @xml.Element,
) -> CT_Shadow raise SchemaViolation {
  let id = vml_attr(element, "id")
  let on = match vml_attr(element, "on") {
    Some(v) => Some(parse_truefalse("CT_Shadow/@on", v))
    None => None
  }
  let type_ = match vml_attr(element, "type") {
    Some(v) => Some(ST_ShadowType::parse(v))
    None => None
  }
  let obscured = match vml_attr(element, "obscured") {
    Some(v) => Some(parse_truefalse("CT_Shadow/@obscured", v))
    None => None
  }
  let color = vml_attr(element, "color")
  let opacity = vml_attr(element, "opacity")
  let offset = vml_attr(element, "offset")
  let color2 = vml_attr(element, "color2")
  let offset2 = vml_attr(element, "offset2")
  let origin = vml_attr(element, "origin")
  let matrix = vml_attr(element, "matrix")
  {
    id,
    on,
    type_,
    obscured,
    color,
    opacity,
    offset,
    color2,
    offset2,
    origin,
    matrix,
    raw_element: element,
  }
}

///|
pub fn CT_Shadow::to_element(self : CT_Shadow) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Stroke — Part 4 §A.6.13 (vml-main.xsd).
/// Attributes: AG_Id and AG_StrokeAttributes. Sequence of optional
/// `o:left`, `o:top`, `o:right`, `o:bottom`, `o:column` stroke children
/// (each typed as CT_StrokeChild).
pub(all) struct CT_Stroke {
  /// @id (AG_Id).
  id : String?
  /// @on (AG_StrokeAttributes).
  on : Bool?
  /// @weight.
  weight : String?
  /// @color.
  color : String?
  /// @opacity.
  opacity : String?
  /// @linestyle (ST_StrokeLineStyle).
  linestyle : ST_StrokeLineStyle?
  /// @miterlimit (xsd:decimal token).
  miterlimit : String?
  /// @joinstyle (ST_StrokeJoinStyle).
  joinstyle : ST_StrokeJoinStyle?
  /// @endcap (ST_StrokeEndCap).
  endcap : ST_StrokeEndCap?
  /// @dashstyle.
  dashstyle : String?
  /// @filltype (ST_FillType).
  filltype : ST_FillType?
  /// @src — image stroke source.
  src : String?
  /// @imageaspect (ST_ImageAspect).
  imageaspect : ST_ImageAspect?
  /// @imagesize.
  imagesize : String?
  /// @imagealignshape (s:ST_TrueFalse).
  imagealignshape : Bool?
  /// @color2.
  color2 : String?
  /// @startarrow (ST_StrokeArrowType).
  startarrow : ST_StrokeArrowType?
  /// @startarrowwidth (ST_StrokeArrowWidth).
  startarrowwidth : ST_StrokeArrowWidth?
  /// @startarrowlength (ST_StrokeArrowLength).
  startarrowlength : ST_StrokeArrowLength?
  /// @endarrow (ST_StrokeArrowType).
  endarrow : ST_StrokeArrowType?
  /// @endarrowwidth (ST_StrokeArrowWidth).
  endarrowwidth : ST_StrokeArrowWidth?
  /// @endarrowlength (ST_StrokeArrowLength).
  endarrowlength : ST_StrokeArrowLength?
  /// @insetpen (s:ST_TrueFalse).
  insetpen : Bool?
  /// Office / relationship attribute refs (o:href, o:althref, o:title,
  /// o:forcedash, r:id, o:relid).
  office_attributes : Array[@xml.Attribute]
  /// `<o:left>`.
  left : CT_StrokeChild?
  /// `<o:top>`.
  top : CT_StrokeChild?
  /// `<o:right>`.
  right : CT_StrokeChild?
  /// `<o:bottom>`.
  bottom : CT_StrokeChild?
  /// `<o:column>`.
  column : CT_StrokeChild?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Stroke::new(
  element : @xml.Element,
) -> CT_Stroke raise SchemaViolation {
  let id = vml_attr(element, "id")
  let on = match vml_attr(element, "on") {
    Some(v) => Some(parse_truefalse("CT_Stroke/@on", v))
    None => None
  }
  let weight = vml_attr(element, "weight")
  let color = vml_attr(element, "color")
  let opacity = vml_attr(element, "opacity")
  let linestyle = match vml_attr(element, "linestyle") {
    Some(v) => Some(ST_StrokeLineStyle::parse(v))
    None => None
  }
  let miterlimit = vml_attr(element, "miterlimit")
  let joinstyle = match vml_attr(element, "joinstyle") {
    Some(v) => Some(ST_StrokeJoinStyle::parse(v))
    None => None
  }
  let endcap = match vml_attr(element, "endcap") {
    Some(v) => Some(ST_StrokeEndCap::parse(v))
    None => None
  }
  let dashstyle = vml_attr(element, "dashstyle")
  let filltype = match vml_attr(element, "filltype") {
    Some(v) => Some(ST_FillType::parse(v))
    None => None
  }
  let src = vml_attr(element, "src")
  let imageaspect = match vml_attr(element, "imageaspect") {
    Some(v) => Some(ST_ImageAspect::parse(v))
    None => None
  }
  let imagesize = vml_attr(element, "imagesize")
  let imagealignshape = match vml_attr(element, "imagealignshape") {
    Some(v) => Some(parse_truefalse("CT_Stroke/@imagealignshape", v))
    None => None
  }
  let color2 = vml_attr(element, "color2")
  let startarrow = match vml_attr(element, "startarrow") {
    Some(v) => Some(ST_StrokeArrowType::parse(v))
    None => None
  }
  let startarrowwidth = match vml_attr(element, "startarrowwidth") {
    Some(v) => Some(ST_StrokeArrowWidth::parse(v))
    None => None
  }
  let startarrowlength = match vml_attr(element, "startarrowlength") {
    Some(v) => Some(ST_StrokeArrowLength::parse(v))
    None => None
  }
  let endarrow = match vml_attr(element, "endarrow") {
    Some(v) => Some(ST_StrokeArrowType::parse(v))
    None => None
  }
  let endarrowwidth = match vml_attr(element, "endarrowwidth") {
    Some(v) => Some(ST_StrokeArrowWidth::parse(v))
    None => None
  }
  let endarrowlength = match vml_attr(element, "endarrowlength") {
    Some(v) => Some(ST_StrokeArrowLength::parse(v))
    None => None
  }
  let insetpen = match vml_attr(element, "insetpen") {
    Some(v) => Some(parse_truefalse("CT_Stroke/@insetpen", v))
    None => None
  }
  let office_attributes = collect_office_attributes(element)
  let left = match vml_first_child(element, "left") {
    Some(child) => Some(CT_StrokeChild::new(child))
    None => None
  }
  let top = match vml_first_child(element, "top") {
    Some(child) => Some(CT_StrokeChild::new(child))
    None => None
  }
  let right = match vml_first_child(element, "right") {
    Some(child) => Some(CT_StrokeChild::new(child))
    None => None
  }
  let bottom = match vml_first_child(element, "bottom") {
    Some(child) => Some(CT_StrokeChild::new(child))
    None => None
  }
  let column = match vml_first_child(element, "column") {
    Some(child) => Some(CT_StrokeChild::new(child))
    None => None
  }
  {
    id,
    on,
    weight,
    color,
    opacity,
    linestyle,
    miterlimit,
    joinstyle,
    endcap,
    dashstyle,
    filltype,
    src,
    imageaspect,
    imagesize,
    imagealignshape,
    color2,
    startarrow,
    startarrowwidth,
    startarrowlength,
    endarrow,
    endarrowwidth,
    endarrowlength,
    insetpen,
    office_attributes,
    left,
    top,
    right,
    bottom,
    column,
    raw_element: element,
  }
}

///|
pub fn CT_Stroke::to_element(self : CT_Stroke) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Textbox — Part 4 §A.6.14 (vml-main.xsd).
/// Attributes: AG_Id, AG_Style, @inset, o:singleclick, o:insetmode.
/// Choice content: optional `w:txbxContent` or wildcard `##local`
/// element.
pub(all) struct CT_Textbox {
  /// @id (AG_Id).
  id : String?
  /// @style (AG_Style). Use `parse_vml_style(...)` for the
  /// typed projection per Part 4 §6.1.
  style : String?
  /// @inset — text inset offsets.
  inset : String?
  /// Office attribute refs (singleclick, insetmode).
  office_attributes : Array[@xml.Attribute]
  /// Optional `<w:txbxContent>` or wildcard child preserved as raw element.
  content : @xml.Element?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Textbox::new(
  element : @xml.Element,
) -> CT_Textbox {
  let id = vml_attr(element, "id")
  let style = vml_attr(element, "style")
  let inset = vml_attr(element, "inset")
  let office_attributes = collect_office_attributes(element)
  let mut content : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      content = Some(child_element)
      break
    }
  }
  { id, style, inset, office_attributes, content, raw_element: element }
}

///|
pub fn CT_Textbox::to_element(self : CT_Textbox) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_TextPath — Part 4 §A.6.15 (vml-main.xsd).
/// Attributes: AG_Id, AG_Style, @on, @fitshape, @fitpath, @trim,
/// @xscale (all s:ST_TrueFalse), @string.
pub(all) struct CT_TextPath {
  id : String?
  style : String?
  on : Bool?
  fitshape : Bool?
  fitpath : Bool?
  trim : Bool?
  xscale : Bool?
  /// @string — text path label (note: `string` is reserved here? no,
  /// MoonBit allows it, but it conflicts with builtin so suffix `_`).
  string_ : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextPath::new(
  element : @xml.Element,
) -> CT_TextPath raise SchemaViolation {
  let id = vml_attr(element, "id")
  let style = vml_attr(element, "style")
  let on = match vml_attr(element, "on") {
    Some(v) => Some(parse_truefalse("CT_TextPath/@on", v))
    None => None
  }
  let fitshape = match vml_attr(element, "fitshape") {
    Some(v) => Some(parse_truefalse("CT_TextPath/@fitshape", v))
    None => None
  }
  let fitpath = match vml_attr(element, "fitpath") {
    Some(v) => Some(parse_truefalse("CT_TextPath/@fitpath", v))
    None => None
  }
  let trim = match vml_attr(element, "trim") {
    Some(v) => Some(parse_truefalse("CT_TextPath/@trim", v))
    None => None
  }
  let xscale = match vml_attr(element, "xscale") {
    Some(v) => Some(parse_truefalse("CT_TextPath/@xscale", v))
    None => None
  }
  let string_ = vml_attr(element, "string")
  {
    id,
    style,
    on,
    fitshape,
    fitpath,
    trim,
    xscale,
    string_,
    raw_element: element,
  }
}

///|
pub fn CT_TextPath::to_element(self : CT_TextPath) -> @xml.Element {
  self.raw_element
}

///|
/// Shared decoder for the AG_AllCoreAttributes / AG_AllShapeAttributes
/// bundle used by the primitive VML shape types (arc, curve, image,
/// line, oval, polyline, rect, roundrect). Returns a struct with every
/// typed field plus the verbatim office attribute bag and the
/// EG_ShapeElements children list.
struct VmlShapeCommon {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  office_attributes : Array[@xml.Attribute]
  shape_children : Array[VmlShapeChild]
} derive(Eq, Debug)

///|
fn decode_shape_common(
  element : @xml.Element,
  ct_name : String,
) -> VmlShapeCommon raise SchemaViolation {
  let id = vml_attr(element, "id")
  let style = vml_attr(element, "style")
  let href = vml_attr(element, "href")
  let target = vml_attr(element, "target")
  let class_ = vml_attr(element, "class")
  let title = vml_attr(element, "title")
  let alt = vml_attr(element, "alt")
  let coordsize = vml_attr(element, "coordsize")
  let coordorigin = vml_attr(element, "coordorigin")
  let wrapcoords = vml_attr(element, "wrapcoords")
  let print = match vml_attr(element, "print") {
    Some(v) => Some(parse_truefalse(ct_name + "/@print", v))
    None => None
  }
  let opacity = vml_attr(element, "opacity")
  let stroked = match vml_attr(element, "stroked") {
    Some(v) => Some(parse_truefalse(ct_name + "/@stroked", v))
    None => None
  }
  let strokecolor = vml_attr(element, "strokecolor")
  let strokeweight = vml_attr(element, "strokeweight")
  let insetpen = match vml_attr(element, "insetpen") {
    Some(v) => Some(parse_truefalse(ct_name + "/@insetpen", v))
    None => None
  }
  let chromakey = vml_attr(element, "chromakey")
  let filled = match vml_attr(element, "filled") {
    Some(v) => Some(parse_truefalse(ct_name + "/@filled", v))
    None => None
  }
  let fillcolor = vml_attr(element, "fillcolor")
  let office_attributes = collect_office_attributes(element)
  let shape_children = collect_vml_shape_children(element)
  {
    id,
    style,
    href,
    target,
    class_,
    title,
    alt,
    coordsize,
    coordorigin,
    wrapcoords,
    print,
    opacity,
    stroked,
    strokecolor,
    strokeweight,
    insetpen,
    chromakey,
    filled,
    fillcolor,
    office_attributes,
    shape_children,
  }
}

///|
/// XSD complex type CT_Arc — Part 4 §A.6.16 (vml-main.xsd). Attributes:
/// AG_AllCoreAttributes, AG_AllShapeAttributes, @startAngle (xsd:decimal),
/// @endAngle (xsd:decimal). Sequence: EG_ShapeElements zero-to-unbounded.
pub(all) struct CT_Arc {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  /// @startAngle — sweep start (decimal token).
  start_angle : String?
  /// @endAngle — sweep end (decimal token).
  end_angle : String?
  office_attributes : Array[@xml.Attribute]
  shape_children : Array[VmlShapeChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Arc::new(element : @xml.Element) -> CT_Arc raise SchemaViolation {
  let c = decode_shape_common(element, "CT_Arc")
  let start_angle = vml_attr(element, "startAngle")
  let end_angle = vml_attr(element, "endAngle")
  {
    id: c.id,
    style: c.style,
    href: c.href,
    target: c.target,
    class_: c.class_,
    title: c.title,
    alt: c.alt,
    coordsize: c.coordsize,
    coordorigin: c.coordorigin,
    wrapcoords: c.wrapcoords,
    print: c.print,
    opacity: c.opacity,
    stroked: c.stroked,
    strokecolor: c.strokecolor,
    strokeweight: c.strokeweight,
    insetpen: c.insetpen,
    chromakey: c.chromakey,
    filled: c.filled,
    fillcolor: c.fillcolor,
    start_angle,
    end_angle,
    office_attributes: c.office_attributes,
    shape_children: c.shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_Arc::to_element(self : CT_Arc) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Curve — Part 4 §A.6.17 (vml-main.xsd). Cubic
/// Bezier curve. Attributes: AG_AllCoreAttributes, AG_AllShapeAttributes,
/// @from, @control1, @control2, @to. Sequence: EG_ShapeElements*.
pub(all) struct CT_Curve {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  /// @from — start point.
  from : String?
  /// @control1 — first control point.
  control1 : String?
  /// @control2 — second control point.
  control2 : String?
  /// @to — end point.
  to : String?
  office_attributes : Array[@xml.Attribute]
  shape_children : Array[VmlShapeChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Curve::new(element : @xml.Element) -> CT_Curve raise SchemaViolation {
  let c = decode_shape_common(element, "CT_Curve")
  let from = vml_attr(element, "from")
  let control1 = vml_attr(element, "control1")
  let control2 = vml_attr(element, "control2")
  let to = vml_attr(element, "to")
  {
    id: c.id,
    style: c.style,
    href: c.href,
    target: c.target,
    class_: c.class_,
    title: c.title,
    alt: c.alt,
    coordsize: c.coordsize,
    coordorigin: c.coordorigin,
    wrapcoords: c.wrapcoords,
    print: c.print,
    opacity: c.opacity,
    stroked: c.stroked,
    strokecolor: c.strokecolor,
    strokeweight: c.strokeweight,
    insetpen: c.insetpen,
    chromakey: c.chromakey,
    filled: c.filled,
    fillcolor: c.fillcolor,
    from,
    control1,
    control2,
    to,
    office_attributes: c.office_attributes,
    shape_children: c.shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_Curve::to_element(self : CT_Curve) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Image — Part 4 §A.6.18 (vml-main.xsd).
/// Attributes: AG_AllCoreAttributes, AG_AllShapeAttributes,
/// AG_ImageAttributes. Sequence: EG_ShapeElements*.
pub(all) struct CT_Image {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  /// AG_ImageAttributes src .. bilevel.
  src : String?
  cropleft : String?
  croptop : String?
  cropright : String?
  cropbottom : String?
  gain : String?
  blacklevel : String?
  gamma : String?
  grayscale : Bool?
  bilevel : Bool?
  office_attributes : Array[@xml.Attribute]
  shape_children : Array[VmlShapeChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Image::new(element : @xml.Element) -> CT_Image raise SchemaViolation {
  let c = decode_shape_common(element, "CT_Image")
  let src = vml_attr(element, "src")
  let cropleft = vml_attr(element, "cropleft")
  let croptop = vml_attr(element, "croptop")
  let cropright = vml_attr(element, "cropright")
  let cropbottom = vml_attr(element, "cropbottom")
  let gain = vml_attr(element, "gain")
  let blacklevel = vml_attr(element, "blacklevel")
  let gamma = vml_attr(element, "gamma")
  let grayscale = match vml_attr(element, "grayscale") {
    Some(v) => Some(parse_truefalse("CT_Image/@grayscale", v))
    None => None
  }
  let bilevel = match vml_attr(element, "bilevel") {
    Some(v) => Some(parse_truefalse("CT_Image/@bilevel", v))
    None => None
  }
  {
    id: c.id,
    style: c.style,
    href: c.href,
    target: c.target,
    class_: c.class_,
    title: c.title,
    alt: c.alt,
    coordsize: c.coordsize,
    coordorigin: c.coordorigin,
    wrapcoords: c.wrapcoords,
    print: c.print,
    opacity: c.opacity,
    stroked: c.stroked,
    strokecolor: c.strokecolor,
    strokeweight: c.strokeweight,
    insetpen: c.insetpen,
    chromakey: c.chromakey,
    filled: c.filled,
    fillcolor: c.fillcolor,
    src,
    cropleft,
    croptop,
    cropright,
    cropbottom,
    gain,
    blacklevel,
    gamma,
    grayscale,
    bilevel,
    office_attributes: c.office_attributes,
    shape_children: c.shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_Image::to_element(self : CT_Image) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Line — Part 4 §A.6.19 (vml-main.xsd). Line
/// primitive. Attributes: AG_AllCoreAttributes, AG_AllShapeAttributes,
/// @from, @to. Sequence: EG_ShapeElements*.
pub(all) struct CT_Line {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  /// @from — line start (`x,y`).
  from : String?
  /// @to — line end (`x,y`).
  to : String?
  office_attributes : Array[@xml.Attribute]
  shape_children : Array[VmlShapeChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Line::new(element : @xml.Element) -> CT_Line raise SchemaViolation {
  let c = decode_shape_common(element, "CT_Line")
  let from = vml_attr(element, "from")
  let to = vml_attr(element, "to")
  {
    id: c.id,
    style: c.style,
    href: c.href,
    target: c.target,
    class_: c.class_,
    title: c.title,
    alt: c.alt,
    coordsize: c.coordsize,
    coordorigin: c.coordorigin,
    wrapcoords: c.wrapcoords,
    print: c.print,
    opacity: c.opacity,
    stroked: c.stroked,
    strokecolor: c.strokecolor,
    strokeweight: c.strokeweight,
    insetpen: c.insetpen,
    chromakey: c.chromakey,
    filled: c.filled,
    fillcolor: c.fillcolor,
    from,
    to,
    office_attributes: c.office_attributes,
    shape_children: c.shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_Line::to_element(self : CT_Line) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Oval — Part 4 §A.6.20 (vml-main.xsd). Oval
/// primitive. Attributes: AG_AllCoreAttributes, AG_AllShapeAttributes.
/// Choice content: EG_ShapeElements*.
pub(all) struct CT_Oval {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  office_attributes : Array[@xml.Attribute]
  shape_children : Array[VmlShapeChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Oval::new(element : @xml.Element) -> CT_Oval raise SchemaViolation {
  let c = decode_shape_common(element, "CT_Oval")
  {
    id: c.id,
    style: c.style,
    href: c.href,
    target: c.target,
    class_: c.class_,
    title: c.title,
    alt: c.alt,
    coordsize: c.coordsize,
    coordorigin: c.coordorigin,
    wrapcoords: c.wrapcoords,
    print: c.print,
    opacity: c.opacity,
    stroked: c.stroked,
    strokecolor: c.strokecolor,
    strokeweight: c.strokeweight,
    insetpen: c.insetpen,
    chromakey: c.chromakey,
    filled: c.filled,
    fillcolor: c.fillcolor,
    office_attributes: c.office_attributes,
    shape_children: c.shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_Oval::to_element(self : CT_Oval) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_PolyLine — Part 4 §A.6.21 (vml-main.xsd).
/// Attributes: AG_AllCoreAttributes, AG_AllShapeAttributes, @points
/// (point list). Choice: EG_ShapeElements | o:ink.
pub(all) struct CT_PolyLine {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  /// @points — polyline vertices as a coordinate list.
  points : String?
  office_attributes : Array[@xml.Attribute]
  /// EG_ShapeElements / o:ink children.
  shape_children : Array[VmlShapeChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PolyLine::new(
  element : @xml.Element,
) -> CT_PolyLine raise SchemaViolation {
  let c = decode_shape_common(element, "CT_PolyLine")
  let points = vml_attr(element, "points")
  {
    id: c.id,
    style: c.style,
    href: c.href,
    target: c.target,
    class_: c.class_,
    title: c.title,
    alt: c.alt,
    coordsize: c.coordsize,
    coordorigin: c.coordorigin,
    wrapcoords: c.wrapcoords,
    print: c.print,
    opacity: c.opacity,
    stroked: c.stroked,
    strokecolor: c.strokecolor,
    strokeweight: c.strokeweight,
    insetpen: c.insetpen,
    chromakey: c.chromakey,
    filled: c.filled,
    fillcolor: c.fillcolor,
    points,
    office_attributes: c.office_attributes,
    shape_children: c.shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_PolyLine::to_element(self : CT_PolyLine) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Rect — Part 4 §A.6.22 (vml-main.xsd). Rectangle
/// primitive. Attributes: AG_AllCoreAttributes, AG_AllShapeAttributes.
/// Choice content: EG_ShapeElements*.
pub(all) struct CT_Rect {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  office_attributes : Array[@xml.Attribute]
  shape_children : Array[VmlShapeChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rect::new(element : @xml.Element) -> CT_Rect raise SchemaViolation {
  let c = decode_shape_common(element, "CT_Rect")
  {
    id: c.id,
    style: c.style,
    href: c.href,
    target: c.target,
    class_: c.class_,
    title: c.title,
    alt: c.alt,
    coordsize: c.coordsize,
    coordorigin: c.coordorigin,
    wrapcoords: c.wrapcoords,
    print: c.print,
    opacity: c.opacity,
    stroked: c.stroked,
    strokecolor: c.strokecolor,
    strokeweight: c.strokeweight,
    insetpen: c.insetpen,
    chromakey: c.chromakey,
    filled: c.filled,
    fillcolor: c.fillcolor,
    office_attributes: c.office_attributes,
    shape_children: c.shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_Rect::to_element(self : CT_Rect) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_RoundRect — Part 4 §A.6.23 (vml-main.xsd).
/// Rounded rectangle primitive. Attributes: AG_AllCoreAttributes,
/// AG_AllShapeAttributes, @arcsize (xsd:string). Choice:
/// EG_ShapeElements*.
pub(all) struct CT_RoundRect {
  id : String?
  style : String?
  href : String?
  target : String?
  class_ : String?
  title : String?
  alt : String?
  coordsize : String?
  coordorigin : String?
  wrapcoords : String?
  print : Bool?
  opacity : String?
  stroked : Bool?
  strokecolor : String?
  strokeweight : String?
  insetpen : Bool?
  chromakey : String?
  filled : Bool?
  fillcolor : String?
  /// @arcsize — corner arc radius expressed as a fraction or pixels.
  arcsize : String?
  office_attributes : Array[@xml.Attribute]
  shape_children : Array[VmlShapeChild]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RoundRect::new(
  element : @xml.Element,
) -> CT_RoundRect raise SchemaViolation {
  let c = decode_shape_common(element, "CT_RoundRect")
  let arcsize = vml_attr(element, "arcsize")
  {
    id: c.id,
    style: c.style,
    href: c.href,
    target: c.target,
    class_: c.class_,
    title: c.title,
    alt: c.alt,
    coordsize: c.coordsize,
    coordorigin: c.coordorigin,
    wrapcoords: c.wrapcoords,
    print: c.print,
    opacity: c.opacity,
    stroked: c.stroked,
    strokecolor: c.strokecolor,
    strokeweight: c.strokeweight,
    insetpen: c.insetpen,
    chromakey: c.chromakey,
    filled: c.filled,
    fillcolor: c.fillcolor,
    arcsize,
    office_attributes: c.office_attributes,
    shape_children: c.shape_children,
    raw_element: element,
  }
}

///|
pub fn CT_RoundRect::to_element(self : CT_RoundRect) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_ShapeDefaults — Part 4 §A.6.24 (vml-officeDrawing.xsd).
/// Office-level VML shape default carrier. Attributes: v:AG_Ext (@ext —
/// ST_Ext), @spidmax (xsd:integer), @style, @fill (s:ST_TrueFalse),
/// @fillcolor (s:ST_ColorType), @stroke, @strokecolor, @allowincell.
/// Children (xsd:all): v:fill, v:stroke, v:textbox, v:shadow, skew,
/// extrusion, callout, lock, colormru (CT_ColorMru), colormenu
/// (CT_ColorMenu).
pub(all) struct CT_ShapeDefaults {
  /// @ext (v:AG_Ext, ST_Ext).
  ext : ST_Ext?
  /// @spidmax — high-water-mark for shape ids.
  spidmax : String?
  /// @style.
  style : String?
  /// @fill (s:ST_TrueFalse).
  fill_attr : Bool?
  /// @fillcolor.
  fillcolor : String?
  /// @stroke (s:ST_TrueFalse).
  stroke_attr : Bool?
  /// @strokecolor.
  strokecolor : String?
  /// @allowincell (s:ST_TrueFalse, qualified form).
  allowincell : Bool?
  /// `<v:fill>` (CT_Fill) — VML default fill.
  fill : CT_Fill?
  /// `<v:stroke>` (CT_Stroke) — VML default stroke.
  stroke : CT_Stroke?
  /// `<v:textbox>` (CT_Textbox).
  textbox : CT_Textbox?
  /// `<v:shadow>` (CT_Shadow).
  shadow : CT_Shadow?
  /// `<skew>` (CT_Skew).
  skew : CT_Skew?
  /// `<extrusion>` (CT_Extrusion).
  extrusion : CT_Extrusion?
  /// `<callout>` (CT_Callout).
  callout : CT_Callout?
  /// `<lock>` (CT_Lock).
  lock : CT_Lock?
  /// `<colormru>` (CT_ColorMru).
  colormru : CT_ColorMru?
  /// `<colormenu>` (CT_ColorMenu).
  colormenu : CT_ColorMenu?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeDefaults::new(
  element : @xml.Element,
) -> CT_ShapeDefaults raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let spidmax = vml_attr(element, "spidmax")
  let style = vml_attr(element, "style")
  let fill_attr = match vml_attr(element, "fill") {
    Some(v) => Some(parse_truefalse("CT_ShapeDefaults/@fill", v))
    None => None
  }
  let fillcolor = vml_attr(element, "fillcolor")
  let stroke_attr = match vml_attr(element, "stroke") {
    Some(v) => Some(parse_truefalse("CT_ShapeDefaults/@stroke", v))
    None => None
  }
  let strokecolor = vml_attr(element, "strokecolor")
  let allowincell = match vml_attr(element, "allowincell") {
    Some(v) => Some(parse_truefalse("CT_ShapeDefaults/@allowincell", v))
    None => None
  }
  let fill = match vml_first_child(element, "fill") {
    Some(child) => Some(CT_Fill::new(child))
    None => None
  }
  let stroke = match vml_first_child(element, "stroke") {
    Some(child) => Some(CT_Stroke::new(child))
    None => None
  }
  let textbox = match vml_first_child(element, "textbox") {
    Some(child) => Some(CT_Textbox::new(child))
    None => None
  }
  let shadow = match vml_first_child(element, "shadow") {
    Some(child) => Some(CT_Shadow::new(child))
    None => None
  }
  let skew = match vml_first_child(element, "skew") {
    Some(child) => Some(CT_Skew::new(child))
    None => None
  }
  let extrusion = match vml_first_child(element, "extrusion") {
    Some(child) => Some(CT_Extrusion::new(child))
    None => None
  }
  let callout = match vml_first_child(element, "callout") {
    Some(child) => Some(CT_Callout::new(child))
    None => None
  }
  let lock = match vml_first_child(element, "lock") {
    Some(child) => Some(CT_Lock::new(child))
    None => None
  }
  let colormru = match vml_first_child(element, "colormru") {
    Some(child) => Some(CT_ColorMru::new(child))
    None => None
  }
  let colormenu = match vml_first_child(element, "colormenu") {
    Some(child) => Some(CT_ColorMenu::new(child))
    None => None
  }
  {
    ext,
    spidmax,
    style,
    fill_attr,
    fillcolor,
    stroke_attr,
    strokecolor,
    allowincell,
    fill,
    stroke,
    textbox,
    shadow,
    skew,
    extrusion,
    callout,
    lock,
    colormru,
    colormenu,
    raw_element: element,
  }
}

///|
pub fn CT_ShapeDefaults::to_element(self : CT_ShapeDefaults) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Ink — Part 4 §A.6.25 (vml-officeDrawing.xsd).
/// Empty sequence. Attributes: @i (ink data, xsd:string), @annotation
/// (s:ST_TrueFalse), @contentType (ST_ContentType, optional).
pub(all) struct CT_Ink {
  /// @i — base64 ink data.
  i : String?
  /// @annotation — annotation flag.
  annotation : Bool?
  /// @contentType — MIME type token.
  content_type : ST_ContentType?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Ink::new(element : @xml.Element) -> CT_Ink raise SchemaViolation {
  let i = vml_attr(element, "i")
  let annotation = match vml_attr(element, "annotation") {
    Some(v) => Some(parse_truefalse("CT_Ink/@annotation", v))
    None => None
  }
  let content_type = match vml_attr(element, "contentType") {
    Some(v) => Some(ST_ContentType::parse(v))
    None => None
  }
  { i, annotation, content_type, raw_element: element }
}

///|
pub fn CT_Ink::to_element(self : CT_Ink) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_SignatureLine — Part 4 §A.6.26 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext (@ext), @issignatureline, @id (s:ST_Guid),
/// @provid (s:ST_Guid), @signinginstructionsset, @allowcomments,
/// @showsigndate, @suggestedsigner, @suggestedsigner2,
/// @suggestedsigneremail, @signinginstructions, @addlxml, @sigprovurl.
pub(all) struct CT_SignatureLine {
  ext : ST_Ext?
  issignatureline : Bool?
  /// @id — signature line identifier (GUID).
  id : String?
  /// @provid — signature provider identifier (GUID).
  provid : String?
  signinginstructionsset : Bool?
  allowcomments : Bool?
  showsigndate : Bool?
  suggestedsigner : String?
  suggestedsigner2 : String?
  suggestedsigneremail : String?
  signinginstructions : String?
  addlxml : String?
  sigprovurl : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SignatureLine::new(
  element : @xml.Element,
) -> CT_SignatureLine raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let issignatureline = match vml_attr(element, "issignatureline") {
    Some(v) => Some(parse_truefalse("CT_SignatureLine/@issignatureline", v))
    None => None
  }
  let id = vml_attr(element, "id")
  let provid = vml_attr(element, "provid")
  let signinginstructionsset = match
    vml_attr(element, "signinginstructionsset") {
    Some(v) =>
      Some(parse_truefalse("CT_SignatureLine/@signinginstructionsset", v))
    None => None
  }
  let allowcomments = match vml_attr(element, "allowcomments") {
    Some(v) => Some(parse_truefalse("CT_SignatureLine/@allowcomments", v))
    None => None
  }
  let showsigndate = match vml_attr(element, "showsigndate") {
    Some(v) => Some(parse_truefalse("CT_SignatureLine/@showsigndate", v))
    None => None
  }
  let suggestedsigner = vml_attr(element, "suggestedsigner")
  let suggestedsigner2 = vml_attr(element, "suggestedsigner2")
  let suggestedsigneremail = vml_attr(element, "suggestedsigneremail")
  let signinginstructions = vml_attr(element, "signinginstructions")
  let addlxml = vml_attr(element, "addlxml")
  let sigprovurl = vml_attr(element, "sigprovurl")
  {
    ext,
    issignatureline,
    id,
    provid,
    signinginstructionsset,
    allowcomments,
    showsigndate,
    suggestedsigner,
    suggestedsigner2,
    suggestedsigneremail,
    signinginstructions,
    addlxml,
    sigprovurl,
    raw_element: element,
  }
}

///|
pub fn CT_SignatureLine::to_element(self : CT_SignatureLine) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_ShapeLayout — Part 4 §A.6.27 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext. Children (xsd:all): `<idmap>` (CT_IdMap, opt),
/// `<regrouptable>` (CT_RegroupTable, opt), `<rules>` (CT_Rules, opt).
pub(all) struct CT_ShapeLayout {
  ext : ST_Ext?
  idmap : CT_IdMap?
  regrouptable : CT_RegroupTable?
  rules : CT_Rules?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeLayout::new(
  element : @xml.Element,
) -> CT_ShapeLayout raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let idmap = match vml_first_child(element, "idmap") {
    Some(child) => Some(CT_IdMap::new(child))
    None => None
  }
  let regrouptable = match vml_first_child(element, "regrouptable") {
    Some(child) => Some(CT_RegroupTable::new(child))
    None => None
  }
  let rules = match vml_first_child(element, "rules") {
    Some(child) => Some(CT_Rules::new(child))
    None => None
  }
  { ext, idmap, regrouptable, rules, raw_element: element }
}

///|
pub fn CT_ShapeLayout::to_element(self : CT_ShapeLayout) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_IdMap — Part 4 §A.6.28 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @data (xsd:string, optional).
pub(all) struct CT_IdMap {
  ext : ST_Ext?
  /// @data — comma-separated id allocation map.
  data : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_IdMap::new(element : @xml.Element) -> CT_IdMap raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let data = vml_attr(element, "data")
  { ext, data, raw_element: element }
}

///|
pub fn CT_IdMap::to_element(self : CT_IdMap) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_RegroupTable — Part 4 §A.6.29 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext. Sequence: zero or more `<entry>` (CT_Entry).
pub(all) struct CT_RegroupTable {
  ext : ST_Ext?
  entry : Array[CT_Entry]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RegroupTable::new(
  element : @xml.Element,
) -> CT_RegroupTable raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let entry : Array[CT_Entry] = []
  for child in vml_children(element, "entry") {
    entry.push(CT_Entry::new(child))
  }
  { ext, entry, raw_element: element }
}

///|
pub fn CT_RegroupTable::to_element(self : CT_RegroupTable) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Entry — Part 4 §A.6.30 (vml-officeDrawing.xsd).
/// Attributes: @new (xsd:int, optional), @old (xsd:int, optional).
pub(all) struct CT_Entry {
  /// @new — new group id (xsd:int as raw string token, name is keyword).
  new_id : String?
  /// @old — old group id (xsd:int as raw string token).
  old_id : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Entry::new(element : @xml.Element) -> CT_Entry {
  let new_id = vml_attr(element, "new")
  let old_id = vml_attr(element, "old")
  { new_id, old_id, raw_element: element }
}

///|
pub fn CT_Entry::to_element(self : CT_Entry) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Rules — Part 4 §A.6.31 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext. Sequence: zero or more `<r>` (CT_R).
pub(all) struct CT_Rules {
  ext : ST_Ext?
  r : Array[CT_R]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rules::new(element : @xml.Element) -> CT_Rules raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let r : Array[CT_R] = []
  for child in vml_children(element, "r") {
    r.push(CT_R::new(child))
  }
  { ext, r, raw_element: element }
}

///|
pub fn CT_Rules::to_element(self : CT_Rules) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_R — Part 4 §A.6.32 (vml-officeDrawing.xsd).
/// Attributes: @id (xsd:string, REQUIRED), @type (ST_RType, optional),
/// @how (ST_How, optional), @idref (xsd:string, optional). Sequence:
/// zero or more `<proxy>` (CT_Proxy).
pub(all) struct CT_R {
  /// @id — REQUIRED rule identifier.
  id : String
  /// @type (ST_RType).
  type_ : ST_RType?
  /// @how (ST_How).
  how : ST_How?
  /// @idref — referenced object id.
  idref : String?
  /// `<proxy>*`.
  proxy : Array[CT_Proxy]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_R::new(element : @xml.Element) -> CT_R raise SchemaViolation {
  let id = match vml_attr(element, "id") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="vml-officeDrawing.xsd",
        path="CT_R/@id",
        reason="required attribute missing",
      )
  }
  let type_ = match vml_attr(element, "type") {
    Some(v) => Some(ST_RType::parse(v))
    None => None
  }
  let how = match vml_attr(element, "how") {
    Some(v) => Some(ST_How::parse(v))
    None => None
  }
  let idref = vml_attr(element, "idref")
  let proxy : Array[CT_Proxy] = []
  for child in vml_children(element, "proxy") {
    proxy.push(CT_Proxy::new(child))
  }
  { id, type_, how, idref, proxy, raw_element: element }
}

///|
pub fn CT_R::to_element(self : CT_R) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Proxy — Part 4 §A.6.33 (vml-officeDrawing.xsd).
/// Attributes: @start (s:ST_TrueFalseBlank, default `false`), @end
/// (s:ST_TrueFalseBlank, default `false`), @idref (xsd:string, optional),
/// @connectloc (xsd:int, optional).
pub(all) struct CT_Proxy {
  /// @start — preserved as raw string to handle the empty ST_TrueFalseBlank.
  start : String?
  /// @end — same convention as @start.
  end : String?
  idref : String?
  /// @connectloc — integer token.
  connectloc : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Proxy::new(element : @xml.Element) -> CT_Proxy {
  let start = vml_attr(element, "start")
  let end = vml_attr(element, "end")
  let idref = vml_attr(element, "idref")
  let connectloc = vml_attr(element, "connectloc")
  { start, end, idref, connectloc, raw_element: element }
}

///|
pub fn CT_Proxy::to_element(self : CT_Proxy) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Diagram — Part 4 §A.6.34 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @dgmstyle (xsd:integer), @autoformat,
/// @reverse, @autolayout, @dgmscalex, @dgmscaley, @dgmfontsize,
/// @constrainbounds, @dgmbasetextscale. Sequence: optional
/// `<relationtable>` (CT_RelationTable).
pub(all) struct CT_Diagram {
  ext : ST_Ext?
  dgmstyle : String?
  autoformat : Bool?
  reverse : Bool?
  autolayout : Bool?
  dgmscalex : String?
  dgmscaley : String?
  dgmfontsize : String?
  constrainbounds : String?
  dgmbasetextscale : String?
  relationtable : CT_RelationTable?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Diagram::new(
  element : @xml.Element,
) -> CT_Diagram raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let dgmstyle = vml_attr(element, "dgmstyle")
  let autoformat = match vml_attr(element, "autoformat") {
    Some(v) => Some(parse_truefalse("CT_Diagram/@autoformat", v))
    None => None
  }
  let reverse = match vml_attr(element, "reverse") {
    Some(v) => Some(parse_truefalse("CT_Diagram/@reverse", v))
    None => None
  }
  let autolayout = match vml_attr(element, "autolayout") {
    Some(v) => Some(parse_truefalse("CT_Diagram/@autolayout", v))
    None => None
  }
  let dgmscalex = vml_attr(element, "dgmscalex")
  let dgmscaley = vml_attr(element, "dgmscaley")
  let dgmfontsize = vml_attr(element, "dgmfontsize")
  let constrainbounds = vml_attr(element, "constrainbounds")
  let dgmbasetextscale = vml_attr(element, "dgmbasetextscale")
  let relationtable = match vml_first_child(element, "relationtable") {
    Some(child) => Some(CT_RelationTable::new(child))
    None => None
  }
  {
    ext,
    dgmstyle,
    autoformat,
    reverse,
    autolayout,
    dgmscalex,
    dgmscaley,
    dgmfontsize,
    constrainbounds,
    dgmbasetextscale,
    relationtable,
    raw_element: element,
  }
}

///|
pub fn CT_Diagram::to_element(self : CT_Diagram) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_EquationXml — Part 4 §A.6.35 (vml-officeDrawing.xsd).
/// Sequence: xsd:any namespace="##any". Attributes: @contentType
/// (ST_AlternateMathContentType, optional).
pub(all) struct CT_EquationXml {
  /// @contentType — alternate math content discriminator.
  content_type : ST_AlternateMathContentType?
  /// Wildcard child preserved verbatim (any namespace).
  any_child : @xml.Element?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EquationXml::new(
  element : @xml.Element,
) -> CT_EquationXml raise SchemaViolation {
  let content_type = match vml_attr(element, "contentType") {
    Some(v) => Some(ST_AlternateMathContentType::parse(v))
    None => None
  }
  let mut any_child : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      any_child = Some(child_element)
      break
    }
  }
  { content_type, any_child, raw_element: element }
}

///|
pub fn CT_EquationXml::to_element(self : CT_EquationXml) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_RelationTable — Part 4 §A.6.36 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext. Sequence: zero or more `<rel>` (CT_Relation).
pub(all) struct CT_RelationTable {
  ext : ST_Ext?
  rel : Array[CT_Relation]
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RelationTable::new(
  element : @xml.Element,
) -> CT_RelationTable raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let rel : Array[CT_Relation] = []
  for child in vml_children(element, "rel") {
    rel.push(CT_Relation::new(child))
  }
  { ext, rel, raw_element: element }
}

///|
pub fn CT_RelationTable::to_element(self : CT_RelationTable) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Relation — Part 4 §A.6.37 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @idsrc, @iddest, @idcntr.
pub(all) struct CT_Relation {
  ext : ST_Ext?
  idsrc : String?
  iddest : String?
  idcntr : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Relation::new(
  element : @xml.Element,
) -> CT_Relation raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let idsrc = vml_attr(element, "idsrc")
  let iddest = vml_attr(element, "iddest")
  let idcntr = vml_attr(element, "idcntr")
  { ext, idsrc, iddest, idcntr, raw_element: element }
}

///|
pub fn CT_Relation::to_element(self : CT_Relation) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_ColorMru — Part 4 §A.6.38 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @colors (xsd:string).
pub(all) struct CT_ColorMru {
  ext : ST_Ext?
  /// @colors — most-recently-used colour palette.
  colors : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMru::new(
  element : @xml.Element,
) -> CT_ColorMru raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let colors = vml_attr(element, "colors")
  { ext, colors, raw_element: element }
}

///|
pub fn CT_ColorMru::to_element(self : CT_ColorMru) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_ColorMenu — Part 4 §A.6.39 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @strokecolor, @fillcolor, @shadowcolor,
/// @extrusioncolor (all s:ST_ColorType).
pub(all) struct CT_ColorMenu {
  ext : ST_Ext?
  strokecolor : String?
  fillcolor : String?
  shadowcolor : String?
  extrusioncolor : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMenu::new(
  element : @xml.Element,
) -> CT_ColorMenu raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let strokecolor = vml_attr(element, "strokecolor")
  let fillcolor = vml_attr(element, "fillcolor")
  let shadowcolor = vml_attr(element, "shadowcolor")
  let extrusioncolor = vml_attr(element, "extrusioncolor")
  {
    ext,
    strokecolor,
    fillcolor,
    shadowcolor,
    extrusioncolor,
    raw_element: element,
  }
}

///|
pub fn CT_ColorMenu::to_element(self : CT_ColorMenu) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Skew — Part 4 §A.6.40 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @id (xsd:string), @on (s:ST_TrueFalse),
/// @offset, @origin, @matrix.
pub(all) struct CT_Skew {
  ext : ST_Ext?
  id : String?
  on : Bool?
  offset : String?
  origin : String?
  matrix : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Skew::new(element : @xml.Element) -> CT_Skew raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let id = vml_attr(element, "id")
  let on = match vml_attr(element, "on") {
    Some(v) => Some(parse_truefalse("CT_Skew/@on", v))
    None => None
  }
  let offset = vml_attr(element, "offset")
  let origin = vml_attr(element, "origin")
  let matrix = vml_attr(element, "matrix")
  { ext, id, on, offset, origin, matrix, raw_element: element }
}

///|
pub fn CT_Skew::to_element(self : CT_Skew) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Extrusion — Part 4 §A.6.41 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @on, @type (ST_ExtrusionType, default parallel),
/// @render (ST_ExtrusionRender, default solid), @viewpointorigin,
/// @viewpoint, @plane (ST_ExtrusionPlane, default XY), @skewangle,
/// @skewamt, @foredepth, @backdepth, @orientation, @orientationangle,
/// @lockrotationcenter, @autorotationcenter, @rotationcenter,
/// @rotationangle, @colormode (ST_ColorMode), @color, @shininess,
/// @specularity, @diffusity, @metal, @edge, @facet, @lightface,
/// @brightness, @lightposition, @lightlevel, @lightharsh,
/// @lightposition2, @lightlevel2, @lightharsh2.
pub(all) struct CT_Extrusion {
  ext : ST_Ext?
  on : Bool?
  type_ : ST_ExtrusionType?
  render : ST_ExtrusionRender?
  viewpointorigin : String?
  viewpoint : String?
  plane : ST_ExtrusionPlane?
  skewangle : String?
  skewamt : String?
  foredepth : String?
  backdepth : String?
  orientation : String?
  orientationangle : String?
  lockrotationcenter : Bool?
  autorotationcenter : Bool?
  rotationcenter : String?
  rotationangle : String?
  colormode : ST_ColorMode?
  color : String?
  shininess : String?
  specularity : String?
  diffusity : String?
  metal : Bool?
  edge : String?
  facet : String?
  lightface : Bool?
  brightness : String?
  lightposition : String?
  lightlevel : String?
  lightharsh : Bool?
  lightposition2 : String?
  lightlevel2 : String?
  lightharsh2 : Bool?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Extrusion::new(
  element : @xml.Element,
) -> CT_Extrusion raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let on = match vml_attr(element, "on") {
    Some(v) => Some(parse_truefalse("CT_Extrusion/@on", v))
    None => None
  }
  let type_ = match vml_attr(element, "type") {
    Some(v) => Some(ST_ExtrusionType::parse(v))
    None => None
  }
  let render = match vml_attr(element, "render") {
    Some(v) => Some(ST_ExtrusionRender::parse(v))
    None => None
  }
  let viewpointorigin = vml_attr(element, "viewpointorigin")
  let viewpoint = vml_attr(element, "viewpoint")
  let plane = match vml_attr(element, "plane") {
    Some(v) => Some(ST_ExtrusionPlane::parse(v))
    None => None
  }
  let skewangle = vml_attr(element, "skewangle")
  let skewamt = vml_attr(element, "skewamt")
  let foredepth = vml_attr(element, "foredepth")
  let backdepth = vml_attr(element, "backdepth")
  let orientation = vml_attr(element, "orientation")
  let orientationangle = vml_attr(element, "orientationangle")
  let lockrotationcenter = match vml_attr(element, "lockrotationcenter") {
    Some(v) => Some(parse_truefalse("CT_Extrusion/@lockrotationcenter", v))
    None => None
  }
  let autorotationcenter = match vml_attr(element, "autorotationcenter") {
    Some(v) => Some(parse_truefalse("CT_Extrusion/@autorotationcenter", v))
    None => None
  }
  let rotationcenter = vml_attr(element, "rotationcenter")
  let rotationangle = vml_attr(element, "rotationangle")
  let colormode = match vml_attr(element, "colormode") {
    Some(v) => Some(ST_ColorMode::parse(v))
    None => None
  }
  let color = vml_attr(element, "color")
  let shininess = vml_attr(element, "shininess")
  let specularity = vml_attr(element, "specularity")
  let diffusity = vml_attr(element, "diffusity")
  let metal = match vml_attr(element, "metal") {
    Some(v) => Some(parse_truefalse("CT_Extrusion/@metal", v))
    None => None
  }
  let edge = vml_attr(element, "edge")
  let facet = vml_attr(element, "facet")
  let lightface = match vml_attr(element, "lightface") {
    Some(v) => Some(parse_truefalse("CT_Extrusion/@lightface", v))
    None => None
  }
  let brightness = vml_attr(element, "brightness")
  let lightposition = vml_attr(element, "lightposition")
  let lightlevel = vml_attr(element, "lightlevel")
  let lightharsh = match vml_attr(element, "lightharsh") {
    Some(v) => Some(parse_truefalse("CT_Extrusion/@lightharsh", v))
    None => None
  }
  let lightposition2 = vml_attr(element, "lightposition2")
  let lightlevel2 = vml_attr(element, "lightlevel2")
  let lightharsh2 = match vml_attr(element, "lightharsh2") {
    Some(v) => Some(parse_truefalse("CT_Extrusion/@lightharsh2", v))
    None => None
  }
  {
    ext,
    on,
    type_,
    render,
    viewpointorigin,
    viewpoint,
    plane,
    skewangle,
    skewamt,
    foredepth,
    backdepth,
    orientation,
    orientationangle,
    lockrotationcenter,
    autorotationcenter,
    rotationcenter,
    rotationangle,
    colormode,
    color,
    shininess,
    specularity,
    diffusity,
    metal,
    edge,
    facet,
    lightface,
    brightness,
    lightposition,
    lightlevel,
    lightharsh,
    lightposition2,
    lightlevel2,
    lightharsh2,
    raw_element: element,
  }
}

///|
pub fn CT_Extrusion::to_element(self : CT_Extrusion) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Callout — Part 4 §A.6.42 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @on, @type, @gap, @angle (ST_Angle), @dropauto,
/// @drop (ST_CalloutDrop), @distance, @lengthspecified (default `f`),
/// @length, @accentbar, @textborder, @minusx, @minusy.
pub(all) struct CT_Callout {
  ext : ST_Ext?
  on : Bool?
  type_ : String?
  gap : String?
  angle : ST_Angle?
  dropauto : Bool?
  drop : ST_CalloutDrop?
  distance : String?
  lengthspecified : Bool?
  length : String?
  accentbar : Bool?
  textborder : Bool?
  minusx : Bool?
  minusy : Bool?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Callout::new(
  element : @xml.Element,
) -> CT_Callout raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let on = match vml_attr(element, "on") {
    Some(v) => Some(parse_truefalse("CT_Callout/@on", v))
    None => None
  }
  let type_ = vml_attr(element, "type")
  let gap = vml_attr(element, "gap")
  let angle = match vml_attr(element, "angle") {
    Some(v) => Some(ST_Angle::parse(v))
    None => None
  }
  let dropauto = match vml_attr(element, "dropauto") {
    Some(v) => Some(parse_truefalse("CT_Callout/@dropauto", v))
    None => None
  }
  let drop = match vml_attr(element, "drop") {
    Some(v) => Some(ST_CalloutDrop::parse(v))
    None => None
  }
  let distance = vml_attr(element, "distance")
  let lengthspecified = match vml_attr(element, "lengthspecified") {
    Some(v) => Some(parse_truefalse("CT_Callout/@lengthspecified", v))
    None => None
  }
  let length = vml_attr(element, "length")
  let accentbar = match vml_attr(element, "accentbar") {
    Some(v) => Some(parse_truefalse("CT_Callout/@accentbar", v))
    None => None
  }
  let textborder = match vml_attr(element, "textborder") {
    Some(v) => Some(parse_truefalse("CT_Callout/@textborder", v))
    None => None
  }
  let minusx = match vml_attr(element, "minusx") {
    Some(v) => Some(parse_truefalse("CT_Callout/@minusx", v))
    None => None
  }
  let minusy = match vml_attr(element, "minusy") {
    Some(v) => Some(parse_truefalse("CT_Callout/@minusy", v))
    None => None
  }
  {
    ext,
    on,
    type_,
    gap,
    angle,
    dropauto,
    drop,
    distance,
    lengthspecified,
    length,
    accentbar,
    textborder,
    minusx,
    minusy,
    raw_element: element,
  }
}

///|
pub fn CT_Callout::to_element(self : CT_Callout) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Lock — Part 4 §A.6.43 (vml-officeDrawing.xsd).
/// Attributes: v:AG_Ext, @position, @selection, @grouping, @ungrouping,
/// @rotation, @cropping, @verticies, @adjusthandles, @text,
/// @aspectratio, @shapetype (all s:ST_TrueFalse, optional).
pub(all) struct CT_Lock {
  ext : ST_Ext?
  position : Bool?
  selection : Bool?
  grouping : Bool?
  ungrouping : Bool?
  rotation : Bool?
  cropping : Bool?
  verticies : Bool?
  adjusthandles : Bool?
  text : Bool?
  aspectratio : Bool?
  shapetype : Bool?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Lock::new(element : @xml.Element) -> CT_Lock raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let position = match vml_attr(element, "position") {
    Some(v) => Some(parse_truefalse("CT_Lock/@position", v))
    None => None
  }
  let selection = match vml_attr(element, "selection") {
    Some(v) => Some(parse_truefalse("CT_Lock/@selection", v))
    None => None
  }
  let grouping = match vml_attr(element, "grouping") {
    Some(v) => Some(parse_truefalse("CT_Lock/@grouping", v))
    None => None
  }
  let ungrouping = match vml_attr(element, "ungrouping") {
    Some(v) => Some(parse_truefalse("CT_Lock/@ungrouping", v))
    None => None
  }
  let rotation = match vml_attr(element, "rotation") {
    Some(v) => Some(parse_truefalse("CT_Lock/@rotation", v))
    None => None
  }
  let cropping = match vml_attr(element, "cropping") {
    Some(v) => Some(parse_truefalse("CT_Lock/@cropping", v))
    None => None
  }
  let verticies = match vml_attr(element, "verticies") {
    Some(v) => Some(parse_truefalse("CT_Lock/@verticies", v))
    None => None
  }
  let adjusthandles = match vml_attr(element, "adjusthandles") {
    Some(v) => Some(parse_truefalse("CT_Lock/@adjusthandles", v))
    None => None
  }
  let text = match vml_attr(element, "text") {
    Some(v) => Some(parse_truefalse("CT_Lock/@text", v))
    None => None
  }
  let aspectratio = match vml_attr(element, "aspectratio") {
    Some(v) => Some(parse_truefalse("CT_Lock/@aspectratio", v))
    None => None
  }
  let shapetype = match vml_attr(element, "shapetype") {
    Some(v) => Some(parse_truefalse("CT_Lock/@shapetype", v))
    None => None
  }
  {
    ext,
    position,
    selection,
    grouping,
    ungrouping,
    rotation,
    cropping,
    verticies,
    adjusthandles,
    text,
    aspectratio,
    shapetype,
    raw_element: element,
  }
}

///|
pub fn CT_Lock::to_element(self : CT_Lock) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_OLEObject — Part 4 §A.6.44 (vml-officeDrawing.xsd).
/// Attributes: @Type (ST_OLEType), @ProgID, @ShapeID, @DrawAspect
/// (ST_OLEDrawAspect), @ObjectID, r:id, @UpdateMode (ST_OLEUpdateMode).
/// Sequence: optional `<LinkType>` (ST_OLELinkType), `<LockedField>`
/// (s:ST_TrueFalseBlank), `<FieldCodes>` (xsd:string).
pub(all) struct CT_OLEObject {
  type_ : ST_OLEType?
  prog_id : String?
  shape_id : String?
  draw_aspect : ST_OLEDrawAspect?
  object_id : String?
  /// r:id attribute (relationship identifier).
  r_id : String?
  update_mode : ST_OLEUpdateMode?
  /// `<LinkType>` optional child (string content).
  link_type : ST_OLELinkType?
  /// `<LockedField>` optional child (ST_TrueFalseBlank token preserved verbatim).
  locked_field : String?
  /// `<FieldCodes>` optional child (string content).
  field_codes : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
fn element_text(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Node::Text(text) => buf.write_string(text)
      @xml.Node::CData(text) => buf.write_string(text)
      _ => ()
    }
  }
  buf.to_string()
}

///|
pub fn CT_OLEObject::new(
  element : @xml.Element,
) -> CT_OLEObject raise SchemaViolation {
  let type_ = match vml_attr(element, "Type") {
    Some(v) => Some(ST_OLEType::parse(v))
    None => None
  }
  let prog_id = vml_attr(element, "ProgID")
  let shape_id = vml_attr(element, "ShapeID")
  let draw_aspect = match vml_attr(element, "DrawAspect") {
    Some(v) => Some(ST_OLEDrawAspect::parse(v))
    None => None
  }
  let object_id = vml_attr(element, "ObjectID")
  let r_id = vml_attr(element, "id")
  let update_mode = match vml_attr(element, "UpdateMode") {
    Some(v) => Some(ST_OLEUpdateMode::parse(v))
    None => None
  }
  let link_type = match vml_first_child(element, "LinkType") {
    Some(child) => Some(ST_OLELinkType::parse(element_text(child)))
    None => None
  }
  let locked_field = match vml_first_child(element, "LockedField") {
    Some(child) => Some(element_text(child))
    None => None
  }
  let field_codes = match vml_first_child(element, "FieldCodes") {
    Some(child) => Some(element_text(child))
    None => None
  }
  {
    type_,
    prog_id,
    shape_id,
    draw_aspect,
    object_id,
    r_id,
    update_mode,
    link_type,
    locked_field,
    field_codes,
    raw_element: element,
  }
}

///|
pub fn CT_OLEObject::to_element(self : CT_OLEObject) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Complex — Part 4 §A.6.45 (vml-officeDrawing.xsd).
/// Empty complex content with v:AG_Ext only.
pub(all) struct CT_Complex {
  ext : ST_Ext?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Complex::new(
  element : @xml.Element,
) -> CT_Complex raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  { ext, raw_element: element }
}

///|
pub fn CT_Complex::to_element(self : CT_Complex) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_StrokeChild — Part 4 §A.6.46 (vml-officeDrawing.xsd).
/// Used for `<o:left>`, `<o:top>`, `<o:right>`, `<o:bottom>`, `<o:column>`.
/// Attributes: v:AG_Ext, @on, @weight, @color, @color2, @opacity,
/// @linestyle (v:ST_StrokeLineStyle), @miterlimit (xsd:decimal),
/// @joinstyle (v:ST_StrokeJoinStyle), @endcap (v:ST_StrokeEndCap),
/// @dashstyle, @insetpen, @filltype (v:ST_FillType), @src,
/// @imageaspect (v:ST_ImageAspect), @imagesize, @imagealignshape,
/// @startarrow (v:ST_StrokeArrowType), @startarrowwidth, @startarrowlength,
/// @endarrow, @endarrowwidth, @endarrowlength; attribute refs href,
/// althref, title, forcedash.
pub(all) struct CT_StrokeChild {
  ext : ST_Ext?
  on : Bool?
  weight : String?
  color : String?
  color2 : String?
  opacity : String?
  linestyle : ST_StrokeLineStyle?
  miterlimit : String?
  joinstyle : ST_StrokeJoinStyle?
  endcap : ST_StrokeEndCap?
  dashstyle : String?
  insetpen : Bool?
  filltype : ST_FillType?
  src : String?
  imageaspect : ST_ImageAspect?
  imagesize : String?
  imagealignshape : Bool?
  startarrow : ST_StrokeArrowType?
  startarrowwidth : ST_StrokeArrowWidth?
  startarrowlength : ST_StrokeArrowLength?
  endarrow : ST_StrokeArrowType?
  endarrowwidth : ST_StrokeArrowWidth?
  endarrowlength : ST_StrokeArrowLength?
  /// @href / @althref / @title (qualified office attributes).
  href : String?
  althref : String?
  title : String?
  /// @forcedash (s:ST_TrueFalse).
  forcedash : Bool?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StrokeChild::new(
  element : @xml.Element,
) -> CT_StrokeChild raise SchemaViolation {
  let ext = match vml_attr(element, "ext") {
    Some(v) => Some(ST_Ext::parse(v))
    None => None
  }
  let on = match vml_attr(element, "on") {
    Some(v) => Some(parse_truefalse("CT_StrokeChild/@on", v))
    None => None
  }
  let weight = vml_attr(element, "weight")
  let color = vml_attr(element, "color")
  let color2 = vml_attr(element, "color2")
  let opacity = vml_attr(element, "opacity")
  let linestyle = match vml_attr(element, "linestyle") {
    Some(v) => Some(ST_StrokeLineStyle::parse(v))
    None => None
  }
  let miterlimit = vml_attr(element, "miterlimit")
  let joinstyle = match vml_attr(element, "joinstyle") {
    Some(v) => Some(ST_StrokeJoinStyle::parse(v))
    None => None
  }
  let endcap = match vml_attr(element, "endcap") {
    Some(v) => Some(ST_StrokeEndCap::parse(v))
    None => None
  }
  let dashstyle = vml_attr(element, "dashstyle")
  let insetpen = match vml_attr(element, "insetpen") {
    Some(v) => Some(parse_truefalse("CT_StrokeChild/@insetpen", v))
    None => None
  }
  let filltype = match vml_attr(element, "filltype") {
    Some(v) => Some(ST_FillType::parse(v))
    None => None
  }
  let src = vml_attr(element, "src")
  let imageaspect = match vml_attr(element, "imageaspect") {
    Some(v) => Some(ST_ImageAspect::parse(v))
    None => None
  }
  let imagesize = vml_attr(element, "imagesize")
  let imagealignshape = match vml_attr(element, "imagealignshape") {
    Some(v) => Some(parse_truefalse("CT_StrokeChild/@imagealignshape", v))
    None => None
  }
  let startarrow = match vml_attr(element, "startarrow") {
    Some(v) => Some(ST_StrokeArrowType::parse(v))
    None => None
  }
  let startarrowwidth = match vml_attr(element, "startarrowwidth") {
    Some(v) => Some(ST_StrokeArrowWidth::parse(v))
    None => None
  }
  let startarrowlength = match vml_attr(element, "startarrowlength") {
    Some(v) => Some(ST_StrokeArrowLength::parse(v))
    None => None
  }
  let endarrow = match vml_attr(element, "endarrow") {
    Some(v) => Some(ST_StrokeArrowType::parse(v))
    None => None
  }
  let endarrowwidth = match vml_attr(element, "endarrowwidth") {
    Some(v) => Some(ST_StrokeArrowWidth::parse(v))
    None => None
  }
  let endarrowlength = match vml_attr(element, "endarrowlength") {
    Some(v) => Some(ST_StrokeArrowLength::parse(v))
    None => None
  }
  let href = vml_attr(element, "href")
  let althref = vml_attr(element, "althref")
  let title = vml_attr(element, "title")
  let forcedash = match vml_attr(element, "forcedash") {
    Some(v) => Some(parse_truefalse("CT_StrokeChild/@forcedash", v))
    None => None
  }
  {
    ext,
    on,
    weight,
    color,
    color2,
    opacity,
    linestyle,
    miterlimit,
    joinstyle,
    endcap,
    dashstyle,
    insetpen,
    filltype,
    src,
    imageaspect,
    imagesize,
    imagealignshape,
    startarrow,
    startarrowwidth,
    startarrowlength,
    endarrow,
    endarrowwidth,
    endarrowlength,
    href,
    althref,
    title,
    forcedash,
    raw_element: element,
  }
}

///|
pub fn CT_StrokeChild::to_element(self : CT_StrokeChild) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_ClipPath — Part 4 §A.6.47 (vml-officeDrawing.xsd).
/// Single REQUIRED attribute @v (xsd:string, qualified form).
pub(all) struct CT_ClipPath {
  /// @v — clip path expression (REQUIRED).
  v : String
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ClipPath::new(
  element : @xml.Element,
) -> CT_ClipPath raise SchemaViolation {
  let v = match vml_attr(element, "v") {
    Some(value) => value
    None =>
      raise SchemaViolation(
        schema="vml-officeDrawing.xsd",
        path="CT_ClipPath/@v",
        reason="required attribute missing",
      )
  }
  { v, raw_element: element }
}

///|
pub fn CT_ClipPath::to_element(self : CT_ClipPath) -> @xml.Element {
  self.raw_element
}

///|
pub fn read_vml_shape(bytes : Bytes) -> CT_Shape raise {
  CT_Shape::new(read_vml_root(bytes, "shape"))
}

///|
pub fn write_vml_shape(value : CT_Shape) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_shapetype(bytes : Bytes) -> CT_Shapetype raise {
  CT_Shapetype::new(read_vml_root(bytes, "shapetype"))
}

///|
pub fn write_vml_shapetype(value : CT_Shapetype) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_group(bytes : Bytes) -> CT_Group raise {
  CT_Group::new(read_vml_root(bytes, "group"))
}

///|
pub fn write_vml_group(value : CT_Group) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_background(bytes : Bytes) -> CT_Background raise {
  CT_Background::new(read_vml_root(bytes, "background"))
}

///|
pub fn write_vml_background(value : CT_Background) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_fill(bytes : Bytes) -> CT_Fill raise {
  CT_Fill::new(read_vml_root(bytes, "fill"))
}

///|
pub fn write_vml_fill(value : CT_Fill) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_stroke(bytes : Bytes) -> CT_Stroke raise {
  CT_Stroke::new(read_vml_root(bytes, "stroke"))
}

///|
pub fn write_vml_stroke(value : CT_Stroke) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_imagedata(bytes : Bytes) -> CT_ImageData raise {
  CT_ImageData::new(read_vml_root(bytes, "imagedata"))
}

///|
pub fn write_vml_imagedata(value : CT_ImageData) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_path(bytes : Bytes) -> CT_Path raise {
  CT_Path::new(read_vml_root(bytes, "path"))
}

///|
pub fn write_vml_path(value : CT_Path) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_textbox(bytes : Bytes) -> CT_Textbox raise {
  CT_Textbox::new(read_vml_root(bytes, "textbox"))
}

///|
pub fn write_vml_textbox(value : CT_Textbox) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_textpath(bytes : Bytes) -> CT_TextPath raise {
  CT_TextPath::new(read_vml_root(bytes, "textpath"))
}

///|
pub fn write_vml_textpath(value : CT_TextPath) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_shapedefaults(bytes : Bytes) -> CT_ShapeDefaults raise {
  CT_ShapeDefaults::new(read_vml_root(bytes, "shapedefaults"))
}

///|
pub fn write_vml_shapedefaults(value : CT_ShapeDefaults) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_ink(bytes : Bytes) -> CT_Ink raise {
  CT_Ink::new(read_vml_root(bytes, "ink"))
}

///|
pub fn write_vml_ink(value : CT_Ink) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_signatureline(bytes : Bytes) -> CT_SignatureLine raise {
  CT_SignatureLine::new(read_vml_root(bytes, "signatureline"))
}

///|
pub fn write_vml_signatureline(value : CT_SignatureLine) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_shapelayout(bytes : Bytes) -> CT_ShapeLayout raise {
  CT_ShapeLayout::new(read_vml_root(bytes, "shapelayout"))
}

///|
pub fn write_vml_shapelayout(value : CT_ShapeLayout) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_idmap(bytes : Bytes) -> CT_IdMap raise {
  CT_IdMap::new(read_vml_root(bytes, "idmap"))
}

///|
pub fn write_vml_idmap(value : CT_IdMap) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_regrouptable(bytes : Bytes) -> CT_RegroupTable raise {
  CT_RegroupTable::new(read_vml_root(bytes, "regrouptable"))
}

///|
pub fn write_vml_regrouptable(value : CT_RegroupTable) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_rules(bytes : Bytes) -> CT_Rules raise {
  CT_Rules::new(read_vml_root(bytes, "rules"))
}

///|
pub fn write_vml_rules(value : CT_Rules) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_diagram(bytes : Bytes) -> CT_Diagram raise {
  CT_Diagram::new(read_vml_root(bytes, "diagram"))
}

///|
pub fn write_vml_diagram(value : CT_Diagram) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_oleobject(bytes : Bytes) -> CT_OLEObject raise {
  CT_OLEObject::new(read_vml_root(bytes, "OLEObject"))
}

///|
pub fn write_vml_oleobject(value : CT_OLEObject) -> Bytes {
  write_element(value.to_element())
}

///|
pub fn read_vml_complex(bytes : Bytes) -> CT_Complex raise {
  CT_Complex::new(read_vml_root(bytes, "complex"))
}

///|
pub fn write_vml_complex(value : CT_Complex) -> Bytes {
  write_element(value.to_element())
}

// ──────────────────────────────────────────────────────────────────
// Top-level element parsers for the four VML XSD schemas.
//
// Each top-level <xsd:element name="..."> in vml-main.xsd,
// vml-officeDrawing.xsd, vml-presentationDrawing.xsd and
// vml-wordprocessingDrawing.xsd is exposed below as a
// `read_<element_name>` function that parses the element bytes and
// returns its typed complex-type representation. The names match the
// XSD element name verbatim (camelCase preserved) so that the
// `xsd_coverage.py` audit can detect them.
// ──────────────────────────────────────────────────────────────────

// CT_Empty / CT_Rel moved to the dedicated `vml_presentation` package
// (vml-presentationDrawing.xsd §A.6.62/§A.6.63). CT_Border / CT_Wrap /
// CT_AnchorLock moved to `vml_word` (vml-wordprocessingDrawing.xsd
// §A.6.64..§A.6.66). Aliased here for the typed VmlShapeChild
// dispatch so existing callers keep working unchanged.

///|
pub using @vml_presentation {type CT_Empty}

///|
pub using @vml_presentation {type CT_Rel}

///|
pub using @vml_word {type CT_Border}

///|
pub using @vml_word {type CT_Wrap}

///|
pub using @vml_word {type CT_AnchorLock}

// ── vml-main.xsd top-level elements ────────────────────────────────

///|
/// Read top-level XSD element `v:shape` (vml-main.xsd §A.6.1).
pub fn read_shape(bytes : Bytes) -> CT_Shape raise {
  CT_Shape::new(read_vml_root(bytes, "shape"))
}

///|
/// Read top-level XSD element `v:shapetype` (vml-main.xsd §A.6.2).
pub fn read_shapetype(bytes : Bytes) -> CT_Shapetype raise {
  CT_Shapetype::new(read_vml_root(bytes, "shapetype"))
}

///|
/// Read top-level XSD element `v:group` (vml-main.xsd §A.6.3).
pub fn read_group(bytes : Bytes) -> CT_Group raise {
  CT_Group::new(read_vml_root(bytes, "group"))
}

///|
/// Read top-level XSD element `v:background` (vml-main.xsd §A.6.4).
pub fn read_background(bytes : Bytes) -> CT_Background raise {
  CT_Background::new(read_vml_root(bytes, "background"))
}

///|
/// Read top-level XSD element `v:fill` (vml-main.xsd §A.6.5). Also
/// satisfies the `o:fill` element declared in vml-officeDrawing.xsd,
/// which reuses CT_Fill.
pub fn read_fill(bytes : Bytes) -> CT_Fill raise {
  CT_Fill::new(read_vml_root(bytes, "fill"))
}

///|
/// Read top-level XSD element `v:formulas` (vml-main.xsd §A.6.6).
pub fn read_formulas(bytes : Bytes) -> CT_Formulas raise {
  CT_Formulas::new(read_vml_root(bytes, "formulas"))
}

///|
/// Read top-level XSD element `v:handles` (vml-main.xsd §A.6.8).
pub fn read_handles(bytes : Bytes) -> CT_Handles raise {
  CT_Handles::new(read_vml_root(bytes, "handles"))
}

///|
/// Read top-level XSD element `v:imagedata` (vml-main.xsd §A.6.10).
pub fn read_imagedata(bytes : Bytes) -> CT_ImageData raise {
  CT_ImageData::new(read_vml_root(bytes, "imagedata"))
}

///|
/// Read top-level XSD element `v:path` (vml-main.xsd §A.6.11).
pub fn read_path(bytes : Bytes) -> CT_Path raise {
  CT_Path::new(read_vml_root(bytes, "path"))
}

///|
/// Read top-level XSD element `v:shadow` (vml-main.xsd §A.6.12).
pub fn read_shadow(bytes : Bytes) -> CT_Shadow raise {
  CT_Shadow::new(read_vml_root(bytes, "shadow"))
}

///|
/// Read top-level XSD element `v:stroke` (vml-main.xsd §A.6.13).
pub fn read_stroke(bytes : Bytes) -> CT_Stroke raise {
  CT_Stroke::new(read_vml_root(bytes, "stroke"))
}

///|
/// Read top-level XSD element `v:textbox` (vml-main.xsd §A.6.14).
pub fn read_textbox(bytes : Bytes) -> CT_Textbox raise {
  CT_Textbox::new(read_vml_root(bytes, "textbox"))
}

///|
/// Read top-level XSD element `v:textpath` (vml-main.xsd §A.6.15).
pub fn read_textpath(bytes : Bytes) -> CT_TextPath raise {
  CT_TextPath::new(read_vml_root(bytes, "textpath"))
}

///|
/// Read top-level XSD element `v:arc` (vml-main.xsd §A.6.16).
pub fn read_arc(bytes : Bytes) -> CT_Arc raise {
  CT_Arc::new(read_vml_root(bytes, "arc"))
}

///|
/// Read top-level XSD element `v:curve` (vml-main.xsd §A.6.17).
pub fn read_curve(bytes : Bytes) -> CT_Curve raise {
  CT_Curve::new(read_vml_root(bytes, "curve"))
}

///|
/// Read top-level XSD element `v:image` (vml-main.xsd §A.6.18).
pub fn read_image(bytes : Bytes) -> CT_Image raise {
  CT_Image::new(read_vml_root(bytes, "image"))
}

///|
/// Read top-level XSD element `v:line` (vml-main.xsd §A.6.19).
pub fn read_line(bytes : Bytes) -> CT_Line raise {
  CT_Line::new(read_vml_root(bytes, "line"))
}

///|
/// Read top-level XSD element `v:oval` (vml-main.xsd §A.6.20).
pub fn read_oval(bytes : Bytes) -> CT_Oval raise {
  CT_Oval::new(read_vml_root(bytes, "oval"))
}

///|
/// Read top-level XSD element `v:polyline` (vml-main.xsd §A.6.21).
pub fn read_polyline(bytes : Bytes) -> CT_PolyLine raise {
  CT_PolyLine::new(read_vml_root(bytes, "polyline"))
}

///|
/// Read top-level XSD element `v:rect` (vml-main.xsd §A.6.22).
pub fn read_rect(bytes : Bytes) -> CT_Rect raise {
  CT_Rect::new(read_vml_root(bytes, "rect"))
}

///|
/// Read top-level XSD element `v:roundrect` (vml-main.xsd §A.6.23).
pub fn read_roundrect(bytes : Bytes) -> CT_RoundRect raise {
  CT_RoundRect::new(read_vml_root(bytes, "roundrect"))
}

// ── vml-officeDrawing.xsd top-level elements ───────────────────────

///|
/// Read top-level XSD element `o:shapedefaults` (vml-officeDrawing.xsd).
pub fn read_shapedefaults(bytes : Bytes) -> CT_ShapeDefaults raise {
  CT_ShapeDefaults::new(read_vml_root(bytes, "shapedefaults"))
}

///|
/// Read top-level XSD element `o:shapelayout` (vml-officeDrawing.xsd).
pub fn read_shapelayout(bytes : Bytes) -> CT_ShapeLayout raise {
  CT_ShapeLayout::new(read_vml_root(bytes, "shapelayout"))
}

///|
/// Read top-level XSD element `o:signatureline` (vml-officeDrawing.xsd).
pub fn read_signatureline(bytes : Bytes) -> CT_SignatureLine raise {
  CT_SignatureLine::new(read_vml_root(bytes, "signatureline"))
}

///|
/// Read top-level XSD element `o:ink` (vml-officeDrawing.xsd).
pub fn read_ink(bytes : Bytes) -> CT_Ink raise {
  CT_Ink::new(read_vml_root(bytes, "ink"))
}

///|
/// Read top-level XSD element `o:diagram` (vml-officeDrawing.xsd).
pub fn read_diagram(bytes : Bytes) -> CT_Diagram raise {
  CT_Diagram::new(read_vml_root(bytes, "diagram"))
}

///|
/// Read top-level XSD element `o:equationxml` (vml-officeDrawing.xsd).
pub fn read_equationxml(bytes : Bytes) -> CT_EquationXml raise {
  CT_EquationXml::new(read_vml_root(bytes, "equationxml"))
}

///|
/// Read top-level XSD element `o:skew` (vml-officeDrawing.xsd).
pub fn read_skew(bytes : Bytes) -> CT_Skew raise {
  CT_Skew::new(read_vml_root(bytes, "skew"))
}

///|
/// Read top-level XSD element `o:extrusion` (vml-officeDrawing.xsd).
pub fn read_extrusion(bytes : Bytes) -> CT_Extrusion raise {
  CT_Extrusion::new(read_vml_root(bytes, "extrusion"))
}

///|
/// Read top-level XSD element `o:callout` (vml-officeDrawing.xsd).
pub fn read_callout(bytes : Bytes) -> CT_Callout raise {
  CT_Callout::new(read_vml_root(bytes, "callout"))
}

///|
/// Read top-level XSD element `o:lock` (vml-officeDrawing.xsd).
pub fn read_lock(bytes : Bytes) -> CT_Lock raise {
  CT_Lock::new(read_vml_root(bytes, "lock"))
}

///|
/// Read top-level XSD element `o:OLEObject` (vml-officeDrawing.xsd).
pub fn read_OLEObject(bytes : Bytes) -> CT_OLEObject raise {
  CT_OLEObject::new(read_vml_root(bytes, "OLEObject"))
}

///|
/// Read top-level XSD element `o:complex` (vml-officeDrawing.xsd).
pub fn read_complex(bytes : Bytes) -> CT_Complex raise {
  CT_Complex::new(read_vml_root(bytes, "complex"))
}

///|
/// Read top-level XSD element `o:left` (vml-officeDrawing.xsd). CT_StrokeChild.
pub fn read_left(bytes : Bytes) -> CT_StrokeChild raise {
  CT_StrokeChild::new(read_vml_root(bytes, "left"))
}

///|
/// Read top-level XSD element `o:top` (vml-officeDrawing.xsd). CT_StrokeChild.
pub fn read_top(bytes : Bytes) -> CT_StrokeChild raise {
  CT_StrokeChild::new(read_vml_root(bytes, "top"))
}

///|
/// Read top-level XSD element `o:right` (vml-officeDrawing.xsd). CT_StrokeChild.
pub fn read_right(bytes : Bytes) -> CT_StrokeChild raise {
  CT_StrokeChild::new(read_vml_root(bytes, "right"))
}

///|
/// Read top-level XSD element `o:bottom` (vml-officeDrawing.xsd). CT_StrokeChild.
pub fn read_bottom(bytes : Bytes) -> CT_StrokeChild raise {
  CT_StrokeChild::new(read_vml_root(bytes, "bottom"))
}

///|
/// Read top-level XSD element `o:column` (vml-officeDrawing.xsd). CT_StrokeChild.
pub fn read_column(bytes : Bytes) -> CT_StrokeChild raise {
  CT_StrokeChild::new(read_vml_root(bytes, "column"))
}

///|
/// Read top-level XSD element `o:clippath` (vml-officeDrawing.xsd).
pub fn read_clippath(bytes : Bytes) -> CT_ClipPath raise {
  CT_ClipPath::new(read_vml_root(bytes, "clippath"))
}

// ── vml-presentationDrawing.xsd top-level elements ─────────────────

///|
/// Read top-level XSD element `pvml:iscomment` (vml-presentationDrawing.xsd).
/// Empty sentinel element (CT_Empty).
pub fn read_iscomment(bytes : Bytes) -> CT_Empty raise {
  CT_Empty::new(read_vml_root(bytes, "iscomment"))
}

///|
/// Read top-level XSD element `pvml:textdata` (vml-presentationDrawing.xsd).
/// Relationship reference (CT_Rel).
pub fn read_textdata(bytes : Bytes) -> CT_Rel raise {
  CT_Rel::new(read_vml_root(bytes, "textdata"))
}

// ── vml-wordprocessingDrawing.xsd top-level elements ───────────────

///|
/// Read top-level XSD element `w10:bordertop` (vml-wordprocessingDrawing.xsd).
pub fn read_bordertop(bytes : Bytes) -> CT_Border raise {
  CT_Border::new(read_vml_root(bytes, "bordertop"))
}

///|
/// Read top-level XSD element `w10:borderleft` (vml-wordprocessingDrawing.xsd).
pub fn read_borderleft(bytes : Bytes) -> CT_Border raise {
  CT_Border::new(read_vml_root(bytes, "borderleft"))
}

///|
/// Read top-level XSD element `w10:borderright` (vml-wordprocessingDrawing.xsd).
pub fn read_borderright(bytes : Bytes) -> CT_Border raise {
  CT_Border::new(read_vml_root(bytes, "borderright"))
}

///|
/// Read top-level XSD element `w10:borderbottom` (vml-wordprocessingDrawing.xsd).
pub fn read_borderbottom(bytes : Bytes) -> CT_Border raise {
  CT_Border::new(read_vml_root(bytes, "borderbottom"))
}

///|
/// Read top-level XSD element `w10:wrap` (vml-wordprocessingDrawing.xsd).
pub fn read_wrap(bytes : Bytes) -> CT_Wrap raise {
  CT_Wrap::new(read_vml_root(bytes, "wrap"))
}

///|
/// Read top-level XSD element `w10:anchorlock` (vml-wordprocessingDrawing.xsd).
/// Empty marker element (CT_AnchorLock).
pub fn read_anchorlock(bytes : Bytes) -> CT_AnchorLock raise {
  CT_AnchorLock::new(read_vml_root(bytes, "anchorlock"))
}
