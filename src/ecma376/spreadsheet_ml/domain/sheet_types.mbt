///|
/// SpreadsheetML sheet typed domain wrappers from sml.xsd. CT_*
/// identifiers in this file bind ECMA-376 Part 1 §18.3 (worksheet markup),
/// §18.4 (shared strings / phonetic), §18.6 (calculation chain), §18.10
/// (pivot tables), §18.11 (revisions), §18.13 (external queries) and
/// §18.16 (XML mappings) complex types. The source `@xml.Element` is
/// preserved on every typed record so the builder can emit
/// byte-identical round-trip output via `value.element`.

///|
pub fn sheet_type_group_name() -> String {
  "spreadsheet_ml.sheet"
}

///|
/// XSD complex type CT_ObjectAnchor — Part 1 §18.3.1.1 (`<anchor>` Object
/// Cell Anchor). Worksheet object anchor that pins a drawing/legacy OLE
/// object between two `xdr:`-namespaced marker cells. Sequence:
/// required `xdr:from` and `xdr:to` markers (CT_Marker, referenced from
/// dml-spreadsheetDrawing schema). Optional attributes `@moveWithCells`
/// and `@sizeWithCells` (xsd:boolean, both default `false`).
pub(all) struct CT_ObjectAnchor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <xdr:from> (CT_Marker) — required start marker; retained as the
  /// raw foreign element because the SpreadsheetDrawing types live in
  /// the drawing_ml package.
  from : @xml.Element?
  /// <xdr:to> (CT_Marker) — required end marker.
  to : @xml.Element?
  /// @moveWithCells (xsd:boolean) — optional, default false.
  move_with_cells : Bool
  /// @sizeWithCells (xsd:boolean) — optional, default false.
  size_with_cells : Bool
} derive(Eq, Debug)

///|
pub fn CT_ObjectAnchor::new(
  element : @xml.Element,
) -> CT_ObjectAnchor raise @opc_errors.SchemaViolation {
  let mut from : @xml.Element? = None
  let mut to : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "from" => from = Some(child_element)
        "to" => to = Some(child_element)
        _ => ()
      }
    }
  }
  let move_with_cells = attr_bool_schema(
    element, "moveWithCells", false, "Part 1 §18.3.1.1", "anchor",
  )
  let size_with_cells = attr_bool_schema(
    element, "sizeWithCells", false, "Part 1 §18.3.1.1", "anchor",
  )
  { element, from, to, move_with_cells, size_with_cells }
}

///|
/// XSD complex type CT_CalcCell — Part 1 §18.6.1 (`<c>` Cell, calculation
/// chain entry). Records one calculation-chain dependency. Required
/// `@r` (ST_CellRef) cell reference. Optional attributes: `@i`
/// (xsd:int, sheet id, default 0); `@s` (xsd:boolean, default false,
/// child of array formula); `@l` (xsd:boolean, default false, array
/// formula); `@t` (xsd:boolean, default false, table formula); `@a`
/// (xsd:boolean, default false, always calculate).
pub(all) struct CT_CalcCell {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r (ST_CellRef) — required cell reference.
  r : String
  /// @i (xsd:int) — optional sheet id; default 0.
  i : Int
  /// @s (xsd:boolean) — optional, default false.
  s : Bool
  /// @l (xsd:boolean) — optional, default false.
  l : Bool
  /// @t (xsd:boolean) — optional, default false.
  t : Bool
  /// @a (xsd:boolean) — optional, default false.
  a : Bool
  /// @ref (ST_Ref) — optional range reference for a shared/array
  /// formula calc entry; empty when absent.
  ref_range : String
} derive(Eq, Debug)

///|
pub fn CT_CalcCell::new(
  element : @xml.Element,
) -> CT_CalcCell raise @opc_errors.SchemaViolation {
  let r = match attr(element, "r") {
    Some(value) => value
    None => ""
  }
  let i = attr_int(element, "i", 0)
  let s = attr_bool_schema(element, "s", false, "Part 1 §18.6.1", "c")
  let l = attr_bool_schema(element, "l", false, "Part 1 §18.6.1", "c")
  let t = attr_bool_schema(element, "t", false, "Part 1 §18.6.1", "c")
  let a = attr_bool_schema(element, "a", false, "Part 1 §18.6.1", "c")
  let ref_range = attr(element, "ref").unwrap_or("")
  { element, r, i, s, l, t, a, ref_range }
}

///|
/// XSD complex type CT_DataBinding — Part 1 §18.16.1 (`<DataBinding>`
/// XML Mapping). XML data binding settings for a custom mapping.
/// Sequence carries a single `<xsd:any/>` payload (the bound XML
/// schema fragment). Required `@DataBindingLoadMode`
/// (xsd:unsignedInt). Optional `@DataBindingName` (xsd:string),
/// `@FileBinding` (xsd:boolean), `@ConnectionID` (xsd:unsignedInt),
/// `@FileBindingName` (xsd:string).
pub(all) struct CT_DataBinding {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Inline `<xsd:any/>` payload — every direct element child is kept
  /// as a raw element to round-trip the schema fragment.
  any_children : Array[@xml.Element]
  /// @DataBindingName (xsd:string) — optional.
  data_binding_name : String?
  /// @FileBinding (xsd:boolean) — optional, no default in the XSD.
  file_binding : Bool?
  /// @ConnectionID (xsd:unsignedInt) — optional.
  connection_id : Int?
  /// @FileBindingName (xsd:string) — optional.
  file_binding_name : String?
  /// @DataBindingLoadMode (xsd:unsignedInt) — required.
  data_binding_load_mode : Int
} derive(Eq, Debug)

///|
pub fn CT_DataBinding::new(element : @xml.Element) -> CT_DataBinding {
  let any_children : Array[@xml.Element] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      any_children.push(child_element)
    }
  }
  let data_binding_name = attr(element, "DataBindingName")
  let file_binding = attr_bool_opt(element, "FileBinding")
  let connection_id = attr_uint_opt(element, "ConnectionID")
  let file_binding_name = attr(element, "FileBindingName")
  let data_binding_load_mode = attr_uint(element, "DataBindingLoadMode", 0)
  {
    element,
    any_children,
    data_binding_name,
    file_binding,
    connection_id,
    file_binding_name,
    data_binding_load_mode,
  }
}

///|
/// XSD complex type CT_Tables — Part 1 §18.13.9 (`<tables>` Tables).
/// External query/refresh table list. Unbounded choice between `<m>`
/// (CT_TableMissing, missing entry), `<s>` (CT_XStringElement, string
/// entry) and `<x>` (CT_Index, index entry). Each variant is stored
/// in its own per-kind array to preserve the choice variants without
/// collapsing them. Optional `@count` (xsd:unsignedInt).
pub(all) struct CT_Tables {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <m>* (CT_TableMissing) — zero or more missing entries.
  missings : Array[CT_TableMissing]
  /// <s>* (CT_XStringElement) — zero or more string entries.
  strings : Array[CT_XStringElement]
  /// <x>* (CT_Index) — zero or more index entries.
  indexes : Array[CT_Index]
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_Tables::new(element : @xml.Element) -> CT_Tables {
  let missings : Array[CT_TableMissing] = []
  let strings : Array[CT_XStringElement] = []
  let indexes : Array[CT_Index] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "m" => missings.push(CT_TableMissing::new(child_element))
        "s" => strings.push(CT_XStringElement::new(child_element))
        "x" => indexes.push(CT_Index::new(child_element))
        _ => ()
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, missings, strings, indexes, count }
}

///|
/// XSD complex type CT_TableMissing — Part 1 §18.10.1.50 / §18.13.4
/// (`<m>` No Value). Empty complex type used inside `<tables>` /
/// `<entries>` choice lists to mark missing pivot or query entries.
/// The XSD declares `<xsd:complexType name="CT_TableMissing"/>` with no
/// attributes or children — `present` records that an empty marker
/// element was materialised from the wire so the typed value is
/// distinguishable from an absent one without consulting the raw
/// element.
pub(all) struct CT_TableMissing {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Marker bit confirming this empty record was materialised from a
  /// real `<m/>` element. Always true for instances constructed from
  /// the wire; lets pattern-matching distinguish the empty
  /// CT_TableMissing variant from `None` in optional contexts.
  present : Bool
} derive(Eq, Debug)

///|
pub fn CT_TableMissing::new(element : @xml.Element) -> CT_TableMissing {
  { element, present: true }
}

///|
/// XSD complex type CT_WorksheetSource — Part 1 §18.10.1.95
/// (`<worksheetSource>` Worksheet PivotCache Source). Attribute-only
/// complex type pointing at the worksheet range that backs a pivot
/// cache. Optional `@ref` (ST_Ref) cell range; optional `@name`
/// (s:ST_Xstring) defined-name reference; optional `@sheet`
/// (s:ST_Xstring) sheet name; optional `@r:id` (relationship id) to an
/// external workbook part.
pub(all) struct CT_WorksheetSource {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ref (ST_Ref) — optional cell range reference.
  ref_ : String?
  /// @name (s:ST_Xstring) — optional defined-name reference.
  name : String?
  /// @sheet (s:ST_Xstring) — optional sheet name.
  sheet : String?
  /// @r:id (relationship id) — optional external workbook reference.
  r_id : String?
} derive(Eq, Debug)

///|
pub fn CT_WorksheetSource::new(element : @xml.Element) -> CT_WorksheetSource {
  let ref_ = attr(element, "ref")
  let name = attr(element, "name")
  let sheet = attr(element, "sheet")
  let r_id = attr_with_ns(element, "id")
  { element, ref_, name, sheet, r_id }
}

///|
/// XSD complex type CT_Pages — Part 1 §18.10.1.65 (`<pages>` Page Item
/// Values). Sequence of 1..4 `<page>` children (CT_PCDSCPage). Optional
/// `@count` (xsd:unsignedInt) page-count attribute.
pub(all) struct CT_Pages {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <page>+ (CT_PCDSCPage) — 1..4 page entries.
  page : Array[CT_PCDSCPage]
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_Pages::new(element : @xml.Element) -> CT_Pages {
  let page : Array[CT_PCDSCPage] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "page" {
        page.push(CT_PCDSCPage::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, page, count }
}

///|
/// XSD complex type CT_PageItem — Part 1 §18.10.1.64 (`<pageItem>` Page
/// Item). Attribute-only complex type that records a single pivot page
/// filter item. Required `@name` (s:ST_Xstring) shared-item caption.
pub(all) struct CT_PageItem {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required item caption.
  name : String
} derive(Eq, Debug)

///|
pub fn CT_PageItem::new(element : @xml.Element) -> CT_PageItem {
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  { element, name }
}

///|
/// XSD complex type CT_PageFields — Part 1 §18.10.1.63 (`<pageFields>`
/// Page Field Items). Sequence of one or more `<pageField>` children
/// (CT_PageField). Optional `@count` (xsd:unsignedInt) entry count.
pub(all) struct CT_PageFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pageField>+ (CT_PageField) — one or more page fields.
  page_field : Array[CT_PageField]
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_PageFields::new(element : @xml.Element) -> CT_PageFields {
  let page_field : Array[CT_PageField] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pageField" {
        page_field.push(CT_PageField::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, page_field, count }
}

///|
/// XSD complex type CT_PageField — Part 1 §18.10.1.62 (`<pageField>`
/// Page Field). Single PivotTable page-area field. Optional `<extLst>`
/// (CT_ExtensionList) child. Required `@fld` (xsd:int) source-field
/// index. Optional `@item` (xsd:unsignedInt) shared-item index;
/// optional `@hier` (xsd:int) hierarchy index; optional `@name`
/// (s:ST_Xstring) display name; optional `@cap` (s:ST_Xstring) caption.
pub(all) struct CT_PageField {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @fld (xsd:int) — required source-field index.
  fld : Int
  /// @item (xsd:unsignedInt) — optional shared-item index.
  item : Int?
  /// @hier (xsd:int) — optional hierarchy index.
  hier : Int?
  /// @name (s:ST_Xstring) — optional display name.
  name : String?
  /// @cap (s:ST_Xstring) — optional caption.
  cap : String?
} derive(Eq, Debug)

///|
pub fn CT_PageField::new(element : @xml.Element) -> CT_PageField {
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  let fld = attr_int(element, "fld", 0)
  let item = attr_uint_opt(element, "item")
  let hier = attr_int_opt(element, "hier")
  let name = attr(element, "name")
  let cap = attr(element, "cap")
  { element, ext_lst, fld, item, hier, name, cap }
}

///|
/// XSD complex type CT_DataFields — Part 1 §18.10.1.23 (`<dataFields>`
/// Data Fields). Sequence of one or more `<dataField>` children
/// (CT_DataField). Optional `@count` (xsd:unsignedInt) entry count.
pub(all) struct CT_DataFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <dataField>+ (CT_DataField) — one or more data fields.
  data_field : Array[CT_DataField]
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_DataFields::new(element : @xml.Element) -> CT_DataFields {
  let data_field : Array[CT_DataField] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "dataField" {
        data_field.push(CT_DataField::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, data_field, count }
}

///|
/// XSD complex type CT_DataField — Part 1 §18.10.1.22 (`<dataField>`
/// Data Field Item). One PivotTable data area field. Optional
/// `<extLst>` (CT_ExtensionList) child. Optional `@name`
/// (s:ST_Xstring) display name; required `@fld` (xsd:unsignedInt)
/// source-field index. Optional `@subtotal`
/// (ST_DataConsolidateFunction, default `sum`); `@showDataAs`
/// (ST_ShowDataAs, default `normal`); `@baseField` (xsd:int, default
/// -1); `@baseItem` (xsd:unsignedInt, default 1048832); `@numFmtId`
/// (ST_NumFmtId / xsd:unsignedInt).
pub(all) struct CT_DataField {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @name (s:ST_Xstring) — optional display name.
  name : String?
  /// @fld (xsd:unsignedInt) — required source-field index.
  fld : Int
  /// @subtotal (ST_DataConsolidateFunction) — optional, default `sum`.
  subtotal : String
  /// @showDataAs (ST_ShowDataAs) — optional, default `normal`.
  show_data_as : String
  /// @baseField (xsd:int) — optional, default -1.
  base_field : Int
  /// @baseItem (xsd:unsignedInt) — optional, default 1048832.
  base_item : Int
  /// @numFmtId (ST_NumFmtId / xsd:unsignedInt) — optional.
  num_fmt_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_DataField::new(element : @xml.Element) -> CT_DataField {
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  let name = attr(element, "name")
  let fld = attr_uint(element, "fld", 0)
  let subtotal = match attr(element, "subtotal") {
    Some(value) => value
    None => "sum"
  }
  let show_data_as = match attr(element, "showDataAs") {
    Some(value) => value
    None => "normal"
  }
  let base_field = attr_int(element, "baseField", -1)
  let base_item = attr_uint(element, "baseItem", 1048832)
  let num_fmt_id = attr_uint_opt(element, "numFmtId")
  {
    element,
    ext_lst,
    name,
    fld,
    subtotal,
    show_data_as,
    base_field,
    base_item,
    num_fmt_id,
  }
}

///|
/// XSD complex type CT_rowItems — Part 1 §18.10.1.84 (`<rowItems>`
/// Row Items). Sequence of one or more `<i>` children (CT_I row item
/// entries). Optional `@count` (xsd:unsignedInt) entry count.
pub(all) struct CT_rowItems {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <i>+ (CT_I) — one or more row items.
  i : Array[CT_I]
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_rowItems::new(element : @xml.Element) -> CT_rowItems {
  let i : Array[CT_I] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "i" {
        i.push(CT_I::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, i, count }
}

///|
/// XSD complex type CT_colItems — Part 1 §18.10.1.17 (`<colItems>`
/// Column Items). Sequence of one or more `<i>` children (CT_I column
/// item entries). Optional `@count` (xsd:unsignedInt) entry count.
pub(all) struct CT_colItems {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <i>+ (CT_I) — one or more column items.
  i : Array[CT_I]
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_colItems::new(element : @xml.Element) -> CT_colItems {
  let i : Array[CT_I] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "i" {
        i.push(CT_I::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, i, count }
}

///|
/// XSD complex type CT_RowFields — Part 1 §18.10.1.81 (`<rowFields>`
/// Row Fields). Sequence of one or more `<field>` children (CT_Field).
/// Optional `@count` (xsd:unsignedInt, default 0) entry count.
pub(all) struct CT_RowFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <field>+ (CT_Field) — one or more row fields.
  field : Array[CT_Field]
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
} derive(Eq, Debug)

///|
pub fn CT_RowFields::new(element : @xml.Element) -> CT_RowFields {
  let field : Array[CT_Field] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "field" {
        field.push(CT_Field::new(child_element))
      }
    }
  }
  let count = attr_uint(element, "count", 0)
  { element, field, count }
}

///|
/// XSD complex type CT_ColFields — Part 1 §18.10.1.14 (`<colFields>`
/// Column Fields). Sequence of one or more `<field>` children
/// (CT_Field). Optional `@count` (xsd:unsignedInt, default 0).
pub(all) struct CT_ColFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <field>+ (CT_Field) — one or more column fields.
  field : Array[CT_Field]
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
} derive(Eq, Debug)

///|
pub fn CT_ColFields::new(element : @xml.Element) -> CT_ColFields {
  let field : Array[CT_Field] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "field" {
        field.push(CT_Field::new(child_element))
      }
    }
  }
  let count = attr_uint(element, "count", 0)
  { element, field, count }
}

///|
/// XSD complex type CT_ConditionalFormats — Part 1 §18.10.1.19
/// (`<conditionalFormats>` Conditional Formats). Sequence of one or
/// more `<conditionalFormat>` children (CT_ConditionalFormat). Optional
/// `@count` (xsd:unsignedInt, default 0) entry count.
pub(all) struct CT_ConditionalFormats {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <conditionalFormat>+ (CT_ConditionalFormat) — one or more entries.
  conditional_format : Array[CT_ConditionalFormat]
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
} derive(Eq, Debug)

///|
pub fn CT_ConditionalFormats::new(
  element : @xml.Element,
) -> CT_ConditionalFormats raise @opc_errors.SchemaViolation {
  let conditional_format : Array[CT_ConditionalFormat] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "conditionalFormat" {
        conditional_format.push(CT_ConditionalFormat::new(child_element))
      }
    }
  }
  let count = attr_uint(element, "count", 0)
  { element, conditional_format, count }
}

