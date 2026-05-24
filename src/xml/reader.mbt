///|
/// Streaming XML reader event.
pub(all) enum Event {
  StartElement(Element)
  EndElement(QName)
  Text(String)
  CData(String)
  Comment(String)
  ProcessingInstruction(ProcessingInstruction)
  XmlDeclaration(XmlDeclaration)
} derive(Eq, Debug)

///|
/// Pull reader for XML 1.0 documents.
pub struct Reader {
  priv chars : Array[Char]
  priv mut pos : Int
  priv mut line : Int
  priv mut col : Int
  priv namespaces : NamespaceContext
  priv stack : Array[QName]
  priv pending_end : Array[QName]
  priv mut seen_declaration : Bool
  priv mut seen_root : Bool
  priv mut closed_root : Bool
}

///|
/// Create a reader from UTF-8 XML bytes.
pub fn Reader::new(bytes : Bytes) -> Reader raise XmlMalformed {
  let source = @utf8.decode(bytes[:]) catch {
    @utf8.Malformed(_) =>
      raise XmlMalformed(line=1, col=1, reason="input is not valid UTF-8")
  }
  let chars = source.to_array()
  // XML 1.0 §4.3.3 — a leading U+FEFF byte-order mark is a legal
  // encoding signature, not document content.  Drop it so the
  // parser sees the `<?xml …?>` declaration or root element first.
  if chars.length() > 0 && chars[0] == '\u{FEFF}' {
    chars.remove(0) |> ignore
  }
  {
    chars,
    pos: 0,
    line: 1,
    col: 1,
    namespaces: NamespaceContext::new(),
    stack: [],
    pending_end: [],
    seen_declaration: false,
    seen_root: false,
    closed_root: false,
  }
}

///|
/// Return the next reader event, or `None` at end of input.
pub fn Reader::next(self : Reader) -> Event? raise {
  match self.pending_end.pop() {
    Some(name) => {
      self.namespaces.pop_scope()
      Some(EndElement(name))
    }
    None =>
      if self.is_eof() {
        if self.stack.length() != 0 {
          let name = self.stack[self.stack.length() - 1]
          raise XmlMalformed(
            line=self.line,
            col=self.col,
            reason="missing end tag for \{format_qname(name)}",
          )
        }
        None
      } else if self.starts_with("<!--") {
        Some(Comment(self.read_comment()))
      } else if self.starts_with("<![CDATA[") {
        Some(CData(self.read_cdata()))
      } else if self.starts_with("<?") {
        let pi = self.read_processing_instruction()
        if pi.target == "xml" && !self.seen_declaration && !self.seen_root {
          self.seen_declaration = true
          Some(
            XmlDeclaration(parse_xml_declaration(pi.data, self.line, self.col)),
          )
        } else {
          Some(ProcessingInstruction(pi))
        }
      } else if self.starts_with("</") {
        Some(EndElement(self.read_end_element()))
      } else if self.starts_with("<!DOCTYPE") {
        self.read_doctype() |> ignore
        self.next()
      } else if self.peek() == Some('<') {
        Some(StartElement(self.read_start_element()))
      } else {
        Some(Text(self.read_text()))
      }
  }
}

///|
fn Reader::is_eof(self : Reader) -> Bool {
  self.pos >= self.chars.length()
}

///|
fn Reader::peek(self : Reader) -> Char? {
  self.chars.get(self.pos)
}

///|
fn Reader::advance(self : Reader) -> Char raise XmlMalformed {
  match self.peek() {
    Some(ch) => {
      self.pos += 1
      if ch == '\n' {
        self.line += 1
        self.col = 1
      } else {
        self.col += 1
      }
      ch
    }
    None =>
      raise XmlMalformed(
        line=self.line,
        col=self.col,
        reason="unexpected end of input",
      )
  }
}

///|
fn Reader::starts_with(self : Reader, s : String) -> Bool {
  let pat = s.to_array()
  if self.pos + pat.length() > self.chars.length() {
    false
  } else {
    let mut ok = true
    for i in 0..<pat.length() {
      if self.chars[self.pos + i] != pat[i] {
        ok = false
      }
    }
    ok
  }
}

///|
fn Reader::expect_string(self : Reader, s : String) -> Unit raise XmlMalformed {
  if !self.starts_with(s) {
    raise XmlMalformed(line=self.line, col=self.col, reason="expected `\{s}`")
  }
  for _ in s.to_array() {
    self.advance() |> ignore
  }
}

///|
fn Reader::skip_spaces(self : Reader) -> Unit raise XmlMalformed {
  while self.peek() is Some(ch) && is_xml_space(ch) {
    self.advance() |> ignore
  }
}

