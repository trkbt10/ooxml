///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
/// Helper: build a `<c r=".." t=".."><v>..</v></c>` cell as an XML node.
fn build_cell(
  cell_ref : String,
  cell_type : String?,
  value_text : String,
) -> @xml.Node {
  let attrs : Array[@xml.Attribute] = [{ name: name("r"), value: cell_ref }]
  match cell_type {
    Some(t) => attrs.push({ name: name("t"), value: t })
    None => ()
  }
  @xml.Node::Element({
    name: name("c"),
    attributes: attrs,
    children: [
      @xml.Node::Element({
        name: name("v"),
        attributes: [],
        children: [@xml.Node::Text(value_text)],
      }),
    ],
  })
}

///|
/// Helper: build a `<row r="N">...children...</row>` element.
fn build_row(row_num : Int, cells : Array[@xml.Node]) -> @xml.Node {
  @xml.Node::Element({
    name: name("row"),
    attributes: [{ name: name("r"), value: row_num.to_string() }],
    children: cells,
  })
}

///|
test "SpreadsheetML SVG renderer column letter conversion" {
  inspect(column_index_to_letter(1), content="A")
  inspect(column_index_to_letter(26), content="Z")
  inspect(column_index_to_letter(27), content="AA")
  inspect(column_index_to_letter(52), content="AZ")
  inspect(column_index_to_letter(702), content="ZZ")
  inspect(column_index_to_letter(703), content="AAA")
}

///|
test "SpreadsheetML SVG renderer cell ref round-trip" {
  inspect(cell_ref_from_indices(1, 1), content="A1")
  inspect(cell_ref_from_indices(10, 27), content="AA10")
  let parsed = parse_cell_ref("AB12")
  match parsed {
    Some((row, col)) => {
      inspect(row, content="12")
      inspect(col, content="28")
    }
    None => abort("parse failed")
  }
}

///|
test "SpreadsheetML SVG renderer column / row pixel conversions" {
  // §18.3.1.13 — Truncate(((256*8.43 + Trunc(128/MDW))/256)*MDW)
  // with MDW = 7.7 (the Calibri-substitute "0" advance @ 11pt 96dpi,
  // documented in `column_max_digit_width_px`):
  //              = Truncate(((2158.08 + 16)/256)*7.7)
  //              = Truncate(8.4925*7.7) = Truncate(65.39) = 65
  inspect(column_width_to_pixels(8.43), content="65")
  // 15 pt * 96/72 = 20 → round → 20.
  inspect(row_height_to_pixels(15.0), content="20")
  // 14.4 pt * 96/72 = 19.2 → round → 19.
  inspect(row_height_to_pixels(14.4), content="19")
}

///|
test "SpreadsheetML SVG renderer renders empty sheet placeholder" {
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [],
  })
  let result = render_svg(worksheet)
  inspect(result.width, content="200")
  inspect(result.height, content="50")
  assert_true(result.svg.contains("(empty sheet)"))
}

///|
test "SpreadsheetML SVG renderer renders 2x2 sheet with text cells" {
  // A1 inline string, B1 numeric, A2 numeric, B2 numeric.
  let cells_row1 : Array[@xml.Node] = [
    {
      let attrs : Array[@xml.Attribute] = [
        { name: name("r"), value: "A1" },
        { name: name("t"), value: "inlineStr" },
      ]
      @xml.Node::Element({
        name: name("c"),
        attributes: attrs,
        children: [
          @xml.Node::Element({
            name: name("is"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("t"),
                attributes: [],
                children: [@xml.Node::Text("Hello")],
              }),
            ],
          }),
        ],
      })
    },
    build_cell("B1", None, "100"),
  ]
  let cells_row2 : Array[@xml.Node] = [
    build_cell("A2", None, "1.5"),
    build_cell("B2", None, "2"),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:B2" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1), build_row(2, cells_row2)],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // §18.3.1.13 spec formula → default col width 8.43 char = 65 px
  // (MDW = 7.7, see `column_max_digit_width_px`).
  // Two columns × 65 = 130 px body. Two rows × 17 px (12.75pt × 96/72
  // rounded — see `default_render_options` for why we use 12.75 pt
  // instead of the spec's 15 pt) = 34 px body.
  // §18.3.1.62 — `result.width` / `result.height` are the page
  // size, i.e. body + print margins.  This worksheet declares no
  // `<pageMargins>`, so the renderer falls back to Excel's print
  // defaults (2.0 cm L/R, 2.5 cm T/B) so the SVG lines up with
  // the reference PDF export used as the snapshot reference.
  //   2.0 cm = 0.787" = 75.59055 px @ 96 DPI
  //   2.5 cm = 0.984" = 94.48819 px @ 96 DPI
  //   width  = 130 + 2*75.59055 ≈ 281.181
  //   height =  34 + 2*94.48819 ≈ 222.976
  inspect(
    result.width,
    content=(
      #|281.1811023622047
    ),
  )
  inspect(
    result.height,
    content=(
      #|222.9763779527559
    ),
  )
  assert_true(result.svg.contains("<svg"))
  assert_true(result.svg.contains("data-ooxml=\"sml\""))
  assert_true(result.svg.contains("Hello"))
  assert_true(result.svg.contains("100"))
  assert_true(result.svg.contains("1.5"))
  // Renderer is a *page* render: gridlines follow §18.3.1.70
  // `<printOptions @gridLines>` (default false), not §18.3.1.87
  // `<sheetView @showGridLines>` (default true).  This worksheet
  // declares neither, so gridlines MUST be absent — matching
  // the reference PDF export.  See `default_render_options` for
  // the rationale.  Callers that want screen-style gridlines pass
  // `show_grid_lines: true` or set `<printOptions @gridLines="1">`.
  assert_false(result.svg.contains("class=\"grid-lines\""))
  assert_true(result.svg.contains("class=\"cell-text\""))
}

///|
test "SpreadsheetML SVG renderer boolean cells (§18.4.2 / §18.18.11)" {
  // A1 = canonical true ("1"), B1 = canonical false ("0"),
  // A2 = lexical "true" (recoverable), B2 = a non-spec literal.
  let cells_row1 : Array[@xml.Node] = [
    build_cell("A1", Some("b"), "1"),
    build_cell("B1", Some("b"), "0"),
  ]
  let cells_row2 : Array[@xml.Node] = [
    build_cell("A2", Some("b"), "true"),
    build_cell("B2", Some("b"), "maybe"),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:B2" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1), build_row(2, cells_row2)],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // Canonical values render as TRUE / FALSE.
  assert_true(result.svg.contains("TRUE"))
  assert_true(result.svg.contains("FALSE"))
  // Lexical "true" is recovered to TRUE with a warning.
  // The non-spec literal "maybe" is surfaced verbatim, not "?".
  assert_true(result.svg.contains("maybe"))
  assert_false(result.svg.contains(">?<"))
}

///|
test "SpreadsheetML SVG renderer respects shared-string table" {
  // A1 is a shared-string index 0 (-> "Hi"), B1 is shared-string index 1 (-> "There").
  let sst = @domain.CT_Sst::new({
    name: name("sst"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("si"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("t"),
            attributes: [],
            children: [@xml.Node::Text("Hi")],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("si"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("t"),
            attributes: [],
            children: [@xml.Node::Text("There")],
          }),
        ],
      }),
    ],
  })
  let cells : Array[@xml.Node] = [
    build_cell("A1", Some("s"), "0"),
    build_cell("B1", Some("s"), "1"),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:B1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells)],
      }),
    ],
  })
  let result = render_svg(worksheet, shared_strings=Some(sst))
  assert_true(result.svg.contains("Hi"))
  assert_true(result.svg.contains("There"))
}

///|
test "SpreadsheetML SVG renderer honours merge cell layout" {
  // A1:B1 merged so width is 2*64 = 128.
  let cells : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:B2" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          build_row(1, cells),
          build_row(2, [build_cell("A2", None, "2")]),
        ],
      }),
      @xml.Node::Element({
        name: name("mergeCells"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("mergeCell"),
            attributes: [{ name: name("ref"), value: "A1:B1" }],
            children: [],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // §18.3.1.13 spec formula → 2 default columns × 65 px = 130 px
  // body (MDW = 7.7, see `column_max_digit_width_px`), plus
  // §18.3.1.62 print-default 2.0 cm L/R print margins
  // (75.59055 px each, 96 DPI) = 281.181 px page width.
  inspect(
    result.width,
    content=(
      #|281.1811023622047
    ),
  )
  // The cell-text group must include "1" exactly once: B1 is hidden by merge.
  assert_true(result.svg.contains(">1<"))
  // It must contain "2" for A2.
  assert_true(result.svg.contains(">2<"))
}

///|
/// §18.3.1.55 — grid lines that would otherwise bisect a merged
/// region must not be emitted. With A1:C1 merged, the inner column
/// boundaries (between A/B and B/C) within row 1 must NOT appear
/// alongside the merged area, while the outer-frame verticals and
/// the row-2 boundary still must.
test "SpreadsheetML grid lines skip inside merged regions" {
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "M")]
  let cells_row2 : Array[@xml.Node] = [
    build_cell("A2", None, "x"),
    build_cell("B2", None, "y"),
    build_cell("C2", None, "z"),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:C2" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1), build_row(2, cells_row2)],
      }),
      @xml.Node::Element({
        name: name("mergeCells"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("mergeCell"),
            attributes: [{ name: name("ref"), value: "A1:C1" }],
            children: [],
          }),
        ],
      }),
    ],
  })
  // This test exercises gridline behaviour, so force
  // `show_grid_lines: true` — the page-render default is now
  // `false` (see `default_render_options`) so without the override
  // there would be no `<g class="grid-lines">` group to inspect.
  let opts = { ..default_render_options(), show_grid_lines: true }
  let result = render_svg(worksheet, options=opts)
  // §18.3.1.13 spec formula → default col width 8.43 char = 65 px
  // (MDW = 7.7, see `column_max_digit_width_px`).
  // §18.3.1.81 default row height 12.75 pt × 96/72 = 17 px (see
  // `default_render_options` for the reference-tuned default).
  // With 3 columns and 2 rows the boundary verticals sit at
  // x=65 and x=130, and the horizontal mid-line at y=17.
  // Inside the merged area (row 1, y=0..17) the two inner
  // verticals must NOT appear: their only emitted segments must
  // start at y=17 and run to y=34. Outer frame is preserved.
  assert_true(
    !result.svg.contains("<line x1=\"65\" y1=\"0\" x2=\"65\" y2=\"17\""),
  )
  assert_true(
    !result.svg.contains("<line x1=\"130\" y1=\"0\" x2=\"130\" y2=\"17\""),
  )
  assert_true(
    result.svg.contains("<line x1=\"65\" y1=\"17\" x2=\"65\" y2=\"34\""),
  )
  assert_true(
    result.svg.contains("<line x1=\"130\" y1=\"17\" x2=\"130\" y2=\"34\""),
  )
  // Outer frame: 3 columns × 65 = 195 px total.
  assert_true(result.svg.contains("<line x1=\"0\" y1=\"0\" x2=\"0\" y2=\"34\""))
  assert_true(
    result.svg.contains("<line x1=\"195\" y1=\"0\" x2=\"195\" y2=\"34\""),
  )
}

