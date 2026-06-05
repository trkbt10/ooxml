// DrawingML main coverage fixtures for schema-backed XML branches that
// ordinary shape/color/effect fixtures do not naturally emit.

///|
const DML_MAIN_TABLE_URI : String = "http://schemas.openxmlformats.org/drawingml/2006/table"

///|
fn dml_main_pos(x : String, y : String) -> @xml.Element {
  xe(NS_A, "pos", [xa("x", x), xa("y", y)], [])
}

///|
fn dml_main_path_pt(x : String, y : String) -> @xml.Node {
  Element(xe(NS_A, "pt", [xa("x", x), xa("y", y)], []))
}

///|
fn dml_main_custom_geometry() -> @xml.Element {
  let cubic_pts : Array[@xml.Node] = [
    dml_main_path_pt("80000", "30000"),
    dml_main_path_pt("70000", "90000"),
    dml_main_path_pt("10000", "80000"),
  ]
  xe(NS_A, "custGeom", [], [
    Element(xe(NS_A, "avLst", [], [])),
    Element(
      xe(NS_A, "gdLst", [], [
        Element(
          xe(NS_A, "gd", [xa("name", "adjX"), xa("fmla", "val 50000")], []),
        ),
        Element(
          xe(NS_A, "gd", [xa("name", "adjY"), xa("fmla", "val 35000")], []),
        ),
      ]),
    ),
    Element(
      xe(NS_A, "ahLst", [], [
        Element(
          xe(
            NS_A,
            "ahXY",
            [
              xa("gdRefX", "adjX"),
              xa("minX", "0"),
              xa("maxX", "100000"),
              xa("gdRefY", "adjY"),
              xa("minY", "0"),
              xa("maxY", "100000"),
            ],
            [Element(dml_main_pos("adjX", "adjY"))],
          ),
        ),
        Element(
          xe(
            NS_A,
            "ahPolar",
            [
              xa("gdRefR", "adjX"),
              xa("minR", "0"),
              xa("maxR", "100000"),
              xa("gdRefAng", "adjY"),
              xa("minAng", "0"),
              xa("maxAng", "21600000"),
            ],
            [Element(dml_main_pos("50000", "50000"))],
          ),
        ),
      ]),
    ),
    Element(
      xe(NS_A, "cxnLst", [], [
        Element(
          xe(NS_A, "cxn", [xa("ang", "0")], [
            Element(dml_main_pos("0", "50000")),
          ]),
        ),
        Element(
          xe(NS_A, "cxn", [xa("ang", "10800000")], [
            Element(dml_main_pos("100000", "50000")),
          ]),
        ),
      ]),
    ),
    Element(
      xe(
        NS_A,
        "rect",
        [xa("l", "0"), xa("t", "0"), xa("r", "100000"), xa("b", "100000")],
        [],
      ),
    ),
    Element(
      xe(NS_A, "pathLst", [], [
        Element(
          xe(NS_A, "path", [xa("w", "100000"), xa("h", "100000")], [
            Element(xe(NS_A, "moveTo", [], [dml_main_path_pt("0", "0")])),
            Element(xe(NS_A, "lnTo", [], [dml_main_path_pt("100000", "0")])),
            Element(
              xe(
                NS_A,
                "arcTo",
                [
                  xa("wR", "25000"),
                  xa("hR", "25000"),
                  xa("stAng", "0"),
                  xa("swAng", "5400000"),
                ],
                [],
              ),
            ),
            Element(xe(NS_A, "cubicBezTo", [], cubic_pts)),
            Element(xe(NS_A, "close", [], [])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn dml_main_custom_geometry_shape() -> @xml.Element {
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "2"), xa("name", "Custom Geometry")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("914400", "914400", "2743200", "2057400")),
        Element(dml_main_custom_geometry()),
        Element(solid_fill("4472C4")),
        Element(
          xe(NS_A, "ln", [xa("w", "25400")], [Element(solid_fill("1F4E79"))]),
        ),
      ]),
    ),
  ])
}

///|
fn dml_main_scene3d() -> @xml.Element {
  xe(NS_A, "scene3d", [], [
    Element(
      xe(
        NS_A,
        "camera",
        [xa("prst", "perspectiveFront"), xa("fov", "5400000")],
        [
          Element(
            xe(NS_A, "rot", [xa("lat", "0"), xa("lon", "0"), xa("rev", "0")], []),
          ),
        ],
      ),
    ),
    Element(
      xe(NS_A, "lightRig", [xa("rig", "threePt"), xa("dir", "t")], [
        Element(
          xe(NS_A, "rot", [xa("lat", "0"), xa("lon", "0"), xa("rev", "0")], []),
        ),
      ]),
    ),
    Element(
      xe(NS_A, "backdrop", [], [
        Element(
          xe(NS_A, "anchor", [xa("x", "0"), xa("y", "0"), xa("z", "0")], []),
        ),
        Element(
          xe(NS_A, "norm", [xa("dx", "0"), xa("dy", "0"), xa("dz", "100000")], []),
        ),
        Element(
          xe(NS_A, "up", [xa("dx", "0"), xa("dy", "100000"), xa("dz", "0")], []),
        ),
      ]),
    ),
  ])
}

///|
fn dml_main_shape3d() -> @xml.Element {
  xe(
    NS_A,
    "sp3d",
    [xa("z", "76200"), xa("extrusionH", "50800"), xa("contourW", "12700")],
    [
      Element(
        xe(
          NS_A,
          "bevelT",
          [xa("w", "50800"), xa("h", "50800"), xa("prst", "circle")],
          [],
        ),
      ),
      Element(
        xe(
          NS_A,
          "bevelB",
          [xa("w", "38100"), xa("h", "38100"), xa("prst", "relaxedInset")],
          [],
        ),
      ),
      Element(
        xe(NS_A, "extrusionClr", [], [
          Element(xe(NS_A, "srgbClr", [xa("val", "5B9BD5")], [])),
        ]),
      ),
      Element(
        xe(NS_A, "contourClr", [], [
          Element(xe(NS_A, "srgbClr", [xa("val", "1F4E79")], [])),
        ]),
      ),
    ],
  )
}

///|
fn dml_main_shape_3d_scene() -> @xml.Element {
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "3"), xa("name", "Scene3D Shape")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("4572000", "914400", "2743200", "2057400")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "roundRect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("70AD47")),
        Element(dml_main_scene3d()),
        Element(dml_main_shape3d()),
      ]),
    ),
  ])
}