///|
/// XSD complex type CT_ConditionalFormat — Part 1 §18.10.1.18
/// (`<conditionalFormat>` Conditional Formatting). PivotTable
/// conditional-format entry. Sequence: required `<pivotAreas>`
/// (CT_PivotAreas) child; optional `<extLst>` (CT_ExtensionList) child.
/// Optional `@scope` (ST_Scope, default `selection`); `@type` (ST_Type,
/// default `none`); required `@priority` (xsd:unsignedInt).
pub(all) struct CT_ConditionalFormat {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pivotAreas> (CT_PivotAreas) — required pivot-area scope list.
  pivot_areas : CT_PivotAreas?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @scope (ST_Scope) — optional, default `selection`.
  scope : String
  /// @type (ST_Type) — optional, default `none`.
  type_ : String
  /// @priority (xsd:unsignedInt) — required priority order.
  priority : Int
} derive(Eq, Debug)

///|
pub fn CT_ConditionalFormat::new(
  element : @xml.Element,
) -> CT_ConditionalFormat raise @opc_errors.SchemaViolation {
  let mut pivot_areas : CT_PivotAreas? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "pivotAreas" => pivot_areas = Some(CT_PivotAreas::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let scope = match attr(element, "scope") {
    Some(value) => value
    None => "selection"
  }
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => "none"
  }
  let priority = attr_uint(element, "priority", 0)
  { element, pivot_areas, ext_lst, scope, type_, priority }
}

///|
/// XSD complex type CT_ChartFormats — Part 1 §18.10.1.13
/// (`<chartFormats>` PivotChart Formats). Sequence of one or more
/// `<chartFormat>` children (CT_ChartFormat). Optional `@count`
/// (xsd:unsignedInt, default 0) entry count.
pub(all) struct CT_ChartFormats {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <chartFormat>+ (CT_ChartFormat) — one or more entries.
  chart_format : Array[CT_ChartFormat]
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
} derive(Eq, Debug)

///|
pub fn CT_ChartFormats::new(
  element : @xml.Element,
) -> CT_ChartFormats raise @opc_errors.SchemaViolation {
  let chart_format : Array[CT_ChartFormat] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "chartFormat" {
        chart_format.push(CT_ChartFormat::new(child_element))
      }
    }
  }
  let count = attr_uint(element, "count", 0)
  { element, chart_format, count }
}

///|
/// XSD complex type CT_ChartFormat — Part 1 §18.10.1.12 (`<chartFormat>`
/// PivotChart Format). Single PivotChart format-entry. Sequence:
/// required `<pivotArea>` (CT_PivotArea) child. Required `@chart`
/// (xsd:unsignedInt) chart index; required `@format` (xsd:unsignedInt)
/// format index. Optional `@series` (xsd:boolean, default false).
pub(all) struct CT_ChartFormat {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pivotArea> (CT_PivotArea) — required scope area.
  pivot_area : CT_PivotArea?
  /// @chart (xsd:unsignedInt) — required chart index.
  chart : Int
  /// @format (xsd:unsignedInt) — required format index.
  format : Int
  /// @series (xsd:boolean) — optional, default false.
  series : Bool
} derive(Eq, Debug)

///|
pub fn CT_ChartFormat::new(
  element : @xml.Element,
) -> CT_ChartFormat raise @opc_errors.SchemaViolation {
  let mut pivot_area : CT_PivotArea? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pivotArea" {
        pivot_area = Some(CT_PivotArea::new(child_element))
      }
    }
  }
  let chart = attr_uint(element, "chart", 0)
  let format = attr_uint(element, "format", 0)
  let series = attr_bool(element, "series", false)
  { element, pivot_area, chart, format, series }
}

///|
/// XSD complex type CT_RevisionHeaders — Part 1 §18.11.1.2 (`<headers>`
/// Revision Headers). Top-level revisions header container. Sequence:
/// one or more `<header>` children (CT_RevisionHeader). Required
/// `@guid` (s:ST_Guid). Optional `@lastGuid` (s:ST_Guid). Boolean and
/// numeric workbook-state attributes with defaults: `@shared` (default
/// true), `@diskRevisions` (false), `@history` (true),
/// `@trackRevisions` (true), `@exclusive` (false), `@revisionId`
/// (xsd:unsignedInt, default 0), `@version` (xsd:int, default 1),
/// `@keepChangeHistory` (default true), `@protected` (default false),
/// `@preserveHistory` (xsd:unsignedInt, default 30).
pub(all) struct CT_RevisionHeaders {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <header>+ (CT_RevisionHeader) — one or more revision headers.
  header : Array[CT_RevisionHeader]
  /// @guid (s:ST_Guid) — required.
  guid : String
  /// @lastGuid (s:ST_Guid) — optional.
  last_guid : String?
  /// @shared (xsd:boolean) — optional, default true.
  shared : Bool
  /// @diskRevisions (xsd:boolean) — optional, default false.
  disk_revisions : Bool
  /// @history (xsd:boolean) — optional, default true.
  history : Bool
  /// @trackRevisions (xsd:boolean) — optional, default true.
  track_revisions : Bool
  /// @exclusive (xsd:boolean) — optional, default false.
  exclusive : Bool
  /// @revisionId (xsd:unsignedInt) — optional, default 0.
  revision_id : Int
  /// @version (xsd:int) — optional, default 1.
  version : Int
  /// @keepChangeHistory (xsd:boolean) — optional, default true.
  keep_change_history : Bool
  /// @protected (xsd:boolean) — optional, default false.
  is_protected : Bool
  /// @preserveHistory (xsd:unsignedInt) — optional, default 30.
  preserve_history : Int
} derive(Eq, Debug)

///|
pub fn CT_RevisionHeaders::new(element : @xml.Element) -> CT_RevisionHeaders {
  let header : Array[CT_RevisionHeader] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "header" {
        header.push(CT_RevisionHeader::new(child_element))
      }
    }
  }
  let guid = match attr(element, "guid") {
    Some(value) => value
    None => ""
  }
  let last_guid = attr(element, "lastGuid")
  let shared = attr_bool(element, "shared", true)
  let disk_revisions = attr_bool(element, "diskRevisions", false)
  let history = attr_bool(element, "history", true)
  let track_revisions = attr_bool(element, "trackRevisions", true)
  let exclusive = attr_bool(element, "exclusive", false)
  let revision_id = attr_uint(element, "revisionId", 0)
  let version = attr_int(element, "version", 1)
  let keep_change_history = attr_bool(element, "keepChangeHistory", true)
  let is_protected = attr_bool(element, "protected", false)
  let preserve_history = attr_uint(element, "preserveHistory", 30)
  {
    element,
    header,
    guid,
    last_guid,
    shared,
    disk_revisions,
    history,
    track_revisions,
    exclusive,
    revision_id,
    version,
    keep_change_history,
    is_protected,
    preserve_history,
  }
}

