///|
/// SpreadsheetML §18 viewer for the reader -> context -> viewer pipeline.
///
/// render_html walks a CT_Worksheet domain tree and emits representative HTML
/// for sheetData, rows, cells, formulas, and values. It intentionally leaves
/// calculation and style fidelity to later context stages.
///
/// The HTML is built as a structured `@xml.Element` tree and
/// serialised once via the shared `@markup` package; no markup is
/// assembled by string concatenation, so an OOXML payload (cell
/// text, a formula, a `@r` reference) can never break out of its
/// element / attribute context.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/viewer"
}

///|
/// Render a SpreadsheetML CT_Worksheet tree as minimal HTML.
/// Plain structural output without shared-string resolution.
///
/// §18.8.45 xf / §18.8.30 numFmt / §18.8.3 theme cascade are
/// NOT applied in this HTML path; the SVG renderer
/// (`svg_render.mbt`) honours the full styling pipeline.  HTML
/// consumers needing number formatting, colours, or borders
/// should call `render_svg` and embed the result inside their
/// own layout.  Lifting this limitation requires threading
/// `styles?` / `theme?` parameters through `render_children`
/// and is tracked as Round 12 #279.
pub fn render_html(domain : @domain.CT_Worksheet) -> String {
  let table : @xml.Element = {
    name: @markup.qname("table"),
    attributes: [@markup.attr("data-ooxml", "sml")],
    children: render_children(domain.element, shared_strings=None),
  }
  @markup.serialize(table)
}

///|
/// Render a SpreadsheetML CT_Worksheet tree as HTML with shared-string
/// resolution. Cells whose `@t="s"` look up the integer index in the
/// supplied §18.4 CT_Sst and inline the resolved text.
pub fn render_html_with_shared_strings(
  domain : @domain.CT_Worksheet,
  sst : @domain.CT_Sst,
) -> String {
  let table : @xml.Element = {
    name: @markup.qname("table"),
    attributes: [@markup.attr("data-ooxml", "sml")],
    children: render_children(domain.element, shared_strings=Some(sst)),
  }
  @markup.serialize(table)
}

///|
/// Render every child of `element` into a flat node array.
fn render_children(
  element : @xml.Element,
  shared_strings~ : @domain.CT_Sst?,
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(child_el) =>
        for node in render_element(child_el, shared_strings~) {
          out.push(node)
        }
      Text(text) | CData(text) => out.push(@markup.text(text))
      _ => ()
    }
  }
  out
}

///|
/// Map one SpreadsheetML element to its HTML node(s).  `sheetData`
/// and unknown wrappers descend transparently (returning their
/// children); `row` / `c` / `f` / `v` / `t` map to table markup.
fn render_element(
  element : @xml.Element,
  shared_strings~ : @domain.CT_Sst?,
) -> Array[@xml.Node] {
  match element.name.local_name {
    "sheetData" => render_children(element, shared_strings~)
    "row" => {
      let attrs : Array[@xml.Attribute] = []
      match attr_value(element, "r") {
        Some(r) => attrs.push(@markup.attr("data-r", r))
        None => ()
      }
      [@markup.elem("tr", attrs, render_children(element, shared_strings~))]
    }
    "c" => [render_cell(element, shared_strings~)]
    "f" =>
      [@markup.elem("code", [], [@markup.text(text_content(element))])]
    "v" | "t" => [@markup.text(text_content(element))]
    _ => render_children(element, shared_strings~)
  }
}

///|
/// Render a single §18.3.1.4 cell (`<c r="A1" t="?">`). When `@t="s"`
/// and shared_strings are provided, the integer value indexes into the
/// CT_Sst's si list per §18.4.9; the resolved plain text replaces the
/// numeric value.
fn render_cell(
  cell : @xml.Element,
  shared_strings~ : @domain.CT_Sst?,
) -> @xml.Node {
  let attrs : Array[@xml.Attribute] = []
  match attr_value(cell, "r") {
    Some(value) => attrs.push(@markup.attr("data-r", value))
    None => ()
  }
  let t = attr_value(cell, "t")
  match t {
    Some(value) => attrs.push(@markup.attr("data-t", value))
    None => ()
  }
  let content : Array[@xml.Node] = match (t, shared_strings) {
    (Some("s"), Some(sst)) => [@markup.text(resolve_shared_string(cell, sst))]
    _ => render_children(cell, shared_strings~)
  }
  @markup.elem("td", attrs, content)
}

///|
/// Resolve a §18.3.1.4 cell with `@t="s"` against §18.4 CT_Sst. The
/// `<v>` child carries the zero-based shared-string index; out-of-range
/// or non-numeric indices fall back to the literal value.  The
/// returned plain text is escaped by the serialiser when it is
/// wrapped in a text node.
fn resolve_shared_string(cell : @xml.Element, sst : @domain.CT_Sst) -> String {
  let value_text = match first_child_named(cell, "v") {
    Some(v) => text_content(v)
    None => return ""
  }
  let trimmed = value_text.trim_space().to_string()
  let parsed = Some(@strconv.parse_int(trimmed)) catch { _ => None }
  match parsed {
    Some(index) =>
      if index >= 0 && index < sst.si_entries.length() {
        sst.si_entries[index].to_plain_text()
      } else {
        trimmed
      }
    None => trimmed
  }
}

///|
fn first_child_named(element : @xml.Element, name : String) -> @xml.Element? {
  for child in element.children {
    match child {
      Element(e) => if e.name.local_name == name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
fn attr_value(element : @xml.Element, local_name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return Some(attr.value)
    }
  }
  None
}

///|
fn text_content(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(text) | CData(text) => out.write_string(text)
      Element(child_el) => out.write_string(text_content(child_el))
      _ => ()
    }
  }
  out.to_string()
}
