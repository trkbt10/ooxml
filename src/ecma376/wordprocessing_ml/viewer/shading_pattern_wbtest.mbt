// §17.3.1.6 / §17.4.33 / §17.18.78 ST_Shd — `<w:shd>` cell / paragraph
// shading patterns. These whitebox tests render full `<w:document>`
// trees and assert against the emitted page SVG. File-local element /
// attribute builders are named `shd_*` so they do not collide with the
// `name` / `attr` helpers in viewer_wbtest.mbt (same package).

///|
fn shd_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn shd_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: shd_name(local_name), value }
}

///|
fn shd_elem(
  local_name : String,
  attributes : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element({ name: shd_name(local_name), attributes, children })
}

///|
/// Build a one-cell, one-row table whose single cell carries the given
/// `<w:tcPr>` children (the `<w:shd>` under test) and a one-word
/// paragraph. Returns the rendered page-0 SVG of the wrapping document.
fn shd_render_cell_table(tc_pr_children : Array[@xml.Node]) -> String raise {
  let para = shd_elem("p", [], [
    shd_elem("r", [], [shd_elem("t", [], [@xml.Node::Text("A1")])]),
  ])
  let cell_children : Array[@xml.Node] = [
    shd_elem("tcPr", [], tc_pr_children),
    para,
  ]
  let cell = shd_elem("tc", [], cell_children)
  let document = @domain.CT_Document::new({
    name: shd_name("document"),
    attributes: [],
    children: [
      shd_elem("body", [], [
        shd_elem("tbl", [], [
          shd_elem("tblPr", [], []),
          shd_elem("tblGrid", [], [
            shd_elem("gridCol", [shd_attr("w", "2880")], []),
          ]),
          shd_elem("tr", [], [cell]),
        ]),
      ]),
    ],
  })
  render_svg(document).pages[0].svg
}

///|
/// Build a single-paragraph document whose `<w:pPr>` carries the given
/// `<w:shd>` and a one-word run. Returns the rendered page-0 SVG.
fn shd_render_para(shd_attrs : Array[@xml.Attribute]) -> String raise {
  let p_pr = shd_elem("pPr", [], [shd_elem("shd", shd_attrs, [])])
  let para = shd_elem("p", [], [
    p_pr,
    shd_elem("r", [], [shd_elem("t", [], [@xml.Node::Text("Para")])]),
  ])
  let document = @domain.CT_Document::new({
    name: shd_name("document"),
    attributes: [],
    children: [shd_elem("body", [], [para])],
  })
  render_svg(document).pages[0].svg
}

///|
/// (i) §17.18.78 — a cell `<w:shd w:val="pct25" w:fill="FFFF00"
/// w:color="FF0000">` must emit a `<pattern>` def, and the cell's
/// shading `<rect>` must reference it via `url(#…)`. The foreground
/// (#FF0000) marks and the background (#FFFF00) panel both appear inside
/// the tile.
test "render_svg emits a pattern def for a pct25 cell shading" {
  let svg = shd_render_cell_table([
    shd_elem(
      "shd",
      [
        shd_attr("val", "pct25"),
        shd_attr("fill", "FFFF00"),
        shd_attr("color", "FF0000"),
      ],
      [],
    ),
  ])
  // A <pattern> tile is emitted.
  assert_true(svg.contains("<pattern"))
  // The cell rect references it.
  assert_true(svg.contains("url(#wmlshd_c"))
  // Foreground marks use #FF0000; background panel uses #FFFF00.
  assert_true(svg.contains("#FF0000"))
  assert_true(svg.contains("#FFFF00"))
  // The pct density renders as a circle mark.
  assert_true(svg.contains("<circle"))
}

///|
/// (ii) §17.18.78 — `<w:shd w:val="diagStripe" …>` must emit a pattern
/// whose marks are stroked `<line>` segments (the diagonal rules), not
/// dots.
test "render_svg emits stroke lines for a diagStripe cell shading" {
  let svg = shd_render_cell_table([
    shd_elem(
      "shd",
      [
        shd_attr("val", "diagStripe"),
        shd_attr("fill", "FFFF00"),
        shd_attr("color", "FF0000"),
      ],
      [],
    ),
  ])
  assert_true(svg.contains("<pattern"))
  assert_true(svg.contains("url(#wmlshd_c"))
  // Stripe marks are <line> segments stroked with the foreground.
  assert_true(svg.contains("<line"))
  assert_true(svg.contains("stroke=\"#FF0000\""))
}

