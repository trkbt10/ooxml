///|
/// Office Math §22.1 viewer for the reader -> context -> viewer pipeline.
///
/// `render_html` walks a `CT_OMath` domain tree and emits MathML.
///
/// The renderer builds the MathML output as a structured
/// `@xml.Element` tree (never by string concatenation) and
/// serialises it exactly once via `serialize_fragment`, which
/// routes every attribute value and text node through the
/// audited `@xml.escape_attribute` / `@xml.escape_text` helpers.
/// This makes the output injection-safe by construction: an OMML
/// `<m:t>` or `<m:chr>` carrying `<`, `&`, `"` etc. can never
/// break out of its element / attribute context.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/office_math/viewer"
}

// ---------------------------------------------------------------
// MathML node construction helpers.
//
// MathML elements carry no namespace prefix here: they are
// emitted for inline embedding inside HTML, where the `<math>`
// element's default namespace governs its subtree.  Node
// construction and serialisation are delegated to the shared
// `@markup` package; `mel` / `mrow` / `mo` are MathML-specific
// shorthands over it.
// ---------------------------------------------------------------

///|
/// Build a MathML element node with the given attributes and
/// child nodes.
fn mel(
  tag : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Node {
  @markup.elem(tag, attrs, children)
}

///|
/// Build an attribute (name + value); the value is escaped by
/// the serialiser, never here.
fn mattr(name : String, value : String) -> @xml.Attribute {
  @markup.attr(name, value)
}

///|
/// Wrap a raw string as an XML text node.
fn text_node(value : String) -> @xml.Node {
  @markup.text(value)
}

///|
/// `<mrow>` grouping element around the given children.
fn mrow(children : Array[@xml.Node]) -> @xml.Node {
  mel("mrow", [], children)
}

///|
/// `<mo>` operator element carrying a single glyph string.
fn mo(glyph : String) -> @xml.Node {
  mel("mo", [], [text_node(glyph)])
}

///|
/// Render an OMML `CT_OMath` tree as a MathML `<math>` element.
///
/// The MathML is a structured `@xml.Element` tree, returned
/// directly so a host renderer (e.g. the WordprocessingML viewer)
/// can embed it into its own document tree without a
/// serialise-then-reparse round trip.
pub fn render_mathml(domain : @domain.CT_OMath) -> @xml.Element {
  {
    name: @markup.qname("math"),
    attributes: [mattr("data-ooxml", "omml")],
    children: render_children(domain.element),
  }
}

///|
/// Render an OMML `CT_OMath` tree as MathML embedded in minimal
/// HTML.
///
/// The MathML body is built as a structured `@xml.Element` tree
/// (via `render_mathml`) and serialised by the shared `@markup`
/// package, which delegates to `@xml.write`.  `@xml.write`
/// escapes every attribute value and text node, so the output is
/// injection-safe by construction.  No XML is ever assembled by
/// string concatenation.
pub fn render_html(domain : @domain.CT_OMath) -> String {
  @markup.serialize(render_mathml(domain))
}

///|
/// Render every child of `element` into a flat node array,
/// dispatching each child element through `render_element`.
fn render_children(element : @xml.Element) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(child_el) => out.push(render_element(child_el))
      Text(text) | CData(text) => out.push(text_node(text))
      _ => ()
    }
  }
  out
}

///|
/// `<mrow>` around `element`'s rendered children — the standard
/// transparent grouping used for OMML argument slots.
fn render_children_row(element : @xml.Element) -> @xml.Node {
  mrow(render_children(element))
}

