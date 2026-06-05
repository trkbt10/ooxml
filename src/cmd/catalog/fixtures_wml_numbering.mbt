// WML numbering-part fixtures — `word/numbering.xml` resolution.
//
// These fixtures exercise §17.9 (ECMA-376 Part 1) numbering: the
// `<w:numbering>` part declares `<w:abstractNum>` definitions (per-
// ilvl `<w:lvl>` with `<w:start>`, `<w:numFmt>`, `<w:lvlText>`,
// `<w:lvlJc>`, `<w:lvlRestart>`, …) and `<w:num>` instances binding
// a `numId` to an `abstractNumId` (with optional `<w:lvlOverride>`).
// Body paragraphs reference the list via
// `<w:pPr><w:numPr><w:ilvl><w:numId></w:numPr></w:pPr>`.
//
// Each fixture isolates ONE numbering behaviour so a regression in
// the resolver / formatter points at a single feature, and so
// the reference renderer's output can be compared per-feature.
//
// Conventions:
//   * `format = "docx"`, `styles = None`, `doc_styles = None`,
//     `numbering = Some(...)`.
//   * Each abstractNum carries every ilvl=0..2 it can, even when
//     unused, so a single helper covers single- and multi-level lists.
//   * `<w:lvlText>` placeholders follow §17.9.11 — `%1` is the
//     ilvl=0 counter, `%2` is ilvl=1, etc.

