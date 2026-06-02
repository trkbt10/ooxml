// @source web-pptx packages/@aurochs-renderer/pptx/src/text-layout/engine.ts
//
// Main text-layout orchestrator.  Walks the `LayoutInput` paragraph
// by paragraph, measures + line-breaks each span, computes baseline
// Y, applies anchor offsets, and returns a `LayoutResult` ready for
// SVG rendering.
//
// ECMA-376 references:
//   §21.1.2.1.2   bodyPr (anchor, anchorCtr, autoFit, spcFirstLastPara)
//   §21.1.2.2.5   a:lnSpc
//   §21.1.2.2.7   marL / marR / indent
//   §21.1.2.1.12  fontAlgn

///|
/// Available content width inside the text box.  Mirrors
/// `getContentWidth` in `engine.ts:37`.
fn content_width(tb : TextBoxConfig) -> Double {
  let w = tb.width - tb.inset_left - tb.inset_right
  if w < 0.0 {
    0.0
  } else {
    w
  }
}

///|
/// Available content height inside the text box.  Mirrors
/// `getContentHeight` in `engine.ts:45`.
fn content_height(tb : TextBoxConfig) -> Double {
  let h = tb.height - tb.inset_top - tb.inset_bottom
  if h < 0.0 {
    0.0
  } else {
    h
  }
}

///|
/// Bullet width helper. Returns 0 when there is no bullet, or when the
/// bullet font cannot be resolved (renderer falls back to the implicit
/// PowerPoint metric rather than aborting the slide layout).
fn bullet_width_of(bullet : BulletConfig?) -> Double {
  match bullet {
    None => 0.0
    Some(b) =>
      try estimate_bullet_width(b.char, b.font_size, b.font_family) catch {
        _ => 0.0
      } noraise {
        w => w
      }
  }
}

///|
/// Build a `MeasuredSpan` array whose widths are all zero. Used as a
/// safety-net fallback when the configured `FontResolver` cannot
/// resolve any of the spans in a paragraph (e.g. test harness without
/// injected fixture faces).
fn zero_width_spans(spans : Array[LayoutSpan]) -> Array[MeasuredSpan] {
  let out : Array[MeasuredSpan] = []
  for s in spans {
    out.push({ span: s, width: 0.0 })
  }
  out
}

///|
/// Pick the effective font size for one line.  Mirrors
/// `getLineFontSize` in `engine.ts:64`.
fn line_font_size(
  line_height_pt : Double,
  end_para_font_size : Double?,
) -> Double {
  if line_height_pt > 0.0 {
    return line_height_pt
  }
  match end_para_font_size {
    Some(v) => v
    None => default_font_size_pt
  }
}

///|
/// Scale a bullet to a new font size percentage.  Mirrors
/// `scaleBullet` in `engine.ts:74`.
fn scale_bullet(bullet : BulletConfig?, percent : Double) -> BulletConfig? {
  match bullet {
    None => None
    Some(b) =>
      Some({
        char: b.char,
        font_size: b.font_size * percent / 100.0,
        color: b.color,
        font_family: b.font_family,
        image_url: b.image_url,
      })
  }
}

///|

///|
/// The ratio of a paragraph's SINGLE-spaced line height to its point
/// size, used by §21.1.2.2.5 `<a:lnSpc>` when the cascade resolves
/// to "single" (absent element, or `<a:spcPct val="100000">`).
///
/// PowerPoint's documented behaviour for "Single" line spacing is
/// `1.20 × fontSize`, not the font's hhea ascender+descender+lineGap
/// sum. This is the same "loose" line height the CSS
/// `line-height: normal` recommendation hits for sans-serif body
/// faces, and it matches PowerPoint's own "Line Spacing → Single"
/// menu item across all default body sizes.
///
/// WML carries its own `DEFAULT_LINE_HEIGHT_RATIO` (≈1.22). Both
/// reflect that production OOXML renderers compose body text at
/// ≈1.2× the bare point size regardless of the font's OS/2 design
/// line-height; § 17.3.1.33 `<w:spacing>` "Single" is
/// implementation-defined and converges near 1.2 for Latin body
/// faces.
const LINE_HEIGHT_RATIO : Double = 1.2

