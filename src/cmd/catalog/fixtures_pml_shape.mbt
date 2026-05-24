// PresentationML / DrawingML shape fixtures — preset geometries,
// gradient/fill variations, multi-layer 3D, group shapes.  Use
// `pptx_shape`, `pptx_shape_outline`, `sp_xfrm`, `solid_fill`,
// `sp_tree`, `preset_batch`, `preset_batch_outline` from
// `fixtures_helpers.mbt`.

///|
/// PresentationML `<p:sp>` with preset geometry, solid fill, and an
/// extra trailing child element appended INSIDE `<p:spPr>`.  Lets
/// each fixture below add an `<a:effectLst>`, `<a:ln>` with dashing
/// / arrowheads, or `<a:scene3d>` + `<a:sp3d>` without re-deriving
/// the entire `<p:sp>` body.  EMU coordinates, sRGB hex fill.
fn pptx_shape_extra(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  hex : String,
  extras : Array[@xml.Element],
) -> @xml.Element {
  let sp_pr_kids : Array[@xml.Node] = [
    Element(sp_xfrm(x, y, cx, cy)),
    Element(
      xe(NS_A, "prstGeom", [xa("prst", prst)], [
        Element(xe(NS_A, "avLst", [], [])),
      ]),
    ),
    Element(solid_fill(hex)),
  ]
  for e in extras {
    sp_pr_kids.push(Element(e))
  }
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(xe(NS_PML, "spPr", [], sp_pr_kids)),
  ])
}

///|
/// Same as `pptx_shape_extra` but with an EXPLICIT `<a:xfrm>` built
/// by the caller — used by fixtures that need `rot`, `flipH`,
/// `flipV` attributes on the transform itself.
fn pptx_shape_xfrm(
  id_ : String,
  name : String,
  prst : String,
  xfrm : @xml.Element,
  hex : String,
  extras : Array[@xml.Element],
) -> @xml.Element {
  let sp_pr_kids : Array[@xml.Node] = [
    Element(xfrm),
    Element(
      xe(NS_A, "prstGeom", [xa("prst", prst)], [
        Element(xe(NS_A, "avLst", [], [])),
      ]),
    ),
    Element(solid_fill(hex)),
  ]
  for e in extras {
    sp_pr_kids.push(Element(e))
  }
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(xe(NS_PML, "spPr", [], sp_pr_kids)),
  ])
}

///|
/// Build an `<a:xfrm>` carrying `rot` / `flipH` / `flipV` attrs —
/// position and extent in EMU.  Each transform-attribute arg is
/// optional; pass `None` to omit it.
fn xfrm_rot(
  x : String,
  y : String,
  cx : String,
  cy : String,
  rot : String?,
  flip_h : Bool,
  flip_v : Bool,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match rot {
    Some(r) => attrs.push(xa("rot", r))
    None => ()
  }
  if flip_h {
    attrs.push(xa("flipH", "1"))
  }
  if flip_v {
    attrs.push(xa("flipV", "1"))
  }
  xe(NS_A, "xfrm", attrs, [
    Element(xe(NS_A, "off", [xa("x", x), xa("y", y)], [])),
    Element(xe(NS_A, "ext", [xa("cx", cx), xa("cy", cy)], [])),
  ])
}

///|
/// `<a:ln>` with explicit width (EMU), cap, and a solid-fill stroke
/// colour — optionally with a `<a:prstDash>` and head / tail end
/// arrow specs as trailing children.  `cap` is one of "flat", "rnd",
/// "sq" (or empty to omit the attribute).
fn line_props(
  w_emu : String,
  cap : String,
  hex : String,
  trailing : Array[@xml.Element],
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [xa("w", w_emu)]
  if cap != "" {
    attrs.push(xa("cap", cap))
  }
  let kids : Array[@xml.Node] = [Element(solid_fill(hex))]
  for t in trailing {
    kids.push(Element(t))
  }
  xe(NS_A, "ln", attrs, kids)
}

