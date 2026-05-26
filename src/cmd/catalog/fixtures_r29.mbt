// Round-29 visual fixtures — drive PML non-visual property elements
// (cNvSpPr, cNvPicPr, cNvPr, nvSpPr, nvPicPr, nvGrpSpPr, grpSpPr)
// through the full reader / writer / renderer chain by hosting them
// inside spec-rich `<p:sp>` / `<p:pic>` / `<p:grpSp>` ancestors that
// the PML viewer paints visibly (preset geometry, blip fill, group
// transform, audio / video / hyperlink overlays).
//
// Round 26 added the differential render path that emits visible
// glyphs for `<a:audioFile>` / `<a:videoFile>` / `<a:hlinkClick>` —
// this round wires the SHAPE / PICTURE / GROUP variants those
// glyphs ride on top of, so the snapshot harness has comparison
// payload for every non-visual property element a conformant PML
// reader must recognise.
//
// Hosting:
//   * `VisualCase` — `.pptx` whose slide content embeds the rich
//     shape / group payload directly in a standard cSld (no extra
//     rels beyond the layout). Wired through `extras_pml_extra_r29`
//     called from `fixtures_categories.mbt`.
//   * `MediaSlideCase` — `.pptx` whose slide carries shape /
//     picture / group payload AND extra slide-side rels (External-
//     mode hyperlink + audio / blip targets). Wired through the
//     existing `media_slide_cases()` collector in fixtures_r26.mbt.
//   * `ExternalRefCase` — `.xlsx` whose `xl/externalLinks/...`
//     part carries a multi-sheet `<externalBook>` so the
//     `<sheetName>` / `<sheetDataSet>` / `<sheetData>` repetition
//     count is non-degenerate. Wired through the existing
//     `external_ref_cases()` collector in fixtures_r26.mbt.
//   * `PivotedCase` — `.xlsx` whose `<pivotCacheDefinition>` part
//     carries an explicit `<cacheSource type="worksheet">` and a
//     richer `<cacheFields>` than the canonical pivot fixtures.
//     Wired through the existing `pivoted_cases()` collector in
//     fixtures_sml_pivots.mbt.

///|
/// §17.4.18 (cNvPicPr) + §20.1.8.13 (blip) + §17.4.20 (cNvSpPr) —
/// a `<p:pic>` with `<p:nvPicPr><p:cNvPicPr><a:picLocks .../></p:cNvPicPr></p:nvPicPr>`
/// plus `<p:blipFill><a:blip r:link="..."/></p:blipFill>` and a
/// preset-geometry `<p:spPr>` so the renderer's picture path emits
/// a visible `<image>` (when the blip resolves) plus its fallback
/// `<rect>` outline. Hosted via `pptx_package_with_slide_rels` so
/// the slide-side `r:link="rId2"` resolves to an External-mode URL
/// without needing an embedded image payload.
fn extras_r29_media_slides_pic(cases : Array[MediaSlideCase]) -> Unit {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // The blip element — `r:embed` is the canonical attr but External-
  // targetMode rels resolve via `r:link`, which keeps the blip valid
  // without needing a binary image part. §20.1.8.13.
  let blip = xe(
    NS_A,
    "blip",
    [
      {
        name: { prefix: Some("r"), local_name: "link", ns: Some(ns_r) },
        value: "rId2",
      },
    ],
    [
      // §20.1.8.7 alphaModFix — partial transparency on the blip.
      Element(xe(NS_A, "alphaModFix", [xa("amt", "50000")], [])),
    ],
  )
  // The blipFill stretch — `<a:stretch><a:fillRect/></a:stretch>`.
  let blip_fill = xe(NS_PML, "blipFill", [], [
    Element(blip),
    Element(xe(NS_A, "stretch", [], [Element(xe(NS_A, "fillRect", [], []))])),
  ])
  // The picture's non-visual properties — cNvPicPr carries
  // `<a:picLocks>` (§20.2.2.2) with noChangeAspect=1 (the most
  // common preset) which the spec requires every conformant
  // editor to honour during interactive resize.
  let nv_pic_pr = xe(NS_PML, "nvPicPr", [], [
    Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "RichPicture")], [])),
    Element(
      xe(NS_PML, "cNvPicPr", [], [
        Element(xe(NS_A, "picLocks", [xa("noChangeAspect", "1")], [])),
      ]),
    ),
    Element(xe(NS_PML, "nvPr", [], [])),
  ])
  // The shape properties — position / size + a `<a:prstGeom prst="rect">`
  // so the picture's bounding region is a real rectangle. The blipFill
  // paints the rect; the renderer falls back to a labelled rect if
  // the external blip cannot be resolved.
  let sp_pr = xe(NS_PML, "spPr", [], [
    Element(sp_xfrm("1828800", "1371600", "5486400", "4114800")),
    Element(
      xe(NS_A, "prstGeom", [xa("prst", "rect")], [
        Element(xe(NS_A, "avLst", [], [])),
      ]),
    ),
  ])
  let pic = xe(NS_PML, "pic", [], [
    Element(nv_pic_pr),
    Element(blip_fill),
    Element(sp_pr),
  ])
  let extra_rels : Array[(String, String, String, String)] = [
    (
      "rId2", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
      "https://example.com/banner.png", "External",
    ),
  ]
  cases.push({
    id: "pic-nv-properties-with-blip",
    format: "pptx",
    category: "pic",
    content: sp_tree([pic]),
    extra_rels,
  })
}

