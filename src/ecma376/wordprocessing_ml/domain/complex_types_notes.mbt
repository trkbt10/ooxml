///|
/// XSD complex type CT_FtnPos — Part 1 §17.11.13 (pos Footnote Position).
/// Required `@val` (ST_FtnPos §17.18.34) selects `pageBottom /
/// beneathText / sectEnd / docEnd`.
pub(all) struct CT_FtnPos {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.34 @val (ST_FtnPos) — required footnote position.
  val : ST_FtnPos
} derive(Eq, Debug)

///|
/// XSD complex type CT_FtnPos — Part 1 §17.11.13. Decode the required
/// `@val` ST_FtnPos token.
pub fn CT_FtnPos::new(
  element : @xml.Element,
) -> CT_FtnPos raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_FtnPos", "Part 1 §17.18.34 ST_FtnPos",
  )
  let val = ST_FtnPos::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_FtnPos — Part 1 §17.11.13.
pub fn CT_FtnPos::parse(
  element : @xml.Element,
) -> CT_FtnPos raise SchemaViolation {
  CT_FtnPos::new(element)
}

///|
pub fn CT_FtnPos::to_element(self : CT_FtnPos) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EdnPos — Part 1 §17.11.6 (pos Endnote Position).
/// Required `@val` (ST_EdnPos §17.18.25) selects `sectEnd / docEnd`.
pub(all) struct CT_EdnPos {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.25 @val (ST_EdnPos) — required endnote position.
  val : ST_EdnPos
} derive(Eq, Debug)

///|
/// XSD complex type CT_EdnPos — Part 1 §17.11.6. Decode the required
/// `@val` ST_EdnPos token.
pub fn CT_EdnPos::new(
  element : @xml.Element,
) -> CT_EdnPos raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_EdnPos", "Part 1 §17.18.25 ST_EdnPos",
  )
  let val = ST_EdnPos::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_EdnPos — Part 1 §17.11.6.
pub fn CT_EdnPos::parse(
  element : @xml.Element,
) -> CT_EdnPos raise SchemaViolation {
  CT_EdnPos::new(element)
}

///|
pub fn CT_EdnPos::to_element(self : CT_EdnPos) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnEdnRef — Part 1 §17.11.14 (footnoteReference)
/// and §17.11.7 (endnoteReference). Required `@id` (ST_DecimalNumber
/// §17.18.10) references the footnote/endnote payload; optional
/// `@customMarkFollows` (s:ST_OnOff §22.9.2.7) indicates that a custom
/// reference glyph follows in the run content.
pub(all) struct CT_FtnEdnRef {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required note identifier.
  id : ST_DecimalNumber
  /// §22.9.2.7 @customMarkFollows (s:ST_OnOff) — optional custom-mark hint.
  custom_mark_follows : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FtnEdnRef — Part 1 §17.11.14 / §17.11.7.
/// Decode the required `@id` and optional `@customMarkFollows`.
pub fn CT_FtnEdnRef::new(
  element : @xml.Element,
) -> CT_FtnEdnRef raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_FtnEdnRef", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let custom_mark_follows = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "customMarkFollows"),
  )
  { element, id, custom_mark_follows }
}

///|
/// XSD complex type CT_FtnEdnRef — Part 1 §17.11.14 / §17.11.7.
pub fn CT_FtnEdnRef::parse(
  element : @xml.Element,
) -> CT_FtnEdnRef raise SchemaViolation {
  CT_FtnEdnRef::new(element)
}

///|
pub fn CT_FtnEdnRef::to_element(self : CT_FtnEdnRef) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnEdnSepRef — Part 1 §17.11.12 (footnote /
/// endnote separator references inside docProps). Required `@id`
/// (ST_DecimalNumber §17.18.10) names the separator footnote/endnote.
pub(all) struct CT_FtnEdnSepRef {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required separator note id.
  id : ST_DecimalNumber
} derive(Eq, Debug)

///|
/// XSD complex type CT_FtnEdnSepRef — Part 1 §17.11.12. Decode the
/// required `@id` separator-note id.
pub fn CT_FtnEdnSepRef::new(
  element : @xml.Element,
) -> CT_FtnEdnSepRef raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_FtnEdnSepRef", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  { element, id }
}

///|
/// XSD complex type CT_FtnEdnSepRef — Part 1 §17.11.12.
pub fn CT_FtnEdnSepRef::parse(
  element : @xml.Element,
) -> CT_FtnEdnSepRef raise SchemaViolation {
  CT_FtnEdnSepRef::new(element)
}

