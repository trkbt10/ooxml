// @source web-pptx packages/@aurochs-renderer/pptx/src/text-layout/line-breaker.ts
//
// Line breaking / word wrap.  Breaks a sequence of `MeasuredSpan` into
// lines that fit within the given pixel widths.  Handles explicit
// line breaks, CJK word-wrap, and ASCII break characters (space, tab,
// hyphen).

///|
/// Default font size used when a paragraph has no measurable runs.
/// Mirrors `DEFAULT_FONT_SIZE_PT` in
/// `text-layout/line-breaker.ts:11`.
pub let default_font_size_pt : Double = 18.0

///|
/// Result of breaking spans into lines.  Mirrors `LineBreakResult` in
/// `text-layout/line-breaker.ts:20`.
pub struct LineBreakResult {
  lines : Array[Array[MeasuredSpan]]
  line_heights : Array[Double]
}

///|
/// True for ASCII word-break opportunities (space, tab, hyphen).
fn is_break_char(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '-'
}

///|
/// Re-measure a single span after splitting its text.  Mirrors
/// `createOverflowSpan` / inline `estimateTextWidth` calls in
/// `text-layout/line-breaker.ts:45`.
fn make_span(parent : MeasuredSpan, text : String) -> MeasuredSpan {
  let width = @glyph.estimate_text_width_fallback(
    text,
    font_size_pt=parent.span.font_size,
    letter_spacing_px=parent.span.letter_spacing,
    font_family=Some(parent.span.font_family),
    font_weight=parent.span.font_weight,
  )
  let new_span : LayoutSpan = {
    text,
    font_size: parent.span.font_size,
    font_family: parent.span.font_family,
    font_family_east_asian: parent.span.font_family_east_asian,
    font_family_complex_script: parent.span.font_family_complex_script,
    font_family_symbol: parent.span.font_family_symbol,
    font_weight: parent.span.font_weight,
    font_style: parent.span.font_style,
    text_decoration: parent.span.text_decoration,
    color: parent.span.color,
    vertical_align: parent.span.vertical_align,
    baseline_pct: parent.span.baseline_pct,
    letter_spacing: parent.span.letter_spacing,
    is_break: parent.span.is_break,
    direction: parent.span.direction,
    highlight_color: parent.span.highlight_color,
    text_transform: parent.span.text_transform,
    link_id: parent.span.link_id,
    link_tooltip: parent.span.link_tooltip,
    mouse_over_link_id: parent.span.mouse_over_link_id,
    mouse_over_link_tooltip: parent.span.mouse_over_link_tooltip,
    bookmark: parent.span.bookmark,
    text_outline: parent.span.text_outline,
    text_fill: parent.span.text_fill,
    kerning: parent.span.kerning,
    underline_color: parent.span.underline_color,
    underline_style: parent.span.underline_style,
  }
  { span: new_span, width }
}

///|
/// Single-character width estimate used while searching for break
/// points inside an oversized span.
fn char_width_estimate(parent : MeasuredSpan, c : Char) -> Double {
  let buf = StringBuilder::new()
  buf.write_char(c)
  @glyph.estimate_text_width_fallback(
    buf.to_string(),
    font_size_pt=parent.span.font_size,
    letter_spacing_px=0.0,
    font_family=Some(parent.span.font_family),
    font_weight=parent.span.font_weight,
  )
}

///|
/// Break `span` at the best position that keeps the line within
/// `(max_width - current_line_width)`.  Returns `(fits, overflow)`:
///   - `fits` is the portion that fits (possibly the whole span).
///   - `overflow` is the leftover text as a fresh `MeasuredSpan` or
///     `None` when everything fit.
///
/// Mirrors `breakSpanAtWidth` in `line-breaker.ts:64`.
fn break_span_at_width(
  span : MeasuredSpan,
  max_width : Double,
  current_line_width : Double,
) -> (MeasuredSpan?, MeasuredSpan?) {
  let available = max_width - current_line_width
  if span.width <= available {
    return (Some(span), None)
  }
  let text = span.span.text
  let chars : Array[Char] = []
  for c in text {
    chars.push(c)
  }
  let n = chars.length()
  let mut break_index : Int = -1
  let mut accumulated : Double = 0.0
  let mut i = 0
  while i < n {
    let c = chars[i]
    let cw = char_width_estimate(span, c) +
      (if i > 0 { span.span.letter_spacing } else { 0.0 })
    if accumulated + cw > available && break_index >= 0 {
      break
    }
    accumulated = accumulated + cw
    // Find break opportunities (ASCII space/tab/hyphen, CJK boundaries).
    if is_break_char(c) {
      break_index = i + 1
    } else if @glyph.is_cjk_char(c) {
      break_index = i + 1
    } else if i > 0 && @glyph.is_cjk_char(chars[i - 1]) {
      break_index = i
    }
    i = i + 1
  }
  if break_index <= 0 {
    if current_line_width == 0.0 {
      // Force-break: find the first char beyond the available width.
      accumulated = 0.0
      let mut j = 0
      while j < n {
        let c = chars[j]
        let cw = char_width_estimate(span, c) +
          (if j > 0 { span.span.letter_spacing } else { 0.0 })
        if accumulated + cw > available && j > 0 {
          break_index = j
          break
        }
        accumulated = accumulated + cw
        j = j + 1
      }
      if break_index <= 0 {
        break_index = if 1 > n { 1 } else { n }
      }
    } else {
      // Can't fit anything; defer this whole span to the next line.
      return (None, Some(span))
    }
  }
  let fits_text = StringBuilder::new()
  let overflow_text = StringBuilder::new()
  for j in 0..<n {
    if j < break_index {
      fits_text.write_char(chars[j])
    } else {
      overflow_text.write_char(chars[j])
    }
  }
  let fits = make_span(span, fits_text.to_string())
  let overflow_str = overflow_text.to_string()
  let overflow = if overflow_str.length() == 0 {
    None
  } else {
    Some(make_span(span, overflow_str))
  }
  (Some(fits), overflow)
}

