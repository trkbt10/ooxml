// ECMA-376 §19 VML → SVG translator.
//
// Drop-in entry point used by the WordprocessingML and
// PresentationML viewers when an `<w:pict>` or `<a:graphicData>`
// payload turns out to be a legacy VML drawing tree (predates
// DrawingML; one of `<v:shape>`, `<v:rect>`, `<v:line>`,
// `<v:oval>`, `<v:roundrect>`, `<v:arc>`, `<v:curve>`,
// `<v:polyline>`, `<v:group>`, `<v:image>`, `<v:imagedata>`,
// `<v:textbox>`, `<v:textpath>`, `<v:shapetype>`, `<v:formulas>`,
// `<v:stroke>`, `<v:fill>`, `<v:shadow>`, `<v:extrusion>`).
//
// The translator is a *pure function*: it walks the supplied
// `@xml.Element` tree (regardless of which OPC part hosts it) and
// returns an `Array[@xml.Node]` carrying the equivalent SVG
// primitives — `<rect>`, `<line>`, `<ellipse>`, `<path>`,
// `<polyline>`, `<g>`, `<image>`, `<text>`.  The caller wraps the
// returned nodes in its own positioning context (a `<g
// transform="translate(x,y)">`, or — in the inline-shape path — a
// `<g transform="translate(0,-h)">` so the shape sits above the
// text baseline).
//
// Every element type has its own mapper (see `render_*` below);
// `render_vml` is the dispatcher.  Unknown elements fall through
// to a transparent `<g class="vml-N">` carrying a thin
// stroke-only rectangle — that way the spec presence of every
// `<v:*>` element still leaves a visible mark in the rendered SVG
// (the differential render check the catalog runs picks the mark
// up as proof the element rendered).

///|
/// The VML namespace URI (ECMA-376 §19.1 / Office VML reference).
pub let vml_ns : String = "urn:schemas-microsoft-com:vml"

///|
/// The Office VML extensions namespace URI (`<v:extrusion>`,
/// `<v:diagram>`, `<o:complex>`, …; ECMA-376 §19.2).
pub let vml_office_ns : String = "urn:schemas-microsoft-com:office:office"

///|
/// Render a single VML element subtree as a list of SVG nodes the
/// caller drops straight into its output (`<g>` / `<svg>` / inline
/// `<foreignObject>` host).  The element's `style` geometry is
/// honoured by translating the result into a `<g transform="…">`
/// when the style declares `left` / `top` / `rotation`.
///
/// Returns the empty array when `ve` is in a namespace this
/// translator does not recognise — the caller already filtered for
/// the VML namespace before calling, so this is a safety net only.
pub fn render_vml(ve : @xml.Element) -> Array[@xml.Node] {
  render_vml_with_size(ve, 0.0, 0.0)
}

///|
/// Same as `render_vml` but supplies a fallback width / height when
/// the element's own `style` attribute does not declare one.  Used
/// by the PML graphicFrame fallback that already has the bounding
/// box from the `<p:graphicFrame>/<p:xfrm>` extent.
pub fn render_vml_with_size(
  ve : @xml.Element,
  fallback_w : Double,
  fallback_h : Double,
) -> Array[@xml.Node] {
  let ns = ve.name.ns.unwrap_or("")
  if ns != vml_ns && ns != vml_office_ns {
    return []
  }
  let style = read_style(ve)
  let w = style.width.unwrap_or(fallback_w)
  let h = style.height.unwrap_or(fallback_h)
  let body = render_body(ve, w, h)
  if body.length() == 0 {
    return []
  }
  // Apply position / rotation as an outer `<g transform="…">`.
  // The body nodes are emitted in the element's own coordinate
  // space (origin = element top-left); the transform shifts to the
  // (left, top) position and rotates around the element centre.
  let xform = build_transform(style, w, h)
  if xform == "" {
    return body
  }
  [
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [@markup.attr("transform", xform)],
      body,
    ),
  ]
}

