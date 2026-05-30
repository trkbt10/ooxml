// §20.4.2.16 CT_WrapPath (wrapPolygon) — a wrapTight / wrapThrough
// anchor's irregular wrap boundary must drive a per-line VARIABLE band:
// each body line follows the polygon edge at its own height, not the
// float's rectangular bounding box.

///|
/// Parse a standalone `<w:drawing>` snippet (with the wp/w namespaces
/// declared on the root) into an element we can hand to the polygon
/// readers directly.
fn drawing_from_xml(xml : String) -> @xml.Element raise {
  @xml.parse(@utf8.encode(xml[:])).root
}

///|
test "read_wrap_polygon normalises EMU vertices into 0..1 box fractions" {
  // extent 1,000,000 × 1,000,000 EMU; a right-pointing triangle:
  // (0,0) → (1.0, 0.5) → (0, 1.0).
  let xml =
    (
      #|<w:drawing xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
      #|<wp:anchor><wp:extent cx="1000000" cy="1000000"/>
      #|<wp:wrapTight wrapText="bothSides"><wp:wrapPolygon edited="0">
      #|<wp:start x="0" y="0"/><wp:lineTo x="1000000" y="500000"/>
      #|<wp:lineTo x="0" y="1000000"/><wp:lineTo x="0" y="0"/>
      #|</wp:wrapPolygon></wp:wrapTight>
      #|</wp:anchor></w:drawing>
    )
  let drawing = drawing_from_xml(xml)
  let poly = read_wrap_polygon(drawing)
  assert_eq(poly.length(), 4)
  // Vertices come back as box-local fractions.
  fn vtx(i : Int, fx : Double, fy : Double) -> Unit raise {
    let (x, y) = poly[i]
    assert_true((x - fx).abs() < 1.0e-9)
    assert_true((y - fy).abs() < 1.0e-9)
  }

  vtx(0, 0.0, 0.0)
  vtx(1, 1.0, 0.5)
  vtx(2, 0.0, 1.0)
  vtx(3, 0.0, 0.0)
}

///|
test "read_wrap_polygon returns empty for a rectangular (no-polygon) anchor" {
  let xml =
    (
      #|<w:drawing xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
      #|<wp:anchor><wp:extent cx="1000000" cy="1000000"/>
      #|<wp:wrapSquare wrapText="bothSides"/>
      #|</wp:anchor></w:drawing>
    )
  let drawing = drawing_from_xml(xml)
  assert_eq(read_wrap_polygon(drawing).length(), 0)
}

///|
test "polygon_x_span_at follows the triangle's right edge by height" {
  // Same right-pointing triangle, in box-local fractions.
  let poly = [(0.0, 0.0), (1.0, 0.5), (0.0, 1.0), (0.0, 0.0)]
  // Near the top the right edge is close to the apex's base (small x);
  // at y=0.4 the upper edge (0,0)->(1,0.5) sits at x=0.8.
  match polygon_x_span_at(poly, 0.4) {
    Some((min_fx, max_fx)) => {
      assert_true((min_fx - 0.0).abs() < 1.0e-9)
      assert_true((max_fx - 0.8).abs() < 1.0e-9)
    }
    None => fail("expected a span at fy=0.4")
  }
  // At y=0.2 the right edge is at x=0.4 — narrower band higher up.
  match polygon_x_span_at(poly, 0.2) {
    Some((_, max_fx)) => assert_true((max_fx - 0.4).abs() < 1.0e-9)
    None => fail("expected a span at fy=0.2")
  }
}

///|
test "polygon_x_span_at returns None above/below the polygon" {
  let poly = [(0.0, 0.25), (1.0, 0.5), (0.0, 0.75), (0.0, 0.25)]
  // y=0.1 is above every edge of the band → no crossing.
  assert_true(polygon_x_span_at(poly, 0.1) is None)
  assert_true(polygon_x_span_at(poly, 0.95) is None)
}

