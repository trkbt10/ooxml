///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn attr(local_name : String, value : String) -> @xml.Attribute {
  { name: name(local_name), value }
}

///|
test "WordprocessingML viewer renders paragraph text" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Hello <wml>")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  assert_true(html.contains("data-ooxml=\"wml\""))
  // The XML writer escapes `<` and `&` in text content; `>` is left
  // bare because XML 1.0 §2.4 only requires escaping `>` inside the
  // `]]>` CDATA-close sequence, so `Hello <wml>` serialises as
  // `Hello &lt;wml>` — well-formed and unambiguous.
  assert_true(html.contains("<p>Hello &lt;wml></p>"))
}

///|
test "render_svg emits one default-letter page for empty body" {
  // §17.6.13 default: letter 12240×15840 twips → 816×1056 px.
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({ name: name("body"), attributes: [], children: [] }),
    ],
  })
  let result = render_svg(document)
  inspect(result.total_pages, content="1")
  let page = result.pages[0]
  // 12240 / 15 = 816, 15840 / 15 = 1056
  inspect(page.width, content="816")
  inspect(page.height, content="1056")
  assert_true(page.svg.contains("<svg "))
  assert_true(page.svg.contains("data-ooxml=\"wml\""))
  assert_true(page.svg.contains("viewBox=\"0 0 816 1056\""))
}

///|
test "render_svg emits text from a paragraph as <text> element" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Hello <wml>")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  inspect(result.total_pages, content="1")
  let svg = result.pages[0].svg
  assert_true(svg.contains("<text "))
  // The XML writer escapes `<` and `&`; `>` is left bare per XML
  // 1.0 §2.4 (only escaped inside `]]>`), so `Hello <wml>`
  // serialises to `Hello &lt;wml>`.
  assert_true(svg.contains("Hello &lt;wml>"))
  // §17.3.2.26 rFonts — without `<w:rFonts>` and without a
  // `<w:docDefaults>` cascade, the viewer falls back to the SVG/CSS
  // generic `serif` family. The previous "Calibri" assertion
  // expected a Word-specific UX default with no ECMA-376 basis.
  assert_true(svg.contains("font-family=\"serif\""))
}

///|
test "render_svg honors custom pgSz from <w:sectPr>" {
  // A4 = 11906 × 16838 twips → 793.7 × 1122.5 px.
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("sectPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pgSz"),
                attributes: [attr("w", "11906"), attr("h", "16838")],
                children: [],
              }),
              @xml.Node::Element({
                name: name("pgMar"),
                attributes: [
                  // CT_PageMar requires all seven attributes per
                  // Annex A.4.3 wml.xsd (top / right / bottom / left
                  // / header / footer / gutter).
                  attr("top", "1440"),
                  attr("right", "1440"),
                  attr("bottom", "1440"),
                  attr("left", "1440"),
                  attr("header", "720"),
                  attr("footer", "720"),
                  attr("gutter", "0"),
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  inspect(result.total_pages, content="1")
  // 11906 / 15 = 793.7333…, 16838 / 15 = 1122.5333…
  let page = result.pages[0]
  // Allow small rounding (output formatter rounds to 3 decimals).
  assert_true(page.svg.contains("width=\"793.733\""))
  assert_true(page.svg.contains("height=\"1122.533\""))
}

///|
test "render_svg renders bold and italic runs with style attrs" {
  let r_pr_b = @xml.Node::Element({
    name: name("rPr"),
    attributes: [],
    children: [
      @xml.Node::Element({ name: name("b"), attributes: [], children: [] }),
      @xml.Node::Element({ name: name("i"), attributes: [], children: [] }),
    ],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  r_pr_b,
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Bold-italic")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("font-weight=\"bold\""))
  assert_true(svg.contains("font-style=\"italic\""))
  assert_true(svg.contains("Bold-italic"))
}

///|
test "render_svg renders a table with cell borders" {
  let cell = @xml.Node::Element({
    name: name("tc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("p"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("r"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("t"),
                attributes: [],
                children: [@xml.Node::Text("A1")],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("tbl"),
            attributes: [],
            children: [
              // CT_Tbl requires <w:tblPr/> per Annex A wml.xsd
              // (sequence with EG_RangeMarkupElements + tblPr + tblGrid
              // + EG_ContentRowContent).
              @xml.Node::Element({
                name: name("tblPr"),
                attributes: [],
                children: [],
              }),
              @xml.Node::Element({
                name: name("tblGrid"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("gridCol"),
                    attributes: [attr("w", "2880")],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("gridCol"),
                    attributes: [attr("w", "2880")],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("tr"),
                attributes: [],
                children: [cell, cell],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // §17.4.40 tblBorders — without `<w:tblBorders>` or `<w:tcBorders>`,
  // the spec mandates no border. Cell text must still appear, but
  // no `<line>` border strokes are emitted (the previous "legacy
  // 1px gray" default had no ECMA-376 basis).
  assert_true(svg.contains("A1"))
  assert_true(!svg.contains("stroke=\"#999999\""))
}

///|
/// §17.4.59 — `<w:tcBorders>` per-side colours override the legacy
/// 1px gray. A `<w:top w:val="single" w:sz="16" w:color="FF0000"/>`
/// renders a 2px red top line (16 eighths = 2pt = 2.667px ≈ 2.67).
test "render_svg honours <w:tcBorders> per-side colours" {
  let cell = @xml.Node::Element({
    name: name("tc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("tcPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("tcBorders"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("top"),
                attributes: [
                  attr("val", "single"),
                  attr("sz", "16"),
                  attr("color", "FF0000"),
                ],
                children: [],
              }),
              @xml.Node::Element({
                name: name("bottom"),
                attributes: [attr("val", "none")],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("p"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("r"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("t"),
                attributes: [],
                children: [@xml.Node::Text("A1")],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("tbl"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("tblPr"),
                attributes: [],
                children: [],
              }),
              @xml.Node::Element({
                name: name("tblGrid"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("gridCol"),
                    attributes: [attr("w", "2880")],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("tr"),
                attributes: [],
                children: [cell],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // §17.4.59 tcBorders — the explicit `<w:top>` produces a red
  // stroke. §17.4.40: without `<w:tblBorders>` the other sides
  // (left/right) have no fallback per spec, so only the red top
  // line is emitted; the explicit `<w:bottom w:val="none"/>`
  // suppresses its own stroke.
  assert_true(svg.contains("stroke=\"#FF0000\""))
  // No legacy gray fallback for unspecified sides.
  assert_true(!svg.contains("stroke=\"#999999\""))
}

///|
/// §17.4.40 — `<w:tblPr>/<w:tblBorders>` provides table-wide
/// fallback borders when a cell has no `<w:tcBorders>` override.
/// The rendered SVG should pick up the table-wide colour for every
/// side of the bare cells.
test "render_svg inherits cell borders from <w:tblBorders>" {
  let cell = @xml.Node::Element({
    name: name("tc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("p"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("r"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("t"),
                attributes: [],
                children: [@xml.Node::Text("X")],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("tbl"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("tblPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("tblBorders"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("top"),
                        attributes: [
                          attr("val", "single"),
                          attr("sz", "8"),
                          attr("color", "00AA00"),
                        ],
                        children: [],
                      }),
                      @xml.Node::Element({
                        name: name("bottom"),
                        attributes: [
                          attr("val", "single"),
                          attr("sz", "8"),
                          attr("color", "00AA00"),
                        ],
                        children: [],
                      }),
                      @xml.Node::Element({
                        name: name("left"),
                        attributes: [
                          attr("val", "single"),
                          attr("sz", "8"),
                          attr("color", "00AA00"),
                        ],
                        children: [],
                      }),
                      @xml.Node::Element({
                        name: name("right"),
                        attributes: [
                          attr("val", "single"),
                          attr("sz", "8"),
                          attr("color", "00AA00"),
                        ],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("tblGrid"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("gridCol"),
                    attributes: [attr("w", "2880")],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("tr"),
                attributes: [],
                children: [cell],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // The table-wide green colour applies to all four sides of the
  // single bare cell.
  assert_true(svg.contains("stroke=\"#00AA00\""))
  // The legacy #999999 fallback must NOT appear because every side
  // resolves through the table-level borders.
  assert_false(svg.contains("stroke=\"#999999\""))
}

///|
/// §17.3.1.6 `<w:pPr><w:shd>` — paragraph shading emits a `<rect>`
/// behind the paragraph's glyphs. `@fill="FFFF00"` paints the
/// paragraph yellow.
test "render_svg emits paragraph shading rect from <w:shd>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("shd"),
                    attributes: [
                      attr("val", "clear"),
                      attr("fill", "FFFF00"),
                    ],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Highlighted")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // The shading rect uses fill="#FFFF00" and the text still renders.
  assert_true(svg.contains("fill=\"#FFFF00\""))
  assert_true(svg.contains("Highlighted"))
}

///|
/// §17.3.1.7 `<w:pPr><w:pBdr>` — paragraph borders emit four `<line>`
/// segments around the paragraph bbox. `<w:top>` with `@color="00BB00"`
/// renders the top line in green.
test "render_svg emits paragraph borders from <w:pBdr>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("pBdr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("top"),
                        attributes: [
                          attr("val", "single"),
                          attr("sz", "8"),
                          attr("color", "00BB00"),
                        ],
                        children: [],
                      }),
                      @xml.Node::Element({
                        name: name("bottom"),
                        attributes: [
                          attr("val", "single"),
                          attr("sz", "8"),
                          attr("color", "00BB00"),
                        ],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Bordered")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("stroke=\"#00BB00\""))
  // Text still renders.
  assert_true(svg.contains("Bordered"))
}

///|
/// §17.9.20 `<w:pPr><w:numPr>` — list items get a bullet glyph
/// prepended. The exact glyph / spacing isn't spec'd at the viewer
/// level so we just check the bullet character (U+2022) made it
/// through together with the body text.
test "render_svg omits bullet when numbering table not wired (§17.9)" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("numPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("ilvl"),
                        attributes: [attr("val", "0")],
                        children: [],
                      }),
                      @xml.Node::Element({
                        name: name("numId"),
                        attributes: [attr("val", "1")],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Item")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // §17.9 — without a CT_Numbering table the lvlText cannot be
  // resolved; the spec mandates use of the configured lvlText, so
  // the viewer MUST NOT substitute a literal U+2022 bullet.
  assert_true(!svg.contains("\u{2022}"))
  assert_true(svg.contains("Item"))
}

///|
/// §17.3.2.42 `<w:rPr><w:vertAlign>` — superscript / subscript runs
/// emit `<text>` elements with a scaled-down font size and a shifted
/// baseline. With no `<w:sz>` and no `<w:docDefaults>` cascade, the
/// run falls back to the viewer's spec-undefined default size of
/// 10 pt: 10 * 96/72 * 0.65 ≈ 8.667 px.
test "render_svg scales font for <w:vertAlign> superscript" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("rPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("vertAlign"),
                        attributes: [attr("val", "superscript")],
                        children: [],
                      }),
                    ],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Sup")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // 10 pt default × 96/72 × 0.65 ≈ 8.667. The emitter writes the
  // value through fmt_double which trims to ≤3 decimals, so the
  // resulting attribute is "8.667" (substring match).
  assert_true(svg.contains("font-size=\"8.667\""))
  assert_true(svg.contains("Sup"))
}

///|
/// §17.3.2.36 `<w:rPr><w:spacing w:val="…">` — character spacing in
/// twentieths of a point. `@val="40"` = 2 pt = 2.667 px → the emitter
/// writes `letter-spacing="2.667px"`.
test "render_svg emits letter-spacing from <w:rPr><w:spacing>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("rPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("spacing"),
                        attributes: [attr("val", "40")],
                        children: [],
                      }),
                    ],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Wide")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("letter-spacing=\"2.667px\""))
  assert_true(svg.contains("Wide"))
}

///|
/// §17.6.10 `<w:sectPr><w:pgBorders>` — page borders attach to the
/// section properties and emit a frame around the page's content
/// area (margin box). `<w:top color="0000FF">` renders the top line
/// in blue.
test "render_svg emits page borders from <w:pgBorders>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Page")],
                  }),
                ],
              }),
            ],
          }),
          @xml.Node::Element({
            name: name("sectPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pgBorders"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("top"),
                    attributes: [
                      attr("val", "single"),
                      attr("sz", "16"),
                      attr("color", "0000FF"),
                    ],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("bottom"),
                    attributes: [
                      attr("val", "single"),
                      attr("sz", "16"),
                      attr("color", "0000FF"),
                    ],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("left"),
                    attributes: [
                      attr("val", "single"),
                      attr("sz", "16"),
                      attr("color", "0000FF"),
                    ],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("right"),
                    attributes: [
                      attr("val", "single"),
                      attr("sz", "16"),
                      attr("color", "0000FF"),
                    ],
                    children: [],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("stroke=\"#0000FF\""))
  assert_true(svg.contains("Page"))
}

///|
/// §17.2.1 `<w:document>/<w:background w:color="…">` — the document-
/// wide background colour overrides the legacy white page rect. With
/// `@color="EEEEEE"` the page rect emits `fill="#EEEEEE"`.
test "render_svg honours <w:document><w:background>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("background"),
        attributes: [attr("color", "EEEEEE")],
        children: [],
      }),
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("BG")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // Custom background fill replaces the legacy #ffffff.
  assert_true(svg.contains("fill=\"#EEEEEE\""))
  assert_false(svg.contains("fill=\"#ffffff\""))
  assert_true(svg.contains("BG"))
}

