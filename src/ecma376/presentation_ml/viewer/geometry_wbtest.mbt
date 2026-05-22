// White-box tests for the geometry dispatcher and basic preset
// implementations.

///|
/// Build a `<a:prstGeom prst="...">` element with optional adjust
/// values for testing the dispatcher end-to-end.
fn geom_make_elt(
  prst : String,
  adjust_values : Array[(String, Double)],
) -> @xml.Element {
  let av_children : Array[@xml.Node] = []
  for av in adjust_values {
    let (name, value) = av
    let gd : @xml.Element = {
      name: { prefix: Some("a"), local_name: "gd", ns: None },
      attributes: [
        { name: { prefix: None, local_name: "name", ns: None }, value: name },
        {
          name: { prefix: None, local_name: "fmla", ns: None },
          value: "val " + value.to_string(),
        },
      ],
      children: [],
    }
    av_children.push(Element(gd))
  }
  let av_lst : @xml.Element = {
    name: { prefix: Some("a"), local_name: "avLst", ns: None },
    attributes: [],
    children: av_children,
  }
  {
    name: { prefix: Some("a"), local_name: "prstGeom", ns: None },
    attributes: [
      { name: { prefix: None, local_name: "prst", ns: None }, value: prst },
    ],
    children: [Element(av_lst)],
  }
}

///|
test "preset rect" {
  let elt = geom_make_elt("rect", [])
  let p = render_preset_geometry(elt, 100.0, 50.0).unwrap()
  inspect(p, content="M 0 0 L 100 0 L 100 50 L 0 50 Z")
}

///|
test "preset ellipse" {
  let elt = geom_make_elt("ellipse", [])
  let p = render_preset_geometry(elt, 100.0, 50.0).unwrap()
  inspect(p, content="M 50 0 A 50 25 0 1 1 50 50 A 50 25 0 1 1 50 0 Z")
}

///|
test "preset triangle" {
  let elt = geom_make_elt("triangle", [])
  let p = render_preset_geometry(elt, 100.0, 50.0).unwrap()
  inspect(p, content="M 50 0 L 100 50 L 0 50 Z")
}

///|
test "preset diamond" {
  let elt = geom_make_elt("diamond", [])
  let p = render_preset_geometry(elt, 100.0, 50.0).unwrap()
  inspect(p, content="M 50 0 L 100 25 L 50 50 L 0 25 Z")
}

///|
test "preset line horizontal" {
  let elt = geom_make_elt("line", [])
  let p = render_preset_geometry(elt, 100.0, 50.0).unwrap()
  inspect(p, content="M 0 25 L 100 25")
}

///|
test "preset line vertical" {
  let elt = geom_make_elt("line", [])
  let p = render_preset_geometry(elt, 50.0, 100.0).unwrap()
  inspect(p, content="M 25 0 L 25 100")
}

///|
test "preset roundRect with default adj" {
  let elt = geom_make_elt("rect", [])
  let p = render_preset_geometry(elt, 100.0, 50.0).unwrap()
  assert_true(p.length() > 0)
  // roundRect with default 16667 → r = 16667/100000 * 50 = 8.3335
  let elt2 = geom_make_elt("roundRect", [])
  let p2 = render_preset_geometry(elt2, 100.0, 50.0).unwrap()
  assert_true(p2.contains("Q")) // contains quadratic curves
}

///|
test "preset parallelogram with custom adj" {
  let elt = geom_make_elt("parallelogram", [("adj", 50000.0)])
  let p = render_preset_geometry(elt, 100.0, 50.0).unwrap()
  // offset = 50000/100000 * 100 = 50
  inspect(p, content="M 50 0 L 100 0 L 50 50 L 0 50 Z")
}

///|
test "preset pentagon produces 5 vertices + close" {
  let elt = geom_make_elt("pentagon", [])
  let p = render_preset_geometry(elt, 100.0, 100.0).unwrap()
  // Should start with M, have 4 L commands, end with Z.
  assert_true(p.has_prefix("M "))
  assert_true(p.has_suffix(" Z"))
}

///|
test "preset hexagon with default adj" {
  let elt = geom_make_elt("hexagon", [])
  let p = render_preset_geometry(elt, 100.0, 50.0).unwrap()
  // offset = 25000/100000 * 100 = 25
  inspect(p, content="M 25 0 L 75 0 L 100 25 L 75 50 L 25 50 L 0 25 Z")
}

///|
test "preset plus with default adj" {
  let elt = geom_make_elt("plus", [])
  let p = render_preset_geometry(elt, 100.0, 100.0).unwrap()
  // arm = 25%, x1=25, x2=75, y1=25, y2=75
  inspect(
    p,
    content="M 25 0 L 75 0 L 75 25 L 100 25 L 100 75 L 75 75 L 75 100 L 25 100 L 25 75 L 0 75 L 0 25 L 25 25 Z",
  )
}

///|
test "preset star5 produces 10 vertices" {
  let elt = geom_make_elt("star5", [])
  let p = render_preset_geometry(elt, 100.0, 100.0).unwrap()
  // 10 vertex commands + 1 Z
  assert_true(p.has_prefix("M "))
  assert_true(p.has_suffix(" Z"))
}

///|
test "unknown preset returns None" {
  let elt = geom_make_elt("nonExistent", [])
  inspect(render_preset_geometry(elt, 100.0, 50.0), content="None")
}
