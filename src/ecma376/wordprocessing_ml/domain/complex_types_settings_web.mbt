///|
/// XSD complex type CT_RecipientData — Part 1 §17.14.30 (recipientData
/// Mail Merge Single Recipient Data). Sequence: optional `<w:active>`
/// (CT_OnOff per §17.17.4) marking whether the recipient is selected,
/// required `<w:column>` (CT_DecimalNumber per §17.18.10) naming the
/// data-source column index and required `<w:uniqueTag>`
/// (CT_Base64Binary per §17.14.31) carrying the recipient's unique
/// identifier as a base64 binary value.
pub(all) struct CT_RecipientData {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.17.4 `<w:active>` (CT_OnOff) — optional selected-flag child.
  active : CT_OnOff?
  /// §17.18.10 `<w:column>` (CT_DecimalNumber) — required column index.
  column : CT_DecimalNumber
  /// §17.14.31 `<w:uniqueTag>` (CT_Base64Binary) — required unique identifier.
  unique_tag : CT_Base64Binary
} derive(Eq, Debug)

///|
/// XSD complex type CT_RecipientData — Part 1 §17.14.30. Decode the
/// optional `<w:active>` and both required children, raising
/// SchemaViolation when either required child is absent or invalid.
pub fn CT_RecipientData::new(
  element : @xml.Element,
) -> CT_RecipientData raise SchemaViolation {
  let active = match wml_ct_chunk2_first_child(element, "active") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let column = match wml_ct_chunk2_first_child(element, "column") {
    Some(child) => CT_DecimalNumber::new(child)
    None =>
      raise_schema_violation(
        "CT_RecipientData", "column", "Part 1 §17.14.30: required child <w:column> is missing",
      )
  }
  let unique_tag = match wml_ct_chunk2_first_child(element, "uniqueTag") {
    Some(child) => CT_Base64Binary::new(child)
    None =>
      raise_schema_violation(
        "CT_RecipientData", "uniqueTag", "Part 1 §17.14.30: required child <w:uniqueTag> is missing",
      )
  }
  { element, active, column, unique_tag }
}

///|
/// XSD complex type CT_RecipientData — Part 1 §17.14.30.
pub fn CT_RecipientData::parse(
  element : @xml.Element,
) -> CT_RecipientData raise SchemaViolation {
  CT_RecipientData::new(element)
}

