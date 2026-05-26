///|
/// Structured markup construction for the SVG renderers.
///
/// The renderers build their SVG output as an `@xml.Element` tree
/// and serialise it once via `serialize_svg`.  Serialisation
/// delegates to `@xml.write`, which escapes every attribute value
/// and text node, so no OOXML payload can break out of its element
/// / attribute context.  No output XML is ever assembled by string
/// concatenation.

///|
/// The SVG namespace URI (SVG 1.1 §1.3).  An SVG document tree
/// built for `serialize_svg` carries this URI on every element so
/// the `@xml` writer emits a single `xmlns` declaration on the
/// root and none on the descendants.
pub let svg_ns : String = "http://www.w3.org/2000/svg"

///|
/// The XLink namespace URI (used by SVG `xlink:href`).
pub let xlink_ns : String = "http://www.w3.org/1999/xlink"

///|
/// Build a `QName` with no prefix and no namespace.
fn qname(name : String) -> @xml.QName {
  { prefix: None, local_name: name, ns: None }
}

///|
/// Build a `QName` in the given default namespace (no prefix).
/// Every element of a namespaced tree (e.g. SVG) must carry the
/// same URI so the writer emits exactly one `xmlns` declaration
/// on the root.
pub fn qname_ns(name : String, ns : String) -> @xml.QName {
  { prefix: None, local_name: name, ns: Some(ns) }
}

///|
/// Build an attribute (name + value).  The value is escaped by
/// the writer at serialisation time, never here.
pub fn attr(name : String, value : String) -> @xml.Attribute {
  { name: qname(name), value }
}

///|
/// Build a prefixed attribute in the given namespace, e.g.
/// `xlink:href`.  The prefix is declared on the element that
/// first carries it.
pub fn attr_ns(
  prefix : String,
  name : String,
  ns : String,
  value : String,
) -> @xml.Attribute {
  { name: { prefix: Some(prefix), local_name: name, ns: Some(ns) }, value }
}

///|
/// Build an element node in the given default namespace.
pub fn elem_ns(
  tag : String,
  ns : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element({ name: qname_ns(tag, ns), attributes: attrs, children })
}

///|
/// Wrap a raw string as an XML text node.  The string is escaped
/// by the writer at serialisation time.
pub fn text(value : String) -> @xml.Node {
  @xml.Node::Text(value)
}

///|
/// Serialise a single element (and its subtree) to a string
/// fragment — declaration-less and doctype-less, so the result
/// is exactly the element's own markup, ready for embedding.
///
/// The `@xml.write` writer always produces well-formed UTF-8, so
/// `decode_lossy` never actually substitutes; it merely avoids
/// propagating an unreachable decode error.
pub fn serialize(root : @xml.Element) -> String {
  let doc : @xml.Document = { declaration: None, doctype: None, root }
  @utf8.decode_lossy(@xml.write(doc)[:])
}

///|
/// Serialise an SVG root element to a string fragment.  The root
/// element must already be built in `svg_ns` (via `elem_ns` /
/// `qname_ns`); the writer then emits one `xmlns` declaration on
/// the `<svg>` root.
pub fn serialize_svg(root : @xml.Element) -> String {
  serialize(root)
}

