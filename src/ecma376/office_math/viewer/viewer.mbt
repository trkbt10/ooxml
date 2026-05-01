///|
/// Office Math §22.1 viewer for the reader -> context -> viewer pipeline.
///
/// render_html walks a CT_OMath domain tree and emits representative MathML
/// wrapped in HTML. The renderer maps OMML text runs to mtext and preserves
/// unknown math structures by walking their children.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/office_math/viewer"
}

///|
/// Render an OMML CT_OMath tree as minimal HTML containing MathML.
pub fn render_html(domain : @domain.CT_OMath) -> String {
  "<math data-ooxml=\"omml\">" + render_children(domain.element) + "</math>"
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
    "t" => "<mtext>" + escape_html(text_content(element)) + "</mtext>"
    "r" => render_children(element)
    "f" => "<mfrac>" + render_children(element) + "</mfrac>"
    "rad" => "<msqrt>" + render_children(element) + "</msqrt>"
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
