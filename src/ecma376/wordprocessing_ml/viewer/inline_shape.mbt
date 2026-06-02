// §20.4 — Inline DrawingML shape (wps:wsp) renderer for the WML viewer.
//
// When a `<w:drawing>` contains a `<wps:wsp>` (wordprocessing-shape)
// instead of a `<pic:pic>` payload, `build_inline_image` returns `None`
// because no blip is reachable, and `emit_drawing_span` previously
// reserved only a whitespace placeholder — leaving the shape invisible.
//
// This module bridges that gap: it walks
//   `<w:drawing>/<wp:inline|wp:anchor>/<a:graphic>/<a:graphicData uri="…/wordprocessingShape">/<wps:wsp>`
// and lifts the shape's preset geometry, fill colour and extent into a
// self-contained SVG `<g>` element.  The group is paired with the
// reserved width/height and surfaced via the existing math-payload slot
// so the line emitter places it on the baseline alongside surrounding
// glyphs.

///|
/// `<a:graphicData @uri>` token identifying a wordprocessing-shape
/// payload (§20.5).  Used to discriminate shape drawings from picture
/// drawings inside a single dispatcher.
const WPS_GRAPHIC_DATA_URI : String = "http://schemas.microsoft.com/office/word/2010/wordprocessingShape"

///|
/// Attempt to build a rendered shape payload for a `<w:drawing>` whose
/// graphicData payload is a wordprocessing-shape (`<wps:wsp>`).  Returns
/// `None` when the drawing has no shape body, when the extent is zero,
/// or when the preset geometry name is unknown to the DML preset
/// dispatcher.
///
/// The returned `MathPayload` reuses the math-fragment baseline slot:
/// `group` is the SVG `<g>` for the shape (translated to draw at
/// (0,-height) so its bottom edge sits on the line baseline);
/// `width_px` / `ascent_px` reserve the line area; `descent_px` is `0`
/// because the shape sits entirely above the baseline.
/// Render one `<wps:wsp>` shape sized `w_px` × `h_px` at local origin
/// (0,0): its geometry `<path>` (preset or custom) painted with the
/// shape's solid fill / line stroke, followed by the laid-out text body
/// (`<wps:txbx>`).  Returns `None` when the shape carries no
/// resolvable geometry (so the caller can skip it).  Shared by the
/// single-shape inline path and the group renderer.
fn wsp_shape_nodes(
  wsp : @xml.Element,
  w_px : Double,
  h_px : Double,
  warnings : Array[String],
) -> Array[@xml.Node]? {
  let sp_pr = match first_child_named(wsp, "spPr") {
    Some(s) => s
    None => return None
  }
  // §20.1.9 EG_Geometry — a shape carries EITHER a `<a:prstGeom>`
  // preset or a `<a:custGeom>` explicit path.  Try the preset first,
  // then fall back to the custom-geometry renderer so freeform /
  // user-drawn Word shapes paint their real outline instead of
  // vanishing.
  let path_d = match first_child_named(sp_pr, "prstGeom") {
    Some(prst_geom) =>
      match @pml_viewer.render_preset_geometry(prst_geom, w_px, h_px) {
        Some(d) => d
        None => return None
      }
    None =>
      match first_child_named(sp_pr, "custGeom") {
        Some(cust_geom) =>
          match @pml_viewer.render_custom_geometry(cust_geom, w_px, h_px) {
            Some(d) => d
            None => return None
          }
        None => return None
      }
  }
  let fill_hex = wps_solid_fill_hex(sp_pr)
  let stroke_hex = wps_line_stroke_hex(sp_pr)
  let path_attrs : Array[@xml.Attribute] = [
    @markup.attr("d", path_d),
    @markup.attr("fill", fill_hex),
  ]
  match stroke_hex {
    Some(hex) => {
      path_attrs.push(@markup.attr("stroke", hex))
      path_attrs.push(@markup.attr("stroke-width", "1"))
    }
    None => ()
  }
  let children : Array[@xml.Node] = [
    @markup.elem_ns("path", @markup.svg_ns, path_attrs, []),
  ]
  // §20.1.2.2.40 `<wps:txbx>/<w:txbxContent>` — the shape's text body.
  for node in build_textbox_body_nodes(wsp, w_px, warnings) {
    children.push(node)
  }
  Some(children)
}

