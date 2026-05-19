// WordprocessingML chunk7 typed complex types — wml.xsd §17 table family.
// Each CT_* declared here is a typed projection of every XSD attribute and
// child element described in ECMA-376 Part 1 §17.4 (tables) / §17.18 (simple
// types referenced) and the corresponding wml.xsd `xsd:complexType`. The
// source `<w:...>` element is preserved alongside the typed fields so
// builders can still round-trip foreign / future content unchanged. Where
// the schema content model is an `xsd:group` over `EG_*` model groups whose
// expansion is the responsibility of upstream readers (block-level
// elements, range-markup elements, content-cell content) the model-group
// children are surfaced as `Array[@xml.Element]` in document order — the
// upstream decoder owns the typed projection at that level.
//
// Helper functions live in `complex_types.mbt` (`wml_ct_chunk{1,2,4}_*`).

///|
/// First direct element child of `element` matching any of the local names
/// in `local_names`, returning the matched element together with the local
/// name resolved. Used for the `xsd:choice` selectors in EG_WrapType /
/// CT_TblStylePr / CT_PosH / CT_PosV — chunk7 mirror of the existing
/// chunk{3,4}_first_choice helpers.
fn wml_ct_chunk7_first_choice(
  element : @xml.Element,
  local_names : Array[String],
) -> (@xml.Element, String)? {
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        for candidate in local_names {
          if ln == candidate {
            return Some((e, candidate))
          }
        }
      }
      _ => ()
    }
  }
  None
}

