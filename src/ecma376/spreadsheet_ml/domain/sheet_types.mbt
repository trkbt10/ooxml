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
/// XSD complex type CT_Cols — Part 1 §18.3.1.17. Worksheet column-range
/// container: one or more `<col>` (CT_Col) children.
pub(all) struct CT_Cols {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <col>+ (CT_Col) — one or more column ranges.
  cols : Array[CT_Col]
} derive(Eq, Debug)

///|
pub fn CT_Cols::new(element : @xml.Element) -> CT_Cols {
  let cols : Array[CT_Col] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "col" {
        cols.push(CT_Col::new(child_element))
      }
    }
  }
  { element, cols }
}

///|
/// XSD complex type CT_Col — Part 1 §18.3.1.13. Worksheet column range:
/// required `@min`, `@max` (xsd:unsignedInt); optional `@width` (xsd:double),
/// `@style` (xsd:unsignedInt, default 0), `@hidden` (xsd:boolean, default
/// false), `@bestFit` (default false), `@customWidth` (default false),
/// `@phonetic` (default false), `@outlineLevel` (xsd:unsignedByte, default 0),
/// `@collapsed` (default false).
pub(all) struct CT_Col {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @min (xsd:unsignedInt) — required first column index.
  min : Int
  /// @max (xsd:unsignedInt) — required last column index.
  max : Int
  /// @width (xsd:double) — optional column width.
  width : Double?
  /// @style (xsd:unsignedInt, default 0) — optional default cell style.
  style : Int
  /// @hidden (xsd:boolean, default false).
  hidden : Bool
  /// @bestFit (xsd:boolean, default false).
  best_fit : Bool
  /// @customWidth (xsd:boolean, default false).
  custom_width : Bool
  /// @phonetic (xsd:boolean, default false).
  phonetic : Bool
  /// @outlineLevel (xsd:unsignedByte, default 0).
  outline_level : Int
  /// @collapsed (xsd:boolean, default false).
  collapsed : Bool
} derive(Eq, Debug)

///|
pub fn CT_Col::new(element : @xml.Element) -> CT_Col {
  let min = attr_uint(element, "min", 0)
  let max = attr_uint(element, "max", 0)
  let width = attr_double_opt(element, "width")
  let style = attr_uint(element, "style", 0)
  let hidden = attr_bool(element, "hidden", false)
  let best_fit = attr_bool(element, "bestFit", false)
  let custom_width = attr_bool(element, "customWidth", false)
  let phonetic = attr_bool(element, "phonetic", false)
  let outline_level = attr_uint(element, "outlineLevel", 0)
  let collapsed = attr_bool(element, "collapsed", false)
  {
    element,
    min,
    max,
    width,
    style,
    hidden,
    best_fit,
    custom_width,
    phonetic,
    outline_level,
    collapsed,
  }
}

///|
/// XSD complex type CT_Row — Part 1 §18.3.1.73. Worksheet row record.
/// Children: zero or more `<c>` (CT_Cell) cells, optional `<extLst>`
/// (CT_ExtensionList). Attributes: optional `@r` (row index), `@spans`
/// (ST_CellSpans token list), `@s` (style index, default 0), `@customFormat`
/// (default false), `@ht` (height), `@hidden`, `@customHeight`,
/// `@outlineLevel` (default 0), `@collapsed`, `@thickTop`, `@thickBot`, `@ph`.
pub(all) struct CT_Row {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <c>* (CT_Cell) — zero or more cells.
  cells : Array[CT_Cell]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
  /// @r (xsd:unsignedInt) — optional row index.
  r : Int?
  /// @spans (ST_CellSpans) — optional span token list.
  spans : String?
  /// @s (xsd:unsignedInt, default 0) — style index.
  s : Int
  /// @customFormat (xsd:boolean, default false).
  custom_format : Bool
  /// @ht (xsd:double) — optional explicit row height.
  ht : Double?
  /// @hidden (xsd:boolean, default false).
  hidden : Bool
  /// @customHeight (xsd:boolean, default false).
  custom_height : Bool
  /// @outlineLevel (xsd:unsignedByte, default 0).
  outline_level : Int
  /// @collapsed (xsd:boolean, default false).
  collapsed : Bool
  /// @thickTop (xsd:boolean, default false).
  thick_top : Bool
  /// @thickBot (xsd:boolean, default false).
  thick_bot : Bool
  /// @ph (xsd:boolean, default false).
  ph : Bool
} derive(Eq, Debug)

///|
pub fn CT_Row::new(element : @xml.Element) -> CT_Row {
  let cells : Array[CT_Cell] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "c" => cells.push(CT_Cell::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let r = attr_uint_opt(element, "r")
  let spans = attr(element, "spans")
  let s = attr_uint(element, "s", 0)
  let custom_format = attr_bool(element, "customFormat", false)
  let ht = attr_double_opt(element, "ht")
  let hidden = attr_bool(element, "hidden", false)
  let custom_height = attr_bool(element, "customHeight", false)
  let outline_level = attr_uint(element, "outlineLevel", 0)
  let collapsed = attr_bool(element, "collapsed", false)
  let thick_top = attr_bool(element, "thickTop", false)
  let thick_bot = attr_bool(element, "thickBot", false)
  let ph = attr_bool(element, "ph", false)
  {
    element,
    cells,
    ext_lst,
    r,
    spans,
    s,
    custom_format,
    ht,
    hidden,
    custom_height,
    outline_level,
    collapsed,
    thick_top,
    thick_bot,
    ph,
  }
}

///|
/// XSD complex type CT_Cell — Part 1 §18.3.1.4. Worksheet cell record.
/// Children: optional `<f>` (CT_CellFormula), `<v>` (s:ST_Xstring value text),
/// `<is>` (CT_Rst inline string), `<extLst>` (CT_ExtensionList). Attributes:
/// optional `@r` (ST_CellRef), `@s` (style index, default 0), `@t`
/// (ST_CellType token, default `n`), `@cm` (cell metadata, default 0), `@vm`
/// (value metadata, default 0), `@ph` (phonetic, default false).
pub(all) struct CT_Cell {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <f> (CT_CellFormula) — optional formula child.
  f : CT_CellFormula?
  /// <v> (s:ST_Xstring) — optional value text.
  v : String?
  /// <is> (CT_Rst) — optional inline rich-string content.
  is_ : CT_Rst?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @r (ST_CellRef) — optional A1 cell reference.
  r : String?
  /// @s (xsd:unsignedInt, default 0) — cell style index.
  s : Int
  /// @t (ST_CellType, default "n") — cell type token.
  t : String
  /// @cm (xsd:unsignedInt, default 0) — cell metadata index.
  cm : Int
  /// @vm (xsd:unsignedInt, default 0) — value metadata index.
  vm : Int
  /// @ph (xsd:boolean, default false) — phonetic flag.
  ph : Bool
} derive(Eq, Debug)

///|
pub fn CT_Cell::new(element : @xml.Element) -> CT_Cell {
  let mut f : CT_CellFormula? = None
  let mut v : String? = None
  let mut is_ : CT_Rst? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "f" => f = Some(CT_CellFormula::new(child_element))
        "v" => v = Some(element_text(child_element))
        "is" => is_ = Some(CT_Rst::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let r = attr(element, "r")
  let s = attr_uint(element, "s", 0)
  let t = match attr(element, "t") {
    Some(value) => value
    None => "n"
  }
  let cm = attr_uint(element, "cm", 0)
  let vm = attr_uint(element, "vm", 0)
  let ph = attr_bool(element, "ph", false)
  { element, f, v, is_, ext_lst, r, s, t, cm, vm, ph }
}

///|
/// XSD complex type CT_SheetPr — Part 1 §18.3.1.82. Worksheet-level
/// properties. Children: optional `<tabColor>` (CT_Color), `<outlinePr>`
/// (CT_OutlinePr), `<pageSetUpPr>` (CT_PageSetUpPr). Attributes:
/// `@syncHorizontal`, `@syncVertical` (booleans, default false), optional
/// `@syncRef` (ST_Ref), `@transitionEvaluation`, `@transitionEntry`
/// (booleans, default false), `@published` (default true), optional
/// `@codeName` (xsd:string), `@filterMode` (default false),
/// `@enableFormatConditionsCalculation` (default true).
pub(all) struct CT_SheetPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <tabColor> (CT_Color element) — optional. Stored as the raw XML
  /// element because the domain's typed CT_Color is an ARGB tuple
  /// (per §18.3.1.15) constructed via CT_Color::new(a, r, g, b) rather
  /// than from XML; this field preserves the worksheet-level
  /// `<tabColor>` reference until colour resolution converts it.
  tab_color : @xml.Element?
  /// <outlinePr> (CT_OutlinePr) — optional.
  outline_pr : CT_OutlinePr?
  /// <pageSetUpPr> (CT_PageSetUpPr) — optional.
  page_set_up_pr : CT_PageSetUpPr?
  /// @syncHorizontal (xsd:boolean, default false).
  sync_horizontal : Bool
  /// @syncVertical (xsd:boolean, default false).
  sync_vertical : Bool
  /// @syncRef (ST_Ref) — optional.
  sync_ref : String?
  /// @transitionEvaluation (xsd:boolean, default false).
  transition_evaluation : Bool
  /// @transitionEntry (xsd:boolean, default false).
  transition_entry : Bool
  /// @published (xsd:boolean, default true).
  published : Bool
  /// @codeName (xsd:string) — optional VBA code name.
  code_name : String?
  /// @filterMode (xsd:boolean, default false).
  filter_mode : Bool
  /// @enableFormatConditionsCalculation (xsd:boolean, default true).
  enable_format_conditions_calculation : Bool
} derive(Eq, Debug)

///|
pub fn CT_SheetPr::new(element : @xml.Element) -> CT_SheetPr {
  let mut tab_color : @xml.Element? = None
  let mut outline_pr : CT_OutlinePr? = None
  let mut page_set_up_pr : CT_PageSetUpPr? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "tabColor" => tab_color = Some(child_element)
        "outlinePr" => outline_pr = Some(CT_OutlinePr::new(child_element))
        "pageSetUpPr" =>
          page_set_up_pr = Some(CT_PageSetUpPr::new(child_element))
        _ => ()
      }
    }
  }
  let sync_horizontal = attr_bool(element, "syncHorizontal", false)
  let sync_vertical = attr_bool(element, "syncVertical", false)
  let sync_ref = attr(element, "syncRef")
  let transition_evaluation = attr_bool(element, "transitionEvaluation", false)
  let transition_entry = attr_bool(element, "transitionEntry", false)
  let published = attr_bool(element, "published", true)
  let code_name = attr(element, "codeName")
  let filter_mode = attr_bool(element, "filterMode", false)
  let enable_format_conditions_calculation = attr_bool(
    element, "enableFormatConditionsCalculation", true,
  )
  {
    element,
    tab_color,
    outline_pr,
    page_set_up_pr,
    sync_horizontal,
    sync_vertical,
    sync_ref,
    transition_evaluation,
    transition_entry,
    published,
    code_name,
    filter_mode,
    enable_format_conditions_calculation,
  }
}

