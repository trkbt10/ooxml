///|
/// Office Math §22.1 — SVG renderer.
///
/// `render_svg` walks a `CT_OMath` domain tree and lays it out
/// geometrically into SVG primitives (`<text>`, `<line>`, `<rect>`,
/// `<path>`).  SVG is the package's only output form: the result is
/// a self-contained `<g>` element a host SVG renderer (the
/// WordprocessingML SVG viewer) can translate to any baseline — no
/// MathML, no `<foreignObject>`.
///
/// Layout model
/// ------------
/// Every fragment is laid out into a `MathBox`: a width plus an
/// `ascent` (extent above the baseline) and a `descent` (extent
/// below it), together with a list of SVG nodes positioned in the
/// box's own coordinate space — x grows rightward from the box's
/// left edge, y grows downward with the baseline at y = 0.
///
/// Composite constructs (fractions, radicals, scripts, …) lay out
/// their children into sub-`MathBox`es and then shift those boxes
/// into place with `shift`, which rewrites every node's coordinates.
/// Nothing is assembled by string concatenation; the SVG tree is a
/// structured `@xml.Element` graph serialised once by `@markup`.
///
/// Glyph widths come from `@glyph.measure_text_width`, the same
/// resolver-backed measurement path the WordprocessingML viewer
/// uses, so math runs and surrounding body text share one metric
/// basis.

///|
/// A laid-out math fragment.
///
/// `nodes` are SVG nodes already positioned in this box's space:
/// the box's left edge is x = 0 and its baseline is y = 0.
/// `ascent` is the height above the baseline, `descent` the depth
/// below it; the total box height is `ascent + descent`.
priv struct MathBox {
  width : Double
  ascent : Double
  descent : Double
  nodes : Array[@xml.Node]
}

///|
/// Layout context threaded through the recursion: the current font
/// size (shrinks inside scripts / fraction parts) and the fill
/// colour for glyphs and rules.
priv struct MathCtx {
  font_size_pt : Double
  color : String
}

///|
/// The result of `render_svg`: the assembled `<g>` element plus the
/// fragment's geometry so the host can position it.  `ascent` /
/// `descent` are measured from the math baseline; `width` and
/// `height` (= ascent + descent) bound the painted region.
pub(all) struct MathSvg {
  /// SVG `<g>` element; its content is laid out with the math
  /// baseline at y = 0, so the host translates it by `(x, baseline)`.
  group : @xml.Element
  width : Double
  ascent : Double
  descent : Double
}

///|
/// Total painted height of the rendered math (`ascent + descent`).
pub fn MathSvg::height(self : MathSvg) -> Double {
  self.ascent + self.descent
}

// ---------------------------------------------------------------
// Geometry constants.
//
// OMML carries no absolute measurements for the structural gaps
// (fraction rule clearance, radical overbar height, script drop,
// …); §22.1 leaves them to the consumer's layout engine.  The
// fractions below are expressed relative to the current font's
// x-height / em so they scale with `font_size_pt`.  They mirror the
// proportions a TeX-style math layout produces and are renderer
// policy, not a spec mandate.
// ---------------------------------------------------------------

///|
/// Fraction of the em used as the gap between a fraction's numerator
/// / denominator and its rule line.
const FRAC_GAP_EM : Double = 0.16

///|
/// Fraction-rule / radical-rule stroke width as a fraction of the em.
const RULE_EM : Double = 0.055

///|
/// Script (subscript / superscript) font size as a fraction of the
/// base size.  TeX uses 0.7 for the first script level.
const SCRIPT_SCALE : Double = 0.72

///|
/// Superscript baseline shift (upward) as a fraction of the base
/// em; subscript shift (downward) likewise.
const SUP_SHIFT_EM : Double = 0.42

///|
/// Subscript baseline shift downward as a fraction of the base em.
const SUB_SHIFT_EM : Double = 0.20

///|
/// Extra horizontal padding placed on each side of an operator
/// glyph (`+`, `=`, n-ary operators), as a fraction of the em.
const OP_PAD_EM : Double = 0.11

///|
/// Render an OMML `CT_OMath` tree as a self-contained SVG fragment.
///
/// `font_size_pt` is the base math font size; nested scripts and
/// fraction parts shrink relative to it.  `color` is the CSS colour
/// for every glyph and rule (e.g. `#000000`).
///
/// The returned `MathSvg` carries a `<g>` laid out with the math
/// baseline at y = 0: a host translates the group by its desired
/// `(x, baseline_y)` to place the equation.
pub fn render_svg(
  domain : @domain.CT_OMath,
  font_size_pt? : Double = 12.0,
  color? : String = "#000000",
) -> MathSvg {
  let ctx = { font_size_pt, color }
  let box = layout_row(domain.element.children, ctx)
  // The group's own content is already baseline-relative; the host
  // applies the outer translate.
  let group : @xml.Element = {
    name: @markup.qname_ns("g", @markup.svg_ns),
    attributes: [mattr("data-ooxml", "omml-svg")],
    children: box.nodes,
  }
  { group, width: box.width, ascent: box.ascent, descent: box.descent }
}

// ---------------------------------------------------------------
// MathBox helpers.
// ---------------------------------------------------------------

///|
/// An empty zero-size box.
fn empty_box() -> MathBox {
  { width: 0.0, ascent: 0.0, descent: 0.0, nodes: [] }
}

///|
/// Return a copy of `box` with every node translated by `(dx, dy)`
/// and the box origin re-anchored: the new box's left edge / baseline
/// sit `(dx, dy)` away from the old one.  `width` is unchanged;
/// `ascent` / `descent` are recomputed for the shifted baseline.
fn shift(box : MathBox, dx : Double, dy : Double) -> Array[@xml.Node] {
  let out : Array[@xml.Node] = []
  for node in box.nodes {
    out.push(translate_node(node, dx, dy))
  }
  out
}

///|
/// Wrap `nodes` in an SVG `<g transform="translate(dx,dy)">`.  Used
/// when re-anchoring a child box; a single group keeps the emitted
/// tree shallow and the transform exact.
fn translate_node(node : @xml.Node, dx : Double, dy : Double) -> @xml.Node {
  if dx == 0.0 && dy == 0.0 {
    return node
  }
  @markup.elem_ns(
    "g",
    @markup.svg_ns,
    [mattr("transform", "translate(" + num(dx) + "," + num(dy) + ")")],
    [node],
  )
}

///|
/// Concatenate `boxes` left to right on a shared baseline, inserting
/// `gap` between adjacent boxes.  The combined box's ascent /
/// descent are the per-box maxima.
fn hbox(boxes : Array[MathBox], gap? : Double = 0.0) -> MathBox {
  let nodes : Array[@xml.Node] = []
  let mut x = 0.0
  let mut ascent = 0.0
  let mut descent = 0.0
  for i, b in boxes {
    if i > 0 {
      x = x + gap
    }
    for n in shift(b, x, 0.0) {
      nodes.push(n)
    }
    x = x + b.width
    if b.ascent > ascent {
      ascent = b.ascent
    }
    if b.descent > descent {
      descent = b.descent
    }
  }
  { width: x, ascent, descent, nodes }
}

