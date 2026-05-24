// White-box tests for the OMML → SVG renderer (`render_svg`).
//
// Each test builds an OMML `@xml.Element` tree, runs `render_svg`,
// and serialises the resulting `<g>` so the assertions can inspect
// the emitted primitives.  The renderer produces pure SVG — no
// MathML, no `<foreignObject>` — so the markers below are SVG
// element / attribute tokens.

///|
/// Build an unprefixed `@xml.QName` from a local name.
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
/// Serialise a rendered math `<g>` to an SVG string for assertions.
fn svg_string(m : MathSvg) -> String {
  @markup.serialize_svg(m.group)
}

///|
/// Build an OMML `<m:r><m:t>text</m:t></m:r>` run node.
fn omml_run(text : String) -> @xml.Node {
  @xml.Node::Element({
    name: name("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text(text)],
      }),
    ],
  })
}

///|
/// Wrap children in a named OMML element node.
fn omml_elem(tag : String, children : Array[@xml.Node]) -> @xml.Node {
  @xml.Node::Element({ name: name(tag), attributes: [], children })
}

///|
test "Office Math SVG renders a run as a <text> element" {
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [omml_run("x")],
  })
  let rendered = render_svg(math)
  let svg = svg_string(rendered)
  // The fragment carries the omml-svg marker and a real <text>.
  assert_true(svg.contains("data-ooxml=\"omml-svg\""))
  assert_true(svg.contains("<text"))
  assert_true(svg.contains(">x</text>"))
  // A non-empty run reserves a positive width and vertical extent.
  assert_true(rendered.width > 0.0)
  assert_true(rendered.height() > 0.0)
}

///|
test "Office Math SVG §22.1.2.36 fraction emits a rule line" {
  // <m:f><m:num><m:r><m:t>a</m:t></m:r></m:num>
  //      <m:den><m:r><m:t>b</m:t></m:r></m:den></m:f>
  let frac = omml_elem("f", [
    omml_elem("num", [omml_run("a")]),
    omml_elem("den", [omml_run("b")]),
  ])
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [frac],
  })
  let svg = svg_string(render_svg(math))
  // A bar fraction draws the rule as a <rect>.
  assert_true(svg.contains("<rect"))
  // Both numerator and denominator glyphs survive.
  assert_true(svg.contains(">a</text>"))
  assert_true(svg.contains(">b</text>"))
}

///|
test "Office Math SVG §22.1.2.118 noBar fraction omits the rule" {
  let frac : @xml.Element = {
    name: name("f"),
    attributes: [],
    children: [
      omml_elem("fPr", [
        @xml.Node::Element({
          name: name("type"),
          attributes: [{ name: name("val"), value: "noBar" }],
          children: [],
        }),
      ]),
      omml_elem("num", [omml_run("a")]),
      omml_elem("den", [omml_run("b")]),
    ],
  }
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(frac)],
  })
  let svg = svg_string(render_svg(math))
  // A noBar fraction stacks the parts but draws no rule rect.
  assert_false(svg.contains("<rect"))
  assert_true(svg.contains(">a</text>"))
  assert_true(svg.contains(">b</text>"))
}

///|
test "Office Math SVG §22.1.2.86 radical emits a path" {
  // <m:rad><m:deg/><m:e><m:r><m:t>x</m:t></m:r></m:e></m:rad>
  let rad = omml_elem("rad", [
    omml_elem("deg", []),
    omml_elem("e", [omml_run("x")]),
  ])
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [rad],
  })
  let svg = svg_string(render_svg(math))
  // The radical sign + overbar is drawn as a stroked <path>.
  assert_true(svg.contains("<path"))
  assert_true(svg.contains(">x</text>"))
}

///|
test "Office Math SVG §22.1.2.115 superscript lifts the script" {
  // <m:sSup><m:e><m:r><m:t>x</m:t></m:r></m:e>
  //         <m:sup><m:r><m:t>2</m:t></m:r></m:sup></m:sSup>
  let s_sup = omml_elem("sSup", [
    omml_elem("e", [omml_run("x")]),
    omml_elem("sup", [omml_run("2")]),
  ])
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [s_sup],
  })
  let rendered = render_svg(math, font_size_pt=12.0)
  let svg = svg_string(rendered)
  // Both base and script glyphs survive; a superscript is shifted
  // up via a translate transform.
  assert_true(svg.contains(">x</text>"))
  assert_true(svg.contains(">2</text>"))
  assert_true(svg.contains("translate("))
  // The script raises the fragment's ascent above one bare glyph's.
  let bare = render_svg(
    @domain.CT_OMath::new({
      name: name("oMath"),
      attributes: [],
      children: [omml_run("x")],
    }),
    font_size_pt=12.0,
  )
  assert_true(rendered.ascent > bare.ascent)
}