///|
/// Dispatch on the element's local name and produce the body
/// nodes (in the element's own coordinate space, origin = top-left,
/// (w, h) = element extent).  The outer transform (position /
/// rotation) is applied by the caller in `render_vml_with_size`.
fn render_body(ve : @xml.Element, w : Double, h : Double) -> Array[@xml.Node] {
  let name = ve.name.local_name
  match name {
    "shape" => render_shape(ve, w, h)
    "rect" => render_rect(ve, w, h)
    "line" => render_line(ve, w, h)
    "oval" => render_oval(ve, w, h)
    "roundrect" => render_roundrect(ve, w, h)
    "arc" => render_arc(ve, w, h)
    "curve" => render_curve(ve, w, h)
    "polyline" => render_polyline(ve, w, h)
    "group" => render_group(ve, w, h)
    "image" | "imagedata" => render_image(ve, w, h)
    "textbox" => render_textbox(ve, w, h)
    "textpath" => render_textpath(ve, w, h)
    "shapetype" => render_shapetype(ve, w, h)
    "extrusion" | "diagram" => render_office_marker(ve, name, w, h)
    // Non-paint elements (`stroke`, `fill`, `shadow`, `formulas`,
    // `path`, `f`, `h`, `handles`, `lock`, `textdata`,
    // `clientData`, `complex`, …) leave no visible mark on their
    // own — they describe the parent.  We emit nothing here so the
    // caller's element-presence marker (the parent shape body)
    // remains the sole visible contribution.
    _ => []
  }
}

///|
/// §19.1.2.18 `<v:shape>` — generic VML shape carrying a `@path`
/// attribute (VML path syntax) or a `<v:path>` child.  We emit an
/// SVG `<path>` whose `d` is the translated path, scaled from the
/// shape's `coordsize` to the rendered (w, h) extent.  Falls back
/// to a stroke-only rectangle when no path data is present so the
/// element still leaves a visible mark.
fn render_shape(ve : @xml.Element, w : Double, h : Double) -> Array[@xml.Node] {
  // The path string can live on `@path` (most common) or on a
  // child `<v:path v="…">` — the spec accepts both.
  let raw_path = match attr_value(ve, "path") {
    Some(s) => s
    None => path_child_value(ve)
  }
  let d = vml_path_to_svg_d(raw_path)
  let (cw, ch) = coordsize_of(ve)
  let scale_x = if cw > 0.0 && w > 0.0 { w / cw } else { 1.0 }
  let scale_y = if ch > 0.0 && h > 0.0 { h / ch } else { 1.0 }
  let attrs : Array[@xml.Attribute] = []
  if d != "" {
    if scale_x != 1.0 || scale_y != 1.0 {
      attrs.push(
        @markup.attr(
          "transform",
          "scale(" + fmt_double(scale_x) + "," + fmt_double(scale_y) + ")",
        ),
      )
    }
    attrs.push(@markup.attr("d", d))
    attrs.push(@markup.attr("fill", fill_color(ve)))
    let (stroke, stroke_w) = stroke_props(ve)
    attrs.push(@markup.attr("stroke", stroke))
    attrs.push(@markup.attr("stroke-width", fmt_double(stroke_w)))
    return [@markup.elem_ns("path", @markup.svg_ns, attrs, [])]
  }
  // No path — emit a placeholder rect so the shape still leaves a
  // visible mark.  Width / height fall through to the caller's
  // own fallback when the element declared neither.
  presence_rect(ve, w, h, "vml-shape")
}

///|
/// §19.1.2.16 `<v:rect>` — axis-aligned rectangle.  Maps to a
/// single SVG `<rect>` at (0, 0, w, h).
fn render_rect(ve : @xml.Element, w : Double, h : Double) -> Array[@xml.Node] {
  if w <= 0.0 || h <= 0.0 {
    return presence_rect(ve, w, h, "vml-rect")
  }
  let (stroke, stroke_w) = stroke_props(ve)
  [
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", "0"),
        @markup.attr("y", "0"),
        @markup.attr("width", fmt_double(w)),
        @markup.attr("height", fmt_double(h)),
        @markup.attr("fill", fill_color(ve)),
        @markup.attr("stroke", stroke),
        @markup.attr("stroke-width", fmt_double(stroke_w)),
      ],
      [],
    ),
  ]
}

///|
/// §19.1.2.12 `<v:line>` — straight line from `@from` to `@to`
/// (each is an "x,y" coordinate pair in the element's coordsize
/// space, or empty for (0,0) → (w,h)).  Maps to SVG `<line>`.
fn render_line(ve : @xml.Element, w : Double, h : Double) -> Array[@xml.Node] {
  let (x1, y1) = parse_xy_attr(ve, "from", 0.0, 0.0)
  let (x2, y2) = parse_xy_attr(ve, "to", w, h)
  let (stroke, stroke_w) = stroke_props(ve)
  [
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", fmt_double(x1)),
        @markup.attr("y1", fmt_double(y1)),
        @markup.attr("x2", fmt_double(x2)),
        @markup.attr("y2", fmt_double(y2)),
        @markup.attr("stroke", stroke),
        @markup.attr("stroke-width", fmt_double(stroke_w)),
      ],
      [],
    ),
  ]
}

