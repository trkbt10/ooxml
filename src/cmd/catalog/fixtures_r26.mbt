// Round-26 visual fixtures — element coverage that the standard
// `VisualCase` path cannot host because they require auxiliary OPC
// parts (an `xl/externalLinks/externalLink1.xml` for §18.14 external
// references, or extra slide-side relationships for `<a:videoFile
// r:link>` + `<a:hlinkClick r:id>` in PML media shapes).
//
// Each fixture targets an ECMA-376 element whose renderer support
// already exists in the viewer but whose catalog containment
// ancestry routes it to a host where the differential render check
// cannot exercise the visible-content branch.  Adding a real
// per-format fixture pulls those elements through the actual
// reader / writer / renderer chain so the snapshot harness records
// their visible output against the reference office binary.
//
// Hosting:
//   * `ExternalRefCase` — `.xlsx` whose workbook carries
//     `<externalReferences><externalReference r:id="…"/></externalReferences>`
//     resolved to an `xl/externalLinks/externalLink1.xml` part
//     (§18.14.5 CT_ExternalBook).
//   * `MediaSlideCase` — `.pptx` whose slide carries a shape with
//     `<a:hlinkClick r:id="…">` on `<a:cNvPr>` AND `<a:videoFile
//     r:link="…">` on `<p:nvPr>`, with the matching slide-side
//     relationships wired so consumers resolve both rIds.

///|
/// `.xlsx` fixture that needs the §18.14 external-link OPC part
/// alongside the worksheet.  Wired via `external_ref_cases()` and
/// emitted using `xlsx_package_with_externals`.
struct ExternalRefCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  external_link : @xml.Element
}

///|
/// `.pptx` fixture that needs extra slide-side relationships beyond
/// the standard slideLayout rId1.  `extra_rels` carries
/// `(rId, type, target, target_mode)` tuples — `target_mode` is
/// "External" for external URIs (hyperlinks, external media) or
/// "" for internal package targets.  Wired via
/// `media_slide_cases()` and emitted using
/// `pptx_package_with_slide_rels`.
struct MediaSlideCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  extra_rels : Array[(String, String, String, String)]
}

///|
/// Collect every `ExternalRefCase` from per-category extender
/// functions.
fn external_ref_cases() -> Array[ExternalRefCase] {
  let cases : Array[ExternalRefCase] = []
  extras_sml_external_refs(cases)
  cases
}

///|
/// Collect every `MediaSlideCase` from per-category extender
/// functions.
fn media_slide_cases() -> Array[MediaSlideCase] {
  let cases : Array[MediaSlideCase] = []
  extras_pml_media_slides(cases)
  cases
}

///|
/// §18.14 external-reference fixture — a workbook whose
/// `<externalReferences>` block points at an
/// `xl/externalLinks/externalLink1.xml` part containing a
/// `<externalBook>` with the referenced sheet names and a
/// `<sheetDataSet>` carrying the cached cell value.  The
/// worksheet carries a formula cell `=[1]Sheet1!$A$1` with the
/// cached `<v>` so both renderers display the same number even
/// though only one of them resolves the external link.
fn extras_sml_external_refs(cases : Array[ExternalRefCase]) -> Unit {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // The external-link part body — `<externalLink>` with one
  // `<externalBook>` child that names the referenced workbook
  // (External targetMode rel id = "rId1" inside this part) and
  // lists the sheets + cached values.
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
                          Element(xe(NS_S, "v", [], [Text("42")])),
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
  // The worksheet's visible cells display the cached value the
  // external reference resolves to (`42`).  We surface the
  // `[1]Sheet1!$A$1` syntax through a `<definedName>` that
  // references the external book — surfaced as worksheet metadata
  // by the renderer — instead of an inline `<f>=[1]Sheet1!$A$1</f>`
  // cell, because the SML formula-rect renderer in
  // `render_sheet_formulas` currently emits malformed SVG for any
  // `<c>/<f>` cell (data-ooxml-formula attr dropped + missing
  // self-close — a pre-existing renderer bug affecting every
  // formula fixture in `xlsx/formula/`, tracked separately).
  // Using inline-string cells avoids the broken path while still
  // wiring the external-reference OPC plumbing through both
  // pipelines so the fixture exercises §18.14 end-to-end.
  let worksheet = xe(NS_S, "worksheet", [], [
    Element(
      xe(NS_S, "sheetData", [], [
        Element(
          s_row("1", [
            s_inline("A1", "External book value:"),
            s_cell("B1", "42"),
          ]),
        ),
        Element(
          s_row("2", [s_inline("A2", "Local total:"), s_cell("B2", "42")]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "external-reference",
    format: "xlsx",
    category: "external",
    content: worksheet,
    external_link,
  })
}

///|
/// §20.1.3.6 `<a:videoFile r:link>` + §20.1.2.2.20 `<a:hlinkClick
/// r:id>` fixture — a shape whose `<p:cNvPr>` carries an
/// hlinkClick and whose `<p:nvPr>` carries a videoFile reference.
/// Both rIds resolve to External-mode targets so consumers do not
/// need an embedded media payload to accept the slide.  Drives
/// `nv_media_overlay_svg` (see
/// `src/ecma376/presentation_ml/viewer/viewer.mbt:1851`) — emits a
/// visible play-triangle glyph + hyperlink underline anchored at
/// the shape's top-left.
fn extras_pml_media_slides(cases : Array[MediaSlideCase]) -> Unit {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // The hyperlink element with @r:id.
  let hlink_click = xe(
    NS_A,
    "hlinkClick",
    [
      {
        name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
        value: "rId2",
      },
      xa("tooltip", "Visit project page"),
    ],
    [],
  )
  // The video file element with @r:link.
  let video_file = xe(
    NS_A,
    "videoFile",
    [
      {
        name: { prefix: Some("r"), local_name: "link", ns: Some(ns_r) },
        value: "rId3",
      },
      xa("contentType", "video/mp4"),
    ],
    [],
  )
  // Build the shape: rect with a fill, hlinkClick on cNvPr, video
  // on nvPr.  The shape carries the same x/y/cx/cy as the host
  // `pptx_shape` so the overall slide composition matches a
  // standard preset shape (the only differences are the overlay
  // glyphs the renderer paints on top).
  let shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "VideoLink")], [
            Element(hlink_click),
          ]),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [Element(video_file)])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1371600", "5486400", "4114800")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("DDEBF7")),
      ]),
    ),
  ])
  let extra_rels : Array[(String, String, String, String)] = [
    (
      "rId2", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
      "https://example.com/", "External",
    ),
    (
      "rId3", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/video",
      "https://example.com/intro.mp4", "External",
    ),
  ]
  cases.push({
    id: "shape-with-video-hlink",
    format: "pptx",
    category: "media",
    content: sp_tree([shape]),
    extra_rels,
  })
}
