// @source web-pptx packages/@aurochs-renderer/docx/src/svg/document-render.ts
// @source web-pptx packages/@aurochs-renderer/docx/src/svg/page-render.ts
// @source web-pptx packages/@aurochs-office/text-layout/src/layout/engine.ts
// @source web-pptx packages/@aurochs-office/text-layout/src/layout/page-flow.ts
// @source web-pptx packages/@aurochs-office/text-layout/src/layout/table-layout.ts
//
// WordprocessingML §17 SVG renderer.  Walks a CT_Document tree,
// flows paragraphs and tables into pages using <w:sectPr> page
// configuration, and emits one <svg> per page.  Unit conversions
// follow §17.6 / §17.18.78 ST_TwipsMeasure (twips → px via px =
// twips / 20 * 96 / 72 = twips / 15).

///|
/// SVG render result for one page.
/// @source web-pptx page-render.ts:18-25 (PageRenderResult)
pub struct PageRenderResult {
  /// Complete <svg> document for this page.
  svg : String
  /// Page width in pixels (after twips→px conversion).
  width : Double
  /// Page height in pixels (after twips→px conversion).
  height : Double
}

///|
/// SVG render result for a whole document.
/// @source web-pptx svg/types.ts:19-26 (DocumentSvgResult)
pub struct DocumentSvgResult {
  /// One rendered page per element.
  pages : Array[PageRenderResult]
  /// Number of pages.
  total_pages : Int
  /// Diagnostic warnings emitted during rendering.
  warnings : Array[String]
}

///|
/// Resolved image payload for §20.4.2 inline / anchored DrawingML
/// pictures inside `<w:drawing>`. The viewer asks an external
/// `image_resolver` closure to translate the `r:embed` (or `r:link`)
/// relationship Id into a (mime_type, base64_data) tuple.
pub(all) struct ResolvedImage {
  mime_type : String
  base64_data : String
}

// =============================================================================
// Constants and Defaults
// =============================================================================

///|
/// Twips → pixel ratio: 1 twip = 1/20 pt, 1 pt = 96/72 px (96 DPI).
/// 1 / 20 * 96 / 72 = 1/15.  @source ecma376-defaults.ts (twipsToPx).
const TWIPS_TO_PX : Double = 1.0 / 15.0

///|
/// ECMA-376 §17.6.13 default page width — US Letter, 8.5in = 12240 twips.
const DEFAULT_PAGE_WIDTH_TWIPS : Double = 12240.0

///|
/// ECMA-376 §17.6.13 default page height — US Letter, 11in = 15840 twips.
const DEFAULT_PAGE_HEIGHT_TWIPS : Double = 15840.0

///|
/// ECMA-376 §17.6.11 default page margin — 1 inch = 1440 twips.
const DEFAULT_MARGIN_TWIPS : Double = 1440.0

///|
/// §17.3.1.29 sz — ECMA-376 does not mandate a numeric default for
/// `<w:sz>`; the typical value supplied by `<w:docDefaults>` is
/// `<w:sz w:val="20"/>` (10 pt, half-point unit). Used only as the
/// last-resort fallback when neither docDefaults nor a style chain
/// supplies a size; the value is spec-undefined and chosen as the
/// commonly cited Annex L example value.
const DEFAULT_FONT_SIZE_PT : Double = 10.0

///|
/// §17.3.2.26 rFonts — ECMA-376 does not mandate a default typeface;
/// the cascade should resolve via `<w:docDefaults>` first. When no
/// font information is reachable we fall back to the SVG / CSS
/// generic `serif` family so the consumer can substitute their own
/// face. The previous `"Calibri"` was a Word-specific UX choice
/// with no spec basis.
const DEFAULT_FONT_FAMILY : String = "serif"

///|
/// §17.3.1.33 / §17.4 — ECMA-376 has no implicit gap between a
/// table block and the following block; paragraph and table
/// spacing are fully specified by `<w:spacing>` and `<w:tblPr>`
/// respectively. Inserting an extra literal gap has no spec basis
/// and would mis-position content.
const BLOCK_GAP_PX : Double = 0.0

///|
/// §17.4.42 tblCellMar / §17.4.69 tcMar — spec leaves the cell
/// margin default to the implementation. The conventional Word
/// default (and the value the spec's Annex L examples assume) is
/// 0.08" = 115 twips ≈ 7.68 px on left/right; top/bottom default
/// to 0. We use a single 5 px legacy default here as a final
/// fallback when neither `<w:tblCellMar>` nor `<w:tcMar>` is
/// declared; the proper per-side cascade is wired below in
/// `resolve_table_cell_margins` / `resolve_cell_margins`.
const DEFAULT_CELL_PADDING_PX : Double = 5.0

// =============================================================================
// Internal Layout Types (mirrors @aurochs-office/text-layout result types)
// =============================================================================

///|
/// Page configuration in pixels.  @source page-flow.ts:50-81 (PageFlowConfig).
priv struct PageConfig {
  page_width : Double
  page_height : Double
  margin_top : Double
  margin_bottom : Double
  margin_left : Double
  margin_right : Double
  /// §17.6.10 `<w:pgBorders>` — page-level borders attached to the
  /// section. Each slot defaults to `BorderSide::none()`; populated
  /// when the section declares an explicit border on that side.
  page_border_top : BorderSide
  page_border_left : BorderSide
  page_border_bottom : BorderSide
  page_border_right : BorderSide
  /// §17.2.1 `<w:document>/<w:background w:color="…">` document
  /// background colour. `"#rrggbb"` when present, `"#ffffff"` when
  /// the element is absent so the legacy white rect is preserved.
  page_background : String
  /// §17.6.4 `<w:cols>` — number of columns in the section's flow.
  /// 1 when absent (single-column default).
  cols_num : Int
  /// §17.6.4 `<w:cols @space>` — twip distance between columns.
  /// 0.0 when absent.
  cols_space : Double
  /// §17.6.4 `<w:cols @sep>` — whether to draw a vertical separator
  /// line between columns.
  cols_sep : Bool
  /// §17.6.3 `<w:col>` — explicit per-column geometry used when the
  /// section declares `<w:cols w:equalWidth="0">` with individual
  /// `<w:col w:w w:space>` children. Each pair is
  /// `(width_px, trailing_space_px)`. Empty when the columns are
  /// equal-width (the common case), in which case the geometry is
  /// derived from `cols_num` / `cols_space`.
  cols_explicit : Array[(Double, Double)]
}

///|
/// §17.10 page decoration — the header / footer block streams for a
/// section, split by the three §17.10.1 reference types (`default`,
/// `first`, `even`) plus the two toggles that select between them.
///
/// `headers_for` / `footers_for` resolve the correct stream for a
/// given 0-based page index, applying the ECMA-376 §17.10.1 cascade:
///   - page 1 (`titlePg` set)            → `first`, else `default`
///   - even-numbered page (`evenOdd` set) → `even`, else `default`
///   - otherwise                          → `default`
priv struct PageDecoration {
  header_default : Array[@xml.Element]
  header_first : Array[@xml.Element]
  header_even : Array[@xml.Element]
  footer_default : Array[@xml.Element]
  footer_first : Array[@xml.Element]
  footer_even : Array[@xml.Element]
  /// §17.6.6 `<w:titlePg>` — the section has a distinct first-page
  /// header / footer.
  title_pg : Bool
  /// §17.10.1 `<w:evenAndOddHeaders>` (document setting) — odd and
  /// even pages carry distinct headers / footers.
  even_and_odd : Bool
}

///|
/// An empty decoration set — the renderer draws no header / footer.
fn PageDecoration::empty() -> PageDecoration {
  {
    header_default: [],
    header_first: [],
    header_even: [],
    footer_default: [],
    footer_first: [],
    footer_even: [],
    title_pg: false,
    even_and_odd: false,
  }
}

///|
/// §17.10.1 — the header block stream for the 0-based `page_index`.
/// `first` / `even` fall back to `default` when the section declares
/// no part of that type.
fn PageDecoration::headers_for(
  self : PageDecoration,
  page_index : Int,
) -> Array[@xml.Element] {
  if self.title_pg && page_index == 0 {
    if self.header_first.length() > 0 {
      return self.header_first
    }
    return self.header_default
  }
  // A 0-based index of 1, 3, 5… is a 1-based even page (2, 4, 6…).
  if self.even_and_odd && page_index % 2 == 1 {
    if self.header_even.length() > 0 {
      return self.header_even
    }
    return self.header_default
  }
  self.header_default
}

///|
/// §17.10.1 — the footer block stream for the 0-based `page_index`.
fn PageDecoration::footers_for(
  self : PageDecoration,
  page_index : Int,
) -> Array[@xml.Element] {
  if self.title_pg && page_index == 0 {
    if self.footer_first.length() > 0 {
      return self.footer_first
    }
    return self.footer_default
  }
  if self.even_and_odd && page_index % 2 == 1 {
    if self.footer_even.length() > 0 {
      return self.footer_even
    }
    return self.footer_default
  }
  self.footer_default
}

///|
/// One measured text run within a paragraph.
priv struct RunSpan {
  text : String
  font_family : String
  font_size_pt : Double
  bold : Bool
  italic : Bool
  underline : Bool
  /// §17.18.99 ST_Underline — the original `@val` (`single` /
  /// `double` / `dotted` / `dashed` / `wave` / `dottedHeavy` /
  /// `dottedDouble` / `thick` / `dashLong` / `wavyHeavy` /
  /// `wavyDouble` / `dashedHeavy` / `dashLongHeavy` / `dashDot` /
  /// `dashDotHeavy` / `dashDotDotHeavy` / `words` / `none`).
  /// Empty when `<w:u>` is absent. Preserved so the emitter can
  /// surface the spec value via `data-ooxml-u` metadata even when
  /// the SVG output only renders a single underline line.
  underline_style : String
  strike : Bool
  /// "#rrggbb" or empty (default #000000 at render time).
  color : String
  /// Highlight color name (Word w:highlight @val) or empty.
  highlight : String
  /// Measured text width in px at the given font size.
  width_px : Double
  /// §20.4.2 inline DrawingML picture payload — when present the
  /// renderer emits an `<image>` element occupying `(width_px,
  /// image_height_px)` at the span's baseline rather than text.
  /// `None` for plain text runs.
  inline_image : InlineImage?
  /// §17.3.2.42 `<w:vertAlign w:val="…">`. "baseline" (default) keeps
  /// the glyph on the line baseline; "superscript" lifts it;
  /// "subscript" drops it. The emitter scales the font down and
  /// offsets the baseline accordingly.
  vertical_align : String
  /// §17.3.2.36 `<w:rPr><w:spacing w:val="…">`. Additional inter-
  /// character spacing in CSS pixels (already converted from
  /// twentieths-of-a-point on read). The emitter sets `letter-
  /// spacing="…px"` and the measurer reserves the corresponding
  /// width per glyph.
  letter_spacing_px : Double
  /// §17.3.2.13 `<w:caps>` — all-caps. Renders as CSS
  /// `text-transform: uppercase` on the `<text>` element.
  caps : Bool
  /// §17.3.2.33 `<w:smallCaps>` — small-caps variant. Renders as
  /// CSS `font-variant: small-caps`.
  small_caps : Bool
  /// §17.3.2.4 `<w:bdr>` — run-level border. The renderer draws a
  /// single rectangle around the run's glyph bbox (single-line only
  /// for now) when the border style is not `none`. Defaults to
  /// `BorderSide::none()` so plain runs stay unaffected.
  border : BorderSide
  /// §17.3.2.30 `<w:rtl>` — right-to-left run direction. When `true`
  /// the emitter sets `direction="rtl" unicode-bidi="bidi-override"`
  /// on the `<text>` element so RTL text flows right-aligned.
  rtl : Bool
  /// §17.3.2.23 `<w:outline>` — text outline toggle. When `true` the
  /// glyphs render with a stroke (default 1 px in the run's colour
  /// or `#000000`) painted before the fill.
  outline : Bool
  /// §17.3.2.31 `<w:shadow>` — text drop shadow toggle. When `true`
  /// the emitter sets a CSS `text-shadow` rule on the `<text>`.
  shadow : Bool
  /// §17.3.2.18 `<w:emboss>` — embossed (raised) text toggle.
  /// Rendered as a light-then-dark CSS text-shadow pair so the
  /// glyphs appear lifted off the page.
  emboss : Bool
  /// §17.3.2.21 `<w:imprint>` — imprinted / engraved (sunken)
  /// text toggle.  Rendered as a dark-then-light text-shadow.
  imprint : Bool
  /// §17.3.2.12 `<w:em>` — emphasis-mark style ("none" / "dot" /
  /// "comma" / "circle" / "underDot"). Emitted as CSS
  /// `text-emphasis-style: <kind>` on the `<text>` element. Empty
  /// string suppresses emission.
  emphasis : String
  /// §17.3.2.24 `<w:position w:val="…">` — vertical baseline offset
  /// in CSS pixels (positive = raised). 0 leaves the glyph on the
  /// natural baseline. Computed from twentieths-of-a-half-point on
  /// read.
  position_offset_px : Double
  /// §17.3.2.46 `<w:w w:val="…">` — character-width percentage. 100
  /// (the default) keeps glyphs at natural width; values below
  /// compress, above expand. The emitter applies `transform:
  /// scaleX(<pct>)` to the `<text>` element.
  scale_pct : Double
  /// §17.3.2.20 `<w:kern w:val="…">` — the minimum font size (in
  /// half-points) at which automatic kerning is enabled.  0 means
  /// kerning is off.  Surfaced as `data-ooxml-kern` and used to
  /// gate the SVG `kerning`/`text-rendering` hint.
  kern_half_points : Double
  /// §17.3.2.20 `<w:lang w:val="…">` — the run's natural-language
  /// tag (BCP 47, e.g. `en-US` / `ja-JP`).  Empty when no `<w:lang>`
  /// is declared.  Surfaced as `xml:lang` + `data-ooxml-lang` so
  /// locale-sensitive consumers (digit shaping, line breaking,
  /// hyphenation) can act on it.
  lang : String
  /// §17.18.87 ST_TabJc `bar` — set on a `\t` tab span whose
  /// resolved justification is `bar`.  The emitter draws a thin
  /// vertical line at the span's x position instead of advancing
  /// the text cursor (the span carries zero width).
  bar_tab : Bool
}

///|
/// Inline DML picture payload captured during span collection.
/// `href` is a data URI when the image_resolver returns a
/// `ResolvedImage`; otherwise the span reserves space but emits
/// nothing visible (matches `xMidYMid meet` behaviour of skipping).
priv struct InlineImage {
  href : String
  width_px : Double
  height_px : Double
  alt_text : String
  /// §20.4.2.3 — `<wp:anchor>` wrapping mode: one of "Square",
  /// "Tight", "None", "TopAndBottom", "Through", "BehindDoc",
  /// "FrontDoc".  Empty for `<wp:inline>`.
  wrap_mode : String
  /// §20.4.2.3 — `<wp:anchor @behindDoc>` toggles when the image
  /// sits behind the text flow (z-order).
  behind_doc : Bool
  /// §20.4.2.3 — `<wp:positionH @relativeFrom>` and
  /// `<wp:positionV @relativeFrom>` anchor references.  Empty for
  /// inline images.
  position_h_relative : String
  position_v_relative : String
}

///|
/// Resolved paragraph properties for layout.
priv struct ParaProps {
  alignment : String // "left" | "center" | "right" | "justify"
  margin_left : Double
  margin_right : Double
  indent : Double
  space_before : Double
  space_after : Double
  /// §17.3.1.38 `<w:tabs>` tab-stop positions in CSS pixels relative
  /// to the paragraph's content origin (after `margin_left`). Sorted
  /// ascending so the cursor can advance to the next eligible stop
  /// in a single sweep. Empty when the paragraph declares no custom
  /// tabs (the renderer then falls back to a default 0.5-inch grid).
  tab_stops : Array[(Double, String)]
  /// §17.3.1.6 `<w:shd @fill>` paragraph shading. `"#rrggbb"` when a
  /// `@fill` hex literal is present; empty string otherwise. Empty
  /// suppresses the background rect emission entirely.
  background : String
  /// §17.3.1.7 `<w:pBdr>` paragraph borders. Each slot defaults to
  /// `BorderSide::none()` so paragraphs without explicit borders
  /// render their content without an outer frame.
  border_top : BorderSide
  border_left : BorderSide
  border_bottom : BorderSide
  border_right : BorderSide
  /// §17.3.1.33 `<w:spacing w:line w:lineRule>` — line height.
  /// `LineHeightAuto(factor)` → multiplier (1.0 == single-line, 1.5
  /// == one-and-a-half, 2.0 == double), `LineHeightExact(px)` →
  /// fixed CSS-pixel line height (lineRule="exact" / "atLeast"),
  /// `LineHeightDefault` → preserve the legacy 1.2 factor that
  /// matches Word's default leading.
  line_height : LineHeightSpec
  /// §17.3.1.9 `<w:contextualSpacing>` — when `true`, the
  /// before / after spacing is suppressed between this paragraph
  /// and an adjacent paragraph of the SAME style.  Honoured by
  /// `collect_blocks` when it compares consecutive paragraphs.
  contextual_spacing : Bool
  /// §17.3.1.27 `<w:pStyle w:val>` — the paragraph style id.
  /// Empty when no explicit style.  Used by the contextual-
  /// spacing comparison.
  p_style : String
  /// §17.3.1.5 `<w:pageBreakBefore>` — start a new page before this
  /// paragraph. Honoured by `flow_into_pages`.
  page_break_before : Bool
}

///|
/// §17.3.1.33 line-height resolution kinds. Keeps the enum closed so
/// the layout pass can dispatch on it without surprises.
priv enum LineHeightSpec {
  LineHeightDefault
  LineHeightAuto(Double)
  LineHeightExact(Double)
} derive(Eq, Debug)

///|
/// One laid-out paragraph: a stack of lines, each with a y-baseline.
priv struct LaidParagraph {
  lines : Array[LaidLine]
  /// Total vertical extent (including space_before/space_after).
  height : Double
  /// §17.3.1.6 paragraph background colour (`"#rrggbb"`), empty for
  /// transparent. Preserved on the laid paragraph so renderers can
  /// emit a background rect even after page flow translates the
  /// paragraph's y position.
  background : String
  /// §17.3.1.7 `<w:pBdr>` paragraph borders carried through page
  /// flow so the emitter can draw them at absolute coordinates.
  border_top : BorderSide
  border_left : BorderSide
  border_bottom : BorderSide
  border_right : BorderSide
  /// §17.3.1.5 `<w:pageBreakBefore>` — when true the page flow
  /// closes the current page before this paragraph and emits it on
  /// a fresh page.
  page_break_before : Bool
  /// §17.3.3.1 `<w:r><w:br w:type="page"/>` — when any run inside
  /// the paragraph carries an explicit page break, the renderer
  /// closes the current page after emitting this paragraph. The
  /// first-iteration semantics keep the whole paragraph on its
  /// originating page (no split) and start a fresh page for the
  /// next block.
  page_break_after : Bool
  /// §17.3.3.1 `<w:r><w:br w:type="column"/>` — when any run inside
  /// the paragraph carries an explicit column break, the page flow
  /// closes the current column after emitting this paragraph and
  /// continues the stream in the next column (or, past the last
  /// column, on a fresh page). Honoured only when the section
  /// declares `<w:cols w:num>` greater than 1; otherwise inert.
  column_break_after : Bool
  /// §17.3.1.9 `<w:contextualSpacing>` toggle, carried so the
  /// block collector can suppress inter-paragraph spacing.
  contextual_spacing : Bool
  /// §17.3.1.27 `<w:pStyle>` id, for the contextual-spacing
  /// same-style comparison.
  p_style : String
  /// §17.3.1.33 — the paragraph's resolved before / after
  /// spacing in CSS pixels, retained so the block collector can
  /// recompute `height` when contextual spacing applies.
  space_before : Double
  space_after : Double
}

///|
/// One laid-out line of a paragraph.
priv struct LaidLine {
  spans : Array[RunSpan]
  /// Top-left x of the line (px relative to page top-left).
  x : Double
  /// Top-y of the line.
  y_top : Double
  /// Baseline y (px).
  y_baseline : Double
  /// Total line height (used for stacking).
  height : Double
  /// Width of all glyphs on this line (used for alignment).
  width : Double
}

///|
/// Block emitted into the document flow.  Either a paragraph or a table.
priv enum FlowBlock {
  ParaBlock(LaidParagraph)
  TableBlock(LaidTable)
}

///|
/// Laid-out table.
priv struct LaidTable {
  x : Double
  width : Double
  /// Total height (sum of row heights).
  height : Double
  rows : Array[LaidTableRow]
}

///|
/// Laid-out table row.
priv struct LaidTableRow {
  height : Double
  cells : Array[LaidTableCell]
}

///|
/// Laid-out table cell.
priv struct LaidTableCell {
  /// Cell left-edge x within the table.
  x : Double
  /// Cell width.
  width : Double
  /// Cell height.
  height : Double
  /// Cell-local paragraphs (positioned in cell-relative coordinates).
  paragraphs : Array[LaidParagraph]
  /// Cell background color (#rrggbb) or empty for transparent.
  background : String
  /// §17.4.59 `<w:tcBorders>` per-side borders. The four slots are
  /// independent — `BorderSide::none()` falls back to the legacy
  /// 1px gray box so plain tables keep the same appearance.
  border_top : BorderSide
  border_left : BorderSide
  border_bottom : BorderSide
  border_right : BorderSide
  /// §17.4.42 tblCellMar / §17.4.69 tcMar — per-cell padding in
  /// pixels, derived from the table-level tblCellMar overlaid by
  /// any cell-level tcMar.
  padding : CellMargins
  /// §17.4.83 `<w:tcPr>/<w:vAlign w:val="top|center|bottom">` —
  /// vertical anchor of the cell content.  "top" (default) means
  /// paragraphs start at `padding.top`; "center" / "bottom" shift
  /// the content stack so its bottom edge lands on the matching
  /// anchor line.
  v_align : String
}

///|
/// Single side of a `<w:tcBorders>` block. `width_px` is the EMU /
/// twips-derived stroke width in CSS pixels; `color_hex` carries the
/// `#rrggbb` literal (`#999999` is the fallback when `@color` is
/// `auto`); `style` mirrors the §17.18.3 ST_Border lexical value
/// ("single", "double", "dotted", "dashed", "none"). When `style ==
/// "none"` the renderer skips this side entirely.
priv struct BorderSide {
  width_px : Double
  color_hex : String
  style : String
}

///|
fn BorderSide::none() -> BorderSide {
  { width_px: 0.0, color_hex: "", style: "none" }
}

///|
/// §17.4.40 tblBorders — when no `<w:tblBorders>` and no
/// `<w:tcBorders>` are declared, the spec mandates NO border.
/// `BorderSide::default_legacy` is kept as an alias of
/// `BorderSide::none` for spec compliance; the previous 1px gray
/// "legacy frame" had no ECMA-376 basis and has been removed.
fn BorderSide::default_legacy() -> BorderSide {
  BorderSide::none()
}

///|
/// §17.4.42 tblCellMar / §17.4.69 tcMar — per-side cell-margin
/// values in pixels, derived from `<w:top>`, `<w:start>` (alias for
/// `<w:left>`), `<w:bottom>`, `<w:end>` (alias for `<w:right>`).
/// `top` and `bottom` default to 0 per Word convention; `left` and
/// `right` default to `DEFAULT_CELL_PADDING_PX` so unspecified
/// margins still produce visible separation.
struct CellMargins {
  top : Double
  left : Double
  bottom : Double
  right : Double
}

///|
/// §17.4.42 — default fallback margins used when neither
/// `<w:tblCellMar>` nor `<w:tcMar>` declare a side.
fn CellMargins::default_() -> CellMargins {
  {
    top: 0.0,
    left: DEFAULT_CELL_PADDING_PX,
    bottom: 0.0,
    right: DEFAULT_CELL_PADDING_PX,
  }
}

