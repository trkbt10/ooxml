// PresentationML master / layout / placeholder / animation / notes /
// header-footer / comment fixtures.
//
// Covers ECMA-376 areas previously under-represented in the visual
// snapshot grid:
//
//   • §19.3.1.34 `<p:sldMaster>` + `<p:sldLayout>` placeholder
//     inheritance — titles/body placeholders inherit through
//     master → layout → slide.  The shared `pptx_package` helper
//     ships a minimal master + a `type="title"` layout; the slide
//     side of every fixture below carries the full placeholder
//     payload (`<p:nvSpPr><p:nvPr><p:ph .../>` plus the geometry +
//     text body) so the resolver sees a complete slide-level
//     override and renders the content even when the layout/master
//     don't supply the same placeholder.
//   • §19.5 Animations — `<p:timing>` with a single time-node tree.
//     The renderer surfaces the time-node names as data attributes;
//     the visual snapshot's job is to verify the slide still renders
//     correctly with a timing payload present.  Fade / fly / wipe /
//     zoom variants exercise the `<p:animEffect>` parser.
//   • §19.3.1.20 Header / Footer — `<p:hf>` toggles plus slide-side
//     `<p:sp>` placeholders of type `dt` (date), `sldNum` (slide
//     number), `ftr` (footer text) so the rendered text is visible.
//   • §19.3.1.29 Notes — a slide bearing a notes-page-style body
//     placeholder so notes text is part of the visual.
//   • §19.4 Comments — `<p:cm>` author-annotation; renders as a
//     small comment glyph attached to a slide-side anchor shape so
//     PowerPoint's comment-pane indicator is visible.
//
// Conventions:
//   • Slide canvas is 9144000 × 6858000 EMU (10in × 7.5in).
//   • Shape ids start at "2" (id "1" is reserved for the spTree
//     group).
//   • Uses helpers from `fixtures_helpers.mbt` (`sp_xfrm`,
//     `solid_fill`, `sp_tree`, `xe`, `xa`) and `verify.mbt`
//     (`xep` for prefix-namespace `<p:*>` elements).

///|
/// Build a `<p:sp>` carrying a placeholder marker and a text body —
/// the canonical slide-side override of a master/layout placeholder.
///
/// `ph_type` is the §19.7.10 ST_PlaceholderType value (`title`,
/// `body`, `ctrTitle`, `subTitle`, `dt`, `ftr`, `sldNum`, `hdr`,
/// `obj`, `pic`, `chart`, `tbl`, `dgm`, `media`).  `ph_idx`, when
/// `Some`, is the §19.3.1.36 `idx` that ties this slide placeholder
/// to a specific layout placeholder; `None` falls back to type-based
/// lookup.  `text` is rendered inside an `<a:p><a:r><a:t>` body at
/// the requested point size (`sz_hp`, half-points × 100, e.g.
/// "3200" = 32 pt).
fn pml_ml_placeholder_sp(
  id_ : String,
  name : String,
  ph_type : String,
  ph_idx : String?,
  x : String,
  y : String,
  cx : String,
  cy : String,
  text : String,
  sz_hp : String,
) -> @xml.Element {
  let ph_attrs : Array[@xml.Attribute] = [xa("type", ph_type)]
  match ph_idx {
    Some(idx) => ph_attrs.push(xa("idx", idx))
    None => ()
  }
  let ph_el = xe(NS_PML, "ph", ph_attrs, [])
  let rpr = xe(NS_A, "rPr", [xa("lang", "en-US"), xa("sz", sz_hp)], [])
  let r = xe(NS_A, "r", [], [
    Element(rpr),
    Element(xe(NS_A, "t", [], [Text(text)])),
  ])
  let para = xe(NS_A, "p", [], [Element(r)])
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(
          xe(NS_PML, "cNvSpPr", [], [
            Element(xe(NS_A, "spLocks", [xa("noGrp", "1")], [])),
          ]),
        ),
        Element(xe(NS_PML, "nvPr", [], [Element(ph_el)])),
      ]),
    ),
    Element(xe(NS_PML, "spPr", [], [Element(sp_xfrm(x, y, cx, cy))])),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", [], [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(para),
      ]),
    ),
  ])
}

