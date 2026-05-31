// §20.1.2.2.40 wps:txbx / §17.3.1 w:txbxContent — a WordprocessingShape
// text box must paint BOTH its outline geometry AND the text laid out
// inside its text rectangle.

///|
/// Parse a full WordprocessingML document XML string into a CT_Document.
fn doc_from_xml(xml : String) -> @domain.CT_Document raise {
  @domain.CT_Document::new(@xml.parse(@utf8.encode(xml[:])).root)
}

///|
test "render_svg paints a WordprocessingShape text box body" {
  ensure_wml_test_font()
  // A <w:drawing> with an inline wps:wsp carrying a rect geometry and a
  // txbxContent paragraph "BoxText".
  let xml =
    #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
    #|<w:body><w:p><w:r><w:drawing>
    #|<wp:inline><wp:extent cx="2743200" cy="914400"/><wp:docPr id="1" name="TextBox 1"/>
    #|<a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
    #|<wps:wsp>
    #|<wps:spPr><a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    #|<a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill>
    #|<a:ln><a:solidFill><a:srgbClr val="000000"/></a:solidFill></a:ln></wps:spPr>
    #|<wps:txbx><w:txbxContent><w:p><w:r><w:t>BoxText</w:t></w:r></w:p></w:txbxContent></wps:txbx>
    #|</wps:wsp>
    #|</a:graphicData></a:graphic></wp:inline>
    #|</w:drawing></w:r></w:p></w:body></w:document>
  let document = doc_from_xml(xml)
  let svg = render_svg(document).pages[0].svg
  // The shape geometry (the box) renders as a <path>.
  assert_true(svg.contains("<path "))
  // The text-box body text must reach the SVG.
  assert_true(svg.contains("BoxText"))
}

///|
test "render_svg paints a WordprocessingGroup of shapes" {
  ensure_wml_test_font()
  // A wpg:wgp with two child shapes (a rect at the left, an ellipse at
  // the right) in a 3in × 1in child coordinate space.
  let xml =
    #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
    #|<w:body><w:p><w:r><w:drawing>
    #|<wp:inline><wp:extent cx="2743200" cy="914400"/><wp:docPr id="1" name="Group 1"/>
    #|<a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup">
    #|<wpg:wgp>
    #|<wpg:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="2743200" cy="914400"/><a:chOff x="0" y="0"/><a:chExt cx="2743200" cy="914400"/></a:xfrm></wpg:grpSpPr>
    #|<wps:wsp><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="914400" cy="914400"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></wps:spPr></wps:wsp>
    #|<wps:wsp><wps:spPr><a:xfrm><a:off x="1828800" y="0"/><a:ext cx="914400" cy="914400"/></a:xfrm><a:prstGeom prst="ellipse"><a:avLst/></a:prstGeom></wps:spPr></wps:wsp>
    #|</wpg:wgp>
    #|</a:graphicData></a:graphic></wp:inline>
    #|</w:drawing></w:r></w:p></w:body></w:document>
  let document = doc_from_xml(xml)
  let svg = render_svg(document).pages[0].svg
  // Both child shapes paint: two <path> elements.
  assert_true(count_occurrences(svg, "<path ") >= 2)
}

///|
/// §20.1.2.2.6 `<wpg:grpSp>` — a group nested inside the top-level
/// `<wpg:wgp>` must be walked recursively so its child shapes paint too
/// (before the recursion was wired the nested group was skipped and its
/// shapes vanished).
test "render_svg recurses into a nested WordprocessingGroup (grpSp)" {
  ensure_wml_test_font()
  // wpg:wgp → wpg:grpSp → two shapes (rect + ellipse).  The nested
  // group spans the whole child space; its two shapes sit left and right.
  let xml =
    #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
    #|<w:body><w:p><w:r><w:drawing>
    #|<wp:inline><wp:extent cx="2743200" cy="914400"/><wp:docPr id="1" name="Group 1"/>
    #|<a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup">
    #|<wpg:wgp>
    #|<wpg:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="2743200" cy="914400"/><a:chOff x="0" y="0"/><a:chExt cx="2743200" cy="914400"/></a:xfrm></wpg:grpSpPr>
    #|<wpg:grpSp>
    #|<wpg:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="2743200" cy="914400"/><a:chOff x="0" y="0"/><a:chExt cx="2743200" cy="914400"/></a:xfrm></wpg:grpSpPr>
    #|<wps:wsp><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="914400" cy="914400"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></wps:spPr></wps:wsp>
    #|<wps:wsp><wps:spPr><a:xfrm><a:off x="1828800" y="0"/><a:ext cx="914400" cy="914400"/></a:xfrm><a:prstGeom prst="ellipse"><a:avLst/></a:prstGeom></wps:spPr></wps:wsp>
    #|</wpg:grpSp>
    #|</wpg:wgp>
    #|</a:graphicData></a:graphic></wp:inline>
    #|</w:drawing></w:r></w:p></w:body></w:document>
  let document = doc_from_xml(xml)
  let svg = render_svg(document).pages[0].svg
  // The nested group's two shapes both paint: recursion reached them.
  assert_true(count_occurrences(svg, "<path ") >= 2)
}

