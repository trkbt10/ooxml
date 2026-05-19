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
/// XSD complex type CT_RevisionMove.
pub(all) struct CT_RevisionMove {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionMove::new(element : @xml.Element) -> CT_RevisionMove {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionFormatting.
pub(all) struct CT_RevisionFormatting {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionFormatting::new(
  element : @xml.Element,
) -> CT_RevisionFormatting {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionAutoFormatting.
pub(all) struct CT_RevisionAutoFormatting {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionAutoFormatting::new(
  element : @xml.Element,
) -> CT_RevisionAutoFormatting {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionComment.
pub(all) struct CT_RevisionComment {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionComment::new(element : @xml.Element) -> CT_RevisionComment {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionDefinedName.
pub(all) struct CT_RevisionDefinedName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionDefinedName::new(
  element : @xml.Element,
) -> CT_RevisionDefinedName {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionConflict.
pub(all) struct CT_RevisionConflict {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionConflict::new(element : @xml.Element) -> CT_RevisionConflict {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Users.
pub(all) struct CT_Users {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Users::new(element : @xml.Element) -> CT_Users {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SharedUser.
pub(all) struct CT_SharedUser {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SharedUser::new(element : @xml.Element) -> CT_SharedUser {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_OutlinePr.
pub(all) struct CT_OutlinePr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OutlinePr::new(element : @xml.Element) -> CT_OutlinePr {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_SmartTags.
pub(all) struct CT_SmartTags {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTags::new(element : @xml.Element) -> CT_SmartTags {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CustomProperties.
pub(all) struct CT_CustomProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomProperties::new(element : @xml.Element) -> CT_CustomProperties {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WebPublishItems.
pub(all) struct CT_WebPublishItems {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebPublishItems::new(element : @xml.Element) -> CT_WebPublishItems {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WebPublishItem.
pub(all) struct CT_WebPublishItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebPublishItem::new(element : @xml.Element) -> CT_WebPublishItem {
  let group_name = workbook_connection_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
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
