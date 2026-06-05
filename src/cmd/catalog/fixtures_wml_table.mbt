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
  let wa = fn(local_name : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name, ns: Some(NS_W) }, value }
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

  // `<w:tblGrid>` with a tracked previous-grid snapshot at the end.
  let tbl_grid_with_change = fn(widths : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for w in widths {
      kids.push(Element(grid_col(w)))
    }
    kids.push(
      Element(
        xe(NS_W, "tblGridChange", [wa("id", "41")], [
          Element(
            xe(NS_W, "tblGrid", [], [
              Element(grid_col("1800")),
              Element(grid_col("1800")),
            ]),
          ),
        ]),
      ),
    )
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

  let rev_attrs = fn(id : String) -> Array[@xml.Attribute] {
    [wa("id", id), wa("author", "Catalog"), wa("date", "2024-01-01T00:00:00Z")]
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

  // Strict logical side variant: top/start/bottom/end.
  let tbl_cell_mar_logical = fn(
    top : String,
    start : String,
    bottom : String,
    end_ : String,
  ) -> @xml.Element {
    let side = fn(name : String, w : String) -> @xml.Element {
      xe(NS_W, name, [wa("w", w), wa("type", "dxa")], [])
    }
    xe(NS_W, "tblCellMar", [], [
      Element(side("top", top)),
      Element(side("start", start)),
      Element(side("bottom", bottom)),
      Element(side("end", end_)),
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

  // Strict logical side variant: top/start/bottom/end.
  let tc_mar_logical = fn(
    top : String,
    start : String,
    bottom : String,
    end_ : String,
  ) -> @xml.Element {
    let side = fn(name : String, w : String) -> @xml.Element {
      xe(NS_W, name, [wa("w", w), wa("type", "dxa")], [])
    }
    xe(NS_W, "tcMar", [], [
      Element(side("top", top)),
      Element(side("start", start)),
      Element(side("bottom", bottom)),
      Element(side("end", end_)),
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
      tbl([tbl_ind("1440", "dxa"), std_borders()], tbl_grid(["2000", "2000"]), [
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
      tbl([tbl_w("5000", "pct"), std_borders()], tbl_grid(["3000", "3000"]), [
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
  //     (Conformant renderers may not apply distinct first-row /
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
      tbl([tbl_w("0", "auto"), std_borders()], tbl_grid(["2000", "2000"]), [
        tr([tc_w_text("2000", "auto"), tc_w_text("2000", "width")]),
        tr([tc_w_text("2000", "tblW"), tc_w_text("2000", "type=auto")]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 22. table-cell-borders — §17.4.59 `<w:tcBorders>` per-side
  //     borders with four distinct colours (red top, green bottom,
  //     blue left, black right) so each side's colour cascade and
  //     the per-side stroke pipeline are exercised in one fixture.
  //     The table sits in a row with NO `<w:tblBorders>` cascade so
  //     the only visible strokes come from the cell-local override
  //     — drives the renderer through the tcBorders branch at
  //     `src/ecma376/wordprocessing_ml/viewer/svg.mbt:901`.
  // ----------------------------------------------------------------
  {
    let coloured_borders = xe(NS_W, "tcBorders", [], [
      Element(bdr("top", "single", "16", "C00000")),
      Element(bdr("left", "single", "16", "0070C0")),
      Element(bdr("bottom", "single", "16", "00B050")),
      Element(bdr("right", "single", "16", "000000")),
    ])
    // A second cell uses different border *styles* per side
    // (single / double / dashed / dotted) — the renderer's stroke-
    // dash translator picks each up from the `<w:val>` attribute.
    let mixed_styles = xe(NS_W, "tcBorders", [], [
      Element(bdr("top", "single", "16", "C00000")),
      Element(bdr("left", "dashed", "16", "0070C0")),
      Element(bdr("bottom", "double", "16", "00B050")),
      Element(bdr("right", "dotted", "16", "000000")),
    ])
    // The empty `<w:tblBorders>` block tells the renderer the table
    // has no cascaded borders; the only strokes that should appear
    // are the per-cell overrides, so the fixture isolates the
    // §17.4.59 path.
    let no_tbl_borders = xe(NS_W, "tblBorders", [], [
      Element(bdr_none("top")),
      Element(bdr_none("left")),
      Element(bdr_none("bottom")),
      Element(bdr_none("right")),
      Element(bdr_none("insideH")),
      Element(bdr_none("insideV")),
    ])
    cases.push({
      id: "table-cell-borders",
      format: "docx",
      category: "table",
      content: body_of(
        tbl([no_tbl_borders], tbl_grid(["3000", "3000"]), [
          tr([
            tc_w_props("3000", [coloured_borders], "Per-side colours"),
            tc_w_props("3000", [mixed_styles], "Mixed styles"),
          ]),
        ]),
      ),
    })
  }

  // ----------------------------------------------------------------
  // 23. table-cell-widths — §17.4.61 `<w:tcW>` explicit per-cell
  //     widths (1000 / 2000 / 3000 dxa).  The columns must render
  //     at their absolute widths regardless of the equal-grid hint
  //     so the renderer honours the cell-local override.  Fixed
  //     layout is set explicitly so the auto-fit pass does not
  //     redistribute widths.
  // ----------------------------------------------------------------
  cases.push({
    id: "table-cell-widths",
    format: "docx",
    category: "table",
    content: body_of(
      tbl(
        [std_borders(), tbl_layout("fixed")],
        tbl_grid(["1000", "2000", "3000"]),
        [
          tr([
            tc_w_text("1000", "1000"),
            tc_w_text("2000", "2000"),
            tc_w_text("3000", "3000"),
          ]),
          tr([
            tc_w_text("1000", "narrow"),
            tc_w_text("2000", "medium"),
            tc_w_text("3000", "wide"),
          ]),
        ],
      ),
    ),
  })

  // ----------------------------------------------------------------
  // 24. table-level-borders — §17.4.43 `<w:tblBorders>` cascades to
  //     all cells.  Each side gets its own colour at the table
  //     level (the §17.4.59 per-cell overrides are absent).  The
  //     renderer must paint the outer-edge cells with the
  //     side-matching cascade colour and the interior edges with
  //     `insideH` / `insideV` colours.
  // ----------------------------------------------------------------
  let cascade_borders = xe(NS_W, "tblBorders", [], [
    Element(bdr("top", "single", "18", "C00000")),
    Element(bdr("left", "single", "18", "0070C0")),
    Element(bdr("bottom", "single", "18", "00B050")),
    Element(bdr("right", "single", "18", "7030A0")),
    Element(bdr("insideH", "single", "8", "808080")),
    Element(bdr("insideV", "single", "8", "808080")),
  ])
  cases.push({
    id: "table-level-borders",
    format: "docx",
    category: "table",
    content: body_of(
      tbl([cascade_borders], tbl_grid(["2400", "2400", "2400"]), [
        tr([
          tc_w_text("2400", "A1"),
          tc_w_text("2400", "B1"),
          tc_w_text("2400", "C1"),
        ]),
        tr([
          tc_w_text("2400", "A2"),
          tc_w_text("2400", "B2"),
          tc_w_text("2400", "C2"),
        ]),
        tr([
          tc_w_text("2400", "A3"),
          tc_w_text("2400", "B3"),
          tc_w_text("2400", "C3"),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 25. table-advanced-properties — table / row / cell properties
  //     that are easy to miss because they often only affect layout
  //     under floating, banded, accessibility, or revision scenarios.
  //     Children are emitted in CT_TblPrBase / CT_TrPrBase /
  //     CT_TcPrBase schema order so the fixture remains usable as
  //     an XSD-valid coverage carrier, not just a QName probe.
  // ----------------------------------------------------------------
  let tblp_pr = xe(
    NS_W,
    "tblpPr",
    [
      wa("leftFromText", "180"),
      wa("rightFromText", "180"),
      wa("topFromText", "120"),
      wa("bottomFromText", "120"),
      wa("vertAnchor", "page"),
      wa("horzAnchor", "margin"),
      wa("tblpX", "720"),
      wa("tblpY", "1440"),
    ],
    [],
  )
  let tbl_props = [
    xe(NS_W, "tblStyle", [wa("val", "TableGrid")], []),
    tblp_pr,
    xe(NS_W, "tblOverlap", [wa("val", "never")], []),
    xe(NS_W, "bidiVisual", [wa("val", "0")], []),
    xe(NS_W, "tblStyleRowBandSize", [wa("val", "2")], []),
    xe(NS_W, "tblStyleColBandSize", [wa("val", "1")], []),
    tbl_w("7200", "dxa"),
    xe(NS_W, "jc", [wa("val", "center")], []),
    xe(NS_W, "tblCellSpacing", [wa("w", "80"), wa("type", "dxa")], []),
    tbl_ind("240", "dxa"),
    std_borders(),
    shd("F7F7F7"),
    tbl_layout("fixed"),
    tbl_cell_mar("120", "120", "120", "120"),
    tbl_look("1", "0", "1", "0"),
    xe(NS_W, "tblCaption", [wa("val", "Catalog advanced table")], []),
    xe(
      NS_W,
      "tblDescription",
      [wa("val", "Floating table with row offsets and fitted cells")],
      [],
    ),
  ]
  let row_props = xe(NS_W, "trPr", [], [
    Element(xe(NS_W, "gridBefore", [wa("val", "1")], [])),
    Element(xe(NS_W, "gridAfter", [wa("val", "1")], [])),
    Element(xe(NS_W, "wBefore", [wa("w", "600"), wa("type", "dxa")], [])),
    Element(xe(NS_W, "wAfter", [wa("w", "600"), wa("type", "dxa")], [])),
    Element(xe(NS_W, "cantSplit", [], [])),
    Element(tr_height("720", "atLeast")),
    Element(xe(NS_W, "tblCellSpacing", [wa("w", "60"), wa("type", "dxa")], [])),
    Element(xe(NS_W, "jc", [wa("val", "center")], [])),
  ])
  let fit_cell_props = [
    xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], []),
    shd("EAF2F8"),
    xe(NS_W, "noWrap", [wa("val", "1")], []),
    tc_mar("120", "180", "120", "180"),
    xe(NS_W, "textDirection", [wa("val", "tbRl")], []),
    xe(NS_W, "tcFitText", [wa("val", "1")], []),
    v_align("center"),
    xe(NS_W, "hideMark", [wa("val", "1")], []),
  ]
  cases.push({
    id: "table-advanced-properties",
    format: "docx",
    category: "table",
    content: body_of(
      tbl(tbl_props, tbl_grid(["2400", "2400", "2400"]), [
        tr_with_pr(row_props, [
          tc_full(fit_cell_props, [
            w_p(None, [w_run(None, "fit text vertical")]),
          ]),
          tc_w_text("2400", "row offsets"),
          tc_w_text("2400", "captioned table"),
        ]),
        tr([
          tc_w_text("2400", "band row"),
          tc_w_text("2400", "spacing"),
          tc_w_text("2400", "fixed layout"),
        ]),
      ]),
    ),
  })

  // ----------------------------------------------------------------
  // 26. table-revision-property-carriers — table/cell/row revision
  //     snapshots and cell-level change markers.  This fixture is a
  //     schema-valid carrier for low-frequency §17.13 table elements:
  //     tblGridChange, tblPrChange, tblPrEx, tblPrExChange,
  //     trPrChange, cellIns/cellDel/cellMerge, headers/header,
  //     tcPrChange, plus paragraph/run property changes in cell text.
  // ----------------------------------------------------------------
  let logical_tbl_borders = xe(NS_W, "tblBorders", [], [
    Element(bdr("top", "single", "8", "5B9BD5")),
    Element(bdr("start", "single", "8", "70AD47")),
    Element(bdr("bottom", "single", "8", "FFC000")),
    Element(bdr("end", "single", "8", "C00000")),
    Element(bdr("insideH", "single", "4", "808080")),
    Element(bdr("insideV", "single", "4", "808080")),
  ])
  let tbl_pr_base_snapshot = fn() -> @xml.Element {
    xe(NS_W, "tblPr", [], [
      Element(tbl_w("4800", "dxa")),
      Element(xe(NS_W, "jc", [wa("val", "left")], [])),
      Element(
        xe(NS_W, "tblCellSpacing", [wa("w", "40"), wa("type", "dxa")], []),
      ),
      Element(tbl_ind("120", "dxa")),
      Element(logical_tbl_borders),
      Element(shd("FFF2CC")),
      Element(tbl_layout("fixed")),
      Element(tbl_cell_mar_logical("80", "100", "80", "100")),
      Element(tbl_look("1", "0", "0", "0")),
    ])
  }
  let tbl_pr_ex_base_snapshot = fn() -> @xml.Element {
    xe(NS_W, "tblPrEx", [], [
      Element(tbl_w("4200", "dxa")),
      Element(xe(NS_W, "jc", [wa("val", "center")], [])),
      Element(
        xe(NS_W, "tblCellSpacing", [wa("w", "20"), wa("type", "dxa")], []),
      ),
      Element(tbl_ind("60", "dxa")),
      Element(logical_tbl_borders),
      Element(shd("E2F0D9")),
      Element(tbl_layout("fixed")),
      Element(tbl_cell_mar_logical("60", "80", "60", "80")),
      Element(tbl_look("1", "0", "1", "0")),
    ])
  }
  let tbl_pr_ex_with_change = xe(NS_W, "tblPrEx", [], [
    Element(tbl_w("4400", "dxa")),
    Element(xe(NS_W, "jc", [wa("val", "right")], [])),
    Element(xe(NS_W, "tblCellSpacing", [wa("w", "30"), wa("type", "dxa")], [])),
    Element(tbl_ind("90", "dxa")),
    Element(logical_tbl_borders),
    Element(shd("D9EAF7")),
    Element(tbl_layout("fixed")),
    Element(tbl_cell_mar_logical("70", "90", "70", "90")),
    Element(tbl_look("1", "1", "0", "0")),
    Element(
      xe(NS_W, "tblPrExChange", rev_attrs("42"), [
        Element(tbl_pr_ex_base_snapshot()),
      ]),
    ),
  ])
  let tr_pr_with_change = xe(NS_W, "trPr", [], [
    Element(xe(NS_W, "gridBefore", [wa("val", "1")], [])),
    Element(xe(NS_W, "gridAfter", [wa("val", "1")], [])),
    Element(tr_height("560", "atLeast")),
    Element(xe(NS_W, "tblHeader", [wa("val", "1")], [])),
    Element(xe(NS_W, "jc", [wa("val", "center")], [])),
    Element(xe(NS_W, "hidden", [wa("val", "0")], [])),
    Element(
      xe(NS_W, "trPrChange", rev_attrs("43"), [
        Element(
          xe(NS_W, "trPr", [], [
            Element(tr_height("360", "atLeast")),
            Element(xe(NS_W, "hidden", [wa("val", "1")], [])),
          ]),
        ),
      ]),
    ),
  ])
  let logical_tc_borders = xe(NS_W, "tcBorders", [], [
    Element(bdr("top", "single", "6", "4472C4")),
    Element(bdr("start", "single", "6", "70AD47")),
    Element(bdr("bottom", "single", "6", "FFC000")),
    Element(bdr("end", "single", "6", "C00000")),
  ])
  let tc_pr_with_change = [
    xe(
      NS_W,
      "cnfStyle",
      [
        wa("firstRow", "1"),
        wa("firstColumn", "1"),
        wa("lastRow", "0"),
        wa("lastColumn", "0"),
      ],
      [],
    ),
    xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], []),
    grid_span("1"),
    xe(NS_W, "hMerge", [wa("val", "restart")], []),
    v_merge_restart(),
    logical_tc_borders,
    shd("FCE4D6"),
    xe(NS_W, "noWrap", [wa("val", "0")], []),
    tc_mar_logical("80", "100", "80", "100"),
    xe(NS_W, "textDirection", [wa("val", "lrTb")], []),
    xe(NS_W, "tcFitText", [wa("val", "0")], []),
    v_align("center"),
    xe(NS_W, "hideMark", [wa("val", "0")], []),
    xe(NS_W, "headers", [], [
      Element(xe(NS_W, "header", [wa("val", "catalog-h1")], [])),
    ]),
    xe(NS_W, "cellIns", rev_attrs("44"), []),
    xe(NS_W, "tcPrChange", rev_attrs("47"), [
      Element(
        xe(NS_W, "tcPr", [], [
          Element(xe(NS_W, "tcW", [wa("w", "1800"), wa("type", "dxa")], [])),
          Element(v_align("top")),
        ]),
      ),
    ]),
  ]
  let tc_pr_cell_del = [
    xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], []),
    shd("EDEDED"),
    xe(NS_W, "cellDel", rev_attrs("45"), []),
  ]
  let tc_pr_cell_merge = [
    xe(NS_W, "tcW", [wa("w", "2400"), wa("type", "dxa")], []),
    v_merge_continue(),
    xe(
      NS_W,
      "cellMerge",
      [
        wa("id", "46"),
        wa("author", "Catalog"),
        wa("date", "2024-01-01T00:00:00Z"),
        wa("vMerge", "rest"),
        wa("vMergeOrig", "cont"),
      ],
      [],
    ),
  ]
  let paragraph_props_change = xe(NS_W, "pPr", [], [
    Element(
      xe(NS_W, "pPrChange", rev_attrs("48"), [Element(xe(NS_W, "pPr", [], []))]),
    ),
  ])
  let run_props_change = w_rpr([
    w_flag("b"),
    xe(NS_W, "rPrChange", rev_attrs("49"), [Element(w_rpr([w_flag("i")]))]),
  ])
  let revision_row = xe(
    NS_W,
    "tr",
    [
      wa("rsidRPr", "00112233"),
      wa("rsidR", "00112234"),
      wa("rsidDel", "00112235"),
      wa("rsidTr", "00112236"),
    ],
    [
      Element(tbl_pr_ex_with_change),
      Element(tr_pr_with_change),
      Element(
        tc_full(tc_pr_with_change, [
          w_p(Some(paragraph_props_change), [
            w_run(Some(run_props_change), "Tracked cell properties"),
          ]),
        ]),
      ),
      Element(
        tc_full(tc_pr_cell_del, [
          w_p(None, [w_run(None, "Deleted cell marker")]),
        ]),
      ),
    ],
  )
  cases.push({
    id: "table-revision-property-carriers",
    format: "docx",
    category: "table",
    content: body_of(
      tbl(
        [
          tbl_w("4800", "dxa"),
          xe(NS_W, "tblPrChange", rev_attrs("40"), [
            Element(tbl_pr_base_snapshot()),
          ]),
        ],
        tbl_grid_with_change(["2400", "2400"]),
        [
          revision_row,
          tr([
            tc_full(tc_pr_cell_merge, [
              w_p(None, [w_run(None, "Merged cell marker")]),
            ]),
            tc_w_text("2400", "Base"),
          ]),
        ],
      ),
    ),
  })
}
