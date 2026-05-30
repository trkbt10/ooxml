// PresentationML viewer / DrawingML SmartArt bridge.
//
// Part 1 §21.4 — a `<p:graphicFrame>` whose `<a:graphicData>` URI
// is the DrawingML diagram namespace carries a `<dgm:relIds>`
// child whose four `r:dm` / `r:lo` / `r:qs` / `r:cs` attributes
// reference the slide rels' four SmartArt parts: data1.xml,
// layout1.xml, quickStyle1.xml, colors1.xml (§21.4.2.22
// CT_RelIds, §15.2.7 relationship-type URIs).
//
// This module bridges the four resolved parts into the
// `@diagram_layout` engine, which produces one `NodeBounds` per
// rendered data point, then emits a `<g class="diagram">` SVG
// subtree containing one `<rect>` (or `<ellipse>` / `<polygon>`
// per the layout-node's `<dgm:shape>`) plus a centred `<text>`
// label per `NodeBounds`. Colours are drawn from
// `<dgm:fillClrLst>` on the colorsDef so the per-node accent cycles
// through the theme's colour transform; `<a:schemeClr>` entries are
// resolved against the presentation theme carried in the
// `ColorResolveContext` (Office-palette fallback when no theme part
// loaded), so the diagram's accents match the surrounding deck.
//
// The renderer is intentionally minimal: it honours the engine's
// computed `(x, y, width, height)` per data point and emits the
// data-model text body. `<dgm:cxn>` connector lines are rendered
// for hierarchical (`hierRoot`/`hierChild`) and cycle layouts —
// hierarchical connectors run from the parent's bottom-centre to
// the child's top-centre, while cycle connectors run straight
// between centres. Each node picks its fill from the colorsDef
// `<dgm:styleLbl>` whose name matches the node's layout-assigned style
// label (`NodeBounds.style_lbl`); nodes sharing a label cycle that
// label's fill list, and a node with no label (or no matching styleLbl)
// falls back to the first label's list. Label TEXT colour comes from
// the same style label's `<dgm:txFillClrLst>` (black when absent), and
// a `<dgm:bg>` solid background fill (§21.4.2.10) renders behind the
// whole diagram.

///|
/// DrawingML diagram namespace (§21.4) — the URI the
/// `<a:graphicData>` carries when the payload is SmartArt.
let diagram_uri : String = "http://schemas.openxmlformats.org/drawingml/2006/diagram"

///|
/// Officedoc relationships namespace (§15.2.1) — the `r:` prefix
/// used by `<dgm:relIds>` for the four part references.
let diagram_rel_ns : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

///|
/// True when `frame`'s `<a:graphic>/<a:graphicData @uri>` selects
/// the §21.4 DrawingML diagram (SmartArt) sub-grammar.
fn is_diagram_graphic_frame(frame : @xml.Element) -> Bool {
  match first_child_named(frame, "graphic") {
    None => false
    Some(g) =>
      match first_child_named(g, "graphicData") {
        None => false
        Some(gd) =>
          match attr_value(gd, "uri") {
            Some(uri) => uri == diagram_uri
            None => false
          }
      }
  }
}

///|
/// Extract the four §21.4.2.22 CT_RelIds attribute values from a
/// graphicFrame's `<a:graphicData>/<dgm:relIds>` child.  Each
/// attribute uses the `r:` officedoc-relationships namespace; we
/// match on local name + namespace URI so a renamed prefix still
/// resolves.  Returns `None` when any of the four required
/// attributes is missing (the schema makes all four mandatory).
fn extract_diagram_rel_ids(
  frame : @xml.Element,
) -> (String, String, String, String)? {
  let graphic = match first_child_named(frame, "graphic") {
    Some(g) => g
    None => return None
  }
  let graphic_data = match first_child_named(graphic, "graphicData") {
    Some(gd) => gd
    None => return None
  }
  let rel_ids = match first_child_named(graphic_data, "relIds") {
    Some(r) => r
    None => return None
  }
  let dm = match rel_ids_attr(rel_ids, "dm") {
    Some(v) => v
    None => return None
  }
  let lo = match rel_ids_attr(rel_ids, "lo") {
    Some(v) => v
    None => return None
  }
  let qs = match rel_ids_attr(rel_ids, "qs") {
    Some(v) => v
    None => return None
  }
  let cs = match rel_ids_attr(rel_ids, "cs") {
    Some(v) => v
    None => return None
  }
  Some((dm, lo, qs, cs))
}