///|
/// Build an SVG `<text>` box for `content` at `font_size_pt`.
///
/// The glyph baseline is the box baseline (y = 0).  Width comes from
/// `@glyph`; the ascent / descent are derived from the font's
/// ascender ratio so the box bounds the glyph extent.
fn text_box(
  content : String,
  ctx : MathCtx,
  italic? : Bool = false,
  bold? : Bool = false,
) -> MathBox {
  if content == "" {
    return empty_box()
  }
  // Math notation conventionally renders in a serif/roman face — the
  // OOXML math font (Cambria Math) and every TeX math font (Latin
  // Modern Math, STIX) are serif. We pass the canonical Noto serif
  // family name and let the resolver pick whatever serif face the
  // host carries; body text defaults to sans-serif by contrast.
  let family = "Noto Serif"
  let weight = if bold { 700 } else { 400 }
  let width = try
    @glyph.measure_text_width(
      content,
      font_size_pt=ctx.font_size_pt,
      letter_spacing_px=0.0,
      family~,
      weight~,
      italic~,
    )
  catch {
    _ => 0.0
  } noraise {
    w => w
  }
  let px = ctx.font_size_pt * @glyph.pt_to_px
  // Ascender ratio drives the box's ascent/descent split. When the
  // resolver cannot satisfy the request we fall back to 0.8 — the
  // typical Latin `hhea.ascent / unitsPerEm` value — so the box
  // bounds still roughly contain the glyph.
  let ascender = try @glyph.get_ascender_ratio(family, weight~, italic~) catch {
    _ => 0.8
  } noraise {
    r => r
  }
  // The ascender ratio covers the cap/ascender extent; the descent
  // is the remaining em below the baseline.
  let ascent = px * ascender
  let descent = px * (1.0 - ascender)
  let attrs : Array[@xml.Attribute] = [
    mattr("x", "0"),
    mattr("y", "0"),
    mattr("font-size", num(px)),
    mattr("font-family", family),
    mattr("fill", ctx.color),
  ]
  if italic {
    attrs.push(mattr("font-style", "italic"))
  }
  if bold {
    attrs.push(mattr("font-weight", "bold"))
  }
  {
    width,
    ascent,
    descent,
    nodes: [
      @markup.elem_ns("text", @markup.svg_ns, attrs, [text_node(content)]),
    ],
  }
}

///|
/// A horizontal rule (fraction bar, radical overbar) of the given
/// `width` and `thickness`, drawn on the box baseline.  The box has
/// `ascent = thickness` and zero descent so the rule sits just above
/// the baseline of whatever stack it joins.
fn rule_box(width : Double, thickness : Double, ctx : MathCtx) -> MathBox {
  {
    width,
    ascent: thickness,
    descent: 0.0,
    nodes: [
      @markup.elem_ns(
        "rect",
        @markup.svg_ns,
        [
          mattr("x", "0"),
          mattr("y", num(-thickness)),
          mattr("width", num(width)),
          mattr("height", num(thickness)),
          mattr("fill", ctx.color),
        ],
        [],
      ),
    ],
  }
}

// ---------------------------------------------------------------
// OMML tree walk.
// ---------------------------------------------------------------

///|
/// Lay out a sequence of OMML child nodes left to right into one
/// `MathBox`.  Text / CData nodes encountered directly become glyph
/// boxes; element nodes dispatch through `layout_element`.
fn layout_row(nodes : Array[@xml.Node], ctx : MathCtx) -> MathBox {
  let boxes : Array[MathBox] = []
  for node in nodes {
    match node {
      Element(el) => boxes.push(layout_element(el, ctx))
      Text(t) | CData(t) => boxes.push(text_box(t, ctx))
      _ => ()
    }
  }
  if boxes.length() == 0 {
    return empty_box()
  }
  hbox(boxes)
}

///|
/// Lay out an OMML `<m:e>` / `<m:num>` / `<m:den>` / … argument
/// element: its children form a row.
fn layout_arg(element : @xml.Element, ctx : MathCtx) -> MathBox {
  layout_row(element.children, ctx)
}

///|
/// §22.1.2 — dispatch one OMML element to its SVG layout.  Mirrors
/// the element coverage of the MathML `render_element`; unknown
/// elements descend transparently as a row so no content is lost.
fn layout_element(element : @xml.Element, ctx : MathCtx) -> MathBox {
  match element.name.local_name {
    // §22.1.2.116 t — math text.
    "t" => text_box(text_content(element), ctx, italic=true)
    // §22.1.2.87 r — run.
    "r" => layout_math_run(element, ctx)
    // §22.1.2.36 f — fraction.
    "f" => layout_fraction(element, ctx)
    // §22.1.2.86 rad — radical.
    "rad" => layout_rad(element, ctx)
    // §22.1.2.115 sSup — superscript pair.
    "sSup" => layout_script(element, ctx, sup=true, sub=false)
    // §22.1.2.112 sSub — subscript pair.
    "sSub" => layout_script(element, ctx, sup=false, sub=true)
    // §22.1.2.113 sSubSup — both sub and sup.
    "sSubSup" => layout_script(element, ctx, sup=true, sub=true)
    // §22.1.2.99 sPre — pre-script pair.
    "sPre" => layout_pre_script(element, ctx)
    // §22.1.2.79 nary — n-ary operator.
    "nary" => layout_nary(element, ctx)
    // §22.1.2.72 limUpp — upper limit.
    "limUpp" => layout_limit(element, ctx, upper=true)
    // §22.1.2.71 limLow — lower limit.
    "limLow" => layout_limit(element, ctx, upper=false)
    // §22.1.2.42 func — function application.
    "func" => layout_func(element, ctx)
    // §22.1.2.31 d — delimiter.
    "d" => layout_delimiter(element, ctx)
    // §22.1.2.81 phant — phantom.
    "phant" => layout_phant(element, ctx)
    // §22.1.2.78 m — matrix.
    "m" => layout_matrix(element, ctx)
    // §22.1.2.66 eqArr — equation array.
    "eqArr" => layout_eq_arr(element, ctx)
    // §22.1.2.51 groupChr — group character.
    "groupChr" => layout_group_chr(element, ctx)
    // §22.1.2.8 bar — accent bar.
    "bar" => layout_bar(element, ctx)
    // §22.1.2.4 acc — accent.
    "acc" => layout_acc(element, ctx)
    // §22.1.2.20 box — grouping box (no border).
    "box" => layout_box(element, ctx)
    // §22.1.2.12 borderBox — bordered box.
    "borderBox" => layout_border_box(element, ctx)
    // §22.1.2.45 e — math element (matrix cell or transparent arg).
    "e" => layout_arg(element, ctx)
    // §22.1.2.36 num / §22.1.2.35 den — fraction parts.
    "num" | "den" => layout_arg(element, ctx)
    // §22.1.2.83 oMath — nested wrapper.
    "oMath" => layout_row(element.children, ctx)
    // §22.1.2.84 oMathPara — paragraph wrapper.
    "oMathPara" => layout_row(element.children, ctx)
    // Property-only elements carry no rendered content.
    "rPr"
    | "mPr"
    | "naryPr"
    | "limUppPr"
    | "limLowPr"
    | "funcPr"
    | "matrixPr"
    | "groupChrPr"
    | "barPr"
    | "boxPr"
    | "accPr"
    | "borderBoxPr"
    | "radPr"
    | "sSupPr"
    | "sSubPr"
    | "sSubSupPr"
    | "eqArrPr"
    | "dPr"
    | "phantPr"
    | "fPr"
    | "sPrePr"
    | "ctrlPr" => empty_box()
    // Unknown element — descend transparently.
    _ => layout_row(element.children, ctx)
  }
}