///|
/// XSD complex type CT_TblWidth — Part 1 §17.4.86 (preferred table width).
/// Two optional attributes: `@w` (ST_MeasurementOrPercent §17.18.107)
/// carries the typed width (twentieths-of-a-point, percentage, or
/// universal measure) and `@type` (ST_TblWidth §17.18.87) selects the
/// auto/dxa/nil/pct width interpretation.
pub(all) struct CT_TblWidth {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.107 @w (ST_MeasurementOrPercent) — optional preferred width.
  w : ST_MeasurementOrPercent?
  /// §17.18.87 @type (ST_TblWidth) — optional width-interpretation token.
  type_ : ST_TblWidth?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblWidth — Part 1 §17.4.86.
pub fn CT_TblWidth::new(
  element : @xml.Element,
) -> CT_TblWidth raise SchemaViolation {
  let w = match wml_ct_chunk4_attr(element, "w") {
    Some(text) => Some(ST_MeasurementOrPercent::parse(text))
    None => None
  }
  let type_ = match wml_ct_chunk4_attr(element, "type") {
    Some(text) => Some(ST_TblWidth::parse(text))
    None => None
  }
  { element, w, type_ }
}

///|
pub fn CT_TblWidth::parse(
  element : @xml.Element,
) -> CT_TblWidth raise SchemaViolation {
  CT_TblWidth::new(element)
}

///|
pub fn CT_TblWidth::to_element(self : CT_TblWidth) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblGridCol — Part 1 §17.4.18 (single grid column
/// definition under tblGrid). Single optional `@w` (s:ST_TwipsMeasure
/// §22.9.2.10) — twentieths-of-a-point column width preserved lexically
/// so the unsigned-decimal / universal-measure union round-trips
/// byte-for-byte.
pub(all) struct CT_TblGridCol {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.10 @w (s:ST_TwipsMeasure) — optional column width.
  w : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblGridCol — Part 1 §17.4.16.
pub fn CT_TblGridCol::new(element : @xml.Element) -> CT_TblGridCol {
  let w = wml_ct_chunk4_attr(element, "w")
  { element, w }
}

///|
/// XSD complex type CT_TblGridCol — Part 1 §17.4.16.
pub fn CT_TblGridCol::parse(element : @xml.Element) -> CT_TblGridCol {
  CT_TblGridCol::new(element)
}

///|
pub fn CT_TblGridCol::to_element(self : CT_TblGridCol) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblGridBase — Part 1 §17.4.49 base. Carries an
/// `xsd:sequence minOccurs=0 maxOccurs=unbounded` of `<gridCol>`
/// (CT_TblGridCol) definitions describing the table grid.
pub(all) struct CT_TblGridBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.17 `<gridCol>`* (CT_TblGridCol) — grid column definitions.
  grid_col : Array[CT_TblGridCol]
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblGridBase — Part 1 §17.4.49.
pub fn CT_TblGridBase::new(element : @xml.Element) -> CT_TblGridBase {
  let grid_col : Array[CT_TblGridCol] = []
  for child in wml_ct_chunk4_children(element, "gridCol") {
    grid_col.push(CT_TblGridCol::new(child))
  }
  { element, grid_col }
}

///|
/// XSD complex type CT_TblGridBase — Part 1 §17.4.49.
pub fn CT_TblGridBase::parse(element : @xml.Element) -> CT_TblGridBase {
  CT_TblGridBase::new(element)
}

///|
pub fn CT_TblGridBase::to_element(self : CT_TblGridBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblGrid — Part 1 §17.4.49 (table grid definition).
/// Extends CT_TblGridBase with an optional `<tblGridChange>`
/// (CT_TblGridChange §17.13.5.33) revision snapshot.
pub(all) struct CT_TblGrid {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.17 `<gridCol>`* (CT_TblGridCol) — grid column definitions.
  grid_col : Array[CT_TblGridCol]
  /// §17.13.5.33 `<tblGridChange>`? — optional revision snapshot.
  tbl_grid_change : CT_TblGridChange?
} derive(Eq, Debug)

///|
pub fn CT_TblGrid::new(
  element : @xml.Element,
) -> CT_TblGrid raise SchemaViolation {
  let grid_col : Array[CT_TblGridCol] = []
  for child in wml_ct_chunk4_children(element, "gridCol") {
    grid_col.push(CT_TblGridCol::new(child))
  }
  let tbl_grid_change = match
    wml_ct_chunk4_first_child(element, "tblGridChange") {
    Some(child) => Some(CT_TblGridChange::new(child))
    None => None
  }
  { element, grid_col, tbl_grid_change }
}

///|
pub fn CT_TblGrid::parse(
  element : @xml.Element,
) -> CT_TblGrid raise SchemaViolation {
  CT_TblGrid::new(element)
}

///|
pub fn CT_TblGrid::to_element(self : CT_TblGrid) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TcBorders — Part 1 §17.4.66 (table-cell border
/// definitions). Eight optional `<top>`/`<start>`/`<bottom>`/`<end>`/
/// `<insideH>`/`<insideV>`/`<tl2br>`/`<tr2bl>` children (CT_Border
/// §17.3.4), one per cell edge or diagonal.
pub(all) struct CT_TcBorders {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.74 `<top>`? — top cell border.
  top : CT_Border?
  /// §17.4.34 `<start>`? — leading-edge cell border.
  start : CT_Border?
  /// §17.4.4 `<bottom>`? — bottom cell border.
  bottom : CT_Border?
  /// §17.4.13 `<end>`? — trailing-edge cell border.
  end : CT_Border?
  /// §17.4.24 `<insideH>`? — interior horizontal border.
  inside_h : CT_Border?
  /// §17.4.25 `<insideV>`? — interior vertical border.
  inside_v : CT_Border?
  /// §17.4.71 `<tl2br>`? — top-left to bottom-right diagonal.
  tl2br : CT_Border?
  /// §17.4.72 `<tr2bl>`? — top-right to bottom-left diagonal.
  tr2bl : CT_Border?
} derive(Eq, Debug)

///|
pub fn CT_TcBorders::new(
  element : @xml.Element,
) -> CT_TcBorders raise SchemaViolation {
  let top = match wml_ct_chunk4_first_child(element, "top") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let start = match wml_ct_chunk4_first_child(element, "start") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let bottom = match wml_ct_chunk4_first_child(element, "bottom") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let end = match wml_ct_chunk4_first_child(element, "end") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let inside_h = match wml_ct_chunk4_first_child(element, "insideH") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let inside_v = match wml_ct_chunk4_first_child(element, "insideV") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let tl2br = match wml_ct_chunk4_first_child(element, "tl2br") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let tr2bl = match wml_ct_chunk4_first_child(element, "tr2bl") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  { element, top, start, bottom, end, inside_h, inside_v, tl2br, tr2bl }
}

///|
pub fn CT_TcBorders::parse(
  element : @xml.Element,
) -> CT_TcBorders raise SchemaViolation {
  CT_TcBorders::new(element)
}

///|
pub fn CT_TcBorders::to_element(self : CT_TcBorders) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TcMar — Part 1 §17.4.67 (table-cell margins).
/// Four optional `<top>`/`<start>`/`<bottom>`/`<end>` children
/// (CT_TblWidth §17.4.86), one per margin edge.
pub(all) struct CT_TcMar {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.75 `<top>`? — top cell margin.
  top : CT_TblWidth?
  /// §17.4.35 `<start>`? — leading-edge cell margin.
  start : CT_TblWidth?
  /// §17.4.3 `<bottom>`? — bottom cell margin.
  bottom : CT_TblWidth?
  /// §17.4.14 `<end>`? — trailing-edge cell margin.
  end : CT_TblWidth?
} derive(Eq, Debug)

///|
pub fn CT_TcMar::new(element : @xml.Element) -> CT_TcMar raise SchemaViolation {
  let top = match wml_ct_chunk4_first_child(element, "top") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let start = match wml_ct_chunk4_first_child(element, "start") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let bottom = match wml_ct_chunk4_first_child(element, "bottom") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let end = match wml_ct_chunk4_first_child(element, "end") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  { element, top, start, bottom, end }
}

///|
pub fn CT_TcMar::parse(
  element : @xml.Element,
) -> CT_TcMar raise SchemaViolation {
  CT_TcMar::new(element)
}

///|
pub fn CT_TcMar::to_element(self : CT_TcMar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_VMerge — Part 1 §17.4.84 (vMerge vertical merge
/// marker). Single optional `@val` (ST_Merge §17.18.57) — `continue`
/// (default when omitted) joins this cell with the vMerge-restart above
/// it; `restart` opens a new vertical-merge sequence.
pub(all) struct CT_VMerge {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.57 @val (ST_Merge) — optional continue/restart selector.
  val : ST_Merge?
} derive(Eq, Debug)

///|
pub fn CT_VMerge::new(
  element : @xml.Element,
) -> CT_VMerge raise SchemaViolation {
  let val = match wml_ct_chunk4_attr(element, "val") {
    Some(text) => Some(ST_Merge::parse(text))
    None => None
  }
  { element, val }
}

///|
pub fn CT_VMerge::parse(
  element : @xml.Element,
) -> CT_VMerge raise SchemaViolation {
  CT_VMerge::new(element)
}

///|
pub fn CT_VMerge::to_element(self : CT_VMerge) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TcPrBase — Part 1 §17.4.69 base (table-cell
/// property base). All thirteen children are optional, in schema
/// `xsd:sequence` order: cnfStyle, tcW, gridSpan, vMerge, tcBorders,
/// shd, noWrap, tcMar, textDirection, tcFitText, vAlign, hideMark,
/// headers.
pub(all) struct CT_TcPrBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.7 `<cnfStyle>`? — conditional-formatting flags (CT_Cnf).
  cnf_style : CT_Cnf?
  /// §17.4.73 `<tcW>`? — preferred cell width (CT_TblWidth).
  tc_w : CT_TblWidth?
  /// §17.4.16 `<gridSpan>`? — horizontal span (CT_DecimalNumber).
  grid_span : CT_DecimalNumber?
  /// §17.4.84 `<vMerge>`? — vertical-merge marker (CT_VMerge).
  v_merge : CT_VMerge?
  /// §17.4.66 `<tcBorders>`? — cell borders (CT_TcBorders).
  tc_borders : CT_TcBorders?
  /// §17.4.32 `<shd>`? — cell shading (CT_Shd).
  shd : CT_Shd?
  /// §17.4.31 `<noWrap>`? — disable autosize wrap (CT_OnOff).
  no_wrap : CT_OnOff?
  /// §17.4.67 `<tcMar>`? — cell margins (CT_TcMar).
  tc_mar : CT_TcMar?
  /// §17.4.40 `<textDirection>`? — text-flow direction (CT_TextDirection).
  text_direction : CT_TextDirection?
  /// §17.4.68 `<tcFitText>`? — fit-text flag (CT_OnOff).
  tc_fit_text : CT_OnOff?
  /// §17.4.85 `<vAlign>`? — vertical alignment (CT_VerticalJc).
  v_align : CT_VerticalJc?
  /// §17.4.20 `<hideMark>`? — hide end-of-cell mark (CT_OnOff).
  hide_mark : CT_OnOff?
  /// §17.4.19 `<headers>`? — header-cell references (CT_Headers).
  headers : CT_Headers?
} derive(Eq, Debug)

///|
pub fn CT_TcPrBase::new(
  element : @xml.Element,
) -> CT_TcPrBase raise SchemaViolation {
  let cnf_style = match wml_ct_chunk4_first_child(element, "cnfStyle") {
    Some(child) => Some(CT_Cnf::new(child))
    None => None
  }
  let tc_w = match wml_ct_chunk4_first_child(element, "tcW") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let grid_span = match wml_ct_chunk4_first_child(element, "gridSpan") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let v_merge = match wml_ct_chunk4_first_child(element, "vMerge") {
    Some(child) => Some(CT_VMerge::new(child))
    None => None
  }
  let tc_borders = match wml_ct_chunk4_first_child(element, "tcBorders") {
    Some(child) => Some(CT_TcBorders::new(child))
    None => None
  }
  let shd = match wml_ct_chunk4_first_child(element, "shd") {
    Some(child) => Some(CT_Shd::new(child))
    None => None
  }
  let no_wrap = match wml_ct_chunk4_first_child(element, "noWrap") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let tc_mar = match wml_ct_chunk4_first_child(element, "tcMar") {
    Some(child) => Some(CT_TcMar::new(child))
    None => None
  }
  let text_direction = match
    wml_ct_chunk4_first_child(element, "textDirection") {
    Some(child) => Some(CT_TextDirection::new(child))
    None => None
  }
  let tc_fit_text = match wml_ct_chunk4_first_child(element, "tcFitText") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let v_align = match wml_ct_chunk4_first_child(element, "vAlign") {
    Some(child) => Some(CT_VerticalJc::new(child))
    None => None
  }
  let hide_mark = match wml_ct_chunk4_first_child(element, "hideMark") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let headers = match wml_ct_chunk4_first_child(element, "headers") {
    Some(child) => Some(CT_Headers::new(child))
    None => None
  }
  {
    element,
    cnf_style,
    tc_w,
    grid_span,
    v_merge,
    tc_borders,
    shd,
    no_wrap,
    tc_mar,
    text_direction,
    tc_fit_text,
    v_align,
    hide_mark,
    headers,
  }
}

///|
pub fn CT_TcPrBase::parse(
  element : @xml.Element,
) -> CT_TcPrBase raise SchemaViolation {
  CT_TcPrBase::new(element)
}

///|
pub fn CT_TcPrBase::to_element(self : CT_TcPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TcPrInner — Part 1 §17.4.69 inner (table-cell
/// property inner). Extends CT_TcPrBase with the EG_CellMarkupElements
/// model group (optional cellIns/cellDel/cellMerge revision markers
/// whose typed projection is owned by the upstream track-change reader).
pub(all) struct CT_TcPrInner {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.7 `<cnfStyle>`?
  cnf_style : CT_Cnf?
  /// §17.4.73 `<tcW>`?
  tc_w : CT_TblWidth?
  /// §17.4.16 `<gridSpan>`?
  grid_span : CT_DecimalNumber?
  /// §17.4.84 `<vMerge>`?
  v_merge : CT_VMerge?
  /// §17.4.66 `<tcBorders>`?
  tc_borders : CT_TcBorders?
  /// §17.4.32 `<shd>`?
  shd : CT_Shd?
  /// §17.4.31 `<noWrap>`?
  no_wrap : CT_OnOff?
  /// §17.4.67 `<tcMar>`?
  tc_mar : CT_TcMar?
  /// §17.4.40 `<textDirection>`?
  text_direction : CT_TextDirection?
  /// §17.4.68 `<tcFitText>`?
  tc_fit_text : CT_OnOff?
  /// §17.4.85 `<vAlign>`?
  v_align : CT_VerticalJc?
  /// §17.4.20 `<hideMark>`?
  hide_mark : CT_OnOff?
  /// §17.4.19 `<headers>`?
  headers : CT_Headers?
  /// EG_CellMarkupElements (§17.13.5.4 cellIns / §17.13.5.2 cellDel /
  /// §17.13.5.3 cellMerge) — raw children in document order, typed by
  /// upstream readers.
  cell_markup_elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn CT_TcPrInner::new(
  element : @xml.Element,
) -> CT_TcPrInner raise SchemaViolation {
  let cnf_style = match wml_ct_chunk4_first_child(element, "cnfStyle") {
    Some(child) => Some(CT_Cnf::new(child))
    None => None
  }
  let tc_w = match wml_ct_chunk4_first_child(element, "tcW") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let grid_span = match wml_ct_chunk4_first_child(element, "gridSpan") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let v_merge = match wml_ct_chunk4_first_child(element, "vMerge") {
    Some(child) => Some(CT_VMerge::new(child))
    None => None
  }
  let tc_borders = match wml_ct_chunk4_first_child(element, "tcBorders") {
    Some(child) => Some(CT_TcBorders::new(child))
    None => None
  }
  let shd = match wml_ct_chunk4_first_child(element, "shd") {
    Some(child) => Some(CT_Shd::new(child))
    None => None
  }
  let no_wrap = match wml_ct_chunk4_first_child(element, "noWrap") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let tc_mar = match wml_ct_chunk4_first_child(element, "tcMar") {
    Some(child) => Some(CT_TcMar::new(child))
    None => None
  }
  let text_direction = match
    wml_ct_chunk4_first_child(element, "textDirection") {
    Some(child) => Some(CT_TextDirection::new(child))
    None => None
  }
  let tc_fit_text = match wml_ct_chunk4_first_child(element, "tcFitText") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let v_align = match wml_ct_chunk4_first_child(element, "vAlign") {
    Some(child) => Some(CT_VerticalJc::new(child))
    None => None
  }
  let hide_mark = match wml_ct_chunk4_first_child(element, "hideMark") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let headers = match wml_ct_chunk4_first_child(element, "headers") {
    Some(child) => Some(CT_Headers::new(child))
    None => None
  }
  let cell_markup_elements : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "cellIns" | "cellDel" | "cellMerge" => cell_markup_elements.push(e)
          _ => ()
        }
      _ => ()
    }
  }
  {
    element,
    cnf_style,
    tc_w,
    grid_span,
    v_merge,
    tc_borders,
    shd,
    no_wrap,
    tc_mar,
    text_direction,
    tc_fit_text,
    v_align,
    hide_mark,
    headers,
    cell_markup_elements,
  }
}

///|
pub fn CT_TcPrInner::parse(
  element : @xml.Element,
) -> CT_TcPrInner raise SchemaViolation {
  CT_TcPrInner::new(element)
}

///|
pub fn CT_TcPrInner::to_element(self : CT_TcPrInner) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TcPr — Part 1 §17.4.69 (table-cell properties).
/// Extends CT_TcPrInner with an optional `<tcPrChange>` (CT_TcPrChange
/// §17.13.5.36) revision snapshot.
pub(all) struct CT_TcPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.7 `<cnfStyle>`?
  cnf_style : CT_Cnf?
  /// §17.4.73 `<tcW>`?
  tc_w : CT_TblWidth?
  /// §17.4.16 `<gridSpan>`?
  grid_span : CT_DecimalNumber?
  /// §17.4.84 `<vMerge>`?
  v_merge : CT_VMerge?
  /// §17.4.66 `<tcBorders>`?
  tc_borders : CT_TcBorders?
  /// §17.4.32 `<shd>`?
  shd : CT_Shd?
  /// §17.4.31 `<noWrap>`?
  no_wrap : CT_OnOff?
  /// §17.4.67 `<tcMar>`?
  tc_mar : CT_TcMar?
  /// §17.4.40 `<textDirection>`?
  text_direction : CT_TextDirection?
  /// §17.4.68 `<tcFitText>`?
  tc_fit_text : CT_OnOff?
  /// §17.4.85 `<vAlign>`?
  v_align : CT_VerticalJc?
  /// §17.4.20 `<hideMark>`?
  hide_mark : CT_OnOff?
  /// §17.4.19 `<headers>`?
  headers : CT_Headers?
  /// EG_CellMarkupElements raw children (cellIns / cellDel / cellMerge).
  cell_markup_elements : Array[@xml.Element]
  /// §17.13.5.36 `<tcPrChange>`? — optional revision snapshot.
  tc_pr_change : CT_TcPrChange?
} derive(Eq, Debug)

///|
pub fn CT_TcPr::new(element : @xml.Element) -> CT_TcPr raise SchemaViolation {
  let inner = CT_TcPrInner::new(element)
  let tc_pr_change = match wml_ct_chunk4_first_child(element, "tcPrChange") {
    Some(child) => Some(CT_TcPrChange::new(child))
    None => None
  }
  {
    element,
    cnf_style: inner.cnf_style,
    tc_w: inner.tc_w,
    grid_span: inner.grid_span,
    v_merge: inner.v_merge,
    tc_borders: inner.tc_borders,
    shd: inner.shd,
    no_wrap: inner.no_wrap,
    tc_mar: inner.tc_mar,
    text_direction: inner.text_direction,
    tc_fit_text: inner.tc_fit_text,
    v_align: inner.v_align,
    hide_mark: inner.hide_mark,
    headers: inner.headers,
    cell_markup_elements: inner.cell_markup_elements,
    tc_pr_change,
  }
}

///|
pub fn CT_TcPr::parse(element : @xml.Element) -> CT_TcPr raise SchemaViolation {
  CT_TcPr::new(element)
}

///|
pub fn CT_TcPr::to_element(self : CT_TcPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Tc — Part 1 §17.4.66 (table cell). One optional
/// `<tcPr>` (CT_TcPr) followed by an `EG_BlockLevelElts` model group
/// (`minOccurs=1 maxOccurs=unbounded` — typed projection owned by
/// upstream readers, exposed here as `Array[@xml.Element]`). An optional
/// `@id` (s:ST_String §22.9.2.13) identifies the cell for accessibility.
pub(all) struct CT_Tc {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.69 `<tcPr>`? — typed cell properties.
  tc_pr : CT_TcPr?
  /// EG_BlockLevelElts (1..unbounded) — raw block-level children in
  /// document order; the typed projection lives at the document reader.
  block_level_elts : Array[@xml.Element]
  /// §22.9.2.13 @id (s:ST_String) — optional accessibility identifier.
  id : String?
} derive(Eq, Debug)

///|
pub fn CT_Tc::new(element : @xml.Element) -> CT_Tc raise SchemaViolation {
  let tc_pr = match wml_ct_chunk4_first_child(element, "tcPr") {
    Some(child) => Some(CT_TcPr::new(child))
    None => None
  }
  let block_level_elts : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name != "tcPr" {
          block_level_elts.push(e)
        }
      _ => ()
    }
  }
  let id = wml_ct_chunk4_attr(element, "id")
  { element, tc_pr, block_level_elts, id }
}

///|
pub fn CT_Tc::parse(element : @xml.Element) -> CT_Tc raise SchemaViolation {
  CT_Tc::new(element)
}

///|
pub fn CT_Tc::to_element(self : CT_Tc) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Cnf — Part 1 §17.4.7 (cnfStyle conditional-format
/// flags). Twelve optional s:ST_OnOff attributes signal which table /
/// row / column / cell band the element participates in. The decoded
/// fields preserve `None` (attribute absent) vs `Some(false)` (attribute
/// present and explicitly disabled).
pub(all) struct CT_Cnf {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @firstRow.
  first_row : Bool?
  /// §22.9.2.7 @lastRow.
  last_row : Bool?
  /// §22.9.2.7 @firstColumn.
  first_column : Bool?
  /// §22.9.2.7 @lastColumn.
  last_column : Bool?
  /// §22.9.2.7 @oddVBand.
  odd_v_band : Bool?
  /// §22.9.2.7 @evenVBand.
  even_v_band : Bool?
  /// §22.9.2.7 @oddHBand.
  odd_h_band : Bool?
  /// §22.9.2.7 @evenHBand.
  even_h_band : Bool?
  /// §22.9.2.7 @firstRowFirstColumn.
  first_row_first_column : Bool?
  /// §22.9.2.7 @firstRowLastColumn.
  first_row_last_column : Bool?
  /// §22.9.2.7 @lastRowFirstColumn.
  last_row_first_column : Bool?
  /// §22.9.2.7 @lastRowLastColumn.
  last_row_last_column : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Cnf — Part 1 §17.4.7.
pub fn CT_Cnf::new(element : @xml.Element) -> CT_Cnf {
  let first_row = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "firstRow"))
  let last_row = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "lastRow"))
  let first_column = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "firstColumn"),
  )
  let last_column = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "lastColumn"),
  )
  let odd_v_band = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "oddVBand"))
  let even_v_band = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "evenVBand"),
  )
  let odd_h_band = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "oddHBand"))
  let even_h_band = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "evenHBand"),
  )
  let first_row_first_column = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "firstRowFirstColumn"),
  )
  let first_row_last_column = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "firstRowLastColumn"),
  )
  let last_row_first_column = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "lastRowFirstColumn"),
  )
  let last_row_last_column = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "lastRowLastColumn"),
  )
  {
    element,
    first_row,
    last_row,
    first_column,
    last_column,
    odd_v_band,
    even_v_band,
    odd_h_band,
    even_h_band,
    first_row_first_column,
    first_row_last_column,
    last_row_first_column,
    last_row_last_column,
  }
}