///|
/// Build a `<p:sp>` body placeholder filled with multi-paragraph
/// bullet text — three `<a:p>` runs at successive indent levels so
/// the body-style cascade through master → layout → slide is
/// exercised.  Each paragraph is auto-bulleted via `<a:buAutoNum>`.
fn pml_ml_body_bullets(
  id_ : String,
  name : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  bullets : Array[(String, String)],
) -> @xml.Element {
  let ph_el = xe(NS_PML, "ph", [xa("type", "body"), xa("idx", "1")], [])
  let paras : Array[@xml.Node] = []
  for b in bullets {
    let (lvl, text) = b
    let ppr_attrs : Array[@xml.Attribute] = if lvl != "0" {
      [xa("lvl", lvl)]
    } else {
      []
    }
    let ppr = xe(NS_A, "pPr", ppr_attrs, [])
    let rpr = xe(NS_A, "rPr", [xa("lang", "en-US"), xa("sz", "2000")], [])
    let r = xe(NS_A, "r", [], [
      Element(rpr),
      Element(xe(NS_A, "t", [], [Text(text)])),
    ])
    paras.push(Element(xe(NS_A, "p", [], [Element(ppr), Element(r)])))
  }
  let body_kids : Array[@xml.Node] = [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
  ]
  for p in paras {
    body_kids.push(p)
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
        Element(xe(NS_PML, "nvPr", [], [Element(ph_el)])),
      ]),
    ),
    Element(xe(NS_PML, "spPr", [], [Element(sp_xfrm(x, y, cx, cy))])),
    Element(xe(NS_PML, "txBody", [], body_kids)),
  ])
}

///|
/// Build a slide-level `<p:cSld>` that wraps `shapes` AND embeds the
/// supplied extras (e.g. `<p:hf>`, `<p:timing>`) as additional
/// children of `<p:cSld>`.  Strictly speaking `<p:timing>` and
/// `<p:hf>` are siblings of `<p:cSld>` inside `<p:sld>` (§19.3.1.38),
/// but the shared `pptx_package` builder accepts only a single child
/// of `<p:sld>`.  Embedding the extras inside `<p:cSld>` keeps the
/// payload visible to the parser while reusing the same host package
/// helper as every other PML fixture; renderers tolerate unknown
/// child elements there.  Mirrors the transition fixtures'
/// convention (see `fixtures_pml_transitions.mbt`).
fn pml_ml_cSld_with_extras(
  shapes : Array[@xml.Element],
  extras : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = [
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
    kids.push(Element(s))
  }
  let cSld_kids : Array[@xml.Node] = [Element(xe(NS_PML, "spTree", [], kids))]
  for e in extras {
    cSld_kids.push(Element(e))
  }
  xe(NS_PML, "cSld", [], cSld_kids)
}

///|
/// `<p:hf>` toggle element — §19.3.1.20 CT_HeaderFooter.  Each
/// attribute is `"1"` (show) or `"0"` (hide) and controls whether
/// the corresponding placeholder is visible on the slide.  Defaults
/// per spec are `1` (show all), so omitting an attribute is identical
/// to passing `"1"`.
fn pml_ml_hf(
  dt : String,
  ftr : String,
  hdr : String,
  sld_num : String,
) -> @xml.Element {
  xe(
    NS_PML,
    "hf",
    [xa("dt", dt), xa("ftr", ftr), xa("hdr", hdr), xa("sldNum", sld_num)],
    [],
  )
}

///|
/// Build a `<p:timing>` element wrapping a single `<p:tnLst>` with
/// one `<p:par>` root.  `effect_kind` becomes a `presetID` attribute
/// on a nested `<p:animEffect>` so the parser sees a recognisable
/// "fade" / "fly" / "wipe" / "zoom" entry.
fn pml_ml_timing_with_effect(effect_kind : String) -> @xml.Element {
  // ECMA-376 §19.5.5 animEffect — minimal payload.  The presetID and
  // presetClass values come from §19.7.16 ST_TLAnimateEffectPresetID.
  // We use representative integer ids:
  //   fade = 10, fly = 2, wipe = 12, zoom = 23
  let preset_id = match effect_kind {
    "fade" => "10"
    "fly" => "2"
    "wipe" => "12"
    "zoom" => "23"
    _ => "0"
  }
  let anim_effect = xep(
    "p",
    NS_PML,
    "animEffect",
    [
      xa("transition", "in"),
      xa("filter", effect_kind),
      xa("presetID", preset_id),
      xa("presetClass", "entr"),
    ],
    [],
  )
  let par_inner = xep("p", NS_PML, "par", [], [Element(anim_effect)])
  let tn_lst = xep("p", NS_PML, "tnLst", [], [Element(par_inner)])
  xep("p", NS_PML, "timing", [], [Element(tn_lst)])
}

