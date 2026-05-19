// ECMA-376 Part 1 §20.1.2.2 DrawingML Graphic Vector Markup Language
// (GVML) cross-domain shape primitives. These complex types describe the
// shape, connector, picture, text-shape, graphic-frame, group-shape, and
// shared non-visual property containers that PresentationML, SpreadsheetML,
// and WordprocessingDrawingML import from DrawingML Main. The XSD
// definitions live in Annex A.4.1 dml-main.xsd at the following line ranges:
//
//   CT_GvmlUseShapeRectangle      line  938  (chunk4 owner — element wrapper)
//   CT_GvmlTextShape              lines 939..948 (chunk4 owner — element wrapper)
//   CT_GvmlShapeNonVisual         lines 949..954 (§20.1.2.2.29 nvSpPr)
//   CT_GvmlShape                  lines 955..963 (§20.1.2.2.33 sp)
//   CT_GvmlConnectorNonVisual     lines 964..970 (§20.1.2.2.25 nvCxnSpPr)
//   CT_GvmlConnector              lines 971..978 (§20.1.2.2.10 cxnSp)
//   CT_GvmlPictureNonVisual       lines 979..985 (§20.1.2.2.28 nvPicPr)
//   CT_GvmlPicture                lines 986..994 (§20.1.2.2.30 pic)
//   CT_GvmlGraphicFrameNonVisual  lines 995..1001 (§20.1.2.2.26 nvGraphicFramePr)
//   CT_GvmlGraphicalObjectFrame   lines 1002..1010 (§20.1.2.2.18 graphicFrame)
//   CT_GvmlGroupShapeNonVisual    lines 1011..1017 (chunk4 owner — element wrapper)
//   CT_GvmlGroupShape             lines 1018..1032 (chunk4 owner — element wrapper)
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit child-element fields decoded from the source
// `@xml.Element`. The element is preserved so the builder can round-trip
// unmodelled content (the `to_element` writer returns the captured
// element verbatim). The non-visual-property children
// (CT_NonVisualDrawingProps, CT_NonVisualDrawingShapeProps, …) are still
// element-only wrappers in this chunk (their CT_X projections will be
// typed by a later chunk) — we capture them as the existing CT_X
// projection so that callers continue to navigate via the same typed
// accessors.
//
// chunk3 owns the eight CT_Gvml(non-group) types. The recursive group
// shape and the text-shape choice are deferred to chunk4 and are kept
// as element-only wrappers here so chunk4 can type them without
// re-touching chunk3 callsites.

///|
/// XSD complex type CT_GvmlShapeNonVisual — Part 1 §20.1.2.2.29 nvSpPr.
/// Annex A.4.1 lines 949..954. Required child sequence: `cNvPr`
/// (CT_NonVisualDrawingProps) and `cNvSpPr`
/// (CT_NonVisualDrawingShapeProps).
pub(all) struct CT_GvmlShapeNonVisual {
  /// <cNvPr> (CT_NonVisualDrawingProps) — required common non-visual
  /// properties.
  c_nv_pr : CT_NonVisualDrawingProps
  /// <cNvSpPr> (CT_NonVisualDrawingShapeProps) — required shape-specific
  /// non-visual properties.
  c_nv_sp_pr : CT_NonVisualDrawingShapeProps
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlShapeNonVisual raise SchemaViolation {
  let c_nv_pr = match ct_first_child(element, "cNvPr") {
    Some(c) => CT_NonVisualDrawingProps::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlShapeNonVisual/cNvPr",
        reason="missing required child element <cNvPr>",
      )
  }
  let c_nv_sp_pr = match ct_first_child(element, "cNvSpPr") {
    Some(c) => CT_NonVisualDrawingShapeProps::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlShapeNonVisual/cNvSpPr",
        reason="missing required child element <cNvSpPr>",
      )
  }
  { c_nv_pr, c_nv_sp_pr, element }
}