///|
/// §18.3.1.4 / §18.8.4 / §18.8.43 — a cell with `s="0"` referencing
/// `cellXfs[0].borderId=0`, where `borders.border[0]` declares
/// `<left style="thin"><color rgb="FF0000FF"/></left>`, must render
/// a blue thin left edge for that cell.
test "SpreadsheetML viewer resolves cellXfs/borders cascade" {
  let styles_xml : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("borders"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("border"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("left"),
                attributes: [{ name: name("style"), value: "thin" }],
                children: [
                  @xml.Node::Element({
                    name: name("color"),
                    attributes: [{ name: name("rgb"), value: "FF0000FF" }],
                    children: [],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("cellXfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xf"),
            attributes: [
              { name: name("borderId"), value: "0" },
              { name: name("applyBorder"), value: "1" },
            ],
            children: [],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Stylesheet::new(styles_xml)
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [
                  { name: name("r"), value: "A1" },
                  { name: name("s"), value: "0" },
                ],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("1")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  // The left edge of A1 is at x=0, with stroke colour #0000FF.
  // The exact line tag should carry stroke="#0000FF" for the
  // resolved cell.
  assert_true(result.svg.contains("stroke=\"#0000FF\""))
}

///|
/// §18.3.1.4 / §18.8.20 / §18.8.43 — a cell with `s="0"` referencing
/// `cellXfs[0].fillId=1`, where `fills.fill[1]` declares
/// `<patternFill patternType="solid"><fgColor rgb="FFFFFF00"/></patternFill>`,
/// must render a yellow solid background for that cell. fills[0] is
/// the spec-mandated "none" sentinel that Excel always emits.
test "SpreadsheetML viewer resolves cellXfs/fills cascade" {
  let styles_xml : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("fills"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("fill"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("patternFill"),
                attributes: [{ name: name("patternType"), value: "none" }],
                children: [],
              }),
            ],
          }),
          @xml.Node::Element({
            name: name("fill"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("patternFill"),
                attributes: [{ name: name("patternType"), value: "solid" }],
                children: [
                  @xml.Node::Element({
                    name: name("fgColor"),
                    attributes: [{ name: name("rgb"), value: "FFFFFF00" }],
                    children: [],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("cellXfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xf"),
            attributes: [
              { name: name("fillId"), value: "1" },
              { name: name("applyFill"), value: "1" },
            ],
            children: [],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Stylesheet::new(styles_xml)
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [
                  { name: name("r"), value: "A1" },
                  { name: name("s"), value: "0" },
                ],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("1")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  assert_true(result.svg.contains("fill=\"#FFFF00\""))
}

///|
/// §18.3.1.4 / §18.8.22 / §18.8.43 — a cell with `s="0"` referencing
/// `cellXfs[0].fontId=1`, where `fonts.font[1]` declares
/// `<b/>` + `<sz val="14"/>` + `<color rgb="FFFF0000"/>` +
/// `<name val="Arial"/>`, must render text with those properties in
/// the SVG output. Index 0 of fonts is the default font Excel emits.
test "SpreadsheetML viewer resolves cellXfs/fonts cascade" {
  let styles_xml : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("fonts"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("font"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("sz"),
                attributes: [{ name: name("val"), value: "11" }],
                children: [],
              }),
              @xml.Node::Element({
                name: name("name"),
                attributes: [{ name: name("val"), value: "Calibri" }],
                children: [],
              }),
            ],
          }),
          @xml.Node::Element({
            name: name("font"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("b"),
                attributes: [],
                children: [],
              }),
              @xml.Node::Element({
                name: name("sz"),
                attributes: [{ name: name("val"), value: "14" }],
                children: [],
              }),
              @xml.Node::Element({
                name: name("color"),
                attributes: [{ name: name("rgb"), value: "FFFF0000" }],
                children: [],
              }),
              @xml.Node::Element({
                name: name("name"),
                attributes: [{ name: name("val"), value: "Arial" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("cellXfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xf"),
            attributes: [
              { name: name("fontId"), value: "1" },
              { name: name("applyFont"), value: "1" },
            ],
            children: [],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Stylesheet::new(styles_xml)
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [
                  { name: name("r"), value: "A1" },
                  { name: name("s"), value: "0" },
                ],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("X")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  // Font properties from fonts[1] must surface in the text element.
  assert_true(result.svg.contains("font-size=\"14pt\""))
  assert_true(result.svg.contains("font-weight=\"bold\""))
  assert_true(result.svg.contains("fill=\"#FF0000\""))
  assert_true(result.svg.contains("Arial"))
}

///|
/// §18.8.30 — a colour directive in a number-format section
/// (`[Blue]`/`[Red]`) overrides the cell text fill.  The custom
/// numFmt has a positive section `[Blue]0` and a negative section
/// `[Red]\-0`; A1 (positive) must render blue, A2 (negative) red.
test "SpreadsheetML number-format colour bracket sets text fill" {
  let styles_xml : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("numFmts"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("numFmt"),
            attributes: [
              { name: name("numFmtId"), value: "164" },
              { name: name("formatCode"), value: "[Blue]0;[Red]\\-0" },
            ],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("cellXfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xf"),
            attributes: [
              { name: name("numFmtId"), value: "164" },
              { name: name("applyNumberFormat"), value: "1" },
            ],
            children: [],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Stylesheet::new(styles_xml)
  let cell_a1 = @xml.Node::Element({
    name: name("c"),
    attributes: [
      { name: name("r"), value: "A1" },
      { name: name("s"), value: "0" },
    ],
    children: [
      @xml.Node::Element({
        name: name("v"),
        attributes: [],
        children: [@xml.Node::Text("5")],
      }),
    ],
  })
  let cell_a2 = @xml.Node::Element({
    name: name("c"),
    attributes: [
      { name: name("r"), value: "A2" },
      { name: name("s"), value: "0" },
    ],
    children: [
      @xml.Node::Element({
        name: name("v"),
        attributes: [],
        children: [@xml.Node::Text("-7")],
      }),
    ],
  })
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A2" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, [cell_a1]), build_row(2, [cell_a2])],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  // Positive section colour → blue (#0000FF); negative → red.
  assert_true(result.svg.contains("fill=\"#0000FF\""))
  assert_true(result.svg.contains("fill=\"#FF0000\""))
}

///|
/// §18.3.1.73 — `<row s="0">` provides the default cellXfs index
/// for every child `<c>` that omits its own `s`. With cellXfs[0]
/// pointing at fonts[1] (bold), a cell without `s="..."` must
/// render bold via the row-level fallback. A second cell that
/// declares its own `s="0"` is the control — both must end up bold.
test "SpreadsheetML viewer respects row.s row-level style fallback" {
  let styles_xml : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("fonts"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("font"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("sz"),
                attributes: [{ name: name("val"), value: "11" }],
                children: [],
              }),
              @xml.Node::Element({
                name: name("name"),
                attributes: [{ name: name("val"), value: "Calibri" }],
                children: [],
              }),
            ],
          }),
          @xml.Node::Element({
            name: name("font"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("b"),
                attributes: [],
                children: [],
              }),
              @xml.Node::Element({
                name: name("sz"),
                attributes: [{ name: name("val"), value: "11" }],
                children: [],
              }),
              @xml.Node::Element({
                name: name("name"),
                attributes: [{ name: name("val"), value: "Calibri" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("cellXfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xf"),
            attributes: [
              { name: name("fontId"), value: "1" },
              { name: name("applyFont"), value: "1" },
            ],
            children: [],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Stylesheet::new(styles_xml)
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [
              { name: name("r"), value: "1" },
              { name: name("s"), value: "0" },
            ],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [{ name: name("r"), value: "A1" }],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("X")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  assert_true(result.svg.contains("font-weight=\"bold\""))
}

///|
/// §18.3.1.18 / §18.3.1.10 — conditional formatting block with a
/// `cellIs > 100` rule referencing `dxfs[0]` (solid red fill) must
/// turn the matching cells red and leave non-matching cells alone.
test "SpreadsheetML viewer applies §18.3.1.18 cellIs cf overlay" {
  let styles_xml : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dxfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("dxf"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("fill"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("patternFill"),
                    attributes: [{ name: name("patternType"), value: "solid" }],
                    children: [
                      @xml.Node::Element({
                        name: name("fgColor"),
                        attributes: [{ name: name("rgb"), value: "FFFF0000" }],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Stylesheet::new(styles_xml)
  let cell_with = fn(addr : String, value : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("c"),
      attributes: [{ name: name("r"), value: addr }],
      children: [
        @xml.Node::Element({
          name: name("v"),
          attributes: [],
          children: [@xml.Node::Text(value)],
        }),
      ],
    })
  }
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A3" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [cell_with("A1", "50")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "2" }],
            children: [cell_with("A2", "150")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "3" }],
            children: [cell_with("A3", "200")],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("conditionalFormatting"),
        attributes: [{ name: name("sqref"), value: "A1:A3" }],
        children: [
          @xml.Node::Element({
            name: name("cfRule"),
            attributes: [
              { name: name("type"), value: "cellIs" },
              { name: name("operator"), value: "greaterThan" },
              { name: name("dxfId"), value: "0" },
              { name: name("priority"), value: "1" },
            ],
            children: [
              @xml.Node::Element({
                name: name("formula"),
                attributes: [],
                children: [@xml.Node::Text("100")],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  // A2 (150) and A3 (200) match; A1 (50) does not. The red overlay
  // must therefore appear exactly twice.
  inspect(count_fill_red(result.svg), content="2")
}

///|
/// §18.3.1.10 Top10 — `<cfRule type="top10" rank="2">` over a sqref
/// of 4 values selects the top 2 cells. They render with the rule's
/// dxf overlay (solid red); the other 2 do not.
test "SpreadsheetML viewer applies §18.3.1.10 Top10 cf overlay" {
  let styles = cf_styles_with_red_dxf()
  let worksheet = cf_worksheet_a1_a4_values_with_rule([
    @xml.Node::Element({
      name: name("cfRule"),
      attributes: [
        { name: name("type"), value: "top10" },
        { name: name("rank"), value: "2" },
        { name: name("dxfId"), value: "0" },
        { name: name("priority"), value: "1" },
      ],
      children: [],
    }),
  ])
  let result = render_svg(worksheet, styles=Some(styles))
  // Values are 10, 30, 20, 40 → top 2 are A4 (40) and A2 (30).
  // Two cells must therefore render red.
  inspect(count_fill_red(result.svg), content="2")
}

///|
/// §18.3.1.10 AboveAverage — over the same {10, 30, 20, 40}
/// population the mean is 25; cells > 25 (A2=30, A4=40) match.
test "SpreadsheetML viewer applies §18.3.1.10 AboveAverage cf overlay" {
  let styles = cf_styles_with_red_dxf()
  let worksheet = cf_worksheet_a1_a4_values_with_rule([
    @xml.Node::Element({
      name: name("cfRule"),
      attributes: [
        { name: name("type"), value: "aboveAverage" },
        { name: name("dxfId"), value: "0" },
        { name: name("priority"), value: "1" },
        { name: name("aboveAverage"), value: "1" },
      ],
      children: [],
    }),
  ])
  let result = render_svg(worksheet, styles=Some(styles))
  inspect(count_fill_red(result.svg), content="2")
}

///|
/// §18.3.1.10 DuplicateValues — populate A1:A4 with 10/30/30/40 so
/// only the two cells holding "30" must match.
test "SpreadsheetML viewer applies §18.3.1.10 DuplicateValues cf overlay" {
  let styles = cf_styles_with_red_dxf()
  let cell_with = fn(addr : String, value : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("c"),
      attributes: [{ name: name("r"), value: addr }],
      children: [
        @xml.Node::Element({
          name: name("v"),
          attributes: [],
          children: [@xml.Node::Text(value)],
        }),
      ],
    })
  }
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A4" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [cell_with("A1", "10")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "2" }],
            children: [cell_with("A2", "30")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "3" }],
            children: [cell_with("A3", "30")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "4" }],
            children: [cell_with("A4", "40")],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("conditionalFormatting"),
        attributes: [{ name: name("sqref"), value: "A1:A4" }],
        children: [
          @xml.Node::Element({
            name: name("cfRule"),
            attributes: [
              { name: name("type"), value: "duplicateValues" },
              { name: name("dxfId"), value: "0" },
              { name: name("priority"), value: "1" },
            ],
            children: [],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  // Only A2 and A3 carry "30" which appears twice → 2 cells red.
  inspect(count_fill_red(result.svg), content="2")
}

///|
/// §18.3.1.28 dataBar — over the population [10, 30, 20, 40] the
/// cell A4 (=40) sits at ratio 1.0 (full bar) and A1 (=10) at 0.0
/// (no bar). The renderer must emit a `<rect ... fill="#0000FF">`
/// for A4 (full-width minus inset) and none for A1.
test "SpreadsheetML viewer renders §18.3.1.28 dataBar visualisation" {
  let worksheet = cf_worksheet_a1_a4_values_with_rule([
    @xml.Node::Element({
      name: name("cfRule"),
      attributes: [
        { name: name("type"), value: "dataBar" },
        { name: name("priority"), value: "1" },
      ],
      children: [
        @xml.Node::Element({
          name: name("dataBar"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("cfvo"),
              attributes: [{ name: name("type"), value: "min" }],
              children: [],
            }),
            @xml.Node::Element({
              name: name("cfvo"),
              attributes: [{ name: name("type"), value: "max" }],
              children: [],
            }),
            @xml.Node::Element({
              name: name("color"),
              attributes: [{ name: name("rgb"), value: "FF0000FF" }],
              children: [],
            }),
          ],
        }),
      ],
    }),
  ])
  let result = render_svg(worksheet)
  // DataBar emits a blue rect for every cell with ratio > 0 (i.e.
  // values 20/30/40, three out of four). Count occurrences of the
  // bar fill colour.
  inspect(count_fill_color(result.svg, "#0000FF"), content="3")
}

///|
/// §18.3.1.49 iconSet — `<iconSet iconSet="3TrafficLights1">` with
/// 3 cfvo thresholds (min / 33% / 67%) over the population
/// [10, 30, 50] assigns A1→red, A2→yellow, A3→green.
test "SpreadsheetML viewer renders §18.3.1.49 iconSet visualisation" {
  let cell_with = fn(addr : String, value : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("c"),
      attributes: [{ name: name("r"), value: addr }],
      children: [
        @xml.Node::Element({
          name: name("v"),
          attributes: [],
          children: [@xml.Node::Text(value)],
        }),
      ],
    })
  }
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A3" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [cell_with("A1", "10")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "2" }],
            children: [cell_with("A2", "30")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "3" }],
            children: [cell_with("A3", "50")],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("conditionalFormatting"),
        attributes: [{ name: name("sqref"), value: "A1:A3" }],
        children: [
          @xml.Node::Element({
            name: name("cfRule"),
            attributes: [
              { name: name("type"), value: "iconSet" },
              { name: name("priority"), value: "1" },
            ],
            children: [
              @xml.Node::Element({
                name: name("iconSet"),
                attributes: [
                  { name: name("iconSet"), value: "3TrafficLights1" },
                ],
                children: [
                  @xml.Node::Element({
                    name: name("cfvo"),
                    attributes: [
                      { name: name("type"), value: "percent" },
                      { name: name("val"), value: "0" },
                    ],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("cfvo"),
                    attributes: [
                      { name: name("type"), value: "percent" },
                      { name: name("val"), value: "33" },
                    ],
                    children: [],
                  }),
                  @xml.Node::Element({
                    name: name("cfvo"),
                    attributes: [
                      { name: name("type"), value: "percent" },
                      { name: name("val"), value: "67" },
                    ],
                    children: [],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // §18.3.1.49 / §18.18.42 — viewer surfaces the set name and
  // bucket index as spec-anchored metadata; A1=10 maps to bucket 0,
  // A2=30 to bucket 1, A3=50 to bucket 2 against cfvo percent
  // 0/33/67 thresholds (§18.18.13).
  assert_true(result.svg.contains("data-ooxml-icon=\"3TrafficLights1\""))
  assert_true(result.svg.contains("data-ooxml-bucket=\"0\""))
  assert_true(result.svg.contains("data-ooxml-bucket=\"1\""))
  assert_true(result.svg.contains("data-ooxml-bucket=\"2\""))
}

///|
/// §18.3.1.16 colorScale — 2-stop (white at min, red at max) over
/// the population [10, 30, 20, 40] colours A1 white and A4 red.
test "SpreadsheetML viewer renders §18.3.1.16 colorScale visualisation" {
  let worksheet = cf_worksheet_a1_a4_values_with_rule([
    @xml.Node::Element({
      name: name("cfRule"),
      attributes: [
        { name: name("type"), value: "colorScale" },
        { name: name("priority"), value: "1" },
      ],
      children: [
        @xml.Node::Element({
          name: name("colorScale"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("cfvo"),
              attributes: [{ name: name("type"), value: "min" }],
              children: [],
            }),
            @xml.Node::Element({
              name: name("cfvo"),
              attributes: [{ name: name("type"), value: "max" }],
              children: [],
            }),
            @xml.Node::Element({
              name: name("color"),
              attributes: [{ name: name("rgb"), value: "FFFFFFFF" }],
              children: [],
            }),
            @xml.Node::Element({
              name: name("color"),
              attributes: [{ name: name("rgb"), value: "FFFF0000" }],
              children: [],
            }),
          ],
        }),
      ],
    }),
  ])
  let result = render_svg(worksheet)
  // A1=10 maps to white (#FFFFFF), A4=40 maps to red (#FF0000).
  // Intermediate cells produce blended colours that aren't tested
  // here; we just assert the endpoints land on the expected hex.
  assert_true(result.svg.contains("fill=\"#FFFFFF\""))
  assert_true(result.svg.contains("fill=\"#FF0000\""))
}

///|
/// Helper — count non-overlapping occurrences of `fill="<color>"`.
fn count_fill_color(haystack : String, color : String) -> Int {
  let needle = "fill=\"" + color + "\""
  let mut count = 0
  let mut i = 0
  while i + needle.length() <= haystack.length() {
    let mut matched = true
    for j in 0..<needle.length() {
      if haystack.code_unit_at(i + j) != needle.code_unit_at(j) {
        matched = false
        break
      }
    }
    if matched {
      count = count + 1
      i = i + needle.length()
    } else {
      i = i + 1
    }
  }
  count
}

///|
/// Helper — build a CT_Stylesheet whose dxfs[0] is a solid red fill.
fn cf_styles_with_red_dxf() -> @domain.CT_Stylesheet {
  @domain.CT_Stylesheet::new({
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dxfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("dxf"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("fill"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("patternFill"),
                    attributes: [{ name: name("patternType"), value: "solid" }],
                    children: [
                      @xml.Node::Element({
                        name: name("fgColor"),
                        attributes: [{ name: name("rgb"), value: "FFFF0000" }],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
}

///|
/// Helper — A1:A4 with values 10/30/20/40 and one custom cfRule.
fn cf_worksheet_a1_a4_values_with_rule(
  cf_rule_children : Array[@xml.Node],
) -> @domain.CT_Worksheet raise {
  let cell_with = fn(addr : String, value : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("c"),
      attributes: [{ name: name("r"), value: addr }],
      children: [
        @xml.Node::Element({
          name: name("v"),
          attributes: [],
          children: [@xml.Node::Text(value)],
        }),
      ],
    })
  }
  @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A4" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [cell_with("A1", "10")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "2" }],
            children: [cell_with("A2", "30")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "3" }],
            children: [cell_with("A3", "20")],
          }),
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "4" }],
            children: [cell_with("A4", "40")],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("conditionalFormatting"),
        attributes: [{ name: name("sqref"), value: "A1:A4" }],
        children: cf_rule_children,
      }),
    ],
  })
}

///|
/// Helper — count non-overlapping occurrences of `fill="#FF0000"`.
fn count_fill_red(haystack : String) -> Int {
  let needle = "fill=\"#FF0000\""
  let mut count = 0
  let mut i = 0
  while i + needle.length() <= haystack.length() {
    let mut matched = true
    for j in 0..<needle.length() {
      if haystack.code_unit_at(i + j) != needle.code_unit_at(j) {
        matched = false
        break
      }
    }
    if matched {
      count = count + 1
      i = i + needle.length()
    } else {
      i = i + 1
    }
  }
  count
}

///|
/// §18.3.1.13 — `<col style="0">` provides the default cellXfs
/// index for every cell in the range that omits both its own `s`
/// and a row-level `s`. With cellXfs[0].fontId=1 (bold), a bare
/// `<c>` under a `<col style="0">` range must render bold.
test "SpreadsheetML viewer respects <col style> column-level fallback" {
  let styles_xml : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("fonts"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("font"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("sz"),
                attributes: [{ name: name("val"), value: "11" }],
                children: [],
              }),
              @xml.Node::Element({
                name: name("name"),
                attributes: [{ name: name("val"), value: "Calibri" }],
                children: [],
              }),
            ],
          }),
          @xml.Node::Element({
            name: name("font"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("b"),
                attributes: [],
                children: [],
              }),
              @xml.Node::Element({
                name: name("sz"),
                attributes: [{ name: name("val"), value: "11" }],
                children: [],
              }),
              @xml.Node::Element({
                name: name("name"),
                attributes: [{ name: name("val"), value: "Calibri" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("cellXfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xf"),
            attributes: [
              { name: name("fontId"), value: "1" },
              { name: name("applyFont"), value: "1" },
            ],
            children: [],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Stylesheet::new(styles_xml)
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("cols"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("col"),
            attributes: [
              { name: name("min"), value: "1" },
              { name: name("max"), value: "1" },
              { name: name("style"), value: "0" },
            ],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [{ name: name("r"), value: "A1" }],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("X")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  assert_true(result.svg.contains("font-weight=\"bold\""))
}

///|
test "SpreadsheetML SVG renderer formats general numbers correctly" {
  // Integers render without decimal, floats keep their formatting.
  inspect(format_general(0.0), content="0")
  inspect(format_general(42.0), content="42")
  inspect(format_general(-3.5), content="-3.5")
  inspect(format_general(1000.0), content="1000")
}

///|
/// §18.8.30 — exercise the format-code grammar across the common
/// patterns. The minimal new path supports digit placeholders (`0` /
/// `#`), decimal point, thousands separator, percent, prefix /
/// suffix literals, and three-section pos/neg/zero dispatch.
test "SpreadsheetML viewer resolves cellXfs/numFmts cascade" {
  // styles = { numFmts: [], cellXfs: [{numFmtId: 2}] } — id 2 is
  // builtin "0.00", so the cell's numeric value 12.345 should
  // render as "12.35" via format_number_by_code.
  let styles_xml : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cellXfs"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xf"),
            attributes: [
              { name: name("numFmtId"), value: "2" },
              { name: name("applyNumberFormat"), value: "1" },
            ],
            children: [],
          }),
        ],
      }),
    ],
  }
  let styles = @domain.CT_Stylesheet::new(styles_xml)
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [
                  { name: name("r"), value: "A1" },
                  { name: name("s"), value: "0" },
                ],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("12.345")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(styles))
  // Builtin id 2 is "0.00" → 12.345 rounds to 12.35.
  assert_true(result.svg.contains("12.35"))
}

///|
test "SpreadsheetML number format codes" {
  // Zero padding — integer placeholder count drives left padding.
  inspect(format_number_by_code(7.0, "000"), content="007")
  // Fixed decimal places.
  inspect(format_number_by_code(3.14159, "0.00"), content="3.14")
  inspect(format_number_by_code(0.5, "0.000"), content="0.500")
  // Thousands separator + decimal.
  inspect(format_number_by_code(1234567.89, "#,##0.00"), content="1,234,567.89")
  // Percent multiplies the source value by 100 then suffixes `%`.
  inspect(format_number_by_code(0.25, "0%"), content="25%")
  inspect(format_number_by_code(0.07, "0.00%"), content="7.00%")
  // Three-section: positive / negative / zero.
  inspect(format_number_by_code(5.0, "0;-0;\"zero\""), content="5")
  inspect(format_number_by_code(-5.0, "0;-0;\"zero\""), content="-5")
  inspect(format_number_by_code(0.0, "0;-0;\"zero\""), content="zero")
}

///|
test "SpreadsheetML scientific-notation format codes (§18.8.30)" {
  // numFmt 11 — `0.00E+00`: ordinary scientific notation, group of
  // one integer digit, exponent always signed and 2-digit padded.
  inspect(format_number_by_code(12345.0, "0.00E+00"), content="1.23E+04")
  inspect(format_number_by_code(0.000123, "0.00E+00"), content="1.23E-04")
  inspect(format_number_by_code(1000000.0, "0.00E+00"), content="1.00E+06")
  // Carry across the rounding boundary: 9.999e3 → 1.00e4.
  inspect(format_number_by_code(9999.0, "0.00E+00"), content="1.00E+04")
  // numFmt 48 — `##0.0E+0`: engineering notation, exponent forced
  // to a multiple of 3, mantissa carries 1..3 integer digits.
  inspect(format_number_by_code(12345.0, "##0.0E+0"), content="12.3E+3")
  inspect(format_number_by_code(123456.0, "##0.0E+0"), content="123.5E+3")
  inspect(format_number_by_code(1234.0, "##0.0E+0"), content="1.2E+3")
  // `E-` shows the sign only for negative exponents.
  inspect(format_number_by_code(123.0, "0.0E-0"), content="1.2E2")
  inspect(format_number_by_code(0.012, "0.0E-0"), content="1.2E-2")
}

///|
test "SpreadsheetML SVG renderer parses col / row attributes" {
  // Custom column width and row height should propagate into the layout.
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("cols"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("col"),
            attributes: [
              { name: name("min"), value: "1" },
              { name: name("max"), value: "1" },
              { name: name("width"), value: "20" },
            ],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [
              { name: name("r"), value: "1" },
              // §18.3.1.73 — `ht` is honoured whenever it is
              // present; the companion `customHeight` is a hint
              // (true = user-set, false = auto) and does NOT gate
              // application of `ht`.
              { name: name("ht"), value: "30" },
            ],
            children: [build_cell("A1", None, "5")],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // §18.3.1.13 spec formula —
  //   Truncate(((256*20 + Trunc(128/7.7))/256)*7.7)
  // = Truncate(((5120+16)/256)*7.7)
  // = Truncate(20.0625*7.7) = Truncate(154.48) = 154 px body width
  // (MDW = 7.7, see `column_max_digit_width_px`).
  // 30 pt * 4/3 = 40 px body height (explicit `ht`, not default).
  // §18.3.1.62 — page size = body + print-default margins
  // (2.0 cm = 75.59055 px L/R, 2.5 cm = 94.48819 px T/B).
  //   width  = 154 + 2*75.59055 ≈ 305.181
  //   height =  40 + 2*94.48819 ≈ 228.976
  inspect(
    result.width,
    content=(
      #|305.1811023622047
    ),
  )
  inspect(
    result.height,
    content=(
      #|228.9763779527559
    ),
  )
}

///|
/// §20.5.2.34 — a `<xdr:twoCellAnchor>` carrying a `<xdr:pic>` is
/// rendered as a positioned `<g class="drawing">` group inside the
/// SVG output. Mirrors web-pptx renderAllDrawings (drawing-renderer.ts).
test "SpreadsheetML viewer emits drawing anchor as labelled group" {
  // Minimal worksheet — a single cell A1 so the layout has a non-zero
  // grid (the empty-sheet placeholder skips drawing rendering).
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [{ name: name("r"), value: "A1" }],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("1")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  // Construct a typed wsDr with one two-cell-anchored shape spanning
  // approximately the cell A1..C3 (using zero offsets for simplicity).
  let marker_from : @xml.Element = {
    name: name("from"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("col"),
        attributes: [],
        children: [@xml.Node::Text("0")],
      }),
      @xml.Node::Element({
        name: name("colOff"),
        attributes: [],
        children: [@xml.Node::Text("0")],
      }),
      @xml.Node::Element({
        name: name("row"),
        attributes: [],
        children: [@xml.Node::Text("0")],
      }),
      @xml.Node::Element({
        name: name("rowOff"),
        attributes: [],
        children: [@xml.Node::Text("0")],
      }),
    ],
  }
  let marker_to : @xml.Element = {
    name: name("to"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("col"),
        attributes: [],
        children: [@xml.Node::Text("2")],
      }),
      @xml.Node::Element({
        name: name("colOff"),
        attributes: [],
        children: [@xml.Node::Text("0")],
      }),
      @xml.Node::Element({
        name: name("row"),
        attributes: [],
        children: [@xml.Node::Text("2")],
      }),
      @xml.Node::Element({
        name: name("rowOff"),
        attributes: [],
        children: [@xml.Node::Text("0")],
      }),
    ],
  }
  // Minimal `<xdr:sp>` carrying the required `<xdr:nvSpPr>` /
  // `<xdr:spPr>` skeleton plus a `<xdr:txBody>` so the typed reader
  // accepts the shape.
  let sp : @xml.Element = {
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("nvSpPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("cNvPr"),
            attributes: [
              { name: name("id"), value: "2" },
              { name: name("name"), value: "Rect" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("cNvSpPr"),
            attributes: [],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({ name: name("spPr"), attributes: [], children: [] }),
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bodyPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("lstStyle"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({ name: name("p"), attributes: [], children: [] }),
        ],
      }),
    ],
  }
  let two_cell_anchor : @xml.Element = {
    name: name("twoCellAnchor"),
    attributes: [],
    children: [
      @xml.Node::Element(marker_from),
      @xml.Node::Element(marker_to),
      @xml.Node::Element(sp),
      @xml.Node::Element({
        name: name("clientData"),
        attributes: [],
        children: [],
      }),
    ],
  }
  let ws_dr = try? @drawing.CT_Drawing::new({
    name: name("wsDr"),
    attributes: [],
    children: [@xml.Node::Element(two_cell_anchor)],
  })
  let ws_dr_ok = match ws_dr {
    Ok(d) => d
    Err(_) => abort("wsDr construction failed")
  }
  let result = render_svg(worksheet, drawing=Some(ws_dr_ok))
  // The renderer wraps every drawing anchor in `<g class="drawing">`
  // and surfaces the choice arm label ("Shape" for `<xdr:sp>`).
  assert_true(result.svg.contains("<g class=\"drawings\">"))
  assert_true(result.svg.contains("<g class=\"drawing\""))
  assert_true(result.svg.contains("[Shape]"))
}

///|
/// §20.5.2.25 — a `<xdr:pic>` whose embedded blip resolves through the
/// supplied `image_resolver` is rendered as an `<image>` element rather
/// than the labelled placeholder. Mirrors web-pptx renderPicture.
test "SpreadsheetML viewer emits <image> for resolved <xdr:pic>" {
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [{ name: name("r"), value: "A1" }],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("1")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  // Two-cell-anchor + xdr:pic with blipFill referencing rId8.
  let marker = fn(tag : String, col : String, row : String) -> @xml.Element {
    {
      name: name(tag),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("col"),
          attributes: [],
          children: [@xml.Node::Text(col)],
        }),
        @xml.Node::Element({
          name: name("colOff"),
          attributes: [],
          children: [@xml.Node::Text("0")],
        }),
        @xml.Node::Element({
          name: name("row"),
          attributes: [],
          children: [@xml.Node::Text(row)],
        }),
        @xml.Node::Element({
          name: name("rowOff"),
          attributes: [],
          children: [@xml.Node::Text("0")],
        }),
      ],
    }
  }
  let pic : @xml.Element = {
    name: name("pic"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("nvPicPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("cNvPr"),
            attributes: [
              { name: name("id"), value: "1" },
              { name: name("name"), value: "Pic" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("cNvPicPr"),
            attributes: [],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("blipFill"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("blip"),
            attributes: [{ name: name("embed"), value: "rId8" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({ name: name("spPr"), attributes: [], children: [] }),
    ],
  }
  let two_cell : @xml.Element = {
    name: name("twoCellAnchor"),
    attributes: [],
    children: [
      @xml.Node::Element(marker("from", "0", "0")),
      @xml.Node::Element(marker("to", "2", "2")),
      @xml.Node::Element(pic),
      @xml.Node::Element({
        name: name("clientData"),
        attributes: [],
        children: [],
      }),
    ],
  }
  let ws_dr = try? @drawing.CT_Drawing::new({
    name: name("wsDr"),
    attributes: [],
    children: [@xml.Node::Element(two_cell)],
  })
  let ws_dr_ok = match ws_dr {
    Ok(d) => d
    Err(_) => abort("wsDr construction failed")
  }
  let resolver = fn(rid : String) -> String? {
    if rid == "rId8" {
      Some("data:image/png;base64,XYZ")
    } else {
      None
    }
  }
  let result = render_svg(
    worksheet,
    drawing=Some(ws_dr_ok),
    image_resolver=resolver,
  )
  assert_true(result.svg.contains("href=\"data:image/png;base64,XYZ\""))
}

///|
/// §20.5.2.30 — an `<xdr:sp>` carrying `<a:prstGeom prst="ellipse">`
/// renders as a typed `<path>` rather than the labelled placeholder
/// rect. Mirrors web-pptx renderShape behaviour (xlsx drawing
/// shape-renderer).
test "SpreadsheetML viewer emits <path> for <xdr:sp> preset geometry" {
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [{ name: name("r"), value: "A1" }],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("1")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let marker_fn = fn(tag : String, col : String, row : String) -> @xml.Element {
    {
      name: name(tag),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("col"),
          attributes: [],
          children: [@xml.Node::Text(col)],
        }),
        @xml.Node::Element({
          name: name("colOff"),
          attributes: [],
          children: [@xml.Node::Text("0")],
        }),
        @xml.Node::Element({
          name: name("row"),
          attributes: [],
          children: [@xml.Node::Text(row)],
        }),
        @xml.Node::Element({
          name: name("rowOff"),
          attributes: [],
          children: [@xml.Node::Text("0")],
        }),
      ],
    }
  }
  // Shape with `<a:prstGeom prst="ellipse">` so the typed path
  // dispatch emits the elliptic arc commands rather than a rect.
  let sp : @xml.Element = {
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("nvSpPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("cNvPr"),
            attributes: [
              { name: name("id"), value: "2" },
              { name: name("name"), value: "Oval" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("cNvSpPr"),
            attributes: [],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("prstGeom"),
            attributes: [{ name: name("prst"), value: "ellipse" }],
            children: [],
          }),
          @xml.Node::Element({
            name: name("solidFill"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("srgbClr"),
                attributes: [{ name: name("val"), value: "FF0000" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bodyPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("lstStyle"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({ name: name("p"), attributes: [], children: [] }),
        ],
      }),
    ],
  }
  let two_cell : @xml.Element = {
    name: name("twoCellAnchor"),
    attributes: [],
    children: [
      @xml.Node::Element(marker_fn("from", "0", "0")),
      @xml.Node::Element(marker_fn("to", "2", "2")),
      @xml.Node::Element(sp),
      @xml.Node::Element({
        name: name("clientData"),
        attributes: [],
        children: [],
      }),
    ],
  }
  let ws_dr = try? @drawing.CT_Drawing::new({
    name: name("wsDr"),
    attributes: [],
    children: [@xml.Node::Element(two_cell)],
  })
  let ws_dr_ok = match ws_dr {
    Ok(d) => d
    Err(_) => abort("wsDr construction failed")
  }
  let result = render_svg(worksheet, drawing=Some(ws_dr_ok))
  // Typed shape renderer emits `<g class="shape"><path d="…"` and the
  // solidFill resolves to the lowercase hex literal.
  assert_true(result.svg.contains("<g class=\"shape\">"))
  assert_true(result.svg.contains("<path d=\""))
  assert_true(result.svg.contains("fill=\"#ff0000\""))
  // The placeholder label "[Shape]" must not appear because the typed
  // path supersedes the placeholder rect.
  assert_false(result.svg.contains("[Shape]"))
}

///|
/// §18.8.3 — end-to-end: when render_svg receives a `theme=Some(t)`
/// and a cell carries a styled colour via cellXfs → fonts.color
/// with `@theme="4"` (accent1), the rendered SVG MUST contain the
/// resolved sRGB hex from the theme's clrScheme.
test "render_svg resolves cell font color through theme cascade" {
  // Theme XML: <a:theme>/<a:themeElements>/<a:clrScheme>
  // with lt1/dk1/lt2/dk2/accent1.  parse_sml_clr_scheme indexes
  // accent1 at slot 4 (the §20.1.4.1.6 ordering).
  let mk_color_slot = fn(local : String, hex : String) -> @xml.Element {
    let srgb : @xml.Element = {
      name: name("srgbClr"),
      attributes: [{ name: name("val"), value: hex }],
      children: [],
    }
    { name: name(local), attributes: [], children: [@xml.Node::Element(srgb)] }
  }
  let scheme : @xml.Element = {
    name: name("clrScheme"),
    attributes: [{ name: name("name"), value: "Test" }],
    children: [
      @xml.Node::Element(mk_color_slot("lt1", "FFFFFF")),
      @xml.Node::Element(mk_color_slot("dk1", "000000")),
      @xml.Node::Element(mk_color_slot("lt2", "E7E6E6")),
      @xml.Node::Element(mk_color_slot("dk2", "44546A")),
      @xml.Node::Element(mk_color_slot("accent1", "4472C4")),
    ],
  }
  let theme_elts : @xml.Element = {
    name: name("themeElements"),
    attributes: [],
    children: [@xml.Node::Element(scheme)],
  }
  let theme : @xml.Element = {
    name: name("theme"),
    attributes: [],
    children: [@xml.Node::Element(theme_elts)],
  }
  // Styles: cellXfs[0].fontId=0 → fonts.font[0] with
  // <color theme="4"/> (accent1).
  let color_el : @xml.Element = {
    name: name("color"),
    attributes: [{ name: name("theme"), value: "4" }],
    children: [],
  }
  let font_el : @xml.Element = {
    name: name("font"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sz"),
        attributes: [{ name: name("val"), value: "11" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("name"),
        attributes: [{ name: name("val"), value: "Calibri" }],
        children: [],
      }),
      @xml.Node::Element(color_el),
    ],
  }
  let fonts_el : @xml.Element = {
    name: name("fonts"),
    attributes: [{ name: name("count"), value: "1" }],
    children: [@xml.Node::Element(font_el)],
  }
  let xf_el : @xml.Element = {
    name: name("xf"),
    attributes: [
      { name: name("fontId"), value: "0" },
      { name: name("applyFont"), value: "1" },
    ],
    children: [],
  }
  let cell_xfs_el : @xml.Element = {
    name: name("cellXfs"),
    attributes: [{ name: name("count"), value: "1" }],
    children: [@xml.Node::Element(xf_el)],
  }
  let stylesheet_el : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [@xml.Node::Element(fonts_el), @xml.Node::Element(cell_xfs_el)],
  }
  let stylesheet = try? @domain.CT_Stylesheet::new(stylesheet_el)
  let styles_ok = match stylesheet {
    Ok(s) => s
    Err(_) => abort("stylesheet construction failed")
  }
  // Worksheet with one cell <c r="A1" s="0" t="n"><v>42</v></c>.
  let cell : @xml.Element = {
    name: name("c"),
    attributes: [
      { name: name("r"), value: "A1" },
      { name: name("s"), value: "0" },
      { name: name("t"), value: "n" },
    ],
    children: [
      @xml.Node::Element({
        name: name("v"),
        attributes: [],
        children: [@xml.Node::Text("42")],
      }),
    ],
  }
  let row : @xml.Element = {
    name: name("row"),
    attributes: [{ name: name("r"), value: "1" }],
    children: [@xml.Node::Element(cell)],
  }
  let sheet_data : @xml.Element = {
    name: name("sheetData"),
    attributes: [],
    children: [@xml.Node::Element(row)],
  }
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [@xml.Node::Element(sheet_data)],
  })
  let result = render_svg(worksheet, styles=Some(styles_ok), theme=Some(theme))
  // The cell's text fill must carry the resolved accent1 hex.
  assert_true(result.svg.contains("#4472c4"))
}

///|
/// §18.3.1.87 `<sheetViews>/<sheetView @showGridLines="0">` — when
/// the per-sheet view turns gridlines off, the SVG renderer MUST
/// omit the `<g class="grid-lines">` group, even when the caller
/// has forced `SheetRenderOptions.show_grid_lines = true` (the
/// screen-style branch).  An explicit editor "false" is treated as
/// a hard "user wants no gridlines anywhere" signal — the
/// historical hide-gridlines contract consumers depend on.  We
/// force `show_grid_lines: true` so the assertion is meaningful;
/// with the page-render default (false) gridlines would be off
/// regardless and the test would pass trivially.
test "SpreadsheetML viewer §18.3.1.87 showGridLines=\"0\" omits grid-lines group" {
  let sheet_view : @xml.Node = @xml.Node::Element({
    name: name("sheetView"),
    attributes: [
      { name: name("workbookViewId"), value: "0" },
      { name: name("showGridLines"), value: "0" },
    ],
    children: [],
  })
  let sheet_views : @xml.Node = @xml.Node::Element({
    name: name("sheetViews"),
    attributes: [],
    children: [sheet_view],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      sheet_views,
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  // Force `show_grid_lines: true` to mimic a screen-style caller
  // (default options would NOT render gridlines on a page render).
  let opts = { ..default_render_options(), show_grid_lines: true }
  let result = render_svg(worksheet, options=opts)
  assert_false(result.svg.contains("class=\"grid-lines\""))
  // Cell content is still emitted normally.
  assert_true(result.svg.contains("data-ooxml=\"sml\""))
  assert_true(result.svg.contains("class=\"cell-text\""))
}

///|
/// §18.3.1.70 `<printOptions @gridLines="1">` — when the worksheet
/// opts in to printed gridlines, the SVG (page) renderer MUST emit
/// the `<g class="grid-lines">` group, overriding the
/// `SheetRenderOptions.show_grid_lines` default of `false`.  This
/// is the print-side counterpart to §18.3.1.87 `@showGridLines`:
/// the editing-view toggle defaults true but is irrelevant to a
/// print render; the print toggle defaults false and is what the
/// reference PDF export consults.
test "SpreadsheetML viewer §18.3.1.70 printOptions gridLines enables grid-lines" {
  let print_options : @xml.Node = @xml.Node::Element({
    name: name("printOptions"),
    attributes: [{ name: name("gridLines"), value: "1" }],
    children: [],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
      print_options,
    ],
  })
  // Default options — `show_grid_lines: false`.  Only the
  // `<printOptions @gridLines="1">` flag should turn them on.
  let result = render_svg(worksheet)
  assert_true(result.svg.contains("class=\"grid-lines\""))
}

///|
/// §18.3.1.70 / §18.3.1.87 — a worksheet whose `<sheetView>` has
/// NO `@showGridLines` attribute (so the editing-UI default of
/// `true` would apply for screen rendering) and NO `<printOptions
/// @gridLines>` MUST render gridline-free on the page renderer.
/// The reference PDF export behaves identically: the screen
/// default does not propagate into the print pipeline.  This is
/// the dual of the "showGridLines=0" test above and locks in the
/// page-render default flipped in this commit (was true).
test "SpreadsheetML viewer §18.3.1.70 absent printOptions gridLines omits grid-lines" {
  let sheet_view : @xml.Node = @xml.Node::Element({
    name: name("sheetView"),
    attributes: [{ name: name("workbookViewId"), value: "0" }],
    children: [],
  })
  let sheet_views : @xml.Node = @xml.Node::Element({
    name: name("sheetViews"),
    attributes: [],
    children: [sheet_view],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      sheet_views,
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  let result = render_svg(worksheet)
  assert_false(result.svg.contains("class=\"grid-lines\""))
}

///|
/// §18.8.30 — `[Red]`/`[Blue]`/conditional/locale brackets MUST NOT
/// appear in the visible cell text; they are format directives.
/// §18.8.31 — `_x` MUST render as a single space; `*x` MUST NOT
/// surface the literal `*` or the trailing fill glyph (without
/// column-width context this layer emits zero repetitions, the
/// only spec-conformant choice without metrics).
test "SpreadsheetML §18.8.30 brackets dropped from formatted output" {
  // Positive section uses `_)` for negative-paren alignment per
  // the canonical builtin §18.8.30 numFmtId 8 accounting code.
  inspect(
    format_number_general(1234.5, "[Red]#,##0.00_);[Blue](#,##0.00)"),
    content="1,234.50 ",
  )
  // Negative routes to the second section, with its leading `(`
  // literal copied through and `[Blue]` directive dropped.
  inspect(
    format_number_general(-1234.5, "[Red]#,##0.00_);[Blue](#,##0.00)"),
    content="(1,234.50)",
  )
  // `*0` in the standalone format MUST NOT surface a literal `*` —
  // zero repetitions when no column-width metric is available.
  inspect(format_number_general(7.0, "0*0"), content="7")
  // `[$$-409]` locale-bracketed currency token is a directive and
  // is dropped; the visible currency literal stays via the
  // `"$"` quoted form.
  inspect(format_number_general(7.0, "[$$-409]\"$\"#,##0"), content="$7")
}

///|
/// §18.8.31 — elapsed-time brackets `[h]`, `[m]`, `[s]` MUST emit
/// the cumulative count (NOT the wall-clock component), with the
/// run length inside the bracket as the zero-pad width.  Test
/// fixtures use a serial of exactly `1.5` days = 36 hours = 2160
/// minutes = 129 600 seconds.
test "SpreadsheetML §18.8.31 elapsed-time brackets emit cumulative count" {
  // 1.5 days = 36 hours.
  inspect(format_number_general(1.5, "[h]"), content="36")
  // 1.5 days = 2160 minutes.
  inspect(format_number_general(1.5, "[m]"), content="2160")
  // 1.5 days = 129600 seconds.
  inspect(format_number_general(1.5, "[s]"), content="129600")
  // Run length is the pad width: `[hh]` pads "36" to width 2 (no-op);
  // `[hhhh]` pads to width 4.
  inspect(format_number_general(1.5, "[hhhh]"), content="0036")
  // Builtin numFmtId 46 = `[h]:mm:ss`.  serial 1.5 = 36 cumulative
  // hours; `mm` after `h` MUST be minute (not month) per §18.8.30.
  inspect(format_number_general(1.5, "[h]:mm:ss"), content="36:00:00")
  // §18.8.30 m-vs-month disambiguation — `m` before `s` is also
  // minute (without an `h` token), distinguishing it from a bare
  // `mm` month token.  serial 0.5 = noon; minute=0.
  inspect(format_number_general(0.5, "mm:ss"), content="00:00")
  // §18.8.30 bare `mm` (no surrounding hour or second) MUST be
  // month.  serial 33 corresponds to early February in the
  // implementation's 1900 date system, so month component = 02.
  inspect(format_number_general(33.0, "mm"), content="02")
}

///|
/// §18.17.4.1 — when the cell carries `t="d"` (ISO 8601 date
/// literal in `<v>`), the renderer MUST apply the resolved
/// numFmt format code rather than emitting the raw ISO string.
/// Directly drives `format_number_general` since the SVG render
/// path's style resolution requires a styles part.
test "SpreadsheetML §18.17.4.1 t=\"d\" cell parses ISO 8601 and applies numFmt" {
  // Parse 2024-03-15T00:00:00 → CalendarDateTime → serial.
  // serial = 45000 in our 1900 date system (Excel = 45366; the
  // off-by-one Lotus 1900 leap bug is documented elsewhere).
  let dt = match parse_iso8601_date("2024-03-15T00:00:00") {
    Some(v) => v
    None => abort("failed to parse ISO 8601")
  }
  assert_eq(dt.year, 2024)
  assert_eq(dt.month, 3)
  assert_eq(dt.day, 15)
  assert_eq(dt.hour, 0)
  assert_eq(dt.minute, 0)
  assert_eq(dt.second, 0)
  // Round-trip via serial and apply `yyyy-mm-dd` format code.
  let serial = try? @date_serial.date_time_to_serial(
    dt,
    @date_serial.DateSystem::Serial1900,
  )
  match serial {
    Ok(s) => {
      // `yyyy-mm-dd` MUST produce "2024-03-15".
      let formatted = format_number_general(s, "yyyy-mm-dd")
      assert_eq(formatted, "2024-03-15")
      // `dd/mm/yyyy` MUST produce "15/03/2024".
      let formatted_eu = format_number_general(s, "dd/mm/yyyy")
      assert_eq(formatted_eu, "15/03/2024")
    }
    Err(_) => abort("date_time_to_serial failed")
  }
}

///|
/// §18.17.4.1 — fractional-second precision (.fff).
test "SpreadsheetML §18.17.4.1 parse_iso8601_date handles fractional seconds" {
  let dt = match parse_iso8601_date("2024-01-01T12:34:56.789") {
    Some(v) => v
    None => abort("failed to parse ISO 8601 with millis")
  }
  assert_eq(dt.hour, 12)
  assert_eq(dt.minute, 34)
  assert_eq(dt.second, 56)
  assert_eq(dt.millisecond, 789)
  // Six-digit fractional → truncate to three.
  let dt2 = match parse_iso8601_date("2024-01-01T00:00:00.123456") {
    Some(v) => v
    None => abort("failed to parse ISO 8601 with 6-digit frac")
  }
  assert_eq(dt2.millisecond, 123)
}

///|
/// §18.17.4.1 — date-only form (YYYY-MM-DD) is also accepted.
test "SpreadsheetML §18.17.4.1 parse_iso8601_date handles date-only form" {
  let dt = match parse_iso8601_date("2024-05-21") {
    Some(v) => v
    None => abort("failed to parse date-only form")
  }
  assert_eq(dt.year, 2024)
  assert_eq(dt.month, 5)
  assert_eq(dt.day, 21)
  assert_eq(dt.hour, 0)
}

///|
/// §18.3.1.65 `<sheetViews>/<sheetView>/<pane>` — when a worksheet
/// carries a freeze pane, the SVG renderer MUST surface the pane
/// state as `data-ooxml-pane-*` attributes on the `<svg>` root
/// and emit a visible split line `<g class="pane-splits">` at
/// the corresponding pixel coordinate.
test "SpreadsheetML viewer §18.3.1.65 frozen pane surfaces metadata and split line" {
  // <pane xSplit="1" ySplit="2" state="frozen" topLeftCell="B3" activePane="bottomRight"/>
  let pane : @xml.Node = @xml.Node::Element({
    name: name("pane"),
    attributes: [
      { name: name("xSplit"), value: "1" },
      { name: name("ySplit"), value: "2" },
      { name: name("state"), value: "frozen" },
      { name: name("topLeftCell"), value: "B3" },
      { name: name("activePane"), value: "bottomRight" },
    ],
    children: [],
  })
  let sheet_view : @xml.Node = @xml.Node::Element({
    name: name("sheetView"),
    attributes: [{ name: name("workbookViewId"), value: "0" }],
    children: [pane],
  })
  let sheet_views : @xml.Node = @xml.Node::Element({
    name: name("sheetViews"),
    attributes: [],
    children: [sheet_view],
  })
  let cells_row1 : Array[@xml.Node] = [
    build_cell("A1", None, "1"),
    build_cell("B1", None, "2"),
  ]
  let cells_row2 : Array[@xml.Node] = [
    build_cell("A2", None, "3"),
    build_cell("B2", None, "4"),
  ]
  let cells_row3 : Array[@xml.Node] = [
    build_cell("A3", None, "5"),
    build_cell("B3", None, "6"),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:B3" }],
        children: [],
      }),
      sheet_views,
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          build_row(1, cells_row1),
          build_row(2, cells_row2),
          build_row(3, cells_row3),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // Pane metadata on the root <svg>.
  assert_true(result.svg.contains("data-ooxml-pane-x-split=\"1\""))
  assert_true(result.svg.contains("data-ooxml-pane-y-split=\"2\""))
  assert_true(result.svg.contains("data-ooxml-pane-state=\"frozen\""))
  assert_true(result.svg.contains("data-ooxml-pane-active=\"bottomRight\""))
  assert_true(result.svg.contains("data-ooxml-pane-top-left=\"B3\""))
  // The visual split line group.
  assert_true(result.svg.contains("class=\"pane-splits\""))
  // Vertical split (xSplit=1, after column A).
  assert_true(result.svg.contains("data-ooxml-split=\"x\""))
  // Horizontal split (ySplit=2, after row 2).
  assert_true(result.svg.contains("data-ooxml-split=\"y\""))
}

///|
/// §18.3.1.65 — when no `<pane>` is present, no pane-* attrs or
/// split lines appear.
test "SpreadsheetML viewer §18.3.1.65 absent pane emits no pane attrs" {
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  let result = render_svg(worksheet)
  assert_false(result.svg.contains("data-ooxml-pane"))
  assert_false(result.svg.contains("class=\"pane-splits\""))
}

///|
/// §18.3.1.45 `<hyperlinks>/<hyperlink ref="A1" r:id="…">` — the SVG
/// renderer MUST emit a `<g class="hyperlinks">` group containing
/// a transparent `<rect>` hit-area per hyperlinked cell, with the
/// spec attributes surfaced as `data-ooxml-hyperlink-*`.
test "SpreadsheetML viewer §18.3.1.45 hyperlink emits hit-area with data-ooxml-hyperlink-*" {
  let hyperlink : @xml.Node = @xml.Node::Element({
    name: name("hyperlink"),
    attributes: [
      { name: name("ref"), value: "A1" },
      { name: name("id"), value: "rId1" },
      { name: name("location"), value: "Sheet1!B2" },
      { name: name("tooltip"), value: "Go to B2" },
      { name: name("display"), value: "Click me" },
    ],
    children: [],
  })
  let hyperlinks_el : @xml.Node = @xml.Node::Element({
    name: name("hyperlinks"),
    attributes: [],
    children: [hyperlink],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
      hyperlinks_el,
    ],
  })
  let result = render_svg(worksheet)
  assert_true(result.svg.contains("class=\"hyperlinks\""))
  assert_true(result.svg.contains("data-ooxml-hyperlink-ref=\"A1\""))
  assert_true(result.svg.contains("data-ooxml-hyperlink-r-id=\"rId1\""))
  // location/tooltip/display all surface verbatim.
  assert_true(
    result.svg.contains("data-ooxml-hyperlink-location=\"Sheet1!B2\""),
  )
  assert_true(result.svg.contains("data-ooxml-hyperlink-tooltip=\"Go to B2\""))
  assert_true(result.svg.contains("data-ooxml-hyperlink-display=\"Click me\""))
}

///|
/// §18.3.1.45 — a hyperlink whose @ref is a range MUST anchor at
/// the top-left cell (the range's first cell).
test "SpreadsheetML viewer §18.3.1.45 hyperlink with range ref anchors at first cell" {
  let hyperlink : @xml.Node = @xml.Node::Element({
    name: name("hyperlink"),
    attributes: [
      { name: name("ref"), value: "A1:B2" },
      { name: name("id"), value: "rId7" },
    ],
    children: [],
  })
  let hyperlinks_el : @xml.Node = @xml.Node::Element({
    name: name("hyperlinks"),
    attributes: [],
    children: [hyperlink],
  })
  let cells_row1 : Array[@xml.Node] = [
    build_cell("A1", None, "1"),
    build_cell("B1", None, "2"),
  ]
  let cells_row2 : Array[@xml.Node] = [
    build_cell("A2", None, "3"),
    build_cell("B2", None, "4"),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:B2" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1), build_row(2, cells_row2)],
      }),
      hyperlinks_el,
    ],
  })
  let result = render_svg(worksheet)
  assert_true(result.svg.contains("data-ooxml-hyperlink-ref=\"A1:B2\""))
  assert_true(result.svg.contains("data-ooxml-hyperlink-r-id=\"rId7\""))
}

///|
/// §18.3.1.40 `<c><f>FORMULA</f><v>cached</v></c>` — the formula
/// text and `@t`/`@si`/`@ref` metadata MUST surface as
/// `data-ooxml-formula` / `data-ooxml-f-*` in a `<g class="formulas">`
/// sidecar so consumers can rebuild the formula layer (re-evaluation,
/// copy/paste, dependency tracking).
test "SpreadsheetML viewer §18.3.1.40 cell formula surfaces as data-ooxml-formula" {
  let formula_cell : @xml.Node = @xml.Node::Element({
    name: name("c"),
    attributes: [
      { name: name("r"), value: "A1" },
      { name: name("t"), value: "n" },
    ],
    children: [
      @xml.Node::Element({
        name: name("f"),
        attributes: [],
        children: [@xml.Node::Text("SUM(B1:B3)")],
      }),
      @xml.Node::Element({
        name: name("v"),
        attributes: [],
        children: [@xml.Node::Text("42")],
      }),
    ],
  })
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [formula_cell],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet)
  assert_true(result.svg.contains("class=\"formulas\""))
  assert_true(result.svg.contains("data-ooxml-formula=\"SUM(B1:B3)\""))
  assert_true(result.svg.contains("data-ooxml-cell-ref=\"A1\""))
  // Cached value still renders.
  assert_true(result.svg.contains("42"))
}

///|
/// §18.3.1.40 — shared / array formulas carry @t / @si / @ref.
test "SpreadsheetML viewer §18.3.1.40 shared formula @si/@ref surface" {
  let shared_formula_cell : @xml.Node = @xml.Node::Element({
    name: name("c"),
    attributes: [
      { name: name("r"), value: "A1" },
      { name: name("t"), value: "n" },
    ],
    children: [
      @xml.Node::Element({
        name: name("f"),
        attributes: [
          { name: name("t"), value: "shared" },
          { name: name("si"), value: "0" },
          { name: name("ref"), value: "A1:A10" },
        ],
        children: [@xml.Node::Text("B1*2")],
      }),
      @xml.Node::Element({
        name: name("v"),
        attributes: [],
        children: [@xml.Node::Text("0")],
      }),
    ],
  })
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A10" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [shared_formula_cell],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet)
  assert_true(result.svg.contains("data-ooxml-f-t=\"shared\""))
  assert_true(result.svg.contains("data-ooxml-f-si=\"0\""))
  assert_true(result.svg.contains("data-ooxml-f-ref=\"A1:A10\""))
}

///|
/// §18.3.1.87 `<sheetView @showRowColHeaders="0">` — the renderer
/// MUST omit the `<g class="row-headers">` / `<g class="column-headers">`
/// groups regardless of the SheetRenderOptions default.
test "SpreadsheetML viewer §18.3.1.87 showRowColHeaders=\"0\" omits header groups" {
  let sheet_view : @xml.Node = @xml.Node::Element({
    name: name("sheetView"),
    attributes: [
      { name: name("workbookViewId"), value: "0" },
      { name: name("showRowColHeaders"), value: "0" },
    ],
    children: [],
  })
  let sheet_views : @xml.Node = @xml.Node::Element({
    name: name("sheetViews"),
    attributes: [],
    children: [sheet_view],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      sheet_views,
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  // Use options that would normally render headers.
  let options = SheetRenderOptions::{
    ..default_render_options(),
    show_row_headers: true,
    show_column_headers: true,
  }
  let result = render_svg(worksheet, options~)
  // Headers MUST be suppressed by the per-sheet view setting.
  assert_false(result.svg.contains("class=\"row-headers\""))
  assert_false(result.svg.contains("class=\"column-headers\""))
}

///|
/// §18.3.1.87 `<sheetView @showZeros="0">` — numeric cells with
/// value exactly 0 MUST render blank.
test "SpreadsheetML viewer §18.3.1.87 showZeros=\"0\" hides zero cells" {
  let sheet_view : @xml.Node = @xml.Node::Element({
    name: name("sheetView"),
    attributes: [
      { name: name("workbookViewId"), value: "0" },
      { name: name("showZeros"), value: "0" },
    ],
    children: [],
  })
  let sheet_views : @xml.Node = @xml.Node::Element({
    name: name("sheetViews"),
    attributes: [],
    children: [sheet_view],
  })
  // A1=0 (numeric), B1=5 (non-zero), C1=0.0 (also zero).
  let cells_row1 : Array[@xml.Node] = [
    build_cell("A1", None, "0"),
    build_cell("B1", None, "5"),
    build_cell("C1", None, "0.0"),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:C1" }],
        children: [],
      }),
      sheet_views,
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // The non-zero value still renders.
  assert_true(result.svg.contains(">5<"))
  // The zero values should NOT render in cell-text spans. We
  // can't simply check `.contains("0")` because column widths /
  // viewbox include digits; instead assert no `<text>` element
  // contains an isolated "0" cell value by checking the count
  // of `>0<` occurrences (which would only come from cell text).
  assert_false(result.svg.contains(">0<"))
  assert_false(result.svg.contains(">0.0<"))
}

///|
/// §18.8.1 `<alignment textRotation indent shrinkToFit readingOrder>` —
/// the SML viewer MUST resolve these attributes through the cellXfs
/// chain and surface them as `data-ooxml-text-rotation` /
/// `data-ooxml-indent` / `data-ooxml-shrink-to-fit` /
/// `data-ooxml-reading-order` on the rendered cell `<text>`.
test "SpreadsheetML viewer §18.8.1 cell alignment attrs surface as data-ooxml-*" {
  // Build a stylesheet with one cellXfs entry whose <alignment>
  // carries all four spec attributes.
  let alignment_el : @xml.Element = {
    name: name("alignment"),
    attributes: [
      { name: name("horizontal"), value: "left" },
      { name: name("vertical"), value: "center" },
      { name: name("textRotation"), value: "90" },
      { name: name("indent"), value: "2" },
      { name: name("shrinkToFit"), value: "1" },
      { name: name("readingOrder"), value: "2" },
    ],
    children: [],
  }
  let xf : @xml.Element = {
    name: name("xf"),
    attributes: [{ name: name("applyAlignment"), value: "1" }],
    children: [@xml.Node::Element(alignment_el)],
  }
  let cell_xfs : @xml.Element = {
    name: name("cellXfs"),
    attributes: [{ name: name("count"), value: "1" }],
    children: [@xml.Node::Element(xf)],
  }
  let stylesheet_el : @xml.Element = {
    name: name("styleSheet"),
    attributes: [],
    children: [@xml.Node::Element(cell_xfs)],
  }
  let stylesheet = @domain.CT_Stylesheet::new(stylesheet_el)
  let cells_row1 : Array[@xml.Node] = [
    @xml.Node::Element({
      name: name("c"),
      attributes: [
        { name: name("r"), value: "A1" },
        { name: name("t"), value: "inlineStr" },
        { name: name("s"), value: "0" },
      ],
      children: [
        @xml.Node::Element({
          name: name("is"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("t"),
              attributes: [],
              children: [@xml.Node::Text("Rotated")],
            }),
          ],
        }),
      ],
    }),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  let result = render_svg(worksheet, styles=Some(stylesheet))
  assert_true(result.svg.contains("data-ooxml-text-rotation=\"90\""))
  assert_true(result.svg.contains("data-ooxml-indent=\"2\""))
  assert_true(result.svg.contains("data-ooxml-shrink-to-fit=\"1\""))
  assert_true(result.svg.contains("data-ooxml-reading-order=\"2\""))
  // §18.8.1 — Excel rotation is counter-clockwise; SVG's
  // transform must negate to clockwise.
  assert_true(result.svg.contains("rotate(-90,"))
}

///|
/// §18.8.31 — fraction format codes like `# ?/?`, `# ?/8`, `?/?`.
/// The denominator MUST be the best rational approximation
/// constrained by the placeholder digit count (max) or set to
/// the literal denominator when the slot is a number.
test "SpreadsheetML §18.8.31 fraction formats produce best rational" {
  // 0.5 → "1/2".  Slot has no integer block; single-digit num/den.
  inspect(format_number_general(0.5, "?/?"), content="1/2")
  // 1.5 → "1 1/2".  Integer slot + space-literal + numerator/denominator.
  inspect(format_number_general(1.5, "# ?/?"), content="1 1/2")
  // 2.625 → "2 5/8" using literal /8 denominator.
  inspect(format_number_general(2.625, "# ?/8"), content="2 5/8")
  // 1/3 ≈ 0.333..., ?/? (max den 9) → "1/3".
  inspect(format_number_general(1.0 / 3.0, "?/?"), content="1/3")
  // 1/3 ≈ 0.333..., ??/?? (max den 99) — right-padded to 2 digits.
  inspect(format_number_general(1.0 / 3.0, "??/??"), content=" 1/ 3")
  // 22/7 ≈ pi approximation: 3.142857..., # ??/?? → "3 22/7".
  // ?? gives max denominator 99; 22/7 is the best approximation.
  // 22/7 ≈ 3.142857 → "3 1/7" (mixed-number form, max den 99).
  // The integer part is 3; remaining 1/7 fits within the
  // numerator/denominator placeholders.
  inspect(format_number_general(22.0 / 7.0, "# ??/??"), content="3  1/ 7")
}

///|
/// §18.3.1.73 row/@outlineLevel + §18.3.1.13 col/@outlineLevel —
/// the renderer MUST surface grouping levels as
/// `data-ooxml-row-outline-level` / `data-ooxml-col-outline-level`
/// data attributes on a sidecar `<g class="outline-levels">`.
test "SpreadsheetML viewer §18.3.1.73/.13 outlineLevel surfaces as data-ooxml" {
  let cols : @xml.Node = @xml.Node::Element({
    name: name("cols"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("col"),
        attributes: [
          { name: name("min"), value: "1" },
          { name: name("max"), value: "2" },
          { name: name("outlineLevel"), value: "2" },
        ],
        children: [],
      }),
    ],
  })
  let row1 : @xml.Node = @xml.Node::Element({
    name: name("row"),
    attributes: [
      { name: name("r"), value: "1" },
      { name: name("outlineLevel"), value: "1" },
    ],
    children: [build_cell("A1", None, "1"), build_cell("B1", None, "2")],
  })
  let row2 : @xml.Node = @xml.Node::Element({
    name: name("row"),
    attributes: [{ name: name("r"), value: "2" }],
    children: [build_cell("A2", None, "3"), build_cell("B2", None, "4")],
  })
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:B2" }],
        children: [],
      }),
      cols,
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [row1, row2],
      }),
    ],
  })
  let result = render_svg(worksheet)
  assert_true(result.svg.contains("class=\"outline-levels\""))
  assert_true(result.svg.contains("data-ooxml-row-outline-level=\"1\""))
  assert_true(result.svg.contains("data-ooxml-row=\"1\""))
  assert_true(result.svg.contains("data-ooxml-col-outline-level=\"2\""))
  assert_true(result.svg.contains("data-ooxml-col-min=\"1\""))
  assert_true(result.svg.contains("data-ooxml-col-max=\"2\""))
}

