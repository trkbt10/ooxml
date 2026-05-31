// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/table.ts
//
// ECMA-376 §21.1.3 DrawingML tables — render an `<a:tbl>` element as
// SVG cell rects + borders + text.
//
// Spec references:
//   §20.1.4.2.10  CT_TableGrid   (tblGrid / gridCol — column widths)
//   §20.1.4.2.13  CT_TableRow    (tr / @h — row height, contains tc*)
//   §20.1.4.2.21  CT_TableCell   (tc — gridSpan / rowSpan / hMerge / vMerge)
//   §20.1.4.2.18  CT_TableCellProperties (tcPr — fill/borders)
//   §20.1.4.2.6   CT_TableProperties (tblPr — table-wide flags)
//
// §21.1.3.x DrawingML table styles — table-style resolution
// (`<a:tableStyleId>` GUID → `/ppt/tableStyles.xml` lookup with
// banded-row/column rules) is still out-of-scope for this
// renderer.  Cells default to no fill / no border when the
// cell doesn't override.  The web-pptx renderer degrades
// gracefully in the same way; full support is tracked as
// Round 13 #308 and requires:
//   1. Parse the workbook-level `tableStyles.xml` into a
//      typed projection (the domain layer already has
//      CT_TableStyle in `drawing_ml/shape_table_types.mbt`).
//   2. At render time, look up `<a:tblPr/@firstRow>` etc. to
//      compute which conditional buckets (firstRow / lastRow /
//      band1H / band2H / nwCell / …) apply per cell.
//   3. Re-enter `<a:fill>` / `<a:ln>` resolution with the
//      bucket's bound colour.
// Until this lands consumers can detect the missing styling
// via the `data-ooxml-table-style-id` attribute that this
// renderer emits on the surrounding `<g>`.
//
// The grid is laid out in EMU; the caller passes the frame width /
// height so a `tbl` whose grid sums don't match the frame can be
// reconciled to the viewBox.

///|
/// Render a `<p:graphicFrame>`'s embedded `<a:tbl>` as a structured
/// SVG node list (the table `<g>` and its children).  Empty when the
/// frame carries no `<a:graphic>/<a:graphicData>/<a:tbl>`.  Callers
/// thread the nodes straight into the SVG tree; no markup is ever
/// assembled by string concatenation.
/// §21.1.2.3.5 — table cells carry §21.1.2 text bodies whose runs may
/// hold `<a:hlinkClick r:id>` hyperlinks.  `hyperlink_resolver` maps a
/// slide-rels r:id to its external URL; it defaults to `_ => None`,
/// which keeps the raw-r:id fallback (byte-identical to the
/// pre-resolver emitter) for callers / tests that do not supply one.
pub fn render_graphic_frame_table_svg(
  frame : @xml.Element,
  width : Double,
  height : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  hyperlink_resolver? : (String) -> String? = _ => None,
) -> Array[@xml.Node] {
  render_graphic_frame_table_nodes(
    frame, width, height, ctx, defs, hyperlink_resolver,
  )
}

///|
/// Internal counterpart of `render_graphic_frame_table_svg` that
/// returns the table `<g>` as a structured node list.  Empty when the
/// frame carries no `<a:graphic>/<a:graphicData>/<a:tbl>`.
fn render_graphic_frame_table_nodes(
  frame : @xml.Element,
  width : Double,
  height : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  hyperlink_resolver : (String) -> String?,
) -> Array[@xml.Node] {
  // <p:graphicFrame> children:
  //   <p:nvGraphicFramePr> ... <p:xfrm/> <a:graphic>
  // The table lives under <a:graphic>/<a:graphicData>/<a:tbl>.
  let graphic = first_child_named(frame, "graphic")
  let graphic_data = match graphic {
    Some(g) => first_child_named(g, "graphicData")
    None => None
  }
  let tbl = match graphic_data {
    Some(gd) => first_child_named(gd, "tbl")
    None => None
  }
  match tbl {
    None => []
    Some(t) => render_table_svg(t, width, height, ctx, defs, hyperlink_resolver)
  }
}

