// §18.8.31 — the `*x` number-format fill directive tiles the glyph `x`
// across the cell's residual width, splitting the value into a
// left-aligned and a right-aligned run (Excel's accounting / leader
// layout).  The pure format-string layer marks the fill with a sentinel;
// the cell renderer expands it against the real cell width.

///|
fn fill_layout() -> CellLayout {
  {
    x: 0.0,
    y: 0.0,
    width: 120.0,
    height: 18.0,
    colspan: 1,
    rowspan: 1,
    is_merge_origin: false,
    is_hidden_by_merge: false,
  }
}

///|
test "apply_format_section marks a *x fill with the sentinel" {
  // `*-0` → fill with '-', then the integer.  The string carries the
  // U+E000 sentinel + the fill glyph, recovered by split_fill_directive.
  let out = apply_format_section(5.0, "*-0")
  guard split_fill_directive(out) is Some((left, fill, right)) else {
    fail("expected a fill directive in the formatted output")
  }
  assert_eq(left, "")
  assert_eq(fill, "-")
  assert_eq(right, "5")
}

///|
test "split_fill_directive returns None for an ordinary string" {
  assert_true(split_fill_directive("1,234.50") is None)
}

///|
test "render_cell_text expands *x fill into left+right anchored runs" {
  let style = default_cell_style(default_render_options())
  // Formatted text with a leader-dot fill: left "$", tiled '.', right "5".
  let text = apply_format_section(5.0, "\"$\"*.0")
  let nodes = render_cell_text("s", "A1", fill_layout(), text, style)
  let sb = StringBuilder::new()
  for n in nodes {
    match n {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  let svg = sb.to_string()
  // Two text runs: one left-anchored (left + fill), one right-anchored.
  assert_true(svg.contains("text-anchor=\"start\""))
  assert_true(svg.contains("text-anchor=\"end\""))
  // The fill glyph is tiled (more than one '.') and the sentinel never
  // leaks into the output.
  assert_true(svg.contains(".."))
  assert_true(!svg.contains("\u{E000}"))
}

///|
test "§18.18.40 fill alignment tiles the whole cell text" {
  let base = default_cell_style(default_render_options())
  let style = { ..base, alignment: { ..base.alignment, horizontal: "fill" } }
  // A 120 px cell with the short text "ab" must repeat it several times.
  let nodes = render_cell_text("s", "A1", fill_layout(), "ab", style)
  let sb = StringBuilder::new()
  for n in nodes {
    match n {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  let svg = sb.to_string()
  // The text is tiled to fill the cell (well beyond a single "ab").
  assert_true(svg.contains("abab"))
}

///|
test "wrapped cell strips the fill sentinel rather than leaking it" {
  let base = default_cell_style(default_render_options())
  let style = { ..base, alignment: { ..base.alignment, wrap_text: true } }
  let text = apply_format_section(5.0, "\"$\"*.0")
  let nodes = render_cell_text("s", "A1", fill_layout(), text, style)
  let sb = StringBuilder::new()
  for n in nodes {
    match n {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  assert_true(!sb.to_string().contains("\u{E000}"))
}