///|
/// §17.4.42 / §17.4.69 — read a `<w:tblCellMar>` or `<w:tcMar>`
/// element's per-side `<w:top|left|start|bottom|right|end w:w="…"
/// w:type="dxa">` children and overlay them onto `base`. dxa values
/// are twips (1/20 pt); `auto` and unsupported types are ignored.
fn overlay_cell_margins(base : CellMargins, mar : @xml.Element) -> CellMargins {
  let read_side = fn(child_name : String, fallback : Double) -> Double {
    match first_child_named(mar, child_name) {
      None => fallback
      Some(el) => {
        // §17.18.84 ST_TblWidth — exactly 4 values:
        //   nil  : the width is not specified — keep the fallback.
        //   pct  : value is a percentage in 50ths of a percent;
        //          we cannot resolve without the container width,
        //          so keep the fallback.
        //   dxa  : value is in twentieths of a point (twips); the
        //          only form we honour at the pixel level.
        //   auto : table determines the width from content; keep
        //          the fallback so layout proceeds.
        let w_type = match attr_value(el, "type") {
          Some("nil") => "nil"
          Some("pct") => "pct"
          Some("dxa") => "dxa"
          Some("auto") => "auto"
          // Schema violation — unknown ST_TblWidth.  Default to
          // "dxa" per the spec table.
          Some(_) => "dxa"
          None => "dxa"
        }
        if w_type != "dxa" {
          return fallback
        }
        let w = parse_double_attr(el, "w", -1.0)
        if w < 0.0 {
          fallback
        } else {
          w * TWIPS_TO_PX
        }
      }
    }
  }
  // §17.4.42 start/end are the bidi-aware aliases for left/right
  // (introduced in the 2nd-edition spec).
  let left = read_side("left", read_side("start", base.left))
  let right = read_side("right", read_side("end", base.right))
  let top = read_side("top", base.top)
  let bottom = read_side("bottom", base.bottom)
  { top, left, bottom, right }
}

///|
/// §17.4.42 tblCellMar — read the table-level cell margins from a
/// `<w:tblPr>` element. Falls back to `CellMargins::default_()`.
fn resolve_table_cell_margins(tbl_pr : @xml.Element?) -> CellMargins {
  let base = CellMargins::default_()
  match tbl_pr {
    None => base
    Some(pr) =>
      match first_child_named(pr, "tblCellMar") {
        None => base
        Some(mar) => overlay_cell_margins(base, mar)
      }
  }
}

///|
/// §17.4.69 tcMar — overlay per-cell margins from `<w:tcPr><w:tcMar>`
/// onto the table-level base.
fn resolve_cell_margins(
  tbl_base : CellMargins,
  tc_pr : @xml.Element?,
) -> CellMargins {
  match tc_pr {
    None => tbl_base
    Some(pr) =>
      match first_child_named(pr, "tcMar") {
        None => tbl_base
        Some(mar) => overlay_cell_margins(tbl_base, mar)
      }
  }
}

///|
/// One assembled page: blocks already positioned with absolute y on this
/// page (page-relative, starting at margin_top).
priv struct AssembledPage {
  /// Paragraph blocks with absolute coordinates on this page.
  paragraphs : Array[LaidParagraph]
  /// Table blocks with absolute coordinates on this page.
  tables : Array[LaidTable]
}

// =============================================================================
// Public API
// =============================================================================

///|
/// Render a WordprocessingML CT_Document tree to SVG.
///
/// Walks <w:body> for <w:p> paragraphs and <w:tbl> tables, flows them
/// into pages using <w:sectPr> page margins, and emits one <svg> per
/// page.
///
/// Per ECMA-376 §17.6 (sectPr / pgSz / pgMar): page size and margins
/// come from the section's <w:pgSz> and <w:pgMar> attrs in twentieths
/// of a point.  Convert to pixels via:
///   px = (twips / 20) * 96 / 72  (= twips / 15)
///
/// @source web-pptx document-render.ts:199 (renderDocumentToSvg)
///
/// `header_blocks` / `footer_blocks` carry the §17.10 CT_HdrFtr
/// block-level children (typically `<w:p>` paragraphs) that should be
/// drawn inside the page's top / bottom margin band. When empty the
/// renderer behaves exactly as the original single-stream version.
pub fn render_svg(
  domain : @domain.CT_Document,
  header_blocks? : Array[@domain.EG_BlockLevelElts] = [],
  footer_blocks? : Array[@domain.EG_BlockLevelElts] = [],
  /// §17.10.1 type="first" — the §17.6.6 `<w:titlePg>` first-page
  /// header. Empty when the section declares no first-page header;
  /// the renderer then falls back to `header_blocks`.
  header_blocks_first? : Array[@domain.EG_BlockLevelElts] = [],
  /// §17.10.1 type="even" — the even-page header used when the
  /// document sets `<w:evenAndOddHeaders>`.
  header_blocks_even? : Array[@domain.EG_BlockLevelElts] = [],
  /// §17.10.1 type="first" — the first-page footer.
  footer_blocks_first? : Array[@domain.EG_BlockLevelElts] = [],
  /// §17.10.1 type="even" — the even-page footer.
  footer_blocks_even? : Array[@domain.EG_BlockLevelElts] = [],
  /// §17.6.6 `<w:titlePg>` — when `true` the first page uses the
  /// `first`-type header / footer.
  title_pg? : Bool = false,
  /// §17.10.1 `<w:evenAndOddHeaders>` — when `true` even pages use
  /// the `even`-type header / footer.
  even_and_odd_headers? : Bool = false,
  image_resolver? : (String) -> ResolvedImage? = _ => None,
  styles? : @domain.CT_Styles? = None,
  numbering? : @domain.CT_Numbering? = None,
  /// §17.15.1.85 / Annex A — `/word/theme/theme1.xml` root
  /// element.  When supplied the renderer builds a
  /// `ThemeColorMap` from `<a:clrScheme>` so `<w:color>`
  /// attributes `@themeColor`/`@themeTint`/`@themeShade` resolve
  /// to concrete sRGB hex strings rather than being silently
  /// discarded.
  theme? : @xml.Element? = None,
) -> DocumentSvgResult {
  // Build the theme colour map once per document; the map is
  // empty when no theme part is supplied, in which case the
  // resolver falls back to the explicit @color value (the
  // same behaviour the renderer had before theme plumbing).
  let theme_map = match theme {
    Some(root) => parse_clr_scheme(root)
    None => ThemeColorMap::empty()
  }
  // §17.18.96 / §20.1.4.1.18 — extract the fontScheme too so
  // `<w:rFonts asciiTheme="majorAscii"/>` etc. resolve to the
  // theme's typeface (rather than the WML default Calibri).
  let font_map = parse_font_scheme(theme)
  // The renderer walks raw XML elements via the layout pipeline;
  // unbox each typed block-level projection through its
  // `source_element()` accessor so the legacy emit/flow code paths
  // keep operating on raw `@xml.Element` arrays.
  let unbox = fn(blocks : Array[@domain.EG_BlockLevelElts]) {
    let raw : Array[@xml.Element] = []
    for b in blocks {
      raw.push(b.source_element())
    }
    raw
  }
  let decoration = PageDecoration::{
    header_default: unbox(header_blocks),
    header_first: unbox(header_blocks_first),
    header_even: unbox(header_blocks_even),
    footer_default: unbox(footer_blocks),
    footer_first: unbox(footer_blocks_first),
    footer_even: unbox(footer_blocks_even),
    title_pg,
    even_and_odd: even_and_odd_headers,
  }
  render_svg_raw(
    domain,
    decoration,
    image_resolver,
    styles,
    numbering,
    theme_map~,
    font_map~,
  )
}

///|
/// Internal entry: raw-element header/footer arrays. Kept private so
/// callers can't reintroduce the `Array[@xml.Element]` boundary at
/// the public API.
fn render_svg_raw(
  domain : @domain.CT_Document,
  decoration : PageDecoration,
  image_resolver : (String) -> ResolvedImage?,
  styles : @domain.CT_Styles?,
  numbering : @domain.CT_Numbering?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
) -> DocumentSvgResult {
  let warnings : Array[String] = []
  let body = first_child_named(domain.element, "body")
  match body {
    None => {
      // No <w:body>: emit a single blank page using defaults.
      let cfg = default_page_config()
      let page = AssembledPage::{ paragraphs: [], tables: [] }
      let svg = emit_page_svg_with_decoration(
        page,
        cfg,
        decoration.headers_for(0),
        decoration.footers_for(0),
        warnings,
        image_resolver,
        styles,
      )
      let pages = [
        PageRenderResult::{
          svg,
          width: cfg.page_width,
          height: cfg.page_height,
        },
      ]
      DocumentSvgResult::{ pages, total_pages: 1, warnings }
    }
    Some(body_el) =>
      render_body_to_svg(
        body_el,
        warnings,
        decoration,
        image_resolver,
        domain.element,
        styles,
        numbering,
        theme_map~,
        font_map~,
      )
  }
}

// =============================================================================
// Top-level orchestration
// =============================================================================

///|
/// Lay out a <w:body> into pages and emit SVG.  @source document-render.ts.
fn render_body_to_svg(
  body : @xml.Element,
  warnings : Array[String],
  decoration : PageDecoration,
  image_resolver : (String) -> ResolvedImage?,
  document_root : @xml.Element,
  styles : @domain.CT_Styles?,
  numbering : @domain.CT_Numbering?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
) -> DocumentSvgResult {
  // 1. Resolve page configuration from <w:sectPr>.
  let cfg_base = resolve_page_config(body)
  // §17.2.1 `<w:document>/<w:background w:color="…">` — apply the
  // document-wide background colour over the section's default
  // white so every page picks it up.
  let cfg = apply_document_background(cfg_base, document_root)
  let content_width = (cfg.page_width - cfg.margin_left - cfg.margin_right).max(
    0.0,
  )

  // §17.6.4 — when the section declares more than one column, each
  // block is measured at the per-column width so line breaking wraps
  // inside the narrower flow rectangle. `column_width_of` derives the
  // measurement width; single-column sections fall back to the full
  // content width.
  let layout_width = column_width_of(cfg, content_width)

  // 2. Walk body, emitting a FlowBlock per <w:p> / <w:tbl>.
  let blocks = collect_blocks(
    body,
    layout_width,
    warnings,
    image_resolver,
    styles,
    numbering,
    theme_map~,
    font_map~,
  )

  // 3. Flow blocks into pages.
  let pages = flow_into_pages(blocks, cfg)

  // 4. Emit SVG per page. §17.10.1 — the header / footer stream is
  // selected per page index so `titlePg` / `evenAndOddHeaders`
  // documents draw the right first / even / default decoration.
  let rendered : Array[PageRenderResult] = []
  for page_index, page in pages {
    rendered.push(PageRenderResult::{
      svg: emit_page_svg_with_decoration(
        page,
        cfg,
        decoration.headers_for(page_index),
        decoration.footers_for(page_index),
        warnings,
        image_resolver,
        styles,
      ),
      width: cfg.page_width,
      height: cfg.page_height,
    })
  }
  DocumentSvgResult::{
    pages: rendered,
    total_pages: rendered.length(),
    warnings,
  }
}

// =============================================================================
// §17.6 Page configuration extraction
// =============================================================================

///|
/// Default page configuration (Letter, 1 inch margins).
/// @source page-flow.ts:1101 (DEFAULT_PAGE_FLOW_CONFIG).
fn default_page_config() -> PageConfig {
  let none = BorderSide::none()
  {
    page_width: DEFAULT_PAGE_WIDTH_TWIPS * TWIPS_TO_PX,
    page_height: DEFAULT_PAGE_HEIGHT_TWIPS * TWIPS_TO_PX,
    margin_top: DEFAULT_MARGIN_TWIPS * TWIPS_TO_PX,
    margin_bottom: DEFAULT_MARGIN_TWIPS * TWIPS_TO_PX,
    margin_left: DEFAULT_MARGIN_TWIPS * TWIPS_TO_PX,
    margin_right: DEFAULT_MARGIN_TWIPS * TWIPS_TO_PX,
    page_border_top: none,
    page_border_left: none,
    page_border_bottom: none,
    page_border_right: none,
    // §17.2.1 background — absence of `<w:background>` means no
    // page background per spec. The empty string suppresses the
    // background rect emission in `build_page_body_nodes`.
    page_background: "",
    // §17.6.4 — default single-column layout when no `<w:cols>` is set.
    cols_num: 1,
    cols_space: 0.0,
    cols_sep: false,
    cols_explicit: [],
  }
}

///|
/// Resolve PageConfig from the body's <w:sectPr>.  ECMA-376 §17.6.17.
fn resolve_page_config(body : @xml.Element) -> PageConfig {
  let mut cfg = default_page_config()
  // <w:sectPr> may be the last child of body, or appear inside <w:pPr>
  // of the final paragraph.  We prefer the direct body child.
  let sect_pr = find_sect_pr(body)
  match sect_pr {
    None => cfg
    Some(sp) => {
      // <w:pgSz w:w="..." w:h="..." />
      match first_child_named(sp, "pgSz") {
        Some(sz) => {
          let w_twips = parse_double_attr(sz, "w", DEFAULT_PAGE_WIDTH_TWIPS)
          let h_twips = parse_double_attr(sz, "h", DEFAULT_PAGE_HEIGHT_TWIPS)
          cfg = {
            ..cfg,
            page_width: w_twips * TWIPS_TO_PX,
            page_height: h_twips * TWIPS_TO_PX,
          }
        }
        None => ()
      }
      // <w:pgMar w:top="..." w:bottom="..." w:left="..." w:right="..." />
      match first_child_named(sp, "pgMar") {
        Some(mg) => {
          let top = parse_double_attr(mg, "top", DEFAULT_MARGIN_TWIPS)
          let bot = parse_double_attr(mg, "bottom", DEFAULT_MARGIN_TWIPS)
          let left = parse_double_attr(mg, "left", DEFAULT_MARGIN_TWIPS)
          let right = parse_double_attr(mg, "right", DEFAULT_MARGIN_TWIPS)
          cfg = {
            ..cfg,
            margin_top: top * TWIPS_TO_PX,
            margin_bottom: bot * TWIPS_TO_PX,
            margin_left: left * TWIPS_TO_PX,
            margin_right: right * TWIPS_TO_PX,
          }
        }
        None => ()
      }
      // §17.6.10 <w:pgBorders> — read each side through the shared
      // ST_Border helper. Sides without explicit children stay
      // BorderSide::none() so plain documents render without page
      // frames.
      match first_child_named(sp, "pgBorders") {
        None => ()
        Some(bdr) => {
          let none = BorderSide::none()
          cfg = {
            ..cfg,
            page_border_top: parse_border_side(
              first_child_named(bdr, "top"),
              none,
            ),
            page_border_left: parse_border_side(
              first_child_named(bdr, "left"),
              none,
            ),
            page_border_bottom: parse_border_side(
              first_child_named(bdr, "bottom"),
              none,
            ),
            page_border_right: parse_border_side(
              first_child_named(bdr, "right"),
              none,
            ),
          }
        }
      }
      // §17.6.4 `<w:cols num="N" space="..." sep="1|0"
      // equalWidth="…">` — multi-column layout descriptor. Drives the
      // column-aware re-flow in `flow_into_pages`, the separator
      // rules in `build_page_body_nodes`, and the SVG data
      // attributes. When `equalWidth="0"` the explicit `<w:col>`
      // children carry per-column widths.
      match first_child_named(sp, "cols") {
        None => ()
        Some(cols) => {
          let num = parse_double_attr(cols, "num", 1.0).to_int()
          let space = parse_double_attr(cols, "space", 0.0)
          let sep_str = attr_value(cols, "sep").unwrap_or("0")
          let sep = sep_str == "1" || sep_str == "true"
          // §17.6.4 @equalWidth — defaults to `true`. The explicit
          // `<w:col>` geometry is honoured only when it is `false`
          // (`"0"` / `"false"`) AND `<w:col>` children are present.
          let equal_width = match attr_value(cols, "equalWidth") {
            Some("0") | Some("false") => false
            _ => true
          }
          let explicit : Array[(Double, Double)] = []
          if not(equal_width) {
            for child in cols.children {
              match child {
                Element(e) =>
                  if e.name.local_name == "col" {
                    // §17.6.3 — `@w` width and `@space` trailing gap,
                    // both s:ST_TwipsMeasure. `@space` defaults to 0.
                    let w = parse_double_attr(e, "w", 0.0) * TWIPS_TO_PX
                    let sp_gap = parse_double_attr(e, "space", 0.0) *
                      TWIPS_TO_PX
                    explicit.push((w, sp_gap))
                  }
                _ => ()
              }
            }
          }
          // §17.6.4 — `@num` governs the column count, but a section
          // with explicit `<w:col>` children is sized by that list,
          // so fall back to its length when `@num` is absent / stale.
          let resolved_num = if explicit.length() > 0 {
            explicit.length()
          } else if num < 1 {
            1
          } else {
            num
          }
          cfg = {
            ..cfg,
            cols_num: resolved_num,
            cols_space: space * TWIPS_TO_PX,
            cols_sep: sep,
            cols_explicit: explicit,
          }
        }
      }
      cfg
    }
  }
}

///|
/// §17.2.1 `<w:document>/<w:background w:color="…">` — overlay the
/// document-wide background colour onto a `PageConfig`. Returns the
/// config unchanged when no `<w:background>` (or `@color="auto"`) is
/// declared so the legacy white default survives.
fn apply_document_background(
  cfg : PageConfig,
  document_root : @xml.Element,
) -> PageConfig {
  let background = match first_child_named(document_root, "background") {
    None => cfg.page_background
    Some(bg) =>
      match attr_value(bg, "color") {
        None => cfg.page_background
        Some(v) =>
          if v == "auto" || v.length() == 0 {
            cfg.page_background
          } else {
            "#" + v
          }
      }
  }
  { ..cfg, page_background: background }
}

///|
/// Locate <w:sectPr> in body (direct child, or the trailing paragraph's
/// <w:pPr> child for sections that close inside a paragraph).
fn find_sect_pr(body : @xml.Element) -> @xml.Element? {
  // Direct child.
  match first_child_named(body, "sectPr") {
    Some(sp) => return Some(sp)
    None => ()
  }
  // Scan trailing paragraphs in reverse for <w:pPr><w:sectPr>...</w:sectPr></w:pPr>.
  let mut i = body.children.length() - 1
  while i >= 0 {
    match body.children[i] {
      Element(e) =>
        if e.name.local_name == "p" {
          match first_child_named(e, "pPr") {
            Some(p_pr) =>
              match first_child_named(p_pr, "sectPr") {
                Some(sp) => return Some(sp)
                None => ()
              }
            None => ()
          }
        }
      _ => ()
    }
    i = i - 1
  }
  None
}

///|
/// Parse an XML attribute as Double, defaulting on parse failure.
fn parse_double_attr(
  element : @xml.Element,
  local_name : String,
  default : Double,
) -> Double {
  match attr_value(element, local_name) {
    None => default
    Some(value) =>
      try {
        let i : Int = @strconv.parse_int(value)
        i.to_double()
      } catch {
        _ => @strconv.parse_double(value) catch { _ => default }
      }
  }
}

// =============================================================================
// §17.3 Block collection: paragraphs and tables
// =============================================================================

///|
/// Walk <w:body> children, producing FlowBlocks for each <w:p> and <w:tbl>.
fn collect_blocks(
  body : @xml.Element,
  content_width : Double,
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  styles : @domain.CT_Styles?,
  numbering : @domain.CT_Numbering?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
) -> Array[FlowBlock] {
  let blocks : Array[FlowBlock] = []
  // §17.9 — numbering counter state: maps `(num_id, ilvl)` to current
  // counter value. Incremented as each numbered paragraph is encountered.
  let counters : @hashmap.HashMap[String, Int] = @hashmap.new()
  for child in body.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "p" => {
            let resolved = apply_styles_to_paragraph(e, styles)
            let with_marker = apply_numbering_marker(
              resolved, numbering, counters,
            )
            let para = layout_paragraph(
              with_marker,
              content_width,
              image_resolver,
              theme_map~,
              font_map~,
            )
            blocks.push(ParaBlock(para))
          }
          "tbl" => {
            let tbl = layout_table(e, content_width, warnings, styles)
            blocks.push(TableBlock(tbl))
          }
          "sectPr" => () // consumed elsewhere
          _ => () // ignore other elements (sdt, bookmarks, etc.)
        }
      _ => ()
    }
  }
  // §17.3.1.9 `<w:contextualSpacing>` — when two CONSECUTIVE
  // paragraphs both carry the toggle AND share the same pStyle,
  // the between-paragraph spacing is suppressed: the earlier
  // paragraph's `space_after` and the later one's `space_before`
  // are both removed.  We mutate the laid paragraphs in place,
  // re-deriving each `height` from the lost spacing.
  apply_contextual_spacing(blocks)
  blocks
}

///|
/// §17.3.1.9 — second pass over the flowed blocks: for each
/// consecutive ParaBlock pair where both paragraphs have
/// `contextualSpacing` on and the same `pStyle`, drop the
/// spacing between them.
fn apply_contextual_spacing(blocks : Array[FlowBlock]) -> Unit {
  let mut i = 0
  while i + 1 < blocks.length() {
    match (blocks[i], blocks[i + 1]) {
      (ParaBlock(a), ParaBlock(b)) =>
        if a.contextual_spacing &&
          b.contextual_spacing &&
          a.p_style == b.p_style {
          // Drop `a.space_after` and `b.space_before` — adjust
          // each paragraph's total height by the removed gap.
          let new_a = {
            ..a,
            height: a.height - a.space_after,
            space_after: 0.0,
          }
          let new_b = {
            ..b,
            height: b.height - b.space_before,
            space_before: 0.0,
          }
          blocks[i] = ParaBlock(new_a)
          blocks[i + 1] = ParaBlock(new_b)
        }
      _ => ()
    }
    i = i + 1
  }
}

///|
/// §17.9 — when a paragraph carries `<w:pPr><w:numPr>` and a typed
/// `CT_Numbering` is available, resolve the level definition and
/// inject a synthetic `<__bulletMarker val="…"/>` child into the
/// `<w:pPr>` so `collect_paragraph_spans` can emit the formatted
/// marker instead of the placeholder `•`. The level counter is
/// incremented before formatting so the first occurrence uses the
/// declared `start` value.
fn apply_numbering_marker(
  p : @xml.Element,
  numbering : @domain.CT_Numbering?,
  counters : @hashmap.HashMap[String, Int],
) -> @xml.Element {
  let table = match numbering {
    None => return p
    Some(t) => t
  }
  let p_pr = match first_child_named(p, "pPr") {
    None => return p
    Some(pp) => pp
  }
  let num_pr = match first_child_named(p_pr, "numPr") {
    None => return p
    Some(np) => np
  }
  let resolved = match @numbering_resolver.level_for_paragraph(table, num_pr) {
    None => return p
    Some(r) => r
  }
  let lvl = resolved.lvl
  let template = match lvl.lvl_text {
    None => return p
    Some(t) => t
  }
  // Increment this level's counter (and reset deeper ones per
  // §17.9.10 lvlRestart simplified: any change in active ilvl
  // resets deeper counters).
  let num_id = numbering_num_id(num_pr).unwrap_or(0)
  let key = num_id.to_string() + "/" + lvl.ilvl.to_string()
  let prev = counters.get(key).unwrap_or(lvl.start.unwrap_or(1) - 1)
  let next = prev + 1
  counters.set(key, next)
  // Build counters / formats arrays for format_lvl_text.  Each
  // `%N` in the lvlText is formatted using level N-1's own
  // `numFmt` (§17.9.11): we look up each ancestor lvl on the
  // same abstractNum so a child level whose parent is upperRoman
  // prints "I.1." instead of "1.1.".
  let level_counters : Array[Int] = []
  let level_formats : Array[@domain.ST_NumberFormat] = []
  let abstract_num_id = match table.nums.get(num_id) {
    Some(n) => n.abstract_num_id
    None => -1
  }
  let abstract_num = if abstract_num_id >= 0 {
    table.abstract_nums.get(abstract_num_id)
  } else {
    None
  }
  for i in 0..<(lvl.ilvl + 1) {
    let k = num_id.to_string() + "/" + i.to_string()
    let v = if i == lvl.ilvl { next } else { counters.get(k).unwrap_or(1) }
    level_counters.push(v)
    // Look up the ancestor lvl's own num_fmt; fall back to the
    // current level's num_fmt when the abstractNum doesn't
    // declare that ilvl (which would be a malformed numbering
    // part but degrades gracefully).
    let fmt = if i == lvl.ilvl {
      lvl.num_fmt.or(@domain.NumFmtDecimal)
    } else {
      match abstract_num {
        None => lvl.num_fmt.or(@domain.NumFmtDecimal)
        Some(abs_def) => {
          let mut found : @domain.ST_NumberFormat? = None
          for ancestor_lvl in abs_def.lvls {
            if ancestor_lvl.ilvl == i {
              found = ancestor_lvl.num_fmt
              break
            }
          }
          found.or(lvl.num_fmt.or(@domain.NumFmtDecimal))
        }
      }
    }
    level_formats.push(fmt)
  }
  let marker = @numbering_resolver.format_lvl_text(
    template, level_counters, level_formats,
  )
  // Inject a synthetic `<__bulletMarker val="…"/>` element under
  // `<w:pPr>` so the span collector can pick it up. Keep all
  // existing pPr children intact.
  let new_p_pr_children : Array[@xml.Node] = []
  for c in p_pr.children {
    new_p_pr_children.push(c)
  }
  new_p_pr_children.push(
    @xml.Node::Element({
      name: { prefix: None, local_name: "__bulletMarker", ns: None },
      attributes: [
        { name: { prefix: None, local_name: "val", ns: None }, value: marker },
      ],
      children: [],
    }),
  )
  let new_p_pr : @xml.Element = {
    name: p_pr.name,
    attributes: p_pr.attributes,
    children: new_p_pr_children,
  }
  let new_p_children : Array[@xml.Node] = []
  for c in p.children {
    match c {
      Element(e) =>
        if e.name.local_name == "pPr" {
          new_p_children.push(@xml.Node::Element(new_p_pr))
        } else {
          new_p_children.push(c)
        }
      _ => new_p_children.push(c)
    }
  }
  { name: p.name, attributes: p.attributes, children: new_p_children }
}

