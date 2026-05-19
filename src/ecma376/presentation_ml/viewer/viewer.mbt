///|
/// PresentationML §19 viewer for the reader -> context -> viewer pipeline.
///
/// render_html walks a CT_Slide domain tree and emits representative HTML for
/// slide common data, shape trees, paragraphs, and text runs. It preserves
/// readable content without attempting PowerPoint layout fidelity.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/viewer"
}

///|
/// Render a PresentationML CT_Slide tree as minimal HTML.
/// Structural-only output; see `render_styled_html` for inline-style output.
pub fn render_html(domain : @domain.CT_Slide) -> String {
  "<section data-ooxml=\"pml\">" +
  render_children(domain.element, plain=true) +
  "</section>"
}

///|
/// Render a PresentationML CT_Slide tree with inline CSS derived from
/// `<a:pPr>` (text-align) and `<a:rPr>` (bold/italic/underline/color/size)
/// per §21.1.2 DrawingML text properties.
pub fn render_styled_html(domain : @domain.CT_Slide) -> String {
  "<section data-ooxml=\"pml\">" +
  render_children(domain.element, plain=false) +
  "</section>"
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
    "sp" | "grpSp" => {
      let label = shape_label(element)
      let attr = if label == "" {
        ""
      } else {
        " data-name=\"" + escape_html(label) + "\""
      }
      "<div class=\"shape\"" +
      attr +
      ">" +
      render_children(element, plain~) +
      "</div>"
    }
    "p" =>
      if plain {
        "<p>" + render_children(element, plain~) + "</p>"
      } else {
        "<p" +
        paragraph_style(element) +
        ">" +
        render_children(element, plain~) +
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
    _ => render_children(element, plain~)
  }
}

///|
/// Extract the §19.3.1.34 shape display name from `<p:nvSpPr>/<p:cNvPr>@name`.
fn shape_label(shape : @xml.Element) -> String {
  match first_child_named(shape, "nvSpPr") {
    Some(nv) =>
      match first_child_named(nv, "cNvPr") {
        Some(c_nv_pr) => attr_value(c_nv_pr, "name").or_default()
        None => ""
      }
    None => ""
  }
}

///|
/// Extract a CSS inline style for §21.1.2.2.7 `<a:pPr>` properties.
/// Maps `@algn` to text-align (l/ctr/r/just).
fn paragraph_style(p : @xml.Element) -> String {
  match first_child_named(p, "pPr") {
    None => ""
    Some(p_pr) =>
      match attr_value(p_pr, "algn") {
        Some(value) => {
          let mapped = match value {
            "l" => "left"
            "ctr" => "center"
            "r" => "right"
            "just" => "justify"
            _ => ""
          }
          if mapped == "" {
            ""
          } else {
            " style=\"text-align:" + mapped + ";\""
          }
        }
        None => ""
      }
  }
}

///|
/// Extract a CSS inline style for §21.1.2.3.9 `<a:rPr>` run properties.
/// Maps `@b="1"`/`@i="1"`/`@u="sng|dbl|..."` plus inline `<a:solidFill>` color.
fn run_style(r : @xml.Element) -> String {
  match first_child_named(r, "rPr") {
    None => ""
    Some(r_pr) => {
      let css = StringBuilder::new()
      match attr_value(r_pr, "b") {
        Some(value) =>
          if value == "1" || value == "true" {
            css.write_string("font-weight:bold;")
          }
        None => ()
      }
      match attr_value(r_pr, "i") {
        Some(value) =>
          if value == "1" || value == "true" {
            css.write_string("font-style:italic;")
          }
        None => ()
      }
      match attr_value(r_pr, "u") {
        Some(value) =>
          if value != "none" {
            css.write_string("text-decoration:underline;")
          }
        None => ()
      }
      // @sz is in hundredths of a point per §17.3.1.36 ST_TextFontSize
      match attr_value(r_pr, "sz") {
        Some(value) =>
          try {
            let hp : Int = @strconv.parse_int(value)
            let pt = hp.to_double() / 100.0
            css.write_string("font-size:" + pt.to_string() + "pt;")
          } catch {
            _ => ()
          }
        None => ()
      }
      // <a:solidFill><a:srgbClr val="RRGGBB"/></a:solidFill>
      match first_child_named(r_pr, "solidFill") {
        Some(fill) =>
          match first_child_named(fill, "srgbClr") {
            Some(srgb) =>
              match attr_value(srgb, "val") {
                Some(value) =>
                  if value.length() > 0 {
                    css.write_string("color:#" + value + ";")
                  }
                None => ()
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