///|
/// XSD complex type CT_SheetDimension — Part 1 §18.3.1.35. Worksheet used
/// range. Required `@ref` (ST_Ref) — A1 range covering the cell payload.
pub(all) struct CT_SheetDimension {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ref (ST_Ref) — required used range.
  ref_ : String
} derive(Eq, Debug)

///|
pub fn CT_SheetDimension::new(element : @xml.Element) -> CT_SheetDimension {
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  { element, ref_ }
}

///|
/// XSD complex type CT_SheetViews — Part 1 §18.3.1.88. Container for one or
/// more `<sheetView>` (CT_SheetView) records, plus an optional `<extLst>`
/// (CT_ExtensionList).
pub(all) struct CT_SheetViews {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sheetView>+ (CT_SheetView) — one or more.
  sheet_views : Array[CT_SheetView]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SheetViews::new(element : @xml.Element) -> CT_SheetViews {
  let sheet_views : Array[CT_SheetView] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sheetView" => sheet_views.push(CT_SheetView::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, sheet_views, ext_lst }
}

///|
/// XSD complex type CT_SheetView — Part 1 §18.3.1.87. Worksheet view
/// record. Children: optional `<pane>` (CT_Pane), zero to four `<selection>`
/// (CT_Selection), zero to four `<pivotSelection>` (CT_PivotSelection),
/// optional `<extLst>` (CT_ExtensionList). Attributes: many boolean
/// view flags plus `@view` (ST_SheetViewType token, default "normal"),
/// optional `@topLeftCell` (ST_CellRef), several xsd:unsignedInt zoom and
/// color identifiers, and required `@workbookViewId`.
pub(all) struct CT_SheetView {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pane> (CT_Pane) — optional split/freeze pane.
  pane : CT_Pane?
  /// <selection>{0..4} (CT_Selection) — per-pane selections.
  selections : Array[CT_Selection]
  /// <pivotSelection>{0..4} (CT_PivotSelection) — per-pane pivot selections.
  pivot_selections : Array[CT_PivotSelection]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
  /// @windowProtection (xsd:boolean, default false).
  window_protection : Bool
  /// @showFormulas (xsd:boolean, default false).
  show_formulas : Bool
  /// @showGridLines (xsd:boolean, default true).
  show_grid_lines : Bool
  /// @showRowColHeaders (xsd:boolean, default true).
  show_row_col_headers : Bool
  /// @showZeros (xsd:boolean, default true).
  show_zeros : Bool
  /// @rightToLeft (xsd:boolean, default false).
  right_to_left : Bool
  /// @tabSelected (xsd:boolean, default false).
  tab_selected : Bool
  /// @showRuler (xsd:boolean, default true).
  show_ruler : Bool
  /// @showOutlineSymbols (xsd:boolean, default true).
  show_outline_symbols : Bool
  /// @defaultGridColor (xsd:boolean, default true).
  default_grid_color : Bool
  /// @showWhiteSpace (xsd:boolean, default true).
  show_white_space : Bool
  /// @view (ST_SheetViewType, default "normal").
  view : String
  /// @topLeftCell (ST_CellRef) — optional.
  top_left_cell : String?
  /// @colorId (xsd:unsignedInt, default 64).
  color_id : Int
  /// @zoomScale (xsd:unsignedInt, default 100).
  zoom_scale : Int
  /// @zoomScaleNormal (xsd:unsignedInt, default 0).
  zoom_scale_normal : Int
  /// @zoomScaleSheetLayoutView (xsd:unsignedInt, default 0).
  zoom_scale_sheet_layout_view : Int
  /// @zoomScalePageLayoutView (xsd:unsignedInt, default 0).
  zoom_scale_page_layout_view : Int
  /// @workbookViewId (xsd:unsignedInt) — required.
  workbook_view_id : Int
} derive(Eq, Debug)

///|
pub fn CT_SheetView::new(element : @xml.Element) -> CT_SheetView {
  let mut pane : CT_Pane? = None
  let selections : Array[CT_Selection] = []
  let pivot_selections : Array[CT_PivotSelection] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "pane" => pane = Some(CT_Pane::new(child_element))
        "selection" => selections.push(CT_Selection::new(child_element))
        "pivotSelection" =>
          pivot_selections.push(CT_PivotSelection::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let window_protection = attr_bool(element, "windowProtection", false)
  let show_formulas = attr_bool(element, "showFormulas", false)
  let show_grid_lines = attr_bool(element, "showGridLines", true)
  let show_row_col_headers = attr_bool(element, "showRowColHeaders", true)
  let show_zeros = attr_bool(element, "showZeros", true)
  let right_to_left = attr_bool(element, "rightToLeft", false)
  let tab_selected = attr_bool(element, "tabSelected", false)
  let show_ruler = attr_bool(element, "showRuler", true)
  let show_outline_symbols = attr_bool(element, "showOutlineSymbols", true)
  let default_grid_color = attr_bool(element, "defaultGridColor", true)
  let show_white_space = attr_bool(element, "showWhiteSpace", true)
  let view = match attr(element, "view") {
    Some(value) => value
    None => "normal"
  }
  let top_left_cell = attr(element, "topLeftCell")
  let color_id = attr_uint(element, "colorId", 64)
  let zoom_scale = attr_uint(element, "zoomScale", 100)
  let zoom_scale_normal = attr_uint(element, "zoomScaleNormal", 0)
  let zoom_scale_sheet_layout_view = attr_uint(
    element, "zoomScaleSheetLayoutView", 0,
  )
  let zoom_scale_page_layout_view = attr_uint(
    element, "zoomScalePageLayoutView", 0,
  )
  let workbook_view_id = attr_uint(element, "workbookViewId", 0)
  {
    element,
    pane,
    selections,
    pivot_selections,
    ext_lst,
    window_protection,
    show_formulas,
    show_grid_lines,
    show_row_col_headers,
    show_zeros,
    right_to_left,
    tab_selected,
    show_ruler,
    show_outline_symbols,
    default_grid_color,
    show_white_space,
    view,
    top_left_cell,
    color_id,
    zoom_scale,
    zoom_scale_normal,
    zoom_scale_sheet_layout_view,
    zoom_scale_page_layout_view,
    workbook_view_id,
  }
}

///|
/// XSD complex type CT_Pane — Part 1 §18.3.1.66. Worksheet split/freeze pane.
/// Attributes: optional `@xSplit`, `@ySplit` (xsd:double, defaults 0),
/// optional `@topLeftCell` (ST_CellRef), `@activePane` (ST_Pane, default
/// "topLeft"), `@state` (ST_PaneState, default "split").
pub(all) struct CT_Pane {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @xSplit (xsd:double, default 0).
  x_split : Double
  /// @ySplit (xsd:double, default 0).
  y_split : Double
  /// @topLeftCell (ST_CellRef) — optional.
  top_left_cell : String?
  /// @activePane (ST_Pane, default "topLeft").
  active_pane : String
  /// @state (ST_PaneState, default "split").
  state : String
} derive(Eq, Debug)

///|
pub fn CT_Pane::new(element : @xml.Element) -> CT_Pane {
  let x_split = attr_double(element, "xSplit", 0.0)
  let y_split = attr_double(element, "ySplit", 0.0)
  let top_left_cell = attr(element, "topLeftCell")
  let active_pane = match attr(element, "activePane") {
    Some(value) => value
    None => "topLeft"
  }
  let state = match attr(element, "state") {
    Some(value) => value
    None => "split"
  }
  { element, x_split, y_split, top_left_cell, active_pane, state }
}

///|
/// XSD complex type CT_Selection — Part 1 §18.3.1.78. Per-pane selection
/// state. Attributes: optional `@pane` (ST_Pane, default "topLeft"),
/// `@activeCell` (ST_CellRef), `@activeCellId` (xsd:unsignedInt, default 0),
/// `@sqref` (ST_Sqref, default "A1").
pub(all) struct CT_Selection {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @pane (ST_Pane, default "topLeft").
  pane : String
  /// @activeCell (ST_CellRef) — optional.
  active_cell : String?
  /// @activeCellId (xsd:unsignedInt, default 0).
  active_cell_id : Int
  /// @sqref (ST_Sqref, default "A1").
  sqref : String
} derive(Eq, Debug)

///|
pub fn CT_Selection::new(element : @xml.Element) -> CT_Selection {
  let pane = match attr(element, "pane") {
    Some(value) => value
    None => "topLeft"
  }
  let active_cell = attr(element, "activeCell")
  let active_cell_id = attr_uint(element, "activeCellId", 0)
  let sqref = match attr(element, "sqref") {
    Some(value) => value
    None => "A1"
  }
  { element, pane, active_cell, active_cell_id, sqref }
}

///|
/// XSD complex type CT_PageBreak — Part 1 §18.3.1.64. Row or column manual
/// page-break container. Children: zero or more `<brk>` (CT_Break) entries.
/// Attributes: optional `@count`, `@manualBreakCount` (xsd:unsignedInt,
/// defaults 0).
pub(all) struct CT_PageBreak {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <brk>* (CT_Break) — zero or more break records.
  brks : Array[CT_Break]
  /// @count (xsd:unsignedInt, default 0).
  count : Int
  /// @manualBreakCount (xsd:unsignedInt, default 0).
  manual_break_count : Int
} derive(Eq, Debug)

///|
pub fn CT_PageBreak::new(element : @xml.Element) -> CT_PageBreak {
  let brks : Array[CT_Break] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "brk" {
        brks.push(CT_Break::new(child_element))
      }
    }
  }
  let count = attr_uint(element, "count", 0)
  let manual_break_count = attr_uint(element, "manualBreakCount", 0)
  { element, brks, count, manual_break_count }
}