///|
/// The descent of an OOXML body font as a fraction of its point size
/// — the distance from the text baseline down to the bottom of the
/// line box. Used to place the baseline within the line box
/// (`baseline = box_bottom − descent`).
///
/// Empirical mid-range value for Latin sans-serif body faces
/// (`sTypoDescender / unitsPerEm ≈ 0.21`). The exact value differs
/// per face — this is the layout fallback when the engine has not
/// yet queried the resolved font's hhea descender directly.
const LINE_DESCENT_RATIO : Double = 0.2119

///|
/// Calculate the line height (in pixels) from `line_spacing`.
///
/// `LineSpacingPercent` is a multiplier of SINGLE spacing — and
/// single spacing is the font's natural line height
/// (`font_size × LINE_HEIGHT_RATIO`), not the bare point size — so a
/// `None` / 100% line is `font_size_px × LINE_HEIGHT_RATIO`.
/// `LineSpacingPoints` is an absolute height and is used as given.
fn calc_line_height(
  base_font_size_pt : Double,
  spacing : LineSpacing?,
) -> Double {
  let font_size_px = base_font_size_pt * @glyph.pt_to_px
  let single = font_size_px * LINE_HEIGHT_RATIO
  match spacing {
    None => single
    Some(LineSpacingPercent(pct)) => single * (pct / 100.0)
    Some(LineSpacingPoints(pts)) => pts * @glyph.pt_to_px
  }
}

///|
/// Convert a list of measured spans to positioned spans (no kerning
/// adjustments — those are applied later during SVG rendering).
fn position_spans(spans : Array[MeasuredSpan]) -> Array[PositionedSpan] {
  let result : Array[PositionedSpan] = []
  for s in spans {
    result.push({ span: s.span, width: s.width, dx: 0.0 })
  }
  result
}

///|
/// X-position of one line given alignment + margins.  Mirrors
/// `calculateLineX` in `engine.ts:268`.
///
/// PowerPoint hanging-indent semantics (§21.1.2.2.7 marL / indent /
/// bullets):
///   • The bullet glyph itself sits at `margin_left + indent`.
///   • The TEXT origin sits one bullet-width past the bullet —
///     `margin_left + indent + bullet_width` — UNLESS the bullet
///     fits entirely within the hanging slot (`bullet_width <
///     -indent`), in which case the text snaps to `margin_left` so
///     it aligns with the wrapped lines that follow.
///
/// Without the snap, a `marL=N, indent=-N` paragraph with a small
/// bullet (e.g. "•" measured ~9 px against a 48 px slot) would put
/// the first line of text at x≈9 — leaving a ragged left edge where
/// wrapped lines start cleanly at x=48 and only the bullet's own
/// line sticks out. The snap matches PowerPoint's documented
/// hanging-indent behaviour.
fn calc_line_x(
  alignment : TextAlign,
  margin_left : Double,
  line_width : Double,
  available_width : Double,
  indent : Double,
  bullet_width : Double,
) -> Double {
  let bullet_end = margin_left + indent + bullet_width
  let base_x = if indent < 0.0 && bullet_end < margin_left {
    margin_left
  } else {
    bullet_end
  }
  match alignment {
    AlignCenter => base_x + (available_width - line_width) / 2.0
    AlignRight => base_x + available_width - line_width
    AlignJustify | AlignJustifyLow | AlignDistributed | AlignThaiDistributed =>
      base_x
    AlignLeft => base_x
    // §21.1.2.2.9 — `AlignDecimal` is a tab-stop-only alignment and
    // cannot occur on a paragraph's `<a:pPr @algn>` (the schema
    // enumerates `l/ctr/r/just/justLow/dist/thaiDist` only). When
    // it leaks here via a typed wrapper we treat it as left.
    AlignDecimal => base_x
  }
}