///|
/// §22.1.3.10 ST_Script — map a base ASCII letter / digit to its Unicode
/// Mathematical Alphanumeric Symbols code point for the OMML run script
/// `scr` (`double-struck` / `fraktur` / `script` / `sans-serif` /
/// `monospace`), honouring the Letterlike-Symbols exceptions (`ℝ`, `ℂ`,
/// `ℜ`, `ℬ`, …) that live outside the U+1D400 block.  Returns `None` for
/// `roman` / unknown scripts, non-alphanumeric characters, and the
/// digit-less fraktur / script alphabets.
fn math_alphabet_codepoint(ch : Char, scr : String) -> Int? {
  let c = ch.to_int()
  let upper = c >= 0x41 && c <= 0x5A
  let lower = c >= 0x61 && c <= 0x7A
  let digit = c >= 0x30 && c <= 0x39
  if !(upper || lower || digit) {
    return None
  }
  match scr {
    "double-struck" =>
      match ch {
        'C' => Some(0x2102)
        'H' => Some(0x210D)
        'N' => Some(0x2115)
        'P' => Some(0x2119)
        'Q' => Some(0x211A)
        'R' => Some(0x211D)
        'Z' => Some(0x2124)
        _ =>
          if upper {
            Some(0x1D538 + c - 0x41)
          } else if lower {
            Some(0x1D552 + c - 0x61)
          } else {
            Some(0x1D7D8 + c - 0x30)
          }
      }
    "fraktur" =>
      if digit {
        None
      } else {
        match ch {
          'C' => Some(0x212D)
          'H' => Some(0x210C)
          'I' => Some(0x2111)
          'R' => Some(0x211C)
          'Z' => Some(0x2128)
          _ =>
            if upper {
              Some(0x1D504 + c - 0x41)
            } else {
              Some(0x1D51E + c - 0x61)
            }
        }
      }
    "script" =>
      if digit {
        None
      } else {
        match ch {
          'B' => Some(0x212C)
          'E' => Some(0x2130)
          'F' => Some(0x2131)
          'H' => Some(0x210B)
          'I' => Some(0x2110)
          'L' => Some(0x2112)
          'M' => Some(0x2133)
          'R' => Some(0x211B)
          'e' => Some(0x212F)
          'g' => Some(0x210A)
          'o' => Some(0x2134)
          _ =>
            if upper {
              Some(0x1D49C + c - 0x41)
            } else {
              Some(0x1D4B6 + c - 0x61)
            }
        }
      }
    "sans-serif" =>
      if upper {
        Some(0x1D5A0 + c - 0x41)
      } else if lower {
        Some(0x1D5BA + c - 0x61)
      } else {
        Some(0x1D7E2 + c - 0x30)
      }
    "monospace" =>
      if upper {
        Some(0x1D670 + c - 0x41)
      } else if lower {
        Some(0x1D68A + c - 0x61)
      } else {
        Some(0x1D7F6 + c - 0x30)
      }
    _ => None
  }
}

///|
/// Apply the OMML run script `scr` to `text`, substituting each base
/// letter / digit with its Mathematical Alphanumeric Symbols form — but
/// ONLY when the active math face (`Noto Serif`, at the run weight) can
/// actually draw that code point.  When the face lacks the glyph the base
/// character is kept so its advance width stays correct (a missing glyph
/// would otherwise collapse to a zero-width box and overlap its
/// neighbours).  `roman` / empty scripts pass through unchanged.
fn apply_math_script(
  text : String,
  scr : String,
  bold : Bool,
  italic : Bool,
) -> String {
  if scr == "" || scr == "roman" {
    return text
  }
  let weight = if bold { 700 } else { 400 }
  let out = StringBuilder::new()
  for ch in text {
    let replacement = match math_alphabet_codepoint(ch, scr) {
      None => ch
      Some(cp) => {
        let renderable = (try? @glyph.font_has_glyph(
          cp,
          family="Noto Serif",
          weight~,
          italic~,
        )).unwrap_or(false)
        if renderable {
          cp.unsafe_to_char()
        } else {
          ch
        }
      }
    }
    out.write_char(replacement)
  }
  out.to_string()
}