///|
/// Look up a `<dgm:relIds>` attribute by its local name in the
/// officedoc relationships namespace.  The namespace check guards
/// against an unrelated attribute with the same local name.
fn rel_ids_attr(rel_ids : @xml.Element, local_name : String) -> String? {
  for a in rel_ids.attributes {
    if a.name.local_name == local_name {
      match a.name.ns {
        Some(uri) => if uri == diagram_rel_ns { return Some(a.value) }
        None =>
          // Unprefixed attributes carry no namespace per the XML
          // namespaces spec; we accept them so a fixture that
          // declares the `r:` prefix differently still resolves.
          return Some(a.value)
      }
    }
  }
  None
}

///|
/// Render a §21.4 SmartArt diagram into the frame's
/// `(frame_x, frame_y, frame_w, frame_h)` bounding box (EMU).
///
/// `part_resolver(rid)` resolves an rId on the slide's rels table
/// into the part's root XML element.  Returns an empty node list
/// when any of the four parts cannot be resolved or decoded — the
/// graphicFrame caller then falls back to its placeholder
/// rendering so the slide still emits something useful.
fn render_diagram_svg(
  frame : @xml.Element,
  frame_w : Double,
  frame_h : Double,
  part_resolver : (String) -> @xml.Element?,
  ctx : ColorResolveContext,
) -> Array[@xml.Node] {
  let (dm_rid, lo_rid, qs_rid, cs_rid) = match extract_diagram_rel_ids(frame) {
    Some(t) => t
    None => return []
  }
  let data_model_root = match part_resolver(dm_rid) {
    Some(e) => e
    None => return []
  }
  let layout_def_root = match part_resolver(lo_rid) {
    Some(e) => e
    None => return []
  }
  // colorsDef is optional from the engine's perspective — we use
  // it only to pick the per-node accent colour.  The quickStyle
  // part (styleDef) is resolved for the marker counter only; the
  // engine itself does not consume it.
  let colors_def_root = part_resolver(cs_rid)
  let style_def_root = part_resolver(qs_rid)

  // Decode the data model and layout definition via the typed
  // CT_* projections in `@dgm` and the engine helpers in
  // `@diagram_layout`. Decoding failures land in the empty branch
  // so the placeholder remains the renderer's safety net.
  // (Removed: previous revision built a raw-XML marker stripe of
  // dummy `<rect fill="#a5a5a5">` elements counted off
  // descendant names so the catalog verifier ticked even when
  // typed decoding failed.  No basis in ECMA-376 — verifier
  // gaming, not §21.4 rendering.  Restored honest behaviour:
  // a typed-decode failure now returns an empty node list and
  // the graphicFrame caller falls back to its labelled
  // placeholder.)
  let data_model_typed = try @dgm.CT_DataModel::new(data_model_root) catch {
    _ => return []
  } noraise {
    t => t
  }
  let definition_typed = try @dgm.CT_DiagramDefinition::new(layout_def_root) catch {
    _ => return []
  } noraise {
    t => t
  }
  let data_model = try @diagram_layout.decode_data_model(data_model_typed) catch {
    _ => return []
  } noraise {
    t => t
  }
  let definition = try @diagram_layout.decode_diagram_definition(definition_typed) catch {
    _ => return []
  } noraise {
    t => t
  }

  // §21.4.2.16 CT_DiagramDefinition — real-world SmartArt layouts
  // carry geometric `<dgm:constr>` elements (`w`, `h`, `l`, `t`,
  // `sp`, `lMarg`, …) that drive the engine's sizing / positioning.
  // A layoutDef carrying only *non-geometric* constraints —
  // typically `primFontSz` for text fitting — has no spatial intent:
  // PowerPoint both surface such layouts as blank
  // graphicFrames (the reference renderer emits no shapes; PowerPoint shows
  // "Cannot display SmartArt"). To stay aligned with the snapshot
  // harness's reference renderer (the reference renderer), we follow suit and
  // emit nothing when the decoded definition carries zero geometric
  // constraints. The predicate
  // `definition_has_geometric_constraints` lives in
  // `diagram_layout/constraint_solver.mbt` and inspects the typed
  // `LayoutNode` tree so it sees the same normalisation as the
  // engine — `primFontSz` is non-geometric and gates rendering
  // off; any `w`/`h`/`l`/`t`/`sp`/`*Marg` constraint gates it on.
  // §21.4.2.16 — when the layoutDef carries no geometric
  // constraints, the engine cannot lay out shapes.  PowerPoint
  // surfaces "Cannot display SmartArt" here; we return an empty
  // node list so the graphicFrame caller falls back to its
  // labelled placeholder rendering.
  //
  // (A previous revision emitted a horizontal strip of one
  // `<rect>` per `<dgm:pt>` here — labelled
  // `data-ooxml="diagram-fallback-pt"` — with the explicit
  // comment "This is NOT how Office renders such layouts; it's a
  // measurement-quality shim".  That shim existed only to make
  // the catalog harness's per-element differential check tick;
  // it has no basis in ECMA-376 §21.4.2 and has been removed.)
  if !@diagram_layout.definition_has_geometric_constraints(definition) {
    return []
  }

  // Run the engine against the frame's bounding box (in EMU). The
  // engine emits one `NodeBounds` per data point reached by the
  // layout walk; we then convert each to an SVG shape + text label.
  let engine = @diagram_layout.DiagramLayoutEngine::new()
  let bounds_rect : @diagram_layout.BoundsRect = {
    x: 0.0,
    y: 0.0,
    width: frame_w,
    height: frame_h,
  }
  let node_bounds = engine.apply(definition, data_model, bounds_rect)

  // Build a text lookup so each NodeBounds can pull the original
  // <dgm:pt><t><a:p><a:r><a:t> body. The engine returns
  // point_ids verbatim, so a linear scan of the data model is
  // adequate (data models are small).
  // §21.4.2.10 `<dgm:bg>` — a whole-diagram background fill renders
  // first, behind the connectors and node shapes.
  let bg_node = emit_diagram_background(data_model_root, frame_w, frame_h, ctx)
  let palette = colors_palette(colors_def_root, ctx)
  // §21.4.4.10 — per-style-label fill lists, so each node uses the
  // colour list of the style label its layout node carries.  Nodes
  // sharing a label cycle that label's list independently.
  let label_palettes = colors_by_style_label(colors_def_root, ctx)
  let label_counts : Map[String, Int] = Map([], capacity=0)
  // §21.4.4 `<dgm:txFillClrLst>` — per-style-label TEXT colour lists,
  // so each node's label uses the style label's text colour.
  let text_palettes = colors_by_style_label(
    colors_def_root, ctx, list_name="txFillClrLst",
  )
  let text_counts : Map[String, Int] = Map([], capacity=0)
  let svg_nodes : Array[@xml.Node] = []
  match bg_node {
    Some(n) => svg_nodes.push(n)
    None => ()
  }
  // §21.4.2.7 cxnLst — connector lines first, so node bodies render
  // on top and the connector endpoints disappear under the shapes.
  // Hierarchical algorithms (hierRoot/hierChild) draw vertical
  // shoulder lines; cycle draws straight chords. Other algorithms
  // skip the connectors entirely (a linear list shows order through
  // stacking, not lines).
  let connector_nodes = emit_diagram_connectors(
    data_model,
    node_bounds,
    definition.root.algorithm,
  )
  for n in connector_nodes {
    svg_nodes.push(n)
  }
  let mut palette_index = 0
  for nb in node_bounds {
    let text = lookup_point_text(data_model, nb.point_id)
    // §21.4.4.10 — prefer the node's own style-label colour list; fall
    // back to the default cycle when the node carries no label or the
    // colorsDef has no matching styleLbl.
    let fill = match nb.style_lbl {
      Some(lbl) =>
        match label_palettes.get(lbl) {
          Some(colors) if colors.length() > 0 => {
            let i = label_counts.get(lbl).unwrap_or(0)
            label_counts[lbl] = i + 1
            colors[i % colors.length()]
          }
          _ => palette_pick(palette, palette_index)
        }
      None => palette_pick(palette, palette_index)
    }
    palette_index = palette_index + 1
    let shape_nodes = emit_node_shape(nb, fill)
    for n in shape_nodes {
      svg_nodes.push(n)
    }
    match text {
      Some(label) =>
        if label.length() > 0 {
          // §21.4.4 — text colour from the node's style label's
          // txFillClrLst, defaulting to black when absent.
          let text_color = match nb.style_lbl {
            Some(lbl) =>
              match text_palettes.get(lbl) {
                Some(colors) if colors.length() > 0 => {
                  let i = text_counts.get(lbl).unwrap_or(0)
                  text_counts[lbl] = i + 1
                  colors[i % colors.length()]
                }
                _ => "#000000"
              }
            None => "#000000"
          }
          svg_nodes.push(emit_node_label(nb, label, text_color~))
        }
      None => ()
    }
  }
  // (Removed: previous revision emitted a horizontal strip of
  // one `<rect>` + one `<line>` connector per `<dgm:pt>` /
  // `<dgm:cxn>` here labelled `diagram-fallback-pt` /
  // `diagram-fallback-cxn` with the explicit comment "This is
  // NOT how Office lays out the diagram — it's a measurement
  // shim".  Verifier-gaming, removed.  An engine layout that
  // emits zero node_bounds now yields an empty node list and
  // the graphicFrame caller falls back to its labelled
  // placeholder.)
  if svg_nodes.length() == 0 {
    return []
  }
  [
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [@markup.attr("data-ooxml", "diagram")],
      svg_nodes,
    ),
  ]
}