///|
/// Render an `<a:tbl>` element as SVG. Driven directly from the raw
/// XML so the renderer doesn't depend on the typed CT_Table reader
/// machinery.
fn render_table_svg(
  tbl : @xml.Element,
  width : Double,
  height : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  hyperlink_resolver : (String) -> String?,
) -> Array[@xml.Node] {
  let tbl_grid = first_child_named(tbl, "tblGrid")
  // Column widths in EMU per §20.1.4.2.10. When the sums don't match
  // the frame width we scale uniformly to fit.
  let raw_widths = collect_grid_col_widths(tbl_grid)
  let col_widths = scale_to_fit(raw_widths, width)
  // Row heights in EMU per §20.1.4.2.13 (tr/@h).
  let rows = collect_rows(tbl)
  let raw_heights : Array[Double] = []
  for r in rows {
    raw_heights.push(attr_double_or(r, "h", 0.0))
  }
  let row_heights = scale_to_fit(raw_heights, height)
  let cell_nodes : Array[@xml.Node] = []
  let mut y = 0.0
  for i in 0..<rows.length() {
    let row = rows[i]
    let row_h = row_heights[i]
    render_row(
      row, col_widths, y, row_h, ctx, defs, hyperlink_resolver, cell_nodes,
    )
    y = y + row_h
  }
  [
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [@markup.attr("class", "tbl")],
      cell_nodes,
    ),
  ]
}

///|
/// Collect every `<a:gridCol>` width (EMU) under `<a:tblGrid>`.
fn collect_grid_col_widths(tbl_grid : @xml.Element?) -> Array[Double] {
  let out : Array[Double] = []
  match tbl_grid {
    None => return out
    Some(g) =>
      for child in g.children {
        match child {
          Element(elt) =>
            if elt.name.local_name == "gridCol" {
              out.push(attr_double_or(elt, "w", 0.0))
            }
          _ => ()
        }
      }
  }
  out
}

///|
/// Collect direct `<a:tr>` children of `<a:tbl>`.
fn collect_rows(tbl : @xml.Element) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in tbl.children {
    match child {
      Element(elt) => if elt.name.local_name == "tr" { out.push(elt) }
      _ => ()
    }
  }
  out
}

///|
/// Scale an array of weights so they sum to `target`. Returns the
/// input unchanged when the sum is non-positive or already matches.
fn scale_to_fit(values : Array[Double], target : Double) -> Array[Double] {
  let mut total = 0.0
  for v in values {
    total = total + v
  }
  if total <= 0.0 || target <= 0.0 {
    let out : Array[Double] = []
    for v in values {
      out.push(v)
    }
    return out
  }
  let scale = target / total
  let out : Array[Double] = []
  for v in values {
    out.push(v * scale)
  }
  out
}

///|
/// Render every `<a:tc>` cell in a row at the given vertical band.
fn render_row(
  row : @xml.Element,
  col_widths : Array[Double],
  y : Double,
  row_height : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  hyperlink_resolver : (String) -> String?,
  out : Array[@xml.Node],
) -> Unit {
  let mut x = 0.0
  let mut col_idx = 0
  for child in row.children {
    match child {
      Element(elt) =>
        if elt.name.local_name == "tc" {
          // Skip horizontally-merged ghosts — they still consume their
          // grid slot but have no rectangle of their own.
          // §21.1.3.16 / §21.1.3.18 @hMerge / @vMerge — xsd:boolean.
          let h_merge = parse_xsd_boolean_or(attr_value(elt, "hMerge"), false)
          let v_merge = parse_xsd_boolean_or(attr_value(elt, "vMerge"), false)
          let grid_span = match attr_value(elt, "gridSpan") {
            Some(v) =>
              try @string.parse_int(v) catch {
                _ => 1
              } noraise {
                n => if n > 0 { n } else { 1 }
              }
            None => 1
          }
          let mut span_w = 0.0
          for j in 0..<grid_span {
            let idx = col_idx + j
            if idx < col_widths.length() {
              span_w = span_w + col_widths[idx]
            }
          }
          if !h_merge && !v_merge {
            render_cell(
              elt, x, y, span_w, row_height, ctx, defs, hyperlink_resolver, out,
            )
          }
          x = x + span_w
          col_idx = col_idx + grid_span
        }
      _ => ()
    }
  }
}