///|
/// §22.1.2 — map every spec-defined OMML element to its MathML
/// counterpart.  Unknown elements (xs:any extensions, vendor
/// namespaces) fall through to a transparent `<mrow>` descent so
/// unknown content neither crashes the renderer nor is silently
/// dropped.
fn render_element(element : @xml.Element) -> @xml.Node {
  match element.name.local_name {
    // §22.1.2.116 t — math text.
    "t" => mel("mtext", [], [text_node(text_content(element))])
    // §22.1.2.87 r — run.  §22.1.2.91 `<m:rPr>` carries
    // §22.1.2.94 `<m:scr>` and §22.1.2.111 `<m:sty>`, which
    // combine into the MathML `mathvariant` attribute.
    "r" => render_math_run(element)
    // §22.1.2.36 f — fraction (bar / noBar / skw / lin).
    "f" => render_fraction(element)
    // §22.1.2.86 rad — radical (msqrt vs mroot via degHide).
    "rad" => render_rad(element)
    // §22.1.2.111 sup — superscript (single).
    "sup" =>
      mel("msup", [], [render_children_row(element)])
    // §22.1.2.114 sub — subscript (single).
    "sub" =>
      mel("msub", [], [render_children_row(element)])
    // §22.1.2.115 sSup — superscript pair (base + sup).
    "sSup" => mel("msup", [], render_children(element))
    // §22.1.2.112 sSub — subscript pair.
    "sSub" => mel("msub", [], render_children(element))
    // §22.1.2.113 sSubSup — both sub and sup.
    "sSubSup" => mel("msubsup", [], render_children(element))
    // §22.1.2.79 nary — n-ary operator (sum, product, integral).
    "nary" => render_nary(element)
    // §22.1.2.72 limUpp — upper limit (lim, max, min).
    "limUpp" => mel("mover", [], render_children(element))
    // §22.1.2.71 limLow — lower limit.
    "limLow" => mel("munder", [], render_children(element))
    // §22.1.2.42 func — function application.
    "func" => render_func(element)
    // §22.1.2.41 fName — function name; grouped as <mrow>.
    "fName" => render_children_row(element)
    // §22.1.2.31 d + §22.1.2.32 dPr — delimiter.
    "d" => render_delimiter(element)
    // §22.1.2.30 ctrlPr — run-properties metadata only.
    "ctrlPr" => mrow([])
    // §22.1.2.81 phant + §22.1.2.82 phantPr — phantom.
    "phant" => render_phant(element)
    // §22.1.2.99 sPre — pre-script pair.
    "sPre" => render_pre_script(element)
    // §22.1.2.78 m — matrix.
    "m" => render_matrix(element)
    // §22.1.2.77 mr — matrix row.
    "mr" => mel("mtr", [], render_children(element))
    // §22.1.2.45 e — math element.  Reached transparently only as
    // a matrix cell (the `<m:mr>` path); every other container
    // (`d`, `func`, `nary`, …) consumes its own `<m:e>`.  In the
    // matrix-cell context the correct MathML wrapper is `<mtd>`.
    "e" => mel("mtd", [], render_children(element))
    // §22.1.2.51 groupChr — group character (over/underbrace).
    "groupChr" => render_group_chr(element)
    // §22.1.2.8 bar — accent bar.
    "bar" => render_bar(element)
    // §22.1.2.20 box — grouping box (no border; see render_box).
    "box" => render_box(element)
    // §22.1.2.4 acc — accent.
    "acc" => render_acc(element)
    // §22.1.2.12 borderBox — bordered box.
    "borderBox" => render_border_box(element)
    // §22.1.2.36 num / §22.1.2.35 den — fraction parts.
    "num" => render_children_row(element)
    "den" => render_children_row(element)
    // §22.1.2.34 deg — radical degree.
    "deg" => mel("mn", [], render_children(element))
    // §22.1.2.83 oMath — wrapper; descend transparently.
    "oMath" => mrow(render_children(element))
    // §22.1.2.84 oMathPara — paragraph wrapper.
    "oMathPara" => render_children_row(element)
    // §22.1.2.66 eqArr — equation array.
    "eqArr" => render_eq_arr(element)
    // Property-only elements that carry no rendered content.
    "rPr" | "mPr" | "naryPr" | "limUppPr" | "limLowPr" | "funcPr"
    | "matrixPr" | "groupChrPr" | "barPr" | "boxPr" | "accPr"
    | "borderBoxPr" | "radPr" | "sSupPr" | "sSubPr" | "sSubSupPr"
    | "eqArrPr" | "dPr" | "phantPr" | "fPr" | "sPrePr" => mrow([])
    // Unknown element — descend transparently rather than
    // swallowing the content.
    _ => mrow(render_children(element))
  }
}

///|
/// Read the `@m:val` attribute of `el`, or "" when absent.
fn read_val(el : @xml.Element) -> String {
  let mut v = ""
  for a in el.attributes {
    if a.name.local_name == "val" {
      v = a.value
    }
  }
  v
}

