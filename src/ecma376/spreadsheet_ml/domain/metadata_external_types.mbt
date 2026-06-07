///|
/// SpreadsheetML metadata, external-link, and XML-mapping typed domain
/// wrappers from sml.xsd. CT_X identifiers in this file bind the
/// ECMA-376 Part 1 §18.5 / §18.9 / §18.11 / §18.14 / §18.15 / §18.16
/// complex types with typed attribute and child fields. The source
/// `@xml.Element` is preserved on every record so the builder can emit
/// byte-identical round-trip output via `value.element`.

///|
pub fn metadata_external_type_group_name() -> String {
  "spreadsheet_ml.metadata_external"
}

///|
/// XSD complex type CT_MapInfo — Part 1 §18.16.3. Schema sml.xsd complex
/// type `CT_MapInfo`. Attributes: `SelectionNamespaces`. Child elements:
/// `Schema`, `Map`. Child types: `CT_Schema`, `CT_Map`. XML mapping
/// wrapper with required `SelectionNamespaces` attribute and unbounded
/// child sequences `<Schema>` (CT_Schema) and `<Map>` (CT_Map).
pub(all) struct CT_MapInfo {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @SelectionNamespaces (xsd:string) — required.
  selection_namespaces : String
  /// <Schema>+ (CT_Schema) — one or more.
  schemas : Array[CT_Schema]
  /// <Map>+ (CT_Map) — one or more.
  maps : Array[CT_Map]
} derive(Eq, Debug)

///|
pub fn CT_MapInfo::new(
  element : @xml.Element,
) -> CT_MapInfo raise @opc_errors.SchemaViolation {
  let selection_namespaces = match attr(element, "SelectionNamespaces") {
    Some(value) => value
    None => ""
  }
  let schemas : Array[CT_Schema] = []
  let maps : Array[CT_Map] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "Schema" => schemas.push(CT_Schema::new(child_element))
        "Map" => maps.push(CT_Map::new(child_element))
        _ => ()
      }
    }
  }
  { element, selection_namespaces, schemas, maps }
}

///|
/// XSD complex type CT_Schema — Part 1 §18.16.4. Schema sml.xsd complex
/// type `CT_Schema`. Attributes: `ID`, `SchemaRef`, `Namespace`,
/// `SchemaLanguage`.
pub(all) struct CT_Schema {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ID (xsd:string) — required.
  id : String
  /// @SchemaRef (xsd:string) — optional.
  schema_ref : String?
  /// @Namespace (xsd:string) — optional.
  ns : String?
  /// @SchemaLanguage (xsd:token) — optional.
  schema_language : String?
} derive(Eq, Debug)

///|
pub fn CT_Schema::new(element : @xml.Element) -> CT_Schema {
  let id = match attr(element, "ID") {
    Some(value) => value
    None => ""
  }
  {
    element,
    id,
    schema_ref: attr(element, "SchemaRef"),
    ns: attr(element, "Namespace"),
    schema_language: attr(element, "SchemaLanguage"),
  }
}

///|
/// XSD complex type CT_Map — Part 1 §18.16.2. Custom XML map. Required
/// attributes `ID` (xsd:unsignedInt), `Name`, `RootElement`, `SchemaID`
/// (xsd:string), and boolean flags `ShowImportExportValidationErrors`,
/// `AutoFit`, `Append`, `PreserveSortAFLayout`, `PreserveFormat`.
/// Optional `<DataBinding>` child (CT_DataBinding).
pub(all) struct CT_Map {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ID (xsd:unsignedInt) — required.
  id : Int
  /// @Name (xsd:string) — required.
  name : String
  /// @RootElement (xsd:string) — required.
  root_element : String
  /// @SchemaID (xsd:string) — required.
  schema_id : String
  /// @ShowImportExportValidationErrors (xsd:boolean) — required.
  show_import_export_validation_errors : Bool
  /// @AutoFit (xsd:boolean) — required.
  auto_fit : Bool
  /// @Append (xsd:boolean) — required.
  append : Bool
  /// @PreserveSortAFLayout (xsd:boolean) — required.
  preserve_sort_af_layout : Bool
  /// @PreserveFormat (xsd:boolean) — required.
  preserve_format : Bool
  /// <DataBinding> (CT_DataBinding) — optional.
  data_binding : CT_DataBinding?
} derive(Eq, Debug)

///|
pub fn CT_Map::new(
  element : @xml.Element,
) -> CT_Map raise @opc_errors.SchemaViolation {
  let id = attr_uint_schema(element, "ID", 0)
  let name = match attr(element, "Name") {
    Some(v) => v
    None => ""
  }
  let root_element = match attr(element, "RootElement") {
    Some(v) => v
    None => ""
  }
  let schema_id = match attr(element, "SchemaID") {
    Some(v) => v
    None => ""
  }
  let show_import_export_validation_errors = attr_bool_schema(
    element, "ShowImportExportValidationErrors", false, "Part 1 §18.16.2", "Map",
  )
  let auto_fit = attr_bool_schema(
    element, "AutoFit", false, "Part 1 §18.16.2", "Map",
  )
  let append = attr_bool_schema(
    element, "Append", false, "Part 1 §18.16.2", "Map",
  )
  let preserve_sort_af_layout = attr_bool_schema(
    element, "PreserveSortAFLayout", false, "Part 1 §18.16.2", "Map",
  )
  let preserve_format = attr_bool_schema(
    element, "PreserveFormat", false, "Part 1 §18.16.2", "Map",
  )
  let mut data_binding : CT_DataBinding? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "DataBinding" {
        data_binding = Some(CT_DataBinding::new(child_element))
      }
    }
  }
  {
    element,
    id,
    name,
    root_element,
    schema_id,
    show_import_export_validation_errors,
    auto_fit,
    append,
    preserve_sort_af_layout,
    preserve_format,
    data_binding,
  }
}

///|
/// XSD complex type CT_Boolean — Part 1 §18.10.1.2 (b). PivotTable shared
/// boolean carrier: required `@v` (xsd:boolean) and optional `@u`, `@f`
/// (xsd:boolean), `@c` (s:ST_Xstring), `@cp` (xsd:unsignedInt). Sequence
/// holds optional repeated `<x>` (CT_X) child indices.
pub(all) struct CT_Boolean {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @v (xsd:boolean) — required.
  v : Bool
  /// @u (xsd:boolean) — optional.
  u : Bool?
  /// @f (xsd:boolean) — optional.
  f : Bool?
  /// @c (s:ST_Xstring) — optional caption.
  c : String?
  /// @cp (xsd:unsignedInt) — optional property index.
  cp : Int?
  /// <x>* (CT_X) — zero or more pivot tuple indices.
  x : Array[CT_X]
} derive(Eq, Debug)

///|
pub fn CT_Boolean::new(
  element : @xml.Element,
) -> CT_Boolean raise @opc_errors.SchemaViolation {
  let v = attr_bool_schema(element, "v", false, "Part 1 §18.10.1.2", "b")
  let u = attr_bool_schema_opt(element, "u", "Part 1 §18.10.1.2", "b")
  let f = attr_bool_schema_opt(element, "f", "Part 1 §18.10.1.2", "b")
  let c = attr(element, "c")
  let cp = attr_uint_opt_schema(element, "cp")
  let x : Array[CT_X] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "x" {
        x.push(CT_X::new(child_element))
      }
    }
  }
  { element, v, u, f, c, cp, x }
}

///|
/// XSD complex type CT_SheetIdMap — Part 1 §18.11.1.24. Sheet-id map used
/// in revision logs. Optional `@count` (xsd:unsignedInt) and one or more
/// `<sheetId>` (CT_SheetId) child entries.
pub(all) struct CT_SheetIdMap {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <sheetId>+ (CT_SheetId) — one or more.
  sheet_ids : Array[CT_SheetId]
} derive(Eq, Debug)

