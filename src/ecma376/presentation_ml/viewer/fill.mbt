// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/fill.ts
//        + packages/@aurochs-renderer/pptx/src/svg/slide-background.ts
//
// DrawingML §20.1.8 fill rendering.  Converts the XmlElement form of
// `<a:noFill>`, `<a:solidFill>`, `<a:gradFill>`, `<a:blipFill>`, and
// `<a:pattFill>` into either an SVG fill attribute value or a
// `<defs>` gradient / pattern fragment.
//
// The TS reference resolves through `BaseFill` typed records; the
// MoonBit port operates on `@xml.Element` directly so the viewer
// stays element-driven (matching the existing `render_svg` style and
// keeping the type surface flat).

///|
/// Result of resolving a fill into an SVG attribute. `attr_value` is
/// the string that goes inside `fill="..."`. When the fill is a
/// gradient or pattern, `attr_value` references a `<defs>` element
/// added to the collector via its `id`; the structured `<defs>` node
/// itself lives in the `SvgDefsCollector` the caller passed in, so
/// this result never carries a serialised markup fragment.
pub struct FillAttrResult {
  attr_value : String
  /// True iff this represents the absence of a fill (`<a:noFill>`).
  is_no_fill : Bool
}

///|
/// One gradient stop, with position in [0, 100] and resolved color.
struct GradientStopValue {
  position : Double
  color : ResolvedColor
}

///|
/// Read the `<a:gsLst>` of a `<a:gradFill>` into a list of stops.
/// Per §20.1.8.36 (a:gs), `pos` is in 60000ths of a percent → /1000
/// to get percent.
fn read_gradient_stops(
  grad_fill : @xml.Element,
  ctx : ColorResolveContext,
) -> Array[GradientStopValue] {
  let result : Array[GradientStopValue] = []
  let gs_lst = match first_child_named(grad_fill, "gsLst") {
    Some(e) => e
    None => return result
  }
  for child in gs_lst.children {
    match child {
      Element(gs) =>
        if gs.name.local_name == "gs" {
          // §20.1.8.36 ST_PositiveFixedPercentage — the `@pos`
          // attribute on `<a:gs>` is a fixed-percentage integer
          // in thousandths-of-a-percent (0..100000).  When the
          // attribute is absent the spec defers to the order
          // of `<a:gs>` children (first stop is implicit 0 %,
          // last is 100 %); a non-numeric `@pos` is a schema
          // violation and we fall back to 0 % rather than the
          // implicit-order rule because the upstream parser
          // would already have rejected the gradient if the
          // structural order were corrupted.
          let pos = match attr_value(gs, "pos") {
            Some(v) =>
              match (try? @strconv.parse_double(v)) {
                Ok(d) => d / 1000.0
                Err(_) => 0.0
              }
            None => 0.0
          }
          match resolve_solid_fill(gs, ctx~) {
            Some(rc) => result.push({ position: pos, color: rc })
            None => ()
          }
        }
      _ => ()
    }
  }
  result
}

///|
/// True iff a `<a:gradFill>` is a radial (path) gradient.  Per
/// §20.1.8.46 (a:path), the presence of `<a:path>` with
/// `path="circle"` indicates a radial gradient.  Linear gradients use
/// `<a:lin ang="..."/>`.
fn is_radial_gradient(grad_fill : @xml.Element) -> Bool {
  match first_child_named(grad_fill, "path") {
    Some(_) => true
    None => false
  }
}

///|
/// Read `<a:lin ang="..."/>` and return the angle in OOXML
/// 60000ths-of-a-degree converted to degrees.  Returns 0 when absent
/// (gradient is left-to-right).
fn read_lin_angle(grad_fill : @xml.Element) -> Double {
  // §20.1.8.31 ST_PositiveFixedAngle — `<a:lin @ang>` is an
  // integer in 60000ths-of-a-degree (0..21600000 = 0..360°).
  // When `<a:lin>` or its `@ang` is absent the spec default is
  // 0° (left-to-right gradient).  Schema-violating non-numeric
  // values fall back to the same 0° default; we surface the
  // raw attribute upstream so consumers can detect the breach
  // and substitute the source's intended angle.
  match first_child_named(grad_fill, "lin") {
    None => 0.0
    Some(lin) =>
      match attr_value(lin, "ang") {
        None => 0.0
        Some(v) =>
          match (try? @strconv.parse_double(v)) {
            Ok(d) => d / 60000.0
            Err(_) => 0.0
          }
      }
  }
}