///|
/// Mutable layout-line accumulator.  Kept as a struct so the helper
/// closures below can share state without allocating per-call.
struct LineBuilder {
  mut current : Array[MeasuredSpan]
  mut current_width : Double
  mut current_height : Double
  mut current_max : Double
}

///|
/// Break a paragraph's spans into lines with word wrap.  Mirrors
/// `breakIntoLines` in `line-breaker.ts:167`.
pub fn break_into_lines(
  spans : Array[MeasuredSpan],
  first_line_width : Double,
  next_line_width : Double,
  wrap_mode : TextWrapping,
) -> LineBreakResult {
  let lines : Array[Array[MeasuredSpan]] = []
  let line_heights : Array[Double] = []
  if spans.length() == 0 {
    lines.push([])
    line_heights.push(0.0)
    return { lines, line_heights }
  }
  let state : LineBuilder = {
    current: [],
    current_width: 0.0,
    current_height: 0.0,
    current_max: first_line_width,
  }
  fn push_line(height : Double) -> Unit {
    lines.push(state.current)
    line_heights.push(height)
    state.current = []
    state.current_width = 0.0
    state.current_height = 0.0
    state.current_max = next_line_width
  }

  for item in spans {
    if item.span.is_break {
      push_line(state.current_height)
      continue
    }
    if wrap_mode is WrapNone {
      state.current.push(item)
      state.current_width = state.current_width + item.width
      if item.span.font_size > state.current_height {
        state.current_height = item.span.font_size
      }
      continue
    }
    let pending : Array[MeasuredSpan] = [item]
    while pending.length() > 0 {
      let cur = pending[0]
      pending.remove(0) |> ignore
      let (fits, overflow) = break_span_at_width(
        cur,
        state.current_max,
        state.current_width,
      )
      match fits {
        Some(f) => {
          state.current.push(f)
          state.current_width = state.current_width + f.width
          if f.span.font_size > state.current_height {
            state.current_height = f.span.font_size
          }
        }
        None => ()
      }
      match overflow {
        Some(o) => {
          let height = if state.current_height != 0.0 {
            state.current_height
          } else {
            o.span.font_size
          }
          push_line(height)
          pending.insert(0, o)
        }
        None => ()
      }
    }
  }
  if state.current.length() > 0 || lines.length() == 0 {
    lines.push(state.current)
    let fallback = if spans.length() > 0 {
      spans[0].span.font_size
    } else {
      default_font_size_pt
    }
    let h = if state.current_height != 0.0 {
      state.current_height
    } else {
      fallback
    }
    line_heights.push(h)
  }
  { lines, line_heights }
}

///|
/// Sum of widths of all spans on a single line.  Mirrors `getLineWidth`
/// in `line-breaker.ts:266`.
pub fn get_line_width(spans : Array[MeasuredSpan]) -> Double {
  let mut total = 0.0
  for s in spans {
    total = total + s.width
  }
  total
}

///|
/// §21.1.2.2.1 ST_TextAlignType `just` — count the U+0020 word-break
/// opportunities on a laid-out line, excluding the trailing wrap-space
/// that `get_line_visible_width` strips for alignment width.
///
/// Used by `layout_paragraph` to spread the slack between the line's
/// visible glyph width and the available text-frame width across the
/// stretchable spaces. We exclude the trailing space on the LAST span
/// because that space is the break-causing whitespace the line breaker
/// keeps on the closing line — stretching it would push the visible
/// glyphs past the right margin instead of holding them at it (the
/// same reason `get_line_visible_width` trims it before computing the
/// alignment X). Internal break-runs (`is_break`) are skipped: their
/// text is the line break sentinel, not a stretchable space.
pub fn count_line_spaces(spans : Array[MeasuredSpan]) -> Int {
  let n = spans.length()
  if n == 0 {
    return 0
  }
  let mut total = 0
  for i in 0..<n {
    let s = spans[i]
    if s.span.is_break {
      continue
    }
    if i == n - 1 {
      // Last span: strip trailing whitespace so the break-causing
      // space (kept on the closing line by the wrapper) is not
      // counted as a stretch point.
      let chars : Array[Char] = []
      for c in s.span.text {
        chars.push(c)
      }
      let mut end = chars.length()
      while end > 0 && is_trailing_ws(chars[end - 1]) {
        end = end - 1
      }
      for j in 0..<end {
        if chars[j] == ' ' {
          total = total + 1
        }
      }
    } else {
      for c in s.span.text {
        if c == ' ' {
          total = total + 1
        }
      }
    }
  }
  total
}

