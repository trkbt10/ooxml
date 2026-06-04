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
    "<video fullScrn=\"true\"><cMediaNode vol=\"50%\"><cTn id=\"51\" dur=\"500\" fill=\"hold\"/><tgtEl><spTgt spid=\"17\"/></tgtEl></cMediaNode></video>" +
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
      assert_true(media.cMediaNode.vol == Some("50000"))
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
      assert_true(media.cMediaNode.vol == Some("50%"))
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
test "§19.5 media nodes reject malformed direct children" {
  let before = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>"
  let after = "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(before + "<audio><bogus/></audio>" + after)
  assert_timing_schema_violation(
    before +
    "<audio><cMediaNode><cTn id=\"52\"/><tgtEl><sndTgt/></tgtEl></cMediaNode><cMediaNode><cTn id=\"53\"/><tgtEl><sndTgt/></tgtEl></cMediaNode></audio>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<audio><cMediaNode><tgtEl><sndTgt/></tgtEl><cTn id=\"54\"/></cMediaNode></audio>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<video><cMediaNode><cTn id=\"55\"/><cTn id=\"56\"/><tgtEl><spTgt spid=\"1\"/></tgtEl></cMediaNode></video>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<video><cMediaNode><cTn id=\"57\"/><tgtEl><spTgt spid=\"1\"/></tgtEl><bogus/></cMediaNode></video>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<audio isNarration=\"maybe\"><cMediaNode><cTn id=\"66\"/><tgtEl><sndTgt/></tgtEl></cMediaNode></audio>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<video fullScrn=\"maybe\"><cMediaNode><cTn id=\"67\"/><tgtEl><spTgt spid=\"1\"/></tgtEl></cMediaNode></video>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<audio><cMediaNode vol=\"bad\"><cTn id=\"58\"/><tgtEl><sndTgt/></tgtEl></cMediaNode></audio>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<audio><cMediaNode vol=\"-1%\"><cTn id=\"59\"/><tgtEl><sndTgt/></tgtEl></cMediaNode></audio>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<video><cMediaNode vol=\"100.1%\"><cTn id=\"60\"/><tgtEl><spTgt spid=\"1\"/></tgtEl></cMediaNode></video>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<video><cMediaNode vol=\"100001\"><cTn id=\"61\"/><tgtEl><spTgt spid=\"1\"/></tgtEl></cMediaNode></video>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<audio><cMediaNode mute=\"maybe\"><cTn id=\"62\"/><tgtEl><sndTgt/></tgtEl></cMediaNode></audio>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<video><cMediaNode showWhenStopped=\"maybe\"><cTn id=\"63\"/><tgtEl><spTgt spid=\"1\"/></tgtEl></cMediaNode></video>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<audio><cMediaNode numSld=\"-1\"><cTn id=\"64\"/><tgtEl><sndTgt/></tgtEl></cMediaNode></audio>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<video><cMediaNode numSld=\"4294967296\"><cTn id=\"65\"/><tgtEl><spTgt spid=\"1\"/></tgtEl></cMediaNode></video>" +
    after,
  )
}

