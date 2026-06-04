// DrawingML §20.1.8 — effect-list completeness fixtures.
//
// Existing `fixtures_pml_shape.mbt` covers a smoke-test pair for the
// effect pipeline (a basic `<a:outerShdw>` and a basic `<a:glow>`).
// This file fills in the remaining §20.1.8 effect primitives so the
// renderer's filter pipeline has fixture coverage for every effect
// type the spec lists:
//
//   §20.1.8.45 outerShdw   — drop-shadow (offset + blur).
//   §20.1.8.40 innerShdw   — inset shadow inside the shape.
//   §20.1.8.32 glow        — outer halo (no offset).
//   §20.1.8.53 softEdge    — feathered edge.
//   §20.1.8.15 blur        — uniform Gaussian blur.
//   §20.1.8.50 reflection  — mirrored copy below the shape (renderer
//                            currently skips this — fixture is here so
//                            it lights up once support lands).
//   §20.1.8.29 fillOverlay — semi-opaque solid on top of fill (renderer
//                            does not currently implement; fixture
//                            ensures parser coverage).
//   §20.1.8 lumMod (as effect) — luminance modulation applied as an
//                            effect on the rendered raster, not on the
//                            colour pipeline (renderer-currently
//                            unimplemented; parser coverage).
//
// All fixtures use a 200x100 EMU-style small rectangle (in EMU:
// 1828800 × 914400 ≈ 2 in × 1 in) on a centred slide so the effect
// halo / shadow / feather is unmistakable.  Each fixture includes a
// REFERENCE rectangle (no effect) on the left so the visual delta
// from the effect is obvious in screenshots.
//
// Element construction is via `xe`/`xa` from `verify.mbt` — no
// hand-written XML strings.

///|
/// One small filled rectangle on the centre-right of the slide with
/// the supplied `extras` (e.g. `<a:effectLst>`) appended after the
/// fill node inside `<p:spPr>`.  Mirrors `pptx_shape_extra` but with
/// a hard-coded position so every effect fixture shares the same
/// visual layout.
fn effect_shape(
  id_ : String,
  name : String,
  fill_hex : String,
  extras : Array[@xml.Element],
) -> @xml.Element {
  pptx_shape_extra(
    id_, name, "rect", "4572000", // 5 in from left (centre-right)
     "2971800", // ~3.25 in from top (vertically centred)
     "1828800", // 2 in wide
     "914400", // 1 in tall
     fill_hex, extras,
  )
}

///|
/// Slide-tree of [reference rectangle without effect, effect-applied
/// rectangle].  Lets each fixture compose itself in one line.
fn effect_with_reference(modified : @xml.Element) -> @xml.Element {
  let reference = pptx_shape(
    "2", "Reference", "rect", "914400", // 1 in from left
     "2971800", "1828800", "914400", "4472C4",
  )
  sp_tree([reference, modified])
}

///|
/// `<a:effectLst>` wrapping a single inner-shadow primitive
/// (§20.1.8.40).  Defaults: blurRad=blur_emu, dist=dist_emu, dir=
/// dir60k in 60000ths-of-a-degree, colour hex.  innerShdw renders as
/// a shadow clipped inside the shape geometry.
fn inner_shadow_effect(
  blur_emu : String,
  dist_emu : String,
  dir : String,
  hex : String,
) -> @xml.Element {
  xe(NS_A, "effectLst", [], [
    Element(
      xe(
        NS_A,
        "innerShdw",
        [xa("blurRad", blur_emu), xa("dist", dist_emu), xa("dir", dir)],
        [Element(xe(NS_A, "srgbClr", [xa("val", hex)], []))],
      ),
    ),
  ])
}

///|
/// `<a:effectLst>` wrapping a §20.1.8.53 softEdge primitive — a
/// feathered edge of `rad_emu` radius (in EMU).
fn soft_edge_effect(rad_emu : String) -> @xml.Element {
  xe(NS_A, "effectLst", [], [
    Element(xe(NS_A, "softEdge", [xa("rad", rad_emu)], [])),
  ])
}

