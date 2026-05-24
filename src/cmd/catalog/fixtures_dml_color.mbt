// DrawingML colour-pipeline fixtures.
//
// Exercises every flavour of colour the DrawingML fill pipeline must
// understand:
//   • <a:schemeClr val="bg1|tx1|accent1..6|hlink|folHlink"> — without
//     a theme part the renderer must use the documented fallbacks
//     (bg1=white, tx1=black, accent1..6 = the canonical Office hues).
//   • <a:srgbClr> with single child modifiers — tint, shade, lumMod,
//     lumOff, satMod, satOff, alpha.
//   • <a:srgbClr> with combined modifiers — lumMod+lumOff (the most
//     common Office authoring pattern) and tint+alpha.
//   • Colour ladders — 5-step monotonic ramps for tint, shade, alpha
//     so a regression in the modifier maths is visible as a kink in
//     the gradient.
//   • <a:prstClr> — named CSS-style colours.
//   • <a:sysClr> — system-colour aliases with lastClr fallback.
//
// All fixtures live under .snapshots/fixtures/pptx/color/.  Each is
// self-contained: no theme part is shipped so the renderer must hit
// its fallback colour table.

///|
/// Build a `<a:solidFill>` whose payload is a single `<a:schemeClr>`
/// with the given scheme-colour name (`bg1`, `tx1`, `accent3`, …).
/// Used by the scheme-colour fixtures; the renderer must resolve the
/// name against either the document theme (absent here) or its
/// built-in fallback table.
fn scheme_color(scheme_name : String) -> @xml.Element {
  xe(NS_A, "solidFill", [], [
    Element(xe(NS_A, "schemeClr", [xa("val", scheme_name)], [])),
  ])
}

///|
/// Build a `<a:solidFill>` wrapping `<a:srgbClr val="hex">` with an
/// arbitrary list of modifier children (`<a:tint>`, `<a:lumMod>`, …).
/// Modifiers are applied in document order per ECMA-376 §20.1.2.3.
fn srgb_with_mods(hex : String, mods : Array[@xml.Element]) -> @xml.Element {
  let mod_nodes : Array[@xml.Node] = []
  for m in mods {
    mod_nodes.push(Element(m))
  }
  xe(NS_A, "solidFill", [], [
    Element(xe(NS_A, "srgbClr", [xa("val", hex)], mod_nodes)),
  ])
}

///|
/// Build a `<a:solidFill>` wrapping a `<a:prstClr val="name">` —
/// the DrawingML preset-named colour palette (`red`, `aliceBlue`, …).
fn preset_color(name : String) -> @xml.Element {
  xe(NS_A, "solidFill", [], [
    Element(xe(NS_A, "prstClr", [xa("val", name)], [])),
  ])
}

///|
/// Build a `<a:solidFill>` wrapping `<a:sysClr val="name"
/// lastClr="hex">` — system-colour alias plus the fallback `lastClr`
/// renderers without OS palette access must use.
fn sys_color(name : String, last_clr : String) -> @xml.Element {
  xe(NS_A, "solidFill", [], [
    Element(xe(NS_A, "sysClr", [xa("val", name), xa("lastClr", last_clr)], [])),
  ])
}

