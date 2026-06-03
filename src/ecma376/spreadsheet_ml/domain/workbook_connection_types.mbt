///|
/// SpreadsheetML workbook connection types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn workbook_connection_type_group_name() -> String {
  "spreadsheet_ml.workbook_connection"
}

///|
fn revision_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
  section : String,
  path_prefix : String,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(element, local_name, default, section, path_prefix)
}

///|
fn revision_bool_opt(
  element : @xml.Element,
  local_name : String,
  section : String,
  path_prefix : String,
) -> Bool? raise @opc_errors.SchemaViolation {
  attr_bool_schema_opt(element, local_name, section, path_prefix)
}

///|
fn file_recovery_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.2.11", "fileRecoveryPr",
  )
}

///|
fn workbook_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.2.28", "workbookPr",
  )
}

///|
fn calc_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(element, local_name, default, "Part 1 §18.2.2", "calcPr")
}

///|
fn calc_pr_bool_opt(
  element : @xml.Element,
  local_name : String,
) -> Bool? raise @opc_errors.SchemaViolation {
  attr_bool_schema_opt(element, local_name, "Part 1 §18.2.2", "calcPr")
}

///|
fn defined_name_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.2.5", "definedName",
  )
}

///|
fn file_sharing_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.2.12", "fileSharing",
  )
}

///|
fn smart_tag_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.2.21", "smartTagPr",
  )
}

///|
fn web_publishing_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.2.24", "webPublishing",
  )
}

///|
/// XSD complex type CT_SortState — Part 1 §18.3.1.92 (`<sortState>` Sort
/// State). Sequence children: `<sortCondition>*` (CT_SortCondition,
/// 0..64) and optional `<extLst>` (CT_ExtensionList). Attributes:
/// optional `@columnSort` (xsd:boolean, default false), `@caseSensitive`
/// (xsd:boolean, default false), `@sortMethod` (ST_SortMethod, default
/// `none`); required `@ref` (ST_Ref).
pub(all) struct CT_SortState {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sortCondition>* (CT_SortCondition) — zero to 64 sort conditions.
  sort_condition : Array[CT_SortCondition]
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @columnSort (xsd:boolean) — optional, default false.
  column_sort : Bool
  /// @caseSensitive (xsd:boolean) — optional, default false.
  case_sensitive : Bool
  /// @sortMethod (ST_SortMethod) — optional, default `none`.
  sort_method : String
  /// @ref (ST_Ref) — required cell-range reference.
  ref_ : String
} derive(Eq, Debug)

///|
pub fn CT_SortState::new(
  element : @xml.Element,
) -> CT_SortState raise @opc_errors.SchemaViolation {
  let sort_condition : Array[CT_SortCondition] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sortCondition" =>
          sort_condition.push(CT_SortCondition::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let column_sort = attr_bool_schema(
    element, "columnSort", false, "Part 1 §18.3.1.92", "sortState",
  )
  let case_sensitive = attr_bool_schema(
    element, "caseSensitive", false, "Part 1 §18.3.1.92", "sortState",
  )
  let sort_method = match attr(element, "sortMethod") {
    Some(value) => value
    None => "none"
  }
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  {
    element,
    sort_condition,
    ext_lst,
    column_sort,
    case_sensitive,
    sort_method,
    ref_,
  }
}

///|
/// XSD complex type CT_SortCondition — Part 1 §18.3.1.91
/// (`<sortCondition>`). Attribute-only. Optional `@descending`
/// (xsd:boolean, default false); `@sortBy` (ST_SortBy, default `value`);
/// required `@ref` (ST_Ref). Optional `@customList` (s:ST_Xstring);
/// `@dxfId` (ST_DxfId); `@iconSet` (ST_IconSetType, default `3Arrows`);
/// `@iconId` (xsd:unsignedInt).
pub(all) struct CT_SortCondition {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @descending (xsd:boolean) — optional, default false.
  descending : Bool
  /// @sortBy (ST_SortBy) — optional, default `value`.
  sort_by : String
  /// @ref (ST_Ref) — required range reference.
  ref_ : String
  /// @customList (s:ST_Xstring) — optional custom list reference.
  custom_list : String?
  /// @dxfId (ST_DxfId) — optional differential format index.
  dxf_id : Int?
  /// @iconSet (ST_IconSetType) — optional, default `3Arrows`.
  icon_set : String
  /// @iconId (xsd:unsignedInt) — optional icon index.
  icon_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_SortCondition::new(
  element : @xml.Element,
) -> CT_SortCondition raise @opc_errors.SchemaViolation {
  let descending = attr_bool_schema(
    element, "descending", false, "Part 1 §18.3.1.91", "sortCondition",
  )
  let sort_by = match attr(element, "sortBy") {
    Some(value) => value
    None => "value"
  }
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  let custom_list = attr(element, "customList")
  let dxf_id = attr_uint_opt_schema(element, "dxfId")
  let icon_set = match attr(element, "iconSet") {
    Some(value) => value
    None => "3Arrows"
  }
  let icon_id = attr_uint_opt_schema(element, "iconId")
  { element, descending, sort_by, ref_, custom_list, dxf_id, icon_set, icon_id }
}

///|
/// XSD complex type CT_Extension — Part 1 §18.2.10 (`<ext>` Extension).
/// Wildcard payload: `xsd:any processContents="lax"` for vendor
/// extension content. Optional `@uri` (xsd:token) extension identifier.
/// Every direct element child is preserved as raw `@xml.Element` to
/// round-trip the open content per §18.2.10.
pub(all) struct CT_Extension {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// `<xsd:any/>` payload — every direct element child preserved.
  any_children : Array[@xml.Element]
  /// @uri (xsd:token) — optional extension URI identifier.
  uri : String?
} derive(Eq, Debug)

///|
pub fn CT_Extension::new(element : @xml.Element) -> CT_Extension {
  let any_children : Array[@xml.Element] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      any_children.push(child_element)
    }
  }
  let uri = attr(element, "uri")
  { element, any_children, uri }
}

///|
/// XSD complex type CT_ExtensionList — Part 1 §18.2.10 (`<extLst>`
/// Future Feature Data Storage Area). Sequence references
/// EG_ExtensionList → `<ext>*` (CT_Extension, zero or more). No
/// attributes.
pub(all) struct CT_ExtensionList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <ext>* (CT_Extension) — zero or more extension entries.
  ext : Array[CT_Extension]
} derive(Eq, Debug)

///|
pub fn CT_ExtensionList::new(element : @xml.Element) -> CT_ExtensionList {
  let ext : Array[CT_Extension] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "ext" {
        ext.push(CT_Extension::new(child_element))
      }
    }
  }
  { element, ext }
}

///|
/// XSD complex type CT_CalcChain — Part 1 §18.6.1 (`<calcChain>`
/// Calculation Chain root). Sequence children: `<c>+` (CT_CalcCell, one
/// or more calculation-chain entries) and optional `<extLst>`
/// (CT_ExtensionList). No attributes.
pub(all) struct CT_CalcChain {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <c>+ (CT_CalcCell) — one or more calculation-chain entries.
  c : Array[CT_CalcCell]
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CalcChain::new(
  element : @xml.Element,
) -> CT_CalcChain raise @opc_errors.SchemaViolation {
  let c : Array[CT_CalcCell] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "c" => c.push(CT_CalcCell::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, c, ext_lst }
}

///|
/// XSD complex type CT_Comments — Part 1 §18.7.6 (`<comments>` Comments
/// part root). Sequence children: required `<authors>` (CT_Authors),
/// required `<commentList>` (CT_CommentList), optional `<extLst>`
/// (CT_ExtensionList). No attributes.
pub(all) struct CT_Comments {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <authors> (CT_Authors) — required authors list.
  authors : CT_Authors
  /// <commentList> (CT_CommentList) — required comment list.
  comment_list : CT_CommentList
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Comments::new(
  element : @xml.Element,
) -> CT_Comments raise @opc_errors.SchemaViolation {
  let mut authors : CT_Authors? = None
  let mut comment_list : CT_CommentList? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "authors" => authors = Some(CT_Authors::new(child_element))
        "commentList" => comment_list = Some(CT_CommentList::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let authors_value = match authors {
    Some(value) => value
    None => CT_Authors::new(element)
  }
  let comment_list_value = match comment_list {
    Some(value) => value
    None => CT_CommentList::new(element)
  }
  { element, authors: authors_value, comment_list: comment_list_value, ext_lst }
}

///|
/// XSD complex type CT_Authors — Part 1 §18.7.1 (`<authors>` Authors).
/// Sequence: `<author>*` (s:ST_Xstring text, zero or more). No
/// attributes. Each author element carries a plain-text payload that is
/// stored in `authors` in document order.
pub(all) struct CT_Authors {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <author>* (s:ST_Xstring) — zero or more author display names.
  authors : Array[String]
} derive(Eq, Debug)

///|
pub fn CT_Authors::new(element : @xml.Element) -> CT_Authors {
  let authors : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "author" {
        authors.push(element_text(child_element))
      }
    }
  }
  { element, authors }
}

///|
/// XSD complex type CT_CommentList — Part 1 §18.7.4 (`<commentList>`).
/// Sequence: `<comment>*` (CT_Comment, zero or more). No attributes.
pub(all) struct CT_CommentList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <comment>* (CT_Comment) — zero or more comment entries.
  comment : Array[CT_Comment]
} derive(Eq, Debug)

///|
pub fn CT_CommentList::new(
  element : @xml.Element,
) -> CT_CommentList raise @opc_errors.SchemaViolation {
  let comment : Array[CT_Comment] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "comment" {
        comment.push(CT_Comment::new(child_element))
      }
    }
  }
  { element, comment }
}

///|
/// XSD complex type CT_Comment — Part 1 §18.7.3 (`<comment>`). Sequence
/// children: required `<text>` (CT_Rst) rich-text body; optional
/// `<commentPr>` (CT_CommentPr) presentation properties. Attributes:
/// required `@ref` (ST_Ref), `@authorId` (xsd:unsignedInt); optional
/// `@guid` (s:ST_Guid), `@shapeId` (xsd:unsignedInt).
pub(all) struct CT_Comment {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <text> (CT_Rst) — required rich-text comment body.
  text : CT_Rst
  /// <commentPr> (CT_CommentPr) — optional comment presentation block.
  comment_pr : CT_CommentPr?
  /// @ref (ST_Ref) — required cell-range reference.
  ref_ : String
  /// @authorId (xsd:unsignedInt) — required author table index.
  author_id : Int
  /// @guid (s:ST_Guid) — optional GUID.
  guid : String?
  /// @shapeId (xsd:unsignedInt) — optional drawing-shape id.
  shape_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_Comment::new(
  element : @xml.Element,
) -> CT_Comment raise @opc_errors.SchemaViolation {
  let mut text : CT_Rst? = None
  let mut comment_pr : CT_CommentPr? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "text" => text = Some(CT_Rst::new(child_element))
        "commentPr" => comment_pr = Some(CT_CommentPr::new(child_element))
        _ => ()
      }
    }
  }
  let text_value = match text {
    Some(value) => value
    None => CT_Rst::new(element)
  }
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  let author_id = attr_uint_schema(element, "authorId", 0)
  let guid = attr(element, "guid")
  let shape_id = attr_uint_opt_schema(element, "shapeId")
  { element, text: text_value, comment_pr, ref_, author_id, guid, shape_id }
}

///|
/// XSD complex type CT_CommentPr — Part 1 §18.7.5 (`<commentPr>`).
/// Sequence: required `<anchor>` (CT_ObjectAnchor). Attributes (all
/// optional with defaults per XSD): `@locked` (xsd:boolean, default
/// true), `@defaultSize` (xsd:boolean, default true), `@print`
/// (xsd:boolean, default true), `@disabled` (xsd:boolean, default
/// false), `@autoFill` (xsd:boolean, default true), `@autoLine`
/// (xsd:boolean, default true), `@altText` (s:ST_Xstring), `@textHAlign`
/// (ST_TextHAlign, default `left`), `@textVAlign` (ST_TextVAlign,
/// default `top`), `@lockText` (xsd:boolean, default true),
/// `@justLastX` (xsd:boolean, default false), `@autoScale`
/// (xsd:boolean, default false).
pub(all) struct CT_CommentPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <anchor> (CT_ObjectAnchor) — required anchor block.
  anchor : CT_ObjectAnchor
  /// @locked (xsd:boolean) — optional, default true.
  locked : Bool
  /// @defaultSize (xsd:boolean) — optional, default true.
  default_size : Bool
  /// @print (xsd:boolean) — optional, default true.
  print : Bool
  /// @disabled (xsd:boolean) — optional, default false.
  disabled : Bool
  /// @autoFill (xsd:boolean) — optional, default true.
  auto_fill : Bool
  /// @autoLine (xsd:boolean) — optional, default true.
  auto_line : Bool
  /// @altText (s:ST_Xstring) — optional alternative text.
  alt_text : String?
  /// @textHAlign (ST_TextHAlign) — optional, default `left`.
  text_h_align : String
  /// @textVAlign (ST_TextVAlign) — optional, default `top`.
  text_v_align : String
  /// @lockText (xsd:boolean) — optional, default true.
  lock_text : Bool
  /// @justLastX (xsd:boolean) — optional, default false.
  just_last_x : Bool
  /// @autoScale (xsd:boolean) — optional, default false.
  auto_scale : Bool
} derive(Eq, Debug)

///|
pub fn CT_CommentPr::new(
  element : @xml.Element,
) -> CT_CommentPr raise @opc_errors.SchemaViolation {
  let mut anchor : CT_ObjectAnchor? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "anchor" {
        anchor = Some(CT_ObjectAnchor::new(child_element))
      }
    }
  }
  let anchor_value = match anchor {
    Some(value) => value
    None => CT_ObjectAnchor::new(element)
  }
  let locked = attr_bool_schema(
    element, "locked", true, "Part 1 §18.7.5", "commentPr",
  )
  let default_size = attr_bool_schema(
    element, "defaultSize", true, "Part 1 §18.7.5", "commentPr",
  )
  let print = attr_bool_schema(
    element, "print", true, "Part 1 §18.7.5", "commentPr",
  )
  let disabled = attr_bool_schema(
    element, "disabled", false, "Part 1 §18.7.5", "commentPr",
  )
  let auto_fill = attr_bool_schema(
    element, "autoFill", true, "Part 1 §18.7.5", "commentPr",
  )
  let auto_line = attr_bool_schema(
    element, "autoLine", true, "Part 1 §18.7.5", "commentPr",
  )
  let alt_text = attr(element, "altText")
  let text_h_align = match attr(element, "textHAlign") {
    Some(value) => value
    None => "left"
  }
  let text_v_align = match attr(element, "textVAlign") {
    Some(value) => value
    None => "top"
  }
  let lock_text = attr_bool_schema(
    element, "lockText", true, "Part 1 §18.7.5", "commentPr",
  )
  let just_last_x = attr_bool_schema(
    element, "justLastX", false, "Part 1 §18.7.5", "commentPr",
  )
  let auto_scale = attr_bool_schema(
    element, "autoScale", false, "Part 1 §18.7.5", "commentPr",
  )
  {
    element,
    anchor: anchor_value,
    locked,
    default_size,
    print,
    disabled,
    auto_fill,
    auto_line,
    alt_text,
    text_h_align,
    text_v_align,
    lock_text,
    just_last_x,
    auto_scale,
  }
}

///|
/// XSD complex type CT_Connections — Part 1 §18.13.2 (`<connections>`
/// External Connections root). Sequence: `<connection>+` (CT_Connection,
/// one or more). No attributes.
pub(all) struct CT_Connections {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <connection>+ (CT_Connection) — one or more connection entries.
  connection : Array[CT_Connection]
} derive(Eq, Debug)

///|
pub fn CT_Connections::new(
  element : @xml.Element,
) -> CT_Connections raise @opc_errors.SchemaViolation {
  let connection : Array[CT_Connection] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "connection" {
        connection.push(CT_Connection::new(child_element))
      }
    }
  }
  { element, connection }
}

///|
/// XSD complex type CT_Connection — Part 1 §18.13.1 (`<connection>`).
/// Sequence children, each optional: `<dbPr>` (CT_DbPr), `<olapPr>`
/// (CT_OlapPr), `<webPr>` (CT_WebPr), `<textPr>` (CT_TextPr),
/// `<parameters>` (CT_Parameters), `<extLst>` (CT_ExtensionList).
/// Required attributes `@id` (xsd:unsignedInt), `@refreshedVersion`
/// (xsd:unsignedByte). Optional: `@sourceFile`, `@odcFile`
/// (s:ST_Xstring); `@keepAlive` (xsd:boolean, default false);
/// `@interval` (xsd:unsignedInt, default 0); `@name`, `@description`
/// (s:ST_Xstring); `@type` (xsd:unsignedInt); `@reconnectionMethod`
/// (xsd:unsignedInt, default 1); `@minRefreshableVersion`
/// (xsd:unsignedByte, default 0); `@savePassword`, `@new`, `@deleted`,
/// `@onlyUseConnectionFile`, `@background`, `@refreshOnLoad`,
/// `@saveData` (xsd:boolean, default false); `@credentials`
/// (ST_CredMethod, default `integrated`); `@singleSignOnId`
/// (s:ST_Xstring).
pub(all) struct CT_Connection {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <dbPr> (CT_DbPr) — optional database properties.
  db_pr : CT_DbPr?
  /// <olapPr> (CT_OlapPr) — optional OLAP properties.
  olap_pr : CT_OlapPr?
  /// <webPr> (CT_WebPr) — optional web-query properties.
  web_pr : CT_WebPr?
  /// <textPr> (CT_TextPr) — optional text-query properties.
  text_pr : CT_TextPr?
  /// <parameters> (CT_Parameters) — optional parameters.
  parameters : CT_Parameters?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @id (xsd:unsignedInt) — required connection identifier.
  id : Int
  /// @sourceFile (s:ST_Xstring) — optional source file path.
  source_file : String?
  /// @odcFile (s:ST_Xstring) — optional ODC file path.
  odc_file : String?
  /// @keepAlive (xsd:boolean) — optional, default false.
  keep_alive : Bool
  /// @interval (xsd:unsignedInt) — optional, default 0.
  interval : Int
  /// @name (s:ST_Xstring) — optional connection name.
  name : String?
  /// @description (s:ST_Xstring) — optional description.
  description : String?
  /// @type (xsd:unsignedInt) — optional connection type code.
  type_ : Int?
  /// @reconnectionMethod (xsd:unsignedInt) — optional, default 1.
  reconnection_method : Int
  /// @refreshedVersion (xsd:unsignedByte) — required refreshed version.
  refreshed_version : Int
  /// @minRefreshableVersion (xsd:unsignedByte) — optional, default 0.
  min_refreshable_version : Int
  /// @savePassword (xsd:boolean) — optional, default false.
  save_password : Bool
  /// @new (xsd:boolean) — optional, default false.
  new_ : Bool
  /// @deleted (xsd:boolean) — optional, default false.
  deleted : Bool
  /// @onlyUseConnectionFile (xsd:boolean) — optional, default false.
  only_use_connection_file : Bool
  /// @background (xsd:boolean) — optional, default false.
  background : Bool
  /// @refreshOnLoad (xsd:boolean) — optional, default false.
  refresh_on_load : Bool
  /// @saveData (xsd:boolean) — optional, default false.
  save_data : Bool
  /// @credentials (ST_CredMethod) — optional, default `integrated`.
  credentials : String
  /// @singleSignOnId (s:ST_Xstring) — optional single sign-on identifier.
  single_sign_on_id : String?
} derive(Eq, Debug)

