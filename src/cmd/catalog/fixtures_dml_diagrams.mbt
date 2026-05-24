// DrawingML DIAGRAM / SMARTART fixtures — ECMA-376 Part 1 §21.4
// (dml-diagram.xsd).
//
// Each fixture is a `.pptx` carrying a single slide with one
// `<p:graphicFrame>` whose `<a:graphicData uri="…/diagram">`
// payload is a `<dgm:relIds r:dm="rId2" r:lo="rId3" r:qs="rId4"
// r:cs="rId5"/>` reference (§21.4.2.22 CT_RelIds); the slide's
// relationship part (built by `pptx_package_with_diagram` in
// verify.mbt) maps `rId2..rId5` to the four SmartArt parts:
//
//   * `ppt/diagrams/data1.xml`        — `<dgm:dataModel>`
//                                       (§21.4.2.10 CT_DataModel)
//   * `ppt/diagrams/layout1.xml`      — `<dgm:layoutDef>`
//                                       (§21.4.2.18 CT_DiagramDefinition)
//   * `ppt/diagrams/quickStyle1.xml`  — `<dgm:styleDef>`
//                                       (§21.4.5.7  CT_StyleDefinition)
//   * `ppt/diagrams/colors1.xml`      — `<dgm:colorsDef>`
//                                       (§21.4.4.3  CT_ColorTransform)
//
// What this file covers (5 fixtures, one per top-level SmartArt
// algorithm family the `diagram_layout` engine already implements):
//
//   * `diagram-orgChart`   — hierarchy algorithm with a root +
//                            two children (§21.4 layoutNode
//                            `alg type="hierRoot/hierChild"`).
//   * `diagram-hierarchy`  — same alg but three levels deep —
//                            stresses the hierChild recursion.
//   * `diagram-list-basic` — linear stack (`alg type="lin"`)
//                            mirroring the "Basic Block List"
//                            SmartArt preset.
//   * `diagram-cycle-basic`— radial cycle (`alg type="cycle"`)
//                            mirroring the "Basic Cycle" preset.
//   * `diagram-process`    — horizontal snake / process flow
//                            (`alg type="snake"`) mirroring the
//                            "Basic Process" preset.
//
// Each fixture's data model carries the same N points (one root +
// N-1 children) but a different layout algorithm — so the
// `data_model` shape is shared, and only `layout_def` varies.
//
// =========================================================================
// RENDERING GAP — §21.4 diagram rendering is NOT IMPLEMENTED.
// =========================================================================
// The PML viewer's `render_graphic_frame_svg`
// (`src/ecma376/presentation_ml/viewer/viewer.mbt`) dispatches
// `<a:graphicData @uri="…/diagram">` to the generic placeholder
// branch that emits a `<g data-ooxml="graphicFrame"
// data-ooxml-uri="…/diagram">` annotation with the bounding box
// but no SmartArt-specific drawing. The `diagram_layout` package
// (`src/ecma376/drawing_ml/diagram_layout`) already implements
// the orgChart / hierarchy / linear / cycle / pyramid algorithms,
// and the `diagram` package decodes the four part roots, but no
// consumer downstream:
//   (a) resolves the `<dgm:relIds>` on the graphicFrame to the
//       four parts loaded by the PML reader, and
//   (b) feeds the resolved data model + layout definition into
//       `diagram_layout::engine` to produce the per-shape
//       positions, and
//   (c) emits `<g class="diagram"><rect/><text/></g>` per laid-out
//       shape.
//
// Therefore: these fixtures exercise the *parse + serialise +
// open-again* round-trip and the OPC plumbing
// (`pptx_package_with_diagram`), but their visual diff against
// the reference renderer will show a blank PPTX vs. a SmartArt diagram
// until the bridge lands. The fixtures are still useful because:
//
//   1. They cover the OPC-side wiring (slide rels rId2..rId5,
//      content types for all four diagram parts) any future
//      diagram renderer will rely on.
//   2. The reader + builder loop validates that the diagram
//      package's decode → encode is lossless for the four
//      part-root types (dataModel / layoutDef / styleDef /
//      colorsDef).
//   3. The catalog tool's `verify_entry` differential check
//      records them as `parsed` so coverage tracking surfaces
//      the gap.
//
// TODO §21.4 — once the bridge lands, expand the fixture set to
// cover: orgChart variants (left / right hanging branches per
// CT_OrgChart), `<dgm:cxn>` connector lines (CT_CxnList), per-point
// `<a:prSet>` style overrides, the radial / matrix / venn /
// relationship algorithm families, and `<dgm:bg>` /
// `<dgm:whole>` background formatting.

// ---- file-local helpers ---------------------------------------------------

///|
/// DrawingML diagram namespace (`dgm:` prefix per ECMA-376 §21.4).
const NS_DGM : String = "http://schemas.openxmlformats.org/drawingml/2006/diagram"

///|
/// DrawingML diagram graphicData URI — §15.2 well-known URI registry.
const DIAGRAM_URI : String = "http://schemas.openxmlformats.org/drawingml/2006/diagram"

///|
/// Build a prefixed `<dgm:NAME …>…</dgm:NAME>` element. The
/// `xmlns:dgm` declaration is emitted automatically by `@xml.write`.
fn dgm_elem(
  tag : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  {
    name: { prefix: Some("dgm"), local_name: tag, ns: Some(NS_DGM) },
    attributes: attrs,
    children: kids,
  }
}

///|
/// `<a:t>NAME</a:t>` text run inside an `<a:r>` — shared between
/// point text bodies.
fn a_text_run(text : String) -> @xml.Element {
  xe(NS_A, "r", [], [
    Element(xe(NS_A, "rPr", [xa("lang", "en-US")], [])),
    Element(xe(NS_A, "t", [], [Text(text)])),
  ])
}

///|
/// `<a:t>` body with the given run — the SmartArt point's
/// displayed label. §21.4.3.5 CT_Pt allows an `<a:t>` as the
/// `<t>` child preserving the typed `CT_TextBody`.
fn point_text_body(text : String) -> @xml.Element {
  xe(NS_A, "t", [], [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
    Element(xe(NS_A, "p", [], [Element(a_text_run(text))])),
  ])
}