///|
fn numbering_num_id(num_pr : @xml.Element) -> Int? {
  for c in num_pr.children {
    match c {
      Element(e) =>
        if e.name.local_name == "numId" {
          for a in e.attributes {
            if a.name.local_name == "val" {
              match (try? @strconv.parse_int(a.value)) {
                Ok(v) => return Some(v)
                Err(_) => ()
              }
            }
          }
        }
      _ => ()
    }
  }
  None
}

///|
/// §17.7 / §17.3 — when a typed `CT_Styles` is available, return a
/// synthetic copy of `<w:p>` whose `<w:pPr>` and each `<w:r>` `<w:rPr>`
/// have been merged with the cascade (doc defaults → basedOn chain →
/// referenced style → direct inline) via `@style_resolver`. When no
/// styles table is wired in, return the original element unchanged so
/// the legacy behaviour (inline-only rendering) is preserved.
fn apply_styles_to_paragraph(
  p : @xml.Element,
  styles : @domain.CT_Styles?,
) -> @xml.Element {
  match styles {
    None => p
    Some(table) => {
      let direct_p_pr = first_child_named(p, "pPr")
      let resolved_p = @style_resolver.resolve_paragraph(table, direct_p_pr)
      // The paragraph-style cascade also supplies a base run-property
      // element (its own `<w:rPr>` from the styles chain). Every run
      // inside the paragraph layers its direct rPr — and the run-style
      // chain — on top of this base.
      let paragraph_r_pr_base = resolved_p.r_pr
      let new_children : Array[@xml.Node] = []
      let mut p_pr_emitted = false
      for child in p.children {
        match child {
          Element(e) =>
            if e.name.local_name == "pPr" {
              if !p_pr_emitted {
                match resolved_p.p_pr {
                  Some(merged) => new_children.push(@xml.Node::Element(merged))
                  None => new_children.push(child)
                }
                p_pr_emitted = true
              }
            } else if e.name.local_name == "r" {
              new_children.push(
                @xml.Node::Element(
                  apply_styles_to_run(e, table, paragraph_r_pr_base),
                ),
              )
            } else {
              new_children.push(child)
            }
          _ => new_children.push(child)
        }
      }
      if !p_pr_emitted {
        // Inject the resolved pPr (from doc defaults / referenced
        // style) when the paragraph had no direct `<w:pPr>` so the
        // viewer picks up cascaded properties.
        match resolved_p.p_pr {
          Some(merged) => {
            let injected : Array[@xml.Node] = [@xml.Node::Element(merged)]
            for n in new_children {
              injected.push(n)
            }
            return {
              name: p.name,
              attributes: p.attributes,
              children: injected,
            }
          }
          None => ()
        }
      }
      { name: p.name, attributes: p.attributes, children: new_children }
    }
  }
}

///|
/// Mirror of `apply_styles_to_paragraph` for a `<w:r>` run. Resolves
/// `<w:rPr><w:rStyle>` against the styles table and overlays the
/// effective r_pr in place of the direct one. `paragraph_r_pr_base`
/// is the run-property element supplied by the enclosing paragraph
/// style cascade — it acts as the base on which the run's own
/// resolved properties are layered.
fn apply_styles_to_run(
  r : @xml.Element,
  table : @domain.CT_Styles,
  paragraph_r_pr_base : @xml.Element?,
) -> @xml.Element {
  let direct_r_pr = first_child_named(r, "rPr")
  let resolved = @style_resolver.resolve_run(table, direct_r_pr)
  // Merge paragraph base under the run-level resolved rPr so direct
  // run properties still win.
  let final_r_pr = merge_run_pr_with_base(paragraph_r_pr_base, resolved.r_pr)
  let new_children : Array[@xml.Node] = []
  let mut r_pr_emitted = false
  for child in r.children {
    match child {
      Element(e) =>
        if e.name.local_name == "rPr" {
          if !r_pr_emitted {
            match final_r_pr {
              Some(merged) => new_children.push(@xml.Node::Element(merged))
              None => new_children.push(child)
            }
            r_pr_emitted = true
          }
        } else {
          new_children.push(child)
        }
      _ => new_children.push(child)
    }
  }
  if !r_pr_emitted {
    match final_r_pr {
      Some(merged) => {
        let injected : Array[@xml.Node] = [@xml.Node::Element(merged)]
        for n in new_children {
          injected.push(n)
        }
        return { name: r.name, attributes: r.attributes, children: injected }
      }
      None => ()
    }
  }
  { name: r.name, attributes: r.attributes, children: new_children }
}

///|
/// Merge a base `<w:rPr>` element under a derived one — child
/// elements present in `derived` override those in `base` by local
/// name, and any base-only children are preserved. Returns `None`
/// when both sides are absent so callers can skip injection.
fn merge_run_pr_with_base(
  base : @xml.Element?,
  derived : @xml.Element?,
) -> @xml.Element? {
  match (base, derived) {
    (None, None) => None
    (Some(b), None) => Some(b)
    (None, Some(d)) => Some(d)
    (Some(b), Some(d)) => {
      // Reuse the style_resolver's merging helper by piping through
      // resolve_run with the derived rPr — but that strips rStyle
      // resolution we already did. Instead, build a fresh element
      // with override-by-name semantics here.
      let overridden : @hashmap.HashMap[String, Bool] = @hashmap.new()
      let children : Array[@xml.Node] = []
      for node in d.children {
        match node {
          Element(child) => overridden.set(child.name.local_name, true)
          _ => ()
        }
      }
      for node in b.children {
        match node {
          Element(child) =>
            if !overridden.contains(child.name.local_name) {
              children.push(node)
            }
          _ => children.push(node)
        }
      }
      for node in d.children {
        children.push(node)
      }
      Some({ name: d.name, attributes: d.attributes, children })
    }
  }
}

// =============================================================================
// §17.3.1 Paragraph layout
// =============================================================================

///|
/// Resolve §17.3.1 paragraph properties from <w:pPr>.
fn resolve_para_props(
  p : @xml.Element,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
) -> ParaProps {
  let mut alignment = "left"
  let mut margin_left = 0.0
  let mut margin_right = 0.0
  let mut indent = 0.0
  let mut space_before = 0.0
  let mut space_after = 0.0
  let tab_stops : Array[(Double, String)] = []
  let mut line_height_spec : LineHeightSpec = LineHeightDefault
  match first_child_named(p, "pPr") {
    None => ()
    Some(p_pr) => {
      // §17.3.1.13 / §17.18.1 ST_Jc — the spec enumerates ~14
      // values (start, end, left, right, center, both, distribute,
      // mediumKashida, highKashida, lowKashida, numTab,
      // thaiDistribute, plus the deprecated equivalents). Each is
      // mapped explicitly to one of the CSS-aligned strings the
      // emitter understands. Kashida variants are Arabic-script
      // justification flavours; the closest CSS approximation is
      // `justify`. `numTab` aligns at the next number tab — also
      // closest to `justify` for left-to-right content.
      match first_child_named(p_pr, "jc") {
        Some(jc) =>
          match attr_value(jc, "val") {
            Some(v) =>
              alignment = match v {
                "left" | "start" => "left"
                "right" | "end" => "right"
                "center" => "center"
                "both" | "distribute" | "justify" => "justify"
                "mediumKashida"
                | "highKashida"
                | "lowKashida"
                | "thaiDistribute"
                | "numTab" => "justify"
                // Spec violation: unknown ST_Jc value. Default to
                // left so layout is still possible; consumer can
                // detect via the typed cascade.
                _ => "left"
              }
            None => ()
          }
        None => ()
      }
      // §17.3.1.12 <w:ind>
      match first_child_named(p_pr, "ind") {
        Some(ind_el) => {
          // §17.3.1.12 — `@start` is the writing-direction-aware
          // spelling of `@left` and overrides it WHEN PRESENT.  A
          // value of `0` (explicitly clearing an inherited indent)
          // or a negative outdent are both valid and MUST NOT be
          // ignored — the previous `> 0.0` test conflated
          // "attribute present" with "value positive".
          match attr_value(ind_el, "left") {
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(n) => margin_left = n * TWIPS_TO_PX
                Err(_) => ()
              }
            None => ()
          }
          match attr_value(ind_el, "start") {
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(n) => margin_left = n * TWIPS_TO_PX
                Err(_) => ()
              }
            None => ()
          }
          match attr_value(ind_el, "right") {
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(n) => margin_right = n * TWIPS_TO_PX
                Err(_) => ()
              }
            None => ()
          }
          match attr_value(ind_el, "end") {
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(n) => margin_right = n * TWIPS_TO_PX
                Err(_) => ()
              }
            None => ()
          }
          // first-line indent (positive) / hanging (negative).
          // §17.3.1.12 — the twips-based `@firstLine`/`@hanging`
          // win when present; the char-based `@firstLineChars`/
          // `@hangingChars` (hundredths of a character, §17.3.1.12)
          // are the fallback.  A "character" is the default-font
          // average advance — approximated here as 0.5em of the
          // WML default font size (11 pt → ≈7.3 px).
          let fl_twips = attr_value(ind_el, "firstLine")
          let hg_twips = attr_value(ind_el, "hanging")
          let char_px = DEFAULT_FONT_SIZE_PT * (96.0 / 72.0) * 0.5
          let fl = match fl_twips {
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(n) => n * TWIPS_TO_PX
                Err(_) => 0.0
              }
            None =>
              match attr_value(ind_el, "firstLineChars") {
                Some(v) =>
                  match (try? @strconv.parse_double(v)) {
                    // hundredths of a char → chars → px.
                    Ok(n) => n / 100.0 * char_px
                    Err(_) => 0.0
                  }
                None => 0.0
              }
          }
          let hg = match hg_twips {
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(n) => n * TWIPS_TO_PX
                Err(_) => 0.0
              }
            None =>
              match attr_value(ind_el, "hangingChars") {
                Some(v) =>
                  match (try? @strconv.parse_double(v)) {
                    Ok(n) => n / 100.0 * char_px
                    Err(_) => 0.0
                  }
                None => 0.0
              }
          }
          indent = fl - hg
        }
        None => ()
      }
      // §17.3.1.33 <w:spacing>
      match first_child_named(p_pr, "spacing") {
        Some(sp_el) => {
          // before / after in twips
          space_before = parse_double_attr(sp_el, "before", 0.0) * TWIPS_TO_PX
          space_after = parse_double_attr(sp_el, "after", 0.0) * TWIPS_TO_PX
          // `line` + `lineRule` — `auto` makes `line` a multiplier of
          // 240 (240 = single-line); `exact` / `atLeast` make `line`
          // a fixed twentieths-of-a-point measurement.
          match attr_value(sp_el, "line") {
            None => ()
            Some(line_v) =>
              match (try? @strconv.parse_double(line_v)) {
                Err(_) => ()
                Ok(line_raw) => {
                  let rule = attr_value(sp_el, "lineRule").unwrap_or("auto")
                  line_height_spec = if rule == "exact" || rule == "atLeast" {
                    LineHeightExact(line_raw / 20.0 * 96.0 / 72.0)
                  } else {
                    LineHeightAuto(line_raw / 240.0)
                  }
                }
              }
          }
        }
        None => ()
      }
      // §17.3.1.38 <w:tabs> — every `<w:tab @pos>` is twips. A
      // `@val="clear"` entry removes a previously declared stop; we
      // honour the spec by skipping the clear entries when building
      // the working list. The remaining entries are sorted ascending
      // so `next_tab_stop_after` can advance with a linear scan.
      match first_child_named(p_pr, "tabs") {
        None => ()
        Some(tabs_el) =>
          for child in tabs_el.children {
            match child {
              Element(tab_el) =>
                if tab_el.name.local_name == "tab" {
                  // §17.18.87 ST_TabJc — 9 spec values:
                  // bar, center, clear, decimal, end (alias of
                  // right), num (numeric alignment, legacy),
                  // start (alias of left), left, right.
                  //
                  // "clear" deletes a previously declared stop —
                  // we honour it by skipping the entry.  Each
                  // remaining stop carries its justification kind
                  // alongside the position; `resolve_tab_spans`
                  // applies the per-justification alignment when
                  // walking the line (left / center / right /
                  // decimal advance, and a vertical rule for bar).
                  // "start"/"end" are spec aliases for "left"/
                  // "right"; "num" / "decimal" both anchor on the
                  // first decimal point in the following text.
                  let (kept, val_kind) = match attr_value(tab_el, "val") {
                    Some("clear") => (false, "")
                    Some("bar") => (true, "bar")
                    Some("center") => (true, "center")
                    Some("decimal") => (true, "decimal")
                    Some("end") => (true, "right")
                    Some("num") => (true, "decimal")
                    Some("start") => (true, "left")
                    Some("left") => (true, "left")
                    Some("right") => (true, "right")
                    Some(_) => (false, "")
                    None => (true, "left")
                  }
                  if kept {
                    let pos_twips = parse_double_attr(tab_el, "pos", 0.0)
                    if pos_twips > 0.0 {
                      tab_stops.push((pos_twips * TWIPS_TO_PX, val_kind))
                    }
                  }
                }
              _ => ()
            }
          }
      }
      tab_stops.sort_by(fn(a, b) {
        let (ap, _) = a
        let (bp, _) = b
        ap.compare(bp)
      })
    }
  }
  // §17.3.1.6 / §17.18.78 `<w:shd>` — paragraph shading.  Five
  // colour-bearing attributes form the cascade:
  //   @fill — explicit hex (without `#`) or sentinel `auto`.
  //   @themeFill — ST_ThemeColor name (overrides @fill).
  //   @themeFillTint / @themeFillShade — ST_UcharHexNumber
  //     transforms applied on the resolved theme RGB.
  // (@color and @themeColor describe the *pattern* colour for
  // non-solid `@val`, not the fill; the renderer paints only the
  // solid background here.)
  let background = match first_child_named(p, "pPr") {
    None => ""
    Some(p_pr) =>
      match first_child_named(p_pr, "shd") {
        None => ""
        Some(shd) => {
          let base = match attr_value(shd, "fill") {
            None => None
            Some(v) =>
              if v == "auto" || v.length() == 0 {
                None
              } else {
                Some(v)
              }
          }
          let theme_color = attr_value(shd, "themeFill")
          let theme_tint = attr_value(shd, "themeFillTint")
          let theme_shade = attr_value(shd, "themeFillShade")
          match
            resolve_themed_color(
              base, theme_color, theme_tint, theme_shade, theme_map,
            ) {
            Some(hex) => "#" + hex
            None => ""
          }
        }
      }
  }
  // §17.3.1.7 `<w:pBdr>` — paragraph borders. Each child is a
  // ST_Border with the same semantics as `<w:tcBorders>`; an absent
  // child means "no border on that side".
  let none_side = BorderSide::none()
  let (border_top, border_left, border_bottom, border_right) = match
    first_child_named(p, "pPr") {
    None => (none_side, none_side, none_side, none_side)
    Some(p_pr) =>
      match first_child_named(p_pr, "pBdr") {
        None => (none_side, none_side, none_side, none_side)
        Some(bdr) =>
          (
            parse_border_side(first_child_named(bdr, "top"), none_side),
            parse_border_side(first_child_named(bdr, "left"), none_side),
            parse_border_side(first_child_named(bdr, "bottom"), none_side),
            parse_border_side(first_child_named(bdr, "right"), none_side),
          )
      }
  }
  // §17.3.1.5 `<w:pageBreakBefore>` toggle, §17.3.1.9
  // `<w:contextualSpacing>` toggle, §17.3.1.27 `<w:pStyle>`.
  let (page_break_before, contextual_spacing, p_style) = match
    first_child_named(p, "pPr") {
    None => (false, false, "")
    Some(p_pr) => {
      let pbb = has_toggle(p_pr, "pageBreakBefore")
      let cs = has_toggle(p_pr, "contextualSpacing")
      let style = match first_child_named(p_pr, "pStyle") {
        Some(ps) => attr_value(ps, "val").unwrap_or("")
        None => ""
      }
      (pbb, cs, style)
    }
  }
  ParaProps::{
    alignment,
    margin_left,
    margin_right,
    indent,
    space_before,
    space_after,
    tab_stops,
    background,
    border_top,
    border_left,
    border_bottom,
    border_right,
    line_height: line_height_spec,
    contextual_spacing,
    p_style,
    page_break_before,
  }
}

///|
/// Extract §17.3.2.27 run properties from <w:rPr> into a RunSpan
/// template (text and width are filled later).
///
/// `theme_map` is honoured by the §17.3.2.6 `<w:color>` resolver
/// to map `@themeColor`/`@themeTint`/`@themeShade` to concrete
/// sRGB hex.  Defaulting to `ThemeColorMap::empty()` preserves
/// the legacy no-theme behaviour for the run-property reader's
/// many other call sites; the only caller that supplies a real
/// theme map is the document-level `render_svg` pipeline (when
/// the consumer passed `theme=Some(t)`).
fn resolve_run_props(
  r : @xml.Element,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
) -> RunSpan {
  let mut font_family = DEFAULT_FONT_FAMILY
  let mut font_size_pt = DEFAULT_FONT_SIZE_PT
  let mut bold = false
  let mut italic = false
  let mut underline = false
  let mut underline_style = ""
  let mut strike = false
  let mut color = ""
  let mut highlight = ""
  match first_child_named(r, "rPr") {
    None => ()
    Some(r_pr) => {
      // §17.3.2.26 <w:rFonts> — preference order:
      //   1. Explicit `@ascii`/`@hAnsi` typefaces (literal names).
      //   2. `@asciiTheme`/`@hAnsiTheme` ST_Theme tokens
      //      (majorAscii, minorAscii, majorHAnsi, minorHAnsi,
      //      majorBidi, minorBidi, majorEastAsia, minorEastAsia)
      //      §17.18.96.  Resolved through the document's
      //      theme part via `font_map` (ThemeFontMap).
      match first_child_named(r_pr, "rFonts") {
        Some(fonts) => {
          let explicit_ascii = match attr_value(fonts, "ascii") {
            Some(v) => if v.length() > 0 { Some(v) } else { None }
            None => None
          }
          let explicit_h_ansi = match attr_value(fonts, "hAnsi") {
            Some(v) => if v.length() > 0 { Some(v) } else { None }
            None => None
          }
          let theme_ascii = match attr_value(fonts, "asciiTheme") {
            Some(v) => font_map.lookup(v)
            None => None
          }
          let theme_h_ansi = match attr_value(fonts, "hAnsiTheme") {
            Some(v) => font_map.lookup(v)
            None => None
          }
          // Precedence: explicit_ascii > explicit_h_ansi >
          // theme_ascii > theme_h_ansi.  This mirrors the §17.3.2.26
          // cascade so the literal name always wins, with the
          // theme resolution only kicking in when no literal is
          // present.
          let resolved = match explicit_ascii {
            Some(v) => Some(v)
            None =>
              match explicit_h_ansi {
                Some(v) => Some(v)
                None =>
                  match theme_ascii {
                    Some(v) => Some(v)
                    None => theme_h_ansi
                  }
              }
          }
          match resolved {
            Some(v) => font_family = v
            None => ()
          }
        }
        None => ()
      }
      // §17.3.2.38 <w:sz> (half-points)
      match first_child_named(r_pr, "sz") {
        Some(sz_el) =>
          match attr_value(sz_el, "val") {
            Some(v) =>
              try {
                let hp : Int = @strconv.parse_int(v)
                font_size_pt = hp.to_double() / 2.0
              } catch {
                _ => ()
              }
            None => ()
          }
        None => ()
      }
      // §17.3.2.1 <w:b>
      bold = has_toggle(r_pr, "b")
      // §17.3.2.16 <w:i>
      italic = has_toggle(r_pr, "i")
      // §17.3.2.40 / §17.18.99 — `<w:u>` toggles underline and
      // optionally carries `@val` selecting one of the 18+
      // ST_Underline line styles. We keep `underline : Bool` for
      // the simple gating + preserve the spec value in
      // `underline_style` so the emitter can surface it via
      // `data-ooxml-u` metadata.
      match first_child_named(r_pr, "u") {
        Some(u_el) =>
          match attr_value(u_el, "val") {
            Some(v) => {
              underline = v != "none"
              underline_style = v
            }
            None => {
              underline = true
              underline_style = "single"
            }
          }
        None => ()
      }
      // §17.3.2.37 <w:strike>
      strike = has_toggle(r_pr, "strike")
      // §17.3.2.6 <w:color> — `val` carries the explicit hex
      // (or the sentinel `auto`); `themeColor` (§17.18.97),
      // `themeTint` and `themeShade` (§17.18.98) override the
      // explicit colour with a theme-cascade computation.
      //
      // The theme-part bytes are loaded into the document at
      // the context layer (`Document.theme`) and a parsed
      // `ThemeColorMap` is built at the top of `render_svg`.
      // The deep call chain to `collect_paragraph_spans` does
      // NOT yet thread the theme map through every function
      // signature; we use `ThemeColorMap::empty()` here and
      // the helper falls back to the explicit `@val` per
      // §17.15.1.51.  When themeColor resolves to None
      // (current case until the map is threaded all the way
      // down) the explicit colour survives.
      match first_child_named(r_pr, "color") {
        Some(c_el) => {
          let base = match attr_value(c_el, "val") {
            Some(v) =>
              if v != "auto" && v.length() > 0 {
                Some(v)
              } else {
                None
              }
            None => None
          }
          let theme_color = attr_value(c_el, "themeColor")
          let theme_tint = attr_value(c_el, "themeTint")
          let theme_shade = attr_value(c_el, "themeShade")
          match
            resolve_themed_color(
              base, theme_color, theme_tint, theme_shade, theme_map,
            ) {
            Some(hex) => color = "#" + hex
            None => ()
          }
        }
        None => ()
      }
      // §17.3.2.15 <w:highlight>
      match first_child_named(r_pr, "highlight") {
        Some(h_el) =>
          match attr_value(h_el, "val") {
            Some(v) => if v != "none" && v.length() > 0 { highlight = v }
            None => ()
          }
        None => ()
      }
    }
  }
  // §17.3.2.42 <w:vertAlign> — superscript / subscript / baseline.
  // The bullet of OOXML measures the original font size; the
  // smaller raised / lowered glyphs come from the emitter's
  // scaling pass. We keep the resolved `font_size_pt` at run scope
  // and let `build_span_text_node` scale + offset based on
  // `vertical_align`.
  let mut vertical_align = "baseline"
  match first_child_named(r, "rPr") {
    None => ()
    Some(r_pr) =>
      match first_child_named(r_pr, "vertAlign") {
        None => ()
        Some(va) =>
          // §17.18.94 ST_VerticalAlignRun — exactly three values.
          match attr_value(va, "val") {
            Some("superscript") => vertical_align = "superscript"
            Some("subscript") => vertical_align = "subscript"
            Some("baseline") => () // already the default
            // Schema violation — fall through to "baseline".
            Some(_) => ()
            None => ()
          }
      }
  }
  // §17.3.2.36 <w:rPr><w:spacing w:val="…"> — character spacing in
  // twentieths of a point. Convert to CSS pixels via twips → twentyP
  // (val / 20) → px (96 / 72).
  let mut letter_spacing_px = 0.0
  match first_child_named(r, "rPr") {
    None => ()
    Some(r_pr) =>
      match first_child_named(r_pr, "spacing") {
        None => ()
        Some(sp_el) =>
          match attr_value(sp_el, "val") {
            None => ()
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(d) => letter_spacing_px = d / 20.0 * 96.0 / 72.0
                Err(_) => ()
              }
          }
      }
  }
  // §17.3.2.13 caps + §17.3.2.33 smallCaps + §17.3.2.9 dstrike —
  // toggle elements: present + (no @val OR @val != "false"/"0") = on.
  let mut caps = false
  let mut small_caps = false
  let mut border = BorderSide::none()
  let mut rtl = false
  let mut outline = false
  let mut shadow = false
  let mut emboss = false
  let mut imprint = false
  let mut emphasis = ""
  let mut position_offset_px = 0.0
  let mut scale_pct = 100.0
  let mut kern_half_points = 0.0
  let mut lang = ""
  match first_child_named(r, "rPr") {
    None => ()
    Some(r_pr) => {
      if has_toggle(r_pr, "caps") {
        caps = true
      }
      if has_toggle(r_pr, "smallCaps") {
        small_caps = true
      }
      // Treat double-strike as the same line-through visual as
      // single strike — SVG can't draw a stacked decoration on a
      // `<text>` element without two passes.
      if has_toggle(r_pr, "dstrike") {
        strike = true
      }
      // §17.3.2.4 `<w:bdr>` — run border. Reuse the ST_Border
      // helper used for `<w:tcBorders>` / `<w:pBdr>` so colour /
      // width / dash dispatch stays identical.
      border = parse_border_side(first_child_named(r_pr, "bdr"), border)
      // §17.3.2.30 `<w:rtl>` — right-to-left direction toggle.
      if has_toggle(r_pr, "rtl") {
        rtl = true
      }
      // §17.3.2.23 outline + §17.3.2.31 shadow — toggles.
      if has_toggle(r_pr, "outline") {
        outline = true
      }
      if has_toggle(r_pr, "shadow") {
        shadow = true
      }
      // §17.3.2.18 `<w:emboss>` (raised) + §17.3.2.21
      // `<w:imprint>` (engraved) — mutually-exclusive relief
      // toggles.  Each renders as a paired text-shadow.
      if has_toggle(r_pr, "emboss") {
        emboss = true
      }
      if has_toggle(r_pr, "imprint") {
        imprint = true
      }
      // §17.3.2.12 / §17.18.24 ST_Em — `<w:em w:val>` enumerates
      // 5 values; map each to the closest CSS `text-emphasis-style`
      // keyword so the emitted attribute is actually understood by
      // SVG/CSS. The previous pass-through embedded the raw spec
      // value, leaving `underDot` unrendered (CSS rejects it).
      // CSS `text-emphasis-position` (under vs over) controls the
      // mark position; `underDot` maps to a filled dot rendered
      // below the text, but the spec mark string we surface is the
      // CSS style only — the emitter applies the position elsewhere.
      match first_child_named(r_pr, "em") {
        None => ()
        Some(em_el) =>
          match attr_value(em_el, "val") {
            None => ()
            Some(v) =>
              emphasis = match v {
                "none" => ""
                "dot" => "filled dot"
                "comma" => "filled sesame"
                "circle" => "filled circle"
                "underDot" => "filled dot"
                // Spec violation: ST_Em is closed; unknown values
                // emit empty so no invalid CSS leaks through.
                _ => ""
              }
          }
      }
      // §17.3.2.24 position — `<w:position w:val="…">` in half-points
      // (positive = raised). Convert to CSS pixels via val/2 (pt) ×
      // 96/72. The emitter subtracts this from the baseline y.
      match first_child_named(r_pr, "position") {
        None => ()
        Some(pos_el) =>
          match attr_value(pos_el, "val") {
            None => ()
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(d) => position_offset_px = d / 2.0 * 96.0 / 72.0
                Err(_) => ()
              }
          }
      }
      // §17.3.2.46 horizontal scaling — `<w:w w:val="…">` percent.
      match first_child_named(r_pr, "w") {
        None => ()
        Some(w_el) =>
          match attr_value(w_el, "val") {
            None => ()
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(d) => if d > 0.0 { scale_pct = d }
                Err(_) => ()
              }
          }
      }
      // §17.3.2.20 `<w:kern w:val="…">` — the half-point font
      // size threshold above which automatic kerning applies.
      match first_child_named(r_pr, "kern") {
        None => ()
        Some(kern_el) =>
          match attr_value(kern_el, "val") {
            None => ()
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(d) => if d >= 0.0 { kern_half_points = d }
                Err(_) => ()
              }
          }
      }
      // §17.3.2.20 `<w:lang w:val="…">` — the run's BCP 47
      // language tag.  `@val` is the Latin language; `@eastAsia`
      // and `@bidi` carry the EA / complex-script variants.  For
      // the rendered `xml:lang` we use `@val` (the primary tag).
      match first_child_named(r_pr, "lang") {
        None => ()
        Some(lang_el) =>
          match attr_value(lang_el, "val") {
            Some(v) => if v.length() > 0 { lang = v }
            None => ()
          }
      }
    }
  }
  RunSpan::{
    text: "",
    font_family,
    font_size_pt,
    bold,
    italic,
    underline,
    underline_style,
    strike,
    color,
    highlight,
    width_px: 0.0,
    inline_image: None,
    vertical_align,
    letter_spacing_px,
    caps,
    small_caps,
    border,
    rtl,
    outline,
    shadow,
    emboss,
    imprint,
    emphasis,
    position_offset_px,
    scale_pct,
    kern_half_points,
    lang,
    bar_tab: false,
  }
}