///|
/// §22.1.2.87 r — render an OMML run.  The §22.1.2.94 `<m:scr>` and
/// §22.1.2.111 `<m:sty>` properties select the glyph styling; only
/// the bold / italic axes have an SVG `<text>` realisation, so the
/// script-alphabet variants degrade to plain glyphs.  A literal run
/// (`<m:nor>` or `<m:lit>`) is upright; a normal math run is italic.
fn layout_math_run(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut scr = ""
  let mut sty = ""
  let mut normal = false
  for child in element.children {
    match child {
      Element(c) =>
        if c.name.local_name == "rPr" {
          for pr in c.children {
            match pr {
              Element(p) =>
                match p.name.local_name {
                  "scr" => scr = read_val(p)
                  "sty" => sty = read_val(p)
                  // §22.1.2.74 nor — normal (upright) text run.
                  "nor" => normal = val_is_on(p, default_on=true)
                  _ => ()
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  // §22.1.2.111 sty defaults to italic for a math run; <m:nor>
  // forces upright.
  let style = if sty == "" { "i" } else { sty }
  let italic = !normal && (style == "i" || style == "bi")
  let bold = style == "b" || style == "bi"
  // §22.1.2.94 scr — the script alphabets (double-struck, fraktur, …)
  // are realised by remapping each base letter to its Mathematical
  // Alphanumeric Symbols code point (guarded by glyph availability in
  // `apply_math_script`), so `ℝ`, `ℂ`, `𝔄`, `𝒜` etc. render as their
  // distinct shapes instead of plain ASCII.
  let boxes : Array[MathBox] = []
  for child in element.children {
    match child {
      Element(c) =>
        if c.name.local_name == "t" {
          let shaped = apply_math_script(text_content(c), scr, bold, italic)
          boxes.push(text_box(shaped, ctx, italic~, bold~))
        }
      Text(t) | CData(t) => {
        let shaped = apply_math_script(t, scr, bold, italic)
        boxes.push(text_box(shaped, ctx, italic~, bold~))
      }
      _ => ()
    }
  }
  if boxes.length() == 0 {
    return empty_box()
  }
  hbox(boxes)
}

///|
/// §22.1.2.36 f — fraction.  `bar` (default) stacks numerator over
/// denominator with a rule between; `noBar` omits the rule;
/// `lin` lays the parts out inline around a slash; `skw` is a
/// skewed slash form.  Numerator and denominator shrink one script
/// level so a nested fraction stays legible.
fn layout_fraction(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut frac_type = "bar"
  let mut num_box = empty_box()
  let mut den_box = empty_box()
  let sub_ctx = { ..ctx, font_size_pt: ctx.font_size_pt * SCRIPT_SCALE }
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "fPr" =>
            for pr in c.children {
              match pr {
                Element(p) =>
                  if p.name.local_name == "type" {
                    let v = read_val(p)
                    if v != "" {
                      frac_type = v
                    }
                  }
                _ => ()
              }
            }
          "num" => num_box = layout_arg(c, sub_ctx)
          "den" => den_box = layout_arg(c, sub_ctx)
          _ => ()
        }
      _ => ()
    }
  }
  match frac_type {
    "lin" =>
      // Linear inline fraction: num / den on the baseline.
      hbox([num_box, text_box("/", ctx), den_box])
    "skw" =>
      // Skewed fraction: numerator raised, denominator lowered,
      // around a fraction slash.
      stack_skew(num_box, den_box, ctx)
    // "bar" (default) and "noBar" — a vertical stack; noBar drops
    // the rule line.
    _ => stack_fraction(num_box, den_box, ctx, with_bar=frac_type != "noBar")
  }
}

///|
/// Stack `num` over `den` centred on a shared vertical axis, with an
/// optional rule line between them.  The combined box's baseline is
/// placed on the rule (math-axis convention) so the fraction aligns
/// with surrounding operators.
fn stack_fraction(
  num : MathBox,
  den : MathBox,
  ctx : MathCtx,
  with_bar~ : Bool,
) -> MathBox {
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let gap = em * FRAC_GAP_EM
  let thickness = if with_bar { em * RULE_EM } else { 0.0 }
  let inner_width = num.width.max(den.width)
  let pad = em * 0.12
  let width = inner_width + pad * 2.0
  // Baseline sits at the rule centre.  Numerator above, denominator
  // below.
  let half_rule = thickness / 2.0
  let nodes : Array[@xml.Node] = []
  // Numerator: its baseline goes `gap + half_rule + num.descent`
  // above the fraction baseline.
  let num_dy = -(half_rule + gap + num.descent)
  let num_x = pad + (inner_width - num.width) / 2.0
  for n in shift(num, num_x, num_dy) {
    nodes.push(n)
  }
  // Denominator: its baseline goes `gap + half_rule + den.ascent`
  // below the fraction baseline.
  let den_dy = half_rule + gap + den.ascent
  let den_x = pad + (inner_width - den.width) / 2.0
  for n in shift(den, den_x, den_dy) {
    nodes.push(n)
  }
  if with_bar {
    let bar = rule_box(width, thickness, ctx)
    // rule_box draws above its baseline; place its baseline at
    // half_rule below the fraction axis so the rule straddles it.
    for n in shift(bar, 0.0, half_rule) {
      nodes.push(n)
    }
  }
  let ascent = half_rule + gap + num.descent + num.ascent
  let descent = half_rule + gap + den.ascent + den.descent
  { width, ascent, descent, nodes }
}

///|
/// Skewed fraction (`<m:type val="skw">`): numerator raised and
/// denominator lowered around a fraction slash (U+2044).
fn stack_skew(num : MathBox, den : MathBox, ctx : MathCtx) -> MathBox {
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let lift = em * 0.30
  let drop = em * 0.30
  let slash = text_box("\u{2044}", ctx)
  let nodes : Array[@xml.Node] = []
  let mut x = 0.0
  for n in shift(num, x, -lift) {
    nodes.push(n)
  }
  x = x + num.width
  for n in shift(slash, x, 0.0) {
    nodes.push(n)
  }
  x = x + slash.width
  for n in shift(den, x, drop) {
    nodes.push(n)
  }
  x = x + den.width
  {
    width: x,
    ascent: (num.ascent + lift).max(slash.ascent),
    descent: (den.descent + drop).max(slash.descent),
    nodes,
  }
}

///|
/// §22.1.2.86 rad — radical.  When `<m:degHide>` is set or `<m:deg>`
/// is empty the result is a square root; otherwise an nth root with
/// the degree drawn small at the upper-left of the radical sign.
fn layout_rad(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut deg_hide = false
  let mut deg_box : MathBox? = None
  let mut radicand = empty_box()
  let deg_ctx = { ..ctx, font_size_pt: ctx.font_size_pt * SCRIPT_SCALE * 0.85 }
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "radPr" =>
            for pr in c.children {
              match pr {
                Element(p) =>
                  if p.name.local_name == "degHide" {
                    deg_hide = val_is_on(p)
                  }
                _ => ()
              }
            }
          "deg" => {
            let b = layout_arg(c, deg_ctx)
            if b.width > 0.0 {
              deg_box = Some(b)
            }
          }
          "e" => radicand = layout_arg(c, ctx)
          _ => ()
        }
      _ => ()
    }
  }
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let thickness = em * RULE_EM
  let gap = em * 0.10
  // Clearance between the radicand and the overbar.
  let overbar_clear = gap + thickness
  let radicand_top = radicand.ascent + overbar_clear
  let radicand_bottom = radicand.descent
  // The radical sign is a check-mark stroke to the left of the
  // radicand, drawn as a <path>.  Its width scales with the em.
  let sign_width = em * 0.55
  let sign_top = -radicand_top
  let sign_bottom = radicand_bottom
  let nodes : Array[@xml.Node] = []
  // Radical sign path: starts at the lower-left dip, rises to the
  // radicand bottom, then to the overbar height, then the overbar
  // runs across the top of the radicand.
  let total_height = sign_bottom - sign_top
  let dip_x = sign_width * 0.28
  let dip_y = sign_top + total_height * 0.62
  let toe_x = sign_width * 0.08
  let toe_y = sign_top + total_height * 0.78
  let radicand_x = sign_width + gap
  let bar_end = radicand_x + radicand.width + gap
  let path_d = "M " +
    num(toe_x) +
    " " +
    num(toe_y) +
    " L " +
    num(dip_x) +
    " " +
    num(dip_y) +
    " L " +
    num(sign_width) +
    " " +
    num(sign_top) +
    " L " +
    num(bar_end) +
    " " +
    num(sign_top)
  nodes.push(
    @markup.elem_ns(
      "path",
      @markup.svg_ns,
      [
        mattr("d", path_d),
        mattr("fill", "none"),
        mattr("stroke", ctx.color),
        mattr("stroke-width", num(thickness)),
        mattr("stroke-linejoin", "miter"),
      ],
      [],
    ),
  )
  for n in shift(radicand, radicand_x, 0.0) {
    nodes.push(n)
  }
  let mut ascent = radicand_top
  let mut width = bar_end
  // §22.1.2.86 — nth-root degree drawn small above the radical's toe.
  match deg_box {
    Some(d) => {
      let deg_dy = -(radicand_top * 0.55 + d.descent)
      let deg_x = 0.0
      for n in shift(d, deg_x, deg_dy) {
        nodes.push(n)
      }
      let deg_top = -deg_dy + d.ascent
      if deg_top > ascent {
        ascent = deg_top
      }
      if d.width > sign_width {
        // A wide degree pushes the radicand right; re-shift would
        // be costly, so just widen the reported box.
        width = width.max(d.width + radicand.width + gap * 2.0)
      }
    }
    None => if deg_hide { () }
  }
  { width, ascent, descent: radicand_bottom, nodes }
}