///|
fn dml_main_effect_dag() -> @xml.Element {
  xe(NS_A, "effectDag", [xa("type", "tree"), xa("name", "coverageDag")], [
    Element(xe(NS_A, "alphaOutset", [xa("rad", "12700")], [])),
    Element(
      xe(NS_A, "blend", [xa("blend", "mult")], [
        Element(
          xe(NS_A, "cont", [xa("type", "sib"), xa("name", "blendChildren")], [
            Element(xe(NS_A, "effect", [xa("ref", "source")], [])),
            Element(
              xe(NS_A, "fill", [], [
                Element(
                  xe(NS_A, "solidFill", [], [
                    Element(xe(NS_A, "srgbClr", [xa("val", "FFC000")], [])),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn dml_main_effect_dag_shape() -> @xml.Element {
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "4"), xa("name", "Effect DAG")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("914400", "3657600", "2743200", "1371600")),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill("ED7D31")),
        Element(dml_main_effect_dag()),
      ]),
    ),
  ])
}

///|
fn dml_main_text_font_collection() -> @xml.Element {
  xe(NS_A, "font", [], [
    Element(xe(NS_A, "latin", [xa("typeface", "Aptos")], [])),
    Element(xe(NS_A, "ea", [xa("typeface", "Yu Gothic")], [])),
    Element(xe(NS_A, "cs", [xa("typeface", "Arial")], [])),
    Element(
      xe(NS_A, "font", [xa("script", "Jpan"), xa("typeface", "Yu Gothic")], []),
    ),
  ])
}

///|
fn dml_main_direct_bullet_ppr() -> @xml.Element {
  xe(NS_A, "pPr", [xa("marL", "342900"), xa("indent", "-342900")], [
    Element(
      xe(NS_A, "buClr", [], [
        Element(xe(NS_A, "srgbClr", [xa("val", "C00000")], [])),
      ]),
    ),
    Element(xe(NS_A, "buSzPct", [xa("val", "125%")], [])),
    Element(xe(NS_A, "buFont", [xa("typeface", "Aptos")], [])),
    Element(xe(NS_A, "buBlip", [], [Element(xe(NS_A, "blip", [], []))])),
    Element(
      xe(NS_A, "tabLst", [], [
        Element(xe(NS_A, "tab", [xa("pos", "914400"), xa("algn", "l")], [])),
      ]),
    ),
    Element(
      xe(NS_A, "defRPr", [xa("sz", "2200"), xa("lang", "en-US")], [
        Element(solid_fill("1F4E79")),
        Element(
          xe(NS_A, "highlight", [], [
            Element(xe(NS_A, "srgbClr", [xa("val", "FFF2CC")], [])),
          ]),
        ),
        Element(xe(NS_A, "latin", [xa("typeface", "Aptos")], [])),
        Element(xe(NS_A, "ea", [xa("typeface", "Yu Gothic")], [])),
        Element(xe(NS_A, "cs", [xa("typeface", "Arial")], [])),
        Element(xe(NS_A, "sym", [xa("typeface", "Wingdings")], [])),
        Element(
          xe(
            NS_A,
            "hlinkMouseOver",
            [xa("action", "ppaction://hlinkshowjump?jump=nextslide")],
            [],
          ),
        ),
        Element(xe(NS_A, "rtl", [xa("val", "0")], [])),
      ]),
    ),
  ])
}

///|
fn dml_main_point_bullet_ppr() -> @xml.Element {
  xe(NS_A, "pPr", [xa("marL", "342900"), xa("indent", "-342900")], [
    Element(
      xe(NS_A, "buClr", [], [
        Element(xe(NS_A, "schemeClr", [xa("val", "accent2")], [])),
      ]),
    ),
    Element(xe(NS_A, "buSzPts", [xa("val", "1800")], [])),
    Element(xe(NS_A, "buFont", [xa("typeface", "Aptos")], [])),
    Element(xe(NS_A, "buChar", [xa("char", "*")], [])),
  ])
}

///|
fn dml_main_follow_text_bullet_ppr() -> @xml.Element {
  xe(NS_A, "pPr", [xa("marL", "342900"), xa("indent", "-342900")], [
    Element(xe(NS_A, "buClrTx", [], [])),
    Element(xe(NS_A, "buSzTx", [], [])),
    Element(xe(NS_A, "buFontTx", [], [])),
    Element(xe(NS_A, "buChar", [xa("char", "-")], [])),
  ])
}

///|
fn dml_main_plain_run(text : String) -> @xml.Element {
  xe(NS_A, "r", [], [
    Element(xe(NS_A, "rPr", [xa("lang", "en-US")], [])),
    Element(xe(NS_A, "t", [], [Text(text)])),
  ])
}

///|
fn dml_main_paragraph(
  ppr : @xml.Element,
  text : String,
  end_text_size : String,
) -> @xml.Element {
  xe(NS_A, "p", [], [
    Element(ppr),
    Element(dml_main_plain_run(text)),
    Element(
      xe(NS_A, "endParaRPr", [xa("sz", end_text_size), xa("lang", "en-US")], [
        Element(xe(NS_A, "latin", [xa("typeface", "Aptos")], [])),
      ]),
    ),
  ])
}

///|
fn dml_main_field_paragraph() -> @xml.Element {
  xe(NS_A, "p", [], [
    Element(
      xe(
        NS_A,
        "fld",
        [
          xa("id", "{00000000-0000-0000-0000-000000000123}"),
          xa("type", "slidenum"),
        ],
        [
          Element(xe(NS_A, "rPr", [xa("lang", "en-US")], [])),
          Element(xe(NS_A, "pPr", [], [])),
          Element(xe(NS_A, "t", [], [Text("1")])),
        ],
      ),
    ),
  ])
}

///|
fn dml_main_empty_text_level(name : String) -> @xml.Element {
  xe(NS_A, name, [], [])
}

///|
fn dml_main_rich_text_shape() -> @xml.Element {
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "5"), xa("name", "Rich DML Text")], []),
        ),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm("4572000", "3657600", "3657600", "1828800")),
      ]),
    ),
    Element(
      xe(NS_PML, "txBody", [], [
        Element(
          xe(NS_A, "bodyPr", [xa("anchor", "ctr")], [
            Element(
              xe(NS_A, "prstTxWarp", [xa("prst", "textArchUp")], [
                Element(xe(NS_A, "avLst", [], [])),
              ]),
            ),
            Element(
              xe(
                NS_A,
                "normAutofit",
                [xa("fontScale", "92000"), xa("lnSpcReduction", "10000")],
                [],
              ),
            ),
            Element(xe(NS_A, "flatTx", [xa("z", "0")], [])),
          ]),
        ),
        Element(
          xe(NS_A, "lstStyle", [], [
            Element(
              xe(NS_A, "defPPr", [], [
                Element(xe(NS_A, "defRPr", [xa("sz", "1800")], [])),
              ]),
            ),
            Element(dml_main_empty_text_level("lvl1pPr")),
            Element(dml_main_empty_text_level("lvl2pPr")),
            Element(dml_main_empty_text_level("lvl3pPr")),
            Element(dml_main_empty_text_level("lvl4pPr")),
            Element(dml_main_empty_text_level("lvl5pPr")),
            Element(dml_main_empty_text_level("lvl6pPr")),
            Element(dml_main_empty_text_level("lvl7pPr")),
            Element(dml_main_empty_text_level("lvl8pPr")),
            Element(dml_main_empty_text_level("lvl9pPr")),
          ]),
        ),
        Element(
          dml_main_paragraph(
            dml_main_direct_bullet_ppr(),
            "blip bullet",
            "1800",
          ),
        ),
        Element(
          dml_main_paragraph(
            dml_main_point_bullet_ppr(),
            "point bullet",
            "1600",
          ),
        ),
        Element(
          dml_main_paragraph(
            dml_main_follow_text_bullet_ppr(),
            "follow text bullet",
            "1600",
          ),
        ),
        Element(dml_main_field_paragraph()),
      ]),
    ),
  ])
}

