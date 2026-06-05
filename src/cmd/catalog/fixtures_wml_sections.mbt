// WordprocessingML section / page-settings visual fixtures.
//
// Each fixture builds a `<w:body>` containing several filler
// paragraphs followed by a trailing `<w:sectPr>` describing the
// desired page geometry (size, margins, columns).  By isolating one
// §17.6 feature per case, a render regression points at a single
// section-property family.
//
// See `fixtures_wml_run.mbt` for the editing convention.
//
// Referenced sections of ECMA-376 Part 1:
//   §17.6.4  cols   — column layout (number, widths, separators)
//   §17.6.11 pgMar  — page margins (top/bottom/left/right/gutter…)
//   §17.6.13 pgSz   — page size (width, height, orientation)
//   §17.6.17 sectPr — section properties container

///|
fn extras_wml_sections(cases : Array[VisualCase]) -> Unit {
  // ---- Local helpers -------------------------------------------
  // A `w:`-prefixed attribute.  `<w:sectPr>` children carry their
  // attributes in the WML namespace, so we cannot use the plain
  // `xa()` helper (which emits no prefix).
  let w_attr = fn(localn : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name: localn, ns: Some(NS_W) }, value }
  }
  // `<w:pgSz>` with width, height, and optional orientation
  // ("portrait" / "landscape").  Dimensions are in twentieths of a
  // point (1/1440 inch).
  let pg_sz = fn(w : String, h : String, orient : String?) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = [w_attr("w", w), w_attr("h", h)]
    match orient {
      Some(o) => attrs.push(w_attr("orient", o))
      None => ()
    }
    xe(NS_W, "pgSz", attrs, [])
  }
  // `<w:pgMar>` with the four basic margins plus optional gutter,
  // header, and footer offsets.  Values are in twentieths of a
  // point.  Header/footer offsets default to 720 (0.5") if omitted
  // and are needed so a header band reserves visual space.
  let pg_mar = fn(
    top : String,
    bottom : String,
    left : String,
    right : String,
    gutter : String?,
  ) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = [
      w_attr("top", top),
      w_attr("right", right),
      w_attr("bottom", bottom),
      w_attr("left", left),
      w_attr("header", "720"),
      w_attr("footer", "720"),
      w_attr("gutter", gutter.unwrap_or("0")),
    ]
    xe(NS_W, "pgMar", attrs, [])
  }
  // `<w:cols>` element.  When `widths` is non-empty we emit
  // `equalWidth="0"` and one `<w:col w:w="…"/>` child per entry;
  // otherwise the columns share width as governed by `space`.
  // `sep` (vertical separator line) maps to `w:sep="1"` when true.
  let cols = fn(
    num : String,
    space : String?,
    sep : Bool,
    widths : Array[(String, String)],
  ) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = [w_attr("num", num)]
    match space {
      Some(s) => attrs.push(w_attr("space", s))
      None => ()
    }
    if sep {
      attrs.push(w_attr("sep", "1"))
    }
    if widths.length() > 0 {
      attrs.push(w_attr("equalWidth", "0"))
    }
    let kids : Array[@xml.Node] = []
    for w in widths {
      kids.push(
        Element(xe(NS_W, "col", [w_attr("w", w.0), w_attr("space", w.1)], [])),
      )
    }
    xe(NS_W, "cols", attrs, kids)
  }
  // Page border side used by `<w:pgBorders>`.
  let pg_border_side = fn(name : String, color : String) -> @xml.Element {
    xe(
      NS_W,
      name,
      [
        w_attr("val", "single"),
        w_attr("color", color),
        w_attr("sz", "12"),
        w_attr("space", "24"),
      ],
      [],
    )
  }
  let pg_borders = fn() -> @xml.Element {
    xe(
      NS_W,
      "pgBorders",
      [
        w_attr("zOrder", "front"),
        w_attr("display", "allPages"),
        w_attr("offsetFrom", "text"),
      ],
      [
        Element(pg_border_side("top", "4472C4")),
        Element(pg_border_side("left", "70AD47")),
        Element(pg_border_side("bottom", "C00000")),
        Element(pg_border_side("right", "7030A0")),
      ],
    )
  }
  // Wrap a list of section-property elements as `<w:sectPr>`.
  let sect_pr = fn(children : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in children {
      kids.push(Element(c))
    }
    xe(NS_W, "sectPr", [], kids)
  }
  // Produce `n` filler paragraphs of representative body prose so
  // each fixture exercises real wrapping under the chosen page
  // size / margins / columns.  Long enough to overflow a narrow
  // column but short enough to keep the snapshot stable.
  let fill_text = fn(n : Int) -> Array[@xml.Node] {
    let lines = [
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " +
      "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "Ut enim ad minim veniam, quis nostrud exercitation ullamco " +
      "laboris nisi ut aliquip ex ea commodo consequat.",
      "Duis aute irure dolor in reprehenderit in voluptate velit " +
      "esse cillum dolore eu fugiat nulla pariatur.",
      "Excepteur sint occaecat cupidatat non proident, sunt in culpa " +
      "qui officia deserunt mollit anim id est laborum.",
      "Sed ut perspiciatis unde omnis iste natus error sit " +
      "voluptatem accusantium doloremque laudantium, totam rem aperiam.",
      "Eaque ipsa quae ab illo inventore veritatis et quasi " +
      "architecto beatae vitae dicta sunt explicabo.",
    ]
    let kids : Array[@xml.Node] = []
    for i in 0..<n {
      let text = lines[i % lines.length()]
      kids.push(Element(w_p(None, [w_run(None, text)])))
    }
    kids
  }
  // Build a `<w:body>` containing `n` filler paragraphs and the
  // supplied trailing `<w:sectPr>`.
  let body = fn(n : Int, sect : @xml.Element) -> @xml.Element {
    let kids = fill_text(n)
    kids.push(Element(sect))
    xe(NS_W, "body", [], kids)
  }

  // =====================================================================
  // §17.6.13 pgSz — page sizes
  // =====================================================================

  // Baseline US Letter — `<w:pgSz w:w="12240" w:h="15840"/>`.  This is
  // the default size but emitting it explicitly confirms the round-
  // trip preserves the value when present.
  cases.push({
    id: "section-pgsz-letter",
    format: "docx",
    category: "section",
    content: body(4, sect_pr([pg_sz("12240", "15840", None)])),
  })

  // A4 — `<w:pgSz w:w="11906" w:h="16838"/>` (210 × 297 mm).
  cases.push({
    id: "section-pgsz-a4",
    format: "docx",
    category: "section",
    content: body(4, sect_pr([pg_sz("11906", "16838", None)])),
  })

  // A3 — `<w:pgSz w:w="16838" w:h="23811"/>` (297 × 420 mm).  Larger
  // page; same prose footprint should look smaller relative to the
  // page than under Letter / A4.
  cases.push({
    id: "section-pgsz-a3",
    format: "docx",
    category: "section",
    content: body(4, sect_pr([pg_sz("16838", "23811", None)])),
  })

  // US Tabloid — `<w:pgSz w:w="15840" w:h="24480"/>` (11 × 17").
  cases.push({
    id: "section-pgsz-tabloid",
    format: "docx",
    category: "section",
    content: body(4, sect_pr([pg_sz("15840", "24480", None)])),
  })

  // Landscape Letter — `<w:pgSz w:w="15840" w:h="12240"
  // w:orient="landscape"/>`.  Wider than tall; wrapping should
  // produce fewer lines for the same prose.
  cases.push({
    id: "section-pgsz-landscape-letter",
    format: "docx",
    category: "section",
    content: body(4, sect_pr([pg_sz("15840", "12240", Some("landscape"))])),
  })

  // =====================================================================
  // §17.6.11 pgMar — page margins
  // =====================================================================

  // Narrow margins — all four at 720 (0.5").  More text per page.
  cases.push({
    id: "section-margins-narrow",
    format: "docx",
    category: "section",
    content: body(
      5,
      sect_pr([
        pg_sz("12240", "15840", None),
        pg_mar("720", "720", "720", "720", None),
      ]),
    ),
  })

  // Wide margins — all four at 2880 (2").  Less text per page; the
  // text block is visibly inset.
  cases.push({
    id: "section-margins-wide",
    format: "docx",
    category: "section",
    content: body(
      5,
      sect_pr([
        pg_sz("12240", "15840", None),
        pg_mar("2880", "2880", "2880", "2880", None),
      ]),
    ),
  })

  // Asymmetric margins — different top / bottom / left / right.
  // Stresses the renderer's distinct handling of each side.
  cases.push({
    id: "section-margins-asymmetric",
    format: "docx",
    category: "section",
    content: body(
      5,
      sect_pr([
        pg_sz("12240", "15840", None),
        // top=1" (1440), bottom=2" (2880), left=0.5" (720), right=1.5" (2160)
        pg_mar("1440", "2880", "720", "2160", None),
      ]),
    ),
  })

  // Binding gutter — `<w:pgMar w:gutter="720" .../>`.  Adds a 0.5"
  // gutter on the binding edge (in addition to the regular margins).
  cases.push({
    id: "section-margins-with-gutter",
    format: "docx",
    category: "section",
    content: body(
      5,
      sect_pr([
        pg_sz("12240", "15840", None),
        pg_mar("1440", "1440", "1440", "1440", Some("720")),
      ]),
    ),
  })

  // =====================================================================
  // §17.6.4 cols — multi-column layout
  // =====================================================================

  // Two equal columns separated by 720 twips (0.5") of gutter.  Need
  // enough prose to fill both columns to make the layout visible.
  cases.push({
    id: "section-cols-2-equal",
    format: "docx",
    category: "section",
    content: body(
      6,
      sect_pr([
        pg_sz("12240", "15840", None),
        pg_mar("1440", "1440", "1440", "1440", None),
        cols("2", Some("720"), false, []),
      ]),
    ),
  })

  // Three equal columns — narrower per column; words wrap more often.
  cases.push({
    id: "section-cols-3-equal",
    format: "docx",
    category: "section",
    content: body(
      8,
      sect_pr([
        pg_sz("12240", "15840", None),
        pg_mar("1440", "1440", "1440", "1440", None),
        cols("3", Some("720"), false, []),
      ]),
    ),
  })

  // Two unequal columns — `equalWidth="0"` plus per-column widths.
  // Left column 3000 twips, right column 5000 twips, 360 twip space.
  cases.push({
    id: "section-cols-2-unequal",
    format: "docx",
    category: "section",
    content: body(
      6,
      sect_pr([
        pg_sz("12240", "15840", None),
        pg_mar("1440", "1440", "1440", "1440", None),
        cols("2", None, false, [("3000", "360"), ("5000", "360")]),
      ]),
    ),
  })

  // Two equal columns with a vertical separator line between them —
  // `<w:cols w:num="2" w:sep="1"/>`.
  cases.push({
    id: "section-cols-with-separator",
    format: "docx",
    category: "section",
    content: body(
      6,
      sect_pr([
        pg_sz("12240", "15840", None),
        pg_mar("1440", "1440", "1440", "1440", None),
        cols("2", Some("720"), true, []),
      ]),
    ),
  })

  // =====================================================================
  // Combinations — pgSz + pgMar + cols stacked
  // =====================================================================

  // A4 landscape with two equal columns.  Wider page and narrower
  // margins give plenty of room for two reasonably wide columns.
  cases.push({
    id: "section-a4-landscape-2col",
    format: "docx",
    category: "section",
    content: body(
      6,
      sect_pr([
        pg_sz("16838", "11906", Some("landscape")),
        pg_mar("1440", "1440", "1440", "1440", None),
        cols("2", Some("720"), false, []),
      ]),
    ),
  })

  // Letter portrait, narrow margins, three columns — a magazine
  // article style layout that exercises pgSz + pgMar + cols
  // interacting.
  cases.push({
    id: "section-letter-narrow-3col",
    format: "docx",
    category: "section",
    content: body(
      8,
      sect_pr([
        pg_sz("12240", "15840", None),
        pg_mar("720", "720", "720", "720", None),
        cols("3", Some("360"), true, []),
      ]),
    ),
  })

  // Miscellaneous §17.6 section properties whose visual effect is
  // either host-dependent (paper source / protection) or only visible
  // in pagination and East Asian layout contexts.  The fixture keeps
  // them in EG_SectPrContents schema order and includes a lightweight
  // sectPrChange snapshot so change-tracking carriers are observed.
  cases.push({
    id: "section-advanced-properties",
    format: "docx",
    category: "section",
    content: body(
      5,
      sect_pr([
        xe(NS_W, "type", [w_attr("val", "continuous")], []),
        pg_sz("12240", "15840", None),
        pg_mar("1440", "1440", "1440", "1440", None),
        xe(NS_W, "paperSrc", [w_attr("first", "1"), w_attr("other", "2")], []),
        pg_borders(),
        xe(
          NS_W,
          "lnNumType",
          [
            w_attr("countBy", "1"),
            w_attr("start", "1"),
            w_attr("distance", "360"),
            w_attr("restart", "continuous"),
          ],
          [],
        ),
        xe(
          NS_W,
          "pgNumType",
          [w_attr("fmt", "decimal"), w_attr("start", "3")],
          [],
        ),
        cols("2", Some("720"), true, []),
        xe(NS_W, "formProt", [w_attr("val", "0")], []),
        xe(NS_W, "vAlign", [w_attr("val", "top")], []),
        xe(NS_W, "noEndnote", [w_attr("val", "1")], []),
        xe(NS_W, "titlePg", [w_attr("val", "1")], []),
        xe(NS_W, "textDirection", [w_attr("val", "lrTb")], []),
        xe(NS_W, "bidi", [w_attr("val", "0")], []),
        xe(NS_W, "rtlGutter", [w_attr("val", "0")], []),
        xe(
          NS_W,
          "docGrid",
          [
            w_attr("type", "linesAndChars"),
            w_attr("linePitch", "360"),
            w_attr("charSpace", "120"),
          ],
          [],
        ),
        xe(
          NS_W,
          "sectPrChange",
          [
            w_attr("id", "41"),
            w_attr("author", "Catalog"),
            w_attr("date", "2026-06-06T00:00:00Z"),
          ],
          [
            Element(
              sect_pr([
                pg_sz("12240", "15840", None),
                pg_mar("1440", "1440", "1440", "1440", None),
              ]),
            ),
          ],
        ),
      ]),
    ),
  })
}
