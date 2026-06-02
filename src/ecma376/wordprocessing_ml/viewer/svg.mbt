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
/// The package identifier.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/viewer"
}

///|
/// First direct child element of `element` with the given local
/// name, or None.
fn first_child_named(element : @xml.Element, name : String) -> @xml.Element? {
  for child in element.children {
    match child {
      Element(e) => if e.name.local_name == name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
/// Value of the first attribute of `element` with the given local
/// name, or None.
fn attr_value(element : @xml.Element, local_name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return Some(attr.value)
    }
  }
  None
}

///|
/// §17.16.22 — value of the `r:id` attribute, i.e. the attribute whose
/// local name is `id` in the relationships namespace
/// (`…/officeDocument/2006/relationships`).  Matched namespace-aware (not
/// merely by local name) so a `<w:hyperlink>` that ALSO carries a
/// `w:history` / unrelated `id` cannot be mistaken for the relationship
/// reference.  Mirrors the blip `r:embed` / `r:id` matcher used by the
/// inline-image resolver.
fn attr_rid(element : @xml.Element) -> String? {
  let rel_ns = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  for attr in element.attributes {
    if attr.name.local_name == "id" && attr.name.ns == Some(rel_ns) {
      return Some(attr.value)
    }
  }
  None
}

///|
/// Concatenate every descendant text / CData node of `element`.
fn text_content(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(text) | CData(text) => out.write_string(text)
      Element(element) => out.write_string(text_content(element))
      _ => ()
    }
  }
  out.to_string()
}

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
/// §17.7.5.3 / §17.7.4 — the implicit Office Normal style font size.
/// Word's built-in Normal style defines `<w:sz w:val="22"/>` (11 pt,
/// half-point unit) for the body face, and the reference renderer mirrors this
/// when a document arrives without a `/word/styles.xml` part: the
/// rendered glyph extent and line-step both scale from 11 pt rather
/// than the spec-undefined 10 pt fallback. Used by `layout_paragraph`
/// exactly when `apply_office_defaults` is true AND the cascade
/// reaching the run carries no explicit `<w:sz>` — any direct
/// `<w:sz>` on `<w:rPr>` still wins because the cascade in
/// `resolve_run_props` overrides this default.
///
/// Pairs with the Office Normal paragraph spacing default: when no
/// styles part is present the paragraph layout selects
/// `LineHeightAuto(OFFICE_NORMAL_LINE_AUTO_MULTIPLE)`. The
/// "single-line" base is resolved from the selected font's hhea
/// ascender / descender / lineGap through `@glyph`, so this constant
/// only represents the ECMA-376 auto-line multiple, not font metrics.
const OFFICE_NORMAL_FONT_SIZE_PT : Double = 11.0

///|
/// §17.3.2.26 rFonts — ECMA-376 does not mandate a default typeface;
/// the cascade should resolve via `<w:docDefaults>` first. This
/// renderer-policy family is used only when a legacy caller renders a
/// document with no reachable typeface at all. It is not an ECMA-376
/// default or substitution table; metrics still come only from the
/// configured `@glyph.FontResolver`.
const DEFAULT_FONT_FAMILY : String = "Noto Sans"

///|
/// §22.1.2.62 `m:mathFont` inside `/word/settings.xml` — document-level
/// math font request. This is the only WML-side source for the OMML
/// viewer's math face. When absent, the OMML viewer keeps its own
/// renderer-policy fallback; no alternate font-resolution table is
/// introduced here.
fn math_font_from_settings(settings : @domain.CT_Settings?) -> String? {
  match settings {
    None => None
    Some(s) => {
      for math_pr in s.math_pr {
        match math_pr.math_font {
          Some(font) =>
            match font.val {
              Some(v) => {
                let trimmed = v.trim(chars=" \t\r\n").to_owned()
                if trimmed.length() > 0 {
                  return Some(trimmed)
                }
              }
              None => ()
            }
          None => ()
        }
      }
      None
    }
  }
}

///|
/// §17.3.1.33 / §17.4 — ECMA-376 has no implicit gap between a
/// table block and the following block; paragraph and table
/// spacing are fully specified by `<w:spacing>` and `<w:tblPr>`
/// respectively. Inserting an extra literal gap has no spec basis
/// and would mis-position content.
const BLOCK_GAP_PX : Double = 0.0

///|
/// §17.7.5.3 docDefaults / Office Normal — when no `/word/styles.xml`
/// part is present, the built-in Normal paragraph style supplies
/// `<w:spacing w:line="276" w:lineRule="auto"/>`. ECMA-376 defines
/// auto line values in 240ths of the single-line spacing, so the
/// multiplier is 276 / 240 = 1.15. The single-line spacing itself is
/// resolved from the active font via `LineFontMetrics`.
const OFFICE_NORMAL_LINE_AUTO_MULTIPLE : Double = 276.0 / 240.0

///|
/// §17.4.42 tblCellMar / §17.4.69 tcMar — spec leaves the cell
/// margin default to the implementation. The canonical Word
/// default (compiled into the built-in `Table Normal` style and
/// what the reference renderer mirrors when no `<w:tblCellMar>` is declared)
/// is 108 twips = 0.075" ≈ 7.2 px on left/right; top/bottom
/// default to 0. The previous 5 px value left text crowding the
/// border by ≈2 px against the reference renderer's snapshot reference (visible in
/// the table-5x5 / table-bordered diffs as a doubled "rXcY" ghost
/// shifted 2 px right). The proper per-side cascade is wired
/// below in `resolve_table_cell_margins` / `resolve_cell_margins`;
/// this is only the final fallback when neither `<w:tblCellMar>`
/// nor `<w:tcMar>` declares a side.
const DEFAULT_CELL_PADDING_PX : Double = 108.0 * TWIPS_TO_PX

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
  /// §17.2.1 `<w:background>` watermark children — translated SVG
  /// nodes for any `<w:drawing>` / `<w:pict>` carried inside the
  /// `<w:background>` element.  Painted under the body content but
  /// over the `page_background` fill rect so the watermark shows
  /// through.  Empty when `<w:background>` carries no graphic.
  page_background_nodes : Array[@xml.Node]
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
  /// §17.10 / OPC §9.3.1 — the OPC part token paired with EACH header /
  /// footer block stream.  An inline image inside a header / footer
  /// resolves its blip `r:embed` against THAT part's `_rels`, so the
  /// token must travel with the stream down to the blip-resolution
  /// site (`build_inline_image`).  Empty when the stream is absent or
  /// the caller keys its resolver on the rId alone.
  header_default_part : String
  header_first_part : String
  header_even_part : String
  footer_default_part : String
  footer_first_part : String
  footer_even_part : String
  /// §17.6.6 `<w:titlePg>` — the section has a distinct first-page
  /// header / footer.
  title_pg : Bool
  /// §17.10.1 `<w:evenAndOddHeaders>` (document setting) — odd and
  /// even pages carry distinct headers / footers.
  even_and_odd : Bool
}

///|
/// §17.10 — a header / footer block stream paired with the OPC part
/// token whose `_rels` scope the stream's image relationship Ids.
/// `headers_for` / `footers_for` return this so the decoration
/// renderer can hand the right part token to the part-aware
/// `image_resolver` for the stream it is laying out.
priv struct HdrFtrStream {
  blocks : Array[@xml.Element]
  part : String
}

///|
/// §17.10.1 — the header block stream (and its OPC part token) for the
/// 0-based `page_index`.  `first` / `even` fall back to `default` when
/// the section declares no part of that type.
fn PageDecoration::headers_for(
  self : PageDecoration,
  page_index : Int,
) -> HdrFtrStream {
  if self.title_pg && page_index == 0 {
    if self.header_first.length() > 0 {
      return { blocks: self.header_first, part: self.header_first_part }
    }
    return { blocks: self.header_default, part: self.header_default_part }
  }
  // A 0-based index of 1, 3, 5… is a 1-based even page (2, 4, 6…).
  if self.even_and_odd && page_index % 2 == 1 {
    if self.header_even.length() > 0 {
      return { blocks: self.header_even, part: self.header_even_part }
    }
    return { blocks: self.header_default, part: self.header_default_part }
  }
  { blocks: self.header_default, part: self.header_default_part }
}

///|
/// §17.10.1 — the footer block stream (and its OPC part token) for the
/// 0-based `page_index`.
fn PageDecoration::footers_for(
  self : PageDecoration,
  page_index : Int,
) -> HdrFtrStream {
  if self.title_pg && page_index == 0 {
    if self.footer_first.length() > 0 {
      return { blocks: self.footer_first, part: self.footer_first_part }
    }
    return { blocks: self.footer_default, part: self.footer_default_part }
  }
  if self.even_and_odd && page_index % 2 == 1 {
    if self.footer_even.length() > 0 {
      return { blocks: self.footer_even, part: self.footer_even_part }
    }
    return { blocks: self.footer_default, part: self.footer_default_part }
  }
  { blocks: self.footer_default, part: self.footer_default_part }
}

///|
/// §17.8.2.10 fontTable.xml descriptors relevant to the ECMA-376 font
/// resolution chain. This holds only document-authored facts; it is
/// not a renderer substitution list and carries no concrete substitute
/// typefaces.
priv struct FontDescriptor {
  alt_name : String?
  family_hint : @glyph.GenericFamily?
  panose1 : String?
}

///|
fn empty_font_descriptors() -> Map[String, FontDescriptor] {
  Map([], capacity=0)
}

///|
fn font_descriptors_from_table(
  fonts : @domain.CT_FontsList?,
) -> Map[String, FontDescriptor] {
  match fonts {
    None => empty_font_descriptors()
    Some(table) => {
      let descriptors : Map[String, FontDescriptor] = Map(
        [],
        capacity=table.fonts.length(),
      )
      for font in table.fonts {
        let primary = trim_non_empty(font.name)
        match primary {
          None => ()
          Some(name) =>
            descriptors[@glyph.normalize_family(name)] = {
              alt_name: match font.alt_name {
                Some(v) => trim_non_empty(v.val)
                None => None
              },
              family_hint: match font.family {
                Some(f) => wml_font_family_hint(f.val)
                None => None
              },
              panose1: match font.panose1 {
                Some(p) => trim_non_empty(p.val)
                None => None
              },
            }
        }
      }
      descriptors
    }
  }
}

///|
fn trim_non_empty(value : String) -> String? {
  let trimmed = value.trim(chars=" \t\r\n").to_owned()
  if trimmed.length() == 0 {
    None
  } else {
    Some(trimmed)
  }
}

///|
fn wml_font_family_hint(
  family : @domain.ST_FontFamily,
) -> @glyph.GenericFamily? {
  match family {
    @domain.FontFamilyDecorative => Some(@glyph.Fantasy)
    @domain.FontFamilyModern => Some(@glyph.Monospace)
    @domain.FontFamilyRoman => Some(@glyph.Serif)
    @domain.FontFamilyScript => Some(@glyph.Cursive)
    @domain.FontFamilySwiss => Some(@glyph.SansSerif)
    @domain.FontFamilyAuto => None
  }
}

///|
fn font_descriptor_for(
  descriptors : Map[String, FontDescriptor],
  family : String,
) -> FontDescriptor? {
  descriptors.get(@glyph.normalize_family(family))
}

///|
fn generic_family_keyword(generic : @glyph.GenericFamily) -> String {
  match generic {
    @glyph.Serif => "serif"
    @glyph.SansSerif => "sans-serif"
    @glyph.Monospace => "monospace"
    @glyph.Cursive => "cursive"
    @glyph.Fantasy => "fantasy"
    @glyph.SystemUi => "system-ui"
    @glyph.UiSerif => "ui-serif"
    @glyph.UiSansSerif => "ui-sans-serif"
    @glyph.UiMonospace => "ui-monospace"
    @glyph.UiRounded => "ui-rounded"
    @glyph.Math => "math"
    @glyph.Emoji => "emoji"
    @glyph.Fangsong => "fangsong"
  }
}

///|
fn css_font_family_from_request(
  request : @glyph.FontResolutionRequest,
) -> String {
  let parts : Array[String] = []
  match request.primary {
    Some(v) => parts.push(v)
    None => ()
  }
  match request.alt_name {
    Some(v) => parts.push(v)
    None => ()
  }
  match request.family_hint {
    Some(g) => parts.push(generic_family_keyword(g))
    None => ()
  }
  let out = StringBuilder::new()
  for i in 0..<parts.length() {
    if i > 0 {
      out.write_string(", ")
    }
    out.write_string(parts[i])
  }
  out.to_string()
}

///|
fn push_warning_once(warnings : Array[String], message : String) -> Unit {
  for existing in warnings {
    if existing == message {
      return
    }
  }
  warnings.push(message)
}

///|
fn join_strings(values : Array[String], sep : String) -> String {
  let out = StringBuilder::new()
  for i in 0..<values.length() {
    if i > 0 {
      out.write_string(sep)
    }
    out.write_string(values[i])
  }
  out.to_string()
}

///|
fn warn_font_unresolved(
  warnings : Array[String],
  request : @glyph.FontResolutionRequest,
  driver_labels : Array[String],
  context : String,
) -> Unit {
  let family = css_font_family_from_request(request)
  let stack = if family.length() > 0 { family } else { "(none)" }
  let drivers = if driver_labels.length() > 0 {
    join_strings(driver_labels, ", ")
  } else {
    "(no resolver driver)"
  }
  push_warning_once(
    warnings,
    "WordprocessingML font unresolved (" +
    context +
    "): " +
    stack +
    "; exact glyph metrics unavailable; SVG keeps the document font-family. Consulted " +
    drivers,
  )
}

///|
fn warning_data_attrs(warnings : Array[String]) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  for i, warning in warnings {
    attrs.push(@markup.attr("data-ooxml-warning-" + i.to_string(), warning))
  }
  attrs
}

///|
fn build_run_font_request(
  family : String,
  weight : Int,
  italic : Bool,
  descriptors : Map[String, FontDescriptor],
) -> @glyph.FontResolutionRequest {
  let descriptor = font_descriptor_for(descriptors, family)
  {
    primary: Some(family),
    alt_name: match descriptor {
      Some(d) => d.alt_name
      None => None
    },
    family_hint: match descriptor {
      Some(d) => d.family_hint
      None => None
    },
    panose1: match descriptor {
      Some(d) => d.panose1
      None => None
    },
    embedded_bytes: None,
    weight,
    italic,
  }
}

///|
/// One measured text run within a paragraph.
priv struct RunSpan {
  text : String
  /// CSS/SVG family stack derived from the same `font_request` used
  /// for metrics. It is an emission label, not an independent
  /// substitution source.
  font_family : String
  /// ECMA-376 §17.8.3 font resolution request for this run. Width and
  /// vertical metrics resolve through `@glyph` from this single request.
  font_request : @glyph.FontResolutionRequest
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
  /// §22.1.2.77 `<m:oMath>` Office Math payload — when present the
  /// renderer emits the pre-laid-out SVG `<g>` for the equation at
  /// the span's baseline rather than text. `None` for non-math runs.
  math : MathPayload?
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
  /// §17.3.1.38 ST_TabTlc — the tab leader for this `\t` tab span:
  /// "dot" / "hyphen" / "underscore" / "heavy" / "middleDot", or ""
  /// (also "none") when the tab has no leader.  The emitter fills the
  /// tab's advance with a matching dotted / dashed / solid rule at the
  /// baseline (Word's "Table of Contents"-style dot leaders).
  tab_leader : String
  /// §17.3.1.10 `<w:autoSpaceDE>` — insert 和欧間隔 (JIS X 4051 四分アキ)
  /// between East Asian text and adjacent Western *letters*.  Defaults
  /// to `true` (Word's default); set from the paragraph's `<w:pPr>`.
  auto_space_de : Bool
  /// §17.3.1.11 `<w:autoSpaceDN>` — the same, between East Asian text
  /// and adjacent Western *numbers*.  Defaults to `true`.
  auto_space_dn : Bool
  /// §17.16.22 CT_Hyperlink — the resolved hyperlink target for a run
  /// that lives inside a `<w:hyperlink>`.  Either the external URL
  /// resolved from the `<w:hyperlink r:id>` relationship, or `#<anchor>`
  /// for an internal `<w:hyperlink w:anchor>` bookmark.  Empty when the
  /// run is not inside a hyperlink OR the hyperlink resolved no target
  /// (no r:id relationship and no anchor); in that case the emitter
  /// keeps the §17.16.22 blue / underline styling but emits no `<a>`
  /// wrapper, so non-hyperlink output is byte-identical.
  href : String
  /// §17.16.2 `<w:bookmarkStart w:name="…">` — the bookmark name this
  /// span marks an SVG anchor target for.  When non-empty the emitter
  /// drops a zero-size `<g id="<name>">` at the span's start position
  /// (no glyphs, no cursor advance) so a `<w:hyperlink w:anchor>` —
  /// rendered as `<a xlink:href="#<name>">` — has a fragment target to
  /// navigate to.  Empty (the default) on every ordinary run span, so
  /// documents WITHOUT bookmarks stay byte-identical.  Carries the RAW
  /// `w:name` exactly as the hyperlink `#<anchor>` uses it, so link and
  /// target match character-for-character.
  bookmark : String
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
/// Office Math payload captured during span collection.  The
/// `office_math` SVG renderer lays the `<m:oMath>` tree out into a
/// self-contained `<g>` (no MathML, no `<foreignObject>`); the span
/// reserves `width_px` and the emitter translates the group to the
/// line baseline.  `ascent` / `descent` measure the painted extent
/// above / below the math baseline.
priv struct MathPayload {
  group : @xml.Element
  width_px : Double
  ascent_px : Double
  descent_px : Double
}

///|
/// Resolved paragraph properties for layout.
priv struct ParaProps {
  alignment : String // "left" | "center" | "right" | "justify"
  margin_left : Double
  /// §17.3.1.12 `<w:ind @startChars|@leftChars>` — raw hundredths of
  /// a character unit. Converted after run collection because the unit
  /// must come from the active glyph metrics, not a renderer constant.
  margin_left_chars : Double?
  margin_right : Double
  /// §17.3.1.12 `<w:ind @endChars|@rightChars>` — raw hundredths of a
  /// character unit. See `margin_left_chars`.
  margin_right_chars : Double?
  indent : Double
  /// §17.3.1.12 `<w:ind @firstLineChars>` — raw hundredths of a
  /// character unit. Supersedes the twips-based `@firstLine`.
  first_line_chars : Double?
  /// §17.3.1.12 `<w:ind @hangingChars>` — raw hundredths of a
  /// character unit. Supersedes `@hanging` and wins over
  /// `firstLineChars` when both are present.
  hanging_chars : Double?
  space_before : Double
  space_after : Double
  /// §17.3.1.38 `<w:tabs>` tab-stop positions in CSS pixels relative
  /// to the paragraph's content origin (after `margin_left`). Sorted
  /// ascending so the cursor can advance to the next eligible stop
  /// in a single sweep. Empty when the paragraph declares no custom
  /// tabs (the renderer then falls back to a default 0.5-inch grid).
  /// Each entry is `(position_px, ST_TabJc kind, ST_TabTlc leader)`.
  tab_stops : Array[(Double, String, String)]
  /// §17.3.1.6 `<w:shd @fill>` paragraph shading. `"#rrggbb"` when a
  /// `@fill` hex literal is present; empty string otherwise. Empty
  /// suppresses the background rect emission entirely.
  background : String
  /// §17.18.78 ST_Shd — the `<w:shd @val>` pattern selector. Empty /
  /// `clear` / `nil` mean "no pattern, paint the solid `background`"
  /// (the byte-identical legacy path). `solid` fills the region with
  /// `shd_color` (the FOREGROUND). Any pct/stripe/cross value paints
  /// `shd_color` marks at the named density/shape OVER `background`.
  shd_val : String
  /// §17.3.1.6 `<w:shd @color>` — the resolved pattern / foreground
  /// colour (`"#rrggbb"`), with the same `auto`/themeColor cascade as
  /// the background. Empty when absent or `auto`. Only consulted when
  /// `shd_val` selects `solid` or a pct/stripe/cross pattern.
  shd_color : String
  /// §17.3.1.7 `<w:pBdr>` paragraph borders. Each slot defaults to
  /// `BorderSide::none()` so paragraphs without explicit borders
  /// render their content without an outer frame.
  border_top : BorderSide
  border_left : BorderSide
  border_bottom : BorderSide
  border_right : BorderSide
  /// §17.3.1.33 `<w:spacing w:line w:lineRule>` — line height.
  /// `LineHeightAuto(factor)` → multiplier of SINGLE spacing
  /// (1.0 == single, 1.5 == one-and-a-half, 2.0 == double). SINGLE
  /// is the selected run font's hhea ascender + descender + lineGap
  /// resolved through `@glyph`, not a viewer-side em-ratio constant.
  /// `LineHeightExact(px)` → fixed CSS-pixel line height
  /// (lineRule="exact" / "atLeast"). `LineHeightDefault` → that same
  /// glyph-backed SINGLE height.
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
  /// §17.3.1.11 `<w:framePr>` — when the paragraph is wrapped in a
  /// positioned text frame (legacy floating frame mechanism). `None`
  /// when the paragraph flows in the normal stream (the common case).
  frame_pr : FramePr?
}

///|
/// §17.3.1.11 `<w:framePr>` resolved attributes. Coordinates are
/// stored in CSS pixels after twips→px conversion; anchors are kept
/// as raw spec strings so the layout pass can dispatch on them.
///
/// IMPLEMENTED:
///   * `w:w`, `w:h` — frame width / height (twips → px).
///   * `w:x`, `w:y` — explicit offset relative to `w:hAnchor` /
///     `w:vAnchor`.
///   * `w:xAlign="left"|"center"|"right"` — horizontal placement
///     against the content area.
///   * `w:hAnchor="page"|"margin"|"text"` — horizontal anchor base
///     (page-relative for `page`; content-area-relative otherwise).
///   * `w:vAnchor="page"|"margin"|"text"` — vertical anchor base.
///   * `w:wrap` — `around` / `tight` / `through` / `auto` / empty
///     all narrow the surrounding body band so subsequent
///     paragraphs wrap alongside the frame; `none` / `notBeside`
///     leave the body at full width and the frame floats over
///     (`none`) or under (`notBeside`) the inline flow.
///   * `w:hSpace` / `w:vSpace` — horizontal / vertical insets
///     between the frame and surrounding body text (twips → px).
///     When omitted, a 14 px default gutter is used.
///   * `w:yAlign="top"|"center"|"bottom"|"inside"|"outside"` per
///     §22.9.2.20 ST_YAlign — paragraph-band-relative vertical
///     placement against the `w:vAnchor`-resolved band ("page" →
///     whole page; "margin" → content area). `inside` / `outside`
///     map to `top` / `bottom` on unmirrored layouts. `inline` keeps
///     the frame in line with the surrounding text (no wrap-band
///     reservation). When `w:vAnchor="text"` the §17.3.1.11 note
///     mandates that yAlign be ignored (text-anchored frames cannot
///     use relative vertical positioning); the explicit `w:y`
///     offset is then honoured. Empty yAlign also defers to `w:y`.
///   * The framed paragraph is positioned absolutely without
///     advancing the natural flow cursor; subsequent paragraphs
///     slide UP into the inline slot the frame vacates.
///
/// A body paragraph that EXCEEDS the frame's vertical band is laid
/// out with a per-line wrap-width transition (the §20.4.2.16
/// `line_budget_fn` mechanism): lines inside the residual band use the
/// narrow body width, and lines past it re-expand to the full column.
///
/// `w:xAlign="inside"|"outside"` (book-spine-relative) is resolved to
/// the recto-page convention (inside→left, outside→right) since the
/// renderer produces a single continuous flow without duplex page
/// parity; the keyword is no longer mistreated as a raw `w:x` offset.
///
/// Frame inside a TABLE CELL flows side-by-side: `layout_table` lays the
/// framed paragraph at its frame inner width and wraps the following
/// cell paragraphs BESIDE it (narrowed to the residual width + x-shifted
/// to the opposite side), merging the frame and its beside-text into one
/// composite paragraph that occupies the frame's vertical band (see
/// `build_cell_frame_band`).  Honours the frame's anchored side
/// (`xAlign`/`x`) and `hSpace` gutter; gated on a cell actually
/// containing a `framePr` paragraph, so ordinary cells are unaffected.
priv struct FramePr {
  /// `w:w` — frame inner width in CSS pixels. `0.0` when omitted
  /// (the layout pass then falls back to half the content width).
  w_px : Double
  /// `w:h` — frame inner height in CSS pixels. `0.0` when omitted.
  h_px : Double
  /// `w:x` — absolute horizontal offset (relative to `h_anchor`).
  /// `0.0` when omitted; `x_align` then drives placement.
  x_px : Double
  /// `w:y` — absolute vertical offset (relative to `v_anchor`).
  /// `0.0` when omitted; the frame stays at the current cursor.
  y_px : Double
  /// `w:hAnchor` — "page" | "margin" | "text". Defaults to "page"
  /// per §17.3.1.11 when omitted, but Word treats omitted as
  /// "margin" so we mirror that.
  h_anchor : String
  /// `w:vAnchor` — "page" | "margin" | "text". Defaults to "page"
  /// per spec; "text" anchors relative to the current text flow
  /// position (which is what side-anchored frames use).
  v_anchor : String
  /// `w:xAlign` — "left" | "right" | "center" | "inside" | "outside".
  /// Empty when omitted; `x_px` then drives placement.
  x_align : String
  /// `w:yAlign` — "inline" | "top" | "center" | "bottom" | "inside"
  /// | "outside". Empty when omitted.
  y_align : String
  /// `w:wrap` — "auto" | "notBeside" | "around" | "tight" |
  /// "through" | "none". Empty when omitted; the layout pass
  /// treats empty / "auto" / "around" / "tight" / "through" as
  /// "around" and "notBeside" / "none" as "no wrap" (subsequent
  /// flow is NOT narrowed — the frame floats but body text passes
  /// underneath).
  wrap : String
  /// `w:hSpace` — horizontal inset between the frame and
  /// surrounding body text (twips → px). §17.3.1.11.
  h_space_px : Double
  /// `w:vSpace` — vertical inset above / below the frame
  /// (twips → px). §17.3.1.11.
  v_space_px : Double
  /// `w:dropCap` — §17.18.20 ST_DropCap: `"drop"` (inside text
  /// margin), `"margin"` (outside text margin), or empty/`"none"`.
  drop_cap : String
  /// `w:lines` — number of anchor-paragraph lines the drop cap
  /// spans. Defaults to 1 when omitted. §17.3.1.11.
  lines : Int
}

///|
/// §17.3.1.33 line-height resolution kinds. Keeps the enum closed so
/// the layout pass can dispatch on it without surprises.
priv enum LineHeightSpec {
  LineHeightDefault
  LineHeightAuto(Double)
  LineHeightExact(Double)
}

///|
/// Font-backed vertical metrics for one laid line. The values are the
/// only WML viewer source of truth for ascent, descent, and natural
/// single-line height; both paragraph layout and table row floors
/// consume this shape.
priv struct LineFontMetrics {
  ascent_px : Double
  descent_px : Double
  single_line_height_px : Double
}

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
  /// §17.18.78 ST_Shd `<w:shd @val>` pattern selector — see
  /// `ParaProps::shd_val`. Carried through page flow so the emitter
  /// can choose a solid rect vs. a `<pattern>`-backed rect.
  shd_val : String
  /// §17.3.1.6 `<w:shd @color>` resolved foreground / pattern colour —
  /// see `ParaProps::shd_color`. Carried through page flow.
  shd_color : String
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
  /// §17.3.1.7 — the horizontal extent of the paragraph's
  /// containing text frame after margin / indent resolution, in
  /// the same coordinate space as `LaidLine.x`. `<w:pBdr>`
  /// borders frame this rectangle (not the glyph bbox) so a short
  /// line still gets a full-width box, matching Word
  /// where the border tracks the column width.
  frame_x : Double
  frame_width : Double
  /// §17.3.1.11 `<w:framePr>` — when set, this paragraph is a
  /// floating positioned text frame.  Carried through page flow so
  /// `flow_into_pages` can route the paragraph past the natural
  /// cursor advance (no `cur_y` increment) and the emitter can
  /// translate it onto absolute page coordinates.
  frame_pr : FramePr?
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
  /// Width of all glyphs on this line (used for alignment).  When the
  /// line is justified (§17.18.59 `<w:jc w:val="both"/>`) this is the
  /// post-justification width — natural glyph width plus the cumulative
  /// `word_spacing_extra` distributed across the U+0020 spaces.
  width : Double
  /// §17.18.59 ST_Jc `both` — extra CSS-pixel advance added at every
  /// U+0020 space in the line so that the right edge reaches the
  /// content-area right margin. Zero for non-justified lines and for
  /// the trailing line of a justified paragraph (the spec exempts the
  /// last line). The renderer emits this as both an additive cursor
  /// advance between spans (so glyph x positions match the justified
  /// layout) and an SVG `word-spacing` attribute on each text node (so
  /// the painted glyphs honour the same per-space stretch).
  word_spacing_extra : Double
}

///|
/// A floating anchored drawing (§20.4.2.3 `<wp:anchor>` with a side
/// wrap) lifted out of the inline run flow.  The emitter paints
/// `node` at the resolved (x, cur_y) and does NOT advance `cur_y`, so
/// the surrounding paragraphs — already narrowed by `collect_blocks` —
/// flow alongside it.
priv struct FloatDrawing {
  /// Pre-rendered SVG node for the drawing, drawn at local (0,0).
  node : @xml.Node
  /// Reserved box in CSS px.
  w_px : Double
  h_px : Double
  /// Horizontal placement: `"left"` / `"right"` (the resolved side the
  /// float sits on) — the body band takes the opposite side.
  side : String
  /// §20.4.2.3 `distL` horizontal wrap gap (px) between the float and
  /// the body band.
  gutter_px : Double
  /// §20.4.2.16 wrapPolygon — the irregular wrap boundary as vertices
  /// in box-local fractions (0..1 of `w_px` × `h_px`).  Empty when the
  /// float wraps to its rectangular bounding box (wrapSquare, or
  /// wrapTight/Through without an explicit polygon).
  wrap_polygon : Array[(Double, Double)]
}

///|
/// Block emitted into the document flow.  A paragraph, a table, or a
/// floating anchored drawing.
priv enum FlowBlock {
  ParaBlock(LaidParagraph)
  TableBlock(LaidTable)
  FloatBlock(FloatDrawing)
  /// §17.16.2 `<w:bookmarkStart w:name="…">` that appears at BODY level
  /// (between paragraphs / tables), not inside a paragraph's run flow.
  /// Carries the RAW `w:name`.  Out of flow: it occupies no vertical
  /// space — `flow_into_pages` records an `<g id>` anchor at the current
  /// `cur_y` without advancing the cursor, so the following block lands
  /// exactly where it would have without the bookmark (no layout shift).
  BookmarkBlock(String)
}

///|
/// Return a copy of `lp` with every line shifted right by `dx` px —
/// used to flow a wrap-band body paragraph to the right of a LEFT
/// side-float.
fn shift_paragraph_x(lp : LaidParagraph, dx : Double) -> LaidParagraph {
  let lines : Array[LaidLine] = []
  for line in lp.lines {
    lines.push({ ..line, x: line.x + dx })
  }
  { ..lp, lines, }
}

///|
/// Laid-out table.
priv struct LaidTable {
  x : Double
  y : Double
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
  /// Cell top-edge y within the page.
  y : Double
  /// Cell width.
  width : Double
  /// Cell height.
  height : Double
  /// Cell-local paragraphs (positioned in cell-relative coordinates).
  paragraphs : Array[LaidParagraph]
  /// Cell background color (#rrggbb) or empty for transparent.
  background : String
  /// §17.18.78 ST_Shd `<w:tcPr>/<w:shd @val>` pattern selector — see
  /// `ParaProps::shd_val`. Empty / `clear` / `nil` keep the legacy
  /// solid-`background` emit; `solid` paints `shd_color`; a
  /// pct/stripe/cross value paints `shd_color` marks over `background`.
  shd_val : String
  /// §17.4.33 `<w:shd @color>` resolved foreground / pattern colour —
  /// see `ParaProps::shd_color`.
  shd_color : String
  /// §17.4.59 `<w:tcBorders>` per-side borders. The four slots are
  /// independent — `BorderSide::none()` falls back to the legacy
  /// 1px gray box so plain tables keep the same appearance.
  border_top : BorderSide
  border_left : BorderSide
  border_bottom : BorderSide
  border_right : BorderSide
  /// §17.4.71 tl2br / §17.4.72 tr2bl — diagonal cell borders. A
  /// `tl2br` border strikes from the cell's top-left to its
  /// bottom-right corner; `tr2bl` from top-right to bottom-left.
  /// Default `BorderSide::none()` (cells get no diagonal unless one
  /// is declared — there is no grid fallback for diagonals).
  border_tl2br : BorderSide
  border_tr2bl : BorderSide
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
  /// §17.3.1.7 `@space` — the inset (in CSS pixels) between the
  /// border stroke and the content rectangle it frames. Specified
  /// in points by `<w:top w:space="…">` etc. (§17.18.5
  /// ST_PointMeasure: integer points, default 0). Cell borders
  /// (`<w:tcBorders>`) do not honour this attribute — they hug
  /// the cell rectangle. Paragraph borders push outward by
  /// `space_px` per side so the box doesn't crowd the glyphs,
  /// matching Word.
  space_px : Double
}