///|
/// §22.1.2.112/.115/.113 — subscript / superscript / both.
///
/// The base is `<m:e>`; `<m:sub>` and `<m:sup>` are the scripts,
/// each rendered one script level smaller and shifted off the
/// baseline.  `sub` / `sup` flags select which slots participate.
fn layout_script(
  element : @xml.Element,
  ctx : MathCtx,
  sup~ : Bool,
  sub~ : Bool,
) -> MathBox {
  let sub_ctx = { ..ctx, font_size_pt: ctx.font_size_pt * SCRIPT_SCALE }
  let mut base = empty_box()
  let mut sub_box = empty_box()
  let mut sup_box = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "e" => base = layout_arg(c, ctx)
          "sub" => sub_box = layout_arg(c, sub_ctx)
          "sup" => sup_box = layout_arg(c, sub_ctx)
          _ => ()
        }
      _ => ()
    }
  }
  attach_scripts(base, sub_box, sup_box, ctx, sup~, sub~)
}

///|
/// Place `sub_box` / `sup_box` to the right of `base`, on top of one
/// another when both are present.  Shared by the script elements and
/// by `nary` (whose limits in subSup mode are scripts on the
/// operator).
fn attach_scripts(
  base : MathBox,
  sub_box : MathBox,
  sup_box : MathBox,
  ctx : MathCtx,
  sup~ : Bool,
  sub~ : Bool,
) -> MathBox {
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let sup_shift = em * SUP_SHIFT_EM
  let sub_shift = em * SUB_SHIFT_EM
  let nodes : Array[@xml.Node] = []
  for n in shift(base, 0.0, 0.0) {
    nodes.push(n)
  }
  let script_x = base.width
  let mut script_w = 0.0
  let mut ascent = base.ascent
  let mut descent = base.descent
  if sup && sup_box.width > 0.0 {
    // Superscript baseline lifted; its descent must clear the shift.
    for n in shift(sup_box, script_x, -sup_shift) {
      nodes.push(n)
    }
    let top = sup_shift + sup_box.ascent
    if top > ascent {
      ascent = top
    }
    if sup_box.width > script_w {
      script_w = sup_box.width
    }
  }
  if sub && sub_box.width > 0.0 {
    for n in shift(sub_box, script_x, sub_shift) {
      nodes.push(n)
    }
    let bot = sub_shift + sub_box.descent
    if bot > descent {
      descent = bot
    }
    if sub_box.width > script_w {
      script_w = sub_box.width
    }
  }
  { width: script_x + script_w, ascent, descent, nodes }
}

///|
/// §22.1.2.99 sPre — pre-script pair: subscript / superscript drawn
/// to the *left* of the base.
fn layout_pre_script(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let sub_ctx = { ..ctx, font_size_pt: ctx.font_size_pt * SCRIPT_SCALE }
  let mut base = empty_box()
  let mut sub_box = empty_box()
  let mut sup_box = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "e" => base = layout_arg(c, ctx)
          "sub" => sub_box = layout_arg(c, sub_ctx)
          "sup" => sup_box = layout_arg(c, sub_ctx)
          _ => ()
        }
      _ => ()
    }
  }
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let sup_shift = em * SUP_SHIFT_EM
  let sub_shift = em * SUB_SHIFT_EM
  let script_w = sub_box.width.max(sup_box.width)
  let nodes : Array[@xml.Node] = []
  let mut ascent = base.ascent
  let mut descent = base.descent
  if sup_box.width > 0.0 {
    for n in shift(sup_box, script_w - sup_box.width, -sup_shift) {
      nodes.push(n)
    }
    let top = sup_shift + sup_box.ascent
    if top > ascent {
      ascent = top
    }
  }
  if sub_box.width > 0.0 {
    for n in shift(sub_box, script_w - sub_box.width, sub_shift) {
      nodes.push(n)
    }
    let bot = sub_shift + sub_box.descent
    if bot > descent {
      descent = bot
    }
  }
  for n in shift(base, script_w, 0.0) {
    nodes.push(n)
  }
  { width: script_w + base.width, ascent, descent, nodes }
}

///|
/// §22.1.2.79 nary — n-ary operator (sum / product / integral).
/// The operator glyph carries the `<m:sub>` / `<m:sup>` bounds; with
/// `limLoc="undOvr"` (default) they sit under / over the operator,
/// with `limLoc="subSup"` they become scripts on it.  `<m:subHide>`
/// / `<m:supHide>` drop a bound.
fn layout_nary(element : @xml.Element, ctx : MathCtx) -> MathBox {
  // U+2211 N-ARY SUMMATION — spec default operator glyph.
  let mut chr = "\u{2211}"
  let mut sub_hide = false
  let mut sup_hide = false
  let mut lim_loc = "undOvr"
  let sub_ctx = { ..ctx, font_size_pt: ctx.font_size_pt * SCRIPT_SCALE }
  let mut sub_box = empty_box()
  let mut sup_box = empty_box()
  let mut e_box = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "naryPr" =>
            for pr in c.children {
              match pr {
                Element(p) =>
                  match p.name.local_name {
                    "chr" => {
                      let v = read_val(p)
                      if v != "" {
                        chr = v
                      }
                    }
                    "subHide" => sub_hide = val_is_on(p)
                    "supHide" => sup_hide = val_is_on(p)
                    "limLoc" => {
                      let v = read_val(p)
                      if v != "" {
                        lim_loc = v
                      }
                    }
                    _ => ()
                  }
                _ => ()
              }
            }
          "sub" => sub_box = layout_arg(c, sub_ctx)
          "sup" => sup_box = layout_arg(c, sub_ctx)
          "e" => e_box = layout_arg(c, ctx)
          _ => ()
        }
      _ => ()
    }
  }
  // The operator glyph is enlarged: n-ary operators print large.
  let op_ctx = { ..ctx, font_size_pt: ctx.font_size_pt * 1.6 }
  let op = text_box(chr, op_ctx)
  let used_sub = if sub_hide { empty_box() } else { sub_box }
  let used_sup = if sup_hide { empty_box() } else { sup_box }
  let operator = if lim_loc == "subSup" {
    attach_scripts(op, used_sub, used_sup, ctx, sup=true, sub=true)
  } else {
    stack_limits(op, used_sup, used_sub, ctx)
  }
  let pad = ctx.font_size_pt * @glyph.pt_to_px * OP_PAD_EM
  hbox([operator, e_box], gap=pad)
}