///|
/// Visible width of a laid-out line — the total span advance minus
/// the advance of any trailing whitespace characters on the LAST span.
///
/// Centring / right-alignment / justified `available_width - line_width`
/// calculations must use this value, NOT `get_line_width`.  Reason:
/// after `break_into_lines` runs, a wrapped line frequently ends with
/// the literal space that triggered the break (the wrapper kept the
/// break-char on the closing line rather than pushing it to the next
/// line; the spec is silent on which side the space goes to, and both
/// LO and PowerPoint keep it on the breaking line).  That trailing
/// space contributes ≈1 advance unit to the raw line width but draws
/// no ink, so the visible glyph extent ends one space-width to the
/// LEFT of the advance end.  LibreOffice excludes the trailing space
/// before centring; if we use the full advance width we leave too
/// little room on the LEFT and the line drifts ≈half-a-space right
/// (≈3–4 px at 26 pt Liberation Sans on the pml-shape-text-wrap
/// fixture — enough to push the RMSE 5–10% past target).
///
/// Mirrors the implicit behaviour in PowerPoint / LibreOffice; the
/// upstream web-pptx port lacks the helper because Canvas
/// `measureText` measures glyph extents directly and skips trailing
/// whitespace automatically — our advance-based estimator has to do
/// the exclusion by hand.
pub fn get_line_visible_width(spans : Array[MeasuredSpan]) -> Double {
  let n = spans.length()
  if n == 0 {
    return 0.0
  }
  // Sum every span's full advance EXCEPT the last span, which we
  // strip of trailing whitespace.
  let mut total = 0.0
  for i in 0..<(n - 1) {
    total = total + spans[i].width
  }
  let last = spans[n - 1]
  // Locate the last non-whitespace char and trim everything after it
  // from the last span's text, then re-measure the visible portion.
  let chars : Array[Char] = []
  for c in last.span.text {
    chars.push(c)
  }
  let mut end = chars.length()
  while end > 0 && is_trailing_ws(chars[end - 1]) {
    end = end - 1
  }
  if end == chars.length() {
    // No trailing whitespace — last span is already its visible width.
    total + last.width
  } else if end == 0 {
    // The entire last span is whitespace — visible width excludes it
    // entirely. (Pure-whitespace lines centre as zero-width which is
    // what LibreOffice does.)
    total
  } else {
    let buf = StringBuilder::new()
    for i in 0..<end {
      buf.write_char(chars[i])
    }
    let trimmed = buf.to_string()
    let w = @glyph.estimate_text_width_fallback(
      trimmed,
      font_size_pt=last.span.font_size,
      letter_spacing_px=last.span.letter_spacing,
      font_family=Some(last.span.font_family),
      font_weight=last.span.font_weight,
    )
    total + w
  }
}

///|
/// True for ASCII whitespace characters that LO / PowerPoint discount
/// at end-of-line for alignment purposes: space and tab.  Hard line
/// breaks `\n` never appear in a layout span (the line-breaker turns
/// `<a:br/>` into a `is_break` marker, not a literal char).
fn is_trailing_ws(c : Char) -> Bool {
  c == ' ' || c == '\t'
}

///|
/// Max font size found within a single line (used for baseline calc).
/// Mirrors `getLineMaxFontSize` in `line-breaker.ts:274`.
pub fn get_line_max_font_size(spans : Array[MeasuredSpan]) -> Double {
  if spans.length() == 0 {
    return default_font_size_pt
  }
  let mut m = spans[0].span.font_size
  for s in spans {
    if s.span.font_size > m {
      m = s.span.font_size
    }
  }
  m
}

///|
/// Font info (size + family) of the largest span on the line —
/// needed for ascender-aware baseline placement.  Mirrors
/// `getLineMaxFontInfo` in `line-breaker.ts:294`.
pub struct LineFontInfo {
  font_size : Double
  font_family : String
}

///|
pub fn get_line_max_font_info(spans : Array[MeasuredSpan]) -> LineFontInfo {
  if spans.length() == 0 {
    return { font_size: default_font_size_pt, font_family: "sans-serif" }
  }
  let mut best = spans[0]
  for s in spans {
    if s.span.font_size > best.span.font_size {
      best = s
    }
  }
  { font_size: best.span.font_size, font_family: best.span.font_family }
}
