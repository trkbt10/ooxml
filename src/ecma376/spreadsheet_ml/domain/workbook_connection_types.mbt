///|
/// SpreadsheetML workbook connection types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn workbook_connection_type_group_name() -> String {
  "spreadsheet_ml.workbook_connection"
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
pub fn CT_SortState::new(element : @xml.Element) -> CT_SortState {
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
  let column_sort = attr_bool(element, "columnSort", false)
  let case_sensitive = attr_bool(element, "caseSensitive", false)
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
pub fn CT_SortCondition::new(element : @xml.Element) -> CT_SortCondition {
  let descending = attr_bool(element, "descending", false)
  let sort_by = match attr(element, "sortBy") {
    Some(value) => value
    None => "value"
  }
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  let custom_list = attr(element, "customList")
  let dxf_id = attr_uint_opt(element, "dxfId")
  let icon_set = match attr(element, "iconSet") {
    Some(value) => value
    None => "3Arrows"
  }
  let icon_id = attr_uint_opt(element, "iconId")
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
pub fn CT_CalcChain::new(element : @xml.Element) -> CT_CalcChain {
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
pub fn CT_Comments::new(element : @xml.Element) -> CT_Comments {
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
pub fn CT_CommentList::new(element : @xml.Element) -> CT_CommentList {
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
pub fn CT_Comment::new(element : @xml.Element) -> CT_Comment {
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
  let author_id = attr_uint(element, "authorId", 0)
  let guid = attr(element, "guid")
  let shape_id = attr_uint_opt(element, "shapeId")
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
pub fn CT_CommentPr::new(element : @xml.Element) -> CT_CommentPr {
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
  let locked = attr_bool(element, "locked", true)
  let default_size = attr_bool(element, "defaultSize", true)
  let print = attr_bool(element, "print", true)
  let disabled = attr_bool(element, "disabled", false)
  let auto_fill = attr_bool(element, "autoFill", true)
  let auto_line = attr_bool(element, "autoLine", true)
  let alt_text = attr(element, "altText")
  let text_h_align = match attr(element, "textHAlign") {
    Some(value) => value
    None => "left"
  }
  let text_v_align = match attr(element, "textVAlign") {
    Some(value) => value
    None => "top"
  }
  let lock_text = attr_bool(element, "lockText", true)
  let just_last_x = attr_bool(element, "justLastX", false)
  let auto_scale = attr_bool(element, "autoScale", false)
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
pub fn CT_Connections::new(element : @xml.Element) -> CT_Connections {
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
pub fn CT_Connection::new(element : @xml.Element) -> CT_Connection {
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
  let id = attr_uint(element, "id", 0)
  let source_file = attr(element, "sourceFile")
  let odc_file = attr(element, "odcFile")
  let keep_alive = attr_bool(element, "keepAlive", false)
  let interval = attr_uint(element, "interval", 0)
  let name = attr(element, "name")
  let description = attr(element, "description")
  let type_ = attr_uint_opt(element, "type")
  let reconnection_method = attr_uint(element, "reconnectionMethod", 1)
  let refreshed_version = attr_uint(element, "refreshedVersion", 0)
  let min_refreshable_version = attr_uint(element, "minRefreshableVersion", 0)
  let save_password = attr_bool(element, "savePassword", false)
  let new_ = attr_bool(element, "new", false)
  let deleted = attr_bool(element, "deleted", false)
  let only_use_connection_file = attr_bool(
    element, "onlyUseConnectionFile", false,
  )
  let background = attr_bool(element, "background", false)
  let refresh_on_load = attr_bool(element, "refreshOnLoad", false)
  let save_data = attr_bool(element, "saveData", false)
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
pub fn CT_DbPr::new(element : @xml.Element) -> CT_DbPr {
  let connection = match attr(element, "connection") {
    Some(value) => value
    None => ""
  }
  let command = attr(element, "command")
  let server_command = attr(element, "serverCommand")
  let command_type = attr_uint(element, "commandType", 2)
  { element, connection, command, server_command, command_type }
}

///|
/// XSD complex type CT_OlapPr: OLAP connection properties with local refresh, locale, row drill count, server fill, number format, font attributes.
pub(all) struct CT_OlapPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OlapPr::new(element : @xml.Element) -> CT_OlapPr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WebPr: Schema sml.xsd complex type `CT_WebPr` has
/// attributes `xml`, `sourceData`, `parsePre`, `consecutive`, `firstRow`,
/// `xl97`, `textDates`, `xl2000`, `url`, `post`, `htmlTables`, `htmlFormat`,
/// and `editPage`, with `tables` children; CT_WebPr and CT_WebPr::new own
/// those web query properties.
pub(all) struct CT_WebPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebPr::new(element : @xml.Element) -> CT_WebPr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Parameters.
pub(all) struct CT_Parameters {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Parameters::new(element : @xml.Element) -> CT_Parameters {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Parameter.
pub(all) struct CT_Parameter {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Parameter::new(element : @xml.Element) -> CT_Parameter {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TextPr.
pub(all) struct CT_TextPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextPr::new(element : @xml.Element) -> CT_TextPr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TextFields.
pub(all) struct CT_TextFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextFields::new(element : @xml.Element) -> CT_TextFields {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TextField.
pub(all) struct CT_TextField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextField::new(element : @xml.Element) -> CT_TextField {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Consolidation.
pub(all) struct CT_Consolidation {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Consolidation::new(element : @xml.Element) -> CT_Consolidation {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SharedItems.
pub(all) struct CT_SharedItems {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SharedItems::new(element : @xml.Element) -> CT_SharedItems {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Missing.
pub(all) struct CT_Missing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Missing::new(element : @xml.Element) -> CT_Missing {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Number.
pub(all) struct CT_Number {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Number::new(element : @xml.Element) -> CT_Number {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Error: Schema sml.xsd complex type `CT_Error` has
/// attributes `v`, `u`, `f`, `c`, `cp`, `in`, `bc`, `fc`, `i`, `un`, `st`,
/// and `b`, with `tpls` and `x` children; CT_Error and CT_Error::new own that
/// pivot cache error item.
pub(all) struct CT_Error {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Error::new(element : @xml.Element) -> CT_Error {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DateTime.
pub(all) struct CT_DateTime {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DateTime::new(element : @xml.Element) -> CT_DateTime {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FieldGroup.
pub(all) struct CT_FieldGroup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FieldGroup::new(element : @xml.Element) -> CT_FieldGroup {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RangePr.
pub(all) struct CT_RangePr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RangePr::new(element : @xml.Element) -> CT_RangePr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DiscretePr.
pub(all) struct CT_DiscretePr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DiscretePr::new(element : @xml.Element) -> CT_DiscretePr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_GroupItems.
pub(all) struct CT_GroupItems {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupItems::new(element : @xml.Element) -> CT_GroupItems {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Record.
pub(all) struct CT_Record {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Record::new(element : @xml.Element) -> CT_Record {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FieldsUsage.
pub(all) struct CT_FieldsUsage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FieldsUsage::new(element : @xml.Element) -> CT_FieldsUsage {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FieldUsage.
pub(all) struct CT_FieldUsage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FieldUsage::new(element : @xml.Element) -> CT_FieldUsage {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_GroupLevels.
pub(all) struct CT_GroupLevels {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupLevels::new(element : @xml.Element) -> CT_GroupLevels {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_GroupLevel.
pub(all) struct CT_GroupLevel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupLevel::new(element : @xml.Element) -> CT_GroupLevel {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Groups.
pub(all) struct CT_Groups {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Groups::new(element : @xml.Element) -> CT_Groups {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_LevelGroup.
pub(all) struct CT_LevelGroup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LevelGroup::new(element : @xml.Element) -> CT_LevelGroup {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ServerFormat.
pub(all) struct CT_ServerFormat {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ServerFormat::new(element : @xml.Element) -> CT_ServerFormat {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ServerFormats.
pub(all) struct CT_ServerFormats {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ServerFormats::new(element : @xml.Element) -> CT_ServerFormats {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Location.
pub(all) struct CT_Location {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Location::new(element : @xml.Element) -> CT_Location {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_AutoSortScope.
pub(all) struct CT_AutoSortScope {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AutoSortScope::new(element : @xml.Element) -> CT_AutoSortScope {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Items.
pub(all) struct CT_Items {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Items::new(element : @xml.Element) -> CT_Items {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Item.
pub(all) struct CT_Item {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Item::new(element : @xml.Element) -> CT_Item {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_I: Schema sml.xsd complex type `CT_I` has attributes
/// `t`, `r`, and `i`, and `x` children of type CT_X; CT_I and CT_I::new own
/// that pivot row or column item.
pub(all) struct CT_I {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_I::new(element : @xml.Element) -> CT_I {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_X: Schema sml.xsd complex type `CT_X` has attribute
/// `v`; CT_X and CT_X::new own that pivot tuple index value.
pub(all) struct CT_X {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_X::new(element : @xml.Element) -> CT_X {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Field.
pub(all) struct CT_Field {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Field::new(element : @xml.Element) -> CT_Field {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Formats.
pub(all) struct CT_Formats {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Formats::new(element : @xml.Element) -> CT_Formats {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Format: pivot table format with pivotArea and extLst children plus action and dxfId attributes.
pub(all) struct CT_Format {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Format::new(element : @xml.Element) -> CT_Format {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Dimensions.
pub(all) struct CT_Dimensions {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Dimensions::new(element : @xml.Element) -> CT_Dimensions {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Index.
pub(all) struct CT_Index {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Index::new(element : @xml.Element) -> CT_Index {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DeletedField.
pub(all) struct CT_DeletedField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DeletedField::new(element : @xml.Element) -> CT_DeletedField {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Revisions.
pub(all) struct CT_Revisions {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Revisions::new(element : @xml.Element) -> CT_Revisions {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_UndoInfo.
pub(all) struct CT_UndoInfo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_UndoInfo::new(element : @xml.Element) -> CT_UndoInfo {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
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
pub fn CT_RevisionMove::new(element : @xml.Element) -> CT_RevisionMove {
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
  let sheet_id = attr_uint(element, "sheetId", 0)
  let source = match attr(element, "source") {
    Some(value) => value
    None => ""
  }
  let destination = match attr(element, "destination") {
    Some(value) => value
    None => ""
  }
  let source_sheet_id = attr_uint(element, "sourceSheetId", 0)
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
) -> CT_RevisionFormatting {
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
  let sheet_id = attr_uint(element, "sheetId", 0)
  let xf_dxf = attr_bool(element, "xfDxf", false)
  let s = attr_bool(element, "s", false)
  let sqref = match attr(element, "sqref") {
    Some(value) => value
    None => ""
  }
  let start = attr_uint_opt(element, "start")
  let length = attr_uint_opt(element, "length")
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
) -> CT_RevisionAutoFormatting {
  let sheet_id = attr_uint(element, "sheetId", 0)
  let auto_format_id = attr_uint_opt(element, "autoFormatId")
  let apply_number_formats = attr_bool_opt(element, "applyNumberFormats")
  let apply_border_formats = attr_bool_opt(element, "applyBorderFormats")
  let apply_font_formats = attr_bool_opt(element, "applyFontFormats")
  let apply_pattern_formats = attr_bool_opt(element, "applyPatternFormats")
  let apply_alignment_formats = attr_bool_opt(element, "applyAlignmentFormats")
  let apply_width_height_formats = attr_bool_opt(
    element, "applyWidthHeightFormats",
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
pub fn CT_RevisionComment::new(element : @xml.Element) -> CT_RevisionComment {
  let sheet_id = attr_uint(element, "sheetId", 0)
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
  let always_show = attr_bool(element, "alwaysShow", false)
  let old = attr_bool(element, "old", false)
  let hidden_row = attr_bool(element, "hiddenRow", false)
  let hidden_column = attr_bool(element, "hiddenColumn", false)
  let author = match attr(element, "author") {
    Some(value) => value
    None => ""
  }
  let old_length = attr_uint(element, "oldLength", 0)
  let new_length = attr_uint(element, "newLength", 0)
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
) -> CT_RevisionDefinedName {
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
  let ua = attr_bool(element, "ua", false)
  let ra = attr_bool(element, "ra", false)
  let local_sheet_id = attr_uint_opt(element, "localSheetId")
  let custom_view = attr_bool(element, "customView", false)
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let function = attr_bool(element, "function", false)
  let old_function = attr_bool(element, "oldFunction", false)
  let function_group_id = attr_uint_opt(element, "functionGroupId")
  let old_function_group_id = attr_uint_opt(element, "oldFunctionGroupId")
  let shortcut_key = attr_uint_opt(element, "shortcutKey")
  let old_shortcut_key = attr_uint_opt(element, "oldShortcutKey")
  let hidden = attr_bool(element, "hidden", false)
  let old_hidden = attr_bool(element, "oldHidden", false)
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
pub fn CT_RevisionConflict::new(element : @xml.Element) -> CT_RevisionConflict {
  let r_id = attr_uint(element, "rId", 0)
  let ua = attr_bool(element, "ua", false)
  let ra = attr_bool(element, "ra", false)
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
pub fn CT_OutlinePr::new(element : @xml.Element) -> CT_OutlinePr {
  let apply_styles = attr_bool(element, "applyStyles", false)
  let summary_below = attr_bool(element, "summaryBelow", true)
  let summary_right = attr_bool(element, "summaryRight", true)
  let show_outline_symbols = attr_bool(element, "showOutlineSymbols", true)
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
pub fn CT_SmartTags::new(element : @xml.Element) -> CT_SmartTags {
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
pub fn CT_WebPublishItems::new(element : @xml.Element) -> CT_WebPublishItems {
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
pub fn CT_WebPublishItem::new(element : @xml.Element) -> CT_WebPublishItem {
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
  let auto_republish = attr_bool(element, "autoRepublish", false)
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
/// XSD complex type CT_GradientStop.
pub(all) struct CT_GradientStop {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GradientStop::new(element : @xml.Element) -> CT_GradientStop {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Workbook.
pub(all) struct CT_Workbook {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Workbook::new(element : @xml.Element) -> CT_Workbook {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FileVersion.
pub(all) struct CT_FileVersion {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FileVersion::new(element : @xml.Element) -> CT_FileVersion {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WorkbookPr.
pub(all) struct CT_WorkbookPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WorkbookPr::new(element : @xml.Element) -> CT_WorkbookPr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SmartTagPr.
pub(all) struct CT_SmartTagPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTagPr::new(element : @xml.Element) -> CT_SmartTagPr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SmartTagTypes.
pub(all) struct CT_SmartTagTypes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTagTypes::new(element : @xml.Element) -> CT_SmartTagTypes {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SmartTagType.
pub(all) struct CT_SmartTagType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTagType::new(element : @xml.Element) -> CT_SmartTagType {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FileRecoveryPr.
pub(all) struct CT_FileRecoveryPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FileRecoveryPr::new(element : @xml.Element) -> CT_FileRecoveryPr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CalcPr: workbook calculation properties with calcId, calcMode, refMode, iterate, fullPrecision, concurrentCalc, forceFullCalc attributes.
pub(all) struct CT_CalcPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CalcPr::new(element : @xml.Element) -> CT_CalcPr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DefinedNames.
pub(all) struct CT_DefinedNames {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DefinedNames::new(element : @xml.Element) -> CT_DefinedNames {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_DefinedName.
pub(all) struct CT_DefinedName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DefinedName::new(element : @xml.Element) -> CT_DefinedName {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FileSharing.
pub(all) struct CT_FileSharing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FileSharing::new(element : @xml.Element) -> CT_FileSharing {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WebPublishing.
pub(all) struct CT_WebPublishing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebPublishing::new(element : @xml.Element) -> CT_WebPublishing {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FunctionGroups.
pub(all) struct CT_FunctionGroups {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FunctionGroups::new(element : @xml.Element) -> CT_FunctionGroups {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FunctionGroup.
pub(all) struct CT_FunctionGroup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FunctionGroup::new(element : @xml.Element) -> CT_FunctionGroup {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}
