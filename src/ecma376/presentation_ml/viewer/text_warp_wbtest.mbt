// §20.1.9.x prstTxWarp — arch-family WordArt warps render the text
// along an SVG arc (textPath); other presets defer to span layout.

///|
fn warp_el(
  prefix : String?,
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Element {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: None, local_name: k, ns: None }, value: v })
  }
  { name: { prefix, local_name: tag, ns: None }, attributes: a, children: kids }
}

///|
fn warp_txbody(prst : String?) -> @xml.Element {
  let bodypr_kids : Array[@xml.Node] = match prst {
    Some(p) =>
      [@xml.Node::Element(warp_el(Some("a"), "prstTxWarp", [("prst", p)], []))]
    None => []
  }
  let run = warp_el(Some("a"), "r", [], [
    @xml.Node::Element(warp_el(Some("a"), "t", [], [@xml.Node::Text("ARCHED")])),
  ])
  warp_el(Some("p"), "txBody", [], [
    @xml.Node::Element(warp_el(Some("a"), "bodyPr", [], bodypr_kids)),
    @xml.Node::Element(warp_el(Some("a"), "p", [], [@xml.Node::Element(run)])),
  ])
}

///|
/// Like `warp_txbody` but the run carries `<a:rPr><a:latin
/// typeface="Noto Sans"/>…</a:rPr>` so the envelope renderer can
/// resolve the registered test-font outline.
fn warp_txbody_with_font(prst : String) -> @xml.Element {
  let bodypr_kids : Array[@xml.Node] = [
    @xml.Node::Element(warp_el(Some("a"), "prstTxWarp", [("prst", prst)], [])),
  ]
  let rpr = warp_el(Some("a"), "rPr", [("sz", "3600")], [
    @xml.Node::Element(
      warp_el(Some("a"), "latin", [("typeface", "Noto Sans")], []),
    ),
  ])
  let run = warp_el(Some("a"), "r", [], [
    @xml.Node::Element(rpr),
    @xml.Node::Element(warp_el(Some("a"), "t", [], [@xml.Node::Text("AV")])),
  ])
  warp_el(Some("p"), "txBody", [], [
    @xml.Node::Element(warp_el(Some("a"), "bodyPr", [], bodypr_kids)),
    @xml.Node::Element(warp_el(Some("a"), "p", [], [@xml.Node::Element(run)])),
  ])
}

///|
fn warp_svg(prst : String?) -> (String, String) {
  let defs = SvgDefsCollector::new()
  let nodes = render_warped_text(
    warp_txbody(prst),
    200.0,
    100.0,
    ColorResolveContext::empty(),
    defs,
  )
  let body = StringBuilder::new()
  match nodes {
    Some(ns) =>
      for n in ns {
        match n {
          @xml.Node::Element(e) => body.write_string(@markup.serialize_svg(e))
          _ => ()
        }
      }
    None => ()
  }
  (body.to_string(), defs.to_defs_element())
}

///|
test "textArchUp renders text along an arc path" {
  let (body, defs) = warp_svg(Some("textArchUp"))
  // <textPath> referencing an arc <path> def.
  assert_true(body.contains("<textPath "))
  assert_true(body.contains("ARCHED"))
  assert_true(body.contains("data-ooxml-text-warp=\"textArchUp\""))
  // Arc path with an "A" (elliptical-arc) command, sweep 1 (up).
  assert_true(defs.contains("<path "))
  assert_true(defs.contains(" A "))
}

///|
test "textArchDown bulges the other way (sweep 0)" {
  let (_, defs) = warp_svg(Some("textArchDown"))
  assert_true(defs.contains(" A "))
  assert_true(defs.contains("0 0 0 ")) // large=0 sweep=0
}

///|
test "textWave1 lays text on a sampled sine polyline (not an arc)" {
  let (body, defs) = warp_svg(Some("textWave1"))
  // Wave is a baseline-on-curve family → text rides a <textPath>.
  assert_true(body.contains("<textPath "))
  assert_true(body.contains("data-ooxml-text-warp=\"textWave1\""))
  // The guide is a sampled polyline (L commands), NOT a circular arc.
  assert_true(defs.contains(" L "))
  assert_true(!defs.contains(" A "))
}

///|
test "textCurveUp uses a shallow open arc" {
  let (body, defs) = warp_svg(Some("textCurveUp"))
  assert_true(body.contains("<textPath "))
  assert_true(defs.contains(" A "))
}

