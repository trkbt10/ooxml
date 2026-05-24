// Office Math Markup Language advanced fixtures — math constructs
// not yet covered (or not covered exhaustively) by
// `fixtures_omml.mbt`: nested fractions, mixed delimiters, vectors
// via accent, sum with both subscript+superscript, varied-dimension
// matrices, Greek-letter expressions, statistics notation, set
// notation, limits, series, polynomial layouts, equation arrays and
// a complex composite expression.
//
// Each fixture wraps math content in `<w:p><m:oMath>…</m:oMath></w:p>`
// inside the docx body.  Top-level helpers `m_t`, `m_r`, `m_arg`,
// `m_e` come from `fixtures_helpers.mbt`.

///|
/// Build an `m:`-prefixed attribute for OMML property values.  Local
/// duplicate of `m_attr` from `fixtures_omml.mbt` — kept independent
/// so each per-category file remains editable without cross-file
/// helper dependencies (the parent file's helpers are private).
fn ma_attr(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("m"), local_name: name, ns: Some(NS_M) }, value }
}

///|
/// `<m:chr m:val="…"/>` — operator character (file-local copy).
fn ma_chr(c : String) -> @xml.Element {
  xe(NS_M, "chr", [ma_attr("val", c)], [])
}

///|
/// Wrap a math expression in a docx body — `<w:p><m:oMath>…</m:oMath></w:p>`.
fn ma_body(inner : @xml.Element) -> @xml.Element {
  xe(NS_W, "body", [], [
    Element(
      xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(inner)]))]),
    ),
  ])
}

///|
/// Wrap a list of children directly under `<m:oMath>`.
fn ma_body_many(children : Array[@xml.Node]) -> @xml.Element {
  xe(NS_W, "body", [], [
    Element(xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], children))])),
  ])
}

///|
/// `<m:f>` fraction with explicit bar type ("" = default bar, "noBar",
/// "skw", "lin").
fn ma_frac(
  bar_type : String,
  num : @xml.Element,
  den : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = if bar_type == "" {
    []
  } else {
    [Element(xe(NS_M, "type", [ma_attr("val", bar_type)], []))]
  }
  xe(NS_M, "f", [], [
    Element(xe(NS_M, "fPr", [], pr_kids)),
    Element(m_arg("num", num)),
    Element(m_arg("den", den)),
  ])
}

///|
/// Delimiter `<m:d>` with explicit begin / end characters.  Empty
/// strings keep the default parenthesis.
fn ma_delim(beg : String, end : String, inner : @xml.Element) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if beg != "" {
    pr_kids.push(Element(xe(NS_M, "begChr", [ma_attr("val", beg)], [])))
  }
  if end != "" {
    pr_kids.push(Element(xe(NS_M, "endChr", [ma_attr("val", end)], [])))
  }
  let kids : Array[@xml.Node] = [Element(xe(NS_M, "dPr", [], pr_kids))]
  kids.push(Element(m_arg("e", inner)))
  xe(NS_M, "d", [], kids)
}

///|
/// Build a `<m:sSubSup>` subscript+superscript-on-base group.
fn ma_subsup(
  e : @xml.Element,
  sub : @xml.Element,
  sup : @xml.Element,
) -> @xml.Element {
  xe(NS_M, "sSubSup", [], [
    Element(m_arg("e", e)),
    Element(m_arg("sub", sub)),
    Element(m_arg("sup", sup)),
  ])
}

///|
/// `<m:sSub>` — base with subscript.
fn ma_sub(e : @xml.Element, sub : @xml.Element) -> @xml.Element {
  xe(NS_M, "sSub", [], [Element(m_arg("e", e)), Element(m_arg("sub", sub))])
}

///|
/// `<m:sSup>` — base with superscript.
fn ma_sup(e : @xml.Element, sup : @xml.Element) -> @xml.Element {
  xe(NS_M, "sSup", [], [Element(m_arg("e", e)), Element(m_arg("sup", sup))])
}