///|
/// Layout one paragraph and return `(result, end_y)`. Mirrors
/// `layoutParagraph` in `engine.ts:142`. Span widths are measured via
/// `@glyph.measure_text_width`, which walks the
/// `default_font_set()` `FontResolver`. A `FontUnresolvedError`
/// surfaces as a 0-width span — `safety net` for the case where the
/// ECMA-376 §17.8.3 chain produced a stack the host could not
/// satisfy. The layout still proceeds so the rest of the slide
/// renders.
fn layout_paragraph(
  para : LayoutParagraphInput,
  cw : Double,
  start_y : Double,
  wrap_mode : TextWrapping,
) -> (LayoutParagraphResult, Double) {
  let ml = para.margin_left
  let mr = para.margin_right
  let ind = para.indent
  let measured = try measure_spans(para.spans) catch {
    _ => zero_width_spans(para.spans)
  } noraise {
    m => m
  }
  let bw = bullet_width_of(para.bullet)
  // Hanging-indent snap: when the bullet area fits entirely inside
  // the negative-indent slot (`bw < -ind`) the first-line text origin
  // collapses to `margin_left` (see `calc_line_x` doc-comment).  The
  // first line then has the SAME effective width as the wrapped
  // lines below.  Without this branch the wrap budget for the first
  // line of a bulleted paragraph is `cw - ml - mr - ind - bw`, which
  // with `ind = -bw` collapses to `cw - ml - mr` correctly anyway —
  // but with `bw < -ind` (the typical case: a 9 px bullet inside a
  // 48 px slot) the budget would inflate by `-ind - bw` and the
  // wrap point would drift right.
  let first_line_width = if ind < 0.0 && ml + ind + bw < ml {
    cw - ml - mr
  } else {
    cw - ml - mr - ind - bw
  }
  let next_line_width = cw - ml - mr
  let { lines: span_lines, line_heights } = break_into_lines(
    measured,
    if first_line_width < 0.0 {
      0.0
    } else {
      first_line_width
    },
    if next_line_width < 0.0 {
      0.0
    } else {
      next_line_width
    },
    wrap_mode,
  )
  let mut current_y = start_y + para.space_before * @glyph.pt_to_px
  let lines : Array[LayoutLine] = []
  for idx in 0..<span_lines.length() {
    let line_spans = span_lines[idx]
    let lh_pt = line_font_size(line_heights[idx], para.end_para_font_size)
    let lh_px = calc_line_height(lh_pt, para.line_spacing)
    let fs_px = lh_pt * @glyph.pt_to_px
    // Baseline placement within the line box. The line box is
    // `lh_px` tall; the baseline sits one DESCENT up from the box
    // bottom — `LINE_DESCENT_RATIO` is the mid-range descent for
    // Latin sans-serif body faces. (An earlier `half_leading +
    // fs*cap_height` model placed the baseline ≈one descent too high
    // and drifted upward against PowerPoint's reference.) This
    // formula puts the baseline `lh_px - LINE_DESCENT_RATIO*fs_px`
    // from the box top, matching PowerPoint for single-spaced lines.
    let descent = fs_px * LINE_DESCENT_RATIO
    let baseline_in_box = if lh_px - descent > 0.0 {
      lh_px - descent
    } else {
      lh_px
    }
    let baseline = current_y + baseline_in_box
    let lw = get_line_width(line_spans)
    // Alignment width excludes trailing whitespace from the last
    // span: a wrapped line keeps its break-causing space on the
    // CLOSING line (PowerPoint does not count that invisible glyph
    // when centring). Using the full advance width here would drift
    // centred/right-aligned lines by ~half-a-space to the right.
    let lw_aligned = get_line_visible_width(line_spans)
    let aw = if idx == 0 { first_line_width } else { next_line_width }
    let line_indent = if idx == 0 { ind } else { 0.0 }
    let line_bw = if idx == 0 { bw } else { 0.0 }
    let x = calc_line_x(
      para.alignment,
      ml,
      lw_aligned,
      if aw < 0.0 {
        0.0
      } else {
        aw
      },
      line_indent,
      line_bw,
    )
    let positioned = position_spans(line_spans)
    // §21.1.2.2.1 ST_TextAlignType `just` — when the paragraph
    // alignment is `justify`, distribute the slack between the
    // line's natural width and the available text-frame width
    // across the U+0020 spaces in the line. The trailing line of a
    // justified paragraph keeps its natural width (the spec exempts
    // the last line); same for any line that has no spaces (a
    // single long word). Negative slack is treated as zero — that
    // means the glyphs already exceeded the budget and stretching
    // would not match Word / PowerPoint behaviour. We use the same
    // `lw_aligned` width that `calc_line_x` uses so the trailing
    // wrap-space (already excluded from alignment width) is also
    // excluded from the slack we distribute — otherwise we would
    // stretch by a few px more than the right margin allows.
    let aw_clamped = if aw < 0.0 { 0.0 } else { aw }
    let is_last_line = idx == span_lines.length() - 1
    let word_spacing_extra = match para.alignment {
      AlignJustify
      | AlignJustifyLow
      | AlignDistributed
      | AlignThaiDistributed =>
        if is_last_line || aw_clamped <= lw_aligned {
          0.0
        } else {
          let n = count_line_spaces(line_spans)
          if n > 0 {
            (aw_clamped - lw_aligned) / n.to_double()
          } else {
            0.0
          }
        }
      _ => 0.0
    }
    // `width: lw` keeps the public `LayoutLine.width` aligned with
    // the existing semantics (full advance, used by downstream
    // measurements such as highlight-rect sizing); only the X
    // origin uses the trimmed value.
    lines.push({
      spans: positioned,
      x,
      y: baseline,
      width: lw,
      height: lh_px,
      word_spacing_extra,
    })
    current_y = current_y + lh_px
  }
  current_y = current_y + para.space_after * @glyph.pt_to_px
  // Bullet x: left-aligned at the start of the hanging-indent slot
  // (`margin_left + indent`).  For a regular non-hanging bullet the
  // slot start equals `margin_left + indent` which sits to the
  // immediate left of the text origin; for a hanging-indent bullet
  // (`indent < 0`) it sits one slot-width left of `margin_left`,
  // giving a natural gap between the bullet glyph and the text.
  let bullet_x = ml + ind
  (
    {
      lines,
      alignment: para.alignment,
      bullet: para.bullet,
      bullet_width: bw,
      bullet_x,
      font_alignment: para.font_alignment,
    },
    current_y,
  )
}

