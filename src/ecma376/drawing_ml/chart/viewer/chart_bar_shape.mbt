// §21.2.2.192 CT_Shape — 3-D bar data-marker shapes projected into SVG.
// The bar renderer is otherwise a 2-D renderer, so these helpers map each
// ST_Shape lexical value to a deterministic 2-D silhouette while preserving
// the resolved series / data-point fill as the single source of colour.

///|
priv enum ChartBarShape {
  ChartBarShapeCone
  ChartBarShapeConeToMax
  ChartBarShapeBox
  ChartBarShapeCylinder
  ChartBarShapePyramid
  ChartBarShapePyramidToMax
}

///|
fn ChartBarShape::to_string(self : ChartBarShape) -> String {
  match self {
    ChartBarShapeCone => "cone"
    ChartBarShapeConeToMax => "coneToMax"
    ChartBarShapeBox => "box"
    ChartBarShapeCylinder => "cylinder"
    ChartBarShapePyramid => "pyramid"
    ChartBarShapePyramidToMax => "pyramidToMax"
  }
}

///|
fn chart_bar_shape_parse(raw : String) -> ChartBarShape {
  match raw {
    "cone" => ChartBarShapeCone
    "coneToMax" => ChartBarShapeConeToMax
    "box" => ChartBarShapeBox
    "cylinder" => ChartBarShapeCylinder
    "pyramid" => ChartBarShapePyramid
    "pyramidToMax" => ChartBarShapePyramidToMax
    _ => abort("invalid ST_Shape: " + raw)
  }
}

///|
fn chart_bar_shape_value(owner : @xml.Element) -> ChartBarShape? {
  match first_child_named(owner, "shape") {
    Some(shape) =>
      match attr_value(shape, "val") {
        Some(v) => Some(chart_bar_shape_parse(v))
        None => Some(ChartBarShapeBox)
      }
    None => None
  }
}

///|
fn read_bar_shape(chart : @xml.Element, ser : @xml.Element) -> ChartBarShape {
  match chart_bar_shape_value(ser) {
    Some(v) => v
    None =>
      match chart_bar_shape_value(chart) {
        Some(v) => v
        None => ChartBarShapeBox
      }
  }
}

///|
fn chart_bar_min(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn chart_bar_rect_node(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  fill : String,
) -> @xml.Node {
  @markup.elem_ns(
    "rect",
    @markup.svg_ns,
    [
      @markup.attr("x", format_double(x)),
      @markup.attr("y", format_double(y)),
      @markup.attr("width", format_double(width)),
      @markup.attr("height", format_double(height)),
      @markup.attr("fill", fill),
    ],
    [],
  )
}

///|
fn chart_bar_points(points : Array[(Double, Double)]) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for point in points {
    let (x, y) = point
    if first {
      first = false
    } else {
      buf.write_string(" ")
    }
    buf.write_string(format_double(x))
    buf.write_string(",")
    buf.write_string(format_double(y))
  }
  buf.to_string()
}

///|
fn chart_bar_polygon(
  points : Array[(Double, Double)],
  fill : String,
  opacity : String,
) -> @xml.Node {
  @markup.elem_ns(
    "polygon",
    @markup.svg_ns,
    [
      @markup.attr("points", chart_bar_points(points)),
      @markup.attr("fill", fill),
      @markup.attr("fill-opacity", opacity),
    ],
    [],
  )
}

///|
fn chart_bar_ellipse(
  cx : Double,
  cy : Double,
  rx : Double,
  ry : Double,
  fill : String,
  opacity : String,
) -> @xml.Node {
  @markup.elem_ns(
    "ellipse",
    @markup.svg_ns,
    [
      @markup.attr("cx", format_double(cx)),
      @markup.attr("cy", format_double(cy)),
      @markup.attr("rx", format_double(rx)),
      @markup.attr("ry", format_double(ry)),
      @markup.attr("fill", fill),
      @markup.attr("fill-opacity", opacity),
    ],
    [],
  )
}

///|
fn chart_bar_shape_group(
  shape : ChartBarShape,
  children : Array[@xml.Node],
) -> @xml.Node {
  @markup.elem_ns(
    "g",
    @markup.svg_ns,
    [
      @markup.attr("data-ooxml", "chart-bar-shape"),
      @markup.attr("data-ooxml-shape", shape.to_string()),
    ],
    children,
  )
}

///|
fn chart_bar_cylinder_nodes(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  fill : String,
  horizontal : Bool,
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  if horizontal {
    let cap_w = chart_bar_min(height * 0.36, width * 0.4)
    let rx = cap_w / 2.0
    let cy = y + height / 2.0
    nodes.push(chart_bar_rect_node(x + rx, y, width - cap_w, height, fill))
    nodes.push(chart_bar_ellipse(x + rx, cy, rx, height / 2.0, fill, "0.72"))
    nodes.push(
      chart_bar_ellipse(x + width - rx, cy, rx, height / 2.0, fill, "1"),
    )
  } else {
    let cap_h = chart_bar_min(width * 0.18, height * 0.4)
    let ry = cap_h / 2.0
    let cx = x + width / 2.0
    nodes.push(chart_bar_rect_node(x, y + ry, width, height - cap_h, fill))
    nodes.push(chart_bar_ellipse(cx, y + ry, width / 2.0, ry, fill, "1"))
    nodes.push(
      chart_bar_ellipse(cx, y + height - ry, width / 2.0, ry, fill, "0.72"),
    )
  }
  nodes
}

