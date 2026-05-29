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
  for node in build_textbox_body_nodes(wsp, w_px) {
    children.push(node)
  }
  Some(children)
}

///|
fn build_inline_shape(drawing : @xml.Element) -> MathPayload? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let wsp = match drawing_wps_shape(drawing) {
    Some(s) => s
    None => return None
  }
  let children = match wsp_shape_nodes(wsp, w_px, h_px) {
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
/// §20.1.2.2.20 `<wpg:wgp>` — render a WordprocessingGroup of shapes.
/// The group's child coordinate space is defined by
/// `<wpg:grpSpPr>/<a:xfrm>` `chOff` / `chExt`; each child `<wps:wsp>`
/// carries its own `<a:xfrm>` `off` / `ext` in that space, which we map
/// into the group's rendered `w_px` × `h_px` box and render via
/// `wsp_shape_nodes`.  Nested groups and pictures are not yet walked
/// (a child without a resolvable shape geometry is simply skipped);
/// shape children — the common case — paint at their mapped positions.
fn build_inline_group(drawing : @xml.Element) -> MathPayload? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let wgp = match drawing_wpg_group(drawing) {
    Some(g) => g
    None => return None
  }
  let grp_sp_pr = match first_child_named(wgp, "grpSpPr") {
    Some(s) => s
    None => return None
  }
  let xfrm = match first_child_named(grp_sp_pr, "xfrm") {
    Some(x) => x
    None => return None
  }
  // Child coordinate space: chOff (origin) + chExt (extent).  Without
  // both we cannot map child positions, so bail to a later renderer.
  let (ch_off_x, ch_off_y) = match xfrm_pair(xfrm, "chOff", "x", "y") {
    Some(p) => p
    None => return None
  }
  let (ch_ext_cx, ch_ext_cy) = match xfrm_pair(xfrm, "chExt", "cx", "cy") {
    Some(p) => p
    None => return None
  }
  if ch_ext_cx <= 0.0 || ch_ext_cy <= 0.0 {
    return None
  }
  let sx = w_px / ch_ext_cx
  let sy = h_px / ch_ext_cy
  let children : Array[@xml.Node] = []
  for child in wgp.children {
    match child {
      Element(c) =>
        if c.name.local_name == "wsp" {
          // Child shape position / size in the group's child space.
          let c_sp_pr = match first_child_named(c, "spPr") {
            Some(s) => s
            None => continue
          }
          let c_xfrm = match first_child_named(c_sp_pr, "xfrm") {
            Some(x) => x
            None => continue
          }
          let (off_x, off_y) = match xfrm_pair(c_xfrm, "off", "x", "y") {
            Some(p) => p
            None => continue
          }
          let (ext_cx, ext_cy) = match xfrm_pair(c_xfrm, "ext", "cx", "cy") {
            Some(p) => p
            None => continue
          }
          let rx = (off_x - ch_off_x) * sx
          let ry = (off_y - ch_off_y) * sy
          let rw = ext_cx * sx
          let rh = ext_cy * sy
          if rw <= 0.0 || rh <= 0.0 {
            continue
          }
          match wsp_shape_nodes(c, rw, rh) {
            Some(nodes) => {
              let g : @xml.Element = {
                name: @markup.qname_ns("g", @markup.svg_ns),
                attributes: [
                  @markup.attr(
                    "transform",
                    "translate(" + fmt_double(rx) + "," + fmt_double(ry) + ")",
                  ),
                ],
                children: nodes,
              }
              children.push(@xml.Node::Element(g))
            }
            None => ()
          }
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
fn build_inline_canvas(drawing : @xml.Element) -> MathPayload? {
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
                      @markup.elem_ns("rect", @markup.svg_ns, [
                        @markup.attr("x", "0"),
                        @markup.attr("y", "0"),
                        @markup.attr("width", fmt_double(w_px)),
                        @markup.attr("height", fmt_double(h_px)),
                        @markup.attr("fill", "#" + v),
                      ], []),
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
  for child in wpc.children {
    match child {
      Element(c) =>
        if c.name.local_name == "wsp" {
          let c_sp_pr = match first_child_named(c, "spPr") {
            Some(s) => s
            None => continue
          }
          let c_xfrm = match first_child_named(c_sp_pr, "xfrm") {
            Some(x) => x
            None => continue
          }
          let (off_x, off_y) = match xfrm_pair(c_xfrm, "off", "x", "y") {
            Some(p) => p
            None => continue
          }
          let (ext_cx, ext_cy) = match xfrm_pair(c_xfrm, "ext", "cx", "cy") {
            Some(p) => p
            None => continue
          }
          let rw = ext_cx * f
          let rh = ext_cy * f
          if rw <= 0.0 || rh <= 0.0 {
            continue
          }
          match wsp_shape_nodes(c, rw, rh) {
            Some(nodes) => {
              let g : @xml.Element = {
                name: @markup.qname_ns("g", @markup.svg_ns),
                attributes: [
                  @markup.attr(
                    "transform",
                    "translate(" +
                    fmt_double(off_x * f) +
                    "," +
                    fmt_double(off_y * f) +
                    ")",
                  ),
                ],
                children: nodes,
              }
              children.push(@xml.Node::Element(g))
            }
            None => ()
          }
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
          let laid = layout_paragraph(p, inner_w, no_image, no_chart)
          let para_nodes = build_paragraph_nodes(laid)
          let g : @xml.Element = {
            name: @markup.qname_ns("g", @markup.svg_ns),
            attributes: [
              @markup.attr(
                "transform",
                "translate(" + fmt_double(l_ins) + "," + fmt_double(cursor_y) + ")",
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
