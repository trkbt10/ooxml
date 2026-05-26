// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/marker.ts
//
// SVG <marker> emission for line-end arrows.
//
// ECMA-376 references:
//   §20.1.8.38 (CT_LineEndProperties — shared by headEnd / tailEnd)
//   §20.1.10.33 ST_LineEndType   (none / triangle / stealth / diamond / oval / arrow)
//   §20.1.10.34 ST_LineEndWidth  (sm / med / lg)
//   §20.1.10.32 ST_LineEndLength (sm / med / lg)
//
// The reader-side typed CT_* / ST_* projections live under
// `src/ecma376/drawing_ml/`. This module operates on the raw `<a:ln>`
// child elements so it can be invoked inline from the SVG rendering
// pipeline without re-parsing the line element.  Marker elements are
// built as `@xml.Node` trees and serialised once by `@xml.write`.

///|
/// §20.1.10.34 ST_LineEndWidth — exactly three values: `sm`, `med`,
/// `lg`.  Mirrors the WIDTH_MULTIPLIER table at `marker.ts:31`.
/// Each value picks a stroke-width multiplier; the spec does not
/// pin exact ratios, so the values below match Word/PowerPoint's
/// own preview rendering.
fn width_multiplier(w : String) -> Double {
  match w {
    "sm" => 2.0
    "med" => 3.0
    "lg" => 5.0
    // Schema violation — value outside ST_LineEndWidth.  Default
    // to `med` per the spec's "implementation default" wording.
    _ => 3.0
  }
}

///|
/// §20.1.10.32 ST_LineEndLength — exactly three values: `sm`, `med`,
/// `lg`.  Mirrors LENGTH_MULTIPLIER at `marker.ts:47`.
fn length_multiplier(l : String) -> Double {
  match l {
    "sm" => 2.0
    "med" => 3.0
    "lg" => 5.0
    // Schema violation — value outside ST_LineEndLength.
    _ => 3.0
  }
}

///|
/// Build the deterministic marker id. Mirrors `generateMarkerId` in
/// `marker.ts:62`. Position is "head" or "tail"; the colour hex's `#`
/// is stripped to keep IDs valid.
fn marker_id(
  type_ : String,
  width : String,
  length : String,
  color_hex : String,
  position : String,
) -> String {
  let normalized_hex = if color_hex.length() > 0 &&
    color_hex.code_unit_at(0).to_int() == 35 {
    color_hex[1:].to_owned()
  } else {
    color_hex
  }
  "marker-" +
  position +
  "-" +
  type_ +
  "-" +
  width +
  "-" +
  length +
  "-" +
  normalized_hex
}

///|
/// `<polygon points="..." fill="..."/>`. Used by triangle / stealth /
/// diamond / arrow (filled).
fn polygon_filled(points : String, fill : String) -> @xml.Node {
  @markup.elem_ns(
    "polygon",
    @markup.svg_ns,
    [@markup.attr("points", points), @markup.attr("fill", fill)],
    [],
  )
}

///|
/// `<polyline points="..." fill="none" stroke="..." stroke-width="..."
/// stroke-linejoin="miter"/>`. Used by the open `arrow` marker.
fn polyline_open(
  points : String,
  color : String,
  stroke_width : Double,
) -> @xml.Node {
  @markup.elem_ns(
    "polyline",
    @markup.svg_ns,
    [
      @markup.attr("points", points),
      @markup.attr("fill", "none"),
      @markup.attr("stroke", color),
      @markup.attr("stroke-width", format_double_for_filter(stroke_width)),
      @markup.attr("stroke-linejoin", "miter"),
    ],
    [],
  )
}

///|
/// `<ellipse cx="..." cy="..." rx="..." ry="..." fill="..."/>`. Used
/// by the oval marker.
fn ellipse_filled(
  cx : Double,
  cy : Double,
  rx : Double,
  ry : Double,
  fill : String,
) -> @xml.Node {
  @markup.elem_ns(
    "ellipse",
    @markup.svg_ns,
    [
      @markup.attr("cx", format_double_for_filter(cx)),
      @markup.attr("cy", format_double_for_filter(cy)),
      @markup.attr("rx", format_double_for_filter(rx)),
      @markup.attr("ry", format_double_for_filter(ry)),
      @markup.attr("fill", fill),
    ],
    [],
  )
}