///|
/// n-ary operator `<m:nary>` with character, limit-location and
/// sub/sup/e bodies (sub or sup may be absent — pass empty elements).
fn ma_nary(
  op : String,
  lim_loc : String,
  sub : @xml.Element?,
  sup : @xml.Element?,
  e : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if op != "" {
    pr_kids.push(Element(ma_chr(op)))
  }
  if lim_loc != "" {
    pr_kids.push(Element(xe(NS_M, "limLoc", [ma_attr("val", lim_loc)], [])))
  }
  let kids : Array[@xml.Node] = [Element(xe(NS_M, "naryPr", [], pr_kids))]
  match sub {
    Some(s) => kids.push(Element(m_arg("sub", s)))
    None => kids.push(Element(xe(NS_M, "sub", [], [])))
  }
  match sup {
    Some(s) => kids.push(Element(m_arg("sup", s)))
    None => kids.push(Element(xe(NS_M, "sup", [], [])))
  }
  kids.push(Element(m_arg("e", e)))
  xe(NS_M, "nary", [], kids)
}

///|
/// Build an `<m:acc>` accent (e.g. arrow for vectors, bar for
/// mean, dot, hat).  `chr` is the accent character.
fn ma_acc(chr : String, e : @xml.Element) -> @xml.Element {
  xe(NS_M, "acc", [], [
    Element(xe(NS_M, "accPr", [], [Element(ma_chr(chr))])),
    Element(m_arg("e", e)),
  ])
}

///|
/// `<m:bar>` overline / underline accent.  `pos` is "top" (default)
/// or "bot".
fn ma_bar(pos : String, e : @xml.Element) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = if pos == "" {
    []
  } else {
    [Element(xe(NS_M, "pos", [ma_attr("val", pos)], []))]
  }
  xe(NS_M, "bar", [], [
    Element(xe(NS_M, "barPr", [], pr_kids)),
    Element(m_arg("e", e)),
  ])
}

///|
/// `<m:limLow>` — "lower limit" group (`lim_{x→a}` style; the limit
/// expression sits BELOW the base).
fn ma_lim_low(base : @xml.Element, lim : @xml.Element) -> @xml.Element {
  xe(NS_M, "limLow", [], [Element(m_arg("e", base)), Element(m_arg("lim", lim))])
}

///|
/// Build an `<m:mr>` matrix-row from an array of cell texts.
fn ma_mrow_text(cells : Array[String]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cells {
    kids.push(Element(m_e(c)))
  }
  xe(NS_M, "mr", [], kids)
}

