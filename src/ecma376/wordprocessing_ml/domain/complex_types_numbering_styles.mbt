///|
/// XSD complex type CT_NumFmt — Part 1 §17.9.18 (numFmt Numbering
/// Format). Required `@val` (ST_NumberFormat §17.18.59) selects the
/// presentation enumeration; optional `@format` (s:ST_String §22.9.2.13)
/// carries a custom-format override used by `custom` numbering styles.
pub(all) struct CT_NumFmt {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.59 @val (ST_NumberFormat) — required format enumeration.
  val : ST_NumberFormat
  /// §22.9.2.13 @format (s:ST_String) — optional custom-format string.
  format : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumFmt — Part 1 §17.9.18. Decode the required
/// `@val` ST_NumberFormat token and the optional `@format` string.
pub fn CT_NumFmt::new(
  element : @xml.Element,
) -> CT_NumFmt raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_NumFmt", "Part 1 §17.18.59 ST_NumberFormat",
  )
  let val = ST_NumberFormat::parse(raw)
  let format = wml_ct_chunk1_attr(element, "format")
  { element, val, format }
}

///|
/// XSD complex type CT_NumFmt — Part 1 §17.9.18.
pub fn CT_NumFmt::parse(
  element : @xml.Element,
) -> CT_NumFmt raise SchemaViolation {
  CT_NumFmt::new(element)
}

