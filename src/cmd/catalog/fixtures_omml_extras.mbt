// Office Math Markup Language EXTRA fixtures — additional §22.1
// coverage beyond `fixtures_omml.mbt` and `fixtures_omml_advanced.mbt`.
// Adds math-styling variants, calculus, series, logic / set theory,
// linear algebra, equation systems, and probability expressions.
//
// Each fixture wraps math content in `<w:p><m:oMath>…</m:oMath></w:p>`
// inside the docx body. Top-level helpers `m_t`, `m_r`, `m_arg`, `m_e`
// come from `fixtures_helpers.mbt`.

///|
/// `m:`-prefixed attribute (file-local copy to keep this module
/// independent of the other OMML files).
fn mx_attr(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("m"), local_name: name, ns: Some(NS_M) }, value }
}

///|
/// `<m:chr m:val="…"/>` — operator character (file-local copy).
fn mx_chr(c : String) -> @xml.Element {
  xe(NS_M, "chr", [mx_attr("val", c)], [])
}

///|
/// Wrap one math expression in a docx body — `<w:p><m:oMath>…</m:oMath></w:p>`.
fn mx_body(inner : @xml.Element) -> @xml.Element {
  xe(NS_W, "body", [], [
    Element(
      xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(inner)]))]),
    ),
  ])
}

///|
/// Wrap many children directly under `<m:oMath>`.
fn mx_body_many(children : Array[@xml.Node]) -> @xml.Element {
  xe(NS_W, "body", [], [
    Element(xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], children))])),
  ])
}