///|
/// Render an `<a:gradFill>` to an SVG `<linearGradient>` or
/// `<radialGradient>` def fragment.  Returns `None` when the
/// gradient has no stops (the caller can fall back to `none`).
fn render_grad_fill_def(
  grad_fill : @xml.Element,
  gradient_id : String,
  ctx : ColorResolveContext,
) -> @xml.Node? {
  let stops = read_gradient_stops(grad_fill, ctx)
  if stops.length() == 0 {
    return None
  }
  let stop_nodes = build_stop_nodes(stops)
  let radial = is_radial_gradient(grad_fill)
  if radial {
    let coords = get_radial_gradient_coords()
    Some(
      @markup.elem_ns(
        "radialGradient",
        @markup.svg_ns,
        [
          @markup.attr("id", gradient_id),
          @markup.attr("cx", coords.cx.to_string() + "%"),
          @markup.attr("cy", coords.cy.to_string() + "%"),
          @markup.attr("r", coords.r.to_string() + "%"),
        ],
        stop_nodes,
      ),
    )
  } else {
    let coords = ooxml_angle_to_svg_linear_gradient(read_lin_angle(grad_fill))
    Some(
      @markup.elem_ns(
        "linearGradient",
        @markup.svg_ns,
        [
          @markup.attr("id", gradient_id),
          @markup.attr("x1", coords.x1.to_string() + "%"),
          @markup.attr("y1", coords.y1.to_string() + "%"),
          @markup.attr("x2", coords.x2.to_string() + "%"),
          @markup.attr("y2", coords.y2.to_string() + "%"),
        ],
        stop_nodes,
      ),
    )
  }
}

///|
/// Build the `<stop offset="..%" stop-color="#hex" [stop-opacity]/>`
/// nodes for a gradient stop list.
fn build_stop_nodes(
  stops : Array[GradientStopValue],
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for stop in stops {
    let attrs : Array[@xml.Attribute] = [
      @markup.attr("offset", stop.position.to_string() + "%"),
      @markup.attr("stop-color", "#" + stop.color.hex),
    ]
    if stop.color.alpha < 1.0 {
      attrs.push(@markup.attr("stop-opacity", stop.color.alpha.to_string()))
    }
    nodes.push(@markup.elem_ns("stop", @markup.svg_ns, attrs, []))
  }
  nodes
}