///|
pub fn CT_NumFmt::to_element(self : CT_NumFmt) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NumRestart — Part 1 §17.11.4 (numRestart Footnote
/// And Endnote Numbering Restart Location). Required `@val`
/// (ST_RestartNumber §17.18.81) selects `continuous / eachSect / eachPage`.
pub(all) struct CT_NumRestart {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.81 @val (ST_RestartNumber) — required restart cadence.
  val : ST_RestartNumber
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumRestart — Part 1 §17.11.4. Decode the required
/// `@val` ST_RestartNumber token.
pub fn CT_NumRestart::new(
  element : @xml.Element,
) -> CT_NumRestart raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_NumRestart", "Part 1 §17.18.81 ST_RestartNumber",
  )
  let val = ST_RestartNumber::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_NumRestart — Part 1 §17.11.4.
pub fn CT_NumRestart::parse(
  element : @xml.Element,
) -> CT_NumRestart raise SchemaViolation {
  CT_NumRestart::new(element)
}

///|
pub fn CT_NumRestart::to_element(self : CT_NumRestart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPrDefault — Part 1 §17.7.5.4 (rPrDefault Default
/// Run Properties). Optional `<w:rPr>` (CT_RPr per §17.3.2.27) carries
/// the document-wide default run formatting.
pub(all) struct CT_RPrDefault {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.3.2.27 `<w:rPr>` (CT_RPr) — optional default run properties.
  r_pr : CT_RPr?
} derive(Eq, Debug)

///|
/// XSD complex type CT_RPrDefault — Part 1 §17.7.5.4. Decode the
/// optional `<w:rPr>` child via the typed CT_RPr constructor.
pub fn CT_RPrDefault::new(
  element : @xml.Element,
) -> CT_RPrDefault raise SchemaViolation {
  let r_pr = match wml_ct_chunk2_first_child(element, "rPr") {
    Some(child) => Some(CT_RPr::new(child))
    None => None
  }
  { element, r_pr }
}

///|
/// XSD complex type CT_RPrDefault — Part 1 §17.7.5.4.
pub fn CT_RPrDefault::parse(
  element : @xml.Element,
) -> CT_RPrDefault raise SchemaViolation {
  CT_RPrDefault::new(element)
}

///|
pub fn CT_RPrDefault::to_element(self : CT_RPrDefault) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrDefault — Part 1 §17.7.5.3 (pPrDefault Default
/// Paragraph Properties). Optional `<w:pPr>` (CT_PPrGeneral per
/// §17.7.8.2) carries the document-wide default paragraph formatting.
pub(all) struct CT_PPrDefault {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.7.8.2 `<w:pPr>` (CT_PPrGeneral) — optional default paragraph properties.
  p_pr : CT_PPrGeneral?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PPrDefault — Part 1 §17.7.5.3. Decode the
/// optional `<w:pPr>` child via the typed CT_PPrGeneral constructor.
pub fn CT_PPrDefault::new(
  element : @xml.Element,
) -> CT_PPrDefault raise SchemaViolation {
  let p_pr = match wml_ct_chunk2_first_child(element, "pPr") {
    Some(child) => Some(CT_PPrGeneral::new(child))
    None => None
  }
  { element, p_pr }
}

///|
/// XSD complex type CT_PPrDefault — Part 1 §17.7.5.3.
pub fn CT_PPrDefault::parse(
  element : @xml.Element,
) -> CT_PPrDefault raise SchemaViolation {
  CT_PPrDefault::new(element)
}

///|
pub fn CT_PPrDefault::to_element(self : CT_PPrDefault) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocDefaults — Part 1 §17.7.5.1 (docDefaults
/// Document Default Paragraph and Run Properties). Optional
/// `<w:rPrDefault>` (CT_RPrDefault per §17.7.5.4) followed by optional
/// `<w:pPrDefault>` (CT_PPrDefault per §17.7.5.3).
pub(all) struct CT_DocDefaults {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.7.5.4 `<w:rPrDefault>` (CT_RPrDefault) — optional run defaults.
  r_pr_default : CT_RPrDefault?
  /// §17.7.5.3 `<w:pPrDefault>` (CT_PPrDefault) — optional paragraph defaults.
  p_pr_default : CT_PPrDefault?
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocDefaults — Part 1 §17.7.5.1. Decode both
/// optional children via their typed constructors.
pub fn CT_DocDefaults::new(
  element : @xml.Element,
) -> CT_DocDefaults raise SchemaViolation {
  let r_pr_default = match wml_ct_chunk2_first_child(element, "rPrDefault") {
    Some(child) => Some(CT_RPrDefault::new(child))
    None => None
  }
  let p_pr_default = match wml_ct_chunk2_first_child(element, "pPrDefault") {
    Some(child) => Some(CT_PPrDefault::new(child))
    None => None
  }
  { element, r_pr_default, p_pr_default }
}

///|
/// XSD complex type CT_DocDefaults — Part 1 §17.7.5.1.
pub fn CT_DocDefaults::parse(
  element : @xml.Element,
) -> CT_DocDefaults raise SchemaViolation {
  CT_DocDefaults::new(element)
}

///|
pub fn CT_DocDefaults::to_element(self : CT_DocDefaults) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StyleSort — Part 1 §17.15.1.84 (stylePaneSortMethod
/// Suggested Style Sorting Order). Required `@val` (ST_StyleSort
/// §17.18.92) selects `name / priority / default / font / basedOn / type`.
pub(all) struct CT_StyleSort {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.92 @val (ST_StyleSort) — required sort method.
  val : ST_StyleSort
} derive(Eq, Debug)

///|
/// XSD complex type CT_StyleSort — Part 1 §17.15.1.84. Decode the
/// required `@val` ST_StyleSort token.
pub fn CT_StyleSort::new(
  element : @xml.Element,
) -> CT_StyleSort raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_StyleSort", "Part 1 §17.18.92 ST_StyleSort",
  )
  let val = ST_StyleSort::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_StyleSort — Part 1 §17.15.1.84.
pub fn CT_StyleSort::parse(
  element : @xml.Element,
) -> CT_StyleSort raise SchemaViolation {
  CT_StyleSort::new(element)
}

///|
pub fn CT_StyleSort::to_element(self : CT_StyleSort) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StylePaneFilter — Part 1 §17.15.1.83
/// (stylePaneFormatFilter Suggested Filtering for Style Pane). All
/// fifteen attributes are optional s:ST_OnOff toggles selecting which
/// style classes the formatting pane surfaces.
pub(all) struct CT_StylePaneFilter {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @allStyles (s:ST_OnOff) — optional show-all toggle.
  all_styles : Bool?
  /// §22.9.2.7 @customStyles (s:ST_OnOff) — optional custom-styles toggle.
  custom_styles : Bool?
  /// §22.9.2.7 @latentStyles (s:ST_OnOff) — optional latent-styles toggle.
  latent_styles : Bool?
  /// §22.9.2.7 @stylesInUse (s:ST_OnOff) — optional in-use toggle.
  styles_in_use : Bool?
  /// §22.9.2.7 @headingStyles (s:ST_OnOff) — optional heading-styles toggle.
  heading_styles : Bool?
  /// §22.9.2.7 @numberingStyles (s:ST_OnOff) — optional numbering-styles toggle.
  numbering_styles : Bool?
  /// §22.9.2.7 @tableStyles (s:ST_OnOff) — optional table-styles toggle.
  table_styles : Bool?
  /// §22.9.2.7 @directFormattingOnRuns (s:ST_OnOff) — optional run-formatting toggle.
  direct_formatting_on_runs : Bool?
  /// §22.9.2.7 @directFormattingOnParagraphs (s:ST_OnOff) — optional paragraph-formatting toggle.
  direct_formatting_on_paragraphs : Bool?
  /// §22.9.2.7 @directFormattingOnNumbering (s:ST_OnOff) — optional numbering-formatting toggle.
  direct_formatting_on_numbering : Bool?
  /// §22.9.2.7 @directFormattingOnTables (s:ST_OnOff) — optional table-formatting toggle.
  direct_formatting_on_tables : Bool?
  /// §22.9.2.7 @clearFormatting (s:ST_OnOff) — optional clear-formatting toggle.
  clear_formatting : Bool?
  /// §22.9.2.7 @top3HeadingStyles (s:ST_OnOff) — optional top-three heading toggle.
  top3_heading_styles : Bool?
  /// §22.9.2.7 @visibleStyles (s:ST_OnOff) — optional visible-styles toggle.
  visible_styles : Bool?
  /// §22.9.2.7 @alternateStyleNames (s:ST_OnOff) — optional alternate-names toggle.
  alternate_style_names : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_StylePaneFilter — Part 1 §17.15.1.83. Decode
/// every optional ST_OnOff attribute.
pub fn CT_StylePaneFilter::new(element : @xml.Element) -> CT_StylePaneFilter {
  let all_styles = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "allStyles"),
  )
  let custom_styles = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "customStyles"),
  )
  let latent_styles = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "latentStyles"),
  )
  let styles_in_use = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "stylesInUse"),
  )
  let heading_styles = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "headingStyles"),
  )
  let numbering_styles = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "numberingStyles"),
  )
  let table_styles = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "tableStyles"),
  )
  let direct_formatting_on_runs = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "directFormattingOnRuns"),
  )
  let direct_formatting_on_paragraphs = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "directFormattingOnParagraphs"),
  )
  let direct_formatting_on_numbering = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "directFormattingOnNumbering"),
  )
  let direct_formatting_on_tables = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "directFormattingOnTables"),
  )
  let clear_formatting = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "clearFormatting"),
  )
  let top3_heading_styles = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "top3HeadingStyles"),
  )
  let visible_styles = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "visibleStyles"),
  )
  let alternate_style_names = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "alternateStyleNames"),
  )
  {
    element,
    all_styles,
    custom_styles,
    latent_styles,
    styles_in_use,
    heading_styles,
    numbering_styles,
    table_styles,
    direct_formatting_on_runs,
    direct_formatting_on_paragraphs,
    direct_formatting_on_numbering,
    direct_formatting_on_tables,
    clear_formatting,
    top3_heading_styles,
    visible_styles,
    alternate_style_names,
  }
}