///|
/// §21.4.2.7 cxn / §21.4.2.8 cxnLst — emit connector geometry between
/// each parent/child pair the data model declares. We honour only
/// `parOf` connectors (the spec default and the only kind that
/// implies a visible relationship); presentation-only links
/// (`presOf`, `presParOf`, `unknownRelationship`) carry no
/// renderable geometry.
///
/// Style per algorithm family:
///   * §21.4.7.1 hierRoot / hierChild — vertical shoulder routing:
///     parent's bottom-centre → midway down → horizontally to the
///     child's column → child's top-centre. Mirrors PowerPoint /
///     the reference renderer's default org-chart connector style.
///   * §21.4.7.1 cycle — straight chord from centre to centre.
///   * §21.4.7.1 lin / snake / pyra — no connectors (linear stacking
///     already conveys order); we drop the connections silently so
///     the renderer's output matches the reference renderer's for these
///     families.
fn emit_diagram_connectors(
  data_model : @diagram_layout.DataModel,
  node_bounds : Array[@diagram_layout.NodeBounds],
  alg : @diagram_layout.Algorithm?,
) -> Array[@xml.Node] {
  let alg_kind = match alg {
    Some(a) => a.kind
    None => @diagram_layout.AlgComposite
  }
  // Per-point bounds lookup. The engine emits at most one
  // NodeBounds per point id, so a simple Map is sufficient.
  let bounds_by_id : Map[String, @diagram_layout.BoundsRect] = {}
  for nb in node_bounds {
    bounds_by_id[nb.point_id] = nb.bounds
  }
  let out : Array[@xml.Node] = []
  for cxn in data_model.connections {
    if cxn.cxn_type != "parOf" {
      continue
    }
    let src_bounds = match bounds_by_id.get(cxn.src_id) {
      Some(b) => b
      None => continue
    }
    let dst_bounds = match bounds_by_id.get(cxn.dest_id) {
      Some(b) => b
      None => continue
    }
    match alg_kind {
      @diagram_layout.AlgHierRoot | @diagram_layout.AlgHierChild =>
        out.push(connector_shoulder_path(src_bounds, dst_bounds))
      @diagram_layout.AlgCycle =>
        out.push(connector_straight_line(src_bounds, dst_bounds))
      _ => ()
    }
  }
  out
}

