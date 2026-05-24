// SpreadsheetML styled fixtures — each `ExtendedCase` here pairs a
// `<sheetData>` (or `<worksheet>`) with its own `<styleSheet>`, so
// the styles.xml part is exercised across the dimensions the bare
// `extended_cases()` block in fixtures.mbt does not cover:
//
//   * font variations          (§18.8.22 fonts / §18.8.20 font)
//   * extra border styles      (§18.8.4  borders)
//   * pattern fills            (§18.8.32 patternFill)
//   * multi-axis alignment     (§18.8.1  alignment)
//   * wrap / rotation / indent / shrinkToFit
//   * extra number formats     (§18.8.30 numFmt — scientific, accounting, time)
//   * mixed cellXfs            (one cell using font+fill+border+align)
//
// All helpers are file-local so this file is independently editable.
// The harness wires every fixture in via `extras_sml_styled(xcases)`
// from `extended_cases()`.

// ---- file-local QName helpers (style-sheet primitives) -----------

///|
/// `<numFmt numFmtId=.. formatCode=..>`.  Custom IDs are ≥164 per
/// §18.8.30 — Excel reserves 0..163 for built-in formats.
fn ss_num_fmt(id : String, code : String) -> @xml.Element {
  xe(NS_S, "numFmt", [xa("numFmtId", id), xa("formatCode", code)], [])
}

///|
/// `<color rgb="..">`.  Helper for child positions where ARGB hex
/// colour is needed (font colour, border colour).
fn ss_color(argb : String) -> @xml.Element {
  xe(NS_S, "color", [xa("rgb", argb)], [])
}

///|
/// `<font>` with size, name, and an arbitrary set of toggle / extra
/// children (`<b/>`, `<i/>`, `<u val=".."/>`, `<strike/>`, `<color/>`).
/// `extras` is appended after the mandatory `<sz>` + `<name>` so the
/// order matches Excel-emitted files (sz first, name last; toggles
/// in between are accepted by every consumer we test).
fn ss_font(
  sz : String,
  name : String,
  extras : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = [Element(xe(NS_S, "sz", [xa("val", sz)], []))]
  for e in extras {
    kids.push(Element(e))
  }
  kids.push(Element(xe(NS_S, "name", [xa("val", name)], [])))
  xe(NS_S, "font", [], kids)
}

///|
/// `<fill>` carrying a `<patternFill>` of the given `patternType`.
/// When `fg` / `bg` are `Some`, they become `<fgColor rgb=..>` /
/// `<bgColor rgb=..>` children of the pattern fill.  For non-`solid`
/// patterns the two-colour pair drives the hatch ink and background.
fn ss_pattern_fill(
  pattern : String,
  fg : String?,
  bg : String?,
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  match fg {
    Some(c) => kids.push(Element(xe(NS_S, "fgColor", [xa("rgb", c)], [])))
    None => ()
  }
  match bg {
    Some(c) => kids.push(Element(xe(NS_S, "bgColor", [xa("rgb", c)], [])))
    None => ()
  }
  xe(NS_S, "fill", [], [
    Element(xe(NS_S, "patternFill", [xa("patternType", pattern)], kids)),
  ])
}

///|
/// `<fill>` with `<patternFill patternType="none"/>` — the spec-default
/// fill at index 0 of `<fills>`.
fn ss_fill_none() -> @xml.Element {
  xe(NS_S, "fill", [], [
    Element(xe(NS_S, "patternFill", [xa("patternType", "none")], [])),
  ])
}

///|
/// `<fill>` with `<patternFill patternType="gray125"/>` — Excel's
/// conventional second fill slot (index 1).  Many readers expect it.
fn ss_fill_gray125() -> @xml.Element {
  xe(NS_S, "fill", [], [
    Element(xe(NS_S, "patternFill", [xa("patternType", "gray125")], [])),
  ])
}

///|
/// One border `<left>` / `<right>` / `<top>` / `<bottom>` / `<diagonal>`
/// side with a `style` attribute and an inner black `<color>`.  An
/// empty `style` means the side is omitted entirely (consumers treat
/// "no style attr" as "no edge").
fn ss_border_side(
  side : String,
  style : String,
  color : String,
) -> @xml.Element {
  if style == "" {
    xe(NS_S, side, [], [])
  } else {
    xe(NS_S, side, [xa("style", style)], [Element(ss_color(color))])
  }
}