///|
fn Reader::read_until(
  self : Reader,
  stop : String,
) -> String raise XmlMalformed {
  let out = StringBuilder::new()
  while !self.is_eof() && !self.starts_with(stop) {
    out.write_char(self.advance())
  }
  if self.is_eof() {
    raise XmlMalformed(line=self.line, col=self.col, reason="missing `\{stop}`")
  }
  out.to_string()
}

///|
fn Reader::read_comment(self : Reader) -> String raise XmlMalformed {
  self.expect_string("<!--")
  let text = self.read_until("-->")
  self.expect_string("-->")
  text
}

///|
fn Reader::read_cdata(self : Reader) -> String raise XmlMalformed {
  self.expect_string("<![CDATA[")
  let text = self.read_until("]]>")
  self.expect_string("]]>")
  text
}

///|
fn Reader::read_processing_instruction(
  self : Reader,
) -> ProcessingInstruction raise XmlMalformed {
  self.expect_string("<?")
  let target = self.read_name()
  if target == "" {
    raise XmlMalformed(
      line=self.line,
      col=self.col,
      reason="missing processing instruction target",
    )
  }
  let data = self.read_until("?>").trim().to_owned()
  self.expect_string("?>")
  { target, data }
}

///|
fn Reader::read_doctype(self : Reader) -> String raise XmlMalformed {
  self.expect_string("<!DOCTYPE")
  let text = self.read_until(">")
  self.expect_string(">")
  text.trim().to_owned()
}

///|
fn Reader::read_text(self : Reader) -> String raise XmlMalformed {
  let out = StringBuilder::new()
  while !self.is_eof() && self.peek() != Some('<') {
    if self.starts_with("]]>") {
      raise XmlMalformed(
        line=self.line,
        col=self.col,
        reason="`]]>` is not allowed in character data",
      )
    }
    if self.peek() == Some('&') {
      out.write_string(self.read_reference())
    } else {
      out.write_char(self.advance())
    }
  }
  out.to_string()
}

///|
fn Reader::read_start_element(self : Reader) -> Element raise {
  if self.closed_root {
    raise XmlMalformed(
      line=self.line,
      col=self.col,
      reason="content after document element",
    )
  }
  self.expect_string("<")
  let raw_name = self.read_name()
  let raw_attrs : Array[(String, String)] = []
  let ns_attrs : Array[NamespaceBinding] = []
  let mut self_closing = false
  self.skip_spaces()
  while !self.is_eof() && self.peek() != Some('>') && !self.starts_with("/>") {
    let attr_name = self.read_name()
    if attr_name == "" {
      raise XmlMalformed(
        line=self.line,
        col=self.col,
        reason="expected attribute name",
      )
    }
    self.skip_spaces()
    self.expect_string("=")
    self.skip_spaces()
    let attr_value = self.read_attribute_value()
    match namespace_declaration(attr_name) {
      Some(binding) => ns_attrs.push({ prefix: binding, uri: attr_value })
      None => raw_attrs.push((attr_name, attr_value))
    }
    self.skip_spaces()
  }
  if self.starts_with("/>") {
    self.expect_string("/>")
    self_closing = true
  } else {
    self.expect_string(">")
  }
  self.namespaces.push_scope()
  for binding in ns_attrs {
    self.namespaces.bind(binding.prefix, binding.uri)
  }
  let name = self.resolve_element_name(raw_name)
  let attrs = self.resolve_attributes(raw_attrs)
  let element = { name, attributes: attrs, children: [] }
  if self.seen_root && self.stack.length() == 0 {
    raise XmlMalformed(
      line=self.line,
      col=self.col,
      reason="multiple document elements",
    )
  }
  self.seen_root = true
  if self_closing {
    self.pending_end.push(name)
  } else {
    self.stack.push(name)
  }
  element
}

///|
fn Reader::read_end_element(self : Reader) -> QName raise {
  self.expect_string("</")
  let raw_name = self.read_name()
  self.skip_spaces()
  self.expect_string(">")
  let name = self.resolve_element_name(raw_name)
  match self.stack.pop() {
    Some(open) =>
      if open != name {
        raise XmlMalformed(
          line=self.line,
          col=self.col,
          reason="expected end tag for \{format_qname(open)}, got \{format_qname(name)}",
        )
      }
    None =>
      raise XmlMalformed(
        line=self.line,
        col=self.col,
        reason="end tag without start tag",
      )
  }
  self.namespaces.pop_scope()
  if self.stack.length() == 0 {
    self.closed_root = true
  }
  name
}