///|
/// Stack `over` above and `under` below `base`, centred — the
/// under/over limit layout shared by `nary` (undOvr), `limUpp`,
/// `limLow`, `groupChr`, `bar`, and `acc`.
fn stack_limits(
  base : MathBox,
  over : MathBox,
  under : MathBox,
  ctx : MathCtx,
) -> MathBox {
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let gap = em * 0.10
  let width = base.width.max(over.width.max(under.width))
  let nodes : Array[@xml.Node] = []
  for n in shift(base, (width - base.width) / 2.0, 0.0) {
    nodes.push(n)
  }
  let mut ascent = base.ascent
  let mut descent = base.descent
  if over.width > 0.0 {
    let dy = -(base.ascent + gap + over.descent)
    for n in shift(over, (width - over.width) / 2.0, dy) {
      nodes.push(n)
    }
    ascent = base.ascent + gap + over.descent + over.ascent
  }
  if under.width > 0.0 {
    let dy = base.descent + gap + under.ascent
    for n in shift(under, (width - under.width) / 2.0, dy) {
      nodes.push(n)
    }
    descent = base.descent + gap + under.ascent + under.descent
  }
  { width, ascent, descent, nodes }
}

///|
/// §22.1.2.72 limUpp / §22.1.2.71 limLow — a limit drawn over (`upper`)
/// or under the base expression.  The limit text shrinks one script
/// level.
fn layout_limit(
  element : @xml.Element,
  ctx : MathCtx,
  upper~ : Bool,
) -> MathBox {
  let sub_ctx = { ..ctx, font_size_pt: ctx.font_size_pt * SCRIPT_SCALE }
  let mut base = empty_box()
  let mut lim = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "e" => base = layout_arg(c, ctx)
          "lim" => lim = layout_arg(c, sub_ctx)
          _ => ()
        }
      _ => ()
    }
  }
  if upper {
    stack_limits(base, lim, empty_box(), ctx)
  } else {
    stack_limits(base, empty_box(), lim, ctx)
  }
}

///|
/// §22.1.2.42 func — function application: the function name
/// followed by its argument with a thin space between.
fn layout_func(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut f_name = empty_box()
  let mut arg = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "fName" => f_name = layout_arg(c, ctx)
          "e" => arg = layout_arg(c, ctx)
          _ => ()
        }
      _ => ()
    }
  }
  let gap = ctx.font_size_pt * @glyph.pt_to_px * 0.06
  hbox([f_name, arg], gap~)
}

///|
/// §22.1.2.31 d — delimiter.  `<m:dPr>` overrides the bracket /
/// separator glyphs; the defaults are `(`, `)`, `|`.  A present
/// char element with an empty value means "no glyph".  Each `<m:e>`
/// is one delimited argument; the brackets stretch to the content
/// height.
fn layout_delimiter(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut beg = "("
  let mut end = ")"
  let mut sep = "|"
  let args : Array[MathBox] = []
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "dPr" =>
            for pr in c.children {
              match pr {
                Element(p) => {
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
          "e" => args.push(layout_arg(c, ctx))
          _ => ()
        }
      _ => ()
    }
  }
  // Content extent: the tallest argument decides the bracket height.
  let mut content_ascent = 0.0
  let mut content_descent = 0.0
  for a in args {
    if a.ascent > content_ascent {
      content_ascent = a.ascent
    }
    if a.descent > content_descent {
      content_descent = a.descent
    }
  }
  if content_ascent == 0.0 && content_descent == 0.0 {
    let em = ctx.font_size_pt * @glyph.pt_to_px
    content_ascent = em * 0.7
    content_descent = em * 0.2
  }
  let pieces : Array[MathBox] = []
  if beg != "" {
    pieces.push(bracket_box(beg, content_ascent, content_descent, ctx))
  }
  for i, a in args {
    if i > 0 && sep != "" {
      pieces.push(bracket_box(sep, content_ascent, content_descent, ctx))
    }
    pieces.push(a)
  }
  if end != "" {
    pieces.push(bracket_box(end, content_ascent, content_descent, ctx))
  }
  if pieces.length() == 0 {
    return empty_box()
  }
  hbox(pieces)
}

///|
/// A stretched bracket / separator glyph sized to span
/// `[−ascent, +descent]` around the baseline.  The glyph is scaled
/// vertically by setting a font size matched to the target height;
/// a non-uniform `scale` transform would distort the stroke, so the
/// width is kept proportionate.
fn bracket_box(
  glyph : String,
  ascent : Double,
  descent : Double,
  ctx : MathCtx,
) -> MathBox {
  let target = ascent + descent
  let natural_em = ctx.font_size_pt * @glyph.pt_to_px
  // Scale the glyph up if the content is taller than one em.
  let scale = 1.0.max(target / natural_em)
  let glyph_ctx = { ..ctx, font_size_pt: ctx.font_size_pt * scale }
  let b = text_box(glyph, glyph_ctx)
  // Re-centre the scaled glyph on the content's vertical midpoint:
  // the midpoint of [−ascent, +descent] is (descent − ascent)/2.
  let glyph_mid = (b.descent - b.ascent) / 2.0
  let content_mid = (descent - ascent) / 2.0
  let dy = content_mid - glyph_mid
  {
    width: b.width,
    ascent: b.ascent - dy,
    descent: b.descent + dy,
    nodes: shift(b, 0.0, dy),
  }
}

///|
/// §22.1.2.81 phant — phantom.  Unless `<m:show>` is set the content
/// is invisible but still reserves its box; `<m:zeroWid>` /
/// `<m:zeroAsc>` / `<m:zeroDesc>` zero individual dimensions.
fn layout_phant(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut show = false
  let mut zero_wid = false
  let mut zero_asc = false
  let mut zero_desc = false
  let mut e_box = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "phantPr" =>
            for pr in c.children {
              match pr {
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
          "e" => e_box = layout_arg(c, ctx)
          _ => ()
        }
      _ => ()
    }
  }
  let width = if zero_wid { 0.0 } else { e_box.width }
  let ascent = if zero_asc { 0.0 } else { e_box.ascent }
  let descent = if zero_desc { 0.0 } else { e_box.descent }
  // Default phantom — reserve the box, paint nothing.
  let nodes : Array[@xml.Node] = if show { e_box.nodes } else { [] }
  { width, ascent, descent, nodes }
}

