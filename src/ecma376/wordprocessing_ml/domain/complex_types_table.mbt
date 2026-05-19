// WordprocessingML chunk6 typed complex types — wml.xsd §17.4 (Tables)
// CT_* wrappers covering table widths, the grid, cell properties, row
// properties, cell content and conditional-format markers. Each former
// `element : @xml.Element` wrapper is replaced with a typed projection
// of every XSD attribute and child element declared by Part 4 / wml.xsd.
// The source `<w:...>` element is preserved alongside the typed fields
// so the builder can still round-trip unchanged markup. Free-content
// groups (EG_BlockLevelElts, EG_ContentCellContent, EG_CellMarkupElements)
// are kept as `Array[@xml.Element]` because their element-level choices
// are decoded by upstream readers; the typed projection here covers the
// attributes and the named single-element children declared by §17.4.

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

///|
/// XSD complex type CT_TblWidth — Part 1 §17.18.90 (table width
/// measurement). Two optional attributes: `@w` (ST_MeasurementOrPercent
/// §17.18.107) carries the measurement value and `@type` (ST_TblWidth
/// §17.18.90) selects how it is interpreted (`nil`, `pct`, `dxa`, `auto`).
pub(all) struct CT_TblWidth {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.107 @w (ST_MeasurementOrPercent) — optional width value.
  w : ST_MeasurementOrPercent?
  /// §17.18.90 @type (ST_TblWidth) — optional unit kind.
  type_ : ST_TblWidth?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblWidth — Part 1 §17.18.90. Decode both
/// optional attributes; either may be omitted.
pub fn CT_TblWidth::new(
  element : @xml.Element,
) -> CT_TblWidth raise SchemaViolation {
  let w = match wml_ct_chunk6_attr(element, "w") {
    Some(text) => Some(ST_MeasurementOrPercent::parse(text))
    None => None
  }
  let type_ = match wml_ct_chunk6_attr(element, "type") {
    Some(text) => Some(ST_TblWidth::parse(text))
    None => None
  }
  { element, w, type_ }
}

///|
/// XSD complex type CT_TblWidth — Part 1 §17.18.90.
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
/// XSD complex type CT_TblGridCol — Part 1 §17.4.16 (gridCol Grid
/// Column Definition). Single optional `@w` attribute (s:ST_TwipsMeasure
/// §22.9.2.10) giving the column width in twentieths of a point.
pub(all) struct CT_TblGridCol {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.10 @w (s:ST_TwipsMeasure) — optional column width lexical.
  w : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblGridCol — Part 1 §17.4.16.
pub fn CT_TblGridCol::new(element : @xml.Element) -> CT_TblGridCol {
  let w = wml_ct_chunk6_attr(element, "w")
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
/// XSD complex type CT_TblGridBase — Part 1 §17.4.49 (tblGrid base type).
/// Sequence of zero-or-more `<w:gridCol>` (CT_TblGridCol per §17.4.16)
/// children describing each column width.
pub(all) struct CT_TblGridBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.16 `<w:gridCol>` (CT_TblGridCol)* — column width entries.
  grid_cols : Array[CT_TblGridCol]
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblGridBase — Part 1 §17.4.49.
pub fn CT_TblGridBase::new(element : @xml.Element) -> CT_TblGridBase {
  let grid_cols : Array[CT_TblGridCol] = []
  for child in wml_ct_chunk6_children(element, "gridCol") {
    grid_cols.push(CT_TblGridCol::new(child))
  }
  { element, grid_cols }
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
/// XSD complex type CT_TblGrid — Part 1 §17.4.49 (tblGrid Table Grid).
/// Extends CT_TblGridBase by appending an optional `<w:tblGridChange>`
/// (CT_TblGridChange per §17.13.5.10) revision marker.
pub(all) struct CT_TblGrid {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.16 `<w:gridCol>` (CT_TblGridCol)* — inherited column widths.
  grid_cols : Array[CT_TblGridCol]
  /// §17.13.5.10 `<w:tblGridChange>` (CT_TblGridChange) — optional revision.
  tbl_grid_change : CT_TblGridChange?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblGrid — Part 1 §17.4.49. Decode the inherited
/// `<w:gridCol>` children and the optional `<w:tblGridChange>`,
/// propagating SchemaViolation from CT_TblGridChange.
pub fn CT_TblGrid::new(
  element : @xml.Element,
) -> CT_TblGrid raise SchemaViolation {
  let grid_cols : Array[CT_TblGridCol] = []
  for child in wml_ct_chunk6_children(element, "gridCol") {
    grid_cols.push(CT_TblGridCol::new(child))
  }
  let tbl_grid_change = match
    wml_ct_chunk6_first_child(element, "tblGridChange") {
    Some(child) => Some(CT_TblGridChange::new(child))
    None => None
  }
  { element, grid_cols, tbl_grid_change }
}

///|
/// XSD complex type CT_TblGrid — Part 1 §17.4.49.
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
/// XSD complex type CT_TcBorders — Part 1 §17.4.66 (tcBorders Table Cell
/// Borders). Sequence of up to eight optional `<w:...>` border children
/// (each CT_Border per §17.3.4.3): `top / start / bottom / end /
/// insideH / insideV / tl2br / tr2bl`.
pub(all) struct CT_TcBorders {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.3.4.3 `<w:top>` (CT_Border) — top border.
  top : CT_Border?
  /// §17.3.4.3 `<w:start>` (CT_Border) — leading border.
  start : CT_Border?
  /// §17.3.4.3 `<w:bottom>` (CT_Border) — bottom border.
  bottom : CT_Border?
  /// §17.3.4.3 `<w:end>` (CT_Border) — trailing border.
  end_ : CT_Border?
  /// §17.3.4.3 `<w:insideH>` (CT_Border) — inside-horizontal border.
  inside_h : CT_Border?
  /// §17.3.4.3 `<w:insideV>` (CT_Border) — inside-vertical border.
  inside_v : CT_Border?
  /// §17.3.4.3 `<w:tl2br>` (CT_Border) — top-left to bottom-right diagonal.
  tl2br : CT_Border?
  /// §17.3.4.3 `<w:tr2bl>` (CT_Border) — top-right to bottom-left diagonal.
  tr2bl : CT_Border?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TcBorders — Part 1 §17.4.66.
pub fn CT_TcBorders::new(
  element : @xml.Element,
) -> CT_TcBorders raise SchemaViolation {
  let top = match wml_ct_chunk6_first_child(element, "top") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let start = match wml_ct_chunk6_first_child(element, "start") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let bottom = match wml_ct_chunk6_first_child(element, "bottom") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let end_ = match wml_ct_chunk6_first_child(element, "end") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let inside_h = match wml_ct_chunk6_first_child(element, "insideH") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let inside_v = match wml_ct_chunk6_first_child(element, "insideV") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let tl2br = match wml_ct_chunk6_first_child(element, "tl2br") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let tr2bl = match wml_ct_chunk6_first_child(element, "tr2bl") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  { element, top, start, bottom, end_, inside_h, inside_v, tl2br, tr2bl }
}

///|
/// XSD complex type CT_TcBorders — Part 1 §17.4.66.
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
/// XSD complex type CT_TcMar — Part 1 §17.4.68 (tcMar Cell Margin
/// Defaults). Sequence of four optional table-width children (each
/// CT_TblWidth per §17.18.90): `top / start / bottom / end`.
pub(all) struct CT_TcMar {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.90 `<w:top>` (CT_TblWidth) — top cell margin.
  top : CT_TblWidth?
  /// §17.18.90 `<w:start>` (CT_TblWidth) — leading cell margin.
  start : CT_TblWidth?
  /// §17.18.90 `<w:bottom>` (CT_TblWidth) — bottom cell margin.
  bottom : CT_TblWidth?
  /// §17.18.90 `<w:end>` (CT_TblWidth) — trailing cell margin.
  end_ : CT_TblWidth?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TcMar — Part 1 §17.4.68.
pub fn CT_TcMar::new(element : @xml.Element) -> CT_TcMar raise SchemaViolation {
  let top = match wml_ct_chunk6_first_child(element, "top") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let start = match wml_ct_chunk6_first_child(element, "start") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let bottom = match wml_ct_chunk6_first_child(element, "bottom") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let end_ = match wml_ct_chunk6_first_child(element, "end") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  { element, top, start, bottom, end_ }
}

///|
/// XSD complex type CT_TcMar — Part 1 §17.4.68.
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
/// XSD complex type CT_VMerge — Part 1 §17.4.84 (vMerge Vertically
/// Merged Cell). Optional `@val` ST_Merge (Part 1 §17.18.57) selects
/// `continue` (cell is part of an existing merge) or `restart` (cell
/// begins a new merge); omission means the default `continue`.
pub(all) struct CT_VMerge {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.57 @val (ST_Merge) — optional merge state.
  val : ST_Merge?
} derive(Eq, Debug)

///|
/// XSD complex type CT_VMerge — Part 1 §17.4.84.
pub fn CT_VMerge::new(
  element : @xml.Element,
) -> CT_VMerge raise SchemaViolation {
  let val = match wml_ct_chunk6_attr(element, "val") {
    Some(text) => Some(ST_Merge::parse(text))
    None => None
  }
  { element, val }
}

///|
/// XSD complex type CT_VMerge — Part 1 §17.4.84.
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
/// XSD complex type CT_TcPrBase — Part 1 §17.4.71 (tcPr Table Cell
/// Properties base). Sequence of thirteen optional table-cell property
/// children: conditional-format style, cell width, grid span, vertical
/// merge, borders, shading, no-wrap, margins, text direction, fit-text,
/// vertical alignment, hide-mark, and a `<w:headers>` group binding.
pub(all) struct CT_TcPrBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.7 `<w:cnfStyle>` (CT_Cnf) — optional conditional-format flags.
  cnf_style : CT_Cnf?
  /// §17.18.90 `<w:tcW>` (CT_TblWidth) — preferred cell width.
  tc_w : CT_TblWidth?
  /// §17.18.10 `<w:gridSpan>` (CT_DecimalNumber) — number of grid columns spanned.
  grid_span : CT_DecimalNumber?
  /// §17.4.84 `<w:vMerge>` (CT_VMerge) — vertical merge state.
  v_merge : CT_VMerge?
  /// §17.4.66 `<w:tcBorders>` (CT_TcBorders) — overriding cell borders.
  tc_borders : CT_TcBorders?
  /// §17.3.5 `<w:shd>` (CT_Shd) — cell shading.
  shd : CT_Shd?
  /// §17.17.4 `<w:noWrap>` (CT_OnOff) — disable wrap inside the cell.
  no_wrap : CT_OnOff?
  /// §17.4.68 `<w:tcMar>` (CT_TcMar) — cell-margin overrides.
  tc_mar : CT_TcMar?
  /// §17.3.1.41 `<w:textDirection>` (CT_TextDirection) — text direction.
  text_direction : CT_TextDirection?
  /// §17.17.4 `<w:tcFitText>` (CT_OnOff) — fit-text-to-cell flag.
  tc_fit_text : CT_OnOff?
  /// §17.4.83 `<w:vAlign>` (CT_VerticalJc) — vertical justification.
  v_align : CT_VerticalJc?
  /// §17.17.4 `<w:hideMark>` (CT_OnOff) — hide cell mark flag.
  hide_mark : CT_OnOff?
  /// §17.4.18 `<w:headers>` (CT_Headers) — accessibility header bindings.
  headers : CT_Headers?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TcPrBase — Part 1 §17.4.71.
pub fn CT_TcPrBase::new(
  element : @xml.Element,
) -> CT_TcPrBase raise SchemaViolation {
  let cnf_style = match wml_ct_chunk6_first_child(element, "cnfStyle") {
    Some(child) => Some(CT_Cnf::new(child))
    None => None
  }
  let tc_w = match wml_ct_chunk6_first_child(element, "tcW") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let grid_span = match wml_ct_chunk6_first_child(element, "gridSpan") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let v_merge = match wml_ct_chunk6_first_child(element, "vMerge") {
    Some(child) => Some(CT_VMerge::new(child))
    None => None
  }
  let tc_borders = match wml_ct_chunk6_first_child(element, "tcBorders") {
    Some(child) => Some(CT_TcBorders::new(child))
    None => None
  }
  let shd = match wml_ct_chunk6_first_child(element, "shd") {
    Some(child) => Some(CT_Shd::new(child))
    None => None
  }
  let no_wrap = match wml_ct_chunk6_first_child(element, "noWrap") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let tc_mar = match wml_ct_chunk6_first_child(element, "tcMar") {
    Some(child) => Some(CT_TcMar::new(child))
    None => None
  }
  let text_direction = match
    wml_ct_chunk6_first_child(element, "textDirection") {
    Some(child) => Some(CT_TextDirection::new(child))
    None => None
  }
  let tc_fit_text = match wml_ct_chunk6_first_child(element, "tcFitText") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let v_align = match wml_ct_chunk6_first_child(element, "vAlign") {
    Some(child) => Some(CT_VerticalJc::new(child))
    None => None
  }
  let hide_mark = match wml_ct_chunk6_first_child(element, "hideMark") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let headers = match wml_ct_chunk6_first_child(element, "headers") {
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
/// XSD complex type CT_TcPrBase — Part 1 §17.4.71.
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
/// XSD complex type CT_TcPrInner — Part 1 §17.4.72 (tcPr Properties).
/// Extends CT_TcPrBase with the EG_CellMarkupElements model-group whose
/// element-level decoding is owned by upstream readers (rev/cell-merge
/// markers under §17.13). The base attributes/children remain inherited.
pub(all) struct CT_TcPrInner {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.71 inherited base properties.
  base : CT_TcPrBase
  /// §17.13 EG_CellMarkupElements — cell-merge revision markers in document order.
  cell_markup_elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_TcPrInner — Part 1 §17.4.72.
pub fn CT_TcPrInner::new(
  element : @xml.Element,
) -> CT_TcPrInner raise SchemaViolation {
  let base = CT_TcPrBase::new(element)
  let cell_markup_elements : Array[@xml.Element] = []
  for child in wml_ct_chunk6_element_children(element) {
    let ln = child.name.local_name
    if ln == "cellIns" || ln == "cellDel" || ln == "cellMerge" {
      cell_markup_elements.push(child)
    }
  }
  { element, base, cell_markup_elements }
}

///|
/// XSD complex type CT_TcPrInner — Part 1 §17.4.72.
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
/// XSD complex type CT_TcPr — Part 1 §17.4.70 (tcPr Cell Properties).
/// Extends CT_TcPrInner with an optional `<w:tcPrChange>` (CT_TcPrChange
/// per §17.13.5.36) carrying revision history for the cell properties.
pub(all) struct CT_TcPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.72 inherited inner cell properties.
  inner : CT_TcPrInner
  /// §17.13.5.36 `<w:tcPrChange>` (CT_TcPrChange) — optional revision marker.
  tc_pr_change : CT_TcPrChange?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TcPr — Part 1 §17.4.70.
pub fn CT_TcPr::new(element : @xml.Element) -> CT_TcPr raise SchemaViolation {
  let inner = CT_TcPrInner::new(element)
  let tc_pr_change = match wml_ct_chunk6_first_child(element, "tcPrChange") {
    Some(child) => Some(CT_TcPrChange::new(child))
    None => None
  }
  { element, inner, tc_pr_change }
}

///|
/// XSD complex type CT_TcPr — Part 1 §17.4.70.
pub fn CT_TcPr::parse(element : @xml.Element) -> CT_TcPr raise SchemaViolation {
  CT_TcPr::new(element)
}

///|
pub fn CT_TcPr::to_element(self : CT_TcPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Tc — Part 1 §17.4.65 (tc Table Cell). Optional
/// `<w:tcPr>` (CT_TcPr per §17.4.70) carries the cell properties; one
/// or more EG_BlockLevelElts children supply the cell content. Optional
/// `@id` (s:ST_String §22.9.2.13) records a stable cell identifier.
pub(all) struct CT_Tc {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @id (s:ST_String) — optional persistent cell identifier.
  id : String?
  /// §17.4.70 `<w:tcPr>` (CT_TcPr) — optional cell properties.
  tc_pr : CT_TcPr?
  /// §17.* EG_BlockLevelElts — block-level cell content in document order.
  block_level_elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Tc — Part 1 §17.4.65.
pub fn CT_Tc::new(element : @xml.Element) -> CT_Tc raise SchemaViolation {
  let id = wml_ct_chunk6_attr(element, "id")
  let tc_pr = match wml_ct_chunk6_first_child(element, "tcPr") {
    Some(child) => Some(CT_TcPr::new(child))
    None => None
  }
  let block_level_elements : Array[@xml.Element] = []
  for child in wml_ct_chunk6_element_children(element) {
    if child.name.local_name != "tcPr" {
      block_level_elements.push(child)
    }
  }
  { element, id, tc_pr, block_level_elements }
}

///|
/// XSD complex type CT_Tc — Part 1 §17.4.65.
pub fn CT_Tc::parse(element : @xml.Element) -> CT_Tc raise SchemaViolation {
  CT_Tc::new(element)
}

///|
pub fn CT_Tc::to_element(self : CT_Tc) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Cnf — Part 1 §17.4.7 (cnfStyle Conditional
/// Formatting). Twelve optional s:ST_OnOff (§22.9.2.7) attributes
/// flagging whether each conditional-format facet applies to the row,
/// column or corner cell. Each attribute defaults to "not applied" when
/// omitted.
pub(all) struct CT_Cnf {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @firstRow (s:ST_OnOff) — first-row formatting flag.
  first_row : Bool?
  /// §22.9.2.7 @lastRow (s:ST_OnOff) — last-row formatting flag.
  last_row : Bool?
  /// §22.9.2.7 @firstColumn (s:ST_OnOff) — first-column formatting flag.
  first_column : Bool?
  /// §22.9.2.7 @lastColumn (s:ST_OnOff) — last-column formatting flag.
  last_column : Bool?
  /// §22.9.2.7 @oddVBand (s:ST_OnOff) — odd vertical band flag.
  odd_v_band : Bool?
  /// §22.9.2.7 @evenVBand (s:ST_OnOff) — even vertical band flag.
  even_v_band : Bool?
  /// §22.9.2.7 @oddHBand (s:ST_OnOff) — odd horizontal band flag.
  odd_h_band : Bool?
  /// §22.9.2.7 @evenHBand (s:ST_OnOff) — even horizontal band flag.
  even_h_band : Bool?
  /// §22.9.2.7 @firstRowFirstColumn (s:ST_OnOff) — top-left corner flag.
  first_row_first_column : Bool?
  /// §22.9.2.7 @firstRowLastColumn (s:ST_OnOff) — top-right corner flag.
  first_row_last_column : Bool?
  /// §22.9.2.7 @lastRowFirstColumn (s:ST_OnOff) — bottom-left corner flag.
  last_row_first_column : Bool?
  /// §22.9.2.7 @lastRowLastColumn (s:ST_OnOff) — bottom-right corner flag.
  last_row_last_column : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Cnf — Part 1 §17.4.7.
pub fn CT_Cnf::new(element : @xml.Element) -> CT_Cnf {
  let first_row = wml_ct_chunk6_on_off(wml_ct_chunk6_attr(element, "firstRow"))
  let last_row = wml_ct_chunk6_on_off(wml_ct_chunk6_attr(element, "lastRow"))
  let first_column = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "firstColumn"),
  )
  let last_column = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "lastColumn"),
  )
  let odd_v_band = wml_ct_chunk6_on_off(wml_ct_chunk6_attr(element, "oddVBand"))
  let even_v_band = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "evenVBand"),
  )
  let odd_h_band = wml_ct_chunk6_on_off(wml_ct_chunk6_attr(element, "oddHBand"))
  let even_h_band = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "evenHBand"),
  )
  let first_row_first_column = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "firstRowFirstColumn"),
  )
  let first_row_last_column = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "firstRowLastColumn"),
  )
  let last_row_first_column = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "lastRowFirstColumn"),
  )
  let last_row_last_column = wml_ct_chunk6_on_off(
    wml_ct_chunk6_attr(element, "lastRowLastColumn"),
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
/// XSD complex type CT_TrPrBase — Part 1 §17.4.81 (trPr Table Row
/// Properties base). xsd:choice over twelve optional children allowing
/// any of: conditional-format style, division id, grid before/after,
/// leading/trailing width, can't-split flag, row height, header flag,
/// row cell-spacing, row justification, hidden flag.
pub(all) struct CT_TrPrBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.4.7 `<w:cnfStyle>` (CT_Cnf) — conditional formatting.
  cnf_style : CT_Cnf?
  /// §17.18.10 `<w:divId>` (CT_DecimalNumber) — row division id.
  div_id : CT_DecimalNumber?
  /// §17.18.10 `<w:gridBefore>` (CT_DecimalNumber) — leading grid columns skipped.
  grid_before : CT_DecimalNumber?
  /// §17.18.10 `<w:gridAfter>` (CT_DecimalNumber) — trailing grid columns skipped.
  grid_after : CT_DecimalNumber?
  /// §17.18.90 `<w:wBefore>` (CT_TblWidth) — leading width.
  w_before : CT_TblWidth?
  /// §17.18.90 `<w:wAfter>` (CT_TblWidth) — trailing width.
  w_after : CT_TblWidth?
  /// §17.17.4 `<w:cantSplit>` (CT_OnOff) — disallow row split across pages.
  cant_split : CT_OnOff?
  /// §17.4.79 `<w:trHeight>` (CT_Height) — row height.
  tr_height : CT_Height?
  /// §17.17.4 `<w:tblHeader>` (CT_OnOff) — row is a table header.
  tbl_header : CT_OnOff?
  /// §17.18.90 `<w:tblCellSpacing>` (CT_TblWidth) — row cell spacing.
  tbl_cell_spacing : CT_TblWidth?
  /// §17.4.27 `<w:jc>` (CT_JcTable) — row justification.
  jc : CT_JcTable?
  /// §17.17.4 `<w:hidden>` (CT_OnOff) — row hidden flag.
  hidden : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrPrBase — Part 1 §17.4.81.
pub fn CT_TrPrBase::new(
  element : @xml.Element,
) -> CT_TrPrBase raise SchemaViolation {
  let cnf_style = match wml_ct_chunk6_first_child(element, "cnfStyle") {
    Some(child) => Some(CT_Cnf::new(child))
    None => None
  }
  let div_id = match wml_ct_chunk6_first_child(element, "divId") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let grid_before = match wml_ct_chunk6_first_child(element, "gridBefore") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let grid_after = match wml_ct_chunk6_first_child(element, "gridAfter") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let w_before = match wml_ct_chunk6_first_child(element, "wBefore") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let w_after = match wml_ct_chunk6_first_child(element, "wAfter") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let cant_split = match wml_ct_chunk6_first_child(element, "cantSplit") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let tr_height = match wml_ct_chunk6_first_child(element, "trHeight") {
    Some(child) => Some(CT_Height::new(child))
    None => None
  }
  let tbl_header = match wml_ct_chunk6_first_child(element, "tblHeader") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let tbl_cell_spacing = match
    wml_ct_chunk6_first_child(element, "tblCellSpacing") {
    Some(child) => Some(CT_TblWidth::new(child))
    None => None
  }
  let jc = match wml_ct_chunk6_first_child(element, "jc") {
    Some(child) => Some(CT_JcTable::new(child))
    None => None
  }
  let hidden = match wml_ct_chunk6_first_child(element, "hidden") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
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
/// XSD complex type CT_TrPrBase — Part 1 §17.4.81.
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
/// XSD complex type CT_TrPr from wml.xsd (§17).
pub(all) struct CT_TrPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrPr::new(element : @xml.Element) -> CT_TrPr {
  { element, }
}

///|
pub fn CT_TrPr::parse(element : @xml.Element) -> CT_TrPr {
  CT_TrPr::new(element)
}

///|
pub fn CT_TrPr::to_element(self : CT_TrPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Row from wml.xsd (§17).
pub(all) struct CT_Row {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Row::new(element : @xml.Element) -> CT_Row {
  { element, }
}

///|
pub fn CT_Row::parse(element : @xml.Element) -> CT_Row {
  CT_Row::new(element)
}

///|
pub fn CT_Row::to_element(self : CT_Row) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblLayoutType from wml.xsd (§17).
pub(all) struct CT_TblLayoutType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblLayoutType::new(element : @xml.Element) -> CT_TblLayoutType {
  { element, }
}

///|
pub fn CT_TblLayoutType::parse(element : @xml.Element) -> CT_TblLayoutType {
  CT_TblLayoutType::new(element)
}

///|
pub fn CT_TblLayoutType::to_element(self : CT_TblLayoutType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblOverlap from wml.xsd (§17).
pub(all) struct CT_TblOverlap {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblOverlap::new(element : @xml.Element) -> CT_TblOverlap {
  { element, }
}

///|
pub fn CT_TblOverlap::parse(element : @xml.Element) -> CT_TblOverlap {
  CT_TblOverlap::new(element)
}

///|
pub fn CT_TblOverlap::to_element(self : CT_TblOverlap) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPPr from wml.xsd (§17).
pub(all) struct CT_TblPPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPPr::new(element : @xml.Element) -> CT_TblPPr {
  { element, }
}

///|
pub fn CT_TblPPr::parse(element : @xml.Element) -> CT_TblPPr {
  CT_TblPPr::new(element)
}

///|
pub fn CT_TblPPr::to_element(self : CT_TblPPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblCellMar from wml.xsd (§17).
pub(all) struct CT_TblCellMar {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblCellMar::new(element : @xml.Element) -> CT_TblCellMar {
  { element, }
}

///|
pub fn CT_TblCellMar::parse(element : @xml.Element) -> CT_TblCellMar {
  CT_TblCellMar::new(element)
}

///|
pub fn CT_TblCellMar::to_element(self : CT_TblCellMar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblBorders from wml.xsd (§17).
pub(all) struct CT_TblBorders {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblBorders::new(element : @xml.Element) -> CT_TblBorders {
  { element, }
}

///|
pub fn CT_TblBorders::parse(element : @xml.Element) -> CT_TblBorders {
  CT_TblBorders::new(element)
}

///|
pub fn CT_TblBorders::to_element(self : CT_TblBorders) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrBase from wml.xsd (§17).
pub(all) struct CT_TblPrBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPrBase::new(element : @xml.Element) -> CT_TblPrBase {
  { element, }
}

///|
pub fn CT_TblPrBase::parse(element : @xml.Element) -> CT_TblPrBase {
  CT_TblPrBase::new(element)
}

///|
pub fn CT_TblPrBase::to_element(self : CT_TblPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPr from wml.xsd (§17).
pub(all) struct CT_TblPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPr::new(element : @xml.Element) -> CT_TblPr {
  { element, }
}

///|
pub fn CT_TblPr::parse(element : @xml.Element) -> CT_TblPr {
  CT_TblPr::new(element)
}

///|
pub fn CT_TblPr::to_element(self : CT_TblPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrExBase from wml.xsd (§17).
pub(all) struct CT_TblPrExBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPrExBase::new(element : @xml.Element) -> CT_TblPrExBase {
  { element, }
}

///|
pub fn CT_TblPrExBase::parse(element : @xml.Element) -> CT_TblPrExBase {
  CT_TblPrExBase::new(element)
}

///|
pub fn CT_TblPrExBase::to_element(self : CT_TblPrExBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrEx from wml.xsd (§17).
pub(all) struct CT_TblPrEx {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPrEx::new(element : @xml.Element) -> CT_TblPrEx {
  { element, }
}

///|
pub fn CT_TblPrEx::parse(element : @xml.Element) -> CT_TblPrEx {
  CT_TblPrEx::new(element)
}

///|
pub fn CT_TblPrEx::to_element(self : CT_TblPrEx) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Tbl from wml.xsd (§17).
pub(all) struct CT_Tbl {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Tbl::new(element : @xml.Element) -> CT_Tbl {
  { element, }
}

///|
pub fn CT_Tbl::parse(element : @xml.Element) -> CT_Tbl {
  CT_Tbl::new(element)
}

///|
pub fn CT_Tbl::to_element(self : CT_Tbl) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblLook from wml.xsd (§17).
pub(all) struct CT_TblLook {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblLook::new(element : @xml.Element) -> CT_TblLook {
  { element, }
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
/// XSD complex type CT_TblStylePr from wml.xsd (§17).
pub(all) struct CT_TblStylePr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblStylePr::new(element : @xml.Element) -> CT_TblStylePr {
  { element, }
}

///|
pub fn CT_TblStylePr::parse(element : @xml.Element) -> CT_TblStylePr {
  CT_TblStylePr::new(element)
}

///|
pub fn CT_TblStylePr::to_element(self : CT_TblStylePr) -> @xml.Element {
  self.element
}