///|
/// XSD complex type CT_StylePaneFilter — Part 1 §17.15.1.83.
pub fn CT_StylePaneFilter::parse(element : @xml.Element) -> CT_StylePaneFilter {
  CT_StylePaneFilter::new(element)
}

///|
pub fn CT_StylePaneFilter::to_element(
  self : CT_StylePaneFilter,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NumPicBullet — Part 1 §17.9.20 (numPicBullet
/// Picture Numbering Symbol Definition). Required
/// `@numPicBulletId` (ST_DecimalNumber §17.18.10) and a required
/// `<w:drawing>` (CT_Drawing per §20.4.2.8) selected by the wml.xsd
/// `xsd:choice`.
pub(all) struct CT_NumPicBullet {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @numPicBulletId (ST_DecimalNumber) — required bullet id.
  num_pic_bullet_id : ST_DecimalNumber
  /// §20.4.2.8 `<w:drawing>` (CT_Drawing) — required picture payload.
  drawing : CT_Drawing
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumPicBullet — Part 1 §17.9.20. Decode the
/// required `@numPicBulletId` and the required `<w:drawing>` child;
/// raise SchemaViolation when either is missing.
pub fn CT_NumPicBullet::new(
  element : @xml.Element,
) -> CT_NumPicBullet raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "numPicBulletId", "CT_NumPicBullet", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let num_pic_bullet_id = ST_DecimalNumber::parse(raw_id)
  let drawing = match wml_ct_chunk2_first_child(element, "drawing") {
    Some(child) => CT_Drawing::new(child)
    None =>
      raise_schema_violation(
        "CT_NumPicBullet", "drawing", "Part 1 §17.9.20: required child <w:drawing> is missing",
      )
  }
  { element, num_pic_bullet_id, drawing }
}

///|
/// XSD complex type CT_NumPicBullet — Part 1 §17.9.20.
pub fn CT_NumPicBullet::parse(
  element : @xml.Element,
) -> CT_NumPicBullet raise SchemaViolation {
  CT_NumPicBullet::new(element)
}

///|
pub fn CT_NumPicBullet::to_element(self : CT_NumPicBullet) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LevelSuffix — Part 1 §17.9.29 (suff Content Between
/// Numbering Symbol and Paragraph Text). Required `@val`
/// (ST_LevelSuffix §17.18.49) selects `tab / space / nothing`.
pub(all) struct CT_LevelSuffix {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.49 @val (ST_LevelSuffix) — required suffix kind.
  val : ST_LevelSuffix
} derive(Eq, Debug)

///|
/// XSD complex type CT_LevelSuffix — Part 1 §17.9.29.
pub fn CT_LevelSuffix::new(
  element : @xml.Element,
) -> CT_LevelSuffix raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_LevelSuffix", "Part 1 §17.18.49 ST_LevelSuffix",
  )
  let val = ST_LevelSuffix::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_LevelSuffix — Part 1 §17.9.29.
pub fn CT_LevelSuffix::parse(
  element : @xml.Element,
) -> CT_LevelSuffix raise SchemaViolation {
  CT_LevelSuffix::new(element)
}

///|
pub fn CT_LevelSuffix::to_element(self : CT_LevelSuffix) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LevelText — Part 1 §17.9.13 (lvlText Numbering
/// Level Text). Optional `@val` (s:ST_String §22.9.2.13) carries the
/// numbering-symbol template; optional `@null` (s:ST_OnOff §22.9.2.7)
/// marks the symbol as empty / placeholder.
pub(all) struct CT_LevelText {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @val (s:ST_String) — optional level-text template.
  val : String?
  /// §22.9.2.7 @null (s:ST_OnOff) — optional empty-symbol flag.
  null_ : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_LevelText — Part 1 §17.9.13. Decode the two
/// optional attributes.
pub fn CT_LevelText::new(element : @xml.Element) -> CT_LevelText {
  let val = wml_ct_chunk1_attr(element, "val")
  let null_ = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "null"))
  { element, val, null_ }
}

///|
/// XSD complex type CT_LevelText — Part 1 §17.9.13.
pub fn CT_LevelText::parse(element : @xml.Element) -> CT_LevelText {
  CT_LevelText::new(element)
}

///|
pub fn CT_LevelText::to_element(self : CT_LevelText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MultiLevelType — Part 1 §17.9.16 (multiLevelType
/// Abstract Numbering Definition Type). Required `@val`
/// (ST_MultiLevelType §17.18.57) selects `singleLevel / multilevel /
/// hybridMultilevel`.
pub(all) struct CT_MultiLevelType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.57 @val (ST_MultiLevelType) — required level-type kind.
  val : ST_MultiLevelType
} derive(Eq, Debug)

///|
/// XSD complex type CT_MultiLevelType — Part 1 §17.9.16.
pub fn CT_MultiLevelType::new(
  element : @xml.Element,
) -> CT_MultiLevelType raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_MultiLevelType", "Part 1 §17.18.57 ST_MultiLevelType",
  )
  let val = ST_MultiLevelType::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_MultiLevelType — Part 1 §17.9.16.
pub fn CT_MultiLevelType::parse(
  element : @xml.Element,
) -> CT_MultiLevelType raise SchemaViolation {
  CT_MultiLevelType::new(element)
}

///|
pub fn CT_MultiLevelType::to_element(self : CT_MultiLevelType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LsdException — Part 1 §17.7.4.3 (lsdException
/// Latent Style Exception). Required `@name` (s:ST_String §22.9.2.13)
/// names the latent style; five optional descriptors override the
/// defaults from CT_LatentStyles: `@locked / @semiHidden /
/// @unhideWhenUsed / @qFormat` (each s:ST_OnOff §22.9.2.7) and
/// `@uiPriority` (ST_DecimalNumber §17.18.10).
pub(all) struct CT_LsdException {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @name (s:ST_String) — required latent-style name.
  name : String
  /// §22.9.2.7 @locked (s:ST_OnOff) — optional locked override.
  locked : Bool?
  /// §17.18.10 @uiPriority (ST_DecimalNumber) — optional UI priority override.
  ui_priority : ST_DecimalNumber?
  /// §22.9.2.7 @semiHidden (s:ST_OnOff) — optional semi-hidden override.
  semi_hidden : Bool?
  /// §22.9.2.7 @unhideWhenUsed (s:ST_OnOff) — optional unhide-when-used override.
  unhide_when_used : Bool?
  /// §22.9.2.7 @qFormat (s:ST_OnOff) — optional quick-format override.
  q_format : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_LsdException — Part 1 §17.7.4.3. Decode the
/// required `@name` and every optional override attribute.
pub fn CT_LsdException::new(
  element : @xml.Element,
) -> CT_LsdException raise SchemaViolation {
  let name = wml_ct_chunk1_required_attr(
    element, "name", "CT_LsdException", "Part 1 §22.9.2.13 s:ST_String",
  )
  let locked = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "locked"))
  let ui_priority = match wml_ct_chunk1_attr(element, "uiPriority") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let semi_hidden = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "semiHidden"),
  )
  let unhide_when_used = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "unhideWhenUsed"),
  )
  let q_format = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "qFormat"))
  {
    element,
    name,
    locked,
    ui_priority,
    semi_hidden,
    unhide_when_used,
    q_format,
  }
}