///|
/// XSD complex type CT_Cnf — Part 1 §17.4.7.
pub fn CT_Cnf::parse(element : @xml.Element) -> CT_Cnf {
  CT_Cnf::new(element)
}

///|
pub fn CT_Cnf::to_element(self : CT_Cnf) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrPrBase — Part 1 §17.4.81 base. The schema
/// declares an `xsd:choice maxOccurs="unbounded"` over twelve optional
/// elements — at runtime any of them may repeat. Each named child is
/// surfaced as an `Array[CT_*]` (or `Array[String]` lexical when the
/// upstream typed CT lives outside chunk7).
pub(all) struct CT_TrPrBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.7 `<cnfStyle>`*
  cnf_style : Array[CT_Cnf]
  /// §17.4.8 `<divId>`* — division identifier.
  div_id : Array[CT_DecimalNumber]
  /// §17.4.15 `<gridBefore>`* — leading-edge grid columns.
  grid_before : Array[CT_DecimalNumber]
  /// §17.4.14 `<gridAfter>`* — trailing-edge grid columns.
  grid_after : Array[CT_DecimalNumber]
  /// §17.4.86 `<wBefore>`* — preferred leading-row width.
  w_before : Array[CT_TblWidth]
  /// §17.4.87 `<wAfter>`* — preferred trailing-row width.
  w_after : Array[CT_TblWidth]
  /// §17.4.6 `<cantSplit>`* — disable row split (CT_OnOff).
  cant_split : Array[CT_OnOff]
  /// §17.4.80 `<trHeight>`* — row height (CT_Height).
  tr_height : Array[CT_Height]
  /// §17.4.78 `<tblHeader>`* — header-row marker (CT_OnOff).
  tbl_header : Array[CT_OnOff]
  /// §17.4.46 `<tblCellSpacing>`* — cell spacing (CT_TblWidth).
  tbl_cell_spacing : Array[CT_TblWidth]
  /// §17.4.27 `<jc>`* — row justification (CT_JcTable).
  jc : Array[CT_JcTable]
  /// §17.4.22 `<hidden>`* — hidden flag (CT_OnOff).
  hidden : Array[CT_OnOff]
} derive(Eq, Debug)

