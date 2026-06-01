// PresentationML advanced visual-fixture set — focuses on uncovered
// ECMA-376 §19/§20 features that have a *rendered* visual effect on
// the slide: slide background (`<p:cSld><p:bg>`), large multi-shape
// arrangements (grids, meshes, radial layouts), text body variations
// inside shapes, scale extremes, outline-only styling variations,
// connector chains, and effect-list / extension placeholders.
//
// Conventions:
//   • Slide canvas is 9144000 × 6858000 EMU (10in × 7.5in).
//   • Every shape inside a slide gets a unique integer `id_`
//     starting at "2" (id "1" is reserved for the group at the
//     `<p:spTree>` root).
//   • Uses top-level helpers from `fixtures_helpers.mbt`:
//     `pptx_shape`, `pptx_shape_outline`, `sp_tree`, `sp_xfrm`,
//     `solid_fill`, `xe`, `xa`.  Anything fancier (gradient fills,
//     effect lists, text bodies inside shapes, bg-pr containers) is
//     built inline so this file is self-contained and does NOT
//     touch the canonical helpers in `fixtures_pml_extra.mbt` /
//     `fixtures_pml_shape.mbt` / `fixtures_pml_text.mbt`.

///|
/// Build a `<p:cSld>` whose first child is a `<p:bg>` (background)
/// element and second child is the standard `<p:spTree>` carrying
/// `shapes`. The shape-tree skeleton itself is shared with the
/// catalog package host helpers; only the ECMA-376 §19.3.1.41
/// background-before-spTree ordering is local to this fixture family.
fn pml_adv_cSld_with_bg(
  bg : @xml.Element,
  shapes : Array[@xml.Element],
) -> @xml.Element {
  pptx_common_slide_data_with_children(NS_PML, [bg], shapes, [])
}

///|
/// `<p:bg><p:bgPr><a:solidFill .../></p:bgPr></p:bg>` — solid hex
/// background colour for a slide.  `<p:bgPr>` requires a child
/// `<a:effectLst/>` per ECMA-376 §19.3.1.2, otherwise conformant
/// readers silently drop the background; we include the empty
/// element.
fn pml_adv_bg_solid(hex : String) -> @xml.Element {
  xe(NS_PML, "bg", [], [
    Element(
      xe(NS_PML, "bgPr", [], [
        Element(solid_fill(hex)),
        Element(xe(NS_A, "effectLst", [], [])),
      ]),
    ),
  ])
}

///|
/// `<p:bg><p:bgPr><a:gradFill .../></p:bgPr></p:bg>` — top-to-bottom
/// linear gradient between `hex1` (0%) and `hex2` (100%) at 90° (line
/// angle is in 60000ths of a degree, so 5400000 = 90°).
fn pml_adv_bg_gradient(hex1 : String, hex2 : String) -> @xml.Element {
  let stop0 = xe(NS_A, "gs", [xa("pos", "0")], [
    Element(xe(NS_A, "srgbClr", [xa("val", hex1)], [])),
  ])
  let stop100 = xe(NS_A, "gs", [xa("pos", "100000")], [
    Element(xe(NS_A, "srgbClr", [xa("val", hex2)], [])),
  ])
  let grad = xe(
    NS_A,
    "gradFill",
    [xa("flip", "none"), xa("rotWithShape", "1")],
    [
      Element(xe(NS_A, "gsLst", [], [Element(stop0), Element(stop100)])),
      Element(xe(NS_A, "lin", [xa("ang", "5400000"), xa("scaled", "0")], [])),
    ],
  )
  xe(NS_PML, "bg", [], [
    Element(
      xe(NS_PML, "bgPr", [], [
        Element(grad),
        Element(xe(NS_A, "effectLst", [], [])),
      ]),
    ),
  ])
}

///|
/// `<p:sp>` with preset geometry, solid fill, and a `<p:txBody>`
/// containing one centred paragraph using the supplied rPr attributes
/// (e.g. `b="1"`, `sz="3200"`, `<a:solidFill>` colour child).  The
/// shape outline is omitted (callers add their own if needed).  The
/// fill colour and text colour are independent.
fn pml_adv_shape_with_text(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill_hex : String,
  text : String,
  rpr_attrs : Array[@xml.Attribute],
  rpr_children : Array[@xml.Element],
  body_pr_attrs : Array[@xml.Attribute],
) -> @xml.Element {
  let rpr_kids : Array[@xml.Node] = []
  for c in rpr_children {
    rpr_kids.push(Element(c))
  }
  let rpr = xe(NS_A, "rPr", rpr_attrs, rpr_kids)
  let a_t = xe(NS_A, "t", [], [Text(text)])
  let a_r = xe(NS_A, "r", [], [Element(rpr), Element(a_t)])
  let ppr = xe(NS_A, "pPr", [xa("algn", "ctr")], [])
  let a_p = xe(NS_A, "p", [], [Element(ppr), Element(a_r)])
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(
          xe(NS_PML, "cNvSpPr", [], [
            Element(xe(NS_A, "spLocks", [xa("noGrp", "1")], [])),
          ]),
        ),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm(x, y, cx, cy)),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", prst)], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill(fill_hex)),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", body_pr_attrs, [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(a_p),
      ]),
    ),
  ])
}

