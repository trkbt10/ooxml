///|
/// WordprocessingML §17 viewer for the reader -> context -> viewer pipeline.
///
/// render_html walks a CT_Document domain tree and emits representative HTML
/// for document, body, paragraph, run, text, and table content. It is a
/// structural renderer for inspection and tests, not a layout-equivalent Word
/// renderer.
///
/// The renderer builds an `@xml.Element` tree and serialises it once via
/// `@markup.serialize`.  Serialisation delegates to `@xml.write`, which
/// escapes every attribute value and text node, so no OOXML payload can
/// break out of its element / attribute context — no HTML is ever assembled
/// by string concatenation.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/viewer"
}

///|
/// Render a WordprocessingML CT_Document tree as minimal HTML.
/// Structural-only output (no inline styles); see `render_styled_html`
/// for a style-aware variant.
pub fn render_html(
  domain : @domain.CT_Document,
  rels_resolver? : (String) -> String? = _ => None,
) -> String {
  let article : @xml.Element = {
    name: @markup.qname("article"),
    attributes: [@markup.attr("data-ooxml", "wml")],
    children: render_children(domain.element, plain=true, rels_resolver~),
  }
  @markup.serialize(article)
}

///|
/// Render a WordprocessingML CT_Document tree as style-aware HTML.
/// Walks `<w:pPr>` and `<w:rPr>` to produce inline CSS for paragraph
/// alignment and run formatting (bold/italic/underline/strike/color/size/
/// rtl/vertAlign) per Part 1 §17.3.1.25 / §17.3.2.27.
///
/// §17.15.1.51 `<w:color w:themeColor>` cascade: when the run
/// carries a theme reference instead of an explicit hex, this
/// renderer surfaces the raw `@themeColor` value via the source
/// `<w:color>` element on the rebuilt DOM but does NOT resolve
/// it.  The SVG renderer (svg.mbt) honours the full
/// ThemeColorMap cascade; the HTML path stays explicit-only
/// because the consumer's CSS can override theme colours via
/// CSS variables.  Adding theme parameter would require
/// threading through every helper in this file (deferred to a
/// future signature widening).
pub fn render_styled_html(
  domain : @domain.CT_Document,
  rels_resolver? : (String) -> String? = _ => None,
) -> String {
  let article : @xml.Element = {
    name: @markup.qname("article"),
    attributes: [@markup.attr("data-ooxml", "wml")],
    children: render_children(domain.element, plain=false, rels_resolver~),
  }
  @markup.serialize(article)
}

///|
/// Render every child of `element` into a flat node array, dispatching
/// each child element through `render_element`. Text / CData nodes are
/// emitted as XML text nodes (escaped by the writer).
fn render_children(
  element : @xml.Element,
  plain~ : Bool,
  rels_resolver~ : (String) -> String?,
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(child_el) =>
        render_element(child_el, plain~, rels_resolver~, out)
      Text(text) | CData(text) => out.push(@markup.text(text))
      _ => ()
    }
  }
  out
}

