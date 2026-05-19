///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parse_root(source : String) -> @xml.Element {
  try! @xml.parse(bytes(source)).root
}

///|
fn build_timing(timing_xml : String) -> @domain.CT_SlideTiming {
  let root = parse_root(timing_xml)
  @domain.CT_SlideTiming::{ element: root }
}

///|
fn root_node(timeline : Timeline) -> @domain.CT_TLCommonTimeNodeData {
  timeline.roots[0]
}

///|
test "§19.5 par container with two set children" {
  let xml = "<timing><tnLst><par><cTn id=\"1\" nodeType=\"tmRoot\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"10\" dur=\"1\" fill=\"hold\"/><tgtEl><spTgt spid=\"7\"/></tgtEl><attrNameLst><attrName>style.visibility</attrName></attrNameLst></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "<set><cBhvr><cTn id=\"11\" dur=\"1\" fill=\"hold\"/><tgtEl><spTgt spid=\"8\"/></tgtEl><attrNameLst><attrName>style.visibility</attrName></attrNameLst></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let root = root_node(timeline)
  assert_eq(root.node_id, 1)
  assert_true(root.node_kind is @domain.TimeNodePar)
  assert_eq(root.children.length(), 2)
  let first = root.children[0]
  let second = root.children[1]
  assert_eq(first.node_id, 10)
  assert_eq(second.node_id, 11)
  let leaves = timeline.flatten_leaves()
  assert_eq(leaves.length(), 2)
  let common0 = first.behavior_common().unwrap()
  assert_true(common0.target_shape_id == Some(7))
  assert_eq(common0.attr_names[0], "style.visibility")
}

///|
test "§19.5.65 seq orders animate children with offset start times" {
  let xml = "<timing><tnLst><seq><cTn id=\"1\" nodeType=\"mainSeq\"><childTnLst>" +
    "<anim from=\"0\" to=\"10\" valueType=\"num\"><cBhvr><cTn id=\"20\" dur=\"1000\" fill=\"hold\"/><tgtEl><spTgt spid=\"1\"/></tgtEl><attrNameLst><attrName>style.left</attrName></attrNameLst></cBhvr></anim>" +
    "<anim from=\"10\" to=\"20\" valueType=\"num\"><cBhvr><cTn id=\"21\" dur=\"1000\" fill=\"hold\"/><tgtEl><spTgt spid=\"1\"/></tgtEl><attrNameLst><attrName>style.left</attrName></attrNameLst></cBhvr></anim>" +
    "</childTnLst></cTn></seq></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let engine = TimingEngine::new(timeline)
  let events = engine.schedule()
  // Expect Start(1), Start(20), Property(20,0), Property(20,1),
  // End(20), Start(21), Property(21,0), Property(21,1), End(21),
  // End(1). At minimum the two child Starts must be in time order.
  let mut child20_start_at = -1
  let mut child21_start_at = -1
  for event in events {
    if event.node_id == 20 {
      match event.kind {
        EventStart => child20_start_at = event.at_ms
        _ => ()
      }
    }
    if event.node_id == 21 {
      match event.kind {
        EventStart => child21_start_at = event.at_ms
        _ => ()
      }
    }
  }
  assert_eq(child20_start_at, 0)
  assert_eq(child21_start_at, 1000)
}

///|
test "§19.5.31 clickEffect surfaces ConditionalStart" {
  let xml = "<timing><tnLst><par><cTn id=\"1\" nodeType=\"clickEffect\">" +
    "<stCondLst><cond evt=\"onClick\" delay=\"0\"><tgtEl><spTgt spid=\"5\"/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let engine = TimingEngine::new(timeline)
  let events = engine.schedule()
  let mut found = false
  for event in events {
    match event.kind {
      EventConditionalStart(cond) => {
        found = true
        assert_true(cond.event == Some(@domain.TriggerOnClick))
        assert_true(cond.target_shape_id == Some(5))
      }
      _ => ()
    }
  }
  assert_true(found)
}

///|
test "§19.5.1 anim from/to interpolates linearly" {
  let xml = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim from=\"0\" to=\"100\" calcmode=\"lin\" valueType=\"num\"><cBhvr><cTn id=\"5\" dur=\"1000\" fill=\"hold\"/><tgtEl><spTgt spid=\"3\"/></tgtEl><attrNameLst><attrName>ppt_x</attrName></attrNameLst></cBhvr></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let engine = TimingEngine::new(timeline)
  let snap0 = engine.animate(0)
  let snap500 = engine.animate(500)
  let snap1000 = engine.animate(1000)
  let leaf0 = snap0[0]
  let leaf500 = snap500[0]
  let leaf1000 = snap1000[0]
  assert_eq(leaf0.attr_name, "ppt_x")
  let v0 = leaf0.value.as_double().unwrap()
  let v500 = leaf500.value.as_double().unwrap()
  let v1000 = leaf1000.value.as_double().unwrap()
  assert_true(v0 <= 0.001 && v0 >= -0.001)
  assert_true(v500 > 49.0 && v500 < 51.0)
  assert_true(v1000 > 99.0 && v1000 <= 100.001)
}