///|
/// XSD complex type CT_RevisionHeader — Part 1 §18.11.1.1 (`<header>`
/// Header). Single revision-log header entry. Sequence: required
/// `<sheetIdMap>` (CT_SheetIdMap); optional `<reviewedList>`
/// (CT_ReviewedRevisions); optional `<extLst>` (CT_ExtensionList).
/// Required attributes: `@guid` (s:ST_Guid), `@dateTime`
/// (xsd:dateTime), `@maxSheetId` (xsd:unsignedInt), `@userName`
/// (s:ST_Xstring) and `@r:id` (relationship id). Optional `@minRId`
/// and `@maxRId` (xsd:unsignedInt).
pub(all) struct CT_RevisionHeader {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sheetIdMap> (CT_SheetIdMap) — required sheet-id mapping table.
  sheet_id_map : CT_SheetIdMap?
  /// <reviewedList> (CT_ReviewedRevisions) — optional.
  reviewed_list : CT_ReviewedRevisions?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @guid (s:ST_Guid) — required.
  guid : String
  /// @dateTime (xsd:dateTime) — required ISO timestamp.
  date_time : String
  /// @maxSheetId (xsd:unsignedInt) — required.
  max_sheet_id : Int
  /// @userName (s:ST_Xstring) — required.
  user_name : String
  /// @r:id (relationship id) — required.
  r_id : String
  /// @minRId (xsd:unsignedInt) — optional.
  min_r_id : Int?
  /// @maxRId (xsd:unsignedInt) — optional.
  max_r_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_RevisionHeader::new(element : @xml.Element) -> CT_RevisionHeader {
  let mut sheet_id_map : CT_SheetIdMap? = None
  let mut reviewed_list : CT_ReviewedRevisions? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sheetIdMap" => sheet_id_map = Some(CT_SheetIdMap::new(child_element))
        "reviewedList" =>
          reviewed_list = Some(CT_ReviewedRevisions::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let guid = match attr(element, "guid") {
    Some(value) => value
    None => ""
  }
  let date_time = match attr(element, "dateTime") {
    Some(value) => value
    None => ""
  }
  let max_sheet_id = attr_uint(element, "maxSheetId", 0)
  let user_name = match attr(element, "userName") {
    Some(value) => value
    None => ""
  }
  let r_id = match attr_with_ns(element, "id") {
    Some(value) => value
    None => ""
  }
  let min_r_id = attr_uint_opt(element, "minRId")
  let max_r_id = attr_uint_opt(element, "maxRId")
  {
    element,
    sheet_id_map,
    reviewed_list,
    ext_lst,
    guid,
    date_time,
    max_sheet_id,
    user_name,
    r_id,
    min_r_id,
    max_r_id,
  }
}

///|
/// XSD complex type CT_SheetId — Part 1 §18.11.1.23 (`<sheetId>` Sheet
/// Id). Attribute-only entry inside `<sheetIdMap>`. Required `@val`
/// (xsd:unsignedInt) sheet identifier value.
pub(all) struct CT_SheetId {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (xsd:unsignedInt) — required identifier value.
  val : Int
} derive(Eq, Debug)

///|
pub fn CT_SheetId::new(element : @xml.Element) -> CT_SheetId {
  let val = attr_uint(element, "val", 0)
  { element, val }
}

///|
/// XSD complex type CT_ReviewedRevisions — Part 1 §18.11.1.15
/// (`<reviewedList>` Reviewed List). Sequence: one or more `<reviewed>`
/// entries (CT_Reviewed). Optional `@count` (xsd:unsignedInt).
pub(all) struct CT_ReviewedRevisions {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <reviewed>+ (CT_Reviewed) — one or more reviewed entries.
  reviewed : Array[CT_Reviewed]
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_ReviewedRevisions::new(
  element : @xml.Element,
) -> CT_ReviewedRevisions {
  let reviewed : Array[CT_Reviewed] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "reviewed" {
        reviewed.push(CT_Reviewed::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, reviewed, count }
}

///|
/// XSD complex type CT_Reviewed — Part 1 §18.11.1.14 (`<reviewed>`
/// Reviewed). Attribute-only complex type. Required `@rId`
/// (xsd:unsignedInt) revision id reference.
pub(all) struct CT_Reviewed {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @rId (xsd:unsignedInt) — required revision id.
  r_id : Int
} derive(Eq, Debug)

///|
pub fn CT_Reviewed::new(element : @xml.Element) -> CT_Reviewed {
  let r_id = attr_uint(element, "rId", 0)
  { element, r_id }
}

///|
/// XSD complex type CT_RevisionRowColumn — Part 1 §18.11.1.21 (`<rrc>`
/// Revision Row Column Insert Delete). Records a row/column insert
/// or delete revision. Unbounded choice of `<undo>` (CT_UndoInfo),
/// `<rcc>` (CT_RevisionCellChange) and `<rfmt>`
/// (CT_RevisionFormatting) children — each kind tracked in its own
/// array. Required attributes from AG_RevData: `@rId`
/// (xsd:unsignedInt), `@ua` (xsd:boolean, default false), `@ra`
/// (xsd:boolean, default false). Type-specific attributes: required
/// `@sId` (xsd:unsignedInt), required `@ref` (ST_Ref), required
/// `@action` (ST_rwColActionType). Optional `@eol` (xsd:boolean,
/// default false) and `@edge` (xsd:boolean, default false).
pub(all) struct CT_RevisionRowColumn {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <undo>* (CT_UndoInfo) — zero or more undo records.
  undo : Array[CT_UndoInfo]
  /// <rcc>* (CT_RevisionCellChange) — zero or more cell changes.
  rcc : Array[CT_RevisionCellChange]
  /// <rfmt>* (CT_RevisionFormatting) — zero or more formatting changes.
  rfmt : Array[CT_RevisionFormatting]
  /// @rId (xsd:unsignedInt) — required revision id (AG_RevData).
  r_id : Int
  /// @ua (xsd:boolean) — optional, default false (AG_RevData).
  ua : Bool
  /// @ra (xsd:boolean) — optional, default false (AG_RevData).
  ra : Bool
  /// @sId (xsd:unsignedInt) — required sheet id.
  s_id : Int
  /// @eol (xsd:boolean) — optional, default false.
  eol : Bool
  /// @ref (ST_Ref) — required row/column reference.
  ref_ : String
  /// @action (ST_rwColActionType) — required action verb.
  action : String
  /// @edge (xsd:boolean) — optional, default false.
  edge : Bool
} derive(Eq, Debug)

///|
pub fn CT_RevisionRowColumn::new(
  element : @xml.Element,
) -> CT_RevisionRowColumn {
  let undo : Array[CT_UndoInfo] = []
  let rcc : Array[CT_RevisionCellChange] = []
  let rfmt : Array[CT_RevisionFormatting] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "undo" => undo.push(CT_UndoInfo::new(child_element))
        "rcc" => rcc.push(CT_RevisionCellChange::new(child_element))
        "rfmt" => rfmt.push(CT_RevisionFormatting::new(child_element))
        _ => ()
      }
    }
  }
  let r_id = attr_uint(element, "rId", 0)
  let ua = attr_bool(element, "ua", false)
  let ra = attr_bool(element, "ra", false)
  let s_id = attr_uint(element, "sId", 0)
  let eol = attr_bool(element, "eol", false)
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  let action = match attr(element, "action") {
    Some(value) => value
    None => ""
  }
  let edge = attr_bool(element, "edge", false)
  { element, undo, rcc, rfmt, r_id, ua, ra, s_id, eol, ref_, action, edge }
}

///|
/// XSD complex type CT_RevisionCustomView — Part 1 §18.11.1.12 (`<rcv>`
/// Revision Custom View). Attribute-only revision entry. Required
/// `@guid` (s:ST_Guid) view identifier. Required `@action`
/// (ST_RevisionAction) action verb (add or delete).
pub(all) struct CT_RevisionCustomView {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @guid (s:ST_Guid) — required.
  guid : String
  /// @action (ST_RevisionAction) — required.
  action : String
} derive(Eq, Debug)

///|
pub fn CT_RevisionCustomView::new(
  element : @xml.Element,
) -> CT_RevisionCustomView {
  let guid = match attr(element, "guid") {
    Some(value) => value
    None => ""
  }
  let action = match attr(element, "action") {
    Some(value) => value
    None => ""
  }
  { element, guid, action }
}

///|
/// XSD complex type CT_RevisionSheetRename — Part 1 §18.11.1.22
/// (`<rsnm>` Revision Sheet Name). Sequence: optional `<extLst>`
/// (CT_ExtensionList). Required attributes from AG_RevData (`@rId`,
/// `@ua`, `@ra`) and type-specific required attributes `@sheetId`
/// (xsd:unsignedInt), `@oldName` (s:ST_Xstring), `@newName`
/// (s:ST_Xstring).
pub(all) struct CT_RevisionSheetRename {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @rId (xsd:unsignedInt) — required (AG_RevData).
  r_id : Int
  /// @ua (xsd:boolean) — optional, default false (AG_RevData).
  ua : Bool
  /// @ra (xsd:boolean) — optional, default false (AG_RevData).
  ra : Bool
  /// @sheetId (xsd:unsignedInt) — required.
  sheet_id : Int
  /// @oldName (s:ST_Xstring) — required prior sheet name.
  old_name : String
  /// @newName (s:ST_Xstring) — required new sheet name.
  new_name : String
} derive(Eq, Debug)

///|
pub fn CT_RevisionSheetRename::new(
  element : @xml.Element,
) -> CT_RevisionSheetRename {
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  let r_id = attr_uint(element, "rId", 0)
  let ua = attr_bool(element, "ua", false)
  let ra = attr_bool(element, "ra", false)
  let sheet_id = attr_uint(element, "sheetId", 0)
  let old_name = match attr(element, "oldName") {
    Some(value) => value
    None => ""
  }
  let new_name = match attr(element, "newName") {
    Some(value) => value
    None => ""
  }
  { element, ext_lst, r_id, ua, ra, sheet_id, old_name, new_name }
}

///|
/// XSD complex type CT_RevisionInsertSheet — Part 1 §18.11.1.18
/// (`<ris>` Revision Insert Sheet). Attribute-only revision entry.
/// Required attributes from AG_RevData (`@rId`, `@ua`, `@ra`).
/// Type-specific required attributes `@sheetId` (xsd:unsignedInt),
/// `@name` (s:ST_Xstring) and `@sheetPosition` (xsd:unsignedInt).
pub(all) struct CT_RevisionInsertSheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @rId (xsd:unsignedInt) — required (AG_RevData).
  r_id : Int
  /// @ua (xsd:boolean) — optional, default false (AG_RevData).
  ua : Bool
  /// @ra (xsd:boolean) — optional, default false (AG_RevData).
  ra : Bool
  /// @sheetId (xsd:unsignedInt) — required.
  sheet_id : Int
  /// @name (s:ST_Xstring) — required new sheet name.
  name : String
  /// @sheetPosition (xsd:unsignedInt) — required insertion index.
  sheet_position : Int
} derive(Eq, Debug)

///|
pub fn CT_RevisionInsertSheet::new(
  element : @xml.Element,
) -> CT_RevisionInsertSheet {
  let r_id = attr_uint(element, "rId", 0)
  let ua = attr_bool(element, "ua", false)
  let ra = attr_bool(element, "ra", false)
  let sheet_id = attr_uint(element, "sheetId", 0)
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let sheet_position = attr_uint(element, "sheetPosition", 0)
  { element, r_id, ua, ra, sheet_id, name, sheet_position }
}

///|
/// XSD complex type CT_RevisionCellChange — Part 1 §18.11.1.9
/// (`<rcc>` Revision Cell Change). Sequence: optional `<oc>` old
/// cell (CT_Cell), required `<nc>` new cell (CT_Cell), optional
/// `<odxf>` old dxf (CT_Dxf), optional `<ndxf>` new dxf (CT_Dxf), and
/// optional `<extLst>` (CT_ExtensionList). Required attributes from
/// AG_RevData (`@rId`, `@ua`, `@ra`). Type-specific required `@sId`
/// (xsd:unsignedInt). Optional boolean / property attributes with
/// defaults: `@odxf` (xsd:boolean, default false), `@xfDxf`
/// (xsd:boolean, default false), `@s` (xsd:boolean, default false),
/// `@dxf` (xsd:boolean, default false), `@numFmtId` (ST_NumFmtId),
/// `@quotePrefix` (xsd:boolean, default false), `@oldQuotePrefix`
/// (xsd:boolean, default false), `@ph` (xsd:boolean, default false),
/// `@oldPh` (xsd:boolean, default false), `@endOfListFormulaUpdate`
/// (xsd:boolean, default false).
pub(all) struct CT_RevisionCellChange {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <oc> (CT_Cell) — optional old cell.
  oc : CT_Cell?
  /// <nc> (CT_Cell) — required new cell.
  nc : CT_Cell?
  /// <odxf> (CT_Dxf) — optional old dxf payload (child element).
  odxf_child : CT_Dxf?
  /// <ndxf> (CT_Dxf) — optional new dxf payload (child element).
  ndxf_child : CT_Dxf?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @rId (xsd:unsignedInt) — required (AG_RevData).
  r_id : Int
  /// @ua (xsd:boolean) — optional, default false (AG_RevData).
  ua : Bool
  /// @ra (xsd:boolean) — optional, default false (AG_RevData).
  ra : Bool
  /// @sId (xsd:unsignedInt) — required sheet id.
  s_id : Int
  /// @odxf (xsd:boolean) — optional, default false (attribute flag).
  odxf : Bool
  /// @xfDxf (xsd:boolean) — optional, default false.
  xf_dxf : Bool
  /// @s (xsd:boolean) — optional, default false.
  s : Bool
  /// @dxf (xsd:boolean) — optional, default false.
  dxf : Bool
  /// @numFmtId (ST_NumFmtId / xsd:unsignedInt) — optional.
  num_fmt_id : Int?
  /// @quotePrefix (xsd:boolean) — optional, default false.
  quote_prefix : Bool
  /// @oldQuotePrefix (xsd:boolean) — optional, default false.
  old_quote_prefix : Bool
  /// @ph (xsd:boolean) — optional, default false.
  ph : Bool
  /// @oldPh (xsd:boolean) — optional, default false.
  old_ph : Bool
  /// @endOfListFormulaUpdate (xsd:boolean) — optional, default false.
  end_of_list_formula_update : Bool
} derive(Eq, Debug)

