// Office Math Markup Language fixtures — math constructs wrapped in
// a docx body.  Use `m_t`, `m_r`, `m_arg`, `m_e` from
// `fixtures_helpers.mbt` for `<m:t>`, `<m:r>`, generic `<m:e>` etc.
//
// Each fixture wraps its math content in `<w:p><m:oMath>…</m:oMath></w:p>`
// inside the docx body.

///|
/// Build an OMML attribute with `m:` prefix — required for sub-properties
/// like `m:val`, `m:type`, `m:bar`, `m:limLoc`, `m:pos`.
fn m_attr(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("m"), local_name: name, ns: Some(NS_M) }, value }
}

///|
/// `<m:chr m:val="…"/>` — operator character for accents, n-ary, groupChr.
fn m_chr(c : String) -> @xml.Element {
  xe(NS_M, "chr", [m_attr("val", c)], [])
}

///|
/// Wrap a math expression in a docx body inside `<w:p><m:oMath>…</m:oMath></w:p>`.
fn omml_body(inner : @xml.Element) -> @xml.Element {
  xe(NS_W, "body", [], [
    Element(
      xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(inner)]))]),
    ),
  ])
}

///|
/// Wrap an `<m:oMath>` that already aggregates many child elements,
/// instead of a single inner element.
fn omml_body_many(children : Array[@xml.Node]) -> @xml.Element {
  xe(NS_W, "body", [], [
    Element(xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], children))])),
  ])
}

///|
/// Delimiter (`<m:d>`) with explicit begin/end characters.  Empty
/// strings keep the default parenthesis.
fn m_delim(
  beg : String,
  sep : String,
  end : String,
  inner : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if beg != "" {
    pr_kids.push(Element(xe(NS_M, "begChr", [m_attr("val", beg)], [])))
  }
  if sep != "" {
    pr_kids.push(Element(xe(NS_M, "sepChr", [m_attr("val", sep)], [])))
  }
  if end != "" {
    pr_kids.push(Element(xe(NS_M, "endChr", [m_attr("val", end)], [])))
  }
  let kids : Array[@xml.Node] = [Element(xe(NS_M, "dPr", [], pr_kids))]
  kids.push(Element(m_arg("e", inner)))
  xe(NS_M, "d", [], kids)
}

///|
/// `<m:r>` math run with `<m:rPr><m:sty m:val="…"/></m:rPr>`
/// — controls italic/bold styling (`"p"`, `"b"`, `"i"`, `"bi"`).
fn m_r_styled(text : String, sty : String) -> @xml.Element {
  let rpr = xe(NS_M, "rPr", [], [
    Element(xe(NS_M, "sty", [m_attr("val", sty)], [])),
  ])
  xe(NS_M, "r", [], [Element(rpr), Element(m_t(text))])
}

///|
/// `<m:r>` math run with `<m:rPr><m:scr m:val="…"/></m:rPr>` —
/// controls the math alphabet ("script", "double-struck", "fraktur",
/// "sans-serif", etc.).
fn m_r_scr(text : String, scr : String) -> @xml.Element {
  let rpr = xe(NS_M, "rPr", [], [
    Element(xe(NS_M, "scr", [m_attr("val", scr)], [])),
  ])
  xe(NS_M, "r", [], [Element(rpr), Element(m_t(text))])
}

///|
/// `<m:r>` with `<m:rPr><m:nor/></m:rPr>` — literal (non-math) text,
/// e.g. a label like "if" or "for".
fn m_r_nor(text : String) -> @xml.Element {
  let rpr = xe(NS_M, "rPr", [], [Element(xe(NS_M, "nor", [], []))])
  xe(NS_M, "r", [], [Element(rpr), Element(m_t(text))])
}

