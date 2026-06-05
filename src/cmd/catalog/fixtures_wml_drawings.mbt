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
// distances) even without a real image.  Shape/text-box fixtures use
// ECMA Transitional VML payloads under `<a:graphicData>` so they
// remain schema-valid without depending on Microsoft Office 2010
// `wps` extension schemas.
//
// Helpers `w_p`, `w_run`, `xe`, `xa`, and the constants `NS_W`,
// `NS_A` come from the catalog's shared modules
// (`fixtures.mbt`, `fixtures_helpers.mbt`, `verify.mbt`).  The three
// drawing-specific namespaces are declared locally per ECMA-376
// §20.4 (wordprocessing-drawing wrapper), §20.2 (DrawingML
// picture), and Part 4 §19 (VML).

///|
fn extras_wml_drawings(cases : Array[VisualCase]) -> Unit {
  // dml-wordprocessingDrawing namespace — wraps inline/anchor and
  // the `<wp:extent>`, `<wp:docPr>`, `<wp:positionH>`, etc. children.
  let ns_wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  // DrawingML-picture namespace — `<pic:pic>`, `<pic:nvPicPr>`,
  // `<pic:blipFill>`, `<pic:spPr>` (§20.2).
  let ns_pic = "http://schemas.openxmlformats.org/drawingml/2006/picture"
  // VML namespace — Transitional ECMA-376 §19 legacy shapes.
  let ns_vml = "urn:schemas-microsoft-com:vml"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

  // ---- Element-builder helpers ---------------------------------
  //
  // `wp_*` builds an element in the dml-wordprocessingDrawing
  // namespace; `pic_*` in the DrawingML-picture namespace; `vml_*`
  // in the VML namespace.  Centralising the
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
  let vml_el = fn(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xe(ns_vml, name, attrs, kids)
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
  let c_nv_graphic_frame_pr = fn() -> @xml.Element {
    wp_el("cNvGraphicFramePr", [], [
      Element(a_el("graphicFrameLocks", [xa("noGrp", "1")], [])),
    ])
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
  // `<a:graphic><a:graphicData uri="urn:schemas-microsoft-com:vml"><v:*…/>`
  // — Transitional VML branch. The vendored VML XSD declares the
  // payload roots globally, so DML's strict `graphicData` wildcard
  // can validate them.
  let vml_graphic = fn(inner : Array[@xml.Node]) -> @xml.Element {
    a_el("graphic", [], [
      Element(a_el("graphicData", [xa("uri", ns_vml)], inner)),
    ])
  }
  let wpc_graphic = fn(inner : Array[@xml.Node]) -> @xml.Element {
    a_el("graphic", [], [
      Element(a_el("graphicData", [xa("uri", ns_wp)], inner)),
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
      [
        Element(extent(cx, cy)),
        Element(docpr(id_, name)),
        Element(c_nv_graphic_frame_pr()),
        Element(graphic),
      ],
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
        Element(c_nv_graphic_frame_pr()),
        Element(graphic),
      ],
    )
  }
  let effect_extent = fn() -> @xml.Element {
    wp_el(
      "effectExtent",
      [xa("l", "22860"), xa("t", "22860"), xa("r", "45720"), xa("b", "45720")],
      [],
    )
  }
  let wrap_polygon = fn() -> @xml.Element {
    wp_el("wrapPolygon", [xa("edited", "1")], [
      Element(wp_el("start", [xa("x", "0"), xa("y", "0")], [])),
      Element(wp_el("lineTo", [xa("x", "1828800"), xa("y", "0")], [])),
      Element(wp_el("lineTo", [xa("x", "1828800"), xa("y", "914400")], [])),
      Element(wp_el("lineTo", [xa("x", "0"), xa("y", "914400")], [])),
    ])
  }
  let wrap_tight = fn() -> @xml.Element {
    wp_el("wrapTight", [xa("wrapText", "bothSides")], [Element(wrap_polygon())])
  }
  let wrap_through = fn() -> @xml.Element {
    wp_el("wrapThrough", [xa("wrapText", "largest")], [Element(wrap_polygon())])
  }
  let position_h_align = fn(
    relative_from : String,
    align : String,
  ) -> @xml.Element {
    wp_el("positionH", [xa("relativeFrom", relative_from)], [
      Element(wp_el("align", [], [Text(align)])),
    ])
  }
  let position_v_align = fn(
    relative_from : String,
    align : String,
  ) -> @xml.Element {
    wp_el("positionV", [xa("relativeFrom", relative_from)], [
      Element(wp_el("align", [], [Text(align)])),
    ])
  }
  let position_h_offset = fn(
    relative_from : String,
    offset : String,
  ) -> @xml.Element {
    wp_el("positionH", [xa("relativeFrom", relative_from)], [
      Element(wp_el("posOffset", [], [Text(offset)])),
    ])
  }
  let position_v_offset = fn(
    relative_from : String,
    offset : String,
  ) -> @xml.Element {
    wp_el("positionV", [xa("relativeFrom", relative_from)], [
      Element(wp_el("posOffset", [], [Text(offset)])),
    ])
  }
  let anchor_with_wrap = fn(
    position_h : @xml.Element,
    position_v : @xml.Element,
    cx : String,
    cy : String,
    wrap_el : @xml.Element,
    id_ : String,
    name : String,
    graphic : @xml.Element,
  ) -> @xml.Element {
    wp_el(
      "anchor",
      [
        xa("distT", "0"),
        xa("distB", "0"),
        xa("distL", "114300"),
        xa("distR", "114300"),
        xa("simplePos", "0"),
        xa("relativeHeight", "251658240"),
        xa("behindDoc", "0"),
        xa("locked", "0"),
        xa("layoutInCell", "1"),
        xa("allowOverlap", "1"),
      ],
      [
        Element(wp_el("simplePos", [xa("x", "0"), xa("y", "0")], [])),
        Element(position_h),
        Element(position_v),
        Element(extent(cx, cy)),
        Element(effect_extent()),
        Element(wrap_el),
        Element(docpr(id_, name)),
        Element(c_nv_graphic_frame_pr()),
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
  // `<v:textbox><w:txbxContent><w:p>…</w:p></w:txbxContent></v:textbox>` —
  // WordprocessingML text-box content embedded inside a VML shape.
  let vml_txbx = fn(text : String) -> @xml.Element {
    vml_el("textbox", [], [
      Element(
        xe(NS_W, "txbxContent", [], [Element(w_p(None, [w_run(None, text)]))]),
      ),
    ])
  }
  let vml_shape_with_children = fn(
    id_ : String,
    prst : String,
    fill_hex : String,
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = [
      xa("id", id_),
      xa("fillcolor", "#" + fill_hex),
      xa("strokecolor", "#666666"),
    ]
    match prst {
      "ellipse" => vml_el("oval", attrs, kids)
      "roundRect" => vml_el("roundrect", attrs, kids)
      "triangle" =>
        vml_el(
          "shape",
          attrs +
          [
            xa("coordsize", "21600,21600"),
            xa("path", "m 10800,0 l 21600,21600 0,21600 x e"),
          ],
          kids,
        )
      _ => vml_el("rect", attrs, kids)
    }
  }
  let vml_shape = fn(
    id_ : String,
    prst : String,
    fill_hex : String,
    text : String,
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    if text != "" {
      kids.push(Element(vml_txbx(text)))
    }
    vml_shape_with_children(id_, prst, fill_hex, kids)
  }
  let wp_shape_xfrm = fn(cx : String, cy : String) -> @xml.Element {
    a_el("xfrm", [], [
      Element(a_el("off", [xa("x", "0"), xa("y", "0")], [])),
      Element(a_el("ext", [xa("cx", cx), xa("cy", cy)], [])),
    ])
  }
  let wp_group_xfrm = fn() -> @xml.Element {
    a_el("xfrm", [], [
      Element(a_el("off", [xa("x", "0"), xa("y", "0")], [])),
      Element(a_el("ext", [xa("cx", "2743200"), xa("cy", "1371600")], [])),
      Element(a_el("chOff", [xa("x", "0"), xa("y", "0")], [])),
      Element(a_el("chExt", [xa("cx", "2743200"), xa("cy", "1371600")], [])),
    ])
  }
  let wp_shape_pr = fn(
    cx : String,
    cy : String,
    fill_hex : String,
  ) -> @xml.Element {
    wp_el("spPr", [], [
      Element(wp_shape_xfrm(cx, cy)),
      Element(
        a_el("prstGeom", [xa("prst", "rect")], [Element(a_el("avLst", [], []))]),
      ),
      Element(
        a_el("solidFill", [], [
          Element(a_el("srgbClr", [xa("val", fill_hex)], [])),
        ]),
      ),
    ])
  }
  let wp_shape_style = fn() -> @xml.Element {
    let ref_color = fn(val : String) -> @xml.Element {
      a_el("schemeClr", [xa("val", val)], [])
    }
    wp_el("style", [], [
      Element(a_el("lnRef", [xa("idx", "1")], [Element(ref_color("accent1"))])),
      Element(
        a_el("fillRef", [xa("idx", "1")], [Element(ref_color("accent2"))]),
      ),
      Element(
        a_el("effectRef", [xa("idx", "1")], [Element(ref_color("accent3"))]),
      ),
      Element(
        a_el("fontRef", [xa("idx", "minor")], [Element(ref_color("tx1"))]),
      ),
    ])
  }
  let wp_canvas_bg = fn() -> @xml.Element {
    wp_el("bg", [], [
      Element(
        a_el("solidFill", [], [
          Element(a_el("srgbClr", [xa("val", "F2F2F2")], [])),
        ]),
      ),
    ])
  }
  let wp_canvas_whole = fn() -> @xml.Element {
    wp_el("whole", [], [
      Element(
        a_el("ln", [xa("w", "12700")], [
          Element(
            a_el("solidFill", [], [
              Element(a_el("srgbClr", [xa("val", "808080")], [])),
            ]),
          ),
        ]),
      ),
    ])
  }
  let wp_canvas_ext_lst = fn() -> @xml.Element {
    wp_el("extLst", [], [
      Element(a_el("ext", [xa("uri", "urn:ooxml:fixture:wp")], [])),
    ])
  }
  let wp_body_pr = fn() -> @xml.Element {
    wp_el("bodyPr", [xa("wrap", "square")], [])
  }
  let wp_textbox = fn(text : String) -> @xml.Element {
    wp_el("txbx", [xa("id", "1")], [
      Element(
        wp_el("txbxContent", [], [Element(w_p(None, [w_run(None, text)]))]),
      ),
    ])
  }
  let wp_text_shape = fn(
    id_ : String,
    name : String,
    text : String,
  ) -> @xml.Element {
    wp_el("wsp", [], [
      Element(wp_el("cNvPr", [xa("id", id_), xa("name", name)], [])),
      Element(wp_el("cNvSpPr", [xa("txBox", "1")], [])),
      Element(wp_shape_pr("1371600", "685800", "D9EAD3")),
      Element(wp_shape_style()),
      Element(wp_textbox(text)),
      Element(wp_body_pr()),
    ])
  }
  let wp_linked_connector_shape = fn() -> @xml.Element {
    wp_el("wsp", [xa("normalEastAsianFlow", "0")], [
      Element(
        wp_el("cNvPr", [xa("id", "32"), xa("name", "Linked Connector")], []),
      ),
      Element(
        wp_el("cNvCnPr", [], [
          Element(a_el("cxnSpLocks", [xa("noChangeShapeType", "1")], [])),
        ]),
      ),
      Element(wp_shape_pr("1371600", "457200", "CFE2F3")),
      Element(wp_el("linkedTxbx", [xa("id", "1"), xa("seq", "2")], [])),
      Element(wp_body_pr()),
    ])
  }
  let wp_graphic_frame = fn(id_ : String, name : String) -> @xml.Element {
    wp_el("graphicFrame", [], [
      Element(wp_el("cNvPr", [xa("id", id_), xa("name", name)], [])),
      Element(
        wp_el("cNvFrPr", [], [
          Element(a_el("graphicFrameLocks", [xa("noGrp", "1")], [])),
        ]),
      ),
      Element(
        wp_el("xfrm", [], [
          Element(a_el("off", [xa("x", "1524000"), xa("y", "0")], [])),
          Element(a_el("ext", [xa("cx", "914400"), xa("cy", "685800")], [])),
        ]),
      ),
      Element(
        a_el("graphic", [], [
          Element(
            a_el("graphicData", [xa("uri", "urn:ooxml-fixture:empty")], []),
          ),
        ]),
      ),
    ])
  }
  let wp_group = fn(name : String, child : @xml.Element?) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(wp_el("cNvPr", [xa("id", "50"), xa("name", name)], [])),
      Element(
        wp_el("cNvGrpSpPr", [], [
          Element(a_el("grpSpLocks", [xa("noUngrp", "1")], [])),
        ]),
      ),
      Element(wp_el("grpSpPr", [], [Element(wp_group_xfrm())])),
    ]
    match child {
      Some(c) => kids.push(Element(c))
      None => ()
    }
    wp_el("wgp", [], kids)
  }
  let wp_nested_group = fn() -> @xml.Element {
    let base = wp_group("Nested WP Group", None)
    wp_el("grpSp", base.attributes, base.children)
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
  // 3. Inline VML filled rectangle — renderable shape (no media)
  // ============================================================
  //
  // Transitional §19 VML `<v:rect>` gives an inline shape with
  // visible content even without external media.
  cases.push({
    id: "drawing-inline-vml-rect-fill",
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
              vml_graphic([Element(vml_shape("v2", "rect", "4F81BD", ""))]),
            ),
          ),
          w_run(None, " trailing text"),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 4. Inline VML text-box rectangle — text inside shape
  // ============================================================
  //
  // §19 VML `<v:rect>` with `<v:textbox>` carrying a
  // `<w:txbxContent>` paragraph. Exercises the embedded-WML
  // text-frame path while staying inside ECMA Transitional schemas.
  cases.push({
    id: "drawing-vml-textbox-rect",
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
              vml_graphic([
                Element(vml_shape("v2", "rect", "FFFFCC", "Boxed text")),
              ]),
            ),
          ),
          w_run(None, " trailing."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 5. Inline VML rounded-rectangle text-box
  // ============================================================
  //
  // §20.1.9.30 `prst="roundRect"` — same as above but with a rounded
  // corner preset.  Visually distinct from rect so a fidelity bug in
  // either geometry surface is easy to spot.
  cases.push({
    id: "drawing-vml-textbox-rounded",
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
              vml_graphic([
                Element(vml_shape("v2", "roundRect", "DDEBF7", "Rounded text")),
              ]),
            ),
          ),
          w_run(None, " label."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 6. Inline VML ellipse shape
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
              vml_graphic([Element(vml_shape("v2", "ellipse", "C5E0B4", ""))]),
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
              vml_graphic([Element(vml_shape("v2", "rect", "F4B084", ""))]),
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
              vml_graphic([Element(vml_shape("v2", "rect", "8FAADC", ""))]),
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
              vml_graphic([Element(vml_shape("v2", "rect", "F2F2F2", ""))]),
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
  // 12. Inline drawing — schema-minimal picture placeholder
  // ============================================================
  //
  // Minimal package-valid placeholder: `<pic:pic>` carries the
  // required nvPicPr, blipFill, and spPr children, but the blip has
  // no `r:embed` relationship. Tests that the renderer falls back
  // gracefully to the wp:extent-sized placeholder without shipping
  // binary media in the fixture catalogue.
  cases.push({
    id: "drawing-inline-bare-pic",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Bare "),
          drawing_run(
            inline(
              "1828800",
              "914400",
              "1",
              "BarePic",
              pic_graphic([
                Element(pic_nv("2", "BarePic")),
                Element(pic_blipfill_empty),
                Element(pic_sppr("1828800", "914400", "rect")),
              ]),
            ),
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
              vml_graphic([Element(vml_shape("v2", "triangle", "FFC000", ""))]),
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
              vml_graphic([Element(vml_shape("v2", "rect", "C00000", ""))]),
            ),
          ),
          w_run(None, " "),
          drawing_run(
            inline(
              "914400",
              "914400",
              "3",
              "B",
              vml_graphic([Element(vml_shape("v4", "ellipse", "00B050", ""))]),
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
  // `<v:textbox>` carrying TWO `<w:p>` paragraphs — exercises the
  // multi-paragraph text-frame layout pathway.
  let txbx_multi : @xml.Element = vml_el("textbox", [], [
    Element(
      xe(NS_W, "txbxContent", [], [
        Element(w_p(None, [w_run(None, "Line one of the text box.")])),
        Element(w_p(None, [w_run(None, "Line two of the text box.")])),
      ]),
    ),
  ])
  let multi_shape = vml_shape_with_children("v2", "rect", "FFF2CC", [
    Element(txbx_multi),
  ])
  cases.push({
    id: "drawing-vml-textbox-multiline",
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
              vml_graphic([Element(multi_shape)]),
            ),
          ),
          w_run(None, " after."),
        ]),
      ),
    ]),
  })

  // ============================================================
  // 16. Anchor drawing — tight/through polygon wrapping with align
  // ============================================================
  //
  // §20.4.2.10 / §20.4.2.17 / §20.4.2.18 / §20.4.2.21 —
  // `positionH/positionV` can select `<wp:align>` instead of
  // `<wp:posOffset>`, and tight/through wrapping requires an
  // explicit `<wp:wrapPolygon>` path with one start point and at
  // least two lineTo points.
  cases.push({
    id: "drawing-anchor-polygon-wraps-align",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          drawing_run(
            anchor_with_wrap(
              position_h_align("page", "center"),
              position_v_align("margin", "top"),
              "1828800",
              "914400",
              wrap_tight(),
              "20",
              "TightPolygon",
              vml_graphic([Element(vml_shape("v-tight", "rect", "EADCF8", ""))]),
            ),
          ),
          w_run(
            None,
            "Tight polygon wrapping uses an edited rectangular path and " +
            "alignment-based positioning instead of raw position offsets.",
          ),
        ]),
      ),
      Element(
        w_p(None, [
          drawing_run(
            anchor_with_wrap(
              position_h_offset("column", "457200"),
              position_v_offset("paragraph", "228600"),
              "1828800",
              "914400",
              wrap_through(),
              "21",
              "ThroughPolygon",
              vml_graphic([
                Element(vml_shape("v-through", "rect", "FCE5CD", "")),
              ]),
            ),
          ),
          w_run(
            None,
            "Through polygon wrapping follows the same path model but " +
            "lets text flow through the transparent interior region.",
          ),
        ]),
      ),
    ]),
  })

  let wpc_rich = wp_el("wpc", [], [
    Element(wp_canvas_bg()),
    Element(wp_canvas_whole()),
    Element(wp_text_shape("30", "WP Text Shape", "Text inside wp:wsp.")),
    Element(wp_linked_connector_shape()),
    Element(wp_group("Top WP Group", Some(wp_nested_group()))),
    Element(wp_graphic_frame("40", "WP Graphic Frame")),
    Element(wp_canvas_ext_lst()),
  ])
  cases.push({
    id: "drawing-wpc-shape-group-frame",
    format: "docx",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Canvas "),
          drawing_run(
            inline(
              "3200400",
              "1600200",
              "22",
              "WordprocessingCanvasRich",
              wpc_graphic([Element(wpc_rich)]),
            ),
          ),
          w_run(None, " branches."),
        ]),
      ),
    ]),
  })

  let content_part = wp_el(
    "contentPart",
    [
      {
        name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
        value: "rIdContentPart",
      },
    ],
    [
      Element(
        wp_el("nvContentPartPr", [], [
          Element(
            wp_el("cNvPr", [xa("id", "7"), xa("name", "Locked Content Part")], []),
          ),
          Element(
            wp_el("cNvContentPartPr", [], [
              Element(
                a_el("cpLocks", [xa("noGrp", "1"), xa("noSelect", "1")], []),
              ),
            ]),
          ),
        ]),
      ),
      Element(
        wp_el("xfrm", [], [
          Element(a_el("off", [xa("x", "0"), xa("y", "0")], [])),
          Element(a_el("ext", [xa("cx", "914400"), xa("cy", "914400")], [])),
        ]),
      ),
    ],
  )
  let wpc = wp_el("wpc", [], [Element(content_part)])
  cases.push({
    id: "drawing-content-part-cp-locks",
    format: "docx:contentPart",
    category: "drawing",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Before "),
          drawing_run(
            inline(
              "914400",
              "914400",
              "1",
              "ContentPartLocks",
              wpc_graphic([Element(wpc)]),
            ),
          ),
          w_run(None, " after."),
        ]),
      ),
    ]),
  })
}
