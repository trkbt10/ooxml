///|
/// SpreadsheetML §18 viewer for the reader -> context -> viewer pipeline.
///
/// render_html walks a CT_Worksheet domain tree and emits representative HTML
/// for sheetData, rows, cells, formulas, and values. It intentionally leaves
/// calculation and style fidelity to later context stages.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/viewer"
}

///|
/// Render a SpreadsheetML CT_Worksheet tree as minimal HTML.
/// Plain structural output without shared-string resolution.
pub fn render_html(domain : @domain.CT_Worksheet) -> String {
  "<table data-ooxml=\"sml\">" +
  render_children(domain.element, shared_strings=None) +
  "</table>"
}

///|
/// Render a SpreadsheetML CT_Worksheet tree as HTML with shared-string
/// resolution. Cells whose `@t="s"` look up the integer index in the
/// supplied §18.4 CT_Sst and inline the resolved text.
pub fn render_html_with_shared_strings(
  domain : @domain.CT_Worksheet,
  sst : @domain.CT_Sst,
) -> String {
  "<table data-ooxml=\"sml\">" +
  render_children(domain.element, shared_strings=Some(sst)) +
  "</table>"
}

///|
fn render_children(
  element : @xml.Element,
  shared_strings~ : @domain.CT_Sst?,
) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Element(element) =>
        out.write_string(render_element(element, shared_strings~))
      Text(text) | CData(text) => out.write_string(escape_html(text))
      _ => ()
    }
  }
  out.to_string()
}

///|
fn render_element(
  element : @xml.Element,
  shared_strings~ : @domain.CT_Sst?,
) -> String {
  match element.name.local_name {
    "sheetData" => render_children(element, shared_strings~)
    "row" => {
      let row_ref = attr_value(element, "r")
      let attr = match row_ref {
        Some(r) => " data-r=\"" + escape_html(r) + "\""
        None => ""
      }
      "<tr" + attr + ">" + render_children(element, shared_strings~) + "</tr>"
    }
    "c" => render_cell(element, shared_strings~)
    "f" => "<code>" + escape_html(text_content(element)) + "</code>"
    "v" | "t" => escape_html(text_content(element))
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
) -> String {
  let r = attr_value(cell, "r")
  let t = attr_value(cell, "t")
  let attrs = StringBuilder::new()
  match r {
    Some(value) => attrs.write_string(" data-r=\"" + escape_html(value) + "\"")
    None => ()
  }
  match t {
    Some(value) => attrs.write_string(" data-t=\"" + escape_html(value) + "\"")
    None => ()
  }
  let content = match (t, shared_strings) {
    (Some("s"), Some(sst)) => resolve_shared_string(cell, sst)
    _ => render_children(cell, shared_strings~)
  }
  "<td" + attrs.to_string() + ">" + content + "</td>"
}

///|
/// Resolve a §18.3.1.4 cell with `@t="s"` against §18.4 CT_Sst. The
/// `<v>` child carries the zero-based shared-string index; out-of-range
/// or non-numeric indices fall back to the literal value.
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
        escape_html(sst.si_entries[index].to_plain_text())
      } else {
        escape_html(trimmed)
      }
    None => escape_html(trimmed)
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
      Element(element) => out.write_string(text_content(element))
      _ => ()
    }
  }
  out.to_string()
}

///|
fn escape_html(value : String) -> String {
  value
  .replace(old="&", new="&amp;")
  .replace(old="<", new="&lt;")
  .replace(old=">", new="&gt;")
}
