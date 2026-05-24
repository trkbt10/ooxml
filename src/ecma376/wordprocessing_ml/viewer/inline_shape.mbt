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
fn build_inline_shape(drawing : @xml.Element) -> MathPayload? {
  let (w_px, h_px) = drawing_extent_size_px(drawing)
  if w_px <= 0.0 || h_px <= 0.0 {
    return None
  }
  let wsp = match drawing_wps_shape(drawing) {
    Some(s) => s
    None => return None
  }
  let sp_pr = match first_child_named(wsp, "spPr") {
    Some(s) => s
    None => return None
  }
  let prst_geom = match first_child_named(sp_pr, "prstGeom") {
    Some(p) => p
    None => return None
  }
  let path_d = match @pml_viewer.render_preset_geometry(prst_geom, w_px, h_px) {
    Some(d) => d
    None => return None
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
  let path_node : @xml.Node = @markup.elem_ns(
    "path",
    @markup.svg_ns,
    path_attrs,
    [],
  )
  // §20.4.2 — the shape is laid out with its top-left at (0,0); when
  // surfaced through the math payload the renderer translates the
  // group to (x_cursor, baseline). We shift the group up by `h_px` so
  // its bottom edge lands on the baseline (matching Word's
  // inline-shape baseline alignment).
  let group : @xml.Element = {
    name: @markup.qname_ns("g", @markup.svg_ns),
    attributes: [
      @markup.attr("transform", "translate(0," + fmt_double(-h_px) + ")"),
    ],
    children: [path_node],
  }
  Some({ group, width_px: w_px, ascent_px: h_px, descent_px: 0.0 })
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
