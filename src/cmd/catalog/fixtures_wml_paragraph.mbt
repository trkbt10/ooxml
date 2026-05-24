// WML paragraph-level fixtures — `<w:pPr>` properties and layouts.
// See `fixtures_wml_run.mbt` for the editing convention.
//
// These extras exercise ECMA-376 §17.3.1 paragraph properties that
// are not covered by the original block in `fixtures.mbt`
// (paragraph-alignment, paragraph-wrapping, paragraph-indent,
// paragraph-tabs, paragraph-shading, paragraph-border,
// paragraph-spacing, etc.).  Each fixture isolates one §17.3.1
// property family so a render regression points at a single feature.

///|
fn extras_wml_paragraph(cases : Array[VisualCase]) -> Unit {
  // Multi-attribute element helpers — kept local so they can read
  // the `NS_W` constant via lexical scope without redeclaring it.
  let w_attr = fn(localn : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name: localn, ns: Some(NS_W) }, value }
  }
  let ppr = fn(children : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in children {
      kids.push(Element(c))
    }
    xe(NS_W, "pPr", [], kids)
  }
  // `<w:ind>` with arbitrary indentation attributes (left, right,
  // firstLine, hanging, start, end).
  let ind = fn(pairs : Array[(String, String)]) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = []
    for p in pairs {
      attrs.push(w_attr(p.0, p.1))
    }
    xe(NS_W, "ind", attrs, [])
  }
  // `<w:spacing>` with arbitrary spacing attributes (before, after,
  // line, lineRule, beforeLines, afterLines).
  let spacing = fn(pairs : Array[(String, String)]) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = []
    for p in pairs {
      attrs.push(w_attr(p.0, p.1))
    }
    xe(NS_W, "spacing", attrs, [])
  }
  // `<w:pBdr>` side helper — single line, given size/space/color.
  let bdr_side = fn(
    side : String,
    val : String,
    sz : String,
    color : String,
  ) -> @xml.Element {
    xe(
      NS_W,
      side,
      [
        w_attr("val", val),
        w_attr("sz", sz),
        w_attr("space", "4"),
        w_attr("color", color),
      ],
      [],
    )
  }
  // `<w:numPr>` with explicit ilvl + numId, for nested-list
  // demonstrations (note: without a real `numbering.xml` this only
  // exercises the layout/indent path, not the bullet glyph).
  let numpr = fn(ilvl : String, numid : String) -> @xml.Element {
    xe(NS_W, "numPr", [], [
      Element(xe(NS_W, "ilvl", [w_attr("val", ilvl)], [])),
      Element(xe(NS_W, "numId", [w_attr("val", numid)], [])),
    ])
  }
  // Explicit tab stop `<w:tab w:val=… w:pos=… w:leader=…/>` inside a
  // `<w:tabs>` element.
  let tab_stop = fn(
    val : String,
    pos : String,
    leader : String?,
  ) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = [w_attr("val", val), w_attr("pos", pos)]
    match leader {
      Some(l) => attrs.push(w_attr("leader", l))
      None => ()
    }
    xe(NS_W, "tab", attrs, [])
  }
  // `<w:r><w:tab/></w:r>` — an embedded tab character in run content.
  let tab_run = xe(NS_W, "r", [], [Element(xe(NS_W, "tab", [], []))])

  // ---- §17.3.1.14 keepNext --------------------------------------
  cases.push({
    id: "paragraph-keepnext",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([xe(NS_W, "keepNext", [], []), w_val("jc", "start")])), [
          w_run(
            Some(w_rpr([w_flag("b"), w_val("sz", "28")])),
            "Heading kept with next",
          ),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(
            None,
            "Body paragraph that must stay on the same page as the " +
            "heading above thanks to the keepNext setting.",
          ),
        ]),
      ),
    ]),
  })

  // ---- §17.3.1.15 keepLines -------------------------------------
  cases.push({
    id: "paragraph-keeplines",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([xe(NS_W, "keepLines", [], [])])), [
          w_run(
            None,
            "All the wrapped lines of this paragraph stay together " +
            "on a single page; the renderer must not split the " +
            "paragraph across a page break even when the surrounding " +
            "content would naturally wrap.",
          ),
        ]),
      ),
    ]),
  })

  // ---- §17.3.1.23 pageBreakBefore -------------------------------
  cases.push({
    id: "paragraph-pagebreak-before",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Paragraph on the first page.")])),
      Element(
        w_p(Some(ppr([xe(NS_W, "pageBreakBefore", [], [])])), [
          w_run(
            Some(w_rpr([w_flag("b"), w_val("sz", "32")])),
            "This heading starts a new page",
          ),
        ]),
      ),
      Element(
        w_p(None, [w_run(None, "Following paragraph on the second page.")]),
      ),
    ]),
  })

  // ---- §17.3.1.44 widowControl ----------------------------------
  // Explicit `w:val="false"` disables widow/orphan control.  Effect
  // is visually subtle but the property must parse cleanly.
  cases.push({
    id: "paragraph-widow-control-off",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(ppr([xe(NS_W, "widowControl", [w_attr("val", "false")], [])])),
          [
            w_run(
              None,
              "This paragraph disables widow/orphan control so single " +
              "trailing or leading lines may be stranded across page " +
              "breaks without the layout engine intervening.",
            ),
          ],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.34 suppressLineNumbers ---------------------------
  cases.push({
    id: "paragraph-suppress-linenumbers",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([xe(NS_W, "suppressLineNumbers", [], [])])), [
          w_run(
            None,
            "Paragraph that opts out of line numbering even when " +
            "the surrounding section enables it.",
          ),
        ]),
      ),
    ]),
  })

  // ---- §17.3.1.9 contextualSpacing ------------------------------
  // Two consecutive paragraphs with contextualSpacing collapse the
  // before/after spacing between them.  Render against a pair WITHOUT
  // the flag (above) to see the difference.
  cases.push({
    id: "paragraph-contextual-spacing",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "contextualSpacing", [], []),
              spacing([("before", "240"), ("after", "240")]),
            ]),
          ),
          [
            w_run(
              None,
              "First contextual-spacing paragraph (12pt before/after).",
            ),
          ],
        ),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "contextualSpacing", [], []),
              spacing([("before", "240"), ("after", "240")]),
            ]),
          ),
          [
            w_run(
              None,
              "Second contextual-spacing paragraph — the spacing " +
              "between this and the previous paragraph should collapse " +
              "even though both request 12pt before/after.",
            ),
          ],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.39 textAlignment (vertical) ----------------------
  // `<w:textAlignment val="top|center|baseline|bottom"/>` aligns
  // glyphs of mixed sizes vertically within the line box.
  cases.push({
    id: "paragraph-textalign-top",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([w_val("textAlignment", "top")])), [
          w_run(Some(w_rpr([w_val("sz", "16")])), "small "),
          w_run(Some(w_rpr([w_val("sz", "48")])), "BIG"),
          w_run(Some(w_rpr([w_val("sz", "16")])), " small (top-aligned)"),
        ]),
      ),
    ]),
  })
  cases.push({
    id: "paragraph-textalign-center",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([w_val("textAlignment", "center")])), [
          w_run(Some(w_rpr([w_val("sz", "16")])), "small "),
          w_run(Some(w_rpr([w_val("sz", "48")])), "BIG"),
          w_run(Some(w_rpr([w_val("sz", "16")])), " small (center)"),
        ]),
      ),
    ]),
  })
  cases.push({
    id: "paragraph-textalign-bottom",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([w_val("textAlignment", "bottom")])), [
          w_run(Some(w_rpr([w_val("sz", "16")])), "small "),
          w_run(Some(w_rpr([w_val("sz", "48")])), "BIG"),
          w_run(Some(w_rpr([w_val("sz", "16")])), " small (bottom)"),
        ]),
      ),
    ]),
  })

  // ---- §17.3.1.20 outlineLvl ------------------------------------
  // Outline levels 0-3 — used for TOC generation; visually a marker
  // for heading levels.
  cases.push({
    id: "paragraph-outline-levels",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([w_val("outlineLvl", "0")])), [
          w_run(
            Some(w_rpr([w_flag("b"), w_val("sz", "36")])),
            "Outline level 0 (Heading 1)",
          ),
        ]),
      ),
      Element(
        w_p(Some(ppr([w_val("outlineLvl", "1")])), [
          w_run(
            Some(w_rpr([w_flag("b"), w_val("sz", "28")])),
            "Outline level 1 (Heading 2)",
          ),
        ]),
      ),
      Element(
        w_p(Some(ppr([w_val("outlineLvl", "2")])), [
          w_run(
            Some(w_rpr([w_flag("b"), w_val("sz", "24")])),
            "Outline level 2 (Heading 3)",
          ),
        ]),
      ),
      Element(
        w_p(Some(ppr([w_val("outlineLvl", "3")])), [
          w_run(
            Some(w_rpr([w_flag("b"), w_val("sz", "22")])),
            "Outline level 3 (Heading 4)",
          ),
        ]),
      ),
    ]),
  })

  // ---- §17.3.1.19 numPr — nested list levels --------------------
  // Different `<w:ilvl>` values on the same numId give visually
  // distinct indents.  Without a real numbering definition the
  // bullet glyph is absent but the indent cascade is exercised.
  cases.push({
    id: "paragraph-numpr-nested",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(Some(ppr([numpr("0", "1")])), [w_run(None, "Level 0 entry")])),
      Element(w_p(Some(ppr([numpr("1", "1")])), [w_run(None, "Level 1 entry")])),
      Element(w_p(Some(ppr([numpr("2", "1")])), [w_run(None, "Level 2 entry")])),
      Element(w_p(Some(ppr([numpr("3", "1")])), [w_run(None, "Level 3 entry")])),
      Element(
        w_p(Some(ppr([numpr("0", "1")])), [w_run(None, "Back to level 0")]),
      ),
    ]),
  })

  // ---- §17.3.1.33 spacing — before only -------------------------
  cases.push({
    id: "paragraph-spacing-before-only",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Preceding paragraph.")])),
      Element(
        w_p(Some(ppr([spacing([("before", "480")])])), [
          w_run(None, "24pt before-only spacing on this paragraph."),
        ]),
      ),
      Element(w_p(None, [w_run(None, "Following paragraph.")])),
    ]),
  })

  // ---- §17.3.1.33 spacing — after only --------------------------
  cases.push({
    id: "paragraph-spacing-after-only",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Preceding paragraph.")])),
      Element(
        w_p(Some(ppr([spacing([("after", "480")])])), [
          w_run(None, "24pt after-only spacing on this paragraph."),
        ]),
      ),
      Element(w_p(None, [w_run(None, "Following paragraph.")])),
    ]),
  })

  // ---- §17.3.1.33 spacing — large before/after combination ------
  cases.push({
    id: "paragraph-spacing-large",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "First paragraph.")])),
      Element(
        w_p(Some(ppr([spacing([("before", "720"), ("after", "720")])])), [
          w_run(None, "Middle paragraph with 36pt before and 36pt after."),
        ]),
      ),
      Element(w_p(None, [w_run(None, "Last paragraph.")])),
    ]),
  })

  // ---- §17.3.1.33 spacing — exact line height (240 = 12pt) ------
  cases.push({
    id: "paragraph-line-exact",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([spacing([("line", "480"), ("lineRule", "exact")])])), [
          w_run(
            None,
            "This paragraph uses exact 24-point line height. The " +
            "wrapped lines are pinned to that height regardless of " +
            "the font size, which is useful for tight typographic " +
            "layouts.",
          ),
        ]),
      ),
    ]),
  })

  // ---- §17.3.1.33 spacing — at-least line height ----------------
  cases.push({
    id: "paragraph-line-atleast",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([spacing([("line", "600"), ("lineRule", "atLeast")])])), [
          w_run(
            None,
            "At-least 30pt line height — line box grows beyond 30pt " +
            "if a glyph needs it, but is never smaller. Useful for " +
            "mixing small body text with occasional large glyphs.",
          ),
        ]),
      ),
    ]),
  })

  // ---- §17.3.1.37 tabs — left/center/right/decimal --------------
  cases.push({
    id: "paragraph-tabs-explicit",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("left", "1440", None)),
                Element(tab_stop("center", "3600", None)),
                Element(tab_stop("right", "5760", None)),
                Element(tab_stop("decimal", "7200", None)),
              ]),
            ]),
          ),
          [
            w_run(None, "L"),
            tab_run,
            w_run(None, "Centre"),
            tab_run,
            w_run(None, "Right"),
            tab_run,
            w_run(None, "12.34"),
          ],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.37 tabs — dot leader -----------------------------
  cases.push({
    id: "paragraph-tabs-dot-leader",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("dot"))),
              ]),
            ]),
          ),
          [w_run(None, "Chapter One"), tab_run, w_run(None, "1")],
        ),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("dot"))),
              ]),
            ]),
          ),
          [w_run(None, "Chapter Two"), tab_run, w_run(None, "17")],
        ),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("dot"))),
              ]),
            ]),
          ),
          [w_run(None, "Chapter Three"), tab_run, w_run(None, "42")],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.37 tabs — hyphen and underscore leaders ----------
  cases.push({
    id: "paragraph-tabs-hyphen-leader",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("hyphen"))),
              ]),
            ]),
          ),
          [w_run(None, "Signature"), tab_run, w_run(None, "Date")],
        ),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("underscore"))),
              ]),
            ]),
          ),
          [w_run(None, "Name"), tab_run, w_run(None, "ID")],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.24 pBdr — top border only ------------------------
  cases.push({
    id: "paragraph-border-top-only",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "pBdr", [], [
                Element(bdr_side("top", "single", "12", "000000")),
              ]),
            ]),
          ),
          [w_run(None, "Paragraph with a top border only.")],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.24 pBdr — bottom border only ---------------------
  cases.push({
    id: "paragraph-border-bottom-only",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "pBdr", [], [
                Element(bdr_side("bottom", "single", "12", "000000")),
              ]),
            ]),
          ),
          [w_run(None, "Paragraph with a bottom border only.")],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.24 pBdr — between border on consecutive paragraphs
  cases.push({
    id: "paragraph-border-between",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "pBdr", [], [
                Element(bdr_side("between", "single", "8", "808080")),
              ]),
            ]),
          ),
          [w_run(None, "First paragraph with between-border styling.")],
        ),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "pBdr", [], [
                Element(bdr_side("between", "single", "8", "808080")),
              ]),
            ]),
          ),
          [
            w_run(
              None,
              "Second paragraph — a border should appear between them.",
            ),
          ],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.24 pBdr — bar border on the left ------------------
  cases.push({
    id: "paragraph-border-bar",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "pBdr", [], [
                Element(bdr_side("bar", "single", "18", "2E74B5")),
              ]),
            ]),
          ),
          [
            w_run(
              None,
              "Paragraph with a bar (vertical rule) drawn outside the " +
              "left margin — common for change-bar revision marking.",
            ),
          ],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.24 pBdr — thick double border --------------------
  cases.push({
    id: "paragraph-border-double-thick",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "pBdr", [], [
                Element(bdr_side("top", "double", "24", "C00000")),
                Element(bdr_side("left", "double", "24", "C00000")),
                Element(bdr_side("bottom", "double", "24", "C00000")),
                Element(bdr_side("right", "double", "24", "C00000")),
              ]),
            ]),
          ),
          [w_run(None, "Boxed paragraph with a thick red double border.")],
        ),
      ),
    ]),
  })

  // ---- §17.3.1.41 textDirection — vertical (tbRl) ---------------
  cases.push({
    id: "paragraph-textdir-tbrl",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([w_val("textDirection", "tbRl")])), [
          w_run(None, "Top-to-bottom right-to-left text flow."),
        ]),
      ),
    ]),
  })

  // ---- §17.3.1.41 textDirection — vertical (btLr) ---------------
  cases.push({
    id: "paragraph-textdir-btlr",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([w_val("textDirection", "btLr")])), [
          w_run(None, "Bottom-to-top left-to-right text flow."),
        ]),
      ),
    ]),
  })

  // ---- TOC-style mixed alignment --------------------------------
  // Right-justified TOC-style entries followed by a centered title
  // — exercises consecutive-paragraph alignment changes.
  cases.push({
    id: "paragraph-toc-style",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(ppr([w_val("jc", "center")])), [
          w_run(
            Some(w_rpr([w_flag("b"), w_val("sz", "32")])),
            "Table of Contents",
          ),
        ]),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("dot"))),
              ]),
            ]),
          ),
          [w_run(None, "Introduction"), tab_run, w_run(None, "1")],
        ),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("dot"))),
              ]),
              ind([("left", "360")]),
            ]),
          ),
          [w_run(None, "Background"), tab_run, w_run(None, "3")],
        ),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("dot"))),
              ]),
              ind([("left", "360")]),
            ]),
          ),
          [w_run(None, "Scope"), tab_run, w_run(None, "5")],
        ),
      ),
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("right", "8640", Some("dot"))),
              ]),
            ]),
          ),
          [w_run(None, "Conclusion"), tab_run, w_run(None, "12")],
        ),
      ),
    ]),
  })

  // ---- Mirrored indents (left + right) --------------------------
  // Quotation-style paragraph with symmetric left/right indents,
  // exercising both attributes of `<w:ind>` simultaneously.
  cases.push({
    id: "paragraph-blockquote-indent",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Body before the quotation.")])),
      Element(
        w_p(
          Some(
            ppr([ind([("left", "720"), ("right", "720")]), w_val("jc", "both")]),
          ),
          [
            w_run(
              Some(w_rpr([w_flag("i")])),
              "This block-quoted paragraph is inset from both the left " +
              "and right margins so the wrapped text forms a visibly " +
              "narrower column than the surrounding body text.",
            ),
          ],
        ),
      ),
      Element(w_p(None, [w_run(None, "Body after the quotation.")])),
    ]),
  })
}