///|
/// Render one `@xml.Element` of the WML tree, appending the resulting
/// node(s) to `out`.  Most cases produce exactly one node, but a few
/// (e.g. plain runs that contribute no wrapper) push a flat sequence.
fn render_element(
  element : @xml.Element,
  plain~ : Bool,
  rels_resolver~ : (String) -> String?,
  out : Array[@xml.Node],
) -> Unit {
  match element.name.local_name {
    "p" => {
      // §17.13.5.29 — revision data attribute belongs on every
      // render mode because it is semantic metadata, not style.
      let attrs : Array[@xml.Attribute] = []
      if !plain {
        append_paragraph_style(element, attrs)
      }
      append_paragraph_change_attr(element, attrs)
      append_paragraph_frame_attrs(element, attrs)
      let children = if plain {
        render_children(element, plain~, rels_resolver~)
      } else {
        render_paragraph_content(element, rels_resolver~)
      }
      out.push(@markup.elem("p", attrs, children))
    }
    "r" =>
      if plain {
        // §17.13.5.31 — preserve the run's revision data attribute
        // even in plain mode; we wrap the run in a `<span>` only
        // when there's something to record, so plain output stays
        // semantically minimal otherwise.
        let attrs : Array[@xml.Attribute] = []
        append_run_change_attr(element, attrs)
        if attrs.length() == 0 {
          for n in render_children(element, plain~, rels_resolver~) {
            out.push(n)
          }
        } else {
          out.push(@markup.elem(
            "span", attrs, render_children(element, plain~, rels_resolver~),
          ))
        }
      } else {
        let attrs : Array[@xml.Attribute] = []
        append_run_style(element, attrs)
        append_run_change_attr(element, attrs)
        out.push(@markup.elem(
          "span", attrs, render_children(element, plain~, rels_resolver~),
        ))
      }
    "t" => out.push(@markup.text(text_content(element)))
    // §17.16.5.2 `<w:fldChar>` is a control marker (begin /
    // separate / end) carrying NO user-visible text.  §17.16.5.4
    // `<w:instrText>` carries the field's instruction code (e.g.
    // " PAGE "); per spec the cached result between fldChar
    // separate / end is what surfaces, NOT the instruction.
    // Both elements must be silently dropped.
    "fldChar" => ()
    "instrText" => ()
    "delInstrText" => ()
    // §17.13.5.14 `<w:delText>` — text scheduled for deletion.
    // Render as normal text so the surrounding `<del>` wrapper
    // (added by the "del" case below) styles it with the
    // strike-through convention.  The xml:space attribute on
    // `<w:delText>` MUST be honoured the same way as `<w:t>`.
    "delText" => out.push(@markup.text(text_content(element)))
    // §17.3.3.1 `<w:br>` — line/page/column break.  `@w:clear`
    // (none/left/right/all) applies to textWrapping breaks and
    // controls which floating objects the break clears past.
    // Surface it as `data-ooxml-br-clear` so float-aware
    // consumers can apply the CSS `clear` rule.
    "br" => {
      let attrs : Array[@xml.Attribute] = []
      match attr_value(element, "clear") {
        Some(c) =>
          if c.length() > 0 && c != "none" {
            attrs.push(@markup.attr("data-ooxml-br-clear", c))
          }
        None => ()
      }
      out.push(@markup.elem("br", attrs, []))
    }
    "tab" => out.push(@markup.text("\u{0009}"))
    // §17.3.3.13 `<w:lastRenderedPageBreak>` — hint emitted by
    // Word at the last save's page break position.  Surface as
    // a `<span data-ooxml-page-break-hint>` so consumers can
    // visualise paginations without re-flowing.
    "lastRenderedPageBreak" =>
      out.push(@markup.elem(
        "span", [@markup.attr("data-ooxml-page-break-hint", "")], [],
      ))
    // §17.3.3.22 `<w:pgNum>` — page-number sentinel.
    "pgNum" =>
      out.push(@markup.elem("span", [@markup.attr("data-ooxml-pgnum", "")], []))
    // §17.3.3.31-.36 — day/month/year sentinels in header/footer
    // text.  Each carries no inner content; the live value is
    // supplied at print time.  Surface as data-ooxml-date-* so
    // consumers can substitute the current date.
    "dayShort" => out.push(date_sentinel("dayShort"))
    "dayLong" => out.push(date_sentinel("dayLong"))
    "monthShort" => out.push(date_sentinel("monthShort"))
    "monthLong" => out.push(date_sentinel("monthLong"))
    "yearShort" => out.push(date_sentinel("yearShort"))
    "yearLong" => out.push(date_sentinel("yearLong"))
    // §17.13.5.18 `<w:ins>` — insertion revision wrapper.
    // Children are runs that ARE part of the document content;
    // the wrapper exists so consumers can highlight insertions.
    // Spec attributes @w:id (xsd:int, required), @w:author
    // (xsd:string), @w:date (ST_DateTime).  Wrap in `<ins>`
    // (the HTML5 element with the same semantics) and surface
    // the spec attributes as `data-w-*`.
    "ins" =>
      out.push(revision_wrapper(element, plain~, html_tag="ins", rels_resolver~))
    // §17.13.5.20 `<w:moveTo>` — track-moved-to revision wrapper.
    // Semantically an insertion (the destination of a move) —
    // wrap in `<ins>` too, but tag the data attribute so
    // consumers can distinguish move from straight insertion.
    "moveTo" =>
      out.push(revision_wrapper(element, plain~, html_tag="ins", rels_resolver~))
    // §17.13.5.14 `<w:del>` — deletion revision wrapper.  Wrap
    // in `<del>`; the inner `<w:r>/<w:delText>` will surface as
    // strike-through text.
    "del" =>
      out.push(revision_wrapper(element, plain~, html_tag="del", rels_resolver~))
    // §17.13.5.27 `<w:moveFrom>` — track-moved-from revision
    // wrapper.  Semantically a deletion (the source of a move)
    // — wrap in `<del>`.
    "moveFrom" =>
      out.push(revision_wrapper(element, plain~, html_tag="del", rels_resolver~))
    // §17.11.14 `<w:footnoteReference w:id="…">` — pointer
    // from the body text to a footnote in /word/footnotes.xml.
    // Emit `<sup data-ooxml-footnote-id="…">` so renderers can
    // hyperlink to the resolved footnote later.
    "footnoteReference" => out.push(ref_marker(element, kind="footnote"))
    // §17.11.7 `<w:endnoteReference>` — same shape, different
    // part.
    "endnoteReference" => out.push(ref_marker(element, kind="endnote"))
    // §17.11.7 `<w:footnoteRef>` / §17.11.14 `<w:endnoteRef>` —
    // auto-numbered reference mark inside a footnote/endnote
    // body part.  Surface as `<sup data-ooxml-footnote-ref>` /
    // `data-ooxml-endnote-ref` so consumers can substitute the
    // resolved mark value.
    "footnoteRef" =>
      out.push(@markup.elem(
        "sup", [@markup.attr("data-ooxml-footnote-ref", "")], [],
      ))
    "endnoteRef" =>
      out.push(@markup.elem(
        "sup", [@markup.attr("data-ooxml-endnote-ref", "")], [],
      ))
    // §17.11.x `<w:separator>` / `<w:continuationSeparator>` —
    // footnote-body separator runs that render as horizontal
    // rules.  Emit `<hr data-ooxml-separator>` so consumers can
    // style them; empty rules degrade gracefully.
    "separator" =>
      out.push(@markup.elem("hr", [@markup.attr("data-ooxml-separator", "")], []))
    "continuationSeparator" =>
      out.push(@markup.elem(
        "hr", [@markup.attr("data-ooxml-continuation-separator", "")], [],
      ))
    // §17.10.x `<w:annotationRef>` — comment-author reference
    // inside a comment body.
    "annotationRef" =>
      out.push(@markup.elem(
        "sup", [@markup.attr("data-ooxml-annotation-ref", "")], [],
      ))
    // §17.3.1.x `<w:ptab>` — positional tab.  We render as a
    // tab character and surface the spec attributes
    // (`@alignment`, `@relativeTo`, `@leader`) on a wrapping
    // span so consumers can resolve the actual jump target.
    "ptab" => {
      let attrs : Array[@xml.Attribute] = [@markup.attr("data-ooxml-ptab", "1")]
      for key in ["alignment", "relativeTo", "leader"] {
        match attr_value(element, key) {
          Some(v) => attrs.push(@markup.attr("data-ooxml-ptab-" + key, v))
          None => ()
        }
      }
      out.push(@markup.elem("span", attrs, [@markup.text("\u{0009}")]))
    }
    // §17.13.4.5 `<w:commentReference w:id="…">` — Word's
    // comment reference; render as a non-printing marker so the
    // text remains intact.
    "commentReference" => out.push(ref_marker(element, kind="comment"))
    // §17.13.4.6 `<w:commentRangeStart>` / §17.13.4.7
    // `<w:commentRangeEnd>` — endpoints of a comment range over
    // body text.  Emit empty `<span>` markers so downstream JS
    // can wrap the range.
    "commentRangeStart" =>
      out.push(range_marker(element, kind="comment-range-start"))
    "commentRangeEnd" =>
      out.push(range_marker(element, kind="comment-range-end"))
    // §17.3.3.30 `<w:sym>` — symbol character.  Carries @w:font
    // (the symbol font's typeface) and @w:char (xsd:hexBinary
    // codepoint).  Per spec, the codepoint is the Unicode value
    // of the glyph in the @w:font typeface — for symbol fonts
    // (Symbol / Wingdings / Webdings) it's the legacy
    // private-use codepoint, but spec says emit the value as
    // the Unicode character.  Surface the font as
    // `data-ooxml-sym-font` so consumers can apply the matching
    // typeface; emit the codepoint as the actual character.
    "sym" =>
      match render_sym(element) {
        Some(node) => out.push(node)
        None => ()
      }
    // §22.1.2.77 `<m:oMath>` and §22.1.2.78 `<m:oMathPara>`
    // — Office Math markup.  Walks the OMML tree (defined in
    // the Office MathML schema, separate prefix `m:`) and emits
    // semantic MathML via the office_math viewer.
    "oMath" =>
      out.push(
        @xml.Node::Element(
          @omml_viewer.render_mathml(@omml.CT_OMath::new(element)),
        ),
      )
    "oMathPara" =>
      for node in render_omath_para(element) {
        out.push(node)
      }
    "tbl" =>
      out.push(@markup.elem(
        "table", [], render_children(element, plain~, rels_resolver~),
      ))
    "tr" =>
      out.push(@markup.elem(
        "tr", [], render_children(element, plain~, rels_resolver~),
      ))
    "tc" => {
      // §17.4.83 `<w:tcPr>/<w:vAlign>` — surface the cell's
      // vertical anchor as `data-ooxml-v-align` so consumers can
      // apply `vertical-align`/`align-items` rules in HTML.
      let attrs : Array[@xml.Attribute] = []
      match first_child_named(element, "tcPr") {
        None => ()
        Some(tc_pr) =>
          match first_child_named(tc_pr, "vAlign") {
            None => ()
            Some(va) =>
              match attr_value(va, "val") {
                Some(v) => attrs.push(@markup.attr("data-ooxml-v-align", v))
                None => ()
              }
          }
      }
      out.push(@markup.elem(
        "td", attrs, render_children(element, plain~, rels_resolver~),
      ))
    }
    // §17.16.22 CT_Hyperlink — emit `<a href="…">` honouring
    // both external (`r:id`) and internal (`@w:anchor`) targets.
    "hyperlink" => out.push(render_hyperlink(element, plain~, rels_resolver~))
    "pPr" => ()
    "rPr" => ()
    "sectPr" => ()
    _ =>
      for n in render_children(element, plain~, rels_resolver~) {
        out.push(n)
      }
  }
}