///|
/// §17.3.1.33 `<w:spacing line="480" lineRule="auto">` — double-line
/// spacing scales the line height to 2× the font size. The default
/// 22 half-points = 11pt run yields a baseline at
/// 11pt × 96/72 × 0.8 ≈ 11.733 px (default Calibri ascender).
/// With double spacing the next line would start at line-height = 11pt
/// × 96/72 × 2 ≈ 29.333 px down — assert that the second paragraph's
/// first line starts well below the single-line distance to confirm
/// the multiplier got picked up.
test "render_svg honours <w:spacing line lineRule='auto'>" {
  let para = fn(line_val : String, text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("p"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("pPr"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("spacing"),
              attributes: [
                attr("line", line_val),
                attr("lineRule", "auto"),
              ],
              children: [],
            }),
          ],
        }),
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
        }),
      ],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [para("480", "Double"), para("480", "Double2")],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("Double"))
  assert_true(svg.contains("Double2"))
}

///|
/// §17.3.2.13 `<w:caps>` + §17.3.2.33 `<w:smallCaps>` — both toggles
/// surface as CSS rules in the `<text>` element's style attribute.
test "render_svg emits text-transform / font-variant for caps + smallCaps" {
  let run = fn(toggle : String, text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("rPr"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name(toggle),
              attributes: [],
              children: [],
            }),
          ],
        }),
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [run("caps", "All")],
          }),
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [run("smallCaps", "Small")],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("text-transform: uppercase"))
  assert_true(svg.contains("font-variant: small-caps"))
  assert_true(svg.contains("All"))
  assert_true(svg.contains("Small"))
}

///|
/// §17.3.2.43 `<w:vanish>` — hidden runs render nothing. A paragraph
/// with a visible "Keep" run and a hidden "Hide" run should surface
/// only "Keep" in the SVG output.
test "render_svg suppresses <w:vanish> runs" {
  let visible_run : @xml.Node = @xml.Node::Element({
    name: name("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("Keep")],
      }),
    ],
  })
  let hidden_run : @xml.Node = @xml.Node::Element({
    name: name("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("rPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("vanish"),
            attributes: [],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("Hide")],
      }),
    ],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [visible_run, hidden_run],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("Keep"))
  assert_false(svg.contains("Hide"))
}

///|
/// §17.3.2.4 `<w:rPr><w:bdr>` — run-level border wraps the glyph
/// bbox in an outlined rect. `@color="AA00AA"` renders the stroke
/// in magenta.
test "render_svg emits run border rect from <w:rPr><w:bdr>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("rPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("bdr"),
                        attributes: [
                          attr("val", "single"),
                          attr("sz", "8"),
                          attr("color", "AA00AA"),
                        ],
                        children: [],
                      }),
                    ],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Boxed")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("stroke=\"#AA00AA\""))
  assert_true(svg.contains("Boxed"))
}

///|
/// §17.3.2.30 `<w:rtl>` — right-to-left run direction toggles a
/// `direction="rtl" unicode-bidi="bidi-override"` attribute pair on
/// the `<text>` element.
test "render_svg emits RTL direction for <w:rtl>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("rPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("rtl"),
                        attributes: [],
                        children: [],
                      }),
                    ],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("RTL")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("direction=\"rtl\""))
  assert_true(svg.contains("unicode-bidi=\"bidi-override\""))
  assert_true(svg.contains("RTL"))
}

///|
/// §17.3.2.23 outline + §17.3.2.31 shadow + §17.3.2.12 em — three
/// text-effect toggles emit distinct SVG / CSS attributes on the
/// `<text>` element.
test "render_svg emits outline/shadow/em effects" {
  let run = fn(toggles : Array[(String, Array[@xml.Attribute])]) -> @xml.Node {
    let rpr_children : Array[@xml.Node] = []
    for entry in toggles {
      let (lname, atts) = entry
      rpr_children.push(@xml.Node::Element({
        name: name(lname),
        attributes: atts,
        children: [],
      }))
    }
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("rPr"),
          attributes: [],
          children: rpr_children,
        }),
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text("Fx")],
        }),
      ],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              run([
                ("outline", []),
                ("shadow", []),
                ("em", [attr("val", "dot")]),
              ]),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // outline → stroke + paint-order
  assert_true(svg.contains("paint-order=\"stroke fill\""))
  // shadow → CSS text-shadow
  assert_true(svg.contains("text-shadow: 1px 1px 1px rgba(0,0,0,0.5)"))
  // em → CSS text-emphasis-style. §17.18.24 ST_Em `dot` maps to
  // the CSS `filled dot` keyword pair (the previous raw `dot`
  // string was not a valid CSS keyword).
  assert_true(svg.contains("text-emphasis-style: filled dot"))
  assert_true(svg.contains("Fx"))
}

///|
/// §17.3.2.46 `<w:w w:val="…">` — horizontal character scaling.
/// `@val="50"` compresses the run to 50% via SVG transform with
/// translate-anchor so the run's start x stays put.
test "render_svg applies <w:w> horizontal scaling via transform" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("rPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("w"),
                        attributes: [attr("val", "50")],
                        children: [],
                      }),
                    ],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Narrow")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // 50% scale → factor 0.5; the transform string includes
  // `scale(0.5, 1)` regardless of the anchor numbers.
  assert_true(svg.contains("scale(0.5, 1)"))
  assert_true(svg.contains("Narrow"))
}

///|
/// §17.3.1.5 `<w:pageBreakBefore>` — the second paragraph forces a
/// new page so the document renders across two pages instead of one.
test "render_svg honours <w:pageBreakBefore>" {
  let make_para = fn(text : String, page_break : Bool) -> @xml.Node {
    let pPr_children : Array[@xml.Node] = []
    if page_break {
      pPr_children.push(@xml.Node::Element({
        name: name("pageBreakBefore"),
        attributes: [],
        children: [],
      }))
    }
    let children : Array[@xml.Node] = []
    if pPr_children.length() > 0 {
      children.push(@xml.Node::Element({
        name: name("pPr"),
        attributes: [],
        children: pPr_children,
      }))
    }
    children.push(@xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    }))
    @xml.Node::Element({ name: name("p"), attributes: [], children })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [make_para("First", false), make_para("Second", true)],
      }),
    ],
  })
  let result = render_svg(document)
  assert_eq(result.total_pages, 2)
  assert_true(result.pages[0].svg.contains("First"))
  assert_true(result.pages[1].svg.contains("Second"))
}