///|
pub fn CT_RevisionCellChange::new(
  element : @xml.Element,
) -> CT_RevisionCellChange {
  let mut oc : CT_Cell? = None
  let mut nc : CT_Cell? = None
  let mut odxf_child : CT_Dxf? = None
  let mut ndxf_child : CT_Dxf? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "oc" => oc = Some(CT_Cell::new(child_element))
        "nc" => nc = Some(CT_Cell::new(child_element))
        "odxf" => odxf_child = Some(CT_Dxf::new(child_element))
        "ndxf" => ndxf_child = Some(CT_Dxf::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let r_id = attr_uint(element, "rId", 0)
  let ua = attr_bool(element, "ua", false)
  let ra = attr_bool(element, "ra", false)
  let s_id = attr_uint(element, "sId", 0)
  let odxf = attr_bool(element, "odxf", false)
  let xf_dxf = attr_bool(element, "xfDxf", false)
  let s = attr_bool(element, "s", false)
  let dxf = attr_bool(element, "dxf", false)
  let num_fmt_id = attr_uint_opt(element, "numFmtId")
  let quote_prefix = attr_bool(element, "quotePrefix", false)
  let old_quote_prefix = attr_bool(element, "oldQuotePrefix", false)
  let ph = attr_bool(element, "ph", false)
  let old_ph = attr_bool(element, "oldPh", false)
  let end_of_list_formula_update = attr_bool(
    element, "endOfListFormulaUpdate", false,
  )
  {
    element,
    oc,
    nc,
    odxf_child,
    ndxf_child,
    ext_lst,
    r_id,
    ua,
    ra,
    s_id,
    odxf,
    xf_dxf,
    s,
    dxf,
    num_fmt_id,
    quote_prefix,
    old_quote_prefix,
    ph,
    old_ph,
    end_of_list_formula_update,
  }
}

///|
/// XSD complex type CT_Macrosheet — Part 1 §A.2 / referenced from Part 4
/// §15.4 (Worksheets). Macro-sheet root payload. Long sequence of
/// optional worksheet sub-parts: `<sheetPr>` (CT_SheetPr), `<dimension>`
/// (CT_SheetDimension), `<sheetViews>` (CT_SheetViews), `<sheetFormatPr>`
/// (CT_SheetFormatPr), `<cols>*` (CT_Cols, unbounded), required
/// `<sheetData>` (CT_SheetData), `<sheetProtection>` (CT_SheetProtection),
/// `<autoFilter>` (CT_AutoFilter), `<sortState>` (CT_SortState),
/// `<dataConsolidate>` (CT_DataConsolidate), `<customSheetViews>`
/// (CT_CustomSheetViews), `<phoneticPr>` (CT_PhoneticPr),
/// `<conditionalFormatting>*` (CT_ConditionalFormatting, unbounded),
/// `<printOptions>` (CT_PrintOptions), `<pageMargins>` (CT_PageMargins),
/// `<pageSetup>` (CT_PageSetup), `<headerFooter>` (CT_HeaderFooter),
/// `<rowBreaks>` / `<colBreaks>` (CT_PageBreak), `<customProperties>`
/// (CT_CustomProperties), `<drawing>` (CT_Drawing), `<drawingHF>`
/// (CT_DrawingHF), `<picture>` (CT_SheetBackgroundPicture),
/// `<oleObjects>` (CT_OleObjects), `<extLst>` (CT_ExtensionList).
pub(all) struct CT_Macrosheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  sheet_pr : CT_SheetPr?
  dimension : CT_SheetDimension?
  sheet_views : CT_SheetViews?
  sheet_format_pr : CT_SheetFormatPr?
  /// <cols>* (CT_Cols) — unbounded per XSD.
  cols : Array[CT_Cols]
  /// <sheetData> (CT_SheetData) — required.
  sheet_data : CT_SheetData?
  sheet_protection : CT_SheetProtection?
  /// <autoFilter> (CT_AutoFilter) — optional; raw element because the
  /// typed CT_AutoFilter is constructed by the external autofilter
  /// parser package, not by a `::new(@xml.Element)` constructor.
  auto_filter : @xml.Element?
  sort_state : CT_SortState?
  data_consolidate : CT_DataConsolidate?
  custom_sheet_views : CT_CustomSheetViews?
  phonetic_pr : CT_PhoneticPr?
  /// <conditionalFormatting>* (CT_ConditionalFormatting) — unbounded.
  /// Part 1 §18.3.1.18.
  conditional_formatting : Array[CT_ConditionalFormatting]
  print_options : CT_PrintOptions?
  page_margins : CT_PageMargins?
  /// <pageSetup> (CT_PageSetup) — optional. Kept as raw element to
  /// avoid coupling to the pivot-package CT_PageSetup binding.
  page_setup : @xml.Element?
  header_footer : CT_HeaderFooter?
  row_breaks : CT_PageBreak?
  col_breaks : CT_PageBreak?
  custom_properties : CT_CustomProperties?
  drawing : CT_Drawing?
  drawing_hf : CT_DrawingHF?
  picture : CT_SheetBackgroundPicture?
  ole_objects : CT_OleObjects?
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Macrosheet::new(
  element : @xml.Element,
) -> CT_Macrosheet raise @opc_errors.SchemaViolation {
  let mut sheet_pr : CT_SheetPr? = None
  let mut dimension : CT_SheetDimension? = None
  let mut sheet_views : CT_SheetViews? = None
  let mut sheet_format_pr : CT_SheetFormatPr? = None
  let cols : Array[CT_Cols] = []
  let mut sheet_data : CT_SheetData? = None
  let mut sheet_protection : CT_SheetProtection? = None
  let mut auto_filter : @xml.Element? = None
  let mut sort_state : CT_SortState? = None
  let mut data_consolidate : CT_DataConsolidate? = None
  let mut custom_sheet_views : CT_CustomSheetViews? = None
  let mut phonetic_pr : CT_PhoneticPr? = None
  let conditional_formatting : Array[CT_ConditionalFormatting] = []
  let mut print_options : CT_PrintOptions? = None
  let mut page_margins : CT_PageMargins? = None
  let mut page_setup : @xml.Element? = None
  let mut header_footer : CT_HeaderFooter? = None
  let mut row_breaks : CT_PageBreak? = None
  let mut col_breaks : CT_PageBreak? = None
  let mut custom_properties : CT_CustomProperties? = None
  let mut drawing : CT_Drawing? = None
  let mut drawing_hf : CT_DrawingHF? = None
  let mut picture : CT_SheetBackgroundPicture? = None
  let mut ole_objects : CT_OleObjects? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sheetPr" => sheet_pr = Some(CT_SheetPr::new(child_element))
        "dimension" => dimension = Some(CT_SheetDimension::new(child_element))
        "sheetViews" => sheet_views = Some(CT_SheetViews::new(child_element))
        "sheetFormatPr" =>
          sheet_format_pr = Some(CT_SheetFormatPr::new(child_element))
        "cols" => cols.push(CT_Cols::new(child_element))
        "sheetData" => sheet_data = Some(CT_SheetData::new(child_element))
        "sheetProtection" =>
          sheet_protection = Some(CT_SheetProtection::new(child_element))
        "autoFilter" => auto_filter = Some(child_element)
        "sortState" => sort_state = Some(CT_SortState::new(child_element))
        "dataConsolidate" =>
          data_consolidate = Some(CT_DataConsolidate::new(child_element))
        "customSheetViews" =>
          custom_sheet_views = Some(CT_CustomSheetViews::new(child_element))
        "phoneticPr" => phonetic_pr = Some(CT_PhoneticPr::new(child_element))
        "conditionalFormatting" =>
          conditional_formatting.push(
            CT_ConditionalFormatting::new(child_element),
          )
        "printOptions" =>
          print_options = Some(CT_PrintOptions::new(child_element))
        "pageMargins" => page_margins = Some(CT_PageMargins::new(child_element))
        "pageSetup" => {
          let _ = CT_PageSetup::new(child_element)
          page_setup = Some(child_element)
        }
        "headerFooter" =>
          header_footer = Some(CT_HeaderFooter::new(child_element))
        "rowBreaks" => row_breaks = Some(CT_PageBreak::new(child_element))
        "colBreaks" => col_breaks = Some(CT_PageBreak::new(child_element))
        "customProperties" =>
          custom_properties = Some(CT_CustomProperties::new(child_element))
        "drawing" => drawing = Some(CT_Drawing::new(child_element))
        "drawingHF" => drawing_hf = Some(CT_DrawingHF::new(child_element))
        "picture" =>
          picture = Some(CT_SheetBackgroundPicture::new(child_element))
        "oleObjects" => ole_objects = Some(CT_OleObjects::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    sheet_pr,
    dimension,
    sheet_views,
    sheet_format_pr,
    cols,
    sheet_data,
    sheet_protection,
    auto_filter,
    sort_state,
    data_consolidate,
    custom_sheet_views,
    phonetic_pr,
    conditional_formatting,
    print_options,
    page_margins,
    page_setup,
    header_footer,
    row_breaks,
    col_breaks,
    custom_properties,
    drawing,
    drawing_hf,
    picture,
    ole_objects,
    ext_lst,
  }
}

///|
/// XSD complex type CT_Dialogsheet — Part 1 §18.3.1.34 (`<dialogsheet>`
/// Dialog Sheet). Optional `<sheetPr>` (CT_SheetPr), `<sheetViews>`
/// (CT_SheetViews), `<sheetFormatPr>` (CT_SheetFormatPr),
/// `<sheetProtection>` (CT_SheetProtection), `<customSheetViews>`
/// (CT_CustomSheetViews), `<printOptions>` (CT_PrintOptions),
/// `<pageMargins>` (CT_PageMargins), `<pageSetup>` (CT_PageSetup),
/// `<headerFooter>` (CT_HeaderFooter), `<drawing>` (CT_Drawing),
/// `<drawingHF>` (CT_DrawingHF), `<oleObjects>` (CT_OleObjects),
/// `<controls>` (CT_Controls), `<extLst>` (CT_ExtensionList).
pub(all) struct CT_Dialogsheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  sheet_pr : CT_SheetPr?
  sheet_views : CT_SheetViews?
  sheet_format_pr : CT_SheetFormatPr?
  sheet_protection : CT_SheetProtection?
  custom_sheet_views : CT_CustomSheetViews?
  print_options : CT_PrintOptions?
  page_margins : CT_PageMargins?
  /// <pageSetup> (CT_PageSetup) — optional; raw element to avoid the
  /// pivot-package CT_PageSetup coupling.
  page_setup : @xml.Element?
  header_footer : CT_HeaderFooter?
  drawing : CT_Drawing?
  drawing_hf : CT_DrawingHF?
  ole_objects : CT_OleObjects?
  controls : CT_Controls?
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Dialogsheet::new(
  element : @xml.Element,
) -> CT_Dialogsheet raise @opc_errors.SchemaViolation {
  let mut sheet_pr : CT_SheetPr? = None
  let mut sheet_views : CT_SheetViews? = None
  let mut sheet_format_pr : CT_SheetFormatPr? = None
  let mut sheet_protection : CT_SheetProtection? = None
  let mut custom_sheet_views : CT_CustomSheetViews? = None
  let mut print_options : CT_PrintOptions? = None
  let mut page_margins : CT_PageMargins? = None
  let mut page_setup : @xml.Element? = None
  let mut header_footer : CT_HeaderFooter? = None
  let mut drawing : CT_Drawing? = None
  let mut drawing_hf : CT_DrawingHF? = None
  let mut ole_objects : CT_OleObjects? = None
  let mut controls : CT_Controls? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sheetPr" => sheet_pr = Some(CT_SheetPr::new(child_element))
        "sheetViews" => sheet_views = Some(CT_SheetViews::new(child_element))
        "sheetFormatPr" =>
          sheet_format_pr = Some(CT_SheetFormatPr::new(child_element))
        "sheetProtection" =>
          sheet_protection = Some(CT_SheetProtection::new(child_element))
        "customSheetViews" =>
          custom_sheet_views = Some(CT_CustomSheetViews::new(child_element))
        "printOptions" =>
          print_options = Some(CT_PrintOptions::new(child_element))
        "pageMargins" => page_margins = Some(CT_PageMargins::new(child_element))
        "pageSetup" => {
          let _ = CT_PageSetup::new(child_element)
          page_setup = Some(child_element)
        }
        "headerFooter" =>
          header_footer = Some(CT_HeaderFooter::new(child_element))
        "drawing" => drawing = Some(CT_Drawing::new(child_element))
        "drawingHF" => drawing_hf = Some(CT_DrawingHF::new(child_element))
        "oleObjects" => ole_objects = Some(CT_OleObjects::new(child_element))
        "controls" => controls = Some(CT_Controls::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    sheet_pr,
    sheet_views,
    sheet_format_pr,
    sheet_protection,
    custom_sheet_views,
    print_options,
    page_margins,
    page_setup,
    header_footer,
    drawing,
    drawing_hf,
    ole_objects,
    controls,
    ext_lst,
  }
}

///|
/// XSD complex type CT_Worksheet — Part 1 §18.3.1.99 (`<worksheet>`
/// Worksheet). Root payload of a worksheet part. Sequence of optional
/// children plus the required `<sheetData>`. Children include:
/// `<sheetPr>` (CT_SheetPr), `<dimension>` (CT_SheetDimension),
/// `<sheetViews>` (CT_SheetViews), `<sheetFormatPr>`
/// (CT_SheetFormatPr), `<cols>*` (CT_Cols), required `<sheetData>`,
/// `<sheetCalcPr>` (CT_SheetCalcPr), `<sheetProtection>`,
/// `<protectedRanges>`, `<scenarios>` (CT_Scenarios), `<autoFilter>`,
/// `<sortState>`, `<dataConsolidate>`, `<customSheetViews>`,
/// `<mergeCells>` (CT_MergeCells), `<phoneticPr>`,
/// `<conditionalFormatting>*`, `<dataValidations>`, `<hyperlinks>`,
/// `<printOptions>`, `<pageMargins>`, `<pageSetup>`, `<headerFooter>`,
/// `<rowBreaks>`, `<colBreaks>`, `<customProperties>`, `<cellWatches>`
/// (CT_CellWatches), `<ignoredErrors>`, `<smartTags>` (CT_SmartTags),
/// `<drawing>`, `<drawingHF>`, `<picture>`, `<oleObjects>`, `<controls>`,
/// `<webPublishItems>` (CT_WebPublishItems), `<tableParts>`
/// (CT_TableParts), `<extLst>`.
pub(all) struct CT_Worksheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  sheet_pr : CT_SheetPr?
  dimension : CT_SheetDimension?
  sheet_views : CT_SheetViews?
  sheet_format_pr : CT_SheetFormatPr?
  /// <cols>* (CT_Cols) — unbounded per XSD.
  cols : Array[CT_Cols]
  /// <sheetData> (CT_SheetData) — required.
  sheet_data : CT_SheetData?
  sheet_calc_pr : CT_SheetCalcPr?
  sheet_protection : CT_SheetProtection?
  protected_ranges : CT_ProtectedRanges?
  scenarios : CT_Scenarios?
  /// <autoFilter> (CT_AutoFilter) — optional; raw element because the
  /// typed CT_AutoFilter is constructed by the external autofilter
  /// parser package.
  auto_filter : @xml.Element?
  sort_state : CT_SortState?
  data_consolidate : CT_DataConsolidate?
  custom_sheet_views : CT_CustomSheetViews?
  merge_cells : CT_MergeCells?
  phonetic_pr : CT_PhoneticPr?
  /// <conditionalFormatting>* (CT_ConditionalFormatting) — unbounded.
  /// Part 1 §18.3.1.18.
  conditional_formatting : Array[CT_ConditionalFormatting]
  data_validations : CT_DataValidations?
  hyperlinks : CT_Hyperlinks?
  print_options : CT_PrintOptions?
  page_margins : CT_PageMargins?
  /// <pageSetup> (CT_PageSetup) — optional; raw element.
  page_setup : @xml.Element?
  header_footer : CT_HeaderFooter?
  row_breaks : CT_PageBreak?
  col_breaks : CT_PageBreak?
  custom_properties : CT_CustomProperties?
  cell_watches : CT_CellWatches?
  ignored_errors : CT_IgnoredErrors?
  smart_tags : CT_SmartTags?
  drawing : CT_Drawing?
  drawing_hf : CT_DrawingHF?
  picture : CT_SheetBackgroundPicture?
  ole_objects : CT_OleObjects?
  controls : CT_Controls?
  web_publish_items : CT_WebPublishItems?
  table_parts : CT_TableParts?
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Worksheet::new(
  element : @xml.Element,
) -> CT_Worksheet raise @opc_errors.SchemaViolation {
  let mut sheet_pr : CT_SheetPr? = None
  let mut dimension : CT_SheetDimension? = None
  let mut sheet_views : CT_SheetViews? = None
  let mut sheet_format_pr : CT_SheetFormatPr? = None
  let cols : Array[CT_Cols] = []
  let mut sheet_data : CT_SheetData? = None
  let mut sheet_calc_pr : CT_SheetCalcPr? = None
  let mut sheet_protection : CT_SheetProtection? = None
  let mut protected_ranges : CT_ProtectedRanges? = None
  let mut scenarios : CT_Scenarios? = None
  let mut auto_filter : @xml.Element? = None
  let mut sort_state : CT_SortState? = None
  let mut data_consolidate : CT_DataConsolidate? = None
  let mut custom_sheet_views : CT_CustomSheetViews? = None
  let mut merge_cells : CT_MergeCells? = None
  let mut phonetic_pr : CT_PhoneticPr? = None
  let conditional_formatting : Array[CT_ConditionalFormatting] = []
  let mut data_validations : CT_DataValidations? = None
  let mut hyperlinks : CT_Hyperlinks? = None
  let mut print_options : CT_PrintOptions? = None
  let mut page_margins : CT_PageMargins? = None
  let mut page_setup : @xml.Element? = None
  let mut header_footer : CT_HeaderFooter? = None
  let mut row_breaks : CT_PageBreak? = None
  let mut col_breaks : CT_PageBreak? = None
  let mut custom_properties : CT_CustomProperties? = None
  let mut cell_watches : CT_CellWatches? = None
  let mut ignored_errors : CT_IgnoredErrors? = None
  let mut smart_tags : CT_SmartTags? = None
  let mut drawing : CT_Drawing? = None
  let mut drawing_hf : CT_DrawingHF? = None
  let mut picture : CT_SheetBackgroundPicture? = None
  let mut ole_objects : CT_OleObjects? = None
  let mut controls : CT_Controls? = None
  let mut web_publish_items : CT_WebPublishItems? = None
  let mut table_parts : CT_TableParts? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sheetPr" => sheet_pr = Some(CT_SheetPr::new(child_element))
        "dimension" => dimension = Some(CT_SheetDimension::new(child_element))
        "sheetViews" => sheet_views = Some(CT_SheetViews::new(child_element))
        "sheetFormatPr" =>
          sheet_format_pr = Some(CT_SheetFormatPr::new(child_element))
        "cols" => cols.push(CT_Cols::new(child_element))
        "sheetData" => sheet_data = Some(CT_SheetData::new(child_element))
        "sheetCalcPr" =>
          sheet_calc_pr = Some(CT_SheetCalcPr::new(child_element))
        "sheetProtection" =>
          sheet_protection = Some(CT_SheetProtection::new(child_element))
        "protectedRanges" =>
          protected_ranges = Some(CT_ProtectedRanges::new(child_element))
        "scenarios" => scenarios = Some(CT_Scenarios::new(child_element))
        "autoFilter" => auto_filter = Some(child_element)
        "sortState" => sort_state = Some(CT_SortState::new(child_element))
        "dataConsolidate" =>
          data_consolidate = Some(CT_DataConsolidate::new(child_element))
        "customSheetViews" =>
          custom_sheet_views = Some(CT_CustomSheetViews::new(child_element))
        "mergeCells" => merge_cells = Some(CT_MergeCells::new(child_element))
        "phoneticPr" => phonetic_pr = Some(CT_PhoneticPr::new(child_element))
        "conditionalFormatting" =>
          conditional_formatting.push(
            CT_ConditionalFormatting::new(child_element),
          )
        "dataValidations" =>
          data_validations = Some(CT_DataValidations::new(child_element))
        "hyperlinks" => hyperlinks = Some(CT_Hyperlinks::new(child_element))
        "printOptions" =>
          print_options = Some(CT_PrintOptions::new(child_element))
        "pageMargins" => page_margins = Some(CT_PageMargins::new(child_element))
        "pageSetup" => {
          let _ = CT_PageSetup::new(child_element)
          page_setup = Some(child_element)
        }
        "headerFooter" =>
          header_footer = Some(CT_HeaderFooter::new(child_element))
        "rowBreaks" => row_breaks = Some(CT_PageBreak::new(child_element))
        "colBreaks" => col_breaks = Some(CT_PageBreak::new(child_element))
        "customProperties" =>
          custom_properties = Some(CT_CustomProperties::new(child_element))
        "cellWatches" => cell_watches = Some(CT_CellWatches::new(child_element))
        "ignoredErrors" =>
          ignored_errors = Some(CT_IgnoredErrors::new(child_element))
        "smartTags" => smart_tags = Some(CT_SmartTags::new(child_element))
        "drawing" => drawing = Some(CT_Drawing::new(child_element))
        "drawingHF" => drawing_hf = Some(CT_DrawingHF::new(child_element))
        "picture" =>
          picture = Some(CT_SheetBackgroundPicture::new(child_element))
        "oleObjects" => ole_objects = Some(CT_OleObjects::new(child_element))
        "controls" => controls = Some(CT_Controls::new(child_element))
        "webPublishItems" =>
          web_publish_items = Some(CT_WebPublishItems::new(child_element))
        "tableParts" => table_parts = Some(CT_TableParts::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    sheet_pr,
    dimension,
    sheet_views,
    sheet_format_pr,
    cols,
    sheet_data,
    sheet_calc_pr,
    sheet_protection,
    protected_ranges,
    scenarios,
    auto_filter,
    sort_state,
    data_consolidate,
    custom_sheet_views,
    merge_cells,
    phonetic_pr,
    conditional_formatting,
    data_validations,
    hyperlinks,
    print_options,
    page_margins,
    page_setup,
    header_footer,
    row_breaks,
    col_breaks,
    custom_properties,
    cell_watches,
    ignored_errors,
    smart_tags,
    drawing,
    drawing_hf,
    picture,
    ole_objects,
    controls,
    web_publish_items,
    table_parts,
    ext_lst,
  }
}

///|
/// XSD complex type CT_SheetData — Part 1 §18.3.1.80 (`<sheetData>`
/// Sheet Data). Sequence: zero or more `<row>` children (CT_Row).
pub(all) struct CT_SheetData {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <row>* (CT_Row) — zero or more rows in document order.
  row : Array[CT_Row]
} derive(Eq, Debug)

///|
pub fn CT_SheetData::new(element : @xml.Element) -> CT_SheetData {
  let row : Array[CT_Row] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "row" {
        row.push(CT_Row::new(child_element))
      }
    }
  }
  { element, row }
}

