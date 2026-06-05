// Content-rich visual-comparison fixtures.
//
// Distinct from the XSD-enumerated catalog: the catalog's synthesised
// fragments are schema-minimal (mostly empty), so a reference-renderer
// image comparison against them would be vacuous.  The fixtures below
// carry real renderable content — text, tables, equations, shapes.
//
// Every fixture is built as an `@xml.Element` tree (via the `xe`/`xa`
// helpers in verify.mbt) and serialised by `@xml.write`; no XML is
// assembled by string concatenation.

///|
/// Namespace URIs used by the visual fixtures.
const NS_W : String = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

///|
const NS_M : String = "http://schemas.openxmlformats.org/officeDocument/2006/math"

///|
const NS_S : String = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"

///|
const NS_A : String = "http://schemas.openxmlformats.org/drawingml/2006/main"

///|
const NS_PML : String = "http://schemas.openxmlformats.org/presentationml/2006/main"

///|
/// One visual fixture: host format, category folder, id, and the
/// content element tree embedded into that format's host package.
struct VisualCase {
  id : String
  format : String
  category : String
  content : @xml.Element
}

///|
/// A `.pptx` fixture whose slide embeds a binary image part and
/// applies one or more §20.1.8 blip effects to the `<a:blip>`.
struct ImageSlideCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  image_bytes : Bytes
}

///|
/// A fixture that needs auxiliary OPC parts (an xlsx `styles.xml` or
/// a WML `numbering.xml` / `styles.xml`).  Kept as a separate
/// extension struct so the 60+ plain-case constructors do not need
/// updating; `extended_cases()` materialises both.
struct ExtendedCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  styles : @xml.Element?
  numbering : @xml.Element?
  doc_styles : @xml.Element?
}

///|
/// A `.docx` fixture that carries the standard package-level
/// `docProps/core.xml`, `docProps/app.xml`, and
/// `docProps/custom.xml` metadata parts.  Kept separate from
/// `ExtendedCase` because these parts are package-root relationships,
/// not `word/document.xml` auxiliary relationships.
struct MetadataCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  core_properties : @xml.Element
  extended_properties : @xml.Element
  custom_properties : @xml.Element
}

///|
/// A `.docx` fixture that carries a Custom XML Data Storage part
/// plus its `customXmlProps` metadata part.  Kept separate from
/// `MetadataCase` because the payload is a main-document
/// relationship (`word/document.xml.rels`) and the properties part
/// is owned by the custom XML item relationship.
struct CustomXmlCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  custom_xml : @xml.Element
  custom_xml_properties : @xml.Element
}

///|
/// A `.xlsx` fixture whose `<worksheet>` references one or more
/// `<table>` parts via `<tableParts>`.  Distinct from `ExtendedCase`
/// because table parts require extra OPC machinery (per-worksheet
/// `_rels` file, `xl/tables/table*.xml` parts, content-type override)
/// that the styles-only `xlsx_package_styled` builder does not emit.
/// `styles`, when present, is the workbook-level `xl/styles.xml` part
/// used by table AutoFilter tests that need resolved cell fills / dxfs.
///
/// Each `tables[i]` is the `<table>` element that becomes
/// `xl/tables/table{i+1}.xml`; the builder owns the `r:id` numbering
/// and appends `<tableParts>` to the worksheet — the fixture's
/// `content` MUST NOT carry its own `<tableParts>`.  §18.5.1.2.
struct TabledCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  tables : Array[@xml.Element]
  styles : @xml.Element?
}

///|
/// A `.xlsx` fixture whose worksheet references one
/// `xl/drawings/drawing1.xml` Spreadsheet Drawing part.  Distinct
/// from `VisualCase` because the `<xdr:wsDr>` payload is a separate
/// OPC part reached from `<worksheet>/<drawing r:id="...">`.
struct SpreadsheetDrawingCase {
  id : String
  format : String
  category : String
  drawing : @xml.Element
}

///|
/// A `.xlsx` fixture whose worksheet references one legacy VML
/// Drawing part via `<legacyDrawing r:id="...">`.  VML Drawing
/// parts use a null-namespace `<xml>` wrapper with VML payloads
/// beneath it; the builder owns the worksheet relationship and
/// `application/vnd.openxmlformats-officedocument.vmlDrawing`
/// content-type override.
struct VmlDrawingCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  vml_drawing : @xml.Element
}

///|
/// A `.xlsx` fixture exercising §18.10 PivotTable plumbing — three
/// extra parts on top of the worksheet (the pivot table definition,
/// the pivot cache definition, and the pivot cache records) wired
/// through the workbook's `<pivotCaches>`, the worksheet's
/// `_rels`, the cache definition's `_rels`, and the
/// `[Content_Types]` overrides.  Owned by `xlsx_package_with_pivot`
/// in verify.mbt.
///
/// The fixture supplies the four element trees verbatim; the
/// builder owns the rId numbering, the relationship type URIs, and
/// the part-name layout.  The pivot definition's `@cacheId` MUST be
/// `0` so it matches the workbook `<pivotCache cacheId="0"/>` the
/// builder writes.
struct PivotedCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  cache_def : @xml.Element
  cache_records : @xml.Element
  pivot_def : @xml.Element
}

///|
/// A `.xlsx` fixture whose `<worksheet>` carries a Microsoft x14
/// sparklines extension via
/// `<extLst>/<ext uri="…">/<x14:sparklineGroups>`.  The sparkline
/// payload is inline (not a separate OPC part) per `[MS-XLSX]`
/// §2.2.4 — the only piece of OPC machinery this needs is the
/// `xlsx_package_with_sparklines` builder in verify.mbt that
/// splices the `<extLst>` carrier element onto the worksheet's
/// children.
///
/// `content` is the worksheet payload (a `<sheetData>` for a bare
/// grid or a full `<worksheet>` carrying multiple top-level
/// children) and `sparkline_groups` is the `<x14:sparklineGroups>`
/// element tree.  No XML strings anywhere — see AGENTS.md.
struct SparklineCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  sparkline_groups : @xml.Element
}

///|
/// A `.pptx` fixture exercising §21.2 DrawingML chart plumbing —
/// one extra part on top of the slide (the `chartSpace`) wired
/// through the slide's `_rels` (rId2 → `chart1.xml`), the
/// `[Content_Types]` overrides, and a `<p:graphicFrame>` on the
/// slide whose `<a:graphicData @uri="…/chart">` carries a
/// `<c:chart r:id="rId2"/>` payload that resolves to the chart
/// part.  Owned by `pptx_package_with_chart` in verify.mbt.
///
/// The fixture supplies the two element trees verbatim; the
/// builder owns the rId numbering, the relationship type URIs,
/// and the part-name layout.  The `<c:chart r:id="rId2"/>` ref
/// inside `content` MUST match the `rId2` the builder writes.
///
/// §21.2 chart rendering status: `render_graphic_frame_svg`
/// dispatches `<a:graphicData uri="…/chart">` through the
/// DrawingML chart viewer, resolving `rId2` to the chart part the
/// builder writes.  The fixtures therefore exercise the OPC
/// plumbing and the visual chart renderer; unresolved chart
/// references remain the only placeholder path.
struct ChartedCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  chart_space : @xml.Element
}

///|
/// A `.pptx` fixture whose chart part references a Chart Drawing
/// `userShapes` part.  Distinct from `ChartedCase` because the
/// chart part itself owns an additional `_rels/chart1.xml.rels`
/// relationship to `ppt/charts/userShapes1.xml`.
struct ChartUserShapesCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  chart_space : @xml.Element
  user_shapes : @xml.Element
}

///|
/// A `.pptx` fixture exercising §21.4 DrawingML SmartArt / diagram
/// plumbing — four extra parts on top of the slide (data model,
/// layout definition, style definition, color transform) wired
/// through the slide's `_rels` (rId2..rId5 per §21.4 relationship
/// type URIs), the four `[Content_Types]` overrides, and a
/// `<p:graphicFrame>` on the slide whose
/// `<a:graphicData @uri="…/diagram">` carries a `<dgm:relIds>`
/// that resolves the four diagram parts.  Owned by
/// `pptx_package_with_diagram` in verify.mbt.
///
/// The fixture supplies the five element trees verbatim; the
/// builder owns the rId numbering and the part-name layout.  The
/// `<dgm:relIds>` references inside `content` MUST match the
/// `rId2..rId5` the builder writes (`dm`, `lo`, `qs`, `cs`).
///
/// §21.4 diagram rendering status: `render_graphic_frame_svg`
/// detects `<a:graphicData uri="…/diagram">`, resolves the
/// slide-side `<dgm:relIds>` references, and delegates to the
/// SmartArt bridge in `presentation_ml/viewer/diagram_render.mbt`.
/// Layout definitions with geometric constraints render through
/// `@diagram_layout`; unresolved parts, typed decode failures, or
/// layout definitions without geometric constraints fall back to the
/// generic `[Diagram]` placeholder.
struct DiagrammedCase {
  id : String
  format : String
  category : String
  content : @xml.Element
  data_model : @xml.Element
  layout_def : @xml.Element
  style_def : @xml.Element
  colors_def : @xml.Element
  // Optional Microsoft cached drawing extension. ECMA schema-valid
  // fixtures leave this as `None`; extension fixtures may supply a
  // non-ECMA `dsp:drawing` part when testing MS-OOXML interop.
  drawing : @xml.Element?
}

///|
/// A `<w:t>` text element.
fn w_t(text : String) -> @xml.Element {
  xe(
    NS_W,
    "t",
    [
      {
        name: {
          prefix: Some("xml"),
          local_name: "space",
          ns: Some("http://www.w3.org/XML/1998/namespace"),
        },
        value: "preserve",
      },
    ],
    [Text(text)],
  )
}

///|
/// A `<w:r>` run with the given run-property element (or none) and
/// text.
fn w_run(rpr : @xml.Element?, text : String) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  match rpr {
    Some(p) => kids.push(Element(p))
    None => ()
  }
  kids.push(Element(w_t(text)))
  xe(NS_W, "r", [], kids)
}

///|
/// A `<w:rPr>` carrying the given toggle / property elements.
fn w_rpr(props : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for p in props {
    kids.push(Element(p))
  }
  xe(NS_W, "rPr", [], kids)
}

///|
/// An empty WML toggle/property element (`<w:b/>`, `<w:i/>`, …).
fn w_flag(name : String) -> @xml.Element {
  xe(NS_W, name, [], [])
}

///|
/// A WML property element with a single `@w:val` attribute.
fn w_val(name : String, value : String) -> @xml.Element {
  xe(
    NS_W,
    name,
    [{ name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) }, value }],
    [],
  )
}

///|
/// A `<w:p>` paragraph: optional `<w:pPr>` then the run children.
fn w_p(ppr : @xml.Element?, runs : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  match ppr {
    Some(p) => kids.push(Element(p))
    None => ()
  }
  for r in runs {
    kids.push(Element(r))
  }
  xe(NS_W, "p", [], kids)
}