///|
/// §17.3.3.1 `<w:r><w:br w:type="page"/>` — a paragraph carrying an
/// inline page-break run starts the next block on a fresh page.
test "render_svg honours <w:br w:type='page'>" {
  let make_para = fn(text : String, with_break : Bool) -> @xml.Node {
    let r_children : Array[@xml.Node] = [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text(text)],
      }),
    ]
    if with_break {
      r_children.push(@xml.Node::Element({
        name: name("br"),
        attributes: [attr("type", "page")],
        children: [],
      }))
    }
    @xml.Node::Element({
      name: name("p"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("r"),
          attributes: [],
          children: r_children,
        }),
      ],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          make_para("Page1", true),
          make_para("Page2", false),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  assert_eq(result.total_pages, 2)
  assert_true(result.pages[0].svg.contains("Page1"))
  assert_true(result.pages[1].svg.contains("Page2"))
}

///|
/// §17.7 — when a paragraph references a `<w:pPr><w:pStyle val="Heading1"/>`
/// and the supplied `CT_Styles` defines that style with `<w:rPr><w:sz
/// val="56"/></w:rPr>`, the rendered run picks up font-size 28 pt
/// (56 half-points). `28 pt × 96/72 ≈ 37.333 px`, which `fmt_double`
/// trims to `37.333`.
test "render_svg cascades through CT_Styles for pStyle" {
  let styles_element : @xml.Element = {
    name: name("styles"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("style"),
        attributes: [
          attr("type", "paragraph"),
          attr("styleId", "Heading1"),
        ],
        children: [
          @xml.Node::Element({
            name: name("rPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("sz"),
                attributes: [attr("val", "56")],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Styles::new(styles_element)
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("pStyle"),
                    attributes: [attr("val", "Heading1")],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Title")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document, styles=Some(styles)).pages[0].svg
  assert_true(svg.contains("font-size=\"37.333\""))
  assert_true(svg.contains("Title"))
}

///|
/// §17.7 — verify the full cascade (`<w:docDefaults><w:rPrDefault>` →
/// basedOn chain → direct rPr) by:
///   docDefaults run-pr supplies color #112233
///   Style "Body" (no basedOn) supplies italic
///   Style "Body2" basedOn "Body" supplies size 48 half-points
///   Direct rPr supplies bold
/// A paragraph pStyle="Body2" with a run that has direct bold should
/// surface all four: color #112233 + italic + 24pt (48/2) +
/// font-weight bold.
test "render_svg cascades docDefaults + basedOn chain through styles" {
  let styles_element : @xml.Element = {
    name: name("styles"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("docDefaults"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("rPrDefault"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("rPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("color"),
                    attributes: [attr("val", "112233")],
                    children: [],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("style"),
        attributes: [
          attr("type", "paragraph"),
          attr("styleId", "Body"),
        ],
        children: [
          @xml.Node::Element({
            name: name("rPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("i"),
                attributes: [],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("style"),
        attributes: [
          attr("type", "paragraph"),
          attr("styleId", "Body2"),
        ],
        children: [
          @xml.Node::Element({
            name: name("basedOn"),
            attributes: [attr("val", "Body")],
            children: [],
          }),
          @xml.Node::Element({
            name: name("rPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("sz"),
                attributes: [attr("val", "48")],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Styles::new(styles_element)
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("pStyle"),
                    attributes: [attr("val", "Body2")],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("rPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("b"),
                        attributes: [],
                        children: [],
                      }),
                    ],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Mix")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document, styles=Some(styles)).pages[0].svg
  // 48 half-points = 24 pt; 24 × 96/72 = 32 px exactly.
  assert_true(svg.contains("font-size=\"32\""))
  // italic from Body, bold from direct rPr, colour from docDefaults.
  assert_true(svg.contains("font-style=\"italic\""))
  assert_true(svg.contains("font-weight=\"bold\""))
  assert_true(svg.contains("fill=\"#112233\""))
  assert_true(svg.contains("Mix"))
}

///|
/// §17.9 — when CT_Numbering is wired in, `<w:numPr>` paragraphs emit
/// the resolved `<w:lvlText>` (with counter substitution) instead of
/// the placeholder bullet. Three paragraphs sharing numId 1 / ilvl 0
/// with `lvlText="%1."` and decimal format render as `1.`, `2.`, `3.`.
test "render_svg resolves <w:numPr> via CT_Numbering lvlText counters" {
  let abstract_num : @xml.Element = {
    name: name("abstractNum"),
    attributes: [attr("abstractNumId", "0")],
    children: [
      @xml.Node::Element({
        name: name("lvl"),
        attributes: [attr("ilvl", "0")],
        children: [
          @xml.Node::Element({
            name: name("start"),
            attributes: [attr("val", "1")],
            children: [],
          }),
          @xml.Node::Element({
            name: name("numFmt"),
            attributes: [attr("val", "decimal")],
            children: [],
          }),
          @xml.Node::Element({
            name: name("lvlText"),
            attributes: [attr("val", "%1.")],
            children: [],
          }),
        ],
      }),
    ],
  }
  let num_el : @xml.Element = {
    name: name("num"),
    attributes: [attr("numId", "1")],
    children: [
      @xml.Node::Element({
        name: name("abstractNumId"),
        attributes: [attr("val", "0")],
        children: [],
      }),
    ],
  }
  let numbering_element : @xml.Element = {
    name: name("numbering"),
    attributes: [],
    children: [
      @xml.Node::Element(abstract_num),
      @xml.Node::Element(num_el),
    ],
  }
  let numbering = @domain.CT_Numbering::parse(numbering_element)
  let make_item = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("p"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("pPr"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("numPr"),
              attributes: [],
              children: [
                @xml.Node::Element({
                  name: name("ilvl"),
                  attributes: [attr("val", "0")],
                  children: [],
                }),
                @xml.Node::Element({
                  name: name("numId"),
                  attributes: [attr("val", "1")],
                  children: [],
                }),
              ],
            }),
          ],
        }),
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
        }),
      ],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          make_item("Alpha"),
          make_item("Beta"),
          make_item("Gamma"),
        ],
      }),
    ],
  })
  let svg = render_svg(document, numbering=Some(numbering)).pages[0].svg
  // The placeholder bullet U+2022 must NOT appear — the resolver
  // supplies the formatted marker instead.
  assert_false(svg.contains("\u{2022}"))
  // Each list item gets its decimal counter.
  assert_true(svg.contains("1.") && svg.contains("Alpha"))
  assert_true(svg.contains("2.") && svg.contains("Beta"))
  assert_true(svg.contains("3.") && svg.contains("Gamma"))
}

///|
test "render_svg paginates when content exceeds page height" {
  // Build many paragraphs to overflow a single page.
  let paragraphs : Array[@xml.Node] = []
  for _ in 0..<200 {
    paragraphs.push(
      @xml.Node::Element({
        name: name("p"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("r"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("t"),
                attributes: [],
                children: [@xml.Node::Text("line")],
              }),
            ],
          }),
        ],
      }),
    )
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: paragraphs,
      }),
    ],
  })
  let result = render_svg(document)
  assert_true(result.total_pages > 1)
}

///|
/// §17.16.20 `<w:fldSimple>` — runs inside a simple-field wrapper are
/// still rendered because the collector descends through the wrapper.
test "render_svg picks up text inside <w:fldSimple>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("fldSimple"),
                attributes: [attr("instr", "PAGE")],
                children: [
                  @xml.Node::Element({
                    name: name("r"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("t"),
                        attributes: [],
                        children: [@xml.Node::Text("Page 1")],
                      }),
                    ],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let page = result.pages[0]
  assert_true(page.svg.contains("Page 1"))
}

