///|
/// Root entry of the `trkbt10/ooxml` library.
///
/// Office Open XML (ECMA-376) implementation for MoonBit. There is
/// no monolithic facade — each ML exposes a `context` package
/// (parser-built tree + IO + render queries) and an `edit` package
/// (B-layer mutators). Downstream users import the context for the
/// format they need and the edit package when they want to mutate:
///
///   - `trkbt10/ooxml/ecma376/wordprocessing_ml/context` — `.docx`
///     context (`open` / `save` / `to_html` / `to_styled_html` /
///     `to_svg` / style + numbering + field-eval queries).
///   - `trkbt10/ooxml/ecma376/wordprocessing_ml/edit` — `.docx`
///     mutators (`append_paragraph`, `set_run_bold`, `insert_picture`,
///     ...).
///   - `trkbt10/ooxml/ecma376/spreadsheet_ml/context` — `.xlsx`
///     context (`open` / `save` / `to_html` / formula + cf-rule +
///     autofilter + pivot-table queries).
///   - `trkbt10/ooxml/ecma376/spreadsheet_ml/edit` — `.xlsx`
///     mutators (`set_cell_value`, `merge_cells`, `set_cell_font`,
///     ...).
///   - `trkbt10/ooxml/ecma376/presentation_ml/context` — `.pptx`
///     context (`open` / `save` / `to_html` / `to_svg_for_slide` /
///     placeholder + animation queries).
///   - `trkbt10/ooxml/ecma376/presentation_ml/edit` — `.pptx`
///     mutators (`append_slide`, `add_textbox`, `set_text_color`,
///     ...).
///
/// The render direction is strictly parser → context → builder |
/// renderer. Mutation always flows through `edit` and yields a new
/// context value.
pub fn version() -> String {
  "0.1.0"
}