///|
/// True when `el` carries a `CT_OnOff`-style true value.  When
/// `default_on` is true an element with no `@val` counts as ON
/// (the CT_OnOff default); otherwise an absent `@val` is OFF.
/// An explicit `@val` always wins over `default_on`.
fn val_is_on(el : @xml.Element, default_on~ : Bool = false) -> Bool {
  let mut result = default_on
  for a in el.attributes {
    if a.name.local_name == "val" {
      result = a.value == "1" || a.value == "true" || a.value == "on"
    }
  }
  result
}

///|
/// §22.1.2.79 nary + §22.1.2.80 naryPr — n-ary operator.
/// Children: `<m:naryPr>` (carries `@chr`, `@subHide`,
/// `@supHide`, `@limLoc`), `<m:sub>`, `<m:sup>`, `<m:e>`.
/// Emits `<munderover>` (or `<msubsup>` when `limLoc="subSup"`)
/// with the operator glyph as the base.
fn render_nary(element : @xml.Element) -> @xml.Node {
  let mut chr = "\u{2211}" // U+2211 N-ARY SUMMATION — spec default.
  let mut sub_hide = false
  let mut sup_hide = false
  // §22.1.2.52 limLoc — "undOvr" (default) or "subSup".
  let mut lim_loc = "undOvr"
  let mut sub_nodes : Array[@xml.Node] = []
  let mut sup_nodes : Array[@xml.Node] = []
  let mut e_nodes : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "naryPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  match p.name.local_name {
                    "chr" => {
                      let v = read_val(p)
                      if v.length() > 0 {
                        chr = v
                      }
                    }
                    "subHide" => sub_hide = val_is_on(p)
                    "supHide" => sup_hide = val_is_on(p)
                    "limLoc" => {
                      let v = read_val(p)
                      if v.length() > 0 {
                        lim_loc = v
                      }
                    }
                    _ => ()
                  }
                _ => ()
              }
            }
          "sub" => sub_nodes = render_children(c)
          "sup" => sup_nodes = render_children(c)
          "e" => e_nodes = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  // §22.1.2.52 — subSup attaches the limits as scripts; undOvr
  // (default) places them under / over the operator.
  let use_scripts = lim_loc == "subSup"
  let both_tag = if use_scripts { "msubsup" } else { "munderover" }
  let sub_tag = if use_scripts { "msub" } else { "munder" }
  let sup_tag = if use_scripts { "msup" } else { "mover" }
  let op = mo(chr)
  // §22.1.2.80 subHide / supHide — drop the hidden bound.
  let operator : @xml.Node = if sub_hide && sup_hide {
    op
  } else if sub_hide {
    mel(sup_tag, [], [op, mrow(sup_nodes)])
  } else if sup_hide {
    mel(sub_tag, [], [op, mrow(sub_nodes)])
  } else {
    mel(both_tag, [], [op, mrow(sub_nodes), mrow(sup_nodes)])
  }
  mrow([operator, mrow(e_nodes)])
}

///|
/// §22.1.2.42 func — function-apply node.  Children: `<m:funcPr>`
/// (metadata), `<m:fName>` (the name), `<m:e>` (the argument).
/// Emits `<mrow> fName <mo>&ApplyFunction;</mo> arg </mrow>`;
/// U+2061 is the invisible APPLY FUNCTION operator.
fn render_func(element : @xml.Element) -> @xml.Node {
  let mut f_name : @xml.Node? = None
  let mut arg : @xml.Node? = None
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "fName" => f_name = Some(render_element(c))
          "e" => arg = Some(render_children_row(c))
          _ => ()
        }
      _ => ()
    }
  }
  let row : Array[@xml.Node] = []
  match f_name {
    Some(n) => row.push(n)
    None => ()
  }
  // The ApplyFunction operator only goes between an actual name
  // and an actual argument.
  if f_name is Some(_) && arg is Some(_) {
    row.push(mo("\u{2061}"))
  }
  match arg {
    Some(n) => row.push(n)
    None => ()
  }
  mrow(row)
}

