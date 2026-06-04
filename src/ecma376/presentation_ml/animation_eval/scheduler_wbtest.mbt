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
  @domain.CT_SlideTiming::new(root)
}

///|
fn root_node(timeline : Timeline) -> @domain.CT_TLCommonTimeNodeData {
  timeline.roots[0]
}

///|
fn assert_timing_schema_violation(timing_xml : String) -> Unit raise {
  let decoded = try? decode_timing(build_timing(timing_xml))
  assert_true(decoded is Err(@opc_errors.SchemaViolation(_)))
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
test "§19.5.3 animEffect decodes as a leaf timing behaviour" {
  let xml = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animEffect transition=\"out\" filter=\"wipe\" prLst=\"opacity\">" +
    "<cBhvr><cTn id=\"12\" dur=\"750\" fill=\"hold\"/><tgtEl><spTgt spid=\"9\"/></tgtEl><attrNameLst><attrName>style.opacity</attrName></attrNameLst></cBhvr>" +
    "<progress><fltVal val=\"0.75\"/></progress>" +
    "</animEffect>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let root = root_node(timeline)
  assert_eq(root.children.length(), 1)
  let node = root.children[0]
  assert_eq(node.node_id, 12)
  assert_true(node.is_leaf())
  match node.node_kind {
    @domain.TimeNodeAnimateEffect(behavior) => {
      assert_true(behavior.transition == Some(@domain.EffectTransitionOut))
      assert_true(behavior.filter == Some("wipe"))
      assert_true(behavior.pr_lst == Some("opacity"))
      assert_true(behavior.common.target_shape_id == Some(9))
      assert_eq(behavior.common.attr_names[0], "style.opacity")
      match behavior.progress {
        Some(@domain.AnimVariantFloat(v)) => assert_true(v > 0.74 && v < 0.76)
        _ => fail("expected animEffect progress float")
      }
    }
    _ => fail("expected TimeNodeAnimateEffect")
  }
  let events = TimingEngine::new(timeline).schedule()
  let mut saw_start = false
  let mut saw_end = false
  for event in events {
    if event.node_id == 12 {
      match event.kind {
        EventStart => saw_start = true
        EventEnd => saw_end = true
        _ => ()
      }
    }
  }
  assert_true(saw_start)
  assert_true(saw_end)
}

///|
test "§19.5.49 audio and §19.5.85 video decode as media time-node leaves" {
  let xml = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<audio isNarration=\"true\"><cMediaNode vol=\"50000\" mute=\"true\" numSld=\"2\" showWhenStopped=\"false\"><cTn id=\"50\" dur=\"1500\" fill=\"hold\"/><tgtEl><sndTgt/></tgtEl></cMediaNode></audio>" +
    "<video fullScrn=\"true\"><cMediaNode><cTn id=\"51\" dur=\"500\" fill=\"hold\"/><tgtEl><spTgt spid=\"17\"/></tgtEl></cMediaNode></video>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let root = root_node(timeline)
  assert_eq(root.children.length(), 2)
  let audio = root.children[0]
  let video = root.children[1]
  assert_eq(audio.node_id, 50)
  assert_eq(video.node_id, 51)
  assert_true(audio.is_leaf())
  assert_true(video.is_leaf())
  match audio.node_kind {
    @domain.TimeNodeAudio(media) => {
      assert_true(media.is_narration == Some(true))
      assert_true(media.cMediaNode.mute == Some(true))
      assert_true(media.cMediaNode.num_sld == Some(2U))
      assert_true(media.cMediaNode.show_when_stopped == Some(false))
      assert_true(media.cMediaNode.tgtEl.choice is @domain.TimeTargetSnd(_))
    }
    _ => fail("expected TimeNodeAudio")
  }
  match video.node_kind {
    @domain.TimeNodeVideo(media) => {
      assert_true(media.full_scrn == Some(true))
      match media.cMediaNode.tgtEl.choice {
        @domain.TimeTargetSp(target) => assert_eq(target.spid, "17")
        _ => fail("expected video shape target")
      }
    }
    _ => fail("expected TimeNodeVideo")
  }
  let events = TimingEngine::new(timeline).schedule()
  let mut audio_start = false
  let mut audio_end_at = -1
  let mut video_end_at = -1
  for event in events {
    if event.node_id == 50 {
      match event.kind {
        EventStart => audio_start = true
        EventEnd => audio_end_at = event.at_ms
        _ => ()
      }
    }
    if event.node_id == 51 {
      match event.kind {
        EventEnd => video_end_at = event.at_ms
        _ => ()
      }
    }
  }
  assert_true(audio_start)
  assert_eq(audio_end_at, 1500)
  assert_eq(video_end_at, 500)
}

///|
test "§19.5.33 cTn rejects malformed percentage and boolean attributes" {
  let before = "<timing><tnLst><par><cTn id=\"1\" "
  let after = "/></par></tnLst></timing>"
  assert_timing_schema_violation(before + "accel=\"bad\"" + after)
  assert_timing_schema_violation(before + "decel=\"bad\"" + after)
  assert_timing_schema_violation(before + "autoRev=\"maybe\"" + after)
  assert_timing_schema_violation(before + "afterEffect=\"maybe\"" + after)
  assert_timing_schema_violation(before + "display=\"maybe\"" + after)
  assert_timing_schema_violation(before + "nodePh=\"maybe\"" + after)
  assert_timing_schema_violation(before + "presetID=\"bad\"" + after)
  assert_timing_schema_violation(before + "bldLvl=\"bad\"" + after)
  assert_timing_schema_violation(before + "grpId=\"-1\"" + after)
  assert_timing_schema_violation(before + "presetSubtype=\"bad\"" + after)
}

///|
test "§19.5.33 timing nodes reject missing required cTn children" {
  assert_timing_schema_violation("<timing><tnLst><par/></tnLst></timing>")
  let anim = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr/></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(anim)
  let set = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><to><strVal val=\"hidden\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(set)
  let empty_root_list = "<timing><tnLst/></timing>"
  assert_timing_schema_violation(empty_root_list)
  let empty_child_list = "<timing><tnLst><par><cTn id=\"1\">" +
    "<childTnLst/></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(empty_child_list)
  let empty_condition_list = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst/></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(empty_condition_list)
}

///|
test "§19.5 animation variants reject malformed boolean and tav timing" {
  let scale = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animScale zoomContents=\"maybe\"><cBhvr><cTn id=\"2\"/></cBhvr></animScale>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(scale)
  let bool_val = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"3\"/></cBhvr><to><boolVal val=\"maybe\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(bool_val)
  let tav = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav tm=\"bogus\"/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(tav)
  let missing_tav_tm = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_tav_tm)
  let motion = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animMotion rAng=\"bad\"><cBhvr><cTn id=\"5\"/></cBhvr></animMotion>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(motion)
  let condition = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn val=\"bad\"/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(condition)
  let missing_tn_val = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_tn_val)
  let missing_spid = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl><spTgt/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_spid)
  let missing_rtn_val = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><rtn/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_rtn_val)
  let malformed_rtn_val = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><rtn val=\"middle\"/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_rtn_val)
  let missing_condition_choice = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond/></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_condition_choice)
  let multiple_condition_choices = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn val=\"2\"/><rtn val=\"first\"/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(multiple_condition_choices)
  let missing_target_choice = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_target_choice)
  let multiple_target_choices = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl><sldTgt/><spTgt spid=\"5\"/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(multiple_target_choices)
  let missing_behavior_target_choice = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"6\"/><tgtEl/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_behavior_target_choice)
  let multiple_behavior_target_choices = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"7\"/><tgtEl><sldTgt/><spTgt spid=\"5\"/></tgtEl></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(multiple_behavior_target_choices)
  let empty_attr_name_list = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"8\"/><attrNameLst/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(empty_attr_name_list)
  let unexpected_condition_child = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn val=\"2\"/></cond><bogus/></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_condition_child)
  let unexpected_tav_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"9\"/></cBhvr><tavLst><tav tm=\"0\"/><bogus/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_tav_child)
  let unexpected_attr_name_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"10\"/><attrNameLst><attrName>style.visibility</attrName><bogus/></attrNameLst></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_attr_name_child)
}

///|
test "§19.5 animation variants reject missing required val attributes" {
  let before = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"6\"/></cBhvr><to>"
  let after = "</to></set></childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(before + "<boolVal/>" + after)
  assert_timing_schema_violation(before + "<intVal/>" + after)
  assert_timing_schema_violation(before + "<fltVal/>" + after)
  assert_timing_schema_violation(before + "<strVal/>" + after)
  assert_timing_schema_violation(before + after)
  assert_timing_schema_violation(before + "<bogusVal val=\"x\"/>" + after)
  assert_timing_schema_violation(
    before + "<strVal val=\"visible\"/><intVal val=\"1\"/>" + after,
  )
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