///|
/// OMML advanced fixtures — 16 visual cases covering math constructs
/// not yet exercised by `extras_omml()`.
fn extras_omml_advanced(cases : Array[VisualCase]) -> Unit {
  // 1. Nested fraction — fraction inside numerator: (a/b) / c.
  cases.push({
    id: "math-nested-frac-num",
    format: "docx",
    category: "math",
    content: ma_body(ma_frac("", ma_frac("", m_r("a"), m_r("b")), m_r("c"))),
  })

  // 2. Nested fraction — fraction inside denominator: a / (b/c).
  cases.push({
    id: "math-nested-frac-den",
    format: "docx",
    category: "math",
    content: ma_body(ma_frac("", m_r("a"), ma_frac("", m_r("b"), m_r("c")))),
  })

  // 3. Fraction with subscript in numerator: a_n / b.
  cases.push({
    id: "math-frac-sub-num",
    format: "docx",
    category: "math",
    content: ma_body(ma_frac("", ma_sub(m_r("a"), m_r("n")), m_r("b"))),
  })

  // 4. Mixed delimiters in one expression — [(a + b) / c].
  // Outer square brackets wrap a fraction whose numerator is
  // parenthesised.
  cases.push({
    id: "math-mixed-delim",
    format: "docx",
    category: "math",
    content: ma_body(
      ma_delim(
        "[",
        "]",
        ma_frac("", ma_delim("(", ")", m_r("a + b")), m_r("c")),
      ),
    ),
  })

  // 5. Vector notation — `\vec{a} = (a₁, a₂, a₃)` using <m:acc>
  // with an arrow accent and a parenthesised tuple.
  cases.push({
    id: "math-vector-tuple",
    format: "docx",
    category: "math",
    content: ma_body_many([
      Element(ma_acc("⃗", m_r("a"))),
      Element(m_r(" = ")),
      Element(
        ma_delim(
          "(",
          ")",
          xe(NS_M, "e", [], [
            Element(ma_sub(m_r("a"), m_r("1"))),
            Element(m_r(", ")),
            Element(ma_sub(m_r("a"), m_r("2"))),
            Element(m_r(", ")),
            Element(ma_sub(m_r("a"), m_r("3"))),
          ]),
        ),
      ),
    ]),
  })

  // 6. Σ with BOTH subscript and superscript at the base of the
  // operator (limLoc subSup) — ∑_{i=1}^{n} a_i.  Exercises the
  // explicit subSup-on-nary path with a subscripted summand.
  cases.push({
    id: "math-sigma-subsup-base",
    format: "docx",
    category: "math",
    content: ma_body(
      ma_nary(
        "∑",
        "subSup",
        Some(m_r("i=1")),
        Some(m_r("n")),
        ma_sub(m_r("a"), m_r("i")),
      ),
    ),
  })

  // 7. 1×3 row matrix — (a b c) — single-row matrix shape.
  let row_matrix = xe(NS_M, "m", [], [
    Element(xe(NS_M, "mPr", [], [])),
    Element(ma_mrow_text(["a", "b", "c"])),
  ])
  cases.push({
    id: "math-matrix-1x3",
    format: "docx",
    category: "math",
    content: ma_body(ma_delim("(", ")", row_matrix)),
  })

  // 8. 3×1 column matrix — (x; y; z) — single-column shape.
  let col_matrix = xe(NS_M, "m", [], [
    Element(xe(NS_M, "mPr", [], [])),
    Element(ma_mrow_text(["x"])),
    Element(ma_mrow_text(["y"])),
    Element(ma_mrow_text(["z"])),
  ])
  cases.push({
    id: "math-matrix-3x1",
    format: "docx",
    category: "math",
    content: ma_body(ma_delim("(", ")", col_matrix)),
  })

  // 9. 4×4 numeric matrix — larger square matrix.
  let m4 = xe(NS_M, "m", [], [
    Element(xe(NS_M, "mPr", [], [])),
    Element(ma_mrow_text(["1", "2", "3", "4"])),
    Element(ma_mrow_text(["5", "6", "7", "8"])),
    Element(ma_mrow_text(["9", "10", "11", "12"])),
    Element(ma_mrow_text(["13", "14", "15", "16"])),
  ])
  cases.push({
    id: "math-matrix-4x4",
    format: "docx",
    category: "math",
    content: ma_body(ma_delim("[", "]", m4)),
  })

  // 10. Partial derivative — ∂f/∂x via a fraction of Greek
  // partial-symbol runs.
  cases.push({
    id: "math-partial-derivative",
    format: "docx",
    category: "math",
    content: ma_body(ma_frac("", m_r("∂f"), m_r("∂x"))),
  })

  // 11. Divergence — ∇·F using nabla + dot + bold F.
  cases.push({
    id: "math-divergence",
    format: "docx",
    category: "math",
    content: ma_body(m_r("∇ · F")),
  })

  // 12. Statistics — x̄ (mean) = μ, with σ² (variance) on a
  // second term.  Exercises <m:bar> on a single-character base and
  // adjacent Greek-letter runs.
  cases.push({
    id: "math-stats-mean-variance",
    format: "docx",
    category: "math",
    content: ma_body_many([
      Element(ma_bar("", m_r("x"))),
      Element(m_r(" = μ, ")),
      Element(ma_sup(m_r("σ"), m_r("2"))),
      Element(m_r(" = Var")),
    ]),
  })

  // 13. Set-builder — {x : x > 0}.  Curly delimiters with a colon
  // separator condition inside.
  cases.push({
    id: "math-set-builder",
    format: "docx",
    category: "math",
    content: ma_body(ma_delim("{", "}", m_r("x : x > 0"))),
  })

  // 14. Set operations — A ∩ B = ∅, then A ∪ B.  Plain runs but
  // with the set-theory operator characters that we have not yet
  // round-tripped through the renderer.
  cases.push({
    id: "math-set-operations",
    format: "docx",
    category: "math",
    content: ma_body_many([
      Element(m_r("A ∩ B = ∅, ")),
      Element(m_r("A ∪ B")),
    ]),
  })

  // 15. Limit — lim_{x→0} sin(x)/x = 1 using <m:limLow>.  Same
  // shape as the existing math-limit-quotient but with explicit
  // helper usage and no nor wrapper on sin (treated as plain text)
  // to exercise the alternate path.
  cases.push({
    id: "math-limit-sinx-x",
    format: "docx",
    category: "math",
    content: ma_body_many([
      Element(ma_lim_low(m_r("lim"), m_r("x→0"))),
      Element(
        ma_frac("", xe(NS_M, "e", [], [Element(m_r("sin(x)"))]), m_r("x")),
      ),
      Element(m_r(" = 1")),
    ]),
  })

  // 16. Power series — Σ a_n x^n with the summation operator
  // followed by a subscripted-coefficient × superscripted-variable
  // pair.
  cases.push({
    id: "math-power-series",
    format: "docx",
    category: "math",
    content: ma_body(
      ma_nary(
        "∑",
        "subSup",
        Some(m_r("n=0")),
        Some(m_r("∞")),
        xe(NS_M, "e", [], [
          Element(ma_sub(m_r("a"), m_r("n"))),
          Element(ma_sup(m_r("x"), m_r("n"))),
        ]),
      ),
    ),
  })

  // 17. Long polynomial — ax² + bx + c = 0.  Standard quadratic
  // coefficients with mixed superscripts.
  cases.push({
    id: "math-quadratic-poly",
    format: "docx",
    category: "math",
    content: ma_body_many([
      Element(ma_sup(m_r("ax"), m_r("2"))),
      Element(m_r(" + bx + c = 0")),
    ]),
  })

  // 18. Multi-equation equation array — a 4-line aligned block.
  let multi_eq = xe(NS_M, "eqArr", [], [
    Element(xe(NS_M, "eqArrPr", [], [])),
    Element(m_arg("e", m_r("x + y = 1"))),
    Element(m_arg("e", m_r("x − y = 3"))),
    Element(m_arg("e", m_r("2x = 4"))),
    Element(m_arg("e", m_r("x = 2"))),
  ])
  cases.push({
    id: "math-eq-array-4line",
    format: "docx",
    category: "math",
    content: ma_body(multi_eq),
  })

  // 19. Complex expression combining many operators —
  // (a + b)/(c − d) × ∫ f(x) dx.  Stresses the renderer with a
  // fraction, an n-ary integral, and a sequence of mixed runs.
  cases.push({
    id: "math-complex-mixed",
    format: "docx",
    category: "math",
    content: ma_body_many([
      Element(
        ma_frac(
          "",
          ma_delim("(", ")", m_r("a + b")),
          ma_delim("(", ")", m_r("c − d")),
        ),
      ),
      Element(m_r(" × ")),
      Element(ma_nary("∫", "subSup", None, None, m_r("f(x) dx"))),
    ]),
  })

  // 20. Bound integral with both lower and upper limits — ∫₀¹ f dx.
  cases.push({
    id: "math-integral-01",
    format: "docx",
    category: "math",
    content: ma_body(
      ma_nary("∫", "subSup", Some(m_r("0")), Some(m_r("1")), m_r("f(x) dx")),
    ),
  })
}