///|
/// §17.4.20 (cNvSpPr txBox=1) + §17.4.4 (audioFile) + §20.1.2.2.20
/// (hlinkClick) + §20.1.2.2.21 (hlinkHover) — a shape whose
/// `<p:cNvPr>` carries BOTH hlinkClick AND hlinkHover targets, whose
/// `<p:cNvSpPr>` is marked as a text box (`txBox="1"`), and whose
/// `<p:nvPr>` carries an `<a:audioFile r:link>`. Drives:
///   * audioFile speaker icon (`nv_media_overlay_svg` audio path)
///   * hlinkClick + hlinkHover underline marker
///   * preset-geometry rectangle (visible body fill)
/// Hosted via `pptx_package_with_slide_rels` so rId2 / rId3 / rId4
/// resolve to External-mode targets.
fn extras_r29_media_slides_shape(cases : Array[MediaSlideCase]) -> Unit {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // hlinkClick on cNvPr — primary click target.
  let hlink_click = xe(
    NS_A,
    "hlinkClick",
    [
      {
        name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
        value: "rId2",
      },
      xa("tooltip", "Documentation"),
    ],
    [],
  )
  // hlinkHover on cNvPr — secondary hover target (§20.1.2.2.21).
  let hlink_hover = xe(
    NS_A,
    "hlinkHover",
    [
      {
        name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
        value: "rId3",
      },
      xa("tooltip", "Preview"),
    ],
    [],
  )
  // audioFile on nvPr — embedded audio reference (§17.4.4).
  let audio_file = xe(
    NS_A,
    "audioFile",
    [
      {
        name: { prefix: Some("r"), local_name: "link", ns: Some(ns_r) },
        value: "rId4",
      },
      xa("contentType", "audio/mpeg"),
    ],
    [],
  )
  // Full nvSpPr — cNvPr carries hlinkClick + hlinkHover; cNvSpPr
  // marks the shape as a textbox; nvPr carries the audioFile.
  let nv_sp_pr = xe(NS_PML, "nvSpPr", [], [
    Element(
      xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "RichTextBoxWithMedia")], [
        Element(hlink_click),
        Element(hlink_hover),
      ]),
    ),
    Element(xe(NS_PML, "cNvSpPr", [xa("txBox", "1")], [])),
    Element(xe(NS_PML, "nvPr", [], [Element(audio_file)])),
  ])
  // spPr — preset rectangle with a solid fill so the body paints.
  let sp_pr = xe(NS_PML, "spPr", [], [
    Element(sp_xfrm("1828800", "1371600", "5486400", "4114800")),
    Element(
      xe(NS_A, "prstGeom", [xa("prst", "rect")], [
        Element(xe(NS_A, "avLst", [], [])),
      ]),
    ),
    Element(solid_fill("FBE5D6")),
  ])
  let shape = xe(NS_PML, "sp", [], [Element(nv_sp_pr), Element(sp_pr)])
  let extra_rels : Array[(String, String, String, String)] = [
    (
      "rId2", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
      "https://example.com/docs", "External",
    ),
    (
      "rId3", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
      "https://example.com/preview", "External",
    ),
    (
      "rId4", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/audio",
      "https://example.com/intro.mp3", "External",
    ),
  ]
  cases.push({
    id: "shape-nv-properties-rich",
    format: "pptx",
    category: "shape",
    content: sp_tree([shape]),
    extra_rels,
  })
}