///|
fn extras_wml_numbering(xcases : Array[ExtendedCase]) -> Unit {
  // ---- Local element helpers ------------------------------------
  // Build a `w:`-prefixed attribute, since `xa()` produces no-NS
  // attributes which is wrong for WML structural attrs like `w:val`.
  let w_attr = fn(localn : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name: localn, ns: Some(NS_W) }, value }
  }
  // A `<w:lvl>` with `start`, `numFmt`, `lvlText`, `lvlJc`.  The
  // four properties are emitted unconditionally — these are the
  // properties the resolver decodes for every level and a missing
  // one would leave a subtle hole in the rendering.
  let lvl = fn(
    ilvl : String,
    fmt : String,
    text : String,
    start : String,
  ) -> @xml.Element {
    xe(NS_W, "lvl", [w_attr("ilvl", ilvl)], [
      Element(xe(NS_W, "start", [w_attr("val", start)], [])),
      Element(xe(NS_W, "numFmt", [w_attr("val", fmt)], [])),
      Element(xe(NS_W, "lvlText", [w_attr("val", text)], [])),
      Element(xe(NS_W, "lvlJc", [w_attr("val", "left")], [])),
    ])
  }
  // Same as `lvl` but also adds a `<w:lvlRestart>` so a fixture can
  // demonstrate the §17.9.12 "restart this counter when an earlier
  // level advances" behaviour.
  let lvl_with_restart = fn(
    ilvl : String,
    fmt : String,
    text : String,
    start : String,
    restart : String,
  ) -> @xml.Element {
    xe(NS_W, "lvl", [w_attr("ilvl", ilvl)], [
      Element(xe(NS_W, "start", [w_attr("val", start)], [])),
      Element(xe(NS_W, "numFmt", [w_attr("val", fmt)], [])),
      Element(xe(NS_W, "lvlRestart", [w_attr("val", restart)], [])),
      Element(xe(NS_W, "lvlText", [w_attr("val", text)], [])),
      Element(xe(NS_W, "lvlJc", [w_attr("val", "left")], [])),
    ])
  }
  // A schema-ordered `<w:lvl>` for less common controls. CT_Lvl
  // requires this child order: start, numFmt, lvlRestart, pStyle,
  // isLgl, suff, lvlText, lvlPicBulletId, lvlJc.
  let lvl_with_flags = fn(
    ilvl : String,
    fmt : String,
    text : String,
    start : String,
    pic_id : String,
  ) -> @xml.Element {
    xe(
      NS_W,
      "lvl",
      [
        w_attr("ilvl", ilvl),
        w_attr("tplc", "04090001"),
        w_attr("tentative", "0"),
      ],
      [
        Element(xe(NS_W, "start", [w_attr("val", start)], [])),
        Element(xe(NS_W, "numFmt", [w_attr("val", fmt)], [])),
        Element(xe(NS_W, "lvlRestart", [w_attr("val", "0")], [])),
        Element(xe(NS_W, "pStyle", [w_attr("val", "ListParagraph")], [])),
        Element(xe(NS_W, "isLgl", [w_attr("val", "1")], [])),
        Element(xe(NS_W, "suff", [w_attr("val", "space")], [])),
        Element(xe(NS_W, "lvlText", [w_attr("val", text)], [])),
        Element(xe(NS_W, "lvlPicBulletId", [w_attr("val", pic_id)], [])),
        Element(
          xe(
            NS_W,
            "legacy",
            [
              w_attr("legacy", "1"),
              w_attr("legacySpace", "360"),
              w_attr("legacyIndent", "-360"),
            ],
            [],
          ),
        ),
        Element(xe(NS_W, "lvlJc", [w_attr("val", "left")], [])),
      ],
    )
  }
  // Wrap a `<w:abstractNum>` around a list of `<w:lvl>` children.
  let abstract_num = fn(
    id : String,
    levels : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for l in levels {
      kids.push(Element(l))
    }
    xe(NS_W, "abstractNum", [w_attr("abstractNumId", id)], kids)
  }
  // CT_AbstractNum's optional header children precede all lvl
  // definitions: nsid, multiLevelType, tmpl, name, styleLink,
  // numStyleLink.
  let abstract_num_with_header = fn(
    id : String,
    header : Array[@xml.Element],
    levels : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for h in header {
      kids.push(Element(h))
    }
    for l in levels {
      kids.push(Element(l))
    }
    xe(NS_W, "abstractNum", [w_attr("abstractNumId", id)], kids)
  }
  // A `<w:num>` instance binding `numId` → `abstractNumId`.
  let num_inst = fn(num_id : String, abstract_id : String) -> @xml.Element {
    xe(NS_W, "num", [w_attr("numId", num_id)], [
      Element(xe(NS_W, "abstractNumId", [w_attr("val", abstract_id)], [])),
    ])
  }
  // A `<w:num>` instance with one or more `<w:lvlOverride>` children
  // — used by the `list-lvlOverride` fixture to demonstrate
  // §17.9.8 lvlOverride wins over the inherited abstract definition.
  let num_inst_override = fn(
    num_id : String,
    abstract_id : String,
    overrides : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(xe(NS_W, "abstractNumId", [w_attr("val", abstract_id)], [])),
    ]
    for o in overrides {
      kids.push(Element(o))
    }
    xe(NS_W, "num", [w_attr("numId", num_id)], kids)
  }
  // A `<w:numbering>` root carrying the given abstractNums + nums.
  let numbering_part = fn(
    abstract_nums : Array[@xml.Element],
    nums : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for a in abstract_nums {
      kids.push(Element(a))
    }
    for n in nums {
      kids.push(Element(n))
    }
    xe(NS_W, "numbering", [], kids)
  }
  // Full CT_Numbering root order: numPicBullet*, abstractNum*, num*,
  // then optional numIdMacAtCleanup.
  let numbering_part_full = fn(
    pic_bullets : Array[@xml.Element],
    abstract_nums : Array[@xml.Element],
    nums : Array[@xml.Element],
    cleanup : @xml.Element?,
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for p in pic_bullets {
      kids.push(Element(p))
    }
    for a in abstract_nums {
      kids.push(Element(a))
    }
    for n in nums {
      kids.push(Element(n))
    }
    match cleanup {
      Some(c) => kids.push(Element(c))
      None => ()
    }
    xe(NS_W, "numbering", [], kids)
  }
  // A body paragraph in a list: `<w:p><w:pPr><w:numPr>...</w:numPr>`
  // with the given ilvl + numId, then a single text run.
  let list_p = fn(
    num_id : String,
    ilvl : String,
    text : String,
  ) -> @xml.Element {
    w_p(
      Some(
        xe(NS_W, "pPr", [], [
          Element(
            xe(NS_W, "numPr", [], [
              Element(xe(NS_W, "ilvl", [w_attr("val", ilvl)], [])),
              Element(xe(NS_W, "numId", [w_attr("val", num_id)], [])),
            ]),
          ),
        ]),
      ),
      [w_run(None, text)],
    )
  }
  // Wrap a list of body-level paragraphs into the `<w:body>`.
  let body_of = fn(paragraphs : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for p in paragraphs {
      kids.push(Element(p))
    }
    xe(NS_W, "body", [], kids)
  }
  let ns_wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  let ns_pic = "http://schemas.openxmlformats.org/drawingml/2006/picture"
  let wp_el = fn(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xe(ns_wp, name, attrs, kids)
  }
  let pic_el = fn(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xe(ns_pic, name, attrs, kids)
  }
  let a_el = fn(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xe(NS_A, name, attrs, kids)
  }
  let pic_graphic = fn(inner : Array[@xml.Node]) -> @xml.Element {
    a_el("graphic", [], [
      Element(
        a_el(
          "graphicData",
          [
            xa(
              "uri", "http://schemas.openxmlformats.org/drawingml/2006/picture",
            ),
          ],
          [Element(pic_el("pic", [], inner))],
        ),
      ),
    ])
  }
  let pic_nv = fn(id_ : String, name : String) -> @xml.Element {
    pic_el("nvPicPr", [], [
      Element(pic_el("cNvPr", [xa("id", id_), xa("name", name)], [])),
      Element(pic_el("cNvPicPr", [], [])),
    ])
  }
  let pic_blipfill_empty = pic_el("blipFill", [], [
    Element(a_el("blip", [], [])),
    Element(a_el("stretch", [], [Element(a_el("fillRect", [], []))])),
  ])
  let pic_sppr = fn(cx : String, cy : String) -> @xml.Element {
    pic_el("spPr", [], [
      Element(
        a_el("xfrm", [], [
          Element(a_el("off", [xa("x", "0"), xa("y", "0")], [])),
          Element(a_el("ext", [xa("cx", cx), xa("cy", cy)], [])),
        ]),
      ),
      Element(
        a_el("prstGeom", [xa("prst", "rect")], [Element(a_el("avLst", [], []))]),
      ),
    ])
  }
  let num_pic_bullet = fn(id_ : String) -> @xml.Element {
    let cx = "457200"
    let cy = "457200"
    xe(NS_W, "numPicBullet", [w_attr("numPicBulletId", id_)], [
      Element(
        xe(NS_W, "drawing", [], [
          Element(
            wp_el(
              "inline",
              [
                xa("distT", "0"),
                xa("distB", "0"),
                xa("distL", "0"),
                xa("distR", "0"),
              ],
              [
                Element(wp_el("extent", [xa("cx", cx), xa("cy", cy)], [])),
                Element(
                  wp_el("docPr", [xa("id", "9"), xa("name", "PicBullet")], []),
                ),
                Element(
                  pic_graphic([
                    Element(pic_nv("10", "PicBullet")),
                    Element(pic_blipfill_empty),
                    Element(pic_sppr(cx, cy)),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    ])
  }

  // ---- Shared per-numFmt helper ---------------------------------
  // Build a single-level list whose only level uses the given
  // numFmt + lvlText, then three list paragraphs that exercise it.
  // The abstractNumId / numId are always 0 / 1 to keep the resolver
  // wiring trivial.
  let simple_numFmt_fixture = fn(
    id : String,
    fmt : String,
    text : String,
  ) -> ExtendedCase {
    {
      id,
      format: "docx",
      category: "list",
      content: body_of([
        list_p("1", "0", "First item"),
        list_p("1", "0", "Second item"),
        list_p("1", "0", "Third item"),
      ]),
      styles: None,
      numbering: Some(
        numbering_part([abstract_num("0", [lvl("0", fmt, text, "1")])], [
          num_inst("1", "0"),
        ]),
      ),
      doc_styles: None,
    }
  }

  // ---- §17.18.59 ST_NumberFormat — one fixture per format ------
  // decimal: 1. 2. 3. — already covered by `paragraph-numbered-list`
  // but kept here with a list category for symmetry with the others.
  xcases.push(simple_numFmt_fixture("list-numfmt-decimal", "decimal", "%1."))
  // upperRoman: I. II. III.
  xcases.push(
    simple_numFmt_fixture("list-numfmt-upper-roman", "upperRoman", "%1."),
  )
  // lowerRoman: i. ii. iii.
  xcases.push(
    simple_numFmt_fixture("list-numfmt-lower-roman", "lowerRoman", "%1."),
  )
  // upperLetter: A. B. C.
  xcases.push(
    simple_numFmt_fixture("list-numfmt-upper-letter", "upperLetter", "%1."),
  )
  // lowerLetter: a) b) c) — uses ')' to vary the punctuation across
  // fixtures and make the lvlText template visible in regressions.
  xcases.push(
    simple_numFmt_fixture("list-numfmt-lower-letter", "lowerLetter", "%1)"),
  )
  // bullet: `•` glyph at every counter — the counter is unused
  // (`NumFmtBullet.format` returns "") so `%1` is irrelevant; the
  // literal bullet character in `lvlText` is what renders.
  xcases.push(simple_numFmt_fixture("list-numfmt-bullet", "bullet", "\u{2022}"))
  // ordinal: 1st 2nd 3rd
  xcases.push(simple_numFmt_fixture("list-numfmt-ordinal", "ordinal", "%1."))
  // cardinalText: One Two Three
  xcases.push(
    simple_numFmt_fixture("list-numfmt-cardinal-text", "cardinalText", "%1."),
  )
  // none: no counter at all — the lvlText literal still emits ('Item').
  // §17.18.59 `NumFmtNone.format` returns "", so `%1` collapses to
  // empty and we test the "no number, just the literal lvlText" path.
  xcases.push(simple_numFmt_fixture("list-numfmt-none", "none", "Item"))

  // ---- Multi-level: Roman → Letter → Decimal cascade -----------
  // Classic outline structure: I. then A. inside, then 1. inside.
  // Three paragraphs at ilvl 0, 1, 2 exercise the resolver's
  // ilvl→lvl lookup and the per-level format selection.
  xcases.push({
    id: "list-multilevel-roman-letter-decimal",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("1", "0", "Top level (Roman)"),
      list_p("1", "1", "Second level (Upper letter)"),
      list_p("1", "2", "Third level (Decimal)"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part(
        [
          abstract_num("0", [
            lvl("0", "upperRoman", "%1.", "1"),
            lvl("1", "upperLetter", "%2.", "1"),
            lvl("2", "decimal", "%3.", "1"),
          ]),
        ],
        [num_inst("1", "0")],
      ),
    ),
    doc_styles: None,
  })

  // ---- Multi-level mixed: decimal / lowerLetter / lowerRoman ----
  // The "academic outline" variant — 1 / a / i.  Tests the same
  // three-level resolver path with a different format mix so a bug
  // that only triggers for a specific numFmt at a specific ilvl
  // surfaces here and not in the cascade above.
  xcases.push({
    id: "list-multilevel-decimal-letter-roman",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("1", "0", "Top level (Decimal)"),
      list_p("1", "1", "Second level (lower letter)"),
      list_p("1", "2", "Third level (lower roman)"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part(
        [
          abstract_num("0", [
            lvl("0", "decimal", "%1.", "1"),
            lvl("1", "lowerLetter", "%2.", "1"),
            lvl("2", "lowerRoman", "%3.", "1"),
          ]),
        ],
        [num_inst("1", "0")],
      ),
    ),
    doc_styles: None,
  })

  // ---- Custom lvlText: "Chapter %1." ----------------------------
  // §17.9.11 — the `lvlText` template is not restricted to a single
  // counter + punctuation: arbitrary literal text may surround the
  // `%N` placeholders.  This fixture exercises the literal-prefix
  // case used by chapter / section headings.
  xcases.push({
    id: "list-lvltext-chapter-prefix",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("1", "0", "Introduction"),
      list_p("1", "0", "Motivation"),
      list_p("1", "0", "Related work"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part(
        [abstract_num("0", [lvl("0", "decimal", "Chapter %1.", "1")])],
        [num_inst("1", "0")],
      ),
    ),
    doc_styles: None,
  })

  // ---- Custom lvlText: "%1.%2" continuing reference -------------
  // §17.9.11 — a level may reference earlier counters to build
  // "1.1", "1.2", "2.1" style numbering.  This is the canonical
  // multi-level legal / technical outline format.
  xcases.push({
    id: "list-lvltext-continuing-reference",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("1", "0", "First section"),
      list_p("1", "1", "First subsection of first"),
      list_p("1", "1", "Second subsection of first"),
      list_p("1", "0", "Second section"),
      list_p("1", "1", "First subsection of second"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part(
        [
          abstract_num("0", [
            lvl("0", "decimal", "%1.", "1"),
            // `%1.%2` — "1.1", "1.2", "2.1"
            lvl("1", "decimal", "%1.%2", "1"),
          ]),
        ],
        [num_inst("1", "0")],
      ),
    ),
    doc_styles: None,
  })

  // ---- start val="5" — list starts at 5 -------------------------
  // §17.9.22 — the `<w:start>` element seeds the counter for that
  // ilvl.  Three items therefore render as "5.", "6.", "7."
  // instead of "1.", "2.", "3.".  Distinguishes a renderer that
  // hard-codes the seed to 1 from one that reads `<w:start>`.
  xcases.push({
    id: "list-start-from-5",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("1", "0", "Starts at five"),
      list_p("1", "0", "Then six"),
      list_p("1", "0", "Then seven"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part([abstract_num("0", [lvl("0", "decimal", "%1.", "5")])], [
        num_inst("1", "0"),
      ]),
    ),
    doc_styles: None,
  })

  // ---- lvlRestart val="0" — never restart -----------------------
  // §17.9.12 — `<w:lvlRestart val="0"/>` instructs the counter to
  // never restart when an earlier-level counter advances.  The
  // ilvl=1 counter therefore keeps going (1, 2, 3, 4) across the
  // two top-level sections instead of resetting to 1 inside the
  // second section.
  xcases.push({
    id: "list-lvlrestart-zero",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("1", "0", "Section one"),
      list_p("1", "1", "Subsection (1)"),
      list_p("1", "1", "Subsection (2)"),
      list_p("1", "0", "Section two"),
      list_p("1", "1", "Subsection (3)"),
      list_p("1", "1", "Subsection (4)"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part(
        [
          abstract_num("0", [
            lvl("0", "decimal", "%1.", "1"),
            // lvlRestart=0 — never restart.
            lvl_with_restart("1", "decimal", "(%2)", "1", "0"),
          ]),
        ],
        [num_inst("1", "0")],
      ),
    ),
    doc_styles: None,
  })

  // ---- lvlOverride: numId=2 inherits then overrides ilvl=0 ------
  // §17.9.8 — a `<w:num>` may carry `<w:lvlOverride>` children to
  // replace the inherited abstract definition's lvl for that ilvl.
  // Here abstractNum 0 declares ilvl=0 as `upperRoman`; numId=2
  // inherits abstractNum 0 but overrides ilvl=0 to be `decimal`
  // starting at 100.  Renders "100.", "101.", "102.".
  xcases.push({
    id: "list-lvloverride-replaces-level",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("2", "0", "Override item one"),
      list_p("2", "0", "Override item two"),
      list_p("2", "0", "Override item three"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part(
        [abstract_num("0", [lvl("0", "upperRoman", "%1.", "1")])],
        [
          num_inst_override("2", "0", [
            xe(NS_W, "lvlOverride", [w_attr("ilvl", "0")], [
              Element(lvl("0", "decimal", "%1.", "100")),
            ]),
          ]),
        ],
      ),
    ),
    doc_styles: None,
  })

  // ---- Numbering metadata, flags, picture bullet placeholder ----
  // Covers CT_Numbering's uncommon root slots (`numPicBullet`,
  // `numIdMacAtCleanup`), CT_AbstractNum metadata (`nsid`,
  // `multiLevelType`, `tmpl`, `styleLink`, `numStyleLink`), CT_Lvl
  // flags (`isLgl`, `suff`, `lvlPicBulletId`), and the
  // `<w:startOverride>` branch of `<w:lvlOverride>`. The picture
  // bullet uses an empty blip, so no numbering.xml.rels relationship
  // is required; renderers should fall back to the text marker.
  xcases.push({
    id: "list-numbering-metadata-flags-picture-placeholder",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("3", "0", "Metadata-backed item one"),
      list_p("3", "0", "Metadata-backed item two"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part_full(
        [num_pic_bullet("5")],
        [
          abstract_num_with_header(
            "0",
            [
              xe(NS_W, "nsid", [w_attr("val", "12345678")], []),
              xe(NS_W, "multiLevelType", [w_attr("val", "hybridMultilevel")], []),
              xe(NS_W, "tmpl", [w_attr("val", "87654321")], []),
              xe(NS_W, "name", [w_attr("val", "MetadataNumbering")], []),
              xe(NS_W, "styleLink", [w_attr("val", "ListNumber")], []),
              xe(NS_W, "numStyleLink", [w_attr("val", "ListNumberLinked")], []),
            ],
            [lvl_with_flags("0", "decimal", "%1.", "1", "5")],
          ),
        ],
        [
          num_inst_override("3", "0", [
            xe(NS_W, "lvlOverride", [w_attr("ilvl", "0")], [
              Element(xe(NS_W, "startOverride", [w_attr("val", "42")], [])),
            ]),
          ]),
        ],
        Some(xe(NS_W, "numIdMacAtCleanup", [w_attr("val", "3")], [])),
      ),
    ),
    doc_styles: None,
  })

  // ---- Custom bullet character per level ------------------------
  // §17.9.11 — the `lvlText` template is a literal string for
  // `bullet` numFmt.  This fixture uses three distinct bullet
  // glyphs to demonstrate per-level bullet customisation:
  //   ilvl=0 → U+25CF BLACK CIRCLE (`●`)
  //   ilvl=1 → U+25CB WHITE CIRCLE (`○`)
  //   ilvl=2 → U+25AA BLACK SMALL SQUARE (`▪`)
  // These mirror the Word default bullet ladder used when a list
  // is created without a custom format.
  xcases.push({
    id: "list-custom-bullets-per-level",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("1", "0", "Top bullet (black circle)"),
      list_p("1", "1", "Second-level bullet (white circle)"),
      list_p("1", "2", "Third-level bullet (small square)"),
      list_p("1", "0", "Back to top"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part(
        [
          abstract_num("0", [
            lvl("0", "bullet", "\u{25CF}", "1"),
            lvl("1", "bullet", "\u{25CB}", "1"),
            lvl("2", "bullet", "\u{25AA}", "1"),
          ]),
        ],
        [num_inst("1", "0")],
      ),
    ),
    doc_styles: None,
  })

  // ---- Multi-level pure bullets (default ladder) ----------------
  // §17.9.25 — the canonical Office bullet ladder uses `•`, `○`,
  // and `▪` for ilvl=0, 1, 2.  This fixture demonstrates the
  // resolver picking the right glyph for each ilvl in the same
  // list, which is the most common bulleted-outline case.
  xcases.push({
    id: "list-multilevel-bullet-ladder",
    format: "docx",
    category: "list",
    content: body_of([
      list_p("1", "0", "First-level point"),
      list_p("1", "1", "Second-level point"),
      list_p("1", "2", "Third-level point"),
      list_p("1", "1", "Back to second"),
      list_p("1", "0", "Back to first"),
    ]),
    styles: None,
    numbering: Some(
      numbering_part(
        [
          abstract_num("0", [
            lvl("0", "bullet", "\u{2022}", "1"),
            lvl("1", "bullet", "\u{25E6}", "1"),
            lvl("2", "bullet", "\u{25AA}", "1"),
          ]),
        ],
        [num_inst("1", "0")],
      ),
    ),
    doc_styles: None,
  })
}
