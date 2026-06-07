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
  defs : SvgDefsCollector,
  theme? : @theme.CT_OfficeStyleSheet? = None,
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
  // it to pick per-node fill/text colours. quickStyle/styleDef is
  // decoded through the DrawingML diagram domain and contributes
  // per-style-label shape styling such as line colour.
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
  let definition_typed = try
    @dgm.CT_DiagramDefinition::new(layout_def_root)
  catch {
    _ => return []
  } noraise {
    t => t
  }
  let data_model = try
    @diagram_layout.decode_data_model(data_model_typed)
  catch {
    _ => return []
  } noraise {
    t => t
  }
  let definition = try
    @diagram_layout.decode_diagram_definition(definition_typed)
  catch {
    _ => return []
  } noraise {
    t => t
  }
  let style_def_typed = match style_def_root {
    Some(root) =>
      try @dgm.CT_StyleDefinition::new(root) catch {
        _ => None
      } noraise {
        typed => Some(typed)
      }
    None => None
  }
  let colors_def_typed = match colors_def_root {
    Some(root) =>
      try @dgm.CT_ColorTransform::new(root) catch {
        _ => None
      } noraise {
        typed => Some(typed)
      }
    None => None
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
  // §21.4.3.9 `<dgm:whole>/<a:ln>` — whole-diagram line formatting
  // draws a frame outline around the SmartArt canvas.
  let whole_node = emit_diagram_whole_outline(
    data_model_root, frame_w, frame_h, ctx,
  )
  let palette = colors_palette(colors_def_root, ctx)
  // §21.4.4.10 — per-style-label fill lists, so each node uses the
  // colour list of the style label its layout node carries.  Nodes
  // sharing a label cycle that label's list independently.
  let label_palettes = colors_by_style_label(colors_def_root, ctx)
  let label_counts : Map[String, Int] = Map([], capacity=0)
  // §21.4.4 `<dgm:txFillClrLst>` — per-style-label TEXT colour lists,
  // so each node's label uses the style label's text colour.
  let text_palettes = colors_by_style_label(
    colors_def_root,
    ctx,
    list_name="txFillClrLst",
  )
  let text_counts : Map[String, Int] = Map([], capacity=0)
  let text_line_palettes = colors_by_style_label(
    colors_def_root,
    ctx,
    list_name="txLinClrLst",
  )
  let text_line_counts : Map[String, Int] = Map([], capacity=0)
  // §21.4.5.10 `<dgm:styleLbl>/<a:style>/<a:lnRef>` — quickStyle
  // supplies per-style-label shape style. Fill/text colours remain
  // driven by colorsDef; line colour comes from styleDef.
  let line_colors = style_line_colors_by_style_label(style_def_typed, ctx)
  let line_palettes = colors_by_style_label(
    colors_def_root,
    ctx,
    list_name="linClrLst",
  )
  let line_counts : Map[String, Int] = Map([], capacity=0)
  // §21.4.4.10 `<dgm:effectClrLst>` supplies the colour list for
  // shape effects selected by the matching quickStyle
  // `<dgm:styleLbl>/<a:style>/<a:effectRef>`. The actual effect
  // geometry still comes from the DrawingML theme effectStyleLst and
  // is emitted by the existing §20.1.8 SVG filter pipeline.
  let effect_palettes = colors_by_style_label(
    colors_def_root,
    ctx,
    list_name="effectClrLst",
  )
  let effect_counts : Map[String, Int] = Map([], capacity=0)
  let effect_templates = style_effect_templates_by_style_label(
    style_def_typed, theme,
  )
  // §21.4.4.10 `<dgm:txEffectClrLst>` supplies the colour list for
  // text effects declared by the matching quickStyle
  // `<dgm:styleLbl>/<dgm:txPr>`. The effect geometry remains owned
  // by quickStyle; colorsDef only provides the style-label colour.
  let tx_effect_palettes = colors_by_style_label(
    colors_def_root,
    ctx,
    list_name="txEffectClrLst",
  )
  let tx_effect_counts : Map[String, Int] = Map([], capacity=0)
  let text_effects = style_text_effects_by_style_label(style_def_typed)
  let svg_nodes : Array[@xml.Node] = []
  match bg_node {
    Some(n) => svg_nodes.push(n)
    None => ()
  }
  match whole_node {
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
    let style_lbl = effective_point_style_label(
      data_model,
      nb.point_id,
      nb.style_lbl,
    )
    // §21.4.4.10 — prefer the node's own style-label colour list; fall
    // back to the default cycle when the node carries no label or the
    // colorsDef has no matching styleLbl.
    let fill = match style_lbl {
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
    let stroke = match style_lbl {
      Some(lbl) =>
        match line_palettes.get(lbl) {
          Some(colors) if colors.length() > 0 => {
            let i = line_counts.get(lbl).unwrap_or(0)
            line_counts[lbl] = i + 1
            colors[i % colors.length()]
          }
          _ =>
            match line_colors.get(lbl) {
              Some(color) => color
              None => "#333333"
            }
        }
      None => "#333333"
    }
    let shape_extra_attrs = diagram_effect_filter_attrs_for_style_label(
      style_lbl,
      effect_templates,
      effect_palettes,
      effect_counts,
      ctx,
      defs,
      "diagram-" + nb.point_id,
    )
    let shape_nodes = emit_node_shape(
      nb,
      fill,
      stroke~,
      extra_attrs=shape_extra_attrs,
    )
    for n in shape_nodes {
      svg_nodes.push(n)
    }
    match text {
      Some(label) =>
        if label.length() > 0 {
          // §21.4.4 — text colour from the node's style label's
          // txFillClrLst, defaulting to black when absent.
          let text_color = match style_lbl {
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
          let text_stroke = match style_lbl {
            Some(lbl) =>
              match text_line_palettes.get(lbl) {
                Some(colors) if colors.length() > 0 => {
                  let i = text_line_counts.get(lbl).unwrap_or(0)
                  text_line_counts[lbl] = i + 1
                  colors[i % colors.length()]
                }
                _ => ""
              }
            None => ""
          }
          let text_effect = diagram_text_effect_for_style_label(
            style_lbl, text_effects, tx_effect_palettes, tx_effect_counts,
          )
          svg_nodes.push(
            emit_node_label(nb, label, text_color~, text_stroke~, text_effect~),
          )
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
      diagram_group_attrs(
        dm_rid,
        lo_rid,
        qs_rid,
        cs_rid,
        data_model_typed,
        definition_typed,
        data_model,
        definition,
        style_def_typed,
        colors_def_typed,
        node_bounds.length(),
      ),
      svg_nodes,
    ),
  ]
}

///|
/// Root metadata for the rendered SmartArt group. These attributes
/// expose §21.4 part identities and definition sizes without adding
/// fake geometry for catalog-only metadata such as category lists,
/// sample data, style labels, or color transform labels.
fn diagram_group_attrs(
  dm_rid : String,
  lo_rid : String,
  qs_rid : String,
  cs_rid : String,
  data_model_typed : @dgm.CT_DataModel,
  definition_typed : @dgm.CT_DiagramDefinition,
  data_model : @diagram_layout.DataModel,
  definition : @diagram_layout.DiagramDefinition,
  style_def_typed : @dgm.CT_StyleDefinition?,
  colors_def_typed : @dgm.CT_ColorTransform?,
  rendered_node_count : Int,
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("data-ooxml", "diagram"),
    @markup.attr("data-ooxml-diagram-dm-rid", dm_rid),
    @markup.attr("data-ooxml-diagram-lo-rid", lo_rid),
    @markup.attr("data-ooxml-diagram-qs-rid", qs_rid),
    @markup.attr("data-ooxml-diagram-cs-rid", cs_rid),
    @markup.attr(
      "data-ooxml-diagram-point-count",
      data_model.points.length().to_string(),
    ),
    @markup.attr(
      "data-ooxml-diagram-connection-count",
      data_model.connections.length().to_string(),
    ),
    @markup.attr(
      "data-ooxml-diagram-rendered-node-count",
      rendered_node_count.to_string(),
    ),
  ]
  match data_model_typed.bg {
    Some(_) => attrs.push(@markup.attr("data-ooxml-diagram-bg", "1"))
    None => ()
  }
  match data_model_typed.whole {
    Some(_) => attrs.push(@markup.attr("data-ooxml-diagram-whole", "1"))
    None => ()
  }
  match definition.unique_id {
    Some(id) => attrs.push(@markup.attr("data-ooxml-diagram-layout-id", id))
    None => ()
  }
  match definition.min_ver {
    Some(v) => attrs.push(@markup.attr("data-ooxml-diagram-layout-min-ver", v))
    None => ()
  }
  match definition.def_style {
    Some(v) =>
      attrs.push(@markup.attr("data-ooxml-diagram-layout-def-style", v))
    None => ()
  }
  match definition.root.algorithm {
    Some(alg) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-diagram-layout-alg",
          diagram_algorithm_type_name(alg.kind),
        ),
      )
    None => ()
  }
  attrs.push(
    @markup.attr(
      "data-ooxml-diagram-layout-title-count",
      definition_typed.title.length().to_string(),
    ),
  )
  attrs.push(
    @markup.attr(
      "data-ooxml-diagram-layout-desc-count",
      definition_typed.desc.length().to_string(),
    ),
  )
  match definition_typed.cat_lst {
    Some(_) =>
      attrs.push(@markup.attr("data-ooxml-diagram-layout-cat-lst", "1"))
    None => ()
  }
  match definition_typed.samp_data {
    Some(_) =>
      attrs.push(@markup.attr("data-ooxml-diagram-layout-samp-data", "1"))
    None => ()
  }
  match definition_typed.style_data {
    Some(_) =>
      attrs.push(@markup.attr("data-ooxml-diagram-layout-style-data", "1"))
    None => ()
  }
  match definition_typed.clr_data {
    Some(_) =>
      attrs.push(@markup.attr("data-ooxml-diagram-layout-clr-data", "1"))
    None => ()
  }
  attrs.push(
    @markup.attr(
      "data-ooxml-diagram-layout-node-count",
      definition_typed.layout_node.length().to_string(),
    ),
  )
  match style_def_typed {
    Some(style_def) => {
      attrs.push(
        @markup.attr("data-ooxml-diagram-style-id", style_def.unique_id),
      )
      attrs.push(
        @markup.attr(
          "data-ooxml-diagram-style-label-count",
          style_def.style_lbl.length().to_string(),
        ),
      )
      match style_def.scene3d {
        Some(_) =>
          attrs.push(@markup.attr("data-ooxml-diagram-style-scene3d", "1"))
        None => ()
      }
      match style_def.cat_lst {
        Some(_) =>
          attrs.push(@markup.attr("data-ooxml-diagram-style-cat-lst", "1"))
        None => ()
      }
    }
    None => ()
  }
  match colors_def_typed {
    Some(colors_def) => {
      attrs.push(
        @markup.attr("data-ooxml-diagram-colors-id", colors_def.unique_id),
      )
      attrs.push(
        @markup.attr(
          "data-ooxml-diagram-colors-style-label-count",
          colors_def.style_lbl.length().to_string(),
        ),
      )
      match colors_def.cat_lst {
        Some(_) =>
          attrs.push(@markup.attr("data-ooxml-diagram-colors-cat-lst", "1"))
        None => ()
      }
    }
    None => ()
  }
  attrs
}

