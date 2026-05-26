// White-box tests for the VML → SVG translator.

///|
test "parse_style honours pt / px / in units" {
  let p = parse_style(
    "position:absolute;left:12pt;top:24pt;width:1in;height:96px",
  )
  @debug.assert_eq(p.left, Some(16.0)) // 12 pt * 96/72 = 16 px
  @debug.assert_eq(p.top, Some(32.0)) // 24 pt * 96/72 = 32 px
  @debug.assert_eq(p.width, Some(96.0)) // 1 in = 96 px
  @debug.assert_eq(p.height, Some(96.0))
}

///|
test "parse_style picks up rotation and flip" {
  let p = parse_style("rotation:30;flip:x")
  @debug.assert_eq(p.rotation_deg, Some(30.0))
  assert_true(p.flip_x)
  assert_false(p.flip_y)
}

///|
test "vml_path_to_svg_d translates moveto / lineto / close" {
  // VML: m 0,0 l 100,0 l 100,100 l 0,100 x e
  // SVG: M 0 0 L 100 0 L 100 100 L 0 100 Z Z
  let d = vml_path_to_svg_d("m 0,0 l 100,0 l 100,100 l 0,100 x e")
  @debug.assert_eq(d, "M 0 0 L 100 0 L 100 100 L 0 100 Z Z")
}

///|
test "vml_path_to_svg_d preserves cubic Bézier" {
  let d = vml_path_to_svg_d("m 0,0 c 50,0 50,100 100,100 e")
  @debug.assert_eq(d, "M 0 0 C 50 0 50 100 100 100 Z")
}

///|
test "render_vml emits an SVG rect for v:rect with extent" {
  let el : @xml.Element = {
    name: { prefix: Some("v"), local_name: "rect", ns: Some(vml_ns) },
    attributes: [
      {
        name: { prefix: None, local_name: "style", ns: None },
        value: "width:100pt;height:50pt",
      },
      {
        name: { prefix: None, local_name: "fillcolor", ns: None },
        value: "#ff0000",
      },
    ],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  // Serialise the first node; expect a `<rect …>` carrying width/
  // height and the requested fill.
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("<rect"))
      assert_true(svg.contains("fill=\"#ff0000\""))
      // 100 pt = 133.333… px → trimmed to 3 decimals → "133.333".
      assert_true(svg.contains("width=\"133.333\""))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml emits an SVG line for v:line" {
  let el : @xml.Element = {
    name: { prefix: Some("v"), local_name: "line", ns: Some(vml_ns) },
    attributes: [
      { name: { prefix: None, local_name: "from", ns: None }, value: "0pt,0pt" },
      {
        name: { prefix: None, local_name: "to", ns: None },
        value: "100pt,50pt",
      },
    ],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("<line"))
      assert_true(svg.contains("x2=\"133.333\""))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml emits an SVG ellipse for v:oval" {
  let el : @xml.Element = {
    name: { prefix: Some("v"), local_name: "oval", ns: Some(vml_ns) },
    attributes: [
      {
        name: { prefix: None, local_name: "style", ns: None },
        value: "width:80px;height:40px",
      },
    ],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("<ellipse"))
      assert_true(svg.contains("rx=\"40\""))
      assert_true(svg.contains("ry=\"20\""))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml emits an SVG path for v:shape with @path" {
  let el : @xml.Element = {
    name: { prefix: Some("v"), local_name: "shape", ns: Some(vml_ns) },
    attributes: [
      {
        name: { prefix: None, local_name: "style", ns: None },
        value: "width:100px;height:100px",
      },
      {
        name: { prefix: None, local_name: "coordsize", ns: None },
        value: "1000,1000",
      },
      {
        name: { prefix: None, local_name: "path", ns: None },
        value: "m 0,0 l 1000,0 l 1000,1000 l 0,1000 x e",
      },
    ],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("<path"))
      assert_true(svg.contains("M 0 0 L 1000 0 L 1000 1000 L 0 1000 Z Z"))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml emits an SVG g for v:group with children" {
  let child : @xml.Element = {
    name: { prefix: Some("v"), local_name: "rect", ns: Some(vml_ns) },
    attributes: [
      {
        name: { prefix: None, local_name: "style", ns: None },
        value: "width:10px;height:10px",
      },
    ],
    children: [],
  }
  let group : @xml.Element = {
    name: { prefix: Some("v"), local_name: "group", ns: Some(vml_ns) },
    attributes: [],
    children: [Element(child)],
  }
  let nodes = render_vml(group)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("vml-group"))
      assert_true(svg.contains("<rect"))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml surfaces textpath @string attribute" {
  let el : @xml.Element = {
    name: { prefix: Some("v"), local_name: "textpath", ns: Some(vml_ns) },
    attributes: [
      { name: { prefix: None, local_name: "string", ns: None }, value: "hello" },
    ],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("<text"))
      assert_true(svg.contains(">hello<"))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml surfaces textbox contents" {
  let txbx_content : @xml.Element = {
    name: { prefix: Some("w"), local_name: "txbxContent", ns: None },
    attributes: [],
    children: [Text("body text")],
  }
  let tb : @xml.Element = {
    name: { prefix: Some("v"), local_name: "textbox", ns: Some(vml_ns) },
    attributes: [
      {
        name: { prefix: None, local_name: "style", ns: None },
        value: "width:80px;height:40px",
      },
    ],
    children: [Element(txbx_content)],
  }
  let nodes = render_vml(tb)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("vml-textbox"))
      assert_true(svg.contains(">body text<"))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml emits placeholder for v:imagedata without resolver" {
  let el : @xml.Element = {
    name: { prefix: Some("v"), local_name: "imagedata", ns: Some(vml_ns) },
    attributes: [
      {
        name: { prefix: None, local_name: "style", ns: None },
        value: "width:64px;height:64px",
      },
    ],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("vml-image"))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml emits stroke marker for v:shapetype" {
  let el : @xml.Element = {
    name: { prefix: Some("v"), local_name: "shapetype", ns: Some(vml_ns) },
    attributes: [],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("vml-shapetype"))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml emits marker for office extrusion" {
  let el : @xml.Element = {
    name: {
      prefix: Some("o"),
      local_name: "extrusion",
      ns: Some(vml_office_ns),
    },
    attributes: [],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      assert_true(svg.contains("vml-extrusion"))
    }
    _ => assert_true(false)
  }
}

///|
test "render_vml wraps element in translate(left,top) when style positions it" {
  let el : @xml.Element = {
    name: { prefix: Some("v"), local_name: "rect", ns: Some(vml_ns) },
    attributes: [
      {
        name: { prefix: None, local_name: "style", ns: None },
        value: "left:10pt;top:20pt;width:30pt;height:40pt",
      },
    ],
    children: [],
  }
  let nodes = render_vml(el)
  assert_true(nodes.length() > 0)
  match nodes[0] {
    Element(e) => {
      let svg = @markup.serialize(e)
      // 10pt = 13.333 px; 20pt = 26.667 px (rounded to 3 decimals).
      assert_true(svg.contains("translate("))
      assert_true(svg.contains("<rect"))
    }
    _ => assert_true(false)
  }
}