///|
/// N-ary operator (`<m:nary>`) with full property set: character,
/// optional `limLoc`, optional `subHide` / `supHide`, sub/sup/e bodies.
fn m_nary(
  op : String,
  lim_loc : String,
  sub : @xml.Element?,
  sup : @xml.Element?,
  e : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if op != "" {
    pr_kids.push(Element(m_chr(op)))
  }
  if lim_loc != "" {
    pr_kids.push(Element(xe(NS_M, "limLoc", [m_attr("val", lim_loc)], [])))
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
/// `<m:f>` fraction with explicit bar type ("bar" default, "noBar"
/// for binomial-stacked, "skw" / "lin" for slashed).
fn m_frac(
  bar_type : String,
  num : @xml.Element,
  den : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = if bar_type == "" {
    []
  } else {
    [Element(xe(NS_M, "type", [m_attr("val", bar_type)], []))]
  }
  xe(NS_M, "f", [], [
    Element(xe(NS_M, "fPr", [], pr_kids)),
    Element(m_arg("num", num)),
    Element(m_arg("den", den)),
  ])
}

///|
/// `<m:rad>` — square root if `deg_text` empty, else nth root.
fn m_rad(deg_text : String, e : @xml.Element) -> @xml.Element {
  let deg_inner : @xml.Element = if deg_text == "" {
    xe(NS_M, "r", [], [])
  } else {
    m_r(deg_text)
  }
  let pr_kids : Array[@xml.Node] = if deg_text == "" {
    [Element(xe(NS_M, "degHide", [m_attr("val", "1")], []))]
  } else {
    []
  }
  xe(NS_M, "rad", [], [
    Element(xe(NS_M, "radPr", [], pr_kids)),
    Element(m_arg("deg", deg_inner)),
    Element(m_arg("e", e)),
  ])
}

///|
fn extras_omml(cases : Array[VisualCase]) -> Unit {
  // 1. Square-root with degree-hide flag — √(2x+3) drawn as a true
  // square root (no visible index in front of the radical).
  cases.push({
    id: "math-sqrt-hidedeg",
    format: "docx",
    category: "math",
    content: omml_body(m_rad("", m_r("2x + 3"))),
  })

  // 2. Cube root — ³√(x³+y³).
  cases.push({
    id: "math-cube-root",
    format: "docx",
    category: "math",
    content: omml_body(m_rad("3", m_r("x³ + y³"))),
  })

  // 3. Nested radicals — √(1 + √x).
  // `m_rad` expects the `<m:e>` body as a single element; we splice
  // two children into an `<m:r>` wrapper so the outer radical wraps
  // the whole expression.
  let nested_inner = xe(NS_M, "r", [], [Element(m_t("1 + "))])
  let inner_rad = m_rad("", m_r("x"))
  // Build the e payload manually so it has both run and radical.
  let nested_e = xe(NS_M, "e", [], [Element(nested_inner), Element(inner_rad)])
  cases.push({
    id: "math-nested-radical",
    format: "docx",
    category: "math",
    content: xe(NS_W, "body", [], [
      Element(
        xe(NS_W, "p", [], [
          Element(
            xe(NS_M, "oMath", [], [
              Element(
                xe(NS_M, "rad", [], [
                  Element(
                    xe(NS_M, "radPr", [], [
                      Element(xe(NS_M, "degHide", [m_attr("val", "1")], [])),
                    ]),
                  ),
                  Element(m_arg("deg", xe(NS_M, "r", [], []))),
                  Element(nested_e),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    ]),
  })

  // 4. Slashed (skewed) fraction — a/b drawn diagonally.
  cases.push({
    id: "math-fraction-slash",
    format: "docx",
    category: "math",
    content: omml_body(m_frac("skw", m_r("a"), m_r("b"))),
  })

  // 5. Linear fraction — a/b drawn inline with a slash.
  cases.push({
    id: "math-fraction-linear",
    format: "docx",
    category: "math",
    content: omml_body(m_frac("lin", m_r("p"), m_r("q"))),
  })

  // 6. No-bar fraction — used for binomial coefficients (n choose k).
  cases.push({
    id: "math-binomial",
    format: "docx",
    category: "math",
    content: omml_body(
      m_delim("(", "", ")", m_frac("noBar", m_r("n"), m_r("k"))),
    ),
  })

  // 7. Absolute value delimiter — |x + y|.
  cases.push({
    id: "math-delim-absvalue",
    format: "docx",
    category: "math",
    content: omml_body(m_delim("|", "", "|", m_r("x + y"))),
  })

  // 8. Norm delimiter — ‖v‖ (double bar).
  cases.push({
    id: "math-delim-norm",
    format: "docx",
    category: "math",
    content: omml_body(m_delim("‖", "", "‖", m_r("v"))),
  })

  // 9. Floor delimiter — ⌊x⌋.
  cases.push({
    id: "math-delim-floor",
    format: "docx",
    category: "math",
    content: omml_body(m_delim("⌊", "", "⌋", m_r("x"))),
  })

  // 10. Ceiling delimiter — ⌈x⌉.
  cases.push({
    id: "math-delim-ceiling",
    format: "docx",
    category: "math",
    content: omml_body(m_delim("⌈", "", "⌉", m_r("x"))),
  })

  // 11. Angle delimiter — ⟨x, y⟩.
  cases.push({
    id: "math-delim-angle",
    format: "docx",
    category: "math",
    content: omml_body(m_delim("⟨", "", "⟩", m_r("x, y"))),
  })

  // 12. n-ary sum with limLoc=subSup — limits become sub/sup scripts
  // on the sigma rather than under / over it (inline-style).
  cases.push({
    id: "math-summation-inline",
    format: "docx",
    category: "math",
    content: omml_body(
      m_nary("∑", "subSup", Some(m_r("k=0")), Some(m_r("N")), m_r("a_k")),
    ),
  })

  // 13. n-ary integral with explicit undOvr limit location — limits
  // displayed under/over the integral sign (unusual for ∫).
  cases.push({
    id: "math-integral-undovr",
    format: "docx",
    category: "math",
    content: omml_body(
      m_nary(
        "∫",
        "undOvr",
        Some(m_r("0")),
        Some(m_r("∞")),
        m_r("e^{-t} dt"),
      ),
    ),
  })

  // 14. Double integral — ∬ over a region D.
  cases.push({
    id: "math-double-integral",
    format: "docx",
    category: "math",
    content: omml_body(
      m_nary("∬", "subSup", Some(m_r("D")), None, m_r("f(x,y) dA")),
    ),
  })

  // 15. Contour integral — ∮ around a closed curve C.
  cases.push({
    id: "math-contour-integral",
    format: "docx",
    category: "math",
    content: omml_body(
      m_nary("∮", "subSup", Some(m_r("C")), None, m_r("F · dr")),
    ),
  })

  // 16. Coproduct n-ary — ∐.
  cases.push({
    id: "math-coproduct",
    format: "docx",
    category: "math",
    content: omml_body(m_nary("∐", "", Some(m_r("i∈I")), None, m_r("X_i"))),
  })

  // 17. Equation array — three aligned equations.
  let eq_arr = xe(NS_M, "eqArr", [], [
    Element(xe(NS_M, "eqArrPr", [], [])),
    Element(m_arg("e", m_r("a + b = c"))),
    Element(m_arg("e", m_r("d − e = f"))),
    Element(m_arg("e", m_r("g × h = i"))),
  ])
  cases.push({
    id: "math-eq-array",
    format: "docx",
    category: "math",
    content: omml_body(eq_arr),
  })

  // 18. 3×3 matrix — identity matrix I₃.
  let matrix3 = xe(NS_M, "m", [], [
    Element(xe(NS_M, "mPr", [], [])),
    Element(
      xe(NS_M, "mr", [], [
        Element(m_e("1")),
        Element(m_e("0")),
        Element(m_e("0")),
      ]),
    ),
    Element(
      xe(NS_M, "mr", [], [
        Element(m_e("0")),
        Element(m_e("1")),
        Element(m_e("0")),
      ]),
    ),
    Element(
      xe(NS_M, "mr", [], [
        Element(m_e("0")),
        Element(m_e("0")),
        Element(m_e("1")),
      ]),
    ),
  ])
  cases.push({
    id: "math-matrix-identity",
    format: "docx",
    category: "math",
    content: omml_body(m_delim("[", "", "]", matrix3)),
  })

  // 19. Quadratic formula — x = (-b ± √(b² - 4ac)) / 2a.
  let quad_disc = m_rad("", m_r("b² − 4ac"))
  let quad_num = xe(NS_M, "e", [], [
    Element(m_r("−b ± ")),
    Element(quad_disc),
  ])
  let quad_frac = xe(NS_M, "f", [], [
    Element(xe(NS_M, "fPr", [], [])),
    Element(xe(NS_M, "num", [], [Element(quad_num)])),
    Element(m_arg("den", m_r("2a"))),
  ])
  cases.push({
    id: "math-quadratic-formula",
    format: "docx",
    category: "math",
    content: omml_body_many([Element(m_r("x = ")), Element(quad_frac)]),
  })

  // 20. Euler's identity — e^{iπ} + 1 = 0.
  let euler_pow = xe(NS_M, "sSup", [], [
    Element(m_arg("e", m_r("e"))),
    Element(m_arg("sup", m_r("iπ"))),
  ])
  cases.push({
    id: "math-euler-identity",
    format: "docx",
    category: "math",
    content: omml_body_many([Element(euler_pow), Element(m_r(" + 1 = 0"))]),
  })

  // 21. Greek letters mixed with operators — α + β = γ.
  cases.push({
    id: "math-greek-letters",
    format: "docx",
    category: "math",
    content: omml_body(m_r("α + β = γ + δ + ε")),
  })

  // 22. Script (calligraphic) styling on a run — script L (𝓛).
  cases.push({
    id: "math-script-alphabet",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(m_r_scr("L", "script")),
      Element(m_r("(f) = ")),
      Element(m_nary("∫", "", Some(m_r("Ω")), None, m_r("f dμ"))),
    ]),
  })

  // 23. Double-struck (blackboard bold) — ℝ ∪ ℂ via scr="double-struck".
  cases.push({
    id: "math-double-struck",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(m_r_scr("R", "double-struck")),
      Element(m_r(" ⊂ ")),
      Element(m_r_scr("C", "double-struck")),
    ]),
  })

  // 24. Fraktur alphabet — 𝔤 lie algebra notation.
  cases.push({
    id: "math-fraktur",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(m_r_scr("g", "fraktur")),
      Element(m_r(" ⊕ ")),
      Element(m_r_scr("h", "fraktur")),
    ]),
  })

  // 25. Bold math run via sty="b" — bold vector v.
  cases.push({
    id: "math-bold-run",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(m_r_styled("v", "b")),
      Element(m_r(" · ")),
      Element(m_r_styled("w", "b")),
      Element(m_r(" = ")),
      Element(
        m_nary(
          "∑",
          "subSup",
          Some(m_r("i=1")),
          Some(m_r("n")),
          m_r("v_i w_i"),
        ),
      ),
    ]),
  })

  // 26. Roman (upright) text in math via nor — sin and cos labels.
  cases.push({
    id: "math-roman-labels",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(
        xe(NS_M, "sSup", [], [
          Element(m_arg("e", m_r_nor("sin"))),
          Element(m_arg("sup", m_r("2"))),
        ]),
      ),
      Element(m_r("(θ) + ")),
      Element(
        xe(NS_M, "sSup", [], [
          Element(m_arg("e", m_r_nor("cos"))),
          Element(m_arg("sup", m_r("2"))),
        ]),
      ),
      Element(m_r("(θ) = 1")),
    ]),
  })

  // 27. Phantom — invisible spacing for alignment (uses width but
  // renders nothing).
  let phant = xe(NS_M, "phant", [], [
    Element(xe(NS_M, "phantPr", [], [])),
    Element(m_arg("e", m_r("xyz"))),
  ])
  cases.push({
    id: "math-phantom",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(m_r("a + ")),
      Element(phant),
      Element(m_r(" = b")),
    ]),
  })

  // 28. Long polynomial — full expansion of a binomial cube.
  cases.push({
    id: "math-polynomial-cube",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(
        xe(NS_M, "d", [], [
          Element(xe(NS_M, "dPr", [], [])),
          Element(m_arg("e", m_r("a + b"))),
        ]),
      ),
      Element(
        xe(NS_M, "sSup", [], [
          Element(m_arg("e", xe(NS_M, "r", [], []))),
          Element(m_arg("sup", m_r("3"))),
        ]),
      ),
      Element(m_r(" = ")),
      Element(
        xe(NS_M, "sSup", [], [
          Element(m_arg("e", m_r("a"))),
          Element(m_arg("sup", m_r("3"))),
        ]),
      ),
      Element(m_r(" + 3")),
      Element(
        xe(NS_M, "sSup", [], [
          Element(m_arg("e", m_r("a"))),
          Element(m_arg("sup", m_r("2"))),
        ]),
      ),
      Element(m_r("b + 3a")),
      Element(
        xe(NS_M, "sSup", [], [
          Element(m_arg("e", m_r("b"))),
          Element(m_arg("sup", m_r("2"))),
        ]),
      ),
      Element(m_r(" + ")),
      Element(
        xe(NS_M, "sSup", [], [
          Element(m_arg("e", m_r("b"))),
          Element(m_arg("sup", m_r("3"))),
        ]),
      ),
    ]),
  })

  // 29. Factored quadratic on one line — (x − r₁)(x − r₂).
  cases.push({
    id: "math-factored-form",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(
        m_delim(
          "(",
          "",
          ")",
          xe(NS_M, "e", [], [
            Element(m_r("x − ")),
            Element(
              xe(NS_M, "sSub", [], [
                Element(m_arg("e", m_r("r"))),
                Element(m_arg("sub", m_r("1"))),
              ]),
            ),
          ]),
        ),
      ),
      Element(
        m_delim(
          "(",
          "",
          ")",
          xe(NS_M, "e", [], [
            Element(m_r("x − ")),
            Element(
              xe(NS_M, "sSub", [], [
                Element(m_arg("e", m_r("r"))),
                Element(m_arg("sub", m_r("2"))),
              ]),
            ),
          ]),
        ),
      ),
    ]),
  })

  // 30. Mean / expectation formula — E[X] = (1/n) Σ x_i.
  cases.push({
    id: "math-expectation",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(m_r_nor("E")),
      Element(m_delim("[", "", "]", m_r("X"))),
      Element(m_r(" = ")),
      Element(m_frac("", m_r("1"), m_r("n"))),
      Element(
        m_nary(
          "∑",
          "subSup",
          Some(m_r("i=1")),
          Some(m_r("n")),
          xe(NS_M, "sSub", [], [
            Element(m_arg("e", m_r("x"))),
            Element(m_arg("sub", m_r("i"))),
          ]),
        ),
      ),
    ]),
  })

  // 31. Nested fractions — 1 / (1 + 1/(1 + 1/x)) continued-fraction form.
  let inner_one = m_frac("", m_r("1"), m_r("x"))
  let mid = m_frac(
    "",
    m_r("1"),
    xe(NS_M, "e", [], [Element(m_r("1 + ")), Element(inner_one)]),
  )
  let outer = m_frac(
    "",
    m_r("1"),
    xe(NS_M, "e", [], [Element(m_r("1 + ")), Element(mid)]),
  )
  cases.push({
    id: "math-continued-fraction",
    format: "docx",
    category: "math",
    content: omml_body(outer),
  })

  // 32. Limit with arrow — lim_{x→0} sin(x)/x = 1.
  cases.push({
    id: "math-limit-quotient",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(
        xe(NS_M, "limLow", [], [
          Element(m_arg("e", m_r_nor("lim"))),
          Element(m_arg("lim", m_r("x→0"))),
        ]),
      ),
      Element(
        m_frac(
          "",
          xe(NS_M, "e", [], [Element(m_r_nor("sin")), Element(m_r("(x)"))]),
          m_r("x"),
        ),
      ),
      Element(m_r(" = 1")),
    ]),
  })

  // 33. Three equations in one paragraph separated by commas.
  cases.push({
    id: "math-multi-equation",
    format: "docx",
    category: "math",
    content: omml_body_many([
      Element(m_r("a = 1, ")),
      Element(m_r("b = 2, ")),
      Element(m_r("c = a + b")),
    ]),
  })

  // 34. Vector with overline and subscript — x̄_n
  let bar_sub = xe(NS_M, "sSub", [], [
    Element(
      m_arg(
        "e",
        xe(NS_M, "bar", [], [
          Element(xe(NS_M, "barPr", [], [])),
          Element(m_arg("e", m_r("x"))),
        ]),
      ),
    ),
    Element(m_arg("sub", m_r("n"))),
  ])
  cases.push({
    id: "math-bar-subscript",
    format: "docx",
    category: "math",
    content: omml_body(bar_sub),
  })

  // 35. Multi-line sum: ∑_{i,j} a_{ij}.
  cases.push({
    id: "math-double-summation",
    format: "docx",
    category: "math",
    content: omml_body(
      m_nary(
        "∑",
        "subSup",
        Some(m_r("i, j")),
        None,
        xe(NS_M, "sSub", [], [
          Element(m_arg("e", m_r("a"))),
          Element(m_arg("sub", m_r("ij"))),
        ]),
      ),
    ),
  })
}