///|
/// §22.1.2.31 d + §22.1.2.32 dPr — delimiter.
///
/// `<m:dPr>` optionally overrides the bracket / separator glyphs
/// via `<m:begChr>`, `<m:endChr>`, `<m:sepChr>`.  Per §22.1.2.32
/// the defaults are `(`, `)` and `|`.  A char element that is
/// *present* with an empty `@val` means "no glyph", which differs
/// from the element being absent (→ default glyph).  Each
/// `<m:e>` child is one delimited argument.  Maps to MathML
/// `<mfenced open=".." close=".." separators="..">`.
fn render_delimiter(element : @xml.Element) -> @xml.Node {
  let mut beg = "("
  let mut end = ")"
  let mut sep = "|"
  let args : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "dPr" =>
            for pr in c.children {
              match pr {
                Element(p) => {
                  // An explicitly present char element overrides
                  // the default — including with an empty value.
                  let v = read_val(p)
                  match p.name.local_name {
                    "begChr" => beg = v
                    "endChr" => end = v
                    "sepChr" => sep = v
                    _ => ()
                  }
                }
                _ => ()
              }
            }
          "e" => args.push(render_children_row(c))
          _ => ()
        }
      _ => ()
    }
  }
  mel(
    "mfenced",
    [mattr("open", beg), mattr("close", end), mattr("separators", sep)],
    args,
  )
}

///|
/// §22.1.2.81 phant + §22.1.2.82 phantPr — phantom.
///   • default (no phantPr / `show` off): the content reserves
///     its box but is invisible → `<mphantom>`.
///   • `<m:show val="1">`: the content IS painted; the
///     `<m:zeroWid>` / `<m:zeroAsc>` / `<m:zeroDesc>` flags zero
///     specific dimensions → `<mpadded width="0">` etc.
fn render_phant(element : @xml.Element) -> @xml.Node {
  let mut show = false
  let mut zero_wid = false
  let mut zero_asc = false
  let mut zero_desc = false
  let mut e_nodes : Array[@xml.Node]? = None
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "phantPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  match p.name.local_name {
                    "show" => show = val_is_on(p)
                    "zeroWid" => zero_wid = val_is_on(p)
                    "zeroAsc" => zero_asc = val_is_on(p)
                    "zeroDesc" => zero_desc = val_is_on(p)
                    _ => ()
                  }
                _ => ()
              }
            }
          "e" => e_nodes = Some(render_children(c))
          _ => ()
        }
      _ => ()
    }
  }
  // Some producers omit the `<m:e>` wrapper and put run content
  // directly under `<m:phant>`; in that case render every
  // non-property child.
  let body : Array[@xml.Node] = match e_nodes {
    Some(ns) => ns
    None => {
      let acc : Array[@xml.Node] = []
      for child in element.children {
        match child {
          Element(c) =>
            if c.name.local_name != "phantPr" {
              acc.push(render_element(c))
            }
          Text(t) | CData(t) => acc.push(text_node(t))
          _ => ()
        }
      }
      acc
    }
  }
  if !show {
    // Default phantom — invisible, box preserved.
    mel("mphantom", [], body)
  } else {
    // show="1" — content visible; zeroed dims via <mpadded>.
    let attrs : Array[@xml.Attribute] = []
    if zero_wid {
      attrs.push(mattr("width", "0"))
    }
    if zero_asc {
      attrs.push(mattr("height", "0"))
    }
    if zero_desc {
      attrs.push(mattr("depth", "0"))
    }
    mel("mpadded", attrs, body)
  }
}

///|
/// §22.1.2.66 eqArr + §22.1.2.35 eqArrPr — equation array.  Each
/// `<m:e>` child is one row.  `baseJc` maps to the `<mtable>`
/// `align` attribute; `rSp` maps to `rowspacing` (and is also
/// surfaced raw as `data-ooxml-eqarr-rsp` because its unit
/// depends on `rSpRule`).
fn render_eq_arr(element : @xml.Element) -> @xml.Node {
  let mut base_jc = ""
  let mut row_spacing = ""
  let rows : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "eqArrPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  match p.name.local_name {
                    "baseJc" => base_jc = read_val(p)
                    "rSp" => row_spacing = read_val(p)
                    _ => ()
                  }
                _ => ()
              }
            }
          "e" =>
            // Each <m:e> is a full row.
            rows.push(mel("mtr", [], [mel("mtd", [], render_children(c))]))
          _ => ()
        }
      _ => ()
    }
  }
  let attrs : Array[@xml.Attribute] = []
  if base_jc.length() > 0 {
    attrs.push(mattr("align", base_jc))
  }
  if row_spacing.length() > 0 {
    attrs.push(mattr("rowspacing", row_spacing))
    attrs.push(mattr("data-ooxml-eqarr-rsp", row_spacing))
  }
  mel("mtable", attrs, rows)
}