///|
pub fn CT_FtnEdnSepRef::to_element(self : CT_FtnEdnSepRef) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnEdn — Part 1 §17.11.8 (endnote) / §17.11.10
/// (footnote). Required `@id` (ST_DecimalNumber §17.18.10) identifies
/// the note; optional `@type` (ST_FtnEdn §17.18.33) marks special
/// separators (`separator / continuationSeparator / continuationNotice`).
/// The body is a one-or-more EG_BlockLevelElts model group whose typed
/// projection is owned by the content-tree readers, preserved here as
/// the raw block-level child elements.
pub(all) struct CT_FtnEdn {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required note id.
  id : ST_DecimalNumber
  /// §17.18.33 @type (ST_FtnEdn) — optional note kind.
  ftn_edn_type : ST_FtnEdn?
  /// EG_BlockLevelElts+ — block-level children carrying the note body,
  /// typed projection of the EG_BlockLevelElts model group.
  block_level_elements : Array[EG_BlockLevelElts]
} derive(Eq, Debug)

///|
/// XSD complex type CT_FtnEdn — Part 1 §17.11.8 / §17.11.10. Decode the
/// required `@id`, optional `@type` and the EG_BlockLevelElts body.
pub fn CT_FtnEdn::new(
  element : @xml.Element,
) -> CT_FtnEdn raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_FtnEdn", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let ftn_edn_type = match wml_ct_chunk1_attr(element, "type") {
    Some(text) => Some(ST_FtnEdn::parse(text))
    None => None
  }
  let block_level_elements = collect_block_level_elements(
    wml_ct_chunk2_element_children(element),
  )
  { element, id, ftn_edn_type, block_level_elements }
}

///|
/// XSD complex type CT_FtnEdn — Part 1 §17.11.8 / §17.11.10.
pub fn CT_FtnEdn::parse(
  element : @xml.Element,
) -> CT_FtnEdn raise SchemaViolation {
  CT_FtnEdn::new(element)
}

