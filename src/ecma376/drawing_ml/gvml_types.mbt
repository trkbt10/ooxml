// ECMA-376 Part 1 §20.1.2.2 DrawingML Graphic Vector Markup Language
// (GVML) cross-domain shape primitives. These complex types describe the
// shape, connector, picture, text-shape, graphic-frame, group-shape, and
// shared non-visual property containers that PresentationML, SpreadsheetML,
// and WordprocessingDrawingML import from DrawingML Main. The XSD
// definitions live in Annex A.4.1 lines 939..1036 and §20.1.2.2.* §-anchors
// in the prose enumerate every element wrapper.
//
// The wrappers preserve the source @xml.Element so that callers can
// inspect or pass through namespace data without lossy re-serialization;
// downstream packages (PresentationML §19.3.1, WML §17.x DrawingML object,
// SML §18 worksheet drawings) construct these via CT_X::new(element).

///|
/// XSD complex type CT_GvmlShapeNonVisual — Part 1 §20.1.2.2.29 nvSpPr
/// (Non-Visual Properties for a Shape). Sequence: cNvPr
/// (CT_NonVisualDrawingProps), cNvSpPr (CT_NonVisualDrawingShapeProps).
/// Annex A.4.1 line 951.
pub(all) struct CT_GvmlShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlShapeNonVisual {
  { element, }
}

///|
/// XSD complex type CT_GvmlShape — Part 1 §20.1.2.2.33 sp (Shape).
/// Sequence: nvSpPr (CT_GvmlShapeNonVisual), spPr (CT_ShapeProperties),
/// txSp? (CT_GvmlTextShape), style? (CT_ShapeStyle), extLst?
/// (CT_OfficeArtExtensionList). Annex A.4.1 line 958.
pub(all) struct CT_GvmlShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlShape::new(element : @xml.Element) -> CT_GvmlShape {
  { element, }
}

///|
/// XSD complex type CT_GvmlConnectorNonVisual — Part 1 §20.1.2.2.25
/// nvCxnSpPr (Non-Visual Properties for a Connection Shape). Sequence:
/// cNvPr (CT_NonVisualDrawingProps), cNvCxnSpPr
/// (CT_NonVisualConnectorProperties). Annex A.4.1 line 967.
pub(all) struct CT_GvmlConnectorNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlConnectorNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlConnectorNonVisual {
  { element, }
}

///|
/// XSD complex type CT_GvmlConnector — Part 1 §20.1.2.2.10 cxnSp
/// (Connection Shape). Sequence: nvCxnSpPr (CT_GvmlConnectorNonVisual),
/// spPr (CT_ShapeProperties), style? (CT_ShapeStyle), extLst?
/// (CT_OfficeArtExtensionList). Annex A.4.1 line 974.
pub(all) struct CT_GvmlConnector {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlConnector::new(element : @xml.Element) -> CT_GvmlConnector {
  { element, }
}

///|
/// XSD complex type CT_GvmlPictureNonVisual — Part 1 §20.1.2.2.28 nvPicPr
/// (Non-Visual Properties for a Picture). Sequence: cNvPr
/// (CT_NonVisualDrawingProps), cNvPicPr (CT_NonVisualPictureProperties).
/// Annex A.4.1 line 983.
pub(all) struct CT_GvmlPictureNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlPictureNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlPictureNonVisual {
  { element, }
}

///|
/// XSD complex type CT_GvmlPicture — Part 1 §20.1.2.2.30 pic (Picture).
/// Sequence: nvPicPr (CT_GvmlPictureNonVisual), blipFill
/// (CT_BlipFillProperties), spPr (CT_ShapeProperties), style?
/// (CT_ShapeStyle), extLst? (CT_OfficeArtExtensionList). Annex A.4.1 line
/// 990.
pub(all) struct CT_GvmlPicture {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlPicture::new(element : @xml.Element) -> CT_GvmlPicture {
  { element, }
}

///|
/// XSD complex type CT_GvmlGraphicFrameNonVisual — Part 1 §20.1.2.2.26
/// nvGraphicFramePr (Non-Visual Properties for a Graphic Frame). Sequence:
/// cNvPr (CT_NonVisualDrawingProps), cNvGraphicFramePr
/// (CT_NonVisualGraphicFrameProperties). Annex A.4.1 line 999.
pub(all) struct CT_GvmlGraphicFrameNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlGraphicFrameNonVisual::new(
  element : @xml.Element,
) -> CT_GvmlGraphicFrameNonVisual {
  { element, }
}

///|
/// XSD complex type CT_GvmlGraphicalObjectFrame — Part 1 §20.1.2.2.18
/// graphicFrame (Graphic Frame). Sequence: nvGraphicFramePr
/// (CT_GvmlGraphicFrameNonVisual), graphic (CT_GraphicalObject), xfrm
/// (CT_Transform2D), extLst? (CT_OfficeArtExtensionList). Annex A.4.1 line
/// 1006.
pub(all) struct CT_GvmlGraphicalObjectFrame {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlGraphicalObjectFrame::new(
  element : @xml.Element,
) -> CT_GvmlGraphicalObjectFrame {
  { element, }
}

///|
/// XSD complex type CT_GvmlGroupShapeNonVisual — Part 1 §20.1.2.2.27
/// nvGrpSpPr (Non-Visual Properties for a Group Shape). Sequence: cNvPr
/// (CT_NonVisualDrawingProps), cNvGrpSpPr
/// (CT_NonVisualGroupDrawingShapeProps). Annex A.4.1 line 1015.
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
/// (§19.3.1.45).
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
/// (CT_OfficeArtExtensionList). Annex A.4.1 line 940.
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
/// attributes or children. Annex A.4.1 line 939.
pub(all) struct CT_GvmlUseShapeRectangle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GvmlUseShapeRectangle::new(
  element : @xml.Element,
) -> CT_GvmlUseShapeRectangle {
  { element, }
}
