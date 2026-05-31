// §21.4.4 SmartArt colour resolution — per-style-label fill / text
// colour lists and the dataModel background fill.

///|
fn dgm_parse(src : String) -> @xml.Element {
  (try! @xml.parse(@utf8.encode(src[:]))).root
}

///|
test "colors_by_style_label maps each styleLbl to its fillClrLst" {
  let cd = dgm_parse(
    (
      #|<dgm:colorsDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
      #|<dgm:styleLbl name="node0"><dgm:fillClrLst><a:srgbClr val="FF0000"/></dgm:fillClrLst></dgm:styleLbl>
      #|<dgm:styleLbl name="node1"><dgm:fillClrLst><a:srgbClr val="00FF00"/></dgm:fillClrLst>
      #|<dgm:txFillClrLst><a:srgbClr val="0000FF"/></dgm:txFillClrLst></dgm:styleLbl>
      #|</dgm:colorsDef>
    ),
  )
  let ctx = ColorResolveContext::empty()
  let fills = colors_by_style_label(Some(cd), ctx)
  assert_eq(fills.get("node0").unwrap()[0], "#FF0000")
  assert_eq(fills.get("node1").unwrap()[0], "#00FF00")
  // Text colours come from txFillClrLst — only node1 declares one.
  let texts = colors_by_style_label(Some(cd), ctx, list_name="txFillClrLst")
  assert_eq(texts.get("node1").unwrap()[0], "#0000FF")
  assert_true(texts.get("node0") is None)
  // The default palette is the first styleLbl's fill list.
  assert_eq(colors_palette(Some(cd), ctx)[0], "#FF0000")
}

///|
test "colors_palette falls back to the built-in palette without a colorsDef" {
  let ctx = ColorResolveContext::empty()
  let pal = colors_palette(None, ctx)
  assert_true(pal.length() >= 6)
  assert_eq(pal[0], "#4472C4")
}

///|
test "emit_diagram_background renders a rect for a solid dgm:bg fill" {
  let dm = dgm_parse(
    (
      #|<dgm:dataModel xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
      #|<dgm:bg><a:solidFill><a:srgbClr val="EEEEEE"/></a:solidFill></dgm:bg>
      #|<dgm:ptLst/></dgm:dataModel>
    ),
  )
  let ctx = ColorResolveContext::empty()
  match emit_diagram_background(dm, 200.0, 100.0, ctx) {
    Some(node) => {
      let svg = match node {
        @xml.Node::Element(e) => @markup.serialize_svg(e)
        _ => ""
      }
      assert_true(svg.contains("<rect "))
      assert_true(svg.contains("width=\"200\""))
      assert_true(svg.contains("#eeeeee") || svg.contains("#EEEEEE"))
    }
    None => fail("expected a background rect for a solid dgm:bg fill")
  }
}

///|
test "emit_diagram_background returns None when no dgm:bg is present" {
  let dm = dgm_parse(
    (
      #|<dgm:dataModel xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram">
      #|<dgm:ptLst/></dgm:dataModel>
    ),
  )
  let ctx = ColorResolveContext::empty()
  assert_true(emit_diagram_background(dm, 200.0, 100.0, ctx) is None)
}

///|
/// §20.1.10.56 — a SmartArt node whose preset is neither ellipse,
/// roundRect nor triangle must render its FAITHFUL geometry (a real
/// `<path>` translated into the node's bounds) via the shared
/// preset-geometry library, not degrade to a plain bounding `<rect>`.
test "emit_node_shape renders a non-trivial preset via the shared geometry" {
  let nb : @diagram_layout.NodeBounds = {
    point_id: "p1",
    bounds: { x: 10.0, y: 20.0, width: 100.0, height: 50.0 },
    shape: @preset_geometry.ShapeChevron,
    style_lbl: None,
  }
  let buf = StringBuilder::new()
  for n in emit_node_shape(nb, "#4472C4") {
    match n {
      @xml.Node::Element(e) => buf.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  let svg = buf.to_string()
  // A chevron is a real path translated to (10, 20), not a bounding rect.
  assert_true(svg.contains("<path "))
  assert_true(svg.contains("translate(10"))
  assert_true(svg.contains("fill=\"#4472C4\""))
}