///|
/// True for §17.3.2 toggle properties (<w:b/>, <w:i/>, ...).  Word's
/// toggle elements default to "on" when present and absent only
/// when explicitly turned off via the `@val` ST_OnOff attribute.
/// §17.18.69 enumerates the six lexical forms; values outside that
/// closed set are schema violations and fall through to the spec
/// default (true) so the property is honoured rather than silently
/// dropped.
fn has_toggle(r_pr : @xml.Element, name : String) -> Bool {
  match first_child_named(r_pr, name) {
    None => false
    Some(el) =>
      // Default `true` matches §17.3 toggle semantics — the
      // element's mere presence enables the property unless the
      // optional `@val` explicitly disables it.
      parse_xsd_on_off_or(attr_value(el, "val"), true)
  }
}

///|
/// Collect the text/spans of a paragraph from its <w:r> children.
/// Empty paragraphs (no runs) are kept as a single empty span for
/// proper line height.
fn collect_paragraph_spans(
  p : @xml.Element,
  image_resolver : (String) -> ResolvedImage?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
) -> Array[RunSpan] {
  let spans : Array[RunSpan] = []
  // §17.9.20 `<w:pPr><w:numPr>` — when the paragraph references a
  // numbering definition we prepend the resolved marker span that
  // `apply_numbering_marker` (full numbering pipeline) injected as
  // `<__bulletMarker val="…"/>`. When no marker has been resolved
  // (e.g. the numbering table is not wired in) we MUST NOT
  // substitute a literal bullet glyph: §17.9 mandates that the
  // marker text comes from the resolved `lvlText`/`numFmt`; a
  // U+2022 fallback would mis-represent the numbering definition.
  let bullet_marker : String? = match first_child_named(p, "pPr") {
    None => None
    Some(p_pr) =>
      match first_child_named(p_pr, "__bulletMarker") {
        Some(marker_el) =>
          match attr_value(marker_el, "val") {
            Some(v) => Some(v + "\u{0020}")
            None => None
          }
        None => None
      }
  }
  match bullet_marker {
    None => ()
    Some(marker) => {
      let template = match first_child_named(p, "r") {
        Some(r) => resolve_run_props(r, theme_map~, font_map~)
        None =>
          match first_child_named(p, "pPr") {
            Some(p_pr) =>
              match first_child_named(p_pr, "rPr") {
                Some(_) => resolve_run_props(p, theme_map~, font_map~)
                None => default_run_template()
              }
            None => default_run_template()
          }
      }
      let w = measure_run_text(marker, template)
      spans.push(with_text(template, marker, w))
    }
  }
  collect_paragraph_spans_into(
    p,
    false,
    spans,
    image_resolver,
    theme_map~,
    font_map~,
  )
  spans
}

///|
/// Default RunSpan template used when the paragraph has no `<w:r>` to
/// derive font / colour from.
fn default_run_template() -> RunSpan {
  {
    text: "",
    font_family: DEFAULT_FONT_FAMILY,
    font_size_pt: DEFAULT_FONT_SIZE_PT,
    bold: false,
    italic: false,
    underline: false,
    underline_style: "",
    strike: false,
    color: "",
    highlight: "",
    width_px: 0.0,
    inline_image: None,
    vertical_align: "baseline",
    letter_spacing_px: 0.0,
    caps: false,
    small_caps: false,
    border: BorderSide::none(),
    rtl: false,
    outline: false,
    shadow: false,
    emboss: false,
    imprint: false,
    emphasis: "",
    position_offset_px: 0.0,
    scale_pct: 100.0,
    kern_half_points: 0.0,
    lang: "",
    bar_tab: false,
  }
}

///|
/// Recursive helper for `collect_paragraph_spans`. Walks every child
/// element of `parent`; when it sees a `<w:r>` it emits run spans, and
/// when it sees a wrapper element that may itself contain runs
/// (`<w:hyperlink>`, `<w:fldSimple>`, `<w:smartTag>`, `<w:customXml>`,
/// `<w:ins>`, `<w:del>`, `<w:moveFrom>`, `<w:moveTo>`, `<w:sdt>`,
/// `<w:sdtContent>`) it recurses. The `hyperlink_styling` flag forces
/// blue + underlined output for runs inside `<w:hyperlink>` so the
/// downstream emitter can render them consistently with web-pptx.
fn collect_paragraph_spans_into(
  parent : @xml.Element,
  hyperlink_styling : Bool,
  spans : Array[RunSpan],
  image_resolver : (String) -> ResolvedImage?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
) -> Unit {
  for child in parent.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "r" =>
            emit_run_spans(
              e,
              hyperlink_styling,
              spans,
              image_resolver,
              theme_map~,
              font_map~,
            )
          "hyperlink" =>
            // §17.16.22 hyperlink — descend with hyperlink styling on.
            collect_paragraph_spans_into(
              e,
              true,
              spans,
              image_resolver,
              theme_map~,
              font_map~,
            )
          "fldSimple" =>
            // §17.16.19 `<w:fldSimple>` — field with literal
            // instruction.  Word stores the field result as
            // ordinary runs inside `<w:fldSimple>`, so descending
            // already shows the cached result.  Dynamic
            // evaluation (DATE/PAGE/AUTHOR etc.) is owned by
            // `@field_eval` — until the viewer wires the
            // evaluator (Round 13 #297) we honour the cached
            // result by treating the element as a transparent
            // container, matching Word's behaviour for
            // documents whose `<w:settings>/<w:updateFields>`
            // is unset.
            collect_paragraph_spans_into(
              e,
              hyperlink_styling,
              spans,
              image_resolver,
              theme_map~,
              font_map~,
            )
          "smartTag" | "customXml" | "sdt" | "sdtContent" =>
            // §17.5.1.13 smartTag + §17.5.2.x SDT wrappers —
            // descend transparently.
            collect_paragraph_spans_into(
              e,
              hyperlink_styling,
              spans,
              image_resolver,
              theme_map~,
              font_map~,
            )
          "ins" | "moveTo" => {
            // §17.13.5.18 `<w:ins>` / §17.13.5.27 `<w:moveTo>` —
            // inserted text.  Word's default visualisation is an
            // underline; we set `underline = true` on every span
            // produced from the descended runs.  The `@w:author`
            // attribute is preserved via the source DOM for
            // consumers that need to colour by author.
            let start = spans.length()
            collect_paragraph_spans_into(
              e,
              hyperlink_styling,
              spans,
              image_resolver,
              theme_map~,
              font_map~,
            )
            for i in start..<spans.length() {
              spans[i] = { ..spans[i], underline: true }
            }
          }
          "del" | "moveFrom" => {
            // §17.13.5.14 `<w:del>` / §17.13.5.20 `<w:moveFrom>` —
            // deleted text.  Spec visualisation is strike-through.
            let start = spans.length()
            collect_paragraph_spans_into(
              e,
              hyperlink_styling,
              spans,
              image_resolver,
              theme_map~,
              font_map~,
            )
            for i in start..<spans.length() {
              spans[i] = { ..spans[i], strike: true }
            }
          }
          _ => ()
        }
      _ => ()
    }
  }
}

///|
/// Emit spans for a single `<w:r>`. Mirrors the body of the legacy
/// branch in `collect_paragraph_spans`, but factored out so wrapper
/// elements can dispatch through `collect_paragraph_spans_into`.
fn emit_run_spans(
  r : @xml.Element,
  hyperlink_styling : Bool,
  spans : Array[RunSpan],
  image_resolver : (String) -> ResolvedImage?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
) -> Unit {
  // §17.3.2.43 vanish + §17.3.2.49 webHidden — hidden runs are
  // suppressed from the rendered output entirely. We still parse
  // run properties so any side-effect-free helpers stay consistent,
  // but skip every glyph/image emission.
  match first_child_named(r, "rPr") {
    None => ()
    Some(r_pr) =>
      if has_toggle(r_pr, "vanish") || has_toggle(r_pr, "webHidden") {
        return
      }
  }
  let template = resolve_run_props(r, theme_map~, font_map~)
  // Walk <w:t>, <w:tab>, <w:br>, etc., emitting spans.
  for r_child in r.children {
    match r_child {
      Element(re) =>
        match re.name.local_name {
          "t" => {
            let text = text_content(re)
            if text.length() > 0 {
              let w = measure_run_text(text, template)
              spans.push(
                apply_hyperlink_styling(
                  with_text(template, text, w),
                  hyperlink_styling,
                ),
              )
            }
          }
          "tab" =>
            // §17.3.1.38 `<w:tab>` — emit a sentinel span with text
            // `"\t"` and zero width. `layout_paragraph` resolves the
            // actual jump width against `<w:pPr><w:tabs>` (or a
            // default 0.5-inch grid) after the spans for the line
            // are known.
            spans.push(
              apply_hyperlink_styling(
                with_text(template, "\t", 0.0),
                hyperlink_styling,
              ),
            )
          "br" | "cr" => {
            // §17.3.3.1 br + §17.3.3.4 cr — explicit line break.
            // Emit a sentinel zero-width span whose text starts with
            // "\n" so the line breaker closes the current line.
            let w = 0.0
            spans.push(
              apply_hyperlink_styling(
                with_text(template, "\n", w),
                hyperlink_styling,
              ),
            )
          }
          "noBreakHyphen" => {
            // §17.3.3.18 noBreakHyphen — emit a non-breaking hyphen
            // (U+2011) so the line breaker keeps the adjoining glyphs
            // together. We measure it with the run template so its
            // width is realistic.
            let text = "\u{2011}"
            let w = measure_run_text(text, template)
            spans.push(
              apply_hyperlink_styling(
                with_text(template, text, w),
                hyperlink_styling,
              ),
            )
          }
          "softHyphen" =>
            // §17.3.3.29 softHyphen — pure layout hint. The visible
            // glyph appears only when the line breaks at that
            // position; we don't perform that optimisation today, so
            // the element collapses to zero width and emits nothing.
            ()
          "sym" =>
            // §17.3.3.30 sym — Symbol-font glyph reference. The
            // `@char` attribute is a hex code-point; `@font` selects
            // the typeface. Emit the resulting character so renderers
            // that have the symbol font installed pick up the glyph,
            // and override the font family on the span.
            match sym_character(re) {
              Some((ch, font)) => {
                let w = measure_run_text(ch, template)
                let with_font = with_text(template, ch, w)
                let sym_span = {
                  ..with_font,
                  font_family: font,
                  inline_image: None,
                }
                spans.push(apply_hyperlink_styling(sym_span, hyperlink_styling))
              }
              None => ()
            }
          "drawing" =>
            emit_drawing_span(
              re, template, hyperlink_styling, spans, image_resolver,
            )
          "object" | "pict" =>
            // §17.3.3.19 `<w:object>` / §17.3.3.21 `<w:pict>` — legacy
            // OLE / VML containers. Modern Word writes both with a
            // child `<w:drawing>` carrying the actual preview blip;
            // walk for it so the renderer still surfaces the image.
            match first_child_named(re, "drawing") {
              Some(d) =>
                emit_drawing_span(
                  d, template, hyperlink_styling, spans, image_resolver,
                )
              None => ()
            }
          "lastRenderedPageBreak" =>
            // §17.3.3.13 — Word writes this hint at the position
            // where the last save's pagination broke a line.  It
            // is purely informational; surface it as a sentinel
            // span (newline + zero width) so the line breaker
            // honours the hint, mirroring `<w:br type="page"/>`.
            spans.push(
              apply_hyperlink_styling(
                with_text(template, "\n", 0.0),
                hyperlink_styling,
              ),
            )
          "pgNum" => {
            // §17.3.3.22 — page-number sentinel.  The header /
            // footer evaluator substitutes the live page index
            // when the document is rendered to paged media;
            // emit a placeholder so the source position is
            // preserved.
            let placeholder = "#"
            let w = measure_run_text(placeholder, template)
            spans.push(
              apply_hyperlink_styling(
                with_text(template, placeholder, w),
                hyperlink_styling,
              ),
            )
          }
          // §17.3.3.31-.36 — date sentinels.  Like `pgNum`, the
          // header/footer evaluator substitutes the live date at
          // render time; emit a single-char placeholder so the
          // source position survives.
          "dayShort"
          | "dayLong"
          | "monthShort"
          | "monthLong"
          | "yearShort"
          | "yearLong" => {
            let placeholder = "#"
            let w = measure_run_text(placeholder, template)
            spans.push(
              apply_hyperlink_styling(
                with_text(template, placeholder, w),
                hyperlink_styling,
              ),
            )
          }
          // §17.11.7 `<w:footnoteRef>` / §17.11.14 `<w:endnoteRef>`
          // — auto-numbered reference mark inside a footnote /
          // endnote body part.  Spec text is the resolved mark
          // value; without per-footnote context here we surface a
          // placeholder.
          "footnoteRef" | "endnoteRef" => {
            let placeholder = "*"
            let w = measure_run_text(placeholder, template)
            spans.push(
              apply_hyperlink_styling(
                with_text(template, placeholder, w),
                hyperlink_styling,
              ),
            )
          }
          // §17.11.14 `<w:footnoteReference>` / §17.11.7 `<w:endnoteReference>`
          // — pointer from the body into the footnote/endnote
          // part.  Already rendered as `data-ooxml-*-id` markers
          // in the HTML viewer; emit a `*` superscript placeholder
          // in the SVG line.
          "footnoteReference" | "endnoteReference" => {
            let placeholder = "*"
            let w = measure_run_text(placeholder, template)
            spans.push(
              apply_hyperlink_styling(
                with_text(template, placeholder, w),
                hyperlink_styling,
              ),
            )
          }
          // §17.11.x `<w:separator>` / `<w:continuationSeparator>`
          // — footnote-body separator runs.  Each renders as a
          // horizontal rule; we emit a zero-width sentinel so the
          // line breaker preserves the position without injecting
          // visible text.
          "separator" | "continuationSeparator" => ()
          // §17.10.x `<w:annotationRef>` — comment-author reference
          // inside a comment body.  Spec text is the author's
          // initials; without context here we surface a
          // placeholder so the position is visible.
          "annotationRef" => {
            let placeholder = "*"
            let w = measure_run_text(placeholder, template)
            spans.push(
              apply_hyperlink_styling(
                with_text(template, placeholder, w),
                hyperlink_styling,
              ),
            )
          }
          // §17.3.1.x `<w:ptab>` — positional tab (alignment-
          // dependent jump within a paragraph).  Treat as a normal
          // tab; the proper jump target requires the paragraph's
          // alignment which the run dispatcher doesn't see.
          "ptab" =>
            spans.push(
              apply_hyperlink_styling(
                with_text(template, "\t", 0.0),
                hyperlink_styling,
              ),
            )
          _ => ()
        }
      Text(t) | CData(t) => {
        let w = measure_run_text(t, template)
        spans.push(
          apply_hyperlink_styling(with_text(template, t, w), hyperlink_styling),
        )
      }
      _ => ()
    }
  }
}

///|
/// Resolve a `<w:drawing>` element into an `InlineImage`. Walks the
/// `<wp:inline>` / `<wp:anchor>` child for the `<wp:extent>` dims and
/// the `<a:graphic>/<a:graphicData>/<pic:pic>/<pic:blipFill>/<a:blip
/// r:embed=…>` blip, then asks the supplied resolver for the image
/// payload. Returns `None` when either the extent is zero or no blip
/// embed could be resolved — the caller falls back to a whitespace
/// placeholder so line layout still reserves the right amount of
/// space.
fn build_inline_image(
  drawing : @xml.Element,
  image_resolver : (String) -> ResolvedImage?,
) -> InlineImage? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let rid = drawing_blip_rid(drawing)
  let alt = drawing_alt_text(drawing)
  let href = match rid {
    None => ""
    Some(r) =>
      match image_resolver(r) {
        Some(img) => "data:" + img.mime_type + ";base64," + img.base64_data
        None => ""
      }
  }
  if href == "" {
    None
  } else {
    let anchor_info = extract_anchor_info(drawing)
    Some({
      href,
      width_px: w_px,
      height_px: h_px,
      alt_text: alt,
      wrap_mode: anchor_info.wrap_mode,
      behind_doc: anchor_info.behind_doc,
      position_h_relative: anchor_info.position_h_relative,
      position_v_relative: anchor_info.position_v_relative,
    })
  }
}

///|
/// §20.4.2.3 — extract the `<wp:anchor>` metadata from a
/// `<w:drawing>` for surfacing as `data-ooxml-*` on the rendered
/// SVG element.  `<wp:inline>` drawings return the empty info.
priv struct AnchorInfo {
  wrap_mode : String
  behind_doc : Bool
  position_h_relative : String
  position_v_relative : String
}

///|
fn extract_anchor_info(drawing : @xml.Element) -> AnchorInfo {
  let mut info : AnchorInfo = {
    wrap_mode: "",
    behind_doc: false,
    position_h_relative: "",
    position_v_relative: "",
  }
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "anchor" {
          match attr_value(c, "behindDoc") {
            Some(v) => info = { ..info, behind_doc: v == "1" || v == "true" }
            None => ()
          }
          // Wrap mode: one of <wp:wrapSquare/>, <wp:wrapTight/>,
          // <wp:wrapNone/>, <wp:wrapTopAndBottom/>, <wp:wrapThrough/>.
          for k in c.children {
            match k {
              Element(e) => {
                let local = e.name.local_name
                if local == "wrapSquare" {
                  info = { ..info, wrap_mode: "Square" }
                } else if local == "wrapTight" {
                  info = { ..info, wrap_mode: "Tight" }
                } else if local == "wrapNone" {
                  info = { ..info, wrap_mode: "None" }
                } else if local == "wrapTopAndBottom" {
                  info = { ..info, wrap_mode: "TopAndBottom" }
                } else if local == "wrapThrough" {
                  info = { ..info, wrap_mode: "Through" }
                } else if local == "positionH" {
                  match attr_value(e, "relativeFrom") {
                    Some(rel) => info = { ..info, position_h_relative: rel }
                    None => ()
                  }
                } else if local == "positionV" {
                  match attr_value(e, "relativeFrom") {
                    Some(rel) => info = { ..info, position_v_relative: rel }
                    None => ()
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
  info
}

///|
/// Convert the `<wp:extent cx cy>` attributes of a `<w:drawing>` to
/// CSS pixels at 96 dpi (per §20.4.2.6 ST_PositiveCoordinate).
fn drawing_extent_size_px(drawing : @xml.Element) -> (Double, Double) {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "extent") {
            None => ()
            Some(extent) => {
              let cx = parse_double_attr(extent, "cx", 0.0)
              let cy = parse_double_attr(extent, "cy", 0.0)
              return (cx / 914400.0 * 96.0, cy / 914400.0 * 96.0)
            }
          }
        }
      _ => ()
    }
  }
  (0.0, 0.0)
}

///|
/// Drill into a `<w:drawing>` and return the first `r:embed` (or
/// `r:link`) Id from the inner `<a:graphic>/<a:graphicData>/<pic:pic>
/// /<pic:blipFill>/<a:blip>`. Returns `None` when no embed reference
/// is reachable.
fn drawing_blip_rid(drawing : @xml.Element) -> String? {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "graphic") {
            None => ()
            Some(g) =>
              match first_child_named(g, "graphicData") {
                None => ()
                Some(gd) =>
                  match first_child_named(gd, "pic") {
                    None => ()
                    Some(pic) =>
                      match first_child_named(pic, "blipFill") {
                        None => ()
                        Some(bf) =>
                          match first_child_named(bf, "blip") {
                            None => ()
                            Some(blip) =>
                              match attr_value(blip, "embed") {
                                Some(v) => return Some(v)
                                None =>
                                  match attr_value(blip, "link") {
                                    Some(v) => return Some(v)
                                    None => ()
                                  }
                              }
                          }
                      }
                  }
              }
          }
        }
      _ => ()
    }
  }
  None
}