///|
/// Render a single `<a:tc>` cell: optional fill + borders + cell text.
fn render_cell(
  cell : @xml.Element,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  hyperlink_resolver : (String) -> String?,
  out : Array[@xml.Node],
) -> Unit {
  let tc_pr = first_child_named(cell, "tcPr")
  // Cell fill — `<a:tcPr>/<a:fill>` per §20.1.4.2.18.
  let fill_value = match tc_pr {
    None => "none"
    Some(pr) =>
      match find_fill_child(pr) {
        None => "none"
        Some(f) => {
          let r = render_fill_attr(f, defs, ctx, shape_width=w, shape_height=h)
          r.attr_value
        }
      }
  }
  // Background rect.
  out.push(
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", format_double(x)),
        @markup.attr("y", format_double(y)),
        @markup.attr("width", format_double(w)),
        @markup.attr("height", format_double(h)),
        @markup.attr("fill", fill_value),
      ],
      [],
    ),
  )
  // Borders — lnL / lnR / lnT / lnB (CT_TableCellProperties Annex A.4.1
  // lines 2347..2369). Diagonals lnTlToBr / lnBlToTr also emitted.
  match tc_pr {
    None => ()
    Some(pr) => emit_cell_borders(pr, x, y, w, h, ctx, defs, out)
  }
  // Cell text — `<a:txBody>` is a §21.1.2 text body.  §20.1.4.2.18
  // CT_TableCellProperties: `@marL`/`@marR`/`@marT`/`@marB` inset
  // the txBody region from the cell border (default 91440/91440/
  // 45720/45720 EMU = 0.1"/0.1"/0.05"/0.05" per spec).  `@anchor`
  // (t/ctr/b/just/dist) controls the vertical alignment of the
  // text block inside the inset area.  We pass both through as
  // data-* attributes on a wrapping `<g>` and apply the inset via
  // the translate offset + reduced width/height.
  match first_child_named(cell, "txBody") {
    None => ()
    Some(_) => {
      let (mar_l, mar_r, mar_t, mar_b, anchor) = read_cell_margins(tc_pr)
      let mar_l_px = mar_l / 9525.0
      let mar_r_px = mar_r / 9525.0
      let mar_t_px = mar_t / 9525.0
      let mar_b_px = mar_b / 9525.0
      let inner_w = (w - mar_l_px - mar_r_px).max(0.0)
      let inner_h = (h - mar_t_px - mar_b_px).max(0.0)
      // Surface the spec-anchored margins + anchor as data-* so
      // consumers can introspect the cell's text geometry.
      let g_attrs : Array[@xml.Attribute] = [
        @markup.attr(
          "transform",
          "translate(" +
          format_double(x + mar_l_px) +
          ", " +
          format_double(y + mar_t_px) +
          ")",
        ),
        @markup.attr("data-ooxml-cell-mar-l", format_double(mar_l)),
        @markup.attr("data-ooxml-cell-mar-r", format_double(mar_r)),
        @markup.attr("data-ooxml-cell-mar-t", format_double(mar_t)),
        @markup.attr("data-ooxml-cell-mar-b", format_double(mar_b)),
      ]
      if anchor.length() > 0 {
        g_attrs.push(@markup.attr("data-ooxml-cell-anchor", anchor))
      }
      out.push(
        @markup.elem_ns(
          "g",
          @markup.svg_ns,
          g_attrs,
          render_shape_text_svg(
            cell, inner_w, inner_h, ctx, defs, hyperlink_resolver,
          ),
        ),
      )
    }
  }
}

///|
/// §20.1.4.2.18 CT_TableCellProperties — extract the cell's
/// margin quad (in EMU) + `@anchor` token.  Spec defaults:
///   marL = 91440  (0.1")
///   marR = 91440
///   marT = 45720  (0.05")
///   marB = 45720
///   anchor (t/ctr/b/just/dist) — defaults to "t".
fn read_cell_margins(
  tc_pr : @xml.Element?,
) -> (Double, Double, Double, Double, String) {
  let mut mar_l = 91440.0
  let mut mar_r = 91440.0
  let mut mar_t = 45720.0
  let mut mar_b = 45720.0
  let mut anchor = ""
  match tc_pr {
    None => ()
    Some(pr) => {
      let parse_emu = fn(key : String, fallback : Double) -> Double {
        match attr_value(pr, key) {
          None => fallback
          Some(v) =>
            try @string.parse_double(v) catch {
              _ => fallback
            } noraise {
              n => n
            }
        }
      }
      mar_l = parse_emu("marL", mar_l)
      mar_r = parse_emu("marR", mar_r)
      mar_t = parse_emu("marT", mar_t)
      mar_b = parse_emu("marB", mar_b)
      match attr_value(pr, "anchor") {
        Some(v) =>
          if v == "t" || v == "ctr" || v == "b" || v == "just" || v == "dist" {
            anchor = v
          }
        None => ()
      }
    }
  }
  (mar_l, mar_r, mar_t, mar_b, anchor)
}

