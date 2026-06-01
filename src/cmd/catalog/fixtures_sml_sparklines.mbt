// SpreadsheetML SPARKLINES (Microsoft x14 extension) — `[MS-XLSX]` §2.2.4.
//
// Sparklines are inline chart glyphs anchored to a single worksheet
// cell. The payload lives inside the worksheet XML via the Office
// 2010 `x14` extension namespace:
//
//   <worksheet xmlns:x14="…">
//     <sheetData>…</sheetData>
//     <extLst>
//       <ext uri="{05C60535-1F16-4FD2-B633-F4F36F0B64E0}">
//         <x14:sparklineGroups>
//           <x14:sparklineGroup type="line" markers="1">
//             <x14:colorSeries rgb="FF376092"/>
//             <x14:sparklines>
//               <x14:sparkline>
//                 <xm:f>Sheet1!A1:E1</xm:f>
//                 <xm:sqref>F1</xm:sqref>
//               </x14:sparkline>
//             </x14:sparklines>
//           </x14:sparklineGroup>
//         </x14:sparklineGroups>
//       </ext>
//     </extLst>
//   </worksheet>
//
// `xlsx_package_with_sparklines` in verify.mbt owns the `<extLst>` /
// `<ext>` wrapping; the fixtures here build the `<sheetData>`,
// `<sheetFormatPr>`, and the `<x14:sparklineGroups>` tree directly.
// Every element is built as an `@xml.Element` tree — no XML
// strings per AGENTS.md.
//
// What this file covers:
//
//   * `sparkline-line-basic` — single line sparkline over a 5-cell
//     row, with default colours.
//   * `sparkline-column-markers` — column sparkline with markers
//     and explicit series colour.
//   * `sparkline-winloss-negative` — win/loss (stacked) sparkline
//     with negative-band colour.
//   * `sparkline-multi-row` — four sparklines on the same column,
//     each anchored to a different row; exercises the
//     multi-`<x14:sparkline>`-per-group path.
//   * `sparkline-line-highlights` — line sparkline with high /
//     low / first / last point highlights.
//
// Renderer support: the SML viewer's `render_sheet_sparklines`
// decodes the worksheet's `<extLst>` payload via
// `@sparkline.decode_ext_lst`, resolves the data-range formula
// against `<sheetData>`, and paints one `<g class="sparkline">`
// per anchored cell. Stacked / column variants paint signed bars;
// the line variant paints a polyline with optional markers and
// per-data-point highlight dots.

// ---- file-local helpers ----------------------------------------------

///|
/// SpreadsheetML namespace shorthand local to this file.
const NS_S_SPK : String = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"

///|
/// Build a prefixed `<x14:NAME …>…</x14:NAME>` element. The
/// `xmlns:x14` declaration is emitted automatically by `@xml.write`
/// on the worksheet root.
fn x14_elem(
  tag : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  {
    name: {
      prefix: Some("x14"),
      local_name: tag,
      ns: Some(@sml_sparkline.x14_ns()),
    },
    attributes: attrs,
    children: kids,
  }
}

///|
/// Build a prefixed `<xm:NAME …>…</xm:NAME>` element.
fn xm_elem(
  tag : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  {
    name: {
      prefix: Some("xm"),
      local_name: tag,
      ns: Some(@sml_sparkline.xm_ns()),
    },
    attributes: attrs,
    children: kids,
  }
}

///|
/// `<x14:colorXxx rgb="…"/>` shorthand. ARGB hex (8 chars) per
/// `[MS-XLSX]` §2.6.10 ST_UnsignedIntHex.
fn x14_color(tag : String, argb_hex : String) -> @xml.Element {
  x14_elem(tag, [xa("rgb", argb_hex)], [])
}

///|
/// `<x14:sparkline><xm:f>…</xm:f><xm:sqref>…</xm:sqref></x14:sparkline>`.
fn x14_sparkline(data_range : String, anchor_cell : String) -> @xml.Element {
  x14_elem("sparkline", [], [
    Element(xm_elem("f", [], [Text(data_range)])),
    Element(xm_elem("sqref", [], [Text(anchor_cell)])),
  ])
}

