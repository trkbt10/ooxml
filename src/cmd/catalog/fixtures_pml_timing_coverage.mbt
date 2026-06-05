// PresentationML timing occurrence fixtures. These focus on the
// ECMA-376 §19.5 time-node tree: animation behavior choices,
// condition lists, variants, media nodes, and build-list entries.

///|
fn pml_tcov_nodes(elements : Array[@xml.Element]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for e in elements {
    nodes.push(Element(e))
  }
  nodes
}

///|
fn pml_tcov_el(
  name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Element],
) -> @xml.Element {
  xe(NS_PML, name, attrs, pml_tcov_nodes(children))
}

///|
fn pml_tcov_point(name : String, x : String, y : String) -> @xml.Element {
  xe(NS_PML, name, [xa("x", x), xa("y", y)], [])
}

///|
fn pml_tcov_condition_child(
  name : String,
  child : @xml.Element,
) -> @xml.Element {
  pml_tcov_el(name, [xa("evt", "onBegin"), xa("delay", "0")], [child])
}

///|
fn pml_tcov_condition_empty(name : String) -> @xml.Element {
  xe(NS_PML, name, [xa("evt", "begin"), xa("delay", "0")], [])
}

///|
fn pml_tcov_cond_list(name : String) -> @xml.Element {
  pml_tcov_el(name, [], [
    pml_tcov_condition_child(
      "cond",
      pml_tcov_el("tgtEl", [], [xe(NS_PML, "sldTgt", [], [])]),
    ),
    pml_tcov_condition_child("cond", pml_tcov_el("tn", [xa("val", "1")], [])),
    pml_tcov_condition_child("cond", pml_tcov_el("rtn", [xa("val", "all")], [])),
  ])
}

///|
fn pml_tcov_iterate_abs() -> @xml.Element {
  pml_tcov_el("iterate", [xa("type", "wd"), xa("backwards", "0")], [
    xe(NS_PML, "tmAbs", [xa("val", "250")], []),
  ])
}

///|
fn pml_tcov_iterate_pct() -> @xml.Element {
  pml_tcov_el("iterate", [xa("type", "lt"), xa("backwards", "1")], [
    xe(NS_PML, "tmPct", [xa("val", "50000")], []),
  ])
}

///|
fn pml_tcov_ctn(id : String, children : Array[@xml.Element]) -> @xml.Element {
  pml_tcov_el(
    "cTn",
    [
      xa("id", id),
      xa("dur", "1000"),
      xa("repeatCount", "1000"),
      xa("spd", "100000"),
      xa("accel", "0"),
      xa("decel", "0"),
      xa("restart", "always"),
      xa("fill", "hold"),
      xa("syncBehavior", "canSlip"),
      xa("display", "1"),
      xa("masterRel", "sameClick"),
      xa("nodeType", "clickEffect"),
    ],
    children,
  )
}

///|
fn pml_tcov_simple_ctn(id : String) -> @xml.Element {
  pml_tcov_ctn(id, [])
}

///|
fn pml_tcov_sp_target(spid : String, child : @xml.Element?) -> @xml.Element {
  let kids : Array[@xml.Element] = []
  match child {
    Some(e) => kids.push(e)
    None => ()
  }
  pml_tcov_el("spTgt", [xa("spid", spid)], kids)
}

///|
fn pml_tcov_tgt_el(target : @xml.Element) -> @xml.Element {
  pml_tcov_el("tgtEl", [], [target])
}

///|
fn pml_tcov_rel_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("r"), local_name, ns: Some(NS_OFFICE_REL) }, value }
}

///|
fn pml_tcov_embedded_wav(name : String, rid : String) -> @xml.Element {
  xep(
    "p",
    NS_PML,
    name,
    [pml_tcov_rel_attr("embed", rid), xa("name", "Catalog sound")],
    [],
  )
}

///|
fn pml_tcov_attr_names() -> @xml.Element {
  xe(NS_PML, "attrNameLst", [], [
    Element(xe(NS_PML, "attrName", [], [Text("style.color")])),
    Element(xe(NS_PML, "attrName", [], [Text("ppt_x")])),
  ])
}