///|
/// §17.3.3.31-.36 — build a `<span data-ooxml-date="…">` sentinel.
fn date_sentinel(kind : String) -> @xml.Node {
  @markup.elem("span", [@markup.attr("data-ooxml-date", kind)], [])
}

///|
/// Render the §17.3.1.25 paragraph content, skipping `<w:pPr>` properties
/// (already consumed by paragraph_style) and emitting the runs.
fn render_paragraph_content(
  element : @xml.Element,
  rels_resolver~ : (String) -> String?,
) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(e) =>
        if e.name.local_name != "pPr" {
          render_element(e, plain=false, rels_resolver~, out)
        }
      Text(text) | CData(text) => out.push(@markup.text(text))
      _ => ()
    }
  }
  out
}

///|
/// Extract an inline style attribute for a §17.3.1.25 paragraph from its
/// `<w:pPr>` child and append it (when non-empty) to `attrs`. Currently
/// maps `<w:jc>` (§17.3.1.13) to text-align and `<w:bidi>` to direction.
fn append_paragraph_style(
  p : @xml.Element,
  attrs : Array[@xml.Attribute],
) -> Unit {
  let p_pr = match first_child_named(p, "pPr") {
    None => return
    Some(pp) => pp
  }
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
  // §17.3.1.6 `<w:bidi>` — paragraph-level RTL.  Toggles the
  // paragraph's reading direction so child runs default to
  // right-to-left ordering.  We emit CSS `direction:rtl;` so
  // the HTML renderer flips the block.
  if first_child_named(p_pr, "bidi") is Some(_) {
    css.write_string("direction:rtl;")
  }
  let s = css.to_string()
  if s != "" {
    attrs.push(@markup.attr("style", s))
  }
}

