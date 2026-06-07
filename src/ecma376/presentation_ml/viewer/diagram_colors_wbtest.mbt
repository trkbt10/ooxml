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
  assert_eq(fills.get("node0").unwrap()[0], "#ff0000")
  assert_eq(fills.get("node1").unwrap()[0], "#00ff00")
  // Text colours come from txFillClrLst — only node1 declares one.
  let texts = colors_by_style_label(Some(cd), ctx, list_name="txFillClrLst")
  assert_eq(texts.get("node1").unwrap()[0], "#0000ff")
  assert_true(texts.get("node0") is None)
  // The default palette is the first styleLbl's fill list.
  assert_eq(colors_palette(Some(cd), ctx)[0], "#ff0000")
}

///|
/// §21.4.4 coloursDef uses DrawingML EG_ColorChoice; resolving it
/// through `@paint` preserves the same transforms as ordinary fills.
test "diagram_color_choice_hex resolves DrawingML transforms through paint SoT" {
  let c = dgm_parse(
    (
      #|<a:srgbClr xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" val="FF0000">
      #|<a:alpha val="50000"/>
      #|</a:srgbClr>
    ),
  )
  let ctx = ColorResolveContext::empty()
  assert_eq(diagram_color_choice_hex(c, ctx).unwrap(), "rgba(255, 0, 0, 0.5)")
}

///|
/// §20.1.2.3 EG_ColorChoice includes preset colours, not just
/// srgbClr/schemeClr.
test "diagram_color_choice_hex resolves preset colors through paint SoT" {
  let c = dgm_parse(
    "<a:prstClr xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" val=\"red\"/>",
  )
  let ctx = ColorResolveContext::empty()
  assert_eq(diagram_color_choice_hex(c, ctx).unwrap(), "#ff0000")
}

///|
/// Unknown scheme colours are invalid input, not a request for the
/// Office accent1 fallback. The shared paint resolver reports this as
/// `none`, which the diagram palette drops.
test "diagram_color_choice_hex rejects invalid scheme colors" {
  let c = dgm_parse(
    "<a:schemeClr xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" val=\"notAColor\"/>",
  )
  let ctx = ColorResolveContext::empty()
  assert_true(diagram_color_choice_hex(c, ctx) is None)
}

///|
/// §21.4.5.10 — quickStyle/styleDef contributes style-label line
/// colours through `<a:style>/<a:lnRef>`.
test "style_line_colors_by_style_label maps quickStyle line colours" {
  let style_def = try! @dgm.CT_StyleDefinition::new(
    dgm_parse(
      (
        #|<dgm:styleDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
        #|<dgm:styleLbl name="node0"><a:style><a:lnRef idx="1"><a:srgbClr val="FF0000"/></a:lnRef></a:style></dgm:styleLbl>
        #|<dgm:styleLbl name="node1"><a:style><a:lnRef idx="1"><a:schemeClr val="accent2"/></a:lnRef></a:style></dgm:styleLbl>
        #|</dgm:styleDef>
      ),
    ),
  )
  let map = style_line_colors_by_style_label(
    Some(style_def),
    ColorResolveContext::empty(),
  )
  assert_eq(map.get("node0").unwrap(), "#ff0000")
  assert_eq(map.get("node1").unwrap(), "#ed7d31")
}