///|
/// XSD complex type CT_Break — Part 1 §18.3.1.1. Single row/column manual
/// page break entry. Attributes: optional `@id`, `@min`, `@max`
/// (xsd:unsignedInt, defaults 0), `@man`, `@pt` (xsd:boolean, default false).
pub(all) struct CT_Break {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt, default 0).
  id : Int
  /// @min (xsd:unsignedInt, default 0).
  min : Int
  /// @max (xsd:unsignedInt, default 0).
  max : Int
  /// @man (xsd:boolean, default false).
  man : Bool
  /// @pt (xsd:boolean, default false).
  pt : Bool
} derive(Eq, Debug)

///|
pub fn CT_Break::new(element : @xml.Element) -> CT_Break {
  let id = attr_uint(element, "id", 0)
  let min = attr_uint(element, "min", 0)
  let max = attr_uint(element, "max", 0)
  let man = attr_bool(element, "man", false)
  let pt = attr_bool(element, "pt", false)
  { element, id, min, max, man, pt }
}

///|
/// XSD complex type CT_DataConsolidate — Part 1 §18.2.3. Data consolidation
/// specification. Child: optional `<dataRefs>` (CT_DataRefs). Attributes:
/// optional `@function` (ST_DataConsolidateFunction, default "sum"),
/// `@startLabels`, `@topLabels`, `@link` (xsd:boolean, default false).
pub(all) struct CT_DataConsolidate {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <dataRefs> (CT_DataRefs) — optional source-range list.
  data_refs : CT_DataRefs?
  /// @function (ST_DataConsolidateFunction, default "sum").
  function : String
  /// @startLabels (xsd:boolean, default false).
  start_labels : Bool
  /// @topLabels (xsd:boolean, default false).
  top_labels : Bool
  /// @link (xsd:boolean, default false).
  link : Bool
} derive(Eq, Debug)

///|
pub fn CT_DataConsolidate::new(element : @xml.Element) -> CT_DataConsolidate {
  let mut data_refs : CT_DataRefs? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "dataRefs" {
        data_refs = Some(CT_DataRefs::new(child_element))
      }
    }
  }
  let function = match attr(element, "function") {
    Some(value) => value
    None => "sum"
  }
  let start_labels = attr_bool(element, "startLabels", false)
  let top_labels = attr_bool(element, "topLabels", false)
  let link = attr_bool(element, "link", false)
  { element, data_refs, function, start_labels, top_labels, link }
}