///|
test "render_svg paints a WordprocessingCanvas with a shape" {
  ensure_wml_test_font()
  // A wpc:wpc with a white background and one rect shape placed at EMU
  // (457200, 228600) = (0.5in, 0.25in).
  let xml =
    #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
    #|<w:body><w:p><w:r><w:drawing>
    #|<wp:inline><wp:extent cx="2743200" cy="914400"/><wp:docPr id="1" name="Canvas 1"/>
    #|<a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas">
    #|<wpc:wpc>
    #|<wpc:bg><a:solidFill><a:srgbClr val="EEEEEE"/></a:solidFill></wpc:bg>
    #|<wps:wsp><wps:spPr><a:xfrm><a:off x="457200" y="228600"/><a:ext cx="914400" cy="457200"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></wps:spPr></wps:wsp>
    #|</wpc:wpc>
    #|</a:graphicData></a:graphic></wp:inline>
    #|</w:drawing></w:r></w:p></w:body></w:document>
  let document = doc_from_xml(xml)
  let svg = render_svg(document).pages[0].svg
  // Background rect + shape path both present.
  assert_true(svg.contains("fill=\"#EEEEEE\""))
  assert_true(svg.contains("<path "))
}

///|
/// §20.4.2.3 — a floating anchored picture with wrapSquare must be
/// lifted out of the inline flow (painted as a positioned <image>) and
/// the surrounding paragraph text must reflow into a narrower band
/// beside it.  We assert the float image renders AND a following
/// paragraph's text is present (laid out at the narrowed width).
test "render_svg reflows text around a wrapSquare floating drawing" {
  ensure_wml_test_font()
  let resolver = fn(rid : String) -> ResolvedImage? {
    if rid == "rIdFloat" {
      Some({ mime_type: "image/png", base64_data: "AAAA" })
    } else {
      None
    }
  }
  let xml =
    #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
    #|<w:body><w:p><w:r><w:drawing>
    #|<wp:anchor distL="114300" distR="114300" behindDoc="0" relativeHeight="0" locked="0" layoutInCell="1" allowOverlap="1">
    #|<wp:simplePos x="0" y="0"/>
    #|<wp:positionH relativeFrom="column"><wp:align>left</wp:align></wp:positionH>
    #|<wp:positionV relativeFrom="paragraph"><wp:posOffset>0</wp:posOffset></wp:positionV>
    #|<wp:extent cx="914400" cy="914400"/>
    #|<wp:wrapSquare wrapText="bothSides"/>
    #|<wp:docPr id="2" name="Float 1"/>
    #|<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
    #|<pic:pic><pic:blipFill><a:blip r:embed="rIdFloat"/></pic:blipFill></pic:pic>
    #|</a:graphicData></a:graphic></wp:anchor>
    #|</w:drawing></w:r></w:p>
    #|<w:p><w:r><w:t>This paragraph wraps beside the floating image on the left side.</w:t></w:r></w:p>
    #|</w:body></w:document>
  let document = doc_from_xml(xml)
  let svg = render_svg(document, image_resolver=resolver).pages[0].svg
  // The float image is painted (lifted out of the inline flow).
  assert_true(svg.contains("<image "))
  // The wrapping body text is present.
  assert_true(svg.contains("This paragraph wraps"))
}

///|
test "render_svg text box without a body still paints its outline" {
  ensure_wml_test_font()
  let xml =
    #|<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
    #|<w:body><w:p><w:r><w:drawing>
    #|<wp:inline><wp:extent cx="2743200" cy="914400"/><wp:docPr id="1" name="TextBox 1"/>
    #|<a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
    #|<wps:wsp><wps:spPr><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></wps:spPr></wps:wsp>
    #|</a:graphicData></a:graphic></wp:inline>
    #|</w:drawing></w:r></w:p></w:body></w:document>
  let document = doc_from_xml(xml)
  let svg = render_svg(document).pages[0].svg
  assert_true(svg.contains("<path "))
}
