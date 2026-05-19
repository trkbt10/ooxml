///|
/// SpreadsheetML sheet types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn sheet_type_group_name() -> String {
  "spreadsheet_ml.sheet"
}

///|
/// XSD complex type CT_ObjectAnchor.
pub(all) struct CT_ObjectAnchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ObjectAnchor::new(element : @xml.Element) -> CT_ObjectAnchor {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CalcCell.
pub(all) struct CT_CalcCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CalcCell::new(element : @xml.Element) -> CT_CalcCell {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DataBinding.
pub(all) struct CT_DataBinding {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataBinding::new(element : @xml.Element) -> CT_DataBinding {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Tables.
pub(all) struct CT_Tables {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Tables::new(element : @xml.Element) -> CT_Tables {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableMissing.
pub(all) struct CT_TableMissing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableMissing::new(element : @xml.Element) -> CT_TableMissing {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WorksheetSource.
pub(all) struct CT_WorksheetSource {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WorksheetSource::new(element : @xml.Element) -> CT_WorksheetSource {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Pages.
pub(all) struct CT_Pages {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Pages::new(element : @xml.Element) -> CT_Pages {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PageItem.
pub(all) struct CT_PageItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageItem::new(element : @xml.Element) -> CT_PageItem {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PageFields.
pub(all) struct CT_PageFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageFields::new(element : @xml.Element) -> CT_PageFields {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PageField.
pub(all) struct CT_PageField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageField::new(element : @xml.Element) -> CT_PageField {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DataFields.
pub(all) struct CT_DataFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataFields::new(element : @xml.Element) -> CT_DataFields {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DataField.
pub(all) struct CT_DataField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataField::new(element : @xml.Element) -> CT_DataField {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_rowItems.
pub(all) struct CT_rowItems {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_rowItems::new(element : @xml.Element) -> CT_rowItems {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_colItems.
pub(all) struct CT_colItems {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_colItems::new(element : @xml.Element) -> CT_colItems {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RowFields.
pub(all) struct CT_RowFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RowFields::new(element : @xml.Element) -> CT_RowFields {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ColFields.
pub(all) struct CT_ColFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColFields::new(element : @xml.Element) -> CT_ColFields {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ConditionalFormats.
pub(all) struct CT_ConditionalFormats {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConditionalFormats::new(
  element : @xml.Element,
) -> CT_ConditionalFormats {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ConditionalFormat.
pub(all) struct CT_ConditionalFormat {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConditionalFormat::new(
  element : @xml.Element,
) -> CT_ConditionalFormat {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ChartFormats.
pub(all) struct CT_ChartFormats {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ChartFormats::new(element : @xml.Element) -> CT_ChartFormats {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ChartFormat.
pub(all) struct CT_ChartFormat {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ChartFormat::new(element : @xml.Element) -> CT_ChartFormat {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionHeaders.
pub(all) struct CT_RevisionHeaders {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionHeaders::new(element : @xml.Element) -> CT_RevisionHeaders {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionHeader.
pub(all) struct CT_RevisionHeader {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionHeader::new(element : @xml.Element) -> CT_RevisionHeader {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetId.
pub(all) struct CT_SheetId {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetId::new(element : @xml.Element) -> CT_SheetId {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ReviewedRevisions.
pub(all) struct CT_ReviewedRevisions {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ReviewedRevisions::new(
  element : @xml.Element,
) -> CT_ReviewedRevisions {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Reviewed.
pub(all) struct CT_Reviewed {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Reviewed::new(element : @xml.Element) -> CT_Reviewed {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionRowColumn.
pub(all) struct CT_RevisionRowColumn {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionRowColumn::new(
  element : @xml.Element,
) -> CT_RevisionRowColumn {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionCustomView.
pub(all) struct CT_RevisionCustomView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionCustomView::new(
  element : @xml.Element,
) -> CT_RevisionCustomView {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionSheetRename.
pub(all) struct CT_RevisionSheetRename {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionSheetRename::new(
  element : @xml.Element,
) -> CT_RevisionSheetRename {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionInsertSheet.
pub(all) struct CT_RevisionInsertSheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionInsertSheet::new(
  element : @xml.Element,
) -> CT_RevisionInsertSheet {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionCellChange.
pub(all) struct CT_RevisionCellChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionCellChange::new(
  element : @xml.Element,
) -> CT_RevisionCellChange {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Macrosheet.
pub(all) struct CT_Macrosheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Macrosheet::new(element : @xml.Element) -> CT_Macrosheet {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Dialogsheet.
pub(all) struct CT_Dialogsheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Dialogsheet::new(element : @xml.Element) -> CT_Dialogsheet {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Worksheet.
pub(all) struct CT_Worksheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Worksheet::new(element : @xml.Element) -> CT_Worksheet {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetData.
pub(all) struct CT_SheetData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetData::new(element : @xml.Element) -> CT_SheetData {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetCalcPr.
pub(all) struct CT_SheetCalcPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetCalcPr::new(element : @xml.Element) -> CT_SheetCalcPr {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetFormatPr.
pub(all) struct CT_SheetFormatPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetFormatPr::new(element : @xml.Element) -> CT_SheetFormatPr {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Cols.
pub(all) struct CT_Cols {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Cols::new(element : @xml.Element) -> CT_Cols {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Col: worksheet column range with min, max, width, style, hidden, bestFit, customWidth, outlineLevel attributes.
pub(all) struct CT_Col {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Col::new(element : @xml.Element) -> CT_Col {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Row: worksheet row with cell and extension children plus r, spans, style, customFormat, height, hidden, outlineLevel attributes.
pub(all) struct CT_Row {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Row::new(element : @xml.Element) -> CT_Row {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Cell: Schema sml.xsd complex type `CT_Cell` has
/// attributes `r`, `s`, `t`, `cm`, `vm`, and `ph`; child elements `f`, `v`,
/// `is`, and `extLst`; CT_Cell and CT_Cell::new own that worksheet cell
/// payload.
pub(all) struct CT_Cell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Cell::new(element : @xml.Element) -> CT_Cell {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetPr.
pub(all) struct CT_SheetPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetPr::new(element : @xml.Element) -> CT_SheetPr {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetDimension.
pub(all) struct CT_SheetDimension {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetDimension::new(element : @xml.Element) -> CT_SheetDimension {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetViews.
pub(all) struct CT_SheetViews {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetViews::new(element : @xml.Element) -> CT_SheetViews {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetView.
pub(all) struct CT_SheetView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetView::new(element : @xml.Element) -> CT_SheetView {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Pane. Attributes: xSplit, ySplit, topLeftCell,
/// activePane, state.
pub(all) struct CT_Pane {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Pane::new(element : @xml.Element) -> CT_Pane {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Selection.
pub(all) struct CT_Selection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Selection::new(element : @xml.Element) -> CT_Selection {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PageBreak.
pub(all) struct CT_PageBreak {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageBreak::new(element : @xml.Element) -> CT_PageBreak {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Break.
pub(all) struct CT_Break {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Break::new(element : @xml.Element) -> CT_Break {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DataConsolidate.
pub(all) struct CT_DataConsolidate {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataConsolidate::new(element : @xml.Element) -> CT_DataConsolidate {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DataRefs.
pub(all) struct CT_DataRefs {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataRefs::new(element : @xml.Element) -> CT_DataRefs {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DataRef.
pub(all) struct CT_DataRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataRef::new(element : @xml.Element) -> CT_DataRef {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MergeCells.
pub(all) struct CT_MergeCells {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MergeCells::new(element : @xml.Element) -> CT_MergeCells {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MergeCell.
pub(all) struct CT_MergeCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MergeCell::new(element : @xml.Element) -> CT_MergeCell {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellSmartTags.
pub(all) struct CT_CellSmartTags {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellSmartTags::new(element : @xml.Element) -> CT_CellSmartTags {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellSmartTag.
pub(all) struct CT_CellSmartTag {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellSmartTag::new(element : @xml.Element) -> CT_CellSmartTag {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellSmartTagPr.
pub(all) struct CT_CellSmartTagPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellSmartTagPr::new(element : @xml.Element) -> CT_CellSmartTagPr {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Drawing.
pub(all) struct CT_Drawing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Drawing::new(element : @xml.Element) -> CT_Drawing {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DrawingHF.
pub(all) struct CT_DrawingHF {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DrawingHF::new(element : @xml.Element) -> CT_DrawingHF {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CustomSheetViews.
pub(all) struct CT_CustomSheetViews {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomSheetViews::new(element : @xml.Element) -> CT_CustomSheetViews {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CustomSheetView.
pub(all) struct CT_CustomSheetView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomSheetView::new(element : @xml.Element) -> CT_CustomSheetView {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DataValidations.
pub(all) struct CT_DataValidations {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataValidations::new(element : @xml.Element) -> CT_DataValidations {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DataValidation.
pub(all) struct CT_DataValidation {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataValidation::new(element : @xml.Element) -> CT_DataValidation {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Hyperlinks.
pub(all) struct CT_Hyperlinks {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Hyperlinks::new(element : @xml.Element) -> CT_Hyperlinks {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Hyperlink.
pub(all) struct CT_Hyperlink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Hyperlink::new(element : @xml.Element) -> CT_Hyperlink {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellFormula.
pub(all) struct CT_CellFormula {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellFormula::new(element : @xml.Element) -> CT_CellFormula {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PageMargins.
pub(all) struct CT_PageMargins {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageMargins::new(element : @xml.Element) -> CT_PageMargins {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PrintOptions.
pub(all) struct CT_PrintOptions {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PrintOptions::new(element : @xml.Element) -> CT_PrintOptions {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_HeaderFooter.
pub(all) struct CT_HeaderFooter {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HeaderFooter::new(element : @xml.Element) -> CT_HeaderFooter {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Scenarios.
pub(all) struct CT_Scenarios {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Scenarios::new(element : @xml.Element) -> CT_Scenarios {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ProtectedRanges.
pub(all) struct CT_ProtectedRanges {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ProtectedRanges::new(element : @xml.Element) -> CT_ProtectedRanges {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ProtectedRange.
pub(all) struct CT_ProtectedRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ProtectedRange::new(element : @xml.Element) -> CT_ProtectedRange {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Scenario.
pub(all) struct CT_Scenario {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Scenario::new(element : @xml.Element) -> CT_Scenario {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_InputCells.
pub(all) struct CT_InputCells {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_InputCells::new(element : @xml.Element) -> CT_InputCells {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellWatches.
pub(all) struct CT_CellWatches {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellWatches::new(element : @xml.Element) -> CT_CellWatches {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellWatch.
pub(all) struct CT_CellWatch {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellWatch::new(element : @xml.Element) -> CT_CellWatch {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Chartsheet.
pub(all) struct CT_Chartsheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Chartsheet::new(element : @xml.Element) -> CT_Chartsheet {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ChartsheetPr.
pub(all) struct CT_ChartsheetPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ChartsheetPr::new(element : @xml.Element) -> CT_ChartsheetPr {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ChartsheetViews.
pub(all) struct CT_ChartsheetViews {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ChartsheetViews::new(element : @xml.Element) -> CT_ChartsheetViews {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ChartsheetView.
pub(all) struct CT_ChartsheetView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ChartsheetView::new(element : @xml.Element) -> CT_ChartsheetView {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CustomChartsheetViews.
pub(all) struct CT_CustomChartsheetViews {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomChartsheetViews::new(
  element : @xml.Element,
) -> CT_CustomChartsheetViews {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CustomChartsheetView.
pub(all) struct CT_CustomChartsheetView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomChartsheetView::new(
  element : @xml.Element,
) -> CT_CustomChartsheetView {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CustomProperty.
pub(all) struct CT_CustomProperty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomProperty::new(element : @xml.Element) -> CT_CustomProperty {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ObjectPr.
pub(all) struct CT_ObjectPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ObjectPr::new(element : @xml.Element) -> CT_ObjectPr {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Controls.
pub(all) struct CT_Controls {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Controls::new(element : @xml.Element) -> CT_Controls {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Control.
pub(all) struct CT_Control {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Control::new(element : @xml.Element) -> CT_Control {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ControlPr.
pub(all) struct CT_ControlPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ControlPr::new(element : @xml.Element) -> CT_ControlPr {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_IgnoredErrors.
pub(all) struct CT_IgnoredErrors {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_IgnoredErrors::new(element : @xml.Element) -> CT_IgnoredErrors {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_IgnoredError.
pub(all) struct CT_IgnoredError {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_IgnoredError::new(element : @xml.Element) -> CT_IgnoredError {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableParts.
pub(all) struct CT_TableParts {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableParts::new(element : @xml.Element) -> CT_TableParts {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TablePart.
pub(all) struct CT_TablePart {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TablePart::new(element : @xml.Element) -> CT_TablePart {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Table.
pub(all) struct CT_Table {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Table::new(element : @xml.Element) -> CT_Table {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableColumns.
pub(all) struct CT_TableColumns {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableColumns::new(element : @xml.Element) -> CT_TableColumns {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableColumn.
pub(all) struct CT_TableColumn {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableColumn::new(element : @xml.Element) -> CT_TableColumn {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableFormula.
pub(all) struct CT_TableFormula {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableFormula::new(element : @xml.Element) -> CT_TableFormula {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_BookViews.
pub(all) struct CT_BookViews {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BookViews::new(element : @xml.Element) -> CT_BookViews {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_BookView.
pub(all) struct CT_BookView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BookView::new(element : @xml.Element) -> CT_BookView {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CustomWorkbookViews.
pub(all) struct CT_CustomWorkbookViews {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomWorkbookViews::new(
  element : @xml.Element,
) -> CT_CustomWorkbookViews {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CustomWorkbookView.
pub(all) struct CT_CustomWorkbookView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomWorkbookView::new(
  element : @xml.Element,
) -> CT_CustomWorkbookView {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Sheets.
pub(all) struct CT_Sheets {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Sheets::new(element : @xml.Element) -> CT_Sheets {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Sheet: Schema sml.xsd complex type `CT_Sheet` has
/// attributes `name`, `sheetId`, and `state`, and references the `r:id`
/// relationship attribute group; CT_Sheet and CT_Sheet::new own that workbook
/// sheet entry.
pub(all) struct CT_Sheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Sheet::new(element : @xml.Element) -> CT_Sheet {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SheetBackgroundPicture.
pub(all) struct CT_SheetBackgroundPicture {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetBackgroundPicture::new(
  element : @xml.Element,
) -> CT_SheetBackgroundPicture {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WebPublishObjects.
pub(all) struct CT_WebPublishObjects {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebPublishObjects::new(
  element : @xml.Element,
) -> CT_WebPublishObjects {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WebPublishObject.
pub(all) struct CT_WebPublishObject {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebPublishObject::new(element : @xml.Element) -> CT_WebPublishObject {
  let group_name = sheet_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}
