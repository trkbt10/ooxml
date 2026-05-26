// SpreadsheetML CONDITIONAL FORMATTING — comprehensive coverage of the
// `<cfRule type="...">` enumeration.
//
// `fixtures_sml_cf.mbt` already covers the rule kinds that EMBED their
// own visual (`colorScale`, `dataBar`, `iconSet`) and therefore need no
// `styles.xml` part.  This file completes the coverage with:
//
//   * extra `iconSet` set-names from ECMA-376 §18.18.42 ST_IconSetType
//     (4Arrows, 5Arrows, 5Rating, 3Symbols) and `3TrafficLights2`;
//   * a `<dataBar>` with explicit `<negativeFillColor>` over a
//     positive+negative population (§18.3.1.28);
//   * a `<dataBar>` with explicit `@axisPosition="middle"` and an
//     `<axisColor>` (§18.3.1.28);
//   * extra colorScale gradients (blue→white 2-stop; percentile-anchored
//     3-stop) — variants beyond the default Excel palette.
//
// And — paired with their own `<styleSheet>` containing a `<dxfs>` that
// the rules' `dxfId` references — fixtures for every remaining
// §18.18.12 ST_CfType value the renderer overlays via differential
// formatting:
//
//   * `cellIs` with operator `lessThan`, `greaterThan`, `equal`,
//     `between`, `notBetween`               — §18.3.1.10 / §18.18.15
//   * `containsText`         (operator `containsText`)
//   * `containsText` rule with operator `notContains` — the "notContainsText"
//     spelling the task asks for, encoded as the spec-conformant
//     `notContains` operator on a containsText rule
//   * `expression`           — §18.3.1.10 (free-form formula)
//   * `top10` (top + bottom variant via `bottom="1"`)  — §18.3.1.42
//   * `aboveAverage`         — §18.3.1.10 (Mean+stdDev semantics)
//   * `uniqueValues`         — §18.3.1.10
//   * `duplicateValues`      — §18.3.1.10
//
// The dxf-bearing fixtures are pushed as `ExtendedCase` values from
// `extras_sml_cf_complete_styled(xcases)`, wired into `extended_cases()`
// alongside the existing `extras_sml_styled` hook so the
// `xlsx_package_styled` host-package builder picks them up and includes
// the `styles.xml` part under `xl/styles.xml`.
//
// The self-contained iconSet / dataBar / colorScale fixtures are
// pushed as `VisualCase` values from `extras_sml_cf_complete(cases)`,
// wired into `extra_cases()` in `fixtures_categories.mbt` and assembled
// by the plain `xlsx_package` builder (no styles.xml required).
//
// Every CF rule and styleSheet element is built as an `@xml.Element`
// tree — `@xml.write` serialises it once on package assembly; no XML
// is composed by string concatenation here.

// ---- file-local helpers reused only here -------------------------