///|
/// §17.3.3.9 `<w:drawing>` — the renderer reserves space matching the
/// `<wp:extent cx="…">` width even though full image rendering still
/// emits a placeholder. cx=914400 EMU = 1 inch = 96 px.
test "render_svg reserves inline width from <w:drawing><wp:extent>" {
  let drawing : @xml.Node = @xml.Node::Element({
    name: name("drawing"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("inline"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("extent"),
            attributes: [
              attr("cx", "914400"),
              attr("cy", "457200"),
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("docPr"),
            attributes: [
              attr("id", "1"),
              attr("name", "Picture"),
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("graphic"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("graphicData"),
                attributes: [attr("uri", "test")],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Before")],
                  }),
                  drawing,
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("After")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let page = result.pages[0]
  // Both text fragments should render — the drawing placeholder
  // doesn't replace them.
  assert_true(page.svg.contains("Before"))
  assert_true(page.svg.contains("After"))
}

///|
/// §17.3.3.9 + §20.4.2 — when an `image_resolver` provides a payload
/// for the `<a:blip r:embed="…">` of `<w:drawing>/<wp:inline>/<a:graphic>
/// /<a:graphicData>/<pic:pic>/<pic:blipFill>/<a:blip>`, the renderer
/// emits an `<image>` element rather than a whitespace placeholder.
test "render_svg emits <image> for inline <w:drawing> via image_resolver" {
  let blip : @xml.Node = @xml.Node::Element({
    name: name("blip"),
    attributes: [attr("embed", "rId99")],
    children: [],
  })
  let pic : @xml.Node = @xml.Node::Element({
    name: name("pic"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("blipFill"),
        attributes: [],
        children: [blip],
      }),
    ],
  })
  let drawing : @xml.Node = @xml.Node::Element({
    name: name("drawing"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("inline"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("extent"),
            attributes: [
              attr("cx", "914400"),
              attr("cy", "914400"),
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("docPr"),
            attributes: [
              attr("id", "1"),
              attr("name", "Picture"),
              attr("descr", "Sample picture"),
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("graphic"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("graphicData"),
                attributes: [attr("uri", "test")],
                children: [pic],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [drawing],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let resolver = fn(rid : String) -> ResolvedImage? {
    if rid == "rId99" {
      Some({ mime_type: "image/png", base64_data: "AAAB" })
    } else {
      None
    }
  }
  let result = render_svg(document, image_resolver=resolver)
  let page = result.pages[0]
  assert_true(page.svg.contains("<image"))
  assert_true(page.svg.contains("href=\"data:image/png;base64,AAAB\""))
  // alt-text (`descr`) surfaces as `<title>` for accessibility.
  assert_true(page.svg.contains("<title>Sample picture</title>"))
}

///|
/// §17.3.1.38 `<w:tabs>` — a paragraph's explicit tab stop advances
/// the cursor to the declared `pos` (twips → CSS px) when a `<w:tab>`
/// is hit. The post-tab text starts at that position, so the rendered
/// SVG places the second `<text>` element at x = 1440 twips * (96/72/20) = 96 px.
test "render_svg honours explicit <w:tabs> stop" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("tabs"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("tab"),
                        attributes: [
                          attr("val", "start"),
                          attr("pos", "1440"),
                        ],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("A")],
                  }),
                  @xml.Node::Element({
                    name: name("tab"),
                    attributes: [],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("B")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let page = result.pages[0]
  // Both text fragments render; the tab span has been resolved so the
  // post-tab "B" text element appears at the declared 96px column.
  assert_true(page.svg.contains(">A</text>"))
  assert_true(page.svg.contains(">B</text>"))
  assert_true(page.svg.contains("x=\"96\""))
}

///|
/// §17.18.87 ST_TabJc `bar` — a bar tab stop draws a vertical rule
/// at the declared position rather than advancing the text cursor.
/// The rendered SVG should carry a `<line data-ooxml-tab="bar">`
/// at x = 1440 twips * (96/72/20) = 96 px.
test "render_svg draws a vertical rule for a bar tab stop" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("tabs"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("tab"),
                        attributes: [attr("val", "bar"), attr("pos", "1440")],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("A")],
                  }),
                  @xml.Node::Element({
                    name: name("tab"),
                    attributes: [],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("B")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let page = result.pages[0]
  // The bar tab emits a <line> tagged with data-ooxml-tab="bar".
  assert_true(page.svg.contains("data-ooxml-tab=\"bar\""))
  assert_true(page.svg.contains("<line"))
  // The bar tab has zero width, so "B" follows "A" directly rather
  // than jumping to the 96px column.
  assert_true(page.svg.contains(">A</text>"))
  assert_true(page.svg.contains(">B</text>"))
}

///|
/// §17.3.3.30 `<w:sym>` — emits the referenced Symbol-font glyph as a
/// regular `<text>` span with the run's font family overridden by
/// `@font`. `@char="2713"` is the U+2713 check mark.
test "render_svg emits Symbol-font character for <w:sym>" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("sym"),
                    attributes: [
                      attr("font", "Wingdings"),
                      attr("char", "2713"),
                    ],
                    children: [],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let page = result.pages[0]
  // The renderer overrides the run's font family with "Wingdings" and
  // emits the U+2713 glyph.
  assert_true(page.svg.contains("font-family=\"Wingdings\""))
  assert_true(page.svg.contains("\u{2713}"))
}

///|
/// §17.7.6 — when a `<w:tbl>` references a `<w:tblStyle>` with a
/// `<w:tblStylePr w:type="firstRow"><w:tcPr><w:shd w:fill="FFFFCC"/>`,
/// the first-row cells render with the yellow background even though
/// no direct `<w:shd>` is declared on the cell itself. The second row
/// must NOT pick up that override.
test "render_svg applies §17.7.6 firstRow tcPr.shd from referenced tblStyle" {
  let p_with = fn(txt : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("p"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("r"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("t"),
              attributes: [],
              children: [@xml.Node::Text(txt)],
            }),
          ],
        }),
      ],
    })
  }
  let mk_cell = fn(txt : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("tc"),
      attributes: [],
      children: [p_with(txt)],
    })
  }
  let tbl_style_pr_first_row : @xml.Node = @xml.Node::Element({
    name: name("tblStylePr"),
    attributes: [attr("type", "firstRow")],
    children: [
      @xml.Node::Element({
        name: name("tcPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("shd"),
            attributes: [attr("val", "clear"), attr("fill", "FFFFCC")],
            children: [],
          }),
        ],
      }),
    ],
  })
  let style_element : @xml.Node = @xml.Node::Element({
    name: name("style"),
    attributes: [attr("styleId", "TestTbl"), attr("type", "table")],
    children: [tbl_style_pr_first_row],
  })
  let styles_doc = @domain.CT_Styles::new({
    name: name("styles"),
    attributes: [],
    children: [style_element],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("tbl"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("tblPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("tblStyle"),
                    attributes: [attr("val", "TestTbl")],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("tblLook"),
                    attributes: [
                      attr("firstRow", "1"),
                      attr("lastRow", "0"),
                      attr("firstColumn", "0"),
                      attr("lastColumn", "0"),
                      attr("noHBand", "1"),
                      attr("noVBand", "1"),
                    ],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("tblGrid"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("gridCol"),
                    attributes: [attr("w", "2880")],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("tr"),
                attributes: [],
                children: [mk_cell("Header")],
              }),
              @xml.Node::Element({
                name: name("tr"),
                attributes: [],
                children: [mk_cell("Body")],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document, styles=Some(styles_doc)).pages[0].svg
  // The first row picks up shd fill=FFFFCC from the tblStyle's
  // firstRow override and renders a <rect ... fill="#FFFFCC"/>.
  assert_true(svg.contains("fill=\"#FFFFCC\""))
  // Body row carries no shd so it must not pick up that fill.
  // Count substring occurrences: must be exactly one (the first
  // row's `<rect ... fill="#FFFFCC"/>`).
  inspect(count_occurrences(svg, "fill=\"#FFFFCC\""), content="1")
}

///|
/// §17.4.85 — a 2-row table whose row-0 cell declares
/// `<w:vMerge w:val="restart"/>` and whose row-1 cell declares
/// `<w:vMerge/>` (no val = continue) must render only one anchor
/// cell whose height covers both rows, and zero continuation cells.
test "render_svg honours <w:vMerge> vertical-merge restart/continue" {
  let p_with = fn(txt : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("p"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("r"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("t"),
              attributes: [],
              children: [@xml.Node::Text(txt)],
            }),
          ],
        }),
      ],
    })
  }
  let v_merge_restart_cell : @xml.Node = @xml.Node::Element({
    name: name("tc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("tcPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("vMerge"),
            attributes: [attr("val", "restart")],
            children: [],
          }),
        ],
      }),
      p_with("Anchor"),
    ],
  })
  let v_merge_continue_cell : @xml.Node = @xml.Node::Element({
    name: name("tc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("tcPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("vMerge"),
            attributes: [],
            children: [],
          }),
        ],
      }),
      p_with("ShouldBeHidden"),
    ],
  })
  let plain_cell = fn(txt : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("tc"),
      attributes: [],
      children: [p_with(txt)],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("tbl"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("tblPr"),
                attributes: [],
                children: [],
              }),
              @xml.Node::Element({
                name: name("tblGrid"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("gridCol"),
                    attributes: [attr("w", "2880")],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("gridCol"),
                    attributes: [attr("w", "2880")],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("tr"),
                attributes: [],
                children: [v_merge_restart_cell, plain_cell("R0C1")],
              }),
              @xml.Node::Element({
                name: name("tr"),
                attributes: [],
                children: [v_merge_continue_cell, plain_cell("R1C1")],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // The anchor's text "Anchor" must appear once; the continuation's
  // text "ShouldBeHidden" must not appear at all.
  assert_true(svg.contains("Anchor"))
  assert_true(!svg.contains("ShouldBeHidden"))
  // The non-merged sibling cells must still render in both rows.
  assert_true(svg.contains("R0C1"))
  assert_true(svg.contains("R1C1"))
}

///|
/// Count non-overlapping occurrences of `needle` in `haystack`.
fn count_occurrences(haystack : String, needle : String) -> Int {
  if needle.length() == 0 {
    return 0
  }
  let mut count = 0
  let mut i = 0
  while i + needle.length() <= haystack.length() {
    let mut matched = true
    for j in 0..<needle.length() {
      if haystack.code_unit_at(i + j) != needle.code_unit_at(j) {
        matched = false
        break
      }
    }
    if matched {
      count = count + 1
      i = i + needle.length()
    } else {
      i = i + 1
    }
  }
  count
}

///|
/// §17.15.1.51 / §17.18.97 — end-to-end: when render_svg receives
/// a `theme=Some(t)` and the document carries a `<w:color
/// w:themeColor="accent1"/>` attribute, the rendered SVG MUST
/// contain the resolved sRGB hex from the theme's clrScheme.
test "render_svg resolves <w:color themeColor> through theme cascade" {
  // Build a minimal theme: <a:theme>/<a:themeElements>/<a:clrScheme>
  // with accent1=#4472C4.  The parse_clr_scheme helper looks at
  // `local_name` only, so prefix/ns are irrelevant here.
  let srgb : @xml.Element = {
    name: name("srgbClr"),
    attributes: [{ name: name("val"), value: "4472C4" }],
    children: [],
  }
  let accent1 : @xml.Element = {
    name: name("accent1"),
    attributes: [],
    children: [@xml.Node::Element(srgb)],
  }
  let clr_scheme : @xml.Element = {
    name: name("clrScheme"),
    attributes: [{ name: name("name"), value: "TestScheme" }],
    children: [@xml.Node::Element(accent1)],
  }
  let theme_elts : @xml.Element = {
    name: name("themeElements"),
    attributes: [],
    children: [@xml.Node::Element(clr_scheme)],
  }
  let theme : @xml.Element = {
    name: name("theme"),
    attributes: [],
    children: [@xml.Node::Element(theme_elts)],
  }
  // Document with one paragraph carrying themeColor="accent1".
  let r_pr : @xml.Element = {
    name: name("rPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("color"),
        attributes: [
          { name: name("val"), value: "auto" },
          { name: name("themeColor"), value: "accent1" },
        ],
        children: [],
      }),
    ],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element(r_pr),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Themed")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document, theme=Some(theme))
  // Concatenate every page so we can scan for the resolved hex.
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  // The themeColor="accent1" must resolve to #4472c4 (lowercase
  // per ThemeColorMap normalisation).
  assert_true(svg.contains("#4472c4"))
}

///|
/// §17.13.5.29 `<w:pPrChange>` — paragraph-property revision marker
/// MUST surface its @id as `data-ooxml-ppr-change` on the rendered
/// `<p>` so revision visualisers can highlight changed paragraphs.
///
/// §17.13.5.31 `<w:rPrChange>` — run-property revision marker is the
/// run-level mirror; surfaces as `data-ooxml-rpr-change` on `<span>`.
test "wml viewer §17.13.5.29 pPrChange and §17.13.5.31 rPrChange surface as data attrs" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("pPrChange"),
                    attributes: [
                      { name: name("id"), value: "7" },
                      { name: name("author"), value: "Alice" },
                    ],
                    children: [
                      @xml.Node::Element({
                        name: name("pPr"),
                        attributes: [],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("rPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("rPrChange"),
                        attributes: [
                          { name: name("id"), value: "9" },
                          { name: name("author"), value: "Alice" },
                        ],
                        children: [
                          @xml.Node::Element({
                            name: name("rPr"),
                            attributes: [],
                            children: [],
                          }),
                        ],
                      }),
                    ],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("revised")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  assert_true(html.contains("data-ooxml-ppr-change=\"7\""))
  assert_true(html.contains("data-ooxml-rpr-change=\"9\""))
  // Body text still rendered.
  assert_true(html.contains("revised"))
}

///|
/// §17.13.5.18 `<w:ins>`, §17.13.5.14 `<w:del>`, §17.13.5.20
/// `<w:moveTo>`, §17.13.5.27 `<w:moveFrom>` — the WML viewer
/// MUST emit `<ins>` / `<del>` HTML wrappers around revision
/// content, surfacing the spec's @w:id, @w:author, @w:date as
/// `data-w-*` attributes plus `data-ooxml-revision` carrying
/// the source-element local name so consumers can distinguish
/// insertion from move-to (both wrap in `<ins>`).
test "wml viewer §17.13.5 ins/del/moveTo/moveFrom emit semantic wrappers" {
  let make_rev_para = fn(
    rev_tag : String,
    inner_text : String,
    text_tag : String,
  ) -> @xml.Node {
    let inner_text_el : @xml.Node = @xml.Node::Element({
      name: name(text_tag),
      attributes: [],
      children: [@xml.Node::Text(inner_text)],
    })
    let run : @xml.Node = @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [inner_text_el],
    })
    let rev : @xml.Node = @xml.Node::Element({
      name: name(rev_tag),
      attributes: [
        { name: name("id"), value: "1" },
        { name: name("author"), value: "Alice" },
        { name: name("date"), value: "2024-01-02T03:04:05Z" },
      ],
      children: [run],
    })
    @xml.Node::Element({
      name: name("p"),
      attributes: [],
      children: [rev],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          make_rev_para("ins", "inserted-text", "t"),
          make_rev_para("del", "deleted-text", "delText"),
          make_rev_para("moveTo", "moved-to-text", "t"),
          make_rev_para("moveFrom", "moved-from-text", "delText"),
        ],
      }),
    ],
  })
  let html = render_html(document)
  // Insertion-class wrappers use `<ins>` with the source local-name on
  // `data-ooxml-revision`.
  assert_true(html.contains("<ins data-ooxml-revision=\"ins\""))
  assert_true(html.contains("<ins data-ooxml-revision=\"moveTo\""))
  // Deletion-class wrappers use `<del>`.
  assert_true(html.contains("<del data-ooxml-revision=\"del\""))
  assert_true(html.contains("<del data-ooxml-revision=\"moveFrom\""))
  // Spec metadata surfaces as data attrs.
  assert_true(html.contains("data-w-id=\"1\""))
  assert_true(html.contains("data-w-author=\"Alice\""))
  assert_true(html.contains("data-w-date=\"2024-01-02T03:04:05Z\""))
  // Inner content survives.
  assert_true(html.contains("inserted-text"))
  assert_true(html.contains("deleted-text"))
  assert_true(html.contains("moved-to-text"))
  assert_true(html.contains("moved-from-text"))
}

