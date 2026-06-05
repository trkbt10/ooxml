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
fn extras_pml_presentation_coverage(cases : Array[VisualCase]) -> Unit {
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