///|
fn connection_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.13.1", "connection",
  )
}

///|
pub fn CT_Connection::new(
  element : @xml.Element,
) -> CT_Connection raise @opc_errors.SchemaViolation {
  let mut db_pr : CT_DbPr? = None
  let mut olap_pr : CT_OlapPr? = None
  let mut web_pr : CT_WebPr? = None
  let mut text_pr : CT_TextPr? = None
  let mut parameters : CT_Parameters? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "dbPr" => db_pr = Some(CT_DbPr::new(child_element))
        "olapPr" => olap_pr = Some(CT_OlapPr::new(child_element))
        "webPr" => web_pr = Some(CT_WebPr::new(child_element))
        "textPr" => text_pr = Some(CT_TextPr::new(child_element))
        "parameters" => parameters = Some(CT_Parameters::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let id = attr_uint_schema(element, "id", 0)
  let source_file = attr(element, "sourceFile")
  let odc_file = attr(element, "odcFile")
  let keep_alive = connection_bool(element, "keepAlive", false)
  let interval = attr_uint_schema(element, "interval", 0)
  let name = attr(element, "name")
  let description = attr(element, "description")
  let type_ = attr_uint_opt_schema(element, "type")
  let reconnection_method = attr_uint_schema(element, "reconnectionMethod", 1)
  let refreshed_version = attr_uint_schema(element, "refreshedVersion", 0)
  let min_refreshable_version = attr_uint_schema(
    element, "minRefreshableVersion", 0,
  )
  let save_password = connection_bool(element, "savePassword", false)
  let new_ = connection_bool(element, "new", false)
  let deleted = connection_bool(element, "deleted", false)
  let only_use_connection_file = connection_bool(
    element, "onlyUseConnectionFile", false,
  )
  let background = connection_bool(element, "background", false)
  let refresh_on_load = connection_bool(element, "refreshOnLoad", false)
  let save_data = connection_bool(element, "saveData", false)
  let credentials = match attr(element, "credentials") {
    Some(value) => value
    None => "integrated"
  }
  let single_sign_on_id = attr(element, "singleSignOnId")
  {
    element,
    db_pr,
    olap_pr,
    web_pr,
    text_pr,
    parameters,
    ext_lst,
    id,
    source_file,
    odc_file,
    keep_alive,
    interval,
    name,
    description,
    type_,
    reconnection_method,
    refreshed_version,
    min_refreshable_version,
    save_password,
    new_,
    deleted,
    only_use_connection_file,
    background,
    refresh_on_load,
    save_data,
    credentials,
    single_sign_on_id,
  }
}

///|
/// XSD complex type CT_DbPr — Part 1 §18.13.3 (`<dbPr>` Database
/// Properties). Attribute-only. Required `@connection` (s:ST_Xstring).
/// Optional `@command`, `@serverCommand` (s:ST_Xstring); `@commandType`
/// (xsd:unsignedInt, default 2).
pub(all) struct CT_DbPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @connection (s:ST_Xstring) — required connection string.
  connection : String
  /// @command (s:ST_Xstring) — optional client command.
  command : String?
  /// @serverCommand (s:ST_Xstring) — optional server-side command.
  server_command : String?
  /// @commandType (xsd:unsignedInt) — optional, default 2.
  command_type : Int
} derive(Eq, Debug)

///|
pub fn CT_DbPr::new(
  element : @xml.Element,
) -> CT_DbPr raise @opc_errors.SchemaViolation {
  let connection = match attr(element, "connection") {
    Some(value) => value
    None => ""
  }
  let command = attr(element, "command")
  let server_command = attr(element, "serverCommand")
  let command_type = attr_uint_schema(element, "commandType", 2)
  { element, connection, command, server_command, command_type }
}

///|
/// Schema sml.xsd complex type `CT_OlapPr`. Attributes: `local`,
/// `localConnection`, `localRefresh`, `sendLocale`, `rowDrillCount`,
/// `serverFill`, `serverNumberFormat`, `serverFont`, `serverFontColor`.
///
/// XSD complex type CT_OlapPr — Part 1 §18.13.6 (`<olapPr>` OLAP
/// Properties). Attribute-only. Optional `@local` (xsd:boolean,
/// default false); `@localConnection` (s:ST_Xstring); `@localRefresh`
/// (xsd:boolean, default true); `@sendLocale` (xsd:boolean, default
/// false); `@rowDrillCount` (xsd:unsignedInt); `@serverFill`,
/// `@serverNumberFormat`, `@serverFont`, `@serverFontColor`
/// (xsd:boolean, default true).
pub(all) struct CT_OlapPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @local (xsd:boolean) — optional, default false.
  is_local : Bool
  /// @localConnection (s:ST_Xstring) — optional local connection string.
  local_connection : String?
  /// @localRefresh (xsd:boolean) — optional, default true.
  local_refresh : Bool
  /// @sendLocale (xsd:boolean) — optional, default false.
  send_locale : Bool
  /// @rowDrillCount (xsd:unsignedInt) — optional row drill cap.
  row_drill_count : Int?
  /// @serverFill (xsd:boolean) — optional, default true.
  server_fill : Bool
  /// @serverNumberFormat (xsd:boolean) — optional, default true.
  server_number_format : Bool
  /// @serverFont (xsd:boolean) — optional, default true.
  server_font : Bool
  /// @serverFontColor (xsd:boolean) — optional, default true.
  server_font_color : Bool
} derive(Eq, Debug)

///|
fn olap_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(element, local_name, default, "Part 1 §18.13.6", "olapPr")
}

///|
pub fn CT_OlapPr::new(
  element : @xml.Element,
) -> CT_OlapPr raise @opc_errors.SchemaViolation {
  let is_local = olap_pr_bool(element, "local", false)
  let local_connection = attr(element, "localConnection")
  let local_refresh = olap_pr_bool(element, "localRefresh", true)
  let send_locale = olap_pr_bool(element, "sendLocale", false)
  let row_drill_count = attr_uint_opt_schema(element, "rowDrillCount")
  let server_fill = olap_pr_bool(element, "serverFill", true)
  let server_number_format = olap_pr_bool(element, "serverNumberFormat", true)
  let server_font = olap_pr_bool(element, "serverFont", true)
  let server_font_color = olap_pr_bool(element, "serverFontColor", true)
  {
    element,
    is_local,
    local_connection,
    local_refresh,
    send_locale,
    row_drill_count,
    server_fill,
    server_number_format,
    server_font,
    server_font_color,
  }
}

///|
/// Schema sml.xsd complex type `CT_WebPr`. Attributes: `xml`,
/// `sourceData`, `parsePre`, `consecutive`, `firstRow`, `xl97`,
/// `textDates`, `xl2000`, `url`, `post`, `htmlTables`, `htmlFormat`,
/// `editPage`. Child elements: `tables`. Child types: `CT_Tables`.
///
/// XSD complex type CT_WebPr — Part 1 §18.13.16 (`<webPr>` Web Query
/// Properties). Sequence: optional `<tables>` (CT_Tables). Optional
/// `@xml`, `@sourceData`, `@parsePre`, `@consecutive`, `@firstRow`,
/// `@xl97`, `@textDates`, `@xl2000`, `@htmlTables` (xsd:boolean,
/// default false); `@url`, `@post`, `@editPage` (s:ST_Xstring);
/// `@htmlFormat` (ST_HtmlFmt, default `none`).
pub(all) struct CT_WebPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <tables> (CT_Tables) — optional web-query table list.
  tables : CT_Tables?
  /// @xml (xsd:boolean) — optional, default false.
  xml : Bool
  /// @sourceData (xsd:boolean) — optional, default false.
  source_data : Bool
  /// @parsePre (xsd:boolean) — optional, default false.
  parse_pre : Bool
  /// @consecutive (xsd:boolean) — optional, default false.
  consecutive : Bool
  /// @firstRow (xsd:boolean) — optional, default false.
  first_row : Bool
  /// @xl97 (xsd:boolean) — optional, default false.
  xl97 : Bool
  /// @textDates (xsd:boolean) — optional, default false.
  text_dates : Bool
  /// @xl2000 (xsd:boolean) — optional, default false.
  xl2000 : Bool
  /// @url (s:ST_Xstring) — optional URL.
  url : String?
  /// @post (s:ST_Xstring) — optional POST body.
  post : String?
  /// @htmlTables (xsd:boolean) — optional, default false.
  html_tables : Bool
  /// @htmlFormat (ST_HtmlFmt) — optional, default `none`.
  html_format : String
  /// @editPage (s:ST_Xstring) — optional edit page URL.
  edit_page : String?
} derive(Eq, Debug)

///|
fn web_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(element, local_name, default, "Part 1 §18.13.16", "webPr")
}

///|
pub fn CT_WebPr::new(
  element : @xml.Element,
) -> CT_WebPr raise @opc_errors.SchemaViolation {
  let mut tables : CT_Tables? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "tables" {
        tables = Some(CT_Tables::new(child_element))
      }
    }
  }
  let xml = web_pr_bool(element, "xml", false)
  let source_data = web_pr_bool(element, "sourceData", false)
  let parse_pre = web_pr_bool(element, "parsePre", false)
  let consecutive = web_pr_bool(element, "consecutive", false)
  let first_row = web_pr_bool(element, "firstRow", false)
  let xl97 = web_pr_bool(element, "xl97", false)
  let text_dates = web_pr_bool(element, "textDates", false)
  let xl2000 = web_pr_bool(element, "xl2000", false)
  let url = attr(element, "url")
  let post = attr(element, "post")
  let html_tables = web_pr_bool(element, "htmlTables", false)
  let html_format = match attr(element, "htmlFormat") {
    Some(value) => value
    None => "none"
  }
  let edit_page = attr(element, "editPage")
  {
    element,
    tables,
    xml,
    source_data,
    parse_pre,
    consecutive,
    first_row,
    xl97,
    text_dates,
    xl2000,
    url,
    post,
    html_tables,
    html_format,
    edit_page,
  }
}

///|
/// XSD complex type CT_Parameters — Part 1 §18.13.7 (`<parameters>`
/// Query Parameters). Sequence: `<parameter>+` (CT_Parameter, one or
/// more). Optional `@count` (xsd:unsignedInt).
pub(all) struct CT_Parameters {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <parameter>+ (CT_Parameter) — one or more parameter entries.
  parameter : Array[CT_Parameter]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_Parameters::new(
  element : @xml.Element,
) -> CT_Parameters raise @opc_errors.SchemaViolation {
  let parameter : Array[CT_Parameter] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "parameter" {
        parameter.push(CT_Parameter::new(child_element))
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, parameter, count }
}

///|
/// XSD complex type CT_Parameter — Part 1 §18.13.8 (`<parameter>` Query
/// Parameter). Attribute-only. Optional `@name` (s:ST_Xstring); `@sqlType`
/// (xsd:int, default 0); `@parameterType` (ST_ParameterType, default
/// `prompt`); `@refreshOnChange` (xsd:boolean, default false); `@prompt`
/// (s:ST_Xstring); `@boolean` (xsd:boolean); `@double` (xsd:double);
/// `@integer` (xsd:int); `@string`, `@cell` (s:ST_Xstring).
pub(all) struct CT_Parameter {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — optional parameter name.
  name : String?
  /// @sqlType (xsd:int) — optional, default 0.
  sql_type : Int
  /// @parameterType (ST_ParameterType) — optional, default `prompt`.
  parameter_type : String
  /// @refreshOnChange (xsd:boolean) — optional, default false.
  refresh_on_change : Bool
  /// @prompt (s:ST_Xstring) — optional prompt text.
  prompt : String?
  /// @boolean (xsd:boolean) — optional supplied boolean value.
  boolean : Bool?
  /// @double (xsd:double) — optional supplied double value.
  double : Double?
  /// @integer (xsd:int) — optional supplied integer value.
  integer : Int?
  /// @string (s:ST_Xstring) — optional supplied string value.
  string : String?
  /// @cell (s:ST_Xstring) — optional supplied cell reference.
  cell : String?
} derive(Eq, Debug)

///|
fn parameter_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.13.8", "parameter",
  )
}

///|
pub fn CT_Parameter::new(
  element : @xml.Element,
) -> CT_Parameter raise @opc_errors.SchemaViolation {
  let name = attr(element, "name")
  let sql_type = attr_int_schema(element, "sqlType", 0)
  let parameter_type = match attr(element, "parameterType") {
    Some(value) => value
    None => "prompt"
  }
  let refresh_on_change = parameter_bool(element, "refreshOnChange", false)
  let prompt = attr(element, "prompt")
  let boolean = attr_bool_schema_opt(
    element, "boolean", "Part 1 §18.13.8", "parameter",
  )
  let double = attr_double_opt_schema(element, "double")
  let integer = attr_int_opt_schema(element, "integer")
  let string = attr(element, "string")
  let cell = attr(element, "cell")
  {
    element,
    name,
    sql_type,
    parameter_type,
    refresh_on_change,
    prompt,
    boolean,
    double,
    integer,
    string,
    cell,
  }
}

///|
/// XSD complex type CT_TextPr — Part 1 §18.13.13 (`<textPr>` Text Import
/// Properties). Sequence: optional `<textFields>` (CT_TextFields).
/// Optional `@prompt` (xsd:boolean, default true); `@fileType`
/// (ST_FileType, default `win`); `@characterSet` (xsd:string);
/// `@firstRow` (xsd:unsignedInt, default 1); `@sourceFile`
/// (s:ST_Xstring, default ""); `@delimited` (xsd:boolean, default true);
/// `@decimal` (s:ST_Xstring, default "."); `@thousands` (s:ST_Xstring,
/// default ","); `@tab` (xsd:boolean, default true); `@space`, `@comma`,
/// `@semicolon`, `@consecutive` (xsd:boolean, default false);
/// `@qualifier` (ST_Qualifier, default `doubleQuote`); `@delimiter`
/// (s:ST_Xstring).
pub(all) struct CT_TextPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <textFields> (CT_TextFields) — optional text field list.
  text_fields : CT_TextFields?
  /// @prompt (xsd:boolean) — optional, default true.
  prompt : Bool
  /// @fileType (ST_FileType) — optional, default `win`.
  file_type : String
  /// @characterSet (xsd:string) — optional character-set identifier.
  character_set : String?
  /// @codePage (xsd:int) — optional code page id; `None` when absent.
  code_page : Int?
  /// @firstRow (xsd:unsignedInt) — optional, default 1.
  first_row : Int
  /// @sourceFile (s:ST_Xstring) — optional, default "".
  source_file : String
  /// @delimited (xsd:boolean) — optional, default true.
  delimited : Bool
  /// @decimal (s:ST_Xstring) — optional decimal separator, default ".".
  decimal : String
  /// @thousands (s:ST_Xstring) — optional thousands separator, default ",".
  thousands : String
  /// @tab (xsd:boolean) — optional, default true.
  tab : Bool
  /// @space (xsd:boolean) — optional, default false.
  space : Bool
  /// @comma (xsd:boolean) — optional, default false.
  comma : Bool
  /// @semicolon (xsd:boolean) — optional, default false.
  semicolon : Bool
  /// @consecutive (xsd:boolean) — optional, default false.
  consecutive : Bool
  /// @qualifier (ST_Qualifier) — optional, default `doubleQuote`.
  qualifier : String
  /// @delimiter (s:ST_Xstring) — optional custom delimiter.
  delimiter : String?
} derive(Eq, Debug)

///|
fn text_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(element, local_name, default, "Part 1 §18.13.13", "textPr")
}

///|
pub fn CT_TextPr::new(
  element : @xml.Element,
) -> CT_TextPr raise @opc_errors.SchemaViolation {
  let mut text_fields : CT_TextFields? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "textFields" {
        text_fields = Some(CT_TextFields::new(child_element))
      }
    }
  }
  let prompt = text_pr_bool(element, "prompt", true)
  let file_type = match attr(element, "fileType") {
    Some(value) => value
    None => "win"
  }
  let character_set = attr(element, "characterSet")
  let code_page = attr_uint_opt_schema(element, "codePage")
  let first_row = attr_uint_schema(element, "firstRow", 1)
  let source_file = match attr(element, "sourceFile") {
    Some(value) => value
    None => ""
  }
  let delimited = text_pr_bool(element, "delimited", true)
  let decimal = match attr(element, "decimal") {
    Some(value) => value
    None => "."
  }
  let thousands = match attr(element, "thousands") {
    Some(value) => value
    None => ","
  }
  let tab = text_pr_bool(element, "tab", true)
  let space = text_pr_bool(element, "space", false)
  let comma = text_pr_bool(element, "comma", false)
  let semicolon = text_pr_bool(element, "semicolon", false)
  let consecutive = text_pr_bool(element, "consecutive", false)
  let qualifier = match attr(element, "qualifier") {
    Some(value) => value
    None => "doubleQuote"
  }
  let delimiter = attr(element, "delimiter")
  {
    element,
    text_fields,
    prompt,
    file_type,
    character_set,
    code_page,
    first_row,
    source_file,
    delimited,
    decimal,
    thousands,
    tab,
    space,
    comma,
    semicolon,
    consecutive,
    qualifier,
    delimiter,
  }
}

///|
/// XSD complex type CT_TextFields — Part 1 §18.13.14 (`<textFields>`
/// Fields). Sequence: `<textField>+` (CT_TextField, one or more).
/// Optional `@count` (xsd:unsignedInt, default 1).
pub(all) struct CT_TextFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <textField>+ (CT_TextField) — one or more text field descriptors.
  text_field : Array[CT_TextField]
  /// @count (xsd:unsignedInt) — optional, default 1.
  count : Int
} derive(Eq, Debug)

