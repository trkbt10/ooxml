// §19 VML legacy graphics — inline renderer for `<w:drawing>`
// whose `<a:graphic>/<a:graphicData>` payload is a raw VML tree
// (predates DrawingML; e.g. `<v:shape>`, `<v:rect>`,
// `<v:line>`, `<v:oval>`, `<v:roundrect>`, `<v:arc>`,
// `<v:curve>`, `<v:polyline>`, `<v:group>`, `<v:image>`,
// `<v:imagedata>`, `<v:textbox>`, `<v:textpath>`,
// `<v:shapetype>`, `<v:extrusion>`, `<v:diagram>`).
//
// Mirrors `inline_shape.mbt`: builds a `MathPayload` carrying a
// self-contained SVG `<g>` for the VML subtree so the line
// emitter places it on the baseline (with the bottom edge
// touching the baseline so the graphic sits like a Word inline
// shape).  Returns `None` when no VML payload is present so the
// caller falls through to the whitespace placeholder.

///|
/// Attempt to build an inline-shape payload for a `<w:drawing>`
/// whose graphicData payload is a raw VML tree.  Walks
/// `<w:drawing>/<wp:inline|wp:anchor>/<a:graphic>/<a:graphicData>/(v:*)*`
/// and translates each VML child via `@vml.render_vml`.  Returns
/// `None` when no VML element is present.
fn build_inline_vml(drawing : @xml.Element) -> MathPayload? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let vml_children = collect_vml_children(drawing)
  if vml_children.length() == 0 {
    return None
  }
  let inner : Array[@xml.Node] = []
  for ve in vml_children {
    let nodes = @vml.render_vml_with_size(ve, w_px, h_px)
    for n in nodes {
      inner.push(n)
    }
  }
  if inner.length() == 0 {
    return None
  }
  // §20.4.2 baseline alignment — the shape is laid out with its
  // top-left at (0,0); when surfaced through the math payload the
  // renderer translates the group to (x_cursor, baseline).  We
  // shift up by `h_px` so the bottom edge lands on the baseline
  // (matches Word's inline-shape baseline alignment).
  let group : @xml.Element = {
    name: @markup.qname_ns("g", @markup.svg_ns),
    attributes: [
      @markup.attr("transform", "translate(0," + fmt_double(-h_px) + ")"),
      @markup.attr("class", "vml"),
    ],
    children: inner,
  }
  Some({ group, width_px: w_px, ascent_px: h_px, descent_px: 0.0 })
}

///|
/// Walk `<w:drawing>/<wp:inline|wp:anchor>/<a:graphic>/<a:graphicData>`
/// and collect every direct VML-namespaced child.  Returns an empty
/// array when the drawing does not host a VML payload.
fn collect_vml_children(drawing : @xml.Element) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in drawing.children {
    match child {
      Element(c) =>
        if c.name.local_name == "inline" || c.name.local_name == "anchor" {
          match first_child_named(c, "graphic") {
            Some(g) =>
              match first_child_named(g, "graphicData") {
                Some(gd) =>
                  for kid in gd.children {
                    match kid {
                      Element(ve) => {
                        let ns = ve.name.ns.unwrap_or("")
                        if ns == @vml.vml_ns || ns == @vml.vml_office_ns {
                          out.push(ve)
                        }
                      }
                      _ => ()
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
  out
}
