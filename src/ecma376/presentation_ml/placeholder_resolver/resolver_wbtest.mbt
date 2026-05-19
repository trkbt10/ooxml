///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parse_root(source : String) -> @xml.Element {
  try! @xml.parse(bytes(source)).root
}

///|
fn build_slide(shapes_xml : String) -> @domain.CT_Slide {
  let root = parse_root(
    "<sld><cSld><spTree>" + shapes_xml + "</spTree></cSld></sld>",
  )
  @domain.CT_Slide::{ element: root }
}

///|
fn build_layout(shapes_xml : String) -> @domain.CT_SlideLayout {
  let root = parse_root(
    "<sldLayout><cSld><spTree>" + shapes_xml + "</spTree></cSld></sldLayout>",
  )
  @domain.CT_SlideLayout::{ element: root }
}

///|
fn build_master(shapes_xml : String) -> @domain.CT_SlideMaster {
  let root = parse_root(
    "<sldMaster><cSld><spTree>" + shapes_xml + "</spTree></cSld></sldMaster>",
  )
  @domain.CT_SlideMaster::{ element: root }
}

///|
fn first_slide_shape(chain : SlideChain) -> @xml.Element {
  chain.slide_shapes()[0]
}

///|
test "§19.3.1.36 CT_Placeholder::from_element returns typed attributes" {
  let element = parse_root(
    "<ph type=\"title\" idx=\"3\" sz=\"half\" orient=\"vert\" hasCustomPrompt=\"1\"/>",
  )
  let ph = try! @domain.CT_Placeholder::from_element(element)
  assert_eq(ph.idx, Some(3))
  assert_true(ph.ph_type == Some(@domain.PhTitle))
  assert_true(ph.size == Some(@domain.PlaceholderHalf))
  assert_true(ph.orient == Some(@domain.DirectionVert))
  assert_true(ph.has_custom_prompt)
}

///|
test "§19.3.1.36 absent attributes leave defaults" {
  let element = parse_root("<ph/>")
  let ph = try! @domain.CT_Placeholder::from_element(element)
  assert_eq(ph.idx, None)
  assert_true(ph.ph_type == None)
  assert_true(ph.size == None)
  assert_true(ph.orient == None)
  assert_true(!ph.has_custom_prompt)
  assert_true(ph.is_default())
}

///|
test "§19.7.10 ST_PlaceholderType rejects unknown lexical values" {
  let element = parse_root("<ph type=\"bogus\"/>")
  let bad = try? @domain.CT_Placeholder::from_element(element)
  assert_true(bad is Err(_))
}

///|
test "§19.3.1.36 idx match resolves slide → layout → master" {
  let slide_xml = "<sp><nvSpPr><nvPr><ph idx=\"2\"/></nvPr></nvSpPr><spPr id=\"slide\"/><txBody id=\"slide\"/></sp>"
  let layout_xml = "<sp><nvSpPr><nvPr><ph idx=\"2\" type=\"body\"/></nvPr></nvSpPr><spPr id=\"layout\"/></sp>"
  let master_xml = "<sp><nvSpPr><nvPr><ph type=\"body\"/></nvPr></nvSpPr><spPr id=\"master\"/></sp>"
  let chain = SlideChain::from_parts(
    build_master(master_xml),
    Some(build_layout(layout_xml)),
    Some(build_slide(slide_xml)),
  )
  let resolved = try! resolve_placeholder(first_slide_shape(chain), chain)
  let effective = resolved.effective_placeholder.unwrap()
  assert_eq(effective.idx, Some(2))
  assert_true(effective.ph_type == @domain.PhBody)
  assert_true(resolved.layout_shape is Some(_))
  assert_true(resolved.master_shape is Some(_))
  let sp_pr = resolved.sp_pr.unwrap()
  assert_true(attr_local_test(sp_pr, "id") == Some("slide"))
}