///|
/// `<a:prstDash val="..."/>` — preset line dash (solid, dash, dot,
/// dashDot, lgDash, lgDashDot, lgDashDotDot, sysDash, sysDot, …).
fn prst_dash(val : String) -> @xml.Element {
  xe(NS_A, "prstDash", [xa("val", val)], [])
}

///|
/// `<a:headEnd>` / `<a:tailEnd>` arrow descriptor — type is "none",
/// "triangle", "stealth", "diamond", "oval", "arrow"; `w` and `len`
/// are "sm" / "med" / "lg".
fn arrow_end(
  tag : String,
  type_ : String,
  w : String,
  len : String,
) -> @xml.Element {
  xe(NS_A, tag, [xa("type", type_), xa("w", w), xa("len", len)], [])
}

///|
/// `<a:effectLst>` containing a single `<a:outerShdw>` — a basic
/// drop shadow.  `blur_emu`, `dist_emu` in EMU, `dir` in
/// 60000ths-of-a-degree.  Children of `outerShdw` are the colour
/// (`<a:srgbClr>`) used for the shadow.
fn outer_shadow_effect(
  blur_emu : String,
  dist_emu : String,
  dir : String,
  hex : String,
) -> @xml.Element {
  xe(NS_A, "effectLst", [], [
    Element(
      xe(
        NS_A,
        "outerShdw",
        [
          xa("blurRad", blur_emu),
          xa("dist", dist_emu),
          xa("dir", dir),
          xa("algn", "ctr"),
          xa("rotWithShape", "0"),
        ],
        [Element(xe(NS_A, "srgbClr", [xa("val", hex)], []))],
      ),
    ),
  ])
}

///|
/// `<a:effectLst>` carrying a coloured `<a:glow>` (soft halo).
fn glow_effect(rad_emu : String, hex : String) -> @xml.Element {
  xe(NS_A, "effectLst", [], [
    Element(
      xe(NS_A, "glow", [xa("rad", rad_emu)], [
        Element(xe(NS_A, "srgbClr", [xa("val", hex)], [])),
      ]),
    ),
  ])
}

///|
/// `<a:scene3d>` + `<a:sp3d>` pair as a two-element extras list —
/// minimal perspective camera plus a bevelled extrusion so the
/// parser sees a non-trivial 3D scene.
fn scene3d_extras() -> Array[@xml.Element] {
  [
    xe(NS_A, "scene3d", [], [
      Element(xe(NS_A, "camera", [xa("prst", "orthographicFront")], [])),
      Element(xe(NS_A, "lightRig", [xa("rig", "threePt"), xa("dir", "t")], [])),
    ]),
    xe(NS_A, "sp3d", [xa("extrusionH", "457200")], [
      Element(
        xe(
          NS_A,
          "bevelT",
          [xa("w", "76200"), xa("h", "76200"), xa("prst", "circle")],
          [],
        ),
      ),
    ]),
  ]
}

///|
/// `<a:solidFill>` with `<a:srgbClr>` + `<a:alpha val="..."/>`
/// modifier — semi-transparent solid fill (alpha in 100000ths).
fn solid_fill_alpha(hex : String, alpha_100000 : String) -> @xml.Element {
  xe(NS_A, "solidFill", [], [
    Element(
      xe(NS_A, "srgbClr", [xa("val", hex)], [
        Element(xe(NS_A, "alpha", [xa("val", alpha_100000)], [])),
      ]),
    ),
  ])
}

///|
/// PresentationML `<p:sp>` with preset geometry, an arbitrary
/// `<a:solidFill>` (constructed externally — typically via
/// `solid_fill_alpha` for an alpha-modified colour), and optional
/// trailing children on `<p:spPr>`.
fn pptx_shape_fill(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill : @xml.Element,
  extras : Array[@xml.Element],
) -> @xml.Element {
  let sp_pr_kids : Array[@xml.Node] = [
    Element(sp_xfrm(x, y, cx, cy)),
    Element(
      xe(NS_A, "prstGeom", [xa("prst", prst)], [
        Element(xe(NS_A, "avLst", [], [])),
      ]),
    ),
    Element(fill),
  ]
  for e in extras {
    sp_pr_kids.push(Element(e))
  }
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(xe(NS_PML, "spPr", [], sp_pr_kids)),
  ])
}