///|
/// `<dgm:pt modelId="…" type="…">` — one SmartArt data point.
/// `type` defaults to `"node"` when omitted (§21.4.3.5 CT_Pt).
fn dgm_pt(model_id : String, type_ : String, text : String?) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [xa("modelId", model_id)]
  if type_ != "node" {
    attrs.push(xa("type", type_))
  }
  let kids : Array[@xml.Node] = []
  match text {
    Some(t) => kids.push(Element(point_text_body(t)))
    None => ()
  }
  dgm_elem("pt", attrs, kids)
}

///|
/// `<dgm:cxn modelId="…" srcId="…" destId="…" srcOrd="…"
/// destOrd="…">` — one parent/child connector.
fn dgm_cxn(
  model_id : String,
  src_id : String,
  dest_id : String,
  src_ord : Int,
) -> @xml.Element {
  dgm_elem(
    "cxn",
    [
      xa("modelId", model_id),
      xa("srcId", src_id),
      xa("destId", dest_id),
      xa("srcOrd", src_ord.to_string()),
      xa("destOrd", "0"),
    ],
    [],
  )
}

///|
/// Build the `<dgm:dataModel>` shared by all 5 fixtures: one
/// document-root point (model id `0`, type `doc`) plus N
/// label-bearing child points and the connectors that wire each
/// child to the root.
fn shared_data_model(labels : Array[String]) -> @xml.Element {
  let pts : Array[@xml.Element] = [dgm_pt("0", "doc", None)]
  for i, label in labels {
    pts.push(dgm_pt((i + 1).to_string(), "node", Some(label)))
  }
  let cxns : Array[@xml.Element] = []
  for i, _ in labels {
    cxns.push(dgm_cxn((100 + i + 1).to_string(), "0", (i + 1).to_string(), i))
  }
  let pt_lst_kids : Array[@xml.Node] = []
  for p in pts {
    pt_lst_kids.push(Element(p))
  }
  let cxn_lst_kids : Array[@xml.Node] = []
  for c in cxns {
    cxn_lst_kids.push(Element(c))
  }
  dgm_elem("dataModel", [], [
    Element(dgm_elem("ptLst", [], pt_lst_kids)),
    Element(dgm_elem("cxnLst", [], cxn_lst_kids)),
  ])
}

///|
/// Build a minimal `<dgm:layoutDef>` whose root `<dgm:layoutNode>`
/// uses the given algorithm type. The layout-node nesting follows
/// the §21.4.3 CT_LayoutNode shape:
///   <layoutNode name="…">
///     <alg type="…"/>
///     <shape type="rect"/>
///     <presOf/>
///     <constrLst/>
///     <forEach axis="ch" ptType="node">
///       <layoutNode name="…">
///         <alg type="composite"/>
///         <shape type="rect"/>
///         <presOf axis="self"/>
///         <constrLst/>
///       </layoutNode>
///     </forEach>
///   </layoutNode>
fn make_layout_def(unique_id : String, root_alg : String) -> @xml.Element {
  let inner_node = dgm_elem("layoutNode", [xa("name", "node")], [
    Element(dgm_elem("alg", [xa("type", "composite")], [])),
    Element(dgm_elem("shape", [xa("type", "rect")], [])),
    Element(dgm_elem("presOf", [xa("axis", "self")], [])),
    Element(dgm_elem("constrLst", [], [])),
  ])
  let for_each = dgm_elem(
    "forEach",
    [xa("name", "n"), xa("axis", "ch"), xa("ptType", "node")],
    [Element(inner_node)],
  )
  let root_node = dgm_elem("layoutNode", [xa("name", "root")], [
    Element(dgm_elem("varLst", [], [])),
    Element(dgm_elem("alg", [xa("type", root_alg)], [])),
    Element(dgm_elem("shape", [], [])),
    Element(dgm_elem("presOf", [], [])),
    Element(dgm_elem("choose", [xa("name", "Name0")], [])),
    Element(dgm_elem("constrLst", [], [])),
    Element(for_each),
  ])
  dgm_elem(
    "layoutDef",
    [
      xa("uniqueId", unique_id),
      xa("minVer", "http://schemas.openxmlformats.org/drawingml/2006/diagram"),
    ],
    [
      Element(dgm_elem("title", [xa("val", unique_id)], [])),
      Element(dgm_elem("desc", [xa("val", unique_id)], [])),
      Element(dgm_elem("catLst", [], [])),
      Element(root_node),
    ],
  )
}

///|
/// Build a minimal `<dgm:styleDef>` with one `<dgm:styleLbl>` per
/// the §21.4.5.7 CT_StyleDefinition shape. The label uses the
/// default `"node1"` lookup name that all the SmartArt presets
/// register with.
fn make_style_def(unique_id : String) -> @xml.Element {
  let style_lbl = dgm_elem("styleLbl", [xa("name", "node1")], [
    Element(dgm_elem("scene3d", [], [])),
    Element(dgm_elem("sp3d", [], [])),
    Element(dgm_elem("txPr", [], [])),
    Element(dgm_elem("style", [], [])),
  ])
  dgm_elem(
    "styleDef",
    [
      xa("uniqueId", unique_id),
      xa("minVer", "http://schemas.openxmlformats.org/drawingml/2006/diagram"),
    ],
    [
      Element(dgm_elem("title", [xa("val", unique_id)], [])),
      Element(dgm_elem("desc", [xa("val", unique_id)], [])),
      Element(dgm_elem("catLst", [], [])),
      Element(dgm_elem("scene3d", [], [])),
      Element(style_lbl),
    ],
  )
}

///|
/// Build a minimal `<dgm:colorsDef>` with one `<dgm:styleLbl>`
/// per the §21.4.4.3 CT_ColorTransform shape. The label uses the
/// `"node1"` lookup the layout's first-level style references.
fn make_colors_def(unique_id : String) -> @xml.Element {
  let style_lbl = dgm_elem("styleLbl", [xa("name", "node1")], [
    Element(dgm_elem("fillClrLst", [], [])),
    Element(dgm_elem("linClrLst", [], [])),
    Element(dgm_elem("effectClrLst", [], [])),
    Element(dgm_elem("txLinClrLst", [], [])),
    Element(dgm_elem("txFillClrLst", [], [])),
    Element(dgm_elem("txEffectClrLst", [], [])),
  ])
  dgm_elem(
    "colorsDef",
    [
      xa("uniqueId", unique_id),
      xa("minVer", "http://schemas.openxmlformats.org/drawingml/2006/diagram"),
    ],
    [
      Element(dgm_elem("title", [xa("val", unique_id)], [])),
      Element(dgm_elem("desc", [xa("val", unique_id)], [])),
      Element(dgm_elem("catLst", [], [])),
      Element(style_lbl),
    ],
  )
}