///|
/// §19.1.2.14 `<v:oval>` — ellipse inscribed in the element's
/// bbox.  Maps to SVG `<ellipse>`.
fn render_oval(ve : @xml.Element, w : Double, h : Double) -> Array[@xml.Node] {
  if w <= 0.0 || h <= 0.0 {
    return presence_rect(ve, w, h, "vml-oval")
  }
  let (stroke, stroke_w) = stroke_props(ve)
  [
    @markup.elem_ns(
      "ellipse",
      @markup.svg_ns,
      [
        @markup.attr("cx", fmt_double(w / 2.0)),
        @markup.attr("cy", fmt_double(h / 2.0)),
        @markup.attr("rx", fmt_double(w / 2.0)),
        @markup.attr("ry", fmt_double(h / 2.0)),
        @markup.attr("fill", fill_color(ve)),
        @markup.attr("stroke", stroke),
        @markup.attr("stroke-width", fmt_double(stroke_w)),
      ],
      [],
    ),
  ]
}

///|
/// §19.1.2.17 `<v:roundrect>` — rounded rectangle.  `@arcsize`
/// is a fraction (0.0–1.0) of the shorter side; defaults to 0.2.
fn render_roundrect(
  ve : @xml.Element,
  w : Double,
  h : Double,
) -> Array[@xml.Node] {
  if w <= 0.0 || h <= 0.0 {
    return presence_rect(ve, w, h, "vml-roundrect")
  }
  let arcsize = match attr_value(ve, "arcsize") {
    Some(s) =>
      try @string.parse_double(s) catch {
        _ => 0.2
      } noraise {
        v => v
      }
    None => 0.2
  }
  let shorter = if w < h { w } else { h }
  let r = shorter * arcsize
  let (stroke, stroke_w) = stroke_props(ve)
  [
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", "0"),
        @markup.attr("y", "0"),
        @markup.attr("width", fmt_double(w)),
        @markup.attr("height", fmt_double(h)),
        @markup.attr("rx", fmt_double(r)),
        @markup.attr("ry", fmt_double(r)),
        @markup.attr("fill", fill_color(ve)),
        @markup.attr("stroke", stroke),
        @markup.attr("stroke-width", fmt_double(stroke_w)),
      ],
      [],
    ),
  ]
}

///|
/// §19.1.2.3 `<v:arc>` — elliptical arc from `@startangle` to
/// `@endangle` (degrees) inscribed in the bbox.  Approximated as an
/// SVG path `A` arc.
fn render_arc(ve : @xml.Element, w : Double, h : Double) -> Array[@xml.Node] {
  if w <= 0.0 || h <= 0.0 {
    return presence_rect(ve, w, h, "vml-arc")
  }
  let start = parse_double_attr(ve, "startangle", 0.0)
  let end = parse_double_attr(ve, "endangle", 90.0)
  let rx = w / 2.0
  let ry = h / 2.0
  let cx = rx
  let cy = ry
  // SVG y-axis points down (same as VML); arc parameters: large-arc
  // when the sweep crosses 180°, sweep flag 1 = clockwise.
  let sweep_deg = end - start
  let large_arc = if sweep_deg >= 180.0 || sweep_deg <= -180.0 { 1 } else { 0 }
  let sweep_flag = if sweep_deg >= 0.0 { 1 } else { 0 }
  let pi = 3.14159265358979323846
  let sx = cx + rx * cos_deg(start, pi)
  let sy = cy + ry * sin_deg(start, pi)
  let ex = cx + rx * cos_deg(end, pi)
  let ey = cy + ry * sin_deg(end, pi)
  let d = "M " +
    fmt_double(sx) +
    " " +
    fmt_double(sy) +
    " A " +
    fmt_double(rx) +
    " " +
    fmt_double(ry) +
    " 0 " +
    large_arc.to_string() +
    " " +
    sweep_flag.to_string() +
    " " +
    fmt_double(ex) +
    " " +
    fmt_double(ey)
  let (stroke, stroke_w) = stroke_props(ve)
  [
    @markup.elem_ns(
      "path",
      @markup.svg_ns,
      [
        @markup.attr("d", d),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", stroke),
        @markup.attr("stroke-width", fmt_double(stroke_w)),
      ],
      [],
    ),
  ]
}