///|
fn diagram_algorithm_type_name(kind : @diagram_layout.AlgorithmType) -> String {
  match kind {
    @diagram_layout.AlgComposite => "composite"
    @diagram_layout.AlgConn => "conn"
    @diagram_layout.AlgCycle => "cycle"
    @diagram_layout.AlgHierChild => "hierChild"
    @diagram_layout.AlgHierRoot => "hierRoot"
    @diagram_layout.AlgLin => "lin"
    @diagram_layout.AlgPyra => "pyra"
    @diagram_layout.AlgSnake => "snake"
    @diagram_layout.AlgSp => "sp"
    @diagram_layout.AlgTx => "tx"
  }
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
/// §21.4.3.4 CT_ElemPropSet — a data-model point can name the
/// presentation style label to apply through `prSet@presStyleLbl`.
/// That point-local label overrides the layout node's
/// `layoutNode@styleLbl` when selecting colorsDef / quickStyle
/// entries for the rendered node.
fn effective_point_style_label(
  data_model : @diagram_layout.DataModel,
  point_id : String,
  layout_style_lbl : String?,
) -> String? {
  for p in data_model.points {
    if p.id == point_id {
      match p.pr_set {
        Some(pr_set) =>
          match attr_value(pr_set, "presStyleLbl") {
            Some(lbl) if lbl.length() > 0 => return Some(lbl)
            _ => ()
          }
        None => ()
      }
      break
    }
  }
  layout_style_lbl
}

///|
/// Emit the SVG shape (or shapes) for one laid-out diagram node.
/// The preset shape is taken from the engine's `NodeBounds.shape`:
/// ellipse / roundRect / triangle use dedicated SVG primitives, and
/// every other §20.1.10.56 preset is materialised through the shared
/// faithful geometry library (translated into the node's bounds), so a
/// diagram point renders its real shape body rather than a plain rect.
fn emit_node_shape(
  nb : @diagram_layout.NodeBounds,
  fill : String,
  stroke? : String = "#333333",
  extra_attrs? : Array[@xml.Attribute] = [],
) -> Array[@xml.Node] {
  if nb.hide_geom {
    return []
  }
  let x = nb.bounds.x
  let y = nb.bounds.y
  let w = nb.bounds.width
  let h = nb.bounds.height
  if w <= 0.0 || h <= 0.0 {
    return []
  }
  let common_attrs : Array[@xml.Attribute] = [
    @markup.attr("fill", fill),
    @markup.attr("stroke", stroke),
    @markup.attr("stroke-width", "1"),
  ]
  for a in extra_attrs {
    common_attrs.push(a)
  }
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
      // §20.1.10.56 — render every OTHER preset through the shared
      // faithful geometry (all 187 ST_ShapeType presets), translated into
      // the node's bounds, instead of degrading non-trivial SmartArt
      // shapes (chevron, pentagon, arrows, …) to a plain rect.  The
      // geometry library always yields a path for a valid `PresetShape`;
      // a degenerate empty result keeps the bounding rect.
      let iw = (w + 0.5).to_int()
      let ih = (h + 0.5).to_int()
      let d = @preset_geometry.render_preset_shape_path(
        nb.shape,
        iw,
        ih,
        nb.adjustments,
      )
      if d == "" {
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
      } else {
        let attrs : Array[@xml.Attribute] = [
          @markup.attr("d", d),
          @markup.attr(
            "transform",
            "translate(" + format_double(x) + "," + format_double(y) + ")",
          ),
        ]
        for a in common_attrs {
          attrs.push(a)
        }
        [@markup.elem_ns("path", @markup.svg_ns, attrs, [])]
      }
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
/// §21.4.3.9 `<dgm:whole>` — render the whole-diagram line formatting
/// carried by `<a:ln>` as an SVG rectangle stroke around the diagram
/// canvas. Effects are preserved by the domain round-trip but are not
/// emitted here until the SmartArt bridge has a full effect pipeline.
fn emit_diagram_whole_outline(
  data_model_root : @xml.Element,
  frame_w : Double,
  frame_h : Double,
  ctx : ColorResolveContext,
) -> @xml.Node? {
  let whole = match first_child_named(data_model_root, "whole") {
    Some(w) => w
    None => return None
  }
  let ln = match first_child_named(whole, "ln") {
    Some(l) => l
    None => return None
  }
  if first_child_named(ln, "noFill") is Some(_) {
    return None
  }
  let color = match @paint.resolve_solid_fill(ln, ctx~) {
    Some(rc) => @paint.format_resolved_color(rc)
    None => "#595959"
  }
  let stroke_width = match attr_value(ln, "w") {
    Some(w) =>
      try @string.parse_double(w) catch {
        _ => 9525.0
      } noraise {
        v => v
      }
    None => 9525.0
  }
  let half = stroke_width / 2.0
  Some(
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", format_double(half)),
        @markup.attr("y", format_double(half)),
        @markup.attr("width", format_double(frame_w - stroke_width)),
        @markup.attr("height", format_double(frame_h - stroke_width)),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", color),
        @markup.attr("stroke-width", format_double(stroke_width)),
      ],
      [],
    ),
  )
}

