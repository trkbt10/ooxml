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
  table_style_list? : @a.CT_TableStyleList? = None,
) -> Array[@xml.Node] {
  render_graphic_frame_table_nodes(
    frame, width, height, ctx, defs, hyperlink_resolver, table_style_list,
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
  table_style_list : @a.CT_TableStyleList?,
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
    Some(t) =>
      render_table_svg(
        t, width, height, ctx, defs, hyperlink_resolver, table_style_list,
      )
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
  table_style_list : @a.CT_TableStyleList?,
) -> Array[@xml.Node] {
  let tbl_pr = first_child_named(tbl, "tblPr")
  let table_style = resolve_table_style(tbl_pr, table_style_list)
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
  let table_attrs = table_svg_attrs(tbl_pr, table_style)
  let cell_nodes : Array[@xml.Node] = []
  let (table_bg_fill, table_bg_source) = match tbl_pr {
    Some(pr) =>
      match find_fill_child(pr) {
        Some(f) => (Some(f), "tblPr")
        None => (table_style_background_fill(table_style), "style")
      }
    None => (table_style_background_fill(table_style), "style")
  }
  match table_bg_fill {
    Some(fill) => {
      let r = render_fill_attr(
        fill,
        defs,
        ctx,
        shape_width=width,
        shape_height=height,
      )
      cell_nodes.push(
        @markup.elem_ns(
          "rect",
          @markup.svg_ns,
          [
            @markup.attr("x", "0"),
            @markup.attr("y", "0"),
            @markup.attr("width", format_double(width)),
            @markup.attr("height", format_double(height)),
            @markup.attr("fill", r.attr_value),
            @markup.attr("data-ooxml-table-bg-source", table_bg_source),
          ],
          [],
        ),
      )
    }
    None => ()
  }
  let mut y = 0.0
  for i in 0..<rows.length() {
    let row = rows[i]
    let row_h = row_heights[i]
    render_row(
      row,
      i,
      rows.length(),
      col_widths,
      y,
      row_h,
      ctx,
      defs,
      hyperlink_resolver,
      table_style,
      tbl_pr,
      cell_nodes,
    )
    y = y + row_h
  }
  [@markup.elem_ns("g", @markup.svg_ns, table_attrs, cell_nodes)]
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
/// Resolve the table style declared by `<a:tblPr>`. Inline
/// `<a:tableStyle>` wins; otherwise `<a:tableStyleId>` looks up the
/// presentation part's `/ppt/tableStyles.xml` projection supplied by
/// the context layer.
fn resolve_table_style(
  tbl_pr : @xml.Element?,
  table_style_list : @a.CT_TableStyleList?,
) -> @xml.Element? {
  let pr = match tbl_pr {
    Some(p) => p
    None => return None
  }
  match first_child_named(pr, "tableStyle") {
    Some(style) => return Some(style)
    None => ()
  }
  let style_id = match first_child_named(pr, "tableStyleId") {
    Some(id_el) => text_content(id_el).trim(chars=" \t\r\n").to_owned()
    None =>
      match table_style_list {
        Some(list) => list.def
        None => return None
      }
  }
  find_table_style_by_id(table_style_list, style_id)
}

///|
fn find_table_style_by_id(
  table_style_list : @a.CT_TableStyleList?,
  style_id : String,
) -> @xml.Element? {
  let list = match table_style_list {
    Some(l) => l
    None => return None
  }
  for style in list.tbl_style {
    if style.style_id == style_id {
      return Some(style.element)
    }
  }
  None
}

///|
fn table_svg_attrs(
  tbl_pr : @xml.Element?,
  table_style : @xml.Element?,
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = [@markup.attr("class", "tbl")]
  match table_style {
    Some(style) => {
      match attr_value(style, "styleId") {
        Some(v) => attrs.push(@markup.attr("data-ooxml-table-style-id", v))
        None => ()
      }
      match attr_value(style, "styleName") {
        Some(v) => attrs.push(@markup.attr("data-ooxml-table-style-name", v))
        None => ()
      }
      match first_child_named(style, "tblBg") {
        Some(bg) =>
          match first_child_named(bg, "effect") {
            Some(effect) =>
              attrs.push(
                @markup.attr(
                  "data-ooxml-table-bg-effect",
                  element_child_local_names(effect),
                ),
              )
            None => ()
          }
        None => ()
      }
    }
    None =>
      match tbl_pr {
        Some(pr) =>
          match first_child_named(pr, "tableStyleId") {
            Some(id_el) =>
              attrs.push(
                @markup.attr("data-ooxml-table-style-id", text_content(id_el)),
              )
            None => ()
          }
        None => ()
      }
  }
  attrs
}

///|
fn table_prop_bool(tbl_pr : @xml.Element?, attr_name : String) -> Bool {
  match tbl_pr {
    Some(pr) => parse_xsd_boolean_or(attr_value(pr, attr_name), false)
    None => false
  }
}

///|
fn push_style_part_if_present(
  out : Array[@xml.Element],
  table_style : @xml.Element,
  local_name : String,
) -> Unit {
  match first_child_named(table_style, local_name) {
    Some(part) => out.push(part)
    None => ()
  }
}

///|
/// §20.1.4.2.26 table style conditional buckets. Later buckets in
/// this array override earlier ones for the same property.
fn table_style_parts_for_cell(
  table_style : @xml.Element?,
  tbl_pr : @xml.Element?,
  row_idx : Int,
  col_idx : Int,
  row_count : Int,
  col_count : Int,
) -> Array[@xml.Element] {
  let style = match table_style {
    Some(s) => s
    None => return []
  }
  let parts : Array[@xml.Element] = []
  push_style_part_if_present(parts, style, "wholeTbl")
  if table_prop_bool(tbl_pr, "bandRow") {
    if row_idx % 2 == 0 {
      push_style_part_if_present(parts, style, "band1H")
    } else {
      push_style_part_if_present(parts, style, "band2H")
    }
  }
  if table_prop_bool(tbl_pr, "bandCol") {
    if col_idx % 2 == 0 {
      push_style_part_if_present(parts, style, "band1V")
    } else {
      push_style_part_if_present(parts, style, "band2V")
    }
  }
  if table_prop_bool(tbl_pr, "firstCol") && col_idx == 0 {
    push_style_part_if_present(parts, style, "firstCol")
  }
  if table_prop_bool(tbl_pr, "lastCol") && col_idx == col_count - 1 {
    push_style_part_if_present(parts, style, "lastCol")
  }
  if table_prop_bool(tbl_pr, "firstRow") && row_idx == 0 {
    push_style_part_if_present(parts, style, "firstRow")
  }
  if table_prop_bool(tbl_pr, "lastRow") && row_idx == row_count - 1 {
    push_style_part_if_present(parts, style, "lastRow")
  }
  if row_idx == 0 && col_idx == 0 {
    push_style_part_if_present(parts, style, "nwCell")
  }
  if row_idx == 0 && col_idx == col_count - 1 {
    push_style_part_if_present(parts, style, "neCell")
  }
  if row_idx == row_count - 1 && col_idx == 0 {
    push_style_part_if_present(parts, style, "swCell")
  }
  if row_idx == row_count - 1 && col_idx == col_count - 1 {
    push_style_part_if_present(parts, style, "seCell")
  }
  parts
}

///|
fn table_part_tc_style(part : @xml.Element) -> @xml.Element? {
  first_child_named(part, "tcStyle")
}

///|
fn table_part_tx_style(part : @xml.Element) -> @xml.Element? {
  first_child_named(part, "tcTxStyle")
}

///|
fn table_style_fill(parts : Array[@xml.Element]) -> @xml.Element? {
  let mut result : @xml.Element? = None
  for part in parts {
    match table_part_tc_style(part) {
      Some(tc_style) =>
        match first_child_named(tc_style, "fill") {
          Some(fill_wrapper) =>
            match find_fill_child(fill_wrapper) {
              Some(fill) => result = Some(fill)
              None => ()
            }
          None => ()
        }
      None => ()
    }
  }
  result
}

///|
fn table_style_background_fill(table_style : @xml.Element?) -> @xml.Element? {
  let style = match table_style {
    Some(s) => s
    None => return None
  }
  match first_child_named(style, "tblBg") {
    Some(bg) =>
      match first_child_named(bg, "fill") {
        Some(fill_wrapper) => find_fill_child(fill_wrapper)
        None => None
      }
    None => None
  }
}

///|
fn table_style_border_wrapper_for_edge(
  local_name : String,
  row_idx : Int,
  col_idx : Int,
  row_count : Int,
  col_count : Int,
) -> String {
  match local_name {
    "lnT" => if row_idx == 0 { "top" } else { "insideH" }
    "lnB" => if row_idx == row_count - 1 { "bottom" } else { "insideH" }
    "lnL" => if col_idx == 0 { "left" } else { "insideV" }
    "lnR" => if col_idx == col_count - 1 { "right" } else { "insideV" }
    "lnTlToBr" => "tl2br"
    "lnBlToTr" => "tr2bl"
    _ => ""
  }
}

///|
fn table_style_border_line(
  parts : Array[@xml.Element],
  wrapper_name : String,
) -> @xml.Element? {
  if wrapper_name.length() == 0 {
    return None
  }
  let mut result : @xml.Element? = None
  for part in parts {
    match table_part_tc_style(part) {
      Some(tc_style) =>
        match first_child_named(tc_style, "tcBdr") {
          Some(tc_bdr) =>
            match first_child_named(tc_bdr, wrapper_name) {
              Some(wrapper) =>
                match first_child_named(wrapper, "ln") {
                  Some(ln) => result = Some(ln)
                  None => ()
                }
              None => ()
            }
          None => ()
        }
      None => ()
    }
  }
  result
}

///|
fn table_style_effective_tx_style(parts : Array[@xml.Element]) -> @xml.Element? {
  let mut result : @xml.Element? = None
  for part in parts {
    match table_part_tx_style(part) {
      Some(tx) => result = Some(tx)
      None => ()
    }
  }
  result
}

///|
fn table_style_text_attrs(parts : Array[@xml.Element]) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  match table_style_effective_tx_style(parts) {
    Some(tx) => {
      match attr_value(tx, "b") {
        Some(v) => attrs.push(@markup.attr("data-ooxml-table-tx-b", v))
        None => ()
      }
      match attr_value(tx, "i") {
        Some(v) => attrs.push(@markup.attr("data-ooxml-table-tx-i", v))
        None => ()
      }
      match first_color_choice_child(tx) {
        Some(c) =>
          attrs.push(
            @markup.attr("data-ooxml-table-tx-color", c.name.local_name),
          )
        None => ()
      }
      match first_child_named(tx, "font") {
        Some(font) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-table-tx-font-children",
              element_child_local_names(font),
            ),
          )
        None => ()
      }
    }
    None => ()
  }
  attrs
}