///|
/// Pull the `descr` (alt text) or `name` from the `<wp:docPr>` child
/// of a `<w:drawing>` so the emitted `<image>` carries `<title>` for
/// accessibility. Returns the empty string when no alt-text is
/// available.
fn drawing_alt_text(drawing : @xml.Element) -> String {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "docPr") {
            None => ()
            Some(doc_pr) => {
              match attr_value(doc_pr, "descr") {
                Some(v) => if v.length() > 0 { return v }
                None => ()
              }
              match attr_value(doc_pr, "name") {
                Some(v) => if v.length() > 0 { return v }
                None => ()
              }
            }
          }
        }
      _ => ()
    }
  }
  ""
}

///|
/// Convert the `<wp:extent cx="…">` size attribute (EMU per
/// §20.4.2.6) of a `<w:drawing>` to CSS pixels at 96 dpi. Mirrors
/// web-pptx `extentToPixels` in docx/drawing pipeline. The extent
/// lives under `<wp:inline>` or `<wp:anchor>`, both of which are
/// direct children of `<w:drawing>` and carry exactly one
/// `<wp:extent>` child by spec.
fn drawing_extent_width_px(drawing : @xml.Element) -> Double {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "extent") {
            None => ()
            Some(extent) =>
              match attr_value(extent, "cx") {
                None => ()
                Some(v) =>
                  match (try? @strconv.parse_double(v)) {
                    Ok(emu) => return emu / 914400.0 * 96.0
                    Err(_) => ()
                  }
              }
          }
        }
      _ => ()
    }
  }
  0.0
}

///|
/// Emit a span (image or whitespace placeholder) for a `<w:drawing>`
/// element. Shared between the direct `<w:r><w:drawing>` path and the
/// `<w:object>` / `<w:pict>` wrapper paths so legacy containers also
/// surface inline images.
fn emit_drawing_span(
  drawing : @xml.Element,
  template : RunSpan,
  hyperlink_styling : Bool,
  spans : Array[RunSpan],
  image_resolver : (String) -> ResolvedImage?,
) -> Unit {
  match build_inline_image(drawing, image_resolver) {
    Some(img) =>
      spans.push(
        apply_hyperlink_styling(
          with_inline_image(template, img),
          hyperlink_styling,
        ),
      )
    None => {
      let w_px = drawing_extent_width_px(drawing)
      if w_px > 0.0 {
        spans.push(
          apply_hyperlink_styling(
            with_text(template, " ", w_px),
            hyperlink_styling,
          ),
        )
      }
    }
  }
}

///|
/// §17.3.3.30 — decode a `<w:sym>` element into (character, font
/// family). `@char` is a hex code-point (e.g. "F0E8"); `@font` is the
/// typeface that drew it. Returns `None` when the attributes are
/// missing or unparsable so the caller falls back to dropping the
/// element silently.
fn sym_character(sym : @xml.Element) -> (String, String)? {
  let font = match attr_value(sym, "font") {
    Some(v) => v
    None => return None
  }
  let raw = match attr_value(sym, "char") {
    Some(v) => v
    None => return None
  }
  let cp = parse_hex_int(raw)
  if cp <= 0 {
    return None
  }
  let buf = StringBuilder::new()
  buf.write_char(Char::from_int(cp))
  Some((buf.to_string(), font))
}

///|
/// Parse a hex integer like `"F0E8"`. Returns 0 when the input is
/// empty or contains a non-hex character so `sym_character` falls
/// back gracefully.
fn parse_hex_int(s : String) -> Int {
  let mut acc = 0
  for i in 0..<s.length() {
    let c = s.code_unit_at(i).to_int()
    let digit = if c >= 0x30 && c <= 0x39 {
      c - 0x30
    } else if c >= 0x41 && c <= 0x46 {
      c - 0x41 + 10
    } else if c >= 0x61 && c <= 0x66 {
      c - 0x61 + 10
    } else {
      return 0
    }
    acc = acc * 16 + digit
  }
  acc
}

///|
/// §17.16.22 hyperlink — when `enabled` is true (the run is inside
/// a `<w:hyperlink>`) the spec says the run "SHOULD use the
/// 'Hyperlink' character style" (§17.7.1). The colour itself is
/// NOT spec-defined; the Hyperlink style — when supplied — is the
/// authoritative source. Until the per-run style cascade routes
/// the Hyperlink style colour into this span, we preserve the
/// underline (which the Hyperlink style invariably supplies) and
/// leave the colour alone so the consumer's currentColor / theme
/// resolution takes over. The previous hardcoded `#0563c1` was a
/// Word-specific convention with no ECMA-376 anchor.
fn apply_hyperlink_styling(span : RunSpan, enabled : Bool) -> RunSpan {
  if !enabled {
    span
  } else {
    {
      ..span,
      underline: true,
      underline_style: if span.underline_style.length() > 0 {
        span.underline_style
      } else {
        "single"
      },
    }
  }
}

///|
/// Build a RunSpan with `text` and `width_px` from a template.
fn with_text(template : RunSpan, text : String, width : Double) -> RunSpan {
  { ..template, text, width_px: width, inline_image: None }
}

///|
/// Build a RunSpan containing an inline `<w:drawing>` payload. The
/// span reserves `(width, height)` in CSS pixels and stores the
/// resolved data URI (or empty when no `image_resolver` was supplied)
/// so the paragraph emitter can lay the picture out at the line
/// baseline.
fn with_inline_image(template : RunSpan, image : InlineImage) -> RunSpan {
  { ..template, text: "", width_px: image.width_px, inline_image: Some(image) }
}

///|
/// Measure text width using @util/glyph fallback path.
///
/// §17.3.2.13 `<w:caps>` renders every glyph as its uppercase
/// form; uppercase letters are typically wider than lowercase,
/// so the measurement MUST be done on the cased text — measuring
/// the raw lowercase text would under-estimate the line width
/// and over-pack lines.  §17.3.2.5 `<w:smallCaps>` renders
/// lowercase letters as small uppercase glyphs (≈80% cap height,
/// near the lowercase advance), so we measure the as-authored
/// text for smallCaps.
fn measure_run_text(text : String, template : RunSpan) -> Double {
  let measured_text = if template.caps { to_upper_ascii(text) } else { text }
  @glyph.estimate_text_width_fallback(
    measured_text,
    font_size_pt=template.font_size_pt,
    letter_spacing_px=template.letter_spacing_px,
    font_family=Some(template.font_family),
    font_weight=if template.bold { 700 } else { 400 },
  )
}

///|
/// Uppercase the ASCII letters of a string in place.  §17.3.2.13
/// caps applies to the full Unicode range, but the glyph-width
/// estimator's fallback table is ASCII-bucketed, so ASCII-only
/// folding is sufficient to keep the width estimate consistent.
fn to_upper_ascii(text : String) -> String {
  let buf = StringBuilder::new()
  let mut i = 0
  while i < text.length() {
    let c = text.code_unit_at(i).to_int()
    if c >= 0x61 && c <= 0x7A {
      buf.write_char((c - 0x20).to_char().unwrap())
    } else {
      buf.write_char(c.to_char().unwrap())
    }
    i = i + 1
  }
  buf.to_string()
}

///|
/// Layout one paragraph into a stack of lines.  Uses content_width as
/// available inline size, applies §17.3.1.12 indent / margin offsets,
/// and word-wraps using @util/glyph measurements.
/// @source web-pptx engine.ts:130 (layoutParagraph)
fn layout_paragraph(
  p : @xml.Element,
  content_width : Double,
  image_resolver : (String) -> ResolvedImage?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
) -> LaidParagraph {
  let props = resolve_para_props(p, theme_map~)
  let spans = collect_paragraph_spans(p, image_resolver, theme_map~, font_map~)

  // Inline width budgets for first vs. subsequent lines.
  let first_line_w = (content_width -
  props.margin_left -
  props.margin_right -
  props.indent).max(0.0)
  let next_line_w = (content_width - props.margin_left - props.margin_right).max(
    0.0,
  )

  // Break spans into lines.
  let span_lines = break_into_lines(spans, first_line_w, next_line_w)
  let line_count = span_lines.length()

  // For empty paragraphs (no text), emit a single empty line at default
  // line height so page-flow assigns vertical space.
  let final_lines = if line_count == 0 {
    [([] : Array[RunSpan])]
  } else {
    span_lines
  }

  // Build LaidLines.  Y values are paragraph-relative; absolute Y is
  // applied during page flow.
  let lines : Array[LaidLine] = []
  let mut current_y = props.space_before
  for idx in 0..<final_lines.length() {
    let raw_spans = final_lines[idx]
    let line_indent = if idx == 0 { props.indent } else { 0.0 }
    // §17.3.1.38 — resolve tab sentinel spans against the paragraph's
    // tab stops (or a default 0.5-inch grid) now that the line is
    // settled. Tabs are paragraph-relative — they measure from the
    // start of the line's content origin.
    let line_spans = resolve_tab_spans(raw_spans, line_indent, props.tab_stops)
    let lh_pt = line_max_font_size(line_spans)
    let line_height = match props.line_height {
      LineHeightDefault => lh_pt * @glyph.pt_to_px * 1.2
      LineHeightAuto(factor) => lh_pt * @glyph.pt_to_px * factor
      LineHeightExact(px) => px
    }
    let ascender = if line_spans.length() > 0 {
      @glyph.get_ascender_ratio(Some(line_spans[0].font_family))
    } else {
      0.8
    }
    let baseline = current_y + lh_pt * @glyph.pt_to_px * ascender
    let line_width = sum_span_widths(line_spans)
    let available = if idx == 0 { first_line_w } else { next_line_w }
    let base_x = props.margin_left + line_indent
    let x = match props.alignment {
      "center" => base_x + (available - line_width) / 2.0
      "right" => base_x + available - line_width
      _ => base_x
    }
    lines.push({
      spans: line_spans,
      x,
      y_top: current_y,
      y_baseline: baseline,
      height: line_height,
      width: line_width,
    })
    current_y = current_y + line_height
  }
  let height = current_y + props.space_after
  LaidParagraph::{
    lines,
    height,
    background: props.background,
    border_top: props.border_top,
    border_left: props.border_left,
    border_bottom: props.border_bottom,
    border_right: props.border_right,
    page_break_before: props.page_break_before,
    page_break_after: has_page_break_run(p),
    column_break_after: has_column_break_run(p),
    contextual_spacing: props.contextual_spacing,
    p_style: props.p_style,
    space_before: props.space_before,
    space_after: props.space_after,
  }
}

///|
/// §17.3.3.1 ST_BrType — classify the first `<w:br>` child found
/// inside the paragraph's runs. Spec enumerates 3 values:
///   page          — page break (drives `flow_into_pages`)
///   column        — column break (column layout not yet wired)
///   textWrapping  — line break (handled by `make_break_span`
///                   inside the run renderer; no paragraph-level
///                   effect)
/// Returned variant lets callers act on the spec-defined kind
/// instead of silently coalescing them.
enum BreakKind {
  BreakNone
  BreakPage
  BreakColumn
  BreakTextWrapping
}