///|
/// §18.3.1.82 `<sheetPr>/<tabColor @rgb>` — the worksheet tab
/// strip colour MUST surface as `data-ooxml-tab-color` on the
/// SVG root.  Excel writes ARGB (8-hex); the leading alpha pair
/// is dropped to yield a CSS `#rrggbb`.
test "SpreadsheetML viewer §18.3.1.82 sheetPr tabColor surfaces as data-ooxml-tab-color" {
  let tab_color : @xml.Node = @xml.Node::Element({
    name: name("tabColor"),
    attributes: [{ name: name("rgb"), value: "FF4472C4" }],
    children: [],
  })
  let sheet_pr : @xml.Node = @xml.Node::Element({
    name: name("sheetPr"),
    attributes: [],
    children: [tab_color],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      sheet_pr,
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // ARGB FF4472C4 → drop alpha FF → #4472C4.
  assert_true(result.svg.contains("data-ooxml-tab-color=\"#4472C4\""))
}

///|
/// §18.3.1.82 — theme-indexed tab colours surface as `theme:N`.
test "SpreadsheetML viewer §18.3.1.82 tabColor theme index surfaces verbatim" {
  let tab_color : @xml.Node = @xml.Node::Element({
    name: name("tabColor"),
    attributes: [{ name: name("theme"), value: "4" }],
    children: [],
  })
  let sheet_pr : @xml.Node = @xml.Node::Element({
    name: name("sheetPr"),
    attributes: [],
    children: [tab_color],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      sheet_pr,
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  let result = render_svg(worksheet)
  assert_true(result.svg.contains("data-ooxml-tab-color=\"theme:4\""))
}

///|
/// §18.3.1.70 `<printOptions>` — the print-setup boolean flags
/// (horizontalCentered / verticalCentered / headings / gridLines)
/// MUST surface as `data-ooxml-print-*` on the SVG root for
/// consumers that drive a print pipeline.
test "SpreadsheetML viewer §18.3.1.70 printOptions surface as data-ooxml-print-*" {
  let print_options : @xml.Node = @xml.Node::Element({
    name: name("printOptions"),
    attributes: [
      { name: name("horizontalCentered"), value: "1" },
      { name: name("verticalCentered"), value: "1" },
      { name: name("headings"), value: "1" },
      { name: name("gridLines"), value: "1" },
    ],
    children: [],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "1")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
      print_options,
    ],
  })
  let result = render_svg(worksheet)
  assert_true(result.svg.contains("data-ooxml-print-horizontalCentered=\"1\""))
  assert_true(result.svg.contains("data-ooxml-print-verticalCentered=\"1\""))
  assert_true(result.svg.contains("data-ooxml-print-headings=\"1\""))
  assert_true(result.svg.contains("data-ooxml-print-gridLines=\"1\""))
}

///|
/// §18.3.1.73 `<row @spans>` — when `<dimension>` is absent, a
/// row that declares a span range but lists few `<c>` cells MUST
/// still contribute its full column extent to the derived sheet
/// bounds (otherwise empty trailing columns vanish).
test "SpreadsheetML viewer §18.3.1.73 row spans widen derived bounds" {
  // Row 1 declares spans "1:5" but only populates A1.
  let row1 : @xml.Node = @xml.Node::Element({
    name: name("row"),
    attributes: [
      { name: name("r"), value: "1" },
      { name: name("spans"), value: "1:5" },
    ],
    children: [build_cell("A1", None, "x")],
  })
  // No <dimension> — bounds derive from data + spans.
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [row1],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // 5 default-width columns (8.43 char × 65 px each, MDW = 7.7 —
  // see `column_max_digit_width_px`) = 325 px body width.  Without
  // the spans honoring, only column A (65 px) would show.
  // §18.3.1.62 — `result.width` is the page width (body +
  // print-default 2.0 cm L/R print margins):
  // 325 + 2*75.59055 ≈ 476.181 px.
  inspect(
    result.width,
    content=(
      #|476.1811023622047
    ),
  )
}

///|
/// §18.3.1.81 `<sheetFormatPr defaultColWidth defaultRowHeight>` —
/// the worksheet's own format defaults MUST override the renderer
/// options for non-custom rows / columns.  A sheet declaring a
/// wider defaultColWidth renders proportionally wider.
test "SpreadsheetML viewer §18.3.1.81 sheetFormatPr overrides default dims" {
  // defaultColWidth=20 char (vs the renderer default 8.43).
  let fmt_pr : @xml.Node = @xml.Node::Element({
    name: name("sheetFormatPr"),
    attributes: [
      { name: name("defaultColWidth"), value: "20" },
      { name: name("defaultRowHeight"), value: "30" },
    ],
    children: [],
  })
  let cells_row1 : Array[@xml.Node] = [build_cell("A1", None, "x")]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      fmt_pr,
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  let result = render_svg(worksheet)
  // A 20-char column is markedly wider than the 8.43-char default
  // (59 px).  §18.3.1.13 width formula gives ≈ 134 px for 20 char.
  assert_true(result.width > 100)
  // defaultRowHeight=30 pt → 40 px (30 × 96/72) vs default 20 px.
  assert_true(result.height > 30)
}

///|
/// §18.4.6 `<rPh>` — a shared-string cell whose `<si>` entry
/// declares phonetic-guide runs MUST surface a
/// `data-ooxml-phonetic` sidecar carrying the concatenated
/// furigana text.
test "SpreadsheetML viewer §18.4.6 rPh phonetic surfaces as data-ooxml-phonetic" {
  // <si><t>東京</t><rPh sb="0" eb="2"><t>とうきょう</t></rPh></si>
  let si : @xml.Element = {
    name: name("si"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("\u{6771}\u{4eac}")],
      }),
      @xml.Node::Element({
        name: name("rPh"),
        attributes: [
          { name: name("sb"), value: "0" },
          { name: name("eb"), value: "2" },
        ],
        children: [
          @xml.Node::Element({
            name: name("t"),
            attributes: [],
            children: [
              @xml.Node::Text("\u{3068}\u{3046}\u{304d}\u{3087}\u{3046}"),
            ],
          }),
        ],
      }),
    ],
  }
  let sst = @domain.CT_Sst::new({
    name: name("sst"),
    attributes: [],
    children: [@xml.Node::Element(si)],
  })
  // Cell A1 references shared-string index 0.
  let cell_a1 : @xml.Node = @xml.Node::Element({
    name: name("c"),
    attributes: [
      { name: name("r"), value: "A1" },
      { name: name("t"), value: "s" },
    ],
    children: [
      @xml.Node::Element({
        name: name("v"),
        attributes: [],
        children: [@xml.Node::Text("0")],
      }),
    ],
  })
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [{ name: name("r"), value: "1" }],
            children: [cell_a1],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, shared_strings=Some(sst))
  assert_true(result.svg.contains("class=\"phonetics\""))
  assert_true(result.svg.contains("data-ooxml-phonetic="))
  assert_true(result.svg.contains("\u{3068}\u{3046}\u{304d}\u{3087}\u{3046}"))
  // Base text still renders.
  assert_true(result.svg.contains("\u{6771}\u{4eac}"))
}

