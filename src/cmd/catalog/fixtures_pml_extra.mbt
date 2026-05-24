// PresentationML compositional fixtures — multi-shape slide
// compositions, backgrounds, decorations, layouts.  Each fixture
// arranges several `<p:sp>` elements into a recognisable scene
// (flowchart, venn diagram, org chart, etc.) so the LibreOffice ↔
// catalog renderer comparison can shake out z-order, layout, and
// preset-geometry interaction bugs that single-shape fixtures miss.
//
// Conventions:
//   • Slide canvas is 9144000 × 6858000 EMU (10in × 7.5in).
//   • Every shape inside a slide gets a unique integer `id_`
//     starting at "2" (id "1" is reserved for the group at the
//     `<p:spTree>` root).
//   • Uses top-level helpers from `fixtures_helpers.mbt`:
//     `pptx_shape`, `pptx_shape_outline`, `sp_tree`.  Anything
//     fancier (effects, alpha, line props) is built inline so this
//     file does not depend on the private helpers in
//     `fixtures_pml_shape.mbt`.

///|
/// Build a `<p:sp>` with preset geometry, an externally-built
/// `<a:solidFill>` (e.g. an alpha-modified colour), and no outline.
/// Local copy so this file is self-contained — `fixtures_pml_shape`
/// owns the canonical version under a different name and we must
/// not touch that file.
fn pml_extra_shape_alpha(
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
/// Build a `<p:sp>` with preset geometry, solid fill, AND an explicit
/// outline colour — used for boxes that need a contrasting border
/// (org chart, flowchart, chart-axes look).  Outline width is fixed
/// at 19050 EMU (~1.5 pt).
fn pml_extra_shape_bordered(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill_hex : String,
  stroke_hex : String,
) -> @xml.Element {
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
        Element(
          xe(NS_A, "ln", [xa("w", "19050")], [Element(solid_fill(stroke_hex))]),
        ),
      ]),
    ),
  ])
}

///|
/// Build a straight-connector arrow between two anchor points.  The
/// underlying preset is `straightConnector1`, drawn stroke-only with
/// a triangle tail end; we encode direction by setting `flipH` /
/// `flipV` on the transform — the connector itself runs from the
/// transform's top-left to its bottom-right corner.
fn pml_extra_arrow(
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
          xe(NS_A, "ln", [xa("w", "25400"), xa("cap", "flat")], [
            Element(solid_fill(hex)),
            Element(
              xe(
                NS_A,
                "tailEnd",
                [xa("type", "triangle"), xa("w", "med"), xa("len", "med")],
                [],
              ),
            ),
          ]),
        ),
      ]),
    ),
  ])
}

///|
/// Build a `<p:sp>` text-frame at (x,y) of size (cx,cy) with a
/// single centred paragraph of `text`.  Used by compositional
/// fixtures that need a label or title inside a slide.  Kept local
/// to this file to avoid touching `fixtures_pml_text.mbt`.
fn pml_extra_textbox(
  id_ : String,
  name : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  text : String,
  sz_centipoints : String,
) -> @xml.Element {
  let body_pr = xe(
    NS_A,
    "bodyPr",
    [xa("wrap", "square"), xa("anchor", "ctr")],
    [],
  )
  let rpr = xe(
    NS_A,
    "rPr",
    [xa("lang", "en-US"), xa("sz", sz_centipoints), xa("dirty", "0")],
    [],
  )
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
    Element(xe(NS_PML, "spPr", [], [Element(sp_xfrm(x, y, cx, cy))])),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(body_pr),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(a_p),
      ]),
    ),
  ])
}