///|
pub fn CT_TrPrBase::new(
  element : @xml.Element,
) -> CT_TrPrBase raise SchemaViolation {
  let cnf_style : Array[CT_Cnf] = []
  for child in wml_ct_chunk4_children(element, "cnfStyle") {
    cnf_style.push(CT_Cnf::new(child))
  }
  let div_id : Array[CT_DecimalNumber] = []
  for child in wml_ct_chunk4_children(element, "divId") {
    div_id.push(CT_DecimalNumber::new(child))
  }
  let grid_before : Array[CT_DecimalNumber] = []
  for child in wml_ct_chunk4_children(element, "gridBefore") {
    grid_before.push(CT_DecimalNumber::new(child))
  }
  let grid_after : Array[CT_DecimalNumber] = []
  for child in wml_ct_chunk4_children(element, "gridAfter") {
    grid_after.push(CT_DecimalNumber::new(child))
  }
  let w_before : Array[CT_TblWidth] = []
  for child in wml_ct_chunk4_children(element, "wBefore") {
    w_before.push(CT_TblWidth::new(child))
  }
  let w_after : Array[CT_TblWidth] = []
  for child in wml_ct_chunk4_children(element, "wAfter") {
    w_after.push(CT_TblWidth::new(child))
  }
  let cant_split : Array[CT_OnOff] = []
  for child in wml_ct_chunk4_children(element, "cantSplit") {
    cant_split.push(CT_OnOff::new(child))
  }
  let tr_height : Array[CT_Height] = []
  for child in wml_ct_chunk4_children(element, "trHeight") {
    tr_height.push(CT_Height::new(child))
  }
  let tbl_header : Array[CT_OnOff] = []
  for child in wml_ct_chunk4_children(element, "tblHeader") {
    tbl_header.push(CT_OnOff::new(child))
  }
  let tbl_cell_spacing : Array[CT_TblWidth] = []
  for child in wml_ct_chunk4_children(element, "tblCellSpacing") {
    tbl_cell_spacing.push(CT_TblWidth::new(child))
  }
  let jc : Array[CT_JcTable] = []
  for child in wml_ct_chunk4_children(element, "jc") {
    jc.push(CT_JcTable::new(child))
  }
  let hidden : Array[CT_OnOff] = []
  for child in wml_ct_chunk4_children(element, "hidden") {
    hidden.push(CT_OnOff::new(child))
  }
  {
    element,
    cnf_style,
    div_id,
    grid_before,
    grid_after,
    w_before,
    w_after,
    cant_split,
    tr_height,
    tbl_header,
    tbl_cell_spacing,
    jc,
    hidden,
  }
}

///|
pub fn CT_TrPrBase::parse(
  element : @xml.Element,
) -> CT_TrPrBase raise SchemaViolation {
  CT_TrPrBase::new(element)
}

///|
pub fn CT_TrPrBase::to_element(self : CT_TrPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrPr — Part 1 §17.4.81 (table-row properties).
/// Extends CT_TrPrBase with optional `<ins>`/`<del>`/`<trPrChange>`
/// revision markers (CT_TrackChange for ins/del, CT_TrPrChange for the
/// property snapshot).
pub(all) struct CT_TrPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.7 `<cnfStyle>`*
  cnf_style : Array[CT_Cnf]
  /// §17.4.8 `<divId>`*
  div_id : Array[CT_DecimalNumber]
  /// §17.4.15 `<gridBefore>`*
  grid_before : Array[CT_DecimalNumber]
  /// §17.4.14 `<gridAfter>`*
  grid_after : Array[CT_DecimalNumber]
  /// §17.4.86 `<wBefore>`*
  w_before : Array[CT_TblWidth]
  /// §17.4.87 `<wAfter>`*
  w_after : Array[CT_TblWidth]
  /// §17.4.6 `<cantSplit>`*
  cant_split : Array[CT_OnOff]
  /// §17.4.80 `<trHeight>`*
  tr_height : Array[CT_Height]
  /// §17.4.78 `<tblHeader>`*
  tbl_header : Array[CT_OnOff]
  /// §17.4.46 `<tblCellSpacing>`*
  tbl_cell_spacing : Array[CT_TblWidth]
  /// §17.4.27 `<jc>`*
  jc : Array[CT_JcTable]
  /// §17.4.22 `<hidden>`*
  hidden : Array[CT_OnOff]
  /// §17.13.5.20 `<ins>`? — track-change insertion.
  ins : CT_TrackChange?
  /// §17.13.5.13 `<del>`? — track-change deletion.
  del : CT_TrackChange?
  /// §17.13.5.37 `<trPrChange>`? — property revision snapshot.
  tr_pr_change : CT_TrPrChange?
} derive(Eq, Debug)

///|
pub fn CT_TrPr::new(element : @xml.Element) -> CT_TrPr raise SchemaViolation {
  let base = CT_TrPrBase::new(element)
  let ins = match wml_ct_chunk4_first_child(element, "ins") {
    Some(child) => Some(CT_TrackChange::new(child))
    None => None
  }
  let del = match wml_ct_chunk4_first_child(element, "del") {
    Some(child) => Some(CT_TrackChange::new(child))
    None => None
  }
  let tr_pr_change = match wml_ct_chunk4_first_child(element, "trPrChange") {
    Some(child) => Some(CT_TrPrChange::new(child))
    None => None
  }
  {
    element,
    cnf_style: base.cnf_style,
    div_id: base.div_id,
    grid_before: base.grid_before,
    grid_after: base.grid_after,
    w_before: base.w_before,
    w_after: base.w_after,
    cant_split: base.cant_split,
    tr_height: base.tr_height,
    tbl_header: base.tbl_header,
    tbl_cell_spacing: base.tbl_cell_spacing,
    jc: base.jc,
    hidden: base.hidden,
    ins,
    del,
    tr_pr_change,
  }
}

///|
pub fn CT_TrPr::parse(element : @xml.Element) -> CT_TrPr raise SchemaViolation {
  CT_TrPr::new(element)
}

