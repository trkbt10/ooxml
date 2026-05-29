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
  { name: { prefix: Some("a"), local_name: "tile", ns: None }, attributes: a, children: [] }
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
    ) {
    None => ()
    Some(_) => fail("expected None when the image cannot be decoded")
  }
}