///|
/// §22.1.2.78 m — matrix.  Each `<m:mr>` is a row of `<m:e>` cells;
/// cells are laid out in a grid with even row / column gaps and the
/// whole matrix centred on the baseline.
fn layout_matrix(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let rows : Array[Array[MathBox]] = []
  for child in element.children {
    match child {
      Element(c) =>
        if c.name.local_name == "mr" {
          let cells : Array[MathBox] = []
          for rc in c.children {
            match rc {
              Element(e) =>
                if e.name.local_name == "e" {
                  cells.push(layout_arg(e, ctx))
                }
              _ => ()
            }
          }
          rows.push(cells)
        }
      _ => ()
    }
  }
  if rows.length() == 0 {
    return empty_box()
  }
  layout_grid(rows, ctx)
}

///|
/// §22.1.2.66 eqArr — equation array: a single-column stack of
/// `<m:e>` rows.
fn layout_eq_arr(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let rows : Array[Array[MathBox]] = []
  for child in element.children {
    match child {
      Element(c) =>
        if c.name.local_name == "e" {
          rows.push([layout_arg(c, ctx)])
        }
      _ => ()
    }
  }
  if rows.length() == 0 {
    return empty_box()
  }
  layout_grid(rows, ctx)
}

///|
/// Lay out a grid of cell boxes: per-column widths are the column
/// maxima, per-row heights the row maxima; the grid is centred
/// vertically on the baseline.
fn layout_grid(rows : Array[Array[MathBox]], ctx : MathCtx) -> MathBox {
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let col_gap = em * 0.45
  let row_gap = em * 0.30
  let mut col_count = 0
  for r in rows {
    if r.length() > col_count {
      col_count = r.length()
    }
  }
  // Per-column width.
  let col_w : Array[Double] = []
  for _ in 0..<col_count {
    col_w.push(0.0)
  }
  for r in rows {
    for ci, cell in r {
      if cell.width > col_w[ci] {
        col_w[ci] = cell.width
      }
    }
  }
  // Per-row ascent / descent.
  let row_asc : Array[Double] = []
  let row_desc : Array[Double] = []
  for r in rows {
    let mut a = 0.0
    let mut d = 0.0
    for cell in r {
      if cell.ascent > a {
        a = cell.ascent
      }
      if cell.descent > d {
        d = cell.descent
      }
    }
    row_asc.push(a)
    row_desc.push(d)
  }
  // Total grid height.
  let mut total_h = 0.0
  for i in 0..<rows.length() {
    if i > 0 {
      total_h = total_h + row_gap
    }
    total_h = total_h + row_asc[i] + row_desc[i]
  }
  let mut total_w = 0.0
  for ci in 0..<col_count {
    if ci > 0 {
      total_w = total_w + col_gap
    }
    total_w = total_w + col_w[ci]
  }
  // Centre the grid on the baseline.
  let grid_ascent = total_h / 2.0
  let nodes : Array[@xml.Node] = []
  let mut y = -grid_ascent
  for ri in 0..<rows.length() {
    let row = rows[ri]
    let row_baseline = y + row_asc[ri]
    let mut x = 0.0
    for ci in 0..<col_count {
      if ci < row.length() {
        let cell = row[ci]
        // Centre each cell within its column.
        let cell_x = x + (col_w[ci] - cell.width) / 2.0
        for n in shift(cell, cell_x, row_baseline) {
          nodes.push(n)
        }
      }
      x = x + col_w[ci] + col_gap
    }
    y = y + row_asc[ri] + row_desc[ri] + row_gap
  }
  { width: total_w, ascent: grid_ascent, descent: total_h - grid_ascent, nodes }
}

///|
/// §22.1.2.51 groupChr — group character (over/underbrace).  The
/// glyph (default U+23DE TOP CURLY BRACKET) is drawn above
/// (`pos="top"`) or below (`pos="bot"`) the base, stretched to the
/// base width.
fn layout_group_chr(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut pos = "top"
  let mut chr = ""
  let mut base = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "groupChrPr" =>
            for pr in c.children {
              match pr {
                Element(p) =>
                  match p.name.local_name {
                    "pos" => {
                      let v = read_val(p)
                      if v != "" {
                        pos = v
                      }
                    }
                    "chr" => {
                      let v = read_val(p)
                      if v != "" {
                        chr = v
                      }
                    }
                    _ => ()
                  }
                _ => ()
              }
            }
          "e" => base = layout_arg(c, ctx)
          _ => ()
        }
      _ => ()
    }
  }
  // U+23DE TOP CURLY BRACKET — spec-neutral default.
  let glyph = if chr != "" { chr } else { "\u{23DE}" }
  let group = stretch_glyph(glyph, base.width, ctx)
  if pos == "bot" {
    stack_limits(base, empty_box(), group, ctx)
  } else {
    stack_limits(base, group, empty_box(), ctx)
  }
}

///|
/// §22.1.2.8 bar — accent bar above (`pos="top"`, default) or below
/// (`pos="bot"`) the base.  Drawn as a rule rather than a combining
/// glyph so it spans the full base width exactly.
fn layout_bar(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut pos = "top"
  let mut base = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "barPr" =>
            for pr in c.children {
              match pr {
                Element(p) =>
                  if p.name.local_name == "pos" {
                    let v = read_val(p)
                    if v != "" {
                      pos = v
                    }
                  }
                _ => ()
              }
            }
          "e" => base = layout_arg(c, ctx)
          _ => ()
        }
      _ => ()
    }
  }
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let thickness = em * RULE_EM
  let gap = em * 0.08
  let nodes : Array[@xml.Node] = []
  for n in base.nodes {
    nodes.push(n)
  }
  if pos == "bot" {
    let bar_y = base.descent + gap + thickness
    let bar = rule_box(base.width, thickness, ctx)
    for n in shift(bar, 0.0, bar_y) {
      nodes.push(n)
    }
    { width: base.width, ascent: base.ascent, descent: bar_y, nodes }
  } else {
    let bar_y = -(base.ascent + gap)
    let bar = rule_box(base.width, thickness, ctx)
    for n in shift(bar, 0.0, bar_y) {
      nodes.push(n)
    }
    {
      width: base.width,
      ascent: base.ascent + gap + thickness,
      descent: base.descent,
      nodes,
    }
  }
}