///|
test "Office Math SVG §22.1.2.79 nary emits the operator glyph" {
  // <m:nary><m:naryPr><m:chr val="∏"/></m:naryPr>
  //   <m:sub><m:r><m:t>i</m:t></m:r></m:sub>
  //   <m:sup><m:r><m:t>n</m:t></m:r></m:sup>
  //   <m:e><m:r><m:t>x</m:t></m:r></m:e></m:nary>
  let nary : @xml.Element = {
    name: name("nary"),
    attributes: [],
    children: [
      omml_elem("naryPr", [
        @xml.Node::Element({
          name: name("chr"),
          attributes: [{ name: name("val"), value: "\u{220F}" }],
          children: [],
        }),
      ]),
      omml_elem("sub", [omml_run("i")]),
      omml_elem("sup", [omml_run("n")]),
      omml_elem("e", [omml_run("x")]),
    ],
  }
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(nary)],
  })
  let svg = svg_string(render_svg(math))
  // U+220F N-ARY PRODUCT operator glyph + all bounds survive.
  assert_true(svg.contains("\u{220F}"))
  assert_true(svg.contains(">i</text>"))
  assert_true(svg.contains(">n</text>"))
  assert_true(svg.contains(">x</text>"))
}

///|
test "Office Math SVG §22.1.2.31 delimiter emits brackets" {
  // <m:d><m:e><m:r><m:t>x</m:t></m:r></m:e></m:d>
  let d = omml_elem("d", [omml_elem("e", [omml_run("x")])])
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [d],
  })
  let svg = svg_string(render_svg(math))
  // Default delimiter brackets are `(` and `)`.
  assert_true(svg.contains(">(</text>"))
  assert_true(svg.contains(">)</text>"))
  assert_true(svg.contains(">x</text>"))
}

///|
test "Office Math SVG §22.1.2.12 borderBox emits edge lines" {
  // <m:borderBox><m:e><m:r><m:t>x</m:t></m:r></m:e></m:borderBox>
  let bb = omml_elem("borderBox", [omml_elem("e", [omml_run("x")])])
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [bb],
  })
  let svg = svg_string(render_svg(math))
  // A full-edge border box draws its four edges as <line>s.
  assert_true(svg.contains("<line"))
  assert_true(svg.contains(">x</text>"))
}

///|
test "Office Math SVG §22.1.2.78 matrix lays cells out in a grid" {
  // 2x2 matrix.
  let cell = fn(t : String) -> @xml.Node { omml_elem("e", [omml_run(t)]) }
  let m = omml_elem("m", [
    omml_elem("mr", [cell("a"), cell("b")]),
    omml_elem("mr", [cell("c"), cell("d")]),
  ])
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [m],
  })
  let svg = svg_string(render_svg(math))
  // All four cells survive.
  for glyph in ["a", "b", "c", "d"] {
    assert_true(svg.contains(">" + glyph + "</text>"))
  }
}

///|
test "Office Math SVG honours the requested colour" {
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [omml_run("x")],
  })
  let svg = svg_string(render_svg(math, color="#ff0000"))
  assert_true(svg.contains("fill=\"#ff0000\""))
}

///|
test "Office Math SVG escapes markup in run text" {
  // A run whose text carries XML metacharacters must not break out
  // of the <text> element.
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [omml_run("a<b&c")],
  })
  let svg = svg_string(render_svg(math))
  assert_false(svg.contains("a<b&c"))
  assert_true(svg.contains("&lt;"))
  assert_true(svg.contains("&amp;"))
}

///|
test "Office Math SVG scales nested fraction parts down" {
  // A fraction whose numerator is itself a fraction: the inner
  // fraction's glyphs render at a smaller font size than the
  // outer denominator's.
  let inner = omml_elem("f", [
    omml_elem("num", [omml_run("a")]),
    omml_elem("den", [omml_run("b")]),
  ])
  let outer = omml_elem("f", [
    omml_elem("num", [inner]),
    omml_elem("den", [omml_run("c")]),
  ])
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [outer],
  })
  let rendered = render_svg(math, font_size_pt=12.0)
  // A nested fraction stacks two rule lines; the outer fraction is
  // therefore taller than a single-level fraction.
  let flat = render_svg(
    @domain.CT_OMath::new({
      name: name("oMath"),
      attributes: [],
      children: [
        omml_elem("f", [
          omml_elem("num", [omml_run("a")]),
          omml_elem("den", [omml_run("c")]),
        ]),
      ],
    }),
    font_size_pt=12.0,
  )
  assert_true(rendered.height() > flat.height())
}