///|
/// Triangle arrow shape. Mirrors `generateTriangleShape` in
/// `marker.ts:77` — three points forming a filled right-pointing
/// triangle.
fn shape_triangle(width : Double, height : Double, color : String) -> @xml.Node {
  let points = "0,0 " +
    format_double_for_filter(width) +
    "," +
    format_double_for_filter(height / 2.0) +
    " 0," +
    format_double_for_filter(height)
  polygon_filled(points, color)
}

///|
/// Stealth (notched) arrow shape. Mirrors `generateStealthShape` in
/// `marker.ts:90`. The notch depth is fixed at 30% of the marker
/// width per the TS implementation.
fn shape_stealth(width : Double, height : Double, color : String) -> @xml.Node {
  let notch_depth = width * 0.3
  let points = "0,0 " +
    format_double_for_filter(width) +
    "," +
    format_double_for_filter(height / 2.0) +
    " 0," +
    format_double_for_filter(height) +
    " " +
    format_double_for_filter(notch_depth) +
    "," +
    format_double_for_filter(height / 2.0)
  polygon_filled(points, color)
}

///|
/// Diamond shape. Mirrors `generateDiamondShape` in `marker.ts:105` —
/// four cardinal-direction points.
fn shape_diamond(width : Double, height : Double, color : String) -> @xml.Node {
  let points = format_double_for_filter(width / 2.0) +
    ",0 " +
    format_double_for_filter(width) +
    "," +
    format_double_for_filter(height / 2.0) +
    " " +
    format_double_for_filter(width / 2.0) +
    "," +
    format_double_for_filter(height) +
    " 0," +
    format_double_for_filter(height / 2.0)
  polygon_filled(points, color)
}

///|
/// Oval shape. Mirrors `generateOvalShape` in `marker.ts:118` —
/// filled ellipse centred on the marker box.
fn shape_oval(width : Double, height : Double, color : String) -> @xml.Node {
  ellipse_filled(width / 2.0, height / 2.0, width / 2.0, height / 2.0, color)
}

///|
/// Open arrow shape. Mirrors `generateArrowShape` in `marker.ts:135`.
/// The TS code multiplies the input stroke width by 0.5 to keep the
/// arrowhead stroke visually balanced against the line.
fn shape_arrow(
  width : Double,
  height : Double,
  color : String,
  stroke_width : Double,
) -> @xml.Node {
  let points = "0,0 " +
    format_double_for_filter(width) +
    "," +
    format_double_for_filter(height / 2.0) +
    " 0," +
    format_double_for_filter(height)
  polyline_open(points, color, stroke_width * 0.5)
}

///|
/// Generate the body shape for a given line-end type. Mirrors
/// `generateShapeForType` in `marker.ts:170`. Returns `None` for
/// `none` and unknown types so callers can skip emitting a marker
/// definition entirely.
fn shape_for_type(
  type_ : String,
  marker_width : Double,
  marker_height : Double,
  color_hex : String,
  stroke_width : Double,
) -> @xml.Node? {
  // §20.1.10.33 ST_LineEndType — exactly 6 values:
  //   none, triangle, stealth, diamond, oval, arrow.
  // `none` is filtered upstream so it returns `None` (no marker
  // emission).  Any value outside the enum is a schema violation
  // and also returns `None` — we do not invent a substitute shape.
  match type_ {
    "none" => None
    "triangle" => Some(shape_triangle(marker_width, marker_height, color_hex))
    "stealth" => Some(shape_stealth(marker_width, marker_height, color_hex))
    "diamond" => Some(shape_diamond(marker_width, marker_height, color_hex))
    "oval" => Some(shape_oval(marker_width, marker_height, color_hex))
    "arrow" =>
      Some(shape_arrow(marker_width, marker_height, color_hex, stroke_width))
    // Schema violation — value outside ST_LineEndType.
    _ => None
  }
}