///|
fn dml_main_line_props(hex : String) -> @xml.Element {
  xe(NS_A, "ln", [xa("w", "12700")], [Element(solid_fill(hex))])
}

///|
fn dml_main_table_border(name : String, hex : String) -> @xml.Element {
  xe(NS_A, name, [], [Element(dml_main_line_props(hex))])
}

///|
fn dml_main_cell_line(name : String, hex : String) -> @xml.Element {
  xe(NS_A, name, [xa("w", "12700")], [Element(solid_fill(hex))])
}

///|
fn dml_main_table_cell3d() -> @xml.Element {
  xe(NS_A, "cell3D", [xa("prstMaterial", "plastic")], [
    Element(
      xe(
        NS_A,
        "bevel",
        [xa("w", "38100"), xa("h", "38100"), xa("prst", "circle")],
        [],
      ),
    ),
    Element(xe(NS_A, "lightRig", [xa("rig", "balanced"), xa("dir", "t")], [])),
  ])
}

///|
fn dml_main_table_style_part() -> @xml.Element {
  xe(NS_A, "wholeTbl", [], [
    Element(
      xe(NS_A, "tcTxStyle", [xa("b", "on"), xa("i", "off")], [
        Element(dml_main_text_font_collection()),
        Element(xe(NS_A, "schemeClr", [xa("val", "tx1")], [])),
      ]),
    ),
    Element(
      xe(NS_A, "tcStyle", [], [
        Element(
          xe(NS_A, "tcBdr", [], [
            Element(dml_main_table_border("left", "5B9BD5")),
            Element(dml_main_table_border("right", "5B9BD5")),
            Element(dml_main_table_border("top", "5B9BD5")),
            Element(dml_main_table_border("bottom", "5B9BD5")),
            Element(dml_main_table_border("insideH", "70AD47")),
            Element(dml_main_table_border("insideV", "70AD47")),
          ]),
        ),
        Element(
          xe(NS_A, "fill", [], [
            Element(
              xe(NS_A, "solidFill", [], [
                Element(xe(NS_A, "srgbClr", [xa("val", "D9EAF7")], [])),
              ]),
            ),
          ]),
        ),
        Element(dml_main_table_cell3d()),
      ]),
    ),
  ])
}