///|
priv struct DiagramText3DStyle {
  sp3d : @xml.Element
  scene3d : @xml.Element?
}

///|
priv struct DiagramTextRenderEffect {
  sp3d : @xml.Element
  scene3d : @xml.Element?
  palette_color : String?
}

///|
fn emit_node_label(
  nb : @diagram_layout.NodeBounds,
  label : String,
  text_color? : String = "#000000",
  text_stroke? : String = "",
  text_effect? : DiagramTextRenderEffect? = None,
) -> @xml.Node {
  let cx = nb.bounds.x + nb.bounds.width * 0.5
  let cy = nb.bounds.y + nb.bounds.height * 0.5
  // Heuristic font size: the smaller of the bounding-box short
  // side / 5 and 180000 EMU (~19 px at 96 DPI). Diagram text is
  // typically much smaller than the box itself in PowerPoint.
  let short_side = double_min_local(nb.bounds.width, nb.bounds.height)
  let raw_size = short_side / 5.0
  let font_size = if raw_size > 180000.0 { 180000.0 } else { raw_size }
  let text_node = diagram_label_text_node(
    cx, cy, font_size, label, text_color, text_stroke,
  )
  let effect = match text_effect {
    Some(e) => e
    None => return text_node
  }
  let effect_children = diagram_text_effect_nodes(
    effect, cx, cy, font_size, label,
  )
  if effect_children.length() == 0 {
    return text_node
  }
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("class", "diagram-text-effect"),
    @markup.attr("color", text_color),
  ]
  for a in diagram_text_effect_transform_attrs(effect) {
    attrs.push(a)
  }
  effect_children.push(text_node)
  @markup.elem_ns("g", @markup.svg_ns, attrs, effect_children)
}

