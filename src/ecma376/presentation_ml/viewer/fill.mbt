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
priv struct GradientStopValue {
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
              try @string.parse_double(v) catch {
                _ => 0.0
              } noraise {
                d => d / 1000.0
              }
            None => 0.0
          }
          match @paint.resolve_solid_fill(gs, ctx~) {
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
/// §20.1.8.46 (a:path) / §20.1.8.30 (a:fillToRect) — read the radial
/// gradient focus from `<a:path>/<a:fillToRect l t r b>` (edge margins
/// as percentages) and return the gradient centre via
/// `fill_to_rect_to_radial_center`.  Returns `None` when the path
/// carries no `<a:fillToRect>` (the spec default centred radial), so
/// the caller keeps the 50%/50% default.
fn read_radial_fill_center(grad_fill : @xml.Element) -> (Double, Double)? {
  match first_child_named(grad_fill, "path") {
    None => None
    Some(path_el) =>
      match first_child_named(path_el, "fillToRect") {
        None => None
        Some(ftr) => {
          let l = parse_st_positive_fixed_percentage(attr_value(ftr, "l"))
          let t = parse_st_positive_fixed_percentage(attr_value(ftr, "t"))
          let r = parse_st_positive_fixed_percentage(attr_value(ftr, "r"))
          let b = parse_st_positive_fixed_percentage(attr_value(ftr, "b"))
          Some(fill_to_rect_to_radial_center(l, t, r, b))
        }
      }
  }
}

///|
/// §20.1.8.56 `<a:tileRect>` — optional gradient tile rectangle.
/// The l/t/r/b insets are percentages of the shape box; defaults are
/// zero. Returns `None` when no tile rectangle is authored.
fn read_gradient_tile_rect(
  grad_fill : @xml.Element,
) -> (Double, Double, Double, Double)? {
  match first_child_named(grad_fill, "tileRect") {
    None => None
    Some(rect) => {
      let l = parse_st_positive_fixed_percentage(attr_value(rect, "l"))
      let t = parse_st_positive_fixed_percentage(attr_value(rect, "t"))
      let r = parse_st_positive_fixed_percentage(attr_value(rect, "r"))
      let b = parse_st_positive_fixed_percentage(attr_value(rect, "b"))
      Some((l, t, r, b))
    }
  }
}

///|
fn tile_rect_axis(start : Double, end_ : Double, p : Double) -> Double {
  start + (end_ - start) * (p / 100.0)
}

///|
fn tile_rect_visible_extent(a : Double, b : Double) -> Double {
  let extent = 100.0 - a - b
  if extent < 0.001 {
    0.001
  } else {
    extent
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
          try @string.parse_double(v) catch {
            _ => 0.0
          } noraise {
            d => d / 60000.0
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
  let tile_rect = read_gradient_tile_rect(grad_fill)
  if radial {
    // §20.1.8.46 (a:path) / §20.1.8.30 (a:fillToRect) — honour the
    // gradient focus rectangle so an off-centre radial (e.g. a
    // top-left highlight) renders at its true centre instead of the
    // 50%/50% default.  Matches the text-fill path
    // (`resolve_text_gradient_fill`).
    let coords = get_radial_gradient_coords(
      radial_center=read_radial_fill_center(grad_fill),
    )
    let attrs : Array[@xml.Attribute] = []
    let mut cx = coords.cx
    let mut cy = coords.cy
    let mut radius = coords.r
    match tile_rect {
      Some((l, t, r, b)) => {
        let right = 100.0 - r
        let bottom = 100.0 - b
        cx = tile_rect_axis(l, right, cx)
        cy = tile_rect_axis(t, bottom, cy)
        let ex = tile_rect_visible_extent(l, r)
        let ey = tile_rect_visible_extent(t, b)
        let scale = if ex < ey { ex } else { ey }
        radius = radius * (scale / 100.0)
        attrs.push(@markup.attr("spreadMethod", "repeat"))
        attrs.push(
          @markup.attr(
            "data-ooxml-tile-rect",
            l.to_string() +
            " " +
            t.to_string() +
            " " +
            r.to_string() +
            " " +
            b.to_string(),
          ),
        )
      }
      None => ()
    }
    attrs.push(@markup.attr("id", gradient_id))
    attrs.push(@markup.attr("cx", cx.to_string() + "%"))
    attrs.push(@markup.attr("cy", cy.to_string() + "%"))
    attrs.push(@markup.attr("r", radius.to_string() + "%"))
    Some(@markup.elem_ns("radialGradient", @markup.svg_ns, attrs, stop_nodes))
  } else {
    let coords = ooxml_angle_to_svg_linear_gradient(read_lin_angle(grad_fill))
    let attrs : Array[@xml.Attribute] = []
    let mut x1 = coords.x1
    let mut y1 = coords.y1
    let mut x2 = coords.x2
    let mut y2 = coords.y2
    match tile_rect {
      Some((l, t, r, b)) => {
        let right = 100.0 - r
        let bottom = 100.0 - b
        x1 = tile_rect_axis(l, right, x1)
        y1 = tile_rect_axis(t, bottom, y1)
        x2 = tile_rect_axis(l, right, x2)
        y2 = tile_rect_axis(t, bottom, y2)
        attrs.push(@markup.attr("spreadMethod", "repeat"))
        attrs.push(
          @markup.attr(
            "data-ooxml-tile-rect",
            l.to_string() +
            " " +
            t.to_string() +
            " " +
            r.to_string() +
            " " +
            b.to_string(),
          ),
        )
      }
      None => ()
    }
    attrs.push(@markup.attr("id", gradient_id))
    attrs.push(@markup.attr("x1", x1.to_string() + "%"))
    attrs.push(@markup.attr("y1", y1.to_string() + "%"))
    attrs.push(@markup.attr("x2", x2.to_string() + "%"))
    attrs.push(@markup.attr("y2", y2.to_string() + "%"))
    Some(@markup.elem_ns("linearGradient", @markup.svg_ns, attrs, stop_nodes))
  }
}

///|
/// Build the `<stop offset="..%" stop-color="#hex" [stop-opacity]/>`
/// nodes for a gradient stop list.
fn build_stop_nodes(stops : Array[GradientStopValue]) -> Array[@xml.Node] {
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
/// Resolve the `<a:fgClr>` / `<a:bgClr>` colour of an `<a:pattFill>`.
/// Each is a wrapper carrying one EG_ColorChoice element; returns the
/// CSS colour string or the supplied fallback when absent.
fn patt_fill_color(
  patt_fill : @xml.Element,
  child_local : String,
  fallback : String,
  ctx : ColorResolveContext,
) -> String {
  match first_child_named(patt_fill, child_local) {
    None => fallback
    Some(wrapper) =>
      match @paint.resolve_solid_fill(wrapper, ctx~) {
        Some(rc) => @paint.format_resolved_color(rc)
        None => fallback
      }
  }
}

///|
/// §20.1.10.51 — the percentage-density (`pct5` … `pct90`) preset
/// patterns map to a dot fraction in [0, 1]; `None` for any other
/// preset name.
fn pattern_pct_density(prst : String) -> Double? {
  match prst {
    "pct5" => Some(0.05)
    "pct10" => Some(0.1)
    "pct20" => Some(0.2)
    "pct25" => Some(0.25)
    "pct30" => Some(0.3)
    "pct40" => Some(0.4)
    "pct50" => Some(0.5)
    "pct60" => Some(0.6)
    "pct70" => Some(0.7)
    "pct75" => Some(0.75)
    "pct80" => Some(0.8)
    "pct90" => Some(0.9)
    _ => None
  }
}

///|
/// Build the geometry child nodes of a §20.1.8.47 pattern tile for a
/// recognised `@prst`. The tile is an 8×8 user-space cell; `fg` paints
/// the marks. Every §20.1.10.50 ST_PresetPatternVal value is mapped;
/// `None` is returned only for a schema-invalid / unknown preset name,
/// so the caller falls back to a flat foreground fill.
///
/// Covered families (the geometric basis of ST_PresetPatternVal):
///   - percentage dots (`pct5` … `pct90`)
///   - horizontal / vertical rules (`horz`, `vert`, `ltHorz`, `dkHorz`,
///     `ltVert`, `dkVert`, `narHorz`, `narVert`)
///   - diagonal rules (`ltDnDiag`, `ltUpDiag`, `dkDnDiag`, `dkUpDiag`,
///     `wdDnDiag`, `wdUpDiag`)
///   - cross-hatch (`cross`, `diagCross`)
///   - grids / checks (`smGrid`, `lgGrid`, `dotGrid`, `smCheck`,
///     `lgCheck`)
fn pattern_tile_marks(prst : String, fg : String) -> Array[@xml.Node]? {
  fn line(x1 : Double, y1 : Double, x2 : Double, y2 : Double, w : Double) {
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", x1.to_string()),
        @markup.attr("y1", y1.to_string()),
        @markup.attr("x2", x2.to_string()),
        @markup.attr("y2", y2.to_string()),
        @markup.attr("stroke", fg),
        @markup.attr("stroke-width", w.to_string()),
      ],
      [],
    )
  }

  fn dot(cx : Double, cy : Double, r : Double) {
    @markup.elem_ns(
      "circle",
      @markup.svg_ns,
      [
        @markup.attr("cx", cx.to_string()),
        @markup.attr("cy", cy.to_string()),
        @markup.attr("r", r.to_string()),
        @markup.attr("fill", fg),
      ],
      [],
    )
  }

  fn dline(x1 : Double, y1 : Double, x2 : Double, y2 : Double) {
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", x1.to_string()),
        @markup.attr("y1", y1.to_string()),
        @markup.attr("x2", x2.to_string()),
        @markup.attr("y2", y2.to_string()),
        @markup.attr("stroke", fg),
        @markup.attr("stroke-width", "1"),
        @markup.attr("stroke-dasharray", "3 3"),
      ],
      [],
    )
  }

  // Stroked open polyline / path (fg, no fill) for zig-zag / wave /
  // shingle presets.
  fn stroke_shape(tag : String, geom_attr : String, geom : String) {
    @markup.elem_ns(
      tag,
      @markup.svg_ns,
      [
        @markup.attr(geom_attr, geom),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", fg),
        @markup.attr("stroke-width", "1"),
      ],
      [],
    )
  }

  // Translucent foreground band (used to layer plaid stripes so the
  // crossings read darker, matching the woven look).
  fn band(x : Double, y : Double, w : Double, h : Double) {
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", x.to_string()),
        @markup.attr("y", y.to_string()),
        @markup.attr("width", w.to_string()),
        @markup.attr("height", h.to_string()),
        @markup.attr("fill", fg),
        @markup.attr("fill-opacity", "0.5"),
      ],
      [],
    )
  }

  // Percentage-density presets — a single centred dot whose radius
  // grows with the density fraction (area ∝ fraction over the 8×8
  // cell, capped so high percentages still read as a pattern).
  match pattern_pct_density(prst) {
    Some(frac) => {
      let r = (frac * 64.0 / 3.14159).sqrt().min(3.6)
      return Some([dot(4.0, 4.0, r)])
    }
    None => ()
  }
  match prst {
    // Horizontal rules — `lt`/`dk`/`nar` vary the stroke weight.
    "horz" | "ltHorz" => Some([line(0.0, 4.0, 8.0, 4.0, 1.0)])
    "dkHorz" => Some([line(0.0, 4.0, 8.0, 4.0, 2.5)])
    "narHorz" =>
      Some([line(0.0, 2.0, 8.0, 2.0, 1.0), line(0.0, 6.0, 8.0, 6.0, 1.0)])
    // Vertical rules.
    "vert" | "ltVert" => Some([line(4.0, 0.0, 4.0, 8.0, 1.0)])
    "dkVert" => Some([line(4.0, 0.0, 4.0, 8.0, 2.5)])
    "narVert" =>
      Some([line(2.0, 0.0, 2.0, 8.0, 1.0), line(6.0, 0.0, 6.0, 8.0, 1.0)])
    // Down-diagonal rules (top-left → bottom-right). Two extra
    // segments stitch the tile edges so the line is continuous when
    // the pattern repeats.
    "ltDnDiag" | "dnDiag" =>
      Some([
        line(0.0, 0.0, 8.0, 8.0, 1.0),
        line(-8.0, 0.0, 8.0, 16.0, 1.0),
        line(0.0, -8.0, 16.0, 8.0, 1.0),
      ])
    "dkDnDiag" | "wdDnDiag" =>
      Some([
        line(0.0, 0.0, 8.0, 8.0, 2.5),
        line(-8.0, 0.0, 8.0, 16.0, 2.5),
        line(0.0, -8.0, 16.0, 8.0, 2.5),
      ])
    // Up-diagonal rules (bottom-left → top-right).
    "ltUpDiag" | "upDiag" =>
      Some([
        line(0.0, 8.0, 8.0, 0.0, 1.0),
        line(-8.0, 8.0, 8.0, -8.0, 1.0),
        line(0.0, 16.0, 16.0, 0.0, 1.0),
      ])
    "dkUpDiag" | "wdUpDiag" =>
      Some([
        line(0.0, 8.0, 8.0, 0.0, 2.5),
        line(-8.0, 8.0, 8.0, -8.0, 2.5),
        line(0.0, 16.0, 16.0, 0.0, 2.5),
      ])
    // Cross-hatch — horizontal + vertical.
    "cross" | "smGrid" =>
      Some([line(0.0, 4.0, 8.0, 4.0, 1.0), line(4.0, 0.0, 4.0, 8.0, 1.0)])
    "lgGrid" =>
      Some([line(0.0, 0.0, 8.0, 0.0, 1.0), line(0.0, 0.0, 0.0, 8.0, 1.0)])
    // Diagonal cross-hatch.
    "diagCross" =>
      Some([
        line(0.0, 0.0, 8.0, 8.0, 1.0),
        line(-8.0, 0.0, 8.0, 16.0, 1.0),
        line(0.0, -8.0, 16.0, 8.0, 1.0),
        line(0.0, 8.0, 8.0, 0.0, 1.0),
        line(-8.0, 8.0, 8.0, -8.0, 1.0),
        line(0.0, 16.0, 16.0, 0.0, 1.0),
      ])
    // Dotted grid — a dot at each tile corner.
    "dotGrid" => Some([dot(0.0, 0.0, 1.0)])
    // Small / large checker — a filled quadrant.
    "smCheck" | "lgCheck" =>
      Some([
        @markup.elem_ns(
          "rect",
          @markup.svg_ns,
          [
            @markup.attr("x", "0"),
            @markup.attr("y", "0"),
            @markup.attr("width", "4"),
            @markup.attr("height", "4"),
            @markup.attr("fill", fg),
          ],
          [],
        ),
        @markup.elem_ns(
          "rect",
          @markup.svg_ns,
          [
            @markup.attr("x", "4"),
            @markup.attr("y", "4"),
            @markup.attr("width", "4"),
            @markup.attr("height", "4"),
            @markup.attr("fill", fg),
          ],
          [],
        ),
      ])
    // Dashed rules.
    "dashHorz" => Some([dline(0.0, 4.0, 8.0, 4.0)])
    "dashVert" => Some([dline(4.0, 0.0, 4.0, 8.0)])
    "dashDnDiag" => Some([dline(0.0, 0.0, 8.0, 8.0)])
    "dashUpDiag" => Some([dline(0.0, 8.0, 8.0, 0.0)])
    // Brick courses — a horizontal rule per row with staggered head
    // joints (vertical segments offset by half a tile between rows).
    "horzBrick" =>
      Some([
        line(0.0, 0.0, 8.0, 0.0, 1.0),
        line(0.0, 4.0, 8.0, 4.0, 1.0),
        line(0.0, 0.0, 0.0, 4.0, 1.0),
        line(4.0, 4.0, 4.0, 8.0, 1.0),
      ])
    "diagBrick" =>
      Some([
        line(0.0, 0.0, 8.0, 8.0, 1.0),
        line(-8.0, 0.0, 8.0, 16.0, 1.0),
        line(0.0, -8.0, 16.0, 8.0, 1.0),
        line(0.0, 8.0, 4.0, 4.0, 1.0),
      ])
    // Diamonds — a centred rotated square.
    "solidDmnd" => Some([patt_diamond_node(8.0, fg, true)])
    "openDmnd" => Some([patt_diamond_node(8.0, fg, false)])
    "dotDmnd" => Some([dot(4.0, 4.0, 1.0)])
    // Confetti — scattered dots; `lg` uses larger dots.
    "smConfetti" =>
      Some([
        dot(1.0, 1.0, 0.6),
        dot(5.0, 3.0, 0.6),
        dot(2.5, 6.0, 0.6),
        dot(6.5, 6.5, 0.6),
      ])
    "lgConfetti" =>
      Some([
        dot(1.0, 1.0, 1.0),
        dot(5.0, 3.0, 1.0),
        dot(2.5, 6.0, 1.0),
        dot(6.5, 6.5, 1.0),
      ])
    // Zig-zag — a triangular wave repeated across the tile.
    "zigZag" =>
      Some([stroke_shape("polyline", "points", "0,6 2,2 4,6 6,2 8,6")])
    // Wave — a smooth sinusoid (two quadratic segments).
    "wave" => Some([stroke_shape("path", "d", "M0,6 Q2,2 4,6 T8,6")])
    // Trellis — a dense diagonal lattice (both diagonals, plus the
    // half-offset diagonals so the cells are smaller than diagCross).
    "trellis" =>
      Some([
        line(0.0, 0.0, 8.0, 8.0, 1.0),
        line(0.0, 8.0, 8.0, 0.0, 1.0),
        line(0.0, 4.0, 4.0, 0.0, 1.0),
        line(4.0, 8.0, 8.0, 4.0, 1.0),
        line(0.0, 4.0, 4.0, 8.0, 1.0),
        line(4.0, 0.0, 8.0, 4.0, 1.0),
      ])
    // Weave — interlocking horizontal / vertical short segments
    // (basket weave).
    "weave" =>
      Some([
        line(0.0, 2.0, 4.0, 2.0, 1.0),
        line(4.0, 6.0, 8.0, 6.0, 1.0),
        line(6.0, 0.0, 6.0, 4.0, 1.0),
        line(2.0, 4.0, 2.0, 8.0, 1.0),
      ])
    // Plaid — overlapping translucent bands; the crossing region
    // reads darker like woven tartan.
    "plaid" => Some([band(0.0, 0.0, 8.0, 4.0), band(0.0, 0.0, 4.0, 8.0)])
    // Shingle — overlapping roof-tile arcs.
    "shingle" =>
      Some([
        stroke_shape("path", "d", "M0,8 Q4,3 8,8"),
        stroke_shape("path", "d", "M-4,4 Q0,-1 4,4"),
        stroke_shape("path", "d", "M4,4 Q8,-1 12,4"),
      ])
    // Divot — small chevron marks scattered over the tile.
    "divot" =>
      Some([
        stroke_shape("polyline", "points", "1,3 2,5 3,3"),
        stroke_shape("polyline", "points", "5,5 6,7 7,5"),
      ])
    // Sphere — a shaded ball (approximated by a filled disc).
    "sphere" => Some([dot(4.0, 4.0, 3.4)])
    _ => None
  }
}