///|
test "textRingOutside wraps text around a full circle path" {
  let (body, defs) = warp_svg(Some("textRingOutside"))
  assert_true(body.contains("<textPath "))
  // A full ring is two half-arcs: the outside sweep flag pattern
  // "0 1 1" appears once per arc, i.e. at least twice.
  let mut count = 0
  let pat = "0 1 1"
  let mut i = 0
  while i + pat.length() <= defs.length() {
    if defs.substring(start=i, end=i + pat.length()) == pat {
      count = count + 1
      i = i + pat.length()
    } else {
      i = i + 1
    }
  }
  assert_true(count >= 2)
}

///|
test "textSlantUp lays text on a straight slanted baseline" {
  let (body, defs) = warp_svg(Some("textSlantUp"))
  assert_true(body.contains("<textPath "))
  // Straight line is emitted as a two-point polyline (sampled L's).
  assert_true(defs.contains(" L "))
  assert_true(!defs.contains(" A "))
}

///|
test "textInflate warps real glyph outlines into a filled path" {
  ensure_test_font()
  let defs = SvgDefsCollector::new()
  let nodes = render_warped_text(
    warp_txbody_with_font("textInflate"),
    200.0,
    100.0,
    ColorResolveContext::empty(),
    defs,
  )
  let body = StringBuilder::new()
  match nodes {
    Some(ns) =>
      for n in ns {
        match n {
          @xml.Node::Element(e) => body.write_string(@markup.serialize_svg(e))
          _ => ()
        }
      }
    None => ()
  }
  let svg = body.to_string()
  // Envelope warp emits filled glyph outlines (not a <textPath>).
  assert_true(svg.contains("<path "))
  assert_true(svg.contains("fill-rule=\"evenodd\""))
  assert_true(svg.contains("data-ooxml-text-warp=\"textInflate\""))
  assert_true(!svg.contains("<textPath"))
}

///|
test "envelope profiles cover every documented envelope preset" {
  // The complete §20.1.10.76 envelope set must all yield a warp; only
  // the baseline-on-curve presets (handled elsewhere via textPath) and
  // truly unknown names return None here.
  for
    prst in [
      "textInflate", "textDeflate", "textInflateBottom", "textDeflateBottom", "textInflateTop",
      "textDeflateTop", "textDeflateInflate", "textDeflateInflateDeflate", "textCanUp",
      "textCanDown", "textTriangle", "textTriangleInverted", "textChevron", "textChevronInverted",
      "textCascadeUp", "textCascadeDown", "textFadeRight", "textFadeLeft", "textFadeUp",
      "textFadeDown",
    ] {
    assert_true(envelope_profiles(prst, 100.0) is Some(_))
  }
  // Baseline / arc families are not envelope warps; unknown names too.
  for prst in ["textArchUp", "textWave1", "textRingInside", "bogusPreset"] {
    assert_true(envelope_profiles(prst, 100.0) is None)
  }
}

///|
test "textFadeUp tapers the band width toward the top" {
  // The top row collapses toward the horizontal centre; verify the
  // left/right boundary fractions at v=0 (top) meet at 0.5 and at v=1
  // (bottom) span the full width.
  guard envelope_profiles("textFadeUp", 100.0) is Some(w) else {
    fail("textFadeUp must yield a warp")
  }
  assert_true(((w.left_x)(0.0) - 0.5).abs() < 1.0e-9)
  assert_true(((w.right_x)(0.0) - 0.5).abs() < 1.0e-9)
  assert_true(((w.left_x)(1.0) - 0.0).abs() < 1.0e-9)
  assert_true(((w.right_x)(1.0) - 1.0).abs() < 1.0e-9)
}

///|
test "font-less envelope warp and no-warp defer to span layout (None)" {
  // §20.1.10.76 envelope warps need per-glyph outline distortion that
  // the metrics-only font stack can't provide → None (flat fallback),
  // never a misleading fake.
  let defs = SvgDefsCollector::new()
  for
    prst in [
      "textInflate", "textDeflate", "textTriangle", "textChevron", "textCascadeUp",
      "textCanUp", "textFadeRight",
    ] {
    let n = render_warped_text(
      warp_txbody(Some(prst)),
      200.0,
      100.0,
      ColorResolveContext::empty(),
      defs,
    )
    assert_true(n is None)
  }
  // No prstTxWarp at all → None.
  let plain = render_warped_text(
    warp_txbody(None),
    200.0,
    100.0,
    ColorResolveContext::empty(),
    defs,
  )
  assert_true(plain is None)
}
