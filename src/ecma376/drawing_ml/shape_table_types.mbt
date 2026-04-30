///|
/// XSD complex type CT_GroupShapeProperties (§20.1.5): attribute bwMode; children xfrm, scene3d, extLst.
pub(all) struct CT_GroupShapeProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupShapeProperties::new(
  element : @xml.Element,
) -> CT_GroupShapeProperties {
  { element, }
}

///|
/// XSD complex type CT_ShapeProperties (§20.1.5): attribute bwMode; children xfrm, ln, scene3d, sp3d, extLst.
pub(all) struct CT_ShapeProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeProperties::new(element : @xml.Element) -> CT_ShapeProperties {
  { element, }
}

///|
/// XSD complex type CT_NonVisualDrawingProps (§20.1.5): attributes id, name, descr, hidden, title; hyperlink children.
pub(all) struct CT_NonVisualDrawingProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualDrawingProps::new(
  element : @xml.Element,
) -> CT_NonVisualDrawingProps {
  { element, }
}

///|
/// XSD complex type CT_NonVisualDrawingShapeProps (§20.1.5): attribute txBox; children spLocks, extLst.
pub(all) struct CT_NonVisualDrawingShapeProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualDrawingShapeProps::new(
  element : @xml.Element,
) -> CT_NonVisualDrawingShapeProps {
  { element, }
}

///|
/// XSD complex type CT_NonVisualConnectorProperties (§20.1.5): connector locks, start/end connections, extLst.
pub(all) struct CT_NonVisualConnectorProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualConnectorProperties::new(
  element : @xml.Element,
) -> CT_NonVisualConnectorProperties {
  { element, }
}

///|
/// XSD complex type CT_NonVisualGraphicFrameProperties (§20.1.5): graphicFrameLocks and extLst.
pub(all) struct CT_NonVisualGraphicFrameProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualGraphicFrameProperties::new(
  element : @xml.Element,
) -> CT_NonVisualGraphicFrameProperties {
  { element, }
}

///|
/// XSD complex type CT_NonVisualGroupDrawingShapeProps (§20.1.5): grpSpLocks and extLst.
pub(all) struct CT_NonVisualGroupDrawingShapeProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualGroupDrawingShapeProps::new(
  element : @xml.Element,
) -> CT_NonVisualGroupDrawingShapeProps {
  { element, }
}

///|
/// XSD complex type CT_NonVisualPictureProperties (§20.1.5): attribute preferRelativeResize; children picLocks, extLst.
pub(all) struct CT_NonVisualPictureProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualPictureProperties::new(
  element : @xml.Element,
) -> CT_NonVisualPictureProperties {
  { element, }
}

