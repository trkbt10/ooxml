// Edge-case visual fixtures.
//
// Each fixture isolates one rendering edge case across the four host
// formats (WML/SML/PML/OMML).  They complement the per-category
// "happy-path" fixtures by stressing extreme geometries, degenerate
// content, or rarely-exercised property combinations so the
// LibreOffice ↔ catalog renderer comparison surfaces regressions that
// the bulk fixtures would not catch.
//
// All IDs are prefixed `edge-` so a single grep separates this set
// from the regular fixtures in the snapshot report.
//
// Uses ONLY the top-level helpers from `fixtures_helpers.mbt` and
// `fixtures.mbt` plus the `xe` / `xa` constructors from `verify.mbt`.

///|
/// Build a `w:`-prefixed attribute — needed for property elements
/// that take attributes WITHOUT a value-shaped wrapper (`<w:ind>`,
/// `<w:tab>`, `<w:pgSz>`).  Mirrors the local helpers used inside
/// every per-category fixture file; lifted here so this module stays
/// self-contained without depending on the closures inside other
/// files.
fn edge_wa(local : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("w"), local_name: local, ns: Some(NS_W) }, value }
}

///|
/// Build an `a:`-prefixed attribute (DrawingML).
fn edge_aa(local : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("a"), local_name: local, ns: Some(NS_A) }, value }
}

///|
/// Build a `<w:pPr>` from a list of property elements.
fn edge_ppr(props : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for p in props {
    kids.push(Element(p))
  }
  xe(NS_W, "pPr", [], kids)
}

///|
/// Build a `<w:tbl>` from a property block, a grid, and rows.  Local
/// helper so this file doesn't share state with `fixtures_wml_table`.
fn edge_tbl(
  tblpr_kids : Array[@xml.Element],
  grid : @xml.Element,
  rows : Array[@xml.Element],
) -> @xml.Element {
  let pkids : Array[@xml.Node] = []
  for p in tblpr_kids {
    pkids.push(Element(p))
  }
  let kids : Array[@xml.Node] = [
    Element(xe(NS_W, "tblPr", [], pkids)),
    Element(grid),
  ]
  for r in rows {
    kids.push(Element(r))
  }
  xe(NS_W, "tbl", [], kids)
}

///|
/// Build a `<w:tblGrid>` from a list of column widths in dxa.
fn edge_tbl_grid(widths : Array[String]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for w in widths {
    kids.push(Element(xe(NS_W, "gridCol", [edge_wa("w", w)], [])))
  }
  xe(NS_W, "tblGrid", [], kids)
}

///|
/// Standard single-border surround used by the edge-table fixtures.
fn edge_std_borders() -> @xml.Element {
  let one_side = fn(side : String) -> @xml.Element {
    xe(
      NS_W,
      side,
      [edge_wa("val", "single"), edge_wa("sz", "8"), edge_wa("color", "000000")],
      [],
    )
  }
  xe(NS_W, "tblBorders", [], [
    Element(one_side("top")),
    Element(one_side("left")),
    Element(one_side("bottom")),
    Element(one_side("right")),
    Element(one_side("insideH")),
    Element(one_side("insideV")),
  ])
}

///|
/// Build a `<w:tc>` containing the supplied paragraphs (no tcPr).
fn edge_tc_paras(paras : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for p in paras {
    kids.push(Element(p))
  }
  xe(NS_W, "tc", [], kids)
}

///|
/// Build a `<w:tc>` with a width-only `<w:tcPr>` and a single text
/// paragraph.  Mirrors the helper in `fixtures.mbt`'s `tc(...)`.
fn edge_tc_w_text(w : String, text : String) -> @xml.Element {
  xe(NS_W, "tc", [], [
    Element(
      xe(NS_W, "tcPr", [], [
        Element(xe(NS_W, "tcW", [edge_wa("w", w), edge_wa("type", "dxa")], [])),
      ]),
    ),
    Element(w_p(None, [w_run(None, text)])),
  ])
}