///|
/// `<p:sp>` with multiple paragraphs of text inside a filled shape.
/// Each entry in `paras` is `(text, rpr_attrs)`.
fn pml_adv_shape_with_paras(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill_hex : String,
  paras : Array[(String, Array[@xml.Attribute])],
  body_pr_attrs : Array[@xml.Attribute],
) -> @xml.Element {
  let body_kids : Array[@xml.Node] = [
    Element(xe(NS_A, "bodyPr", body_pr_attrs, [])),
    Element(xe(NS_A, "lstStyle", [], [])),
  ]
  for entry in paras {
    let (text, rpr_attrs) = entry
    let rpr = xe(NS_A, "rPr", rpr_attrs, [])
    let a_t = xe(NS_A, "t", [], [Text(text)])
    let a_r = xe(NS_A, "r", [], [Element(rpr), Element(a_t)])
    let ppr = xe(NS_A, "pPr", [xa("algn", "ctr")], [])
    let a_p = xe(NS_A, "p", [], [Element(ppr), Element(a_r)])
    body_kids.push(Element(a_p))
  }
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(
          xe(NS_PML, "cNvSpPr", [], [
            Element(xe(NS_A, "spLocks", [xa("noGrp", "1")], [])),
          ]),
        ),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm(x, y, cx, cy)),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", prst)], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill(fill_hex)),
      ]),
    ),
    Element(xe(NS_PML, "txBody", [], body_kids)),
  ])
}

///|
/// `<p:sp>` with preset geometry, solid fill, and a custom outline of
/// arbitrary width / line attributes plus children (line ends, joins).
fn pml_adv_shape_ln(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill_hex : String,
  ln_attrs : Array[@xml.Attribute],
  ln_children : Array[@xml.Element],
) -> @xml.Element {
  let ln_kids : Array[@xml.Node] = []
  for c in ln_children {
    ln_kids.push(Element(c))
  }
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm(x, y, cx, cy)),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", prst)], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill(fill_hex)),
        Element(xe(NS_A, "ln", ln_attrs, ln_kids)),
      ]),
    ),
  ])
}

///|
/// `<p:sp>` solid-filled, with arbitrary additional child elements
/// appended at the end of `<p:spPr>` — used for fixtures that need
/// `<a:effectLst/>`, `<a:extLst/>`, or other §20 sibling elements.
fn pml_adv_shape_with_extras(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill_hex : String,
  extras : Array[@xml.Element],
) -> @xml.Element {
  let spPr_kids : Array[@xml.Node] = [
    Element(sp_xfrm(x, y, cx, cy)),
    Element(
      xe(NS_A, "prstGeom", [xa("prst", prst)], [
        Element(xe(NS_A, "avLst", [], [])),
      ]),
    ),
    Element(solid_fill(fill_hex)),
  ]
  for e in extras {
    spPr_kids.push(Element(e))
  }
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(xe(NS_PML, "spPr", [], spPr_kids)),
  ])
}

///|
/// `<p:sp>` with rotation `<a:xfrm rot=...>` and a centred text body.
/// `rot` is in 60000ths of a degree (e.g. 1800000 = 30°).
fn pml_adv_shape_rotated_text(
  id_ : String,
  name : String,
  prst : String,
  rot : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill_hex : String,
  text : String,
) -> @xml.Element {
  let xfrm = xe(NS_A, "xfrm", [xa("rot", rot)], [
    Element(xe(NS_A, "off", [xa("x", x), xa("y", y)], [])),
    Element(xe(NS_A, "ext", [xa("cx", cx), xa("cy", cy)], [])),
  ])
  let rpr = xe(NS_A, "rPr", [xa("lang", "en-US"), xa("sz", "2400")], [])
  let a_t = xe(NS_A, "t", [], [Text(text)])
  let a_r = xe(NS_A, "r", [], [Element(rpr), Element(a_t)])
  let ppr = xe(NS_A, "pPr", [xa("algn", "ctr")], [])
  let a_p = xe(NS_A, "p", [], [Element(ppr), Element(a_r)])
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(
          xe(NS_PML, "cNvSpPr", [], [
            Element(xe(NS_A, "spLocks", [xa("noGrp", "1")], [])),
          ]),
        ),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(xfrm),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", prst)], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill(fill_hex)),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(
          xe(NS_A, "bodyPr", [xa("wrap", "square"), xa("anchor", "ctr")], []),
        ),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(a_p),
      ]),
    ),
  ])
}

