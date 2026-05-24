// @source web-pptx packages/@aurochs-renderer/pptx/src/text-layout/types.ts
//
// Type definitions for the DrawingML text-layout engine.  All
// measurements use plain `Double` (pixels for distances, points for
// font sizes) — the TypeScript reference uses branded `Pixels` /
// `Points` types but in MoonBit we keep them as `Double` and rely on
// disciplined field naming.
//
// ECMA-376 references:
//   §21.1.2     DrawingML text
//   §21.1.2.1   bodyPr attributes (anchor, anchorCtr, autoFit, ...)
//   §21.1.2.2   pPr attributes (alignment, marL, marR, indent, lvl)
//   §21.1.2.3   rPr attributes (font, size, weight, fill, ...)
//   §21.1.2.4   buAutoNum / buChar / buBlip
//   §21.1.2.1.39 ST_TextVerticalType
//   §21.1.2.1.12 ST_TextFontAlignType
//   §21.1.2.2.5 a:lnSpc

///|
/// Auto-fit configuration for text scaling.  Mirrors `AutoFitConfig`
/// in `text-layout/types.ts:28`.
pub(all) enum AutoFitConfig {
  /// `<a:noAutofit/>` — no scaling.  §21.1.2.1.1.
  AutoFitNone
  /// `<a:spAutoFit/>` — shape resizes to fit text.  §21.1.2.1.3.
  AutoFitShape
  /// `<a:normAutofit fontScale="..%" lnSpcReduction="..%"/>`.
  /// §21.1.2.1.2.
  AutoFitNormal(Double, Double)
}

///|
/// Anchor describes where the text block sits inside the shape.
/// Mirrors `TextAnchor` in `pptx/domain/types.ts`.
pub(all) enum TextAnchor {
  AnchorTop
  AnchorCenter
  AnchorBottom
  AnchorJustified
  AnchorDistributed
} derive(Eq, Show)

///|
/// Horizontal alignment of paragraph text.  Mirrors `TextAlign` in
/// `pptx/domain/types.ts`.
pub(all) enum TextAlign {
  AlignLeft
  AlignCenter
  AlignRight
  AlignJustify
  AlignJustifyLow
  AlignDistributed
  AlignThaiDistributed
  /// §21.1.2.2.9 — tab-stop only: aligns the line content on the
  /// decimal separator. Not valid for `<a:pPr @algn>` paragraphs.
  AlignDecimal
} derive(Eq, Show)

///|
/// `<a:bodyPr wrap="square|none"/>` plus our internal "wrap" alias.
pub(all) enum TextWrapping {
  WrapNone
  WrapSquare
} derive(Eq, Show)

///|
/// `<a:bodyPr horzOverflow="overflow|clip"/>`.  §21.1.2.1.16.
pub(all) enum TextOverflow {
  OverflowAllow
  OverflowClip
} derive(Eq, Show)

///|
/// `<a:bodyPr vertOverflow="overflow|ellipsis|clip"/>`.  §21.1.2.1.42.
pub(all) enum TextVerticalOverflow {
  VertOverflowAllow
  VertOverflowEllipsis
  VertOverflowClip
} derive(Eq, Show)

///|
/// `<a:bodyPr vert="..."/>`.  §21.1.2.1.39.
pub(all) enum TextVerticalType {
  VertHorz
  VertVert
  VertEastAsianVert
  VertVert270
  VertWordArtVert
  VertMongolianVert
  VertWordArtVertRtl
} derive(Eq, Show)

///|
/// `<a:bodyPr>/<a:lnSpc>` either fixed-point or percent of font size.
/// §21.1.2.2.5.
pub(all) enum LineSpacing {
  /// Percent of the line's largest font size; `value` is the percent
  /// (e.g. 100 = 1.0, 150 = 1.5).
  LineSpacingPercent(Double)
  /// Absolute spacing in points.
  LineSpacingPoints(Double)
}

///|
/// Font alignment within a line (controls baseline placement when
/// runs have different font sizes).  §21.1.2.1.12.
pub(all) enum FontAlignment {
  FontAlignAuto
  FontAlignTop
  FontAlignCenter
  FontAlignBase
  FontAlignBottom
} derive(Eq, Show)

///|
/// Tab-stop position and alignment.  §21.1.2.2.14.
pub struct LayoutTabStop {
  /// Position in pixels from the left edge.
  position : Double
  alignment : TextAlign
}

