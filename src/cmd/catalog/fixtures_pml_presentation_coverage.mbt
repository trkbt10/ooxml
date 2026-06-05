// PresentationML presentation/view/presentation-properties occurrence
// fixtures. These target §19 roots and auxiliary parts that do not
// change the slide render but are valid package-level PML payloads.

///|
fn pml_cov_rid_attr(id : String) -> @xml.Attribute {
  {
    name: {
      prefix: Some("r"),
      local_name: "id",
      ns: Some(
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      ),
    },
    value: id,
  }
}

///|
fn pml_cov_ext_list() -> @xml.Element {
  xe(NS_PML, "extLst", [], [
    Element(xe(NS_PML, "ext", [xa("uri", "urn:ooxml-catalog:pml")], [])),
  ])
}

///|
fn pml_cov_html_pub_pr() -> @xml.Element {
  xep(
    "p",
    NS_PML,
    "htmlPubPr",
    [
      pml_cov_rid_attr("rId1"),
      xa("showSpeakerNotes", "1"),
      xa("target", "catalog"),
      xa("title", "Catalog HTML Publish"),
    ],
    [Element(xep("p", NS_PML, "sldAll", [], [])), Element(pml_cov_ext_list())],
  )
}

///|
fn pml_cov_color(hex : String) -> @xml.Element {
  xe(NS_A, "srgbClr", [xa("val", hex)], [])
}

///|
fn pml_cov_text_list_style() -> @xml.Element {
  xe(NS_A, "defPPr", [], [
    Element(
      xe(NS_A, "defRPr", [xa("lang", "en-US"), xa("sz", "1800")], [
        Element(xe(NS_A, "solidFill", [], [Element(pml_cov_color("404040"))])),
      ]),
    ),
  ])
}

///|
fn pml_cov_clr_map() -> @xml.Element {
  xep(
    "p",
    NS_PML,
    "clrMap",
    [
      xa("bg1", "lt1"),
      xa("tx1", "dk1"),
      xa("bg2", "lt2"),
      xa("tx2", "dk2"),
      xa("accent1", "accent1"),
      xa("accent2", "accent2"),
      xa("accent3", "accent3"),
      xa("accent4", "accent4"),
      xa("accent5", "accent5"),
      xa("accent6", "accent6"),
      xa("hlink", "hlink"),
      xa("folHlink", "folHlink"),
    ],
    [],
  )
}

///|
fn pml_cov_shape_tree_with_content_part() -> @xml.Element {
  let tree = pptx_shape_tree(NS_PML, [])
  let children : Array[@xml.Node] = []
  for child in tree.children {
    children.push(child)
  }
  children.push(
    Element(xep("p", NS_PML, "contentPart", [pml_cov_rid_attr("rId2")], [])),
  )
  { name: tree.name, attributes: tree.attributes, children }
}

///|
fn pml_cov_slide_refs_root() -> @xml.Element {
  xep("p", NS_PML, "cSld", [xa("name", "Catalog slide refs")], [
    Element(
      xep("p", NS_PML, "bg", [], [
        Element(
          xep("p", NS_PML, "bgRef", [xa("idx", "1001")], [
            Element(xe(NS_A, "schemeClr", [xa("val", "bg1")], [])),
          ]),
        ),
      ]),
    ),
    Element(pml_cov_shape_tree_with_content_part()),
    Element(
      xep("p", NS_PML, "custDataLst", [], [
        Element(xep("p", NS_PML, "custData", [pml_cov_rid_attr("rId3")], [])),
        Element(xep("p", NS_PML, "tags", [pml_cov_rid_attr("rId4")], [])),
      ]),
    ),
    Element(
      xep("p", NS_PML, "controls", [], [
        Element(
          xep(
            "p",
            NS_PML,
            "control",
            [xa("name", "CatalogControl"), xa("showAsIcon", "0")],
            [Element(pml_cov_ext_list())],
          ),
        ),
      ]),
    ),
  ])
}