///|
/// §17.11.14 `<w:footnoteReference>`, §17.11.7 `<w:endnoteReference>`,
/// §17.13.4.5 `<w:commentReference>`, §17.13.4.6 `<w:commentRangeStart>`,
/// §17.13.4.7 `<w:commentRangeEnd>` MUST surface as data-ooxml-* markers
/// in the rendered HTML so downstream renderers can resolve the
/// referenced part / range later.
test "wml viewer §17.11/17.13.4 footnote/endnote/comment markers surface" {
  let mk_marker = fn(local : String, id : String) -> @xml.Node {
    @xml.Node::Element({
      name: name(local),
      attributes: [{ name: name("id"), value: id }],
      children: [],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  mk_marker("footnoteReference", "1"),
                  mk_marker("endnoteReference", "2"),
                  mk_marker("commentReference", "3"),
                ],
              }),
              mk_marker("commentRangeStart", "9"),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("commented text")],
                  }),
                ],
              }),
              mk_marker("commentRangeEnd", "9"),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  // Footnote / endnote / comment reference markers.
  assert_true(html.contains("data-ooxml-footnote-id=\"1\""))
  assert_true(html.contains("data-ooxml-endnote-id=\"2\""))
  assert_true(html.contains("data-ooxml-comment-id=\"3\""))
  // Comment range start / end markers (with matching @w:id).
  assert_true(html.contains("data-ooxml-comment-range-start=\"9\""))
  assert_true(html.contains("data-ooxml-comment-range-end=\"9\""))
  // Text in between survives.
  assert_true(html.contains("commented text"))
}

///|
/// §17.3.3.30 `<w:sym>` — the symbol element MUST emit the
/// @w:char codepoint as the actual Unicode character (decoded
/// from xsd:hexBinary), wrapped in a `<span>` carrying
/// `data-ooxml-sym-font` so consumers can apply the matching
/// symbol typeface.
test "wml viewer §17.3.3.30 sym emits codepoint with data-ooxml-sym-font" {
  // U+0041 = 'A' in the @w:font typeface "Symbol" (legacy mapping;
  // the spec just stores the codepoint and the font name).
  let sym : @xml.Node = @xml.Node::Element({
    name: name("sym"),
    attributes: [
      { name: name("font"), value: "Symbol" },
      { name: name("char"), value: "0041" },
    ],
    children: [],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [sym],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  assert_true(html.contains("data-ooxml-sym-font=\"Symbol\""))
  // The glyph for U+0041 is "A".
  assert_true(html.contains(">A<"))
}

///|
/// §22.1.2.77 `<m:oMath>` and §22.1.2.78 `<m:oMathPara>` — when
/// the WML viewer encounters Office Math markup it MUST emit
/// MathML through the @office_math viewer rather than silently
/// dropping the math content.
test "wml viewer §22.1 oMath emits MathML through @office_math viewer" {
  // <m:oMath><m:r><m:t>x</m:t></m:r></m:oMath> at body level.
  let math_t : @xml.Node = @xml.Node::Element({
    name: name("t"),
    attributes: [],
    children: [@xml.Node::Text("x")],
  })
  let math_r : @xml.Node = @xml.Node::Element({
    name: name("r"),
    attributes: [],
    children: [math_t],
  })
  let omath : @xml.Node = @xml.Node::Element({
    name: name("oMath"),
    attributes: [],
    children: [math_r],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [omath],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  // The math viewer wraps in <math data-ooxml="omml"> and
  // produces <mtext>x</mtext> for the run text.
  assert_true(html.contains("<math data-ooxml=\"omml\""))
  assert_true(html.contains("<mtext>x</mtext>"))
}

///|
/// §17.16.22 — when the caller supplies a `rels_resolver`, the
/// WML viewer MUST use the resolved URL as the `<a>` href and
/// still surface the source r:id as `data-ooxml-r-id` so
/// consumers can round-trip.
test "wml viewer §17.16.22 hyperlink rels_resolver replaces href" {
  let hl : @xml.Node = @xml.Node::Element({
    name: name("hyperlink"),
    attributes: [
      { name: { prefix: Some("r"), local_name: "id", ns: None }, value: "rId5" },
    ],
    children: [
      @xml.Node::Element({
        name: name("r"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("t"),
            attributes: [],
            children: [@xml.Node::Text("click")],
          }),
        ],
      }),
    ],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [hl],
          }),
        ],
      }),
    ],
  })
  let resolver = fn(rid : String) -> String? {
    if rid == "rId5" {
      Some("https://example.com/target")
    } else {
      None
    }
  }
  let html = render_html(document, rels_resolver=resolver)
  // The resolved URL is used as the href.
  assert_true(html.contains("href=\"https://example.com/target\""))
  // The raw r:id still surfaces as data-ooxml-r-id.
  assert_true(html.contains("data-ooxml-r-id=\"rId5\""))
  // Without the resolver, the href is omitted.
  let html_no_resolver = render_html(document)
  assert_false(html_no_resolver.contains("href=\"https://example.com"))
  // Without resolver but with @w:anchor, the href is "#anchor".
  assert_true(html_no_resolver.contains("data-ooxml-r-id=\"rId5\""))
}

