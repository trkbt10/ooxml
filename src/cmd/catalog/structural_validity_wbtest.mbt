///|
fn assert_catalog_empty_root_path(
  ancestry : Map[String, Array[Array[(String, String)]]],
  name : String,
  type_name : String,
) -> Unit raise {
  match ancestry.get(nt_key(name, type_name)) {
    Some(paths) => {
      assert_true(paths.length() > 0)
      assert_eq(paths[0].length(), 0)
    }
    None => abort("missing ancestry for " + name + " " + type_name)
  }
}

///|
fn assert_catalog_first_path_root(
  ancestry : Map[String, Array[Array[(String, String)]]],
  name : String,
  type_name : String,
  root_name : String,
) -> Unit raise {
  match ancestry.get(nt_key(name, type_name)) {
    Some(paths) => {
      assert_true(paths.length() > 0)
      assert_true(paths[0].length() > 0)
      assert_eq(paths[0][0].0, root_name)
    }
    None => abort("missing ancestry for " + name + " " + type_name)
  }
}

///|
test "catalog pptx empty-body package reopens after context save" {
  let host = empty_body_package("pptx")
  let presentation = @pml_context.open(host) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let saved = presentation.save_or_raise() catch {
    @pml_context.SaveError(kind~, path~, reason~) =>
      abort("save failed: " + kind + " " + path + " " + reason)
  }
  try @pml_context.open(saved) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("reopen failed: " + kind + " " + path + " " + reason)
  } noraise {
    _ => ()
  }
}

///|
test "catalog routes presentation part root through presentation host" {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let host_name = catalog_host_for_root("presentation", "pptx")
  assert_eq(host_name, "pptx:presentation")
  let host = host_package(host_name, xep("p", ns_p, "presentation", [], []))
  let presentation = @pml_context.open(host) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let saved = presentation.save_or_raise() catch {
    @pml_context.SaveError(kind~, path~, reason~) =>
      abort("save failed: " + kind + " " + path + " " + reason)
  }
  try @pml_context.open(saved) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("reopen failed: " + kind + " " + path + " " + reason)
  } noraise {
    _ => ()
  }
}