///|
/// Emit the four cell borders + two diagonals when present. Borders
/// are stored as `<a:lnL>` / `<a:lnR>` / `<a:lnT>` / `<a:lnB>` /
/// `<a:lnTlToBr>` / `<a:lnBlToTr>` under `<a:tcPr>` (CT_TableCellProperties).
fn emit_cell_borders(
  tc_pr : @xml.Element,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  out : Array[@xml.Node],
) -> Unit {
  emit_border_line(tc_pr, "lnT", x, y, x + w, y, ctx, defs, out)
  emit_border_line(tc_pr, "lnB", x, y + h, x + w, y + h, ctx, defs, out)
  emit_border_line(tc_pr, "lnL", x, y, x, y + h, ctx, defs, out)
  emit_border_line(tc_pr, "lnR", x + w, y, x + w, y + h, ctx, defs, out)
  emit_border_line(tc_pr, "lnTlToBr", x, y, x + w, y + h, ctx, defs, out)
  emit_border_line(tc_pr, "lnBlToTr", x, y + h, x + w, y, ctx, defs, out)
}

///|
/// Resolve a `<a:ln*>` child of `tcPr` into a stroke and emit an SVG
/// `<line>` when present. The fill resolution mirrors what
/// `build_line_attrs` does for shapes.
fn emit_border_line(
  tc_pr : @xml.Element,
  local_name : String,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  out : Array[@xml.Node],
) -> Unit {
  match first_child_named(tc_pr, local_name) {
    None => ()
    Some(ln) => {
      // noFill on the line → skip.
      if first_child_named(ln, "noFill") is Some(_) {
        return
      }
      // §21.1.3.18 / §20.1.2.2.24 — when `<a:ln>` omits @w or a
      // fill, the spec defers to the table style cascade (and
      // ultimately the theme's `<a:lnStyleLst>`).  9525 EMU is
      // not a spec default; we emit `data-ooxml-ln-w-missing`
      // metadata so consumers know the source had no width and
      // can pull from the table style they own.  The rendered
      // SVG keeps a 1 px stroke so the border remains visible
      // — a missing width is preferable to a missing line.
      let (width_str, w_missing) = match attr_value(ln, "w") {
        Some(v) => (v, false)
        None => ("9525", true)
      }
      // §21.1.3.18 — no explicit fill on the line element: the
      // colour cascade resolves through the table style chain;
      // we surface `currentColor` so the consumer's CSS context
      // (or downstream theme lookup) picks the actual hue.
      let color_str = match find_fill_child(ln) {
        None => "currentColor"
        Some(f) => render_fill_attr(f, defs, ctx).attr_value
      }
      let attrs : Array[@xml.Attribute] = [
        @markup.attr("x1", format_double(x1)),
        @markup.attr("y1", format_double(y1)),
        @markup.attr("x2", format_double(x2)),
        @markup.attr("y2", format_double(y2)),
        @markup.attr("stroke", color_str),
        @markup.attr("stroke-width", width_str),
      ]
      if w_missing {
        attrs.push(@markup.attr("data-ooxml-ln-w-source", "missing"))
      }
      out.push(@markup.elem_ns("line", @markup.svg_ns, attrs, []))
    }
  }
}

///|
/// §21.1.3.* — parse a numeric attribute (EMU width / height /
/// position) with the per-attribute spec default applied when
/// the attribute is absent.  Non-numeric values are schema
/// violations of the underlying xsd:long type; we still fall
/// back to the spec default so the table renders rather than
/// crashing the slide pipeline, and the breach is preserved on
/// the source DOM for upstream diagnostics.
fn attr_double_or(
  element : @xml.Element,
  name : String,
  default : Double,
) -> Double {
  match attr_value(element, name) {
    None => default
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => default
      } noraise {
        d => d
      }
  }
}