///|
pub fn CT_GvmlShapeNonVisual::to_element(
  self : CT_GvmlShapeNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GvmlShape — Part 1 §20.1.2.2.33 sp (Shape).
/// Annex A.4.1 lines 955..963. Required `nvSpPr` (CT_GvmlShapeNonVisual)
/// and `spPr` (CT_ShapeProperties), plus optional `txSp` (CT_GvmlTextShape),
/// `style` (CT_ShapeStyle) and `extLst` (CT_OfficeArtExtensionList).
pub(all) struct CT_GvmlShape {
  /// <nvSpPr> (CT_GvmlShapeNonVisual) — required.
  nv_sp_pr : CT_GvmlShapeNonVisual
  /// <spPr> (CT_ShapeProperties) — required.
  sp_pr : CT_ShapeProperties
  /// <txSp> (CT_GvmlTextShape) — optional text shape. CT_GvmlTextShape
  /// remains an element-only wrapper (chunk4 owner) — it is referenced
  /// here by the typed projection.
  tx_sp : CT_GvmlTextShape?
  /// <style> (CT_ShapeStyle) — optional.
  style : CT_ShapeStyle?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlShape::new(
  element : @xml.Element,
) -> CT_GvmlShape raise SchemaViolation {
  let nv_sp_pr = match ct_first_child(element, "nvSpPr") {
    Some(c) => CT_GvmlShapeNonVisual::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlShape/nvSpPr",
        reason="missing required child element <nvSpPr>",
      )
  }
  let sp_pr = match ct_first_child(element, "spPr") {
    Some(c) => CT_ShapeProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlShape/spPr",
        reason="missing required child element <spPr>",
      )
  }
  let tx_sp = match ct_first_child(element, "txSp") {
    Some(c) => Some(CT_GvmlTextShape::new(c))
    None => None
  }
  let style = match ct_first_child(element, "style") {
    Some(c) => Some(CT_ShapeStyle::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { nv_sp_pr, sp_pr, tx_sp, style, ext_lst, element }
}

///|
pub fn CT_GvmlShape::to_element(self : CT_GvmlShape) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GvmlConnectorNonVisual — Part 1 §20.1.2.2.25
/// nvCxnSpPr. Annex A.4.1 lines 964..970. Required child sequence:
/// `cNvPr` (CT_NonVisualDrawingProps) and `cNvCxnSpPr`
/// (CT_NonVisualConnectorProperties).
pub(all) struct CT_GvmlConnectorNonVisual {
  /// <cNvPr> (CT_NonVisualDrawingProps) — required.
  c_nv_pr : CT_NonVisualDrawingProps
  /// <cNvCxnSpPr> (CT_NonVisualConnectorProperties) — required.
  c_nv_cxn_sp_pr : CT_NonVisualConnectorProperties
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlConnectorNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlConnectorNonVisual raise SchemaViolation {
  let c_nv_pr = match ct_first_child(element, "cNvPr") {
    Some(c) => CT_NonVisualDrawingProps::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlConnectorNonVisual/cNvPr",
        reason="missing required child element <cNvPr>",
      )
  }
  let c_nv_cxn_sp_pr = match ct_first_child(element, "cNvCxnSpPr") {
    Some(c) => CT_NonVisualConnectorProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlConnectorNonVisual/cNvCxnSpPr",
        reason="missing required child element <cNvCxnSpPr>",
      )
  }
  { c_nv_pr, c_nv_cxn_sp_pr, element }
}

///|
pub fn CT_GvmlConnectorNonVisual::to_element(
  self : CT_GvmlConnectorNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GvmlConnector — Part 1 §20.1.2.2.10 cxnSp
/// (Connection Shape). Annex A.4.1 lines 971..978. Required `nvCxnSpPr`
/// (CT_GvmlConnectorNonVisual) and `spPr` (CT_ShapeProperties); optional
/// `style` (CT_ShapeStyle) and `extLst` (CT_OfficeArtExtensionList).
pub(all) struct CT_GvmlConnector {
  /// <nvCxnSpPr> (CT_GvmlConnectorNonVisual) — required.
  nv_cxn_sp_pr : CT_GvmlConnectorNonVisual
  /// <spPr> (CT_ShapeProperties) — required.
  sp_pr : CT_ShapeProperties
  /// <style> (CT_ShapeStyle) — optional.
  style : CT_ShapeStyle?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlConnector::new(
  element : @xml.Element,
) -> CT_GvmlConnector raise SchemaViolation {
  let nv_cxn_sp_pr = match ct_first_child(element, "nvCxnSpPr") {
    Some(c) => CT_GvmlConnectorNonVisual::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlConnector/nvCxnSpPr",
        reason="missing required child element <nvCxnSpPr>",
      )
  }
  let sp_pr = match ct_first_child(element, "spPr") {
    Some(c) => CT_ShapeProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlConnector/spPr",
        reason="missing required child element <spPr>",
      )
  }
  let style = match ct_first_child(element, "style") {
    Some(c) => Some(CT_ShapeStyle::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { nv_cxn_sp_pr, sp_pr, style, ext_lst, element }
}

///|
pub fn CT_GvmlConnector::to_element(self : CT_GvmlConnector) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GvmlPictureNonVisual — Part 1 §20.1.2.2.28
/// nvPicPr. Annex A.4.1 lines 979..985. Required child sequence: `cNvPr`
/// (CT_NonVisualDrawingProps) and `cNvPicPr`
/// (CT_NonVisualPictureProperties).
pub(all) struct CT_GvmlPictureNonVisual {
  /// <cNvPr> (CT_NonVisualDrawingProps) — required.
  c_nv_pr : CT_NonVisualDrawingProps
  /// <cNvPicPr> (CT_NonVisualPictureProperties) — required.
  c_nv_pic_pr : CT_NonVisualPictureProperties
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlPictureNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlPictureNonVisual raise SchemaViolation {
  let c_nv_pr = match ct_first_child(element, "cNvPr") {
    Some(c) => CT_NonVisualDrawingProps::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlPictureNonVisual/cNvPr",
        reason="missing required child element <cNvPr>",
      )
  }
  let c_nv_pic_pr = match ct_first_child(element, "cNvPicPr") {
    Some(c) => CT_NonVisualPictureProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlPictureNonVisual/cNvPicPr",
        reason="missing required child element <cNvPicPr>",
      )
  }
  { c_nv_pr, c_nv_pic_pr, element }
}

///|
pub fn CT_GvmlPictureNonVisual::to_element(
  self : CT_GvmlPictureNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GvmlPicture — Part 1 §20.1.2.2.30 pic (Picture).
/// Annex A.4.1 lines 986..994. Required `nvPicPr` (CT_GvmlPictureNonVisual),
/// `blipFill` (CT_BlipFillProperties) and `spPr` (CT_ShapeProperties);
/// optional `style` (CT_ShapeStyle) and `extLst`
/// (CT_OfficeArtExtensionList).
pub(all) struct CT_GvmlPicture {
  /// <nvPicPr> (CT_GvmlPictureNonVisual) — required.
  nv_pic_pr : CT_GvmlPictureNonVisual
  /// <blipFill> (CT_BlipFillProperties) — required.
  blip_fill : CT_BlipFillProperties
  /// <spPr> (CT_ShapeProperties) — required.
  sp_pr : CT_ShapeProperties
  /// <style> (CT_ShapeStyle) — optional.
  style : CT_ShapeStyle?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlPicture::new(
  element : @xml.Element,
) -> CT_GvmlPicture raise SchemaViolation {
  let nv_pic_pr = match ct_first_child(element, "nvPicPr") {
    Some(c) => CT_GvmlPictureNonVisual::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlPicture/nvPicPr",
        reason="missing required child element <nvPicPr>",
      )
  }
  let blip_fill = match ct_first_child(element, "blipFill") {
    Some(c) => CT_BlipFillProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlPicture/blipFill",
        reason="missing required child element <blipFill>",
      )
  }
  let sp_pr = match ct_first_child(element, "spPr") {
    Some(c) => CT_ShapeProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlPicture/spPr",
        reason="missing required child element <spPr>",
      )
  }
  let style = match ct_first_child(element, "style") {
    Some(c) => Some(CT_ShapeStyle::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { nv_pic_pr, blip_fill, sp_pr, style, ext_lst, element }
}

///|
pub fn CT_GvmlPicture::to_element(self : CT_GvmlPicture) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GvmlGraphicFrameNonVisual — Part 1 §20.1.2.2.26
/// nvGraphicFramePr. Annex A.4.1 lines 995..1001. Required child
/// sequence: `cNvPr` (CT_NonVisualDrawingProps) and `cNvGraphicFramePr`
/// (CT_NonVisualGraphicFrameProperties).
pub(all) struct CT_GvmlGraphicFrameNonVisual {
  /// <cNvPr> (CT_NonVisualDrawingProps) — required.
  c_nv_pr : CT_NonVisualDrawingProps
  /// <cNvGraphicFramePr> (CT_NonVisualGraphicFrameProperties) — required.
  c_nv_graphic_frame_pr : CT_NonVisualGraphicFrameProperties
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlGraphicFrameNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlGraphicFrameNonVisual raise SchemaViolation {
  let c_nv_pr = match ct_first_child(element, "cNvPr") {
    Some(c) => CT_NonVisualDrawingProps::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlGraphicFrameNonVisual/cNvPr",
        reason="missing required child element <cNvPr>",
      )
  }
  let c_nv_graphic_frame_pr = match
    ct_first_child(element, "cNvGraphicFramePr") {
    Some(c) => CT_NonVisualGraphicFrameProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlGraphicFrameNonVisual/cNvGraphicFramePr",
        reason="missing required child element <cNvGraphicFramePr>",
      )
  }
  { c_nv_pr, c_nv_graphic_frame_pr, element }
}

///|
pub fn CT_GvmlGraphicFrameNonVisual::to_element(
  self : CT_GvmlGraphicFrameNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GvmlGraphicalObjectFrame — Part 1 §20.1.2.2.18
/// graphicFrame (Graphic Frame). Annex A.4.1 lines 1002..1010. Required
/// `nvGraphicFramePr` (CT_GvmlGraphicFrameNonVisual), `graphic`
/// (CT_GraphicalObject) and `xfrm` (CT_Transform2D); optional `extLst`
/// (CT_OfficeArtExtensionList).
pub(all) struct CT_GvmlGraphicalObjectFrame {
  /// <nvGraphicFramePr> (CT_GvmlGraphicFrameNonVisual) — required.
  nv_graphic_frame_pr : CT_GvmlGraphicFrameNonVisual
  /// <graphic> (CT_GraphicalObject) — required (referenced via xsd:element
  /// ref="graphic", not a typed child).
  graphic : CT_GraphicalObject
  /// <xfrm> (CT_Transform2D) — required.
  xfrm : CT_Transform2D
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlGraphicalObjectFrame::new(
  element : @xml.Element,
) -> CT_GvmlGraphicalObjectFrame raise SchemaViolation {
  let nv_graphic_frame_pr = match ct_first_child(element, "nvGraphicFramePr") {
    Some(c) => CT_GvmlGraphicFrameNonVisual::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlGraphicalObjectFrame/nvGraphicFramePr",
        reason="missing required child element <nvGraphicFramePr>",
      )
  }
  let graphic = match ct_first_child(element, "graphic") {
    Some(c) => CT_GraphicalObject::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlGraphicalObjectFrame/graphic",
        reason="missing required child element <graphic>",
      )
  }
  let xfrm = match ct_first_child(element, "xfrm") {
    Some(c) => CT_Transform2D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GvmlGraphicalObjectFrame/xfrm",
        reason="missing required child element <xfrm>",
      )
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { nv_graphic_frame_pr, graphic, xfrm, ext_lst, element }
}

///|
pub fn CT_GvmlGraphicalObjectFrame::to_element(
  self : CT_GvmlGraphicalObjectFrame,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GvmlGroupShapeNonVisual — Part 1 §20.1.2.2.27
/// nvGrpSpPr (Non-Visual Properties for a Group Shape). Sequence: cNvPr
/// (CT_NonVisualDrawingProps), cNvGrpSpPr
/// (CT_NonVisualGroupDrawingShapeProps). Annex A.4.1 line 1015. Owned
/// by chunk4; kept as an element-only wrapper here.
pub(all) struct CT_GvmlGroupShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlGroupShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlGroupShapeNonVisual {
  { element, }
}

///|
/// XSD complex type CT_GvmlGroupShape — Part 1 §20.1.2.2.20 grpSp (Group
/// Shape). Sequence: nvGrpSpPr (CT_GvmlGroupShapeNonVisual), grpSpPr
/// (CT_GroupShapeProperties), choice (txSp/sp/cxnSp/pic/graphicFrame/grpSp)
/// 0..unbounded, extLst? (CT_OfficeArtExtensionList). Annex A.4.1 line
/// 1022; reused by lockedCanvas (§20.3) and PresentationML spTree
/// (§19.3.1.45). Owned by chunk4 (the recursive `grpSp` choice
/// references CT_GvmlGroupShape itself); kept as an element-only
/// wrapper here.
pub(all) struct CT_GvmlGroupShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlGroupShape::new(element : @xml.Element) -> CT_GvmlGroupShape {
  { element, }
}

///|
/// XSD complex type CT_GvmlTextShape — Part 1 §20.1.2.2.41 txSp (Text
/// Shape). Sequence: txBody (CT_TextBody), choice (useSpRect
/// (CT_GvmlUseShapeRectangle) | xfrm (CT_Transform2D)), extLst?
/// (CT_OfficeArtExtensionList). Annex A.4.1 line 940. Owned by chunk4;
/// kept as an element-only wrapper here.
pub(all) struct CT_GvmlTextShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlTextShape::new(element : @xml.Element) -> CT_GvmlTextShape {
  { element, }
}

///|
/// XSD complex type CT_GvmlUseShapeRectangle — Part 1 §20.1.2.2.42
/// useSpRect (Use Shape Text Rectangle). Empty complex type — no
/// attributes or children. Annex A.4.1 line 939. Owned by chunk4; kept
/// as an element-only wrapper here.
pub(all) struct CT_GvmlUseShapeRectangle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlUseShapeRectangle::new(
  element : @xml.Element,
) -> CT_GvmlUseShapeRectangle {
  { element, }
}