///|
fn diagram_label_text_node(
  cx : Double,
  cy : Double,
  font_size : Double,
  label : String,
  fill : String,
  stroke : String,
  extra_attrs? : Array[@xml.Attribute] = [],
) -> @xml.Node {
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("x", format_double(cx)),
    @markup.attr("y", format_double(cy)),
    @markup.attr("text-anchor", "middle"),
    @markup.attr("dominant-baseline", "central"),
    @markup.attr("font-family", "sans-serif"),
    @markup.attr("font-size", format_double(font_size)),
    @markup.attr("fill", fill),
  ]
  if stroke.length() > 0 {
    attrs.push(@markup.attr("stroke", stroke))
    attrs.push(@markup.attr("stroke-width", format_double(font_size * 0.04)))
    attrs.push(@markup.attr("paint-order", "stroke fill"))
  }
  for a in extra_attrs {
    attrs.push(a)
  }
  @markup.elem_ns("text", @markup.svg_ns, attrs, [@markup.text(label)])
}

///|
fn diagram_text_effect_nodes(
  effect : DiagramTextRenderEffect,
  cx : Double,
  cy : Double,
  font_size : Double,
  label : String,
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  match diagram_text_extrusion_node(effect, cx, cy, font_size, label) {
    Some(n) => nodes.push(n)
    None => ()
  }
  match diagram_text_contour_node(effect, cx, cy, font_size, label) {
    Some(n) => nodes.push(n)
    None => ()
  }
  nodes
}

