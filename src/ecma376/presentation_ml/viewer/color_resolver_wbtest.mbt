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
    color_map: Map([], capacity=0),
    color_map_override: None,
    color_scheme: scheme,
    ph_clr: None,
    major_font: Map([], capacity=0),
    minor_font: Map([], capacity=0),
    clamp_overflow_hue: true,
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
    major_font: Map([], capacity=0),
    minor_font: Map([], capacity=0),
    clamp_overflow_hue: true,
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
  let opaque_color : ResolvedColor = { hex: "abcdef", alpha: 1.0 }
  inspect(format_resolved_color(opaque_color), content="#abcdef")
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
/// §20.1.2.3.19 hueOff — accent1 blue (4472c4) with a +90°
/// hue rotation (5400000 sixtieths of a degree).  Verifies the
/// resolver parses the integer `val=` attribute and feeds it
/// through `apply_hue_off` after dividing by 60000.
test "hueOff rotates hue by 90 degrees" {
  let hue_off = make_elt("hueOff", [("val", "5400000")], [])
  let elt = make_elt("srgbClr", [("val", "FF0000")], [hue_off])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  // Pure red (H=0) + 90° → H=90 → yellow-green region.
  // HSL(90, 1, 0.5) → #80ff00.
  inspect(rc.hex, content="80ff00")
}

///|
/// §20.1.2.3.5 comp — child element with no attributes flips the
/// hue 180°.  Pure red → cyan.
test "comp child triggers hue rotation" {
  let comp = make_elt("comp", [], [])
  let elt = make_elt("srgbClr", [("val", "FF0000")], [comp])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="00ffff")
}

///|
/// §20.1.2.3.20 inv — per-channel linear-RGB inversion.  Pure
/// white → black.
test "inv child inverts white to black" {
  let inv = make_elt("inv", [], [])
  let elt = make_elt("srgbClr", [("val", "FFFFFF")], [inv])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="000000")
}

///|
/// §20.1.2.3.17 gray — Rec. 709 luminance.  Pure green
/// dominates (0.7152 coefficient) → mid-bright gray.
test "gray child reduces green to grayscale" {
  let gray = make_elt("gray", [], [])
  let elt = make_elt("srgbClr", [("val", "00FF00")], [gray])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  // Y = 0.7152 → sRGB byte ≈220 (dc).  All three channels equal.
  inspect(rc.hex[0:2], content="dc")
  inspect(rc.hex[2:4], content="dc")
  inspect(rc.hex[4:6], content="dc")
}

///|
/// §20.1.2.3.26 a:red — explicit channel replacement.  Driving
/// red to 100% on a pure-black base produces pure red.
test "red 100% sets the red channel" {
  let red = make_elt("red", [("val", "100000")], [])
  let elt = make_elt("srgbClr", [("val", "000000")], [red])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="ff0000")
}

///|
/// §20.1.2.3.4 a:blue — explicit channel replacement.  Driving
/// blue to 25% on a mid-gray base darkens just the blue channel.
test "blue 25% sets the blue channel" {
  let blue = make_elt("blue", [("val", "25000")], [])
  // Mid-gray base (808080) — we expect r/g preserved and blue
  // overwritten with the gamma-encoded 0.25 linear value.
  let elt = make_elt("srgbClr", [("val", "808080")], [blue])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  // Red and green untouched.
  inspect(rc.hex[0:2], content="80")
  inspect(rc.hex[2:4], content="80")
  // Blue ≈ linear_to_srgb(0.25) → 137 (0x89).
  inspect(rc.hex[4:6], content="89")
}

///|
/// §20.1.2.3.16 a:gamma — re-encodes byte/255 through the sRGB
/// transfer function, lifting mid-tones.  808080 → bcbcbc.
test "gamma child lifts mid-tones" {
  let gamma = make_elt("gamma", [], [])
  let elt = make_elt("srgbClr", [("val", "808080")], [gamma])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="bcbcbc")
}

///|
/// §20.1.2.3.13 a:invGamma — inverse of gamma; mid-tones darken.
test "invGamma child darkens mid-tones" {
  let inv_gamma = make_elt("invGamma", [], [])
  let elt = make_elt("srgbClr", [("val", "BCBCBC")], [inv_gamma])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="808080")
}

///|
/// §20.1.2.3.7 a:satOff — additive saturation offset.  Driving
/// satOff to -100 % flattens any colour to a neutral gray at the
/// preserved lightness.
test "satOff -100 desaturates to gray" {
  let sat_off = make_elt("satOff", [("val", "-100000")], [])
  let elt = make_elt("srgbClr", [("val", "FF0000")], [sat_off])
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  inspect(rc.hex, content="808080")
}

///|
/// §20.1.2.3.30 scrgbClr — the linear-RGB channels MUST be
/// gamma-encoded to sRGB.  A 50% linear channel maps to ≈188
/// (the IEC 61966-2-1 transfer), NOT 128 (straight scaling).
test "scrgbClr applies linear-to-sRGB gamma" {
  let elt = make_elt(
    "scrgbClr",
    [("r", "50000"), ("g", "50000"), ("b", "50000")],
    [],
  )
  let ctx = ColorResolveContext::empty()
  let rc = resolve_solid_fill(elt, ctx~).unwrap()
  // 50% linear → ≈0xbc (188).  Straight scaling would give 0x80.
  inspect(rc.hex, content="bcbcbc")
  // Full intensity → white.
  let white = make_elt(
    "scrgbClr",
    [("r", "100000"), ("g", "100000"), ("b", "100000")],
    [],
  )
  let rw = resolve_solid_fill(white, ctx~).unwrap()
  inspect(rw.hex, content="ffffff")
}