///|
fn Reader::read_attribute_value(self : Reader) -> String raise XmlMalformed {
  let quote = match self.peek() {
    Some('"') => '"'
    Some('\'') => '\''
    _ =>
      raise XmlMalformed(
        line=self.line,
        col=self.col,
        reason="attribute value must be quoted",
      )
  }
  self.advance() |> ignore
  let out = StringBuilder::new()
  while self.peek() != Some(quote) {
    if self.is_eof() {
      raise XmlMalformed(
        line=self.line,
        col=self.col,
        reason="unclosed attribute value",
      )
    }
    if self.peek() == Some('<') {
      raise XmlMalformed(
        line=self.line,
        col=self.col,
        reason="`<` is not allowed in attribute values",
      )
    }
    if self.peek() == Some('&') {
      out.write_string(self.read_reference())
    } else {
      out.write_char(self.advance())
    }
  }
  self.advance() |> ignore
  out.to_string()
}

///|
fn Reader::read_reference(self : Reader) -> String raise XmlMalformed {
  self.expect_string("&")
  let out = StringBuilder::new()
  while self.peek() != Some(';') {
    if self.is_eof() {
      raise XmlMalformed(
        line=self.line,
        col=self.col,
        reason="unclosed entity reference",
      )
    }
    out.write_char(self.advance())
  }
  self.expect_string(";")
  decode_reference(out.to_string(), self.line, self.col)
}

///|
fn Reader::read_name(self : Reader) -> String raise XmlMalformed {
  let out = StringBuilder::new()
  while self.peek() is Some(ch) && is_name_char(ch) {
    out.write_char(self.advance())
  }
  out.to_string()
}

///|
fn Reader::resolve_element_name(self : Reader, raw : String) -> QName raise {
  let name = split_qname(raw)
  let ns = match (name.prefix, self.namespaces.resolve(name.prefix)) {
    (None, Some("")) => None
    (_, value) => value
  }
  match (name.prefix, ns) {
    (Some(prefix), None) => raise UndeclaredPrefix(prefix~)
    _ => { prefix: name.prefix, local_name: name.local_name, ns }
  }
}

///|
fn Reader::resolve_attributes(
  self : Reader,
  raw_attrs : Array[(String, String)],
) -> Array[Attribute] raise {
  let attrs : Array[Attribute] = []
  let seen : Map[String, Bool] = Map::new()
  for raw_attr in raw_attrs {
    let (raw, value) = raw_attr
    let split = split_qname(raw)
    let ns = match split.prefix {
      Some(prefix) =>
        match self.namespaces.resolve(Some(prefix)) {
          Some(uri) => Some(uri)
          None => raise UndeclaredPrefix(prefix~)
        }
      None => None
    }
    let qname = { prefix: split.prefix, local_name: split.local_name, ns }
    let key = expanded_key(qname)
    if seen.contains(key) {
      raise DuplicateAttribute(name=key)
    }
    seen[key] = true
    attrs.push({ name: qname, value })
  }
  attrs
}

///|
fn is_xml_space(ch : Char) -> Bool {
  ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t'
}

///|
fn is_name_char(ch : Char) -> Bool {
  ch.is_ascii_alphabetic() ||
  ch.is_ascii_digit() ||
  ch == '_' ||
  ch == '-' ||
  ch == '.' ||
  ch == ':'
}

///|
fn split_qname(raw : String) -> QName {
  match raw.split_once(":") {
    Some((prefix, local_part)) =>
      {
        prefix: Some(prefix.to_owned()),
        local_name: local_part.to_owned(),
        ns: None,
      }
    None => { prefix: None, local_name: raw, ns: None }
  }
}

///|
fn namespace_declaration(raw : String) -> String?? {
  if raw == "xmlns" {
    Some(None)
  } else {
    match raw.strip_prefix("xmlns:") {
      Some(prefix) => Some(Some(prefix.to_owned()))
      None => None
    }
  }
}

///|
fn decode_reference(
  text : String,
  line : Int,
  col : Int,
) -> String raise XmlMalformed {
  match text {
    "amp" => "&"
    "lt" => "<"
    "gt" => ">"
    "apos" => "'"
    "quot" => "\""
    _ =>
      if text.has_prefix("#x") {
        decode_numeric(
          text.unsafe_substring(start=2, end=text.length()),
          16,
          line,
          col,
        )
      } else if text.has_prefix("#") {
        decode_numeric(
          text.unsafe_substring(start=1, end=text.length()),
          10,
          line,
          col,
        )
      } else {
        raise XmlMalformed(
          line~,
          col~,
          reason="unknown entity reference `&\{text};`",
        )
      }
  }
}

