// PresentationML connector and line fixtures.
//
// Focus areas (all under `category: "line"`):
//   • Stroke-only `line` preset rendered with every `<a:prstDash>`
//     pattern and across a sweep of stroke widths — verifies the
//     renderer's dash-array conversion and stroke-width pipeline.
//   • Same `line` exercised with every `<a:headEnd>` / `<a:tailEnd>`
//     arrowhead type plus the width × length sizing matrix — verifies
//     marker resolution at both ends.
//   • `<p:cxnSp>` connector shapes (`straightConnector1`,
//     `bentConnector2/3`, `curvedConnector2/3/4/5`) drawn between two
//     anchors so the connector-specific layout code is exercised
//     distinctly from the filled-preset path.
//   • Cap style (`flat` / `rnd` / `sq`) sweep, diagonal-line rotation
//     sweep, and a few compositional fixtures (chained connectors,
//     thick line with large arrowhead).
//
// Uses top-level helpers from `fixtures_helpers.mbt` (`pptx_shape_outline`,
// `sp_xfrm`, `solid_fill`, `sp_tree`, `preset_batch_outline`).  All
// `<p:cxnSp>` / per-line property variants are built locally so this
// file is self-contained — `fixtures_pml_extra.mbt` and
// `fixtures_pml_shape.mbt` own their own connector helpers under
// different names and must not be touched.

///|
/// Build a `<p:cxnSp>` (connector shape) with the given preset
/// geometry and an explicit `<a:ln>` configuration.  EMU coordinates;
/// stroke-only (the connector body itself never has a fill).  Each
/// arrow / dash arg is "" to omit that element entirely so the
/// generated XML stays minimal for the simple cases.
fn cxnsp(
  id_ : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  stroke_hex : String,
  stroke_width_emu : String,
  head_arrow : String,
  tail_arrow : String,
  dash : String,
) -> @xml.Element {
  let ln_kids : Array[@xml.Node] = [Element(solid_fill(stroke_hex))]
  if dash != "" {
    ln_kids.push(Element(xe(NS_A, "prstDash", [xa("val", dash)], [])))
  }
  if head_arrow != "" {
    ln_kids.push(
      Element(
        xe(
          NS_A,
          "headEnd",
          [xa("type", head_arrow), xa("w", "med"), xa("len", "med")],
          [],
        ),
      ),
    )
  }
  if tail_arrow != "" {
    ln_kids.push(
      Element(
        xe(
          NS_A,
          "tailEnd",
          [xa("type", tail_arrow), xa("w", "med"), xa("len", "med")],
          [],
        ),
      ),
    )
  }
  xe(NS_PML, "cxnSp", [], [
    Element(
      xe(NS_PML, "nvCxnSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", "Cxn" + id_)], []),
        ),
        Element(xe(NS_PML, "cNvCxnSpPr", [], [])),
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
        Element(xe(NS_A, "noFill", [], [])),
        Element(xe(NS_A, "ln", [xa("w", stroke_width_emu)], ln_kids)),
      ]),
    ),
  ])
}

///|
/// Build a stroke-only `<p:sp>` (using preset geometry `prst`) whose
/// `<a:ln>` carries an explicit width, dash style, head/tail arrow
/// configuration AND a cap style.  Empty `""` for any of dash /
/// head_arrow / tail_arrow / cap omits that element entirely.  Used
/// by the dash / arrow / width / cap grids — gives every cell its
/// own line configuration in a single helper.
fn line_sp(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  stroke_hex : String,
  stroke_width_emu : String,
  head_arrow : String,
  head_w : String,
  head_len : String,
  tail_arrow : String,
  tail_w : String,
  tail_len : String,
  dash : String,
  cap : String,
) -> @xml.Element {
  let ln_attrs : Array[@xml.Attribute] = [xa("w", stroke_width_emu)]
  if cap != "" {
    ln_attrs.push(xa("cap", cap))
  }
  let ln_kids : Array[@xml.Node] = [Element(solid_fill(stroke_hex))]
  if dash != "" {
    ln_kids.push(Element(xe(NS_A, "prstDash", [xa("val", dash)], [])))
  }
  if head_arrow != "" {
    ln_kids.push(
      Element(
        xe(
          NS_A,
          "headEnd",
          [xa("type", head_arrow), xa("w", head_w), xa("len", head_len)],
          [],
        ),
      ),
    )
  }
  if tail_arrow != "" {
    ln_kids.push(
      Element(
        xe(
          NS_A,
          "tailEnd",
          [xa("type", tail_arrow), xa("w", tail_w), xa("len", tail_len)],
          [],
        ),
      ),
    )
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
        Element(xe(NS_A, "noFill", [], [])),
        Element(xe(NS_A, "ln", ln_attrs, ln_kids)),
      ]),
    ),
  ])
}