///|
fn extras_pml_master_layout(cases : Array[VisualCase]) -> Unit {
  // ---- 1. §19.3.1.34 title-only layout: slide carries only a
  // `<p:ph type="title">` placeholder; the title text is supplied by
  // the slide itself so the resolver sees the slide-level override.
  cases.push({
    id: "ml-title-only",
    format: "pptx",
    category: "master-layout",
    content: sp_tree([
      pml_ml_placeholder_sp(
        "2",
        "Title 1",
        "title",
        Some("0"),
        "457200",
        "1828800",
        "8229600",
        "1371600",
        "Slide Title from Slide",
        "4400",
      ),
    ]),
  })

  // ---- 2. §19.3.1.34 title + body layout: title at the top, a
  // `<p:ph type="body" idx="1">` placeholder with three indent-level
  // bullets underneath.  Exercises the body-style cascade through the
  // master → layout → slide chain.
  cases.push({
    id: "ml-title-body-bullets",
    format: "pptx",
    category: "master-layout",
    content: sp_tree([
      pml_ml_placeholder_sp(
        "2",
        "Title 1",
        "title",
        Some("0"),
        "457200",
        "457200",
        "8229600",
        "1143000",
        "Section Heading",
        "3600",
      ),
      pml_ml_body_bullets(
        "3",
        "Body 2",
        "457200",
        "1828800",
        "8229600",
        "4572000",
        [
          ("0", "First top-level bullet"),
          ("1", "Sub-bullet under level zero"),
          ("0", "Second top-level bullet"),
          ("1", "Another sub-bullet"),
          ("2", "Deeper indent bullet"),
        ],
      ),
    ]),
  })

  // ---- 3. §19.3.1.34 two-content layout: title across the top, two
  // body placeholders (idx=1 and idx=2) side-by-side underneath.
  // Each body owns its own bullet list — the typical PowerPoint
  // "Two Content" layout pattern.
  cases.push({
    id: "ml-title-two-content",
    format: "pptx",
    category: "master-layout",
    content: sp_tree([
      pml_ml_placeholder_sp(
        "2",
        "Title 1",
        "title",
        Some("0"),
        "457200",
        "457200",
        "8229600",
        "1143000",
        "Comparison",
        "3600",
      ),
      pml_ml_body_bullets(
        "3",
        "LeftBody",
        "457200",
        "1828800",
        "3886200",
        "4572000",
        [
          ("0", "Left option A"),
          ("0", "Left option B"),
          ("1", "Sub-detail B-1"),
        ],
      ),
      pml_ml_body_bullets(
        "4",
        "RightBody",
        "4800600",
        "1828800",
        "3886200",
        "4572000",
        [
          ("0", "Right option A"),
          ("0", "Right option B"),
          ("1", "Sub-detail B-1"),
        ],
      ),
    ]),
  })

  // ---- 4. §19.3.1.34 custom layout with a scheme-colour-filled
  // accent shape: a non-placeholder `<p:sp>` filled from
  // `<a:schemeClr val="accent1">` so the master's `<p:clrMap>` is
  // exercised end-to-end (master clrMap → theme accent1 → SRGB).
  let accent_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "AccentBar")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("0", "0", "9144000", "457200")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(
          xe(NS_A, "solidFill", [], [
            Element(xe(NS_A, "schemeClr", [xa("val", "accent1")], [])),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "ml-custom-master-scheme-color",
    format: "pptx",
    category: "master-layout",
    content: sp_tree([
      accent_shape,
      pml_ml_placeholder_sp(
        "3",
        "Title 1",
        "title",
        Some("0"),
        "457200",
        "1143000",
        "8229600",
        "1143000",
        "Custom Layout (accent1 bar)",
        "3200",
      ),
    ]),
  })

  // ---- 5. §19.3.1.36 slide-side override of a master placeholder:
  // the slide carries an `<p:sp>` with `<p:ph idx="0"/>` (no type,
  // pure idx-based lookup), an explicit fill, and explicit body text
  // — the slide's overrides win over whatever the master would have
  // supplied via idx=0.
  let override_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "TitleOverride")], []),
        ),
        Element(
          xe(NS_PML, "cNvSpPr", [], [
            Element(xe(NS_A, "spLocks", [xa("noGrp", "1")], [])),
          ]),
        ),
        Element(
          xe(NS_PML, "nvPr", [], [
            Element(xe(NS_PML, "ph", [xa("idx", "0")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("457200", "1828800", "8229600", "1371600")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("FFF2CC")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", [xa("anchor", "ctr")], [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          xe(NS_A, "p", [], [
            Element(xe(NS_A, "pPr", [xa("algn", "ctr")], [])),
            Element(
              xe(NS_A, "r", [], [
                Element(
                  xe(
                    NS_A,
                    "rPr",
                    [xa("lang", "en-US"), xa("sz", "3200"), xa("b", "1")],
                    [Element(solid_fill("BF8F00"))],
                  ),
                ),
                Element(xe(NS_A, "t", [], [Text("Slide Overrides Master")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "ml-slide-overrides-master",
    format: "pptx",
    category: "master-layout",
    content: sp_tree([override_shape]),
  })

  // ---- 6. §19.3.1.20 header/footer placeholders all present —
  // date, footer text, slide-number placeholders, each carrying
  // visible text so the rendered SVG actually shows the values.
  // The `<p:hf>` toggle declares the master/layout intent; the
  // slide-side `<p:sp>` placeholders carry the text content.
  cases.push({
    id: "ml-hf-all-on",
    format: "pptx",
    category: "master-layout",
    content: pml_ml_cSld_with_extras(
      [
        pml_ml_placeholder_sp(
          "2",
          "Title 1",
          "title",
          Some("0"),
          "457200",
          "457200",
          "8229600",
          "1143000",
          "Header / Footer Demo",
          "3200",
        ),
        // Date placeholder, bottom-left.
        pml_ml_placeholder_sp(
          "3",
          "Date 2",
          "dt",
          Some("10"),
          "457200",
          "6248400",
          "2286000",
          "457200",
          "2026-05-23",
          "1200",
        ),
        // Footer text, bottom-centre.
        pml_ml_placeholder_sp(
          "4",
          "Footer 3",
          "ftr",
          Some("11"),
          "3429000",
          "6248400",
          "2286000",
          "457200",
          "Confidential",
          "1200",
        ),
        // Slide-number, bottom-right.
        pml_ml_placeholder_sp(
          "5",
          "SlideNum 4",
          "sldNum",
          Some("12"),
          "6400800",
          "6248400",
          "2286000",
          "457200",
          "Slide 1",
          "1200",
        ),
      ],
      [pml_ml_hf("1", "1", "0", "1")],
    ),
  })

  // ---- 7. §19.3.1.20 header/footer toggled off: same placeholders
  // present on the slide but `<p:hf>` says hide footer + slide
  // number.  Conformant readers still render the placeholder text
  // (we never strip them), but the parser path for the toggle is
  // exercised and the slide composes cleanly.
  cases.push({
    id: "ml-hf-footer-off",
    format: "pptx",
    category: "master-layout",
    content: pml_ml_cSld_with_extras(
      [
        pml_ml_placeholder_sp(
          "2",
          "Title 1",
          "title",
          Some("0"),
          "457200",
          "457200",
          "8229600",
          "1143000",
          "Footer Disabled",
          "3200",
        ),
        pml_ml_placeholder_sp(
          "3",
          "Date 2",
          "dt",
          Some("10"),
          "457200",
          "6248400",
          "8229600",
          "457200",
          "Only the date should appear",
          "1200",
        ),
      ],
      [pml_ml_hf("1", "0", "0", "0")],
    ),
  })

  // ---- 8. §19.3.1.29 Notes-style body — a `<p:ph type="body"
  // idx="1">` placeholder filled with multi-line notes-page text.
  // The notes-MASTER part itself is not shipped (would require
  // extending `pptx_package`); the fixture validates that a slide
  // bearing notes-style content still parses and renders.
  cases.push({
    id: "ml-notes-body",
    format: "pptx",
    category: "master-layout",
    content: sp_tree([
      pml_ml_placeholder_sp(
        "2",
        "Title 1",
        "title",
        Some("0"),
        "457200",
        "457200",
        "8229600",
        "914400",
        "Notes for Speaker",
        "2800",
      ),
      pml_ml_body_bullets(
        "3",
        "NotesBody",
        "457200",
        "1600200",
        "8229600",
        "4800600",
        [
          ("0", "Remember to mention the Q3 numbers up front."),
          ("0", "Pause for questions after the comparison slide."),
          ("0", "Demo runs ~7 minutes; cut the appendix if short on time."),
          ("1", "Backup demo recording linked in shared drive."),
        ],
      ),
    ]),
  })

  // ---- 9. §19.5 Animations — fade entry on a single shape.  The
  // `<p:timing>` payload sits inside `<p:cSld>` (so the existing
  // pptx_package builder accepts it); the renderer surfaces the
  // timing root name as `data-ooxml-timing-tnLst="par"`.  The body
  // shape carries visible text so the visual snapshot has content
  // to compare.
  let timing_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "AnimShape")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("2286000", "2286000", "4572000", "2286000")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("4472C4")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", [xa("anchor", "ctr")], [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          xe(NS_A, "p", [], [
            Element(xe(NS_A, "pPr", [xa("algn", "ctr")], [])),
            Element(
              xe(NS_A, "r", [], [
                Element(
                  xe(NS_A, "rPr", [xa("lang", "en-US"), xa("sz", "2800")], [
                    Element(solid_fill("FFFFFF")),
                  ]),
                ),
                Element(xe(NS_A, "t", [], [Text("Fade-In Target")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "ml-timing-fade",
    format: "pptx",
    category: "master-layout",
    content: pml_ml_cSld_with_extras([timing_shape], [
      pml_ml_timing_with_effect("fade"),
    ]),
  })

  // ---- 10. §19.5 Animations — fly-in entry on a target shape.
  let fly_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "FlyShape")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("2286000", "2286000", "4572000", "2286000")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "ellipse")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("ED7D31")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", [xa("anchor", "ctr")], [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          xe(NS_A, "p", [], [
            Element(xe(NS_A, "pPr", [xa("algn", "ctr")], [])),
            Element(
              xe(NS_A, "r", [], [
                Element(
                  xe(NS_A, "rPr", [xa("lang", "en-US"), xa("sz", "2800")], [
                    Element(solid_fill("FFFFFF")),
                  ]),
                ),
                Element(xe(NS_A, "t", [], [Text("Fly-In Target")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "ml-timing-fly",
    format: "pptx",
    category: "master-layout",
    content: pml_ml_cSld_with_extras([fly_shape], [
      pml_ml_timing_with_effect("fly"),
    ]),
  })

  // ---- 11. §19.5 Animations — wipe entry on a banner.
  let wipe_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "WipeShape")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("457200", "2743200", "8229600", "1371600")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rightArrow")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("70AD47")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", [xa("anchor", "ctr")], [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          xe(NS_A, "p", [], [
            Element(xe(NS_A, "pPr", [xa("algn", "ctr")], [])),
            Element(
              xe(NS_A, "r", [], [
                Element(
                  xe(NS_A, "rPr", [xa("lang", "en-US"), xa("sz", "2800")], [
                    Element(solid_fill("FFFFFF")),
                  ]),
                ),
                Element(xe(NS_A, "t", [], [Text("Wipe-In Banner")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "ml-timing-wipe",
    format: "pptx",
    category: "master-layout",
    content: pml_ml_cSld_with_extras([wipe_shape], [
      pml_ml_timing_with_effect("wipe"),
    ]),
  })

  // ---- 12. §19.5 Animations — zoom entry on a star.
  let zoom_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "ZoomShape")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("3429000", "1828800", "2286000", "2286000")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "star5")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("FFC000")),
      ]),
    ),
  ])
  cases.push({
    id: "ml-timing-zoom",
    format: "pptx",
    category: "master-layout",
    content: pml_ml_cSld_with_extras([zoom_shape], [
      pml_ml_timing_with_effect("zoom"),
    ]),
  })

  // ---- 13. §19.4 Comment marker — a slide-side anchor shape with
  // a small comment glyph (a tiny yellow rect labelled "[1]") near
  // the top-left.  The actual `<p:cm>` element would normally live
  // in a separate `commentAuthors.xml` / `comments1.xml` part — the
  // current `pptx_package` helper doesn't ship those parts, so we
  // embed a visible *visual* indicator of where a comment would
  // attach to the slide.  This still exercises the renderer's
  // multi-shape composition near a target.
  let comment_target = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "TargetShape")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1828800", "5486400", "2743200")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "roundRect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("DEEBF7")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", [xa("anchor", "ctr")], [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          xe(NS_A, "p", [], [
            Element(xe(NS_A, "pPr", [xa("algn", "ctr")], [])),
            Element(
              xe(NS_A, "r", [], [
                Element(
                  xe(NS_A, "rPr", [xa("lang", "en-US"), xa("sz", "2400")], []),
                ),
                Element(xe(NS_A, "t", [], [Text("Commented Shape")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  let comment_glyph = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "3"), xa("name", "CommentGlyph")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1600200", "1600200", "457200", "457200")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("FFC000")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", [xa("anchor", "ctr")], [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          xe(NS_A, "p", [], [
            Element(xe(NS_A, "pPr", [xa("algn", "ctr")], [])),
            Element(
              xe(NS_A, "r", [], [
                Element(
                  xe(
                    NS_A,
                    "rPr",
                    [xa("lang", "en-US"), xa("sz", "1400"), xa("b", "1")],
                    [],
                  ),
                ),
                Element(xe(NS_A, "t", [], [Text("1")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "ml-comment-marker",
    format: "pptx",
    category: "master-layout",
    content: sp_tree([comment_target, comment_glyph]),
  })
}