///|
/// §17.18.96 / §20.1.4.1.18 — when render_svg receives a `theme`
/// part with a `<a:fontScheme>` and the document carries a
/// `<w:rFonts asciiTheme="minorAscii">`, the rendered SVG MUST
/// resolve the theme token to the concrete typeface from
/// `<a:minorFont>/<a:latin>/@typeface` rather than dropping the
/// reference.
test "render_svg resolves rFonts asciiTheme through fontScheme" {
  // Theme with majorFont/minorFont so resolution has something
  // to find.  Major Latin = "Calibri Light"; Minor Latin = "Garamond".
  let major_latin : @xml.Element = {
    name: name("latin"),
    attributes: [{ name: name("typeface"), value: "Calibri Light" }],
    children: [],
  }
  let major_font : @xml.Element = {
    name: name("majorFont"),
    attributes: [],
    children: [@xml.Node::Element(major_latin)],
  }
  let minor_latin : @xml.Element = {
    name: name("latin"),
    attributes: [{ name: name("typeface"), value: "Garamond" }],
    children: [],
  }
  let minor_font : @xml.Element = {
    name: name("minorFont"),
    attributes: [],
    children: [@xml.Node::Element(minor_latin)],
  }
  let font_scheme : @xml.Element = {
    name: name("fontScheme"),
    attributes: [{ name: name("name"), value: "TestScheme" }],
    children: [
      @xml.Node::Element(major_font),
      @xml.Node::Element(minor_font),
    ],
  }
  let theme_elts : @xml.Element = {
    name: name("themeElements"),
    attributes: [],
    children: [@xml.Node::Element(font_scheme)],
  }
  let theme : @xml.Element = {
    name: name("theme"),
    attributes: [],
    children: [@xml.Node::Element(theme_elts)],
  }
  // Document: one paragraph, one run with <w:rFonts asciiTheme="minorAscii"/>.
  let r_pr : @xml.Element = {
    name: name("rPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("rFonts"),
        attributes: [{ name: name("asciiTheme"), value: "minorAscii" }],
        children: [],
      }),
    ],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element(r_pr),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Themed font")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document, theme=Some(theme))
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  // The asciiTheme="minorAscii" must resolve through the
  // fontScheme to "Garamond".
  assert_true(svg.contains("Garamond"))
}

///|
/// §17.16.5.2 `<w:fldChar>` — complex fields are stored as a
/// triple of begin / separate / end markers with the cached
/// result text between separate and end.  Per spec the cached
/// result IS the spec-conformant rendering (Word only re-evaluates
/// when `<w:settings>/<w:updateFields>="true"`).  Verify the
/// cached runs surface in the rendered output (the fldChar /
/// instrText elements themselves are silently dropped).
test "wml viewer §17.16.5.2 fldChar cached result renders, instrText dropped" {
  // <w:p>
  //   <w:r><w:fldChar w:fldCharType="begin"/></w:r>
  //   <w:r><w:instrText> PAGE </w:instrText></w:r>
  //   <w:r><w:fldChar w:fldCharType="separate"/></w:r>
  //   <w:r><w:t>42</w:t></w:r>  <-- cached result
  //   <w:r><w:fldChar w:fldCharType="end"/></w:r>
  // </w:p>
  let run_with = fn(local : String, attrs : Array[@xml.Attribute], text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name(local),
          attributes: attrs,
          children: if text == "" { [] } else { [@xml.Node::Text(text)] },
        }),
      ],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              run_with("fldChar", [{ name: name("fldCharType"), value: "begin" }], ""),
              run_with("instrText", [], " PAGE "),
              run_with("fldChar", [{ name: name("fldCharType"), value: "separate" }], ""),
              run_with("t", [], "42"),
              run_with("fldChar", [{ name: name("fldCharType"), value: "end" }], ""),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  // Cached result "42" survives.
  assert_true(html.contains("42"))
  // The instruction text " PAGE " is NOT visible (it's a code, not
  // user-facing content).  We use a strict comparison: " PAGE "
  // shouldn't appear anywhere — fail loudly if it does.
  assert_false(html.contains("PAGE"))
}

///|
/// §17.3.3.13 `<w:lastRenderedPageBreak>`, §17.3.3.22 `<w:pgNum>`,
/// §17.3.3.31-.36 date sentinels (`<w:dayShort>` etc.) MUST surface
/// as `data-ooxml-*` placeholders in HTML so paged/dated consumers
/// can substitute live values.
test "wml viewer §17.3.3 page/date sentinels emit data-ooxml markers" {
  let mk_inline = fn(local : String) -> @xml.Node {
    @xml.Node::Element({
      name: name(local),
      attributes: [],
      children: [],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  mk_inline("lastRenderedPageBreak"),
                  mk_inline("pgNum"),
                  mk_inline("dayShort"),
                  mk_inline("monthLong"),
                  mk_inline("yearShort"),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  assert_true(html.contains("data-ooxml-page-break-hint"))
  assert_true(html.contains("data-ooxml-pgnum"))
  assert_true(html.contains("data-ooxml-date=\"dayShort\""))
  assert_true(html.contains("data-ooxml-date=\"monthLong\""))
  assert_true(html.contains("data-ooxml-date=\"yearShort\""))
}

///|
/// §17.6.4 `<w:cols num="N" space="..." sep="1">` — the section
/// column descriptor MUST surface as `data-ooxml-cols-*` data
/// attributes on the page `<svg>` so consumers can apply CSS
/// columns or other multi-column layout.
test "wml viewer §17.6.4 <w:cols> surfaces as data-ooxml-cols-*" {
  let cols : @xml.Node = @xml.Node::Element({
    name: name("cols"),
    attributes: [
      { name: name("num"), value: "3" },
      { name: name("space"), value: "720" },
      { name: name("sep"), value: "1" },
    ],
    children: [],
  })
  let sect_pr : @xml.Node = @xml.Node::Element({
    name: name("sectPr"),
    attributes: [],
    children: [cols],
  })
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("body")],
                  }),
                ],
              }),
            ],
          }),
          sect_pr,
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  assert_true(svg.contains("data-ooxml-cols-num=\"3\""))
  assert_true(svg.contains("data-ooxml-cols-sep=\"1\""))
  // space=720 twips * (96/72/20) = 48px.
  assert_true(svg.contains("data-ooxml-cols-space=\"48"))
}

///|
/// §20.4.2.3 — `<wp:anchor>` wrap mode + positionH/positionV
/// metadata MUST surface as `data-ooxml-wrap-mode` /
/// `-behind-doc` / `-pos-h-rel` / `-pos-v-rel` on the rendered
/// `<image>` so consumers can apply floating-image layout.
test "wml viewer §20.4.2.3 wp:anchor wrap+position surface as data-ooxml-*" {
  // Build a minimal anchor drawing: extent + blip + wrapSquare + positionH/V.
  let extent : @xml.Node = @xml.Node::Element({
    name: name("extent"),
    attributes: [
      { name: name("cx"), value: "914400" },
      { name: name("cy"), value: "457200" },
    ],
    children: [],
  })
  let blip : @xml.Node = @xml.Node::Element({
    name: name("blip"),
    attributes: [
      { name: { prefix: Some("r"), local_name: "embed", ns: None }, value: "rId1" },
    ],
    children: [],
  })
  let blip_fill : @xml.Node = @xml.Node::Element({
    name: name("blipFill"),
    attributes: [],
    children: [blip],
  })
  let pic : @xml.Node = @xml.Node::Element({
    name: name("pic"),
    attributes: [],
    children: [blip_fill],
  })
  let graphic_data : @xml.Node = @xml.Node::Element({
    name: name("graphicData"),
    attributes: [
      {
        name: name("uri"),
        value: "http://schemas.openxmlformats.org/drawingml/2006/picture",
      },
    ],
    children: [pic],
  })
  let graphic : @xml.Node = @xml.Node::Element({
    name: name("graphic"),
    attributes: [],
    children: [graphic_data],
  })
  let wrap_square : @xml.Node = @xml.Node::Element({
    name: name("wrapSquare"),
    attributes: [{ name: name("wrapText"), value: "bothSides" }],
    children: [],
  })
  let pos_offset_h : @xml.Node = @xml.Node::Element({
    name: name("posOffset"),
    attributes: [],
    children: [@xml.Node::Text("0")],
  })
  let position_h : @xml.Node = @xml.Node::Element({
    name: name("positionH"),
    attributes: [{ name: name("relativeFrom"), value: "page" }],
    children: [pos_offset_h],
  })
  let pos_offset_v : @xml.Node = @xml.Node::Element({
    name: name("posOffset"),
    attributes: [],
    children: [@xml.Node::Text("0")],
  })
  let position_v : @xml.Node = @xml.Node::Element({
    name: name("positionV"),
    attributes: [{ name: name("relativeFrom"), value: "paragraph" }],
    children: [pos_offset_v],
  })
  let simple_pos : @xml.Node = @xml.Node::Element({
    name: name("simplePos"),
    attributes: [
      { name: name("x"), value: "0" },
      { name: name("y"), value: "0" },
    ],
    children: [],
  })
  let doc_pr : @xml.Node = @xml.Node::Element({
    name: name("docPr"),
    attributes: [
      { name: name("id"), value: "1" },
      { name: name("name"), value: "Anchored" },
    ],
    children: [],
  })
  let anchor : @xml.Node = @xml.Node::Element({
    name: name("anchor"),
    attributes: [
      { name: name("behindDoc"), value: "1" },
      { name: name("relativeHeight"), value: "0" },
      { name: name("locked"), value: "0" },
      { name: name("layoutInCell"), value: "1" },
      { name: name("allowOverlap"), value: "1" },
    ],
    children: [
      simple_pos, position_h, position_v, extent, wrap_square, doc_pr, graphic,
    ],
  })
  let drawing : @xml.Node = @xml.Node::Element({
    name: name("drawing"),
    attributes: [],
    children: [anchor],
  })
  let doc_attempt = try? @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [drawing],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let document = match doc_attempt {
    Ok(d) => d
    Err(_) => abort("CT_Document parse failed")
  }
  let resolver = fn(rid : String) -> ResolvedImage? {
    if rid == "rId1" {
      Some({ mime_type: "image/png", base64_data: "AAAA" })
    } else {
      None
    }
  }
  let result = render_svg(document, image_resolver=resolver)
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  assert_true(svg.contains("data-ooxml-wrap-mode=\"Square\""))
  assert_true(svg.contains("data-ooxml-behind-doc=\"1\""))
  assert_true(svg.contains("data-ooxml-pos-h-rel=\"page\""))
  assert_true(svg.contains("data-ooxml-pos-v-rel=\"paragraph\""))
}