///|
test "§19.5.33 cTn rejects malformed scalar attributes" {
  let before = "<timing><tnLst><par><cTn id=\"1\" "
  let after = "/></par></tnLst></timing>"
  assert_timing_schema_violation(
    "<timing><tnLst><par><cTn id=\"4294967296\"/></par></tnLst></timing>",
  )
  assert_timing_schema_violation(
    "<timing><tnLst><par><cTn id=\"2147483648\"/></par></tnLst></timing>",
  )
  assert_timing_schema_violation(before + "dur=\"bad\"" + after)
  assert_timing_schema_violation(before + "dur=\"-1\"" + after)
  assert_timing_schema_violation(before + "repeatCount=\"bad\"" + after)
  assert_timing_schema_violation(before + "repeatDur=\"-1\"" + after)
  assert_timing_schema_violation(before + "nodeType=\"root\"" + after)
  assert_timing_schema_violation(before + "presetClass=\"entrance\"" + after)
  assert_timing_schema_violation(before + "restart=\"sometimes\"" + after)
  assert_timing_schema_violation(before + "fill=\"persist\"" + after)
  assert_timing_schema_violation(before + "accel=\"bad\"" + after)
  assert_timing_schema_violation(before + "accel=\"-1%\"" + after)
  assert_timing_schema_violation(before + "accel=\"100001\"" + after)
  assert_timing_schema_violation(before + "decel=\"bad\"" + after)
  assert_timing_schema_violation(before + "decel=\"0.5\"" + after)
  assert_timing_schema_violation(before + "decel=\"100.1%\"" + after)
  assert_timing_schema_violation(before + "autoRev=\"maybe\"" + after)
  assert_timing_schema_violation(before + "afterEffect=\"maybe\"" + after)
  assert_timing_schema_violation(before + "display=\"maybe\"" + after)
  assert_timing_schema_violation(before + "nodePh=\"maybe\"" + after)
  assert_timing_schema_violation(before + "presetID=\"bad\"" + after)
  assert_timing_schema_violation(before + "presetID=\"2147483648\"" + after)
  assert_timing_schema_violation(before + "bldLvl=\"bad\"" + after)
  assert_timing_schema_violation(before + "bldLvl=\"-2147483649\"" + after)
  assert_timing_schema_violation(before + "grpId=\"-1\"" + after)
  assert_timing_schema_violation(before + "grpId=\"2147483648\"" + after)
  assert_timing_schema_violation(before + "presetSubtype=\"bad\"" + after)
  assert_timing_schema_violation(before + "masterRel=\"bad\"" + after)
  assert_timing_schema_violation(before + "spd=\"bad\"" + after)
  assert_timing_schema_violation(before + "spd=\"1e2%\"" + after)
  assert_timing_schema_violation(before + "syncBehavior=\"bad\"" + after)
}

///|
test "§19.5.12 cTn decodes scalar timing metadata" {
  let xml = "<timing><tnLst><par><cTn id=\"1\" accel=\"25000\" decel=\"12.5%\" masterRel=\"lastClick\" spd=\"-12.5%\" syncBehavior=\"locked\"/></par></tnLst></timing>"
  let timeline = try! decode_timing(build_timing(xml))
  let root = root_node(timeline)
  assert_true(root.accel > 0.249 && root.accel < 0.251)
  assert_true(root.decel > 0.124 && root.decel < 0.126)
  assert_true(root.master_rel == Some("lastClick"))
  assert_true(root.spd == Some("-12.5%"))
  assert_true(root.sync_behavior == Some("locked"))
}