///|
/// XSD complex type CT_DataRefs — Part 1 §18.2.4. Container for zero or more
/// `<dataRef>` (CT_DataRef) consolidation sources. Optional `@count`
/// (xsd:unsignedInt).
pub(all) struct CT_DataRefs {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <dataRef>* (CT_DataRef) — zero or more source ranges.
  data_refs : Array[CT_DataRef]
  /// @count (xsd:unsignedInt) — optional cache count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_DataRefs::new(element : @xml.Element) -> CT_DataRefs {
  let data_refs : Array[CT_DataRef] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "dataRef" {
        data_refs.push(CT_DataRef::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, data_refs, count }
}

///|
/// XSD complex type CT_DataRef — Part 1 §18.2.5. Single consolidation source.
/// All attributes optional: `@ref` (ST_Ref), `@name` (s:ST_Xstring),
/// `@sheet` (s:ST_Xstring), `@r:id` relationship reference.
pub(all) struct CT_DataRef {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ref (ST_Ref) — optional A1 range.
  ref_ : String?
  /// @name (s:ST_Xstring) — optional source name.
  name : String?
  /// @sheet (s:ST_Xstring) — optional source sheet name.
  sheet : String?
  /// @r:id (relationship reference) — optional.
  r_id : String?
} derive(Eq, Debug)

///|
pub fn CT_DataRef::new(element : @xml.Element) -> CT_DataRef {
  let ref_ = attr(element, "ref")
  let name = attr(element, "name")
  let sheet = attr(element, "sheet")
  let r_id = attr_with_ns(element, "id")
  { element, ref_, name, sheet, r_id }
}

///|
/// XSD complex type CT_MergeCells — Part 1 §18.3.1.55. Container for one or
/// more `<mergeCell>` (CT_MergeCell) entries. Optional `@count`
/// (xsd:unsignedInt).
pub(all) struct CT_MergeCells {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <mergeCell>+ (CT_MergeCell) — one or more merge ranges.
  merge_cells : Array[CT_MergeCell]
  /// @count (xsd:unsignedInt) — optional merge count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_MergeCells::new(element : @xml.Element) -> CT_MergeCells {
  let merge_cells : Array[CT_MergeCell] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "mergeCell" {
        merge_cells.push(CT_MergeCell::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, merge_cells, count }
}

///|
/// XSD complex type CT_MergeCell — Part 1 §18.3.1.54. Single merge range.
/// Required `@ref` (ST_Ref).
pub(all) struct CT_MergeCell {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ref (ST_Ref) — required merge A1 range.
  ref_ : String
} derive(Eq, Debug)

///|
pub fn CT_MergeCell::new(element : @xml.Element) -> CT_MergeCell {
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  { element, ref_ }
}

///|
/// XSD complex type CT_CellSmartTags — Part 1 §18.3.1.8. Smart tag group
/// anchored at a single cell. Required `@r` (ST_CellRef) and one or more
/// `<cellSmartTag>` (CT_CellSmartTag) entries.
pub(all) struct CT_CellSmartTags {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cellSmartTag>+ (CT_CellSmartTag) — one or more smart-tag entries.
  cell_smart_tags : Array[CT_CellSmartTag]
  /// @r (ST_CellRef) — required anchor cell.
  r : String
} derive(Eq, Debug)

///|
pub fn CT_CellSmartTags::new(element : @xml.Element) -> CT_CellSmartTags {
  let cell_smart_tags : Array[CT_CellSmartTag] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "cellSmartTag" {
        cell_smart_tags.push(CT_CellSmartTag::new(child_element))
      }
    }
  }
  let r = match attr(element, "r") {
    Some(value) => value
    None => ""
  }
  { element, cell_smart_tags, r }
}

///|
/// XSD complex type CT_CellSmartTag — Part 1 §18.3.1.7. Single smart-tag
/// entry. Children: zero or more `<cellSmartTagPr>` (CT_CellSmartTagPr).
/// Attributes: required `@type` (xsd:unsignedInt), optional `@deleted`,
/// `@xmlBased` (xsd:boolean, default false).
pub(all) struct CT_CellSmartTag {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cellSmartTagPr>* (CT_CellSmartTagPr) — zero or more key/value props.
  cell_smart_tag_prs : Array[CT_CellSmartTagPr]
  /// @type (xsd:unsignedInt) — required smart-tag identifier.
  type_ : Int
  /// @deleted (xsd:boolean, default false).
  deleted : Bool
  /// @xmlBased (xsd:boolean, default false).
  xml_based : Bool
} derive(Eq, Debug)

///|
pub fn CT_CellSmartTag::new(element : @xml.Element) -> CT_CellSmartTag {
  let cell_smart_tag_prs : Array[CT_CellSmartTagPr] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "cellSmartTagPr" {
        cell_smart_tag_prs.push(CT_CellSmartTagPr::new(child_element))
      }
    }
  }
  let type_ = attr_uint(element, "type", 0)
  let deleted = attr_bool(element, "deleted", false)
  let xml_based = attr_bool(element, "xmlBased", false)
  { element, cell_smart_tag_prs, type_, deleted, xml_based }
}

///|
/// XSD complex type CT_CellSmartTagPr — Part 1 §18.3.1.6. Smart-tag
/// property pair. Required `@key`, `@val` (s:ST_Xstring).
pub(all) struct CT_CellSmartTagPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @key (s:ST_Xstring) — required property key.
  key : String
  /// @val (s:ST_Xstring) — required property value.
  val : String
} derive(Eq, Debug)

///|
pub fn CT_CellSmartTagPr::new(element : @xml.Element) -> CT_CellSmartTagPr {
  let key = match attr(element, "key") {
    Some(value) => value
    None => ""
  }
  let val = match attr(element, "val") {
    Some(value) => value
    None => ""
  }
  { element, key, val }
}

///|
/// XSD complex type CT_Drawing — Part 1 §18.3.1.36. Sheet drawing-part
/// reference. Required `@r:id` (relationship to the DrawingML part).
pub(all) struct CT_Drawing {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id — required relationship identifier.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_Drawing::new(element : @xml.Element) -> CT_Drawing {
  let r_id = match attr_with_ns(element, "id") {
    Some(value) => value
    None => ""
  }
  { element, r_id }
}

///|
/// XSD complex type CT_DrawingHF — Part 1 §18.3.1.37. Header/footer drawing
/// reference. Required `@r:id`; eighteen optional `xsd:unsignedInt`
/// positional attributes (`@lho`, `@lhe`, `@lhf`, `@cho`, `@che`, `@chf`,
/// `@rho`, `@rhe`, `@rhf`, `@lfo`, `@lfe`, `@lff`, `@cfo`, `@cfe`, `@cff`,
/// `@rfo`, `@rfe`, `@rff`) addressing left/center/right header/footer slots
/// across odd/even/first pages.
pub(all) struct CT_DrawingHF {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id — required relationship identifier.
  r_id : String
  /// @lho (xsd:unsignedInt) — optional left-header odd index.
  lho : Int?
  /// @lhe (xsd:unsignedInt) — optional left-header even index.
  lhe : Int?
  /// @lhf (xsd:unsignedInt) — optional left-header first index.
  lhf : Int?
  /// @cho (xsd:unsignedInt) — optional center-header odd index.
  cho : Int?
  /// @che (xsd:unsignedInt) — optional center-header even index.
  che : Int?
  /// @chf (xsd:unsignedInt) — optional center-header first index.
  chf : Int?
  /// @rho (xsd:unsignedInt) — optional right-header odd index.
  rho : Int?
  /// @rhe (xsd:unsignedInt) — optional right-header even index.
  rhe : Int?
  /// @rhf (xsd:unsignedInt) — optional right-header first index.
  rhf : Int?
  /// @lfo (xsd:unsignedInt) — optional left-footer odd index.
  lfo : Int?
  /// @lfe (xsd:unsignedInt) — optional left-footer even index.
  lfe : Int?
  /// @lff (xsd:unsignedInt) — optional left-footer first index.
  lff : Int?
  /// @cfo (xsd:unsignedInt) — optional center-footer odd index.
  cfo : Int?
  /// @cfe (xsd:unsignedInt) — optional center-footer even index.
  cfe : Int?
  /// @cff (xsd:unsignedInt) — optional center-footer first index.
  cff : Int?
  /// @rfo (xsd:unsignedInt) — optional right-footer odd index.
  rfo : Int?
  /// @rfe (xsd:unsignedInt) — optional right-footer even index.
  rfe : Int?
  /// @rff (xsd:unsignedInt) — optional right-footer first index.
  rff : Int?
} derive(Eq, Debug)

///|
pub fn CT_DrawingHF::new(element : @xml.Element) -> CT_DrawingHF {
  let r_id = match attr_with_ns(element, "id") {
    Some(value) => value
    None => ""
  }
  let lho = attr_uint_opt(element, "lho")
  let lhe = attr_uint_opt(element, "lhe")
  let lhf = attr_uint_opt(element, "lhf")
  let cho = attr_uint_opt(element, "cho")
  let che = attr_uint_opt(element, "che")
  let chf = attr_uint_opt(element, "chf")
  let rho = attr_uint_opt(element, "rho")
  let rhe = attr_uint_opt(element, "rhe")
  let rhf = attr_uint_opt(element, "rhf")
  let lfo = attr_uint_opt(element, "lfo")
  let lfe = attr_uint_opt(element, "lfe")
  let lff = attr_uint_opt(element, "lff")
  let cfo = attr_uint_opt(element, "cfo")
  let cfe = attr_uint_opt(element, "cfe")
  let cff = attr_uint_opt(element, "cff")
  let rfo = attr_uint_opt(element, "rfo")
  let rfe = attr_uint_opt(element, "rfe")
  let rff = attr_uint_opt(element, "rff")
  {
    element,
    r_id,
    lho,
    lhe,
    lhf,
    cho,
    che,
    chf,
    rho,
    rhe,
    rhf,
    lfo,
    lfe,
    lff,
    cfo,
    cfe,
    cff,
    rfo,
    rfe,
    rff,
  }
}

///|
/// XSD complex type CT_CustomSheetViews — Part 1 §18.3.1.27. Container for
/// one or more `<customSheetView>` (CT_CustomSheetView) entries.
pub(all) struct CT_CustomSheetViews {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <customSheetView>+ (CT_CustomSheetView) — one or more entries.
  custom_sheet_views : Array[CT_CustomSheetView]
} derive(Eq, Debug)

///|
pub fn CT_CustomSheetViews::new(element : @xml.Element) -> CT_CustomSheetViews {
  let custom_sheet_views : Array[CT_CustomSheetView] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "customSheetView" {
        custom_sheet_views.push(CT_CustomSheetView::new(child_element))
      }
    }
  }
  { element, custom_sheet_views }
}