// ---- SparklineCase extender: x14 sparklines on a worksheet -----------

///|
/// Push every sparkline fixture onto the supplied
/// `Array[SparklineCase]`. Wired via `sparkline_cases()` in
/// `fixtures.mbt`.
fn extras_sml_sparklines(scases : Array[SparklineCase]) -> Unit {
  // ---- 1. LINE sparkline over a 5-cell row -----------------------
  // Data row A1:E1 = 1, 3, 2, 5, 4 ; the sparkline glyph lives in
  // F1. No markers, default colours.
  scases.push({
    id: "sparkline-line-basic",
    format: "xlsx",
    category: "sparkline",
    content: xe(NS_S_SPK, "worksheet", [], [
      Element(
        xe(NS_S_SPK, "sheetData", [], [
          Element(
            s_row("1", [
              s_cell("A1", "1"),
              s_cell("B1", "3"),
              s_cell("C1", "2"),
              s_cell("D1", "5"),
              s_cell("E1", "4"),
            ]),
          ),
        ]),
      ),
    ]),
    sparkline_groups: x14_elem("sparklineGroups", [], [
      Element(
        x14_elem("sparklineGroup", [xa("type", "line")], [
          Element(x14_color("colorSeries", "FF376092")),
          Element(
            x14_elem("sparklines", [], [
              Element(x14_sparkline("Sheet1!A1:E1", "F1")),
            ]),
          ),
        ]),
      ),
    ]),
  })
  // ---- 2. COLUMN sparkline with explicit colour ------------------
  // Data row A2:E2 = 4, 6, 2, 7, 3 ; bars in F2.
  scases.push({
    id: "sparkline-column-markers",
    format: "xlsx",
    category: "sparkline",
    content: xe(NS_S_SPK, "worksheet", [], [
      Element(
        xe(NS_S_SPK, "sheetData", [], [
          Element(
            s_row("2", [
              s_cell("A2", "4"),
              s_cell("B2", "6"),
              s_cell("C2", "2"),
              s_cell("D2", "7"),
              s_cell("E2", "3"),
            ]),
          ),
        ]),
      ),
    ]),
    sparkline_groups: x14_elem("sparklineGroups", [], [
      Element(
        x14_elem(
          "sparklineGroup",
          [xa("type", "column"), xa("displayXAxis", "1")],
          [
            Element(x14_color("colorSeries", "FF548235")),
            Element(x14_color("colorAxis", "FF808080")),
            Element(
              x14_elem("sparklines", [], [
                Element(x14_sparkline("Sheet1!A2:E2", "F2")),
              ]),
            ),
          ],
        ),
      ),
    ]),
  })
  // ---- 3. WIN/LOSS (stacked) sparkline with negative band --------
  // Data row A3:F3 = 2, -1, 3, -2, 1, -3 ; bars in G3. Positive
  // points use colorSeries, negative use colorNegative.
  scases.push({
    id: "sparkline-winloss-negative",
    format: "xlsx",
    category: "sparkline",
    content: xe(NS_S_SPK, "worksheet", [], [
      Element(
        xe(NS_S_SPK, "sheetData", [], [
          Element(
            s_row("3", [
              s_cell("A3", "2"),
              s_cell("B3", "-1"),
              s_cell("C3", "3"),
              s_cell("D3", "-2"),
              s_cell("E3", "1"),
              s_cell("F3", "-3"),
            ]),
          ),
        ]),
      ),
    ]),
    sparkline_groups: x14_elem("sparklineGroups", [], [
      Element(
        x14_elem(
          "sparklineGroup",
          [xa("type", "stacked"), xa("negative", "1")],
          [
            Element(x14_color("colorSeries", "FF376092")),
            Element(x14_color("colorNegative", "FFC00000")),
            Element(
              x14_elem("sparklines", [], [
                Element(x14_sparkline("Sheet1!A3:F3", "G3")),
              ]),
            ),
          ],
        ),
      ),
    ]),
  })
  // ---- 4. MULTI-ROW: four sparklines in column F, one per row ----
  // Each row carries 5 numbers in A..E; the sparkline group holds
  // four `<x14:sparkline>` entries, one per anchor cell F1..F4.
  // Exercises the multi-sparkline branch in the renderer.
  scases.push({
    id: "sparkline-multi-row",
    format: "xlsx",
    category: "sparkline",
    content: xe(NS_S_SPK, "worksheet", [], [
      Element(
        xe(NS_S_SPK, "sheetData", [], [
          Element(
            s_row("1", [
              s_cell("A1", "1"),
              s_cell("B1", "2"),
              s_cell("C1", "3"),
              s_cell("D1", "4"),
              s_cell("E1", "5"),
            ]),
          ),
          Element(
            s_row("2", [
              s_cell("A2", "5"),
              s_cell("B2", "4"),
              s_cell("C2", "3"),
              s_cell("D2", "2"),
              s_cell("E2", "1"),
            ]),
          ),
          Element(
            s_row("3", [
              s_cell("A3", "2"),
              s_cell("B3", "5"),
              s_cell("C3", "1"),
              s_cell("D3", "4"),
              s_cell("E3", "3"),
            ]),
          ),
          Element(
            s_row("4", [
              s_cell("A4", "3"),
              s_cell("B4", "1"),
              s_cell("C4", "4"),
              s_cell("D4", "2"),
              s_cell("E4", "5"),
            ]),
          ),
        ]),
      ),
    ]),
    sparkline_groups: x14_elem("sparklineGroups", [], [
      Element(
        x14_elem("sparklineGroup", [xa("type", "line"), xa("markers", "1")], [
          Element(x14_color("colorSeries", "FF376092")),
          Element(x14_color("colorMarkers", "FFD00000")),
          Element(
            x14_elem("sparklines", [], [
              Element(x14_sparkline("Sheet1!A1:E1", "F1")),
              Element(x14_sparkline("Sheet1!A2:E2", "F2")),
              Element(x14_sparkline("Sheet1!A3:E3", "F3")),
              Element(x14_sparkline("Sheet1!A4:E4", "F4")),
            ]),
          ),
        ]),
      ),
    ]),
  })
  // ---- 5. LINE sparkline with high / low / first / last
  //         highlights -----------------------------------------------
  // Data row A5:G5 = 3, 7, 2, 8, 5, 1, 6 ; sparkline in H5. High
  // (8), low (1), first (3), and last (6) get distinct
  // highlight colours per `[MS-XLSX]` §2.6.5 precedence.
  scases.push({
    id: "sparkline-line-highlights",
    format: "xlsx",
    category: "sparkline",
    content: xe(NS_S_SPK, "worksheet", [], [
      Element(
        xe(NS_S_SPK, "sheetData", [], [
          Element(
            s_row("5", [
              s_cell("A5", "3"),
              s_cell("B5", "7"),
              s_cell("C5", "2"),
              s_cell("D5", "8"),
              s_cell("E5", "5"),
              s_cell("F5", "1"),
              s_cell("G5", "6"),
            ]),
          ),
        ]),
      ),
    ]),
    sparkline_groups: x14_elem("sparklineGroups", [], [
      Element(
        x14_elem(
          "sparklineGroup",
          [
            xa("type", "line"),
            xa("markers", "1"),
            xa("high", "1"),
            xa("low", "1"),
            xa("first", "1"),
            xa("last", "1"),
          ],
          [
            Element(x14_color("colorSeries", "FF376092")),
            Element(x14_color("colorMarkers", "FF808080")),
            Element(x14_color("colorHigh", "FF00B050")),
            Element(x14_color("colorLow", "FFC00000")),
            Element(x14_color("colorFirst", "FF7030A0")),
            Element(x14_color("colorLast", "FFFFC000")),
            Element(
              x14_elem("sparklines", [], [
                Element(x14_sparkline("Sheet1!A5:G5", "H5")),
              ]),
            ),
          ],
        ),
      ),
    ]),
  })
}