///|
test "§19.5.79 tavLst keypoints lerp between adjacent entries" {
  let xml = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim calcmode=\"lin\" valueType=\"num\"><cBhvr><cTn id=\"6\" dur=\"1000\" fill=\"hold\"/><tgtEl><spTgt spid=\"4\"/></tgtEl><attrNameLst><attrName>ppt_y</attrName></attrNameLst></cBhvr>" +
    "<tavLst><tav tm=\"0%\"><val><fltVal val=\"0\"/></val></tav><tav tm=\"50%\"><val><fltVal val=\"25\"/></val></tav><tav tm=\"100%\"><val><fltVal val=\"100\"/></val></tav></tavLst>" +
    "</anim></childTnLst></cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let engine = TimingEngine::new(timeline)
  let snap500 = engine.animate(500)
  let snap750 = engine.animate(750)
  let v500 = snap500[0].value.as_double().unwrap()
  let v750 = snap750[0].value.as_double().unwrap()
  // At t=500 (50%): exactly 25 per the midpoint keypoint.
  assert_true(v500 > 24.5 && v500 < 25.5)
  // At t=750 (75%): linear between 25 and 100 → 62.5.
  assert_true(v750 > 61.0 && v750 < 64.0)
}

///|
test "§19.5.33 repeatCount=3000 cycles three iterations" {
  let xml = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim from=\"0\" to=\"1\" calcmode=\"lin\" valueType=\"num\"><cBhvr><cTn id=\"9\" dur=\"1000\" repeatCount=\"3000\" fill=\"hold\"/><tgtEl><spTgt spid=\"2\"/></tgtEl><attrNameLst><attrName>opacity</attrName></attrNameLst></cBhvr></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let engine = TimingEngine::new(timeline)
  // 1.5 * single_dur = 1500ms — should give local progress 0.5.
  let snap1500 = engine.animate(1500)
  let v1500 = snap1500[0].value.as_double().unwrap()
  assert_true(v1500 > 0.45 && v1500 < 0.55)
  // 2.25 * single_dur = 2250ms — local progress 0.25.
  let snap2250 = engine.animate(2250)
  let v2250 = snap2250[0].value.as_double().unwrap()
  assert_true(v2250 > 0.2 && v2250 < 0.3)
}

///|
test "§19.7.41 fill=hold keeps snapshot active past end time" {
  let xml = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim from=\"0\" to=\"100\" calcmode=\"lin\" valueType=\"num\"><cBhvr><cTn id=\"30\" dur=\"500\" fill=\"hold\"/><tgtEl><spTgt spid=\"1\"/></tgtEl><attrNameLst><attrName>opacity</attrName></attrNameLst></cBhvr></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let engine = TimingEngine::new(timeline)
  let snap_after = engine.animate(2000)
  assert_eq(snap_after.length(), 1)
  let final_value = snap_after[0].value.as_double().unwrap()
  assert_true(final_value > 99.0 && final_value <= 100.001)
}

///|
test "§19.7.41 fill=remove drops snapshot after end" {
  let xml = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim from=\"0\" to=\"100\" calcmode=\"lin\" valueType=\"num\"><cBhvr><cTn id=\"40\" dur=\"500\" fill=\"remove\"/><tgtEl><spTgt spid=\"1\"/></tgtEl><attrNameLst><attrName>opacity</attrName></attrNameLst></cBhvr></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let engine = TimingEngine::new(timeline)
  let snap_after = engine.animate(2000)
  assert_eq(snap_after.length(), 0)
}

///|
test "§19.5 animation_part1_19_5_section_name citation" {
  assert_eq(animation_part1_19_5_section_name(), "Part 1 §19.5")
}

///|
test "§19.7.38 ST_TLTime decoder accepts indefinite and milliseconds" {
  let indef = try! @domain.ST_TLTime::parse("indefinite")
  assert_eq(indef.to_string(), "indefinite")
  let ms = try! @domain.ST_TLTime::parse("2500")
  assert_eq(ms.to_string(), "2500")
  let bad = try? @domain.ST_TLTime::parse("nope")
  assert_true(bad is Err(_))
}