///|
/// XSD complex type CT_CustomSheetView — Part 1 §18.3.1.26. Per-user
/// captured sheet view. Children (all optional, maxOccurs 1): `<pane>`
/// (CT_Pane), `<selection>` (CT_Selection), `<rowBreaks>`, `<colBreaks>`
/// (CT_PageBreak), `<pageMargins>` (CT_PageMargins), `<printOptions>`
/// (CT_PrintOptions), `<pageSetup>` (CT_PageSetup), `<headerFooter>`
/// (CT_HeaderFooter), `<autoFilter>` (CT_AutoFilter), `<extLst>`
/// (CT_ExtensionList). Attributes: required `@guid` (s:ST_Guid); optional
/// `@scale`, `@colorId` (xsd:unsignedInt, defaults 100/64); ten boolean
/// view flags (defaults indicated in XSD); `@state` (ST_SheetState, default
/// "visible"); `@filterUnique` (default false); `@view` (ST_SheetViewType,
/// default "normal"); `@showRuler` (default true); `@topLeftCell` (optional
/// ST_CellRef).
pub(all) struct CT_CustomSheetView {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pane> (CT_Pane) — optional.
  pane : CT_Pane?
  /// <selection> (CT_Selection) — optional.
  selection : CT_Selection?
  /// <rowBreaks> (CT_PageBreak) — optional row break list.
  row_breaks : CT_PageBreak?
  /// <colBreaks> (CT_PageBreak) — optional column break list.
  col_breaks : CT_PageBreak?
  /// <pageMargins> (CT_PageMargins) — optional.
  page_margins : CT_PageMargins?
  /// <printOptions> (CT_PrintOptions) — optional.
  print_options : CT_PrintOptions?
  /// <pageSetup> (CT_PageSetup) — optional.
  page_setup : CT_PageSetup?
  /// <headerFooter> (CT_HeaderFooter) — optional.
  header_footer : CT_HeaderFooter?
  /// <autoFilter> (CT_AutoFilter element) — optional. Stored as the raw
  /// XML element because CT_AutoFilter (§18.3.1.2) is a typed record built
  /// from autofilter evaluation rather than from this XSD child; this
  /// field preserves the embedded `<autoFilter>` for round-trip.
  auto_filter : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
  /// @guid (s:ST_Guid) — required view identifier.
  guid : String
  /// @scale (xsd:unsignedInt, default 100).
  scale : Int
  /// @colorId (xsd:unsignedInt, default 64).
  color_id : Int
  /// @showPageBreaks (xsd:boolean, default false).
  show_page_breaks : Bool
  /// @showFormulas (xsd:boolean, default false).
  show_formulas : Bool
  /// @showGridLines (xsd:boolean, default true).
  show_grid_lines : Bool
  /// @showRowCol (xsd:boolean, default true).
  show_row_col : Bool
  /// @outlineSymbols (xsd:boolean, default true).
  outline_symbols : Bool
  /// @zeroValues (xsd:boolean, default true).
  zero_values : Bool
  /// @fitToPage (xsd:boolean, default false).
  fit_to_page : Bool
  /// @printArea (xsd:boolean, default false).
  print_area : Bool
  /// @filter (xsd:boolean, default false).
  filter : Bool
  /// @showAutoFilter (xsd:boolean, default false).
  show_auto_filter : Bool
  /// @hiddenRows (xsd:boolean, default false).
  hidden_rows : Bool
  /// @hiddenColumns (xsd:boolean, default false).
  hidden_columns : Bool
  /// @state (ST_SheetState, default "visible").
  state : String
  /// @filterUnique (xsd:boolean, default false).
  filter_unique : Bool
  /// @view (ST_SheetViewType, default "normal").
  view : String
  /// @showRuler (xsd:boolean, default true).
  show_ruler : Bool
  /// @topLeftCell (ST_CellRef) — optional.
  top_left_cell : String?
} derive(Eq, Debug)

///|
pub fn CT_CustomSheetView::new(element : @xml.Element) -> CT_CustomSheetView {
  let mut pane : CT_Pane? = None
  let mut selection : CT_Selection? = None
  let mut row_breaks : CT_PageBreak? = None
  let mut col_breaks : CT_PageBreak? = None
  let mut page_margins : CT_PageMargins? = None
  let mut print_options : CT_PrintOptions? = None
  let mut page_setup : CT_PageSetup? = None
  let mut header_footer : CT_HeaderFooter? = None
  let mut auto_filter : @xml.Element? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "pane" => pane = Some(CT_Pane::new(child_element))
        "selection" => selection = Some(CT_Selection::new(child_element))
        "rowBreaks" => row_breaks = Some(CT_PageBreak::new(child_element))
        "colBreaks" => col_breaks = Some(CT_PageBreak::new(child_element))
        "pageMargins" => page_margins = Some(CT_PageMargins::new(child_element))
        "printOptions" =>
          print_options = Some(CT_PrintOptions::new(child_element))
        "pageSetup" => page_setup = Some(CT_PageSetup::new(child_element))
        "headerFooter" =>
          header_footer = Some(CT_HeaderFooter::new(child_element))
        "autoFilter" => auto_filter = Some(child_element)
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let guid = match attr(element, "guid") {
    Some(value) => value
    None => ""
  }
  let scale = attr_uint(element, "scale", 100)
  let color_id = attr_uint(element, "colorId", 64)
  let show_page_breaks = attr_bool(element, "showPageBreaks", false)
  let show_formulas = attr_bool(element, "showFormulas", false)
  let show_grid_lines = attr_bool(element, "showGridLines", true)
  let show_row_col = attr_bool(element, "showRowCol", true)
  let outline_symbols = attr_bool(element, "outlineSymbols", true)
  let zero_values = attr_bool(element, "zeroValues", true)
  let fit_to_page = attr_bool(element, "fitToPage", false)
  let print_area = attr_bool(element, "printArea", false)
  let filter = attr_bool(element, "filter", false)
  let show_auto_filter = attr_bool(element, "showAutoFilter", false)
  let hidden_rows = attr_bool(element, "hiddenRows", false)
  let hidden_columns = attr_bool(element, "hiddenColumns", false)
  let state = match attr(element, "state") {
    Some(value) => value
    None => "visible"
  }
  let filter_unique = attr_bool(element, "filterUnique", false)
  let view = match attr(element, "view") {
    Some(value) => value
    None => "normal"
  }
  let show_ruler = attr_bool(element, "showRuler", true)
  let top_left_cell = attr(element, "topLeftCell")
  {
    element,
    pane,
    selection,
    row_breaks,
    col_breaks,
    page_margins,
    print_options,
    page_setup,
    header_footer,
    auto_filter,
    ext_lst,
    guid,
    scale,
    color_id,
    show_page_breaks,
    show_formulas,
    show_grid_lines,
    show_row_col,
    outline_symbols,
    zero_values,
    fit_to_page,
    print_area,
    filter,
    show_auto_filter,
    hidden_rows,
    hidden_columns,
    state,
    filter_unique,
    view,
    show_ruler,
    top_left_cell,
  }
}

///|
/// XSD complex type CT_DataValidations — Part 1 §18.3.1.33. Container for
/// one or more `<dataValidation>` (CT_DataValidation) entries. Attributes:
/// optional `@disablePrompts` (xsd:boolean, default false), `@xWindow`,
/// `@yWindow`, `@count` (xsd:unsignedInt).
pub(all) struct CT_DataValidations {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <dataValidation>+ (CT_DataValidation) — one or more entries.
  data_validations : Array[CT_DataValidation]
  /// @disablePrompts (xsd:boolean, default false).
  disable_prompts : Bool
  /// @xWindow (xsd:unsignedInt) — optional.
  x_window : Int?
  /// @yWindow (xsd:unsignedInt) — optional.
  y_window : Int?
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_DataValidations::new(element : @xml.Element) -> CT_DataValidations {
  let data_validations : Array[CT_DataValidation] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "dataValidation" {
        data_validations.push(CT_DataValidation::new(child_element))
      }
    }
  }
  let disable_prompts = attr_bool(element, "disablePrompts", false)
  let x_window = attr_uint_opt(element, "xWindow")
  let y_window = attr_uint_opt(element, "yWindow")
  let count = attr_uint_opt(element, "count")
  { element, data_validations, disable_prompts, x_window, y_window, count }
}