///|
fn extras_pml_shape(cases : Array[VisualCase]) -> Unit {
  // ---- effect / shadow / glow -------------------------------------
  // Drop-shadow under a rectangle — `<a:effectLst><a:outerShdw>`.
  cases.push({
    id: "shape-effect-shadow",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape_extra(
        "2",
        "Shadowed",
        "rect",
        "1828800",
        "1371600",
        "3657600",
        "2743200",
        "4472C4",
        [outer_shadow_effect("63500", "38100", "2700000", "404040")],
      ),
    ]),
  })
  // Coloured halo around an ellipse — `<a:effectLst><a:glow>`.
  cases.push({
    id: "shape-effect-glow",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape_extra(
        "2",
        "Glowing",
        "ellipse",
        "1828800",
        "1371600",
        "3657600",
        "2743200",
        "ED7D31",
        [glow_effect("114300", "FFC000")],
      ),
    ]),
  })

  // ---- 3D scene ---------------------------------------------------
  // `<a:scene3d>` + `<a:sp3d>` extrusion + top bevel on a rect.
  cases.push({
    id: "shape-3d-extrude",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape_extra(
        "2",
        "Extruded",
        "rect",
        "1828800",
        "1371600",
        "3657600",
        "2743200",
        "70AD47",
        scene3d_extras(),
      ),
    ]),
  })

  // ---- preset-dash outlines (dash / dot / dashDot / lgDash) -------
  // Four rects side-by-side, each with the same fill but a
  // different `<a:prstDash>` value on a thick outline so the
  // dash pattern is the dominant visual signal.
  let dash_styles = [
    ("Solid", "solid"),
    ("Dash", "dash"),
    ("Dot", "dot"),
    ("DashDot", "dashDot"),
    ("LgDash", "lgDash"),
    ("LgDashDot", "lgDashDot"),
    ("LgDashDotDot", "lgDashDotDot"),
    ("SysDash", "sysDash"),
  ]
  let dash_shapes : Array[@xml.Element] = []
  for i, ds in dash_styles {
    let (name, val) = ds
    let col = i % 4
    let row = i / 4
    let x = (457200 + col * 2057400).to_string()
    let y = (457200 + row * 1828800).to_string()
    dash_shapes.push(
      pptx_shape_extra(
        (i + 2).to_string(),
        name,
        "rect",
        x,
        y,
        "1828800",
        "1371600",
        "FFFFFF",
        [line_props("38100", "flat", "1F3864", [prst_dash(val)])],
      ),
    )
  }
  cases.push({
    id: "shape-outline-dashes",
    format: "pptx",
    category: "shape",
    content: sp_tree(dash_shapes),
  })

  // ---- line-width sweep -------------------------------------------
  // Hairline → very thick, six bars across — `<a:lnW>` from 6350
  // (1/4 pt) to 76200 (6 pt).
  let widths = ["6350", "12700", "19050", "25400", "38100", "76200"]
  let width_shapes : Array[@xml.Element] = []
  for i, w in widths {
    let x = (457200 + i * 1371600).to_string()
    width_shapes.push(
      pptx_shape_extra(
        (i + 2).to_string(),
        "W" + w,
        "rect",
        x,
        "2286000",
        "1143000",
        "1828800",
        "FFFFFF",
        [line_props(w, "flat", "1F3864", [])],
      ),
    )
  }
  cases.push({
    id: "shape-outline-widths",
    format: "pptx",
    category: "shape",
    content: sp_tree(width_shapes),
  })

  // ---- line caps --------------------------------------------------
  // Three identical-width strokes with `cap="flat"`, `"sq"`, `"rnd"`.
  // The geometry is a horizontal line preset so the cap is the
  // dominant difference.
  let caps = ["flat", "sq", "rnd"]
  let cap_shapes : Array[@xml.Element] = []
  for i, c in caps {
    let y = (914400 + i * 1371600).to_string()
    cap_shapes.push(
      xe(NS_PML, "sp", [], [
        Element(
          xe(NS_PML, "nvSpPr", [], [
            Element(
              xe(
                NS_PML,
                "cNvPr",
                [xa("id", (i + 2).to_string()), xa("name", "Cap_" + c)],
                [],
              ),
            ),
            Element(xe(NS_PML, "cNvSpPr", [], [])),
            Element(xe(NS_PML, "nvPr", [], [])),
          ]),
        ),
        Element(
          xe(NS_PML, "spPr", [], [
            Element(sp_xfrm("1828800", y, "5486400", "0")),
            Element(
              xe(NS_A, "prstGeom", [xa("prst", "line")], [
                Element(xe(NS_A, "avLst", [], [])),
              ]),
            ),
            Element(xe(NS_A, "noFill", [], [])),
            Element(line_props("76200", c, "1F3864", [])),
          ]),
        ),
      ]),
    )
  }
  cases.push({
    id: "shape-outline-caps",
    format: "pptx",
    category: "shape",
    content: sp_tree(cap_shapes),
  })

  // ---- arrow heads ------------------------------------------------
  // Four horizontal arrow-line presets with different head / tail
  // styles — triangle, stealth, oval, diamond.
  let arrow_styles = [
    ("Tri", "triangle"),
    ("Stealth", "stealth"),
    ("Oval", "oval"),
    ("Diamond", "diamond"),
  ]
  let arrow_shapes : Array[@xml.Element] = []
  for i, a in arrow_styles {
    let (label, t) = a
    let y = (457200 + i * 1143000).to_string()
    arrow_shapes.push(
      xe(NS_PML, "sp", [], [
        Element(
          xe(NS_PML, "nvSpPr", [], [
            Element(
              xe(
                NS_PML,
                "cNvPr",
                [xa("id", (i + 2).to_string()), xa("name", "Arrow_" + label)],
                [],
              ),
            ),
            Element(xe(NS_PML, "cNvSpPr", [], [])),
            Element(xe(NS_PML, "nvPr", [], [])),
          ]),
        ),
        Element(
          xe(NS_PML, "spPr", [], [
            Element(sp_xfrm("1828800", y, "5486400", "0")),
            Element(
              xe(NS_A, "prstGeom", [xa("prst", "line")], [
                Element(xe(NS_A, "avLst", [], [])),
              ]),
            ),
            Element(xe(NS_A, "noFill", [], [])),
            Element(
              line_props("38100", "flat", "C00000", [
                arrow_end("headEnd", t, "med", "med"),
                arrow_end("tailEnd", t, "med", "med"),
              ]),
            ),
          ]),
        ),
      ]),
    )
  }
  cases.push({
    id: "shape-arrowheads",
    format: "pptx",
    category: "shape",
    content: sp_tree(arrow_shapes),
  })

  // ---- rotation sweep ---------------------------------------------
  // Same rectangle at 0°, 30°, 60°, 90°, 120°, 150°, 180° — laid
  // out left-to-right.  `rot` is in 60000ths-of-a-degree (so 30° =
  // 1800000, 90° = 5400000, 180° = 10800000).
  let rots = [
    ("0", "0"),
    ("30", "1800000"),
    ("60", "3600000"),
    ("90", "5400000"),
    ("120", "7200000"),
    ("150", "9000000"),
    ("180", "10800000"),
  ]
  let rot_shapes : Array[@xml.Element] = []
  for i, r in rots {
    let (_, val) = r
    let x = (457200 + i * 1143000).to_string()
    rot_shapes.push(
      pptx_shape_xfrm(
        (i + 2).to_string(),
        "Rot_" + r.0,
        "rect",
        xfrm_rot(x, "2286000", "914400", "1143000", Some(val), false, false),
        "4472C4",
        [],
      ),
    )
  }
  cases.push({
    id: "shape-rotation-sweep",
    format: "pptx",
    category: "shape",
    content: sp_tree(rot_shapes),
  })

  // ---- flipH / flipV mirroring ------------------------------------
  // Same right-pointing arrow preset four times: as-is, flipH,
  // flipV, flipH+flipV.  Mirroring is encoded as `<a:xfrm flipH="1"
  // flipV="1">`; the geometry is otherwise identical.
  cases.push({
    id: "shape-flip-mirror",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape_xfrm(
        "2",
        "Normal",
        "rightArrow",
        xfrm_rot("457200", "457200", "1828800", "1371600", None, false, false),
        "4472C4",
        [],
      ),
      pptx_shape_xfrm(
        "3",
        "FlipH",
        "rightArrow",
        xfrm_rot("2743200", "457200", "1828800", "1371600", None, true, false),
        "ED7D31",
        [],
      ),
      pptx_shape_xfrm(
        "4",
        "FlipV",
        "rightArrow",
        xfrm_rot("457200", "2286000", "1828800", "1371600", None, false, true),
        "70AD47",
        [],
      ),
      pptx_shape_xfrm(
        "5",
        "FlipHV",
        "rightArrow",
        xfrm_rot("2743200", "2286000", "1828800", "1371600", None, true, true),
        "C00000",
        [],
      ),
    ]),
  })

  // ---- mixed: gradient/effect/outline -----------------------------
  // A roundRect with a thick dashed outline AND a drop shadow —
  // tests that multiple `<a:spPr>` siblings co-exist in the correct
  // schema order (xfrm → prstGeom → fill → ln → effectLst).
  cases.push({
    id: "shape-mixed-effects",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape_extra(
        "2",
        "Mixed",
        "roundRect",
        "1828800",
        "1371600",
        "5486400",
        "2743200",
        "70AD47",
        [
          line_props("50800", "flat", "1F3864", [prst_dash("dash")]),
          outer_shadow_effect("76200", "50800", "2700000", "404040"),
        ],
      ),
    ]),
  })

  // ---- alpha-modified srgbClr fill --------------------------------
  // Three overlapping ellipses at 50 % alpha — exercises the
  // `<a:srgbClr><a:alpha val="50000"/></a:srgbClr>` colour-mod path.
  cases.push({
    id: "shape-alpha-overlap",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape_fill(
        "2",
        "AlphaR",
        "ellipse",
        "1828800",
        "914400",
        "2743200",
        "2743200",
        solid_fill_alpha("C00000", "50000"),
        [],
      ),
      pptx_shape_fill(
        "3",
        "AlphaG",
        "ellipse",
        "3429000",
        "914400",
        "2743200",
        "2743200",
        solid_fill_alpha("00B050", "50000"),
        [],
      ),
      pptx_shape_fill(
        "4",
        "AlphaB",
        "ellipse",
        "2628900",
        "2286000",
        "2743200",
        "2743200",
        solid_fill_alpha("0070C0", "50000"),
        [],
      ),
    ]),
  })

  // ---- aspect-ratio sweep of ellipses -----------------------------
  // Same `cy` of 1828800, sweeping `cx` from 457200 (thin column)
  // to 4572000 (wide oval) so the renderer's ellipse path generator
  // is exercised at extreme aspect ratios.
  let ellipses_aspect : Array[@xml.Element] = []
  let widths_emu = [
    "457200", "914400", "1828800", "2743200", "3657600", "4572000",
  ]
  for i, w in widths_emu {
    let x = (457200 + i * 1371600).to_string()
    ellipses_aspect.push(
      pptx_shape(
        (i + 2).to_string(),
        "E_" + w,
        "ellipse",
        x,
        "2286000",
        w,
        "1828800",
        "4472C4",
      ),
    )
  }
  cases.push({
    id: "shape-ellipse-aspect-ratios",
    format: "pptx",
    category: "shape",
    content: sp_tree(ellipses_aspect),
  })

  // ---- triangle pointing in four directions -----------------------
  // Identical right-triangle preset at 0°, 90°, 180°, 270° to give
  // four cardinal pointing directions in a 2×2 grid.
  let tri_rot = [
    ("0", "0"),
    ("90", "5400000"),
    ("180", "10800000"),
    ("270", "16200000"),
  ]
  let tri_shapes : Array[@xml.Element] = []
  for i, r in tri_rot {
    let (_, val) = r
    let col = i % 2
    let row = i / 2
    let x = (1371600 + col * 3200400).to_string()
    let y = (457200 + row * 2286000).to_string()
    tri_shapes.push(
      pptx_shape_xfrm(
        (i + 2).to_string(),
        "Tri_" + r.0,
        "triangle",
        xfrm_rot(x, y, "1828800", "1828800", Some(val), false, false),
        "ED7D31",
        [],
      ),
    )
  }
  cases.push({
    id: "shape-triangle-directions",
    format: "pptx",
    category: "shape",
    content: sp_tree(tri_shapes),
  })

  // ---- group with own rotation AND child rotation -----------------
  // A `<p:grpSp>` rotated 30°; one child rotated −30° (so it appears
  // upright in screen space), and another at 0° (so it ends up
  // tilted by the group's 30°).  Tests that the group rotation
  // composes with the child rotation correctly.
  let inner_a = pptx_shape_xfrm(
    "3",
    "ChildCounterRot",
    "rect",
    xfrm_rot("0", "0", "2286000", "1371600", Some("19800000"), false, false), // −30° = 21600000 − 1800000
    "4472C4",
    [],
  )
  let inner_b = pptx_shape_xfrm(
    "4",
    "ChildNoRot",
    "rect",
    xfrm_rot("3200400", "914400", "2286000", "1371600", Some("0"), false, false),
    "ED7D31",
    [],
  )
  let group_rot = xe(NS_PML, "grpSp", [], [
    Element(
      xe(NS_PML, "nvGrpSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "GroupRot")], []),
        ),
        Element(xe(NS_PML, "cNvGrpSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "grpSpPr", [], [
        Element(
          xe(NS_A, "xfrm", [xa("rot", "1800000")], [ // group rot 30°
            Element(
              xe(NS_A, "off", [xa("x", "1828800"), xa("y", "1371600")], []),
            ),
            Element(
              xe(NS_A, "ext", [xa("cx", "5486400"), xa("cy", "2286000")], []),
            ),
            Element(xe(NS_A, "chOff", [xa("x", "0"), xa("y", "0")], [])),
            Element(
              xe(NS_A, "chExt", [xa("cx", "5486400"), xa("cy", "2286000")], []),
            ),
          ]),
        ),
      ]),
    ),
    Element(inner_a),
    Element(inner_b),
  ])
  cases.push({
    id: "shape-group-rotated",
    format: "pptx",
    category: "shape",
    content: sp_tree([group_rot]),
  })

  // ---- connector-style straight line with arrows ------------------
  // `<p:cxnSp>` would be the strictly-correct element for connectors,
  // but the renderer accepts `straightConnector1` on a `<p:sp>` and
  // resolves the geometry identically.  The fixture pairs two arrows
  // running between diagonal anchor points.
  cases.push({
    id: "shape-connector-arrows",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      xe(NS_PML, "sp", [], [
        Element(
          xe(NS_PML, "nvSpPr", [], [
            Element(
              xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Diag1")], []),
            ),
            Element(xe(NS_PML, "cNvSpPr", [], [])),
            Element(xe(NS_PML, "nvPr", [], [])),
          ]),
        ),
        Element(
          xe(NS_PML, "spPr", [], [
            Element(sp_xfrm("914400", "914400", "5486400", "3657600")),
            Element(
              xe(NS_A, "prstGeom", [xa("prst", "straightConnector1")], [
                Element(xe(NS_A, "avLst", [], [])),
              ]),
            ),
            Element(xe(NS_A, "noFill", [], [])),
            Element(
              line_props("50800", "flat", "1F3864", [
                arrow_end("tailEnd", "triangle", "lg", "lg"),
              ]),
            ),
          ]),
        ),
      ]),
      xe(NS_PML, "sp", [], [
        Element(
          xe(NS_PML, "nvSpPr", [], [
            Element(
              xe(NS_PML, "cNvPr", [xa("id", "3"), xa("name", "Diag2")], []),
            ),
            Element(xe(NS_PML, "cNvSpPr", [], [])),
            Element(xe(NS_PML, "nvPr", [], [])),
          ]),
        ),
        Element(
          xe(NS_PML, "spPr", [], [
            Element(
              xfrm_rot(
                "914400",
                "914400",
                "5486400",
                "3657600",
                None,
                false,
                true,
              ),
            ),
            Element(
              xe(NS_A, "prstGeom", [xa("prst", "straightConnector1")], [
                Element(xe(NS_A, "avLst", [], [])),
              ]),
            ),
            Element(xe(NS_A, "noFill", [], [])),
            Element(
              line_props("50800", "flat", "C00000", [
                arrow_end("tailEnd", "triangle", "lg", "lg"),
              ]),
            ),
          ]),
        ),
      ]),
    ]),
  })

  // ---- tiny diamond ladder ----------------------------------------
  // Eight diamonds in a vertical ladder with descending hues —
  // exercises preset-geometry pathing at small (~800px) cell size.
  let ladder_hex = [
    "C00000", "ED7D31", "FFC000", "70AD47", "4472C4", "7030A0", "ED7D31", "1F3864",
  ]
  let ladder_shapes : Array[@xml.Element] = []
  for i, h in ladder_hex {
    let y = (228600 + i * 685800).to_string()
    ladder_shapes.push(
      pptx_shape(
        (i + 2).to_string(),
        "D" + i.to_string(),
        "diamond",
        "4114800",
        y,
        "914400",
        "685800",
        h,
      ),
    )
  }
  cases.push({
    id: "shape-diamond-ladder",
    format: "pptx",
    category: "shape",
    content: sp_tree(ladder_shapes),
  })

  // ---- thin-outline + alpha fill (compound fill spec) -------------
  // Half-transparent green ellipse with a thin contrasting outline
  // — combines the alpha colour-mod with `<a:ln>`.
  cases.push({
    id: "shape-alpha-with-outline",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape_fill(
        "2",
        "AlphaOutlined",
        "ellipse",
        "1828800",
        "1371600",
        "4572000",
        "2743200",
        solid_fill_alpha("70AD47", "40000"),
        [line_props("19050", "flat", "1F3864", [prst_dash("solid")])],
      ),
    ]),
  })

  // ---- many small rotated stars -----------------------------------
  // 12 little 5-point stars at 12 different rotations around a
  // shared centre — visualises the rotation transform on a more
  // complex preset path than a rect.
  let star_shapes : Array[@xml.Element] = []
  for i in 0..<12 {
    let col = i % 4
    let row = i / 4
    let x = (457200 + col * 2057400).to_string()
    let y = (457200 + row * 1828800).to_string()
    let rot = (i * 1800000).to_string() // 30° step
    star_shapes.push(
      pptx_shape_xfrm(
        (i + 2).to_string(),
        "Star_" + i.to_string(),
        "star5",
        xfrm_rot(x, y, "1371600", "1371600", Some(rot), false, false),
        "FFC000",
        [],
      ),
    )
  }
  cases.push({
    id: "shape-star-rotation-grid",
    format: "pptx",
    category: "shape",
    content: sp_tree(star_shapes),
  })

  // ---- a 3D bevel-style cylinder + cube + can combination ---------
  // Three multi-layer preset shapes side-by-side, each with a top
  // bevel via `<a:sp3d>` — exercises the multi-path renderer with
  // the 3D scene metadata attached.
  cases.push({
    id: "shape-3d-trio",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape_extra(
        "2",
        "Cube3D",
        "cube",
        "457200",
        "1371600",
        "2286000",
        "2286000",
        "4472C4",
        scene3d_extras(),
      ),
      pptx_shape_extra(
        "3",
        "Can3D",
        "can",
        "3200400",
        "1371600",
        "1828800",
        "2286000",
        "ED7D31",
        scene3d_extras(),
      ),
      pptx_shape_extra(
        "4",
        "Bevel3D",
        "bevel",
        "5486400",
        "1371600",
        "2286000",
        "2286000",
        "70AD47",
        scene3d_extras(),
      ),
    ]),
  })
}