///|
/// Extract an inline style attribute for a §17.9.2.27 run from its
/// `<w:rPr>` child and append it (when non-empty) to `attrs`. Currently
/// maps `<w:b>`, `<w:i>`, `<w:u>`, `<w:color>`, and `<w:sz>` (§17.3.2
/// run properties).
fn append_run_style(r : @xml.Element, attrs : Array[@xml.Attribute]) -> Unit {
  let r_pr = match first_child_named(r, "rPr") {
    None => return
    Some(rp) => rp
  }
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
  // §17.3.2.30 `<w:rtl>` — right-to-left script run.
  if first_child_named(r_pr, "rtl") is Some(_) {
    css.write_string("direction:rtl;unicode-bidi:bidi-override;")
  }
  // §17.3.2.42 `<w:vertAlign w:val="superscript|subscript">`.
  match first_child_named(r_pr, "vertAlign") {
    None => ()
    Some(va) =>
      match attr_value(va, "val") {
        Some("superscript") =>
          css.write_string("vertical-align:super;font-size:smaller;")
        Some("subscript") =>
          css.write_string("vertical-align:sub;font-size:smaller;")
        _ => ()
      }
  }
  let s = css.to_string()
  if s != "" {
    attrs.push(@markup.attr("style", s))
  }
}