///|
/// `<dxf>` wrapping a solid `<patternFill>` of `argb` — the renderer
/// reads this as the overlay fill applied to every cell the matching
/// rule selects.  §18.8.14 dxf / §18.8.32 patternFill.
fn cf_dxf_solid_fill(argb : String) -> @xml.Element {
  xe(NS_S, "dxf", [], [
    Element(
      xe(NS_S, "fill", [], [
        Element(
          xe(NS_S, "patternFill", [xa("patternType", "solid")], [
            Element(xe(NS_S, "fgColor", [xa("rgb", argb)], [])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
/// Wrap a list of `<dxf>` elements in the parent `<dxfs count="...">`
/// container.  §18.8.15 dxfs — sits in `<styleSheet>` after `<cellXfs>`.
fn cf_dxfs(dxfs : Array[@xml.Element]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for d in dxfs {
    kids.push(Element(d))
  }
  xe(NS_S, "dxfs", [xa("count", dxfs.length().to_string())], kids)
}

///|
/// Build a minimal `<styleSheet>` whose only payload (beyond the
/// mandatory fonts/fills/borders/cellXfs default index 0 entries) is a
/// `<dxfs>` carrying one solid-fill `<dxf>` of `argb` at index 0.  CF
/// rules reference it via `dxfId="0"`.
///
/// The five children of `<styleSheet>` MUST be emitted in spec order
/// — fonts, fills, borders, cellXfs, dxfs (§18.8.39 styleSheet) — so
/// readers that index by position still find each block.
fn cf_styles_with_dxf_color(argb : String) -> @xml.Element {
  xe(NS_S, "styleSheet", [], [
    Element(
      xe(NS_S, "fonts", [xa("count", "1")], [
        Element(
          xe(NS_S, "font", [], [
            Element(xe(NS_S, "sz", [xa("val", "11")], [])),
            Element(xe(NS_S, "name", [xa("val", "Calibri")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(NS_S, "fills", [xa("count", "2")], [
        Element(
          xe(NS_S, "fill", [], [
            Element(xe(NS_S, "patternFill", [xa("patternType", "none")], [])),
          ]),
        ),
        Element(
          xe(NS_S, "fill", [], [
            Element(xe(NS_S, "patternFill", [xa("patternType", "gray125")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(NS_S, "borders", [xa("count", "1")], [
        Element(
          xe(NS_S, "border", [], [
            Element(xe(NS_S, "left", [], [])),
            Element(xe(NS_S, "right", [], [])),
            Element(xe(NS_S, "top", [], [])),
            Element(xe(NS_S, "bottom", [], [])),
            Element(xe(NS_S, "diagonal", [], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(NS_S, "cellXfs", [xa("count", "1")], [
        Element(
          xe(
            NS_S,
            "xf",
            [
              xa("numFmtId", "0"),
              xa("fontId", "0"),
              xa("fillId", "0"),
              xa("borderId", "0"),
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(cf_dxfs([cf_dxf_solid_fill(argb)])),
  ])
}

///|
/// A `<cfRule type="cellIs" operator="...">` carrying one or two
/// `<formula>` children plus the `dxfId` overlay reference and a
/// priority.  §18.3.1.10 cfRule.
fn cf_rule_cell_is(
  operator : String,
  formulas : Array[String],
  dxf_id : String,
  priority : String,
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for f in formulas {
    kids.push(Element(xe(NS_S, "formula", [], [Text(f)])))
  }
  xe(
    NS_S,
    "cfRule",
    [
      xa("type", "cellIs"),
      xa("operator", operator),
      xa("dxfId", dxf_id),
      xa("priority", priority),
    ],
    kids,
  )
}

///|
/// A `<cfRule type="containsText" operator="...">` rule.  The `text`
/// attribute carries the literal needle string and a single
/// `<formula>` mirrors the SEARCH() / NOT(ISERROR(...)) idiom Excel
/// emits for this predicate (§18.3.1.10 — `<formula>` is required
/// even when the rule could be evaluated from `@text` alone).  The
/// `operator` is one of `containsText` / `notContains` / `beginsWith`
/// / `endsWith` per §18.18.15.
fn cf_rule_contains_text(
  operator : String,
  needle : String,
  sqref : String,
  dxf_id : String,
  priority : String,
) -> @xml.Element {
  // Excel writes the matching formula `NOT(ISERROR(SEARCH("X",cell)))`
  // for containsText and `ISERROR(SEARCH("X",cell))` for notContains;
  // mirror that so any consumer that re-evaluates the formula gets the
  // same predicate as the rule type.
  let first_ref = first_cell_of_sqref(sqref)
  let formula = match operator {
    "containsText" =>
      "NOT(ISERROR(SEARCH(\"" + needle + "\"," + first_ref + ")))"
    "notContains" => "ISERROR(SEARCH(\"" + needle + "\"," + first_ref + "))"
    "beginsWith" =>
      "LEFT(" +
      first_ref +
      "," +
      needle.length().to_string() +
      ")=\"" +
      needle +
      "\""
    "endsWith" =>
      "RIGHT(" +
      first_ref +
      "," +
      needle.length().to_string() +
      ")=\"" +
      needle +
      "\""
    _ => "TRUE"
  }
  xe(
    NS_S,
    "cfRule",
    [
      xa("type", "containsText"),
      xa("operator", operator),
      xa("text", needle),
      xa("dxfId", dxf_id),
      xa("priority", priority),
    ],
    [Element(xe(NS_S, "formula", [], [Text(formula)]))],
  )
}

///|
/// Return the first cell reference of an sqref range — `A1:A10` →
/// `A1`, `B3` → `B3`.  Used by `cf_rule_contains_text` to emit the
/// SEARCH() formula against the range's anchor cell.
fn first_cell_of_sqref(sqref : String) -> String {
  let colon = sqref.find(":")
  match colon {
    Some(i) => sqref[0:i].to_owned()
    None => sqref
  }
}

///|
/// A `<cfRule type="expression">` carrying one `<formula>` returning
/// boolean.  When the formula evaluates TRUE for a cell the dxf
/// overlay fires.  §18.3.1.10.
fn cf_rule_expression(
  formula : String,
  dxf_id : String,
  priority : String,
) -> @xml.Element {
  xe(
    NS_S,
    "cfRule",
    [xa("type", "expression"), xa("dxfId", dxf_id), xa("priority", priority)],
    [Element(xe(NS_S, "formula", [], [Text(formula)]))],
  )
}

///|
/// A `<cfRule type="top10" rank="N">` selecting the top (or, when
/// `bottom` is `Some("1")`, the bottom) N cells of the population.
/// `percent="1"` would switch from absolute rank to the top N percent
/// — omitted here for simplicity.  §18.3.1.10 / §18.3.1.42.
fn cf_rule_top10(
  rank : String,
  bottom : String?,
  dxf_id : String,
  priority : String,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    xa("type", "top10"),
    xa("rank", rank),
    xa("dxfId", dxf_id),
    xa("priority", priority),
  ]
  match bottom {
    Some(v) => attrs.push(xa("bottom", v))
    None => ()
  }
  xe(NS_S, "cfRule", attrs, [])
}

///|
/// A `<cfRule type="aboveAverage">` highlighting cells above the
/// population mean (set `above_or_below` to `"1"` for above-average,
/// `"0"` for below-average).  §18.3.1.10.
fn cf_rule_above_average(
  above_or_below : String,
  dxf_id : String,
  priority : String,
) -> @xml.Element {
  xe(
    NS_S,
    "cfRule",
    [
      xa("type", "aboveAverage"),
      xa("aboveAverage", above_or_below),
      xa("dxfId", dxf_id),
      xa("priority", priority),
    ],
    [],
  )
}

///|
/// A `<cfRule type="uniqueValues">` highlighting values that occur
/// exactly once across the population.  §18.3.1.10.
fn cf_rule_unique_values(dxf_id : String, priority : String) -> @xml.Element {
  xe(
    NS_S,
    "cfRule",
    [xa("type", "uniqueValues"), xa("dxfId", dxf_id), xa("priority", priority)],
    [],
  )
}

///|
/// A `<cfRule type="duplicateValues">` highlighting values that occur
/// more than once across the population.  §18.3.1.10.
fn cf_rule_duplicate_values(dxf_id : String, priority : String) -> @xml.Element {
  xe(
    NS_S,
    "cfRule",
    [
      xa("type", "duplicateValues"),
      xa("dxfId", dxf_id),
      xa("priority", priority),
    ],
    [],
  )
}

///|
/// `<dataBar>` with explicit child elements beyond the basic 3 (cfvo
/// min / cfvo max / color): `axisPosition` / `direction` /
/// `negativeFillColor` / `axisColor`.  Pass `None` for any axis /
/// direction / negative-fill that should be omitted, so the resulting
/// element is the minimum spec payload plus the requested extras.
/// §18.3.1.28 dataBar.
fn cf_rule_data_bar_extended(
  priority : String,
  cfvo_min : @xml.Element,
  cfvo_max : @xml.Element,
  bar_color : @xml.Element,
  axis_position : String?,
  axis_color : String?,
  negative_color : String?,
) -> @xml.Element {
  let bar_attrs : Array[@xml.Attribute] = []
  match axis_position {
    Some(p) => bar_attrs.push(xa("axisPosition", p))
    None => ()
  }
  let bar_kids : Array[@xml.Node] = [
    Element(cfvo_min),
    Element(cfvo_max),
    Element(bar_color),
  ]
  match negative_color {
    Some(c) =>
      bar_kids.push(Element(xe(NS_S, "negativeFillColor", [xa("rgb", c)], [])))
    None => ()
  }
  match axis_color {
    Some(c) => bar_kids.push(Element(xe(NS_S, "axisColor", [xa("rgb", c)], [])))
    None => ()
  }
  xe(NS_S, "cfRule", [xa("type", "dataBar"), xa("priority", priority)], [
    Element(xe(NS_S, "dataBar", bar_attrs, bar_kids)),
  ])
}

// ---- entry points ------------------------------------------------

///|
/// Self-contained conditional-formatting fixtures — no `styles.xml`
/// needed because every rule kind here embeds its own visual data
/// (`colorScale` colours, `dataBar` colour / axis, `iconSet` icon set).
/// Pushed under category "cf" so they land in
/// `.snapshots/fixtures/xlsx/cf/`.
fn extras_sml_cf_complete(cases : Array[VisualCase]) -> Unit {
  // 10-row monotonic ramp used as input for every embedded-visual
  // rule below (mirrors the reference column of fixtures_sml_cf.mbt).
  let v10_inc = ["10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]
  // 10-row range mixing negatives and positives for the dataBar
  // variants with axis / negative fill.
  let v_neg_pos = [
    "-50", "-30", "-10", "0", "10", "30", "50", "70", "90", "100",
  ]

  // ---- 1. iconSet 4Arrows — §18.3.1.49 / §18.18.42 ----------------
  // The 4-element ascending arrow set (down / down-right / up-right /
  // up).  Percent thresholds at 0/25/50/75 split the population into
  // four equal quartiles.
  cases.push({
    id: "cf-iconset-4arrows-set",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_icon_set("1", "4Arrows", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("25")),
            s_cfvo("percent", Some("50")),
            s_cfvo("percent", Some("75")),
          ]),
        ]),
      ),
    ]),
  })

  // ---- 2. iconSet 5Arrows — §18.3.1.49 / §18.18.42 ----------------
  // The 5-element ascending arrow set — five-quintile split at
  // 0/20/40/60/80.
  cases.push({
    id: "cf-iconset-5arrows-set",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_icon_set("1", "5Arrows", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("20")),
            s_cfvo("percent", Some("40")),
            s_cfvo("percent", Some("60")),
            s_cfvo("percent", Some("80")),
          ]),
        ]),
      ),
    ]),
  })

  // ---- 3. iconSet 5Rating — §18.3.1.49 / §18.18.42 ----------------
  // The 5-element rating-bars icon set (the spec spelling is "5Rating",
  // sometimes informally called "5RatingMarks" — only "5Rating" is
  // in ST_IconSetType, §18.18.42).  Five histogram-bar icons growing
  // 1-bar through 5-bar at thresholds 0/20/40/60/80.
  cases.push({
    id: "cf-iconset-5rating",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_icon_set("1", "5Rating", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("20")),
            s_cfvo("percent", Some("40")),
            s_cfvo("percent", Some("60")),
            s_cfvo("percent", Some("80")),
          ]),
        ]),
      ),
    ]),
  })

  // ---- 4. iconSet 3Symbols — §18.3.1.49 / §18.18.42 --------------
  // The 3-element symbol set (cross / exclamation / check) — three
  // status indicators.  Default thresholds 0/33/67.
  cases.push({
    id: "cf-iconset-3symbols",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_icon_set("1", "3Symbols", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("33")),
            s_cfvo("percent", Some("67")),
          ]),
        ]),
      ),
    ]),
  })

  // ---- 5. dataBar with explicit negativeFillColor — §18.3.1.28 ----
  // Range crossing zero, with the bar coloured blue for positives and
  // red for negatives.  The renderer should split bar direction at the
  // zero-axis so negatives extend left of the axis.
  cases.push({
    id: "cf-databar-negative-fill",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v_neg_pos))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_data_bar_extended(
            "1",
            s_cfvo("min", None),
            s_cfvo("max", None),
            s_color("FF638EC6"),
            None,
            None,
            Some("FFFF555A"),
          ),
        ]),
      ),
    ]),
  })

  // ---- 6. dataBar with axisPosition="middle" + axisColor ----------
  // Same neg+pos range, with the axis forced to the column midpoint
  // (instead of the data-driven "automatic" position) and tinted dark
  // grey.  Exercises the explicit `@axisPosition` and `<axisColor>`
  // pair of §18.3.1.28.
  cases.push({
    id: "cf-databar-axis-middle",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v_neg_pos))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_data_bar_extended(
            "1",
            s_cfvo("min", None),
            s_cfvo("max", None),
            s_color("FF638EC6"),
            Some("middle"),
            Some("FF000000"),
            Some("FFFF555A"),
          ),
        ]),
      ),
    ]),
  })

  // ---- 7. 2-colour colorScale (blue → white) — §18.3.1.16 ---------
  // Alt 2-colour palette: a cool low → neutral high gradient that is
  // visually distinct from the existing red→green default.
  cases.push({
    id: "cf-colorscale-2-bluewhite",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_color_scale(
            "1",
            [s_cfvo("min", None), s_cfvo("max", None)],
            [s_color("FF5A8AC6"), s_color("FFFFFFFF")],
          ),
        ]),
      ),
    ]),
  })

  // ---- 8. 3-colour colorScale with percentile-anchored stops ------
  // 3-stop gradient where the midpoint is anchored to the 50th
  // percentile and the endpoints to `min` / `max`.  Same palette
  // (green → yellow → red, reversed) as a heat-map alternative; the
  // mid CFVO uses `percentile` (not `percent`) to exercise that
  // type-of-anchor branch.
  cases.push({
    id: "cf-colorscale-3-percentile-greenred",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_color_scale(
            "1",
            [
              s_cfvo("min", None),
              s_cfvo("percentile", Some("50")),
              s_cfvo("max", None),
            ],
            [s_color("FF63BE7B"), s_color("FFFFEB84"), s_color("FFF8696B")],
          ),
        ]),
      ),
    ]),
  })
}