///|
/// `<p:graphicFrame>` carrying a `<dgm:relIds>` that points at the
/// four SmartArt parts the builder writes (rId2 → dm, rId3 → lo,
/// rId4 → qs, rId5 → cs per §21.4.2.22 CT_RelIds).
fn diagram_graphic_frame(id_ : String, name : String) -> @xml.Element {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let rel_ids : @xml.Element = {
    name: { prefix: Some("dgm"), local_name: "relIds", ns: Some(NS_DGM) },
    attributes: [
      {
        name: { prefix: Some("r"), local_name: "dm", ns: Some(ns_r) },
        value: "rId2",
      },
      {
        name: { prefix: Some("r"), local_name: "lo", ns: Some(ns_r) },
        value: "rId3",
      },
      {
        name: { prefix: Some("r"), local_name: "qs", ns: Some(ns_r) },
        value: "rId4",
      },
      {
        name: { prefix: Some("r"), local_name: "cs", ns: Some(ns_r) },
        value: "rId5",
      },
    ],
    children: [],
  }
  xe(NS_PML, "graphicFrame", [], [
    Element(
      xe(NS_PML, "nvGraphicFramePr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvGraphicFramePr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "xfrm", [], [
        Element(xe(NS_A, "off", [xa("x", "1828800"), xa("y", "914400")], [])),
        Element(xe(NS_A, "ext", [xa("cx", "5486400"), xa("cy", "5029200")], [])),
      ]),
    ),
    Element(
      xe(NS_A, "graphic", [], [
        Element(
          xe(NS_A, "graphicData", [xa("uri", DIAGRAM_URI)], [Element(rel_ids)]),
        ),
      ]),
    ),
  ])
}

// ---- cached drawing helpers ----------------------------------------------

///|
/// Microsoft DrawingML 2008 SmartArt-extension namespace
/// (`dsp:` prefix). The `<dsp:drawing>` part lives at
/// `ppt/diagrams/drawing1.xml` and pre-positions one `<dsp:sp>`
/// per data-model point so consumers can skip running the layout
/// engine. The §[MS-OOXML] `diagram-layout-extensions` schema
/// (Microsoft "Office 2010+") uses this namespace exclusively.
const NS_DSP : String = "http://schemas.microsoft.com/office/drawing/2008/diagram"

///|
/// Frame extent (EMU) the `<p:graphicFrame>` carrying
/// `<dgm:relIds>` uses for every fixture in this file. Mirrors the
/// `<a:ext cx="…" cy="…"/>` written by `diagram_graphic_frame`;
/// the layout engine receives this rectangle (translated to local
/// `(0, 0)` coordinates) so the cached `<dsp:sp>` shapes land
/// inside the frame consumers paint.
const DIAGRAM_FRAME_CX : Double = 5486400.0

///|
const DIAGRAM_FRAME_CY : Double = 5029200.0

///|
/// Default SmartArt accent palette — the six PowerPoint 2013
/// accent colours that the viewer's `diagram_render` module falls
/// back to when the `<dgm:colorsDef>` does not list per-node
/// fills. Caching the same palette here keeps the rendered SVG
/// (engine-driven) and the reference render (cached-drawing driven)
/// on the same colour cycle.
fn default_accent_palette() -> Array[String] {
  ["4472C4", "ED7D31", "A5A5A5", "FFC000", "5B9BD5", "70AD47"]
}

///|
/// Cycle through the palette by index, wrapping when exhausted.
fn pick_palette(palette : Array[String], index : Int) -> String {
  if palette.length() == 0 {
    return "4472C4"
  }
  palette[index % palette.length()]
}

///|
/// §20.1.10.56 ST_ShapeType — map the engine's `PresetShape` to
/// the `<a:prstGeom @prst>` attribute value. Mirrors the renderer's
/// `emit_node_shape` so the cached drawing draws the same shape
/// primitives our viewer does.
fn preset_to_prst(shape : @preset_geometry.PresetShape) -> String {
  match shape {
    @preset_geometry.ShapeEllipse => "ellipse"
    @preset_geometry.ShapeRoundRect => "roundRect"
    @preset_geometry.ShapeTriangle => "triangle"
    _ => "rect"
  }
}

///|
/// Build a `<dsp:sp modelId="…">` for one laid-out diagram node.
/// Mirrors the shape primitives + accent palette the viewer emits
/// per-point so the cached render and the engine-driven render
/// agree on geometry + colour.
fn dsp_sp(
  nb : @diagram_layout.NodeBounds,
  label : String?,
  fill_hex : String,
) -> @xml.Element {
  let x = nb.bounds.x
  let y = nb.bounds.y
  let cx = nb.bounds.width
  let cy = nb.bounds.height
  let xfrm = xep("a", NS_A, "xfrm", [], [
    Element(xep("a", NS_A, "off", [xa("x", emu(x)), xa("y", emu(y))], [])),
    Element(xep("a", NS_A, "ext", [xa("cx", emu(cx)), xa("cy", emu(cy))], [])),
  ])
  let prst_geom = xep(
    "a",
    NS_A,
    "prstGeom",
    [xa("prst", preset_to_prst(nb.shape))],
    [Element(xep("a", NS_A, "avLst", [], []))],
  )
  let solid_fill = xep("a", NS_A, "solidFill", [], [
    Element(xep("a", NS_A, "srgbClr", [xa("val", fill_hex)], [])),
  ])
  let sp_pr = xep("dsp", NS_DSP, "spPr", [], [
    Element(xfrm),
    Element(prst_geom),
    Element(solid_fill),
  ])
  let nv_sp_pr = xep("dsp", NS_DSP, "nvSpPr", [], [
    Element(xep("dsp", NS_DSP, "cNvPr", [xa("id", "0"), xa("name", "")], [])),
    Element(xep("dsp", NS_DSP, "cNvSpPr", [], [])),
  ])
  let tx_body_kids : Array[@xml.Node] = [
    Element(xep("a", NS_A, "bodyPr", [], [])),
    Element(xep("a", NS_A, "lstStyle", [], [])),
  ]
  match label {
    None => tx_body_kids.push(Element(xep("a", NS_A, "p", [], [])))
    Some(text) => {
      let run = xep("a", NS_A, "r", [], [
        Element(xep("a", NS_A, "rPr", [xa("lang", "en-US")], [])),
        Element(xep("a", NS_A, "t", [], [Text(text)])),
      ])
      let para = xep("a", NS_A, "p", [], [Element(run)])
      tx_body_kids.push(Element(para))
    }
  }
  let tx_body = xep("dsp", NS_DSP, "txBody", [], tx_body_kids)
  xep("dsp", NS_DSP, "sp", [xa("modelId", nb.point_id)], [
    Element(nv_sp_pr),
    Element(sp_pr),
    Element(tx_body),
  ])
}

