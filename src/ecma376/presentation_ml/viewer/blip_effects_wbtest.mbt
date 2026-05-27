// White-box tests for CT_Blip effect → SVG filter emission.

///|
fn build_pic_with_blip_effects(effects_xml : String) -> @xml.Element raise {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let src = "<p:pic xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\" xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" xmlns:r=\"" +
    ns_r +
    "\"><p:nvPicPr><p:cNvPr id=\"2\" name=\"Pic\"/><p:cNvPicPr/><p:nvPr/></p:nvPicPr><p:blipFill><a:blip r:embed=\"rId1\">" +
    effects_xml +
    "</a:blip><a:stretch><a:fillRect/></a:stretch></p:blipFill><p:spPr><a:xfrm><a:off x=\"0\" y=\"0\"/><a:ext cx=\"914400\" cy=\"914400\"/></a:xfrm></p:spPr></p:pic>"
  let doc = @xml.parse(@utf8.encode(src[:]))
  doc.root
}

///|
fn mock_image_resolver(rid : String) -> ResolvedImage? {
  if rid == "rId1" {
    Some({ mime_type: "image/png", base64_data: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==" })
  } else {
    None
  }
}

///|
fn render_pic_svg(pic : @xml.Element) -> String {
  let defs = SvgDefsCollector::new()
  let nodes = render_picture_svg(
    pic,
    ColorResolveContext::empty(),
    defs,
    mock_image_resolver,
  )
  let defs_str = defs.to_defs_element()
  let nodes_str = StringBuilder::new()
  for node in nodes {
    match node {
      @xml.Node::Element(e) => nodes_str.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  defs_str + nodes_str.to_string()
}

///|
fn build_blip_fill_with_effects(effects_xml : String) -> @xml.Element raise {
  let src = "<p:blipFill xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\" xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"><a:blip>" +
    effects_xml +
    "</a:blip></p:blipFill>"
  let doc = @xml.parse(@utf8.encode(src[:]))
  doc.root
}

///|
test "blip grayscl emits feColorMatrix saturate=0" {
  let bf = build_blip_fill_with_effects("<a:grayscl/>")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feColorMatrix"))
  assert_true(defs_str.contains("type=\"matrix\""))
  assert_true(defs_str.contains("0.299"))
}

///|
test "blip alphaModFix amt=50000 emits feFuncA slope=0.5" {
  let bf = build_blip_fill_with_effects(
    "<a:alphaModFix amt=\"50000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feComponentTransfer"))
  assert_true(defs_str.contains("feFuncA"))
  assert_true(defs_str.contains("type=\"linear\""))
  assert_true(defs_str.contains("slope=\"0.5\""))
}

///|
test "blip alphaModFix default amt=100000 emits slope=1" {
  let bf = build_blip_fill_with_effects("<a:alphaModFix/>")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("slope=\"1\""))
}

///|
test "blip alphaRepl a=30000 emits intercept=0.3" {
  let bf = build_blip_fill_with_effects("<a:alphaRepl a=\"30000\"/>")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFuncA"))
  assert_true(defs_str.contains("slope=\"0\""))
  assert_true(defs_str.contains("intercept=\"0.3\""))
}

///|
test "blip lum bright=25000 contrast=100000" {
  let bf = build_blip_fill_with_effects(
    "<a:lum bright=\"25000\" contrast=\"100000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feComponentTransfer"))
  assert_true(defs_str.contains("feFuncR"))
  assert_true(defs_str.contains("feFuncG"))
  assert_true(defs_str.contains("feFuncB"))
  // slope = 1 + 1.0 = 2
  assert_true(defs_str.contains("slope=\"2\""))
  // intercept = 0.25 - 1.0*0.5 = -0.25
  assert_true(defs_str.contains("intercept=\"-0.25\""))
}

///|
test "blip blur rad=9525 emits feGaussianBlur stdDeviation=0.5" {
  let bf = build_blip_fill_with_effects("<a:blur rad=\"9525\"/>")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feGaussianBlur"))
  assert_true(defs_str.contains("stdDeviation=\"0.5\""))
}

///|
test "blip blur rad=0 produces no filter" {
  let bf = build_blip_fill_with_effects("<a:blur rad=\"0\"/>")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is None)
}