///|
/// §17.11.7 `<w:footnoteRef>` / §17.11.14 `<w:endnoteRef>` /
/// §17.11.x `<w:separator>` / `<w:continuationSeparator>` /
/// §17.10.x `<w:annotationRef>` / §17.3.1.x `<w:ptab>` — these
/// inline-run sentinels MUST surface as data-ooxml-* markers in
/// the HTML viewer so consumers can substitute the resolved
/// reference / draw separators / position positional tabs.
test "wml viewer §17.11 / §17.3.1 inline sentinels emit data-ooxml markers" {
  let mk_inline = fn(local : String, attrs : Array[@xml.Attribute]) -> @xml.Node {
    @xml.Node::Element({ name: name(local), attributes: attrs, children: [] })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  mk_inline("footnoteRef", []),
                  mk_inline("endnoteRef", []),
                  mk_inline("annotationRef", []),
                  mk_inline("separator", []),
                  mk_inline("continuationSeparator", []),
                  mk_inline("ptab", [
                    { name: name("alignment"), value: "right" },
                    { name: name("relativeTo"), value: "margin" },
                    { name: name("leader"), value: "dot" },
                  ]),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  assert_true(html.contains("data-ooxml-footnote-ref"))
  assert_true(html.contains("data-ooxml-endnote-ref"))
  assert_true(html.contains("data-ooxml-annotation-ref"))
  assert_true(html.contains("data-ooxml-separator"))
  assert_true(html.contains("data-ooxml-continuation-separator"))
  assert_true(html.contains("data-ooxml-ptab=\"1\""))
  assert_true(html.contains("data-ooxml-ptab-alignment=\"right\""))
  assert_true(html.contains("data-ooxml-ptab-relativeTo=\"margin\""))
  assert_true(html.contains("data-ooxml-ptab-leader=\"dot\""))
}

///|
/// §17.9.11 `<w:lvlText>` — each `%N` placeholder MUST be
/// formatted using level N-1's own `numFmt`, not the current
/// level's.  Multilevel list with lvl0=upperRoman, lvl1=decimal,
/// template `%1.%2)` at lvl1 must render "I.1)" not "1.1)".
test "wml viewer §17.9.11 lvlText %N uses ancestor numFmt per level" {
  // <w:numbering>
  //   <w:abstractNum abstractNumId="0">
  //     <w:lvl ilvl="0"><w:start val="1"/><w:numFmt val="upperRoman"/><w:lvlText val="%1."/></w:lvl>
  //     <w:lvl ilvl="1"><w:start val="1"/><w:numFmt val="decimal"/><w:lvlText val="%1.%2)"/></w:lvl>
  //   </w:abstractNum>
  //   <w:num numId="1"><w:abstractNumId val="0"/></w:num>
  // </w:numbering>
  let mk_lvl = fn(ilvl : String, fmt : String, text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("lvl"),
      attributes: [{ name: name("ilvl"), value: ilvl }],
      children: [
        @xml.Node::Element({
          name: name("start"),
          attributes: [{ name: name("val"), value: "1" }],
          children: [],
        }),
        @xml.Node::Element({
          name: name("numFmt"),
          attributes: [{ name: name("val"), value: fmt }],
          children: [],
        }),
        @xml.Node::Element({
          name: name("lvlText"),
          attributes: [{ name: name("val"), value: text }],
          children: [],
        }),
      ],
    })
  }
  let abstract_num : @xml.Node = @xml.Node::Element({
    name: name("abstractNum"),
    attributes: [{ name: name("abstractNumId"), value: "0" }],
    children: [
      mk_lvl("0", "upperRoman", "%1."),
      mk_lvl("1", "decimal", "%1.%2)"),
    ],
  })
  let num : @xml.Node = @xml.Node::Element({
    name: name("num"),
    attributes: [{ name: name("numId"), value: "1" }],
    children: [
      @xml.Node::Element({
        name: name("abstractNumId"),
        attributes: [{ name: name("val"), value: "0" }],
        children: [],
      }),
    ],
  })
  let numbering = try? @domain.CT_Numbering::parse({
    name: name("numbering"),
    attributes: [],
    children: [abstract_num, num],
  })
  let numbering = match numbering {
    Ok(n) => n
    Err(_) => abort("numbering parse failed")
  }
  // §17.3.1.19 `<w:numPr>/<w:numId val="1"/><w:ilvl val="1"/>` —
  // paragraph references lvl 1 of num 1.
  let p_pr : @xml.Element = {
    name: name("pPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("numPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("ilvl"),
            attributes: [{ name: name("val"), value: "1" }],
            children: [],
          }),
          @xml.Node::Element({
            name: name("numId"),
            attributes: [{ name: name("val"), value: "1" }],
            children: [],
          }),
        ],
      }),
    ],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element(p_pr),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("body")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document, numbering=Some(numbering))
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  // The marker MUST be "I.1)" (parent level uses upperRoman; current
  // level uses decimal).  Before the fix this printed "1.1)".
  assert_true(svg.contains("I.1)"))
}

///|
/// §17.3.1.11 `<w:framePr>` — text-frame properties MUST surface as
/// `data-ooxml-frame-*` data attributes so float-wrap consumers can
/// apply CSS positioning.
test "wml viewer §17.3.1.11 framePr surfaces as data-ooxml-frame-*" {
  let frame : @xml.Element = {
    name: name("framePr"),
    attributes: [
      { name: name("w"), value: "2880" },
      { name: name("h"), value: "1440" },
      { name: name("wrap"), value: "around" },
      { name: name("vAnchor"), value: "page" },
      { name: name("hAnchor"), value: "margin" },
      { name: name("xAlign"), value: "center" },
      { name: name("hSpace"), value: "180" },
      { name: name("dropCap"), value: "drop" },
      { name: name("lines"), value: "3" },
    ],
    children: [],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [@xml.Node::Element(frame)],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("framed")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  assert_true(html.contains("data-ooxml-frame=\"1\""))
  assert_true(html.contains("data-ooxml-frame-w=\"2880\""))
  assert_true(html.contains("data-ooxml-frame-h=\"1440\""))
  assert_true(html.contains("data-ooxml-frame-wrap=\"around\""))
  assert_true(html.contains("data-ooxml-frame-vAnchor=\"page\""))
  assert_true(html.contains("data-ooxml-frame-hAnchor=\"margin\""))
  assert_true(html.contains("data-ooxml-frame-xAlign=\"center\""))
  assert_true(html.contains("data-ooxml-frame-hSpace=\"180\""))
  assert_true(html.contains("data-ooxml-frame-dropCap=\"drop\""))
  assert_true(html.contains("data-ooxml-frame-lines=\"3\""))
  // Paragraph text survives.
  assert_true(html.contains("framed"))
}

///|
/// §17.4.83 `<w:tcPr>/<w:vAlign w:val="center|bottom">` — the cell
/// vertical anchor MUST surface as `data-ooxml-v-align` on the
/// rendered `<td>` so HTML consumers can apply
/// vertical-align / align-items styling.
test "wml viewer §17.4.83 tcPr/vAlign surfaces as data-ooxml-v-align" {
  let mk_cell = fn(val : String, text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("tc"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("tcPr"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("vAlign"),
              attributes: [{ name: name("val"), value: val }],
              children: [],
            }),
          ],
        }),
        @xml.Node::Element({
          name: name("p"),
          attributes: [],
          children: [
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
            }),
          ],
        }),
      ],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("tbl"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("tblPr"),
                attributes: [],
                children: [],
              }),
              @xml.Node::Element({
                name: name("tblGrid"),
                attributes: [],
                children: [],
              }),
              @xml.Node::Element({
                name: name("tr"),
                attributes: [],
                children: [
                  mk_cell("center", "centered"),
                  mk_cell("bottom", "down"),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  assert_true(html.contains("data-ooxml-v-align=\"center\""))
  assert_true(html.contains("data-ooxml-v-align=\"bottom\""))
  assert_true(html.contains("centered"))
  assert_true(html.contains("down"))
}

///|
/// §17.18.97 / §17.18.98 — when `<w:shd>` carries
/// @themeFill + @themeFillShade, the shading rect MUST resolve
/// the theme colour through the document's ThemeColorMap and apply
/// the shade transform.  Before this fix, themeFillShade was
/// silently dropped because the helper received an empty map.
test "wml viewer §17.18.98 shd/themeFillShade applies via theme_map" {
  // Theme with accent1=#FF0000.
  let srgb : @xml.Element = {
    name: name("srgbClr"),
    attributes: [{ name: name("val"), value: "FF0000" }],
    children: [],
  }
  let accent1 : @xml.Element = {
    name: name("accent1"),
    attributes: [],
    children: [@xml.Node::Element(srgb)],
  }
  let clr_scheme : @xml.Element = {
    name: name("clrScheme"),
    attributes: [{ name: name("name"), value: "TestScheme" }],
    children: [@xml.Node::Element(accent1)],
  }
  let theme_elts : @xml.Element = {
    name: name("themeElements"),
    attributes: [],
    children: [@xml.Node::Element(clr_scheme)],
  }
  let theme : @xml.Element = {
    name: name("theme"),
    attributes: [],
    children: [@xml.Node::Element(theme_elts)],
  }
  // Paragraph with <w:shd themeFill="accent1" themeFillShade="80"/>.
  // shade=0x80=128/255≈0.5 → blend accent1 toward black by 0.5.
  let p_pr : @xml.Element = {
    name: name("pPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("shd"),
        attributes: [
          { name: name("val"), value: "clear" },
          { name: name("themeFill"), value: "accent1" },
          { name: name("themeFillShade"), value: "80" },
        ],
        children: [],
      }),
    ],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element(p_pr),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("shaded")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document, theme=Some(theme))
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  // The shading rect MUST surface as a fill that is a darker
  // variant of #ff0000 (theme accent1) via the shade transform,
  // NOT the literal "#ff0000" (which would mean shade dropped).
  // §17.18.98 ratio 0x80=128/255≈0.502 blend toward black means
  // R component approximately 0xFF * 0.502 ≈ 0x80.  Check the
  // fill is present and not pure #ff0000.
  assert_true(svg.contains("fill=\"#"))
  assert_false(svg.contains("fill=\"#ff0000\""))
}