///|
/// §22.1.2.78 `<m:oMathPara>` — a paragraph-level math wrapper
/// that contains one or more `<m:oMath>` children.  Emit each
/// nested `<m:oMath>` through the office_math viewer and collect
/// the resulting MathML nodes.
fn render_omath_para(element : @xml.Element) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(e) =>
        if e.name.local_name == "oMath" {
          out.push(
            @xml.Node::Element(
              @omml_viewer.render_mathml(@omml.CT_OMath::new(e)),
            ),
          )
        }
      _ => ()
    }
  }
  out
}

///|
/// §17.3.3.30 `<w:sym>` — render the @w:char codepoint as a
/// character, optionally wrapped in a `<span>` carrying
/// `data-ooxml-sym-font` so consumers can apply the matching
/// symbol typeface.  @w:char is xsd:hexBinary up to 4 hex
/// digits; values outside the BMP (>U+FFFF) MUST go through
/// surrogate-pair encoding which is automatic when we synthesise
/// the character via Char::from_int.  Returns `None` when the
/// element carries no `@char`.
fn render_sym(element : @xml.Element) -> @xml.Node? {
  let hex = match attr_value(element, "char") {
    Some(v) => v
    None => ""
  }
  let font = match attr_value(element, "font") {
    Some(v) => v
    None => ""
  }
  if hex == "" {
    return None
  }
  // Parse @w:char as a hex codepoint.  ST_ShortHexNumber per
  // §17.18.79; ST_LongHexNumber per §17.18.50.
  let codepoint = parse_hex_codepoint(hex)
  let glyph = match codepoint {
    Some(cp) =>
      match Int::to_char(cp) {
        Some(c) => c.to_string()
        None => ""
      }
    None => ""
  }
  if font == "" {
    Some(@markup.text(glyph))
  } else {
    Some(@markup.elem(
      "span",
      [@markup.attr("data-ooxml-sym-font", font)],
      [@markup.text(glyph)],
    ))
  }
}