///|
/// Straight-arrow connector for chain / mesh fixtures.  The transform
/// goes from (x,y) to (x+cx,y+cy); `flipH` / `flipV` reverse axes.
fn pml_adv_arrow(
  id_ : String,
  name : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  flip_h : Bool,
  flip_v : Bool,
  hex : String,
) -> @xml.Element {
  let xfrm_attrs : Array[@xml.Attribute] = []
  if flip_h {
    xfrm_attrs.push(xa("flipH", "1"))
  }
  if flip_v {
    xfrm_attrs.push(xa("flipV", "1"))
  }
  let xfrm = xe(NS_A, "xfrm", xfrm_attrs, [
    Element(xe(NS_A, "off", [xa("x", x), xa("y", y)], [])),
    Element(xe(NS_A, "ext", [xa("cx", cx), xa("cy", cy)], [])),
  ])
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(xfrm),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "straightConnector1")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(xe(NS_A, "noFill", [], [])),
        Element(
          xe(NS_A, "ln", [xa("w", "19050")], [
            Element(solid_fill(hex)),
            Element(xe(NS_A, "tailEnd", [xa("type", "triangle")], [])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
/// Translucent solid fill helper: returns a `<a:solidFill>` wrapping
/// `<a:srgbClr>` with an inner `<a:alpha val=.../>` modifier (val is
/// in 1000ths of a percent, so 50000 = 50%).
fn pml_adv_alpha_shape(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  hex : String,
  alpha_100000 : String,
) -> @xml.Element {
  let fill = xe(NS_A, "solidFill", [], [
    Element(
      xe(NS_A, "srgbClr", [xa("val", hex)], [
        Element(xe(NS_A, "alpha", [xa("val", alpha_100000)], [])),
      ]),
    ),
  ])
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm(x, y, cx, cy)),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", prst)], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(fill),
      ]),
    ),
  ])
}

