// =============================================================================
// SpreadsheetML §18 → SVG renderer.
//
// Faithful MoonBit port of web-pptx's @aurochs-renderer/xlsx/src/svg/*
// (sheet-renderer.ts, layout.ts, cell-renderer.ts, border-renderer.ts,
// style-resolver.ts, context.ts).  All structural decisions and pixel
// math mirror the TypeScript implementation so the two renderers agree
// on layout / output.
//
// The renderer walks the worksheet's raw XML element (parallel to the
// existing render_html implementation in viewer.mbt) so that it does
// not need to track the typed-domain accessor names exhaustively.
// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/sheet-renderer.ts
// =============================================================================

///|
/// Options controlling sheet → SVG rendering.  Mirrors
/// `XlsxRenderOptions` in types.ts.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/types.ts:142
pub(all) struct SheetRenderOptions {
  /// Scale factor for converting Excel units to pixels.  Currently
  /// unused by `columnWidthCharToPixels` (which uses its own
  /// maxDigitWidth) but retained for API parity with the TS layer.
  scale : Double
  /// Default row height in points.
  default_row_height : Double
  /// Default column width in Excel character units.
  default_column_width : Double
  /// Whether to draw the global grid behind cells.
  show_grid_lines : Bool
  /// Whether to render the row-number gutter on the left.
  show_row_headers : Bool
  /// Whether to render the column-letter gutter on top.
  show_column_headers : Bool
  /// Pixel size of the row / column header gutter.
  header_size : Double
  /// Default font family for cell text.
  default_font_family : String
  /// Default font size for cell text in points.
  default_font_size : Double
  /// Stroke colour for grid lines.
  grid_line_color : String
  /// Background fill colour for the entire sheet.
  background_color : String
}

///|
/// Default render options matching web-pptx's
/// `DEFAULT_XLSX_RENDER_OPTIONS`.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/types.ts:227
pub fn default_render_options() -> SheetRenderOptions {
  {
    scale: 7.0,
    default_row_height: 15.0,
    default_column_width: 8.43,
    show_grid_lines: true,
    show_row_headers: false,
    show_column_headers: false,
    header_size: 20.0,
    default_font_family: "Calibri",
    default_font_size: 11.0,
    grid_line_color: "#E0E0E0",
    background_color: "#FFFFFF",
  }
}

///|
/// Result of rendering a worksheet to SVG.  Mirrors `SheetSvgResult`.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/types.ts:250
pub(all) struct SheetSvgResult {
  svg : String
  width : Double
  height : Double
  warnings : Array[String]
}

// =============================================================================
// Public entry point
// =============================================================================

///|
/// Render a §18.3.1.99 CT_Worksheet to a stand-alone SVG document.
///
/// `shared_strings` is consulted when a cell carries `@t="s"`; the
/// `<v>` child is interpreted as the integer index into
/// `sst.si_entries` per §18.4.9.  When `None`, indices are emitted
/// verbatim.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/sheet-renderer.ts:30
pub fn render_svg(
  domain : @domain.CT_Worksheet,
  shared_strings? : @domain.CT_Sst? = None,
  options? : SheetRenderOptions = default_render_options(),
  drawing? : @drawing.WsDr? = None,
  image_resolver? : (String) -> String? = _ => None,
  styles? : @domain.CT_Stylesheet? = None,
  /// §18.8.3 — `/xl/theme/theme1.xml` root element.  When
  /// supplied the renderer builds a `SmlThemeColorMap` from
  /// `<a:clrScheme>` so `<color theme="N">` references and
  /// `<a:srgbClr>` references resolve to concrete sRGB hex
  /// strings rather than being silently discarded.
  theme? : @xml.Element? = None,
  /// §18.2.28 `<workbookPr @date1904>` — when `true` the
  /// workbook uses the 1904 date system, so serial date values
  /// are interpreted relative to 1904-01-01 instead of
  /// 1900-01-01.  Defaults to `false` (1900 system).
  date1904? : Bool = false,
) -> SheetSvgResult {
  // §18.2.28 — pick the date system once for the whole sheet.
  let date_system = if date1904 {
    @date_serial.DateSystem::Serial1904
  } else {
    @date_serial.DateSystem::Serial1900
  }
  // Build the theme map once; empty when no theme part.
  let theme_map = match theme {
    Some(root) => parse_sml_clr_scheme(root)
    None => SmlThemeColorMap::empty()
  }
  // theme_map is consumed below by resolve_cell_style and its
  // descendants (ct_font_to_resolved / ct_fill_to_resolved /
  // ct_border_to_resolved / resolve_color_element_rgb).
  let warnings : Array[String] = []
  // §18.3.1.81 `<sheetFormatPr defaultColWidth defaultRowHeight>`
  // — the worksheet's own format defaults override the renderer
  // options for every non-`customWidth` / non-`customHeight`
  // row / column.
  let options = apply_sheet_format_pr(domain.element, options)
  let layout = compute_sheet_layout(domain.element, options)
  if layout.column_count == 0 || layout.row_count == 0 {
    return create_empty_result()
  }

  // Build cell map: cell-ref string ("A1") -> XML <c> element.
  // §18.3.1.13 / §18.3.1.73 — collect col defs first so the cell
  // map can apply col.style / row.s fallbacks for cells that omit
  // their own `s` attribute.
  let col_defs = collect_column_defs(domain.element)
  let cell_map : Map[String, @xml.Element] = Map::new()
  collect_cells(domain.element, cell_map, col_defs)
  // §18.3.1.18 — pre-sort `<conditionalFormatting>` rules by their
  // (block, rule.priority) ordering so the overlay pass below can
  // walk them in spec precedence order.
  let cf_blocks = domain.conditional_formatting
  // §18.3.1.10 — pre-compute per-block population statistics (mean,
  // std-dev, sorted values, occurrence counts) so the per-cell pass
  // below can evaluate Top10 / AboveAverage / DuplicateValues /
  // UniqueValues in O(1).
  let cf_stats : Array[PopulationStats] = []
  for block in cf_blocks {
    cf_stats.push(compute_population_stats(block, cell_map, shared_strings))
  }

  // Children of the root `<svg>` element, accumulated as a node
  // tree.  No SVG output is ever assembled by string concatenation:
  // every element flows through `svg_elem` (which carries the SVG
  // namespace) and is serialised once via `@markup.serialize_svg`.
  let body : Array[@xml.Node] = []

  // 1. Background rectangle.
  body.push(
    svg_elem(
      "rect",
      [
        svg_attr("x", "0"),
        svg_attr("y", "0"),
        svg_attr("width", format_d(layout.total_width)),
        svg_attr("height", format_d(layout.total_height)),
        svg_attr("fill", options.background_color),
      ],
      [],
    ),
  )

  // 2. Grid lines.  §18.3.1.87 `<sheetView @showGridLines>`
  // overrides the SheetRenderOptions when present; per-sheet
  // setting wins because Excel writes the toggle on the view.
  let effective_grid_lines = sheet_view_show_grid_lines(domain.element).unwrap_or(
    options.show_grid_lines,
  )
  if effective_grid_lines {
    body.push(
      svg_elem(
        "g",
        [svg_attr("class", "grid-lines")],
        render_grid_lines(layout, options),
      ),
    )
  }

  // 3. Cell fills.
  let cell_fills : Array[@xml.Node] = []
  for entry in layout.cells {
    let (cell_ref, cl) = entry
    if cl.is_hidden_by_merge || cl.width == 0.0 || cl.height == 0.0 {
      continue
    }
    match cell_map.get(cell_ref) {
      None => ()
      Some(cell_el) => {
        let base_style = resolve_cell_style(
          cell_el,
          options,
          styles,
          theme_map~,
        )
        let style = apply_cf_overlay(
          cell_ref,
          cell_el,
          base_style,
          cf_blocks,
          cf_stats,
          styles,
          shared_strings,
          theme_map~,
        )
        let fill_nodes : Array[@xml.Node] = match style.fill {
          FillNone => []
          FillSolid(color) => render_cell_fill_solid(cl, color)
          FillPattern(name, fg, bg) =>
            render_cell_fill_pattern(cl, name, fg, bg)
          FillGradient(grad_type, degree, stops) =>
            render_cell_fill_gradient(cl, grad_type, degree, stops)
        }
        for n in fill_nodes {
          cell_fills.push(n)
        }
        // §18.3.1.28 dataBar — draw the proportional bar over the
        // cell background. Width = cell.width * ratio. Left-aligned
        // for positive bars; ECMA-376 §18.3.1.28 also supports
        // negative bars centred on the axis but the most common
        // case is min=0 so we ship the simple left-aligned form.
        match style.data_bar {
          None => ()
          Some(pair) => {
            let (ratio, bar_color, axis_position, direction, negative_color) = pair
            for
              n in render_data_bar(
                cl, ratio, bar_color, axis_position, direction, negative_color,
              ) {
              cell_fills.push(n)
            }
          }
        }
      }
    }
  }
  body.push(svg_elem("g", [svg_attr("class", "cell-fills")], cell_fills))

  // 4. Cell borders.
  let cell_borders : Array[@xml.Node] = []
  for entry in layout.cells {
    let (cell_ref, cl) = entry
    if cl.is_hidden_by_merge || cl.width == 0.0 || cl.height == 0.0 {
      continue
    }
    match cell_map.get(cell_ref) {
      None => ()
      Some(cell_el) => {
        let base_style = resolve_cell_style(
          cell_el,
          options,
          styles,
          theme_map~,
        )
        let style = apply_cf_overlay(
          cell_ref,
          cell_el,
          base_style,
          cf_blocks,
          cf_stats,
          styles,
          shared_strings,
          theme_map~,
        )
        for n in render_cell_borders(cl, style.border) {
          cell_borders.push(n)
        }
      }
    }
  }
  body.push(svg_elem("g", [svg_attr("class", "cell-borders")], cell_borders))

  // 5. Cell text.
  let cell_text : Array[@xml.Node] = []
  for entry in layout.cells {
    let (cell_ref, cl) = entry
    if cl.is_hidden_by_merge || cl.width == 0.0 || cl.height == 0.0 {
      continue
    }
    match cell_map.get(cell_ref) {
      None => ()
      Some(cell_el) => {
        let base_style = resolve_cell_style(
          cell_el,
          options,
          styles,
          theme_map~,
        )
        let style = apply_cf_overlay(
          cell_ref,
          cell_el,
          base_style,
          cf_blocks,
          cf_stats,
          styles,
          shared_strings,
          theme_map~,
        )
        // §18.3.1.49 iconSet — emit spec-anchored metadata only.
        // §18.18.42 ST_IconSetType enumerates the set name; the
        // actual icon glyph/colour is consumer-defined and outside
        // ECMA-376 scope, so the viewer surfaces the set name and
        // bucket index as data-* attributes and reserves no inline
        // horizontal space for an icon.
        match style.icon {
          None => ()
          Some(pair) => {
            let (set_name, bucket) = pair
            for n in render_cell_icon_metadata(cl, set_name, bucket) {
              cell_text.push(n)
            }
          }
        }
        let icon_width = 0.0
        if !style.hide_value {
          let text = format_cell_value(
            cell_el,
            shared_strings,
            style,
            warnings,
            date_system~,
          )
          // §18.3.1.87 `<sheetView @showZeros="0">` — when the
          // per-sheet view turns off zero display, numeric cells
          // with value exactly 0 MUST render blank.  The
          // suppression is gated by the cell's numeric value, not
          // the formatted text (so "0.00" still suppresses).
          let suppress_zero = match sheet_view_show_zeros(domain.element) {
            Some(false) => is_numeric_zero_cell(cell_el, shared_strings)
            _ => false
          }
          if text != "" && !suppress_zero {
            let cell_t = attr_value_local(cell_el, "t")
            // §18.8.30 — a colour directive in the applicable
            // number-format section (`[Red]`, `[Color 12]`, …)
            // overrides the cell text colour.  Resolve it against
            // the cell's numeric value (which selects the
            // positive / negative / zero section) and override the
            // font colour before rendering.
            let text_style = match cell_numeric_value(cell_el, date_system) {
              None => style
              Some(num) =>
                match resolve_format_color(num, style.number_format) {
                  None => style
                  Some(rgb) =>
                    { ..style, font: { ..style.font, color: Some(rgb) } }
                }
            }
            for
              n in render_cell_text_offset(
                cl,
                text,
                text_style,
                icon_width,
                cell_t~,
              ) {
              cell_text.push(n)
            }
          }
        }
      }
    }
  }
  body.push(svg_elem("g", [svg_attr("class", "cell-text")], cell_text))

  // 6. Optional row / column headers.  §18.3.1.87
  // `<sheetView @showRowColHeaders="0">` MUST suppress them
  // regardless of the renderer default.
  let effective_headers = sheet_view_show_row_col_headers(domain.element)
  let effective_show_row = match effective_headers {
    Some(b) => b
    None => options.show_row_headers
  }
  let effective_show_col = match effective_headers {
    Some(b) => b
    None => options.show_column_headers
  }
  if effective_show_row {
    body.push(
      svg_elem(
        "g",
        [svg_attr("class", "row-headers")],
        render_row_headers(layout, options),
      ),
    )
  }
  if effective_show_col {
    body.push(
      svg_elem(
        "g",
        [svg_attr("class", "column-headers")],
        render_column_headers(layout, options),
      ),
    )
  }

  // §18.3.1.73 / §18.3.1.13 — `<row @outlineLevel>` and
  // `<col @outlineLevel>` define grouping levels for rows/columns.
  // Surface them as `data-ooxml-row-outline-level` /
  // `data-ooxml-col-outline-level` sidecar rects so consumers can
  // render the grouping bracket.
  match render_sheet_outline_levels(domain.element, layout) {
    Some(node) => body.push(node)
    None => ()
  }

  // §18.3.1.40 `<c>/<f>` — emit a per-cell `<rect>` carrying the
  // formula text and shared-formula metadata as `data-ooxml-*`
  // attributes so consumers can rebuild the formula layer
  // (re-evaluation, copy/paste, dependency tracking).  The rect
  // is transparent and zero-sized when no metadata applies; it
  // exists purely as a metadata sidecar to keep the rendering
  // pipeline simple.
  match render_sheet_formulas(cell_map, layout) {
    Some(node) => body.push(node)
    None => ()
  }

  // §18.4.6 `<rPh>` — emit a per-cell `<rect data-ooxml-phonetic>`
  // sidecar for every shared-string cell whose `<si>` entry
  // carries phonetic-guide (furigana) runs, so consumers can
  // render ruby text above the base value.
  match render_sheet_phonetics(cell_map, layout, shared_strings) {
    Some(node) => body.push(node)
    None => ()
  }

  // §18.3.1.45 `<hyperlinks>/<hyperlink>` — emit a per-cell SVG
  // marker carrying `data-ooxml-hyperlink-r-id` /
  // `data-ooxml-hyperlink-location` so downstream consumers
  // can wrap the cell text in an HTML `<a>`. Excel writes the
  // hyperlink as sibling of `<sheetData>`, not inline on the
  // cell, so we walk the worksheet looking for hyperlink rows.
  match render_sheet_hyperlinks(domain.element, layout) {
    Some(node) => body.push(node)
    None => ()
  }

  // Drawings (§20.5.2.35 xdr:wsDr) — emit each EG_Anchor as a typed
  // SVG group positioned over the cell grid. Mirrors web-pptx
  // renderAllDrawings in drawing-renderer.ts.
  match drawing {
    None => ()
    Some(d) => {
      let drawing_nodes : Array[@xml.Node] = []
      for anchor in d.anchors {
        for n in render_drawing_anchor(anchor, layout, image_resolver, warnings) {
          drawing_nodes.push(n)
        }
      }
      body.push(svg_elem("g", [svg_attr("class", "drawings")], drawing_nodes))
    }
  }

  // Assemble the final SVG document as a node tree.  The root
  // `<svg>` carries the SVG namespace via `svg_elem` so the writer
  // emits exactly one `xmlns` declaration; `@markup.serialize_svg`
  // escapes every attribute value and text node.
  let root_attrs : Array[@xml.Attribute] = [
    svg_attr("width", format_d(layout.total_width)),
    svg_attr("height", format_d(layout.total_height)),
    svg_attr(
      "viewBox",
      "0 0 " +
      format_d(layout.total_width) +
      " " +
      format_d(layout.total_height),
    ),
    svg_attr("data-ooxml", "sml"),
  ]
  // §18.3.1.65 `<sheetViews>/<sheetView>/<pane>` — surface the
  // pane state and split positions as data attributes on the
  // SVG root so downstream consumers can render freeze
  // indicators / sticky headers.
  match sheet_view_pane_info(domain.element) {
    None => ()
    Some(pane) => {
      root_attrs.push(
        svg_attr("data-ooxml-pane-x-split", format_d(pane.x_split)),
      )
      root_attrs.push(
        svg_attr("data-ooxml-pane-y-split", format_d(pane.y_split)),
      )
      match pane.state {
        Some(s) => root_attrs.push(svg_attr("data-ooxml-pane-state", s))
        None => ()
      }
      match pane.active_pane {
        Some(s) => root_attrs.push(svg_attr("data-ooxml-pane-active", s))
        None => ()
      }
      match pane.top_left_cell {
        Some(s) => root_attrs.push(svg_attr("data-ooxml-pane-top-left", s))
        None => ()
      }
    }
  }
  // §18.3.1.82 `<sheetPr>/<tabColor>` — the worksheet tab strip
  // colour.  The single-worksheet SVG render has no tab UI, so we
  // surface the colour as `data-ooxml-tab-color` on the root for
  // consumers that build a multi-sheet tab bar.
  match sheet_tab_color(domain.element) {
    None => ()
    Some(color) => root_attrs.push(svg_attr("data-ooxml-tab-color", color))
  }
  // §18.3.1.70 `<printOptions>` — page-setup print flags.  The
  // SVG render is a continuous viewport, not paged media, so the
  // four booleans surface as `data-ooxml-print-*` data attributes
  // for consumers that drive a print pipeline.
  for kv in sheet_print_options(domain.element) {
    let (key, val) = kv
    root_attrs.push(svg_attr("data-ooxml-print-" + key, val))
  }
  // §18.3.1.65 — draw split lines for visible freeze/split panes.
  // For "frozen" panes the split values are column / row counts;
  // for "split" panes they are pixel positions.  Project both to
  // pixel coordinates using the layout's column / row widths.  The
  // split-line group precedes the body content so it matches the
  // legacy output ordering.
  let root_children : Array[@xml.Node] = []
  match sheet_view_pane_info(domain.element) {
    None => ()
    Some(pane) =>
      match render_pane_split_lines(layout, pane) {
        Some(node) => root_children.push(node)
        None => ()
      }
  }
  for n in body {
    root_children.push(n)
  }
  let svg_root : @xml.Element = {
    name: @markup.qname_ns("svg", @markup.svg_ns),
    attributes: root_attrs,
    children: root_children,
  }
  {
    svg: @markup.serialize_svg(svg_root),
    width: layout.total_width,
    height: layout.total_height,
    warnings,
  }
}

///|
/// Build the empty-sheet placeholder.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/sheet-renderer.ts:103
fn create_empty_result() -> SheetSvgResult {
  let svg_root : @xml.Element = {
    name: @markup.qname_ns("svg", @markup.svg_ns),
    attributes: [
      svg_attr("width", "200"),
      svg_attr("height", "50"),
      svg_attr("viewBox", "0 0 200 50"),
    ],
    children: [
      svg_elem(
        "text",
        [
          svg_attr("x", "100"),
          svg_attr("y", "25"),
          svg_attr("text-anchor", "middle"),
          svg_attr("dominant-baseline", "middle"),
          svg_attr("font-size", "14"),
          svg_attr("fill", "#999999"),
        ],
        [svg_text("(empty sheet)")],
      ),
    ],
  }
  {
    svg: @markup.serialize_svg(svg_root),
    width: 200.0,
    height: 50.0,
    warnings: [],
  }
}

// =============================================================================
// Layout computation
// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/layout.ts
// =============================================================================

///|
/// Pixel layout for a single cell.
struct CellLayout {
  x : Double
  y : Double
  width : Double
  height : Double
  colspan : Int
  rowspan : Int
  is_merge_origin : Bool
  is_hidden_by_merge : Bool
}

///|
/// Pixel layout for an entire sheet.  `cells` is an Array of
/// (cellRef, layout) pairs preserving traversal order — the TS code
/// uses a Map<string, CellLayout> and iterates insertion-ordered, so
/// we keep the same convention.
struct SheetLayout {
  cells : Array[(String, CellLayout)]
  total_width : Double
  total_height : Double
  column_positions : Array[Double]
  row_positions : Array[Double]
  column_widths : Array[Double]
  row_heights : Array[Double]
  column_count : Int
  row_count : Int
  /// §18.3.1.55 mergeCells — populated so renderers can suppress
  /// grid lines, borders, and cell content inside merged regions.
  merge_map : Map[String, MergeInfo]
}

///|
/// §18.3.1.13 column definition.
struct ColumnDef {
  min : Int
  max : Int
  width : Double?
  hidden : Bool
  /// §18.3.1.13 `@style` — cellXfs index applied to every cell in
  /// `min..=max` that lacks both its own `s` and a row-level `s`.
  style : String?
}

///|
/// Convert a 1-based column index to its A1 letter sequence.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/layout.ts:38
fn column_index_to_letter(col : Int) -> String {
  if col <= 0 {
    return ""
  }
  let mut n = col
  let buf = StringBuilder::new()
  let chars : Array[Char] = []
  while n > 0 {
    let remainder = (n - 1) % 26
    chars.push(Char::from_int(65 + remainder))
    n = (n - 1) / 26
  }
  let mut i = chars.length() - 1
  while i >= 0 {
    buf.write_char(chars[i])
    i = i - 1
  }
  buf.to_string()
}

///|
/// Compose an A1 cell reference from 1-based (row, col) indices.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/layout.ts:55
fn cell_ref_from_indices(row : Int, col : Int) -> String {
  column_index_to_letter(col) + row.to_string()
}

///|
/// Parse an A1 cell reference (e.g. "AB12") into 1-based (row, col).
/// Returns `None` when the input is malformed.
fn parse_cell_ref(ref_str : String) -> (Int, Int)? {
  let s = ref_str.trim_space().to_string()
  let len = s.length()
  if len == 0 {
    return None
  }
  let mut col = 0
  let mut i = 0
  let mut letters_consumed = false
  for c in s {
    if c >= 'A' && c <= 'Z' {
      col = col * 26 + (c.to_int() - 65 + 1)
      letters_consumed = true
      i = i + 1
    } else if c >= 'a' && c <= 'z' {
      col = col * 26 + (c.to_int() - 97 + 1)
      letters_consumed = true
      i = i + 1
    } else if c == '$' {
      i = i + 1
    } else {
      break
    }
  }
  if !letters_consumed || i >= len {
    return None
  }
  let mut row_str = ""
  for j in i..<len {
    let ch = s.unsafe_charcode_at(j)
    if ch == '$'.to_int() {
      continue
    }
    if ch < '0'.to_int() || ch > '9'.to_int() {
      return None
    }
    row_str = row_str + Char::from_int(ch).to_string()
  }
  if row_str.length() == 0 {
    return None
  }
  match (try? @strconv.parse_int(row_str)) {
    Ok(r) => if r > 0 { Some((r, col)) } else { None }
    Err(_) => None
  }
}

///|
/// §18.3.1.13 ST_Col @width — Excel column width (character units)
/// to CSS pixels using the spec-mandated formula:
///   Truncate( ((256 × w + Truncate(128 / MDW)) / 256) × MDW )
/// MDW = max-digit-width = pixel width of the `"0"` glyph in the
/// Normal style's font at 96 dpi. The Normal-style font is
/// implementation-resolved; until the Normal-style cascade is
/// wired in we use 7 px (Calibri 11 at 96 dpi) as the documented
/// fallback. The previous `width * 7 + 5` heuristic was a web-pptx
/// shortcut that does not match the spec formula at narrow widths.
fn column_width_to_pixels(excel_width : Double) -> Double {
  let mdw = column_max_digit_width_px()
  let padding = (128.0 / mdw).to_int().to_double()
  let raw = (256.0 * excel_width + padding) / 256.0 * mdw
  let truncated = raw.to_int().to_double()
  if truncated < 0.0 {
    0.0
  } else {
    truncated
  }
}

///|
/// §18.3.1.13 — pixel width of the `"0"` digit in the Normal style's
/// font at 96 dpi. Spec mandates the value come from the Normal
/// style's font; until that resolution path is wired we use 7 px
/// (= Calibri 11 at 96 dpi) as a documented fallback.
fn column_max_digit_width_px() -> Double {
  7.0
}

///|
/// Convert row height in points → CSS pixels, rounded to the nearest
/// integer.  Mirrors `rowHeightToPixels` (Math.round ∘
/// pointsToPixels).
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/layout.ts:27
fn row_height_to_pixels(points : Double) -> Double {
  let exact = points * (96.0 / 72.0)
  let rounded = (exact + 0.5).to_int().to_double()
  rounded
}

