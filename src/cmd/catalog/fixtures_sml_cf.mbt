// SpreadsheetML CONDITIONAL FORMATTING fixtures — `<conditionalFormatting>`
// siblings of `<sheetData>` carrying `<cfRule type="colorScale|dataBar|
// iconSet">` elements (ECMA-376 §18.3.1.18 and §18.3.1.16).
//
// These fixtures use the rule kinds that EMBED their own visual data —
// colorScale colours, dataBar colour, iconSet icon-set name — and so
// do NOT need a `styles.xml` `dxfId` reference.  That keeps every
// case as a plain `VisualCase` (worksheet element root) wired through
// `extra_cases()` in `fixtures_categories.mbt`, with no
// `ExtendedCase`/styles plumbing required.
//
// Lay-out: each fixture content is a `<worksheet>` with
//   <sheetData>…rows of numeric values…</sheetData>
//   <conditionalFormatting sqref="A1:A10"> <cfRule …/> </conditionalFormatting>
// so the renderer must (a) lay out the cell grid and (b) apply the
// CF visualisation on top of those cells.

///|
/// One `<cfvo>` (Conditional Formatting Value Object) — a threshold
/// indicator used by colorScale / dataBar / iconSet rules.  `type` is
/// `min` / `max` / `num` / `percent` / `percentile` / `formula`; `val`
/// is required for every type except `min` / `max`.
fn s_cfvo(type_ : String, val : String?) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [xa("type", type_)]
  match val {
    Some(v) => attrs.push(xa("val", v))
    None => ()
  }
  xe(NS_S, "cfvo", attrs, [])
}

///|
/// One `<color rgb="FFRRGGBB"/>` child of a colorScale / dataBar /
/// iconSet rule — the SpreadsheetML colour reference uses the
/// `rgb=`-attribute form (ARGB hex), NOT a `<srgbClr>` element.
fn s_color(argb : String) -> @xml.Element {
  xe(NS_S, "color", [xa("rgb", argb)], [])
}

///|
/// A `<cfRule type="colorScale">` wrapping a 2-stop or 3-stop
/// `<colorScale>` definition.  Caller supplies the cfvo list and the
/// matching colour list — they MUST be the same length (2 or 3).
fn s_cf_rule_color_scale(
  priority : String,
  cfvos : Array[@xml.Element],
  colors : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cfvos {
    kids.push(Element(c))
  }
  for c in colors {
    kids.push(Element(c))
  }
  xe(NS_S, "cfRule", [xa("type", "colorScale"), xa("priority", priority)], [
    Element(xe(NS_S, "colorScale", [], kids)),
  ])
}

///|
/// A `<cfRule type="dataBar">` wrapping a `<dataBar>` definition.
/// Two cfvos (min / max) and ONE colour — the bar fill colour.
fn s_cf_rule_data_bar(
  priority : String,
  cfvo_min : @xml.Element,
  cfvo_max : @xml.Element,
  color : @xml.Element,
) -> @xml.Element {
  xe(NS_S, "cfRule", [xa("type", "dataBar"), xa("priority", priority)], [
    Element(
      xe(NS_S, "dataBar", [], [
        Element(cfvo_min),
        Element(cfvo_max),
        Element(color),
      ]),
    ),
  ])
}

///|
/// A `<cfRule type="iconSet">` wrapping an `<iconSet iconSet="...">`.
/// The cfvo list size matches the iconSet (3, 4 or 5 stops).
fn s_cf_rule_icon_set(
  priority : String,
  icon_set_name : String,
  cfvos : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cfvos {
    kids.push(Element(c))
  }
  xe(NS_S, "cfRule", [xa("type", "iconSet"), xa("priority", priority)], [
    Element(xe(NS_S, "iconSet", [xa("iconSet", icon_set_name)], kids)),
  ])
}

///|
/// A `<conditionalFormatting sqref="...">` wrapping one or more cf
/// rules.  Mirrors the worksheet-level container element.
fn s_conditional_formatting(
  sqref : String,
  rules : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for r in rules {
    kids.push(Element(r))
  }
  xe(NS_S, "conditionalFormatting", [xa("sqref", sqref)], kids)
}

///|
/// Build a vertical 10-row column-A numeric ramp with the given
/// values — typical input for a colorScale / dataBar fixture.
fn cf_ramp_rows_a(values : Array[String]) -> Array[@xml.Node] {
  let rows : Array[@xml.Node] = []
  for i, v in values {
    let r = (i + 1).to_string()
    rows.push(Element(s_row(r, [s_cell("A" + r, v)])))
  }
  rows
}