///|
pub fn CT_SheetIdMap::new(
  element : @xml.Element,
) -> CT_SheetIdMap raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
  let sheet_ids : Array[CT_SheetId] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "sheetId" {
        sheet_ids.push(CT_SheetId::new(child_element))
      }
    }
  }
  { element, count, sheet_ids }
}

///|
/// XSD complex type CT_OleObjects — Part 1 §18.3.1.60. Worksheet OLE-object
/// container: one or more `<oleObject>` (CT_OleObject) children.
pub(all) struct CT_OleObjects {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <oleObject>+ (CT_OleObject) — one or more.
  ole_objects : Array[CT_OleObject]
} derive(Eq, Debug)

///|
pub fn CT_OleObjects::new(
  element : @xml.Element,
) -> CT_OleObjects raise @opc_errors.SchemaViolation {
  let ole_objects : Array[CT_OleObject] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "oleObject" {
        ole_objects.push(CT_OleObject::new(child_element))
      }
    }
  }
  { element, ole_objects }
}

///|
/// XSD complex type CT_OleObject — Part 1 §18.3.1.59. Embedded OLE object
/// descriptor. Required `@shapeId` (xsd:unsignedInt); optional `@progId`
/// (xsd:string), `@dvAspect` (ST_DvAspect, default DVASPECT_CONTENT),
/// `@link` (s:ST_Xstring), `@oleUpdate` (ST_OleUpdate), `@autoLoad`
/// (xsd:boolean, default false), and `@r:id`. Optional `<objectPr>` child
/// (CT_ObjectPr).
pub(all) struct CT_OleObject {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @progId (xsd:string) — optional.
  prog_id : String?
  /// @dvAspect (ST_DvAspect) — optional, default DVASPECT_CONTENT.
  dv_aspect : String?
  /// @link (s:ST_Xstring) — optional.
  link : String?
  /// @oleUpdate (ST_OleUpdate) — optional.
  ole_update : String?
  /// @autoLoad (xsd:boolean) — optional, default false.
  auto_load : Bool
  /// @shapeId (xsd:unsignedInt) — required.
  shape_id : Int
  /// @r:id (relationship id) — optional.
  r_id : String?
  /// <objectPr> (CT_ObjectPr) — optional.
  object_pr : CT_ObjectPr?
} derive(Eq, Debug)

///|
pub fn CT_OleObject::new(
  element : @xml.Element,
) -> CT_OleObject raise @opc_errors.SchemaViolation {
  let prog_id = attr(element, "progId")
  let dv_aspect = attr(element, "dvAspect")
  let link = attr(element, "link")
  let ole_update = attr(element, "oleUpdate")
  let auto_load = attr_bool_schema(
    element, "autoLoad", false, "Part 1 §18.3.1.59", "oleObject",
  )
  let shape_id = attr_uint_schema(element, "shapeId", 0)
  let r_id = attr_with_ns(element, "id")
  let mut object_pr : CT_ObjectPr? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "objectPr" {
        object_pr = Some(CT_ObjectPr::new(child_element))
      }
    }
  }
  {
    element,
    prog_id,
    dv_aspect,
    link,
    ole_update,
    auto_load,
    shape_id,
    r_id,
    object_pr,
  }
}

///|
/// XSD complex type CT_Metadata — Part 1 §18.9.8. Workbook metadata root.
/// Optional ordered children: `<metadataTypes>` (CT_MetadataTypes),
/// `<metadataStrings>` (CT_MetadataStrings), `<mdxMetadata>`
/// (CT_MdxMetadata), `<futureMetadata>*` (CT_FutureMetadata),
/// `<cellMetadata>` (CT_MetadataBlocks), `<valueMetadata>` (CT_MetadataBlocks),
/// and `<extLst>` (CT_ExtensionList).
pub(all) struct CT_Metadata {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <metadataTypes> (CT_MetadataTypes) — optional.
  metadata_types : CT_MetadataTypes?
  /// <metadataStrings> (CT_MetadataStrings) — optional.
  metadata_strings : CT_MetadataStrings?
  /// <mdxMetadata> (CT_MdxMetadata) — optional.
  mdx_metadata : CT_MdxMetadata?
  /// <futureMetadata>* (CT_FutureMetadata) — zero or more.
  future_metadata : Array[CT_FutureMetadata]
  /// <cellMetadata> (CT_MetadataBlocks) — optional.
  cell_metadata : CT_MetadataBlocks?
  /// <valueMetadata> (CT_MetadataBlocks) — optional.
  value_metadata : CT_MetadataBlocks?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Metadata::new(
  element : @xml.Element,
) -> CT_Metadata raise @opc_errors.SchemaViolation {
  let mut metadata_types : CT_MetadataTypes? = None
  let mut metadata_strings : CT_MetadataStrings? = None
  let mut mdx_metadata : CT_MdxMetadata? = None
  let future_metadata : Array[CT_FutureMetadata] = []
  let mut cell_metadata : CT_MetadataBlocks? = None
  let mut value_metadata : CT_MetadataBlocks? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "metadataTypes" =>
          metadata_types = Some(CT_MetadataTypes::new(child_element))
        "metadataStrings" =>
          metadata_strings = Some(CT_MetadataStrings::new(child_element))
        "mdxMetadata" => mdx_metadata = Some(CT_MdxMetadata::new(child_element))
        "futureMetadata" =>
          future_metadata.push(CT_FutureMetadata::new(child_element))
        "cellMetadata" =>
          cell_metadata = Some(CT_MetadataBlocks::new(child_element))
        "valueMetadata" =>
          value_metadata = Some(CT_MetadataBlocks::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    metadata_types,
    metadata_strings,
    mdx_metadata,
    future_metadata,
    cell_metadata,
    value_metadata,
    ext_lst,
  }
}

///|
/// XSD complex type CT_MetadataTypes — Part 1 §18.9.11. Optional `@count`
/// (xsd:unsignedInt, default 0) and one or more `<metadataType>` children.
pub(all) struct CT_MetadataTypes {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
  /// <metadataType>+ (CT_MetadataType) — one or more.
  metadata_types : Array[CT_MetadataType]
} derive(Eq, Debug)

///|
pub fn CT_MetadataTypes::new(
  element : @xml.Element,
) -> CT_MetadataTypes raise @opc_errors.SchemaViolation {
  let count = attr_uint_schema(element, "count", 0)
  let metadata_types : Array[CT_MetadataType] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "metadataType" {
        metadata_types.push(CT_MetadataType::new(child_element))
      }
    }
  }
  { element, count, metadata_types }
}

