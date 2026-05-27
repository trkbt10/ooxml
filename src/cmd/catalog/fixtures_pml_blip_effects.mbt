// Visual fixtures for §20.1.8.13 CT_Blip raster effects.
//
// Each fixture embeds a test PNG and applies one or more blip
// effects via `<a:blip>` children. The snapshot pipeline
// (rsvg-convert → pdftoppm → ImageMagick compare) rasterises both
// the reference (LibreOffice) and our SVG and measures the RMSE
// to verify visual fidelity.

///|
/// 4×4 solid-red PNG (73 bytes).
fn test_image_4x4_red() -> Bytes {
  Bytes::from_array([
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
    0, 0, 0, 4, 0, 0, 0, 4, 8, 2, 0, 0, 0, 38, 147, 9, 41, 0, 0,
    0, 16, 73, 68, 65, 84, 120, 156, 99, 248, 207, 192, 0, 71, 12,
    196, 113, 0, 174, 147, 15, 241, 208, 95, 35, 158, 0, 0, 0, 0,
    73, 69, 78, 68, 174, 66, 96, 130,
  ])
}

///|
/// 8×8 four-quadrant PNG (85 bytes): red / green / blue / yellow.
fn test_image_8x8_quad() -> Bytes {
  Bytes::from_array([
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
    0, 0, 0, 8, 0, 0, 0, 8, 8, 2, 0, 0, 0, 75, 109, 41, 220, 0,
    0, 0, 28, 73, 68, 65, 84, 120, 156, 99, 248, 207, 192, 0, 71,
    12, 255, 113, 32, 10, 37, 144, 121, 255, 255, 51, 192, 17, 21,
    37, 0, 182, 141, 79, 177, 165, 30, 79, 187, 0, 0, 0, 0, 73, 69,
    78, 68, 174, 66, 96, 130,
  ])
}

///|
/// Build a `<p:pic>` element with an embedded blip (`r:embed="rId2"`)
/// and the specified effect children inside `<a:blip>`.
fn blip_pic(
  effects : Array[@xml.Element],
  x : String,
  y : String,
  cx : String,
  cy : String,
) -> @xml.Element {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let effect_kids : Array[@xml.Node] = []
  for e in effects {
    effect_kids.push(Element(e))
  }
  let blip : @xml.Element = {
    name: { prefix: Some("a"), local_name: "blip", ns: Some(NS_A) },
    attributes: [
      {
        name: { prefix: Some("r"), local_name: "embed", ns: Some(ns_r) },
        value: "rId2",
      },
    ],
    children: effect_kids,
  }
  fn pe(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("p", NS_PML, name, attrs, kids)
  }

  fn ae(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("a", NS_A, name, attrs, kids)
  }

  let xfrm = ae("xfrm", [], [
    Element(ae("off", [xa("x", x), xa("y", y)], [])),
    Element(ae("ext", [xa("cx", cx), xa("cy", cy)], [])),
  ])

  let blip_fill = pe("blipFill", [], [
    Element(blip),
    Element(ae("stretch", [], [Element(ae("fillRect", [], []))])),
  ])
  let nv_pic_pr = pe("nvPicPr", [], [
    Element(
      pe("cNvPr", [xa("id", "2"), xa("name", "BlipEffectPic")], []),
    ),
    Element(
      pe("cNvPicPr", [], [
        Element(ae("picLocks", [xa("noChangeAspect", "1")], [])),
      ]),
    ),
    Element(pe("nvPr", [], [])),
  ])
  let sp_pr = pe("spPr", [], [
    Element(xfrm),
    Element(
      ae("prstGeom", [xa("prst", "rect")], [
        Element(ae("avLst", [], [])),
      ]),
    ),
  ])
  pe("pic", [], [
    Element(nv_pic_pr),
    Element(blip_fill),
    Element(sp_pr),
  ])
}

///|
/// `sp_tree` variant that uses `p:` prefix on all PML elements so
/// PowerPoint accepts the file (PowerPoint rejects default-namespace
/// PML elements).
fn sp_tree_p(shapes : Array[@xml.Element]) -> @xml.Element {
  fn pe(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("p", NS_PML, name, attrs, kids)
  }

  fn ae(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("a", NS_A, name, attrs, kids)
  }

  let grp_xfrm = ae("xfrm", [], [
    Element(ae("off", [xa("x", "0"), xa("y", "0")], [])),
    Element(ae("ext", [xa("cx", "0"), xa("cy", "0")], [])),
    Element(ae("chOff", [xa("x", "0"), xa("y", "0")], [])),
    Element(ae("chExt", [xa("cx", "0"), xa("cy", "0")], [])),
  ])
  let kids : Array[@xml.Node] = [
    Element(
      pe("nvGrpSpPr", [], [
        Element(pe("cNvPr", [xa("id", "1"), xa("name", "")], [])),
        Element(pe("cNvGrpSpPr", [], [])),
        Element(pe("nvPr", [], [])),
      ]),
    ),
    Element(pe("grpSpPr", [], [Element(grp_xfrm)])),
  ]
  for s in shapes {
    kids.push(Element(s))
  }
  let clr_map_ovr = pe("clrMapOvr", [], [
    Element(ae("masterClrMapping", [], [])),
  ])
  pe("cSld", [], [Element(pe("spTree", [], kids)), Element(clr_map_ovr)])
}

