///|
/// WordprocessingML §17 viewer for the reader -> context -> viewer pipeline.
///
/// render_html walks a CT_Document domain tree and emits representative HTML
/// for document, body, paragraph, run, text, and table content. It is a
/// structural renderer for inspection and tests, not a layout-equivalent Word
/// renderer.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/viewer"
}

///|
/// Render a WordprocessingML CT_Document tree as minimal HTML.
/// Structural-only output (no inline styles); see `render_styled_html`
/// for a style-aware variant.
pub fn render_html(domain : @domain.CT_Document) -> String {
  "<article data-ooxml=\"wml\">" +
  render_children(domain.element, plain=true) +
  "</article>"
}

///|
/// Render a WordprocessingML CT_Document tree as style-aware HTML.
/// Walks `<w:pPr>` and `<w:rPr>` to produce inline CSS for paragraph
/// alignment and run formatting (bold/italic/underline/strike/color/size)
/// per Part 1 §17.3.1.25 / §17.3.2.27. This is still a structural
/// renderer (not layout-equivalent to Word), but covers the per-run
/// inline-formatting surface so consumers can apply CSS for previews.
pub fn render_styled_html(domain : @domain.CT_Document) -> String {
  "<article data-ooxml=\"wml\">" +
  render_children(domain.element, plain=false) +
  "</article>"
}

///|
fn render_children(element : @xml.Element, plain~ : Bool) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Element(element) => out.write_string(render_element(element, plain~))
      Text(text) | CData(text) => out.write_string(escape_html(text))
      _ => ()
    }
  }
  out.to_string()
}

///|
fn render_element(element : @xml.Element, plain~ : Bool) -> String {
  match element.name.local_name {
    "p" =>
      if plain {
        "<p>" + render_children(element, plain~) + "</p>"
      } else {
        "<p" +
        paragraph_style(element) +
        ">" +
        render_paragraph_content(element) +
        "</p>"
      }
    "r" =>
      if plain {
        render_children(element, plain~)
      } else {
        "<span" +
        run_style(element) +
        ">" +
        render_children(element, plain~) +
        "</span>"
      }
    "t" => escape_html(text_content(element))
    "br" => "<br>"
    "tab" => "&#9;"
    "tbl" => "<table>" + render_children(element, plain~) + "</table>"
    "tr" => "<tr>" + render_children(element, plain~) + "</tr>"
    "tc" => "<td>" + render_children(element, plain~) + "</td>"
    "hyperlink" => "<a>" + render_children(element, plain~) + "</a>"
    "pPr" => ""
    "rPr" => ""
    "sectPr" => ""
    _ => render_children(element, plain~)
  }
}

///|
/// Render the §17.3.1.25 paragraph content, skipping `<w:pPr>` properties
/// (already consumed by paragraph_style) and emitting the runs.
fn render_paragraph_content(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Element(e) =>
        if e.name.local_name != "pPr" {
          out.write_string(render_element(e, plain=false))
        }
      Text(text) | CData(text) => out.write_string(escape_html(text))
      _ => ()
    }
  }
  out.to_string()
}

///|
/// Extract an inline style attribute for a §17.3.1.25 paragraph from its
/// `<w:pPr>` child. Currently maps `<w:jc>` (§17.3.1.13) to text-align.
fn paragraph_style(p : @xml.Element) -> String {
  match first_child_named(p, "pPr") {
    None => ""
    Some(p_pr) => {
      let css = StringBuilder::new()
      match first_child_named(p_pr, "jc") {
        Some(jc) =>
          match attr_value(jc, "val") {
            Some(value) => {
              let mapped = match value {
                "left" | "start" => "left"
                "right" | "end" => "right"
                "center" => "center"
                "both" | "distribute" | "justify" => "justify"
                _ => ""
              }
              if mapped != "" {
                css.write_string("text-align:" + mapped + ";")
              }
            }
            None => ()
          }
        None => ()
      }
      let s = css.to_string()
      if s == "" {
        ""
      } else {
        " style=\"" + s + "\""
      }
    }
  }
}

///|
/// Extract an inline style attribute for a §17.9.2.27 run from its
/// `<w:rPr>` child. Currently maps `<w:b>`, `<w:i>`, `<w:u>`, `<w:color>`,
/// and `<w:sz>` (§17.3.2 run properties).
fn run_style(r : @xml.Element) -> String {
  match first_child_named(r, "rPr") {
    None => ""
    Some(r_pr) => {
      let css = StringBuilder::new()
      if first_child_named(r_pr, "b") is Some(_) {
        css.write_string("font-weight:bold;")
      }
      if first_child_named(r_pr, "i") is Some(_) {
        css.write_string("font-style:italic;")
      }
      if first_child_named(r_pr, "u") is Some(_) {
        css.write_string("text-decoration:underline;")
      }
      if first_child_named(r_pr, "strike") is Some(_) {
        css.write_string("text-decoration:line-through;")
      }
      match first_child_named(r_pr, "color") {
        Some(color_el) =>
          match attr_value(color_el, "val") {
            Some(value) =>
              if value != "auto" && value.length() > 0 {
                css.write_string("color:#" + value + ";")
              }
            None => ()
          }
        None => ()
      }
      match first_child_named(r_pr, "sz") {
        Some(sz_el) =>
          match attr_value(sz_el, "val") {
            // @sz is in half-points (§17.18.108 ST_HpsMeasure)
            Some(value) =>
              try {
                let hp : Int = @strconv.parse_int(value)
                let half = hp.to_double() / 2.0
                css.write_string("font-size:" + half.to_string() + "pt;")
              } catch {
                _ => ()
              }
            None => ()
          }
        None => ()
      }
      let s = css.to_string()
      if s == "" {
        ""
      } else {
        " style=\"" + s + "\""
      }
    }
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