///|
/// Shoulder (3-segment) connector for hierarchical layouts. Routes
/// from the parent's bottom-centre down to the midway-y line, across
/// to the child's column, and down to the child's top-centre.
/// The two intermediate segments are right angles so the result
/// matches PowerPoint's default org-chart wiring.
fn connector_shoulder_path(
  parent : @diagram_layout.BoundsRect,
  child : @diagram_layout.BoundsRect,
) -> @xml.Node {
  let px = parent.x + parent.width / 2.0
  let py = parent.y + parent.height
  let cx = child.x + child.width / 2.0
  let cy = child.y
  // Midpoint Y between parent bottom and child top — the
  // horizontal segment lives at this line.
  let mid_y = (py + cy) / 2.0
  let d = "M " +
    format_double(px) +
    "," +
    format_double(py) +
    " L " +
    format_double(px) +
    "," +
    format_double(mid_y) +
    " L " +
    format_double(cx) +
    "," +
    format_double(mid_y) +
    " L " +
    format_double(cx) +
    "," +
    format_double(cy)
  @markup.elem_ns(
    "path",
    @markup.svg_ns,
    [
      @markup.attr("d", d),
      @markup.attr("fill", "none"),
      @markup.attr("stroke", "#595959"),
      @markup.attr(
        "stroke-width",
        format_double(diagram_connector_stroke(parent)),
      ),
      @markup.attr("stroke-linejoin", "round"),
      @markup.attr("stroke-linecap", "round"),
    ],
    [],
  )
}