///|
/// Full `<border>` element — each of left/right/top/bottom/diagonal is
/// supplied independently so combinations like "bottom-only" or
/// "left+right" can be expressed.  A `""` style omits the edge.
fn ss_border(
  left : String,
  right : String,
  top : String,
  bottom : String,
  diagonal : String,
  diag_attrs : Array[@xml.Attribute],
  color : String,
) -> @xml.Element {
  let kids : Array[@xml.Node] = [
    Element(ss_border_side("left", left, color)),
    Element(ss_border_side("right", right, color)),
    Element(ss_border_side("top", top, color)),
    Element(ss_border_side("bottom", bottom, color)),
  ]
  if diagonal == "" {
    kids.push(Element(xe(NS_S, "diagonal", [], [])))
  } else {
    // <diagonal> itself can carry diagonalUp/diagonalDown — but those
    // live on the <border> ELEMENT in OOXML; we accept attrs here for
    // forward-compat and only emit them when present.
    kids.push(
      Element(
        xe(NS_S, "diagonal", [xa("style", diagonal)], [Element(ss_color(color))]),
      ),
    )
  }
  // diag_attrs (e.g. diagonalUp="1") are border-level, not side-level.
  xe(NS_S, "border", diag_attrs, kids)
}

///|
/// The default plain `<border>` — every side empty.  Index 0 of
/// `<borders>` in every style sheet.
fn ss_border_none() -> @xml.Element {
  ss_border("", "", "", "", "", [], "FF000000")
}

///|
/// `<xf>` referencing the four index arrays plus an optional
/// `<alignment>` child.  Each `apply_*` flag is wired only when the
/// corresponding index is non-zero so the cellXf cleanly inherits the
/// default style when the slot isn't customised.
fn ss_cell_xf(
  num_fmt_id : String,
  font_id : String,
  fill_id : String,
  border_id : String,
  alignment : @xml.Element?,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    xa("numFmtId", num_fmt_id),
    xa("fontId", font_id),
    xa("fillId", fill_id),
    xa("borderId", border_id),
  ]
  if num_fmt_id != "0" {
    attrs.push(xa("applyNumberFormat", "1"))
  }
  if font_id != "0" {
    attrs.push(xa("applyFont", "1"))
  }
  if fill_id != "0" {
    attrs.push(xa("applyFill", "1"))
  }
  if border_id != "0" {
    attrs.push(xa("applyBorder", "1"))
  }
  let kids : Array[@xml.Node] = []
  match alignment {
    Some(a) => {
      attrs.push(xa("applyAlignment", "1"))
      kids.push(Element(a))
    }
    None => ()
  }
  xe(NS_S, "xf", attrs, kids)
}

///|
/// `<alignment>` with arbitrary attributes.  Caller supplies whichever
/// `horizontal` / `vertical` / `wrapText` / `textRotation` / `indent` /
/// `shrinkToFit` attributes are relevant.
fn ss_alignment(attrs : Array[@xml.Attribute]) -> @xml.Element {
  xe(NS_S, "alignment", attrs, [])
}

///|
/// Assemble a full `<styleSheet>` from its five primary children — the
/// child order matches §18.8.39: numFmts, fonts, fills, borders, cellXfs.
fn ss_sheet(
  num_fmts : Array[@xml.Element],
  fonts : Array[@xml.Element],
  fills : Array[@xml.Element],
  borders : Array[@xml.Element],
  cell_xfs : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  if num_fmts.length() > 0 {
    let nf : Array[@xml.Node] = []
    for f in num_fmts {
      nf.push(Element(f))
    }
    kids.push(
      Element(
        xe(NS_S, "numFmts", [xa("count", num_fmts.length().to_string())], nf),
      ),
    )
  }
  let fn_ : Array[@xml.Node] = []
  for f in fonts {
    fn_.push(Element(f))
  }
  kids.push(
    Element(xe(NS_S, "fonts", [xa("count", fonts.length().to_string())], fn_)),
  )
  let fi : Array[@xml.Node] = []
  for f in fills {
    fi.push(Element(f))
  }
  kids.push(
    Element(xe(NS_S, "fills", [xa("count", fills.length().to_string())], fi)),
  )
  let bd : Array[@xml.Node] = []
  for b in borders {
    bd.push(Element(b))
  }
  kids.push(
    Element(
      xe(NS_S, "borders", [xa("count", borders.length().to_string())], bd),
    ),
  )
  let cx : Array[@xml.Node] = []
  for c in cell_xfs {
    cx.push(Element(c))
  }
  kids.push(
    Element(
      xe(NS_S, "cellXfs", [xa("count", cell_xfs.length().to_string())], cx),
    ),
  )
  xe(NS_S, "styleSheet", [], kids)
}