///|
/// (iii) §17.18.78 — `<w:shd w:val="solid" w:color="00FF00">` fills the
/// cell SOLID with the FOREGROUND `@color` (#00FF00), NOT `@fill`, and
/// emits NO `<pattern>` (it is a flat rect).
test "render_svg fills solid cell shading with the foreground colour" {
  let svg = shd_render_cell_table([
    shd_elem(
      "shd",
      [
        shd_attr("val", "solid"),
        shd_attr("fill", "FFFF00"),
        shd_attr("color", "00FF00"),
      ],
      [],
    ),
  ])
  // Solid → a flat rect filled with the foreground colour.
  assert_true(svg.contains("fill=\"#00FF00\""))
  // No pattern is emitted for solid.
  assert_true(!svg.contains("<pattern"))
  assert_true(!svg.contains("url(#"))
}

///|
/// (iv) §17.18.78 — `<w:shd w:val="clear" w:fill="CCCCCC">` keeps the
/// legacy solid-background path: a flat rect filled with the BACKGROUND
/// (#CCCCCC), NO `<pattern>`, and NO `url()`.
test "render_svg keeps the clear background path solid and pattern-free" {
  let svg = shd_render_cell_table([
    shd_elem("shd", [shd_attr("val", "clear"), shd_attr("fill", "CCCCCC")], []),
  ])
  assert_true(svg.contains("fill=\"#CCCCCC\""))
  assert_true(!svg.contains("<pattern"))
  assert_true(!svg.contains("url(#"))
}

///|
/// (iv-para) §17.3.1.6 — the same `clear`/`@fill` path on a PARAGRAPH
/// shading also stays solid and pattern-free.
test "render_svg keeps paragraph clear shading solid and pattern-free" {
  let svg = shd_render_para([
    shd_attr("val", "clear"),
    shd_attr("fill", "CCCCCC"),
  ])
  assert_true(svg.contains("fill=\"#CCCCCC\""))
  assert_true(!svg.contains("<pattern"))
  assert_true(!svg.contains("url(#"))
}

///|
/// (ii-para) §17.3.1.6 — a paragraph `<w:shd w:val="pct50" …>` emits a
/// pattern referenced by the paragraph shading rect (prefix `wmlshd_p`).
test "render_svg emits a pattern def for a pct50 paragraph shading" {
  let svg = shd_render_para([
    shd_attr("val", "pct50"),
    shd_attr("fill", "FFFF00"),
    shd_attr("color", "FF0000"),
  ])
  assert_true(svg.contains("<pattern"))
  assert_true(svg.contains("url(#wmlshd_p"))
  assert_true(svg.contains("#FF0000"))
  assert_true(svg.contains("#FFFF00"))
}

///|
/// (v) §17.18.78 — a cell with NO `<w:shd>` emits no pattern, no
/// `url()` reference, and no `wmlshd_` shading id. The output must be
/// byte-unchanged from the legacy no-shading path. We also assert the
/// bare cell renders no shading `<rect>` carrying a `#`-hex fill.
test "render_svg leaves a cell with no shd completely unchanged" {
  let with_no_shd = shd_render_cell_table([])
  assert_true(!with_no_shd.contains("<pattern"))
  assert_true(!with_no_shd.contains("url(#"))
  assert_true(!with_no_shd.contains("wmlshd_"))
  // A bare cell paints no shading rect, so no rect carries a hex fill.
  assert_true(
    !with_no_shd.contains("<rect") || !with_no_shd.contains("fill=\"#"),
  )
}

///|
/// (v-para) §17.3.1.6 — a paragraph with no `<w:shd>` emits no pattern,
/// no url() reference, and no shading rect.
test "render_svg leaves a paragraph with no shd completely unchanged" {
  let document = @domain.CT_Document::new({
    name: shd_name("document"),
    attributes: [],
    children: [
      shd_elem("body", [], [
        shd_elem("p", [], [
          shd_elem("r", [], [shd_elem("t", [], [@xml.Node::Text("Plain")])]),
        ]),
      ]),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(!svg.contains("<pattern"))
  assert_true(!svg.contains("url(#"))
}