///|
pub fn CT_TrPr::to_element(self : CT_TrPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Row — Part 1 §17.4.79 (table row). Sequence: an
/// optional `<tblPrEx>` (CT_TblPrEx — exception properties), an
/// optional `<trPr>` (CT_TrPr — row properties), and an
/// EG_ContentCellContent model group (zero or more, typed projection
/// owned by upstream readers — surfaced as `Array[@xml.Element]`). The
/// four optional revision-id attributes are decoded as ST_LongHexNumber.
pub(all) struct CT_Row {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.61 `<tblPrEx>`? — table-property exception.
  tbl_pr_ex : CT_TblPrEx?
  /// §17.4.81 `<trPr>`? — typed row properties.
  tr_pr : CT_TrPr?
  /// EG_ContentCellContent (0..unbounded) — raw cell-content children
  /// (tc / sdt / customXml etc.).
  content_cell_content : Array[@xml.Element]
  /// §17.18.50 @rsidRPr (ST_LongHexNumber) — optional revision id.
  rsid_r_pr : ST_LongHexNumber?
  /// §17.18.50 @rsidR (ST_LongHexNumber) — optional revision id.
  rsid_r : ST_LongHexNumber?
  /// §17.18.50 @rsidDel (ST_LongHexNumber) — optional revision id.
  rsid_del : ST_LongHexNumber?
  /// §17.18.50 @rsidTr (ST_LongHexNumber) — optional revision id.
  rsid_tr : ST_LongHexNumber?
} derive(Eq, Debug)

///|
pub fn CT_Row::new(element : @xml.Element) -> CT_Row raise SchemaViolation {
  let tbl_pr_ex = match wml_ct_chunk4_first_child(element, "tblPrEx") {
    Some(child) => Some(CT_TblPrEx::new(child))
    None => None
  }
  let tr_pr = match wml_ct_chunk4_first_child(element, "trPr") {
    Some(child) => Some(CT_TrPr::new(child))
    None => None
  }
  let content_cell_content : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        if ln != "tblPrEx" && ln != "trPr" {
          content_cell_content.push(e)
        }
      }
      _ => ()
    }
  }
  let rsid_r_pr = match wml_ct_chunk4_attr(element, "rsidRPr") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_r = match wml_ct_chunk4_attr(element, "rsidR") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_del = match wml_ct_chunk4_attr(element, "rsidDel") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_tr = match wml_ct_chunk4_attr(element, "rsidTr") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  {
    element,
    tbl_pr_ex,
    tr_pr,
    content_cell_content,
    rsid_r_pr,
    rsid_r,
    rsid_del,
    rsid_tr,
  }
}

///|
pub fn CT_Row::parse(element : @xml.Element) -> CT_Row raise SchemaViolation {
  CT_Row::new(element)
}

///|
pub fn CT_Row::to_element(self : CT_Row) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblLayoutType — Part 1 §17.4.52 (tblLayout). The
/// only attribute `@type` (ST_TblLayoutType §17.18.85) is optional and
/// chooses between `autofit` (default when omitted) and `fixed`.
pub(all) struct CT_TblLayoutType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.85 @type (ST_TblLayoutType) — optional layout mode.
  type_ : ST_TblLayoutType?
} derive(Eq, Debug)

///|
pub fn CT_TblLayoutType::new(
  element : @xml.Element,
) -> CT_TblLayoutType raise SchemaViolation {
  let type_ = match wml_ct_chunk4_attr(element, "type") {
    Some(text) => Some(ST_TblLayoutType::parse(text))
    None => None
  }
  { element, type_ }
}

///|
pub fn CT_TblLayoutType::parse(
  element : @xml.Element,
) -> CT_TblLayoutType raise SchemaViolation {
  CT_TblLayoutType::new(element)
}