///|
/// §17.4.23 / §19.3.1.22 (grpSpPr) — an explicit `<p:grpSp>` group
/// containing two child shapes. The group's `<p:nvGrpSpPr>` carries
/// `<p:cNvPr>` + `<p:cNvGrpSpPr>` + `<p:nvPr>`; its `<p:grpSpPr>`
/// carries an `<a:xfrm>` with `<a:off>` / `<a:ext>` / `<a:chOff>` /
/// `<a:chExt>` so child coordinates project through the group's
/// transform. Drives the §19.3.1.22 `<p:grpSp>` renderer path.
fn extras_r29_pml_group(cases : Array[VisualCase]) -> Unit {
  // Group transform — the group occupies the same EMU box as a
  // standalone shape would; `chOff` / `chExt` define the child
  // coordinate system origin and extent. §20.1.7.5 CT_GroupTransform2D.
  let grp_xfrm = xe(NS_A, "xfrm", [], [
    Element(xe(NS_A, "off", [xa("x", "1828800"), xa("y", "1371600")], [])),
    Element(xe(NS_A, "ext", [xa("cx", "5486400"), xa("cy", "4114800")], [])),
    Element(xe(NS_A, "chOff", [xa("x", "0"), xa("y", "0")], [])),
    Element(xe(NS_A, "chExt", [xa("cx", "5486400"), xa("cy", "4114800")], [])),
  ])
  // Child shapes — two rectangles positioned in the group's child
  // coordinate space (top-left at 0, bottom-right at chExt).
  let child1 = pptx_shape(
    "3", "GroupChildA", "rect", "0", "0", "2743200", "2057400", "5B9BD5",
  )
  let child2 = pptx_shape(
    "4", "GroupChildB", "rect", "2743200", "2057400", "2743200", "2057400", "ED7D31",
  )
  let group = xe(NS_PML, "grpSp", [], [
    Element(
      xe(NS_PML, "nvGrpSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "RichGroup")], []),
        ),
        Element(xe(NS_PML, "cNvGrpSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(xe(NS_PML, "grpSpPr", [], [Element(grp_xfrm)])),
    Element(child1),
    Element(child2),
  ])
  cases.push({
    id: "group-nv-grpSpPr",
    format: "pptx",
    category: "group",
    content: sp_tree([group]),
  })
}

///|
/// §18.14.5 / §18.14.7 — extended external-link fixture whose
/// `<externalBook>` carries TWO `<sheetName>` entries and TWO
/// `<sheetDataSet>/<sheetData>` payloads. The worksheet displays
/// the cached values from BOTH external sheets via the inline-
/// string + numeric cells below (the formula path is broken — see
/// the r26 notes — so we surface the cached numbers directly).
fn extras_r29_sml_external_book_multi(cases : Array[ExternalRefCase]) -> Unit {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // `<externalBook>` with two sheets — Sheet1 + Sheet2 — and a
  // sheetDataSet containing one row of cached values per sheet so
  // the §18.14.5 `<sheetDataSet>` repetition count is genuinely
  // multi-element (the r26 baseline used a single sheet).
  let external_link = xe(NS_S, "externalLink", [], [
    Element(
      xe(
        NS_S,
        "externalBook",
        [
          {
            name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
            value: "rId1",
          },
        ],
        [
          Element(
            xe(NS_S, "sheetNames", [], [
              Element(xe(NS_S, "sheetName", [xa("val", "Sheet1")], [])),
              Element(xe(NS_S, "sheetName", [xa("val", "Sheet2")], [])),
            ]),
          ),
          Element(
            xe(NS_S, "sheetDataSet", [], [
              Element(
                xe(NS_S, "sheetData", [xa("sheetId", "0")], [
                  Element(
                    xe(NS_S, "row", [xa("r", "1")], [
                      Element(
                        xe(NS_S, "cell", [xa("r", "A1"), xa("t", "n")], [
                          Element(xe(NS_S, "v", [], [Text("100")])),
                        ]),
                      ),
                    ]),
                  ),
                ]),
              ),
              Element(
                xe(NS_S, "sheetData", [xa("sheetId", "1")], [
                  Element(
                    xe(NS_S, "row", [xa("r", "1")], [
                      Element(
                        xe(NS_S, "cell", [xa("r", "A1"), xa("t", "n")], [
                          Element(xe(NS_S, "v", [], [Text("200")])),
                        ]),
                      ),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ),
    ),
  ])
  // The worksheet surfaces both cached values as inline-string +
  // numeric cells so the snapshot harness has visible labels for
  // the cross-sheet aggregation.
  let worksheet = xe(NS_S, "worksheet", [], [
    Element(
      xe(NS_S, "sheetData", [], [
        Element(s_row("1", [s_inline("A1", "Sheet1 A1:"), s_cell("B1", "100")])),
        Element(s_row("2", [s_inline("A2", "Sheet2 A1:"), s_cell("B2", "200")])),
        Element(s_row("3", [s_inline("A3", "Combined:"), s_cell("B3", "300")])),
      ]),
    ),
  ])
  cases.push({
    id: "external-book-multi-sheet",
    format: "xlsx",
    category: "external",
    content: worksheet,
    external_link,
  })
}

///|
/// §18.10.1.67 — pivot fixture with a richer `<pivotCacheDefinition>`
/// than the canonical pivot set: TWO numeric data fields with
/// distinct numFmtId entries, an explicit `<cacheSource type="worksheet">`
/// + named range, and a single-row / single-col layout that the
/// renderer paints with a body-cell pair the snapshot harness can
/// detect. Pushed via the standard `xlsx_package_with_pivot` chain
/// so the `pivotCacheDefinition` part lands at
/// `xl/pivotCache/pivotCacheDefinition1.xml`.
fn extras_r29_sml_pivot_cache_rich(cases : Array[PivotedCase]) -> Unit {
  // Source data — one Region column + two numeric columns (Sales,
  // Cost) so the cache definition carries three field entries with
  // distinct `<sharedItems>` shapes (string / number / number).
  let source_sheet = xe(NS_S, "sheetData", [], [
    Element(
      s_row("1", [
        s_inline("A1", "Region"),
        s_inline("B1", "Sales"),
        s_inline("C1", "Cost"),
      ]),
    ),
    Element(
      s_row("2", [
        s_inline("A2", "North"),
        s_cell("B2", "100"),
        s_cell("C2", "60"),
      ]),
    ),
    Element(
      s_row("3", [
        s_inline("A3", "South"),
        s_cell("B3", "80"),
        s_cell("C3", "45"),
      ]),
    ),
    Element(
      s_row("4", [
        s_inline("A4", "East"),
        s_cell("B4", "120"),
        s_cell("C4", "75"),
      ]),
    ),
  ])
  // Cache definition — explicit `<cacheSource type="worksheet">` +
  // `<worksheetSource sheet="S1" ref="A1:C4"/>`, plus
  // `<cacheFields>` with three entries: Region (string shared
  // items), Sales (inline numeric), Cost (inline numeric). The
  // `recordCount=3` matches the three source rows.
  let cache_def = xe(
    NS_S,
    "pivotCacheDefinition",
    [
      xa("recordCount", "3"),
      xa("createdVersion", "3"),
      xa("refreshedVersion", "3"),
    ],
    [
      Element(
        xe(NS_S, "cacheSource", [xa("type", "worksheet")], [
          Element(
            xe(
              NS_S,
              "worksheetSource",
              [xa("ref", "A1:C4"), xa("sheet", "S1")],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S, "cacheFields", [xa("count", "3")], [
          // Region — string shared-items (3 distinct values).
          Element(
            xe(
              NS_S,
              "cacheField",
              [xa("name", "Region"), xa("numFmtId", "0")],
              [
                Element(
                  xe(NS_S, "sharedItems", [xa("count", "3")], [
                    Element(xe(NS_S, "s", [xa("v", "North")], [])),
                    Element(xe(NS_S, "s", [xa("v", "South")], [])),
                    Element(xe(NS_S, "s", [xa("v", "East")], [])),
                  ]),
                ),
              ],
            ),
          ),
          // Sales — numeric inline values (no sharedItems entries).
          Element(
            xe(NS_S, "cacheField", [xa("name", "Sales"), xa("numFmtId", "0")], [
              Element(
                xe(
                  NS_S,
                  "sharedItems",
                  [
                    xa("containsSemiMixedTypes", "0"),
                    xa("containsString", "0"),
                    xa("containsNumber", "1"),
                  ],
                  [],
                ),
              ),
            ]),
          ),
          // Cost — numeric inline values.
          Element(
            xe(NS_S, "cacheField", [xa("name", "Cost"), xa("numFmtId", "0")], [
              Element(
                xe(
                  NS_S,
                  "sharedItems",
                  [
                    xa("containsSemiMixedTypes", "0"),
                    xa("containsString", "0"),
                    xa("containsNumber", "1"),
                  ],
                  [],
                ),
              ),
            ]),
          ),
        ]),
      ),
    ],
  )
  // Cache records — three rows of (region-idx, sales, cost).
  let cache_records = xe(NS_S, "pivotCacheRecords", [xa("count", "3")], [
    Element(
      xe(NS_S, "r", [], [
        Element(xe(NS_S, "x", [xa("v", "0")], [])),
        Element(xe(NS_S, "n", [xa("v", "100")], [])),
        Element(xe(NS_S, "n", [xa("v", "60")], [])),
      ]),
    ),
    Element(
      xe(NS_S, "r", [], [
        Element(xe(NS_S, "x", [xa("v", "1")], [])),
        Element(xe(NS_S, "n", [xa("v", "80")], [])),
        Element(xe(NS_S, "n", [xa("v", "45")], [])),
      ]),
    ),
    Element(
      xe(NS_S, "r", [], [
        Element(xe(NS_S, "x", [xa("v", "2")], [])),
        Element(xe(NS_S, "n", [xa("v", "120")], [])),
        Element(xe(NS_S, "n", [xa("v", "75")], [])),
      ]),
    ),
  ])
  // Pivot definition — row axis on Region, two data fields
  // (sum-of-sales + sum-of-cost). Renders a 3-region × 2-value
  // grid that the materializer paints with body cells.
  let pivot_def = xe(
    NS_S,
    "pivotTableDefinition",
    [
      xa("name", "PivotRichCache"),
      xa("cacheId", "0"),
      xa("dataCaption", "Values"),
      xa("createdVersion", "3"),
      xa("updatedVersion", "3"),
      xa("minRefreshableVersion", "3"),
      xa("useAutoFormatting", "1"),
      xa("itemPrintTitles", "1"),
      xa("indent", "0"),
      xa("compact", "0"),
      xa("compactData", "0"),
      xa("gridDropZones", "1"),
    ],
    [
      Element(
        xe(
          NS_S,
          "location",
          [
            xa("ref", "E1:G5"),
            xa("firstHeaderRow", "0"),
            xa("firstDataRow", "1"),
            xa("firstDataCol", "1"),
          ],
          [],
        ),
      ),
      Element(
        xe(NS_S, "pivotFields", [xa("count", "3")], [
          Element(
            xe(
              NS_S,
              "pivotField",
              [
                xa("axis", "axisRow"),
                xa("compact", "0"),
                xa("outline", "0"),
                xa("showAll", "0"),
              ],
              [
                Element(
                  xe(NS_S, "items", [xa("count", "4")], [
                    Element(xe(NS_S, "item", [xa("x", "0")], [])),
                    Element(xe(NS_S, "item", [xa("x", "1")], [])),
                    Element(xe(NS_S, "item", [xa("x", "2")], [])),
                    Element(xe(NS_S, "item", [xa("t", "default")], [])),
                  ]),
                ),
              ],
            ),
          ),
          Element(
            xe(
              NS_S,
              "pivotField",
              [
                xa("dataField", "1"),
                xa("compact", "0"),
                xa("outline", "0"),
                xa("showAll", "0"),
              ],
              [],
            ),
          ),
          Element(
            xe(
              NS_S,
              "pivotField",
              [
                xa("dataField", "1"),
                xa("compact", "0"),
                xa("outline", "0"),
                xa("showAll", "0"),
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xe(NS_S, "rowFields", [xa("count", "1")], [
          Element(xe(NS_S, "field", [xa("x", "0")], [])),
        ]),
      ),
      Element(
        xe(NS_S, "rowItems", [xa("count", "3")], [
          Element(
            xe(NS_S, "i", [], [Element(xe(NS_S, "x", [xa("v", "0")], []))]),
          ),
          Element(
            xe(NS_S, "i", [], [Element(xe(NS_S, "x", [xa("v", "1")], []))]),
          ),
          Element(
            xe(NS_S, "i", [], [Element(xe(NS_S, "x", [xa("v", "2")], []))]),
          ),
        ]),
      ),
      Element(
        xe(NS_S, "colItems", [xa("count", "1")], [
          Element(xe(NS_S, "i", [], [Element(xe(NS_S, "x", [], []))])),
        ]),
      ),
      Element(
        xe(NS_S, "dataFields", [xa("count", "2")], [
          Element(
            xe(
              NS_S,
              "dataField",
              [
                xa("name", "Sum of Sales"),
                xa("fld", "1"),
                xa("baseField", "0"),
                xa("baseItem", "0"),
              ],
              [],
            ),
          ),
          Element(
            xe(
              NS_S,
              "dataField",
              [
                xa("name", "Sum of Cost"),
                xa("fld", "2"),
                xa("baseField", "0"),
                xa("baseItem", "0"),
              ],
              [],
            ),
          ),
        ]),
      ),
    ],
  )
  cases.push({
    id: "pivot-cache-rich",
    format: "xlsx",
    category: "pivot",
    content: source_sheet,
    cache_def,
    cache_records,
    pivot_def,
  })
}