///|
/// Conditional-formatting fixtures whose rules rely on a `dxfId`
/// reference into the workbook's `styles.xml` `<dxfs>` table — every
/// rule kind whose visual is "overlay this fill on the matching cell"
/// rather than a kind that embeds its own colours / icons.
///
/// Pushed under category "cf" so they land in
/// `.snapshots/fixtures/xlsx/cf/`, alongside the embedded-visual
/// fixtures.  Each `ExtendedCase` carries its own minimal `styleSheet`
/// whose `<dxfs>` contains a single solid-fill `<dxf>` at index 0 —
/// the rules reference it with `dxfId="0"`.
fn extras_sml_cf_complete_styled(xcases : Array[ExtendedCase]) -> Unit {
  // Shared styles part — a single red dxf at index 0.  Mirrors the
  // viewer test `cf_styles_with_red_dxf()` so a `dxfId="0"` overlay
  // resolves to the same overlay colour the unit tests assert against.
  let red_dxf_styles = cf_styles_with_dxf_color("FFFF6666")
  // Yellow variant — used by the multi-rule fixture so the two
  // overlays do not collapse into the same colour.
  let amber_dxf_styles = cf_styles_with_dxf_color("FFFFD966")
  // 10-row numeric ramp 10/20/.../100.
  let v10_inc = ["10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]
  // 10-row inline-text column for containsText / notContains.
  let words = [
    "Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape", "Honeydew",
    "Kiwi", "Lemon",
  ]

  // Helper: build a `<sheetData>` whose column A carries inline
  // strings (the text-predicate population).
  let words_rows = fn() -> Array[@xml.Node] {
    let rows : Array[@xml.Node] = []
    for i, w in words {
      let r = (i + 1).to_string()
      rows.push(Element(s_row(r, [s_inline("A" + r, w)])))
    }
    rows
  }

  // ---- 1. cellIs / lessThan — §18.3.1.10 / §18.18.15 OpLessThan ---
  // Highlight any cell whose value is < 50 in the 10..100 ramp; the
  // bottom four cells (10/20/30/40) match.
  xcases.push({
    id: "cf-cellis-lessthan",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_cell_is("lessThan", ["50"], "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 2. cellIs / greaterThan — §18.18.15 OpGreaterThan ----------
  // Highlight cells > 60 — top four (70/80/90/100) match.
  xcases.push({
    id: "cf-cellis-greaterthan",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_cell_is("greaterThan", ["60"], "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 3. cellIs / equal — §18.18.15 OpEqual ---------------------
  // Highlight only the cell whose value equals 50.  One match.
  xcases.push({
    id: "cf-cellis-equal",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_cell_is("equal", ["50"], "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 4. cellIs / between — §18.18.15 OpBetween ------------------
  // Two `<formula>` children — inclusive band [30, 70].  Cells 30, 40,
  // 50, 60, 70 match.
  xcases.push({
    id: "cf-cellis-between",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_cell_is("between", ["30", "70"], "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 5. cellIs / notBetween — §18.18.15 OpNotBetween ------------
  // Outside [30, 70] — cells 10, 20, 80, 90, 100 match.
  xcases.push({
    id: "cf-cellis-notbetween",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_cell_is("notBetween", ["30", "70"], "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 6. containsText — §18.3.1.10 ContainsText ------------------
  // Highlight every fruit name that contains "an" — "Banana".  One
  // match.  `@text` attribute carries the needle and `<formula>`
  // mirrors the SEARCH() idiom Excel emits for re-evaluators.
  xcases.push({
    id: "cf-containstext",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], words_rows())),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_contains_text("containsText", "an", "A1:A10", "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 7. notContains (a.k.a. "notContainsText") — §18.18.15 ------
  // Inverse predicate of the above — every fruit that does NOT contain
  // "an" matches.  9 cells.  The spec spelling of the operator is
  // `notContains`; the human-friendly name "notContainsText" appears
  // in documentation but is encoded as `operator="notContains"` on a
  // `containsText`-type rule.
  xcases.push({
    id: "cf-notcontainstext",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], words_rows())),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_contains_text("notContains", "an", "A1:A10", "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 8. expression — §18.3.1.10 / type="expression" -------------
  // Free-form boolean formula: every odd-indexed cell (rows 1/3/5/7/9)
  // matches via `MOD(ROW(),2)=1`.  Exercises the expression-type rule
  // dispatch.
  xcases.push({
    id: "cf-expression-oddrows",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_expression("MOD(ROW(),2)=1", "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 9. top10 / top-3 — §18.3.1.10 / §18.3.1.42 Top10 -----------
  // Highlight the top 3 cells of the 10-row population.  Cells 80, 90,
  // 100 match.
  xcases.push({
    id: "cf-top10-top3",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [cf_rule_top10("3", None, "0", "1")]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 10. top10 / bottom-3 — §18.3.1.10 with @bottom="1" ---------
  // The `bottom="1"` attribute flips the predicate from "top N" to
  // "bottom N".  Cells 10, 20, 30 match.
  xcases.push({
    id: "cf-top10-bottom3",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_top10("3", Some("1"), "0", "1"),
        ]),
      ),
    ]),
    styles: Some(amber_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 11. aboveAverage — §18.3.1.10 ------------------------------
  // Mean of the 10..100 ramp is 55; cells > 55 (60/70/80/90/100) match.
  xcases.push({
    id: "cf-aboveaverage",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          cf_rule_above_average("1", "0", "1"),
        ]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 12. uniqueValues — §18.3.1.10 ------------------------------
  // Mostly-unique ramp with two duplicates (the two "30"s).  Eight
  // cells (the singletons) match.
  let v_uniq = ["10", "30", "30", "50", "70", "80", "90", "90", "95", "100"]
  xcases.push({
    id: "cf-uniquevalues",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v_uniq))),
      Element(
        s_conditional_formatting("A1:A10", [cf_rule_unique_values("0", "1")]),
      ),
    ]),
    styles: Some(red_dxf_styles),
    numbering: None,
    doc_styles: None,
  })

  // ---- 13. duplicateValues — §18.3.1.10 ---------------------------
  // Same population — the duplicate pairs (30/30 and 90/90) match.
  xcases.push({
    id: "cf-duplicatevalues",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v_uniq))),
      Element(
        s_conditional_formatting("A1:A10", [cf_rule_duplicate_values("0", "1")]),
      ),
    ]),
    styles: Some(amber_dxf_styles),
    numbering: None,
    doc_styles: None,
  })
}