///|
fn pml_tcov_common_behavior(id : String, target : @xml.Element) -> @xml.Element {
  pml_tcov_el(
    "cBhvr",
    [
      xa("additive", "sum"),
      xa("accumulate", "always"),
      xa("xfrmType", "pt"),
      xa("from", "0"),
      xa("to", "1"),
      xa("by", "1"),
      xa("override", "normal"),
    ],
    [pml_tcov_simple_ctn(id), pml_tcov_tgt_el(target), pml_tcov_attr_names()],
  )
}

///|
fn pml_tcov_variant(name : String, child : @xml.Element) -> @xml.Element {
  pml_tcov_el(name, [], [child])
}

///|
fn pml_tcov_tav(tm : String, child : @xml.Element) -> @xml.Element {
  pml_tcov_el("tav", [xa("tm", tm), xa("fmla", "")], [
    pml_tcov_variant("val", child),
  ])
}

///|
fn pml_tcov_tav_list() -> @xml.Element {
  pml_tcov_el("tavLst", [], [
    pml_tcov_tav("0", xe(NS_PML, "boolVal", [xa("val", "1")], [])),
    pml_tcov_tav("25000", xe(NS_PML, "intVal", [xa("val", "42")], [])),
    pml_tcov_tav("50000", xe(NS_PML, "fltVal", [xa("val", "3.5")], [])),
    pml_tcov_tav("75000", xe(NS_PML, "strVal", [xa("val", "catalog")], [])),
    pml_tcov_tav(
      "100000",
      pml_tcov_el("clrVal", [], [xe(NS_A, "srgbClr", [xa("val", "4472C4")], [])]),
    ),
  ])
}

///|
fn pml_tcov_anim() -> @xml.Element {
  pml_tcov_el(
    "anim",
    [
      xa("valueType", "num"),
      xa("calcmode", "lin"),
      xa("from", "0"),
      xa("to", "100"),
      xa("by", "10"),
    ],
    [
      pml_tcov_common_behavior(
        "10",
        pml_tcov_sp_target(
          "2",
          Some(
            pml_tcov_el("txEl", [], [
              xe(NS_PML, "charRg", [xa("st", "0"), xa("end", "4")], []),
            ]),
          ),
        ),
      ),
      pml_tcov_tav_list(),
    ],
  )
}

///|
fn pml_tcov_anim_clr() -> @xml.Element {
  pml_tcov_el("animClr", [xa("clrSpc", "rgb"), xa("dir", "cw")], [
    pml_tcov_common_behavior(
      "11",
      pml_tcov_sp_target(
        "2",
        Some(
          pml_tcov_el("txEl", [], [
            xe(NS_PML, "pRg", [xa("st", "0"), xa("end", "1")], []),
          ]),
        ),
      ),
    ),
    pml_tcov_el("by", [], [
      pml_tcov_el("rgb", [xa("r", "10000"), xa("g", "0"), xa("b", "0")], []),
    ]),
    pml_tcov_el("from", [], [xe(NS_A, "srgbClr", [xa("val", "4472C4")], [])]),
    pml_tcov_el("to", [], [xe(NS_A, "srgbClr", [xa("val", "ED7D31")], [])]),
  ])
}

///|
fn pml_tcov_anim_clr_hsl() -> @xml.Element {
  pml_tcov_el("animClr", [xa("clrSpc", "hsl"), xa("dir", "ccw")], [
    pml_tcov_common_behavior(
      "12",
      pml_tcov_sp_target("2", Some(pml_tcov_el("subSp", [xa("spid", "3")], []))),
    ),
    pml_tcov_el("by", [], [
      pml_tcov_el("hsl", [xa("h", "60000"), xa("s", "10000"), xa("l", "0")], []),
    ]),
  ])
}

///|
fn pml_tcov_anim_effect() -> @xml.Element {
  pml_tcov_el("animEffect", [xa("transition", "in"), xa("filter", "fade")], [
    pml_tcov_common_behavior(
      "13",
      pml_tcov_sp_target(
        "2",
        Some(
          pml_tcov_el("oleChartEl", [xa("type", "series"), xa("lvl", "0")], []),
        ),
      ),
    ),
    pml_tcov_variant("progress", xe(NS_PML, "strVal", [xa("val", "0.5")], [])),
  ])
}

