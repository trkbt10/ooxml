///|
/// ECMA-376 Part 1 §20: DrawingML facade. Self-contained chapter combining colour, font, theme, shape, picture, chart, diagram subdomains.
///
/// Package overview cites the non-symbol DrawingML chapters that are documented at chapter scope rather than represented as individual code identifiers: Part 1 §14.1 glossary, §14.2 part summary, and §20.5 SpreadsheetML Drawing integration.
///
/// Part 4 §17, §18, and §19 migration chapters describe legacy-to-OOXML migration notes for wordprocessing, spreadsheet, and presentation drawings; those compatibility notes are tracked here as overview documentation rather than parser or builder entry points.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml"
}