///|
fn pml_cov_comments_root() -> @xml.Element {
  xep("p", NS_PML, "cmLst", [], [
    Element(
      xep(
        "p",
        NS_PML,
        "cm",
        [xa("authorId", "0"), xa("idx", "1"), xa("dt", "2026-06-06T00:00:00Z")],
        [
          Element(xep("p", NS_PML, "pos", [xa("x", "0"), xa("y", "0")], [])),
          Element(xep("p", NS_PML, "text", [], [Text("Catalog comment")])),
        ],
      ),
    ),
  ])
}

///|
fn pml_cov_comment_authors_root() -> @xml.Element {
  xep("p", NS_PML, "cmAuthorLst", [], [
    Element(
      xep(
        "p",
        NS_PML,
        "cmAuthor",
        [
          xa("id", "0"),
          xa("name", "Catalog Author"),
          xa("initials", "CA"),
          xa("lastIdx", "1"),
          xa("clrIdx", "0"),
        ],
        [],
      ),
    ),
  ])
}

///|
fn pml_cov_notes_root() -> @xml.Element {
  xep("p", NS_PML, "notes", [], [Element(pptx_common_slide_data(NS_PML, []))])
}

///|
fn pml_cov_notes_master_root() -> @xml.Element {
  xep("p", NS_PML, "notesMaster", [], [
    Element(pptx_common_slide_data(NS_PML, [])),
    Element(pml_cov_clr_map()),
    Element(
      xep(
        "p",
        NS_PML,
        "hf",
        [xa("sldNum", "1"), xa("hdr", "1"), xa("ftr", "1"), xa("dt", "1")],
        [],
      ),
    ),
    Element(
      xep("p", NS_PML, "notesStyle", [], [Element(pml_cov_text_list_style())]),
    ),
  ])
}

///|
fn pml_cov_handout_master_root() -> @xml.Element {
  xep("p", NS_PML, "handoutMaster", [], [
    Element(pptx_common_slide_data(NS_PML, [])),
    Element(pml_cov_clr_map()),
    Element(
      xep(
        "p",
        NS_PML,
        "hf",
        [xa("sldNum", "1"), xa("hdr", "1"), xa("ftr", "1"), xa("dt", "1")],
        [],
      ),
    ),
  ])
}

///|
fn pml_cov_slide_sync_root() -> @xml.Element {
  xep(
    "p",
    NS_PML,
    "sldSyncPr",
    [
      xa("serverSldId", "catalog-slide"),
      xa("serverSldModifiedTime", "2026-06-06T00:00:00Z"),
      xa("clientInsertedTime", "2026-06-06T00:00:00Z"),
    ],
    [Element(pml_cov_ext_list())],
  )
}