///|
/// XSD complex type CT_DataValidation — Part 1 §18.3.1.32. Single data
/// validation rule. Children: optional `<formula1>`, `<formula2>` (ST_Formula
/// text). Attributes: `@type` (ST_DataValidationType, default "none"),
/// `@errorStyle` (default "stop"), `@imeMode` (default "noControl"),
/// `@operator` (default "between"), six boolean flags, optional Xstring
/// strings (`errorTitle`, `error`, `promptTitle`, `prompt`), required
/// `@sqref` (ST_Sqref).
pub(all) struct CT_DataValidation {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <formula1> (ST_Formula text) — optional first bound formula.
  formula1 : String?
  /// <formula2> (ST_Formula text) — optional second bound formula.
  formula2 : String?
  /// @type (ST_DataValidationType, default "none").
  type_ : String
  /// @errorStyle (ST_DataValidationErrorStyle, default "stop").
  error_style : String
  /// @imeMode (ST_DataValidationImeMode, default "noControl").
  ime_mode : String
  /// @operator (ST_DataValidationOperator, default "between").
  operator : String
  /// @allowBlank (xsd:boolean, default false).
  allow_blank : Bool
  /// @showDropDown (xsd:boolean, default false).
  show_drop_down : Bool
  /// @showInputMessage (xsd:boolean, default false).
  show_input_message : Bool
  /// @showErrorMessage (xsd:boolean, default false).
  show_error_message : Bool
  /// @errorTitle (s:ST_Xstring) — optional.
  error_title : String?
  /// @error (s:ST_Xstring) — optional.
  error : String?
  /// @promptTitle (s:ST_Xstring) — optional.
  prompt_title : String?
  /// @prompt (s:ST_Xstring) — optional.
  prompt : String?
  /// @sqref (ST_Sqref) — required target range list.
  sqref : String
} derive(Eq, Debug)

///|
pub fn CT_DataValidation::new(element : @xml.Element) -> CT_DataValidation {
  let mut formula1 : String? = None
  let mut formula2 : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "formula1" => formula1 = Some(element_text(child_element))
        "formula2" => formula2 = Some(element_text(child_element))
        _ => ()
      }
    }
  }
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => "none"
  }
  let error_style = match attr(element, "errorStyle") {
    Some(value) => value
    None => "stop"
  }
  let ime_mode = match attr(element, "imeMode") {
    Some(value) => value
    None => "noControl"
  }
  let operator = match attr(element, "operator") {
    Some(value) => value
    None => "between"
  }
  let allow_blank = attr_bool(element, "allowBlank", false)
  let show_drop_down = attr_bool(element, "showDropDown", false)
  let show_input_message = attr_bool(element, "showInputMessage", false)
  let show_error_message = attr_bool(element, "showErrorMessage", false)
  let error_title = attr(element, "errorTitle")
  let error = attr(element, "error")
  let prompt_title = attr(element, "promptTitle")
  let prompt = attr(element, "prompt")
  let sqref = match attr(element, "sqref") {
    Some(value) => value
    None => ""
  }
  {
    element,
    formula1,
    formula2,
    type_,
    error_style,
    ime_mode,
    operator,
    allow_blank,
    show_drop_down,
    show_input_message,
    show_error_message,
    error_title,
    error,
    prompt_title,
    prompt,
    sqref,
  }
}

///|
/// XSD complex type CT_Hyperlinks — Part 1 §18.3.1.48. Container for one or
/// more `<hyperlink>` (CT_Hyperlink) entries.
pub(all) struct CT_Hyperlinks {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <hyperlink>+ (CT_Hyperlink) — one or more entries.
  hyperlinks : Array[CT_Hyperlink]
} derive(Eq, Debug)

///|
pub fn CT_Hyperlinks::new(element : @xml.Element) -> CT_Hyperlinks {
  let hyperlinks : Array[CT_Hyperlink] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "hyperlink" {
        hyperlinks.push(CT_Hyperlink::new(child_element))
      }
    }
  }
  { element, hyperlinks }
}

///|
/// XSD complex type CT_Hyperlink — Part 1 §18.3.1.47. Single worksheet
/// hyperlink. Required `@ref` (ST_Ref); optional `@r:id`, `@location`,
/// `@tooltip`, `@display` (s:ST_Xstring).
pub(all) struct CT_Hyperlink {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ref (ST_Ref) — required A1 anchor range.
  ref_ : String
  /// @r:id — optional external relationship target.
  r_id : String?
  /// @location (s:ST_Xstring) — optional internal anchor.
  location : String?
  /// @tooltip (s:ST_Xstring) — optional tooltip text.
  tooltip : String?
  /// @display (s:ST_Xstring) — optional displayed text.
  display : String?
} derive(Eq, Debug)

///|
pub fn CT_Hyperlink::new(element : @xml.Element) -> CT_Hyperlink {
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  let r_id = attr_with_ns(element, "id")
  let location = attr(element, "location")
  let tooltip = attr(element, "tooltip")
  let display = attr(element, "display")
  { element, ref_, r_id, location, tooltip, display }
}

///|
/// XSD complex type CT_CellFormula — Part 1 §18.3.1.40. Cell formula
/// payload. Simple content extends ST_Formula (the textual formula). Twelve
/// optional attributes: `@t` (ST_CellFormulaType, default "normal"), `@aca`
/// (xsd:boolean, default false), `@ref` (ST_Ref), `@dt2D` (default false),
/// `@dtr` (default false), `@del1` / `@del2` (default false), `@r1` / `@r2`
/// (ST_CellRef), `@ca` (default false), `@si` (xsd:unsignedInt — shared
/// formula index), `@bx` (default false).
pub(all) struct CT_CellFormula {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Simple-content value (ST_Formula text).
  formula : String
  /// @t (ST_CellFormulaType, default "normal").
  t : String
  /// @aca (xsd:boolean, default false).
  aca : Bool
  /// @ref (ST_Ref) — optional shared/array range.
  ref_ : String?
  /// @dt2D (xsd:boolean, default false).
  dt2_d : Bool
  /// @dtr (xsd:boolean, default false).
  dtr : Bool
  /// @del1 (xsd:boolean, default false).
  del1 : Bool
  /// @del2 (xsd:boolean, default false).
  del2 : Bool
  /// @r1 (ST_CellRef) — optional.
  r1 : String?
  /// @r2 (ST_CellRef) — optional.
  r2 : String?
  /// @ca (xsd:boolean, default false).
  ca : Bool
  /// @si (xsd:unsignedInt) — optional shared formula index.
  si : Int?
  /// @bx (xsd:boolean, default false).
  bx : Bool
} derive(Eq, Debug)

///|
pub fn CT_CellFormula::new(element : @xml.Element) -> CT_CellFormula {
  let formula = element_text(element)
  let t = match attr(element, "t") {
    Some(value) => value
    None => "normal"
  }
  let aca = attr_bool(element, "aca", false)
  let ref_ = attr(element, "ref")
  let dt2_d = attr_bool(element, "dt2D", false)
  let dtr = attr_bool(element, "dtr", false)
  let del1 = attr_bool(element, "del1", false)
  let del2 = attr_bool(element, "del2", false)
  let r1 = attr(element, "r1")
  let r2 = attr(element, "r2")
  let ca = attr_bool(element, "ca", false)
  let si = attr_uint_opt(element, "si")
  let bx = attr_bool(element, "bx", false)
  { element, formula, t, aca, ref_, dt2_d, dtr, del1, del2, r1, r2, ca, si, bx }
}