///|
/// Walk `<cols>/<col>` ranges and produce a list of column definitions.
fn collect_column_defs(worksheet : @xml.Element) -> Array[ColumnDef] {
  let defs : Array[ColumnDef] = []
  for child in worksheet.children {
    match child {
      Element(e) =>
        if e.name.local_name == "cols" {
          for sub in e.children {
            match sub {
              Element(col_el) =>
                if col_el.name.local_name == "col" {
                  let min = parse_int_attr_or(col_el, "min", -1)
                  let max = parse_int_attr_or(col_el, "max", min)
                  if min > 0 {
                    let width = match attr_value_local(col_el, "width") {
                      None => None
                      Some(v) =>
                        match (try? @strconv.parse_double(v)) {
                          Ok(w) => Some(w)
                          Err(_) => None
                        }
                    }
                    // §18.3.1.13 col/@hidden — xsd:boolean.
                    let hidden = parse_xsd_boolean_or(
                      attr_value_local(col_el, "hidden"),
                      false,
                    )
                    let style = attr_value_local(col_el, "style")
                    defs.push({ min, max, width, hidden, style })
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  defs
}

///|
/// Resolve the rendered pixel width for a 1-based column index.
/// Mirrors `getColumnWidth` — explicit width wins; explicit hidden
/// forces 0; otherwise falls back to the option default.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/layout.ts:63
fn column_width_for(
  col_index : Int,
  columns : Array[ColumnDef],
  options : SheetRenderOptions,
) -> Double {
  for col in columns {
    if col_index >= col.min && col_index <= col.max {
      if col.hidden {
        return 0.0
      }
      match col.width {
        Some(w) => return column_width_to_pixels(w)
        None => ()
      }
    }
  }
  column_width_to_pixels(options.default_column_width)
}

///|
/// Collect row height overrides keyed by 1-based row number.
fn build_row_height_map(worksheet : @xml.Element) -> Map[Int, Double] {
  let map : Map[Int, Double] = Map::new()
  for child in worksheet.children {
    match child {
      Element(sd) =>
        if sd.name.local_name == "sheetData" {
          for row_node in sd.children {
            match row_node {
              Element(row_el) =>
                if row_el.name.local_name == "row" {
                  let row_num = parse_int_attr_or(row_el, "r", 0)
                  if row_num > 0 {
                    // §18.3.1.73 row/@hidden — xsd:boolean.
                    let hidden = parse_xsd_boolean_or(
                      attr_value_local(row_el, "hidden"),
                      false,
                    )
                    if hidden {
                      map.set(row_num, 0.0)
                    } else {
                      // §18.3.1.73 row/@ht — when `ht` is present
                      // the spec lets the consumer honour it as the
                      // row's explicit height (in points). The
                      // companion `customHeight` attribute is a
                      // hint that the height was user-set (so it
                      // should survive auto-fit) — it does NOT
                      // gate the application of `ht`. The previous
                      // strict gating mis-rendered Excel files that
                      // omit `customHeight` while declaring `ht`.
                      // Explicit `customHeight="0"` is treated as a
                      // request to ignore `ht` in favour of the
                      // §18.3.1.81 default.
                      // §18.3.1.73 @customHeight — xsd:boolean.
                      // `false` (explicit) requests that `ht` is
                      // ignored in favour of the default; `true`
                      // or absent honours `ht`.  Schema-violating
                      // values fall through to the per-attribute
                      // spec default of `true` (honour ht).
                      let custom_height = parse_xsd_boolean_or(
                        attr_value_local(row_el, "customHeight"),
                        true,
                      )
                      let ignore_ht = !custom_height
                      if !ignore_ht {
                        match attr_value_local(row_el, "ht") {
                          Some(v) =>
                            match (try? @strconv.parse_double(v)) {
                              Ok(pts) =>
                                map.set(row_num, row_height_to_pixels(pts))
                              Err(_) => ()
                            }
                          None => ()
                        }
                      }
                    }
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  map
}

///|
/// Merge-cell info recorded for each cell within a merged range.
/// `origin_row` / `origin_col` point at the top-left anchor cell so
/// grid-line suppression can identify which merged region this cell
/// belongs to without an extra lookup.
struct MergeInfo {
  is_origin : Bool
  colspan : Int
  rowspan : Int
  origin_row : Int
  origin_col : Int
}

///|
/// Build the merged-cells map by expanding every `<mergeCells>/<mergeCell ref="...">`.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/layout.ts:118
fn build_merge_map(worksheet : @xml.Element) -> Map[String, MergeInfo] {
  let map : Map[String, MergeInfo] = Map::new()
  for child in worksheet.children {
    match child {
      Element(mc) =>
        if mc.name.local_name == "mergeCells" {
          for entry in mc.children {
            match entry {
              Element(me) =>
                if me.name.local_name == "mergeCell" {
                  match attr_value_local(me, "ref") {
                    Some(range) => process_merge_range(range, map)
                    None => ()
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  map
}

///|
/// Expand "A1:B3" into one origin entry plus N-1 hidden entries.
fn process_merge_range(range : String, map : Map[String, MergeInfo]) -> Unit {
  let parts = range.split(":").collect()
  let (start, end) = match parts.length() {
    1 => (parts[0].to_string(), parts[0].to_string())
    2 => (parts[0].to_string(), parts[1].to_string())
    _ => return
  }
  let s = match parse_cell_ref(start) {
    Some(p) => p
    None => return
  }
  let e = match parse_cell_ref(end) {
    Some(p) => p
    None => return
  }
  let (start_row, start_col) = s
  let (end_row, end_col) = e
  let colspan = end_col - start_col + 1
  let rowspan = end_row - start_row + 1
  let origin = cell_ref_from_indices(start_row, start_col)
  map.set(origin, {
    is_origin: true,
    colspan,
    rowspan,
    origin_row: start_row,
    origin_col: start_col,
  })
  for r in start_row..<=end_row {
    for c in start_col..<=end_col {
      if r == start_row && c == start_col {
        continue
      }
      let cref = cell_ref_from_indices(r, c)
      map.set(cref, {
        is_origin: false,
        colspan: 1,
        rowspan: 1,
        origin_row: start_row,
        origin_col: start_col,
      })
    }
  }
}

///|
/// Read `<dimension ref="A1:E10">` and return (max_row, max_col); zero
/// when missing.
fn read_dimension(worksheet : @xml.Element) -> (Int, Int) {
  for child in worksheet.children {
    match child {
      Element(d) =>
        if d.name.local_name == "dimension" {
          match attr_value_local(d, "ref") {
            None => ()
            Some(r) => {
              let parts = r.split(":").collect()
              match parts.length() {
                1 =>
                  match parse_cell_ref(parts[0].to_string()) {
                    Some((row, col)) => return (row, col)
                    None => ()
                  }
                _ =>
                  match parse_cell_ref(parts[parts.length() - 1].to_string()) {
                    Some((row, col)) => return (row, col)
                    None => ()
                  }
              }
            }
          }
        }
      _ => ()
    }
  }
  (0, 0)
}

///|
/// §18.3.1.81 — overlay `<sheetFormatPr>`'s `@defaultColWidth`
/// and `@defaultRowHeight` onto the render options.  Both
/// attributes are optional; when absent the renderer defaults
/// (8.43 char-width / 15.0 pt) survive.  `@defaultColWidth` is
/// in Excel character units, `@defaultRowHeight` in points —
/// matching the `SheetRenderOptions` field units exactly.
fn apply_sheet_format_pr(
  worksheet : @xml.Element,
  options : SheetRenderOptions,
) -> SheetRenderOptions {
  let fmt_pr = first_child_named_local(worksheet, "sheetFormatPr")
  match fmt_pr {
    None => options
    Some(fp) => {
      let mut opts = options
      match attr_value_local(fp, "defaultColWidth") {
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(w) => if w > 0.0 { opts = { ..opts, default_column_width: w } }
            Err(_) => ()
          }
        None => ()
      }
      match attr_value_local(fp, "defaultRowHeight") {
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(h) => if h > 0.0 { opts = { ..opts, default_row_height: h } }
            Err(_) => ()
          }
        None => ()
      }
      opts
    }
  }
}

///|
/// §18.3.1.73 — parse a `<row @spans>` value and return the
/// largest column index named by any `min:max` range.  The
/// attribute is a space-separated list of `N:M` 1-based column
/// ranges (e.g. `"1:5 8:10"`).  Returns 0 when the value is
/// empty or malformed.
fn max_col_from_spans(spans : String) -> Int {
  let mut max_col = 0
  // Split on spaces; each token is `min:max`.
  let mut i = 0
  let n = spans.length()
  while i < n {
    // Skip whitespace.
    while i < n && spans.code_unit_at(i).to_int() == 0x20 {
      i = i + 1
    }
    let token_start = i
    while i < n && spans.code_unit_at(i).to_int() != 0x20 {
      i = i + 1
    }
    if i > token_start {
      let token = spans.substring(start=token_start, end=i)
      // Find the `:` separator.
      let mut colon = -1
      let mut k = 0
      while k < token.length() {
        if token.code_unit_at(k).to_int() == 0x3A {
          colon = k
          break
        }
        k = k + 1
      }
      if colon >= 0 {
        let hi = token.substring(start=colon + 1, end=token.length())
        match (try? @strconv.parse_int(hi)) {
          Ok(m) => if m > max_col { max_col = m }
          Err(_) => ()
        }
      }
    }
  }
  max_col
}

///|
/// When `<dimension>` is missing or zero, derive the bounds by
/// scanning `<sheetData>/<row r="...">` and `<c r="...">`.
fn derive_max_from_data(worksheet : @xml.Element) -> (Int, Int) {
  let mut max_row = 0
  let mut max_col = 0
  for child in worksheet.children {
    match child {
      Element(sd) =>
        if sd.name.local_name == "sheetData" {
          for rn in sd.children {
            match rn {
              Element(row_el) =>
                if row_el.name.local_name == "row" {
                  let r = parse_int_attr_or(row_el, "r", 0)
                  if r > max_row {
                    max_row = r
                  }
                  // §18.3.1.73 `<row @spans>` — a space-separated
                  // list of `min:max` column ranges naming the
                  // populated cells.  Honour it so a sparse row
                  // that declares spans but lists few `<c>` still
                  // contributes its full column extent to the
                  // derived bounds.
                  match attr_value_local(row_el, "spans") {
                    Some(spans_str) => {
                      let span_max = max_col_from_spans(spans_str)
                      if span_max > max_col {
                        max_col = span_max
                      }
                    }
                    None => ()
                  }
                  for cn in row_el.children {
                    match cn {
                      Element(cell_el) =>
                        if cell_el.name.local_name == "c" {
                          match attr_value_local(cell_el, "r") {
                            Some(addr) =>
                              match parse_cell_ref(addr) {
                                Some((rr, cc)) => {
                                  if rr > max_row {
                                    max_row = rr
                                  }
                                  if cc > max_col {
                                    max_col = cc
                                  }
                                }
                                None => ()
                              }
                            None => ()
                          }
                        }
                      _ => ()
                    }
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  (max_row, max_col)
}

///|
/// Top-level layout calculator.  Mirrors `calculateSheetLayout` plus
/// the helper sub-functions in layout.ts.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/layout.ts:162
fn compute_sheet_layout(
  worksheet : @xml.Element,
  options : SheetRenderOptions,
) -> SheetLayout {
  let (dim_row, dim_col) = read_dimension(worksheet)
  let (max_row, max_col) = if dim_row > 0 && dim_col > 0 {
    (dim_row, dim_col)
  } else {
    let (dr, dc) = derive_max_from_data(worksheet)
    let mr = if dim_row > 0 { dim_row } else { dr }
    let mc = if dim_col > 0 { dim_col } else { dc }
    (mr, mc)
  }
  if max_row == 0 || max_col == 0 {
    return {
      cells: [],
      total_width: 0.0,
      total_height: 0.0,
      column_positions: [],
      row_positions: [],
      column_widths: [],
      row_heights: [],
      column_count: 0,
      row_count: 0,
      merge_map: Map::new(),
    }
  }
  let columns = collect_column_defs(worksheet)
  let row_height_map = build_row_height_map(worksheet)
  let merge_map = build_merge_map(worksheet)

  // Column widths + positions.
  let header_x_offset = if options.show_row_headers {
    options.header_size
  } else {
    0.0
  }
  let column_widths : Array[Double] = []
  for col in 1..<=max_col {
    column_widths.push(column_width_for(col, columns, options))
  }
  let column_positions : Array[Double] = []
  let mut acc = header_x_offset
  for w in column_widths {
    column_positions.push(acc)
    acc = acc + w
  }
  let total_width = acc

  // Row heights + positions.
  let header_y_offset = if options.show_column_headers {
    options.header_size
  } else {
    0.0
  }
  let row_heights : Array[Double] = []
  let default_height_px = row_height_to_pixels(options.default_row_height)
  for row in 1..<=max_row {
    let h = match row_height_map.get(row) {
      Some(v) => v
      None => default_height_px
    }
    row_heights.push(h)
  }
  let row_positions : Array[Double] = []
  let mut yacc = header_y_offset
  for h in row_heights {
    row_positions.push(yacc)
    yacc = yacc + h
  }
  let total_height = yacc

  // Cell layouts.
  let cells : Array[(String, CellLayout)] = []
  for row in 1..<=max_row {
    for col in 1..<=max_col {
      let cref = cell_ref_from_indices(row, col)
      let x = column_positions[col - 1]
      let y = row_positions[row - 1]
      let layout = match merge_map.get(cref) {
        Some(info) =>
          if info.is_origin {
            let end_col = if col + info.colspan - 1 < max_col {
              col + info.colspan - 1
            } else {
              max_col
            }
            let end_row = if row + info.rowspan - 1 < max_row {
              row + info.rowspan - 1
            } else {
              max_row
            }
            let mut w = 0.0
            for i in col..<=end_col {
              w = w + column_widths[i - 1]
            }
            let mut h = 0.0
            for i in row..<=end_row {
              h = h + row_heights[i - 1]
            }
            (
              {
                x,
                y,
                width: w,
                height: h,
                colspan: info.colspan,
                rowspan: info.rowspan,
                is_merge_origin: true,
                is_hidden_by_merge: false,
              } : CellLayout)
          } else {
            (
              {
                x,
                y,
                width: column_widths[col - 1],
                height: row_heights[row - 1],
                colspan: 1,
                rowspan: 1,
                is_merge_origin: false,
                is_hidden_by_merge: true,
              } : CellLayout)
          }
        None =>
          (
            {
              x,
              y,
              width: column_widths[col - 1],
              height: row_heights[row - 1],
              colspan: 1,
              rowspan: 1,
              is_merge_origin: false,
              is_hidden_by_merge: false,
            } : CellLayout)
      }
      cells.push((cref, layout))
    }
  }
  {
    cells,
    total_width,
    total_height,
    column_positions,
    row_positions,
    column_widths,
    row_heights,
    column_count: max_col,
    row_count: max_row,
    merge_map,
  }
}

// =============================================================================
// Cell index — gather every `<c r="...">` keyed by cell reference.
// =============================================================================

///|
fn collect_cells(
  worksheet : @xml.Element,
  map : Map[String, @xml.Element],
  col_defs : Array[ColumnDef],
) -> Unit {
  for child in worksheet.children {
    match child {
      Element(sd) =>
        if sd.name.local_name == "sheetData" {
          let mut implicit_row = 1
          for rn in sd.children {
            match rn {
              Element(row_el) =>
                if row_el.name.local_name == "row" {
                  let row_num = parse_int_attr_or(row_el, "r", implicit_row)
                  implicit_row = row_num + 1
                  // §18.3.1.73 — `<row s="N">` provides the default
                  // cellXfs index for every child `<c>` lacking its
                  // own `s` attribute. §18.3.1.13 — `<col style="N">`
                  // serves the same role at the column axis with
                  // weaker precedence. We synthesise the inheritance
                  // by overlaying the resolved fallback `s` on cells
                  // that omit it; cells that DO carry their own `s`
                  // win unchanged.
                  let row_s_attr = attr_value_local(row_el, "s")
                  let mut implicit_col = 1
                  for cn in row_el.children {
                    match cn {
                      Element(cell_el) =>
                        if cell_el.name.local_name == "c" {
                          let cref = match attr_value_local(cell_el, "r") {
                            Some(a) => a
                            None => cell_ref_from_indices(row_num, implicit_col)
                          }
                          let col_index = match parse_cell_ref(cref) {
                            Some((_, c)) => {
                              implicit_col = c + 1
                              c
                            }
                            None => {
                              let c = implicit_col
                              implicit_col = implicit_col + 1
                              c
                            }
                          }
                          let resolved_cell = apply_style_fallback(
                            cell_el, row_s_attr, col_defs, col_index,
                          )
                          map.set(cref, resolved_cell)
                        }
                      _ => ()
                    }
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
}

///|
/// §18.3.1.4 / §18.3.1.13 / §18.3.1.73 — cellXfs index precedence
/// for a cell. The cell's own `s` wins; absent that, the row's `s`
/// wins; absent that, the matching `<col style="N">` range wins;
/// absent that, the cell is returned unchanged. The result is a
/// shallow-cloned `@xml.Element` with `s` injected on cells that
/// did not declare it directly.
fn apply_style_fallback(
  cell : @xml.Element,
  row_s_attr : String?,
  col_defs : Array[ColumnDef],
  col_index : Int,
) -> @xml.Element {
  // Cell already declared `s` — its value wins per §18.3.1.4.
  for a in cell.attributes {
    if a.name.local_name == "s" {
      return cell
    }
  }
  let fallback_s = match row_s_attr {
    Some(v) => Some(v)
    None => col_style_for(col_defs, col_index)
  }
  match fallback_s {
    None => cell
    Some(v) => {
      let new_attrs : Array[@xml.Attribute] = []
      for a in cell.attributes {
        new_attrs.push(a)
      }
      new_attrs.push({
        name: { prefix: None, local_name: "s", ns: None },
        value: v,
      })
      { name: cell.name, attributes: new_attrs, children: cell.children }
    }
  }
}

///|
/// §18.3.1.13 — find the first `<col>` range covering `col_index`
/// (1-based) that declares a `@style` attribute, and return that
/// style id. Returns `None` when no matching range exists.
fn col_style_for(col_defs : Array[ColumnDef], col_index : Int) -> String? {
  for def in col_defs {
    if def.min <= col_index && col_index <= def.max {
      match def.style {
        Some(s) => return Some(s)
        None => ()
      }
    }
  }
  None
}

// =============================================================================
// Style resolution (subset).
// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/style-resolver.ts
//
// CT_Worksheet alone does not carry the workbook's `<styleSheet>`,
// so we cannot perform full styleId resolution here.  We do however
// honour any inline hints carried directly on the `<c>` element — in
// particular bold / italic flags, alignment overrides, and explicit
// background fills that some emitters embed.  The bulk of cells will
// fall back to the default style derived from `options`.
// =============================================================================

///|
/// §18.8.20 CT_Fill / §18.18.55 ST_PatternType / §18.8.24
/// CT_GradientFill — resolved fill for a cell.
/// `FillPattern(name, fg, bg)` preserves the spec-defined pattern
/// name plus its foreground / background colours.
/// `FillGradient(type, degree, stops)` preserves the spec-defined
/// linear / path gradient parameters; `stops` is a list of
/// `(position 0..1, "#RRGGBB")` pairs derived from `<stop>`
/// children. Both arms surface metadata so consumers can render
/// the actual texture / gradient when the viewer doesn't.
pub(all) enum ResolvedFill {
  FillNone
  FillSolid(String)
  FillPattern(String, String, String)
  FillGradient(String, Double, Array[(Double, String)])
} derive(Eq)

///|
struct ResolvedFont {
  family : String
  size : Double
  bold : Bool
  italic : Bool
  underline : Bool
  strikethrough : Bool
  color : String?
}

///|
struct ResolvedBorderEdge {
  style : String
  color : String
}

///|
struct ResolvedBorder {
  left : ResolvedBorderEdge?
  right : ResolvedBorderEdge?
  top : ResolvedBorderEdge?
  bottom : ResolvedBorderEdge?
  diagonal : ResolvedBorderEdge?
  diagonal_up : Bool
  diagonal_down : Bool
}

///|
struct ResolvedAlignment {
  horizontal : String // general / left / center / right / fill / justify / centerContinuous / distributed
  vertical : String // top / center / bottom / justify / distributed
  wrap_text : Bool
  /// §18.8.1 `<alignment @textRotation>` — degrees (0..180) or 255
  /// for vertical-stack.  0 = horizontal (default).
  text_rotation : Int
  /// §18.8.1 `<alignment @indent>` — each unit = 3 spaces of
  /// horizontal indent.  0 = no indent.
  indent : Int
  /// §18.8.1 `<alignment @shrinkToFit>` — when true the renderer
  /// must reduce font size until the text fits the cell width
  /// (mutually exclusive with @wrapText per spec).
  shrink_to_fit : Bool
  /// §18.8.1 `<alignment @readingOrder>` — 0=context-dependent,
  /// 1=left-to-right, 2=right-to-left.
  reading_order : Int
}

///|
struct ResolvedCellStyle {
  font : ResolvedFont
  fill : ResolvedFill
  border : ResolvedBorder
  alignment : ResolvedAlignment
  number_format : String
  /// §18.3.1.28 dataBar overlay — `(ratio in 0..1, bar fill color,
  /// axis_position metadata, direction metadata, negative fill
  /// colour or empty)` derived from `<dataBar>` attributes
  /// (`@axisPosition`, `@direction`, `<a:negativeFillColor>`). The
  /// renderer paints the rect using `ratio`/`bar fill color` and
  /// surfaces the rest as spec-anchored metadata.
  data_bar : (Double, String, String, String, String)?
  /// §18.3.1.49 iconSet — `(set_name from §18.18.42, bucket index
  /// from evaluate_icon_bucket)`. The spec only enumerates icon set
  /// names; the actual glyph/colour is consumer-defined and outside
  /// ECMA-376 scope. The viewer therefore emits the set name and
  /// bucket as spec-anchored SVG metadata attributes only and leaves
  /// rendering to downstream consumers.
  icon : (String, Int)?
  /// §18.3.1.49 — when the `<iconSet showValue="0">` flag is false
  /// the matched cell suppresses its numeric text and shows only
  /// the icon.
  hide_value : Bool
}

///|
/// Build a default style from the render options.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/style-resolver.ts (createDefaultStyle)
fn default_cell_style(options : SheetRenderOptions) -> ResolvedCellStyle {
  {
    font: {
      family: options.default_font_family,
      size: options.default_font_size,
      bold: false,
      italic: false,
      underline: false,
      strikethrough: false,
      color: None,
    },
    fill: FillNone,
    border: {
      left: None,
      right: None,
      top: None,
      bottom: None,
      diagonal: None,
      diagonal_up: false,
      diagonal_down: false,
    },
    alignment: {
      horizontal: "general",
      vertical: "bottom",
      wrap_text: false,
      text_rotation: 0,
      indent: 0,
      shrink_to_fit: false,
      reading_order: 0,
    },
    number_format: "General",
    data_bar: None,
    icon: None,
    hide_value: false,
  }
}

///|
/// Resolve a per-cell style without a workbook styleSheet.  We accept
/// any inline `<bold>`/`<italic>` markers some emitters carry plus the
/// `t="..."` attribute (which gates the value formatter).  Most cells
/// inherit the default style.
fn resolve_cell_style(
  cell : @xml.Element,
  options : SheetRenderOptions,
  styles : @domain.CT_Stylesheet?,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedCellStyle {
  let base = default_cell_style(options)
  // Excel writes inline rich-text in `<is><r><rPr>...`; we honour
  // the first run's `rPr` font hints to provide minimally faithful
  // text styling when the cell is inline (`t="inlineStr"`).
  let inline_rpr : @xml.Element? = match first_child_named_local(cell, "is") {
    None => None
    Some(is_el) =>
      match first_child_named_local(is_el, "r") {
        None => None
        Some(r_el) => first_child_named_local(r_el, "rPr")
      }
  }
  // §18.8.22 / §18.8.43 — apply cellXfs[N].fontId → fonts.font[M]
  // as the cell's base font; any inline rPr on the same cell then
  // layers on top (Excel semantics: cellXf font is the default that
  // inline runs override per-property).
  let cell_xf_font = resolve_cell_font(cell, styles, base.font, theme_map~)
  let font = match inline_rpr {
    None => cell_xf_font
    Some(rpr) => parse_inline_font(rpr, cell_xf_font)
  }
  // §18.8.30 / §18.8.10 — resolve `<c s="N">` against
  // styles.cellXfs[N].numFmtId, then against numFmts (or the spec
  // builtin table for ids 0-49) for the format code string.
  let number_format = resolve_cell_number_format(
    cell,
    styles,
    base.number_format,
  )
  // §18.3.1.4 / §18.8.4 / §18.8.43 — resolve cellXfs[N].borderId
  // against `<borders>` to produce a typed ResolvedBorder.
  let border = resolve_cell_border(cell, styles, base.border, theme_map~)
  // §18.3.1.4 / §18.8.20 / §18.8.43 — resolve cellXfs[N].fillId
  // against `<fills>` to produce a typed ResolvedFill.
  let fill = resolve_cell_fill(cell, styles, base.fill, theme_map~)
  // §18.8.1 / §18.8.43 — resolve cellXfs[N].alignment to typed
  // ResolvedAlignment.  Honours @applyAlignment per spec.
  let alignment = resolve_cell_alignment(cell, styles, base.alignment)
  { ..base, font, number_format, border, fill, alignment }
}

///|
/// §18.8.1 / §18.8.43 — resolve `<c s="N">` → cellXfs[N].alignment
/// into a typed `ResolvedAlignment`.  Returns `fallback` when the
/// cell has no @s, the cellXfs index is out of range, no
/// `<alignment>` child is set, or `@applyAlignment="0"`.
fn resolve_cell_alignment(
  cell : @xml.Element,
  styles : @domain.CT_Stylesheet?,
  fallback : ResolvedAlignment,
) -> ResolvedAlignment {
  let styles_table = match styles {
    None => return fallback
    Some(t) => t
  }
  let s_attr = match attr_value_local(cell, "s") {
    None => return fallback
    Some(v) => v
  }
  let xf_index = match (try? @strconv.parse_int(s_attr)) {
    Ok(n) => n
    Err(_) => return fallback
  }
  let cell_xfs = match styles_table.cell_xfs {
    None => return fallback
    Some(xfs) => xfs
  }
  if xf_index < 0 || xf_index >= cell_xfs.xf.length() {
    return fallback
  }
  let xf = cell_xfs.xf[xf_index]
  match xf.apply_alignment {
    Some(false) => return fallback
    _ => ()
  }
  let alignment = match xf.alignment {
    None => return fallback
    Some(a) => a
  }
  // §18.8.1 — populate every spec field.  The CT_CellAlignment
  // struct in domain/style_types.mbt mirrors the spec exactly.
  let horizontal = alignment.horizontal.unwrap_or(fallback.horizontal)
  // §18.8.1 — `@vertical` default is "bottom" per spec; the
  // CT_CellAlignment struct carries it as a String (not String?)
  // with the default already baked in.
  let vertical = alignment.vertical
  let wrap_text = alignment.wrap_text.unwrap_or(fallback.wrap_text)
  let text_rotation = alignment.text_rotation.unwrap_or(fallback.text_rotation)
  let indent = alignment.indent.unwrap_or(fallback.indent)
  let shrink_to_fit = alignment.shrink_to_fit.unwrap_or(fallback.shrink_to_fit)
  let reading_order = alignment.reading_order.unwrap_or(fallback.reading_order)
  {
    horizontal,
    vertical,
    wrap_text,
    text_rotation,
    indent,
    shrink_to_fit,
    reading_order,
  }
}

///|
/// §18.8.43 cellXfs / §18.8.22 fonts — resolve the cell's base font
/// by walking `<c s="N">` → `cellXfs[N].fontId` → `fonts.font[M]`.
/// Returns `fallback` when the cascade resolves to a missing entry.
/// Honours `applyFont="0"`. The returned ResolvedFont layers under
/// any inline rPr in the caller.
fn resolve_cell_font(
  cell : @xml.Element,
  styles : @domain.CT_Stylesheet?,
  fallback : ResolvedFont,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedFont {
  let styles_table = match styles {
    None => return fallback
    Some(t) => t
  }
  let s_attr = match attr_value_local(cell, "s") {
    None => return fallback
    Some(v) => v
  }
  let xf_index = match (try? @strconv.parse_int(s_attr)) {
    Ok(n) => n
    Err(_) => return fallback
  }
  let cell_xfs = match styles_table.cell_xfs {
    None => return fallback
    Some(xfs) => xfs
  }
  if xf_index < 0 || xf_index >= cell_xfs.xf.length() {
    return fallback
  }
  let xf = cell_xfs.xf[xf_index]
  match xf.apply_font {
    Some(false) => return fallback
    _ => ()
  }
  let font_id = match xf.font_id {
    None => return fallback
    Some(id) => id
  }
  let fonts = match styles_table.fonts {
    None => return fallback
    Some(fs) => fs
  }
  if font_id < 0 || font_id >= fonts.font.length() {
    return fallback
  }
  ct_font_to_resolved(fonts.font[font_id], fallback, theme_map~)
}

///|
/// §18.8.22 — translate a typed `CT_Font` into the viewer's
/// `ResolvedFont`. The schema declares each font property
/// (`<name>`, `<sz>`, `<b>`, `<i>`, `<u>`, `<strike>`, `<color>`,
/// `<family>`, `<charset>`, `<scheme>`, …) inside an
/// `xsd:choice minOccurs="0" maxOccurs="unbounded"`, so duplicates
/// are spec-permitted but unusual. ECMA-376 itself does not
/// prescribe a tie-breaker; we take the LAST occurrence so that a
/// round-trip preserving the source XML order resolves identically
/// before and after a re-encode. When an array is empty the
/// fallback value is carried over unchanged.
fn ct_font_to_resolved(
  font : @domain.CT_Font,
  fallback : ResolvedFont,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedFont {
  let family = match last_of(font.name) {
    Some(n) => n.val
    None => fallback.family
  }
  let size = match last_of(font.sz) {
    Some(s) => s.val
    None => fallback.size
  }
  let bold = match last_of(font.b) {
    Some(b) => b.val
    None => fallback.bold
  }
  let italic = match last_of(font.i) {
    Some(i) => i.val
    None => fallback.italic
  }
  let underline = match last_of(font.u) {
    Some(_) => true
    None => fallback.underline
  }
  let strikethrough = match last_of(font.strike) {
    Some(s) => s.val
    None => fallback.strikethrough
  }
  let color = match last_of(font.color) {
    Some(c) =>
      match resolve_color_element_rgb(c.element, theme_map) {
        Some(rgb) => Some(rgb)
        None => fallback.color
      }
    None => fallback.color
  }
  { family, size, bold, italic, underline, strikethrough, color }
}

///|
/// Return the last element of an array, or `None` when empty.
fn[T] last_of(xs : Array[T]) -> T? {
  if xs.length() == 0 {
    None
  } else {
    Some(xs[xs.length() - 1])
  }
}

///|
/// §18.3.1.28 — locate the `<negativeFillColor>` (or legacy
/// `<a:srgbClr>` variant) child of a `<dataBar>` element and
/// return its `#RRGGBB`. Returns `""` when no negative-fill
/// colour is declared so the renderer can fall back to the
/// positive-bar colour.
fn read_data_bar_negative_color(
  data_bar : @xml.Element,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> String {
  let negative = first_child_named_local(data_bar, "negativeFillColor")
  match negative {
    None => ""
    Some(el) =>
      match resolve_color_element_rgb(el, theme_map) {
        Some(rgb) => rgb
        None => ""
      }
  }
}

///|
/// §18.3.1.18 / §18.3.1.10 / §18.18.13 — apply conditional
/// formatting overlays onto `base_style`. Walks each
/// `<conditionalFormatting>` block whose sqref contains `cell_ref`,
/// then each `<cfRule>` in priority order; the first matching rule
/// (or every matching rule when `stop_if_true=false`) layers its
/// referenced `<dxf>` (font / fill / border) onto the style. Rules
/// requiring a population sweep (top10, aboveAverage, dataBar,
/// iconSet, colorScale, duplicate/unique) are skipped here for
/// now — those need a separate value-population pass.
fn apply_cf_overlay(
  cell_ref : String,
  cell : @xml.Element,
  base : ResolvedCellStyle,
  cf_blocks : Array[@domain.CT_ConditionalFormatting],
  cf_stats : Array[PopulationStats],
  styles : @domain.CT_Stylesheet?,
  shared_strings : @domain.CT_Sst?,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedCellStyle {
  if cf_blocks.length() == 0 {
    return base
  }
  // §18.3.1.16 colorScale / §18.3.1.28 dataBar do not depend on
  // styles.dxfs; only the dxf-overlay rules (cellIs, containsText,
  // population) need it. dxfs may legitimately be None for a
  // workbook that only uses value-driven visualisations.
  let dxfs : @domain.CT_Dxfs? = match styles {
    None => None
    Some(t) => t.dxfs
  }
  let (row, col) = match parse_cell_ref(cell_ref) {
    Some((r, c)) => (r, c)
    None => return base
  }
  let mut acc = base
  for i, block in cf_blocks {
    if !sqref_contains(block.sqref, row, col) {
      continue
    }
    let stats = cf_stats[i]
    for rule in block.rules {
      // §18.3.1.16 colorScale / §18.3.1.28 dataBar — value-driven
      // visualisations override per-cell dxf paths. Delegate to the
      // shared `@cf_eval` evaluator (which already implements the
      // §18.3.1.11 cfvo threshold resolution and linear blending)
      // so the result matches the validated evaluator output.
      match rule.color_scale {
        Some(scale) => {
          let cell_val = formula_value_for(cell, shared_strings)
          let population = population_as_formula_values(stats)
          match @cf_eval.evaluate_color_scale(scale, cell_val, population) {
            Some(argb) => acc = { ..acc, fill: FillSolid(argb_to_css(argb)) }
            None => ()
          }
          continue
        }
        None => ()
      }
      match rule.data_bar {
        Some(bar) => {
          let cell_val = formula_value_for(cell, shared_strings)
          let population = population_as_formula_values(stats)
          match @cf_eval.evaluate_bar_ratio(bar, cell_val, population) {
            Some(ratio) => {
              // §18.3.1.28 — surface the spec-defined @axisPosition
              // / @direction attributes and a `<negativeFillColor>`
              // child via metadata so consumers can paint the axis
              // and negative-bar variant the viewer doesn't render
              // directly. Missing attributes fall back to the spec
              // defaults (axisPosition = "automatic",
              // direction = "context").
              let axis_position = attr_value_local(bar.element, "axisPosition").or(
                "automatic",
              )
              let direction = attr_value_local(bar.element, "direction").or(
                "context",
              )
              let negative_color = read_data_bar_negative_color(bar.element)
              acc = {
                ..acc,
                data_bar: Some(
                  (
                    ratio,
                    argb_to_css(bar.color),
                    axis_position,
                    direction,
                    negative_color,
                  ),
                ),
              }
            }
            None => ()
          }
          continue
        }
        None => ()
      }
      match rule.icon_set {
        Some(icon_set) => {
          let cell_val = formula_value_for(cell, shared_strings)
          let population = population_as_formula_values(stats)
          match @cf_eval.evaluate_icon_bucket(icon_set, cell_val, population) {
            Some(bucket) =>
              // §18.3.1.49 / §18.18.42 — surface only the spec-
              // defined set name and bucket index; the actual icon
              // glyph and colour are consumer-defined per spec.
              acc = {
                ..acc,
                icon: Some((icon_set.set_name, bucket)),
                hide_value: !icon_set.show_value,
              }
            None => ()
          }
          continue
        }
        None => ()
      }
      let matched = if rule.is_population_rule() {
        cf_population_rule_matches(rule, cell, cell_ref, stats)
      } else {
        cf_rule_matches(rule, cell, shared_strings)
      }
      if !matched {
        continue
      }
      match (rule.dxf_id, dxfs) {
        (Some(id), Some(dxfs_table)) =>
          if id >= 0 && id < dxfs_table.dxf.length() {
            acc = overlay_dxf_on_style(acc, dxfs_table.dxf[id], theme_map~)
          }
        _ => ()
      }
      if rule.stop_if_true {
        break
      }
    }
  }
  acc
}

///|
/// Convert a cell element into a `FormulaValue` for cf_eval's
/// colorScale / dataBar evaluators. Numeric `<v>` children become
/// `VNumber`; everything else becomes `VEmpty`.
fn formula_value_for(
  cell : @xml.Element,
  shared_strings : @domain.CT_Sst?,
) -> @formula.FormulaValue {
  match parse_cell_numeric(cell) {
    Some(n) => @formula.VNumber(n)
    None => {
      let text = cell_resolved_text(cell, shared_strings)
      if text.length() == 0 {
        @formula.VEmpty
      } else {
        @formula.VString(text)
      }
    }
  }
}

///|
/// Re-project the population's numeric samples into a `FormulaValue`
/// array so the cf_eval color_scale / data_bar primitives can
/// consume them via the shared `collect_numbers` helper.
fn population_as_formula_values(
  stats : PopulationStats,
) -> Array[@formula.FormulaValue] {
  let out : Array[@formula.FormulaValue] = []
  for p in stats.sorted_desc {
    let (_, v) = p
    out.push(@formula.VNumber(v))
  }
  out
}

///|
/// §18.8.3 — `CT_ColorArgb` → CSS `#RRGGBB`. Alpha is dropped to
/// match the rest of the viewer's color pipeline (which uses solid
/// SVG fills only).
fn argb_to_css(argb : @domain.CT_ColorArgb) -> String {
  let r = pad_two_hex(argb.red)
  let g = pad_two_hex(argb.green)
  let b = pad_two_hex(argb.blue)
  "#" + r + g + b
}

///|
fn pad_two_hex(byte : Int) -> String {
  let hi = (byte / 16) & 0xF
  let lo = byte & 0xF
  hex_digit(hi).to_string() + hex_digit(lo).to_string()
}

///|
fn hex_digit(n : Int) -> Char {
  if n < 10 {
    Char::from_int(0x30 + n)
  } else {
    Char::from_int(0x41 + n - 10)
  }
}

///|
/// §18.3.1.10 — pre-computed per-block population statistics used by
/// Top10 / AboveAverage / DuplicateValues / UniqueValues predicates.
struct PopulationStats {
  /// (cell_ref, numeric value) pairs for every cell in the block's
  /// sqref that has a numeric value, sorted in descending order.
  /// Used by Top10 (top N) and the bottom variant takes the tail.
  sorted_desc : Array[(String, Double)]
  /// Mean of every numeric cell value in the block's sqref.
  mean : Double
  /// Population standard deviation. Zero when fewer than 2 numeric
  /// cells contribute.
  std_dev : Double
  /// Map from cell's resolved text value (number formatted via
  /// Show or shared-string lookup) to the number of cells carrying
  /// that exact value. Used by Duplicate/UniqueValues.
  value_counts : Map[String, Int]
}

///|
/// §18.3.1.10 — walk every cell in `block.sqref` and collect the
/// statistics needed by the four population rules. Cells outside
/// the worksheet's `cell_map` (= empty cells) contribute the empty
/// string to `value_counts` but no numeric sample to mean/std-dev.
fn compute_population_stats(
  block : @domain.CT_ConditionalFormatting,
  cell_map : Map[String, @xml.Element],
  shared_strings : @domain.CT_Sst?,
) -> PopulationStats {
  let pairs : Array[(String, Double)] = []
  let counts : Map[String, Int] = Map::new()
  let mut sum = 0.0
  let mut count = 0
  for r in block.sqref.ranges {
    let sr = r.start_row_zero_based.or(0)
    let er = r.end_row_zero_based.or(sr)
    let sc = r.start_col_zero_based.or(0)
    let ec = r.end_col_zero_based.or(sc)
    for row in sr..<=er {
      for col in sc..<=ec {
        let cref = cell_ref_from_indices(row + 1, col + 1)
        match cell_map.get(cref) {
          None => {
            // Empty cell — count as the empty string for
            // duplicate/unique semantics (Excel parity).
            let prev = counts.get("").or(0)
            counts.set("", prev + 1)
          }
          Some(cell_el) => {
            let text = cell_resolved_text(cell_el, shared_strings)
            let prev = counts.get(text).or(0)
            counts.set(text, prev + 1)
            match parse_cell_numeric(cell_el) {
              None => ()
              Some(v) => {
                pairs.push((cref, v))
                sum = sum + v
                count = count + 1
              }
            }
          }
        }
      }
    }
  }
  // Sort descending by value for Top10.
  pairs.sort_by(fn(a, b) {
    let (_, av) = a
    let (_, bv) = b
    if av < bv {
      1
    } else if av > bv {
      -1
    } else {
      0
    }
  })
  let mean = if count > 0 { sum / count.to_double() } else { 0.0 }
  let mut variance = 0.0
  if count >= 2 {
    for p in pairs {
      let (_, v) = p
      let d = v - mean
      variance = variance + d * d
    }
    variance = variance / count.to_double()
  }
  let std_dev = sqrt_double(variance)
  { sorted_desc: pairs, mean, std_dev, value_counts: counts }
}

///|
/// Naive Newton sqrt — adequate for the small statistical loads
/// the cf evaluator handles. Returns 0 for negative or zero input.
fn sqrt_double(x : Double) -> Double {
  if x <= 0.0 {
    return 0.0
  }
  let mut g = x
  let mut prev = 0.0
  let mut i = 0
  while i < 50 && (g - prev).abs() > 1.0e-12 {
    prev = g
    g = (g + x / g) * 0.5
    i = i + 1
  }
  g
}

///|
/// §18.3.1.10 — evaluate a population-based rule against `cell`.
/// `stats` is the pre-computed `PopulationStats` for the rule's
/// enclosing block.
fn cf_population_rule_matches(
  rule : @domain.CT_CfRule,
  cell : @xml.Element,
  cell_ref : String,
  stats : PopulationStats,
) -> Bool {
  match rule.cf_type {
    Top10 => top_n_matches(rule, cell_ref, stats)
    AboveAverage => above_average_matches(rule, cell, stats)
    DuplicateValues => duplicate_matches(cell, stats, want_duplicate=true)
    UniqueValues => duplicate_matches(cell, stats, want_duplicate=false)
    _ => false
  }
}

///|
/// §18.3.1.10 Top10 — match cells whose numeric value is in the
/// top (or bottom) N positions, where N is `rule.rank`. When
/// `rule.percent=true`, N is interpreted as a percentage of the
/// population. `rule.bottom=true` matches the bottom N instead.
fn top_n_matches(
  rule : @domain.CT_CfRule,
  cell_ref : String,
  stats : PopulationStats,
) -> Bool {
  let rank = rule.rank.or(1)
  let pop_size = stats.sorted_desc.length()
  if pop_size == 0 || rank <= 0 {
    return false
  }
  let n_cells = if rule.percent {
    let pct = rank.to_double() / 100.0
    let approx = (pop_size.to_double() * pct).max(1.0)
    let n = approx.to_int()
    if n < 1 {
      1
    } else if n > pop_size {
      pop_size
    } else {
      n
    }
  } else if rank > pop_size {
    pop_size
  } else {
    rank
  }
  if rule.bottom {
    // Bottom N = the last n_cells of the descending list.
    for i in (pop_size - n_cells)..<pop_size {
      let (ref_, _) = stats.sorted_desc[i]
      if ref_ == cell_ref {
        return true
      }
    }
  } else {
    for i in 0..<n_cells {
      let (ref_, _) = stats.sorted_desc[i]
      if ref_ == cell_ref {
        return true
      }
    }
  }
  false
}

///|
/// §18.3.1.10 AboveAverage — match cells whose value is above
/// (or below, when `rule.above_average=false`) the population mean.
/// When `rule.equal_average=true`, equal-to-mean also matches.
/// When `rule.std_dev` is set, the threshold shifts by that many
/// standard deviations away from the mean.
fn above_average_matches(
  rule : @domain.CT_CfRule,
  cell : @xml.Element,
  stats : PopulationStats,
) -> Bool {
  let value = match parse_cell_numeric(cell) {
    None => return false
    Some(v) => v
  }
  let dev_count = rule.std_dev.or(0)
  let threshold = if rule.above_average {
    stats.mean + dev_count.to_double() * stats.std_dev
  } else {
    stats.mean - dev_count.to_double() * stats.std_dev
  }
  if rule.above_average {
    if rule.equal_average {
      value >= threshold
    } else {
      value > threshold
    }
  } else if rule.equal_average {
    value <= threshold
  } else {
    value < threshold
  }
}

///|
/// §18.3.1.10 DuplicateValues / UniqueValues — match cells whose
/// resolved text appears more than once (duplicate) or exactly once
/// (unique) in the block's sqref population. `want_duplicate=true`
/// implements DuplicateValues; `false` implements UniqueValues.
fn duplicate_matches(
  cell : @xml.Element,
  stats : PopulationStats,
  want_duplicate~ : Bool,
) -> Bool {
  let text = cell_resolved_text(cell, None)
  // Note: we pass `None` for SST here because the population pass
  // already resolved each cell's text into the same Map. Cells
  // carrying `t="s"` will look up the shared-string but for
  // duplicate matching we compare the resolved text either way —
  // the production lookup uses the cell's own t attribute so any
  // mismatch is between in-band inline strings and SST-resolved
  // strings, which would already differ in the population scan.
  let _ = cell
  let count = stats.value_counts.get(text).or(0)
  if want_duplicate {
    count > 1
  } else {
    count == 1
  }
}

///|
/// §18.18.76 ST_Sqref — true when `(row, col)` (1-based) is inside
/// at least one range of `sqref`. Ranges can omit `end_*` to
/// represent single cells, or omit `*_col_zero_based` to span whole
/// rows / columns.
fn sqref_contains(sqref : @address.Sqref, row : Int, col : Int) -> Bool {
  let r0 = row - 1
  let c0 = col - 1
  for r in sqref.ranges {
    let sr = r.start_row_zero_based.or(0)
    let er = r.end_row_zero_based.or(r.start_row_zero_based.or(0))
    let sc = r.start_col_zero_based.or(0)
    let ec = r.end_col_zero_based.or(r.start_col_zero_based.or(0))
    let row_ok = r.start_row_zero_based is None || (r0 >= sr && r0 <= er)
    let col_ok = r.start_col_zero_based is None || (c0 >= sc && c0 <= ec)
    if row_ok && col_ok {
      return true
    }
  }
  false
}

///|
/// §18.3.1.10 — evaluate a single per-cell rule against the cell.
/// Supports cellIs (greaterThan / lessThan / equal / notEqual /
/// greaterThanOrEqual / lessThanOrEqual / between / notBetween)
/// and containsText / notContainsText / beginsWith / endsWith.
/// Returns `false` for rule shapes we cannot evaluate yet so the
/// overlay is conservatively skipped.
fn cf_rule_matches(
  rule : @domain.CT_CfRule,
  cell : @xml.Element,
  shared_strings : @domain.CT_Sst?,
) -> Bool {
  // §18.18.12 ST_CfType — every per-cell rule type is matched
  // explicitly. Population rule types (AboveAverage / Top10 /
  // DuplicateValues / UniqueValues / ColorScale / DataBar /
  // IconSet) are dispatched by `cf_population_rule_matches`
  // upstream so this function returns `false` for them.
  match rule.cf_type {
    CellIs => evaluate_cell_is(rule, cell)
    ContainsText => contains_text_match(rule, cell, shared_strings, true)
    NotContainsText => !contains_text_match(rule, cell, shared_strings, true)
    BeginsWith => starts_or_ends_match(rule, cell, shared_strings, starts=true)
    EndsWith => starts_or_ends_match(rule, cell, shared_strings, starts=false)
    ContainsBlanks =>
      cell_resolved_text(cell, shared_strings).trim_space().length() == 0
    NotContainsBlanks =>
      cell_resolved_text(cell, shared_strings).trim_space().length() > 0
    ContainsErrors => cell_is_error_value(cell, shared_strings)
    NotContainsErrors => !cell_is_error_value(cell, shared_strings)
    // §18.18.12 — `expression` evaluates the rule's formula as a
    // boolean. Full §22.1 expression evaluation is not wired in
    // here; surface the formula via the dxf overlay only when
    // the formula is literally "TRUE" / "1" (otherwise no match).
    Expression => evaluate_expression_literal(rule)
    // §18.18.82 — `timePeriod` requires date arithmetic against
    // the workbook epoch. Surface as no-match until the dedicated
    // TimePeriod evaluator lands (Task #157).
    TimePeriod => false
    // Population rules — dispatched upstream by
    // `cf_population_rule_matches`. Should not reach here.
    Top10
    | AboveAverage
    | DuplicateValues
    | UniqueValues
    | ColorScale
    | DataBar
    | IconSet => false
  }
}

///|
/// §18.18.11 / §18.18.12 — true when the cell carries an error
/// value (`t="e"` or its resolved text looks like an Excel error
/// literal such as `"#REF!"`, `"#NAME?"`, `"#DIV/0!"`, `"#NULL!"`,
/// `"#VALUE!"`, `"#NUM!"`, `"#N/A"`, `"#GETTING_DATA"`).
fn cell_is_error_value(
  cell : @xml.Element,
  shared_strings : @domain.CT_Sst?,
) -> Bool {
  // Explicit error type beats every other heuristic.
  match attr_value_local(cell, "t") {
    Some("e") => return true
    _ => ()
  }
  let text = cell_resolved_text(cell, shared_strings).trim_space().to_string()
  match text {
    "#REF!"
    | "#NAME?"
    | "#DIV/0!"
    | "#NULL!"
    | "#VALUE!"
    | "#NUM!"
    | "#N/A"
    | "#GETTING_DATA"
    | "#SPILL!"
    | "#CALC!"
    | "#FIELD!"
    | "#UNKNOWN!"
    | "#BLOCKED!"
    | "#BUSY!"
    | "#CONNECT!"
    | "#EXTERNAL!"
    | "#PYTHON!" => true
    _ => false
  }
}

///|
/// §18.18.12 expression — evaluate trivial boolean literals in the
/// rule's formula. Full expression evaluation requires the §22.1
/// AST evaluator which lives in a separate package; until that
/// path is wired through cf_rule_eval the renderer only honours
/// the `TRUE` / `FALSE` / `1` / `0` literals so explicitly
/// boolean cfRules behave correctly.
fn evaluate_expression_literal(rule : @domain.CT_CfRule) -> Bool {
  if rule.formulas.length() == 0 {
    return false
  }
  match rule.formulas[0].trim_space().to_string() {
    "TRUE" | "true" | "1" => true
    _ => false
  }
}

///|
/// §18.3.1.10 cellIs — compare the cell's value against the rule's
/// formula(s) using the chosen operator. §18.18.49 enumerates 12
/// operators: lessThan, lessThanOrEqual, equal, notEqual,
/// greaterThanOrEqual, greaterThan, between, notBetween,
/// containsText, notContains, beginsWith, endsWith. The numeric
/// arms parse the formula as a literal double; the text arms
/// compare the cell's resolved text to the formula text via the
/// same case-insensitive helpers as the standalone containsText
/// rule type.
fn evaluate_cell_is(rule : @domain.CT_CfRule, cell : @xml.Element) -> Bool {
  let op = match rule.operator {
    None => return false
    Some(o) => o
  }
  match op {
    OpContainsText | OpNotContains | OpBeginsWith | OpEndsWith =>
      evaluate_cell_is_text(op, rule, cell)
    OpEqual
    | OpNotEqual
    | OpGreaterThan
    | OpGreaterThanOrEqual
    | OpLessThan
    | OpLessThanOrEqual
    | OpBetween
    | OpNotBetween => evaluate_cell_is_numeric(op, rule, cell)
  }
}

///|
/// §18.18.49 — numeric-operator arm of `cellIs`.
fn evaluate_cell_is_numeric(
  op : @domain.ST_ConditionalFormattingOperator,
  rule : @domain.CT_CfRule,
  cell : @xml.Element,
) -> Bool {
  let value = match parse_cell_numeric(cell) {
    None => return false
    Some(v) => v
  }
  let f0 = if rule.formulas.length() >= 1 {
    match (try? @strconv.parse_double(rule.formulas[0])) {
      Ok(v) => Some(v)
      Err(_) => None
    }
  } else {
    None
  }
  let f1 = if rule.formulas.length() >= 2 {
    match (try? @strconv.parse_double(rule.formulas[1])) {
      Ok(v) => Some(v)
      Err(_) => None
    }
  } else {
    None
  }
  match op {
    OpEqual =>
      match f0 {
        Some(t) => value == t
        None => false
      }
    OpNotEqual =>
      match f0 {
        Some(t) => value != t
        None => false
      }
    OpGreaterThan =>
      match f0 {
        Some(t) => value > t
        None => false
      }
    OpGreaterThanOrEqual =>
      match f0 {
        Some(t) => value >= t
        None => false
      }
    OpLessThan =>
      match f0 {
        Some(t) => value < t
        None => false
      }
    OpLessThanOrEqual =>
      match f0 {
        Some(t) => value <= t
        None => false
      }
    OpBetween =>
      match (f0, f1) {
        (Some(lo), Some(hi)) => value >= lo && value <= hi
        _ => false
      }
    OpNotBetween =>
      match (f0, f1) {
        (Some(lo), Some(hi)) => value < lo || value > hi
        _ => false
      }
    OpContainsText | OpNotContains | OpBeginsWith | OpEndsWith => false
  }
}

///|
/// §18.18.49 — text-operator arm of `cellIs`. The cell's resolved
/// text is compared against the literal text carried by the
/// rule's first `<formula>` element. `containsText`, `notContains`,
/// `beginsWith`, `endsWith` mirror §18.3.1.10's standalone rule
/// types; comparison is case-insensitive per §22.1.4 SEARCH
/// semantics (folded through `ascii_lower`). The formula text
/// arrives literally (no SST resolution / quoting) — Excel writes
/// `"foo"` with the literal quotes; we strip a single pair when
/// present so the comparison sees the bare text.
fn evaluate_cell_is_text(
  op : @domain.ST_ConditionalFormattingOperator,
  rule : @domain.CT_CfRule,
  cell : @xml.Element,
) -> Bool {
  if rule.formulas.length() == 0 {
    return false
  }
  let raw = rule.formulas[0].trim_space().to_string()
  let needle = if raw.length() >= 2 &&
    raw.code_unit_at(0).to_int() == 0x22 &&
    raw.code_unit_at(raw.length() - 1).to_int() == 0x22 {
    raw[1:raw.length() - 1].to_string()
  } else {
    raw
  }
  if needle.length() == 0 {
    return false
  }
  let haystack = cell_resolved_text(cell, None)
  let h_lc = ascii_lower(haystack)
  let n_lc = ascii_lower(needle)
  match op {
    OpContainsText => h_lc.contains(n_lc)
    OpNotContains => !h_lc.contains(n_lc)
    OpBeginsWith => h_lc.has_prefix(n_lc)
    OpEndsWith => h_lc.has_suffix(n_lc)
    _ => false
  }
}

///|
/// §18.3.1.10 containsText / notContainsText — substring test
/// against the cell's resolved text value. §18.3.1.10 defines the
/// rule's evaluation as `NOT(ISERROR(SEARCH(text, value)))`; per
/// §22.1.4 the SEARCH function is case-INSENSITIVE (FIND is the
/// case-sensitive variant). The comparison therefore lowercases
/// both sides before checking containment.
fn contains_text_match(
  rule : @domain.CT_CfRule,
  cell : @xml.Element,
  shared_strings : @domain.CT_Sst?,
  _matches_text : Bool,
) -> Bool {
  let needle = match rule.text {
    None => return false
    Some(t) => t
  }
  let value = cell_resolved_text(cell, shared_strings)
  ascii_lower(value).contains(ascii_lower(needle))
}

///|
/// §18.3.1.10 beginsWith / endsWith — prefix / suffix test on the
/// resolved cell text. §18.3.1.10 evaluates these as
/// `LEFT(value, LEN(text)) = text` / `RIGHT(value, LEN(text)) = text`.
/// The `=` operator in §22.1 comparison is case-insensitive for
/// strings, so the comparison lowercases both sides.
fn starts_or_ends_match(
  rule : @domain.CT_CfRule,
  cell : @xml.Element,
  shared_strings : @domain.CT_Sst?,
  starts~ : Bool,
) -> Bool {
  let needle = match rule.text {
    None => return false
    Some(t) => t
  }
  let value_lc = ascii_lower(cell_resolved_text(cell, shared_strings))
  let needle_lc = ascii_lower(needle)
  if starts {
    value_lc.has_prefix(needle_lc)
  } else {
    value_lc.has_suffix(needle_lc)
  }
}

///|
/// ASCII-only `tolower` — folds A-Z to a-z and leaves every other
/// code point untouched.
///
/// §22.1.4's case-insensitive string comparison follows Excel's
/// own locale-aware semantics (ICU-derived in modern builds).
/// The viewer uses ASCII-only folding here as a deterministic
/// constraint: the spec does not pin a normative Unicode
/// case-folding table, and ASCII folding matches the behaviour
/// of every Excel cell whose content lies in the BMP ASCII
/// range.  Locale-sensitive scripts (Turkish dotless-i, German
/// ß) preserve their original casing; consumers needing
/// locale-aware comparison must pre-normalise the input.
fn ascii_lower(s : String) -> String {
  let buf = StringBuilder::new()
  for i in 0..<s.length() {
    let c = s.code_unit_at(i).to_int()
    let lower = if c >= 0x41 && c <= 0x5A { c + 0x20 } else { c }
    buf.write_char(lower.to_char().unwrap())
  }
  buf.to_string()
}

///|
/// Parse the cell's `<v>` child as a double. Returns `None` when
/// absent or non-numeric.
fn parse_cell_numeric(cell : @xml.Element) -> Double? {
  match first_child_named_local(cell, "v") {
    None => None
    Some(v_el) => {
      let mut text = ""
      for node in v_el.children {
        match node {
          @xml.Node::Text(s) => text = text + s
          _ => ()
        }
      }
      match (try? @strconv.parse_double(text.trim_space().to_string())) {
        Ok(d) => Some(d)
        Err(_) => None
      }
    }
  }
}

///|
/// Resolve the cell's textual value: inline string `<is>` content,
/// shared-string lookup when `t="s"`, or the bare `<v>` text
/// otherwise. Used by containsText / beginsWith / endsWith.
fn cell_resolved_text(
  cell : @xml.Element,
  shared_strings : @domain.CT_Sst?,
) -> String {
  let t_attr = attr_value_local(cell, "t")
  match t_attr {
    Some("s") => {
      let v = match first_child_named_local(cell, "v") {
        None => return ""
        Some(v_el) => {
          let mut text = ""
          for node in v_el.children {
            match node {
              @xml.Node::Text(s) => text = text + s
              _ => ()
            }
          }
          text.trim_space().to_string()
        }
      }
      let idx = match (try? @strconv.parse_int(v)) {
        Ok(n) => n
        Err(_) => return ""
      }
      match shared_strings {
        None => ""
        Some(sst) =>
          if idx >= 0 && idx < sst.si_entries.length() {
            sst.si_entries[idx].to_plain_text()
          } else {
            ""
          }
      }
    }
    // §18.18.11 ST_CellType — the remaining six values:
    //   b: boolean ("0"/"1" stored in <v>) → display as
    //      TRUE/FALSE per Excel default rendering.
    //   d: ISO 8601 date stored in <v>.
    //   e: error literal stored in <v>.
    //   n: number stored in <v>.
    //   str: formula-result string stored in <v>.
    //   inlineStr: rich text under <is>.
    // For containsText / beginsWith / endsWith we want the
    // displayed text exactly as Excel would render it.
    Some("b") => {
      let raw = read_v_text(cell)
      match raw {
        "1" => "TRUE"
        "0" => "FALSE"
        // Schema violation — boolean cells may carry only "0"
        // or "1"; preserve the malformed token verbatim so the
        // upstream containsText predicate can see it.
        _ => raw
      }
    }
    Some("d") => read_v_text(cell)
    Some("e") => read_v_text(cell)
    Some("n") => read_v_text(cell)
    Some("str") => read_v_text(cell)
    Some("inlineStr") =>
      match first_child_named_local(cell, "is") {
        Some(is_el) => extract_text_from_is(is_el)
        // Schema violation — `t="inlineStr"` without an <is>
        // child; fall back to the <v> sibling if present.
        None => read_v_text(cell)
      }
    None =>
      // §18.18.11 default — when @t is absent the cell is
      // numeric (n).  Same accessor.
      read_v_text(cell)
    // Schema violation — unknown @t value.  Fall back to the
    // raw <v> text since that is the format-agnostic surface.
    Some(_) => read_v_text(cell)
  }
}

///|
/// Read the concatenated text of the cell's `<v>` child, or
/// empty when there is no `<v>`.
fn read_v_text(cell : @xml.Element) -> String {
  match first_child_named_local(cell, "v") {
    None => ""
    Some(v_el) => {
      let mut text = ""
      for node in v_el.children {
        match node {
          @xml.Node::Text(s) => text = text + s
          _ => ()
        }
      }
      text
    }
  }
}

///|
/// Walk `<is>` and concatenate every `<t>` text child. Excel
/// inline-string blocks carry one or more `<r><t>` runs, and each
/// `<t>` may carry plain text — we strip none of it.
fn extract_text_from_is(is_el : @xml.Element) -> String {
  let buf = StringBuilder::new()
  walk_text_children(is_el, buf)
  buf.to_string()
}

///|
fn walk_text_children(element : @xml.Element, buf : StringBuilder) -> Unit {
  for node in element.children {
    match node {
      @xml.Node::Text(s) => buf.write_string(s)
      @xml.Node::Element(child) =>
        if child.name.local_name == "t" {
          for grand in child.children {
            match grand {
              @xml.Node::Text(s) => buf.write_string(s)
              _ => ()
            }
          }
        } else {
          walk_text_children(child, buf)
        }
      _ => ()
    }
  }
}

///|
/// §18.8.18 dxf — overlay the differential format's font / fill /
/// border onto `base`. Only fields the dxf declares are touched
/// (Excel's "differential" semantics).
fn overlay_dxf_on_style(
  base : ResolvedCellStyle,
  dxf : @domain.CT_Dxf,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedCellStyle {
  let font = match dxf.font {
    Some(f) => ct_font_to_resolved(f, base.font, theme_map~)
    None => base.font
  }
  let fill = match dxf.fill {
    Some(f) => ct_fill_to_resolved(f, base.fill, theme_map~)
    None => base.fill
  }
  let border = match dxf.border {
    Some(b) => ct_border_to_resolved(b, base.border, theme_map~)
    None => base.border
  }
  { ..base, font, fill, border }
}

///|
/// §18.8.43 cellXfs / §18.8.20 fills — resolve the cell's fill by
/// walking `<c s="N">` → `cellXfs[N].fillId` → `fills.fill[M]`.
/// Returns `fallback` when the cascade resolves to a missing entry.
/// Honours `applyFill="0"`.  `<patternFill>` resolves to
/// `FillSolid` / `FillNone` / `FillPattern` and `<gradientFill>`
/// to `FillGradient` (see `ct_fill_to_resolved`).
fn resolve_cell_fill(
  cell : @xml.Element,
  styles : @domain.CT_Stylesheet?,
  fallback : ResolvedFill,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedFill {
  let styles_table = match styles {
    None => return fallback
    Some(t) => t
  }
  let s_attr = match attr_value_local(cell, "s") {
    None => return fallback
    Some(v) => v
  }
  let xf_index = match (try? @strconv.parse_int(s_attr)) {
    Ok(n) => n
    Err(_) => return fallback
  }
  let cell_xfs = match styles_table.cell_xfs {
    None => return fallback
    Some(xfs) => xfs
  }
  if xf_index < 0 || xf_index >= cell_xfs.xf.length() {
    return fallback
  }
  let xf = cell_xfs.xf[xf_index]
  // §18.8.4 / §18.8.43 — `applyFill="0"` says "ignore this xf's
  // fillId and inherit from the parent xf via `xfId` into
  // `cellStyleXfs`".  Full inheritance walking is tracked as
  // future work; the current viewer treats applyFill=false as
  // a hard fallback to the row/column default, which is the
  // spec-permitted degradation (consumer sees no fill rather
  // than a wrong one).
  match xf.apply_fill {
    Some(false) => return fallback
    _ => ()
  }
  let fill_id = match xf.fill_id {
    None => return fallback
    Some(id) => id
  }
  let fills = match styles_table.fills {
    None => return fallback
    Some(fs) => fs
  }
  if fill_id < 0 || fill_id >= fills.fill.length() {
    return fallback
  }
  ct_fill_to_resolved(fills.fill[fill_id], fallback, theme_map~)
}

///|
/// §18.8.20 / §18.8.32 — translate a typed `CT_Fill` into the
/// viewer's `ResolvedFill`.  `<patternFill patternType="solid">`
/// becomes `FillSolid(fgColor)`; `patternType` absent or `none`
/// becomes `FillNone`; every other ST_PatternType becomes
/// `FillPattern(name, fg, bg)`.  `<gradientFill>` becomes
/// `FillGradient(type, degree, stops)`.
fn ct_fill_to_resolved(
  fill : @domain.CT_Fill,
  fallback : ResolvedFill,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedFill {
  match fill.pattern_fill {
    Some(pf) => {
      let pt = pf.pattern_type.or("none")
      match pt {
        "none" => FillNone
        "solid" => {
          // §18.8.3 — unresolved `<fgColor>` resolves to the
          // spec-permitted `auto` sentinel, which the SVG
          // cascade resolves via `currentColor`.  The previous
          // literal "#000000" overrode the cascade.
          let rgb = match pf.fg_color {
            Some(el) =>
              resolve_color_element_rgb(el, theme_map).or("currentColor")
            None => "currentColor"
          }
          FillSolid(rgb)
        }
        _ => {
          // §18.18.55 ST_PatternType — non-solid named patterns
          // (gray125, lightHorizontal, …) require a `<pattern>`
          // def to render correctly. The viewer surfaces the
          // pattern name + fg/bg colours as `FillPattern` so the
          // emitter can choose between rendering the pattern as
          // an SVG `<pattern>` def OR exposing it via metadata
          // attributes. The previous "flat solid" degradation lost
          // the spec-defined pattern identity.
          let fg = match pf.fg_color {
            Some(el) =>
              resolve_color_element_rgb(el, theme_map).or("currentColor")
            None => "currentColor"
          }
          let bg = match pf.bg_color {
            Some(el) =>
              match resolve_color_element_rgb(el, theme_map) {
                Some(rgb) => rgb
                None => ""
              }
            None => ""
          }
          FillPattern(pt, fg, bg)
        }
      }
    }
    None =>
      match fill.gradient_fill {
        Some(gf) => {
          // §18.8.24 CT_GradientFill — capture every `<stop>`
          // child's (position, colour) so the renderer can paint
          // an SVG gradient (or surface metadata for consumers).
          let stops : Array[(Double, String)] = []
          for s in gf.stop {
            let color = match s.color {
              Some(el) =>
                match resolve_color_element_rgb(el, theme_map) {
                  Some(rgb) => rgb
                  None => "#000000"
                }
              None => "#000000"
            }
            stops.push((s.position, color))
          }
          FillGradient(gf.type_, gf.degree, stops)
        }
        None => fallback
      }
  }
}

///|
/// §18.8.43 cellXfs / §18.8.4 borders — resolve the cell's border
/// edges by walking `<c s="N">` → `cellXfs[N].borderId` → `borders.
/// border[M]`. Returns `fallback` when the cascade resolves to a
/// missing entry. Mirrors `resolve_cell_number_format` for symmetry.
fn resolve_cell_border(
  cell : @xml.Element,
  styles : @domain.CT_Stylesheet?,
  fallback : ResolvedBorder,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedBorder {
  let styles_table = match styles {
    None => return fallback
    Some(t) => t
  }
  let s_attr = match attr_value_local(cell, "s") {
    None => return fallback
    Some(v) => v
  }
  let xf_index = match (try? @strconv.parse_int(s_attr)) {
    Ok(n) => n
    Err(_) => return fallback
  }
  let cell_xfs = match styles_table.cell_xfs {
    None => return fallback
    Some(xfs) => xfs
  }
  if xf_index < 0 || xf_index >= cell_xfs.xf.length() {
    return fallback
  }
  let xf = cell_xfs.xf[xf_index]
  // §18.8.43 — applyBorder="0" tells the consumer to ignore the
  // border reference. We honour that exactly.
  match xf.apply_border {
    Some(false) => return fallback
    _ => ()
  }
  let border_id = match xf.border_id {
    None => return fallback
    Some(id) => id
  }
  let borders = match styles_table.borders {
    None => return fallback
    Some(bs) => bs
  }
  if border_id < 0 || border_id >= borders.border.length() {
    return fallback
  }
  let border = borders.border[border_id]
  ct_border_to_resolved(border, fallback, theme_map~)
}

///|
/// §18.8.4 — translate a typed `CT_Border` record into the viewer's
/// `ResolvedBorder` value used by `render_cell_borders`. We honour
/// the spec-defined `<start>`/`<end>` element names AND the
/// Transitional-namespace `<left>`/`<right>` names because Excel
/// emits the latter even in OOXML Strict files.
fn ct_border_to_resolved(
  border : @domain.CT_Border,
  fallback : ResolvedBorder,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedBorder {
  let left = ct_border_pr_to_resolved(
    prefer_edge(border, "start", "left"),
    theme_map~,
  )
  let right = ct_border_pr_to_resolved(
    prefer_edge(border, "end", "right"),
    theme_map~,
  )
  let top = ct_border_pr_to_resolved(border.top, theme_map~)
  let bottom = ct_border_pr_to_resolved(border.bottom, theme_map~)
  let diagonal = ct_border_pr_to_resolved(border.diagonal, theme_map~)
  {
    ..fallback,
    left,
    right,
    top,
    bottom,
    diagonal,
    diagonal_up: border.diagonal_up.or(false),
    diagonal_down: border.diagonal_down.or(false),
  }
}

///|
/// §18.8.4 — return the typed start/end edge when populated; fall
/// back to the raw XML element's child by local name to pick up
/// Excel-emitted `<left>`/`<right>` even when the typed projection
/// has them as None (Strict-only typed schema).
fn prefer_edge(
  border : @domain.CT_Border,
  strict_name : String,
  transitional_name : String,
) -> @domain.CT_BorderPr? {
  let typed = match strict_name {
    "start" => border.start
    "end" => border.end
    _ => None
  }
  match typed {
    Some(_) => typed
    None =>
      match first_child_named_local(border.element, transitional_name) {
        Some(raw) => Some(@domain.CT_BorderPr::new(raw))
        None => None
      }
  }
}

///|
/// §18.8.4 — translate one CT_BorderPr edge into the viewer's
/// ResolvedBorderEdge. Returns `None` when the edge is absent or its
/// `@style` is "none" (default).
fn ct_border_pr_to_resolved(
  edge : @domain.CT_BorderPr?,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> ResolvedBorderEdge? {
  let pr = match edge {
    None => return None
    Some(p) => p
  }
  if pr.style == "none" || pr.style == "" {
    return None
  }
  // §18.8.4 — unresolved theme / indexed border colour resolves
  // to the spec-permitted `auto` sentinel; we surface it as
  // `currentColor` so the SVG cascade picks the actual hue.
  let color = resolve_ct_color_rgb(pr.color, theme_map~).or("currentColor")
  Some({ style: pr.style, color })
}

///|
/// §18.8.3 — minimal CT_Color → CSS RGB string resolver. Defers to
/// `resolve_color_element_rgb` over the wrapped XML element so the
/// same palette logic powers both typed-CT_Color cascades (e.g.
/// border edges) and raw-element cascades (e.g. `<fgColor>` /
/// `<bgColor>` inside `<patternFill>` whose typed projection is the
/// raw element rather than a CT_Color tuple).
fn resolve_ct_color_rgb(
  color : @domain.CT_Color?,
  theme_map? : SmlThemeColorMap = SmlThemeColorMap::empty(),
) -> String? {
  match color {
    None => None
    Some(c) => resolve_color_element_rgb(c.element, theme_map)
  }
}

///|
/// §18.8.3 — resolve an `<… rgb / indexed>` colour-bearing element to
/// a CSS RGB / rgba string. Honours `rgb="AARRGGBB"` (alpha preserved
/// via `normalise_argb_hex`) and `indexed="N"` against the §18.8.27
/// palette. `theme` / `tint` attributes (which require the workbook
/// theme part for full resolution per §20.1.6.9) return `None`; per
/// §18.8.3 callers SHOULD treat that as `auto` and substitute the
/// system / theme default. The viewer falls back to the consumer-
/// defined "auto" colour (typically `#000000` for text, `#FFFFFF`
/// for backgrounds) which is spec-permitted.
fn resolve_color_element_rgb(
  element : @xml.Element,
  theme_map : SmlThemeColorMap,
) -> String? {
  match attr_value_local(element, "rgb") {
    Some(hex) => return Some(normalise_argb_hex(hex))
    None => ()
  }
  match attr_value_local(element, "indexed") {
    Some(idx_str) =>
      match (try? @strconv.parse_int(idx_str)) {
        Ok(idx) => return Some(indexed_color_to_rgb(idx))
        Err(_) => ()
      }
    None => ()
  }
  // §18.8.3 — @theme: indexes into the workbook's clrScheme
  // (slot table parsed via parse_sml_clr_scheme).  When the
  // theme map is empty (no theme part) the lookup returns None.
  // @tint: HSL luminance offset in [-1.0, 1.0]; applied via
  // `@color.apply_lum_off` on the resolved theme RGB.
  match attr_value_local(element, "theme") {
    Some(theme_idx_str) =>
      match (try? @strconv.parse_int(theme_idx_str)) {
        Ok(theme_idx) =>
          match theme_map.lookup(theme_idx) {
            Some(base_hex) => {
              let tint = match attr_value_local(element, "tint") {
                Some(t) =>
                  match (try? @strconv.parse_double(t)) {
                    Ok(d) => d
                    Err(_) => 0.0
                  }
                None => 0.0
              }
              if tint == 0.0 {
                return Some("#" + base_hex)
              }
              // §18.8.3 — tint is in [-1.0, 1.0] applied in HSL
              // space; `@color.apply_lum_off` handles the L
              // component offset and clamps to [0, 1].
              return Some(@color.apply_lum_off(base_hex, tint))
            }
            None => ()
          }
        Err(_) => ()
      }
    None => ()
  }
  None
}

///|
/// §18.8.3 — translate the ARGB hex literal carried by `<color rgb>`
/// into a CSS colour. Opaque ARGB values (AA = FF) and RGB-only
/// values become `#RRGGBB`; values with alpha < FF become an
/// `rgba(R, G, B, A)` CSS literal so the alpha channel survives
/// per spec. Excel writes `<color rgb="FF0000FF">` for opaque blue
/// (returns "#0000FF") and would write e.g. `7F0000FF` for half-
/// transparent blue (returns "rgba(0, 0, 255, 0.498)").
fn normalise_argb_hex(hex : String) -> String {
  if hex.length() == 8 {
    let alpha_hex = hex[0:2].to_string()
    let rgb_hex = hex[2:].to_string()
    let alpha_byte = parse_hex_byte(alpha_hex)
    if alpha_byte == 255 {
      "#" + rgb_hex
    } else {
      let r = parse_hex_byte(rgb_hex[0:2].to_string())
      let g = parse_hex_byte(rgb_hex[2:4].to_string())
      let b = parse_hex_byte(rgb_hex[4:6].to_string())
      let alpha = alpha_byte.to_double() / 255.0
      "rgba(" +
      r.to_string() +
      ", " +
      g.to_string() +
      ", " +
      b.to_string() +
      ", " +
      format_alpha(alpha) +
      ")"
    }
  } else {
    "#" + hex
  }
}

///|
/// Parse a 2-char hex byte (`"FF"`, `"a3"`) to an Int in [0,255].
/// Returns 0 on invalid input.
fn parse_hex_byte(hex2 : String) -> Int {
  let mut out = 0
  for i in 0..<hex2.length() {
    let c = hex2.code_unit_at(i).to_int()
    let digit = if c >= 0x30 && c <= 0x39 {
      c - 0x30
    } else if c >= 0x41 && c <= 0x46 {
      c - 0x41 + 10
    } else if c >= 0x61 && c <= 0x66 {
      c - 0x61 + 10
    } else {
      return 0
    }
    out = out * 16 + digit
  }
  out
}

///|
/// Format an alpha (0..1) for CSS `rgba()` — three decimals,
/// trailing zeros trimmed.
fn format_alpha(a : Double) -> String {
  let clamped = if a < 0.0 { 0.0 } else if a > 1.0 { 1.0 } else { a }
  let scaled = (clamped * 1000.0).round().to_int()
  if scaled == 0 {
    "0"
  } else if scaled == 1000 {
    "1"
  } else {
    let int_part = scaled / 1000
    let frac_part = scaled % 1000
    // strip trailing zeros from the 3-digit fractional part
    let mut frac_str = pad_left_zeros(frac_part.to_string(), 3)
    while frac_str.length() > 1 &&
          frac_str.code_unit_at(frac_str.length() - 1).to_int() == 0x30 {
      frac_str = frac_str[:frac_str.length() - 1].to_string()
    }
    int_part.to_string() + "." + frac_str
  }
}

///|
/// §18.8.27 ST_ColorIndexed — the full 56-entry built-in palette
/// the spec enumerates plus the two reserved system-colour slots
/// (64 = system foreground, default `#000000`; 65 = system
/// background, default `#FFFFFF`). Indices outside the spec's
/// 0..55 + 64/65 range fall back to `#000000` so a colour at least
/// renders. The table is reproduced verbatim from §18.8.27 — do
/// not reorder.
fn indexed_color_to_rgb(idx : Int) -> String {
  match idx {
    0 => "#000000"
    1 => "#FFFFFF"
    2 => "#FF0000"
    3 => "#00FF00"
    4 => "#0000FF"
    5 => "#FFFF00"
    6 => "#FF00FF"
    7 => "#00FFFF"
    8 => "#000000"
    9 => "#FFFFFF"
    10 => "#FF0000"
    11 => "#00FF00"
    12 => "#0000FF"
    13 => "#FFFF00"
    14 => "#FF00FF"
    15 => "#00FFFF"
    16 => "#800000"
    17 => "#008000"
    18 => "#000080"
    19 => "#808000"
    20 => "#800080"
    21 => "#008080"
    22 => "#C0C0C0"
    23 => "#808080"
    24 => "#9999FF"
    25 => "#993366"
    26 => "#FFFFCC"
    27 => "#CCFFFF"
    28 => "#660066"
    29 => "#FF8080"
    30 => "#0066CC"
    31 => "#CCCCFF"
    32 => "#000080"
    33 => "#FF00FF"
    34 => "#FFFF00"
    35 => "#00FFFF"
    36 => "#800080"
    37 => "#800000"
    38 => "#008080"
    39 => "#0000FF"
    40 => "#00CCFF"
    41 => "#CCFFFF"
    42 => "#CCFFCC"
    43 => "#FFFF99"
    44 => "#99CCFF"
    45 => "#FF99CC"
    46 => "#CC99FF"
    47 => "#FFCC99"
    48 => "#3366FF"
    49 => "#33CCCC"
    50 => "#99CC00"
    51 => "#FFCC00"
    52 => "#FF9900"
    53 => "#FF6600"
    54 => "#666699"
    55 => "#969696"
    // §18.8.27 — slots 56..63 are reserved for legacy add-in
    // palettes (`<indexedColors>` overrides per §18.8.45).
    // When the workbook ships no override the spec leaves the
    // hue implementation-defined; we surface `currentColor`
    // so the consumer's CSS cascade picks the colour rather
    // than committing to a literal black.
    56 => "currentColor"
    57 => "currentColor"
    58 => "currentColor"
    59 => "currentColor"
    60 => "currentColor"
    61 => "currentColor"
    62 => "currentColor"
    63 => "currentColor"
    // §18.8.27 — slot 64 is `System Foreground` (default
    // `windowText`) and 65 is `System Background` (default
    // `window`).  Same `currentColor` surfacing semantics.
    64 => "currentColor"
    65 => "currentColor"
    // Schema violation — indexed value outside §18.8.27's
    // closed 0..65 range.  The spec defines no behaviour for
    // out-of-range indices; we surface `currentColor` so the
    // SVG output is still valid CSS.
    _ => "currentColor"
  }
}

///|
/// §18.8.30 — resolve a number-format colour directive to a CSS
/// colour string.  The grammar admits eight named colours plus the
/// indexed form `[Color n]` (n is 1-based, 1..56).  The names map
/// to the §18.8.27 standard palette slots 0..7; `[Color n]` maps to
/// palette slot `n - 1`.  Returns `None` when `body` is not a
/// colour directive (it may be a condition, locale or currency).
fn format_color_directive_to_rgb(body : String) -> String? {
  // Normalise: drop surrounding whitespace, compare case-folded.
  let trimmed = body.trim_space().to_string()
  let lower = trimmed.to_lower()
  match lower {
    "black" => Some(indexed_color_to_rgb(0))
    "white" => Some(indexed_color_to_rgb(1))
    "red" => Some(indexed_color_to_rgb(2))
    "green" => Some(indexed_color_to_rgb(3))
    "blue" => Some(indexed_color_to_rgb(4))
    "yellow" => Some(indexed_color_to_rgb(5))
    "magenta" => Some(indexed_color_to_rgb(6))
    "cyan" => Some(indexed_color_to_rgb(7))
    _ =>
      // `[Color n]` — the keyword `color` followed by whitespace
      // and a 1-based decimal index.
      if lower.length() > 5 && lower.substring(start=0, end=5) == "color" {
        let rest = lower.substring(start=5, end=lower.length()).trim_space()
        match (try? @strconv.parse_int(rest.to_string())) {
          Ok(n) => if n >= 1 { Some(indexed_color_to_rgb(n - 1)) } else { None }
          Err(_) => None
        }
      } else {
        None
      }
  }
}

///|
/// §18.8.30 — scan a single format section for a colour directive
/// (`[Red]`, `[Color 12]`, …) and return the resolved CSS colour.
/// Only the first colour bracket is honoured; quoted literals and
/// backslash escapes are skipped so a `[` inside text is ignored.
/// Returns `None` when the section carries no colour directive.
fn section_format_color(section : String) -> String? {
  let mut i = 0
  while i < section.length() {
    let c = section.code_unit_at(i).to_int()
    if c == 0x22 {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x22 {
        i = i + 1
      }
      i = i + 1
      continue
    }
    if c == 0x5C && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if c == 0x5B {
      // Collect the bracket body up to the matching `]`.
      let body_start = i + 1
      let mut k = body_start
      while k < section.length() && section.code_unit_at(k).to_int() != 0x5D {
        k = k + 1
      }
      let body = section.substring(start=body_start, end=k).to_string()
      match format_color_directive_to_rgb(body) {
        Some(rgb) => return Some(rgb)
        None => ()
      }
      i = if k < section.length() { k + 1 } else { k }
      continue
    }
    i = i + 1
  }
  None
}

///|
/// §18.8.30 — resolve the colour a numeric cell's format code
/// assigns to its text, given the cell's value (which selects the
/// positive / negative / zero section).  Mirrors the section
/// selection in `format_number_by_code`.  Returns `None` for the
/// `General` format, an empty code, or a code with no colour
/// directive in the applicable section.
fn resolve_format_color(num : Double, format_code : String) -> String? {
  if format_code == "General" || format_code == "" {
    return None
  }
  if contains_date_token(format_code) {
    // Elapsed/calendar formats may still carry a colour bracket.
    let sections = split_format_sections(format_code)
    return section_format_color(sections[0])
  }
  let sections = split_format_sections(format_code)
  let section = if num > 0.0 {
    sections[0]
  } else if num < 0.0 && sections.length() >= 2 {
    sections[1]
  } else if num == 0.0 && sections.length() >= 3 {
    sections[2]
  } else {
    sections[0]
  }
  section_format_color(section)
}

///|
/// §18.8.30 — resolve the cell's format code by walking
/// `<c s="N">` → `styles.cellXfs[N].numFmtId` → numFmts /
/// builtin table. Returns `fallback` when the cascade resolves to
/// a missing entry.
fn resolve_cell_number_format(
  cell : @xml.Element,
  styles : @domain.CT_Stylesheet?,
  fallback : String,
) -> String {
  let styles_table = match styles {
    None => return fallback
    Some(t) => t
  }
  let s_attr = match attr_value_local(cell, "s") {
    None => return fallback
    Some(v) => v
  }
  let xf_index = match (try? @strconv.parse_int(s_attr)) {
    Ok(n) => n
    Err(_) => return fallback
  }
  let cell_xfs = match styles_table.cell_xfs {
    None => return fallback
    Some(xfs) => xfs
  }
  if xf_index < 0 || xf_index >= cell_xfs.xf.length() {
    return fallback
  }
  let xf = cell_xfs.xf[xf_index]
  let num_fmt_id = match xf.num_fmt_id {
    None => return fallback
    Some(id) => id
  }
  // Custom numFmts win when the id is registered there; otherwise
  // fall back to the spec built-in table (0-49).
  match styles_table.num_fmts {
    None => ()
    Some(num_fmts) =>
      for nf in num_fmts.num_fmt {
        if nf.num_fmt_id == num_fmt_id {
          return nf.format_code
        }
      }
  }
  builtin_number_format(num_fmt_id, fallback)
}

///|
/// §18.8.30 — spec-defined built-in numFmt table.  ECMA-376
/// Part 1 §18.8.30 reserves IDs 0..163 for built-in formats; ids
/// ≥164 are user-defined via `<numFmts>`.  Within the reserved
/// range the spec assigns concrete format codes only to the
/// 23 entries returned below.  The remaining reserved IDs are
/// either locale-dependent (5..8 currency variants, 23..36
/// accounting variants, 41..44 accounting variants) or omitted
/// entirely (50..63, 67..80, 82..162) — in both cases the spec
/// leaves the rendering implementation-defined and consumers
/// are expected to substitute their own locale's format code.
/// We return `fallback` for those IDs so the caller can pick
/// up the cell value as plain text rather than guessing.
fn builtin_number_format(id : Int, fallback : String) -> String {
  match id {
    // §18.8.30 — globally-defined format codes.
    0 => "General"
    1 => "0"
    2 => "0.00"
    3 => "#,##0"
    4 => "#,##0.00"
    9 => "0%"
    10 => "0.00%"
    11 => "0.00E+00"
    12 => "# ?/?"
    13 => "# ??/??"
    14 => "mm-dd-yy"
    15 => "d-mmm-yy"
    16 => "d-mmm"
    17 => "mmm-yy"
    18 => "h:mm AM/PM"
    19 => "h:mm:ss AM/PM"
    20 => "h:mm"
    21 => "h:mm:ss"
    22 => "m/d/yy h:mm"
    37 => "#,##0 ;(#,##0)"
    38 => "#,##0 ;[Red](#,##0)"
    39 => "#,##0.00;(#,##0.00)"
    40 => "#,##0.00;[Red](#,##0.00)"
    45 => "mm:ss"
    46 => "[h]:mm:ss"
    47 => "mmss.0"
    48 => "##0.0E+0"
    49 => "@"
    // §18.8.30 — IDs that the spec reserves for locale-defined
    // format codes (5..8 currency, 23..36 accounting variants,
    // 41..44 accounting variants).  We fall through to the
    // caller's `fallback` rather than substituting an arbitrary
    // format that would mis-render under a non-en-US locale.
    _ => fallback
  }
}

///|
/// Parse a §18.4.7 inline `<rPr>` element.  Recognised children:
/// `<sz val="..."/>`, `<b/>`, `<i/>`, `<u/>`, `<strike/>`,
/// `<color rgb="..."/>`, `<rFont val="..."/>`.
fn parse_inline_font(rpr : @xml.Element, base : ResolvedFont) -> ResolvedFont {
  let mut family = base.family
  let mut size = base.size
  let mut bold = base.bold
  let mut italic = base.italic
  let mut underline = base.underline
  let mut strikethrough = base.strikethrough
  let mut color = base.color
  for child in rpr.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "b" => bold = true
          "i" => italic = true
          "u" => underline = true
          "strike" => strikethrough = true
          "sz" =>
            match attr_value_local(e, "val") {
              Some(v) =>
                match (try? @strconv.parse_double(v)) {
                  Ok(d) => size = d
                  Err(_) => ()
                }
              None => ()
            }
          "rFont" =>
            match attr_value_local(e, "val") {
              Some(v) => family = v
              None => ()
            }
          "color" =>
            match attr_value_local(e, "rgb") {
              Some(v) =>
                if v.length() == 8 {
                  // ARGB → #RRGGBB
                  color = Some("#" + v.substring(start=2, end=8))
                } else if v.length() == 6 {
                  color = Some("#" + v)
                }
              None => ()
            }
          _ => ()
        }
      _ => ()
    }
  }
  { family, size, bold, italic, underline, strikethrough, color }
}

// =============================================================================
// Cell value formatting.
// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:31
// =============================================================================

///|
/// Resolve a §18.3.1.4 `<c>` element's display text.  Honours the
/// `@t` attribute per §18.18.11 (ST_CellType): `n` numeric, `s`
/// shared-string, `str` literal, `b` boolean, `e` error, `inlineStr`
/// inline rich-text.  Numbers respect the resolved
/// `style.number_format`.
fn format_cell_value(
  cell : @xml.Element,
  shared_strings : @domain.CT_Sst?,
  style : ResolvedCellStyle,
  warnings : Array[String],
  date_system? : @date_serial.DateSystem = @date_serial.DateSystem::Serial1900,
) -> String {
  let t = match attr_value_local(cell, "t") {
    Some(v) => v
    None => "n"
  }
  match t {
    "s" => {
      // Shared-string index in `<v>`.
      let value_text = match first_child_named_local(cell, "v") {
        Some(v) => xml_text_content(v).trim_space().to_string()
        None => return ""
      }
      match shared_strings {
        None => value_text
        Some(sst) =>
          match (try? @strconv.parse_int(value_text)) {
            Ok(idx) =>
              if idx >= 0 && idx < sst.si_entries.length() {
                sst.si_entries[idx].to_plain_text()
              } else {
                value_text
              }
            Err(_) => value_text
          }
      }
    }
    "str" =>
      // Literal string in `<v>`.
      match first_child_named_local(cell, "v") {
        Some(v) => xml_text_content(v)
        None => ""
      }
    "inlineStr" =>
      // §18.3.1.53 inline rich-text under `<is>`.
      match first_child_named_local(cell, "is") {
        None => ""
        Some(is_el) => collect_inline_text(is_el)
      }
    "b" => {
      // §18.4.2 / §18.18.11 — boolean cell values are `"1"`
      // (true) or `"0"` (false).  Some producers write the
      // lexical `"true"`/`"false"` forms instead; we recover
      // those and warn, rather than discarding the recoverable
      // value behind a `"?"` placeholder.
      let raw = match first_child_named_local(cell, "v") {
        Some(v) => xml_text_content(v).trim_space().to_string()
        None => ""
      }
      match raw {
        "1" => "TRUE"
        "0" => "FALSE"
        "true" | "TRUE" | "True" => {
          warnings.push(
            "§18.4.2: boolean cell <v> should be '1' (saw '" + raw + "')",
          )
          "TRUE"
        }
        "false" | "FALSE" | "False" => {
          warnings.push(
            "§18.4.2: boolean cell <v> should be '0' (saw '" + raw + "')",
          )
          "FALSE"
        }
        _ => {
          // Truly unrecognised — warn and surface the raw value
          // rather than an opaque "?" so consumers can still see
          // what the source contained.
          warnings.push(
            "§18.4.2: boolean cell <v> must be '1' or '0' (saw '" + raw + "')",
          )
          raw
        }
      }
    }
    "e" =>
      // Error literal carried verbatim, e.g. "#REF!".
      match first_child_named_local(cell, "v") {
        Some(v) => xml_text_content(v)
        None => ""
      }
    "d" => {
      // §18.18.11 — ISO 8601 date/time literal in `<v>`.
      // §18.17.4.1 — convert the lexical date to the Excel
      // serial (date_time_to_serial under Serial1900) then run
      // `format_excel_date` so the resolved numFmt applies.
      // If the cell has no @s or `@numFmt = "General"`, fall
      // back to the literal ISO string so callers still see
      // something meaningful.
      let raw = match first_child_named_local(cell, "v") {
        Some(v) => xml_text_content(v)
        None => ""
      }
      if raw.length() == 0 {
        return ""
      }
      match parse_iso8601_date(raw) {
        None => {
          warnings.push(
            "§18.17.4.1: cell t=\"d\" carries an unparseable" +
            " ISO 8601 value '" +
            raw +
            "'",
          )
          raw
        }
        Some(dt) =>
          match (try? @date_serial.date_time_to_serial(dt, date_system)) {
            Err(_) => raw
            Ok(serial) =>
              if style.number_format == "General" || style.number_format == "" {
                raw
              } else {
                format_number_general(serial, style.number_format, date_system~)
              }
          }
      }
    }
    "n" => {
      // §18.18.11 default — numeric. Honours the resolved
      // §18.8.30 format code.
      let value_text = match first_child_named_local(cell, "v") {
        Some(v) => xml_text_content(v).trim_space().to_string()
        None => return ""
      }
      if value_text == "" {
        return ""
      }
      match (try? @strconv.parse_double(value_text)) {
        Ok(num) => format_number_general(num, style.number_format, date_system~)
        Err(_) => value_text
      }
    }
    other => {
      // Spec violation: §18.18.11 enumerates exactly
      // {b, d, e, inlineStr, n, s, str}. Treat unknown values as
      // numeric per §18.18.11's documented default and warn so
      // the schema breach is visible.
      warnings.push("§18.18.11: cell @t='" + other + "' not in ST_CellType")
      let value_text = match first_child_named_local(cell, "v") {
        Some(v) => xml_text_content(v).trim_space().to_string()
        None => return ""
      }
      if value_text == "" {
        return ""
      }
      match (try? @strconv.parse_double(value_text)) {
        Ok(num) => format_number_general(num, style.number_format, date_system~)
        Err(_) => value_text
      }
    }
  }
}

///|
/// Concatenate the plain text of an inline rich-text run.  Mirrors
/// §18.4.6 CT_Rst's flattening rules: text from `<t>` plus every
/// `<r>/<t>`.
fn collect_inline_text(is_el : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in is_el.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "t" => buf.write_string(xml_text_content(e))
          "r" =>
            // Each `<r>` may carry `<rPr>` then `<t>`.
            for sub in e.children {
              match sub {
                Element(t_or_pr) =>
                  if t_or_pr.name.local_name == "t" {
                    buf.write_string(xml_text_content(t_or_pr))
                  }
                _ => ()
              }
            }
          _ => ()
        }
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// §18.8.30 numFmt formatter — dispatch on the cell's resolved
/// format code. Empty / "General" routes through `format_general`;
/// otherwise we evaluate the format-code grammar (sections split by
/// `;` for positive/negative/zero, `0` / `#` digit placeholders,
/// `.` decimal, `,` thousands separator, `%` percent, literal
/// suffix). Falls back to `format_general` when the format isn't
/// understood so unsupported codes still produce a readable cell.
fn format_number_general(
  num : Double,
  format_code : String,
  date_system? : @date_serial.DateSystem = @date_serial.DateSystem::Serial1900,
) -> String {
  if format_code == "General" || format_code == "" {
    return format_general(num)
  }
  format_number_by_code(num, format_code, date_system~)
}

///|
/// §18.8.30 — interpret a format-code string. Handles the common
/// patterns: section delimiters (`;`), digit placeholders `0` / `#`,
/// decimal point `.`, thousands separator `,`, percent multiplier
/// `%`, prefix / suffix literals, and the leading `_` (next-char
/// padding — treated as a literal space here for simplicity). When
/// the format can't be recognised the value falls back to
/// `format_general`.
fn format_number_by_code(
  num : Double,
  format_code : String,
  date_system? : @date_serial.DateSystem = @date_serial.DateSystem::Serial1900,
) -> String {
  // §18.8.30 / §18.17.4.1 — date/time format codes (containing
  // the tokens m, d, y, h, s outside of quoted literals)
  // require the numeric value to be interpreted as an Excel
  // serial date.  We delegate to `format_excel_date` which
  // converts the serial to a CalendarDateTime via
  // `@date_serial.serial_to_date_time` and substitutes each
  // recognised date token with the formatted component.
  if contains_date_token(format_code) {
    return format_excel_date(num, format_code, date_system~)
  }
  // Section split by `;` per §18.8.30: pos[;neg[;zero[;text]]].
  let sections = split_format_sections(format_code)
  let section = if num > 0.0 {
    sections[0]
  } else if num < 0.0 && sections.length() >= 2 {
    sections[1]
  } else if num == 0.0 && sections.length() >= 3 {
    sections[2]
  } else {
    sections[0]
  }
  // Apply per-section sign convention: when a negative section is
  // declared and the value is negative, format the absolute value
  // (the section literal supplies any leading "-" / "(").
  let value = if num < 0.0 && sections.length() >= 2 { -num } else { num }
  apply_format_section(value, section)
}

///|
/// §18.8.30 / §18.17.4.1 — true when `format_code` contains any
/// unquoted date/time token (m, d, y, h, s — uppercase variants
/// also recognised). Used to gate the date-format placeholder
/// fallback until the full token grammar is implemented.
fn contains_date_token(format_code : String) -> Bool {
  let mut in_quote = false
  let mut in_bracket = false
  let mut i = 0
  while i < format_code.length() {
    let c = format_code.code_unit_at(i).to_int()
    if c == 0x22 {
      in_quote = !(in_quote)
      i = i + 1
      continue
    }
    if c == 0x5C && i + 1 < format_code.length() {
      // backslash-escape: skip the next char as a literal
      i = i + 2
      continue
    }
    if c == 0x5B {
      // '[' opens a directive token (§18.8.30): colour name,
      // condition, locale, currency, OR elapsed-time `[h]/[m]/[s]`
      // (§18.8.31).  Only the elapsed-time forms are date/time
      // tokens; everything else (`[Red]`, `[>=100]`, `[$$-409]`)
      // must NOT trigger the date-format path.  Peek the bracket
      // body and decide: when the body matches `h+`, `m+`, or
      // `s+` (case-insensitive) it IS an elapsed-time token.
      let body_start = i + 1
      let mut k = body_start
      while k < format_code.length() &&
            format_code.code_unit_at(k).to_int() != 0x5D {
        k = k + 1
      }
      let body_end = k
      let mut is_elapsed = body_end > body_start
      if is_elapsed {
        let first = format_code.code_unit_at(body_start).to_int()
        let is_hms = first == 0x68 ||
          first == 0x48 ||
          first == 0x6D ||
          first == 0x4D ||
          first == 0x73 ||
          first == 0x53
        if !(is_hms) {
          is_elapsed = false
        } else {
          let mut q = body_start + 1
          while q < body_end {
            let cc = format_code.code_unit_at(q).to_int()
            if cc != first && cc != first + 0x20 && cc != first - 0x20 {
              is_elapsed = false
              break
            }
            q = q + 1
          }
        }
      }
      if is_elapsed {
        return true
      }
      i = body_end + 1
      continue
    }
    if c == 0x5D {
      in_bracket = false
      i = i + 1
      continue
    }
    if !(in_quote) {
      // §18.8.30 date/time tokens — case-insensitive per
      // §18.17.4.1.
      if c == 0x6D || c == 0x4D {
        return true
      }
      if c == 0x64 || c == 0x44 {
        return true
      }
      if c == 0x79 || c == 0x59 {
        return true
      }
      if c == 0x68 || c == 0x48 {
        return true
      }
      // 's' is also a seconds token but inside an elapsed bracket
      // it is unambiguous; outside it can collide with the literal
      // letter 's' in some custom codes — we still treat it as a
      // time token because §18.8.30 reserves it.
      if c == 0x73 || c == 0x53 {
        return true
      }
      let _ = in_bracket
    }
    i = i + 1
  }
  false
}

///|
/// Split `format_code` on top-level `;`. Backslash-escaped `;` and
/// quoted `";"` are preserved as part of the surrounding section.
/// §18.8.30 / §18.17.4.1 — format an Excel serial date through a
/// `m/d/yyyy h:mm:ss` -style format code.  Implements the
/// minimal token set:
///   yyyy  — 4-digit year
///   yy    — 2-digit year (mod 100)
///   m     — month (1-12)
///   mm    — month zero-padded
///   d     — day (1-31)
///   dd    — day zero-padded
///   h     — hour (0-23)
///   hh    — hour zero-padded
///   ss    — seconds zero-padded
///   AM/PM — 12-hour suffix (converts h to 1-12)
/// Any other character (incl. quoted literals, `-`, `:`, `/`)
/// is passed through verbatim.  Out-of-range serials fall
/// back to the General representation so callers see the
/// raw number rather than a nonsensical date.
/// §18.17.4.1 — parse an ISO 8601 date/time literal of the form
/// `YYYY-MM-DD` or `YYYY-MM-DDTHH:MM:SS[.fff]` (with optional
/// trailing timezone designator).  Returns `None` for any
/// lexical form outside the spec.  Timezone designators beyond
/// `Z` are dropped (Excel ignores them).
fn parse_iso8601_date(raw : String) -> @date_serial.CalendarDateTime? {
  let n = raw.length()
  if n < 10 {
    return None
  }
  let digit = fn(off : Int) -> Int? {
    let c = raw.code_unit_at(off).to_int()
    if c >= 0x30 && c <= 0x39 {
      Some(c - 0x30)
    } else {
      None
    }
  }
  let read_int = fn(off : Int, width : Int) -> Int? {
    let mut acc = 0
    let mut i = 0
    while i < width {
      match digit(off + i) {
        None => return None
        Some(d) => acc = acc * 10 + d
      }
      i = i + 1
    }
    Some(acc)
  }
  let year = match read_int(0, 4) {
    None => return None
    Some(v) => v
  }
  if raw.code_unit_at(4).to_int() != 0x2D {
    return None
  }
  let month = match read_int(5, 2) {
    None => return None
    Some(v) => v
  }
  if raw.code_unit_at(7).to_int() != 0x2D {
    return None
  }
  let day = match read_int(8, 2) {
    None => return None
    Some(v) => v
  }
  let mut hour = 0
  let mut minute = 0
  let mut second = 0
  let mut millisecond = 0
  if n > 10 {
    if raw.code_unit_at(10).to_int() != 0x54 {
      return None
    }
    if n < 19 {
      return None
    }
    hour = match read_int(11, 2) {
      None => return None
      Some(v) => v
    }
    if raw.code_unit_at(13).to_int() != 0x3A {
      return None
    }
    minute = match read_int(14, 2) {
      None => return None
      Some(v) => v
    }
    if raw.code_unit_at(16).to_int() != 0x3A {
      return None
    }
    second = match read_int(17, 2) {
      None => return None
      Some(v) => v
    }
    // Optional `.fff` fractional seconds.
    if n > 19 && raw.code_unit_at(19).to_int() == 0x2E {
      let mut i = 20
      let mut acc = 0
      let mut count = 0
      while i < n {
        match digit(i) {
          None => break
          Some(d) => {
            acc = acc * 10 + d
            count = count + 1
            i = i + 1
          }
        }
      }
      if count == 0 {
        return None
      }
      // Normalise to three-digit milliseconds.
      while count < 3 {
        acc = acc * 10
        count = count + 1
      }
      while count > 3 {
        acc = acc / 10
        count = count - 1
      }
      millisecond = acc
    }
  }
  Some({ year, month, day, hour, minute, second, millisecond })
}

///|
fn format_excel_date(
  serial : Double,
  format_code : String,
  date_system? : @date_serial.DateSystem = @date_serial.DateSystem::Serial1900,
) -> String {
  let dt = try @date_serial.serial_to_date_time(serial, date_system) catch {
    _ => return format_general(serial)
  } noraise {
    parsed => parsed
  }
  let buf = StringBuilder::new()
  let mut i = 0
  // Pre-scan for AM/PM presence so hour is rendered 12-hour.
  let has_am_pm_upper = format_code.contains("AM/PM")
  let has_am_pm_lower = format_code.contains("am/pm")
  let has_ap_upper = format_code.contains("A/P")
  let has_ap_lower = format_code.contains("a/p")
  let has_am_pm = has_am_pm_upper ||
    has_am_pm_lower ||
    has_ap_upper ||
    has_ap_lower
  let pad2 = fn(n : Int) -> String {
    if n < 10 {
      "0" + n.to_string()
    } else {
      n.to_string()
    }
  }
  let pad4 = fn(n : Int) -> String {
    if n < 10 {
      "000" + n.to_string()
    } else if n < 100 {
      "00" + n.to_string()
    } else if n < 1000 {
      "0" + n.to_string()
    } else {
      n.to_string()
    }
  }
  // §18.8.30 — `m` is the minute component when it neighbours a
  // time token (`h`, `hh`, `[h…]`, `s`, `ss`); otherwise it is
  // the month component.  Track whether the previously emitted
  // time-grammar token was an hour token, and at every `m` token
  // also peek forward for an immediately-following second token,
  // before deciding month vs. minute.
  let mut last_token_was_hour = false
  while i < format_code.length() {
    let c = format_code.code_unit_at(i).to_int()
    // Quoted literals — copy verbatim.
    if c == 0x22 {
      i = i + 1
      while i < format_code.length() {
        let cc = format_code.code_unit_at(i).to_int()
        if cc == 0x22 {
          i = i + 1
          break
        }
        buf.write_char(cc.to_char().unwrap())
        i = i + 1
      }
      continue
    }
    // Backslash escape.
    if c == 0x5C && i + 1 < format_code.length() {
      let n = format_code.code_unit_at(i + 1).to_int()
      buf.write_char(n.to_char().unwrap())
      i = i + 2
      continue
    }
    // §18.8.31 — `[h]`, `[m]`, `[s]` elapsed-time tokens.  Run
    // length inside the brackets is the zero-pad width.  The
    // value is the cumulative count from the serial, NOT the
    // wall-clock component — that's exactly what distinguishes
    // the bracketed form from bare `h`/`m`/`s`.
    if c == 0x5B {
      let body_start = i + 1
      let mut k = body_start
      while k < format_code.length() &&
            format_code.code_unit_at(k).to_int() != 0x5D {
        k = k + 1
      }
      let body_end = k
      if body_end > body_start {
        let first = format_code.code_unit_at(body_start).to_int()
        let lower = if first >= 0x41 && first <= 0x5A {
          first + 0x20
        } else {
          first
        }
        let is_h = lower == 0x68
        let is_m = lower == 0x6D
        let is_s = lower == 0x73
        if is_h || is_m || is_s {
          let mut uniform = true
          let mut q = body_start + 1
          while q < body_end {
            let cc = format_code.code_unit_at(q).to_int()
            if cc != first && cc != first + 0x20 && cc != first - 0x20 {
              uniform = false
              break
            }
            q = q + 1
          }
          if uniform {
            let width = body_end - body_start
            // Compute cumulative integer count.  serial is the
            // Excel date serial (days since the epoch); per
            // §18.17.4.1 the fractional day is hours/24, etc.
            let secs_total = (serial * 86400.0).to_int64()
            let count = if is_h {
              (secs_total / 3600L).to_int()
            } else if is_m {
              (secs_total / 60L).to_int()
            } else {
              secs_total.to_int()
            }
            let raw = count.to_string()
            let pad = width - raw.length()
            if pad > 0 {
              for _p in 0..<pad {
                buf.write_char('0')
              }
            }
            buf.write_string(raw)
            // `[h…]` counts as the hour token for the m-vs-month
            // disambiguation that follows.
            last_token_was_hour = is_h
            i = body_end + 1
            continue
          }
        }
      }
      // Non-elapsed bracket (`[Red]`, `[$$-409]`, `[>=100]`) —
      // drop the directive entirely; it never surfaces in
      // formatted text.
      i = body_end + 1
      continue
    }
    // AM/PM literal — must come before single-char tokens.
    let matches_am_pm = if i + 5 <= format_code.length() {
      let s = format_code.substring(start=i, end=i + 5)
      s == "AM/PM" || s == "am/pm"
    } else {
      false
    }
    if matches_am_pm {
      let hour = dt.hour
      buf.write_string(if hour >= 12 { "PM" } else { "AM" })
      i = i + 5
      continue
    }
    // Run-length for repeated date tokens (yyyy, mmm, dd, ...).
    let token_start = i
    let token_char = c
    while i < format_code.length() &&
          format_code.code_unit_at(i).to_int() == token_char {
      i = i + 1
    }
    let run_length = i - token_start
    // Dispatch by token character (lowercased to keep mm /
    // MM / Mm equivalent per §18.8.30 case-insensitivity).
    let lower_char = if token_char >= 0x41 && token_char <= 0x5A {
      token_char + 0x20
    } else {
      token_char
    }
    if lower_char == 0x79 { // 'y'
      if run_length >= 4 {
        buf.write_string(pad4(dt.year))
      } else {
        buf.write_string(pad2(dt.year % 100))
      }
    } else if lower_char == 0x6D { // 'm' — month or minute (§18.8.30)
      // Look forward past whitespace / `:` / quoted literal for
      // an `s` token — that also forces minute interpretation.
      let mut peek = i
      let mut peek_minute = false
      while peek < format_code.length() {
        let pc = format_code.code_unit_at(peek).to_int()
        if pc == 0x20 || pc == 0x3A {
          peek = peek + 1
        } else if pc == 0x22 {
          peek = peek + 1
          while peek < format_code.length() &&
                format_code.code_unit_at(peek).to_int() != 0x22 {
            peek = peek + 1
          }
          peek = peek + 1
        } else {
          if pc == 0x73 || pc == 0x53 {
            peek_minute = true
          }
          break
        }
      }
      let as_minute = last_token_was_hour || peek_minute
      let value = if as_minute { dt.minute } else { dt.month }
      if run_length >= 2 {
        buf.write_string(pad2(value))
      } else {
        buf.write_string(value.to_string())
      }
      last_token_was_hour = false
    } else if lower_char == 0x64 { // 'd'
      if run_length >= 2 {
        buf.write_string(pad2(dt.day))
      } else {
        buf.write_string(dt.day.to_string())
      }
      last_token_was_hour = false
    } else if lower_char == 0x68 { // 'h'
      let hour = if has_am_pm {
        let h12 = dt.hour % 12
        if h12 == 0 {
          12
        } else {
          h12
        }
      } else {
        dt.hour
      }
      if run_length >= 2 {
        buf.write_string(pad2(hour))
      } else {
        buf.write_string(hour.to_string())
      }
      last_token_was_hour = true
    } else if lower_char == 0x73 { // 's'
      if run_length >= 2 {
        buf.write_string(pad2(dt.second))
      } else {
        buf.write_string(dt.second.to_string())
      }
      last_token_was_hour = false
    } else {
      // Unrecognised — pass through verbatim.
      for _j in 0..<run_length {
        buf.write_char(token_char.to_char().unwrap())
      }
    }
  }
  buf.to_string()
}

///|
fn split_format_sections(format_code : String) -> Array[String] {
  let out : Array[String] = []
  let buf = StringBuilder::new()
  let mut in_quote = false
  for i in 0..<format_code.length() {
    let c = format_code.code_unit_at(i).to_int()
    if c == 0x22 {
      // '"' — toggle quote
      in_quote = !(in_quote)
      buf.write_char(c.to_char().unwrap())
    } else if c == 0x5C && i + 1 < format_code.length() {
      // backslash-escape: keep both chars together
      buf.write_char(c.to_char().unwrap())
    } else if c == 0x3B && !(in_quote) {
      // ';' delimiter
      out.push(buf.to_string())
      buf.reset()
    } else {
      buf.write_char(c.to_char().unwrap())
    }
  }
  out.push(buf.to_string())
  out
}

///|
/// Apply one format section to a (non-negative) numeric value.
/// Walks the section token-by-token, building up the integer and
/// decimal portions independently before substituting them into
/// the placeholders.
///
/// §18.8.30 / §18.8.31 token coverage:
///   - `0`, `#`, `?`, `,`, `.`, `%`         — fully honoured
///   - `"..."` quoted literal               — fully honoured
///   - `\<c>` escape                        — fully honoured
///   - `[Red]` / `[Blue]` colour bracket    — stripped from the
///       visible output (they are format directives, not text).
///   - `[$$-409]` locale / currency bracket — stripped.
///   - `[h]` / `[m]` / `[s]` elapsed-time   — honoured as
///       cumulative date components.
///   - `_<c>` accounting gap                — emits a space.
///   - `*<c>` fill character                — emits nothing
///       (column-width-relative fill is not resolvable here).
///   - `E+` / `E-` / `e` scientific notation — honoured.
/// §18.8.31 — detect whether a format-code section uses the fraction
/// grammar: an unquoted `/` separator with digit placeholders
/// (`?`, `0`, `#`) on both sides.  Quoted literals, backslash
/// escapes, and `[...]` directives are skipped during the scan.
fn section_is_fraction_format(section : String) -> Bool {
  let mut i = 0
  let mut slash_pos = -1
  while i < section.length() {
    let c = section.code_unit_at(i).to_int()
    if c == 0x22 {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x22 {
        i = i + 1
      }
      i = i + 1
      continue
    }
    if c == 0x5C && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if c == 0x5B {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x5D {
        i = i + 1
      }
      if i < section.length() {
        i = i + 1
      }
      continue
    }
    if (c == 0x5F || c == 0x2A) && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if c == 0x2F {
      // `/` candidate — must have at least one digit-placeholder
      // before and after.
      let mut before = false
      let mut k = i - 1
      while k >= 0 {
        let cc = section.code_unit_at(k).to_int()
        if cc == 0x3F || cc == 0x30 || cc == 0x23 {
          before = true
          break
        }
        if cc == 0x20 {
          k = k - 1
          continue
        }
        break
      }
      let mut after = false
      let mut k2 = i + 1
      while k2 < section.length() {
        let cc = section.code_unit_at(k2).to_int()
        // Placeholder OR literal digit (1-9, 0).  Excel accepts
        // `?/8`, `?/16` etc. with a literal denominator.
        if cc == 0x3F || cc == 0x23 || (cc >= 0x30 && cc <= 0x39) {
          after = true
          break
        }
        if cc == 0x20 {
          k2 = k2 + 1
          continue
        }
        break
      }
      if before && after {
        slash_pos = i
        break
      }
    }
    i = i + 1
  }
  slash_pos >= 0
}

///|
/// §18.8.31 — render a fraction-format section like `# ?/?`,
/// `0 ?/?`, `# ??/??`, `# ?/8`.  The numerator/denominator
/// placeholders set the maximum number of digits; the actual
/// denominator is the best rational approximation with that
/// digit budget (Stern-Brocot lattice search).  When the
/// denominator part is a literal integer (e.g. `?/8`), the
/// fraction is constrained to that exact denominator.
fn apply_fraction_format_section(value : Double, section : String) -> String {
  let negative = value < 0.0
  let abs_val = if negative { -value } else { value }
  // Locate the unquoted `/`.
  let slash_pos = fraction_slash_position(section)
  if slash_pos < 0 {
    // Defensive — caller already verified.
    return value.to_string()
  }
  // Inspect numerator side: count the digit placeholders to bound
  // the maximum allowed denominator (10^digits - 1).
  let mut num_digits = 0
  let mut k = slash_pos - 1
  while k >= 0 {
    let c = section.code_unit_at(k).to_int()
    if c == 0x3F || c == 0x30 || c == 0x23 {
      num_digits = num_digits + 1
      k = k - 1
    } else {
      break
    }
  }
  // Inspect denominator side: same digit-placeholder count
  // unless the denominator slot is a literal integer.
  let mut den_digits = 0
  let mut den_literal : Int? = None
  let mut k2 = slash_pos + 1
  // Skip leading whitespace.
  while k2 < section.length() && section.code_unit_at(k2).to_int() == 0x20 {
    k2 = k2 + 1
  }
  let den_start = k2
  while k2 < section.length() {
    let c = section.code_unit_at(k2).to_int()
    if c == 0x3F || c == 0x30 || c == 0x23 {
      den_digits = den_digits + 1
      k2 = k2 + 1
    } else if c >= 0x31 && c <= 0x39 {
      // Literal integer denominator (e.g. `/8`, `/16`).  Collect
      // the entire decimal literal.
      let mut acc = 0
      while k2 < section.length() {
        let cc = section.code_unit_at(k2).to_int()
        if cc >= 0x30 && cc <= 0x39 {
          acc = acc * 10 + (cc - 0x30)
          k2 = k2 + 1
        } else {
          break
        }
      }
      den_literal = Some(acc)
      break
    } else {
      break
    }
  }
  let _ = den_start
  // Integer portion comes from any digit placeholders before the
  // numerator slot.  Detect the integer slot the same way: digit
  // placeholders before a space and the numerator block.
  let mut has_integer_slot = false
  let mut int_idx = k
  while int_idx >= 0 {
    let c = section.code_unit_at(int_idx).to_int()
    if c == 0x20 {
      int_idx = int_idx - 1
      continue
    }
    if c == 0x3F || c == 0x30 || c == 0x23 {
      has_integer_slot = true
    }
    break
  }
  // Compute best numerator/denominator.
  let (int_part, num, den) = if den_literal is Some(d) {
    // Constrained denominator: numerator = round(frac * d).
    let frac = abs_val - abs_val.floor()
    let n = (frac * d.to_double()).round().to_int()
    let i_part = abs_val.floor().to_int()
    // Carry when the rounded numerator equals d (e.g. 0.999 → 1/1
    // should normalise to int+1, 0/d).
    if n == d {
      (i_part + 1, 0, d)
    } else {
      (i_part, n, d)
    }
  } else {
    // Max denominator: 10^num_digits - 1, clamped to a sensible
    // upper bound to keep the lattice search bounded.
    let max_den = if den_digits <= 0 {
      9
    } else {
      pow10(den_digits).to_int() - 1
    }
    let (n, d) = best_fraction(abs_val, max_den)
    let i_part = abs_val.floor().to_int()
    let frac_n = n - i_part * d
    (i_part, frac_n, d)
  }
  // Assemble result: walk the section, emitting the integer slot,
  // numerator slot, slash, denominator slot; copy literals verbatim.
  let buf = StringBuilder::new()
  if negative {
    buf.write_char('-')
  }
  let mut j = 0
  let mut emitted_int = false
  let mut emitted_num = false
  let mut emitted_den = false
  while j < section.length() {
    let c = section.code_unit_at(j).to_int()
    if c == 0x22 {
      j = j + 1
      while j < section.length() && section.code_unit_at(j).to_int() != 0x22 {
        buf.write_char(section.code_unit_at(j).to_int().to_char().unwrap())
        j = j + 1
      }
      j = j + 1
      continue
    }
    if c == 0x5C && j + 1 < section.length() {
      buf.write_char(section.code_unit_at(j + 1).to_int().to_char().unwrap())
      j = j + 2
      continue
    }
    if c == 0x5B {
      j = j + 1
      while j < section.length() && section.code_unit_at(j).to_int() != 0x5D {
        j = j + 1
      }
      if j < section.length() {
        j = j + 1
      }
      continue
    }
    if c == 0x5F && j + 1 < section.length() {
      buf.write_char(' ')
      j = j + 2
      continue
    }
    if c == 0x2A && j + 1 < section.length() {
      j = j + 2
      continue
    }
    if c == 0x3F || c == 0x30 || c == 0x23 {
      // Determine which slot we're in by comparing j to slash_pos.
      if j < slash_pos {
        if has_integer_slot && !(emitted_int) {
          if int_part == 0 && num != 0 {
            // Standard fraction form: when the integer is 0 and
            // there IS a fractional part, leave the integer slot
            // empty (ECMA-376 §18.8.31 example output: " 1/2").
            buf.write_char(' ')
          } else {
            buf.write_string(int_part.to_string())
          }
          emitted_int = true
          // Skip the rest of the integer slot.
          while j < section.length() {
            let cc = section.code_unit_at(j).to_int()
            if cc == 0x3F || cc == 0x30 || cc == 0x23 {
              j = j + 1
            } else {
              break
            }
          }
          continue
        }
        if !(emitted_num) {
          // Numerator.  Right-align in the slot using leading
          // spaces (?-placeholders) so the alignment matches
          // Excel's behaviour.
          let raw = num.to_string()
          let mut pad = num_digits - raw.length()
          while pad > 0 {
            buf.write_char(' ')
            pad = pad - 1
          }
          buf.write_string(raw)
          emitted_num = true
          while j < section.length() {
            let cc = section.code_unit_at(j).to_int()
            if cc == 0x3F || cc == 0x30 || cc == 0x23 {
              j = j + 1
            } else {
              break
            }
          }
          continue
        }
        j = j + 1
        continue
      } else {
        // Past the slash → denominator slot.
        if !(emitted_den) {
          let raw = den.to_string()
          let mut pad = den_digits - raw.length()
          while pad > 0 {
            buf.write_char(' ')
            pad = pad - 1
          }
          buf.write_string(raw)
          emitted_den = true
          while j < section.length() {
            let cc = section.code_unit_at(j).to_int()
            if cc == 0x3F || cc == 0x30 || cc == 0x23 {
              j = j + 1
            } else {
              break
            }
          }
          continue
        }
        j = j + 1
        continue
      }
    }
    // Literal denominator digit run.
    if j == slash_pos + 1 || (j > slash_pos && c >= 0x30 && c <= 0x39) {
      // Walk past the literal integer denominator we already
      // emitted, replacing it with our `den`.
      if !(emitted_den) {
        buf.write_string(den.to_string())
        emitted_den = true
      }
      while j < section.length() {
        let cc = section.code_unit_at(j).to_int()
        if cc >= 0x30 && cc <= 0x39 {
          j = j + 1
        } else {
          break
        }
      }
      continue
    }
    buf.write_char(c.to_char().unwrap())
    j = j + 1
  }
  buf.to_string()
}

///|
fn fraction_slash_position(section : String) -> Int {
  let mut i = 0
  while i < section.length() {
    let c = section.code_unit_at(i).to_int()
    if c == 0x22 {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x22 {
        i = i + 1
      }
      i = i + 1
      continue
    }
    if c == 0x5C && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if c == 0x5B {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x5D {
        i = i + 1
      }
      if i < section.length() {
        i = i + 1
      }
      continue
    }
    if (c == 0x5F || c == 0x2A) && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if c == 0x2F {
      return i
    }
    i = i + 1
  }
  -1
}

///|
/// Stern-Brocot lattice search for the best rational
/// approximation `n/d` with `d <= max_d`.  Returns `(n, d)`.
fn best_fraction(value : Double, max_d : Int) -> (Int, Int) {
  if max_d < 1 {
    return (value.round().to_int(), 1)
  }
  // Stern-Brocot mediant search.
  let mut lo_n = 0
  let mut lo_d = 1
  let mut hi_n = 1
  let mut hi_d = 0
  let mut best_n = value.round().to_int()
  let mut best_d = 1
  let mut best_err : Double = (value - best_n.to_double()).abs()
  // Cap iterations to avoid pathological inputs.
  let mut iter = 0
  while iter < 100 {
    let m_n = lo_n + hi_n
    let m_d = lo_d + hi_d
    if m_d > max_d {
      break
    }
    let approx = m_n.to_double() / m_d.to_double()
    let err = (value - approx).abs()
    if err < best_err {
      best_err = err
      best_n = m_n
      best_d = m_d
    }
    if approx < value {
      lo_n = m_n
      lo_d = m_d
    } else if approx > value {
      hi_n = m_n
      hi_d = m_d
    } else {
      break
    }
    iter = iter + 1
  }
  (best_n, best_d)
}

///|
fn apply_format_section(value : Double, section : String) -> String {
  // §18.8.31 — when the section carries an unquoted `/` with `?`/`0`
  // digit placeholders on both sides, it's a fraction-format
  // section.  Route to the dedicated lattice-search formatter so
  // the proper integer-portion + best-/N numerator/denominator
  // split is produced.  Otherwise fall through to the standard
  // decimal walker below.
  if section_is_fraction_format(section) {
    return apply_fraction_format_section(value, section)
  }
  // §18.8.30 — an unquoted `E+`, `E-`, `e+` or `e-` token marks a
  // scientific-notation section (built-in numFmt 11 `0.00E+00`,
  // numFmt 48 `##0.0E+0`).  The standard decimal walker has no
  // exponent semantics, so route to the dedicated formatter.
  if scientific_token_position(section) >= 0 {
    return apply_scientific_format_section(value, section)
  }
  // Pre-scan tokens.
  let mut pct_count = 0
  let mut has_decimal = false
  let mut int_zero_count = 0
  let mut frac_zero_count = 0
  let mut frac_hash_count = 0
  let mut thousands = false
  let mut i = 0
  while i < section.length() {
    let c = section.code_unit_at(i).to_int()
    if c == 0x22 {
      // skip quoted literal
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x22 {
        i = i + 1
      }
      i = i + 1
      continue
    }
    if c == 0x5C && i + 1 < section.length() {
      // escaped literal — skip the escape itself, but the next
      // char is just literal; don't treat as placeholder
      i = i + 2
      continue
    }
    // §18.8.30 — `[...]` tokens are format directives (colour
    // name, condition, locale, currency), NOT literal text and
    // NOT digit placeholders; skip past the close bracket so
    // their inner glyphs do not feed the placeholder counters.
    if c == 0x5B {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x5D {
        i = i + 1
      }
      if i < section.length() {
        i = i + 1
      }
      continue
    }
    // §18.8.31 — `_x` skips one character width; `*x` repeats `x`
    // to fill the column.  Neither carries placeholder semantics
    // — consume the escape and the following glyph as a unit so
    // the digit counters do not pick up an `x` that happens to be
    // `0`, `#`, `.`, etc.
    if (c == 0x5F || c == 0x2A) && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if c == 0x25 {
      pct_count = pct_count + 1
    } else if c == 0x2E {
      has_decimal = true
    } else if c == 0x2C && has_decimal == false {
      thousands = true
    } else if c == 0x30 {
      // '0'
      if has_decimal {
        frac_zero_count = frac_zero_count + 1
      } else {
        int_zero_count = int_zero_count + 1
      }
    } else if c == 0x23 {
      // '#'
      if has_decimal {
        frac_hash_count = frac_hash_count + 1
      }
    }
    i = i + 1
  }
  let scaled = if pct_count > 0 { value * 100.0 } else { value }
  let frac_digits = frac_zero_count + frac_hash_count
  let rounded = if frac_digits > 0 {
    let mult = pow10(frac_digits)
    (scaled * mult).round() / mult
  } else {
    scaled.round()
  }
  let abs_val = if rounded < 0.0 { -rounded } else { rounded }
  let int_part = abs_val.to_int64().to_int()
  let int_str = if int_part == 0 && int_zero_count == 0 {
    ""
  } else {
    int_part.to_string()
  }
  let padded_int = pad_left_zeros(int_str, int_zero_count)
  let int_with_sep = if thousands {
    add_thousands_separator(padded_int)
  } else {
    padded_int
  }
  let frac_str = if frac_digits > 0 {
    let frac_part = abs_val - int_part.to_double()
    let frac_int = (frac_part * pow10(frac_digits)).round().to_int64().to_int()
    let raw = pad_left_zeros(frac_int.to_string(), frac_digits)
    // Drop trailing zeros up to the count of `#` placeholders.
    let mut keep = raw.length()
    while keep > frac_zero_count && raw.code_unit_at(keep - 1).to_int() == 0x30 {
      keep = keep - 1
    }
    if keep == 0 {
      ""
    } else {
      raw.substring(start=0, end=keep)
    }
  } else {
    ""
  }
  // Walk the section once more to assemble output: substitute the
  // integer / decimal portions at the first placeholder run and
  // copy literal characters verbatim.
  let buf = StringBuilder::new()
  let sign = if rounded < 0.0 { "-" } else { "" }
  buf.write_string(sign)
  let mut emitted_int = false
  let mut emitted_frac = false
  let mut j = 0
  while j < section.length() {
    let c = section.code_unit_at(j).to_int()
    if c == 0x22 {
      j = j + 1
      while j < section.length() && section.code_unit_at(j).to_int() != 0x22 {
        buf.write_char(section.code_unit_at(j).to_int().to_char().unwrap())
        j = j + 1
      }
      j = j + 1
      continue
    }
    if c == 0x5C && j + 1 < section.length() {
      buf.write_char(section.code_unit_at(j + 1).to_int().to_char().unwrap())
      j = j + 2
      continue
    }
    // §18.8.30 — drop `[...]` directive tokens from the visible
    // text output (colour, condition, locale, currency are format
    // directives, not literal text).  A colour directive still
    // takes effect: `section_format_color` resolves it separately
    // and the caller applies it to the cell `<text fill>`.
    if c == 0x5B {
      j = j + 1
      while j < section.length() && section.code_unit_at(j).to_int() != 0x5D {
        j = j + 1
      }
      if j < section.length() {
        j = j + 1
      }
      continue
    }
    // §18.8.31 — `_x` aligns by skipping one character's width:
    // emit a single space (the visual placeholder for the gap).
    if c == 0x5F && j + 1 < section.length() {
      buf.write_char(' ')
      j = j + 2
      continue
    }
    // §18.8.31 — `*x` repeats `x` to fill the column width.
    // Without column-width context at this layer we emit nothing
    // (zero repetitions is the only spec-conformant choice when
    // the fill width is unknown — emitting a single `x` would be
    // an arbitrary approximation).
    if c == 0x2A && j + 1 < section.length() {
      j = j + 2
      continue
    }
    if c == 0x30 || c == 0x23 || c == 0x2C {
      // placeholder run — emit integer portion once.
      if !(emitted_int) {
        buf.write_string(int_with_sep)
        emitted_int = true
      }
      j = j + 1
      // Skip the rest of the integer placeholders so we don't
      // double-emit.
      while j < section.length() {
        let cc = section.code_unit_at(j).to_int()
        if cc == 0x30 || cc == 0x23 || cc == 0x2C {
          j = j + 1
        } else {
          break
        }
      }
      continue
    }
    if c == 0x2E {
      buf.write_char('.')
      j = j + 1
      // Fractional placeholders — substitute the fraction string
      // once and skip them.
      if !(emitted_frac) && frac_str.length() > 0 {
        buf.write_string(frac_str)
        emitted_frac = true
      }
      while j < section.length() {
        let cc = section.code_unit_at(j).to_int()
        if cc == 0x30 || cc == 0x23 {
          j = j + 1
        } else {
          break
        }
      }
      continue
    }
    if c == 0x25 {
      buf.write_char('%')
      j = j + 1
      continue
    }
    // Literal copy.
    buf.write_char(c.to_char().unwrap())
    j = j + 1
  }
  buf.to_string()
}

///|
/// §18.8.30 — locate the unquoted scientific-notation token in a
/// format section.  The token is `E` or `e` immediately followed
/// by `+` or `-`.  Quoted literals, backslash escapes, `[...]`
/// directives and `_`/`*` escapes are skipped so an `E` inside
/// e.g. a `"E"` literal does not trigger scientific mode.
/// Returns the index of the `E`/`e`, or -1 when absent.
fn scientific_token_position(section : String) -> Int {
  let mut i = 0
  while i < section.length() {
    let c = section.code_unit_at(i).to_int()
    if c == 0x22 {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x22 {
        i = i + 1
      }
      i = i + 1
      continue
    }
    if c == 0x5C && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if c == 0x5B {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x5D {
        i = i + 1
      }
      if i < section.length() {
        i = i + 1
      }
      continue
    }
    if (c == 0x5F || c == 0x2A) && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if (c == 0x45 || c == 0x65) && i + 1 < section.length() {
      let next = section.code_unit_at(i + 1).to_int()
      if next == 0x2B || next == 0x2D {
        return i
      }
    }
    i = i + 1
  }
  -1
}

///|
/// §18.8.30 — render a scientific-notation section such as
/// `0.00E+00` (numFmt 11) or `##0.0E+0` (numFmt 48).
///
/// The section splits at the `E`/`e` token: the left side is the
/// mantissa format, the right side is the exponent format.
///   * The count of integer digit-placeholders before the decimal
///     point in the mantissa is the *engineering grouping* N.  The
///     exponent is normalised to a multiple of N, and the mantissa
///     integer part carries 1..N digits.  For `0.00E+00` N is 1
///     (ordinary scientific notation); for `##0.0E+0` N is 3
///     (engineering notation).
///   * Fractional placeholders after the decimal point fix the
///     mantissa's fraction-digit count (`0` pads, `#` trims).
///   * The exponent placeholders fix the minimum exponent width;
///     `E+` always shows the sign, `E-` shows only `-`.
fn apply_scientific_format_section(value : Double, section : String) -> String {
  let e_pos = scientific_token_position(section)
  if e_pos < 0 {
    return value.to_string()
  }
  let mantissa_fmt = section[0:e_pos].to_string()
  let exp_sign_char = section.code_unit_at(e_pos + 1).to_int()
  let exp_fmt = section[e_pos + 2:].to_string()
  // Count mantissa placeholders: integer side (before `.`) and
  // fractional side (after `.`), distinguishing `0` (pad) from
  // `#`/`?` (trim).  Quoted/escaped/bracketed runs are skipped.
  let mut int_placeholders = 0
  let mut frac_zero = 0
  let mut frac_opt = 0
  let mut seen_dot = false
  let mut mi = 0
  while mi < mantissa_fmt.length() {
    let c = mantissa_fmt.code_unit_at(mi).to_int()
    if c == 0x22 {
      mi = mi + 1
      while mi < mantissa_fmt.length() &&
            mantissa_fmt.code_unit_at(mi).to_int() != 0x22 {
        mi = mi + 1
      }
      mi = mi + 1
      continue
    }
    if c == 0x5C && mi + 1 < mantissa_fmt.length() {
      mi = mi + 2
      continue
    }
    if c == 0x5B {
      mi = mi + 1
      while mi < mantissa_fmt.length() &&
            mantissa_fmt.code_unit_at(mi).to_int() != 0x5D {
        mi = mi + 1
      }
      if mi < mantissa_fmt.length() {
        mi = mi + 1
      }
      continue
    }
    if c == 0x2E {
      seen_dot = true
    } else if c == 0x30 {
      if seen_dot {
        frac_zero = frac_zero + 1
      } else {
        int_placeholders = int_placeholders + 1
      }
    } else if c == 0x23 || c == 0x3F {
      if seen_dot {
        frac_opt = frac_opt + 1
      } else {
        int_placeholders = int_placeholders + 1
      }
    }
    mi = mi + 1
  }
  // Count exponent placeholders for minimum-width padding.
  let mut exp_width = 0
  let mut ei = 0
  while ei < exp_fmt.length() {
    let c = exp_fmt.code_unit_at(ei).to_int()
    if c == 0x30 || c == 0x23 || c == 0x3F {
      exp_width = exp_width + 1
    }
    ei = ei + 1
  }
  // Engineering grouping: at least 1.
  let group = if int_placeholders < 1 { 1 } else { int_placeholders }
  let negative = value < 0.0
  let abs_val = if negative { -value } else { value }
  // Decompose abs_val into mantissa * 10^exp with the mantissa
  // integer part holding 1..group digits.
  let (mantissa, exponent) = if abs_val == 0.0 {
    (0.0, 0)
  } else {
    // Base-10 exponent of the most significant digit.  `log10`
    // can land just below an integer for exact powers of ten
    // (float rounding), so correct the floor result by checking
    // the candidate mantissa.
    let mut e0 = @math.log10(abs_val).floor().to_int()
    if abs_val / pow_int10(e0 + 1) >= 1.0 {
      e0 = e0 + 1
    } else if abs_val / pow_int10(e0) < 1.0 {
      e0 = e0 - 1
    }
    // Engineering normalisation: exp must be a multiple of `group`.
    let rem = e0 % group
    let adj = if rem < 0 { rem + group } else { rem }
    let exp = e0 - adj
    let mant = abs_val / pow_int10(exp)
    (mant, exp)
  }
  // Round the mantissa to its fraction-digit budget; a carry may
  // bump the integer part past `group` digits, which forces the
  // exponent up by `group`.
  let frac_digits = frac_zero + frac_opt
  let mut m = mantissa
  let mut e = exponent
  if m != 0.0 {
    let mult = pow10(frac_digits)
    m = (m * mult).round() / mult
    // Carry: e.g. 9.999 rounded to 2 dp → 10.00; if that pushes the
    // integer part to `group + 1` digits, divide down and bump exp.
    if m >= pow_int10(group) {
      m = m / pow_int10(group)
      e = e + group
    }
  }
  // Format the mantissa with a fixed fraction-digit count, then
  // trim trailing zeros down to the count of `0` (pad) placeholders.
  let m_int = m.to_int64().to_int()
  let m_frac_scaled = ((m - m_int.to_double()) * pow10(frac_digits))
    .round()
    .to_int64()
    .to_int()
  let mut frac_str = if frac_digits > 0 {
    pad_left_zeros(m_frac_scaled.to_string(), frac_digits)
  } else {
    ""
  }
  if frac_digits > 0 {
    let mut keep = frac_str.length()
    while keep > frac_zero && frac_str.code_unit_at(keep - 1).to_int() == 0x30 {
      keep = keep - 1
    }
    frac_str = if keep == 0 {
      ""
    } else {
      frac_str.substring(start=0, end=keep)
    }
  }
  // Exponent sign and magnitude.
  let exp_neg = e < 0
  let exp_mag = if exp_neg { -e } else { e }
  let exp_digits = pad_left_zeros(exp_mag.to_string(), exp_width)
  let exp_sign = if exp_neg {
    "-"
  } else if exp_sign_char == 0x2B {
    "+"
  } else {
    ""
  }
  let buf = StringBuilder::new()
  if negative {
    buf.write_char('-')
  }
  buf.write_string(m_int.to_string())
  if frac_str.length() > 0 {
    buf.write_char('.')
    buf.write_string(frac_str)
  }
  // The literal `E`/`e` glyph follows the case used in the format.
  buf.write_char(section.code_unit_at(e_pos).to_int().to_char().unwrap())
  buf.write_string(exp_sign)
  buf.write_string(exp_digits)
  buf.to_string()
}

///|
/// 10 raised to an integer power, valid for negative exponents.
fn pow_int10(n : Int) -> Double {
  if n >= 0 {
    pow10(n)
  } else {
    1.0 / pow10(-n)
  }
}

///|
fn pow10(n : Int) -> Double {
  let mut result = 1.0
  for _ in 0..<n {
    result = result * 10.0
  }
  result
}

///|
fn pad_left_zeros(value : String, width : Int) -> String {
  if value.length() >= width {
    return value
  }
  let buf = StringBuilder::new()
  for _ in 0..<(width - value.length()) {
    buf.write_char('0')
  }
  buf.write_string(value)
  buf.to_string()
}

///|
/// Insert `,` thousands separators every three digits from the right.
fn add_thousands_separator(value : String) -> String {
  let mut start = 0
  if value.length() > 0 && value.code_unit_at(0).to_int() == 0x2D {
    // skip leading '-'
    start = 1
  }
  let digits = value.length() - start
  if digits <= 3 {
    return value
  }
  let buf = StringBuilder::new()
  if start == 1 {
    buf.write_char('-')
  }
  let first_chunk = digits % 3
  let mut i = start
  if first_chunk > 0 {
    for _ in 0..<first_chunk {
      buf.write_char(value.code_unit_at(i).to_int().to_char().unwrap())
      i = i + 1
    }
    if i < value.length() {
      buf.write_char(',')
    }
  }
  let mut group_count = 0
  while i < value.length() {
    if group_count == 3 {
      buf.write_char(',')
      group_count = 0
    }
    buf.write_char(value.code_unit_at(i).to_int().to_char().unwrap())
    group_count = group_count + 1
    i = i + 1
  }
  buf.to_string()
}

///|
/// Replicates `formatGeneralNumber`: integers render without a
/// decimal; small or large magnitudes use scientific notation.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:121
fn format_general(value : Double) -> String {
  if value == value.to_int().to_double() && value.abs() < 1.0e15 {
    return value.to_int64().to_string()
  }
  let abs_v = value.abs()
  if abs_v >= 1.0e10 || (abs_v < 1.0e-4 && abs_v != 0.0) {
    return value.to_string()
  }
  value.to_string()
}

// =============================================================================
// Cell fill / border / text rendering.
// =============================================================================

///|
/// §18.3.1.28 dataBar — emit a `<rect>` overlay positioned over the
/// cell, with width = layout.width * ratio (clamped to [0, width]).
/// The bar is inset 2 px on each side as a viewer convention so the
/// cell text remains readable; spec leaves the visual inset unset.
/// `axis_position`, `direction`, and `negative_color` carry the
/// §18.3.1.28 attributes that the viewer does not render directly
/// (centred axis, RTL direction, negative-fill bar) — they surface
/// as `data-ooxml-axis-position` / `data-ooxml-direction` /
/// `data-ooxml-negative-color` so the consumer can apply them.
fn render_data_bar(
  layout : CellLayout,
  ratio : Double,
  color : String,
  axis_position : String,
  direction : String,
  negative_color : String,
) -> Array[@xml.Node] {
  let inset = 2.0
  let max_bar_width = (layout.width - inset * 2.0).max(0.0)
  let bar_width = (max_bar_width * ratio.max(0.0).min(1.0)).max(0.0)
  if bar_width == 0.0 {
    return []
  }
  let bar_height = (layout.height - inset * 2.0).max(0.0)
  let attrs : Array[@xml.Attribute] = [
    svg_attr("x", format_d(layout.x + inset)),
    svg_attr("y", format_d(layout.y + inset)),
    svg_attr("width", format_d(bar_width)),
    svg_attr("height", format_d(bar_height)),
    svg_attr("fill", color),
  ]
  if axis_position != "automatic" {
    attrs.push(svg_attr("data-ooxml-axis-position", axis_position))
  }
  if direction != "context" {
    attrs.push(svg_attr("data-ooxml-direction", direction))
  }
  if negative_color != "" {
    attrs.push(svg_attr("data-ooxml-negative-color", negative_color))
  }
  [svg_elem("rect", attrs, [])]
}

///|
/// §18.8.24 CT_GradientFill — render a gradient cell fill. The
/// viewer emits an inline `<linearGradient>` def (without a real
/// SVG defs collector to keep callsites local) and references it
/// via `fill="url(#…)"`. For `path` gradients the spec specifies
/// a radial-like fill bounded by left/right/top/bottom percentages
/// (§18.8.24); the viewer surfaces those via metadata until the
/// radial path is fully implemented. The gradient `id` is derived
/// from the cell layout coordinates so it is stable + unique.
fn render_cell_fill_gradient(
  layout : CellLayout,
  grad_type : String,
  degree : Double,
  stops : Array[(Double, String)],
) -> Array[@xml.Node] {
  if stops.length() == 0 {
    return []
  }
  // Stable id from cell position. The id includes the
  // gradient type so two cells with the same coords but
  // different gradients don't collide.
  let id = "grad_" +
    format_d(layout.x).replace(old=".", new="_") +
    "_" +
    format_d(layout.y).replace(old=".", new="_") +
    "_" +
    grad_type
  // Linear-gradient angle: §18.8.24 @degree is the rotation
  // measured clockwise from the positive x-axis.
  let angle_rad = degree * 3.141592653589793 / 180.0
  let dx = @math.cos(angle_rad)
  let dy = @math.sin(angle_rad)
  // Map the unit-vector direction onto a 0..1 box so SVG
  // userSpaceOnUse coordinates land on the gradient axis.
  let x1 = 0.5 - dx * 0.5
  let y1 = 0.5 - dy * 0.5
  let x2 = 0.5 + dx * 0.5
  let y2 = 0.5 + dy * 0.5
  let stop_nodes : Array[@xml.Node] = []
  for stop in stops {
    let (pos, color) = stop
    stop_nodes.push(
      svg_elem(
        "stop",
        [svg_attr("offset", format_d(pos)), svg_attr("stop-color", color)],
        [],
      ),
    )
  }
  let linear_gradient = svg_elem(
    "linearGradient",
    [
      svg_attr("id", id),
      svg_attr("x1", format_d(x1)),
      svg_attr("y1", format_d(y1)),
      svg_attr("x2", format_d(x2)),
      svg_attr("y2", format_d(y2)),
    ],
    stop_nodes,
  )
  let defs = svg_elem("defs", [], [linear_gradient])
  let rect = svg_elem(
    "rect",
    [
      svg_attr("x", format_d(layout.x)),
      svg_attr("y", format_d(layout.y)),
      svg_attr("width", format_d(layout.width)),
      svg_attr("height", format_d(layout.height)),
      svg_attr("fill", "url(#" + id + ")"),
      svg_attr("data-ooxml-gradient-type", grad_type),
    ],
    [],
  )
  [defs, rect]
}

///|
/// §18.18.55 ST_PatternType — render a named pattern cell fill.
/// The spec defines 18 named pattern types; we emit one SVG
/// `<pattern>` def per cell with the matching geometry (lines /
/// crosshatch / dotted background) using the cell's `fgColor` for
/// the marks and the `bgColor` for the panel. When the renderer
/// has no geometry mapping yet we fall back to a flat `fg` rect +
/// metadata so the cell still picks up the intended hue.
fn render_cell_fill_pattern(
  layout : CellLayout,
  pattern_name : String,
  fg : String,
  bg : String,
) -> Array[@xml.Node] {
  let bg_color = if bg.length() > 0 { bg } else { "#FFFFFF" }
  // Stable id from coords + pattern name so two cells with the
  // same pattern get distinct defs (cell coords differ).
  let id = "pat_" +
    format_d(layout.x).replace(old=".", new="_") +
    "_" +
    format_d(layout.y).replace(old=".", new="_") +
    "_" +
    pattern_name
  let pattern_def = build_pattern_def(id, pattern_name, fg, bg_color)
  match pattern_def {
    None => {
      // No geometry mapped — fall back to flat fg + metadata.
      let attrs : Array[@xml.Attribute] = [
        svg_attr("x", format_d(layout.x)),
        svg_attr("y", format_d(layout.y)),
        svg_attr("width", format_d(layout.width)),
        svg_attr("height", format_d(layout.height)),
        svg_attr("fill", fg),
        svg_attr("data-ooxml-pattern", pattern_name),
      ]
      if bg.length() > 0 {
        attrs.push(svg_attr("data-ooxml-pattern-bg", bg))
      }
      [svg_elem("rect", attrs, [])]
    }
    Some(pattern_node) => {
      let defs = svg_elem("defs", [], [pattern_node])
      let rect = svg_elem(
        "rect",
        [
          svg_attr("x", format_d(layout.x)),
          svg_attr("y", format_d(layout.y)),
          svg_attr("width", format_d(layout.width)),
          svg_attr("height", format_d(layout.height)),
          svg_attr("fill", "url(#" + id + ")"),
          svg_attr("data-ooxml-pattern", pattern_name),
        ],
        [],
      )
      [defs, rect]
    }
  }
}

///|
/// §18.18.55 ST_PatternType — build an SVG `<pattern>` definition
/// for the named pattern. Geometry is rendered on an 8×8 unit tile
/// (`patternUnits="userSpaceOnUse"` so each tile is exactly 8 px,
/// independent of the cell rect).  All 17 non-solid ST_PatternType
/// values are rendered; a schema-violating name returns "" so the
/// caller falls back to flat foreground.
fn build_pattern_def(
  id : String,
  pattern_name : String,
  fg : String,
  bg : String,
) -> @xml.Node? {
  let bg_rect = svg_elem(
    "rect",
    [svg_attr("width", "8"), svg_attr("height", "8"), svg_attr("fill", bg)],
    [],
  )
  // Geometry helpers — paint horizontal / vertical / diagonal
  // marks in the foreground colour.
  let line = fn(
    x1 : String,
    y1 : String,
    x2 : String,
    y2 : String,
    w : String,
  ) -> Array[@xml.Node] {
    [
      svg_elem(
        "line",
        [
          svg_attr("x1", x1),
          svg_attr("y1", y1),
          svg_attr("x2", x2),
          svg_attr("y2", y2),
          svg_attr("stroke", fg),
          svg_attr("stroke-width", w),
        ],
        [],
      ),
    ]
  }
  // §18.18.55 ST_PatternType — closed-19 enumeration.  `none` and
  // `solid` are special-cased upstream (this function isn't called
  // for them).  The remaining 17 patterns split into two families:
  //
  //   (a) Five "density" patterns whose names map directly to a
  //       spec-defined coverage fraction.  Each is painted by
  //       placing exactly N dots in the 8×8 tile such that the
  //       coloured-pixel ratio matches the spec fraction.
  //         lightGray   = 25 %   →  16 of 64 px coverage
  //         mediumGray  = 50 %   →  32 of 64 px coverage
  //         darkGray    = 75 %   →  48 of 64 px coverage
  //         gray125     = 12.5 % →   8 of 64 px coverage
  //         gray0625    =  6.25 %→   4 of 64 px coverage
  //
  //   (b) Twelve hatch / grid / trellis patterns whose geometry is
  //       prescribed by the spec figure — a horizontal / vertical /
  //       diagonal stroke of "thin" (1 px) or "thick" (2 px) weight,
  //       optionally crossed with its mirror to form a grid /
  //       trellis.  We render those exactly.
  //
  // No silent fallback survives — schema-violating names return ""
  // so the caller emits flat foreground (the spec default treatment
  // for an unrecognised pattern type per Annex E).
  let geometry : Array[@xml.Node] = match pattern_name {
    // (b) Hatch family
    "darkHorizontal" => line("0", "4", "8", "4", "2")
    "lightHorizontal" => line("0", "4", "8", "4", "1")
    "darkVertical" => line("4", "0", "4", "8", "2")
    "lightVertical" => line("4", "0", "4", "8", "1")
    "darkDown" => line("0", "0", "8", "8", "2")
    "lightDown" => line("0", "0", "8", "8", "1")
    "darkUp" => line("0", "8", "8", "0", "2")
    "lightUp" => line("0", "8", "8", "0", "1")
    "darkGrid" => line("0", "4", "8", "4", "2") + line("4", "0", "4", "8", "2")
    "lightGrid" => line("0", "4", "8", "4", "1") + line("4", "0", "4", "8", "1")
    "darkTrellis" =>
      line("0", "0", "8", "8", "2") + line("0", "8", "8", "0", "2")
    "lightTrellis" =>
      line("0", "0", "8", "8", "1") + line("0", "8", "8", "0", "1")
    // (a) Density family — every dot is rendered as a 1 px square
    // at integer grid coordinates so the coloured-pixel count
    // exactly matches the spec coverage fraction.
    "gray0625" =>
      // 6.25 % — 4 dots: corners of the 4×4 sub-grid.
      density_dot(fg, 0, 0) +
      density_dot(fg, 4, 0) +
      density_dot(fg, 0, 4) +
      density_dot(fg, 4, 4)
    "gray125" =>
      // 12.5 % — 8 dots: 2×2 lattice in each quadrant offset.
      density_dot(fg, 0, 0) +
      density_dot(fg, 4, 0) +
      density_dot(fg, 0, 4) +
      density_dot(fg, 4, 4) +
      density_dot(fg, 2, 2) +
      density_dot(fg, 6, 2) +
      density_dot(fg, 2, 6) +
      density_dot(fg, 6, 6)
    "lightGray" =>
      // 25 % — 16 dots: every 2nd grid cell.
      density_pattern_quarter(fg)
    "mediumGray" =>
      // 50 % — 32 dots: checkerboard.
      density_pattern_checker(fg)
    "darkGray" =>
      // 75 % — 48 dots: inverse 25 % (every cell except the
      // light-grey lattice positions).
      density_pattern_three_quarters(fg)
    // Schema violation — name outside ST_PatternType.  Empty
    // geometry triggers the caller's flat-foreground fallback.
    _ => []
  }
  if geometry.length() == 0 {
    return None
  }
  let children : Array[@xml.Node] = [bg_rect]
  for g in geometry {
    children.push(g)
  }
  Some(
    svg_elem(
      "pattern",
      [
        svg_attr("id", id),
        svg_attr("patternUnits", "userSpaceOnUse"),
        svg_attr("width", "8"),
        svg_attr("height", "8"),
      ],
      children,
    ),
  )
}

///|
/// Paint a single 1×1 pixel square at `(x, y)` inside the 8×8
/// density-pattern tile.  Used by the §18.18.55 density family so
/// the coloured-pixel count exactly matches the spec coverage
/// fraction (each square contributes one pixel).
fn density_dot(fg : String, x : Int, y : Int) -> Array[@xml.Node] {
  [
    svg_elem(
      "rect",
      [
        svg_attr("x", x.to_string()),
        svg_attr("y", y.to_string()),
        svg_attr("width", "1"),
        svg_attr("height", "1"),
        svg_attr("fill", fg),
      ],
      [],
    ),
  ]
}

///|
/// §18.18.55 `lightGray` — 25 % coverage.  Paint 16 of 64 px,
/// arranged as a 4×4 lattice on the even-even sub-grid.
fn density_pattern_quarter(fg : String) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for y in [0, 2, 4, 6] {
    for x in [0, 2, 4, 6] {
      for n in density_dot(fg, x, y) {
        out.push(n)
      }
    }
  }
  out
}

///|
/// §18.18.55 `mediumGray` — 50 % coverage.  Classic checkerboard
/// (32 of 64 px coloured).
fn density_pattern_checker(fg : String) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for y in 0..<8 {
    for x in 0..<8 {
      if (x + y) % 2 == 0 {
        for n in density_dot(fg, x, y) {
          out.push(n)
        }
      }
    }
  }
  out
}

///|
/// §18.18.55 `darkGray` — 75 % coverage.  Inverse of the 25 %
/// lattice (48 of 64 px coloured).
fn density_pattern_three_quarters(fg : String) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  // Build a presence map for the 25 % lattice, then paint every
  // pixel that is NOT in it.
  for y in 0..<8 {
    for x in 0..<8 {
      let on_quarter = x % 2 == 0 && y % 2 == 0
      if !on_quarter {
        for n in density_dot(fg, x, y) {
          out.push(n)
        }
      }
    }
  }
  out
}

///|
/// Render a single solid-colour cell background.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:151
fn render_cell_fill_solid(
  layout : CellLayout,
  color : String,
) -> Array[@xml.Node] {
  [
    svg_elem(
      "rect",
      [
        svg_attr("x", format_d(layout.x)),
        svg_attr("y", format_d(layout.y)),
        svg_attr("width", format_d(layout.width)),
        svg_attr("height", format_d(layout.height)),
        svg_attr("fill", color),
      ],
      [],
    ),
  ]
}

///|
/// §18.18.3 ST_BorderStyle — stroke-width / dash pattern table for
/// every spec value.  The spec enumerates 14 values and prescribes
/// the visual ordering ("hair < thin < medium < thick") but does
/// NOT pin exact stroke-width pixel sizes or dash-array
/// proportions; the values below are the renderer's
/// implementation choice, consistent with web-pptx and Excel's
/// own preview rendering.  Consumers that need exact glyph-grid
/// alignment should override the dash-array from their own
/// stylesheet — the spec-anchored identity survives on the
/// caller's source DOM via the cell's @borderId chain.
///
/// `none` returns width=0 so the caller skips emission; spec
/// violations also return 0 so we do not invent a visible
/// stroke that the source did not request.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/border-renderer.ts:25
fn border_props(style : String) -> (Double, String?) {
  match style {
    "none" => (0.0, None)
    "thin" => (1.0, None)
    "medium" => (2.0, None)
    "thick" => (3.0, None)
    "dashed" => (1.0, Some("4 2"))
    "dotted" => (1.0, Some("1 1"))
    "double" => (1.0, None)
    "hair" => (0.5, None)
    "mediumDashed" => (2.0, Some("4 2"))
    "dashDot" => (1.0, Some("4 2 1 2"))
    "mediumDashDot" => (2.0, Some("4 2 1 2"))
    "dashDotDot" => (1.0, Some("4 2 1 2 1 2"))
    "mediumDashDotDot" => (2.0, Some("4 2 1 2 1 2"))
    "slantDashDot" => (2.0, Some("4 2 1 2"))
    // Schema violation — ST_BorderStyle is closed-14; non-listed
    // values are treated as `none` (no border) so we do not
    // invent a visible stroke that the source did not request.
    _ => (0.0, None)
  }
}

///|
/// Emit one `<line>` element for a single border edge.  `double`
/// emits two parallel offset lines.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/border-renderer.ts:70
fn render_border_edge(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  edge : ResolvedBorderEdge,
) -> Array[@xml.Node] {
  let (width, dash) = border_props(edge.style)
  if width == 0.0 {
    return []
  }
  let base_attrs = fn() -> Array[@xml.Attribute] {
    let attrs : Array[@xml.Attribute] = [
      svg_attr("x1", format_d(x1)),
      svg_attr("y1", format_d(y1)),
      svg_attr("x2", format_d(x2)),
      svg_attr("y2", format_d(y2)),
      svg_attr("stroke", edge.color),
      svg_attr("stroke-width", format_d(width)),
    ]
    match dash {
      Some(d) => attrs.push(svg_attr("stroke-dasharray", d))
      None => ()
    }
    attrs
  }
  if edge.style == "double" {
    let offset = 1.0
    let is_horizontal = y1 == y2
    let attrs_a = base_attrs()
    let attrs_b = base_attrs()
    if is_horizontal {
      attrs_a.push(
        svg_attr("transform", "translate(0, -" + format_d(offset) + ")"),
      )
      attrs_b.push(
        svg_attr("transform", "translate(0, " + format_d(offset) + ")"),
      )
    } else {
      attrs_a.push(
        svg_attr("transform", "translate(-" + format_d(offset) + ", 0)"),
      )
      attrs_b.push(
        svg_attr("transform", "translate(" + format_d(offset) + ", 0)"),
      )
    }
    [svg_elem("line", attrs_a, []), svg_elem("line", attrs_b, [])]
  } else {
    [svg_elem("line", base_attrs(), [])]
  }
}

///|
/// Render every border edge declared on `layout`.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/border-renderer.ts:122
fn render_cell_borders(
  layout : CellLayout,
  border : ResolvedBorder,
) -> Array[@xml.Node] {
  if layout.is_hidden_by_merge || layout.width == 0.0 || layout.height == 0.0 {
    return []
  }
  let x = layout.x
  let y = layout.y
  let w = layout.width
  let h = layout.height
  let out : Array[@xml.Node] = []
  let append = fn(nodes : Array[@xml.Node]) -> Unit {
    for n in nodes {
      out.push(n)
    }
  }
  match border.top {
    Some(e) => append(render_border_edge(x, y, x + w, y, e))
    None => ()
  }
  match border.right {
    Some(e) => append(render_border_edge(x + w, y, x + w, y + h, e))
    None => ()
  }
  match border.bottom {
    Some(e) => append(render_border_edge(x, y + h, x + w, y + h, e))
    None => ()
  }
  match border.left {
    Some(e) => append(render_border_edge(x, y, x, y + h, e))
    None => ()
  }
  match border.diagonal {
    Some(e) => {
      if border.diagonal_down {
        append(render_border_edge(x, y, x + w, y + h, e))
      }
      if border.diagonal_up {
        append(render_border_edge(x, y + h, x + w, y, e))
      }
    }
    None => ()
  }
  out
}

///|
/// §18.18.40 ST_HorizontalAlignment — resolve a position + text-
/// anchor for the given alignment. The `general` value resolves to:
///   * right-aligned for numeric / date / time cells,
///   * centred for booleans and errors,
///   * left-aligned for strings (and the empty type).
/// `centerContinuous` and `distributed` render at the cell centre;
/// `fill` and `justify` render at the cell start (their full
/// repeat / multi-line stretch semantics require glyph measurement
/// the viewer doesn't perform yet — the alignment value is preserved
/// as a `data-ooxml-h-align` attribute via `horizontal_attr_value`
/// so consumers can apply CSS later).
///
/// `cell_t` carries the cell's §18.18.11 ST_CellType (or `None`
/// when the cell omits `@t`, in which case the spec default is
/// numeric — `n`).
fn horizontal_text_pos(
  layout : CellLayout,
  horizontal : String,
  padding : Double,
  cell_t? : String? = None,
) -> (Double, String) {
  let resolved = if horizontal == "general" {
    general_alignment_for(cell_t)
  } else {
    horizontal
  }
  // §18.18.40 ST_HorizontalAlignment — 8 spec values; "general"
  // is resolved upstream into a concrete alignment via
  // `general_alignment_for`. The 7 remaining values are matched
  // explicitly below; "end" is not in the spec enum but is the
  // upstream normalisation of right-handed RTL alignment so we
  // accept it here too.
  match resolved {
    "center" => (layout.x + layout.width / 2.0, "middle")
    "centerContinuous" => (layout.x + layout.width / 2.0, "middle")
    "distributed" => (layout.x + layout.width / 2.0, "middle")
    "right" => (layout.x + layout.width - padding, "end")
    "end" => (layout.x + layout.width - padding, "end")
    "fill" =>
      // §18.18.40 — `fill` repeats the cell text to fill the cell.
      // Faithful rendering requires glyph measurement; until that
      // is wired in we anchor at the cell's start edge and surface
      // the intent via `horizontal_attr_value` metadata.
      (layout.x + padding, "start")
    "justify" =>
      // §18.18.40 — `justify` distributes the inter-word spacing
      // across the cell.  Same temporary anchoring as `fill`.
      (layout.x + padding, "start")
    "left" => (layout.x + padding, "start")
    "general" =>
      // Defensive — `general_alignment_for` should have already
      // mapped this to a concrete value; treat as left for
      // forward safety.
      (layout.x + padding, "start")
    // Schema violation — unknown ST_HorizontalAlignment value.
    // Anchor at the start edge so layout still completes; the
    // raw attribute is preserved on the source DOM.
    _ => (layout.x + padding, "start")
  }
}

///|
/// §18.18.40 — return the original ST_HorizontalAlignment value
/// (resolved against the cell's @t for `general`) so the renderer
/// can surface it as a spec-anchored `data-ooxml-h-align` attribute.
/// Returns "" when the resolution falls through to the implicit
/// default so the renderer can elide the attribute.
fn horizontal_attr_value(horizontal : String, cell_t : String?) -> String {
  if horizontal == "general" {
    let g = general_alignment_for(cell_t)
    if g == "left" {
      ""
    } else {
      g
    }
  } else {
    horizontal
  }
}

///|
/// §18.18.40 / §18.18.11 — translate a cell's ST_CellType into the
/// concrete horizontal alignment implied by `general`. Every spec
/// ST_CellType value (b, d, e, inlineStr, n, s, str) is matched
/// explicitly so future cell types do not silently default to
/// right-aligned. Strings (`s` / `str` / `inlineStr`) left-align,
/// booleans / errors centre, numbers and dates right-align.
fn general_alignment_for(cell_t : String?) -> String {
  match cell_t {
    Some("s") | Some("str") | Some("inlineStr") => "left"
    Some("b") | Some("e") => "center"
    Some("n") | Some("d") | None => "right"
    // Spec violation: schema-undefined cell type. Default to
    // right-aligned to match the spec default for `n`.
    Some(_) => "right"
  }
}

///|
/// §18.18.88 ST_VerticalAlignment — compute SVG (y, dominant-
/// baseline) for every spec value. The spec enumerates 5 values
/// (top, center, bottom, justify, distributed). `justify` and
/// `distributed` are full-block vertical layouts that the SVG
/// `<text>` element cannot natively express; we anchor at the
/// cell centre as the spec-permitted fallback and surface the
/// requested alignment via `data-ooxml-v-align` upstream.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:271
fn vertical_text_pos(
  layout : CellLayout,
  vertical : String,
  font_size : Double,
  padding : Double,
) -> (Double, String) {
  // §18.18.88 ST_VerticalAlignment — exactly 5 values:
  //   top, center, bottom, justify, distributed.
  match vertical {
    "top" => (layout.y + font_size + padding, "hanging")
    "center" => (layout.y + layout.height / 2.0, "middle")
    "bottom" => (layout.y + layout.height - padding, "alphabetic")
    "justify" => (layout.y + layout.height / 2.0, "middle")
    "distributed" => (layout.y + layout.height / 2.0, "middle")
    // Schema violation — value outside ST_VerticalAlignment.
    // Default to `bottom` per Annex A; consumers can detect the
    // violation via the cell's @vertical attribute on the source
    // DOM if they need to act on it.
    _ => (layout.y + layout.height - padding, "alphabetic")
  }
}

///|
/// §18.3.1.49 / §18.18.42 — emit an empty `<g>` element whose
/// `data-ooxml-icon` attribute carries the ST_IconSetType name and
/// `data-ooxml-bucket` carries the §18.3.1.49 bucket index. ECMA-
/// 376 does not specify the actual icon glyph or colour for any
/// ST_IconSetType value, so the viewer leaves rendering to the
/// consumer and only surfaces the spec-anchored bucket assignment.
fn render_cell_icon_metadata(
  layout : CellLayout,
  set_name : String,
  bucket : Int,
) -> Array[@xml.Node] {
  [
    svg_elem(
      "g",
      [
        svg_attr("data-ooxml-icon", set_name),
        svg_attr("data-ooxml-bucket", bucket.to_string()),
        svg_attr("data-ooxml-cell-x", format_d(layout.x)),
        svg_attr("data-ooxml-cell-y", format_d(layout.y)),
        svg_attr("data-ooxml-cell-w", format_d(layout.width)),
        svg_attr("data-ooxml-cell-h", format_d(layout.height)),
      ],
      [],
    ),
  ]
}

///|
/// §18.3.1.49 — same as `render_cell_text` but shifts the text's
/// horizontal anchor to the right by `offset_x` (the iconSet glyph's
/// reserved width). When `offset_x == 0` the behaviour is identical
/// to `render_cell_text`. `cell_t` carries the §18.18.11 cell type
/// so the `general` horizontal alignment resolves correctly per
/// §18.18.40.
fn render_cell_text_offset(
  layout : CellLayout,
  text : String,
  style : ResolvedCellStyle,
  offset_x : Double,
  cell_t? : String? = None,
) -> Array[@xml.Node] {
  if offset_x == 0.0 {
    return render_cell_text(layout, text, style, cell_t~)
  }
  let offset_layout : CellLayout = {
    x: layout.x + offset_x,
    y: layout.y,
    width: (layout.width - offset_x).max(0.0),
    height: layout.height,
    colspan: layout.colspan,
    rowspan: layout.rowspan,
    is_merge_origin: layout.is_merge_origin,
    is_hidden_by_merge: layout.is_hidden_by_merge,
  }
  render_cell_text(offset_layout, text, style, cell_t~)
}

///|
/// Render a `<text>` for the cell's display string.  Wrapped text is
/// implemented via stacked `<tspan>` lines. `cell_t` carries the
/// §18.18.11 ST_CellType (or `None` = numeric default) so the
/// `general` horizontal alignment resolves per §18.18.40.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:293
fn render_cell_text(
  layout : CellLayout,
  text : String,
  style : ResolvedCellStyle,
  cell_t? : String? = None,
) -> Array[@xml.Node] {
  let padding = 2.0
  let (tx, anchor) = horizontal_text_pos(
    layout,
    style.alignment.horizontal,
    padding,
    cell_t~,
  )
  let (ty, baseline) = vertical_text_pos(
    layout,
    style.alignment.vertical,
    style.font.size,
    padding,
  )
  if style.alignment.wrap_text && layout.width > 0.0 {
    return render_wrapped_text(layout, text, style, tx, anchor)
  }
  let attrs : Array[@xml.Attribute] = [
    svg_attr("x", format_d(tx)),
    svg_attr("y", format_d(ty)),
    svg_attr("text-anchor", anchor),
    svg_attr("dominant-baseline", baseline),
  ]
  // §18.18.40 — surface the resolved ST_HorizontalAlignment as a
  // spec-anchored data attribute so consumers can apply alignment
  // semantics (especially `fill` / `justify` / `distributed` /
  // `centerContinuous`) the viewer cannot render directly.
  let h_align_attr = horizontal_attr_value(style.alignment.horizontal, cell_t)
  if h_align_attr.length() > 0 {
    attrs.push(svg_attr("data-ooxml-h-align", h_align_attr))
  }
  // §18.8.1 — text-rotation (0..180 or 255 for vertical-stack).
  // Apply as `transform="rotate(-N,tx,ty)"` so the SVG rotates
  // the glyphs around the text anchor point; 255 is vertical-
  // stack (each char on its own line) which we surface as
  // `data-ooxml-text-rotation="255"` for downstream rendering.
  if style.alignment.text_rotation != 0 {
    let rot = style.alignment.text_rotation
    if rot == 255 {
      attrs.push(svg_attr("data-ooxml-text-rotation", "255"))
    } else {
      // §18.8.1 — Excel's rotation is counter-clockwise; SVG's
      // is clockwise, so negate.  Also surface as data attr so
      // consumers can read the raw spec value.
      attrs.push(svg_attr("data-ooxml-text-rotation", rot.to_string()))
      attrs.push(
        svg_attr(
          "transform",
          "rotate(" +
          (-rot).to_string() +
          "," +
          format_d(tx) +
          "," +
          format_d(ty) +
          ")",
        ),
      )
    }
  }
  // §18.8.1 — indent: each unit = 3 spaces (§18.18.x).  Surface
  // raw value so consumers can apply left/right padding.
  if style.alignment.indent != 0 {
    attrs.push(
      svg_attr("data-ooxml-indent", style.alignment.indent.to_string()),
    )
  }
  if style.alignment.shrink_to_fit {
    attrs.push(svg_attr("data-ooxml-shrink-to-fit", "1"))
  }
  if style.alignment.reading_order != 0 {
    attrs.push(
      svg_attr(
        "data-ooxml-reading-order",
        style.alignment.reading_order.to_string(),
      ),
    )
  }
  append_font_attrs(attrs, style.font)
  [svg_elem("text", attrs, [svg_text(text)])]
}

///|
/// Emit the cell text as stacked `<tspan>` lines.  Mirrors
/// `renderWrappedText`: split on newlines first, then greedy word-wrap
/// each paragraph at `width / (font_size * 0.6)` characters.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:392
fn render_wrapped_text(
  layout : CellLayout,
  text : String,
  style : ResolvedCellStyle,
  x : Double,
  anchor : String,
) -> Array[@xml.Node] {
  let font_size = style.font.size
  let line_height = font_size * 1.2
  let max_lines_d = (layout.height / line_height).to_int()
  let max_lines = if max_lines_d < 1 { 1 } else { max_lines_d }
  let lines = wrap_text(text, layout.width, font_size, max_lines)
  if lines.length() == 0 {
    return []
  }
  let padding = 2.0
  let start_y = layout.y + font_size + padding
  let attrs : Array[@xml.Attribute] = [svg_attr("text-anchor", anchor)]
  append_font_attrs(attrs, style.font)
  let tspans : Array[@xml.Node] = []
  for i, line in lines {
    if i == 0 {
      tspans.push(
        svg_elem(
          "tspan",
          [svg_attr("x", format_d(x)), svg_attr("y", format_d(start_y))],
          [svg_text(line)],
        ),
      )
    } else {
      tspans.push(
        svg_elem(
          "tspan",
          [svg_attr("x", format_d(x)), svg_attr("dy", format_d(line_height))],
          [svg_text(line)],
        ),
      )
    }
  }
  [svg_elem("text", attrs, tspans)]
}

///|
/// Word-wrap `text` for the cell width / font size / max-line bounds.
/// Splits paragraphs on `\n`/`\r\n` first, then greedily packs words
/// into lines.  Single overlong words overflow rather than truncate.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:433
fn wrap_text(
  text : String,
  width : Double,
  font_size : Double,
  max_lines : Int,
) -> Array[String] {
  let avg_char = font_size * 0.6
  let chars_per_line_d = (width / avg_char).to_int()
  let chars_per_line = if chars_per_line_d < 1 { 1 } else { chars_per_line_d }
  let paragraphs = split_lines(text)
  let result : Array[String] = []
  for paragraph in paragraphs {
    if result.length() >= max_lines {
      break
    }
    if paragraph == "" {
      result.push("")
      continue
    }
    let words = split_words(paragraph)
    let remaining = max_lines - result.length()
    let wrapped = greedy_wrap(words, chars_per_line, remaining)
    for w in wrapped {
      result.push(w)
    }
  }
  if result.length() > max_lines {
    let truncated : Array[String] = []
    for i in 0..<max_lines {
      truncated.push(result[i])
    }
    return truncated
  }
  result
}

///|
fn split_lines(text : String) -> Array[String] {
  let out : Array[String] = []
  let buf = StringBuilder::new()
  let mut i = 0
  let len = text.length()
  while i < len {
    let c = text.unsafe_charcode_at(i)
    if c == '\r'.to_int() {
      out.push(buf.to_string())
      buf.reset()
      // Skip following \n if present.
      if i + 1 < len && text.unsafe_charcode_at(i + 1) == '\n'.to_int() {
        i = i + 1
      }
    } else if c == '\n'.to_int() {
      out.push(buf.to_string())
      buf.reset()
    } else {
      buf.write_char(Char::from_int(c))
    }
    i = i + 1
  }
  out.push(buf.to_string())
  out
}

///|
fn split_words(paragraph : String) -> Array[String] {
  let out : Array[String] = []
  let buf = StringBuilder::new()
  for i in 0..<paragraph.length() {
    let c = paragraph.unsafe_charcode_at(i)
    if c == ' '.to_int() || c == '\t'.to_int() {
      if buf.to_string().length() > 0 {
        out.push(buf.to_string())
        buf.reset()
      }
    } else {
      buf.write_char(Char::from_int(c))
    }
  }
  if buf.to_string().length() > 0 {
    out.push(buf.to_string())
  }
  out
}

///|
fn greedy_wrap(
  words : Array[String],
  chars_per_line : Int,
  max_lines : Int,
) -> Array[String] {
  let lines : Array[String] = []
  let mut current = ""
  for word in words {
    if lines.length() >= max_lines {
      break
    }
    let test_line = if current == "" { word } else { current + " " + word }
    if test_line.length() > chars_per_line && current != "" {
      lines.push(current)
      if lines.length() >= max_lines {
        current = ""
        break
      }
      current = word
    } else {
      current = test_line
    }
  }
  if current != "" && lines.length() < max_lines {
    lines.push(current)
  }
  lines
}

///|
/// Append font-related SVG presentation attributes to `attrs`.
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:357
fn append_font_attrs(
  attrs : Array[@xml.Attribute],
  font : ResolvedFont,
) -> Unit {
  attrs.push(svg_attr("font-family", "'" + font.family + "', sans-serif"))
  attrs.push(svg_attr("font-size", format_d(font.size) + "pt"))
  if font.bold {
    attrs.push(svg_attr("font-weight", "bold"))
  }
  if font.italic {
    attrs.push(svg_attr("font-style", "italic"))
  }
  match font.color {
    Some(c) => attrs.push(svg_attr("fill", c))
    None => ()
  }
  let parts : Array[String] = []
  if font.underline {
    parts.push("underline")
  }
  if font.strikethrough {
    parts.push("line-through")
  }
  if parts.length() > 0 {
    let mut decoration = ""
    let mut first = true
    for p in parts {
      if first {
        first = false
        decoration = p
      } else {
        decoration = decoration + " " + p
      }
    }
    attrs.push(svg_attr("text-decoration", decoration))
  }
}

// =============================================================================
// Grid lines and row / column headers.
// =============================================================================

///|
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/border-renderer.ts:175
fn render_grid_lines(
  layout : SheetLayout,
  options : SheetRenderOptions,
) -> Array[@xml.Node] {
  let stroke = options.grid_line_color
  let out : Array[@xml.Node] = []

  // Vertical grid lines. We render the boundary between
  // `column[boundary_col - 1]` and `column[boundary_col]` for each
  // `boundary_col` in [0, column_count]. `boundary_col == 0` is the
  // sheet's left edge; `boundary_col == column_count` is the right
  // edge. Per §18.3.1.55, when a row's cell spans this boundary as
  // part of a merged region, we omit the segment so the gridline
  // does not cut through the merged area.
  let header_x_offset = if options.show_row_headers {
    options.header_size
  } else {
    0.0
  }
  let header_y_offset = if options.show_column_headers {
    options.header_size
  } else {
    0.0
  }
  for boundary_col in 0..<=layout.column_count {
    let x = if boundary_col < layout.column_count {
      layout.column_positions[boundary_col]
    } else {
      header_x_offset +
      sum_doubles(layout.column_widths, 0, layout.column_count)
    }
    for
      n in render_vertical_grid_segments(
        x, boundary_col, layout, stroke, header_y_offset,
      ) {
      out.push(n)
    }
  }

  // Horizontal grid lines — symmetric treatment.
  for boundary_row in 0..<=layout.row_count {
    let y = if boundary_row < layout.row_count {
      layout.row_positions[boundary_row]
    } else {
      header_y_offset + sum_doubles(layout.row_heights, 0, layout.row_count)
    }
    for
      n in render_horizontal_grid_segments(
        y, boundary_row, layout, stroke, header_x_offset,
      ) {
      out.push(n)
    }
  }
  out
}

///|
fn sum_doubles(xs : Array[Double], start : Int, end_exclusive : Int) -> Double {
  let mut s = 0.0
  let limit = if end_exclusive > xs.length() {
    xs.length()
  } else {
    end_exclusive
  }
  for i in start..<limit {
    s = s + xs[i]
  }
  s
}

///|
/// §18.3.1.55 — emit the vertical gridline `boundary_col` as a
/// sequence of `<line>` segments, skipping every contiguous row range
/// that is covered by a merged region straddling this boundary.
fn render_vertical_grid_segments(
  x : Double,
  boundary_col : Int,
  layout : SheetLayout,
  stroke : String,
  header_y_offset : Double,
) -> Array[@xml.Node] {
  if layout.row_count == 0 {
    return []
  }
  // For each row r (1-based), decide whether the boundary at column
  // `boundary_col` is suppressed for that row. The boundary is
  // suppressed when there's a merge region whose horizontal extent
  // covers both column `boundary_col` and `boundary_col + 1` for
  // that row (= the cells either side of this gridline share the
  // same merge origin).
  let segments = compute_axis_segments(layout.row_count, fn(r) {
    column_boundary_suppressed(layout, r, boundary_col)
  })
  emit_axis_line_segments(
    x,
    layout.row_positions,
    layout.row_heights,
    layout.row_count,
    header_y_offset,
    segments,
    stroke,
    vertical=true,
  )
}

///|
fn render_horizontal_grid_segments(
  y : Double,
  boundary_row : Int,
  layout : SheetLayout,
  stroke : String,
  header_x_offset : Double,
) -> Array[@xml.Node] {
  if layout.column_count == 0 {
    return []
  }
  let segments = compute_axis_segments(layout.column_count, fn(c) {
    row_boundary_suppressed(layout, c, boundary_row)
  })
  emit_axis_line_segments(
    y,
    layout.column_positions,
    layout.column_widths,
    layout.column_count,
    header_x_offset,
    segments,
    stroke,
    vertical=false,
  )
}

///|
/// Walk 1..=count and group consecutive cells by their `suppressed`
/// flag. Returns (start_index, end_index_inclusive, suppressed) in
/// cell-index order.
fn compute_axis_segments(
  count : Int,
  suppressed : (Int) -> Bool,
) -> Array[(Int, Int, Bool)] {
  let out : Array[(Int, Int, Bool)] = []
  if count == 0 {
    return out
  }
  let mut seg_start = 1
  let mut current = suppressed(1)
  for i in 2..<=count {
    let s = suppressed(i)
    if s != current {
      out.push((seg_start, i - 1, current))
      seg_start = i
      current = s
    }
  }
  out.push((seg_start, count, current))
  out
}

///|
/// §18.3.1.55 — vertical (column) boundary at `boundary_col` is
/// suppressed at row `r` iff the cells at (r, boundary_col) and
/// (r, boundary_col + 1) belong to the same merge region. Sheet
/// edges (boundary 0 and boundary == column_count) are never
/// suppressed.
fn column_boundary_suppressed(
  layout : SheetLayout,
  r : Int,
  boundary_col : Int,
) -> Bool {
  if boundary_col <= 0 || boundary_col >= layout.column_count {
    return false
  }
  let ref1 = cell_ref_from_indices(r, boundary_col)
  let ref2 = cell_ref_from_indices(r, boundary_col + 1)
  match (layout.merge_map.get(ref1), layout.merge_map.get(ref2)) {
    (Some(m1), Some(m2)) =>
      m1.origin_row == m2.origin_row && m1.origin_col == m2.origin_col
    _ => false
  }
}

///|
/// §18.3.1.55 — horizontal (row) boundary at `boundary_row` is
/// suppressed at column `c` iff the cells at (boundary_row, c) and
/// (boundary_row + 1, c) belong to the same merge region.
fn row_boundary_suppressed(
  layout : SheetLayout,
  c : Int,
  boundary_row : Int,
) -> Bool {
  if boundary_row <= 0 || boundary_row >= layout.row_count {
    return false
  }
  let ref1 = cell_ref_from_indices(boundary_row, c)
  let ref2 = cell_ref_from_indices(boundary_row + 1, c)
  match (layout.merge_map.get(ref1), layout.merge_map.get(ref2)) {
    (Some(m1), Some(m2)) =>
      m1.origin_row == m2.origin_row && m1.origin_col == m2.origin_col
    _ => false
  }
}

///|
/// Emit a single gridline (vertical or horizontal) as a sequence of
/// `<line>` segments. `axis_pos` is the fixed coordinate (x for
/// vertical lines, y for horizontal). `cell_positions` /
/// `cell_sizes` describe the cells along the running axis.
fn emit_axis_line_segments(
  axis_pos : Double,
  cell_positions : Array[Double],
  cell_sizes : Array[Double],
  cell_count : Int,
  header_offset : Double,
  segments : Array[(Int, Int, Bool)],
  stroke : String,
  vertical~ : Bool,
) -> Array[@xml.Node] {
  if cell_count == 0 {
    return []
  }
  let out : Array[@xml.Node] = []
  for seg in segments {
    let (start_i, end_i, suppressed) = seg
    if suppressed {
      continue
    }
    let start_pos = if start_i <= 1 {
      header_offset
    } else {
      cell_positions[start_i - 1]
    }
    let end_pos = if end_i >= cell_count {
      header_offset + sum_doubles(cell_sizes, 0, cell_count)
    } else {
      cell_positions[end_i - 1] + cell_sizes[end_i - 1]
    }
    let attrs : Array[@xml.Attribute] = if vertical {
      [
        svg_attr("x1", format_d(axis_pos)),
        svg_attr("y1", format_d(start_pos)),
        svg_attr("x2", format_d(axis_pos)),
        svg_attr("y2", format_d(end_pos)),
        svg_attr("stroke", stroke),
        svg_attr("stroke-width", "0.5"),
      ]
    } else {
      [
        svg_attr("x1", format_d(start_pos)),
        svg_attr("y1", format_d(axis_pos)),
        svg_attr("x2", format_d(end_pos)),
        svg_attr("y2", format_d(axis_pos)),
        svg_attr("stroke", stroke),
        svg_attr("stroke-width", "0.5"),
      ]
    }
    out.push(svg_elem("line", attrs, []))
  }
  out
}

///|
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/border-renderer.ts:228
fn render_column_headers(
  layout : SheetLayout,
  options : SheetRenderOptions,
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = [
    svg_elem(
      "rect",
      [
        svg_attr("x", "0"),
        svg_attr("y", "0"),
        svg_attr("width", format_d(layout.total_width)),
        svg_attr("height", format_d(options.header_size)),
        svg_attr("fill", "#F0F0F0"),
        svg_attr("stroke", "#C0C0C0"),
      ],
      [],
    ),
  ]
  for i, x in layout.column_positions {
    let w = layout.column_widths[i]
    if w == 0.0 {
      continue
    }
    let label = column_index_to_letter(i + 1)
    out.push(
      svg_elem(
        "text",
        [
          svg_attr("x", format_d(x + w / 2.0)),
          svg_attr("y", format_d(options.header_size / 2.0)),
          svg_attr("text-anchor", "middle"),
          svg_attr("dominant-baseline", "middle"),
          svg_attr("font-size", "10"),
          svg_attr("fill", "#666666"),
        ],
        [svg_text(label)],
      ),
    )
  }
  out
}

///|
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/border-renderer.ts:260
fn render_row_headers(
  layout : SheetLayout,
  options : SheetRenderOptions,
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = [
    svg_elem(
      "rect",
      [
        svg_attr("x", "0"),
        svg_attr("y", "0"),
        svg_attr("width", format_d(options.header_size)),
        svg_attr("height", format_d(layout.total_height)),
        svg_attr("fill", "#F0F0F0"),
        svg_attr("stroke", "#C0C0C0"),
      ],
      [],
    ),
  ]
  for i, y in layout.row_positions {
    let h = layout.row_heights[i]
    if h == 0.0 {
      continue
    }
    let label = (i + 1).to_string()
    out.push(
      svg_elem(
        "text",
        [
          svg_attr("x", format_d(options.header_size / 2.0)),
          svg_attr("y", format_d(y + h / 2.0)),
          svg_attr("text-anchor", "middle"),
          svg_attr("dominant-baseline", "middle"),
          svg_attr("font-size", "10"),
          svg_attr("fill", "#666666"),
        ],
        [svg_text(label)],
      ),
    )
  }
  out
}

// =============================================================================
// Small utilities (local to the SVG renderer so we do not clash with
// the existing helpers in viewer.mbt).
// =============================================================================

///|
fn first_child_named_local(
  element : @xml.Element,
  name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      Element(e) => if e.name.local_name == name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
fn attr_value_local(element : @xml.Element, local_name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return Some(attr.value)
    }
  }
  None
}

///|
fn xml_text_content(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(t) | CData(t) => out.write_string(t)
      Element(e) => out.write_string(xml_text_content(e))
      _ => ()
    }
  }
  out.to_string()
}

///|
fn parse_int_attr_or(
  element : @xml.Element,
  name : String,
  default : Int,
) -> Int {
  match attr_value_local(element, name) {
    None => default
    Some(v) =>
      match (try? @strconv.parse_int(v.trim_space().to_string())) {
        Ok(i) => i
        Err(_) => default
      }
  }
}

///|
/// Build an SVG element node carrying the SVG namespace on every
/// element (so `@xml.write` emits a single root `xmlns`).  All SVG
/// output in this file flows through this helper and `svg_attr` /
/// `svg_text`; no markup is ever assembled by string concatenation,
/// so the `@xml` writer escapes every attribute value / text node
/// and no OOXML payload can break out of its context.
fn svg_elem(
  tag : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Node {
  @markup.elem_ns(tag, @markup.svg_ns, attrs, children)
}

///|
/// Build a single SVG attribute (name + value); the value is
/// escaped by the writer at serialisation time.
fn svg_attr(name : String, value : String) -> @xml.Attribute {
  @markup.attr(name, value)
}

///|
/// Wrap a raw string as an XML text node for SVG element content.
fn svg_text(value : String) -> @xml.Node {
  @markup.text(value)
}

///|
/// Format a double for SVG output; integral values omit the
/// fractional part.
fn format_d(value : Double) -> String {
  if value == value.to_int().to_double() {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}

// =============================================================================
// Drawing anchor rendering (§20.5.2.35 xdr:wsDr)
// =============================================================================

///|
/// EMU constants — 914400 EMU = 1 inch, 96 dpi yields the per-pixel
/// scaling used by the rest of the SVG output.
let emu_per_inch : Double = 914400.0

///|
let pixels_per_inch : Double = 96.0

///|
/// Convert EMU (English Metric Units) to CSS pixels. Mirrors web-pptx
/// `emuToPixels` in drawing-layout.ts at 96 dpi.
fn emu_to_pixels(emu : Double) -> Double {
  emu / emu_per_inch * pixels_per_inch
}

///|
/// Render a single `<xdr:twoCellAnchor>` / `<xdr:oneCellAnchor>` /
/// `<xdr:absoluteAnchor>` to an SVG group. Anchors with zero or
/// negative bounds are skipped (mirrors web-pptx renderAnchor's
/// width/height guard). The inner content is a placeholder rect plus
/// a labelled `<text>` describing the EG_ObjectChoices arm so client
/// code sees that the anchor exists and where it lives on the sheet.
fn render_drawing_anchor(
  anchor : @drawing.EG_Anchor,
  layout : SheetLayout,
  image_resolver : (String) -> String?,
  warnings : Array[String],
) -> Array[@xml.Node] {
  let bounds = drawing_bounds_for(anchor, layout)
  if bounds.width <= 0.0 || bounds.height <= 0.0 {
    return []
  }
  let (label, choice) = drawing_choice_info(anchor)
  // §20.5.2 dml-spreadsheetDrawing EG_ObjectChoices — record an info
  // entry so callers can list every anchor's choice arm without
  // re-walking the EG_Anchor sum.
  warnings.push(
    "xdr:anchor " +
    label +
    " at (" +
    format_d(bounds.x) +
    "," +
    format_d(bounds.y) +
    ") " +
    format_d(bounds.width) +
    "x" +
    format_d(bounds.height),
  )
  // §20.5.2.25 picture — try the typed picture renderer first so the
  // image becomes a real `<image>` element when an `image_resolver`
  // resolves the embedded blip; fall back to the labelled placeholder
  // otherwise. §20.5.2.30 shape goes through the typed preset-
  // geometry pipeline so simple rectangles / ellipses / lines render
  // as actual SVG paths instead of the legacy labelled rect.
  let inner : Array[@xml.Node] = match choice {
    Pic(pic) =>
      match render_drawing_picture(pic, bounds, image_resolver) {
        Some(node) => [node]
        None => drawing_placeholder_inner(bounds, label)
      }
    Sp(sp) =>
      match render_drawing_shape(sp, bounds) {
        Some(node) => [node]
        None => drawing_placeholder_inner(bounds, label)
      }
    CxnSp(cxn) =>
      match render_drawing_connector(cxn, bounds) {
        Some(node) => [node]
        None => drawing_placeholder_inner(bounds, label)
      }
    GrpSp(grp) => [render_drawing_group(grp, bounds, image_resolver)]
    _ => drawing_placeholder_inner(bounds, label)
  }
  [
    svg_elem(
      "g",
      [
        svg_attr("class", "drawing"),
        svg_attr(
          "transform",
          "translate(" + format_d(bounds.x) + "," + format_d(bounds.y) + ")",
        ),
      ],
      inner,
    ),
  ]
}

///|
/// Render the inner SVG fragment for a `<xdr:pic>` anchor when its
/// embedded blip resolves through the supplied `image_resolver`.
/// Mirrors web-pptx renderPicture (xlsx/svg/drawing/picture-renderer.ts).
fn render_drawing_picture(
  pic : @drawing.CT_Picture,
  bounds : DrawingBounds,
  image_resolver : (String) -> String?,
) -> @xml.Node? {
  let blip = match first_child_named_local(pic.element, "blipFill") {
    Some(bf) => first_child_named_local(bf, "blip")
    None => return None
  }
  let blip_elt = match blip {
    Some(b) => b
    None => return None
  }
  let rid = match attr_value_local(blip_elt, "embed") {
    Some(v) => v
    None =>
      match attr_value_local(blip_elt, "link") {
        Some(v) => v
        None => return None
      }
  }
  match image_resolver(rid) {
    None => None
    Some(href) =>
      Some(
        svg_elem(
          "image",
          [
            svg_attr("x", "0"),
            svg_attr("y", "0"),
            svg_attr("width", format_d(bounds.width)),
            svg_attr("height", format_d(bounds.height)),
            svg_attr("href", href),
            svg_attr("preserveAspectRatio", "none"),
          ],
          [],
        ),
      )
  }
}

///|
/// Render the inner SVG fragment for an `<xdr:sp>` (CT_Shape) anchor.
/// Reads `<xdr:spPr>/<a:prstGeom @prst>` and dispatches to the
/// preset-shape path generator. The fill / stroke are picked from
/// `<a:solidFill>` and `<a:ln>` children when present, falling back
/// to a neutral grey theme palette so the shape is visible. Returns
/// `None` when no `<a:prstGeom>` is present so the caller can fall
/// back to the labelled placeholder.
fn render_drawing_shape(
  sp : @drawing.CT_Shape,
  bounds : DrawingBounds,
) -> @xml.Node? {
  let sp_pr = match first_child_named_local(sp.element, "spPr") {
    Some(p) => p
    None => return None
  }
  let prst_geom = match first_child_named_local(sp_pr, "prstGeom") {
    Some(g) => g
    None => return None
  }
  let prst = match attr_value_local(prst_geom, "prst") {
    Some(v) => v
    None => return None
  }
  let path_d = drawing_preset_path(prst, bounds.width, bounds.height)
  if path_d == "" {
    // §20.1.10.55 — preset name is enumerated but not yet drawn by
    // the viewer. Surface it as spec-anchored metadata so the
    // consumer can apply the right geometry; render the spec-
    // mandated bounding box only (no cosmetic chrome).
    return Some(render_drawing_unknown_preset(prst, bounds))
  }
  // §20.1.2.2.36 `<a:solidFill>` — when no fill cascade resolves
  // the spec defers to the shape's theme style (§20.1.4.1.21
  // `<a:spStyle>`).  We have no theme lookup here; surface
  // `currentColor` so the SVG cascade or downstream theme layer
  // picks the actual hue.  The previous `#d9d9d9` was a
  // PowerPoint-UX placeholder with no §20.1 basis.
  let fill = resolve_shape_solid_color(sp_pr, "solidFill", "currentColor")
  // §20.1.2.2.24 `<a:ln>` — same theme-cascade semantics for
  // stroke.  `#808080` was a viewer convention; we emit
  // `currentColor` so the consumer's cascade decides.  §20.1.2.1.3
  // 9525 EMU = 1 CSS px at 96 dpi remains the stroke-width
  // conversion factor.
  let ln_opt = first_child_named_local(sp_pr, "ln")
  let stroke = match ln_opt {
    None => "currentColor"
    Some(ln) => resolve_shape_solid_color(ln, "solidFill", "currentColor")
  }
  let stroke_width_px = match ln_opt {
    None => 1.0
    Some(ln) =>
      match attr_value_local(ln, "w") {
        None => 1.0
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(emu) => (emu / 9525.0).max(0.0)
            Err(_) => 1.0
          }
      }
  }
  // Optional text body — emit a centered `<text>` for a single-string
  // `<a:t>` payload. Anything richer falls back silently.
  let text_node = drawing_shape_text_svg(sp.element, bounds)
  let children : Array[@xml.Node] = [
    svg_elem(
      "path",
      [
        svg_attr("d", path_d),
        svg_attr("fill", fill),
        svg_attr("stroke", stroke),
        svg_attr("stroke-width", format_d(stroke_width_px)),
      ],
      [],
    ),
  ]
  match text_node {
    Some(n) => children.push(n)
    None => ()
  }
  Some(svg_elem("g", [svg_attr("class", "shape")], children))
}

///|
/// Emit a minimal SVG `d=` body for a `<a:prstGeom prst="…">` value
/// in the rectangle (0, 0, w, h). Returns "" for presets we don't yet
/// understand so the caller can pick a fallback rendering path.
fn drawing_preset_path(prst : String, w : Double, h : Double) -> String {
  // §20.1.10.55 ST_ShapeType — route the preset name through the
  // shared `@preset_geometry` dispatcher that covers the entire
  // 187-value enumeration.  Returns "" only when the preset name
  // is outside the spec enum (schema violation), letting the
  // caller fall through to a metadata-only `<g>` so the spec
  // attribute survives in the output.
  match render_preset_shape_d(prst, w, h) {
    Some(d) => d
    None => ""
  }
}

///|
/// Look up `<a:solidFill>/<a:srgbClr @val>` under `parent` (e.g.
/// `<a:spPr>` or `<a:ln>`) and return `#rrggbb`. Returns `fallback`
/// when no solid-fill colour is present.
fn resolve_shape_solid_color(
  parent : @xml.Element,
  fill_local_name : String,
  fallback : String,
) -> String {
  match first_child_named_local(parent, fill_local_name) {
    None => fallback
    Some(fill) =>
      match first_child_named_local(fill, "srgbClr") {
        None => fallback
        Some(c) =>
          match attr_value_local(c, "val") {
            None => fallback
            Some(v) => "#" + v.to_lower()
          }
      }
  }
}

///|
/// Extract the concatenated text of an `<xdr:txBody>` child of an
/// `<xdr:sp>` and render it as a centred `<text>` element. Returns
/// `""` when no text payload is present.
fn drawing_shape_text_svg(
  sp : @xml.Element,
  bounds : DrawingBounds,
) -> @xml.Node? {
  let tx_body = match first_child_named_local(sp, "txBody") {
    Some(t) => t
    None => return None
  }
  let buf = StringBuilder::new()
  // §21.1.2.3.7 — capture the first run's `<a:rPr>` so the rendered
  // `<text>` can honour size / typeface / colour. Later runs are
  // concatenated as text but inherit the first run's properties.
  let mut first_rpr : @xml.Element? = None
  for child in tx_body.children {
    match child {
      Element(p) =>
        if p.name.local_name == "p" {
          for run in p.children {
            match run {
              Element(r) =>
                if r.name.local_name == "r" {
                  if first_rpr is None {
                    first_rpr = first_child_named_local(r, "rPr")
                  }
                  for t in r.children {
                    match t {
                      Element(t_el) =>
                        if t_el.name.local_name == "t" {
                          buf.write_string(xml_text_content(t_el))
                        }
                      _ => ()
                    }
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  let text = buf.to_string()
  if text.length() == 0 {
    return None
  }
  // §21.1.2.3.13 sz — `<a:rPr sz="N">` is 1/100 pt. Default is
  // implementation-defined; we use 11 pt as a documented fallback.
  // §21.1.2.3.1-2/10 latin/ea/cs/sym — pick the first available
  // typeface, falling back to the generic CSS `serif` family per
  // the same convention as the WML viewer.
  // §21.1.2.3.7 — `<a:solidFill>/<a:srgbClr @val>` for the run
  // §21.1.2.3.13 — when no rPr is present, font defaults come
  // from the theme `<a:fontScheme>` cascade (PowerPoint default
  // 1800 hundredths-of-a-point = 18 pt, applied through the
  // body-text default); we have no theme lookup here so we use
  // the §18.4.2 SML implementation default (11 pt) and surface
  // the absence as metadata via the `data-ooxml-font-default`
  // attribute on the caller's <text> element.
  // Colour: `currentColor` per §18.8.3 `auto` resolution.
  let (font_size_pt, font_family, fill_color) = match first_rpr {
    None => (11.0, "", "currentColor")
    Some(rp) => {
      let sz = match attr_value_local(rp, "sz") {
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(hp) => hp / 100.0
            Err(_) => 11.0
          }
        None => 11.0
      }
      // §21.1.2.3.13 — when @typeface is absent, defer to the
      // SVG cascade rather than substituting `serif`.
      let typeface = drawing_text_typeface(rp).unwrap_or("")
      let color = drawing_text_color(rp).unwrap_or("currentColor")
      (sz, typeface, color)
    }
  }
  // §21.1.2.3.13 — when the run carries no @typeface the SVG
  // text inherits its parent's font-family; emit no attribute
  // rather than `font-family=""` (invalid CSS) so the cascade
  // survives.
  let attrs : Array[@xml.Attribute] = [
    svg_attr("x", format_d(bounds.width / 2.0)),
    svg_attr("y", format_d(bounds.height / 2.0)),
    svg_attr("text-anchor", "middle"),
    svg_attr("dominant-baseline", "middle"),
    svg_attr("font-size", format_d(font_size_pt) + "pt"),
  ]
  if font_family.length() > 0 {
    attrs.push(svg_attr("font-family", font_family))
  }
  attrs.push(svg_attr("fill", fill_color))
  Some(svg_elem("text", attrs, [svg_text(text)]))
}

///|
/// §21.1.2.3.1-2 / §21.1.2.3.10 — locate one of the typeface
/// children (`<a:latin>` / `<a:ea>` / `<a:cs>` / `<a:sym>`) under
/// `r_pr` and return its `@typeface`. Theme-shorthand values like
/// `+mj-lt` / `+mn-lt` are passed through verbatim; their full
/// resolution against the workbook theme is a separate task.
fn drawing_text_typeface(r_pr : @xml.Element) -> String? {
  for local in ["latin", "ea", "cs", "sym"] {
    match first_child_named_local(r_pr, local) {
      Some(el) =>
        match attr_value_local(el, "typeface") {
          Some(v) => return Some(v)
          None => ()
        }
      None => ()
    }
  }
  None
}

///|
/// §21.1.2.3 EG_TextRunProperties — read `<a:solidFill>/<a:srgbClr
/// @val>` from `r_pr` and return the resolved RGB hex string.
fn drawing_text_color(r_pr : @xml.Element) -> String? {
  let solid = first_child_named_local(r_pr, "solidFill")
  match solid {
    None => None
    Some(sf) =>
      match first_child_named_local(sf, "srgbClr") {
        None => None
        Some(rgb_el) =>
          match attr_value_local(rgb_el, "val") {
            Some(hex) => Some("#" + hex)
            None => None
          }
      }
  }
}

///|
/// Render the inner SVG fragment for an `<xdr:grpSp>` (CT_GroupShape)
/// anchor. Walks the group's EG_ObjectChoices children and renders
/// each one against its own `<a:xfrm>`-relative bounds (offset by the
/// group's `<a:chOff>` so children land in the group's coordinate
/// system). Anchors with no child geometry fall back to the labelled
/// placeholder so the structure is still visible.
fn render_drawing_group(
  grp : @drawing.CT_GroupShape,
  bounds : DrawingBounds,
  image_resolver : (String) -> String?,
) -> @xml.Node {
  // §20.1.7.5 grpSpPr/xfrm — the group has its own `chOff` / `chExt`
  // (child coordinate space) which we translate into the group's
  // pixel bounds. We approximate by uniformly scaling children using
  // the ratio between `chExt` and the group's pixel size. When the
  // group declares no `<a:xfrm>` we default to a 1:1 mapping rooted
  // at (0, 0).
  let (ch_off_x, ch_off_y, ch_ext_w, ch_ext_h) = group_child_coords(grp)
  let group_children : Array[@xml.Node] = []
  for child in grp.shapes {
    let child_bounds = group_child_bounds(
      child, bounds, ch_off_x, ch_off_y, ch_ext_w, ch_ext_h,
    )
    let inner : Array[@xml.Node] = match child {
      Sp(sp) =>
        match render_drawing_shape(sp, child_bounds) {
          Some(node) => [node]
          None => drawing_placeholder_inner(child_bounds, "Shape")
        }
      Pic(pic) =>
        match render_drawing_picture(pic, child_bounds, image_resolver) {
          Some(node) => [node]
          None => drawing_placeholder_inner(child_bounds, "Picture")
        }
      CxnSp(cxn) =>
        match render_drawing_connector(cxn, child_bounds) {
          Some(node) => [node]
          None => drawing_placeholder_inner(child_bounds, "Connector")
        }
      GrpSp(nested) =>
        [render_drawing_group(nested, child_bounds, image_resolver)]
      GraphicFrame(_) => drawing_placeholder_inner(child_bounds, "GraphicFrame")
      ContentPart(_) => drawing_placeholder_inner(child_bounds, "ContentPart")
    }
    group_children.push(
      svg_elem(
        "g",
        [
          svg_attr(
            "transform",
            "translate(" +
            format_d(child_bounds.x) +
            "," +
            format_d(child_bounds.y) +
            ")",
          ),
        ],
        inner,
      ),
    )
  }
  svg_elem("g", [svg_attr("class", "group")], group_children)
}

///|
/// Read the group's `<a:xfrm>/<a:chOff>` (child origin) and
/// `<a:chExt>` (child extent) values in EMU. Returns (cx_off, cy_off,
/// cx_ext, cy_ext) — defaults to (0, 0, 914400, 914400) when the
/// group hasn't declared a child coordinate space so callers always
/// have a non-zero denominator.
fn group_child_coords(
  grp : @drawing.CT_GroupShape,
) -> (Double, Double, Double, Double) {
  let xfrm = match first_child_named_local(grp.element, "grpSpPr") {
    None => None
    Some(gsp) => first_child_named_local(gsp, "xfrm")
  }
  match xfrm {
    None => (0.0, 0.0, 914400.0, 914400.0)
    Some(x) => {
      let ch_off = first_child_named_local(x, "chOff")
      let ch_ext = first_child_named_local(x, "chExt")
      let off_x = match ch_off {
        Some(o) => parse_double_or(attr_value_local(o, "x").unwrap_or("0"), 0.0)
        None => 0.0
      }
      let off_y = match ch_off {
        Some(o) => parse_double_or(attr_value_local(o, "y").unwrap_or("0"), 0.0)
        None => 0.0
      }
      let ext_w = match ch_ext {
        Some(e) =>
          parse_double_or(
            attr_value_local(e, "cx").unwrap_or("914400"),
            914400.0,
          )
        None => 914400.0
      }
      let ext_h = match ch_ext {
        Some(e) =>
          parse_double_or(
            attr_value_local(e, "cy").unwrap_or("914400"),
            914400.0,
          )
        None => 914400.0
      }
      (off_x, off_y, ext_w, ext_h)
    }
  }
}

///|
/// Compute the pixel bounds for a child of a `<xdr:grpSp>`. The
/// child carries its own `<a:xfrm>/<a:off>` / `<a:ext>` (EMU) which
/// we map into the group's pixel rectangle by scaling against the
/// group's `chExt`. ContentPart / GraphicFrame fall back to the
/// group's full bounds because they don't carry an embedded xfrm.
fn group_child_bounds(
  child : @drawing.EG_ObjectChoices,
  group_bounds : DrawingBounds,
  ch_off_x : Double,
  ch_off_y : Double,
  ch_ext_w : Double,
  ch_ext_h : Double,
) -> DrawingBounds {
  let child_element = match child {
    Sp(s) => Some(s.element)
    Pic(p) => Some(p.element)
    CxnSp(c) => Some(c.element)
    GrpSp(g) => Some(g.element)
    GraphicFrame(_) | ContentPart(_) => None
  }
  let xfrm = match child_element {
    None => None
    Some(e) =>
      match first_child_named_local(e, "spPr") {
        None => None
        Some(sp_pr) => first_child_named_local(sp_pr, "xfrm")
      }
  }
  match xfrm {
    None =>
      { x: 0.0, y: 0.0, width: group_bounds.width, height: group_bounds.height }
    Some(x) => {
      let off = first_child_named_local(x, "off")
      let ext = first_child_named_local(x, "ext")
      let off_x_emu = match off {
        Some(o) => parse_double_or(attr_value_local(o, "x").unwrap_or("0"), 0.0)
        None => 0.0
      }
      let off_y_emu = match off {
        Some(o) => parse_double_or(attr_value_local(o, "y").unwrap_or("0"), 0.0)
        None => 0.0
      }
      let ext_w_emu = match ext {
        Some(e) =>
          parse_double_or(attr_value_local(e, "cx").unwrap_or("0"), 0.0)
        None => 0.0
      }
      let ext_h_emu = match ext {
        Some(e) =>
          parse_double_or(attr_value_local(e, "cy").unwrap_or("0"), 0.0)
        None => 0.0
      }
      // Map child EMU coordinates into the group's pixel rectangle
      // through the chOff/chExt scale.
      let sx = if ch_ext_w > 0.0 { group_bounds.width / ch_ext_w } else { 0.0 }
      let sy = if ch_ext_h > 0.0 { group_bounds.height / ch_ext_h } else { 0.0 }
      {
        x: (off_x_emu - ch_off_x) * sx,
        y: (off_y_emu - ch_off_y) * sy,
        width: ext_w_emu * sx,
        height: ext_h_emu * sy,
      }
    }
  }
}

///|
/// Render the inner SVG fragment for an `<xdr:cxnSp>` (CT_Connector)
/// anchor. Reads `<xdr:spPr>/<a:prstGeom @prst>` to decide the path
/// (defaults to a corner-to-corner diagonal when missing — Word /
/// Excel's default "line" preset), and `<xdr:spPr>/<a:ln>` for stroke
/// colour and width.
fn render_drawing_connector(
  cxn : @drawing.CT_Connector,
  bounds : DrawingBounds,
) -> @xml.Node? {
  let sp_pr = match first_child_named_local(cxn.element, "spPr") {
    Some(p) => p
    None => return None
  }
  let path_d = drawing_connector_path(sp_pr, bounds.width, bounds.height)
  if path_d == "" {
    return None
  }
  let (stroke, stroke_width) = drawing_connector_stroke(sp_pr)
  Some(
    svg_elem("g", [svg_attr("class", "connector")], [
      svg_elem(
        "path",
        [
          svg_attr("d", path_d),
          svg_attr("fill", "none"),
          svg_attr("stroke", stroke),
          svg_attr("stroke-width", format_d(stroke_width)),
        ],
        [],
      ),
    ]),
  )
}

///|
/// Build the `d=` body for a connector's `<a:prstGeom>` — special-
/// cases `prst="line"` / `prst="straightConnector1"` to a diagonal
/// from (0,0) to (w,h) and falls back to the preset-path dispatcher
/// for richer presets. Returns "" when no usable geometry survives.
fn drawing_connector_path(
  sp_pr : @xml.Element,
  w : Double,
  h : Double,
) -> String {
  match first_child_named_local(sp_pr, "prstGeom") {
    None => "M 0 0 L " + format_d(w) + " " + format_d(h)
    Some(pg) =>
      match attr_value_local(pg, "prst") {
        Some("line") | Some("straightConnector1") =>
          "M 0 0 L " + format_d(w) + " " + format_d(h)
        Some(prst) =>
          match drawing_preset_path(prst, w, h) {
            "" => "M 0 0 L " + format_d(w) + " " + format_d(h)
            d => d
          }
        None => "M 0 0 L " + format_d(w) + " " + format_d(h)
      }
  }
}

///|
/// Pull (stroke colour, stroke width in CSS pixels) from `<a:ln @w>`
/// + `<a:solidFill>/<a:srgbClr>` of a connector's shape properties.
/// Width default is 1 px when the attribute is absent; the `@w` value
/// itself is in EMU (914400/inch) so it's converted to CSS px at
/// 96 dpi.
fn drawing_connector_stroke(sp_pr : @xml.Element) -> (String, Double) {
  let ln = first_child_named_local(sp_pr, "ln")
  let color = match ln {
    None => "#000000"
    Some(l) => resolve_shape_solid_color(l, "solidFill", "#000000")
  }
  let width_px = match ln {
    None => 1.0
    Some(l) =>
      match attr_value_local(l, "w") {
        None => 1.0
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(emu) => (emu / 914400.0 * 96.0).max(0.5)
            Err(_) => 1.0
          }
      }
  }
  (color, width_px)
}

///|
/// §20.1.10.55 ST_ShapeType — when the preset name is enumerated
/// but the viewer has no path for it yet, surface the spec-anchored
/// preset name as `data-ooxml-prst` metadata on an empty `<g>` so
/// consumers can render the geometry themselves. The bounding box
/// dimensions are kept as data attributes for the same reason.
fn render_drawing_unknown_preset(
  prst : String,
  bounds : DrawingBounds,
) -> @xml.Node {
  svg_elem(
    "g",
    [
      svg_attr("data-ooxml", "shape"),
      svg_attr("data-ooxml-prst", prst),
      svg_attr("data-ooxml-w", format_d(bounds.width)),
      svg_attr("data-ooxml-h", format_d(bounds.height)),
    ],
    [],
  )
}

///|
/// §18.3.1.87 `<sheetViews>/<sheetView @showGridLines>` —
/// returns the typed boolean when the worksheet declares a
/// sheet view, else None so the caller falls back to the
/// render-time `options.show_grid_lines` toggle.  Only the
/// first sheetView is consulted because Excel only emits one
/// per worksheet for the workbook view; §18.3.1.86 sheetViews
/// permits multiple but they're per-`workbookView` and the
/// viewer doesn't yet model window state.
/// §18.3.1.65 — draw the SVG split lines that visualise a
/// `<pane>` freeze or split.  For state="frozen" or "frozenSplit"
/// the split values count columns / rows; for state="split" they
/// are pixel positions.  Returns the SVG fragment or "" when no
/// visible split applies (e.g. zero splits).
fn render_pane_split_lines(
  layout : SheetLayout,
  pane : SheetPaneInfo,
) -> @xml.Node? {
  let is_frozen = match pane.state {
    Some("frozen") => true
    Some("frozenSplit") => true
    _ => false
  }
  let x_pixel = if pane.x_split == 0.0 {
    0.0
  } else if is_frozen {
    // Convert column count to pixel x position by summing widths
    // of the first @xSplit columns.
    let n = pane.x_split.to_int()
    let mut acc = 0.0
    let mut i = 0
    while i < n && i < layout.column_widths.length() {
      acc = acc + layout.column_widths[i]
      i = i + 1
    }
    acc
  } else {
    // Twips / EMU-relative — Excel uses 1/20 of a point per
    // §18.3.1.65 "xSplit" semantics for the "split" state.
    pane.x_split
  }
  let y_pixel = if pane.y_split == 0.0 {
    0.0
  } else if is_frozen {
    let n = pane.y_split.to_int()
    let mut acc = 0.0
    let mut i = 0
    while i < n && i < layout.row_heights.length() {
      acc = acc + layout.row_heights[i]
      i = i + 1
    }
    acc
  } else {
    pane.y_split
  }
  if x_pixel == 0.0 && y_pixel == 0.0 {
    return None
  }
  let lines : Array[@xml.Node] = []
  if x_pixel > 0.0 {
    lines.push(
      svg_elem(
        "line",
        [
          svg_attr("x1", format_d(x_pixel)),
          svg_attr("y1", "0"),
          svg_attr("x2", format_d(x_pixel)),
          svg_attr("y2", format_d(layout.total_height)),
          svg_attr("stroke", "#888"),
          svg_attr("stroke-width", "1"),
          svg_attr("data-ooxml-split", "x"),
        ],
        [],
      ),
    )
  }
  if y_pixel > 0.0 {
    lines.push(
      svg_elem(
        "line",
        [
          svg_attr("x1", "0"),
          svg_attr("y1", format_d(y_pixel)),
          svg_attr("x2", format_d(layout.total_width)),
          svg_attr("y2", format_d(y_pixel)),
          svg_attr("stroke", "#888"),
          svg_attr("stroke-width", "1"),
          svg_attr("data-ooxml-split", "y"),
        ],
        [],
      ),
    )
  }
  Some(svg_elem("g", [svg_attr("class", "pane-splits")], lines))
}

///|
/// §18.3.1.40 — emit a `<g class="formulas">` group with one
/// `<rect data-ooxml-formula="…">` per cell that carries a `<f>`
/// child.  Spec attributes that survive: the formula text, `@t`
/// (normal/array/dataTable/shared), `@si` (shared formula index),
/// `@ref` (array/shared formula range).  The rect is transparent
/// — its purpose is metadata, not visual rendering.
/// §18.4.6 — emit a `<g class="phonetics">` sidecar with one
/// transparent `<rect data-ooxml-phonetic="…">` per shared-string
/// cell whose `<si>` entry declares phonetic-guide (`<rPh>`)
/// runs.  The attribute carries the concatenated furigana so
/// consumers can render ruby text above the base cell value.
fn render_sheet_phonetics(
  cell_map : Map[String, @xml.Element],
  layout : SheetLayout,
  shared_strings : @domain.CT_Sst?,
) -> @xml.Node? {
  let sst = match shared_strings {
    Some(s) => s
    None => return None
  }
  let rects : Array[@xml.Node] = []
  for entry in layout.cells {
    let (cell_ref, cl) = entry
    match cell_map.get(cell_ref) {
      None => ()
      Some(cell_el) =>
        // Only `t="s"` shared-string cells can carry phonetics.
        if attr_value_local(cell_el, "t") == Some("s") {
          match first_child_named_local(cell_el, "v") {
            None => ()
            Some(v) =>
              match
                (try? @strconv.parse_int(
                  xml_text_content(v).trim_space().to_string(),
                )) {
                Ok(idx) =>
                  if idx >= 0 && idx < sst.si_entries.length() {
                    let phon = sst.si_entries[idx].phonetic_text()
                    if phon.length() > 0 {
                      rects.push(
                        svg_elem(
                          "rect",
                          [
                            svg_attr("x", format_d(cl.x)),
                            svg_attr("y", format_d(cl.y)),
                            svg_attr("width", format_d(cl.width)),
                            svg_attr("height", format_d(cl.height)),
                            svg_attr("fill", "transparent"),
                            svg_attr("data-ooxml-cell-ref", cell_ref),
                            svg_attr("data-ooxml-phonetic", phon),
                          ],
                          [],
                        ),
                      )
                    }
                  }
                Err(_) => ()
              }
          }
        }
    }
  }
  if rects.length() == 0 {
    None
  } else {
    Some(svg_elem("g", [svg_attr("class", "phonetics")], rects))
  }
}

///|
fn render_sheet_formulas(
  cell_map : Map[String, @xml.Element],
  layout : SheetLayout,
) -> @xml.Node? {
  let rects : Array[@xml.Node] = []
  for entry in layout.cells {
    let (cell_ref, cl) = entry
    match cell_map.get(cell_ref) {
      None => ()
      Some(cell_el) =>
        match first_child_named_local(cell_el, "f") {
          None => ()
          Some(f_el) => {
            let formula = xml_text_content(f_el)
            let attrs : Array[@xml.Attribute] = [
              svg_attr("x", format_d(cl.x)),
              svg_attr("y", format_d(cl.y)),
              svg_attr("width", format_d(cl.width)),
              svg_attr("height", format_d(cl.height)),
              svg_attr("fill", "transparent"),
              svg_attr("data-ooxml-formula", formula),
              svg_attr("data-ooxml-cell-ref", cell_ref),
            ]
            match attr_value_local(f_el, "t") {
              Some(t) => attrs.push(svg_attr("data-ooxml-f-t", t))
              None => ()
            }
            match attr_value_local(f_el, "si") {
              Some(si) => attrs.push(svg_attr("data-ooxml-f-si", si))
              None => ()
            }
            match attr_value_local(f_el, "ref") {
              Some(r) => attrs.push(svg_attr("data-ooxml-f-ref", r))
              None => ()
            }
            rects.push(svg_elem("rect", attrs, []))
          }
        }
    }
  }
  if rects.length() == 0 {
    None
  } else {
    Some(svg_elem("g", [svg_attr("class", "formulas")], rects))
  }
}

///|
/// §18.3.1.45 — emit a `<g class="hyperlinks">` group with one
/// `<rect data-ooxml-hyperlink-*>` per hyperlinked cell.  The
/// rect spans the cell's grid coordinates so consumers can
/// detect the hit area and rebuild an `<a>` link.  Excel
/// supports a range-based `@ref` (e.g. `A1:B3`); we currently
/// honour the top-left cell only — multi-cell hyperlink coverage
/// is uncommon and tracked separately.
/// §18.3.1.73 / §18.3.1.13 — emit a `<g class="outline-levels">`
/// sidecar containing one transparent rect per row / column that
/// carries `@outlineLevel > 0`.  The rect spans the row/col's
/// grid extent and surfaces `data-ooxml-outline-level` so
/// consumers can render grouping brackets / collapse indicators.
fn render_sheet_outline_levels(
  worksheet : @xml.Element,
  layout : SheetLayout,
) -> @xml.Node? {
  let rects : Array[@xml.Node] = []
  // Rows: walk <sheetData>/<row @outlineLevel>.
  match first_child_named_local(worksheet, "sheetData") {
    None => ()
    Some(sd) =>
      for child in sd.children {
        match child {
          @xml.Element(row) =>
            if row.name.local_name == "row" {
              let lvl = match attr_value_local(row, "outlineLevel") {
                Some(v) =>
                  match (try? @strconv.parse_int(v)) {
                    Ok(n) => n
                    Err(_) => 0
                  }
                None => 0
              }
              if lvl > 0 {
                let r_attr = match attr_value_local(row, "r") {
                  Some(v) =>
                    match (try? @strconv.parse_int(v)) {
                      Ok(n) => n
                      Err(_) => -1
                    }
                  None => -1
                }
                if r_attr > 0 &&
                  r_attr - 1 < layout.row_positions.length() &&
                  r_attr - 1 < layout.row_heights.length() {
                  let y = layout.row_positions[r_attr - 1]
                  let h = layout.row_heights[r_attr - 1]
                  rects.push(
                    svg_elem(
                      "rect",
                      [
                        svg_attr("x", "0"),
                        svg_attr("y", format_d(y)),
                        svg_attr("width", format_d(layout.total_width)),
                        svg_attr("height", format_d(h)),
                        svg_attr("fill", "transparent"),
                        svg_attr("data-ooxml-row", r_attr.to_string()),
                        svg_attr(
                          "data-ooxml-row-outline-level",
                          lvl.to_string(),
                        ),
                      ],
                      [],
                    ),
                  )
                }
              }
            }
          _ => ()
        }
      }
  }
  // Columns: walk <cols>/<col @outlineLevel @min @max>.
  match first_child_named_local(worksheet, "cols") {
    None => ()
    Some(cols) =>
      for child in cols.children {
        match child {
          @xml.Element(col) =>
            if col.name.local_name == "col" {
              let lvl = match attr_value_local(col, "outlineLevel") {
                Some(v) =>
                  match (try? @strconv.parse_int(v)) {
                    Ok(n) => n
                    Err(_) => 0
                  }
                None => 0
              }
              if lvl > 0 {
                let min = match attr_value_local(col, "min") {
                  Some(v) =>
                    match (try? @strconv.parse_int(v)) {
                      Ok(n) => n
                      Err(_) => 0
                    }
                  None => 0
                }
                let max = match attr_value_local(col, "max") {
                  Some(v) =>
                    match (try? @strconv.parse_int(v)) {
                      Ok(n) => n
                      Err(_) => 0
                    }
                  None => 0
                }
                if min > 0 &&
                  max >= min &&
                  min - 1 < layout.column_positions.length() {
                  let x = layout.column_positions[min - 1]
                  let mut w_sum = 0.0
                  let mut col_i = min - 1
                  while col_i < max && col_i < layout.column_widths.length() {
                    w_sum = w_sum + layout.column_widths[col_i]
                    col_i = col_i + 1
                  }
                  rects.push(
                    svg_elem(
                      "rect",
                      [
                        svg_attr("x", format_d(x)),
                        svg_attr("y", "0"),
                        svg_attr("width", format_d(w_sum)),
                        svg_attr("height", format_d(layout.total_height)),
                        svg_attr("fill", "transparent"),
                        svg_attr("data-ooxml-col-min", min.to_string()),
                        svg_attr("data-ooxml-col-max", max.to_string()),
                        svg_attr(
                          "data-ooxml-col-outline-level",
                          lvl.to_string(),
                        ),
                      ],
                      [],
                    ),
                  )
                }
              }
            }
          _ => ()
        }
      }
  }
  if rects.length() == 0 {
    None
  } else {
    Some(svg_elem("g", [svg_attr("class", "outline-levels")], rects))
  }
}

///|
fn render_sheet_hyperlinks(
  worksheet : @xml.Element,
  layout : SheetLayout,
) -> @xml.Node? {
  let hyperlinks_el = first_child_named_local(worksheet, "hyperlinks")
  let parent = match hyperlinks_el {
    Some(h) => h
    None => return None
  }
  let rects : Array[@xml.Node] = []
  for child in parent.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "hyperlink" {
          let ref_ = match attr_value_local(e, "ref") {
            Some(v) => v
            None => continue
          }
          let cell_key = first_cell_of_range(ref_)
          let cell_layout : CellLayout? = lookup_cell_layout(layout, cell_key)
          match cell_layout {
            None => ()
            Some(cl) => {
              // Transparent — this rect's purpose is metadata,
              // not visual.  Consumers wrap or paint it.
              let attrs : Array[@xml.Attribute] = [
                svg_attr("x", format_d(cl.x)),
                svg_attr("y", format_d(cl.y)),
                svg_attr("width", format_d(cl.width)),
                svg_attr("height", format_d(cl.height)),
                svg_attr("fill", "transparent"),
                svg_attr("data-ooxml-hyperlink-ref", ref_),
              ]
              match attr_value_local(e, "id") {
                Some(rid) =>
                  attrs.push(svg_attr("data-ooxml-hyperlink-r-id", rid))
                None => ()
              }
              match attr_value_local(e, "location") {
                Some(loc) =>
                  attrs.push(svg_attr("data-ooxml-hyperlink-location", loc))
                None => ()
              }
              match attr_value_local(e, "tooltip") {
                Some(tip) =>
                  attrs.push(svg_attr("data-ooxml-hyperlink-tooltip", tip))
                None => ()
              }
              match attr_value_local(e, "display") {
                Some(disp) =>
                  attrs.push(svg_attr("data-ooxml-hyperlink-display", disp))
                None => ()
              }
              rects.push(svg_elem("rect", attrs, []))
            }
          }
        }
      _ => ()
    }
  }
  if rects.length() == 0 {
    None
  } else {
    Some(svg_elem("g", [svg_attr("class", "hyperlinks")], rects))
  }
}

///|
/// §18.18.62 ST_Ref — return the single-cell reference at the
/// top-left of a range expression like "A1:B3" or just "A1".
fn first_cell_of_range(ref_ : String) -> String {
  let mut i = 0
  while i < ref_.length() {
    if ref_.code_unit_at(i).to_int() == 0x3A {
      return ref_.substring(start=0, end=i).to_string()
    }
    i = i + 1
  }
  ref_
}

///|
/// Look up a cell's layout by single-cell A1 reference.  Returns
/// None when the cell is outside the layout's range.
fn lookup_cell_layout(layout : SheetLayout, cell_key : String) -> CellLayout? {
  for entry in layout.cells {
    let (key, cl) = entry
    if key == cell_key {
      return Some(cl)
    }
  }
  None
}

///|
/// §18.3.1.65 `<pane>` — extracted CT_Pane metadata.  `None`
/// when no `<sheetView>/<pane>` is present.
struct SheetPaneInfo {
  /// @xSplit (xsd:double, default 0).  Horizontal split position
  /// in column-units (frozen: number of frozen columns; split:
  /// pixel position above the column).
  x_split : Double
  /// @ySplit (xsd:double, default 0).  Vertical split position
  /// in row-units (frozen: number of frozen rows; split: pixel
  /// position above the row).
  y_split : Double
  /// @topLeftCell (ST_CellRef).  First visible cell in the
  /// bottom-right pane after split / freeze.
  top_left_cell : String?
  /// @activePane (ST_Pane).  Default "topLeft".
  active_pane : String?
  /// @state (ST_PaneState).  Default "split"; common values
  /// "frozen" / "split" / "frozenSplit".
  state : String?
}

///|
/// §18.3.1.70 — read the worksheet's `<printOptions>` element
/// and return the boolean print flags as `(key, "1")` pairs.
/// Only flags explicitly set to a true value are returned (an
/// absent / false flag means the default and is not surfaced).
/// Recognised flags: `horizontalCentered`, `verticalCentered`,
/// `headings`, `gridLines`, `gridLinesSet`.
fn sheet_print_options(worksheet : @xml.Element) -> Array[(String, String)] {
  let out : Array[(String, String)] = []
  let print_options = first_child_named_local(worksheet, "printOptions")
  match print_options {
    None => ()
    Some(po) =>
      for
        key in [
          "horizontalCentered", "verticalCentered", "headings", "gridLines", "gridLinesSet",
        ] {
        match attr_value_local(po, key) {
          Some("1") | Some("true") => out.push((key, "1"))
          _ => ()
        }
      }
  }
  out
}

///|
/// §18.3.1.82 — read the worksheet's `<sheetPr>/<tabColor>`
/// element.  Returns the colour as a `#rrggbb` string when the
/// `@rgb` attribute is present (Excel writes `AARRGGBB`, so we
/// drop the leading alpha pair); returns the `theme:N`/`indexed:N`
/// token verbatim for theme / indexed colours so consumers can
/// resolve them.  None when no `<tabColor>` is declared.
fn sheet_tab_color(worksheet : @xml.Element) -> String? {
  let sheet_pr = first_child_named_local(worksheet, "sheetPr")
  let tab_color = match sheet_pr {
    Some(sp) => first_child_named_local(sp, "tabColor")
    None => None
  }
  match tab_color {
    None => None
    Some(tc) =>
      // §18.8.3 CT_Color — @rgb is ARGB 8-hex; @theme + @indexed
      // are integer indices.  Prefer @rgb when present.
      match attr_value_local(tc, "rgb") {
        Some(argb) =>
          if argb.length() == 8 {
            // Drop the leading 2-hex alpha.
            Some("#" + argb.substring(start=2, end=8))
          } else if argb.length() == 6 {
            Some("#" + argb)
          } else {
            Some(argb)
          }
        None =>
          match attr_value_local(tc, "theme") {
            Some(t) => Some("theme:" + t)
            None =>
              match attr_value_local(tc, "indexed") {
                Some(i) => Some("indexed:" + i)
                None => None
              }
          }
      }
  }
}

///|
/// §18.3.1.65 — read the worksheet's `<sheetView>/<pane>` element
/// and return a typed snapshot, or None when absent.
fn sheet_view_pane_info(worksheet : @xml.Element) -> SheetPaneInfo? {
  let sheet_views = first_child_named_local(worksheet, "sheetViews")
  let sheet_view = match sheet_views {
    Some(sv) => first_child_named_local(sv, "sheetView")
    None => None
  }
  let pane = match sheet_view {
    Some(sv) => first_child_named_local(sv, "pane")
    None => None
  }
  match pane {
    None => None
    Some(p) => {
      let x_split = match attr_value_local(p, "xSplit") {
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(n) => n
            Err(_) => 0.0
          }
        None => 0.0
      }
      let y_split = match attr_value_local(p, "ySplit") {
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(n) => n
            Err(_) => 0.0
          }
        None => 0.0
      }
      let top_left_cell = attr_value_local(p, "topLeftCell")
      let active_pane = attr_value_local(p, "activePane")
      let state = attr_value_local(p, "state")
      Some({ x_split, y_split, top_left_cell, active_pane, state })
    }
  }
}

///|
/// §18.3.1.87 — test whether a `<c>` element holds a numeric
/// value of zero.  Used by the `@showZeros="0"` suppression.
/// Considers only `t="n"` cells (or unspecified-t which defaults
/// to numeric per §18.18.11); string/inline/error cells are
/// never suppressed.
fn is_numeric_zero_cell(
  cell : @xml.Element,
  _shared_strings : @domain.CT_Sst?,
) -> Bool {
  let cell_t = attr_value_local(cell, "t").unwrap_or("n")
  if cell_t != "n" {
    return false
  }
  match first_child_named_local(cell, "v") {
    None => false
    Some(v) => {
      let raw = xml_text_content(v).trim_space().to_string()
      match (try? @strconv.parse_double(raw)) {
        Ok(n) => n == 0.0
        Err(_) => false
      }
    }
  }
}

///|
/// §18.8.30 — the numeric value of a cell, used to pick the
/// positive / negative / zero section of a number-format code.
/// Only `t="n"` (numeric) and `t="d"` (date) cells carry a value
/// the format colour can apply to; every other cell type returns
/// `None`.  For `t="d"` the ISO date is converted to its Excel
/// serial so the section selection sees a positive number.
fn cell_numeric_value(
  cell : @xml.Element,
  date_system : @date_serial.DateSystem,
) -> Double? {
  let cell_t = attr_value_local(cell, "t").unwrap_or("n")
  match cell_t {
    "n" =>
      match first_child_named_local(cell, "v") {
        None => None
        Some(v) => {
          let raw = xml_text_content(v).trim_space().to_string()
          match (try? @strconv.parse_double(raw)) {
            Ok(n) => Some(n)
            Err(_) => None
          }
        }
      }
    "d" =>
      match first_child_named_local(cell, "v") {
        None => None
        Some(v) => {
          let raw = xml_text_content(v).trim_space().to_string()
          match parse_iso8601_date(raw) {
            None => None
            Some(dt) =>
              match (try? @date_serial.date_time_to_serial(dt, date_system)) {
                Ok(serial) => Some(serial)
                Err(_) => None
              }
          }
        }
      }
    _ => None
  }
}

///|
/// §18.3.1.87 — `<sheetView @showRowColHeaders>` overrides the
/// renderer's `options.show_row_headers` / `options.show_column_headers`
/// when present.  Returns None when no `<sheetView>` is set so
/// the caller falls back to the renderer default.
fn sheet_view_show_row_col_headers(worksheet : @xml.Element) -> Bool? {
  let sheet_views = first_child_named_local(worksheet, "sheetViews")
  let sheet_view = match sheet_views {
    Some(sv) => first_child_named_local(sv, "sheetView")
    None => None
  }
  match sheet_view {
    None => None
    Some(sv) =>
      match attr_value_local(sv, "showRowColHeaders") {
        Some("0") => Some(false)
        Some("false") => Some(false)
        Some("1") => Some(true)
        Some("true") => Some(true)
        Some(_) => None
        None => None
      }
  }
}

///|
/// §18.3.1.87 — `<sheetView @showZeros>` (default true).  When
/// false, numeric cells with value 0 MUST render as blank.
fn sheet_view_show_zeros(worksheet : @xml.Element) -> Bool? {
  let sheet_views = first_child_named_local(worksheet, "sheetViews")
  let sheet_view = match sheet_views {
    Some(sv) => first_child_named_local(sv, "sheetView")
    None => None
  }
  match sheet_view {
    None => None
    Some(sv) =>
      match attr_value_local(sv, "showZeros") {
        Some("0") => Some(false)
        Some("false") => Some(false)
        Some("1") => Some(true)
        Some("true") => Some(true)
        Some(_) => None
        None => None
      }
  }
}

///|
fn sheet_view_show_grid_lines(worksheet : @xml.Element) -> Bool? {
  let sheet_views = first_child_named_local(worksheet, "sheetViews")
  let sheet_view = match sheet_views {
    Some(sv) => first_child_named_local(sv, "sheetView")
    None => None
  }
  match sheet_view {
    None => None
    Some(sv) =>
      match attr_value_local(sv, "showGridLines") {
        Some("0") => Some(false)
        Some("false") => Some(false)
        Some("1") => Some(true)
        Some("true") => Some(true)
        // Schema violation — value outside xsd:boolean.
        Some(_) => None
        None => None
      }
  }
}

///|
/// Placeholder rect + centred label used when the EG_ObjectChoices
/// arm has no specialised renderer.  The `label` (drawn as text
/// in the centre of the rect) is also emitted as
/// `data-ooxml-graphic-type` on the surrounding `<g>` so
/// consumers can detect §21.2 chart frames, §21.4 SmartArt
/// frames, etc. and apply their own rendering downstream.
fn drawing_placeholder_inner(
  bounds : DrawingBounds,
  label : String,
) -> Array[@xml.Node] {
  [
    svg_elem(
      "rect",
      [
        svg_attr("x", "0"),
        svg_attr("y", "0"),
        svg_attr("width", format_d(bounds.width)),
        svg_attr("height", format_d(bounds.height)),
        svg_attr("fill", "#f0f0f0"),
        svg_attr("stroke", "#cccccc"),
        svg_attr("data-ooxml-graphic-type", label),
      ],
      [],
    ),
    svg_elem(
      "text",
      [
        svg_attr("x", format_d(bounds.width / 2.0)),
        svg_attr("y", format_d(bounds.height / 2.0)),
        svg_attr("text-anchor", "middle"),
        svg_attr("dominant-baseline", "middle"),
        svg_attr("font-size", "10"),
        svg_attr("fill", "#999999"),
      ],
      [svg_text("[" + label + "]")],
    ),
  ]
}

///|
/// Pixel bounds for a drawing anchor. Mirrors web-pptx
/// `DrawingBounds` in drawing-layout.ts.
struct DrawingBounds {
  x : Double
  y : Double
  width : Double
  height : Double
}

///|
/// Dispatch on the EG_Anchor sum to compute pixel bounds. Each arm
/// reuses the sheet column / row positions so cell-anchored drawings
/// align with the existing grid.
fn drawing_bounds_for(
  anchor : @drawing.EG_Anchor,
  layout : SheetLayout,
) -> DrawingBounds {
  match anchor {
    TwoCellAnchor(a) => {
      let f = marker_position(a.from, layout)
      let t = marker_position(a.to, layout)
      let w = t.0 - f.0
      let h = t.1 - f.1
      {
        x: f.0,
        y: f.1,
        width: if w > 0.0 {
          w
        } else {
          0.0
        },
        height: if h > 0.0 {
          h
        } else {
          0.0
        },
      }
    }
    OneCellAnchor(a) => {
      let f = marker_position(a.from, layout)
      let w = emu_to_pixels(positive_size_emu(a.ext.cx))
      let h = emu_to_pixels(positive_size_emu(a.ext.cy))
      { x: f.0, y: f.1, width: w, height: h }
    }
    AbsoluteAnchor(a) => {
      let x = emu_to_pixels(coordinate_emu(a.pos.x))
      let y = emu_to_pixels(coordinate_emu(a.pos.y))
      let w = emu_to_pixels(positive_size_emu(a.ext.cx))
      let h = emu_to_pixels(positive_size_emu(a.ext.cy))
      { x, y, width: w, height: h }
    }
  }
}

///|
/// Convert a `<xdr:from>` / `<xdr:to>` marker to a (px x, px y)
/// position by indexing the column / row positions arrays from the
/// sheet layout and adding the offset components.
fn marker_position(
  marker : @drawing.CT_Marker,
  layout : SheetLayout,
) -> (Double, Double) {
  let col = parse_int_or(marker.col, 0)
  let row = parse_int_or(marker.row, 0)
  let col_off = parse_double_or(marker.col_off, 0.0)
  let row_off = parse_double_or(marker.row_off, 0.0)
  let col_x = if col < layout.column_positions.length() {
    layout.column_positions[col]
  } else {
    layout.total_width
  }
  let row_y = if row < layout.row_positions.length() {
    layout.row_positions[row]
  } else {
    layout.total_height
  }
  (col_x + emu_to_pixels(col_off), row_y + emu_to_pixels(row_off))
}

///|
/// Resolve a label + the EG_ObjectChoices arm carried by an
/// EG_Anchor so the caller can route to specialised rendering.
fn drawing_choice_info(
  anchor : @drawing.EG_Anchor,
) -> (String, @drawing.EG_ObjectChoices) {
  let choice = match anchor {
    TwoCellAnchor(a) => a.object_choice
    OneCellAnchor(a) => a.object_choice
    AbsoluteAnchor(a) => a.object_choice
  }
  let label = match choice {
    Sp(_) => "Shape"
    GrpSp(_) => "Group"
    GraphicFrame(gf) => graphic_frame_uri_label(gf)
    CxnSp(_) => "Connector"
    Pic(_) => "Picture"
    ContentPart(_) => "ContentPart"
  }
  (label, choice)
}

///|
/// Inspect `<a:graphic>/<a:graphicData @uri>` and pick a human label
/// per the well-known URIs (chart / table / diagram / OLE). Mirrors
/// web-pptx's renderGraphicFrameSvg dispatch but only surfaces the
/// label since the typed renderers live elsewhere.
/// §15.2 — exact-match the well-known graphicData URIs the OOXML
/// registry defines. Substring matching admits false positives
/// (e.g. a future URI containing "chart" that is not a DrawingML
/// chart). Unknown URIs fall through to the spec-anchored
/// "GraphicFrame" sentinel; consumers wanting fine-grained
/// handling read the raw URI off the `<a:graphicData>` element.
fn graphic_frame_uri_label(gf : @drawing.CT_GraphicalObjectFrame) -> String {
  let graphic_data = match first_child_named_local(gf.element, "graphic") {
    None => return "GraphicFrame"
    Some(g) =>
      match first_child_named_local(g, "graphicData") {
        None => return "GraphicFrame"
        Some(gd) => gd
      }
  }
  match attr_value_local(graphic_data, "uri") {
    None => "GraphicFrame"
    Some(uri) =>
      match uri {
        "http://schemas.openxmlformats.org/drawingml/2006/chart" => "Chart"
        "http://schemas.openxmlformats.org/drawingml/2006/table" => "Table"
        "http://schemas.openxmlformats.org/drawingml/2006/diagram" => "Diagram"
        "http://schemas.openxmlformats.org/presentationml/2006/ole" =>
          "OLE Object"
        "http://schemas.openxmlformats.org/drawingml/2006/lockedCanvas" =>
          "LockedCanvas"
        "http://www.w3.org/2003/InkML" => "Ink"
        _ => "GraphicFrame"
      }
  }
}

///|
fn parse_double_or(text : String, fallback : Double) -> Double {
  match (try? @strconv.parse_double(text)) {
    Ok(d) => d
    Err(_) => fallback
  }
}

///|
/// Convert a typed ST_Coordinate to its EMU magnitude (as Double).
/// EMU branch returns the long value directly; universal-measure
/// branch falls back to the lexical form parsed through `parse_double_or`.
fn coordinate_emu(coord : @a.ST_Coordinate) -> Double {
  parse_double_or(coord.to_string(), 0.0)
}

///|
/// Convert a typed ST_PositiveCoordinate to its EMU magnitude as Double.
fn positive_size_emu(coord : @a.ST_PositiveCoordinate) -> Double {
  parse_double_or(coord.to_string(), 0.0)
}

///|
fn parse_int_or(text : String, fallback : Int) -> Int {
  match (try? @strconv.parse_int(text)) {
    Ok(n) => n
    Err(_) => fallback
  }
}