///|
/// XSD complex type CT_SheetCalcPr — Part 1 §18.3.1.79 (`<sheetCalcPr>`
/// Sheet Calculation Properties). Attribute-only complex type.
/// Optional `@fullCalcOnLoad` (xsd:boolean, default false).
pub(all) struct CT_SheetCalcPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @fullCalcOnLoad (xsd:boolean) — optional, default false.
  full_calc_on_load : Bool
} derive(Eq, Debug)

///|
pub fn CT_SheetCalcPr::new(
  element : @xml.Element,
) -> CT_SheetCalcPr raise @opc_errors.SchemaViolation {
  let full_calc_on_load = attr_bool_schema(
    element, "fullCalcOnLoad", false, "Part 1 §18.3.1.79", "sheetCalcPr",
  )
  { element, full_calc_on_load }
}

///|
/// XSD complex type CT_SheetFormatPr — Part 1 §18.3.1.81
/// (`<sheetFormatPr>` Sheet Format Properties). Attribute-only
/// complex type. Optional `@baseColWidth` (xsd:unsignedInt, default 8),
/// `@defaultColWidth` (xsd:double), required `@defaultRowHeight`
/// (xsd:double). Optional booleans `@customHeight`, `@zeroHeight`,
/// `@thickTop`, `@thickBottom` (all default false). Optional
/// `@outlineLevelRow` and `@outlineLevelCol` (xsd:unsignedByte,
/// default 0).
pub(all) struct CT_SheetFormatPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @baseColWidth (xsd:unsignedInt) — optional, default 8.
  base_col_width : Int
  /// @defaultColWidth (xsd:double) — optional.
  default_col_width : Double?
  /// @defaultRowHeight (xsd:double) — required.
  default_row_height : Double
  /// @customHeight (xsd:boolean) — optional, default false.
  custom_height : Bool
  /// @zeroHeight (xsd:boolean) — optional, default false.
  zero_height : Bool
  /// @thickTop (xsd:boolean) — optional, default false.
  thick_top : Bool
  /// @thickBottom (xsd:boolean) — optional, default false.
  thick_bottom : Bool
  /// @outlineLevelRow (xsd:unsignedByte) — optional, default 0.
  outline_level_row : Int
  /// @outlineLevelCol (xsd:unsignedByte) — optional, default 0.
  outline_level_col : Int
} derive(Eq, Debug)

///|
pub fn CT_SheetFormatPr::new(
  element : @xml.Element,
) -> CT_SheetFormatPr raise @opc_errors.SchemaViolation {
  let base_col_width = attr_uint(element, "baseColWidth", 8)
  let default_col_width = attr_double_opt(element, "defaultColWidth")
  let default_row_height = attr_double(element, "defaultRowHeight", 0.0)
  let custom_height = attr_bool_schema(
    element, "customHeight", false, "Part 1 §18.3.1.81", "sheetFormatPr",
  )
  let zero_height = attr_bool_schema(
    element, "zeroHeight", false, "Part 1 §18.3.1.81", "sheetFormatPr",
  )
  let thick_top = attr_bool_schema(
    element, "thickTop", false, "Part 1 §18.3.1.81", "sheetFormatPr",
  )
  let thick_bottom = attr_bool_schema(
    element, "thickBottom", false, "Part 1 §18.3.1.81", "sheetFormatPr",
  )
  let outline_level_row = attr_uint(element, "outlineLevelRow", 0)
  let outline_level_col = attr_uint(element, "outlineLevelCol", 0)
  {
    element,
    base_col_width,
    default_col_width,
    default_row_height,
    custom_height,
    zero_height,
    thick_top,
    thick_bottom,
    outline_level_row,
    outline_level_col,
  }
}

///|
/// XSD complex type CT_Cols — Part 1 §18.3.1.17. Worksheet column-range
/// container: one or more `<col>` (CT_Col) children.
/// Schema sml.xsd complex type `CT_Cols`. Child elements: `col`. Child
/// types: `CT_Col`.
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
fn sheet_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.82", "sheetPr",
  )
}

///|
pub fn CT_SheetPr::new(
  element : @xml.Element,
) -> CT_SheetPr raise @opc_errors.SchemaViolation {
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
  let sync_horizontal = sheet_pr_bool(element, "syncHorizontal", false)
  let sync_vertical = sheet_pr_bool(element, "syncVertical", false)
  let sync_ref = attr(element, "syncRef")
  let transition_evaluation = sheet_pr_bool(
    element, "transitionEvaluation", false,
  )
  let transition_entry = sheet_pr_bool(element, "transitionEntry", false)
  let published = sheet_pr_bool(element, "published", true)
  let code_name = attr(element, "codeName")
  let filter_mode = sheet_pr_bool(element, "filterMode", false)
  let enable_format_conditions_calculation = sheet_pr_bool(
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
pub fn CT_SheetViews::new(
  element : @xml.Element,
) -> CT_SheetViews raise @opc_errors.SchemaViolation {
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
fn sheet_view_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.87", "sheetView",
  )
}

///|
pub fn CT_SheetView::new(
  element : @xml.Element,
) -> CT_SheetView raise @opc_errors.SchemaViolation {
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
  let window_protection = sheet_view_bool(element, "windowProtection", false)
  let show_formulas = sheet_view_bool(element, "showFormulas", false)
  let show_grid_lines = sheet_view_bool(element, "showGridLines", true)
  let show_row_col_headers = sheet_view_bool(element, "showRowColHeaders", true)
  let show_zeros = sheet_view_bool(element, "showZeros", true)
  let right_to_left = sheet_view_bool(element, "rightToLeft", false)
  let tab_selected = sheet_view_bool(element, "tabSelected", false)
  let show_ruler = sheet_view_bool(element, "showRuler", true)
  let show_outline_symbols = sheet_view_bool(
    element, "showOutlineSymbols", true,
  )
  let default_grid_color = sheet_view_bool(element, "defaultGridColor", true)
  let show_white_space = sheet_view_bool(element, "showWhiteSpace", true)
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
  /// @leftLabels (xsd:boolean, default false).
  left_labels : Bool
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
  let left_labels = attr_bool(element, "leftLabels", false)
  let top_labels = attr_bool(element, "topLabels", false)
  let link = attr_bool(element, "link", false)
  { element, data_refs, function, start_labels, left_labels, top_labels, link }
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
/// Schema sml.xsd complex type `CT_LegacyDrawing`. Attribute groups
/// referenced: `r:id`.
///
/// XSD complex type CT_LegacyDrawing — Part 1 §18.3.1.32. Sheet
/// legacy-drawing-part reference (VML drawing).  Required `@r:id`
/// (relationship to the VML drawing part).  Used by `<legacyDrawing>`
/// and `<legacyDrawingHF>` to address pre-DrawingML graphics that
/// survive in Office documents for backwards compatibility.
pub(all) struct CT_LegacyDrawing {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id — required relationship identifier.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_LegacyDrawing::new(element : @xml.Element) -> CT_LegacyDrawing {
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
pub fn CT_CustomSheetViews::new(
  element : @xml.Element,
) -> CT_CustomSheetViews raise @opc_errors.SchemaViolation {
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
fn custom_sheet_view_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.26", "customSheetView",
  )
}

///|
pub fn CT_CustomSheetView::new(
  element : @xml.Element,
) -> CT_CustomSheetView raise @opc_errors.SchemaViolation {
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
  let show_page_breaks = custom_sheet_view_bool(
    element, "showPageBreaks", false,
  )
  let show_formulas = custom_sheet_view_bool(element, "showFormulas", false)
  let show_grid_lines = custom_sheet_view_bool(element, "showGridLines", true)
  let show_row_col = custom_sheet_view_bool(element, "showRowCol", true)
  let outline_symbols = custom_sheet_view_bool(element, "outlineSymbols", true)
  let zero_values = custom_sheet_view_bool(element, "zeroValues", true)
  let fit_to_page = custom_sheet_view_bool(element, "fitToPage", false)
  let print_area = custom_sheet_view_bool(element, "printArea", false)
  let filter = custom_sheet_view_bool(element, "filter", false)
  let show_auto_filter = custom_sheet_view_bool(
    element, "showAutoFilter", false,
  )
  let hidden_rows = custom_sheet_view_bool(element, "hiddenRows", false)
  let hidden_columns = custom_sheet_view_bool(element, "hiddenColumns", false)
  let state = match attr(element, "state") {
    Some(value) => value
    None => "visible"
  }
  let filter_unique = custom_sheet_view_bool(element, "filterUnique", false)
  let view = match attr(element, "view") {
    Some(value) => value
    None => "normal"
  }
  let show_ruler = custom_sheet_view_bool(element, "showRuler", true)
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
pub fn CT_DataValidations::new(
  element : @xml.Element,
) -> CT_DataValidations raise @opc_errors.SchemaViolation {
  let data_validations : Array[CT_DataValidation] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "dataValidation" {
        data_validations.push(CT_DataValidation::new(child_element))
      }
    }
  }
  let disable_prompts = attr_bool_schema(
    element, "disablePrompts", false, "Part 1 §18.3.1.33", "dataValidations",
  )
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
fn data_validation_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.32", "dataValidation",
  )
}

///|
pub fn CT_DataValidation::new(
  element : @xml.Element,
) -> CT_DataValidation raise @opc_errors.SchemaViolation {
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
  let type_ = decode_data_validation_type(
    attr(element, "type").unwrap_or("none"),
  )
  let error_style = decode_data_validation_error_style(
    attr(element, "errorStyle").unwrap_or("stop"),
  )
  let ime_mode = decode_data_validation_ime_mode(
    attr(element, "imeMode").unwrap_or("noControl"),
  )
  let operator = decode_data_validation_operator(
    attr(element, "operator").unwrap_or("between"),
  )
  let allow_blank = data_validation_bool(element, "allowBlank", false)
  let show_drop_down = data_validation_bool(element, "showDropDown", false)
  let show_input_message = data_validation_bool(
    element, "showInputMessage", false,
  )
  let show_error_message = data_validation_bool(
    element, "showErrorMessage", false,
  )
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
fn decode_data_validation_type(
  value : String,
) -> String raise @opc_errors.SchemaViolation {
  try @sml_types.ST_DataValidationType::new(value) catch {
    @sml_types.SchemaViolation(_) =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.1.32 / §18.18.21",
        path="dataValidation/@type",
        reason="value is outside ST_DataValidationType enumeration",
      )
  } noraise {
    parsed => parsed.to_string()
  }
}

///|
fn decode_data_validation_error_style(
  value : String,
) -> String raise @opc_errors.SchemaViolation {
  try @sml_types.ST_DataValidationErrorStyle::new(value) catch {
    @sml_types.SchemaViolation(_) =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.1.32 / §18.18.18",
        path="dataValidation/@errorStyle",
        reason="value is outside ST_DataValidationErrorStyle enumeration",
      )
  } noraise {
    parsed => parsed.to_string()
  }
}