///|
/// Decode an xsd:hexBinary attribute value to a Unicode
/// codepoint.  Returns None on malformed input.
fn parse_hex_codepoint(hex : String) -> Int? {
  if hex.length() == 0 || hex.length() > 8 {
    return None
  }
  let mut value = 0
  let mut i = 0
  while i < hex.length() {
    let c = hex.code_unit_at(i).to_int()
    let digit = if c >= 0x30 && c <= 0x39 {
      c - 0x30
    } else if c >= 0x41 && c <= 0x46 {
      c - 0x41 + 10
    } else if c >= 0x61 && c <= 0x66 {
      c - 0x61 + 10
    } else {
      return None
    }
    value = value * 16 + digit
    i = i + 1
  }
  Some(value)
}

///|
/// §17.11.14 / §17.11.7 / §17.13.4.5 — emit a `<sup>` reference
/// marker pointing at a footnote / endnote / comment.  `@w:id`
/// is the spec-required pointer; surface it as
/// `data-ooxml-{kind}-id` so consumers can rebuild the link
/// after resolving the corresponding part.
fn ref_marker(element : @xml.Element, kind~ : String) -> @xml.Node {
  let id = match attr_value(element, "id") {
    Some(v) => v
    None => ""
  }
  @markup.elem("sup", [@markup.attr("data-ooxml-" + kind + "-id", id)], [])
}

///|
/// §17.13.4.6 / §17.13.4.7 — emit an empty `<span>` marker for
/// a comment range start/end.  The @w:id ties the start and end
/// markers to the same comment, surfaced as `data-ooxml-comment-id`.
fn range_marker(element : @xml.Element, kind~ : String) -> @xml.Node {
  let id = match attr_value(element, "id") {
    Some(v) => v
    None => ""
  }
  @markup.elem("span", [@markup.attr("data-ooxml-" + kind, id)], [])
}

///|
/// §17.13.5 — emit an HTML `<ins>` / `<del>` wrapper for a
/// `<w:ins>` / `<w:del>` / `<w:moveTo>` / `<w:moveFrom>`
/// revision element.  Surfaces the spec's @w:id, @w:author,
/// and @w:date attributes as `data-w-id`, `data-w-author`,
/// `data-w-date`, plus the local-name of the source element as
/// `data-ooxml-revision` so consumers can distinguish
/// insertion vs. move-to (both wrap in `<ins>`) and deletion
/// vs. move-from (both wrap in `<del>`).
fn revision_wrapper(
  element : @xml.Element,
  plain~ : Bool,
  html_tag~ : String,
  rels_resolver~ : (String) -> String?,
) -> @xml.Node {
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("data-ooxml-revision", element.name.local_name),
  ]
  for key in ["id", "author", "date"] {
    match attr_value(element, key) {
      Some(v) => attrs.push(@markup.attr("data-w-" + key, v))
      None => ()
    }
  }
  @markup.elem(
    html_tag, attrs, render_children(element, plain~, rels_resolver~),
  )
}

///|
/// §17.13.5.29 `<w:pPrChange>` — paragraph-property revision marker
/// recording the @id (xsd:int) and author of the change.  When the
/// paragraph carries one, append it as `data-ooxml-ppr-change` to
/// `attrs` so downstream consumers can visualise the revision.
fn append_paragraph_change_attr(
  p : @xml.Element,
  attrs : Array[@xml.Attribute],
) -> Unit {
  match first_child_named(p, "pPr") {
    None => ()
    Some(p_pr) =>
      match first_child_named(p_pr, "pPrChange") {
        None => ()
        Some(change) => {
          let id = match attr_value(change, "id") {
            Some(v) => v
            None => ""
          }
          attrs.push(@markup.attr("data-ooxml-ppr-change", id))
        }
      }
  }
}

