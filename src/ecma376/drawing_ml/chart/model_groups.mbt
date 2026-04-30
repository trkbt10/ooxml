///|
/// XSD model group EG_DLblShared (§21.2, dml-chart.xsd): choices/sequence members numFmt: CT_NumFmt, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, dLblPos: CT_DLblPos, showLegendKey: CT_Boolean, showVal: CT_Boolean, showCatName: CT_Boolean, showSerName: CT_Boolean, showPercent: CT_Boolean, showBubbleSize: CT_Boolean, separator: xsd:string.
pub(all) struct EG_DLblShared {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_DLblShared from already parsed child elements.
pub fn EG_DLblShared::new(elements : Array[@xml.Element]) -> EG_DLblShared {
  { elements, }
}

///|
/// Count parsed child elements held by EG_DLblShared.
pub fn EG_DLblShared::count(self : EG_DLblShared) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_DLblShared contains a child with the requested local name.
pub fn EG_DLblShared::contains(
  self : EG_DLblShared,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_DLblShared.
pub fn EG_DLblShared::member_names(self : EG_DLblShared) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group Group_DLbl (§21.2, dml-chart.xsd): choices/sequence members layout: CT_Layout, tx: CT_Tx.
pub(all) struct Group_DLbl {
  elements : Array[@xml.Element]
}

///|
/// Construct Group_DLbl from already parsed child elements.
pub fn Group_DLbl::new(elements : Array[@xml.Element]) -> Group_DLbl {
  { elements, }
}

///|
/// Count parsed child elements held by Group_DLbl.
pub fn Group_DLbl::count(self : Group_DLbl) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when Group_DLbl contains a child with the requested local name.
pub fn Group_DLbl::contains(self : Group_DLbl, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of Group_DLbl.
pub fn Group_DLbl::member_names(self : Group_DLbl) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group Group_DLbls (§21.2, dml-chart.xsd): choices/sequence members showLeaderLines: CT_Boolean, leaderLines: CT_ChartLines.
pub(all) struct Group_DLbls {
  elements : Array[@xml.Element]
}

///|
/// Construct Group_DLbls from already parsed child elements.
pub fn Group_DLbls::new(elements : Array[@xml.Element]) -> Group_DLbls {
  { elements, }
}

///|
/// Count parsed child elements held by Group_DLbls.
pub fn Group_DLbls::count(self : Group_DLbls) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when Group_DLbls contains a child with the requested local name.
pub fn Group_DLbls::contains(self : Group_DLbls, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of Group_DLbls.
pub fn Group_DLbls::member_names(self : Group_DLbls) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_SerShared (§21.2, dml-chart.xsd): choices/sequence members idx: CT_UnsignedInt, order: CT_UnsignedInt, tx: CT_SerTx, spPr: a:CT_ShapeProperties.
pub(all) struct EG_SerShared {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_SerShared from already parsed child elements.
pub fn EG_SerShared::new(elements : Array[@xml.Element]) -> EG_SerShared {
  { elements, }
}

///|
/// Count parsed child elements held by EG_SerShared.
pub fn EG_SerShared::count(self : EG_SerShared) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_SerShared contains a child with the requested local name.
pub fn EG_SerShared::contains(self : EG_SerShared, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_SerShared.
pub fn EG_SerShared::member_names(self : EG_SerShared) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_LineChartShared (§21.2, dml-chart.xsd): choices/sequence members grouping: CT_Grouping, varyColors: CT_Boolean, ser: CT_LineSer, dLbls: CT_DLbls, dropLines: CT_ChartLines.
pub(all) struct EG_LineChartShared {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_LineChartShared from already parsed child elements.
pub fn EG_LineChartShared::new(
  elements : Array[@xml.Element],
) -> EG_LineChartShared {
  { elements, }
}

///|
/// Count parsed child elements held by EG_LineChartShared.
pub fn EG_LineChartShared::count(self : EG_LineChartShared) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_LineChartShared contains a child with the requested local name.
pub fn EG_LineChartShared::contains(
  self : EG_LineChartShared,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_LineChartShared.
pub fn EG_LineChartShared::member_names(
  self : EG_LineChartShared,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_BarChartShared (§21.2, dml-chart.xsd): choices/sequence members barDir: CT_BarDir, grouping: CT_BarGrouping, varyColors: CT_Boolean, ser: CT_BarSer, dLbls: CT_DLbls.
pub(all) struct EG_BarChartShared {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_BarChartShared from already parsed child elements.
pub fn EG_BarChartShared::new(
  elements : Array[@xml.Element],
) -> EG_BarChartShared {
  { elements, }
}

///|
/// Count parsed child elements held by EG_BarChartShared.
pub fn EG_BarChartShared::count(self : EG_BarChartShared) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_BarChartShared contains a child with the requested local name.
pub fn EG_BarChartShared::contains(
  self : EG_BarChartShared,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_BarChartShared.
pub fn EG_BarChartShared::member_names(
  self : EG_BarChartShared,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_AreaChartShared (§21.2, dml-chart.xsd): choices/sequence members grouping: CT_Grouping, varyColors: CT_Boolean, ser: CT_AreaSer, dLbls: CT_DLbls, dropLines: CT_ChartLines.
pub(all) struct EG_AreaChartShared {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_AreaChartShared from already parsed child elements.
pub fn EG_AreaChartShared::new(
  elements : Array[@xml.Element],
) -> EG_AreaChartShared {
  { elements, }
}

///|
/// Count parsed child elements held by EG_AreaChartShared.
pub fn EG_AreaChartShared::count(self : EG_AreaChartShared) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_AreaChartShared contains a child with the requested local name.
pub fn EG_AreaChartShared::contains(
  self : EG_AreaChartShared,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_AreaChartShared.
pub fn EG_AreaChartShared::member_names(
  self : EG_AreaChartShared,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_PieChartShared (§21.2, dml-chart.xsd): choices/sequence members varyColors: CT_Boolean, ser: CT_PieSer, dLbls: CT_DLbls.
pub(all) struct EG_PieChartShared {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_PieChartShared from already parsed child elements.
pub fn EG_PieChartShared::new(
  elements : Array[@xml.Element],
) -> EG_PieChartShared {
  { elements, }
}

///|
/// Count parsed child elements held by EG_PieChartShared.
pub fn EG_PieChartShared::count(self : EG_PieChartShared) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_PieChartShared contains a child with the requested local name.
pub fn EG_PieChartShared::contains(
  self : EG_PieChartShared,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_PieChartShared.
pub fn EG_PieChartShared::member_names(
  self : EG_PieChartShared,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_SurfaceChartShared (§21.2, dml-chart.xsd): choices/sequence members wireframe: CT_Boolean, ser: CT_SurfaceSer, bandFmts: CT_BandFmts.
pub(all) struct EG_SurfaceChartShared {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_SurfaceChartShared from already parsed child elements.
pub fn EG_SurfaceChartShared::new(
  elements : Array[@xml.Element],
) -> EG_SurfaceChartShared {
  { elements, }
}

///|
/// Count parsed child elements held by EG_SurfaceChartShared.
pub fn EG_SurfaceChartShared::count(self : EG_SurfaceChartShared) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_SurfaceChartShared contains a child with the requested local name.
pub fn EG_SurfaceChartShared::contains(
  self : EG_SurfaceChartShared,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_SurfaceChartShared.
pub fn EG_SurfaceChartShared::member_names(
  self : EG_SurfaceChartShared,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_AxShared (§21.2, dml-chart.xsd): choices/sequence members axId: CT_UnsignedInt, scaling: CT_Scaling, delete: CT_Boolean, axPos: CT_AxPos, majorGridlines: CT_ChartLines, minorGridlines: CT_ChartLines, title: CT_Title, numFmt: CT_NumFmt, majorTickMark: CT_TickMark, minorTickMark: CT_TickMark, tickLblPos: CT_TickLblPos, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, crossAx: CT_UnsignedInt, crosses: CT_Crosses, crossesAt: CT_Double.
pub(all) struct EG_AxShared {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_AxShared from already parsed child elements.
pub fn EG_AxShared::new(elements : Array[@xml.Element]) -> EG_AxShared {
  { elements, }
}

///|
/// Count parsed child elements held by EG_AxShared.
pub fn EG_AxShared::count(self : EG_AxShared) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_AxShared contains a child with the requested local name.
pub fn EG_AxShared::contains(self : EG_AxShared, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_AxShared.
pub fn EG_AxShared::member_names(self : EG_AxShared) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_LegendEntryData (§21.2, dml-chart.xsd): choices/sequence members txPr: a:CT_TextBody.
pub(all) struct EG_LegendEntryData {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_LegendEntryData from already parsed child elements.
pub fn EG_LegendEntryData::new(
  elements : Array[@xml.Element],
) -> EG_LegendEntryData {
  { elements, }
}

///|
/// Count parsed child elements held by EG_LegendEntryData.
pub fn EG_LegendEntryData::count(self : EG_LegendEntryData) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_LegendEntryData contains a child with the requested local name.
pub fn EG_LegendEntryData::contains(
  self : EG_LegendEntryData,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_LegendEntryData.
pub fn EG_LegendEntryData::member_names(
  self : EG_LegendEntryData,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_ObjectChoices (§21.3, dml-chartDrawing.xsd): choices/sequence members sp: CT_Shape, grpSp: CT_GroupShape, graphicFrame: CT_GraphicFrame, cxnSp: CT_Connector, pic: CT_Picture.
/// ResourceMissing is reported by higher layers when a selected object choice
/// references an external chart drawing resource that is not available.
pub(all) struct EG_ObjectChoices {
  elements : Array[@xml.Element]
}

///|
/// Resource lookup error for chart drawing object choices.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// Construct EG_ObjectChoices from already parsed child elements.
pub fn EG_ObjectChoices::new(
  elements : Array[@xml.Element],
) -> EG_ObjectChoices {
  { elements, }
}

///|
/// Count parsed child elements held by EG_ObjectChoices.
pub fn EG_ObjectChoices::count(self : EG_ObjectChoices) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_ObjectChoices contains a child with the requested local name.
pub fn EG_ObjectChoices::contains(
  self : EG_ObjectChoices,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_ObjectChoices.
pub fn EG_ObjectChoices::member_names(self : EG_ObjectChoices) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_Anchor (§21.3, dml-chartDrawing.xsd): choices/sequence members relSizeAnchor: CT_RelSizeAnchor, absSizeAnchor: CT_AbsSizeAnchor.
pub(all) struct EG_Anchor {
  elements : Array[@xml.Element]
}

///|
/// Construct EG_Anchor from already parsed child elements.
pub fn EG_Anchor::new(elements : Array[@xml.Element]) -> EG_Anchor {
  { elements, }
}

///|
/// Count parsed child elements held by EG_Anchor.
pub fn EG_Anchor::count(self : EG_Anchor) -> Int {
  let mut total = 0
  for _ in self.elements {
    total = total + 1
  }
  total
}

///|
/// Return true when EG_Anchor contains a child with the requested local name.
pub fn EG_Anchor::contains(self : EG_Anchor, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Return local names from the concrete members of EG_Anchor.
pub fn EG_Anchor::member_names(self : EG_Anchor) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}
