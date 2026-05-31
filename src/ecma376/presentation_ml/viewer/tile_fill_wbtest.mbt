// §20.1.8.58 `<a:tile>` — a tiled blip fill renders as an SVG
// `<pattern>`-filled rect repeating the image, not a single stretched
// image.

///|
/// A decodable 1×1 PNG (same fixture the blip-effect tests use).
let tile_test_png : String = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg=="

///|
fn tile_elt(attrs : Array[(String, String)]) -> @xml.Element {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: None, local_name: k, ns: None }, value: v })
  }
  {
    name: { prefix: Some("a"), local_name: "tile", ns: None },
    attributes: a,
    children: [],
  }
}

///|
test "build_tiled_blip_fill emits a pattern-filled rect" {
  let defs = SvgDefsCollector::new()
  let uri = "data:image/png;base64," + tile_test_png
  let nodes = build_tiled_blip_fill(
    tile_elt([("sx", "100000"), ("sy", "100000")]),
    "image/png",
    tile_test_png,
    uri,
    100.0,
    50.0,
    defs,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  match nodes {
    Some(ns) => {
      let svg = match ns[0] {
        @xml.Node::Element(e) => @markup.serialize_svg(e)
        _ => ""
      }
      // The shape is filled with the tile pattern, not a bare <image>.
      assert_true(svg.contains("<rect "))
      assert_true(svg.contains("fill=\"url(#blip-tile"))
    }
    None => fail("expected a tiled fill for a decodable PNG")
  }
}

///|
test "build_tiled_blip_fill returns None for an undecodable image" {
  let defs = SvgDefsCollector::new()
  match
    build_tiled_blip_fill(
      tile_elt([]),
      "image/png",
      "not-base64-png",
      "data:image/png;base64,xxx",
      100.0,
      100.0,
      defs,
      0.0,
      0.0,
      0.0,
      0.0,
    ) {
    None => ()
    Some(_) => fail("expected None when the image cannot be decoded")
  }
}

///|
/// §20.1.8.55 `<a:srcRect>` on a tiled `<a:blipFill>` — a crop of
/// l=25% r=25% (insets, as plain percentages here) selects the centre
/// 50 % width of the source.  The tiled pattern cell must therefore be
/// HALF as wide as the un-cropped tile (the cropped source scaled by
/// @sx=100 %), and the tile's `<image>` must be scaled-up and shifted
/// left so only that centre band lands in the tile viewport.
///
/// The fixture is a 1×1 PNG, so the un-cropped tile cell is 1×1; the
/// l=25%/r=25% crop yields a 0.5×1 cell with an image laid out by the
/// SAME `compute_cropped_image_layout` math the stretch path uses:
/// width back to 1 (full image scaled so the 50 % band fills 0.5) and
/// x=-0.25 (the cropped-out left quarter pushed out of the tile).
test "tiled blipFill with srcRect crops the repeated tile" {
  let defs = SvgDefsCollector::new()
  let uri = "data:image/png;base64," + tile_test_png
  let nodes = build_tiled_blip_fill(
    tile_elt([("sx", "100000"), ("sy", "100000")]),
    "image/png",
    tile_test_png,
    uri,
    100.0,
    50.0,
    defs,
    25.0, // l: inset 25 % from the left
    0.0, // t
    25.0, // r: inset 25 % from the right
    0.0, // b
  )
  match nodes {
    Some(_) => {
      let pattern_svg = defs.to_defs_element()
      // The pattern cell is the cropped source (centre 50 % width)
      // scaled by @sx=100 %: width 0.5 (NOT the un-cropped 1).
      assert_true(pattern_svg.contains("<pattern"))
      assert_true(pattern_svg.contains("width=\"0.5\""))
      // The tile's <image> is scaled back to full width (1) and shifted
      // left by the cropped-out quarter so only the centre band shows.
      assert_true(pattern_svg.contains("<image"))
      assert_true(pattern_svg.contains("x=\"-0.25\""))
    }
    None => fail("expected a tiled fill for a decodable PNG")
  }
}

///|
/// §20.1.8.58 — a tiled `<a:blipFill>` with NO `<a:srcRect>` (all-zero
/// insets) must render byte-identically to today: the pattern tile is
/// the full native image scaled by @sx/@sy, and the `<image>` sits at
/// x=0/y=0 with width/height equal to the tile cell.  This is the
/// control case for the crop test above.
test "tiled blipFill without srcRect is unchanged" {
  let defs = SvgDefsCollector::new()
  let uri = "data:image/png;base64," + tile_test_png
  let nodes = build_tiled_blip_fill(
    tile_elt([("sx", "100000"), ("sy", "100000")]),
    "image/png",
    tile_test_png,
    uri,
    100.0,
    50.0,
    defs,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  match nodes {
    Some(_) => {
      let pattern_svg = defs.to_defs_element()
      // Full 1×1 tile cell; image at the origin with no crop offset.
      assert_true(pattern_svg.contains("<pattern"))
      assert_true(pattern_svg.contains("width=\"1\""))
      assert_true(pattern_svg.contains("x=\"0\""))
      // No negative crop offset is emitted.
      assert_false(pattern_svg.contains("x=\"-"))
    }
    None => fail("expected a tiled fill for a decodable PNG")
  }
}
