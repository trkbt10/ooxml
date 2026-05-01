///|
/// ECMA-376 Part 1 §21.2 Drawingml Charts and Part 4 §18.1 DrawingML Charts schema surface.
///
/// The package owns dml-chart.xsd top-level elements chartSpace, userShapes,
/// and chart, plus dml-chartDrawing.xsd anchor/object domain identifiers.
/// §18.1 Drawingml Charts: ECMA-376 Part 4 §18.1 covers DrawingML chart migration, represented by CT_ChartSpace, CT_Chart, and parse_chart_space().
///
/// XSD complex type CT_Chart: dml-chart.xsd defines the chart element payload
/// with title, view3D, plotArea, legend, display flags, and extLst children;
/// CT_Chart, CT_Chart::new, parse_ct_chart_element, CT_Chart::has_plot_area,
/// read_chart, and write_chart own that structure in this package.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/chart"
}

///|
/// Return the owned ECMA-376 chapter for this package.
pub fn chart_section_name() -> String {
  "ECMA-376 Part 1 §21.2 Drawingml Charts"
}

///|
/// Return the ECMA-376 Part 4 §18.1 Drawingml Charts chapter mirrored by this
/// package.
///
/// §18.1 Drawingml Charts: ECMA-376 Part 4 §18.1 is owned by
/// src/ecma376/drawing_ml/chart and is represented by CT_ChartSpace, CT_Chart,
/// parse_chart_space, read_chart_space, and write_chart_space.
pub fn chart_migration_section_name() -> String {
  "ECMA-376 Part 4 §18.1 Drawingml Charts"
}