///|
pub fn CT_TextFields::new(
  element : @xml.Element,
) -> CT_TextFields raise @opc_errors.SchemaViolation {
  let text_field : Array[CT_TextField] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "textField" {
        text_field.push(CT_TextField::new(child_element))
      }
    }
  }
  let count = attr_uint_schema(element, "count", 1)
  { element, text_field, count }
}

///|
/// XSD complex type CT_TextField — Part 1 §18.13.12 (`<textField>` Text
/// Field). Attribute-only. Optional `@type` (ST_ExternalConnectionType,
/// default `general`); `@position` (xsd:unsignedInt, default 0).
pub(all) struct CT_TextField {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @type (ST_ExternalConnectionType) — optional, default `general`.
  type_ : String
  /// @position (xsd:unsignedInt) — optional, default 0.
  position : Int
} derive(Eq, Debug)

///|
pub fn CT_TextField::new(
  element : @xml.Element,
) -> CT_TextField raise @opc_errors.SchemaViolation {
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => "general"
  }
  let position = attr_uint_schema(element, "position", 0)
  { element, type_, position }
}

///|
/// XSD complex type CT_Consolidation — Part 1 §18.10.1.13
/// (`<consolidation>` Pivot Cache Consolidation Source). Sequence:
/// optional `<pages>` (CT_Pages), required `<rangeSets>` (CT_RangeSets).
/// Optional `@autoPage` (xsd:boolean, default true).
pub(all) struct CT_Consolidation {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pages> (CT_Pages) — optional consolidation page list.
  pages : CT_Pages?
  /// <rangeSets> (CT_RangeSets) — required range set list.
  range_sets : CT_RangeSets
  /// @autoPage (xsd:boolean) — optional, default true.
  auto_page : Bool
} derive(Eq, Debug)

///|
pub fn CT_Consolidation::new(
  element : @xml.Element,
) -> CT_Consolidation raise @opc_errors.SchemaViolation {
  let mut pages : CT_Pages? = None
  let mut range_sets : CT_RangeSets? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "pages" => pages = Some(CT_Pages::new(child_element))
        "rangeSets" => range_sets = Some(CT_RangeSets::new(child_element))
        _ => ()
      }
    }
  }
  let range_sets_value = match range_sets {
    Some(value) => value
    None => CT_RangeSets::new(element)
  }
  let auto_page = attr_bool_schema(
    element, "autoPage", true, "Part 1 §18.10.1.13", "consolidation",
  )
  { element, pages, range_sets: range_sets_value, auto_page }
}

///|
/// XSD complex type CT_SharedItems — Part 1 §18.10.1.41 (`<sharedItems>`
/// Shared Items). Unbounded choice children: `<m>*` (CT_Missing), `<n>*`
/// (CT_Number), `<b>*` (CT_Boolean), `<e>*` (CT_Error), `<s>*`
/// (CT_String), `<d>*` (CT_DateTime). Optional `@containsSemiMixedTypes`,
/// `@containsNonDate`, `@containsString` (xsd:boolean, default true);
/// `@containsDate`, `@containsBlank`, `@containsMixedTypes`,
/// `@containsNumber`, `@containsInteger`, `@longText` (xsd:boolean,
/// default false); `@minValue`, `@maxValue` (xsd:double); `@minDate`,
/// `@maxDate` (xsd:dateTime); `@count` (xsd:unsignedInt).
pub(all) struct CT_SharedItems {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <m>* (CT_Missing) — zero or more missing entries.
  missings : Array[CT_Missing]
  /// <n>* (CT_Number) — zero or more number entries.
  numbers : Array[CT_Number]
  /// <b>* (CT_Boolean) — zero or more boolean entries.
  booleans : Array[CT_Boolean]
  /// <e>* (CT_Error) — zero or more error entries.
  errors : Array[CT_Error]
  /// <s>* (CT_String) — zero or more string entries.
  strings : Array[CT_String]
  /// <d>* (CT_DateTime) — zero or more dateTime entries.
  date_times : Array[CT_DateTime]
  /// @containsSemiMixedTypes (xsd:boolean) — optional, default true.
  contains_semi_mixed_types : Bool
  /// @containsNonDate (xsd:boolean) — optional, default true.
  contains_non_date : Bool
  /// @containsDate (xsd:boolean) — optional, default false.
  contains_date : Bool
  /// @containsString (xsd:boolean) — optional, default true.
  contains_string : Bool
  /// @containsBlank (xsd:boolean) — optional, default false.
  contains_blank : Bool
  /// @containsMixedTypes (xsd:boolean) — optional, default false.
  contains_mixed_types : Bool
  /// @containsNumber (xsd:boolean) — optional, default false.
  contains_number : Bool
  /// @containsInteger (xsd:boolean) — optional, default false.
  contains_integer : Bool
  /// @minValue (xsd:double) — optional minimum numeric value.
  min_value : Double?
  /// @maxValue (xsd:double) — optional maximum numeric value.
  max_value : Double?
  /// @minDate (xsd:dateTime) — optional minimum date.
  min_date : String?
  /// @maxDate (xsd:dateTime) — optional maximum date.
  max_date : String?
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
  /// @longText (xsd:boolean) — optional, default false.
  long_text : Bool
} derive(Eq, Debug)

///|
fn shared_items_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.10.1.41", "sharedItems",
  )
}

///|
pub fn CT_SharedItems::new(
  element : @xml.Element,
) -> CT_SharedItems raise @opc_errors.SchemaViolation {
  let missings : Array[CT_Missing] = []
  let numbers : Array[CT_Number] = []
  let booleans : Array[CT_Boolean] = []
  let errors : Array[CT_Error] = []
  let strings : Array[CT_String] = []
  let date_times : Array[CT_DateTime] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "m" => missings.push(CT_Missing::new(child_element))
        "n" => numbers.push(CT_Number::new(child_element))
        "b" => booleans.push(CT_Boolean::new(child_element))
        "e" => errors.push(CT_Error::new(child_element))
        "s" => strings.push(CT_String::new(child_element))
        "d" => date_times.push(CT_DateTime::new(child_element))
        _ => ()
      }
    }
  }
  let contains_semi_mixed_types = shared_items_bool(
    element, "containsSemiMixedTypes", true,
  )
  let contains_non_date = shared_items_bool(element, "containsNonDate", true)
  let contains_date = shared_items_bool(element, "containsDate", false)
  let contains_string = shared_items_bool(element, "containsString", true)
  let contains_blank = shared_items_bool(element, "containsBlank", false)
  let contains_mixed_types = shared_items_bool(
    element, "containsMixedTypes", false,
  )
  let contains_number = shared_items_bool(element, "containsNumber", false)
  let contains_integer = shared_items_bool(element, "containsInteger", false)
  let min_value = attr_double_opt_schema(element, "minValue")
  let max_value = attr_double_opt_schema(element, "maxValue")
  let min_date = attr(element, "minDate")
  let max_date = attr(element, "maxDate")
  let count = attr_uint_opt_schema(element, "count")
  let long_text = shared_items_bool(element, "longText", false)
  {
    element,
    missings,
    numbers,
    booleans,
    errors,
    strings,
    date_times,
    contains_semi_mixed_types,
    contains_non_date,
    contains_date,
    contains_string,
    contains_blank,
    contains_mixed_types,
    contains_number,
    contains_integer,
    min_value,
    max_value,
    min_date,
    max_date,
    count,
    long_text,
  }
}

///|
/// XSD complex type CT_Missing — Part 1 §18.10.1.46 (`<m>` Missing Item).
/// Sequence: `<tpls>*` (CT_Tuples) shared-tuple sub-records and `<x>*`
/// (CT_X) pivot indices. Optional `@u`, `@f` (xsd:boolean); `@c`
/// (s:ST_Xstring) caption; `@cp` (xsd:unsignedInt) caption index;
/// `@in` (xsd:unsignedInt); `@bc`, `@fc` (ST_UnsignedIntHex); `@i`,
/// `@un`, `@st`, `@b` (xsd:boolean, default false).
pub(all) struct CT_Missing {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <tpls>* (CT_Tuples) — zero or more shared-tuple sub-records.
  tpls : Array[CT_Tuples]
  /// <x>* (CT_X) — zero or more pivot tuple indices.
  x : Array[CT_X]
  /// @u (xsd:boolean) — optional unused flag.
  u : Bool?
  /// @f (xsd:boolean) — optional formula flag.
  f : Bool?
  /// @c (s:ST_Xstring) — optional caption text.
  c : String?
  /// @cp (xsd:unsignedInt) — optional caption shared-string index.
  cp : Int?
  /// @in (xsd:unsignedInt) — optional index.
  in_ : Int?
  /// @bc (ST_UnsignedIntHex) — optional background ARGB color.
  bc : Int?
  /// @fc (ST_UnsignedIntHex) — optional foreground ARGB color.
  fc : Int?
  /// @i (xsd:boolean) — optional, default false.
  i : Bool
  /// @un (xsd:boolean) — optional, default false.
  un : Bool
  /// @st (xsd:boolean) — optional, default false.
  st : Bool
  /// @b (xsd:boolean) — optional, default false.
  b : Bool
} derive(Eq, Debug)

///|
pub fn CT_Missing::new(
  element : @xml.Element,
) -> CT_Missing raise @opc_errors.SchemaViolation {
  let tpls : Array[CT_Tuples] = []
  let x : Array[CT_X] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "tpls" => tpls.push(CT_Tuples::new(child_element))
        "x" => x.push(CT_X::new(child_element))
        _ => ()
      }
    }
  }
  let u = attr_bool_schema_opt(element, "u", "Part 1 §18.10.1.46", "m")
  let f = attr_bool_schema_opt(element, "f", "Part 1 §18.10.1.46", "m")
  let c = attr(element, "c")
  let cp = attr_uint_opt_schema(element, "cp")
  let in_ = attr_uint_opt_schema(element, "in")
  let bc = attr_hex_uint_opt(element, "bc")
  let fc = attr_hex_uint_opt(element, "fc")
  let i = attr_bool_schema(element, "i", false, "Part 1 §18.10.1.46", "m")
  let un = attr_bool_schema(element, "un", false, "Part 1 §18.10.1.46", "m")
  let st = attr_bool_schema(element, "st", false, "Part 1 §18.10.1.46", "m")
  let b = attr_bool_schema(element, "b", false, "Part 1 §18.10.1.46", "m")
  { element, tpls, x, u, f, c, cp, in_, bc, fc, i, un, st, b }
}

///|
/// XSD complex type CT_Number — Part 1 §18.10.1.69 (`<n>` Numeric Item).
/// Sequence: `<tpls>*` (CT_Tuples) and `<x>*` (CT_X). Required `@v`
/// (xsd:double). Optional `@u`, `@f` (xsd:boolean); `@c` (s:ST_Xstring);
/// `@cp`, `@in` (xsd:unsignedInt); `@bc`, `@fc` (ST_UnsignedIntHex);
/// `@i`, `@un`, `@st`, `@b` (xsd:boolean, default false).
/// Schema sml.xsd complex type `CT_Number`. Attributes: `v`, `u`, `f`,
/// `c`, `cp`, `in`, `bc`, `fc`, `i`, `un`, `st`, `b`. Child elements:
/// `tpls`, `x`. Child types: `CT_Tuples`, `CT_X`.
pub(all) struct CT_Number {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <tpls>* (CT_Tuples) — zero or more shared-tuple sub-records.
  tpls : Array[CT_Tuples]
  /// <x>* (CT_X) — zero or more pivot tuple indices.
  x : Array[CT_X]
  /// @v (xsd:double) — required numeric value.
  v : Double
  /// @u (xsd:boolean) — optional unused flag.
  u : Bool?
  /// @f (xsd:boolean) — optional formula flag.
  f : Bool?
  /// @c (s:ST_Xstring) — optional caption text.
  c : String?
  /// @cp (xsd:unsignedInt) — optional caption shared-string index.
  cp : Int?
  /// @in (xsd:unsignedInt) — optional index.
  in_ : Int?
  /// @bc (ST_UnsignedIntHex) — optional background ARGB color.
  bc : Int?
  /// @fc (ST_UnsignedIntHex) — optional foreground ARGB color.
  fc : Int?
  /// @i (xsd:boolean) — optional, default false.
  i : Bool
  /// @un (xsd:boolean) — optional, default false.
  un : Bool
  /// @st (xsd:boolean) — optional, default false.
  st : Bool
  /// @b (xsd:boolean) — optional, default false.
  b : Bool
} derive(Eq, Debug)

///|
pub fn CT_Number::new(
  element : @xml.Element,
) -> CT_Number raise @opc_errors.SchemaViolation {
  let tpls : Array[CT_Tuples] = []
  let x : Array[CT_X] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "tpls" => tpls.push(CT_Tuples::new(child_element))
        "x" => x.push(CT_X::new(child_element))
        _ => ()
      }
    }
  }
  let v = attr_double_schema(element, "v", 0.0)
  let u = attr_bool_schema_opt(element, "u", "Part 1 §18.10.1.69", "n")
  let f = attr_bool_schema_opt(element, "f", "Part 1 §18.10.1.69", "n")
  let c = attr(element, "c")
  let cp = attr_uint_opt_schema(element, "cp")
  let in_ = attr_uint_opt_schema(element, "in")
  let bc = attr_hex_uint_opt(element, "bc")
  let fc = attr_hex_uint_opt(element, "fc")
  let i = attr_bool_schema(element, "i", false, "Part 1 §18.10.1.69", "n")
  let un = attr_bool_schema(element, "un", false, "Part 1 §18.10.1.69", "n")
  let st = attr_bool_schema(element, "st", false, "Part 1 §18.10.1.69", "n")
  let b = attr_bool_schema(element, "b", false, "Part 1 §18.10.1.69", "n")
  { element, tpls, x, v, u, f, c, cp, in_, bc, fc, i, un, st, b }
}

///|
/// XSD complex type CT_Error — Part 1 §18.10.1.25 (`<e>` Error Item).
/// Sequence: optional `<tpls>` (CT_Tuples) and `<x>*` (CT_X). Required
/// `@v` (s:ST_Xstring) error text. Optional `@u`, `@f` (xsd:boolean);
/// `@c` (s:ST_Xstring); `@cp`, `@in` (xsd:unsignedInt); `@bc`, `@fc`
/// (ST_UnsignedIntHex); `@i`, `@un`, `@st`, `@b` (xsd:boolean, default
/// false).
/// Schema sml.xsd complex type `CT_Error`. Attributes: `v`, `u`, `f`,
/// `c`, `cp`, `in`, `bc`, `fc`, `i`, `un`, `st`, `b`. Child elements:
/// `tpls`, `x`. Child types: `CT_Tuples`, `CT_X`.
pub(all) struct CT_Error {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <tpls> (CT_Tuples) — optional shared-tuple sub-record.
  tpls : CT_Tuples?
  /// <x>* (CT_X) — zero or more pivot tuple indices.
  x : Array[CT_X]
  /// @v (s:ST_Xstring) — required error literal.
  v : String
  /// @u (xsd:boolean) — optional unused flag.
  u : Bool?
  /// @f (xsd:boolean) — optional formula flag.
  f : Bool?
  /// @c (s:ST_Xstring) — optional caption text.
  c : String?
  /// @cp (xsd:unsignedInt) — optional caption shared-string index.
  cp : Int?
  /// @in (xsd:unsignedInt) — optional index.
  in_ : Int?
  /// @bc (ST_UnsignedIntHex) — optional background ARGB color.
  bc : Int?
  /// @fc (ST_UnsignedIntHex) — optional foreground ARGB color.
  fc : Int?
  /// @i (xsd:boolean) — optional, default false.
  i : Bool
  /// @un (xsd:boolean) — optional, default false.
  un : Bool
  /// @st (xsd:boolean) — optional, default false.
  st : Bool
  /// @b (xsd:boolean) — optional, default false.
  b : Bool
} derive(Eq, Debug)

///|
pub fn CT_Error::new(
  element : @xml.Element,
) -> CT_Error raise @opc_errors.SchemaViolation {
  let mut tpls : CT_Tuples? = None
  let x : Array[CT_X] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "tpls" => tpls = Some(CT_Tuples::new(child_element))
        "x" => x.push(CT_X::new(child_element))
        _ => ()
      }
    }
  }
  let v = match attr(element, "v") {
    Some(value) => value
    None => ""
  }
  let u = attr_bool_schema_opt(element, "u", "Part 1 §18.10.1.25", "e")
  let f = attr_bool_schema_opt(element, "f", "Part 1 §18.10.1.25", "e")
  let c = attr(element, "c")
  let cp = attr_uint_opt_schema(element, "cp")
  let in_ = attr_uint_opt_schema(element, "in")
  let bc = attr_hex_uint_opt(element, "bc")
  let fc = attr_hex_uint_opt(element, "fc")
  let i = attr_bool_schema(element, "i", false, "Part 1 §18.10.1.25", "e")
  let un = attr_bool_schema(element, "un", false, "Part 1 §18.10.1.25", "e")
  let st = attr_bool_schema(element, "st", false, "Part 1 §18.10.1.25", "e")
  let b = attr_bool_schema(element, "b", false, "Part 1 §18.10.1.25", "e")
  { element, tpls, x, v, u, f, c, cp, in_, bc, fc, i, un, st, b }
}

///|
/// XSD complex type CT_DateTime — Part 1 §18.10.1.20 (`<d>` DateTime
/// Item). Sequence: `<x>*` (CT_X) pivot indices. Required `@v`
/// (xsd:dateTime) date payload. Optional `@u`, `@f` (xsd:boolean); `@c`
/// (s:ST_Xstring) caption; `@cp` (xsd:unsignedInt) caption index.
pub(all) struct CT_DateTime {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <x>* (CT_X) — zero or more pivot tuple indices.
  x : Array[CT_X]
  /// @v (xsd:dateTime) — required dateTime literal.
  v : String
  /// @u (xsd:boolean) — optional unused flag.
  u : Bool?
  /// @f (xsd:boolean) — optional formula flag.
  f : Bool?
  /// @c (s:ST_Xstring) — optional caption text.
  c : String?
  /// @cp (xsd:unsignedInt) — optional caption shared-string index.
  cp : Int?
} derive(Eq, Debug)

///|
pub fn CT_DateTime::new(
  element : @xml.Element,
) -> CT_DateTime raise @opc_errors.SchemaViolation {
  let x : Array[CT_X] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "x" {
        x.push(CT_X::new(child_element))
      }
    }
  }
  let v = match attr(element, "v") {
    Some(value) => value
    None => ""
  }
  let u = attr_bool_schema_opt(element, "u", "Part 1 §18.10.1.20", "d")
  let f = attr_bool_schema_opt(element, "f", "Part 1 §18.10.1.20", "d")
  let c = attr(element, "c")
  let cp = attr_uint_opt_schema(element, "cp")
  { element, x, v, u, f, c, cp }
}