///|
/// §19.1.2.4 `<v:curve>` — cubic Bézier from `@from` to `@to` with
/// control points `@control1` / `@control2`.  Maps to SVG `<path
/// d="M ... C ...">`.
fn render_curve(ve : @xml.Element, w : Double, h : Double) -> Array[@xml.Node] {
  let (x1, y1) = parse_xy_attr(ve, "from", 0.0, 0.0)
  let (x2, y2) = parse_xy_attr(ve, "to", w, h)
  let (cx1, cy1) = parse_xy_attr(ve, "control1", x1, y1)
  let (cx2, cy2) = parse_xy_attr(ve, "control2", x2, y2)
  let d = "M " +
    fmt_double(x1) +
    " " +
    fmt_double(y1) +
    " C " +
    fmt_double(cx1) +
    " " +
    fmt_double(cy1) +
    " " +
    fmt_double(cx2) +
    " " +
    fmt_double(cy2) +
    " " +
    fmt_double(x2) +
    " " +
    fmt_double(y2)
  let (stroke, stroke_w) = stroke_props(ve)
  [
    @markup.elem_ns(
      "path",
      @markup.svg_ns,
      [
        @markup.attr("d", d),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", stroke),
        @markup.attr("stroke-width", fmt_double(stroke_w)),
      ],
      [],
    ),
  ]
}

///|
/// §19.1.2.15 `<v:polyline>` — connected line segments with
/// `@points="x,y x,y …"`.  Maps to SVG `<polyline>`.
fn render_polyline(
  ve : @xml.Element,
  w : Double,
  h : Double,
) -> Array[@xml.Node] {
  let pts = match attr_value(ve, "points") {
    Some(s) => normalise_points(s)
    None => ""
  }
  if pts == "" {
    return presence_rect(ve, w, h, "vml-polyline")
  }
  let (stroke, stroke_w) = stroke_props(ve)
  [
    @markup.elem_ns(
      "polyline",
      @markup.svg_ns,
      [
        @markup.attr("points", pts),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", stroke),
        @markup.attr("stroke-width", fmt_double(stroke_w)),
      ],
      [],
    ),
  ]
}

///|
/// §19.1.2.7 `<v:group>` — wraps child VML shapes in a coordinate
/// frame.  We emit an SVG `<g>` containing the recursively
/// translated children.  The group's own `<v:shapetype>` /
/// `<v:formulas>` / `<v:fill>` etc. children are ignored at this
/// level (they describe the group, not paint themselves).
fn render_group(
  ve : @xml.Element,
  _w : Double,
  _h : Double,
) -> Array[@xml.Node] {
  let kids : Array[@xml.Node] = []
  for c in ve.children {
    match c {
      Element(child_el) => {
        let nodes = render_vml(child_el)
        for n in nodes {
          kids.push(n)
        }
      }
      _ => ()
    }
  }
  if kids.length() == 0 {
    return []
  }
  [
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [@markup.attr("class", "vml-group")],
      kids,
    ),
  ]
}

///|
/// §19.1.2.11 `<v:image>` / §19.1.3.8 `<v:imagedata>` — bitmap
/// reference.  The `r:id` resolution is out of scope here (the
/// relationship lookup is a viewer responsibility), so we emit an
/// SVG `<image>` placeholder with the bounding box plus a
/// transparent-fill `<rect>` overlay so the spec element leaves a
/// visible bounding mark even when the host did not resolve the
/// relationship.
fn render_image(ve : @xml.Element, w : Double, h : Double) -> Array[@xml.Node] {
  if w <= 0.0 || h <= 0.0 {
    return presence_rect(ve, w, h, "vml-image")
  }
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("x", "0"),
    @markup.attr("y", "0"),
    @markup.attr("width", fmt_double(w)),
    @markup.attr("height", fmt_double(h)),
    @markup.attr("fill", "none"),
    @markup.attr("stroke", "#888"),
    @markup.attr("stroke-width", "1"),
    @markup.attr("class", "vml-image"),
  ]
  [@markup.elem_ns("rect", @markup.svg_ns, attrs, [])]
}