///|
/// XSD complex type CT_LsdException — Part 1 §17.7.4.3.
pub fn CT_LsdException::parse(
  element : @xml.Element,
) -> CT_LsdException raise SchemaViolation {
  CT_LsdException::new(element)
}

///|
pub fn CT_LsdException::to_element(self : CT_LsdException) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LatentStyles — Part 1 §17.7.4.5 (latentStyles
/// Latent Style Information). Zero-or-more `<w:lsdException>`
/// (CT_LsdException per §17.7.4.3) children plus six optional
/// document-wide defaults: `@defLockedState / @defSemiHidden /
/// @defUnhideWhenUsed / @defQFormat` (each s:ST_OnOff §22.9.2.7),
/// `@defUIPriority` and `@count` (each ST_DecimalNumber §17.18.10).
pub(all) struct CT_LatentStyles {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @defLockedState (s:ST_OnOff) — optional default locked state.
  def_locked_state : Bool?
  /// §17.18.10 @defUIPriority (ST_DecimalNumber) — optional default UI priority.
  def_ui_priority : ST_DecimalNumber?
  /// §22.9.2.7 @defSemiHidden (s:ST_OnOff) — optional default semi-hidden flag.
  def_semi_hidden : Bool?
  /// §22.9.2.7 @defUnhideWhenUsed (s:ST_OnOff) — optional default unhide-when-used.
  def_unhide_when_used : Bool?
  /// §22.9.2.7 @defQFormat (s:ST_OnOff) — optional default quick-format flag.
  def_q_format : Bool?
  /// §17.18.10 @count (ST_DecimalNumber) — optional total exception count.
  count : ST_DecimalNumber?
  /// §17.7.4.3 `<w:lsdException>` (CT_LsdException)* — exception entries.
  lsd_exceptions : Array[CT_LsdException]
} derive(Eq, Debug)

///|
/// XSD complex type CT_LatentStyles — Part 1 §17.7.4.5. Decode every
/// optional default attribute and the `<w:lsdException>` children.
pub fn CT_LatentStyles::new(
  element : @xml.Element,
) -> CT_LatentStyles raise SchemaViolation {
  let def_locked_state = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "defLockedState"),
  )
  let def_ui_priority = match wml_ct_chunk1_attr(element, "defUIPriority") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let def_semi_hidden = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "defSemiHidden"),
  )
  let def_unhide_when_used = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "defUnhideWhenUsed"),
  )
  let def_q_format = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "defQFormat"),
  )
  let count = match wml_ct_chunk1_attr(element, "count") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let lsd_exceptions : Array[CT_LsdException] = []
  for child in wml_ct_chunk2_children(element, "lsdException") {
    lsd_exceptions.push(CT_LsdException::new(child))
  }
  {
    element,
    def_locked_state,
    def_ui_priority,
    def_semi_hidden,
    def_unhide_when_used,
    def_q_format,
    count,
    lsd_exceptions,
  }
}

///|
/// XSD complex type CT_LatentStyles — Part 1 §17.7.4.5.
pub fn CT_LatentStyles::parse(
  element : @xml.Element,
) -> CT_LatentStyles raise SchemaViolation {
  CT_LatentStyles::new(element)
}

///|
pub fn CT_LatentStyles::to_element(self : CT_LatentStyles) -> @xml.Element {
  self.element
}

// CT_Style and CT_Styles moved to style_types.mbt as the typed view
// required by §17.7 (Style Definitions) and §17.7.4.17 / §17.7.4.18.
