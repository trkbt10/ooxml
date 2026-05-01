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
pub fn render_html(domain : @domain.CT_Worksheet) -> String {
  "<table data-ooxml=\"sml\">" + render_children(domain.element) + "</table>"
}

///|
fn render_children(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Element(element) => out.write_string(render_element(element))
      Text(text) | CData(text) => out.write_string(escape_html(text))
      _ => ()
    }
  }
  out.to_string()
}

///|
fn render_element(element : @xml.Element) -> String {
  match element.name.local_name {
    "sheetData" => render_children(element)
    "row" => "<tr>" + render_children(element) + "</tr>"
    "c" => "<td>" + render_children(element) + "</td>"
    "f" => "<code>" + escape_html(text_content(element)) + "</code>"
    "v" | "t" => escape_html(text_content(element))
    _ => render_children(element)
  }
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