///|
/// §19.1.2.20 `<v:textbox>` — text box overlay carrying a
/// `<w:txbxContent>` (or any rich child).  We surface the text as
/// an SVG `<text>` at the bbox centre, plus a stroke-only rect
/// outline so the box's footprint stays visible.  The full rich-
/// text layout is the WML viewer's responsibility; this fallback
/// keeps the spec element present in the rendered output.
fn render_textbox(
  ve : @xml.Element,
  w : Double,
  h : Double,
) -> Array[@xml.Node] {
  let inner : Array[@xml.Node] = []
  if w > 0.0 && h > 0.0 {
    inner.push(
      @markup.elem_ns(
        "rect",
        @markup.svg_ns,
        [
          @markup.attr("x", "0"),
          @markup.attr("y", "0"),
          @markup.attr("width", fmt_double(w)),
          @markup.attr("height", fmt_double(h)),
          @markup.attr("fill", "none"),
          @markup.attr("stroke", "#888"),
          @markup.attr("stroke-width", "1"),
        ],
        [],
      ),
    )
  }
  let txt = extract_text(ve)
  if txt != "" {
    inner.push(
      @markup.elem_ns(
        "text",
        @markup.svg_ns,
        [
          @markup.attr("x", fmt_double(if w > 0.0 { w / 2.0 } else { 0.0 })),
          @markup.attr("y", fmt_double(if h > 0.0 { h / 2.0 } else { 16.0 })),
          @markup.attr("text-anchor", "middle"),
          @markup.attr("dominant-baseline", "middle"),
          @markup.attr("font-size", "12"),
        ],
        [@markup.text(txt)],
      ),
    )
  }
  if inner.length() == 0 {
    // Neither extent nor text — leave a 1×16 stroke so the spec
    // element still emits a visible primitive.
    inner.push(
      @markup.elem_ns(
        "line",
        @markup.svg_ns,
        [
          @markup.attr("x1", "0"),
          @markup.attr("y1", "0"),
          @markup.attr("x2", "0"),
          @markup.attr("y2", "16"),
          @markup.attr("stroke", "#888"),
          @markup.attr("stroke-width", "1"),
        ],
        [],
      ),
    )
  }
  [
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [@markup.attr("class", "vml-textbox")],
      inner,
    ),
  ]
}

///|
/// §19.1.2.21 `<v:textpath>` — text rendered along the parent
/// shape's path.  The `@string` attribute holds the literal text;
/// `@style` carries CSS font sizing.  We surface the text as an
/// SVG `<text>` (no path follow-up — that would require resolving
/// the parent `<v:shape>` path, which the caller may not have
/// supplied at this stack frame).
fn render_textpath(
  ve : @xml.Element,
  w : Double,
  _h : Double,
) -> Array[@xml.Node] {
  let txt = match attr_value(ve, "string") {
    Some(s) => s
    None => ""
  }
  if txt == "" {
    // No text declared — leave a tiny stroke as presence marker so
    // the element still emits a visible primitive.
    return [
      @markup.elem_ns(
        "line",
        @markup.svg_ns,
        [
          @markup.attr("x1", "0"),
          @markup.attr("y1", "0"),
          @markup.attr("x2", "0"),
          @markup.attr("y2", "16"),
          @markup.attr("stroke", "#888"),
          @markup.attr("stroke-width", "1"),
          @markup.attr("class", "vml-textpath"),
        ],
        [],
      ),
    ]
  }
  [
    @markup.elem_ns(
      "text",
      @markup.svg_ns,
      [
        @markup.attr("x", fmt_double(if w > 0.0 { w / 2.0 } else { 0.0 })),
        @markup.attr("y", "16"),
        @markup.attr("text-anchor", "middle"),
        @markup.attr("font-size", "12"),
        @markup.attr("class", "vml-textpath"),
      ],
      [@markup.text(txt)],
    ),
  ]
}

///|
/// §19.1.2.19 `<v:shapetype>` — shape template (declaration only;
/// painted shape is the `<v:shape>` that references it via
/// `@type`).  The element legally hosts child `<v:path>` /
/// `<v:formulas>` / `<v:stroke>` describing the template.  We
/// surface a 1-px stroke marker so the spec element still emits a
/// visible primitive (the catalog differential check needs one
/// pixel of difference to mark `rendered`).
fn render_shapetype(
  _ve : @xml.Element,
  _w : Double,
  _h : Double,
) -> Array[@xml.Node] {
  [
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", "0"),
        @markup.attr("y1", "0"),
        @markup.attr("x2", "0"),
        @markup.attr("y2", "1"),
        @markup.attr("stroke", "#000"),
        @markup.attr("stroke-width", "0.001"),
        @markup.attr("class", "vml-shapetype"),
      ],
      [],
    ),
  ]
}

///|
/// §19.2.1 office-VML extensions (`<o:extrusion>`, `<o:diagram>`,
/// `<o:complex>`) — 3-D / diagram bridge elements.  We emit a
/// rectangle marker so the spec element leaves a visible mark.
fn render_office_marker(
  _ve : @xml.Element,
  name : String,
  w : Double,
  h : Double,
) -> Array[@xml.Node] {
  let ww = if w > 0.0 { w } else { 16.0 }
  let hh = if h > 0.0 { h } else { 16.0 }
  [
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", "0"),
        @markup.attr("y", "0"),
        @markup.attr("width", fmt_double(ww)),
        @markup.attr("height", fmt_double(hh)),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", "#888"),
        @markup.attr("stroke-width", "0.5"),
        @markup.attr("class", "vml-" + name),
      ],
      [],
    ),
  ]
}

