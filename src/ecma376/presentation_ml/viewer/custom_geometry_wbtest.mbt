// White-box tests for the §20.1.9.8 custom-geometry (`<a:custGeom>`)
// path renderer.  These exercise the OOXML path command → SVG path
// translation, the path→box coordinate scaling, the guide-engine
// coordinate resolution, and the `<a:arcTo>` ellipse-to-SVG-arc math.

///|
/// Parse a `<a:custGeom>` fragment into its element.  The fragment is
/// wrapped with the DrawingML namespace so the local-name walker in
/// `render_custom_geometry` sees real `a:` children.
fn custgeom_make(inner : String) -> @xml.Element raise {
  let src = "<a:custGeom xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\">" +
    inner +
    "</a:custGeom>"
  @xml.parse(@utf8.encode(src[:])).root
}

///|
test "custGeom moveTo/lnTo/close maps to M/L/Z with 1:1 scale" {
  // Path coordinate space equals the rendered box (200x100) so no
  // scaling is applied — the emitted coordinates equal the inputs.
  let cg = custgeom_make(
    "<a:pathLst><a:path w=\"200\" h=\"100\">" +
    "<a:moveTo><a:pt x=\"0\" y=\"0\"/></a:moveTo>" +
    "<a:lnTo><a:pt x=\"200\" y=\"0\"/></a:lnTo>" +
    "<a:lnTo><a:pt x=\"100\" y=\"100\"/></a:lnTo>" +
    "<a:close/>" +
    "</a:path></a:pathLst>",
  )
  let d = render_custom_geometry(cg, 200.0, 100.0).unwrap()
  inspect(d, content="M 0 0 L 200 0 L 100 100 Z")
}

///|
test "custGeom scales path coordinate space into the rendered box" {
  // Path space is 100x100 but the shape is rendered at 300x200, so x
  // scales by 3 and y by 2.
  let cg = custgeom_make(
    "<a:pathLst><a:path w=\"100\" h=\"100\">" +
    "<a:moveTo><a:pt x=\"0\" y=\"0\"/></a:moveTo>" +
    "<a:lnTo><a:pt x=\"100\" y=\"50\"/></a:lnTo>" +
    "</a:path></a:pathLst>",
  )
  let d = render_custom_geometry(cg, 300.0, 200.0).unwrap()
  inspect(d, content="M 0 0 L 300 100")
}

///|
test "custGeom cubicBezTo and quadBezTo map to C and Q" {
  let cg = custgeom_make(
    "<a:pathLst><a:path w=\"100\" h=\"100\">" +
    "<a:moveTo><a:pt x=\"0\" y=\"0\"/></a:moveTo>" +
    "<a:cubicBezTo><a:pt x=\"10\" y=\"20\"/><a:pt x=\"30\" y=\"40\"/><a:pt x=\"50\" y=\"60\"/></a:cubicBezTo>" +
    "<a:quadBezTo><a:pt x=\"70\" y=\"80\"/><a:pt x=\"90\" y=\"100\"/></a:quadBezTo>" +
    "</a:path></a:pathLst>",
  )
  let d = render_custom_geometry(cg, 100.0, 100.0).unwrap()
  inspect(d, content="M 0 0 C 10 20 30 40 50 60 Q 70 80 90 100")
}

///|
test "custGeom resolves guide-named coordinates via the guide engine" {
  // `<a:pt x="hc" y="vc"/>` references the built-in centre guides
  // (hc = w/2, vc = h/2) in the path coordinate space (100x100), so
  // the point resolves to (50,50) then renders 1:1.
  let cg = custgeom_make(
    "<a:gdLst/><a:pathLst><a:path w=\"100\" h=\"100\">" +
    "<a:moveTo><a:pt x=\"hc\" y=\"vc\"/></a:moveTo>" +
    "<a:lnTo><a:pt x=\"r\" y=\"b\"/></a:lnTo>" +
    "</a:path></a:pathLst>",
  )
  let d = render_custom_geometry(cg, 100.0, 100.0).unwrap()
  // r = w = 100, b = h = 100.
  inspect(d, content="M 50 50 L 100 100")
}

///|
test "custGeom arcTo: quarter arc from 0deg sweeping +90deg" {
  // Current point starts at (wR, 0) relative to centre via the moveTo;
  // wR=50,hR=50, stAng=0, swAng=90deg (5400000 units). Centre is
  // (cur - wR*cos0, cur - hR*sin0) = (0,0) when moveTo is (50,0).
  // End point = (0 + 50*cos90, 0 + 50*sin90) = (0,50). Sweep is < 180
  // so large-arc-flag 0; positive sweep so sweep-flag 1.
  let cg = custgeom_make(
    "<a:pathLst><a:path w=\"100\" h=\"100\">" +
    "<a:moveTo><a:pt x=\"50\" y=\"0\"/></a:moveTo>" +
    "<a:arcTo wR=\"50\" hR=\"50\" stAng=\"0\" swAng=\"5400000\"/>" +
    "</a:path></a:pathLst>",
  )
  let d = render_custom_geometry(cg, 100.0, 100.0).unwrap()
  inspect(d, content="M 50 0 A 50 50 0 0 1 0 50")
}

///|
test "custGeom returns None when pathLst is absent" {
  let cg = custgeom_make("<a:avLst/>")
  match render_custom_geometry(cg, 100.0, 100.0) {
    None => ()
    Some(d) => fail("expected None for custGeom without pathLst, got " + d)
  }
}