///|
pub fn CT_TblLayoutType::to_element(self : CT_TblLayoutType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblOverlap — Part 1 §17.4.55 (tblOverlap). The
/// required `@val` (ST_TblOverlap §17.18.86) chooses `never` (no
/// overlap with floating objects) or `overlap`.
pub(all) struct CT_TblOverlap {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.86 @val (ST_TblOverlap) — required overlap behaviour.
  val : ST_TblOverlap
} derive(Eq, Debug)

///|
pub fn CT_TblOverlap::new(
  element : @xml.Element,
) -> CT_TblOverlap raise SchemaViolation {
  let raw = wml_ct_chunk4_required_attr(
    element, "val", "CT_TblOverlap", "Part 1 §17.18.86 ST_TblOverlap",
  )
  let val = ST_TblOverlap::parse(raw)
  { element, val }
}

///|
pub fn CT_TblOverlap::parse(
  element : @xml.Element,
) -> CT_TblOverlap raise SchemaViolation {
  CT_TblOverlap::new(element)
}

///|
pub fn CT_TblOverlap::to_element(self : CT_TblOverlap) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPPr — Part 1 §17.4.59 (tblpPr, floating-table
/// positioning properties). Ten optional attributes describing
/// horizontal / vertical anchoring, signed-twips offsets, and named
/// X/Y alignments. Twips measures are preserved lexically so the
/// unsigned-decimal / universal-measure unions round-trip byte-for-byte.
pub(all) struct CT_TblPPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.10 @leftFromText (s:ST_TwipsMeasure).
  left_from_text : String?
  /// §22.9.2.10 @rightFromText (s:ST_TwipsMeasure).
  right_from_text : String?
  /// §22.9.2.10 @topFromText (s:ST_TwipsMeasure).
  top_from_text : String?
  /// §22.9.2.10 @bottomFromText (s:ST_TwipsMeasure).
  bottom_from_text : String?
  /// §17.18.103 @vertAnchor (ST_VAnchor) — optional vertical anchor.
  vert_anchor : ST_VAnchor?
  /// §17.18.40 @horzAnchor (ST_HAnchor) — optional horizontal anchor.
  horz_anchor : ST_HAnchor?
  /// §22.9.2.20 @tblpXSpec (s:ST_XAlign) — optional named X alignment
  /// (preserved lexically; the s: simple type lives outside chunk7's
  /// typing scope and is shared with the WordprocessingML drawing
  /// vocabulary).
  tblp_x_spec : String?
  /// §17.18.81 @tblpX (ST_SignedTwipsMeasure) — optional X offset.
  tblp_x : ST_SignedTwipsMeasure?
  /// §22.9.2.21 @tblpYSpec (s:ST_YAlign) — optional named Y alignment.
  tblp_y_spec : String?
  /// §17.18.81 @tblpY (ST_SignedTwipsMeasure) — optional Y offset.
  tblp_y : ST_SignedTwipsMeasure?
} derive(Eq, Debug)

///|
pub fn CT_TblPPr::new(
  element : @xml.Element,
) -> CT_TblPPr raise SchemaViolation {
  let left_from_text = wml_ct_chunk4_attr(element, "leftFromText")
  let right_from_text = wml_ct_chunk4_attr(element, "rightFromText")
  let top_from_text = wml_ct_chunk4_attr(element, "topFromText")
  let bottom_from_text = wml_ct_chunk4_attr(element, "bottomFromText")
  let vert_anchor = match wml_ct_chunk4_attr(element, "vertAnchor") {
    Some(text) => Some(ST_VAnchor::parse(text))
    None => None
  }
  let horz_anchor = match wml_ct_chunk4_attr(element, "horzAnchor") {
    Some(text) => Some(ST_HAnchor::parse(text))
    None => None
  }
  let tblp_x_spec = wml_ct_chunk4_attr(element, "tblpXSpec")
  let tblp_x = match wml_ct_chunk4_attr(element, "tblpX") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  let tblp_y_spec = wml_ct_chunk4_attr(element, "tblpYSpec")
  let tblp_y = match wml_ct_chunk4_attr(element, "tblpY") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  {
    element,
    left_from_text,
    right_from_text,
    top_from_text,
    bottom_from_text,
    vert_anchor,
    horz_anchor,
    tblp_x_spec,
    tblp_x,
    tblp_y_spec,
    tblp_y,
  }
}

///|
pub fn CT_TblPPr::parse(
  element : @xml.Element,
) -> CT_TblPPr raise SchemaViolation {
  CT_TblPPr::new(element)
}

///|
pub fn CT_TblPPr::to_element(self : CT_TblPPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblCellMar — Part 1 §17.4.42 (default table-cell
/// margins). Four optional `<top>`/`<start>`/`<bottom>`/`<end>` children
/// (CT_TblWidth §17.4.86) describing the default margin per edge.
pub(all) struct CT_TblCellMar {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.77 `<top>`?
  top : CT_TblWidth?
  /// §17.4.36 `<start>`?
  start : CT_TblWidth?
  /// §17.4.5 `<bottom>`?
  bottom : CT_TblWidth?
  /// §17.4.12 `<end>`?
  end : CT_TblWidth?
} derive(Eq, Debug)

///|
pub fn CT_TblCellMar::new(
  element : @xml.Element,
) -> CT_TblCellMar raise SchemaViolation {
  let top = match wml_ct_chunk4_first_child(element, "top") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let start = match wml_ct_chunk4_first_child(element, "start") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let bottom = match wml_ct_chunk4_first_child(element, "bottom") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let end = match wml_ct_chunk4_first_child(element, "end") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  { element, top, start, bottom, end }
}

///|
pub fn CT_TblCellMar::parse(
  element : @xml.Element,
) -> CT_TblCellMar raise SchemaViolation {
  CT_TblCellMar::new(element)
}

///|
pub fn CT_TblCellMar::to_element(self : CT_TblCellMar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblBorders — Part 1 §17.4.39 (table borders).
/// Six optional `<top>`/`<start>`/`<bottom>`/`<end>`/`<insideH>`/
/// `<insideV>` children (CT_Border §17.3.4) describing the table-level
/// border per edge or interior gridline.
pub(all) struct CT_TblBorders {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.76 `<top>`?
  top : CT_Border?
  /// §17.4.37 `<start>`?
  start : CT_Border?
  /// §17.4.2 `<bottom>`?
  bottom : CT_Border?
  /// §17.4.11 `<end>`?
  end : CT_Border?
  /// §17.4.23 `<insideH>`?
  inside_h : CT_Border?
  /// §17.4.24 `<insideV>`?
  inside_v : CT_Border?
} derive(Eq, Debug)

///|
pub fn CT_TblBorders::new(
  element : @xml.Element,
) -> CT_TblBorders raise SchemaViolation {
  let top = match wml_ct_chunk4_first_child(element, "top") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let start = match wml_ct_chunk4_first_child(element, "start") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let bottom = match wml_ct_chunk4_first_child(element, "bottom") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let end = match wml_ct_chunk4_first_child(element, "end") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let inside_h = match wml_ct_chunk4_first_child(element, "insideH") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let inside_v = match wml_ct_chunk4_first_child(element, "insideV") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  { element, top, start, bottom, end, inside_h, inside_v }
}

///|
pub fn CT_TblBorders::parse(
  element : @xml.Element,
) -> CT_TblBorders raise SchemaViolation {
  CT_TblBorders::new(element)
}

///|
pub fn CT_TblBorders::to_element(self : CT_TblBorders) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrBase — Part 1 §17.4.61 base (table-property
/// base, shared by CT_TblPr and CT_Style.tblPr). Seventeen optional
/// children in schema sequence order describing style, positioning,
/// overlap, banding, width, alignment, spacing, indent, borders,
/// shading, layout, default margins, look bits, and accessibility.
pub(all) struct CT_TblPrBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.65 `<tblStyle>`? — referenced style (CT_String, @val=styleId).
  tbl_style : CT_String?
  /// §17.4.59 `<tblpPr>`? — floating-table positioning (CT_TblPPr).
  tblp_pr : CT_TblPPr?
  /// §17.4.55 `<tblOverlap>`? — overlap mode (CT_TblOverlap).
  tbl_overlap : CT_TblOverlap?
  /// §17.4.1 `<bidiVisual>`? — visual-bidirectional flag (CT_OnOff).
  bidi_visual : CT_OnOff?
  /// §17.4.69 `<tblStyleRowBandSize>`? — banded row size.
  tbl_style_row_band_size : CT_DecimalNumber?
  /// §17.4.68 `<tblStyleColBandSize>`? — banded column size.
  tbl_style_col_band_size : CT_DecimalNumber?
  /// §17.4.86 `<tblW>`? — preferred table width.
  tbl_w : CT_TblWidth?
  /// §17.4.28 `<jc>`? — table-level justification (CT_JcTable).
  jc : CT_JcTable?
  /// §17.4.43 `<tblCellSpacing>`? — cell spacing (CT_TblWidth).
  tbl_cell_spacing : CT_TblWidth?
  /// §17.4.51 `<tblInd>`? — table indent (CT_TblWidth).
  tbl_ind : CT_TblWidth?
  /// §17.4.39 `<tblBorders>`? — table-level borders (CT_TblBorders).
  tbl_borders : CT_TblBorders?
  /// §17.4.32 `<shd>`? — table-level shading (CT_Shd).
  shd : CT_Shd?
  /// §17.4.52 `<tblLayout>`? — layout mode (CT_TblLayoutType).
  tbl_layout : CT_TblLayoutType?
  /// §17.4.42 `<tblCellMar>`? — default cell margins (CT_TblCellMar).
  tbl_cell_mar : CT_TblCellMar?
  /// §17.4.53 `<tblLook>`? — look bits for conditional formatting.
  tbl_look : CT_TblLook?
  /// §17.4.41 `<tblCaption>`? — accessibility caption.
  tbl_caption : CT_String?
  /// §17.4.47 `<tblDescription>`? — accessibility description.
  tbl_description : CT_String?
} derive(Eq, Debug)

///|
pub fn CT_TblPrBase::new(
  element : @xml.Element,
) -> CT_TblPrBase raise SchemaViolation {
  let tbl_style = match wml_ct_chunk4_first_child(element, "tblStyle") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let tblp_pr = match wml_ct_chunk4_first_child(element, "tblpPr") {
    Some(child) => Some(CT_TblPPr::new(child))
    None => None
  }
  let tbl_overlap = match wml_ct_chunk4_first_child(element, "tblOverlap") {
    Some(child) => Some(CT_TblOverlap::new(child))
    None => None
  }
  let bidi_visual = match wml_ct_chunk4_first_child(element, "bidiVisual") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let tbl_style_row_band_size = match
    wml_ct_chunk4_first_child(element, "tblStyleRowBandSize") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let tbl_style_col_band_size = match
    wml_ct_chunk4_first_child(element, "tblStyleColBandSize") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let tbl_w = match wml_ct_chunk4_first_child(element, "tblW") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let jc = match wml_ct_chunk4_first_child(element, "jc") {
    Some(child) => Some(CT_JcTable::new(child))
    None => None
  }
  let tbl_cell_spacing = match
    wml_ct_chunk4_first_child(element, "tblCellSpacing") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let tbl_ind = match wml_ct_chunk4_first_child(element, "tblInd") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let tbl_borders = match wml_ct_chunk4_first_child(element, "tblBorders") {
    Some(child) => Some(CT_TblBorders::new(child))
    None => None
  }
  let shd = match wml_ct_chunk4_first_child(element, "shd") {
    Some(child) => Some(CT_Shd::new(child))
    None => None
  }
  let tbl_layout = match wml_ct_chunk4_first_child(element, "tblLayout") {
    Some(child) => Some(CT_TblLayoutType::new(child))
    None => None
  }
  let tbl_cell_mar = match wml_ct_chunk4_first_child(element, "tblCellMar") {
    Some(child) => Some(CT_TblCellMar::new(child))
    None => None
  }
  let tbl_look = match wml_ct_chunk4_first_child(element, "tblLook") {
    Some(child) => Some(CT_TblLook::new(child))
    None => None
  }
  let tbl_caption = match wml_ct_chunk4_first_child(element, "tblCaption") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let tbl_description = match
    wml_ct_chunk4_first_child(element, "tblDescription") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  {
    element,
    tbl_style,
    tblp_pr,
    tbl_overlap,
    bidi_visual,
    tbl_style_row_band_size,
    tbl_style_col_band_size,
    tbl_w,
    jc,
    tbl_cell_spacing,
    tbl_ind,
    tbl_borders,
    shd,
    tbl_layout,
    tbl_cell_mar,
    tbl_look,
    tbl_caption,
    tbl_description,
  }
}

///|
pub fn CT_TblPrBase::parse(
  element : @xml.Element,
) -> CT_TblPrBase raise SchemaViolation {
  CT_TblPrBase::new(element)
}

///|
pub fn CT_TblPrBase::to_element(self : CT_TblPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPr — Part 1 §17.4.61 (table properties).
/// Extends CT_TblPrBase with an optional `<tblPrChange>` (CT_TblPrChange
/// §17.13.5.34) revision snapshot.
pub(all) struct CT_TblPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.65 `<tblStyle>`?
  tbl_style : CT_String?
  /// §17.4.59 `<tblpPr>`?
  tblp_pr : CT_TblPPr?
  /// §17.4.55 `<tblOverlap>`?
  tbl_overlap : CT_TblOverlap?
  /// §17.4.1 `<bidiVisual>`?
  bidi_visual : CT_OnOff?
  /// §17.4.69 `<tblStyleRowBandSize>`?
  tbl_style_row_band_size : CT_DecimalNumber?
  /// §17.4.68 `<tblStyleColBandSize>`?
  tbl_style_col_band_size : CT_DecimalNumber?
  /// §17.4.86 `<tblW>`?
  tbl_w : CT_TblWidth?
  /// §17.4.28 `<jc>`?
  jc : CT_JcTable?
  /// §17.4.43 `<tblCellSpacing>`?
  tbl_cell_spacing : CT_TblWidth?
  /// §17.4.51 `<tblInd>`?
  tbl_ind : CT_TblWidth?
  /// §17.4.39 `<tblBorders>`?
  tbl_borders : CT_TblBorders?
  /// §17.4.32 `<shd>`?
  shd : CT_Shd?
  /// §17.4.52 `<tblLayout>`?
  tbl_layout : CT_TblLayoutType?
  /// §17.4.42 `<tblCellMar>`?
  tbl_cell_mar : CT_TblCellMar?
  /// §17.4.53 `<tblLook>`?
  tbl_look : CT_TblLook?
  /// §17.4.41 `<tblCaption>`?
  tbl_caption : CT_String?
  /// §17.4.47 `<tblDescription>`?
  tbl_description : CT_String?
  /// §17.13.5.34 `<tblPrChange>`? — revision snapshot.
  tbl_pr_change : CT_TblPrChange?
} derive(Eq, Debug)

///|
pub fn CT_TblPr::new(element : @xml.Element) -> CT_TblPr raise SchemaViolation {
  let base = CT_TblPrBase::new(element)
  let tbl_pr_change = match wml_ct_chunk4_first_child(element, "tblPrChange") {
    Some(child) => Some(CT_TblPrChange::new(child))
    None => None
  }
  {
    element,
    tbl_style: base.tbl_style,
    tblp_pr: base.tblp_pr,
    tbl_overlap: base.tbl_overlap,
    bidi_visual: base.bidi_visual,
    tbl_style_row_band_size: base.tbl_style_row_band_size,
    tbl_style_col_band_size: base.tbl_style_col_band_size,
    tbl_w: base.tbl_w,
    jc: base.jc,
    tbl_cell_spacing: base.tbl_cell_spacing,
    tbl_ind: base.tbl_ind,
    tbl_borders: base.tbl_borders,
    shd: base.shd,
    tbl_layout: base.tbl_layout,
    tbl_cell_mar: base.tbl_cell_mar,
    tbl_look: base.tbl_look,
    tbl_caption: base.tbl_caption,
    tbl_description: base.tbl_description,
    tbl_pr_change,
  }
}

///|
pub fn CT_TblPr::parse(
  element : @xml.Element,
) -> CT_TblPr raise SchemaViolation {
  CT_TblPr::new(element)
}

///|
pub fn CT_TblPr::to_element(self : CT_TblPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrExBase — Part 1 §17.4.62 base (row-level
/// table-property exception base). Nine optional children — a subset of
/// CT_TblPrBase covering width / alignment / spacing / indent / borders
/// / shading / layout / margins / look bits.
pub(all) struct CT_TblPrExBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.86 `<tblW>`?
  tbl_w : CT_TblWidth?
  /// §17.4.28 `<jc>`?
  jc : CT_JcTable?
  /// §17.4.43 `<tblCellSpacing>`?
  tbl_cell_spacing : CT_TblWidth?
  /// §17.4.51 `<tblInd>`?
  tbl_ind : CT_TblWidth?
  /// §17.4.39 `<tblBorders>`?
  tbl_borders : CT_TblBorders?
  /// §17.4.32 `<shd>`?
  shd : CT_Shd?
  /// §17.4.52 `<tblLayout>`?
  tbl_layout : CT_TblLayoutType?
  /// §17.4.42 `<tblCellMar>`?
  tbl_cell_mar : CT_TblCellMar?
  /// §17.4.53 `<tblLook>`?
  tbl_look : CT_TblLook?
} derive(Eq, Debug)

///|
pub fn CT_TblPrExBase::new(
  element : @xml.Element,
) -> CT_TblPrExBase raise SchemaViolation {
  let tbl_w = match wml_ct_chunk4_first_child(element, "tblW") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let jc = match wml_ct_chunk4_first_child(element, "jc") {
    Some(child) => Some(CT_JcTable::new(child))
    None => None
  }
  let tbl_cell_spacing = match
    wml_ct_chunk4_first_child(element, "tblCellSpacing") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let tbl_ind = match wml_ct_chunk4_first_child(element, "tblInd") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let tbl_borders = match wml_ct_chunk4_first_child(element, "tblBorders") {
    Some(child) => Some(CT_TblBorders::new(child))
    None => None
  }
  let shd = match wml_ct_chunk4_first_child(element, "shd") {
    Some(child) => Some(CT_Shd::new(child))
    None => None
  }
  let tbl_layout = match wml_ct_chunk4_first_child(element, "tblLayout") {
    Some(child) => Some(CT_TblLayoutType::new(child))
    None => None
  }
  let tbl_cell_mar = match wml_ct_chunk4_first_child(element, "tblCellMar") {
    Some(child) => Some(CT_TblCellMar::new(child))
    None => None
  }
  let tbl_look = match wml_ct_chunk4_first_child(element, "tblLook") {
    Some(child) => Some(CT_TblLook::new(child))
    None => None
  }
  {
    element,
    tbl_w,
    jc,
    tbl_cell_spacing,
    tbl_ind,
    tbl_borders,
    shd,
    tbl_layout,
    tbl_cell_mar,
    tbl_look,
  }
}

///|
pub fn CT_TblPrExBase::parse(
  element : @xml.Element,
) -> CT_TblPrExBase raise SchemaViolation {
  CT_TblPrExBase::new(element)
}

///|
pub fn CT_TblPrExBase::to_element(self : CT_TblPrExBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrEx — Part 1 §17.4.62 (row-level
/// table-property exception). Extends CT_TblPrExBase with an optional
/// `<tblPrExChange>` (CT_TblPrExChange §17.13.5.35) revision snapshot.
pub(all) struct CT_TblPrEx {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.86 `<tblW>`?
  tbl_w : CT_TblWidth?
  /// §17.4.28 `<jc>`?
  jc : CT_JcTable?
  /// §17.4.43 `<tblCellSpacing>`?
  tbl_cell_spacing : CT_TblWidth?
  /// §17.4.51 `<tblInd>`?
  tbl_ind : CT_TblWidth?
  /// §17.4.39 `<tblBorders>`?
  tbl_borders : CT_TblBorders?
  /// §17.4.32 `<shd>`?
  shd : CT_Shd?
  /// §17.4.52 `<tblLayout>`?
  tbl_layout : CT_TblLayoutType?
  /// §17.4.42 `<tblCellMar>`?
  tbl_cell_mar : CT_TblCellMar?
  /// §17.4.53 `<tblLook>`?
  tbl_look : CT_TblLook?
  /// §17.13.5.35 `<tblPrExChange>`? — revision snapshot.
  tbl_pr_ex_change : CT_TblPrExChange?
} derive(Eq, Debug)

///|
pub fn CT_TblPrEx::new(
  element : @xml.Element,
) -> CT_TblPrEx raise SchemaViolation {
  let base = CT_TblPrExBase::new(element)
  let tbl_pr_ex_change = match
    wml_ct_chunk4_first_child(element, "tblPrExChange") {
    Some(child) => Some(CT_TblPrExChange::new(child))
    None => None
  }
  {
    element,
    tbl_w: base.tbl_w,
    jc: base.jc,
    tbl_cell_spacing: base.tbl_cell_spacing,
    tbl_ind: base.tbl_ind,
    tbl_borders: base.tbl_borders,
    shd: base.shd,
    tbl_layout: base.tbl_layout,
    tbl_cell_mar: base.tbl_cell_mar,
    tbl_look: base.tbl_look,
    tbl_pr_ex_change,
  }
}

///|
pub fn CT_TblPrEx::parse(
  element : @xml.Element,
) -> CT_TblPrEx raise SchemaViolation {
  CT_TblPrEx::new(element)
}

///|
pub fn CT_TblPrEx::to_element(self : CT_TblPrEx) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Tbl — Part 1 §17.4.38 (table). Sequence:
/// EG_RangeMarkupElements*, `<tblPr>` (required, CT_TblPr), `<tblGrid>`
/// (required, CT_TblGrid), then EG_ContentRowContent* — both range
/// markup and row content are projected as `Array[@xml.Element]` here
/// (the typed expansion lives at the document-reader layer).
pub(all) struct CT_Tbl {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// EG_RangeMarkupElements (0..unbounded) — leading range-markup
  /// children (bookmarkStart / bookmarkEnd / commentRangeStart etc.).
  range_markup_elements : Array[@xml.Element]
  /// §17.4.61 `<tblPr>` — required table properties.
  tbl_pr : CT_TblPr
  /// §17.4.49 `<tblGrid>` — required table grid.
  tbl_grid : CT_TblGrid
  /// EG_ContentRowContent (0..unbounded) — row content (tr / sdt /
  /// customXml etc.) following the grid.
  content_row_content : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn CT_Tbl::new(element : @xml.Element) -> CT_Tbl raise SchemaViolation {
  let tbl_pr = match wml_ct_chunk4_first_child(element, "tblPr") {
    Some(child) => CT_TblPr::new(child)
    None =>
      raise_schema_violation(
        "CT_Tbl", "tblPr", "Part 1 §17.4.38: required child <w:tblPr> is missing",
      )
  }
  let tbl_grid = match wml_ct_chunk4_first_child(element, "tblGrid") {
    Some(child) => CT_TblGrid::new(child)
    None =>
      raise_schema_violation(
        "CT_Tbl", "tblGrid", "Part 1 §17.4.38: required child <w:tblGrid> is missing",
      )
  }
  // Partition the remaining element children into the prefix (range markup)
  // and the suffix (row content) about the tblPr/tblGrid spine.
  let range_markup_elements : Array[@xml.Element] = []
  let content_row_content : Array[@xml.Element] = []
  let mut seen_spine = false
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "tblPr" | "tblGrid" => seen_spine = true
          _ =>
            if seen_spine {
              content_row_content.push(e)
            } else {
              range_markup_elements.push(e)
            }
        }
      _ => ()
    }
  }
  { element, range_markup_elements, tbl_pr, tbl_grid, content_row_content }
}

///|
pub fn CT_Tbl::parse(element : @xml.Element) -> CT_Tbl raise SchemaViolation {
  CT_Tbl::new(element)
}

///|
pub fn CT_Tbl::to_element(self : CT_Tbl) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblLook — Part 1 §17.4.53 (tblLook conditional
/// formatting bits). Six optional s:ST_OnOff attributes selecting which
/// rows / columns / banding receive conditional-style application.
pub(all) struct CT_TblLook {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @firstRow.
  first_row : Bool?
  /// §22.9.2.7 @lastRow.
  last_row : Bool?
  /// §22.9.2.7 @firstColumn.
  first_column : Bool?
  /// §22.9.2.7 @lastColumn.
  last_column : Bool?
  /// §22.9.2.7 @noHBand.
  no_h_band : Bool?
  /// §22.9.2.7 @noVBand.
  no_v_band : Bool?
} derive(Eq, Debug)

///|
pub fn CT_TblLook::new(element : @xml.Element) -> CT_TblLook {
  let first_row = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "firstRow"))
  let last_row = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "lastRow"))
  let first_column = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "firstColumn"),
  )
  let last_column = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "lastColumn"),
  )
  let no_h_band = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "noHBand"))
  let no_v_band = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "noVBand"))
  {
    element,
    first_row,
    last_row,
    first_column,
    last_column,
    no_h_band,
    no_v_band,
  }
}