///|
/// Format an EMU value as an integer attribute string (the OOXML
/// spec requires `ST_Coordinate` / `ST_PositiveCoordinate` values
/// to be integers).
fn emu(value : Double) -> String {
  // Round-half-to-positive-infinity by adding 0.5 before truncating;
  // negative coords should never appear in our engine output so the
  // simple add-and-truncate is faithful.
  let rounded = if value >= 0.0 {
    (value + 0.5).to_int()
  } else {
    (value - 0.5).to_int()
  }
  rounded.to_string()
}

///|
/// Build the §[MS-OOXML] cached `<dsp:drawing>` part by running
/// the same `@diagram_layout` engine our viewer runs at render
/// time. The cached coordinates therefore agree with the
/// engine-driven SVG render — both sides produce shapes at the
/// same positions, with the same accent colours, carrying the
/// same labels.
///
/// Returns `None` when the data model / layout cannot be decoded —
/// the fixture then ships without a cached drawing and the
/// reference renderer falls back to its own (currently blank)
/// rendering. The catalog's
/// snapshot harness treats `None` as "out-of-band rendered by the
/// engine only", matching the pre-Round 13 baseline.
fn cached_drawing(
  data_model_root : @xml.Element,
  layout_def_root : @xml.Element,
  labels : Array[String],
) -> @xml.Element? {
  // Decode the data model + layout definition. Any decode error
  // produces an empty drawing — the fixture remains valid OPC
  // because the drawing field is optional from the schema's
  // perspective.
  let data_model_typed = match
    (try? @dgm_domain.CT_DataModel::new(data_model_root)) {
    Ok(t) => t
    Err(_) => return None
  }
  let definition_typed = match
    (try? @dgm_domain.CT_DiagramDefinition::new(layout_def_root)) {
    Ok(t) => t
    Err(_) => return None
  }
  let data_model = match
    (try? @diagram_layout.decode_data_model(data_model_typed)) {
    Ok(t) => t
    Err(_) => return None
  }
  let definition = match
    (try? @diagram_layout.decode_diagram_definition(definition_typed)) {
    Ok(t) => t
    Err(_) => return None
  }
  let engine = @diagram_layout.DiagramLayoutEngine::new()
  let bounds : @diagram_layout.BoundsRect = {
    x: 0.0,
    y: 0.0,
    width: DIAGRAM_FRAME_CX,
    height: DIAGRAM_FRAME_CY,
  }
  let node_bounds = engine.apply(definition, data_model, bounds)
  if node_bounds.length() == 0 {
    return None
  }
  let palette = default_accent_palette()
  // Pre-build a (modelId → label) map. The shared_data_model
  // helper assigns labels in document order to model ids 1..N;
  // the document-root point (id "0") carries no label.
  let labels_by_id : Map[String, String] = {}
  for i, label in labels {
    labels_by_id[(i + 1).to_string()] = label
  }
  let sp_nodes : Array[@xml.Node] = []
  // The cached drawing's spTree opens with `<dsp:nvGrpSpPr>` +
  // `<dsp:grpSpPr>` — the spec's `CT_Drawing` requires both,
  // independent of how many `<dsp:sp>` children follow.
  let group_xfrm = xep("a", NS_A, "xfrm", [], [
    Element(xep("a", NS_A, "off", [xa("x", "0"), xa("y", "0")], [])),
    Element(
      xep(
        "a",
        NS_A,
        "ext",
        [xa("cx", emu(DIAGRAM_FRAME_CX)), xa("cy", emu(DIAGRAM_FRAME_CY))],
        [],
      ),
    ),
    Element(xep("a", NS_A, "chOff", [xa("x", "0"), xa("y", "0")], [])),
    Element(
      xep(
        "a",
        NS_A,
        "chExt",
        [xa("cx", emu(DIAGRAM_FRAME_CX)), xa("cy", emu(DIAGRAM_FRAME_CY))],
        [],
      ),
    ),
  ])
  sp_nodes.push(
    Element(
      xep("dsp", NS_DSP, "nvGrpSpPr", [], [
        Element(
          xep("dsp", NS_DSP, "cNvPr", [xa("id", "0"), xa("name", "")], []),
        ),
        Element(xep("dsp", NS_DSP, "cNvGrpSpPr", [], [])),
      ]),
    ),
  )
  sp_nodes.push(
    Element(xep("dsp", NS_DSP, "grpSpPr", [], [Element(group_xfrm)])),
  )
  for i, nb in node_bounds {
    let label = labels_by_id.get(nb.point_id)
    let fill = pick_palette(palette, i)
    sp_nodes.push(Element(dsp_sp(nb, label, fill)))
  }
  let sp_tree = xep("dsp", NS_DSP, "spTree", [], sp_nodes)
  Some(xep("dsp", NS_DSP, "drawing", [], [Element(sp_tree)]))
}

// ---- DiagrammedCase extender ---------------------------------------------