///|
fn decode_data_validation_ime_mode(
  value : String,
) -> String raise @opc_errors.SchemaViolation {
  try @sml_types.ST_DataValidationImeMode::new(value) catch {
    @sml_types.SchemaViolation(_) =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.1.32 / §18.18.19",
        path="dataValidation/@imeMode",
        reason="value is outside ST_DataValidationImeMode enumeration",
      )
  } noraise {
    parsed => parsed.to_string()
  }
}

///|
fn decode_data_validation_operator(
  value : String,
) -> String raise @opc_errors.SchemaViolation {
  try @sml_types.ST_DataValidationOperator::new(value) catch {
    @sml_types.SchemaViolation(_) =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.1.32 / §18.18.20",
        path="dataValidation/@operator",
        reason="value is outside ST_DataValidationOperator enumeration",
      )
  } noraise {
    parsed => parsed.to_string()
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
fn print_options_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.70", "printOptions",
  )
}

///|
pub fn CT_PrintOptions::new(
  element : @xml.Element,
) -> CT_PrintOptions raise @opc_errors.SchemaViolation {
  let horizontal_centered = print_options_bool(
    element, "horizontalCentered", false,
  )
  let vertical_centered = print_options_bool(element, "verticalCentered", false)
  let headings = print_options_bool(element, "headings", false)
  let grid_lines = print_options_bool(element, "gridLines", false)
  let grid_lines_set = print_options_bool(element, "gridLinesSet", true)
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
fn header_footer_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.46", "headerFooter",
  )
}

///|
pub fn CT_HeaderFooter::new(
  element : @xml.Element,
) -> CT_HeaderFooter raise @opc_errors.SchemaViolation {
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
  let different_odd_even = header_footer_bool(
    element, "differentOddEven", false,
  )
  let different_first = header_footer_bool(element, "differentFirst", false)
  let scale_with_doc = header_footer_bool(element, "scaleWithDoc", true)
  let align_with_margins = header_footer_bool(element, "alignWithMargins", true)
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
  /// @password (ST_UnsignedShortHex) — legacy 16-bit verifier hash,
  /// deprecated; `None` when absent.
  legacy_password : String?
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
  let legacy_password = attr(element, "password")
  {
    element,
    security_descriptors,
    sqref,
    name,
    algorithm_name,
    hash_value,
    salt_value,
    spin_count,
    legacy_password,
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
pub fn CT_Chartsheet::new(
  element : @xml.Element,
) -> CT_Chartsheet raise @opc_errors.SchemaViolation {
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
/// XSD complex type CT_ChartsheetPr — Part 1 §18.3.1.12
/// (`<sheetPr>` of a chartsheet).  Carries the VBA `@codeName`, the
/// `@published` flag, and an optional `<tabColor>` child.
pub(all) struct CT_ChartsheetPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @codeName (ST_Xstring) — VBA code name; empty when absent.
  code_name : String
  /// @published (xsd:boolean) — default true.
  published : Bool
  /// <tabColor> (CT_Color) — optional sheet-tab colour, retained raw.
  tab_color : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_ChartsheetPr::new(element : @xml.Element) -> CT_ChartsheetPr {
  let mut tab_color : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "tabColor" {
      tab_color = Some(e)
    }
  }
  {
    element,
    code_name: attr(element, "codeName").unwrap_or(""),
    published: attr_bool(element, "published", true),
    tab_color,
  }
}

///|
/// XSD complex type CT_ChartsheetViews — Part 1 §18.3.1.45.  A list of
/// `<sheetView>` (CT_ChartsheetView) children.
pub(all) struct CT_ChartsheetViews {
  element : @xml.Element
  views : Array[CT_ChartsheetView]
} derive(Eq, Debug)

///|
pub fn CT_ChartsheetViews::new(element : @xml.Element) -> CT_ChartsheetViews {
  let views : Array[CT_ChartsheetView] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "sheetView" {
      views.push(CT_ChartsheetView::new(e))
    }
  }
  { element, views }
}

///|
/// XSD complex type CT_ChartsheetView — Part 1 §18.3.1.44.  One chart
/// sheet view: tab selection, zoom, and the owning workbook view id.
pub(all) struct CT_ChartsheetView {
  element : @xml.Element
  /// @tabSelected (xsd:boolean) — default false.
  tab_selected : Bool
  /// @zoomScale (xsd:unsignedInt) — default 100.
  zoom_scale : Int
  /// @workbookViewId (xsd:unsignedInt) — required; default 0.
  workbook_view_id : Int
  /// @zoomToFit (xsd:boolean) — default false.
  zoom_to_fit : Bool
} derive(Eq, Debug)

///|
pub fn CT_ChartsheetView::new(element : @xml.Element) -> CT_ChartsheetView {
  {
    element,
    tab_selected: attr_bool(element, "tabSelected", false),
    zoom_scale: attr_int(element, "zoomScale", 100),
    workbook_view_id: attr_int(element, "workbookViewId", 0),
    zoom_to_fit: attr_bool(element, "zoomToFit", false),
  }
}

///|
/// XSD complex type CT_CustomChartsheetViews — Part 1 §18.3.1.22.  A
/// list of `<customSheetView>` (CT_CustomChartsheetView) children.
pub(all) struct CT_CustomChartsheetViews {
  element : @xml.Element
  views : Array[CT_CustomChartsheetView]
} derive(Eq, Debug)

///|
pub fn CT_CustomChartsheetViews::new(
  element : @xml.Element,
) -> CT_CustomChartsheetViews {
  let views : Array[CT_CustomChartsheetView] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "customSheetView" {
      views.push(CT_CustomChartsheetView::new(e))
    }
  }
  { element, views }
}

///|
/// XSD complex type CT_CustomChartsheetView — Part 1 §18.3.1.21.  A
/// named custom view of a chart sheet (guid + zoom/state) with optional
/// page-setup children.
pub(all) struct CT_CustomChartsheetView {
  element : @xml.Element
  /// @guid (ST_Guid) — required view identifier.
  guid : String
  /// @scale (xsd:unsignedInt) — default 100.
  scale : Int
  /// @state (ST_SheetState) — default "visible".
  state : String
  /// @zoomToFit (xsd:boolean) — default false.
  zoom_to_fit : Bool
  /// <pageMargins> / <pageSetup> / <headerFooter> — retained raw.
  page_margins : @xml.Element?
  page_setup : @xml.Element?
  header_footer : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_CustomChartsheetView::new(
  element : @xml.Element,
) -> CT_CustomChartsheetView {
  let mut page_margins : @xml.Element? = None
  let mut page_setup : @xml.Element? = None
  let mut header_footer : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(e) {
      match e.name.local_name {
        "pageMargins" => page_margins = Some(e)
        "pageSetup" => page_setup = Some(e)
        "headerFooter" => header_footer = Some(e)
        _ => ()
      }
    }
  }
  {
    element,
    guid: attr(element, "guid").unwrap_or(""),
    scale: attr_int(element, "scale", 100),
    state: attr(element, "state").unwrap_or("visible"),
    zoom_to_fit: attr_bool(element, "zoomToFit", false),
    page_margins,
    page_setup,
    header_footer,
  }
}

///|
/// XSD complex type CT_CustomProperty — Part 1 §18.3.1.18.  A named
/// custom property of a sheet, referencing a property part via `r:id`.
pub(all) struct CT_CustomProperty {
  element : @xml.Element
  /// @name (ST_Xstring) — required property name.
  name : String
  /// @r:id (ST_RelationshipId) — relationship to the property part.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_CustomProperty::new(element : @xml.Element) -> CT_CustomProperty {
  {
    element,
    name: attr(element, "name").unwrap_or(""),
    r_id: attr(element, "id").unwrap_or(""),
  }
}

///|
/// XSD complex type CT_ObjectPr — Part 1 §18.3.1.55.  Embedded-object
/// properties (sizing / printing / fill toggles) plus the cell anchor.
pub(all) struct CT_ObjectPr {
  element : @xml.Element
  /// @locked (xsd:boolean) — default true.
  locked : Bool
  /// @defaultSize (xsd:boolean) — default true.
  default_size : Bool
  /// @disabled (xsd:boolean) — default false.
  disabled : Bool
  /// @autoFill (xsd:boolean) — default true.
  auto_fill : Bool
  /// @autoPict (xsd:boolean) — default true.
  auto_pict : Bool
  /// @autoLine (xsd:boolean) — default true.
  auto_line : Bool
  /// @altText (ST_Xstring) — accessibility text; empty when absent.
  alt_text : String
  /// @print (xsd:boolean) — default true.
  print : Bool
  /// @uiObject (xsd:boolean) — default false.
  ui_object : Bool
  /// @dde (xsd:boolean) — DDE-linked object; default false.
  dde : Bool
  /// @macro (ST_Formula) — macro reference; empty when absent.
  macro_ref : String
  /// @r:id (ST_RelationshipId) — relationship to the embedded object.
  r_id : String
  /// <anchor> (CT_ObjectAnchor) — retained raw.
  anchor : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_ObjectPr::new(element : @xml.Element) -> CT_ObjectPr {
  let mut anchor : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "anchor" {
      anchor = Some(e)
    }
  }
  {
    element,
    locked: attr_bool(element, "locked", true),
    default_size: attr_bool(element, "defaultSize", true),
    disabled: attr_bool(element, "disabled", false),
    auto_fill: attr_bool(element, "autoFill", true),
    auto_pict: attr_bool(element, "autoPict", true),
    auto_line: attr_bool(element, "autoLine", true),
    alt_text: attr(element, "altText").unwrap_or(""),
    print: attr_bool(element, "print", true),
    ui_object: attr_bool(element, "uiObject", false),
    dde: attr_bool(element, "dde", false),
    macro_ref: attr(element, "macro").unwrap_or(""),
    r_id: attr(element, "id").unwrap_or(""),
    anchor,
  }
}

///|
/// XSD complex type CT_Controls — Part 1 §18.3.1.20.  A list of
/// `<control>` (CT_Control) children.
pub(all) struct CT_Controls {
  element : @xml.Element
  controls : Array[CT_Control]
} derive(Eq, Debug)

///|
pub fn CT_Controls::new(element : @xml.Element) -> CT_Controls {
  let controls : Array[CT_Control] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "control" {
      controls.push(CT_Control::new(e))
    }
  }
  { element, controls }
}

///|
/// XSD complex type CT_Control — Part 1 §18.3.1.32.  A form control on
/// a worksheet: its `@shapeId`, `r:id` relationship, `@name`, and
/// optional `<controlPr>`.
pub(all) struct CT_Control {
  element : @xml.Element
  /// @shapeId (xsd:unsignedInt) — required drawing shape id; default 0.
  shape_id : Int
  /// @r:id (ST_RelationshipId) — relationship to the control part.
  r_id : String
  /// @name (ST_Xstring) — control name; empty when absent.
  name : String
  /// <controlPr> (CT_ControlPr) — typed control properties.
  control_pr : CT_ControlPr?
} derive(Eq, Debug)