///|
/// XSD complex type CT_FieldGroup — Part 1 §18.10.1.29 (`<fieldGroup>`
/// Field Group). Sequence: optional `<rangePr>` (CT_RangePr),
/// `<discretePr>` (CT_DiscretePr), `<groupItems>` (CT_GroupItems).
/// Optional `@par` (xsd:unsignedInt) parent group; `@base`
/// (xsd:unsignedInt) base field.
pub(all) struct CT_FieldGroup {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <rangePr> (CT_RangePr) — optional range-based grouping.
  range_pr : CT_RangePr?
  /// <discretePr> (CT_DiscretePr) — optional discrete grouping.
  discrete_pr : CT_DiscretePr?
  /// <groupItems> (CT_GroupItems) — optional group item list.
  group_items : CT_GroupItems?
  /// @par (xsd:unsignedInt) — optional parent group index.
  par : Int?
  /// @base (xsd:unsignedInt) — optional base field index.
  base : Int?
} derive(Eq, Debug)

///|
pub fn CT_FieldGroup::new(
  element : @xml.Element,
) -> CT_FieldGroup raise @opc_errors.SchemaViolation {
  let mut range_pr : CT_RangePr? = None
  let mut discrete_pr : CT_DiscretePr? = None
  let mut group_items : CT_GroupItems? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "rangePr" => range_pr = Some(CT_RangePr::new(child_element))
        "discretePr" => discrete_pr = Some(CT_DiscretePr::new(child_element))
        "groupItems" => group_items = Some(CT_GroupItems::new(child_element))
        _ => ()
      }
    }
  }
  let par = attr_uint_opt_schema(element, "par")
  let base = attr_uint_opt_schema(element, "base")
  { element, range_pr, discrete_pr, group_items, par, base }
}

///|
/// XSD complex type CT_RangePr — Part 1 §18.10.1.78 (`<rangePr>` Range
/// Grouping). Attribute-only. Optional `@autoStart`, `@autoEnd`
/// (xsd:boolean, default true); `@groupBy` (ST_GroupBy, default `range`);
/// `@startNum`, `@endNum` (xsd:double); `@startDate`, `@endDate`
/// (xsd:dateTime); `@groupInterval` (xsd:double, default 1).
pub(all) struct CT_RangePr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @autoStart (xsd:boolean) — optional, default true.
  auto_start : Bool
  /// @autoEnd (xsd:boolean) — optional, default true.
  auto_end : Bool
  /// @groupBy (ST_GroupBy) — optional, default `range`.
  group_by : String
  /// @startNum (xsd:double) — optional numeric start value.
  start_num : Double?
  /// @endNum (xsd:double) — optional numeric end value.
  end_num : Double?
  /// @startDate (xsd:dateTime) — optional date start value.
  start_date : String?
  /// @endDate (xsd:dateTime) — optional date end value.
  end_date : String?
  /// @groupInterval (xsd:double) — optional, default 1.
  group_interval : Double
} derive(Eq, Debug)

///|
pub fn CT_RangePr::new(
  element : @xml.Element,
) -> CT_RangePr raise @opc_errors.SchemaViolation {
  let auto_start = attr_bool_schema(
    element, "autoStart", true, "Part 1 §18.10.1.78", "rangePr",
  )
  let auto_end = attr_bool_schema(
    element, "autoEnd", true, "Part 1 §18.10.1.78", "rangePr",
  )
  let group_by = match attr(element, "groupBy") {
    Some(value) => value
    None => "range"
  }
  let start_num = attr_double_opt_schema(element, "startNum")
  let end_num = attr_double_opt_schema(element, "endNum")
  let start_date = attr(element, "startDate")
  let end_date = attr(element, "endDate")
  let group_interval = attr_double_schema(element, "groupInterval", 1.0)
  {
    element,
    auto_start,
    auto_end,
    group_by,
    start_num,
    end_num,
    start_date,
    end_date,
    group_interval,
  }
}

///|
/// XSD complex type CT_DiscretePr — Part 1 §18.10.1.23 (`<discretePr>`
/// Discrete Grouping Properties). Sequence: `<x>+` (CT_Index, one or
/// more). Optional `@count` (xsd:unsignedInt).
pub(all) struct CT_DiscretePr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <x>+ (CT_Index) — one or more discrete index entries.
  x : Array[CT_Index]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_DiscretePr::new(
  element : @xml.Element,
) -> CT_DiscretePr raise @opc_errors.SchemaViolation {
  let x : Array[CT_Index] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "x" {
        x.push(CT_Index::new(child_element))
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, x, count }
}

///|
/// XSD complex type CT_GroupItems — Part 1 §18.10.1.31 (`<groupItems>`
/// Group Items). Unbounded choice children: `<m>*` (CT_Missing), `<n>*`
/// (CT_Number), `<b>*` (CT_Boolean), `<e>*` (CT_Error), `<s>*`
/// (CT_String), `<d>*` (CT_DateTime). Optional `@count`
/// (xsd:unsignedInt).
pub(all) struct CT_GroupItems {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <m>* (CT_Missing) — zero or more missing entries.
  missings : Array[CT_Missing]
  /// <n>* (CT_Number) — zero or more number entries.
  numbers : Array[CT_Number]
  /// <b>* (CT_Boolean) — zero or more boolean entries.
  booleans : Array[CT_Boolean]
  /// <e>* (CT_Error) — zero or more error entries.
  errors : Array[CT_Error]
  /// <s>* (CT_String) — zero or more string entries.
  strings : Array[CT_String]
  /// <d>* (CT_DateTime) — zero or more dateTime entries.
  date_times : Array[CT_DateTime]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_GroupItems::new(
  element : @xml.Element,
) -> CT_GroupItems raise @opc_errors.SchemaViolation {
  let missings : Array[CT_Missing] = []
  let numbers : Array[CT_Number] = []
  let booleans : Array[CT_Boolean] = []
  let errors : Array[CT_Error] = []
  let strings : Array[CT_String] = []
  let date_times : Array[CT_DateTime] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "m" => missings.push(CT_Missing::new(child_element))
        "n" => numbers.push(CT_Number::new(child_element))
        "b" => booleans.push(CT_Boolean::new(child_element))
        "e" => errors.push(CT_Error::new(child_element))
        "s" => strings.push(CT_String::new(child_element))
        "d" => date_times.push(CT_DateTime::new(child_element))
        _ => ()
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, missings, numbers, booleans, errors, strings, date_times, count }
}

///|
/// XSD complex type CT_Record — Part 1 §18.10.1.82 (`<r>` PivotCache
/// Record). Unbounded choice children: `<m>*` (CT_Missing), `<n>*`
/// (CT_Number), `<b>*` (CT_Boolean), `<e>*` (CT_Error), `<s>*`
/// (CT_String), `<d>*` (CT_DateTime), `<x>*` (CT_Index). No attributes.
pub(all) struct CT_Record {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <m>* (CT_Missing) — zero or more missing entries.
  missings : Array[CT_Missing]
  /// <n>* (CT_Number) — zero or more number entries.
  numbers : Array[CT_Number]
  /// <b>* (CT_Boolean) — zero or more boolean entries.
  booleans : Array[CT_Boolean]
  /// <e>* (CT_Error) — zero or more error entries.
  errors : Array[CT_Error]
  /// <s>* (CT_String) — zero or more string entries.
  strings : Array[CT_String]
  /// <d>* (CT_DateTime) — zero or more dateTime entries.
  date_times : Array[CT_DateTime]
  /// <x>* (CT_Index) — zero or more shared-item index references.
  x : Array[CT_Index]
} derive(Eq, Debug)

///|
pub fn CT_Record::new(
  element : @xml.Element,
) -> CT_Record raise @opc_errors.SchemaViolation {
  let missings : Array[CT_Missing] = []
  let numbers : Array[CT_Number] = []
  let booleans : Array[CT_Boolean] = []
  let errors : Array[CT_Error] = []
  let strings : Array[CT_String] = []
  let date_times : Array[CT_DateTime] = []
  let x : Array[CT_Index] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "m" => missings.push(CT_Missing::new(child_element))
        "n" => numbers.push(CT_Number::new(child_element))
        "b" => booleans.push(CT_Boolean::new(child_element))
        "e" => errors.push(CT_Error::new(child_element))
        "s" => strings.push(CT_String::new(child_element))
        "d" => date_times.push(CT_DateTime::new(child_element))
        "x" => x.push(CT_Index::new(child_element))
        _ => ()
      }
    }
  }
  { element, missings, numbers, booleans, errors, strings, date_times, x }
}

///|
/// XSD complex type CT_FieldsUsage — Part 1 §18.10.1.27 (`<fieldsUsage>`
/// Field Usage List). Sequence: `<fieldUsage>*` (CT_FieldUsage). Optional
/// `@count` (xsd:unsignedInt).
pub(all) struct CT_FieldsUsage {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <fieldUsage>* (CT_FieldUsage) — zero or more field usage entries.
  field_usage : Array[CT_FieldUsage]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_FieldsUsage::new(
  element : @xml.Element,
) -> CT_FieldsUsage raise @opc_errors.SchemaViolation {
  let field_usage : Array[CT_FieldUsage] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "fieldUsage" {
        field_usage.push(CT_FieldUsage::new(child_element))
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, field_usage, count }
}

///|
/// XSD complex type CT_FieldUsage — Part 1 §18.10.1.26 (`<fieldUsage>`
/// Field Usage). Attribute-only. Required `@x` (xsd:int) field index.
pub(all) struct CT_FieldUsage {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @x (xsd:int) — required field index.
  x : Int
} derive(Eq, Debug)

///|
pub fn CT_FieldUsage::new(
  element : @xml.Element,
) -> CT_FieldUsage raise @opc_errors.SchemaViolation {
  let x = attr_int_schema(element, "x", 0)
  { element, x }
}

///|
/// XSD complex type CT_GroupLevels — Part 1 §18.10.1.33 (`<groupLevels>`
/// OLAP Grouping Levels). Sequence: `<groupLevel>+` (CT_GroupLevel, one
/// or more). Optional `@count` (xsd:unsignedInt).
pub(all) struct CT_GroupLevels {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <groupLevel>+ (CT_GroupLevel) — one or more group level entries.
  group_level : Array[CT_GroupLevel]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_GroupLevels::new(
  element : @xml.Element,
) -> CT_GroupLevels raise @opc_errors.SchemaViolation {
  let group_level : Array[CT_GroupLevel] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "groupLevel" {
        group_level.push(CT_GroupLevel::new(child_element))
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, group_level, count }
}

///|
/// XSD complex type CT_GroupLevel — Part 1 §18.10.1.32 (`<groupLevel>`
/// OLAP Grouping Level). Sequence: optional `<groups>` (CT_Groups);
/// optional `<extLst>` (CT_ExtensionList). Required `@uniqueName`
/// (s:ST_Xstring), `@caption` (s:ST_Xstring). Optional `@user`,
/// `@customRollUp` (xsd:boolean, default false).
pub(all) struct CT_GroupLevel {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <groups> (CT_Groups) — optional group list.
  groups : CT_Groups?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @uniqueName (s:ST_Xstring) — required unique name.
  unique_name : String
  /// @caption (s:ST_Xstring) — required caption.
  caption : String
  /// @user (xsd:boolean) — optional, default false.
  user : Bool
  /// @customRollUp (xsd:boolean) — optional, default false.
  custom_roll_up : Bool
} derive(Eq, Debug)

///|
pub fn CT_GroupLevel::new(
  element : @xml.Element,
) -> CT_GroupLevel raise @opc_errors.SchemaViolation {
  let mut groups : CT_Groups? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "groups" => groups = Some(CT_Groups::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let unique_name = match attr(element, "uniqueName") {
    Some(value) => value
    None => ""
  }
  let caption = match attr(element, "caption") {
    Some(value) => value
    None => ""
  }
  let user = attr_bool_schema(
    element, "user", false, "Part 1 §18.10.1.32", "groupLevel",
  )
  let custom_roll_up = attr_bool_schema(
    element, "customRollUp", false, "Part 1 §18.10.1.32", "groupLevel",
  )
  { element, groups, ext_lst, unique_name, caption, user, custom_roll_up }
}

///|
/// XSD complex type CT_Groups — Part 1 §18.10.1.34 (`<groups>` OLAP
/// Level Groups). Sequence: `<group>+` (CT_LevelGroup, one or more).
/// Optional `@count` (xsd:unsignedInt).
/// Schema sml.xsd complex type `CT_Groups`. Attributes: `count`. Child
/// elements: `group`. Child types: `CT_LevelGroup`.
pub(all) struct CT_Groups {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <group>+ (CT_LevelGroup) — one or more level groups.
  group : Array[CT_LevelGroup]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_Groups::new(
  element : @xml.Element,
) -> CT_Groups raise @opc_errors.SchemaViolation {
  let group : Array[CT_LevelGroup] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "group" {
        group.push(CT_LevelGroup::new(child_element))
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, group, count }
}

///|
/// XSD complex type CT_LevelGroup — Part 1 §18.10.1.45 (`<group>` OLAP
/// Level Group). Sequence: required `<groupMembers>` (CT_GroupMembers).
/// Required `@name`, `@uniqueName`, `@caption` (s:ST_Xstring); optional
/// `@uniqueParent` (s:ST_Xstring); `@id` (xsd:int).
pub(all) struct CT_LevelGroup {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <groupMembers> (CT_GroupMembers) — required group member list.
  group_members : CT_GroupMembers
  /// @name (s:ST_Xstring) — required name.
  name : String
  /// @uniqueName (s:ST_Xstring) — required unique name.
  unique_name : String
  /// @caption (s:ST_Xstring) — required caption.
  caption : String
  /// @uniqueParent (s:ST_Xstring) — optional parent unique name.
  unique_parent : String?
  /// @id (xsd:int) — optional level group identifier.
  id : Int?
} derive(Eq, Debug)

///|
pub fn CT_LevelGroup::new(
  element : @xml.Element,
) -> CT_LevelGroup raise @opc_errors.SchemaViolation {
  let mut group_members : CT_GroupMembers? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "groupMembers" {
        group_members = Some(CT_GroupMembers::new(child_element))
      }
    }
  }
  let group_members_value = match group_members {
    Some(value) => value
    None => CT_GroupMembers::new(element)
  }
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let unique_name = match attr(element, "uniqueName") {
    Some(value) => value
    None => ""
  }
  let caption = match attr(element, "caption") {
    Some(value) => value
    None => ""
  }
  let unique_parent = attr(element, "uniqueParent")
  let id = attr_int_opt_schema(element, "id")
  {
    element,
    group_members: group_members_value,
    name,
    unique_name,
    caption,
    unique_parent,
    id,
  }
}

///|
/// XSD complex type CT_ServerFormat — Part 1 §18.10.1.86
/// (`<serverFormat>` OLAP Server Format). Attribute-only. Optional
/// `@culture` (s:ST_Xstring); `@format` (s:ST_Xstring).
pub(all) struct CT_ServerFormat {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @culture (s:ST_Xstring) — optional culture identifier.
  culture : String?
  /// @format (s:ST_Xstring) — optional format string.
  format : String?
} derive(Eq, Debug)

///|
pub fn CT_ServerFormat::new(element : @xml.Element) -> CT_ServerFormat {
  let culture = attr(element, "culture")
  let format = attr(element, "format")
  { element, culture, format }
}

///|
/// XSD complex type CT_ServerFormats — Part 1 §18.10.1.87
/// (`<serverFormats>` OLAP Server Formats). Sequence: `<serverFormat>*`
/// (CT_ServerFormat). Optional `@count` (xsd:unsignedInt).
pub(all) struct CT_ServerFormats {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <serverFormat>* (CT_ServerFormat) — zero or more server formats.
  server_format : Array[CT_ServerFormat]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_ServerFormats::new(
  element : @xml.Element,
) -> CT_ServerFormats raise @opc_errors.SchemaViolation {
  let server_format : Array[CT_ServerFormat] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "serverFormat" {
        server_format.push(CT_ServerFormat::new(child_element))
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, server_format, count }
}

///|
/// XSD complex type CT_Location — Part 1 §18.10.1.49 (`<location>`
/// PivotTable Location). Attribute-only. Required `@ref` (ST_Ref),
/// `@firstHeaderRow`, `@firstDataRow`, `@firstDataCol`
/// (xsd:unsignedInt). Optional `@rowPageCount`, `@colPageCount`
/// (xsd:unsignedInt, default 0).
pub(all) struct CT_Location {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ref (ST_Ref) — required pivot table reference.
  ref_ : String
  /// @firstHeaderRow (xsd:unsignedInt) — required first header row.
  first_header_row : Int
  /// @firstDataRow (xsd:unsignedInt) — required first data row.
  first_data_row : Int
  /// @firstDataCol (xsd:unsignedInt) — required first data column.
  first_data_col : Int
  /// @rowPageCount (xsd:unsignedInt) — optional, default 0.
  row_page_count : Int
  /// @colPageCount (xsd:unsignedInt) — optional, default 0.
  col_page_count : Int
} derive(Eq, Debug)

///|
pub fn CT_Location::new(
  element : @xml.Element,
) -> CT_Location raise @opc_errors.SchemaViolation {
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  let first_header_row = attr_uint_schema(element, "firstHeaderRow", 0)
  let first_data_row = attr_uint_schema(element, "firstDataRow", 0)
  let first_data_col = attr_uint_schema(element, "firstDataCol", 0)
  let row_page_count = attr_uint_schema(element, "rowPageCount", 0)
  let col_page_count = attr_uint_schema(element, "colPageCount", 0)
  {
    element,
    ref_,
    first_header_row,
    first_data_row,
    first_data_col,
    row_page_count,
    col_page_count,
  }
}

///|
/// XSD complex type CT_AutoSortScope — Part 1 §18.10.1.5
/// (`<autoSortScope>` AutoSort Scope). Sequence: required `<pivotArea>`
/// (CT_PivotArea). No attributes.
pub(all) struct CT_AutoSortScope {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pivotArea> (CT_PivotArea) — required pivot area.
  pivot_area : CT_PivotArea
} derive(Eq, Debug)

///|
pub fn CT_AutoSortScope::new(
  element : @xml.Element,
) -> CT_AutoSortScope raise @opc_errors.SchemaViolation {
  let mut pivot_area : CT_PivotArea? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pivotArea" {
        pivot_area = Some(CT_PivotArea::new(child_element))
      }
    }
  }
  let pivot_area_value = match pivot_area {
    Some(value) => value
    None => CT_PivotArea::new(element)
  }
  { element, pivot_area: pivot_area_value }
}