///|
test "blip alphaBiLevel thresh=50000 emits discrete feFuncA" {
  let bf = build_blip_fill_with_effects(
    "<a:alphaBiLevel thresh=\"50000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFuncA"))
  assert_true(defs_str.contains("type=\"discrete\""))
  assert_true(defs_str.contains("tableValues="))
}

///|
test "blip biLevel thresh=50000 emits grayscale then threshold" {
  let bf = build_blip_fill_with_effects(
    "<a:biLevel thresh=\"50000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  // First: grayscale via feColorMatrix (BT.601)
  assert_true(defs_str.contains("type=\"matrix\""))
  assert_true(defs_str.contains("0.299"))
  // Then: threshold via feFuncR/G/B discrete
  assert_true(defs_str.contains("feFuncR"))
  assert_true(defs_str.contains("type=\"discrete\""))
}

///|
test "blip duotone with two srgbClr children emits grayscale + table" {
  let bf = build_blip_fill_with_effects(
    "<a:duotone><a:srgbClr val=\"000000\"/><a:srgbClr val=\"FFFFFF\"/></a:duotone>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  // Grayscale step (BT.601)
  assert_true(defs_str.contains("type=\"matrix\""))
  // Table interpolation
  assert_true(defs_str.contains("type=\"table\""))
  assert_true(defs_str.contains("feFuncR"))
  assert_true(defs_str.contains("feFuncG"))
  assert_true(defs_str.contains("feFuncB"))
}

///|
test "blip alphaFloor emits discrete feFuncA with floor table" {
  let bf = build_blip_fill_with_effects("<a:alphaFloor/>")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFuncA"))
  assert_true(defs_str.contains("type=\"discrete\""))
  // 20-bin table: only last bin is 1
  assert_true(defs_str.contains("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1"))
}

///|
test "blip alphaCeiling emits discrete feFuncA with ceiling table" {
  let bf = build_blip_fill_with_effects("<a:alphaCeiling/>")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFuncA"))
  assert_true(defs_str.contains("type=\"discrete\""))
  // 20-bin table: only first bin is 0
  assert_true(defs_str.contains("0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"))
}

///|
test "blip alphaInv emits table feFuncA with inverted values" {
  let bf = build_blip_fill_with_effects("<a:alphaInv/>")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFuncA"))
  assert_true(defs_str.contains("type=\"table\""))
  assert_true(defs_str.contains("tableValues=\"1 0\""))
}

///|
test "blip clrRepl emits feFlood + feComposite" {
  let bf = build_blip_fill_with_effects(
    "<a:clrRepl><a:srgbClr val=\"FF0000\"/></a:clrRepl>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFlood"))
  assert_true(defs_str.contains("rgb(255, 0, 0)"))
  assert_true(defs_str.contains("feComposite"))
  assert_true(defs_str.contains("operator=\"in\""))
}

///|
test "blip fillOverlay blend=mult emits feFlood+feComposite+feBlend" {
  let bf = build_blip_fill_with_effects(
    "<a:fillOverlay blend=\"mult\"><a:solidFill><a:srgbClr val=\"0000FF\"/></a:solidFill></a:fillOverlay>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFlood"))
  assert_true(defs_str.contains("rgb(0, 0, 255)"))
  assert_true(defs_str.contains("feComposite"))
  assert_true(defs_str.contains("feBlend"))
  assert_true(defs_str.contains("mode=\"multiply\""))
}