///|
fn chart_bar_pyramid_points(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  horizontal : Bool,
  value_reversed : Bool,
) -> Array[(Double, Double)] {
  if horizontal {
    let base_x = if value_reversed { x + width } else { x }
    let apex_x = if value_reversed { x } else { x + width }
    [(base_x, y), (base_x, y + height), (apex_x, y + height / 2.0)]
  } else {
    let base_y = if value_reversed { y } else { y + height }
    let apex_y = if value_reversed { y + height } else { y }
    [(x, base_y), (x + width, base_y), (x + width / 2.0, apex_y)]
  }
}

///|
fn chart_bar_trapezoid_points(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  horizontal : Bool,
  value_reversed : Bool,
) -> Array[(Double, Double)] {
  if horizontal {
    let inset = height * 0.28
    if value_reversed {
      [
        (x, y + inset),
        (x, y + height - inset),
        (x + width, y + height),
        (x + width, y),
      ]
    } else {
      [
        (x, y),
        (x, y + height),
        (x + width, y + height - inset),
        (x + width, y + inset),
      ]
    }
  } else {
    let inset = width * 0.28
    if value_reversed {
      [
        (x, y),
        (x + width, y),
        (x + width - inset, y + height),
        (x + inset, y + height),
      ]
    } else {
      [
        (x + inset, y),
        (x + width - inset, y),
        (x + width, y + height),
        (x, y + height),
      ]
    }
  }
}

///|
fn chart_bar_cone_caps(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  fill : String,
  horizontal : Bool,
  value_reversed : Bool,
  to_max : Bool,
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  if horizontal {
    let cap_w = chart_bar_min(height * 0.36, width * 0.4)
    let rx = cap_w / 2.0
    let cy = y + height / 2.0
    let base_x = if value_reversed { x + width } else { x }
    nodes.push(chart_bar_ellipse(base_x, cy, rx, height / 2.0, fill, "0.72"))
    if to_max {
      let end_x = if value_reversed { x } else { x + width }
      nodes.push(
        chart_bar_ellipse(end_x, cy, rx * 0.55, height * 0.22, fill, "1"),
      )
    }
  } else {
    let cap_h = chart_bar_min(width * 0.18, height * 0.4)
    let ry = cap_h / 2.0
    let cx = x + width / 2.0
    let base_y = if value_reversed { y } else { y + height }
    nodes.push(chart_bar_ellipse(cx, base_y, width / 2.0, ry, fill, "0.72"))
    if to_max {
      let end_y = if value_reversed { y + height } else { y }
      nodes.push(
        chart_bar_ellipse(cx, end_y, width * 0.22, ry * 0.55, fill, "1"),
      )
    }
  }
  nodes
}

///|
fn render_bar_shape_nodes(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  fill : String,
  shape : ChartBarShape,
  horizontal : Bool,
  value_reversed : Bool,
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  match shape {
    ChartBarShapeBox =>
      nodes.push(chart_bar_rect_node(x, y, width, height, fill))
    ChartBarShapeCylinder =>
      nodes.push(
        chart_bar_shape_group(
          shape,
          chart_bar_cylinder_nodes(x, y, width, height, fill, horizontal),
        ),
      )
    ChartBarShapeCone => {
      let kids : Array[@xml.Node] = [
        chart_bar_polygon(
          chart_bar_pyramid_points(
            x, y, width, height, horizontal, value_reversed,
          ),
          fill,
          "0.9",
        ),
      ]
      for
        n in chart_bar_cone_caps(
          x, y, width, height, fill, horizontal, value_reversed, false,
        ) {
        kids.push(n)
      }
      nodes.push(chart_bar_shape_group(shape, kids))
    }
    ChartBarShapeConeToMax => {
      let kids : Array[@xml.Node] = [
        chart_bar_polygon(
          chart_bar_trapezoid_points(
            x, y, width, height, horizontal, value_reversed,
          ),
          fill,
          "0.9",
        ),
      ]
      for
        n in chart_bar_cone_caps(
          x, y, width, height, fill, horizontal, value_reversed, true,
        ) {
        kids.push(n)
      }
      nodes.push(chart_bar_shape_group(shape, kids))
    }
    ChartBarShapePyramid =>
      nodes.push(
        chart_bar_shape_group(shape, [
          chart_bar_polygon(
            chart_bar_pyramid_points(
              x, y, width, height, horizontal, value_reversed,
            ),
            fill,
            "1",
          ),
        ]),
      )
    ChartBarShapePyramidToMax =>
      nodes.push(
        chart_bar_shape_group(shape, [
          chart_bar_polygon(
            chart_bar_trapezoid_points(
              x, y, width, height, horizontal, value_reversed,
            ),
            fill,
            "1",
          ),
        ]),
      )
  }
  nodes
}