///|
/// The set of visual-comparison cases.
fn visual_cases() -> Array[VisualCase] {
  let cases : Array[VisualCase] = []

  // ---- docx / run -----------------------------------------------
  cases.push({
    id: "run-plain",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Plain text run content.")])),
    ]),
  })
  cases.push({
    id: "run-bold-italic",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "normal "),
          w_run(Some(w_rpr([w_flag("b")])), "bold"),
          w_run(None, " "),
          w_run(Some(w_rpr([w_flag("i")])), "italic"),
        ]),
      ),
    ]),
  })
  cases.push({
    id: "run-underline-strike",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("u", "single")])), "underlined"),
          w_run(None, " and "),
          w_run(Some(w_rpr([w_flag("strike")])), "struck"),
        ]),
      ),
    ]),
  })
  cases.push({
    id: "run-color-size",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_val("color", "C00000"), w_val("sz", "40")])),
            "Large red text",
          ),
        ]),
      ),
    ]),
  })
  cases.push({
    id: "run-highlight",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("highlight", "yellow")])), "highlighted text"),
        ]),
      ),
    ]),
  })

  // ---- docx / paragraph -----------------------------------------
  let jc = fn(v : String) -> @xml.Element {
    xe(NS_W, "pPr", [], [Element(w_val("jc", v))])
  }
  cases.push({
    id: "paragraph-alignment",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(Some(jc("start")), [w_run(None, "Left aligned")])),
      Element(w_p(Some(jc("center")), [w_run(None, "Centre aligned")])),
      Element(w_p(Some(jc("end")), [w_run(None, "Right aligned")])),
    ]),
  })
  cases.push({
    id: "paragraph-wrapping",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            None,
            "This is a long paragraph of body text with many words " +
            "deliberately written to exceed the printable page width so " +
            "that the line breaker must wrap it across several lines.",
          ),
        ]),
      ),
    ]),
  })

  cases.push({
    id: "paragraph-indent",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            xe(NS_W, "pPr", [], [
              Element(
                xe(
                  NS_W,
                  "ind",
                  [
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "left",
                        ns: Some(NS_W),
                      },
                      value: "720",
                    },
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "firstLine",
                        ns: Some(NS_W),
                      },
                      value: "720",
                    },
                  ],
                  [],
                ),
              ),
            ]),
          ),
          [w_run(None, "Indented paragraph with a first-line indent.")],
        ),
      ),
    ]),
  })
  cases.push({
    id: "paragraph-tabs",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Col1"),
          xe(NS_W, "r", [], [Element(xe(NS_W, "tab", [], []))]),
          w_run(None, "Col2"),
          xe(NS_W, "r", [], [Element(xe(NS_W, "tab", [], []))]),
          w_run(None, "Col3"),
        ]),
      ),
    ]),
  })
  // Run with all underline styles in one fixture.
  cases.push({
    id: "run-underline-styles",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(Some(w_rpr([w_val("u", "single")])), "single")])),
      Element(w_p(None, [w_run(Some(w_rpr([w_val("u", "double")])), "double")])),
      Element(w_p(None, [w_run(Some(w_rpr([w_val("u", "thick")])), "thick")])),
      Element(w_p(None, [w_run(Some(w_rpr([w_val("u", "dotted")])), "dotted")])),
      Element(w_p(None, [w_run(Some(w_rpr([w_val("u", "dash")])), "dash")])),
      Element(w_p(None, [w_run(Some(w_rpr([w_val("u", "wave")])), "wave")])),
    ]),
  })

  // Run with several explicit colors via theme codes.
  cases.push({
    id: "run-theme-colors",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("color", "auto")])), "auto "),
          w_run(Some(w_rpr([w_val("color", "FF0000")])), "red "),
          w_run(Some(w_rpr([w_val("color", "00FF00")])), "green "),
          w_run(Some(w_rpr([w_val("color", "0000FF")])), "blue "),
          w_run(Some(w_rpr([w_val("color", "FFC000")])), "amber"),
        ]),
      ),
    ]),
  })

  // Multiple font sizes in one paragraph.
  cases.push({
    id: "run-font-sizes",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("sz", "16")])), "8pt "),
          w_run(Some(w_rpr([w_val("sz", "20")])), "10pt "),
          w_run(Some(w_rpr([w_val("sz", "28")])), "14pt "),
          w_run(Some(w_rpr([w_val("sz", "40")])), "20pt "),
          w_run(Some(w_rpr([w_val("sz", "56")])), "28pt"),
        ]),
      ),
    ]),
  })

  // Mixed text alignments in consecutive paragraphs.
  cases.push({
    id: "paragraph-alignment-all",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(xe(NS_W, "pPr", [], [Element(w_val("jc", "start"))])), [
          w_run(None, "Left aligned paragraph"),
        ]),
      ),
      Element(
        w_p(Some(xe(NS_W, "pPr", [], [Element(w_val("jc", "center"))])), [
          w_run(None, "Center aligned paragraph"),
        ]),
      ),
      Element(
        w_p(Some(xe(NS_W, "pPr", [], [Element(w_val("jc", "end"))])), [
          w_run(None, "Right aligned paragraph"),
        ]),
      ),
      Element(
        w_p(Some(xe(NS_W, "pPr", [], [Element(w_val("jc", "both"))])), [
          w_run(
            None,
            "Justified paragraph with enough text to fill the line and " +
            "demonstrate the justification effect across a wrapped line.",
          ),
        ]),
      ),
    ]),
  })

  // Paragraph with line spacing 1.5×.
  cases.push({
    id: "paragraph-1.5-line",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            xe(NS_W, "pPr", [], [
              Element(
                xe(
                  NS_W,
                  "spacing",
                  [
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "line",
                        ns: Some(NS_W),
                      },
                      value: "360",
                    },
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "lineRule",
                        ns: Some(NS_W),
                      },
                      value: "auto",
                    },
                  ],
                  [],
                ),
              ),
            ]),
          ),
          [
            w_run(
              None,
              "This paragraph uses 1.5-line spacing. Multiple lines of " +
              "wrapped text appear with extra space between each line so " +
              "the difference from single spacing is visible.",
            ),
          ],
        ),
      ),
    ]),
  })

  // Punctuation across various scripts.
  cases.push({
    id: "run-punctuation",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Latin: ! ? . , ; : ' \" ( ) [ ] { }")])),
      Element(
        w_p(None, [w_run(None, "Japanese: 。、・「」『』【】〜")]),
      ),
      Element(
        w_p(None, [w_run(None, "Math: + - × ÷ = ≠ < > ≤ ≥ ± √ π")]),
      ),
    ]),
  })

  // Verbose dummy text — wider variation to stress line breaking.
  cases.push({
    id: "run-stress-wrap",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            None,
            "The quick brown fox jumps over the lazy dog. " +
            "Pack my box with five dozen liquor jugs. " +
            "Sphinx of black quartz, judge my vow. " +
            "How vexingly quick daft zebras jump! " +
            "Crazy Fredrick bought many very exquisite opal jewels.",
          ),
        ]),
      ),
    ]),
  })

  // Numeric digits in different sizes.
  cases.push({
    id: "run-digits",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("sz", "24")])), "0123456789 "),
          w_run(Some(w_rpr([w_val("sz", "40"), w_flag("b")])), "0123456789"),
        ]),
      ),
    ]),
  })

  // Run with size + bold + italic + color simultaneously.
  cases.push({
    id: "run-all-formatting",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(
              w_rpr([
                w_flag("b"),
                w_flag("i"),
                w_val("u", "single"),
                w_val("color", "2E74B5"),
                w_val("sz", "32"),
              ]),
            ),
            "All Formatting Combined",
          ),
        ]),
      ),
    ]),
  })

  // Run with white text on filled background.
  cases.push({
    id: "run-white-on-highlight",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(
              w_rpr([
                w_val("color", "FFFFFF"),
                w_val("highlight", "darkBlue"),
                w_val("sz", "28"),
              ]),
            ),
            "White text on dark blue",
          ),
        ]),
      ),
    ]),
  })

  // Long English text with line wrapping.
  cases.push({
    id: "run-long-text",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            None,
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, " +
            "sed do eiusmod tempor incididunt ut labore et dolore magna " +
            "aliqua. Ut enim ad minim veniam, quis nostrud exercitation " +
            "ullamco laboris nisi ut aliquip ex ea commodo consequat.",
          ),
        ]),
      ),
    ]),
  })

  // Long Japanese text — exercises CJK wrapping.
  cases.push({
    id: "run-long-japanese",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            None,
            "吾輩は猫である。名前はまだ無い。どこで生れたかとんと見当が" +
            "つかぬ。何でも薄暗いじめじめした所でニャーニャー泣いて居た" +
            "事丈は記憶して居る。吾輩はここで始めて人間というものを見た。",
          ),
        ]),
      ),
    ]),
  })

  // Empty paragraph followed by content (blank lines).
  cases.push({
    id: "paragraph-blank-lines",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "First paragraph.")])),
      Element(w_p(None, [])),
      Element(w_p(None, [])),
      Element(w_p(None, [w_run(None, "Fourth paragraph (after two blanks).")])),
    ]),
  })

  // Different language text — CJK
  cases.push({
    id: "run-cjk",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [w_run(None, "日本語テキストのレンダリング")]),
      ),
      Element(w_p(None, [w_run(None, "中文文本渲染")])),
      Element(w_p(None, [w_run(None, "한국어 텍스트 렌더링")])),
    ]),
  })

  // Mixed Latin + CJK in one run.
  cases.push({
    id: "run-mixed-script",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Hello 世界 — Mixed Latin + CJK")])),
    ]),
  })

  // Special characters / typography
  cases.push({
    id: "run-special-chars",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "© ® ™ — “smart quotes” and—em dash"),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(None, "Math: α β γ × ÷ ≈ ≠ ≤ ≥ ∞ ∂ ∫"),
        ]),
      ),
    ]),
  })

  // Multiple paragraphs with alternating bold for visual variety.
  cases.push({
    id: "paragraph-alternating",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(Some(w_rpr([w_flag("b")])), "Header 1")])),
      Element(w_p(None, [w_run(None, "Body paragraph below header 1.")])),
      Element(w_p(None, [w_run(Some(w_rpr([w_flag("b")])), "Header 2")])),
      Element(w_p(None, [w_run(None, "Body paragraph below header 2.")])),
    ]),
  })

  // Paragraph with empty text run (edge case).
  cases.push({
    id: "paragraph-empty",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "")])),
      Element(w_p(None, [w_run(None, "After empty paragraph.")])),
    ]),
  })

  // Paragraph with mixed inline elements (text + line break + text).
  cases.push({
    id: "paragraph-mixed-inline",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Before "),
          w_run(Some(w_rpr([w_flag("b")])), "bold"),
          w_run(None, " — "),
          w_run(Some(w_rpr([w_flag("i")])), "italic"),
          w_run(None, " — "),
          w_run(Some(w_rpr([w_val("u", "single")])), "underline"),
          w_run(None, " — "),
          w_run(Some(w_rpr([w_val("color", "C00000")])), "red"),
        ]),
      ),
    ]),
  })

  // Run with stretched (kern) — kerning.
  cases.push({
    id: "run-kerning",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [w_run(Some(w_rpr([w_val("kern", "1")])), "AVATAR (kerned)")]),
      ),
    ]),
  })

  // Hidden / vanish text (`<w:vanish/>`) — should be invisible.
  cases.push({
    id: "run-vanish",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Visible "),
          w_run(Some(w_rpr([w_flag("vanish")])), "[hidden]"),
          w_run(None, " visible again"),
        ]),
      ),
    ]),
  })

  // Caps (all caps) — text rendered in uppercase even if input is mixed.
  cases.push({
    id: "run-caps",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [w_run(Some(w_rpr([w_flag("caps")])), "All caps render")]),
      ),
    ]),
  })

  // Run with explicit em (emphasis-mark) — a dot above each glyph.
  cases.push({
    id: "run-emphasis",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_val("em", "dot")])),
            "強調マーク付きテキスト",
          ),
        ]),
      ),
    ]),
  })

  // Run with double-underline + small-caps.
  cases.push({
    id: "run-doubleunderline",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("u", "double")])), "Double-underlined text"),
        ]),
      ),
    ]),
  })
  cases.push({
    id: "run-smallcaps",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [w_run(Some(w_rpr([w_flag("smallCaps")])), "Small Caps Text")]),
      ),
    ]),
  })
  // Several bold/italic combinations.
  cases.push({
    id: "run-bold-italic-combo",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "normal | "),
          w_run(Some(w_rpr([w_flag("b")])), "bold "),
          w_run(Some(w_rpr([w_flag("i")])), "italic "),
          w_run(Some(w_rpr([w_flag("b"), w_flag("i")])), "bold-italic"),
        ]),
      ),
    ]),
  })

  // Run with character spacing (`<w:spacing w:val="40">`) and
  // expansion (w:w scale).
  cases.push({
    id: "run-spacing-stretch",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("spacing", "40")])), "Wide-spaced text"),
        ]),
      ),
      Element(
        w_p(None, [w_run(Some(w_rpr([w_val("w", "150")])), "Stretched 150%")]),
      ),
    ]),
  })
  // Multiple runs with different colors in one paragraph.
  cases.push({
    id: "run-mixed-colors",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("color", "C00000")])), "Red "),
          w_run(Some(w_rpr([w_val("color", "00B050")])), "Green "),
          w_run(Some(w_rpr([w_val("color", "0070C0")])), "Blue "),
          w_run(None, "default"),
        ]),
      ),
    ]),
  })

  // Run with explicit font family — `<w:rFonts w:ascii="...">`.
  let w_rfonts = fn(ascii_face : String) -> @xml.Element {
    xe(
      NS_W,
      "rFonts",
      [
        {
          name: { prefix: Some("w"), local_name: "ascii", ns: Some(NS_W) },
          value: ascii_face,
        },
        {
          name: { prefix: Some("w"), local_name: "hAnsi", ns: Some(NS_W) },
          value: ascii_face,
        },
      ],
      [],
    )
  }
  cases.push({
    id: "run-font-family",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_rfonts("Times New Roman")])), "Serif text."),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_rfonts("Courier New")])), "Monospace text."),
        ]),
      ),
    ]),
  })

  cases.push({
    id: "run-superscript-subscript",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "E = mc"),
          w_run(Some(w_rpr([w_val("vertAlign", "superscript")])), "2"),
          w_run(None, " and H"),
          w_run(Some(w_rpr([w_val("vertAlign", "subscript")])), "2"),
          w_run(None, "O"),
        ]),
      ),
    ]),
  })
  // Paragraph shading — `<w:pPr><w:shd>` paints a background fill
  // behind the whole paragraph.
  cases.push({
    id: "paragraph-shading",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            xe(NS_W, "pPr", [], [
              Element(
                xe(
                  NS_W,
                  "shd",
                  [
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "val",
                        ns: Some(NS_W),
                      },
                      value: "clear",
                    },
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "fill",
                        ns: Some(NS_W),
                      },
                      value: "D9E2F3",
                    },
                  ],
                  [],
                ),
              ),
            ]),
          ),
          [w_run(None, "Paragraph with a shaded background fill.")],
        ),
      ),
    ]),
  })
  // Paragraph borders — `<w:pPr><w:pBdr>` boxes the paragraph.
  let p_bdr_side = fn(side : String) -> @xml.Element {
    xe(
      NS_W,
      side,
      [
        {
          name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
          value: "single",
        },
        {
          name: { prefix: Some("w"), local_name: "sz", ns: Some(NS_W) },
          value: "12",
        },
        {
          name: { prefix: Some("w"), local_name: "space", ns: Some(NS_W) },
          value: "4",
        },
        {
          name: { prefix: Some("w"), local_name: "color", ns: Some(NS_W) },
          value: "2E74B5",
        },
      ],
      [],
    )
  }
  cases.push({
    id: "paragraph-border",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            xe(NS_W, "pPr", [], [
              Element(
                xe(NS_W, "pBdr", [], [
                  Element(p_bdr_side("top")),
                  Element(p_bdr_side("left")),
                  Element(p_bdr_side("bottom")),
                  Element(p_bdr_side("right")),
                ]),
              ),
            ]),
          ),
          [w_run(None, "Paragraph enclosed in a border box.")],
        ),
      ),
    ]),
  })
  // Paragraph spacing — `<w:spacing>` before/after in twentieths-of-
  // a-point.  240 = 12pt.
  let spacing_pr = xe(NS_W, "pPr", [], [
    Element(
      xe(
        NS_W,
        "spacing",
        [
          {
            name: { prefix: Some("w"), local_name: "before", ns: Some(NS_W) },
            value: "240",
          },
          {
            name: { prefix: Some("w"), local_name: "after", ns: Some(NS_W) },
            value: "240",
          },
        ],
        [],
      ),
    ),
  ])
  cases.push({
    id: "paragraph-spacing",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "First paragraph (no extra spacing).")])),
      Element(
        w_p(Some(spacing_pr), [
          w_run(None, "Second paragraph (12pt above and below)."),
        ]),
      ),
      Element(
        w_p(None, [w_run(None, "Third paragraph (after the spaced one).")]),
      ),
    ]),
  })
  // A heading-sized run (28pt bold) — exercises font-size cascade and
  // bold rendering at a larger size than the body fixtures.
  cases.push({
    id: "paragraph-heading-like",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_flag("b"), w_val("sz", "56")])),
            "Chapter Heading",
          ),
        ]),
      ),
      Element(w_p(None, [w_run(None, "Body text following the heading.")])),
    ]),
  })

  // Explicit line breaks within a run — `<w:br/>` splits text onto
  // new lines without starting a new paragraph.
  cases.push({
    id: "run-linebreak",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          xe(NS_W, "r", [], [
            Element(w_t("First line")),
            Element(xe(NS_W, "br", [], [])),
            Element(w_t("Second line")),
            Element(xe(NS_W, "br", [], [])),
            Element(w_t("Third line")),
          ]),
        ]),
      ),
    ]),
  })
  // RTL paragraph — right-to-left reading direction.
  cases.push({
    id: "paragraph-rtl",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(xe(NS_W, "pPr", [], [Element(xe(NS_W, "bidi", [], []))])), [
          w_run(None, "Right-to-left paragraph content."),
        ]),
      ),
    ]),
  })

  // Paragraph with first-line indent only.
  cases.push({
    id: "paragraph-firstline",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            xe(NS_W, "pPr", [], [
              Element(
                xe(
                  NS_W,
                  "ind",
                  [
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "firstLine",
                        ns: Some(NS_W),
                      },
                      value: "720",
                    },
                  ],
                  [],
                ),
              ),
            ]),
          ),
          [
            w_run(
              None,
              "This paragraph has a first-line indent (no left indent), " +
              "so only the opening line is pushed inward while the " +
              "wrapped continuation flows back to the margin.",
            ),
          ],
        ),
      ),
    ]),
  })

  // Hanging indent — first line at margin, continuation indented.
  cases.push({
    id: "paragraph-hanging",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(
          Some(
            xe(NS_W, "pPr", [], [
              Element(
                xe(
                  NS_W,
                  "ind",
                  [
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "left",
                        ns: Some(NS_W),
                      },
                      value: "720",
                    },
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "hanging",
                        ns: Some(NS_W),
                      },
                      value: "720",
                    },
                  ],
                  [],
                ),
              ),
            ]),
          ),
          [
            w_run(
              None,
              "Title — This paragraph uses a hanging indent: the first " +
              "line touches the margin and the continuation lines hang " +
              "indented by half-inch, useful for term–definition pairs.",
            ),
          ],
        ),
      ),
    ]),
  })

  // Centred paragraph with bold + colored text — combines paragraph
  // alignment + run formatting.
  cases.push({
    id: "paragraph-centered-bold-color",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(xe(NS_W, "pPr", [], [Element(w_val("jc", "center"))])), [
          w_run(
            Some(
              w_rpr([w_flag("b"), w_val("color", "2E74B5"), w_val("sz", "32")]),
            ),
            "Centered Bold Blue Heading",
          ),
        ]),
      ),
    ]),
  })

  // Right-aligned paragraph.
  cases.push({
    id: "paragraph-right-aligned",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(xe(NS_W, "pPr", [], [Element(w_val("jc", "end"))])), [
          w_run(None, "Right-aligned paragraph text."),
        ]),
      ),
    ]),
  })

  // Justified paragraph with wrapping — exercises the layout
  // engine's justification logic.
  cases.push({
    id: "paragraph-justified",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(Some(xe(NS_W, "pPr", [], [Element(w_val("jc", "both"))])), [
          w_run(
            None,
            "This justified paragraph contains enough words to force " +
            "wrapping across multiple lines so the layout engine has " +
            "to distribute the extra inter-word space evenly along " +
            "each filled line.",
          ),
        ]),
      ),
    ]),
  })

  // Section with custom page size — `<w:sectPr><w:pgSz>` defining A5
  // dimensions in twentieths of a point.
  cases.push({
    id: "paragraph-pagesize-a5",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Document with custom A5 page size.")])),
      Element(
        xe(NS_W, "sectPr", [], [
          Element(
            xe(
              NS_W,
              "pgSz",
              [
                {
                  name: { prefix: Some("w"), local_name: "w", ns: Some(NS_W) },
                  value: "8391",
                },
                {
                  name: { prefix: Some("w"), local_name: "h", ns: Some(NS_W) },
                  value: "11907",
                },
              ],
              [],
            ),
          ),
        ]),
      ),
    ]),
  })

  // Multiple paragraphs — vertical stacking and inter-paragraph
  // spacing.
  cases.push({
    id: "paragraph-multiple",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "First paragraph of the document.")])),
      Element(w_p(None, [w_run(None, "Second paragraph follows below.")])),
      Element(w_p(None, [w_run(None, "Third and last paragraph here.")])),
    ]),
  })

  // ---- docx / table ---------------------------------------------
  // A 2x2 bordered table.  CT_Tbl: tblPr (with tblBorders) → tblGrid
  // (gridCol per column) → tr (rows) → tc (cells, each tcPr + p).
  let tbl_border = fn(side : String) -> @xml.Element {
    xe(
      NS_W,
      side,
      [
        {
          name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
          value: "single",
        },
        {
          name: { prefix: Some("w"), local_name: "sz", ns: Some(NS_W) },
          value: "8",
        },
        {
          name: { prefix: Some("w"), local_name: "color", ns: Some(NS_W) },
          value: "000000",
        },
      ],
      [],
    )
  }
  let tc = fn(text : String) -> @xml.Element {
    xe(NS_W, "tc", [], [
      Element(
        xe(NS_W, "tcPr", [], [
          Element(
            xe(
              NS_W,
              "tcW",
              [
                {
                  name: { prefix: Some("w"), local_name: "w", ns: Some(NS_W) },
                  value: "2400",
                },
                {
                  name: {
                    prefix: Some("w"),
                    local_name: "type",
                    ns: Some(NS_W),
                  },
                  value: "dxa",
                },
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(w_p(None, [w_run(None, text)])),
    ])
  }
  let tr = fn(cells : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in cells {
      kids.push(Element(c))
    }
    xe(NS_W, "tr", [], kids)
  }
  let grid_col = xe(
    NS_W,
    "gridCol",
    [
      {
        name: { prefix: Some("w"), local_name: "w", ns: Some(NS_W) },
        value: "2400",
      },
    ],
    [],
  )
  cases.push({
    id: "table-bordered",
    format: "docx",
    category: "table",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "tbl", [], [
          Element(
            xe(NS_W, "tblPr", [], [
              Element(
                xe(NS_W, "tblBorders", [], [
                  Element(tbl_border("top")),
                  Element(tbl_border("left")),
                  Element(tbl_border("bottom")),
                  Element(tbl_border("right")),
                  Element(tbl_border("insideH")),
                  Element(tbl_border("insideV")),
                ]),
              ),
            ]),
          ),
          Element(
            xe(NS_W, "tblGrid", [], [Element(grid_col), Element(grid_col)]),
          ),
          Element(tr([tc("Item"), tc("Qty")])),
          Element(tr([tc("Apples"), tc("12")])),
        ]),
      ),
    ]),
  })
  // A 3×3 table with header row shading — exercises `<w:shd>` on
  // a `<w:tc>` and a larger grid.
  let tc_shaded = fn(text : String) -> @xml.Element {
    xe(NS_W, "tc", [], [
      Element(
        xe(NS_W, "tcPr", [], [
          Element(
            xe(
              NS_W,
              "tcW",
              [
                {
                  name: { prefix: Some("w"), local_name: "w", ns: Some(NS_W) },
                  value: "1800",
                },
                {
                  name: {
                    prefix: Some("w"),
                    local_name: "type",
                    ns: Some(NS_W),
                  },
                  value: "dxa",
                },
              ],
              [],
            ),
          ),
          Element(
            xe(
              NS_W,
              "shd",
              [
                {
                  name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
                  value: "clear",
                },
                {
                  name: {
                    prefix: Some("w"),
                    local_name: "fill",
                    ns: Some(NS_W),
                  },
                  value: "D9E2F3",
                },
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(w_p(None, [w_run(Some(w_rpr([w_flag("b")])), text)])),
    ])
  }
  let tc_narrow = fn(text : String) -> @xml.Element {
    xe(NS_W, "tc", [], [
      Element(
        xe(NS_W, "tcPr", [], [
          Element(
            xe(
              NS_W,
              "tcW",
              [
                {
                  name: { prefix: Some("w"), local_name: "w", ns: Some(NS_W) },
                  value: "1800",
                },
                {
                  name: {
                    prefix: Some("w"),
                    local_name: "type",
                    ns: Some(NS_W),
                  },
                  value: "dxa",
                },
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(w_p(None, [w_run(None, text)])),
    ])
  }
  let grid_col_narrow = xe(
    NS_W,
    "gridCol",
    [
      {
        name: { prefix: Some("w"), local_name: "w", ns: Some(NS_W) },
        value: "1800",
      },
    ],
    [],
  )
  cases.push({
    id: "table-shaded-header",
    format: "docx",
    category: "table",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "tbl", [], [
          Element(
            xe(NS_W, "tblPr", [], [
              Element(
                xe(NS_W, "tblBorders", [], [
                  Element(tbl_border("top")),
                  Element(tbl_border("left")),
                  Element(tbl_border("bottom")),
                  Element(tbl_border("right")),
                  Element(tbl_border("insideH")),
                  Element(tbl_border("insideV")),
                ]),
              ),
            ]),
          ),
          Element(
            xe(NS_W, "tblGrid", [], [
              Element(grid_col_narrow),
              Element(grid_col_narrow),
              Element(grid_col_narrow),
            ]),
          ),
          Element(
            tr([tc_shaded("Region"), tc_shaded("Sales"), tc_shaded("Growth")]),
          ),
          Element(tr([tc_narrow("North"), tc_narrow("100"), tc_narrow("12%")])),
          Element(tr([tc_narrow("South"), tc_narrow("85"), tc_narrow("8%")])),
          Element(tr([tc_narrow("East"), tc_narrow("120"), tc_narrow("15%")])),
        ]),
      ),
    ]),
  })
  // A 4-column table with mixed-text rows (numeric, label, formula-like).
  cases.push({
    id: "table-4col",
    format: "docx",
    category: "table",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "tbl", [], [
          Element(
            xe(NS_W, "tblPr", [], [
              Element(
                xe(NS_W, "tblBorders", [], [
                  Element(tbl_border("top")),
                  Element(tbl_border("left")),
                  Element(tbl_border("bottom")),
                  Element(tbl_border("right")),
                  Element(tbl_border("insideH")),
                  Element(tbl_border("insideV")),
                ]),
              ),
            ]),
          ),
          Element(
            xe(NS_W, "tblGrid", [], [
              Element(grid_col_narrow),
              Element(grid_col_narrow),
              Element(grid_col_narrow),
              Element(grid_col_narrow),
            ]),
          ),
          Element(
            tr([
              tc_narrow("Q1"),
              tc_narrow("Q2"),
              tc_narrow("Q3"),
              tc_narrow("Q4"),
            ]),
          ),
          Element(
            tr([
              tc_narrow("100"),
              tc_narrow("110"),
              tc_narrow("120"),
              tc_narrow("130"),
            ]),
          ),
          Element(
            tr([
              tc_narrow("105"),
              tc_narrow("115"),
              tc_narrow("125"),
              tc_narrow("135"),
            ]),
          ),
        ]),
      ),
    ]),
  })

  // A 1-row tall-cell table — exercises auto cell height.
  cases.push({
    id: "table-tall-row",
    format: "docx",
    category: "table",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "tbl", [], [
          Element(
            xe(NS_W, "tblPr", [], [
              Element(
                xe(NS_W, "tblBorders", [], [
                  Element(tbl_border("top")),
                  Element(tbl_border("left")),
                  Element(tbl_border("bottom")),
                  Element(tbl_border("right")),
                  Element(tbl_border("insideH")),
                  Element(tbl_border("insideV")),
                ]),
              ),
            ]),
          ),
          Element(
            xe(NS_W, "tblGrid", [], [Element(grid_col), Element(grid_col)]),
          ),
          Element(
            tr([
              tc("Heading"),
              {
                let kids : Array[@xml.Node] = [
                  Element(
                    xe(NS_W, "tcPr", [], [
                      Element(
                        xe(
                          NS_W,
                          "tcW",
                          [
                            {
                              name: {
                                prefix: Some("w"),
                                local_name: "w",
                                ns: Some(NS_W),
                              },
                              value: "2400",
                            },
                            {
                              name: {
                                prefix: Some("w"),
                                local_name: "type",
                                ns: Some(NS_W),
                              },
                              value: "dxa",
                            },
                          ],
                          [],
                        ),
                      ),
                    ]),
                  ),
                  Element(w_p(None, [w_run(None, "Line one")])),
                  Element(w_p(None, [w_run(None, "Line two")])),
                  Element(w_p(None, [w_run(None, "Line three")])),
                ]
                xe(NS_W, "tc", [], kids)
              },
            ]),
          ),
        ]),
      ),
    ]),
  })

  // A table with NO borders (default cell padding only) — exercises
  // the no-border render path which differs from the bordered one.
  cases.push({
    id: "table-borderless",
    format: "docx",
    category: "table",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "tbl", [], [
          Element(
            xe(NS_W, "tblPr", [], [
              Element(
                xe(NS_W, "tblBorders", [], [
                  Element(
                    xe(
                      NS_W,
                      "top",
                      [
                        {
                          name: {
                            prefix: Some("w"),
                            local_name: "val",
                            ns: Some(NS_W),
                          },
                          value: "none",
                        },
                      ],
                      [],
                    ),
                  ),
                  Element(
                    xe(
                      NS_W,
                      "left",
                      [
                        {
                          name: {
                            prefix: Some("w"),
                            local_name: "val",
                            ns: Some(NS_W),
                          },
                          value: "none",
                        },
                      ],
                      [],
                    ),
                  ),
                  Element(
                    xe(
                      NS_W,
                      "bottom",
                      [
                        {
                          name: {
                            prefix: Some("w"),
                            local_name: "val",
                            ns: Some(NS_W),
                          },
                          value: "none",
                        },
                      ],
                      [],
                    ),
                  ),
                  Element(
                    xe(
                      NS_W,
                      "right",
                      [
                        {
                          name: {
                            prefix: Some("w"),
                            local_name: "val",
                            ns: Some(NS_W),
                          },
                          value: "none",
                        },
                      ],
                      [],
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          Element(
            xe(NS_W, "tblGrid", [], [Element(grid_col), Element(grid_col)]),
          ),
          Element(tr([tc("Name"), tc("Value")])),
          Element(tr([tc("Foo"), tc("42")])),
        ]),
      ),
    ]),
  })

  // ---- docx / math (OMML) ---------------------------------------
  let m_t = fn(text : String) -> @xml.Element {
    xe(NS_M, "t", [], [Text(text)])
  }
  let m_r = fn(text : String) -> @xml.Element {
    xe(NS_M, "r", [], [Element(m_t(text))])
  }
  let m_arg = fn(name : String, inner : @xml.Element) -> @xml.Element {
    xe(NS_M, name, [], [Element(inner)])
  }
  // a/b fraction.
  let frac = xe(NS_M, "f", [], [
    Element(m_arg("num", m_r("a"))),
    Element(m_arg("den", m_r("b"))),
  ])
  cases.push({
    id: "math-fraction",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(frac)]))]),
      ),
    ]),
  })
  // x squared superscript.
  let sup = xe(NS_M, "sSup", [], [
    Element(m_arg("e", m_r("x"))),
    Element(m_arg("sup", m_r("2"))),
  ])
  cases.push({
    id: "math-script",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(sup)]))]),
      ),
    ]),
  })

  // square-root radical: √(x+1).
  let rad = xe(NS_M, "rad", [], [
    Element(xe(NS_M, "radPr", [], [])),
    Element(m_arg("deg", xe(NS_M, "r", [], []))),
    Element(m_arg("e", m_r("x+1"))),
  ])
  cases.push({
    id: "math-radical",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(rad)]))]),
      ),
    ]),
  })
  // a full equation: x = (a + b) / c, fraction of a sum.
  let eq = xe(NS_M, "f", [], [
    Element(m_arg("num", m_r("a + b"))),
    Element(m_arg("den", m_r("c"))),
  ])
  cases.push({
    id: "math-equation",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(xe(NS_M, "oMath", [], [Element(m_r("x = ")), Element(eq)])),
        ]),
      ),
    ]),
  })
  // Subscript: x_n
  let sub = xe(NS_M, "sSub", [], [
    Element(m_arg("e", m_r("x"))),
    Element(m_arg("sub", m_r("n"))),
  ])
  cases.push({
    id: "math-subscript",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(sub)]))]),
      ),
    ]),
  })
  // Subscript+Superscript combined: x_i^2
  let sub_sup = xe(NS_M, "sSubSup", [], [
    Element(m_arg("e", m_r("x"))),
    Element(m_arg("sub", m_r("i"))),
    Element(m_arg("sup", m_r("2"))),
  ])
  cases.push({
    id: "math-subsup",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(sub_sup)]))]),
      ),
    ]),
  })
  // Delimiter (parentheses) around an inner expression: (a + b)
  let delim = xe(NS_M, "d", [], [
    Element(xe(NS_M, "dPr", [], [])),
    Element(m_arg("e", m_r("a + b"))),
  ])
  cases.push({
    id: "math-delimiter",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(delim)]))]),
      ),
    ]),
  })
  // N-ary sum: Σ from i=1 to n of x_i
  let nary_sum = xe(NS_M, "nary", [], [
    Element(
      xe(NS_M, "naryPr", [], [
        Element(
          xe(
            NS_M,
            "chr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "∑",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("sub", m_r("i=1"))),
    Element(m_arg("sup", m_r("n"))),
    Element(
      m_arg(
        "e",
        xe(NS_M, "sSub", [], [
          Element(m_arg("e", m_r("x"))),
          Element(m_arg("sub", m_r("i"))),
        ]),
      ),
    ),
  ])
  cases.push({
    id: "math-summation",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(nary_sum)]))]),
      ),
    ]),
  })
  // N-ary integral: ∫ from 0 to 1 of f(x) dx
  let nary_int = xe(NS_M, "nary", [], [
    Element(xe(NS_M, "naryPr", [], [])),
    Element(m_arg("sub", m_r("0"))),
    Element(m_arg("sup", m_r("1"))),
    Element(m_arg("e", m_r("f(x) dx"))),
  ])
  cases.push({
    id: "math-integral",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(nary_int)]))]),
      ),
    ]),
  })
  // 2×2 matrix: [a b; c d]
  let m_e = fn(text : String) -> @xml.Element {
    xe(NS_M, "e", [], [Element(m_r(text))])
  }
  let matrix = xe(NS_M, "m", [], [
    Element(xe(NS_M, "mPr", [], [])),
    Element(xe(NS_M, "mr", [], [Element(m_e("a")), Element(m_e("b"))])),
    Element(xe(NS_M, "mr", [], [Element(m_e("c")), Element(m_e("d"))])),
  ])
  cases.push({
    id: "math-matrix",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(matrix)]))]),
      ),
    ]),
  })
  // Accent — vector arrow over a variable: x⃗
  let accent = xe(NS_M, "acc", [], [
    Element(
      xe(NS_M, "accPr", [], [
        Element(
          xe(
            NS_M,
            "chr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "⃗",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("e", m_r("x"))),
  ])
  cases.push({
    id: "math-accent",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(accent)]))]),
      ),
    ]),
  })
  // Stacked fraction with sub-script in numerator: (x/y)_n
  let stacked_subbed = xe(NS_M, "sSub", [], [
    Element(
      m_arg(
        "e",
        xe(NS_M, "f", [], [
          Element(m_arg("num", m_r("x"))),
          Element(m_arg("den", m_r("y"))),
        ]),
      ),
    ),
    Element(m_arg("sub", m_r("n"))),
  ])
  cases.push({
    id: "math-fraction-subscript",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(xe(NS_M, "oMath", [], [Element(stacked_subbed)])),
        ]),
      ),
    ]),
  })

  // n-ary union: ⋃
  let nary_union = xe(NS_M, "nary", [], [
    Element(
      xe(NS_M, "naryPr", [], [
        Element(
          xe(
            NS_M,
            "chr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "⋃",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("sub", m_r("i=1"))),
    Element(m_arg("sup", m_r("n"))),
    Element(m_arg("e", m_r("A"))),
  ])
  cases.push({
    id: "math-union",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(xe(NS_M, "oMath", [], [Element(nary_union)])),
        ]),
      ),
    ]),
  })
  // n-ary intersection: ⋂
  let nary_inter = xe(NS_M, "nary", [], [
    Element(
      xe(NS_M, "naryPr", [], [
        Element(
          xe(
            NS_M,
            "chr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "⋂",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("sub", m_r("i=1"))),
    Element(m_arg("sup", m_r("n"))),
    Element(m_arg("e", m_r("A"))),
  ])
  cases.push({
    id: "math-intersection",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(xe(NS_M, "oMath", [], [Element(nary_inter)])),
        ]),
      ),
    ]),
  })
  // Box around an expression: ▢ x
  let math_box = xe(NS_M, "box", [], [
    Element(xe(NS_M, "boxPr", [], [])),
    Element(m_arg("e", m_r("x + y"))),
  ])
  cases.push({
    id: "math-box",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(math_box)]))]),
      ),
    ]),
  })
  // borderBox around an expression
  let bborder = xe(NS_M, "borderBox", [], [
    Element(xe(NS_M, "borderBoxPr", [], [])),
    Element(m_arg("e", m_r("a²+b²=c²"))),
  ])
  cases.push({
    id: "math-borderbox",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(bborder)]))]),
      ),
    ]),
  })
  // groupChr — an under/over symbol grouping
  let group_chr = xe(NS_M, "groupChr", [], [
    Element(
      xe(NS_M, "groupChrPr", [], [
        Element(
          xe(
            NS_M,
            "chr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "⏟",
              },
            ],
            [],
          ),
        ),
        Element(
          xe(
            NS_M,
            "pos",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "bot",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("e", m_r("x + y + z"))),
  ])
  cases.push({
    id: "math-groupchr",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(group_chr)]))]),
      ),
    ]),
  })
  // limUpp / limLow — upper/lower limits
  let lim_upp = xe(NS_M, "limUpp", [], [
    Element(m_arg("e", m_r("max"))),
    Element(m_arg("lim", m_r("n"))),
  ])
  cases.push({
    id: "math-limupp",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(lim_upp)]))]),
      ),
    ]),
  })
  let lim_low = xe(NS_M, "limLow", [], [
    Element(m_arg("e", m_r("lim"))),
    Element(m_arg("lim", m_r("x→∞"))),
  ])
  cases.push({
    id: "math-limlow",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(lim_low)]))]),
      ),
    ]),
  })

  // Curly-brace delimiter — {a + b}
  let curly_delim = xe(NS_M, "d", [], [
    Element(
      xe(NS_M, "dPr", [], [
        Element(
          xe(
            NS_M,
            "begChr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "{",
              },
            ],
            [],
          ),
        ),
        Element(
          xe(
            NS_M,
            "endChr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "}",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("e", m_r("a + b"))),
  ])
  cases.push({
    id: "math-delim-curly",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(xe(NS_M, "oMath", [], [Element(curly_delim)])),
        ]),
      ),
    ]),
  })

  // Bar (overline) on an expression: x̄
  let bar = xe(NS_M, "bar", [], [
    Element(xe(NS_M, "barPr", [], [])),
    Element(m_arg("e", m_r("x"))),
  ])
  cases.push({
    id: "math-bar",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(bar)]))]),
      ),
    ]),
  })
  // N-ary product: Π
  let nary_prod = xe(NS_M, "nary", [], [
    Element(
      xe(NS_M, "naryPr", [], [
        Element(
          xe(
            NS_M,
            "chr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "∏",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("sub", m_r("i=1"))),
    Element(m_arg("sup", m_r("n"))),
    Element(m_arg("e", m_r("x"))),
  ])
  cases.push({
    id: "math-product",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(nary_prod)]))]),
      ),
    ]),
  })
  // Square brackets delimiter: [a, b]
  let brack_delim = xe(NS_M, "d", [], [
    Element(
      xe(NS_M, "dPr", [], [
        Element(
          xe(
            NS_M,
            "begChr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "[",
              },
            ],
            [],
          ),
        ),
        Element(
          xe(
            NS_M,
            "endChr",
            [
              {
                name: { prefix: Some("m"), local_name: "val", ns: Some(NS_M) },
                value: "]",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(m_arg("e", m_r("a, b"))),
  ])
  cases.push({
    id: "math-delim-brackets",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(xe(NS_M, "oMath", [], [Element(brack_delim)])),
        ]),
      ),
    ]),
  })
  // Pre-script: ⁿxₖ — m:sPre with sub/sup before the base
  let pre_script = xe(NS_M, "sPre", [], [
    Element(m_arg("sub", m_r("k"))),
    Element(m_arg("sup", m_r("n"))),
    Element(m_arg("e", m_r("x"))),
  ])
  cases.push({
    id: "math-prescript",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(xe(NS_M, "oMath", [], [Element(pre_script)])),
        ]),
      ),
    ]),
  })
  // Function: f(x) using m:func
  let func_app = xe(NS_M, "func", [], [
    Element(m_arg("fName", m_r("sin"))),
    Element(m_arg("e", m_r("x"))),
  ])
  cases.push({
    id: "math-function",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(func_app)]))]),
      ),
    ]),
  })

  // ---- pptx / shape ---------------------------------------------
  // A slide shape: nvSpPr + spPr (xfrm + prstGeom) + a solid fill.
  let sp_xfrm = fn(
    x : String,
    y : String,
    cx : String,
    cy : String,
  ) -> @xml.Element {
    xe(NS_A, "xfrm", [], [
      Element(xe(NS_A, "off", [xa("x", x), xa("y", y)], [])),
      Element(xe(NS_A, "ext", [xa("cx", cx), xa("cy", cy)], [])),
    ])
  }
  let solid_fill = fn(hex : String) -> @xml.Element {
    xe(NS_A, "solidFill", [], [
      Element(xe(NS_A, "srgbClr", [xa("val", hex)], [])),
    ])
  }
  let pptx_shape = fn(
    id_ : String,
    name : String,
    prst : String,
    x : String,
    y : String,
    cx : String,
    cy : String,
    hex : String,
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
          Element(solid_fill(hex)),
        ]),
      ),
    ])
  }
  // The slide tree: cSld → spTree → (nvGrpSpPr + grpSpPr + shapes).
  let sp_tree = fn(shapes : Array[@xml.Element]) -> @xml.Element {
    pptx_common_slide_data(NS_PML, shapes)
  }
  cases.push({
    id: "shape-ellipse",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Ellipse", "ellipse", "1828800", "1371600", "3657600", "2743200", "4472C4",
      ),
    ]),
  })
  cases.push({
    id: "shape-roundrect",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "RoundRect", "roundRect", "914400", "914400", "2743200", "1828800",
        "ED7D31",
      ),
    ]),
  })

  // Preset-geometry coverage — a grid of common preset shapes, each
  // with a solid fill, so the geometry path generator is exercised
  // against the reference renderer for many `prst` values at once.
  let preset_grid : Array[@xml.Element] = []
  let presets = [
    ("triangle", "C00000"),
    ("diamond", "00B050"),
    ("hexagon", "0070C0"),
    ("pentagon", "7030A0"),
    ("star5", "FFC000"),
    ("rightArrow", "ED7D31"),
  ]
  for i, ph in presets {
    let (prst, hex) = ph
    let col = i % 3
    let row = i / 3
    let x = (914400 + col * 2743200).to_string()
    let y = (914400 + row * 2286000).to_string()
    preset_grid.push(
      pptx_shape(
        (i + 2).to_string(),
        prst,
        prst,
        x,
        y,
        "2286000",
        "1828800",
        hex,
      ),
    )
  }
  cases.push({
    id: "shape-presets",
    format: "pptx",
    category: "shape",
    content: sp_tree(preset_grid),
  })

  // Helper: lay an arbitrary preset list out as a 4-column grid of
  // 2286000 × 1828800 EMU cells, centred in a 9144000-wide slide.
  // Returns one shape per preset, all in a uniform fill colour, so
  // the fixture isolates the GEOMETRY of each `prst` against the
  // reference render.
  let preset_batch = fn(names : Array[String], hex : String) -> @xml.Element {
    let shapes : Array[@xml.Element] = []
    for i, n in names {
      let col = i % 4
      let row = i / 4
      let x = (457200 + col * 2057400).to_string()
      let y = (457200 + row * 1600200).to_string()
      shapes.push(
        pptx_shape((i + 2).to_string(), n, n, x, y, "1828800", "1371600", hex),
      )
    }
    sp_tree(shapes)
  }

  // Outline-only counterpart of `pptx_shape` for stroke-shaped
  // presets — brackets, braces, connectors, line, arc.  These
  // presets' spec PathLst is `<a:path fill="none" stroke="true">`
  // so they MUST render as a stroked open path, not a filled one;
  // a `<a:solidFill>` on a bracket fills the bracket-character
  // interior and turns it into a rounded rectangle, which is
  // exactly what the unfixed renderer produced.
  let pptx_shape_outline = fn(
    id_ : String,
    name : String,
    prst : String,
    x : String,
    y : String,
    cx : String,
    cy : String,
    hex : String,
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
          Element(xe(NS_A, "noFill", [], [])),
          Element(
            xe(NS_A, "ln", [xa("w", "38100")], [Element(solid_fill(hex))]),
          ),
        ]),
      ),
    ])
  }
  let preset_batch_outline = fn(
    names : Array[String],
    hex : String,
  ) -> @xml.Element {
    let shapes : Array[@xml.Element] = []
    for i, n in names {
      let col = i % 4
      let row = i / 4
      let x = (457200 + col * 2057400).to_string()
      let y = (457200 + row * 1600200).to_string()
      shapes.push(
        pptx_shape_outline(
          (i + 2).to_string(),
          n,
          n,
          x,
          y,
          "1828800",
          "1371600",
          hex,
        ),
      )
    }
    sp_tree(shapes)
  }

  // A shape with TEXT INSIDE — `<p:txBody>` on a `<p:sp>`.  The
  // shape fills with one solid colour and the text body is
  // positioned within.
  let shape_with_text = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Labeled")], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1371600", "3657600", "2286000")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "roundRect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("70AD47")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(xe(NS_A, "bodyPr", [], [])),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          xe(NS_A, "p", [], [
            Element(
              xe(NS_A, "r", [], [Element(xe(NS_A, "t", [], [Text("Label")]))]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "shape-with-text",
    format: "pptx",
    category: "shape",
    content: sp_tree([shape_with_text]),
  })

  // Coverage closure — the remaining handful of presets the
  // supported set declares but no other batch fixture exercises.
  cases.push({
    id: "shape-misc-extras",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      ["foldedCorner", "leftUpArrow", "nonIsoscelesTrapezoid", "squareTabs"],
      "9966CC",
    ),
  })
  cases.push({
    id: "shape-misc-inv",
    format: "pptx",
    category: "shape",
    content: preset_batch_outline(["lineInv"], "595959"),
  })

  // Radial gradient — `<a:gradFill><a:path path="circle">`.
  let radial_grad = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Radial")], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("2286000", "1371600", "3657600", "2743200")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "ellipse")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(
          xe(NS_A, "gradFill", [], [
            Element(
              xe(NS_A, "gsLst", [], [
                Element(
                  xe(NS_A, "gs", [xa("pos", "0")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "FFFFFF")], [])),
                  ]),
                ),
                Element(
                  xe(NS_A, "gs", [xa("pos", "100000")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "4472C4")], [])),
                  ]),
                ),
              ]),
            ),
            Element(xe(NS_A, "path", [xa("path", "circle")], [])),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "shape-gradient-radial",
    format: "pptx",
    category: "shape",
    content: sp_tree([radial_grad]),
  })

  // Multiple gradient stops — 3-color gradient.
  let multi_grad = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Rainbow")], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1371600", "4572000", "2743200")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(
          xe(NS_A, "gradFill", [], [
            Element(
              xe(NS_A, "gsLst", [], [
                Element(
                  xe(NS_A, "gs", [xa("pos", "0")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "FF0000")], [])),
                  ]),
                ),
                Element(
                  xe(NS_A, "gs", [xa("pos", "50000")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "FFFF00")], [])),
                  ]),
                ),
                Element(
                  xe(NS_A, "gs", [xa("pos", "100000")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "0000FF")], [])),
                  ]),
                ),
              ]),
            ),
            Element(xe(NS_A, "lin", [xa("ang", "0")], [])),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "shape-gradient-3stops",
    format: "pptx",
    category: "shape",
    content: sp_tree([multi_grad]),
  })

  // Many different solid-color shape rectangles arranged in a grid
  // — tests color resolution and basic shape rendering at scale.
  let many_colored_shapes : Array[@xml.Element] = []
  let colors = [
    "FF0000", "FF8000", "FFFF00", "80FF00", "00FF00", "00FF80", "00FFFF", "0080FF",
    "0000FF", "8000FF", "FF00FF", "FF0080",
  ]
  for i, hex in colors {
    let col = i % 4
    let row = i / 4
    let x = (457200 + col * 2057400).to_string()
    let y = (457200 + row * 1600200).to_string()
    many_colored_shapes.push(
      pptx_shape(
        (i + 2).to_string(),
        "Color" + i.to_string(),
        "rect",
        x,
        y,
        "1828800",
        "1371600",
        hex,
      ),
    )
  }
  cases.push({
    id: "shape-color-grid",
    format: "pptx",
    category: "shape",
    content: sp_tree(many_colored_shapes),
  })

  // ---- pptx / shape — arrow presets ($20.1.10.56) ----------------
  cases.push({
    id: "shape-arrows",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "leftArrow", "rightArrow", "upArrow", "downArrow", "leftRightArrow", "upDownArrow",
        "quadArrow", "leftRightUpArrow", "bentArrow", "bentUpArrow", "uturnArrow",
        "chevron", "homePlate", "notchedRightArrow", "stripedRightArrow", "swooshArrow",
      ],
      "4472C4",
    ),
  })
  // Curved arrows are arc-based, a different code path from the
  // polygon arrows above.
  cases.push({
    id: "shape-arrows-curved",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "curvedLeftArrow", "curvedRightArrow", "curvedUpArrow", "curvedDownArrow",
        "circularArrow", "leftCircularArrow", "leftRightCircularArrow",
      ],
      "ED7D31",
    ),
  })
  // Arrow callouts — arrow + flag-shaped label region.
  cases.push({
    id: "shape-arrow-callouts",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "leftArrowCallout", "rightArrowCallout", "upArrowCallout", "downArrowCallout",
        "leftRightArrowCallout", "upDownArrowCallout", "quadArrowCallout",
      ],
      "70AD47",
    ),
  })

  // ---- pptx / shape — flowchart presets --------------------------
  // The standard flowchart symbol set per §20.1.10.56 — process,
  // decision, document, terminator, connector, ….
  cases.push({
    id: "shape-flowchart",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "flowChartProcess", "flowChartDecision", "flowChartInputOutput", "flowChartPredefinedProcess",
        "flowChartInternalStorage", "flowChartDocument", "flowChartMultidocument",
        "flowChartTerminator", "flowChartPreparation", "flowChartManualInput", "flowChartManualOperation",
        "flowChartConnector", "flowChartPunchedCard", "flowChartPunchedTape", "flowChartSummingJunction",
        "flowChartOr",
      ],
      "5B9BD5",
    ),
  })
  cases.push({
    id: "shape-flowchart-storage",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "flowChartCollate", "flowChartSort", "flowChartExtract", "flowChartMerge",
        "flowChartOfflineStorage", "flowChartOnlineStorage", "flowChartMagneticTape",
        "flowChartMagneticDisk", "flowChartMagneticDrum", "flowChartDisplay", "flowChartDelay",
        "flowChartAlternateProcess", "flowChartOffpageConnector",
      ],
      "9966CC",
    ),
  })

  // ---- pptx / shape — callout presets ----------------------------
  cases.push({
    id: "shape-callouts",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "callout1", "callout2", "callout3", "accentCallout1", "accentCallout2", "accentCallout3",
        "borderCallout1", "borderCallout2", "borderCallout3", "accentBorderCallout1",
        "accentBorderCallout2", "accentBorderCallout3", "wedgeRectCallout", "wedgeRoundRectCallout",
        "wedgeEllipseCallout", "cloudCallout",
      ],
      "C5504B",
    ),
  })

  // ---- pptx / shape — star presets -------------------------------
  cases.push({
    id: "shape-stars",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "star4", "star5", "star6", "star7", "star8", "star10", "star12", "star16",
        "star24", "star32",
      ],
      "FFC000",
    ),
  })

  // ---- pptx / shape — bracket / brace / connector ----------------
  cases.push({
    id: "shape-brackets",
    format: "pptx",
    category: "shape",
    content: preset_batch_outline(
      [
        "leftBracket", "rightBracket", "bracketPair", "leftBrace", "rightBrace",
        "bracePair",
      ],
      "595959",
    ),
  })
  cases.push({
    id: "shape-connectors",
    format: "pptx",
    category: "shape",
    content: preset_batch_outline(
      [
        "line", "straightConnector1", "bentConnector2", "bentConnector3", "bentConnector4",
        "bentConnector5", "curvedConnector2", "curvedConnector3", "curvedConnector4",
        "curvedConnector5",
      ],
      "595959",
    ),
  })

  // ---- pptx / shape — action buttons -----------------------------
  cases.push({
    id: "shape-action-buttons",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "actionButtonBlank", "actionButtonHome", "actionButtonHelp", "actionButtonInformation",
        "actionButtonForwardNext", "actionButtonBackPrevious", "actionButtonEnd",
        "actionButtonBeginning", "actionButtonReturn", "actionButtonDocument", "actionButtonSound",
        "actionButtonMovie",
      ],
      "44546A",
    ),
  })

  // ---- pptx / shape — misc geometry ------------------------------
  cases.push({
    id: "shape-misc-basic",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "rect", "roundRect", "snip1Rect", "snip2SameRect", "snip2DiagRect", "snipRoundRect",
        "round1Rect", "round2SameRect", "round2DiagRect", "plaque", "ellipse", "teardrop",
        "octagon", "heptagon", "decagon", "dodecagon",
      ],
      "8FAADC",
    ),
  })
  cases.push({
    id: "shape-misc-pointy",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "triangle", "rtTriangle", "parallelogram", "trapezoid", "diamond", "pentagon",
        "hexagon", "plus", "noSmoking", "chord", "pie", "pieWedge", "donut", "can",
        "frame", "halfFrame",
      ],
      "A9D08E",
    ),
  })
  cases.push({
    id: "shape-misc-banner",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "leftRightRibbon", "ribbon", "ribbon2", "ellipseRibbon", "ellipseRibbon2",
        "verticalScroll", "horizontalScroll", "wave", "doubleWave", "irregularSeal1",
        "irregularSeal2", "cloud", "sun", "moon", "heart", "lightningBolt",
      ],
      "F4B183",
    ),
  })
  cases.push({
    id: "shape-misc-symbol",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "smileyFace", "arc", "bevel", "frame", "cube", "diagStripe", "corner", "cornerTabs",
        "blockArc", "plaqueTabs", "chartPlus", "chartStar", "chartX", "mathPlus",
        "mathMinus", "mathMultiply",
      ],
      "F4B183",
    ),
  })
  cases.push({
    id: "shape-misc-math",
    format: "pptx",
    category: "shape",
    content: preset_batch(
      [
        "mathDivide", "mathEqual", "mathNotEqual", "gear6", "gear9", "funnel", "flowChartSort",
        "leftRightArrow", "upDownArrow", "flowChartConnector",
      ],
      "C9C9C9",
    ),
  })

  // A shape with a gradient fill — `<a:gradFill>` two-stop linear.
  let grad_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Gradient")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1371600", "4572000", "2743200")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(
          xe(NS_A, "gradFill", [], [
            Element(
              xe(NS_A, "gsLst", [], [
                Element(
                  xe(NS_A, "gs", [xa("pos", "0")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "4472C4")], [])),
                  ]),
                ),
                Element(
                  xe(NS_A, "gs", [xa("pos", "100000")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "ED7D31")], [])),
                  ]),
                ),
              ]),
            ),
            Element(xe(NS_A, "lin", [xa("ang", "0"), xa("scaled", "1")], [])),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "shape-gradient",
    format: "pptx",
    category: "shape",
    content: sp_tree([grad_shape]),
  })
  // Shape with no fill — only outline.
  let nofill_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "NoFill")], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1371600", "3657600", "2286000")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "ellipse")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(xe(NS_A, "noFill", [], [])),
        Element(
          xe(NS_A, "ln", [xa("w", "38100")], [Element(solid_fill("4472C4"))]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "shape-nofill",
    format: "pptx",
    category: "shape",
    content: sp_tree([nofill_shape]),
  })

  // Two shapes with text inside, demonstrating text alignment.
  let shape_with_centered_text = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "CenteredText")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1371600", "3657600", "2286000")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "roundRect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("4472C4")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(
          xe(NS_A, "bodyPr", [xa("anchor", "ctr"), xa("anchorCtr", "1")], []),
        ),
        Element(xe(NS_A, "lstStyle", [], [])),
        Element(
          xe(NS_A, "p", [], [
            Element(xe(NS_A, "pPr", [xa("algn", "ctr")], [])),
            Element(
              xe(NS_A, "r", [], [
                Element(
                  xe(NS_A, "rPr", [xa("sz", "2400"), xa("b", "1")], [
                    Element(solid_fill("FFFFFF")),
                  ]),
                ),
                Element(xe(NS_A, "t", [], [Text("Centered Text")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "shape-centered-text",
    format: "pptx",
    category: "shape",
    content: sp_tree([shape_with_centered_text]),
  })

  // Gradient with horizontal direction (ang=0).
  let grad_h = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Horiz")], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1371600", "4572000", "2743200")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(
          xe(NS_A, "gradFill", [], [
            Element(
              xe(NS_A, "gsLst", [], [
                Element(
                  xe(NS_A, "gs", [xa("pos", "0")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "70AD47")], [])),
                  ]),
                ),
                Element(
                  xe(NS_A, "gs", [xa("pos", "100000")], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "FFC000")], [])),
                  ]),
                ),
              ]),
            ),
            // ang=5400000 → 90° → top-to-bottom.
            Element(xe(NS_A, "lin", [xa("ang", "5400000")], [])),
          ]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "shape-gradient-vertical",
    format: "pptx",
    category: "shape",
    content: sp_tree([grad_h]),
  })

  // A shape with an explicit outline — `<a:ln>` stroke width + color.
  let outline_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Outlined")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("1828800", "1371600", "3657600", "2286000")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("FFFFFF")),
        Element(
          xe(NS_A, "ln", [xa("w", "57150")], [Element(solid_fill("C00000"))]),
        ),
      ]),
    ),
  ])
  cases.push({
    id: "shape-outline",
    format: "pptx",
    category: "shape",
    content: sp_tree([outline_shape]),
  })

  // Curved presets — `pie`, `chord`, `donut`, `can` all exercise
  // the arc / circle path generators that the polygonal presets do
  // not touch, and any sign/order error in the arc sweep parameters
  // would surface here.
  let curved_grid : Array[@xml.Element] = []
  let curved_presets = [
    ("pie", "C00000"),
    ("chord", "00B050"),
    ("donut", "0070C0"),
    ("can", "ED7D31"),
  ]
  for i, ph in curved_presets {
    let (prst, hex) = ph
    let col = i % 2
    let row = i / 2
    let x = (914400 + col * 3657600).to_string()
    let y = (914400 + row * 2286000).to_string()
    curved_grid.push(
      pptx_shape(
        (i + 2).to_string(),
        prst,
        prst,
        x,
        y,
        "2286000",
        "1828800",
        hex,
      ),
    )
  }
  cases.push({
    id: "shape-curved",
    format: "pptx",
    category: "shape",
    content: sp_tree(curved_grid),
  })

  // A shape with a rotation transform — `<a:xfrm rot="...">` in
  // 60000ths-of-a-degree, clockwise (OOXML convention).  45° = 2700000.
  let rotated_shape = xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Rot45")], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(
          xe(NS_A, "xfrm", [xa("rot", "2700000")], [
            Element(
              xe(NS_A, "off", [xa("x", "3429000"), xa("y", "1828800")], []),
            ),
            Element(
              xe(NS_A, "ext", [xa("cx", "2286000"), xa("cy", "1828800")], []),
            ),
          ]),
        ),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("4472C4")),
      ]),
    ),
  ])
  cases.push({
    id: "shape-rotated",
    format: "pptx",
    category: "shape",
    content: sp_tree([rotated_shape]),
  })

  // Multiple cylinders with various aspect ratios — exercises the
  // multi-layer can geometry at non-default sizes.
  cases.push({
    id: "shape-cylinders",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "TallCan", "can", "457200", "457200", "1828800", "3429000", "C00000",
      ),
      pptx_shape(
        "3", "WideCan", "can", "2743200", "457200", "3429000", "1828800", "00B050",
      ),
      pptx_shape(
        "4", "SquareCan", "can", "6400800", "457200", "2286000", "2286000", "0070C0",
      ),
    ]),
  })

  // Cube preset (multi-layer 3D) standalone fixture.
  cases.push({
    id: "shape-cube",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Cube", "cube", "2286000", "1371600", "3657600", "2743200", "4472C4",
      ),
    ]),
  })
  // Bevel preset (multi-layer beveled tile) standalone fixture.
  cases.push({
    id: "shape-bevel",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Bevel", "bevel", "2286000", "1371600", "3657600", "2743200", "ED7D31",
      ),
    ]),
  })
  // Can preset (cylinder) standalone fixture — already shown in
  // shape-curved batch; here as a focused single-shape comparison.
  cases.push({
    id: "shape-can",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Cylinder", "can", "2286000", "1371600", "3657600", "2743200", "70AD47",
      ),
    ]),
  })

  // A GROUP shape — `<p:grpSp>` containing two sub-shapes with their
  // own local coordinate system via the group's xfrm.
  let group_shape = xe(NS_PML, "grpSp", [], [
    Element(
      xe(NS_PML, "nvGrpSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Group")], [])),
        Element(xe(NS_PML, "cNvGrpSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "grpSpPr", [], [
        Element(
          xe(NS_A, "xfrm", [], [
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
    Element(
      pptx_shape(
        "3", "GroupA", "ellipse", "0", "0", "2286000", "2286000", "4472C4",
      ),
    ),
    Element(
      pptx_shape(
        "4", "GroupB", "rect", "3200400", "228600", "2286000", "1828800", "ED7D31",
      ),
    ),
  ])
  cases.push({
    id: "shape-group",
    format: "pptx",
    category: "shape",
    content: sp_tree([group_shape]),
  })

  // Multiple shapes on one slide — z-order, independent transforms.
  cases.push({
    id: "shape-multiple",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      pptx_shape(
        "2", "Rect", "rect", "457200", "457200", "2286000", "1828800", "4472C4",
      ),
      pptx_shape(
        "3", "Ellipse", "ellipse", "2743200", "1371600", "2286000", "1828800", "ED7D31",
      ),
      pptx_shape(
        "4", "Triangle", "triangle", "5029200", "2286000", "2286000", "1828800",
        "70AD47",
      ),
    ]),
  })

  // Multiple shapes including the rotated-shape series.  Two ellipses
  // at the same position with different rotations (45° and 90°).
  let make_rotated = fn(
    id_ : String,
    rot : String,
    hex : String,
  ) -> @xml.Element {
    xe(NS_PML, "sp", [], [
      Element(
        xe(NS_PML, "nvSpPr", [], [
          Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", "Rot")], [])),
          Element(xe(NS_PML, "cNvSpPr", [], [])),
          Element(xe(NS_PML, "nvPr", [], [])),
        ]),
      ),
      Element(
        xe(NS_PML, "spPr", [], [
          Element(
            xe(NS_A, "xfrm", [xa("rot", rot)], [
              Element(
                xe(NS_A, "off", [xa("x", "3429000"), xa("y", "1828800")], []),
              ),
              Element(
                xe(NS_A, "ext", [xa("cx", "2286000"), xa("cy", "914400")], []),
              ),
            ]),
          ),
          Element(
            xe(NS_A, "prstGeom", [xa("prst", "rect")], [
              Element(xe(NS_A, "avLst", [], [])),
            ]),
          ),
          Element(solid_fill(hex)),
        ]),
      ),
    ])
  }
  cases.push({
    id: "shape-multi-rotated",
    format: "pptx",
    category: "shape",
    content: sp_tree([
      make_rotated("2", "0", "4472C4"),
      make_rotated("3", "2700000", "ED7D31"), // 45°
      make_rotated("4", "5400000", "70AD47"), // 90°
    ]),
  })

  // ---- pptx / text ----------------------------------------------
  // A text-box shape: spPr (no fill) + txBody with paragraphs.
  let a_para = fn(text : String) -> @xml.Element {
    xe(NS_A, "p", [], [
      Element(xe(NS_A, "r", [], [Element(xe(NS_A, "t", [], [Text(text)]))])),
    ])
  }
  let text_shape = fn(
    id_ : String,
    x : String,
    y : String,
    cx : String,
    cy : String,
    paras : Array[@xml.Element],
  ) -> @xml.Element {
    let body_kids : Array[@xml.Node] = [
      Element(xe(NS_A, "bodyPr", [], [])),
      Element(xe(NS_A, "lstStyle", [], [])),
    ]
    for p in paras {
      body_kids.push(Element(p))
    }
    xe(NS_PML, "sp", [], [
      Element(
        xe(NS_PML, "nvSpPr", [], [
          Element(
            xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", "TextBox")], []),
          ),
          Element(xe(NS_PML, "cNvSpPr", [], [])),
          Element(xe(NS_PML, "nvPr", [], [])),
        ]),
      ),
      Element(xe(NS_PML, "spPr", [], [Element(sp_xfrm(x, y, cx, cy))])),
      Element(xe(NS_PML, "txBody", [], body_kids)),
    ])
  }
  cases.push({
    id: "text-textbox",
    format: "pptx",
    category: "text",
    content: sp_tree([
      text_shape("2", "457200", "457200", "8229600", "1143000", [
        a_para("Presentation Title"),
      ]),
      text_shape("3", "457200", "1828800", "8229600", "3886200", [
        a_para("First bullet point"),
        a_para("Second bullet point"),
        a_para("Third and final point"),
      ]),
    ]),
  })

  // ---- xlsx / cell ----------------------------------------------
  let s_cell = fn(ref_ : String, value : String) -> @xml.Element {
    xe(NS_S, "c", [xa("r", ref_)], [Element(xe(NS_S, "v", [], [Text(value)]))])
  }
  let s_row = fn(num : String, cells : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in cells {
      kids.push(Element(c))
    }
    xe(NS_S, "row", [xa("r", num)], kids)
  }
  cases.push({
    id: "cell-values",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_cell("A1", "10"), s_cell("B1", "20"), s_cell("C1", "30")]),
      ),
      Element(
        s_row("2", [
          s_cell("A2", "1.5"),
          s_cell("B2", "2.25"),
          s_cell("C2", "100"),
        ]),
      ),
    ]),
  })
  // An inline-string cell (`t="inlineStr"` → `<is><t>`).
  let s_inline = fn(ref_ : String, text : String) -> @xml.Element {
    xe(NS_S, "c", [xa("r", ref_), xa("t", "inlineStr")], [
      Element(xe(NS_S, "is", [], [Element(xe(NS_S, "t", [], [Text(text)]))])),
    ])
  }
  cases.push({
    id: "cell-inline-string",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_inline("A1", "Name"), s_inline("B1", "Score")])),
      Element(s_row("2", [s_inline("A2", "Alice"), s_cell("B2", "95")])),
    ]),
  })
  // A cell carrying a formula (`<f>` + cached `<v>`).
  let s_formula = fn(
    ref_ : String,
    formula : String,
    cached : String,
  ) -> @xml.Element {
    xe(NS_S, "c", [xa("r", ref_)], [
      Element(xe(NS_S, "f", [], [Text(formula)])),
      Element(xe(NS_S, "v", [], [Text(cached)])),
    ])
  }
  cases.push({
    id: "formula-sum",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(s_row("1", [s_cell("A1", "5"), s_cell("B1", "7")])),
      Element(s_row("2", [s_formula("A2", "SUM(A1:B1)", "12")])),
    ]),
  })
  // A worksheet with explicit COLUMN widths via `<cols><col>`.  Each
  // `<col>` defines width for a span of columns, in character units.
  let s_col = fn(min : String, max : String, width : String) -> @xml.Element {
    xe(
      NS_S,
      "col",
      [
        xa("min", min),
        xa("max", max),
        xa("width", width),
        xa("customWidth", "1"),
      ],
      [],
    )
  }
  cases.push({
    id: "cell-column-widths",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "worksheet", [], [
      Element(
        xe(NS_S, "cols", [], [
          Element(s_col("1", "1", "8")),
          Element(s_col("2", "2", "20")),
          Element(s_col("3", "3", "12")),
        ]),
      ),
      Element(
        xe(NS_S, "sheetData", [], [
          Element(
            s_row("1", [
              s_inline("A1", "ID"),
              s_inline("B1", "Description"),
              s_inline("C1", "Value"),
            ]),
          ),
          Element(
            s_row("2", [
              s_inline("A2", "1"),
              s_inline("B2", "First entry"),
              s_cell("C2", "100"),
            ]),
          ),
          Element(
            s_row("3", [
              s_inline("A3", "2"),
              s_inline("B3", "Second entry"),
              s_cell("C3", "200"),
            ]),
          ),
        ]),
      ),
    ]),
  })
  // A sheet with MERGED CELLS via `<mergeCells>`.  The merge spans
  // A1:C1 (a 3-column merged header).
  cases.push({
    id: "cell-merged",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "worksheet", [], [
      Element(
        xe(NS_S, "sheetData", [], [
          Element(s_row("1", [s_inline("A1", "Merged Header")])),
          Element(
            s_row("2", [
              s_inline("A2", "Col1"),
              s_inline("B2", "Col2"),
              s_inline("C2", "Col3"),
            ]),
          ),
          Element(
            s_row("3", [
              s_cell("A3", "10"),
              s_cell("B3", "20"),
              s_cell("C3", "30"),
            ]),
          ),
        ]),
      ),
      Element(
        xe(NS_S, "mergeCells", [xa("count", "1")], [
          Element(xe(NS_S, "mergeCell", [xa("ref", "A1:C1")], [])),
        ]),
      ),
    ]),
  })
  // A larger sheet — 5 columns × 8 rows of numeric data, exercising
  // the grid rendering at scale.
  let big_rows : Array[@xml.Node] = []
  for r in 1..<9 {
    let cells : Array[@xml.Element] = []
    let cols = ["A", "B", "C", "D", "E"]
    for ci, col in cols {
      let v = (r * 10 + ci).to_string()
      cells.push(s_cell(col + r.to_string(), v))
    }
    big_rows.push(Element(s_row(r.to_string(), cells)))
  }
  cases.push({
    id: "cell-grid",
    format: "xlsx",
    category: "cell",
    content: xe(NS_S, "sheetData", [], big_rows),
  })
  // A formula with several functions and references.
  cases.push({
    id: "formula-multi",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_cell("A1", "10"), s_cell("B1", "20"), s_cell("C1", "30")]),
      ),
      Element(
        s_row("2", [
          s_formula("A2", "SUM(A1:C1)", "60"),
          s_formula("B2", "AVERAGE(A1:C1)", "20"),
          s_formula("C2", "MAX(A1:C1)", "30"),
        ]),
      ),
      Element(
        s_row("3", [
          s_formula("A3", "MIN(A1:C1)", "10"),
          s_formula("B3", "COUNT(A1:C1)", "3"),
          s_formula("C3", "A1+B1+C1", "60"),
        ]),
      ),
    ]),
  })
  // IF/conditional formulas.
  cases.push({
    id: "formula-conditional",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [s_cell("A1", "85"), s_cell("B1", "60"), s_cell("C1", "92")]),
      ),
      Element(
        s_row("2", [
          s_formula("A2", "IF(A1>=80,\"PASS\",\"FAIL\")", "PASS"),
          s_formula("B2", "IF(B1>=80,\"PASS\",\"FAIL\")", "FAIL"),
          s_formula("C2", "IF(C1>=80,\"PASS\",\"FAIL\")", "PASS"),
        ]),
      ),
    ]),
  })
  // Statistical / counting formulas.
  cases.push({
    id: "formula-statistical",
    format: "xlsx",
    category: "formula",
    content: xe(NS_S, "sheetData", [], [
      Element(
        s_row("1", [
          s_cell("A1", "5"),
          s_cell("B1", "10"),
          s_cell("C1", "15"),
          s_cell("D1", "20"),
          s_cell("E1", "25"),
        ]),
      ),
      Element(
        s_row("2", [
          s_formula("A2", "MEDIAN(A1:E1)", "15"),
          s_formula("B2", "STDEV(A1:E1)", "7.91"),
          s_formula("C2", "VAR(A1:E1)", "62.5"),
          s_formula("D2", "PRODUCT(A1:E1)", "375000"),
        ]),
      ),
    ]),
  })

  cases
}