///|
/// §22.1.2.86 rad + §22.1.2.90 radPr/degHide — radical.  When
/// `<m:degHide val="1">` is set (or `<m:deg>` is empty) the
/// expression is a square root → `<msqrt>`; otherwise it is an
/// nth-root → `<mroot>` with the degree index.
fn render_rad(element : @xml.Element) -> @xml.Node {
  let mut deg_hide = false
  let mut deg_nodes : Array[@xml.Node] = []
  let mut e_nodes : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "radPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  if p.name.local_name == "degHide" {
                    deg_hide = val_is_on(p)
                  }
                _ => ()
              }
            }
          "deg" => deg_nodes = render_children(c)
          "e" => e_nodes = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  if deg_hide || deg_nodes.length() == 0 {
    mel("msqrt", [], [mrow(e_nodes)])
  } else {
    mel("mroot", [], [mrow(e_nodes), mrow(deg_nodes)])
  }
}

///|
/// §22.1.2.36 f + §22.1.2.118 type — fraction.  `<m:fPr>/<m:type
/// val>` selects the form:
///   bar (default) → `<mfrac>`
///   noBar         → `<mfrac linethickness="0">` (binomial stack)
///   skw           → skewed fraction (num / den around U+2044)
///   lin           → linear inline fraction `num / den`
fn render_fraction(element : @xml.Element) -> @xml.Node {
  let mut frac_type = "bar"
  let mut num : Array[@xml.Node] = []
  let mut den : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "fPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  if p.name.local_name == "type" {
                    let v = read_val(p)
                    if v.length() > 0 {
                      frac_type = v
                    }
                  }
                _ => ()
              }
            }
          "num" => num = render_children(c)
          "den" => den = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  match frac_type {
    "noBar" =>
      // Binomial-style stack: a fraction with no rule line.
      mel("mfrac", [mattr("linethickness", "0")], [mrow(num), mrow(den)])
    "lin" =>
      // Linear inline fraction: num / den on one line.
      mrow([mrow(num), mo("/"), mrow(den)])
    "skw" =>
      // Skewed fraction: numerator raised, denominator lowered,
      // separated by a fraction slash (U+2044).
      mrow([
        mel("msup", [], [mrow([]), mrow(num)]),
        mo("\u{2044}"),
        mel("msub", [], [mrow([]), mrow(den)]),
      ])
    // "bar" or any unrecognised value — the default horizontal
    // bar fraction.
    _ => mel("mfrac", [], [mrow(num), mrow(den)])
  }
}