///|
/// Anchor Y offset.  Mirrors `getAnchorYOffset` in `engine.ts:330`.
fn anchor_y_offset(
  anchor : TextAnchor,
  inset_top : Double,
  content_h : Double,
  total_h : Double,
) -> Double {
  match anchor {
    AnchorCenter => inset_top + (content_h - total_h) / 2.0
    AnchorBottom => inset_top + content_h - total_h
    AnchorTop | AnchorJustified | AnchorDistributed => inset_top
  }
}

///|
/// `calculateYOffset` from `engine.ts:321`.
fn calc_y_offset(total_h : Double, tb : TextBoxConfig) -> Double {
  let ch = content_height(tb)
  let raw = anchor_y_offset(tb.anchor, tb.inset_top, ch, total_h)
  if raw < tb.inset_top {
    tb.inset_top
  } else {
    raw
  }
}

///|
/// `calculateXCenterOffset` from `engine.ts:357`.
fn calc_x_center_offset(
  paragraphs : Array[LayoutParagraphResult],
  content_w : Double,
) -> Double {
  let mut max_line_width = 0.0
  for p in paragraphs {
    for l in p.lines {
      if l.width > max_line_width {
        max_line_width = l.width
      }
    }
  }
  let off = (content_w - max_line_width) / 2.0
  if off < 0.0 {
    0.0
  } else {
    off
  }
}