///|
fn extras_pml_blip_effects(cases : Array[ImageSlideCase]) -> Unit {
  let img = test_image_4x4_red()
  let pos = ("914400", "914400", "4572000", "4572000")
  // §20.1.8.34 grayscl — greyscale conversion.
  cases.push({
    id: "blip-fx-grayscl",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "grayscl", [], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: img,
  })
  // §20.1.8.6 alphaModFix — 50 % opacity.
  cases.push({
    id: "blip-fx-alphaModFix-50",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "alphaModFix", [xa("amt", "50000")], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: img,
  })
  // §20.1.8.42 lum — brightness +20 %, contrast +50 %.
  cases.push({
    id: "blip-fx-lum-bright-contrast",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xe(
            NS_A,
            "lum",
            [xa("bright", "20000"), xa("contrast", "50000")],
            [],
          ),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: img,
  })
  // §20.1.8.11 biLevel — black/white threshold at 50 %.
  cases.push({
    id: "blip-fx-biLevel-50",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "biLevel", [xa("thresh", "50000")], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: img,
  })
  // Chain: grayscl + alphaModFix 70 %.
  cases.push({
    id: "blip-fx-chain-grayscl-alpha",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xep("a", NS_A, "grayscl", [], []),
          xep("a", NS_A, "alphaModFix", [xa("amt", "70000")], []),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: img,
  })
  // §20.1.8.23 duotone — black-to-blue.
  cases.push({
    id: "blip-fx-duotone-black-blue",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xep("a", NS_A, "duotone", [], [
            Element(xep("a", NS_A, "srgbClr", [xa("val", "000000")], [])),
            Element(xep("a", NS_A, "srgbClr", [xa("val", "0000FF")], [])),
          ]),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: img,
  })
  // --- Multi-colour image fixtures (8×8 quad) ---
  let quad = test_image_8x8_quad()
  // §20.1.8.34 grayscl on multi-colour.
  cases.push({
    id: "blip-fx-grayscl-quad",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic([xep("a", NS_A, "grayscl", [], [])], pos.0, pos.1, pos.2, pos.3),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.8 alphaRepl — replace alpha with 30 %.
  cases.push({
    id: "blip-fx-alphaRepl-30",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "alphaRepl", [xa("a", "30000")], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.15 blur — radius 2 px (19050 EMU).
  cases.push({
    id: "blip-fx-blur-2px",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "blur", [xa("rad", "19050")], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.1 alphaBiLevel — threshold at 50 %.
  cases.push({
    id: "blip-fx-alphaBiLevel-50",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "alphaBiLevel", [xa("thresh", "50000")], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.60 tint — hue 90°, amt 50 %.
  cases.push({
    id: "blip-fx-tint-90-50",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xe(
            NS_A,
            "tint",
            [xa("hue", "5400000"), xa("amt", "50000")],
            [],
          ),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.39 hsl — hue +180°, sat +50 %.
  cases.push({
    id: "blip-fx-hsl-hue180-sat50",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xe(
            NS_A,
            "hsl",
            [xa("hue", "10800000"), xa("sat", "50000"), xa("lum", "0")],
            [],
          ),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.3 alphaFloor.
  cases.push({
    id: "blip-fx-alphaFloor",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "alphaFloor", [], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.2 alphaCeiling.
  cases.push({
    id: "blip-fx-alphaCeiling",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "alphaCeiling", [], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.4 alphaInv.
  cases.push({
    id: "blip-fx-alphaInv",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "alphaInv", [], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.18 clrRepl — replace all colours with green.
  cases.push({
    id: "blip-fx-clrRepl-green",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xep("a", NS_A, "clrRepl", [], [
            Element(xep("a", NS_A, "srgbClr", [xa("val", "00FF00")], [])),
          ]),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.29 fillOverlay — multiply blend with blue.
  cases.push({
    id: "blip-fx-fillOverlay-mult-blue",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xep("a", NS_A, "fillOverlay", [xa("blend", "mult")], [
            Element(
              xep("a", NS_A, "solidFill", [], [
                Element(xep("a", NS_A, "srgbClr", [xa("val", "0000FF")], [])),
              ]),
            ),
          ]),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.42 lum on multi-colour — brightness +30 %.
  cases.push({
    id: "blip-fx-lum-bright30-quad",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [xep("a", NS_A, "lum", [xa("bright", "30000"), xa("contrast", "0")], [])],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.23 duotone on multi-colour — sepia tone (dark brown → cream).
  cases.push({
    id: "blip-fx-duotone-sepia-quad",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xep("a", NS_A, "duotone", [], [
            Element(xep("a", NS_A, "srgbClr", [xa("val", "3B2507")], [])),
            Element(xep("a", NS_A, "srgbClr", [xa("val", "F5E6C8")], [])),
          ]),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.5 alphaMod — container with single alphaModFix 60 %.
  cases.push({
    id: "blip-fx-alphaMod-60",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xep("a", NS_A, "alphaMod", [], [
            Element(
              xep("a", NS_A, "cont", [], [
                Element(
                  xep("a", NS_A, "alphaModFix", [xa("amt", "60000")], []),
                ),
              ]),
            ),
          ]),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
  // §20.1.8.16 clrChange — red → green colour swap.
  cases.push({
    id: "blip-fx-clrChange-red-green",
    format: "pptx",
    category: "pic",
    content: sp_tree_p([
      blip_pic(
        [
          xep("a", NS_A, "clrChange", [], [
            Element(
              xep("a", NS_A, "clrFrom", [], [
                Element(xep("a", NS_A, "srgbClr", [xa("val", "FF0000")], [])),
              ]),
            ),
            Element(
              xep("a", NS_A, "clrTo", [], [
                Element(xep("a", NS_A, "srgbClr", [xa("val", "00FF00")], [])),
              ]),
            ),
          ]),
        ],
        pos.0,
        pos.1,
        pos.2,
        pos.3,
      ),
    ]),
    image_bytes: quad,
  })
}
