// WordprocessingML "extras" visual fixtures — exercise §17 areas
// that the existing per-category extenders (`fixtures_wml_run.mbt`,
// `fixtures_wml_paragraph.mbt`, `fixtures_wml_sections.mbt`,
// `fixtures_wml_table.mbt`, `fixtures_wml_fields.mbt`,
// `fixtures_wml_drawings.mbt`, `fixtures_wml_numbering.mbt`)
// deliberately leave alone.  The features covered here are
// container / annotation elements whose visual contribution is
// surfaced ONLY when they are nested inside a paragraph with real
// text payload, and which therefore need their own per-element
// fixtures so a regression is attributable to the wrapping
// element and not to the inner runs.
//
// ECMA-376 Part 1 cross-references:
//   §17.3.1.10 framePr         — text-frame container around a paragraph
//                                 (`<w:pPr><w:framePr>`).
//   §17.5.1.13 smartTag        — Office SmartTag wrapper around runs.
//   §17.5.2.31 sdt /
//   §17.5.2.30 sdtContent      — Structured Document Tag (content control)
//                                 wrapper around runs.
//   §17.5.5    customXml       — generic CustomXML round-trip wrapper
//                                 around runs.
//   §17.13.5.3 commentRangeStart /
//   §17.13.5.4 commentRangeEnd /
//   §17.13.5.5 commentReference — comment-anchored range markers around
//                                 runs.
//   §17.16     instrText       — multi-fragment field instruction (the
//                                 PAGEREF / TOC / SEQ family) split across
//                                 several `<w:instrText>` runs inside the
//                                 begin / separate / end frame from
//                                 §17.16.18.
//   §17.16.22  hyperlink       — anchor-only and external-URL hyperlinks
//                                 nested inside a paragraph between
//                                 surrounding prose.
//
// Fixtures here are placed under fresh categories so they appear as
// their own folder under `.snapshots/fixtures/docx/<cat>/` and a
// per-feature RMSE regression is visible at the report level.
//
// Editing convention: helpers are local `let` closures so this file is
// independent of every other `fixtures_wml_*.mbt` and can be edited in
// parallel.  Element trees are built via the `xe` / `xa` helpers from
// the catalog's shared module — NEVER hand-write XML strings.