///|
test "wrapPolygon left-float drives a variable body band end to end" {
  ensure_wml_test_font()
  // A left-anchored side float (wrapTight + wrapPolygon) followed by a
  // long body paragraph: the text must render beside the float, and the
  // variable-band code path (per-line width following the polygon) must
  // run without error.
  let xml =
    (
      #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
      #|<w:body><w:p><w:r><w:drawing>
      #|<wp:anchor distT="0" distB="0" distL="114300" distR="114300" simplePos="0" relativeHeight="251658240" behindDoc="0" locked="0" layoutInCell="1" allowOverlap="1">
      #|<wp:simplePos x="0" y="0"/>
      #|<wp:positionH relativeFrom="column"><wp:align>left</wp:align></wp:positionH>
      #|<wp:positionV relativeFrom="paragraph"><wp:posOffset>0</wp:posOffset></wp:positionV>
      #|<wp:extent cx="1828800" cy="1828800"/>
      #|<wp:wrapTight wrapText="bothSides"><wp:wrapPolygon edited="0">
      #|<wp:start x="0" y="0"/><wp:lineTo x="1828800" y="914400"/>
      #|<wp:lineTo x="0" y="1828800"/><wp:lineTo x="0" y="0"/>
      #|</wp:wrapPolygon></wp:wrapTight>
      #|<wp:docPr id="1" name="Shape 1"/>
      #|<a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
      #|<wps:wsp><wps:spPr><a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
      #|<a:solidFill><a:srgbClr val="DDDDDD"/></a:solidFill></wps:spPr></wps:wsp>
      #|</a:graphicData></a:graphic></wp:anchor>
      #|</w:drawing></w:r>
      #|<w:r><w:t>The quick brown fox jumps over the lazy dog again and again across the page</w:t></w:r>
      #|</w:p></w:body></w:document>
    )
  let document = doc_from_xml(xml)
  let svg = render_svg(document).pages[0].svg
  // Body text reaches the SVG beside the float.
  assert_true(svg.contains("quick"))
}

///|
test "framePr paragraph inside a table cell wraps body text beside it" {
  ensure_wml_test_font()
  // A table cell whose first paragraph is a §17.3.1.11 text frame
  // (left-anchored, ~1in wide) followed by a body paragraph: the body
  // text must flow BESIDE the frame (composite band), with both the
  // frame text and the body text reaching the SVG.
  let xml =
    (
      #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
      #|<w:body><w:tbl>
      #|<w:tblPr><w:tblW w:w="8000" w:type="dxa"/></w:tblPr>
      #|<w:tblGrid><w:gridCol w:w="8000"/></w:tblGrid>
      #|<w:tr><w:tc>
      #|<w:tcPr><w:tcW w:w="8000" w:type="dxa"/></w:tcPr>
      #|<w:p><w:pPr><w:framePr w:w="1440" w:h="720" w:wrap="around" w:hSpace="180" w:hAnchor="text" w:vAnchor="text" w:xAlign="left"/></w:pPr><w:r><w:t>FRAMETEXT</w:t></w:r></w:p>
      #|<w:p><w:r><w:t>Beside paragraph flowing next to the frame inside the cell</w:t></w:r></w:p>
      #|</w:tc></w:tr>
      #|</w:tbl></w:body></w:document>
    )
  let document = doc_from_xml(xml)
  let svg = render_svg(document).pages[0].svg
  // Both the frame's text and the beside text render.
  assert_true(svg.contains("FRAMETEXT"))
  assert_true(svg.contains("Beside"))
}

///|
test "rectangular band: a tall body paragraph re-expands past the float" {
  ensure_wml_test_font()
  // A SHORT left-anchored square-wrap float (≈ one line tall) beside a
  // long body paragraph: early lines wrap narrow beside the float and
  // later lines re-expand to the full column.  The §17.3.1.11 band is
  // rectangular (no wrapPolygon), exercising the per-line transition.
  let xml =
    (
      #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
      #|<w:body><w:p><w:r><w:drawing>
      #|<wp:anchor distT="0" distB="0" distL="114300" distR="114300" simplePos="0" relativeHeight="251658240" behindDoc="0" locked="0" layoutInCell="1" allowOverlap="1">
      #|<wp:simplePos x="0" y="0"/>
      #|<wp:positionH relativeFrom="column"><wp:align>left</wp:align></wp:positionH>
      #|<wp:positionV relativeFrom="paragraph"><wp:posOffset>0</wp:posOffset></wp:positionV>
      #|<wp:extent cx="457200" cy="228600"/>
      #|<wp:wrapSquare wrapText="bothSides"/>
      #|<wp:docPr id="1" name="Shape 1"/>
      #|<a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
      #|<wps:wsp><wps:spPr><a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
      #|<a:solidFill><a:srgbClr val="DDDDDD"/></a:solidFill></wps:spPr></wps:wsp>
      #|</a:graphicData></a:graphic></wp:anchor>
      #|</w:drawing></w:r>
      #|<w:r><w:t>Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis nostrud exercitation</w:t></w:r>
      #|</w:p></w:body></w:document>
    )
  let document = doc_from_xml(xml)
  let page = render_svg(document).pages[0]
  // The paragraph renders without error and the body text is present.
  assert_true(page.svg.contains("Lorem"))
  // The float box (a grey rect) is emitted alongside.
  assert_true(page.svg.contains("#DDDDDD") || page.svg.contains("#dddddd"))
}