///|
test "catalog seeds strict supplementary roots through type-qualified registry" {
  let ancestry = build_ancestry(load_catalog_schema())
  let strict_theme = "http://purl.oclc.org/ooxml/drawingml/main#CT_OfficeStyleSheet"
  assert_eq(catalog_host_for_root_type("theme", strict_theme, ""), "pptx:theme")
  assert_catalog_empty_root_path(ancestry, "theme", strict_theme)
  assert_catalog_first_path_root(
    ancestry, "themeElements", "http://purl.oclc.org/ooxml/drawingml/main#CT_BaseStyles",
    "theme",
  )
  let strict_presentation = "http://purl.oclc.org/ooxml/presentationml/main#CT_Presentation"
  assert_eq(
    catalog_host_for_root_type("presentation", strict_presentation, "pptx"),
    "pptx:presentation",
  )
  assert_catalog_empty_root_path(ancestry, "presentation", strict_presentation)
  let strict_workbook = "http://purl.oclc.org/ooxml/spreadsheetml/main#CT_Workbook"
  assert_eq(
    catalog_host_for_root_type("workbook", strict_workbook, "xlsx"),
    "xlsx:workbook",
  )
  assert_catalog_empty_root_path(ancestry, "workbook", strict_workbook)
  let strict_styles = "http://purl.oclc.org/ooxml/spreadsheetml/main#CT_Stylesheet"
  assert_eq(
    catalog_host_for_root_type("styleSheet", strict_styles, "xlsx"),
    "xlsx:styles",
  )
  assert_catalog_empty_root_path(ancestry, "styleSheet", strict_styles)
  let strict_sst = "http://purl.oclc.org/ooxml/spreadsheetml/main#CT_Sst"
  assert_eq(
    catalog_host_for_root_type("sst", strict_sst, "xlsx"),
    "xlsx:sharedStrings",
  )
  assert_catalog_empty_root_path(ancestry, "sst", strict_sst)
  let strict_sml_comments = "http://purl.oclc.org/ooxml/spreadsheetml/main#CT_Comments"
  assert_eq(
    catalog_host_for_root_type("comments", strict_sml_comments, "xlsx"),
    "xlsx:comments",
  )
  assert_catalog_empty_root_path(ancestry, "comments", strict_sml_comments)
  let strict_xdr = "http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing#CT_Drawing"
  assert_eq(catalog_host_for_root_type("wsDr", strict_xdr, ""), "xlsx:drawing")
  assert_catalog_empty_root_path(ancestry, "wsDr", strict_xdr)
  let trans_xdr = "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing#CT_Drawing"
  assert_eq(
    catalog_host_for_root_type("wsDr", trans_xdr, "xlsx"),
    "xlsx:drawing",
  )
  assert_catalog_empty_root_path(ancestry, "wsDr", trans_xdr)
  let strict_wml_comments = "http://purl.oclc.org/ooxml/wordprocessingml/main#CT_Comments"
  assert_eq(
    catalog_host_for_root_type("comments", strict_wml_comments, "docx"),
    "docx:comments",
  )
  assert_catalog_empty_root_path(ancestry, "comments", strict_wml_comments)
  let strict_wml_fonts = "http://purl.oclc.org/ooxml/wordprocessingml/main#CT_FontsList"
  assert_eq(
    catalog_host_for_root_type("fonts", strict_wml_fonts, "docx"),
    "docx:fonts",
  )
  assert_catalog_empty_root_path(ancestry, "fonts", strict_wml_fonts)
  assert_catalog_first_path_root(
    ancestry, "fonts", "http://purl.oclc.org/ooxml/spreadsheetml/main#CT_Fonts",
    "styleSheet",
  )
}

///|
test "catalog fidelity proves skeleton-spliced singletons through extLst marker" {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  let presentation = stamp_target(xep("p", ns_p, "presentation", [], []))
  assert_eq(
    roundtrip_fidelity("pptx:presentation", presentation, "CAT-FY-PRES"),
    "fy-inject",
  )
  let theme = stamp_target(xep("a", ns_a, "theme", [xa("name", "Catalog")], []))
  assert_eq(
    roundtrip_fidelity("pptx:theme", theme, "CAT-FY-THEME"),
    "fy-inject",
  )
  let theme_elements = xep("a", ns_a, "theme", [xa("name", "Catalog")], [
    Element(stamp_target(xep("a", ns_a, "themeElements", [], []))),
  ])
  assert_eq(
    roundtrip_fidelity("pptx:theme", theme_elements, "CAT-FY-THEME-ELEMENTS"),
    "fy-inject",
  )
}