///|
/// XSD complex type CT_Items — Part 1 §18.10.1.40 (`<items>` Field
/// Items). Sequence: `<item>+` (CT_Item, one or more). Optional `@count`
/// (xsd:unsignedInt).
pub(all) struct CT_Items {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <item>+ (CT_Item) — one or more pivot item entries.
  item : Array[CT_Item]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_Items::new(
  element : @xml.Element,
) -> CT_Items raise @opc_errors.SchemaViolation {
  let item : Array[CT_Item] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "item" {
        item.push(CT_Item::new(child_element))
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, item, count }
}

///|
fn item_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(element, local_name, default, "Part 1 §18.10.1.43", "item")
}

///|
/// XSD complex type CT_Item — Part 1 §18.10.1.43 (`<item>` PivotField
/// Item). Attribute-only. Optional `@n` (s:ST_Xstring) caption; `@t`
/// (ST_ItemType, default `data`); `@h` (default false), `@s` (false),
/// `@sd` (true), `@f` (false), `@m` (false), `@c` (false) (xsd:boolean);
/// `@x` (xsd:unsignedInt); `@d` (false), `@e` (true) (xsd:boolean).
pub(all) struct CT_Item {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @n (s:ST_Xstring) — optional caption string.
  n : String?
  /// @t (ST_ItemType) — optional, default `data`.
  t : String
  /// @h (xsd:boolean) — optional, default false (hidden).
  h : Bool
  /// @s (xsd:boolean) — optional, default false (set source flag).
  s : Bool
  /// @sd (xsd:boolean) — optional, default true (show detail).
  sd : Bool
  /// @f (xsd:boolean) — optional, default false (calculated).
  f : Bool
  /// @m (xsd:boolean) — optional, default false (missing).
  m : Bool
  /// @c (xsd:boolean) — optional, default false (cached approx).
  c : Bool
  /// @x (xsd:unsignedInt) — optional shared item index.
  x : Int?
  /// @d (xsd:boolean) — optional, default false (drill).
  d : Bool
  /// @e (xsd:boolean) — optional, default true (expand).
  e : Bool
} derive(Eq, Debug)

///|
pub fn CT_Item::new(
  element : @xml.Element,
) -> CT_Item raise @opc_errors.SchemaViolation {
  let n = attr(element, "n")
  let t = match attr(element, "t") {
    Some(value) => value
    None => "data"
  }
  let h = item_bool(element, "h", false)
  let s = item_bool(element, "s", false)
  let sd = item_bool(element, "sd", true)
  let f = item_bool(element, "f", false)
  let m = item_bool(element, "m", false)
  let c = item_bool(element, "c", false)
  let x = attr_uint_opt_schema(element, "x")
  let d = item_bool(element, "d", false)
  let e = item_bool(element, "e", true)
  { element, n, t, h, s, sd, f, m, c, x, d, e }
}

///|
/// Schema sml.xsd complex type `CT_I`. Attributes: `t`, `r`, `i`.
/// Child elements: `x`. Child types: `CT_X`.
///
/// XSD complex type CT_I — Part 1 §18.10.1.37 (`<i>` Row Item).
/// Sequence: `<x>*` (CT_X) zero or more member index entries.
/// Optional `@t` (ST_ItemType, default `data`); `@r` (xsd:unsignedInt,
/// default 0) repeated-item count; `@i` (xsd:unsignedInt, default 0)
/// data field index.
pub(all) struct CT_I {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <x>* (CT_X) — zero or more pivot tuple indices.
  x : Array[CT_X]
  /// @t (ST_ItemType) — optional, default `data`.
  t : String
  /// @r (xsd:unsignedInt) — optional repeated item count, default 0.
  r : Int
  /// @i (xsd:unsignedInt) — optional data field index, default 0.
  i : Int
} derive(Eq, Debug)

///|
pub fn CT_I::new(
  element : @xml.Element,
) -> CT_I raise @opc_errors.SchemaViolation {
  let x : Array[CT_X] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "x" {
        x.push(CT_X::new(child_element))
      }
    }
  }
  let t = match attr(element, "t") {
    Some(value) => value
    None => "data"
  }
  let r = attr_uint_schema(element, "r", 0)
  let i = attr_uint_schema(element, "i", 0)
  { element, x, t, r, i }
}

///|
/// XSD complex type CT_X — Part 1 §18.10.1.108 (`<x>` Pivot Tuple Index).
/// Attribute-only. Optional `@v` (xsd:int, default 0) shared-items index.
/// Schema sml.xsd complex type `CT_X`. Attributes: `v`.
pub(all) struct CT_X {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @v (xsd:int) — optional shared items index, default 0.
  v : Int
} derive(Eq, Debug)

///|
pub fn CT_X::new(
  element : @xml.Element,
) -> CT_X raise @opc_errors.SchemaViolation {
  let v = attr_int_schema(element, "v", 0)
  { element, v }
}

///|
/// XSD complex type CT_Field — Part 1 §18.10.1.28 (`<field>` Field
/// Reference). Attribute-only. Required `@x` (xsd:int) field index.
/// Schema sml.xsd complex type `CT_Field`. Attributes: `x`.
pub(all) struct CT_Field {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @x (xsd:int) — required field index.
  x : Int
} derive(Eq, Debug)

///|
pub fn CT_Field::new(
  element : @xml.Element,
) -> CT_Field raise @opc_errors.SchemaViolation {
  let x = attr_int_schema(element, "x", 0)
  { element, x }
}

///|
/// XSD complex type CT_Formats — Part 1 §18.10.1.30 (`<formats>` Pivot
/// Formats). Sequence: `<format>+` (CT_Format, one or more). Optional
/// `@count` (xsd:unsignedInt, default 0).
pub(all) struct CT_Formats {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <format>+ (CT_Format) — one or more pivot format entries.
  format : Array[CT_Format]
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
} derive(Eq, Debug)

///|
pub fn CT_Formats::new(
  element : @xml.Element,
) -> CT_Formats raise @opc_errors.SchemaViolation {
  let format : Array[CT_Format] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "format" {
        format.push(CT_Format::new(child_element))
      }
    }
  }
  let count = attr_uint_schema(element, "count", 0)
  { element, format, count }
}

///|
/// XSD complex type CT_Format — Part 1 §18.10.1.30 (`<format>` Pivot
/// Format). Sequence: required `<pivotArea>` (CT_PivotArea); optional
/// `<extLst>` (CT_ExtensionList). Optional `@action` (ST_FormatAction,
/// default `formatting`); `@dxfId` (ST_DxfId).
pub(all) struct CT_Format {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pivotArea> (CT_PivotArea) — required pivot area.
  pivot_area : CT_PivotArea
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @action (ST_FormatAction) — optional, default `formatting`.
  action : String
  /// @dxfId (ST_DxfId) — optional differential format index.
  dxf_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_Format::new(
  element : @xml.Element,
) -> CT_Format raise @opc_errors.SchemaViolation {
  let mut pivot_area : CT_PivotArea? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "pivotArea" => pivot_area = Some(CT_PivotArea::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let pivot_area_value = match pivot_area {
    Some(value) => value
    None => CT_PivotArea::new(element)
  }
  let action = match attr(element, "action") {
    Some(value) => value
    None => "formatting"
  }
  let dxf_id = attr_uint_opt_schema(element, "dxfId")
  { element, pivot_area: pivot_area_value, ext_lst, action, dxf_id }
}

///|
/// XSD complex type CT_Dimensions — Part 1 §18.10.1.22 (`<dimensions>`
/// OLAP Dimensions). Sequence: `<dimension>*` (CT_PivotDimension).
/// Optional `@count` (xsd:unsignedInt).
pub(all) struct CT_Dimensions {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <dimension>* (CT_PivotDimension) — zero or more dimensions.
  dimension : Array[CT_PivotDimension]
  /// @count (xsd:unsignedInt) — optional declared count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_Dimensions::new(
  element : @xml.Element,
) -> CT_Dimensions raise @opc_errors.SchemaViolation {
  let dimension : Array[CT_PivotDimension] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "dimension" {
        dimension.push(CT_PivotDimension::new(child_element))
      }
    }
  }
  let count = attr_uint_opt_schema(element, "count")
  { element, dimension, count }
}

///|
/// XSD complex type CT_Index — Part 1 §18.10.1.38 (`<x>` Shared Items
/// Index). Attribute-only. Required `@v` (xsd:unsignedInt) index value.
/// Schema sml.xsd complex type `CT_Index`. Attributes: `v`.
pub(all) struct CT_Index {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @v (xsd:unsignedInt) — required shared-items index value.
  v : Int
} derive(Eq, Debug)

///|
pub fn CT_Index::new(
  element : @xml.Element,
) -> CT_Index raise @opc_errors.SchemaViolation {
  let v = attr_uint_schema(element, "v", 0)
  { element, v }
}

///|
/// XSD complex type CT_DeletedField — Part 1 §18.12.7 (`<deletedField>`
/// Deleted QueryTable Field). Attribute-only. Required `@name`
/// (s:ST_Xstring).
pub(all) struct CT_DeletedField {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required deleted field name.
  name : String
} derive(Eq, Debug)

///|
pub fn CT_DeletedField::new(element : @xml.Element) -> CT_DeletedField {
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  { element, name }
}

///|
/// XSD complex type CT_Revisions — Part 1 §18.11.1.20 (`<revisions>`
/// Revisions root). Unbounded choice children: `<rrc>*`
/// (CT_RevisionRowColumn), `<rm>*` (CT_RevisionMove), `<rcv>*`
/// (CT_RevisionCustomView), `<rsnm>*` (CT_RevisionSheetRename), `<ris>*`
/// (CT_RevisionInsertSheet), `<rcc>*` (CT_RevisionCellChange), `<rfmt>*`
/// (CT_RevisionFormatting), `<raf>*` (CT_RevisionAutoFormatting),
/// `<rdn>*` (CT_RevisionDefinedName), `<rcmt>*` (CT_RevisionComment),
/// `<rqt>*` (CT_RevisionQueryTableField), `<rcft>*`
/// (CT_RevisionConflict). No attributes.
pub(all) struct CT_Revisions {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <rrc>* (CT_RevisionRowColumn) — zero or more row/column revisions.
  rrc : Array[CT_RevisionRowColumn]
  /// <rm>* (CT_RevisionMove) — zero or more move revisions.
  rm : Array[CT_RevisionMove]
  /// <rcv>* (CT_RevisionCustomView) — zero or more custom view revisions.
  rcv : Array[CT_RevisionCustomView]
  /// <rsnm>* (CT_RevisionSheetRename) — zero or more sheet rename revisions.
  rsnm : Array[CT_RevisionSheetRename]
  /// <ris>* (CT_RevisionInsertSheet) — zero or more sheet insert revisions.
  ris : Array[CT_RevisionInsertSheet]
  /// <rcc>* (CT_RevisionCellChange) — zero or more cell-change revisions.
  rcc : Array[CT_RevisionCellChange]
  /// <rfmt>* (CT_RevisionFormatting) — zero or more formatting revisions.
  rfmt : Array[CT_RevisionFormatting]
  /// <raf>* (CT_RevisionAutoFormatting) — zero or more autoformatting
  /// revisions.
  raf : Array[CT_RevisionAutoFormatting]
  /// <rdn>* (CT_RevisionDefinedName) — zero or more defined-name revisions.
  rdn : Array[CT_RevisionDefinedName]
  /// <rcmt>* (CT_RevisionComment) — zero or more comment revisions.
  rcmt : Array[CT_RevisionComment]
  /// <rqt>* (CT_RevisionQueryTableField) — zero or more query-table field
  /// revisions.
  rqt : Array[CT_RevisionQueryTableField]
  /// <rcft>* (CT_RevisionConflict) — zero or more conflict revisions.
  rcft : Array[CT_RevisionConflict]
} derive(Eq, Debug)

///|
pub fn CT_Revisions::new(
  element : @xml.Element,
) -> CT_Revisions raise @opc_errors.SchemaViolation {
  let rrc : Array[CT_RevisionRowColumn] = []
  let rm : Array[CT_RevisionMove] = []
  let rcv : Array[CT_RevisionCustomView] = []
  let rsnm : Array[CT_RevisionSheetRename] = []
  let ris : Array[CT_RevisionInsertSheet] = []
  let rcc : Array[CT_RevisionCellChange] = []
  let rfmt : Array[CT_RevisionFormatting] = []
  let raf : Array[CT_RevisionAutoFormatting] = []
  let rdn : Array[CT_RevisionDefinedName] = []
  let rcmt : Array[CT_RevisionComment] = []
  let rqt : Array[CT_RevisionQueryTableField] = []
  let rcft : Array[CT_RevisionConflict] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "rrc" => rrc.push(CT_RevisionRowColumn::new(child_element))
        "rm" => rm.push(CT_RevisionMove::new(child_element))
        "rcv" => rcv.push(CT_RevisionCustomView::new(child_element))
        "rsnm" => rsnm.push(CT_RevisionSheetRename::new(child_element))
        "ris" => ris.push(CT_RevisionInsertSheet::new(child_element))
        "rcc" => rcc.push(CT_RevisionCellChange::new(child_element))
        "rfmt" => rfmt.push(CT_RevisionFormatting::new(child_element))
        "raf" => raf.push(CT_RevisionAutoFormatting::new(child_element))
        "rdn" => rdn.push(CT_RevisionDefinedName::new(child_element))
        "rcmt" => rcmt.push(CT_RevisionComment::new(child_element))
        "rqt" => rqt.push(CT_RevisionQueryTableField::new(child_element))
        "rcft" => rcft.push(CT_RevisionConflict::new(child_element))
        _ => ()
      }
    }
  }
  { element, rrc, rm, rcv, rsnm, ris, rcc, rfmt, raf, rdn, rcmt, rqt, rcft }
}