///|
fn table_cell_metadata_attrs_from_tc_style(
  parts : Array[@xml.Element],
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  let mut has_cell3d = false
  for part in parts {
    match table_part_tc_style(part) {
      Some(tc_style) =>
        match first_child_named(tc_style, "cell3D") {
          Some(cell3d) => {
            has_cell3d = true
            match attr_value(cell3d, "prstMaterial") {
              Some(v) =>
                attrs.push(@markup.attr("data-ooxml-table-cell3d-material", v))
              None => ()
            }
          }
          None => ()
        }
      None => ()
    }
  }
  if has_cell3d {
    attrs.push(@markup.attr("data-ooxml-table-cell3d-source", "style"))
  }
  attrs
}

///|
fn table_cell_metadata_attrs_from_tc_pr(
  tc_pr : @xml.Element?,
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  let pr = match tc_pr {
    Some(p) => p
    None => return attrs
  }
  match first_child_named(pr, "cell3D") {
    Some(cell3d) => {
      attrs.push(@markup.attr("data-ooxml-table-cell3d-source", "cell"))
      match attr_value(cell3d, "prstMaterial") {
        Some(v) =>
          attrs.push(@markup.attr("data-ooxml-table-cell3d-material", v))
        None => ()
      }
    }
    None => ()
  }
  match first_child_named(pr, "headers") {
    Some(headers) =>
      attrs.push(
        @markup.attr("data-ooxml-table-headers", text_content(headers)),
      )
    None => ()
  }
  attrs
}