///|
/// Text-box configuration assembled by the adapter from `<a:bodyPr>`
/// + render-options.  Mirrors `TextBoxConfig` in
/// `text-layout/types.ts:46`.
pub struct TextBoxConfig {
  width : Double
  height : Double
  inset_left : Double
  inset_right : Double
  inset_top : Double
  inset_bottom : Double
  anchor : TextAnchor
  /// `anchorCtr` — centre the content horizontally.  §21.1.2.1.2.
  anchor_center : Bool
  wrap_mode : TextWrapping
  auto_fit : AutoFitConfig
  horz_overflow : TextOverflow
  vert_overflow : TextVerticalOverflow
  compat_ln_spc : Bool
  force_aa : Bool
  rtl_col : Bool
  spc_first_last_para : Bool
  upright : Bool
  vertical_type : TextVerticalType
}

///|
/// Outline (stroke) configuration applied to glyph outlines.
/// §20.1.2.2.24 (a:ln).
pub struct TextOutlineConfig {
  width : Double
  /// Hex colour string with leading `#`.
  color : String
  /// One of `"butt"`, `"round"`, `"square"`.
  cap : String
  /// One of `"miter"`, `"round"`, `"bevel"`.
  join : String
}

///|
/// Gradient stop used by `TextFillConfig::Gradient`.
pub struct TextGradientStop {
  position : Double
  /// Hex colour string with leading `#`.
  color : String
  alpha : Double
}

///|
/// Text fill mode.  Mirrors `TextFillConfig` in
/// `@aurochs-office/drawing-ml/domain/text-fill.ts`.
pub(all) enum TextFillConfig {
  TextFillSolid(String, Double) // colour-hex (with #), alpha
  TextFillNone
  TextFillGradient(Array[TextGradientStop], Double, Bool) // stops, angle, isRadial
  TextFillPattern(String, String) // fg-hex, bg-hex (simplified)
  TextFillImage(String) // src URL
}

///|
/// Resolved text span — everything needed to lay out and render one
/// stretch of run-level content.  Mirrors `LayoutSpan` in
/// `text-layout/types.ts:166`.
pub struct LayoutSpan {
  text : String
  /// Font size in points.
  font_size : Double
  /// Primary font family.
  font_family : String
  /// Secondary East-Asian font family (a:ea).  §21.1.2.3.2.
  font_family_east_asian : String?
  /// Complex-script font family (a:cs).  §21.1.2.3.1.
  font_family_complex_script : String?
  /// Symbol font family (a:sym).  §21.1.2.3.10.
  font_family_symbol : String?
  /// 400 = normal, 700 = bold.
  font_weight : Int
  /// `"normal"` or `"italic"`.
  font_style : String
  /// `"underline"` / `"line-through"` / etc.; `None` = no decoration.
  text_decoration : String?
  /// Colour hex (with leading `#`).
  color : String
  /// `"baseline"`, `"superscript"`, or `"subscript"`. Used as a
  /// coarse classifier for emitters that don't honour the exact
  /// percentage; `baseline_pct` carries the spec-mandated signed
  /// percentage (-100000..100000) when available.
  vertical_align : String
  /// §21.1.2.3.4 baseline — signed percentage of the em-height
  /// (positive lifts, negative drops, 0 = baseline). Zero when
  /// `<a:rPr baseline>` is absent.
  baseline_pct : Double
  /// Extra letter spacing in pixels.
  letter_spacing : Double
  /// True for `<a:br/>` line-break runs.
  is_break : Bool
  /// `"ltr"` or `"rtl"`.
  direction : String
  /// Optional highlight (background) colour hex (with leading `#`).
  highlight_color : String?
  /// `"uppercase"`, `"lowercase"`, or `None`.
  text_transform : String?
  /// Hyperlink relationship id.
  link_id : String?
  link_tooltip : String?
  mouse_over_link_id : String?
  mouse_over_link_tooltip : String?
  bookmark : String?
  text_outline : TextOutlineConfig?
  text_fill : TextFillConfig?
  /// Kerning threshold in points (§21.1.2.3.9 `kern`).
  kerning : Double?
  /// Custom underline colour (§21.1.2.3.33 `a:uLn`).
  underline_color : String?
  /// §21.1.2.3.32 u — the raw underline-style value (`sng`, `dbl`,
  /// `wavy`, `dotted`, `dash`, `heavy`, …) preserved so the
  /// renderer can paint multi-line / wavy decorations the SVG
  /// `text-decoration-style` CSS property can't express through
  /// librsvg.  `None` matches `<a:rPr u="none">` or an absent
  /// attribute; `text_decoration` (above) carries the CSS-level
  /// flag this raw value translates to.
  underline_style : String?
}