///|
/// Apply anchor offsets (vertical + optional horizontal centring).
/// Mirrors `applyAnchorOffsets` in `engine.ts:375`.
fn apply_anchor_offsets(
  paragraphs : Array[LayoutParagraphResult],
  total_h : Double,
  tb : TextBoxConfig,
) -> (Array[LayoutParagraphResult], Double) {
  let y_offset = calc_y_offset(total_h, tb)
  let content_w = tb.width - tb.inset_left - tb.inset_right
  let x_center = if tb.anchor_center {
    calc_x_center_offset(paragraphs, content_w)
  } else {
    0.0
  }
  let result : Array[LayoutParagraphResult] = []
  for p in paragraphs {
    let new_lines : Array[LayoutLine] = []
    for l in p.lines {
      new_lines.push({
        spans: l.spans,
        x: l.x + tb.inset_left + x_center,
        y: l.y + y_offset,
        width: l.width,
        height: l.height,
        word_spacing_extra: l.word_spacing_extra,
      })
    }
    result.push({
      lines: new_lines,
      alignment: p.alignment,
      bullet: p.bullet,
      bullet_width: p.bullet_width,
      bullet_x: p.bullet_x + tb.inset_left + x_center,
      font_alignment: p.font_alignment,
    })
  }
  (result, y_offset)
}

///|
/// Scale one span's font size by `percent` (e.g. 80.0 = 80 %).
/// Mirrors `scaleSpanFontSize` in `engine.ts:410`.
fn scale_span_font_size(span : LayoutSpan, percent : Double) -> LayoutSpan {
  {
    text: span.text,
    font_size: span.font_size * percent / 100.0,
    font_family: span.font_family,
    font_family_east_asian: span.font_family_east_asian,
    font_family_complex_script: span.font_family_complex_script,
    font_family_symbol: span.font_family_symbol,
    font_weight: span.font_weight,
    font_style: span.font_style,
    text_decoration: span.text_decoration,
    color: span.color,
    vertical_align: span.vertical_align,
    baseline_pct: span.baseline_pct,
    letter_spacing: span.letter_spacing,
    is_break: span.is_break,
    direction: span.direction,
    highlight_color: span.highlight_color,
    text_transform: span.text_transform,
    link_id: span.link_id,
    link_tooltip: span.link_tooltip,
    mouse_over_link_id: span.mouse_over_link_id,
    mouse_over_link_tooltip: span.mouse_over_link_tooltip,
    bookmark: span.bookmark,
    text_outline: span.text_outline,
    text_fill: span.text_fill,
    kerning: span.kerning,
    underline_color: span.underline_color,
    underline_style: span.underline_style,
  }
}

