///|
/// §20.1.10.15 ST_CompoundLine — `<a:ln @cmpd>` describes a COMPOUND
/// outline of multiple parallel sub-strokes across the total width
/// `@w`.  An SVG stroke is centred on the path and a single element's
/// stroke attributes cannot express parallel sub-strokes, so the
/// renderer LAYERS concentric strokes on the same geometry path: the
/// outer stroke at full width `w` in the line colour, then narrower
/// centred overlay stroke(s) in the shape's fill colour to carve the
/// gap(s).  These whitebox tests pin the band counts per `@cmpd`
/// value and confirm the default `sng` path stays a single stroke.

///|
/// Count the number of `<path` element openings in a fragment of SVG
/// markup.  Used to assert how many stroked copies of the geometry a
/// compound line emits.
fn count_substr(haystack : String, needle : String) -> Int {
  let mut count = 0
  let mut from = 0
  loop find_from(haystack, needle, from) {
    None => break
    Some(i) => {
      count = count + 1
      from = i + needle.length()
      continue find_from(haystack, needle, from)
    }
  }
  count
}

///|
/// Build a `<p:sp>` rect shape carrying a solid shape fill plus an
/// `<a:ln>` with the given width / compound class and a solid line
/// colour.  Mirrors the connector-test build idiom in
/// `viewer_wbtest.mbt`.
fn sp_rect_with_compound_line(
  line_w : String,
  cmpd : String?,
  line_hex : String,
  fill_hex : String?,
) -> @domain.CT_Slide {
  let ln_attrs : Array[@xml.Attribute] = [{ name: name("w"), value: line_w }]
  match cmpd {
    Some(c) => ln_attrs.push({ name: name("cmpd"), value: c })
    None => ()
  }
  let line_child : @xml.Node = @xml.Node::Element({
    name: name("ln"),
    attributes: ln_attrs,
    children: [
      @xml.Node::Element({
        name: name("solidFill"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("srgbClr"),
            attributes: [{ name: name("val"), value: line_hex }],
            children: [],
          }),
        ],
      }),
    ],
  })
  let sp_pr_children : Array[@xml.Node] = [
    @xml.Node::Element({
      name: name("xfrm"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("off"),
          attributes: [
            { name: name("x"), value: "0" },
            { name: name("y"), value: "0" },
          ],
          children: [],
        }),
        @xml.Node::Element({
          name: name("ext"),
          attributes: [
            { name: name("cx"), value: "914400" },
            { name: name("cy"), value: "457200" },
          ],
          children: [],
        }),
      ],
    }),
    @xml.Node::Element({
      name: name("prstGeom"),
      attributes: [{ name: name("prst"), value: "rect" }],
      children: [],
    }),
  ]
  match fill_hex {
    Some(hex) =>
      sp_pr_children.push(
        @xml.Node::Element({
          name: name("solidFill"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("srgbClr"),
              attributes: [{ name: name("val"), value: hex }],
              children: [],
            }),
          ],
        }),
      )
    None => ()
  }
  sp_pr_children.push(line_child)
  let sp : @xml.Node = @xml.Node::Element({
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: sp_pr_children,
      }),
    ],
  })
  @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: [sp],
          }),
        ],
      }),
    ],
  })
}

///|
/// §20.1.10.15 `cmpd="dbl"` — a double line is rendered as the full-
/// width outer stroke in the line colour plus ONE centred overlay
/// stroke in the shape's fill colour that carves the centre gap, so
/// the geometry path is stroked MORE THAN ONCE (outer + gap overlay).
test "compound line dbl emits an outer stroke + one fill-colour gap overlay" {
  let slide = sp_rect_with_compound_line(
    "38100",
    Some("dbl"),
    "0000FF",
    Some("FF0000"),
  )
  let svg = render_svg(slide)
  // The line colour stroke must be present (outer band).
  assert_true(svg.contains("stroke=\"#0000ff\""))
  // The fill colour carves the centre gap — one overlay stroke.
  assert_true(svg.contains("stroke=\"#ff0000\""))
  // Two distinct stroke-width values appear: the full 38100 outer and
  // the w/3 = 12700 gap overlay.
  assert_true(svg.contains("stroke-width=\"38100\""))
  assert_true(svg.contains("stroke-width=\"12700\""))
}

///|
/// §20.1.10.15 `cmpd="tri"` — a triple line reads as five bands
/// (line · gap · line · gap · line).  The renderer carves a wide
/// 3·w/5 gap in the fill colour, then restores the centre w/5 line in
/// the line colour, so the line colour appears on BOTH the outer band
/// and the restored core (two line-colour strokes) and the fill
/// colour carves the gap (one overlay) — three stroked geometry
/// copies total beyond the fill.
test "compound line tri carves two gaps via a wide overlay + restored core" {
  let slide = sp_rect_with_compound_line(
    "50000",
    Some("tri"),
    "0000FF",
    Some("FF0000"),
  )
  let svg = render_svg(slide)
  // Two line-colour strokes (outer full-width band + restored centre
  // core).
  assert_true(count_substr(svg, "stroke=\"#0000ff\"") == 2)
  // One fill-colour gap overlay.
  assert_true(count_substr(svg, "stroke=\"#ff0000\"") == 1)
}

