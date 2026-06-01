// Visual-fixture helper functions, lifted to top-level so the
// category-specific case builders (`fixtures_wml_*.mbt`,
// `fixtures_sml*.mbt`, `fixtures_pml*.mbt`, `fixtures_omml.mbt`) can
// be split across files and worked on in parallel without sharing
// closures.

///|
/// SVG-namespace shorthand for the OMML math text element factory.
fn m_t(text : String) -> @xml.Element {
  xe(NS_M, "t", [], [Text(text)])
}

///|
/// OMML `<m:r>` (math run) containing the given literal text.
fn m_r(text : String) -> @xml.Element {
  xe(NS_M, "r", [], [Element(m_t(text))])
}

///|
/// OMML wrapper element with one inner content element — e.g. `<m:e>`,
/// `<m:num>`, `<m:den>`, `<m:sub>`, `<m:sup>`.
fn m_arg(name : String, inner : @xml.Element) -> @xml.Element {
  xe(NS_M, name, [], [Element(inner)])
}

///|
/// OMML `<m:e>` cell — used by matrix rows.
fn m_e(text : String) -> @xml.Element {
  xe(NS_M, "e", [], [Element(m_r(text))])
}

///|
/// SpreadsheetML `<c>` cell with a numeric `<v>` value.
fn s_cell(ref_ : String, value : String) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_)], [Element(xe(NS_S, "v", [], [Text(value)]))])
}

///|
/// SpreadsheetML `<row>` carrying the given cells.
fn s_row(num : String, cells : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cells {
    kids.push(Element(c))
  }
  xe(NS_S, "row", [xa("r", num)], kids)
}

///|
/// SpreadsheetML `<row hidden="1">` carrying cells filtered out by a
/// persisted AutoFilter view.
fn s_row_hidden(num : String, cells : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cells {
    kids.push(Element(c))
  }
  xe(NS_S, "row", [xa("r", num), xa("hidden", "1")], kids)
}

///|
/// SpreadsheetML inline-string cell — `t="inlineStr"` + `<is><t>`.
fn s_inline(ref_ : String, text : String) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_), xa("t", "inlineStr")], [
    Element(xe(NS_S, "is", [], [Element(xe(NS_S, "t", [], [Text(text)]))])),
  ])
}

///|
/// SpreadsheetML formula cell — `<f>...</f>` with cached `<v>`.
fn s_formula(ref_ : String, formula : String, cached : String) -> @xml.Element {
  xe(NS_S, "c", [xa("r", ref_)], [
    Element(xe(NS_S, "f", [], [Text(formula)])),
    Element(xe(NS_S, "v", [], [Text(cached)])),
  ])
}

///|
/// WML run with an explicit font family on the run.
fn w_rfonts(ascii_face : String) -> @xml.Element {
  xe(
    NS_W,
    "rFonts",
    [
      {
        name: { prefix: Some("w"), local_name: "ascii", ns: Some(NS_W) },
        value: ascii_face,
      },
      {
        name: { prefix: Some("w"), local_name: "hAnsi", ns: Some(NS_W) },
        value: ascii_face,
      },
    ],
    [],
  )
}

///|
/// DrawingML `<a:xfrm>` containing `<a:off>` (position) and
/// `<a:ext>` (size) in EMU.
fn sp_xfrm(x : String, y : String, cx : String, cy : String) -> @xml.Element {
  xe(NS_A, "xfrm", [], [
    Element(xe(NS_A, "off", [xa("x", x), xa("y", y)], [])),
    Element(xe(NS_A, "ext", [xa("cx", cx), xa("cy", cy)], [])),
  ])
}

///|
/// DrawingML `<a:solidFill>` with an sRGB hex colour.
fn solid_fill(hex : String) -> @xml.Element {
  xe(NS_A, "solidFill", [], [Element(xe(NS_A, "srgbClr", [xa("val", hex)], []))])
}

///|
/// PresentationML `<p:sp>` shape with preset geometry and solid fill.
fn pptx_shape(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  hex : String,
) -> @xml.Element {
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm(x, y, cx, cy)),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", prst)], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(solid_fill(hex)),
      ]),
    ),
  ])
}

///|
/// PresentationML `<p:sp>` shape with preset geometry, no fill, and
/// an explicit outline (`<a:ln>`).  Used for stroke-only presets
/// (brackets, braces, connectors, line, arc).
fn pptx_shape_outline(
  id_ : String,
  name : String,
  prst : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  hex : String,
) -> @xml.Element {
  xe(NS_PML, "sp", [], [
    Element(
      xe(NS_PML, "nvSpPr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvSpPr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "spPr", [], [
        Element(sp_xfrm(x, y, cx, cy)),
        Element(
          xe(NS_A, "prstGeom", [xa("prst", prst)], [
            Element(xe(NS_A, "avLst", [], [])),
          ]),
        ),
        Element(xe(NS_A, "noFill", [], [])),
        Element(xe(NS_A, "ln", [xa("w", "38100")], [Element(solid_fill(hex))])),
      ]),
    ),
  ])
}

///|
/// Wrap a list of shapes in the PresentationML slide tree:
/// `<p:cSld><p:spTree>(nvGrpSpPr + grpSpPr + shapes)</p:spTree></p:cSld>`.
fn sp_tree(shapes : Array[@xml.Element]) -> @xml.Element {
  pptx_common_slide_data(NS_PML, shapes)
}

///|
/// Lay an arbitrary preset list out as a 4-column grid of cells,
/// each preset rendered as a solid-filled shape.  Isolates the
/// GEOMETRY of each `prst` for visual comparison.
fn preset_batch(names : Array[String], hex : String) -> @xml.Element {
  let shapes : Array[@xml.Element] = []
  for i, n in names {
    let col = i % 4
    let row = i / 4
    let x = (457200 + col * 2057400).to_string()
    let y = (457200 + row * 1600200).to_string()
    shapes.push(
      pptx_shape((i + 2).to_string(), n, n, x, y, "1828800", "1371600", hex),
    )
  }
  sp_tree(shapes)
}

///|
/// Stroke-only variant of `preset_batch` — uses `pptx_shape_outline`
/// so brackets / braces / connectors are rendered with the bracket
/// OUTLINE instead of a filled bracket-shaped region.
fn _preset_batch_outline(names : Array[String], hex : String) -> @xml.Element {
  let shapes : Array[@xml.Element] = []
  for i, n in names {
    let col = i % 4
    let row = i / 4
    let x = (457200 + col * 2057400).to_string()
    let y = (457200 + row * 1600200).to_string()
    shapes.push(
      pptx_shape_outline(
        (i + 2).to_string(),
        n,
        n,
        x,
        y,
        "1828800",
        "1371600",
        hex,
      ),
    )
  }
  sp_tree(shapes)
}