///|
fn extras_pml_extra(cases : Array[VisualCase]) -> Unit {
  // ===== Slide compositions =========================================

  // ---- 1. title-slide composition --------------------------------
  // Two large stacked textboxes: a 40pt title centred in the upper
  // half and a 24pt subtitle centred underneath.  Exercises text
  // anchoring + sizing across two `<p:sp>` text frames.
  cases.push({
    id: "shape-comp-title-slide",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_extra_textbox(
        "2", "Title", "914400", "1828800", "7315200", "1371600", "Presentation Title",
        "4000",
      ),
      pml_extra_textbox(
        "3", "Subtitle", "914400", "3429000", "7315200", "914400", "An introductory subtitle",
        "2400",
      ),
    ]),
  })

  // ---- 2. two-column layout --------------------------------------
  // A header band on top, then two equal-width columns of body text.
  // Layered rectangles (filled background bands) with text frames on
  // top exercise z-order resolution.
  cases.push({
    id: "shape-comp-two-column",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "HeaderBand", "rect", "457200", "457200", "8229600", "914400", "1F3864",
      ),
      pml_extra_textbox(
        "3", "HeaderText", "457200", "457200", "8229600", "914400", "Section Header",
        "3200",
      ),
      pml_extra_shape_bordered(
        "4", "LeftCol", "rect", "457200", "1600200", "3886200", "4572000", "DEEBF7",
        "1F3864",
      ),
      pml_extra_textbox(
        "5", "LeftText", "457200", "1600200", "3886200", "4572000", "Left column",
        "2400",
      ),
      pml_extra_shape_bordered(
        "6", "RightCol", "rect", "4800600", "1600200", "3886200", "4572000", "FCE4D6",
        "C65911",
      ),
      pml_extra_textbox(
        "7", "RightText", "4800600", "1600200", "3886200", "4572000", "Right column",
        "2400",
      ),
    ]),
  })

  // ---- 3. four-quadrant comparison layout ------------------------
  // Classic 2×2 comparison grid.  Each quadrant is a tinted rect
  // with a label centred inside.  Distinct hues per quadrant let
  // the renderer's fill-pipeline be verified across 4 colours in
  // one shot.
  cases.push({
    id: "shape-comp-comparison-4quad",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_extra_shape_bordered(
        "2", "Q1", "rect", "457200", "457200", "4114800", "2971800", "FFF2CC", "BF8F00",
      ),
      pml_extra_textbox(
        "3", "Q1Text", "457200", "457200", "4114800", "2971800", "Pros", "2800",
      ),
      pml_extra_shape_bordered(
        "4", "Q2", "rect", "4572000", "457200", "4114800", "2971800", "E2EFDA", "548235",
      ),
      pml_extra_textbox(
        "5", "Q2Text", "4572000", "457200", "4114800", "2971800", "Cons", "2800",
      ),
      pml_extra_shape_bordered(
        "6", "Q3", "rect", "457200", "3429000", "4114800", "2971800", "DEEBF7", "1F4E79",
      ),
      pml_extra_textbox(
        "7", "Q3Text", "457200", "3429000", "4114800", "2971800", "Opportunities",
        "2800",
      ),
      pml_extra_shape_bordered(
        "8", "Q4", "rect", "4572000", "3429000", "4114800", "2971800", "FBE5D6",
        "C65911",
      ),
      pml_extra_textbox(
        "9", "Q4Text", "4572000", "3429000", "4114800", "2971800", "Risks", "2800",
      ),
    ]),
  })

  // ---- 4. flowchart with arrows ----------------------------------
  // Three boxes connected by straight arrows — exercises the
  // straightConnector1 preset plus arrowhead direction in concert
  // with adjacent filled rectangles.
  cases.push({
    id: "shape-comp-flowchart",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_extra_shape_bordered(
        "2", "Step1", "flowChartProcess", "457200", "2743200", "2057400", "1371600",
        "DEEBF7", "1F4E79",
      ),
      pml_extra_textbox(
        "3", "Step1T", "457200", "2743200", "2057400", "1371600", "Input", "2000",
      ),
      pml_extra_arrow(
        "4", "A1", "2514600", "3429000", "1028700", "1", false, false, "404040",
      ),
      pml_extra_shape_bordered(
        "5", "Step2", "flowChartDecision", "3543300", "2514600", "2057400", "1828800",
        "FFF2CC", "BF8F00",
      ),
      pml_extra_textbox(
        "6", "Step2T", "3543300", "2514600", "2057400", "1828800", "Decide", "2000",
      ),
      pml_extra_arrow(
        "7", "A2", "5600700", "3429000", "1028700", "1", false, false, "404040",
      ),
      pml_extra_shape_bordered(
        "8", "Step3", "flowChartTerminator", "6629400", "2743200", "2057400", "1371600",
        "E2EFDA", "548235",
      ),
      pml_extra_textbox(
        "9", "Step3T", "6629400", "2743200", "2057400", "1371600", "Output", "2000",
      ),
    ]),
  })

  // ---- 5. venn diagram with overlapping circles ------------------
  // Three semi-transparent ellipses arranged so each pair overlaps.
  // Alpha compositing in the renderer must produce the canonical
  // 7-region venn picture.
  cases.push({
    id: "shape-comp-venn-diagram",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_extra_shape_alpha(
        "2", "VA", "ellipse", "1371600", "1371600", "3657600", "3657600", "4472C4",
        "50000",
      ),
      pml_extra_shape_alpha(
        "3", "VB", "ellipse", "4114800", "1371600", "3657600", "3657600", "ED7D31",
        "50000",
      ),
      pml_extra_shape_alpha(
        "4", "VC", "ellipse", "2743200", "3200400", "3657600", "3657600", "70AD47",
        "50000",
      ),
    ]),
  })

  // ---- 6. pyramid (stacked trapezoids) ---------------------------
  // Four trapezoids of decreasing width stacked into a pyramid.
  // Exercises the trapezoid preset's vertex layout and verifies the
  // renderer treats successive shapes as ascending z-order.
  cases.push({
    id: "shape-comp-pyramid",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      // Bottom (widest) layer.
      pptx_shape(
        "2", "P1", "trapezoid", "1371600", "5029200", "6400800", "1143000", "1F4E79",
      ),
      pptx_shape(
        "3", "P2", "trapezoid", "2057400", "3886200", "5029200", "1143000", "2E75B6",
      ),
      pptx_shape(
        "4", "P3", "trapezoid", "2743200", "2743200", "3657600", "1143000", "5B9BD5",
      ),
      // Top (narrowest) layer.
      pptx_shape(
        "5", "P4", "trapezoid", "3429000", "1600200", "2286000", "1143000", "9DC3E6",
      ),
    ]),
  })

  // ---- 7. cycle with arrows in a ring ----------------------------
  // Four pill-shaped nodes around the centre of the slide, joined
  // by curved arrows that traverse the circle clockwise.  Tests
  // arrow ends + roundRect preset in a non-trivial arrangement.
  cases.push({
    id: "shape-comp-cycle",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      // Top
      pml_extra_shape_bordered(
        "2", "C1", "roundRect", "3886200", "457200", "1371600", "914400", "DEEBF7",
        "1F4E79",
      ),
      // Right
      pml_extra_shape_bordered(
        "3", "C2", "roundRect", "6629400", "2971800", "1371600", "914400", "E2EFDA",
        "548235",
      ),
      // Bottom
      pml_extra_shape_bordered(
        "4", "C3", "roundRect", "3886200", "5486400", "1371600", "914400", "FFF2CC",
        "BF8F00",
      ),
      // Left
      pml_extra_shape_bordered(
        "5", "C4", "roundRect", "1143000", "2971800", "1371600", "914400", "FBE5D6",
        "C65911",
      ),
      // Arrows around the perimeter (4 segments).
      pml_extra_arrow(
        "6", "Cyc1", "5257800", "1371600", "1371600", "1600200", false, false, "404040",
      ),
      pml_extra_arrow(
        "7", "Cyc2", "5257800", "3886200", "1371600", "1600200", false, true, "404040",
      ),
      pml_extra_arrow(
        "8", "Cyc3", "2514600", "3886200", "1371600", "1600200", true, true, "404040",
      ),
      pml_extra_arrow(
        "9", "Cyc4", "2514600", "1371600", "1371600", "1600200", true, false, "404040",
      ),
    ]),
  })

  // ===== Backgrounds and decorations ================================

  // ---- 8. single shape filling almost the whole slide ------------
  // Background-style rectangle covering ~95% of the canvas; tests
  // large-extent geometry and clipping at slide bounds.
  cases.push({
    id: "shape-comp-full-bleed-bg",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "BG", "rect", "228600", "228600", "8686800", "6400800", "1F3864",
      ),
      pml_extra_textbox(
        "3", "BGLabel", "228600", "228600", "8686800", "6400800", "Full-bleed background",
        "3600",
      ),
    ]),
  })

  // ---- 9. multiple shapes layered with z-order -------------------
  // Five concentric rounded rectangles, biggest first.  Each
  // subsequent shape is smaller and centred inside the previous;
  // the renderer must honour document order = paint order.
  cases.push({
    id: "shape-comp-layered-zorder",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "L1", "roundRect", "457200", "457200", "8229600", "5943600", "1F4E79",
      ),
      pptx_shape(
        "3", "L2", "roundRect", "1143000", "1143000", "6858000", "4572000", "2E75B6",
      ),
      pptx_shape(
        "4", "L3", "roundRect", "1828800", "1828800", "5486400", "3200400", "5B9BD5",
      ),
      pptx_shape(
        "5", "L4", "roundRect", "2514600", "2514600", "4114800", "1828800", "9DC3E6",
      ),
      pptx_shape(
        "6", "L5", "roundRect", "3200400", "3086100", "2743200", "685800", "FFFFFF",
      ),
    ]),
  })

  // ---- 10. decorative banner with text ---------------------------
  // A wide ribbon stretched across the upper third of the slide with
  // a contrasting text label centred inside it.
  cases.push({
    id: "shape-comp-decorative-banner",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Ribbon", "ribbon", "457200", "1600200", "8229600", "1828800", "C00000",
      ),
      pml_extra_textbox(
        "3", "Banner", "457200", "1600200", "8229600", "1828800", "BANNER HEADLINE",
        "3200",
      ),
    ]),
  })

  // ---- 11. star burst with text label ----------------------------
  // 24-point star centred behind a 24pt label — classic "burst"
  // decoration.  Exercises starN preset geometry rendering and
  // text-over-shape compositing.
  cases.push({
    id: "shape-comp-star-burst",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Burst", "star24", "2971800", "1828800", "3200400", "3200400", "FFC000",
      ),
      pml_extra_textbox(
        "3", "BurstText", "2971800", "1828800", "3200400", "3200400", "NEW!", "4400",
      ),
    ]),
  })

  // ===== Specific shape combinations ================================

  // ---- 12. chart-like rectangle layout ---------------------------
  // Six tall rectangles of varying heights arranged as bar-chart
  // columns over a baseline rectangle (the "axis").  Verifies that
  // small layout offsets compose into a coherent chart picture.
  cases.push({
    id: "shape-comp-bar-chart",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      // Baseline (x-axis).
      pptx_shape(
        "2", "Axis", "rect", "457200", "5486400", "8229600", "38100", "404040",
      ),
      // Bars, varying height.
      pptx_shape(
        "3", "B1", "rect", "914400", "3886200", "914400", "1600200", "4472C4",
      ),
      pptx_shape(
        "4", "B2", "rect", "2057400", "2743200", "914400", "2743200", "ED7D31",
      ),
      pptx_shape(
        "5", "B3", "rect", "3200400", "3429000", "914400", "2057400", "A5A5A5",
      ),
      pptx_shape(
        "6", "B4", "rect", "4343400", "1828800", "914400", "3657600", "FFC000",
      ),
      pptx_shape(
        "7", "B5", "rect", "5486400", "2514600", "914400", "2971800", "5B9BD5",
      ),
      pptx_shape(
        "8", "B6", "rect", "6629400", "3657600", "914400", "1828800", "70AD47",
      ),
    ]),
  })

  // ---- 13. speech bubbles with different tail directions ---------
  // Four wedge-callout variants pointing in different directions —
  // covers wedgeRectCallout, wedgeRoundRectCallout, and
  // wedgeEllipseCallout in a single slide.
  cases.push({
    id: "shape-comp-speech-bubbles",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Bub1", "wedgeRectCallout", "457200", "457200", "3886200", "2286000",
        "FFF2CC",
      ),
      pptx_shape(
        "3", "Bub2", "wedgeRoundRectCallout", "4800600", "457200", "3886200", "2286000",
        "DEEBF7",
      ),
      pptx_shape(
        "4", "Bub3", "wedgeEllipseCallout", "457200", "3429000", "3886200", "2286000",
        "E2EFDA",
      ),
      pptx_shape(
        "5", "Bub4", "cloudCallout", "4800600", "3429000", "3886200", "2286000",
        "FBE5D6",
      ),
    ]),
  })

  // ---- 14. brackets annotating an inner box ----------------------
  // A central rect with `leftBracket` + `rightBracket` strokes
  // flanking it, plus top/bottom brace pair.  Exercises stroke-only
  // bracket / brace presets used as annotation marks.
  cases.push({
    id: "shape-comp-bracket-annotation",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Inner", "rect", "2514600", "2286000", "4114800", "2286000", "DEEBF7",
      ),
      pptx_shape_outline(
        "3", "LB", "leftBracket", "2057400", "2057400", "457200", "2743200", "1F3864",
      ),
      pptx_shape_outline(
        "4", "RB", "rightBracket", "6629400", "2057400", "457200", "2743200", "1F3864",
      ),
      pptx_shape_outline(
        "5", "TB", "leftBrace", "2514600", "1600200", "4114800", "457200", "C00000",
      ),
      pptx_shape_outline(
        "6", "BB", "rightBrace", "2514600", "4800600", "4114800", "457200", "C00000",
      ),
    ]),
  })

  // ---- 15. org-chart-like hierarchy ------------------------------
  // CEO box on top, two managers, four reports.  Connector arrows
  // from CEO→managers and manager→reports.  Tests dense layout of
  // bordered rectangles plus straight connectors.
  cases.push({
    id: "shape-comp-org-chart",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      // Root.
      pml_extra_shape_bordered(
        "2", "CEO", "rect", "3886200", "228600", "1371600", "685800", "1F4E79", "041D38",
      ),
      // Mid-tier managers.
      pml_extra_shape_bordered(
        "3", "M1", "rect", "1828800", "2057400", "1371600", "685800", "2E75B6", "1F4E79",
      ),
      pml_extra_shape_bordered(
        "4", "M2", "rect", "5943600", "2057400", "1371600", "685800", "2E75B6", "1F4E79",
      ),
      // Reports.
      pml_extra_shape_bordered(
        "5", "R1", "rect", "457200", "3886200", "1371600", "685800", "5B9BD5", "2E75B6",
      ),
      pml_extra_shape_bordered(
        "6", "R2", "rect", "2286000", "3886200", "1371600", "685800", "5B9BD5", "2E75B6",
      ),
      pml_extra_shape_bordered(
        "7", "R3", "rect", "4572000", "3886200", "1371600", "685800", "5B9BD5", "2E75B6",
      ),
      pml_extra_shape_bordered(
        "8", "R4", "rect", "6400800", "3886200", "1371600", "685800", "5B9BD5", "2E75B6",
      ),
      // CEO -> M1, M2 (flipH on the diagonal to M1 side).
      pml_extra_arrow(
        "9", "OC1", "2514600", "914400", "2057400", "1143000", true, false, "404040",
      ),
      pml_extra_arrow(
        "10", "OC2", "4572000", "914400", "2057400", "1143000", false, false, "404040",
      ),
      // M1 -> R1, R2.
      pml_extra_arrow(
        "11", "OC3", "1143000", "2743200", "1371600", "1143000", true, false, "404040",
      ),
      pml_extra_arrow(
        "12", "OC4", "2514600", "2743200", "457200", "1143000", false, false, "404040",
      ),
      // M2 -> R3, R4.
      pml_extra_arrow(
        "13", "OC5", "5257800", "2743200", "1371600", "1143000", true, false, "404040",
      ),
      pml_extra_arrow(
        "14", "OC6", "6629400", "2743200", "457200", "1143000", false, false, "404040",
      ),
    ]),
  })

  // ===== Misc =======================================================

  // ---- 16. single centred circle ---------------------------------
  // One ellipse, dead-centre, large.  The simplest possible
  // compositional fixture — sanity-checks slide centering math.
  cases.push({
    id: "shape-comp-center-circle",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Circle", "ellipse", "3429000", "2286000", "2286000", "2286000", "4472C4",
      ),
    ]),
  })

  // ---- 17. 10 ellipses in a ring ---------------------------------
  // Ten small ellipses placed on an evenly-divided 360° circle.
  // Verifies the renderer's per-shape transform math when many
  // shapes share a common centre.  Coordinates are precomputed in
  // EMU; centre (4572000, 3429000), radius 2286000.
  let ring_xy = [
    // (x_offset, y_offset) from centre for angle i*36° (i = 0..9)
    (2286000, 0),
    (1850204, 1343778),
    (706577, 2174240),
    (-706577, 2174240),
    (-1850204, 1343778),
    (-2286000, 0),
    (-1850204, -1343778),
    (-706577, -2174240),
    (706577, -2174240),
    (1850204, -1343778),
  ]
  let ring_shapes : Array[@xml.Element] = []
  for i, p in ring_xy {
    let (dx, dy) = p
    let cx_emu = 4572000 + dx - 304800
    let cy_emu = 3429000 + dy - 304800
    ring_shapes.push(
      pptx_shape(
        (i + 2).to_string(),
        "Ring" + i.to_string(),
        "ellipse",
        cx_emu.to_string(),
        cy_emu.to_string(),
        "609600",
        "609600",
        "4472C4",
      ),
    )
  }
  cases.push({
    id: "shape-comp-ring-of-ellipses",
    format: "pptx",
    category: "shape",
    content: sp_tree(ring_shapes),
  })

  // ---- 18. arrows pointing to a central shape --------------------
  // Central diamond with four converging arrows (from N, S, E, W).
  // Tests connector + filled preset interaction.
  cases.push({
    id: "shape-comp-converging-arrows",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Hub", "diamond", "3886200", "2743200", "1371600", "1371600", "C00000",
      ),
      // From left edge to hub-left.
      pml_extra_arrow(
        "3", "Lin", "457200", "3429000", "3429000", "1", false, false, "404040",
      ),
      // From right edge to hub-right.
      pml_extra_arrow(
        "4", "Rin", "5257800", "3429000", "3429000", "1", true, false, "404040",
      ),
      // From top edge to hub-top.
      pml_extra_arrow(
        "5", "Tin", "4572000", "457200", "1", "2286000", false, false, "404040",
      ),
      // From bottom edge to hub-bottom.
      pml_extra_arrow(
        "6", "Bin", "4572000", "4114800", "1", "2286000", false, true, "404040",
      ),
    ]),
  })

  // ---- 19. tile pattern of small shapes --------------------------
  // 6×4 grid of small alternating-coloured squares — a simple tile
  // pattern testing many-shapes-per-slide performance and uniform
  // layout math.
  let tile_shapes : Array[@xml.Element] = []
  let tile_cols = 6
  let tile_rows = 4
  let tile_cell = 1143000
  let tile_gap = 76200
  let mut tile_id = 2
  for r in 0..<tile_rows {
    for c in 0..<tile_cols {
      let x = (457200 + c * (tile_cell + tile_gap)).to_string()
      let y = (914400 + r * (tile_cell + tile_gap)).to_string()
      let parity = (r + c) % 2
      let hex = if parity == 0 { "4472C4" } else { "ED7D31" }
      tile_shapes.push(
        pptx_shape(
          tile_id.to_string(),
          "T" + tile_id.to_string(),
          "rect",
          x,
          y,
          tile_cell.to_string(),
          tile_cell.to_string(),
          hex,
        ),
      )
      tile_id = tile_id + 1
    }
  }
  cases.push({
    id: "shape-comp-tile-pattern",
    format: "pptx",
    category: "shape",
    content: sp_tree(tile_shapes),
  })

  // ---- 20. callouts of every wedge variant -----------------------
  // Side-by-side panel of every wedge callout flavour with
  // distinguishing fills.  Complements fixture #13 by adding the
  // arrow-callout family.
  cases.push({
    id: "shape-comp-arrow-callouts",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "ACL", "leftArrowCallout", "457200", "457200", "2057400", "1828800",
        "DEEBF7",
      ),
      pptx_shape(
        "3", "ACR", "rightArrowCallout", "2743200", "457200", "2057400", "1828800",
        "FCE4D6",
      ),
      pptx_shape(
        "4", "ACU", "upArrowCallout", "5029200", "457200", "2057400", "1828800",
        "FFF2CC",
      ),
      pptx_shape(
        "5", "ACD", "downArrowCallout", "7315200", "457200", "1371600", "1828800",
        "E2EFDA",
      ),
      pptx_shape(
        "6", "ACLR", "leftRightArrowCallout", "457200", "2743200", "4114800", "1828800",
        "DEEBF7",
      ),
      pptx_shape(
        "7", "ACUD", "upDownArrowCallout", "4800600", "2743200", "1828800", "1828800",
        "FFF2CC",
      ),
      pptx_shape(
        "8", "ACQ", "quadArrowCallout", "6858000", "2743200", "1828800", "1828800",
        "E2EFDA",
      ),
      pptx_shape(
        "9", "ACBig", "rightArrowCallout", "457200", "4800600", "8229600", "1371600",
        "C00000",
      ),
    ]),
  })

  // ---- 21. concentric donuts (background-style decoration) -------
  // Two donut shapes nested concentrically over a backing
  // rectangle.  Tests the donut preset's hole rendering and
  // multi-layer compositing.
  cases.push({
    id: "shape-comp-concentric-donuts",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Back", "rect", "228600", "228600", "8686800", "6400800", "F2F2F2",
      ),
      pptx_shape(
        "3", "DonutO", "donut", "3200400", "1828800", "2743200", "2743200", "1F4E79",
      ),
      pptx_shape(
        "4", "DonutI", "donut", "3886200", "2514600", "1371600", "1371600", "ED7D31",
      ),
    ]),
  })

  // ---- 22. mixed-preset diagram (process map) --------------------
  // Mix of flowchart presets connected by arrows to make a realistic
  // multi-step process map.  Process → Decision → 2 outputs.
  cases.push({
    id: "shape-comp-process-map",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pml_extra_shape_bordered(
        "2", "Start", "flowChartTerminator", "457200", "457200", "1828800", "914400",
        "DEEBF7", "1F4E79",
      ),
      pml_extra_textbox(
        "3", "StartT", "457200", "457200", "1828800", "914400", "Start", "1800",
      ),
      pml_extra_arrow(
        "4", "PA1", "2286000", "914400", "457200", "457200", false, false, "404040",
      ),
      pml_extra_shape_bordered(
        "5", "Proc", "flowChartProcess", "2743200", "457200", "1828800", "914400",
        "FFF2CC", "BF8F00",
      ),
      pml_extra_textbox(
        "6", "ProcT", "2743200", "457200", "1828800", "914400", "Process", "1800",
      ),
      pml_extra_arrow(
        "7", "PA2", "4572000", "914400", "457200", "457200", false, false, "404040",
      ),
      pml_extra_shape_bordered(
        "8", "Dec", "flowChartDecision", "5029200", "228600", "1828800", "1371600",
        "FBE5D6", "C65911",
      ),
      pml_extra_textbox(
        "9", "DecT", "5029200", "228600", "1828800", "1371600", "Branch?", "1600",
      ),
      // Yes branch (top).
      pml_extra_arrow(
        "10", "PA3", "6858000", "914400", "457200", "457200", false, false, "404040",
      ),
      pml_extra_shape_bordered(
        "11", "Y", "flowChartTerminator", "7315200", "457200", "1371600", "914400",
        "E2EFDA", "548235",
      ),
      pml_extra_textbox(
        "12", "YT", "7315200", "457200", "1371600", "914400", "Yes", "1800",
      ),
      // No branch (bottom).
      pml_extra_arrow(
        "13", "PA4", "5943600", "1600200", "457200", "1828800", false, false, "404040",
      ),
      pml_extra_shape_bordered(
        "14", "N", "flowChartTerminator", "5257800", "3886200", "1371600", "914400",
        "FBE5D6", "C65911",
      ),
      pml_extra_textbox(
        "15", "NT", "5257800", "3886200", "1371600", "914400", "No", "1800",
      ),
    ]),
  })

  // ---- 23. side-by-side rotated rectangles -----------------------
  // Three rectangles rotated 0°, 15°, 30° respectively (rot is in
  // 60000ths-of-a-degree).  Combines transform+geometry: tests both
  // the rotation pipeline and the layout offset for adjacent rotated
  // shapes.
  cases.push({
    id: "shape-comp-rotation-row",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      xe(NS_PML, "sp", [], [
        Element(
          xe(NS_PML, "nvSpPr", [], [
            Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "R0")], [])),
            Element(xe(NS_PML, "cNvSpPr", [], [])),
            Element(xe(NS_PML, "nvPr", [], [])),
          ]),
        ),
        Element(
          xe(NS_PML, "spPr", [], [
            Element(sp_xfrm("457200", "2286000", "2057400", "2286000")),
            Element(
              xe(NS_A, "prstGeom", [xa("prst", "rect")], [
                Element(xe(NS_A, "avLst", [], [])),
              ]),
            ),
            Element(solid_fill("4472C4")),
          ]),
        ),
      ]),
      xe(NS_PML, "sp", [], [
        Element(
          xe(NS_PML, "nvSpPr", [], [
            Element(xe(NS_PML, "cNvPr", [xa("id", "3"), xa("name", "R15")], [])),
            Element(xe(NS_PML, "cNvSpPr", [], [])),
            Element(xe(NS_PML, "nvPr", [], [])),
          ]),
        ),
        Element(
          xe(NS_PML, "spPr", [], [
            Element(
              xe(NS_A, "xfrm", [xa("rot", "900000")], [
                Element(
                  xe(NS_A, "off", [xa("x", "3543300"), xa("y", "2286000")], []),
                ),
                Element(
                  xe(NS_A, "ext", [xa("cx", "2057400"), xa("cy", "2286000")], []),
                ),
              ]),
            ),
            Element(
              xe(NS_A, "prstGeom", [xa("prst", "rect")], [
                Element(xe(NS_A, "avLst", [], [])),
              ]),
            ),
            Element(solid_fill("ED7D31")),
          ]),
        ),
      ]),
      xe(NS_PML, "sp", [], [
        Element(
          xe(NS_PML, "nvSpPr", [], [
            Element(xe(NS_PML, "cNvPr", [xa("id", "4"), xa("name", "R30")], [])),
            Element(xe(NS_PML, "cNvSpPr", [], [])),
            Element(xe(NS_PML, "nvPr", [], [])),
          ]),
        ),
        Element(
          xe(NS_PML, "spPr", [], [
            Element(
              xe(NS_A, "xfrm", [xa("rot", "1800000")], [
                Element(
                  xe(NS_A, "off", [xa("x", "6629400"), xa("y", "2286000")], []),
                ),
                Element(
                  xe(NS_A, "ext", [xa("cx", "2057400"), xa("cy", "2286000")], []),
                ),
              ]),
            ),
            Element(
              xe(NS_A, "prstGeom", [xa("prst", "rect")], [
                Element(xe(NS_A, "avLst", [], [])),
              ]),
            ),
            Element(solid_fill("70AD47")),
          ]),
        ),
      ]),
    ]),
  })

  // ---- 24. multi-connector "subway" map --------------------------
  // Several connectors of different orientations meeting at a central
  // hub.  Tests the renderer's stroke pipeline with many parallel /
  // perpendicular lines.
  cases.push({
    id: "shape-comp-connector-mesh",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      // Central hub.
      pptx_shape(
        "2", "Hub", "ellipse", "4114800", "2971800", "914400", "914400", "C00000",
      ),
      // Four diagonals.
      pml_extra_arrow(
        "3", "M1", "457200", "457200", "3657600", "2514600", false, false, "1F3864",
      ),
      pml_extra_arrow(
        "4", "M2", "5029200", "457200", "3657600", "2514600", true, false, "1F3864",
      ),
      pml_extra_arrow(
        "5", "M3", "457200", "3886200", "3657600", "2514600", false, true, "1F3864",
      ),
      pml_extra_arrow(
        "6", "M4", "5029200", "3886200", "3657600", "2514600", true, true, "1F3864",
      ),
      // Cardinal.
      pml_extra_arrow(
        "7", "M5", "457200", "3429000", "3657600", "1", false, false, "548235",
      ),
      pml_extra_arrow(
        "8", "M6", "5029200", "3429000", "3657600", "1", false, false, "548235",
      ),
      pml_extra_arrow(
        "9", "M7", "4572000", "457200", "1", "2514600", false, false, "548235",
      ),
      pml_extra_arrow(
        "10", "M8", "4572000", "3886200", "1", "2514600", false, false, "548235",
      ),
    ]),
  })

  // ---- 25. mixed gradient-look shapes ----------------------------
  // Four shapes — rect, ellipse, pentagon, hexagon — laid out in a
  // row, each filled with a different stepped colour (no real
  // gradient: just a band of layered translucent ellipses gives the
  // illusion of fading).  Verifies layered alpha + preset geometry.
  cases.push({
    id: "shape-comp-pseudo-gradient-row",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      // Rect with overlaid alpha rect (creates two-tone band).
      pptx_shape(
        "2", "G1", "rect", "457200", "2057400", "1828800", "2743200", "4472C4",
      ),
      pml_extra_shape_alpha(
        "3", "G1Top", "rect", "457200", "2057400", "1828800", "1371600", "FFFFFF",
        "40000",
      ),
      // Ellipse split.
      pptx_shape(
        "4", "G2", "ellipse", "2514600", "2057400", "1828800", "2743200", "ED7D31",
      ),
      pml_extra_shape_alpha(
        "5", "G2Top", "ellipse", "2514600", "2057400", "1828800", "1371600", "FFFFFF",
        "40000",
      ),
      // Pentagon split.
      pptx_shape(
        "6", "G3", "pentagon", "4572000", "2057400", "1828800", "2743200", "70AD47",
      ),
      pml_extra_shape_alpha(
        "7", "G3Top", "pentagon", "4572000", "2057400", "1828800", "1371600", "FFFFFF",
        "40000",
      ),
      // Hexagon split.
      pptx_shape(
        "8", "G4", "hexagon", "6629400", "2057400", "1828800", "2743200", "7030A0",
      ),
      pml_extra_shape_alpha(
        "9", "G4Top", "hexagon", "6629400", "2057400", "1828800", "1371600", "FFFFFF",
        "40000",
      ),
    ]),
  })
}
