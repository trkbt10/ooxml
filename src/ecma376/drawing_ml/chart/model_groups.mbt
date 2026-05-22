// ECMA-376 DrawingML chart §21.2 / chartDrawing §21.3 model groups.
// All <xsd:group> declarations from dml-chart.xsd / dml-chartDrawing.xsd
// rendered as Moonbit sum types (choice) or structs (sequence) so
// readers branch on the typed schema arm rather than re-walking
// raw XML.

// ─────────────────────────────────────────────────────────────────────
// EG_DLblShared — §21.2 dml-chart.xsd. Sequence of 11 optional members
// (numFmt / spPr / txPr / dLblPos / showLegendKey / showVal /
// showCatName / showSerName / showPercent / showBubbleSize / separator).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_DLblShared {
  num_fmt : CT_NumFmt?
  sp_pr : @a.CT_ShapeProperties?
  tx_pr : @a.CT_TextBody?
  d_lbl_pos : CT_DLblPos?
  show_legend_key : CT_Boolean?
  show_val : CT_Boolean?
  show_cat_name : CT_Boolean?
  show_ser_name : CT_Boolean?
  show_percent : CT_Boolean?
  show_bubble_size : CT_Boolean?
  separator : String?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// Group_DLbl — §21.2. Sequence (layout? / tx? / EG_DLblShared).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct Group_DLbl {
  layout : CT_Layout?
  tx : CT_Tx?
  shared : EG_DLblShared
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// Group_DLbls — §21.2. Sequence (EG_DLblShared / showLeaderLines? /
// leaderLines?).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct Group_DLbls {
  shared : EG_DLblShared
  show_leader_lines : CT_Boolean?
  leader_lines : CT_ChartLines?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_SerShared — §21.2. Sequence (idx / order / tx? / spPr?).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_SerShared {
  idx : CT_UnsignedInt
  order : CT_UnsignedInt
  tx : CT_SerTx?
  sp_pr : @a.CT_ShapeProperties?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_LineChartShared — §21.2. Sequence (grouping / varyColors? /
// ser* / dLbls? / dropLines?).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_LineChartShared {
  grouping : CT_Grouping
  vary_colors : CT_Boolean?
  ser : Array[CT_LineSer]
  d_lbls : CT_DLbls?
  drop_lines : CT_ChartLines?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_BarChartShared — §21.2. Sequence (barDir / grouping? / varyColors? /
// ser* / dLbls?).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_BarChartShared {
  bar_dir : CT_BarDir
  grouping : CT_BarGrouping?
  vary_colors : CT_Boolean?
  ser : Array[CT_BarSer]
  d_lbls : CT_DLbls?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_AreaChartShared — §21.2.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_AreaChartShared {
  grouping : CT_Grouping?
  vary_colors : CT_Boolean?
  ser : Array[CT_AreaSer]
  d_lbls : CT_DLbls?
  drop_lines : CT_ChartLines?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_PieChartShared — §21.2.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_PieChartShared {
  vary_colors : CT_Boolean?
  ser : Array[CT_PieSer]
  d_lbls : CT_DLbls?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_SurfaceChartShared — §21.2.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_SurfaceChartShared {
  wireframe : CT_Boolean?
  ser : Array[CT_SurfaceSer]
  band_fmts : CT_BandFmts?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_AxShared — §21.2. Sequence (axId / scaling / delete? / axPos /
// majorGridlines? / minorGridlines? / title? / numFmt? / majorTickMark? /
// minorTickMark? / tickLblPos? / spPr? / txPr? / crossAx /
// choice<crosses | crossesAt>?).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum CrossesOrAt {
  Crosses(CT_Crosses)
  CrossesAt(CT_Double)
} derive(Eq, Debug)

///|
pub(all) struct EG_AxShared {
  ax_id : CT_UnsignedInt
  scaling : CT_Scaling
  delete_ : CT_Boolean?
  ax_pos : CT_AxPos
  major_gridlines : CT_ChartLines?
  minor_gridlines : CT_ChartLines?
  title : CT_Title?
  num_fmt : CT_NumFmt?
  major_tick_mark : CT_TickMark?
  minor_tick_mark : CT_TickMark?
  tick_lbl_pos : CT_TickLblPos?
  sp_pr : @a.CT_ShapeProperties?
  tx_pr : @a.CT_TextBody?
  cross_ax : CT_UnsignedInt
  crosses_choice : CrossesOrAt?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_LegendEntryData — §21.2. Sequence with single optional txPr.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_LegendEntryData {
  tx_pr : @a.CT_TextBody?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_ObjectChoices — §21.3 dml-chartDrawing.xsd. Required choice of
// sp / grpSp / graphicFrame / cxnSp / pic.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_ObjectChoices {
  Sp(CT_Shape)
  GrpSp(CT_GroupShape)
  GraphicFrame(CT_GraphicFrame)
  CxnSp(CT_Connector)
  Pic(CT_Picture)
} derive(Eq, Debug)

///|
pub fn parse_object_choice_element(
  element : @xml.Element,
) -> EG_ObjectChoices? raise SchemaViolation {
  match element.name.local_name {
    "sp" => Some(Sp(CT_Shape::new(element)))
    "grpSp" => Some(GrpSp(CT_GroupShape::new(element)))
    "graphicFrame" => Some(GraphicFrame(CT_GraphicFrame::new(element)))
    "cxnSp" => Some(CxnSp(CT_Connector::new(element)))
    "pic" => Some(Pic(CT_Picture::new(element)))
    _ => None
  }
}

///|
pub fn find_object_choice_child(
  element : @xml.Element,
) -> EG_ObjectChoices? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_object_choice_element(child) {
          Some(c) => return Some(c)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_Anchor — §21.3. Choice of relSizeAnchor / absSizeAnchor.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_Anchor {
  RelSizeAnchor(CT_RelSizeAnchor)
  AbsSizeAnchor(CT_AbsSizeAnchor)
} derive(Eq, Debug)

///|
pub fn parse_anchor_element(
  element : @xml.Element,
) -> EG_Anchor? raise SchemaViolation {
  match element.name.local_name {
    "relSizeAnchor" => Some(RelSizeAnchor(CT_RelSizeAnchor::new(element)))
    "absSizeAnchor" => Some(AbsSizeAnchor(CT_AbsSizeAnchor::new(element)))
    _ => None
  }
}

///|
pub fn collect_anchors(
  element : @xml.Element,
) -> Array[EG_Anchor] raise SchemaViolation {
  let out : Array[EG_Anchor] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_anchor_element(child) {
          Some(a) => out.push(a)
          None => ()
        }
      _ => ()
    }
  }
  out
}