///|
fn diagram_text_extrusion_node(
  effect : DiagramTextRenderEffect,
  cx : Double,
  cy : Double,
  font_size : Double,
  label : String,
) -> @xml.Node? {
  let extrusion_emu = attr_emu_d(effect.sp3d, "extrusionH", 0.0)
  if extrusion_emu <= 0.0 {
    return None
  }
  let extrusion_h = extrusion_emu / 9525.0
  let (offset_x, offset_y) = extrusion_offset(
    diagram_text_effect_camera_preset(effect),
    extrusion_h,
  )
  let raw_layers = (extrusion_h / 2.0 + 0.999).to_int()
  let layers = if raw_layers > 10 { 10 } else { raw_layers }
  if layers <= 0 {
    return None
  }
  let color = diagram_text_effect_color(effect, "extrusionClr")
  let children : Array[@xml.Node] = []
  for i = layers; i > 0; i = i - 1 {
    let layer_offset = i.to_double() / layers.to_double()
    let x = offset_x * layer_offset
    let y = offset_y * layer_offset
    let opacity = 0.5 + 0.5 * (1.0 - layer_offset)
    children.push(
      diagram_label_text_node(cx, cy, font_size, label, color, "", extra_attrs=[
        @markup.attr("class", "diagram-text-extrusion-layer"),
        @markup.attr(
          "transform",
          "translate(" +
          format_double_for_filter(x) +
          ", " +
          format_double_for_filter(y) +
          ")",
        ),
        @markup.attr("fill-opacity", format_opacity(opacity)),
        @markup.attr("stroke", "none"),
      ]),
    )
  }
  Some(
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [@markup.attr("class", "diagram-text-extrusion-effect")],
      children,
    ),
  )
}