///|
pub fn CT_TblLook::parse(element : @xml.Element) -> CT_TblLook {
  CT_TblLook::new(element)
}

///|
pub fn CT_TblLook::to_element(self : CT_TblLook) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblStylePr — Part 1 §17.7.6 (table-style
/// conditional-format override). Five optional children covering
/// paragraph / run / table / row / cell properties plus a required
/// `@type` (ST_TblStyleOverrideType §17.18.84) selecting which
/// conditional context the override applies to.
pub(all) struct CT_TblStylePr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.7.6 @type (ST_TblStyleOverrideType) — required context.
  type_ : ST_TblStyleOverrideType
  /// §17.7.6 `<pPr>`? — paragraph-property overrides (CT_PPrGeneral).
  p_pr : CT_PPrGeneral?
  /// §17.7.6 `<rPr>`? — run-property overrides (CT_RPr).
  r_pr : CT_RPr?
  /// §17.7.6 `<tblPr>`? — table-property overrides (CT_TblPrBase).
  tbl_pr : CT_TblPrBase?
  /// §17.7.6 `<trPr>`? — row-property overrides (CT_TrPr).
  tr_pr : CT_TrPr?
  /// §17.7.6 `<tcPr>`? — cell-property overrides (CT_TcPr).
  tc_pr : CT_TcPr?
} derive(Eq, Debug)

