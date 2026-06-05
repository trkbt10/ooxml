// Category-scoped fixture extension framework.
//
// `visual_cases()` in fixtures.mbt produces the bulk of the visual
// fixtures via inline `let cases = ...; cases.push(...)` because it
// also defines a forest of closure helpers (`pptx_shape`, `sp_tree`,
// `tr`, `tc`, …).  Adding more fixtures to that one function makes
// it grow indefinitely and serialises subagent edits.
//
// This file (and its per-category siblings) lets new fixture
// additions live in **separate top-level functions** that each take
// the same `cases : Array[VisualCase]` and push onto it.  Helpers
// were lifted to top-level in `fixtures_helpers.mbt` so the
// per-category extenders can use them without re-declaring.
//
// Wire-up: the entry point `extra_cases()` calls each category's
// extender in turn; `visual_cases()` appends the result.  Subagents
// can edit `fixtures_<category>.mbt` independently.

///|
/// Run every category extender and return their combined fixtures.
/// Subagents add new fixtures by inserting `cases.push(...)` calls
/// into the per-category functions; nothing else has to change.
fn extra_cases() -> Array[VisualCase] {
  let cases : Array[VisualCase] = []
  extras_wml_run(cases)
  extras_wml_paragraph(cases)
  extras_wml_sections(cases)
  extras_wml_table(cases)
  extras_wml_fields(cases)
  extras_wml_drawings(cases)
  extras_wml_extras(cases)
  extras_wml_aux_parts(cases)
  extras_sml(cases)
  extras_sml_advanced(cases)
  extras_sml_cf(cases)
  extras_sml_cf_complete(cases)
  extras_sml_autofilter_inline(cases)
  extras_sml_aux_parts(cases)
  extras_sml_worksheet_coverage(cases)
  extras_pml_shape(cases)
  extras_pml_text(cases)
  extras_pml_extra(cases)
  extras_pml_advanced(cases)
  extras_pml_lines(cases)
  extras_pml_transitions(cases)
  extras_pml_timing_coverage(cases)
  extras_pml_arrows_extra(cases)
  extras_pml_master_layout(cases)
  extras_pml_presentation_coverage(cases)
  extras_r29_pml_group(cases)
  extras_dml_color(cases)
  extras_dml_color_complete(cases)
  extras_dml_effects(cases)
  extras_dml_main_coverage(cases)
  extras_dml_locked_canvas(cases)
  extras_omml(cases)
  extras_omml_advanced(cases)
  extras_omml_extras(cases)
  extras_omml_complete(cases)
  extras_misc(cases)
  extras_edges(cases)
  cases
}

///|
/// Pivot fixtures (§18.10) are emitted via `pivoted_cases()` (in
/// fixtures.mbt) using the `xlsx_package_with_pivot` builder, which
/// owns the workbook `<pivotCaches>` entry, the per-part `_rels`
/// chain, and the three `[Content_Types]` overrides
/// (`pivotTable`, `pivotCacheDefinition`, `pivotCacheRecords`).
/// `extras_sml_pivots` in `fixtures_sml_pivots.mbt` is the per-
/// category extender — pushed onto the `PivotedCase` array via
/// `pivoted_cases()` rather than `extra_cases()` because pivots
/// need the multi-part OPC builder.
fn _pivot_fixtures_anchor() -> Unit {
  // Anchor function so subagents searching for "pivot fixtures"
  // land in this file alongside the visual case extender table.
  // The actual fixture pushes live in `extras_sml_pivots`.
  ()
}

///|
/// Chart fixtures (§21.2 DrawingML chart) are emitted via
/// `charted_cases()` (in fixtures.mbt) using the
/// `pptx_package_with_chart` builder, which owns the slide-side
/// `rId2 → charts/chart1.xml` relationship and the
/// `…drawingml.chart+xml` content-type override.  `extras_dml_charts`
/// in `fixtures_dml_charts.mbt` is the per-category extender —
/// pushed onto the `ChartedCase` array via `charted_cases()` because
/// charts need the chart-specific OPC builder, not the plain
/// `pptx_package`.
fn _chart_fixtures_anchor() -> Unit {
  ()
}

///|
/// Diagram / SmartArt fixtures (§21.4 DrawingML diagram) are
/// emitted via `diagrammed_cases()` (in fixtures.mbt) using the
/// `pptx_package_with_diagram` builder, which owns the four
/// slide-side relationships (rId2..rId5 → data / layout /
/// quickStyle / colors parts) and the four content-type
/// overrides.  `extras_dml_diagrams` in `fixtures_dml_diagrams.mbt`
/// is the per-category extender — pushed onto the `DiagrammedCase`
/// array via `diagrammed_cases()` because diagrams need the
/// SmartArt-specific 4-part OPC builder.
fn _diagram_fixtures_anchor() -> Unit {
  ()
}

///|
/// Spreadsheet Drawing fixtures (§20.5 DrawingML SpreadsheetML
/// Drawing) are emitted via `spreadsheet_drawing_cases()` (in
/// fixtures.mbt) using the `xlsx_with_drawing_root_package` builder,
/// which owns the worksheet `<drawing r:id>` relationship and the
/// `xl/drawings/drawing1.xml` content-type override. The concrete
/// fixture pushes live in `extras_dml_spreadsheet_drawing`.
fn _spreadsheet_drawing_fixtures_anchor() -> Unit {
  ()
}