///|
fn pml_tcov_anim_motion() -> @xml.Element {
  pml_tcov_el(
    "animMotion",
    [
      xa("origin", "layout"),
      xa("path", "M 0 0 L 0.25 0.25 E"),
      xa("pathEditMode", "relative"),
      xa("rAng", "0"),
      xa("ptsTypes", "A"),
    ],
    [
      pml_tcov_common_behavior("14", pml_tcov_sp_target("2", None)),
      pml_tcov_point("by", "10000", "10000"),
      pml_tcov_point("from", "0", "0"),
      pml_tcov_point("to", "50000", "50000"),
      pml_tcov_point("rCtr", "50000", "50000"),
    ],
  )
}

///|
fn pml_tcov_anim_rot() -> @xml.Element {
  pml_tcov_el(
    "animRot",
    [xa("by", "5400000"), xa("from", "0"), xa("to", "10800000")],
    [pml_tcov_common_behavior("15", pml_tcov_sp_target("2", None))],
  )
}

///|
fn pml_tcov_anim_scale() -> @xml.Element {
  pml_tcov_el("animScale", [xa("zoomContents", "1")], [
    pml_tcov_common_behavior("16", pml_tcov_sp_target("2", None)),
    pml_tcov_point("by", "10000", "10000"),
    pml_tcov_point("from", "100000", "100000"),
    pml_tcov_point("to", "125000", "125000"),
  ])
}

///|
fn pml_tcov_cmd() -> @xml.Element {
  pml_tcov_el("cmd", [xa("type", "evt"), xa("cmd", "play")], [
    pml_tcov_common_behavior("17", xe(NS_PML, "inkTgt", [xa("spid", "2")], [])),
  ])
}

///|
fn pml_tcov_set() -> @xml.Element {
  pml_tcov_el("set", [], [
    pml_tcov_common_behavior("18", pml_tcov_sp_target("2", None)),
    pml_tcov_variant("to", xe(NS_PML, "strVal", [xa("val", "visible")], [])),
  ])
}

///|
fn pml_tcov_media_node(name : String, id : String) -> @xml.Element {
  pml_tcov_media_node_target(name, id, xe(NS_PML, "sldTgt", [], []))
}

///|
fn pml_tcov_media_node_target(
  name : String,
  id : String,
  target : @xml.Element,
) -> @xml.Element {
  pml_tcov_el(name, [], [
    pml_tcov_el(
      "cMediaNode",
      [
        xa("vol", "50000"),
        xa("mute", "0"),
        xa("numSld", "1"),
        xa("showWhenStopped", "1"),
      ],
      [pml_tcov_simple_ctn(id), pml_tcov_tgt_el(target)],
    ),
  ])
}

///|
fn pml_tcov_seq() -> @xml.Element {
  pml_tcov_el(
    "seq",
    [xa("concurrent", "0"), xa("prevAc", "none"), xa("nextAc", "seek")],
    [
      pml_tcov_ctn("20", [pml_tcov_iterate_pct()]),
      pml_tcov_cond_list("prevCondLst"),
      pml_tcov_cond_list("nextCondLst"),
    ],
  )
}

///|
fn pml_tcov_excl() -> @xml.Element {
  pml_tcov_el("excl", [], [pml_tcov_simple_ctn("21")])
}

///|
fn pml_tcov_child_tn_list() -> @xml.Element {
  pml_tcov_el("childTnLst", [], [
    pml_tcov_seq(),
    pml_tcov_excl(),
    pml_tcov_anim(),
    pml_tcov_anim_clr(),
    pml_tcov_anim_clr_hsl(),
    pml_tcov_anim_effect(),
    pml_tcov_anim_motion(),
    pml_tcov_anim_rot(),
    pml_tcov_anim_scale(),
    pml_tcov_cmd(),
    pml_tcov_set(),
    pml_tcov_media_node("audio", "22"),
    pml_tcov_media_node("video", "23"),
  ])
}

///|
fn pml_tcov_sub_tn_list() -> @xml.Element {
  pml_tcov_el("subTnLst", [], [
    pml_tcov_el("par", [], [pml_tcov_simple_ctn("24")]),
  ])
}