///|
/// XSD complex type CT_PageMargins — Part 1 §18.3.1.62. Page margin block.
/// Six required xsd:double attributes — `@left`, `@right`, `@top`,
/// `@bottom`, `@header`, `@footer` (inches).
pub(all) struct CT_PageMargins {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @left (xsd:double) — required.
  left : Double
  /// @right (xsd:double) — required.
  right : Double
  /// @top (xsd:double) — required.
  top : Double
  /// @bottom (xsd:double) — required.
  bottom : Double
  /// @header (xsd:double) — required.
  header : Double
  /// @footer (xsd:double) — required.
  footer : Double
} derive(Eq, Debug)

///|
pub fn CT_PageMargins::new(element : @xml.Element) -> CT_PageMargins {
  let left = attr_double(element, "left", 0.0)
  let right = attr_double(element, "right", 0.0)
  let top = attr_double(element, "top", 0.0)
  let bottom = attr_double(element, "bottom", 0.0)
  let header = attr_double(element, "header", 0.0)
  let footer = attr_double(element, "footer", 0.0)
  { element, left, right, top, bottom, header, footer }
}

///|
/// XSD complex type CT_PrintOptions — Part 1 §18.3.1.70. Worksheet print
/// options. All attributes xsd:boolean: optional `@horizontalCentered`,
/// `@verticalCentered`, `@headings`, `@gridLines` (defaults false);
/// `@gridLinesSet` (default true).
pub(all) struct CT_PrintOptions {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @horizontalCentered (xsd:boolean, default false).
  horizontal_centered : Bool
  /// @verticalCentered (xsd:boolean, default false).
  vertical_centered : Bool
  /// @headings (xsd:boolean, default false).
  headings : Bool
  /// @gridLines (xsd:boolean, default false).
  grid_lines : Bool
  /// @gridLinesSet (xsd:boolean, default true).
  grid_lines_set : Bool
} derive(Eq, Debug)

///|
pub fn CT_PrintOptions::new(element : @xml.Element) -> CT_PrintOptions {
  let horizontal_centered = attr_bool(element, "horizontalCentered", false)
  let vertical_centered = attr_bool(element, "verticalCentered", false)
  let headings = attr_bool(element, "headings", false)
  let grid_lines = attr_bool(element, "gridLines", false)
  let grid_lines_set = attr_bool(element, "gridLinesSet", true)
  {
    element,
    horizontal_centered,
    vertical_centered,
    headings,
    grid_lines,
    grid_lines_set,
  }
}

///|
/// XSD complex type CT_HeaderFooter — Part 1 §18.3.1.46. Header/footer text
/// payload. Children (all optional, maxOccurs 1, ST_Xstring text):
/// `<oddHeader>`, `<oddFooter>`, `<evenHeader>`, `<evenFooter>`,
/// `<firstHeader>`, `<firstFooter>`. Attributes (all xsd:boolean):
/// `@differentOddEven`, `@differentFirst` (default false); `@scaleWithDoc`,
/// `@alignWithMargins` (default true).
pub(all) struct CT_HeaderFooter {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <oddHeader> (s:ST_Xstring text) — optional.
  odd_header : String?
  /// <oddFooter> (s:ST_Xstring text) — optional.
  odd_footer : String?
  /// <evenHeader> (s:ST_Xstring text) — optional.
  even_header : String?
  /// <evenFooter> (s:ST_Xstring text) — optional.
  even_footer : String?
  /// <firstHeader> (s:ST_Xstring text) — optional.
  first_header : String?
  /// <firstFooter> (s:ST_Xstring text) — optional.
  first_footer : String?
  /// @differentOddEven (xsd:boolean, default false).
  different_odd_even : Bool
  /// @differentFirst (xsd:boolean, default false).
  different_first : Bool
  /// @scaleWithDoc (xsd:boolean, default true).
  scale_with_doc : Bool
  /// @alignWithMargins (xsd:boolean, default true).
  align_with_margins : Bool
} derive(Eq, Debug)

///|
pub fn CT_HeaderFooter::new(element : @xml.Element) -> CT_HeaderFooter {
  let mut odd_header : String? = None
  let mut odd_footer : String? = None
  let mut even_header : String? = None
  let mut even_footer : String? = None
  let mut first_header : String? = None
  let mut first_footer : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "oddHeader" => odd_header = Some(element_text(child_element))
        "oddFooter" => odd_footer = Some(element_text(child_element))
        "evenHeader" => even_header = Some(element_text(child_element))
        "evenFooter" => even_footer = Some(element_text(child_element))
        "firstHeader" => first_header = Some(element_text(child_element))
        "firstFooter" => first_footer = Some(element_text(child_element))
        _ => ()
      }
    }
  }
  let different_odd_even = attr_bool(element, "differentOddEven", false)
  let different_first = attr_bool(element, "differentFirst", false)
  let scale_with_doc = attr_bool(element, "scaleWithDoc", true)
  let align_with_margins = attr_bool(element, "alignWithMargins", true)
  {
    element,
    odd_header,
    odd_footer,
    even_header,
    even_footer,
    first_header,
    first_footer,
    different_odd_even,
    different_first,
    scale_with_doc,
    align_with_margins,
  }
}

///|
/// XSD complex type CT_Scenarios — Part 1 §18.3.1.76. Scenario manager
/// container. Children: one or more `<scenario>` (CT_Scenario). Attributes:
/// optional `@current`, `@show` (xsd:unsignedInt), `@sqref` (ST_Sqref).
pub(all) struct CT_Scenarios {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <scenario>+ (CT_Scenario) — one or more scenarios.
  scenarios : Array[CT_Scenario]
  /// @current (xsd:unsignedInt) — optional active scenario index.
  current : Int?
  /// @show (xsd:unsignedInt) — optional displayed scenario index.
  show : Int?
  /// @sqref (ST_Sqref) — optional changing cells range list.
  sqref : String?
} derive(Eq, Debug)

///|
pub fn CT_Scenarios::new(element : @xml.Element) -> CT_Scenarios {
  let scenarios : Array[CT_Scenario] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "scenario" {
        scenarios.push(CT_Scenario::new(child_element))
      }
    }
  }
  let current = attr_uint_opt(element, "current")
  let show = attr_uint_opt(element, "show")
  let sqref = attr(element, "sqref")
  { element, scenarios, current, show, sqref }
}

///|
/// XSD complex type CT_ProtectedRanges — Part 1 §18.3.1.72. Container for
/// one or more `<protectedRange>` (CT_ProtectedRange) entries.
pub(all) struct CT_ProtectedRanges {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <protectedRange>+ (CT_ProtectedRange) — one or more entries.
  protected_ranges : Array[CT_ProtectedRange]
} derive(Eq, Debug)

///|
pub fn CT_ProtectedRanges::new(element : @xml.Element) -> CT_ProtectedRanges {
  let protected_ranges : Array[CT_ProtectedRange] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "protectedRange" {
        protected_ranges.push(CT_ProtectedRange::new(child_element))
      }
    }
  }
  { element, protected_ranges }
}

///|
/// XSD complex type CT_ProtectedRange — Part 1 §18.3.1.71. Single protected
/// range record. Children: zero or more `<securityDescriptor>` (xsd:string
/// text). Attributes: required `@sqref` (ST_Sqref) and `@name`
/// (s:ST_Xstring); optional `@algorithmName`, `@hashValue`
/// (xsd:base64Binary), `@saltValue` (xsd:base64Binary), `@spinCount`
/// (xsd:unsignedInt).
pub(all) struct CT_ProtectedRange {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <securityDescriptor>* (xsd:string text) — zero or more SD strings.
  security_descriptors : Array[String]
  /// @sqref (ST_Sqref) — required protected range list.
  sqref : String
  /// @name (s:ST_Xstring) — required protected-range name.
  name : String
  /// @algorithmName (s:ST_Xstring) — optional.
  algorithm_name : String?
  /// @hashValue (xsd:base64Binary) — optional hash value.
  hash_value : String?
  /// @saltValue (xsd:base64Binary) — optional salt value.
  salt_value : String?
  /// @spinCount (xsd:unsignedInt) — optional iteration count.
  spin_count : Int?
} derive(Eq, Debug)

///|
pub fn CT_ProtectedRange::new(element : @xml.Element) -> CT_ProtectedRange {
  let security_descriptors : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "securityDescriptor" {
        security_descriptors.push(element_text(child_element))
      }
    }
  }
  let sqref = match attr(element, "sqref") {
    Some(value) => value
    None => ""
  }
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let algorithm_name = attr(element, "algorithmName")
  let hash_value = attr(element, "hashValue")
  let salt_value = attr(element, "saltValue")
  let spin_count = attr_uint_opt(element, "spinCount")
  {
    element,
    security_descriptors,
    sqref,
    name,
    algorithm_name,
    hash_value,
    salt_value,
    spin_count,
  }
}