///|
/// XSD complex type CT_MetadataType — Part 1 §18.9.10. Required `@name`
/// (s:ST_Xstring) and `@minSupportedVersion` (xsd:unsignedInt); twenty-six
/// optional xsd:boolean flags (default false) covering metadata operation
/// behaviours (`ghostRow`, `ghostCol`, `edit`, `delete`, `copy`,
/// `pasteAll`, `pasteFormulas`, `pasteValues`, `pasteFormats`,
/// `pasteComments`, `pasteDataValidation`, `pasteBorders`,
/// `pasteColWidths`, `pasteNumberFormats`, `merge`, `splitFirst`,
/// `splitAll`, `rowColShift`, `clearAll`, `clearFormats`, `clearContents`,
/// `clearComments`, `assign`, `coerce`, `adjust`, `cellMeta`).
pub(all) struct CT_MetadataType {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required.
  name : String
  /// @minSupportedVersion (xsd:unsignedInt) — required.
  min_supported_version : Int
  /// @ghostRow (xsd:boolean) — optional, default false.
  ghost_row : Bool
  /// @ghostCol (xsd:boolean) — optional, default false.
  ghost_col : Bool
  /// @edit (xsd:boolean) — optional, default false.
  edit : Bool
  /// @delete (xsd:boolean) — optional, default false.
  delete : Bool
  /// @copy (xsd:boolean) — optional, default false.
  copy : Bool
  /// @pasteAll (xsd:boolean) — optional, default false.
  paste_all : Bool
  /// @pasteFormulas (xsd:boolean) — optional, default false.
  paste_formulas : Bool
  /// @pasteValues (xsd:boolean) — optional, default false.
  paste_values : Bool
  /// @pasteFormats (xsd:boolean) — optional, default false.
  paste_formats : Bool
  /// @pasteComments (xsd:boolean) — optional, default false.
  paste_comments : Bool
  /// @pasteDataValidation (xsd:boolean) — optional, default false.
  paste_data_validation : Bool
  /// @pasteBorders (xsd:boolean) — optional, default false.
  paste_borders : Bool
  /// @pasteColWidths (xsd:boolean) — optional, default false.
  paste_col_widths : Bool
  /// @pasteNumberFormats (xsd:boolean) — optional, default false.
  paste_number_formats : Bool
  /// @merge (xsd:boolean) — optional, default false.
  merge : Bool
  /// @splitFirst (xsd:boolean) — optional, default false.
  split_first : Bool
  /// @splitAll (xsd:boolean) — optional, default false.
  split_all : Bool
  /// @rowColShift (xsd:boolean) — optional, default false.
  row_col_shift : Bool
  /// @clearAll (xsd:boolean) — optional, default false.
  clear_all : Bool
  /// @clearFormats (xsd:boolean) — optional, default false.
  clear_formats : Bool
  /// @clearContents (xsd:boolean) — optional, default false.
  clear_contents : Bool
  /// @clearComments (xsd:boolean) — optional, default false.
  clear_comments : Bool
  /// @assign (xsd:boolean) — optional, default false.
  assign : Bool
  /// @coerce (xsd:boolean) — optional, default false.
  coerce : Bool
  /// @adjust (xsd:boolean) — optional, default false.
  adjust : Bool
  /// @cellMeta (xsd:boolean) — optional, default false.
  cell_meta : Bool
} derive(Eq, Debug)

///|
pub fn CT_MetadataType::new(
  element : @xml.Element,
) -> CT_MetadataType raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let min_supported_version = attr_uint_schema(
    element, "minSupportedVersion", 0,
  )
  {
    element,
    name,
    min_supported_version,
    ghost_row: attr_bool_strict(element, "ghostRow", false),
    ghost_col: attr_bool_strict(element, "ghostCol", false),
    edit: attr_bool_strict(element, "edit", false),
    delete: attr_bool_strict(element, "delete", false),
    copy: attr_bool_strict(element, "copy", false),
    paste_all: attr_bool_strict(element, "pasteAll", false),
    paste_formulas: attr_bool_strict(element, "pasteFormulas", false),
    paste_values: attr_bool_strict(element, "pasteValues", false),
    paste_formats: attr_bool_strict(element, "pasteFormats", false),
    paste_comments: attr_bool_strict(element, "pasteComments", false),
    paste_data_validation: attr_bool_strict(
      element, "pasteDataValidation", false,
    ),
    paste_borders: attr_bool_strict(element, "pasteBorders", false),
    paste_col_widths: attr_bool_strict(element, "pasteColWidths", false),
    paste_number_formats: attr_bool_strict(element, "pasteNumberFormats", false),
    merge: attr_bool_strict(element, "merge", false),
    split_first: attr_bool_strict(element, "splitFirst", false),
    split_all: attr_bool_strict(element, "splitAll", false),
    row_col_shift: attr_bool_strict(element, "rowColShift", false),
    clear_all: attr_bool_strict(element, "clearAll", false),
    clear_formats: attr_bool_strict(element, "clearFormats", false),
    clear_contents: attr_bool_strict(element, "clearContents", false),
    clear_comments: attr_bool_strict(element, "clearComments", false),
    assign: attr_bool_strict(element, "assign", false),
    coerce: attr_bool_strict(element, "coerce", false),
    adjust: attr_bool_strict(element, "adjust", false),
    cell_meta: attr_bool_strict(element, "cellMeta", false),
  }
}

///|
/// XSD complex type CT_MetadataBlocks — Part 1 §18.9.3 (cellMetadata
/// element). Optional `@count` (xsd:unsignedInt, default 0) and one or
/// more `<bk>` (CT_MetadataBlock) children.
pub(all) struct CT_MetadataBlocks {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
  /// <bk>+ (CT_MetadataBlock) — one or more.
  blocks : Array[CT_MetadataBlock]
} derive(Eq, Debug)

///|
pub fn CT_MetadataBlocks::new(
  element : @xml.Element,
) -> CT_MetadataBlocks raise @opc_errors.SchemaViolation {
  let count = attr_uint_schema(element, "count", 0)
  let blocks : Array[CT_MetadataBlock] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "bk" {
        blocks.push(CT_MetadataBlock::new(child_element))
      }
    }
  }
  { element, count, blocks }
}

///|
/// XSD complex type CT_MetadataBlock — Part 1 §18.9.1 (bk Metadata
/// Block). Required sequence of one or more `<rc>` (CT_MetadataRecord)
/// children.
pub(all) struct CT_MetadataBlock {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <rc>+ (CT_MetadataRecord) — one or more.
  records : Array[CT_MetadataRecord]
} derive(Eq, Debug)

///|
pub fn CT_MetadataBlock::new(
  element : @xml.Element,
) -> CT_MetadataBlock raise @opc_errors.SchemaViolation {
  let records : Array[CT_MetadataRecord] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "rc" {
        records.push(CT_MetadataRecord::new(child_element))
      }
    }
  }
  { element, records }
}

///|
/// XSD complex type CT_MetadataRecord — Part 1 §18.9.15 (rc). Required
/// attributes `@t` (xsd:unsignedInt, metadata-type index) and `@v`
/// (xsd:unsignedInt, value-store index).
pub(all) struct CT_MetadataRecord {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @t (xsd:unsignedInt) — required.
  t : Int
  /// @v (xsd:unsignedInt) — required.
  v : Int
} derive(Eq, Debug)

///|
pub fn CT_MetadataRecord::new(
  element : @xml.Element,
) -> CT_MetadataRecord raise @opc_errors.SchemaViolation {
  let t = attr_uint_schema(element, "t", 0)
  let v = attr_uint_schema(element, "v", 0)
  { element, t, v }
}

///|
/// XSD complex type CT_FutureMetadata — Part 1 §18.9.4. Forward-compat
/// metadata-block bundle. Required `@name` (s:ST_Xstring); optional
/// `@count` (xsd:unsignedInt, default 0). Children: zero or more `<bk>`
/// (CT_FutureMetadataBlock) plus an optional `<extLst>`.
pub(all) struct CT_FutureMetadata {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required.
  name : String
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
  /// <bk>* (CT_FutureMetadataBlock) — zero or more.
  blocks : Array[CT_FutureMetadataBlock]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_FutureMetadata::new(
  element : @xml.Element,
) -> CT_FutureMetadata raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let count = attr_uint_schema(element, "count", 0)
  let blocks : Array[CT_FutureMetadataBlock] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "bk" => blocks.push(CT_FutureMetadataBlock::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, name, count, blocks, ext_lst }
}