///|
fn diagram_text_contour_node(
  effect : DiagramTextRenderEffect,
  cx : Double,
  cy : Double,
  font_size : Double,
  label : String,
) -> @xml.Node? {
  let contour_emu = attr_emu_d(effect.sp3d, "contourW", 0.0)
  if contour_emu <= 0.0 {
    return None
  }
  let color = diagram_text_effect_color(effect, "contourClr")
  let contour_w = contour_emu / 9525.0
  Some(
    diagram_label_text_node(cx, cy, font_size, label, "none", "", extra_attrs=[
      @markup.attr("class", "diagram-text-contour-effect"),
      @markup.attr("stroke", color),
      @markup.attr("stroke-width", format_double_for_filter(contour_w)),
      @markup.attr("stroke-linejoin", "round"),
      @markup.attr("paint-order", "stroke fill"),
    ]),
  )
}

///|
fn diagram_text_effect_color(
  effect : DiagramTextRenderEffect,
  sp3d_color_child : String,
) -> String {
  match effect.palette_color {
    Some(c) => c
    None => resolve_sp3d_color(effect.sp3d, sp3d_color_child)
  }
}

///|
fn diagram_text_effect_camera_preset(
  effect : DiagramTextRenderEffect,
) -> String {
  match diagram_text_effect_camera(effect) {
    Some(camera) =>
      match attr_value(camera, "prst") {
        Some(p) => p
        None => "orthographicFront"
      }
    None => "orthographicFront"
  }
}

///|
fn diagram_text_effect_transform_attrs(
  effect : DiagramTextRenderEffect,
) -> Array[@xml.Attribute] {
  let camera = match diagram_text_effect_camera(effect) {
    Some(c) => c
    None => return []
  }
  let preset = match attr_value(camera, "prst") {
    Some(p) => p
    None => "orthographicFront"
  }
  let transform = apply_camera_zoom_rot(
    calculate_camera_transform(preset),
    camera,
  )
  if transform3d_is_identity(transform) {
    []
  } else {
    [@markup.attr("transform", compose_transform3d_attr(transform))]
  }
}

///|
fn diagram_text_effect_camera(
  effect : DiagramTextRenderEffect,
) -> @xml.Element? {
  match effect.scene3d {
    Some(scene) => first_child_named(scene, "camera")
    None => None
  }
}

///|
fn style_text_effects_by_style_label(
  style_def : @dgm.CT_StyleDefinition?,
) -> Map[String, DiagramText3DStyle] {
  let map : Map[String, DiagramText3DStyle] = Map([], capacity=0)
  let sd = match style_def {
    Some(s) => s
    None => return map
  }
  for label in sd.style_lbl {
    let tx_pr = match label.tx_pr {
      Some(t) => t
      None => continue
    }
    let sp3d = match text_props_sp3d(tx_pr) {
      Some(s) => s
      None => continue
    }
    let scene3d = match label.scene3d {
      Some(s) => Some(s)
      None => sd.scene3d
    }
    map[label.name] = { sp3d, scene3d }
  }
  map
}