///|
/// `sng` (the schema default) must keep EXACTLY one stroke on the
/// geometry path — no layering, no fill-colour overlay.  An ABSENT
/// `@cmpd` must behave identically (the default is `sng`).
test "compound line sng / absent cmpd emits exactly one geometry stroke" {
  // Explicit cmpd="sng".
  let slide_sng = sp_rect_with_compound_line(
    "38100",
    Some("sng"),
    "0000FF",
    Some("FF0000"),
  )
  let svg_sng = render_svg(slide_sng)
  // Only the line colour strokes the geometry; the fill colour is the
  // shape interior (a `fill=` attribute, never a `stroke=`).
  assert_true(count_substr(svg_sng, "stroke=\"#0000ff\"") == 1)
  assert_true(count_substr(svg_sng, "stroke=\"#ff0000\"") == 0)

  // Absent cmpd → same single-stroke output.
  let slide_abs = sp_rect_with_compound_line(
    "38100",
    None,
    "0000FF",
    Some("FF0000"),
  )
  let svg_abs = render_svg(slide_abs)
  assert_true(count_substr(svg_abs, "stroke=\"#0000ff\"") == 1)
  assert_true(count_substr(svg_abs, "stroke=\"#ff0000\"") == 0)
}

///|
/// §20.1.10.15 — unit-level pin on `build_compound_line_nodes`: the
/// exact node counts per compound class.  dbl = 2 nodes (outer +
/// 1 gap), tri = 3 nodes (outer + wide gap + restored core),
/// thickThin / thinThick = 2 nodes (outer + 1 centred gap), and
/// sng = None (caller keeps its single-element output).
test "build_compound_line_nodes node counts per cmpd class" {
  let path_d = "M 0 0 L 100 0 L 100 50 L 0 50 Z"
  let stroke_attrs : Array[@xml.Attribute] = [
    @markup.attr("stroke", "#0000ff"),
    @markup.attr("stroke-width", "60000"),
  ]
  let fill_attrs : Array[@xml.Attribute] = [@markup.attr("fill", "#ff0000")]

  // sng → None (single-element path preserved).
  assert_true(
    build_compound_line_nodes(path_d, "sng", fill_attrs, stroke_attrs) is None,
  )

  // dbl → outer + one gap overlay = 2 nodes.
  match build_compound_line_nodes(path_d, "dbl", fill_attrs, stroke_attrs) {
    Some(nodes) => assert_eq(nodes.length(), 2)
    None => fail("dbl should produce compound nodes")
  }

  // tri → outer + wide gap + restored core = 3 nodes.
  match build_compound_line_nodes(path_d, "tri", fill_attrs, stroke_attrs) {
    Some(nodes) => assert_eq(nodes.length(), 3)
    None => fail("tri should produce compound nodes")
  }

  // thickThin / thinThick → outer + one centred gap = 2 nodes.
  match
    build_compound_line_nodes(path_d, "thickThin", fill_attrs, stroke_attrs) {
    Some(nodes) => assert_eq(nodes.length(), 2)
    None => fail("thickThin should produce compound nodes")
  }
  match
    build_compound_line_nodes(path_d, "thinThick", fill_attrs, stroke_attrs) {
    Some(nodes) => assert_eq(nodes.length(), 2)
    None => fail("thinThick should produce compound nodes")
  }
}

///|
/// §20.1.10.15 — the gap-colour approximation: when the shape has NO
/// usable fill (`fill="none"` / a gradient `url(#…)`), the gap cannot
/// be carved with the interior colour, so the renderer falls back to
/// `white` (documented approximation).  A `none` overlay would not
/// carve the gap at all, collapsing the compound line back to a
/// single stroke.
test "build_compound_line_nodes gap falls back to white when fill is none" {
  let path_d = "M 0 0 L 100 100"
  let stroke_attrs : Array[@xml.Attribute] = [
    @markup.attr("stroke", "#0000ff"),
    @markup.attr("stroke-width", "30000"),
  ]
  let nodes = match
    build_compound_line_nodes(
      path_d,
      "dbl",
      [@markup.attr("fill", "none")],
      stroke_attrs,
    ) {
    Some(n) => n
    None => {
      fail("dbl should produce compound nodes")
      []
    }
  }
  // The gap overlay (second node) is painted white.
  let mut found_white_gap = false
  for n in nodes {
    match n {
      @xml.Node::Element(e) =>
        for a in e.attributes {
          if a.name.local_name == "stroke" && a.value == "white" {
            found_white_gap = true
          }
        }
      _ => ()
    }
  }
  assert_true(found_white_gap)
}