///|
test "§19.5 animation leaves reject malformed enum attributes" {
  let before = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>"
  let after = "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(
    before +
    "<anim calcmode=\"linear\"><cBhvr><cTn id=\"70\"/></cBhvr></anim>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<anim valueType=\"color\"><cBhvr><cTn id=\"71\"/></cBhvr></anim>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<animEffect transition=\"fade\"><cBhvr><cTn id=\"72\"/></cBhvr></animEffect>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<animMotion origin=\"slide\"><cBhvr><cTn id=\"73\"/></cBhvr></animMotion>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<animMotion pathEditMode=\"locked\"><cBhvr><cTn id=\"74\"/></cBhvr></animMotion>" +
    after,
  )
  assert_timing_schema_violation(
    before + "<cmd type=\"event\"><cBhvr><cTn id=\"75\"/></cBhvr></cmd>" + after,
  )
  assert_timing_schema_violation(
    before +
    "<animClr clrSpc=\"lab\"><cBhvr><cTn id=\"76\"/></cBhvr></animClr>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<animClr dir=\"clockwise\"><cBhvr><cTn id=\"77\"/></cBhvr></animClr>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<set><cBhvr additive=\"add\"><cTn id=\"78\"/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    after,
  )
  assert_timing_schema_violation(
    before +
    "<set><cBhvr accumulate=\"sometimes\"><cTn id=\"79\"/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    after,
  )
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
  let unsupported_root_node = "<timing><tnLst><bogus/></tnLst></timing>"
  assert_timing_schema_violation(unsupported_root_node)
  let unsupported_child_node = "<timing><tnLst><par><cTn id=\"1\">" +
    "<childTnLst><bogus/></childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unsupported_child_node)
  let unexpected_par_child = "<timing><tnLst><par><cTn id=\"1\"/><bogus/></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_par_child)
  let duplicate_excl_ctn = "<timing><tnLst><excl><cTn id=\"1\"/><cTn id=\"2\"/></excl></tnLst></timing>"
  assert_timing_schema_violation(duplicate_excl_ctn)
  let reversed_seq_children = "<timing><tnLst><seq>" +
    "<nextCondLst><cond><rtn val=\"first\"/></cond></nextCondLst><cTn id=\"1\"/>" +
    "</seq></tnLst></timing>"
  assert_timing_schema_violation(reversed_seq_children)
  let duplicate_seq_prev_conditions = "<timing><tnLst><seq><cTn id=\"1\"/>" +
    "<prevCondLst><cond><rtn val=\"first\"/></cond></prevCondLst>" +
    "<prevCondLst><cond><rtn val=\"last\"/></cond></prevCondLst></seq></tnLst></timing>"
  assert_timing_schema_violation(duplicate_seq_prev_conditions)
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
  let scale_rejects_r_ctr = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animScale><cBhvr><cTn id=\"27\"/></cBhvr><rCtr x=\"0\" y=\"0\"/></animScale>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(scale_rejects_r_ctr)
  let scale_rejects_from_attr = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animScale from=\"1\"><cBhvr><cTn id=\"41\"/></cBhvr></animScale>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(scale_rejects_from_attr)
  let scale_rejects_to_attr = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animScale to=\"2\"><cBhvr><cTn id=\"42\"/></cBhvr></animScale>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(scale_rejects_to_attr)
  let scale_rejects_by_attr = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animScale by=\"3\"><cBhvr><cTn id=\"43\"/></cBhvr></animScale>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(scale_rejects_by_attr)
  let duplicate_anim_rot_cbhvr = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animRot><cBhvr><cTn id=\"32\"/></cBhvr><cBhvr><cTn id=\"33\"/></cBhvr></animRot>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_anim_rot_cbhvr)
  let unexpected_anim_rot_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animRot><cBhvr><cTn id=\"34\"/></cBhvr><bogus/></animRot>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_anim_rot_child)
  let malformed_anim_rot_by = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animRot by=\"bad\"><cBhvr><cTn id=\"38\"/></cBhvr></animRot>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_rot_by)
  let fractional_anim_rot_from = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animRot from=\"1.5\"><cBhvr><cTn id=\"39\"/></cBhvr></animRot>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(fractional_anim_rot_from)
  let malformed_anim_rot_to = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animRot to=\"+\"><cBhvr><cTn id=\"40\"/></cBhvr></animRot>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_rot_to)
  let missing_cmd_cbhvr = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<cmd cmd=\"foo\"/>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_cmd_cbhvr)
  let duplicate_cmd_cbhvr = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<cmd><cBhvr><cTn id=\"35\"/></cBhvr><cBhvr><cTn id=\"36\"/></cBhvr></cmd>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_cmd_cbhvr)
  let unexpected_cmd_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<cmd><cBhvr><cTn id=\"37\"/></cBhvr><bogus/></cmd>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_cmd_child)
  let bool_val = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"3\"/></cBhvr><to><boolVal val=\"maybe\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(bool_val)
  let duplicate_set_cbhvr = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"14\"/></cBhvr><cBhvr><cTn id=\"15\"/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_set_cbhvr)
  let duplicate_set_to = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"16\"/></cBhvr><to><strVal val=\"visible\"/></to><to><strVal val=\"hidden\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_set_to)
  let unexpected_set_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"17\"/></cBhvr><bogus/><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_set_child)
  let duplicate_anim_effect_progress = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animEffect><cBhvr><cTn id=\"18\"/></cBhvr><progress><fltVal val=\"0.25\"/></progress><progress><fltVal val=\"0.75\"/></progress></animEffect>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_anim_effect_progress)
  let unexpected_anim_effect_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animEffect><cBhvr><cTn id=\"19\"/></cBhvr><bogus/><progress><fltVal val=\"0.25\"/></progress></animEffect>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_anim_effect_child)
  let reversed_anim_effect_children = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animEffect><progress><fltVal val=\"0.25\"/></progress><cBhvr><cTn id=\"20\"/></cBhvr></animEffect>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(reversed_anim_effect_children)
  let duplicate_anim_tav_list = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"21\"/></cBhvr><tavLst><tav tm=\"0%\"/></tavLst><tavLst><tav tm=\"100%\"/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_anim_tav_list)
  let unexpected_anim_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"22\"/></cBhvr><bogus/><tavLst><tav tm=\"0%\"/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_anim_child)
  let reversed_anim_children = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><tavLst><tav tm=\"0%\"/></tavLst><cBhvr><cTn id=\"23\"/></cBhvr></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(reversed_anim_children)
  let tav = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav tm=\"bogus\"/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(tav)
  let bare_tav_tm = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav tm=\"0\"/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(bare_tav_tm)
  let negative_tav_tm = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav tm=\"-1%\"/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(negative_tav_tm)
  let exponent_tav_tm = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav tm=\"1e2%\"/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(exponent_tav_tm)
  let out_of_range_tav_tm = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav tm=\"100.1%\"/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(out_of_range_tav_tm)
  let unexpected_tav_value_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav tm=\"0%\"><val><fltVal val=\"0\"/></val><bogus/></tav></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_tav_value_child)
  let multiple_tav_values = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"4\"/></cBhvr><tavLst><tav tm=\"0%\"><val><fltVal val=\"0\"/></val><val><fltVal val=\"1\"/></val></tav></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(multiple_tav_values)
  let motion = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animMotion rAng=\"bad\"><cBhvr><cTn id=\"5\"/></cBhvr></animMotion>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(motion)
  let fractional_motion_rotation = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animMotion rAng=\"1.5\"><cBhvr><cTn id=\"44\"/></cBhvr></animMotion>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(fractional_motion_rotation)
  let missing_motion_point_y = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animMotion><cBhvr><cTn id=\"28\"/></cBhvr><by x=\"0\"/></animMotion>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_motion_point_y)
  let duplicate_motion_to = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animMotion><cBhvr><cTn id=\"29\"/></cBhvr><to x=\"0\" y=\"0\"/><to x=\"1\" y=\"1\"/></animMotion>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_motion_to)
  let reversed_motion_points = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animMotion><cBhvr><cTn id=\"30\"/></cBhvr><to x=\"1\" y=\"1\"/><from x=\"0\" y=\"0\"/></animMotion>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(reversed_motion_points)
  let motion_point_with_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animMotion><cBhvr><cTn id=\"31\"/></cBhvr><by x=\"0\" y=\"0\"><bogus/></by></animMotion>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(motion_point_with_child)
  let empty_anim_clr_from = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"11\"/></cBhvr><from/></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(empty_anim_clr_from)
  let multiple_anim_clr_to = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"12\"/></cBhvr><to><srgbClr val=\"000000\"/><schemeClr val=\"accent1\"/></to></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(multiple_anim_clr_to)
  let missing_anim_clr_from_val = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"12\"/></cBhvr><from><srgbClr/></from></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_anim_clr_from_val)
  let malformed_anim_clr_from_hex = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"12\"/></cBhvr><from><srgbClr val=\"zzzzzz\"/></from></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_clr_from_hex)
  let malformed_anim_clr_to_scheme = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"12\"/></cBhvr><to><schemeClr val=\"bogus\"/></to></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_clr_to_scheme)
  let malformed_anim_clr_to_hsl = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"12\"/></cBhvr><to><hslClr hue=\"1.5\" sat=\"0%\" lum=\"0%\"/></to></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_clr_to_hsl)
  let malformed_anim_clr_from_scrgb = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"12\"/></cBhvr><from><scrgbClr r=\"bad\" g=\"0%\" b=\"0%\"/></from></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_clr_from_scrgb)
  let malformed_anim_clr_to_sys_last = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"12\"/></cBhvr><to><sysClr val=\"windowText\" lastClr=\"12345z\"/></to></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_clr_to_sys_last)
  let malformed_anim_clr_by = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"13\"/></cBhvr><by><rgb r=\"100%\" g=\"0%\"/></by></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_clr_by)
  let malformed_anim_clr_by_rgb = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"27\"/></cBhvr><by><rgb r=\"bad\" g=\"0%\" b=\"0%\"/></by></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_clr_by_rgb)
  let out_of_range_anim_clr_by_rgb = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"28\"/></cBhvr><by><rgb r=\"-100.1%\" g=\"0%\" b=\"0%\"/></by></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(out_of_range_anim_clr_by_rgb)
  let malformed_anim_clr_by_hsl_angle = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"29\"/></cBhvr><by><hsl h=\"1.5\" s=\"0%\" l=\"0%\"/></by></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_anim_clr_by_hsl_angle)
  let out_of_range_anim_clr_by_hsl = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"30\"/></cBhvr><by><hsl h=\"0\" s=\"100001\" l=\"0%\"/></by></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(out_of_range_anim_clr_by_hsl)
  let nested_anim_clr_by_rgb = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"31\"/></cBhvr><by><rgb r=\"0%\" g=\"0%\" b=\"0%\"><bogus/></rgb></by></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(nested_anim_clr_by_rgb)
  let duplicate_anim_clr_from = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"24\"/></cBhvr><from><srgbClr val=\"000000\"/></from><from><schemeClr val=\"accent1\"/></from></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_anim_clr_from)
  let unexpected_anim_clr_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"25\"/></cBhvr><bogus/><to><schemeClr val=\"accent1\"/></to></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_anim_clr_child)
  let reversed_anim_clr_children = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<animClr><cBhvr><cTn id=\"26\"/></cBhvr><to><schemeClr val=\"accent1\"/></to><from><srgbClr val=\"000000\"/></from></animClr>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(reversed_anim_clr_children)
  let condition = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn val=\"bad\"/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(condition)
  let out_of_range_tn_val = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn val=\"4294967296\"/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(out_of_range_tn_val)
  let nonrepresentable_tn_val = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn val=\"2147483648\"/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(nonrepresentable_tn_val)
  let malformed_condition_delay = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond delay=\"bad\"><tn val=\"2\"/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_condition_delay)
  let malformed_condition_event = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond evt=\"hover\"><tn val=\"2\"/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_condition_event)
  let missing_tn_val = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_tn_val)
  let missing_spid = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl><spTgt/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_spid)
  let negative_spid = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl><spTgt spid=\"-5\"/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(negative_spid)
  let malformed_spid = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl><spTgt spid=\"bad\"/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_spid)
  let nonrepresentable_spid = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl><spTgt spid=\"2147483648\"/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(nonrepresentable_spid)
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
  let unexpected_condition_choice = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn val=\"2\"/><bogus/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_condition_choice)
  let missing_target_choice = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl/></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_target_choice)
  let multiple_target_choices = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl><sldTgt/><spTgt spid=\"5\"/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(multiple_target_choices)
  let unexpected_target_choice = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tgtEl><spTgt spid=\"5\"/><bogus/></tgtEl></cond></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_target_choice)
  let missing_behavior_target_choice = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"6\"/><tgtEl/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(missing_behavior_target_choice)
  let multiple_behavior_target_choices = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"7\"/><tgtEl><sldTgt/><spTgt spid=\"5\"/></tgtEl></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(multiple_behavior_target_choices)
  let duplicate_behavior_targets = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"11\"/><tgtEl><spTgt spid=\"5\"/></tgtEl><tgtEl><spTgt spid=\"6\"/></tgtEl></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_behavior_targets)
  let duplicate_attr_name_lists = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"12\"/><attrNameLst><attrName>style.visibility</attrName></attrNameLst><attrNameLst><attrName>style.opacity</attrName></attrNameLst></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(duplicate_attr_name_lists)
  let unexpected_behavior_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"13\"/><bogus/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_behavior_child)
  let reversed_behavior_children = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"14\"/><attrNameLst><attrName>style.visibility</attrName></attrNameLst><tgtEl><spTgt spid=\"5\"/></tgtEl></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(reversed_behavior_children)
  let malformed_behavior_override = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr override=\"bogus\"><cTn id=\"15\"/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_behavior_override)
  let malformed_behavior_transform = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr xfrmType=\"all\"><cTn id=\"16\"/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(malformed_behavior_transform)
  let empty_attr_name_list = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"8\"/><attrNameLst/></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(empty_attr_name_list)
  let unexpected_condition_child = "<timing><tnLst><par><cTn id=\"1\">" +
    "<stCondLst><cond><tn val=\"2\"/></cond><bogus/></stCondLst>" +
    "</cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_condition_child)
  let unexpected_tav_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<anim><cBhvr><cTn id=\"9\"/></cBhvr><tavLst><tav tm=\"0%\"/><bogus/></tavLst></anim>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_tav_child)
  let unexpected_attr_name_child = "<timing><tnLst><par><cTn id=\"1\"><childTnLst>" +
    "<set><cBhvr><cTn id=\"10\"/><attrNameLst><attrName>style.visibility</attrName><bogus/></attrNameLst></cBhvr><to><strVal val=\"visible\"/></to></set>" +
    "</childTnLst></cTn></par></tnLst></timing>"
  assert_timing_schema_violation(unexpected_attr_name_child)
}