///|
fn pml_tcov_tn_list() -> @xml.Element {
  pml_tcov_el("tnLst", [], [
    pml_tcov_el("par", [], [
      pml_tcov_ctn("1", [
        pml_tcov_cond_list("stCondLst"),
        pml_tcov_cond_list("endCondLst"),
        pml_tcov_condition_empty("endSync"),
        pml_tcov_iterate_abs(),
        pml_tcov_child_tn_list(),
        pml_tcov_sub_tn_list(),
      ]),
    ]),
  ])
}

///|
fn pml_tcov_template_list() -> @xml.Element {
  pml_tcov_el("tmplLst", [], [
    pml_tcov_el("tmpl", [xa("lvl", "0")], [
      pml_tcov_el("tnLst", [], [pml_tcov_anim_effect()]),
    ]),
  ])
}

///|
fn pml_tcov_build_list() -> @xml.Element {
  pml_tcov_el("bldLst", [], [
    pml_tcov_el(
      "bldP",
      [
        xa("spid", "2"),
        xa("grpId", "0"),
        xa("build", "p"),
        xa("bldLvl", "1"),
        xa("animBg", "1"),
        xa("autoUpdateAnimBg", "1"),
        xa("rev", "0"),
        xa("advAuto", "indefinite"),
      ],
      [pml_tcov_template_list()],
    ),
    xe(
      NS_PML,
      "bldDgm",
      [xa("spid", "2"), xa("grpId", "1"), xa("bld", "whole")],
      [],
    ),
    xe(
      NS_PML,
      "bldOleChart",
      [
        xa("spid", "2"),
        xa("grpId", "2"),
        xa("bld", "series"),
        xa("animBg", "1"),
      ],
      [],
    ),
    pml_tcov_el("bldGraphic", [xa("spid", "2"), xa("grpId", "3")], [
      xe(NS_PML, "bldAsOne", [], []),
    ]),
  ])
}

///|
fn pml_tcov_timing() -> @xml.Element {
  pml_tcov_el("timing", [], [pml_tcov_tn_list(), pml_tcov_build_list()])
}

///|
fn pml_tcov_slide() -> @xml.Element {
  pml_ml_cSld_with_extras(
    [
      pptx_shape(
        "2", "TimingTarget", "rect", "1828800", "1828800", "5486400", "3200400",
        "70AD47",
      ),
    ],
    [pml_tcov_timing()],
  )
}

///|
fn pml_tcov_transition_sound() -> @xml.Element {
  pml_tcov_el("transition", [xa("spd", "fast")], [
    pml_tcov_el("sndAc", [], [
      pml_tcov_el("stSnd", [xa("loop", "1")], [
        pml_tcov_embedded_wav("snd", "rId2"),
      ]),
    ]),
  ])
}

///|
fn pml_tcov_sound_timing() -> @xml.Element {
  pml_tcov_el("timing", [], [
    pml_tcov_el("tnLst", [], [
      pml_tcov_el("par", [], [
        pml_tcov_ctn("30", [
          pml_tcov_el("childTnLst", [], [
            pml_tcov_media_node_target(
              "audio",
              "31",
              pml_tcov_embedded_wav("sndTgt", "rId2"),
            ),
          ]),
        ]),
      ]),
    ]),
  ])
}

///|
fn pml_tcov_sound_slide() -> @xml.Element {
  pml_ml_cSld_with_extras(
    [
      pptx_shape(
        "2", "SoundTarget", "rect", "1828800", "1828800", "5486400", "3200400", "DDEBF7",
      ),
    ],
    [pml_tcov_transition_sound(), pml_tcov_sound_timing()],
  )
}

///|
fn extras_pml_timing_media_slides(cases : Array[MediaSlideCase]) -> Unit {
  let extra_rels : Array[(String, String, String, String)] = [
    (
      "rId2", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/audio",
      "https://example.com/catalog.wav", "External",
    ),
  ]
  cases.push({
    id: "pml-timing-sound-target-rich",
    format: "pptx",
    category: "timing",
    content: pml_tcov_sound_slide(),
    extra_rels,
  })
}

///|
fn extras_pml_timing_coverage(cases : Array[VisualCase]) -> Unit {
  cases.push({
    id: "pml-timing-behavior-build-rich",
    format: "pptx",
    category: "timing",
    content: pml_tcov_slide(),
  })
}