///|
/// Build a `<w:tc>` with width + an explicit `<w:p>` alignment property
/// and a single text run.  Used by the mixed-alignment-row fixture.
fn edge_tc_aligned(w : String, jc : String, text : String) -> @xml.Element {
  xe(NS_W, "tc", [], [
    Element(
      xe(NS_W, "tcPr", [], [
        Element(xe(NS_W, "tcW", [edge_wa("w", w), edge_wa("type", "dxa")], [])),
      ]),
    ),
    Element(w_p(Some(edge_ppr([w_val("jc", jc)])), [w_run(None, text)])),
  ])
}

///|
/// Build a `<w:tr>` from a list of cells.
fn edge_tr(cells : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cells {
    kids.push(Element(c))
  }
  xe(NS_W, "tr", [], kids)
}

///|
/// Build a `<p:sp>` text frame at (x,y,cx,cy) with the supplied
/// paragraphs and an optional `rot` attribute on the `<a:xfrm>`.
/// Local copy so this file doesn't reach into `fixtures_pml_extra`.
fn edge_pml_textbox_rot(
  id_ : String,
  name : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  rot : String,
  text : String,
  sz_centi : String,
) -> @xml.Element {
  let xfrm_attrs : Array[@xml.Attribute] = []
  if rot != "" {
    xfrm_attrs.push(xa("rot", rot))
  }
  let xfrm = xe(NS_A, "xfrm", xfrm_attrs, [
    Element(xe(NS_A, "off", [xa("x", x), xa("y", y)], [])),
    Element(xe(NS_A, "ext", [xa("cx", cx), xa("cy", cy)], [])),
  ])
  let body_pr = xe(
    NS_A,
    "bodyPr",
    [xa("wrap", "square"), xa("anchor", "ctr")],
    [],
  )
  let rpr = xe(
    NS_A,
    "rPr",
    [xa("lang", "en-US"), xa("sz", sz_centi), xa("dirty", "0")],
    [],
  )
  let a_t = xe(NS_A, "t", [], [Text(text)])
  let a_r = xe(NS_A, "r", [], [Element(rpr), Element(a_t)])
  let ppr = xe(NS_A, "pPr", [xa("algn", "ctr")], [])
  let a_p = xe(NS_A, "p", [], [Element(ppr), Element(a_r)])
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
    Element(xe(NS_PML, "spPr", [], [Element(xfrm)])),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(body_pr),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(a_p),
      ]),
    ),
  ])
}

///|
/// Build a `<p:sp>` stroke-only line of explicit width.
fn edge_pml_thin_line(
  id_ : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  w_emu : String,
  hex : String,
) -> @xml.Element {
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", "Thin")], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm(x, y, cx, cy)),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "line")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(xe(NS_A, "noFill", [], [])),
        Element(xe(NS_A, "ln", [xa("w", w_emu)], [Element(solid_fill(hex))])),
      ]),
    ),
  ])
}

///|
/// Repeat `s` `n` times — short, side-effect-free string-builder.
fn edge_repeat(s : String, n : Int) -> String {
  let buf = StringBuilder::new(size_hint=s.length() * n)
  for _ in 0..<n {
    buf.write_string(s)
  }
  buf.to_string()
}