///|
fn build_inline_shape(
  drawing : @xml.Element,
  warnings : Array[String],
) -> MathPayload? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let wsp = match drawing_wps_shape(drawing) {
    Some(s) => s
    None => return None
  }
  let children = match wsp_shape_nodes(wsp, w_px, h_px, warnings) {
    Some(nodes) => nodes
    None => return None
  }
  let group : @xml.Element = {
    name: @markup.qname_ns("g", @markup.svg_ns),
    attributes: [
      @markup.attr("transform", "translate(0," + fmt_double(-h_px) + ")"),
    ],
    children,
  }
  Some({ group, width_px: w_px, ascent_px: h_px, descent_px: 0.0 })
}

///|
/// `<a:graphicData @uri>` token identifying a WordprocessingGroup
/// payload (§20.1.2.2.20).
const WPG_GRAPHIC_DATA_URI : String = "http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"

///|
/// Walk `<w:drawing>/<wp:inline|wp:anchor>/<a:graphic>/<a:graphicData
/// uri=".../wordprocessingGroup">/<wpg:wgp>` and return the group body
/// element, or `None` when the drawing is not a group.
fn drawing_wpg_group(drawing : @xml.Element) -> @xml.Element? {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "graphic") {
            Some(g) =>
              match first_child_named(g, "graphicData") {
                Some(gd) =>
                  if attr_value(gd, "uri").unwrap_or("") == WPG_GRAPHIC_DATA_URI {
                    return first_child_named(gd, "wgp")
                  }
                None => ()
              }
            None => ()
          }
        }
      _ => ()
    }
  }
  None
}

///|
/// Read an `<a:off>`/`<a:ext>`/`<a:chOff>`/`<a:chExt>`-style child of an
/// `<a:xfrm>` as an (x|cx, y|cy) EMU pair.  Returns `None` when the
/// child or its attributes are absent / unparsable.
fn xfrm_pair(
  xfrm : @xml.Element,
  child : String,
  attr_x : String,
  attr_y : String,
) -> (Double, Double)? {
  let e = match first_child_named(xfrm, child) {
    Some(c) => c
    None => return None
  }
  let x = match attr_value(e, attr_x) {
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => return None
      } noraise {
        d => d
      }
    None => return None
  }
  let y = match attr_value(e, attr_y) {
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => return None
      } noraise {
        d => d
      }
    None => return None
  }
  Some((x, y))
}

///|
/// Locate a group child's `<a:xfrm>` — under `<wps:spPr>` for a shape /
/// picture, or under `<wpg:grpSpPr>` for a nested group.
fn child_xfrm_element(child : @xml.Element) -> @xml.Element? {
  let props = match first_child_named(child, "spPr") {
    Some(p) => Some(p)
    None => first_child_named(child, "grpSpPr")
  }
  match props {
    Some(p) => first_child_named(p, "xfrm")
    None => None
  }
}

///|
/// Map a group child's `<a:xfrm>` `off`/`ext` from the parent child
/// coordinate space (origin `ch_off`, scale `sx`/`sy`) into a pixel rect
/// `(rx, ry, rw, rh)`.  `None` when the transform is absent or degenerate.
fn group_child_rect(
  child : @xml.Element,
  ch_off_x : Double,
  ch_off_y : Double,
  sx : Double,
  sy : Double,
) -> (Double, Double, Double, Double)? {
  let xfrm = match child_xfrm_element(child) {
    Some(x) => x
    None => return None
  }
  let (off_x, off_y) = match xfrm_pair(xfrm, "off", "x", "y") {
    Some(p) => p
    None => return None
  }
  let (ext_cx, ext_cy) = match xfrm_pair(xfrm, "ext", "cx", "cy") {
    Some(p) => p
    None => return None
  }
  let rw = ext_cx * sx
  let rh = ext_cy * sy
  if rw <= 0.0 || rh <= 0.0 {
    return None
  }
  Some(((off_x - ch_off_x) * sx, (off_y - ch_off_y) * sy, rw, rh))
}

///|
/// Wrap rendered child `nodes` in an SVG `<g transform="translate(rx,ry)">`.
fn translate_group(
  rx : Double,
  ry : Double,
  nodes : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element({
    name: @markup.qname_ns("g", @markup.svg_ns),
    attributes: [
      @markup.attr(
        "transform",
        "translate(" + fmt_double(rx) + "," + fmt_double(ry) + ")",
      ),
    ],
    children: nodes,
  })
}