///|
/// Fixtures that need an auxiliary OPC part (xlsx styles.xml, WML
/// numbering.xml / styles.xml).  Materialised separately so the
/// plain-case constructors above remain a simple `VisualCase`
/// struct-literal — only fixtures here pay the field-list cost.
fn extended_cases() -> Array[ExtendedCase] {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let xcases : Array[ExtendedCase] = []

  // ---- xlsx / number-format styles ------------------------------
  // A `<styleSheet>` declaring three custom number formats and one
  // `<xf>` per format referencing it; cells then use `s="N"` to pick
  // a format by its index in `<cellXfs>` (zero-based).
  // §18.8.45 (numFmts), §18.8.10 (cellXfs).
  let num_fmt = fn(id : String, code : String) -> @xml.Element {
    xe(ns_s, "numFmt", [xa("numFmtId", id), xa("formatCode", code)], [])
  }
  let xf = fn(num_fmt_id : String) -> @xml.Element {
    xe(
      ns_s,
      "xf",
      [
        xa("numFmtId", num_fmt_id),
        xa("fontId", "0"),
        xa("fillId", "0"),
        xa("borderId", "0"),
        xa("applyNumberFormat", "1"),
      ],
      [],
    )
  }
  // A minimal styleSheet: numFmts + fonts + fills + borders + cellXfs.
  // Built numFmt IDs (numFmtId>=164 are custom):
  //   164 → "0.00"            (two-decimal)
  //   165 → "#,##0"           (thousands)
  //   166 → "0%"              (percent)
  //   167 → "yyyy-mm-dd"      (ISO date)
  let styles_sheet = xe(ns_s, "styleSheet", [], [
    Element(
      xe(ns_s, "numFmts", [xa("count", "4")], [
        Element(num_fmt("164", "0.00")),
        Element(num_fmt("165", "#,##0")),
        Element(num_fmt("166", "0%")),
        Element(num_fmt("167", "yyyy-mm-dd")),
      ]),
    ),
    Element(
      xe(ns_s, "fonts", [xa("count", "1")], [
        Element(
          xe(ns_s, "font", [], [
            Element(xe(ns_s, "sz", [xa("val", "11")], [])),
            Element(xe(ns_s, "name", [xa("val", "Calibri")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "fills", [xa("count", "1")], [
        Element(
          xe(ns_s, "fill", [], [
            Element(xe(ns_s, "patternFill", [xa("patternType", "none")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "borders", [xa("count", "1")], [
        Element(
          xe(ns_s, "border", [], [
            Element(xe(ns_s, "left", [], [])),
            Element(xe(ns_s, "right", [], [])),
            Element(xe(ns_s, "top", [], [])),
            Element(xe(ns_s, "bottom", [], [])),
            Element(xe(ns_s, "diagonal", [], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "cellXfs", [xa("count", "5")], [
        // index 0 — default (general number format).
        Element(xf("0")),
        // index 1 — two-decimal.
        Element(xf("164")),
        // index 2 — thousands.
        Element(xf("165")),
        // index 3 — percent.
        Element(xf("166")),
        // index 4 — date.
        Element(xf("167")),
      ]),
    ),
  ])
  // A cell with a numeric value and a style index.
  let s_cell_styled = fn(
    ref_ : String,
    value : String,
    style : String,
  ) -> @xml.Element {
    xe(ns_s, "c", [xa("r", ref_), xa("s", style)], [
      Element(xe(ns_s, "v", [], [Text(value)])),
    ])
  }
  let s_row_x = fn(num : String, cells : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for c in cells {
      kids.push(Element(c))
    }
    xe(ns_s, "row", [xa("r", num)], kids)
  }
  let s_inline_x = fn(ref_ : String, text : String) -> @xml.Element {
    xe(ns_s, "c", [xa("r", ref_), xa("t", "inlineStr")], [
      Element(xe(ns_s, "is", [], [Element(xe(ns_s, "t", [], [Text(text)]))])),
    ])
  }
  xcases.push({
    id: "cell-number-formats",
    format: "xlsx",
    category: "cell",
    content: xe(ns_s, "sheetData", [], [
      Element(
        s_row_x("1", [
          s_inline_x("A1", "Default"),
          s_inline_x("B1", "2-decimal"),
          s_inline_x("C1", "Thousands"),
          s_inline_x("D1", "Percent"),
        ]),
      ),
      Element(
        s_row_x("2", [
          s_cell_styled("A2", "1234.567", "0"),
          s_cell_styled("B2", "1234.567", "1"),
          s_cell_styled("C2", "1234.567", "2"),
          s_cell_styled("D2", "0.4275", "3"),
        ]),
      ),
      Element(
        s_row_x("3", [
          s_cell_styled("A3", "12.5", "0"),
          s_cell_styled("B3", "12.5", "1"),
          s_cell_styled("C3", "1000000", "2"),
          s_cell_styled("D3", "0.123", "3"),
        ]),
      ),
    ]),
    styles: Some(styles_sheet),
    numbering: None,
    doc_styles: None,
  })

  // ---- xlsx / borders ------------------------------------------
  // A styleSheet declaring 4 border styles indexed in `<cellXfs>`
  // and cells using them to box each cell.
  let border_side = fn(side : String, style : String) -> @xml.Element {
    xe(ns_s, side, [xa("style", style)], [
      Element(xe(ns_s, "color", [xa("rgb", "FF000000")], [])),
    ])
  }
  let border_def = fn(style : String) -> @xml.Element {
    xe(ns_s, "border", [], [
      Element(border_side("left", style)),
      Element(border_side("right", style)),
      Element(border_side("top", style)),
      Element(border_side("bottom", style)),
      Element(xe(ns_s, "diagonal", [], [])),
    ])
  }
  let border_styles = xe(ns_s, "styleSheet", [], [
    Element(
      xe(ns_s, "fonts", [xa("count", "1")], [
        Element(
          xe(ns_s, "font", [], [
            Element(xe(ns_s, "sz", [xa("val", "11")], [])),
            Element(xe(ns_s, "name", [xa("val", "Calibri")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "fills", [xa("count", "1")], [
        Element(
          xe(ns_s, "fill", [], [
            Element(xe(ns_s, "patternFill", [xa("patternType", "none")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "borders", [xa("count", "5")], [
        // index 0 — no border (default).
        Element(border_def("none")),
        // index 1 — thin.
        Element(border_def("thin")),
        // index 2 — medium.
        Element(border_def("medium")),
        // index 3 — thick.
        Element(border_def("thick")),
        // index 4 — double.
        Element(border_def("double")),
      ]),
    ),
    Element(
      xe(ns_s, "cellXfs", [xa("count", "5")], [
        // index 0 — default.
        Element(
          xe(
            ns_s,
            "xf",
            [xa("borderId", "0"), xa("fontId", "0"), xa("fillId", "0")],
            [],
          ),
        ),
        // index 1 — thin border.
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "1"),
              xa("fontId", "0"),
              xa("fillId", "0"),
              xa("applyBorder", "1"),
            ],
            [],
          ),
        ),
        // index 2 — medium.
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "2"),
              xa("fontId", "0"),
              xa("fillId", "0"),
              xa("applyBorder", "1"),
            ],
            [],
          ),
        ),
        // index 3 — thick.
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "3"),
              xa("fontId", "0"),
              xa("fillId", "0"),
              xa("applyBorder", "1"),
            ],
            [],
          ),
        ),
        // index 4 — double.
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "4"),
              xa("fontId", "0"),
              xa("fillId", "0"),
              xa("applyBorder", "1"),
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  xcases.push({
    id: "cell-borders",
    format: "xlsx",
    category: "cell",
    content: xe(ns_s, "sheetData", [], [
      Element(
        s_row_x("1", [
          s_cell_styled("A1", "1", "1"),
          s_cell_styled("B1", "2", "2"),
          s_cell_styled("C1", "3", "3"),
          s_cell_styled("D1", "4", "4"),
        ]),
      ),
      Element(
        s_row_x("2", [
          s_inline_x("A2", "thin"),
          s_inline_x("B2", "medium"),
          s_inline_x("C2", "thick"),
          s_inline_x("D2", "double"),
        ]),
      ),
    ]),
    styles: Some(border_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- xlsx / cell fills ---------------------------------------
  // Cells with solid background fill colors via `<fills><fill><patternFill>`.
  let fill_def = fn(rgb : String) -> @xml.Element {
    xe(ns_s, "fill", [], [
      Element(
        xe(ns_s, "patternFill", [xa("patternType", "solid")], [
          Element(xe(ns_s, "fgColor", [xa("rgb", "FF" + rgb)], [])),
          Element(xe(ns_s, "bgColor", [xa("indexed", "64")], [])),
        ]),
      ),
    ])
  }
  let fill_styles = xe(ns_s, "styleSheet", [], [
    Element(
      xe(ns_s, "fonts", [xa("count", "1")], [
        Element(
          xe(ns_s, "font", [], [
            Element(xe(ns_s, "sz", [xa("val", "11")], [])),
            Element(xe(ns_s, "name", [xa("val", "Calibri")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "fills", [xa("count", "5")], [
        // index 0 — none.
        Element(
          xe(ns_s, "fill", [], [
            Element(xe(ns_s, "patternFill", [xa("patternType", "none")], [])),
          ]),
        ),
        // index 1 — gray125 (default Excel placeholder).
        Element(
          xe(ns_s, "fill", [], [
            Element(xe(ns_s, "patternFill", [xa("patternType", "gray125")], [])),
          ]),
        ),
        // index 2 — red.
        Element(fill_def("FFC7CE")),
        // index 3 — green.
        Element(fill_def("C6EFCE")),
        // index 4 — blue.
        Element(fill_def("BDD7EE")),
      ]),
    ),
    Element(
      xe(ns_s, "borders", [xa("count", "1")], [
        Element(
          xe(ns_s, "border", [], [
            Element(xe(ns_s, "left", [], [])),
            Element(xe(ns_s, "right", [], [])),
            Element(xe(ns_s, "top", [], [])),
            Element(xe(ns_s, "bottom", [], [])),
            Element(xe(ns_s, "diagonal", [], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "cellXfs", [xa("count", "4")], [
        Element(
          xe(
            ns_s,
            "xf",
            [xa("borderId", "0"), xa("fontId", "0"), xa("fillId", "0")],
            [],
          ),
        ),
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "0"),
              xa("fontId", "0"),
              xa("fillId", "2"),
              xa("applyFill", "1"),
            ],
            [],
          ),
        ),
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "0"),
              xa("fontId", "0"),
              xa("fillId", "3"),
              xa("applyFill", "1"),
            ],
            [],
          ),
        ),
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "0"),
              xa("fontId", "0"),
              xa("fillId", "4"),
              xa("applyFill", "1"),
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  // ---- docx / numbered list ------------------------------------
  // §17.9 — `<w:numbering>` declares an abstractNum (the format
  // definition) and a num (the instance binding numId→abstractNumId).
  // Paragraphs reference the list via `<w:pPr><w:numPr><w:numId>`.
  let num_lvl = fn(
    ilvl : String,
    fmt : String,
    text : String,
    start : String,
  ) -> @xml.Element {
    xe(
      NS_W,
      "lvl",
      [
        {
          name: { prefix: Some("w"), local_name: "ilvl", ns: Some(NS_W) },
          value: ilvl,
        },
      ],
      [
        Element(
          xe(
            NS_W,
            "start",
            [
              {
                name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
                value: start,
              },
            ],
            [],
          ),
        ),
        Element(
          xe(
            NS_W,
            "numFmt",
            [
              {
                name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
                value: fmt,
              },
            ],
            [],
          ),
        ),
        Element(
          xe(
            NS_W,
            "lvlText",
            [
              {
                name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
                value: text,
              },
            ],
            [],
          ),
        ),
        Element(
          xe(
            NS_W,
            "lvlJc",
            [
              {
                name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
                value: "left",
              },
            ],
            [],
          ),
        ),
      ],
    )
  }
  let numbered_numbering = xe(NS_W, "numbering", [], [
    Element(
      xe(
        NS_W,
        "abstractNum",
        [
          {
            name: {
              prefix: Some("w"),
              local_name: "abstractNumId",
              ns: Some(NS_W),
            },
            value: "0",
          },
        ],
        [Element(num_lvl("0", "decimal", "%1.", "1"))],
      ),
    ),
    Element(
      xe(
        NS_W,
        "num",
        [
          {
            name: { prefix: Some("w"), local_name: "numId", ns: Some(NS_W) },
            value: "1",
          },
        ],
        [
          Element(
            xe(
              NS_W,
              "abstractNumId",
              [
                {
                  name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
                  value: "0",
                },
              ],
              [],
            ),
          ),
        ],
      ),
    ),
  ])
  let bulleted_numbering = xe(NS_W, "numbering", [], [
    Element(
      xe(
        NS_W,
        "abstractNum",
        [
          {
            name: {
              prefix: Some("w"),
              local_name: "abstractNumId",
              ns: Some(NS_W),
            },
            value: "0",
          },
        ],
        [Element(num_lvl("0", "bullet", "•", "1"))],
      ),
    ),
    Element(
      xe(
        NS_W,
        "num",
        [
          {
            name: { prefix: Some("w"), local_name: "numId", ns: Some(NS_W) },
            value: "1",
          },
        ],
        [
          Element(
            xe(
              NS_W,
              "abstractNumId",
              [
                {
                  name: { prefix: Some("w"), local_name: "val", ns: Some(NS_W) },
                  value: "0",
                },
              ],
              [],
            ),
          ),
        ],
      ),
    ),
  ])
  // A paragraph in a numbered list (numId=1, ilvl=0).
  let num_p = fn(text : String) -> @xml.Element {
    w_p(
      Some(
        xe(NS_W, "pPr", [], [
          Element(
            xe(NS_W, "numPr", [], [
              Element(
                xe(
                  NS_W,
                  "ilvl",
                  [
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "val",
                        ns: Some(NS_W),
                      },
                      value: "0",
                    },
                  ],
                  [],
                ),
              ),
              Element(
                xe(
                  NS_W,
                  "numId",
                  [
                    {
                      name: {
                        prefix: Some("w"),
                        local_name: "val",
                        ns: Some(NS_W),
                      },
                      value: "1",
                    },
                  ],
                  [],
                ),
              ),
            ]),
          ),
        ]),
      ),
      [w_run(None, text)],
    )
  }
  xcases.push({
    id: "paragraph-numbered-list",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(num_p("First numbered item")),
      Element(num_p("Second numbered item")),
      Element(num_p("Third numbered item")),
    ]),
    styles: None,
    numbering: Some(numbered_numbering),
    doc_styles: None,
  })
  xcases.push({
    id: "paragraph-bulleted-list",
    format: "docx",
    category: "paragraph",
    content: xe(NS_W, "body", [], [
      Element(num_p("First bullet item")),
      Element(num_p("Second bullet item")),
      Element(num_p("Third bullet item")),
    ]),
    styles: None,
    numbering: Some(bulleted_numbering),
    doc_styles: None,
  })

  // ---- xlsx / cell alignment -----------------------------------
  let align_styles = xe(ns_s, "styleSheet", [], [
    Element(
      xe(ns_s, "fonts", [xa("count", "1")], [
        Element(
          xe(ns_s, "font", [], [
            Element(xe(ns_s, "sz", [xa("val", "11")], [])),
            Element(xe(ns_s, "name", [xa("val", "Calibri")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "fills", [xa("count", "1")], [
        Element(
          xe(ns_s, "fill", [], [
            Element(xe(ns_s, "patternFill", [xa("patternType", "none")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "borders", [xa("count", "1")], [
        Element(
          xe(ns_s, "border", [], [
            Element(xe(ns_s, "left", [], [])),
            Element(xe(ns_s, "right", [], [])),
            Element(xe(ns_s, "top", [], [])),
            Element(xe(ns_s, "bottom", [], [])),
            Element(xe(ns_s, "diagonal", [], [])),
          ]),
        ),
      ]),
    ),
    // index 0 = default; 1 = left; 2 = center; 3 = right.
    Element(
      xe(ns_s, "cellXfs", [xa("count", "4")], [
        Element(
          xe(
            ns_s,
            "xf",
            [xa("borderId", "0"), xa("fontId", "0"), xa("fillId", "0")],
            [],
          ),
        ),
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "0"),
              xa("fontId", "0"),
              xa("fillId", "0"),
              xa("applyAlignment", "1"),
            ],
            [Element(xe(ns_s, "alignment", [xa("horizontal", "left")], []))],
          ),
        ),
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "0"),
              xa("fontId", "0"),
              xa("fillId", "0"),
              xa("applyAlignment", "1"),
            ],
            [Element(xe(ns_s, "alignment", [xa("horizontal", "center")], []))],
          ),
        ),
        Element(
          xe(
            ns_s,
            "xf",
            [
              xa("borderId", "0"),
              xa("fontId", "0"),
              xa("fillId", "0"),
              xa("applyAlignment", "1"),
            ],
            [Element(xe(ns_s, "alignment", [xa("horizontal", "right")], []))],
          ),
        ),
      ]),
    ),
  ])
  let inline_str_styled = fn(
    ref_ : String,
    style : String,
    text : String,
  ) -> @xml.Element {
    xe(ns_s, "c", [xa("r", ref_), xa("s", style), xa("t", "inlineStr")], [
      Element(xe(ns_s, "is", [], [Element(xe(ns_s, "t", [], [Text(text)]))])),
    ])
  }
  let col_x = fn(min : String, max : String, width : String) -> @xml.Element {
    xe(
      ns_s,
      "col",
      [
        xa("min", min),
        xa("max", max),
        xa("width", width),
        xa("customWidth", "1"),
      ],
      [],
    )
  }
  xcases.push({
    id: "cell-alignment",
    format: "xlsx",
    category: "cell",
    content: xe(ns_s, "worksheet", [], [
      Element(xe(ns_s, "cols", [], [Element(col_x("1", "3", "15"))])),
      Element(
        xe(ns_s, "sheetData", [], [
          Element(
            s_row_x("1", [
              inline_str_styled("A1", "1", "LEFT"),
              inline_str_styled("B1", "2", "CENTER"),
              inline_str_styled("C1", "3", "RIGHT"),
            ]),
          ),
        ]),
      ),
    ]),
    styles: Some(align_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- xlsx / date & time formats ------------------------------
  let date_styles = xe(ns_s, "styleSheet", [], [
    Element(
      xe(ns_s, "numFmts", [xa("count", "4")], [
        Element(num_fmt("164", "yyyy-mm-dd")),
        Element(num_fmt("165", "hh:mm:ss")),
        Element(num_fmt("166", "yyyy-mm-dd hh:mm")),
        Element(num_fmt("167", "mmm dd, yyyy")),
      ]),
    ),
    Element(
      xe(ns_s, "fonts", [xa("count", "1")], [
        Element(
          xe(ns_s, "font", [], [
            Element(xe(ns_s, "sz", [xa("val", "11")], [])),
            Element(xe(ns_s, "name", [xa("val", "Calibri")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "fills", [xa("count", "1")], [
        Element(
          xe(ns_s, "fill", [], [
            Element(xe(ns_s, "patternFill", [xa("patternType", "none")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "borders", [xa("count", "1")], [
        Element(
          xe(ns_s, "border", [], [
            Element(xe(ns_s, "left", [], [])),
            Element(xe(ns_s, "right", [], [])),
            Element(xe(ns_s, "top", [], [])),
            Element(xe(ns_s, "bottom", [], [])),
            Element(xe(ns_s, "diagonal", [], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "cellXfs", [xa("count", "5")], [
        Element(xf("0")),
        Element(xf("164")),
        Element(xf("165")),
        Element(xf("166")),
        Element(xf("167")),
      ]),
    ),
  ])
  // Excel date serial 45000 ≈ 2023-03-15.
  xcases.push({
    id: "cell-dates",
    format: "xlsx",
    category: "cell",
    content: xe(ns_s, "sheetData", [], [
      Element(
        s_row_x("1", [
          inline_str_styled("A1", "0", "Date"),
          inline_str_styled("B1", "0", "Time"),
          inline_str_styled("C1", "0", "DateTime"),
          inline_str_styled("D1", "0", "Long"),
        ]),
      ),
      Element(
        s_row_x("2", [
          s_cell_styled("A2", "45000", "1"),
          s_cell_styled("B2", "0.5", "2"),
          s_cell_styled("C2", "45000.75", "3"),
          s_cell_styled("D2", "45000", "4"),
        ]),
      ),
    ]),
    styles: Some(date_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- xlsx / currency formats ---------------------------------
  let currency_styles = xe(ns_s, "styleSheet", [], [
    Element(
      xe(ns_s, "numFmts", [xa("count", "3")], [
        Element(num_fmt("164", "$#,##0.00")),
        Element(num_fmt("165", "¥#,##0")),
        Element(num_fmt("166", "0.00%")),
      ]),
    ),
    Element(
      xe(ns_s, "fonts", [xa("count", "1")], [
        Element(
          xe(ns_s, "font", [], [
            Element(xe(ns_s, "sz", [xa("val", "11")], [])),
            Element(xe(ns_s, "name", [xa("val", "Calibri")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "fills", [xa("count", "1")], [
        Element(
          xe(ns_s, "fill", [], [
            Element(xe(ns_s, "patternFill", [xa("patternType", "none")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "borders", [xa("count", "1")], [
        Element(
          xe(ns_s, "border", [], [
            Element(xe(ns_s, "left", [], [])),
            Element(xe(ns_s, "right", [], [])),
            Element(xe(ns_s, "top", [], [])),
            Element(xe(ns_s, "bottom", [], [])),
            Element(xe(ns_s, "diagonal", [], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "cellXfs", [xa("count", "4")], [
        Element(xf("0")),
        Element(xf("164")),
        Element(xf("165")),
        Element(xf("166")),
      ]),
    ),
  ])
  xcases.push({
    id: "cell-currency",
    format: "xlsx",
    category: "cell",
    content: xe(ns_s, "sheetData", [], [
      Element(
        s_row_x("1", [
          inline_str_styled("A1", "0", "USD"),
          inline_str_styled("B1", "0", "JPY"),
          inline_str_styled("C1", "0", "Pct"),
        ]),
      ),
      Element(
        s_row_x("2", [
          s_cell_styled("A2", "1234.50", "1"),
          s_cell_styled("B2", "150000", "2"),
          s_cell_styled("C2", "0.075", "3"),
        ]),
      ),
    ]),
    styles: Some(currency_styles),
    numbering: None,
    doc_styles: None,
  })

  xcases.push({
    id: "cell-fills",
    format: "xlsx",
    category: "cell",
    content: xe(ns_s, "sheetData", [], [
      Element(
        s_row_x("1", [
          s_cell_styled("A1", "100", "1"),
          s_cell_styled("B1", "200", "2"),
          s_cell_styled("C1", "300", "3"),
        ]),
      ),
      Element(
        s_row_x("2", [
          s_inline_x("A2", "red"),
          s_inline_x("B2", "green"),
          s_inline_x("C2", "blue"),
        ]),
      ),
    ]),
    styles: Some(fill_styles),
    numbering: None,
    doc_styles: None,
  })

  // Per-feature extensions live in `fixtures_wml_numbering.mbt`
  // (and future ExtendedCase-using extras files); each function
  // pushes onto `xcases` so the giant `extended_cases()` body
  // remains a stable anchor.
  extras_wml_numbering(xcases)
  extras_sml_styled(xcases)
  extras_sml_cf_complete_styled(xcases)
  extras_sml_autofilter_styled(xcases)
  extras_sml_aux_parts_styled(xcases)

  xcases
}

///|
/// Generate every visual fixture file under .snapshots/fixtures/.
fn generate_visual_fixtures() -> Unit {
  let cases = visual_cases()
  // Per-category extension cases live in `fixtures_<category>.mbt`
  // and are pushed via `extra_cases()`.  This lets subagents add
  // fixtures to disjoint files without conflicting on the giant
  // `visual_cases()` body.
  for c in extra_cases() {
    cases.push(c)
  }
  let xcases = extended_cases()
  let _ = try? @fs.create_dir(".snapshots")
  let _ = try? @fs.create_dir(".snapshots/fixtures")
  let mut written = 0
  let mut total = 0
  for c in cases {
    total = total + 1
    let bytes = match c.format {
      "xlsx" => xlsx_package(c.content)
      "pptx" => pptx_package(c.content)
      "pptx:theme" => pptx_with_aux_root_package("theme", c.content)
      "pptx:presentation" =>
        pptx_with_aux_root_package("presentation", c.content)
      "pptx:presentationPr" =>
        pptx_with_aux_root_package("presentationPr", c.content)
      "pptx:viewPr" => pptx_with_aux_root_package("viewPr", c.content)
      "pptx:themeOverride" =>
        pptx_with_aux_root_package("themeOverride", c.content)
      "pptx:themeManager" =>
        pptx_with_aux_root_package("themeManager", c.content)
      "pptx:master-txstyle" => pptx_package_with_master_tx_styles(c.content)
      "pptx:slideRefs" => pptx_package_with_slide_refs(c.content)
      "pptx:comments" => pptx_with_aux_root_package("comments", c.content)
      "pptx:commentAuthors" =>
        pptx_with_aux_root_package("commentAuthors", c.content)
      "pptx:sldSyncPr" => pptx_with_aux_root_package("sldSyncPr", c.content)
      "pptx:notes" => pptx_with_aux_root_package("notes", c.content)
      "pptx:notesMaster" => pptx_with_aux_root_package("notesMaster", c.content)
      "pptx:handoutMaster" =>
        pptx_with_aux_root_package("handoutMaster", c.content)
      "pptx:presentationRefs" => pptx_package_with_presentation_refs(c.content)
      "xlsx:workbook" => xlsx_with_aux_root_package("workbook", c.content)
      "xlsx:sharedStrings" =>
        xlsx_with_aux_root_package("sharedStrings", c.content)
      "xlsx:styles" => xlsx_with_aux_root_package("styles", c.content)
      "xlsx:comments" => xlsx_with_aux_root_package("comments", c.content)
      "xlsx:calcChain" => xlsx_with_aux_root_package("calcChain", c.content)
      "xlsx:connections" => xlsx_with_aux_root_package("connections", c.content)
      "xlsx:metadata" => xlsx_with_aux_root_package("metadata", c.content)
      "xlsx:xmlMaps" => xlsx_with_aux_root_package("xmlMaps", c.content)
      "xlsx:queryTable" => xlsx_with_aux_root_package("queryTable", c.content)
      "xlsx:revisionHeaders" =>
        xlsx_with_aux_root_package("revisionHeaders", c.content)
      "xlsx:revisionLog" => xlsx_with_aux_root_package("revisionLog", c.content)
      "xlsx:userNames" => xlsx_with_aux_root_package("userNames", c.content)
      "xlsx:volatileDependencies" =>
        xlsx_with_aux_root_package("volatileDependencies", c.content)
      "xlsx:worksheetRefs" => xlsx_package_with_worksheet_refs(c.content)
      "xlsx:chartsheet" => xlsx_package_with_chartsheet(c.content)
      "xlsx:dialogsheet" => xlsx_package_with_dialogsheet(c.content)
      "xlsx:tableSingleCells" => xlsx_package_with_table_single_cells(c.content)
      "docx:settings" => docx_aux_package("settings", c.content)
      "docx:styles" => docx_aux_package("styles", c.content)
      "docx:numbering" => docx_aux_package("numbering", c.content)
      "docx:header" => docx_header_footer_package("header", c.content)
      "docx:footer" => docx_header_footer_package("footer", c.content)
      "docx:glossary" => docx_aux_package("glossary", c.content)
      "docx:fonts" => docx_aux_package("fonts", c.content)
      "docx:webSettings" => docx_aux_package("webSettings", c.content)
      "docx:comments" => docx_aux_package("comments", c.content)
      "docx:footnotes" => docx_aux_package("footnotes", c.content)
      "docx:endnotes" => docx_aux_package("endnotes", c.content)
      "docx:annotationRefs" => docx_package_with_annotation_refs(c.content)
      "docx:contentPart" => docx_package_with_content_part(c.content)
      _ => docx_package(c.content)
    }
    let output_format = match c.format {
      "pptx:theme" => "pptx"
      "pptx:presentation" => "pptx"
      "pptx:presentationPr" => "pptx"
      "pptx:viewPr" => "pptx"
      "pptx:themeOverride" => "pptx"
      "pptx:themeManager" => "pptx"
      "pptx:master-txstyle" => "pptx"
      "pptx:slideRefs" => "pptx"
      "pptx:comments" => "pptx"
      "pptx:commentAuthors" => "pptx"
      "pptx:sldSyncPr" => "pptx"
      "pptx:notes" => "pptx"
      "pptx:notesMaster" => "pptx"
      "pptx:handoutMaster" => "pptx"
      "pptx:presentationRefs" => "pptx"
      "xlsx:workbook" => "xlsx"
      "xlsx:sharedStrings" => "xlsx"
      "xlsx:styles" => "xlsx"
      "xlsx:comments" => "xlsx"
      "xlsx:calcChain" => "xlsx"
      "xlsx:connections" => "xlsx"
      "xlsx:metadata" => "xlsx"
      "xlsx:xmlMaps" => "xlsx"
      "xlsx:queryTable" => "xlsx"
      "xlsx:revisionHeaders" => "xlsx"
      "xlsx:revisionLog" => "xlsx"
      "xlsx:userNames" => "xlsx"
      "xlsx:volatileDependencies" => "xlsx"
      "xlsx:worksheetRefs" => "xlsx"
      "xlsx:chartsheet" => "xlsx"
      "xlsx:dialogsheet" => "xlsx"
      "xlsx:tableSingleCells" => "xlsx"
      "docx:settings" => "docx"
      "docx:styles" => "docx"
      "docx:numbering" => "docx"
      "docx:header" => "docx"
      "docx:footer" => "docx"
      "docx:glossary" => "docx"
      "docx:fonts" => "docx"
      "docx:webSettings" => "docx"
      "docx:comments" => "docx"
      "docx:footnotes" => "docx"
      "docx:endnotes" => "docx"
      "docx:annotationRefs" => "docx"
      "docx:contentPart" => "docx"
      _ => c.format
    }
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + output_format)
    let dir = ".snapshots/fixtures/" + output_format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + output_format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  for c in xcases {
    total = total + 1
    // Pick the styled host-package variant whose aux parts the
    // fixture actually carries.
    let bytes = match c.format {
      "xlsx" =>
        match c.styles {
          Some(s) => xlsx_package_styled(c.content, s)
          None => xlsx_package(c.content)
        }
      "docx" => docx_package_with_aux(c.content, c.numbering, c.doc_styles)
      _ => docx_package(c.content)
    }
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Metadata-case pass: docx fixtures carrying package-root core,
  // extended, and custom properties under `docProps/`.  Built by
  // `docx_package_with_doc_props` so the package `.rels`, content
  // types, and metadata XML roots are all validated together.
  for c in metadata_cases() {
    total = total + 1
    let bytes = docx_package_with_doc_props(
      c.content,
      c.core_properties,
      c.extended_properties,
      c.custom_properties,
    )
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Custom-XML-case pass: docx fixtures carrying arbitrary XML data
  // storage parts plus `customXmlProps` metadata.  Built by
  // `docx_package_with_custom_xml` so the main-document relationship,
  // item-level properties relationship, and content-type override are
  // validated as one OPC package graph.
  for c in custom_xml_cases() {
    total = total + 1
    let bytes = docx_package_with_custom_xml(
      c.content,
      c.custom_xml,
      c.custom_xml_properties,
    )
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Tabled-case pass: xlsx fixtures whose worksheet references one
  // or more <table> parts via <tableParts>.  Built by
  // `xlsx_package_with_tables` so the per-worksheet relationships,
  // the `xl/tables/table*.xml` parts, and the `…spreadsheetml.table`
  // content-type override land in the OPC package.
  for c in tabled_cases() {
    total = total + 1
    let bytes = xlsx_package_with_tables(c.content, c.tables, styles=c.styles)
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Spreadsheet-drawing-case pass: xlsx fixtures whose worksheet
  // references a §20.5 DrawingML Spreadsheet Drawing part. Built by
  // `xlsx_with_drawing_root_package` so the worksheet relationship,
  // drawing content type, and drawing-side contentPart customXml
  // relationship are validated together.
  for c in spreadsheet_drawing_cases() {
    total = total + 1
    let bytes = xlsx_with_drawing_root_package(c.drawing)
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // VML-drawing-case pass: xlsx fixtures whose worksheet references
  // a legacy VML Drawing part through `<legacyDrawing r:id>`.  Built
  // by `xlsx_package_with_vml_drawing` so the worksheet relationship,
  // VML content type, and null-namespace `<xml>` wrapper are
  // validated together.
  for c in vml_drawing_cases() {
    total = total + 1
    let bytes = xlsx_package_with_vml_drawing(c.content, c.vml_drawing)
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Pivot-case pass: xlsx fixtures whose worksheet references a
  // §18.10 `<pivotTable>` part.  Built by `xlsx_package_with_pivot`
  // which wires the workbook `<pivotCaches>` entry, the workbook /
  // worksheet / pivot table / cache definition `_rels` files, and
  // the three `[Content_Types]` overrides.
  for c in pivoted_cases() {
    total = total + 1
    let bytes = xlsx_package_with_pivot(
      c.content,
      c.cache_def,
      c.cache_records,
      c.pivot_def,
    )
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Sparkline-case pass: xlsx fixtures whose worksheet carries a
  // Microsoft x14 sparklines extension inline.  Built by
  // `xlsx_package_with_sparklines` which splices the
  // `<extLst>/<ext uri="{05C60535-…}">/<x14:sparklineGroups>`
  // carrier onto the worksheet's children (no separate OPC part —
  // the payload is inline per `[MS-XLSX]` §2.2.4).
  for c in sparkline_cases() {
    total = total + 1
    let bytes = xlsx_package_with_sparklines(c.content, c.sparkline_groups)
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Charted-case pass: pptx fixtures whose slide carries a
  // `<p:graphicFrame>` referencing a §21.2 DrawingML chart part.
  // Built by `pptx_package_with_chart` which wires the chart's
  // slide-side relationship (rId2 → `charts/chart1.xml`) and the
  // `…drawingml.chart+xml` content-type override.
  for c in charted_cases() {
    total = total + 1
    let bytes = pptx_package_with_chart(c.content, c.chart_space)
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Chart-user-shapes-case pass: pptx fixtures whose chart part
  // carries a `<c:userShapes r:id>` relationship to a §21.3 Chart
  // Drawing part.  Built by `pptx_package_with_chart_usershapes_real`
  // so the chart-side relationship, chartshapes content type, and
  // `cdr:*` payload are validated together.
  for c in chart_user_shapes_cases() {
    total = total + 1
    let bytes = pptx_package_with_chart_usershapes_real(
      c.content,
      c.chart_space,
      c.user_shapes,
    )
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Diagrammed-case pass: pptx fixtures whose slide carries a
  // `<p:graphicFrame>` referencing the four §21.4 DrawingML
  // SmartArt parts (data model, layout def, style def, color
  // transform).  Built by `pptx_package_with_diagram` which wires
  // rId2..rId5 on the slide and the four content-type overrides.
  for c in diagrammed_cases() {
    total = total + 1
    let bytes = pptx_package_with_diagram(
      c.content,
      c.data_model,
      c.layout_def,
      c.style_def,
      c.colors_def,
      c.drawing,
    )
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // External-reference-case pass: xlsx fixtures whose workbook
  // declares `<externalReferences>` resolved to an
  // `xl/externalLinks/externalLink1.xml` part (§18.14.7 /
  // §18.14.5).  Built by `xlsx_package_with_externals` which
  // wires the workbook rId2 → external link relationship and the
  // `…spreadsheetml.externalLink+xml` content-type override.
  for c in external_ref_cases() {
    total = total + 1
    let bytes = xlsx_package_with_externals(c.content, c.external_link)
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Media-slide-case pass: pptx fixtures whose slide carries a
  // `<a:videoFile r:link>` and/or `<a:hlinkClick r:id>` whose
  // rIds resolve via slide-side External-mode relationships.
  // Built by `pptx_package_with_slide_rels` which wires the
  // layout rId1 plus the caller-supplied (rId2..) extras.
  for c in media_slide_cases() {
    total = total + 1
    let bytes = pptx_package_with_slide_rels(c.content, c.extra_rels)
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  // Image-slide-case pass: pptx fixtures whose slide contains a
  // `<p:pic>` with an embedded image (`r:embed`) and blip effects.
  // Built by `pptx_package_with_embedded_image` which wires the
  // slide-side rId2 → `media/image1.png` relationship and the
  // `Default Extension="png"` content-type.
  for c in image_slide_cases() {
    total = total + 1
    let bytes = pptx_package_with_embedded_image(c.content, c.image_bytes)
    let _ = try? @fs.create_dir(".snapshots/fixtures/" + c.format)
    let dir = ".snapshots/fixtures/" + c.format + "/" + c.category
    let _ = try? @fs.create_dir(dir)
    let path = dir + "/" + c.id + "." + c.format
    try @fs.write_bytes_to_file(path, bytes) catch {
      _ => println("!! failed to write " + path)
    } noraise {
      _ => written = written + 1
    }
  }
  println("visual fixtures: \{written}/\{total} -> .snapshots/fixtures/")
}

///|
/// Collect every `ImageSlideCase` from per-category extender
/// functions.  Uses `pptx_package_with_embedded_image` for fixtures
/// whose slide carries a `<p:pic>` with an `r:embed` blip and one
/// or more §20.1.8 raster effects.
fn image_slide_cases() -> Array[ImageSlideCase] {
  let cases : Array[ImageSlideCase] = []
  extras_pml_blip_effects(cases)
  cases
}

///|
/// Collect every `SparklineCase` from per-category extender
/// functions.  Mirrors `pivoted_cases()` for fixtures that need the
/// `xlsx_package_with_sparklines` builder (Microsoft x14
/// sparklines, `[MS-XLSX]` §2.2.4).  Subagents add fixtures by
/// editing `fixtures_sml_sparklines.mbt`.
fn sparkline_cases() -> Array[SparklineCase] {
  let scases : Array[SparklineCase] = []
  extras_sml_sparklines(scases)
  scases
}

///|
/// Collect every `TabledCase` from per-category extender functions.
/// Mirrors `extra_cases()` / `extended_cases()` but for fixtures that
/// need the `xlsx_package_with_tables` builder.  Subagents add
/// fixtures by editing `fixtures_sml_tables.mbt` (and future
/// table-bearing siblings).
fn tabled_cases() -> Array[TabledCase] {
  let tcases : Array[TabledCase] = []
  extras_sml_tables(tcases)
  tcases
}

///|
/// Collect every §20.5 DrawingML Spreadsheet Drawing package
/// fixture. These cover `dml-spreadsheetDrawing.xsd` part roots and
/// anchor/object-choice branches.
fn spreadsheet_drawing_cases() -> Array[SpreadsheetDrawingCase] {
  let xdcases : Array[SpreadsheetDrawingCase] = []
  extras_dml_spreadsheet_drawing(xdcases)
  xdcases
}

///|
/// Collect every legacy VML Drawing package fixture.  These cover
/// Transitional VML namespaces reached through a worksheet's
/// `vmlDrawing` relationship.
fn vml_drawing_cases() -> Array[VmlDrawingCase] {
  let vcases : Array[VmlDrawingCase] = []
  extras_vml_spreadsheet_drawing(vcases)
  vcases
}

///|
/// Collect every `PivotedCase` from per-category extender functions.
/// Mirrors `tabled_cases()` for fixtures that need the
/// `xlsx_package_with_pivot` builder (§18.10 PivotTable plumbing).
fn pivoted_cases() -> Array[PivotedCase] {
  let pcases : Array[PivotedCase] = []
  extras_sml_pivots(pcases)
  extras_r29_sml_pivot_cache_rich(pcases)
  pcases
}

///|
/// Collect every `ChartedCase` from per-category extender functions.
/// Mirrors `pivoted_cases()` for fixtures that need the
/// `pptx_package_with_chart` builder (§21.2 DrawingML chart).
fn charted_cases() -> Array[ChartedCase] {
  let ccases : Array[ChartedCase] = []
  extras_dml_charts(ccases)
  ccases
}

///|
/// Collect every Chart Drawing `userShapes` package fixture.  These
/// cover §21.3 chartDrawing payloads reached through a chart part's
/// `chartUserShapes` relationship.
fn chart_user_shapes_cases() -> Array[ChartUserShapesCase] {
  let cdcases : Array[ChartUserShapesCase] = []
  extras_dml_chart_drawing(cdcases)
  cdcases
}

///|
/// Collect every `DiagrammedCase` from per-category extender
/// functions.  Mirrors `pivoted_cases()` for fixtures that need the
/// `pptx_package_with_diagram` builder (§21.4 DrawingML SmartArt).
fn diagrammed_cases() -> Array[DiagrammedCase] {
  let dcases : Array[DiagrammedCase] = []
  extras_dml_diagrams(dcases)
  dcases
}

///|
/// Collect every metadata-bearing package fixture.  These cover OPC
/// document-property parts rather than visible body content.
fn metadata_cases() -> Array[MetadataCase] {
  let mcases : Array[MetadataCase] = []
  extras_doc_props_metadata(mcases)
  mcases
}

///|
/// Collect every Custom XML Data Storage package fixture.  These
/// cover standard item-properties parts and ECMA bibliography data
/// stored through the `customXml` relationship type.
fn custom_xml_cases() -> Array[CustomXmlCase] {
  let ccases : Array[CustomXmlCase] = []
  extras_bibliography_custom_xml(ccases)
  extras_shared_ancillary_custom_xml(ccases)
  extras_opc_digital_signature_custom_xml(ccases)
  ccases
}
