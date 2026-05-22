// White-box tests for the DrawingML color resolver.
//
// Builds small XmlElement trees for each color form
// (srgbClr / schemeClr / prstClr / sysClr / hslClr) and verifies that
// resolution + transforms produce the expected hex string.

///|
/// Build a minimal XmlElement for testing.  `attrs` is `[(name,value)]`.
fn make_elt(
  local_name : String,
  attrs : Array[(String, String)],
  children : Array[@xml.Element],
) -> @xml.Element {
  let attributes : Array[@xml.Attribute] = []
  for pair in attrs {
    let (k, v) = pair
    attributes.push({
      name: { prefix: Some("a"), local_name: k, ns: None },
      value: v,
    })
  }
  let nodes : Array[@xml.Node] = []
  for c in children {
    nodes.push(Element(c))
  }
  {
    name: { prefix: Some("a"), local_name, ns: None },
    attributes,
    children: nodes,
  }
}

///|
test "srgbClr resolves to literal hex" {
  let elt = make_elt("srgbClr", [("val", "FF0000")], [])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="ff0000")
  inspect(rc.alpha, content="1")
}

///|
test "schemeClr looks up the theme palette" {
  let elt = make_elt("schemeClr", [("val", "accent1")], [])
  let scheme : ColorScheme = { "accent1": "4472C4" }
  let ctx : ColorResolveContext = {
    color_map: Map::new(),
    color_map_override: None,
    color_scheme: scheme,
    ph_clr: None,
    major_font: Map::new(),
    minor_font: Map::new(),
  }
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="4472c4")
}

///|
test "schemeClr respects colorMap (tx1 → dk1)" {
  let elt = make_elt("schemeClr", [("val", "tx1")], [])
  let scheme : ColorScheme = { "dk1": "000000" }
  let cm : ColorMap = { "tx1": "dk1" }
  let ctx : ColorResolveContext = {
    color_map: cm,
    color_map_override: None,
    color_scheme: scheme,
    ph_clr: None,
    major_font: Map::new(),
    minor_font: Map::new(),
  }
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="000000")
}

///|
test "prstClr resolves CSS named color" {
  let elt = make_elt("prstClr", [("val", "red")], [])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="ff0000")
}

///|
test "sysClr lastClr takes precedence" {
  let elt = make_elt("sysClr", [("val", "windowText"), ("lastClr", "112233")], [])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="112233")
}

///|
test "sysClr windowText falls back to black" {
  let elt = make_elt("sysClr", [("val", "windowText")], [])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="000000")
}

///|
test "alpha 50% is captured" {
  let alpha = make_elt("alpha", [("val", "50000")], [])
  let elt = make_elt("srgbClr", [("val", "FF0000")], [alpha])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.alpha, content="0.5")
}

///|
test "format_resolved_color emits #hex or rgba" {
  let opaque : ResolvedColor = { hex: "abcdef", alpha: 1.0 }
  inspect(format_resolved_color(opaque), content="#abcdef")
  let translucent : ResolvedColor = { hex: "ff0000", alpha: 0.5 }
  // rgba uses integer RGB and double alpha.
  inspect(format_resolved_color(translucent), content="rgba(255, 0, 0, 0.5)")
}

///|
test "solidFill wrapper element is unwrapped" {
  let inner = make_elt("srgbClr", [("val", "00FF00")], [])
  let sf = make_elt("solidFill", [], [inner])
  // Wrap in a parent so resolve_solid_fill sees the solidFill child path.
  let parent = make_elt("spPr", [], [sf])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(parent, ctx~).unwrap()
  inspect(rc.hex, content="00ff00")
}

///|
/// §20.1.2.3.30 scrgbClr — the linear-RGB channels MUST be
/// gamma-encoded to sRGB.  A 50% linear channel maps to ≈188
/// (the IEC 61966-2-1 transfer), NOT 128 (straight scaling).
test "scrgbClr applies linear-to-sRGB gamma" {
  let elt = make_elt(
    "scrgbClr", [("r", "50000"), ("g", "50000"), ("b", "50000")], [],
  )
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  // 50% linear → ≈0xbc (188).  Straight scaling would give 0x80.
  inspect(rc.hex, content="bcbcbc")
  // Full intensity → white.
  let white = make_elt(
    "scrgbClr", [("r", "100000"), ("g", "100000"), ("b", "100000")], [],
  )
  let rw = resolve_solid_fill(white, ctx~).unwrap()
  inspect(rw.hex, content="ffffff")
}