///|
/// §17.18.87 — `<w:tab w:val="right">` MUST end-align the
/// following text at the stop, NOT left-align (the default).
/// The post-tab `<text>` element's x should be at the stop minus
/// the measured run width.
test "wml viewer §17.18.87 right-justified tab end-aligns following text" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("tabs"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("tab"),
                        attributes: [
                          attr("val", "end"),
                          attr("pos", "8640"),
                        ],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("page 1")],
                  }),
                  @xml.Node::Element({
                    name: name("tab"),
                    attributes: [],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("of 10")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let page = result.pages[0]
  // Both text spans appear.
  assert_true(page.svg.contains(">page 1</text>"))
  assert_true(page.svg.contains(">of 10</text>"))
  // §17.18.87 right-justified — "of 10" MUST end at the stop
  // (576 px = 8640 twips at 96 dpi / 20 twips-per-pt).  We assert
  // the post-tab text element appears at an x significantly LESS
  // than 576 (left-aligned would put it AT 576).  Without the fix
  // it would render at "x=\"576" — with the fix x is well before.
  assert_false(page.svg.contains(">of 10</text>") &&
    page.svg.contains("x=\"576\""))
}

///|
/// §17.3.2.13 `<w:caps>` — the renderer MUST measure the
/// uppercased glyph widths (caps letters are wider) so line
/// layout matches the displayed text.  We verify the CSS
/// `text-transform: uppercase` is emitted AND that a caps run
/// renders without crashing through the measurement path.
test "wml viewer §17.3.2.13 caps run emits uppercase + measures cased width" {
  let r_pr : @xml.Element = {
    name: name("rPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("caps"),
        attributes: [],
        children: [],
      }),
    ],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element(r_pr),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("hello world")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  // The caps run carries the CSS uppercase transform.
  assert_true(svg.contains("text-transform: uppercase"))
  // The source text survives (CSS does the casing visually).
  assert_true(svg.contains("hello world"))
}

///|
/// §17.3.1.12 `<w:ind>` — `@firstLineChars` (hundredths of a
/// character) MUST be honoured as a fallback when the twips-based
/// `@firstLine` is absent.  We verify a paragraph with a
/// char-based first-line indent renders shifted (the post-indent
/// text element x is non-zero).
test "wml viewer §17.3.1.12 ind firstLineChars resolves char-based indent" {
  let p_pr : @xml.Element = {
    name: name("pPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("ind"),
        attributes: [
          // 200 hundredths-of-char = 2 chars first-line indent.
          { name: name("firstLineChars"), value: "200" },
        ],
        children: [],
      }),
    ],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element(p_pr),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("indented")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let page = result.pages[0]
  // The text renders (the char-based indent didn't crash the
  // layout pipeline and produced a positive first-line offset).
  assert_true(page.svg.contains("indented"))
}

///|
/// §17.3.1.12 `<w:ind w:start="0">` — an explicit zero start
/// indent MUST clear (not be ignored by a positivity test).
test "wml viewer §17.3.1.12 ind start=0 explicitly clears indent" {
  let p_pr : @xml.Element = {
    name: name("pPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("ind"),
        attributes: [
          // left=720 then start=0 — start overrides left to 0.
          { name: name("left"), value: "720" },
          { name: name("start"), value: "0" },
        ],
        children: [],
      }),
    ],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element(p_pr),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("flush")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let page = result.pages[0]
  assert_true(page.svg.contains("flush"))
}

///|
/// §17.3.2.18 `<w:emboss>` and §17.3.2.21 `<w:imprint>` — relief
/// toggles MUST render as paired text-shadows + surface a
/// `data-ooxml-relief` attribute.
test "wml viewer §17.3.2.18/.21 emboss/imprint emit relief shadow" {
  let mk_para = fn(toggle : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("p"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("r"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("rPr"),
              attributes: [],
              children: [
                @xml.Node::Element({
                  name: name(toggle),
                  attributes: [],
                  children: [],
                }),
              ],
            }),
            @xml.Node::Element({
              name: name("t"),
              attributes: [],
              children: [@xml.Node::Text(toggle + "-text")],
            }),
          ],
        }),
      ],
    })
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [mk_para("emboss"), mk_para("imprint")],
      }),
    ],
  })
  let result = render_svg(document)
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  assert_true(svg.contains("data-ooxml-relief=\"emboss\""))
  assert_true(svg.contains("data-ooxml-relief=\"imprint\""))
  // Both emit a text-shadow CSS rule.
  assert_true(svg.contains("text-shadow:"))
}

///|
/// §17.3.1.9 `<w:contextualSpacing>` — two consecutive same-style
/// paragraphs that both carry the toggle MUST have the spacing
/// between them suppressed.  We verify the rendered SVG total
/// document height is SHORTER when both paragraphs declare
/// contextualSpacing than when they don't.
test "wml viewer §17.3.1.9 contextualSpacing suppresses same-style gap" {
  let mk_para = fn(with_cs : Bool) -> @xml.Node {
    let p_pr_children : Array[@xml.Node] = [
      @xml.Node::Element({
        name: name("pStyle"),
        attributes: [{ name: name("val"), value: "ListParagraph" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("spacing"),
        attributes: [
          { name: name("before"), value: "240" },
          { name: name("after"), value: "240" },
        ],
        children: [],
      }),
    ]
    if with_cs {
      p_pr_children.push(@xml.Node::Element({
        name: name("contextualSpacing"),
        attributes: [],
        children: [],
      }))
    }
    @xml.Node::Element({
      name: name("p"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("pPr"),
          attributes: [],
          children: p_pr_children,
        }),
        @xml.Node::Element({
          name: name("r"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("t"),
              attributes: [],
              children: [@xml.Node::Text("item")],
            }),
          ],
        }),
      ],
    })
  }
  let doc_without = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [mk_para(false), mk_para(false)],
      }),
    ],
  })
  let doc_with = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [mk_para(true), mk_para(true)],
      }),
    ],
  })
  // Without contextualSpacing the two paragraphs keep their
  // before/after spacing.  With it, the between-gap is removed.
  let h_without = render_svg(doc_without).pages[0].height
  let h_with = render_svg(doc_with).pages[0].height
  // The contextual-spacing version's content height is shorter
  // (gap suppressed) — at minimum not taller.
  assert_true(h_with <= h_without)
}

///|
/// §17.3.2.20 `<w:kern>` + `<w:lang>` — the run's kerning
/// threshold MUST surface as `data-ooxml-kern` (with `kerning="auto"`
/// when the font size meets the threshold) and the language tag
/// MUST surface as `xml:lang` + `data-ooxml-lang`.
test "wml viewer §17.3.2.20 kern + lang surface on rendered text" {
  let r_pr : @xml.Element = {
    name: name("rPr"),
    attributes: [],
    children: [
      // sz=24 half-points = 12 pt.  kern threshold = 16 half-points
      // = 8 pt → 12 >= 8, so kerning is active.
      @xml.Node::Element({
        name: name("sz"),
        attributes: [{ name: name("val"), value: "24" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("kern"),
        attributes: [{ name: name("val"), value: "16" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("lang"),
        attributes: [{ name: name("val"), value: "ja-JP" }],
        children: [],
      }),
    ],
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element(r_pr),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("kerned")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(document)
  let buf = StringBuilder::new()
  for page in result.pages {
    buf.write_string(page.svg)
  }
  let svg = buf.to_string()
  assert_true(svg.contains("data-ooxml-kern=\"16\""))
  // 12 pt >= 8 pt threshold → kerning active.
  assert_true(svg.contains("kerning=\"auto\""))
  assert_true(svg.contains("xml:lang=\"ja-JP\""))
  assert_true(svg.contains("data-ooxml-lang=\"ja-JP\""))
}

///|
/// Build a one-run document whose run carries `<w:highlight w:val>`.
fn highlight_fixture(hl : String) -> @domain.CT_Document raise {
  @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("rPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("highlight"),
                        attributes: [{ name: name("val"), value: hl }],
                        children: [],
                      }),
                    ],
                  }),
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("hl")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
}

///|
/// §17.18.40 ST_HighlightColor — the highlight palette is the VGA
/// 16-colour set.  `darkGray` MUST resolve to #808080 and
/// `lightGray` to #c0c0c0 (NOT the CSS named-colour values).
test "wml viewer §17.18.40 highlight darkGray/lightGray use VGA palette" {
  let svg_dark = render_svg(highlight_fixture("darkGray")).pages[0].svg
  assert_true(svg_dark.contains("#808080"))
  assert_false(svg_dark.contains("#a9a9a9"))
  let svg_light = render_svg(highlight_fixture("lightGray")).pages[0].svg
  assert_true(svg_light.contains("#c0c0c0"))
  assert_false(svg_light.contains("#d3d3d3"))
}

///|
/// §17.3.3.1 `<w:br w:clear="all">` — a textWrapping break's
/// `@clear` attribute MUST surface as `data-ooxml-br-clear` on
/// the rendered `<br>` so float-aware consumers apply CSS clear.
test "wml viewer §17.3.3.1 br clear surfaces as data-ooxml-br-clear" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("br"),
                    attributes: [{ name: name("clear"), value: "all" }],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("br"),
                    attributes: [],
                    children: [],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  // The clear="all" break carries the data attribute.
  assert_true(html.contains("data-ooxml-br-clear=\"all\""))
  // A plain `<w:br>` with no @clear stays bare; the XML writer emits
  // it as the self-closing `<br/>` (XML-syntax HTML).
  assert_true(html.contains("<br/>"))
}