///|
/// §17.3.1.11 `<w:framePr>` — text-frame properties (float-wrap
/// box around the paragraph).  Surface every spec attribute as
/// `data-ooxml-frame-*` so consumers can apply CSS float / position
/// rules.  Per spec the attribute set covers: w (width), h
/// (height), wrap, vAnchor, hAnchor, x, y, xAlign, yAlign,
/// hSpace, vSpace, hRule, dropCap, lines, anchorLock.
fn append_paragraph_frame_attrs(
  p : @xml.Element,
  attrs : Array[@xml.Attribute],
) -> Unit {
  let p_pr = match first_child_named(p, "pPr") {
    None => return
    Some(pp) => pp
  }
  let frame = match first_child_named(p_pr, "framePr") {
    None => return
    Some(f) => f
  }
  attrs.push(@markup.attr("data-ooxml-frame", "1"))
  // §17.3.1.11 — full attribute list per spec.
  for key in [
    "w", "h", "wrap", "vAnchor", "hAnchor", "x", "y", "xAlign", "yAlign",
    "hSpace", "vSpace", "hRule", "dropCap", "lines", "anchorLock",
  ] {
    match attr_value(frame, key) {
      Some(v) => attrs.push(@markup.attr("data-ooxml-frame-" + key, v))
      None => ()
    }
  }
}

///|
/// §17.13.5.31 `<w:rPrChange>` — run-property revision marker
/// (mirror of pPrChange for run properties).  Appends its @id as
/// `data-ooxml-rpr-change` to `attrs`.
fn append_run_change_attr(
  r : @xml.Element,
  attrs : Array[@xml.Attribute],
) -> Unit {
  match first_child_named(r, "rPr") {
    None => ()
    Some(r_pr) =>
      match first_child_named(r_pr, "rPrChange") {
        None => ()
        Some(change) => {
          let id = match attr_value(change, "id") {
            Some(v) => v
            None => ""
          }
          attrs.push(@markup.attr("data-ooxml-rpr-change", id))
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
/// §17.16.22 CT_Hyperlink — emit a `<a>` element with as much of
/// the spec attribute set as we can synthesize without the
/// document's relationship table.  Always emits the descended
/// children as the anchor's content.
///
/// Attribute mapping:
///   @w:anchor → `href="#<anchor>"` (internal target, no rels
///               lookup needed)
///   @w:tooltip → `title="<tooltip>"`
///   @r:id     → `data-ooxml-r-id="<rid>"` (consumer resolves
///               via document rels)
fn render_hyperlink(
  element : @xml.Element,
  plain~ : Bool,
  rels_resolver~ : (String) -> String?,
) -> @xml.Node {
  let mut anchor : String? = None
  let mut tooltip : String? = None
  let mut r_id : String? = None
  for a in element.attributes {
    match (a.name.prefix, a.name.local_name) {
      (Some("w"), "anchor") | (None, "anchor") => anchor = Some(a.value)
      (Some("w"), "tooltip") | (None, "tooltip") => tooltip = Some(a.value)
      (Some("r"), "id") => r_id = Some(a.value)
      _ => ()
    }
  }
  let attrs : Array[@xml.Attribute] = []
  // §17.16.22 — when the caller supplies a rels_resolver and
  // the hyperlink carries an @r:id, prefer the resolved URL as
  // the actual `href`.  The raw r:id still surfaces as
  // `data-ooxml-r-id` for consumers that want to round-trip.
  let resolved_url : String? = match r_id {
    Some(rid) => rels_resolver(rid)
    None => None
  }
  match resolved_url {
    Some(url) => attrs.push(@markup.attr("href", url))
    None =>
      match anchor {
        Some(a) => attrs.push(@markup.attr("href", "#" + a))
        None => ()
      }
  }
  match tooltip {
    Some(t) => attrs.push(@markup.attr("title", t))
    None => ()
  }
  match r_id {
    Some(rid) => attrs.push(@markup.attr("data-ooxml-r-id", rid))
    None => ()
  }
  @markup.elem("a", attrs, render_children(element, plain~, rels_resolver~))
}