///|
fn pml_cov_presentation_refs_root() -> @xml.Element {
  xep("p", NS_PML, "presentation", [], [
    Element(
      xep("p", NS_PML, "sldMasterIdLst", [], [
        Element(
          xep(
            "p",
            NS_PML,
            "sldMasterId",
            [xa("id", "2147483648"), pml_cov_rid_attr("rId2")],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep("p", NS_PML, "notesMasterIdLst", [], [
        Element(
          xep("p", NS_PML, "notesMasterId", [pml_cov_rid_attr("rId4")], []),
        ),
      ]),
    ),
    Element(
      xep("p", NS_PML, "handoutMasterIdLst", [], [
        Element(
          xep("p", NS_PML, "handoutMasterId", [pml_cov_rid_attr("rId5")], []),
        ),
      ]),
    ),
    Element(
      xep("p", NS_PML, "sldIdLst", [], [
        Element(
          xep(
            "p",
            NS_PML,
            "sldId",
            [xa("id", "256"), pml_cov_rid_attr("rId1")],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep(
        "p",
        NS_PML,
        "sldSz",
        [xa("cx", "9144000"), xa("cy", "6858000"), xa("type", "screen4x3")],
        [],
      ),
    ),
    Element(
      xe(NS_PML, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
    ),
    Element(xep("p", NS_PML, "smartTags", [pml_cov_rid_attr("rId6")], [])),
    Element(
      xep("p", NS_PML, "embeddedFontLst", [], [
        Element(
          xep("p", NS_PML, "embeddedFont", [], [
            Element(xep("p", NS_PML, "font", [xa("typeface", "Aptos")], [])),
            Element(xep("p", NS_PML, "regular", [pml_cov_rid_attr("rId9")], [])),
            Element(xep("p", NS_PML, "bold", [pml_cov_rid_attr("rId10")], [])),
            Element(xep("p", NS_PML, "italic", [pml_cov_rid_attr("rId11")], [])),
            Element(
              xep("p", NS_PML, "boldItalic", [pml_cov_rid_attr("rId12")], []),
            ),
          ]),
        ),
      ]),
    ),
    Element(
      xep("p", NS_PML, "custDataLst", [], [
        Element(xep("p", NS_PML, "custData", [pml_cov_rid_attr("rId7")], [])),
        Element(xep("p", NS_PML, "tags", [pml_cov_rid_attr("rId8")], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "defaultTextStyle", [], [Element(pml_cov_text_list_style())]),
    ),
    Element(pml_cov_ext_list()),
  ])
}

///|
fn pml_cov_presentation_root() -> @xml.Element {
  xep("p", NS_PML, "presentation", [], [
    Element(
      xe(NS_PML, "embeddedFontLst", [], [
        Element(
          xe(NS_PML, "embeddedFont", [], [
            Element(xe(NS_PML, "font", [xa("typeface", "Aptos")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(NS_PML, "custShowLst", [], [
        Element(
          xe(NS_PML, "custShow", [xa("name", "Catalog Show"), xa("id", "1")], [
            Element(
              xe(NS_PML, "sldLst", [], [
                Element(xe(NS_PML, "sld", [pml_cov_rid_attr("rId1")], [])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
    Element(
      xe(
        NS_PML,
        "photoAlbum",
        [
          xa("bw", "0"),
          xa("showCaptions", "1"),
          xa("layout", "2pic"),
          xa("frame", "frameStyle2"),
        ],
        [],
      ),
    ),
    Element(xe(NS_PML, "custDataLst", [], [])),
    Element(
      xe(
        NS_PML,
        "kinsoku",
        [
          xa("lang", "ja-JP"),
          xa("invalStChars", "、。)]}"),
          xa("invalEndChars", "([{'"),
        ],
        [],
      ),
    ),
    Element(
      xe(NS_PML, "defaultTextStyle", [], [Element(pml_cov_text_list_style())]),
    ),
    Element(
      xe(
        NS_PML,
        "modifyVerifier",
        [
          xa("algorithmName", "SHA-1"),
          xa("hashValue", "AA=="),
          xa("saltValue", "AA=="),
          xa("spinValue", "1"),
        ],
        [],
      ),
    ),
    Element(pml_cov_ext_list()),
  ])
}

///|
fn pml_cov_scale() -> @xml.Element {
  xe(NS_PML, "scale", [], [
    Element(xe(NS_A, "sx", [xa("n", "1"), xa("d", "1")], [])),
    Element(xe(NS_A, "sy", [xa("n", "1"), xa("d", "1")], [])),
  ])
}

///|
fn pml_cov_common_view() -> @xml.Element {
  xe(NS_PML, "cViewPr", [], [
    Element(pml_cov_scale()),
    Element(xe(NS_PML, "origin", [xa("x", "0"), xa("y", "0")], [])),
  ])
}

///|
fn pml_cov_common_slide_view() -> @xml.Element {
  xe(
    NS_PML,
    "cSldViewPr",
    [xa("snapToGrid", "1"), xa("snapToObjects", "1"), xa("showGuides", "1")],
    [
      Element(pml_cov_common_view()),
      Element(
        xe(NS_PML, "guideLst", [], [
          Element(
            xe(NS_PML, "guide", [xa("orient", "vert"), xa("pos", "914400")], []),
          ),
          Element(
            xe(NS_PML, "guide", [xa("orient", "horz"), xa("pos", "685800")], []),
          ),
        ]),
      ),
    ],
  )
}

///|
fn pml_cov_view_props_root() -> @xml.Element {
  xep("p", NS_PML, "viewPr", [xa("lastView", "sldView")], [
    Element(
      xe(
        NS_PML,
        "normalViewPr",
        [
          xa("showOutlineIcons", "1"),
          xa("snapVertSplitter", "1"),
          xa("vertBarState", "restored"),
          xa("horzBarState", "restored"),
          xa("preferSingleView", "0"),
        ],
        [
          Element(xe(NS_PML, "restoredLeft", [xa("sz", "25000")], [])),
          Element(xe(NS_PML, "restoredTop", [xa("sz", "75000")], [])),
        ],
      ),
    ),
    Element(
      xe(NS_PML, "slideViewPr", [], [
        Element(pml_cov_common_slide_view()),
        Element(pml_cov_ext_list()),
      ]),
    ),
    Element(
      xe(NS_PML, "outlineViewPr", [], [
        Element(pml_cov_common_view()),
        Element(pml_cov_ext_list()),
      ]),
    ),
    Element(
      xe(NS_PML, "sorterViewPr", [xa("showFormatting", "1")], [
        Element(pml_cov_common_view()),
        Element(pml_cov_ext_list()),
      ]),
    ),
    Element(
      xe(NS_PML, "notesViewPr", [], [
        Element(pml_cov_common_slide_view()),
        Element(pml_cov_ext_list()),
      ]),
    ),
    Element(
      xe(NS_PML, "gridSpacing", [xa("cx", "914400"), xa("cy", "914400")], []),
    ),
    Element(pml_cov_ext_list()),
  ])
}

///|
fn pml_cov_presentation_pr_root(
  show_kind : String,
  slide_kind : String,
) -> @xml.Element {
  let show_child = match show_kind {
    "browse" => xe(NS_PML, "browse", [xa("showScrollbar", "1")], [])
    "kiosk" => xe(NS_PML, "kiosk", [xa("restart", "300000")], [])
    _ => xe(NS_PML, "present", [], [])
  }
  let slide_child = match slide_kind {
    "range" => xe(NS_PML, "sldRg", [xa("st", "1"), xa("end", "1")], [])
    "custom" => xe(NS_PML, "custShow", [xa("id", "1")], [])
    _ => xe(NS_PML, "sldAll", [], [])
  }
  xep("p", NS_PML, "presentationPr", [], [
    Element(pml_cov_html_pub_pr()),
    Element(
      xe(
        NS_PML,
        "webPr",
        [
          xa("showAnimation", "1"),
          xa("resizeGraphics", "1"),
          xa("allowPng", "1"),
          xa("relyOnVml", "0"),
          xa("organizeInFolders", "1"),
          xa("useLongFilenames", "1"),
          xa("imgSz", "1024x768"),
          xa("encoding", "utf-8"),
          xa("clr", "whiteTextOnBlack"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PML,
        "prnPr",
        [
          xa("prnWhat", "slides"),
          xa("clrMode", "clr"),
          xa("hiddenSlides", "0"),
          xa("scaleToFitPaper", "1"),
          xa("frameSlides", "1"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PML,
        "showPr",
        [
          xa("loop", "1"),
          xa("showNarration", "1"),
          xa("showAnimation", "1"),
          xa("useTimings", "1"),
        ],
        [
          Element(show_child),
          Element(slide_child),
          Element(xe(NS_PML, "penClr", [], [Element(pml_cov_color("FF0000"))])),
          Element(pml_cov_ext_list()),
        ],
      ),
    ),
    Element(
      xe(NS_PML, "clrMru", [], [
        Element(pml_cov_color("FF0000")),
        Element(pml_cov_color("00B050")),
      ]),
    ),
    Element(pml_cov_ext_list()),
  ])
}

///|
fn pml_cov_master_tx_styles_root() -> @xml.Element {
  xep("p", NS_PML, "txStyles", [], [
    Element(xe(NS_PML, "titleStyle", [], [Element(pml_cov_text_list_style())])),
    Element(xe(NS_PML, "bodyStyle", [], [Element(pml_cov_text_list_style())])),
    Element(xe(NS_PML, "otherStyle", [], [Element(pml_cov_text_list_style())])),
  ])
}

///|
fn pml_cov_shape_style() -> @xml.Element {
  xep("p", NS_PML, "style", [], [
    Element(
      xep("a", NS_A, "lnRef", [xa("idx", "1")], [
        Element(pml_cov_color("4472C4")),
      ]),
    ),
    Element(
      xep("a", NS_A, "fillRef", [xa("idx", "1")], [
        Element(pml_cov_color("E2F0D9")),
      ]),
    ),
    Element(
      xep("a", NS_A, "effectRef", [xa("idx", "0")], [
        Element(pml_cov_color("F2F2F2")),
      ]),
    ),
    Element(
      xep("a", NS_A, "fontRef", [xa("idx", "minor")], [
        Element(pml_cov_color("404040")),
      ]),
    ),
  ])
}

///|
fn pml_cov_ole_choice(kind : String) -> @xml.Element {
  match kind {
    "link" =>
      xep("p", NS_PML, "link", [xa("updateAutomatic", "1")], [
        Element(pml_cov_ext_list()),
      ])
    _ =>
      xep("p", NS_PML, "embed", [xa("followColorScheme", "none")], [
        Element(pml_cov_ext_list()),
      ])
  }
}

///|
fn pml_cov_ole_pic(
  id_ : String,
  name : String,
  x : String,
  fill : String,
) -> @xml.Element {
  xep("p", NS_PML, "pic", [], [
    Element(
      xep("p", NS_PML, "nvPicPr", [], [
        Element(
          xep("p", NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], []),
        ),
        Element(
          xep("p", NS_PML, "cNvPicPr", [], [
            Element(xep("a", NS_A, "picLocks", [xa("noChangeAspect", "1")], [])),
          ]),
        ),
        Element(xep("p", NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xep("p", NS_PML, "blipFill", [], [
        Element(xep("a", NS_A, "blip", [], [])),
        Element(catalog_default_stretch()),
      ]),
    ),
    Element(
      xep("p", NS_PML, "spPr", [], [
        Element(sp_xfrm(x, "1828800", "2286000", "1714500")),
        Element(
          xep("a", NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xep("a", NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill(fill)),
      ]),
    ),
    Element(pml_cov_shape_style()),
  ])
}

///|
fn pml_cov_ole_obj(
  kind : String,
  spid : String,
  name : String,
  x : String,
  fill : String,
) -> @xml.Element {
  xep(
    "p",
    NS_PML,
    "oleObj",
    [
      xa("progId", "Package"),
      xa("spid", spid),
      xa("name", name),
      xa("showAsIcon", "0"),
      xa("imgW", "2286000"),
      xa("imgH", "1714500"),
    ],
    [
      Element(pml_cov_ole_choice(kind)),
      Element(pml_cov_ole_pic(spid, name + " Preview", x, fill)),
    ],
  )
}

///|
fn pml_cov_ole_graphic_frame(
  id_ : String,
  name : String,
  x : String,
  kind : String,
  fill : String,
) -> @xml.Element {
  xep("p", NS_PML, "graphicFrame", [], [
    Element(
      xep("p", NS_PML, "nvGraphicFramePr", [], [
        Element(
          xep("p", NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], []),
        ),
        Element(xep("p", NS_PML, "cNvGraphicFramePr", [], [])),
        Element(xep("p", NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xep("p", NS_PML, "xfrm", [], [
        Element(xep("a", NS_A, "off", [xa("x", x), xa("y", "1371600")], [])),
        Element(
          xep("a", NS_A, "ext", [xa("cx", "2743200"), xa("cy", "2286000")], []),
        ),
      ]),
    ),
    Element(
      xep("a", NS_A, "graphic", [], [
        Element(
          xep(
            "a",
            NS_A,
            "graphicData",
            [
              xa(
                "uri", "http://schemas.openxmlformats.org/presentationml/2006/ole",
              ),
            ],
            [Element(pml_cov_ole_obj(kind, id_, name + " Object", x, fill))],
          ),
        ),
      ]),
    ),
  ])
}

///|
fn extras_pml_ole_slides(cases : Array[MediaSlideCase]) -> Unit {
  let extra_rels : Array[(String, String, String, String)] = []
  cases.push({
    id: "pml-ole-objects-rich",
    format: "pptx",
    category: "presentation",
    content: sp_tree([
      pml_cov_ole_graphic_frame(
        "2", "Embedded OLE", "914400", "embed", "DDEBF7",
      ),
      pml_cov_ole_graphic_frame("3", "Linked OLE", "5029200", "link", "FCE4D6"),
    ]),
    extra_rels,
  })
}

///|
fn extras_pml_presentation_coverage(cases : Array[VisualCase]) -> Unit {
  cases.push({
    id: "pml-slide-refs-rich",
    format: "pptx:slideRefs",
    category: "presentation",
    content: pml_cov_slide_refs_root(),
  })

  cases.push({
    id: "pml-comments-rich",
    format: "pptx:comments",
    category: "presentation",
    content: pml_cov_comments_root(),
  })

  cases.push({
    id: "pml-comment-authors-rich",
    format: "pptx:commentAuthors",
    category: "presentation",
    content: pml_cov_comment_authors_root(),
  })

  cases.push({
    id: "pml-notes-rich",
    format: "pptx:notes",
    category: "presentation",
    content: pml_cov_notes_root(),
  })

  cases.push({
    id: "pml-notes-master-rich",
    format: "pptx:notesMaster",
    category: "presentation",
    content: pml_cov_notes_master_root(),
  })

  cases.push({
    id: "pml-handout-master-rich",
    format: "pptx:handoutMaster",
    category: "presentation",
    content: pml_cov_handout_master_root(),
  })

  cases.push({
    id: "pml-slide-sync-properties-rich",
    format: "pptx:sldSyncPr",
    category: "presentation",
    content: pml_cov_slide_sync_root(),
  })

  cases.push({
    id: "pml-presentation-refs-rich",
    format: "pptx:presentationRefs",
    category: "presentation",
    content: pml_cov_presentation_refs_root(),
  })

  cases.push({
    id: "pml-presentation-properties",
    format: "pptx:presentation",
    category: "presentation",
    content: pml_cov_presentation_root(),
  })

  cases.push({
    id: "pml-view-properties-rich",
    format: "pptx:viewPr",
    category: "presentation",
    content: pml_cov_view_props_root(),
  })

  cases.push({
    id: "pml-presprops-present-all",
    format: "pptx:presentationPr",
    category: "presentation",
    content: pml_cov_presentation_pr_root("present", "all"),
  })

  cases.push({
    id: "pml-presprops-browse-range",
    format: "pptx:presentationPr",
    category: "presentation",
    content: pml_cov_presentation_pr_root("browse", "range"),
  })

  cases.push({
    id: "pml-presprops-kiosk-custom",
    format: "pptx:presentationPr",
    category: "presentation",
    content: pml_cov_presentation_pr_root("kiosk", "custom"),
  })

  cases.push({
    id: "pml-master-text-styles-rich",
    format: "pptx:master-txstyle",
    category: "presentation",
    content: pml_cov_master_tx_styles_root(),
  })
}