///|
pub fn CT_TblStylePr::new(
  element : @xml.Element,
) -> CT_TblStylePr raise SchemaViolation {
  let raw = wml_ct_chunk4_required_attr(
    element, "type", "CT_TblStylePr", "Part 1 §17.18.84 ST_TblStyleOverrideType",
  )
  let type_ = ST_TblStyleOverrideType::parse(raw)
  let p_pr = match wml_ct_chunk4_first_child(element, "pPr") {
    Some(child) => Some(CT_PPrGeneral::new(child))
    None => None
  }
  let r_pr = match wml_ct_chunk4_first_child(element, "rPr") {
    Some(child) => Some(CT_RPr::new(child))
    None => None
  }
  let tbl_pr = match wml_ct_chunk4_first_child(element, "tblPr") {
    Some(child) => Some(CT_TblPrBase::new(child))
    None => None
  }
  let tr_pr = match wml_ct_chunk4_first_child(element, "trPr") {
    Some(child) => Some(CT_TrPr::new(child))
    None => None
  }
  let tc_pr = match wml_ct_chunk4_first_child(element, "tcPr") {
    Some(child) => Some(CT_TcPr::new(child))
    None => None
  }
  { element, type_, p_pr, r_pr, tbl_pr, tr_pr, tc_pr }
}

///|
pub fn CT_TblStylePr::parse(
  element : @xml.Element,
) -> CT_TblStylePr raise SchemaViolation {
  CT_TblStylePr::new(element)
}

///|
pub fn CT_TblStylePr::to_element(self : CT_TblStylePr) -> @xml.Element {
  self.element
}

///|
/// First direct attribute of `element` with the given local name, or
/// `None` if no such attribute exists. WordprocessingML attributes use
/// the unqualified local name (`w:` prefix is namespace metadata) so a
/// local-name match is sufficient.
fn wml_ct_chunk6_attr(element : @xml.Element, local_name : String) -> String? {
  let mut found : String? = None
  for attribute in element.attributes {
    if found is None && attribute.name.local_name == local_name {
      found = Some(attribute.value)
    }
  }
  found
}

///|
/// Read a required attribute and raise SchemaViolation when missing.
fn wml_ct_chunk6_required_attr(
  element : @xml.Element,
  local_name : String,
  type_name : String,
  context : String,
) -> String raise SchemaViolation {
  match wml_ct_chunk6_attr(element, local_name) {
    Some(text) => text
    None =>
      raise_schema_violation(
        type_name,
        local_name,
        context + ": required attribute @" + local_name + " is missing",
      )
  }
}

///|
/// Decode an optional ST_OnOff lexical token (§22.9.2.7). Returns `None`
/// when the attribute is omitted and `Some(bool)` otherwise. Accepts the
/// four schema spellings (`0/1`, `on/off`, `true/false`).
fn wml_ct_chunk6_on_off(value : String?) -> Bool? {
  match value {
    Some("1") | Some("true") | Some("on") => Some(true)
    Some("0") | Some("false") | Some("off") => Some(false)
    Some(_) => Some(false)
    None => None
  }
}

///|
/// First direct element child of `element` with the given local name,
/// or `None` if no such child exists. Used to read optional / required
/// single-child elements per `xsd:sequence` ordering.
fn wml_ct_chunk6_first_child(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  let mut found : @xml.Element? = None
  for child in element.children {
    if found is None {
      match child {
        @xml.Node::Element(e) =>
          if e.name.local_name == local_name {
            found = Some(e)
          }
        _ => ()
      }
    }
  }
  found
}

///|
/// All direct element children of `element` whose local name equals
/// `local_name`, returned in document order. Used to read
/// `maxOccurs="unbounded"` payloads.
fn wml_ct_chunk6_children(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Node::Element(e) =>
        if e.name.local_name == local_name {
          out.push(e)
        }
      _ => ()
    }
  }
  out
}

///|
/// All direct element children of `element`, in document order. Used
/// for CT types whose schema content is an `xsd:group` over a model
/// group (e.g. EG_BlockLevelElts, EG_ContentCellContent) where the
/// typed projection is decoded by upstream readers.
fn wml_ct_chunk6_element_children(
  element : @xml.Element,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Node::Element(e) => out.push(e)
      _ => ()
    }
  }
  out
}