///|
/// §22.1.2.87 r — render an OMML run, applying the §22.1.2.94
/// `<m:scr>` script and §22.1.2.111 `<m:sty>` style from
/// `<m:rPr>` as a MathML `mathvariant` wrapper.
fn render_math_run(element : @xml.Element) -> @xml.Node {
  let mut scr = ""
  let mut sty = ""
  for child in element.children {
    match child {
      Element(c) =>
        if c.name.local_name == "rPr" {
          for attr_child in c.children {
            match attr_child {
              Element(p) =>
                match p.name.local_name {
                  "scr" => scr = read_val(p)
                  "sty" => sty = read_val(p)
                  _ => ()
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  let inner = render_children(element)
  let variant = math_variant(scr, sty)
  if variant == "" {
    mrow(inner)
  } else {
    mel("mstyle", [mattr("mathvariant", variant)], inner)
  }
}

///|
/// §22.1.2.94 / §22.1.2.111 — map an OMML (scr, sty) pair to a
/// MathML `mathvariant` token.  Returns "" when the pair is the
/// default (roman + p) so no wrapper is emitted.
fn math_variant(scr : String, sty : String) -> String {
  // sty defaults to "i" (italic) for math runs per §22.1.2.111.
  let style = if sty == "" { "i" } else { sty }
  match scr {
    "double-struck" => "double-struck"
    "script" =>
      if style == "b" || style == "bi" {
        "bold-script"
      } else {
        "script"
      }
    "fraktur" =>
      if style == "b" || style == "bi" {
        "bold-fraktur"
      } else {
        "fraktur"
      }
    "sans-serif" =>
      match style {
        "b" => "bold-sans-serif"
        "i" => "sans-serif-italic"
        "bi" => "sans-serif-bold-italic"
        _ => "sans-serif"
      }
    "monospace" => "monospace"
    // "roman" or empty — the default Latin script.
    _ =>
      match style {
        "b" => "bold"
        "i" => "italic"
        "bi" => "bold-italic"
        "p" => "normal"
        _ => ""
      }
  }
}

///|
/// §22.1.2.4 acc + §22.1.2.24 accPr — accented expression.  The
/// accent glyph comes from `<m:accPr>/<m:chr val>`; per spec the
/// default when `<m:chr>` is absent is U+0302 COMBINING
/// CIRCUMFLEX ACCENT.  Maps to `<mover accent="true">`.
fn render_acc(element : @xml.Element) -> @xml.Node {
  let mut chr = ""
  let mut e_nodes : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "accPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  if p.name.local_name == "chr" {
                    let v = read_val(p)
                    if v.length() > 0 {
                      chr = v
                    }
                  }
                _ => ()
              }
            }
          "e" => e_nodes = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  // U+0302 COMBINING CIRCUMFLEX ACCENT — spec default.
  let glyph = if chr.length() > 0 { chr } else { "\u{0302}" }
  mel("mover", [mattr("accent", "true")], [mrow(e_nodes), mo(glyph)])
}

///|
/// §22.1.2.78 m + §22.1.2.67 mPr/mcs/mc/mcPr/mcJc — matrix.
/// `<m:mPr>/<m:mcs>` holds `<m:mc>` column-group descriptors,
/// each carrying `<m:mcPr>/<m:count>` and `<m:mcPr>/<m:mcJc>`.
/// The per-group justification is expanded into a flat per-column
/// `columnalign` token list on the `<mtable>`.
fn render_matrix(element : @xml.Element) -> @xml.Node {
  let col_aligns : Array[String] = []
  let rows : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "mPr" =>
            for mpr_child in c.children {
              match mpr_child {
                Element(mp) =>
                  if mp.name.local_name == "mcs" {
                    for mcs_child in mp.children {
                      match mcs_child {
                        Element(mc) =>
                          if mc.name.local_name == "mc" {
                            collect_matrix_column(mc, col_aligns)
                          }
                        _ => ()
                      }
                    }
                  }
                _ => ()
              }
            }
          "mr" => rows.push(render_element(c))
          _ => ()
        }
      _ => ()
    }
  }
  let attrs : Array[@xml.Attribute] = []
  if col_aligns.length() > 0 {
    let buf = StringBuilder::new()
    for i, a in col_aligns {
      if i > 0 {
        buf.write_char(' ')
      }
      buf.write_string(a)
    }
    attrs.push(mattr("columnalign", buf.to_string()))
  }
  mel("mtable", attrs, rows)
}