///|
/// §20.2.2.5 — the relationship id of a `<pic:pic>`'s blip fill
/// (`<pic:blipFill>/<a:blip @r:embed|@r:link>`), or `None`.
fn pic_blip_rid(pic : @xml.Element) -> String? {
  let bf = match first_child_named(pic, "blipFill") {
    Some(b) => b
    None => return None
  }
  let blip = match first_child_named(bf, "blip") {
    Some(b) => b
    None => return None
  }
  match attr_value(blip, "embed") {
    Some(v) => Some(v)
    None => attr_value(blip, "link")
  }
}

///|
/// §20.2.2.5 `<pic:pic>` — an SVG `<image>` at pixel rect (rx, ry, rw, rh)
/// whose `href` is the blip resolved through `image_resolver` as a data
/// URI.  `None` when the blip id is missing or unresolved.
fn group_pic_image_node(
  pic : @xml.Element,
  rx : Double,
  ry : Double,
  rw : Double,
  rh : Double,
  image_resolver : (String) -> ResolvedImage?,
) -> @xml.Node? {
  let rid = match pic_blip_rid(pic) {
    Some(r) => r
    None => return None
  }
  let img = match image_resolver(rid) {
    Some(i) => i
    None => return None
  }
  let href = "data:" + img.mime_type + ";base64," + img.base64_data
  Some(
    @markup.elem_ns(
      "image",
      @markup.svg_ns,
      [
        @markup.attr("x", fmt_double(rx)),
        @markup.attr("y", fmt_double(ry)),
        @markup.attr("width", fmt_double(rw)),
        @markup.attr("height", fmt_double(rh)),
        @markup.attr("href", href),
      ],
      [],
    ),
  )
}

///|
/// Render one group / canvas child already mapped to pixel rect
/// (rx, ry, rw, rh): a `<wps:wsp>` paints its preset / custom geometry, a
/// `<pic:pic>` paints its resolved blip image, and a nested `<wpg:grpSp>`
/// recurses into its own child coordinate space.  Other child kinds
/// (connectors, graphic frames) return `None` and are skipped.
fn render_group_child_node(
  child : @xml.Element,
  rx : Double,
  ry : Double,
  rw : Double,
  rh : Double,
  image_resolver : (String) -> ResolvedImage?,
  warnings : Array[String],
) -> @xml.Node? {
  match child.name.local_name {
    "wsp" =>
      match wsp_shape_nodes(child, rw, rh, warnings) {
        Some(nodes) => Some(translate_group(rx, ry, nodes))
        None => None
      }
    "pic" => group_pic_image_node(child, rx, ry, rw, rh, image_resolver)
    "grpSp" => {
      let nested = render_wpg_group_children(
        child, rw, rh, image_resolver, warnings,
      )
      if nested.length() > 0 {
        Some(translate_group(rx, ry, nested))
      } else {
        None
      }
    }
    _ => None
  }
}

///|
/// §20.1.2.2.20 / §20.1.2.2.6 — render the children of a `<wpg:wgp>` or
/// nested `<wpg:grpSp>` `container` onto a `target_w` × `target_h` pixel
/// box.  The container's `grpSpPr/xfrm` `chOff`/`chExt` define the child
/// coordinate space; each child is mapped into the box and dispatched
/// through `render_group_child_node` (shapes, pictures and nested groups
/// alike).  Returns an empty array when the container carries no usable
/// child geometry.
fn render_wpg_group_children(
  container : @xml.Element,
  target_w : Double,
  target_h : Double,
  image_resolver : (String) -> ResolvedImage?,
  warnings : Array[String],
) -> Array[@xml.Node] {
  let grp_sp_pr = match first_child_named(container, "grpSpPr") {
    Some(s) => s
    None => return []
  }
  let xfrm = match first_child_named(grp_sp_pr, "xfrm") {
    Some(x) => x
    None => return []
  }
  // Child coordinate space: chOff (origin) + chExt (extent).
  let (ch_off_x, ch_off_y) = match xfrm_pair(xfrm, "chOff", "x", "y") {
    Some(p) => p
    None => return []
  }
  let (ch_ext_cx, ch_ext_cy) = match xfrm_pair(xfrm, "chExt", "cx", "cy") {
    Some(p) => p
    None => return []
  }
  if ch_ext_cx <= 0.0 || ch_ext_cy <= 0.0 {
    return []
  }
  let sx = target_w / ch_ext_cx
  let sy = target_h / ch_ext_cy
  let children : Array[@xml.Node] = []
  for child in container.children {
    match child {
      Element(c) =>
        match group_child_rect(c, ch_off_x, ch_off_y, sx, sy) {
          Some((rx, ry, rw, rh)) =>
            match
              render_group_child_node(
                c, rx, ry, rw, rh, image_resolver, warnings,
              ) {
              Some(node) => children.push(node)
              None => ()
            }
          None => ()
        }
      _ => ()
    }
  }
  children
}