///|
fn text_props_sp3d(tx_pr : @dgm.CT_TextProps) -> @xml.Element? {
  for child in tx_pr.text3d {
    if child.name.local_name == "sp3d" {
      return Some(child)
    }
  }
  None
}

///|
fn diagram_text_effect_for_style_label(
  style_lbl : String?,
  text_effects : Map[String, DiagramText3DStyle],
  tx_effect_palettes : Map[String, Array[String]],
  tx_effect_counts : Map[String, Int],
) -> DiagramTextRenderEffect? {
  let lbl = match style_lbl {
    Some(value) => value
    None => return None
  }
  let spec = match text_effects.get(lbl) {
    Some(value) => value
    None => return None
  }
  let palette_color = diagram_text_effect_palette_color(
    lbl, tx_effect_palettes, tx_effect_counts,
  )
  Some({ sp3d: spec.sp3d, scene3d: spec.scene3d, palette_color })
}

///|
fn diagram_text_effect_palette_color(
  lbl : String,
  tx_effect_palettes : Map[String, Array[String]],
  tx_effect_counts : Map[String, Int],
) -> String? {
  let colors = match tx_effect_palettes.get(lbl) {
    Some(values) if values.length() > 0 => values
    _ => return None
  }
  let i = tx_effect_counts.get(lbl).unwrap_or(0)
  tx_effect_counts[lbl] = i + 1
  Some(colors[i % colors.length()])
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
/// resolving every DrawingML colour choice through the shared paint
/// resolver so colorsDef and shape fills share one source of truth.
/// Returns an empty array when the styleLbl carries no fill list.
fn fill_clr_lst_colors(
  lbl : @xml.Element,
  ctx : ColorResolveContext,
  list_name? : String = "fillClrLst",
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
      Element(e) =>
        match diagram_color_choice_hex(e, ctx) {
          Some(hex) => result.push(hex)
          None => ()
        }
      _ => ()
    }
  }
  result
}

///|
/// Resolve the diagram-side DrawingML EG_ColorChoice used by
/// colorsDef/styleDef colour lists through the shared paint colour
/// resolver. This keeps SmartArt node/text/line colours aligned with
/// every other DrawingML fill path and avoids a second, partial colour
/// implementation in the diagram bridge.
fn diagram_color_choice_hex(
  element : @xml.Element,
  ctx : ColorResolveContext,
) -> String? {
  match @paint.resolve_solid_fill(element, ctx~) {
    Some(rc) => {
      let color = @paint.format_resolved_color(rc)
      if color == "none" {
        None
      } else {
        Some(color)
      }
    }
    None => None
  }
}

///|
/// §21.4.5.10 `<dgm:styleLbl>` — map quickStyle/styleDef style labels
/// to the line colour declared by their DrawingML `<a:style>/<a:lnRef>`.
fn style_line_colors_by_style_label(
  style_def : @dgm.CT_StyleDefinition?,
  ctx : ColorResolveContext,
) -> Map[String, String] {
  let map : Map[String, String] = Map([], capacity=0)
  let sd = match style_def {
    Some(s) => s
    None => return map
  }
  for label in sd.style_lbl {
    let style = match label.style {
      Some(s) => s
      None => continue
    }
    let ln_ref = match first_child_named(style, "lnRef") {
      Some(l) => l
      None => continue
    }
    for child in ln_ref.children {
      match child {
        Element(e) =>
          match diagram_color_choice_hex(e, ctx) {
            Some(hex) => {
              map[label.name] = hex
              break
            }
            None => ()
          }
        _ => ()
      }
    }
  }
  map
}