///|
/// Build a `<p:sp>` with preset geometry positioned at (x,y) with
/// extent (cx,cy) and an externally-built `<a:solidFill>` element.
/// Lets every fixture in this file pick a custom fill payload
/// (`schemeClr`, `srgbClr`+mods, `prstClr`, `sysClr`).
fn shape_with_fill(
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
/// Single-shape full-slide fixture content — one big rectangle
/// filled with `fill`, sized to ~80% of the slide canvas so the
/// fill is obvious in screenshots.  Used by `color-scheme-*` and
/// `color-mod-*` fixtures.
fn solo_color_swatch(fill : @xml.Element, name : String) -> @xml.Element {
  sp_tree([
    shape_with_fill(
      "2", name, "rect", "914400", "914400", "7315200", "5029200", fill,
    ),
  ])
}

///|
/// Lay out N swatches horizontally across the slide, each filled by
/// `fills[i]`.  Used by ladder fixtures (`color-tint-ladder`, etc.)
/// and the prstClr grid.  Cell width = 8229600/N, height = 5029200.
fn swatch_row(fills : Array[@xml.Element]) -> @xml.Element {
  let n = fills.length()
  let avail_w = 8229600
  let gap = 76200
  let cell_w = (avail_w - gap * (n - 1)) / n
  let shapes : Array[@xml.Element] = []
  for i, fill in fills {
    let x = (457200 + i * (cell_w + gap)).to_string()
    shapes.push(
      shape_with_fill(
        (i + 2).to_string(),
        "S" + i.to_string(),
        "rect",
        x,
        "914400",
        cell_w.to_string(),
        "5029200",
        fill,
      ),
    )
  }
  sp_tree(shapes)
}

///|
/// Lay out N swatches as a grid (cols × rows) auto-sized to the
/// slide canvas.  Used for the prstClr palette (which needs more
/// swatches than a single row can fit) and the sysClr pair.
fn swatch_grid(fills : Array[@xml.Element], cols : Int) -> @xml.Element {
  let n = fills.length()
  let rows = (n + cols - 1) / cols
  let avail_w = 8229600
  let avail_h = 5943600
  let gap = 76200
  let cell_w = (avail_w - gap * (cols - 1)) / cols
  let cell_h = (avail_h - gap * (rows - 1)) / rows
  let shapes : Array[@xml.Element] = []
  for i, fill in fills {
    let col = i % cols
    let row = i / cols
    let x = (457200 + col * (cell_w + gap)).to_string()
    let y = (457200 + row * (cell_h + gap)).to_string()
    shapes.push(
      shape_with_fill(
        (i + 2).to_string(),
        "S" + i.to_string(),
        "rect",
        x,
        y,
        cell_w.to_string(),
        cell_h.to_string(),
        fill,
      ),
    )
  }
  sp_tree(shapes)
}

///|
fn extras_dml_color(cases : Array[VisualCase]) -> Unit {
  // ===== Scheme colour resolution ===================================
  // Without a theme part the renderer falls back to:
  //   bg1 = FFFFFF (white background)
  //   tx1 = 000000 (black text)
  //   accent1..6 = 4472C4 ED7D31 A5A5A5 FFC000 5B9BD5 70AD47
  //   hlink     = 0563C1
  //   folHlink  = 954F72
  // Each fixture in this group is a single big rectangle filled with
  // one scheme colour so visual regressions are obvious.

  cases.push({
    id: "color-scheme-bg1",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("bg1"), "Bg1"),
  })

  cases.push({
    id: "color-scheme-tx1",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("tx1"), "Tx1"),
  })

  cases.push({
    id: "color-scheme-accent1",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("accent1"), "Accent1"),
  })

  cases.push({
    id: "color-scheme-accent2",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("accent2"), "Accent2"),
  })

  cases.push({
    id: "color-scheme-accent3",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("accent3"), "Accent3"),
  })

  cases.push({
    id: "color-scheme-accent4",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("accent4"), "Accent4"),
  })

  cases.push({
    id: "color-scheme-accent5",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("accent5"), "Accent5"),
  })

  cases.push({
    id: "color-scheme-accent6",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("accent6"), "Accent6"),
  })

  cases.push({
    id: "color-scheme-hlink",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("hlink"), "HLink"),
  })

  cases.push({
    id: "color-scheme-folHlink",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(scheme_color("folHlink"), "FolHLink"),
  })

  // ---- Side-by-side board of every accent + bg/tx in one slide ----
  // Easier to eyeball: if the renderer mis-maps one accent slot the
  // whole row breaks the visual rhythm.
  cases.push({
    id: "color-scheme-accent-board",
    format: "pptx",
    category: "color",
    content: swatch_grid(
      [
        scheme_color("accent1"),
        scheme_color("accent2"),
        scheme_color("accent3"),
        scheme_color("accent4"),
        scheme_color("accent5"),
        scheme_color("accent6"),
        scheme_color("hlink"),
        scheme_color("folHlink"),
      ],
      4,
    ),
  })

  // ===== srgbClr with a single modifier =============================
  // Base colour is the canonical Office accent1 blue (4472C4).  Each
  // fixture applies exactly one modifier so a regression in any one
  // modifier is isolated.

  let blue = "4472C4"

  // tint(50%) — interpolate toward white.  Renderer must end up near
  // ~A0B6E1.
  cases.push({
    id: "color-mod-tint",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [xe(NS_A, "tint", [xa("val", "50000")], [])]),
      "Tint50",
    ),
  })

  // shade(50%) — interpolate toward black (~223362).
  cases.push({
    id: "color-mod-shade",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [xe(NS_A, "shade", [xa("val", "50000")], [])]),
      "Shade50",
    ),
  })

  // lumMod(75%) — multiply HSL luminance by 0.75.
  cases.push({
    id: "color-mod-lumMod",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [xe(NS_A, "lumMod", [xa("val", "75000")], [])]),
      "LumMod75",
    ),
  })

  // lumOff(+25%) — add 0.25 to HSL luminance (clamped to 1).
  cases.push({
    id: "color-mod-lumOff",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [xe(NS_A, "lumOff", [xa("val", "25000")], [])]),
      "LumOff25",
    ),
  })

  // satMod(150%) — multiply HSL saturation by 1.5 (clamped).
  cases.push({
    id: "color-mod-satMod",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [xe(NS_A, "satMod", [xa("val", "150000")], [])]),
      "SatMod150",
    ),
  })

  // satOff(-25%) — subtract 0.25 from HSL saturation.
  cases.push({
    id: "color-mod-satOff",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [xe(NS_A, "satOff", [xa("val", "-25000")], [])]),
      "SatOffNeg25",
    ),
  })

  // alpha(50%) — render with 50% opacity over the white slide;
  // result reads as a pale blue.
  cases.push({
    id: "color-mod-alpha",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [xe(NS_A, "alpha", [xa("val", "50000")], [])]),
      "Alpha50",
    ),
  })

  // ===== srgbClr with combined modifiers ============================

  // lumMod + lumOff — Office's canonical "tinted accent" formula.
  // For "60% lighter accent1" Office emits lumMod=40000 + lumOff=60000.
  cases.push({
    id: "color-mod-lumMod-lumOff",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [
        xe(NS_A, "lumMod", [xa("val", "40000")], []),
        xe(NS_A, "lumOff", [xa("val", "60000")], []),
      ]),
      "LumMod40LumOff60",
    ),
  })

  // tint + alpha — semi-transparent tinted swatch.
  cases.push({
    id: "color-mod-tint-alpha",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      srgb_with_mods(blue, [
        xe(NS_A, "tint", [xa("val", "60000")], []),
        xe(NS_A, "alpha", [xa("val", "60000")], []),
      ]),
      "Tint60Alpha60",
    ),
  })

  // ===== Ladders ====================================================
  // 5-step monotonic ramps.  A bug in modifier maths becomes visible
  // as either a flipped direction or a non-monotonic step.

  cases.push({
    id: "color-tint-ladder",
    format: "pptx",
    category: "color",
    content: swatch_row([
      srgb_with_mods(blue, [xe(NS_A, "tint", [xa("val", "20000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "tint", [xa("val", "40000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "tint", [xa("val", "60000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "tint", [xa("val", "80000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "tint", [xa("val", "100000")], [])]),
    ]),
  })

  cases.push({
    id: "color-shade-ladder",
    format: "pptx",
    category: "color",
    content: swatch_row([
      srgb_with_mods(blue, [xe(NS_A, "shade", [xa("val", "20000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "shade", [xa("val", "40000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "shade", [xa("val", "60000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "shade", [xa("val", "80000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "shade", [xa("val", "100000")], [])]),
    ]),
  })

  cases.push({
    id: "color-alpha-ladder",
    format: "pptx",
    category: "color",
    content: swatch_row([
      srgb_with_mods(blue, [xe(NS_A, "alpha", [xa("val", "20000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "alpha", [xa("val", "40000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "alpha", [xa("val", "60000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "alpha", [xa("val", "80000")], [])]),
      srgb_with_mods(blue, [xe(NS_A, "alpha", [xa("val", "100000")], [])]),
    ]),
  })

  // ===== Preset (named) colours =====================================
  // The DrawingML `<a:prstClr>` palette maps directly to CSS named
  // colours.  A 4×3 grid sampling a mix of primaries, pastels, and
  // muted tones gives a quick eye-pass for the name→hex table.
  cases.push({
    id: "color-preset-named",
    format: "pptx",
    category: "color",
    content: swatch_grid(
      [
        preset_color("red"),
        preset_color("green"),
        preset_color("blue"),
        preset_color("yellow"),
        preset_color("orange"),
        preset_color("purple"),
        preset_color("aliceBlue"),
        preset_color("cornflowerBlue"),
        preset_color("lavender"),
        preset_color("salmon"),
        preset_color("seaGreen"),
        preset_color("slateGray"),
      ],
      4,
    ),
  })

  // ===== System colours =============================================
  // `<a:sysClr>` aliases an OS palette slot.  Headless renderers
  // must obey the `lastClr` fallback.

  // `windowText` — typically black; lastClr=000000.  Use a swatch
  // that fills most of the slide so the colour is unmistakable.
  cases.push({
    id: "color-sys-windowtext",
    format: "pptx",
    category: "color",
    content: solo_color_swatch(
      sys_color("windowText", "000000"),
      "SysWindowText",
    ),
  })

  // `window` — typically white; lastClr=FFFFFF.  Pair with a thin
  // dark border so an all-white slide is still visible in diffs.
  cases.push({
    id: "color-sys-window",
    format: "pptx",
    category: "color",
    content: sp_tree([
      // Black backing strip — without this an all-white slide is
      // indistinguishable from an empty render.
      shape_with_fill(
        "2",
        "Backstop",
        "rect",
        "457200",
        "457200",
        "8229600",
        "5943600",
        sys_color("windowText", "000000"),
      ),
      shape_with_fill(
        "3",
        "SysWindow",
        "rect",
        "914400",
        "914400",
        "7315200",
        "5029200",
        sys_color("window", "FFFFFF"),
      ),
    ]),
  })
}