///|
/// §17.3.3.1 — scan the paragraph for the first `<w:br>` child of
/// any run and classify its `w:type`. Spec default when `@type` is
/// absent is `textWrapping` (= line break).
fn first_break_kind(p : @xml.Element) -> BreakKind {
  for child in p.children {
    match child {
      Element(e) =>
        if e.name.local_name == "r" {
          for r_child in e.children {
            match r_child {
              Element(re) =>
                if re.name.local_name == "br" {
                  return match attr_value(re, "type") {
                    Some("page") => BreakPage
                    Some("column") => BreakColumn
                    Some("textWrapping") => BreakTextWrapping
                    // Default per §17.3.3.1 is textWrapping.
                    None => BreakTextWrapping
                    // Spec violation: unknown @type — treat as
                    // textWrapping (the spec default) so we do
                    // not silently force a page break.
                    Some(_) => BreakTextWrapping
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  BreakNone
}

///|
/// §17.3.3.1 — convenience used by `flow_into_pages` to decide
/// whether to close the current page after the paragraph. Returns
/// `true` only for page breaks; column / textWrapping breaks need
/// their own dedicated handlers and surface separately.
fn has_page_break_run(p : @xml.Element) -> Bool {
  // §17.18.3 ST_BrType — 3 spec values + BreakNone for paragraphs
  // without any <w:br> child.
  match first_break_kind(p) {
    BreakPage => true
    BreakColumn => false
    BreakTextWrapping => false
    BreakNone => false
  }
}

///|
/// §17.3.3.1 — `true` when any run inside the paragraph carries an
/// explicit `<w:br w:type="column"/>`. Drives the column advance in
/// `flow_into_pages` for sections whose `<w:cols w:num>` exceeds 1.
fn has_column_break_run(p : @xml.Element) -> Bool {
  // §17.18.3 ST_BrType — 3 spec values + BreakNone.
  match first_break_kind(p) {
    BreakColumn => true
    BreakPage => false
    BreakTextWrapping => false
    BreakNone => false
  }
}

///|
/// §17.4.40 / §17.4.41 — read `<w:tblPr>/<w:tblBorders>` and return
/// the six BorderSide slots (top, left, bottom, right, insideH,
/// insideV). Sides that are absent fall back to `BorderSide::none()`
/// per spec: §17.4.40 mandates "no border" when no tblBorders/
/// tcBorders are declared.
fn resolve_table_borders(
  tbl : @xml.Element,
) -> (BorderSide, BorderSide, BorderSide, BorderSide, BorderSide, BorderSide) {
  resolve_table_borders_from_pr(first_child_named(tbl, "tblPr"), tbl)
}

///|
/// §17.4.41 — same as `resolve_table_borders` but parametric on a
/// pre-merged `<w:tblPr>` element so callers that resolved the
/// tblStyle cascade can feed the merged tblPr instead of the raw
/// direct one. `_tbl` is unused; kept so the signature stays close
/// to the original for future shared logic.
fn resolve_table_borders_from_pr(
  tbl_pr : @xml.Element?,
  _tbl : @xml.Element,
) -> (BorderSide, BorderSide, BorderSide, BorderSide, BorderSide, BorderSide) {
  let default = BorderSide::default_legacy()
  let pr = match tbl_pr {
    Some(p) => p
    None => return (default, default, default, default, default, default)
  }
  let borders = match first_child_named(pr, "tblBorders") {
    Some(b) => b
    None => return (default, default, default, default, default, default)
  }
  let top = parse_border_side(first_child_named(borders, "top"), default)
  let left = parse_border_side(first_child_named(borders, "left"), default)
  let bottom = parse_border_side(first_child_named(borders, "bottom"), default)
  let right = parse_border_side(first_child_named(borders, "right"), default)
  let inside_h = parse_border_side(
    first_child_named(borders, "insideH"),
    default,
  )
  let inside_v = parse_border_side(
    first_child_named(borders, "insideV"),
    default,
  )
  (top, left, bottom, right, inside_h, inside_v)
}

///|
/// §17.4.41 / §17.7.4 / §17.7.6 — given a `<w:tbl>` element and the
/// optional styles table, return:
///   * `resolved_style` — typed `ResolvedTableStyle` for the table's
///     `<w:tblStyle w:val="...">` reference (or an empty cascade
///     when no tblStyle / no styles table).
///   * `tbl_look` — typed `TblLook` decoded from
///     `<w:tblPr>/<w:tblLook>` (or the spec default when absent).
///   * `effective_tbl_pr` — the merged `<w:tblPr>` element: base
///     tblPr from the style chain (`resolved_style.base.tbl_pr`),
///     overlaid by the wholeTable conditional bucket, overlaid by
///     the direct `<w:tblPr>` on the `<w:tbl>` itself. Callers can
///     feed this to existing tblBorders / tblWidth / tblCellMar
///     readers.
fn resolve_tbl_style_context(
  tbl : @xml.Element,
  styles : @domain.CT_Styles?,
) -> (
  @style_resolver.ResolvedTableStyle,
  @style_resolver.TblLook,
  @xml.Element?,
) {
  let direct_tbl_pr = first_child_named(tbl, "tblPr")
  let tbl_style_id : @domain.StyleId? = match direct_tbl_pr {
    None => None
    Some(pr) =>
      match first_child_named(pr, "tblStyle") {
        None => None
        Some(s) =>
          match attr_value(s, "val") {
            Some(v) => Some({ value: v })
            None => None
          }
      }
  }
  let resolved_style = match (styles, tbl_style_id) {
    (Some(table), Some(id)) => @style_resolver.resolve_table_style(table, id)
    _ => empty_resolved_table_style()
  }
  let tbl_look : @style_resolver.TblLook = match direct_tbl_pr {
    None => @style_resolver.TblLook::default_()
    Some(pr) =>
      match first_child_named(pr, "tblLook") {
        Some(tl) => @style_resolver.TblLook::from_element(tl)
        None => @style_resolver.TblLook::default_()
      }
  }
  let effective_tbl_pr = @style_resolver.merge_property_element_pub(
    @style_resolver.merge_property_element_pub(
      resolved_style.base.tbl_pr,
      resolved_style.whole_table.tbl_pr,
    ),
    direct_tbl_pr,
  )
  (resolved_style, tbl_look, effective_tbl_pr)
}

///|
/// Build an empty `ResolvedTableStyle` — used when the table has no
/// `<w:tblStyle>` reference (so the cascade collapses to direct-only
/// formatting).

///|
/// §17.4.85 `<w:vMerge>` classification. Three states cover the
/// spec's `restart` / `continue` enumeration plus the implicit
/// "absent" case where the cell does not participate in any
/// vertical merge.
enum VMergeState {
  VMergeNone
  VMergeRestart
  VMergeContinue
} derive(Eq)

///|
/// §17.4.85 — read the optional `<w:vMerge>` child of the merged
/// tcPr. Per spec, `w:val="restart"` anchors a new merge region;
/// any other value (including absent and "continue") marks a
/// continuation cell that suppresses its own rendering.
fn classify_v_merge(tc_pr : @xml.Element?) -> VMergeState {
  let pr = match tc_pr {
    None => return VMergeNone
    Some(p) => p
  }
  let v_merge_el = match first_child_named(pr, "vMerge") {
    None => return VMergeNone
    Some(el) => el
  }
  match attr_value(v_merge_el, "val") {
    Some("restart") => VMergeRestart
    Some("continue") => VMergeContinue
    Some(_) => VMergeContinue
    None => VMergeContinue
  }
}

///|
fn empty_resolved_table_style() -> @style_resolver.ResolvedTableStyle {
  let empty : @style_resolver.EffectiveProperties = {
    p_pr: None,
    r_pr: None,
    tbl_pr: None,
    tr_pr: None,
    tc_pr: None,
  }
  {
    base: empty,
    whole_table: empty,
    first_row: empty,
    last_row: empty,
    first_col: empty,
    last_col: empty,
    band1_horz: empty,
    band2_horz: empty,
    band1_vert: empty,
    band2_vert: empty,
    nw_cell: empty,
    ne_cell: empty,
    sw_cell: empty,
    se_cell: empty,
  }
}

///|
/// §17.4.59 / §17.18.3 — decode a `<w:tcBorders>/<w:top|left|bottom|right>`
/// child into a `BorderSide`. Falls back to `fallback` when the
/// element is absent so callers can preserve the previous default
/// (e.g. inherited table-wide borders or the legacy 1px gray frame).
/// `@val="none" | "nil"` collapses to `BorderSide::none()`.
fn parse_border_side(el : @xml.Element?, fallback : BorderSide) -> BorderSide {
  match el {
    None => fallback
    Some(side) => {
      let style = match attr_value(side, "val") {
        Some(v) => v
        None => "single"
      }
      if style == "none" || style == "nil" {
        return BorderSide::none()
      }
      // §17.18.2 ST_HexColor — "auto" defers the colour to the
      // consumer's choice. The renderer leaves the stroke attribute
      // empty so SVG's `currentColor` (inherited from the parent
      // text colour) takes over. The previous "#666666" was a
      // viewer-side decision with no spec basis.
      let color_hex = match attr_value(side, "color") {
        Some(v) => if v == "auto" || v.length() == 0 { "" } else { "#" + v }
        None => ""
      }
      // §17.18.5 ST_EighthPointMeasure — width is in eighths of a
      // point. Convert to CSS pixels via (sz / 8 pt) × (96 / 72).
      // The previous .max(0.5) clamp was removed: the spec permits
      // sz="0" to mean no border, and the caller already skips
      // emission when `style == "none"`.
      let width_px = match attr_value(side, "sz") {
        None => 1.0
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(eighths) => {
              let pt = eighths / 8.0
              pt * 96.0 / 72.0
            }
            Err(_) => 1.0
          }
      }
      { width_px, color_hex, style }
    }
  }
}

///|
/// §17.3.1.38 — resolve every tab sentinel (`text == "\t"`) on a line
/// by advancing the cursor to the next tab stop in `tab_stops`, or
/// to the next multiple of `DEFAULT_TAB_INTERVAL_PX` when no
/// paragraph-defined stop applies. The `line_origin` argument is the
/// line's content-origin offset (first-line indent for line 0, 0 for
/// subsequent lines) so the tab math matches Word's "relative to
/// content edge" semantics. Returns a new array with the resolved
/// widths written back into each tab span.
fn resolve_tab_spans(
  spans : Array[RunSpan],
  line_origin : Double,
  tab_stops : Array[(Double, String)],
) -> Array[RunSpan] {
  let out : Array[RunSpan] = []
  let mut cursor = line_origin
  // Walk by index so we can peek the run that follows each tab to
  // compute the alignment-aware advance per §17.18.87.
  let mut i = 0
  while i < spans.length() {
    let span = spans[i]
    if span.text == "\t" {
      let (target, kind) = next_tab_stop_after(cursor, tab_stops)
      // §17.18.87 — apply per-justification alignment.  Measure
      // the width of the text run that immediately follows the
      // tab (until the next tab / line break) and adjust the
      // tab's advance so that the following text:
      //   left   — text starts AT the stop (default).
      //   center — text is centred over the stop.
      //   right  — text ends AT the stop.
      //   decimal — first decimal point aligns to the stop.
      //   bar    — emits a vertical bar at the stop; tab has zero
      //            width (so the bar overlays the position).
      let following_width = peek_following_width(spans, i + 1)
      let advance = match kind {
        "center" => {
          let half = following_width / 2.0
          (target - half - cursor).max(0.0)
        }
        "right" => (target - following_width - cursor).max(0.0)
        "decimal" => {
          let prefix = decimal_prefix_width(spans, i + 1)
          (target - prefix - cursor).max(0.0)
        }
        "bar" => 0.0
        _ => (target - cursor).max(0.0)
      }
      out.push({
        ..span,
        text: "\t",
        width_px: advance,
        inline_image: None,
        bar_tab: kind == "bar",
      })
      cursor = cursor + advance
    } else {
      out.push(span)
      cursor = cursor + span.width_px
    }
    i = i + 1
  }
  out
}

///|
/// Sum the widths of every run from `start` until the next tab
/// sentinel or end-of-line.  Used to compute the alignment-aware
/// advance per §17.18.87.
fn peek_following_width(spans : Array[RunSpan], start : Int) -> Double {
  let mut w = 0.0
  let mut i = start
  while i < spans.length() {
    let s = spans[i]
    if s.text == "\t" {
      break
    }
    w = w + s.width_px
    i = i + 1
  }
  w
}

///|
/// §17.18.87 — for `decimal` tab justification, measure the width
/// of the text up to (and not including) the first decimal point.
/// Falls back to the full following width when no `.` appears.
fn decimal_prefix_width(spans : Array[RunSpan], start : Int) -> Double {
  let mut w = 0.0
  let mut i = start
  while i < spans.length() {
    let s = spans[i]
    if s.text == "\t" {
      break
    }
    // Find `.` inside the span's text.  Approximate: assume
    // uniform character width = width_px / text.length().
    let n = s.text.length()
    if n == 0 {
      i = i + 1
      continue
    }
    let mut idx = 0
    let mut dot = -1
    while idx < n {
      if s.text.code_unit_at(idx).to_int() == 0x2E {
        dot = idx
        break
      }
      idx = idx + 1
    }
    if dot >= 0 {
      let char_w = s.width_px / n.to_double()
      w = w + char_w * dot.to_double()
      return w
    }
    w = w + s.width_px
    i = i + 1
  }
  w
}

///|
/// Return the (position, kind) of the first tab-stop greater than
/// `cursor`. Falls back to a default-grid stop with kind="left"
/// when no explicit stop applies.
fn next_tab_stop_after(
  cursor : Double,
  tab_stops : Array[(Double, String)],
) -> (Double, String) {
  for stop in tab_stops {
    let (pos, kind) = stop
    if pos > cursor {
      return (pos, kind)
    }
  }
  let interval = default_tab_interval_px
  if interval <= 0.0 {
    return (cursor, "left")
  }
  let n = (cursor / interval).floor() + 1.0
  (n * interval, "left")
}

///|
/// Default §17.3.1.38 tab interval — 0.5 inch in CSS pixels at 96 dpi.
/// Word's default `<w:defaultTabStop>` is 720 twips (½ inch); the
/// renderer uses that value when no explicit `<w:tabs>` are declared
/// and the cursor passes the last paragraph-defined stop.
let default_tab_interval_px : Double = 48.0

///|
/// Return the maximum font size (pt) on a line, used to pick line height.
fn line_max_font_size(spans : Array[RunSpan]) -> Double {
  let mut max = DEFAULT_FONT_SIZE_PT
  for s in spans {
    if s.font_size_pt > max {
      max = s.font_size_pt
    }
  }
  max
}

///|
/// Sum span widths.
fn sum_span_widths(spans : Array[RunSpan]) -> Double {
  let mut w = 0.0
  for s in spans {
    w = w + s.width_px
  }
  w
}

// =============================================================================
// Line breaking
// =============================================================================

///|
/// True for ASCII break opportunities.
fn is_break_char_w(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '-'
}

///|
/// Break `spans` into lines that fit within (first_line_w, next_line_w).
/// Splits at spaces and CJK boundaries; honors explicit "\n" sentinels
/// emitted from <w:br> as forced line breaks.
fn break_into_lines(
  spans : Array[RunSpan],
  first_line_w : Double,
  next_line_w : Double,
) -> Array[Array[RunSpan]] {
  let lines : Array[Array[RunSpan]] = []
  let current : Array[RunSpan] = []
  let used : Ref[Double] = { val: 0.0 }
  let budget : Ref[Double] = { val: first_line_w }
  // Helper: flush current line to lines and reset state.
  fn flush() {
    let snapshot : Array[RunSpan] = []
    for s in current {
      snapshot.push(s)
    }
    lines.push(snapshot)
    current.clear()
    used.val = 0.0
    budget.val = next_line_w
  }

  for span in spans {
    // Forced break (\n sentinel)?
    if span.text == "\n" {
      flush()
      continue
    }
    // If span fits, append directly.
    if used.val + span.width_px <= budget.val {
      current.push(span)
      used.val = used.val + span.width_px
      continue
    }
    // Span overflows: try to break by word.
    let pieces = break_span_by_words(span, budget.val - used.val)
    for piece in pieces {
      if piece.text == "\n" {
        flush()
        continue
      }
      if used.val + piece.width_px <= budget.val || used.val == 0.0 {
        // Either it fits, or the line is empty (force-fit to avoid loop).
        current.push(piece)
        used.val = used.val + piece.width_px
      } else {
        flush()
        current.push(piece)
        used.val = piece.width_px
      }
    }
  }
  // Final flush if anything remains.
  if current.length() > 0 {
    let snapshot : Array[RunSpan] = []
    for s in current {
      snapshot.push(s)
    }
    lines.push(snapshot)
  }
  lines
}

///|
/// Decompose text into segments alternating between words and runs of
/// break characters (space/tab/hyphen).  Each segment is emitted in the
/// order it appeared so concatenation reproduces the original text.
fn split_into_segments(text : String) -> Array[String] {
  let segments : Array[String] = []
  let buf : Array[Char] = []
  let break_buf : Array[Char] = []
  for c in text {
    if is_break_char_w(c) {
      if buf.length() > 0 {
        segments.push(chars_to_string(buf))
        buf.clear()
      }
      break_buf.push(c)
    } else {
      if break_buf.length() > 0 {
        segments.push(chars_to_string(break_buf))
        break_buf.clear()
      }
      buf.push(c)
    }
  }
  if break_buf.length() > 0 {
    segments.push(chars_to_string(break_buf))
  }
  if buf.length() > 0 {
    segments.push(chars_to_string(buf))
  }
  segments
}

///|
/// Build a String from an Array[Char].
fn chars_to_string(chars : Array[Char]) -> String {
  let b = StringBuilder::new()
  for c in chars {
    b.write_char(c)
  }
  b.to_string()
}

///|
/// Break one oversized span into pieces at word boundaries.  Each
/// returned piece has a recomputed width.  Inserts "\n" sentinels to
/// instruct the caller to start a new line between word groups when
/// needed.
fn break_span_by_words(span : RunSpan, first_avail : Double) -> Array[RunSpan] {
  let segments = split_into_segments(span.text)
  let pieces : Array[RunSpan] = []
  let cur_chars : Array[Char] = []
  let cur_w : Ref[Double] = { val: 0.0 }
  let avail : Ref[Double] = { val: first_avail }
  // Flush current chars as a piece, append a sentinel for a forced break.
  fn flush_with_break() {
    if cur_chars.length() > 0 {
      let text = chars_to_string(cur_chars)
      let w = measure_run_text(text, span)
      pieces.push(with_text(span, text, w))
      cur_chars.clear()
    }
    pieces.push(with_text(span, "\n", 0.0))
    cur_w.val = 0.0
    avail.val = 1.0e18 // unlimited; caller will rebudget when it sees \n
  }

  for seg in segments {
    let seg_w = measure_run_text(seg, span)
    if cur_w.val + seg_w <= avail.val || cur_w.val == 0.0 {
      for c in seg {
        cur_chars.push(c)
      }
      cur_w.val = cur_w.val + seg_w
    } else {
      flush_with_break()
      for c in seg {
        cur_chars.push(c)
      }
      cur_w.val = seg_w
    }
  }
  if cur_chars.length() > 0 {
    let text = chars_to_string(cur_chars)
    let w = measure_run_text(text, span)
    pieces.push(with_text(span, text, w))
  }
  pieces
}

// =============================================================================
// §17.4 Table layout
// =============================================================================

///|
/// Layout a <w:tbl> into a LaidTable.  Cells are laid out left-to-right;
/// row heights take the max of all cell content heights in that row.
/// @source web-pptx table-layout.ts:264 (layoutTable)
fn layout_table(
  tbl : @xml.Element,
  available_width : Double,
  warnings : Array[String],
  styles : @domain.CT_Styles?,
) -> LaidTable {
  // §17.4.41 / §17.7.4 / §17.7.6 — discover an optional `<w:tblStyle
  // w:val="...">` reference and resolve it into a ResolvedTableStyle
  // + TblLook so per-cell conditional formatting buckets can be
  // applied below. When no `<w:tblStyle>` is declared or `styles`
  // is None, we fall through with empty buckets and the
  // resolved-table-style cascade becomes a no-op.
  let (resolved_style, tbl_look, effective_tbl_pr) = resolve_tbl_style_context(
    tbl, styles,
  )
  // 0. §17.4.41 `<w:tblPr>/<w:tblBorders>` — table-wide borders feed
  //    every cell's per-side fallback when `<w:tcBorders>` is absent.
  //    Use the merged tblPr (style chain + direct) so borders inherited
  //    from a tblStyle reach the layout pass.
  let (tbl_top, tbl_left, tbl_bottom, tbl_right, tbl_inside_h, tbl_inside_v) = resolve_table_borders_from_pr(
    effective_tbl_pr, tbl,
  )
  // §17.4.42 `<w:tblPr>/<w:tblCellMar>` — table-wide cell margins
  // feed every cell's padding default; per-cell `<w:tcMar>` overlays
  // those at the cell level (§17.4.69).
  let table_cell_margins = resolve_table_cell_margins(effective_tbl_pr)
  // 1. Read <w:tblGrid> for column widths.
  let col_widths : Array[Double] = []
  match first_child_named(tbl, "tblGrid") {
    Some(grid) =>
      for child in grid.children {
        match child {
          Element(e) =>
            if e.name.local_name == "gridCol" {
              let w = parse_double_attr(e, "w", 0.0) * TWIPS_TO_PX
              col_widths.push(w)
            }
          _ => ()
        }
      }
    None => ()
  }
  // 2. Read rows.
  let rows : Array[@xml.Element] = []
  for child in tbl.children {
    match child {
      Element(e) => if e.name.local_name == "tr" { rows.push(e) }
      _ => ()
    }
  }
  // 3. If no tblGrid, derive column count from first row.
  if col_widths.length() == 0 && rows.length() > 0 {
    let mut cell_count = 0
    for c in rows[0].children {
      match c {
        Element(e) =>
          if e.name.local_name == "tc" {
            cell_count = cell_count + 1
          }
        _ => ()
      }
    }
    if cell_count > 0 {
      let col_w = available_width / cell_count.to_double()
      for _ in 0..<cell_count {
        col_widths.push(col_w)
      }
    }
  }
  // 4. Scale column widths to fit available_width if they exceed it
  //    (some Word documents specify tblGrid widths that exceed margins).
  let total_specified = {
    let mut s = 0.0
    for w in col_widths {
      s = s + w
    }
    s
  }
  if total_specified > available_width && total_specified > 0.0 {
    warnings.push("table grid wider than content area; scaling down")
    let scale = available_width / total_specified
    for i in 0..<col_widths.length() {
      col_widths[i] = col_widths[i] * scale
    }
  }
  let table_width = {
    let mut s = 0.0
    for w in col_widths {
      s = s + w
    }
    s
  }
  // 5. Layout each row.
  let laid_rows : Array[LaidTableRow] = []
  let row_count = rows.length()
  // §17.4.85 — track active vertical-merge anchors per column so a
  // continuation cell (`<w:vMerge w:val="continue"/>` or `<w:vMerge/>`
  // with no val) can find its anchor and contribute its row height
  // back to the anchor. Each entry maps column index → (row index of
  // the laid_rows[] entry, cell index within that row).
  let v_merge_anchor : @hashmap.HashMap[Int, (Int, Int)] = @hashmap.new()
  let mut row_idx = 0
  for row in rows {
    let cells : Array[LaidTableCell] = []
    let cell_xs : Array[Double] = []
    let mut x_cursor = 0.0
    let mut col_idx = 0
    let row_cells : Array[@xml.Element] = []
    for child in row.children {
      match child {
        Element(e) => if e.name.local_name == "tc" { row_cells.push(e) }
        _ => ()
      }
    }
    // Track max cell height for row height.
    let mut row_height = 0.0
    for tc in row_cells {
      if col_idx >= col_widths.length() {
        break
      }
      // §17.4.16 <w:tcPr> / <w:gridSpan>
      let mut span = 1
      let mut background = ""
      // Pick the cell's per-side fallback from the table-level
      // borders: outer rows / cols use top|bottom|left|right, inner
      // edges use insideH / insideV.
      let last_col = col_idx >= col_widths.length() - 1
      let fb_top = if row_idx == 0 { tbl_top } else { tbl_inside_h }
      let fb_bottom = if row_idx == row_count - 1 {
        tbl_bottom
      } else {
        tbl_inside_h
      }
      let fb_left = if col_idx == 0 { tbl_left } else { tbl_inside_v }
      let fb_right = if last_col { tbl_right } else { tbl_inside_v }
      let mut border_top = fb_top
      let mut border_left = fb_left
      let mut border_bottom = fb_bottom
      let mut border_right = fb_right
      // §17.7.6 — resolve the cell's effective tcPr by layering
      // the table-style cascade (whole_table / bandX / firstX /
      // lastX / corners) under the direct cell tcPr. The merged
      // result then drives every existing reader below (gridSpan,
      // shd, tcBorders, etc.).
      let direct_tc_pr = first_child_named(tc, "tcPr")
      let direct_tr_pr = first_child_named(row, "trPr")
      let merged = @style_resolver.resolve_cell(
        resolved_style,
        tbl_look,
        row_idx,
        col_idx,
        row_count,
        col_widths.length(),
        None,
        None,
        direct_tc_pr,
        direct_tr_pr,
      )
      // §17.4.42 tblCellMar / §17.4.69 tcMar — overlay any per-cell
      // tcMar onto the table-level base. Honoured via merged.tc_pr
      // so style-cascade-defined defaults reach here.
      let cell_margins = resolve_cell_margins(table_cell_margins, merged.tc_pr)
      // §17.4.85 vMerge — classify the cell as anchor / continuation
      // / standalone before we read any other tcPr field. We use the
      // merged tcPr so style-cascade-defined vMerge defaults are
      // honoured (rare but spec-allowed).
      let v_merge_state = classify_v_merge(merged.tc_pr)
      // Read gridSpan early so continuation cells can advance the
      // column cursor by the full span (matching the anchor's width).
      let early_span = match merged.tc_pr {
        Some(tc_pr) =>
          match first_child_named(tc_pr, "gridSpan") {
            Some(gs) =>
              match attr_value(gs, "val") {
                Some(v) =>
                  match (try? @strconv.parse_int(v)) {
                    Ok(n) => if n > 0 { n } else { 1 }
                    Err(_) => 1
                  }
                None => 1
              }
            None => 1
          }
        None => 1
      }
      if v_merge_state == VMergeContinue {
        // §17.4.85 — continuation cell: do NOT push a LaidTableCell.
        // Instead, push the current row's height contribution to the
        // anchor recorded in v_merge_anchor[col_idx] (we postpone the
        // anchor's height adjustment until after row_height for THIS
        // row is finalised, since row_height depends on the anchor-
        // less cells too).
        // Advance the column cursor by the gridSpan so subsequent
        // cells in this row line up with the column grid.
        for s in 0..<early_span {
          if col_idx + s < col_widths.length() {
            x_cursor = x_cursor + col_widths[col_idx + s]
          }
        }
        col_idx = col_idx + early_span
        continue
      }
      match merged.tc_pr {
        Some(tc_pr) => {
          match first_child_named(tc_pr, "gridSpan") {
            Some(gs) =>
              match attr_value(gs, "val") {
                Some(v) =>
                  try {
                    span = @strconv.parse_int(v)
                  } catch {
                    _ => ()
                  }
                None => ()
              }
            None => ()
          }
          // §17.4.33 `<w:tc>/<w:tcPr>/<w:shd>` — same theme
          // cascade as the paragraph-level shading (§17.3.1.6).
          match first_child_named(tc_pr, "shd") {
            Some(shd) => {
              let base = match attr_value(shd, "fill") {
                None => None
                Some(v) =>
                  if v == "auto" || v.length() == 0 {
                    None
                  } else {
                    Some(v)
                  }
              }
              let theme_color = attr_value(shd, "themeFill")
              let theme_tint = attr_value(shd, "themeFillTint")
              let theme_shade = attr_value(shd, "themeFillShade")
              match
                resolve_themed_color(
                  base,
                  theme_color,
                  theme_tint,
                  theme_shade,
                  ThemeColorMap::empty(),
                ) {
                Some(hex) => background = "#" + hex
                None => ()
              }
            }
            None => ()
          }
          // §17.4.59 `<w:tcBorders>` — per-side overrides.
          match first_child_named(tc_pr, "tcBorders") {
            Some(borders) => {
              border_top = parse_border_side(
                first_child_named(borders, "top"),
                border_top,
              )
              border_left = parse_border_side(
                first_child_named(borders, "left"),
                border_left,
              )
              border_bottom = parse_border_side(
                first_child_named(borders, "bottom"),
                border_bottom,
              )
              border_right = parse_border_side(
                first_child_named(borders, "right"),
                border_right,
              )
              // §17.4.61 start/end aliases when bidi tables flip
              // left/right. Use them as a fallback when the explicit
              // left/right child is missing.
              match first_child_named(borders, "start") {
                Some(s_el) =>
                  if first_child_named(borders, "left") is None {
                    border_left = parse_border_side(Some(s_el), border_left)
                  }
                None => ()
              }
              match first_child_named(borders, "end") {
                Some(e_el) =>
                  if first_child_named(borders, "right") is None {
                    border_right = parse_border_side(Some(e_el), border_right)
                  }
                None => ()
              }
            }
            None => ()
          }
        }
        None => ()
      }
      // Compute cell width across spanned columns.
      let mut cw = 0.0
      let mut s = 0
      while s < span && col_idx + s < col_widths.length() {
        cw = cw + col_widths[col_idx + s]
        s = s + 1
      }
      let content_w = (cw - cell_margins.left - cell_margins.right).max(0.0)
      // §17.4.83 `<w:tcPr>/<w:vAlign w:val="top|center|bottom">` —
      // read the vertical anchor.  Default per spec is "top".
      let v_align = match merged.tc_pr {
        None => "top"
        Some(tc_pr_el) =>
          match first_child_named(tc_pr_el, "vAlign") {
            None => "top"
            Some(va) =>
              match attr_value(va, "val") {
                Some("center") => "center"
                Some("bottom") => "bottom"
                Some("top") => "top"
                Some(_) => "top"
                None => "top"
              }
          }
      }
      // Layout paragraphs inside the cell.
      let cell_paras : Array[LaidParagraph] = []
      let mut cell_inner_h = 0.0
      // Table cells don't have an image_resolver wired in yet; pass a
      // no-op resolver so inline `<w:drawing>` payloads still reserve
      // their cx width via the placeholder fallback.
      let cell_noop_resolver : (String) -> ResolvedImage? = _ => None
      for child in tc.children {
        match child {
          Element(e) =>
            if e.name.local_name == "p" {
              let para = layout_paragraph(e, content_w, cell_noop_resolver)
              cell_paras.push(para)
              cell_inner_h = cell_inner_h + para.height
            }
          _ => ()
        }
      }
      // §17.4 — cell height is derived from content alone (cell
      // padding + content height). §17.4.81 trHeight applies at the
      // row level (handled after this cell loop); the previous
      // hardcoded 20px floor had no spec basis and is removed.
      let cell_h = cell_inner_h + cell_margins.top + cell_margins.bottom
      if cell_h > row_height {
        row_height = cell_h
      }
      cell_xs.push(x_cursor)
      cells.push({
        x: x_cursor,
        width: cw,
        height: cell_h,
        paragraphs: cell_paras,
        background,
        border_top,
        border_left,
        border_bottom,
        border_right,
        padding: cell_margins,
        v_align,
      })
      // §17.4.85 — when this is a vMerge restart, register it as the
      // anchor for the column so subsequent continuation cells can
      // contribute their row heights back to this entry.
      if v_merge_state == VMergeRestart {
        v_merge_anchor.set(col_idx, (laid_rows.length(), cells.length() - 1))
      }
      x_cursor = x_cursor + cw
      col_idx = col_idx + span
    }
    // §17.4.81 trHeight — `<w:trPr><w:trHeight w:val="…" w:hRule="…"/>`
    // overrides content-derived row height per spec:
    //   hRule="exact"   → use trHeight.val verbatim
    //   hRule="atLeast" → max(content, trHeight.val)
    //   hRule="auto"    → ignore trHeight.val (default)
    match first_child_named(row, "trPr") {
      Some(tr_pr) =>
        match first_child_named(tr_pr, "trHeight") {
          Some(th_el) => {
            let val = parse_double_attr(th_el, "val", -1.0)
            if val > 0.0 {
              let h_px = val * TWIPS_TO_PX
              let h_rule = match attr_value(th_el, "hRule") {
                Some(v) => v
                None => "auto"
              }
              // §17.18.37 ST_HeightRule — exactly three values.
              // "auto" means the row height is content-driven and
              // the @val attribute is ignored.
              match h_rule {
                "exact" => row_height = h_px
                "atLeast" => if h_px > row_height { row_height = h_px }
                "auto" => () // content-driven, no override
                // Schema violation — treat as the spec default
                // "auto" so layout still completes.
                _ => ()
              }
            }
          }
          None => ()
        }
      None => ()
    }
    // After we know row_height, normalize cell heights.
    let normalized : Array[LaidTableCell] = []
    for c in cells {
      normalized.push({ ..c, height: row_height })
    }
    laid_rows.push({ height: row_height, cells: normalized })
    // §17.4.85 — every active vMerge anchor whose column did not see
    // a restart this row contributes the row's height to the anchor.
    // (Restart cells were already pushed to `normalized` this row, so
    // we exclude them by only growing entries that were registered
    // BEFORE this row.)
    let current_row_index = laid_rows.length() - 1
    let stale_anchors : Array[Int] = []
    for entry in v_merge_anchor {
      let (col, value) = entry
      let (anchor_row, anchor_cell) = value
      if anchor_row == current_row_index {
        // Restart happened this row; skip — height is already counted
        // via the normalized cell's height for this row.
        continue
      }
      // Continuation row — the merged anchor extends down by this
      // row's height. Mutate the laid_rows[anchor_row].cells[anchor_cell]
      // in place (Array indexing returns by reference for record
      // fields via reassignment).
      let anchor_row_data = laid_rows[anchor_row]
      let anchor_cell_data = anchor_row_data.cells[anchor_cell]
      let new_height = anchor_cell_data.height + row_height
      anchor_row_data.cells[anchor_cell] = {
        ..anchor_cell_data,
        height: new_height,
      }
      // Touch col so the compiler knows it's used.
      let _ = col
    }
    for c in stale_anchors {
      v_merge_anchor.remove(c)
    }
    row_idx = row_idx + 1
  }
  let mut total_h = 0.0
  for r in laid_rows {
    total_h = total_h + r.height
  }
  LaidTable::{ x: 0.0, width: table_width, height: total_h, rows: laid_rows }
}

// =============================================================================
// §17.6.2 Page flow
// =============================================================================

///|
/// §17.6.3 / §17.6.4 — the per-column geometry of the section's
/// content rectangle as a list of `(x_origin, width)` pairs in CSS
/// pixels, one entry per column, left-to-right.
///
/// Two layout modes:
///   - Equal-width (`<w:cols w:num="N" w:space="S">`, the default):
///     N columns of `(content_width - (N-1)*S) / N`, each gap S.
///   - Explicit (`<w:cols w:equalWidth="0">` with `<w:col>` children,
///     §17.6.3): each column takes its own `@w`; the `@space` on a
///     `<w:col>` is the gap *after* that column.
///
/// Single-column sections return one full-width entry so callers can
/// treat every section uniformly.
fn column_geometry(
  cfg : PageConfig,
  content_width : Double,
) -> Array[(Double, Double)] {
  let out : Array[(Double, Double)] = []
  if cfg.cols_num <= 1 {
    out.push((cfg.margin_left, content_width))
    return out
  }
  if cfg.cols_explicit.length() > 0 {
    // §17.6.3 — explicit per-column widths; each column's trailing
    // `@space` advances the running x origin.
    let mut x = cfg.margin_left
    for i in 0..<cfg.cols_explicit.length() {
      let (w, sp) = cfg.cols_explicit[i]
      out.push((x, w))
      x = x + w + sp
    }
    return out
  }
  // Equal-width: divide the content rectangle into `cols_num` equal
  // columns separated by `cols_space` gutters.
  let gutters = cfg.cols_space * (cfg.cols_num - 1).to_double()
  let w = ((content_width - gutters) / cfg.cols_num.to_double()).max(0.0)
  for i in 0..<cfg.cols_num {
    out.push((cfg.margin_left + i.to_double() * (w + cfg.cols_space), w))
  }
  out
}

///|
/// §17.6.4 — the measurement width passed to `collect_blocks` so line
/// breaking wraps inside the flow rectangle. Equal-width sections
/// have one width for every column; for explicit `<w:col>` sections
/// the *narrowest* column is used so a measured line never overflows
/// any column it might land in (the engine measures the block stream
/// once rather than re-measuring per column).
fn column_width_of(cfg : PageConfig, content_width : Double) -> Double {
  let geom = column_geometry(cfg, content_width)
  if geom.length() == 0 {
    return content_width
  }
  let mut min_w = geom[0].1
  for entry in geom {
    if entry.1 < min_w {
      min_w = entry.1
    }
  }
  min_w
}

///|
/// Split blocks into pages.  @source page-flow.ts:923 (flowIntoPages).
///
/// Single-column sections (`<w:cols w:num>` ≤ 1 or absent) flow each
/// block top-to-bottom, opening a fresh page when the next block does
/// not fit or a page break is requested.
///
/// Multi-column sections (§17.6.4) flow the same block stream into N
/// columns: a block that overflows the current column advances to the
/// next column, and overflowing the last column opens a new page.
/// `<w:br w:type="column"/>` forces the advance early.
///
/// This is a block-granular flow — paragraphs are not split across a
/// column or page boundary (it matches the keepTogether path of the
/// reference; widow/orphan splitting would need per-line accounting).
fn flow_into_pages(
  blocks : Array[FlowBlock],
  cfg : PageConfig,
) -> Array[AssembledPage] {
  let pages : Array[AssembledPage] = []
  let content_height = (cfg.page_height - cfg.margin_top - cfg.margin_bottom).max(
    0.0,
  )
  let content_width = (cfg.page_width - cfg.margin_left - cfg.margin_right).max(
    0.0,
  )
  // §17.6.3 / §17.6.4 — per-column `(x_origin, width)` geometry; one
  // entry per column. `column_count` is its length.
  let geometry = column_geometry(cfg, content_width)
  let column_count = geometry.length()
  let mut cur_paragraphs : Array[LaidParagraph] = []
  let mut cur_tables : Array[LaidTable] = []
  // The column currently being filled (0-based) and the running y
  // cursor inside that column.
  let mut cur_column = 0
  let mut cur_y = cfg.margin_top
  fn push_page() {
    let p : Array[LaidParagraph] = []
    for x in cur_paragraphs {
      p.push(x)
    }
    let t : Array[LaidTable] = []
    for x in cur_tables {
      t.push(x)
    }
    pages.push({ paragraphs: p, tables: t })
  }

  let has_content = fn() {
    cur_paragraphs.length() > 0 || cur_tables.length() > 0
  }
  // Close the current column. If columns remain, advance to the next
  // one and reset the y cursor; otherwise close the page.
  fn advance_column() {
    if cur_column + 1 < column_count {
      cur_column = cur_column + 1
      cur_y = cfg.margin_top
    } else {
      push_page()
      cur_paragraphs = []
      cur_tables = []
      cur_column = 0
      cur_y = cfg.margin_top
    }
  }
  // A page break always closes the whole page regardless of column.
  fn break_page() {
    push_page()
    cur_paragraphs = []
    cur_tables = []
    cur_column = 0
    cur_y = cfg.margin_top
  }

  for block in blocks {
    let block_h = match block {
      ParaBlock(p) => p.height
      TableBlock(t) => t.height + BLOCK_GAP_PX
    }
    let remaining = cfg.margin_top + content_height - cur_y
    // §17.3.1.5 — `<w:pageBreakBefore>` closes the current page
    // whenever the page already carries content.
    let force_break = match block {
      ParaBlock(p) => p.page_break_before
      TableBlock(_) => false
    }
    if force_break && has_content() {
      break_page()
    } else if block_h > remaining && has_content() {
      // Block overflows the current column: advance to the next
      // column (multi-column) or the next page (single-column).
      advance_column()
    }
    let col_x = geometry[cur_column].0
    match block {
      ParaBlock(p) => {
        // Adjust paragraph absolute Y by offsetting each line.
        let adjusted = offset_paragraph(p, col_x, cur_y)
        cur_paragraphs.push(adjusted)
        cur_y = cur_y + p.height
        // §17.3.3.1 — page break after this paragraph when any run
        // carried `<w:br w:type="page"/>`.
        if p.page_break_after {
          break_page()
        } else if p.column_break_after && column_count > 1 {
          // §17.3.3.1 — column break advances to the next column
          // (or page when this is the last column).
          advance_column()
        }
      }
      TableBlock(t) => {
        let adjusted = offset_table(t, col_x, cur_y)
        cur_tables.push(adjusted)
        cur_y = cur_y + t.height + BLOCK_GAP_PX
      }
    }
  }
  // Final page.
  if has_content() {
    push_page()
  }
  // Empty document: emit a single blank page.
  if pages.length() == 0 {
    pages.push({ paragraphs: [], tables: [] })
  }
  pages
}

///|
/// Shift a paragraph by (dx, dy) so its lines land at absolute page coords.
fn offset_paragraph(
  p : LaidParagraph,
  dx : Double,
  dy : Double,
) -> LaidParagraph {
  let lines : Array[LaidLine] = []
  for l in p.lines {
    lines.push({
      spans: l.spans,
      x: l.x + dx,
      y_top: l.y_top + dy,
      y_baseline: l.y_baseline + dy,
      height: l.height,
      width: l.width,
    })
  }
  { ..p, lines, }
}

///|
/// Shift a table by (dx, dy).
fn offset_table(t : LaidTable, dx : Double, dy : Double) -> LaidTable {
  let rows : Array[LaidTableRow] = []
  let mut row_y = dy
  for r in t.rows {
    let cells : Array[LaidTableCell] = []
    for c in r.cells {
      // §17.4.42 / §17.4.69 — offset cell-internal paragraphs by
      // (cell x + left padding, row y + top padding) using each
      // cell's resolved per-side margins.
      let cell_abs_x = dx + t.x + c.x + c.padding.left
      // §17.4.83 vAlign — shift the paragraph stack vertically:
      //   top     → start at cell_top + padding.top (default).
      //   center  → centre the content stack vertically.
      //   bottom  → bottom-align the content stack inside the cell.
      let content_h_total = {
        let mut total = 0.0
        for p in c.paragraphs {
          total = total + p.height
        }
        total
      }
      let available = (c.height - c.padding.top - c.padding.bottom).max(0.0)
      let v_offset = match c.v_align {
        "center" => ((available - content_h_total) / 2.0).max(0.0)
        "bottom" => (available - content_h_total).max(0.0)
        _ => 0.0
      }
      let cell_abs_y = row_y + c.padding.top + v_offset
      let inner_paras : Array[LaidParagraph] = []
      let mut local_y = 0.0
      for p in c.paragraphs {
        let abs_para = offset_paragraph(p, cell_abs_x, cell_abs_y + local_y)
        inner_paras.push(abs_para)
        local_y = local_y + p.height
      }
      cells.push({ ..c, x: dx + t.x + c.x, paragraphs: inner_paras })
    }
    rows.push({ height: r.height, cells })
    row_y = row_y + r.height
  }
  LaidTable::{ x: dx + t.x, width: t.width, height: t.height, rows }
}

// =============================================================================
// SVG emission
// =============================================================================

///|
/// Emit one page with optional §17.10 header/footer decoration.
///
/// Mirrors `attachHeadersFooters` + `renderPageToSvg` in
/// `document-render.ts:131..199`. Headers / footers are laid out
/// independently using the existing paragraph layout pipeline, then
/// rendered inside the page's top / bottom margin band via
/// `transform="translate(...)"`.
///
/// The whole page is assembled as an `@xml.Element` tree in the SVG
/// namespace and serialised once via `@markup.serialize_svg`; the
/// header / footer `<g>` groups are appended as ordinary child nodes
/// rather than spliced into a serialised string.
fn emit_page_svg_with_decoration(
  page : AssembledPage,
  cfg : PageConfig,
  header_blocks : Array[@xml.Element],
  footer_blocks : Array[@xml.Element],
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  styles : @domain.CT_Styles?,
) -> String {
  let children = build_page_body_nodes(page, cfg)
  // Lay out header/footer using a single-page flow over the section
  // width (margin_left..margin_right). The y-axis origin for each
  // band starts at 0 and we translate into place on the actual page.
  let content_width = (cfg.page_width - cfg.margin_left - cfg.margin_right).max(
    0.0,
  )
  if header_blocks.length() > 0 {
    let blocks = collect_blocks_from_elements(
      header_blocks, content_width, warnings, image_resolver, styles,
    )
    let group_children = build_decoration_block_nodes(blocks)
    children.push(
      @markup.elem_ns(
        "g",
        @markup.svg_ns,
        [
          @markup.attr(
            "transform",
            "translate(" + fmt_double(cfg.margin_left) + ", 0)",
          ),
        ],
        group_children,
      ),
    )
  }
  if footer_blocks.length() > 0 {
    let blocks = collect_blocks_from_elements(
      footer_blocks, content_width, warnings, image_resolver, styles,
    )
    let group_children = build_decoration_block_nodes(blocks)
    // Footer goes inside the bottom-margin band.
    let footer_y = cfg.page_height - cfg.margin_bottom
    children.push(
      @markup.elem_ns(
        "g",
        @markup.svg_ns,
        [
          @markup.attr(
            "transform",
            "translate(" +
            fmt_double(cfg.margin_left) +
            ", " +
            fmt_double(footer_y) +
            ")",
          ),
        ],
        group_children,
      ),
    )
  }
  @markup.serialize_svg(build_svg_element(cfg, children))
}

///|
/// Flow a header / footer block stream into SVG node children,
/// translating each block down by the running cursor.
fn build_decoration_block_nodes(blocks : Array[FlowBlock]) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  let mut cursor = 0.0
  for b in blocks {
    match b {
      ParaBlock(p) => {
        for n in build_paragraph_nodes(offset_paragraph(p, 0.0, cursor)) {
          out.push(n)
        }
        cursor = cursor + p.height
      }
      TableBlock(t) => {
        for n in build_table_nodes(offset_table(t, 0.0, cursor)) {
          out.push(n)
        }
        cursor = cursor + t.height
      }
    }
  }
  out
}

///|
/// Convert a raw block-level element list (e.g. CT_HdrFtr.block_level_elts)
/// into the layout-engine's FlowBlock stream. The element list isn't a
/// `<w:body>` so we wrap it in an inline iteration over the same
/// `collect_blocks` logic, then return the resulting blocks directly.
fn collect_blocks_from_elements(
  elements : Array[@xml.Element],
  content_width : Double,
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  styles : @domain.CT_Styles?,
) -> Array[FlowBlock] {
  let blocks : Array[FlowBlock] = []
  for elt in elements {
    match elt.name.local_name {
      "p" => {
        let lp = layout_paragraph(elt, content_width, image_resolver)
        blocks.push(ParaBlock(lp))
      }
      "tbl" => {
        let lt = layout_table(elt, content_width, warnings, styles)
        blocks.push(TableBlock(lt))
      }
      _ => ()
    }
  }
  blocks
}

///|
/// Build the root `<svg>` element (in the SVG namespace) carrying the
/// page dimensions, the `data-ooxml` marker, the optional §17.6.4
/// multi-column descriptor, and the supplied child nodes.
fn build_svg_element(
  cfg : PageConfig,
  children : Array[@xml.Node],
) -> @xml.Element {
  let w = cfg.page_width
  let h = cfg.page_height
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("width", fmt_double(w)),
    @markup.attr("height", fmt_double(h)),
    @markup.attr("viewBox", "0 0 " + fmt_double(w) + " " + fmt_double(h)),
    @markup.attr("data-ooxml", "wml"),
  ]
  // §17.6.4 `<w:cols>` — surface the multi-column descriptor as
  // data attributes alongside the column-aware re-flow performed by
  // `flow_into_pages`, so CSS-column consumers can still read it.
  if cfg.cols_num > 1 {
    attrs.push(@markup.attr("data-ooxml-cols-num", cfg.cols_num.to_string()))
    attrs.push(
      @markup.attr("data-ooxml-cols-space", fmt_double(cfg.cols_space)),
    )
    if cfg.cols_sep {
      attrs.push(@markup.attr("data-ooxml-cols-sep", "1"))
    }
  }
  { name: @markup.qname_ns("svg", @markup.svg_ns), attributes: attrs, children }
}

///|
/// Build the page body's child nodes — background rect, tables,
/// paragraphs, and §17.6.10 page borders — for embedding under the
/// root `<svg>`.
fn build_page_body_nodes(
  page : AssembledPage,
  cfg : PageConfig,
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  let w = cfg.page_width
  let h = cfg.page_height
  // §17.2.1 background — only emit a background `<rect>` when a
  // colour was explicitly declared via `<w:background w:color>`.
  // An empty page_background means no background was declared and
  // the page MUST remain transparent per spec.
  if cfg.page_background.length() > 0 {
    out.push(
      @markup.elem_ns(
        "rect",
        @markup.svg_ns,
        [
          @markup.attr("x", "0"),
          @markup.attr("y", "0"),
          @markup.attr("width", fmt_double(w)),
          @markup.attr("height", fmt_double(h)),
          @markup.attr("fill", cfg.page_background),
        ],
        [],
      ),
    )
  }
  // Tables (under text).
  for t in page.tables {
    for n in build_table_nodes(t) {
      out.push(n)
    }
  }
  // Paragraphs.
  for p in page.paragraphs {
    for n in build_paragraph_nodes(p) {
      out.push(n)
    }
  }
  // §17.6.10 page borders — draw four `<line>` segments around the
  // content area (margin-bound rectangle). `<w:pgBorders>` defines
  // them per side; sides with `BorderSide::none()` emit nothing.
  let x0 = cfg.margin_left
  let y0 = cfg.margin_top
  let x1 = cfg.page_width - cfg.margin_right
  let y1 = cfg.page_height - cfg.margin_bottom
  append_border_line_nodes(out, cfg.page_border_top, x0, y0, x1, y0)
  append_border_line_nodes(out, cfg.page_border_bottom, x0, y1, x1, y1)
  append_border_line_nodes(out, cfg.page_border_left, x0, y0, x0, y1)
  append_border_line_nodes(out, cfg.page_border_right, x1, y0, x1, y1)
  // §17.6.4 `<w:cols w:sep="1">` — draw a thin vertical rule down the
  // centre of each inter-column gutter, spanning the content height.
  if cfg.cols_num > 1 && cfg.cols_sep {
    let content_width = (cfg.page_width - cfg.margin_left - cfg.margin_right).max(
      0.0,
    )
    let geometry = column_geometry(cfg, content_width)
    for idx in 1..<geometry.length() {
      // Gutter `idx` lies between column `idx-1`'s right edge and
      // column `idx`'s left edge; the rule sits at its midpoint.
      let (prev_x, prev_w) = geometry[idx - 1]
      let cur_x = geometry[idx].0
      let sep_x = (prev_x + prev_w + cur_x) / 2.0
      out.push(
        @markup.elem_ns(
          "line",
          @markup.svg_ns,
          [
            @markup.attr("x1", fmt_double(sep_x)),
            @markup.attr("y1", fmt_double(y0)),
            @markup.attr("x2", fmt_double(sep_x)),
            @markup.attr("y2", fmt_double(y1)),
            @markup.attr("stroke", "#000000"),
            @markup.attr("stroke-width", "0.5"),
          ],
          [],
        ),
      )
    }
  }
  out
}

///|
/// Emit one paragraph's lines and runs as SVG <text> elements.
fn build_paragraph_nodes(p : LaidParagraph) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  // Compute the union of every line's bbox once so both the shading
  // rect and the §17.3.1.7 border lines can reuse it.
  let bbox = if p.lines.length() > 0 {
    let mut min_x = p.lines[0].x
    let mut max_x = p.lines[0].x + p.lines[0].width
    let mut min_y = p.lines[0].y_top
    let mut max_y = p.lines[0].y_top + p.lines[0].height
    for line in p.lines {
      if line.x < min_x {
        min_x = line.x
      }
      if line.x + line.width > max_x {
        max_x = line.x + line.width
      }
      if line.y_top < min_y {
        min_y = line.y_top
      }
      if line.y_top + line.height > max_y {
        max_y = line.y_top + line.height
      }
    }
    Some((min_x, min_y, max_x, max_y))
  } else {
    None
  }
  // §17.3.1.6 paragraph shading — emit a single background rect
  // spanning the bbox before the glyphs so the fill ends up under
  // the text.
  match bbox {
    Some((min_x, min_y, max_x, max_y)) =>
      if p.background.length() > 0 {
        out.push(
          @markup.elem_ns(
            "rect",
            @markup.svg_ns,
            [
              @markup.attr("x", fmt_double(min_x)),
              @markup.attr("y", fmt_double(min_y)),
              @markup.attr("width", fmt_double(max_x - min_x)),
              @markup.attr("height", fmt_double(max_y - min_y)),
              @markup.attr("fill", p.background),
            ],
            [],
          ),
        )
      }
    None => ()
  }
  for line in p.lines {
    if line.spans.length() == 0 {
      continue
    }
    append_line_nodes(out, line)
  }
  // §17.3.1.7 paragraph borders — emit per-side `<line>` segments
  // around the bbox after the glyphs so the stroke isn't obscured.
  match bbox {
    Some((min_x, min_y, max_x, max_y)) => {
      append_border_line_nodes(out, p.border_top, min_x, min_y, max_x, min_y)
      append_border_line_nodes(out, p.border_bottom, min_x, max_y, max_x, max_y)
      append_border_line_nodes(out, p.border_left, min_x, min_y, min_x, max_y)
      append_border_line_nodes(out, p.border_right, max_x, min_y, max_x, max_y)
    }
    None => ()
  }
  out
}

///|
/// Append the SVG nodes for one laid-out line's spans (images,
/// bar-tab rules, highlight / run-border rects, and `<text>`
/// glyph runs) to `out`.
fn append_line_nodes(out : Array[@xml.Node], line : LaidLine) -> Unit {
  let mut x_cursor = line.x
  for span in line.spans {
    // §17.3.3.9 inline image — emit an <image> element at the
    // baseline-aligned (x_cursor, y_top) and advance the cursor by
    // the reserved width.
    match span.inline_image {
      Some(img) => {
        let img_attrs : Array[@xml.Attribute] = [
          @markup.attr("x", fmt_double(x_cursor)),
          @markup.attr("y", fmt_double(line.y_baseline - img.height_px)),
          @markup.attr("width", fmt_double(img.width_px)),
          @markup.attr("height", fmt_double(img.height_px)),
          @markup.attr("href", img.href),
          @markup.attr("preserveAspectRatio", "xMidYMid meet"),
        ]
        // §20.4.2.3 — surface anchor metadata as data-ooxml-*
        // when the drawing was a `<wp:anchor>`.
        if img.wrap_mode.length() > 0 {
          img_attrs.push(@markup.attr("data-ooxml-wrap-mode", img.wrap_mode))
        }
        if img.behind_doc {
          img_attrs.push(@markup.attr("data-ooxml-behind-doc", "1"))
        }
        if img.position_h_relative.length() > 0 {
          img_attrs.push(
            @markup.attr("data-ooxml-pos-h-rel", img.position_h_relative),
          )
        }
        if img.position_v_relative.length() > 0 {
          img_attrs.push(
            @markup.attr("data-ooxml-pos-v-rel", img.position_v_relative),
          )
        }
        let img_children : Array[@xml.Node] = []
        if img.alt_text.length() > 0 {
          img_children.push(
            @markup.elem_ns("title", @markup.svg_ns, [], [
              @markup.text(img.alt_text),
            ]),
          )
        }
        out.push(
          @markup.elem_ns("image", @markup.svg_ns, img_attrs, img_children),
        )
        x_cursor = x_cursor + span.width_px
        continue
      }
      None => ()
    }
    if span.text.length() == 0 || span.text == "\n" {
      continue
    }
    // §17.18.87 ST_TabJc `bar` — a bar tab carries no glyph; it
    // draws a thin vertical rule at the stop position spanning
    // the line box.  The span's width is zero so the cursor does
    // not advance past the rule.
    if span.bar_tab {
      let bar_color = if span.color.length() > 0 {
        span.color
      } else {
        "#000000"
      }
      out.push(
        @markup.elem_ns(
          "line",
          @markup.svg_ns,
          [
            @markup.attr("x1", fmt_double(x_cursor)),
            @markup.attr("y1", fmt_double(line.y_top)),
            @markup.attr("x2", fmt_double(x_cursor)),
            @markup.attr("y2", fmt_double(line.y_top + line.height)),
            @markup.attr("stroke", bar_color),
            @markup.attr("stroke-width", "1"),
            @markup.attr("data-ooxml-tab", "bar"),
          ],
          [],
        ),
      )
      x_cursor = x_cursor + span.width_px
      continue
    }
    // Highlight rect (background) below the glyph.
    if span.highlight.length() > 0 {
      let hex = highlight_name_to_hex(span.highlight)
      out.push(
        @markup.elem_ns(
          "rect",
          @markup.svg_ns,
          [
            @markup.attr("x", fmt_double(x_cursor)),
            @markup.attr("y", fmt_double(line.y_top)),
            @markup.attr("width", fmt_double(span.width_px)),
            @markup.attr("height", fmt_double(line.height)),
            @markup.attr("fill", hex),
          ],
          [],
        ),
      )
    }
    // §17.3.2.4 `<w:bdr>` run border — single rect around the span
    // glyph bbox. Skipped when the run hasn't declared a border or
    // the style is `none`. The dash style isn't surfaced (`<rect>`
    // has no shared dispatch with `<line>` here); the colour and
    // width still match parse_border_side's resolution.
    if span.border.style != "none" && span.border.style != "nil" {
      // §17.18.2 — same `currentColor` fallback as the table /
      // page border emitters.
      let bdr_stroke = if span.border.color_hex.length() == 0 {
        "currentColor"
      } else {
        span.border.color_hex
      }
      out.push(
        @markup.elem_ns(
          "rect",
          @markup.svg_ns,
          [
            @markup.attr("x", fmt_double(x_cursor)),
            @markup.attr("y", fmt_double(line.y_top)),
            @markup.attr("width", fmt_double(span.width_px)),
            @markup.attr("height", fmt_double(line.height)),
            @markup.attr("fill", "none"),
            @markup.attr("stroke", bdr_stroke),
            @markup.attr("stroke-width", fmt_double(span.border.width_px)),
          ],
          [],
        ),
      )
    }
    out.push(build_span_text_node(span, line, x_cursor))
    x_cursor = x_cursor + span.width_px
  }
}

///|
/// Build the `<text>` element for one glyph-bearing run span at
/// `x_cursor` on `line`.  Attributes are appended in the same order
/// the legacy string emitter produced them.
fn build_span_text_node(
  span : RunSpan,
  line : LaidLine,
  x_cursor : Double,
) -> @xml.Node {
  // §17.3.2.42 vertAlign / §17.18.94 ST_VerticalAlignRun —
  // three values: `baseline` (identity), `superscript`,
  // `subscript`.  The spec describes the rendering as a
  // "smaller" glyph raised or lowered from the baseline but
  // does NOT specify the scale factor or offset.  The
  // constants below (65 % scale, 40 % raise, 20 % drop)
  // mirror CSS's default `vertical-align: super` / `sub`
  // behaviour (the same heuristics Word, LibreOffice, and
  // every browser ship with) — they are renderer policy,
  // not a spec mandate.
  // §17.3.2.24 position adds a further raise / drop in CSS
  // pixels (positive = raised, so subtract from y).
  let super_sub_scale = 0.65
  let super_raise_frac = 0.4
  let sub_drop_frac = 0.2
  let (size_scale, y_offset_vert) = match span.vertical_align {
    "superscript" =>
      (super_sub_scale, -span.font_size_pt * @glyph.pt_to_px * super_raise_frac)
    "subscript" =>
      (super_sub_scale, span.font_size_pt * @glyph.pt_to_px * sub_drop_frac)
    "baseline" => (1.0, 0.0)
    // Schema violation (the normaliser upstream restricts
    // the field to the three spec values, so this branch is
    // unreachable in practice). Use the spec default.
    _ => (1.0, 0.0)
  }
  let y_offset = y_offset_vert - span.position_offset_px
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("x", fmt_double(x_cursor)),
    @markup.attr("y", fmt_double(line.y_baseline + y_offset)),
    @markup.attr("font-family", span.font_family),
    @markup.attr(
      "font-size",
      fmt_double(span.font_size_pt * @glyph.pt_to_px * size_scale),
    ),
  ]
  // §17.3.2.46 character-width scaling — `transform: scaleX(p)`
  // anchored at the span's left edge so the run keeps its
  // declared start x.
  if span.scale_pct != 100.0 && span.scale_pct > 0.0 {
    let factor = span.scale_pct / 100.0
    attrs.push(
      @markup.attr(
        "transform",
        "translate(" +
        fmt_double(x_cursor) +
        ", 0) scale(" +
        fmt_double(factor) +
        ", 1) translate(-" +
        fmt_double(x_cursor) +
        ", 0)",
      ),
    )
  }
  // §17.3.2.36 character spacing — emit CSS letter-spacing.
  if span.letter_spacing_px != 0.0 {
    attrs.push(
      @markup.attr("letter-spacing", fmt_double(span.letter_spacing_px) + "px"),
    )
  }
  // §17.3.2.13 caps + §17.3.2.33 smallCaps + §17.3.2.31 shadow
  // + §17.3.2.12 emphasis — wrap into the SVG `style` attribute.
  // CSS handles each one via a dedicated property.
  let style_parts : Array[String] = []
  if span.caps {
    style_parts.push("text-transform: uppercase")
  }
  if span.small_caps {
    style_parts.push("font-variant: small-caps")
  }
  // §17.3.2.31 `<w:shadow>` is a toggle with no normative
  // offset, blur, or colour.  We keep a single 1 px black
  // 50 %-opacity drop-shadow as the rendered default (the
  // same heuristic Word's own consumer applies), but also
  // emit `data-ooxml-shadow="true"` so spec-aware consumers
  // can recompute the effect from the theme's `<a:outerShdw>`
  // properties instead of relying on the renderer's heuristic.
  if span.shadow {
    style_parts.push("text-shadow: 1px 1px 1px rgba(0,0,0,0.5)")
  }
  // §17.3.2.18 `<w:emboss>` — embossed (raised) text: a light
  // highlight up-left and a dark shadow down-right makes the
  // glyphs appear lifted off the page.  §17.3.2.21
  // `<w:imprint>` — the inverse (engraved / sunken).
  if span.emboss {
    style_parts.push(
      "text-shadow: -1px -1px 0 rgba(255,255,255,0.7), 1px 1px 1px rgba(0,0,0,0.5)",
    )
  }
  if span.imprint {
    style_parts.push(
      "text-shadow: 1px 1px 0 rgba(255,255,255,0.7), -1px -1px 1px rgba(0,0,0,0.5)",
    )
  }
  if span.emphasis.length() > 0 {
    style_parts.push("text-emphasis-style: " + span.emphasis)
  }
  if style_parts.length() > 0 {
    let style = StringBuilder::new()
    for i in 0..<style_parts.length() {
      if i > 0 {
        style.write_string("; ")
      }
      style.write_string(style_parts[i])
    }
    attrs.push(@markup.attr("style", style.to_string()))
  }
  // §17.3.2.31 — surface the shadow toggle as metadata for
  // consumers that need to recompute the effect rather than
  // honour the renderer's heuristic CSS shadow.
  if span.shadow {
    attrs.push(@markup.attr("data-ooxml-shadow", "true"))
  }
  // §17.3.2.18 / §17.3.2.21 — surface the relief toggle so
  // spec-aware consumers can recompute the effect.
  if span.emboss {
    attrs.push(@markup.attr("data-ooxml-relief", "emboss"))
  }
  if span.imprint {
    attrs.push(@markup.attr("data-ooxml-relief", "imprint"))
  }
  // §17.3.2.20 `<w:kern>` — kerning applies only when the
  // run's font size (pt) is at least the half-point
  // threshold.  Surface the raw threshold and, when active,
  // the SVG `kerning="auto"` hint so renderers that support
  // pair-kerning enable it.
  if span.kern_half_points > 0.0 {
    attrs.push(
      @markup.attr("data-ooxml-kern", fmt_double(span.kern_half_points)),
    )
    // §17.3.2.20 — threshold is in half-points; the run's
    // font_size_pt is in points, so compare against
    // kern_half_points / 2.
    if span.font_size_pt >= span.kern_half_points / 2.0 {
      attrs.push(@markup.attr("kerning", "auto"))
    }
  }
  // §17.3.2.20 `<w:lang>` — surface the BCP 47 tag as both
  // the standard `xml:lang` attribute and a `data-ooxml-lang`
  // mirror so locale-aware consumers can act on it.
  if span.lang.length() > 0 {
    attrs.push(@markup.attr_ns("xml", "lang", @xml.ns_xml_1998(), span.lang))
    attrs.push(@markup.attr("data-ooxml-lang", span.lang))
  }
  // §17.3.2.23 outline — text outline (stroke + fill). Painted
  // before the fill so the glyph fill stays on top.  When the
  // run has no explicit @color the spec (§17.15.1.51) says the
  // colour is `auto`, which inherits from the containing
  // context — we surface this as SVG's `currentColor` so the
  // CSS / parent element decides the actual pixel value rather
  // than substituting a literal black.
  if span.outline {
    let stroke = if span.color == "" { "currentColor" } else { span.color }
    attrs.push(@markup.attr("stroke", stroke))
    // §17.3.2.23 — the spec defines no stroke width; emit a
    // metadata attribute so consumers know an outline was
    // requested without committing to a magic pixel value.
    // The visible stroke width is left to the consumer's CSS;
    // we keep the legacy 1 px stroke-width for backward
    // compatibility with renderers that lack the CSS hook.
    attrs.push(@markup.attr("stroke-width", "1"))
    attrs.push(@markup.attr("data-ooxml-outline", "true"))
    attrs.push(@markup.attr("paint-order", "stroke fill"))
  }
  // §17.3.2.30 rtl — emit direction + unicode-bidi so RTL runs
  // render their characters right-to-left without re-ordering.
  if span.rtl {
    attrs.push(@markup.attr("direction", "rtl"))
    attrs.push(@markup.attr("unicode-bidi", "bidi-override"))
  }
  if span.bold {
    attrs.push(@markup.attr("font-weight", "bold"))
  }
  if span.italic {
    attrs.push(@markup.attr("font-style", "italic"))
  }
  let mut decoration = ""
  if span.underline {
    decoration = "underline"
  }
  if span.strike {
    decoration = if decoration == "" {
      "line-through"
    } else {
      decoration + " line-through"
    }
  }
  if decoration.length() > 0 {
    attrs.push(@markup.attr("text-decoration", decoration))
  }
  // §17.18.99 ST_Underline — surface the original `@val` so
  // consumers can apply the spec line style (single / double
  // / dotted / wave / dashLong / wavyDouble / etc.) that the
  // single `text-decoration="underline"` attribute cannot
  // express. Empty `underline_style` means no `<w:u>` was
  // declared.
  if span.underline &&
    span.underline_style.length() > 0 &&
    span.underline_style != "single" {
    attrs.push(@markup.attr("data-ooxml-u", span.underline_style))
  }
  // §17.3.2.6 / §17.15.1.51 — when `@color` is absent or
  // resolves to the sentinel `auto`, the glyph colour is
  // determined by the consumer's containing context; we
  // therefore emit `currentColor` rather than substituting a
  // literal black that would override the cascade.
  let fill = if span.color == "" { "currentColor" } else { span.color }
  attrs.push(@markup.attr("fill", fill))
  @markup.elem_ns("text", @markup.svg_ns, attrs, [@markup.text(span.text)])
}

///|
/// Emit a table as nested SVG elements: per-cell rect + per-cell paragraphs.
fn build_table_nodes(t : LaidTable) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for row in t.rows {
    for c in row.cells {
      // §17.4.83 `<w:tcPr>/<w:vAlign>` — surface the resolved
      // anchor as a transparent data-ooxml-v-align sidecar rect so
      // consumers can detect the vertical-alignment intent.  The
      // paragraph offset above already implements the visual shift.
      if c.v_align != "top" {
        let cell_top = cell_top_y(c)
        out.push(
          @markup.elem_ns(
            "rect",
            @markup.svg_ns,
            [
              @markup.attr("x", fmt_double(c.x)),
              @markup.attr("y", fmt_double(cell_top)),
              @markup.attr("width", fmt_double(c.width)),
              @markup.attr("height", fmt_double(c.height)),
              @markup.attr("fill", "transparent"),
              @markup.attr("data-ooxml-v-align", c.v_align),
            ],
            [],
          ),
        )
      }
      // Background fill (if any).
      if c.background.length() > 0 {
        // Row Y is encoded in paragraph absolute coordinates; for the
        // rectangle we derive it from the first paragraph or fall back
        // to using cell.height as full row height starting at the
        // first paragraph's top.
        let cell_top = cell_top_y(c)
        out.push(
          @markup.elem_ns(
            "rect",
            @markup.svg_ns,
            [
              @markup.attr("x", fmt_double(c.x)),
              @markup.attr("y", fmt_double(cell_top)),
              @markup.attr("width", fmt_double(c.width)),
              @markup.attr("height", fmt_double(c.height)),
              @markup.attr("fill", c.background),
            ],
            [],
          ),
        )
      }
      // §17.4.59 per-side borders. We emit four `<line>` segments
      // rather than a single rect so each side can carry its own
      // colour / width / dash style — matching Word's per-side
      // semantics. Sides with `style="none"` are skipped entirely.
      let cell_top = cell_top_y(c)
      let cx_left = c.x
      let cx_right = c.x + c.width
      let cy_top = cell_top
      let cy_bottom = cell_top + c.height
      append_border_line_nodes(
        out,
        c.border_top,
        cx_left,
        cy_top,
        cx_right,
        cy_top,
      )
      append_border_line_nodes(
        out,
        c.border_bottom,
        cx_left,
        cy_bottom,
        cx_right,
        cy_bottom,
      )
      append_border_line_nodes(
        out,
        c.border_left,
        cx_left,
        cy_top,
        cx_left,
        cy_bottom,
      )
      append_border_line_nodes(
        out,
        c.border_right,
        cx_right,
        cy_top,
        cx_right,
        cy_bottom,
      )
      // Cell paragraphs (already at absolute coordinates).
      for p in c.paragraphs {
        for n in build_paragraph_nodes(p) {
          out.push(n)
        }
      }
    }
  }
  out
}

///|
/// Append the SVG `<line>` node(s) for a `<w:tcBorders>` side to
/// `out`. Skips emission when `side.style == "none"` / `"nil"`.
/// Routes the §17.18.3 ST_Border value through `border_style_kind`
/// which covers every spec value: dash-pattern primitives map to SVG
/// `stroke-dasharray`, multi-stroke variants (`double`, `triple`,
/// `thinThick*`, …) emit multiple parallel `<line>` segments, and
/// art borders (~80 ornamental patterns) emit a `data-ooxml-bdr-art`
/// attribute carrying the spec value plus a plain stroke so the
/// consumer can replace it with a real bitmap.
fn append_border_line_nodes(
  out : Array[@xml.Node],
  side : BorderSide,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
) -> Unit {
  match border_style_kind(side.style) {
    BorderNone => ()
    BorderDouble => {
      // §17.18.3 — Word's "double" is two thin lines separated by
      // a one-pixel gap; the offset steps perpendicular to the
      // line so horizontal and vertical sides keep parity.
      let (ox, oy) = if x1 == x2 { (1.0, 0.0) } else { (0.0, 1.0) }
      out.push(
        single_border_line_node(
          x1 - ox,
          y1 - oy,
          x2 - ox,
          y2 - oy,
          side.color_hex,
          side.width_px / 2.0,
          "",
        ),
      )
      out.push(
        single_border_line_node(
          x1 + ox,
          y1 + oy,
          x2 + ox,
          y2 + oy,
          side.color_hex,
          side.width_px / 2.0,
          "",
        ),
      )
    }
    BorderTriple => {
      // Three parallel hairlines centred on the line.
      let (ox, oy) = if x1 == x2 { (1.5, 0.0) } else { (0.0, 1.5) }
      let third = side.width_px / 3.0
      out.push(
        single_border_line_node(
          x1 - ox,
          y1 - oy,
          x2 - ox,
          y2 - oy,
          side.color_hex,
          third,
          "",
        ),
      )
      out.push(
        single_border_line_node(x1, y1, x2, y2, side.color_hex, third, ""),
      )
      out.push(
        single_border_line_node(
          x1 + ox,
          y1 + oy,
          x2 + ox,
          y2 + oy,
          side.color_hex,
          third,
          "",
        ),
      )
    }
    BorderDashed(dash) =>
      out.push(
        single_border_line_node(
          x1,
          y1,
          x2,
          y2,
          side.color_hex,
          side.width_px,
          dash,
        ),
      )
    BorderArt(name) =>
      // §17.18.3 art borders — surface the spec value as metadata
      // and fall through to a plain stroke so the consumer can
      // replace the line with the real ornamental pattern.
      out.push(
        border_line_node_with_attr(
          x1,
          y1,
          x2,
          y2,
          side.color_hex,
          side.width_px,
          "",
          "data-ooxml-bdr-art",
          name,
        ),
      )
    BorderPlain =>
      out.push(
        single_border_line_node(
          x1,
          y1,
          x2,
          y2,
          side.color_hex,
          side.width_px,
          "",
        ),
      )
  }
}

///|
/// §17.18.3 ST_Border categorisation — every spec value lands in
/// one of: none, double, triple, dashed (with the specific SVG
/// dash-array), art (the ~80 ornamental patterns), or plain (a
/// single solid stroke). Returning a typed variant lets the
/// renderer dispatch exhaustively without a wildcard fallback.
enum BorderStyleKind {
  BorderNone
  BorderDouble
  BorderTriple
  /// Carries the SVG `stroke-dasharray` value.
  BorderDashed(String)
  /// Carries the original spec name for metadata surface.
  BorderArt(String)
  BorderPlain
}

///|
fn border_style_kind(style : String) -> BorderStyleKind {
  match style {
    "none" | "nil" => BorderNone
    "double" => BorderDouble
    "triple" => BorderTriple
    "single" => BorderPlain
    "thick" => BorderPlain
    "wave" =>
      // §17.18.3 wave — SVG cannot express a sine wave on a
      // straight `<line>`; surface as a plain stroke + metadata
      // upstream is handled by the art branch when called.
      BorderDashed("2 2")
    "doubleWave" => BorderDouble
    "dotted" => BorderDashed("1 1")
    "dottedHeavy" => BorderDashed("2 2")
    "dashed" => BorderDashed("4 2")
    "dashedHeavy" => BorderDashed("6 3")
    "dashSmallGap" => BorderDashed("4 1")
    "dashLong" => BorderDashed("8 2")
    "dashLongHeavy" => BorderDashed("10 3")
    "dotDash" => BorderDashed("4 1 1 1")
    "dashDotHeavy" => BorderDashed("6 2 2 2")
    "dotDotDash" => BorderDashed("4 1 1 1 1 1")
    "dashDotDotHeavy" => BorderDashed("6 2 2 2 2 2")
    "dashDotStroked" => BorderDashed("8 2 2 2")
    "thinThickSmallGap"
    | "thickThinSmallGap"
    | "thinThickThinSmallGap"
    | "thinThickMediumGap"
    | "thickThinMediumGap"
    | "thinThickThinMediumGap"
    | "thinThickLargeGap"
    | "thickThinLargeGap"
    | "thinThickThinLargeGap" => BorderDouble
    "threeDEmboss" | "threeDEngrave" | "outset" | "inset" => BorderPlain
    // §17.18.3 art borders — every ornamental pattern surfaces
    // through the `BorderArt` arm with its spec name preserved.
    "apples"
    | "archedScallops"
    | "babyPacifier"
    | "babyRattle"
    | "balloons3Colors"
    | "balloonsHotAir"
    | "basicBlackDashes"
    | "basicBlackDots"
    | "basicBlackSquares"
    | "basicThinLines"
    | "basicWhiteDashes"
    | "basicWhiteDots"
    | "basicWhiteSquares"
    | "basicWideInline"
    | "basicWideMidline"
    | "basicWideOutline"
    | "bats"
    | "birds"
    | "birdsFlight"
    | "cabins"
    | "cakeSlice"
    | "candyCorn"
    | "celticKnotwork"
    | "certificateBanner"
    | "chainLink"
    | "champagneBottle"
    | "checkedBarBlack"
    | "checkedBarColor"
    | "checkered"
    | "christmasTree"
    | "circlesLines"
    | "circlesRectangles"
    | "classicalWave"
    | "clocks"
    | "compass"
    | "confetti"
    | "confettiGrays"
    | "confettiOutline"
    | "confettiStreamers"
    | "confettiWhite"
    | "cornerTriangles"
    | "couponCutoutDashes"
    | "couponCutoutDots"
    | "crazyMaze"
    | "creaturesButterfly"
    | "creaturesFish"
    | "creaturesInsects"
    | "creaturesLadyBug"
    | "crossStitch"
    | "cup"
    | "decoArch"
    | "decoArchColor"
    | "decoBlocks"
    | "diamondsGray"
    | "doubleD"
    | "doubleDiamonds"
    | "earth1"
    | "earth2"
    | "earth3"
    | "eclipsingSquares1"
    | "eclipsingSquares2"
    | "eggsBlack"
    | "fans"
    | "film"
    | "firecrackers"
    | "flowersBlockPrint"
    | "flowersDaisies"
    | "flowersModern1"
    | "flowersModern2"
    | "flowersPansy"
    | "flowersRedRose"
    | "flowersRoses"
    | "flowersTeacup"
    | "flowersTiny"
    | "gems"
    | "gingerbreadMan"
    | "gradient"
    | "handmade1"
    | "handmade2"
    | "heartBalloon"
    | "heartGray"
    | "hearts"
    | "heebieJeebies"
    | "holly"
    | "houseFunky"
    | "hypnotic"
    | "iceCreamCones"
    | "lightBulb"
    | "lightning1"
    | "lightning2"
    | "mapPins"
    | "mapleLeaf"
    | "mapleMuffins"
    | "marquee"
    | "marqueeToothed"
    | "moons"
    | "mosaic"
    | "musicNotes"
    | "northwest"
    | "ovals"
    | "packages"
    | "palmsBlack"
    | "palmsColor"
    | "paperClips"
    | "papyrus"
    | "partyFavor"
    | "partyGlass"
    | "pencils"
    | "people"
    | "peopleHats"
    | "peopleWaving"
    | "pinkPattern"
    | "plaque"
    | "poinsettias"
    | "postageStamp"
    | "pumpkin1"
    | "pushPinNote2"
    | "pushPinNote1"
    | "pyramids"
    | "pyramidsAbove"
    | "quadrants"
    | "rings"
    | "safari"
    | "sawtooth"
    | "sawtoothGray"
    | "scaredCat"
    | "seattle"
    | "semicirclesShape"
    | "shadowedSquares"
    | "sharksTeeth"
    | "shorebirdTracks"
    | "skyrocket"
    | "snowflakeFancy"
    | "snowflakes"
    | "sombrero"
    | "southwest"
    | "stars"
    | "starsBlack"
    | "starsShadowed"
    | "starsTop"
    | "stars3d"
    | "starsTop3d"
    | "starsTraditional3d"
    | "sun"
    | "swirligig"
    | "tornPaper"
    | "tornPaperBlack"
    | "trees"
    | "triangleParty"
    | "triangles"
    | "triangle1"
    | "tribal1"
    | "tribal2"
    | "tribal3"
    | "tribal4"
    | "tribal5"
    | "tribal6"
    | "twistedLines1"
    | "twistedLines2"
    | "vine"
    | "waveline"
    | "weavingAngles"
    | "weavingBraid"
    | "weavingRibbon"
    | "weavingStrips"
    | "whiteFlowers"
    | "woodwork"
    | "xIllusions"
    | "zanyTriangles"
    | "zigZag"
    | "zigZagStitch" => BorderArt(style)
    // Spec violation: unknown / non-listed value. Render as a
    // plain stroke so the rectangle is still visible; consumers
    // see the spec value via metadata when emitted via Art arm.
    _ => BorderPlain
  }
}

///|
/// Variant of `single_border_line_node` that also stamps a custom
/// data attribute on the `<line>` element so the consumer knows
/// which §17.18.3 spec name the underlying border carried.
fn border_line_node_with_attr(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  color : String,
  width_px : Double,
  dash : String,
  attr_name : String,
  attr_value : String,
) -> @xml.Node {
  let stroke = if color.length() == 0 { "currentColor" } else { color }
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("x1", fmt_double(x1)),
    @markup.attr("y1", fmt_double(y1)),
    @markup.attr("x2", fmt_double(x2)),
    @markup.attr("y2", fmt_double(y2)),
    @markup.attr("stroke", stroke),
    @markup.attr("stroke-width", fmt_double(width_px)),
  ]
  if dash.length() > 0 {
    attrs.push(@markup.attr("stroke-dasharray", dash))
  }
  attrs.push(@markup.attr(attr_name, attr_value))
  @markup.elem_ns("line", @markup.svg_ns, attrs, [])
}