///|
/// `<c>` numeric cell carrying both a `s=` style index and a `<v>`.
fn s_cell_styled_x(
  ref_ : String,
  value : String,
  style_idx : String,
) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_), xa("s", style_idx)], [
    Element(xe(NS_S, "v", [], [Text(value)])),
  ])
}

///|
/// `<c t="inlineStr" s=..><is><t>..</t></is></c>` — string cell with a
/// style index.
fn s_inline_styled_x(
  ref_ : String,
  text : String,
  style_idx : String,
) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_), xa("s", style_idx), xa("t", "inlineStr")], [
    Element(xe(NS_S, "is", [], [Element(xe(NS_S, "t", [], [Text(text)]))])),
  ])
}

///|
/// `<row r=..>` containing the supplied cells.  Local to this file so
/// nothing in `fixtures_helpers.mbt` needs to change.
fn s_row_x(num : String, cells : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cells {
    kids.push(Element(c))
  }
  xe(NS_S, "row", [xa("r", num)], kids)
}

///|
/// Helper that wraps `<sheetData>` plus an explicit `<cols>` block in
/// a `<worksheet>` element — needed for fixtures whose layout requires
/// a specific column width (wrap, shrinkToFit, rotation).
fn ws_with_cols(
  cols : Array[@xml.Element],
  sheet_data : @xml.Element,
) -> @xml.Element {
  let cn : Array[@xml.Node] = []
  for c in cols {
    cn.push(Element(c))
  }
  xe(NS_S, "worksheet", [], [
    Element(xe(NS_S, "cols", [], cn)),
    Element(sheet_data),
  ])
}

///|
/// `<col min=.. max=.. width=.. customWidth="1">` shortcut.
fn ws_col(min : String, max : String, width : String) -> @xml.Element {
  xe(
    NS_S,
    "col",
    [xa("min", min), xa("max", max), xa("width", width), xa("customWidth", "1")],
    [],
  )
}

///|
/// `<row r=.. ht=.. customHeight="1">` containing `cells` — explicit
/// row height is needed for the rotated/wrapped fixtures so the rotated
/// glyph and the wrapped second line have room to render.
fn s_row_tall(
  num : String,
  ht : String,
  cells : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cells {
    kids.push(Element(c))
  }
  xe(NS_S, "row", [xa("r", num), xa("ht", ht), xa("customHeight", "1")], kids)
}

// ---- entry point --------------------------------------------------

