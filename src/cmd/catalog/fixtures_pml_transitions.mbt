// PresentationML slide-transition and DrawingML theme-cascade
// fixtures.
//
// Two families of coverage:
//
//   1. Slide transitions (`<p:transition>`).  Per ECMA-376
//      §19.3.1.50 the transition is a sibling of `<p:cSld>` inside
//      `<p:sld>`.  The shared `pptx_package` builder however accepts
//      a single `content` child of `<p:sld>` (the cSld), so the
//      transition is embedded *inside* the cSld instead — strictly
//      speaking the wrong location, but renderers tolerate unknown
//      child elements and the goal here is purely to ensure the
//      `<p:transition>` flavour does NOT crash the renderer when it
//      appears in a slide.  Each fixture additionally carries a
//      visible shape so the rendered output is compared against
//      LibreOffice on the shape alone.
//
//   2. DrawingML theme cascade.  Exercises every cascade flavour the
//      DrawingML colour pipeline must resolve when no theme part is
//      shipped: bare `schemeClr`, scheme + shade, scheme + tint,
//      bg/tx mixes, hlink / folHlink, the lumMod+lumOff cascade,
//      multi-modifier stacks, and an sRGB-vs-scheme grid.  All
//      visual; no theme part is shipped so the renderer must hit its
//      built-in fallback table.
//
//   3. Misc PML coverage — many-text-blocks, dense grid w/ labels,
//      comparison panels.
//
// Conventions:
//   • Slide canvas is 9144000 × 6858000 EMU (10in × 7.5in).
//   • Every shape inside a slide gets a unique integer `id_`
//     starting at "2" (id "1" is reserved for the group at the
//     `<p:spTree>` root).
//   • Uses top-level helpers from `fixtures_helpers.mbt`
//     (`pptx_shape`, `pptx_shape_outline`, `sp_xfrm`, `solid_fill`,
//     `sp_tree`, `xe`, `xa`).  Local helpers below are kept
//     self-contained so this file does not depend on the private
//     helpers in sibling category files.

///|
/// `<a:solidFill><a:schemeClr val="..."/></a:solidFill>`.
fn pmltr_scheme_fill(scheme_name : String) -> @xml.Element {
  xe(NS_A, "solidFill", [], [
    Element(xe(NS_A, "schemeClr", [xa("val", scheme_name)], [])),
  ])
}

///|
/// `<a:solidFill><a:schemeClr val="..."><mods></a:schemeClr></a:solidFill>`.
/// Modifier list is applied in document order per ECMA-376 §20.1.2.3.
fn pmltr_scheme_fill_with_mods(
  scheme_name : String,
  mods : Array[@xml.Element],
) -> @xml.Element {
  let mod_nodes : Array[@xml.Node] = []
  for m in mods {
    mod_nodes.push(Element(m))
  }
  xe(NS_A, "solidFill", [], [
    Element(xe(NS_A, "schemeClr", [xa("val", scheme_name)], mod_nodes)),
  ])
}

///|
/// `<a:solidFill><a:sysClr val="..." lastClr="..."/></a:solidFill>`.
fn pmltr_sys_fill(name : String, last_clr : String) -> @xml.Element {
  xe(NS_A, "solidFill", [], [
    Element(xe(NS_A, "sysClr", [xa("val", name), xa("lastClr", last_clr)], [])),
  ])
}

///|
/// `<a:solidFill><a:srgbClr val="..."/></a:solidFill>` — used to
/// pair sRGB swatches next to scheme swatches in the comparison
/// grid.
fn pmltr_srgb_fill(hex : String) -> @xml.Element {
  xe(NS_A, "solidFill", [], [Element(xe(NS_A, "srgbClr", [xa("val", hex)], []))])
}

///|
/// Build a `<p:sp>` with preset geometry, position+size, and an
/// externally-built `<a:solidFill>` payload.  Used by every theme-
/// cascade fixture so the call sites can pick `pmltr_scheme_fill`,
/// `pmltr_scheme_fill_with_mods`, `pmltr_sys_fill`, etc.
fn pmltr_shape_with_fill(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill : @xml.Element,
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
        Element(fill),
      ]),
    ),
  ])
}

///|
/// Build a `<p:sp>` with preset geometry, fill, AND a contrasting
/// outline.  Used by `theme-color-bg-tx-mix` so the cascade is
/// visible against the background.
fn pmltr_shape_with_fill_and_outline(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill : @xml.Element,
  outline : @xml.Element,
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
        Element(fill),
        Element(xe(NS_A, "ln", [xa("w", "38100")], [Element(outline)])),
      ]),
    ),
  ])
}