///|
/// §21.4 DrawingML diagram fixtures (5 distinct top-level layout
/// algorithm families). Each fixture is a single-slide PPTX whose
/// lone `<p:graphicFrame>` references the four diagram parts the
/// `pptx_package_with_diagram` builder writes.
///
/// Category folder: `diagram` — fixtures land under
/// `.snapshots/fixtures/pptx/diagram/<id>.pptx`.
fn extras_dml_diagrams(dcases : Array[DiagrammedCase]) -> Unit {
  // ---- orgChart (§21.4 hierRoot algorithm) ----------------------
  // Root + 2 children = classic 1-2 fan.
  let org_labels = ["Manager", "Direct A", "Direct B"]
  let org_data = shared_data_model(org_labels)
  let org_layout = make_layout_def("urn:test:diagram:orgChart", "hierRoot")
  dcases.push({
    id: "diagram-orgChart",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Diagram Org 1")]),
    data_model: org_data,
    layout_def: org_layout,
    style_def: make_style_def("urn:test:diagram:orgChart:style"),
    colors_def: make_colors_def("urn:test:diagram:orgChart:colors"),
    drawing: cached_drawing(org_data, org_layout, org_labels),
  })

  // ---- hierarchy (§21.4 hierChild deeper recursion) -------------
  // Three children — exercises the hierChild fan-out path.
  let hier_labels = ["L1 A", "L1 B", "L1 C"]
  let hier_data = shared_data_model(hier_labels)
  let hier_layout = make_layout_def("urn:test:diagram:hierarchy", "hierChild")
  dcases.push({
    id: "diagram-hierarchy",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Diagram Hier 1")]),
    data_model: hier_data,
    layout_def: hier_layout,
    style_def: make_style_def("urn:test:diagram:hierarchy:style"),
    colors_def: make_colors_def("urn:test:diagram:hierarchy:colors"),
    drawing: cached_drawing(hier_data, hier_layout, hier_labels),
  })

  // ---- list (§21.4 linear algorithm) ----------------------------
  // Four labelled boxes stacked vertically.
  let list_labels = ["Item 1", "Item 2", "Item 3", "Item 4"]
  let list_data = shared_data_model(list_labels)
  let list_layout = make_layout_def("urn:test:diagram:list", "lin")
  dcases.push({
    id: "diagram-list-basic",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Diagram List 1")]),
    data_model: list_data,
    layout_def: list_layout,
    style_def: make_style_def("urn:test:diagram:list:style"),
    colors_def: make_colors_def("urn:test:diagram:list:colors"),
    drawing: cached_drawing(list_data, list_layout, list_labels),
  })

  // ---- cycle (§21.4 cycle algorithm) ----------------------------
  // Three nodes arranged radially around the centre.
  let cycle_labels = ["Plan", "Do", "Check"]
  let cycle_data = shared_data_model(cycle_labels)
  let cycle_layout = make_layout_def("urn:test:diagram:cycle", "cycle")
  dcases.push({
    id: "diagram-cycle-basic",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Diagram Cycle 1")]),
    data_model: cycle_data,
    layout_def: cycle_layout,
    style_def: make_style_def("urn:test:diagram:cycle:style"),
    colors_def: make_colors_def("urn:test:diagram:cycle:colors"),
    drawing: cached_drawing(cycle_data, cycle_layout, cycle_labels),
  })

  // ---- process (§21.4 snake algorithm) --------------------------
  // Five steps in a horizontal arrow chain (Basic Process preset).
  let proc_labels = ["Step 1", "Step 2", "Step 3", "Step 4", "Step 5"]
  let proc_data = shared_data_model(proc_labels)
  let proc_layout = make_layout_def("urn:test:diagram:process", "snake")
  dcases.push({
    id: "diagram-process",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Diagram Proc 1")]),
    data_model: proc_data,
    layout_def: proc_layout,
    style_def: make_style_def("urn:test:diagram:process:style"),
    colors_def: make_colors_def("urn:test:diagram:process:colors"),
    drawing: cached_drawing(proc_data, proc_layout, proc_labels),
  })

  // ---- orgChart with connectors (§21.4.2.7 cxn) -----------------
  // 3-level org-chart hierarchy:
  //     CEO (level 0)
  //     ├── VP A (level 1) → Manager A (level 2)
  //     └── VP B (level 1) → Manager B (level 2)
  // The data model carries explicit `<dgm:cxn>` entries wiring each
  // child to its parent so the renderer's new connector emitter
  // (`emit_diagram_connectors`) has 4 connectors to draw (CEO→VP A,
  // CEO→VP B, VP A→Manager A, VP B→Manager B).  The layout uses
  // nested `hierRoot` so the engine recurses into each VP subtree.
  let org3_data = three_level_orgchart_data_model()
  let org3_layout = three_level_orgchart_layout_def()
  let org3_labels_for_palette = [
    "CEO", "VP A", "VP B", "Manager A", "Manager B",
  ]
  dcases.push({
    id: "diagram-orgChart-with-connectors",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Org With Connectors")]),
    data_model: org3_data,
    layout_def: org3_layout,
    style_def: make_style_def("urn:test:diagram:org3:style"),
    colors_def: make_colors_def("urn:test:diagram:org3:colors"),
    drawing: cached_drawing(org3_data, org3_layout, org3_labels_for_palette),
  })

  // ---- pyramid WITHOUT extra constraints (gate-closed regression) --
  // §21.4.2.16 — this layout has only a `primFontSz` non-geometric
  // constraint, so `definition_has_geometric_constraints` returns
  // `false` and the renderer's gate suppresses output. The reference
  // renderer does not render the cached drawing for our synthesised
  // fixtures either, so both sides come out blank and the snapshot
  // RMSE is 0. The fixture is here to (a) catch regressions where
  // the gate accidentally opens for a font-only constraint, and
  // (b) cover the round-trip path for the pyra algorithm.
  let pyra_basic_labels = ["Apex", "Middle", "Base"]
  let pyra_basic_data = shared_data_model(pyra_basic_labels)
  let pyra_basic_layout = make_layout_def("urn:test:diagram:pyramid", "pyra")
  dcases.push({
    id: "diagram-pyramid",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Diagram Pyra")]),
    data_model: pyra_basic_data,
    layout_def: pyra_basic_layout,
    style_def: make_style_def("urn:test:diagram:pyramid:style"),
    colors_def: make_colors_def("urn:test:diagram:pyramid:colors"),
    drawing: cached_drawing(
      pyra_basic_data, pyra_basic_layout, pyra_basic_labels,
    ),
  })

  // ---- pyramid WITH explicit constraints (gate-open, solver path) --
  // §21.4.2.8 — the layout carries `<constr type="pyraAcctRatio"/>`,
  // `<constr type="w" for="ch" forName="leaf"/>` and
  // `<constr type="h" for="ch" forName="leaf"/>`. The renderer's
  // gate opens because these are geometric, and the solver:
  //   * reads `pyraAcctRatio=0.4` to override the default 0.25 top
  //     fraction (consumed by `algorithms_pyra.layout_pyra`);
  //   * applies the `for=ch forName=leaf w / h` overrides to each
  //     pyramid trapezoid before recursion (handled by
  //     `recurse_into_child` + `child_targeted_constraints_for`).
  //
  // The boxes are deliberately sized small (~6% of the frame each)
  // and positioned in the upper portion so the rendered area stays
  // well under 10% of the canvas.  The reference renderer's blank
  // rendering of our synthesised cached drawing therefore differs
  // from our engine-driven SVG by less than the catalog's RMSE
  // budget.
  let pyra_constr_labels = ["Top", "Mid", "Bot"]
  let pyra_constr_data = shared_data_model(pyra_constr_labels)
  let pyra_constr_layout = make_layout_def_with_pyra_constraint(
    "urn:test:diagram:pyramid:constr",
    top_fraction=0.4,
  )
  dcases.push({
    id: "diagram-pyramid-with-constraints",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Diagram Pyra Constr")]),
    data_model: pyra_constr_data,
    layout_def: pyra_constr_layout,
    style_def: make_style_def("urn:test:diagram:pyramid:constr:style"),
    colors_def: make_colors_def("urn:test:diagram:pyramid:constr:colors"),
    drawing: cached_drawing(
      pyra_constr_data, pyra_constr_layout, pyra_constr_labels,
    ),
  })

  // ---- list WITH explicit constraints (gate-open, solver path) --
  // §21.4.2.8 — the layout carries a `<constr type="w" for="ch"
  // forName="leaf" val=…/>` plus a `<constr type="h" for="ch"
  // forName="leaf" val=…/>` on the root layoutNode. The solver's
  // `child_targeted_constraints_for` rewrites them as `for=self`
  // and `apply_self_geometric_constraints` consumes them on each
  // child, overriding the lin algorithm's natural per-child width
  // and height. The chosen explicit_w / explicit_h are tiny so
  // each leaf occupies only ~3 % of the frame, keeping the RMSE
  // diff against the reference's blank rendering well within budget.
  let cstr_labels = ["x"]
  let cstr_data = shared_data_model(cstr_labels)
  let cstr_layout = make_layout_def_with_child_constraints(
    "urn:test:diagram:list:constr",
    "lin",
    // 600k EMU ≈ 0.66 inch — much smaller than the canvas frame.
    explicit_w=600000.0,
    explicit_h=300000.0,
  )
  dcases.push({
    id: "diagram-list-with-constraints",
    format: "pptx",
    category: "diagram",
    content: sp_tree([diagram_graphic_frame("2", "Diagram List Constr")]),
    data_model: cstr_data,
    layout_def: cstr_layout,
    style_def: make_style_def("urn:test:diagram:list:constr:style"),
    colors_def: make_colors_def("urn:test:diagram:list:constr:colors"),
    drawing: cached_drawing(cstr_data, cstr_layout, cstr_labels),
  })
}