///|
/// §18.2.28 / §18.17.4.1 — the `date1904` workbook flag MUST
/// shift serial-date interpretation by ~4 years.  Serial 1 with
/// a `yyyy` date format renders 1900 under the default 1900
/// system and 1904 under date1904.
test "SpreadsheetML viewer §18.2.28 date1904 flag shifts date epoch" {
  // A1 numeric value 367 with a yyyy-mm-dd numFmt.
  let xf : @xml.Element = {
    name: name("xf"),
    attributes: [{ name: name("numFmtId"), value: "14" }],
    children: [],
  }
  let cell_xfs : @xml.Element = {
    name: name("cellXfs"),
    attributes: [{ name: name("count"), value: "1" }],
    children: [@xml.Node::Element(xf)],
  }
  let stylesheet = @domain.CT_Stylesheet::new({
    name: name("styleSheet"),
    attributes: [],
    children: [@xml.Node::Element(cell_xfs)],
  })
  let cells_row1 : Array[@xml.Node] = [
    @xml.Node::Element({
      name: name("c"),
      attributes: [
        { name: name("r"), value: "A1" },
        { name: name("s"), value: "0" },
      ],
      children: [
        @xml.Node::Element({
          name: name("v"),
          attributes: [],
          children: [@xml.Node::Text("367")],
        }),
      ],
    }),
  ]
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, cells_row1)],
      }),
    ],
  })
  // Direct check on the format helper — serial 367 with an
  // explicit yyyy format.  Under the 1900 system this is a 1901
  // date; under date1904 it is ~4 years later.
  let y1900 = format_number_general(367.0, "yyyy")
  let y1904 = format_number_general(
    367.0,
    "yyyy",
    date_system=@date_serial.DateSystem::Serial1904,
  )
  // The two epochs MUST produce different years.
  assert_false(y1900 == y1904)
  // End-to-end: the rendered SVG honours date1904 too — the two
  // renders differ.
  let svg_1900 = render_svg(worksheet, styles=Some(stylesheet)).svg
  let svg_1904 = render_svg(worksheet, styles=Some(stylesheet), date1904=true).svg
  assert_false(svg_1900 == svg_1904)
}