///|
/// Straight-chord connector for cycle layouts. Anchors at the
/// centres of the two node bounds; the line passes behind the node
/// bodies because connectors are emitted before shapes in
/// `render_diagram_svg`.
fn connector_straight_line(
  src : @diagram_layout.BoundsRect,
  dst : @diagram_layout.BoundsRect,
) -> @xml.Node {
  let x1 = src.x + src.width / 2.0
  let y1 = src.y + src.height / 2.0
  let x2 = dst.x + dst.width / 2.0
  let y2 = dst.y + dst.height / 2.0
  @markup.elem_ns(
    "line",
    @markup.svg_ns,
    [
      @markup.attr("x1", format_double(x1)),
      @markup.attr("y1", format_double(y1)),
      @markup.attr("x2", format_double(x2)),
      @markup.attr("y2", format_double(y2)),
      @markup.attr("stroke", "#595959"),
      @markup.attr("stroke-width", format_double(diagram_connector_stroke(src))),
      @markup.attr("stroke-linecap", "round"),
    ],
    [],
  )
}

///|
/// Stroke width for diagram connectors — scales with the node size
/// so connectors stay visible at every zoom level. We use 4% of the
/// node's short side, clamped to ≥ 9525 EMU (1 px at 96 DPI) so the
/// line never disappears for very small nodes.
fn diagram_connector_stroke(bounds : @diagram_layout.BoundsRect) -> Double {
  let short = double_min_local(bounds.width, bounds.height)
  let raw = short * 0.04
  if raw < 9525.0 {
    9525.0
  } else {
    raw
  }
}

///|
/// Walk the data model and return the text body of the point with
/// the supplied id (or `None` when the point has no `<t>` child).
fn lookup_point_text(
  data_model : @diagram_layout.DataModel,
  point_id : String,
) -> String? {
  for p in data_model.points {
    if p.id == point_id {
      return p.text
    }
  }
  None
}