///|
test "catalog docx font-table host retargets synthesized font relationship id" {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let font = xep(
    "w",
    ns_w,
    "font",
    [
      {
        name: { prefix: Some("w"), local_name: "name", ns: Some(ns_w) },
        value: "CatalogFont",
      },
    ],
    [
      Element(
        xep(
          "w",
          ns_w,
          "embedRegular",
          [
            {
              name: {
                prefix: Some("r"),
                local_name: "id",
                ns: Some(NS_OFFICE_REL),
              },
              value: "0",
            },
          ],
          [],
        ),
      ),
    ],
  )
  let host = docx_aux_package("fonts", font)
  let pkg = @opc.Package::open(host) catch { _ => abort("OPC open failed") }
  match pkg.relationships("/word/fontTable.xml") {
    Some(rels) => {
      assert_eq(rels.relationships.length(), 1)
      assert_eq(rels.relationships[0].id, FONT_TABLE_DATA_RID)
    }
    None => abort("expected fontTable relationships")
  }
  let document = @wml_context.open(host) catch {
    @wml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let saved = document.save_or_raise() catch {
    @wml_context.SaveError(kind~, path~, reason~) =>
      abort("save failed: " + kind + " " + path + " " + reason)
  }
  try @wml_context.open(saved) catch {
    @wml_context.OpenError(kind~, path~, reason~) =>
      abort("reopen failed: " + kind + " " + path + " " + reason)
  } noraise {
    _ => ()
  }
}

///|
test "catalog font fixture lets docx render default font metrics" {
  install_catalog_font_fixture()
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let body = xep("w", ns_w, "body", [], [
    Element(
      xep("w", ns_w, "p", [], [
        Element(
          xep("w", ns_w, "r", [], [
            Element(xep("w", ns_w, "t", [], [Text("Catalog font fixture")])),
          ]),
        ),
      ]),
    ),
  ])
  let svg = match render_svg_of("docx", host_package("docx", body)) {
    Some(s) => s
    None => abort("expected docx render with catalog font fixture")
  }
  assert_true(svg.contains("Catalog font fixture"))
}

///|
test "catalog xlsx comments host retargets synthesized comment ref to sheet cell" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let s_attr = fn(local_name : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("s"), local_name, ns: Some(ns_s) }, value }
  }
  let comments = xep("s", ns_s, "comments", [], [
    Element(
      xep("s", ns_s, "authors", [], [
        Element(xep("s", ns_s, "author", [], [Text("Catalog")])),
      ]),
    ),
    Element(
      xep("s", ns_s, "commentList", [], [
        Element(
          xep(
            "s",
            ns_s,
            "comment",
            [s_attr("ref", "x"), s_attr("authorId", "0")],
            [
              Element(
                xep("s", ns_s, "text", [], [
                  Element(xep("s", ns_s, "t", [], [Text("note")])),
                ]),
              ),
            ],
          ),
        ),
      ]),
    ),
  ])
  let workbook = @sml_context.open(
    xlsx_with_aux_root_package("comments", comments),
  ) catch {
    @sml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let saved = workbook.save_or_raise() catch {
    @sml_context.SaveError(kind~, path~, reason~) =>
      abort("save failed: " + kind + " " + path + " " + reason)
  }
  let reopened = @sml_context.open(saved) catch {
    @sml_context.OpenError(kind~, path~, reason~) =>
      abort("reopen failed: " + kind + " " + path + " " + reason)
  }
  let svg = reopened.to_svg(debug_attrs=true)
  assert_true(svg.contains("class=\"comment-indicators\""))
  assert_true(svg.contains("data-ooxml-comment-ref=\"A1\""))
  assert_true(!svg.contains("data-ooxml-comment-ref=\"x\""))
}

///|
fn catalog_xdr_marker(
  local_name : String,
  col : String,
  row : String,
) -> @xml.Element {
  let ns_xdr = "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
  xep("xdr", ns_xdr, local_name, [], [
    Element(xep("xdr", ns_xdr, "col", [], [Text(col)])),
    Element(xep("xdr", ns_xdr, "colOff", [], [Text("0")])),
    Element(xep("xdr", ns_xdr, "row", [], [Text(row)])),
    Element(xep("xdr", ns_xdr, "rowOff", [], [Text("0")])),
  ])
}