///|
/// Register all 20+ edge-case visual fixtures.  Wired from
/// `extra_cases()` in `fixtures_categories.mbt`.
fn extras_edges(cases : Array[VisualCase]) -> Unit {
  // ============================================================
  // WML edge cases (8)
  // ============================================================

  // 1. Very short run — single character "X".  Exercises the
  //    minimum-content branch of the wrap / measure pipeline.
  cases.push({
    id: "edge-wml-very-short-run",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [Element(w_p(None, [w_run(None, "X")]))]),
  })

  // 2. Very long single line — 500 characters with no wrap-friendly
  //    spaces near the end forces several break attempts.
  let long_line = edge_repeat("abcdefghij", 50)
  cases.push({
    id: "edge-wml-very-long-single-line",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [Element(w_p(None, [w_run(None, long_line)]))]),
  })

  // 3. Nested tables — a 1×1 table inside a cell of a 1×1 outer
  //    table.  Exercises recursive cell layout and border nesting.
  let inner_tbl = edge_tbl([edge_std_borders()], edge_tbl_grid(["1500"]), [
    edge_tr([edge_tc_w_text("1500", "Inner")]),
  ])
  cases.push({
    id: "edge-wml-nested-tables",
    format: "docx",
    category: "table",
    content: xe(NS_W, "body", [], [
      Element(
        edge_tbl([edge_std_borders()], edge_tbl_grid(["3000"]), [
          edge_tr([
            edge_tc_paras([
              w_p(None, [w_run(None, "Outer")]),
              inner_tbl,
              w_p(None, []),
            ]),
          ]),
        ]),
      ),
    ]),
  })

  // 4. Empty cells — table whose cells contain only `<w:p/>`.  Verifies
  //    the renderer does not collapse zero-height paragraphs into a
  //    flat row when the cell carries no runs.
  cases.push({
    id: "edge-wml-empty-table-cell",
    format: "docx",
    category: "table",
    content: xe(NS_W, "body", [], [
      Element(
        edge_tbl([edge_std_borders()], edge_tbl_grid(["1500", "1500"]), [
          edge_tr([
            edge_tc_paras([w_p(None, [])]),
            edge_tc_paras([w_p(None, [])]),
          ]),
        ]),
      ),
    ]),
  })

  // 5. Mixed alignments inside one row — left, centre, right cells in
  //    the same `<w:tr>`.  Tests per-cell paragraph property override.
  cases.push({
    id: "edge-wml-mixed-alignments-in-table",
    format: "docx",
    category: "table",
    content: xe(NS_W, "body", [], [
      Element(
        edge_tbl(
          [edge_std_borders()],
          edge_tbl_grid(["1800", "1800", "1800"]),
          [
            edge_tr([
              edge_tc_aligned("1800", "start", "Left"),
              edge_tc_aligned("1800", "center", "Center"),
              edge_tc_aligned("1800", "end", "Right"),
            ]),
          ],
        ),
      ),
    ]),
  })

  // 6. Many tab stops — paragraph carrying 10 explicit `<w:tab>`
  //    declarations at evenly-spaced positions, then a run that
  //    advances through all of them with `<w:tab/>` characters.
  let tabs_pr = {
    let stops : Array[@xml.Element] = []
    for i in 1..<11 {
      let pos = (i * 720).to_string()
      stops.push(
        xe(NS_W, "tab", [edge_wa("val", "left"), edge_wa("pos", pos)], []),
      )
    }
    let tabs = xe(
      NS_W,
      "tabs",
      [],
      {
        let kids : Array[@xml.Node] = []
        for s in stops {
          kids.push(Element(s))
        }
        kids
      },
    )
    edge_ppr([tabs])
  }
  let many_tab_runs : Array[@xml.Element] = []
  for i in 1..<11 {
    many_tab_runs.push(xe(NS_W, "r", [], [Element(xe(NS_W, "tab", [], []))]))
    many_tab_runs.push(w_run(None, "C" + i.to_string()))
  }
  cases.push({
    id: "edge-wml-tab-stops-many",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [Element(w_p(Some(tabs_pr), many_tab_runs))]),
  })

  // 7. RTL paragraph with Arabic-Indic numerals.  Exercises the
  //    `<w:bidi/>` direction flag combined with digit-glyph mixing.
  cases.push({
    id: "edge-wml-rtl-with-numbers",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(edge_ppr([xe(NS_W, "bidi", [], [])])), [
          w_run(None, "السنة ٢٠٢٦ نتائج جيدة ١٢٣٤٥"),
        ]),
      ),
    ]),
  })

  // 8. Zero-width span — a `<w:r/>` (empty run) sitting between two
  //    text runs.  The empty run should produce no glyphs but the two
  //    neighbours should still adjoin without a visible gap.
  cases.push({
    id: "edge-wml-zero-width-span",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "before"),
          xe(NS_W, "r", [], []),
          w_run(None, "after"),
        ]),
      ),
    ]),
  })

  // ============================================================
  // SML edge cases (5)
  // ============================================================

  // 9. Single cell rendered at 50pt — large inline text in one cell.
  //    The styles part stays defaulted; the size comes from the cell
  //    text run's inline-string `<rPr><sz>` is not on the v=… path,
  //    so this fixture leans on cell content + column width to make
  //    the size visible at the cell level.  inline-string `<t>` carries
  //    just text — to drive a large rendering we put a long label that
  //    forces width adjustments in the renderer.
  cases.push({
    id: "edge-sml-single-cell-large",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "BIG")])),
    ]),
  })

  // 10. 30 rows × 1 column, narrow numeric values — tall geometry
  //     check.  Exercises row-flow accumulation past the typical 10-20
  //     row fixtures.
  let many_rows : Array[@xml.Node] = []
  for r in 1..<31 {
    many_rows.push(
      Element(
        s_row(r.to_string(), [s_cell("A" + r.to_string(), r.to_string())]),
      ),
    )
  }
  cases.push({
    id: "edge-sml-many-rows-narrow",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], many_rows),
  })

  // 11. Circular reference with cached values — A1 = B1, B1 = A1.
  //     A real reader must not evaluate; it should display the cached
  //     `<v>` text as-is.  Cached values pick an arbitrary numeric
  //     literal (0) to make the rendering deterministic.
  cases.push({
    id: "edge-sml-formula-circular-reference",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_formula("A1", "B1", "0"), s_formula("B1", "A1", "0")]),
      ),
    ]),
  })

  // 12. Very precise decimal — 16 significant digits, deeper than IEEE
  //     double precision exposed in the cell.
  cases.push({
    id: "edge-sml-very-precise-decimal",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_inline("A1", "value"), s_cell("B1", "1.23456789012345")]),
      ),
    ]),
  })

  // 13. Scientific notation in storage — `1.5e-20` written verbatim
  //     into `<v>`.  The renderer must honour the exponent form.
  cases.push({
    id: "edge-sml-scientific-notation",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "tiny"), s_cell("B1", "1.5E-20")])),
    ]),
  })

  // ============================================================
  // PML edge cases (5)
  // ============================================================

  // 14. Extreme aspect-ratio rectangle — very wide, very short.  Tests
  //     the geometry pipeline at the edge of LibreOffice's hairline-
  //     thickness rasterisation: 1000 EMU tall × 7,500,000 wide.
  cases.push({
    id: "edge-pml-extreme-aspect-shape",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Strip", "rect", "457200", "3429000", "7500000", "1000", "1F4E79",
      ),
    ]),
  })

  // 15. 0.5pt thin line — stroke width 6350 EMU.  Verifies the
  //     renderer does not round sub-1pt strokes up to invisibility.
  cases.push({
    id: "edge-pml-1px-thin-line",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      edge_pml_thin_line(
        "2", "457200", "3429000", "8229600", "0", "6350", "404040",
      ),
    ]),
  })

  // 16. Text frame rotated 90° — `rot` = 5_400_000 (60_000ths-of-a-
  //     degree).  Exercises rotation matrix application to the text
  //     baseline.
  cases.push({
    id: "edge-pml-rotated-text-90deg",
    format: "pptx",
    category: "text",
    content: sp_tree([
      edge_pml_textbox_rot(
        "2", "RotText", "3886200", "1828800", "1371600", "3200400", "5400000", "Rotated 90°",
        "3200",
      ),
    ]),
  })

  // 17. 20 small overlapping ellipses — stress-test for compositing
  //     many semi-overlapping shapes.  Placed in a 5×4 grid with
  //     overlap of half their extent.
  let overlap_shapes : Array[@xml.Element] = []
  let mut ov_id = 2
  for r in 0..<4 {
    for c in 0..<5 {
      let x = (1500000 + c * 700000).to_string()
      let y = (1500000 + r * 700000).to_string()
      overlap_shapes.push(
        pptx_shape(
          ov_id.to_string(),
          "E" + ov_id.to_string(),
          "ellipse",
          x,
          y,
          "1000000",
          "1000000",
          if (r + c) % 2 == 0 {
            "4472C4"
          } else {
            "ED7D31"
          },
        ),
      )
      ov_id = ov_id + 1
    }
  }
  cases.push({
    id: "edge-pml-many-overlapping-shapes",
    format: "pptx",
    category: "shape",
    content: sp_tree(overlap_shapes),
  })

  // 18. 1-inch shape (914400 × 914400 EMU) with 6pt text label inside.
  //     `sz` in DrawingML is in hundredths of a point so 6pt = "600".
  //     Tests the small-text branch of the text frame renderer.
  cases.push({
    id: "edge-pml-shape-with-very-small-text",
    format: "pptx",
    category: "text",
    content: sp_tree([
      pptx_shape(
        "2", "Box", "rect", "3886200", "2971800", "914400", "914400", "F2F2F2",
      ),
      edge_pml_textbox_rot(
        "3", "Tiny", "3886200", "2971800", "914400", "914400", "", "tiny", "600",
      ),
    ]),
  })

  // ============================================================
  // OMML edge cases (5)
  // ============================================================

  // 19. Empty fraction — `<m:f>` with empty `<m:num>` and `<m:den>`.
  //     Renderer must not crash; should draw an empty bar/glyph.
  let empty_frac = xe(NS_M, "f", [], [
    Element(xe(NS_M, "num", [], [])),
    Element(xe(NS_M, "den", [], [])),
  ])
  cases.push({
    id: "edge-omml-empty-fraction",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(xe(NS_M, "oMath", [], [Element(empty_frac)])),
        ]),
      ),
    ]),
  })

  // 20. Deeply nested — fraction inside fraction inside fraction.
  //     Verifies the recursive layout's vertical extent calculation.
  let lvl1 = xe(NS_M, "f", [], [
    Element(m_arg("num", m_r("a"))),
    Element(m_arg("den", m_r("b"))),
  ])
  let lvl2 = xe(NS_M, "f", [], [
    Element(m_arg("num", lvl1)),
    Element(m_arg("den", m_r("c"))),
  ])
  let lvl3 = xe(NS_M, "f", [], [
    Element(m_arg("num", lvl2)),
    Element(m_arg("den", m_r("d"))),
  ])
  cases.push({
    id: "edge-omml-deeply-nested",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(lvl3)]))]),
      ),
    ]),
  })

  // 21. Very long numerator — full quartic polynomial in `<m:num>`.
  //     Exercises the fraction-bar width that must span a long run.
  let long_num = m_r(
    "a₀ + a₁x + a₂x² + a₃x³ + a₄x⁴ + a₅x⁵ + a₆x⁶",
  )
  let long_frac = xe(NS_M, "f", [], [
    Element(m_arg("num", long_num)),
    Element(m_arg("den", m_r("n!"))),
  ])
  cases.push({
    id: "edge-omml-very-long-numerator",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(long_frac)]))]),
      ),
    ]),
  })

  // 22. Single letter — just `<m:r><m:t>x</m:t></m:r>` with no
  //     surrounding structure.  Smallest possible OMath.
  cases.push({
    id: "edge-omml-single-letter",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(m_r("x"))]))]),
      ),
    ]),
  })

  // 23. Pi via Leibniz series — π = 4 × Σ((-1)ⁿ/(2n+1)) from n=0 to ∞.
  //     Combines an `<m:nary>`, an `<m:f>`, and an `<m:sSup>` in one
  //     equation.
  let sign_pow = xe(NS_M, "sSup", [], [
    Element(
      m_arg(
        "e",
        xe(NS_M, "d", [], [
          Element(xe(NS_M, "dPr", [], [])),
          Element(m_arg("e", m_r("−1"))),
        ]),
      ),
    ),
    Element(m_arg("sup", m_r("n"))),
  ])
  let term_frac = xe(NS_M, "f", [], [
    Element(xe(NS_M, "num", [], [Element(sign_pow)])),
    Element(m_arg("den", m_r("2n + 1"))),
  ])
  let sum = xe(NS_M, "nary", [], [
    Element(
      xe(NS_M, "naryPr", [], [
        Element(
          xe(
            NS_M,
            "chr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "∑",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("sub", m_r("n=0"))),
    Element(m_arg("sup", m_r("∞"))),
    Element(m_arg("e", term_frac)),
  ])
  cases.push({
    id: "edge-omml-pi-equation",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(
            xe(NS_M, "oMath", [], [Element(m_r("π = 4 × ")), Element(sum)]),
          ),
        ]),
      ),
    ]),
  })

  // Touch `edge_aa` so the helper is exercised — referenced once for
  // type-checking; emits nothing into the fixture set.
  let _ = edge_aa
}