///|
/// XSD complex type CT_FutureMetadataBlock — Part 1 §18.9.2 (bk Future
/// Metadata Block). Single optional `<extLst>` child carrying the
/// extension payload; no attributes.
pub(all) struct CT_FutureMetadataBlock {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_FutureMetadataBlock::new(
  element : @xml.Element,
) -> CT_FutureMetadataBlock {
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  { element, ext_lst }
}

///|
/// XSD complex type CT_MetadataStringIndex — Part 1 §18.9.13 (n Member
/// Unique Name Index). Required `@x` (xsd:unsignedInt, index into the
/// metadataStrings store); optional `@s` (xsd:boolean, default false,
/// "string store" flag).
pub(all) struct CT_MetadataStringIndex {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @x (xsd:unsignedInt) — required.
  x : Int
  /// @s (xsd:boolean) — optional, default false.
  s : Bool
} derive(Eq, Debug)

///|
pub fn CT_MetadataStringIndex::new(
  element : @xml.Element,
) -> CT_MetadataStringIndex raise @opc_errors.SchemaViolation {
  let x = attr_uint_schema(element, "x", 0)
  let s = attr_bool_schema(element, "s", false, "Part 1 §18.9.13", "n")
  { element, x, s }
}

///|
/// XSD complex type CT_MetadataStrings — Part 1 §18.9.9. Metadata string
/// store. Optional `@count` (xsd:unsignedInt, default 0) and one or more
/// `<s>` (CT_XStringElement) children.
pub(all) struct CT_MetadataStrings {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
  /// <s>+ (CT_XStringElement) — one or more.
  strings : Array[CT_XStringElement]
} derive(Eq, Debug)

///|
pub fn CT_MetadataStrings::new(
  element : @xml.Element,
) -> CT_MetadataStrings raise @opc_errors.SchemaViolation {
  let count = attr_uint_schema(element, "count", 0)
  let strings : Array[CT_XStringElement] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "s" {
        strings.push(CT_XStringElement::new(child_element))
      }
    }
  }
  { element, count, strings }
}

///|
/// XSD complex type CT_SingleXmlCells — Part 1 §18.5.2.2. Unbounded
/// sequence of `<singleXmlCell>` (CT_SingleXmlCell) children.
pub(all) struct CT_SingleXmlCells {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <singleXmlCell>* (CT_SingleXmlCell) — zero or more (XSD maxOccurs=unbounded).
  single_xml_cells : Array[CT_SingleXmlCell]
} derive(Eq, Debug)

///|
pub fn CT_SingleXmlCells::new(
  element : @xml.Element,
) -> CT_SingleXmlCells raise @opc_errors.SchemaViolation {
  let single_xml_cells : Array[CT_SingleXmlCell] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "singleXmlCell" {
        single_xml_cells.push(CT_SingleXmlCell::new(child_element))
      }
    }
  }
  { element, single_xml_cells }
}

///|
/// XSD complex type CT_SingleXmlCell — Part 1 §18.5.2.1. Single-cell XML
/// map binding. Required `@id` (xsd:unsignedInt), `@r` (ST_CellRef),
/// `@connectionId` (xsd:unsignedInt). Children: required `<xmlCellPr>`
/// (CT_XmlCellPr) and optional `<extLst>` (CT_ExtensionList).
pub(all) struct CT_SingleXmlCell {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt) — required.
  id : Int
  /// @r (ST_CellRef) — required.
  r : String
  /// @connectionId (xsd:unsignedInt) — required.
  connection_id : Int
  /// <xmlCellPr> (CT_XmlCellPr) — required.
  xml_cell_pr : CT_XmlCellPr?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SingleXmlCell::new(
  element : @xml.Element,
) -> CT_SingleXmlCell raise @opc_errors.SchemaViolation {
  let id = attr_uint_schema(element, "id", 0)
  let r = match attr(element, "r") {
    Some(v) => v
    None => ""
  }
  let connection_id = attr_uint_schema(element, "connectionId", 0)
  let mut xml_cell_pr : CT_XmlCellPr? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "xmlCellPr" => xml_cell_pr = Some(CT_XmlCellPr::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, id, r, connection_id, xml_cell_pr, ext_lst }
}

///|
/// XSD complex type CT_XmlCellPr — Part 1 §18.5.2.3 (xmlCellPr Cell
/// Properties). Required `@id` (xsd:unsignedInt); optional `@uniqueName`
/// (s:ST_Xstring). Children: required `<xmlPr>` (CT_XmlPr) and optional
/// `<extLst>` (CT_ExtensionList).
pub(all) struct CT_XmlCellPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt) — required.
  id : Int
  /// @uniqueName (s:ST_Xstring) — optional.
  unique_name : String?
  /// <xmlPr> (CT_XmlPr) — required.
  xml_pr : CT_XmlPr?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_XmlCellPr::new(
  element : @xml.Element,
) -> CT_XmlCellPr raise @opc_errors.SchemaViolation {
  let id = attr_uint_schema(element, "id", 0)
  let unique_name = attr(element, "uniqueName")
  let mut xml_pr : CT_XmlPr? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "xmlPr" => xml_pr = Some(CT_XmlPr::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, id, unique_name, xml_pr, ext_lst }
}

///|
/// XSD complex type CT_XmlPr — Part 1 §18.5.2.4 (xmlPr Column XML
/// Properties). Required `@mapId` (xsd:unsignedInt), `@xpath`
/// (s:ST_Xstring), `@xmlDataType` (ST_XmlDataType). Optional `<extLst>`
/// (CT_ExtensionList) child.
pub(all) struct CT_XmlPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @mapId (xsd:unsignedInt) — required.
  map_id : Int
  /// @xpath (s:ST_Xstring) — required.
  xpath : String
  /// @xmlDataType (ST_XmlDataType) — required.
  xml_data_type : String
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_XmlPr::new(
  element : @xml.Element,
) -> CT_XmlPr raise @opc_errors.SchemaViolation {
  let map_id = attr_uint_schema(element, "mapId", 0)
  let xpath = match attr(element, "xpath") {
    Some(v) => v
    None => ""
  }
  let xml_data_type = match attr(element, "xmlDataType") {
    Some(v) => v
    None => ""
  }
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  { element, map_id, xpath, xml_data_type, ext_lst }
}

///|
/// XSD complex type CT_ExternalLink — Part 1 §18.14.8 (externalLink
/// External Reference). xsd:choice between `<externalBook>`
/// (CT_ExternalBook), `<ddeLink>` (CT_DdeLink), and `<oleLink>`
/// (CT_OleLink); plus optional `<extLst>` (CT_ExtensionList).
pub(all) struct CT_ExternalLink {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <externalBook> (CT_ExternalBook) — choice option.
  external_book : CT_ExternalBook?
  /// <ddeLink> (CT_DdeLink) — choice option.
  dde_link : CT_DdeLink?
  /// <oleLink> (CT_OleLink) — choice option.
  ole_link : CT_OleLink?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ExternalLink::new(
  element : @xml.Element,
) -> CT_ExternalLink raise @opc_errors.SchemaViolation {
  let mut external_book : CT_ExternalBook? = None
  let mut dde_link : CT_DdeLink? = None
  let mut ole_link : CT_OleLink? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "externalBook" =>
          external_book = Some(CT_ExternalBook::new(child_element))
        "ddeLink" => dde_link = Some(CT_DdeLink::new(child_element))
        "oleLink" => ole_link = Some(CT_OleLink::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, external_book, dde_link, ole_link, ext_lst }
}

///|
/// XSD complex type CT_ExternalBook — Part 1 §18.14.7. Required `@r:id`
/// reference to the linked workbook part. Optional children
/// `<sheetNames>` (CT_ExternalSheetNames), `<definedNames>`
/// (CT_ExternalDefinedNames), and `<sheetDataSet>`
/// (CT_ExternalSheetDataSet).
pub(all) struct CT_ExternalBook {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (relationship id) — required.
  r_id : String
  /// <sheetNames> (CT_ExternalSheetNames) — optional.
  sheet_names : CT_ExternalSheetNames?
  /// <definedNames> (CT_ExternalDefinedNames) — optional.
  defined_names : CT_ExternalDefinedNames?
  /// <sheetDataSet> (CT_ExternalSheetDataSet) — optional.
  sheet_data_set : CT_ExternalSheetDataSet?
} derive(Eq, Debug)

///|
pub fn CT_ExternalBook::new(
  element : @xml.Element,
) -> CT_ExternalBook raise @opc_errors.SchemaViolation {
  let r_id = match attr_with_ns(element, "id") {
    Some(v) => v
    None => ""
  }
  let mut sheet_names : CT_ExternalSheetNames? = None
  let mut defined_names : CT_ExternalDefinedNames? = None
  let mut sheet_data_set : CT_ExternalSheetDataSet? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sheetNames" =>
          sheet_names = Some(CT_ExternalSheetNames::new(child_element))
        "definedNames" =>
          defined_names = Some(CT_ExternalDefinedNames::new(child_element))
        "sheetDataSet" =>
          sheet_data_set = Some(CT_ExternalSheetDataSet::new(child_element))
        _ => ()
      }
    }
  }
  { element, r_id, sheet_names, defined_names, sheet_data_set }
}