///|
/// Span with measured width attached.
pub struct MeasuredSpan {
  /// All fields are duplicated from `LayoutSpan` so callers don't
  /// need a wrapping reference.
  span : LayoutSpan
  width : Double
}

///|
/// Bullet configuration computed by the adapter (`a:buChar`,
/// `a:buAutoNum`, or `a:buBlip`).  §21.1.2.4.
pub struct BulletConfig {
  /// Rendered bullet character (or generated auto-number string).
  char : String
  /// Font size in points.
  font_size : Double
  /// Colour hex (with leading `#`).
  color : String
  font_family : String
  /// When set, render an `<image href="...">` instead of text
  /// (§21.1.2.4.2 a:buBlip).
  image_url : String?
}

///|
/// Paragraph input for the layout engine.  Mirrors
/// `LayoutParagraphInput` in `text-layout/types.ts:321`.
pub struct LayoutParagraphInput {
  spans : Array[LayoutSpan]
  alignment : TextAlign
  /// Left margin in pixels.
  margin_left : Double
  /// First-line indent in pixels (can be negative for hanging indents).
  indent : Double
  margin_right : Double
  /// Space before this paragraph in points.
  space_before : Double
  /// Space after this paragraph in points.
  space_after : Double
  line_spacing : LineSpacing?
  bullet : BulletConfig?
  font_alignment : FontAlignment
  default_tab_size : Double
  tab_stops : Array[LayoutTabStop]
  ea_line_break : Bool
  latin_line_break : Bool
  hanging_punctuation : Bool
  /// Empty-paragraph font size from `a:endParaRPr` (used for height
  /// when no text runs are present).  §21.1.2.2.3.
  end_para_font_size : Double?
}

///|
/// Span positioned within a line — the only extra field over
/// `MeasuredSpan` is `dx` (kerning adjustment from previous span).
pub struct PositionedSpan {
  span : LayoutSpan
  width : Double
  dx : Double
}

///|
/// One laid-out line.
pub struct LayoutLine {
  spans : Array[PositionedSpan]
  x : Double
  y : Double
  width : Double
  height : Double
  /// §21.1.2.2.1 ST_TextAlignType `just` — extra CSS-pixel advance
  /// added at every U+0020 space in this line so the right edge
  /// reaches the available text-frame width. Zero for non-justified
  /// lines and for the trailing line of a justified paragraph (PML
  /// `just`, like WML `both`, exempts the last line). The renderer
  /// emits this as both a `word-spacing` attribute on each `<text>`
  /// element (so painted glyphs land on the justified positions) and
  /// an additive cursor advance between spans (so subsequent spans
  /// start where the stretched glyphs end).
  word_spacing_extra : Double
}

///|
/// One laid-out paragraph.
pub struct LayoutParagraphResult {
  lines : Array[LayoutLine]
  alignment : TextAlign
  bullet : BulletConfig?
  bullet_width : Double
  /// §21.1.2.4.4-8 — x-coordinate of the bullet's left edge (CSS
  /// pixels).  The bullet glyph is painted left-aligned at this
  /// position so its right edge falls inside the hanging-indent
  /// slot (`bullet_x + bullet_width ≤ margin_left`).  This keeps a
  /// natural gap between bullet and text when the slot is wider
  /// than the glyph, matching PowerPoint.  Zero when
  /// the paragraph has no bullet.
  bullet_x : Double
  font_alignment : FontAlignment
}

///|
/// Final output of `layout_text_body`.  Mirrors `LayoutResult` in
/// `text-layout/types.ts:448`.
pub struct LayoutResult {
  paragraphs : Array[LayoutParagraphResult]
  /// Total content height including insets.
  total_height : Double
  /// Y-offset applied by the anchor calculation.
  y_offset : Double
}

///|
/// Full input to `layout_text_body`.  Mirrors `LayoutInput` in
/// `text-layout/types.ts:464`.
pub struct LayoutInput {
  text_box : TextBoxConfig
  paragraphs : Array[LayoutParagraphInput]
}