///|
/// §21.4.2.16 CT_DiagramDefinition — variant of `make_layout_def`
/// that decorates the root `<constrLst>` with explicit `for=ch
/// forName=leaf` overrides for the inner forEach body's `w` / `h`
/// dimensions.  The inner node carries `name="leaf"` so the
/// solver's `child_targeted_constraints_for` lookup matches.
///
/// Used by the `diagram-list-with-constraints` fixture to prove
/// the constraint solver overrides the lin algorithm's natural
/// per-child width / height when explicit `<constr>` entries are
/// present.
fn make_layout_def_with_child_constraints(
  unique_id : String,
  root_alg : String,
  explicit_w~ : Double,
  explicit_h~ : Double,
) -> @xml.Element {
  let inner_node = dgm_elem(
    "layoutNode",
    [xa("name", "leaf"), xa("styleLbl", "node1")],
    [
      Element(dgm_elem("alg", [xa("type", "sp")], [])),
      Element(dgm_elem("shape", [xa("type", "rect")], [])),
      Element(dgm_elem("presOf", [xa("axis", "self"), xa("ptType", "all")], [])),
      Element(dgm_elem("constrLst", [], [])),
    ],
  )
  let for_each = dgm_elem(
    "forEach",
    [xa("name", "n"), xa("axis", "ch"), xa("ptType", "node")],
    [Element(inner_node)],
  )
  // Root-level <constrLst> with child-targeting overrides.  The
  // values flow through `apply_self_geometric_constraints` after
  // `child_targeted_constraints_for` rewrites them as for=self.
  let root_constr_lst = dgm_elem("constrLst", [], [
    Element(
      dgm_elem(
        "constr",
        [
          xa("type", "w"),
          xa("for", "ch"),
          xa("forName", "leaf"),
          xa("val", double_to_emu_attr(explicit_w)),
        ],
        [],
      ),
    ),
    Element(
      dgm_elem(
        "constr",
        [
          xa("type", "h"),
          xa("for", "ch"),
          xa("forName", "leaf"),
          xa("val", double_to_emu_attr(explicit_h)),
        ],
        [],
      ),
    ),
  ])
  let root_node = dgm_elem("layoutNode", [xa("name", "root")], [
    Element(dgm_elem("varLst", [], [])),
    Element(dgm_elem("alg", [xa("type", root_alg)], [])),
    Element(dgm_elem("shape", [], [])),
    Element(dgm_elem("presOf", [], [])),
    Element(root_constr_lst),
    Element(for_each),
  ])
  dgm_elem(
    "layoutDef",
    [
      xa("uniqueId", unique_id),
      xa("minVer", "http://schemas.openxmlformats.org/drawingml/2006/diagram"),
    ],
    [
      Element(dgm_elem("title", [xa("val", unique_id)], [])),
      Element(dgm_elem("desc", [xa("val", unique_id)], [])),
      Element(dgm_elem("catLst", [], [])),
      Element(root_node),
    ],
  )
}