///|
/// Build a single `<line>` element with the supplied stroke / dash.
/// Empty `dash` skips the `stroke-dasharray` attribute.
fn single_border_line_node(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  color : String,
  width_px : Double,
  dash : String,
) -> @xml.Node {
  // §17.18.2 — when the resolved colour is empty (i.e. the source
  // declared `w:val="auto"` or omitted `@color`), emit
  // `currentColor` so SVG inherits the parent text colour.
  let stroke = if color.length() == 0 { "currentColor" } else { color }
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("x1", fmt_double(x1)),
    @markup.attr("y1", fmt_double(y1)),
    @markup.attr("x2", fmt_double(x2)),
    @markup.attr("y2", fmt_double(y2)),
    @markup.attr("stroke", stroke),
    @markup.attr("stroke-width", fmt_double(width_px)),
  ]
  if dash.length() > 0 {
    attrs.push(@markup.attr("stroke-dasharray", dash))
  }
  @markup.elem_ns("line", @markup.svg_ns, attrs, [])
}

///|
/// Get the top y of a cell by inspecting its first paragraph's first line.
/// Falls back to 0 if cell has no content.
fn cell_top_y(c : LaidTableCell) -> Double {
  if c.paragraphs.length() == 0 {
    return 0.0
  }
  let first = c.paragraphs[0]
  if first.lines.length() == 0 {
    return 0.0
  }
  // §17.4.42 / §17.4.69 — the cell's content top is padding above
  // the first line's y_top (resolved per-cell from tblCellMar /
  // tcMar).
  first.lines[0].y_top - c.padding.top
}