///|
/// Apply autoFit (font scale + line space reduction) to all
/// paragraphs.  Mirrors `applyAutoFit` in `engine.ts:484`.
fn apply_auto_fit(
  paragraphs : Array[LayoutParagraphInput],
  auto_fit : AutoFitConfig,
) -> Array[LayoutParagraphInput] {
  // §21.1.2.1.1 / .2 / .3 — `AutoFitConfig` is closed-3:
  //   AutoFitNone       — `<a:noAutofit/>`
  //   AutoFitShape      — `<a:spAutoFit/>`
  //   AutoFitNormal(_)  — `<a:normAutofit fontScale lnSpcReduction>`
  // Only the Normal branch triggers font-scale / line-space
  // reduction; the other two leave the paragraphs intact.
  match auto_fit {
    AutoFitNormal(font_scale, ln_spc_reduction) => {
      let result : Array[LayoutParagraphInput] = []
      for para in paragraphs {
        let spans = if font_scale != 100.0 {
          let s : Array[LayoutSpan] = []
          for span in para.spans {
            s.push(scale_span_font_size(span, font_scale))
          }
          s
        } else {
          para.spans
        }
        let bullet = if font_scale != 100.0 {
          scale_bullet(para.bullet, font_scale)
        } else {
          para.bullet
        }
        let ls = if ln_spc_reduction > 0.0 {
          match para.line_spacing {
            None => Some(LineSpacingPercent(100.0 - ln_spc_reduction))
            Some(LineSpacingPercent(v)) =>
              Some(LineSpacingPercent(v * (100.0 - ln_spc_reduction) / 100.0))
            Some(LineSpacingPoints(v)) =>
              Some(LineSpacingPoints(v * (100.0 - ln_spc_reduction) / 100.0))
          }
        } else {
          para.line_spacing
        }
        result.push({
          spans,
          alignment: para.alignment,
          margin_left: para.margin_left,
          indent: para.indent,
          margin_right: para.margin_right,
          space_before: para.space_before,
          space_after: para.space_after,
          line_spacing: ls,
          bullet,
          font_alignment: para.font_alignment,
          default_tab_size: para.default_tab_size,
          tab_stops: para.tab_stops,
          ea_line_break: para.ea_line_break,
          latin_line_break: para.latin_line_break,
          hanging_punctuation: para.hanging_punctuation,
          end_para_font_size: para.end_para_font_size,
        })
      }
      result
    }
    // §21.1.2.1.1 / .3 — AutoFitNone / AutoFitShape: no font
    // scaling applied to the paragraphs; pass them through.
    AutoFitNone => {
      let result : Array[LayoutParagraphInput] = []
      for p in paragraphs {
        result.push(p)
      }
      result
    }
    AutoFitShape => {
      let result : Array[LayoutParagraphInput] = []
      for p in paragraphs {
        result.push(p)
      }
      result
    }
  }
}

///|
/// Main entry point — lay out a `LayoutInput` into a `LayoutResult`.
/// Mirrors `layoutTextBody` in `engine.ts:506`.
///
/// Every glyph-width measurement now flows through
/// `@glyph.measure_text_width`, which routes to the
/// `default_font_set()` `FontResolver`. Font-resolution failures
/// degrade individual span widths to zero rather than aborting the
/// layout — the caller still receives a `LayoutResult` it can paint.
pub fn layout_text_body(input : LayoutInput) -> LayoutResult {
  let tb = input.text_box
  let scaled = apply_auto_fit(input.paragraphs, tb.auto_fit)
  // Apply spcFirstLastPara: when false, suppress first paragraph's
  // `space_before` and last paragraph's `space_after`.  §21.1.2.1.2.
  let adjusted : Array[LayoutParagraphInput] = []
  let n = scaled.length()
  for i in 0..<n {
    let para = scaled[i]
    let is_first = i == 0
    let is_last = i == n - 1
    if !tb.spc_first_last_para {
      adjusted.push({
        spans: para.spans,
        alignment: para.alignment,
        margin_left: para.margin_left,
        indent: para.indent,
        margin_right: para.margin_right,
        space_before: if is_first {
          0.0
        } else {
          para.space_before
        },
        space_after: if is_last {
          0.0
        } else {
          para.space_after
        },
        line_spacing: para.line_spacing,
        bullet: para.bullet,
        font_alignment: para.font_alignment,
        default_tab_size: para.default_tab_size,
        tab_stops: para.tab_stops,
        ea_line_break: para.ea_line_break,
        latin_line_break: para.latin_line_break,
        hanging_punctuation: para.hanging_punctuation,
        end_para_font_size: para.end_para_font_size,
      })
    } else {
      adjusted.push(para)
    }
  }
  let cw = content_width(tb)
  let layouted : Array[LayoutParagraphResult] = []
  let mut current_y = 0.0
  for p in adjusted {
    let (result, end_y) = layout_paragraph(p, cw, current_y, tb.wrap_mode)
    layouted.push(result)
    current_y = end_y
  }
  let total_h = current_y
  let (final_paragraphs, y_offset) = apply_anchor_offsets(layouted, total_h, tb)
  {
    paragraphs: final_paragraphs,
    total_height: total_h + tb.inset_top + tb.inset_bottom,
    y_offset,
  }
}