///|
/// §18.3.1.4 — cell text is clipped to the cell rectangle via a
/// `<clipPath>` so an overlong string cannot bleed into adjacent
/// cells. Mirrors `renderCellText` in web-pptx
/// `@aurochs-renderer/xlsx/src/svg/cell-renderer.ts:308-318`.
test "SpreadsheetML SVG renderer clips cell text to the cell rect" {
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          build_row(1, [
            {
              let attrs : Array[@xml.Attribute] = [
                { name: name("r"), value: "A1" },
                { name: name("t"), value: "inlineStr" },
              ]
              @xml.Node::Element({
                name: name("c"),
                attributes: attrs,
                children: [
                  @xml.Node::Element({
                    name: name("is"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("t"),
                        attributes: [],
                        children: [
                          @xml.Node::Text(
                            "A very long cell string that would overflow",
                          ),
                        ],
                      }),
                    ],
                  }),
                ],
              })
            },
          ]),
        ],
      }),
    ],
  })
  let svg = render_svg(worksheet).svg
  // The cell text carries a clip-path reference, and a matching
  // <clipPath> definition is emitted.
  assert_true(svg.contains("<clipPath "))
  assert_true(svg.contains("clip-path=\"url(#clip_"))
}

///|
/// §18.3.1.70 — `render_svg` produces a *page* render, so row /
/// column headings follow `<printOptions @headings>` (default
/// false), NOT the editing-view `<sheetView @showRowColHeaders>`.
/// A worksheet whose `<sheetView>` enables headers for editing but
/// has no `<printOptions @headings="1">` MUST render without the
/// header gutters — matching a print / PDF export.
test "SpreadsheetML viewer §18.3.1.70 page render omits editing-view headers" {
  let sheet_view : @xml.Node = @xml.Node::Element({
    name: name("sheetView"),
    attributes: [
      { name: name("workbookViewId"), value: "0" },
      // Editing view shows headers — must NOT leak into the page render.
      { name: name("showRowColHeaders"), value: "true" },
    ],
    children: [],
  })
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetViews"),
        attributes: [],
        children: [sheet_view],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, [build_cell("A1", None, "1")])],
      }),
    ],
  })
  let svg = render_svg(worksheet).svg
  // No editing-view header gutters in a page render.
  assert_false(svg.contains("class=\"row-headers\""))
  assert_false(svg.contains("class=\"column-headers\""))
}

