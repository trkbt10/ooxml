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