///|
/// §20.1.2.2.20 `<wpg:wgp>` — render a WordprocessingGroup.  The group's
/// child coordinate space is `<wpg:grpSpPr>/<a:xfrm>` `chOff` / `chExt`;
/// each child carries its own `<a:xfrm>` `off` / `ext` in that space,
/// which we map into the group's rendered `w_px` × `h_px` box.  Shapes
/// (`<wps:wsp>`), pictures (`<pic:pic>`, resolved through `image_resolver`)
/// and nested groups (`<wpg:grpSp>`, walked recursively) all paint at
/// their mapped positions.
fn build_inline_group(
  drawing : @xml.Element,
  image_resolver : (String) -> ResolvedImage?,
  warnings : Array[String],
) -> MathPayload? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let wgp = match drawing_wpg_group(drawing) {
    Some(g) => g
    None => return None
  }
  let children = render_wpg_group_children(
    wgp, w_px, h_px, image_resolver, warnings,
  )
  if children.length() == 0 {
    return None
  }
  let group : @xml.Element = {
    name: @markup.qname_ns("g", @markup.svg_ns),
    attributes: [
      @markup.attr("transform", "translate(0," + fmt_double(-h_px) + ")"),
    ],
    children,
  }
  Some({ group, width_px: w_px, ascent_px: h_px, descent_px: 0.0 })
}

///|
/// `<a:graphicData @uri>` token identifying a WordprocessingCanvas
/// payload (§20.4.2.29).
const WPC_GRAPHIC_DATA_URI : String = "http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"

///|
/// Walk `<w:drawing>/<wp:inline|wp:anchor>/<a:graphic>/<a:graphicData
/// uri=".../wordprocessingCanvas">/<wpc:wpc>` and return the canvas body
/// element, or `None` when the drawing is not a canvas.
fn drawing_wpc_canvas(drawing : @xml.Element) -> @xml.Element? {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "graphic") {
            Some(g) =>
              match first_child_named(g, "graphicData") {
                Some(gd) =>
                  if attr_value(gd, "uri").unwrap_or("") == WPC_GRAPHIC_DATA_URI {
                    return first_child_named(gd, "wpc")
                  }
                None => ()
              }
            None => ()
          }
        }
      _ => ()
    }
  }
  None
}