///|
test "render_diagram_svg connects dgm effectClrLst to quickStyle effectRef filters" {
  let theme_xml =
    #|<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office">
    #|<a:themeElements>
    #|<a:clrScheme name="Office">
    #|<a:dk1><a:srgbClr val="000000"/></a:dk1><a:lt1><a:srgbClr val="FFFFFF"/></a:lt1>
    #|<a:dk2><a:srgbClr val="000000"/></a:dk2><a:lt2><a:srgbClr val="FFFFFF"/></a:lt2>
    #|<a:accent1><a:srgbClr val="4472C4"/></a:accent1><a:accent2><a:srgbClr val="ED7D31"/></a:accent2>
    #|<a:accent3><a:srgbClr val="A5A5A5"/></a:accent3><a:accent4><a:srgbClr val="FFC000"/></a:accent4>
    #|<a:accent5><a:srgbClr val="5B9BD5"/></a:accent5><a:accent6><a:srgbClr val="70AD47"/></a:accent6>
    #|<a:hlink><a:srgbClr val="0563C1"/></a:hlink><a:folHlink><a:srgbClr val="954F72"/></a:folHlink>
    #|</a:clrScheme>
    #|<a:fontScheme name="Office">
    #|<a:majorFont><a:latin typeface="Calibri"/><a:ea typeface="Calibri"/><a:cs typeface="Calibri"/></a:majorFont>
    #|<a:minorFont><a:latin typeface="Calibri"/><a:ea typeface="Calibri"/><a:cs typeface="Calibri"/></a:minorFont>
    #|</a:fontScheme>
    #|<a:fmtScheme name="Office">
    #|<a:fillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:fillStyleLst>
    #|<a:lnStyleLst><a:ln/><a:ln/><a:ln/></a:lnStyleLst>
    #|<a:effectStyleLst>
    #|<a:effectStyle><a:effectLst><a:outerShdw blurRad="40000" dist="20000" dir="5400000"><a:srgbClr val="000000"><a:alpha val="50000"/></a:srgbClr></a:outerShdw></a:effectLst></a:effectStyle>
    #|<a:effectStyle><a:effectLst/></a:effectStyle>
    #|<a:effectStyle><a:effectLst/></a:effectStyle>
    #|</a:effectStyleLst>
    #|<a:bgFillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:bgFillStyleLst>
    #|</a:fmtScheme>
    #|</a:themeElements>
    #|</a:theme>
  let theme_ok = try @theme.read_theme(@utf8.encode(theme_xml[:])) catch {
    _ => abort("theme construction failed")
  } noraise {
    t => t
  }
  let frame = dgm_parse(
    (
      #|<p:graphicFrame xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
      #|<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/diagram"><dgm:relIds r:dm="rIdDm" r:lo="rIdLo" r:qs="rIdQs" r:cs="rIdCs"/></a:graphicData></a:graphic>
      #|</p:graphicFrame>
    ),
  )
  let data_model = dgm_parse(
    (
      #|<dgm:dataModel xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
      #|<dgm:ptLst><dgm:pt modelId="0" type="doc"/><dgm:pt modelId="1" type="node"><dgm:t><a:p><a:r><a:t>One</a:t></a:r></a:p></dgm:t></dgm:pt></dgm:ptLst>
      #|<dgm:cxnLst><dgm:cxn modelId="101" type="parOf" srcId="0" destId="1" srcOrd="0" destOrd="0"/></dgm:cxnLst>
      #|</dgm:dataModel>
    ),
  )
  let layout_def = dgm_parse(
    (
      #|<dgm:layoutDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" uniqueId="layout-id">
      #|<dgm:layoutNode name="root"><dgm:alg type="lin"/>
      #|<dgm:constrLst><dgm:constr type="w" val="1000000"/><dgm:constr type="h" val="500000"/></dgm:constrLst>
      #|<dgm:forEach name="each" axis="ch" ptType="node"><dgm:layoutNode name="box" styleLbl="node1"><dgm:alg type="sp"/><dgm:shape type="rect"/><dgm:presOf axis="self" ptType="all"/></dgm:layoutNode></dgm:forEach>
      #|</dgm:layoutNode></dgm:layoutDef>
    ),
  )
  let style_def = dgm_parse(
    (
      #|<dgm:styleDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" uniqueId="style-id">
      #|<dgm:styleLbl name="node1"><a:style><a:effectRef idx="1"/></a:style></dgm:styleLbl>
      #|</dgm:styleDef>
    ),
  )
  let colors_def = dgm_parse(
    (
      #|<dgm:colorsDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" uniqueId="colors-id">
      #|<dgm:styleLbl name="node1"><dgm:fillClrLst><a:srgbClr val="4472C4"/></dgm:fillClrLst><dgm:effectClrLst><a:srgbClr val="C00000"/></dgm:effectClrLst></dgm:styleLbl>
      #|</dgm:colorsDef>
    ),
  )
  let resolver = fn(rid : String) -> @xml.Element? {
    match rid {
      "rIdDm" => Some(data_model)
      "rIdLo" => Some(layout_def)
      "rIdQs" => Some(style_def)
      "rIdCs" => Some(colors_def)
      _ => None
    }
  }
  let defs = SvgDefsCollector::new()
  let nodes = render_diagram_svg(
    frame,
    2000000.0,
    1000000.0,
    resolver,
    ColorResolveContext::empty(),
    defs,
    theme=Some(theme_ok),
  )
  if nodes.length() == 0 {
    fail("expected a rendered diagram group")
  }
  let buf = StringBuilder::new()
  match defs.to_defs_node() {
    Some(d) =>
      match d {
        @xml.Node::Element(e) => buf.write_string(@markup.serialize_svg(e))
        _ => ()
      }
    None => fail("expected an effect filter definition")
  }
  for n in nodes {
    match n {
      @xml.Node::Element(e) => buf.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  let svg = buf.to_string()
  assert_true(svg.contains("<filter"))
  assert_true(svg.contains("feColorMatrix"))
  assert_true(svg.contains("filter=\"url(#effect-diagram-1)\""))
  assert_true(svg.contains("0.752"))
}

///|
test "render_diagram_svg connects dgm txPr and txEffectClrLst to text effects" {
  let frame = dgm_parse(
    (
      #|<p:graphicFrame xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
      #|<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/diagram"><dgm:relIds r:dm="rIdDm" r:lo="rIdLo" r:qs="rIdQs" r:cs="rIdCs"/></a:graphicData></a:graphic>
      #|</p:graphicFrame>
    ),
  )
  let data_model = dgm_parse(
    (
      #|<dgm:dataModel xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
      #|<dgm:ptLst><dgm:pt modelId="0" type="doc"/><dgm:pt modelId="1" type="node"><dgm:t><a:p><a:r><a:t>One</a:t></a:r></a:p></dgm:t></dgm:pt></dgm:ptLst>
      #|<dgm:cxnLst><dgm:cxn modelId="101" type="parOf" srcId="0" destId="1" srcOrd="0" destOrd="0"/></dgm:cxnLst>
      #|</dgm:dataModel>
    ),
  )
  let layout_def = dgm_parse(
    (
      #|<dgm:layoutDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" uniqueId="layout-id">
      #|<dgm:layoutNode name="root"><dgm:alg type="lin"/>
      #|<dgm:constrLst><dgm:constr type="w" val="1000000"/><dgm:constr type="h" val="500000"/></dgm:constrLst>
      #|<dgm:forEach name="each" axis="ch" ptType="node"><dgm:layoutNode name="box" styleLbl="node1"><dgm:alg type="sp"/><dgm:shape type="rect"/><dgm:presOf axis="self" ptType="all"/></dgm:layoutNode></dgm:forEach>
      #|</dgm:layoutNode></dgm:layoutDef>
    ),
  )
  let style_def = dgm_parse(
    (
      #|<dgm:styleDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" uniqueId="style-id">
      #|<dgm:styleLbl name="node1"><dgm:txPr><a:sp3d extrusionH="190500" contourW="38100"/></dgm:txPr></dgm:styleLbl>
      #|</dgm:styleDef>
    ),
  )
  let colors_def = dgm_parse(
    (
      #|<dgm:colorsDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" uniqueId="colors-id">
      #|<dgm:styleLbl name="node1"><dgm:fillClrLst><a:srgbClr val="4472C4"/></dgm:fillClrLst><dgm:txEffectClrLst><a:srgbClr val="C00000"/></dgm:txEffectClrLst></dgm:styleLbl>
      #|</dgm:colorsDef>
    ),
  )
  let resolver = fn(rid : String) -> @xml.Element? {
    match rid {
      "rIdDm" => Some(data_model)
      "rIdLo" => Some(layout_def)
      "rIdQs" => Some(style_def)
      "rIdCs" => Some(colors_def)
      _ => None
    }
  }
  let nodes = render_diagram_svg(
    frame,
    2000000.0,
    1000000.0,
    resolver,
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  if nodes.length() == 0 {
    fail("expected a rendered diagram group")
  }
  let svg = match nodes[0] {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(svg.contains("class=\"diagram-text-effect\""))
  assert_true(svg.contains("class=\"diagram-text-extrusion-effect\""))
  assert_true(svg.contains("class=\"diagram-text-contour-effect\""))
  assert_true(svg.contains("fill=\"#c00000\""))
  assert_true(svg.contains("stroke=\"#c00000\""))
}

///|
test "render_diagram_svg uses dgm prSet presStyleLbl for node colours" {
  let frame = dgm_parse(
    (
      #|<p:graphicFrame xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
      #|<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/diagram"><dgm:relIds r:dm="rIdDm" r:lo="rIdLo" r:qs="rIdQs" r:cs="rIdCs"/></a:graphicData></a:graphic>
      #|</p:graphicFrame>
    ),
  )
  let data_model = dgm_parse(
    (
      #|<dgm:dataModel xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
      #|<dgm:ptLst>
      #|<dgm:pt modelId="0" type="doc"/>
      #|<dgm:pt modelId="1" type="node"><dgm:prSet presStyleLbl="node2"/><dgm:t><a:p><a:r><a:t>One</a:t></a:r></a:p></dgm:t></dgm:pt>
      #|</dgm:ptLst>
      #|<dgm:cxnLst><dgm:cxn modelId="101" type="parOf" srcId="0" destId="1" srcOrd="0" destOrd="0"/></dgm:cxnLst>
      #|</dgm:dataModel>
    ),
  )
  let layout_def = dgm_parse(
    (
      #|<dgm:layoutDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" uniqueId="layout-id">
      #|<dgm:layoutNode name="root"><dgm:alg type="lin"/>
      #|<dgm:constrLst><dgm:constr type="w" val="1000000"/><dgm:constr type="h" val="500000"/></dgm:constrLst>
      #|<dgm:forEach name="each" axis="ch" ptType="node">
      #|<dgm:layoutNode name="box" styleLbl="node1"><dgm:alg type="sp"/><dgm:shape type="rect"/><dgm:presOf axis="self" ptType="all"/></dgm:layoutNode>
      #|</dgm:forEach>
      #|</dgm:layoutNode></dgm:layoutDef>
    ),
  )
  let style_def = dgm_parse(
    (
      #|<dgm:styleDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" uniqueId="style-id">
      #|<dgm:styleLbl name="node1"/><dgm:styleLbl name="node2"/>
      #|</dgm:styleDef>
    ),
  )
  let colors_def = dgm_parse(
    (
      #|<dgm:colorsDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" uniqueId="colors-id">
      #|<dgm:styleLbl name="node1"><dgm:fillClrLst><a:srgbClr val="00FF00"/></dgm:fillClrLst></dgm:styleLbl>
      #|<dgm:styleLbl name="node2"><dgm:fillClrLst><a:srgbClr val="FF0000"/></dgm:fillClrLst></dgm:styleLbl>
      #|</dgm:colorsDef>
    ),
  )
  let decoded_data = try! @diagram_layout.decode_data_model(
    try! @dgm.CT_DataModel::new(data_model),
  )
  assert_true(
    effective_point_style_label(decoded_data, "1", Some("node1")) ==
    Some("node2"),
  )
  let resolver = fn(rid : String) -> @xml.Element? {
    match rid {
      "rIdDm" => Some(data_model)
      "rIdLo" => Some(layout_def)
      "rIdQs" => Some(style_def)
      "rIdCs" => Some(colors_def)
      _ => None
    }
  }
  let nodes = render_diagram_svg(
    frame,
    2000000.0,
    1000000.0,
    resolver,
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  if nodes.length() == 0 {
    fail("expected a rendered diagram group")
  }
  let svg = match nodes[0] {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(svg.contains("fill=\"#ff0000\""))
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
    hide_geom: false,
    adjustments: [],
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

///|
test "emit_node_shape applies quickStyle stroke colour" {
  let nb : @diagram_layout.NodeBounds = {
    point_id: "p1",
    bounds: { x: 10.0, y: 20.0, width: 100.0, height: 50.0 },
    shape: @preset_geometry.ShapeRect,
    hide_geom: false,
    adjustments: [],
    style_lbl: Some("node0"),
  }
  let buf = StringBuilder::new()
  for n in emit_node_shape(nb, "#4472C4", stroke="#FF0000") {
    match n {
      @xml.Node::Element(e) => buf.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  let svg = buf.to_string()
  assert_true(svg.contains("fill=\"#4472C4\""))
  assert_true(svg.contains("stroke=\"#FF0000\""))
}

///|
test "emit_node_shape honors dgm shape hideGeom" {
  let nb : @diagram_layout.NodeBounds = {
    point_id: "p1",
    bounds: { x: 10.0, y: 20.0, width: 100.0, height: 50.0 },
    shape: @preset_geometry.ShapeRect,
    hide_geom: true,
    adjustments: [],
    style_lbl: Some("node0"),
  }
  assert_eq(emit_node_shape(nb, "#4472C4").length(), 0)
}

///|
test "emit_node_label applies diagram txLinClrLst stroke colour" {
  let nb : @diagram_layout.NodeBounds = {
    point_id: "p1",
    bounds: { x: 10.0, y: 20.0, width: 1000000.0, height: 500000.0 },
    shape: @preset_geometry.ShapeRect,
    hide_geom: false,
    adjustments: [],
    style_lbl: Some("node1"),
  }
  let node = emit_node_label(
    nb,
    "Label",
    text_color="#000000",
    text_stroke="#AA00AA",
  )
  let svg = match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(svg.contains("fill=\"#000000\""))
  assert_true(svg.contains("stroke=\"#AA00AA\""))
  assert_true(svg.contains("paint-order=\"stroke fill\""))
}

///|
test "emit_diagram_whole_outline renders whole ln border" {
  let data_model = dgm_parse(
    (
      #|<dgm:dataModel xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
      #|<dgm:whole><a:ln w="38100"><a:solidFill><a:srgbClr val="C00000"/></a:solidFill></a:ln></dgm:whole>
      #|</dgm:dataModel>
    ),
  )
  let node = emit_diagram_whole_outline(
    data_model,
    2000000.0,
    1000000.0,
    ColorResolveContext::empty(),
  )
  let svg = match node {
    Some(@xml.Node::Element(e)) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(svg.contains("fill=\"none\""))
  assert_true(svg.contains("stroke=\"#c00000\""))
  assert_true(svg.contains("stroke-width=\"38100\""))
}

///|
test "render_diagram_svg exposes SmartArt part metadata on diagram group" {
  let frame = dgm_parse(
    (
      #|<p:graphicFrame xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
      #|<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/diagram"><dgm:relIds r:dm="rIdDm" r:lo="rIdLo" r:qs="rIdQs" r:cs="rIdCs"/></a:graphicData></a:graphic>
      #|</p:graphicFrame>
    ),
  )
  let data_model = dgm_parse(
    (
      #|<dgm:dataModel xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
      #|<dgm:ptLst>
      #|<dgm:pt modelId="0" type="doc"/>
      #|<dgm:pt modelId="1" type="node"><dgm:t><a:p><a:r><a:t>One</a:t></a:r></a:p></dgm:t></dgm:pt>
      #|</dgm:ptLst>
      #|<dgm:cxnLst><dgm:cxn modelId="101" type="parOf" srcId="0" destId="1" srcOrd="0" destOrd="0"/></dgm:cxnLst>
      #|<dgm:bg><a:solidFill><a:srgbClr val="EEEEEE"/></a:solidFill></dgm:bg>
      #|<dgm:whole/>
      #|</dgm:dataModel>
    ),
  )
  let layout_def = dgm_parse(
    (
      #|<dgm:layoutDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" uniqueId="layout-id" minVer="v1" defStyle="style-a">
      #|<dgm:title val="Layout"/>
      #|<dgm:desc val="Layout description"/>
      #|<dgm:catLst/>
      #|<dgm:sampData/>
      #|<dgm:styleData/>
      #|<dgm:clrData/>
      #|<dgm:layoutNode name="root">
      #|<dgm:alg type="composite"/>
      #|<dgm:constrLst>
      #|<dgm:constr type="l" for="ch" forName="boxA" val="0"/>
      #|<dgm:constr type="t" for="ch" forName="boxA" val="0"/>
      #|<dgm:constr type="w" for="ch" forName="boxA" val="1000000"/>
      #|<dgm:constr type="h" for="ch" forName="boxA" val="500000"/>
      #|</dgm:constrLst>
      #|<dgm:layoutNode name="boxA" styleLbl="node1">
      #|<dgm:alg type="sp"/>
      #|<dgm:shape type="rect"/>
      #|<dgm:presOf axis="self" ptType="all"/>
      #|</dgm:layoutNode>
      #|</dgm:layoutNode>
      #|</dgm:layoutDef>
    ),
  )
  let style_def = dgm_parse(
    (
      #|<dgm:styleDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" uniqueId="style-id">
      #|<dgm:catLst/>
      #|<dgm:scene3d/>
      #|<dgm:styleLbl name="node1"><a:style><a:lnRef idx="1"><a:srgbClr val="111111"/></a:lnRef></a:style></dgm:styleLbl>
      #|</dgm:styleDef>
    ),
  )
  let colors_def = dgm_parse(
    (
      #|<dgm:colorsDef xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" uniqueId="colors-id">
      #|<dgm:catLst/>
      #|<dgm:styleLbl name="node1"><dgm:fillClrLst><a:srgbClr val="00FF00"/></dgm:fillClrLst></dgm:styleLbl>
      #|</dgm:colorsDef>
    ),
  )
  let data_model_typed = try! @dgm.CT_DataModel::new(data_model)
  let layout_def_typed = try! @dgm.CT_DiagramDefinition::new(layout_def)
  let decoded_data_model = try! @diagram_layout.decode_data_model(
    data_model_typed,
  )
  let decoded_layout = try! @diagram_layout.decode_diagram_definition(
    layout_def_typed,
  )
  assert_true(
    @diagram_layout.definition_has_geometric_constraints(decoded_layout),
  )
  let engine = @diagram_layout.DiagramLayoutEngine::new()
  let dry_run = engine.apply(decoded_layout, decoded_data_model, {
    x: 0.0,
    y: 0.0,
    width: 2000000.0,
    height: 1000000.0,
  })
  assert_true(dry_run.length() > 0)
  let resolver = fn(rid : String) -> @xml.Element? {
    match rid {
      "rIdDm" => Some(data_model)
      "rIdLo" => Some(layout_def)
      "rIdQs" => Some(style_def)
      "rIdCs" => Some(colors_def)
      _ => None
    }
  }
  let nodes = render_diagram_svg(
    frame,
    2000000.0,
    1000000.0,
    resolver,
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  if nodes.length() == 0 {
    fail("expected a rendered diagram group")
  }
  let svg = match nodes[0] {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(svg.contains("data-ooxml=\"diagram\""))
  assert_true(svg.contains("data-ooxml-diagram-dm-rid=\"rIdDm\""))
  assert_true(svg.contains("data-ooxml-diagram-point-count=\"2\""))
  assert_true(svg.contains("data-ooxml-diagram-connection-count=\"1\""))
  assert_true(svg.contains("data-ooxml-diagram-rendered-node-count=\"1\""))
  assert_true(svg.contains("data-ooxml-diagram-bg=\"1\""))
  assert_true(svg.contains("data-ooxml-diagram-whole=\"1\""))
  assert_true(svg.contains("data-ooxml-diagram-layout-id=\"layout-id\""))
  assert_true(svg.contains("data-ooxml-diagram-layout-alg=\"composite\""))
  assert_true(svg.contains("data-ooxml-diagram-layout-samp-data=\"1\""))
  assert_true(svg.contains("data-ooxml-diagram-style-id=\"style-id\""))
  assert_true(svg.contains("data-ooxml-diagram-style-label-count=\"1\""))
  assert_true(svg.contains("data-ooxml-diagram-colors-id=\"colors-id\""))
  assert_true(svg.contains("data-ooxml-diagram-colors-style-label-count=\"1\""))
}