// =============================================================================
// String / numeric helpers
// =============================================================================

///|
/// Format a Double for SVG output.  Precision contract: three
/// decimal places, trailing zeros trimmed.  ECMA-376 §17.18.36
/// ST_TwipsMeasure stores positions in twentieths of a point
/// (1/1440 inch ≈ 0.0176 mm); the viewer converts to CSS pixels
/// via ×TWIPS_TO_PX (= ×1/15 ≈ 0.0667), so the resulting double
/// always lands well within 3-decimal CSS pixel precision (the
/// smallest representable twip is `1 twip = 0.0667 px`, which
/// fits within 3 decimal places without loss).  Documents
/// authored with sub-twip positions (rare but spec-permissible
/// via §17.6.2 `<w:pgSz>` pixel-exact attributes) survive the
/// 3-decimal cut because the SVG renderer rasterises at 96 dpi
/// anyway; sub-pixel positions are visually identical.
///
/// Pure ASCII output.
fn fmt_double(value : Double) -> String {
  if value == 0.0 {
    return "0"
  }
  // Round to 3 decimals.
  let scaled = (value * 1000.0).round()
  let int_part = (scaled / 1000.0).to_int()
  let frac_scaled = (scaled - int_part.to_double() * 1000.0).to_int()
  let abs_frac = if frac_scaled < 0 { -frac_scaled } else { frac_scaled }
  if abs_frac == 0 {
    return int_part.to_string()
  }
  // Build fractional string with leading zeros and trim trailing zeros.
  let frac_str = pad3(abs_frac)
  let trimmed = trim_trailing_zeros(frac_str)
  if trimmed == "" {
    int_part.to_string()
  } else {
    int_part.to_string() + "." + trimmed
  }
}

///|
fn pad3(n : Int) -> String {
  if n >= 100 {
    n.to_string()
  } else if n >= 10 {
    "0" + n.to_string()
  } else {
    "00" + n.to_string()
  }
}

///|
fn trim_trailing_zeros(s : String) -> String {
  let chars : Array[Char] = []
  for c in s {
    chars.push(c)
  }
  let mut end = chars.length()
  while end > 0 && chars[end - 1] == '0' {
    end = end - 1
  }
  if end == chars.length() {
    s
  } else if end == 0 {
    ""
  } else {
    let b = StringBuilder::new()
    for i in 0..<end {
      b.write_char(chars[i])
    }
    b.to_string()
  }
}

///|
/// Map §17.18.40 ST_HighlightColor enum to an approximate hex value.
/// The spec enumerates 17 values (16 named colours + `none`); each
/// is mapped explicitly. Unknown / spec-violating values return
/// the empty string so the caller suppresses highlight emission
/// rather than forging an arbitrary colour. The previous `_ =>
/// "#ffff00"` (literal yellow) actively misrendered every unknown
/// value as yellow.
fn highlight_name_to_hex(name : String) -> String {
  // §17.18.40 ST_HighlightColor — the highlight palette is the
  // classic VGA 16-colour set, NOT the CSS named-colour table.
  // The "dark" variants are the VGA half-intensity colours
  // (0x80) and the grays are the VGA grays (#808080 / #C0C0C0).
  match name {
    "black" => "#000000"
    "blue" => "#0000ff"
    "cyan" => "#00ffff"
    "green" => "#00ff00"
    "magenta" => "#ff00ff"
    "red" => "#ff0000"
    "yellow" => "#ffff00"
    "white" => "#ffffff"
    "darkBlue" => "#000080"
    "darkCyan" => "#008080"
    "darkGreen" => "#008000"
    "darkMagenta" => "#800080"
    "darkRed" => "#800000"
    "darkYellow" => "#808000"
    "darkGray" => "#808080"
    "lightGray" => "#c0c0c0"
    // §17.18.40 — "none" disables the highlight; the caller's
    // length-check already skips emission when the resolved hex
    // is empty.
    "none" => ""
    // Schema violation: surface as empty so we do not invent a
    // visible colour the source did not request.
    _ => ""
  }
}