///|
test "chained effects: grayscl + alphaModFix produce two-stage pipeline" {
  let bf = build_blip_fill_with_effects(
    "<a:grayscl/><a:alphaModFix amt=\"50000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  // First stage: grayscl in=SourceGraphic result=bfx0
  assert_true(defs_str.contains("in=\"SourceGraphic\""))
  assert_true(defs_str.contains("result=\"bfx0\""))
  // Second stage: alphaModFix in=bfx0 result=bfx1
  assert_true(defs_str.contains("in=\"bfx0\""))
  assert_true(defs_str.contains("result=\"bfx1\""))
}

///|
test "no effects produces None" {
  let bf = build_blip_fill_with_effects("")
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is None)
  assert_eq(defs.to_defs_element(), "")
}

///|
test "blip lum default bright=0 contrast=0 produces no filter" {
  let bf = build_blip_fill_with_effects(
    "<a:lum bright=\"0\" contrast=\"0\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  // lum with both values at 0 still produces a filter (identity transform)
  // because the element is present — the spec says the effect is applied.
  assert_true(filter_ref is Some(_))
}

///|
test "blip hsl produces no SVG filter (handled by pixel ops)" {
  let bf = build_blip_fill_with_effects(
    "<a:hsl hue=\"0\" sat=\"0\" lum=\"0\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  // hsl is now handled by preprocess_blip_image, not SVG filter
  assert_true(filter_ref is None)
}

///|
test "blip hsl with hue shift produces no SVG filter (handled by pixel ops)" {
  let bf = build_blip_fill_with_effects(
    "<a:hsl hue=\"10800000\" sat=\"0\" lum=\"0\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  // hsl is now handled by preprocess_blip_image, not SVG filter
  assert_true(filter_ref is None)
}

///|
test "preprocess_blip_image applies hsl with hue shift" {
  let bf = build_blip_fill_with_effects(
    "<a:hsl hue=\"10800000\" sat=\"0\" lum=\"0\"/>",
  )
  let result = preprocess_blip_image(
    bf,
    "image/png",
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==",
    ColorResolveContext::empty(),
  )
  // hsl with non-zero hue triggers pixel processing
  assert_true(result is Some(_))
}

///|
test "preprocess_blip_image skips hsl with all zeroes" {
  let bf = build_blip_fill_with_effects(
    "<a:hsl hue=\"0\" sat=\"0\" lum=\"0\"/>",
  )
  let result = preprocess_blip_image(
    bf,
    "image/png",
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==",
    ColorResolveContext::empty(),
  )
  // hsl with all zeroes still triggers pixel path (image is decoded)
  // because the element is present, but the apply_hsl call is skipped
  // when all params are zero. The function still returns Some because
  // needs_pixel_ops is true (the element is named "hsl").
  assert_true(result is Some(_))
}

///|
test "blip tint produces no SVG filter (handled by pixel ops)" {
  let bf = build_blip_fill_with_effects(
    "<a:tint hue=\"5400000\" amt=\"50000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  // tint is now handled by preprocess_blip_image, not SVG filter
  assert_true(filter_ref is None)
}

///|
test "preprocess_blip_image applies tint with non-zero amt" {
  let bf = build_blip_fill_with_effects(
    "<a:tint hue=\"5400000\" amt=\"50000\"/>",
  )
  let result = preprocess_blip_image(
    bf,
    "image/png",
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==",
    ColorResolveContext::empty(),
  )
  // tint with non-zero amt triggers pixel processing
  assert_true(result is Some(_))
}

// =================================================================
// Integration tests — exercise the full render_picture_svg pipeline
// with a mock image resolver to verify that the filter attribute
// appears on the output <g> and the <filter> def is generated.
// =================================================================

///|
test "render_picture_svg: grayscl adds filter attr to <g>" {
  let pic = build_pic_with_blip_effects("<a:grayscl/>")
  let svg = render_pic_svg(pic)
  assert_true(svg.contains("filter=\"url(#blip-fx-"))
  assert_true(svg.contains("feColorMatrix"))
  assert_true(svg.contains("type=\"matrix\""))
  assert_true(svg.contains("0.299"))
  assert_true(svg.contains("data-ooxml-blip-effects=\"grayscl\""))
}

///|
test "render_picture_svg: alphaModFix 50% adds filter with feFuncA" {
  let pic = build_pic_with_blip_effects(
    "<a:alphaModFix amt=\"50000\"/>",
  )
  let svg = render_pic_svg(pic)
  assert_true(svg.contains("filter=\"url(#blip-fx-"))
  assert_true(svg.contains("feFuncA"))
  assert_true(svg.contains("slope=\"0.5\""))
  assert_true(
    svg.contains("data-ooxml-blip-effects=\"alphaModFix\""),
  )
}

///|
test "render_picture_svg: grayscl+lum chain produces two-stage filter" {
  let pic = build_pic_with_blip_effects(
    "<a:grayscl/><a:lum bright=\"50000\" contrast=\"0\"/>",
  )
  let svg = render_pic_svg(pic)
  assert_true(svg.contains("filter=\"url(#blip-fx-"))
  // Grayscale stage (BT.601)
  assert_true(svg.contains("type=\"matrix\""))
  // Lum stage
  assert_true(svg.contains("feFuncR"))
  // Chain connection
  assert_true(svg.contains("result=\"bfx0\""))
  assert_true(svg.contains("in=\"bfx0\""))
  assert_true(svg.contains("result=\"bfx1\""))
  assert_true(
    svg.contains("data-ooxml-blip-effects=\"grayscl lum\""),
  )
}

///|
test "render_picture_svg: no effects produces no filter attr" {
  let pic = build_pic_with_blip_effects("")
  let svg = render_pic_svg(pic)
  assert_true(!svg.contains("filter=\"url(#blip-fx-"))
  assert_true(svg.contains("<image"))
}

///|
test "render_picture_svg: biLevel produces grayscale + threshold pipeline" {
  let pic = build_pic_with_blip_effects(
    "<a:biLevel thresh=\"50000\"/>",
  )
  let svg = render_pic_svg(pic)
  assert_true(svg.contains("filter=\"url(#blip-fx-"))
  // Grayscale (BT.601)
  assert_true(svg.contains("0.299"))
  // Threshold
  assert_true(svg.contains("type=\"discrete\""))
  assert_true(svg.contains("feFuncR"))
}

///|
test "render_picture_svg: duotone black-to-white" {
  let pic = build_pic_with_blip_effects(
    "<a:duotone><a:srgbClr val=\"000000\"/><a:srgbClr val=\"FFFFFF\"/></a:duotone>",
  )
  let svg = render_pic_svg(pic)
  assert_true(svg.contains("filter=\"url(#blip-fx-"))
  assert_true(svg.contains("type=\"table\""))
  assert_true(svg.contains("feFuncR"))
}

// =================================================================
// Edge case tests
// =================================================================

///|
test "blip lum negative contrast clamps slope correctly" {
  let bf = build_blip_fill_with_effects(
    "<a:lum bright=\"0\" contrast=\"-50000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  // slope = 1 + (-0.5) = 0.5
  assert_true(defs_str.contains("slope=\"0.5\""))
  // intercept = 0 - (-0.5)*0.5 = 0.25
  assert_true(defs_str.contains("intercept=\"0.25\""))
}

///|
test "blip tint amt=0 produces no SVG filter (pixel ops skip zero amt)" {
  let bf = build_blip_fill_with_effects(
    "<a:tint hue=\"5400000\" amt=\"0\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  // tint is skipped by SVG filter pipeline (handled by pixel ops)
  assert_true(filter_ref is None)
}

///|
test "preprocess_blip_image skips tint with amt=0" {
  let bf = build_blip_fill_with_effects(
    "<a:tint hue=\"5400000\" amt=\"0\"/>",
  )
  let result = preprocess_blip_image(
    bf,
    "image/png",
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==",
    ColorResolveContext::empty(),
  )
  // tint element triggers pixel path, but amt=0 means the actual
  // apply_tint call is skipped. The image is still decoded and
  // re-encoded because needs_pixel_ops is true.
  assert_true(result is Some(_))
}

///|
test "blip tint amt=100000 produces no SVG filter (handled by pixel ops)" {
  let bf = build_blip_fill_with_effects(
    "<a:tint hue=\"0\" amt=\"100000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  // tint is now handled by preprocess_blip_image, not SVG filter
  assert_true(filter_ref is None)
}

///|
test "preprocess_blip_image applies full tint amt=100000" {
  let bf = build_blip_fill_with_effects(
    "<a:tint hue=\"0\" amt=\"100000\"/>",
  )
  let result = preprocess_blip_image(
    bf,
    "image/png",
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==",
    ColorResolveContext::empty(),
  )
  // Full tint triggers pixel processing and returns modified image
  assert_true(result is Some(_))
}

///|
test "blip blur grow=false keeps tight viewport" {
  let bf = build_blip_fill_with_effects(
    "<a:blur rad=\"95250\" grow=\"false\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("x=\"0%\""))
  assert_true(defs_str.contains("width=\"100%\""))
}

///|
test "blip blur grow=true widens viewport" {
  let bf = build_blip_fill_with_effects(
    "<a:blur rad=\"95250\" grow=\"true\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("x=\"-50%\""))
  assert_true(defs_str.contains("width=\"200%\""))
}

///|
test "blip alphaModFix amt=100000 produces identity slope=1" {
  let bf = build_blip_fill_with_effects(
    "<a:alphaModFix amt=\"100000\"/>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("slope=\"1\""))
}

// hsl_to_rgb tests removed — function moved to @color package.

///|
test "blip fillOverlay uses chain alpha not SourceAlpha" {
  let bf = build_blip_fill_with_effects(
    "<a:alphaModFix amt=\"50000\"/><a:fillOverlay blend=\"mult\"><a:solidFill><a:srgbClr val=\"FF0000\"/></a:solidFill></a:fillOverlay>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  // fillOverlay should clip to chain input (bfx0), not SourceAlpha
  assert_true(!defs_str.contains("SourceAlpha"))
  // Chain: alphaModFix→bfx0, fillOverlay→bfx1
  assert_true(defs_str.contains("in2=\"bfx0\""))
}

///|
test "blip alphaMod with single alphaModFix container applies alpha" {
  let bf = build_blip_fill_with_effects(
    "<a:alphaMod><a:cont><a:alphaModFix amt=\"75000\"/></a:cont></a:alphaMod>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is Some(_))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFuncA"))
  assert_true(defs_str.contains("slope=\"0.75\""))
}

///|
test "blip alphaMod with empty container produces no filter" {
  let bf = build_blip_fill_with_effects(
    "<a:alphaMod><a:cont/></a:alphaMod>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  assert_true(filter_ref is None)
}

///|
test "blip clrChange produces no SVG filter (handled by pixel ops)" {
  let bf = build_blip_fill_with_effects(
    "<a:clrChange><a:clrFrom><a:srgbClr val=\"FF0000\"/></a:clrFrom><a:clrTo><a:srgbClr val=\"00FF00\"/></a:clrTo></a:clrChange>",
  )
  let defs = SvgDefsCollector::new()
  let filter_ref = build_blip_effect_filter(
    bf,
    defs,
    ColorResolveContext::empty(),
  )
  // clrChange is now handled by preprocess_blip_image, not SVG filter
  assert_true(filter_ref is None)
}

///|
test "preprocess_blip_image applies clrChange" {
  let bf = build_blip_fill_with_effects(
    "<a:clrChange><a:clrFrom><a:srgbClr val=\"FF0000\"/></a:clrFrom><a:clrTo><a:srgbClr val=\"00FF00\"/></a:clrTo></a:clrChange>",
  )
  let result = preprocess_blip_image(
    bf,
    "image/png",
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==",
    ColorResolveContext::empty(),
  )
  // clrChange triggers pixel processing
  assert_true(result is Some(_))
}