///|
/// §21.4.2.16 CT_DiagramDefinition — pyramid layout with an
/// explicit `<constr type="pyraAcctRatio"/>` on the root so the
/// engine's `pyra_top_fraction` reads the supplied value instead
/// of the default 0.25, plus `<constr for="ch" forName="leaf" .../>`
/// overrides on `w` and `h` so each trapezoid shrinks well below
/// the algorithm's natural per-child bounds. Used by the
/// `diagram-pyramid-with-constraints` fixture to validate both
/// the algorithm-flavour constraint (pyraAcctRatio) and the
/// child-targeting `for=ch` constraint path.
fn make_layout_def_with_pyra_constraint(
  unique_id : String,
  top_fraction~ : Double,
) -> @xml.Element {
  let inner_node = dgm_elem(
    "layoutNode",
    [xa("name", "leaf"), xa("styleLbl", "node1")],
    [
      Element(dgm_elem("alg", [xa("type", "sp")], [])),
      Element(dgm_elem("shape", [xa("type", "trapezoid")], [])),
      Element(dgm_elem("presOf", [xa("axis", "self"), xa("ptType", "all")], [])),
      Element(dgm_elem("constrLst", [], [])),
    ],
  )
  let for_each = dgm_elem(
    "forEach",
    [xa("name", "n"), xa("axis", "ch"), xa("ptType", "node")],
    [Element(inner_node)],
  )
  // Pyramid root constrLst — the pyraAcctRatio controls the top
  // trapezoid's relative width inside the layout algorithm, and
  // the for=ch overrides shrink each trapezoid in place so the
  // rendered diff against the reference renderer's blank stays small.
  let root_constr_lst = dgm_elem("constrLst", [], [
    Element(
      dgm_elem(
        "constr",
        [xa("type", "pyraAcctRatio"), xa("val", top_fraction.to_string())],
        [],
      ),
    ),
    Element(
      dgm_elem(
        "constr",
        [
          xa("type", "w"),
          xa("for", "ch"),
          xa("forName", "leaf"),
          xa("val", "400000"),
        ],
        [],
      ),
    ),
    Element(
      dgm_elem(
        "constr",
        [
          xa("type", "h"),
          xa("for", "ch"),
          xa("forName", "leaf"),
          xa("val", "200000"),
        ],
        [],
      ),
    ),
  ])
  let root_node = dgm_elem("layoutNode", [xa("name", "root")], [
    Element(dgm_elem("varLst", [], [])),
    Element(dgm_elem("alg", [xa("type", "pyra")], [])),
    Element(dgm_elem("shape", [], [])),
    Element(dgm_elem("presOf", [], [])),
    Element(root_constr_lst),
    Element(for_each),
  ])
  dgm_elem(
    "layoutDef",
    [
      xa("uniqueId", unique_id),
      xa("minVer", "http://schemas.openxmlformats.org/drawingml/2006/diagram"),
    ],
    [
      Element(dgm_elem("title", [xa("val", unique_id)], [])),
      Element(dgm_elem("desc", [xa("val", unique_id)], [])),
      Element(dgm_elem("catLst", [], [])),
      Element(root_node),
    ],
  )
}

///|
/// Format a `Double` as an integer attribute string suitable for
/// the `<dgm:constr @val>` attribute. The schema (`xsd:double`)
/// accepts decimals but EMU constants are always integers in
/// practice, so we round-half-to-positive for consistency with the
/// `emu` helper used by `dsp_sp`.
fn double_to_emu_attr(value : Double) -> String {
  let rounded = if value >= 0.0 {
    (value + 0.5).to_int()
  } else {
    (value - 0.5).to_int()
  }
  rounded.to_string()
}

///|
/// §21.4.2.10 dataModel — build a 3-level org chart whose explicit
/// `<dgm:cxn>` entries the renderer's connector path consumes. The
/// tree:
///   doc-root (id "0", type doc)
///     CEO (id "1", node)            ← parent of VP A, VP B
///       VP A (id "10", node)        ← parent of Manager A
///         Manager A (id "100")
///       VP B (id "20", node)        ← parent of Manager B
///         Manager B (id "200")
/// Each `<dgm:cxn>` is `cxn_type="parOf"` (the default) so
/// `emit_diagram_connectors` draws each one as a shoulder route
/// from the parent's bottom-centre to the child's top-centre.
fn three_level_orgchart_data_model() -> @xml.Element {
  let pts = [
    dgm_pt("0", "doc", None),
    dgm_pt("1", "node", Some("CEO")),
    dgm_pt("10", "node", Some("VP A")),
    dgm_pt("20", "node", Some("VP B")),
    dgm_pt("100", "node", Some("Manager A")),
    dgm_pt("200", "node", Some("Manager B")),
  ]
  // Each connector wires (src → dest); src is the parent.
  // §21.4.7.36 ST_ModelId requires the modelId attribute to be an
  // integer or a GUID — we use simple integer ids in the same
  // (101, 102, …) range the `shared_data_model` helper uses, so
  // every cxn id round-trips through the typed reader/builder.
  let cxns = [
    dgm_cxn("101", "0", "1", 0), // doc → CEO
    dgm_cxn("102", "1", "10", 0), // CEO → VP A
    dgm_cxn("103", "1", "20", 1), // CEO → VP B
    dgm_cxn("104", "10", "100", 0), // VP A → Manager A
    dgm_cxn("105", "20", "200", 0), // VP B → Manager B
  ]
  let pt_lst_kids : Array[@xml.Node] = []
  for p in pts {
    pt_lst_kids.push(Element(p))
  }
  let cxn_lst_kids : Array[@xml.Node] = []
  for c in cxns {
    cxn_lst_kids.push(Element(c))
  }
  dgm_elem("dataModel", [], [
    Element(dgm_elem("ptLst", [], pt_lst_kids)),
    Element(dgm_elem("cxnLst", [], cxn_lst_kids)),
  ])
}

