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
  let strict_wml_hdr_ftr = "http://purl.oclc.org/ooxml/wordprocessingml/main#CT_HdrFtr"
  assert_eq(
    catalog_host_for_root_type("hdr", strict_wml_hdr_ftr, "docx"),
    "docx:header",
  )
  assert_catalog_empty_root_path(ancestry, "hdr", strict_wml_hdr_ftr)
  assert_eq(
    catalog_host_for_root_type("ftr", strict_wml_hdr_ftr, "docx"),
    "docx:footer",
  )
  assert_catalog_empty_root_path(ancestry, "ftr", strict_wml_hdr_ftr)
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
fn catalog_wml_hdr_ftr_probe(root_name : String, text : String) -> @xml.Element {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xep("w", ns_w, root_name, [], [
    Element(
      xep("w", ns_w, "p", [], [
        Element(
          xep("w", ns_w, "r", [], [
            Element(xep("w", ns_w, "t", [], [Text(text)])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
test "catalog docx header and footer hosts render referenced section parts" {
  install_catalog_font_fixture()
  let header = stamp_target(catalog_wml_hdr_ftr_probe("hdr", TEXT_MARKER))
  assert_eq(verify_entry("docx:header", header, "CAT-WML-HDR"), "rendered")
  let header_svg = match
    render_svg_of(
      "docx:header",
      host_package(
        "docx:header",
        catalog_wml_hdr_ftr_probe("hdr", "Catalog header text"),
      ),
    ) {
    Some(s) => s
    None => abort("expected header host to render")
  }
  assert_true(header_svg.contains("Catalog header text"))
  let footer = stamp_target(catalog_wml_hdr_ftr_probe("ftr", TEXT_MARKER))
  assert_eq(verify_entry("docx:footer", footer, "CAT-WML-FTR"), "rendered")
  let footer_svg = match
    render_svg_of(
      "docx:footer",
      host_package(
        "docx:footer",
        catalog_wml_hdr_ftr_probe("ftr", "Catalog footer text"),
      ),
    ) {
    Some(s) => s
    None => abort("expected footer host to render")
  }
  assert_true(footer_svg.contains("Catalog footer text"))
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
  install_catalog_font_fixture()
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
fn catalog_sml_shared_strings_probe(text : String) -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xep("s", ns_s, "sst", [], [
    Element(
      xep("s", ns_s, "si", [], [
        Element(
          xep("s", ns_s, "r", [], [
            Element(xep("s", ns_s, "t", [], [Text(text)])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
test "catalog xlsx sharedStrings host resolves sheet cell text" {
  install_catalog_font_fixture()
  let sst = stamp_target(catalog_sml_shared_strings_probe(TEXT_MARKER))
  assert_eq(verify_entry("xlsx:sharedStrings", sst, "CAT-SST-TEXT"), "rendered")
  let workbook = @sml_context.open(
    xlsx_with_aux_root_package(
      "sharedStrings",
      catalog_sml_shared_strings_probe("Catalog shared string"),
    ),
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
  assert_true(svg.contains("Catalog shared string"))
}

///|
test "catalog xlsx sharedStrings rich text properties route to renderer" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let cases : Array[(String, @xml.Element)] = [
    ("RPR", xep("s", ns_s, "rPr", [], [])),
    ("RFONT", xep("s", ns_s, "rFont", [], [])),
    ("CHARSET", xep("s", ns_s, "charset", [], [])),
    ("FAMILY", xep("s", ns_s, "family", [], [])),
    ("BOLD", xep("s", ns_s, "b", [], [])),
    ("ITALIC", xep("s", ns_s, "i", [], [])),
    ("STRIKE", xep("s", ns_s, "strike", [], [])),
    ("OUTLINE", xep("s", ns_s, "outline", [], [])),
    ("SHADOW", xep("s", ns_s, "shadow", [], [])),
    ("CONDENSE", xep("s", ns_s, "condense", [], [])),
    ("EXTEND", xep("s", ns_s, "extend", [], [])),
    ("COLOR", xep("s", ns_s, "color", [], [])),
    ("SZ", xep("s", ns_s, "sz", [], [])),
    ("U", xep("s", ns_s, "u", [], [])),
    ("VERTALIGN", xep("s", ns_s, "vertAlign", [], [])),
  ]
  for case in cases {
    let (id, target) = case
    let root = catalog_sml_shared_string_rich_text_root(stamp_target(target))
    assert_eq(
      verify_entry("xlsx:sharedStrings", root, "CAT-SST-" + id),
      "rendered",
    )
  }
}

///|
fn catalog_sml_render_styles_svg(styles : @xml.Element) -> String {
  install_catalog_font_fixture()
  let workbook = @sml_context.open(xlsx_with_aux_root_package("styles", styles)) catch {
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
  reopened.to_svg(debug_attrs=true)
}

///|
test "catalog fidelity preserves raw xlsx styles target" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let dxf = stamp_target(
    xep("s", ns_s, "dxf", [], [
      Element(
        xep("s", ns_s, "font", [], [
          Element(xep("s", ns_s, "color", [xa("rgb", "FFFF0000")], [])),
        ]),
      ),
    ]),
  )
  let styles = xep("s", ns_s, "styleSheet", [], [
    Element(xep("s", ns_s, "dxfs", [xa("count", "1")], [Element(dxf)])),
  ])
  assert_eq(
    roundtrip_fidelity("xlsx:styles", styles, "CAT-SML-DXF"),
    "fy-inject",
  )
}

///|
test "catalog xlsx styles host applies nested fgColor to visible cell" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let fg_color = stamp_target(
    xep("s", ns_s, "fgColor", [xa("rgb", "FFFF0000")], []),
  )
  let styles = xep("s", ns_s, "styleSheet", [], [
    Element(
      xep("s", ns_s, "fills", [xa("count", "1")], [
        Element(
          xep("s", ns_s, "fill", [], [
            Element(
              xep("s", ns_s, "patternFill", [xa("patternType", "solid")], [
                Element(fg_color),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  assert_eq(verify_entry("xlsx:styles", styles, "CAT-SML-FG"), "rendered")
  let svg = catalog_sml_render_styles_svg(strip_target_attr(styles))
  assert_true(svg.contains("#FF0000"))
}

///|
test "catalog xlsx styles host applies nested bgColor to visible pattern" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let bg_color = stamp_target(
    xep("s", ns_s, "bgColor", [xa("rgb", "FFFFFF00")], []),
  )
  let styles = xep("s", ns_s, "styleSheet", [], [
    Element(
      xep("s", ns_s, "fills", [xa("count", "1")], [
        Element(
          xep("s", ns_s, "fill", [], [
            Element(
              xep("s", ns_s, "patternFill", [xa("patternType", "darkGrid")], [
                Element(xep("s", ns_s, "fgColor", [xa("rgb", "FFFF0000")], [])),
                Element(bg_color),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  assert_eq(verify_entry("xlsx:styles", styles, "CAT-SML-BG"), "rendered")
  let svg = catalog_sml_render_styles_svg(strip_target_attr(styles))
  assert_true(svg.contains("data-ooxml-pattern-bg=\"#FFFF00\""))
}

///|
test "catalog xlsx styles host routes numFmt through cell style index" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let num_fmt = stamp_target(
    xep(
      "s",
      ns_s,
      "numFmt",
      [xa("numFmtId", "164"), xa("formatCode", "0.00")],
      [],
    ),
  )
  assert_eq(verify_entry("xlsx:styles", num_fmt, "CAT-SML-NUMFMT"), "rendered")
  let svg = catalog_sml_render_styles_svg(strip_target_attr(num_fmt))
  assert_true(svg.contains("1234.50"))
}

///|
test "catalog xlsx styles host routes font color through cell style index" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let color = stamp_target(xep("s", ns_s, "color", [xa("rgb", "FFFF0000")], []))
  assert_eq(verify_entry("xlsx:styles", color, "CAT-SML-FONT"), "rendered")
  let svg = catalog_sml_render_styles_svg(strip_target_attr(color))
  assert_true(svg.contains("#FF0000"))
}

///|
test "catalog xlsx styles host routes font toggles through cell style index" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let bold = stamp_target(xep("s", ns_s, "b", [xa("val", "1")], []))
  assert_eq(verify_entry("xlsx:styles", bold, "CAT-SML-BOLD"), "rendered")
  let bold_svg = catalog_sml_render_styles_svg(strip_target_attr(bold))
  assert_true(bold_svg.contains("font-weight=\"bold\""))
  let italic = stamp_target(xep("s", ns_s, "i", [xa("val", "1")], []))
  assert_eq(verify_entry("xlsx:styles", italic, "CAT-SML-ITALIC"), "rendered")
  let italic_svg = catalog_sml_render_styles_svg(strip_target_attr(italic))
  assert_true(italic_svg.contains("font-style=\"italic\""))
  let underline = stamp_target(xep("s", ns_s, "u", [xa("val", "single")], []))
  assert_eq(
    verify_entry("xlsx:styles", underline, "CAT-SML-UNDERLINE"),
    "rendered",
  )
  let underline_svg = catalog_sml_render_styles_svg(
    strip_target_attr(underline),
  )
  assert_true(underline_svg.contains("text-decoration=\"underline\""))
  let strike = stamp_target(xep("s", ns_s, "strike", [xa("val", "1")], []))
  assert_eq(verify_entry("xlsx:styles", strike, "CAT-SML-STRIKE"), "rendered")
  let strike_svg = catalog_sml_render_styles_svg(strip_target_attr(strike))
  assert_true(strike_svg.contains("text-decoration=\"line-through\""))
}

///|
test "catalog xlsx styles host routes font legacy effects through cell style index" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let outline = stamp_target(xep("s", ns_s, "outline", [xa("val", "1")], []))
  assert_eq(verify_entry("xlsx:styles", outline, "CAT-SML-OUTLINE"), "rendered")
  let outline_svg = catalog_sml_render_styles_svg(strip_target_attr(outline))
  assert_true(outline_svg.contains("stroke-width=\"0.35pt\""))
  let shadow = stamp_target(xep("s", ns_s, "shadow", [xa("val", "1")], []))
  assert_eq(verify_entry("xlsx:styles", shadow, "CAT-SML-SHADOW"), "rendered")
  let shadow_svg = catalog_sml_render_styles_svg(strip_target_attr(shadow))
  assert_true(shadow_svg.contains("drop-shadow"))
  let condense = stamp_target(xep("s", ns_s, "condense", [xa("val", "1")], []))
  assert_eq(
    verify_entry("xlsx:styles", condense, "CAT-SML-CONDENSE"),
    "rendered",
  )
  let condense_svg = catalog_sml_render_styles_svg(strip_target_attr(condense))
  assert_true(condense_svg.contains("font-stretch=\"condensed\""))
  let extend = stamp_target(xep("s", ns_s, "extend", [xa("val", "1")], []))
  assert_eq(verify_entry("xlsx:styles", extend, "CAT-SML-EXTEND"), "rendered")
  let extend_svg = catalog_sml_render_styles_svg(strip_target_attr(extend))
  assert_true(extend_svg.contains("font-stretch=\"expanded\""))
}

///|
test "catalog xlsx styles host routes font size through cell style index" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let size = stamp_target(xep("s", ns_s, "sz", [xa("val", "18")], []))
  assert_eq(verify_entry("xlsx:styles", size, "CAT-SML-SIZE"), "rendered")
  let svg = catalog_sml_render_styles_svg(strip_target_attr(size))
  assert_true(svg.contains("font-size=\"18pt\""))
}

///|
test "catalog xlsx styles host routes font vertAlign through cell style index" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let vert_align = stamp_target(
    xep("s", ns_s, "vertAlign", [xa("val", "baseline")], []),
  )
  assert_eq(
    verify_entry("xlsx:styles", vert_align, "CAT-SML-VERTALIGN"),
    "rendered",
  )
  let svg = catalog_sml_render_styles_svg(vert_align)
  assert_true(svg.contains("baseline-shift=\"super\""))
}

///|
test "catalog xlsx styles host routes font scheme through workbook theme" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let scheme = stamp_target(xep("s", ns_s, "scheme", [xa("val", "minor")], []))
  assert_eq(verify_entry("xlsx:styles", scheme, "CAT-SML-SCHEME"), "rendered")
  let svg = catalog_sml_render_styles_svg(scheme)
  assert_true(svg.contains("Calibri Light"))
}

///|
test "catalog xlsx styles host routes font family classification" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let family = stamp_target(xep("s", ns_s, "family", [xa("val", "3")], []))
  assert_eq(verify_entry("xlsx:styles", family, "CAT-SML-FAMILY"), "rendered")
  let svg = catalog_sml_render_styles_svg(family)
  assert_true(svg.contains("font-family=\"&apos;monospace&apos;, sans-serif\""))
}

///|
test "catalog xlsx styles host routes font charset language hint" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let charset = stamp_target(xep("s", ns_s, "charset", [xa("val", "128")], []))
  assert_eq(verify_entry("xlsx:styles", charset, "CAT-SML-CHARSET"), "rendered")
  let svg = catalog_sml_render_styles_svg(charset)
  assert_true(svg.contains("xml:lang=\"ja\""))
}

///|
test "catalog xlsx styles host routes target font root before child name" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let font = stamp_target(
    xep("s", ns_s, "font", [], [
      Element(xep("s", ns_s, "name", [xa("val", "x")], [])),
    ]),
  )
  assert_eq(verify_entry("xlsx:styles", font, "CAT-SML-FONT-ROOT"), "rendered")
  let svg = catalog_sml_render_styles_svg(font)
  assert_true(svg.contains("#0000FF"))
}

///|
test "catalog xlsx styles host routes target fonts root before child name" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let fonts = stamp_target(
    xep("s", ns_s, "fonts", [xa("count", "1")], [
      Element(
        xep("s", ns_s, "font", [], [
          Element(xep("s", ns_s, "name", [xa("val", "x")], [])),
        ]),
      ),
    ]),
  )
  assert_eq(
    verify_entry("xlsx:styles", fonts, "CAT-SML-FONTS-ROOT"),
    "rendered",
  )
  let svg = catalog_sml_render_styles_svg(fonts)
  assert_true(svg.contains("#0000FF"))
}

///|
test "catalog xlsx styles host routes named cell style through Normal style" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let cell_style = stamp_target(
    xep(
      "s",
      ns_s,
      "cellStyle",
      [xa("name", "Input"), xa("xfId", "7"), xa("builtinId", "20")],
      [],
    ),
  )
  assert_eq(
    verify_entry("xlsx:styles", cell_style, "CAT-SML-CELLSTYLE"),
    "rendered",
  )
  let cell_style_svg = catalog_sml_render_styles_svg(cell_style)
  assert_true(cell_style_svg.contains("font-size=\"18pt\""))
  assert_true(cell_style_svg.contains("#FF0000"))
  let cell_styles = stamp_target(
    xep("s", ns_s, "cellStyles", [xa("count", "1")], [
      Element(
        xep(
          "s",
          ns_s,
          "cellStyle",
          [xa("name", "Input"), xa("xfId", "7"), xa("builtinId", "20")],
          [],
        ),
      ),
    ]),
  )
  assert_eq(
    verify_entry("xlsx:styles", cell_styles, "CAT-SML-CELLSTYLES"),
    "rendered",
  )
  let cell_styles_svg = catalog_sml_render_styles_svg(cell_styles)
  assert_true(cell_styles_svg.contains("font-size=\"18pt\""))
  assert_true(cell_styles_svg.contains("#FF0000"))
}

///|
test "catalog xlsx styles host routes table styles through table chrome" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let table_style_element = stamp_target(
    xep(
      "s",
      ns_s,
      "tableStyleElement",
      [xa("type", "totalRow"), xa("dxfId", "7")],
      [],
    ),
  )
  assert_eq(
    verify_entry(
      "xlsx:styles", table_style_element, "CAT-SML-TABLESTYLE-ELEMENT",
    ),
    "rendered",
  )
  let table_style = stamp_target(
    xep(
      "s",
      ns_s,
      "tableStyle",
      [xa("name", "Original"), xa("pivot", "1"), xa("table", "0")],
      [
        Element(
          xep(
            "s",
            ns_s,
            "tableStyleElement",
            [xa("type", "totalRow"), xa("dxfId", "7")],
            [],
          ),
        ),
      ],
    ),
  )
  assert_eq(
    verify_entry("xlsx:styles", table_style, "CAT-SML-TABLESTYLE"),
    "rendered",
  )
  let table_styles = stamp_target(
    xep("s", ns_s, "tableStyles", [xa("count", "1")], [
      Element(
        xep(
          "s",
          ns_s,
          "tableStyle",
          [xa("name", "Original"), xa("pivot", "1"), xa("table", "0")],
          [
            Element(
              xep(
                "s",
                ns_s,
                "tableStyleElement",
                [xa("type", "totalRow"), xa("dxfId", "7")],
                [],
              ),
            ),
          ],
        ),
      ),
    ]),
  )
  assert_eq(
    verify_entry("xlsx:styles", table_styles, "CAT-SML-TABLESTYLES"),
    "rendered",
  )
  let svg = match
    render_svg_of(
      "xlsx:styles",
      host_package_for_render("xlsx:styles", table_style_element),
    ) {
    Some(s) => s
    None => abort("expected xlsx:styles table-style scaffold to render")
  }
  assert_true(svg.contains("class=\"table-chrome\""))
  assert_true(svg.contains("data-ooxml-table-band=\"header\""))
  assert_true(svg.contains("#123456"))
}

///|
test "catalog xlsx styles host routes indexedColors through indexed fill" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let rgb_color = stamp_target(
    xep("s", ns_s, "rgbColor", [xa("rgb", "FF000000")], []),
  )
  assert_eq(
    verify_entry("xlsx:styles", rgb_color, "CAT-SML-RGBCOLOR"),
    "rendered",
  )
  let rgb_svg = catalog_sml_render_styles_svg(rgb_color)
  assert_true(rgb_svg.contains("#123456"))
  let indexed_colors = stamp_target(
    xep("s", ns_s, "indexedColors", [], [
      Element(xep("s", ns_s, "rgbColor", [xa("rgb", "FF000000")], [])),
    ]),
  )
  assert_eq(
    verify_entry("xlsx:styles", indexed_colors, "CAT-SML-INDEXEDCOLORS"),
    "rendered",
  )
  let indexed_svg = catalog_sml_render_styles_svg(indexed_colors)
  assert_true(indexed_svg.contains("#123456"))
}

///|
test "catalog xlsx styles host routes ancestry-wrapped font child" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let styles = xep("s", ns_s, "fonts", [], [
    Element(
      xep("s", ns_s, "font", [], [
        Element(stamp_target(xep("s", ns_s, "b", [xa("val", "1")], []))),
      ]),
    ),
  ])
  assert_eq(
    verify_entry("xlsx:styles", styles, "CAT-SML-BOLD-WRAPPED"),
    "rendered",
  )
}

///|
test "catalog xlsx styles host routes synthesized font child attrs" {
  let ns_s = "http://purl.oclc.org/ooxml/spreadsheetml/main"
  let styles = xep("s", ns_s, "fonts", [], [
    Element(
      xep("s", ns_s, "font", [], [
        Element(
          stamp_target(
            xep(
              "s",
              ns_s,
              "b",
              [
                {
                  name: { prefix: Some("s"), local_name: "val", ns: Some(ns_s) },
                  value: "true",
                },
              ],
              [],
            ),
          ),
        ),
      ]),
    ),
  ])
  assert_eq(
    verify_entry("xlsx:styles", styles, "CAT-SML-BOLD-SYNTH"),
    "rendered",
  )
}

///|
test "catalog xlsx styles host prefers target font child over siblings" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let styles = xep("s", ns_s, "fonts", [], [
    Element(
      xep("s", ns_s, "font", [], [
        Element(xep("s", ns_s, "name", [xa("val", "sans-serif")], [])),
        Element(xep("s", ns_s, "sz", [xa("val", "11")], [])),
        Element(stamp_target(xep("s", ns_s, "b", [xa("val", "1")], []))),
      ]),
    ),
  ])
  assert_eq(
    verify_entry("xlsx:styles", styles, "CAT-SML-BOLD-SIBLINGS"),
    "rendered",
  )
}

///|
test "catalog xlsx styles host routes target border edge before nested color" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let edge = stamp_target(
    xep("s", ns_s, "start", [xa("style", "none")], [
      Element(xep("s", ns_s, "color", [], [])),
    ]),
  )
  assert_eq(
    verify_entry("xlsx:styles", edge, "CAT-SML-BORDER-EDGE"),
    "rendered",
  )
  let svg = catalog_sml_render_styles_svg(edge)
  assert_true(svg.contains("<line "))
  assert_true(svg.contains("stroke=\"#000000\""))
}

///|
test "catalog xlsx styles host routes target border root before nested color" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let border = stamp_target(
    xep("s", ns_s, "border", [], [
      Element(
        xep("s", ns_s, "top", [xa("style", "none")], [
          Element(xep("s", ns_s, "color", [], [])),
        ]),
      ),
    ]),
  )
  assert_eq(
    verify_entry("xlsx:styles", border, "CAT-SML-BORDER-ROOT"),
    "rendered",
  )
  let svg = catalog_sml_render_styles_svg(border)
  assert_true(svg.contains("<line "))
  assert_true(svg.contains("stroke=\"#000000\""))
}

///|
test "catalog xlsx styles host routes cell protection sidecar" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let protection = stamp_target(
    xep("s", ns_s, "protection", [xa("locked", "0"), xa("hidden", "1")], []),
  )
  assert_eq(
    verify_entry("xlsx:styles", protection, "CAT-SML-PROTECTION"),
    "rendered",
  )
  let svg = catalog_sml_render_styles_svg(protection)
  assert_true(svg.contains("class=\"cell-protection\""))
  assert_true(svg.contains("data-ooxml-cell-protection-hidden=\"1\""))
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
  install_catalog_font_fixture()
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
fn catalog_master_txstyle_probe(style_name : String) -> @xml.Element {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  xep("p", ns_p, style_name, [], [
    Element(
      xep("a", ns_a, "lvl1pPr", [], [
        Element(
          xep("a", ns_a, "defRPr", [xa("sz", "2800")], [
            Element(
              xep("a", ns_a, "solidFill", [], [
                Element(xep("a", ns_a, "srgbClr", [xa("val", "C00000")], [])),
              ]),
            ),
            Element(
              xep("a", ns_a, "latin", [xa("typeface", "CatalogMasterFace")], []),
            ),
          ]),
        ),
      ]),
    ),
  ])
}

///|
test "catalog pptx master txstyle host renders placeholder inherited style" {
  assert_true(
    is_pml_master_tx_style_catalog_target(
      "titleStyle", "http://schemas.openxmlformats.org/presentationml/2006/main#CT_TextListStyle",
      "http://schemas.openxmlformats.org/presentationml/2006/main",
    ),
  )
  assert_true(
    is_pml_master_tx_style_catalog_target(
      "bodyStyle", "http://schemas.openxmlformats.org/presentationml/2006/main#CT_TextListStyle",
      "http://schemas.openxmlformats.org/presentationml/2006/main",
    ),
  )
  assert_true(
    is_pml_master_tx_style_catalog_target(
      "otherStyle", "http://schemas.openxmlformats.org/presentationml/2006/main#CT_TextListStyle",
      "http://schemas.openxmlformats.org/presentationml/2006/main",
    ),
  )
  assert_true(
    !is_pml_master_tx_style_catalog_target(
      "notesStyle", "http://schemas.openxmlformats.org/presentationml/2006/main#CT_TextListStyle",
      "http://schemas.openxmlformats.org/presentationml/2006/main",
    ),
  )
  let tx_styles = catalog_master_tx_styles_root(
    stamp_target(catalog_master_txstyle_probe("bodyStyle")),
  )
  assert_eq(
    verify_entry("pptx:master-txstyle", tx_styles, "CAT-PML-MASTER-TX"),
    "rendered",
  )
  let presentation = @pml_context.open(
    host_package("pptx:master-txstyle", strip_target_attr(tx_styles)),
  ) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let svg = presentation.to_svg(debug_attrs=true)
  assert_true(svg.contains("Catalog master text"))
  assert_true(svg.contains("CatalogMasterFace"))
  assert_true(svg.contains("font-size=\"37.333333"))
}

///|
fn catalog_master_txstyle_lvl2_probe() -> @xml.Element {
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  xep("a", ns_a, "lvl2pPr", [], [
    Element(
      xep("a", ns_a, "defRPr", [xa("sz", "2800")], [
        Element(
          xep("a", ns_a, "solidFill", [], [
            Element(xep("a", ns_a, "srgbClr", [xa("val", "C00000")], [])),
          ]),
        ),
        Element(
          xep("a", ns_a, "latin", [xa("typeface", "CatalogMasterFace")], []),
        ),
      ]),
    ),
  ])
}

///|
test "catalog pptx master txstyle host renders paragraph-level defaults" {
  assert_true(
    is_pml_master_tx_paragraph_style_catalog_target(
      "lvl2pPr", "http://schemas.openxmlformats.org/drawingml/2006/main#CT_TextParagraphProperties",
      "http://schemas.openxmlformats.org/drawingml/2006/main",
    ),
  )
  assert_true(
    is_pml_master_tx_paragraph_style_catalog_target(
      "defPPr", "http://purl.oclc.org/ooxml/drawingml/main#CT_TextParagraphProperties",
      "http://purl.oclc.org/ooxml/drawingml/main",
    ),
  )
  assert_true(
    !is_pml_master_tx_paragraph_style_catalog_target(
      "rPr", "http://schemas.openxmlformats.org/drawingml/2006/main#CT_TextCharacterProperties",
      "http://schemas.openxmlformats.org/drawingml/2006/main",
    ),
  )
  let tx_styles = catalog_master_tx_paragraph_style_root(
    stamp_target(catalog_master_txstyle_lvl2_probe()),
  )
  assert_eq(
    verify_entry("pptx:master-txstyle", tx_styles, "CAT-PML-MASTER-LVL2"),
    "rendered",
  )
  let presentation = @pml_context.open(
    host_package("pptx:master-txstyle", strip_target_attr(tx_styles)),
  ) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let svg = presentation.to_svg(debug_attrs=true)
  assert_true(svg.contains("Catalog master text"))
  assert_true(svg.contains("CatalogMasterFace"))
  assert_true(svg.contains("font-size=\"37.333333"))
}

///|
test "catalog pptx placeholder host renders ph through slide layout chain" {
  assert_true(
    is_pml_placeholder_catalog_target(
      "ph", "http://schemas.openxmlformats.org/presentationml/2006/main#CT_Placeholder",
      "http://schemas.openxmlformats.org/presentationml/2006/main",
    ),
  )
  let ph = stamp_target(
    xep("p", NS_PML, "ph", [xa("type", "title"), xa("idx", "0")], []),
  )
  let root = catalog_pml_placeholder_chain_root(ph)
  let presentation = @pml_context.open(
    host_package("pptx:placeholder-chain", strip_target_attr(root)),
  ) catch {
    @pml_context.OpenError(kind~, path~, reason~) =>
      abort("initial open failed: " + kind + " " + path + " " + reason)
  }
  let svg = presentation.to_svg(debug_attrs=true)
  assert_true(svg.contains("Catalog placeholder text"))
  assert_eq(
    verify_entry("pptx:placeholder-chain", root, "CAT-PML-PH"),
    "rendered",
  )
}

///|
test "catalog pptx picture blip host resolves embedded image" {
  assert_true(
    is_pml_picture_blip_catalog_target(
      "pic", "http://schemas.openxmlformats.org/presentationml/2006/main#CT_Picture",
      "http://schemas.openxmlformats.org/presentationml/2006/main",
    ),
  )
  assert_true(
    is_pml_picture_blip_catalog_target(
      "blip", "http://schemas.openxmlformats.org/drawingml/2006/main#CT_Blip", "http://schemas.openxmlformats.org/drawingml/2006/main",
    ),
  )
  let pic = stamp_target(xep("p", NS_PML, "pic", [], []))
  let root = catalog_pml_picture_blip_root(pic)
  assert_eq(verify_entry("pptx:picture-blip", root, "CAT-PML-PIC"), "rendered")
  let svg = match
    render_svg_of(
      "pptx:picture-blip",
      host_package("pptx:picture-blip", strip_target_attr(root)),
    ) {
    Some(s) => s
    None => abort("expected picture blip host to render")
  }
  assert_true(svg.contains("data:image/png;base64,"))
  assert_true(svg.contains("data-r-embed=\"rId2\""))
}

///|
test "catalog docx picture blip host resolves embedded image" {
  install_catalog_font_fixture()
  let ns_pic = "http://schemas.openxmlformats.org/drawingml/2006/picture"
  let ns_wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  assert_true(
    is_wml_picture_blip_catalog_target("pic", ns_pic + "#CT_Picture", ns_pic),
  )
  assert_true(
    is_wml_picture_blip_catalog_target("inline", ns_wp + "#CT_Inline", ns_wp),
  )
  assert_true(
    is_wml_picture_blip_catalog_target("anchor", ns_wp + "#CT_Anchor", ns_wp),
  )
  assert_false(
    is_wml_picture_blip_catalog_target(
      "grayscl", "http://schemas.openxmlformats.org/drawingml/2006/main#CT_GrayscaleEffect",
      "http://schemas.openxmlformats.org/drawingml/2006/main",
    ),
  )
  let pic = stamp_target(xep("pic", ns_pic, "pic", [], []))
  let root = catalog_wml_picture_blip_root(pic)
  assert_eq(verify_entry("docx:picture-blip", root, "CAT-WML-PIC"), "rendered")
  let svg = match
    render_svg_of(
      "docx:picture-blip",
      host_package("docx:picture-blip", strip_target_attr(root)),
    ) {
    Some(s) => s
    None => abort("expected WML picture blip host to render")
  }
  assert_true(svg.contains("data:image/png;base64,"))
  assert_true(svg.contains("<image "))
  let inline = stamp_target(xep("wp", ns_wp, "inline", [], []))
  let inline_root = catalog_wml_picture_blip_root(inline)
  assert_eq(
    verify_entry("docx:picture-blip", inline_root, "CAT-WML-INLINE"),
    "rendered",
  )
}

///|
test "catalog pptx picture blip host renders blip effects" {
  assert_true(
    is_pml_picture_blip_catalog_target(
      "grayscl", "http://schemas.openxmlformats.org/drawingml/2006/main#CT_GrayscaleEffect",
      "http://schemas.openxmlformats.org/drawingml/2006/main",
    ),
  )
  assert_true(
    is_pml_picture_blip_catalog_target(
      "tint", "http://schemas.openxmlformats.org/drawingml/2006/main#CT_TintEffect",
      "http://schemas.openxmlformats.org/drawingml/2006/main",
    ),
  )
  assert_false(
    is_pml_picture_blip_catalog_target(
      "tint", "http://schemas.openxmlformats.org/drawingml/2006/main#CT_PositiveFixedPercentage",
      "http://schemas.openxmlformats.org/drawingml/2006/main",
    ),
  )
  let grayscl = stamp_target(xep("a", NS_A, "grayscl", [], []))
  let root = catalog_pml_picture_blip_root(grayscl)
  assert_eq(
    verify_entry("pptx:picture-blip", root, "CAT-PML-BLIP-FX"),
    "rendered",
  )
  let svg = match
    render_svg_of(
      "pptx:picture-blip",
      host_package("pptx:picture-blip", strip_target_attr(root)),
    ) {
    Some(s) => s
    None => abort("expected picture blip effect host to render")
  }
  assert_true(svg.contains("data-ooxml-blip-effects=\"grayscl\""))
  assert_true(svg.contains("<filter "))
}

///|
test "catalog synth emits non-degenerate xdr twoCellAnchor" {
  install_catalog_font_fixture()
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
test "catalog synth emits non-default chart tickMarkSkip" {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let schema = load_catalog_schema()
  let mut skip : @xml.Element? = None
  for _key, decl in schema.all_elements {
    if decl.name == "tickMarkSkip" && decl.ns == ns_c {
      match schema.complex_types.get(decl.type_name) {
        Some(ct) => {
          let st : StrSet = Map([], capacity=0)
          st[decl.type_name] = true
          skip = Some(
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
  let skip = match skip {
    Some(s) => s
    None => abort("expected chart tickMarkSkip declaration")
  }
  assert_eq(attr(skip, "val").unwrap_or(""), "2")
}

///|
test "catalog synth emits non-default chart date time units" {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let schema = load_catalog_schema()
  fn synth_decl(local_name : String) -> @xml.Element {
    for _key, decl in schema.all_elements {
      if decl.name == local_name && decl.ns == ns_c {
        match schema.complex_types.get(decl.type_name) {
          Some(ct) => {
            let st : StrSet = Map([], capacity=0)
            st[decl.type_name] = true
            return synth_element(
              schema,
              ct,
              decl.ns,
              decl.name,
              st,
              0,
              RICH_BUDGET,
              include_optional_attrs=true,
            )
          }
          None => ()
        }
      }
    }
    abort("expected chart " + local_name + " declaration")
  }
  assert_eq(attr(synth_decl("baseTimeUnit"), "val").unwrap_or(""), "months")
  assert_eq(attr(synth_decl("majorTimeUnit"), "val").unwrap_or(""), "years")
  assert_eq(attr(synth_decl("minorTimeUnit"), "val").unwrap_or(""), "days")
}

///|
test "catalog synth emits visible chart line carriers" {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let schema = load_catalog_schema()
  let mut ser_lines : @xml.Element? = None
  for _key, decl in schema.all_elements {
    if decl.name == "serLines" && decl.ns == ns_c {
      match schema.complex_types.get(decl.type_name) {
        Some(ct) => {
          let st : StrSet = Map([], capacity=0)
          st[decl.type_name] = true
          ser_lines = Some(
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
  let ser_lines = match ser_lines {
    Some(s) => s
    None => abort("expected chart serLines declaration")
  }
  let sp_pr = match first_child_named_in(ser_lines, "spPr") {
    Some(e) => e
    None => abort("expected serLines spPr")
  }
  let ln = match first_child_named_in(sp_pr, "ln") {
    Some(e) => e
    None => abort("expected serLines spPr ln")
  }
  assert_true(first_child_named_in(ln, "noFill") is None)
  assert_eq(attr(ln, "w").unwrap_or(""), "9525")
  match first_child_named_in(ln, "solidFill") {
    Some(sf) =>
      match first_child_named_in(sf, "srgbClr") {
        Some(c) => assert_eq(attr(c, "val").unwrap_or(""), "8090A0")
        None => abort("expected serLines line color")
      }
    None => abort("expected serLines solid line fill")
  }
}

///|
test "catalog chart render scaffold keeps non-target axes visible" {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let chart_space = xep("c", ns_c, "chartSpace", [], [
    Element(
      xep("c", ns_c, "chart", [], [
        Element(
          xep("c", ns_c, "plotArea", [], [
            Element(
              xep("c", ns_c, "catAx", [], [
                Element(xep("c", ns_c, "delete", [], [])),
                Element(
                  stamp_target(
                    xep("c", ns_c, "tickMarkSkip", [xa("val", "2")], []),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  let enhanced = enhance_chart_space_for_render(chart_space)
  let delete = match first_descendant_named_local(enhanced, "delete") {
    Some(e) => e
    None => abort("expected normalized axis delete")
  }
  assert_eq(catalog_attr_value_local(delete, "val").unwrap_or(""), "0")
}

///|
test "catalog chart render scaffold leaves target delete untouched" {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let chart_space = xep("c", ns_c, "chartSpace", [], [
    Element(
      xep("c", ns_c, "chart", [], [
        Element(
          xep("c", ns_c, "plotArea", [], [
            Element(
              xep("c", ns_c, "catAx", [], [
                Element(stamp_target(xep("c", ns_c, "delete", [], []))),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  let enhanced = enhance_chart_space_for_render(chart_space)
  let delete = match first_descendant_named_local(enhanced, "delete") {
    Some(e) => e
    None => abort("expected target axis delete")
  }
  assert_eq(catalog_attr_value_local(delete, "val").unwrap_or(""), "")
}

///|
test "catalog chart render scaffold gives date axes numeric categories" {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let chart_space = xep("c", ns_c, "chartSpace", [], [
    Element(
      xep("c", ns_c, "chart", [], [
        Element(
          xep("c", ns_c, "plotArea", [], [
            Element(
              xep("c", ns_c, "dateAx", [], [
                Element(
                  stamp_target(
                    xep("c", ns_c, "baseTimeUnit", [xa("val", "months")], []),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  let enhanced = enhance_chart_space_for_render(chart_space)
  let cat = match first_descendant_named_local(enhanced, "cat") {
    Some(e) => e
    None => abort("expected scaffold category data")
  }
  let num_ref = match first_descendant_named_local(cat, "numRef") {
    Some(e) => e
    None => abort("expected date category numRef")
  }
  let cache = match first_descendant_named_local(num_ref, "numCache") {
    Some(e) => e
    None => abort("expected date category numCache")
  }
  assert_true(catalog_xml_text_content(cache).contains("45292"))
  assert_true(catalog_xml_text_content(cache).contains("45323"))
}

///|
test "catalog chart bar option host renders invertIfNegative" {
  let target = stamp_target(
    xep("c", NS_C, "invertIfNegative", [xa("val", "1")], []),
  )
  let root = catalog_chart_bar_series_option_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-INVERT"), "rendered")
}

///|
test "catalog chart host renders varyColors point palette" {
  let target = stamp_target(xep("c", NS_C, "varyColors", [xa("val", "1")], []))
  let root = catalog_chart_vary_colors_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-VARY"), "rendered")
  match
    render_svg_of(
      "pptx:chart",
      host_package("pptx:chart", strip_target_attr(root)),
    ) {
    Some(svg) => {
      assert_true(svg.contains("fill=\"#4472c4\""))
      assert_true(svg.contains("fill=\"#ed7d31\""))
      assert_true(svg.contains("fill=\"#a5a5a5\""))
    }
    None => fail("expected chart SVG")
  }
}

///|
test "catalog chart axis position host renders axPos" {
  let target = stamp_target(xep("c", NS_C, "axPos", [xa("val", "l")], []))
  let root = catalog_chart_axis_position_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-AXPOS"), "rendered")
}

///|
test "catalog chart axis host renders axId" {
  let target = stamp_target(
    xep("c", NS_C, "axId", [xa("val", "222222222")], []),
  )
  let root = catalog_chart_axis_id_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-AXID"), "rendered")
}

///|
test "catalog chart axis host renders crossAx" {
  let target = stamp_target(
    xep("c", NS_C, "crossAx", [xa("val", "333333333")], []),
  )
  let root = catalog_chart_axis_cross_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-CROSSAX"), "rendered")
}

///|
test "catalog chart axis host renders auto" {
  let target = stamp_target(xep("c", NS_C, "auto", [xa("val", "1")], []))
  let root = catalog_chart_axis_auto_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-AUTO"), "rendered")
}

///|
test "catalog chart axis host renders noMultiLvlLbl" {
  let target = stamp_target(
    xep("c", NS_C, "noMultiLvlLbl", [xa("val", "1")], []),
  )
  let root = catalog_chart_no_multi_level_labels_root(target)
  assert_eq(
    verify_entry("pptx:chart", root, "CAT-CHART-NOMULTILVL"),
    "rendered",
  )
}

///|
test "catalog chart axis host renders majorGridlines" {
  let target = stamp_target(xep("c", NS_C, "majorGridlines", [], []))
  let root = catalog_chart_axis_gridlines_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-MAJORGRID"), "rendered")
}

///|
test "catalog chart axis host renders minorGridlines" {
  let target = stamp_target(xep("c", NS_C, "minorGridlines", [], []))
  let root = catalog_chart_axis_gridlines_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-MINORGRID"), "rendered")
}

///|
test "catalog chart axis host renders lblOffset" {
  let target = stamp_target(xep("c", NS_C, "lblOffset", [xa("val", "200")], []))
  let root = catalog_chart_axis_option_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-LBLOFFSET"), "rendered")
}

///|
test "catalog chart axis host renders majorUnit" {
  let target = stamp_target(xep("c", NS_C, "majorUnit", [xa("val", "20")], []))
  let root = catalog_chart_axis_option_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-MAJORUNIT"), "rendered")
}

///|
test "catalog chart axis host renders minorUnit" {
  let target = stamp_target(xep("c", NS_C, "minorUnit", [xa("val", "20")], []))
  let root = catalog_chart_axis_option_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-MINORUNIT"), "rendered")
}

///|
test "catalog chart date axis host renders baseTimeUnit" {
  let target = stamp_target(
    xep("c", NS_C, "baseTimeUnit", [xa("val", "months")], []),
  )
  let root = catalog_chart_date_axis_unit_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-BASETIME"), "rendered")
}

///|
test "catalog chart date axis host renders majorTimeUnit" {
  let target = stamp_target(
    xep("c", NS_C, "majorTimeUnit", [xa("val", "years")], []),
  )
  let root = catalog_chart_date_axis_unit_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-MAJORTIME"), "rendered")
}

///|
test "catalog chart date axis host renders minorTimeUnit" {
  let target = stamp_target(
    xep("c", NS_C, "minorTimeUnit", [xa("val", "days")], []),
  )
  let root = catalog_chart_date_axis_unit_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-MINORTIME"), "rendered")
}

///|
test "catalog chart date system host renders date1904" {
  let target = stamp_target(xep("c", NS_C, "date1904", [xa("val", "1")], []))
  let root = catalog_chart_date_axis_unit_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-DATE1904"), "rendered")
}

///|
test "catalog chart title host renders autoTitleDeleted" {
  let target = stamp_target(
    xep("c", NS_C, "autoTitleDeleted", [xa("val", "1")], []),
  )
  let root = catalog_chart_auto_title_deleted_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-AUTOTITLE"), "rendered")
}

///|
test "catalog chart labels host renders showDLblsOverMax" {
  let target = stamp_target(
    xep("c", NS_C, "showDLblsOverMax", [xa("val", "1")], []),
  )
  let root = catalog_chart_show_data_labels_over_max_root(target)
  assert_eq(
    verify_entry("pptx:chart", root, "CAT-CHART-SHOWDLBLSOVERMAX"),
    "rendered",
  )
}

///|
test "catalog chart data source host renders strCache" {
  let target = stamp_target(xep("c", NS_C, "strCache", [], []))
  let root = catalog_chart_data_source_root(target, "CT_StrData")
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-STRCACHE"), "rendered")
}

///|
test "catalog chart data source host renders rich text" {
  let target = stamp_target(xep("c", NS_C, "rich", [], []))
  let root = catalog_chart_data_source_root(target, "CT_TextBody")
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-RICH"), "rendered")
}

///|
test "catalog chart text properties host renders txPr" {
  let target = stamp_target(xep("c", NS_C, "txPr", [], []))
  let root = catalog_chart_tx_pr_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-TXPR"), "rendered")
}

///|
test "catalog chart color map host renders clrMapOvr" {
  let target = stamp_target(
    xep(
      "c",
      NS_C,
      "clrMapOvr",
      [
        xa("bg1", "lt1"),
        xa("tx1", "dk1"),
        xa("bg2", "lt2"),
        xa("tx2", "dk2"),
        xa("accent1", "accent2"),
        xa("accent2", "accent2"),
        xa("accent3", "accent3"),
        xa("accent4", "accent4"),
        xa("accent5", "accent5"),
        xa("accent6", "accent6"),
        xa("hlink", "hlink"),
        xa("folHlink", "folHlink"),
      ],
      [],
    ),
  )
  let root = catalog_chart_color_map_override_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-CLRMAPOVR"), "rendered")
}

///|
test "catalog chart surface host renders wireframe" {
  let target = stamp_target(xep("c", NS_C, "wireframe", [xa("val", "1")], []))
  let root = catalog_chart_surface_wireframe_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-WIREFRAME"), "rendered")
}

///|
test "catalog chart surface host renders bandFmt" {
  let target = stamp_target(xep("c", NS_C, "bandFmt", [], []))
  let root = catalog_chart_surface_band_format_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-BANDFMT"), "rendered")
}

///|
test "catalog chart surface host renders bandFmts" {
  let target = stamp_target(xep("c", NS_C, "bandFmts", [], []))
  let root = catalog_chart_surface_band_format_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-BANDFMTS"), "rendered")
}

///|
test "catalog chart bar3D host renders gapDepth" {
  let target = stamp_target(xep("c", NS_C, "gapDepth", [xa("val", "400%")], []))
  let root = catalog_chart_bar3d_gap_depth_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-GAPDEPTH"), "rendered")
}

///|
test "catalog chart bar host renders series order" {
  let target = stamp_target(xep("c", NS_C, "order", [xa("val", "1")], []))
  let root = catalog_chart_bar_series_order_root(target)
  assert_eq(verify_entry("pptx:chart", root, "CAT-CHART-ORDER"), "rendered")
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
test "catalog xlsx autofilter sortState receives render-visible sort glyph" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let sort_state = stamp_target(
    xep("s", ns_s, "sortState", [], [
      Element(xep("s", ns_s, "sortCondition", [], [])),
    ]),
  )
  let worksheet = xep("s", ns_s, "worksheet", [], [
    Element(xep("s", ns_s, "autoFilter", [], [Element(sort_state)])),
  ])
  assert_eq(verify_entry("xlsx", worksheet, "CAT-AF-SORTSTATE"), "rendered")
}

///|
test "catalog xlsx autofilter sortCondition receives render-visible sort glyph" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let sort_condition = stamp_target(xep("s", ns_s, "sortCondition", [], []))
  let worksheet = xep("s", ns_s, "worksheet", [], [
    Element(
      xep("s", ns_s, "autoFilter", [], [
        Element(xep("s", ns_s, "sortState", [], [Element(sort_condition)])),
      ]),
    ),
  ])
  assert_eq(verify_entry("xlsx", worksheet, "CAT-AF-SORTCONDITION"), "rendered")
}

///|
test "catalog xlsx headerFooter root receives render-visible text" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let header_footer = stamp_target(xep("s", ns_s, "headerFooter", [], []))
  assert_eq(verify_entry("xlsx", header_footer, "CAT-SML-HF"), "rendered")
}

///|
test "catalog xlsx headerFooter text leaf receives render-visible text" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let odd_header = stamp_target(xep("s", ns_s, "oddHeader", [], []))
  let worksheet = xep("s", ns_s, "worksheet", [], [
    Element(xep("s", ns_s, "headerFooter", [], [Element(odd_header)])),
  ])
  assert_eq(verify_entry("xlsx", worksheet, "CAT-SML-ODDHEADER"), "rendered")
}

///|
test "catalog xlsx worksheet layout primitives route to renderer" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let cases : Array[(String, @xml.Element)] = [
    ("DIM", xep("s", ns_s, "dimension", [], [])),
    ("SHEETFORMAT", xep("s", ns_s, "sheetFormatPr", [], [])),
    ("COLS", xep("s", ns_s, "cols", [], [])),
    ("COL", xep("s", ns_s, "col", [], [])),
    ("SHEETDATA", xep("s", ns_s, "sheetData", [], [])),
    ("ROW", xep("s", ns_s, "row", [], [])),
    ("CELL", xep("s", ns_s, "c", [], [])),
    ("MERGECELLS", xep("s", ns_s, "mergeCells", [], [])),
    ("MERGECELL", xep("s", ns_s, "mergeCell", [], [])),
    ("CONDITIONALFORMATTING", xep("s", ns_s, "conditionalFormatting", [], [])),
    ("CFRULE", xep("s", ns_s, "cfRule", [], [])),
    ("COLORSCALE", xep("s", ns_s, "colorScale", [], [])),
    ("DATABAR", xep("s", ns_s, "dataBar", [], [])),
    ("ICONSET", xep("s", ns_s, "iconSet", [], [])),
    ("CFVO", xep("s", ns_s, "cfvo", [], [])),
    ("COLOR", xep("s", ns_s, "color", [], [])),
  ]
  for case in cases {
    let (id, target) = case
    let root = catalog_sml_worksheet_render_root(stamp_target(target))
    assert_eq(verify_entry("xlsx", root, "CAT-SML-" + id), "rendered")
  }
}

///|
test "catalog xlsx page break container receives render-visible break" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let row_breaks = stamp_target(xep("s", ns_s, "rowBreaks", [], []))
  assert_eq(verify_entry("xlsx", row_breaks, "CAT-SML-ROWBREAKS"), "rendered")
}

///|
test "catalog xlsx page break leaf receives render-visible break attrs" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let brk = stamp_target(xep("s", ns_s, "brk", [], []))
  let worksheet = xep("s", ns_s, "worksheet", [], [
    Element(xep("s", ns_s, "rowBreaks", [], [Element(brk)])),
  ])
  assert_eq(verify_entry("xlsx", worksheet, "CAT-SML-BRK"), "rendered")
}

///|
test "catalog xlsx printOptions receives render-visible print flags" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let print_options = stamp_target(xep("s", ns_s, "printOptions", [], []))
  assert_eq(
    verify_entry("xlsx", print_options, "CAT-SML-PRINTOPTIONS"),
    "rendered",
  )
}

///|
test "catalog xlsx pageMargins receives render-visible page offsets" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let page_margins = stamp_target(xep("s", ns_s, "pageMargins", [], []))
  assert_eq(
    verify_entry("xlsx", page_margins, "CAT-SML-PAGEMARGINS"),
    "rendered",
  )
}

///|
test "catalog xlsx pageSetup receives render-visible page frame" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let page_setup = stamp_target(xep("s", ns_s, "pageSetup", [], []))
  assert_eq(verify_entry("xlsx", page_setup, "CAT-SML-PAGESETUP"), "rendered")
}

///|
test "catalog xlsx drawing receives worksheet drawing relationship" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let drawing = stamp_target(xep("s", ns_s, "drawing", [], []))
  assert_eq(verify_entry("xlsx", drawing, "CAT-SML-DRAWING"), "rendered")
  let svg = render_svg_of("xlsx", host_package_for_render("xlsx", drawing)).unwrap_or(
    "",
  )
  assert_true(svg.contains("<g class=\"drawings\">"))
  assert_true(svg.contains("<g class=\"drawing\""))
  assert_true(svg.contains("data-ooxml-twocell-anchor=\"1\""))
}

///|
test "catalog xlsx hyperlinks receive worksheet hyperlink relationship" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let hyperlinks = stamp_target(xep("s", ns_s, "hyperlinks", [], []))
  assert_eq(verify_entry("xlsx", hyperlinks, "CAT-SML-HYPERLINKS"), "rendered")
  let svg = render_svg_of("xlsx", host_package_for_render("xlsx", hyperlinks)).unwrap_or(
    "",
  )
  assert_true(svg.contains("<a "))
  assert_true(svg.contains("href=\"https://example.com/catalog\""))
  assert_true(svg.contains("data-ooxml-hyperlink-ref=\"A1\""))
}

///|
test "catalog xlsx dataValidations receive list dropdown chrome" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let data_validations = stamp_target(xep("s", ns_s, "dataValidations", [], []))
  assert_eq(
    verify_entry("xlsx", data_validations, "CAT-SML-DATAVALIDATIONS"),
    "rendered",
  )
  let svg = render_svg_of(
    "xlsx",
    host_package_for_render("xlsx", data_validations),
  ).unwrap_or("")
  assert_true(svg.contains("class=\"data-validation-dropdowns\""))
}

///|
test "catalog xlsx picture receives worksheet-scoped background image rel" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let picture = stamp_target(xep("s", ns_s, "picture", [], []))
  assert_eq(verify_entry("xlsx", picture, "CAT-SML-PICTURE"), "rendered")
}

///|
test "catalog xlsx legacyDrawingHF renders resolved VML drawing part" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let legacy = stamp_target(xep("s", ns_s, "legacyDrawingHF", [], []))
  assert_eq(verify_entry("xlsx", legacy, "CAT-SML-LEGACY-HF"), "rendered")
  let svg = render_svg_of("xlsx", host_package_for_render("xlsx", legacy)).unwrap_or(
    "",
  )
  assert_true(svg.contains("class=\"legacy-drawing-hf\""))
  assert_true(svg.contains("data-ooxml-legacy-drawing-hf-r-id=\"rIdLegacyHF\""))
  assert_true(svg.contains("fill=\"#F2F7FF\""))
  assert_true(svg.contains("stroke=\"#2F5597\""))
  assert_false(svg.contains("legacy VML HF"))
}

///|
test "catalog xlsx legacyDrawing renders resolved VML drawing part" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let legacy = stamp_target(
    xep("s", ns_s, "legacyDrawing", [sml_aux_rel_attr("id", "0")], []),
  )
  assert_eq(verify_entry("xlsx", legacy, "CAT-SML-LEGACY"), "rendered")
  let svg = render_svg_of("xlsx", host_package_for_render("xlsx", legacy)).unwrap_or(
    "",
  )
  assert_true(svg.contains("class=\"legacy-drawing\""))
  assert_true(svg.contains("data-ooxml-legacy-drawing-r-id=\"rIdLegacy\""))
  assert_true(svg.contains("fill=\"#F2F7FF\""))
  assert_true(svg.contains("stroke=\"#2F5597\""))
}

///|
test "catalog xlsx controls render resolved ActiveX control part" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let controls = stamp_target(xep("s", ns_s, "controls", [], []))
  assert_eq(verify_entry("xlsx", controls, "CAT-SML-CONTROLS"), "rendered")
  let svg = render_svg_of("xlsx", host_package_for_render("xlsx", controls)).unwrap_or(
    "",
  )
  assert_true(svg.contains("class=\"controls\""))
  assert_true(svg.contains("class=\"control\""))
  assert_true(svg.contains("data-ooxml-control-r-id=\"rIdControl\""))
  assert_true(svg.contains("data-ooxml-control-anchor-from=\"A1\""))
  assert_true(svg.contains("data-ooxml-control-anchor-to=\"D6\""))
  assert_true(svg.contains(">CatalogControl<"))
}

///|
test "catalog xlsx customProperties render resolved custom property part" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let custom_properties = stamp_target(
    xep("s", ns_s, "customProperties", [], []),
  )
  assert_eq(
    verify_entry("xlsx", custom_properties, "CAT-SML-CUSTOM-PROPERTIES"),
    "rendered",
  )
  let svg = render_svg_of(
    "xlsx",
    host_package_for_render("xlsx", custom_properties),
  ).unwrap_or("")
  assert_true(svg.contains("data-ooxml-custom-properties-count=\"1\""))
  assert_true(svg.contains("data-ooxml-custom-property-0-r-id=\"rIdCustom\""))
  assert_true(
    svg.contains("data-ooxml-custom-property-0-payload-0-value=\"observed\""),
  )
}

///|
test "catalog xlsx chartsheet renders resolved drawing chart" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let chartsheet = stamp_target(
    xep("s", ns_s, "chartsheet", [], [
      Element(
        xep("s", ns_s, "sheetViews", [], [
          Element(xep("s", ns_s, "sheetView", [xa("workbookViewId", "0")], [])),
        ]),
      ),
      Element(xep("s", ns_s, "drawing", [sml_aux_rel_attr("id", "0")], [])),
    ]),
  )
  assert_eq(
    verify_entry("xlsx:chartsheet", chartsheet, "CAT-SML-CHARTSHEET"),
    "rendered",
  )
  let svg = render_svg_of(
    "xlsx:chartsheet",
    host_package_for_render("xlsx:chartsheet", chartsheet),
  ).unwrap_or("")
  assert_true(svg.contains("data-ooxml-chartsheet=\"1\""))
  assert_true(svg.contains("data-ooxml-chartsheet-drawing-r-id=\"rIdDrawing\""))
  assert_true(svg.contains("class=\"drawings\""))
  assert_true(svg.contains("data-ooxml=\"chart\""))
}

///|
test "catalog xlsx sheetViews routes through worksheet view chrome" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let sheet_views = stamp_target(
    xep("s", ns_s, "sheetViews", [], [
      Element(
        xep("s", ns_s, "sheetView", [xa("workbookViewId", "0")], [
          Element(xep("s", ns_s, "selection", [], [])),
        ]),
      ),
    ]),
  )
  assert_eq(verify_entry("xlsx", sheet_views, "CAT-SML-SHEETVIEWS"), "rendered")
}

///|
test "catalog xlsx pane routes through worksheet view split lines" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let pane = stamp_target(xep("s", ns_s, "pane", [], []))
  assert_eq(verify_entry("xlsx", pane, "CAT-SML-PANE"), "rendered")
}

///|
test "catalog xlsx selection routes through worksheet view outline" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let selection = stamp_target(xep("s", ns_s, "selection", [], []))
  assert_eq(verify_entry("xlsx", selection, "CAT-SML-SELECTION"), "rendered")
}

///|
test "catalog xlsx pivot filters route through pivot table materializer" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let filters = stamp_target(
    xep("s", ns_s, "filters", [xa("count", "1")], [
      Element(xep("s", ns_s, "filter", [xa("fld", "0")], [])),
    ]),
  )
  assert_eq(verify_entry("xlsx", filters, "CAT-SML-PIVOT-FILTERS"), "rendered")
}

///|
test "catalog xlsx pivot filter routes through pivot table materializer" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let filter = stamp_target(xep("s", ns_s, "filter", [xa("fld", "0")], []))
  assert_eq(verify_entry("xlsx", filter, "CAT-SML-PIVOT-FILTER"), "rendered")
}

///|
test "catalog xlsx pivot pageField renders page field dropdown" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let page_field = stamp_target(xep("s", ns_s, "pageField", [], []))
  let root = catalog_sml_pivot_root(
    page_field, "http://schemas.openxmlformats.org/spreadsheetml/2006/main#CT_PageField",
  )
  assert_eq(
    verify_entry("xlsx:pivot", root, "CAT-SML-PIVOT-PAGEFIELD"),
    "rendered",
  )
  let svg = render_svg_of(
    "xlsx:pivot",
    host_package("xlsx:pivot", strip_target_attr(root)),
  ).unwrap_or("")
  assert_true(svg.contains("class=\"pivot-page-fields\""))
  assert_true(svg.contains(">Product<"))
  assert_true(svg.contains(">Apple<"))
  assert_true(svg.contains("data-ooxml-autofilter=\"button\""))
}

///|
test "catalog xlsx tablePart routes through real worksheet tableParts rel" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let table_part = stamp_target(xep("s", ns_s, "tablePart", [], []))
  assert_eq(verify_entry("xlsx", table_part, "CAT-SML-TABLEPART"), "rendered")
}

///|
test "catalog xlsx table root routes through table part chrome" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let table = stamp_target(
    xep(
      "s",
      ns_s,
      "table",
      [xa("id", "1"), xa("name", "T"), xa("displayName", "T"), xa("ref", "x")],
      [],
    ),
  )
  assert_eq(verify_entry("xlsx", table, "CAT-SML-TABLE"), "rendered")
}

///|
test "catalog xlsx table formulas and xmlColumnPr receive visible metadata" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let calc = stamp_target(
    xep("s", ns_s, "calculatedColumnFormula", [], [Text(TEXT_MARKER)]),
  )
  assert_eq(verify_entry("xlsx", calc, "CAT-SML-CALC-COL-FORMULA"), "rendered")
  let totals = stamp_target(
    xep("s", ns_s, "totalsRowFormula", [], [Text(TEXT_MARKER)]),
  )
  assert_eq(verify_entry("xlsx", totals, "CAT-SML-TOTALS-FORMULA"), "rendered")
  let xml_column = stamp_target(
    xep(
      "s",
      ns_s,
      "xmlColumnPr",
      [
        xa("mapId", "1"),
        xa("xpath", "/catalog/item"),
        xa("xmlDataType", "string"),
      ],
      [],
    ),
  )
  assert_eq(verify_entry("xlsx", xml_column, "CAT-SML-XML-COLUMN"), "rendered")
}

///|
test "catalog pptx table host routes DrawingML table root to existing renderer" {
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  let tbl = stamp_target(
    xep("a", ns_a, "tbl", [], [
      Element(
        xep("a", ns_a, "tblGrid", [], [
          Element(xep("a", ns_a, "gridCol", [xa("w", "914400")], [])),
        ]),
      ),
      Element(
        xep("a", ns_a, "tr", [xa("h", "914400")], [
          Element(xep("a", ns_a, "tc", [], [])),
        ]),
      ),
    ]),
  )
  assert_true(
    is_drawingml_table_catalog_target("tbl", ns_a + "#CT_Table", ns_a),
  )
  let probe = catalog_table_root(tbl)
  assert_eq(verify_entry("pptx:table", probe, "CAT-TABLE"), "rendered")
  let svg = match
    render_svg_of(
      "pptx:table",
      host_package("pptx:table", strip_target_attr(probe)),
    ) {
    Some(s) => s
    None => abort("expected table host to render")
  }
  assert_true(svg.contains("<g class=\"tbl\">"))
  assert_true(svg.contains("<rect "))
}

///|
test "catalog pptx table host routes table border children through table renderer" {
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  let ln_b = stamp_target(
    xep("a", ns_a, "lnB", [xa("w", "19050")], [
      Element(
        xep("a", ns_a, "solidFill", [], [
          Element(xep("a", ns_a, "srgbClr", [xa("val", "000000")], [])),
        ]),
      ),
    ]),
  )
  assert_true(
    is_drawingml_table_catalog_target("lnB", ns_a + "#CT_LineProperties", ns_a),
  )
  let probe = catalog_table_root(ln_b)
  assert_eq(verify_entry("pptx:table", probe, "CAT-TABLE-LNB"), "rendered")
  let svg = match
    render_svg_of(
      "pptx:table",
      host_package("pptx:table", strip_target_attr(probe)),
    ) {
    Some(s) => s
    None => abort("expected table border host to render")
  }
  assert_true(svg.contains("<g class=\"tbl\">"))
  assert_true(svg.contains("<line "))
  assert_true(svg.contains("stroke=\"#000000\""))
}

///|
test "catalog pptx table host does not credit noFill border scaffolding" {
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  let ln_b = stamp_target(
    xep("a", ns_a, "lnB", [xa("w", "19050")], [
      Element(xep("a", ns_a, "noFill", [], [])),
    ]),
  )
  let probe = catalog_table_root(ln_b)
  assert_eq(verify_entry("pptx:table", probe, "CAT-TABLE-LNB-NOFILL"), "parsed")
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
test "catalog diagram active colors connect fill line and text lists" {
  fn color_list(name : String, val : String) -> @xml.Element {
    stamp_target(
      xep("dgm", NS_DGM, name, [], [
        Element(xep("a", NS_A, "srgbClr", [xa("val", val)], [])),
      ]),
    )
  }

  for
    entry in [
      ("fillClrLst", "FF0000"),
      ("linClrLst", "00FF00"),
      ("txLinClrLst", "AA00AA"),
      ("txFillClrLst", "0000FF"),
    ] {
    let (name, val) = entry
    let root = catalog_diagram_active_colors_root(color_list(name, val))
    assert_eq(
      verify_entry("pptx:diagram-colors", root, "CAT-DGM-COLOR-" + name),
      "rendered",
    )
  }
}

///|
test "catalog diagram active layout connects shape presOf and constraints" {
  let targets = [
    stamp_target(
      xep("dgm", NS_DGM, "shape", [xa("type", "rect"), xa("hideGeom", "1")], []),
    ),
    stamp_target(xep("dgm", NS_DGM, "presOf", [], [])),
    stamp_target(xep("dgm", NS_DGM, "constr", [], [])),
    stamp_target(xep("dgm", NS_DGM, "constrLst", [], [])),
  ]
  for target in targets {
    let root = catalog_diagram_active_layout_root(target)
    assert_eq(
      verify_entry(
        "pptx:diagram-layout",
        root,
        "CAT-DGM-LAYOUT-" + target.name.local_name,
      ),
      "rendered",
    )
  }
}

///|
test "catalog diagram active layout connects algorithm and parameter" {
  let targets = [
    stamp_target(xep("dgm", NS_DGM, "alg", [], [])),
    stamp_target(xep("dgm", NS_DGM, "param", [], [])),
  ]
  for target in targets {
    let root = catalog_diagram_algorithm_layout_root(target)
    assert_eq(
      verify_entry(
        "pptx:diagram-layout-alg",
        root,
        "CAT-DGM-ALG-" + target.name.local_name,
      ),
      "rendered",
    )
  }
}

///|
test "catalog diagram active layout connects shape adjustments" {
  let targets = [
    stamp_target(xep("dgm", NS_DGM, "adj", [], [])),
    stamp_target(xep("dgm", NS_DGM, "adjLst", [], [])),
  ]
  for target in targets {
    let root = catalog_diagram_adjustment_layout_root(target)
    assert_eq(
      verify_entry(
        "pptx:diagram-layout-adj",
        root,
        "CAT-DGM-ADJ-" + target.name.local_name,
      ),
      "rendered",
    )
  }
}

///|
test "catalog diagram active layout connects numeric rules" {
  let targets = [
    stamp_target(xep("dgm", NS_DGM, "rule", [], [])),
    stamp_target(xep("dgm", NS_DGM, "ruleLst", [], [])),
  ]
  for target in targets {
    let root = catalog_diagram_rule_layout_root(target)
    assert_eq(
      verify_entry(
        "pptx:diagram-layout-rule",
        root,
        "CAT-DGM-RULE-" + target.name.local_name,
      ),
      "rendered",
    )
  }
}

///|
test "catalog diagram active layout connects flow controls" {
  let targets = [
    stamp_target(xep("dgm", NS_DGM, "layoutNode", [], [])),
    stamp_target(xep("dgm", NS_DGM, "forEach", [], [])),
    stamp_target(xep("dgm", NS_DGM, "choose", [], [])),
    stamp_target(xep("dgm", NS_DGM, "if", [], [])),
    stamp_target(xep("dgm", NS_DGM, "else", [], [])),
  ]
  for target in targets {
    let root = catalog_diagram_layout_flow_layout_root(target)
    assert_eq(
      verify_entry(
        "pptx:diagram-layout-flow",
        root,
        "CAT-DGM-FLOW-" + target.name.local_name,
      ),
      "rendered",
    )
  }
}

///|
test "catalog diagram active layout connects variable properties" {
  let targets = [
    stamp_target(xep("dgm", NS_DGM, "varLst", [], [])),
    stamp_target(xep("dgm", NS_DGM, "orgChart", [], [])),
    stamp_target(xep("dgm", NS_DGM, "chMax", [], [])),
    stamp_target(xep("dgm", NS_DGM, "chPref", [], [])),
    stamp_target(xep("dgm", NS_DGM, "bulletEnabled", [], [])),
    stamp_target(xep("dgm", NS_DGM, "dir", [], [])),
    stamp_target(xep("dgm", NS_DGM, "hierBranch", [], [])),
    stamp_target(xep("dgm", NS_DGM, "animOne", [], [])),
    stamp_target(xep("dgm", NS_DGM, "animLvl", [], [])),
    stamp_target(xep("dgm", NS_DGM, "resizeHandles", [], [])),
  ]
  for target in targets {
    let root = catalog_diagram_layout_variable_layout_root(target)
    assert_eq(
      verify_entry(
        "pptx:diagram-layout-var",
        root,
        "CAT-DGM-VAR-" + target.name.local_name,
      ),
      "rendered",
    )
  }
}

///|
test "catalog diagram active data connects background and point text" {
  let text_body = xep("dgm", NS_DGM, "t", [], [
    Element(
      xep("a", NS_A, "p", [], [
        Element(
          xep("a", NS_A, "r", [], [
            Element(xep("a", NS_A, "t", [], [Text("Catalog point")])),
          ]),
        ),
      ]),
    ),
  ])
  let point = xep("dgm", NS_DGM, "pt", [xa("modelId", "1")], [
    Element(text_body),
  ])
  let targets = [
    stamp_target(xep("dgm", NS_DGM, "bg", [], [])),
    stamp_target(xep("dgm", NS_DGM, "whole", [], [])),
    stamp_target(text_body),
    stamp_target(point),
    stamp_target(xep("dgm", NS_DGM, "ptLst", [], [])),
    stamp_target(xep("dgm", NS_DGM, "prSet", [], [])),
  ]
  for target in targets {
    let root = catalog_diagram_active_data_model_root(target)
    assert_eq(
      verify_entry(
        "pptx:diagram-data",
        root,
        "CAT-DGM-DATA-" + target.name.local_name,
      ),
      "rendered",
    )
  }
}

///|
test "catalog diagram active data connects point presentation layout variables" {
  let target = stamp_target(xep("dgm", NS_DGM, "presLayoutVars", [], []))
  let root = catalog_diagram_point_variable_data_model_root(target)
  assert_eq(
    verify_entry("pptx:diagram-data-var", root, "CAT-DGM-DATA-presLayoutVars"),
    "rendered",
  )
}

///|
test "catalog diagram active data connects connector list" {
  let targets = [
    stamp_target(xep("dgm", NS_DGM, "cxn", [], [])),
    stamp_target(xep("dgm", NS_DGM, "cxnLst", [], [])),
  ]
  for target in targets {
    let root = catalog_diagram_connection_data_model_root(target)
    assert_eq(
      verify_entry(
        "pptx:diagram-data-cxn",
        root,
        "CAT-DGM-CXN-" + target.name.local_name,
      ),
      "rendered",
    )
  }
}

///|
test "catalog diagram active style connects quickStyle labels" {
  let target = stamp_target(xep("dgm", NS_DGM, "styleLbl", [], []))
  let root = catalog_diagram_active_style_root(target)
  assert_eq(
    verify_entry("pptx:diagram-style", root, "CAT-DGM-STYLE-styleLbl"),
    "rendered",
  )
}

///|
test "catalog diagram colors connects effect color list to shape effects" {
  let target = stamp_target(xep("dgm", NS_DGM, "effectClrLst", [], []))
  let root = catalog_diagram_effect_colors_root(target)
  assert_eq(
    verify_entry(
      "pptx:diagram-colors-effect", root, "CAT-DGM-COLOR-effectClrLst",
    ),
    "rendered",
  )
}

///|
test "catalog diagram colors connects txEffectClrLst to text effects" {
  let target = stamp_target(xep("dgm", NS_DGM, "txEffectClrLst", [], []))
  let root = catalog_diagram_text_effect_colors_root(target)
  assert_eq(
    verify_entry(
      "pptx:diagram-colors-text-effect", root, "CAT-DGM-COLOR-txEffectClrLst",
    ),
    "rendered",
  )
}

///|
test "catalog diagram style connects txPr to text effects" {
  let target = stamp_target(xep("dgm", NS_DGM, "txPr", [], []))
  let root = catalog_diagram_text_effect_style_root(target)
  assert_eq(
    verify_entry("pptx:diagram-style-text-effect", root, "CAT-DGM-STYLE-txPr"),
    "rendered",
  )
}

///|
fn catalog_cdr_marker(name : String, x : String, y : String) -> @xml.Element {
  let ns_cdr = "http://schemas.openxmlformats.org/drawingml/2006/chartDrawing"
  xep("cdr", ns_cdr, name, [], [
    Element(xep("cdr", ns_cdr, "x", [], [Text(x)])),
    Element(xep("cdr", ns_cdr, "y", [], [Text(y)])),
  ])
}

///|
fn catalog_cdr_shape() -> @xml.Element {
  let ns_cdr = "http://schemas.openxmlformats.org/drawingml/2006/chartDrawing"
  xep("cdr", ns_cdr, "sp", [], [
    Element(
      xep("cdr", ns_cdr, "nvSpPr", [], [
        Element(
          xep(
            "cdr",
            ns_cdr,
            "cNvPr",
            [xa("id", "2"), xa("name", "Catalog Chart User Shape")],
            [],
          ),
        ),
        Element(xep("cdr", ns_cdr, "cNvSpPr", [], [])),
      ]),
    ),
    Element(
      xep("cdr", ns_cdr, "spPr", [], [
        Element(
          xep("a", NS_A, "prstGeom", [xa("prst", "rect")], [
            Element(xep("a", NS_A, "avLst", [], [])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn catalog_chart_user_shapes_root(shape : @xml.Element) -> @xml.Element {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let ns_cdr = "http://schemas.openxmlformats.org/drawingml/2006/chartDrawing"
  let anchor = xep("cdr", ns_cdr, "absSizeAnchor", [], [
    Element(catalog_cdr_marker("from", "0.15", "0.20")),
    Element(
      xep("cdr", ns_cdr, "ext", [xa("cx", "1800000"), xa("cy", "900000")], []),
    ),
    Element(shape),
  ])
  xep("c", ns_c, "userShapes", [], [Element(anchor)])
}

///|
test "catalog pptx chart userShapes host resolves chartDrawing part" {
  let root = catalog_chart_user_shapes_root(stamp_target(catalog_cdr_shape()))
  assert_eq(
    verify_entry("pptx:chart-usershapes", root, "CAT-CDR-SP"),
    "rendered",
  )
  let svg = match
    render_svg_of(
      "pptx:chart-usershapes",
      host_package("pptx:chart-usershapes", strip_target_attr(root)),
    ) {
    Some(s) => s
    None => abort("expected chart userShapes host to render")
  }
  assert_true(svg.contains("data-ooxml=\"chart-user-shape-sp\""))
  assert_true(svg.contains("fill=\"#dceaff\""))
}

///|
test "catalog chart userShapes rel host resolves chartDrawing part" {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let target = xep("c", ns_c, "userShapes", [xa("id", "rId9")], [])
  let root = catalog_chart_user_shapes_ref_root(stamp_target(target))
  assert_eq(
    verify_entry("pptx:chart-usershapes-ref", root, "CAT-CHART-USER-SHAPES"),
    "rendered",
  )
  let svg = match
    render_svg_of(
      "pptx:chart-usershapes-ref",
      host_package("pptx:chart-usershapes-ref", strip_target_attr(root)),
    ) {
    Some(s) => s
    None => abort("expected chart userShapes ref host to render")
  }
  assert_true(svg.contains("data-ooxml=\"chart-user-shape-sp\""))
  assert_true(svg.contains("fill=\"#dceaff\""))
}

///|
test "catalog chartDrawing nonvisual hosts connect cNvPr hidden" {
  let ns_cdr = "http://schemas.openxmlformats.org/drawingml/2006/chartDrawing"
  let cases : Array[(String, String)] = [
    ("nvSpPr", "cNvSpPr"),
    ("nvCxnSpPr", "cNvCxnSpPr"),
    ("nvPicPr", "cNvPicPr"),
    ("nvGraphicFramePr", "cNvGraphicFramePr"),
    ("nvGrpSpPr", "cNvGrpSpPr"),
  ]
  for item in cases {
    let (nv_local, second) = item
    let target = xep("cdr", ns_cdr, nv_local, [], [
      Element(
        xep("cdr", ns_cdr, "cNvPr", [xa("id", "9"), xa("name", nv_local)], []),
      ),
      Element(xep("cdr", ns_cdr, second, [], [])),
    ])
    let root = catalog_chart_user_shapes_nonvisual_root(stamp_target(target))
    assert_eq(
      verify_entry("pptx:chart-usershapes", root, "CAT-CDR-" + nv_local),
      "rendered",
    )
  }
}

///|
test "catalog docx chart rel host resolves chart part" {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let target = xep("c", ns_c, "chart", [xa("id", "rIdOther")], [])
  let root = catalog_docx_chart_ref_body(stamp_target(target))
  assert_eq(verify_entry("docx:chart", root, "CAT-WML-CHART"), "rendered")
  let svg = match
    render_svg_of(
      "docx:chart",
      host_package("docx:chart", strip_target_attr(root)),
    ) {
    Some(s) => s
    None => abort("expected docx chart host to render")
  }
  assert_true(svg.contains("data-ooxml=\"chart\""))
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