///|
/// Same as `line_sp` but takes an explicit `<a:xfrm>` element so the
/// caller can attach `rot` / `flipH` / `flipV` attributes.  Used by
/// the diagonal-rotation fixture.
fn line_sp_xfrm(
  id_ : String,
  name : String,
  prst : String,
  xfrm : @xml.Element,
  stroke_hex : String,
  stroke_width_emu : String,
  head_arrow : String,
  tail_arrow : String,
  dash : String,
) -> @xml.Element {
  let ln_kids : Array[@xml.Node] = [Element(solid_fill(stroke_hex))]
  if dash != "" {
    ln_kids.push(Element(xe(NS_A, "prstDash", [xa("val", dash)], [])))
  }
  if head_arrow != "" {
    ln_kids.push(
      Element(
        xe(
          NS_A,
          "headEnd",
          [xa("type", head_arrow), xa("w", "med"), xa("len", "med")],
          [],
        ),
      ),
    )
  }
  if tail_arrow != "" {
    ln_kids.push(
      Element(
        xe(
          NS_A,
          "tailEnd",
          [xa("type", tail_arrow), xa("w", "med"), xa("len", "med")],
          [],
        ),
      ),
    )
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
        Element(xfrm),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", prst)], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(xe(NS_A, "noFill", [], [])),
        Element(xe(NS_A, "ln", [xa("w", stroke_width_emu)], ln_kids)),
      ]),
    ),
  ])
}

