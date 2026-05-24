// WML drawing visual-fixtures — `<w:drawing>` wrappers around
// DrawingML payloads, per ECMA-376 §17.3.3.9 (drawing).
//
// A `<w:drawing>` contains either `<wp:inline>` (drawing flows with
// the text, inserted at the run position) or `<wp:anchor>` (drawing
// is positioned absolutely with text wrapping behaviour) — both
// elements live in the dml-wordprocessingDrawing namespace
// (`wp`). The drawing then carries a `<a:graphic>` whose
// `<a:graphicData uri=".../picture">` payload is a `<pic:pic>`
// element (DrawingML picture namespace).
//
// Most fixtures here intentionally OMIT the `<a:blip r:embed=…>`
// reference to image media: shipping binary images in the fixture
// catalogue would defeat the point of an XML-only test surface.
// The reference renderer and our renderer both fall back to a
// placeholder box for an unresolved picture, so the
// visual-comparison pipeline can
// still measure drawing-wrapper geometry (extent, position, anchor
// distances) even without a real image.  The few "shape" fixtures
// (`<wps:wsp>` wordprocessing-shape) carry their own renderable
// content (a preset-geometry + text body), so they exercise the
// `<w:drawing>` → DML shape path that DOES have visible output even
// without media.
//
// Helpers `w_p`, `w_run`, `xe`, `xa`, and the constants `NS_W`,
// `NS_A` come from the catalog's shared modules
// (`fixtures.mbt`, `fixtures_helpers.mbt`, `verify.mbt`).  The three
// drawing-specific namespaces are declared locally per ECMA-376
// §20.4 (wordprocessing-drawing wrapper) and §20.2 (DrawingML
// picture).