///|
/// Centred text-frame shape — single-paragraph label used by the
/// pml-slide-grid-with-text and pml-slide-many-text-blocks fixtures.
fn pmltr_textbox(
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
/// Wrap a `<p:transition>` element together with the shape tree
/// (spTree) inside a `<p:cSld>`.  ECMA-376 §19.3.1.38 puts
/// `<p:transition>` as a sibling of `<p:cSld>`, but the shared
/// `pptx_package` builder accepts only a single child element of
/// `<p:sld>`, so we embed the transition inside `<p:cSld>`.
/// Renderers tolerate unknown child elements; visual fidelity is
/// measured on the rendered shapes alone.
fn pmltr_cSld_with_transition(
  transition : @xml.Element,
  shapes : Array[@xml.Element],
) -> @xml.Element {
  let sp_kids : Array[@xml.Node] = [
    Element(
      xe(NS_PML, "nvGrpSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "1"), xa("name", "")], [])),
        Element(xe(NS_PML, "cNvGrpSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(xe(NS_PML, "grpSpPr", [], [])),
  ]
  for s in shapes {
    sp_kids.push(Element(s))
  }
  xe(NS_PML, "cSld", [], [
    Element(xe(NS_PML, "spTree", [], sp_kids)),
    Element(transition),
  ])
}

///|
/// `<p:transition>` carrying a single named child (e.g. `<p:fade/>`,
/// `<p:wipe dir="r"/>`).  The `child_attrs` list configures the inner
/// transition element's attributes.
fn pmltr_transition(
  child_name : String,
  child_attrs : Array[@xml.Attribute],
) -> @xml.Element {
  xe(NS_PML, "transition", [], [
    Element(xe(NS_PML, child_name, child_attrs, [])),
  ])
}

///|
fn extras_pml_transitions(cases : Array[VisualCase]) -> Unit {
  // A reusable visible shape used by every transition fixture.  Big
  // central rectangle in accent blue so the renderer's shape
  // pipeline is exercised regardless of the transition payload.
  let transition_witness : @xml.Element = pptx_shape(
    "2", "TransitionWitness", "rect", "1828800", "1828800", "5486400", "3200400",
    "4472C4",
  )

  // ===== Slide transitions ==========================================
  // Each fixture pairs one transition flavour with the same witness
  // shape.  The transition element itself does not render in a
  // single-slide snapshot — its purpose is to ensure the renderer
  // does not crash when encountering it.

  // ---- 1. fade ----------------------------------------------------
  cases.push({
    id: "transition-fade",
    format: "pptx",
    category: "transition",
    content: pmltr_cSld_with_transition(pmltr_transition("fade", []), [
      transition_witness,
    ]),
  })

  // ---- 2. push (rightward) ----------------------------------------
  cases.push({
    id: "transition-push",
    format: "pptx",
    category: "transition",
    content: pmltr_cSld_with_transition(
      pmltr_transition("push", [xa("dir", "r")]),
      [transition_witness],
    ),
  })

  // ---- 3. wipe (rightward) ----------------------------------------
  cases.push({
    id: "transition-wipe",
    format: "pptx",
    category: "transition",
    content: pmltr_cSld_with_transition(
      pmltr_transition("wipe", [xa("dir", "r")]),
      [transition_witness],
    ),
  })

  // ---- 4. split (horizontal, outward) -----------------------------
  cases.push({
    id: "transition-split",
    format: "pptx",
    category: "transition",
    content: pmltr_cSld_with_transition(
      pmltr_transition("split", [xa("dir", "out"), xa("orient", "horz")]),
      [transition_witness],
    ),
  })

  // ---- 5. circle --------------------------------------------------
  cases.push({
    id: "transition-circle",
    format: "pptx",
    category: "transition",
    content: pmltr_cSld_with_transition(pmltr_transition("circle", []), [
      transition_witness,
    ]),
  })

  // ---- 6. zoom (inward) -------------------------------------------
  cases.push({
    id: "transition-zoom",
    format: "pptx",
    category: "transition",
    content: pmltr_cSld_with_transition(
      pmltr_transition("zoom", [xa("dir", "in")]),
      [transition_witness],
    ),
  })

  // ===== DrawingML theme cascade ====================================
  // Each fixture is a big rectangle (or grid of them) filled with a
  // scheme colour, optionally with a cascade of modifiers.  Without
  // a theme part the renderer must fall back to its built-in Office
  // accent palette:
  //   bg1     = FFFFFF        tx1     = 000000
  //   bg2     = E7E6E6        tx2     = 44546A
  //   accent1 = 4472C4        accent2 = ED7D31
  //   accent3 = A5A5A5        accent4 = FFC000
  //   accent5 = 5B9BD5        accent6 = 70AD47
  //   hlink   = 0563C1        folHlink= 954F72

  // ---- 7. plain accent1 -------------------------------------------
  cases.push({
    id: "theme-color-accent1-fill",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill(
        "2",
        "Accent1",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_scheme_fill("accent1"),
      ),
    ]),
  })

  // ---- 8. accent2 with 50% shade (darkened) -----------------------
  cases.push({
    id: "theme-color-accent2-with-shade",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill(
        "2",
        "Accent2Shaded",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_scheme_fill_with_mods("accent2", [
          xe(NS_A, "shade", [xa("val", "50000")], []),
        ]),
      ),
    ]),
  })

  // ---- 9. accent3 with 50% tint (lightened) -----------------------
  cases.push({
    id: "theme-color-accent3-with-tint",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill(
        "2",
        "Accent3Tinted",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_scheme_fill_with_mods("accent3", [
          xe(NS_A, "tint", [xa("val", "50000")], []),
        ]),
      ),
    ]),
  })

  // ---- 10. bg2 background + tx1 outline ---------------------------
  // Big bg2 rect with a dark tx1 outline.  Tests both background
  // and text scheme slot resolution in a single fixture.
  cases.push({
    id: "theme-color-bg-tx-mix",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill_and_outline(
        "2",
        "BgTxMix",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_scheme_fill("bg2"),
        pmltr_scheme_fill("tx1"),
      ),
    ]),
  })

  // ---- 11. hlink-coloured shape -----------------------------------
  cases.push({
    id: "theme-color-hlink-link",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill(
        "2",
        "HlinkSwatch",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_scheme_fill("hlink"),
      ),
    ]),
  })

  // ---- 12. luminance cascade (lumMod 75% + lumOff 25%) ------------
  // The single most common Office-authored cascade — accent + lumMod
  // 75000 + lumOff 25000 produces the "60% lighter" Office UI shade.
  cases.push({
    id: "theme-color-luminance-cascade",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill(
        "2",
        "LumCascade",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_scheme_fill_with_mods("accent1", [
          xe(NS_A, "lumMod", [xa("val", "75000")], []),
          xe(NS_A, "lumOff", [xa("val", "25000")], []),
        ]),
      ),
    ]),
  })

  // ---- 13. all-accents grid (accent1..6) --------------------------
  // 3×2 grid of accent-coloured swatches — verifies the slot map
  // resolves every accent slot to a distinct hue.
  let accent_names = [
    "accent1", "accent2", "accent3", "accent4", "accent5", "accent6",
  ]
  let accent_shapes : Array[@xml.Element] = []
  let accent_cols = 3
  let accent_rows = 2
  let accent_avail_w = 8229600
  let accent_avail_h = 5943600
  let accent_gap = 76200
  let accent_cell_w = (accent_avail_w - accent_gap * (accent_cols - 1)) /
    accent_cols
  let accent_cell_h = (accent_avail_h - accent_gap * (accent_rows - 1)) /
    accent_rows
  for i, name in accent_names {
    let col = i % accent_cols
    let row = i / accent_cols
    let x = (457200 + col * (accent_cell_w + accent_gap)).to_string()
    let y = (457200 + row * (accent_cell_h + accent_gap)).to_string()
    accent_shapes.push(
      pmltr_shape_with_fill(
        (i + 2).to_string(),
        "A" + (i + 1).to_string(),
        "rect",
        x,
        y,
        accent_cell_w.to_string(),
        accent_cell_h.to_string(),
        pmltr_scheme_fill(name),
      ),
    )
  }
  cases.push({
    id: "theme-color-all-accents-grid",
    format: "pptx",
    category: "theme",
    content: sp_tree(accent_shapes),
  })

  // ---- 14. srgb vs scheme grid ------------------------------------
  // Two columns: left = sRGB literal blue (#5B9BD5 ≈ accent5),
  // right = schemeClr accent5.  In a default-theme renderer the two
  // should be visually indistinguishable; mismatches mean the
  // scheme→sRGB resolution is wrong.
  let srgb_vs_scheme : Array[@xml.Element] = []
  let pair_w = 4038600 // (8229600 - 152400) / 2
  let pair_y_top = 457200
  let pair_h = 2895600 // (5943600 - 152400) / 2
  let pair_y_bot = pair_y_top + pair_h + 152400
  let pair_x_left = 457200
  let pair_x_right = pair_x_left + pair_w + 152400
  srgb_vs_scheme.push(
    pmltr_shape_with_fill(
      "2",
      "Srgb5",
      "rect",
      pair_x_left.to_string(),
      pair_y_top.to_string(),
      pair_w.to_string(),
      pair_h.to_string(),
      pmltr_srgb_fill("5B9BD5"),
    ),
  )
  srgb_vs_scheme.push(
    pmltr_shape_with_fill(
      "3",
      "Scheme5",
      "rect",
      pair_x_right.to_string(),
      pair_y_top.to_string(),
      pair_w.to_string(),
      pair_h.to_string(),
      pmltr_scheme_fill("accent5"),
    ),
  )
  // Second row: a different pair (#4472C4 vs accent1).
  srgb_vs_scheme.push(
    pmltr_shape_with_fill(
      "4",
      "Srgb1",
      "rect",
      pair_x_left.to_string(),
      pair_y_bot.to_string(),
      pair_w.to_string(),
      pair_h.to_string(),
      pmltr_srgb_fill("4472C4"),
    ),
  )
  srgb_vs_scheme.push(
    pmltr_shape_with_fill(
      "5",
      "Scheme1",
      "rect",
      pair_x_right.to_string(),
      pair_y_bot.to_string(),
      pair_w.to_string(),
      pair_h.to_string(),
      pmltr_scheme_fill("accent1"),
    ),
  )
  cases.push({
    id: "theme-color-srgb-vs-scheme-grid",
    format: "pptx",
    category: "theme",
    content: sp_tree(srgb_vs_scheme),
  })

  // ---- 15. multiple modifiers simultaneously ----------------------
  // accent4 + tint 60% + alpha 60% + lumMod 90%.  Order matters per
  // ECMA-376 §20.1.2.3; the renderer must apply them in document
  // order.
  cases.push({
    id: "theme-color-multiple-modifiers",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill(
        "2",
        "MultiMod",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_scheme_fill_with_mods("accent4", [
          xe(NS_A, "tint", [xa("val", "60000")], []),
          xe(NS_A, "lumMod", [xa("val", "90000")], []),
          xe(NS_A, "alpha", [xa("val", "60000")], []),
        ]),
      ),
    ]),
  })

  // ---- 16. followed-hyperlink colour ------------------------------
  cases.push({
    id: "theme-color-followed-hyperlink",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill(
        "2",
        "FolHlinkSwatch",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_scheme_fill("folHlink"),
      ),
    ]),
  })

  // ---- 17. sysClr windowText with lastClr fallback ---------------
  cases.push({
    id: "theme-color-sys-text",
    format: "pptx",
    category: "theme",
    content: sp_tree([
      pmltr_shape_with_fill(
        "2",
        "SysWindowText",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        pmltr_sys_fill("windowText", "000000"),
      ),
    ]),
  })

  // ===== Misc PML coverage ==========================================

  // ---- 18. many text blocks at different positions ---------------
  // 8 small textboxes scattered across the canvas.  Tests multiple
  // independent `<p:sp>` text frames with different positions and
  // sizes in one slide.
  cases.push({
    id: "pml-slide-many-text-blocks",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pmltr_textbox(
        "2", "TB1", "457200", "457200", "2057400", "685800", "Block 1", "2000",
      ),
      pmltr_textbox(
        "3", "TB2", "3543300", "457200", "2057400", "685800", "Block 2", "2000",
      ),
      pmltr_textbox(
        "4", "TB3", "6629400", "457200", "2057400", "685800", "Block 3", "2000",
      ),
      pmltr_textbox(
        "5", "TB4", "457200", "2057400", "2057400", "685800", "Block 4", "2000",
      ),
      pmltr_textbox(
        "6", "TB5", "3543300", "2057400", "2057400", "685800", "Block 5", "2000",
      ),
      pmltr_textbox(
        "7", "TB6", "6629400", "2057400", "2057400", "685800", "Block 6", "2000",
      ),
      pmltr_textbox(
        "8", "TB7", "1828800", "4114800", "2057400", "685800", "Block 7", "2000",
      ),
      pmltr_textbox(
        "9", "TB8", "5257800", "4114800", "2057400", "685800", "Block 8", "2000",
      ),
    ]),
  })

  // ---- 19. 4×3 grid of bordered shapes with labels ---------------
  // 12 cells, each a coloured rect with a centred label on top of
  // it.  Tests layout uniformity, z-order (rect then label), and
  // many-shapes-per-slide performance.
  let grid_cols = 4
  let grid_rows = 3
  let grid_avail_w = 8229600
  let grid_avail_h = 5943600
  let grid_gap = 76200
  let grid_cell_w = (grid_avail_w - grid_gap * (grid_cols - 1)) / grid_cols
  let grid_cell_h = (grid_avail_h - grid_gap * (grid_rows - 1)) / grid_rows
  let grid_palette = [
    "DEEBF7", "FCE4D6", "FFF2CC", "E2EFDA", "D9E1F2", "FBE5D6", "FFF7E5", "EAEEDB",
    "BDD7EE", "F8CBAD", "FFE699", "C5E0B4",
  ]
  let grid_shapes : Array[@xml.Element] = []
  let mut grid_id = 2
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      let idx = r * grid_cols + c
      let x = (457200 + c * (grid_cell_w + grid_gap)).to_string()
      let y = (457200 + r * (grid_cell_h + grid_gap)).to_string()
      grid_shapes.push(
        pptx_shape(
          grid_id.to_string(),
          "Cell" + idx.to_string(),
          "rect",
          x,
          y,
          grid_cell_w.to_string(),
          grid_cell_h.to_string(),
          grid_palette[idx],
        ),
      )
      grid_id = grid_id + 1
      grid_shapes.push(
        pmltr_textbox(
          grid_id.to_string(),
          "CellT" + idx.to_string(),
          x,
          y,
          grid_cell_w.to_string(),
          grid_cell_h.to_string(),
          "Cell " + (idx + 1).to_string(),
          "1800",
        ),
      )
      grid_id = grid_id + 1
    }
  }
  cases.push({
    id: "pml-slide-grid-with-text",
    format: "pptx",
    category: "shape",
    content: sp_tree(grid_shapes),
  })

  // ---- 20. 3-way comparison panel --------------------------------
  // Three side-by-side panels with header bands and body labels,
  // typical "Option A / Option B / Option C" deck slide.  Exercises
  // multi-shape z-order plus text on top of filled bands.
  let comp_cols = 3
  let comp_avail_w = 8229600
  let comp_gap = 152400
  let comp_cell_w = (comp_avail_w - comp_gap * (comp_cols - 1)) / comp_cols
  let comp_header_h = 685800
  let comp_body_h = 4572000
  let comp_y_header = 685800
  let comp_y_body = comp_y_header + comp_header_h
  let comp_header_colors = ["1F4E79", "548235", "C65911"]
  let comp_body_colors = ["DEEBF7", "E2EFDA", "FBE5D6"]
  let comp_titles = ["Option A", "Option B", "Option C"]
  let comp_bodies = [
    "Lower cost\nFaster setup\nLimited scale", "Balanced\nMedium cost\nGood scale",
    "Highest cost\nMost flexible\nFull scale",
  ]
  let comp_shapes : Array[@xml.Element] = []
  let mut comp_id = 2
  for i in 0..<comp_cols {
    let x = (457200 + i * (comp_cell_w + comp_gap)).to_string()
    // Header band.
    comp_shapes.push(
      pptx_shape(
        comp_id.to_string(),
        "Hdr" + i.to_string(),
        "rect",
        x,
        comp_y_header.to_string(),
        comp_cell_w.to_string(),
        comp_header_h.to_string(),
        comp_header_colors[i],
      ),
    )
    comp_id = comp_id + 1
    // Header label.
    comp_shapes.push(
      pmltr_textbox(
        comp_id.to_string(),
        "HdrT" + i.to_string(),
        x,
        comp_y_header.to_string(),
        comp_cell_w.to_string(),
        comp_header_h.to_string(),
        comp_titles[i],
        "2400",
      ),
    )
    comp_id = comp_id + 1
    // Body band.
    comp_shapes.push(
      pptx_shape(
        comp_id.to_string(),
        "Body" + i.to_string(),
        "rect",
        x,
        comp_y_body.to_string(),
        comp_cell_w.to_string(),
        comp_body_h.to_string(),
        comp_body_colors[i],
      ),
    )
    comp_id = comp_id + 1
    // Body label.
    comp_shapes.push(
      pmltr_textbox(
        comp_id.to_string(),
        "BodyT" + i.to_string(),
        x,
        comp_y_body.to_string(),
        comp_cell_w.to_string(),
        comp_body_h.to_string(),
        comp_bodies[i],
        "1800",
      ),
    )
    comp_id = comp_id + 1
  }
  cases.push({
    id: "pml-slide-comparison-3way",
    format: "pptx",
    category: "shape",
    content: sp_tree(comp_shapes),
  })
}