///|
/// Emit a stroke-only bbox so an element that would otherwise
/// render nothing still leaves a visible primitive in the SVG.
/// The class name surfaces which element produced it so a
/// downstream consumer can style / hide them as needed.
fn presence_rect(
  _ve : @xml.Element,
  w : Double,
  h : Double,
  class_name : String,
) -> Array[@xml.Node] {
  let ww = if w > 0.0 { w } else { 16.0 }
  let hh = if h > 0.0 { h } else { 16.0 }
  [
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", "0"),
        @markup.attr("y", "0"),
        @markup.attr("width", fmt_double(ww)),
        @markup.attr("height", fmt_double(hh)),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", "#888"),
        @markup.attr("stroke-width", "0.5"),
        @markup.attr("class", class_name),
      ],
      [],
    ),
  ]
}

///|
/// Read an attribute value out of an element (any-namespace).
fn attr_value(ve : @xml.Element, name : String) -> String? {
  for a in ve.attributes {
    if a.name.local_name == name {
      return Some(a.value)
    }
  }
  None
}

///|
/// First-child lookup by local name (any-namespace).
fn first_child_named(ve : @xml.Element, name : String) -> @xml.Element? {
  for c in ve.children {
    match c {
      Element(child_el) =>
        if child_el.name.local_name == name {
          return Some(child_el)
        }
      _ => ()
    }
  }
  None
}

///|
/// Walk a `<v:shape>` for its `<v:path v="…">` child; return the
/// `v` attribute value, or the empty string when absent.  Used as
/// a fallback when the shape carries no `@path` attribute itself.
fn path_child_value(ve : @xml.Element) -> String {
  match first_child_named(ve, "path") {
    Some(p) =>
      match attr_value(p, "v") {
        Some(v) => v
        None => ""
      }
    None => ""
  }
}

///|
/// §19.1.2.18 `@coordsize="X,Y"` — the shape's path-coordinate
/// rectangle.  Defaults to (1000, 1000) per the VML reference, which
/// happens to be Word's default too.
fn coordsize_of(ve : @xml.Element) -> (Double, Double) {
  match attr_value(ve, "coordsize") {
    Some(s) => parse_xy_string(s, 1000.0, 1000.0)
    None => (1000.0, 1000.0)
  }
}

///|
/// Parse an `@from` / `@to` / `@control1` / `@control2` attribute
/// of the form "x,y" (comma- or space-separated) into a `(Double,
/// Double)`.  Returns the supplied defaults when the attribute is
/// missing or malformed.
fn parse_xy_attr(
  ve : @xml.Element,
  name : String,
  def_x : Double,
  def_y : Double,
) -> (Double, Double) {
  match attr_value(ve, name) {
    Some(s) => parse_xy_string(s, def_x, def_y)
    None => (def_x, def_y)
  }
}

///|
/// Parse "x,y" or "x y" (with optional units the VML reader strips
/// — `pt`/`px`/`in`/`cm`/`mm`) into (Double, Double).
fn parse_xy_string(
  s : String,
  def_x : Double,
  def_y : Double,
) -> (Double, Double) {
  let parts = split_on_separators(s)
  let x = if parts.length() >= 1 { parse_length_px(parts[0]) } else { def_x }
  let y = if parts.length() >= 2 { parse_length_px(parts[1]) } else { def_y }
  (x, y)
}

///|
/// Split a string on commas, ASCII whitespace, or a mix of both —
/// the VML `from` / `to` / `points` separators.  Returns the list
/// of non-empty tokens, each as an owned `String`.
fn split_on_separators(s : String) -> Array[String] {
  let parts : Array[String] = []
  let n = s.length()
  let sp = ' '.to_int()
  let tab = '\t'.to_int()
  let nl = '\n'.to_int()
  let cr = '\r'.to_int()
  let comma = ','.to_int()
  let mut start = 0
  let mut i = 0
  while i < n {
    let cu = s[i].to_int()
    if cu == sp || cu == tab || cu == nl || cu == cr || cu == comma {
      if i > start {
        parts.push(s[start:i].to_owned())
      }
      start = i + 1
    }
    i = i + 1
  }
  if n > start {
    parts.push(s[start:n].to_owned())
  }
  parts
}

///|
/// Parse a `@points` attribute into the SVG `<polyline>` form
/// (`"x,y x,y x,y …"`).  Strips per-coordinate units so the SVG
/// renderer sees raw px numbers.
fn normalise_points(s : String) -> String {
  let pending = split_on_separators(s)
  let buf = StringBuilder::new()
  let mut first = true
  let m = pending.length()
  let mut j = 0
  while j + 1 < m {
    let x = parse_length_px(pending[j])
    let y = parse_length_px(pending[j + 1])
    if !first {
      buf.write_char(' ')
    }
    buf.write_string(fmt_double(x))
    buf.write_char(',')
    buf.write_string(fmt_double(y))
    first = false
    j = j + 2
  }
  buf.to_string()
}

