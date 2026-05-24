// =============================================================================
// Microsoft x14 sparklines domain (typed structs).
//
// Spec references:
//   * `[MS-XLSX]` §2.2.4 Sparkline (Office 2010 extension).
//   * Microsoft Office 2010 schemas (`xl/2009/9/main`,
//     `xl/2009/9/main/spreadsheetDrawing`) — `x14:sparklineGroups`,
//     `x14:sparklineGroup`, `x14:sparkline`, `x14:colorSeries` /
//     `x14:colorNegative` / `x14:colorAxis` / `x14:colorMarkers` /
//     `x14:colorFirst` / `x14:colorLast` / `x14:colorHigh` /
//     `x14:colorLow`.
//   * `[MS-XLSX]` §2.6.5 ST_SparklineType — `line | column | stacked`.
//   * `[MS-XLSX]` §2.6.4 ST_SparklineEmptyCells — `gap | zero | span`.
//
// The x14 namespace URI is documented in `x14_ns()` so every consumer
// (decoder, renderer, fixture builders, verify.mbt) shares the single
// source of truth.
// =============================================================================

///|
/// The package identifier.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/sparkline"
}

///|
/// The Microsoft Office 2010 x14 extension namespace URI.
///
/// Per `[MS-XLSX]` §2.2.4 every `<x14:*>` element under
/// `<extLst><ext uri="…">` lives in this URI. The same URI is used
/// when serialising sparklines back into an `<x14:sparklineGroups>`
/// tree — declared once on the worksheet root via the `@xml.write`
/// writer's automatic namespace machinery.
pub fn x14_ns() -> String {
  "http://schemas.microsoft.com/office/spreadsheetml/2009/9/main"
}

///|
/// The Excel 2010 "expressions and metadata" namespace used by
/// `<xm:f>` (sparkline data-range formula) and `<xm:sqref>`
/// (sparkline anchor cell) inside `<x14:sparkline>`. Documented
/// alongside `x14_ns()` so fixtures use the single source of truth.
pub fn xm_ns() -> String {
  "http://schemas.microsoft.com/office/excel/2006/main"
}

///|
/// The extension URI MUST be present on the `<x:ext uri="…">`
/// element that carries `<x14:sparklineGroups>`. Per `[MS-XLSX]`
/// §2.2.4 the value is the GUID literal
/// `{05C60535-1F16-4FD2-B633-F4F36F0B64E0}`.
pub fn sparkline_ext_uri() -> String {
  "{05C60535-1F16-4FD2-B633-F4F36F0B64E0}"
}

///|
/// `[MS-XLSX]` §2.6.5 ST_SparklineType.
pub(all) enum SparklineKind {
  /// `type="line"` — polyline through the data values.
  Line
  /// `type="column"` — column bars (all data points positive-up).
  Column
  /// `type="stacked"` — win/loss bars (positive up, negative down,
  /// zero hidden).
  Stacked
} derive(Eq, Debug)

///|
/// `[MS-XLSX]` §2.6.4 ST_SparklineEmptyCells.
pub(all) enum SparklineEmptyCells {
  /// `gap` — leave a gap (the default per the schema).
  EmptyGap
  /// `zero` — draw a zero-value data point.
  EmptyZero
  /// `span` — interpolate across the gap.
  EmptySpan
} derive(Eq, Debug)

///|
/// One typed RGB colour. `<x14:colorSeries rgb="HEXVAL"/>` lands here.
/// `hex` carries the ARGB hex string exactly as written in the XML
/// (8-char ARGB, e.g. `"FF376092"`); when omitted the field is
/// `None` and the renderer falls back to its default palette.
pub(all) struct SparklineColor {
  hex : String?
  /// `theme="N"` — index into `<a:clrScheme>` per §18.8.3. The
  /// resolver lives in the SML viewer's theme handling, so this
  /// field is surfaced for downstream consumers but not yet
  /// resolved in the renderer (see render.mbt note).
  theme : Int?
  /// `tint="±F"` — tint applied to the resolved colour per
  /// §18.18.16 ST_TextColorScheme.
  tint : Double?
} derive(Eq, Debug)