///|
/// §21.4.5.10 `<dgm:styleLbl>/<a:style>/<a:effectRef>` — resolve
/// quickStyle effect references to the theme's DrawingML
/// `<a:effectStyle>` template. The template is later coloured from
/// colorsDef `<dgm:effectClrLst>` and emitted through the shared
/// §20.1.8 SVG filter path.
fn style_effect_templates_by_style_label(
  style_def : @dgm.CT_StyleDefinition?,
  theme : @theme.CT_OfficeStyleSheet?,
) -> Map[String, @xml.Element] {
  let map : Map[String, @xml.Element] = Map([], capacity=0)
  let sd = match style_def {
    Some(s) => s
    None => return map
  }
  let t = match theme {
    Some(value) => value
    None => return map
  }
  for label in sd.style_lbl {
    let style = match label.style {
      Some(s) => s
      None => continue
    }
    let effect_ref = match first_child_named(style, "effectRef") {
      Some(e) => e
      None => continue
    }
    match resolve_effect_ref_template(effect_ref, t) {
      Some(template) => map[label.name] = template
      None => ()
    }
  }
  map
}

///|
fn diagram_effect_filter_attrs_for_style_label(
  style_lbl : String?,
  effect_templates : Map[String, @xml.Element],
  effect_palettes : Map[String, Array[String]],
  effect_counts : Map[String, Int],
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  shape_id : String,
) -> Array[@xml.Attribute] {
  let lbl = match style_lbl {
    Some(value) => value
    None => return []
  }
  let template = match effect_templates.get(lbl) {
    Some(value) => value
    None => return []
  }
  let coloured_template = match
    diagram_effect_hex_for_label(lbl, effect_palettes, effect_counts) {
    Some(hex) => diagram_effect_template_with_color(template, hex)
    None => template
  }
  render_effects_filter_attr(coloured_template, shape_id, ctx, defs)
}

///|
fn diagram_effect_hex_for_label(
  lbl : String,
  effect_palettes : Map[String, Array[String]],
  effect_counts : Map[String, Int],
) -> String? {
  let colors = match effect_palettes.get(lbl) {
    Some(values) if values.length() > 0 => values
    _ => return None
  }
  let i = effect_counts.get(lbl).unwrap_or(0)
  effect_counts[lbl] = i + 1
  let color = colors[i % colors.length()]
  if color.length() > 0 && color.code_unit_at(0).to_int() == 0x23 {
    Some(strip_hash(color))
  } else {
    None
  }
}

///|
fn diagram_effect_template_with_color(
  template : @xml.Element,
  hex : String,
) -> @xml.Element {
  diagram_rewrite_effect_color(template, hex)
}

///|
fn diagram_rewrite_effect_color(
  element : @xml.Element,
  hex : String,
) -> @xml.Element {
  if diagram_is_color_choice_element(element) {
    let attrs : Array[@xml.Attribute] = []
    for a in element.attributes {
      if a.name.local_name != "val" && a.name.local_name != "lastClr" {
        attrs.push(a)
      }
    }
    attrs.push(@markup.attr("val", hex))
    return {
      name: {
        prefix: element.name.prefix,
        local_name: "srgbClr",
        ns: element.name.ns,
      },
      attributes: attrs,
      children: element.children,
    }
  }
  let kids : Array[@xml.Node] = []
  for child in element.children {
    match child {
      @xml.Node::Element(e) =>
        kids.push(@xml.Node::Element(diagram_rewrite_effect_color(e, hex)))
      other => kids.push(other)
    }
  }
  { name: element.name, attributes: element.attributes, children: kids }
}

///|
fn diagram_is_color_choice_element(element : @xml.Element) -> Bool {
  match element.name.local_name {
    "srgbClr" | "schemeClr" | "sysClr" | "hslClr" | "scrgbClr" | "prstClr" =>
      true
    _ => false
  }
}

///|
/// §21.4.4.10 — map every `<dgm:styleLbl name="…">` in the colorsDef to
/// its resolved fill colour list, so a node can pick the colour list of
/// the style label its layout node carries (rather than always cycling
/// the first label's list).
fn colors_by_style_label(
  colors_def : @xml.Element?,
  ctx : ColorResolveContext,
  list_name? : String = "fillClrLst",
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