///|
pub fn CT_Control::new(element : @xml.Element) -> CT_Control {
  let mut control_pr : CT_ControlPr? = None
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "controlPr" {
      control_pr = Some(CT_ControlPr::new(e))
    }
  }
  {
    element,
    shape_id: attr_int(element, "shapeId", 0),
    r_id: attr(element, "id").unwrap_or(""),
    name: attr(element, "name").unwrap_or(""),
    control_pr,
  }
}

///|
/// XSD complex type CT_ControlPr — Part 1 §18.3.1.19.  Form-control
/// properties (sizing / fill / print toggles, alt text) plus anchor.
pub(all) struct CT_ControlPr {
  element : @xml.Element
  /// @locked (xsd:boolean) — default true.
  locked : Bool
  /// @defaultSize (xsd:boolean) — default true.
  default_size : Bool
  /// @disabled (xsd:boolean) — default false.
  disabled : Bool
  /// @autoFill (xsd:boolean) — default true.
  auto_fill : Bool
  /// @autoLine (xsd:boolean) — default true.
  auto_line : Bool
  /// @autoPict (xsd:boolean) — default true.
  auto_pict : Bool
  /// @altText (ST_Xstring) — accessibility text; empty when absent.
  alt_text : String
  /// @print (xsd:boolean) — default true.
  print : Bool
  /// @recalcAlways (xsd:boolean) — default false.
  recalc_always : Bool
  /// @uiObject (xsd:boolean) — default false.
  ui_object : Bool
  /// @macro (ST_Formula) — macro reference; empty when absent.
  macro_ref : String
  /// @cf (ST_Xstring) — clipboard format; default "pict".
  cf : String
  /// @linkedCell (ST_Formula) — linked cell reference.
  linked_cell : String
  /// @listFillRange (ST_Formula) — list-fill source range.
  list_fill_range : String
  /// @r:id (ST_RelationshipId) — relationship to the control part.
  r_id : String
  /// <anchor> (CT_ObjectAnchor) — retained raw.
  anchor : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_ControlPr::new(element : @xml.Element) -> CT_ControlPr {
  let mut anchor : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "anchor" {
      anchor = Some(e)
    }
  }
  {
    element,
    locked: attr_bool(element, "locked", true),
    default_size: attr_bool(element, "defaultSize", true),
    disabled: attr_bool(element, "disabled", false),
    auto_fill: attr_bool(element, "autoFill", true),
    auto_line: attr_bool(element, "autoLine", true),
    auto_pict: attr_bool(element, "autoPict", true),
    alt_text: attr(element, "altText").unwrap_or(""),
    print: attr_bool(element, "print", true),
    recalc_always: attr_bool(element, "recalcAlways", false),
    ui_object: attr_bool(element, "uiObject", false),
    macro_ref: attr(element, "macro").unwrap_or(""),
    cf: attr(element, "cf").unwrap_or("pict"),
    linked_cell: attr(element, "linkedCell").unwrap_or(""),
    list_fill_range: attr(element, "listFillRange").unwrap_or(""),
    r_id: attr(element, "id").unwrap_or(""),
    anchor,
  }
}

///|
/// XSD complex type CT_IgnoredErrors — Part 1 §18.3.1.46.  A list of
/// `<ignoredError>` (CT_IgnoredError) children.
pub(all) struct CT_IgnoredErrors {
  element : @xml.Element
  errors : Array[CT_IgnoredError]
} derive(Eq, Debug)

///|
pub fn CT_IgnoredErrors::new(element : @xml.Element) -> CT_IgnoredErrors {
  let errors : Array[CT_IgnoredError] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "ignoredError" {
      errors.push(CT_IgnoredError::new(e))
    }
  }
  { element, errors }
}

///|
/// XSD complex type CT_IgnoredError — Part 1 §18.3.1.45.  The set of
/// error checks suppressed over a cell range (`@sqref`), each a boolean
/// toggle defaulting to false.
pub(all) struct CT_IgnoredError {
  element : @xml.Element
  /// @sqref (ST_Sqref) — the cell range(s) the suppression applies to.
  sqref : String
  /// @evalError (xsd:boolean) — default false.
  eval_error : Bool
  /// @twoDigitTextYear (xsd:boolean) — default false.
  two_digit_text_year : Bool
  /// @numberStoredAsText (xsd:boolean) — default false.
  number_stored_as_text : Bool
  /// @formula (xsd:boolean) — default false.
  formula : Bool
  /// @formulaRange (xsd:boolean) — default false.
  formula_range : Bool
  /// @unlockedFormula (xsd:boolean) — default false.
  unlocked_formula : Bool
  /// @emptyCellReference (xsd:boolean) — default false.
  empty_cell_reference : Bool
  /// @listDataValidation (xsd:boolean) — default false.
  list_data_validation : Bool
  /// @calculatedColumn (xsd:boolean) — default false.
  calculated_column : Bool
} derive(Eq, Debug)

///|
pub fn CT_IgnoredError::new(element : @xml.Element) -> CT_IgnoredError {
  {
    element,
    sqref: attr(element, "sqref").unwrap_or(""),
    eval_error: attr_bool(element, "evalError", false),
    two_digit_text_year: attr_bool(element, "twoDigitTextYear", false),
    number_stored_as_text: attr_bool(element, "numberStoredAsText", false),
    formula: attr_bool(element, "formula", false),
    formula_range: attr_bool(element, "formulaRange", false),
    unlocked_formula: attr_bool(element, "unlockedFormula", false),
    empty_cell_reference: attr_bool(element, "emptyCellReference", false),
    list_data_validation: attr_bool(element, "listDataValidation", false),
    calculated_column: attr_bool(element, "calculatedColumn", false),
  }
}

///|
/// XSD complex type CT_TableParts — Part 1 §18.3.1.87 (`<tableParts>`).
/// `@count` (optional) + a sequence of `<tablePart>` children.
pub(all) struct CT_TableParts {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — number of table parts; default 0.
  count : Int
  /// `<tablePart>` (CT_TablePart) children in document order.
  parts : Array[CT_TablePart]
} derive(Eq, Debug)

///|
pub fn CT_TableParts::new(element : @xml.Element) -> CT_TableParts {
  let parts : Array[CT_TablePart] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "tablePart" {
      parts.push(CT_TablePart::new(e))
    }
  }
  { element, count: attr_int(element, "count", 0), parts }
}

///|
/// XSD complex type CT_TablePart — Part 1 §18.3.1.86 (`<tablePart>`).
/// A relationship reference (`r:id`) to a table-definition part.
pub(all) struct CT_TablePart {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — relationship to the table part.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_TablePart::new(element : @xml.Element) -> CT_TablePart {
  { element, r_id: attr(element, "id").unwrap_or("") }
}

///|
/// XSD complex type CT_Table — Part 1 §18.5.1.2 (`<table>`).  Defines a
/// SpreadsheetML structured table over a cell range: its name /
/// display name, the `@ref` range, header / totals row counts, and the
/// typed column definitions.
pub(all) struct CT_Table {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt) — table id; default 0.
  id : Int
  /// @name (ST_Xstring) — programmatic name.
  name : String
  /// @displayName (ST_Xstring) — display name (required by spec).
  display_name : String
  /// @comment (ST_Xstring) — optional table comment.
  comment : String
  /// @ref (ST_Ref) — the table's cell range (e.g. "A1:C5").
  ref_range : String
  /// @headerRowCount (xsd:unsignedInt) — default 1.
  header_row_count : Int
  /// @totalsRowCount (xsd:unsignedInt) — default 0.
  totals_row_count : Int
  /// @totalsRowShown (xsd:boolean) — default true.
  totals_row_shown : Bool
  /// @tableType (ST_TableType) — "worksheet" (default) / "xml" /
  /// "queryTable".
  table_type : String
  /// @connectionId (xsd:unsignedInt) — external connection; default 0.
  connection_id : Int
  /// @published (xsd:boolean) — default false.
  published : Bool
  /// @insertRow / @insertRowShift (xsd:boolean) — default false.
  insert_row : Bool
  insert_row_shift : Bool
  /// Style references (ST_DxfId / cell-style names).  dxf-id fields use
  /// -1 to mean "absent" (no default in the schema).
  header_row_dxf_id : Int
  data_dxf_id : Int
  totals_row_dxf_id : Int
  header_row_border_dxf_id : Int
  table_border_dxf_id : Int
  totals_row_border_dxf_id : Int
  header_row_cell_style : String
  data_cell_style : String
  totals_row_cell_style : String
  /// <tableColumns> (CT_TableColumns) — required column definitions.
  table_columns : CT_TableColumns?
  /// <autoFilter> (CT_AutoFilter) — optional, retained raw.
  auto_filter : @xml.Element?
  /// <sortState> (CT_SortState) — optional, retained raw.
  sort_state : @xml.Element?
  /// <tableStyleInfo> (CT_TableStyleInfo) — optional table-style
  /// projection. The typed value is the SoT for renderers; `element`
  /// still preserves the raw source XML for round-trip.
  table_style_info : CT_TableStyleInfo?
} derive(Eq, Debug)

///|
pub fn CT_Table::new(
  element : @xml.Element,
) -> CT_Table raise @opc_errors.SchemaViolation {
  let mut table_columns : CT_TableColumns? = None
  let mut auto_filter : @xml.Element? = None
  let mut sort_state : @xml.Element? = None
  let mut table_style_info : CT_TableStyleInfo? = None
  for child in element.children {
    if child is @xml.Node::Element(e) {
      match e.name.local_name {
        "tableColumns" => table_columns = Some(CT_TableColumns::new(e))
        "autoFilter" => auto_filter = Some(e)
        "sortState" => sort_state = Some(e)
        "tableStyleInfo" => table_style_info = Some(CT_TableStyleInfo::new(e))
        _ => ()
      }
    }
  }
  {
    element,
    id: attr_int(element, "id", 0),
    name: attr(element, "name").unwrap_or(""),
    display_name: attr(element, "displayName").unwrap_or(""),
    comment: attr(element, "comment").unwrap_or(""),
    ref_range: attr(element, "ref").unwrap_or(""),
    header_row_count: attr_int(element, "headerRowCount", 1),
    totals_row_count: attr_int(element, "totalsRowCount", 0),
    totals_row_shown: attr_bool_schema(
      element, "totalsRowShown", true, "Part 1 §18.5.1.2", "table",
    ),
    table_type: attr(element, "tableType").unwrap_or("worksheet"),
    connection_id: attr_int(element, "connectionId", 0),
    published: attr_bool_schema(
      element, "published", false, "Part 1 §18.5.1.2", "table",
    ),
    insert_row: attr_bool_schema(
      element, "insertRow", false, "Part 1 §18.5.1.2", "table",
    ),
    insert_row_shift: attr_bool_schema(
      element, "insertRowShift", false, "Part 1 §18.5.1.2", "table",
    ),
    header_row_dxf_id: attr_int(element, "headerRowDxfId", -1),
    data_dxf_id: attr_int(element, "dataDxfId", -1),
    totals_row_dxf_id: attr_int(element, "totalsRowDxfId", -1),
    header_row_border_dxf_id: attr_int(element, "headerRowBorderDxfId", -1),
    table_border_dxf_id: attr_int(element, "tableBorderDxfId", -1),
    totals_row_border_dxf_id: attr_int(element, "totalsRowBorderDxfId", -1),
    header_row_cell_style: attr(element, "headerRowCellStyle").unwrap_or(""),
    data_cell_style: attr(element, "dataCellStyle").unwrap_or(""),
    totals_row_cell_style: attr(element, "totalsRowCellStyle").unwrap_or(""),
    table_columns,
    auto_filter,
    sort_state,
    table_style_info,
  }
}

///|
/// XSD complex type CT_TableColumns — Part 1 §18.5.1.4 (`<tableColumns>`).
/// `@count` + one or more `<tableColumn>` children.
pub(all) struct CT_TableColumns {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — number of columns; default 0.
  count : Int
  /// `<tableColumn>` (CT_TableColumn) children in document order.
  columns : Array[CT_TableColumn]
} derive(Eq, Debug)

///|
pub fn CT_TableColumns::new(
  element : @xml.Element,
) -> CT_TableColumns raise @opc_errors.SchemaViolation {
  let columns : Array[CT_TableColumn] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "tableColumn" {
      columns.push(CT_TableColumn::new(e))
    }
  }
  { element, count: attr_int(element, "count", 0), columns }
}

///|
/// XSD complex type CT_TableColumn — Part 1 §18.5.1.3 (`<tableColumn>`).
/// One column of a structured table: its id / name and optional
/// calculated-column / totals-row formulas.
pub(all) struct CT_TableColumn {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt) — column id; default 0.
  id : Int
  /// @name (ST_Xstring) — column header text.
  name : String
  /// @uniqueName (ST_Xstring) — optional unique name.
  unique_name : String
  /// @totalsRowFunction (ST_TotalsRowFunction) — default "none".
  totals_row_function : String
  /// @totalsRowLabel (ST_Xstring) — totals-row label text.
  totals_row_label : String
  /// @queryTableFieldId (xsd:unsignedInt) — query-table field; -1 absent.
  query_table_field_id : Int
  /// Style references (ST_DxfId / cell-style names); dxf-id -1 = absent.
  header_row_dxf_id : Int
  data_dxf_id : Int
  totals_row_dxf_id : Int
  header_row_cell_style : String
  data_cell_style : String
  totals_row_cell_style : String
  /// <xmlColumnPr> — optional XML mapping properties.
  xml_column_pr : CT_XmlColumnPr?
  /// <calculatedColumnFormula> — optional typed column formula.
  calculated_column_formula : CT_TableFormula?
  /// <totalsRowFormula> — optional typed totals-row formula.
  totals_row_formula : CT_TableFormula?
} derive(Eq, Debug)