///|
test "§19.5.22 cBhvr preserves enum-backed behavior attributes" {
  let common = try! decode_cbhvr(
    parse_root(
      "<set><cBhvr override=\"childStyle\" xfrmType=\"img\" rctx=\"session\"><cTn id=\"17\"/></cBhvr></set>",
    ),
  )
  assert_true(common.override_behavior == Some("childStyle"))
  assert_true(common.transform_type == Some("img"))
  assert_true(common.runtime_context == Some("session"))
}

///|
test "§19.5.66 set preserves cBhvr behavior metadata" {
  let node = try! decode_set(
    parse_root(
      "<set><cBhvr override=\"childStyle\" xfrmType=\"img\" rctx=\"session\"><cTn id=\"18\"/></cBhvr><to><strVal val=\"visible\"/></to></set>",
    ),
  )
  match node.node_kind {
    @domain.TimeNodeSet(behavior) => {
      assert_true(behavior.common.override_behavior == Some("childStyle"))
      assert_true(behavior.common.transform_type == Some("img"))
      assert_true(behavior.common.runtime_context == Some("session"))
      assert_true(
        behavior.common.to_value is Some(@domain.AnimVariantString(_)),
      )
    }
    _ => fail("expected set behavior")
  }
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
  assert_timing_schema_violation(before + "<clrVal/>" + after)
  assert_timing_schema_violation(before + "<intVal val=\"bad\"/>" + after)
  assert_timing_schema_violation(
    before + "<intVal val=\"2147483648\"/>" + after,
  )
  assert_timing_schema_violation(before + "<fltVal val=\"1.2.3\"/>" + after)
  assert_timing_schema_violation(before + "<clrVal><bogus/></clrVal>" + after)
  assert_timing_schema_violation(before + "<clrVal><srgbClr/></clrVal>" + after)
  assert_timing_schema_violation(
    before + "<clrVal><srgbClr val=\"12345z\"/></clrVal>" + after,
  )
  assert_timing_schema_violation(
    before + "<clrVal><schemeClr val=\"notAColor\"/></clrVal>" + after,
  )
  assert_timing_schema_violation(
    before +
    "<clrVal><srgbClr val=\"ff00aa\"/><schemeClr val=\"accent1\"/></clrVal>" +
    after,
  )
  assert_timing_schema_violation(before + after)
  assert_timing_schema_violation(before + "<bogusVal val=\"x\"/>" + after)
  assert_timing_schema_violation(
    before + "<strVal val=\"visible\"/><intVal val=\"1\"/>" + after,
  )
}