///|
/// Read one `<m:mc>` column-group descriptor: `<m:mcPr>/<m:count>`
/// and `<m:mcPr>/<m:mcJc>`.  The group's justification is pushed
/// `count` times onto `col_aligns`.
fn collect_matrix_column(
  mc : @xml.Element,
  col_aligns : Array[String],
) -> Unit {
  let mut count = 1
  let mut jc = "center"
  for mc_child in mc.children {
    match mc_child {
      Element(mcpr) =>
        if mcpr.name.local_name == "mcPr" {
          for pr in mcpr.children {
            match pr {
              Element(e) =>
                match e.name.local_name {
                  "count" =>
                    match (try? @strconv.parse_int(read_val(e))) {
                      Ok(n) => if n > 0 { count = n }
                      Err(_) => ()
                    }
                  "mcJc" => {
                    let v = read_val(e)
                    if v.length() > 0 {
                      jc = v
                    }
                  }
                  _ => ()
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  // inside / outside have no direct MathML equivalent — center.
  let mathml_jc = match jc {
    "left" => "left"
    "right" => "right"
    "center" => "center"
    _ => "center"
  }
  for _ in 0..<count {
    col_aligns.push(mathml_jc)
  }
}

///|
/// §22.1.2.12 borderBox + §22.1.2.13 borderBoxPr — bordered box.
/// By default all four edges are drawn; the
/// `hideTop`/`hideBot`/`hideLeft`/`hideRight` toggles suppress
/// individual edges and `strikeH`/`strikeV`/`strikeBLTR`/
/// `strikeTLBR` add strike lines.  The surviving edge set becomes
/// a `<menclose>` `notation` token list.
fn render_border_box(element : @xml.Element) -> @xml.Node {
  let mut hide_top = false
  let mut hide_bot = false
  let mut hide_left = false
  let mut hide_right = false
  let mut strike_h = false
  let mut strike_v = false
  let mut strike_bltr = false
  let mut strike_tlbr = false
  let mut e_nodes : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "borderBoxPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  // CT_OnOff toggles default ON when present.
                  match p.name.local_name {
                    "hideTop" => hide_top = val_is_on(p, default_on=true)
                    "hideBot" => hide_bot = val_is_on(p, default_on=true)
                    "hideLeft" => hide_left = val_is_on(p, default_on=true)
                    "hideRight" => hide_right = val_is_on(p, default_on=true)
                    "strikeH" => strike_h = val_is_on(p, default_on=true)
                    "strikeV" => strike_v = val_is_on(p, default_on=true)
                    "strikeBLTR" =>
                      strike_bltr = val_is_on(p, default_on=true)
                    "strikeTLBR" =>
                      strike_tlbr = val_is_on(p, default_on=true)
                    _ => ()
                  }
                _ => ()
              }
            }
          "e" => e_nodes = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  let tokens : Array[String] = []
  if !hide_top {
    tokens.push("top")
  }
  if !hide_bot {
    tokens.push("bottom")
  }
  if !hide_left {
    tokens.push("left")
  }
  if !hide_right {
    tokens.push("right")
  }
  if strike_h {
    tokens.push("horizontalstrike")
  }
  if strike_v {
    tokens.push("verticalstrike")
  }
  if strike_bltr {
    tokens.push("updiagonalstrike")
  }
  if strike_tlbr {
    tokens.push("downdiagonalstrike")
  }
  let notation = if tokens.length() == 0 {
    // All edges hidden, no strikes — a transparent box.
    "none"
  } else {
    let buf = StringBuilder::new()
    for i, t in tokens {
      if i > 0 {
        buf.write_char(' ')
      }
      buf.write_string(t)
    }
    buf.to_string()
  }
  mel("menclose", [mattr("notation", notation)], [mrow(e_nodes)])
}

///|
/// §22.1.2.20 box + §22.1.2.7 boxPr — render a "box" object.
///
/// Despite the name, `<m:box>` draws **no** border — a visible
/// frame is the job of `<m:borderBox>` (§22.1.2.12).  `<m:box>`
/// is a grouping container; its `<m:boxPr>` carries layout /
/// parsing directives.  Two have a direct MathML realisation,
/// emitted as the first children of the row:
///   • `brk` — a manual line break → `<mspace linebreak="newline">`
///     (MathML §3.2.7).
///   • `aln` — an alignment point → `<malignmark>` (MathML §3.5.5).
///
/// The remaining three (`opEmu` operator-emulation, `noBreak`
/// keep-together, `diff` differential) have no MathML element or
/// attribute: MathML cannot express "this subtree must not break"
/// or "treat this group as one operator", and the differential
/// spacing tweak is a property of the consumer's layout engine,
/// not of the markup.  Dropping them would lose spec-defined
/// information, so each set flag is surfaced as a `data-ooxml-box-*`
/// attribute on the `<mrow>` for a spec-aware consumer to honour.
fn render_box(element : @xml.Element) -> @xml.Node {
  let mut op_emu = false
  let mut no_break = false
  let mut diff = false
  let mut brk = false
  let mut aln = false
  let mut e_nodes : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "boxPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  match p.name.local_name {
                    "opEmu" => op_emu = val_is_on(p, default_on=true)
                    "noBreak" => no_break = val_is_on(p, default_on=true)
                    "diff" => diff = val_is_on(p, default_on=true)
                    // `brk` is CT_ManualBreak — set whenever present.
                    "brk" => brk = true
                    "aln" => aln = val_is_on(p, default_on=true)
                    _ => ()
                  }
                _ => ()
              }
            }
          "e" => e_nodes = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  // Assemble the content row: `brk` / `aln` prepend a real
  // MathML node before the box content.
  let body : Array[@xml.Node] = []
  if brk {
    body.push(mel("mspace", [mattr("linebreak", "newline")], []))
  }
  if aln {
    body.push(mel("malignmark", [], []))
  }
  for n in e_nodes {
    body.push(n)
  }
  // `opEmu` / `noBreak` / `diff` have no MathML realisation;
  // surface the raw spec flags for a layout-aware consumer.
  let attrs : Array[@xml.Attribute] = []
  if op_emu {
    attrs.push(mattr("data-ooxml-box-opemu", "1"))
  }
  if no_break {
    attrs.push(mattr("data-ooxml-box-nobreak", "1"))
  }
  if diff {
    attrs.push(mattr("data-ooxml-box-diff", "1"))
  }
  mel("mrow", attrs, body)
}

///|
/// §22.1.2.8 bar + §22.1.2.9 barPr/pos — accent bar.  `<m:barPr>/
/// <m:pos val>` selects whether the bar sits above (`pos="top"`,
/// default → `<mover>` + U+203E OVERLINE) or below (`pos="bot"` →
/// `<munder>` + U+0332 COMBINING LOW LINE) the base.
fn render_bar(element : @xml.Element) -> @xml.Node {
  let mut pos = "top"
  let mut e_nodes : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "barPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  if p.name.local_name == "pos" {
                    let v = read_val(p)
                    if v.length() > 0 {
                      pos = v
                    }
                  }
                _ => ()
              }
            }
          "e" => e_nodes = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  if pos == "bot" {
    mel("munder", [], [mrow(e_nodes), mo("\u{0332}")])
  } else {
    mel("mover", [], [mrow(e_nodes), mo("\u{203E}")])
  }
}