///|
/// A diamond (rotated square) centred in a `size`×`size` pattern tile,
/// either filled or stroked-only (open), used by §20.1.8.47 pattern
/// fill presets `solidDmnd` / `openDmnd`.
fn patt_diamond_node(size : Double, color : String, filled : Bool) -> @xml.Node {
  let c = size / 2.0
  let s = size.to_string()
  let cs = c.to_string()
  let pts = "\{cs},0 \{s},\{cs} \{cs},\{s} 0,\{cs}"
  let attrs : Array[@xml.Attribute] = [@markup.attr("points", pts)]
  if filled {
    attrs.push(@markup.attr("fill", color))
  } else {
    attrs.push(@markup.attr("fill", "none"))
    attrs.push(@markup.attr("stroke", color))
    attrs.push(@markup.attr("stroke-width", "1"))
  }
  @markup.elem_ns("polygon", @markup.svg_ns, attrs, [])
}

///|
/// Render an `<a:pattFill>` to an SVG `<pattern>` def. Returns `None`
/// when `@prst` is absent or names a schema-invalid preset (every valid
/// ST_PresetPatternVal is mapped), so the caller falls back to a flat
/// foreground fill.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/fill.ts:100
fn render_patt_fill_def(
  patt_fill : @xml.Element,
  pattern_id : String,
  ctx : ColorResolveContext,
) -> @xml.Node? {
  let prst = match attr_value(patt_fill, "prst") {
    Some(v) => v
    None => return None
  }
  let fg = patt_fill_color(patt_fill, "fgClr", "#000000", ctx)
  let bg = patt_fill_color(patt_fill, "bgClr", "#ffffff", ctx)
  let marks = match pattern_tile_marks(prst, fg) {
    Some(m) => m
    None => return None
  }
  // The tile is an 8×8 user-space cell painted with the background
  // panel first, then the foreground marks.
  let children : Array[@xml.Node] = [
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", "0"),
        @markup.attr("y", "0"),
        @markup.attr("width", "8"),
        @markup.attr("height", "8"),
        @markup.attr("fill", bg),
      ],
      [],
    ),
  ]
  for m in marks {
    children.push(m)
  }
  Some(
    @markup.elem_ns(
      "pattern",
      @markup.svg_ns,
      [
        @markup.attr("id", pattern_id),
        @markup.attr("patternUnits", "userSpaceOnUse"),
        @markup.attr("width", "8"),
        @markup.attr("height", "8"),
      ],
      children,
    ),
  )
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
      match @paint.resolve_solid_fill(fill_element, ctx~) {
        Some(rc) =>
          { attr_value: @paint.format_resolved_color(rc), is_no_fill: false }
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
    "pattFill" => {
      // §20.1.8.47 `<a:pattFill>` — `@prst` (ST_PresetPatternVal,
      // §20.1.10.51) names the tile geometry; `<a:fgClr>` paints
      // the marks and `<a:bgClr>` the panel. Build an SVG
      // `<pattern>` def for the recognised geometry families; an
      // unmapped preset falls back to the foreground colour so the
      // shape still picks up the intended hue.
      let id = defs.next_id("shape-patt")
      match render_patt_fill_def(fill_element, id, ctx) {
        Some(def) => {
          defs.add_def(def)
          { attr_value: "url(#" + id + ")", is_no_fill: false }
        }
        None => {
          // Unmapped preset / missing `@prst` — fall back to the
          // `<a:fgClr>` colour so the shape still picks up the
          // pattern's intended hue rather than vanishing.
          let fg = patt_fill_color(fill_element, "fgClr", "none", ctx)
          { attr_value: fg, is_no_fill: false }
        }
      }
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