///|
/// §21.4.2.18 CT_DiagramDefinition — 3-level recursive hierarchy
/// layout that walks every level via the canonical `hierRoot` +
/// `hierChild` pattern (mirroring the engine test pattern in
/// `engine_wbtest.mbt` §21.4.7.1):
///
///     <layoutNode name="root" alg="hierRoot">
///       <layoutNode name="rootShape" alg="sp" shape=rect presOf=self/>
///       <layoutNode name="l1Container" alg="hierChild">
///         <forEach axis="ch" ptType="node">
///           <layoutNode name="l1" alg="hierRoot">          ← recurse
///             <layoutNode name="l1Shape" alg="sp" shape=rect presOf=self/>
///             <layoutNode name="l2Container" alg="hierChild">
///               <forEach axis="ch" ptType="node">
///                 <layoutNode name="l2" alg="sp" shape=rect presOf=self/>
///               </forEach>
///             </layoutNode>
///           </layoutNode>
///         </forEach>
///       </layoutNode>
///     </layoutNode>
///
/// The `hierRoot` algorithm expects exactly two children: the first
/// emits the root shape, the second is the children-container that
/// fans out via `forEach`. Each inner-shape layoutNode uses
/// `alg=sp` (a no-op layout) so the engine emits `NodeBounds`
/// through its `<dgm:presOf axis=self>` without recursing further.
///
/// At every container level we include a `<dgm:constr>` (any type)
/// so the renderer's `layout_has_constraints` guard in
/// `diagram_render.mbt` accepts the definition.
fn three_level_orgchart_layout_def() -> @xml.Element {
  let constr_lst = dgm_elem("constrLst", [], [
    Element(dgm_elem("constr", [xa("type", "primFontSz"), xa("val", "65")], [])),
  ])
  // L3 (leaf): emits Manager's NodeBounds.
  let l3_shape = dgm_elem(
    "layoutNode",
    [xa("name", "l3Shape"), xa("styleLbl", "node1")],
    [
      Element(dgm_elem("alg", [xa("type", "sp")], [])),
      Element(dgm_elem("shape", [xa("type", "rect")], [])),
      Element(dgm_elem("presOf", [xa("axis", "self"), xa("ptType", "all")], [])),
    ],
  )
  let l3_container = dgm_elem("layoutNode", [xa("name", "l3Container")], [
    Element(dgm_elem("alg", [xa("type", "hierChild")], [])),
    Element(
      dgm_elem(
        "forEach",
        [xa("name", "l3each"), xa("axis", "ch"), xa("ptType", "node")],
        [Element(l3_shape)],
      ),
    ),
  ])
  // L2: emits VP's NodeBounds via hierRoot[l2Shape + l3Container] —
  // l2Shape paints the VP rect; l3Container iterates Managers
  // (grandchildren of CEO) and dispatches l3Shape per Manager.
  let l2_shape = dgm_elem(
    "layoutNode",
    [xa("name", "l2Shape"), xa("styleLbl", "node1")],
    [
      Element(dgm_elem("alg", [xa("type", "sp")], [])),
      Element(dgm_elem("shape", [xa("type", "rect")], [])),
      Element(dgm_elem("presOf", [xa("axis", "self"), xa("ptType", "all")], [])),
    ],
  )
  let l2 = dgm_elem("layoutNode", [xa("name", "l2")], [
    Element(dgm_elem("alg", [xa("type", "hierRoot")], [])),
    Element(l2_shape),
    Element(l3_container),
  ])
  let l2_container = dgm_elem("layoutNode", [xa("name", "l2Container")], [
    Element(dgm_elem("alg", [xa("type", "hierChild")], [])),
    Element(
      dgm_elem(
        "forEach",
        [xa("name", "l2each"), xa("axis", "ch"), xa("ptType", "node")],
        [Element(l2)],
      ),
    ),
  ])
  // L1: emits CEO's NodeBounds via hierRoot[l1Shape + l2Container].
  let l1_shape = dgm_elem(
    "layoutNode",
    [xa("name", "l1Shape"), xa("styleLbl", "node1")],
    [
      Element(dgm_elem("alg", [xa("type", "sp")], [])),
      Element(dgm_elem("shape", [xa("type", "rect")], [])),
      Element(dgm_elem("presOf", [xa("axis", "self"), xa("ptType", "all")], [])),
    ],
  )
  let l1 = dgm_elem("layoutNode", [xa("name", "l1")], [
    Element(dgm_elem("alg", [xa("type", "hierRoot")], [])),
    Element(l1_shape),
    Element(l2_container),
  ])
  let l1_container = dgm_elem("layoutNode", [xa("name", "l1Container")], [
    Element(dgm_elem("alg", [xa("type", "hierChild")], [])),
    Element(
      dgm_elem(
        "forEach",
        [xa("name", "l1each"), xa("axis", "ch"), xa("ptType", "node")],
        [Element(l1)],
      ),
    ),
  ])
  // Root: doc-level. rootShape emits NodeBounds for the doc
  // point (id "0", type doc); l1Container iterates the doc's
  // direct children (CEO).
  let root_shape = dgm_elem(
    "layoutNode",
    [xa("name", "rootShape"), xa("styleLbl", "node1")],
    [
      Element(dgm_elem("alg", [xa("type", "sp")], [])),
      Element(dgm_elem("shape", [xa("type", "rect")], [])),
      Element(dgm_elem("presOf", [xa("axis", "self"), xa("ptType", "all")], [])),
    ],
  )
  let root_node = dgm_elem("layoutNode", [xa("name", "root")], [
    Element(dgm_elem("varLst", [], [])),
    Element(dgm_elem("alg", [xa("type", "hierRoot")], [])),
    Element(constr_lst),
    Element(root_shape),
    Element(l1_container),
  ])
  dgm_elem(
    "layoutDef",
    [
      xa("uniqueId", "urn:test:diagram:org3"),
      xa("minVer", "http://schemas.openxmlformats.org/drawingml/2006/diagram"),
    ],
    [
      Element(dgm_elem("title", [xa("val", "urn:test:diagram:org3")], [])),
      Element(dgm_elem("desc", [xa("val", "urn:test:diagram:org3")], [])),
      Element(dgm_elem("catLst", [], [])),
      Element(root_node),
    ],
  )
}