///|
/// §22.1.2.51 groupChr + §22.1.2.52 groupChrPr/pos — group
/// character (over/underbrace).  `pos="top"` places the char
/// above the base (`<mover>`); `pos="bot"` below (`<munder>`).
/// The glyph is `<m:chr val>` (default U+23DE TOP CURLY BRACKET).
fn render_group_chr(element : @xml.Element) -> @xml.Node {
  let mut pos = "top"
  let mut chr = ""
  let mut e_nodes : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "groupChrPr" =>
            for attr_child in c.children {
              match attr_child {
                Element(p) =>
                  match p.name.local_name {
                    "pos" => {
                      let v = read_val(p)
                      if v.length() > 0 {
                        pos = v
                      }
                    }
                    "chr" => {
                      let v = read_val(p)
                      if v.length() > 0 {
                        chr = v
                      }
                    }
                    _ => ()
                  }
                _ => ()
              }
            }
          "e" => e_nodes = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  // U+23DE TOP CURLY BRACKET — spec-neutral default.
  let glyph = if chr.length() > 0 { chr } else { "\u{23DE}" }
  if pos == "bot" {
    mel("munder", [], [mrow(e_nodes), mo(glyph)])
  } else {
    mel("mover", [], [mrow(e_nodes), mo(glyph)])
  }
}

///|
/// §22.1.2.99 sPre + §22.1.2.100 sPrePr — pre-script pair.
/// Children: `<m:sPrePr>` (metadata), `<m:sub>` (pre-subscript),
/// `<m:sup>` (pre-superscript), `<m:e>` (base).  Maps to MathML
/// `<mmultiscripts>` with the pre-script form:
///   <mmultiscripts> BASE <mprescripts/> SUB SUP </mmultiscripts>
fn render_pre_script(element : @xml.Element) -> @xml.Node {
  let mut sub_nodes : Array[@xml.Node] = []
  let mut sup_nodes : Array[@xml.Node] = []
  let mut e_nodes : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "sub" => sub_nodes = render_children(c)
          "sup" => sup_nodes = render_children(c)
          "e" => e_nodes = render_children(c)
          _ => ()
        }
      _ => ()
    }
  }
  mel("mmultiscripts", [], [
    mrow(e_nodes),
    mel("mprescripts", [], []),
    mrow(sub_nodes),
    mrow(sup_nodes),
  ])
}

///|
/// Concatenate every descendant text node of `element`.
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