///|
/// §18.3.1.70 — when `<printOptions @headings="1">` IS set, the page
/// render DOES include the row / column heading gutters.
test "SpreadsheetML viewer §18.3.1.70 printOptions headings enables gutters" {
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("dimension"),
        attributes: [{ name: name("ref"), value: "A1:A1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("printOptions"),
        attributes: [{ name: name("headings"), value: "1" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, [build_cell("A1", None, "1")])],
      }),
    ],
  })
  let svg = render_svg(worksheet).svg
  assert_true(svg.contains("class=\"row-headers\""))
  assert_true(svg.contains("class=\"column-headers\""))
}

///|
/// §18.5.1.5 — table style chrome is suppressed by default
/// (matches the reference PDF print export, which does NOT paint
/// table banding nor autofilter dropdown glyphs).  A worksheet
/// carrying a styled `<table>` must render without the
/// `table-chrome` / `table-autofilter` groups when
/// `show_table_chrome: false` (the default).
test "SpreadsheetML viewer §18.5 table chrome suppressed by default for print" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let worksheet = @domain.CT_Worksheet::new({
    name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [build_row(1, [build_cell("A1", None, "Project")])],
      }),
    ],
  })
  // A `<table>` element with TableStyleMedium2 + showRowStripes —
  // the canonical Excel-default styled table.
  let table : @xml.Element = {
    name: { prefix: None, local_name: "table", ns: Some(ns_s) },
    attributes: [
      { name: name("id"), value: "1" },
      { name: name("name"), value: "T1" },
      { name: name("displayName"), value: "T1" },
      { name: name("ref"), value: "A1:A3" },
    ],
    children: [
      @xml.Node::Element({
        name: name("tableStyleInfo"),
        attributes: [
          { name: name("name"), value: "TableStyleMedium2" },
          { name: name("showRowStripes"), value: "1" },
        ],
        children: [],
      }),
    ],
  }
  let svg = render_svg(worksheet, tables=[table]).svg
  // Default: no chrome (print mode).
  assert_false(svg.contains("class=\"table-chrome\""))
  assert_false(svg.contains("class=\"table-autofilter\""))
  assert_false(svg.contains("data-ooxml-table-band"))
}