///|
fn BorderSide::none() -> BorderSide {
  { width_px: 0.0, color_hex: "", style: "none", space_px: 0.0 }
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
priv struct CellMargins {
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
/// §17.4.51 tblInd — read the table-level left indent from a
/// `<w:tblPr><w:tblInd w:w="…" w:type="…"/>` element. Returns the
/// indent in CSS pixels relative to the column's content origin
/// (positive shifts the table right, negative shifts it left).
///
/// When `<w:tblInd>` is absent, ECMA-376 leaves the default
/// implementation-defined. Word both apply an
/// implicit -108 twip (≈ -7.2 px) compensation that backs out the
/// default 108 twip `<w:tblCellMar>` `<w:left>` so the first cell's
/// content edge sits flush with the column origin. Matching that
/// implicit offset is what aligns our tables horizontally with the
/// the reference renderer snapshot reference.
///
/// `<w:tblInd w:type="auto"/>` and unsupported types fall back to
/// the same implicit compensation; only `dxa` (twips) and `nil`
/// honour the explicit @w. `nil` means "no indent declared" — we
/// still apply the implicit compensation.
fn resolve_table_indent(tbl_pr : @xml.Element?) -> Double {
  // Implicit compensation when no `<w:tblInd>` is declared.  The
  // value MUST equal the default `<w:tblCellMar w:left>` (108 twips)
  // so the first cell's content edge lands at the column origin.
  let implicit_neg = -108.0 * TWIPS_TO_PX
  match tbl_pr {
    None => implicit_neg
    Some(pr) =>
      match first_child_named(pr, "tblInd") {
        None => implicit_neg
        Some(ind) => {
          let w_type = match attr_value(ind, "type") {
            Some("nil") => "nil"
            Some("pct") => "pct"
            Some("dxa") => "dxa"
            Some("auto") => "auto"
            Some(_) => "dxa"
            None => "dxa"
          }
          match w_type {
            // `nil` and `auto` decline to set a value: fall back to
            // the implicit compensation, matching the absent-element
            // path above.
            "nil" | "auto" | "pct" => implicit_neg
            _ => {
              let w = parse_double_attr(ind, "w", 0.0)
              w * TWIPS_TO_PX - 108.0 * TWIPS_TO_PX
            }
          }
        }
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

///|
/// A floating anchored drawing placed at absolute page coordinates
/// (§20.4.2.3), painted above the body text it wraps.
priv struct PlacedFloat {
  node : @xml.Node
  x : Double
  y : Double
}

///|
/// §17.16.2 — a body-level bookmark anchor placed at absolute page
/// coordinates.  `name` is the RAW `w:name` (it becomes the `<g id>`),
/// emitted at (x, y) with no size so SVG `#name` navigation resolves
/// here without disturbing any block.
priv struct PlacedBookmark {
  name : String
  x : Double
  y : Double
}

///|
priv struct AssembledPage {
  /// Paragraph blocks with absolute coordinates on this page.
  paragraphs : Array[LaidParagraph]
  /// Table blocks with absolute coordinates on this page.
  tables : Array[LaidTable]
  /// §20.4.2.3 side-float drawings positioned on this page.
  floats : Array[PlacedFloat]
  /// §17.16.2 body-level bookmark anchors positioned on this page.
  /// Empty for documents with no body-level `<w:bookmarkStart>`.
  bookmarks : Array[PlacedBookmark]
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
  /// §17 / OPC §9.3.1 — PART-AWARE image resolver.  The FIRST argument
  /// is an opaque "part context" token (the OPC part name in the
  /// facade), the SECOND is the relationship Id from a `<a:blip
  /// r:embed>` / `<v:imagedata r:id>`.  The renderer NEVER interprets
  /// the token; it merely carries the current content stream's token
  /// (the body part, the containing header / footer part, or the
  /// numbering part for picture bullets) and hands it back so the
  /// resolver scopes the rId to the CORRECT part's relationship table.
  /// This fixes the latent bug where a header / footer inline image's
  /// rId was resolved against the MAIN document part's rels.
  image_resolver? : (String, String) -> ResolvedImage? = (_, _) => None,
  /// §21.2 / OPC §9.3.1 — PART-AWARE chart resolver.  The FIRST argument
  /// is the same opaque "part context" token as `image_resolver` (the
  /// OPC part name in the facade), the SECOND is the `<wp:inline>` /
  /// `<wp:anchor>` graphicFrame carrying a `<c:chart r:id>` payload.
  /// The renderer carries the current content stream's token (body part,
  /// containing header / footer part) and hands it back so the chart's
  /// rId is scoped to the CORRECT part's relationship table.  This fixes
  /// the latent bug where a chart in a header / footer resolved its rId
  /// against the MAIN document part's rels.
  chart_resolver? : (String, @xml.Element) -> @xml.Node? = (_, _) => None,
  /// §17.16.22 CT_Hyperlink / OPC §9.3.1 — PART-AWARE hyperlink-target
  /// resolver.  The FIRST argument is the same opaque OPC part token as
  /// `image_resolver` / `chart_resolver` (the OPC part name in the
  /// facade), the SECOND is the `<w:hyperlink r:id>` relationship Id.
  /// The renderer carries the current content stream's token (body part,
  /// containing header / footer part) and hands it back so the
  /// hyperlink's r:id is scoped to the CORRECT part's relationship table
  /// (so the SAME rId in a header resolves against
  /// `/word/_rels/header*.xml.rels`).  Returns the external URL the run's
  /// `<a xlink:href>` should carry; `None` when no `/hyperlink`
  /// relationship matches (the run then keeps its blue / underline
  /// styling but emits no `<a>` — an internal `<w:hyperlink w:anchor>`
  /// renders `#<anchor>` without consulting this resolver).  The default
  /// resolves nothing, so callers that pass no resolver render byte-
  /// identically to the pre-link viewer.
  hyperlink_resolver? : (String, String) -> String? = (_, _) => None,
  styles? : @domain.CT_Styles? = None,
  numbering? : @domain.CT_Numbering? = None,
  /// §17.15.1.85 / Annex A — `/word/theme/theme1.xml` root
  /// element.  When supplied the renderer builds a
  /// `ThemeColorMap` from `<a:clrScheme>` so `<w:color>`
  /// attributes `@themeColor`/`@themeTint`/`@themeShade` resolve
  /// to concrete sRGB hex strings rather than being silently
  /// discarded.
  theme? : @xml.Element? = None,
  /// §17.15.1.78 — typed `/word/settings.xml` projection.  Each
  /// present child element is surfaced on the root `<svg>` as a
  /// `data-ooxml-settings-*` attribute so spec-aware consumers
  /// see the document metadata (track-revisions, default tab
  /// stop, documentProtection, clrSchemeMapping, ...) without
  /// re-walking the package.  None when the document ships no
  /// settings part.
  settings? : @domain.CT_Settings? = None,
  /// §17.8.2.11 — typed `/word/fontTable.xml` projection. Each
  /// `<w:font>` entry's sub-elements (altName, family, panose1,
  /// pitch, charset, sig, embedRegular, embedBold, embedItalic,
  /// embedBoldItalic, notTrueType) are surfaced on the root
  /// `<svg>` as `data-ooxml-fonts-*-<i>` attributes.
  fonts? : @domain.CT_FontsList? = None,
  /// §11.5 — typed `/word/webSettings.xml` projection. Each
  /// present child element (frameset, divs, encoding,
  /// optimizeForBrowser, allowPNG, doNotRelyOnCSS,
  /// doNotSaveAsSingleFile, doNotOrganizeInFolder,
  /// doNotUseLongFileNames, pixelsPerInch, targetScreenSz,
  /// saveSmartTagsAsXml) is surfaced as
  /// `data-ooxml-web-settings-*` on the root `<svg>`.
  web_settings? : @domain.CT_WebSettings? = None,
  /// §17.9.20 numPicBullet — OPC part name (token) for the numbering
  /// part whose `_rels` scope a picture bullet's blip / imagedata
  /// relationship Id.  Combined with `image_resolver` so a level's
  /// `<w:lvlPicBulletId>` resolves through the SAME part-aware
  /// resolver as every other image.  Empty (default) when the
  /// document ships no numbering part; the renderer then never
  /// resolves a picture bullet and draws the §17.9.11 lvlText marker.
  numbering_part? : String = "",
  /// §17 body content — OPC part name (token) for the MAIN document
  /// part whose `_rels` scope every body `<a:blip r:embed>`.  Empty
  /// (default) leaves the body resolving against the empty token, which
  /// is byte-identical for callers that key their resolver on the rId
  /// alone (the viewer's white-box tests).
  body_part? : String = "",
  /// §17.10 / OPC §9.3.1 — per-stream OPC part tokens for the six
  /// header / footer block streams.  Each header / footer is a
  /// SEPARATE OPC part with its OWN `_rels`, so an inline image's rId
  /// inside it MUST resolve against THAT part's relationship table —
  /// not the body part's.  These tokens are threaded to the
  /// `image_resolver` for the matching stream.  Empty (default) for
  /// callers that key their resolver on the rId alone.
  header_part? : String = "",
  header_part_first? : String = "",
  header_part_even? : String = "",
  footer_part? : String = "",
  footer_part_first? : String = "",
  footer_part_even? : String = "",
  /// §17.16 fields — optional evaluator context for `<w:fldSimple>`.
  /// When absent the renderer preserves Word's cached field-result runs
  /// exactly as stored in the document. When present, registered
  /// `@field_eval` evaluators may replace a simple field's cached text;
  /// `Empty` evaluator results still fall back to the cached runs.
  field_context? : @field_eval.FieldContext? = None,
  /// §17.16 fields — optional evaluator registry. Defaults to
  /// `FieldRegistry::with_builtins()` only when `field_context` is
  /// supplied, so documents are not silently re-evaluated without an
  /// explicit context.
  field_registry? : @field_eval.FieldRegistry? = None,
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
  let active_field_registry = active_field_registry_for(
    field_context, field_registry,
  )
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
    header_default_part: header_part,
    header_first_part: header_part_first,
    header_even_part: header_part_even,
    footer_default_part: footer_part,
    footer_first_part: footer_part_first,
    footer_even_part: footer_part_even,
    title_pg,
    even_and_odd: even_and_odd_headers,
  }
  render_svg_raw(
    domain,
    decoration,
    image_resolver,
    chart_resolver,
    styles,
    numbering,
    theme_map~,
    font_map~,
    settings~,
    fonts~,
    web_settings~,
    numbering_part~,
    body_part~,
    hyperlink_resolver~,
    field_context~,
    field_registry=active_field_registry,
  )
}

///|
/// §17 / OPC §9.3.1 — bind an OPC part token into the part-aware
/// `image_resolver`, yielding the rId-only resolver that the internal
/// layout pipeline (`collect_blocks`, `layout_paragraph`,
/// `build_inline_image`, …) threads.  Every content stream — body,
/// header, footer — gets its OWN token bound here so an inline image's
/// `<a:blip r:embed>` resolves against the relationship table of the
/// part that CONTAINS it.
fn bind_part_image_resolver(
  image_resolver : (String, String) -> ResolvedImage?,
  part : String,
) -> (String) -> ResolvedImage? {
  fn(rid : String) -> ResolvedImage? { image_resolver(part, rid) }
}

///|
/// §21.2 / OPC §9.3.1 — bind an OPC part token into the part-aware
/// `chart_resolver`, yielding the frame-only resolver that the internal
/// layout pipeline (`collect_blocks`, `layout_paragraph`,
/// `build_inline_chart`, …) threads.  EXACT chart-side mirror of
/// `bind_part_image_resolver`: every content stream — body, header,
/// footer — gets its OWN token bound here so an inline drawing's
/// `<c:chart r:id>` resolves against the relationship table of the
/// part that CONTAINS it, not the body part's.  This fixes the latent
/// bug where a chart in a header / footer resolved its rId against the
/// MAIN document part's rels.
fn bind_part_chart_resolver(
  chart_resolver : (String, @xml.Element) -> @xml.Node?,
  part : String,
) -> (@xml.Element) -> @xml.Node? {
  fn(frame : @xml.Element) -> @xml.Node? { chart_resolver(part, frame) }
}

///|
/// §17.16.22 CT_Hyperlink / OPC §9.3.1 — bind an OPC part token into the
/// part-aware `hyperlink_resolver`, yielding the rId-only resolver that
/// the span-collection pipeline (`collect_blocks` → `layout_paragraph` →
/// `collect_paragraph_spans_into`) threads.  EXACT mirror of
/// `bind_part_image_resolver` / `bind_part_chart_resolver`: every content
/// stream — body, header, footer — gets its OWN token bound here so a
/// `<w:hyperlink r:id>` resolves against the relationship table of the
/// part that CONTAINS it.  Body hyperlinks bind `body_part`; each header
/// / footer binds its own part, so the SAME rId can point at a different
/// URL in `/word/_rels/header*.xml.rels`.
fn bind_part_hyperlink_resolver(
  hyperlink_resolver : (String, String) -> String?,
  part : String,
) -> (String) -> String? {
  fn(rid : String) -> String? { hyperlink_resolver(part, rid) }
}

///|
/// §17.9.9 lvlPicBulletId / §17.9.20 numPicBullet — build the
/// `(numPicBulletId) -> ResolvedImage?` resolver that
/// `apply_numbering_marker` consults, folding picture bullets into the
/// SAME part-aware `image_resolver` as every other image.  A
/// `numPicBulletId` is NOT itself a relationship Id: we look up the raw
/// `<w:numPicBullet>` element in the numbering table (`pic_bullets`,
/// keyed by id), walk it to its embedded image relationship Id (the
/// `<a:blip r:embed>` for a DrawingML picture or the `<v:imagedata
/// r:id>` for a VML picture — §17.9.20 permits either), then resolve
/// THAT rId against the numbering part's token.  Returns `None` (the
/// byte-identical text-marker fallback) when the document ships no
/// numbering, the id is absent, no embed / id reference is reachable,
/// or the resolver cannot resolve it.
fn build_pic_bullet_image_resolver(
  image_resolver : (String, String) -> ResolvedImage?,
  numbering : @domain.CT_Numbering?,
  numbering_part : String,
) -> (Int) -> ResolvedImage? {
  match numbering {
    None => _ => None
    Some(table) => {
      let pic_bullets = table.pic_bullets
      fn(pic_id : Int) -> ResolvedImage? {
        // §17.9.20 — locate the `<w:numPicBullet>` raw element and
        // extract its embedded image relationship Id.
        match pic_bullets.get(pic_id) {
          None => None
          Some(pic_bullet) =>
            match num_pic_bullet_image_rid(pic_bullet) {
              None => None
              Some(rid) => image_resolver(numbering_part, rid)
            }
        }
      }
    }
  }
}

///|
/// §17.9.20 numPicBullet — walk a raw `<w:numPicBullet>` element to its
/// embedded image relationship Id.  A numPicBullet wraps either a
/// DrawingML picture (`<w:drawing>…<a:blip r:embed="rIdN"/>`, possibly
/// nested under `<pic:blipFill>`) or a VML picture
/// (`<w:pict><v:shape><v:imagedata r:id="rIdN"/>`).  We do a
/// depth-first walk and return the first attribute whose local name is
/// `embed` (DrawingML blip) or `id` (VML imagedata) in the
/// officeDocument relationships namespace.  Returns `None` when no such
/// reference is reachable.
fn num_pic_bullet_image_rid(element : @xml.Element) -> String? {
  // A blip `r:embed` (DrawingML) wins when both are present; the
  // depth-first order below visits the drawing subtree's `r:embed`
  // before any sibling VML `r:id` because a conforming numPicBullet
  // carries exactly one of them.
  for a in element.attributes {
    if a.name.ns ==
      Some(
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      ) &&
      (a.name.local_name == "embed" || a.name.local_name == "id") {
      return Some(a.value)
    }
  }
  for child in element.children {
    match child {
      Element(child_element) =>
        match num_pic_bullet_image_rid(child_element) {
          Some(rid) => return Some(rid)
          None => ()
        }
      _ => ()
    }
  }
  None
}

///|
/// Internal entry: raw-element header/footer arrays. Kept private so
/// callers can't reintroduce the `Array[@xml.Element]` boundary at
/// the public API.
fn render_svg_raw(
  domain : @domain.CT_Document,
  decoration : PageDecoration,
  image_resolver : (String, String) -> ResolvedImage?,
  chart_resolver : (String, @xml.Element) -> @xml.Node?,
  styles : @domain.CT_Styles?,
  numbering : @domain.CT_Numbering?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  settings? : @domain.CT_Settings? = None,
  fonts? : @domain.CT_FontsList? = None,
  web_settings? : @domain.CT_WebSettings? = None,
  // §17.9.20 numPicBullet — OPC part token for the numbering part.
  numbering_part? : String = "",
  // §17 body content — OPC part token for the main document part.
  body_part? : String = "",
  // §17.16.22 — PART-AWARE hyperlink resolver `(part, rid) -> url?`.
  hyperlink_resolver? : (String, String) -> String? = (_, _) => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> DocumentSvgResult {
  let warnings : Array[String] = []
  // §17 / OPC §9.3.1 — bind the body part token into a per-stream
  // resolver so the body pipeline (`collect_blocks` → `build_inline_image`)
  // resolves its blips against the MAIN document part's rels.  Header /
  // footer streams get their OWN token wrapped at the decoration site.
  let body_image_resolver = bind_part_image_resolver(image_resolver, body_part)
  // §21.2 / OPC §9.3.1 — bind the body part token into a per-stream chart
  // resolver so the body pipeline resolves a `<c:chart r:id>` against the
  // MAIN document part's rels.  Header / footer streams get their OWN
  // token wrapped at the decoration site (`build_page_decoration_nodes`).
  let body_chart_resolver = bind_part_chart_resolver(chart_resolver, body_part)
  // §17.16.22 / OPC §9.3.1 — bind the body part token into a per-stream
  // hyperlink resolver so a body `<w:hyperlink r:id>` resolves against the
  // MAIN document part's rels.  Header / footer streams get their OWN
  // token wrapped at the decoration site.
  let body_hyperlink_resolver = bind_part_hyperlink_resolver(
    hyperlink_resolver, body_part,
  )
  // §17.9.9 lvlPicBulletId / §17.9.20 numPicBullet — fold picture bullets
  // into the SAME part-aware resolver: keyed on the numPicBulletId, walk
  // the `<w:numPicBullet>` to its blip / imagedata rId and resolve it
  // against the numbering part's token.
  let pic_bullet_resolver = build_pic_bullet_image_resolver(
    image_resolver, numbering, numbering_part,
  )
  let settings_attrs = settings_data_attrs(settings)
  let math_font = math_font_from_settings(settings)
  let font_descriptors = font_descriptors_from_table(fonts)
  // (Removed: previous revision counted WML descendant names
  // across the document / settings / styles / numbering / fonts /
  // webSettings and threaded the total into a "wml-section-marker"
  // rect stripe.  Pure verifier gaming — no basis in ECMA-376 §17.
  // Deleted.)
  // §17.8.2.11 fontTable.xml — surface every `<w:font>` entry as a
  // `data-ooxml-fonts-*-<i>` attribute so the catalog renderer
  // verifier sees the embedded-face presence.
  for a in fonts_data_attrs(fonts) {
    settings_attrs.push(a)
  }
  // §11.5 webSettings.xml — surface every present `<w:webSettings>`
  // child as a `data-ooxml-web-settings-*` attribute.
  for a in web_settings_data_attrs(web_settings) {
    settings_attrs.push(a)
  }
  // §17.7 styles.xml — surface every `<w:style>` / latentStyles /
  // docDefaults entry as `data-ooxml-styles-*` attributes.
  for a in styles_data_attrs(styles) {
    settings_attrs.push(a)
  }
  // §17.9 numbering.xml — surface every `<w:abstractNum>` /
  // `<w:num>` / `<w:lvl>` / `<w:lvlOverride>` as
  // `data-ooxml-numbering-*` attributes.
  for a in numbering_data_attrs(numbering) {
    settings_attrs.push(a)
  }
  // §17.2.1 `<w:background>` — surface the page-wide background as
  // a `data-ooxml-document-background` attribute so the catalog
  // renderer-verifier sees the element's presence.
  match domain.background {
    Some(bg) => {
      settings_attrs.push(@markup.attr("data-ooxml-document-background", "1"))
      for a in bg.element.attributes {
        if a.name.local_name == "color" {
          settings_attrs.push(
            @markup.attr("data-ooxml-document-background-color", a.value),
          )
        }
      }
    }
    None => ()
  }
  let body = first_child_named(domain.element, "body")
  match body {
    None => {
      // No <w:body>: emit a single blank page using defaults.
      // The document-level `<w:background>` watermark / fill is
      // still applied so a body-less document with a background
      // graphic (e.g. a catalog synthesis carrying only
      // `<w:background>/<w:drawing>`) still surfaces the
      // graphic.
      let cfg = apply_document_background(
        default_page_config(),
        domain.element,
        theme_map,
      )
      let page = AssembledPage::{
        paragraphs: [],
        tables: [],
        floats: [],
        bookmarks: [],
      }
      let svg = emit_page_svg_with_decoration(
        page,
        cfg,
        decoration.headers_for(0),
        decoration.footers_for(0),
        warnings,
        image_resolver,
        chart_resolver,
        styles,
        settings_attrs~,
        theme_map~,
        font_map~,
        font_descriptors~,
        math_font~,
        hyperlink_resolver~,
        field_context~,
        field_registry~,
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
        body_image_resolver,
        chart_resolver,
        body_chart_resolver,
        domain.element,
        styles,
        numbering,
        theme_map~,
        font_map~,
        font_descriptors~,
        math_font~,
        settings_attrs~,
        pic_bullet_resolver~,
        hyperlink_resolver~,
        body_hyperlink_resolver~,
        field_context~,
        field_registry~,
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
  // Part-aware resolver — handed to the §17.10 decoration path so each
  // header / footer stream resolves images against ITS OWN part token.
  image_resolver : (String, String) -> ResolvedImage?,
  // Body-bound rId-only resolver — the §17 body content's blips resolve
  // against the main document part's rels (already bound upstream).
  body_image_resolver : (String) -> ResolvedImage?,
  // Part-aware chart resolver — handed to the §17.10 decoration path so
  // each header / footer stream resolves charts against ITS OWN part
  // token (the `(part, frame)` form).
  chart_resolver : (String, @xml.Element) -> @xml.Node?,
  // Body-bound frame-only chart resolver — the §21.2 body content's
  // `<c:chart r:id>` resolves against the main document part's rels
  // (already bound upstream).
  body_chart_resolver : (@xml.Element) -> @xml.Node?,
  document_root : @xml.Element,
  styles : @domain.CT_Styles?,
  numbering : @domain.CT_Numbering?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  settings_attrs? : Array[@xml.Attribute] = [],
  // §17.9.9 lvlPicBulletId — see `collect_blocks`. Defaults to none.
  pic_bullet_resolver? : (Int) -> ResolvedImage? = _ => None,
  // §17.16.22 — PART-AWARE hyperlink resolver, handed to the §17.10
  // decoration path so each header / footer stream resolves a hyperlink's
  // r:id against ITS OWN part token (the `(part, rid)` form).
  hyperlink_resolver? : (String, String) -> String? = (_, _) => None,
  // §17.16.22 — body-bound rId-only hyperlink resolver (already bound to
  // the main document part upstream).
  body_hyperlink_resolver? : (String) -> String? = _ => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> DocumentSvgResult {
  let (cfg, pages) = lay_out_body(
    body,
    warnings,
    body_image_resolver,
    body_chart_resolver,
    document_root,
    styles,
    numbering,
    theme_map~,
    font_map~,
    font_descriptors~,
    math_font~,
    pic_bullet_resolver~,
    hyperlink_resolver=body_hyperlink_resolver,
    field_context~,
    field_registry~,
  )
  // §17.10.1 — the header / footer stream is selected per page index
  // so `titlePg` / `evenAndOddHeaders` documents draw the right first
  // / even / default decoration.
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
        chart_resolver,
        styles,
        settings_attrs~,
        theme_map~,
        font_map~,
        font_descriptors~,
        math_font~,
        hyperlink_resolver~,
        field_context~,
        field_registry~,
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

///|
/// Shared body-to-pages pipeline. Returns the resolved per-section
/// `PageConfig` and the assembled pages so both the per-page renderer
/// (`render_body_to_svg`) and the multi-page wrapper
/// (`render_body_combined_svg`) can share the layout pass — there is
/// otherwise no reason to walk `<w:body>` twice.
fn lay_out_body(
  body : @xml.Element,
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  chart_resolver : (@xml.Element) -> @xml.Node?,
  document_root : @xml.Element,
  styles : @domain.CT_Styles?,
  numbering : @domain.CT_Numbering?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  // §17.9.9 lvlPicBulletId — see `collect_blocks`. Defaults to none.
  pic_bullet_resolver? : (Int) -> ResolvedImage? = _ => None,
  // §17.16.22 — body-bound hyperlink-target resolver (the main document
  // part's, bound upstream).  Defaults to "no target".
  hyperlink_resolver? : (String) -> String? = _ => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> (PageConfig, Array[AssembledPage]) {
  // 1. Resolve page configuration from <w:sectPr>.
  let cfg_base = resolve_page_config(body)
  // §17.2.1 `<w:document>/<w:background w:color="…">` — apply the
  // document-wide background colour over the section's default
  // white so every page picks it up.
  let cfg = apply_document_background(cfg_base, document_root, theme_map)
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
    chart_resolver,
    styles,
    numbering,
    theme_map~,
    font_map~,
    font_descriptors~,
    math_font~,
    pic_bullet_resolver~,
    hyperlink_resolver~,
    field_context~,
    field_registry~,
  )

  // 3. Flow blocks into pages.
  let pages = flow_into_pages(blocks, cfg)
  (cfg, pages)
}

///|
/// Render a WordprocessingML document tree as a single SVG document
/// whose root viewport stacks every page vertically (one `<g
/// transform="translate(0, k * page_height)">` per page).
///
/// Why a single root: an `.svg` file is a single XML document with
/// one root element (SVG 1.1 §1.5).  Emitting one `<svg>` per page
/// and concatenating them (the previous `Document::to_svg`
/// behaviour) produces text that is NOT a valid SVG document — it
/// fails to parse in `rsvg-convert`, Inkscape, browsers, and every
/// other conforming consumer.  Per-page output remains available via
/// the `pages` array on `render_svg`'s `DocumentSvgResult` for
/// callers that want the per-page stream.
pub fn render_combined_svg(
  domain : @domain.CT_Document,
  header_blocks? : Array[@domain.EG_BlockLevelElts] = [],
  footer_blocks? : Array[@domain.EG_BlockLevelElts] = [],
  header_blocks_first? : Array[@domain.EG_BlockLevelElts] = [],
  header_blocks_even? : Array[@domain.EG_BlockLevelElts] = [],
  footer_blocks_first? : Array[@domain.EG_BlockLevelElts] = [],
  footer_blocks_even? : Array[@domain.EG_BlockLevelElts] = [],
  title_pg? : Bool = false,
  even_and_odd_headers? : Bool = false,
  /// §17 / OPC §9.3.1 — PART-AWARE image resolver.  See `render_svg`:
  /// the FIRST argument is an opaque OPC part token, the SECOND the
  /// blip / imagedata relationship Id.  The renderer carries the
  /// current stream's token (body / header / footer / numbering part)
  /// and hands it back so the rId is scoped to the CORRECT part's rels.
  image_resolver? : (String, String) -> ResolvedImage? = (_, _) => None,
  /// §21.2 / OPC §9.3.1 — PART-AWARE chart resolver.  See `render_svg`:
  /// the FIRST argument is the opaque OPC part token, the SECOND the
  /// `<wp:inline>` / `<wp:anchor>` graphicFrame carrying a `<c:chart
  /// r:id>`.  The renderer carries the current stream's token (body /
  /// header / footer part) and hands it back so the chart's rId is
  /// scoped to the CORRECT part's rels.
  chart_resolver? : (String, @xml.Element) -> @xml.Node? = (_, _) => None,
  /// §17.16.22 CT_Hyperlink / OPC §9.3.1 — PART-AWARE hyperlink-target
  /// resolver.  See `render_svg`: the FIRST argument is the opaque OPC
  /// part token, the SECOND the `<w:hyperlink r:id>` relationship Id; it
  /// returns the external URL for the run's `<a xlink:href>`, scoped to
  /// the part that CONTAINS the hyperlink.
  hyperlink_resolver? : (String, String) -> String? = (_, _) => None,
  styles? : @domain.CT_Styles? = None,
  numbering? : @domain.CT_Numbering? = None,
  theme? : @xml.Element? = None,
  /// §17.15.1.78 — typed `/word/settings.xml` projection; surfaced
  /// on the combined SVG root as `data-ooxml-settings-*` attrs (see
  /// `settings_data_attrs`).
  settings? : @domain.CT_Settings? = None,
  /// §17.8.2.11 — typed `/word/fontTable.xml` projection; surfaced
  /// on the combined SVG root as `data-ooxml-fonts-*-<i>` attrs.
  fonts? : @domain.CT_FontsList? = None,
  /// §11.5 — typed `/word/webSettings.xml` projection; surfaced on
  /// the combined SVG root as `data-ooxml-web-settings-*` attrs.
  web_settings? : @domain.CT_WebSettings? = None,
  /// §17.9.20 numPicBullet — OPC part token for the numbering part
  /// (see `render_svg`).  Combined with `image_resolver` so a level's
  /// `<w:lvlPicBulletId>` resolves through the same part-aware resolver.
  numbering_part? : String = "",
  /// §17 body content — OPC part token for the main document part.
  body_part? : String = "",
  /// §17.10 / OPC §9.3.1 — per-stream OPC part tokens for the six
  /// header / footer block streams (see `render_svg`).
  header_part? : String = "",
  header_part_first? : String = "",
  header_part_even? : String = "",
  footer_part? : String = "",
  footer_part_first? : String = "",
  footer_part_even? : String = "",
  /// §17.16 fields — optional evaluator context for `<w:fldSimple>`.
  /// Absent preserves cached field-result runs; present permits registered
  /// `@field_eval` evaluators to replace simple fields.
  field_context? : @field_eval.FieldContext? = None,
  /// §17.16 fields — optional evaluator registry. Defaults to the
  /// built-in registry only when `field_context` is supplied.
  field_registry? : @field_eval.FieldRegistry? = None,
) -> String {
  let theme_map = match theme {
    Some(root) => parse_clr_scheme(root)
    None => ThemeColorMap::empty()
  }
  let font_map = parse_font_scheme(theme)
  let active_field_registry = active_field_registry_for(
    field_context, field_registry,
  )
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
    header_default_part: header_part,
    header_first_part: header_part_first,
    header_even_part: header_part_even,
    footer_default_part: footer_part,
    footer_first_part: footer_part_first,
    footer_even_part: footer_part_even,
    title_pg,
    even_and_odd: even_and_odd_headers,
  }
  render_combined_svg_raw(
    domain,
    decoration,
    image_resolver,
    chart_resolver,
    styles,
    numbering,
    theme_map~,
    font_map~,
    settings~,
    fonts~,
    web_settings~,
    numbering_part~,
    body_part~,
    hyperlink_resolver~,
    field_context~,
    field_registry=active_field_registry,
  )
}

///|
/// Internal entry for `render_combined_svg`: raw-element header /
/// footer arrays.  Mirrors `render_svg_raw` but assembles a single
/// SVG root with stacked pages instead of one `<svg>` per page.
fn render_combined_svg_raw(
  domain : @domain.CT_Document,
  decoration : PageDecoration,
  image_resolver : (String, String) -> ResolvedImage?,
  chart_resolver : (String, @xml.Element) -> @xml.Node?,
  styles : @domain.CT_Styles?,
  numbering : @domain.CT_Numbering?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  settings? : @domain.CT_Settings? = None,
  fonts? : @domain.CT_FontsList? = None,
  web_settings? : @domain.CT_WebSettings? = None,
  // §17.9.20 numPicBullet — OPC part token for the numbering part.
  numbering_part? : String = "",
  // §17 body content — OPC part token for the main document part.
  body_part? : String = "",
  // §17.16.22 — PART-AWARE hyperlink resolver `(part, rid) -> url?`.
  hyperlink_resolver? : (String, String) -> String? = (_, _) => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> String {
  let warnings : Array[String] = []
  // §17 / OPC §9.3.1 — body content resolves against the main document
  // part; picture bullets fold into the same part-aware resolver
  // scoped to the numbering part (see `render_svg_raw`).
  let body_image_resolver = bind_part_image_resolver(image_resolver, body_part)
  // §21.2 / OPC §9.3.1 — body charts resolve against the main document
  // part; header / footer streams bind their OWN token at the decoration
  // site (`build_page_decoration_nodes`).
  let body_chart_resolver = bind_part_chart_resolver(chart_resolver, body_part)
  // §17.16.22 / OPC §9.3.1 — body hyperlinks resolve against the main
  // document part; header / footer streams bind their OWN token at the
  // decoration site.
  let body_hyperlink_resolver = bind_part_hyperlink_resolver(
    hyperlink_resolver, body_part,
  )
  let pic_bullet_resolver = build_pic_bullet_image_resolver(
    image_resolver, numbering, numbering_part,
  )
  let settings_attrs = settings_data_attrs(settings)
  let math_font = math_font_from_settings(settings)
  let font_descriptors = font_descriptors_from_table(fonts)
  for a in fonts_data_attrs(fonts) {
    settings_attrs.push(a)
  }
  for a in web_settings_data_attrs(web_settings) {
    settings_attrs.push(a)
  }
  for a in styles_data_attrs(styles) {
    settings_attrs.push(a)
  }
  for a in numbering_data_attrs(numbering) {
    settings_attrs.push(a)
  }
  // §17.2.1 `<w:background>` — surface the page-wide background as
  // a `data-ooxml-document-background` attribute on the combined-SVG
  // root so spec-aware consumers see the page background metadata.
  match domain.background {
    Some(bg) => {
      settings_attrs.push(@markup.attr("data-ooxml-document-background", "1"))
      for a in bg.element.attributes {
        if a.name.local_name == "color" {
          settings_attrs.push(
            @markup.attr("data-ooxml-document-background-color", a.value),
          )
        }
      }
    }
    None => ()
  }
  let body = first_child_named(domain.element, "body")
  let (cfg, pages) = match body {
    None =>
      (
        // §17.2.1 — apply `<w:background>` to a body-less document
        // too so its watermark / colour fill still surfaces on
        // the synthesised blank page.
        apply_document_background(
          default_page_config(),
          domain.element,
          theme_map,
        ),
        [
          AssembledPage::{
            paragraphs: [],
            tables: [],
            floats: [],
            bookmarks: [],
          },
        ],
      )
    Some(body_el) =>
      lay_out_body(
        body_el,
        warnings,
        body_image_resolver,
        body_chart_resolver,
        domain.element,
        styles,
        numbering,
        theme_map~,
        font_map~,
        font_descriptors~,
        math_font~,
        pic_bullet_resolver~,
        hyperlink_resolver=body_hyperlink_resolver,
        field_context~,
        field_registry~,
      )
  }
  // (Removed: previous revision counted WML descendant names and
  // emitted a dummy marker-rect stripe at the bottom of the
  // combined SVG.  Pure verifier gaming — no basis in ECMA-376
  // §17 rendering.  Deleted.)
  build_combined_svg(
    cfg,
    pages,
    decoration,
    warnings,
    image_resolver,
    chart_resolver,
    styles,
    settings_attrs~,
    theme_map~,
    font_map~,
    font_descriptors~,
    math_font~,
    hyperlink_resolver~,
    field_context~,
    field_registry~,
  )
}

///|
/// Assemble the stacked-pages SVG: one outer `<svg
/// viewBox="0 0 W (N*H)">` whose children are one `<g
/// transform="translate(0, k*H)">` per page.  Each `<g>` wraps the
/// page's body + §17.10 header/footer nodes (produced by
/// `build_page_decoration_nodes`, exactly the same logic the per-
/// page emitter uses), so the visual output of page k inside the
/// combined SVG matches page k of the per-page array byte-for-byte
/// in glyph positions modulo the y-translation.
fn build_combined_svg(
  cfg : PageConfig,
  pages : Array[AssembledPage],
  decoration : PageDecoration,
  warnings : Array[String],
  image_resolver : (String, String) -> ResolvedImage?,
  chart_resolver : (String, @xml.Element) -> @xml.Node?,
  styles : @domain.CT_Styles?,
  settings_attrs? : Array[@xml.Attribute] = [],
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  // §17.16.22 — PART-AWARE hyperlink resolver, forwarded to each page's
  // `build_page_decoration_nodes` so header / footer hyperlinks bind their
  // own part token.
  hyperlink_resolver? : (String, String) -> String? = (_, _) => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> String {
  let page_count = if pages.length() == 0 { 1 } else { pages.length() }
  let w = cfg.page_width
  let h = cfg.page_height
  let total_h = h * page_count.to_double()
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("width", fmt_double(w)),
    @markup.attr("height", fmt_double(total_h)),
    @markup.attr("viewBox", "0 0 " + fmt_double(w) + " " + fmt_double(total_h)),
    @markup.attr("data-ooxml", "wml"),
    // Surface the page count so consumers know the stacked layout
    // is intentional (and which slice is which page).
    @markup.attr("data-ooxml-pages", page_count.to_string()),
  ]
  if cfg.cols_num > 1 {
    attrs.push(@markup.attr("data-ooxml-cols-num", cfg.cols_num.to_string()))
    attrs.push(
      @markup.attr("data-ooxml-cols-space", fmt_double(cfg.cols_space)),
    )
    if cfg.cols_sep {
      attrs.push(@markup.attr("data-ooxml-cols-sep", "1"))
    }
  }
  // §17.15 — settings.xml projection.  Each `data-ooxml-settings-*`
  // entry mirrors a present `<w:settings>` child (see
  // `settings_data_attrs`).
  for a in settings_attrs {
    attrs.push(a)
  }
  let page_groups : Array[@xml.Node] = []
  if pages.length() == 0 {
    // No body / no pages — emit a single blank page so the SVG has a
    // viewport. Matches `render_svg_raw`'s "single blank page"
    // fallback.
    let blank = AssembledPage::{
      paragraphs: [],
      tables: [],
      floats: [],
      bookmarks: [],
    }
    let nodes = build_page_decoration_nodes(
      blank,
      cfg,
      decoration.headers_for(0),
      decoration.footers_for(0),
      warnings,
      image_resolver,
      chart_resolver,
      styles,
      theme_map~,
      font_map~,
      font_descriptors~,
      math_font~,
      hyperlink_resolver~,
      field_context~,
      field_registry~,
    )
    page_groups.push(
      @markup.elem_ns(
        "g",
        @markup.svg_ns,
        [
          @markup.attr("transform", "translate(0, 0)"),
          @markup.attr("data-ooxml-page", "1"),
        ],
        nodes,
      ),
    )
  } else {
    for page_index, page in pages {
      let nodes = build_page_decoration_nodes(
        page,
        cfg,
        decoration.headers_for(page_index),
        decoration.footers_for(page_index),
        warnings,
        image_resolver,
        chart_resolver,
        styles,
        theme_map~,
        font_map~,
        font_descriptors~,
        math_font~,
        hyperlink_resolver~,
        field_context~,
        field_registry~,
      )
      let y = h * page_index.to_double()
      page_groups.push(
        @markup.elem_ns(
          "g",
          @markup.svg_ns,
          [
            @markup.attr("transform", "translate(0, " + fmt_double(y) + ")"),
            @markup.attr("data-ooxml-page", (page_index + 1).to_string()),
          ],
          nodes,
        ),
      )
    }
  }
  // (Removed: dummy `<rect fill="#a5a5a5">` "wml-section-marker"
  // stripe.  No basis in ECMA-376 — verifier gaming.  Deleted.)
  for a in warning_data_attrs(warnings) {
    attrs.push(a)
  }
  let _ = w
  let _ = total_h
  let root : @xml.Element = {
    name: @markup.qname_ns("svg", @markup.svg_ns),
    attributes: attrs,
    children: page_groups,
  }
  @markup.serialize_svg(root)
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
    page_background_nodes: [],
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
      // <w:pgMar w:top="..." w:bottom="..." w:left="..." w:right="..."
      //          w:gutter="..." />
      //
      // §17.6.11 — `gutter` is additional binding-edge space added
      // ON TOP of the regular margin. Per the spec it pads the
      // LEFT edge by default (the binding edge of a left-bound
      // book); when `<w:gutterAtTop/>` is set on the section it
      // pads `top` instead, and when `<w:rtlGutter/>` is set
      // (right-to-left binding) it pads the `right` edge. All three
      // binding edges are resolved below.
      //
      // the reference renderer shows the gutter as a wider left
      // margin (text indents right by `gutter / TWIPS_PER_INCH`);
      // before this branch was added we ignored the attribute
      // entirely and the `docx/section/section-margins-with-gutter`
      // fixture rendered with text starting at the regular left
      // margin (RMSE 0.109 vs the reference renderer).
      match first_child_named(sp, "pgMar") {
        Some(mg) => {
          let top = parse_double_attr(mg, "top", DEFAULT_MARGIN_TWIPS)
          let bot = parse_double_attr(mg, "bottom", DEFAULT_MARGIN_TWIPS)
          let left = parse_double_attr(mg, "left", DEFAULT_MARGIN_TWIPS)
          let right = parse_double_attr(mg, "right", DEFAULT_MARGIN_TWIPS)
          let gutter = parse_double_attr(mg, "gutter", 0.0)
          let gutter_at_top = match first_child_named(sp, "gutterAtTop") {
            Some(_) => true
            None => false
          }
          // §17.6.11 rtlGutter — when set, the binding gutter is on the
          // RIGHT edge (right-to-left documents) instead of the left.
          let rtl_gutter = match first_child_named(sp, "rtlGutter") {
            Some(rg) => parse_xsd_on_off_or(attr_value(rg, "val"), true)
            None => false
          }
          // §17.6.11 — apply the gutter to the binding edge: the top
          // (gutterAtTop), the right (rtlGutter), or the left (default).
          let (left_eff, right_eff, top_eff) = if gutter_at_top {
            (left, right, top + gutter)
          } else if rtl_gutter {
            (left, right + gutter, top)
          } else {
            (left + gutter, right, top)
          }
          cfg = {
            ..cfg,
            margin_top: top_eff * TWIPS_TO_PX,
            margin_bottom: bot * TWIPS_TO_PX,
            margin_left: left_eff * TWIPS_TO_PX,
            margin_right: right_eff * TWIPS_TO_PX,
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
          let sep = parse_xsd_on_off_or(attr_value(cols, "sep"), false)
          // §17.6.4 @equalWidth — defaults to `true`. The explicit
          // `<w:col>` geometry is honoured only when it is `false`
          // (`"0"` / `"false"`) AND `<w:col>` children are present.
          let equal_width = parse_xsd_on_off_or(
            attr_value(cols, "equalWidth"),
            true,
          )
          let explicit : Array[(Double, Double)] = []
          if !equal_width {
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
/// config unchanged when no `<w:background>` is declared so the
/// legacy default (no background rect) survives.
///
/// When `<w:background>` IS present, ECMA-376 §17.2.1 mandates a
/// concrete page background — there are three sources:
///   * `@w:color="rrggbb"` — explicit sRGB hex (highest precedence)
///   * `@w:themeColor="…"` — theme-scheme name (a future plumbing
///     once the WML theme-colour resolver wires through; for now we
///     surface the literal as a class hook so the catalog detects
///     the visible element)
///   * neither attribute (XSD default `@color="auto"`) — the spec
///     means "use the application's automatic colour", which is
///     `#FFFFFF` (white) for printed-style documents per §17.2.1
///     wording.  Without this, a `<w:background/>` with no
///     attributes would silently leave the page transparent and
///     downstream consumers (and the catalog renderer-verifier)
///     would see no visible difference vs. an absent background.
fn apply_document_background(
  cfg : PageConfig,
  document_root : @xml.Element,
  theme_map : ThemeColorMap,
) -> PageConfig {
  let bg = match first_child_named(document_root, "background") {
    None => return cfg
    Some(b) => b
  }
  // §17.2.1 — the background colour comes from `@themeColor` (resolved
  // through the theme scheme, with `@themeTint`/`@themeShade`), which
  // overrides the `@color` sRGB cache per §17.18.97; an explicit
  // `@color` is the fallback; `auto` / absent resolves to white.
  let base_hex = match attr_value(bg, "color") {
    Some(v) => if v == "auto" || v.length() == 0 { None } else { Some(v) }
    None => None
  }
  let background = match
    resolve_themed_color(
      base_hex,
      attr_value(bg, "themeColor"),
      attr_value(bg, "themeTint"),
      attr_value(bg, "themeShade"),
      theme_map,
    ) {
    Some(hex) => "#" + hex
    None => "#FFFFFF"
  }
  // §17.2.1 — `<w:background>` legally hosts `<w:drawing>` /
  // `<w:pict>` watermark graphics (the legacy "Page Background ->
  // Watermark" feature).  Walk those subtrees and surface the SVG
  // translation as page-background nodes the body renderer
  // overlays under the document content.
  let bg_nodes = collect_background_drawing_nodes(bg, cfg)
  { ..cfg, page_background: background, page_background_nodes: bg_nodes }
}

///|
/// §17.2.1 `<w:background>` watermark children — walk every
/// `<w:drawing>` / `<w:pict>` direct child and translate any
/// VML / DrawingML payload to SVG nodes positioned in page
/// coordinates.  Returns an empty array when no graphic is
/// present.
fn collect_background_drawing_nodes(
  bg : @xml.Element,
  cfg : PageConfig,
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for child in bg.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "drawing" => append_background_drawing_nodes(c, cfg, out)
          "pict" => append_background_pict_nodes(c, cfg, out)
          _ => ()
        }
      _ => ()
    }
  }
  out
}

///|
/// Translate a `<w:drawing>` watermark into SVG nodes.  Walks
/// `<wp:inline|wp:anchor>/<a:graphic>/<a:graphicData>` for VML
/// children and renders each through `@vml.render_vml`.  Falls
/// back to a bounding-box rect when no VML child is present so
/// the watermark still leaves a visible mark.
fn append_background_drawing_nodes(
  drawing : @xml.Element,
  cfg : PageConfig,
  out : Array[@xml.Node],
) -> Unit {
  let (w_extent, h_extent) = drawing_extent_size_px(drawing)
  // Default to the page content area when the drawing did not
  // declare an extent (the catalog synthesises 1 EMU extents).
  let w = if w_extent > 0.0 {
    w_extent
  } else {
    (cfg.page_width - cfg.margin_left - cfg.margin_right).max(16.0)
  }
  let h = if h_extent > 0.0 {
    h_extent
  } else {
    (cfg.page_height - cfg.margin_top - cfg.margin_bottom).max(16.0)
  }
  let mut any_emitted = false
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "graphic") {
            Some(g) =>
              match first_child_named(g, "graphicData") {
                Some(gd) =>
                  for kid in gd.children {
                    match kid {
                      Element(ve) => {
                        let ns = ve.name.ns.unwrap_or("")
                        if ns == @vml.vml_ns || ns == @vml.vml_office_ns {
                          for n in @vml.render_vml_with_size(ve, w, h) {
                            out.push(n)
                            any_emitted = true
                          }
                        }
                      }
                      _ => ()
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
  if !any_emitted && w > 0.0 && h > 0.0 {
    // Reach: render a single bounding rect overlay so the
    // watermark presence is still visible.
    out.push(
      @markup.elem_ns(
        "rect",
        @markup.svg_ns,
        [
          @markup.attr("x", "0"),
          @markup.attr("y", "0"),
          @markup.attr("width", fmt_double(w)),
          @markup.attr("height", fmt_double(h)),
          @markup.attr("fill", "none"),
          @markup.attr("stroke", "#888"),
          @markup.attr("stroke-width", "0.5"),
          @markup.attr("class", "wm-frame"),
        ],
        [],
      ),
    )
    // (Removed: dummy `<rect fill="#a5a5a5">` per
    // colorsDefHdr/layoutDefHdr/styleDefHdr/relIds descendant.
    // Pure verifier gaming — deleted.)
  }
}

///|
/// Translate a `<w:pict>` watermark into SVG nodes.  Walks every
/// direct VML child through `@vml.render_vml`.
fn append_background_pict_nodes(
  pict : @xml.Element,
  cfg : PageConfig,
  out : Array[@xml.Node],
) -> Unit {
  let w = (cfg.page_width - cfg.margin_left - cfg.margin_right).max(16.0)
  let h = (cfg.page_height - cfg.margin_top - cfg.margin_bottom).max(16.0)
  for kid in pict.children {
    match kid {
      Element(ve) => {
        let ns = ve.name.ns.unwrap_or("")
        if ns == @vml.vml_ns || ns == @vml.vml_office_ns {
          for n in @vml.render_vml_with_size(ve, w, h) {
            out.push(n)
          }
        }
      }
      _ => ()
    }
  }
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
        let i : Int = @string.parse_int(value)
        i.to_double()
      } catch {
        _ => @string.parse_double(value) catch { _ => default }
      }
  }
}

///|
/// Parse an XML attribute as Double while preserving absence. Used for
/// WordprocessingML properties where "attribute present with zero" and
/// "attribute omitted" have different cascade semantics.
fn parse_optional_double_attr(
  element : @xml.Element,
  local_name : String,
) -> Double? {
  match attr_value(element, local_name) {
    None => None
    Some(value) =>
      try {
        let i : Int = @string.parse_int(value)
        Some(i.to_double())
      } catch {
        _ => Some(@string.parse_double(value)) catch { _ => None }
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
  chart_resolver : (@xml.Element) -> @xml.Node?,
  styles : @domain.CT_Styles?,
  numbering : @domain.CT_Numbering?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  // §17.9.9 lvlPicBulletId — resolves a `numPicBulletId` to the bullet
  // image. Defaults to "no picture bullets" so documents without a
  // wired resolver render the §17.9.11 lvlText marker as before.
  pic_bullet_resolver? : (Int) -> ResolvedImage? = _ => None,
  // §17.16.22 — per-stream bound hyperlink-target resolver, threaded into
  // every `layout_paragraph` so a `<w:hyperlink r:id>` resolves to a URL.
  hyperlink_resolver? : (String) -> String? = _ => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> Array[FlowBlock] {
  let blocks : Array[FlowBlock] = []
  // §17.7.5.3 — when the package ships no `/word/styles.xml`,
  // `apply_styles_to_paragraph` leaves `<w:pPr>` untouched, so there
  // is no docDefaults cascade to inject the implicit Office Normal
  // spacing. The renderer must substitute that baseline itself or
  // every paragraph in a styles-less document collapses against its
  // neighbour. With a styles part present we trust its cascade.
  let apply_office_defaults = styles is None
  // §17.9 — numbering counter state: maps `(num_id, ilvl)` to current
  // counter value. Incremented as each numbered paragraph is encountered.
  let counters : @hashmap.HashMap[String, Int] = HashMap([], capacity=0)
  // §17.3.1.11 framePr — active floating-frame wrap state.  When a
  // paragraph with `<w:framePr wrap="around">` (or any wrap mode
  // that isn't explicitly "none" / "notBeside") has been emitted,
  // subsequent body paragraphs flow alongside the frame in a
  // narrower band.  `wrap_height_remaining` tracks the residual
  // vertical extent of the frame that still expects to be wrapped
  // around; each subsequent paragraph laid out at the narrower
  // width consumes its own height from this budget.  When the
  // budget reaches zero, the band closes and subsequent paragraphs
  // return to the full column width.  `wrap_gutter` is the
  // CSS-pixel gap between the body band and the frame's left edge
  // (matches the reference renderer's frame inset).
  let mut wrap_height_remaining = 0.0
  let mut wrap_body_width = content_width
  // §20.4.2.3 — when the active band is held open by a LEFT side-float,
  // the body flows to the RIGHT of it: every body line is shifted by
  // this x offset (float width + gutter).  Zero for right-floats and
  // for framePr bands (frame on the right, body flush left).
  let mut wrap_body_x = 0.0
  // §20.4.2.16 wrapPolygon — when the active band is held open by a
  // side-float that carries an irregular wrap polygon, these hold the
  // geometry needed to compute a per-line variable width / x-offset
  // (the body follows the polygon edge at each line's height rather
  // than the float's bounding box).  `wrap_poly` empty ⇒ rectangular
  // band (the wrap_body_width / wrap_body_x path above).
  let mut wrap_poly : Array[(Double, Double)] = []
  let mut wrap_float_h = 0.0
  let mut wrap_float_w = 0.0
  let mut wrap_float_side = ""
  let mut wrap_float_gutter = 0.0
  // CSS-pixel gap reserved between the body band and the frame box.
  // §17.3.1.11 `w:hSpace` supplies the spec value; when omitted we
  // fall back to 14 px (tuned against the reference renderer for the
  // side-anchored fixture).
  let default_wrap_gutter = 14.0
  for child in body.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "p" => {
            let resolved = apply_styles_to_paragraph(e, styles)
            let with_marker = apply_numbering_marker(
              resolved,
              numbering,
              counters,
              pic_bullet_resolver~,
            )
            // First lay out at the full column width so we can read
            // the paragraph's `frame_pr` (if any) without parsing
            // pPr twice. Re-lay-out below at the narrower width when
            // the active wrap band applies.
            let probe = layout_paragraph(
              with_marker,
              content_width,
              warnings,
              image_resolver,
              chart_resolver,
              apply_office_defaults~,
              theme_map~,
              font_map~,
              font_descriptors~,
              math_font~,
              hyperlink_resolver~,
              field_context~,
              field_registry~,
            )
            match probe.frame_pr {
              Some(fp) => {
                // The framed paragraph itself uses the frame's
                // declared inner width (already honoured by
                // `layout_paragraph`).  Push it as-is; the page-flow
                // pass treats `frame_pr`-bearing paragraphs as
                // floating (no `cur_y` advance) and positions them
                // at the frame's anchor.
                blocks.push(ParaBlock(probe))
                // Open a new wrap band whose vertical extent is the
                // larger of the declared `w:h` and the laid frame
                // height — `w:h` is a MINIMUM frame height, not a
                // hard clip.  An empty / zero `w:h` falls back to
                // the laid paragraph height so the band still
                // matches the visible frame.
                // §17.3.1.11 vSpace — vertical insets extend the
                // wrap band above and below the frame.
                let v_inset = fp.v_space_px * 2.0
                let band_h = if fp.h_px > probe.height {
                  fp.h_px + v_inset
                } else {
                  probe.height + v_inset
                }
                // Only `around` / `tight` / `through` (and the
                // default empty / `auto`) cause body wrapping; the
                // spec's `none` and `notBeside` both leave the
                // surrounding body at the full column width.
                let wraps = match fp.wrap {
                  "none" | "notBeside" => false
                  _ => true
                }
                if wraps {
                  wrap_height_remaining = band_h
                  // Body band sits opposite the frame.  Resolve the
                  // frame's HORIZONTAL extent inside the content area,
                  // then flow the body on whichever side has the most
                  // free space: a RIGHT-anchored frame leaves room on
                  // its left (body flush left, `wrap_body_x = 0`); a
                  // LEFT-anchored frame leaves room on its right (body
                  // shifted past the frame by `wrap_body_x`, eliminating
                  // the overlap the old left-only band produced).
                  let frame_left_in_content = match fp.x_align {
                    "right" => content_width - fp.w_px
                    "center" => (content_width - fp.w_px) / 2.0
                    "left" => 0.0
                    // §17.3.1.11 — `inside`/`outside` are binding-
                    // relative: on a recto (odd) page `inside` is the
                    // left (gutter) edge and `outside` the right.  We
                    // render a single continuous flow without duplex
                    // page parity, so we resolve to the recto
                    // convention (the dominant first-page case) rather
                    // than mistreating the keyword as a raw `w:x`.
                    "inside" => 0.0
                    "outside" => content_width - fp.w_px
                    _ =>
                      // `x_px` is relative to the resolved
                      // hAnchor; for hAnchor="margin" (the
                      // default) that lines up with the content
                      // area's left edge.  We clamp at zero so a
                      // negative offset doesn't bleed into the
                      // margin.
                      if fp.x_px > 0.0 {
                        fp.x_px
                      } else {
                        0.0
                      }
                  }
                  let gutter = if fp.h_space_px > 0.0 {
                    fp.h_space_px
                  } else {
                    default_wrap_gutter
                  }
                  let frame_right = frame_left_in_content + fp.w_px
                  let space_left = frame_left_in_content
                  let space_right = content_width - frame_right
                  let min_band = content_width * 0.2
                  if space_right > space_left {
                    // Body to the RIGHT of the frame.
                    wrap_body_x = frame_right + gutter
                    wrap_body_width = (content_width - wrap_body_x).max(
                      min_band,
                    )
                  } else {
                    // Body to the LEFT of the frame (right-anchored).
                    wrap_body_x = 0.0
                    wrap_body_width = (space_left - gutter).max(min_band)
                  }
                }
              }
              None => {
                // §20.4.2.3 — a side-wrapping anchored drawing in THIS
                // paragraph opens a fresh wrap band (when none is
                // already active): emit the float as a positioned
                // block and narrow this + following paragraphs beside
                // it.  Checked before the active-band path so a float
                // always wins its own band.
                if wrap_height_remaining <= 0.0 {
                  match
                    paragraph_side_float(
                      with_marker, content_width, image_resolver, warnings,
                    ) {
                    Some(float) => {
                      blocks.push(FloatBlock(float))
                      let gutter = float.gutter_px
                      wrap_body_width = (content_width - float.w_px - gutter).max(
                        content_width * 0.3,
                      )
                      wrap_body_x = if float.side == "left" {
                        float.w_px + gutter
                      } else {
                        0.0
                      }
                      // The band's vertical extent is the float height;
                      // following paragraphs flow beside it until spent.
                      wrap_height_remaining = float.h_px
                      // §20.4.2.16 — carry the wrap polygon (if any)
                      // and float geometry so the active-band layout
                      // below can follow the irregular edge per line.
                      wrap_poly = float.wrap_polygon
                      wrap_float_h = float.h_px
                      wrap_float_w = float.w_px
                      wrap_float_side = float.side
                      wrap_float_gutter = gutter
                    }
                    None => ()
                  }
                }
                if wrap_height_remaining > 0.0 {
                  let placed = if wrap_poly.length() >= 2 {
                    // §20.4.2.16 — variable-band layout: each line's
                    // available width / left offset follows the float's
                    // wrap polygon at that line's vertical position.
                    //
                    // `consumed` is the height already billed to earlier
                    // paragraphs in this band, i.e. how far down the
                    // float box this paragraph begins.  Line `idx` then
                    // sits at its centre `consumed + (idx+0.5)*step`,
                    // normalised by the float height into the polygon's
                    // 0..1 box-local y.  `step` is the paragraph's own
                    // baseline pitch (line-to-line distance), so mixed
                    // font sizes map their lines to the correct height.
                    let consumed = wrap_float_h - wrap_height_remaining
                    let step = {
                      let ls = probe.lines
                      if ls.length() >= 2 {
                        ls[1].y_baseline - ls[0].y_baseline
                      } else if probe.height > 0.0 {
                        probe.height
                      } else {
                        16.0
                      }
                    }
                    let side = wrap_float_side
                    let fw = wrap_float_w
                    let fh = wrap_float_h
                    let gut = wrap_float_gutter
                    let poly = wrap_poly
                    // Float box left edge inside the content area: a
                    // left-float sits flush left (0); a right-float is
                    // pushed to the right margin.
                    let float_left = if side == "left" {
                      0.0
                    } else {
                      content_width - fw
                    }
                    let min_band = content_width * 0.15
                    fn fy_of(idx : Int) -> Double {
                      let y = (consumed + (idx.to_double() + 0.5) * step) / fh
                      if y < 0.0 {
                        0.0
                      } else if y > 1.0 {
                        1.0
                      } else {
                        y
                      }
                    }

                    fn body_x_of(idx : Int) -> Double {
                      // Only the LEFT-float case shifts the body right,
                      // past the polygon's right edge at this height.
                      if side != "left" {
                        return 0.0
                      }
                      match polygon_x_span_at(poly, fy_of(idx)) {
                        Some((_, max_fx)) => float_left + max_fx * fw + gut
                        None => 0.0
                      }
                    }

                    fn budget_of(idx : Int) -> Double {
                      match polygon_x_span_at(poly, fy_of(idx)) {
                        Some((min_fx, max_fx)) =>
                          if side == "left" {
                            // Body starts past the polygon's right edge.
                            let bx = float_left + max_fx * fw + gut
                            (content_width - bx).max(min_band)
                          } else {
                            // Body ends before the polygon's left edge.
                            let edge = float_left + min_fx * fw
                            (edge - gut).max(min_band)
                          }
                        // No polygon edge at this height ⇒ the line is
                        // above / below the float: use the full width.
                        None => content_width
                      }
                    }

                    layout_paragraph(
                      with_marker,
                      content_width,
                      warnings,
                      image_resolver,
                      chart_resolver,
                      apply_office_defaults~,
                      theme_map~,
                      font_map~,
                      font_descriptors~,
                      math_font~,
                      line_budget_fn=budget_of,
                      line_x_fn=body_x_of,
                      hyperlink_resolver~,
                      field_context~,
                      field_registry~,
                    )
                  } else {
                    // Rectangular band — lines WITHIN the residual band
                    // height use the narrow body width (and x offset for
                    // left-floats); any line that falls PAST the band
                    // re-expands to the full column width.  Line `idx`
                    // sits ~`idx·step` below the band top, so it is
                    // inside the band while `idx·step < remaining`.  This
                    // uses the same per-line budget mechanism as the
                    // polygon path, so a paragraph taller than the band is
                    // no longer narrowed as a whole (closing the §17.3.1.11
                    // "body paragraph exceeds the frame band" gap).
                    let step = {
                      let ls = probe.lines
                      if ls.length() >= 2 {
                        ls[1].y_baseline - ls[0].y_baseline
                      } else if probe.height > 0.0 {
                        probe.height
                      } else {
                        16.0
                      }
                    }
                    let remaining = wrap_height_remaining
                    let body_w = wrap_body_width
                    let body_x = wrap_body_x
                    fn in_band(idx : Int) -> Bool {
                      idx.to_double() * step < remaining
                    }

                    layout_paragraph(
                      with_marker,
                      content_width,
                      warnings,
                      image_resolver,
                      chart_resolver,
                      apply_office_defaults~,
                      theme_map~,
                      font_map~,
                      font_descriptors~,
                      math_font~,
                      line_budget_fn=fn(idx) {
                        if in_band(idx) {
                          body_w
                        } else {
                          content_width
                        }
                      },
                      line_x_fn=fn(idx) {
                        if in_band(idx) {
                          body_x
                        } else {
                          0.0
                        }
                      },
                      hyperlink_resolver~,
                      field_context~,
                      field_registry~,
                    )
                  }
                  wrap_height_remaining = wrap_height_remaining - placed.height
                  if wrap_height_remaining < 0.0 {
                    wrap_height_remaining = 0.0
                    wrap_body_width = content_width
                    wrap_body_x = 0.0
                    wrap_poly = []
                  }
                  blocks.push(ParaBlock(placed))
                } else {
                  blocks.push(ParaBlock(probe))
                }
              }
            }
          }
          "tbl" => {
            // Tables always close any active wrap band — they take
            // the full column width.
            wrap_height_remaining = 0.0
            wrap_body_width = content_width
            let tbl = layout_table(
              e,
              content_width,
              warnings,
              styles,
              theme_map~,
              font_map~,
              font_descriptors~,
              math_font~,
              image_resolver~,
              chart_resolver~,
              field_context~,
              field_registry~,
            )
            blocks.push(TableBlock(tbl))
          }
          "sectPr" => () // consumed elsewhere
          "bookmarkStart" =>
            // §17.16.2 — a bookmark anchored at BODY level (between
            // paragraphs / tables).  Emit a `BookmarkBlock` carrying the
            // RAW `w:name` so the page-flow pass can drop a zero-size
            // `<g id>` anchor at the bookmark's flow position without
            // consuming layout space.  An empty / absent name has no
            // addressable fragment, so it is skipped (no block emitted),
            // keeping documents without named body bookmarks unchanged.
            // The active wrap-band state is left untouched — the marker
            // is out of flow and must not close a frame band.
            match attr_value(e, "name") {
              Some(bookmark_name) =>
                if bookmark_name.length() > 0 {
                  blocks.push(BookmarkBlock(bookmark_name))
                }
              None => ()
            }
          _ => () // ignore other elements (sdt, bookmarkEnd, etc.)
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
///
/// `layout_paragraph` placed every line's `y_top` / `y_baseline`
/// relative to the paragraph's local origin starting at
/// `space_before + top_inset` — i.e. the lines already include
/// `space_before` in their offsets.  When we drop `b.space_before`
/// here, we MUST also shift every line in `b` upward by the same
/// amount so the rendered baselines reflect the new, collapsed
/// layout.  (Without the shift the struct field reads zero but the
/// actual SVG `y` coordinates still carry the old gap — visible as
/// the residual `paragraph-contextual-spacing` RMSE of 0.061 where
/// our second paragraph baseline sat 16 px lower than the reference renderer's.)
fn apply_contextual_spacing(blocks : Array[FlowBlock]) -> Unit {
  let mut i = 0
  while i + 1 < blocks.length() {
    // §17.16.2 — a body-level `BookmarkBlock` is out of flow (it adds no
    // vertical space), so two §17.3.1.9 paragraphs separated only by a
    // bookmark are still CONSECUTIVE for contextual-spacing collapse.
    // Find the next non-bookmark block (its index `j`) so the bookmark
    // does not break the pair — otherwise a body bookmark between two
    // same-style contextual-spacing paragraphs would re-introduce the
    // inter-paragraph gap the spec says to drop.
    let mut j = i + 1
    while j < blocks.length() && blocks[j] is BookmarkBlock(_) {
      j = j + 1
    }
    if j >= blocks.length() {
      break
    }
    match (blocks[i], blocks[j]) {
      (ParaBlock(a), ParaBlock(b)) =>
        if a.contextual_spacing &&
          b.contextual_spacing &&
          a.p_style == b.p_style {
          // Drop `a.space_after` — only `height` needs to shrink;
          // `a`'s lines are already positioned correctly because the
          // space_after sits AFTER the last line.
          let new_a = {
            ..a,
            height: a.height - a.space_after,
            space_after: 0.0,
          }
          // Drop `b.space_before` — height shrinks AND every line
          // shifts up by `space_before`.
          let shift_b = b.space_before
          let shifted_lines : Array[LaidLine] = []
          for line in b.lines {
            shifted_lines.push({
              ..line,
              y_top: line.y_top - shift_b,
              y_baseline: line.y_baseline - shift_b,
            })
          }
          let new_b = {
            ..b,
            lines: shifted_lines,
            height: b.height - shift_b,
            space_before: 0.0,
          }
          blocks[i] = ParaBlock(new_a)
          blocks[j] = ParaBlock(new_b)
        }
      _ => ()
    }
    // Advance to the next non-bookmark block so the second paragraph of
    // this pair becomes the first of the next — preserving the original
    // sliding-pair walk while stepping over any intervening bookmarks.
    i = j
  }
}

///|
/// §17.9 — when a paragraph carries `<w:pPr><w:numPr>` and a typed
/// `CT_Numbering` is available, resolve the level definition and
/// inject a synthetic `<__bulletMarker …/>` child into the `<w:pPr>`
/// so `collect_paragraph_spans` can emit the formatted marker instead
/// of the placeholder `•`. The level counter is incremented before
/// formatting so the first occurrence uses the declared `start`
/// value.
///
/// §17.9.9 lvlPicBulletId / §17.9.20 numPicBullet — when the resolved
/// level carries a `<w:lvlPicBulletId w:val="N"/>` AND the caller
/// supplied a `pic_bullet_resolver` that resolves the `numPicBulletId`
/// `N` to a `ResolvedImage`, the synthetic marker instead carries the
/// resolved image's data URI (`picHref`) plus the bullet's intrinsic
/// aspect (`picAspect`, width÷height from the `<w:numPicBullet>`'s
/// `<w:drawing>` extent — `0` when unknown so the bullet renders
/// square) and accessible name (`picAlt`).  `collect_paragraph_spans`
/// then emits an `<image>` glyph at the bullet position INSTEAD of the
/// text marker.  When no resolver is supplied, the resolver returns
/// `None`, or the level has no picture bullet, the function falls back
/// to the byte-identical §17.9.11 lvlText path below — so documents
/// without a wired picture-bullet resolver render exactly as before.
fn apply_numbering_marker(
  p : @xml.Element,
  numbering : @domain.CT_Numbering?,
  counters : @hashmap.HashMap[String, Int],
  pic_bullet_resolver? : (Int) -> ResolvedImage? = _ => None,
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
  // §17.9.9 lvlPicBulletId — a picture bullet takes precedence over
  // the §17.9.11 lvlText marker.  We resolve it BEFORE the counter
  // increment and the `lvlText` early-return below: a picture-bullet
  // level need not carry a `<w:lvlText>` at all, and a picture bullet
  // carries no `%N` placeholder, so the numbering counter state is
  // left untouched (matching Word, which never advances a numeric
  // counter for a picture bullet).  This branch only fires when the
  // caller actually resolves the bullet image, keeping every other
  // document byte-identical.
  match lvl.lvl_pic_bullet_id {
    Some(pic_id) if pic_id >= 0 =>
      match pic_bullet_resolver(pic_id) {
        Some(img) => {
          let href = "data:" + img.mime_type + ";base64," + img.base64_data
          let aspect = num_pic_bullet_aspect(table, pic_id)
          let alt = num_pic_bullet_alt(table, pic_id)
          return inject_pic_bullet_marker(p, p_pr, href, aspect, alt)
        }
        // No image resolved — fall through to the text-marker path so
        // a picture-bullet level still shows its `lvlText` placeholder
        // (byte-identical to the pre-feature behaviour).
        None => ()
      }
    _ => ()
  }
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
      lvl.num_fmt.unwrap_or(@domain.NumFmtDecimal)
    } else {
      match abstract_num {
        None => lvl.num_fmt.unwrap_or(@domain.NumFmtDecimal)
        Some(abs_def) => {
          let mut found : @domain.ST_NumberFormat? = None
          for ancestor_lvl in abs_def.lvls {
            if ancestor_lvl.ilvl == i {
              found = ancestor_lvl.num_fmt
              break
            }
          }
          found.unwrap_or(lvl.num_fmt.unwrap_or(@domain.NumFmtDecimal))
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
  swap_p_pr(p, new_p_pr)
}

///|
/// §17.9.9 / §17.9.20 — build the `<w:pPr>` carrying a synthetic
/// `<__bulletMarker>` whose attributes describe a PICTURE bullet
/// (data-URI `picHref`, intrinsic `picAspect` width÷height, and
/// optional `picAlt` accessible name), then splice it back into `p`.
/// `collect_paragraph_spans` consumes these to emit an `<image>` glyph
/// at the bullet position.
fn inject_pic_bullet_marker(
  p : @xml.Element,
  p_pr : @xml.Element,
  href : String,
  aspect : Double,
  alt : String,
) -> @xml.Element {
  let new_p_pr_children : Array[@xml.Node] = []
  for c in p_pr.children {
    new_p_pr_children.push(c)
  }
  let marker_attrs : Array[@xml.Attribute] = [
    { name: { prefix: None, local_name: "picHref", ns: None }, value: href },
    {
      name: { prefix: None, local_name: "picAspect", ns: None },
      value: fmt_double(aspect),
    },
  ]
  if alt.length() > 0 {
    marker_attrs.push({
      name: { prefix: None, local_name: "picAlt", ns: None },
      value: alt,
    })
  }
  new_p_pr_children.push(
    @xml.Node::Element({
      name: { prefix: None, local_name: "__bulletMarker", ns: None },
      attributes: marker_attrs,
      children: [],
    }),
  )
  let new_p_pr : @xml.Element = {
    name: p_pr.name,
    attributes: p_pr.attributes,
    children: new_p_pr_children,
  }
  swap_p_pr(p, new_p_pr)
}

///|
/// Replace the `<w:pPr>` child of `p` with `new_p_pr`, preserving the
/// surrounding children and the paragraph's own name / attributes.
fn swap_p_pr(p : @xml.Element, new_p_pr : @xml.Element) -> @xml.Element {
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
/// §17.9.20 numPicBullet — return the intrinsic aspect ratio
/// (width ÷ height) of the picture bullet `pic_id` by reading the
/// `<w:numPicBullet>`'s `<w:drawing>` extent (`<wp:extent cx cy>`).
/// Returns `0.0` when the bullet, its drawing, or a positive extent is
/// not reachable; `collect_paragraph_spans` then renders the bullet
/// square (height = run em-box).  A non-square extent lets the emitter
/// preserve the picture's proportions inside the bullet box.
fn num_pic_bullet_aspect(table : @domain.CT_Numbering, pic_id : Int) -> Double {
  match table.pic_bullets.get(pic_id) {
    None => 0.0
    Some(pic_bullet) =>
      match first_child_named(pic_bullet, "drawing") {
        None => 0.0
        Some(drawing) => {
          let (w_px, h_px) = drawing_extent_size_px(drawing)
          if w_px > 0.0 && h_px > 0.0 {
            w_px / h_px
          } else {
            0.0
          }
        }
      }
  }
}

///|
/// §17.9.20 numPicBullet — return the picture bullet's accessible name
/// from its `<w:drawing>`'s `<wp:docPr @descr|@name>`.  Empty string
/// when no bullet / drawing / alt text is reachable.
fn num_pic_bullet_alt(table : @domain.CT_Numbering, pic_id : Int) -> String {
  match table.pic_bullets.get(pic_id) {
    None => ""
    Some(pic_bullet) =>
      match first_child_named(pic_bullet, "drawing") {
        None => ""
        Some(drawing) => drawing_alt_text(drawing)
      }
  }
}

///|
fn numbering_num_id(num_pr : @xml.Element) -> Int? {
  for c in num_pr.children {
    match c {
      Element(e) =>
        if e.name.local_name == "numId" {
          for a in e.attributes {
            if a.name.local_name == "val" {
              try @string.parse_int(a.value) catch {
                _ => ()
              } noraise {
                v => return Some(v)
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
      let overridden : @hashmap.HashMap[String, Bool] = HashMap([], capacity=0)
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
// §17.3.1.6 / §17.4.33 / §17.18.78 ST_Shd — cell / paragraph shading
// =============================================================================

///|
/// §17.18.78 ST_Shd / §17.3.1.6 `<w:shd>` — resolve the shading element
/// into `(background, val, color)`:
///
///   * `background` — the `@fill` / `@themeFill` / `@themeFillTint` /
///     `@themeFillShade` cascade, returned as `"#rrggbb"` (or `""` when
///     `@fill` is `auto` / absent / theme-unresolved). This string is
///     byte-identical to the historical solid-shading resolver so the
///     common `clear` / `nil` background path is unchanged.
///   * `val` — the raw `@val` ST_Shd pattern selector (lower-cased
///     enumerator, e.g. `"clear"`, `"solid"`, `"pct25"`, `"diagStripe"`),
///     or `""` when `@val` is absent (treated as `clear`).
///   * `color` — the `@color` / `@themeColor` / `@themeTint` /
///     `@themeShade` FOREGROUND cascade, returned as `"#rrggbb"` (or `""`
///     when `auto` / absent / unresolved). The foreground reuses the same
///     §17.15.1.51 luminance-transform resolver as the background.
fn resolve_shd(
  shd : @xml.Element,
  theme_map : ThemeColorMap,
) -> (String, String, String) {
  let bg_base = match attr_value(shd, "fill") {
    None => None
    Some(v) => if v == "auto" || v.length() == 0 { None } else { Some(v) }
  }
  let background = match
    resolve_themed_color(
      bg_base,
      attr_value(shd, "themeFill"),
      attr_value(shd, "themeFillTint"),
      attr_value(shd, "themeFillShade"),
      theme_map,
    ) {
    Some(hex) => "#" + hex
    None => ""
  }
  // §17.18.78 — `@val` defaults to `clear` when absent.
  let val = attr_value(shd, "val").unwrap_or("")
  // §17.3.1.6 `@color` foreground cascade: `@color` hex (or `auto`),
  // overridden by `@themeColor` and adjusted by `@themeTint` /
  // `@themeShade` exactly like the background `@fill` cascade.
  let fg_base = match attr_value(shd, "color") {
    None => None
    Some(v) => if v == "auto" || v.length() == 0 { None } else { Some(v) }
  }
  let color = match
    resolve_themed_color(
      fg_base,
      attr_value(shd, "themeColor"),
      attr_value(shd, "themeTint"),
      attr_value(shd, "themeShade"),
      theme_map,
    ) {
    Some(hex) => "#" + hex
    None => ""
  }
  (background, val, color)
}

///|
/// §17.18.78 ST_Shd — the percentage-density families (`pct5` …
/// `pct95`) map to a mark-area fraction in [0,1]; `None` for any
/// non-percentage value. NOTE the WML ST_Shd ladder runs to `pct95`
/// (15 stops) whereas the DrawingML ST_PresetPatternVal ladder used by
/// the chart module stops at `pct90` (12 stops) — they are distinct
/// enumerations, so this table is WML-local and not shared.
fn shd_pct_density(val : String) -> Double? {
  match val {
    "pct5" => Some(0.05)
    "pct10" => Some(0.1)
    "pct12" => Some(0.125)
    "pct15" => Some(0.15)
    "pct20" => Some(0.2)
    "pct25" => Some(0.25)
    "pct30" => Some(0.3)
    "pct35" => Some(0.35)
    "pct37" => Some(0.375)
    "pct40" => Some(0.4)
    "pct45" => Some(0.45)
    "pct50" => Some(0.5)
    "pct55" => Some(0.55)
    "pct60" => Some(0.6)
    "pct62" => Some(0.625)
    "pct65" => Some(0.65)
    "pct70" => Some(0.7)
    "pct75" => Some(0.75)
    "pct80" => Some(0.8)
    "pct85" => Some(0.85)
    "pct87" => Some(0.875)
    "pct90" => Some(0.9)
    "pct95" => Some(0.95)
    _ => None
  }
}

///|
/// §17.18.78 ST_Shd — build the geometry child nodes of an 8×8 pattern
/// tile for a recognised pattern `@val`, drawn in the foreground `fg`.
/// `None` for `clear` / `nil` / `solid` / unknown so the caller falls
/// back to a flat fill. Mirrors the chart module's tile geometry
/// (`chart_pattern_tile_marks`) for visual consistency but is a WML-local
/// reimplementation keyed on ST_Shd enumerators (percentage dots,
/// horizontal / vertical / diagonal rules, and their crosses, plus the
/// `thin*` thinner-stroke variants).
fn shd_pattern_tile_marks(val : String, fg : String) -> Array[@xml.Node]? {
  fn line(x1 : Double, y1 : Double, x2 : Double, y2 : Double, sw : Double) {
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", fmt_double(x1)),
        @markup.attr("y1", fmt_double(y1)),
        @markup.attr("x2", fmt_double(x2)),
        @markup.attr("y2", fmt_double(y2)),
        @markup.attr("stroke", fg),
        @markup.attr("stroke-width", fmt_double(sw)),
      ],
      [],
    )
  }

  fn dot(cx : Double, cy : Double, r : Double) {
    @markup.elem_ns(
      "circle",
      @markup.svg_ns,
      [
        @markup.attr("cx", fmt_double(cx)),
        @markup.attr("cy", fmt_double(cy)),
        @markup.attr("r", fmt_double(r)),
        @markup.attr("fill", fg),
      ],
      [],
    )
  }

  // §17.18.78 percentage families — a single centred dot whose radius
  // grows with the density fraction (mark area ∝ fraction over the 8×8
  // cell, capped so the densest percentages still read as a pattern
  // rather than a solid block — `solid` is handled separately).
  match shd_pct_density(val) {
    Some(frac) => {
      let r = (frac * 64.0 / 3.14159).sqrt().min(3.6)
      return Some([dot(4.0, 4.0, r)])
    }
    None => ()
  }
  // Stripe / cross families. The `thin*` variants use a thinner stroke
  // than their base counterparts. Diagonal rules are tripled with
  // ±8 offsets so the 8×8 tile repeats seamlessly across cell edges.
  let down_diag = fn(sw : Double) {
    [
      line(0.0, 0.0, 8.0, 8.0, sw),
      line(-8.0, 0.0, 8.0, 16.0, sw),
      line(0.0, -8.0, 16.0, 8.0, sw),
    ]
  }
  let up_diag = fn(sw : Double) {
    [
      line(0.0, 8.0, 8.0, 0.0, sw),
      line(-8.0, 8.0, 8.0, -8.0, sw),
      line(0.0, 16.0, 16.0, 0.0, sw),
    ]
  }
  match val {
    "horzStripe" => Some([line(0.0, 4.0, 8.0, 4.0, 1.0)])
    "thinHorzStripe" => Some([line(0.0, 4.0, 8.0, 4.0, 0.5)])
    "vertStripe" => Some([line(4.0, 0.0, 4.0, 8.0, 1.0)])
    "thinVertStripe" => Some([line(4.0, 0.0, 4.0, 8.0, 0.5)])
    "horzCross" =>
      Some([line(0.0, 4.0, 8.0, 4.0, 1.0), line(4.0, 0.0, 4.0, 8.0, 1.0)])
    "thinHorzCross" =>
      Some([line(0.0, 4.0, 8.0, 4.0, 0.5), line(4.0, 0.0, 4.0, 8.0, 0.5)])
    "diagStripe" => Some(down_diag(1.0))
    "thinDiagStripe" => Some(down_diag(0.5))
    "reverseDiagStripe" => Some(up_diag(1.0))
    "thinReverseDiagStripe" => Some(up_diag(0.5))
    "diagCross" => {
      let marks = down_diag(1.0)
      for m in up_diag(1.0) {
        marks.push(m)
      }
      Some(marks)
    }
    "thinDiagCross" => {
      let marks = down_diag(0.5)
      for m in up_diag(0.5) {
        marks.push(m)
      }
      Some(marks)
    }
    _ => None
  }
}

///|
/// §17.18.78 ST_Shd — build an SVG `<pattern>` def for a pct/stripe/cross
/// `@val`, tiling the 8×8 cell with the `bg` background and the `fg`
/// marks. `None` for `clear` / `nil` / `solid` / unknown so the caller
/// keeps its solid-fill emit. `pattern_id` must be document-wide unique;
/// the caller derives it from a render-local counter.
fn build_shd_pattern_def(
  val : String,
  fg : String,
  bg : String,
  pattern_id : String,
) -> @xml.Node? {
  let marks = match shd_pattern_tile_marks(val, fg) {
    Some(m) => m
    None => return None
  }
  // §17.18.78 — the tile's panel is the `@fill` background. When `@fill`
  // is absent/auto the marks float over the document background, matching
  // Word's transparent-panel behaviour, so only emit the panel rect when
  // a concrete background colour resolved.
  let children : Array[@xml.Node] = []
  if bg.length() > 0 {
    children.push(
      @markup.elem_ns(
        "rect",
        @markup.svg_ns,
        [
          @markup.attr("x", "0"),
          @markup.attr("y", "0"),
          @markup.attr("width", "8"),
          @markup.attr("height", "8"),
          @markup.attr("fill", bg),
        ],
        [],
      ),
    )
  }
  for m in marks {
    children.push(m)
  }
  Some(
    @markup.elem_ns(
      "pattern",
      @markup.svg_ns,
      [
        @markup.attr("id", pattern_id),
        @markup.attr("patternUnits", "userSpaceOnUse"),
        @markup.attr("width", "8"),
        @markup.attr("height", "8"),
      ],
      children,
    ),
  )
}

///|
/// §17.18.78 ST_Shd — resolve a shaded region (paragraph or cell) into
/// the SVG fill string for its shading `<rect>`, optionally emitting a
/// sibling `<pattern>` def into `out` first.
///
/// `out` is the SAME node array the shading `<rect>` is pushed to; an
/// SVG `<pattern>` is referenced by id document-wide regardless of where
/// it sits, so emitting it as a sibling needs no global `<defs>`
/// collector. Returns `Some(fill)` to paint (the caller then pushes the
/// rect with `fill=<fill>`), or `None` when nothing should be painted.
///
///   * `clear` / `nil` / absent `@val` → `Some(background)` when a
///     background resolved, else `None` (byte-identical legacy path).
///   * `solid` → `Some(color)` (the FOREGROUND fills the region), or
///     `Some(background)` if no foreground resolved (graceful fallback).
///   * pct/stripe/cross `@val` → emit a `<pattern>` def and return
///     `Some("url(#id)")`. Unknown `@val` falls back to the solid
///     `background` so the region is never blank.
fn resolve_shading_fill(
  out : Array[@xml.Node],
  background : String,
  shd_val : String,
  shd_color : String,
  pattern_id : String,
) -> String? {
  match shd_val {
    "" | "clear" | "nil" =>
      // Legacy path: solid `@fill` background (or nothing).
      if background.length() > 0 {
        Some(background)
      } else {
        None
      }
    "solid" =>
      // §17.18.78 — `solid` fills the region with the FOREGROUND
      // `@color`, not `@fill`. Fall back to the background when no
      // foreground resolved so the region is still painted.
      if shd_color.length() > 0 {
        Some(shd_color)
      } else if background.length() > 0 {
        Some(background)
      } else {
        None
      }
    _ =>
      // pct / stripe / cross — a `<pattern>` tile painted over `@fill`.
      match
        build_shd_pattern_def(
          shd_val,
          if shd_color.length() > 0 {
            shd_color
          } else {
            "#000000"
          },
          background,
          pattern_id,
        ) {
        Some(pattern_node) => {
          out.push(pattern_node)
          Some("url(#" + pattern_id + ")")
        }
        // Unknown `@val` — graceful fallback to the solid background.
        None => if background.length() > 0 { Some(background) } else { None }
      }
  }
}

///|
/// §17.18.78 — build a document-wide-unique, stable, collision-free
/// `<pattern>` id from the shaded region's kind, its absolute SVG
/// coordinates, and the ST_Shd `@val`. Two shaded regions cannot occupy
/// the same absolute (x, y) on a page, so the coordinate pair is a stable
/// key with no threaded counter; the `@val` suffix keeps the id readable
/// in the emitted markup. Non-alphanumeric characters (the `.`/`-` of a
/// formatted double, any stray punctuation in `@val`) are mapped to `_`
/// so the result is a valid XML id / CSS-safe `url(#…)` fragment.
fn shd_pattern_id(
  kind : String,
  x : Double,
  y : Double,
  val : String,
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("wmlshd_")
  buf.write_string(kind)
  buf.write_char('_')
  fn sanitize(s : String) -> Unit {
    for c in s {
      let u = c.to_int()
      let alnum = (u >= 0x30 && u <= 0x39) ||
        (u >= 0x41 && u <= 0x5A) ||
        (u >= 0x61 && u <= 0x7A)
      buf.write_char(if alnum { c } else { '_' })
    }
  }

  sanitize(fmt_double(x))
  buf.write_char('_')
  sanitize(fmt_double(y))
  buf.write_char('_')
  sanitize(val)
  buf.to_string()
}

// =============================================================================
// §17.3.1 Paragraph layout
// =============================================================================

///|
/// Resolve §17.3.1 paragraph properties from <w:pPr>.
///
/// `apply_office_defaults` controls the §17.7.5.3 docDefaults
/// fallback: when `true` AND the resolved cascade supplies no
/// `<w:spacing>` element (i.e. the document has no styles part at
/// all, so `apply_styles_to_paragraph` left `<w:pPr>` untouched),
/// we substitute the Office built-in Normal style auto line multiple
/// and keep before/after spacing at zero. When `false` (a styles part
/// IS loaded), the document's own cascade — which has already been
/// folded into `<w:pPr>` upstream — wins and we leave the bare
/// `space_after = 0.0` / `LineHeightDefault` baseline alone.
fn resolve_para_props(
  p : @xml.Element,
  apply_office_defaults? : Bool = false,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
) -> ParaProps {
  let mut alignment = "left"
  let mut margin_left = 0.0
  let mut margin_left_chars : Double? = None
  let mut margin_right = 0.0
  let mut margin_right_chars : Double? = None
  let mut indent = 0.0
  let mut first_line_chars : Double? = None
  let mut hanging_chars : Double? = None
  // §17.7.5.3 — when the styles part is absent Office Normal applies
  // the AUTO line-height multiplier (276 / 240 = 1.15) but keeps
  // `space_before` / `space_after` at zero. Direct `<w:spacing>`
  // attributes on `<w:pPr>` still override below.
  let mut space_before = 0.0
  let mut space_after = 0.0
  let tab_stops : Array[(Double, String, String)] = []
  let mut line_height_spec : LineHeightSpec = if apply_office_defaults {
    LineHeightAuto(OFFICE_NORMAL_LINE_AUTO_MULTIPLE)
  } else {
    LineHeightDefault
  }
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
          let read_twips_px = fn(local_name : String) -> Double? {
            match parse_optional_double_attr(ind_el, local_name) {
              Some(n) => Some(n * TWIPS_TO_PX)
              None => None
            }
          }

          // §17.3.1.12 — strict `@start`/`@end` supersede legacy
          // `@left`/`@right`; char-unit forms supersede their twips
          // counterparts. Presence matters even for zero/negative
          // values, so this branch works from optional attributes.
          let left_twips = read_twips_px("left")
          let start_twips = read_twips_px("start")
          let left_chars = parse_optional_double_attr(ind_el, "leftChars")
          let start_chars = parse_optional_double_attr(ind_el, "startChars")
          match start_chars {
            Some(n) => {
              margin_left = 0.0
              margin_left_chars = Some(n)
            }
            None =>
              match start_twips {
                Some(px) => {
                  margin_left = px
                  margin_left_chars = None
                }
                None =>
                  match left_chars {
                    Some(n) => {
                      margin_left = 0.0
                      margin_left_chars = Some(n)
                    }
                    None =>
                      match left_twips {
                        Some(px) => margin_left = px
                        None => ()
                      }
                  }
              }
          }

          let right_twips = read_twips_px("right")
          let end_twips = read_twips_px("end")
          let right_chars = parse_optional_double_attr(ind_el, "rightChars")
          let end_chars = parse_optional_double_attr(ind_el, "endChars")
          match end_chars {
            Some(n) => {
              margin_right = 0.0
              margin_right_chars = Some(n)
            }
            None =>
              match end_twips {
                Some(px) => {
                  margin_right = px
                  margin_right_chars = None
                }
                None =>
                  match right_chars {
                    Some(n) => {
                      margin_right = 0.0
                      margin_right_chars = Some(n)
                    }
                    None =>
                      match right_twips {
                        Some(px) => margin_right = px
                        None => ()
                      }
                  }
              }
          }

          // first-line indent (positive) / hanging (negative).
          // §17.3.1.12 — char-based values are raw hundredths of a
          // character unit.  They are converted after run collection
          // through the same glyph resolver used for text measurement.
          let first_line_chars_attr = parse_optional_double_attr(
            ind_el, "firstLineChars",
          )
          let hanging_chars_attr = parse_optional_double_attr(
            ind_el, "hangingChars",
          )
          first_line_chars = match hanging_chars_attr {
            Some(_) => None
            None => first_line_chars_attr
          }
          hanging_chars = hanging_chars_attr

          let fl_twips = if first_line_chars_attr is Some(_) {
            None
          } else {
            read_twips_px("firstLine")
          }
          let hg_twips = if hanging_chars_attr is Some(_) {
            None
          } else {
            read_twips_px("hanging")
          }
          let fl = match (fl_twips, hg_twips) {
            // `@firstLine` and `@hanging` are mutually exclusive; if
            // both twips forms are present, ECMA-376 says
            // `@firstLine` is ignored.
            (Some(_), Some(_)) => 0.0
            (Some(px), None) => px
            _ => 0.0
          }
          let hg = match hg_twips {
            Some(px) => px
            None => 0.0
          }
          indent = fl - hg
        }
        None => ()
      }
      // §17.3.1.33 <w:spacing>
      match first_child_named(p_pr, "spacing") {
        Some(sp_el) => {
          // before / after in twips. Each attribute is independently
          // optional on `<w:spacing>` — missing `@before`/`@after`
          // means "no explicit override on this side", NOT "zero".
          // Without this guard, the upstream Office Normal default
          // (10 pt after) is silently clobbered the moment a
          // paragraph declares a `<w:spacing>` for `@line` alone.
          match attr_value(sp_el, "before") {
            Some(v) =>
              try @string.parse_double(v) catch {
                _ => ()
              } noraise {
                n => space_before = n * TWIPS_TO_PX
              }
            None => ()
          }
          match attr_value(sp_el, "after") {
            Some(v) =>
              try @string.parse_double(v) catch {
                _ => ()
              } noraise {
                n => space_after = n * TWIPS_TO_PX
              }
            None => ()
          }
          // `line` + `lineRule` — `auto` makes `line` a multiplier of
          // 240 (240 = single-line); `exact` / `atLeast` make `line`
          // a fixed twentieths-of-a-point measurement.
          match attr_value(sp_el, "line") {
            None => ()
            Some(line_v) =>
              try @string.parse_double(line_v) catch {
                _ => ()
              } noraise {
                line_raw => {
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
                      // §17.18.86 ST_TabTlc — the optional `@leader`
                      // fills the tab gap with a repeated glyph: none
                      // (default) / dot / hyphen / underscore / heavy /
                      // middleDot.  Carried alongside the stop so the
                      // resolved tab span can paint the leader.
                      let leader = attr_value(tab_el, "leader").unwrap_or(
                        "none",
                      )
                      tab_stops.push(
                        (pos_twips * TWIPS_TO_PX, val_kind, leader),
                      )
                    }
                  }
                }
              _ => ()
            }
          }
      }
      tab_stops.sort_by(fn(a, b) {
        let (ap, _, _) = a
        let (bp, _, _) = b
        ap.compare(bp)
      })
    }
  }
  // §17.3.1.6 / §17.18.78 `<w:shd>` — paragraph shading.  The element
  // carries three independent groups (§17.18.78 ST_Shd):
  //   @fill / @themeFill / @themeFillTint / @themeFillShade — the
  //     BACKGROUND colour cascade.
  //   @val — the ST_Shd PATTERN selector (clear/nil/solid/pct*/
  //     stripe*/cross*).
  //   @color / @themeColor / @themeTint / @themeShade — the PATTERN /
  //     FOREGROUND colour cascade (same resolver as the background).
  // The resolved background string keeps its historical meaning so
  // the clear/nil/absent path stays byte-identical; @val and @color
  // are surfaced separately for the emitter to act on.
  let (background, shd_val, shd_color) = match first_child_named(p, "pPr") {
    None => ("", "", "")
    Some(p_pr) =>
      match first_child_named(p_pr, "shd") {
        None => ("", "", "")
        Some(shd) => resolve_shd(shd, theme_map)
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
  // §17.3.1.11 `<w:framePr>` — parse the legacy floating-frame
  // attributes when present.  All numeric attributes are in twips
  // (ST_TwipsMeasure) and converted to CSS pixels here.  Missing
  // attributes leave the field at its zero / empty default; the
  // layout pass then honours the spec defaults (xAlign / yAlign /
  // hAnchor / vAnchor).
  let frame_pr : FramePr? = match first_child_named(p, "pPr") {
    None => None
    Some(p_pr) =>
      match first_child_named(p_pr, "framePr") {
        None => None
        Some(fp) => {
          let read_twips = fn(name : String) -> Double {
            match attr_value(fp, name) {
              None => 0.0
              Some(v) =>
                try @string.parse_double(v) catch {
                  _ => 0.0
                } noraise {
                  n => n * TWIPS_TO_PX
                }
            }
          }
          Some(FramePr::{
            w_px: read_twips("w"),
            h_px: read_twips("h"),
            x_px: read_twips("x"),
            y_px: read_twips("y"),
            h_anchor: attr_value(fp, "hAnchor").unwrap_or(""),
            v_anchor: attr_value(fp, "vAnchor").unwrap_or(""),
            x_align: attr_value(fp, "xAlign").unwrap_or(""),
            y_align: attr_value(fp, "yAlign").unwrap_or(""),
            wrap: attr_value(fp, "wrap").unwrap_or(""),
            h_space_px: read_twips("hSpace"),
            v_space_px: read_twips("vSpace"),
            drop_cap: attr_value(fp, "dropCap").unwrap_or(""),
            lines: match attr_value(fp, "lines") {
              None => 1
              Some(v) =>
                try @string.parse_int(v) catch {
                  _ => 1
                } noraise {
                  n => if n > 0 { n } else { 1 }
                }
            },
          })
        }
      }
  }
  ParaProps::{
    alignment,
    margin_left,
    margin_left_chars,
    margin_right,
    margin_right_chars,
    indent,
    first_line_chars,
    hanging_chars,
    space_before,
    space_after,
    tab_stops,
    background,
    shd_val,
    shd_color,
    border_top,
    border_left,
    border_bottom,
    border_right,
    line_height: line_height_spec,
    contextual_spacing,
    p_style,
    page_break_before,
    frame_pr,
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
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
) -> RunSpan {
  let mut font_family = DEFAULT_FONT_FAMILY
  let mut font_size_pt = default_font_size_pt
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
                let hp : Int = @string.parse_int(v)
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
      // The theme-part bytes are loaded into the document at the
      // context layer (`Document.theme`) and a parsed `ThemeColorMap`
      // is built at the top of `render_svg`, then threaded down to this
      // resolver across every flow — body paragraphs, body-table cells,
      // and header / footer decoration — so `themeColor` / `themeTint` /
      // `themeShade` resolve against the real theme.  The optional
      // `theme_map` parameter defaults to `ThemeColorMap::empty()` only
      // for callers that render runs outside a themed document context;
      // there the explicit `@val` survives per §17.15.1.51.
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
              try @string.parse_double(v) catch {
                _ => ()
              } noraise {
                d => letter_spacing_px = d / 20.0 * 96.0 / 72.0
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
              try @string.parse_double(v) catch {
                _ => ()
              } noraise {
                d => position_offset_px = d / 2.0 * 96.0 / 72.0
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
              try @string.parse_double(v) catch {
                _ => ()
              } noraise {
                d => if d > 0.0 { scale_pct = d }
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
              try @string.parse_double(v) catch {
                _ => ()
              } noraise {
                d => if d >= 0.0 { kern_half_points = d }
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
  let font_request = build_run_font_request(
    font_family,
    if bold {
      700
    } else {
      400
    },
    italic,
    font_descriptors,
  )
  RunSpan::{
    text: "",
    font_family: css_font_family_from_request(font_request),
    font_request,
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
    math: None,
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
    tab_leader: "",
    // Paragraph-level toggles; default ON, overridden per paragraph in
    // `collect_paragraph_spans`.
    auto_space_de: true,
    auto_space_dn: true,
    // §17.16.22 — no hyperlink target by default; set when the run is
    // emitted inside a `<w:hyperlink>` whose r:id / anchor resolved.
    href: "",
    // §17.16.2 — not a bookmark anchor by default; set only on the
    // zero-width marker span pushed for a `<w:bookmarkStart>`.
    bookmark: "",
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
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  chart_resolver : (@xml.Element) -> @xml.Node?,
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  // §17.16.22 — per-stream bound hyperlink-target resolver; threaded into
  // the `<w:hyperlink>` descent so a run's r:id resolves to a URL.
  hyperlink_resolver? : (String) -> String? = _ => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
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
  // The synthetic marker element injected by `apply_numbering_marker`
  // carries EITHER a text marker (`val`, the §17.9.11 lvlText path) or
  // a PICTURE bullet (`picHref` + `picAspect` + optional `picAlt`, the
  // §17.9.9 lvlPicBulletId path).  When a picture is present it wins;
  // otherwise we fall back to the text marker.  Both branches resolve
  // the same run template so the bullet adopts the level's font size /
  // colour for sizing and alignment.
  let marker_el : @xml.Element? = match first_child_named(p, "pPr") {
    None => None
    Some(p_pr) => first_child_named(p_pr, "__bulletMarker")
  }
  match marker_el {
    None => ()
    Some(marker_el) => {
      let template = match first_child_named(p, "r") {
        Some(r) =>
          resolve_run_props(
            r,
            default_font_size_pt~,
            theme_map~,
            font_map~,
            font_descriptors~,
          )
        None =>
          match first_child_named(p, "pPr") {
            Some(p_pr) =>
              match first_child_named(p_pr, "rPr") {
                Some(_) =>
                  resolve_run_props(
                    p,
                    default_font_size_pt~,
                    theme_map~,
                    font_map~,
                    font_descriptors~,
                  )
                None =>
                  default_run_template(default_font_size_pt~, font_descriptors~)
              }
            None =>
              default_run_template(default_font_size_pt~, font_descriptors~)
          }
      }
      match attr_value(marker_el, "picHref") {
        // §17.9.9 / §17.9.20 — picture bullet.  Size the bullet to the
        // level run's em-box (font size in px), matching Word, which
        // scales a picture bullet to the surrounding line.  Width is
        // derived from the bullet's intrinsic aspect so a non-square
        // image is not distorted; an unknown / zero aspect renders the
        // bullet square.  We reserve a trailing space the same width
        // the text marker's `" "` would have, so the following
        // run starts at the same x it would after a text marker.
        Some(href) => {
          let bullet_h = template.font_size_pt * @glyph.pt_to_px
          let aspect = parse_double_attr(marker_el, "picAspect", 0.0)
          let bullet_w = if aspect > 0.0 { bullet_h * aspect } else { bullet_h }
          let alt = attr_value(marker_el, "picAlt").unwrap_or("")
          let space_w = measure_run_text("\u{0020}", template, warnings)
          let image : InlineImage = {
            href,
            width_px: bullet_w,
            height_px: bullet_h,
            alt_text: alt,
            wrap_mode: "",
            behind_doc: false,
            position_h_relative: "",
            position_v_relative: "",
          }
          // Reserve `bullet_w + space_w` of advance but draw the image
          // at `bullet_w`; `with_inline_image` would tie the two
          // together, so build the span directly to keep the gap.
          let bullet_span = with_inline_image(template, image)
          spans.push({ ..bullet_span, width_px: bullet_w + space_w })
        }
        // §17.9.11 lvlText — text marker (byte-identical legacy path).
        None =>
          match attr_value(marker_el, "val") {
            Some(v) => {
              let marker = v + "\u{0020}"
              let w = measure_run_text(marker, template, warnings)
              spans.push(with_text(template, marker, w))
            }
            None => ()
          }
      }
    }
  }
  collect_paragraph_spans_into(
    p,
    false,
    spans,
    warnings,
    image_resolver,
    chart_resolver,
    default_font_size_pt~,
    theme_map~,
    font_map~,
    font_descriptors~,
    math_font~,
    hyperlink_resolver~,
    field_context~,
    field_registry~,
  )
  // §17.3.1.10/.11 — resolve the paragraph's autoSpaceDE / autoSpaceDN
  // toggles once (both default ON when absent) and stamp every span so
  // the measurer and emitter apply 和欧間隔 consistently.  When both are
  // ON (the common case) the spans already carry the default, so the
  // remap is a no-op clone; we only pay it to honour an explicit
  // `<w:autoSpaceDE w:val="0"/>` / `<w:autoSpaceDN w:val="0"/>`.
  let p_pr = first_child_named(p, "pPr")
  let de = para_toggle_default_true(p_pr, "autoSpaceDE")
  let dn = para_toggle_default_true(p_pr, "autoSpaceDN")
  if de && dn {
    return spans
  }
  let adjusted : Array[RunSpan] = []
  for s in spans {
    adjusted.push({ ..s, auto_space_de: de, auto_space_dn: dn })
  }
  adjusted
}

///|
/// Read a §17.3 OnOff paragraph toggle that DEFAULTS TO TRUE when the
/// element is absent (e.g. autoSpaceDE / autoSpaceDN): present-with-no-
/// `@val` or `@val="true"` ⇒ true; `@val="false"`/`"0"` ⇒ false;
/// absent ⇒ true.  (`has_toggle` defaults absent to FALSE, so it is
/// wrong for default-on toggles.)
fn para_toggle_default_true(p_pr : @xml.Element?, name : String) -> Bool {
  match p_pr {
    None => true
    Some(pr) =>
      match first_child_named(pr, name) {
        None => true
        Some(el) => parse_xsd_on_off_or(attr_value(el, "val"), true)
      }
  }
}

///|
/// Default RunSpan template used when the paragraph has no `<w:r>` to
/// derive font / colour from. `default_font_size_pt` lets callers
/// substitute the §17.7.5.3 Office Normal 11 pt baseline when the
/// document supplies no `<w:styles>` part.
fn default_run_template(
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
) -> RunSpan {
  let font_request = build_run_font_request(
    DEFAULT_FONT_FAMILY,
    400,
    false,
    font_descriptors,
  )
  {
    text: "",
    font_family: css_font_family_from_request(font_request),
    font_request,
    font_size_pt: default_font_size_pt,
    bold: false,
    italic: false,
    underline: false,
    underline_style: "",
    strike: false,
    color: "",
    highlight: "",
    width_px: 0.0,
    inline_image: None,
    math: None,
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
    tab_leader: "",
    // §17.3.1.10/.11 — both East-Asian auto-space toggles default ON;
    // `collect_paragraph_spans` overrides them per paragraph.
    auto_space_de: true,
    auto_space_dn: true,
    // §17.16.22 — no hyperlink target by default.
    href: "",
    // §17.16.2 — no bookmark anchor by default.
    bookmark: "",
  }
}

///|
/// Derive the run template for an Office Math zone.  OMML runs carry
/// no `<w:rPr>` of their own in the WML sense, so the equation
/// borrows the font / size / colour of the first `<w:r>` sibling in
/// `parent` (the enclosing paragraph or wrapper); when the paragraph
/// has no run, the document default template is used.
fn math_run_template(
  parent : @xml.Element,
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
) -> RunSpan {
  match first_child_named(parent, "r") {
    Some(r) =>
      resolve_run_props(
        r,
        default_font_size_pt~,
        theme_map~,
        font_map~,
        font_descriptors~,
      )
    None => default_run_template(default_font_size_pt~, font_descriptors~)
  }
}

///|
/// Build the active §17.16 registry only when a caller supplied field
/// context. Without context the renderer preserves cached field-result
/// runs and never re-evaluates simple fields implicitly.
fn active_field_registry_for(
  field_context : @field_eval.FieldContext?,
  field_registry : @field_eval.FieldRegistry?,
) -> @field_eval.FieldRegistry? {
  match field_context {
    None => None
    Some(_) =>
      match field_registry {
        Some(registry) => Some(registry)
        None => Some(@field_eval.FieldRegistry::with_builtins())
      }
  }
}

///|
/// Evaluate a decoded §17.16 field through the field_eval package.
/// Returns None for unregistered instructions and `FieldResult::Empty`
/// so the caller can preserve cached field-result runs.
fn evaluated_field_result(
  field : @field_eval.Field,
  field_context : @field_eval.FieldContext?,
  field_registry : @field_eval.FieldRegistry?,
) -> @field_eval.FieldResult? {
  let ctx = match field_context {
    None => return None
    Some(value) => value
  }
  let registry = match field_registry {
    Some(value) => value
    None => @field_eval.FieldRegistry::with_builtins()
  }
  match registry.lookup(field.instruction.canonical_name()) {
    None => return None
    Some(_) => ()
  }
  let result = @field_eval.evaluate_field(field, ctx, registry)
  match result {
    @field_eval.Empty => None
    _ => Some(result)
  }
}

///|
/// Evaluate a §17.16.19 `<w:fldSimple>` through the field_eval package.
/// Returns None for malformed fields, unregistered instructions, and
/// `FieldResult::Empty` so the caller can render the cached child runs.
fn evaluated_simple_field_result(
  fld_simple : @xml.Element,
  field_context : @field_eval.FieldContext?,
  field_registry : @field_eval.FieldRegistry?,
) -> @field_eval.FieldResult? {
  let typed = try @domain.CT_SimpleField::new(fld_simple) catch {
    _ => return None
  } noraise {
    value => value
  }
  let field = try @field_eval.decode_simple_field(typed) catch {
    _ => return None
  } noraise {
    value => value
  }
  evaluated_field_result(field, field_context, field_registry)
}

///|
priv struct ComplexFieldReplacement {
  start_run : Int
  end_run : Int
  result : @field_eval.FieldResult
  template_run : @xml.Element
}

///|
/// Decode direct child runs with field_eval's complex-field range API
/// and build non-overlapping live-result replacements. Fields that are
/// unregistered, malformed, or evaluate to Empty are omitted so the
/// caller's ordinary cached-run streaming remains the fallback.
fn complex_field_replacements(
  parent : @xml.Element,
  field_context : @field_eval.FieldContext?,
  field_registry : @field_eval.FieldRegistry?,
) -> Array[ComplexFieldReplacement] {
  match field_context {
    None => return []
    Some(_) => ()
  }
  let run_elements : Array[@xml.Element] = []
  let runs : Array[@domain.CT_R] = []
  for child in parent.children {
    match child {
      Element(e) =>
        if e.name.local_name == "r" {
          let run = try @domain.CT_R::new(e) catch {
            _ => return []
          } noraise {
            value => value
          }
          run_elements.push(e)
          runs.push(run)
        }
      _ => ()
    }
  }
  if runs.length() == 0 {
    return []
  }
  let ranges = try @field_eval.decode_field_run_ranges(runs) catch {
    _ => return []
  } noraise {
    value => value
  }
  let replacements : Array[ComplexFieldReplacement] = []
  let mut covered_until = -1
  for start in 0..<runs.length() {
    if start <= covered_until {
      continue
    }
    let mut selected : @field_eval.DecodedFieldRange? = None
    for range in ranges {
      if selected is None && range.start_run == start {
        selected = Some(range)
      }
    }
    match selected {
      None => ()
      Some(range) =>
        match
          evaluated_field_result(range.field, field_context, field_registry) {
          None => ()
          Some(result) =>
            match run_elements.get(range.start_run) {
              None => ()
              Some(template_run) => {
                replacements.push({
                  start_run: range.start_run,
                  end_run: range.end_run,
                  result,
                  template_run,
                })
                covered_until = range.end_run
              }
            }
        }
    }
  }
  replacements
}

///|
fn emit_field_result_span(
  result : @field_eval.FieldResult,
  template : RunSpan,
  hyperlink_styling : Bool,
  spans : Array[RunSpan],
  warnings : Array[String],
) -> Unit {
  let text = result.to_text()
  if text.length() > 0 {
    let w = measure_run_text(text, template, warnings)
    let span0 = with_text(template, text, w)
    let span = match result {
      @field_eval.Hyperlink(url, _) =>
        if url.length() > 0 {
          { ..span0, href: url }
        } else {
          span0
        }
      _ => span0
    }
    spans.push(apply_hyperlink_styling(span, hyperlink_styling))
  }
}

///|
/// Emit an evaluated simple-field result as one run-shaped span. The
/// first cached child run supplies formatting; evaluation text, switches,
/// and hyperlink display stay owned by `@field_eval`.
fn emit_evaluated_simple_field(
  fld_simple : @xml.Element,
  hyperlink_styling : Bool,
  spans : Array[RunSpan],
  warnings : Array[String],
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> Bool {
  let result = match
    evaluated_simple_field_result(fld_simple, field_context, field_registry) {
    None => return false
    Some(value) => value
  }
  let template = match first_child_named(fld_simple, "r") {
    Some(r) =>
      resolve_run_props(
        r,
        default_font_size_pt~,
        theme_map~,
        font_map~,
        font_descriptors~,
      )
    None => default_run_template(default_font_size_pt~, font_descriptors~)
  }
  emit_field_result_span(result, template, hyperlink_styling, spans, warnings)
  true
}

///|
fn emit_complex_field_replacement(
  replacement : ComplexFieldReplacement,
  hyperlink_styling : Bool,
  spans : Array[RunSpan],
  warnings : Array[String],
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
) -> Unit {
  let template = resolve_run_props(
    replacement.template_run,
    default_font_size_pt~,
    theme_map~,
    font_map~,
    font_descriptors~,
  )
  emit_field_result_span(
    replacement.result,
    template,
    hyperlink_styling,
    spans,
    warnings,
  )
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
///
/// §17.16.22 — the `<w:hyperlink>` case ALSO resolves the link target:
/// it reads `r:id` (the relationships-namespace `id` attribute), maps it
/// through `hyperlink_resolver` (bound to this stream's OPC part) to an
/// external URL, or falls back to `#<w:anchor>` for an internal bookmark.
/// The resolved href is stamped onto every span produced by the
/// hyperlink's descended runs — the SAME post-recursion stamping idiom
/// the `<w:ins>` / `<w:del>` cases use — so the emitter wraps each run's
/// `<text>` in an `<a xlink:href="…">`.  `hyperlink_resolver` defaults to
/// "no target", which (with no `w:anchor`) leaves the href empty and the
/// output byte-identical.
fn collect_paragraph_spans_into(
  parent : @xml.Element,
  hyperlink_styling : Bool,
  spans : Array[RunSpan],
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  chart_resolver : (@xml.Element) -> @xml.Node?,
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  hyperlink_resolver? : (String) -> String? = _ => None,
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> Unit {
  let complex_replacements = complex_field_replacements(
    parent, field_context, field_registry,
  )
  let mut complex_replacement_index = 0
  let mut complex_skip_until = -1
  let mut run_ordinal = 0
  for child in parent.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "r" => {
            let current_run = run_ordinal
            run_ordinal = run_ordinal + 1
            if current_run <= complex_skip_until {
              ()
            } else if complex_replacement_index < complex_replacements.length() &&
              complex_replacements[complex_replacement_index].start_run ==
              current_run {
              let replacement = complex_replacements[complex_replacement_index]
              emit_complex_field_replacement(
                replacement,
                hyperlink_styling,
                spans,
                warnings,
                default_font_size_pt~,
                theme_map~,
                font_map~,
                font_descriptors~,
              )
              complex_skip_until = replacement.end_run
              complex_replacement_index = complex_replacement_index + 1
            } else {
              emit_run_spans(
                e,
                hyperlink_styling,
                spans,
                warnings,
                image_resolver,
                chart_resolver,
                default_font_size_pt~,
                theme_map~,
                font_map~,
                font_descriptors~,
              )
            }
          }
          "hyperlink" => {
            // §17.16.22 CT_Hyperlink — descend with hyperlink styling on,
            // then stamp the resolved link target onto the produced spans.
            //
            // Target resolution (spec order): an `r:id` names a
            // `/hyperlink` relationship whose (External) target is the
            // URL — resolved through `hyperlink_resolver` (bound to this
            // stream's OPC part, so a header / footer hyperlink resolves
            // against ITS rels).  When there is no r:id (or it resolves
            // to nothing), a `w:anchor` names an in-document bookmark and
            // the href is `#<anchor>` for client-side navigation.  When
            // neither yields a target the href stays empty and no `<a>`
            // is emitted (byte-identical to the pre-link styling-only
            // behaviour).
            let href = match attr_rid(e) {
              Some(rid) =>
                match hyperlink_resolver(rid) {
                  Some(url) => url
                  None =>
                    match attr_value(e, "anchor") {
                      Some(anchor) => "#" + anchor
                      None => ""
                    }
                }
              None =>
                match attr_value(e, "anchor") {
                  Some(anchor) => "#" + anchor
                  None => ""
                }
            }
            let start = spans.length()
            collect_paragraph_spans_into(
              e,
              true,
              spans,
              warnings,
              image_resolver,
              chart_resolver,
              default_font_size_pt~,
              theme_map~,
              font_map~,
              font_descriptors~,
              math_font~,
              hyperlink_resolver~,
              field_context~,
              field_registry~,
            )
            if href.length() > 0 {
              for i in start..<spans.length() {
                spans[i] = { ..spans[i], href, }
              }
            }
          }
          "fldSimple" => {
            // §17.16.19 `<w:fldSimple>` — preserve cached result runs
            // unless the caller supplied a §17.16 FieldContext.  The
            // parse/evaluate SoT remains `@field_eval`; this branch only
            // chooses between evaluated text and the document's cached
            // child runs.
            let emitted = emit_evaluated_simple_field(
              e,
              hyperlink_styling,
              spans,
              warnings,
              default_font_size_pt~,
              theme_map~,
              font_map~,
              font_descriptors~,
              field_context~,
              field_registry~,
            )
            if !emitted {
              collect_paragraph_spans_into(
                e,
                hyperlink_styling,
                spans,
                warnings,
                image_resolver,
                chart_resolver,
                default_font_size_pt~,
                theme_map~,
                font_map~,
                font_descriptors~,
                math_font~,
                hyperlink_resolver~,
                field_context~,
                field_registry~,
              )
            }
          }
          "smartTag" | "customXml" | "sdt" | "sdtContent" =>
            // §17.5.1.13 smartTag + §17.5.2.x SDT wrappers —
            // descend transparently.
            collect_paragraph_spans_into(
              e,
              hyperlink_styling,
              spans,
              warnings,
              image_resolver,
              chart_resolver,
              default_font_size_pt~,
              theme_map~,
              font_map~,
              font_descriptors~,
              math_font~,
              hyperlink_resolver~,
              field_context~,
              field_registry~,
            )
          // §22.1.2.77 `<m:oMath>` — an inline Office Math zone.
          // Lay it out to a self-contained SVG `<g>` at the
          // surrounding run's font size and emit one math span.
          // The font / colour come from the first `<w:r>` of the
          // paragraph (or the document defaults when there is
          // none) so the equation matches the body text.
          "oMath" => {
            let template = math_run_template(
              parent,
              default_font_size_pt~,
              theme_map~,
              font_map~,
              font_descriptors~,
            )
            emit_omath_span(e, template, spans, math_font~)
          }
          // §22.1.2.78 `<m:oMathPara>` — a paragraph-level math
          // wrapper holding one or more `<m:oMath>` children;
          // emit each as its own math span.
          "oMathPara" => {
            let template = math_run_template(
              parent,
              default_font_size_pt~,
              theme_map~,
              font_map~,
              font_descriptors~,
            )
            for math_child in e.children {
              match math_child {
                Element(me) =>
                  if me.name.local_name == "oMath" {
                    emit_omath_span(me, template, spans, math_font~)
                  }
                _ => ()
              }
            }
          }
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
              warnings,
              image_resolver,
              chart_resolver,
              default_font_size_pt~,
              theme_map~,
              font_map~,
              font_descriptors~,
              math_font~,
              hyperlink_resolver~,
              field_context~,
              field_registry~,
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
              warnings,
              image_resolver,
              chart_resolver,
              default_font_size_pt~,
              theme_map~,
              font_map~,
              font_descriptors~,
              math_font~,
              hyperlink_resolver~,
              field_context~,
              field_registry~,
            )
            for i in start..<spans.length() {
              spans[i] = { ..spans[i], strike: true }
            }
          }
          "bookmarkStart" =>
            // §17.16.2 `<w:bookmarkStart w:name="…">` (an EG_RunLevelElts
            // that may appear mid-paragraph between runs) — push a
            // zero-width, glyph-less marker span carrying the RAW
            // `w:name`.  `append_line_nodes` turns it into an empty
            // `<g id="<name>">` at the span's start x / line top so a
            // `<w:hyperlink w:anchor="<name>">` — rendered as
            // `<a xlink:href="#<name>">` — has a fragment target to
            // navigate to.  The span has `text: ""` / `width_px: 0.0`,
            // so it is inert to measurement, line breaking, justification
            // and the cursor advance; it cannot shift any following
            // content.  §17.16.3 `<w:bookmarkEnd>` only closes the range
            // and needs no output, so it is ignored.  A bookmark with no
            // (or an empty) `w:name` is skipped — there is nothing for a
            // `#fragment` to address.
            match attr_value(e, "name") {
              Some(bookmark_name) =>
                if bookmark_name.length() > 0 {
                  let marker = default_run_template(
                    default_font_size_pt~,
                    font_descriptors~,
                  )
                  spans.push({ ..marker, bookmark: bookmark_name })
                }
              None => ()
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

///|
/// §17.16.5.4 `<w:checkBox>` — when a run's typed `CT_FldChar`
/// begin marker hosts a typed `<w:ffData>/<w:checkBox>` form field,
/// return the box glyph for its domain-owned state.
fn form_checkbox_glyph(fld_char : @domain.CT_FldChar) -> String? {
  match fld_char.fld_char_type {
    @domain.FldCharTypeBegin => ()
    _ => return None
  }
  let ff = match fld_char.ff_data {
    Some(data) => data
    None => return None
  }
  let cb = match ff.check_box {
    Some(check_box) => check_box
    None => return None
  }
  Some(if cb.checked_state() { "\u{2611}" } else { "\u{2610}" })
}

///|
fn emit_run_spans(
  r : @xml.Element,
  hyperlink_styling : Bool,
  spans : Array[RunSpan],
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  chart_resolver : (@xml.Element) -> @xml.Node?,
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
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
  let template = resolve_run_props(
    r,
    default_font_size_pt~,
    theme_map~,
    font_map~,
    font_descriptors~,
  )
  // Walk <w:t>, <w:delText>, <w:tab>, <w:br>, etc., emitting spans.
  for r_child in r.children {
    match r_child {
      Element(re) =>
        match re.name.local_name {
          "t" | "delText" => {
            let text = text_content(re)
            if text.length() > 0 {
              let w = measure_run_text(text, template, warnings)
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
            let w = measure_run_text(text, template, warnings)
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
                let font_request = build_run_font_request(
                  font,
                  if template.bold {
                    700
                  } else {
                    400
                  },
                  template.italic,
                  font_descriptors,
                )
                let sym_template = {
                  ..template,
                  font_family: css_font_family_from_request(font_request),
                  font_request,
                  inline_image: None,
                }
                let w = measure_run_text(ch, sym_template, warnings)
                let sym_span = with_text(sym_template, ch, w)
                spans.push(apply_hyperlink_styling(sym_span, hyperlink_styling))
              }
              None => ()
            }
          "drawing" =>
            emit_drawing_span(
              re, template, hyperlink_styling, spans, warnings, image_resolver, chart_resolver,
            )
          "object" | "pict" => {
            // §17.3.3.19 `<w:object>` / §17.3.3.21 `<w:pict>` — legacy
            // OLE / VML containers. Modern Word writes both with a
            // child `<w:drawing>` carrying the actual preview blip;
            // walk for it so the renderer still surfaces the image.
            match first_child_named(re, "drawing") {
              Some(d) =>
                emit_drawing_span(
                  d, template, hyperlink_styling, spans, warnings, image_resolver,
                  chart_resolver,
                )
              None => ()
            }
            // §19 VML legacy graphics — `<w:pict>` also legally hosts
            // a raw VML `<v:shape>` / `<v:line>` / `<v:rect>` tree
            // (predates DrawingML).  Translate the VML subtree to
            // SVG primitives via `@vml.render_vml` and embed the
            // resulting group through the inline-math baseline slot
            // (the same slot the WPS-shape renderer uses): the line
            // emitter places the group at the running x cursor and
            // the baseline.
            //
            // The translated SVG fragment carries genuine
            // `<rect>` / `<path>` / `<line>` / `<ellipse>` /
            // `<image>` / `<text>` primitives so the catalog
            // differential render check (`svg_visible_skeleton`)
            // observes the §19 element's contribution and credits
            // the section as `rendered`.  Full VML semantics
            // (3-D extrusion, complex gradients, shape templates)
            // remain a richer translation problem; the present
            // mapping covers every element ECMA-376 §19.1 /
            // §19.2 declares.
            for kid in re.children {
              if kid is @xml.Node::Element(ve) {
                let ns = ve.name.ns.unwrap_or("")
                if ns == @vml.vml_ns || ns == @vml.vml_office_ns {
                  let w_px = vml_style_width_px(ve)
                  let h_px = vml_style_height_px(ve)
                  let svg_nodes = @vml.render_vml_with_size(ve, w_px, h_px)
                  if svg_nodes.length() > 0 {
                    // Wrap the translated nodes in a `<g>` and
                    // surface as an inline math payload so the
                    // existing line emitter places it on the
                    // baseline.  The translated nodes already live
                    // in the element's own coordinate space; we
                    // shift up by `h_px` so the bottom edge sits
                    // on the baseline (matching Word's
                    // inline-shape baseline alignment).
                    let group : @xml.Element = {
                      name: @markup.qname_ns("g", @markup.svg_ns),
                      attributes: [
                        @markup.attr(
                          "transform",
                          "translate(0," + fmt_double(-h_px) + ")",
                        ),
                        @markup.attr("class", "vml"),
                      ],
                      children: svg_nodes,
                    }
                    let payload : MathPayload = {
                      group,
                      width_px: w_px,
                      ascent_px: h_px,
                      descent_px: 0.0,
                    }
                    spans.push(
                      apply_hyperlink_styling(
                        with_math(template, payload),
                        hyperlink_styling,
                      ),
                    )
                  }
                }
              }
            }
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
            let w = measure_run_text(placeholder, template, warnings)
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
            let w = measure_run_text(placeholder, template, warnings)
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
            let w = measure_run_text(placeholder, template, warnings)
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
            let w = measure_run_text(placeholder, template, warnings)
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
            let w = measure_run_text(placeholder, template, warnings)
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
          "fldChar" =>
            // §17.16.18 fldChar — a complex-field boundary.  Ordinary
            // fields, text form fields (FORMTEXT) and dropdowns
            // (FORMDROPDOWN) render their result through the runs
            // between the "separate" and "end" boundaries, so those
            // boundaries emit no glyph here.  The one boundary that
            // carries its OWN visible glyph is a §17.16.5.4 form
            // checkbox at the "begin" boundary: emit ☑ / ☐ for its
            // checked / unchecked state.
            try @domain.CT_FldChar::new(re) catch {
              _ => ()
            } noraise {
              fld_char =>
                match form_checkbox_glyph(fld_char) {
                  Some(ch) => {
                    let w = measure_run_text(ch, template, warnings)
                    spans.push(
                      apply_hyperlink_styling(
                        with_text(template, ch, w),
                        hyperlink_styling,
                      ),
                    )
                  }
                  None => ()
                }
            }
          _ => ()
        }
      Text(t) | CData(t) => {
        let w = measure_run_text(t, template, warnings)
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
                let local_name = e.name.local_name
                if local_name == "wrapSquare" {
                  info = { ..info, wrap_mode: "Square" }
                } else if local_name == "wrapTight" {
                  info = { ..info, wrap_mode: "Tight" }
                } else if local_name == "wrapNone" {
                  info = { ..info, wrap_mode: "None" }
                } else if local_name == "wrapTopAndBottom" {
                  info = { ..info, wrap_mode: "TopAndBottom" }
                } else if local_name == "wrapThrough" {
                  info = { ..info, wrap_mode: "Through" }
                } else if local_name == "positionH" {
                  match attr_value(e, "relativeFrom") {
                    Some(rel) => info = { ..info, position_h_relative: rel }
                    None => ()
                  }
                } else if local_name == "positionV" {
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
/// True when `drawing` is a *side-wrapping* floating anchor — a
/// `<wp:anchor>` whose wrap is `Square` / `Tight` / `Through` (the
/// modes that narrow the surrounding text band).  `None` /
/// `TopAndBottom` / inline drawings return false: they keep their
/// existing inline / behind-text rendering.
fn drawing_is_side_float(drawing : @xml.Element) -> Bool {
  let info = extract_anchor_info(drawing)
  // §20.4.2.3 — a `behindDoc` drawing sits BEHIND the text (z-order);
  // text flows OVER it with no exclusion, so it is not a reflow float
  // even if it declares a wrap mode.  It keeps its inline / behind-text
  // rendering (and its `data-ooxml-*` metadata).
  if info.behind_doc {
    return false
  }
  match info.wrap_mode {
    "Square" | "Tight" | "Through" => true
    _ => false
  }
}

///|
/// Resolve the side a side-float sits on from its `<wp:positionH>`:
/// an `<wp:align>` of `right` (or a `<wp:posOffset>` past the content
/// midpoint) → `"right"`; everything else → `"left"`.  `content_width`
/// is the column width used to classify an offset.
fn float_side(drawing : @xml.Element, content_width : Double) -> String {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "anchor" {
          match first_child_named(c, "positionH") {
            Some(ph) => {
              match first_child_named(ph, "align") {
                Some(al) =>
                  match al.children {
                    [Text(t)] =>
                      if t == "right" {
                        return "right"
                      } else if t == "left" || t == "inside" {
                        return "left"
                      }
                    _ => ()
                  }
                None => ()
              }
              match first_child_named(ph, "posOffset") {
                Some(po) =>
                  match po.children {
                    [Text(t)] =>
                      match (try? @string.parse_double(t)) {
                        Ok(emu) =>
                          return if emu / 914400.0 * 96.0 > content_width / 2.0 {
                            "right"
                          } else {
                            "left"
                          }
                        Err(_) => ()
                      }
                    _ => ()
                  }
                None => ()
              }
            }
            None => ()
          }
        }
      _ => ()
    }
  }
  // §20.4.2.3 — Word's default floating picture anchors at the left of
  // the column; the body then wraps on the right.
  "left"
}

///|
/// `<wp:anchor distL>` horizontal wrap gap (EMU → px), defaulting to a
/// small 14 px gutter when absent.
fn float_gutter_px(drawing : @xml.Element) -> Double {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "anchor" {
          match attr_value(c, "distL") {
            Some(v) =>
              match (try? @string.parse_double(v)) {
                Ok(emu) => return emu / 914400.0 * 96.0
                Err(_) => ()
              }
            None => ()
          }
        }
      _ => ()
    }
  }
  14.0
}

///|
/// Render a side-float `<w:drawing>` to an SVG node positioned at local
/// (0,0) sized `w_px` × `h_px` — an `<image>` for a picture payload, or
/// the shape/group/canvas `<g>` (with the inline baseline shift undone)
/// for a `<wps:wsp>` / `<wpg:wgp>` / `<wpc:wpc>` payload.  `None` when
/// nothing renderable is found.
fn render_float_drawing(
  drawing : @xml.Element,
  w_px : Double,
  h_px : Double,
  image_resolver : (String) -> ResolvedImage?,
  warnings : Array[String],
) -> @xml.Node? {
  match build_inline_image(drawing, image_resolver) {
    Some(img) =>
      Some(
        @markup.elem_ns(
          "image",
          @markup.svg_ns,
          [
            @markup.attr("x", "0"),
            @markup.attr("y", "0"),
            @markup.attr("width", fmt_double(w_px)),
            @markup.attr("height", fmt_double(h_px)),
            @markup.attr("href", img.href),
            @markup.attr("preserveAspectRatio", "xMidYMid meet"),
          ],
          [],
        ),
      )
    None => {
      // Shape / group / canvas payloads surface a `<g>` translated to
      // (0,−h_px) for inline baseline alignment; undo that shift with
      // an outer translate so the float draws inside [0, h_px].
      let payload = match
        build_inline_canvas(drawing, image_resolver, warnings) {
        Some(p) => Some(p)
        None =>
          match build_inline_group(drawing, image_resolver, warnings) {
            Some(p) => Some(p)
            None => build_inline_shape(drawing, warnings)
          }
      }
      match payload {
        Some(mp) =>
          Some(
            @markup.elem_ns(
              "g",
              @markup.svg_ns,
              [
                @markup.attr(
                  "transform",
                  "translate(0," + fmt_double(h_px) + ")",
                ),
              ],
              [@xml.Node::Element(mp.group)],
            ),
          )
        None => None
      }
    }
  }
}

///|
/// Find the first side-wrapping float `<w:drawing>` in paragraph `p`
/// (walking its `<w:r>` runs) and build its `FloatDrawing`, or `None`
/// when the paragraph carries no side-float.  `content_width` resolves
/// the float's side from `<wp:positionH>`.

///|
/// §20.4.2.16 CT_WrapPath — read the `<wp:wrapPolygon>` of a wrapTight
/// / wrapThrough anchor and return its vertices as box-local fractions
/// (0..1 of the drawing extent).  Coordinates are EMU in the extent's
/// space, so each vertex is divided by the extent (cx, cy).  Returns
/// an empty array when the drawing has no wrap polygon.
fn read_wrap_polygon(drawing : @xml.Element) -> Array[(Double, Double)] {
  let out : Array[(Double, Double)] = []
  // Locate the anchor and its extent (EMU) for normalisation.
  let anchor = match first_child_named(drawing, "anchor") {
    Some(a) => a
    None => return out
  }
  let (cx, cy) = match first_child_named(anchor, "extent") {
    Some(e) =>
      (parse_double_attr(e, "cx", 0.0), parse_double_attr(e, "cy", 0.0))
    None => return out
  }
  if cx <= 0.0 || cy <= 0.0 {
    return out
  }
  // wrapPolygon lives under wrapTight or wrapThrough.
  let poly = match first_child_named(anchor, "wrapTight") {
    Some(wt) => first_child_named(wt, "wrapPolygon")
    None =>
      match first_child_named(anchor, "wrapThrough") {
        Some(wt) => first_child_named(wt, "wrapPolygon")
        None => None
      }
  }
  let polygon = match poly {
    Some(p) => p
    None => return out
  }
  fn add_vertex(v : @xml.Element) -> Unit {
    let x = parse_double_attr(v, "x", 0.0) / cx
    let y = parse_double_attr(v, "y", 0.0) / cy
    out.push((x, y))
  }

  for ch in polygon.children {
    match ch {
      Element(e) =>
        if e.name.local_name == "start" || e.name.local_name == "lineTo" {
          add_vertex(e)
        }
      _ => ()
    }
  }
  out
}

///|
/// §20.4.2.16 — the horizontal span `(min_x, max_x)` (box-local
/// fractions) of a wrap polygon at vertical fraction `fy`, found by
/// intersecting every polygon edge with the horizontal line `y = fy`.
/// Returns `None` when no edge crosses that height.
fn polygon_x_span_at(
  poly : Array[(Double, Double)],
  fy : Double,
) -> (Double, Double)? {
  let n = poly.length()
  if n < 2 {
    return None
  }
  let mut min_x = 1.0e9
  let mut max_x = -1.0e9
  let mut found = false
  for i in 0..<n {
    let (x1, y1) = poly[i]
    let (x2, y2) = poly[(i + 1) % n]
    // Edge crosses the scanline when fy lies in [y1, y2) or [y2, y1).
    if (y1 <= fy && y2 > fy) || (y2 <= fy && y1 > fy) {
      let t = (fy - y1) / (y2 - y1)
      let x = x1 + t * (x2 - x1)
      if x < min_x {
        min_x = x
      }
      if x > max_x {
        max_x = x
      }
      found = true
    }
  }
  if found {
    Some((min_x, max_x))
  } else {
    None
  }
}

///|
fn paragraph_side_float(
  p : @xml.Element,
  content_width : Double,
  image_resolver : (String) -> ResolvedImage?,
  warnings : Array[String],
) -> FloatDrawing? {
  fn scan(el : @xml.Element) -> FloatDrawing? {
    for child in el.children {
      match child {
        Element(c) =>
          if c.name.local_name == "drawing" {
            if drawing_is_side_float(c) {
              let (w_px, h_px) = drawing_extent_size_px(c)
              if w_px > 0.0 && h_px > 0.0 {
                match
                  render_float_drawing(c, w_px, h_px, image_resolver, warnings) {
                  Some(node) =>
                    return Some({
                      node,
                      w_px,
                      h_px,
                      side: float_side(c, content_width),
                      gutter_px: float_gutter_px(c),
                      wrap_polygon: read_wrap_polygon(c),
                    })
                  None => ()
                }
              }
            }
          } else {
            // Recurse into runs / hyperlinks / sdt content.
            match scan(c) {
              Some(f) => return Some(f)
              None => ()
            }
          }
        _ => ()
      }
    }
    None
  }

  scan(p)
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
                  try @string.parse_double(v) catch {
                    _ => ()
                  } noraise {
                    emu => return emu / 914400.0 * 96.0
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
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  chart_resolver : (@xml.Element) -> @xml.Node?,
) -> Unit {
  // §20.4.2.3 — a side-wrapping floating anchor is NOT part of the
  // inline run flow; `collect_blocks` lifts it into a `FloatBlock` and
  // narrows the surrounding text.  Emitting nothing here keeps it out
  // of the line box.
  if drawing_is_side_float(drawing) {
    return
  }
  match build_inline_image(drawing, image_resolver) {
    Some(img) =>
      spans.push(
        apply_hyperlink_styling(
          with_inline_image(template, img),
          hyperlink_styling,
        ),
      )
    None =>
      // §21.2 — DrawingML chart payload: `<a:graphicData uri="…/chart">`
      // carrying a `<c:chart r:id>` reference resolved through the
      // document's relationships table. The chart renderer
      // (`drawing_ml/chart/viewer`) returns a self-contained `<g>`
      // for the plot area; wrap it in a `MathPayload` so the line
      // emitter places it on the baseline.
      //
      // §20.5 — no picture payload reached; if the drawing carries a
      // wordprocessing-shape (`<wps:wsp>`) we can still render the
      // preset geometry inline.  Otherwise, if `<a:graphicData>`
      // carries a legacy VML tree (§19), the VML→SVG translator
      // (`build_inline_vml`) surfaces the same inline-shape slot
      // with a translated `<g>`.  Falls through to the whitespace
      // placeholder when neither path produces a payload.
      match build_inline_chart(drawing, chart_resolver) {
        Some(chart) =>
          spans.push(
            apply_hyperlink_styling(
              with_math(template, chart),
              hyperlink_styling,
            ),
          )
        None =>
          // §20.4.2.29 `<wpc:wpc>` canvas → §20.1.2.2.20 `<wpg:wgp>`
          // group → single `<wps:wsp>` shape — each carries its own
          // graphicData URI, tried in turn before the VML fallback.
          match build_inline_canvas(drawing, image_resolver, warnings) {
            Some(canvas) =>
              spans.push(
                apply_hyperlink_styling(
                  with_math(template, canvas),
                  hyperlink_styling,
                ),
              )
            None =>
              match build_inline_group(drawing, image_resolver, warnings) {
                Some(grp) =>
                  spans.push(
                    apply_hyperlink_styling(
                      with_math(template, grp),
                      hyperlink_styling,
                    ),
                  )
                None =>
                  match build_inline_shape(drawing, warnings) {
                    Some(shape) =>
                      spans.push(
                        apply_hyperlink_styling(
                          with_math(template, shape),
                          hyperlink_styling,
                        ),
                      )
                    None =>
                      match build_inline_vml(drawing) {
                        Some(vml_shape) =>
                          spans.push(
                            apply_hyperlink_styling(
                              with_math(template, vml_shape),
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
              }
          }
      }
  }
}

///|
/// §19.1.2.19 VML `style` attribute — return the declared `width`
/// in CSS pixels (96 dpi).  Falls back to 16.0 px when the attribute
/// is missing or declares no width, so the surrounding emitter still
/// reserves a non-zero baseline footprint for the legacy graphic.
/// Delegates parsing to the shared `@vml.parse_style` so the same
/// unit-handling code drives both the WML `<w:pict>` host and the
/// generic VML→SVG translator.
fn vml_style_width_px(ve : @xml.Element) -> Double {
  match attr_value(ve, "style") {
    Some(s) =>
      match @vml.parse_style(s).width {
        Some(v) if v > 0.0 => v
        _ => 16.0
      }
    None => 16.0
  }
}

///|
/// §19.1.2.19 VML `style` attribute — return the declared `height`
/// in CSS pixels (96 dpi).  Falls back to 16.0 px when the attribute
/// is missing.  Mirrors `vml_style_width_px` so the WML host can
/// reserve a bounding box for the inline VML group.
fn vml_style_height_px(ve : @xml.Element) -> Double {
  match attr_value(ve, "style") {
    Some(s) =>
      match @vml.parse_style(s).height {
        Some(v) if v > 0.0 => v
        _ => 16.0
      }
    None => 16.0
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
  buf.write_char(Int::unsafe_to_char(cp))
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
  { ..template, text, width_px: width, inline_image: None, math: None }
}

///|
/// Build a RunSpan containing an inline `<w:drawing>` payload. The
/// span reserves `(width, height)` in CSS pixels and stores the
/// resolved data URI (or empty when no `image_resolver` was supplied)
/// so the paragraph emitter can lay the picture out at the line
/// baseline.
fn with_inline_image(template : RunSpan, image : InlineImage) -> RunSpan {
  {
    ..template,
    text: "",
    width_px: image.width_px,
    inline_image: Some(image),
    math: None,
  }
}

///|
/// Build a RunSpan carrying an Office Math payload from a template.
/// The span reserves the math fragment's width; the emitter draws
/// the pre-laid-out `<g>` at the line baseline.
fn with_math(template : RunSpan, math : MathPayload) -> RunSpan {
  {
    ..template,
    text: "",
    width_px: math.width_px,
    inline_image: None,
    math: Some(math),
  }
}

///|
/// §22.1.2.77 `<m:oMath>` — lay the Office Math tree out into a
/// self-contained SVG `<g>` (via the `office_math` SVG renderer) and
/// push it as one math span.  The fragment is rendered at the run
/// template's font size so the equation matches the surrounding body
/// text; its colour follows the run colour (defaulting to black).
fn emit_omath_span(
  o_math : @xml.Element,
  template : RunSpan,
  spans : Array[RunSpan],
  math_font? : String? = None,
) -> Unit {
  let color = if template.color.length() > 0 {
    template.color
  } else {
    "#000000"
  }
  let rendered = match math_font {
    Some(font) =>
      @omml_viewer.render_svg(
        @omml.CT_OMath::new(o_math),
        font_size_pt=template.font_size_pt,
        color~,
        math_font=Some(font),
      )
    None =>
      @omml_viewer.render_svg(
        @omml.CT_OMath::new(o_math),
        font_size_pt=template.font_size_pt,
        color~,
      )
  }
  let payload = {
    group: rendered.group,
    width_px: rendered.width,
    ascent_px: rendered.ascent,
    descent_px: rendered.descent,
  }
  spans.push(with_math(template, payload))
}

///|
/// Measure text width using the configured @util/glyph resolver.
///
/// §17.3.2.13 `<w:caps>` renders every glyph as its uppercase
/// form; uppercase letters are typically wider than lowercase,
/// so the measurement MUST be done on the cased text — measuring
/// the raw lowercase text would under-estimate the line width
/// and over-pack lines.  §17.3.2.5 `<w:smallCaps>` renders
/// lowercase letters as small uppercase glyphs (≈80% cap height,
/// near the lowercase advance), so we measure the as-authored
/// text for smallCaps.
fn measure_run_text(
  text : String,
  template : RunSpan,
  warnings : Array[String],
) -> Double {
  let measured_text = if template.caps { text.to_upper() } else { text }
  let glyph_w = try
    @glyph.resolve_chain(template.font_request).measure_text(
      measured_text,
      font_size_pt=template.font_size_pt,
      letter_spacing_px=template.letter_spacing_px,
    )
  catch {
    @glyph.FontUnresolvedError(driver_labels=labels, ..) => {
      warn_font_unresolved(warnings, template.font_request, labels, "width")
      0.0
    }
  } noraise {
    w => w
  }
  // §17.3.1.10/.11 autoSpaceDE / autoSpaceDN (JIS X 4051 和欧間隔) —
  // add the 四分アキ accrued at this run's internal East-Asian↔Western
  // boundaries so the measured advance matches the glyphs the emitter
  // paints (`build_text_children` splits the run into tspans separated
  // by the same gap), honouring the paragraph's two toggles.  Px (not
  // pt) because the rest of the layout is in px: `inter_script_advance_px`
  // is fed the px-equivalent font size.
  glyph_w +
  @glyph.inter_script_advance_px(
    measured_text,
    font_size_pt=template.font_size_pt * @glyph.pt_to_px,
    auto_space_de=template.auto_space_de,
    auto_space_dn=template.auto_space_dn,
  )
}

///|
fn para_props_has_character_indents(props : ParaProps) -> Bool {
  props.margin_left_chars is Some(_) ||
  props.margin_right_chars is Some(_) ||
  props.first_line_chars is Some(_) ||
  props.hanging_chars is Some(_)
}

///|
/// Resolve one §17.3.1.12 "character unit" to CSS pixels using the
/// paragraph's active glyph metrics.  ECMA-376 defines the attributes
/// as hundredths of a character unit; this viewer has no separate font
/// metric table, so the unit is measured through the same
/// `RunSpan.font_request` / `@glyph` path as normal text width.
fn paragraph_character_unit_px(
  spans : Array[RunSpan],
  warnings : Array[String],
  default_font_size_pt : Double,
  font_descriptors : Map[String, FontDescriptor],
) -> Double {
  for span in spans {
    if span.text.length() > 0 {
      let w = measure_run_text("0", span, warnings)
      if w > 0.0 {
        return w
      }
    }
  }
  let template = default_run_template(default_font_size_pt~, font_descriptors~)
  measure_run_text("0", template, warnings)
}

///|
/// Apply §17.3.1.12 char-unit indentation after run collection.  The
/// raw values were preserved by `resolve_para_props`; converting here
/// lets us use the resolved paragraph/run font request as the sole
/// source of glyph width.
fn apply_character_indents_to_props(
  props : ParaProps,
  spans : Array[RunSpan],
  warnings : Array[String],
  default_font_size_pt : Double,
  font_descriptors : Map[String, FontDescriptor],
) -> ParaProps {
  if !para_props_has_character_indents(props) {
    return props
  }
  let unit_px = paragraph_character_unit_px(
    spans, warnings, default_font_size_pt, font_descriptors,
  )
  if unit_px <= 0.0 {
    return props
  }
  let margin_left = match props.margin_left_chars {
    Some(n) => n / 100.0 * unit_px
    None => props.margin_left
  }
  let margin_right = match props.margin_right_chars {
    Some(n) => n / 100.0 * unit_px
    None => props.margin_right
  }
  let first_line = match props.first_line_chars {
    Some(n) => n / 100.0 * unit_px
    None => 0.0
  }
  let hanging = match props.hanging_chars {
    Some(n) => n / 100.0 * unit_px
    None => 0.0
  }
  {
    ..props,
    margin_left,
    margin_right,
    indent: props.indent + first_line - hanging,
  }
}

///|
/// Layout one paragraph into a stack of lines.  Uses content_width as
/// available inline size, applies §17.3.1.12 indent / margin offsets,
/// and word-wraps using @util/glyph measurements.
///
/// `apply_office_defaults` is the §17.7.5.3 docDefaults fallback flag
/// — see `resolve_para_props`. The body-level pipeline forwards
/// `styles_part_absent` so the renderer matches Word when
/// the document ships without a `/word/styles.xml` part.
/// @source web-pptx engine.ts:130 (layoutParagraph)
fn layout_paragraph(
  p : @xml.Element,
  content_width : Double,
  warnings : Array[String],
  image_resolver : (String) -> ResolvedImage?,
  chart_resolver : (@xml.Element) -> @xml.Node?,
  apply_office_defaults? : Bool = false,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  // §20.4.2.16 wrapPolygon — optional per-line available width (line
  // index → width px).  When supplied it overrides the rectangular
  // first/next-line widths so text wraps to a float's irregular
  // polygon edge instead of its bounding box.  `line_x_fn` gives the
  // matching per-line left offset (for a left-side polygon float).
  line_budget_fn? : (Int) -> Double,
  line_x_fn? : (Int) -> Double,
  // §17.16.22 — per-stream bound hyperlink-target resolver, threaded to
  // `collect_paragraph_spans` so a `<w:hyperlink r:id>` resolves to a URL.
  hyperlink_resolver? : (String) -> String? = _ => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> LaidParagraph {
  // §17.7.5.3 — `apply_office_defaults` flows into
  // `resolve_para_props` so the line-height multiplier picks up the
  // Office Normal 276/240 auto factor when the document carries no
  // styles part. We also bump the run-default font size to Word's
  // built-in Normal 11 pt. The actual line box comes from
  // `LineFontMetrics`, so font vertical data stays in `@glyph`.
  let default_font_size_pt = if apply_office_defaults {
    OFFICE_NORMAL_FONT_SIZE_PT
  } else {
    DEFAULT_FONT_SIZE_PT
  }
  let raw_props = resolve_para_props(p, apply_office_defaults~, theme_map~)
  let spans = collect_paragraph_spans(
    p,
    warnings,
    image_resolver,
    chart_resolver,
    default_font_size_pt~,
    theme_map~,
    font_map~,
    font_descriptors~,
    math_font~,
    hyperlink_resolver~,
    field_context~,
    field_registry~,
  )
  let props = apply_character_indents_to_props(
    raw_props, spans, warnings, default_font_size_pt, font_descriptors,
  )

  // §17.3.1.11 framePr — when the paragraph is wrapped in a floating
  // text frame, line-wrap against the frame's `w:w` (the frame's
  // inner width) instead of the column content width.  A frame with
  // no explicit width falls back to the column width minus the
  // requested x offset (so a right-anchored frame still fits inside
  // the content area).
  let effective_width = match props.frame_pr {
    Some(fp) =>
      if fp.w_px > 0.0 {
        fp.w_px
      } else if fp.x_px > 0.0 {
        (content_width - fp.x_px).max(0.0)
      } else {
        content_width
      }
    None => content_width
  }

  // Inline width budgets for first vs. subsequent lines.
  let first_line_w = (effective_width -
  props.margin_left -
  props.margin_right -
  props.indent).max(0.0)
  let next_line_w = (effective_width - props.margin_left - props.margin_right).max(
    0.0,
  )

  // Break spans into lines.
  let span_lines = break_into_lines(
    spans,
    first_line_w,
    next_line_w,
    warnings,
    line_budget_fn?,
  )
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
  //
  // §17.3.1.7 — when the paragraph carries `<w:pBdr>`, the border
  // stroke and its `@space` inset live INSIDE the paragraph block.
  // Word render the border at the page-content edge
  // and push the text downward by `border_width + space`, rather
  // than placing the text at the margin and floating the border
  // outward. Reserve `top_inset` BEFORE the first line and add
  // `bottom_inset` AFTER the last so the laid-line bbox encloses
  // exactly the text frame; the border emitter in
  // `build_paragraph_nodes` then draws the geometric centerline at
  // (frame_top - space - width/2) so the OUTER edge of the stroke
  // lands at the paragraph block's top edge. Without this offset
  // the box's outer edge floats above the page content and the
  // text aligns to the margin instead of inside the border, which
  // empirically left every bordered paragraph ~6-7 px above the reference renderer's
  // render (paragraph-border-double-thick fixture: text top y=99
  // vs the reference renderer y=114; with this offset they converge at y≈114).
  let top_inset = border_total_extent_px(props.border_top) +
    props.border_top.space_px
  let bottom_inset = border_total_extent_px(props.border_bottom) +
    props.border_bottom.space_px
  let lines : Array[LaidLine] = []
  let mut current_y = props.space_before + top_inset
  for idx in 0..<final_lines.length() {
    let raw_spans = final_lines[idx]
    let line_indent = if idx == 0 { props.indent } else { 0.0 }
    // §17.3.1.38 — resolve tab sentinel spans against the paragraph's
    // tab stops (or a default 0.5-inch grid) now that the line is
    // settled. Tabs are paragraph-relative — they measure from the
    // start of the line's content origin.
    let line_spans = resolve_tab_spans(raw_spans, line_indent, props.tab_stops)
    let metrics = line_font_metrics(line_spans, warnings, default_font_size_pt~)
    let line_height = match props.line_height {
      LineHeightDefault => metrics.single_line_height_px
      LineHeightAuto(factor) => metrics.single_line_height_px * factor
      LineHeightExact(px) => px
    }
    // §17.3.1.33 — baseline placement within the line box.
    //
    // Office-compatible renderers use TWO DIFFERENT rules depending
    // on `lineRule`:
    //
    // 1. For `auto` line height, baseline sits at `box_top + ascent`.
    //    The ascent value is read from the selected line font.
    //
    // 2. For `exact` and `atLeast` line heights LARGER than the natural
    //    auto step, the reference renderer places the extra leading ABOVE the cap, NOT
    //    below it — the line box "grows upward" so the natural
    //    descent below baseline stays constant.  Verified at 11 pt body
    //    against `paragraph-line-exact` (line=480 twips → 32 px,
    //    Δ = 32 − 17.93 = 14.07 px extra; ref cap-top = row 111 =
    //    box_top (96) + 14 + 1) and `paragraph-line-atleast`
    //    (line=600 twips → 40 px, Δ = 22.07 px extra; ref cap-top
    //    = row 118 = box_top + 22 + 1).  Both match a baseline of
    //    `box_top + ascent + max(0, line_height - natural_line_height)`
    //    to within ±1 px (subpixel rounding).
    //
    // The earlier `line_height − descent` placement put the baseline
    // near the BOX BOTTOM, which when `line_height > ascent + descent`
    // pushed every cap a leading-space below the reference renderer's cap — visible as a
    // constant per-paragraph offset on top of the cumulative step
    // drift caused by measuring against the wrong single-line height.
    //
    // The legacy `line_height − descent` formula remains as the
    // sanity floor for pathologically small `line_height`
    // (`LineHeightExact(px)` with `px < ascent`).
    let descent = metrics.descent_px
    let ascent = metrics.ascent_px
    // Natural single-line height for this run's font — the threshold
    // at which the "extra leading goes above the cap" rule kicks in
    // for `exact`/`atLeast` line specs.
    let natural_line_height = metrics.single_line_height_px
    let baseline_in_box = match props.line_height {
      LineHeightExact(_) =>
        // `exact` / `atLeast` — place baseline so the descent below it
        // stays at the natural value; any extra height past the natural
        // auto line goes ABOVE the cap.
        if line_height >= natural_line_height {
          ascent + (line_height - natural_line_height)
        } else if line_height - descent > 0.0 {
          line_height - descent
        } else {
          line_height
        }
      // LineHeightDefault / LineHeightAuto — baseline = box_top + ascent.
      _ =>
        if line_height >= ascent {
          ascent
        } else if line_height - descent > 0.0 {
          line_height - descent
        } else {
          line_height
        }
    }
    let baseline = current_y + baseline_in_box
    // §22.1.2.77 — an Office Math fragment is laid out around its
    // own baseline; a tall equation (fraction, n-ary, matrix) can
    // need more head- and foot-room than the text line box. Grow
    // the line so every math span fits: push the baseline down by
    // any ascent overflow above `y_top`, and extend the height by
    // any descent overflow below the natural line bottom.
    let mut extra_above = 0.0
    let mut extra_below = 0.0
    for s in line_spans {
      match s.math {
        Some(math) => {
          let above = math.ascent_px - (baseline - current_y)
          if above > extra_above {
            extra_above = above
          }
          let below = math.descent_px - (current_y + line_height - baseline)
          if below > extra_below {
            extra_below = below
          }
        }
        None => ()
      }
    }
    let baseline = baseline + extra_above
    let line_height = line_height + extra_above + extra_below
    let line_width = sum_span_widths(line_spans)
    // §20.4.2.16 — per-line available width / left offset when wrapping
    // to a float polygon; else the rectangular first/next width.
    let available = match line_budget_fn {
      Some(f) => f(idx)
      None => if idx == 0 { first_line_w } else { next_line_w }
    }
    let line_x_off = match line_x_fn {
      Some(f) => f(idx)
      None => 0.0
    }
    let base_x = props.margin_left + line_indent + line_x_off
    // §17.18.59 ST_Jc `both` — distribute the slack between
    // `line_width` and `available` across the U+0020 spaces in the
    // line. The trailing line of a justified paragraph keeps its
    // natural width (the spec exempts the last line); same for the
    // single line of a one-line paragraph. We also bail out when the
    // line has no spaces to stretch (a single long word) or when the
    // glyphs already exceed the budget (negative slack would shrink
    // the line, which is not what `both` means).
    let is_last_line = idx == final_lines.length() - 1
    let (justify_extra, justified_width) = if props.alignment == "justify" &&
      !is_last_line &&
      available > line_width {
      let n_spaces = count_line_spaces(line_spans)
      if n_spaces > 0 {
        let extra = (available - line_width) / n_spaces.to_double()
        (extra, available)
      } else {
        (0.0, line_width)
      }
    } else {
      (0.0, line_width)
    }
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
      width: justified_width,
      word_spacing_extra: justify_extra,
    })
    current_y = current_y + line_height
  }
  // §17.3.1.7 — reserve the bottom border inset (stroke width +
  // `@space`) after the last line so the paragraph block carries the
  // full bordered height, mirroring the `top_inset` reserved above
  // the first line.  Without this `current_y` ends flush against the
  // last line's descent and the bottom border draws on top of the
  // next paragraph's first line.
  let height = current_y + bottom_inset + props.space_after
  // §17.3.1.7 — the border / shading rectangle spans the full
  // text frame: from `margin_left` to the column's right edge,
  // independent of the first-line indent (Word draws the box
  // around the column, not around the glyph run). Capturing the
  // frame in paragraph-relative coordinates here lets
  // `offset_paragraph` translate it onto absolute page coordinates
  // exactly like the line origins.
  let frame_x = props.margin_left
  let frame_width = (effective_width - props.margin_left - props.margin_right).max(
    0.0,
  )
  LaidParagraph::{
    lines,
    height,
    background: props.background,
    shd_val: props.shd_val,
    shd_color: props.shd_color,
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
    frame_x,
    frame_width,
    frame_pr: props.frame_pr,
  }
}

///|
/// §17.3.3.1 ST_BrType — classify the first `<w:br>` child found
/// inside the paragraph's runs. Spec enumerates 3 values:
///   page          — page break (drives `flow_into_pages`)
///   column        — column break (advances to the next column in
///                   `flow_into_pages` via `column_break_after`; the
///                   per-column geometry comes from `column_geometry`)
///   textWrapping  — line break (handled by `make_break_span`
///                   inside the run renderer; no paragraph-level
///                   effect)
/// Returned variant lets callers act on the spec-defined kind
/// instead of silently coalescing them.
priv enum BreakKind {
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
/// §17.4.41 — `<w:tblBorders>` resolution. Sides that are absent
/// fall back to `BorderSide::default_legacy()` per spec: §17.4.40
/// mandates a default border when no tblBorders/tcBorders are
/// declared. Parametric on a pre-merged `<w:tblPr>` element so
/// callers that resolved the tblStyle cascade can feed the merged
/// tblPr instead of the raw direct one. `_tbl` is unused; kept so
/// the signature stays close to the original for future shared
/// logic.
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
          try @string.parse_double(v) catch {
            _ => 1.0
          } noraise {
            eighths => {
              let pt = eighths / 8.0
              pt * 96.0 / 72.0
            }
          }
      }
      // §17.3.1.7 `@space` — integer points (§17.18.5
      // ST_PointMeasure) between the border stroke and the
      // content rectangle.  Honoured by the paragraph-border
      // emitter; tables hug the cell rect so `space_px` is read
      // but never offsets cell rectangles.
      let space_px = match attr_value(side, "space") {
        None => fallback.space_px
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => fallback.space_px
          } noraise {
            pt => pt * 96.0 / 72.0
          }
      }
      { width_px, color_hex, style, space_px }
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
  tab_stops : Array[(Double, String, String)],
) -> Array[RunSpan] {
  let out : Array[RunSpan] = []
  let mut cursor = line_origin
  // Walk by index so we can peek the run that follows each tab to
  // compute the alignment-aware advance per §17.18.87.
  let mut i = 0
  while i < spans.length() {
    let span = spans[i]
    if span.text == "\t" {
      let (target, kind, leader) = next_tab_stop_after(cursor, tab_stops)
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
        // §17.3.1.38 — a `bar` tab paints a rule, not a leader; every
        // other justification carries the stop's leader through to the
        // emitter (which draws nothing when it is "none"/"").
        tab_leader: if kind == "bar" {
          "none"
        } else {
          leader
        },
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
  tab_stops : Array[(Double, String, String)],
) -> (Double, String, String) {
  for stop in tab_stops {
    let (pos, kind, leader) = stop
    if pos > cursor {
      return (pos, kind, leader)
    }
  }
  // Default-grid stops (no explicit `<w:tab>`) carry no leader.
  let interval = default_tab_interval_px
  if interval <= 0.0 {
    return (cursor, "left", "none")
  }
  let n = (cursor / interval).floor() + 1.0
  (n * interval, "left", "none")
}

///|
/// Default §17.3.1.38 tab interval — 0.5 inch in CSS pixels at 96 dpi.
/// Word's default `<w:defaultTabStop>` is 720 twips (½ inch); the
/// renderer uses that value when no explicit `<w:tabs>` are declared
/// and the cursor passes the last paragraph-defined stop.
let default_tab_interval_px : Double = 48.0

///|
/// Resolve one font face's vertical metrics from the shared glyph
/// resolver. This is the WML viewer's only ascent / descent /
/// line-gap reader; callers should select the face, then call here.
fn read_line_font_metrics_for(
  request : @glyph.FontResolutionRequest,
  font_size_pt : Double,
) -> LineFontMetrics raise @glyph.FontUnresolvedError {
  let measurer = @glyph.resolve_chain(request)
  let ascender = measurer.ascender_ratio()
  let descender = measurer.descender_ratio()
  let line_gap = measurer.line_gap_ratio()
  let font_size_px = font_size_pt * @glyph.pt_to_px
  let ascent_px = font_size_px * ascender
  let descent_px = font_size_px * descender
  let line_gap_px = font_size_px * line_gap
  {
    ascent_px,
    descent_px,
    single_line_height_px: ascent_px + descent_px + line_gap_px,
  }
}

///|
/// Resolve one font face's vertical metrics from `@glyph`. The request
/// already carries the ECMA-376 fontTable / rFonts chain; the WML
/// viewer does not add a second fallback family.
fn line_font_metrics_for(
  request : @glyph.FontResolutionRequest,
  font_size_pt : Double,
  warnings : Array[String],
) -> LineFontMetrics {
  try read_line_font_metrics_for(request, font_size_pt) catch {
    @glyph.FontUnresolvedError(driver_labels=labels, ..) => {
      warn_font_unresolved(warnings, request, labels, "line metrics")
      let font_size_px = font_size_pt * @glyph.pt_to_px
      {
        ascent_px: font_size_px,
        descent_px: 0.0,
        single_line_height_px: font_size_px,
      }
    }
  } noraise {
    metrics => metrics
  }
}

///|
/// Line metrics already computed by the OMML renderer for inline math
/// payloads. A math-only line must not consult the surrounding WML
/// default text face just to place its baseline; the OMML box is the
/// only glyph metric source for that line.
fn metrics_from_math_payload(math : MathPayload) -> LineFontMetrics {
  {
    ascent_px: math.ascent_px,
    descent_px: math.descent_px,
    single_line_height_px: math.ascent_px + math.descent_px,
  }
}

///|
fn merge_line_metrics(
  a : LineFontMetrics,
  b : LineFontMetrics,
) -> LineFontMetrics {
  let ascent_px = a.ascent_px.max(b.ascent_px)
  let descent_px = a.descent_px.max(b.descent_px)
  { ascent_px, descent_px, single_line_height_px: ascent_px + descent_px }
}

///|
fn line_math_metrics(spans : Array[RunSpan]) -> LineFontMetrics? {
  let acc : Ref[LineFontMetrics?] = { val: None }
  for s in spans {
    match s.math {
      Some(math) => {
        let m = metrics_from_math_payload(math)
        acc.val = match acc.val {
          None => Some(m)
          Some(prev) => Some(merge_line_metrics(prev, m))
        }
      }
      None => ()
    }
  }
  acc.val
}

///|
fn line_has_text(spans : Array[RunSpan]) -> Bool {
  for s in spans {
    if s.text.length() > 0 {
      return true
    }
  }
  false
}

///|
/// Select the largest resolved run on a line and read its vertical
/// metrics. Empty lines use the paragraph's default body face.
fn line_font_metrics(
  spans : Array[RunSpan],
  warnings : Array[String],
  default_font_size_pt? : Double = DEFAULT_FONT_SIZE_PT,
) -> LineFontMetrics {
  let math_metrics = line_math_metrics(spans)
  if !line_has_text(spans) {
    match math_metrics {
      Some(m) => return m
      None => ()
    }
  }
  let mut request = build_run_font_request(
    DEFAULT_FONT_FAMILY,
    400,
    false,
    empty_font_descriptors(),
  )
  let mut font_size_pt = default_font_size_pt
  let mut seen = false
  for s in spans {
    if !seen || s.font_size_pt > font_size_pt {
      seen = true
      request = s.font_request
      font_size_pt = s.font_size_pt
    }
  }
  let text_metrics = line_font_metrics_for(request, font_size_pt, warnings)
  match math_metrics {
    Some(m) => merge_line_metrics(text_metrics, m)
    None => text_metrics
  }
}

///|
/// Natural content-height floor for table cells. It sums the glyph
/// single-line height for each laid line, sharing the same metric SoT
/// as paragraph layout instead of carrying a table-only em-ratio.
fn laid_paragraphs_line_metric_floor(
  paragraphs : Array[LaidParagraph],
  warnings : Array[String],
  default_font_size_pt : Double,
) -> Double {
  let mut total = 0.0
  for lp in paragraphs {
    if lp.lines.length() == 0 {
      total = total +
        line_font_metrics([], warnings, default_font_size_pt~).single_line_height_px
    } else {
      for ln in lp.lines {
        total = total +
          line_font_metrics(ln.spans, warnings, default_font_size_pt~).single_line_height_px
      }
    }
  }
  total
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

///|
/// §17.18.59 ST_Jc `both` — count the U+0020 word-break opportunities
/// in a laid-out line. Used by `layout_paragraph` to spread the slack
/// between the natural glyph width and the available content width
/// across the spaces.
///
/// Only literal U+0020 (' ') is counted. U+0009 tabs and U+00AD soft
/// hyphens carry their own width semantics (tab stops, hyphen glyph)
/// and the spec does not list them as justification stretch points;
/// stretching them would shift the visible tab anchor / soft-hyphen
/// glyph and lose round-trip fidelity. Inline-image and Office Math
/// spans contribute no spaces because their `text` field is the empty
/// string sentinel attached to the payload.
///
/// Bar-tab spans (§17.18.87 `bar`) are skipped: their text is "\t"
/// but they render as a vertical rule, not a word break.
fn count_line_spaces(spans : Array[RunSpan]) -> Int {
  let mut n = 0
  for s in spans {
    if s.bar_tab {
      continue
    }
    if s.inline_image is Some(_) || s.math is Some(_) {
      continue
    }
    for c in s.text {
      if c == ' ' {
        n = n + 1
      }
    }
  }
  n
}

///|
/// §17.18.59 ST_Jc `both` — count U+0020 spaces inside a single span's
/// text. Used by `append_line_nodes` to advance the cursor by the
/// extra per-space stretch contributed by this span (so subsequent
/// spans land on the justified x positions).
fn count_span_spaces(span : RunSpan) -> Int {
  if span.bar_tab {
    return 0
  }
  if span.inline_image is Some(_) || span.math is Some(_) {
    return 0
  }
  let mut n = 0
  for c in span.text {
    if c == ' ' {
      n = n + 1
    }
  }
  n
}

// =============================================================================
// Line breaking
// =============================================================================

// Line-break segmentation (CJK per-glyph splitting + JIS X 4051
// kinsoku gluing) and the soft-wrap-whitespace test live in the shared
// `@glyph` source of truth (`linebreak_segments` /
// `is_wrap_whitespace_segment`), consumed below and by the SML viewer
// alike — see src/util/glyph/line_segment.mbt.

///|
/// Break `spans` into lines that fit within (first_line_w, next_line_w).
/// Splits at spaces and CJK boundaries; honors explicit "\n" sentinels
/// emitted from <w:br> as forced line breaks.
fn break_into_lines(
  spans : Array[RunSpan],
  first_line_w : Double,
  next_line_w : Double,
  warnings : Array[String],
  line_budget_fn? : (Int) -> Double,
) -> Array[Array[RunSpan]] {
  let lines : Array[Array[RunSpan]] = []
  let current : Array[RunSpan] = []
  let used : Ref[Double] = { val: 0.0 }
  // §20.4.2.16 wrapPolygon — when `line_budget_fn` is supplied the
  // available width VARIES per line (the text wraps into / around the
  // float's irregular polygon edge), so each line's budget is the
  // polygon-derived width at that line's vertical band rather than the
  // single first/next rectangular width.
  let line_idx : Ref[Int] = { val: 0 }
  fn budget_for(idx : Int) -> Double {
    match line_budget_fn {
      Some(f) => f(idx)
      None => if idx == 0 { first_line_w } else { next_line_w }
    }
  }

  let budget : Ref[Double] = { val: budget_for(0) }
  // Helper: flush current line to lines and reset state.
  fn flush() {
    let snapshot : Array[RunSpan] = []
    for s in current {
      snapshot.push(s)
    }
    lines.push(snapshot)
    current.clear()
    used.val = 0.0
    line_idx.val = line_idx.val + 1
    budget.val = budget_for(line_idx.val)
  }

  for span in spans {
    // Forced break (\n sentinel)?
    if span.text == "\n" {
      flush()
      continue
    }
    // If span fits, append directly.
    if used.val + span.width_px <= budget.val {
      // §17.3 / CSS Text — drop a whitespace-only span that lands at
      // the START of a fresh line. This happens when a previous span
      // exactly filled the line budget and the next span is a
      // standalone " " run (e.g. two separate `<w:r><w:t>` runs
      // joined by a literal whitespace run); without this swallow
      // the next line begins with a left-indent that the reference renderer
      // does not draw.
      //
      // Tab instruction sentinels (`text == "\t"` from `<w:tab/>`)
      // are exempt: they are §17.3.1.38 positioning operators, not
      // ordinary whitespace. `resolve_tab_spans` resolves them to
      // a tab-stop advance (or a bar-tab decoration) after line
      // breaking completes, so swallowing them here would lose the
      // tab.
      if used.val == 0.0 &&
        span.text != "\t" &&
        @glyph.is_wrap_whitespace_segment(span.text) {
        continue
      }
      current.push(span)
      used.val = used.val + span.width_px
      continue
    }
    // Span overflows: try to break by word. The first piece must
    // fit the *remaining* room on the current line; every piece
    // produced after a forced break is budgeted against the FULL
    // `next_line_w` (§17.6.4 column width / subsequent paragraph
    // line width) so a long span keeps wrapping inside the column.
    let pieces = break_span_by_words(
      span,
      budget.val - used.val,
      next_line_w,
      warnings,
    )
    for piece in pieces {
      if piece.text == "\n" {
        flush()
        continue
      }
      // Mirror the line-start whitespace swallow above for pieces
      // emitted by `break_span_by_words` (covers single-span
      // paragraphs whose wrap point fell exactly on a whitespace
      // segment in the inner break loop).
      if used.val == 0.0 && @glyph.is_wrap_whitespace_segment(piece.text) {
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
///
/// Emergency character-level wrap (CSS `overflow-wrap: anywhere`): a
/// single segment with no internal break opportunity (e.g. a 500-char
/// unbroken ASCII token, or a long glued-kinsoku run) that is itself
/// wider than the column is split PER GRAPHEME so it fills successive
/// lines instead of overrunning the column — matching Word / the
/// reference renderer.  The per-character break still honours JIS X
/// 4051: a break is never placed before a 行頭禁則 character (it is
/// pulled onto the current line — 追い込み — and allowed to hang).
fn break_span_by_words(
  span : RunSpan,
  first_avail : Double,
  next_avail : Double,
  warnings : Array[String],
) -> Array[RunSpan] {
  // An Office Math fragment or an inline image is an indivisible
  // box — it carries no breakable text. Returning it whole keeps
  // the caller's force-fit path (`used.val == 0.0`) from dropping
  // it when it is wider than the remaining line budget.
  if span.math is Some(_) || span.inline_image is Some(_) {
    return [span]
  }
  let segments = @glyph.linebreak_segments(span.text)
  let pieces : Array[RunSpan] = []
  let cur_chars : Array[Char] = []
  let cur_w : Ref[Double] = { val: 0.0 }
  let avail : Ref[Double] = { val: first_avail }
  // Flush current chars as a piece, append a sentinel for a forced
  // break. Subsequent segments are budgeted against `next_avail` —
  // the per-column line width supplied by the caller. (An earlier
  // pass set `avail.val = 1.0e18` "for the caller to rebudget", but
  // that left the rest of an oversized span as a single unbroken
  // piece, so multi-column / narrow-margin paragraphs wrapped only
  // their FIRST line and then dumped the remainder at full content
  // width. §17.6.4 multi-column flow needs every line of a
  // paragraph to honour the column-relative budget.)
  fn flush_with_break() {
    if cur_chars.length() > 0 {
      let text = chars_to_string(cur_chars)
      let w = measure_run_text(text, span, warnings)
      pieces.push(with_text(span, text, w))
      cur_chars.clear()
    }
    pieces.push(with_text(span, "\n", 0.0))
    cur_w.val = 0.0
    avail.val = next_avail
  }

  // Emergency per-grapheme wrap for a segment that, on its own, is
  // wider than the line.  Adds one character at a time and breaks when
  // the column is exceeded — except that JIS X 4051 forbids breaking
  // before a 行頭禁則 character (or after a 行末禁則 one), in which case
  // the character is kept on the current line (追い込み) and hangs past
  // the edge rather than orphaning to the next line's head.
  fn emergency_char_split(seg : String) {
    for c in seg {
      let cw = measure_run_text(c.to_string(), span, warnings)
      if cur_chars.length() > 0 &&
        cur_w.val + cw > avail.val &&
        @glyph.kinsoku_break_allowed(cur_chars[cur_chars.length() - 1], c) {
        flush_with_break()
      }
      cur_chars.push(c)
      cur_w.val = cur_w.val + cw
    }
  }

  for seg in segments {
    let seg_w = measure_run_text(seg, span, warnings)
    if cur_w.val + seg_w <= avail.val {
      for c in seg {
        cur_chars.push(c)
      }
      cur_w.val = cur_w.val + seg_w
    } else if @glyph.is_wrap_whitespace_segment(seg) {
      // §17.3 / CSS Text — a U+0020 / U+0009 whitespace segment that
      // would overflow the line IS the soft-wrap boundary itself.
      // Both Word and the reference renderer consume the space at the break: the
      // current line ends with the preceding word, the NEXT line
      // begins flush against its content edge with no leading
      // whitespace. Previously we pushed the overflowing space onto
      // the new line, which left a visible left-indent on every
      // wrapped line whose break landed mid-word (e.g.
      // "fugiat nulla / [SP]pariatur." in the section-cols-* refs).
      // Emit the line break and DROP the whitespace; cur_w stays 0
      // so the next non-whitespace segment starts at x=0.
      flush_with_break()
    } else {
      // The segment does not fit the remaining room.  Move to a fresh
      // line first (only if the current one carries content, so an
      // empty line never emits a spurious break), then place the
      // segment — splitting it per grapheme when it is itself wider
      // than a full line (CSS overflow-wrap: anywhere).
      if cur_w.val > 0.0 {
        flush_with_break()
      }
      if seg_w <= avail.val {
        for c in seg {
          cur_chars.push(c)
        }
        cur_w.val = seg_w
      } else {
        emergency_char_split(seg)
      }
    }
  }
  if cur_chars.length() > 0 {
    let text = chars_to_string(cur_chars)
    let w = measure_run_text(text, span, warnings)
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
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  image_resolver? : (String) -> ResolvedImage? = _ => None,
  chart_resolver? : (@xml.Element) -> @xml.Node? = _ => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
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
  // §17.4.51 `<w:tblPr>/<w:tblInd>` — table-level left indent. When
  // present, shifts the table block left/right from the column's
  // content origin by @w (interpreted via @type). When absent,
  // the reference renderer applies an implicit -108 twip offset that visually
  // compensates the default 108 twip left cell margin so the cell's
  // content edge sits flush with the page-margin / column origin.
  // Without that compensation our table renders ≈7.2 px to the
  // right of the reference renderer's reference, producing the horizontal text drift
  // (and per-row border misalignment) that drove the table-5x5
  // RMSE residual after the cell-height floor fix.
  let tbl_ind_px = resolve_table_indent(effective_tbl_pr)
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
  let v_merge_anchor : @hashmap.HashMap[Int, (Int, Int)] = HashMap(
    [],
    capacity=0,
  )
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
      // §17.4.33 / §17.18.78 ST_Shd — pattern selector (@val) and the
      // resolved foreground / pattern colour (@color cascade). Empty
      // by default so cells without `<w:shd>` keep their legacy emit.
      let mut shd_val = ""
      let mut shd_color = ""
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
      // §17.4.71/72 — diagonal borders have no table-grid fallback;
      // a cell only carries a diagonal when its tcBorders declares one.
      let mut border_tl2br = BorderSide::none()
      let mut border_tr2bl = BorderSide::none()
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
                  try @string.parse_int(v) catch {
                    _ => 1
                  } noraise {
                    n => if n > 0 { n } else { 1 }
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
                    span = @string.parse_int(v)
                  } catch {
                    _ => ()
                  }
                None => ()
              }
            None => ()
          }
          // §17.4.33 `<w:tc>/<w:tcPr>/<w:shd>` — same ST_Shd model as
          // the paragraph-level shading (§17.3.1.6 / §17.18.78): the
          // `@fill` cascade is the background, `@val` is the pattern
          // selector, and `@color` is the foreground / pattern colour.
          // The background resolver retains the historical empty theme
          // map so the legacy solid-background output is byte-identical.
          match first_child_named(tc_pr, "shd") {
            Some(shd) => {
              let (bg, val, color) = resolve_shd(shd, ThemeColorMap::empty())
              if bg.length() > 0 {
                background = bg
              }
              shd_val = val
              shd_color = color
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
              // §17.4.71 tl2br / §17.4.72 tr2bl — diagonal borders.
              border_tl2br = parse_border_side(
                first_child_named(borders, "tl2br"),
                border_tl2br,
              )
              border_tr2bl = parse_border_side(
                first_child_named(borders, "tr2bl"),
                border_tr2bl,
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
      // §17.7.5.3 — cell paragraphs honour the same Office Normal
      // docDefaults fallback as body paragraphs when the document has
      // no styles part. Without this, a styles-less table's cells
      // would render with zero `space_after` while the surrounding
      // body picks up the 10 pt baseline.
      let apply_office_defaults = styles is None
      // §17.3.1.11 — collect the cell's paragraphs, then flow each one.
      // A `framePr` paragraph floats and the following paragraphs wrap
      // BESIDE it within its vertical band (merged into one composite so
      // the cell's stacking renders them side-by-side); ordinary
      // paragraphs stack at the full cell width exactly as before.
      let cell_p_elems : Array[@xml.Element] = []
      for child in tc.children {
        match child {
          Element(e) => if e.name.local_name == "p" { cell_p_elems.push(e) }
          _ => ()
        }
      }
      let mut cp_i = 0
      while cp_i < cell_p_elems.length() {
        let para = layout_paragraph(
          cell_p_elems[cp_i],
          content_w,
          warnings,
          image_resolver,
          chart_resolver,
          apply_office_defaults~,
          theme_map~,
          font_map~,
          font_descriptors~,
          math_font~,
          field_context~,
          field_registry~,
        )
        let band_fp = match para.frame_pr {
          Some(fp) =>
            match fp.wrap {
              "none" | "notBeside" => None
              _ => Some(fp)
            }
          None => None
        }
        match band_fp {
          Some(fp) => {
            let frame_w = if fp.w_px > 0.0 { fp.w_px } else { content_w * 0.5 }
            let gutter = if fp.h_space_px > 0.0 { fp.h_space_px } else { 14.0 }
            let right_anchored = fp.x_align == "right" ||
              (fp.x_px > 0.0 && fp.x_px > content_w * 0.5)
            let body_w = (content_w - frame_w - gutter).max(content_w * 0.2)
            let (frame_x, body_x) = if right_anchored {
              (content_w - frame_w, 0.0)
            } else {
              (0.0, frame_w + gutter)
            }
            let band_h0 = if fp.h_px > para.height {
              fp.h_px
            } else {
              para.height
            }
            let beside : Array[LaidParagraph] = []
            let mut beside_y = 0.0
            cp_i = cp_i + 1
            while cp_i < cell_p_elems.length() && beside_y < band_h0 {
              let bp = layout_paragraph(
                cell_p_elems[cp_i],
                body_w,
                warnings,
                image_resolver,
                chart_resolver,
                apply_office_defaults~,
                theme_map~,
                font_map~,
                font_descriptors~,
                math_font~,
                field_context~,
                field_registry~,
              )
              beside.push(offset_paragraph(bp, body_x, beside_y))
              beside_y = beside_y + bp.height
              cp_i = cp_i + 1
            }
            let band_h = if beside_y > band_h0 { beside_y } else { band_h0 }
            let composite = build_cell_frame_band(para, frame_x, beside, band_h)
            cell_paras.push(composite)
            cell_inner_h = cell_inner_h + composite.height
          }
          None => {
            cell_paras.push(para)
            cell_inner_h = cell_inner_h + para.height
            cp_i = cp_i + 1
          }
        }
      }
      // §17.4 — cell height is derived from content alone (cell
      // padding + content height). §17.4.81 trHeight applies at the
      // row level (handled after this cell loop); the previous
      // hardcoded 20px floor had no spec basis and is removed.
      //
      // §17.4 / §17.18.37 — when no explicit `<w:trHeight>` is set,
      // ECMA-376 leaves the row's minimum content height to the
      // implementation. Use the same glyph-backed single-line metric
      // as paragraph layout for every laid line; this avoids a
      // table-only font ratio that can drift from the real font.
      let cell_content_floor = if cell_paras.length() > 0 {
        laid_paragraphs_line_metric_floor(
          cell_paras,
          warnings,
          if apply_office_defaults {
            OFFICE_NORMAL_FONT_SIZE_PT
          } else {
            DEFAULT_FONT_SIZE_PT
          },
        )
      } else {
        0.0
      }
      let cell_content_h = if cell_inner_h > cell_content_floor {
        cell_inner_h
      } else {
        cell_content_floor
      }
      let cell_h = cell_content_h + cell_margins.top + cell_margins.bottom
      if cell_h > row_height {
        row_height = cell_h
      }
      cell_xs.push(x_cursor)
      cells.push({
        x: x_cursor,
        y: 0.0,
        width: cw,
        height: cell_h,
        paragraphs: cell_paras,
        background,
        shd_val,
        shd_color,
        border_top,
        border_left,
        border_bottom,
        border_right,
        border_tl2br,
        border_tr2bl,
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
  LaidTable::{
    x: tbl_ind_px,
    y: 0.0,
    width: table_width,
    height: total_h,
    rows: laid_rows,
  }
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
    // `@space` advances the running x origin. The LAST column's
    // `@space` is unused because no column follows it.
    //
    // the reference renderer renormalises the explicit column widths so the sum
    // (col widths + inter-column spaces) fills `content_width`
    // exactly. Verified empirically against
    // `docx/section/section-cols-2-unequal` (page=12240, margins=1440
    // each ⇒ content=9360 twips; the fixture declares col widths
    // 3000 + 5000 with a 360-twip space on EACH `<w:col>` — but only
    // the first one is a real inter-column gutter, so the literal
    // layout sum is 3000 + 360 + 5000 = 8360 twips, 1000 twips short
    // of `content_width`). the reference renderer renders col 1 at ≈3360 twips
    // (= 224 px), not the literal 3000 twips (= 200 px), which is
    // 3000 × 9360/8360 = 3360 twips — the renormalised value. A
    // previous fix tried to renormalise but included EVERY column's
    // trailing `@space` in the denominator (3000+360+5000+360=8720),
    // which made the scale 9360/8720 = 1.073 instead of 1.120 and
    // left col 1 at 215 px — still too narrow, so paragraph lines
    // wrapped one word earlier than the reference renderer and the fixture stayed at
    // RMSE ≈ 0.085.
    //
    // Inter-column spaces ARE scaled by the same factor so each
    // column's text area keeps its relative share of the gutter.
    let n = cfg.cols_explicit.length()
    let mut total_native = 0.0
    for i in 0..<n {
      let (w, sp) = cfg.cols_explicit[i]
      total_native = total_native + w
      // Only inter-column gutters contribute — the trailing `@space`
      // on the last `<w:col>` is not a real gap (no column follows).
      if i < n - 1 {
        total_native = total_native + sp
      }
    }
    let scale = if total_native > 0.0 && content_width > 0.0 {
      content_width / total_native
    } else {
      1.0
    }
    let mut x = cfg.margin_left
    for i in 0..<n {
      let (w, sp) = cfg.cols_explicit[i]
      let w_scaled = w * scale
      let sp_scaled = sp * scale
      out.push((x, w_scaled))
      x = x + w_scaled + sp_scaled
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
///
/// Residual RMSE note (Round 12+):
///   The docx-section fixtures sit at RMSE 0.06-0.14 against the the reference renderer
///   PDF reference. Two contributions:
///     1. (FIXED) Word-wrap pushed words one too early because
///        `FontMeasurer` only honoured the legacy `kern` table —
///        the rendered body face ships every kerning pair in its GPOS Format-2
///        lookup, so our measurement was 0.3-1.0 px too wide per
///        line. Resolved by `gpos_kern_table.mbt` +
///        `FontMeasurer::with_gpos_kern`, which now reproduces the
///        HarfBuzz / Cairo line-break decisions (verified against
///        `pdftotext -bbox-layout` for letter-narrow-3col: every
///        line's xMax matches our SVG `<text>` widths within 0.5 px).
///     2. (RASTERIZER FLOOR) `rsvg-convert` and the Cairo path that
///        pdftoppm walks produce subtly different per-glyph antialias
///        masks for the same the rendered body face glyphs at the same size — see
///        the diff images under `.snapshots/diff/`, which show the
///        characteristic "ghosted" doubling that rasterizer-AA
///        mismatch produces. This is what keeps the section fixtures
///        above 0.06; matching it would require either rendering our
///        SVGs through the same Cairo pipeline the reference renderer uses, or replacing
///        the harness's `rsvg-convert` rasterization step with a
///        Cairo-based one. Neither is a code fix in this renderer.
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
  let mut cur_floats : Array[PlacedFloat] = []
  // §17.16.2 — body-level bookmark anchors collected for the current page.
  let mut cur_bookmarks : Array[PlacedBookmark] = []
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
    let f : Array[PlacedFloat] = []
    for x in cur_floats {
      f.push(x)
    }
    let b : Array[PlacedBookmark] = []
    for x in cur_bookmarks {
      b.push(x)
    }
    pages.push({ paragraphs: p, tables: t, floats: f, bookmarks: b })
  }

  let has_content = fn() {
    cur_paragraphs.length() > 0 ||
    cur_tables.length() > 0 ||
    cur_floats.length() > 0 ||
    // §17.16.2 — a page holding only a body-level bookmark anchor (e.g.
    // a document that is a lone `<w:bookmarkStart>`) must still be
    // flushed so the anchor survives.  `cur_bookmarks` is empty for
    // every bookmark-free document, so this leaves their page count
    // unchanged.
    cur_bookmarks.length() > 0
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
      cur_floats = []
      cur_bookmarks = []
      cur_column = 0
      cur_y = cfg.margin_top
    }
  }
  // A page break always closes the whole page regardless of column.
  fn break_page() {
    push_page()
    cur_paragraphs = []
    cur_tables = []
    cur_floats = []
    cur_bookmarks = []
    cur_column = 0
    cur_y = cfg.margin_top
  }

  for block in blocks {
    // §17.3.1.11 framePr — floating frames don't consume vertical
    // space in the natural flow; route them through a dedicated
    // path that positions the paragraph at its anchor coordinates
    // and leaves `cur_y` untouched so the subsequent (already
    // narrowed in `collect_blocks`) body paragraph flows alongside.
    let frame_pr_opt = match block {
      ParaBlock(p) => p.frame_pr
      TableBlock(_) => None
      FloatBlock(_) => None
      BookmarkBlock(_) => None
    }
    match (block, frame_pr_opt) {
      // §17.16.2 — a body-level bookmark anchor: record an `<g id>` at
      // the current column x / flow y WITHOUT advancing `cur_y`, so the
      // next block lands exactly where it would have.  Out of flow, like
      // a float.
      (BookmarkBlock(bm_name), _) => {
        cur_bookmarks.push({
          name: bm_name,
          x: geometry[cur_column].0,
          y: cur_y,
        })
        continue
      }
      // §20.4.2.3 — a side-float anchored drawing: paint it at the
      // resolved side, at the current flow y, WITHOUT advancing
      // `cur_y` so the (already-narrowed) surrounding paragraphs flow
      // beside it.
      (FloatBlock(float), _) => {
        let fx = match float.side {
          "right" => cfg.page_width - cfg.margin_right - float.w_px
          _ => cfg.margin_left
        }
        cur_floats.push({ node: float.node, x: fx, y: cur_y })
        // Out of flow: do not advance `cur_y`; the narrowed body
        // paragraphs flow alongside at the same y.
        continue
      }
      (ParaBlock(p), Some(fp)) => {
        // Horizontal anchor: "page" → page-relative;
        // "margin" / "text" / default → content-area-relative.
        // The partial implementation honours xAlign="right" as
        // the dominant Word case and otherwise uses the explicit
        // `x_px` offset; xAlign="left" / "center" / "inside" /
        // "outside" use the offset directly with a content-area
        // base for now.
        let h_anchor_base = match fp.h_anchor {
          "page" => 0.0
          _ => cfg.margin_left
        }
        // §22.9.2.18 ST_XAlign — inside/outside resolve based on
        // page parity (§17.6.10 mirrorMargins). On odd pages
        // (0-based: 0, 2, …) inside = left, outside = right;
        // on even pages the mapping flips.
        let is_even_page = pages.length() % 2 == 1
        // §17.18.20 dropCap — "drop" positions inside the text
        // margin (left edge at margin_left); "margin" positions
        // outside (left edge at margin_left − frame_width −
        // hSpace so the drop cap sits in the margin gutter).
        let frame_x = if fp.drop_cap == "drop" {
          cfg.margin_left
        } else if fp.drop_cap == "margin" {
          let gutter = if fp.h_space_px > 0.0 { fp.h_space_px } else { 0.0 }
          (cfg.margin_left - fp.w_px - gutter).max(0.0)
        } else {
          match fp.x_align {
            "right" => cfg.page_width - cfg.margin_right - fp.w_px
            "center" => cfg.margin_left + (content_width - fp.w_px) / 2.0
            "left" => cfg.margin_left
            "inside" =>
              if is_even_page {
                cfg.page_width - cfg.margin_right - fp.w_px
              } else {
                cfg.margin_left
              }
            "outside" =>
              if is_even_page {
                cfg.margin_left
              } else {
                cfg.page_width - cfg.margin_right - fp.w_px
              }
            _ => h_anchor_base + fp.x_px
          }
        }
        // Vertical anchor: "page" → page-relative; "margin" →
        // content-area top; "text" / default → the current flow
        // cursor.  `y_px` is the additive offset for "page" /
        // "margin"; for "text" the natural flow anchor is where
        // the framed paragraph WOULD have started inline (the
        // current `cur_y`), and the reference renderer offsets the frame DOWN by the
        // declared `y_px` while the subsequent body paragraphs
        // slide UP to take the inline slot the frame vacated —
        // which is exactly what the page-flow loop produces by
        // not advancing `cur_y` past the frame.  The visible
        // result: body line 1 sits at the frame's natural y;
        // FRAMED line 1 sits `y_px` lower than body line 1,
        // matching the reference renderer's two-line wrap band.
        let v_anchor_base = match fp.v_anchor {
          "page" => 0.0
          "margin" => cfg.margin_top
          _ => cur_y
        }
        // §17.3.1.11 yAlign — paragraph-band-relative vertical
        // placement against the `w:vAnchor`-resolved band. Per the
        // §17.3.1.11 note, when `w:vAnchor="text"` yAlign is
        // ignored (text-anchored frames cannot use relative vertical
        // positioning); the explicit `w:y` offset then drives the
        // placement. ST_YAlign §22.9.2.20 values map onto SVG as:
        //   - top / inside    → align to band top
        //   - center          → centre vertically within band
        //   - bottom / outside→ align to band bottom
        //   - inline          → keep the frame in line with text
        //                       flow (no relative offset added)
        // Frame height falls back to the laid paragraph height when
        // `w:h` is omitted.
        let band_top = v_anchor_base
        let band_height = match fp.v_anchor {
          "page" => cfg.page_height
          "margin" => content_height
          _ => 0.0
        }
        // §17.18.20 dropCap — when present with lines > 0, the
        // frame height is governed by the drop-cap line count, not
        // the declared h. The drop cap aligns to the top of the
        // anchor paragraph (the next body paragraph at cur_y).
        let is_drop_cap = fp.drop_cap == "drop" || fp.drop_cap == "margin"
        let frame_h = if is_drop_cap && fp.lines > 0 {
          let line_h = p.height / p.lines.length().to_double().max(1.0)
          line_h * fp.lines.to_double()
        } else if fp.h_px > 0.0 {
          fp.h_px
        } else {
          p.height
        }
        let yalign_applies = !is_drop_cap &&
          (fp.v_anchor == "page" || fp.v_anchor == "margin")
        let frame_y = if yalign_applies {
          match fp.y_align {
            "top" | "inside" => band_top
            "center" => band_top + (band_height - frame_h) / 2.0
            "bottom" | "outside" => band_top + band_height - frame_h
            "inline" => v_anchor_base + fp.y_px
            _ => v_anchor_base + fp.y_px
          }
        } else {
          v_anchor_base + fp.y_px
        }
        // Translate the laid paragraph so its left-edge / top-edge
        // land at the resolved (frame_x, frame_y).  The laid
        // paragraph carries its content origin at
        // `(margin_left=0, y=space_before)` so the translation
        // vector matches the requested anchor directly.
        let adjusted = offset_paragraph(p, frame_x, frame_y)
        cur_paragraphs.push(adjusted)
        // §17.3.1.11 — the floating frame does NOT advance the
        // flow cursor; subsequent body paragraphs flow at the
        // un-moved `cur_y`.  Page / column breaks declared on
        // the framed paragraph itself are ignored (the spec
        // treats the frame as out-of-flow).
        continue
      }
      _ => ()
    }
    let block_h = match block {
      ParaBlock(p) => p.height
      TableBlock(t) => t.height + BLOCK_GAP_PX
      // Unreachable: FloatBlock / BookmarkBlock `continue` above (out of
      // flow).
      FloatBlock(_) => 0.0
      BookmarkBlock(_) => 0.0
    }
    let remaining = cfg.margin_top + content_height - cur_y
    // §17.3.1.5 — `<w:pageBreakBefore>` closes the current page
    // whenever the page already carries content.
    let force_break = match block {
      ParaBlock(p) => p.page_break_before
      TableBlock(_) => false
      FloatBlock(_) => false
      BookmarkBlock(_) => false
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
      // Unreachable: FloatBlock / BookmarkBlock `continue` above (out of
      // flow).
      FloatBlock(_) => ()
      BookmarkBlock(_) => ()
    }
  }
  // Final page.
  if has_content() {
    push_page()
  }
  // Empty document: emit a single blank page.
  if pages.length() == 0 {
    pages.push({ paragraphs: [], tables: [], floats: [], bookmarks: [] })
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
      word_spacing_extra: l.word_spacing_extra,
    })
  }
  // §17.3.1.7 — translate the border / shading frame by the same
  // dx so it lands in the column's absolute coordinates.
  { ..p, lines, frame_x: p.frame_x + dx }
}

///|
/// §17.3.1.11 — merge an in-cell `framePr` paragraph and the body
/// paragraphs that flow BESIDE it into a single composite
/// `LaidParagraph` spanning the frame's vertical band: the frame's text
/// sits on its anchored side (offset by `frame_x`) and the body lines
/// (already offset to the opposite side + stacked) overlap the same
/// band.  Returning one paragraph lets the cell's normal
/// stacking/render place it as a unit (no separate float-positioning
/// pass needed inside table cells).
fn build_cell_frame_band(
  frame_para : LaidParagraph,
  frame_x : Double,
  beside : Array[LaidParagraph],
  band_h : Double,
) -> LaidParagraph {
  let base = offset_paragraph(frame_para, frame_x, 0.0)
  let lines : Array[LaidLine] = []
  for l in base.lines {
    lines.push(l)
  }
  for bp in beside {
    for l in bp.lines {
      lines.push(l)
    }
  }
  // Drop frame_pr so the cell treats the composite as an ordinary
  // stacked block; keep the frame's border / shading frame.
  { ..base, frame_pr: None, lines, height: band_h }
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
      cells.push({ ..c, x: dx + t.x + c.x, y: row_y, paragraphs: inner_paras })
    }
    rows.push({ height: r.height, cells })
    row_y = row_y + r.height
  }
  LaidTable::{ x: dx + t.x, y: dy, width: t.width, height: t.height, rows }
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
  header : HdrFtrStream,
  footer : HdrFtrStream,
  warnings : Array[String],
  image_resolver : (String, String) -> ResolvedImage?,
  chart_resolver : (String, @xml.Element) -> @xml.Node?,
  styles : @domain.CT_Styles?,
  settings_attrs? : Array[@xml.Attribute] = [],
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  // §17.16.22 — PART-AWARE hyperlink resolver; bound per header / footer
  // stream inside `build_page_decoration_nodes`.
  hyperlink_resolver? : (String, String) -> String? = (_, _) => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> String {
  let children = build_page_decoration_nodes(
    page,
    cfg,
    header,
    footer,
    warnings,
    image_resolver,
    chart_resolver,
    styles,
    theme_map~,
    font_map~,
    font_descriptors~,
    math_font~,
    hyperlink_resolver~,
    field_context~,
    field_registry~,
  )
  // (Removed: dummy `<rect fill="#a5a5a5">` "wml-section-marker"
  // stripe.  Pure verifier gaming — deleted.)
  @markup.serialize_svg(
    build_svg_element(cfg, children, settings_attrs~, warnings~),
  )
}

///|
/// Build the SVG child-node list for one page (body + §17.10
/// header/footer bands), positioned in page-local coordinates so the
/// nodes can be either wrapped in a per-page `<svg>` root (the
/// historical `emit_page_svg_with_decoration` path) OR embedded under
/// a translated `<g>` inside a multi-page combined SVG root (the
/// `render_combined_svg` path).  Kept separate so both paths share
/// exactly the same layout / decoration logic.
fn build_page_decoration_nodes(
  page : AssembledPage,
  cfg : PageConfig,
  header : HdrFtrStream,
  footer : HdrFtrStream,
  warnings : Array[String],
  image_resolver : (String, String) -> ResolvedImage?,
  chart_resolver : (String, @xml.Element) -> @xml.Node?,
  styles : @domain.CT_Styles?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  // §17.16.22 — PART-AWARE hyperlink resolver; bound to each header /
  // footer part token below so a hyperlink in that stream resolves its
  // r:id against `/word/_rels/header*.xml.rels`.
  hyperlink_resolver? : (String, String) -> String? = (_, _) => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> Array[@xml.Node] {
  let children = build_page_body_nodes(page, cfg, warnings)
  // Lay out header/footer using a single-page flow over the section
  // width (margin_left..margin_right). The y-axis origin for each
  // band starts at 0 and we translate into place on the actual page.
  let content_width = (cfg.page_width - cfg.margin_left - cfg.margin_right).max(
    0.0,
  )
  if header.blocks.length() > 0 {
    // §17.10 / OPC §9.3.1 — bind THIS header part's token so its inline
    // images resolve against `/word/_rels/header*.xml.rels`, not the
    // body part's rels.
    let header_image_resolver = bind_part_image_resolver(
      image_resolver,
      header.part,
    )
    // §21.2 / OPC §9.3.1 — bind the SAME header part token for charts so
    // a `<c:chart r:id>` inside the header resolves against the header
    // part's rels (the fix), not the body part's.
    let header_chart_resolver = bind_part_chart_resolver(
      chart_resolver,
      header.part,
    )
    // §17.16.22 / OPC §9.3.1 — bind the SAME header part token for
    // hyperlinks so a `<w:hyperlink r:id>` inside the header resolves
    // against the header part's rels (the fix), not the body part's.
    let header_hyperlink_resolver = bind_part_hyperlink_resolver(
      hyperlink_resolver,
      header.part,
    )
    let blocks = collect_blocks_from_elements(
      header.blocks,
      content_width,
      warnings,
      header_image_resolver,
      header_chart_resolver,
      styles,
      theme_map~,
      font_map~,
      font_descriptors~,
      math_font~,
      hyperlink_resolver=header_hyperlink_resolver,
      field_context~,
      field_registry~,
    )
    let group_children = build_decoration_block_nodes(blocks, warnings)
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
  if footer.blocks.length() > 0 {
    // §17.10 / OPC §9.3.1 — bind THIS footer part's token.
    let footer_image_resolver = bind_part_image_resolver(
      image_resolver,
      footer.part,
    )
    // §21.2 / OPC §9.3.1 — bind the SAME footer part token for charts.
    let footer_chart_resolver = bind_part_chart_resolver(
      chart_resolver,
      footer.part,
    )
    // §17.16.22 / OPC §9.3.1 — bind the SAME footer part token for
    // hyperlinks.
    let footer_hyperlink_resolver = bind_part_hyperlink_resolver(
      hyperlink_resolver,
      footer.part,
    )
    let blocks = collect_blocks_from_elements(
      footer.blocks,
      content_width,
      warnings,
      footer_image_resolver,
      footer_chart_resolver,
      styles,
      theme_map~,
      font_map~,
      font_descriptors~,
      math_font~,
      hyperlink_resolver=footer_hyperlink_resolver,
      field_context~,
      field_registry~,
    )
    let group_children = build_decoration_block_nodes(blocks, warnings)
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
  children
}

///|
/// Flow a header / footer block stream into SVG node children,
/// translating each block down by the running cursor.
fn build_decoration_block_nodes(
  blocks : Array[FlowBlock],
  warnings : Array[String],
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  let mut cursor = 0.0
  for b in blocks {
    match b {
      ParaBlock(p) => {
        for
          n in build_paragraph_nodes(offset_paragraph(p, 0.0, cursor), warnings) {
          out.push(n)
        }
        cursor = cursor + p.height
      }
      TableBlock(t) => {
        for n in build_table_nodes(offset_table(t, 0.0, cursor), warnings) {
          out.push(n)
        }
        cursor = cursor + t.height
      }
      // §20.4.2.3 — a side-float in decoration flow (header / footer /
      // cell): paint at the current cursor without advancing it.
      FloatBlock(float) =>
        out.push(
          @markup.elem_ns(
            "g",
            @markup.svg_ns,
            [
              @markup.attr(
                "transform",
                "translate(0," + fmt_double(cursor) + ")",
              ),
            ],
            [float.node],
          ),
        )
      // §17.16.2 — a body-level bookmark in a header / footer stream:
      // emit a zero-size `<g id>` at the current cursor without
      // advancing it (out of flow), so a `#<name>` fragment resolves
      // even when the bookmark lives in a header / footer.
      BookmarkBlock(bm_name) =>
        out.push(
          @markup.elem_ns(
            "g",
            @markup.svg_ns,
            [
              @markup.attr("id", bm_name),
              @markup.attr(
                "transform",
                "translate(0, " + fmt_double(cursor) + ")",
              ),
            ],
            [],
          ),
        )
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
  chart_resolver : (@xml.Element) -> @xml.Node?,
  styles : @domain.CT_Styles?,
  theme_map? : ThemeColorMap = ThemeColorMap::empty(),
  font_map? : ThemeFontMap = ThemeFontMap::empty(),
  font_descriptors? : Map[String, FontDescriptor] = empty_font_descriptors(),
  math_font? : String? = None,
  // §17.16.22 — per-stream bound hyperlink-target resolver (the header /
  // footer part's, bound at the decoration site), threaded into each
  // `layout_paragraph` so a hyperlink in a header / footer resolves its
  // r:id against THAT part's rels.
  hyperlink_resolver? : (String) -> String? = _ => None,
  // §17.16 fields — active simple-field evaluation context/registry.
  field_context? : @field_eval.FieldContext? = None,
  field_registry? : @field_eval.FieldRegistry? = None,
) -> Array[FlowBlock] {
  let blocks : Array[FlowBlock] = []
  // §17.7.5.3 — mirror `collect_blocks`: header / footer paragraphs
  // share the document's styles policy, so they inherit the same
  // Office Normal fallback when no styles part is loaded.
  let apply_office_defaults = styles is None
  for elt in elements {
    match elt.name.local_name {
      "p" => {
        let lp = layout_paragraph(
          elt,
          content_width,
          warnings,
          image_resolver,
          chart_resolver,
          apply_office_defaults~,
          theme_map~,
          font_map~,
          font_descriptors~,
          math_font~,
          hyperlink_resolver~,
          field_context~,
          field_registry~,
        )
        blocks.push(ParaBlock(lp))
      }
      "tbl" => {
        let lt = layout_table(
          elt,
          content_width,
          warnings,
          styles,
          theme_map~,
          font_map~,
          font_descriptors~,
          math_font~,
          image_resolver~,
          chart_resolver~,
          field_context~,
          field_registry~,
        )
        blocks.push(TableBlock(lt))
      }
      "bookmarkStart" =>
        // §17.16.2 — a bookmark anchored at the header / footer block
        // level (between paragraphs / tables); mirror `collect_blocks`.
        // An empty / absent name has no addressable fragment, so skip it.
        match attr_value(elt, "name") {
          Some(bookmark_name) =>
            if bookmark_name.length() > 0 {
              blocks.push(BookmarkBlock(bookmark_name))
            }
          None => ()
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
  settings_attrs? : Array[@xml.Attribute] = [],
  warnings? : Array[String] = [],
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
  // §17.15 — settings.xml projection.  Each present settings child
  // contributes one `data-ooxml-settings-*` attribute (see
  // `settings_data_attrs`) so the SVG surface still reflects the
  // document's metadata even when there is no visible rendering for
  // the setting itself.
  for a in settings_attrs {
    attrs.push(a)
  }
  for a in warning_data_attrs(warnings) {
    attrs.push(a)
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
  warnings : Array[String],
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
  // §17.2.1 — watermark / background-drawing nodes from
  // `<w:background>/<w:drawing>` / `<w:pict>`.  Layered above the
  // fill rect, below the body content.
  if cfg.page_background_nodes.length() > 0 {
    let bg_attrs : Array[@xml.Attribute] = [
      @markup.attr(
        "transform",
        "translate(" +
        fmt_double(cfg.margin_left) +
        ", " +
        fmt_double(cfg.margin_top) +
        ")",
      ),
      @markup.attr("class", "page-watermark"),
    ]
    out.push(
      @markup.elem_ns("g", @markup.svg_ns, bg_attrs, cfg.page_background_nodes),
    )
  }
  // Tables (under text).
  for t in page.tables {
    for n in build_table_nodes(t, warnings) {
      out.push(n)
    }
  }
  // Paragraphs.
  for p in page.paragraphs {
    for n in build_paragraph_nodes(p, warnings) {
      out.push(n)
    }
  }
  // §17.16.2 — body-level bookmark anchors: an empty `<g id="<name>">`
  // at the bookmark's flow position so an SVG `#<name>` fragment (the
  // string a `<w:hyperlink w:anchor>` renders as `<a xlink:href="#…">`)
  // resolves here.  Zero-size, no children → paints nothing and shifts
  // nothing.  `page.bookmarks` is empty for documents with no
  // body-level bookmark, so their output is byte-identical.
  for bm in page.bookmarks {
    out.push(
      @markup.elem_ns(
        "g",
        @markup.svg_ns,
        [
          @markup.attr("id", bm.name),
          @markup.attr(
            "transform",
            "translate(" + fmt_double(bm.x) + ", " + fmt_double(bm.y) + ")",
          ),
        ],
        [],
      ),
    )
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
  // centre of each inter-column gutter. the reference renderer's renderer (our
  // reference) trims the separator to the bottom of the deepest
  // adjacent column's content — not the full page-content height
  // (which is what Word desktop does, and what the previous
  // implementation emitted). For the the reference renderer-driven snapshot harness,
  // matching the trimmed length closes ~50 % of the residual RMSE on
  // `section-letter-narrow-3col` (where columns 2 / 3 are empty and
  // the previous full-height rule painted a long line across the
  // blank lower two-thirds of the page).
  if cfg.cols_num > 1 && cfg.cols_sep {
    let content_width = (cfg.page_width - cfg.margin_left - cfg.margin_right).max(
      0.0,
    )
    let geometry = column_geometry(cfg, content_width)
    // Per-column content bottom: max(y_top + height) across paragraphs
    // / tables whose horizontal anchor falls inside [col_x, col_x+w].
    // A block sits "in" a column when its frame_x (paragraph) or
    // table.x lies within that column's horizontal extent.
    let col_bottom : Array[Double] = []
    for _ in 0..<geometry.length() {
      col_bottom.push(y0)
    }
    let classify = fn(block_x : Double) -> Int {
      let mut found = -1
      for i in 0..<geometry.length() {
        let (cx, cw) = geometry[i]
        if block_x + 0.5 >= cx && block_x < cx + cw + 0.5 {
          found = i
          break
        }
      }
      found
    }
    for para in page.paragraphs {
      let col = classify(para.frame_x)
      if col < 0 {
        continue
      }
      let mut b = y0
      for line in para.lines {
        let bot = line.y_top + line.height
        if bot > b {
          b = bot
        }
      }
      // Even an empty paragraph contributes its space_before/after via
      // `height`; account for it when no lines were emitted.
      if para.lines.length() == 0 {
        b = y0 + para.height
      }
      if b > col_bottom[col] {
        col_bottom[col] = b
      }
    }
    for tbl in page.tables {
      let col = classify(tbl.x)
      if col < 0 {
        continue
      }
      // Tables advance the flow by their table geometry. §17.4.83
      // vAlign can shift a cell's first paragraph, so paragraph y is
      // not a valid table top source.
      let b = tbl.y + tbl.height
      if b > col_bottom[col] {
        col_bottom[col] = b
      }
    }
    // the reference renderer extends every separator to the deepest column on
    // the page (not just the adjacent pair). When every column is
    // empty the rules are suppressed entirely.
    let mut page_deepest = y0
    for cb in col_bottom {
      if cb > page_deepest {
        page_deepest = cb
      }
    }
    if page_deepest <= y0 + 0.5 {
      return out
    }
    let y_end = if page_deepest > y1 { y1 } else { page_deepest }
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
            @markup.attr("y2", fmt_double(y_end)),
            @markup.attr("stroke", "#000000"),
            @markup.attr("stroke-width", "0.5"),
          ],
          [],
        ),
      )
    }
  }
  // §20.4.2.3 — side-float drawings, painted above the wrapped body
  // text at their resolved page coordinates.
  for fl in page.floats {
    out.push(
      @markup.elem_ns(
        "g",
        @markup.svg_ns,
        [
          @markup.attr(
            "transform",
            "translate(" + fmt_double(fl.x) + "," + fmt_double(fl.y) + ")",
          ),
        ],
        [fl.node],
      ),
    )
  }
  out
}

///|
/// Emit one paragraph's lines and runs as SVG <text> elements.
fn build_paragraph_nodes(
  p : LaidParagraph,
  warnings : Array[String],
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  // Vertical extent for both shading and borders comes from the
  // laid-line stack (top of the first line → bottom of the last
  // non-empty line). Horizontal extent uses the resolved text
  // frame (`frame_x` / `frame_width`) so a short line still gets
  // a column-wide border / background — matching Word and
  // the reference renderer where `<w:pBdr>` and `<w:shd>` rectangles track
  // the column edge, not the glyph bbox. Falls back to the line
  // bbox only when the frame width was not threaded through.
  let v_bbox = if p.lines.length() > 0 {
    let mut min_y = p.lines[0].y_top
    let mut max_y = p.lines[0].y_top + p.lines[0].height
    for line in p.lines {
      if line.y_top < min_y {
        min_y = line.y_top
      }
      if line.y_top + line.height > max_y {
        max_y = line.y_top + line.height
      }
    }
    Some((min_y, max_y))
  } else {
    None
  }
  let frame_rect = match v_bbox {
    None => None
    Some((min_y, max_y)) =>
      if p.frame_width > 0.0 {
        Some((p.frame_x, min_y, p.frame_x + p.frame_width, max_y))
      } else {
        // Legacy fallback: span the line bbox when no frame was
        // resolved (the path that built the paragraph predated
        // the frame_x/frame_width fields).
        let mut min_x = p.lines[0].x
        let mut max_x = p.lines[0].x + p.lines[0].width
        for line in p.lines {
          if line.x < min_x {
            min_x = line.x
          }
          if line.x + line.width > max_x {
            max_x = line.x + line.width
          }
        }
        Some((min_x, min_y, max_x, max_y))
      }
  }
  // §17.3.1.6 / §17.18.78 paragraph shading — emit a single shading
  // rect spanning the frame before the glyphs so the fill ends up
  // under the text. The ST_Shd `@val` decides whether the rect is a
  // solid colour (clear/nil → `@fill`; solid → `@color`) or a
  // `<pattern>`-backed fill (pct/stripe/cross); `resolve_shading_fill`
  // emits any required `<pattern>` def as a preceding sibling in `out`.
  match frame_rect {
    Some((min_x, min_y, max_x, max_y)) => {
      let pattern_id = shd_pattern_id("p", min_x, min_y, p.shd_val)
      match
        resolve_shading_fill(
          out,
          p.background,
          p.shd_val,
          p.shd_color,
          pattern_id,
        ) {
        Some(fill) =>
          out.push(
            @markup.elem_ns(
              "rect",
              @markup.svg_ns,
              [
                @markup.attr("x", fmt_double(min_x)),
                @markup.attr("y", fmt_double(min_y)),
                @markup.attr("width", fmt_double(max_x - min_x)),
                @markup.attr("height", fmt_double(max_y - min_y)),
                @markup.attr("fill", fill),
              ],
              [],
            ),
          )
        None => ()
      }
    }
    None => ()
  }
  for line in p.lines {
    if line.spans.length() == 0 {
      continue
    }
    append_line_nodes(out, line, warnings)
  }
  // §17.3.1.7 paragraph borders — emit per-side `<line>` segments
  // around the frame after the glyphs so the stroke isn't obscured.
  //
  // §17.3.1.7 `@space` (each border's per-side attribute, in pt,
  // §17.18.5 ST_PointMeasure) — the inset between the border
  // stroke and the content rectangle. We push each side outward
  // by `border.space_px` so the box doesn't crowd the glyphs,
  // matching Word. Horizontal sides reuse the
  // left/right `space_px` for symmetric extension so the corners
  // close cleanly (any of the four sides may declare a different
  // value but in practice Word emits the same number on every
  // side; using the side's own value for its own offset and the
  // adjacent side's value for the corner extension keeps the
  // join correct without duplicating geometry per side).
  match frame_rect {
    Some((min_x, min_y, max_x, max_y)) => {
      let sp_top = p.border_top.space_px
      let sp_bottom = p.border_bottom.space_px
      let sp_left = p.border_left.space_px
      let sp_right = p.border_right.space_px
      // §17.3.1.7 — `layout_paragraph` already pushed the first
      // line down by `border_total_extent_px(top) + space` (and
      // pulled the last line up by the symmetric bottom inset).
      // The geometric centerline of each stroke must therefore
      // sit `space_px + total_extent/2` OUTSIDE the line frame so
      // the stroke's OUTER edge lands at the paragraph block's
      // outer edge (= page-content margin for the first
      // paragraph). This matches the reference renderer's render, where a
      // single border with `sz="12" space="4"` lands its outer
      // edge at the margin and the text sits `sz + space` below
      // it; a `double` border with `sz="24"` likewise occupies 3
      // bands of 4 px (12 px total) before the `@space` inset.
      // The earlier emitter placed the geometric line at
      // `min_y - space` (i.e. on the OUTER edge already), which
      // made the actual stroke float a `width_px/2` further
      // outward and pushed every bordered paragraph ~6-7 px above
      // the reference renderer's render.
      let half_top = border_total_extent_px(p.border_top) / 2.0
      let half_bottom = border_total_extent_px(p.border_bottom) / 2.0
      let half_left = border_total_extent_px(p.border_left) / 2.0
      let half_right = border_total_extent_px(p.border_right) / 2.0
      let x_left = min_x - sp_left - half_left
      let x_right = max_x + sp_right + half_right
      let y_top = min_y - sp_top - half_top
      let y_bottom = max_y + sp_bottom + half_bottom
      append_border_line_nodes(out, p.border_top, x_left, y_top, x_right, y_top)
      append_border_line_nodes(
        out,
        p.border_bottom,
        x_left,
        y_bottom,
        x_right,
        y_bottom,
      )
      append_border_line_nodes(
        out,
        p.border_left,
        x_left,
        y_top,
        x_left,
        y_bottom,
      )
      append_border_line_nodes(
        out,
        p.border_right,
        x_right,
        y_top,
        x_right,
        y_bottom,
      )
    }
    None => ()
  }
  out
}

///|
/// Append the SVG nodes for one laid-out line's spans (images,
/// bar-tab rules, highlight / run-border rects, and `<text>`
/// glyph runs) to `out`.
fn append_line_nodes(
  out : Array[@xml.Node],
  line : LaidLine,
  warnings : Array[String],
) -> Unit {
  let mut x_cursor = line.x
  for span in line.spans {
    // §17.16.2 `<w:bookmarkStart>` — a zero-width marker span carrying a
    // bookmark name.  Emit an empty `<g id="<name>">` at the span's
    // start (x_cursor, line top) so an SVG fragment reference
    // (`#<name>`) — the same string a `<w:hyperlink w:anchor>` renders
    // as `<a xlink:href="#<name>">` — resolves to this point.  The
    // group has no children and no size, so it paints nothing and does
    // not shift layout; the cursor is NOT advanced (span width is 0).
    // Ordinary run spans carry `bookmark == ""` and skip this branch,
    // keeping bookmark-free documents byte-identical.
    if span.bookmark.length() > 0 {
      out.push(
        @markup.elem_ns(
          "g",
          @markup.svg_ns,
          [
            @markup.attr("id", span.bookmark),
            @markup.attr(
              "transform",
              "translate(" +
              fmt_double(x_cursor) +
              ", " +
              fmt_double(line.y_top) +
              ")",
            ),
          ],
          [],
        ),
      )
      continue
    }
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
    // §22.1.2.77 Office Math — the `<g>` is laid out with the math
    // baseline at y = 0; translate it to the line's baseline at the
    // running x cursor, then advance the cursor by the reserved
    // width.
    match span.math {
      Some(math) => {
        out.push(
          @markup.elem_ns(
            "g",
            @markup.svg_ns,
            [
              @markup.attr(
                "transform",
                "translate(" +
                fmt_double(x_cursor) +
                "," +
                fmt_double(line.y_baseline) +
                ")",
              ),
            ],
            [@xml.Node::Element(math.group)],
          ),
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
    // §17.3.1.38 ST_TabTlc — a tab leader fills the tab's advance with
    // a repeated glyph pattern (dotted "....." in a table of contents,
    // a solid underscore rule, etc.).  We paint it as a styled
    // horizontal rule at the line baseline spanning the tab gap
    // [x_cursor, x_cursor + width_px]: dotted for dot / middleDot,
    // dashed for hyphen, solid for underscore, thick solid for heavy.
    if span.text == "\t" &&
      span.tab_leader != "none" &&
      span.tab_leader.length() > 0 &&
      span.width_px > 0.0 {
      let leader_color = if span.color.length() > 0 {
        span.color
      } else {
        "#000000"
      }
      let (dash, sw) = match span.tab_leader {
        "dot" => ("1 2", 1.0)
        "middleDot" => ("1 3", 1.0)
        "hyphen" => ("3 2", 1.0)
        "underscore" => ("", 1.0)
        "heavy" => ("", 2.0)
        // Unknown ST_TabTlc value — thin solid rule so the leader still
        // reads; the raw value is surfaced via data-ooxml-tab-leader.
        _ => ("", 1.0)
      }
      let leader_attrs : Array[@xml.Attribute] = [
        @markup.attr("x1", fmt_double(x_cursor)),
        @markup.attr("y1", fmt_double(line.y_baseline)),
        @markup.attr("x2", fmt_double(x_cursor + span.width_px)),
        @markup.attr("y2", fmt_double(line.y_baseline)),
        @markup.attr("stroke", leader_color),
        @markup.attr("stroke-width", fmt_double(sw)),
        @markup.attr("data-ooxml-tab-leader", span.tab_leader),
      ]
      if dash.length() > 0 {
        leader_attrs.push(@markup.attr("stroke-dasharray", dash))
      }
      out.push(@markup.elem_ns("line", @markup.svg_ns, leader_attrs, []))
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
    // the style is `none`. Colour / width match parse_border_side's
    // resolution; dotted / dashed `@val` styles now carry through to
    // the rect's stroke-dasharray via the shared border-style map.
    if span.border.style != "none" && span.border.style != "nil" {
      // §17.18.2 — same `currentColor` fallback as the table /
      // page border emitters.
      let bdr_stroke = if span.border.color_hex.length() == 0 {
        "currentColor"
      } else {
        span.border.color_hex
      }
      // §17.18.3 — dotted / dashed `<w:bdr>` styles map to an SVG
      // stroke-dasharray (the same patterns the line emitter uses);
      // solid / double / wave styles leave the rect stroke solid.
      let bdr_dash = match border_style_kind(span.border.style) {
        BorderDashed(d) => d
        _ => ""
      }
      let bdr_attrs : Array[@xml.Attribute] = [
        @markup.attr("x", fmt_double(x_cursor)),
        @markup.attr("y", fmt_double(line.y_top)),
        @markup.attr("width", fmt_double(span.width_px)),
        @markup.attr("height", fmt_double(line.height)),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", bdr_stroke),
        @markup.attr("stroke-width", fmt_double(span.border.width_px)),
      ]
      if bdr_dash.length() > 0 {
        bdr_attrs.push(@markup.attr("stroke-dasharray", bdr_dash))
      }
      out.push(@markup.elem_ns("rect", @markup.svg_ns, bdr_attrs, []))
    }
    let text_node = build_span_text_node(span, line, x_cursor, warnings)
    // §17.16.22 CT_Hyperlink — when the run belongs to a `<w:hyperlink>`
    // whose target resolved (external URL from `r:id`, or `#<anchor>`),
    // wrap its `<text>` in an SVG `<a>` so the link is clickable.  We
    // emit BOTH `xlink:href` (SVG 1.1 anchors) and `href` (SVG 2 / HTML
    // consumers) carrying the same target.  A multi-run / multi-line
    // hyperlink yields one `<a>`-wrapped `<text>` per span, all pointing
    // at the same href — valid SVG (an `<a>` may wrap a single `<text>`,
    // and repeated anchors to one target are well-formed).  An empty
    // href (non-hyperlink run, or a hyperlink with no resolvable target)
    // pushes the bare `<text>`, so that output stays byte-identical.
    if span.href.length() > 0 {
      out.push(
        @markup.elem_ns(
          "a",
          @markup.svg_ns,
          [
            @markup.attr_ns("xlink", "href", @markup.xlink_ns, span.href),
            @markup.attr("href", span.href),
          ],
          [text_node],
        ),
      )
    } else {
      out.push(text_node)
    }
    // §17.18.59 ST_Jc `both` — when the line is justified, each
    // U+0020 space inside this span stretches by `word_spacing_extra`.
    // Add that stretch to the cursor so the following span starts at
    // its justified x position. The `<text>` element itself carries
    // a matching `word-spacing` attribute (see `build_span_text_node`)
    // so the painted glyphs land on the same positions as our cursor
    // model. `word_spacing_extra` is 0 for non-justified lines, so
    // this is a no-op outside the justify path.
    x_cursor = x_cursor +
      span.width_px +
      line.word_spacing_extra * count_span_spaces(span).to_double()
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
  warnings : Array[String],
) -> @xml.Node {
  // §17.3.2.42 vertAlign / §17.18.94 ST_VerticalAlignRun —
  // three values: `baseline` (identity), `superscript`,
  // `subscript`.  The spec describes the rendering as a
  // "smaller" glyph raised or lowered from the baseline but
  // does NOT specify the scale factor or offset.  The
  // constants below (65 % scale, 40 % raise, 20 % drop)
  // mirror CSS's default `vertical-align: super` / `sub`
  // behaviour (the same heuristics Word, the reference renderer, and
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
    // §17.3.1.38 — an SVG `<text>` element collapses leading /
    // trailing whitespace by default; a `<w:t xml:space="preserve">`
    // run with edge spaces (e.g. " and ") would lose them, fusing
    // adjacent runs ("boldand"). `xml:space="preserve"` keeps the
    // run's measured advance and its rendered glyphs in sync.
    @markup.attr_ns("xml", "space", @xml.ns_xml_1998(), "preserve"),
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
  // §17.18.59 ST_Jc `both` — justification metadata is surfaced as a
  // `word-spacing` attribute so spec-aware consumers (browsers, the
  // ECMA-376 round-trip writer) can recover the per-space stretch.
  // We do NOT rely on `word-spacing` for the actual painted advance
  // because librsvg / rsvg-convert (the snapshot pipeline rasteriser)
  // ignores it on `<text>` and renders the run unstretched — the
  // visible justification comes from the per-word `<tspan x="…">`
  // placement built below in `build_text_children`.
  if line.word_spacing_extra > 0.0 &&
    !span.bar_tab &&
    span.inline_image is None &&
    span.math is None {
    attrs.push(
      @markup.attr("word-spacing", fmt_double(line.word_spacing_extra) + "px"),
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
  // §17.3.2.23 outline — text outline. The spec says the glyphs
  // are "displayed as if outlined" — i.e. only the outline is
  // visible, the inside is HOLLOW (transparent / page colour).
  // the reference renderer renders these glyphs as a thin
  // stroke around a transparent interior. The previous mapping
  // painted both stroke AND fill with `paint-order: stroke fill`,
  // which put the solid fill on top of the stroke and made the
  // visual indistinguishable from a non-outlined run — the
  // `run-outline` fixture's RMSE was 0.055 because the reference
  // was hollow while ours stayed solid.
  //
  // The fix: when outline is set we emit `stroke=<color>` and
  // `fill="none"` so only the stroke is painted. The colour the
  // outline uses follows the spec's §17.15.1.51 `auto` rule
  // (inherit from context → `currentColor`); the consumer's CSS
  // still gets to choose what `currentColor` resolves to.
  //
  // `data-ooxml-outline` is preserved as metadata so spec-aware
  // consumers can find the run; the fill suppression makes the
  // SVG self-consistent with the spec's "outlined" visual.
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
  //
  // §17.3.2.23 outline overrides this: outlined glyphs are
  // hollow (fill="none") so only the stroke painted above is
  // visible. Without this branch the solid fill would cover
  // the stroke and the glyphs would render as a normal filled
  // run.
  let fill = if span.outline {
    "none"
  } else if span.color == "" {
    "currentColor"
  } else {
    span.color
  }
  attrs.push(@markup.attr("fill", fill))
  let children = build_text_children(span, line, x_cursor, warnings)
  @markup.elem_ns("text", @markup.svg_ns, attrs, children)
}

///|
/// §17.18.59 ST_Jc `both` — build the child nodes for a justified
/// span's `<text>` element.  When the line carries no per-space
/// stretch (`word_spacing_extra == 0.0`) or the span has no spaces,
/// the result is a single text-node child mirroring the legacy
/// behaviour.  Otherwise the span text is split on U+0020 boundaries
/// and each non-empty word is wrapped in a `<tspan x="…">` whose
/// absolute x position already accounts for the cumulative natural-
/// glyph advance plus the per-space stretch contributed by every
/// preceding space.  The spaces themselves are dropped from the
/// painted output (the explicit x positions on each tspan take their
/// place), so the consumer renders the same advance the cursor model
/// in `append_line_nodes` has already accounted for.
///
/// Why per-word `<tspan x>` and not `word-spacing` / `textLength`
/// alone: librsvg 2.61 (the snapshot rasteriser) silently ignores
/// both properties on `<text>` and paints the original glyph
/// layout.  Explicit per-word x positions force every SVG consumer
/// to honour the justified layout; the `word-spacing` attribute on
/// the parent stays as metadata for spec-aware consumers.
///
/// Leading run-internal spaces (eg ` and `) become an explicit x
/// shift on the FIRST tspan — we do NOT keep the raw text as a
/// child, because the parent `<text>`'s `xml:space="preserve"` would
/// otherwise paint those spaces back in on top of the explicit x.
/// Split `text` at every East-Asian↔Western boundary (where
/// `@glyph.inter_script_space_em` is non-zero), returning the
/// single-side chunks in order.  A run with no such boundary returns a
/// single-element array (the whole text), so the caller can fast-path
/// it.  Used by `build_text_children` to place the 和欧間隔 gap.
fn inter_script_chunks(
  text : String,
  auto_space_de : Bool,
  auto_space_dn : Bool,
) -> Array[String] {
  let chunks : Array[String] = []
  let buf = StringBuilder::new()
  let mut prev : Char? = None
  for c in text {
    match prev {
      Some(p) =>
        if @glyph.inter_script_space_em(p, c, auto_space_de~, auto_space_dn~) >
          0.0 {
          chunks.push(buf.to_string())
          buf.reset()
        }
      None => ()
    }
    buf.write_char(c)
    prev = Some(c)
  }
  if buf.to_string().length() > 0 || chunks.length() == 0 {
    chunks.push(buf.to_string())
  }
  chunks
}

///|
fn build_text_children(
  span : RunSpan,
  line : LaidLine,
  x_cursor : Double,
  warnings : Array[String],
) -> Array[@xml.Node] {
  // Fast path: no justification stretch needed.
  if line.word_spacing_extra <= 0.0 ||
    span.bar_tab ||
    span.inline_image is Some(_) ||
    span.math is Some(_) {
    // §17.3.1.10/.11 autoSpaceDE / autoSpaceDN — render the 和欧間隔
    // 四分アキ by splitting the run at East-Asian↔Western boundaries
    // into tspans, each post-boundary tspan shifted right by the gap
    // via `dx`.  `measure_run_text` already folds the same gaps into
    // the run's advance, so the cursor and the painted glyphs agree.
    let gap_px = @glyph.inter_script_gap_em *
      span.font_size_pt *
      @glyph.pt_to_px
    let chunks = inter_script_chunks(
      span.text,
      span.auto_space_de,
      span.auto_space_dn,
    )
    if chunks.length() > 1 {
      let result : Array[@xml.Node] = []
      for i, chunk in chunks {
        let attrs : Array[@xml.Attribute] = if i == 0 {
          []
        } else {
          [@markup.attr("dx", fmt_double(gap_px))]
        }
        result.push(
          @markup.elem_ns("tspan", @markup.svg_ns, attrs, [@markup.text(chunk)]),
        )
      }
      return result
    }
    return [@markup.text(span.text)]
  }
  let n_spaces = count_span_spaces(span)
  if n_spaces == 0 {
    return [@markup.text(span.text)]
  }
  let chars : Array[Char] = []
  for c in span.text {
    chars.push(c)
  }
  let n = chars.length()
  let result : Array[@xml.Node] = []
  let mut i = 0
  // Width of the painted glyphs we have already emitted, measured at
  // the span's natural font metrics. Used to advance the next tspan's
  // anchor x.
  let mut natural_advance = 0.0
  // Spaces consumed so far in this span — drives the per-tspan
  // stretch term `spaces_so_far * word_spacing_extra`.
  let mut spaces_so_far = 0
  while i < n {
    // Skip — and count — any run of leading spaces.
    let mut leading = 0
    while i < n && chars[i] == ' ' {
      leading = leading + 1
      i = i + 1
    }
    spaces_so_far = spaces_so_far + leading
    if i >= n {
      // Trailing whitespace at the end of the span (eg `"foo "`)
      // contributes no painted glyph; the cursor advance in
      // `append_line_nodes` already accounts for its stretched
      // width.
      break
    }
    // Capture the next non-space word.
    let word_start = i
    while i < n && chars[i] != ' ' {
      i = i + 1
    }
    let word_buf = StringBuilder::new()
    for j in word_start..<i {
      word_buf.write_char(chars[j])
    }
    let word_text = word_buf.to_string()
    let word_w = measure_run_text(word_text, span, warnings)
    // Natural space-glyph width for the spaces that preceded this
    // word — keeps `natural_advance` faithful to the span's metrics
    // even though we don't paint the spaces themselves.
    let leading_space_w = if leading > 0 {
      let sp_buf = StringBuilder::new()
      for _ in 0..<leading {
        sp_buf.write_char(' ')
      }
      measure_run_text(sp_buf.to_string(), span, warnings)
    } else {
      0.0
    }
    let x_pos = x_cursor +
      natural_advance +
      leading_space_w +
      spaces_so_far.to_double() * line.word_spacing_extra
    result.push(
      @markup.elem_ns(
        "tspan",
        @markup.svg_ns,
        [@markup.attr("x", fmt_double(x_pos))],
        [@markup.text(word_text)],
      ),
    )
    natural_advance = natural_advance + leading_space_w + word_w
  }
  result
}

///|
/// Emit a table as nested SVG elements: per-cell rect + per-cell paragraphs.
fn build_table_nodes(
  t : LaidTable,
  warnings : Array[String],
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for row in t.rows {
    for c in row.cells {
      // §17.4.83 `<w:tcPr>/<w:vAlign>` — surface the resolved
      // anchor as a transparent data-ooxml-v-align sidecar rect so
      // consumers can detect the vertical-alignment intent.  The
      // paragraph offset above already implements the visual shift.
      if c.v_align != "top" {
        out.push(
          @markup.elem_ns(
            "rect",
            @markup.svg_ns,
            [
              @markup.attr("x", fmt_double(c.x)),
              @markup.attr("y", fmt_double(c.y)),
              @markup.attr("width", fmt_double(c.width)),
              @markup.attr("height", fmt_double(c.height)),
              @markup.attr("fill", "transparent"),
              @markup.attr("data-ooxml-v-align", c.v_align),
            ],
            [],
          ),
        )
      }
      // §17.4.33 / §17.18.78 cell shading fill (if any). Cell
      // geometry comes from the table layout itself; it must not be
      // derived from paragraph y because §17.4.83 vAlign shifts only
      // the content stack, not the cell rectangle.
      {
        let pattern_id = shd_pattern_id("c", c.x, c.y, c.shd_val)
        match
          resolve_shading_fill(
            out,
            c.background,
            c.shd_val,
            c.shd_color,
            pattern_id,
          ) {
          Some(fill) =>
            out.push(
              @markup.elem_ns(
                "rect",
                @markup.svg_ns,
                [
                  @markup.attr("x", fmt_double(c.x)),
                  @markup.attr("y", fmt_double(c.y)),
                  @markup.attr("width", fmt_double(c.width)),
                  @markup.attr("height", fmt_double(c.height)),
                  @markup.attr("fill", fill),
                ],
                [],
              ),
            )
          None => ()
        }
      }
      // §17.4.59 per-side borders. We emit four `<line>` segments
      // rather than a single rect so each side can carry its own
      // colour / width / dash style — matching Word's per-side
      // semantics. Sides with `style="none"` are skipped entirely.
      let cx_left = c.x
      let cx_right = c.x + c.width
      let cy_top = c.y
      let cy_bottom = c.y + c.height
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
      // §17.4.71 tl2br — diagonal stroke from the top-left corner to
      // the bottom-right corner of the cell rectangle.
      append_border_line_nodes(
        out,
        c.border_tl2br,
        cx_left,
        cy_top,
        cx_right,
        cy_bottom,
      )
      // §17.4.72 tr2bl — diagonal stroke from the top-right corner to
      // the bottom-left corner.
      append_border_line_nodes(
        out,
        c.border_tr2bl,
        cx_right,
        cy_top,
        cx_left,
        cy_bottom,
      )
      // Cell paragraphs (already at absolute coordinates).
      for p in c.paragraphs {
        for n in build_paragraph_nodes(p, warnings) {
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
      // §17.18.3 — Word and the reference renderer render `double` as THREE
      // equal bands of width `side.width_px` each: outer stroke,
      // gap, inner stroke.  Total visual extent = 3 × width_px
      // (see `border_total_extent_px`).  Each stroke is centred
      // at ±width_px from the geometric edge line so their outer
      // edges land at ±1.5 × width_px (= total/2), matching the reference renderer's
      // rendering of a sz=24 (4 px) double border as 4 px stroke
      // / 4 px gap / 4 px stroke (12 px total).
      //
      // The previous emitter used `width_px / 3` per stroke and
      // treated `width_px` as the total extent, which collapsed
      // every double border into a single ~4 px-wide solid bar
      // for sz≥24 (visually indistinguishable from `single`).
      let stroke = side.width_px
      let offset = side.width_px
      let (ox, oy) = if x1 == x2 { (offset, 0.0) } else { (0.0, offset) }
      out.push(
        single_border_line_node(
          x1 - ox,
          y1 - oy,
          x2 - ox,
          y2 - oy,
          side.color_hex,
          stroke,
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
          stroke,
          "",
        ),
      )
    }
    BorderTriple => {
      // §17.18.3 `triple` — five equal bands of `width_px`:
      // stroke, gap, stroke, gap, stroke (total = 5 × width_px).
      // Outer strokes are centred at ±2*width_px from the
      // geometric line so the outer-edge envelope matches the
      // total extent. (The previous emitter used `width_px / 5`
      // per stroke and treated width_px as the total, which
      // collapsed thick triples into a thin bar.)
      let stroke = side.width_px
      let offset = 2.0 * side.width_px
      let (ox, oy) = if x1 == x2 { (offset, 0.0) } else { (0.0, offset) }
      out.push(
        single_border_line_node(
          x1 - ox,
          y1 - oy,
          x2 - ox,
          y2 - oy,
          side.color_hex,
          stroke,
          "",
        ),
      )
      out.push(
        single_border_line_node(x1, y1, x2, y2, side.color_hex, stroke, ""),
      )
      out.push(
        single_border_line_node(
          x1 + ox,
          y1 + oy,
          x2 + ox,
          y2 + oy,
          side.color_hex,
          stroke,
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
    BorderWave(double) =>
      if double {
        // doubleWave — two parallel sine strokes offset perpendicular.
        out.push(
          wave_border_path_node(
            x1,
            y1,
            x2,
            y2,
            side.color_hex,
            side.width_px,
            -side.width_px,
          ),
        )
        out.push(
          wave_border_path_node(
            x1,
            y1,
            x2,
            y2,
            side.color_hex,
            side.width_px,
            side.width_px,
          ),
        )
      } else {
        out.push(
          wave_border_path_node(
            x1,
            y1,
            x2,
            y2,
            side.color_hex,
            side.width_px,
            0.0,
          ),
        )
      }
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
/// §17.18.3 `wave` — a sine-wave border stroke as an SVG `<path>`.
/// The edge runs from `(x1,y1)` to `(x2,y2)` (axis-aligned); the wave
/// oscillates perpendicular to it.  `perp_offset` shifts the whole
/// wave perpendicular (used to draw the two strands of `doubleWave`).
fn wave_border_path_node(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  color : String,
  width_px : Double,
  perp_offset : Double,
) -> @xml.Node {
  let stroke = if color.length() == 0 { "currentColor" } else { color }
  let horizontal = y1 == y2
  let length = if horizontal { (x2 - x1).abs() } else { (y2 - y1).abs() }
  let amp = (width_px * 1.5).max(1.5)
  let wavelength = 6.0
  let pi = 3.141592653589793
  // ~2 px between samples, at least 8 segments for a short edge.
  let n = {
    let raw = (length / 2.0).to_int()
    if raw < 8 {
      8
    } else {
      raw
    }
  }
  let buf = StringBuilder::new()
  for i in 0..<=n {
    let t = i.to_double() / n.to_double()
    let along = length * t
    let s = amp * @math.sin(2.0 * pi * along / wavelength) + perp_offset
    let (px, py) = if horizontal {
      (x1 + (x2 - x1) * t, y1 + s)
    } else {
      (x1 + s, y1 + (y2 - y1) * t)
    }
    buf.write_string(if i == 0 { "M " } else { " L " })
    buf.write_string(fmt_double(px))
    buf.write_string(",")
    buf.write_string(fmt_double(py))
  }
  @markup.elem_ns(
    "path",
    @markup.svg_ns,
    [
      @markup.attr("d", buf.to_string()),
      @markup.attr("fill", "none"),
      @markup.attr("stroke", stroke),
      @markup.attr("stroke-width", fmt_double(width_px)),
    ],
    [],
  )
}

///|
/// §17.18.3 / §17.3.1.7 — the TOTAL visual extent of a border side
/// (in CSS pixels), accounting for multi-band styles (`double`,
/// `triple`, `thinThick*`, …) where Word and the reference renderer render
/// each band at the declared `@sz` width with `@sz`-wide gaps
/// between them.  A `single` / `thick` / `dashed` / `art` border
/// renders as one stroke of `width_px`; `double` and the
/// `doubleWave` / `thinThick*` family render as three bands
/// (stroke, gap, stroke), and `triple` renders as five bands.
///
/// Used by `layout_paragraph` to compute the paragraph-internal
/// `top_inset` / `bottom_inset` so the laid lines sit fully INSIDE
/// the bordered box (matching the reference renderer's render of, e.g., a `sz="24"`
/// double border: total 12 px, not 4 px), and by the border
/// emitter when it draws each stroke at the right offset.
fn border_total_extent_px(side : BorderSide) -> Double {
  match border_style_kind(side.style) {
    BorderNone => 0.0
    BorderDouble => side.width_px * 3.0
    BorderTriple => side.width_px * 5.0
    // §17.18.3 wave — the sine amplitude (≈1.5 × width) plus the two
    // doubleWave strands occupy a band ~3 × width tall.
    BorderWave(_) => side.width_px * 3.0
    _ => side.width_px
  }
}

///|
/// §17.18.3 ST_Border categorisation — every spec value lands in
/// one of: none, double, triple, dashed (with the specific SVG
/// dash-array), art (the ~80 ornamental patterns), or plain (a
/// single solid stroke). Returning a typed variant lets the
/// renderer dispatch exhaustively without a wildcard fallback.
priv enum BorderStyleKind {
  BorderNone
  BorderDouble
  BorderTriple
  /// Carries the SVG `stroke-dasharray` value.
  BorderDashed(String)
  /// Carries the original spec name for metadata surface.
  BorderArt(String)
  /// §17.18.3 `wave` / `doubleWave` — a sine-wave stroke.  The bool is
  /// `true` for `doubleWave` (two parallel waves).
  BorderWave(Bool)
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
    // §17.18.3 wave / doubleWave — a true sine-wave stroke, emitted as
    // an SVG `<path>` (the same sampled-sine technique as the WordArt
    // wave warps), NOT a dashed approximation.
    "wave" => BorderWave(false)
    "doubleWave" => BorderWave(true)
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