///|
fn on_off_style_attr_value(value : String?) -> String? {
  match value {
    Some("on") | Some("1") | Some("true") => Some("1")
    Some("off") | Some("0") | Some("false") => Some("0")
    _ => None
  }
}

///|
fn table_style_text_lst_style(parts : Array[@xml.Element]) -> @xml.Element? {
  let tx = match table_style_effective_tx_style(parts) {
    Some(t) => t
    None => return None
  }
  let attrs : Array[@xml.Attribute] = []
  match on_off_style_attr_value(attr_value(tx, "b")) {
    Some(v) => attrs.push(@markup.attr("b", v))
    None => ()
  }
  match on_off_style_attr_value(attr_value(tx, "i")) {
    Some(v) => attrs.push(@markup.attr("i", v))
    None => ()
  }
  let r_pr_children : Array[@xml.Node] = []
  match first_color_choice_child(tx) {
    Some(color) =>
      r_pr_children.push(
        Element({
          name: synthetic_a_qname("solidFill"),
          attributes: [],
          children: [Element(color)],
        }),
      )
    None => ()
  }
  match first_child_named(tx, "font") {
    Some(font) => {
      match first_child_named(font, "latin") {
        Some(latin) => r_pr_children.push(Element(latin))
        None => ()
      }
      match first_child_named(font, "ea") {
        Some(ea) => r_pr_children.push(Element(ea))
        None => ()
      }
      match first_child_named(font, "cs") {
        Some(cs) => r_pr_children.push(Element(cs))
        None => ()
      }
    }
    None => ()
  }
  if attrs.length() == 0 && r_pr_children.length() == 0 {
    return None
  }
  let def_r_pr : @xml.Element = {
    name: synthetic_a_qname("defRPr"),
    attributes: attrs,
    children: r_pr_children,
  }
  let def_p_pr : @xml.Element = {
    name: synthetic_a_qname("defPPr"),
    attributes: [],
    children: [Element(def_r_pr)],
  }
  Some({
    name: synthetic_a_qname("lstStyle"),
    attributes: [],
    children: [Element(def_p_pr)],
  })
}