///|
/// Emit the SVG shape (or shapes) for one laid-out diagram node.
/// The preset shape is taken from the engine's `NodeBounds.shape`;
/// unknown / unsupported presets fall back to a plain `<rect>` so
/// every diagram point always receives a visible body.
fn emit_node_shape(
  nb : @diagram_layout.NodeBounds,
  fill : String,
) -> Array[@xml.Node] {
  let x = nb.bounds.x
  let y = nb.bounds.y
  let w = nb.bounds.width
  let h = nb.bounds.height
  if w <= 0.0 || h <= 0.0 {
    return []
  }
  let common_attrs : Array[@xml.Attribute] = [
    @markup.attr("fill", fill),
    @markup.attr("stroke", "#333333"),
    @markup.attr("stroke-width", "1"),
  ]
  // §20.1.10.56 ST_ShapeType — render the preset shape that the
  // engine attached to this point. We pick the spec-faithful
  // primitive for the common SmartArt shapes (rect / ellipse /
  // roundRect / triangle) and fall back to `<rect>` otherwise so
  // every point is still visible.
  match nb.shape {
    @preset_geometry.ShapeEllipse => {
      let cx = x + w * 0.5
      let cy = y + h * 0.5
      let rx = w * 0.5
      let ry = h * 0.5
      let attrs : Array[@xml.Attribute] = [
        @markup.attr("cx", format_double(cx)),
        @markup.attr("cy", format_double(cy)),
        @markup.attr("rx", format_double(rx)),
        @markup.attr("ry", format_double(ry)),
      ]
      for a in common_attrs {
        attrs.push(a)
      }
      [@markup.elem_ns("ellipse", @markup.svg_ns, attrs, [])]
    }
    @preset_geometry.ShapeRoundRect => {
      // §20.1.9 — preset roundRect uses an `adj` for the corner
      // radius. The engine does not propagate adjusts, so we use
      // 1/8 of min(width, height) as a reasonable default.
      let r = double_min_local(w, h) * 0.125
      let attrs : Array[@xml.Attribute] = [
        @markup.attr("x", format_double(x)),
        @markup.attr("y", format_double(y)),
        @markup.attr("width", format_double(w)),
        @markup.attr("height", format_double(h)),
        @markup.attr("rx", format_double(r)),
        @markup.attr("ry", format_double(r)),
      ]
      for a in common_attrs {
        attrs.push(a)
      }
      [@markup.elem_ns("rect", @markup.svg_ns, attrs, [])]
    }
    @preset_geometry.ShapeTriangle => {
      // §20.1.9 triangle preset — apex at top centre, base across
      // the bottom of the bounds.
      let pts = format_double(x + w * 0.5) +
        "," +
        format_double(y) +
        " " +
        format_double(x + w) +
        "," +
        format_double(y + h) +
        " " +
        format_double(x) +
        "," +
        format_double(y + h)
      let attrs : Array[@xml.Attribute] = [@markup.attr("points", pts)]
      for a in common_attrs {
        attrs.push(a)
      }
      [@markup.elem_ns("polygon", @markup.svg_ns, attrs, [])]
    }
    _ => {
      // Default: render as a rect for every other preset.
      let attrs : Array[@xml.Attribute] = [
        @markup.attr("x", format_double(x)),
        @markup.attr("y", format_double(y)),
        @markup.attr("width", format_double(w)),
        @markup.attr("height", format_double(h)),
      ]
      for a in common_attrs {
        attrs.push(a)
      }
      [@markup.elem_ns("rect", @markup.svg_ns, attrs, [])]
    }
  }
}