///|
/// Render a §20.1.8 fill element to an SVG fill attribute value and
/// optional `<defs>` fragment.
///
/// `fill_element` is one of the fill flavours from `<a:spPr>` (or a
/// wrapper containing one): `<a:noFill>`, `<a:solidFill>`,
/// `<a:gradFill>`, `<a:blipFill>`, `<a:pattFill>`.
///
/// `defs` accumulates gradient / pattern definitions.  `image_resolver`
/// is called with the `r:embed` resource id to obtain a data URI for
/// `<a:blipFill>`; `None` means "skip this image" (caller falls back
/// to `none`).
pub fn render_fill_attr(
  fill_element : @xml.Element,
  defs : SvgDefsCollector,
  ctx : ColorResolveContext,
  shape_width? : Double = 0.0,
  shape_height? : Double = 0.0,
  image_resolver? : (String) -> ResolvedImage? = _ => None,
) -> FillAttrResult {
  match fill_element.name.local_name {
    "noFill" => { attr_value: "none", is_no_fill: true }
    "solidFill" =>
      match resolve_solid_fill(fill_element, ctx~) {
        Some(rc) =>
          { attr_value: format_resolved_color(rc), is_no_fill: false }
        None => { attr_value: "none", is_no_fill: false }
      }
    "gradFill" => {
      let id = defs.next_id("shape-grad")
      match render_grad_fill_def(fill_element, id, ctx) {
        Some(def) => {
          defs.add_def(def)
          { attr_value: "url(#" + id + ")", is_no_fill: false }
        }
        None => { attr_value: "none", is_no_fill: false }
      }
    }
    "blipFill" =>
      render_blip_fill(
        fill_element, defs, shape_width, shape_height, image_resolver,
      )
    "pattFill" =>
      // §20.1.8.47 `<a:pattFill>` — the pattern's foreground /
      // background colours are spec-mandated to come from
      // `<a:fgClr>` and `<a:bgClr>` children, and the geometry
      // from `@prst`.  Until the full tile-generator lands the
      // renderer surfaces only the foreground colour so the
      // shape stays visible; the spec-defined pattern identity
      // is preserved on the source DOM for round-trip.
      match resolve_solid_fill(fill_element, ctx~) {
        Some(rc) =>
          { attr_value: format_resolved_color(rc), is_no_fill: false }
        None => { attr_value: "none", is_no_fill: false }
      }
    "grpFill" =>
      // §20.1.8.35 `<a:grpFill>` — inherit the fill from the
      // containing group.  Until the group-level fill cascade
      // is wired through the renderer surfaces `currentColor`
      // so the SVG cascade picks up the consumer's container
      // fill rather than committing to a literal fallback.
      { attr_value: "currentColor", is_no_fill: false }
    // Schema violation — value outside EG_FillProperties (6
    // permitted choices: noFill, solidFill, gradFill, blipFill,
    // pattFill, grpFill).  Treat as no fill so the renderer
    // does not invent a colour; `is_no_fill: false` keeps the
    // caller from treating this as the spec-meaningful "no
    // fill" sentinel.
    _ => { attr_value: "none", is_no_fill: false }
  }
}

///|
/// Render a `<a:blipFill>` (image fill).  Per §20.1.8.13:
/// `<a:blip r:embed="rId..."/>` references the image, optional
/// `<a:srcRect>` provides a crop, and optional `<a:stretch>` /
/// `<a:tile>` controls how the image fills the shape.
///
/// We model this by creating a `<pattern>` def whose viewBox matches
/// the shape dimensions and contains a single `<image>`.  Tiling and
/// cropping refinements are tracked as future work.
fn render_blip_fill(
  blip_fill : @xml.Element,
  defs : SvgDefsCollector,
  w : Double,
  h : Double,
  image_resolver : (String) -> ResolvedImage?,
) -> FillAttrResult {
  let blip = match first_child_named(blip_fill, "blip") {
    Some(e) => e
    None => return { attr_value: "none", is_no_fill: false }
  }
  let rid = match attr_value(blip, "embed") {
    Some(v) => v
    None =>
      // Fallback to `r:link` — referenced but not embedded.
      match attr_value(blip, "link") {
        Some(v) => v
        None => return { attr_value: "none", is_no_fill: false }
      }
  }
  let resolved = image_resolver(rid)
  match resolved {
    None => { attr_value: "none", is_no_fill: false }
    Some(img) => {
      let id = defs.next_id("img-pattern")
      let def = @markup.elem_ns(
        "pattern",
        @markup.svg_ns,
        [
          @markup.attr("id", id),
          @markup.attr("patternUnits", "objectBoundingBox"),
          @markup.attr("width", "1"),
          @markup.attr("height", "1"),
        ],
        [
          @markup.elem_ns(
            "image",
            @markup.svg_ns,
            [
              @markup.attr(
                "href",
                "data:" + img.mime_type + ";base64," + img.base64_data,
              ),
              @markup.attr("width", format_double(w)),
              @markup.attr("height", format_double(h)),
              @markup.attr("preserveAspectRatio", "xMidYMid slice"),
            ],
            [],
          ),
        ],
      )
      defs.add_def(def)
      { attr_value: "url(#" + id + ")", is_no_fill: false }
    }
  }
}