///|
/// XSD complex type CT_ExternalSheetNames — Part 1 §18.14.16
/// (sheetNames Supporting Workbook Sheet Names). One or more
/// `<sheetName>` (CT_ExternalSheetName) children.
pub(all) struct CT_ExternalSheetNames {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sheetName>+ (CT_ExternalSheetName) — one or more.
  sheet_names : Array[CT_ExternalSheetName]
} derive(Eq, Debug)

///|
pub fn CT_ExternalSheetNames::new(
  element : @xml.Element,
) -> CT_ExternalSheetNames {
  let sheet_names : Array[CT_ExternalSheetName] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "sheetName" {
        sheet_names.push(CT_ExternalSheetName::new(child_element))
      }
    }
  }
  { element, sheet_names }
}

///|
/// XSD complex type CT_ExternalSheetName — Part 1 §18.14.15 (sheetName
/// Sheet Name). Single optional `@val` (s:ST_Xstring) attribute carrying
/// the linked sheet name.
pub(all) struct CT_ExternalSheetName {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (s:ST_Xstring) — optional.
  val : String?
} derive(Eq, Debug)

///|
pub fn CT_ExternalSheetName::new(
  element : @xml.Element,
) -> CT_ExternalSheetName {
  let val = attr(element, "val")
  { element, val }
}

///|
/// XSD complex type CT_ExternalDefinedNames — Part 1 §18.14.6
/// (definedNames Named Links). Zero or more `<definedName>`
/// (CT_ExternalDefinedName) children.
pub(all) struct CT_ExternalDefinedNames {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <definedName>* (CT_ExternalDefinedName) — zero or more.
  defined_names : Array[CT_ExternalDefinedName]
} derive(Eq, Debug)

///|
pub fn CT_ExternalDefinedNames::new(
  element : @xml.Element,
) -> CT_ExternalDefinedNames raise @opc_errors.SchemaViolation {
  let defined_names : Array[CT_ExternalDefinedName] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "definedName" {
        defined_names.push(CT_ExternalDefinedName::new(child_element))
      }
    }
  }
  { element, defined_names }
}

///|
/// XSD complex type CT_ExternalDefinedName — Part 1 §18.14.5
/// (definedName Defined Name). Required `@name` (s:ST_Xstring); optional
/// `@refersTo` (s:ST_Xstring) and `@sheetId` (xsd:unsignedInt).
pub(all) struct CT_ExternalDefinedName {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required.
  name : String
  /// @refersTo (s:ST_Xstring) — optional.
  refers_to : String?
  /// @sheetId (xsd:unsignedInt) — optional.
  sheet_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_ExternalDefinedName::new(
  element : @xml.Element,
) -> CT_ExternalDefinedName raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let refers_to = attr(element, "refersTo")
  let sheet_id = attr_uint_opt_schema(element, "sheetId")
  { element, name, refers_to, sheet_id }
}

///|
/// XSD complex type CT_ExternalSheetData — Part 1 §18.14.13 (sheetData
/// External Sheet Data Set). Required `@sheetId` (xsd:unsignedInt) and
/// optional `@refreshError` (xsd:boolean, default false); zero or more
/// `<row>` (CT_ExternalRow) children.
pub(all) struct CT_ExternalSheetData {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @sheetId (xsd:unsignedInt) — required.
  sheet_id : Int
  /// @refreshError (xsd:boolean) — optional, default false.
  refresh_error : Bool
  /// <row>* (CT_ExternalRow) — zero or more.
  rows : Array[CT_ExternalRow]
} derive(Eq, Debug)

///|
pub fn CT_ExternalSheetData::new(
  element : @xml.Element,
) -> CT_ExternalSheetData raise @opc_errors.SchemaViolation {
  let sheet_id = attr_uint_schema(element, "sheetId", 0)
  let refresh_error = attr_bool_schema(
    element, "refreshError", false, "Part 1 §18.14.13", "sheetData",
  )
  let rows : Array[CT_ExternalRow] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "row" {
        rows.push(CT_ExternalRow::new(child_element))
      }
    }
  }
  { element, sheet_id, refresh_error, rows }
}

///|
/// XSD complex type CT_ExternalRow — Part 1 §18.14.12 (row). Required
/// `@r` (xsd:unsignedInt, row index); zero or more `<cell>`
/// (CT_ExternalCell) children.
pub(all) struct CT_ExternalRow {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r (xsd:unsignedInt) — required.
  r : Int
  /// <cell>* (CT_ExternalCell) — zero or more.
  cells : Array[CT_ExternalCell]
} derive(Eq, Debug)

///|
pub fn CT_ExternalRow::new(
  element : @xml.Element,
) -> CT_ExternalRow raise @opc_errors.SchemaViolation {
  let r = attr_uint_schema(element, "r", 0)
  let cells : Array[CT_ExternalCell] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "cell" {
        cells.push(CT_ExternalCell::new(child_element))
      }
    }
  }
  { element, r, cells }
}

///|
/// XSD complex type CT_ExternalCell — Part 1 §18.14.1 (cell External
/// Cell Data). Optional `@r` (ST_CellRef), `@t` (ST_CellType, default
/// `n`), `@vm` (xsd:unsignedInt, default 0). Optional `<v>` (s:ST_Xstring)
/// value child.
pub(all) struct CT_ExternalCell {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r (ST_CellRef) — optional.
  r : String?
  /// @t (ST_CellType) — optional, default "n".
  t : String
  /// @vm (xsd:unsignedInt) — optional, default 0.
  vm : Int
  /// <v> (s:ST_Xstring) — optional.
  v : String?
} derive(Eq, Debug)

///|
pub fn CT_ExternalCell::new(
  element : @xml.Element,
) -> CT_ExternalCell raise @opc_errors.SchemaViolation {
  let r = attr(element, "r")
  let t = match attr(element, "t") {
    Some(v) => v
    None => "n"
  }
  let vm = attr_uint_schema(element, "vm", 0)
  let mut v : String? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "v" {
        v = Some(element_text(child_element))
      }
    }
  }
  { element, r, t, vm, v }
}

///|
/// XSD complex type CT_DdeLink — Part 1 §18.14.4 (ddeLink DDE
/// Connection). Required `@ddeService` and `@ddeTopic` (s:ST_Xstring);
/// optional `<ddeItems>` (CT_DdeItems) child.
pub(all) struct CT_DdeLink {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ddeService (s:ST_Xstring) — required.
  dde_service : String
  /// @ddeTopic (s:ST_Xstring) — required.
  dde_topic : String
  /// <ddeItems> (CT_DdeItems) — optional.
  dde_items : CT_DdeItems?
} derive(Eq, Debug)

///|
pub fn CT_DdeLink::new(
  element : @xml.Element,
) -> CT_DdeLink raise @opc_errors.SchemaViolation {
  let dde_service = match attr(element, "ddeService") {
    Some(v) => v
    None => ""
  }
  let dde_topic = match attr(element, "ddeTopic") {
    Some(v) => v
    None => ""
  }
  let mut dde_items : CT_DdeItems? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "ddeItems" {
        dde_items = Some(CT_DdeItems::new(child_element))
      }
    }
  }
  { element, dde_service, dde_topic, dde_items }
}

///|
/// XSD complex type CT_DdeItems — Part 1 §18.14.3 (ddeItems DDE Items
/// Collection). Zero or more `<ddeItem>` (CT_DdeItem) children.
pub(all) struct CT_DdeItems {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <ddeItem>* (CT_DdeItem) — zero or more.
  dde_items : Array[CT_DdeItem]
} derive(Eq, Debug)