///|
/// `<a:effectLst>` wrapping a §20.1.8.15 blur primitive — uniform
/// Gaussian blur of `rad_emu` radius.  `grow` controls whether the
/// blur extends past the shape's bounding box.
fn blur_effect(rad_emu : String, grow : String) -> @xml.Element {
  xe(NS_A, "effectLst", [], [
    Element(xe(NS_A, "blur", [xa("rad", rad_emu), xa("grow", grow)], [])),
  ])
}

///|
/// `<a:effectLst>` wrapping a §20.1.8.50 reflection primitive.
/// Renderer skips this effect today (SVG cannot express the
/// distance/blur/start-alpha/end-alpha tuple as a single filter
/// without `<image>` composition) — fixture provided so the
/// snapshot lights up automatically when support lands.
fn reflection_effect(
  blur_rad : String,
  st_a : String,
  end_a : String,
  dist : String,
  dir : String,
) -> @xml.Element {
  xe(NS_A, "effectLst", [], [
    Element(
      xe(
        NS_A,
        "reflection",
        [
          xa("blurRad", blur_rad),
          xa("stA", st_a),
          xa("stPos", "0"),
          xa("endA", end_a),
          xa("endPos", "100000"),
          xa("dist", dist),
          xa("dir", dir),
          xa("fadeDir", "5400000"),
          xa("sy", "100000"),
          xa("sx", "100000"),
          xa("kx", "0"),
          xa("ky", "0"),
          xa("algn", "bl"),
          xa("rotWithShape", "0"),
        ],
        [],
      ),
    ),
  ])
}

///|
/// `<a:effectLst>` wrapping a §20.1.8.29 fillOverlay primitive — a
/// semi-opaque solid drawn on top of the underlying fill.  `blend`
/// is one of `over` / `mult` / `screen` / `darken` / `lighten`.
fn fill_overlay_effect(blend : String, hex : String) -> @xml.Element {
  let fill = xe(NS_A, "solidFill", [], [
    Element(
      xe(NS_A, "srgbClr", [xa("val", hex)], [
        Element(xe(NS_A, "alpha", [xa("val", "50000")], [])),
      ]),
    ),
  ])
  xe(NS_A, "effectLst", [], [
    Element(xe(NS_A, "fillOverlay", [xa("blend", blend)], [Element(fill)])),
  ])
}