///|
pub fn CT_FtnEdn::to_element(self : CT_FtnEdn) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnProps — Part 1 §17.11.5 (footnotePr Section
/// Footnote Properties). Optional `<w:pos>` (CT_FtnPos per §17.11.13),
/// optional `<w:numFmt>` (CT_NumFmt per §17.11.3) and the inline
/// EG_FtnEdnNumProps group — optional `<w:numStart>` (CT_DecimalNumber
/// per §17.11.4) and `<w:numRestart>` (CT_NumRestart per §17.11.4).
pub(all) struct CT_FtnProps {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.11.13 `<w:pos>` (CT_FtnPos) — optional footnote position.
  pos : CT_FtnPos?
  /// §17.11.3 `<w:numFmt>` (CT_NumFmt) — optional number format.
  num_fmt : CT_NumFmt?
  /// §17.11.4 `<w:numStart>` (CT_DecimalNumber) — optional restart base.
  num_start : CT_DecimalNumber?
  /// §17.11.4 `<w:numRestart>` (CT_NumRestart) — optional restart cadence.
  num_restart : CT_NumRestart?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FtnProps — Part 1 §17.11.5. Decode every
/// optional child of the sequence, propagating SchemaViolation from
/// typed constructors.
pub fn CT_FtnProps::new(
  element : @xml.Element,
) -> CT_FtnProps raise SchemaViolation {
  let pos = match wml_ct_chunk2_first_child(element, "pos") {
    Some(child) => Some(CT_FtnPos::new(child))
    None => None
  }
  let num_fmt = match wml_ct_chunk2_first_child(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let num_start = match wml_ct_chunk2_first_child(element, "numStart") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let num_restart = match wml_ct_chunk2_first_child(element, "numRestart") {
    Some(child) => Some(CT_NumRestart::new(child))
    None => None
  }
  { element, pos, num_fmt, num_start, num_restart }
}

///|
/// XSD complex type CT_FtnProps — Part 1 §17.11.5.
pub fn CT_FtnProps::parse(
  element : @xml.Element,
) -> CT_FtnProps raise SchemaViolation {
  CT_FtnProps::new(element)
}

///|
pub fn CT_FtnProps::to_element(self : CT_FtnProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EdnProps — Part 1 §17.11.1 (endnotePr Section
/// Endnote Properties). Optional `<w:pos>` (CT_EdnPos per §17.11.6),
/// optional `<w:numFmt>` (CT_NumFmt per §17.11.3) and the inline
/// EG_FtnEdnNumProps group — optional `<w:numStart>` (CT_DecimalNumber
/// per §17.11.4) and `<w:numRestart>` (CT_NumRestart per §17.11.4).
pub(all) struct CT_EdnProps {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.11.6 `<w:pos>` (CT_EdnPos) — optional endnote position.
  pos : CT_EdnPos?
  /// §17.11.3 `<w:numFmt>` (CT_NumFmt) — optional number format.
  num_fmt : CT_NumFmt?
  /// §17.11.4 `<w:numStart>` (CT_DecimalNumber) — optional restart base.
  num_start : CT_DecimalNumber?
  /// §17.11.4 `<w:numRestart>` (CT_NumRestart) — optional restart cadence.
  num_restart : CT_NumRestart?
} derive(Eq, Debug)

///|
/// XSD complex type CT_EdnProps — Part 1 §17.11.1.
pub fn CT_EdnProps::new(
  element : @xml.Element,
) -> CT_EdnProps raise SchemaViolation {
  let pos = match wml_ct_chunk2_first_child(element, "pos") {
    Some(child) => Some(CT_EdnPos::new(child))
    None => None
  }
  let num_fmt = match wml_ct_chunk2_first_child(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let num_start = match wml_ct_chunk2_first_child(element, "numStart") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let num_restart = match wml_ct_chunk2_first_child(element, "numRestart") {
    Some(child) => Some(CT_NumRestart::new(child))
    None => None
  }
  { element, pos, num_fmt, num_start, num_restart }
}

///|
/// XSD complex type CT_EdnProps — Part 1 §17.11.1.
pub fn CT_EdnProps::parse(
  element : @xml.Element,
) -> CT_EdnProps raise SchemaViolation {
  CT_EdnProps::new(element)
}

///|
pub fn CT_EdnProps::to_element(self : CT_EdnProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FtnDocProps — Part 1 §17.11.11 (footnotePr Document
/// Footnote Properties). Extends CT_FtnProps with zero-to-three
/// `<w:footnote>` (CT_FtnEdnSepRef per §17.11.12) separator references.
pub(all) struct CT_FtnDocProps {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.11.13 `<w:pos>` (CT_FtnPos) — optional footnote position (inherited).
  pos : CT_FtnPos?
  /// §17.11.3 `<w:numFmt>` (CT_NumFmt) — optional number format (inherited).
  num_fmt : CT_NumFmt?
  /// §17.11.4 `<w:numStart>` (CT_DecimalNumber) — optional restart base (inherited).
  num_start : CT_DecimalNumber?
  /// §17.11.4 `<w:numRestart>` (CT_NumRestart) — optional restart cadence (inherited).
  num_restart : CT_NumRestart?
  /// §17.11.12 `<w:footnote>` (CT_FtnEdnSepRef){0,3} — up to three separator refs.
  footnotes : Array[CT_FtnEdnSepRef]
} derive(Eq, Debug)

///|
/// XSD complex type CT_FtnDocProps — Part 1 §17.11.11. Decode the
/// inherited optional CT_FtnProps members plus up to three
/// `<w:footnote>` separator references.
pub fn CT_FtnDocProps::new(
  element : @xml.Element,
) -> CT_FtnDocProps raise SchemaViolation {
  let pos = match wml_ct_chunk2_first_child(element, "pos") {
    Some(child) => Some(CT_FtnPos::new(child))
    None => None
  }
  let num_fmt = match wml_ct_chunk2_first_child(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let num_start = match wml_ct_chunk2_first_child(element, "numStart") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let num_restart = match wml_ct_chunk2_first_child(element, "numRestart") {
    Some(child) => Some(CT_NumRestart::new(child))
    None => None
  }
  let footnotes : Array[CT_FtnEdnSepRef] = []
  for child in wml_ct_chunk2_children(element, "footnote") {
    footnotes.push(CT_FtnEdnSepRef::new(child))
  }
  { element, pos, num_fmt, num_start, num_restart, footnotes }
}

///|
/// XSD complex type CT_FtnDocProps — Part 1 §17.11.11.
pub fn CT_FtnDocProps::parse(
  element : @xml.Element,
) -> CT_FtnDocProps raise SchemaViolation {
  CT_FtnDocProps::new(element)
}

///|
pub fn CT_FtnDocProps::to_element(self : CT_FtnDocProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EdnDocProps — Part 1 §17.11.2 (endnotePr Document
/// Endnote Properties). Extends CT_EdnProps with zero-to-three
/// `<w:endnote>` (CT_FtnEdnSepRef per §17.11.12) separator references.
pub(all) struct CT_EdnDocProps {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.11.6 `<w:pos>` (CT_EdnPos) — optional endnote position (inherited).
  pos : CT_EdnPos?
  /// §17.11.3 `<w:numFmt>` (CT_NumFmt) — optional number format (inherited).
  num_fmt : CT_NumFmt?
  /// §17.11.4 `<w:numStart>` (CT_DecimalNumber) — optional restart base (inherited).
  num_start : CT_DecimalNumber?
  /// §17.11.4 `<w:numRestart>` (CT_NumRestart) — optional restart cadence (inherited).
  num_restart : CT_NumRestart?
  /// §17.11.12 `<w:endnote>` (CT_FtnEdnSepRef){0,3} — up to three separator refs.
  endnotes : Array[CT_FtnEdnSepRef]
} derive(Eq, Debug)

///|
/// XSD complex type CT_EdnDocProps — Part 1 §17.11.2.
pub fn CT_EdnDocProps::new(
  element : @xml.Element,
) -> CT_EdnDocProps raise SchemaViolation {
  let pos = match wml_ct_chunk2_first_child(element, "pos") {
    Some(child) => Some(CT_EdnPos::new(child))
    None => None
  }
  let num_fmt = match wml_ct_chunk2_first_child(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let num_start = match wml_ct_chunk2_first_child(element, "numStart") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let num_restart = match wml_ct_chunk2_first_child(element, "numRestart") {
    Some(child) => Some(CT_NumRestart::new(child))
    None => None
  }
  let endnotes : Array[CT_FtnEdnSepRef] = []
  for child in wml_ct_chunk2_children(element, "endnote") {
    endnotes.push(CT_FtnEdnSepRef::new(child))
  }
  { element, pos, num_fmt, num_start, num_restart, endnotes }
}

///|
/// XSD complex type CT_EdnDocProps — Part 1 §17.11.2.
pub fn CT_EdnDocProps::parse(
  element : @xml.Element,
) -> CT_EdnDocProps raise SchemaViolation {
  CT_EdnDocProps::new(element)
}

///|
pub fn CT_EdnDocProps::to_element(self : CT_EdnDocProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Footnotes — Part 1 §17.11.16 (footnotes Footnote
/// Collection). Sequence of zero-or-more `<w:footnote>` (CT_FtnEdn per
/// §17.11.10) children. The wml.xsd grammar declares the sequence with
/// `maxOccurs="unbounded"` and the inner element as `minOccurs="0"`.
pub(all) struct CT_Footnotes {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.11.10 `<w:footnote>` (CT_FtnEdn)* — footnote payloads.
  footnotes : Array[CT_FtnEdn]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Footnotes — Part 1 §17.11.16. Decode each
/// `<w:footnote>` child, propagating SchemaViolation from the typed
/// CT_FtnEdn constructor.
pub fn CT_Footnotes::new(
  element : @xml.Element,
) -> CT_Footnotes raise SchemaViolation {
  let footnotes : Array[CT_FtnEdn] = []
  for child in wml_ct_chunk2_children(element, "footnote") {
    footnotes.push(CT_FtnEdn::new(child))
  }
  { element, footnotes }
}

///|
/// XSD complex type CT_Footnotes — Part 1 §17.11.16.
pub fn CT_Footnotes::parse(
  element : @xml.Element,
) -> CT_Footnotes raise SchemaViolation {
  CT_Footnotes::new(element)
}

///|
pub fn CT_Footnotes::to_element(self : CT_Footnotes) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Endnotes — Part 1 §17.11.9 (endnotes Endnote
/// Collection). Sequence of zero-or-more `<w:endnote>` (CT_FtnEdn per
/// §17.11.8) children.
pub(all) struct CT_Endnotes {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.11.8 `<w:endnote>` (CT_FtnEdn)* — endnote payloads.
  endnotes : Array[CT_FtnEdn]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Endnotes — Part 1 §17.11.9.
pub fn CT_Endnotes::new(
  element : @xml.Element,
) -> CT_Endnotes raise SchemaViolation {
  let endnotes : Array[CT_FtnEdn] = []
  for child in wml_ct_chunk2_children(element, "endnote") {
    endnotes.push(CT_FtnEdn::new(child))
  }
  { element, endnotes }
}

///|
/// XSD complex type CT_Endnotes — Part 1 §17.11.9.
pub fn CT_Endnotes::parse(
  element : @xml.Element,
) -> CT_Endnotes raise SchemaViolation {
  CT_Endnotes::new(element)
}

///|
pub fn CT_Endnotes::to_element(self : CT_Endnotes) -> @xml.Element {
  self.element
}