///|
/// XSD complex type CT_UndoInfo — Part 1 §18.11.1.27 (`<undo>` Undo
/// Information). Attribute-only. Required `@index` (xsd:unsignedInt),
/// `@exp` (ST_FormulaExpression), `@dr` (ST_RefA). Optional `@ref3D`
/// (xsd:boolean, default false); `@array` (false); `@v` (false);
/// `@nf` (false); `@cs` (false); `@dn` (s:ST_Xstring); `@r`
/// (ST_CellRef); `@sId` (xsd:unsignedInt).
pub(all) struct CT_UndoInfo {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @index (xsd:unsignedInt) — required formula-record index.
  index : Int
  /// @exp (ST_FormulaExpression) — required expression kind.
  exp : String
  /// @ref3D (xsd:boolean) — optional, default false.
  ref3_d : Bool
  /// @array (xsd:boolean) — optional, default false.
  array : Bool
  /// @v (xsd:boolean) — optional, default false.
  v : Bool
  /// @nf (xsd:boolean) — optional, default false.
  nf : Bool
  /// @cs (xsd:boolean) — optional, default false.
  cs : Bool
  /// @dr (ST_RefA) — required dependency range reference.
  dr : String
  /// @dn (s:ST_Xstring) — optional defined name reference.
  dn : String?
  /// @r (ST_CellRef) — optional cell reference.
  r : String?
  /// @sId (xsd:unsignedInt) — optional sheet identifier.
  s_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_UndoInfo::new(
  element : @xml.Element,
) -> CT_UndoInfo raise @opc_errors.SchemaViolation {
  let index = attr_uint_schema(element, "index", 0)
  let exp = match attr(element, "exp") {
    Some(value) => value
    None => ""
  }
  let ref3_d = revision_bool(
    element, "ref3D", false, "Part 1 §18.11.1.27", "undo",
  )
  let array = revision_bool(
    element, "array", false, "Part 1 §18.11.1.27", "undo",
  )
  let v = revision_bool(element, "v", false, "Part 1 §18.11.1.27", "undo")
  let nf = revision_bool(element, "nf", false, "Part 1 §18.11.1.27", "undo")
  let cs = revision_bool(element, "cs", false, "Part 1 §18.11.1.27", "undo")
  let dr = match attr(element, "dr") {
    Some(value) => value
    None => ""
  }
  let dn = attr(element, "dn")
  let r = attr(element, "r")
  let s_id = attr_uint_opt_schema(element, "sId")
  { element, index, exp, ref3_d, array, v, nf, cs, dr, dn, r, s_id }
}

///|
/// XSD complex type CT_RevisionMove — Part 1 §18.11.1.19 (`<rm>` Revision
/// Cell Move). Records a cell-range move. Unbounded choice children:
/// `<undo>*` (CT_UndoInfo), `<rcc>*` (CT_RevisionCellChange) and
/// `<rfmt>*` (CT_RevisionFormatting). Attributes from AG_RevData:
/// required `@rId` (xsd:unsignedInt), optional `@ua` (xsd:boolean,
/// default false), optional `@ra` (xsd:boolean, default false).
/// Type-specific: required `@sheetId` (xsd:unsignedInt), required
/// `@source` (ST_Ref), required `@destination` (ST_Ref); optional
/// `@sourceSheetId` (xsd:unsignedInt, default 0).
pub(all) struct CT_RevisionMove {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <undo>* (CT_UndoInfo) — zero or more undo records.
  undo : Array[CT_UndoInfo]
  /// <rcc>* (CT_RevisionCellChange) — zero or more cell-change records.
  rcc : Array[CT_RevisionCellChange]
  /// <rfmt>* (CT_RevisionFormatting) — zero or more formatting records.
  rfmt : Array[CT_RevisionFormatting]
  /// @rId (xsd:unsignedInt) — required revision id (AG_RevData).
  r_id : Int
  /// @ua (xsd:boolean) — optional, default false (AG_RevData).
  ua : Bool
  /// @ra (xsd:boolean) — optional, default false (AG_RevData).
  ra : Bool
  /// @sheetId (xsd:unsignedInt) — required sheet id.
  sheet_id : Int
  /// @source (ST_Ref) — required source cell-range reference.
  source : String
  /// @destination (ST_Ref) — required destination cell-range reference.
  destination : String
  /// @sourceSheetId (xsd:unsignedInt) — optional, default 0.
  source_sheet_id : Int
} derive(Eq, Debug)

///|
pub fn CT_RevisionMove::new(
  element : @xml.Element,
) -> CT_RevisionMove raise @opc_errors.SchemaViolation {
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
  let r_id = attr_uint_schema(element, "rId", 0)
  let ua = revision_bool(element, "ua", false, "Part 1 §18.11.1.19", "rm")
  let ra = revision_bool(element, "ra", false, "Part 1 §18.11.1.19", "rm")
  let sheet_id = attr_uint_schema(element, "sheetId", 0)
  let source = match attr(element, "source") {
    Some(value) => value
    None => ""
  }
  let destination = match attr(element, "destination") {
    Some(value) => value
    None => ""
  }
  let source_sheet_id = attr_uint_schema(element, "sourceSheetId", 0)
  {
    element,
    undo,
    rcc,
    rfmt,
    r_id,
    ua,
    ra,
    sheet_id,
    source,
    destination,
    source_sheet_id,
  }
}

///|
/// XSD complex type CT_RevisionFormatting — Part 1 §18.11.1.17 (`<rfmt>`
/// Revision Format). Sequence children: optional `<dxf>` (CT_Dxf)
/// differential format and optional `<extLst>` (CT_ExtensionList).
/// Attributes: required `@sheetId` (xsd:unsignedInt); optional `@xfDxf`
/// (xsd:boolean, default false); optional `@s` (xsd:boolean, default
/// false); required `@sqref` (ST_Sqref); optional `@start`,
/// `@length` (xsd:unsignedInt).
pub(all) struct CT_RevisionFormatting {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <dxf> (CT_Dxf) — optional differential formatting block.
  dxf : CT_Dxf?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @sheetId (xsd:unsignedInt) — required sheet id.
  sheet_id : Int
  /// @xfDxf (xsd:boolean) — optional, default false.
  xf_dxf : Bool
  /// @s (xsd:boolean) — optional, default false.
  s : Bool
  /// @sqref (ST_Sqref) — required cell-range reference list.
  sqref : String
  /// @start (xsd:unsignedInt) — optional run start index.
  start : Int?
  /// @length (xsd:unsignedInt) — optional run length.
  length : Int?
} derive(Eq, Debug)

///|
pub fn CT_RevisionFormatting::new(
  element : @xml.Element,
) -> CT_RevisionFormatting raise @opc_errors.SchemaViolation {
  let mut dxf : CT_Dxf? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "dxf" => dxf = Some(CT_Dxf::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let sheet_id = attr_uint_schema(element, "sheetId", 0)
  let xf_dxf = revision_bool(
    element, "xfDxf", false, "Part 1 §18.11.1.17", "rfmt",
  )
  let s = revision_bool(element, "s", false, "Part 1 §18.11.1.17", "rfmt")
  let sqref = match attr(element, "sqref") {
    Some(value) => value
    None => ""
  }
  let start = attr_uint_opt_schema(element, "start")
  let length = attr_uint_opt_schema(element, "length")
  { element, dxf, ext_lst, sheet_id, xf_dxf, s, sqref, start, length }
}

///|
/// XSD complex type CT_RevisionAutoFormatting — Part 1 §18.11.1.7
/// (`<raf>` Revision Auto Format). Attribute-only revision entry.
/// Required `@sheetId` (xsd:unsignedInt). Attributes from AG_AutoFormat
/// (all optional, xsd:unsignedInt / xsd:boolean): `@autoFormatId`,
/// `@applyNumberFormats`, `@applyBorderFormats`, `@applyFontFormats`,
/// `@applyPatternFormats`, `@applyAlignmentFormats`,
/// `@applyWidthHeightFormats`. Required `@ref` (ST_Ref).
pub(all) struct CT_RevisionAutoFormatting {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @sheetId (xsd:unsignedInt) — required sheet id.
  sheet_id : Int
  /// @autoFormatId (xsd:unsignedInt) — optional auto format id (AG_AutoFormat).
  auto_format_id : Int?
  /// @applyNumberFormats (xsd:boolean) — optional (AG_AutoFormat).
  apply_number_formats : Bool?
  /// @applyBorderFormats (xsd:boolean) — optional (AG_AutoFormat).
  apply_border_formats : Bool?
  /// @applyFontFormats (xsd:boolean) — optional (AG_AutoFormat).
  apply_font_formats : Bool?
  /// @applyPatternFormats (xsd:boolean) — optional (AG_AutoFormat).
  apply_pattern_formats : Bool?
  /// @applyAlignmentFormats (xsd:boolean) — optional (AG_AutoFormat).
  apply_alignment_formats : Bool?
  /// @applyWidthHeightFormats (xsd:boolean) — optional (AG_AutoFormat).
  apply_width_height_formats : Bool?
  /// @ref (ST_Ref) — required cell-range reference.
  ref_ : String
} derive(Eq, Debug)

///|
pub fn CT_RevisionAutoFormatting::new(
  element : @xml.Element,
) -> CT_RevisionAutoFormatting raise @opc_errors.SchemaViolation {
  let sheet_id = attr_uint_schema(element, "sheetId", 0)
  let auto_format_id = attr_uint_opt_schema(element, "autoFormatId")
  let apply_number_formats = revision_bool_opt(
    element, "applyNumberFormats", "Part 1 §18.11.1.7", "raf",
  )
  let apply_border_formats = revision_bool_opt(
    element, "applyBorderFormats", "Part 1 §18.11.1.7", "raf",
  )
  let apply_font_formats = revision_bool_opt(
    element, "applyFontFormats", "Part 1 §18.11.1.7", "raf",
  )
  let apply_pattern_formats = revision_bool_opt(
    element, "applyPatternFormats", "Part 1 §18.11.1.7", "raf",
  )
  let apply_alignment_formats = revision_bool_opt(
    element, "applyAlignmentFormats", "Part 1 §18.11.1.7", "raf",
  )
  let apply_width_height_formats = revision_bool_opt(
    element, "applyWidthHeightFormats", "Part 1 §18.11.1.7", "raf",
  )
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  {
    element,
    sheet_id,
    auto_format_id,
    apply_number_formats,
    apply_border_formats,
    apply_font_formats,
    apply_pattern_formats,
    apply_alignment_formats,
    apply_width_height_formats,
    ref_,
  }
}

///|
/// XSD complex type CT_RevisionComment — Part 1 §18.11.1.10 (`<rcmt>`
/// Revision Cell Comment). Attribute-only revision entry. Required
/// `@sheetId` (xsd:unsignedInt), `@cell` (ST_CellRef), `@guid`
/// (s:ST_Guid). Optional `@action` (ST_RevisionAction, default `add`);
/// `@alwaysShow`, `@old`, `@hiddenRow`, `@hiddenColumn` (xsd:boolean,
/// default false). Required `@author` (s:ST_Xstring). Optional
/// `@oldLength`, `@newLength` (xsd:unsignedInt, default 0).
pub(all) struct CT_RevisionComment {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @sheetId (xsd:unsignedInt) — required sheet id.
  sheet_id : Int
  /// @cell (ST_CellRef) — required cell reference.
  cell : String
  /// @guid (s:ST_Guid) — required GUID.
  guid : String
  /// @action (ST_RevisionAction) — optional, default `add`.
  action : String
  /// @alwaysShow (xsd:boolean) — optional, default false.
  always_show : Bool
  /// @old (xsd:boolean) — optional, default false.
  old : Bool
  /// @hiddenRow (xsd:boolean) — optional, default false.
  hidden_row : Bool
  /// @hiddenColumn (xsd:boolean) — optional, default false.
  hidden_column : Bool
  /// @author (s:ST_Xstring) — required author display name.
  author : String
  /// @oldLength (xsd:unsignedInt) — optional, default 0.
  old_length : Int
  /// @newLength (xsd:unsignedInt) — optional, default 0.
  new_length : Int
} derive(Eq, Debug)

///|
pub fn CT_RevisionComment::new(
  element : @xml.Element,
) -> CT_RevisionComment raise @opc_errors.SchemaViolation {
  let sheet_id = attr_uint_schema(element, "sheetId", 0)
  let cell = match attr(element, "cell") {
    Some(value) => value
    None => ""
  }
  let guid = match attr(element, "guid") {
    Some(value) => value
    None => ""
  }
  let action = match attr(element, "action") {
    Some(value) => value
    None => "add"
  }
  let always_show = revision_bool(
    element, "alwaysShow", false, "Part 1 §18.11.1.10", "rcmt",
  )
  let old = revision_bool(element, "old", false, "Part 1 §18.11.1.10", "rcmt")
  let hidden_row = revision_bool(
    element, "hiddenRow", false, "Part 1 §18.11.1.10", "rcmt",
  )
  let hidden_column = revision_bool(
    element, "hiddenColumn", false, "Part 1 §18.11.1.10", "rcmt",
  )
  let author = match attr(element, "author") {
    Some(value) => value
    None => ""
  }
  let old_length = attr_uint_schema(element, "oldLength", 0)
  let new_length = attr_uint_schema(element, "newLength", 0)
  {
    element,
    sheet_id,
    cell,
    guid,
    action,
    always_show,
    old,
    hidden_row,
    hidden_column,
    author,
    old_length,
    new_length,
  }
}

///|
/// XSD complex type CT_RevisionDefinedName — Part 1 §18.11.1.13 (`<rdn>`
/// Revision Defined Name). Sequence children: optional `<formula>`
/// (ST_Formula text), optional `<oldFormula>` (ST_Formula text),
/// optional `<extLst>` (CT_ExtensionList). Attributes from AG_RevData:
/// required `@rId` (xsd:unsignedInt); optional `@ua`, `@ra`
/// (xsd:boolean, default false). Type-specific optional: `@localSheetId`
/// (xsd:unsignedInt), `@customView` (xsd:boolean, default false);
/// required `@name` (s:ST_Xstring); optional `@function`,
/// `@oldFunction` (xsd:boolean, default false); optional
/// `@functionGroupId`, `@oldFunctionGroupId`, `@shortcutKey`,
/// `@oldShortcutKey` (xsd:unsignedByte); `@hidden`, `@oldHidden`
/// (xsd:boolean, default false); `@customMenu`, `@oldCustomMenu`,
/// `@description`, `@oldDescription`, `@help`, `@oldHelp`,
/// `@statusBar`, `@oldStatusBar`, `@comment`, `@oldComment`
/// (s:ST_Xstring).
pub(all) struct CT_RevisionDefinedName {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <formula> (ST_Formula text) — optional new formula payload.
  formula : String?
  /// <oldFormula> (ST_Formula text) — optional previous formula payload.
  old_formula : String?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @rId (xsd:unsignedInt) — required revision id (AG_RevData).
  r_id : Int
  /// @ua (xsd:boolean) — optional, default false (AG_RevData).
  ua : Bool
  /// @ra (xsd:boolean) — optional, default false (AG_RevData).
  ra : Bool
  /// @localSheetId (xsd:unsignedInt) — optional local sheet binding.
  local_sheet_id : Int?
  /// @customView (xsd:boolean) — optional, default false.
  custom_view : Bool
  /// @name (s:ST_Xstring) — required defined name.
  name : String
  /// @function (xsd:boolean) — optional, default false.
  function : Bool
  /// @oldFunction (xsd:boolean) — optional, default false.
  old_function : Bool
  /// @functionGroupId (xsd:unsignedByte) — optional.
  function_group_id : Int?
  /// @oldFunctionGroupId (xsd:unsignedByte) — optional.
  old_function_group_id : Int?
  /// @shortcutKey (xsd:unsignedByte) — optional.
  shortcut_key : Int?
  /// @oldShortcutKey (xsd:unsignedByte) — optional.
  old_shortcut_key : Int?
  /// @hidden (xsd:boolean) — optional, default false.
  hidden : Bool
  /// @oldHidden (xsd:boolean) — optional, default false.
  old_hidden : Bool
  /// @customMenu (s:ST_Xstring) — optional.
  custom_menu : String?
  /// @oldCustomMenu (s:ST_Xstring) — optional.
  old_custom_menu : String?
  /// @description (s:ST_Xstring) — optional.
  description : String?
  /// @oldDescription (s:ST_Xstring) — optional.
  old_description : String?
  /// @help (s:ST_Xstring) — optional.
  help : String?
  /// @oldHelp (s:ST_Xstring) — optional.
  old_help : String?
  /// @statusBar (s:ST_Xstring) — optional.
  status_bar : String?
  /// @oldStatusBar (s:ST_Xstring) — optional.
  old_status_bar : String?
  /// @comment (s:ST_Xstring) — optional.
  comment : String?
  /// @oldComment (s:ST_Xstring) — optional.
  old_comment : String?
} derive(Eq, Debug)

///|
pub fn CT_RevisionDefinedName::new(
  element : @xml.Element,
) -> CT_RevisionDefinedName raise @opc_errors.SchemaViolation {
  let mut formula : String? = None
  let mut old_formula : String? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "formula" => formula = Some(element_text(child_element))
        "oldFormula" => old_formula = Some(element_text(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let r_id = attr_uint(element, "rId", 0)
  let ua = revision_bool(element, "ua", false, "Part 1 §18.11.1.13", "rdn")
  let ra = revision_bool(element, "ra", false, "Part 1 §18.11.1.13", "rdn")
  let local_sheet_id = attr_uint_opt(element, "localSheetId")
  let custom_view = revision_bool(
    element, "customView", false, "Part 1 §18.11.1.13", "rdn",
  )
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let function = revision_bool(
    element, "function", false, "Part 1 §18.11.1.13", "rdn",
  )
  let old_function = revision_bool(
    element, "oldFunction", false, "Part 1 §18.11.1.13", "rdn",
  )
  let function_group_id = attr_uint_opt(element, "functionGroupId")
  let old_function_group_id = attr_uint_opt(element, "oldFunctionGroupId")
  let shortcut_key = attr_uint_opt(element, "shortcutKey")
  let old_shortcut_key = attr_uint_opt(element, "oldShortcutKey")
  let hidden = revision_bool(
    element, "hidden", false, "Part 1 §18.11.1.13", "rdn",
  )
  let old_hidden = revision_bool(
    element, "oldHidden", false, "Part 1 §18.11.1.13", "rdn",
  )
  let custom_menu = attr(element, "customMenu")
  let old_custom_menu = attr(element, "oldCustomMenu")
  let description = attr(element, "description")
  let old_description = attr(element, "oldDescription")
  let help = attr(element, "help")
  let old_help = attr(element, "oldHelp")
  let status_bar = attr(element, "statusBar")
  let old_status_bar = attr(element, "oldStatusBar")
  let comment = attr(element, "comment")
  let old_comment = attr(element, "oldComment")
  {
    element,
    formula,
    old_formula,
    ext_lst,
    r_id,
    ua,
    ra,
    local_sheet_id,
    custom_view,
    name,
    function,
    old_function,
    function_group_id,
    old_function_group_id,
    shortcut_key,
    old_shortcut_key,
    hidden,
    old_hidden,
    custom_menu,
    old_custom_menu,
    description,
    old_description,
    help,
    old_help,
    status_bar,
    old_status_bar,
    comment,
    old_comment,
  }
}

///|
/// XSD complex type CT_RevisionConflict — Part 1 §18.11.1.11 (`<rcft>`
/// Revision Conflict). Attribute-only revision entry. Attributes from
/// AG_RevData: required `@rId` (xsd:unsignedInt); optional `@ua`, `@ra`
/// (xsd:boolean, default false). Type-specific: optional `@sheetId`
/// (xsd:unsignedInt).
pub(all) struct CT_RevisionConflict {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @rId (xsd:unsignedInt) — required revision id (AG_RevData).
  r_id : Int
  /// @ua (xsd:boolean) — optional, default false (AG_RevData).
  ua : Bool
  /// @ra (xsd:boolean) — optional, default false (AG_RevData).
  ra : Bool
  /// @sheetId (xsd:unsignedInt) — optional sheet id.
  sheet_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_RevisionConflict::new(
  element : @xml.Element,
) -> CT_RevisionConflict raise @opc_errors.SchemaViolation {
  let r_id = attr_uint(element, "rId", 0)
  let ua = revision_bool(element, "ua", false, "Part 1 §18.11.1.11", "rcft")
  let ra = revision_bool(element, "ra", false, "Part 1 §18.11.1.11", "rcft")
  let sheet_id = attr_uint_opt(element, "sheetId")
  { element, r_id, ua, ra, sheet_id }
}

///|
/// XSD complex type CT_Users — Part 1 §18.11.1.27 (`<users>` Users
/// container in the user-names part). Sequence: `<userInfo>*`
/// (CT_SharedUser) zero to 256 entries. Optional attribute `@count`
/// (xsd:unsignedInt).
pub(all) struct CT_Users {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <userInfo>* (CT_SharedUser) — zero to 256 shared-user entries.
  user_info : Array[CT_SharedUser]
  /// @count (xsd:unsignedInt) — optional count attribute.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_Users::new(element : @xml.Element) -> CT_Users {
  let user_info : Array[CT_SharedUser] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "userInfo" {
        user_info.push(CT_SharedUser::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, user_info, count }
}

///|
/// XSD complex type CT_SharedUser — Part 1 §18.11.1.24 (`<userInfo>`
/// Shared User). Sequence: optional `<extLst>` (CT_ExtensionList).
/// Attributes: required `@guid` (s:ST_Guid), `@name` (s:ST_Xstring),
/// `@id` (xsd:int), `@dateTime` (xsd:dateTime).
pub(all) struct CT_SharedUser {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @guid (s:ST_Guid) — required GUID.
  guid : String
  /// @name (s:ST_Xstring) — required display name.
  name : String
  /// @id (xsd:int) — required signed identifier.
  id : Int
  /// @dateTime (xsd:dateTime) — required ISO 8601 timestamp text.
  date_time : String
} derive(Eq, Debug)

///|
pub fn CT_SharedUser::new(element : @xml.Element) -> CT_SharedUser {
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  let guid = match attr(element, "guid") {
    Some(value) => value
    None => ""
  }
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let id = attr_int(element, "id", 0)
  let date_time = match attr(element, "dateTime") {
    Some(value) => value
    None => ""
  }
  { element, ext_lst, guid, name, id, date_time }
}

///|
/// XSD complex type CT_OutlinePr — Part 1 §18.3.1.61 (`<outlinePr>`
/// Sheet Outline Properties). Attribute-only. Optional `@applyStyles`
/// (xsd:boolean, default false); `@summaryBelow` (xsd:boolean, default
/// true); `@summaryRight` (xsd:boolean, default true);
/// `@showOutlineSymbols` (xsd:boolean, default true).
pub(all) struct CT_OutlinePr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @applyStyles (xsd:boolean) — optional, default false.
  apply_styles : Bool
  /// @summaryBelow (xsd:boolean) — optional, default true.
  summary_below : Bool
  /// @summaryRight (xsd:boolean) — optional, default true.
  summary_right : Bool
  /// @showOutlineSymbols (xsd:boolean) — optional, default true.
  show_outline_symbols : Bool
} derive(Eq, Debug)

///|
fn outline_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.61", "outlinePr",
  )
}

///|
pub fn CT_OutlinePr::new(
  element : @xml.Element,
) -> CT_OutlinePr raise @opc_errors.SchemaViolation {
  let apply_styles = outline_pr_bool(element, "applyStyles", false)
  let summary_below = outline_pr_bool(element, "summaryBelow", true)
  let summary_right = outline_pr_bool(element, "summaryRight", true)
  let show_outline_symbols = outline_pr_bool(
    element, "showOutlineSymbols", true,
  )
  { element, apply_styles, summary_below, summary_right, show_outline_symbols }
}

///|
/// XSD complex type CT_SmartTags — Part 1 §18.3.1.78 (`<smartTags>`
/// Smart Tags root for a worksheet). Sequence: `<cellSmartTags>+`
/// (CT_CellSmartTags) one or more. No attributes.
pub(all) struct CT_SmartTags {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cellSmartTags>+ (CT_CellSmartTags) — one or more cell-smart-tag groups.
  cell_smart_tags : Array[CT_CellSmartTags]
} derive(Eq, Debug)

///|
pub fn CT_SmartTags::new(
  element : @xml.Element,
) -> CT_SmartTags raise @opc_errors.SchemaViolation {
  let cell_smart_tags : Array[CT_CellSmartTags] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "cellSmartTags" {
        cell_smart_tags.push(CT_CellSmartTags::new(child_element))
      }
    }
  }
  { element, cell_smart_tags }
}

///|
/// XSD complex type CT_CustomProperties — Part 1 §18.3.1.16
/// (`<customProperties>` Custom Properties container). Sequence:
/// `<customPr>+` (CT_CustomProperty) one or more. No attributes.
pub(all) struct CT_CustomProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <customPr>+ (CT_CustomProperty) — one or more custom property entries.
  custom_pr : Array[CT_CustomProperty]
} derive(Eq, Debug)

