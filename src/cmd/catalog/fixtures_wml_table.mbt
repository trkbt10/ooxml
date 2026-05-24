// WML table fixtures — `<w:tbl>` layouts, borders, shading, merged
// cells, custom widths.  See `fixtures_wml_run.mbt` for convention.
//
// All fixtures live under `category: "table"` and exercise features
// from ECMA-376 Part 1 §17.4 (Tables): tblPr, tblGrid, tr, tc and
// their associated property elements (tblBorders, tblCellMar,
// tblInd, tblW, tblLayout, tblLook, trHeight, trPr, tcPr, tcW,
// tcMar, vAlign, gridSpan, vMerge, shd, tcBorders).

///|
fn extras_wml_table(cases : Array[VisualCase]) -> Unit {
  // --- File-local helpers --------------------------------------------
  //
  // The WML table grammar is verbose: most property elements carry a
  // handful of `w:`-prefixed attributes that cannot be expressed via
  // `w_val`.  These local closures encode the recurring patterns so
  // the per-fixture construction stays readable.

  // `<w:` attribute factory.
  let wa = fn(local : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name: local, ns: Some(NS_W) }, value }
  }

  // `<w:gridCol w:w="..."/>` — column width in twentieths of a point.
  let grid_col = fn(w : String) -> @xml.Element {
    xe(NS_W, "gridCol", [wa("w", w)], [])
  }

  // `<w:tblGrid>` from a list of column widths.
  let tbl_grid = fn(widths : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for w in widths {
      kids.push(Element(grid_col(w)))
    }
    xe(NS_W, "tblGrid", [], kids)
  }

  // Generic border side, `<w:top w:val="single" w:sz="N" w:color="..."/>`.
  let bdr = fn(
    side : String,
    val : String,
    sz : String,
    color : String,
  ) -> @xml.Element {
    xe(NS_W, side, [wa("val", val), wa("sz", sz), wa("color", color)], [])
  }
  let bdr_single = fn(side : String) -> @xml.Element {
    bdr(side, "single", "8", "000000")
  }
  let bdr_none = fn(side : String) -> @xml.Element {
    xe(NS_W, side, [wa("val", "nil")], [])
  }

  // Standard single-border surround used by most fixtures.
  let std_borders = fn() -> @xml.Element {
    xe(NS_W, "tblBorders", [], [
      Element(bdr_single("top")),
      Element(bdr_single("left")),
      Element(bdr_single("bottom")),
      Element(bdr_single("right")),
      Element(bdr_single("insideH")),
      Element(bdr_single("insideV")),
    ])
  }

  // `<w:tblW w:w="..." w:type="..."/>`.
  let tbl_w = fn(w : String, ty : String) -> @xml.Element {
    xe(NS_W, "tblW", [wa("w", w), wa("type", ty)], [])
  }

  // `<w:tblInd w:w="..." w:type="..."/>`.
  let tbl_ind = fn(w : String, ty : String) -> @xml.Element {
    xe(NS_W, "tblInd", [wa("w", w), wa("type", ty)], [])
  }

  // `<w:tblLayout w:type="..."/>`.
  let tbl_layout = fn(ty : String) -> @xml.Element {
    xe(NS_W, "tblLayout", [wa("type", ty)], [])
  }

  // `<w:tblLook .../>` conditional-format hints.
  let tbl_look = fn(
    first_row : String,
    last_row : String,
    first_col : String,
    last_col : String,
  ) -> @xml.Element {
    xe(
      NS_W,
      "tblLook",
      [
        wa("firstRow", first_row),
        wa("lastRow", last_row),
        wa("firstColumn", first_col),
        wa("lastColumn", last_col),
      ],
      [],
    )
  }

  // Default cell margins at the table level — four sides.
  let tbl_cell_mar = fn(
    top : String,
    left : String,
    bottom : String,
    right : String,
  ) -> @xml.Element {
    let side = fn(name : String, w : String) -> @xml.Element {
      xe(NS_W, name, [wa("w", w), wa("type", "dxa")], [])
    }
    xe(NS_W, "tblCellMar", [], [
      Element(side("top", top)),
      Element(side("left", left)),
      Element(side("bottom", bottom)),
      Element(side("right", right)),
    ])
  }

  // Per-cell margin override.
  let tc_mar = fn(
    top : String,
    left : String,
    bottom : String,
    right : String,
  ) -> @xml.Element {
    let side = fn(name : String, w : String) -> @xml.Element {
      xe(NS_W, name, [wa("w", w), wa("type", "dxa")], [])
    }
    xe(NS_W, "tcMar", [], [
      Element(side("top", top)),
      Element(side("left", left)),
      Element(side("bottom", bottom)),
      Element(side("right", right)),
    ])
  }

  // `<w:trHeight w:val="..." w:hRule="..."/>` row height.
  let tr_height = fn(val : String, rule : String) -> @xml.Element {
    xe(NS_W, "trHeight", [wa("val", val), wa("hRule", rule)], [])
  }

  // `<w:shd>` cell shading.
  let shd = fn(fill : String) -> @xml.Element {
    xe(
      NS_W,
      "shd",
      [wa("val", "clear"), wa("color", "auto"), wa("fill", fill)],
      [],
    )
  }

  // `<w:vAlign w:val="..."/>` cell vertical alignment.
  let v_align = fn(val : String) -> @xml.Element {
    xe(NS_W, "vAlign", [wa("val", val)], [])
  }

  // `<w:gridSpan w:val="N"/>` horizontal merge.
  let grid_span = fn(n : String) -> @xml.Element {
    xe(NS_W, "gridSpan", [wa("val", n)], [])
  }

  // `<w:vMerge w:val="restart"/>` or `<w:vMerge/>` (continue).
  let v_merge_restart = fn() -> @xml.Element {
    xe(NS_W, "vMerge", [wa("val", "restart")], [])
  }
  let v_merge_continue = fn() -> @xml.Element { xe(NS_W, "vMerge", [], []) }

  // Build a `<w:tc>` with an arbitrary list of property elements and
  // paragraph children.  This is the workhorse used by all builders
  // below — it keeps the verbose Element/Node wrapping localised.
  let tc_full = fn(
    props : Array[@xml.Element],
    paras : Array[@xml.Element],
  ) -> @xml.Element {
    let pkids : Array[@xml.Node] = []
    for p in props {
      pkids.push(Element(p))
    }
    let kids : Array[@xml.Node] = [Element(xe(NS_W, "tcPr", [], pkids))]
    for p in paras {
      kids.push(Element(p))
    }
    xe(NS_W, "tc", [], kids)
  }

  // Basic cell — `<w:tcW>` width + a single-run paragraph.
  let tc_w_text = fn(w : String, text : String) -> @xml.Element {
    tc_full([xe(NS_W, "tcW", [wa("w", w), wa("type", "dxa")], [])], [
      w_p(None, [w_run(None, text)]),
    ])
  }

  // Cell with explicit width plus an arbitrary list of extra
  // property elements layered after `<w:tcW>`.
  let tc_w_props = fn(
    w : String,
    extras : Array[@xml.Element],
    text : String,
  ) -> @xml.Element {
    let props : Array[@xml.Element] = [
      xe(NS_W, "tcW", [wa("w", w), wa("type", "dxa")], []),
    ]
    for e in extras {
      props.push(e)
    }
    tc_full(props, [w_p(None, [w_run(None, text)])])
  }

  // `<w:tr>` wrapper from a cell list (no row properties).
  let tr = fn(cells : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in cells {
      kids.push(Element(c))
    }
    xe(NS_W, "tr", [], kids)
  }

  // `<w:tr>` with an explicit `<w:trPr>` block.
  let tr_with_pr = fn(
    trpr : @xml.Element,
    cells : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = [Element(trpr)]
    for c in cells {
      kids.push(Element(c))
    }
    xe(NS_W, "tr", [], kids)
  }

  // Build `<w:tbl>` from prop block + grid + rows.
  let tbl = fn(
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

  // Convenience: wrap a single `<w:tbl>` in a `<w:body>`.
  let body_of = fn(table : @xml.Element) -> @xml.Element {
    xe(NS_W, "body", [], [Element(table)])
  }

  // ----------------------------------------------------------------
  // 1. table-gridspan-2 — two cells merged across columns via gridSpan.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-gridspan-2",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["2000", "2000", "2000"]), [
        tr([
          // Header cell spans all three columns.
          tc_full(
            [
              xe(NS_W, "tcW", [wa("w", "6000"), wa("type", "dxa")], []),
              grid_span("3"),
              shd("DDEBF7"),
            ],
            [
              w_p(None, [w_run(Some(w_rpr([w_flag("b")])), "Quarterly results")]),
            ],
          ),
        ]),
        tr([
          tc_w_text("2000", "Q1"),
          tc_w_text("2000", "Q2"),
          tc_w_text("2000", "Q3"),
        ]),
        tr([
          tc_w_text("2000", "100"),
          tc_w_text("2000", "110"),
          tc_w_text("2000", "120"),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 2. table-vmerge-2 — left column vertically merged across two rows.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-vmerge-2",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["2000", "2000", "2000"]), [
        tr([
          tc_w_props("2000", [v_merge_restart()], "Region"),
          tc_w_text("2000", "North"),
          tc_w_text("2000", "100"),
        ]),
        tr([
          // Continuation — empty paragraph.
          tc_full(
            [
              xe(NS_W, "tcW", [wa("w", "2000"), wa("type", "dxa")], []),
              v_merge_continue(),
            ],
            [w_p(None, [w_run(None, "")])],
          ),
          tc_w_text("2000", "South"),
          tc_w_text("2000", "85"),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 3. table-tcmar-varying — per-cell margin overrides side-by-side.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-tcmar-varying",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["2400", "2400", "2400"]), [
        tr([
          tc_w_props("2400", [tc_mar("60", "60", "60", "60")], "tight 60dxa"),
          tc_w_props(
            "2400",
            [tc_mar("240", "240", "240", "240")],
            "wide 240dxa",
          ),
          tc_w_props(
            "2400",
            [tc_mar("60", "480", "60", "60")],
            "asymmetric L=480",
          ),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 4. table-tblcellmar — default cell margins set at table level.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-tblcellmar",
    format: "docx",
    category: "table",
    content: body_of(
      tbl(
        [std_borders(), tbl_cell_mar("200", "200", "200", "200")],
        tbl_grid(["2400", "2400"]),
        [
          tr([tc_w_text("2400", "Padded"), tc_w_text("2400", "Cells")]),
          tr([tc_w_text("2400", "All sides"), tc_w_text("2400", "200dxa")]),
        ],
      ),
    ),
  })

  // ----------------------------------------------------------------
  // 5. table-tblind — table offset from the left margin via tblInd.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-tblind",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders(), tbl_ind("1440", "dxa")], tbl_grid(["2000", "2000"]), [
        tr([tc_w_text("2000", "Indented"), tc_w_text("2000", "1 inch")]),
        tr([tc_w_text("2000", "from"), tc_w_text("2000", "margin")]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 6. table-tblw-pct — table width as percentage of page width.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-tblw-pct",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders(), tbl_w("5000", "pct")], tbl_grid(["3000", "3000"]), [
        tr([tc_w_text("3000", "50% wide"), tc_w_text("3000", "table")]),
        tr([tc_w_text("3000", "via tblW"), tc_w_text("3000", "pct=5000")]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 7. table-valign-mixed — cells with top / center / bottom alignment
  //    sharing a tall row so the difference is visible.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-valign-mixed",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["2000", "2000", "2000"]), [
        tr_with_pr(
          xe(NS_W, "trPr", [], [Element(tr_height("1400", "atLeast"))]),
          [
            tc_w_props("2000", [v_align("top")], "top"),
            tc_w_props("2000", [v_align("center")], "center"),
            tc_w_props("2000", [v_align("bottom")], "bottom"),
          ],
        ),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 8. table-trheight-exact — exact row height (clips overflow).
  // ----------------------------------------------------------------
  cases.push({
    id: "table-trheight-exact",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["3000", "3000"]), [
        tr_with_pr(xe(NS_W, "trPr", [], [Element(tr_height("400", "exact"))]), [
          tc_w_text("3000", "Exact 20pt"),
          tc_w_text("3000", "row"),
        ]),
        tr_with_pr(
          xe(NS_W, "trPr", [], [Element(tr_height("800", "atLeast"))]),
          [tc_w_text("3000", "atLeast 40pt"), tc_w_text("3000", "row")],
        ),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 9. table-diagonal-border — `<w:tl2br>` (top-left → bottom-right)
  //    and `<w:tr2bl>` (top-right → bottom-left) on cells.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-diagonal-border",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["2400", "2400"]), [
        tr([
          tc_full(
            [
              xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], []),
              xe(NS_W, "tcBorders", [], [
                Element(bdr("tl2br", "single", "8", "C00000")),
              ]),
            ],
            [w_p(None, [w_run(None, "TL-BR diag")])],
          ),
          tc_full(
            [
              xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], []),
              xe(NS_W, "tcBorders", [], [
                Element(bdr("tr2bl", "single", "8", "0070C0")),
              ]),
            ],
            [w_p(None, [w_run(None, "TR-BL diag")])],
          ),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 10. table-header-row — first row tagged as repeating header.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-header-row",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["2400", "2400"]), [
        tr_with_pr(
          xe(NS_W, "trPr", [], [Element(xe(NS_W, "tblHeader", [], []))]),
          [
            tc_full(
              [
                xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], []),
                shd("4F81BD"),
              ],
              [
                w_p(None, [
                  w_run(
                    Some(w_rpr([w_flag("b"), w_val("color", "FFFFFF")])),
                    "Name",
                  ),
                ]),
              ],
            ),
            tc_full(
              [
                xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], []),
                shd("4F81BD"),
              ],
              [
                w_p(None, [
                  w_run(
                    Some(w_rpr([w_flag("b"), w_val("color", "FFFFFF")])),
                    "Score",
                  ),
                ]),
              ],
            ),
          ],
        ),
        tr([tc_w_text("2400", "Alice"), tc_w_text("2400", "94")]),
        tr([tc_w_text("2400", "Bob"), tc_w_text("2400", "87")]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 11. table-cantsplit — row with `<w:cantSplit/>` (no page break).
  // ----------------------------------------------------------------
  cases.push({
    id: "table-cantsplit",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["3000", "3000"]), [
        tr_with_pr(
          xe(NS_W, "trPr", [], [Element(xe(NS_W, "cantSplit", [], []))]),
          [tc_w_text("3000", "Atomic"), tc_w_text("3000", "Row (cantSplit)")],
        ),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 12. table-fixed-layout — `<w:tblLayout w:type="fixed"/>` forces
  //     columns to honour grid widths (no autofit).
  // ----------------------------------------------------------------
  cases.push({
    id: "table-fixed-layout",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders(), tbl_layout("fixed")], tbl_grid(["1000", "4000"]), [
        tr([tc_w_text("1000", "S"), tc_w_text("4000", "Wide column")]),
        tr([
          tc_w_text("1000", "M"),
          tc_w_text("4000", "Fixed even with long content"),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 13. table-mixed-shading — every cell a different fill colour.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-mixed-shading",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["1600", "1600", "1600"]), [
        tr([
          tc_w_props("1600", [shd("F2DCDB")], "rose"),
          tc_w_props("1600", [shd("EBF1DE")], "leaf"),
          tc_w_props("1600", [shd("DCE6F1")], "sky"),
        ]),
        tr([
          tc_w_props("1600", [shd("FFFF99")], "lemon"),
          tc_w_props("1600", [shd("E4DFEC")], "lilac"),
          tc_w_props("1600", [shd("FDE9D9")], "peach"),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 14. table-5x5 — stress-test grid alignment and border drawing.
  // ----------------------------------------------------------------
  {
    let rows : Array[@xml.Element] = []
    for r = 0; r < 5; r = r + 1 {
      let cells : Array[@xml.Element] = []
      for c = 0; c < 5; c = c + 1 {
        let label = "r" + r.to_string() + "c" + c.to_string()
        cells.push(tc_w_text("1300", label))
      }
      rows.push(tr(cells))
    }
    cases.push({
      id: "table-5x5",
      format: "docx",
      category: "table",
      content: body_of(
        tbl(
          [std_borders()],
          tbl_grid(["1300", "1300", "1300", "1300", "1300"]),
          rows,
        ),
      ),
    })
  }

  // ----------------------------------------------------------------
  // 15. table-tbllook — explicit conditional-formatting hints.
  //     (Renderer/LibreOffice may not apply distinct first-row /
  //     first-col styling without a referenced style, but the
  //     element must round-trip without breaking layout.)
  // ----------------------------------------------------------------
  cases.push({
    id: "table-tbllook",
    format: "docx",
    category: "table",
    content: body_of(
      tbl(
        [std_borders(), tbl_look("1", "1", "1", "1")],
        tbl_grid(["2000", "2000", "2000"]),
        [
          tr([
            tc_w_text("2000", "Header"),
            tc_w_text("2000", "Mid"),
            tc_w_text("2000", "Last"),
          ]),
          tr([
            tc_w_text("2000", "Row1A"),
            tc_w_text("2000", "Row1B"),
            tc_w_text("2000", "Row1C"),
          ]),
          tr([
            tc_w_text("2000", "Footer"),
            tc_w_text("2000", "Mid"),
            tc_w_text("2000", "Last"),
          ]),
        ],
      ),
    ),
  })

  // ----------------------------------------------------------------
  // 16. table-nested — a one-cell table inside another cell.
  // ----------------------------------------------------------------
  {
    let inner = tbl([std_borders()], tbl_grid(["1200", "1200"]), [
      tr([tc_w_text("1200", "inner A"), tc_w_text("1200", "inner B")]),
      tr([tc_w_text("1200", "inner C"), tc_w_text("1200", "inner D")]),
    ])
    // The nested table must be followed by an empty paragraph inside
    // the parent cell — ECMA-376 requires a `<w:p>` after a nested
    // `<w:tbl>` so the cell terminates with a paragraph.
    let outer_cell_with_inner_tbl = tc_full(
      [xe(NS_W, "tcW", [wa("w", "3000"), wa("type", "dxa")], [])],
      [],
    )
    // Manually rebuild: tcPr + inner tbl + closing paragraph.
    let nested_cell = {
      let kids : Array[@xml.Node] = []
      for n in outer_cell_with_inner_tbl.children {
        kids.push(n)
      }
      kids.push(Element(inner))
      kids.push(Element(w_p(None, [w_run(None, "")])))
      xe(NS_W, "tc", [], kids)
    }
    cases.push({
      id: "table-nested",
      format: "docx",
      category: "table",
      content: body_of(
        tbl([std_borders()], tbl_grid(["3000", "2000"]), [
          tr([nested_cell, tc_w_text("2000", "outer right")]),
          tr([tc_w_text("3000", "row 2 L"), tc_w_text("2000", "row 2 R")]),
        ]),
      ),
    })
  }

  // ----------------------------------------------------------------
  // 17. table-multipara-cell — cells whose content is multiple
  //     paragraphs (forces multi-line stacking).
  // ----------------------------------------------------------------
  cases.push({
    id: "table-multipara-cell",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["3000", "3000"]), [
        tr([
          tc_full([xe(NS_W, "tcW", [wa("w", "3000"), wa("type", "dxa")], [])], [
            w_p(None, [w_run(None, "First para line.")]),
            w_p(None, [w_run(None, "Second para in same cell.")]),
            w_p(None, [w_run(None, "Third para closes the cell.")]),
          ]),
          tc_w_text("3000", "Single-para neighbour"),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 18. table-bold-italic — bold + italic + underline text inside cells.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-bold-italic",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders()], tbl_grid(["2400", "2400"]), [
        tr([
          tc_full([xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], [])], [
            w_p(None, [w_run(Some(w_rpr([w_flag("b")])), "Bold label")]),
          ]),
          tc_full([xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], [])], [
            w_p(None, [w_run(Some(w_rpr([w_flag("i")])), "Italic value")]),
          ]),
        ]),
        tr([
          tc_full([xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], [])], [
            w_p(None, [w_run(Some(w_rpr([w_val("u", "single")])), "Underlined")]),
          ]),
          tc_full([xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], [])], [
            w_p(None, [
              w_run(
                Some(
                  w_rpr([w_flag("b"), w_flag("i"), w_val("color", "C00000")]),
                ),
                "Bold+Italic red",
              ),
            ]),
          ]),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 19. table-right-align-numeric — second column right-aligned to
  //     simulate a numeric column.
  // ----------------------------------------------------------------
  // Paragraph with `<w:jc w:val="right"/>` justification.
  {
    let right_p = fn(text : String) -> @xml.Element {
      let ppr = xe(NS_W, "pPr", [], [
        Element(xe(NS_W, "jc", [wa("val", "right")], [])),
      ])
      w_p(Some(ppr), [w_run(None, text)])
    }
    let tc_right = fn(text : String) -> @xml.Element {
      tc_full([xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], [])], [
        right_p(text),
      ])
    }
    cases.push({
      id: "table-right-align-numeric",
      format: "docx",
      category: "table",
      content: body_of(
        tbl([std_borders()], tbl_grid(["2400", "2400"]), [
          tr([tc_w_text("2400", "Item"), tc_right("Amount")]),
          tr([tc_w_text("2400", "Apples"), tc_right("12")]),
          tr([tc_w_text("2400", "Pears"), tc_right("8")]),
          tr([tc_w_text("2400", "Grand Total"), tc_right("1,234.56")]),
        ]),
      ),
    })
  }

  // ----------------------------------------------------------------
  // 20. table-thick-outer — heavy outer border, no inner borders.
  // ----------------------------------------------------------------
  {
    let thick_borders = xe(NS_W, "tblBorders", [], [
      Element(bdr("top", "single", "24", "000000")),
      Element(bdr("left", "single", "24", "000000")),
      Element(bdr("bottom", "single", "24", "000000")),
      Element(bdr("right", "single", "24", "000000")),
      Element(bdr_none("insideH")),
      Element(bdr_none("insideV")),
    ])
    cases.push({
      id: "table-thick-outer",
      format: "docx",
      category: "table",
      content: body_of(
        tbl([thick_borders], tbl_grid(["2400", "2400"]), [
          tr([tc_w_text("2400", "Thick"), tc_w_text("2400", "outline")]),
          tr([tc_w_text("2400", "no"), tc_w_text("2400", "inner")]),
        ]),
      ),
    })
  }

  // ----------------------------------------------------------------
  // 21. table-tblw-auto — explicit `tblW` type="auto".
  // ----------------------------------------------------------------
  cases.push({
    id: "table-tblw-auto",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([std_borders(), tbl_w("0", "auto")], tbl_grid(["2000", "2000"]), [
        tr([tc_w_text("2000", "auto"), tc_w_text("2000", "width")]),
        tr([tc_w_text("2000", "tblW"), tc_w_text("2000", "type=auto")]),
      ]),
    ),
  })
}