///|
fn extras_wml_drawings(cases : Array[VisualCase]) -> Unit {
  // dml-wordprocessingDrawing namespace — wraps inline/anchor and
  // the `<wp:extent>`, `<wp:docPr>`, `<wp:positionH>`, etc. children.
  let ns_wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  // DrawingML-picture namespace — `<pic:pic>`, `<pic:nvPicPr>`,
  // `<pic:blipFill>`, `<pic:spPr>` (§20.2).
  let ns_pic = "http://schemas.openxmlformats.org/drawingml/2006/picture"
  // wordprocessing-shape namespace — `<wps:wsp>`, `<wps:bodyPr>`,
  // `<wps:txbx>` (§20.5).  Used for text-frame fixtures where the
  // shape carries its own renderable run content instead of an
  // image reference.
  let ns_wps = "http://schemas.microsoft.com/office/word/2010/wordprocessingShape"

  // ---- Element-builder helpers ---------------------------------
  //
  // `wp_*` builds an element in the dml-wordprocessingDrawing
  // namespace; `pic_*` in the DrawingML-picture namespace; `wps_*`
  // in the wordprocessing-shape namespace.  Centralising the
  // namespace plumbing keeps the cases below readable.
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
  let wps_el = fn(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xe(ns_wps, name, attrs, kids)
  }
  let a_el = fn(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xe(NS_A, name, attrs, kids)
  }

  // `<wp:extent cx="…" cy="…"/>` — required size of the drawing's
  // box in EMU (English Metric Units, 914400 / inch).
  let extent = fn(cx : String, cy : String) -> @xml.Element {
    wp_el("extent", [xa("cx", cx), xa("cy", cy)], [])
  }
  // `<wp:docPr id="…" name="…"/>` — non-visual identifier required
  // by both inline and anchor drawings.
  let docpr = fn(id_ : String, name : String) -> @xml.Element {
    wp_el("docPr", [xa("id", id_), xa("name", name)], [])
  }
  // `<a:graphic><a:graphicData uri="…/picture"><pic:pic>…</pic:pic>`
  // — the picture graphic-data branch (§20.1.2.2.16).  Even with an
  // empty `<pic:pic>` body, the renderer recognises the URI and
  // falls back to a placeholder box of the parent's `<wp:extent>`.
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
  // `<a:graphic><a:graphicData uri="…/wordprocessingShape"><wps:wsp>`
  // — the wordprocessing-shape graphic-data branch.
  let wps_graphic = fn(inner : Array[@xml.Node]) -> @xml.Element {
    a_el("graphic", [], [
      Element(
        a_el(
          "graphicData",
          [
            xa(
              "uri", "http://schemas.microsoft.com/office/word/2010/wordprocessingShape",
            ),
          ],
          [Element(wps_el("wsp", [], inner))],
        ),
      ),
    ])
  }
  // `<wp:inline distT="0" distB="0" distL="0" distR="0">extent docPr graphic</wp:inline>`
  // — inline drawing wrapper.  The four distance attributes give the
  // padding (in EMU) between the inline image box and surrounding
  // text on each side; zero is the canonical default.
  let inline = fn(
    cx : String,
    cy : String,
    id_ : String,
    name : String,
    graphic : @xml.Element,
  ) -> @xml.Element {
    wp_el(
      "inline",
      [xa("distT", "0"), xa("distB", "0"), xa("distL", "0"), xa("distR", "0")],
      [Element(extent(cx, cy)), Element(docpr(id_, name)), Element(graphic)],
    )
  }
  // `<wp:anchor …>simplePos positionH positionV extent wrap docPr
  // graphic</wp:anchor>` — floating anchored drawing.  The boolean
  // attributes (behindDoc, locked, layoutInCell, allowOverlap) and
  // `relativeHeight` are all required by the schema.  The four
  // dist* attributes give text-wrap padding; the `simplePos` element
  // is required but ignored when `simplePos="0"`.
  //
  // `wrap_kind` selects the text-wrapping behaviour element:
  //   - "none"   — `<wp:wrapNone/>` (drawing floats over text)
  //   - "square" — `<wp:wrapSquare wrapText="bothSides"/>`
  //   - "tight"  — `<wp:wrapTight wrapText="bothSides"/>` (degenerate
  //                without a `<wp:wrapPolygon>` child; conformant
  //                renderers fall back to a rectangular wrap)
  //   - "topBottom" — `<wp:wrapTopAndBottom/>`
  let anchor = fn(
    pos_x : String,
    pos_y : String,
    cx : String,
    cy : String,
    behind_doc : String,
    wrap_kind : String,
    id_ : String,
    name : String,
    graphic : @xml.Element,
  ) -> @xml.Element {
    let wrap_el = match wrap_kind {
      "square" => wp_el("wrapSquare", [xa("wrapText", "bothSides")], [])
      "tight" => wp_el("wrapTight", [xa("wrapText", "bothSides")], [])
      "topBottom" => wp_el("wrapTopAndBottom", [], [])
      _ => wp_el("wrapNone", [], [])
    }
    wp_el(
      "anchor",
      [
        xa("distT", "0"),
        xa("distB", "0"),
        xa("distL", "114300"),
        xa("distR", "114300"),
        xa("simplePos", "0"),
        xa("relativeHeight", "251658240"),
        xa("behindDoc", behind_doc),
        xa("locked", "0"),
        xa("layoutInCell", "1"),
        xa("allowOverlap", "1"),
      ],
      [
        Element(wp_el("simplePos", [xa("x", "0"), xa("y", "0")], [])),
        Element(
          wp_el("positionH", [xa("relativeFrom", "column")], [
            Element(wp_el("posOffset", [], [Text(pos_x)])),
          ]),
        ),
        Element(
          wp_el("positionV", [xa("relativeFrom", "paragraph")], [
            Element(wp_el("posOffset", [], [Text(pos_y)])),
          ]),
        ),
        Element(extent(cx, cy)),
        Element(wrap_el),
        Element(docpr(id_, name)),
        Element(graphic),
      ],
    )
  }
  // `<pic:nvPicPr><pic:cNvPr id name/><pic:cNvPicPr/></pic:nvPicPr>` —
  // non-visual picture properties (id + name).  Required for the
  // `<pic:pic>` payload even when no `<pic:blipFill>` follows.
  let pic_nv = fn(id_ : String, name : String) -> @xml.Element {
    pic_el("nvPicPr", [], [
      Element(pic_el("cNvPr", [xa("id", id_), xa("name", name)], [])),
      Element(pic_el("cNvPicPr", [], [])),
    ])
  }
  // `<pic:blipFill><a:blip/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>`
  // — empty blipFill: no `r:embed` attribute, so no image is
  // resolved.  Both the reference renderer and our renderer respond
  // with an empty/placeholder box.  Useful for fixtures that want
  // to exercise the picture layout path WITHOUT shipping binary
  // media.
  let pic_blipfill_empty = pic_el("blipFill", [], [
    Element(a_el("blip", [], [])),
    Element(a_el("stretch", [], [Element(a_el("fillRect", [], []))])),
  ])
  // `<pic:spPr><a:xfrm><a:off/><a:ext/></a:xfrm><a:prstGeom prst=…/></pic:spPr>`
  // — picture shape properties with explicit transform + preset
  // geometry frame.
  let pic_sppr = fn(cx : String, cy : String, prst : String) -> @xml.Element {
    pic_el("spPr", [], [
      Element(
        a_el("xfrm", [], [
          Element(a_el("off", [xa("x", "0"), xa("y", "0")], [])),
          Element(a_el("ext", [xa("cx", cx), xa("cy", cy)], [])),
        ]),
      ),
      Element(
        a_el("prstGeom", [xa("prst", prst)], [Element(a_el("avLst", [], []))]),
      ),
    ])
  }
  // `<a:p><a:r><a:t>…</a:t></a:r></a:p>` — single DrawingML paragraph
  // with one run carrying the given text, used inside `<wps:txbx>`
  // text boxes.
  let a_text_para = fn(text : String) -> @xml.Element {
    a_el("p", [], [
      Element(a_el("r", [], [Element(a_el("t", [], [Text(text)]))])),
    ])
  }
  // `<wps:txbx><w:txbxContent><w:p>…</w:p></w:txbxContent></wps:txbx>` —
  // WordprocessingML text-box content embedded inside a shape.  The
  // `<w:txbxContent>` element is in the `w:` namespace (not `wps:`).
  let wps_txbx = fn(text : String) -> @xml.Element {
    wps_el("txbx", [], [
      Element(
        xe(NS_W, "txbxContent", [], [Element(w_p(None, [w_run(None, text)]))]),
      ),
    ])
  }
  // `<wps:wsp>` body = nvSpPr + spPr (with prstGeom & solidFill) +
  // optional txbx + bodyPr.  When `text` is empty no txbx is
  // emitted, and the shape is rendered as a pure filled preset
  // (useful for "empty shape" placeholders).
  let wps_shape_body = fn(
    id_ : String,
    name : String,
    cx : String,
    cy : String,
    prst : String,
    fill_hex : String,
    text : String,
  ) -> Array[@xml.Node] {
    let body : Array[@xml.Node] = [
      Element(wps_el("cNvSpPr", [], [])),
      Element(
        wps_el("spPr", [], [
          Element(
            a_el("xfrm", [], [
              Element(a_el("off", [xa("x", "0"), xa("y", "0")], [])),
              Element(a_el("ext", [xa("cx", cx), xa("cy", cy)], [])),
            ]),
          ),
          Element(
            a_el("prstGeom", [xa("prst", prst)], [
              Element(a_el("avLst", [], [])),
            ]),
          ),
          Element(solid_fill(fill_hex)),
        ]),
      ),
    ]
    if text != "" {
      body.push(Element(wps_txbx(text)))
    }
    body.push(
      Element(wps_el("bodyPr", [xa("rtlCol", "0"), xa("anchor", "ctr")], [])),
    )
    // Insert cNvPr at the head so that wsp = cNvPr + cNvSpPr + spPr + …
    let head : Array[@xml.Node] = [
      Element(wps_el("cNvPr", [xa("id", id_), xa("name", name)], [])),
    ]
    for n in body {
      head.push(n)
    }
    head
  }

  // Wrap a `<w:drawing>` element as a paragraph child via a `<w:r>`
  // run — this is the canonical placement of drawings inside a body
  // paragraph (§17.3.3.9).
  let drawing_run = fn(drawing : @xml.Element) -> @xml.Element {
    xe(NS_W, "r", [], [Element(xe(NS_W, "drawing", [], [Element(drawing)]))])
  }

  // ============================================================
  // 1. Empty picture inline — placeholder box at 2.5" x 2"
  // ============================================================
  //
  // §17.3.3.9 + §20.4.2.8 — minimal `<w:drawing><wp:inline>` with a
  // `<pic:pic>` carrying only nvPicPr + empty blipFill + spPr.  No
  // `r:embed` attribute means no image media is resolved; both the
  // reference renderer and our renderer should produce an empty
  // 2.5" × 2" rectangle inline with surrounding text.
  cases.push({
    id: "drawing-inline-empty-pic",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Before "),
          drawing_run(
            inline(
              "2286000",
              "1828800",
              "1",
              "Empty",
              pic_graphic([
                Element(pic_nv("2", "EmptyPic")),
                Element(pic_blipfill_empty),
                Element(pic_sppr("2286000", "1828800", "rect")),
              ]),
            ),
          ),
          w_run(None, " after"),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 2. Empty picture anchor — wrapNone, behindDoc=0
  // ============================================================
  //
  // §20.4.2.3 — `<wp:anchor>` placed at a fixed offset from the
  // column origin.  Without an image media part the renderer should
  // still draw a placeholder rectangle at (1", 0.5") with size
  // 2" × 1.5".  `wrapNone` means surrounding text is unaffected.
  cases.push({
    id: "drawing-anchor-empty-pic",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            None,
            "Body paragraph that runs underneath the anchored image " +
            "placeholder positioned at one inch from the column edge.",
          ),
          drawing_run(
            anchor(
              "914400",
              "457200",
              "1828800",
              "1371600",
              "0",
              "none",
              "1",
              "AnchorEmpty",
              pic_graphic([
                Element(pic_nv("2", "AnchorEmptyPic")),
                Element(pic_blipfill_empty),
                Element(pic_sppr("1828800", "1371600", "rect")),
              ]),
            ),
          ),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 3. Inline wps:wsp filled rectangle — renderable shape (no media)
  // ============================================================
  //
  // §20.5.2.30 — `<wps:wsp>` carrying preset geometry + solid fill
  // gives an inline shape with VISIBLE content even without external
  // media.  Useful baseline for verifying the WML → DML shape path.
  cases.push({
    id: "drawing-inline-wps-rect-fill",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Inline shape: "),
          drawing_run(
            inline(
              "1828800",
              "1371600",
              "1",
              "RectShape",
              wps_graphic(
                wps_shape_body(
                  "2", "Rect1", "1828800", "1371600", "rect", "4F81BD", "",
                ),
              ),
            ),
          ),
          w_run(None, " trailing text"),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 4. Inline wps:wsp text-box rectangle — text inside shape
  // ============================================================
  //
  // §20.5.2.30 + §17.3.5 — `<wps:wsp>` with a `<wps:txbx>` carrying
  // a `<w:txbxContent>` paragraph.  Exercises the embedded-WML
  // text-frame rendering path.
  cases.push({
    id: "drawing-textbox-rect",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Surrounding text and "),
          drawing_run(
            inline(
              "2286000",
              "914400",
              "1",
              "TextBox",
              wps_graphic(
                wps_shape_body(
                  "2", "TBox1", "2286000", "914400", "rect", "FFFFCC", "Boxed text",
                ),
              ),
            ),
          ),
          w_run(None, " trailing."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 5. Inline wps:wsp rounded-rectangle text-box
  // ============================================================
  //
  // §20.1.9.30 `prst="roundRect"` — same as above but with a rounded
  // corner preset.  Visually distinct from rect so a fidelity bug in
  // either geometry surface is easy to spot.
  cases.push({
    id: "drawing-textbox-rounded",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Rounded "),
          drawing_run(
            inline(
              "2286000",
              "914400",
              "1",
              "RoundBox",
              wps_graphic(
                wps_shape_body(
                  "2", "RBox", "2286000", "914400", "roundRect", "DDEBF7", "Rounded text",
                ),
              ),
            ),
          ),
          w_run(None, " label."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 6. Inline wps:wsp ellipse shape
  // ============================================================
  //
  // §20.1.9.18 `prst="ellipse"` — non-rectangular geometry, no
  // text. Tests that the WML drawing path correctly delegates to
  // DML's preset-geometry renderer for non-rect shapes.
  cases.push({
    id: "drawing-inline-ellipse",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "An ellipse "),
          drawing_run(
            inline(
              "1828800",
              "1371600",
              "1",
              "Ellipse",
              wps_graphic(
                wps_shape_body(
                  "2", "Ell", "1828800", "1371600", "ellipse", "C5E0B4", "",
                ),
              ),
            ),
          ),
          w_run(None, " inline."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 7. Inline drawing — large (full page width approx 6")
  // ============================================================
  //
  // 5486400 EMU ≈ 6 inches (close to default US-Letter text column
  // width).  Exercises the "wide inline image" layout path where
  // the drawing alone fills the line box.
  cases.push({
    id: "drawing-inline-large",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Caption above.")])),
      Element(
        w_p(None, [
          drawing_run(
            inline(
              "5486400",
              "2057400",
              "1",
              "BigPic",
              pic_graphic([
                Element(pic_nv("2", "BigPic")),
                Element(pic_blipfill_empty),
                Element(pic_sppr("5486400", "2057400", "rect")),
              ]),
            ),
          ),
        ]),
      ),
      Element(w_p(None, [w_run(None, "Caption below.")])),
    ]),
  })

  // ============================================================
  // 8. Inline drawing — small icon-sized (0.5" square)
  // ============================================================
  //
  // 457200 EMU = 0.5 inch.  Common icon size.  Exercises the
  // small-inline path where surrounding text dominates the line box.
  cases.push({
    id: "drawing-inline-small",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "An icon "),
          drawing_run(
            inline(
              "457200",
              "457200",
              "1",
              "Icon",
              pic_graphic([
                Element(pic_nv("2", "Icon")),
                Element(pic_blipfill_empty),
                Element(pic_sppr("457200", "457200", "rect")),
              ]),
            ),
          ),
          w_run(None, " inline with body text."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 9. Anchor drawing — square text wrapping
  // ============================================================
  //
  // §20.4.2.16 `<wp:wrapSquare>` — body text reflows around the
  // anchored image's bounding box on both sides.  Without media the
  // image is a placeholder box, but the text reflow geometry MUST
  // still be honoured.
  cases.push({
    id: "drawing-anchor-wrap-square",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          drawing_run(
            anchor(
              "0",
              "0",
              "1828800",
              "1371600",
              "0",
              "square",
              "1",
              "WrapSquare",
              wps_graphic(
                wps_shape_body(
                  "2", "WS", "1828800", "1371600", "rect", "F4B084", "",
                ),
              ),
            ),
          ),
          w_run(
            None,
            "Body text that should reflow around the anchored image " +
            "with square wrapping. Each line wraps short on the side " +
            "of the image and resumes at full width below it.",
          ),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 10. Anchor drawing — topAndBottom wrapping
  // ============================================================
  //
  // §20.4.2.20 `<wp:wrapTopAndBottom>` — body text breaks above and
  // below the anchor, but does NOT wrap on either side.  The image
  // owns the full column width band it occupies.
  cases.push({
    id: "drawing-anchor-wrap-topbottom",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Paragraph before the anchored image."),
          drawing_run(
            anchor(
              "457200",
              "228600",
              "2286000",
              "914400",
              "0",
              "topBottom",
              "1",
              "WrapTB",
              wps_graphic(
                wps_shape_body(
                  "2", "WTB", "2286000", "914400", "rect", "8FAADC", "",
                ),
              ),
            ),
          ),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(
            None,
            "Paragraph after the anchored image - text should resume " +
            "below the floated box, never beside it.",
          ),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 11. Anchor drawing — behindDoc=1 (image behind text)
  // ============================================================
  //
  // §20.4.2.3 `@behindDoc="1"` puts the drawing BEHIND the text
  // layer, with wrapNone so the body text overlays it.  Common
  // pattern for watermarks and decorative backgrounds.
  cases.push({
    id: "drawing-anchor-behind-doc",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          drawing_run(
            anchor(
              "457200",
              "228600",
              "3657600",
              "914400",
              "1",
              "none",
              "1",
              "Behind",
              wps_graphic(
                wps_shape_body(
                  "2", "Bg", "3657600", "914400", "rect", "F2F2F2", "",
                ),
              ),
            ),
          ),
          w_run(
            None,
            "Foreground text drawn on top of the behindDoc rectangle " +
            "that acts as a subtle background panel.",
          ),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 12. Inline drawing — empty `<pic:pic>` (no children at all)
  // ============================================================
  //
  // Most-minimal placeholder: `<pic:pic/>` with no nvPicPr,
  // blipFill, or spPr.  Tests that the renderer survives a
  // completely empty picture body and falls back gracefully to the
  // wp:extent-sized placeholder.
  cases.push({
    id: "drawing-inline-bare-pic",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Bare "),
          drawing_run(
            inline("1828800", "914400", "1", "BarePic", pic_graphic([])),
          ),
          w_run(None, " trailing."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 13. Inline shape — triangle preset
  // ============================================================
  //
  // §20.1.9.65 `prst="triangle"` — visible non-rect, non-ellipse
  // preset.  Validates that an arbitrary preset name passes through
  // the WML → DML shape pipeline.
  cases.push({
    id: "drawing-inline-triangle",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Triangle "),
          drawing_run(
            inline(
              "1371600",
              "1371600",
              "1",
              "Tri",
              wps_graphic(
                wps_shape_body(
                  "2", "Tri1", "1371600", "1371600", "triangle", "FFC000", "",
                ),
              ),
            ),
          ),
          w_run(None, " inline."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 14. Two consecutive inline shapes — same paragraph
  // ============================================================
  //
  // Multiple `<w:drawing>` siblings in a single paragraph — checks
  // that consecutive inline drawings stack correctly along the
  // baseline and surrounding text positions properly.
  cases.push({
    id: "drawing-inline-pair",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Two: "),
          drawing_run(
            inline(
              "914400",
              "914400",
              "1",
              "A",
              wps_graphic(
                wps_shape_body(
                  "2", "ShapeA", "914400", "914400", "rect", "C00000", "",
                ),
              ),
            ),
          ),
          w_run(None, " "),
          drawing_run(
            inline(
              "914400",
              "914400",
              "3",
              "B",
              wps_graphic(
                wps_shape_body(
                  "4", "ShapeB", "914400", "914400", "ellipse", "00B050", "",
                ),
              ),
            ),
          ),
          w_run(None, " end."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 15. Inline text-box — multiline content
  // ============================================================
  //
  // `<wps:txbx>` carrying TWO `<w:p>` paragraphs — exercises the
  // multi-paragraph text-frame layout pathway.  Built inline because
  // `wps_txbx` only takes a single text string.
  let txbx_multi : @xml.Element = wps_el("txbx", [], [
    Element(
      xe(NS_W, "txbxContent", [], [
        Element(w_p(None, [w_run(None, "Line one of the text box.")])),
        Element(w_p(None, [w_run(None, "Line two of the text box.")])),
      ]),
    ),
  ])
  let multi_shape : Array[@xml.Node] = [
    Element(wps_el("cNvPr", [xa("id", "2"), xa("name", "MultiTB")], [])),
    Element(wps_el("cNvSpPr", [], [])),
    Element(
      wps_el("spPr", [], [
        Element(
          a_el("xfrm", [], [
            Element(a_el("off", [xa("x", "0"), xa("y", "0")], [])),
            Element(a_el("ext", [xa("cx", "2743200"), xa("cy", "1371600")], [])),
          ]),
        ),
        Element(
          a_el("prstGeom", [xa("prst", "rect")], [
            Element(a_el("avLst", [], [])),
          ]),
        ),
        Element(solid_fill("FFF2CC")),
      ]),
    ),
    Element(txbx_multi),
    Element(wps_el("bodyPr", [xa("rtlCol", "0"), xa("anchor", "t")], [])),
  ]
  cases.push({
    id: "drawing-textbox-multiline",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Before "),
          drawing_run(
            inline(
              "2743200",
              "1371600",
              "1",
              "MultiTB",
              wps_graphic(multi_shape),
            ),
          ),
          w_run(None, " after."),
        ]),
      ),
    ]),
  })

  // Reference the unused helpers so the MoonBit compiler doesn't
  // emit unused-let warnings if a fixture above is removed.  These
  // are all idempotent no-op identity bindings.
  let _ = a_text_para
}