///|
/// XSD complex type CT_GraphicalObject (§20.1.5): child graphicData.
pub(all) struct CT_GraphicalObject {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObject::new(element : @xml.Element) -> CT_GraphicalObject {
  { element, }
}

///|
/// XSD complex type CT_GraphicalObjectData (§20.1.5): attribute uri and open content.
pub(all) struct CT_GraphicalObjectData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectData::new(
  element : @xml.Element,
) -> CT_GraphicalObjectData {
  { element, }
}

///|
/// XSD complex type CT_GraphicalObjectFrameLocking (§20.1.5): noGrp, noDrilldown, noSelect, noChangeAspect, noMove, noResize.
pub(all) struct CT_GraphicalObjectFrameLocking {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectFrameLocking::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameLocking {
  { element, }
}

///|
/// XSD complex type CT_GroupLocking (§20.1.5): grouping, selection, rotation, aspect, move, resize locks.
pub(all) struct CT_GroupLocking {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupLocking::new(element : @xml.Element) -> CT_GroupLocking {
  { element, }
}

///|
/// XSD complex type CT_ShapeLocking (§20.1.5): attribute noTextEdit and extLst.
pub(all) struct CT_ShapeLocking {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeLocking::new(element : @xml.Element) -> CT_ShapeLocking {
  { element, }
}

///|
/// XSD complex type CT_ConnectorLocking (§20.1.5): extLst.
pub(all) struct CT_ConnectorLocking {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectorLocking::new(element : @xml.Element) -> CT_ConnectorLocking {
  { element, }
}

///|
/// XSD complex type CT_PictureLocking (§20.1.5): attribute noCrop and extLst.
pub(all) struct CT_PictureLocking {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PictureLocking::new(element : @xml.Element) -> CT_PictureLocking {
  { element, }
}

///|
/// XSD complex type CT_ContentPartLocking (§20.1.5): extLst.
pub(all) struct CT_ContentPartLocking {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ContentPartLocking::new(
  element : @xml.Element,
) -> CT_ContentPartLocking {
  { element, }
}

///|
/// XSD complex type CT_Hyperlink (§20.1.5): relationship id, target/action metadata, sound, and extLst.
pub(all) struct CT_Hyperlink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Hyperlink::new(element : @xml.Element) -> CT_Hyperlink {
  { element, }
}

///|
/// XSD complex type CT_TableCellProperties (§20.1.3): margins, vertical layout, borders, 3D, headers, extLst.
pub(all) struct CT_TableCellProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableCellProperties::new(
  element : @xml.Element,
) -> CT_TableCellProperties {
  { element, }
}

///|
/// XSD complex type CT_TableCol (§20.1.3): attribute w; child extLst.
pub(all) struct CT_TableCol {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableCol::new(element : @xml.Element) -> CT_TableCol {
  { element, }
}

///|
/// XSD complex type CT_TableGrid (§20.1.3): child gridCol.
pub(all) struct CT_TableGrid {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableGrid::new(element : @xml.Element) -> CT_TableGrid {
  { element, }
}

///|
/// XSD complex type CT_TableCell (§20.1.3): attributes rowSpan, gridSpan, hMerge, vMerge, id; children txBody, tcPr, extLst.
pub(all) struct CT_TableCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableCell::new(element : @xml.Element) -> CT_TableCell {
  { element, }
}

///|
/// XSD complex type CT_TableRow (§20.1.3): attribute h; children tc, extLst.
pub(all) struct CT_TableRow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableRow::new(element : @xml.Element) -> CT_TableRow {
  { element, }
}

///|
/// XSD complex type CT_TableProperties (§20.1.3): rtl, edge/banding attributes and table style children.
pub(all) struct CT_TableProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableProperties::new(element : @xml.Element) -> CT_TableProperties {
  { element, }
}

///|
/// XSD complex type CT_Table (§20.1.3): children tblPr, tblGrid, tr.
pub(all) struct CT_Table {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Table::new(element : @xml.Element) -> CT_Table {
  { element, }
}

///|
/// XSD complex type CT_TableStyleTextStyle (§20.1.3): attributes b, i; child extLst.
pub(all) struct CT_TableStyleTextStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyleTextStyle::new(
  element : @xml.Element,
) -> CT_TableStyleTextStyle {
  { element, }
}

///|
/// XSD complex type CT_TableCellBorderStyle (§20.1.3): themed line styles for table cell borders.
pub(all) struct CT_TableCellBorderStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableCellBorderStyle::new(
  element : @xml.Element,
) -> CT_TableCellBorderStyle {
  { element, }
}

///|
/// XSD complex type CT_TableBackgroundStyle (§20.1.3): table background style choice.
pub(all) struct CT_TableBackgroundStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableBackgroundStyle::new(
  element : @xml.Element,
) -> CT_TableBackgroundStyle {
  { element, }
}

///|
/// XSD complex type CT_TableStyleCellStyle (§20.1.3): cell border style and 3D settings.
pub(all) struct CT_TableStyleCellStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyleCellStyle::new(
  element : @xml.Element,
) -> CT_TableStyleCellStyle {
  { element, }
}

///|
/// XSD complex type CT_TablePartStyle (§20.1.3): text and cell style for one table part.
pub(all) struct CT_TablePartStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TablePartStyle::new(element : @xml.Element) -> CT_TablePartStyle {
  { element, }
}

///|
/// XSD complex type CT_TableStyle (§20.1.3): style id/name and part styles.
pub(all) struct CT_TableStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyle::new(element : @xml.Element) -> CT_TableStyle {
  { element, }
}

///|
/// XSD complex type CT_TableStyleList (§20.1.3): attribute def; child tblStyle.
pub(all) struct CT_TableStyleList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyleList::new(element : @xml.Element) -> CT_TableStyleList {
  { element, }
}

///|
pub fn read_graphical_object(bytes : Bytes) -> CT_GraphicalObject raise {
  CT_GraphicalObject::new(read_main_root(bytes, "graphic"))
}

///|
pub fn write_graphical_object(value : CT_GraphicalObject) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_table(bytes : Bytes) -> CT_Table raise {
  CT_Table::new(read_main_root(bytes, "tbl"))
}

///|
pub fn write_table(value : CT_Table) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_table_style_list(bytes : Bytes) -> CT_TableStyleList raise {
  CT_TableStyleList::new(read_main_root(bytes, "tblStyleLst"))
}

///|
pub fn write_table_style_list(value : CT_TableStyleList) -> Bytes {
  write_element(value.element)
}