///|
test "§19.5.5 animRot preserves ST_Angle endpoints" {
  let node = try! decode_anim_rot(
    parse_root(
      "<animRot from=\"-5400000\" to=\"5400000\" by=\"60000\"><cBhvr><cTn id=\"15\"/></cBhvr></animRot>",
    ),
  )
  match node.node_kind {
    @domain.TimeNodeAnimateRotation(behavior) => {
      match behavior.common.from_value {
        Some(@domain.AnimVariantInt(value)) => assert_eq(value, -5400000)
        _ => fail("expected integer from angle")
      }
      match behavior.common.to_value {
        Some(@domain.AnimVariantInt(value)) => assert_eq(value, 5400000)
        _ => fail("expected integer to angle")
      }
      match behavior.common.by_value {
        Some(@domain.AnimVariantInt(value)) => assert_eq(value, 60000)
        _ => fail("expected integer by angle")
      }
    }
    _ => fail("expected animate rotation node")
  }
}

///|
test "§19.5.2 animClr preserves endpoint payloads" {
  let node = try! decode_anim_clr(
    parse_root(
      "<animClr><cBhvr><cTn id=\"12\"/></cBhvr><by><rgb r=\"100%\" g=\"0%\" b=\"0%\"/></by><from><srgbClr val=\"000000\"/></from><to><schemeClr val=\"accent1\"/></to></animClr>",
    ),
  )
  match node.node_kind {
    @domain.TimeNodeAnimateColor(behavior) => {
      match behavior.common.from_value {
        Some(@domain.AnimVariantColor(payload)) =>
          assert_eq(payload, "srgbClr:000000")
        _ => fail("expected from color")
      }
      match behavior.common.to_value {
        Some(@domain.AnimVariantColor(payload)) =>
          assert_eq(payload, "schemeClr:accent1")
        _ => fail("expected to color")
      }
      match behavior.common.by_value {
        Some(@domain.AnimVariantColor(payload)) =>
          assert_eq(payload, "rgb:r=100%,g=0%,b=0%")
        _ => fail("expected by transform")
      }
    }
    _ => fail("expected animate color node")
  }
}

