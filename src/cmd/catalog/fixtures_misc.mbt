// Miscellaneous fixture coverage — exercises edge-case areas of the
// renderer that the per-format `fixtures_<area>.mbt` families do not
// drive on their own.  Each fixture isolates one less-covered feature
// so a regression in (e.g.) WML decimal tabs surfaces here without
// being masked by the bulk paragraph cases.
//
// Categories targeted:
//   * WML §17.6.13 pgSz — very large / very small page boundaries.
//   * WML §17.6.11 pgMar — very narrow / very wide margin extremes.
//   * SML §18.18.11 ST_CellType — numeric-looking strings (`t="str"`,
//                                  `t="inlineStr"`).
//   * SML §18.17 — deeply nested formula expressions.
//   * PML §21.1.2 — text body with mixed paragraph styles in one frame.
//   * OMML §22.1 — composite expressions not covered by the basic
//                  fixture set (bra-ket, conditional probability).
//   * WML §17.3.1.37 — tab variants: bar (vertical rule) and clear
//                      (cancel inherited stop).
//   * WML run runs containing multiple scripts (RTL + LTR + CJK)
//                      to exercise the bidi / glyph-shaping cascade.

///|
/// Register the miscellaneous visual fixtures.  Wired from
/// `extra_cases()` in `fixtures_categories.mbt`.
fn extras_misc(cases : Array[VisualCase]) -> Unit {
  // ---- local helpers --------------------------------------------
  // A `w:`-prefixed attribute — `<w:sectPr>` and friends need the
  // prefix to round-trip through the renderer.
  let w_attr = fn(localn : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name: localn, ns: Some(NS_W) }, value }
  }
  // `<w:pgSz w:w=… w:h=…/>` — page size in twentieths of a point.
  let pg_sz = fn(w : String, h : String) -> @xml.Element {
    xe(NS_W, "pgSz", [w_attr("w", w), w_attr("h", h)], [])
  }
  // `<w:pgMar w:top=… w:right=… w:bottom=… w:left=…/>` — four basic
  // page margins.  Header / footer / gutter default to safe values.
  let pg_mar = fn(
    top : String,
    bottom : String,
    left : String,
    right : String,
  ) -> @xml.Element {
    xe(
      NS_W,
      "pgMar",
      [
        w_attr("top", top),
        w_attr("right", right),
        w_attr("bottom", bottom),
        w_attr("left", left),
        w_attr("header", "720"),
        w_attr("footer", "720"),
        w_attr("gutter", "0"),
      ],
      [],
    )
  }
  // Wrap a list of section-property children in `<w:sectPr>`.
  let sect_pr = fn(children : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in children {
      kids.push(Element(c))
    }
    xe(NS_W, "sectPr", [], kids)
  }
  // `<w:p><w:r><w:t>…</w:t></w:r></w:p>` filler paragraph factory so
  // each section fixture exercises wrapping under the chosen geometry.
  let p_line = fn(text : String) -> @xml.Element {
    w_p(None, [w_run(None, text)])
  }
  // `<w:pPr>` helper — wraps the supplied property children.
  let ppr = fn(props : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for p in props {
      kids.push(Element(p))
    }
    xe(NS_W, "pPr", [], kids)
  }
  // `<w:tab w:val=… w:pos=…/>` — a single tab-stop spec.  `val` is
  // one of `left`, `center`, `right`, `decimal`, `bar`, `clear`,
  // `num`; `pos` is the position in twentieths of a point from the
  // paragraph's content origin (`leader` not modelled here).
  let tab_stop = fn(val : String, pos : String) -> @xml.Element {
    xe(NS_W, "tab", [w_attr("val", val), w_attr("pos", pos)], [])
  }
  // `<w:r><w:tab/></w:r>` — a tab-character run that advances to the
  // next eligible stop in the paragraph's tab-stop table.
  let tab_run : @xml.Element = xe(NS_W, "r", [], [
    Element(xe(NS_W, "tab", [], [])),
  ])
  // `<a:t>` literal text inside a DrawingML run.
  let a_t = fn(text : String) -> @xml.Element {
    xe(NS_A, "t", [], [Text(text)])
  }
  // `<a:r>` run with optional `<a:rPr>` and a single text payload.
  let a_run = fn(rpr : @xml.Element?, text : String) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    match rpr {
      Some(p) => kids.push(Element(p))
      None => ()
    }
    kids.push(Element(a_t(text)))
    xe(NS_A, "r", [], kids)
  }
  // `<a:p>` DrawingML paragraph with optional `<a:pPr>` then runs.
  let a_p = fn(
    ppr_el : @xml.Element?,
    runs : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    match ppr_el {
      Some(p) => kids.push(Element(p))
      None => ()
    }
    for r in runs {
      kids.push(Element(r))
    }
    xe(NS_A, "p", [], kids)
  }

  // ===================================================================
  // 1. WML page setup — very-narrow margins (0.1" all sides)
  // ===================================================================
  //
  // §17.6.11 pgMar boundary — 144 twips = 0.1" margins squeeze the
  // body to almost the full page width; Word's narrowest built-in
  // preset is 0.25" so this exercises a value below every named
  // preset.  Useful for catching off-by-one in margin → content-width
  // arithmetic.
  cases.push({
    id: "misc-wml-page-margins-extreme-narrow",
    format: "docx",
    category: "misc",
    content: xe(NS_W, "body", [], [
      Element(
        p_line(
          "Extremely narrow margins (0.1\") — body should almost touch " +
          "the page edge on every side, exposing any off-by-one " +
          "page-content-width error in the renderer.",
        ),
      ),
      Element(
        p_line(
          "Second paragraph for wrap verification under the tightest " +
          "permitted margin configuration.",
        ),
      ),
      Element(
        sect_pr([pg_sz("12240", "15840"), pg_mar("144", "144", "144", "144")]),
      ),
    ]),
  })

  // ===================================================================
  // 2. WML page setup — very-wide margins (3.5" all sides)
  // ===================================================================
  //
  // §17.6.11 pgMar boundary — 5040 twips = 3.5" margins on US
  // Letter leave a 1.5" × 4" content rectangle.  Tests that the
  // wrapping path doesn't collapse on a sub-2" content width.
  cases.push({
    id: "misc-wml-page-margins-extreme-wide",
    format: "docx",
    category: "misc",
    content: xe(NS_W, "body", [], [
      Element(
        p_line(
          "Very wide margins (3.5\") shrink the text column to 1.5\" — " +
          "every sentence should wrap aggressively into the narrow " +
          "content rectangle.",
        ),
      ),
      Element(
        p_line(
          "Second filler paragraph so wrapping behaviour is visible " +
          "in the rendered output as multiple short lines.",
        ),
      ),
      Element(
        sect_pr([
          pg_sz("12240", "15840"),
          pg_mar("5040", "5040", "5040", "5040"),
        ]),
      ),
    ]),
  })

  // ===================================================================
  // 3. WML page setup — oversize custom page (24" × 36" plotter)
  // ===================================================================
  //
  // §17.6.13 pgSz extreme — 34560 × 51840 twips (24" × 36" "ARCH-D"
  // architectural sheet).  Renderers that assume Letter-size bounds
  // for viewport / scaling collapse on this value; the text should
  // still flow on the upper-left.
  cases.push({
    id: "misc-wml-page-oversize-24x36",
    format: "docx",
    category: "misc",
    content: xe(NS_W, "body", [], [
      Element(
        p_line(
          "Oversize architectural page (24\" × 36\"). The text block " +
          "should sit at the top-left under 1\" margins and leave the " +
          "rest of the canvas empty.",
        ),
      ),
      Element(
        sect_pr([
          pg_sz("34560", "51840"),
          pg_mar("1440", "1440", "1440", "1440"),
        ]),
      ),
    ]),
  })

  // ===================================================================
  // 4. SML — numeric-looking strings forced to type `str`
  // ===================================================================
  //
  // §18.18.11 ST_CellType — `t="str"` is a "result of formula stored
  // as string" type; reading code sometimes shortcuts on numeric
  // payload and renders without quotes.  Mixing `str` and `n` cells
  // surfaces that path.
  cases.push({
    id: "misc-sml-numeric-as-string",
    format: "xlsx",
    category: "misc",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Type"), s_inline("B1", "Value")])),
      Element(s_row("2", [s_inline("A2", "as number"), s_cell("B2", "42")])),
      // `t="str"` with a numeric-looking payload — should render as
      // the literal text "42", left-aligned, not as a right-aligned
      // number.
      Element(
        s_row("3", [
          s_inline("A3", "as str"),
          xe(NS_S, "c", [xa("r", "B3"), xa("t", "str")], [
            Element(xe(NS_S, "v", [], [Text("42")])),
          ]),
        ]),
      ),
      // Inline-string with numeric-looking payload — same expected
      // visual treatment as the `t="str"` case but via the inline-
      // string branch.
      Element(
        s_row("4", [s_inline("A4", "as inlineStr"), s_inline("B4", "42")]),
      ),
    ]),
  })

  // ===================================================================
  // 5. SML — deeply nested formula
  // ===================================================================
  //
  // §18.17 — formula nesting depth stress: IF(SUM(MAX(MIN(…),…),…),
  // …) five levels deep.  We supply a cached value via `<v>` so the
  // renderer surfaces it without needing the formula engine.
  cases.push({
    id: "misc-sml-formula-nested-deep",
    format: "xlsx",
    category: "misc",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_cell("A1", "5"),
          s_cell("B1", "10"),
          s_cell("C1", "15"),
          s_cell("D1", "20"),
        ]),
      ),
      Element(
        s_row("2", [
          s_inline("A2", "deep"),
          s_formula(
            "B2",
            "IF(SUM(MAX(MIN(A1,B1),MAX(C1,D1)),SUM(A1:D1))>=50," +
            "ROUND(AVERAGE(A1:D1)*2,0),CONCATENATE(\"err:\",A1))",
            "25",
          ),
        ]),
      ),
    ]),
  })

  // ===================================================================
  // 6. PML — composite text frame with mixed paragraph styles
  // ===================================================================
  //
  // §21.1.2.2 — one `<a:txBody>` holding paragraphs that vary in
  // alignment, size, weight and colour.  The renderer must apply
  // each paragraph's own `<a:pPr>` and run `<a:rPr>` independently.
  //
  // §21.1.2.5 rPr — attributes:
  //   sz : font size in hundredths of a point (`2400` = 24pt)
  //   b  : bold toggle ("1" = on)
  //   i  : italic toggle
  //   u  : underline style ("sng")
  let rpr_big_bold : @xml.Element = xe(
    NS_A,
    "rPr",
    [xa("sz", "2400"), xa("b", "1"), xa("lang", "en-US")],
    [Element(solid_fill("1F3864"))],
  )
  let rpr_small : @xml.Element = xe(
    NS_A,
    "rPr",
    [xa("sz", "1200"), xa("i", "1"), xa("lang", "en-US")],
    [Element(solid_fill("595959"))],
  )
  let rpr_medium_red : @xml.Element = xe(
    NS_A,
    "rPr",
    [xa("sz", "1800"), xa("lang", "en-US")],
    [Element(solid_fill("C00000"))],
  )
  let pml_mixed_paras : Array[@xml.Element] = [
    a_p(Some(xe(NS_A, "pPr", [xa("algn", "ctr")], [])), [
      a_run(Some(rpr_big_bold), "Headline (24pt bold navy)"),
    ]),
    a_p(Some(xe(NS_A, "pPr", [xa("algn", "l")], [])), [
      a_run(Some(rpr_small), "Caption line in 12pt italic grey, left-aligned."),
    ]),
    a_p(Some(xe(NS_A, "pPr", [xa("algn", "r")], [])), [
      a_run(Some(rpr_medium_red), "Right-aligned 18pt red callout."),
    ]),
  ]
  let mixed_body_kids : Array[@xml.Node] = [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
  ]
  for p in pml_mixed_paras {
    mixed_body_kids.push(Element(p))
  }
  let mixed_frame : @xml.Element = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "MixedText")], []),
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
        Element(sp_xfrm("914400", "914400", "7315200", "3657600")),
      ]),
    ),
    Element(xe(NS_PML, "txBody", [], mixed_body_kids)),
  ])
  cases.push({
    id: "misc-pml-text-mixed-paragraph-styles",
    format: "pptx",
    category: "misc",
    content: sp_tree([mixed_frame]),
  })

  // ===================================================================
  // 7. OMML — bra-ket notation `⟨ψ|H|φ⟩`
  // ===================================================================
  //
  // §22.1.2.21 `<m:d>` with explicit begin / separator / end glyphs
  // — Dirac bra-ket uses ⟨ … | … | … ⟩.  `sepChr` sets the inner
  // pipe, distinct from the outer ⟨ ⟩.
  cases.push({
    id: "misc-omml-bra-ket",
    format: "docx",
    category: "misc",
    content: omml_body(
      m_delim(
        "\u{27E8}",
        "|",
        "\u{27E9}",
        xe(NS_M, "e", [], [
          Element(m_r("\u{03C8}")),
          Element(m_r("H")),
          Element(m_r("\u{03C6}")),
        ]),
      ),
    ),
  })

  // ===================================================================
  // 8. OMML — conditional probability `P(A | B)`
  // ===================================================================
  //
  // §22.1.2.21 — parenthesised expression with a single pipe
  // separator.  Common notation that exercises the asymmetric
  // delimiter case (paren outer, pipe inner).
  cases.push({
    id: "misc-omml-conditional-probability",
    format: "docx",
    category: "misc",
    content: omml_body_many([
      Element(m_r("P")),
      Element(
        m_delim(
          "(",
          "|",
          ")",
          xe(NS_M, "e", [], [Element(m_r("A")), Element(m_r("B"))]),
        ),
      ),
    ]),
  })

  // ===================================================================
  // 9. OMML — tensor sub/superscript `T^{ij}_{kl}`
  // ===================================================================
  //
  // §22.1.2.85 `<m:sSubSup>` — combined sub-and-superscript anchored
  // on the same base.  Tensor indices are the canonical use case.
  let tensor : @xml.Element = xe(NS_M, "sSubSup", [], [
    Element(xe(NS_M, "sSubSupPr", [], [])),
    Element(m_arg("e", m_r("T"))),
    Element(m_arg("sub", m_r("kl"))),
    Element(m_arg("sup", m_r("ij"))),
  ])
  cases.push({
    id: "misc-omml-tensor-indices",
    format: "docx",
    category: "misc",
    content: omml_body(tensor),
  })

  // ===================================================================
  // 10. WML tab — bar tab (`val="bar"`, vertical rule)
  // ===================================================================
  //
  // §17.18.87 ST_TabJc `bar` — the tab character does not advance
  // the cursor; instead the renderer draws a thin vertical line at
  // the stop position spanning the line box.  Tests the bar-rule
  // emission path.
  cases.push({
    id: "misc-wml-tab-bar-rule",
    format: "docx",
    category: "misc",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("bar", "2880")),
                Element(tab_stop("left", "3240")),
                Element(tab_stop("bar", "5760")),
                Element(tab_stop("left", "6120")),
              ]),
            ]),
          ),
          [
            w_run(None, "Before"),
            tab_run,
            w_run(None, "between"),
            tab_run,
            w_run(None, "after"),
          ],
        ),
      ),
    ]),
  })

  // ===================================================================
  // 11. WML tab — clear tab cancels an inherited stop
  // ===================================================================
  //
  // §17.3.1.37 — `<w:tab w:val="clear" w:pos="…"/>` removes a tab
  // stop inherited from the paragraph style at the matching `pos`.
  // We declare a left stop, then a clear at the same position, so
  // the renderer must NOT honour the left stop.
  cases.push({
    id: "misc-wml-tab-clear-inherited",
    format: "docx",
    category: "misc",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            ppr([
              xe(NS_W, "tabs", [], [
                Element(tab_stop("left", "1440")),
                Element(tab_stop("clear", "1440")),
                Element(tab_stop("right", "5760")),
              ]),
            ]),
          ),
          [w_run(None, "Start"), tab_run, w_run(None, "skip-to-right")],
        ),
      ),
    ]),
  })

  // ===================================================================
  // 12. WML run — Arabic + English + Japanese in one paragraph
  // ===================================================================
  //
  // §17.3.2.20 `<w:lang w:bidi="…"/>` & §17.3.2.30 `<w:rtl/>` —
  // mixed-script paragraph forcing the renderer to switch between
  // LTR English, RTL Arabic, and CJK Japanese runs back-to-back.
  // Each script uses its native characters so a font substitution
  // failure leaves the affected run as tofu (unrendered).
  //
  // The Arabic run sets `<w:rtl/>` so the renderer reverses its
  // visual order; the CJK run uses Hiragana + Kanji to surface any
  // missing CJK fall-back in the glyph metrics path.
  let rtl_rpr : @xml.Element = w_rpr([w_flag("rtl")])
  cases.push({
    id: "misc-wml-mixed-script-arabic-english-japanese",
    format: "docx",
    category: "misc",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Hello "),
          // Arabic: "السلام" (peace) — RTL.
          w_run(
            Some(rtl_rpr),
            "\u{0627}\u{0644}\u{0633}\u{0644}\u{0627}\u{0645}",
          ),
          w_run(None, " "),
          // Japanese: "こんにちは" (hello) — CJK.
          w_run(None, "\u{3053}\u{3093}\u{306B}\u{3061}\u{306F}"),
          w_run(None, " — end."),
        ]),
      ),
    ]),
  })

  // ===================================================================
  // 13. WML run — Chinese (simplified) + Latin
  // ===================================================================
  //
  // CJK alongside ASCII — a common business-document pattern; the
  // renderer must pick a CJK fallback for the Han glyphs and keep
  // the ASCII run in the body face without doubling the cell
  // height.
  cases.push({
    id: "misc-wml-mixed-script-chinese-latin",
    format: "docx",
    category: "misc",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          // "中文 (Chinese): hello world"
          w_run(None, "\u{4E2D}\u{6587} (Chinese): hello world"),
        ]),
      ),
    ]),
  })

  // ===================================================================
  // 14. WML run — Hebrew + English (RTL mid-line)
  // ===================================================================
  //
  // §17.3.2.30 `<w:rtl/>` — Hebrew run mid-paragraph; the renderer
  // must reverse the Hebrew while keeping the English LTR, and the
  // surrounding spaces should sit on the script-direction boundary.
  cases.push({
    id: "misc-wml-mixed-script-hebrew-english",
    format: "docx",
    category: "misc",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Hello "),
          // Hebrew: "שלום" (shalom).
          w_run(Some(rtl_rpr), "\u{05E9}\u{05DC}\u{05D5}\u{05DD}"),
          w_run(None, " world."),
        ]),
      ),
    ]),
  })

  // ===================================================================
  // 15. PML composite — text frame with bullets + plain paragraphs
  // ===================================================================
  //
  // §21.1.2.4.4 buChar / §21.1.2.4.6 buNone — a single text frame
  // mixing bulleted and unbulleted paragraphs.  Each paragraph
  // explicitly sets its own `<a:buChar>` or `<a:buNone>` so the
  // renderer must apply the bullet decision per paragraph rather
  // than for the whole text body.
  let bullet_pr : @xml.Element = xe(
    NS_A,
    "pPr",
    [xa("marL", "342900"), xa("indent", "-342900")],
    [Element(xe(NS_A, "buChar", [xa("char", "\u{2022}")], []))],
  )
  let no_bullet_pr : @xml.Element = xe(NS_A, "pPr", [], [
    Element(xe(NS_A, "buNone", [], [])),
  ])
  let bullet_paras : Array[@xml.Element] = [
    a_p(Some(no_bullet_pr), [a_run(None, "Introduction (no bullet).")]),
    a_p(Some(bullet_pr), [a_run(None, "First bullet point.")]),
    a_p(Some(bullet_pr), [a_run(None, "Second bullet point.")]),
    a_p(Some(no_bullet_pr), [a_run(None, "Closing remark (no bullet).")]),
  ]
  let bullet_body_kids : Array[@xml.Node] = [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
  ]
  for p in bullet_paras {
    bullet_body_kids.push(Element(p))
  }
  let bullet_frame : @xml.Element = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "BulletMix")], []),
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
        Element(sp_xfrm("914400", "914400", "7315200", "3657600")),
      ]),
    ),
    Element(xe(NS_PML, "txBody", [], bullet_body_kids)),
  ])
  cases.push({
    id: "misc-pml-text-bullet-mix",
    format: "pptx",
    category: "misc",
    content: sp_tree([bullet_frame]),
  })
}