///|
fn decode_numeric(
  digits : String,
  base : Int,
  line : Int,
  col : Int,
) -> String raise XmlMalformed {
  if digits == "" {
    raise XmlMalformed(line~, col~, reason="empty numeric character reference")
  }
  let mut value = 0
  for ch in digits {
    let digit = digit_value(ch)
    if digit < 0 || digit >= base {
      raise XmlMalformed(
        line~,
        col~,
        reason="invalid numeric character reference",
      )
    }
    value = value * base + digit
  }
  match value.to_char() {
    Some(ch) => ch.to_string()
    None =>
      raise XmlMalformed(line~, col~, reason="invalid Unicode scalar value")
  }
}

///|
fn digit_value(ch : Char) -> Int {
  if ch >= '0' && ch <= '9' {
    ch.to_int() - '0'.to_int()
  } else if ch >= 'a' && ch <= 'f' {
    ch.to_int() - 'a'.to_int() + 10
  } else if ch >= 'A' && ch <= 'F' {
    ch.to_int() - 'A'.to_int() + 10
  } else {
    -1
  }
}

///|
fn parse_xml_declaration(
  data : String,
  line : Int,
  col : Int,
) -> XmlDeclaration raise XmlMalformed {
  let parser = AttributeParser::new(data, line, col)
  let attrs = parser.parse_all()
  let mut version = "1.0"
  let mut encoding : String? = None
  let mut standalone : Bool? = None
  for attr in attrs {
    let (name, value) = attr
    match name {
      "version" => version = value
      "encoding" => encoding = Some(value)
      "standalone" =>
        standalone = match value {
          "yes" => Some(true)
          "no" => Some(false)
          _ =>
            raise XmlMalformed(
              line~,
              col~,
              reason="standalone must be yes or no",
            )
        }
      _ => ()
    }
  }
  { version, encoding, standalone }
}

///|
priv struct AttributeParser {
  chars : Array[Char]
  mut pos : Int
  line : Int
  col : Int
}

///|
fn AttributeParser::new(
  source : String,
  line : Int,
  col : Int,
) -> AttributeParser {
  { chars: source.to_array(), pos: 0, line, col }
}

///|
fn AttributeParser::parse_all(
  self : AttributeParser,
) -> Array[(String, String)] raise XmlMalformed {
  let attrs = []
  self.skip_spaces()
  while self.pos < self.chars.length() {
    let name = self.read_name()
    self.skip_spaces()
    self.expect('=')
    self.skip_spaces()
    let value = self.read_value()
    attrs.push((name, value))
    self.skip_spaces()
  }
  attrs
}

///|
fn AttributeParser::skip_spaces(self : AttributeParser) -> Unit {
  while self.pos < self.chars.length() && is_xml_space(self.chars[self.pos]) {
    self.pos += 1
  }
}

///|
fn AttributeParser::expect(
  self : AttributeParser,
  ch : Char,
) -> Unit raise XmlMalformed {
  if self.pos >= self.chars.length() || self.chars[self.pos] != ch {
    raise XmlMalformed(
      line=self.line,
      col=self.col,
      reason="malformed XML declaration",
    )
  }
  self.pos += 1
}

///|
fn AttributeParser::read_name(
  self : AttributeParser,
) -> String raise XmlMalformed {
  let out = StringBuilder::new()
  while self.pos < self.chars.length() && is_name_char(self.chars[self.pos]) {
    out.write_char(self.chars[self.pos])
    self.pos += 1
  }
  let name = out.to_string()
  if name == "" {
    raise XmlMalformed(
      line=self.line,
      col=self.col,
      reason="expected declaration attribute name",
    )
  }
  name
}

///|
fn AttributeParser::read_value(
  self : AttributeParser,
) -> String raise XmlMalformed {
  if self.pos >= self.chars.length() {
    raise XmlMalformed(
      line=self.line,
      col=self.col,
      reason="expected declaration attribute value",
    )
  }
  let quote = self.chars[self.pos]
  if quote != '"' && quote != '\'' {
    raise XmlMalformed(
      line=self.line,
      col=self.col,
      reason="declaration attribute value must be quoted",
    )
  }
  self.pos += 1
  let out = StringBuilder::new()
  while self.pos < self.chars.length() && self.chars[self.pos] != quote {
    out.write_char(self.chars[self.pos])
    self.pos += 1
  }
  self.expect(quote)
  out.to_string()
}

///|
fn expanded_key(name : QName) -> String {
  match name.ns {
    Some(ns) => "{\{ns}}\{name.local_name}"
    None => name.local_name
  }
}

///|
fn format_qname(name : QName) -> String {
  match name.prefix {
    Some(prefix) => "\{prefix}:\{name.local_name}"
    None => name.local_name
  }
}