///|
/// Strip every `data-*` attribute from an already-serialised SVG /
/// XML document.  This is the **SoT** for "drop debug labels": the
/// viewer renderers (WML / SML / PML / DML) freely decorate their
/// `<svg>` output with `data-ooxml-*` attributes that surface
/// schema-level metadata (settings, fonts, theme references,
/// presentation-level options …) for spec-aware consumers and the
/// catalog harness's differential render verifier.  Those
/// attributes are inspection labels, not draw primitives — the
/// rendered visual output is identical whether they are present or
/// absent.  Top-level viewer entry points (`Document::to_svg`,
/// `Workbook::to_svg`, `Presentation::to_svg`) call this once on
/// the serialised result when their `debug_attrs` flag is `false`
/// so production consumers receive a clean SVG while the catalog
/// harness (which passes `debug_attrs=true`) still sees the labels
/// its diff machinery depends on.
///
/// Why one post-pass instead of threading a flag through every
/// emission site: every `data-*` push lives in viewer code that
/// already builds a complete `@xml.Element` tree per spec section.
/// Gating each push (580 sites across 20 files in the WML / SML /
/// PML / DML viewers as of this writing) would multiply call-site
/// noise without any change in serialised output that a consumer
/// would observe.  A single byte-stream scan over the already-
/// serialised SVG enforces the SoT in one place: a renderer that
/// emits a new `data-foo` attribute tomorrow needs no further
/// plumbing to satisfy the "labels are opt-in" invariant.
///
/// Implementation mirrors the catalog verifier's
/// `svg_visible_skeleton` (src/cmd/catalog/verify.mbt) on its
/// attribute-pass: a linear scan over the byte view drops every
/// attribute whose name starts with `data-` (the unambiguous
/// debug-label prefix used across this project's viewers).  Unlike
/// the verifier we PRESERVE PCDATA whitespace and XML comments —
/// the verifier collapses both to make two render outputs
/// byte-compare equivalently; here we are producing the canonical
/// production SVG, so we keep every non-debug character.  Quoted
/// attribute values that contain `>` are honoured (`"` and `'`
/// both open / close quote runs the same way `@xml.write`
/// produces them).
pub fn strip_debug_attrs(svg : String) -> String {
  // MoonBit's `String::to_bytes` returns the UTF-16 code-unit
  // byte layout, which would interleave NULs for ASCII content
  // and break a byte-level scanner.  Force UTF-8 explicitly so
  // the scanner sees the same byte stream a downstream consumer
  // (browser, rsvg, Inkscape) would parse.
  let bytes = @utf8.encode(svg[:])
  let out = Buffer()
  let n = bytes.length()
  let mut i = 0
  // ASCII codes — comparing UInt16 / Int code units, not Char.
  let lt = '<'.to_int()
  let gt = '>'.to_int()
  let eq = '='.to_int()
  let dq = '"'.to_int()
  let sq = '\''.to_int()
  let sp = ' '.to_int()
  let tab = '\t'.to_int()
  let nl = '\n'.to_int()
  let cr = '\r'.to_int()
  fn is_ws(b : Int) -> Bool {
    b == sp || b == tab || b == nl || b == cr
  }

  while i < n {
    let c = bytes[i].to_int()
    if c != lt {
      // Outside any tag — copy byte verbatim.  PCDATA, comments,
      // and whitespace pass through unchanged.
      out.write_byte(bytes[i])
      i = i + 1
      continue
    }
    // `<!…` (comment / CDATA / DOCTYPE) and `<?…?>` (PI): copy the
    // whole construct verbatim — they carry no attribute we touch.
    if i + 1 < n {
      let next = bytes[i + 1].to_int()
      let bang = '!'.to_int()
      let qm = '?'.to_int()
      if next == bang || next == qm {
        // Copy until matching `>` (good enough for the constructs
        // the viewer emits — XML declaration, doctype, comment;
        // none nest `>` outside an attribute the writer wouldn't
        // produce here).  Inside a comment `-->` ends it; the
        // simple `>` scan also matches because the writer never
        // emits `>` inside the comment body.
        out.write_byte(bytes[i])
        i = i + 1
        while i < n {
          let cc = bytes[i].to_int()
          out.write_byte(bytes[i])
          i = i + 1
          if cc == gt {
            break
          }
        }
        continue
      }
    }
    // Start tag or end tag — walk attribute by attribute, dropping
    // those whose name starts with `data-`.  The tag-name token
    // (everything up to the first whitespace) is always copied;
    // attribute names live after whitespace.  Whitespace that
    // PRECEDES a dropped attribute is dropped too — otherwise the
    // output would carry the dangling space the dropped attribute
    // owned, which would visibly differ from a clean writer pass.
    out.write_byte(b'<')
    i = i + 1
    let mut in_quote = 0
    let mut at_name_start = true
    let mut tag_name_done = false
    let mut attr_first_chars = Buffer()
    let mut attr_buf = Buffer()
    let mut ws_buf = Buffer()
    let mut copying = true
    while i < n {
      let ch = bytes[i].to_int()
      if in_quote == 0 {
        if ch == gt {
          // End of tag — commit any whitespace that PRECEDES a
          // surviving attribute or the closing `>` itself; if the
          // current attribute is being dropped, its leading
          // whitespace dies with it.  `attr_buf` carries the
          // last-still-open attribute (empty after a fresh
          // boundary).
          //
          // The self-close `/` token belongs to the tag, NOT to
          // the last attribute — strip it off the (possibly
          // dropped) `attr_buf` and emit it before `>` so a
          // `<rect data-foo="x"/>` collapses to `<rect/>` rather
          // than `<rect>` (which would nest the next rect inside
          // the unclosed one and break every consumer).
          let mut self_close = false
          if attr_buf.length() > 0 {
            let ab = attr_buf.contents()
            if ab[ab.length() - 1] == b'/' {
              self_close = true
              let trimmed = Buffer()
              for k in 0..<(ab.length() - 1) {
                trimmed.write_byte(ab[k])
              }
              attr_buf = trimmed
            }
          }
          if copying {
            if attr_buf.length() > 0 {
              out.write_bytes(ws_buf.contents())
              out.write_bytes(attr_buf.contents())
            }
          }
          if self_close {
            out.write_byte(b'/')
          }
          out.write_byte(b'>')
          i = i + 1
          break
        } else if !tag_name_done && is_ws(ch) {
          // Boundary between tag name and the first attribute.
          // Buffer the whitespace; whether it survives depends
          // on the attribute that follows.
          tag_name_done = true
          attr_buf = Buffer()
          attr_first_chars = Buffer()
          ws_buf = Buffer()
          ws_buf.write_byte(bytes[i])
          at_name_start = true
          copying = true
          i = i + 1
        } else if tag_name_done && is_ws(ch) && attr_buf.length() == 0 {
          // Run of whitespace BEFORE the next attribute token
          // — keep buffering so we can drop it with the attr
          // when needed.
          ws_buf.write_byte(bytes[i])
          i = i + 1
        } else if tag_name_done && is_ws(ch) {
          // Boundary between two attribute tokens.  Commit the
          // previous attr buffer (if it survived the drop test)
          // along with the whitespace that introduced it, then
          // start a fresh whitespace buffer for the next.
          if copying {
            out.write_bytes(ws_buf.contents())
            out.write_bytes(attr_buf.contents())
          }
          attr_buf = Buffer()
          attr_first_chars = Buffer()
          ws_buf = Buffer()
          ws_buf.write_byte(bytes[i])
          at_name_start = true
          copying = true
          i = i + 1
        } else if tag_name_done && ch == eq {
          // End of attribute name — decide drop/keep.
          let name = attr_first_chars.contents()
          if name.length() >= 5 &&
            name[0] == b'd' &&
            name[1] == b'a' &&
            name[2] == b't' &&
            name[3] == b'a' &&
            name[4] == b'-' {
            copying = false
          }
          attr_buf.write_byte(b'=')
          i = i + 1
          at_name_start = false
        } else if tag_name_done && (ch == dq || ch == sq) {
          in_quote = ch
          attr_buf.write_byte(bytes[i])
          i = i + 1
        } else {
          if !tag_name_done {
            // Still inside the tag name — write verbatim, no
            // attribute buffering.
            out.write_byte(bytes[i])
          } else {
            if at_name_start {
              attr_first_chars.write_byte(bytes[i])
            }
            attr_buf.write_byte(bytes[i])
          }
          i = i + 1
        }
      } else {
        // Inside a quoted attribute value — copy verbatim into
        // the attr buffer; close the quote when the matching
        // delimiter is seen.
        attr_buf.write_byte(bytes[i])
        if ch == in_quote {
          in_quote = 0
        }
        i = i + 1
      }
    }
  }
  @utf8.decode_lossy(out.contents()[:])
}