///|
/// §20.4.2.29 `<wpc:wpc>` — render a WordprocessingCanvas.  The canvas
/// children (`<wps:wsp>`) carry `<a:xfrm>` `off`/`ext` in absolute EMU
/// within the canvas, mapped to px (914400 EMU = 96 px) and rendered
/// via `wsp_shape_nodes`.  An optional `<wpc:bg>` solid fill paints a
/// backing rectangle.  Nested groups / pictures inside the canvas are
/// not yet walked (skipped), so shape children paint at their EMU
/// positions.
fn build_inline_canvas(
  drawing : @xml.Element,
  image_resolver : (String) -> ResolvedImage?,
  warnings : Array[String],
) -> MathPayload? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let wpc = match drawing_wpc_canvas(drawing) {
    Some(c) => c
    None => return None
  }
  let f = 96.0 / 914400.0
  let children : Array[@xml.Node] = []
  // §20.1.2.2.4 `<wpc:bg>` — a backing rectangle when it carries a
  // solid fill.
  match first_child_named(wpc, "bg") {
    Some(bg) =>
      match first_child_named(bg, "solidFill") {
        Some(sf) =>
          match first_child_named(sf, "srgbClr") {
            Some(clr) =>
              match attr_value(clr, "val") {
                Some(v) =>
                  if v.length() == 6 {
                    children.push(
                      @markup.elem_ns(
                        "rect",
                        @markup.svg_ns,
                        [
                          @markup.attr("x", "0"),
                          @markup.attr("y", "0"),
                          @markup.attr("width", fmt_double(w_px)),
                          @markup.attr("height", fmt_double(h_px)),
                          @markup.attr("fill", "#" + v),
                        ],
                        [],
                      ),
                    )
                  }
                None => ()
              }
            None => ()
          }
        None => ()
      }
    None => ()
  }
  // §20.4.2.29 — canvas children are positioned in absolute EMU within
  // the canvas (914400 EMU = 96 px), so each `<a:xfrm>` `off`/`ext` maps
  // straight through `f`.  Shapes, pictures and nested groups are
  // dispatched through the shared `render_group_child_node`.
  for child in wpc.children {
    match child {
      Element(c) =>
        match child_xfrm_element(c) {
          Some(xfrm) => {
            let off = xfrm_pair(xfrm, "off", "x", "y")
            let ext = xfrm_pair(xfrm, "ext", "cx", "cy")
            match (off, ext) {
              (Some((off_x, off_y)), Some((ext_cx, ext_cy))) => {
                let rw = ext_cx * f
                let rh = ext_cy * f
                if rw > 0.0 && rh > 0.0 {
                  match
                    render_group_child_node(
                      c,
                      off_x * f,
                      off_y * f,
                      rw,
                      rh,
                      image_resolver,
                      warnings,
                    ) {
                    Some(node) => children.push(node)
                    None => ()
                  }
                }
              }
              _ => ()
            }
          }
          None => ()
        }
      _ => ()
    }
  }
  if children.length() == 0 {
    return None
  }
  let group : @xml.Element = {
    name: @markup.qname_ns("g", @markup.svg_ns),
    attributes: [
      @markup.attr("transform", "translate(0," + fmt_double(-h_px) + ")"),
    ],
    children,
  }
  Some({ group, width_px: w_px, ascent_px: h_px, descent_px: 0.0 })
}

///|
/// §21.1.2.1.1 default text-body insets (EMU): lIns / rIns = 91440
/// (0.1 in), tIns / bIns = 45720 (0.05 in).  EMU → px at 96 dpi:
/// 914400 EMU = 1 in = 96 px.
const TXBX_L_INS_PX : Double = 9.6

///|
const TXBX_T_INS_PX : Double = 4.8

///|
/// Lay out the `<wps:txbx>/<w:txbxContent>` paragraphs of `wsp` inside
/// the shape's `w_px`-wide text rectangle, returning one translated
/// `<g>` per paragraph stacked vertically from the top inset.  Returns
/// an empty array when the shape carries no text body.
fn build_textbox_body_nodes(
  wsp : @xml.Element,
  w_px : Double,
  warnings : Array[String],
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  let txbx = match first_child_named(wsp, "txbx") {
    Some(t) => t
    None => return out
  }
  let content = match first_child_named(txbx, "txbxContent") {
    Some(c) => c
    None => return out
  }
  // Resolve the body insets from `<wps:bodyPr>` when present, else the
  // §21.1.2.1.1 defaults.
  let (l_ins, t_ins) = textbox_insets(wsp)
  let inner_w = w_px - l_ins * 2.0
  if inner_w <= 0.0 {
    return out
  }
  // Text boxes rarely embed pictures / charts; resolve them to nothing
  // (the paragraph engine degrades gracefully, reserving space).
  let no_image : (String) -> ResolvedImage? = fn(_s) { None }
  let no_chart : (@xml.Element) -> @xml.Node? = fn(_e) { None }
  let mut cursor_y = t_ins
  for child in content.children {
    match child {
      Element(p) =>
        if p.name.local_name == "p" {
          let laid = layout_paragraph(p, inner_w, warnings, no_image, no_chart)
          let para_nodes = build_paragraph_nodes(laid, warnings)
          let g : @xml.Element = {
            name: @markup.qname_ns("g", @markup.svg_ns),
            attributes: [
              @markup.attr(
                "transform",
                "translate(" +
                fmt_double(l_ins) +
                "," +
                fmt_double(cursor_y) +
                ")",
              ),
            ],
            children: para_nodes,
          }
          out.push(@xml.Node::Element(g))
          cursor_y = cursor_y + laid.height
        }
      _ => ()
    }
  }
  out
}