///|
/// Local `min` helper for two doubles — `moonbitlang/core/math`'s
/// generic min is intentionally not imported here to avoid widening
/// the package's import surface for a one-liner.
fn double_min_local(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Emit an SVG `<text>` centred in `nb.bounds` carrying the
/// data-point's label. Font sizing is heuristic: half the bounding
/// box's short side, capped so very tall boxes do not produce
/// overly large text. The text is anchored at the centre so it
/// stays visually centred for boxes of any aspect ratio.
/// §21.4.2.10 dataModel/`<dgm:bg>` (CT_BackgroundFormatting) — emit a
/// background rectangle covering the whole diagram frame when the data
/// model declares a solid background fill.  `noFill` / absent / non-
/// solid fills yield `None` (no background rect).
fn emit_diagram_background(
  data_model_root : @xml.Element,
  frame_w : Double,
  frame_h : Double,
  ctx : ColorResolveContext,
) -> @xml.Node? {
  let bg = match first_child_named(data_model_root, "bg") {
    Some(b) => b
    None => return None
  }
  let sf = match first_child_named(bg, "solidFill") {
    Some(s) => s
    None => return None
  }
  let color = match @paint.resolve_solid_fill(sf, ctx~) {
    Some(rc) => @paint.format_resolved_color(rc)
    None => return None
  }
  Some(
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", "0"),
        @markup.attr("y", "0"),
        @markup.attr("width", format_double(frame_w)),
        @markup.attr("height", format_double(frame_h)),
        @markup.attr("fill", color),
      ],
      [],
    ),
  )
}

///|
fn emit_node_label(
  nb : @diagram_layout.NodeBounds,
  label : String,
  text_color~ : String = "#000000",
) -> @xml.Node {
  let cx = nb.bounds.x + nb.bounds.width * 0.5
  let cy = nb.bounds.y + nb.bounds.height * 0.5
  // Heuristic font size: the smaller of the bounding-box short
  // side / 5 and 180000 EMU (~19 px at 96 DPI). Diagram text is
  // typically much smaller than the box itself in PowerPoint.
  let short_side = double_min_local(nb.bounds.width, nb.bounds.height)
  let raw_size = short_side / 5.0
  let font_size = if raw_size > 180000.0 { 180000.0 } else { raw_size }
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("x", format_double(cx)),
    @markup.attr("y", format_double(cy)),
    @markup.attr("text-anchor", "middle"),
    @markup.attr("dominant-baseline", "central"),
    @markup.attr("font-family", "sans-serif"),
    @markup.attr("font-size", format_double(font_size)),
    @markup.attr("fill", text_color),
  ]
  @markup.elem_ns("text", @markup.svg_ns, attrs, [@markup.text(label)])
}

///|
/// Extract the colour palette for the diagram from the colorsDef
/// part. §21.4.4.7 `<dgm:fillClrLst>` under the canonical
/// `<dgm:styleLbl name="node1">` defines the per-node accent
/// cycle; we pull each `<a:srgbClr>` / `<a:schemeClr>` arm in
/// document order and return their hex strings. When the colorsDef
/// is absent or empty, we fall back to a small built-in palette so
/// the diagram still has visible per-node differentiation.
fn diagram_default_palette() -> Array[String] {
  ["#4472C4", "#ED7D31", "#A5A5A5", "#FFC000", "#5B9BD5", "#70AD47"]
}

///|
/// §21.4.4.7 `<dgm:fillClrLst>` — read a styleLbl's fill colour list,
/// resolving `<a:srgbClr>` literally and `<a:schemeClr>` against the
/// presentation theme in `ctx` (Office-palette fallback).  Returns an
/// empty array when the styleLbl carries no fill list.
fn fill_clr_lst_colors(
  lbl : @xml.Element,
  ctx : ColorResolveContext,
  list_name~ : String = "fillClrLst",
) -> Array[String] {
  let result : Array[String] = []
  let mut fill_lst : @xml.Element? = None
  for child in lbl.children {
    match child {
      Element(e) =>
        if e.name.local_name == list_name {
          fill_lst = Some(e)
          break
        }
      _ => ()
    }
  }
  let lst = match fill_lst {
    Some(e) => e
    None => return result
  }
  for child in lst.children {
    match child {
      Element(e) => {
        let local_name = e.name.local_name
        if local_name == "srgbClr" {
          match attr_value(e, "val") {
            Some(hex) => result.push("#" + hex)
            None => ()
          }
        } else if local_name == "schemeClr" {
          match attr_value(e, "val") {
            Some(name) =>
              match @paint.get_scheme_color(name, None, ctx) {
                Some(hex) => result.push("#" + hex)
                None => result.push(scheme_default_hex(name))
              }
            None => ()
          }
        }
      }
      _ => ()
    }
  }
  result
}

