///|
/// SpreadsheetML attribute groups and model groups from sml.xsd.

///|
pub fn schema_group_name() -> String {
  "spreadsheet_ml.schema_groups"
}

///|
/// XSD attribute group AG_AutoFormat.
pub(all) struct AG_AutoFormat {
  auto_format_id : String?
  apply_number_formats : String?
  apply_border_formats : String?
  apply_font_formats : String?
  apply_pattern_formats : String?
  apply_alignment_formats : String?
  apply_width_height_formats : String?
} derive(Eq, Debug)

///|
pub fn AG_AutoFormat::new(
  auto_format_id? : String? = None,
  apply_number_formats? : String? = None,
  apply_border_formats? : String? = None,
  apply_font_formats? : String? = None,
  apply_pattern_formats? : String? = None,
  apply_alignment_formats? : String? = None,
  apply_width_height_formats? : String? = None,
) -> AG_AutoFormat {
  {
    auto_format_id,
    apply_number_formats,
    apply_border_formats,
    apply_font_formats,
    apply_pattern_formats,
    apply_alignment_formats,
    apply_width_height_formats,
  }
}

///|
/// XSD attribute group AG_RevData.
pub(all) struct AG_RevData {
  r_id : String?
  ua : String?
  ra : String?
} derive(Eq, Debug)

///|
pub fn AG_RevData::new(
  r_id? : String? = None,
  ua? : String? = None,
  ra? : String? = None,
) -> AG_RevData {
  { r_id, ua, ra }
}

///|
/// XSD model group EG_ExtensionList: Schema sml.xsd model group
/// `EG_ExtensionList` has `ext` children of type CT_Extension;
/// EG_ExtensionList and EG_ExtensionList::new own that extension-list group.
pub(all) struct EG_ExtensionList {
  ext : Array[CT_Extension]
} derive(Eq, Debug)

///|
pub fn EG_ExtensionList::new(ext : Array[CT_Extension]) -> EG_ExtensionList {
  let group_name = schema_group_name()
  if group_name.length() > 0 || ext.length() >= 0 {
    { ext, }
  } else {
    { ext, }
  }
}