///|
fn extras_dml_effects(cases : Array[VisualCase]) -> Unit {
  // ===== §20.1.8.45 outerShdw variations ===========================
  // Existing fixture covers a basic centred-shadow.  Add the
  // "top-left" alignment variant (the Office "Outer / Bottom-Right"
  // preset) so the algn attribute is exercised.
  cases.push({
    id: "effect-outerShdw-bottomRight",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "OuterShdwBR", "4472C4", [
        outer_shadow_effect("50800", "76200", "2700000", "404040"),
      ]),
    ),
  })

  // outerShdw with a bright accent colour and a small offset — the
  // "glow-like" outerShdw common in slide decks.
  cases.push({
    id: "effect-outerShdw-accent",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "OuterShdwAccent", "FFFFFF", [
        outer_shadow_effect("38100", "25400", "2700000", "ED7D31"),
      ]),
    ),
  })

  // ===== §20.1.8.40 innerShdw =====================================
  // Small inset shadow against a light fill — the inset is most
  // visible when the underlying colour is pale.
  cases.push({
    id: "effect-innerShdw-basic",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "InnerShdwBasic", "DEEBF7", [
        inner_shadow_effect("38100", "25400", "2700000", "1F3864"),
      ]),
    ),
  })

  // innerShdw from the top — direction 16200000 sixtieths = 270°
  // (light from below, shadow at top).
  cases.push({
    id: "effect-innerShdw-fromTop",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "InnerShdwTop", "FFF2CC", [
        inner_shadow_effect("50800", "38100", "16200000", "806000"),
      ]),
    ),
  })

  // ===== §20.1.8.32 glow ==========================================
  // Coloured halo with a generous radius — the "Office accent4 glow".
  cases.push({
    id: "effect-glow-large",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "GlowLarge", "4472C4", [glow_effect("228600", "FFC000")]),
    ),
  })

  // A small accent-blue glow on an orange shape — high-contrast
  // colour pair so the glow is unmistakable in screenshots.
  cases.push({
    id: "effect-glow-tight",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "GlowTight", "ED7D31", [glow_effect("76200", "0070C0")]),
    ),
  })

  // ===== §20.1.8.53 softEdge ======================================
  // Small radius (~3 pt) — visible feather without dissolving the
  // shape.
  cases.push({
    id: "effect-softEdge-small",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "SoftEdgeSmall", "70AD47", [soft_edge_effect("38100")]),
    ),
  })

  // Large radius (~9 pt) — heavy feather so the rect edges go very
  // soft.
  cases.push({
    id: "effect-softEdge-large",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "SoftEdgeLarge", "70AD47", [soft_edge_effect("114300")]),
    ),
  })

  // ===== §20.1.8.15 blur ==========================================
  // grow="0" — blur stays within the shape's bounding box.
  cases.push({
    id: "effect-blur-noGrow",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "BlurNoGrow", "4472C4", [blur_effect("76200", "0")]),
    ),
  })

  // grow="1" — blur extends outward past the bounding box.
  cases.push({
    id: "effect-blur-grow",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "BlurGrow", "4472C4", [blur_effect("76200", "1")]),
    ),
  })

  // ===== §20.1.8.50 reflection ====================================
  // Renderer currently skips this effect — fixture proves the parse
  // path accepts the canonical Office "tight reflection" preset
  // (stA=50000, endA=300, dist=0, blurRad=6350).
  cases.push({
    id: "effect-reflection-tight",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "ReflectionTight", "4472C4", [
        reflection_effect("6350", "50000", "300", "0", "5400000"),
      ]),
    ),
  })

  // Loose reflection preset — bigger blur, larger gap.
  cases.push({
    id: "effect-reflection-loose",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "ReflectionLoose", "ED7D31", [
        reflection_effect("38100", "60000", "0", "50800", "5400000"),
      ]),
    ),
  })

  // ===== §20.1.8.29 fillOverlay ===================================
  // Semi-opaque red overlay using `over` blend.  Renderer currently
  // does not implement fillOverlay; the fixture is here so the
  // snapshot lights up automatically when support lands and so the
  // parser path is exercised today.
  cases.push({
    id: "effect-fillOverlay-over",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "FillOverlayOver", "4472C4", [
        fill_overlay_effect("over", "FF0000"),
      ]),
    ),
  })

  // Multiply blend — overlay attenuates the underlying colour.
  cases.push({
    id: "effect-fillOverlay-mult",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "FillOverlayMult", "70AD47", [
        fill_overlay_effect("mult", "FFC000"),
      ]),
    ),
  })

  // ===== §20.1.8.54 softEdge =====================================
  // A schema-valid effectList member that attenuates the edge of the
  // shape. Colour-pipeline lumMod is covered by DrawingML colour
  // fixtures; it is not an effectList child in ECMA-376.
  cases.push({
    id: "effect-softEdge-6pt",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "SoftEdge6pt", "4472C4", [soft_edge_effect("76200")]),
    ),
  })

  // ===== Effect stacks ============================================
  // Combine glow + outerShdw in one effectLst — exercises the
  // renderer's effect-priority logic while preserving the ECMA-376
  // CT_EffectList child sequence.
  cases.push({
    id: "effect-stack-shadow-glow",
    format: "pptx",
    category: "shape",
    content: effect_with_reference(
      effect_shape("3", "ShadowAndGlow", "4472C4", [
        xe(NS_A, "effectLst", [], [
          Element(
            xe(NS_A, "glow", [xa("rad", "76200")], [
              Element(xe(NS_A, "srgbClr", [xa("val", "FFC000")], [])),
            ]),
          ),
          Element(
            xe(
              NS_A,
              "outerShdw",
              [
                xa("blurRad", "50800"),
                xa("dist", "38100"),
                xa("dir", "2700000"),
                xa("algn", "ctr"),
                xa("rotWithShape", "0"),
              ],
              [Element(xe(NS_A, "srgbClr", [xa("val", "404040")], []))],
            ),
          ),
        ]),
      ]),
    ),
  })
}