///|
pub fn CT_DdeItems::new(
  element : @xml.Element,
) -> CT_DdeItems raise @opc_errors.SchemaViolation {
  let dde_items : Array[CT_DdeItem] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "ddeItem" {
        dde_items.push(CT_DdeItem::new(child_element))
      }
    }
  }
  { element, dde_items }
}

///|
/// XSD complex type CT_DdeItem — Part 1 §18.14.2 (ddeItem DDE Item
/// Definition). Optional `@name` (s:ST_Xstring, default "0"), `@ole`,
/// `@advise`, `@preferPic` (xsd:boolean, default false); optional
/// `<values>` (CT_DdeValues) child.
pub(all) struct CT_DdeItem {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — optional, default "0".
  name : String
  /// @ole (xsd:boolean) — optional, default false.
  ole : Bool
  /// @advise (xsd:boolean) — optional, default false.
  advise : Bool
  /// @preferPic (xsd:boolean) — optional, default false.
  prefer_pic : Bool
  /// <values> (CT_DdeValues) — optional.
  values : CT_DdeValues?
} derive(Eq, Debug)

///|
pub fn CT_DdeItem::new(
  element : @xml.Element,
) -> CT_DdeItem raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(v) => v
    None => "0"
  }
  let ole = attr_bool_schema(
    element, "ole", false, "Part 1 §18.14.2", "ddeItem",
  )
  let advise = attr_bool_schema(
    element, "advise", false, "Part 1 §18.14.2", "ddeItem",
  )
  let prefer_pic = attr_bool_schema(
    element, "preferPic", false, "Part 1 §18.14.2", "ddeItem",
  )
  let mut values : CT_DdeValues? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "values" {
        values = Some(CT_DdeValues::new(child_element))
      }
    }
  }
  { element, name, ole, advise, prefer_pic, values }
}

///|
/// XSD complex type CT_DdeValues — Part 1 §18.14.19 (values DDE Name
/// Values). Optional `@rows` and `@cols` (xsd:unsignedInt, default 1);
/// one or more `<value>` (CT_DdeValue) children.
pub(all) struct CT_DdeValues {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @rows (xsd:unsignedInt) — optional, default 1.
  rows : Int
  /// @cols (xsd:unsignedInt) — optional, default 1.
  cols : Int
  /// <value>+ (CT_DdeValue) — one or more.
  values : Array[CT_DdeValue]
} derive(Eq, Debug)

///|
pub fn CT_DdeValues::new(
  element : @xml.Element,
) -> CT_DdeValues raise @opc_errors.SchemaViolation {
  let rows = attr_uint_schema(element, "rows", 1)
  let cols = attr_uint_schema(element, "cols", 1)
  let values : Array[CT_DdeValue] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "value" {
        values.push(CT_DdeValue::new(child_element))
      }
    }
  }
  { element, rows, cols, values }
}

///|
/// XSD complex type CT_DdeValue — Part 1 §18.14.18 (value). Optional
/// `@t` (ST_DdeValueType, default `n`); required `<val>` (s:ST_Xstring)
/// child carrying the literal payload.
pub(all) struct CT_DdeValue {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @t (ST_DdeValueType) — optional, default "n".
  t : String
  /// <val> (s:ST_Xstring) — required text payload.
  val : String
} derive(Eq, Debug)

///|
pub fn CT_DdeValue::new(element : @xml.Element) -> CT_DdeValue {
  let t = match attr(element, "t") {
    Some(v) => v
    None => "n"
  }
  let mut val = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "val" {
        val = element_text(child_element)
      }
    }
  }
  { element, t, val }
}

///|
/// XSD complex type CT_OleLink — Part 1 §18.14.11 (oleLink Generic
/// Object Link Connection). Required `@r:id` reference and `@progId`
/// (s:ST_Xstring); optional `<oleItems>` (CT_OleItems) child.
pub(all) struct CT_OleLink {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (relationship id) — required.
  r_id : String
  /// @progId (s:ST_Xstring) — required.
  prog_id : String
  /// <oleItems> (CT_OleItems) — optional.
  ole_items : CT_OleItems?
} derive(Eq, Debug)

///|
pub fn CT_OleLink::new(
  element : @xml.Element,
) -> CT_OleLink raise @opc_errors.SchemaViolation {
  let r_id = match attr_with_ns(element, "id") {
    Some(v) => v
    None => ""
  }
  let prog_id = match attr(element, "progId") {
    Some(v) => v
    None => ""
  }
  let mut ole_items : CT_OleItems? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "oleItems" {
        ole_items = Some(CT_OleItems::new(child_element))
      }
    }
  }
  { element, r_id, prog_id, ole_items }
}

///|
/// XSD complex type CT_OleItems — Part 1 §18.14.10 (oleItems Object
/// Link Items). Zero or more `<oleItem>` (CT_OleItem) children.
pub(all) struct CT_OleItems {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <oleItem>* (CT_OleItem) — zero or more.
  ole_items : Array[CT_OleItem]
} derive(Eq, Debug)

///|
pub fn CT_OleItems::new(
  element : @xml.Element,
) -> CT_OleItems raise @opc_errors.SchemaViolation {
  let ole_items : Array[CT_OleItem] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "oleItem" {
        ole_items.push(CT_OleItem::new(child_element))
      }
    }
  }
  { element, ole_items }
}

///|
/// XSD complex type CT_OleItem — Part 1 §18.14.9 (oleItem Object Link
/// Item). Required `@name` (s:ST_Xstring); optional `@icon`, `@advise`,
/// `@preferPic` (xsd:boolean, default false).
pub(all) struct CT_OleItem {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required.
  name : String
  /// @icon (xsd:boolean) — optional, default false.
  icon : Bool
  /// @advise (xsd:boolean) — optional, default false.
  advise : Bool
  /// @preferPic (xsd:boolean) — optional, default false.
  prefer_pic : Bool
} derive(Eq, Debug)

///|
pub fn CT_OleItem::new(
  element : @xml.Element,
) -> CT_OleItem raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let icon = attr_bool_schema(
    element, "icon", false, "Part 1 §18.14.9", "oleItem",
  )
  let advise = attr_bool_schema(
    element, "advise", false, "Part 1 §18.14.9", "oleItem",
  )
  let prefer_pic = attr_bool_schema(
    element, "preferPic", false, "Part 1 §18.14.9", "oleItem",
  )
  { element, name, icon, advise, prefer_pic }
}

///|
/// XSD complex type CT_XmlColumnPr — Part 1 §18.5.1.7 (xmlColumnPr XML
/// Column Properties). Required `@mapId` (xsd:unsignedInt), `@xpath`
/// (s:ST_Xstring), `@xmlDataType` (ST_XmlDataType); optional
/// `@denormalized` (xsd:boolean, default false). Optional `<extLst>`
/// (CT_ExtensionList) child.
pub(all) struct CT_XmlColumnPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @mapId (xsd:unsignedInt) — required.
  map_id : Int
  /// @xpath (s:ST_Xstring) — required.
  xpath : String
  /// @denormalized (xsd:boolean) — optional, default false.
  denormalized : Bool
  /// @xmlDataType (ST_XmlDataType) — required.
  xml_data_type : String
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_XmlColumnPr::new(
  element : @xml.Element,
) -> CT_XmlColumnPr raise @opc_errors.SchemaViolation {
  let map_id = attr_uint_schema(element, "mapId", 0)
  let xpath = match attr(element, "xpath") {
    Some(v) => v
    None => ""
  }
  let denormalized = attr_bool_schema(
    element, "denormalized", false, "Part 1 §18.5.1.7", "xmlColumnPr",
  )
  let xml_data_type = match attr(element, "xmlDataType") {
    Some(v) => v
    None => ""
  }
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  { element, map_id, xpath, denormalized, xml_data_type, ext_lst }
}