///|
/// Conditional-formatting fixtures.  Adds 12 cases under category
/// "cf" — landing in `.snapshots/fixtures/xlsx/cf/`.
///
/// Each fixture pairs a `<sheetData>` of numeric cells (the input
/// the CF rule is interpreted against) with a sibling
/// `<conditionalFormatting>` carrying one or more `<cfRule>`.  Only
/// rule kinds that embed their own colours / icon-sets are used so
/// none of the fixtures need a `dxfId` from `styles.xml`.
fn extras_sml_cf(cases : Array[VisualCase]) -> Unit {
  // ---- xlsx / cf — 2-colour heat map (red → green) -----------------
  // 1. 2-colour colorScale over A1:A10 with monotonically increasing
  //    values, so the gradient runs cleanly from red (min) to green
  //    (max) down the column.
  let v10_inc = ["10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]
  cases.push({
    id: "cf-colorscale-2-redgreen",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_color_scale(
            "1",
            [s_cfvo("min", None), s_cfvo("max", None)],
            // ECMA-376 default 2-colour: red (FFF8696B) → green (FF63BE7B).
            [s_color("FFF8696B"), s_color("FF63BE7B")],
          ),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — 3-colour heat map (red → yellow → green) -------
  // 2. 3-stop colorScale with mid=50% — classic "low / mid / high"
  //    heat-map gradient.
  cases.push({
    id: "cf-colorscale-3-redyellowgreen",
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
            // ECMA-376 default 3-colour: red, yellow, green.
            [s_color("FFF8696B"), s_color("FFFFEB84"), s_color("FF63BE7B")],
          ),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — blue data-bar ---------------------------------
  // 3. Solid blue horizontal dataBar over A1:A10 with the same
  //    increasing ramp — bars should grow left→right with the value.
  cases.push({
    id: "cf-databar-blue",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_data_bar(
            "1",
            s_cfvo("min", None),
            s_cfvo("max", None),
            // Standard blue dataBar default (FF638EC6).
            s_color("FF638EC6"),
          ),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — red data-bar (gradient look) ------------------
  // 4. Same dataBar geometry, red colour.  Excel uses gradient bars
  //    by default; we exercise the kind WITHOUT an explicit
  //    `<negativeFillColor>` / `<axisColor>` to ensure the basic
  //    positive-only ramp renders.
  cases.push({
    id: "cf-databar-redgrad",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_data_bar(
            "1",
            s_cfvo("min", None),
            s_cfvo("max", None),
            s_color("FFFF555A"),
          ),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — 3-traffic-lights icon set ---------------------
  // 5. `3TrafficLights1`: red / yellow / green circles, switching at
  //    33 / 67 % percentile thresholds.
  cases.push({
    id: "cf-iconset-3lights",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_icon_set("1", "3TrafficLights1", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("33")),
            s_cfvo("percent", Some("67")),
          ]),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — 3-arrows icon set -----------------------------
  // 6. `3Arrows`: down / flat / up arrow icons coloured red / yellow /
  //    green.  Same percentile thresholds as the traffic lights.
  cases.push({
    id: "cf-iconset-3arrows",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_icon_set("1", "3Arrows", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("33")),
            s_cfvo("percent", Some("67")),
          ]),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — 4-ratings icon set (bars) ---------------------
  // 7. `4Rating`: four ascending histogram-bar icons.  Four cfvo
  //    thresholds at 0 / 25 / 50 / 75 %.
  cases.push({
    id: "cf-iconset-4ratings",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_icon_set("1", "4Rating", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("25")),
            s_cfvo("percent", Some("50")),
            s_cfvo("percent", Some("75")),
          ]),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — 5-quarters icon set (pie segments) ------------
  // 8. `5Quarters`: five black/white pie-quarter icons at 0/20/40/60/80.
  cases.push({
    id: "cf-iconset-5quarters",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_icon_set("1", "5Quarters", [
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

  // ---- xlsx / cf — 2-colour scale on a different value pattern ---
  // 9. A non-monotone ramp (zig-zag) to exercise per-cell colour
  //    interpolation — the gradient must follow the actual values,
  //    not the row order.
  let v_zigzag = ["50", "10", "90", "20", "80", "30", "70", "40", "60", "100"]
  cases.push({
    id: "cf-colorscale-vertical-grid",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v_zigzag))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_color_scale(
            "1",
            [
              s_cfvo("min", None),
              s_cfvo("percentile", Some("50")),
              s_cfvo("max", None),
            ],
            [s_color("FF5A8AC6"), s_color("FFFCFCFF"), s_color("FFF8696B")],
          ),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — data-bar across negative + positive values ----
  // 10. A range with negatives, zero and positives.  Without a
  //     `<negativeFillColor>` the dataBar reader must still place a
  //     value at the appropriate proportion of the band.
  let v_neg_pos = [
    "-50", "-30", "-10", "0", "10", "30", "50", "70", "90", "100",
  ]
  cases.push({
    id: "cf-databar-numeric-range",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v_neg_pos))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_data_bar(
            "1",
            s_cfvo("min", None),
            s_cfvo("max", None),
            s_color("FF638EC6"),
          ),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — multiple rules on the same range --------------
  // 11. Both a 2-colour scale (priority 2) AND a dataBar (priority 1)
  //     applied to A1:A10.  Excel evaluates lower priority first;
  //     the dataBar paints on top of the cell-fill scale.
  cases.push({
    id: "cf-multi-rules",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v10_inc))),
      Element(
        s_conditional_formatting("A1:A10", [
          s_cf_rule_data_bar(
            "1",
            s_cfvo("min", None),
            s_cfvo("max", None),
            s_color("FF638EC6"),
          ),
          s_cf_rule_color_scale(
            "2",
            [s_cfvo("min", None), s_cfvo("max", None)],
            [s_color("FFF8696B"), s_color("FF63BE7B")],
          ),
        ]),
      ),
    ]),
  })

  // ---- xlsx / cf — large range with an iconSet -------------------
  // 12. 50-cell column (A1:A50) — exercises the per-row icon
  //     placement at scale.  Values increase 1..50 so percentile
  //     thresholds at 0/33/67 split into three even thirds.
  let v_50 : Array[String] = []
  for i in 1..<51 {
    v_50.push(i.to_string())
  }
  cases.push({
    id: "cf-large-range",
    format: "xlsx",
    category: "cf",
    content: xe(NS_S, "worksheet", [], [
      Element(xe(NS_S, "sheetData", [], cf_ramp_rows_a(v_50))),
      Element(
        s_conditional_formatting("A1:A50", [
          s_cf_rule_icon_set("1", "3TrafficLights1", [
            s_cfvo("percent", Some("0")),
            s_cfvo("percent", Some("33")),
            s_cfvo("percent", Some("67")),
          ]),
        ]),
      ),
    ]),
  })
}