///|
pub fn CT_CustomProperties::new(element : @xml.Element) -> CT_CustomProperties {
  let custom_pr : Array[CT_CustomProperty] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "customPr" {
        custom_pr.push(CT_CustomProperty::new(child_element))
      }
    }
  }
  { element, custom_pr }
}

///|
/// XSD complex type CT_WebPublishItems — Part 1 §18.3.1.96
/// (`<webPublishItems>` Web Publishing Items container). Sequence:
/// `<webPublishItem>+` (CT_WebPublishItem) one or more. Optional
/// attribute `@count` (xsd:unsignedInt).
pub(all) struct CT_WebPublishItems {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <webPublishItem>+ (CT_WebPublishItem) — one or more publish items.
  web_publish_item : Array[CT_WebPublishItem]
  /// @count (xsd:unsignedInt) — optional count attribute.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_WebPublishItems::new(
  element : @xml.Element,
) -> CT_WebPublishItems raise @opc_errors.SchemaViolation {
  let web_publish_item : Array[CT_WebPublishItem] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "webPublishItem" {
        web_publish_item.push(CT_WebPublishItem::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, web_publish_item, count }
}

///|
/// XSD complex type CT_WebPublishItem — Part 1 §18.3.1.95
/// (`<webPublishItem>` Web Publishing Item). Attribute-only. Required
/// `@id` (xsd:unsignedInt), `@divId` (s:ST_Xstring), `@sourceType`
/// (ST_WebSourceType), `@destinationFile` (s:ST_Xstring). Optional
/// `@sourceRef` (ST_Ref), `@sourceObject` (s:ST_Xstring), `@title`
/// (s:ST_Xstring); `@autoRepublish` (xsd:boolean, default false).
pub(all) struct CT_WebPublishItem {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt) — required publish item identifier.
  id : Int
  /// @divId (s:ST_Xstring) — required HTML div identifier.
  div_id : String
  /// @sourceType (ST_WebSourceType) — required source kind.
  source_type : String
  /// @sourceRef (ST_Ref) — optional source range reference.
  source_ref : String?
  /// @sourceObject (s:ST_Xstring) — optional named source object.
  source_object : String?
  /// @destinationFile (s:ST_Xstring) — required output file path.
  destination_file : String
  /// @title (s:ST_Xstring) — optional human-readable title.
  title : String?
  /// @autoRepublish (xsd:boolean) — optional, default false.
  auto_republish : Bool
} derive(Eq, Debug)

///|
fn web_publish_item_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.95", "webPublishItem",
  )
}

///|
pub fn CT_WebPublishItem::new(
  element : @xml.Element,
) -> CT_WebPublishItem raise @opc_errors.SchemaViolation {
  let id = attr_uint(element, "id", 0)
  let div_id = match attr(element, "divId") {
    Some(value) => value
    None => ""
  }
  let source_type = match attr(element, "sourceType") {
    Some(value) => value
    None => ""
  }
  let source_ref = attr(element, "sourceRef")
  let source_object = attr(element, "sourceObject")
  let destination_file = match attr(element, "destinationFile") {
    Some(value) => value
    None => ""
  }
  let title = attr(element, "title")
  let auto_republish = web_publish_item_bool(element, "autoRepublish", false)
  {
    element,
    id,
    div_id,
    source_type,
    source_ref,
    source_object,
    destination_file,
    title,
    auto_republish,
  }
}

///|
/// XSD complex type CT_GradientStop — Part 1 §18.8.38 (`<stop>` Gradient
/// Stop). Sequence: required `<color>` (CT_Color, minOccurs=1
/// maxOccurs=1). Required `@position` (xsd:double). The domain's typed
/// `CT_Color` is the ARGB-only conditional-formatting carrier
/// (§18.3.1.15) constructed via `CT_Color::new(a, r, g, b)`, so the
/// gradient stop's XML `<color>` child is preserved as its raw
/// `@xml.Element` for byte-identical round-trip.
pub(all) struct CT_GradientStop {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <color> (CT_Color element) — required gradient-stop colour, preserved
  /// as the raw XML element because the typed CT_Color is the ARGB-only
  /// (§18.3.1.15) carrier.
  color : @xml.Element?
  /// @position (xsd:double) — required gradient-stop position.
  position : Double
} derive(Eq, Debug)

///|
pub fn CT_GradientStop::new(element : @xml.Element) -> CT_GradientStop {
  let mut color : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "color" {
        color = Some(child_element)
      }
    }
  }
  let position = attr_double(element, "position", 0.0)
  { element, color, position }
}

///|
/// XSD complex type CT_Workbook — Part 1 §18.2.27 (`<workbook>` Workbook
/// root). Sequence in order: `<fileVersion>?` (CT_FileVersion),
/// `<fileSharing>?` (CT_FileSharing), `<workbookPr>?` (CT_WorkbookPr),
/// `<workbookProtection>?` (CT_WorkbookProtection), `<bookViews>?`
/// (CT_BookViews), `<sheets>` (CT_Sheets, required minOccurs=1),
/// `<functionGroups>?` (CT_FunctionGroups), `<externalReferences>?`
/// (CT_ExternalReferences), `<definedNames>?` (CT_DefinedNames),
/// `<calcPr>?` (CT_CalcPr), `<oleSize>?` (CT_OleSize),
/// `<customWorkbookViews>?` (CT_CustomWorkbookViews), `<pivotCaches>?`
/// (CT_PivotCaches), `<smartTagPr>?` (CT_SmartTagPr), `<smartTagTypes>?`
/// (CT_SmartTagTypes), `<webPublishing>?` (CT_WebPublishing),
/// `<fileRecoveryPr>*` (CT_FileRecoveryPr, maxOccurs=unbounded),
/// `<webPublishObjects>?` (CT_WebPublishObjects), `<extLst>?`
/// (CT_ExtensionList). Optional `@conformance` (s:ST_ConformanceClass).
pub(all) struct CT_Workbook {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <fileVersion> (CT_FileVersion) — optional, the workbook file version.
  file_version : CT_FileVersion?
  /// <fileSharing> (CT_FileSharing) — optional file-sharing settings.
  file_sharing : CT_FileSharing?
  /// <workbookPr> (CT_WorkbookPr) — optional workbook properties.
  workbook_pr : CT_WorkbookPr?
  /// <workbookProtection> (CT_WorkbookProtection) — optional protection.
  workbook_protection : CT_WorkbookProtection?
  /// <bookViews> (CT_BookViews) — optional collection of workbook views.
  book_views : CT_BookViews?
  /// <sheets> (CT_Sheets) — required, the sheet entries.
  sheets : CT_Sheets?
  /// <functionGroups> (CT_FunctionGroups) — optional function-group list.
  function_groups : CT_FunctionGroups?
  /// <externalReferences> (CT_ExternalReferences) — optional external refs.
  external_references : CT_ExternalReferences?
  /// <definedNames> (CT_DefinedNames) — optional defined-name table.
  defined_names : CT_DefinedNames?
  /// <calcPr> (CT_CalcPr) — optional calculation properties.
  calc_pr : CT_CalcPr?
  /// <oleSize> (CT_OleSize) — optional embedded-object dimensions.
  ole_size : CT_OleSize?
  /// <customWorkbookViews> (CT_CustomWorkbookViews) — optional custom views.
  custom_workbook_views : CT_CustomWorkbookViews?
  /// <pivotCaches> (CT_PivotCaches) — optional pivot-cache references.
  pivot_caches : CT_PivotCaches?
  /// <smartTagPr> (CT_SmartTagPr) — optional smart-tag properties.
  smart_tag_pr : CT_SmartTagPr?
  /// <smartTagTypes> (CT_SmartTagTypes) — optional smart-tag type list.
  smart_tag_types : CT_SmartTagTypes?
  /// <webPublishing> (CT_WebPublishing) — optional web-publishing settings.
  web_publishing : CT_WebPublishing?
  /// <fileRecoveryPr>* (CT_FileRecoveryPr) — zero or more recovery hints.
  file_recovery_pr : Array[CT_FileRecoveryPr]
  /// <webPublishObjects> (CT_WebPublishObjects) — optional publish objects.
  web_publish_objects : CT_WebPublishObjects?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
  /// @conformance (s:ST_ConformanceClass) — optional conformance class.
  conformance : String?
} derive(Eq, Debug)

///|
pub fn CT_Workbook::new(
  element : @xml.Element,
) -> CT_Workbook raise @opc_errors.SchemaViolation {
  let mut file_version : CT_FileVersion? = None
  let mut file_sharing : CT_FileSharing? = None
  let mut workbook_pr : CT_WorkbookPr? = None
  let mut workbook_protection : CT_WorkbookProtection? = None
  let mut book_views : CT_BookViews? = None
  let mut sheets : CT_Sheets? = None
  let mut function_groups : CT_FunctionGroups? = None
  let mut external_references : CT_ExternalReferences? = None
  let mut defined_names : CT_DefinedNames? = None
  let mut calc_pr : CT_CalcPr? = None
  let mut ole_size : CT_OleSize? = None
  let mut custom_workbook_views : CT_CustomWorkbookViews? = None
  let mut pivot_caches : CT_PivotCaches? = None
  let mut smart_tag_pr : CT_SmartTagPr? = None
  let mut smart_tag_types : CT_SmartTagTypes? = None
  let mut web_publishing : CT_WebPublishing? = None
  let file_recovery_pr : Array[CT_FileRecoveryPr] = []
  let mut web_publish_objects : CT_WebPublishObjects? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "fileVersion" => file_version = Some(CT_FileVersion::new(child_element))
        "fileSharing" => file_sharing = Some(CT_FileSharing::new(child_element))
        "workbookPr" => workbook_pr = Some(CT_WorkbookPr::new(child_element))
        "workbookProtection" =>
          workbook_protection = Some(CT_WorkbookProtection::new(child_element))
        "bookViews" => book_views = Some(CT_BookViews::new(child_element))
        "sheets" => sheets = Some(CT_Sheets::new(child_element))
        "functionGroups" =>
          function_groups = Some(CT_FunctionGroups::new(child_element))
        "externalReferences" =>
          external_references = Some(CT_ExternalReferences::new(child_element))
        "definedNames" =>
          defined_names = Some(CT_DefinedNames::new(child_element))
        "calcPr" => calc_pr = Some(CT_CalcPr::new(child_element))
        "oleSize" => ole_size = Some(CT_OleSize::new(child_element))
        "customWorkbookViews" =>
          custom_workbook_views = Some(
            CT_CustomWorkbookViews::new(child_element),
          )
        "pivotCaches" => pivot_caches = Some(CT_PivotCaches::new(child_element))
        "smartTagPr" => smart_tag_pr = Some(CT_SmartTagPr::new(child_element))
        "smartTagTypes" =>
          smart_tag_types = Some(CT_SmartTagTypes::new(child_element))
        "webPublishing" =>
          web_publishing = Some(CT_WebPublishing::new(child_element))
        "fileRecoveryPr" =>
          file_recovery_pr.push(CT_FileRecoveryPr::new(child_element))
        "webPublishObjects" =>
          web_publish_objects = Some(CT_WebPublishObjects::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let conformance = attr(element, "conformance")
  {
    element,
    file_version,
    file_sharing,
    workbook_pr,
    workbook_protection,
    book_views,
    sheets,
    function_groups,
    external_references,
    defined_names,
    calc_pr,
    ole_size,
    custom_workbook_views,
    pivot_caches,
    smart_tag_pr,
    smart_tag_types,
    web_publishing,
    file_recovery_pr,
    web_publish_objects,
    ext_lst,
    conformance,
  }
}

///|
/// XSD complex type CT_FileVersion — Part 1 §18.2.13 (`<fileVersion>`
/// File Version). Attribute-only. Optional `@appName` (xsd:string),
/// `@lastEdited` (xsd:string), `@lowestEdited` (xsd:string), `@rupBuild`
/// (xsd:string), `@codeName` (s:ST_Guid). Per the strict XSD the four
/// build identifiers are xsd:string (not numeric) so they are surfaced
/// as `String?` to preserve loose value formats observed in real
/// workbooks.
pub(all) struct CT_FileVersion {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @appName (xsd:string) — optional application identifier.
  app_name : String?
  /// @lastEdited (xsd:string) — optional last-editor build number.
  last_edited : String?
  /// @lowestEdited (xsd:string) — optional lowest-editor build number.
  lowest_edited : String?
  /// @rupBuild (xsd:string) — optional rupture build identifier.
  rup_build : String?
  /// @codeName (s:ST_Guid) — optional VBA code-name GUID.
  code_name : String?
} derive(Eq, Debug)

///|
pub fn CT_FileVersion::new(element : @xml.Element) -> CT_FileVersion {
  let app_name = attr(element, "appName")
  let last_edited = attr(element, "lastEdited")
  let lowest_edited = attr(element, "lowestEdited")
  let rup_build = attr(element, "rupBuild")
  let code_name = attr(element, "codeName")
  { element, app_name, last_edited, lowest_edited, rup_build, code_name }
}

///|
/// XSD complex type CT_WorkbookPr — Part 1 §18.2.28 (`<workbookPr>`
/// Workbook Properties). Attribute-only. Optional booleans with defaults:
/// `@date1904` (false), `@showBorderUnselectedTables` (true),
/// `@filterPrivacy` (false), `@promptedSolutions` (false),
/// `@showInkAnnotation` (true), `@backupFile` (false),
/// `@saveExternalLinkValues` (true), `@hidePivotFieldList` (false),
/// `@showPivotChartFilter` (false), `@allowRefreshQuery` (false),
/// `@publishItems` (false), `@checkCompatibility` (false),
/// `@autoCompressPictures` (true), `@refreshAllConnections` (false).
/// Enumeration attrs: `@showObjects` (ST_Objects, default "all"),
/// `@updateLinks` (ST_UpdateLinks, default "userSet"). String attrs:
/// `@codeName` (xsd:string). Numeric: `@defaultThemeVersion`
/// (xsd:unsignedInt, optional).
pub(all) struct CT_WorkbookPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @date1904 (xsd:boolean) — optional, default false.
  date1904 : Bool
  /// @showObjects (ST_Objects) — optional, default "all".
  show_objects : String
  /// @showBorderUnselectedTables (xsd:boolean) — optional, default true.
  show_border_unselected_tables : Bool
  /// @filterPrivacy (xsd:boolean) — optional, default false.
  filter_privacy : Bool
  /// @promptedSolutions (xsd:boolean) — optional, default false.
  prompted_solutions : Bool
  /// @showInkAnnotation (xsd:boolean) — optional, default true.
  show_ink_annotation : Bool
  /// @backupFile (xsd:boolean) — optional, default false.
  backup_file : Bool
  /// @saveExternalLinkValues (xsd:boolean) — optional, default true.
  save_external_link_values : Bool
  /// @updateLinks (ST_UpdateLinks) — optional, default "userSet".
  update_links : String
  /// @codeName (xsd:string) — optional VBA code-name.
  code_name : String?
  /// @hidePivotFieldList (xsd:boolean) — optional, default false.
  hide_pivot_field_list : Bool
  /// @showPivotChartFilter (xsd:boolean) — optional, default false.
  show_pivot_chart_filter : Bool
  /// @allowRefreshQuery (xsd:boolean) — optional, default false.
  allow_refresh_query : Bool
  /// @publishItems (xsd:boolean) — optional, default false.
  publish_items : Bool
  /// @checkCompatibility (xsd:boolean) — optional, default false.
  check_compatibility : Bool
  /// @autoCompressPictures (xsd:boolean) — optional, default true.
  auto_compress_pictures : Bool
  /// @refreshAllConnections (xsd:boolean) — optional, default false.
  refresh_all_connections : Bool
  /// @defaultThemeVersion (xsd:unsignedInt) — optional default theme version.
  default_theme_version : Int?
} derive(Eq, Debug)

///|
pub fn CT_WorkbookPr::new(
  element : @xml.Element,
) -> CT_WorkbookPr raise @opc_errors.SchemaViolation {
  let date1904 = workbook_pr_bool(element, "date1904", false)
  let show_objects = match attr(element, "showObjects") {
    Some(value) => value
    None => "all"
  }
  let show_border_unselected_tables = workbook_pr_bool(
    element, "showBorderUnselectedTables", true,
  )
  let filter_privacy = workbook_pr_bool(element, "filterPrivacy", false)
  let prompted_solutions = workbook_pr_bool(element, "promptedSolutions", false)
  let show_ink_annotation = workbook_pr_bool(element, "showInkAnnotation", true)
  let backup_file = workbook_pr_bool(element, "backupFile", false)
  let save_external_link_values = workbook_pr_bool(
    element, "saveExternalLinkValues", true,
  )
  let update_links = match attr(element, "updateLinks") {
    Some(value) => value
    None => "userSet"
  }
  let code_name = attr(element, "codeName")
  let hide_pivot_field_list = workbook_pr_bool(
    element, "hidePivotFieldList", false,
  )
  let show_pivot_chart_filter = workbook_pr_bool(
    element, "showPivotChartFilter", false,
  )
  let allow_refresh_query = workbook_pr_bool(
    element, "allowRefreshQuery", false,
  )
  let publish_items = workbook_pr_bool(element, "publishItems", false)
  let check_compatibility = workbook_pr_bool(
    element, "checkCompatibility", false,
  )
  let auto_compress_pictures = workbook_pr_bool(
    element, "autoCompressPictures", true,
  )
  let refresh_all_connections = workbook_pr_bool(
    element, "refreshAllConnections", false,
  )
  let default_theme_version = attr_uint_opt_schema(
    element, "defaultThemeVersion",
  )
  {
    element,
    date1904,
    show_objects,
    show_border_unselected_tables,
    filter_privacy,
    prompted_solutions,
    show_ink_annotation,
    backup_file,
    save_external_link_values,
    update_links,
    code_name,
    hide_pivot_field_list,
    show_pivot_chart_filter,
    allow_refresh_query,
    publish_items,
    check_compatibility,
    auto_compress_pictures,
    refresh_all_connections,
    default_theme_version,
  }
}