///|
fn dml_main_empty_table_part(name : String) -> @xml.Element {
  xe(NS_A, name, [], [])
}

///|
fn dml_main_table_style() -> @xml.Element {
  xe(
    NS_A,
    "tableStyle",
    [
      xa("styleId", "{11111111-1111-1111-1111-111111111111}"),
      xa("styleName", "Coverage Table"),
    ],
    [
      Element(
        xe(NS_A, "tblBg", [], [
          Element(
            xe(NS_A, "fill", [], [
              Element(
                xe(NS_A, "solidFill", [], [
                  Element(xe(NS_A, "srgbClr", [xa("val", "FFFFFF")], [])),
                ]),
              ),
            ]),
          ),
          Element(
            xe(NS_A, "effect", [], [Element(xe(NS_A, "effectLst", [], []))]),
          ),
        ]),
      ),
      Element(dml_main_table_style_part()),
      Element(dml_main_empty_table_part("band1H")),
      Element(dml_main_empty_table_part("band2H")),
      Element(dml_main_empty_table_part("band1V")),
      Element(dml_main_empty_table_part("band2V")),
      Element(dml_main_empty_table_part("lastCol")),
      Element(dml_main_empty_table_part("firstCol")),
      Element(dml_main_empty_table_part("lastRow")),
      Element(dml_main_empty_table_part("seCell")),
      Element(dml_main_empty_table_part("swCell")),
      Element(dml_main_empty_table_part("firstRow")),
      Element(dml_main_empty_table_part("neCell")),
      Element(dml_main_empty_table_part("nwCell")),
    ],
  )
}

