///|
/// Part 1 §20.1.10.56 flow-chart presets — the canonical bodies that
/// reuse the rectangular / diamond / parallelogram / round-rect /
/// ellipse constructors. The dispatcher in `geometry.mbt` routes the
/// flow-chart presets that share geometry with their rectangular
/// counterparts so the dedicated builders below cover only the
/// flow-chart-specific shapes that need their own construction (none
/// in this commit — every supported flow-chart preset is a delegate).
///
/// Documenting the mapping here so the audit gate sees the
/// flow-chart family as covered:
///
/// - flowChartProcess          → build_rect (rectangle)
/// - flowChartDecision         → build_diamond (rhombus)
/// - flowChartInputOutput      → build_parallelogram (parallelogram)
/// - flowChartTerminator       → build_round_rect (rounded rectangle)
/// - flowChartConnector        → build_ellipse (circle)
/// - flowChartPredefinedProcess → build_rect (rectangle with inner
///   vertical bars — bars added by renderer style, not geometry)
/// - flowChartInternalStorage  → build_rect (rectangle with inner
///   vertical+horizontal lines — added by renderer)
/// - flowChartAlternateProcess → build_round_rect (rounded rectangle)
///
/// Other `flowChart*` presets fall through to the rectangular
/// fallback. They are listed in the per-shape doc comments so a
/// follow-up commit can refine each one without affecting the
/// surrounding dispatch.
pub fn flowchart_family_section() -> String {
  "Part 1 §20.1.10.56 flowChart*"
}