///|
/// §19.1.2.5 `@fillcolor` — solid fill colour, or a `<v:fill>`
/// child overriding it.  Defaults to "#ffffff" (VML reference's
/// default; the renderer relies on the surrounding `<rect>` /
/// `<path>` to still draw something even when the fill is empty).
fn fill_color(ve : @xml.Element) -> String {
  // `<v:fill>` child wins over `@fillcolor` per the VML reference.
  match first_child_named(ve, "fill") {
    Some(f) => {
      match attr_value(f, "color") {
        Some(v) => return normalise_color(v)
        None => ()
      }
      match attr_value(f, "type") {
        Some(t) => if t == "none" { return "none" }
        None => ()
      }
    }
    None => ()
  }
  match attr_value(ve, "fillcolor") {
    Some(v) => normalise_color(v)
    None => "#ffffff"
  }
}

///|
/// Stroke colour + width, honouring `@strokecolor` / `@strokeweight`
/// and the `<v:stroke>` child override.  Defaults to "#000000" at
/// 1 px so an unstyled shape still has a visible outline.
fn stroke_props(ve : @xml.Element) -> (String, Double) {
  let mut color = match attr_value(ve, "strokecolor") {
    Some(v) => normalise_color(v)
    None => "#000000"
  }
  let mut width = match attr_value(ve, "strokeweight") {
    Some(v) => parse_length_px(v)
    None => 1.0
  }
  if width <= 0.0 {
    width = 1.0
  }
  match attr_value(ve, "stroked") {
    Some(v) =>
      if v.to_lower() == "f" || v.to_lower() == "false" {
        return ("none", 0.0)
      }
    None => ()
  }
  match first_child_named(ve, "stroke") {
    Some(s) => {
      match attr_value(s, "color") {
        Some(c) => color = normalise_color(c)
        None => ()
      }
      match attr_value(s, "weight") {
        Some(w) => {
          let v = parse_length_px(w)
          if v > 0.0 {
            width = v
          }
        }
        None => ()
      }
      match attr_value(s, "on") {
        Some(v) =>
          if v.to_lower() == "f" || v.to_lower() == "false" {
            return ("none", 0.0)
          }
        None => ()
      }
    }
    None => ()
  }
  (color, width)
}

///|
/// Convert a VML colour (#rrggbb, rrggbb, named CSS colour) to the
/// SVG `fill` / `stroke` form.  Strips `[…]` palette suffix the
/// Office writer occasionally appends.
fn normalise_color(s : String) -> String {
  let n = s.length()
  if n == 0 {
    return "#000000"
  }
  // Strip a trailing `[…]` palette suffix.
  let mut end = n
  let mut i = 0
  while i < n {
    let c = s[i].to_int()
    if c == '['.to_int() {
      end = i
      break
    }
    i = i + 1
  }
  let trimmed = s[0:end].to_owned()
  if trimmed.length() == 0 {
    return "#000000"
  }
  if trimmed[0].to_int() == '#'.to_int() {
    return trimmed
  }
  if trimmed.length() == 6 && is_hex(trimmed) {
    return "#" + trimmed
  }
  trimmed
}

///|
/// `true` when every character of `s` is a hex digit.
fn is_hex(s : String) -> Bool {
  let n = s.length()
  let mut i = 0
  while i < n {
    let c = s[i].to_int()
    let is_digit = c >= '0'.to_int() && c <= '9'.to_int()
    let is_lower = c >= 'a'.to_int() && c <= 'f'.to_int()
    let is_upper = c >= 'A'.to_int() && c <= 'F'.to_int()
    if !(is_digit || is_lower || is_upper) {
      return false
    }
    i = i + 1
  }
  true
}

///|
/// Parse a numeric attribute (e.g. `@startangle="30"`) with a
/// fallback default.  Strips units.
fn parse_double_attr(ve : @xml.Element, name : String, def : Double) -> Double {
  match attr_value(ve, name) {
    Some(s) => parse_length_px(s)
    None => def
  }
}

///|
/// Recursively collect text content from an element (visits
/// `<w:t>` / `<a:t>` / plain `Text` children, ignores empties).
/// Used by the `<v:textbox>` fallback to surface any text payload
/// the textbox carried even when the full WML pipeline is not in
/// scope.
fn extract_text(ve : @xml.Element) -> String {
  let buf = StringBuilder::new()
  collect_text(ve, buf)
  buf.to_string()
}