///|
fn catalog_xdr_shape() -> @xml.Element {
  let ns_xdr = "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  xep("xdr", ns_xdr, "sp", [], [
    Element(
      xep("xdr", ns_xdr, "nvSpPr", [], [
        Element(
          xep(
            "xdr",
            ns_xdr,
            "cNvPr",
            [xa("id", "2"), xa("name", "Catalog Shape")],
            [],
          ),
        ),
        Element(xep("xdr", ns_xdr, "cNvSpPr", [], [])),
      ]),
    ),
    Element(
      xep("xdr", ns_xdr, "spPr", [], [
        Element(
          xep("a", ns_a, "prstGeom", [xa("prst", "rect")], [
            Element(xep("a", ns_a, "avLst", [], [])),
          ]),
        ),
        Element(
          xep("a", ns_a, "solidFill", [], [
            Element(xep("a", ns_a, "srgbClr", [xa("val", "4472C4")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xep("xdr", ns_xdr, "txBody", [], [
        Element(xep("a", ns_a, "bodyPr", [], [])),
        Element(xep("a", ns_a, "lstStyle", [], [])),
        Element(xep("a", ns_a, "p", [], [])),
      ]),
    ),
  ])
}

///|
test "catalog xlsx drawing host wires wsDr through worksheet drawing rel" {
  let ns_xdr = "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
  let anchor = xep("xdr", ns_xdr, "twoCellAnchor", [], [
    Element(catalog_xdr_marker("from", "0", "0")),
    Element(catalog_xdr_marker("to", "3", "5")),
    Element(catalog_xdr_shape()),
    Element(xep("xdr", ns_xdr, "clientData", [], [])),
  ])
  let ws_dr = xep("xdr", ns_xdr, "wsDr", [], [Element(stamp_target(anchor))])
  assert_eq(verify_entry("xlsx:drawing", ws_dr, "CAT-XDR-DRAWING"), "rendered")
  let workbook = @sml_context.open(
    host_package("xlsx:drawing", strip_target_attr(ws_dr)),
  ) catch {
    @sml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  match workbook.worksheets[0].drawing {
    Some(drawing) => assert_true(drawing.anchors.length() > 0)
    None => abort("expected WorksheetPart.drawing to be resolved")
  }
  match workbook.worksheets[0].drawing_part {
    Some(part) => assert_eq(part, "/xl/drawings/drawing1.xml")
    None => abort("expected drawing_part to be resolved")
  }
  let svg = workbook.to_svg(debug_attrs=true)
  assert_true(svg.contains("<g class=\"drawings\">"))
  assert_true(svg.contains("<g class=\"drawing\""))
  assert_true(svg.contains("data-ooxml-twocell-anchor=\"1\""))
  assert_true(svg.contains("data-ooxml-twocell-anchor-to-col=\"3\""))
}

///|
test "catalog synth emits non-degenerate xdr twoCellAnchor" {
  let ns_xdr = "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
  let schema = load_catalog_schema()
  let mut anchor : @xml.Element? = None
  for _key, decl in schema.all_elements {
    if decl.name == "twoCellAnchor" && decl.ns == ns_xdr {
      match schema.complex_types.get(decl.type_name) {
        Some(ct) => {
          let st : StrSet = Map([], capacity=0)
          st[decl.type_name] = true
          anchor = Some(
            synth_element(
              schema,
              ct,
              decl.ns,
              decl.name,
              st,
              0,
              RICH_BUDGET,
              include_optional_attrs=true,
            ),
          )
        }
        None => ()
      }
    }
  }
  let anchor = match anchor {
    Some(a) => a
    None => abort("expected transitional xdr twoCellAnchor declaration")
  }
  let ws_dr = xep("xdr", ns_xdr, "wsDr", [], [Element(stamp_target(anchor))])
  assert_eq(verify_entry("xlsx:drawing", ws_dr, "CAT-XDR-SYNTH"), "rendered")
}

///|
test "catalog xlsx autofilter host supplies dxf facts for colorFilter" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let color_filter = stamp_target(
    xep("s", ns_s, "colorFilter", [xa("dxfId", "1"), xa("cellColor", "1")], []),
  )
  let worksheet = xep("s", ns_s, "worksheet", [], [
    Element(
      xep("s", ns_s, "autoFilter", [], [
        Element(
          xep("s", ns_s, "filterColumn", [xa("colId", "1")], [
            Element(color_filter),
          ]),
        ),
      ]),
    ),
  ])
  assert_eq(verify_entry("xlsx", worksheet, "CAT-AF-COLOR"), "rendered")
  let svg = match
    render_svg_of("xlsx", host_package("xlsx", strip_target_attr(worksheet))) {
    Some(s) => s
    None => abort("expected colorFilter host to render")
  }
  assert_true(svg.contains("Red low"))
  assert_true(!svg.contains("Green middle"))
  assert_true(svg.contains("Red high"))
}

///|
test "catalog xlsx autofilter host supplies icon facts for iconFilter" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let icon_filter = stamp_target(
    xep(
      "s",
      ns_s,
      "iconFilter",
      [xa("iconSet", "3Arrows"), xa("iconId", "1")],
      [],
    ),
  )
  let worksheet = xep("s", ns_s, "worksheet", [], [
    Element(
      xep("s", ns_s, "autoFilter", [], [
        Element(
          xep("s", ns_s, "filterColumn", [xa("colId", "1")], [
            Element(icon_filter),
          ]),
        ),
      ]),
    ),
  ])
  assert_eq(verify_entry("xlsx", worksheet, "CAT-AF-ICON"), "rendered")
  let svg = match
    render_svg_of("xlsx", host_package("xlsx", strip_target_attr(worksheet))) {
    Some(s) => s
    None => abort("expected iconFilter host to render")
  }
  assert_true(!svg.contains("Red low"))
  assert_true(svg.contains("Green middle"))
  assert_true(!svg.contains("Red high"))
}

///|
test "catalog pptx diagram relIds host uses existing SmartArt renderer" {
  fn r_attr(local_name : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("r"), local_name, ns: Some(NS_OFFICE_REL) }, value }
  }

  let rel_ids = stamp_target(
    xep(
      "dgm",
      NS_DGM,
      "relIds",
      [
        r_attr("dm", "catalogDm"),
        r_attr("lo", "catalogLo"),
        r_attr("qs", "catalogQs"),
        r_attr("cs", "catalogCs"),
      ],
      [],
    ),
  )
  assert_eq(
    verify_entry("pptx:diagram-relids", rel_ids, "CAT-DGM-RELIDS"),
    "rendered",
  )
  let svg = match
    render_svg_of(
      "pptx:diagram-relids",
      host_package("pptx:diagram-relids", strip_target_attr(rel_ids)),
    ) {
    Some(s) => s
    None => abort("expected diagram relIds host to render")
  }
  assert_true(svg.contains("data-ooxml=\"diagram\""))
}

///|
test "catalog pptx host inserts required cSld before slide transition" {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let transition = xep("p", ns_p, "transition", [xa("spd", "fast")], [
    Element(xep("p", ns_p, "fade", [], [])),
  ])
  let presentation = @pml_context.open(pptx_package(transition)) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let saved = presentation.save_or_raise() catch {
    @pml_context.SaveError(kind~, path~, reason~) =>
      abort("save failed: " + kind + " " + path + " " + reason)
  }
  let reopened = @pml_context.open(saved) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("reopen failed: " + kind + " " + path + " " + reason)
  }
  let svg = reopened.to_svg(debug_attrs=true)
  assert_true(svg.contains("data-ooxml-transition=\"fade\""))
  assert_true(svg.contains("data-ooxml-transition-spd=\"fast\""))
}

///|
test "catalog pptx host inserts required cSld before slide timing" {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let timing = xep("p", ns_p, "timing", [], [
    Element(
      xep("p", ns_p, "tnLst", [], [Element(xep("p", ns_p, "par", [], []))]),
    ),
  ])
  let presentation = @pml_context.open(pptx_package(timing)) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let saved = presentation.save_or_raise() catch {
    @pml_context.SaveError(kind~, path~, reason~) =>
      abort("save failed: " + kind + " " + path + " " + reason)
  }
  let reopened = @pml_context.open(saved) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("reopen failed: " + kind + " " + path + " " + reason)
  }
  let svg = reopened.to_svg(debug_attrs=true)
  assert_true(svg.contains("data-ooxml-timing-tnLst=\"par\""))
  assert_true(svg.contains("data-ooxml-timing-count=\"1\""))
}