///|
/// XSD complex type CT_SmartTagPr — Part 1 §18.2.21 (`<smartTagPr>`
/// Smart Tag Properties). Attribute-only. Optional `@embed`
/// (xsd:boolean, default false); `@show` (ST_SmartTagShow, default
/// "all").
pub(all) struct CT_SmartTagPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @embed (xsd:boolean) — optional, default false.
  embed : Bool
  /// @show (ST_SmartTagShow) — optional, default "all".
  show : String
} derive(Eq, Debug)

///|
pub fn CT_SmartTagPr::new(
  element : @xml.Element,
) -> CT_SmartTagPr raise @opc_errors.SchemaViolation {
  let embed = smart_tag_pr_bool(element, "embed", false)
  let show = match attr(element, "show") {
    Some(value) => value
    None => "all"
  }
  { element, embed, show }
}

///|
/// XSD complex type CT_SmartTagTypes — Part 1 §18.2.23
/// (`<smartTagTypes>` Smart Tag Types container). Sequence:
/// `<smartTagType>*` (CT_SmartTagType, minOccurs=0
/// maxOccurs=unbounded). No attributes.
pub(all) struct CT_SmartTagTypes {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <smartTagType>* (CT_SmartTagType) — zero or more smart-tag type entries.
  smart_tag_type : Array[CT_SmartTagType]
} derive(Eq, Debug)

///|
pub fn CT_SmartTagTypes::new(element : @xml.Element) -> CT_SmartTagTypes {
  let smart_tag_type : Array[CT_SmartTagType] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "smartTagType" {
        smart_tag_type.push(CT_SmartTagType::new(child_element))
      }
    }
  }
  { element, smart_tag_type }
}

///|
/// XSD complex type CT_SmartTagType — Part 1 §18.2.22 (`<smartTagType>`
/// Smart Tag Type). Attribute-only. Optional `@namespaceUri`
/// (s:ST_Xstring), `@name` (s:ST_Xstring), `@url` (s:ST_Xstring).
pub(all) struct CT_SmartTagType {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @namespaceUri (s:ST_Xstring) — optional smart-tag namespace URI.
  namespace_uri : String?
  /// @name (s:ST_Xstring) — optional smart-tag type name.
  name : String?
  /// @url (s:ST_Xstring) — optional smart-tag type URL.
  url : String?
} derive(Eq, Debug)

///|
pub fn CT_SmartTagType::new(element : @xml.Element) -> CT_SmartTagType {
  let namespace_uri = attr(element, "namespaceUri")
  let name = attr(element, "name")
  let url = attr(element, "url")
  { element, namespace_uri, name, url }
}

///|
/// XSD complex type CT_FileRecoveryPr — Part 1 §18.2.11
/// (`<fileRecoveryPr>` File Recovery Properties). Attribute-only.
/// Optional `@autoRecover` (xsd:boolean, default true); `@crashSave`
/// (xsd:boolean, default false); `@dataExtractLoad` (xsd:boolean,
/// default false); `@repairLoad` (xsd:boolean, default false).
pub(all) struct CT_FileRecoveryPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @autoRecover (xsd:boolean) — optional, default true.
  auto_recover : Bool
  /// @crashSave (xsd:boolean) — optional, default false.
  crash_save : Bool
  /// @dataExtractLoad (xsd:boolean) — optional, default false.
  data_extract_load : Bool
  /// @repairLoad (xsd:boolean) — optional, default false.
  repair_load : Bool
} derive(Eq, Debug)

///|
pub fn CT_FileRecoveryPr::new(
  element : @xml.Element,
) -> CT_FileRecoveryPr raise @opc_errors.SchemaViolation {
  let auto_recover = file_recovery_pr_bool(element, "autoRecover", true)
  let crash_save = file_recovery_pr_bool(element, "crashSave", false)
  let data_extract_load = file_recovery_pr_bool(
    element, "dataExtractLoad", false,
  )
  let repair_load = file_recovery_pr_bool(element, "repairLoad", false)
  { element, auto_recover, crash_save, data_extract_load, repair_load }
}

///|
/// XSD complex type CT_CalcPr — Part 1 §18.2.2 (`<calcPr>` Calculation
/// Properties). Attribute-only. `@calcId` (xsd:unsignedInt) optional.
/// `@calcMode` (ST_CalcMode, default "auto"); `@refMode` (ST_RefMode,
/// default "A1"). Optional booleans: `@fullCalcOnLoad` (default false),
/// `@iterate` (default false), `@fullPrecision` (default true),
/// `@calcCompleted` (default true), `@calcOnSave` (default true),
/// `@concurrentCalc` (default true), `@forceFullCalc` (no default).
/// Numerics: `@iterateCount` (xsd:unsignedInt, default 100),
/// `@iterateDelta` (xsd:double, default 0.001),
/// `@concurrentManualCount` (xsd:unsignedInt, optional).
pub(all) struct CT_CalcPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @calcId (xsd:unsignedInt) — optional calculation engine identifier.
  calc_id : Int?
  /// @calcMode (ST_CalcMode) — optional, default "auto".
  calc_mode : String
  /// @fullCalcOnLoad (xsd:boolean) — optional, default false.
  full_calc_on_load : Bool
  /// @refMode (ST_RefMode) — optional, default "A1".
  ref_mode : String
  /// @iterate (xsd:boolean) — optional, default false.
  iterate : Bool
  /// @iterateCount (xsd:unsignedInt) — optional, default 100.
  iterate_count : Int
  /// @iterateDelta (xsd:double) — optional, default 0.001.
  iterate_delta : Double
  /// @fullPrecision (xsd:boolean) — optional, default true.
  full_precision : Bool
  /// @calcCompleted (xsd:boolean) — optional, default true.
  calc_completed : Bool
  /// @calcOnSave (xsd:boolean) — optional, default true.
  calc_on_save : Bool
  /// @concurrentCalc (xsd:boolean) — optional, default true.
  concurrent_calc : Bool
  /// @concurrentManualCount (xsd:unsignedInt) — optional manual thread count.
  concurrent_manual_count : Int?
  /// @forceFullCalc (xsd:boolean) — optional, no default.
  force_full_calc : Bool?
} derive(Eq, Debug)

///|
pub fn CT_CalcPr::new(
  element : @xml.Element,
) -> CT_CalcPr raise @opc_errors.SchemaViolation {
  let calc_id = attr_uint_opt_schema(element, "calcId")
  let calc_mode = match attr(element, "calcMode") {
    Some(value) => value
    None => "auto"
  }
  let full_calc_on_load = calc_pr_bool(element, "fullCalcOnLoad", false)
  let ref_mode = match attr(element, "refMode") {
    Some(value) => value
    None => "A1"
  }
  let iterate = calc_pr_bool(element, "iterate", false)
  let iterate_count = attr_uint_schema(element, "iterateCount", 100)
  let iterate_delta = attr_double_schema(element, "iterateDelta", 0.001)
  let full_precision = calc_pr_bool(element, "fullPrecision", true)
  let calc_completed = calc_pr_bool(element, "calcCompleted", true)
  let calc_on_save = calc_pr_bool(element, "calcOnSave", true)
  let concurrent_calc = calc_pr_bool(element, "concurrentCalc", true)
  let concurrent_manual_count = attr_uint_opt_schema(
    element, "concurrentManualCount",
  )
  let force_full_calc = calc_pr_bool_opt(element, "forceFullCalc")
  {
    element,
    calc_id,
    calc_mode,
    full_calc_on_load,
    ref_mode,
    iterate,
    iterate_count,
    iterate_delta,
    full_precision,
    calc_completed,
    calc_on_save,
    concurrent_calc,
    concurrent_manual_count,
    force_full_calc,
  }
}

///|
/// XSD complex type CT_DefinedNames — Part 1 §18.2.6 (`<definedNames>`
/// Defined Names container). Sequence: `<definedName>*` (CT_DefinedName,
/// minOccurs=0 maxOccurs=unbounded). No attributes.
pub(all) struct CT_DefinedNames {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <definedName>* (CT_DefinedName) — zero or more defined-name entries.
  defined_name : Array[CT_DefinedName]
} derive(Eq, Debug)

///|
pub fn CT_DefinedNames::new(
  element : @xml.Element,
) -> CT_DefinedNames raise @opc_errors.SchemaViolation {
  let defined_name : Array[CT_DefinedName] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "definedName" {
        defined_name.push(CT_DefinedName::new(child_element))
      }
    }
  }
  { element, defined_name }
}

///|
/// XSD complex type CT_DefinedName — Part 1 §18.2.5 (`<definedName>`
/// Defined Name). Simple-content extending ST_Formula (the textual
/// formula payload). Required `@name` (s:ST_Xstring). Optional string
/// attributes: `@comment`, `@customMenu`, `@description`, `@help`,
/// `@statusBar`, `@shortcutKey` (s:ST_Xstring). Optional
/// `@localSheetId` (xsd:unsignedInt) and `@functionGroupId`
/// (xsd:unsignedInt). Optional booleans (default false): `@hidden`,
/// `@function`, `@vbProcedure`, `@xlm`, `@publishToServer`,
/// `@workbookParameter`.
pub(all) struct CT_DefinedName {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Simple-content value (ST_Formula text) — the formula payload.
  formula : String
  /// @name (s:ST_Xstring) — required defined-name identifier.
  name : String
  /// @comment (s:ST_Xstring) — optional comment.
  comment : String?
  /// @customMenu (s:ST_Xstring) — optional custom-menu label.
  custom_menu : String?
  /// @description (s:ST_Xstring) — optional description text.
  description : String?
  /// @help (s:ST_Xstring) — optional help text.
  help : String?
  /// @statusBar (s:ST_Xstring) — optional status-bar text.
  status_bar : String?
  /// @localSheetId (xsd:unsignedInt) — optional local sheet index.
  local_sheet_id : Int?
  /// @hidden (xsd:boolean) — optional, default false.
  hidden : Bool
  /// @function (xsd:boolean) — optional, default false.
  function : Bool
  /// @vbProcedure (xsd:boolean) — optional, default false.
  vb_procedure : Bool
  /// @xlm (xsd:boolean) — optional, default false.
  xlm : Bool
  /// @functionGroupId (xsd:unsignedInt) — optional function-group index.
  function_group_id : Int?
  /// @shortcutKey (s:ST_Xstring) — optional shortcut-key glyph.
  shortcut_key : String?
  /// @publishToServer (xsd:boolean) — optional, default false.
  publish_to_server : Bool
  /// @workbookParameter (xsd:boolean) — optional, default false.
  workbook_parameter : Bool
} derive(Eq, Debug)

///|
pub fn CT_DefinedName::new(
  element : @xml.Element,
) -> CT_DefinedName raise @opc_errors.SchemaViolation {
  let formula = element_text(element)
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let comment = attr(element, "comment")
  let custom_menu = attr(element, "customMenu")
  let description = attr(element, "description")
  let help = attr(element, "help")
  let status_bar = attr(element, "statusBar")
  let local_sheet_id = attr_uint_opt_schema(element, "localSheetId")
  let hidden = defined_name_bool(element, "hidden", false)
  let function = defined_name_bool(element, "function", false)
  let vb_procedure = defined_name_bool(element, "vbProcedure", false)
  let xlm = defined_name_bool(element, "xlm", false)
  let function_group_id = attr_uint_opt_schema(element, "functionGroupId")
  let shortcut_key = attr(element, "shortcutKey")
  let publish_to_server = defined_name_bool(element, "publishToServer", false)
  let workbook_parameter = defined_name_bool(
    element, "workbookParameter", false,
  )
  {
    element,
    formula,
    name,
    comment,
    custom_menu,
    description,
    help,
    status_bar,
    local_sheet_id,
    hidden,
    function,
    vb_procedure,
    xlm,
    function_group_id,
    shortcut_key,
    publish_to_server,
    workbook_parameter,
  }
}

///|
/// XSD complex type CT_FileSharing — Part 1 §18.2.12 (`<fileSharing>`
/// File Sharing). Attribute-only. Optional `@readOnlyRecommended`
/// (xsd:boolean, default false); `@userName` (s:ST_Xstring, optional);
/// `@algorithmName` (s:ST_Xstring); `@hashValue` (xsd:base64Binary);
/// `@saltValue` (xsd:base64Binary); `@spinCount` (xsd:unsignedInt).
/// Base64 values are preserved as their lexical strings because the
/// domain does not maintain a binary decoder for the encryption salt.
pub(all) struct CT_FileSharing {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @readOnlyRecommended (xsd:boolean) — optional, default false.
  read_only_recommended : Bool
  /// @userName (s:ST_Xstring) — optional sharing user-name.
  user_name : String?
  /// @algorithmName (s:ST_Xstring) — optional password-hash algorithm.
  algorithm_name : String?
  /// @hashValue (xsd:base64Binary) — optional password-hash, base64 lexical.
  hash_value : String?
  /// @saltValue (xsd:base64Binary) — optional password-salt, base64 lexical.
  salt_value : String?
  /// @spinCount (xsd:unsignedInt) — optional iteration count.
  spin_count : Int?
  /// @reservationPassword (ST_UnsignedShortHex) — legacy 16-bit
  /// verifier hash, deprecated; `None` when absent.
  reservation_password : String?
} derive(Eq, Debug)

///|
pub fn CT_FileSharing::new(
  element : @xml.Element,
) -> CT_FileSharing raise @opc_errors.SchemaViolation {
  let read_only_recommended = file_sharing_bool(
    element, "readOnlyRecommended", false,
  )
  let user_name = attr(element, "userName")
  let algorithm_name = attr(element, "algorithmName")
  let hash_value = attr(element, "hashValue")
  let salt_value = attr(element, "saltValue")
  let spin_count = attr_uint_opt_schema(element, "spinCount")
  let reservation_password = attr(element, "reservationPassword")
  {
    element,
    read_only_recommended,
    user_name,
    algorithm_name,
    hash_value,
    salt_value,
    spin_count,
    reservation_password,
  }
}

///|
/// XSD complex type CT_WebPublishing — Part 1 §18.2.24
/// (`<webPublishing>` Web Publishing Properties). Attribute-only.
/// Optional booleans with defaults: `@css` (true), `@thicket` (true),
/// `@longFileNames` (true), `@vml` (false), `@allowPng` (false).
/// `@targetScreenSize` (ST_TargetScreenSize, default "800x600");
/// `@dpi` (xsd:unsignedInt, default 96); `@characterSet` (xsd:string,
/// optional).
pub(all) struct CT_WebPublishing {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @css (xsd:boolean) — optional, default true.
  css : Bool
  /// @thicket (xsd:boolean) — optional, default true.
  thicket : Bool
  /// @longFileNames (xsd:boolean) — optional, default true.
  long_file_names : Bool
  /// @vml (xsd:boolean) — optional, default false.
  vml : Bool
  /// @allowPng (xsd:boolean) — optional, default false.
  allow_png : Bool
  /// @targetScreenSize (ST_TargetScreenSize) — optional, default "800x600".
  target_screen_size : String
  /// @dpi (xsd:unsignedInt) — optional, default 96.
  dpi : Int
  /// @characterSet (xsd:string) — optional character-set name.
  character_set : String?
  /// @codePage (xsd:int) — optional code page id; `None` when absent.
  code_page : Int?
} derive(Eq, Debug)

///|
pub fn CT_WebPublishing::new(
  element : @xml.Element,
) -> CT_WebPublishing raise @opc_errors.SchemaViolation {
  let css = web_publishing_bool(element, "css", true)
  let thicket = web_publishing_bool(element, "thicket", true)
  let long_file_names = web_publishing_bool(element, "longFileNames", true)
  let vml = web_publishing_bool(element, "vml", false)
  let allow_png = web_publishing_bool(element, "allowPng", false)
  let target_screen_size = match attr(element, "targetScreenSize") {
    Some(value) => value
    None => "800x600"
  }
  let dpi = attr_uint_schema(element, "dpi", 96)
  let character_set = attr(element, "characterSet")
  let code_page = attr_uint_opt_schema(element, "codePage")
  {
    element,
    css,
    thicket,
    long_file_names,
    vml,
    allow_png,
    target_screen_size,
    dpi,
    character_set,
    code_page,
  }
}

///|
/// XSD complex type CT_FunctionGroups — Part 1 §18.2.15
/// (`<functionGroups>` Function Groups container). Sequence:
/// `<functionGroup>*` (CT_FunctionGroup, minOccurs=0; the parent
/// sequence carries maxOccurs="unbounded" in the strict XSD).
/// Optional `@builtInGroupCount` (xsd:unsignedInt, default 16).
pub(all) struct CT_FunctionGroups {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <functionGroup>* (CT_FunctionGroup) — zero or more function-group entries.
  function_group : Array[CT_FunctionGroup]
  /// @builtInGroupCount (xsd:unsignedInt) — optional, default 16.
  built_in_group_count : Int
} derive(Eq, Debug)

///|
pub fn CT_FunctionGroups::new(
  element : @xml.Element,
) -> CT_FunctionGroups raise @opc_errors.SchemaViolation {
  let function_group : Array[CT_FunctionGroup] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "functionGroup" {
        function_group.push(CT_FunctionGroup::new(child_element))
      }
    }
  }
  let built_in_group_count = attr_uint_schema(element, "builtInGroupCount", 16)
  { element, function_group, built_in_group_count }
}

///|
/// XSD complex type CT_FunctionGroup — Part 1 §18.2.14
/// (`<functionGroup>` Function Group). Attribute-only. Optional
/// `@name` (s:ST_Xstring).
pub(all) struct CT_FunctionGroup {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — optional function-group name.
  name : String?
} derive(Eq, Debug)

///|
pub fn CT_FunctionGroup::new(element : @xml.Element) -> CT_FunctionGroup {
  let name = attr(element, "name")
  { element, name }
}