///|
/// XSD complex type CT_Scenario — Part 1 §18.3.1.75. Single what-if
/// scenario. Children: one or more `<inputCells>` (CT_InputCells).
/// Attributes: required `@name` (s:ST_Xstring); optional `@locked`,
/// `@hidden` (xsd:boolean, default false), `@count` (xsd:unsignedInt),
/// `@user`, `@comment` (s:ST_Xstring).
pub(all) struct CT_Scenario {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <inputCells>+ (CT_InputCells) — one or more captured cell values.
  input_cells : Array[CT_InputCells]
  /// @name (s:ST_Xstring) — required scenario label.
  name : String
  /// @locked (xsd:boolean, default false).
  locked : Bool
  /// @hidden (xsd:boolean, default false).
  hidden : Bool
  /// @count (xsd:unsignedInt) — optional input cell count.
  count : Int?
  /// @user (s:ST_Xstring) — optional creator.
  user : String?
  /// @comment (s:ST_Xstring) — optional comment.
  comment : String?
} derive(Eq, Debug)

///|
pub fn CT_Scenario::new(element : @xml.Element) -> CT_Scenario {
  let input_cells : Array[CT_InputCells] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "inputCells" {
        input_cells.push(CT_InputCells::new(child_element))
      }
    }
  }
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let locked = attr_bool(element, "locked", false)
  let hidden = attr_bool(element, "hidden", false)
  let count = attr_uint_opt(element, "count")
  let user = attr(element, "user")
  let comment = attr(element, "comment")
  { element, input_cells, name, locked, hidden, count, user, comment }
}

///|
/// XSD complex type CT_InputCells — Part 1 §18.3.1.49. Scenario input cell.
/// Required `@r` (ST_CellRef) and `@val` (s:ST_Xstring); optional
/// `@deleted`, `@undone` (xsd:boolean, default false), `@numFmtId`
/// (ST_NumFmtId — xsd:unsignedInt).
pub(all) struct CT_InputCells {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r (ST_CellRef) — required cell reference.
  r : String
  /// @deleted (xsd:boolean, default false).
  deleted : Bool
  /// @undone (xsd:boolean, default false).
  undone : Bool
  /// @val (s:ST_Xstring) — required captured value.
  val : String
  /// @numFmtId (ST_NumFmtId / xsd:unsignedInt) — optional number format.
  num_fmt_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_InputCells::new(element : @xml.Element) -> CT_InputCells {
  let r = match attr(element, "r") {
    Some(value) => value
    None => ""
  }
  let deleted = attr_bool(element, "deleted", false)
  let undone = attr_bool(element, "undone", false)
  let val = match attr(element, "val") {
    Some(value) => value
    None => ""
  }
  let num_fmt_id = attr_uint_opt(element, "numFmtId")
  { element, r, deleted, undone, val, num_fmt_id }
}

///|
/// XSD complex type CT_CellWatches — Part 1 §18.3.1.10. Container for one
/// or more `<cellWatch>` (CT_CellWatch) entries.
pub(all) struct CT_CellWatches {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cellWatch>+ (CT_CellWatch) — one or more entries.
  cell_watches : Array[CT_CellWatch]
} derive(Eq, Debug)

///|
pub fn CT_CellWatches::new(element : @xml.Element) -> CT_CellWatches {
  let cell_watches : Array[CT_CellWatch] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "cellWatch" {
        cell_watches.push(CT_CellWatch::new(child_element))
      }
    }
  }
  { element, cell_watches }
}

///|
/// XSD complex type CT_CellWatch — Part 1 §18.3.1.9. Watch window entry.
/// Required `@r` (ST_CellRef) — cell to watch.
pub(all) struct CT_CellWatch {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r (ST_CellRef) — required watched cell reference.
  r : String
} derive(Eq, Debug)

///|
pub fn CT_CellWatch::new(element : @xml.Element) -> CT_CellWatch {
  let r = match attr(element, "r") {
    Some(value) => value
    None => ""
  }
  { element, r }
}

///|
/// XSD complex type CT_Chartsheet — Part 1 §18.3.1.12. Chartsheet root.
/// Children (in document order): optional `<sheetPr>` (CT_ChartsheetPr);
/// required `<sheetViews>` (CT_ChartsheetViews); optional `<sheetProtection>`
/// (CT_ChartsheetProtection), `<customSheetViews>` (CT_CustomChartsheetViews),
/// `<pageMargins>` (CT_PageMargins), `<pageSetup>` (CT_CsPageSetup),
/// `<headerFooter>` (CT_HeaderFooter); required `<drawing>` (CT_Drawing);
/// optional `<drawingHF>` (CT_DrawingHF), `<picture>`
/// (CT_SheetBackgroundPicture), `<webPublishItems>` (CT_WebPublishItems),
/// `<extLst>` (CT_ExtensionList).
pub(all) struct CT_Chartsheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sheetPr> (CT_ChartsheetPr) — optional.
  sheet_pr : CT_ChartsheetPr?
  /// <sheetViews> (CT_ChartsheetViews) — required view container.
  sheet_views : CT_ChartsheetViews?
  /// <sheetProtection> (CT_ChartsheetProtection) — optional.
  sheet_protection : CT_ChartsheetProtection?
  /// <customSheetViews> (CT_CustomChartsheetViews) — optional.
  custom_sheet_views : CT_CustomChartsheetViews?
  /// <pageMargins> (CT_PageMargins) — optional.
  page_margins : CT_PageMargins?
  /// <pageSetup> (CT_CsPageSetup) — optional chartsheet page setup.
  page_setup : CT_CsPageSetup?
  /// <headerFooter> (CT_HeaderFooter) — optional.
  header_footer : CT_HeaderFooter?
  /// <drawing> (CT_Drawing) — required drawing-part reference.
  drawing : CT_Drawing?
  /// <drawingHF> (CT_DrawingHF) — optional header/footer drawing.
  drawing_hf : CT_DrawingHF?
  /// <picture> (CT_SheetBackgroundPicture) — optional background picture.
  picture : CT_SheetBackgroundPicture?
  /// <webPublishItems> (CT_WebPublishItems) — optional.
  web_publish_items : CT_WebPublishItems?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Chartsheet::new(element : @xml.Element) -> CT_Chartsheet {
  let mut sheet_pr : CT_ChartsheetPr? = None
  let mut sheet_views : CT_ChartsheetViews? = None
  let mut sheet_protection : CT_ChartsheetProtection? = None
  let mut custom_sheet_views : CT_CustomChartsheetViews? = None
  let mut page_margins : CT_PageMargins? = None
  let mut page_setup : CT_CsPageSetup? = None
  let mut header_footer : CT_HeaderFooter? = None
  let mut drawing : CT_Drawing? = None
  let mut drawing_hf : CT_DrawingHF? = None
  let mut picture : CT_SheetBackgroundPicture? = None
  let mut web_publish_items : CT_WebPublishItems? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sheetPr" => sheet_pr = Some(CT_ChartsheetPr::new(child_element))
        "sheetViews" =>
          sheet_views = Some(CT_ChartsheetViews::new(child_element))
        "sheetProtection" =>
          sheet_protection = Some(CT_ChartsheetProtection::new(child_element))
        "customSheetViews" =>
          custom_sheet_views = Some(
            CT_CustomChartsheetViews::new(child_element),
          )
        "pageMargins" => page_margins = Some(CT_PageMargins::new(child_element))
        "pageSetup" => page_setup = Some(CT_CsPageSetup::new(child_element))
        "headerFooter" =>
          header_footer = Some(CT_HeaderFooter::new(child_element))
        "drawing" => drawing = Some(CT_Drawing::new(child_element))
        "drawingHF" => drawing_hf = Some(CT_DrawingHF::new(child_element))
        "picture" =>
          picture = Some(CT_SheetBackgroundPicture::new(child_element))
        "webPublishItems" =>
          web_publish_items = Some(CT_WebPublishItems::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    sheet_pr,
    sheet_views,
    sheet_protection,
    custom_sheet_views,
    page_margins,
    page_setup,
    header_footer,
    drawing,
    drawing_hf,
    picture,
    web_publish_items,
    ext_lst,
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