///|
/// `<m:f>` fraction with explicit bar type ("" = default bar,
/// "noBar", "skw", "lin").
fn mx_frac(
  bar_type : String,
  num : @xml.Element,
  den : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = if bar_type == "" {
    []
  } else {
    [Element(xe(NS_M, "type", [mx_attr("val", bar_type)], []))]
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
fn mx_delim(beg : String, end : String, inner : @xml.Element) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if beg != "" {
    pr_kids.push(Element(xe(NS_M, "begChr", [mx_attr("val", beg)], [])))
  }
  if end != "" {
    pr_kids.push(Element(xe(NS_M, "endChr", [mx_attr("val", end)], [])))
  }
  let kids : Array[@xml.Node] = [Element(xe(NS_M, "dPr", [], pr_kids))]
  kids.push(Element(m_arg("e", inner)))
  xe(NS_M, "d", [], kids)
}

///|
/// `<m:sSub>` — base with subscript.
fn mx_sub(e : @xml.Element, sub : @xml.Element) -> @xml.Element {
  xe(NS_M, "sSub", [], [Element(m_arg("e", e)), Element(m_arg("sub", sub))])
}

///|
/// `<m:sSup>` — base with superscript.
fn mx_sup(e : @xml.Element, sup : @xml.Element) -> @xml.Element {
  xe(NS_M, "sSup", [], [Element(m_arg("e", e)), Element(m_arg("sup", sup))])
}

///|
/// `<m:sSubSup>` — base with simultaneous sub+superscript.
fn mx_subsup(
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
/// n-ary operator `<m:nary>` with character, limit-location and
/// sub/sup/e bodies.
fn mx_nary(
  op : String,
  lim_loc : String,
  sub : @xml.Element?,
  sup : @xml.Element?,
  e : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if op != "" {
    pr_kids.push(Element(mx_chr(op)))
  }
  if lim_loc != "" {
    pr_kids.push(Element(xe(NS_M, "limLoc", [mx_attr("val", lim_loc)], [])))
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
/// Styled math run via `<m:rPr><m:sty m:val="…"/></m:rPr>` —
/// "p" plain, "b" bold, "i" italic, "bi" bold-italic.
fn mx_r_sty(text : String, sty : String) -> @xml.Element {
  let rpr = xe(NS_M, "rPr", [], [
    Element(xe(NS_M, "sty", [mx_attr("val", sty)], [])),
  ])
  xe(NS_M, "r", [], [Element(rpr), Element(m_t(text))])
}

///|
/// Math run with explicit alphabet via `<m:rPr><m:scr m:val="…"/></m:rPr>`
/// — "script", "double-struck", "fraktur", "sans-serif", "monospace".
fn mx_r_scr(text : String, scr : String) -> @xml.Element {
  let rpr = xe(NS_M, "rPr", [], [
    Element(xe(NS_M, "scr", [mx_attr("val", scr)], [])),
  ])
  xe(NS_M, "r", [], [Element(rpr), Element(m_t(text))])
}

///|
/// Math run with `<m:nor/>` — literal (non-math) text such as
/// function labels ("sin", "if", "det", "tr").
fn mx_r_nor(text : String) -> @xml.Element {
  let rpr = xe(NS_M, "rPr", [], [Element(xe(NS_M, "nor", [], []))])
  xe(NS_M, "r", [], [Element(rpr), Element(m_t(text))])
}

///|
/// `<m:acc>` accent (vector arrow, hat, dot, bar) over a base.
fn mx_acc(chr : String, e : @xml.Element) -> @xml.Element {
  xe(NS_M, "acc", [], [
    Element(xe(NS_M, "accPr", [], [Element(mx_chr(chr))])),
    Element(m_arg("e", e)),
  ])
}

///|
/// `<m:limLow>` — "lower limit" group (`lim_{x→a}` style).
fn mx_lim_low(base : @xml.Element, lim : @xml.Element) -> @xml.Element {
  xe(NS_M, "limLow", [], [Element(m_arg("e", base)), Element(m_arg("lim", lim))])
}

///|
/// Matrix-row from an array of cell texts.
fn mx_mrow_text(cells : Array[String]) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for c in cells {
    kids.push(Element(m_e(c)))
  }
  xe(NS_M, "mr", [], kids)
}

///|
/// OMML extra fixtures — 32 visual cases covering math styling,
/// calculus, series, logic, set theory, linear algebra, equation
/// systems and probability not yet exercised elsewhere.
fn extras_omml_extras(cases : Array[VisualCase]) -> Unit {
  //
  // ---- Math styling variants ----
  //

  // 1. Italic-styled run — single italic letter via sty="i".
  cases.push({
    id: "math-italic-run",
    format: "docx",
    category: "math",
    content: mx_body(mx_r_sty("x", "i")),
  })

  // 2. Bold-italic-styled run — sty="bi".
  cases.push({
    id: "math-bold-italic-run",
    format: "docx",
    category: "math",
    content: mx_body(mx_r_sty("z", "bi")),
  })

  // 3. Plain-styled run — sty="p" suppresses italic conversion.
  cases.push({
    id: "math-plain-run",
    format: "docx",
    category: "math",
    content: mx_body(mx_r_sty("k", "p")),
  })

  // 4. Sans-serif alphabet — scr="sans-serif" on a single letter.
  cases.push({
    id: "math-sans-serif-letter",
    format: "docx",
    category: "math",
    content: mx_body(mx_r_scr("A", "sans-serif")),
  })

  // 5. Monospace alphabet — scr="monospace" on a single letter.
  cases.push({
    id: "math-monospace-letter",
    format: "docx",
    category: "math",
    content: mx_body(mx_r_scr("M", "monospace")),
  })

  //
  // ---- Calculus ----
  //

  // 6. Derivative dy/dx — italic dy over italic dx with default bar.
  cases.push({
    id: "math-derivative-dy-dx",
    format: "docx",
    category: "math",
    content: mx_body(mx_frac("", m_r("dy"), m_r("dx"))),
  })

  // 7. Second derivative — d²y / dx² with superscripted numerator and
  // denominator parts.
  cases.push({
    id: "math-second-derivative",
    format: "docx",
    category: "math",
    content: mx_body(
      mx_frac(
        "",
        xe(NS_M, "e", [], [
          Element(mx_sup(m_r("d"), m_r("2"))),
          Element(m_r("y")),
        ]),
        xe(NS_M, "e", [], [
          Element(m_r("d")),
          Element(mx_sup(m_r("x"), m_r("2"))),
        ]),
      ),
    ),
  })

  // 8. Mixed partial — ∂²f / (∂x ∂y) — second-order mixed partial
  // with parenthesised denominator.
  cases.push({
    id: "math-mixed-partial",
    format: "docx",
    category: "math",
    content: mx_body(
      mx_frac(
        "",
        xe(NS_M, "e", [], [
          Element(mx_sup(m_r("∂"), m_r("2"))),
          Element(m_r("f")),
        ]),
        xe(NS_M, "e", [], [Element(m_r("∂x ∂y"))]),
      ),
    ),
  })

  // 9. Indefinite integral — ∫ f(x) dx, no limits.
  cases.push({
    id: "math-integral-indefinite",
    format: "docx",
    category: "math",
    content: mx_body(mx_nary("∫", "", None, None, m_r("f(x) dx"))),
  })

  // 10. Definite integral with symbolic bounds — ∫_a^b f(x) dx.
  cases.push({
    id: "math-integral-bounds-symbolic",
    format: "docx",
    category: "math",
    content: mx_body(
      mx_nary("∫", "subSup", Some(m_r("a")), Some(m_r("b")), m_r("f(x) dx")),
    ),
  })

  // 11. Double integral over region D — ∬_D f(x,y) dA.
  cases.push({
    id: "math-double-integral-region",
    format: "docx",
    category: "math",
    content: mx_body(
      mx_nary("∬", "subSup", Some(m_r("D")), None, m_r("f(x,y) dA")),
    ),
  })

  // 12. Line integral — ∮ F · dr around a closed contour.
  cases.push({
    id: "math-line-integral",
    format: "docx",
    category: "math",
    content: mx_body(mx_nary("∮", "", None, None, m_r("F · dr"))),
  })

  //
  // ---- Series & sequences ----
  //

  // 13. Finite sum 1..n — Σ_{k=1}^{n} a_k.
  cases.push({
    id: "math-finite-sum-1-to-n",
    format: "docx",
    category: "math",
    content: mx_body(
      mx_nary(
        "∑",
        "subSup",
        Some(m_r("k=1")),
        Some(m_r("n")),
        mx_sub(m_r("a"), m_r("k")),
      ),
    ),
  })

  // 14. Geometric series — Σ_{k=0}^{∞} a r^k.
  cases.push({
    id: "math-geometric-series",
    format: "docx",
    category: "math",
    content: mx_body(
      mx_nary(
        "∑",
        "subSup",
        Some(m_r("k=0")),
        Some(m_r("∞")),
        xe(NS_M, "e", [], [
          Element(m_r("a")),
          Element(mx_sup(m_r("r"), m_r("k"))),
        ]),
      ),
    ),
  })

  // 15. Telescoping sum — (a₁ − a₂) + (a₂ − a₃) + (a₃ − a₄) + …
  cases.push({
    id: "math-telescoping-sum",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(
        mx_delim(
          "(",
          ")",
          xe(NS_M, "e", [], [
            Element(mx_sub(m_r("a"), m_r("1"))),
            Element(m_r(" − ")),
            Element(mx_sub(m_r("a"), m_r("2"))),
          ]),
        ),
      ),
      Element(m_r(" + ")),
      Element(
        mx_delim(
          "(",
          ")",
          xe(NS_M, "e", [], [
            Element(mx_sub(m_r("a"), m_r("2"))),
            Element(m_r(" − ")),
            Element(mx_sub(m_r("a"), m_r("3"))),
          ]),
        ),
      ),
      Element(m_r(" + ")),
      Element(
        mx_delim(
          "(",
          ")",
          xe(NS_M, "e", [], [
            Element(mx_sub(m_r("a"), m_r("3"))),
            Element(m_r(" − ")),
            Element(mx_sub(m_r("a"), m_r("4"))),
          ]),
        ),
      ),
      Element(m_r(" + ⋯")),
    ]),
  })

  // 16. Recurrence — a_n = a_{n−1} + 2.
  cases.push({
    id: "math-recursion",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_sub(m_r("a"), m_r("n"))),
      Element(m_r(" = ")),
      Element(mx_sub(m_r("a"), m_r("n−1"))),
      Element(m_r(" + 2")),
    ]),
  })

  //
  // ---- Logic & set theory ----
  //

  // 17. Logic — p ∧ q, p ∨ q, ¬p.
  cases.push({
    id: "math-logic-and-or-not",
    format: "docx",
    category: "math",
    content: mx_body(m_r("p ∧ q, p ∨ q, ¬p")),
  })

  // 18. Quantifiers — ∀x ∃y P(x, y).
  cases.push({
    id: "math-forall-exists",
    format: "docx",
    category: "math",
    content: mx_body(m_r("∀x ∃y P(x, y)")),
  })

  // 19. Implication — p ⇒ q.
  cases.push({
    id: "math-implies",
    format: "docx",
    category: "math",
    content: mx_body(m_r("p ⇒ q")),
  })

  // 20. Biconditional — p ⇔ q.
  cases.push({
    id: "math-iff",
    format: "docx",
    category: "math",
    content: mx_body(m_r("p ⇔ q")),
  })

  // 21. Element-of / not-element-of — x ∈ S, x ∉ T.
  cases.push({
    id: "math-element-of",
    format: "docx",
    category: "math",
    content: mx_body(m_r("x ∈ S, x ∉ T")),
  })

  // 22. Subset / proper subset — A ⊂ B, A ⊆ B.
  cases.push({
    id: "math-subset",
    format: "docx",
    category: "math",
    content: mx_body(m_r("A ⊂ B, A ⊆ B")),
  })

  //
  // ---- Linear algebra ----
  //

  // 23. Dot product — a · b in bold.
  cases.push({
    id: "math-dot-product",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_r_sty("a", "b")),
      Element(m_r(" · ")),
      Element(mx_r_sty("b", "b")),
    ]),
  })

  // 24. Cross product — a × b in bold.
  cases.push({
    id: "math-cross-product",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_r_sty("a", "b")),
      Element(m_r(" × ")),
      Element(mx_r_sty("b", "b")),
    ]),
  })

  // 25. Squared norm — ‖v‖² with double-bar delimiters and squared
  // exponent.
  cases.push({
    id: "math-norm-squared",
    format: "docx",
    category: "math",
    content: mx_body(mx_sup(mx_delim("‖", "‖", m_r("v")), m_r("2"))),
  })

  // 26. Determinant — det(A).
  cases.push({
    id: "math-determinant",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_r_nor("det")),
      Element(mx_delim("(", ")", m_r("A"))),
    ]),
  })

  // 27. Trace — tr(A).
  cases.push({
    id: "math-trace",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_r_nor("tr")),
      Element(mx_delim("(", ")", m_r("A"))),
    ]),
  })

  // 28. Eigenvalue equation — Av = λv.
  cases.push({
    id: "math-eigenvalue",
    format: "docx",
    category: "math",
    content: mx_body(m_r("Av = λv")),
  })

  // 29. 2×3 numeric matrix — bracketed.
  let m23 = xe(NS_M, "m", [], [
    Element(xe(NS_M, "mPr", [], [])),
    Element(mx_mrow_text(["1", "2", "3"])),
    Element(mx_mrow_text(["4", "5", "6"])),
  ])
  cases.push({
    id: "math-matrix-2x3",
    format: "docx",
    category: "math",
    content: mx_body(mx_delim("[", "]", m23)),
  })

  //
  // ---- Equations & systems ----
  //

  // 30. System of equations — left brace enclosing an eqArr block.
  let sys = xe(NS_M, "eqArr", [], [
    Element(xe(NS_M, "eqArrPr", [], [])),
    Element(m_arg("e", m_r("ax + by = c"))),
    Element(m_arg("e", m_r("cx + dy = e"))),
  ])
  cases.push({
    id: "math-system-of-eqs",
    format: "docx",
    category: "math",
    content: mx_body(mx_delim("{", "", sys)),
  })

  // 31. Piecewise definition — f(x) = { x² if x>0 ; 0 otherwise }.
  let piecewise = xe(NS_M, "eqArr", [], [
    Element(xe(NS_M, "eqArrPr", [], [])),
    Element(m_arg("e", xe(NS_M, "r", [], [Element(m_t("x² if x > 0"))]))),
    Element(m_arg("e", xe(NS_M, "r", [], [Element(m_t("0  otherwise"))]))),
  ])
  cases.push({
    id: "math-piecewise",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(m_r("f(x) = ")),
      Element(mx_delim("{", "", piecewise)),
    ]),
  })

  // 32. Cauchy–Schwarz inequality — |⟨x,y⟩| ≤ ‖x‖ · ‖y‖.
  cases.push({
    id: "math-cauchy-schwarz",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_delim("|", "|", mx_delim("⟨", "⟩", m_r("x, y")))),
      Element(m_r(" ≤ ")),
      Element(mx_delim("‖", "‖", m_r("x"))),
      Element(m_r(" · ")),
      Element(mx_delim("‖", "‖", m_r("y"))),
    ]),
  })

  // 33. Pythagorean theorem — a² + b² = c².
  cases.push({
    id: "math-pythagorean",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_sup(m_r("a"), m_r("2"))),
      Element(m_r(" + ")),
      Element(mx_sup(m_r("b"), m_r("2"))),
      Element(m_r(" = ")),
      Element(mx_sup(m_r("c"), m_r("2"))),
    ]),
  })

  //
  // ---- Probability ----
  //

  // 34. Binomial coefficient — (n choose k) via no-bar fraction inside
  // parentheses (the canonical OMML rendering for C(n, k)).
  cases.push({
    id: "math-binomial-coefficient",
    format: "docx",
    category: "math",
    content: mx_body(mx_delim("(", ")", mx_frac("noBar", m_r("n"), m_r("k")))),
  })

  // 35. Conditional probability — P(A∩B) / P(B).
  cases.push({
    id: "math-prob-conditional",
    format: "docx",
    category: "math",
    content: mx_body(
      mx_frac(
        "",
        xe(NS_M, "e", [], [
          Element(mx_r_nor("P")),
          Element(mx_delim("(", ")", m_r("A ∩ B"))),
        ]),
        xe(NS_M, "e", [], [
          Element(mx_r_nor("P")),
          Element(mx_delim("(", ")", m_r("B"))),
        ]),
      ),
    ),
  })

  // 36. Variance form — E[X²] − E[X]².  Uses square brackets, nor
  // wrapper on the E operator, and a squared expectation term.
  cases.push({
    id: "math-expected-value",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_r_nor("E")),
      Element(mx_delim("[", "]", mx_sup(m_r("X"), m_r("2")))),
      Element(m_r(" − ")),
      Element(
        mx_sup(
          xe(NS_M, "e", [], [
            Element(mx_r_nor("E")),
            Element(mx_delim("[", "]", m_r("X"))),
          ]),
          m_r("2"),
        ),
      ),
    ]),
  })

  // 37. Hatted estimator — θ̂ via accent ̂ over θ (statistics).
  cases.push({
    id: "math-hat-estimator",
    format: "docx",
    category: "math",
    content: mx_body(mx_acc("̂", m_r("θ"))),
  })

  // 38. Gradient of f — ∇f.  Plain run pairing nabla with f.
  cases.push({
    id: "math-gradient",
    format: "docx",
    category: "math",
    content: mx_body(m_r("∇f")),
  })

  // 39. Triple integral — ∭_V f dV.
  cases.push({
    id: "math-triple-integral",
    format: "docx",
    category: "math",
    content: mx_body(
      mx_nary("∭", "subSup", Some(m_r("V")), None, m_r("f dV")),
    ),
  })

  // 40. Limit at infinity — lim_{n→∞} aₙ.
  cases.push({
    id: "math-limit-infinity",
    format: "docx",
    category: "math",
    content: mx_body_many([
      Element(mx_lim_low(mx_r_nor("lim"), m_r("n→∞"))),
      Element(mx_sub(m_r("a"), m_r("n"))),
    ]),
  })

  // 41. Sub+sup tensor index — T^{ij}_{kl}.
  cases.push({
    id: "math-tensor-indices",
    format: "docx",
    category: "math",
    content: mx_body(mx_subsup(m_r("T"), m_r("kl"), m_r("ij"))),
  })

  // 42. Empty set in equation — A ∩ B = ∅.
  cases.push({
    id: "math-empty-set-eq",
    format: "docx",
    category: "math",
    content: mx_body(m_r("A ∩ B = ∅")),
  })
}