///|
fn extras_wml_extras(cases : Array[VisualCase]) -> Unit {
  // ---- Local helpers -------------------------------------------
  // A `w:`-prefixed attribute. Most WML elements declare their
  // attribute namespace via the `w:` prefix, so we cannot use the
  // unprefixed `xa()` for the body / framing elements below.
  let w_attr = fn(localn : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name: localn, ns: Some(NS_W) }, value }
  }

  // `<w:instrText xml:space="preserve">…</w:instrText>` — field
  // instruction body.  `xml:space="preserve"` is mandatory: the
  // instruction string carries semantic whitespace (e.g. switches
  // like ` \\h ` inside `PAGEREF`).
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

  // `<w:r><w:instrText>…</w:instrText></w:r>` — wraps an
  // instruction fragment in its own run so the field parser treats
  // the text as instruction (not as displayed content).
  let instr_run = fn(text : String) -> @xml.Element {
    xe(NS_W, "r", [], [Element(w_instr_text(text))])
  }

  // `<w:r><w:fldChar w:fldCharType="…"/></w:r>` — §17.16.18 begin /
  // separate / end marker run.  Each marker must live in its own
  // run, between which the instruction / display content sits.
  let fldchar_run = fn(kind : String) -> @xml.Element {
    xe(NS_W, "r", [], [
      Element(xe(NS_W, "fldChar", [w_attr("fldCharType", kind)], [])),
    ])
  }

  // Wrap a list of WML runs inside a `<w:p>` paragraph (no `<w:pPr>`).
  let wrap_in_paragraph = fn(runs : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for r in runs {
      kids.push(Element(r))
    }
    xe(NS_W, "p", [], kids)
  }

  // `<w:r>` with arbitrary run inner-content elements.  Used for
  // revision payloads where `<w:t>` is not the only legal text carrier
  // (`delText`, `delInstrText`, `ptab`, etc.).
  let run_with = fn(children : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for child in children {
      kids.push(Element(child))
    }
    xe(NS_W, "r", [], kids)
  }

  let text_leaf = fn(name : String, text : String) -> @xml.Element {
    xe(NS_W, name, [], [Text(text)])
  }

  let change_attrs = fn(id_ : String) -> Array[@xml.Attribute] {
    [
      w_attr("id", id_),
      w_attr("author", "Catalog User"),
      w_attr("date", "2026-06-06T00:00:00Z"),
    ]
  }

  // Wrap a list of paragraphs inside a `<w:body>`.
  let body_with = fn(paras : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for p in paras {
      kids.push(Element(p))
    }
    xe(NS_W, "body", [], kids)
  }

  // ==================================================================
  // §17.3.1.10 framePr — text-frame around a paragraph
  // ==================================================================
  // `<w:framePr>` lives inside `<w:pPr>` and turns its containing
  // paragraph into a positioned text frame (width, height, wrap mode,
  // h/v anchor).  The visual difference from a plain paragraph is
  // that the frame sits at an explicit (x,y) inside the page and the
  // surrounding text wraps around it.  Fixture exercises a fixed-
  // width side-anchored frame with surrounding body prose, so a
  // viewer that ignores `<w:framePr>` will place the framed paragraph
  // in normal flow and the regression is visible at a glance.
  //
  // Attributes used:
  //   w:w        — frame width  (twips)
  //   w:h        — frame height (twips)
  //   w:hAnchor  — horizontal anchor: "text" | "margin" | "page"
  //   w:vAnchor  — vertical   anchor: same enum
  //   w:wrap     — wrap mode: "around" (text wraps around the frame)
  //   w:x        — horizontal offset (twips, relative to hAnchor)
  //   w:y        — vertical   offset (twips, relative to vAnchor)
  cases.push({
    id: "extras-wml-framepr-side-anchored",
    format: "docx",
    category: "framePr",
    content: body_with([
      // Body prose preceding the frame (the frame floats inline).
      w_p(None, [
        w_run(
          None,
          "Body text before the floated frame. " +
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " +
          "The next paragraph carries a <w:framePr> that anchors a " +
          "text frame to the right margin so the surrounding prose " +
          "wraps around it.",
        ),
      ]),
      // The framed paragraph: pPr → framePr + r → t.
      xe(NS_W, "p", [], [
        Element(
          xe(NS_W, "pPr", [], [
            Element(
              xe(
                NS_W,
                "framePr",
                [
                  w_attr("w", "3600"),
                  w_attr("h", "1200"),
                  w_attr("hAnchor", "margin"),
                  w_attr("vAnchor", "text"),
                  w_attr("wrap", "around"),
                  w_attr("x", "5400"),
                  w_attr("y", "100"),
                ],
                [],
              ),
            ),
          ]),
        ),
        Element(
          w_run(
            None,
            "FRAMED — this paragraph is wrapped in a side-anchored text frame.",
          ),
        ),
      ]),
      // More body prose flowing AFTER the frame so the wrap effect is
      // exercised even when the frame fits on the first line band.
      w_p(None, [
        w_run(
          None,
          "Body text after the frame continues the natural flow. " +
          "Ut enim ad minim veniam, quis nostrud exercitation " +
          "ullamco laboris nisi ut aliquip ex ea commodo consequat.",
        ),
      ]),
    ]),
  })

  // ==================================================================
  // §17.5.1.13 smartTag — SmartTag wrapper around runs
  // ==================================================================
  // `<w:smartTag>` carries `@w:uri` (the SmartTag namespace URI) and
  // `@w:element` (the local SmartTag element name) and wraps the
  // detected runs.  The wrapper is transparent for rendering — the
  // inner runs render unchanged — but a buggy viewer that fails to
  // descend into `<w:smartTag>` would drop the wrapped runs entirely.
  // The fixture surrounds a date phrase with smartTag and embeds it
  // between two regular runs so any drop is visible as a missing
  // middle segment.
  cases.push({
    id: "extras-wml-smarttag-date",
    format: "docx",
    category: "smartTag",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "Meeting scheduled for "),
        // <w:smartTag w:uri="urn:schemas-microsoft-com:office:smarttags"
        //             w:element="date">
        //   <w:r><w:t>15 January 2026</w:t></w:r>
        // </w:smartTag>
        xe(
          NS_W,
          "smartTag",
          [
            w_attr("uri", "urn:schemas-microsoft-com:office:smarttags"),
            w_attr("element", "date"),
          ],
          [Element(w_run(None, "15 January 2026"))],
        ),
        w_run(None, " in conference room A."),
      ]),
    ]),
  })

  // ==================================================================
  // §17.5.2.31 sdt / §17.5.2.30 sdtContent — Structured Document Tag
  // ==================================================================
  // SDT (a.k.a. content control) wraps runs with a `<w:sdt>` carrying
  // `<w:sdtPr>` (control metadata) and `<w:sdtContent>` (the actual
  // payload).  Like smartTag, it is a transparent wrapper for
  // rendering; a viewer must descend into `<w:sdtContent>` to surface
  // the inner runs.  Fixture uses an inline (run-level) SDT with a
  // unique alias and tag so the dropped payload would be detectable.
  cases.push({
    id: "extras-wml-sdt-inline-text",
    format: "docx",
    category: "sdt",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "Contact name: "),
        // <w:sdt>
        //   <w:sdtPr>
        //     <w:alias w:val="ContactName"/>
        //     <w:tag w:val="contact-name"/>
        //   </w:sdtPr>
        //   <w:sdtContent>
        //     <w:r><w:t>Jane Q. Public</w:t></w:r>
        //   </w:sdtContent>
        // </w:sdt>
        xe(NS_W, "sdt", [], [
          Element(
            xe(NS_W, "sdtPr", [], [
              Element(xe(NS_W, "alias", [w_attr("val", "ContactName")], [])),
              Element(xe(NS_W, "tag", [w_attr("val", "contact-name")], [])),
            ]),
          ),
          Element(
            xe(NS_W, "sdtContent", [], [Element(w_run(None, "Jane Q. Public"))]),
          ),
        ]),
        w_run(None, " — please verify."),
      ]),
    ]),
  })

  // Rich SDT properties and subtype branches.  CT_SdtPr permits only
  // one subtype choice per SDT, so this fixture emits a small gallery
  // of independent inline SDTs to observe every branch in schema order.
  let sdt_list_item = fn(label : String, value : String) -> @xml.Element {
    xe(
      NS_W,
      "listItem",
      [w_attr("displayText", label), w_attr("value", value)],
      [],
    )
  }
  let doc_part_choice = fn(name : String) -> @xml.Element {
    xe(NS_W, name, [], [
      Element(w_val("docPartGallery", "docParts")),
      Element(w_val("docPartCategory", "Catalog Category")),
      Element(w_val("docPartUnique", "1")),
    ])
  }
  let sdt_pr_rich = fn(id_ : String, choice : @xml.Element) -> @xml.Element {
    xe(NS_W, "sdtPr", [], [
      Element(w_rpr([w_val("color", "2F5597")])),
      Element(w_val("alias", "Catalog SDT " + id_)),
      Element(w_val("tag", "catalog-sdt-" + id_)),
      Element(w_val("id", id_)),
      Element(w_val("lock", "sdtContentLocked")),
      Element(
        xe(NS_W, "placeholder", [], [
          Element(w_val("docPart", "Catalog Placeholder")),
        ]),
      ),
      Element(w_val("temporary", "0")),
      Element(w_val("showingPlcHdr", "0")),
      Element(
        xe(
          NS_W,
          "dataBinding",
          [
            w_attr("prefixMappings", "xmlns:cat='urn:catalog:sdt'"),
            w_attr("xpath", "/cat:root/cat:value"),
            w_attr("storeItemID", "{11111111-2222-3333-4444-555555555555}"),
          ],
          [],
        ),
      ),
      Element(w_val("label", id_)),
      Element(w_val("tabIndex", id_)),
      Element(choice),
    ])
  }
  let sdt_run = fn(
    id_ : String,
    choice : @xml.Element,
    text : String,
  ) -> @xml.Element {
    xe(NS_W, "sdt", [], [
      Element(sdt_pr_rich(id_, choice)),
      Element(xe(NS_W, "sdtEndPr", [], [Element(w_rpr([w_flag("i")]))])),
      Element(xe(NS_W, "sdtContent", [], [Element(w_run(None, text))])),
    ])
  }
  cases.push({
    id: "extras-wml-sdt-control-gallery",
    format: "docx",
    category: "sdt",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "Equation: "),
        sdt_run("901", xe(NS_W, "equation", [], []), "x + y"),
      ]),
      wrap_in_paragraph([
        w_run(None, "Combo: "),
        sdt_run(
          "902",
          xe(NS_W, "comboBox", [w_attr("lastValue", "two")], [
            Element(sdt_list_item("One", "one")),
            Element(sdt_list_item("Two", "two")),
          ]),
          "Two",
        ),
      ]),
      wrap_in_paragraph([
        w_run(None, "Date: "),
        sdt_run(
          "903",
          xe(NS_W, "date", [w_attr("fullDate", "2026-06-06T00:00:00Z")], [
            Element(w_val("dateFormat", "yyyy-MM-dd")),
            Element(w_val("lid", "en-US")),
            Element(w_val("storeMappedDataAs", "dateTime")),
            Element(w_val("calendar", "gregorian")),
          ]),
          "2026-06-06",
        ),
      ]),
      wrap_in_paragraph([
        w_run(None, "Doc part object: "),
        sdt_run("904", doc_part_choice("docPartObj"), "Object part"),
      ]),
      wrap_in_paragraph([
        w_run(None, "Doc part list: "),
        sdt_run("905", doc_part_choice("docPartList"), "List part"),
      ]),
      wrap_in_paragraph([
        w_run(None, "Drop-down: "),
        sdt_run(
          "906",
          xe(NS_W, "dropDownList", [w_attr("lastValue", "beta")], [
            Element(sdt_list_item("Alpha", "alpha")),
            Element(sdt_list_item("Beta", "beta")),
          ]),
          "Beta",
        ),
      ]),
      wrap_in_paragraph([
        w_run(None, "Picture marker: "),
        sdt_run("907", xe(NS_W, "picture", [], []), "Picture placeholder"),
      ]),
      wrap_in_paragraph([
        w_run(None, "Rich text: "),
        sdt_run("908", xe(NS_W, "richText", [], []), "Rich text payload"),
      ]),
      wrap_in_paragraph([
        w_run(None, "Plain text: "),
        sdt_run(
          "909",
          xe(NS_W, "text", [w_attr("multiLine", "1")], []),
          "Plain text",
        ),
      ]),
      wrap_in_paragraph([
        w_run(None, "Citation marker: "),
        sdt_run("910", xe(NS_W, "citation", [], []), "Citation payload"),
      ]),
      wrap_in_paragraph([
        w_run(None, "Group marker: "),
        sdt_run("911", xe(NS_W, "group", [], []), "Grouped content"),
      ]),
      wrap_in_paragraph([
        w_run(None, "Bibliography marker: "),
        sdt_run("912", xe(NS_W, "bibliography", [], []), "Bibliography payload"),
      ]),
    ]),
  })

  // ==================================================================
  // §17.5.5 customXml — generic CustomXML wrapper
  // ==================================================================
  // `<w:customXml>` is similar to `<w:smartTag>` but for arbitrary
  // CustomXml round-trip elements (third-party annotations); it
  // carries `@w:uri`, `@w:element`, optional `<w:customXmlPr>`.
  // Same transparency rule: descend through the wrapper and render
  // inner runs unchanged.
  cases.push({
    id: "extras-wml-customxml-citation",
    format: "docx",
    category: "customXml",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "As shown in "),
        // <w:customXml w:uri="http://example.com/citation" w:element="ref">
        //   <w:r><w:t>(Smith 2024)</w:t></w:r>
        // </w:customXml>
        xe(
          NS_W,
          "customXml",
          [
            w_attr("uri", "http://example.com/citation"),
            w_attr("element", "ref"),
          ],
          [Element(w_run(None, "(Smith 2024)"))],
        ),
        w_run(None, ", the result follows."),
      ]),
    ]),
  })

  // `<w:customXmlPr>` carries custom XML placeholder/attribute metadata
  // before the wrapped inline content.  This fixture adds the property
  // branch that the transparent citation wrapper above intentionally
  // omits.
  cases.push({
    id: "extras-wml-customxml-properties",
    format: "docx",
    category: "customXml",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "Custom XML metadata: "),
        xe(
          NS_W,
          "customXml",
          [
            w_attr("uri", "urn:catalog:customxml"),
            w_attr("element", "annotated"),
          ],
          [
            Element(
              xe(NS_W, "customXmlPr", [], [
                Element(w_val("placeholder", "Catalog placeholder")),
                Element(
                  xe(
                    NS_W,
                    "attr",
                    [
                      w_attr("uri", "urn:catalog:customxml"),
                      w_attr("name", "role"),
                      w_attr("val", "sample"),
                    ],
                    [],
                  ),
                ),
              ]),
            ),
            Element(w_run(None, "inline payload")),
          ],
        ),
        w_run(None, "."),
      ]),
    ]),
  })

  // Bidirectional embedding/override wrappers.  They are transparent
  // containers over EG_PContent, but a parser/viewer must recurse
  // through them instead of dropping the nested runs.
  cases.push({
    id: "extras-wml-bidi-run-wrappers",
    format: "docx",
    category: "bidi",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "Bidi wrappers: "),
        xe(NS_W, "dir", [w_attr("val", "rtl")], [
          Element(w_run(None, "RTL embedded text")),
        ]),
        w_run(None, " / "),
        xe(NS_W, "bdo", [w_attr("val", "ltr")], [
          Element(w_run(None, "LTR override text")),
        ]),
      ]),
    ]),
  })

  // Revision/range markers that live directly in paragraph content.
  // This covers run-level track-change containers, move/custom-XML
  // range pairs, permission ranges, proof-error ranges, and deleted
  // run text carriers.  The elements are intentionally adjacent to
  // visible runs so a viewer that drops or renders the markers
  // incorrectly changes the fixture output.
  cases.push({
    id: "extras-wml-revision-range-gallery",
    format: "docx",
    category: "revision",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "Revision gallery: "),
        xe(NS_W, "proofErr", [w_attr("type", "spellStart")], []),
        w_run(None, "mispelled"),
        xe(NS_W, "proofErr", [w_attr("type", "spellEnd")], []),
        w_run(None, " "),
        xe(
          NS_W,
          "permStart",
          [w_attr("id", "perm1"), w_attr("edGrp", "everyone")],
          [],
        ),
        w_run(None, "editable range"),
        xe(NS_W, "permEnd", [w_attr("id", "perm1")], []),
      ]),
      wrap_in_paragraph([
        xe(NS_W, "customXmlInsRangeStart", change_attrs("201"), []),
        w_run(None, "custom XML inserted range"),
        xe(NS_W, "customXmlInsRangeEnd", [w_attr("id", "201")], []),
        w_run(None, " "),
        xe(NS_W, "customXmlDelRangeStart", change_attrs("202"), []),
        w_run(None, "custom XML deleted range"),
        xe(NS_W, "customXmlDelRangeEnd", [w_attr("id", "202")], []),
      ]),
      wrap_in_paragraph([
        xe(NS_W, "customXmlMoveFromRangeStart", change_attrs("203"), []),
        w_run(None, "custom XML move-from range"),
        xe(NS_W, "customXmlMoveFromRangeEnd", [w_attr("id", "203")], []),
        w_run(None, " "),
        xe(NS_W, "customXmlMoveToRangeStart", change_attrs("204"), []),
        w_run(None, "custom XML move-to range"),
        xe(NS_W, "customXmlMoveToRangeEnd", [w_attr("id", "204")], []),
      ]),
      wrap_in_paragraph([
        xe(
          NS_W,
          "moveFromRangeStart",
          [
            w_attr("id", "205"),
            w_attr("name", "move-from-bookmark"),
            w_attr("author", "Catalog User"),
            w_attr("date", "2026-06-06T00:00:00Z"),
          ],
          [],
        ),
        w_run(None, "moved-from marked range"),
        xe(NS_W, "moveFromRangeEnd", [w_attr("id", "205")], []),
        w_run(None, " "),
        xe(
          NS_W,
          "moveToRangeStart",
          [
            w_attr("id", "206"),
            w_attr("name", "move-to-bookmark"),
            w_attr("author", "Catalog User"),
            w_attr("date", "2026-06-06T00:00:00Z"),
          ],
          [],
        ),
        w_run(None, "moved-to marked range"),
        xe(NS_W, "moveToRangeEnd", [w_attr("id", "206")], []),
      ]),
      wrap_in_paragraph([
        xe(NS_W, "ins", change_attrs("207"), [
          Element(w_run(None, "inserted run")),
        ]),
        w_run(None, " "),
        xe(NS_W, "del", change_attrs("208"), [
          Element(run_with([text_leaf("delText", "deleted run")])),
        ]),
        w_run(None, " "),
        xe(NS_W, "moveFrom", change_attrs("209"), [
          Element(run_with([text_leaf("delInstrText", " MERGEFIELD OldName ")])),
        ]),
        w_run(None, " "),
        xe(NS_W, "moveTo", change_attrs("210"), [
          Element(w_run(None, "moved-to run")),
        ]),
      ]),
      wrap_in_paragraph([
        w_run(None, "Absolute tab"),
        run_with([
          xe(
            NS_W,
            "ptab",
            [
              w_attr("alignment", "right"),
              w_attr("relativeTo", "margin"),
              w_attr("leader", "dot"),
            ],
            [],
          ),
        ]),
        w_run(None, "42"),
      ]),
    ]),
  })

  // ==================================================================
  // §17.13.5.{3,4,5} commentRange{Start,End} / commentReference
  // ==================================================================
  // Comment-anchored range markers wrap a span of runs with a
  // commentRangeStart … commentRangeEnd pair (shared `@w:id`) and
  // emit a `<w:commentReference>` to attach the threaded comment.
  // The markers themselves render NOTHING; the wrapped runs render
  // unchanged.  A viewer that mistakes the markers for renderable
  // runs would emit extra glyphs or break the line.
  cases.push({
    id: "extras-wml-comment-range-wrap",
    format: "docx",
    category: "commentRange",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "The "),
        // <w:commentRangeStart w:id="0"/>
        xe(NS_W, "commentRangeStart", [w_attr("id", "0")], []),
        w_run(None, "quick brown fox"),
        // <w:commentRangeEnd w:id="0"/>
        xe(NS_W, "commentRangeEnd", [w_attr("id", "0")], []),
        // NOTE: a real Word document would follow with
        // `<w:r><w:commentReference w:id="0"/></w:r>` and a matching
        // `word/comments.xml` part holding the threaded comment.
        // The OPC reader / .rels manifest needed to attach that part
        // is out of scope for this fixture, which exercises only the
        // RANGE-MARKER pair (a transparent wrapper for rendering);
        // Conformant readers reject the whole `.docx` when the
        // reference resolves to a missing part, so we omit the
        // reference and keep only the start / end pair.
        w_run(None, " jumps over the lazy dog."),
      ]),
    ]),
  })

  // ==================================================================
  // §17.16.18 fldChar — complex field with split instructions
  // ==================================================================
  // The simple-field form (`<w:fldSimple w:instr=…>`) is already
  // covered by `fixtures_wml_fields.mbt`.  This fixture exercises
  // the more involved COMPLEX form (begin / separate / end fldChar
  // frames) with the instruction split across MULTIPLE
  // `<w:instrText>` runs — a common Word behaviour for long
  // instructions (revision-tracked edits to the instruction string).
  //
  // The frame structure:
  //   r:fldChar(begin)
  //   r:instrText(" PAGEREF ")
  //   r:instrText("bookmark1")
  //   r:instrText(" \\h \\* MERGEFORMAT ")
  //   r:fldChar(separate)
  //   r:t("12")                  -- cached display result
  //   r:fldChar(end)
  cases.push({
    id: "extras-wml-fldchar-split-instr",
    format: "docx",
    category: "fldComplex",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "See page "),
        fldchar_run("begin"),
        instr_run(" PAGEREF "),
        instr_run("bookmark1"),
        instr_run(" \\h \\* MERGEFORMAT "),
        fldchar_run("separate"),
        w_run(None, "12"),
        fldchar_run("end"),
        w_run(None, " for details."),
      ]),
    ]),
  })

  // ==================================================================
  // §17.16.22 hyperlink — anchor-only (intra-document) hyperlink
  // ==================================================================
  // The existing fields fixtures cover external (r:id-bearing)
  // hyperlinks.  This fixture covers the anchor-only form
  // (`@w:anchor` without `@r:id`) which targets a bookmark inside
  // the same document — a frequent intra-document navigation
  // pattern (table of contents → section anchor).  Runs inside the
  // hyperlink carry the conventional `<w:rStyle w:val="Hyperlink"/>`
  // so the styled-link path is exercised.
  cases.push({
    id: "extras-wml-hyperlink-anchor-only",
    format: "docx",
    category: "hyperlinkAnchor",
    content: body_with([
      wrap_in_paragraph([
        w_run(None, "Jump to "),
        // <w:hyperlink w:anchor="section-3" w:tooltip="Go to Section 3">
        //   <w:r><w:rPr><w:rStyle w:val="Hyperlink"/></w:rPr>
        //        <w:t>Section 3</w:t></w:r>
        // </w:hyperlink>
        xe(
          NS_W,
          "hyperlink",
          [w_attr("anchor", "section-3"), w_attr("tooltip", "Go to Section 3")],
          [
            Element(
              w_run(Some(w_rpr([w_val("rStyle", "Hyperlink")])), "Section 3"),
            ),
          ],
        ),
        w_run(None, " for the conclusion."),
      ]),
    ]),
  })
}