///|
test "§19.5.2 animClr preserves signed hsl by transform payload" {
  let node = try! decode_anim_clr(
    parse_root(
      "<animClr><cBhvr><cTn id=\"13\"/></cBhvr><by><hsl h=\"-5400000\" s=\"-100000\" l=\"100%\"/></by></animClr>",
    ),
  )
  match node.node_kind {
    @domain.TimeNodeAnimateColor(behavior) =>
      match behavior.common.by_value {
        Some(@domain.AnimVariantColor(payload)) =>
          assert_eq(payload, "hsl:h=-5400000,s=-100000,l=100%")
        _ => fail("expected hsl by transform")
      }
    _ => fail("expected animate color node")
  }
}

///|
test "§19.5.79 tav defaults missing tm to indefinite" {
  let tav = try! decode_tav(
    parse_root("<tav><val><fltVal val=\"1.5\"/></val></tav>"),
  )
  match tav.tm_percent {
    None => ()
    Some(_) => fail("expected indefinite default")
  }
  match tav.value {
    Some(@domain.AnimVariantFloat(value)) => assert_eq(value, 1.5)
    _ => fail("expected float value")
  }
  assert_eq(tav.fmla, "")
}

///|
test "§19.5.92 clrVal preserves nested DML color choice" {
  let decoded = try! decode_anim_variant(
    parse_root("<val><clrVal><srgbClr val=\"ff00aa\"/></clrVal></val>"),
  )
  match decoded {
    Some(@domain.AnimVariantColor(payload)) =>
      assert_eq(payload, "srgbClr:ff00aa")
    _ => fail("expected color variant")
  }
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