///|
/// §18.5.1.5 — with `show_table_chrome: true` (editing view), the
/// renderer paints the header band, row stripes, and totals border
/// using the built-in style palette.
test "SpreadsheetML viewer §18.5 table chrome emitted when show_table_chrome opts in" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let worksheet = @domain.CT_Worksheet::new({
    name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          build_row(1, [build_cell("A1", None, "H")]),
          build_row(2, [build_cell("A2", None, "1")]),
          build_row(3, [build_cell("A3", None, "2")]),
          build_row(4, [build_cell("A4", None, "3")]),
        ],
      }),
    ],
  })
  let table : @xml.Element = {
    name: { prefix: None, local_name: "table", ns: Some(ns_s) },
    attributes: [
      { name: name("id"), value: "1" },
      { name: name("name"), value: "T1" },
      { name: name("displayName"), value: "T1" },
      { name: name("ref"), value: "A1:A4" },
    ],
    children: [
      @xml.Node::Element({
        name: name("tableStyleInfo"),
        attributes: [
          { name: name("name"), value: "TableStyleMedium2" },
          { name: name("showRowStripes"), value: "1" },
        ],
        children: [],
      }),
    ],
  }
  let opts = { ..default_render_options(), show_table_chrome: true }
  let svg = render_svg(worksheet, options=opts, tables=[table]).svg
  // Chrome groups MUST appear.
  assert_true(svg.contains("class=\"table-chrome\""))
  // Header band sits on row 1 (y=0..17).
  assert_true(svg.contains("data-ooxml-table-band=\"header\""))
  // One row stripe — data rows are 2,3,4 → stripe lands on row 3.
  assert_true(svg.contains("data-ooxml-table-band=\"row-stripe\""))
}