///|
/// `SparklineColor` with no fields set (every colour optional).
pub fn SparklineColor::empty() -> SparklineColor {
  { hex: None, theme: None, tint: None }
}

///|
/// `[MS-XLSX]` §2.2.4 `<x14:sparkline>` — one inline sparkline
/// anchored to a single cell.
pub(all) struct Sparkline {
  /// `<xm:f>` — the source data range, e.g. `"Sheet1!A1:E1"`. The
  /// formula is preserved verbatim; renderers parse it into a
  /// `CellRange` and pull values from `<sheetData>` (see
  /// `decode_value_list` for the literal-array fallback documented
  /// in the package readme).
  data_range : String
  /// `<xm:sqref>` — the cell that contains the sparkline glyph,
  /// e.g. `"F1"`. The renderer uses this to look the cell up in
  /// `SheetLayout.cells` and paints the glyph in that cell's box.
  anchor_cell : String
  /// Literal value array — set when the fixture wants to bypass the
  /// data-range resolver (the project does not yet evaluate cell
  /// formulas in the data range; per the task constraint, fixtures
  /// can pass literal values via `decode_value_list`). When
  /// populated the renderer uses these values directly; when empty
  /// the renderer pulls values from `<sheetData>` for the cells
  /// inside `data_range`.
  literal_values : Array[Double]
} derive(Eq, Debug)

///|
/// `[MS-XLSX]` §2.2.4 `<x14:sparklineGroup>` — a group of sparklines
/// that share visual settings (type, markers, colour palette).
pub(all) struct SparklineGroup {
  /// `@type` — `line | column | stacked`. Default `line` per the
  /// schema.
  kind : SparklineKind
  /// `@displayEmptyCellsAs` — `gap | zero | span`. Default `gap`.
  display_empty_cells_as : SparklineEmptyCells
  /// `@markers="1"` — draw a square marker at every data point on
  /// a `line` sparkline.
  markers : Bool
  /// `@high="1"` — highlight the highest data point.
  high : Bool
  /// `@low="1"` — highlight the lowest data point.
  low : Bool
  /// `@first="1"` — highlight the first data point.
  first : Bool
  /// `@last="1"` — highlight the last data point.
  last : Bool
  /// `@negative="1"` — highlight negative points (column /
  /// stacked sparklines).
  negative : Bool
  /// `@displayXAxis="1"` — draw a horizontal axis line at y=0.
  display_x_axis : Bool
  /// `<x14:colorSeries>` — the line / column series colour.
  color_series : SparklineColor
  /// `<x14:colorNegative>` — colour for negative points.
  color_negative : SparklineColor
  /// `<x14:colorAxis>` — colour of the x-axis line.
  color_axis : SparklineColor
  /// `<x14:colorMarkers>` — colour of every marker dot.
  color_markers : SparklineColor
  /// `<x14:colorFirst>` — colour of the first-data-point highlight.
  color_first : SparklineColor
  /// `<x14:colorLast>` — colour of the last-data-point highlight.
  color_last : SparklineColor
  /// `<x14:colorHigh>` — colour of the high-data-point highlight.
  color_high : SparklineColor
  /// `<x14:colorLow>` — colour of the low-data-point highlight.
  color_low : SparklineColor
  /// `<x14:sparklines>/<x14:sparkline>+` — one inline sparkline per
  /// anchored cell.
  sparklines : Array[Sparkline]
} derive(Eq, Debug)

///|
/// `[MS-XLSX]` §2.2.4 `<x14:sparklineGroups>` — top-level container
/// for every `<x14:sparklineGroup>` carried by a single worksheet's
/// `<extLst>/<ext uri="…">` payload.
pub(all) struct SparklineGroups {
  groups : Array[SparklineGroup]
} derive(Eq, Debug)

///|
/// Empty-set sparkline groups — convenience for callers that need
/// a zero-state value.
pub fn SparklineGroups::empty() -> SparklineGroups {
  { groups: [] }
}
