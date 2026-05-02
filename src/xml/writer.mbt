///|
/// Serialize a DOM document to UTF-8 XML bytes.
pub fn write(doc : Document) -> Bytes {
  let out = StringBuilder::new()
  match doc.declaration {
    Some(decl) => {
      out.write_string("<?xml version=\"")
      out.write_string(escape_attribute(decl.version))
      out.write_string("\"")
      match decl.encoding {
        Some(encoding) => {
          out.write_string(" encoding=\"")
          out.write_string(escape_attribute(encoding))
          out.write_string("\"")
        }
        None => ()
      }
      match decl.standalone {
        Some(value) => {
          out.write_string(" standalone=\"")
          out.write_string(if value { "yes" } else { "no" })
          out.write_string("\"")
        }
        None => ()
      }
      out.write_string("?>")
    }
    None => ()
  }
  match doc.doctype {
    Some(doctype) => {
      out.write_string("<!DOCTYPE ")
      out.write_string(doctype)
      out.write_string(">")
    }
    None => ()
  }
  let namespaces = NamespaceContext::new()
  write_element(out, doc.root, namespaces)
  @utf8.encode(out.to_string()[:])
}

///|
fn write_element(
  out : StringBuilder,
  element : Element,
  namespaces : NamespaceContext,
) -> Unit {
  out.write_string("<")
  out.write_string(format_qname(element.name))
  namespaces.push_scope()
  write_element_namespace_if_needed(
    out,
    namespaces,
    element.name.prefix,
    element.name.ns,
  )
  for attr in element.attributes {
    match attr.name.prefix {
      Some(_) =>
        write_namespace_if_needed(
          out,
          namespaces,
          attr.name.prefix,
          attr.name.ns,
        )
      None => ()
    }
  }
  for attr in element.attributes {
    out.write_string(" ")
    out.write_string(format_qname(attr.name))
    out.write_string("=\"")
    out.write_string(escape_attribute(attr.value))
    out.write_string("\"")
  }
  if element.children.is_empty() {
    out.write_string("/>")
  } else {
    out.write_string(">")
    for child in element.children {
      match child {
        Element(child_element) => write_element(out, child_element, namespaces)
        Text(text) => out.write_string(escape_text(text))
        CData(text) => {
          out.write_string("<![CDATA[")
          out.write_string(text)
          out.write_string("]]>")
        }
        Comment(text) => {
          out.write_string("<!--")
          out.write_string(text)
          out.write_string("-->")
        }
        ProcessingInstruction(pi) => {
          out.write_string("<?")
          out.write_string(pi.target)
          if pi.data != "" {
            out.write_string(" ")
            out.write_string(pi.data)
          }
          out.write_string("?>")
        }
      }
    }
    out.write_string("</")
    out.write_string(format_qname(element.name))
    out.write_string(">")
  }
  namespaces.pop_scope() |> ignore
}

///|
fn write_namespace_if_needed(
  out : StringBuilder,
  namespaces : NamespaceContext,
  prefix : String?,
  ns : String?,
) -> Unit {
  match ns {
    Some(uri) =>
      if namespaces.resolve(prefix) != Some(uri) {
        out.write_string(" ")
        match prefix {
          Some(prefix) => {
            out.write_string("xmlns:")
            out.write_string(prefix)
          }
          None => out.write_string("xmlns")
        }
        out.write_string("=\"")
        out.write_string(escape_attribute(uri))
        out.write_string("\"")
        namespaces.bind(prefix, uri)
      }
    None => ()
  }
}

///|
fn write_element_namespace_if_needed(
  out : StringBuilder,
  namespaces : NamespaceContext,
  prefix : String?,
  ns : String?,
) -> Unit {
  match (prefix, ns) {
    (None, None) =>
      if namespaces.resolve(None) is Some(active) && active != "" {
        out.write_string(" xmlns=\"\"")
        namespaces.bind(None, "")
      }
    _ => write_namespace_if_needed(out, namespaces, prefix, ns)
  }
}

///|
/// Escape attribute value per XML 1.0 §2.4 / §3.3.3 and OPC §6.2.5: replace
/// all five predefined entities (`&`, `<`, `>`, `"`, `'`) with named refs.
pub fn escape_attribute(value : String) -> String {
  let out = StringBuilder::new()
  for ch in value {
    match ch {
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '&' => out.write_string("&amp;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&apos;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
/// Escape text per XML 1.0 §2.4 and OPC §6.2.5: replace `&` with `&amp;`,
/// `<` with `&lt;`, and split any `]]>` sequence to `]]&gt;` so it cannot
/// terminate a CDATA section.
pub fn escape_text(value : String) -> String {
  let out = StringBuilder::new()
  let chars = value.to_array()
  let mut i = 0
  while i < chars.length() {
    if i + 2 < chars.length() &&
      chars[i] == ']' &&
      chars[i + 1] == ']' &&
      chars[i + 2] == '>' {
      out.write_string("]]&gt;")
      i += 3
    } else {
      match chars[i] {
        '<' => out.write_string("&lt;")
        '&' => out.write_string("&amp;")
        _ => out.write_char(chars[i])
      }
      i += 1
    }
  }
  out.to_string()
}

///|
/// Escape attribute per W3C Canonical XML 1.0 §2.3 for OPC §6.2.5 XML
/// signatures: replace `&`, `<`, `"`, tab (`&#x9;`), LF (`&#xA;`), and CR
/// (`&#xD;`).
pub fn escape_attribute_c14n(value : String) -> String {
  let out = StringBuilder::new()
  for ch in value {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '"' => out.write_string("&quot;")
      '\t' => out.write_string("&#x9;")
      '\n' => out.write_string("&#xA;")
      '\r' => out.write_string("&#xD;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
/// Escape text per W3C Canonical XML 1.0 §2.3 for OPC §6.2.5 XML signatures:
/// replace `&`, `<`, `>`, and CR (`&#xD;`). Unlike plain XML serialization,
/// C14N text mode always escapes `>`.
pub fn escape_text_c14n(value : String) -> String {
  let out = StringBuilder::new()
  for ch in value {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '\r' => out.write_string("&#xD;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
/// XML 1.0 §2.2 Char production for OPC §6.2.5 XML documents: U+0009,
/// U+000A, U+000D, U+0020..U+D7FF, U+E000..U+FFFD, U+10000..U+10FFFF.
/// Any other codepoint is forbidden in XML 1.0 documents.
pub fn is_xml_char(ch : Char) -> Bool {
  let code = ch.to_int()
  code == 0x09 ||
  code == 0x0A ||
  code == 0x0D ||
  (code >= 0x20 && code <= 0xD7FF) ||
  (code >= 0xE000 && code <= 0xFFFD) ||
  (code >= 0x10000 && code <= 0x10FFFF)
}