///|
/// §18.5.1.2 / §18.3.1.2 — when a `<table>` carries an
/// `<autoFilter>` child AND `show_table_chrome: true`, the renderer
/// paints the dropdown button glyph on the header row.
test "SpreadsheetML viewer §18.5 autofilter dropdown emitted with chrome opt-in" {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let worksheet = @domain.CT_Worksheet::new({
    name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          build_row(1, [
            build_cell("A1", None, "H"),
            build_cell("B1", None, "K"),
          ]),
          build_row(2, [
            build_cell("A2", None, "x"),
            build_cell("B2", None, "y"),
          ]),
        ],
      }),
    ],
  })
  let table : @xml.Element = {
    name: { prefix: None, local_name: "table", ns: Some(ns_s) },
    attributes: [
      { name: name("id"), value: "1" },
      { name: name("name"), value: "T1" },
      { name: name("displayName"), value: "T1" },
      { name: name("ref"), value: "A1:B2" },
    ],
    children: [
      @xml.Node::Element({
        name: name("autoFilter"),
        attributes: [{ name: name("ref"), value: "A1:B2" }],
        children: [],
      }),
    ],
  }
  let opts = { ..default_render_options(), show_table_chrome: true }
  let svg = render_svg(worksheet, options=opts, tables=[table]).svg
  // The autofilter glyph group fires.
  assert_true(svg.contains("class=\"table-autofilter\""))
  assert_true(svg.contains("data-ooxml-autofilter=\"button\""))
  assert_true(svg.contains("data-ooxml-autofilter=\"arrow\""))
}