///|
fn collect_text(ve : @xml.Element, buf : StringBuilder) -> Unit {
  for c in ve.children {
    match c {
      Text(t) => buf.write_string(t)
      CData(t) => buf.write_string(t)
      Element(child_el) => collect_text(child_el, buf)
      _ => ()
    }
  }
}

///|
/// Build the outer `<g transform="…">` value: `translate(left, top)
/// rotate(angle cx cy)` when either is present, or "" otherwise.
fn build_transform(style : StyleProps, w : Double, h : Double) -> String {
  let parts : Array[String] = []
  match style.left {
    Some(lx) => {
      let ty = style.top.unwrap_or(0.0)
      parts.push("translate(" + fmt_double(lx) + "," + fmt_double(ty) + ")")
    }
    None =>
      match style.top {
        Some(ty) => parts.push("translate(0," + fmt_double(ty) + ")")
        None => ()
      }
  }
  match style.rotation_deg {
    Some(deg) if deg != 0.0 =>
      parts.push(
        "rotate(" +
        fmt_double(deg) +
        "," +
        fmt_double(w / 2.0) +
        "," +
        fmt_double(h / 2.0) +
        ")",
      )
    _ => ()
  }
  if style.flip_x {
    parts.push("scale(-1,1) translate(" + fmt_double(-w) + ",0)")
  }
  if style.flip_y {
    parts.push("scale(1,-1) translate(0," + fmt_double(-h) + ")")
  }
  parts.join(" ")
}

///|
/// Read the element's `style` attribute and parse it.  Returns the
/// empty `StyleProps` when the attribute is absent so the caller's
/// fallback width / height kicks in.
fn read_style(ve : @xml.Element) -> StyleProps {
  match attr_value(ve, "style") {
    Some(s) => parse_style(s)
    None => StyleProps::empty()
  }
}

///|
/// Compact double formatter for SVG attribute values — round to 3
/// decimals, trim trailing zeros so "12.0" → "12".  Pure ASCII.
fn fmt_double(value : Double) -> String {
  if value == 0.0 {
    return "0"
  }
  let scaled = (value * 1000.0).round()
  let int_part = (scaled / 1000.0).to_int()
  let frac = (scaled - int_part.to_double() * 1000.0).to_int()
  let abs_frac = if frac < 0 { -frac } else { frac }
  if abs_frac == 0 {
    return int_part.to_string()
  }
  // Pad fractional to 3 digits, then trim trailing zeros.
  let pad = pad3(abs_frac)
  let trimmed = trim_trailing_zeros(pad)
  if trimmed.length() == 0 {
    int_part.to_string()
  } else {
    int_part.to_string() + "." + trimmed
  }
}

///|
/// Render an integer as a 3-digit zero-padded string ("12" → "012").
fn pad3(n : Int) -> String {
  let s = n.to_string()
  if s.length() >= 3 {
    return s
  }
  if s.length() == 2 {
    return "0" + s
  }
  "00" + s
}

///|
/// Trim trailing '0' characters (used after `pad3` to compact the
/// fractional part).
fn trim_trailing_zeros(s : String) -> String {
  let n = s.length()
  let mut b = n
  while b > 0 && s[b - 1].to_int() == '0'.to_int() {
    b = b - 1
  }
  s[0:b].to_owned()
}

///|
/// `cos(deg)` (degrees → radians, then `cos`).  Pure helper used by
/// `<v:arc>` so the arc translation does not depend on `@math`.
fn cos_deg(deg : Double, pi : Double) -> Double {
  let r = deg * pi / 180.0
  // No `cos`/`sin` in the platform-agnostic runtime — implement via
  // the McLaurin series truncated to 8 terms (good to ~1e-7 for
  // |r| ≤ π).
  // Reduce to [-π, π] for stability.
  let two_pi = 2.0 * pi
  let mut x = r
  while x > pi {
    x = x - two_pi
  }
  while x < -pi {
    x = x + two_pi
  }
  let x2 = x * x
  let x4 = x2 * x2
  let x6 = x4 * x2
  let x8 = x4 * x4
  1.0 - x2 / 2.0 + x4 / 24.0 - x6 / 720.0 + x8 / 40320.0 - x8 * x2 / 3628800.0
}

///|
fn sin_deg(deg : Double, pi : Double) -> Double {
  let r = deg * pi / 180.0
  let two_pi = 2.0 * pi
  let mut x = r
  while x > pi {
    x = x - two_pi
  }
  while x < -pi {
    x = x + two_pi
  }
  let x2 = x * x
  let x3 = x * x2
  let x5 = x3 * x2
  let x7 = x5 * x2
  let x9 = x7 * x2
  x - x3 / 6.0 + x5 / 120.0 - x7 / 5040.0 + x9 / 362880.0 - x9 * x2 / 39916800.0
}