///|
/// Render every `<a:tc>` cell in a row at the given vertical band.
fn render_row(
  row : @xml.Element,
  row_idx : Int,
  row_count : Int,
  col_widths : Array[Double],
  y : Double,
  row_height : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  hyperlink_resolver : (String) -> String?,
  table_style : @xml.Element?,
  tbl_pr : @xml.Element?,
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
              elt,
              x,
              y,
              span_w,
              row_height,
              row_idx,
              col_idx,
              row_count,
              col_widths.length(),
              ctx,
              defs,
              hyperlink_resolver,
              table_style,
              tbl_pr,
              out,
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
  row_idx : Int,
  col_idx : Int,
  row_count : Int,
  col_count : Int,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  hyperlink_resolver : (String) -> String?,
  table_style : @xml.Element?,
  tbl_pr : @xml.Element?,
  out : Array[@xml.Node],
) -> Unit {
  let tc_pr = first_child_named(cell, "tcPr")
  let style_parts = table_style_parts_for_cell(
    table_style, tbl_pr, row_idx, col_idx, row_count, col_count,
  )
  // Cell fill — `<a:tcPr>/<a:fill>` per §20.1.4.2.18.
  let fill_value = {
    let direct_fill = match tc_pr {
      Some(pr) => find_fill_child(pr)
      None => None
    }
    let resolved_fill = match direct_fill {
      Some(f) => Some(f)
      None => table_style_fill(style_parts)
    }
    match resolved_fill {
      None => "none"
      Some(f) => {
        let r = render_fill_attr(f, defs, ctx, shape_width=w, shape_height=h)
        r.attr_value
      }
    }
  }
  // Background rect.
  let rect_attrs : Array[@xml.Attribute] = [
    @markup.attr("x", format_double(x)),
    @markup.attr("y", format_double(y)),
    @markup.attr("width", format_double(w)),
    @markup.attr("height", format_double(h)),
    @markup.attr("fill", fill_value),
  ]
  let direct_cell3d = match tc_pr {
    Some(pr) => first_child_named(pr, "cell3D") is Some(_)
    None => false
  }
  if !direct_cell3d {
    for attr in table_cell_metadata_attrs_from_tc_style(style_parts) {
      rect_attrs.push(attr)
    }
  }
  for attr in table_cell_metadata_attrs_from_tc_pr(tc_pr) {
    rect_attrs.push(attr)
  }
  out.push(@markup.elem_ns("rect", @markup.svg_ns, rect_attrs, []))
  // Borders — lnL / lnR / lnT / lnB (CT_TableCellProperties Annex A.4.1
  // lines 2347..2369). Diagonals lnTlToBr / lnBlToTr also emitted.
  emit_cell_borders(
    tc_pr, style_parts, row_idx, col_idx, row_count, col_count, x, y, w, h, ctx,
    defs, out,
  )
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
      for attr in table_style_text_attrs(style_parts) {
        g_attrs.push(attr)
      }
      let table_text_style = table_style_text_lst_style(style_parts)
      out.push(
        @markup.elem_ns(
          "g",
          @markup.svg_ns,
          g_attrs,
          render_shape_text_svg(
            cell,
            inner_w,
            inner_h,
            ctx,
            defs,
            _ => None,
            hyperlink_resolver,
            master_lst_style=table_text_style,
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
  tc_pr : @xml.Element?,
  style_parts : Array[@xml.Element],
  row_idx : Int,
  col_idx : Int,
  row_count : Int,
  col_count : Int,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  out : Array[@xml.Node],
) -> Unit {
  emit_border_line(
    tc_pr,
    style_parts,
    "lnT",
    row_idx,
    col_idx,
    row_count,
    col_count,
    x,
    y,
    x + w,
    y,
    ctx,
    defs,
    out,
  )
  emit_border_line(
    tc_pr,
    style_parts,
    "lnB",
    row_idx,
    col_idx,
    row_count,
    col_count,
    x,
    y + h,
    x + w,
    y + h,
    ctx,
    defs,
    out,
  )
  emit_border_line(
    tc_pr,
    style_parts,
    "lnL",
    row_idx,
    col_idx,
    row_count,
    col_count,
    x,
    y,
    x,
    y + h,
    ctx,
    defs,
    out,
  )
  emit_border_line(
    tc_pr,
    style_parts,
    "lnR",
    row_idx,
    col_idx,
    row_count,
    col_count,
    x + w,
    y,
    x + w,
    y + h,
    ctx,
    defs,
    out,
  )
  emit_border_line(
    tc_pr,
    style_parts,
    "lnTlToBr",
    row_idx,
    col_idx,
    row_count,
    col_count,
    x,
    y,
    x + w,
    y + h,
    ctx,
    defs,
    out,
  )
  emit_border_line(
    tc_pr,
    style_parts,
    "lnBlToTr",
    row_idx,
    col_idx,
    row_count,
    col_count,
    x,
    y + h,
    x + w,
    y,
    ctx,
    defs,
    out,
  )
}

///|
/// Resolve a `<a:ln*>` child of `tcPr` into a stroke and emit an SVG
/// `<line>` when present. The fill resolution mirrors what
/// `build_line_attrs` does for shapes.
fn emit_border_line(
  tc_pr : @xml.Element?,
  style_parts : Array[@xml.Element],
  local_name : String,
  row_idx : Int,
  col_idx : Int,
  row_count : Int,
  col_count : Int,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  out : Array[@xml.Node],
) -> Unit {
  let direct = match tc_pr {
    Some(pr) => first_child_named(pr, local_name)
    None => None
  }
  let (ln_opt, source) = match direct {
    Some(ln) => (Some(ln), "cell")
    None => {
      let wrapper = table_style_border_wrapper_for_edge(
        local_name, row_idx, col_idx, row_count, col_count,
      )
      (table_style_border_line(style_parts, wrapper), "style")
    }
  }
  match ln_opt {
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
      attrs.push(@markup.attr("data-ooxml-table-border-source", source))
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