///|
pub fn CT_TableColumn::new(
  element : @xml.Element,
) -> CT_TableColumn raise @opc_errors.SchemaViolation {
  let mut xml_column_pr : CT_XmlColumnPr? = None
  let mut calculated_column_formula : CT_TableFormula? = None
  let mut totals_row_formula : CT_TableFormula? = None
  for child in element.children {
    if child is @xml.Node::Element(e) {
      match e.name.local_name {
        "xmlColumnPr" => xml_column_pr = Some(CT_XmlColumnPr::new(e))
        "calculatedColumnFormula" =>
          calculated_column_formula = Some(CT_TableFormula::new(e))
        "totalsRowFormula" => totals_row_formula = Some(CT_TableFormula::new(e))
        _ => ()
      }
    }
  }
  {
    element,
    id: attr_int(element, "id", 0),
    name: attr(element, "name").unwrap_or(""),
    unique_name: attr(element, "uniqueName").unwrap_or(""),
    totals_row_function: attr(element, "totalsRowFunction").unwrap_or("none"),
    totals_row_label: attr(element, "totalsRowLabel").unwrap_or(""),
    query_table_field_id: attr_int(element, "queryTableFieldId", -1),
    header_row_dxf_id: attr_int(element, "headerRowDxfId", -1),
    data_dxf_id: attr_int(element, "dataDxfId", -1),
    totals_row_dxf_id: attr_int(element, "totalsRowDxfId", -1),
    header_row_cell_style: attr(element, "headerRowCellStyle").unwrap_or(""),
    data_cell_style: attr(element, "dataCellStyle").unwrap_or(""),
    totals_row_cell_style: attr(element, "totalsRowCellStyle").unwrap_or(""),
    xml_column_pr,
    calculated_column_formula,
    totals_row_formula,
  }
}

///|
/// XSD complex type CT_TableFormula — Part 1 §18.5.1.5
/// (`<calculatedColumnFormula>` / `<totalsRowFormula>`).  Holds the
/// formula text and the `@array` flag.
pub(all) struct CT_TableFormula {
  element : @xml.Element
  /// @array (xsd:boolean) — array formula flag; default false.
  array : Bool
  /// Element text — the formula string.
  formula : String
} derive(Eq, Debug)

///|
pub fn CT_TableFormula::new(
  element : @xml.Element,
) -> CT_TableFormula raise @opc_errors.SchemaViolation {
  {
    element,
    array: attr_bool_schema(
      element,
      "array",
      false,
      "Part 1 §18.5.1.5",
      element.name.local_name,
    ),
    formula: element_text(element),
  }
}

///|
/// XSD complex type CT_BookViews — Part 1 §18.2.2 (`<bookViews>`).  A
/// list of `<workbookView>` (CT_BookView) children.
pub(all) struct CT_BookViews {
  element : @xml.Element
  views : Array[CT_BookView]
} derive(Eq, Debug)

///|
pub fn CT_BookViews::new(element : @xml.Element) -> CT_BookViews {
  let views : Array[CT_BookView] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "workbookView" {
      views.push(CT_BookView::new(e))
    }
  }
  { element, views }
}

///|
/// XSD complex type CT_BookView — Part 1 §18.2.1 (`<workbookView>`).
/// One workbook-window view: which sheet tab is active, the first
/// visible tab, window geometry, and tab-bar / scrollbar visibility.
pub(all) struct CT_BookView {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @activeTab (xsd:unsignedInt) — 0-based active sheet tab; default 0.
  active_tab : Int
  /// @firstSheet (xsd:unsignedInt) — first visible tab; default 0.
  first_sheet : Int
  /// @showSheetTabs (xsd:boolean) — default true.
  show_sheet_tabs : Bool
  /// @showHorizontalScroll (xsd:boolean) — default true.
  show_horizontal_scroll : Bool
  /// @showVerticalScroll (xsd:boolean) — default true.
  show_vertical_scroll : Bool
  /// @minimized (xsd:boolean) — default false.
  minimized : Bool
  /// @visibility (ST_Visibility) — default "visible".
  visibility : String
  /// @xWindow / @yWindow (xsd:int) — window position; default 0.
  x_window : Int
  y_window : Int
  /// @windowWidth / @windowHeight (xsd:unsignedInt) — default 0.
  window_width : Int
  window_height : Int
  /// @tabRatio (xsd:unsignedInt) — sheet-tab / scrollbar split; default 600.
  tab_ratio : Int
  /// @autoFilterDateGrouping (xsd:boolean) — default true.
  auto_filter_date_grouping : Bool
} derive(Eq, Debug)

///|
pub fn CT_BookView::new(element : @xml.Element) -> CT_BookView {
  {
    element,
    active_tab: attr_int(element, "activeTab", 0),
    first_sheet: attr_int(element, "firstSheet", 0),
    show_sheet_tabs: attr_bool(element, "showSheetTabs", true),
    show_horizontal_scroll: attr_bool(element, "showHorizontalScroll", true),
    show_vertical_scroll: attr_bool(element, "showVerticalScroll", true),
    minimized: attr_bool(element, "minimized", false),
    visibility: attr(element, "visibility").unwrap_or("visible"),
    x_window: attr_int(element, "xWindow", 0),
    y_window: attr_int(element, "yWindow", 0),
    window_width: attr_int(element, "windowWidth", 0),
    window_height: attr_int(element, "windowHeight", 0),
    tab_ratio: attr_int(element, "tabRatio", 600),
    auto_filter_date_grouping: attr_bool(
      element, "autoFilterDateGrouping", true,
    ),
  }
}

///|
/// XSD complex type CT_CustomWorkbookViews — Part 1 §18.2.5
/// (`<customWorkbookViews>`).  A list of `<customWorkbookView>`
/// (CT_CustomWorkbookView) children.
pub(all) struct CT_CustomWorkbookViews {
  element : @xml.Element
  views : Array[CT_CustomWorkbookView]
} derive(Eq, Debug)

///|
pub fn CT_CustomWorkbookViews::new(
  element : @xml.Element,
) -> CT_CustomWorkbookViews {
  let views : Array[CT_CustomWorkbookView] = []
  for child in element.children {
    if child is @xml.Node::Element(e) &&
      e.name.local_name == "customWorkbookView" {
      views.push(CT_CustomWorkbookView::new(e))
    }
  }
  { element, views }
}

///|
/// XSD complex type CT_CustomWorkbookView — Part 1 §18.2.4
/// (`<customWorkbookView>`).  A named, GUID-identified custom view of
/// the workbook with its window geometry and active sheet.
pub(all) struct CT_CustomWorkbookView {
  element : @xml.Element
  /// @name (ST_Xstring) — required view name.
  name : String
  /// @guid (ST_Guid) — required view identifier.
  guid : String
  /// @activeSheetId (xsd:unsignedInt) — active sheet; default 0.
  active_sheet_id : Int
  /// @xWindow / @yWindow (xsd:int) — window position; default 0.
  x_window : Int
  y_window : Int
  /// @windowWidth / @windowHeight (xsd:unsignedInt) — default 0.
  window_width : Int
  window_height : Int
  /// @maximized (xsd:boolean) — default false.
  maximized : Bool
  /// @showHorizontalScroll / @showVerticalScroll / @showSheetTabs
  /// (xsd:boolean) — default true.
  show_horizontal_scroll : Bool
  show_vertical_scroll : Bool
  show_sheet_tabs : Bool
  /// @tabRatio (xsd:unsignedInt) — tab / scrollbar split; default 600.
  tab_ratio : Int
  /// @autoUpdate (xsd:boolean) — default false.
  auto_update : Bool
  /// @mergeInterval (xsd:unsignedInt) — auto-update interval; default 0.
  merge_interval : Int
  /// @changesSavedWin (xsd:boolean) — default false.
  changes_saved_win : Bool
  /// @onlySync (xsd:boolean) — default false.
  only_sync : Bool
  /// @personalView (xsd:boolean) — default false.
  personal_view : Bool
  /// @includePrintSettings (xsd:boolean) — default true.
  include_print_settings : Bool
  /// @includeHiddenRowCol (xsd:boolean) — default true.
  include_hidden_row_col : Bool
  /// @minimized (xsd:boolean) — default false.
  minimized : Bool
  /// @showComments (ST_Comments) — default "commIndicator".
  show_comments : String
  /// @showFormulaBar (xsd:boolean) — default true.
  show_formula_bar : Bool
  /// @showStatusbar (xsd:boolean) — default true.
  show_statusbar : Bool
  /// @showObjects (ST_Objects) — default "all".
  show_objects : String
} derive(Eq, Debug)

///|
pub fn CT_CustomWorkbookView::new(
  element : @xml.Element,
) -> CT_CustomWorkbookView {
  {
    element,
    name: attr(element, "name").unwrap_or(""),
    guid: attr(element, "guid").unwrap_or(""),
    active_sheet_id: attr_int(element, "activeSheetId", 0),
    x_window: attr_int(element, "xWindow", 0),
    y_window: attr_int(element, "yWindow", 0),
    window_width: attr_int(element, "windowWidth", 0),
    window_height: attr_int(element, "windowHeight", 0),
    maximized: attr_bool(element, "maximized", false),
    show_horizontal_scroll: attr_bool(element, "showHorizontalScroll", true),
    show_vertical_scroll: attr_bool(element, "showVerticalScroll", true),
    show_sheet_tabs: attr_bool(element, "showSheetTabs", true),
    tab_ratio: attr_int(element, "tabRatio", 600),
    auto_update: attr_bool(element, "autoUpdate", false),
    merge_interval: attr_int(element, "mergeInterval", 0),
    changes_saved_win: attr_bool(element, "changesSavedWin", false),
    only_sync: attr_bool(element, "onlySync", false),
    personal_view: attr_bool(element, "personalView", false),
    include_print_settings: attr_bool(element, "includePrintSettings", true),
    include_hidden_row_col: attr_bool(element, "includeHiddenRowCol", true),
    minimized: attr_bool(element, "minimized", false),
    show_comments: attr(element, "showComments").unwrap_or("commIndicator"),
    show_formula_bar: attr_bool(element, "showFormulaBar", true),
    show_statusbar: attr_bool(element, "showStatusbar", true),
    show_objects: attr(element, "showObjects").unwrap_or("all"),
  }
}

///|
/// XSD complex type CT_Sheets — Part 1 §18.2.20 (`<sheets>`).  The
/// workbook's ordered list of `<sheet>` (CT_Sheet) entries.
pub(all) struct CT_Sheets {
  element : @xml.Element
  sheets : Array[CT_Sheet]
} derive(Eq, Debug)

///|
pub fn CT_Sheets::new(element : @xml.Element) -> CT_Sheets {
  let sheets : Array[CT_Sheet] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "sheet" {
      sheets.push(CT_Sheet::new(e))
    }
  }
  { element, sheets }
}

///|
/// XSD complex type CT_Sheet — Part 1 §18.2.19 (`<sheet>`).  One entry
/// in the workbook's `<sheets>` list: the sheet's display `@name`, its
/// `@sheetId`, visibility `@state`, and the `r:id` relationship to the
/// sheet part.
pub(all) struct CT_Sheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (ST_Xstring) — sheet tab display name.
  name : String
  /// @sheetId (xsd:unsignedInt) — internal sheet id; default 0.
  sheet_id : Int
  /// @state (ST_SheetState) — "visible" (default) / "hidden" /
  /// "veryHidden".
  state : String
  /// @r:id (ST_RelationshipId) — relationship to the worksheet part.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_Sheet::new(element : @xml.Element) -> CT_Sheet {
  {
    element,
    name: attr(element, "name").unwrap_or(""),
    sheet_id: attr_int(element, "sheetId", 0),
    state: attr(element, "state").unwrap_or("visible"),
    r_id: attr(element, "id").unwrap_or(""),
  }
}

///|
/// XSD complex type CT_SheetBackgroundPicture — Part 1 §18.3.1.84
/// (`<picture>`).  References the worksheet background image part via
/// `r:id`.
pub(all) struct CT_SheetBackgroundPicture {
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — relationship to the image part.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_SheetBackgroundPicture::new(
  element : @xml.Element,
) -> CT_SheetBackgroundPicture {
  { element, r_id: attr(element, "id").unwrap_or("") }
}

///|
/// XSD complex type CT_WebPublishObjects — Part 1 §18.2.28.  A
/// `@count` plus a list of `<webPublishObject>` children.
pub(all) struct CT_WebPublishObjects {
  element : @xml.Element
  count : Int
  objects : Array[CT_WebPublishObject]
} derive(Eq, Debug)

///|
pub fn CT_WebPublishObjects::new(
  element : @xml.Element,
) -> CT_WebPublishObjects {
  let objects : Array[CT_WebPublishObject] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "webPublishObject" {
      objects.push(CT_WebPublishObject::new(e))
    }
  }
  { element, count: attr_int(element, "count", 0), objects }
}

///|
/// XSD complex type CT_WebPublishObject — Part 1 §18.2.27.  One object
/// published to a web page: its id, the source object name, the
/// destination file, and republish flag.
pub(all) struct CT_WebPublishObject {
  element : @xml.Element
  /// @id (xsd:unsignedInt) — required; default 0.
  id : Int
  /// @divId (ST_Xstring) — required HTML div id.
  div_id : String
  /// @sourceObject (ST_Xstring) — published object name; empty if absent.
  source_object : String
  /// @destinationFile (ST_Xstring) — required destination path.
  destination_file : String
  /// @title (ST_Xstring) — optional title.
  title : String
  /// @autoRepublish (xsd:boolean) — default false.
  auto_republish : Bool
} derive(Eq, Debug)

///|
pub fn CT_WebPublishObject::new(element : @xml.Element) -> CT_WebPublishObject {
  {
    element,
    id: attr_int(element, "id", 0),
    div_id: attr(element, "divId").unwrap_or(""),
    source_object: attr(element, "sourceObject").unwrap_or(""),
    destination_file: attr(element, "destinationFile").unwrap_or(""),
    title: attr(element, "title").unwrap_or(""),
    auto_republish: attr_bool(element, "autoRepublish", false),
  }
}
