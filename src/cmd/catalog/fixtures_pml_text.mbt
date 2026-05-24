// PresentationML text-frame fixtures — txBody, paragraphs, runs,
// alignment, bullets.  Each fixture isolates one ECMA-376 §21.1
// text-frame feature (anchor, bullet, indent level, run property,
// spacing, etc.) so the LibreOffice ↔ catalog renderer comparison
// can pinpoint where text layout drifts.

///|
fn extras_pml_text(cases : Array[VisualCase]) -> Unit {
  // ---- local helpers ---------------------------------------------
  // `<a:t>` literal text.
  let a_t = fn(text : String) -> @xml.Element {
    xe(NS_A, "t", [], [Text(text)])
  }
  // `<a:r>` run with optional `<a:rPr>` and literal text.
  let a_run = fn(rpr : @xml.Element?, text : String) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    match rpr {
      Some(p) => kids.push(Element(p))
      None => ()
    }
    kids.push(Element(a_t(text)))
    xe(NS_A, "r", [], kids)
  }
  // `<a:rPr>` with arbitrary attributes and arbitrary child elements
  // (e.g. `<a:solidFill>`, `<a:latin>`).
  let a_rpr = fn(
    attrs : Array[@xml.Attribute],
    children : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in children {
      kids.push(Element(c))
    }
    xe(NS_A, "rPr", attrs, kids)
  }
  // `<a:pPr>` with arbitrary attributes and child elements.
  let a_ppr = fn(
    attrs : Array[@xml.Attribute],
    children : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in children {
      kids.push(Element(c))
    }
    xe(NS_A, "pPr", attrs, kids)
  }
  // `<a:p>` paragraph with optional pPr and a sequence of run/break
  // children.
  let a_p = fn(
    ppr : @xml.Element?,
    runs : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    match ppr {
      Some(p) => kids.push(Element(p))
      None => ()
    }
    for r in runs {
      kids.push(Element(r))
    }
    xe(NS_A, "p", [], kids)
  }
  // Plain paragraph carrying one unstyled literal run.
  let a_p_text = fn(text : String) -> @xml.Element {
    a_p(None, [a_run(None, text)])
  }
  // `<a:br/>` soft line-break inside an `<a:p>`.
  let a_br : @xml.Element = xe(NS_A, "br", [], [])

  // Build a `<p:sp>` text-frame at (x,y) of size (cx,cy) with the
  // given `<a:bodyPr>` attributes and a sequence of `<a:p>` kids.
  let text_shape = fn(
    id_ : String,
    name : String,
    x : String,
    y : String,
    cx : String,
    cy : String,
    body_pr_attrs : Array[@xml.Attribute],
    paras : Array[@xml.Element],
  ) -> @xml.Element {
    let body_kids : Array[@xml.Node] = [
      Element(xe(NS_A, "bodyPr", body_pr_attrs, [])),
      Element(xe(NS_A, "lstStyle", [], [])),
    ]
    for p in paras {
      body_kids.push(Element(p))
    }
    xe(NS_PML, "sp", [], [
      Element(
        xe(NS_PML, "nvSpPr", [], [
          Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
          Element(
            xe(NS_PML, "cNvSpPr", [], [
              Element(xe(NS_A, "spLocks", [xa("noGrp", "1")], [])),
            ]),
          ),
          Element(xe(NS_PML, "nvPr", [], [])),
        ]),
      ),
      Element(xe(NS_PML, "spPr", [], [Element(sp_xfrm(x, y, cx, cy))])),
      Element(xe(NS_PML, "txBody", [], body_kids)),
    ])
  }

  // ---- 1. multi-paragraph mixed alignment -------------------------
  cases.push({
    id: "text-mixed-alignment",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "MixedAlign",
        "457200",
        "457200",
        "8229600",
        "5486400",
        [],
        [
          a_p(Some(a_ppr([xa("algn", "l")], [])), [
            a_run(None, "Left aligned paragraph"),
          ]),
          a_p(Some(a_ppr([xa("algn", "ctr")], [])), [
            a_run(None, "Centered paragraph"),
          ]),
          a_p(Some(a_ppr([xa("algn", "r")], [])), [
            a_run(None, "Right aligned paragraph"),
          ]),
        ],
      ),
    ]),
  })

  // ---- 2. vertical anchor: centre ---------------------------------
  cases.push({
    id: "text-anchor-center",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "AnchCtr",
        "457200",
        "457200",
        "8229600",
        "5486400",
        [xa("anchor", "ctr"), xa("anchorCtr", "0")],
        [a_p_text("Vertically centered text")],
      ),
    ]),
  })

  // ---- 3. vertical anchor: bottom ---------------------------------
  cases.push({
    id: "text-anchor-bottom",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "AnchBot",
        "457200",
        "457200",
        "8229600",
        "5486400",
        [xa("anchor", "b"), xa("anchorCtr", "0")],
        [a_p_text("Bottom anchored text")],
      ),
    ]),
  })

  // ---- 4. bullet character `<a:buChar char="•"/>` -----------------
  let bu_char = fn(ch : String) -> @xml.Element {
    xe(NS_A, "buChar", [xa("char", ch)], [])
  }
  cases.push({
    id: "text-bullet-char",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "BulChar", "457200", "457200", "8229600", "5486400", [], [
        a_p(
          Some(
            a_ppr([xa("marL", "342900"), xa("indent", "-342900")], [
              bu_char("•"),
            ]),
          ),
          [a_run(None, "First bulleted item")],
        ),
        a_p(
          Some(
            a_ppr([xa("marL", "342900"), xa("indent", "-342900")], [
              bu_char("•"),
            ]),
          ),
          [a_run(None, "Second bulleted item")],
        ),
        a_p(
          Some(
            a_ppr([xa("marL", "342900"), xa("indent", "-342900")], [
              bu_char("•"),
            ]),
          ),
          [a_run(None, "Third bulleted item")],
        ),
      ]),
    ]),
  })

  // ---- 5. auto-number bullets `arabicPeriod` ----------------------
  let bu_auto = fn(typ : String) -> @xml.Element {
    xe(NS_A, "buAutoNum", [xa("type", typ)], [])
  }
  cases.push({
    id: "text-bullet-auto-arabic",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "BulAuto", "457200", "457200", "8229600", "5486400", [], [
        a_p(
          Some(
            a_ppr([xa("marL", "457200"), xa("indent", "-457200")], [
              bu_auto("arabicPeriod"),
            ]),
          ),
          [a_run(None, "First numbered item")],
        ),
        a_p(
          Some(
            a_ppr([xa("marL", "457200"), xa("indent", "-457200")], [
              bu_auto("arabicPeriod"),
            ]),
          ),
          [a_run(None, "Second numbered item")],
        ),
        a_p(
          Some(
            a_ppr([xa("marL", "457200"), xa("indent", "-457200")], [
              bu_auto("arabicPeriod"),
            ]),
          ),
          [a_run(None, "Third numbered item")],
        ),
      ]),
    ]),
  })

  // ---- 6. indent levels lvl=0,1,2 ---------------------------------
  cases.push({
    id: "text-indent-levels",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "Indent", "457200", "457200", "8229600", "5486400", [], [
        a_p(Some(a_ppr([xa("lvl", "0")], [])), [
          a_run(None, "Level 0 outline item"),
        ]),
        a_p(Some(a_ppr([xa("lvl", "1")], [])), [
          a_run(None, "Level 1 outline item"),
        ]),
        a_p(Some(a_ppr([xa("lvl", "2")], [])), [
          a_run(None, "Level 2 outline item"),
        ]),
        a_p(Some(a_ppr([xa("lvl", "1")], [])), [a_run(None, "Back to level 1")]),
      ]),
    ]),
  })

  // ---- 7. explicit body-pr insets (1") ----------------------------
  cases.push({
    id: "text-bodypr-insets",
    format: "pptx",
    category: "text",
    content: sp_tree([
      // Filled background so the inset is visible as a margin.
      pptx_shape(
        "2", "InsetBg", "rect", "1828800", "914400", "5486400", "3657600", "DDEBF7",
      ),
      text_shape(
        "3",
        "Insets",
        "1828800",
        "914400",
        "5486400",
        "3657600",
        [
          xa("lIns", "457200"),
          xa("tIns", "457200"),
          xa("rIns", "457200"),
          xa("bIns", "457200"),
        ],
        [a_p_text("Text with 0.5in insets on all four sides.")],
      ),
    ]),
  })

  // ---- 8. wrap="none" — single line, no wrapping ------------------
  cases.push({
    id: "text-wrap-none",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "NoWrap",
        "457200",
        "457200",
        "3657600",
        "914400",
        [xa("wrap", "none")],
        [
          a_p_text(
            "This line stays on a single line even when the frame is narrow",
          ),
        ],
      ),
    ]),
  })

  // ---- 9. body rotation rot="2700000" (45°) -----------------------
  cases.push({
    id: "text-bodypr-rotated",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "Rotated",
        "2286000",
        "1371600",
        "4572000",
        "3657600",
        [xa("rot", "2700000")],
        [a_p_text("Rotated body text at 45 degrees")],
      ),
    ]),
  })

  // ---- 10. superscript + subscript via baseline -------------------
  cases.push({
    id: "text-baseline-sup-sub",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "SupSub", "457200", "1828800", "8229600", "1371600", [], [
        a_p(None, [
          a_run(Some(a_rpr([xa("sz", "2400")], [])), "H"),
          a_run(
            Some(a_rpr([xa("sz", "2400"), xa("baseline", "-25000")], [])),
            "2",
          ),
          a_run(Some(a_rpr([xa("sz", "2400")], [])), "O and E = mc"),
          a_run(
            Some(a_rpr([xa("sz", "2400"), xa("baseline", "30000")], [])),
            "2",
          ),
        ]),
      ]),
    ]),
  })

  // ---- 11. bold + italic + underline in one run -------------------
  cases.push({
    id: "text-bold-italic-underline",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "BIU", "457200", "1828800", "8229600", "1371600", [], [
        a_p(None, [
          a_run(
            Some(
              a_rpr(
                [xa("sz", "3200"), xa("b", "1"), xa("i", "1"), xa("u", "sng")],
                [],
              ),
            ),
            "Bold Italic Underlined",
          ),
        ]),
      ]),
    ]),
  })

  // ---- 12. multiple font sizes in one paragraph -------------------
  cases.push({
    id: "text-multi-size",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "MultiSize",
        "457200",
        "1828800",
        "8229600",
        "1371600",
        [],
        [
          a_p(None, [
            a_run(Some(a_rpr([xa("sz", "1200")], [])), "tiny "),
            a_run(Some(a_rpr([xa("sz", "1800")], [])), "small "),
            a_run(Some(a_rpr([xa("sz", "2400")], [])), "medium "),
            a_run(Some(a_rpr([xa("sz", "3600")], [])), "LARGE"),
          ]),
        ],
      ),
    ]),
  })

  // ---- 13. multiple colours in one paragraph ----------------------
  cases.push({
    id: "text-multi-color",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "MultiColor",
        "457200",
        "1828800",
        "8229600",
        "1371600",
        [],
        [
          a_p(None, [
            a_run(
              Some(a_rpr([xa("sz", "2800")], [solid_fill("C00000")])),
              "Red ",
            ),
            a_run(
              Some(a_rpr([xa("sz", "2800")], [solid_fill("00B050")])),
              "Green ",
            ),
            a_run(
              Some(a_rpr([xa("sz", "2800")], [solid_fill("0070C0")])),
              "Blue ",
            ),
            a_run(
              Some(a_rpr([xa("sz", "2800")], [solid_fill("7030A0")])),
              "Purple",
            ),
          ]),
        ],
      ),
    ]),
  })

  // ---- 14. long-text wrap stress test -----------------------------
  cases.push({
    id: "text-long-wrap",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "LongWrap",
        "457200",
        "457200",
        "8229600",
        "5486400",
        [],
        [
          a_p(None, [
            a_run(
              Some(a_rpr([xa("sz", "2000")], [])),
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " +
              "Sed do eiusmod tempor incididunt ut labore et dolore " +
              "magna aliqua. Ut enim ad minim veniam, quis nostrud " +
              "exercitation ullamco laboris nisi ut aliquip ex ea " +
              "commodo consequat. Duis aute irure dolor in reprehenderit " +
              "in voluptate velit esse cillum dolore eu fugiat nulla " +
              "pariatur. Excepteur sint occaecat cupidatat non proident.",
            ),
          ]),
        ],
      ),
    ]),
  })

  // ---- 15. right + left aligned paragraphs alternating ------------
  cases.push({
    id: "text-align-r-then-l",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "RL", "457200", "457200", "8229600", "5486400", [], [
        a_p(Some(a_ppr([xa("algn", "r")], [])), [
          a_run(None, "Right-aligned line one"),
        ]),
        a_p(Some(a_ppr([xa("algn", "l")], [])), [
          a_run(None, "Left-aligned line two"),
        ]),
        a_p(Some(a_ppr([xa("algn", "r")], [])), [
          a_run(None, "Right-aligned line three"),
        ]),
        a_p(Some(a_ppr([xa("algn", "l")], [])), [
          a_run(None, "Left-aligned line four"),
        ]),
      ]),
    ]),
  })

  // ---- 16. justified paragraph (long content so justification shows)
  cases.push({
    id: "text-justified-long",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "Just", "457200", "457200", "8229600", "5486400", [], [
        a_p(Some(a_ppr([xa("algn", "just")], [])), [
          a_run(
            Some(a_rpr([xa("sz", "1800")], [])),
            "Justified paragraph stretches inter-word spaces so " +
            "the lines fill the full content width. The longer " +
            "the run the more visible the spacing adjustment " +
            "between words becomes when the renderer obeys the " +
            "justification request faithfully.",
          ),
        ]),
      ]),
    ]),
  })

  // ---- 17. paragraph with explicit `<a:br/>` between runs ---------
  // Build the `<a:p>` manually to embed a real `<a:br/>` sibling
  // between two `<a:r>` runs (rather than nesting it in an `<a:r>`).
  let para_with_br : @xml.Element = xe(NS_A, "p", [], [
    Element(
      a_run(Some(a_rpr([xa("sz", "2000")], [])), "Line one before the break."),
    ),
    Element(a_br),
    Element(
      a_run(Some(a_rpr([xa("sz", "2000")], [])), "Line two after the break."),
    ),
    Element(a_br),
    Element(
      a_run(
        Some(a_rpr([xa("sz", "2000")], [])),
        "Line three after another break.",
      ),
    ),
  ])
  cases.push({
    id: "text-line-breaks",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "Breaks", "457200", "457200", "8229600", "5486400", [], [
        para_with_br,
      ]),
    ]),
  })

  // ---- 18. line-spacing 150% --------------------------------------
  let line_spacing_150 : @xml.Element = xe(NS_A, "lnSpc", [], [
    Element(xe(NS_A, "spcPct", [xa("val", "150000")], [])),
  ])
  cases.push({
    id: "text-line-spacing-150",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "Spc150", "457200", "457200", "8229600", "5486400", [], [
        a_p(Some(a_ppr([], [line_spacing_150])), [
          a_run(
            Some(a_rpr([xa("sz", "2000")], [])),
            "Paragraph one with 150 percent line spacing.",
          ),
        ]),
        a_p(Some(a_ppr([], [line_spacing_150])), [
          a_run(
            Some(a_rpr([xa("sz", "2000")], [])),
            "Paragraph two showing the spacing wraps onto multiple lines for the spacing to show.",
          ),
        ]),
      ]),
    ]),
  })

  // ---- 19. paragraph spacing before/after via spcPts --------------
  let spc_bef = xe(NS_A, "spcBef", [], [
    Element(xe(NS_A, "spcPts", [xa("val", "1200")], [])),
  ])
  let spc_aft = xe(NS_A, "spcAft", [], [
    Element(xe(NS_A, "spcPts", [xa("val", "1200")], [])),
  ])
  cases.push({
    id: "text-paragraph-spacing",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "ParaSpc", "457200", "457200", "8229600", "5486400", [], [
        a_p(Some(a_ppr([], [spc_bef, spc_aft])), [
          a_run(
            Some(a_rpr([xa("sz", "2000")], [])),
            "Paragraph one with 12pt above and below.",
          ),
        ]),
        a_p(Some(a_ppr([], [spc_bef, spc_aft])), [
          a_run(
            Some(a_rpr([xa("sz", "2000")], [])),
            "Paragraph two — gap visible between paragraphs.",
          ),
        ]),
        a_p(Some(a_ppr([], [spc_bef, spc_aft])), [
          a_run(
            Some(a_rpr([xa("sz", "2000")], [])),
            "Paragraph three closes the run.",
          ),
        ]),
      ]),
    ]),
  })

  // ---- 20. underline-only run (sng / dbl) -------------------------
  cases.push({
    id: "text-underline-styles",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "U", "457200", "457200", "8229600", "5486400", [], [
        a_p(None, [
          a_run(
            Some(a_rpr([xa("sz", "2400"), xa("u", "sng")], [])),
            "Single underline. ",
          ),
          a_run(
            Some(a_rpr([xa("sz", "2400"), xa("u", "dbl")], [])),
            "Double underline.",
          ),
        ]),
        a_p(None, [
          a_run(
            Some(a_rpr([xa("sz", "2400"), xa("u", "wavy")], [])),
            "Wavy underline.",
          ),
        ]),
      ]),
    ]),
  })

  // ---- 21. bullet types — arabic / roman / alpha ------------------
  cases.push({
    id: "text-bullet-auto-types",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "BulTypes",
        "457200",
        "457200",
        "8229600",
        "5486400",
        [],
        [
          a_p(
            Some(
              a_ppr([xa("marL", "457200"), xa("indent", "-457200")], [
                bu_auto("arabicPeriod"),
              ]),
            ),
            [a_run(None, "Arabic numbered item")],
          ),
          a_p(
            Some(
              a_ppr([xa("marL", "457200"), xa("indent", "-457200")], [
                bu_auto("romanUcPeriod"),
              ]),
            ),
            [a_run(None, "Upper-roman numbered item")],
          ),
          a_p(
            Some(
              a_ppr([xa("marL", "457200"), xa("indent", "-457200")], [
                bu_auto("alphaLcPeriod"),
              ]),
            ),
            [a_run(None, "Lower-alpha numbered item")],
          ),
          a_p(
            Some(
              a_ppr([xa("marL", "457200"), xa("indent", "-457200")], [
                bu_auto("alphaUcPeriod"),
              ]),
            ),
            [a_run(None, "Upper-alpha numbered item")],
          ),
        ],
      ),
    ]),
  })

  // ---- 22. body wrap=square explicit ------------------------------
  cases.push({
    id: "text-wrap-square",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape(
        "2",
        "WrapSq",
        "457200",
        "457200",
        "3657600",
        "2743200",
        [xa("wrap", "square")],
        [a_p_text("Wrapping square mode wraps the words inside the body.")],
      ),
    ]),
  })

  // ---- 23. mixed run colours + sizes + weights --------------------
  cases.push({
    id: "text-mixed-runs",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "MixRun", "457200", "457200", "8229600", "5486400", [], [
        a_p(None, [
          a_run(
            Some(
              a_rpr([xa("sz", "2800"), xa("b", "1")], [solid_fill("203864")]),
            ),
            "Title ",
          ),
          a_run(
            Some(
              a_rpr([xa("sz", "2000"), xa("i", "1")], [solid_fill("808080")]),
            ),
            "subtitle",
          ),
        ]),
        a_p(None, [
          a_run(Some(a_rpr([xa("sz", "1800")], [])), "Body text mixing "),
          a_run(Some(a_rpr([xa("sz", "1800"), xa("b", "1")], [])), "bold"),
          a_run(Some(a_rpr([xa("sz", "1800")], [])), " and "),
          a_run(Some(a_rpr([xa("sz", "1800"), xa("i", "1")], [])), "italic"),
          a_run(Some(a_rpr([xa("sz", "1800")], [])), " and "),
          a_run(
            Some(
              a_rpr([xa("sz", "1800"), xa("u", "sng")], [solid_fill("0070C0")]),
            ),
            "underlined-blue",
          ),
          a_run(Some(a_rpr([xa("sz", "1800")], [])), " runs."),
        ]),
      ]),
    ]),
  })

  // ---- 24. body anchor t (top) — explicit -------------------------
  cases.push({
    id: "text-anchor-top",
    format: "pptx",
    category: "text",
    content: sp_tree([
      // Background rect so the unused space at the bottom is visible.
      pptx_shape(
        "2", "TopBg", "rect", "457200", "457200", "8229600", "5486400", "F2F2F2",
      ),
      text_shape(
        "3",
        "AnchTop",
        "457200",
        "457200",
        "8229600",
        "5486400",
        [xa("anchor", "t")],
        [a_p_text("Top-anchored text — fills from the top.")],
      ),
    ]),
  })

  // ---- 25. no-autofit body — `<a:noAutofit/>` ---------------------
  let no_autofit : @xml.Element = xe(NS_A, "noAutofit", [], [])
  let bodyPr_with_autofit : @xml.Element = xe(NS_A, "bodyPr", [], [
    Element(no_autofit),
  ])
  // text_shape passes only attributes to bodyPr — build this shape
  // explicitly so the body can carry a `<a:noAutofit/>` child.
  let no_autofit_shape : @xml.Element = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "NoAutoFit")], []),
        ),
        Element(
          xe(NS_PML, "cNvSpPr", [], [
            Element(xe(NS_A, "spLocks", [xa("noGrp", "1")], [])),
          ]),
        ),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("457200", "457200", "8229600", "1371600")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(bodyPr_with_autofit),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          a_p(None, [
            a_run(
              Some(a_rpr([xa("sz", "2400")], [])),
              "Text with explicit <a:noAutofit/>.",
            ),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "text-body-no-autofit",
    format: "pptx",
    category: "text",
    content: sp_tree([no_autofit_shape]),
  })
}
