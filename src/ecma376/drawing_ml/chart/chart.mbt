///|
/// ECMA-376 Part 1 §21.2 Drawingml Charts and Part 4 §18.1 DrawingML Charts schema surface.
///
/// The package owns dml-chart.xsd top-level elements chartSpace, userShapes,
/// and chart, plus dml-chartDrawing.xsd anchor/object domain identifiers.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/chart"
}

///|
/// Return the owned ECMA-376 chapter for this package.
pub fn chart_section_name() -> String {
  "ECMA-376 Part 1 §21.2 Drawingml Charts"
}