///|
/// Push styled SpreadsheetML fixtures.  Each pushes a single
/// `ExtendedCase` with its own `styleSheet` so the styles.xml part is
/// stressed across new dimensions (font, pattern, alignment axis,
/// rotation, wrap, shrinkToFit, indent, scientific / accounting / time
/// number formats, mixed multi-attribute cellXfs).
fn extras_sml_styled(xcases : Array[ExtendedCase]) -> Unit {
  // ---- 1. font variations: bold / italic / underline / strike ----
  // Five fonts (default + four toggle variants), each pointed at by a
  // dedicated cellXf so the cell `s=` can pick the variant.
  let font_toggles_styles = ss_sheet(
    [],
    [
      // 0 — plain.
      ss_font("11", "Calibri", []),
      // 1 — bold.
      ss_font("11", "Calibri", [xe(NS_S, "b", [xa("val", "1")], [])]),
      // 2 — italic.
      ss_font("11", "Calibri", [xe(NS_S, "i", [xa("val", "1")], [])]),
      // 3 — underline single.
      ss_font("11", "Calibri", [xe(NS_S, "u", [xa("val", "single")], [])]),
      // 4 — underline double.
      ss_font("11", "Calibri", [xe(NS_S, "u", [xa("val", "double")], [])]),
      // 5 — strike-through.
      ss_font("11", "Calibri", [xe(NS_S, "strike", [xa("val", "1")], [])]),
    ],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border_none()],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "1", "0", "0", None),
      ss_cell_xf("0", "2", "0", "0", None),
      ss_cell_xf("0", "3", "0", "0", None),
      ss_cell_xf("0", "4", "0", "0", None),
      ss_cell_xf("0", "5", "0", "0", None),
    ],
  )
  xcases.push({
    id: "cell-font-toggles",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_x("1", [
          s_inline_styled_x("A1", "plain", "0"),
          s_inline_styled_x("B1", "bold", "1"),
          s_inline_styled_x("C1", "italic", "2"),
          s_inline_styled_x("D1", "under1", "3"),
          s_inline_styled_x("E1", "under2", "4"),
          s_inline_styled_x("F1", "strike", "5"),
        ]),
      ),
    ]),
    styles: Some(font_toggles_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 2. font size variations ------------------------------------
  // Fonts of 8 / 10 / 14 / 18 / 24 pt — exercises the size dimension.
  let font_sizes_styles = ss_sheet(
    [],
    [
      ss_font("11", "Calibri", []),
      ss_font("8", "Calibri", []),
      ss_font("10", "Calibri", []),
      ss_font("14", "Calibri", []),
      ss_font("18", "Calibri", []),
      ss_font("24", "Calibri", []),
    ],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border_none()],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "1", "0", "0", None),
      ss_cell_xf("0", "2", "0", "0", None),
      ss_cell_xf("0", "3", "0", "0", None),
      ss_cell_xf("0", "4", "0", "0", None),
      ss_cell_xf("0", "5", "0", "0", None),
    ],
  )
  xcases.push({
    id: "cell-font-sizes",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_tall("1", "32", [
          s_inline_styled_x("A1", "8pt", "1"),
          s_inline_styled_x("B1", "10pt", "2"),
          s_inline_styled_x("C1", "14pt", "3"),
          s_inline_styled_x("D1", "18pt", "4"),
          s_inline_styled_x("E1", "24pt", "5"),
        ]),
      ),
    ]),
    styles: Some(font_sizes_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 3. font colours ---------------------------------------------
  let font_colors_styles = ss_sheet(
    [],
    [
      ss_font("11", "Calibri", []),
      ss_font("11", "Calibri", [ss_color("FFC00000")]), // red
      ss_font("11", "Calibri", [ss_color("FF00B050")]), // green
      ss_font("11", "Calibri", [ss_color("FF0070C0")]), // blue
      ss_font("11", "Calibri", [ss_color("FFFFC000")]), // amber
      ss_font("11", "Calibri", [ss_color("FF7030A0")]), // purple
    ],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border_none()],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "1", "0", "0", None),
      ss_cell_xf("0", "2", "0", "0", None),
      ss_cell_xf("0", "3", "0", "0", None),
      ss_cell_xf("0", "4", "0", "0", None),
      ss_cell_xf("0", "5", "0", "0", None),
    ],
  )
  xcases.push({
    id: "cell-font-colors",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_x("1", [
          s_inline_styled_x("A1", "red", "1"),
          s_inline_styled_x("B1", "green", "2"),
          s_inline_styled_x("C1", "blue", "3"),
          s_inline_styled_x("D1", "amber", "4"),
          s_inline_styled_x("E1", "purple", "5"),
        ]),
      ),
    ]),
    styles: Some(font_colors_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 4. font names (Calibri / Cambria / Courier / Times) -------
  let font_names_styles = ss_sheet(
    [],
    [
      ss_font("11", "Calibri", []),
      ss_font("11", "Cambria", []),
      ss_font("11", "Courier New", []),
      ss_font("11", "Times New Roman", []),
      ss_font("11", "Arial", []),
    ],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border_none()],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "1", "0", "0", None),
      ss_cell_xf("0", "2", "0", "0", None),
      ss_cell_xf("0", "3", "0", "0", None),
      ss_cell_xf("0", "4", "0", "0", None),
    ],
  )
  xcases.push({
    id: "cell-font-faces",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_x("1", [
          s_inline_styled_x("A1", "Calibri", "0"),
          s_inline_styled_x("B1", "Cambria", "1"),
          s_inline_styled_x("C1", "Courier", "2"),
          s_inline_styled_x("D1", "Times", "3"),
          s_inline_styled_x("E1", "Arial", "4"),
        ]),
      ),
    ]),
    styles: Some(font_names_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 5. partial borders: top-only / bottom-only / left+right ---
  let partial_border_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [
      ss_border_none(),
      // top-only
      ss_border("", "", "thin", "", "", [], "FF000000"),
      // bottom-only
      ss_border("", "", "", "thin", "", [], "FF000000"),
      // left+right
      ss_border("thin", "thin", "", "", "", [], "FF000000"),
      // top+bottom
      ss_border("", "", "thin", "thin", "", [], "FF000000"),
    ],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "0", "0", "1", None),
      ss_cell_xf("0", "0", "0", "2", None),
      ss_cell_xf("0", "0", "0", "3", None),
      ss_cell_xf("0", "0", "0", "4", None),
    ],
  )
  xcases.push({
    id: "cell-border-partials",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_x("1", [
          s_inline_styled_x("A1", "top", "1"),
          s_inline_styled_x("B1", "bottom", "2"),
          s_inline_styled_x("C1", "L+R", "3"),
          s_inline_styled_x("D1", "T+B", "4"),
        ]),
      ),
    ]),
    styles: Some(partial_border_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 6. dashed / dotted / hair border styles -------------------
  let dashed_border_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [
      ss_border_none(),
      ss_border("dashed", "dashed", "dashed", "dashed", "", [], "FF000000"),
      ss_border("dotted", "dotted", "dotted", "dotted", "", [], "FF000000"),
      ss_border("hair", "hair", "hair", "hair", "", [], "FF000000"),
      ss_border("dashDot", "dashDot", "dashDot", "dashDot", "", [], "FF000000"),
    ],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "0", "0", "1", None),
      ss_cell_xf("0", "0", "0", "2", None),
      ss_cell_xf("0", "0", "0", "3", None),
      ss_cell_xf("0", "0", "0", "4", None),
    ],
  )
  xcases.push({
    id: "cell-border-dashed",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_x("1", [
          s_inline_styled_x("A1", "dashed", "1"),
          s_inline_styled_x("B1", "dotted", "2"),
          s_inline_styled_x("C1", "hair", "3"),
          s_inline_styled_x("D1", "dashDot", "4"),
        ]),
      ),
    ]),
    styles: Some(dashed_border_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 7. diagonal borders ---------------------------------------
  // Diagonal up, diagonal down, both.  diagonalUp / diagonalDown live
  // on the <border> ELEMENT itself.
  let diagonal_border_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [
      ss_border_none(),
      ss_border("", "", "", "", "thin", [xa("diagonalUp", "1")], "FF000000"),
      ss_border("", "", "", "", "thin", [xa("diagonalDown", "1")], "FF000000"),
      ss_border(
        "",
        "",
        "",
        "",
        "thin",
        [xa("diagonalUp", "1"), xa("diagonalDown", "1")],
        "FF000000",
      ),
    ],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "0", "0", "1", None),
      ss_cell_xf("0", "0", "0", "2", None),
      ss_cell_xf("0", "0", "0", "3", None),
    ],
  )
  xcases.push({
    id: "cell-border-diagonal",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_tall("1", "24", [
          s_inline_styled_x("A1", "up", "1"),
          s_inline_styled_x("B1", "down", "2"),
          s_inline_styled_x("C1", "both", "3"),
        ]),
      ),
    ]),
    styles: Some(diagonal_border_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 8. pattern fills (gray25 / 50 / 75) -----------------------
  // Black ink + transparent bg; the engine should hatch each square.
  let pattern_fills_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [
      ss_fill_none(),
      ss_fill_gray125(),
      ss_pattern_fill("gray0625", Some("FF000000"), Some("FFFFFFFF")),
      ss_pattern_fill("gray125", Some("FF000000"), Some("FFFFFFFF")),
      ss_pattern_fill("gray25", Some("FF000000"), Some("FFFFFFFF")),
      ss_pattern_fill("gray50", Some("FF000000"), Some("FFFFFFFF")),
      ss_pattern_fill("gray75", Some("FF000000"), Some("FFFFFFFF")),
    ],
    [ss_border_none()],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "0", "2", "0", None),
      ss_cell_xf("0", "0", "3", "0", None),
      ss_cell_xf("0", "0", "4", "0", None),
      ss_cell_xf("0", "0", "5", "0", None),
      ss_cell_xf("0", "0", "6", "0", None),
    ],
  )
  xcases.push({
    id: "cell-fill-gray-patterns",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_tall("1", "30", [
          s_inline_styled_x("A1", "g0625", "1"),
          s_inline_styled_x("B1", "g125", "2"),
          s_inline_styled_x("C1", "g25", "3"),
          s_inline_styled_x("D1", "g50", "4"),
          s_inline_styled_x("E1", "g75", "5"),
        ]),
      ),
    ]),
    styles: Some(pattern_fills_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 9. directional pattern fills ------------------------------
  // lightHorizontal / darkHorizontal / lightVertical / darkUp / darkDown.
  let dir_pattern_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [
      ss_fill_none(),
      ss_fill_gray125(),
      ss_pattern_fill("lightHorizontal", Some("FF000000"), Some("FFFFFFFF")),
      ss_pattern_fill("darkHorizontal", Some("FF000000"), Some("FFFFFFFF")),
      ss_pattern_fill("lightVertical", Some("FF000000"), Some("FFFFFFFF")),
      ss_pattern_fill("darkUp", Some("FF000000"), Some("FFFFFFFF")),
      ss_pattern_fill("darkDown", Some("FF000000"), Some("FFFFFFFF")),
    ],
    [ss_border_none()],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("0", "0", "2", "0", None),
      ss_cell_xf("0", "0", "3", "0", None),
      ss_cell_xf("0", "0", "4", "0", None),
      ss_cell_xf("0", "0", "5", "0", None),
      ss_cell_xf("0", "0", "6", "0", None),
    ],
  )
  xcases.push({
    id: "cell-fill-directional-patterns",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row_tall("1", "30", [
          s_inline_styled_x("A1", "lightH", "1"),
          s_inline_styled_x("B1", "darkH", "2"),
          s_inline_styled_x("C1", "lightV", "3"),
          s_inline_styled_x("D1", "darkUp", "4"),
          s_inline_styled_x("E1", "darkDn", "5"),
        ]),
      ),
    ]),
    styles: Some(dir_pattern_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 10. multi-axis alignment (horizontal × vertical) ---------
  let align_2d_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border("thin", "thin", "thin", "thin", "", [], "FF999999")],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("horizontal", "left"), xa("vertical", "top")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("horizontal", "center"), xa("vertical", "top")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("horizontal", "right"), xa("vertical", "top")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("horizontal", "left"), xa("vertical", "center")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(
          ss_alignment([xa("horizontal", "center"), xa("vertical", "center")]),
        ),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(
          ss_alignment([xa("horizontal", "right"), xa("vertical", "center")]),
        ),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("horizontal", "left"), xa("vertical", "bottom")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(
          ss_alignment([xa("horizontal", "center"), xa("vertical", "bottom")]),
        ),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(
          ss_alignment([xa("horizontal", "right"), xa("vertical", "bottom")]),
        ),
      ),
    ],
  )
  xcases.push({
    id: "cell-alignment-2d",
    format: "xlsx",
    category: "cell",
    content: ws_with_cols(
      [ws_col("1", "3", "14")],
      xe(NS_S, "sheetData", [], [
        Element(
          s_row_tall("1", "40", [
            s_inline_styled_x("A1", "TL", "1"),
            s_inline_styled_x("B1", "TC", "2"),
            s_inline_styled_x("C1", "TR", "3"),
          ]),
        ),
        Element(
          s_row_tall("2", "40", [
            s_inline_styled_x("A2", "ML", "4"),
            s_inline_styled_x("B2", "MC", "5"),
            s_inline_styled_x("C2", "MR", "6"),
          ]),
        ),
        Element(
          s_row_tall("3", "40", [
            s_inline_styled_x("A3", "BL", "7"),
            s_inline_styled_x("B3", "BC", "8"),
            s_inline_styled_x("C3", "BR", "9"),
          ]),
        ),
      ]),
    ),
    styles: Some(align_2d_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 11. wrap text in a narrow column --------------------------
  let wrap_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border("thin", "thin", "thin", "thin", "", [], "FF000000")],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("wrapText", "1"), xa("vertical", "top")])),
      ),
    ],
  )
  xcases.push({
    id: "cell-alignment-wrap",
    format: "xlsx",
    category: "cell",
    content: ws_with_cols(
      [ws_col("1", "1", "14")],
      xe(NS_S, "sheetData", [], [
        Element(
          s_row_tall("1", "60", [
            s_inline_styled_x(
              "A1", "This is a long sentence that should wrap to multiple lines",
              "1",
            ),
          ]),
        ),
      ]),
    ),
    styles: Some(wrap_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 12. text rotation (45 / 90 / -45) ------------------------
  let rotation_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border("thin", "thin", "thin", "thin", "", [], "FF000000")],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("textRotation", "45")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("textRotation", "90")])),
      ),
      // textRotation values 91..180 encode counter-clockwise -1..-90,
      // so 135 == -45° per §18.8.1.
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("textRotation", "135")])),
      ),
      // Stacked vertical: textRotation="255" is the special "vertical"
      // value (glyphs stacked, not rotated).
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("textRotation", "255")])),
      ),
    ],
  )
  xcases.push({
    id: "cell-alignment-rotation",
    format: "xlsx",
    category: "cell",
    content: ws_with_cols(
      [ws_col("1", "4", "10")],
      xe(NS_S, "sheetData", [], [
        Element(
          s_row_tall("1", "70", [
            s_inline_styled_x("A1", "Tilt45", "1"),
            s_inline_styled_x("B1", "Vert90", "2"),
            s_inline_styled_x("C1", "Tilt-45", "3"),
            s_inline_styled_x("D1", "Stack", "4"),
          ]),
        ),
      ]),
    ),
    styles: Some(rotation_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 13. indent levels (0..4) ---------------------------------
  let indent_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border_none()],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "0",
        Some(ss_alignment([xa("horizontal", "left"), xa("indent", "1")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "0",
        Some(ss_alignment([xa("horizontal", "left"), xa("indent", "2")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "0",
        Some(ss_alignment([xa("horizontal", "left"), xa("indent", "3")])),
      ),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "0",
        Some(ss_alignment([xa("horizontal", "left"), xa("indent", "4")])),
      ),
    ],
  )
  xcases.push({
    id: "cell-alignment-indent",
    format: "xlsx",
    category: "cell",
    content: ws_with_cols(
      [ws_col("1", "1", "30")],
      xe(NS_S, "sheetData", [], [
        Element(s_row_x("1", [s_inline_styled_x("A1", "Indent 0", "0")])),
        Element(s_row_x("2", [s_inline_styled_x("A2", "Indent 1", "1")])),
        Element(s_row_x("3", [s_inline_styled_x("A3", "Indent 2", "2")])),
        Element(s_row_x("4", [s_inline_styled_x("A4", "Indent 3", "3")])),
        Element(s_row_x("5", [s_inline_styled_x("A5", "Indent 4", "4")])),
      ]),
    ),
    styles: Some(indent_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 14. shrinkToFit with overflowing text --------------------
  let shrink_styles = ss_sheet(
    [],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border("thin", "thin", "thin", "thin", "", [], "FF000000")],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "1",
        Some(ss_alignment([xa("shrinkToFit", "1")])),
      ),
    ],
  )
  xcases.push({
    id: "cell-alignment-shrink",
    format: "xlsx",
    category: "cell",
    content: ws_with_cols(
      [ws_col("1", "1", "10")],
      xe(NS_S, "sheetData", [], [
        Element(s_row_x("1", [s_inline_styled_x("A1", "WithoutShrink", "0")])),
        Element(s_row_x("2", [s_inline_styled_x("A2", "WithShrinkToFit", "1")])),
      ]),
    ),
    styles: Some(shrink_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 15. scientific / accounting / time number formats --------
  // 0.00E+00, accounting (_-* #,##0.00_-), hh:mm AM/PM, [h]:mm:ss elapsed.
  let extra_numfmt_styles = ss_sheet(
    [
      ss_num_fmt("164", "0.00E+00"),
      ss_num_fmt("165", "_-* #,##0.00_-"),
      ss_num_fmt("166", "hh:mm AM/PM"),
      ss_num_fmt("167", "[h]:mm:ss"),
      ss_num_fmt("168", "##0.0E+0"),
    ],
    [ss_font("11", "Calibri", [])],
    [ss_fill_none(), ss_fill_gray125()],
    [ss_border_none()],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      ss_cell_xf("164", "0", "0", "0", None),
      ss_cell_xf("165", "0", "0", "0", None),
      ss_cell_xf("166", "0", "0", "0", None),
      ss_cell_xf("167", "0", "0", "0", None),
      ss_cell_xf("168", "0", "0", "0", None),
    ],
  )
  xcases.push({
    id: "cell-number-formats-extra",
    format: "xlsx",
    category: "cell",
    content: ws_with_cols(
      [ws_col("1", "2", "16")],
      xe(NS_S, "sheetData", [], [
        Element(
          s_row_x("1", [
            s_inline_styled_x("A1", "Scientific", "0"),
            s_cell_styled_x("B1", "12345.6789", "1"),
          ]),
        ),
        Element(
          s_row_x("2", [
            s_inline_styled_x("A2", "Accounting", "0"),
            s_cell_styled_x("B2", "1234.56", "2"),
          ]),
        ),
        Element(
          s_row_x("3", [
            s_inline_styled_x("A3", "TimeAMPM", "0"),
            // 0.5625 == 13:30 → "01:30 PM"
            s_cell_styled_x("B3", "0.5625", "3"),
          ]),
        ),
        Element(
          s_row_x("4", [
            s_inline_styled_x("A4", "ElapsedH", "0"),
            // 2.5 == 60h
            s_cell_styled_x("B4", "2.5", "4"),
          ]),
        ),
        Element(
          s_row_x("5", [
            s_inline_styled_x("A5", "EngSci", "0"),
            s_cell_styled_x("B5", "98700", "5"),
          ]),
        ),
      ]),
    ),
    styles: Some(extra_numfmt_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 16. mixed cellXf — font + fill + border + alignment in one
  // Five distinct fully-decorated cellXfs, exercising the cellXf
  // resolver's intersection logic (rather than each style being a
  // single dimension).
  let mixed_styles = ss_sheet(
    [ss_num_fmt("164", "$#,##0.00")],
    [
      ss_font("11", "Calibri", []),
      ss_font("12", "Calibri", [
        xe(NS_S, "b", [xa("val", "1")], []),
        ss_color("FFFFFFFF"),
      ]),
      ss_font("11", "Calibri", [ss_color("FFC00000")]),
      ss_font("11", "Calibri", [
        xe(NS_S, "i", [xa("val", "1")], []),
        ss_color("FF003366"),
      ]),
    ],
    [
      ss_fill_none(),
      ss_fill_gray125(),
      ss_pattern_fill("solid", Some("FF1F4E78"), Some("FF000000")),
      ss_pattern_fill("solid", Some("FFFFF2CC"), Some("FF000000")),
      ss_pattern_fill("solid", Some("FFE2EFDA"), Some("FF000000")),
    ],
    [
      ss_border_none(),
      ss_border("medium", "medium", "medium", "medium", "", [], "FF000000"),
      ss_border("thin", "thin", "thin", "thin", "", [], "FF7F7F7F"),
    ],
    [
      ss_cell_xf("0", "0", "0", "0", None),
      // Header — bold white on dark blue, centred, medium border.
      ss_cell_xf(
        "0",
        "1",
        "2",
        "1",
        Some(
          ss_alignment([xa("horizontal", "center"), xa("vertical", "center")]),
        ),
      ),
      // Body — red text on cream, accounting-format, right-aligned, thin border.
      ss_cell_xf(
        "164",
        "2",
        "3",
        "2",
        Some(
          ss_alignment([xa("horizontal", "right"), xa("vertical", "center")]),
        ),
      ),
      // Body alt — navy italic on mint, thin border, right-aligned.
      ss_cell_xf(
        "164",
        "3",
        "4",
        "2",
        Some(
          ss_alignment([xa("horizontal", "right"), xa("vertical", "center")]),
        ),
      ),
    ],
  )
  xcases.push({
    id: "cell-mixed-styles",
    format: "xlsx",
    category: "cell",
    content: ws_with_cols(
      [ws_col("1", "1", "12"), ws_col("2", "2", "16")],
      xe(NS_S, "sheetData", [], [
        Element(
          s_row_tall("1", "26", [
            s_inline_styled_x("A1", "Item", "1"),
            s_inline_styled_x("B1", "Amount", "1"),
          ]),
        ),
        Element(
          s_row_tall("2", "22", [
            s_inline_styled_x("A2", "Widgets", "2"),
            s_cell_styled_x("B2", "1234.50", "2"),
          ]),
        ),
        Element(
          s_row_tall("3", "22", [
            s_inline_styled_x("A3", "Gadgets", "3"),
            s_cell_styled_x("B3", "9876.25", "3"),
          ]),
        ),
        Element(
          s_row_tall("4", "22", [
            s_inline_styled_x("A4", "Doodads", "2"),
            s_cell_styled_x("B4", "500.00", "2"),
          ]),
        ),
      ]),
    ),
    styles: Some(mixed_styles),
    numbering: None,
    doc_styles: None,
  })
}