///|
/// XSD complex type CT_VolTypes — Part 1 §18.15.6 (volTypes Volatile
/// Dependency Types). One or more `<volType>` (CT_VolType) children plus
/// optional `<extLst>` (CT_ExtensionList).
pub(all) struct CT_VolTypes {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <volType>+ (CT_VolType) — one or more.
  vol_types : Array[CT_VolType]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_VolTypes::new(
  element : @xml.Element,
) -> CT_VolTypes raise @opc_errors.SchemaViolation {
  let vol_types : Array[CT_VolType] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "volType" => vol_types.push(CT_VolType::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, vol_types, ext_lst }
}

// =============================================================================
// chunk2 typed wrappers — XSD complex types now carry every spec-defined
// attribute and child element. Reader/builder still access `.element` for
// byte-identical round-trip, so the raw element is preserved on each record.
// =============================================================================

///|
/// XSD complex type CT_VolType — Part 1 §18.15.5. Volatile-dependency type
/// entry: required `@type` (ST_VolDepType ∈ {realTimeData, olapFunctions}),
/// and one or more `<main>` (CT_VolMain) children describing the dependent
/// topics for the named function group.
pub(all) struct CT_VolType {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @type (ST_VolDepType) — required. Lexical value preserved.
  type_ : String
  /// <main>+ (CT_VolMain) — one or more.
  mains : Array[CT_VolMain]
} derive(Eq, Debug)

///|
pub fn CT_VolType::new(
  element : @xml.Element,
) -> CT_VolType raise @opc_errors.SchemaViolation {
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => ""
  }
  let mains : Array[CT_VolMain] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "main" {
        mains.push(CT_VolMain::new(child_element))
      }
    }
  }
  { element, type_, mains }
}

///|
/// XSD complex type CT_VolMain — Part 1 §18.15.1. Volatile-dependency main
/// entry: required `@first` (s:ST_Xstring) holding the head topic value
/// and one or more `<tp>` (CT_VolTopic) children describing the dependent
/// topic chain.
/// Schema sml.xsd complex type `CT_VolMain`. Attributes: `first`. Child
/// elements: `tp`. Child types: `CT_VolTopic`.
pub(all) struct CT_VolMain {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @first (s:ST_Xstring) — required.
  first : String
  /// <tp>+ (CT_VolTopic) — one or more topics.
  tps : Array[CT_VolTopic]
} derive(Eq, Debug)

///|
pub fn CT_VolMain::new(
  element : @xml.Element,
) -> CT_VolMain raise @opc_errors.SchemaViolation {
  let first = match attr(element, "first") {
    Some(value) => value
    None => ""
  }
  let tps : Array[CT_VolTopic] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "tp" {
        tps.push(CT_VolTopic::new(child_element))
      }
    }
  }
  { element, first, tps }
}

///|
/// XSD complex type CT_VolTopic — Part 1 §18.15.3 (tp). Volatile-dependency
/// topic: optional `@t` (ST_VolValueType ∈ {b,n,e,s}, default "n"), a
/// required `<v>` (s:ST_Xstring) value child, an optional sequence of
/// `<stp>` (s:ST_Xstring) sub-topic strings, and one or more `<tr>`
/// (CT_VolTopicRef) references.
pub(all) struct CT_VolTopic {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @t (ST_VolValueType) — optional, default "n". Lexical preserved.
  t : String?
  /// <v> (s:ST_Xstring) — required value text.
  v : String
  /// <stp>* (s:ST_Xstring) — zero or more sub-topic strings.
  stps : Array[String]
  /// <tr>+ (CT_VolTopicRef) — one or more topic references.
  trs : Array[CT_VolTopicRef]
} derive(Eq, Debug)

///|
pub fn CT_VolTopic::new(
  element : @xml.Element,
) -> CT_VolTopic raise @opc_errors.SchemaViolation {
  let t = attr(element, "t")
  let mut v = ""
  let stps : Array[String] = []
  let trs : Array[CT_VolTopicRef] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "v" => v = element_text(child_element)
        "stp" => stps.push(element_text(child_element))
        "tr" => trs.push(CT_VolTopicRef::new(child_element))
        _ => ()
      }
    }
  }
  { element, t, v, stps, trs }
}

///|
/// XSD complex type CT_VolTopicRef — Part 1 §18.15.4 (tr). Volatile-dependency
/// topic reference: required `@r` (ST_CellRef) cell reference and required
/// `@s` (xsd:unsignedInt) sheet-id index. No child elements.
pub(all) struct CT_VolTopicRef {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r (ST_CellRef) — required cell reference.
  r : String
  /// @s (xsd:unsignedInt) — required sheet-id index.
  s : Int
} derive(Eq, Debug)

///|
pub fn CT_VolTopicRef::new(
  element : @xml.Element,
) -> CT_VolTopicRef raise @opc_errors.SchemaViolation {
  let r = match attr(element, "r") {
    Some(value) => value
    None => ""
  }
  let s = attr_uint_schema(element, "s", 0)
  { element, r, s }
}

///|
/// XSD complex type CT_ExternalReferences — Part 1 §18.2.9. Workbook-level
/// container of external-workbook relationships: one or more
/// `<externalReference>` (CT_ExternalReference) children. No attributes.
pub(all) struct CT_ExternalReferences {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <externalReference>+ (CT_ExternalReference) — one or more.
  external_references : Array[CT_ExternalReference]
} derive(Eq, Debug)

///|
pub fn CT_ExternalReferences::new(
  element : @xml.Element,
) -> CT_ExternalReferences {
  let external_references : Array[CT_ExternalReference] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "externalReference" {
        external_references.push(CT_ExternalReference::new(child_element))
      }
    }
  }
  { element, external_references }
}

///|
/// XSD complex type CT_ExternalReference — Part 1 §18.2.8. Reference to an
/// external workbook part: required `@r:id` carrying the relationship id
/// targeting the external-link part. No child elements.
pub(all) struct CT_ExternalReference {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (relationship id) — required.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_ExternalReference::new(
  element : @xml.Element,
) -> CT_ExternalReference {
  let r_id = match attr_with_ns(element, "id") {
    Some(value) => value
    None => ""
  }
  { element, r_id }
}

///|
/// XSD complex type CT_OleSize — Part 1 §18.2.16. Embedded OLE-object size
/// hint: required `@ref` (ST_Ref) cell-range reference that defines the
/// embedded object's visible area on the active sheet. No child elements.
pub(all) struct CT_OleSize {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ref (ST_Ref) — required cell-range reference.
  ref_ : String
} derive(Eq, Debug)

///|
pub fn CT_OleSize::new(element : @xml.Element) -> CT_OleSize {
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  { element, ref_ }
}

// =============================================================================
// private parse helpers
// =============================================================================

///|
/// Look up an attribute by local name, ignoring namespace prefix.
fn attr(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// Look up an attribute by local name where the attribute is expected to
/// carry a prefix (e.g. `r:id`). The lookup matches the local name with
/// a non-empty prefix to disambiguate from unprefixed siblings.
fn attr_with_ns(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name &&
      attribute.name.prefix is Some(_) {
      return Some(attribute.value)
    }
  }
  // Fall back to plain local-name match in case the document elided the prefix.
  attr(element, local_name)
}

///|
/// Strict xsd:unsignedInt reader for schema boundary constructors.
/// Missing attributes use the schema default; malformed present values raise.
fn attr_uint_schema(
  element : @xml.Element,
  local_name : String,
  default : Int,
) -> Int raise @opc_errors.SchemaViolation {
  match attr_uint_opt_schema(element, local_name) {
    Some(n) => n
    None => default
  }
}

///|
fn attr_uint_opt_schema(
  element : @xml.Element,
  local_name : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_uint_text(value) {
        Some(n) => Some(n)
        None =>
          raise_numeric_attr_violation(element, local_name, "xsd:unsignedInt")
      }
    None => None
  }
}

///|
fn attr_uint_schema_at(
  element : @xml.Element,
  local_name : String,
  default : Int,
  section : String,
  path_prefix : String,
) -> Int raise @opc_errors.SchemaViolation {
  match attr_uint_opt_schema_at(element, local_name, section, path_prefix) {
    Some(n) => n
    None => default
  }
}