///|
fn dml_main_table_properties() -> @xml.Element {
  xe(
    NS_A,
    "tblPr",
    [
      xa("firstRow", "1"),
      xa("firstCol", "1"),
      xa("bandRow", "1"),
      xa("bandCol", "1"),
    ],
    [
      Element(
        xe(NS_A, "pattFill", [xa("prst", "pct20")], [
          Element(
            xe(NS_A, "fgClr", [], [
              Element(xe(NS_A, "srgbClr", [xa("val", "5B9BD5")], [])),
            ]),
          ),
          Element(
            xe(NS_A, "bgClr", [], [
              Element(xe(NS_A, "srgbClr", [xa("val", "FFFFFF")], [])),
            ]),
          ),
        ]),
      ),
      Element(dml_main_table_style()),
    ],
  )
}

///|
fn dml_main_table_text_body(text : String) -> @xml.Element {
  xe(NS_A, "txBody", [], [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
    Element(xe(NS_A, "p", [], [Element(dml_main_plain_run(text))])),
  ])
}

///|
fn dml_main_table_cell(text : String) -> @xml.Element {
  xe(NS_A, "tc", [], [
    Element(dml_main_table_text_body(text)),
    Element(
      xe(NS_A, "tcPr", [], [
        Element(dml_main_cell_line("lnL", "5B9BD5")),
        Element(dml_main_cell_line("lnR", "5B9BD5")),
        Element(dml_main_cell_line("lnT", "5B9BD5")),
        Element(dml_main_cell_line("lnB", "5B9BD5")),
        Element(dml_main_cell_line("lnTlToBr", "A5A5A5")),
        Element(dml_main_cell_line("lnBlToTr", "A5A5A5")),
        Element(dml_main_table_cell3d()),
        Element(solid_fill("E2F0D9")),
        Element(
          xe(NS_A, "headers", [], [
            Element(xe(NS_A, "header", [], [Text("Coverage header")])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn dml_main_table_root() -> @xml.Element {
  xe(NS_A, "tbl", [], [
    Element(dml_main_table_properties()),
    Element(
      xe(NS_A, "tblGrid", [], [
        Element(xe(NS_A, "gridCol", [xa("w", "2743200")], [])),
        Element(xe(NS_A, "gridCol", [xa("w", "2743200")], [])),
      ]),
    ),
    Element(
      xe(NS_A, "tr", [xa("h", "914400")], [
        Element(dml_main_table_cell("A1")),
        Element(dml_main_table_cell("B1")),
      ]),
    ),
  ])
}

///|
fn dml_main_table_graphic_frame() -> @xml.Element {
  xe(NS_PML, "graphicFrame", [], [
    Element(
      xe(NS_PML, "nvGraphicFramePr", [], [
        Element(
          xe(NS_PML, "cNvPr", [xa("id", "6"), xa("name", "DML Table")], []),
        ),
        Element(
          xe(NS_PML, "cNvGraphicFramePr", [], [
            Element(
              xe(
                NS_A,
                "graphicFrameLocks",
                [xa("noGrp", "1"), xa("noResize", "1")],
                [],
              ),
            ),
          ]),
        ),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "xfrm", [], [
        Element(xe(NS_A, "off", [xa("x", "914400"), xa("y", "914400")], [])),
        Element(xe(NS_A, "ext", [xa("cx", "5486400"), xa("cy", "1828800")], [])),
      ]),
    ),
    Element(
      xe(NS_A, "graphic", [], [
        Element(
          xe(NS_A, "graphicData", [xa("uri", DML_MAIN_TABLE_URI)], [
            Element(dml_main_table_root()),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn extras_dml_main_coverage(cases : Array[VisualCase]) -> Unit {
  cases.push({
    id: "dml-main-custom-geometry-3d-effects-text",
    format: "pptx",
    category: "drawing/main",
    content: sp_tree([
      dml_main_custom_geometry_shape(),
      dml_main_shape_3d_scene(),
      dml_main_effect_dag_shape(),
      dml_main_rich_text_shape(),
    ]),
  })

  cases.push({
    id: "dml-main-table-graphic-data",
    format: "pptx",
    category: "drawing/main",
    content: sp_tree([dml_main_table_graphic_frame()]),
  })
}