///|
test "§19.3.1.36 type-only slide ph falls through to master" {
  let slide_xml = "<sp><nvSpPr><nvPr><ph type=\"body\"/></nvPr></nvSpPr><txBody id=\"slide-body\"/></sp>"
  let layout_xml = "<sp><nvSpPr><nvPr><ph type=\"title\" idx=\"1\"/></nvPr></nvSpPr><spPr id=\"layout-title\"/></sp>"
  let master_xml = "<sp><nvSpPr><nvPr><ph type=\"body\"/></nvPr></nvSpPr><spPr id=\"master-body\"/></sp>"
  let chain = SlideChain::from_parts(
    build_master(master_xml),
    Some(build_layout(layout_xml)),
    Some(build_slide(slide_xml)),
  )
  let resolved = try! resolve_placeholder(first_slide_shape(chain), chain)
  // Layout has no `body` placeholder, so layout_shape is None.
  assert_true(resolved.layout_shape is None)
  // Master `body` shape supplies the spPr.
  let sp_pr = resolved.sp_pr.unwrap()
  assert_true(attr_local_test(sp_pr, "id") == Some("master-body"))
  assert_true(resolved.master_shape is Some(_))
  assert_true(resolved.effective_placeholder.unwrap().ph_type == @domain.PhBody)
}

///|
test "§19.3.1.36 ctrTitle in layout inherits from master title" {
  let slide_xml = "<sp><nvSpPr><nvPr><ph idx=\"1\"/></nvPr></nvSpPr></sp>"
  let layout_xml = "<sp><nvSpPr><nvPr><ph type=\"ctrTitle\" idx=\"1\"/></nvPr></nvSpPr><spPr id=\"layout-ctr\"/></sp>"
  let master_xml = "<sp><nvSpPr><nvPr><ph type=\"title\"/></nvPr></nvSpPr><spPr id=\"master-title\"/></sp>"
  let chain = SlideChain::from_parts(
    build_master(master_xml),
    Some(build_layout(layout_xml)),
    Some(build_slide(slide_xml)),
  )
  let resolved = try! resolve_placeholder(first_slide_shape(chain), chain)
  assert_true(resolved.layout_shape is Some(_))
  let master_shape = resolved.master_shape.unwrap()
  let sp_pr = shape_sp_pr(master_shape).unwrap()
  assert_true(attr_local_test(sp_pr, "id") == Some("master-title"))
  let effective = resolved.effective_placeholder.unwrap()
  assert_true(effective.ph_type == @domain.PhCtrTitle)
}

///|
test "§19.7.9 size and orient inherit from first non-empty layer" {
  let slide_xml = "<sp><nvSpPr><nvPr><ph idx=\"1\"/></nvPr></nvSpPr></sp>"
  let layout_xml = "<sp><nvSpPr><nvPr><ph idx=\"1\" type=\"body\" sz=\"half\"/></nvPr></nvSpPr></sp>"
  let master_xml = "<sp><nvSpPr><nvPr><ph type=\"body\" sz=\"quarter\" orient=\"vert\"/></nvPr></nvSpPr></sp>"
  let chain = SlideChain::from_parts(
    build_master(master_xml),
    Some(build_layout(layout_xml)),
    Some(build_slide(slide_xml)),
  )
  let resolved = try! resolve_placeholder(first_slide_shape(chain), chain)
  let effective = resolved.effective_placeholder.unwrap()
  // Layout supplies half (slide is silent), master supplies vert
  // because layout is silent on orient.
  assert_true(effective.size == @domain.PlaceholderHalf)
  assert_true(effective.orient == @domain.DirectionVert)
}

///|
test "§19.3.1.36 missing slide / layout still resolves master ph" {
  let master_xml = "<sp><nvSpPr><nvPr><ph type=\"body\"/></nvPr></nvSpPr><spPr id=\"master-only\"/></sp>"
  let chain = SlideChain::from_parts(build_master(master_xml), None, None)
  assert_eq(chain.slide_shapes().length(), 0)
  assert_eq(chain.layout_shapes().length(), 0)
  assert_eq(chain.master_shapes().length(), 1)
  // Building a fake "slide" with just the master shape exercises the
  // resolver for layout-less chains (e.g. previewing the master).
  let synthetic = parse_root(
    "<sp><nvSpPr><nvPr><ph type=\"body\"/></nvPr></nvSpPr></sp>",
  )
  let resolved = try! resolve_placeholder(synthetic, chain)
  assert_true(resolved.layout_shape is None)
  assert_true(resolved.master_shape is Some(_))
}

///|
test "§19.3.1.36 placeholder_part1_19_3_1_36_section_name citation" {
  assert_eq(placeholder_part1_19_3_1_36_section_name(), "Part 1 §19.3.1.36")
}

///|
fn attr_local_test(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}