///|
/// Build a `<marker>` definition node. Mirrors the `marker(...)`
/// primitive invocation at `marker.ts:235`.
fn marker_def(
  id : String,
  marker_width : Double,
  marker_height : Double,
  ref_x : Double,
  ref_y : Double,
  body : @xml.Node,
) -> @xml.Node {
  @markup.elem_ns(
    "marker",
    @markup.svg_ns,
    [
      @markup.attr("id", id),
      @markup.attr("markerWidth", format_double_for_filter(marker_width)),
      @markup.attr("markerHeight", format_double_for_filter(marker_height)),
      @markup.attr("refX", format_double_for_filter(ref_x)),
      @markup.attr("refY", format_double_for_filter(ref_y)),
      @markup.attr("orient", "auto"),
      @markup.attr("markerUnits", "userSpaceOnUse"),
    ],
    [body],
  )
}

///|
/// Build one marker definition node + url() reference for a given
/// line-end element. Returns `(None, "")` when the element is absent,
/// has `@type="none"`, or its type is unsupported. Mirrors the body
/// of `generateMarkerDef` + `generate{Head,Tail}MarkerResult` in
/// `marker.ts:213..295`.
///
/// Side-effect: the caller is responsible for pushing the returned
/// definition into the slide's `<defs>` collector.
fn build_marker(
  line_end : @xml.Element?,
  position : String,
  stroke_width : Double,
  color_hex : String,
) -> (@xml.Node?, String) {
  match line_end {
    None => (None, "")
    Some(elt) => {
      let type_ = match attr_value(elt, "type") {
        Some(v) => v
        None => "none"
      }
      if type_ == "none" {
        return (None, "")
      }
      let width = match attr_value(elt, "w") {
        Some(v) => v
        None => "med"
      }
      let length = match attr_value(elt, "len") {
        Some(v) => v
        None => "med"
      }
      let marker_width = stroke_width * width_multiplier(width)
      let marker_height = stroke_width * length_multiplier(length)
      let body = match
        shape_for_type(
          type_, marker_width, marker_height, color_hex, stroke_width,
        ) {
        None => return (None, "")
        Some(b) => b
      }
      let id = marker_id(type_, width, length, color_hex, position)
      // refX: tail → tip of marker, head → origin (line starts from tip).
      let ref_x = if position == "tail" { marker_width } else { 0.0 }
      let ref_y = marker_height / 2.0
      let def = marker_def(id, marker_width, marker_height, ref_x, ref_y, body)
      (Some(def), "url(#" + id + ")")
    }
  }
}

///|
/// Emission result for an `<a:ln>`'s head/tail markers. Mirrors the
/// `MarkerCollection` record at `marker.ts:258`.  Each field is the
/// structured `marker-start` / `marker-end` attribute list (empty
/// when the corresponding end is absent); callers thread the
/// attributes straight onto the line element rather than serialising
/// an intermediate string fragment.
pub struct LineMarkerEmission {
  marker_start_attrs : Array[@xml.Attribute]
  marker_end_attrs : Array[@xml.Attribute]
}

///|
/// Build the marker attribute payload for a `<a:ln>` element and push
/// any required `<marker>` definitions into `defs`. Mirrors
/// `generateLineMarkers` in `marker.ts:306`.
///
/// `stroke_width_px` is the resolved stroke width in user units (the
/// caller has already converted from EMU). `color_hex` is the
/// resolved colour string passed straight through to fill/stroke
/// attributes.
pub fn build_line_marker_attrs(
  line : @xml.Element,
  stroke_width_px : Double,
  color_hex : String,
  defs : SvgDefsCollector,
) -> LineMarkerEmission {
  let head_end = first_child_named(line, "headEnd")
  let tail_end = first_child_named(line, "tailEnd")
  let (head_def, head_url) = build_marker(
    head_end, "head", stroke_width_px, color_hex,
  )
  let (tail_def, tail_url) = build_marker(
    tail_end, "tail", stroke_width_px, color_hex,
  )
  match head_def {
    Some(d) => defs.add_def(d)
    None => ()
  }
  match tail_def {
    Some(d) => defs.add_def(d)
    None => ()
  }
  let marker_start_attrs : Array[@xml.Attribute] = if head_url == "" {
    []
  } else {
    [@markup.attr("marker-start", head_url)]
  }
  let marker_end_attrs : Array[@xml.Attribute] = if tail_url == "" {
    []
  } else {
    [@markup.attr("marker-end", tail_url)]
  }
  { marker_start_attrs, marker_end_attrs }
}