///|
fn extras_pml_lines(cases : Array[VisualCase]) -> Unit {
  // ===== 1. Dash-style grid =========================================
  // One horizontal line preset per `<a:prstDash>` value.  9 cells in a
  // 3×3 grid; stroke width fixed (25400 EMU ≈ 2pt) so each cell
  // differs only in dash pattern.
  let dashes = [
    "solid", "dash", "dot", "dashDot", "lgDash", "sysDash", "sysDot", "sysDashDot",
    "sysDashDotDot",
  ]
  let dash_shapes : Array[@xml.Element] = []
  for i, d in dashes {
    let col = i % 3
    let row = i / 3
    let x = (457200 + col * 2895600).to_string()
    let y = (914400 + row * 1828800).to_string()
    dash_shapes.push(
      line_sp(
        (i + 2).to_string(),
        "Dash_" + d,
        "line",
        x,
        y,
        "2514600",
        "1",
        "1F4E79",
        "25400",
        "",
        "med",
        "med",
        "",
        "med",
        "med",
        d,
        "",
      ),
    )
  }
  cases.push({
    id: "line-grid-dashes",
    format: "pptx",
    category: "line",
    content: sp_tree(dash_shapes),
  })

  // ===== 2. Width sweep =============================================
  // Six horizontal lines stacked vertically, identical except for
  // their `<a:ln w="">` value: 3175 / 6350 / 12700 / 25400 / 38100 /
  // 76200 EMU (~0.25 / 0.5 / 1 / 2 / 3 / 6 pt).
  let widths = ["3175", "6350", "12700", "25400", "38100", "76200"]
  let width_shapes : Array[@xml.Element] = []
  for i, w in widths {
    let y = (914400 + i * 914400).to_string()
    width_shapes.push(
      line_sp(
        (i + 2).to_string(),
        "W_" + w,
        "line",
        "914400",
        y,
        "7315200",
        "1",
        "1F4E79",
        w,
        "",
        "med",
        "med",
        "",
        "med",
        "med",
        "",
        "",
      ),
    )
  }
  cases.push({
    id: "line-grid-widths",
    format: "pptx",
    category: "line",
    content: sp_tree(width_shapes),
  })

  // ===== 3. Head-arrow grid =========================================
  // Six lines, each with a different `<a:headEnd type="">`.  Tail is
  // bare.  Lays out 3 columns × 2 rows.
  let heads = ["none", "triangle", "stealth", "diamond", "oval", "arrow"]
  let head_shapes : Array[@xml.Element] = []
  for i, h in heads {
    let col = i % 3
    let row = i / 3
    let x = (457200 + col * 2895600).to_string()
    let y = (914400 + row * 2743200).to_string()
    let head_t = if h == "none" { "" } else { h }
    head_shapes.push(
      line_sp(
        (i + 2).to_string(),
        "H_" + h,
        "line",
        x,
        y,
        "2514600",
        "1",
        "1F4E79",
        "38100",
        head_t,
        "med",
        "med",
        "",
        "med",
        "med",
        "",
        "",
      ),
    )
  }
  cases.push({
    id: "line-grid-arrows-head",
    format: "pptx",
    category: "line",
    content: sp_tree(head_shapes),
  })

  // ===== 4. Tail-arrow grid =========================================
  // Mirror of #3 with `<a:tailEnd>`.
  let tail_shapes : Array[@xml.Element] = []
  for i, t in heads {
    let col = i % 3
    let row = i / 3
    let x = (457200 + col * 2895600).to_string()
    let y = (914400 + row * 2743200).to_string()
    let tail_t = if t == "none" { "" } else { t }
    tail_shapes.push(
      line_sp(
        (i + 2).to_string(),
        "T_" + t,
        "line",
        x,
        y,
        "2514600",
        "1",
        "1F4E79",
        "38100",
        "",
        "med",
        "med",
        tail_t,
        "med",
        "med",
        "",
        "",
      ),
    )
  }
  cases.push({
    id: "line-grid-arrows-tail",
    format: "pptx",
    category: "line",
    content: sp_tree(tail_shapes),
  })

  // ===== 5. Both-ends arrow grid ====================================
  // Five lines with paired (head, tail) of distinct types — exercises
  // the renderer when both ends carry markers.
  let both_pairs = [
    ("triangle", "triangle"),
    ("stealth", "stealth"),
    ("diamond", "oval"),
    ("oval", "diamond"),
    ("arrow", "arrow"),
  ]
  let both_shapes : Array[@xml.Element] = []
  for i, p in both_pairs {
    let (h, t) = p
    let y = (914400 + i * 1066800).to_string()
    both_shapes.push(
      line_sp(
        (i + 2).to_string(),
        "B_" + h + "_" + t,
        "line",
        "914400",
        y,
        "7315200",
        "1",
        "1F4E79",
        "38100",
        h,
        "med",
        "med",
        t,
        "med",
        "med",
        "",
        "",
      ),
    )
  }
  cases.push({
    id: "line-grid-arrows-both",
    format: "pptx",
    category: "line",
    content: sp_tree(both_shapes),
  })

  // ===== 6. Arrow size sweep ========================================
  // Five `triangle` arrows on both ends sweeping the width × len
  // matrix: (sm,sm) (sm,med) (sm,lg) (med,med) (lg,lg).
  let sizes = [
    ("sm", "sm"),
    ("sm", "med"),
    ("sm", "lg"),
    ("med", "med"),
    ("lg", "lg"),
  ]
  let size_shapes : Array[@xml.Element] = []
  for i, s in sizes {
    let (w, ln) = s
    let y = (914400 + i * 1066800).to_string()
    size_shapes.push(
      line_sp(
        (i + 2).to_string(),
        "S_" + w + "_" + ln,
        "line",
        "914400",
        y,
        "7315200",
        "1",
        "1F4E79",
        "38100",
        "triangle",
        w,
        ln,
        "triangle",
        w,
        ln,
        "",
        "",
      ),
    )
  }
  cases.push({
    id: "line-arrows-sizes",
    format: "pptx",
    category: "line",
    content: sp_tree(size_shapes),
  })

  // ===== 7. Connector — bentConnector2 ==============================
  // Right-angle 2-segment elbow between (1in, 1in) and (8in, 5in).
  cases.push({
    id: "connector-bent2",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A", "ellipse", "685800", "685800", "457200", "457200", "C00000",
      ),
      pptx_shape(
        "3", "B", "ellipse", "7772400", "4572000", "457200", "457200", "1F4E79",
      ),
      cxnsp(
        "4", "bentConnector2", "914400", "914400", "7315200", "3886200", "1F4E79",
        "25400", "", "triangle", "",
      ),
    ]),
  })

  // ===== 8. Connector — bentConnector3 ==============================
  // 3-segment elbow with midpoint leg between two anchors.
  cases.push({
    id: "connector-bent3",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A", "ellipse", "685800", "685800", "457200", "457200", "C00000",
      ),
      pptx_shape(
        "3", "B", "ellipse", "7772400", "4572000", "457200", "457200", "1F4E79",
      ),
      cxnsp(
        "4", "bentConnector3", "914400", "914400", "7315200", "3886200", "1F4E79",
        "25400", "", "triangle", "",
      ),
    ]),
  })

  // ===== 9. Connector — curvedConnector2 ============================
  cases.push({
    id: "connector-curved2",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A", "ellipse", "685800", "685800", "457200", "457200", "C00000",
      ),
      pptx_shape(
        "3", "B", "ellipse", "7772400", "4572000", "457200", "457200", "1F4E79",
      ),
      cxnsp(
        "4", "curvedConnector2", "914400", "914400", "7315200", "3886200", "1F4E79",
        "25400", "", "triangle", "",
      ),
    ]),
  })

  // ===== 10. Connector — curvedConnector3 ===========================
  cases.push({
    id: "connector-curved3",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A", "ellipse", "685800", "685800", "457200", "457200", "C00000",
      ),
      pptx_shape(
        "3", "B", "ellipse", "7772400", "4572000", "457200", "457200", "1F4E79",
      ),
      cxnsp(
        "4", "curvedConnector3", "914400", "914400", "7315200", "3886200", "548235",
        "25400", "", "triangle", "",
      ),
    ]),
  })

  // ===== 11. Connector — curvedConnector4 ===========================
  cases.push({
    id: "connector-curved4",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A", "ellipse", "685800", "685800", "457200", "457200", "C00000",
      ),
      pptx_shape(
        "3", "B", "ellipse", "7772400", "4572000", "457200", "457200", "1F4E79",
      ),
      cxnsp(
        "4", "curvedConnector4", "914400", "914400", "7315200", "3886200", "BF8F00",
        "25400", "", "triangle", "",
      ),
    ]),
  })

  // ===== 12. Connector — curvedConnector5 ===========================
  cases.push({
    id: "connector-curved5",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A", "ellipse", "685800", "685800", "457200", "457200", "C00000",
      ),
      pptx_shape(
        "3", "B", "ellipse", "7772400", "4572000", "457200", "457200", "1F4E79",
      ),
      cxnsp(
        "4", "curvedConnector5", "914400", "914400", "7315200", "3886200", "C00000",
        "25400", "", "triangle", "",
      ),
    ]),
  })

  // ===== 13. Cap style sweep ========================================
  // Three thick lines (76200 EMU) with cap=flat / cap=rnd / cap=sq.
  // Width is generous so the cap shape is visible.
  let caps = ["flat", "rnd", "sq"]
  let cap_shapes : Array[@xml.Element] = []
  for i, c in caps {
    let y = (1371600 + i * 1828800).to_string()
    cap_shapes.push(
      line_sp(
        (i + 2).to_string(),
        "Cap_" + c,
        "line",
        "1371600",
        y,
        "6400800",
        "1",
        "1F4E79",
        "76200",
        "",
        "med",
        "med",
        "",
        "med",
        "med",
        "",
        c,
      ),
    )
  }
  cases.push({
    id: "line-cap-flat-vs-round",
    format: "pptx",
    category: "line",
    content: sp_tree(cap_shapes),
  })

  // ===== 14. Diagonal grid via rot ==================================
  // Five identical horizontal lines, each rotated by a different
  // amount via `<a:xfrm rot="">` (units = 1/60000 deg): 0, 30°, 45°,
  // 60°, 90° — i.e. 0, 1800000, 2700000, 3600000, 5400000.
  let rots = ["0", "1800000", "2700000", "3600000", "5400000"]
  let rot_shapes : Array[@xml.Element] = []
  for i, r in rots {
    // Lay out in a row across the slide; each line is a 1.5in
    // horizontal segment inside a square frame so the rotation pivots
    // around its centre.
    let col = i
    let x = (457200 + col * 1714500).to_string()
    let y = "2286000"
    let xfrm = xe(NS_A, "xfrm", [xa("rot", r)], [
      Element(xe(NS_A, "off", [xa("x", x), xa("y", y)], [])),
      Element(xe(NS_A, "ext", [xa("cx", "1371600"), xa("cy", "1371600")], [])),
    ])
    rot_shapes.push(
      line_sp_xfrm(
        (i + 2).to_string(),
        "Rot_" + r,
        "line",
        xfrm,
        "1F4E79",
        "38100",
        "",
        "triangle",
        "",
      ),
    )
  }
  cases.push({
    id: "line-diagonal-grid",
    format: "pptx",
    category: "line",
    content: sp_tree(rot_shapes),
  })

  // ===== 15. Zigzag chain of bent connectors ========================
  // Three `bentConnector3` connectors chained tip-to-tail to form a
  // Z-style zigzag — exercises connector layout when multiple bent
  // segments meet at the same point.
  cases.push({
    id: "connector-zigzag",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A1", "ellipse", "457200", "457200", "457200", "457200", "C00000",
      ),
      pptx_shape(
        "3", "A2", "ellipse", "3886200", "1828800", "457200", "457200", "BF8F00",
      ),
      pptx_shape(
        "4", "A3", "ellipse", "457200", "3200400", "457200", "457200", "548235",
      ),
      pptx_shape(
        "5", "A4", "ellipse", "3886200", "4572000", "457200", "457200", "1F4E79",
      ),
      cxnsp(
        "6", "bentConnector3", "685800", "685800", "3200400", "1371600", "404040",
        "25400", "", "triangle", "",
      ),
      cxnsp(
        "7", "bentConnector3", "685800", "2057400", "3200400", "1371600", "404040",
        "25400", "", "triangle", "",
      ),
      cxnsp(
        "8", "bentConnector3", "685800", "3429000", "3200400", "1371600", "404040",
        "25400", "", "triangle", "",
      ),
    ]),
  })

  // ===== 16. Thick stroke + large arrowhead =========================
  // Single horizontal line with a wide stroke (101600 EMU ≈ 8pt) and
  // a `triangle` arrow at width=lg, length=lg on the tail end.
  cases.push({
    id: "line-thick-with-arrows",
    format: "pptx",
    category: "line",
    content: sp_tree([
      line_sp(
        "2", "ThickArrow", "line", "914400", "3200400", "7315200", "1", "C00000",
        "101600", "triangle", "lg", "lg", "triangle", "lg", "lg", "", "flat",
      ),
    ]),
  })

  // ===== 17. straightConnector1 between anchors =====================
  // A simple `straightConnector1` `<p:cxnSp>` between two anchors so
  // the connector path (distinct from the filled `line` preset) is
  // also exercised in this category.
  cases.push({
    id: "connector-straight",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A", "ellipse", "685800", "685800", "457200", "457200", "C00000",
      ),
      pptx_shape(
        "3", "B", "ellipse", "7772400", "4572000", "457200", "457200", "1F4E79",
      ),
      cxnsp(
        "4", "straightConnector1", "914400", "914400", "7315200", "3886200", "1F4E79",
        "25400", "", "triangle", "",
      ),
    ]),
  })

  // ===== 18. Dashed connector =======================================
  // `straightConnector1` with `prstDash="dash"` plus arrows — verifies
  // dash + arrowhead interaction on connector path.
  cases.push({
    id: "connector-dashed-with-arrows",
    format: "pptx",
    category: "line",
    content: sp_tree([
      pptx_shape(
        "2", "A", "rect", "457200", "457200", "1371600", "914400", "DEEBF7",
      ),
      pptx_shape(
        "3", "B", "rect", "7315200", "4572000", "1371600", "914400", "FCE4D6",
      ),
      cxnsp(
        "4", "straightConnector1", "1828800", "914400", "5486400", "4114800", "1F4E79",
        "38100", "oval", "triangle", "dash",
      ),
    ]),
  })
}
