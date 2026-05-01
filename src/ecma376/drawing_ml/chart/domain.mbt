///|
/// XSD complex type CT_Boolean (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Boolean {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Double (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Double {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_UnsignedInt (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_UnsignedInt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RelId (§21.2, dml-chart.xsd): attributes r:id; children no local child elements.
pub(all) struct CT_RelId {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Extension (§21.2, dml-chart.xsd): attributes uri; children no local child elements.
pub(all) struct CT_Extension {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ExtensionList (§21.2, dml-chart.xsd): attributes no local attributes; children ext: CT_Extension.
pub(all) struct CT_ExtensionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumVal (§21.2, dml-chart.xsd): attributes idx, formatCode; children v: s:ST_Xstring.
pub(all) struct CT_NumVal {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumData (§21.2, dml-chart.xsd): attributes no local attributes; children formatCode: s:ST_Xstring, ptCount: CT_UnsignedInt, pt: CT_NumVal, extLst: CT_ExtensionList.
pub(all) struct CT_NumData {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumRef (§21.2, dml-chart.xsd): attributes no local attributes; children f: xsd:string, numCache: CT_NumData, extLst: CT_ExtensionList.
pub(all) struct CT_NumRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumDataSource (§21.2, dml-chart.xsd): attributes no local attributes; children numRef: CT_NumRef, numLit: CT_NumData.
pub(all) struct CT_NumDataSource {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_StrVal (§21.2, dml-chart.xsd): attributes idx; children v: s:ST_Xstring.
pub(all) struct CT_StrVal {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_StrData (§21.2, dml-chart.xsd): attributes no local attributes; children ptCount: CT_UnsignedInt, pt: CT_StrVal, extLst: CT_ExtensionList.
pub(all) struct CT_StrData {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_StrRef (§21.2, dml-chart.xsd): attributes no local attributes; children f: xsd:string, strCache: CT_StrData, extLst: CT_ExtensionList.
pub(all) struct CT_StrRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Tx (§21.2, dml-chart.xsd): attributes no local attributes; children strRef: CT_StrRef, rich: a:CT_TextBody.
pub(all) struct CT_Tx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextLanguageID (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TextLanguageID {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Lvl (§21.2, dml-chart.xsd): attributes no local attributes; children pt: CT_StrVal.
pub(all) struct CT_Lvl {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_MultiLvlStrData (§21.2, dml-chart.xsd): attributes no local attributes; children ptCount: CT_UnsignedInt, lvl: CT_Lvl, extLst: CT_ExtensionList.
pub(all) struct CT_MultiLvlStrData {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_MultiLvlStrRef (§21.2, dml-chart.xsd): attributes no local attributes; children f: xsd:string, multiLvlStrCache: CT_MultiLvlStrData, extLst: CT_ExtensionList.
pub(all) struct CT_MultiLvlStrRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AxDataSource (§21.2, dml-chart.xsd): attributes no local attributes; children multiLvlStrRef: CT_MultiLvlStrRef, numRef: CT_NumRef, numLit: CT_NumData, strRef: CT_StrRef, strLit: CT_StrData.
pub(all) struct CT_AxDataSource {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SerTx (§21.2, dml-chart.xsd): attributes no local attributes; children strRef: CT_StrRef, v: s:ST_Xstring.
pub(all) struct CT_SerTx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LayoutTarget (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LayoutTarget {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LayoutMode (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LayoutMode {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ManualLayout (§21.2, dml-chart.xsd): attributes no local attributes; children layoutTarget: CT_LayoutTarget, xMode: CT_LayoutMode, yMode: CT_LayoutMode, wMode: CT_LayoutMode, hMode: CT_LayoutMode, x: CT_Double, y: CT_Double, w: CT_Double, h: CT_Double, extLst: CT_ExtensionList.
pub(all) struct CT_ManualLayout {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Layout (§21.2, dml-chart.xsd): attributes no local attributes; children manualLayout: CT_ManualLayout, extLst: CT_ExtensionList.
pub(all) struct CT_Layout {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Title (§21.2, dml-chart.xsd): attributes no local attributes; children tx: CT_Tx, layout: CT_Layout, overlay: CT_Boolean, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, extLst: CT_ExtensionList.
pub(all) struct CT_Title {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RotX (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_RotX {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_HPercent (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_HPercent {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RotY (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_RotY {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DepthPercent (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_DepthPercent {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Perspective (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Perspective {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_View3D (§21.2, dml-chart.xsd): attributes no local attributes; children rotX: CT_RotX, hPercent: CT_HPercent, rotY: CT_RotY, depthPercent: CT_DepthPercent, rAngAx: CT_Boolean, perspective: CT_Perspective, extLst: CT_ExtensionList.
pub(all) struct CT_View3D {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Surface (§21.2, dml-chart.xsd): attributes no local attributes; children thickness: CT_Thickness, spPr: a:CT_ShapeProperties, pictureOptions: CT_PictureOptions, extLst: CT_ExtensionList.
pub(all) struct CT_Surface {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Thickness (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Thickness {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DTable (§21.2, dml-chart.xsd): attributes no local attributes; children showHorzBorder: CT_Boolean, showVertBorder: CT_Boolean, showOutline: CT_Boolean, showKeys: CT_Boolean, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, extLst: CT_ExtensionList.
pub(all) struct CT_DTable {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GapAmount (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_GapAmount {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Overlap (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Overlap {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BubbleScale (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_BubbleScale {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SizeRepresents (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_SizeRepresents {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_FirstSliceAng (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_FirstSliceAng {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_HoleSize (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_HoleSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SplitType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_SplitType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustSplit (§21.2, dml-chart.xsd): attributes no local attributes; children secondPiePt: CT_UnsignedInt.
pub(all) struct CT_CustSplit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SecondPieSize (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_SecondPieSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumFmt (§21.2, dml-chart.xsd): attributes formatCode, sourceLinked; children no local child elements.
pub(all) struct CT_NumFmt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LblAlgn (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LblAlgn {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DLblPos (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_DLblPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DLbl (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, delete: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_DLbl {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DLbls (§21.2, dml-chart.xsd): attributes no local attributes; children dLbl: CT_DLbl, delete: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_DLbls {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_MarkerStyle (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_MarkerStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_MarkerSize (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_MarkerSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Marker (§21.2, dml-chart.xsd): attributes no local attributes; children symbol: CT_MarkerStyle, size: CT_MarkerSize, spPr: a:CT_ShapeProperties, extLst: CT_ExtensionList.
pub(all) struct CT_Marker {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DPt (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, invertIfNegative: CT_Boolean, marker: CT_Marker, bubble3D: CT_Boolean, explosion: CT_UnsignedInt, spPr: a:CT_ShapeProperties, pictureOptions: CT_PictureOptions, extLst: CT_ExtensionList.
pub(all) struct CT_DPt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrendlineType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TrendlineType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Order (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Order {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Period (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Period {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrendlineLbl (§21.2, dml-chart.xsd): attributes no local attributes; children layout: CT_Layout, tx: CT_Tx, numFmt: CT_NumFmt, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, extLst: CT_ExtensionList.
pub(all) struct CT_TrendlineLbl {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Trendline (§21.2, dml-chart.xsd): attributes no local attributes; children name: xsd:string, spPr: a:CT_ShapeProperties, trendlineType: CT_TrendlineType, order: CT_Order, period: CT_Period, forward: CT_Double, backward: CT_Double, intercept: CT_Double, dispRSqr: CT_Boolean, dispEq: CT_Boolean, trendlineLbl: CT_TrendlineLbl, extLst: CT_ExtensionList.
pub(all) struct CT_Trendline {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ErrDir (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_ErrDir {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ErrBarType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_ErrBarType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ErrValType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_ErrValType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ErrBars (§21.2, dml-chart.xsd): attributes no local attributes; children errDir: CT_ErrDir, errBarType: CT_ErrBarType, errValType: CT_ErrValType, noEndCap: CT_Boolean, plus: CT_NumDataSource, minus: CT_NumDataSource, val: CT_Double, spPr: a:CT_ShapeProperties, extLst: CT_ExtensionList.
pub(all) struct CT_ErrBars {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_UpDownBar (§21.2, dml-chart.xsd): attributes no local attributes; children spPr: a:CT_ShapeProperties.
pub(all) struct CT_UpDownBar {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_UpDownBars (§21.2, dml-chart.xsd): attributes no local attributes; children gapWidth: CT_GapAmount, upBars: CT_UpDownBar, downBars: CT_UpDownBar, extLst: CT_ExtensionList.
pub(all) struct CT_UpDownBars {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LineSer (§21.2, dml-chart.xsd): attributes no local attributes; children marker: CT_Marker, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, cat: CT_AxDataSource, val: CT_NumDataSource, smooth: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_LineSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ScatterSer (§21.2, dml-chart.xsd): attributes no local attributes; children marker: CT_Marker, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, xVal: CT_AxDataSource, yVal: CT_NumDataSource, smooth: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_ScatterSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RadarSer (§21.2, dml-chart.xsd): attributes no local attributes; children marker: CT_Marker, dPt: CT_DPt, dLbls: CT_DLbls, cat: CT_AxDataSource, val: CT_NumDataSource, extLst: CT_ExtensionList.
pub(all) struct CT_RadarSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BarSer (§21.2, dml-chart.xsd): attributes no local attributes; children invertIfNegative: CT_Boolean, pictureOptions: CT_PictureOptions, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, cat: CT_AxDataSource, val: CT_NumDataSource, shape: CT_Shape, extLst: CT_ExtensionList.
pub(all) struct CT_BarSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AreaSer (§21.2, dml-chart.xsd): attributes no local attributes; children pictureOptions: CT_PictureOptions, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, cat: CT_AxDataSource, val: CT_NumDataSource, extLst: CT_ExtensionList.
pub(all) struct CT_AreaSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PieSer (§21.2, dml-chart.xsd): attributes no local attributes; children explosion: CT_UnsignedInt, dPt: CT_DPt, dLbls: CT_DLbls, cat: CT_AxDataSource, val: CT_NumDataSource, extLst: CT_ExtensionList.
pub(all) struct CT_PieSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BubbleSer (§21.2, dml-chart.xsd): attributes no local attributes; children invertIfNegative: CT_Boolean, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, xVal: CT_AxDataSource, yVal: CT_NumDataSource, bubbleSize: CT_NumDataSource, bubble3D: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_BubbleSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SurfaceSer (§21.2, dml-chart.xsd): attributes no local attributes; children cat: CT_AxDataSource, val: CT_NumDataSource, extLst: CT_ExtensionList.
pub(all) struct CT_SurfaceSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Grouping (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Grouping {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ChartLines (§21.2, dml-chart.xsd): attributes no local attributes; children spPr: a:CT_ShapeProperties.
pub(all) struct CT_ChartLines {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LineChart (§21.2, dml-chart.xsd): attributes no local attributes; children hiLowLines: CT_ChartLines, upDownBars: CT_UpDownBars, marker: CT_Boolean, smooth: CT_Boolean, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_LineChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Line3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children gapDepth: CT_GapAmount, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_Line3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_StockChart (§21.2, dml-chart.xsd): attributes no local attributes; children ser: CT_LineSer, dLbls: CT_DLbls, dropLines: CT_ChartLines, hiLowLines: CT_ChartLines, upDownBars: CT_UpDownBars, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_StockChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ScatterStyle (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_ScatterStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ScatterChart (§21.2, dml-chart.xsd): attributes no local attributes; children scatterStyle: CT_ScatterStyle, varyColors: CT_Boolean, ser: CT_ScatterSer, dLbls: CT_DLbls, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_ScatterChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RadarStyle (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_RadarStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RadarChart (§21.2, dml-chart.xsd): attributes no local attributes; children radarStyle: CT_RadarStyle, varyColors: CT_Boolean, ser: CT_RadarSer, dLbls: CT_DLbls, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_RadarChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BarGrouping (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_BarGrouping {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BarDir (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_BarDir {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Shape (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Shape {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BarChart (§21.2, dml-chart.xsd): attributes no local attributes; children gapWidth: CT_GapAmount, overlap: CT_Overlap, serLines: CT_ChartLines, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_BarChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Bar3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children gapWidth: CT_GapAmount, gapDepth: CT_GapAmount, shape: CT_Shape, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_Bar3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AreaChart (§21.2, dml-chart.xsd): attributes no local attributes; children axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_AreaChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Area3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children gapDepth: CT_GapAmount, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_Area3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PieChart (§21.2, dml-chart.xsd): attributes no local attributes; children firstSliceAng: CT_FirstSliceAng, extLst: CT_ExtensionList.
pub(all) struct CT_PieChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Pie3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children extLst: CT_ExtensionList.
pub(all) struct CT_Pie3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DoughnutChart (§21.2, dml-chart.xsd): attributes no local attributes; children firstSliceAng: CT_FirstSliceAng, holeSize: CT_HoleSize, extLst: CT_ExtensionList.
pub(all) struct CT_DoughnutChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_OfPieType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_OfPieType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_OfPieChart (§21.2, dml-chart.xsd): attributes no local attributes; children ofPieType: CT_OfPieType, gapWidth: CT_GapAmount, splitType: CT_SplitType, splitPos: CT_Double, custSplit: CT_CustSplit, secondPieSize: CT_SecondPieSize, serLines: CT_ChartLines, extLst: CT_ExtensionList.
pub(all) struct CT_OfPieChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BubbleChart (§21.2, dml-chart.xsd): attributes no local attributes; children varyColors: CT_Boolean, ser: CT_BubbleSer, dLbls: CT_DLbls, bubble3D: CT_Boolean, bubbleScale: CT_BubbleScale, showNegBubbles: CT_Boolean, sizeRepresents: CT_SizeRepresents, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_BubbleChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BandFmt (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, spPr: a:CT_ShapeProperties.
pub(all) struct CT_BandFmt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BandFmts (§21.2, dml-chart.xsd): attributes no local attributes; children bandFmt: CT_BandFmt.
pub(all) struct CT_BandFmts {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SurfaceChart (§21.2, dml-chart.xsd): attributes no local attributes; children axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_SurfaceChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Surface3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_Surface3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AxPos (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_AxPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Crosses (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Crosses {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_CrossBetween (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_CrossBetween {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TickMark (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TickMark {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TickLblPos (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TickLblPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Skip (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Skip {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TimeUnit (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TimeUnit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AxisUnit (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_AxisUnit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BuiltInUnit (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_BuiltInUnit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureFormat (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_PictureFormat {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureStackUnit (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_PictureStackUnit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureOptions (§21.2, dml-chart.xsd): attributes no local attributes; children applyToFront: CT_Boolean, applyToSides: CT_Boolean, applyToEnd: CT_Boolean, pictureFormat: CT_PictureFormat, pictureStackUnit: CT_PictureStackUnit.
pub(all) struct CT_PictureOptions {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DispUnitsLbl (§21.2, dml-chart.xsd): attributes no local attributes; children layout: CT_Layout, tx: CT_Tx, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody.
pub(all) struct CT_DispUnitsLbl {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DispUnits (§21.2, dml-chart.xsd): attributes no local attributes; children custUnit: CT_Double, builtInUnit: CT_BuiltInUnit, dispUnitsLbl: CT_DispUnitsLbl, extLst: CT_ExtensionList.
pub(all) struct CT_DispUnits {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Orientation (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Orientation {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LogBase (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LogBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Scaling (§21.2, dml-chart.xsd): attributes no local attributes; children logBase: CT_LogBase, orientation: CT_Orientation, max: CT_Double, min: CT_Double, extLst: CT_ExtensionList.
pub(all) struct CT_Scaling {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LblOffset (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LblOffset {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_CatAx (§21.2, dml-chart.xsd): attributes no local attributes; children auto: CT_Boolean, lblAlgn: CT_LblAlgn, lblOffset: CT_LblOffset, tickLblSkip: CT_Skip, tickMarkSkip: CT_Skip, noMultiLvlLbl: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_CatAx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DateAx (§21.2, dml-chart.xsd): attributes no local attributes; children auto: CT_Boolean, lblOffset: CT_LblOffset, baseTimeUnit: CT_TimeUnit, majorUnit: CT_AxisUnit, majorTimeUnit: CT_TimeUnit, minorUnit: CT_AxisUnit, minorTimeUnit: CT_TimeUnit, extLst: CT_ExtensionList.
pub(all) struct CT_DateAx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SerAx (§21.2, dml-chart.xsd): attributes no local attributes; children tickLblSkip: CT_Skip, tickMarkSkip: CT_Skip, extLst: CT_ExtensionList.
pub(all) struct CT_SerAx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ValAx (§21.2, dml-chart.xsd): attributes no local attributes; children crossBetween: CT_CrossBetween, majorUnit: CT_AxisUnit, minorUnit: CT_AxisUnit, dispUnits: CT_DispUnits, extLst: CT_ExtensionList.
pub(all) struct CT_ValAx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PlotArea (§21.2, dml-chart.xsd): attributes no local attributes; children layout: CT_Layout, areaChart: CT_AreaChart, area3DChart: CT_Area3DChart, lineChart: CT_LineChart, line3DChart: CT_Line3DChart, stockChart: CT_StockChart, radarChart: CT_RadarChart, scatterChart: CT_ScatterChart, pieChart: CT_PieChart, pie3DChart: CT_Pie3DChart, doughnutChart: CT_DoughnutChart, barChart: CT_BarChart, bar3DChart: CT_Bar3DChart, ofPieChart: CT_OfPieChart, surfaceChart: CT_SurfaceChart, surface3DChart: CT_Surface3DChart, bubbleChart: CT_BubbleChart, valAx: CT_ValAx, catAx: CT_CatAx, dateAx: CT_DateAx, serAx: CT_SerAx, dTable: CT_DTable, spPr: a:CT_ShapeProperties, extLst: CT_ExtensionList.
pub(all) struct CT_PlotArea {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PivotFmt (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, marker: CT_Marker, dLbl: CT_DLbl, extLst: CT_ExtensionList.
pub(all) struct CT_PivotFmt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PivotFmts (§21.2, dml-chart.xsd): attributes no local attributes; children pivotFmt: CT_PivotFmt.
pub(all) struct CT_PivotFmts {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LegendPos (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LegendPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LegendEntry (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, delete: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_LegendEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Legend (§21.2, dml-chart.xsd): attributes no local attributes; children legendPos: CT_LegendPos, legendEntry: CT_LegendEntry, layout: CT_Layout, overlay: CT_Boolean, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, extLst: CT_ExtensionList.
pub(all) struct CT_Legend {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DispBlanksAs (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_DispBlanksAs {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Chart (§21.2, dml-chart.xsd): attributes no local attributes; children title: CT_Title, autoTitleDeleted: CT_Boolean, pivotFmts: CT_PivotFmts, view3D: CT_View3D, floor: CT_Surface, sideWall: CT_Surface, backWall: CT_Surface, plotArea: CT_PlotArea, legend: CT_Legend, plotVisOnly: CT_Boolean, dispBlanksAs: CT_DispBlanksAs, showDLblsOverMax: CT_Boolean, extLst: CT_ExtensionList.
/// XSD complex type CT_Chart: dml-chart.xsd defines CT_Chart for chart
/// payload children including title, plotArea, legend, view3D, and extLst.
/// CT_Chart is the chart element payload containing plot area, title, legend,
/// 3-D view, floor, side wall, back wall, display blanks behavior, and extensions.
/// Schema dml-chart.xsd complex type `CT_Chart` children include
/// `{'name': 'title', 'type': 'CT_Title'}` and
/// `{'name': 'plotArea', 'type': 'CT_PlotArea'}`.
pub(all) struct CT_Chart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Chart from a parsed chart element while keeping the complete XML tree.
pub fn CT_Chart::new(element : @xml.Element) -> CT_Chart {
  if element.name.local_name.length() == 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// Parse an element already selected for XSD complex type CT_Chart.
///
/// Schema dml-chart.xsd complex type `CT_Chart` has children title,
/// autoTitleDeleted, pivotFmts, view3D, floor, sideWall, backWall, plotArea,
/// legend, plotVisOnly, dispBlanksAs, showDLblsOverMax, and extLst.
pub fn parse_ct_chart_element(element : @xml.Element) -> CT_Chart {
  CT_Chart::new(element)
}

///|
/// Return whether CT_Chart contains the required chart payload child plotArea.
pub fn CT_Chart::has_plot_area(self : CT_Chart) -> Bool {
  let mut found = false
  for child in self.element.children {
    match child {
      @xml.Node::Element(element) =>
        if element.name.local_name == "plotArea" {
          found = true
        }
      _ => ()
    }
  }
  found
}

///|
/// XSD complex type CT_Style (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Style {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PivotSource (§21.2, dml-chart.xsd): attributes no local attributes; children name: s:ST_Xstring, fmtId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_PivotSource {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Protection (§21.2, dml-chart.xsd): attributes no local attributes; children chartObject: CT_Boolean, data: CT_Boolean, formatting: CT_Boolean, selection: CT_Boolean, userInterface: CT_Boolean.
pub(all) struct CT_Protection {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_HeaderFooter (§21.2, dml-chart.xsd): attributes alignWithMargins, differentOddEven, differentFirst; children oddHeader: s:ST_Xstring, oddFooter: s:ST_Xstring, evenHeader: s:ST_Xstring, evenFooter: s:ST_Xstring, firstHeader: s:ST_Xstring, firstFooter: s:ST_Xstring.
pub(all) struct CT_HeaderFooter {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageMargins (§21.2, dml-chart.xsd): attributes l, r, t, b, header, footer; children no local child elements.
pub(all) struct CT_PageMargins {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ExternalData (§21.2, dml-chart.xsd): attributes r:id; children autoUpdate: CT_Boolean.
pub(all) struct CT_ExternalData {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageSetup (§21.2, dml-chart.xsd): attributes paperSize, paperHeight, paperWidth, firstPageNumber, orientation, blackAndWhite, draft, useFirstPageNumber, horizontalDpi, verticalDpi, copies; children no local child elements.
pub(all) struct CT_PageSetup {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PrintSettings (§21.2, dml-chart.xsd): attributes no local attributes; children headerFooter: CT_HeaderFooter, pageMargins: CT_PageMargins, pageSetup: CT_PageSetup.
pub(all) struct CT_PrintSettings {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ChartSpace (§21.2, dml-chart.xsd): attributes no local attributes; children date1904: CT_Boolean, lang: CT_TextLanguageID, roundedCorners: CT_Boolean, style: CT_Style, clrMapOvr: a:CT_ColorMapping, pivotSource: CT_PivotSource, protection: CT_Protection, chart: CT_Chart, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, externalData: CT_ExternalData, printSettings: CT_PrintSettings, userShapes: CT_RelId, extLst: CT_ExtensionList.
pub(all) struct CT_ChartSpace {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ShapeNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvSpPr: a:CT_NonVisualDrawingShapeProps.
pub(all) struct CT_ShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Shape is also present in dml-chartDrawing.xsd (§21.3); this shared holder captures the parsed element for both schema bundles.

///|
/// XSD complex type CT_ConnectorNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvCxnSpPr: a:CT_NonVisualConnectorProperties.
pub(all) struct CT_ConnectorNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Connector (§21.3, dml-chartDrawing.xsd): attributes macro, fPublished; children nvCxnSpPr: CT_ConnectorNonVisual, spPr: a:CT_ShapeProperties, style: a:CT_ShapeStyle.
pub(all) struct CT_Connector {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvPicPr: a:CT_NonVisualPictureProperties.
pub(all) struct CT_PictureNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Picture (§21.3, dml-chartDrawing.xsd): attributes macro, fPublished; children nvPicPr: CT_PictureNonVisual, blipFill: a:CT_BlipFillProperties, spPr: a:CT_ShapeProperties, style: a:CT_ShapeStyle.
pub(all) struct CT_Picture {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GraphicFrameNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvGraphicFramePr: a:CT_NonVisualGraphicFrameProperties.
pub(all) struct CT_GraphicFrameNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GraphicFrame (§21.3, dml-chartDrawing.xsd): attributes macro, fPublished; children nvGraphicFramePr: CT_GraphicFrameNonVisual, xfrm: a:CT_Transform2D, a:graphic.
pub(all) struct CT_GraphicFrame {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GroupShapeNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvGrpSpPr: a:CT_NonVisualGroupDrawingShapeProps.
pub(all) struct CT_GroupShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GroupShape (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children nvGrpSpPr: CT_GroupShapeNonVisual, grpSpPr: a:CT_GroupShapeProperties, sp: CT_Shape, grpSp: CT_GroupShape, graphicFrame: CT_GraphicFrame, cxnSp: CT_Connector, pic: CT_Picture.
pub(all) struct CT_GroupShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Marker is also present in dml-chartDrawing.xsd (§21.3); this shared holder captures the parsed element for both schema bundles.

///|
/// XSD complex type CT_RelSizeAnchor (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children from: CT_Marker, to: CT_Marker.
pub(all) struct CT_RelSizeAnchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AbsSizeAnchor (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children from: CT_Marker, ext: a:CT_PositiveSize2D.
pub(all) struct CT_AbsSizeAnchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Drawing (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children no local child elements.
pub(all) struct CT_Drawing {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD top-level element chartSpace (§21.2, dml-chart.xsd) with type CT_ChartSpace.
pub(all) struct ChartSpace {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD top-level element userShapes (§21.2, dml-chart.xsd) with type cdr:CT_Drawing.
pub(all) struct UserShapes {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD top-level element chart (§21.2, dml-chart.xsd) with type CT_RelId.
pub(all) struct Chart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Return the schema bundle names implemented by this DrawingML chart package.
pub fn chart_schema_bundles() -> Array[String] {
  let bundles = []
  bundles.push("dml-chart.xsd")
  bundles.push("dml-chartDrawing.xsd")
  bundles
}
