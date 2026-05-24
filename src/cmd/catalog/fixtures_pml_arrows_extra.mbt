// Extra PML preset arrow fixtures — covers the spec's bent /
// notched / striped / circular arrow family (ECMA-376 §20.1.10.56)
// that the in-tree `shape-arrows{,-curved}` fixtures do not include.
//
// Why these are split out:
//   • They render through `preset_shapes_arrow.mbt` paths that
//     previously had no visual coverage, so any geometry regression
//     there shows up immediately as an RMSE spike on these fixtures.
//   • Keeping arrow extensions in their own file lets contributors
//     iterate on arrow geometry without touching the existing
//     `shape-arrows{,-curved}` fixtures (and their cached references).
//
// Each fixture uses `preset_batch` from `fixtures_helpers.mbt` to
// arrange a 4-column grid of shape boxes at 1828800 × 1371600 EMU
// each (matching the existing `shape-arrows{,-curved}` layout) so
// the visual snapshot is comparable across the family.

///|
fn extras_pml_arrows_extra(cases : Array[VisualCase]) -> Unit {
  // ---- 1. Bent / U-turn arrow family ------------------------------
  // The `bent*` and `uturn` arrows are POLYGONAL — built from
  // straight edges only — so they exercise the line-segment path
  // builder in `preset_shapes_arrow.mbt`.  Pairing them in one
  // fixture lets the snapshot catch any directional / orientation
  // regression in a single comparison.
  cases.push({
    id: "shape-arrows-bent",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "bentArrow", "bentUpArrow", "uturnArrow", "leftUpArrow", "leftRightUpArrow",
      ],
      "5B9BD5",
    ),
  })

  // ---- 2. Notched / striped / chevron arrows ---------------------
  // These add a notch (`notchedRightArrow`), parallel stripes
  // (`stripedRightArrow`), or a chevron tail (`chevron`,
  // `homePlate`) to the base right-pointing arrow.  Useful for
  // catching incorrect notch-depth or stripe-spacing in our path
  // builder.
  cases.push({
    id: "shape-arrows-notched-striped",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "notchedRightArrow", "stripedRightArrow", "chevron", "homePlate", "swooshArrow",
      ],
      "70AD47",
    ),
  })

  // ---- 3. Bi-directional arrows ---------------------------------
  // `leftRightArrow` / `upDownArrow` / `quadArrow` are arrows with
  // multiple heads pointing in opposite directions.  Their
  // geometry shares the single-direction-arrow math but exercises
  // both halves of the symmetric path code.
  cases.push({
    id: "shape-arrows-bidirectional",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      ["leftRightArrow", "upDownArrow", "quadArrow", "leftRightUpArrow"],
      "ED7D31",
    ),
  })

  // ---- 4. Circular arrows (different from the curved family) ----
  // `circularArrow`, `leftCircularArrow`, `leftRightCircularArrow`
  // are full-loop arrows distinct from the `curved*Arrow` family
  // (which forms a half-loop).  They use the most complex preset
  // geometry in the arrow file (the `arrow_circular_arrow` ladder
  // of 150+ guides) and are sensitive to small algebra regressions.
  cases.push({
    id: "shape-arrows-circular",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      ["circularArrow", "leftCircularArrow", "leftRightCircularArrow"],
      "7030A0",
    ),
  })

  // ---- 5. Arrow callouts -----------------------------------------
  // Arrow + flag-shaped label region.  Already covered by
  // `shape-arrow-callouts` but this slimmer fixture isolates the
  // four primary directions for quick regression spotting.
  cases.push({
    id: "shape-arrows-callouts-primary",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "leftArrowCallout", "rightArrowCallout", "upArrowCallout", "downArrowCallout",
      ],
      "C00000",
    ),
  })

  // ---- 6. Mixed-direction single arrows --------------------------
  // The cardinal direction arrows (`leftArrow`, `rightArrow`,
  // `upArrow`, `downArrow`) — a sanity-check sweep that should
  // always render cleanly.  Splitting them into their own fixture
  // lets the snapshot tell us whether direction-handling is the
  // culprit of an arrow-family regression vs. shape-specific bugs.
  cases.push({
    id: "shape-arrows-cardinal",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      ["leftArrow", "rightArrow", "upArrow", "downArrow"],
      "4472C4",
    ),
  })
}