///|
fn attr_uint_opt_schema_at(
  element : @xml.Element,
  local_name : String,
  section : String,
  path_prefix : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_uint_text(value) {
        Some(n) => Some(n)
        None =>
          raise_numeric_attr_violation_at(
            local_name, "xsd:unsignedInt", value, section, path_prefix,
          )
      }
    None => None
  }
}

///|
fn[T] raise_numeric_attr_violation(
  element : @xml.Element,
  local_name : String,
  type_name : String,
) -> T raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(
    section="Part 1 §18 SpreadsheetML",
    path=element.name.local_name + "/@" + local_name,
    reason="value is outside " + type_name,
  )
}

///|
fn[T] raise_numeric_attr_violation_at(
  local_name : String,
  type_name : String,
  value : String,
  section : String,
  path_prefix : String,
) -> T raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(
    section~,
    path=path_prefix + "/@" + local_name,
    reason="expected " + type_name + " lexical, got " + value,
  )
}

///|
/// Strict xsd:int reader for schema boundary constructors.
fn attr_int_schema(
  element : @xml.Element,
  local_name : String,
  default : Int,
) -> Int raise @opc_errors.SchemaViolation {
  match attr_int_opt_schema(element, local_name) {
    Some(n) => n
    None => default
  }
}

///|
fn attr_int_opt_schema(
  element : @xml.Element,
  local_name : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_int_text(value) {
        Some(n) => Some(n)
        None => raise_numeric_attr_violation(element, local_name, "xsd:int")
      }
    None => None
  }
}

///|
/// Helper: parse a signed integer per xsd:int. Whitespace is trimmed;
/// empty tokens are rejected.
fn parse_int_text(text : String) -> Int? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try {
    let value : Int64 = @strconv.from_str(trimmed)
    Some(value.to_int())
  } catch {
    _ => None
  }
}

///|
/// Helper: parse a non-negative integer per xsd:unsignedInt. Whitespace
/// is trimmed; leading-sign / empty / negative tokens are rejected.
fn parse_uint_text(text : String) -> Int? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try {
    let value : Int64 = @strconv.from_str(trimmed)
    let n = value.to_int()
    if n < 0 {
      None
    } else {
      Some(n)
    }
  } catch {
    _ => None
  }
}

///|
/// Trim ASCII whitespace from both ends per XSD §3 collapse-whitespace.
fn trim_whitespace(text : String) -> String {
  let len = text.length()
  let mut start = 0
  let mut stop = len
  while start < stop {
    let c = text.code_unit_at(start).to_int()
    if c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D {
      start = start + 1
    } else {
      break
    }
  }
  while stop > start {
    let c = text.code_unit_at(stop - 1).to_int()
    if c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D {
      stop = stop - 1
    } else {
      break
    }
  }
  text[start:stop].to_owned()
}

///|
/// Parse an attribute as xsd:boolean at a schema reader boundary. Missing
/// attributes keep their schema default; present malformed lexicals raise.
fn attr_bool_strict(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.9.10", "metadataType",
  )
}

///|
/// Parse an attribute as xsd:boolean at a schema reader boundary using a
/// caller-supplied ECMA section and element path.
fn attr_bool_schema(
  element : @xml.Element,
  local_name : String,
  default : Bool,
  section : String,
  path_prefix : String,
) -> Bool raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_bool_text(value) {
        Some(parsed) => parsed
        None =>
          raise @opc_errors.SchemaViolation(
            section~,
            path=path_prefix + "/@" + local_name,
            reason="expected xsd:boolean lexical, got " + value,
          )
      }
    None => default
  }
}

///|
/// Parse an optional xsd:boolean attribute at a schema reader boundary.
fn attr_bool_schema_opt(
  element : @xml.Element,
  local_name : String,
  section : String,
  path_prefix : String,
) -> Bool? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_bool_text(value) {
        Some(parsed) => Some(parsed)
        None =>
          raise @opc_errors.SchemaViolation(
            section~,
            path=path_prefix + "/@" + local_name,
            reason="expected xsd:boolean lexical, got " + value,
          )
      }
    None => None
  }
}

///|
/// Parse W3C XML Schema xsd:boolean after the simple type whitespace
/// collapse step. The only permitted lexical values are 1, 0, true, false.
fn parse_bool_text(text : String) -> Bool? {
  match trim_whitespace(text) {
    "1" => Some(true)
    "true" => Some(true)
    "0" => Some(false)
    "false" => Some(false)
    _ => None
  }
}

///|
/// Concatenate the text and CDATA descendants of an element. Comments and
/// processing instructions are skipped per XSD §3 simpleContent rules.
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
/// Parse an attribute as a hex-encoded unsigned integer
/// (ST_UnsignedIntHex from sml.xsd, four-byte fixed length). Returns
/// None when absent or malformed.
fn attr_hex_uint_opt(element : @xml.Element, local_name : String) -> Int? {
  match attr(element, local_name) {
    Some(value) => parse_hex_uint_text(value)
    None => None
  }
}

///|
/// Strict ST_UnsignedIntHex reader for schema boundary constructors.
fn attr_hex_uint_opt_schema(
  element : @xml.Element,
  local_name : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_hex_uint_text(value) {
        Some(n) => Some(n)
        None =>
          raise_numeric_attr_violation(element, local_name, "ST_UnsignedIntHex")
      }
    None => None
  }
}

///|
/// Helper: parse a hex-encoded unsigned integer. Accepts both upper and
/// lower-case hex digits. Up to eight hex digits (xsd:hexBinary length=4)
/// pack into a single Int payload. Returns None on empty / non-hex input.
fn parse_hex_uint_text(text : String) -> Int? {
  let trimmed = trim_whitespace(text)
  let len = trimmed.length()
  if len == 0 || len > 8 {
    return None
  }
  let mut acc : Int = 0
  for index in 0..<len {
    let ch = trimmed.code_unit_at(index).to_int()
    let digit = if ch >= '0'.to_int() && ch <= '9'.to_int() {
      ch - '0'.to_int()
    } else if ch >= 'a'.to_int() && ch <= 'f'.to_int() {
      ch - 'a'.to_int() + 10
    } else if ch >= 'A'.to_int() && ch <= 'F'.to_int() {
      ch - 'A'.to_int() + 10
    } else {
      return None
    }
    acc = acc * 16 + digit
  }
  Some(acc)
}

///|
/// Strict xsd:double reader for schema boundary constructors.
fn attr_double_opt_schema(
  element : @xml.Element,
  local_name : String,
) -> Double? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_double_text(value) {
        Some(n) => Some(n)
        None => raise_numeric_attr_violation(element, local_name, "xsd:double")
      }
    None => None
  }
}

///|
fn attr_double_opt_schema_at(
  element : @xml.Element,
  local_name : String,
  section : String,
  path_prefix : String,
) -> Double? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_double_text(value) {
        Some(n) => Some(n)
        None =>
          raise_numeric_attr_violation_at(
            local_name, "xsd:double", value, section, path_prefix,
          )
      }
    None => None
  }
}

///|
fn attr_double_schema(
  element : @xml.Element,
  local_name : String,
  default : Double,
) -> Double raise @opc_errors.SchemaViolation {
  match attr_double_opt_schema(element, local_name) {
    Some(d) => d
    None => default
  }
}

///|
fn attr_double_schema_at(
  element : @xml.Element,
  local_name : String,
  default : Double,
  section : String,
  path_prefix : String,
) -> Double raise @opc_errors.SchemaViolation {
  match attr_double_opt_schema_at(element, local_name, section, path_prefix) {
    Some(d) => d
    None => default
  }
}

///|
/// Helper: parse a floating-point value per xsd:double. Whitespace is
/// trimmed; empty tokens are rejected.
fn parse_double_text(text : String) -> Double? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try {
    let value : Double = @strconv.from_str(trimmed)
    Some(value)
  } catch {
    _ => None
  }
}