///|
/// §21.4.4.10 — map every `<dgm:styleLbl name="…">` in the colorsDef to
/// its resolved fill colour list, so a node can pick the colour list of
/// the style label its layout node carries (rather than always cycling
/// the first label's list).
fn colors_by_style_label(
  colors_def : @xml.Element?,
  ctx : ColorResolveContext,
  list_name~ : String = "fillClrLst",
) -> Map[String, Array[String]] {
  let map : Map[String, Array[String]] = Map([], capacity=0)
  let cd = match colors_def {
    Some(e) => e
    None => return map
  }
  for child in cd.children {
    match child {
      Element(e) =>
        if e.name.local_name == "styleLbl" {
          match attr_value(e, "name") {
            Some(name) => {
              let colors = fill_clr_lst_colors(e, ctx, list_name~)
              if colors.length() > 0 {
                map[name] = colors
              }
            }
            None => ()
          }
        }
      _ => ()
    }
  }
  map
}

///|
fn colors_palette(
  colors_def : @xml.Element?,
  ctx : ColorResolveContext,
) -> Array[String] {
  let defaults = diagram_default_palette()
  let cd = match colors_def {
    Some(e) => e
    None => return defaults
  }
  // §21.4.4.10 `<dgm:styleLbl>` — the first one (typically
  // `name="node1"`) supplies the default per-node cycle.
  let mut style_lbl : @xml.Element? = None
  for child in cd.children {
    match child {
      Element(e) =>
        if e.name.local_name == "styleLbl" {
          style_lbl = Some(e)
          break
        }
      _ => ()
    }
  }
  match style_lbl {
    None => defaults
    Some(lbl) => {
      let result = fill_clr_lst_colors(lbl, ctx)
      if result.length() == 0 {
        defaults
      } else {
        result
      }
    }
  }
}

///|
/// Resolve a §20.1.6.2 scheme colour name to a reasonable default
/// hex value when the theme is not available. Mirrors the
/// PowerPoint 2013 default Office theme accents so diagrams render
/// with familiar colours when the slide's theme cannot be threaded
/// through to this function.
fn scheme_default_hex(name : String) -> String {
  match name {
    "accent1" => "#4472C4"
    "accent2" => "#ED7D31"
    "accent3" => "#A5A5A5"
    "accent4" => "#FFC000"
    "accent5" => "#5B9BD5"
    "accent6" => "#70AD47"
    "dk1" | "tx1" => "#000000"
    "lt1" | "bg1" => "#FFFFFF"
    "dk2" | "tx2" => "#44546A"
    "lt2" | "bg2" => "#E7E6E6"
    "hlink" => "#0563C1"
    "folHlink" => "#954F72"
    _ => "#4472C4"
  }
}

///|
/// Cycle through the palette by index, wrapping when the index
/// exceeds the palette length. Used to pick a per-node accent
/// without exhausting short palettes.
fn palette_pick(palette : Array[String], index : Int) -> String {
  if palette.length() == 0 {
    return "#4472C4"
  }
  let i = index % palette.length()
  palette[i]
}

// NOTE: the in-file `layout_has_constraints` / `is_spatial_constraint_type`
// pair was superseded in this round by the typed-tree predicate
// `@diagram_layout.definition_has_geometric_constraints` from
// `drawing_ml/diagram_layout/constraint_solver.mbt`. Probing on the
// decoded `LayoutNode` tree (instead of the raw XML) lets the same
// `ConstraintKind` enum drive both the gate and the geometry solver,
// and shares the spatial-vs-typography classification with the engine.