///|
pub fn CT_RecipientData::to_element(self : CT_RecipientData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Recipients — Part 1 §17.14.31 (recipients Mail
/// Merge Recipient Information). Sequence container holding one or
/// more `<w:recipientData>` children (CT_RecipientData per §17.14.30).
pub(all) struct CT_Recipients {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.14.30 `<w:recipientData>` (CT_RecipientData)+ — recipient entries.
  recipient_data : Array[CT_RecipientData]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Recipients — Part 1 §17.14.31. Decode each
/// `<w:recipientData>` child, propagating SchemaViolation from the
/// typed CT_RecipientData constructor.
pub fn CT_Recipients::new(
  element : @xml.Element,
) -> CT_Recipients raise SchemaViolation {
  let recipient_data : Array[CT_RecipientData] = []
  for child in wml_ct_chunk2_children(element, "recipientData") {
    recipient_data.push(CT_RecipientData::new(child))
  }
  { element, recipient_data }
}

///|
/// XSD complex type CT_Recipients — Part 1 §17.14.31.
pub fn CT_Recipients::parse(
  element : @xml.Element,
) -> CT_Recipients raise SchemaViolation {
  CT_Recipients::new(element)
}

///|
pub fn CT_Recipients::to_element(self : CT_Recipients) -> @xml.Element {
  self.element
}

// WordprocessingML chunk6 typed complex types — wml.xsd §17.14 (Mail
// Merge), §17.15 (Settings), §11.5 (Framesets), §17.11 (Caption /
// AutoCaption tables) and §17.7 (Web settings) CT_* wrappers. Each
// former `element : @xml.Element` wrapper is replaced with a typed
// projection of every XSD attribute and child element declared by Part
// 4 / wml.xsd. The source `<w:...>` element is preserved alongside the
// typed fields so the builder can still round-trip unchanged markup.
// The chunk6 helpers needed for attribute / child lookup are defined in
// `complex_types_table.mbt` (`wml_ct_chunk6_*`) and are reused here.

///|
/// XSD complex type CT_OdsoFieldMapData — Part 1 §17.14.42 (odso Field
/// Map Data entry). Sequence of six optional children carrying the
/// mapping of one ODSO column to a mail-merge field: `<w:type>`
/// (CT_MailMergeOdsoFMDFieldType per §17.14.33), `<w:name>` (CT_String
/// per §22.9.2.13), `<w:mappedName>` (CT_String), `<w:column>`
/// (CT_DecimalNumber per §17.18.10), `<w:lid>` (CT_Lang per §22.9.2.6)
/// and `<w:dynamicAddress>` (CT_OnOff per §17.17.4).
pub(all) struct CT_OdsoFieldMapData {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.14.33 `<w:type>` (CT_MailMergeOdsoFMDFieldType) — optional mapping kind.
  type_ : CT_MailMergeOdsoFMDFieldType?
  /// §22.9.2.13 `<w:name>` (CT_String) — optional source column name.
  name : CT_String?
  /// §22.9.2.13 `<w:mappedName>` (CT_String) — optional target field name.
  mapped_name : CT_String?
  /// §17.18.10 `<w:column>` (CT_DecimalNumber) — optional column index.
  column : CT_DecimalNumber?
  /// §22.9.2.6 `<w:lid>` (CT_Lang) — optional language identifier.
  lid : CT_Lang?
  /// §17.17.4 `<w:dynamicAddress>` (CT_OnOff) — optional dynamic-address flag.
  dynamic_address : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_OdsoFieldMapData — Part 1 §17.14.42.
pub fn CT_OdsoFieldMapData::new(
  element : @xml.Element,
) -> CT_OdsoFieldMapData raise SchemaViolation {
  let type_ = match wml_ct_chunk6_first_child(element, "type") {
    Some(child) => Some(CT_MailMergeOdsoFMDFieldType::new(child))
    None => None
  }
  let name = match wml_ct_chunk6_first_child(element, "name") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let mapped_name = match wml_ct_chunk6_first_child(element, "mappedName") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let column = match wml_ct_chunk6_first_child(element, "column") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let lid = match wml_ct_chunk6_first_child(element, "lid") {
    Some(child) => Some(CT_Lang::new(child))
    None => None
  }
  let dynamic_address = match
    wml_ct_chunk6_first_child(element, "dynamicAddress") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  { element, type_, name, mapped_name, column, lid, dynamic_address }
}

///|
/// XSD complex type CT_OdsoFieldMapData — Part 1 §17.14.42.
pub fn CT_OdsoFieldMapData::parse(
  element : @xml.Element,
) -> CT_OdsoFieldMapData raise SchemaViolation {
  CT_OdsoFieldMapData::new(element)
}

///|
pub fn CT_OdsoFieldMapData::to_element(
  self : CT_OdsoFieldMapData,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeSourceType — Part 1 §17.14.50 (odso
/// `<w:type>` Mail Merge Source Type). Required `@val` ST_MailMergeSourceType
/// (Part 1 §17.18.53) names the kind of external data source.
pub(all) struct CT_MailMergeSourceType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.53 @val (ST_MailMergeSourceType) — required source kind.
  val : ST_MailMergeSourceType
} derive(Eq, Debug)

///|
/// XSD complex type CT_MailMergeSourceType — Part 1 §17.14.50.
pub fn CT_MailMergeSourceType::new(
  element : @xml.Element,
) -> CT_MailMergeSourceType raise SchemaViolation {
  let raw = wml_ct_chunk6_required_attr(
    element, "val", "CT_MailMergeSourceType", "Part 1 §17.18.53 ST_MailMergeSourceType",
  )
  let val = ST_MailMergeSourceType::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_MailMergeSourceType — Part 1 §17.14.50.
pub fn CT_MailMergeSourceType::parse(
  element : @xml.Element,
) -> CT_MailMergeSourceType raise SchemaViolation {
  CT_MailMergeSourceType::new(element)
}

///|
pub fn CT_MailMergeSourceType::to_element(
  self : CT_MailMergeSourceType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Odso — Part 1 §17.14.24 (odso Office Data Source
/// Object Settings). Sequence of eight optional children describing the
/// connection to a mail-merge data source: UDL connection string, table
/// name, source relationship, column delimiter, source type, header
/// flag, plus unbounded ODSO field-mapping entries and recipient-data
/// relationships.
pub(all) struct CT_Odso {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 `<w:udl>` (CT_String) — optional UDL connection.
  udl : CT_String?
  /// §22.9.2.13 `<w:table>` (CT_String) — optional table name.
  table : CT_String?
  /// §A.1 `<w:src>` (CT_Rel) — optional source relationship.
  src : CT_Rel?
  /// §17.18.10 `<w:colDelim>` (CT_DecimalNumber) — optional column delimiter codepoint.
  col_delim : CT_DecimalNumber?
  /// §17.14.50 `<w:type>` (CT_MailMergeSourceType) — optional source type.
  type_ : CT_MailMergeSourceType?
  /// §17.17.4 `<w:fHdr>` (CT_OnOff) — optional first-row-header flag.
  f_hdr : CT_OnOff?
  /// §17.14.42 `<w:fieldMapData>` (CT_OdsoFieldMapData)* — field-mapping entries.
  field_map_data : Array[CT_OdsoFieldMapData]
  /// §A.1 `<w:recipientData>` (CT_Rel)* — recipient-data relationships.
  recipient_data : Array[CT_Rel]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Odso — Part 1 §17.14.24.
pub fn CT_Odso::new(element : @xml.Element) -> CT_Odso raise SchemaViolation {
  let udl = match wml_ct_chunk6_first_child(element, "udl") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let table = match wml_ct_chunk6_first_child(element, "table") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let src = match wml_ct_chunk6_first_child(element, "src") {
    Some(child) => Some(CT_Rel::new(child))
    None => None
  }
  let col_delim = match wml_ct_chunk6_first_child(element, "colDelim") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let type_ = match wml_ct_chunk6_first_child(element, "type") {
    Some(child) => Some(CT_MailMergeSourceType::new(child))
    None => None
  }
  let f_hdr = match wml_ct_chunk6_first_child(element, "fHdr") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let field_map_data : Array[CT_OdsoFieldMapData] = []
  for child in wml_ct_chunk6_children(element, "fieldMapData") {
    field_map_data.push(CT_OdsoFieldMapData::new(child))
  }
  let recipient_data : Array[CT_Rel] = []
  for child in wml_ct_chunk6_children(element, "recipientData") {
    recipient_data.push(CT_Rel::new(child))
  }
  {
    element,
    udl,
    table,
    src,
    col_delim,
    type_,
    f_hdr,
    field_map_data,
    recipient_data,
  }
}

///|
/// XSD complex type CT_Odso — Part 1 §17.14.24.
pub fn CT_Odso::parse(element : @xml.Element) -> CT_Odso raise SchemaViolation {
  CT_Odso::new(element)
}

///|
pub fn CT_Odso::to_element(self : CT_Odso) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMerge — Part 1 §17.14.20 (mailMerge Mail
/// Merge Source Settings). Sequence of sixteen children describing the
/// document's mail-merge state. Required `<w:mainDocumentType>` and
/// `<w:dataType>` select the document and data formats; the remaining
/// fourteen children are optional (link-to-query flag, connection
/// string, query, data/header sources, options and the ODSO block).
pub(all) struct CT_MailMerge {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.14.22 `<w:mainDocumentType>` (CT_MailMergeDocType) — required document kind.
  main_document_type : CT_MailMergeDocType
  /// §17.17.4 `<w:linkToQuery>` (CT_OnOff) — optional link-to-query flag.
  link_to_query : CT_OnOff?
  /// §17.14.15 `<w:dataType>` (CT_MailMergeDataType) — required data-source format.
  data_type : CT_MailMergeDataType
  /// §22.9.2.13 `<w:connectString>` (CT_String) — optional ODSO connection string.
  connect_string : CT_String?
  /// §22.9.2.13 `<w:query>` (CT_String) — optional ODSO query string.
  query : CT_String?
  /// §A.1 `<w:dataSource>` (CT_Rel) — optional data-source relationship.
  data_source : CT_Rel?
  /// §A.1 `<w:headerSource>` (CT_Rel) — optional header-source relationship.
  header_source : CT_Rel?
  /// §17.17.4 `<w:doNotSuppressBlankLines>` (CT_OnOff) — optional blank-line flag.
  do_not_suppress_blank_lines : CT_OnOff?
  /// §17.14.16 `<w:destination>` (CT_MailMergeDest) — optional output destination.
  destination : CT_MailMergeDest?
  /// §22.9.2.13 `<w:addressFieldName>` (CT_String) — optional address-field name.
  address_field_name : CT_String?
  /// §22.9.2.13 `<w:mailSubject>` (CT_String) — optional mail subject template.
  mail_subject : CT_String?
  /// §17.17.4 `<w:mailAsAttachment>` (CT_OnOff) — optional attach-mail flag.
  mail_as_attachment : CT_OnOff?
  /// §17.17.4 `<w:viewMergedData>` (CT_OnOff) — optional view-merged flag.
  view_merged_data : CT_OnOff?
  /// §17.18.10 `<w:activeRecord>` (CT_DecimalNumber) — optional active record index.
  active_record : CT_DecimalNumber?
  /// §17.18.10 `<w:checkErrors>` (CT_DecimalNumber) — optional error-checking mode.
  check_errors : CT_DecimalNumber?
  /// §17.14.24 `<w:odso>` (CT_Odso) — optional ODSO settings block.
  odso : CT_Odso?
} derive(Eq, Debug)

///|
/// XSD complex type CT_MailMerge — Part 1 §17.14.20.
pub fn CT_MailMerge::new(
  element : @xml.Element,
) -> CT_MailMerge raise SchemaViolation {
  let main_document_type = match
    wml_ct_chunk6_first_child(element, "mainDocumentType") {
    Some(child) => CT_MailMergeDocType::new(child)
    None =>
      raise_schema_violation(
        "CT_MailMerge", "mainDocumentType", "Part 1 §17.14.20: required child <w:mainDocumentType> is missing",
      )
  }
  let link_to_query = match wml_ct_chunk6_first_child(element, "linkToQuery") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let data_type = match wml_ct_chunk6_first_child(element, "dataType") {
    Some(child) => CT_MailMergeDataType::new(child)
    None =>
      raise_schema_violation(
        "CT_MailMerge", "dataType", "Part 1 §17.14.20: required child <w:dataType> is missing",
      )
  }
  let connect_string = match
    wml_ct_chunk6_first_child(element, "connectString") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let query = match wml_ct_chunk6_first_child(element, "query") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let data_source = match wml_ct_chunk6_first_child(element, "dataSource") {
    Some(child) => Some(CT_Rel::new(child))
    None => None
  }
  let header_source = match wml_ct_chunk6_first_child(element, "headerSource") {
    Some(child) => Some(CT_Rel::new(child))
    None => None
  }
  let do_not_suppress_blank_lines = match
    wml_ct_chunk6_first_child(element, "doNotSuppressBlankLines") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let destination = match wml_ct_chunk6_first_child(element, "destination") {
    Some(child) => Some(CT_MailMergeDest::new(child))
    None => None
  }
  let address_field_name = match
    wml_ct_chunk6_first_child(element, "addressFieldName") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let mail_subject = match wml_ct_chunk6_first_child(element, "mailSubject") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let mail_as_attachment = match
    wml_ct_chunk6_first_child(element, "mailAsAttachment") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let view_merged_data = match
    wml_ct_chunk6_first_child(element, "viewMergedData") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let active_record = match wml_ct_chunk6_first_child(element, "activeRecord") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let check_errors = match wml_ct_chunk6_first_child(element, "checkErrors") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let odso = match wml_ct_chunk6_first_child(element, "odso") {
    Some(child) => Some(CT_Odso::new(child))
    None => None
  }
  {
    element,
    main_document_type,
    link_to_query,
    data_type,
    connect_string,
    query,
    data_source,
    header_source,
    do_not_suppress_blank_lines,
    destination,
    address_field_name,
    mail_subject,
    mail_as_attachment,
    view_merged_data,
    active_record,
    check_errors,
    odso,
  }
}

///|
/// XSD complex type CT_MailMerge — Part 1 §17.14.20.
pub fn CT_MailMerge::parse(
  element : @xml.Element,
) -> CT_MailMerge raise SchemaViolation {
  CT_MailMerge::new(element)
}

///|
pub fn CT_MailMerge::to_element(self : CT_MailMerge) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TargetScreenSz — Part 1 §17.15.1.84 (targetScreenSz
/// Target Screen Size for HTML output). Required `@val`
/// ST_TargetScreenSz (Part 1 §17.18.92) names the target resolution.
pub(all) struct CT_TargetScreenSz {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.92 @val (ST_TargetScreenSz) — required target resolution.
  val : ST_TargetScreenSz
} derive(Eq, Debug)

///|
/// XSD complex type CT_TargetScreenSz — Part 1 §17.15.1.84.
pub fn CT_TargetScreenSz::new(
  element : @xml.Element,
) -> CT_TargetScreenSz raise SchemaViolation {
  let raw = wml_ct_chunk6_required_attr(
    element, "val", "CT_TargetScreenSz", "Part 1 §17.18.92 ST_TargetScreenSz",
  )
  let val = ST_TargetScreenSz::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_TargetScreenSz — Part 1 §17.15.1.84.
pub fn CT_TargetScreenSz::parse(
  element : @xml.Element,
) -> CT_TargetScreenSz raise SchemaViolation {
  CT_TargetScreenSz::new(element)
}

///|
pub fn CT_TargetScreenSz::to_element(self : CT_TargetScreenSz) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Compat — Part 1 §17.15.1.7 (compat Compatibility
/// Settings). Sequence of seven optional legacy-compatibility CT_OnOff
/// flags (spaceForUL, balanceSingleByteDoubleByteWidth,
/// doNotLeaveBackslashAlone, ulTrailSpace, doNotExpandShiftReturn,
/// adjustLineHeightInTable, applyBreakingRules) plus zero-or-more
/// `<w:compatSetting>` (CT_CompatSetting per §17.15.1.9) entries.
pub(all) struct CT_Compat {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.17.4 `<w:spaceForUL>` (CT_OnOff) — optional ULine spacing flag.
  space_for_ul : CT_OnOff?
  /// §17.17.4 `<w:balanceSingleByteDoubleByteWidth>` (CT_OnOff).
  balance_single_byte_double_byte_width : CT_OnOff?
  /// §17.17.4 `<w:doNotLeaveBackslashAlone>` (CT_OnOff).
  do_not_leave_backslash_alone : CT_OnOff?
  /// §17.17.4 `<w:ulTrailSpace>` (CT_OnOff).
  ul_trail_space : CT_OnOff?
  /// §17.17.4 `<w:doNotExpandShiftReturn>` (CT_OnOff).
  do_not_expand_shift_return : CT_OnOff?
  /// §17.17.4 `<w:adjustLineHeightInTable>` (CT_OnOff).
  adjust_line_height_in_table : CT_OnOff?
  /// §17.17.4 `<w:applyBreakingRules>` (CT_OnOff).
  apply_breaking_rules : CT_OnOff?
  /// §17.15.1.9 `<w:compatSetting>` (CT_CompatSetting)* — open-ended compatibility entries.
  compat_setting : Array[CT_CompatSetting]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Compat — Part 1 §17.15.1.7.
pub fn CT_Compat::new(element : @xml.Element) -> CT_Compat {
  let space_for_ul = match wml_ct_chunk6_first_child(element, "spaceForUL") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let balance_single_byte_double_byte_width = match
    wml_ct_chunk6_first_child(element, "balanceSingleByteDoubleByteWidth") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let do_not_leave_backslash_alone = match
    wml_ct_chunk6_first_child(element, "doNotLeaveBackslashAlone") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let ul_trail_space = match
    wml_ct_chunk6_first_child(element, "ulTrailSpace") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let do_not_expand_shift_return = match
    wml_ct_chunk6_first_child(element, "doNotExpandShiftReturn") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let adjust_line_height_in_table = match
    wml_ct_chunk6_first_child(element, "adjustLineHeightInTable") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let apply_breaking_rules = match
    wml_ct_chunk6_first_child(element, "applyBreakingRules") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let compat_setting : Array[CT_CompatSetting] = []
  for child in wml_ct_chunk6_children(element, "compatSetting") {
    compat_setting.push(CT_CompatSetting::new(child))
  }
  {
    element,
    space_for_ul,
    balance_single_byte_double_byte_width,
    do_not_leave_backslash_alone,
    ul_trail_space,
    do_not_expand_shift_return,
    adjust_line_height_in_table,
    apply_breaking_rules,
    compat_setting,
  }
}

///|
/// XSD complex type CT_Compat — Part 1 §17.15.1.7.
pub fn CT_Compat::parse(element : @xml.Element) -> CT_Compat {
  CT_Compat::new(element)
}

///|
pub fn CT_Compat::to_element(self : CT_Compat) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CompatSetting — Part 1 §17.15.1.9 (compatSetting
/// Single Compatibility Setting). Three optional s:ST_String attributes:
/// `@name` (compatibility-flag identifier), `@uri` (namespace) and
/// `@val` (string value).
pub(all) struct CT_CompatSetting {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @name (s:ST_String) — optional setting identifier.
  name : String?
  /// §22.9.2.13 @uri (s:ST_String) — optional setting namespace.
  uri : String?
  /// §22.9.2.13 @val (s:ST_String) — optional setting value.
  val : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_CompatSetting — Part 1 §17.15.1.9.
pub fn CT_CompatSetting::new(element : @xml.Element) -> CT_CompatSetting {
  let name = wml_ct_chunk6_attr(element, "name")
  let uri = wml_ct_chunk6_attr(element, "uri")
  let val = wml_ct_chunk6_attr(element, "val")
  { element, name, uri, val }
}

///|
/// XSD complex type CT_CompatSetting — Part 1 §17.15.1.9.
pub fn CT_CompatSetting::parse(element : @xml.Element) -> CT_CompatSetting {
  CT_CompatSetting::new(element)
}

///|
pub fn CT_CompatSetting::to_element(self : CT_CompatSetting) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocVar — Part 1 §17.15.1.36 (docVar Single
/// Document Variable). Two required s:ST_String attributes: `@name`
/// names the variable and `@val` carries its persisted string value.
pub(all) struct CT_DocVar {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @name (s:ST_String) — required variable name.
  name : String
  /// §22.9.2.13 @val (s:ST_String) — required variable value.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocVar — Part 1 §17.15.1.36.
pub fn CT_DocVar::new(
  element : @xml.Element,
) -> CT_DocVar raise SchemaViolation {
  let name = wml_ct_chunk6_required_attr(
    element, "name", "CT_DocVar", "Part 1 §22.9.2.13 s:ST_String",
  )
  let val = wml_ct_chunk6_required_attr(
    element, "val", "CT_DocVar", "Part 1 §22.9.2.13 s:ST_String",
  )
  { element, name, val }
}

///|
/// XSD complex type CT_DocVar — Part 1 §17.15.1.36.
pub fn CT_DocVar::parse(
  element : @xml.Element,
) -> CT_DocVar raise SchemaViolation {
  CT_DocVar::new(element)
}

///|
pub fn CT_DocVar::to_element(self : CT_DocVar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocVars — Part 1 §17.15.1.37 (docVars Document
/// Variables). Sequence container holding zero-or-more `<w:docVar>`
/// (CT_DocVar per §17.15.1.36) entries.
pub(all) struct CT_DocVars {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.15.1.36 `<w:docVar>` (CT_DocVar)* — document variable entries.
  doc_var : Array[CT_DocVar]
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocVars — Part 1 §17.15.1.37.
pub fn CT_DocVars::new(
  element : @xml.Element,
) -> CT_DocVars raise SchemaViolation {
  let doc_var : Array[CT_DocVar] = []
  for child in wml_ct_chunk6_children(element, "docVar") {
    doc_var.push(CT_DocVar::new(child))
  }
  { element, doc_var }
}

///|
/// XSD complex type CT_DocVars — Part 1 §17.15.1.37.
pub fn CT_DocVars::parse(
  element : @xml.Element,
) -> CT_DocVars raise SchemaViolation {
  CT_DocVars::new(element)
}

///|
pub fn CT_DocVars::to_element(self : CT_DocVars) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocRsids — Part 1 §17.15.1.72 (rsids Document
/// Revision Save IDs). Sequence: optional `<w:rsidRoot>` carrying the
/// document's root revision-save id (CT_LongHexNumber per §17.18.50)
/// followed by zero-or-more `<w:rsid>` revision-save id entries.
pub(all) struct CT_DocRsids {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.50 `<w:rsidRoot>` (CT_LongHexNumber) — optional root rsid.
  rsid_root : CT_LongHexNumber?
  /// §17.18.50 `<w:rsid>` (CT_LongHexNumber)* — additional rsid entries.
  rsid : Array[CT_LongHexNumber]
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocRsids — Part 1 §17.15.1.72.
pub fn CT_DocRsids::new(
  element : @xml.Element,
) -> CT_DocRsids raise SchemaViolation {
  let rsid_root = match wml_ct_chunk6_first_child(element, "rsidRoot") {
    Some(child) => Some(CT_LongHexNumber::new(child))
    None => None
  }
  let rsid : Array[CT_LongHexNumber] = []
  for child in wml_ct_chunk6_children(element, "rsid") {
    rsid.push(CT_LongHexNumber::new(child))
  }
  { element, rsid_root, rsid }
}

///|
/// XSD complex type CT_DocRsids — Part 1 §17.15.1.72.
pub fn CT_DocRsids::parse(
  element : @xml.Element,
) -> CT_DocRsids raise SchemaViolation {
  CT_DocRsids::new(element)
}

///|
pub fn CT_DocRsids::to_element(self : CT_DocRsids) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CharacterSpacing — Part 1 §17.15.1.4
/// (characterSpacingControl). Required `@val` ST_CharacterSpacing
/// (Part 1 §17.18.5) selects the kana/punctuation compression rule.
pub(all) struct CT_CharacterSpacing {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.5 @val (ST_CharacterSpacing) — required compression rule.
  val : ST_CharacterSpacing
} derive(Eq, Debug)

///|
/// XSD complex type CT_CharacterSpacing — Part 1 §17.15.1.4.
pub fn CT_CharacterSpacing::new(
  element : @xml.Element,
) -> CT_CharacterSpacing raise SchemaViolation {
  let raw = wml_ct_chunk6_required_attr(
    element, "val", "CT_CharacterSpacing", "Part 1 §17.18.5 ST_CharacterSpacing",
  )
  let val = ST_CharacterSpacing::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_CharacterSpacing — Part 1 §17.15.1.4.
pub fn CT_CharacterSpacing::parse(
  element : @xml.Element,
) -> CT_CharacterSpacing raise SchemaViolation {
  CT_CharacterSpacing::new(element)
}

///|
pub fn CT_CharacterSpacing::to_element(
  self : CT_CharacterSpacing,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SaveThroughXslt — Part 1 §17.15.1.76
/// (saveThroughXslt Save through XSLT). Two optional attributes:
/// `@r:id` (ST_RelationshipId per §A.6.7) references the XSLT
/// relationship, `@solutionID` (s:ST_String) carries the solution
/// identifier. The `r:id` attribute lives in the relationships
/// namespace; lookup matches the spec-required URI.
pub(all) struct CT_SaveThroughXslt {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §A.6.7 @r:id (ST_RelationshipId) — optional XSLT relationship id.
  r_id : String?
  /// §22.9.2.13 @solutionID (s:ST_String) — optional solution identifier.
  solution_id : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SaveThroughXslt — Part 1 §17.15.1.76.
pub fn CT_SaveThroughXslt::new(element : @xml.Element) -> CT_SaveThroughXslt {
  // Look up @r:id by the relationships namespace; fall back to a local
  // lookup so producers emitting only the local name still round-trip.
  let mut r_id : String? = None
  for attribute in element.attributes {
    if r_id is None && attribute.name.local_name == "id" {
      match attribute.name.ns {
        Some(uri) =>
          if uri ==
            "http://schemas.openxmlformats.org/officeDocument/2006/relationships" {
            r_id = Some(attribute.value)
          }
        None => r_id = Some(attribute.value)
      }
    }
  }
  let solution_id = wml_ct_chunk6_attr(element, "solutionID")
  { element, r_id, solution_id }
}

///|
/// XSD complex type CT_SaveThroughXslt — Part 1 §17.15.1.76.
pub fn CT_SaveThroughXslt::parse(element : @xml.Element) -> CT_SaveThroughXslt {
  CT_SaveThroughXslt::new(element)
}

///|
pub fn CT_SaveThroughXslt::to_element(
  self : CT_SaveThroughXslt,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorSchemeMapping — Part 1 §17.15.1.16
/// (clrSchemeMapping Theme-to-Document Color Mappings). Twelve optional
/// ST_WmlColorSchemeIndex attributes (Part 1 §17.18.103) mapping each
/// theme slot to a document color: `@bg1 / @t1 / @bg2 / @t2`,
/// `@accent1..@accent6`, `@hyperlink`, `@followedHyperlink`.
pub(all) struct CT_ColorSchemeMapping {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.103 @bg1 (ST_WmlColorSchemeIndex) — optional background-1 mapping.
  bg1 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @t1 (ST_WmlColorSchemeIndex) — optional text-1 mapping.
  t1 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @bg2 (ST_WmlColorSchemeIndex) — optional background-2 mapping.
  bg2 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @t2 (ST_WmlColorSchemeIndex) — optional text-2 mapping.
  t2 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @accent1 (ST_WmlColorSchemeIndex) — optional accent-1 mapping.
  accent1 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @accent2 (ST_WmlColorSchemeIndex) — optional accent-2 mapping.
  accent2 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @accent3 (ST_WmlColorSchemeIndex) — optional accent-3 mapping.
  accent3 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @accent4 (ST_WmlColorSchemeIndex) — optional accent-4 mapping.
  accent4 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @accent5 (ST_WmlColorSchemeIndex) — optional accent-5 mapping.
  accent5 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @accent6 (ST_WmlColorSchemeIndex) — optional accent-6 mapping.
  accent6 : ST_WmlColorSchemeIndex?
  /// §17.18.103 @hyperlink (ST_WmlColorSchemeIndex) — optional hyperlink mapping.
  hyperlink : ST_WmlColorSchemeIndex?
  /// §17.18.103 @followedHyperlink (ST_WmlColorSchemeIndex) — optional followed-link mapping.
  followed_hyperlink : ST_WmlColorSchemeIndex?
} derive(Eq, Debug)

///|
/// XSD complex type CT_ColorSchemeMapping — Part 1 §17.15.1.16.
pub fn CT_ColorSchemeMapping::new(
  element : @xml.Element,
) -> CT_ColorSchemeMapping raise SchemaViolation {
  let bg1 = match wml_ct_chunk6_attr(element, "bg1") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let t1 = match wml_ct_chunk6_attr(element, "t1") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let bg2 = match wml_ct_chunk6_attr(element, "bg2") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let t2 = match wml_ct_chunk6_attr(element, "t2") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let accent1 = match wml_ct_chunk6_attr(element, "accent1") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let accent2 = match wml_ct_chunk6_attr(element, "accent2") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let accent3 = match wml_ct_chunk6_attr(element, "accent3") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let accent4 = match wml_ct_chunk6_attr(element, "accent4") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let accent5 = match wml_ct_chunk6_attr(element, "accent5") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let accent6 = match wml_ct_chunk6_attr(element, "accent6") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let hyperlink = match wml_ct_chunk6_attr(element, "hyperlink") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  let followed_hyperlink = match
    wml_ct_chunk6_attr(element, "followedHyperlink") {
    Some(text) => Some(ST_WmlColorSchemeIndex::parse(text))
    None => None
  }
  {
    element,
    bg1,
    t1,
    bg2,
    t2,
    accent1,
    accent2,
    accent3,
    accent4,
    accent5,
    accent6,
    hyperlink,
    followed_hyperlink,
  }
}

///|
/// XSD complex type CT_ColorSchemeMapping — Part 1 §17.15.1.16.
pub fn CT_ColorSchemeMapping::parse(
  element : @xml.Element,
) -> CT_ColorSchemeMapping raise SchemaViolation {
  CT_ColorSchemeMapping::new(element)
}

///|
pub fn CT_ColorSchemeMapping::to_element(
  self : CT_ColorSchemeMapping,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ReadingModeInkLockDown — Part 1 §17.15.1.66
/// (readModeInkLockDown). Four required attributes describing the
/// frozen reading-mode-ink layout: `@actualPg` (s:ST_OnOff §22.9.2.7)
/// records whether the current page geometry is in use, `@w` and `@h`
/// (ST_PixelsMeasure §17.18.67) carry the pinned viewport size in
/// pixels and `@fontSz` (ST_DecimalNumberOrPercent §17.18.11) carries
/// the pinned font size.
pub(all) struct CT_ReadingModeInkLockDown {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @actualPg (s:ST_OnOff) — required actual-page flag.
  actual_pg : Bool
  /// §17.18.67 @w (ST_PixelsMeasure) — required viewport width in pixels.
  w : ST_PixelsMeasure
  /// §17.18.67 @h (ST_PixelsMeasure) — required viewport height in pixels.
  h : ST_PixelsMeasure
  /// §17.18.11 @fontSz (ST_DecimalNumberOrPercent) — required pinned font size.
  font_sz : ST_DecimalNumberOrPercent
} derive(Eq, Debug)

///|
/// XSD complex type CT_ReadingModeInkLockDown — Part 1 §17.15.1.66.
pub fn CT_ReadingModeInkLockDown::new(
  element : @xml.Element,
) -> CT_ReadingModeInkLockDown raise SchemaViolation {
  let raw_actual_pg = wml_ct_chunk6_required_attr(
    element, "actualPg", "CT_ReadingModeInkLockDown", "Part 1 §22.9.2.7 s:ST_OnOff",
  )
  let actual_pg = wml_st_on_off(raw_actual_pg)
  let raw_w = wml_ct_chunk6_required_attr(
    element, "w", "CT_ReadingModeInkLockDown", "Part 1 §17.18.67 ST_PixelsMeasure",
  )
  let w = ST_PixelsMeasure::parse(raw_w)
  let raw_h = wml_ct_chunk6_required_attr(
    element, "h", "CT_ReadingModeInkLockDown", "Part 1 §17.18.67 ST_PixelsMeasure",
  )
  let h = ST_PixelsMeasure::parse(raw_h)
  let raw_font_sz = wml_ct_chunk6_required_attr(
    element, "fontSz", "CT_ReadingModeInkLockDown", "Part 1 §17.18.11 ST_DecimalNumberOrPercent",
  )
  let font_sz = ST_DecimalNumberOrPercent::parse(raw_font_sz)
  { element, actual_pg, w, h, font_sz }
}

///|
/// XSD complex type CT_ReadingModeInkLockDown — Part 1 §17.15.1.66.
pub fn CT_ReadingModeInkLockDown::parse(
  element : @xml.Element,
) -> CT_ReadingModeInkLockDown raise SchemaViolation {
  CT_ReadingModeInkLockDown::new(element)
}

///|
pub fn CT_ReadingModeInkLockDown::to_element(
  self : CT_ReadingModeInkLockDown,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WriteProtection — Part 1 §17.15.1.93 (writeProtection
/// Document Write Protection). Optional `@recommended` (s:ST_OnOff per
/// §22.9.2.7) toggle plus AG_Password attribute group (§17.18 Password
/// hash: optional `@algorithmName`, `@hashValue`, `@saltValue`,
/// `@spinCount`). The AG_Password attributes are kept on the preserved
/// element so writers round-trip them verbatim per spec wording.
pub(all) struct CT_WriteProtection {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @recommended (s:ST_OnOff) — optional recommended-read-only flag.
  recommended : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_WriteProtection — Part 1 §17.15.1.93.
pub fn CT_WriteProtection::new(element : @xml.Element) -> CT_WriteProtection {
  let recommended = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "recommended"),
  )
  { element, recommended }
}

///|
/// XSD complex type CT_WriteProtection — Part 1 §17.15.1.93.
pub fn CT_WriteProtection::parse(element : @xml.Element) -> CT_WriteProtection {
  CT_WriteProtection::new(element)
}

///|
pub fn CT_WriteProtection::to_element(
  self : CT_WriteProtection,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Settings — Part 1 §17.15.1.78 (settings Document
/// Settings). xsd:sequence of ~80 optional child elements covering the
/// entire document-wide settings surface (view, zoom, hyphenation,
/// proofing, mail-merge, revision tracking, document protection, fonts,
/// compatibility, mail/document-wide rsid, etc.). Each child slot is
/// modelled as an `Option`/`Array` typed field where the schema permits
/// it. Mathematical-defaults (`<m:mathPr>`), the SmartTag and Schema
/// libraries plus the `<w:forceUpgrade>` (CT_Empty) live in the foreign
/// `<m:..>` / `<sl:..>` namespaces — those raw foreign elements are
/// preserved via `Array[@xml.Element]` so upstream readers can decode
/// them without re-walking the source.
pub(all) struct CT_Settings {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.15.1.93 `<w:writeProtection>` (CT_WriteProtection).
  write_protection : CT_WriteProtection?
  /// §17.15.1.92 `<w:view>` (CT_View).
  view : CT_View?
  /// §17.15.1.94 `<w:zoom>` (CT_Zoom).
  zoom : CT_Zoom?
  /// §17.15.1.68 `<w:removePersonalInformation>` (CT_OnOff).
  remove_personal_information : CT_OnOff?
  /// §17.15.1.67 `<w:removeDateAndTime>` (CT_OnOff).
  remove_date_and_time : CT_OnOff?
  /// §17.15.1.28 `<w:doNotDisplayPageBoundaries>` (CT_OnOff).
  do_not_display_page_boundaries : CT_OnOff?
  /// §17.15.1.21 `<w:displayBackgroundShape>` (CT_OnOff).
  display_background_shape : CT_OnOff?
  /// §17.15.1.62 `<w:printPostScriptOverText>` (CT_OnOff).
  print_post_script_over_text : CT_OnOff?
  /// §17.15.1.60 `<w:printFractionalCharacterWidth>` (CT_OnOff).
  print_fractional_character_width : CT_OnOff?
  /// §17.15.1.61 `<w:printFormsData>` (CT_OnOff).
  print_forms_data : CT_OnOff?
  /// §17.15.1.43 `<w:embedTrueTypeFonts>` (CT_OnOff).
  embed_true_type_fonts : CT_OnOff?
  /// §17.15.1.42 `<w:embedSystemFonts>` (CT_OnOff).
  embed_system_fonts : CT_OnOff?
  /// §17.15.1.75 `<w:saveSubsetFonts>` (CT_OnOff).
  save_subset_fonts : CT_OnOff?
  /// §17.15.1.73 `<w:saveFormsData>` (CT_OnOff).
  save_forms_data : CT_OnOff?
  /// §17.15.1.55 `<w:mirrorMargins>` (CT_OnOff).
  mirror_margins : CT_OnOff?
  /// §17.15.1.2 `<w:alignBordersAndEdges>` (CT_OnOff).
  align_borders_and_edges : CT_OnOff?
  /// §17.15.1.5 `<w:bordersDoNotSurroundHeader>` (CT_OnOff).
  borders_do_not_surround_header : CT_OnOff?
  /// §17.15.1.6 `<w:bordersDoNotSurroundFooter>` (CT_OnOff).
  borders_do_not_surround_footer : CT_OnOff?
  /// §17.15.1.46 `<w:gutterAtTop>` (CT_OnOff).
  gutter_at_top : CT_OnOff?
  /// §17.15.1.48 `<w:hideSpellingErrors>` (CT_OnOff).
  hide_spelling_errors : CT_OnOff?
  /// §17.15.1.47 `<w:hideGrammaticalErrors>` (CT_OnOff).
  hide_grammatical_errors : CT_OnOff?
  /// §17.15.1.3 `<w:activeWritingStyle>` (CT_WritingStyle)*.
  active_writing_style : Array[CT_WritingStyle]
  /// §17.15.1.65 `<w:proofState>` (CT_Proof).
  proof_state : CT_Proof?
  /// §17.15.1.45 `<w:formsDesign>` (CT_OnOff).
  forms_design : CT_OnOff?
  /// §A.1 `<w:attachedTemplate>` (CT_Rel).
  attached_template : CT_Rel?
  /// §17.15.1.50 `<w:linkStyles>` (CT_OnOff).
  link_styles : CT_OnOff?
  /// §17.15.1.85 `<w:stylePaneFormatFilter>` (CT_StylePaneFilter).
  style_pane_format_filter : CT_StylePaneFilter?
  /// §17.15.1.86 `<w:stylePaneSortMethod>` (CT_StyleSort).
  style_pane_sort_method : CT_StyleSort?
  /// §17.15.1.32 `<w:documentType>` (CT_DocType).
  document_type : CT_DocType?
  /// §17.14.20 `<w:mailMerge>` (CT_MailMerge).
  mail_merge : CT_MailMerge?
  /// §17.15.1.69 `<w:revisionView>` (CT_TrackChangesView).
  revision_view : CT_TrackChangesView?
  /// §17.15.1.89 `<w:trackRevisions>` (CT_OnOff).
  track_revisions : CT_OnOff?
  /// §17.15.1.30 `<w:doNotTrackMoves>` (CT_OnOff).
  do_not_track_moves : CT_OnOff?
  /// §17.15.1.29 `<w:doNotTrackFormatting>` (CT_OnOff).
  do_not_track_formatting : CT_OnOff?
  /// §17.15.1.29 `<w:documentProtection>` (CT_DocProtect).
  document_protection : CT_DocProtect?
  /// §17.15.1.10 `<w:autoFormatOverride>` (CT_OnOff).
  auto_format_override : CT_OnOff?
  /// §17.15.1.83 `<w:styleLockTheme>` (CT_OnOff).
  style_lock_theme : CT_OnOff?
  /// §17.15.1.82 `<w:styleLockQFSet>` (CT_OnOff).
  style_lock_qf_set : CT_OnOff?
  /// §17.15.1.20 `<w:defaultTabStop>` (CT_TwipsMeasure).
  default_tab_stop : CT_TwipsMeasure?
  /// §17.15.1.11 `<w:autoHyphenation>` (CT_OnOff).
  auto_hyphenation : CT_OnOff?
  /// §17.15.1.18 `<w:consecutiveHyphenLimit>` (CT_DecimalNumber).
  consecutive_hyphen_limit : CT_DecimalNumber?
  /// §17.15.1.49 `<w:hyphenationZone>` (CT_TwipsMeasure).
  hyphenation_zone : CT_TwipsMeasure?
  /// §17.15.1.34 `<w:doNotHyphenateCaps>` (CT_OnOff).
  do_not_hyphenate_caps : CT_OnOff?
  /// §17.15.1.80 `<w:showEnvelope>` (CT_OnOff).
  show_envelope : CT_OnOff?
  /// §17.15.1.87 `<w:summaryLength>` (CT_DecimalNumberOrPrecent).
  summary_length : CT_DecimalNumberOrPrecent?
  /// §17.15.1.14 `<w:clickAndTypeStyle>` (CT_String).
  click_and_type_style : CT_String?
  /// §17.15.1.19 `<w:defaultTableStyle>` (CT_String).
  default_table_style : CT_String?
  /// §17.15.1.44 `<w:evenAndOddHeaders>` (CT_OnOff).
  even_and_odd_headers : CT_OnOff?
  /// §17.15.1.13 `<w:bookFoldRevPrinting>` (CT_OnOff).
  book_fold_rev_printing : CT_OnOff?
  /// §17.15.1.12 `<w:bookFoldPrinting>` (CT_OnOff).
  book_fold_printing : CT_OnOff?
  /// §17.15.1.12 `<w:bookFoldPrintingSheets>` (CT_DecimalNumber).
  book_fold_printing_sheets : CT_DecimalNumber?
  /// §17.15.1.40 `<w:drawingGridHorizontalSpacing>` (CT_TwipsMeasure).
  drawing_grid_horizontal_spacing : CT_TwipsMeasure?
  /// §17.15.1.41 `<w:drawingGridVerticalSpacing>` (CT_TwipsMeasure).
  drawing_grid_vertical_spacing : CT_TwipsMeasure?
  /// §17.15.1.23 `<w:displayHorizontalDrawingGridEvery>` (CT_DecimalNumber).
  display_horizontal_drawing_grid_every : CT_DecimalNumber?
  /// §17.15.1.24 `<w:displayVerticalDrawingGridEvery>` (CT_DecimalNumber).
  display_vertical_drawing_grid_every : CT_DecimalNumber?
  /// §17.15.1.33 `<w:doNotUseMarginsForDrawingGridOrigin>` (CT_OnOff).
  do_not_use_margins_for_drawing_grid_origin : CT_OnOff?
  /// §17.15.1.38 `<w:drawingGridHorizontalOrigin>` (CT_TwipsMeasure).
  drawing_grid_horizontal_origin : CT_TwipsMeasure?
  /// §17.15.1.39 `<w:drawingGridVerticalOrigin>` (CT_TwipsMeasure).
  drawing_grid_vertical_origin : CT_TwipsMeasure?
  /// §17.15.1.31 `<w:doNotShadeFormData>` (CT_OnOff).
  do_not_shade_form_data : CT_OnOff?
  /// §17.15.1.57 `<w:noPunctuationKerning>` (CT_OnOff).
  no_punctuation_kerning : CT_OnOff?
  /// §17.15.1.4 `<w:characterSpacingControl>` (CT_CharacterSpacing).
  character_spacing_control : CT_CharacterSpacing?
  /// §17.15.1.63 `<w:printTwoOnOne>` (CT_OnOff).
  print_two_on_one : CT_OnOff?
  /// §17.15.1.79 `<w:strictFirstAndLastChars>` (CT_OnOff).
  strict_first_and_last_chars : CT_OnOff?
  /// §17.15.1.59 `<w:noLineBreaksAfter>` (CT_Kinsoku).
  no_line_breaks_after : CT_Kinsoku?
  /// §17.15.1.58 `<w:noLineBreaksBefore>` (CT_Kinsoku).
  no_line_breaks_before : CT_Kinsoku?
  /// §17.15.1.74 `<w:savePreviewPicture>` (CT_OnOff).
  save_preview_picture : CT_OnOff?
  /// §17.15.1.27 `<w:doNotValidateAgainstSchema>` (CT_OnOff).
  do_not_validate_against_schema : CT_OnOff?
  /// §17.15.1.71 `<w:saveInvalidXml>` (CT_OnOff).
  save_invalid_xml : CT_OnOff?
  /// §17.15.1.51 `<w:ignoreMixedContent>` (CT_OnOff).
  ignore_mixed_content : CT_OnOff?
  /// §17.15.1.1 `<w:alwaysShowPlaceholderText>` (CT_OnOff).
  always_show_placeholder_text : CT_OnOff?
  /// §17.15.1.26 `<w:doNotDemarcateInvalidXml>` (CT_OnOff).
  do_not_demarcate_invalid_xml : CT_OnOff?
  /// §17.15.1.77 `<w:saveXmlDataOnly>` (CT_OnOff).
  save_xml_data_only : CT_OnOff?
  /// §17.15.1.91 `<w:useXSLTWhenSaving>` (CT_OnOff).
  use_xslt_when_saving : CT_OnOff?
  /// §17.15.1.76 `<w:saveThroughXslt>` (CT_SaveThroughXslt).
  save_through_xslt : CT_SaveThroughXslt?
  /// §17.15.1.81 `<w:showXMLTags>` (CT_OnOff).
  show_xml_tags : CT_OnOff?
  /// §17.15.1.0 `<w:alwaysMergeEmptyNamespace>` (CT_OnOff).
  always_merge_empty_namespace : CT_OnOff?
  /// §17.15.1.90 `<w:updateFields>` (CT_OnOff).
  update_fields : CT_OnOff?
  /// §17.11.13 `<w:footnotePr>` (CT_FtnDocProps).
  footnote_pr : CT_FtnDocProps?
  /// §17.11.4 `<w:endnotePr>` (CT_EdnDocProps).
  endnote_pr : CT_EdnDocProps?
  /// §17.15.1.7 `<w:compat>` (CT_Compat).
  compat : CT_Compat?
  /// §17.15.1.37 `<w:docVars>` (CT_DocVars).
  doc_vars : CT_DocVars?
  /// §17.15.1.72 `<w:rsids>` (CT_DocRsids).
  rsids : CT_DocRsids?
  /// `<m:mathPr>` — Office Math defaults (Part 1 §22.1 CT_MathPr).
  math_pr : Array[@m.CT_MathPr]
  /// §17.15.1.0 `<w:attachedSchema>` (CT_String)*.
  attached_schema : Array[CT_String]
  /// §17.15.1.88 `<w:themeFontLang>` (CT_Language).
  theme_font_lang : CT_Language?
  /// §17.15.1.16 `<w:clrSchemeMapping>` (CT_ColorSchemeMapping).
  clr_scheme_mapping : CT_ColorSchemeMapping?
  /// §17.15.1.25 `<w:doNotIncludeSubdocsInStats>` (CT_OnOff).
  do_not_include_subdocs_in_stats : CT_OnOff?
  /// §17.15.1.22 `<w:doNotAutoCompressPictures>` (CT_OnOff).
  do_not_auto_compress_pictures : CT_OnOff?
  /// `<w:forceUpgrade>` (CT_Empty) — optional upgrade-trigger marker.
  force_upgrade : CT_Empty?
  /// §17.11.* `<w:captions>` (CT_Captions).
  captions : CT_Captions?
  /// §17.15.1.66 `<w:readModeInkLockDown>` (CT_ReadingModeInkLockDown).
  read_mode_ink_lock_down : CT_ReadingModeInkLockDown?
  /// `<w:smartTagType>` (CT_SmartTagType)*.
  smart_tag_type : Array[CT_SmartTagType]
  /// `<sl:schemaLibrary>` — Part 1 §23.2.2 CT_SchemaLibrary
  /// (custom XML schema library binding).
  schema_library : Array[@custom_xml.CT_SchemaLibrary]
  /// `<w:doNotEmbedSmartTags>` (CT_OnOff).
  do_not_embed_smart_tags : CT_OnOff?
  /// `<w:decimalSymbol>` (CT_String).
  decimal_symbol : CT_String?
  /// `<w:listSeparator>` (CT_String).
  list_separator : CT_String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Settings — Part 1 §17.15.1.78. Decode each
/// optional / unbounded child described by the wml.xsd sequence,
/// propagating SchemaViolation from the typed child constructors.
pub fn CT_Settings::new(
  element : @xml.Element,
) -> CT_Settings raise SchemaViolation {
  let write_protection = match
    wml_ct_chunk6_first_child(element, "writeProtection") {
    Some(c) => Some(CT_WriteProtection::new(c))
    None => None
  }
  let view = match wml_ct_chunk6_first_child(element, "view") {
    Some(c) => Some(CT_View::new(c))
    None => None
  }
  let zoom = match wml_ct_chunk6_first_child(element, "zoom") {
    Some(c) => Some(CT_Zoom::new(c))
    None => None
  }
  let remove_personal_information = match
    wml_ct_chunk6_first_child(element, "removePersonalInformation") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let remove_date_and_time = match
    wml_ct_chunk6_first_child(element, "removeDateAndTime") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let do_not_display_page_boundaries = match
    wml_ct_chunk6_first_child(element, "doNotDisplayPageBoundaries") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let display_background_shape = match
    wml_ct_chunk6_first_child(element, "displayBackgroundShape") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let print_post_script_over_text = match
    wml_ct_chunk6_first_child(element, "printPostScriptOverText") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let print_fractional_character_width = match
    wml_ct_chunk6_first_child(element, "printFractionalCharacterWidth") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let print_forms_data = match
    wml_ct_chunk6_first_child(element, "printFormsData") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let embed_true_type_fonts = match
    wml_ct_chunk6_first_child(element, "embedTrueTypeFonts") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let embed_system_fonts = match
    wml_ct_chunk6_first_child(element, "embedSystemFonts") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let save_subset_fonts = match
    wml_ct_chunk6_first_child(element, "saveSubsetFonts") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let save_forms_data = match
    wml_ct_chunk6_first_child(element, "saveFormsData") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let mirror_margins = match
    wml_ct_chunk6_first_child(element, "mirrorMargins") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let align_borders_and_edges = match
    wml_ct_chunk6_first_child(element, "alignBordersAndEdges") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let borders_do_not_surround_header = match
    wml_ct_chunk6_first_child(element, "bordersDoNotSurroundHeader") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let borders_do_not_surround_footer = match
    wml_ct_chunk6_first_child(element, "bordersDoNotSurroundFooter") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let gutter_at_top = match wml_ct_chunk6_first_child(element, "gutterAtTop") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let hide_spelling_errors = match
    wml_ct_chunk6_first_child(element, "hideSpellingErrors") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let hide_grammatical_errors = match
    wml_ct_chunk6_first_child(element, "hideGrammaticalErrors") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let active_writing_style : Array[CT_WritingStyle] = []
  for child in wml_ct_chunk6_children(element, "activeWritingStyle") {
    active_writing_style.push(CT_WritingStyle::new(child))
  }
  let proof_state = match wml_ct_chunk6_first_child(element, "proofState") {
    Some(c) => Some(CT_Proof::new(c))
    None => None
  }
  let forms_design = match wml_ct_chunk6_first_child(element, "formsDesign") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let attached_template = match
    wml_ct_chunk6_first_child(element, "attachedTemplate") {
    Some(c) => Some(CT_Rel::new(c))
    None => None
  }
  let link_styles = match wml_ct_chunk6_first_child(element, "linkStyles") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let style_pane_format_filter = match
    wml_ct_chunk6_first_child(element, "stylePaneFormatFilter") {
    Some(c) => Some(CT_StylePaneFilter::new(c))
    None => None
  }
  let style_pane_sort_method = match
    wml_ct_chunk6_first_child(element, "stylePaneSortMethod") {
    Some(c) => Some(CT_StyleSort::new(c))
    None => None
  }
  let document_type = match wml_ct_chunk6_first_child(element, "documentType") {
    Some(c) => Some(CT_DocType::new(c))
    None => None
  }
  let mail_merge = match wml_ct_chunk6_first_child(element, "mailMerge") {
    Some(c) => Some(CT_MailMerge::new(c))
    None => None
  }
  let revision_view = match wml_ct_chunk6_first_child(element, "revisionView") {
    Some(c) => Some(CT_TrackChangesView::new(c))
    None => None
  }
  let track_revisions = match
    wml_ct_chunk6_first_child(element, "trackRevisions") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let do_not_track_moves = match
    wml_ct_chunk6_first_child(element, "doNotTrackMoves") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let do_not_track_formatting = match
    wml_ct_chunk6_first_child(element, "doNotTrackFormatting") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let document_protection = match
    wml_ct_chunk6_first_child(element, "documentProtection") {
    Some(c) => Some(CT_DocProtect::new(c))
    None => None
  }
  let auto_format_override = match
    wml_ct_chunk6_first_child(element, "autoFormatOverride") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let style_lock_theme = match
    wml_ct_chunk6_first_child(element, "styleLockTheme") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let style_lock_qf_set = match
    wml_ct_chunk6_first_child(element, "styleLockQFSet") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let default_tab_stop = match
    wml_ct_chunk6_first_child(element, "defaultTabStop") {
    Some(c) => Some(CT_TwipsMeasure::new(c))
    None => None
  }
  let auto_hyphenation = match
    wml_ct_chunk6_first_child(element, "autoHyphenation") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let consecutive_hyphen_limit = match
    wml_ct_chunk6_first_child(element, "consecutiveHyphenLimit") {
    Some(c) => Some(CT_DecimalNumber::new(c))
    None => None
  }
  let hyphenation_zone = match
    wml_ct_chunk6_first_child(element, "hyphenationZone") {
    Some(c) => Some(CT_TwipsMeasure::new(c))
    None => None
  }
  let do_not_hyphenate_caps = match
    wml_ct_chunk6_first_child(element, "doNotHyphenateCaps") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let show_envelope = match wml_ct_chunk6_first_child(element, "showEnvelope") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let summary_length = match
    wml_ct_chunk6_first_child(element, "summaryLength") {
    Some(c) => Some(CT_DecimalNumberOrPrecent::new(c))
    None => None
  }
  let click_and_type_style = match
    wml_ct_chunk6_first_child(element, "clickAndTypeStyle") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let default_table_style = match
    wml_ct_chunk6_first_child(element, "defaultTableStyle") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let even_and_odd_headers = match
    wml_ct_chunk6_first_child(element, "evenAndOddHeaders") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let book_fold_rev_printing = match
    wml_ct_chunk6_first_child(element, "bookFoldRevPrinting") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let book_fold_printing = match
    wml_ct_chunk6_first_child(element, "bookFoldPrinting") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let book_fold_printing_sheets = match
    wml_ct_chunk6_first_child(element, "bookFoldPrintingSheets") {
    Some(c) => Some(CT_DecimalNumber::new(c))
    None => None
  }
  let drawing_grid_horizontal_spacing = match
    wml_ct_chunk6_first_child(element, "drawingGridHorizontalSpacing") {
    Some(c) => Some(CT_TwipsMeasure::new(c))
    None => None
  }
  let drawing_grid_vertical_spacing = match
    wml_ct_chunk6_first_child(element, "drawingGridVerticalSpacing") {
    Some(c) => Some(CT_TwipsMeasure::new(c))
    None => None
  }
  let display_horizontal_drawing_grid_every = match
    wml_ct_chunk6_first_child(element, "displayHorizontalDrawingGridEvery") {
    Some(c) => Some(CT_DecimalNumber::new(c))
    None => None
  }
  let display_vertical_drawing_grid_every = match
    wml_ct_chunk6_first_child(element, "displayVerticalDrawingGridEvery") {
    Some(c) => Some(CT_DecimalNumber::new(c))
    None => None
  }
  let do_not_use_margins_for_drawing_grid_origin = match
    wml_ct_chunk6_first_child(element, "doNotUseMarginsForDrawingGridOrigin") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let drawing_grid_horizontal_origin = match
    wml_ct_chunk6_first_child(element, "drawingGridHorizontalOrigin") {
    Some(c) => Some(CT_TwipsMeasure::new(c))
    None => None
  }
  let drawing_grid_vertical_origin = match
    wml_ct_chunk6_first_child(element, "drawingGridVerticalOrigin") {
    Some(c) => Some(CT_TwipsMeasure::new(c))
    None => None
  }
  let do_not_shade_form_data = match
    wml_ct_chunk6_first_child(element, "doNotShadeFormData") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let no_punctuation_kerning = match
    wml_ct_chunk6_first_child(element, "noPunctuationKerning") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let character_spacing_control = match
    wml_ct_chunk6_first_child(element, "characterSpacingControl") {
    Some(c) => Some(CT_CharacterSpacing::new(c))
    None => None
  }
  let print_two_on_one = match
    wml_ct_chunk6_first_child(element, "printTwoOnOne") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let strict_first_and_last_chars = match
    wml_ct_chunk6_first_child(element, "strictFirstAndLastChars") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let no_line_breaks_after = match
    wml_ct_chunk6_first_child(element, "noLineBreaksAfter") {
    Some(c) => Some(CT_Kinsoku::new(c))
    None => None
  }
  let no_line_breaks_before = match
    wml_ct_chunk6_first_child(element, "noLineBreaksBefore") {
    Some(c) => Some(CT_Kinsoku::new(c))
    None => None
  }
  let save_preview_picture = match
    wml_ct_chunk6_first_child(element, "savePreviewPicture") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let do_not_validate_against_schema = match
    wml_ct_chunk6_first_child(element, "doNotValidateAgainstSchema") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let save_invalid_xml = match
    wml_ct_chunk6_first_child(element, "saveInvalidXml") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let ignore_mixed_content = match
    wml_ct_chunk6_first_child(element, "ignoreMixedContent") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let always_show_placeholder_text = match
    wml_ct_chunk6_first_child(element, "alwaysShowPlaceholderText") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let do_not_demarcate_invalid_xml = match
    wml_ct_chunk6_first_child(element, "doNotDemarcateInvalidXml") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let save_xml_data_only = match
    wml_ct_chunk6_first_child(element, "saveXmlDataOnly") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let use_xslt_when_saving = match
    wml_ct_chunk6_first_child(element, "useXSLTWhenSaving") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let save_through_xslt = match
    wml_ct_chunk6_first_child(element, "saveThroughXslt") {
    Some(c) => Some(CT_SaveThroughXslt::new(c))
    None => None
  }
  let show_xml_tags = match wml_ct_chunk6_first_child(element, "showXMLTags") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let always_merge_empty_namespace = match
    wml_ct_chunk6_first_child(element, "alwaysMergeEmptyNamespace") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let update_fields = match wml_ct_chunk6_first_child(element, "updateFields") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let footnote_pr = match wml_ct_chunk6_first_child(element, "footnotePr") {
    Some(c) => Some(CT_FtnDocProps::new(c))
    None => None
  }
  let endnote_pr = match wml_ct_chunk6_first_child(element, "endnotePr") {
    Some(c) => Some(CT_EdnDocProps::new(c))
    None => None
  }
  let compat = match wml_ct_chunk6_first_child(element, "compat") {
    Some(c) => Some(CT_Compat::new(c))
    None => None
  }
  let doc_vars = match wml_ct_chunk6_first_child(element, "docVars") {
    Some(c) => Some(CT_DocVars::new(c))
    None => None
  }
  let rsids = match wml_ct_chunk6_first_child(element, "rsids") {
    Some(c) => Some(CT_DocRsids::new(c))
    None => None
  }
  let math_pr : Array[@m.CT_MathPr] = []
  for child in wml_ct_chunk6_children(element, "mathPr") {
    math_pr.push(wrap_m_violation(() => @m.CT_MathPr::new(child)))
  }
  let attached_schema : Array[CT_String] = []
  for child in wml_ct_chunk6_children(element, "attachedSchema") {
    attached_schema.push(CT_String::new(child))
  }
  let theme_font_lang = match
    wml_ct_chunk6_first_child(element, "themeFontLang") {
    Some(c) => Some(CT_Language::new(c))
    None => None
  }
  let clr_scheme_mapping = match
    wml_ct_chunk6_first_child(element, "clrSchemeMapping") {
    Some(c) => Some(CT_ColorSchemeMapping::new(c))
    None => None
  }
  let do_not_include_subdocs_in_stats = match
    wml_ct_chunk6_first_child(element, "doNotIncludeSubdocsInStats") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let do_not_auto_compress_pictures = match
    wml_ct_chunk6_first_child(element, "doNotAutoCompressPictures") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let force_upgrade = match wml_ct_chunk6_first_child(element, "forceUpgrade") {
    Some(c) => Some(CT_Empty::new(c))
    None => None
  }
  let captions = match wml_ct_chunk6_first_child(element, "captions") {
    Some(c) => Some(CT_Captions::new(c))
    None => None
  }
  let read_mode_ink_lock_down = match
    wml_ct_chunk6_first_child(element, "readModeInkLockDown") {
    Some(c) => Some(CT_ReadingModeInkLockDown::new(c))
    None => None
  }
  let smart_tag_type : Array[CT_SmartTagType] = []
  for child in wml_ct_chunk6_children(element, "smartTagType") {
    smart_tag_type.push(CT_SmartTagType::new(child))
  }
  let schema_library : Array[@custom_xml.CT_SchemaLibrary] = []
  for child in wml_ct_chunk6_children(element, "schemaLibrary") {
    schema_library.push(@custom_xml.CT_SchemaLibrary::new(child))
  }
  let do_not_embed_smart_tags = match
    wml_ct_chunk6_first_child(element, "doNotEmbedSmartTags") {
    Some(c) => Some(CT_OnOff::parse(c))
    None => None
  }
  let decimal_symbol = match
    wml_ct_chunk6_first_child(element, "decimalSymbol") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let list_separator = match
    wml_ct_chunk6_first_child(element, "listSeparator") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  {
    element,
    write_protection,
    view,
    zoom,
    remove_personal_information,
    remove_date_and_time,
    do_not_display_page_boundaries,
    display_background_shape,
    print_post_script_over_text,
    print_fractional_character_width,
    print_forms_data,
    embed_true_type_fonts,
    embed_system_fonts,
    save_subset_fonts,
    save_forms_data,
    mirror_margins,
    align_borders_and_edges,
    borders_do_not_surround_header,
    borders_do_not_surround_footer,
    gutter_at_top,
    hide_spelling_errors,
    hide_grammatical_errors,
    active_writing_style,
    proof_state,
    forms_design,
    attached_template,
    link_styles,
    style_pane_format_filter,
    style_pane_sort_method,
    document_type,
    mail_merge,
    revision_view,
    track_revisions,
    do_not_track_moves,
    do_not_track_formatting,
    document_protection,
    auto_format_override,
    style_lock_theme,
    style_lock_qf_set,
    default_tab_stop,
    auto_hyphenation,
    consecutive_hyphen_limit,
    hyphenation_zone,
    do_not_hyphenate_caps,
    show_envelope,
    summary_length,
    click_and_type_style,
    default_table_style,
    even_and_odd_headers,
    book_fold_rev_printing,
    book_fold_printing,
    book_fold_printing_sheets,
    drawing_grid_horizontal_spacing,
    drawing_grid_vertical_spacing,
    display_horizontal_drawing_grid_every,
    display_vertical_drawing_grid_every,
    do_not_use_margins_for_drawing_grid_origin,
    drawing_grid_horizontal_origin,
    drawing_grid_vertical_origin,
    do_not_shade_form_data,
    no_punctuation_kerning,
    character_spacing_control,
    print_two_on_one,
    strict_first_and_last_chars,
    no_line_breaks_after,
    no_line_breaks_before,
    save_preview_picture,
    do_not_validate_against_schema,
    save_invalid_xml,
    ignore_mixed_content,
    always_show_placeholder_text,
    do_not_demarcate_invalid_xml,
    save_xml_data_only,
    use_xslt_when_saving,
    save_through_xslt,
    show_xml_tags,
    always_merge_empty_namespace,
    update_fields,
    footnote_pr,
    endnote_pr,
    compat,
    doc_vars,
    rsids,
    math_pr,
    attached_schema,
    theme_font_lang,
    clr_scheme_mapping,
    do_not_include_subdocs_in_stats,
    do_not_auto_compress_pictures,
    force_upgrade,
    captions,
    read_mode_ink_lock_down,
    smart_tag_type,
    schema_library,
    do_not_embed_smart_tags,
    decimal_symbol,
    list_separator,
  }
}

///|
/// XSD complex type CT_Settings — Part 1 §17.15.1.78.
pub fn CT_Settings::parse(
  element : @xml.Element,
) -> CT_Settings raise SchemaViolation {
  CT_Settings::new(element)
}

///|
pub fn CT_Settings::to_element(self : CT_Settings) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WebSettings — Part 1 §11.5 / Part 1 §17.15.2
/// (webSettings Web Settings). Sequence of twelve optional children
/// governing the document's HTML-export behaviour.
pub(all) struct CT_WebSettings {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §11.5 `<w:frameset>` (CT_Frameset) — optional frameset definition.
  frameset : CT_Frameset?
  /// §17.15.2.7 `<w:divs>` (CT_Divs) — optional `<div>` definitions.
  divs : CT_Divs?
  /// §17.15.2.8 `<w:encoding>` (CT_String) — optional output encoding.
  encoding : CT_String?
  /// §17.15.2.13 `<w:optimizeForBrowser>` (CT_OptimizeForBrowser).
  optimize_for_browser : CT_OptimizeForBrowser?
  /// §17.15.2.2 `<w:allowPNG>` (CT_OnOff).
  allow_png : CT_OnOff?
  /// §17.15.2.5 `<w:doNotRelyOnCSS>` (CT_OnOff).
  do_not_rely_on_css : CT_OnOff?
  /// §17.15.2.6 `<w:doNotSaveAsSingleFile>` (CT_OnOff).
  do_not_save_as_single_file : CT_OnOff?
  /// §17.15.2.4 `<w:doNotOrganizeInFolder>` (CT_OnOff).
  do_not_organize_in_folder : CT_OnOff?
  /// §17.15.2.3 `<w:doNotUseLongFileNames>` (CT_OnOff).
  do_not_use_long_file_names : CT_OnOff?
  /// §17.15.2.14 `<w:pixelsPerInch>` (CT_DecimalNumber).
  pixels_per_inch : CT_DecimalNumber?
  /// §17.15.2.15 `<w:targetScreenSz>` (CT_TargetScreenSz).
  target_screen_sz : CT_TargetScreenSz?
  /// §17.15.2.16 `<w:saveSmartTagsAsXml>` (CT_OnOff).
  save_smart_tags_as_xml : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_WebSettings — Part 1 §11.5.
pub fn CT_WebSettings::new(
  element : @xml.Element,
) -> CT_WebSettings raise SchemaViolation {
  let frameset = match wml_ct_chunk6_first_child(element, "frameset") {
    Some(c) => Some(CT_Frameset::new(c))
    None => None
  }
  let divs = match wml_ct_chunk6_first_child(element, "divs") {
    Some(c) => Some(CT_Divs::new(c))
    None => None
  }
  let encoding = match wml_ct_chunk6_first_child(element, "encoding") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let optimize_for_browser = match
    wml_ct_chunk6_first_child(element, "optimizeForBrowser") {
    Some(c) => Some(CT_OptimizeForBrowser::new(c))
    None => None
  }
  let allow_png = match wml_ct_chunk6_first_child(element, "allowPNG") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let do_not_rely_on_css = match
    wml_ct_chunk6_first_child(element, "doNotRelyOnCSS") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let do_not_save_as_single_file = match
    wml_ct_chunk6_first_child(element, "doNotSaveAsSingleFile") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let do_not_organize_in_folder = match
    wml_ct_chunk6_first_child(element, "doNotOrganizeInFolder") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let do_not_use_long_file_names = match
    wml_ct_chunk6_first_child(element, "doNotUseLongFileNames") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let pixels_per_inch = match
    wml_ct_chunk6_first_child(element, "pixelsPerInch") {
    Some(c) => Some(CT_DecimalNumber::new(c))
    None => None
  }
  let target_screen_sz = match
    wml_ct_chunk6_first_child(element, "targetScreenSz") {
    Some(c) => Some(CT_TargetScreenSz::new(c))
    None => None
  }
  let save_smart_tags_as_xml = match
    wml_ct_chunk6_first_child(element, "saveSmartTagsAsXml") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  {
    element,
    frameset,
    divs,
    encoding,
    optimize_for_browser,
    allow_png,
    do_not_rely_on_css,
    do_not_save_as_single_file,
    do_not_organize_in_folder,
    do_not_use_long_file_names,
    pixels_per_inch,
    target_screen_sz,
    save_smart_tags_as_xml,
  }
}

///|
/// XSD complex type CT_WebSettings — Part 1 §11.5.
pub fn CT_WebSettings::parse(
  element : @xml.Element,
) -> CT_WebSettings raise SchemaViolation {
  CT_WebSettings::new(element)
}

///|
pub fn CT_WebSettings::to_element(self : CT_WebSettings) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FrameScrollbar — Part 1 §17.15.2.42 (scrollbar
/// Frame Scrollbar Visibility). Required `@val` ST_FrameScrollbar
/// (Part 1 §17.18.41) selects on/off/auto behaviour.
pub(all) struct CT_FrameScrollbar {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.41 @val (ST_FrameScrollbar) — required visibility kind.
  val : ST_FrameScrollbar
} derive(Eq, Debug)

///|
/// XSD complex type CT_FrameScrollbar — Part 1 §17.15.2.42.
pub fn CT_FrameScrollbar::new(
  element : @xml.Element,
) -> CT_FrameScrollbar raise SchemaViolation {
  let raw = wml_ct_chunk6_required_attr(
    element, "val", "CT_FrameScrollbar", "Part 1 §17.18.41 ST_FrameScrollbar",
  )
  let val = ST_FrameScrollbar::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_FrameScrollbar — Part 1 §17.15.2.42.
pub fn CT_FrameScrollbar::parse(
  element : @xml.Element,
) -> CT_FrameScrollbar raise SchemaViolation {
  CT_FrameScrollbar::new(element)
}

///|
pub fn CT_FrameScrollbar::to_element(self : CT_FrameScrollbar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OptimizeForBrowser — Part 1 §17.15.2.13
/// (optimizeForBrowser). Extends CT_OnOff (§17.17.4) with an optional
/// `@target` s:ST_String attribute naming a specific browser flavour.
/// The inherited `@val` ST_OnOff toggle is captured via `CT_OnOff::new`
/// so the on/off truth value remains typed.
pub(all) struct CT_OptimizeForBrowser {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.17.4 inherited on/off projection.
  base : CT_OnOff
  /// §22.9.2.13 @target (s:ST_String) — optional browser-target hint.
  target : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_OptimizeForBrowser — Part 1 §17.15.2.13.
pub fn CT_OptimizeForBrowser::new(
  element : @xml.Element,
) -> CT_OptimizeForBrowser {
  let base = CT_OnOff::new(element)
  let target = wml_ct_chunk6_attr(element, "target")
  { element, base, target }
}

///|
/// XSD complex type CT_OptimizeForBrowser — Part 1 §17.15.2.13.
pub fn CT_OptimizeForBrowser::parse(
  element : @xml.Element,
) -> CT_OptimizeForBrowser {
  CT_OptimizeForBrowser::new(element)
}

///|
pub fn CT_OptimizeForBrowser::to_element(
  self : CT_OptimizeForBrowser,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Frame — Part 1 §17.15.2.16 (frame Single Frame).
/// Sequence of ten optional children describing the frame size, name,
/// title, long description / source relationships, page margins,
/// scrollbar visibility, resizable and link-to-file toggles.
pub(all) struct CT_Frame {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 `<w:sz>` (CT_String) — optional frame size lexical.
  sz : CT_String?
  /// §22.9.2.13 `<w:name>` (CT_String) — optional frame name.
  name : CT_String?
  /// §22.9.2.13 `<w:title>` (CT_String) — optional frame title.
  title : CT_String?
  /// §A.1 `<w:longDesc>` (CT_Rel) — optional long-description relationship.
  long_desc : CT_Rel?
  /// §A.1 `<w:sourceFileName>` (CT_Rel) — optional source-file relationship.
  source_file_name : CT_Rel?
  /// §17.18.67 `<w:marW>` (CT_PixelsMeasure) — optional left/right margin in pixels.
  mar_w : CT_PixelsMeasure?
  /// §17.18.67 `<w:marH>` (CT_PixelsMeasure) — optional top/bottom margin in pixels.
  mar_h : CT_PixelsMeasure?
  /// §17.15.2.42 `<w:scrollbar>` (CT_FrameScrollbar) — optional scrollbar visibility.
  scrollbar : CT_FrameScrollbar?
  /// §17.17.4 `<w:noResizeAllowed>` (CT_OnOff) — optional no-resize flag.
  no_resize_allowed : CT_OnOff?
  /// §17.17.4 `<w:linkedToFile>` (CT_OnOff) — optional linked-to-file flag.
  linked_to_file : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Frame — Part 1 §17.15.2.16.
pub fn CT_Frame::new(element : @xml.Element) -> CT_Frame raise SchemaViolation {
  let sz = match wml_ct_chunk6_first_child(element, "sz") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let name = match wml_ct_chunk6_first_child(element, "name") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let title = match wml_ct_chunk6_first_child(element, "title") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let long_desc = match wml_ct_chunk6_first_child(element, "longDesc") {
    Some(c) => Some(CT_Rel::new(c))
    None => None
  }
  let source_file_name = match
    wml_ct_chunk6_first_child(element, "sourceFileName") {
    Some(c) => Some(CT_Rel::new(c))
    None => None
  }
  let mar_w = match wml_ct_chunk6_first_child(element, "marW") {
    Some(c) => Some(CT_PixelsMeasure::new(c))
    None => None
  }
  let mar_h = match wml_ct_chunk6_first_child(element, "marH") {
    Some(c) => Some(CT_PixelsMeasure::new(c))
    None => None
  }
  let scrollbar = match wml_ct_chunk6_first_child(element, "scrollbar") {
    Some(c) => Some(CT_FrameScrollbar::new(c))
    None => None
  }
  let no_resize_allowed = match
    wml_ct_chunk6_first_child(element, "noResizeAllowed") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let linked_to_file = match
    wml_ct_chunk6_first_child(element, "linkedToFile") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  {
    element,
    sz,
    name,
    title,
    long_desc,
    source_file_name,
    mar_w,
    mar_h,
    scrollbar,
    no_resize_allowed,
    linked_to_file,
  }
}

///|
/// XSD complex type CT_Frame — Part 1 §17.15.2.16.
pub fn CT_Frame::parse(
  element : @xml.Element,
) -> CT_Frame raise SchemaViolation {
  CT_Frame::new(element)
}

///|
pub fn CT_Frame::to_element(self : CT_Frame) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FrameLayout — Part 1 §17.15.2.18 (frameLayout
/// Frame Layout). Required `@val` ST_FrameLayout (Part 1 §17.18.40)
/// selects `rows`, `cols` or `none` for the child frame arrangement.
pub(all) struct CT_FrameLayout {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.40 @val (ST_FrameLayout) — required layout kind.
  val : ST_FrameLayout
} derive(Eq, Debug)

///|
/// XSD complex type CT_FrameLayout — Part 1 §17.15.2.18.
pub fn CT_FrameLayout::new(
  element : @xml.Element,
) -> CT_FrameLayout raise SchemaViolation {
  let raw = wml_ct_chunk6_required_attr(
    element, "val", "CT_FrameLayout", "Part 1 §17.18.40 ST_FrameLayout",
  )
  let val = ST_FrameLayout::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_FrameLayout — Part 1 §17.15.2.18.
pub fn CT_FrameLayout::parse(
  element : @xml.Element,
) -> CT_FrameLayout raise SchemaViolation {
  CT_FrameLayout::new(element)
}

///|
pub fn CT_FrameLayout::to_element(self : CT_FrameLayout) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FramesetSplitbar — Part 1 §17.15.2.22
/// (framesetSplitbar Frameset Splitter). Sequence of four optional
/// children: split-bar width, colour, border-suppression and
/// flat-borders style toggles.
pub(all) struct CT_FramesetSplitbar {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.10 `<w:w>` (CT_TwipsMeasure) — optional split-bar width.
  w : CT_TwipsMeasure?
  /// §17.3.2.6 `<w:color>` (CT_Color) — optional split-bar colour.
  color : CT_Color?
  /// §17.17.4 `<w:noBorder>` (CT_OnOff) — optional no-border flag.
  no_border : CT_OnOff?
  /// §17.17.4 `<w:flatBorders>` (CT_OnOff) — optional flat-borders flag.
  flat_borders : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FramesetSplitbar — Part 1 §17.15.2.22.
pub fn CT_FramesetSplitbar::new(
  element : @xml.Element,
) -> CT_FramesetSplitbar raise SchemaViolation {
  let w = match wml_ct_chunk6_first_child(element, "w") {
    Some(c) => Some(CT_TwipsMeasure::new(c))
    None => None
  }
  let color = match wml_ct_chunk6_first_child(element, "color") {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
  let no_border = match wml_ct_chunk6_first_child(element, "noBorder") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let flat_borders = match wml_ct_chunk6_first_child(element, "flatBorders") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  { element, w, color, no_border, flat_borders }
}

///|
/// XSD complex type CT_FramesetSplitbar — Part 1 §17.15.2.22.
pub fn CT_FramesetSplitbar::parse(
  element : @xml.Element,
) -> CT_FramesetSplitbar raise SchemaViolation {
  CT_FramesetSplitbar::new(element)
}

///|
pub fn CT_FramesetSplitbar::to_element(
  self : CT_FramesetSplitbar,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Frameset — Part 1 §17.15.2.20 (frameset Frameset
/// Container). Sequence of four optional sizing/title children
/// followed by an unbounded xsd:choice of nested `<w:frameset>`
/// (CT_Frameset) and `<w:frame>` (CT_Frame per §17.15.2.16) children.
pub(all) struct CT_Frameset {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 `<w:sz>` (CT_String) — optional frameset size.
  sz : CT_String?
  /// §17.15.2.22 `<w:framesetSplitbar>` (CT_FramesetSplitbar).
  frameset_splitbar : CT_FramesetSplitbar?
  /// §17.15.2.18 `<w:frameLayout>` (CT_FrameLayout) — optional layout selector.
  frame_layout : CT_FrameLayout?
  /// §22.9.2.13 `<w:title>` (CT_String) — optional frameset title.
  title : CT_String?
  /// §17.15.2.20 `<w:frameset>` (CT_Frameset)* — nested framesets.
  framesets : Array[CT_Frameset]
  /// §17.15.2.16 `<w:frame>` (CT_Frame)* — terminal frame entries.
  frames : Array[CT_Frame]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Frameset — Part 1 §17.15.2.20.
pub fn CT_Frameset::new(
  element : @xml.Element,
) -> CT_Frameset raise SchemaViolation {
  let sz = match wml_ct_chunk6_first_child(element, "sz") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let frameset_splitbar = match
    wml_ct_chunk6_first_child(element, "framesetSplitbar") {
    Some(c) => Some(CT_FramesetSplitbar::new(c))
    None => None
  }
  let frame_layout = match wml_ct_chunk6_first_child(element, "frameLayout") {
    Some(c) => Some(CT_FrameLayout::new(c))
    None => None
  }
  let title = match wml_ct_chunk6_first_child(element, "title") {
    Some(c) => Some(CT_String::new(c))
    None => None
  }
  let framesets : Array[CT_Frameset] = []
  for child in wml_ct_chunk6_children(element, "frameset") {
    framesets.push(CT_Frameset::new(child))
  }
  let frames : Array[CT_Frame] = []
  for child in wml_ct_chunk6_children(element, "frame") {
    frames.push(CT_Frame::new(child))
  }
  { element, sz, frameset_splitbar, frame_layout, title, framesets, frames }
}

///|
/// XSD complex type CT_Frameset — Part 1 §17.15.2.20.
pub fn CT_Frameset::parse(
  element : @xml.Element,
) -> CT_Frameset raise SchemaViolation {
  CT_Frameset::new(element)
}

///|
pub fn CT_Frameset::to_element(self : CT_Frameset) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DivBdr — Part 1 §17.15.2.8 (divBdr `<div>`
/// Border Specifications). Sequence of four optional CT_Border (per
/// §17.3.4.3) borders bounding the HTML `<div>`: top, left, bottom,
/// right.
pub(all) struct CT_DivBdr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.3.4.3 `<w:top>` (CT_Border) — optional top border.
  top : CT_Border?
  /// §17.3.4.3 `<w:left>` (CT_Border) — optional left border.
  left : CT_Border?
  /// §17.3.4.3 `<w:bottom>` (CT_Border) — optional bottom border.
  bottom : CT_Border?
  /// §17.3.4.3 `<w:right>` (CT_Border) — optional right border.
  right : CT_Border?
} derive(Eq, Debug)

///|
/// XSD complex type CT_DivBdr — Part 1 §17.15.2.8.
pub fn CT_DivBdr::new(
  element : @xml.Element,
) -> CT_DivBdr raise SchemaViolation {
  let top = match wml_ct_chunk6_first_child(element, "top") {
    Some(c) => Some(CT_Border::new(c))
    None => None
  }
  let left = match wml_ct_chunk6_first_child(element, "left") {
    Some(c) => Some(CT_Border::new(c))
    None => None
  }
  let bottom = match wml_ct_chunk6_first_child(element, "bottom") {
    Some(c) => Some(CT_Border::new(c))
    None => None
  }
  let right = match wml_ct_chunk6_first_child(element, "right") {
    Some(c) => Some(CT_Border::new(c))
    None => None
  }
  { element, top, left, bottom, right }
}

///|
/// XSD complex type CT_DivBdr — Part 1 §17.15.2.8.
pub fn CT_DivBdr::parse(
  element : @xml.Element,
) -> CT_DivBdr raise SchemaViolation {
  CT_DivBdr::new(element)
}

///|
pub fn CT_DivBdr::to_element(self : CT_DivBdr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Div — Part 1 §17.15.2.9 (div `<div>` Definition).
/// Sequence with eight children plus a required `@id` (ST_DecimalNumber
/// §17.18.10). Optional `<w:blockQuote>` and `<w:bodyDiv>` (each
/// CT_OnOff) flag block-quote / body-level wrapping. Required margin
/// quadruple `<w:marLeft>`, `<w:marRight>`, `<w:marTop>`, `<w:marBottom>`
/// (each CT_SignedTwipsMeasure §17.18.81). Optional `<w:divBdr>`
/// (CT_DivBdr) and an unbounded `<w:divsChild>` (CT_Divs) for nested
/// `<div>` groupings.
pub(all) struct CT_Div {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required `<div>` identifier.
  id : ST_DecimalNumber
  /// §17.17.4 `<w:blockQuote>` (CT_OnOff) — optional block-quote flag.
  block_quote : CT_OnOff?
  /// §17.17.4 `<w:bodyDiv>` (CT_OnOff) — optional body-div flag.
  body_div : CT_OnOff?
  /// §17.18.81 `<w:marLeft>` (CT_SignedTwipsMeasure) — required left margin.
  mar_left : CT_SignedTwipsMeasure
  /// §17.18.81 `<w:marRight>` (CT_SignedTwipsMeasure) — required right margin.
  mar_right : CT_SignedTwipsMeasure
  /// §17.18.81 `<w:marTop>` (CT_SignedTwipsMeasure) — required top margin.
  mar_top : CT_SignedTwipsMeasure
  /// §17.18.81 `<w:marBottom>` (CT_SignedTwipsMeasure) — required bottom margin.
  mar_bottom : CT_SignedTwipsMeasure
  /// §17.15.2.8 `<w:divBdr>` (CT_DivBdr) — optional border bundle.
  div_bdr : CT_DivBdr?
  /// §17.15.2.10 `<w:divsChild>` (CT_Divs)* — nested `<div>` collections.
  divs_child : Array[CT_Divs]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Div — Part 1 §17.15.2.9.
pub fn CT_Div::new(element : @xml.Element) -> CT_Div raise SchemaViolation {
  let raw_id = wml_ct_chunk6_required_attr(
    element, "id", "CT_Div", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let block_quote = match wml_ct_chunk6_first_child(element, "blockQuote") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let body_div = match wml_ct_chunk6_first_child(element, "bodyDiv") {
    Some(c) => Some(CT_OnOff::new(c))
    None => None
  }
  let mar_left = match wml_ct_chunk6_first_child(element, "marLeft") {
    Some(c) => CT_SignedTwipsMeasure::new(c)
    None =>
      raise_schema_violation(
        "CT_Div", "marLeft", "Part 1 §17.15.2.9: required child <w:marLeft> is missing",
      )
  }
  let mar_right = match wml_ct_chunk6_first_child(element, "marRight") {
    Some(c) => CT_SignedTwipsMeasure::new(c)
    None =>
      raise_schema_violation(
        "CT_Div", "marRight", "Part 1 §17.15.2.9: required child <w:marRight> is missing",
      )
  }
  let mar_top = match wml_ct_chunk6_first_child(element, "marTop") {
    Some(c) => CT_SignedTwipsMeasure::new(c)
    None =>
      raise_schema_violation(
        "CT_Div", "marTop", "Part 1 §17.15.2.9: required child <w:marTop> is missing",
      )
  }
  let mar_bottom = match wml_ct_chunk6_first_child(element, "marBottom") {
    Some(c) => CT_SignedTwipsMeasure::new(c)
    None =>
      raise_schema_violation(
        "CT_Div", "marBottom", "Part 1 §17.15.2.9: required child <w:marBottom> is missing",
      )
  }
  let div_bdr = match wml_ct_chunk6_first_child(element, "divBdr") {
    Some(c) => Some(CT_DivBdr::new(c))
    None => None
  }
  let divs_child : Array[CT_Divs] = []
  for child in wml_ct_chunk6_children(element, "divsChild") {
    divs_child.push(CT_Divs::new(child))
  }
  {
    element,
    id,
    block_quote,
    body_div,
    mar_left,
    mar_right,
    mar_top,
    mar_bottom,
    div_bdr,
    divs_child,
  }
}

///|
/// XSD complex type CT_Div — Part 1 §17.15.2.9.
pub fn CT_Div::parse(element : @xml.Element) -> CT_Div raise SchemaViolation {
  CT_Div::new(element)
}

///|
pub fn CT_Div::to_element(self : CT_Div) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Divs — Part 1 §17.15.2.10 (divs `<div>` Group).
/// Sequence with `minOccurs="1"` `maxOccurs="unbounded"` of `<w:div>`
/// (CT_Div per §17.15.2.9) children — at least one child is required
/// for the group to be well-formed.
pub(all) struct CT_Divs {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.15.2.9 `<w:div>` (CT_Div)+ — one or more `<div>` definitions.
  divs : Array[CT_Div]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Divs — Part 1 §17.15.2.10. Raises SchemaViolation
/// when the schema-required one-or-more constraint is not met.
pub fn CT_Divs::new(element : @xml.Element) -> CT_Divs raise SchemaViolation {
  let divs : Array[CT_Div] = []
  for child in wml_ct_chunk6_children(element, "div") {
    divs.push(CT_Div::new(child))
  }
  if divs.length() == 0 {
    raise_schema_violation(
      "CT_Divs", "div", "Part 1 §17.15.2.10: at least one <w:div> child is required",
    )
  }
  { element, divs }
}

///|
/// XSD complex type CT_Divs — Part 1 §17.15.2.10.
pub fn CT_Divs::parse(element : @xml.Element) -> CT_Divs raise SchemaViolation {
  CT_Divs::new(element)
}

///|
pub fn CT_Divs::to_element(self : CT_Divs) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Caption — Part 1 §17.11.6 (caption Single Caption
/// Definition). Required `@name` (s:ST_String §22.9.2.13) plus six
/// optional attributes: `@pos` (ST_CaptionPos §17.18.4), `@chapNum`
/// (s:ST_OnOff §22.9.2.7), `@heading` (ST_DecimalNumber §17.18.10),
/// `@noLabel` (s:ST_OnOff), `@numFmt` (ST_NumberFormat §17.18.59) and
/// `@sep` (ST_ChapterSep §17.18.6).
pub(all) struct CT_Caption {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @name (s:ST_String) — required caption identifier.
  name : String
  /// §17.18.4 @pos (ST_CaptionPos) — optional caption position.
  pos : ST_CaptionPos?
  /// §22.9.2.7 @chapNum (s:ST_OnOff) — optional chapter-number flag.
  chap_num : Bool?
  /// §17.18.10 @heading (ST_DecimalNumber) — optional heading level.
  heading : ST_DecimalNumber?
  /// §22.9.2.7 @noLabel (s:ST_OnOff) — optional no-label flag.
  no_label : Bool?
  /// §17.18.59 @numFmt (ST_NumberFormat) — optional numeric format.
  num_fmt : ST_NumberFormat?
  /// §17.18.6 @sep (ST_ChapterSep) — optional chapter separator.
  sep : ST_ChapterSep?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Caption — Part 1 §17.11.6.
pub fn CT_Caption::new(
  element : @xml.Element,
) -> CT_Caption raise SchemaViolation {
  let name = wml_ct_chunk6_required_attr(
    element, "name", "CT_Caption", "Part 1 §22.9.2.13 s:ST_String",
  )
  let pos = match wml_ct_chunk6_attr(element, "pos") {
    Some(text) => Some(ST_CaptionPos::parse(text))
    None => None
  }
  let chap_num = wml_ct_chunk6_on_off(wml_ct_chunk6_attr(element, "chapNum"))
  let heading = match wml_ct_chunk6_attr(element, "heading") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let no_label = wml_ct_chunk6_on_off(wml_ct_chunk6_attr(element, "noLabel"))
  let num_fmt = match wml_ct_chunk6_attr(element, "numFmt") {
    Some(text) => Some(ST_NumberFormat::parse(text))
    None => None
  }
  let sep = match wml_ct_chunk6_attr(element, "sep") {
    Some(text) => Some(ST_ChapterSep::parse(text))
    None => None
  }
  { element, name, pos, chap_num, heading, no_label, num_fmt, sep }
}

///|
/// XSD complex type CT_Caption — Part 1 §17.11.6.
pub fn CT_Caption::parse(
  element : @xml.Element,
) -> CT_Caption raise SchemaViolation {
  CT_Caption::new(element)
}

///|
pub fn CT_Caption::to_element(self : CT_Caption) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AutoCaption — Part 1 §17.11.2 (autoCaption Single
/// Automatic Caption). Two required s:ST_String attributes: `@name`
/// names the OLE object class for which the caption applies and
/// `@caption` carries the caption text to be inserted.
pub(all) struct CT_AutoCaption {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @name (s:ST_String) — required OLE object identifier.
  name : String
  /// §22.9.2.13 @caption (s:ST_String) — required caption text.
  caption : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_AutoCaption — Part 1 §17.11.2.
pub fn CT_AutoCaption::new(
  element : @xml.Element,
) -> CT_AutoCaption raise SchemaViolation {
  let name = wml_ct_chunk6_required_attr(
    element, "name", "CT_AutoCaption", "Part 1 §22.9.2.13 s:ST_String",
  )
  let caption = wml_ct_chunk6_required_attr(
    element, "caption", "CT_AutoCaption", "Part 1 §22.9.2.13 s:ST_String",
  )
  { element, name, caption }
}

///|
/// XSD complex type CT_AutoCaption — Part 1 §17.11.2.
pub fn CT_AutoCaption::parse(
  element : @xml.Element,
) -> CT_AutoCaption raise SchemaViolation {
  CT_AutoCaption::new(element)
}

///|
pub fn CT_AutoCaption::to_element(self : CT_AutoCaption) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AutoCaptions — Part 1 §17.11.3 (autoCaptions
/// Automatic Captions). Sequence with `minOccurs="1"` `maxOccurs="unbounded"`
/// of `<w:autoCaption>` (CT_AutoCaption per §17.11.2) children — at
/// least one entry must be present for the container to be well-formed.
pub(all) struct CT_AutoCaptions {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.11.2 `<w:autoCaption>` (CT_AutoCaption)+ — one or more entries.
  auto_caption : Array[CT_AutoCaption]
} derive(Eq, Debug)

///|
/// XSD complex type CT_AutoCaptions — Part 1 §17.11.3.
pub fn CT_AutoCaptions::new(
  element : @xml.Element,
) -> CT_AutoCaptions raise SchemaViolation {
  let auto_caption : Array[CT_AutoCaption] = []
  for child in wml_ct_chunk6_children(element, "autoCaption") {
    auto_caption.push(CT_AutoCaption::new(child))
  }
  if auto_caption.length() == 0 {
    raise_schema_violation(
      "CT_AutoCaptions", "autoCaption", "Part 1 §17.11.3: at least one <w:autoCaption> child is required",
    )
  }
  { element, auto_caption }
}

///|
/// XSD complex type CT_AutoCaptions — Part 1 §17.11.3.
pub fn CT_AutoCaptions::parse(
  element : @xml.Element,
) -> CT_AutoCaptions raise SchemaViolation {
  CT_AutoCaptions::new(element)
}

///|
pub fn CT_AutoCaptions::to_element(self : CT_AutoCaptions) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Captions — Part 1 §17.11.5 (captions Caption
/// Definitions). Sequence holding one-or-more `<w:caption>` (CT_Caption
/// per §17.11.6) entries followed by an optional `<w:autoCaptions>`
/// (CT_AutoCaptions per §17.11.3) bundle.
pub(all) struct CT_Captions {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.11.6 `<w:caption>` (CT_Caption)+ — one or more caption definitions.
  caption : Array[CT_Caption]
  /// §17.11.3 `<w:autoCaptions>` (CT_AutoCaptions) — optional automatic captions.
  auto_captions : CT_AutoCaptions?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Captions — Part 1 §17.11.5.
pub fn CT_Captions::new(
  element : @xml.Element,
) -> CT_Captions raise SchemaViolation {
  let caption : Array[CT_Caption] = []
  for child in wml_ct_chunk6_children(element, "caption") {
    caption.push(CT_Caption::new(child))
  }
  if caption.length() == 0 {
    raise_schema_violation(
      "CT_Captions", "caption", "Part 1 §17.11.5: at least one <w:caption> child is required",
    )
  }
  let auto_captions = match wml_ct_chunk6_first_child(element, "autoCaptions") {
    Some(c) => Some(CT_AutoCaptions::new(c))
    None => None
  }
  { element, caption, auto_captions }
}

///|
/// XSD complex type CT_Captions — Part 1 §17.11.5.
pub fn CT_Captions::parse(
  element : @xml.Element,
) -> CT_Captions raise SchemaViolation {
  CT_Captions::new(element)
}

///|
pub fn CT_Captions::to_element(self : CT_Captions) -> @xml.Element {
  self.element
}