///|
/// §21.1.2.1.1 `<wps:bodyPr lIns tIns>` — the text rectangle's left /
/// top insets in px, falling back to the spec defaults.  (rIns / bIns
/// mirror lIns / tIns for our symmetric inner-width estimate.)
fn textbox_insets(wsp : @xml.Element) -> (Double, Double) {
  match first_child_named(wsp, "bodyPr") {
    None => (TXBX_L_INS_PX, TXBX_T_INS_PX)
    Some(body_pr) => {
      let l = match attr_value(body_pr, "lIns") {
        Some(v) => emu_attr_to_px(v, TXBX_L_INS_PX)
        None => TXBX_L_INS_PX
      }
      let t = match attr_value(body_pr, "tIns") {
        Some(v) => emu_attr_to_px(v, TXBX_T_INS_PX)
        None => TXBX_T_INS_PX
      }
      (l, t)
    }
  }
}

///|
/// Parse an EMU integer attribute to px (914400 EMU = 96 px), or
/// `fallback` when the value does not parse.
fn emu_attr_to_px(raw : String, fallback : Double) -> Double {
  try @string.parse_double(raw) catch {
    _ => return fallback
  } noraise {
    emu => emu / 914400.0 * 96.0
  }
}

///|
/// Walk `<w:drawing>/<wp:inline|wp:anchor>/<a:graphic>/<a:graphicData
/// uri=".../wordprocessingShape">/<wps:wsp>` and return the shape body
/// element.  Returns `None` when the drawing's graphicData payload is
/// not a wordprocessing-shape.
fn drawing_wps_shape(drawing : @xml.Element) -> @xml.Element? {
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "graphic") {
            Some(g) =>
              match first_child_named(g, "graphicData") {
                Some(gd) => {
                  let uri = match attr_value(gd, "uri") {
                    Some(v) => v
                    None => ""
                  }
                  if uri == WPS_GRAPHIC_DATA_URI {
                    return first_child_named(gd, "wsp")
                  }
                }
                None => ()
              }
            None => ()
          }
        }
      _ => ()
    }
  }
  None
}

///|
/// §20.1.8.54 `<a:solidFill><a:srgbClr val="RRGGBB"/></a:solidFill>` —
/// pull a solid fill colour from a `<wps:spPr>`. Returns "#rrggbb"
/// when an `<a:solidFill>` with an `<a:srgbClr>` is present; falls back
/// to "#4f81bd" (PowerPoint default accent1) when the fill is absent —
/// matching Word's behaviour for an unstyled shape.
fn wps_solid_fill_hex(sp_pr : @xml.Element) -> String {
  match first_child_named(sp_pr, "solidFill") {
    Some(sf) =>
      match first_child_named(sf, "srgbClr") {
        Some(clr) =>
          match attr_value(clr, "val") {
            Some(v) => if v.length() == 6 { "#" + v } else { "#4f81bd" }
            None => "#4f81bd"
          }
        None =>
          // `<a:schemeClr>` and other colour variants are not resolved
          // here; fall back to the PowerPoint accent1 default so the
          // shape still paints rather than disappearing.
          "#4f81bd"
      }
    None => "#4f81bd"
  }
}

///|
/// §20.1.8.32 `<a:ln>` — pull the shape outline colour from a
/// `<wps:spPr>`. Returns `Some("#rrggbb")` when an `<a:ln>` contains
/// an `<a:solidFill><a:srgbClr>`, `None` when the shape has no
/// outline (`<a:noFill>` or no `<a:ln>` at all). This is the bare
/// minimum the inline-shape renderer needs; richer outline styling
/// (dash, cap, join) is left to the full DML pipeline.
fn wps_line_stroke_hex(sp_pr : @xml.Element) -> String? {
  match first_child_named(sp_pr, "ln") {
    None => None
    Some(ln) => {
      // §20.1.8.44 `<a:noFill>` directly under `<a:ln>` suppresses
      // the outline entirely.
      match first_child_named(ln, "noFill") {
        Some(_) => return None
        None => ()
      }
      match first_child_named(ln, "solidFill") {
        Some(sf) =>
          match first_child_named(sf, "srgbClr") {
            Some(clr) =>
              match attr_value(clr, "val") {
                Some(v) => if v.length() == 6 { Some("#" + v) } else { None }
                None => None
              }
            None => None
          }
        None => None
      }
    }
  }
}