///|
/// §22.1.2.4 acc — accented expression.  The accent glyph (default
/// U+0302 COMBINING CIRCUMFLEX ACCENT) is drawn over the base,
/// centred.
fn layout_acc(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut chr = ""
  let mut base = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "accPr" =>
            for pr in c.children {
              match pr {
                Element(p) =>
                  if p.name.local_name == "chr" {
                    let v = read_val(p)
                    if v != "" {
                      chr = v
                    }
                  }
                _ => ()
              }
            }
          "e" => base = layout_arg(c, ctx)
          _ => ()
        }
      _ => ()
    }
  }
  // U+0302 COMBINING CIRCUMFLEX ACCENT renders inconsistently on its
  // own; substitute the spacing circumflex U+02C6 when that is the
  // (default) accent so the glyph is reliably visible.
  let glyph = if chr == "" || chr == "\u{0302}" { "\u{02C6}" } else { chr }
  let acc_box = text_box(glyph, ctx)
  stack_limits(base, acc_box, empty_box(), ctx)
}

///|
/// §22.1.2.20 box — a grouping container that draws no border.
/// Transparent for layout: its `<m:e>` argument is rendered as a row.
fn layout_box(element : @xml.Element, ctx : MathCtx) -> MathBox {
  for child in element.children {
    match child {
      Element(c) => if c.name.local_name == "e" { return layout_arg(c, ctx) }
      _ => ()
    }
  }
  empty_box()
}

///|
/// §22.1.2.12 borderBox — a bordered box.  The
/// `hide*` toggles suppress individual edges and the `strike*`
/// toggles add strike lines through the content.
fn layout_border_box(element : @xml.Element, ctx : MathCtx) -> MathBox {
  let mut hide_top = false
  let mut hide_bot = false
  let mut hide_left = false
  let mut hide_right = false
  let mut strike_h = false
  let mut strike_v = false
  let mut strike_bltr = false
  let mut strike_tlbr = false
  let mut content = empty_box()
  for child in element.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "borderBoxPr" =>
            for pr in c.children {
              match pr {
                Element(p) =>
                  // CT_OnOff toggles default ON when present.
                  match p.name.local_name {
                    "hideTop" => hide_top = val_is_on(p, default_on=true)
                    "hideBot" => hide_bot = val_is_on(p, default_on=true)
                    "hideLeft" => hide_left = val_is_on(p, default_on=true)
                    "hideRight" => hide_right = val_is_on(p, default_on=true)
                    "strikeH" => strike_h = val_is_on(p, default_on=true)
                    "strikeV" => strike_v = val_is_on(p, default_on=true)
                    "strikeBLTR" => strike_bltr = val_is_on(p, default_on=true)
                    "strikeTLBR" => strike_tlbr = val_is_on(p, default_on=true)
                    _ => ()
                  }
                _ => ()
              }
            }
          "e" => content = layout_arg(c, ctx)
          _ => ()
        }
      _ => ()
    }
  }
  let em = ctx.font_size_pt * @glyph.pt_to_px
  let pad = em * 0.16
  let thickness = em * RULE_EM
  let inner_w = content.width
  let box_w = inner_w + pad * 2.0
  let top = -(content.ascent + pad)
  let bot = content.descent + pad
  let nodes : Array[@xml.Node] = []
  for n in shift(content, pad, 0.0) {
    nodes.push(n)
  }
  let edge = fn(x1 : Double, y1 : Double, x2 : Double, y2 : Double) -> Unit {
    nodes.push(
      @markup.elem_ns(
        "line",
        @markup.svg_ns,
        [
          mattr("x1", num(x1)),
          mattr("y1", num(y1)),
          mattr("x2", num(x2)),
          mattr("y2", num(y2)),
          mattr("stroke", ctx.color),
          mattr("stroke-width", num(thickness)),
        ],
        [],
      ),
    )
  }
  if !hide_top {
    edge(0.0, top, box_w, top)
  }
  if !hide_bot {
    edge(0.0, bot, box_w, bot)
  }
  if !hide_left {
    edge(0.0, top, 0.0, bot)
  }
  if !hide_right {
    edge(box_w, top, box_w, bot)
  }
  if strike_h {
    edge(0.0, (top + bot) / 2.0, box_w, (top + bot) / 2.0)
  }
  if strike_v {
    edge(box_w / 2.0, top, box_w / 2.0, bot)
  }
  if strike_bltr {
    edge(0.0, bot, box_w, top)
  }
  if strike_tlbr {
    edge(0.0, top, box_w, bot)
  }
  {
    width: box_w,
    ascent: content.ascent + pad,
    descent: content.descent + pad,
    nodes,
  }
}

///|
/// Draw `glyph` stretched horizontally to span `target_width`.  The
/// glyph is rendered once and scaled along x via a transform; a
/// curly brace / arrow keeps its drawn thickness because only the
/// x-axis is scaled.
fn stretch_glyph(
  glyph : String,
  target_width : Double,
  ctx : MathCtx,
) -> MathBox {
  let b = text_box(glyph, ctx)
  if b.width <= 0.0 || target_width <= 0.0 {
    return b
  }
  let scale = target_width / b.width
  let scaled = @markup.elem_ns(
    "g",
    @markup.svg_ns,
    [mattr("transform", "scale(" + num(scale) + ",1)")],
    b.nodes,
  )
  { width: target_width, ascent: b.ascent, descent: b.descent, nodes: [scaled] }
}

// ---------------------------------------------------------------
// Attribute / text helpers.
// ---------------------------------------------------------------

///|
/// The package identifier.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/office_math/viewer"
}

///|
/// Build an SVG attribute (name + value); the value is escaped by
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
fn val_is_on(el : @xml.Element, default_on? : Bool = false) -> Bool {
  try @domain.CT_OnOff::new(el) catch {
    _ => false
  } noraise {
    value =>
      match value.value {
        Some(v) => v
        None => default_on
      }
  }
}

///|
/// Format a Double for an SVG coordinate / length attribute: integer
/// when whole, otherwise rounded to three decimals with trailing
/// zeros trimmed.  Pure ASCII.
fn num(value : Double) -> String {
  if value == 0.0 {
    return "0"
  }
  let scaled = (value * 1000.0).round()
  let int_part = (scaled / 1000.0).to_int()
  let frac_scaled = (scaled - int_part.to_double() * 1000.0).to_int()
  let abs_frac = if frac_scaled < 0 { -frac_scaled } else { frac_scaled }
  if abs_frac == 0 {
    return int_part.to_string()
  }
  // Three-digit fractional part with leading zeros, trailing zeros
  // trimmed.
  let mut frac = abs_frac.to_string()
  while frac.length() < 3 {
    frac = "0" + frac
  }
  let mut end = frac.length()
  while end > 0 && frac.code_unit_at(end - 1) == '0' {
    end = end - 1
  }
  let trimmed = frac[:end].to_owned()
  let sign = if value < 0.0 && int_part == 0 { "-" } else { "" }
  if trimmed == "" {
    sign + int_part.to_string()
  } else {
    sign + int_part.to_string() + "." + trimmed
  }
}