///|
fn extras_pml_advanced(cases : Array[VisualCase]) -> Unit {
  // ====== Slide background fixtures =================================

  // ---- bg-solid-fill ---------------------------------------------
  // `<p:cSld><p:bg><p:bgPr><a:solidFill>` — light-blue slide
  // background colour with no foreground shapes.  Tests that the
  // background descriptor reaches the renderer.
  cases.push({
    id: "bg-solid-fill",
    format: "pptx",
    category: "background",
    content: pml_adv_cSld_with_bg(pml_adv_bg_solid("DEEBF7"), []),
  })

  // ---- bg-gradient -----------------------------------------------
  // Linear top-to-bottom gradient from deep-blue to light-blue,
  // exercising `<a:gradFill>` inside `<p:bgPr>`.
  cases.push({
    id: "bg-gradient",
    format: "pptx",
    category: "background",
    content: pml_adv_cSld_with_bg(pml_adv_bg_gradient("1F3864", "BDD7EE"), []),
  })

  // ---- bg-with-shape ---------------------------------------------
  // Solid background + a single centred foreground rectangle in a
  // contrasting colour.  Verifies background-then-foreground paint
  // order.
  cases.push({
    id: "bg-with-shape",
    format: "pptx",
    category: "background",
    content: pml_adv_cSld_with_bg(pml_adv_bg_solid("1F3864"), [
      pptx_shape(
        "2", "FG", "rect", "2286000", "1828800", "4572000", "3200400", "FFC000",
      ),
    ]),
  })

  // ====== Multi-shape arrangements ==================================

  // ---- pml-grid-5x4 ----------------------------------------------
  // 20 small filled rectangles in a 5-column × 4-row grid.  Verifies
  // uniform-spacing layout math at moderate density.
  let g54_shapes : Array[@xml.Element] = []
  let g54_cell = 1371600
  let g54_gap = 152400
  let mut g54_id = 2
  for r in 0..<4 {
    for c in 0..<5 {
      let x = (457200 + c * (g54_cell + g54_gap)).to_string()
      let y = (457200 + r * (g54_cell + g54_gap)).to_string()
      let hex = match (r + c) % 3 {
        0 => "4472C4"
        1 => "ED7D31"
        _ => "70AD47"
      }
      g54_shapes.push(
        pptx_shape(
          g54_id.to_string(),
          "G" + g54_id.to_string(),
          "rect",
          x,
          y,
          g54_cell.to_string(),
          g54_cell.to_string(),
          hex,
        ),
      )
      g54_id = g54_id + 1
    }
  }
  cases.push({
    id: "pml-grid-5x4",
    format: "pptx",
    category: "shape",
    content: sp_tree(g54_shapes),
  })

  // ---- pml-overlapping-circles -----------------------------------
  // Five large translucent circles laid out so each pair overlaps,
  // testing alpha compositing across 5 shapes (deeper stack than
  // existing venn fixture).
  cases.push({
    id: "pml-overlapping-circles",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_alpha_shape(
        "2", "OC1", "ellipse", "1371600", "1371600", "3200400", "3200400", "4472C4",
        "50000",
      ),
      pml_adv_alpha_shape(
        "3", "OC2", "ellipse", "3429000", "1371600", "3200400", "3200400", "ED7D31",
        "50000",
      ),
      pml_adv_alpha_shape(
        "4", "OC3", "ellipse", "5486400", "1371600", "3200400", "3200400", "70AD47",
        "50000",
      ),
      pml_adv_alpha_shape(
        "5", "OC4", "ellipse", "2400300", "2971800", "3200400", "3200400", "FFC000",
        "50000",
      ),
      pml_adv_alpha_shape(
        "6", "OC5", "ellipse", "4457700", "2971800", "3200400", "3200400", "C00000",
        "50000",
      ),
    ]),
  })

  // ---- pml-flowchart-pipeline ------------------------------------
  // Five filled boxes in a horizontal row, joined by four straight
  // arrows.  Wider pipeline than existing 3-step flowchart.
  cases.push({
    id: "pml-flowchart-pipeline",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "S1", "flowChartTerminator", "228600", "2971800", "1371600", "914400",
        "DEEBF7",
      ),
      pml_adv_arrow(
        "3", "A1", "1600200", "3429000", "457200", "1", false, false, "404040",
      ),
      pptx_shape(
        "4", "S2", "flowChartProcess", "2057400", "2971800", "1371600", "914400",
        "FFF2CC",
      ),
      pml_adv_arrow(
        "5", "A2", "3429000", "3429000", "457200", "1", false, false, "404040",
      ),
      pptx_shape(
        "6", "S3", "flowChartProcess", "3886200", "2971800", "1371600", "914400",
        "FCE4D6",
      ),
      pml_adv_arrow(
        "7", "A3", "5257800", "3429000", "457200", "1", false, false, "404040",
      ),
      pptx_shape(
        "8", "S4", "flowChartDecision", "5715000", "2743200", "1371600", "1371600",
        "FBE5D6",
      ),
      pml_adv_arrow(
        "9", "A4", "7086600", "3429000", "457200", "1", false, false, "404040",
      ),
      pptx_shape(
        "10", "S5", "flowChartTerminator", "7543800", "2971800", "1371600", "914400",
        "E2EFDA",
      ),
    ]),
  })

  // ---- pml-tile-50 -----------------------------------------------
  // 50 small rectangles tiling most of the slide, 10×5 grid.  Stress
  // test for many-shapes-per-slide rendering throughput.
  let t50_shapes : Array[@xml.Element] = []
  let t50_cell = 762000
  let t50_gap = 76200
  let mut t50_id = 2
  for r in 0..<5 {
    for c in 0..<10 {
      let x = (457200 + c * (t50_cell + t50_gap)).to_string()
      let y = (914400 + r * (t50_cell + t50_gap)).to_string()
      let parity = (r + c) % 2
      let hex = if parity == 0 { "5B9BD5" } else { "FFFFFF" }
      t50_shapes.push(
        pptx_shape(
          t50_id.to_string(),
          "T" + t50_id.to_string(),
          "rect",
          x,
          y,
          t50_cell.to_string(),
          t50_cell.to_string(),
          hex,
        ),
      )
      t50_id = t50_id + 1
    }
  }
  cases.push({
    id: "pml-tile-50",
    format: "pptx",
    category: "shape",
    content: sp_tree(t50_shapes),
  })

  // ====== Text inside shapes ========================================

  // ---- pml-shape-text-bold-large ---------------------------------
  // Single shape with bold 32pt centred text inside it.  Tests the
  // shape→txBody pipeline for large bold glyph rendering.
  cases.push({
    id: "pml-shape-text-bold-large",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_with_text(
        "2",
        "BoldLarge",
        "rect",
        "1828800",
        "2286000",
        "5486400",
        "2286000",
        "DEEBF7",
        "Bold 32pt Text",
        [xa("lang", "en-US"), xa("sz", "3200"), xa("b", "1")],
        [],
        [xa("wrap", "square"), xa("anchor", "ctr")],
      ),
    ]),
  })

  // ---- pml-shape-text-multipara ----------------------------------
  // Shape with three paragraphs of distinct text.  Tests vertical
  // stacking of `<a:p>` siblings inside one txBody.
  cases.push({
    id: "pml-shape-text-multipara",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_with_paras(
        "2",
        "Multi",
        "rect",
        "1371600",
        "1371600",
        "6400800",
        "4114800",
        "FFF2CC",
        [
          (
            "First paragraph of body text.",
            [xa("lang", "en-US"), xa("sz", "2400")],
          ),
          (
            "Second paragraph follows here.",
            [xa("lang", "en-US"), xa("sz", "2400"), xa("b", "1")],
          ),
          (
            "Third and last paragraph.",
            [xa("lang", "en-US"), xa("sz", "2400"), xa("i", "1")],
          ),
        ],
        [xa("wrap", "square"), xa("anchor", "t")],
      ),
    ]),
  })

  // ---- pml-shape-text-wrap ---------------------------------------
  // Shape with long English text that must wrap to fit.  Exercises
  // the text-wrapping logic inside a narrow box.
  cases.push({
    id: "pml-shape-text-wrap",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_with_text(
        "2",
        "Wrap",
        "rect",
        "2286000",
        "1828800",
        "4572000",
        "3200400",
        "E2EFDA",
        "This is a long sentence written specifically to force the " +
        "text layout engine to wrap across multiple lines inside a " +
        "constrained shape extent so wrap behaviour can be inspected.",
        [xa("lang", "en-US"), xa("sz", "2000")],
        [],
        [xa("wrap", "square"), xa("anchor", "t")],
      ),
    ]),
  })

  // ---- pml-shape-text-color --------------------------------------
  // Shape with white text on a dark navy fill — exercises explicit
  // run-fill colour against a contrasting shape fill.
  cases.push({
    id: "pml-shape-text-color",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_with_text(
        "2",
        "ColorText",
        "rect",
        "1828800",
        "2286000",
        "5486400",
        "2286000",
        "1F3864",
        "White text on dark fill",
        [xa("lang", "en-US"), xa("sz", "2800"), xa("b", "1")],
        [solid_fill("FFFFFF")],
        [xa("wrap", "square"), xa("anchor", "ctr")],
      ),
    ]),
  })

  // ---- pml-shape-text-rotated ------------------------------------
  // Whole-shape rotation of 30° with centred text inside; tests the
  // `<a:xfrm rot=...>` pipeline.
  cases.push({
    id: "pml-shape-text-rotated",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_rotated_text(
        "2", "Rot30", "rect", "1800000", "2743200", "2286000", "3657600", "2286000",
        "FFC000", "Rotated 30 deg",
      ),
    ]),
  })

  // ====== DrawingML scale variations ================================

  // ---- pml-shape-tiny --------------------------------------------
  // 100 000 × 100 000 EMU shape (~0.1 in) centred — verifies the
  // renderer does not collapse very small shapes to zero pixels at
  // 96 dpi.
  cases.push({
    id: "pml-shape-tiny",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Tiny", "rect", "4522000", "3379000", "100000", "100000", "C00000",
      ),
    ]),
  })

  // ---- pml-shape-huge --------------------------------------------
  // Single rectangle filling the entire slide canvas exactly.  Tests
  // clipping and full-extent geometry math at slide bounds.
  cases.push({
    id: "pml-shape-huge",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape("2", "Huge", "rect", "0", "0", "9144000", "6858000", "5B9BD5"),
    ]),
  })

  // ---- pml-shape-aspectratio-1to10 -------------------------------
  // Thin tall rectangle (300 000 × 3 000 000 EMU) centred.  Tests
  // extreme aspect ratio without overflow.
  cases.push({
    id: "pml-shape-aspectratio-1to10",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Tall", "rect", "4422000", "1929000", "300000", "3000000", "ED7D31",
      ),
    ]),
  })

  // ---- pml-shape-aspectratio-10to1 -------------------------------
  // Thin wide rectangle — converse of the previous fixture.
  cases.push({
    id: "pml-shape-aspectratio-10to1",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Wide", "rect", "1572000", "3279000", "6000000", "300000", "70AD47",
      ),
    ]),
  })

  // ====== Outline variations ========================================

  // ---- pml-shape-outline-thick -----------------------------------
  // Rectangle filled white with an unusually thick outline (76200
  // EMU = ~6 pt).  Verifies the renderer respects large line widths.
  cases.push({
    id: "pml-shape-outline-thick",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_ln(
        "2",
        "ThickLn",
        "rect",
        "1828800",
        "1828800",
        "5486400",
        "3200400",
        "FFFFFF",
        [xa("w", "76200")],
        [solid_fill("1F3864")],
      ),
    ]),
  })

  // ---- pml-shape-outline-multi-color -----------------------------
  // Five rectangles laid out horizontally, each with progressively
  // darker outline colour.  Verifies per-shape outline colour
  // distinction.
  cases.push({
    id: "pml-shape-outline-multi-color",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_ln(
        "2",
        "O1",
        "rect",
        "457200",
        "2743200",
        "1371600",
        "1371600",
        "FFFFFF",
        [xa("w", "38100")],
        [solid_fill("BDD7EE")],
      ),
      pml_adv_shape_ln(
        "3",
        "O2",
        "rect",
        "2057400",
        "2743200",
        "1371600",
        "1371600",
        "FFFFFF",
        [xa("w", "38100")],
        [solid_fill("9DC3E6")],
      ),
      pml_adv_shape_ln(
        "4",
        "O3",
        "rect",
        "3657600",
        "2743200",
        "1371600",
        "1371600",
        "FFFFFF",
        [xa("w", "38100")],
        [solid_fill("5B9BD5")],
      ),
      pml_adv_shape_ln(
        "5",
        "O4",
        "rect",
        "5257800",
        "2743200",
        "1371600",
        "1371600",
        "FFFFFF",
        [xa("w", "38100")],
        [solid_fill("2E75B6")],
      ),
      pml_adv_shape_ln(
        "6",
        "O5",
        "rect",
        "6858000",
        "2743200",
        "1371600",
        "1371600",
        "FFFFFF",
        [xa("w", "38100")],
        [solid_fill("1F4E79")],
      ),
    ]),
  })

  // ---- pml-shape-outline-rounded-join ----------------------------
  // Rectangle with a thick outline using rounded line caps and a
  // mitered join with explicit miter limit.  Tests `<a:ln cap="rnd">`
  // plus `<a:miter lim=...>`.
  cases.push({
    id: "pml-shape-outline-rounded-join",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_ln(
        "2",
        "RoundJ",
        "rect",
        "1828800",
        "1828800",
        "5486400",
        "3200400",
        "FFF2CC",
        [xa("w", "76200"), xa("cap", "rnd")],
        [solid_fill("BF8F00"), xe(NS_A, "miter", [xa("lim", "200000")], [])],
      ),
    ]),
  })

  // ====== Connector chains ==========================================

  // ---- pml-connector-tree ----------------------------------------
  // One root rectangle with three downward-fanning child rectangles
  // joined by bentConnector3 connectors.  Tests the bent-connector
  // preset geometry in a tree layout.
  cases.push({
    id: "pml-connector-tree",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      // Root (top centre).
      pptx_shape(
        "2", "Root", "rect", "3886200", "457200", "1371600", "685800", "1F4E79",
      ),
      // Children.
      pptx_shape(
        "3", "C1", "rect", "914400", "3886200", "1371600", "685800", "2E75B6",
      ),
      pptx_shape(
        "4", "C2", "rect", "3886200", "3886200", "1371600", "685800", "2E75B6",
      ),
      pptx_shape(
        "5", "C3", "rect", "6858000", "3886200", "1371600", "685800", "2E75B6",
      ),
      // bentConnector3 root → C1 (left-going).
      pptx_shape_outline(
        "6", "BC1", "bentConnector3", "1600200", "1143000", "2971800", "2743200",
        "404040",
      ),
      // Straight middle.
      pptx_shape_outline(
        "7", "BC2", "straightConnector1", "4572000", "1143000", "1", "2743200", "404040",
      ),
      // bentConnector3 root → C3 (right-going).
      pptx_shape_outline(
        "8", "BC3", "bentConnector3", "4572000", "1143000", "2971800", "2743200",
        "404040",
      ),
    ]),
  })

  // ---- pml-connector-mesh ----------------------------------------
  // Four corner nodes fully connected: 4 nodes → 6 connectors.
  // Verifies dense connector graph rendering.
  cases.push({
    id: "pml-connector-mesh",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      // Corner nodes.
      pptx_shape(
        "2", "N1", "ellipse", "457200", "457200", "914400", "914400", "4472C4",
      ),
      pptx_shape(
        "3", "N2", "ellipse", "7772400", "457200", "914400", "914400", "ED7D31",
      ),
      pptx_shape(
        "4", "N3", "ellipse", "457200", "5486400", "914400", "914400", "70AD47",
      ),
      pptx_shape(
        "5", "N4", "ellipse", "7772400", "5486400", "914400", "914400", "FFC000",
      ),
      // 6 edges: N1-N2, N1-N3, N1-N4, N2-N3, N2-N4, N3-N4.
      pml_adv_arrow(
        "6", "E12", "1371600", "914400", "6400800", "1", false, false, "404040",
      ),
      pml_adv_arrow(
        "7", "E13", "914400", "1371600", "1", "4114800", false, false, "404040",
      ),
      pml_adv_arrow(
        "8", "E14", "1371600", "1371600", "6400800", "4114800", false, false, "404040",
      ),
      pml_adv_arrow(
        "9", "E23", "1371600", "1371600", "6400800", "4114800", true, false, "404040",
      ),
      pml_adv_arrow(
        "10", "E24", "8229600", "1371600", "1", "4114800", false, false, "404040",
      ),
      pml_adv_arrow(
        "11", "E34", "1371600", "5943600", "6400800", "1", false, false, "404040",
      ),
    ]),
  })

  // ====== Shape attribute placeholders ==============================

  // ---- pml-shape-with-effectlst-empty ----------------------------
  // Solid rectangle with an empty `<a:effectLst/>` child after the
  // fill — exercises the no-op-effect code path; renderer must NOT
  // crash and the visible output should match a plain shape.
  cases.push({
    id: "pml-shape-with-effectlst-empty",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_with_extras(
        "2",
        "Eff0",
        "rect",
        "1828800",
        "1828800",
        "5486400",
        "3200400",
        "DEEBF7",
        [xe(NS_A, "effectLst", [], [])],
      ),
    ]),
  })

  // ---- pml-shape-with-extlst-empty -------------------------------
  // Solid rectangle with an empty `<a:extLst/>` extension list at
  // the end of spPr.  Tests the renderer ignores unknown-extension
  // placeholders cleanly.
  cases.push({
    id: "pml-shape-with-extlst-empty",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_adv_shape_with_extras(
        "2",
        "Ext0",
        "rect",
        "1828800",
        "1828800",
        "5486400",
        "3200400",
        "FCE4D6",
        [xe(NS_A, "extLst", [], [])],
      ),
    ]),
  })

  // ---- pml-shape-multi-fill-stack --------------------------------
  // Single rectangle carrying gradient fill (instead of solid) PLUS
  // outline PLUS an outer-shadow effect.  Verifies stacked fill /
  // outline / effect rendering in one shape.
  let stack_grad = xe(NS_A, "gradFill", [xa("rotWithShape", "1")], [
    Element(
      xe(NS_A, "gsLst", [], [
        Element(
          xe(NS_A, "gs", [xa("pos", "0")], [
            Element(xe(NS_A, "srgbClr", [xa("val", "5B9BD5")], [])),
          ]),
        ),
        Element(
          xe(NS_A, "gs", [xa("pos", "100000")], [
            Element(xe(NS_A, "srgbClr", [xa("val", "1F3864")], [])),
          ]),
        ),
      ]),
    ),
    Element(xe(NS_A, "lin", [xa("ang", "5400000"), xa("scaled", "0")], [])),
  ])
  let stack_outline = xe(NS_A, "ln", [xa("w", "38100")], [
    Element(solid_fill("FFC000")),
  ])
  let stack_effect = xe(NS_A, "effectLst", [], [
    Element(
      xe(
        NS_A,
        "outerShdw",
        [
          xa("blurRad", "50800"),
          xa("dist", "38100"),
          xa("dir", "2700000"),
          xa("algn", "tl"),
          xa("rotWithShape", "0"),
        ],
        [
          Element(
            xe(NS_A, "srgbClr", [xa("val", "000000")], [
              Element(xe(NS_A, "alpha", [xa("val", "40000")], [])),
            ]),
          ),
        ],
      ),
    ),
  ])
  let stack_sp = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "MFStack")], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1828800", "5486400", "3200400")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(stack_grad),
        Element(stack_outline),
        Element(stack_effect),
      ]),
    ),
  ])
  cases.push({
    id: "pml-shape-multi-fill-stack",
    format: "pptx",
    category: "shape",
    content: sp_tree([stack_sp]),
  })

  // ====== Misc compositions =========================================

  // ---- pml-3-rows-of-shapes --------------------------------------
  // Three horizontal rows, each containing five rectangles of a
  // distinct fill.  Verifies row-by-row layout uniformity.
  let rows_shapes : Array[@xml.Element] = []
  let rows_cell_w = 1524000
  let rows_cell_h = 1524000
  let rows_gap = 152400
  let mut rows_id = 2
  let row_hexes = ["4472C4", "ED7D31", "70AD47"]
  for r in 0..<3 {
    let hex = row_hexes[r]
    for c in 0..<5 {
      let x = (457200 + c * (rows_cell_w + rows_gap)).to_string()
      let y = (457200 + r * (rows_cell_h + rows_gap)).to_string()
      rows_shapes.push(
        pptx_shape(
          rows_id.to_string(),
          "R" + rows_id.to_string(),
          "rect",
          x,
          y,
          rows_cell_w.to_string(),
          rows_cell_h.to_string(),
          hex,
        ),
      )
      rows_id = rows_id + 1
    }
  }
  cases.push({
    id: "pml-3-rows-of-shapes",
    format: "pptx",
    category: "shape",
    content: sp_tree(rows_shapes),
  })

  // ---- pml-checkerboard-8x6 --------------------------------------
  // 48 small rectangles in an 8-column × 6-row checkerboard, two
  // alternating colours.  Tests dense uniform layouts with binary
  // colour parity.
  let cb_shapes : Array[@xml.Element] = []
  let cb_cell = 990600
  let cb_gap = 25400
  let mut cb_id = 2
  for r in 0..<6 {
    for c in 0..<8 {
      let x = (533400 + c * (cb_cell + cb_gap)).to_string()
      let y = (457200 + r * (cb_cell + cb_gap)).to_string()
      let parity = (r + c) % 2
      let hex = if parity == 0 { "1F3864" } else { "FFFFFF" }
      cb_shapes.push(
        pptx_shape(
          cb_id.to_string(),
          "K" + cb_id.to_string(),
          "rect",
          x,
          y,
          cb_cell.to_string(),
          cb_cell.to_string(),
          hex,
        ),
      )
      cb_id = cb_id + 1
    }
  }
  cases.push({
    id: "pml-checkerboard-8x6",
    format: "pptx",
    category: "shape",
    content: sp_tree(cb_shapes),
  })

  // ---- pml-radial-arrangement ------------------------------------
  // Twelve small ellipses placed at evenly-spaced 30° intervals on a
  // circle around the slide centre.  Cosine/sine offsets are
  // precomputed in EMU; centre = (4572000, 3429000), radius =
  // 2400000.  Complements existing 10-ellipse ring fixture.
  let radial_xy : Array[(Int, Int)] = [
    (2400000, 0), //   0°
    (2078461, 1200000), //  30°
    (1200000, 2078461), //  60°
    (0, 2400000), //  90°
    (-1200000, 2078461), // 120°
    (-2078461, 1200000), // 150°
    (-2400000, 0), // 180°
    (-2078461, -1200000), // 210°
    (-1200000, -2078461), // 240°
    (0, -2400000), // 270°
    (1200000, -2078461), // 300°
    (2078461, -1200000), // 330°
  ]
  let radial_shapes : Array[@xml.Element] = []
  let radial_node_half = 304800
  for i, p in radial_xy {
    let (dx, dy) = p
    let cx_emu = 4572000 + dx - radial_node_half
    let cy_emu = 3429000 + dy - radial_node_half
    let hex = match i % 4 {
      0 => "4472C4"
      1 => "ED7D31"
      2 => "70AD47"
      _ => "FFC000"
    }
    radial_shapes.push(
      pptx_shape(
        (i + 2).to_string(),
        "Rad" + i.to_string(),
        "ellipse",
        cx_emu.to_string(),
        cy_emu.to_string(),
        (radial_node_half * 2).to_string(),
        (radial_node_half * 2).to_string(),
        hex,
      ),
    )
  }
  cases.push({
    id: "pml-radial-arrangement",
    format: "pptx",
    category: "shape",
    content: sp_tree(radial_shapes),
  })
}
