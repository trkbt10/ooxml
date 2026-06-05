// WML field, hyperlink, and bookmark visual-fixtures —
// exercise ECMA-376 §17.16 (fields) and §17.13 (annotations).
//
// Add new fixtures by inserting `cases.push({...})` into
// `extras_wml_fields`.  See the editing convention in
// `fixtures_wml_run.mbt`; helpers `w_p`, `w_run`, `w_rpr`, `w_val`,
// `w_flag`, `w_t`, `xe`, `xa`, and the constant `NS_W` come from
// the catalog's shared helper modules.
//
// Fixtures here split across three categories:
//   - "field"     — simple (`<w:fldSimple>`) and complex
//                   (`<w:fldChar>` + `<w:instrText>`) field codes.
//   - "hyperlink" — `<w:hyperlink>` with anchor / tooltip.
//   - "bookmark"  — `<w:bookmarkStart>` / `<w:bookmarkEnd>` markers.
//
// Several layout-affecting run characters (`<w:br w:type=…>` and
// `<w:tab/>`) are grouped under "field" because they share §17.16
// neighbourhood and the regression surface (run-break behaviour).

///|
fn extras_wml_fields(cases : Array[VisualCase]) -> Unit {
  // Multi-attribute element helpers — local so they can read the
  // `NS_W` constant via lexical scope without redeclaration.
  let w_attr = fn(localn : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name: localn, ns: Some(NS_W) }, value }
  }

  // `<w:instrText xml:space="preserve">…</w:instrText>` — the field
  // instruction body.  `xml:space="preserve"` is mandatory: leading /
  // trailing whitespace inside instruction strings (`PAGEREF bm \\h`,
  // `MERGEFIELD FirstName`) carries semantic weight, so the renderer
  // must not collapse it.
  let w_instr_text = fn(text : String) -> @xml.Element {
    xe(
      NS_W,
      "instrText",
      [
        {
          name: {
            prefix: Some("xml"),
            local_name: "space",
            ns: Some("http://www.w3.org/XML/1998/namespace"),
          },
          value: "preserve",
        },
      ],
      [Text(text)],
    )
  }

  // `<w:r><w:instrText>…</w:instrText></w:r>` — wraps an instruction
  // string in its own run (no `<w:t>`!) so the field parser knows the
  // text is instruction, not display content.
  let instr_run = fn(text : String) -> @xml.Element {
    xe(NS_W, "r", [], [Element(w_instr_text(text))])
  }

  // `<w:r><w:fldChar w:fldCharType="…"/></w:r>` — marker run carrying
  // a begin / separate / end field character (§17.16.18).  Each
  // marker MUST live in its own run.
  let fldchar_run = fn(kind : String) -> @xml.Element {
    xe(NS_W, "r", [], [
      Element(xe(NS_W, "fldChar", [w_attr("fldCharType", kind)], [])),
    ])
  }

  let ffdata = fn(children : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in children {
      kids.push(Element(c))
    }
    xe(NS_W, "ffData", [], kids)
  }

  let fldchar_form_run = fn(children : Array[@xml.Element]) -> @xml.Element {
    xe(NS_W, "r", [], [
      Element(
        xe(NS_W, "fldChar", [w_attr("fldCharType", "begin")], [
          Element(ffdata(children)),
        ]),
      ),
    ])
  }

  // `<w:fldSimple w:instr="…">(runs)</w:fldSimple>` — simple field
  // wrapper that carries the instruction in the `w:instr` attribute
  // and the cached display result as child runs.
  let fldsimple = fn(
    instr : String,
    runs : Array[@xml.Element],
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for r in runs {
      kids.push(Element(r))
    }
    xe(NS_W, "fldSimple", [w_attr("instr", instr)], kids)
  }

  // `<w:bookmarkStart w:id=… w:name=…/>` /
  // `<w:bookmarkEnd w:id=…/>` — §17.13.6.{2,1}.  Bookmarks span the
  // siblings between start and end; `id` must match across the pair.
  let bookmark_start = fn(id_ : String, name : String) -> @xml.Element {
    xe(NS_W, "bookmarkStart", [w_attr("id", id_), w_attr("name", name)], [])
  }
  let bookmark_end = fn(id_ : String) -> @xml.Element {
    xe(NS_W, "bookmarkEnd", [w_attr("id", id_)], [])
  }

  // `<w:hyperlink …>(runs)</w:hyperlink>` — §17.16.22.  Attributes are
  // open-ended (`w:anchor`, `w:tooltip`, `r:id`, `w:history`); pass
  // any subset as `(local, value)` pairs.
  let hyperlink = fn(
    pairs : Array[(String, String)],
    runs : Array[@xml.Element],
  ) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = []
    for p in pairs {
      attrs.push(w_attr(p.0, p.1))
    }
    let kids : Array[@xml.Node] = []
    for r in runs {
      kids.push(Element(r))
    }
    xe(NS_W, "hyperlink", attrs, kids)
  }

  // Hyperlink-styled run — `<w:rPr><w:rStyle w:val="Hyperlink"/></w:rPr>`
  // is the conventional rendering of an active hyperlink in WML.
  // Even without a real `styles.xml` defining `Hyperlink`, the run
  // structure exercises the rStyle reference path.
  let hyperlink_run = fn(text : String) -> @xml.Element {
    w_run(Some(w_rpr([w_val("rStyle", "Hyperlink")])), text)
  }

  // `<w:r><w:br w:type=…/></w:r>` — explicit page / column / textWrap
  // break inserted in run content (§17.3.3.1).
  let br_run = fn(kind : String) -> @xml.Element {
    xe(NS_W, "r", [], [Element(xe(NS_W, "br", [w_attr("type", kind)], []))])
  }

  // `<w:r><w:tab/></w:r>` — embedded tab character (§17.3.3.32).
  let tab_run = xe(NS_W, "r", [], [Element(xe(NS_W, "tab", [], []))])

  let w_rel_attr = fn(localn : String, value : String) -> @xml.Attribute {
    {
      name: { prefix: Some("r"), local_name: localn, ns: Some(NS_OFFICE_REL) },
      value,
    }
  }

  let field_relationship_fldsimple = xe(
    NS_W,
    "fldSimple",
    [w_attr("instr", "MERGEFIELD CatalogName")],
    [
      Element(xe(NS_W, "fldData", [], [Text("catalog-field-data")])),
      Element(w_run(None, "CatalogName")),
    ],
  )

  let content_part_run = xe(NS_W, "r", [], [
    Element(xe(NS_W, "contentPart", [w_rel_attr("id", "rIdContentPart")], [])),
  ])

  let object_embed = xe(
    NS_W,
    "object",
    [w_attr("dxaOrig", "1440"), w_attr("dyaOrig", "720")],
    [
      Element(
        xe(
          NS_W,
          "objectEmbed",
          [
            w_rel_attr("id", "rIdOleEmbed"),
            w_attr("drawAspect", "content"),
            w_attr("progId", "Package"),
          ],
          [],
        ),
      ),
    ],
  )

  let object_link = xe(NS_W, "object", [], [
    Element(
      xe(
        NS_W,
        "objectLink",
        [
          w_rel_attr("id", "rIdOleLink"),
          w_attr("drawAspect", "icon"),
          w_attr("progId", "Package"),
          w_attr("updateMode", "onCall"),
        ],
        [],
      ),
    ),
  ])

  let picture_carrier = xe(NS_W, "pict", [], [
    Element(xe(NS_W, "movie", [w_rel_attr("id", "rIdMovie")], [])),
    Element(
      xe(
        NS_W,
        "control",
        [w_attr("name", "CatalogControl"), w_attr("shapeid", "_x0000_s1")],
        [],
      ),
    ),
  ])

  let numbering_change_run = xe(NS_W, "r", [], [
    Element(
      xe(NS_W, "fldChar", [w_attr("fldCharType", "begin")], [
        Element(
          xe(
            NS_W,
            "numberingChange",
            [
              w_attr("id", "401"),
              w_attr("author", "Catalog"),
              w_attr("date", "2026-06-06T00:00:00Z"),
              w_attr("original", "1."),
            ],
            [],
          ),
        ),
      ]),
    ),
  ])

  let smart_tag = xe(
    NS_W,
    "smartTag",
    [w_attr("element", "catalogTag"), w_attr("uri", "urn:catalog")],
    [
      Element(
        xe(NS_W, "smartTagPr", [], [
          Element(
            xe(
              NS_W,
              "attr",
              [w_attr("name", "kind"), w_attr("val", "relationship")],
              [],
            ),
          ),
        ]),
      ),
      Element(w_run(None, "smart tag")),
    ],
  )

  cases.push({
    id: "field-relationship-carriers",
    format: "docx:relationshipRich",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_flag("oMath")])), "Math-styled run. "),
          smart_tag,
          xe(NS_W, "subDoc", [w_rel_attr("id", "rIdSubDoc")], []),
        ]),
      ),
      Element(w_p(None, [field_relationship_fldsimple])),
      Element(
        w_p(None, [
          content_part_run,
          numbering_change_run,
          xe(NS_W, "r", [], [Element(object_embed)]),
          xe(NS_W, "r", [], [Element(object_link)]),
          xe(NS_W, "r", [], [Element(picture_carrier)]),
        ]),
      ),
      Element(
        xe(NS_W, "altChunk", [w_rel_attr("id", "rIdAltChunk")], [
          Element(
            xe(NS_W, "altChunkPr", [], [
              Element(xe(NS_W, "matchSrc", [w_attr("val", "1")], [])),
            ]),
          ),
        ]),
      ),
      Element(
        xe(NS_W, "sectPr", [], [
          Element(
            xe(
              NS_W,
              "printerSettings",
              [w_rel_attr("id", "rIdPrinterSettings")],
              [],
            ),
          ),
        ]),
      ),
    ]),
  })

  // ---- §17.16 simple fields (`<w:fldSimple>`) ------------------

  // PAGE — current page number, cached as "1".
  cases.push({
    id: "field-page-number",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Page "),
          fldsimple("PAGE", [w_run(None, "1")]),
          w_run(None, " of the document."),
        ]),
      ),
    ]),
  })

  // NUMPAGES — total page count, cached as "1".
  cases.push({
    id: "field-numpages",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "This document contains "),
          fldsimple("NUMPAGES", [w_run(None, "1")]),
          w_run(None, " page(s)."),
        ]),
      ),
    ]),
  })

  // DATE — formatted current date.  Backslash-escaped switch follows
  // the field-code switch grammar (`\@ "format"`).
  cases.push({
    id: "field-date",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Today is "),
          fldsimple("DATE \\@ \"yyyy-MM-dd\"", [w_run(None, "2026-05-23")]),
          w_run(None, "."),
        ]),
      ),
    ]),
  })

  // TIME — current time of day.
  cases.push({
    id: "field-time",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Current time: "),
          fldsimple("TIME \\@ \"HH:mm\"", [w_run(None, "09:42")]),
          w_run(None, "."),
        ]),
      ),
    ]),
  })

  // AUTHOR — author metadata pulled from core.xml.
  cases.push({
    id: "field-author",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Document author: "),
          fldsimple("AUTHOR", [w_run(None, "Catalog Author")]),
          w_run(None, "."),
        ]),
      ),
    ]),
  })

  // Legacy form fields — `<w:fldChar><w:ffData>...`.
  cases.push({
    id: "field-legacy-form-controls",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Checkbox: "),
          fldchar_form_run([
            w_val("name", "AcceptTerms"),
            w_val("label", "1"),
            w_val("tabIndex", "1"),
            w_val("enabled", "1"),
            w_val("calcOnExit", "0"),
            w_val("entryMacro", "OnEnterAcceptTerms"),
            w_val("exitMacro", "OnExitAcceptTerms"),
            xe(
              NS_W,
              "helpText",
              [w_attr("type", "text"), w_attr("val", "Check to accept")],
              [],
            ),
            xe(
              NS_W,
              "statusText",
              [w_attr("type", "text"), w_attr("val", "Required checkbox")],
              [],
            ),
            xe(NS_W, "checkBox", [], [
              Element(w_flag("sizeAuto")),
              Element(w_val("default", "0")),
              Element(w_val("checked", "1")),
            ]),
          ]),
          fldchar_run("separate"),
          w_run(None, "checked"),
          fldchar_run("end"),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(None, "Drop-down: "),
          fldchar_form_run([
            w_val("name", "Choice"),
            w_val("label", "2"),
            w_val("tabIndex", "2"),
            w_val("enabled", "1"),
            w_val("calcOnExit", "1"),
            xe(NS_W, "ddList", [], [
              Element(w_val("result", "1")),
              Element(w_val("default", "0")),
              Element(w_val("listEntry", "One")),
              Element(w_val("listEntry", "Two")),
            ]),
          ]),
          fldchar_run("separate"),
          w_run(None, "Two"),
          fldchar_run("end"),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(None, "Text input: "),
          fldchar_form_run([
            w_val("name", "ShortText"),
            w_val("label", "3"),
            w_val("tabIndex", "3"),
            w_val("enabled", "1"),
            w_val("calcOnExit", "0"),
            xe(NS_W, "textInput", [], [
              Element(w_val("type", "regular")),
              Element(w_val("default", "Catalog")),
              Element(w_val("maxLength", "32")),
              Element(w_val("format", "Title Case")),
            ]),
          ]),
          fldchar_run("separate"),
          w_run(None, "Catalog"),
          fldchar_run("end"),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(None, "Fixed-size checkbox: "),
          fldchar_form_run([
            w_val("name", "FixedSizeChoice"),
            w_val("label", "4"),
            w_val("tabIndex", "4"),
            w_val("enabled", "1"),
            w_val("calcOnExit", "0"),
            xe(NS_W, "checkBox", [], [
              Element(w_val("size", "20")),
              Element(w_val("default", "1")),
              Element(w_val("checked", "0")),
            ]),
          ]),
          fldchar_run("separate"),
          w_run(None, "unchecked"),
          fldchar_run("end"),
        ]),
      ),
    ]),
  })

  // TITLE — title metadata.
  cases.push({
    id: "field-title",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Title: "),
          fldsimple("TITLE", [w_run(None, "Visual Fixtures Catalog")]),
        ]),
      ),
    ]),
  })

  // PAGEREF — page number of the referenced bookmark.  The bookmark
  // is declared in a separate paragraph so the reference points at a
  // real anchor inside the same document body.
  cases.push({
    id: "field-pageref",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          bookmark_start("100", "target_para"),
          w_run(None, "This is the target paragraph for the PAGEREF."),
          bookmark_end("100"),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(None, "See target on page "),
          fldsimple("PAGEREF target_para \\h", [w_run(None, "1")]),
          w_run(None, "."),
        ]),
      ),
    ]),
  })

  // REF — reference to another bookmark's text content.
  cases.push({
    id: "field-ref",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          bookmark_start("101", "ref_target"),
          w_run(None, "Referenced text"),
          bookmark_end("101"),
          w_run(None, " is the original."),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(None, "Repeated here: "),
          fldsimple("REF ref_target", [w_run(None, "Referenced text")]),
          w_run(None, "."),
        ]),
      ),
    ]),
  })

  // MERGEFIELD — mail-merge placeholder, cached display value
  // typically renders with chevron wrappers («FirstName»).
  cases.push({
    id: "field-mergefield",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Dear "),
          fldsimple("MERGEFIELD FirstName", [w_run(None, "«FirstName»")]),
          w_run(None, ","),
        ]),
      ),
    ]),
  })

  // ---- §17.16 complex fields (`<w:fldChar>` markers) -----------

  // PAGE — same field as `field-page-number`, but expressed with
  // begin/separate/end markers.  Tests the complex-field parsing
  // path; visual output should match the simple variant.
  cases.push({
    id: "field-complex-page",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Page "),
          fldchar_run("begin"),
          instr_run("PAGE"),
          fldchar_run("separate"),
          w_run(None, "1"),
          fldchar_run("end"),
          w_run(None, " of the document."),
        ]),
      ),
    ]),
  })

  // HYPERLINK — complex-field form, the cached display run carries
  // the Hyperlink rStyle so the link surface is visibly styled.
  cases.push({
    id: "field-complex-hyperlink",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Visit "),
          fldchar_run("begin"),
          instr_run("HYPERLINK \"https://example.com\""),
          fldchar_run("separate"),
          hyperlink_run("https://example.com"),
          fldchar_run("end"),
          w_run(None, " for details."),
        ]),
      ),
    ]),
  })

  // ---- §17.16.22 hyperlinks ------------------------------------

  // `<w:hyperlink w:anchor="bm">` — internal anchor jump.  Target
  // bookmark `internal_bm` is declared in a later paragraph.
  cases.push({
    id: "hyperlink-anchor",
    format: "docx",
    category: "hyperlink",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Click "),
          hyperlink([("anchor", "internal_bm")], [hyperlink_run("here to jump")]),
          w_run(None, " to scroll to the marker below."),
        ]),
      ),
      Element(
        w_p(None, [
          bookmark_start("102", "internal_bm"),
          w_run(None, "Anchor destination paragraph."),
          bookmark_end("102"),
        ]),
      ),
    ]),
  })

  // `<w:hyperlink w:tooltip="…">` — hover tooltip plus anchor.
  cases.push({
    id: "hyperlink-tooltip",
    format: "docx",
    category: "hyperlink",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Hover over "),
          hyperlink(
            [("anchor", "tip_bm"), ("tooltip", "Jump to the tip target")],
            [hyperlink_run("this link")],
          ),
          w_run(None, " to see the tooltip."),
        ]),
      ),
      Element(
        w_p(None, [
          bookmark_start("103", "tip_bm"),
          w_run(None, "Tooltip-link destination."),
          bookmark_end("103"),
        ]),
      ),
    ]),
  })

  // ---- §17.13.6 bookmarks --------------------------------------

  // `<w:bookmarkStart>` / `<w:bookmarkEnd>` wrapping a single run.
  // Bookmarks are invisible in normal rendering, so the test asserts
  // that introducing them does not perturb the surrounding text.
  cases.push({
    id: "bookmark-text",
    format: "docx",
    category: "bookmark",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Before. "),
          bookmark_start("200", "single_bm"),
          w_run(None, "Bookmarked text"),
          bookmark_end("200"),
          w_run(None, " After."),
        ]),
      ),
    ]),
  })

  // Bookmark spanning two paragraphs — start in the first paragraph,
  // end in the second.  Validates that bookmarks may cross paragraph
  // boundaries (§17.13.6.2 makes no boundary restriction).
  cases.push({
    id: "bookmark-multi-para",
    format: "docx",
    category: "bookmark",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          bookmark_start("201", "multi_bm"),
          w_run(None, "First paragraph inside the bookmark."),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(None, "Second paragraph inside the bookmark."),
          bookmark_end("201"),
        ]),
      ),
      Element(w_p(None, [w_run(None, "Third paragraph outside the bookmark.")])),
    ]),
  })

  // ---- §17.3.3.1 / §17.3.3.32 explicit break and tab characters

  // `<w:br w:type="page"/>` inside a run — forces a page break mid-run.
  cases.push({
    id: "line-break-page",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Before the page break."),
          br_run("page"),
          w_run(None, "After the page break (new page)."),
        ]),
      ),
    ]),
  })

  // `<w:br w:type="column"/>` — column break (visible when the
  // surrounding section declares multiple columns; with the default
  // one-column section this is functionally equivalent to a page
  // break, so the fixture verifies that the marker parses cleanly).
  cases.push({
    id: "line-break-column",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Before the column break."),
          br_run("column"),
          w_run(None, "After the column break."),
        ]),
      ),
    ]),
  })

  // `<w:tab/>` between two text runs — embedded tab character (not a
  // tab stop definition).  With no explicit `<w:tabs>` the default
  // every-half-inch grid kicks in.
  cases.push({
    id: "tab-explicit",
    format: "docx",
    category: "field",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [w_run(None, "Column A"), tab_run, w_run(None, "Column B")]),
      ),
    ]),
  })
}
