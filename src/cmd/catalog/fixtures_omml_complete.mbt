// Office Math Markup Language COMPLETION fixtures — explicit §22.1.2
// coverage for every top-level OMML element that `fixtures_omml.mbt`,
// `fixtures_omml_advanced.mbt`, and `fixtures_omml_extras.mbt` do not
// yet exercise.  Tracking against the §22.1.2 element list, these
// were missing entirely:
//
//   - §22.1.2.39 m:limUpp  — Upper-Limit object  (lim ABOVE base)
//   - §22.1.2.31 m:func    — Functional Apply    (fName + e)
//   - §22.1.2.13 m:box     — Box object          (alignment / break point)
//   - §22.1.2.12 m:borderBox — Bordered box      (border + strikethroughs)
//   - §22.1.2.34 m:groupChr — Group-Character    (brace/bracket grouping)
//   - §22.1.2.101 m:sPre   — Pre-script object   (sub/sup BEFORE base)
//
// In addition we add edge-case coverage that the other OMML files
// avoid — empty operand, multi-property nesting, the §22.1.2.51 m:mc
// /m:mcs matrix-column structure, and §22.1.2 properties not yet
// observed by the renderer (`m:vertJc`, `m:hideTop/Bot/Left/Right`,
// `m:strikeH/V/BLTR/TLBR`, `m:opEmu`, `m:diff`, `m:noBreak`, `m:show`,
// `m:zeroWid`, `m:zeroAsc`, `m:zeroDesc`, `m:transp`, `m:subHide`,
// `m:supHide`, `m:grow`, `m:alnScr`, `m:shp`).
//
// Every fixture wraps math content in `<w:p><m:oMath>…</m:oMath></w:p>`
// inside the docx body.  Top-level helpers `m_t`, `m_r`, `m_arg`,
// `m_e` come from `fixtures_helpers.mbt`.  XML trees are assembled
// via `xe`/`xa` and serialised by `@xml.write` at render time — no
// fixture writes a literal XML string.

///|
/// `m:`-prefixed attribute (file-local copy — every per-category
/// OMML extender keeps its own attribute / chr factory so subagents
/// can edit each file independently without cross-file dependencies).
fn mc_attr(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("m"), local_name: name, ns: Some(NS_M) }, value }
}

///|
/// `<m:chr m:val="…"/>` operator character (file-local copy).
fn mc_chr(c : String) -> @xml.Element {
  xe(NS_M, "chr", [mc_attr("val", c)], [])
}

///|
/// Wrap a single math expression in a docx body —
/// `<w:body><w:p><m:oMath>…</m:oMath></w:p></w:body>`.
fn mc_body(inner : @xml.Element) -> @xml.Element {
  xe(NS_W, "body", [], [
    Element(
      xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], [Element(inner)]))]),
    ),
  ])
}

///|
/// Wrap several `<m:oMath>` children in a docx body.
fn mc_body_many(children : Array[@xml.Node]) -> @xml.Element {
  xe(NS_W, "body", [], [
    Element(xe(NS_W, "p", [], [Element(xe(NS_M, "oMath", [], children))])),
  ])
}

///|
/// §22.1.2.39 `<m:limUpp>` — Upper-Limit object (limit expression sits
/// ABOVE the base; typical use: `⋃ₙ Aₙ` rendered with the union as
/// the base and `n` above it).  Counterpart of `m:limLow`.
fn mc_lim_upp(base : @xml.Element, lim : @xml.Element) -> @xml.Element {
  xe(NS_M, "limUpp", [], [
    Element(xe(NS_M, "limUppPr", [], [])),
    Element(m_arg("e", base)),
    Element(m_arg("lim", lim)),
  ])
}

///|
/// §22.1.2.31 `<m:func>` — Functional Apply.  Pairs a function name
/// (typically a `<m:r>` with `<m:nor/>`) with its operand wrapped in
/// `<m:e>`.  Spec example: `sin(x)`, `log(y)`, `det(A)`.
fn mc_func(name : @xml.Element, arg : @xml.Element) -> @xml.Element {
  xe(NS_M, "func", [], [
    Element(xe(NS_M, "funcPr", [], [])),
    Element(m_arg("fName", name)),
    Element(m_arg("e", arg)),
  ])
}

///|
/// §22.1.2.13 `<m:box>` — Box object (logical grouping that lets the
/// engine treat its contents as an operator emulator, no-break unit,
/// or differential).  We expose the `opEmu` / `noBreak` / `diff`
/// flags so each can be exercised independently.
fn mc_box(
  op_emu : Bool,
  no_break : Bool,
  diff : Bool,
  e : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if op_emu {
    pr_kids.push(Element(xe(NS_M, "opEmu", [mc_attr("val", "1")], [])))
  }
  if no_break {
    pr_kids.push(Element(xe(NS_M, "noBreak", [mc_attr("val", "1")], [])))
  }
  if diff {
    pr_kids.push(Element(xe(NS_M, "diff", [mc_attr("val", "1")], [])))
  }
  xe(NS_M, "box", [], [
    Element(xe(NS_M, "boxPr", [], pr_kids)),
    Element(m_arg("e", e)),
  ])
}

///|
/// §22.1.2.12 `<m:borderBox>` — Bordered box with optional side hides
/// (`hideTop/Bot/Left/Right`) and strikethroughs (`strikeH/V`,
/// `strikeBLTR/TLBR`).  A booleans tuple keeps the call sites compact.
fn mc_border_box(
  hide_top : Bool,
  hide_bot : Bool,
  hide_left : Bool,
  hide_right : Bool,
  strike_h : Bool,
  strike_v : Bool,
  strike_bltr : Bool,
  strike_tlbr : Bool,
  e : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if hide_top {
    pr_kids.push(Element(xe(NS_M, "hideTop", [mc_attr("val", "1")], [])))
  }
  if hide_bot {
    pr_kids.push(Element(xe(NS_M, "hideBot", [mc_attr("val", "1")], [])))
  }
  if hide_left {
    pr_kids.push(Element(xe(NS_M, "hideLeft", [mc_attr("val", "1")], [])))
  }
  if hide_right {
    pr_kids.push(Element(xe(NS_M, "hideRight", [mc_attr("val", "1")], [])))
  }
  if strike_h {
    pr_kids.push(Element(xe(NS_M, "strikeH", [mc_attr("val", "1")], [])))
  }
  if strike_v {
    pr_kids.push(Element(xe(NS_M, "strikeV", [mc_attr("val", "1")], [])))
  }
  if strike_bltr {
    pr_kids.push(Element(xe(NS_M, "strikeBLTR", [mc_attr("val", "1")], [])))
  }
  if strike_tlbr {
    pr_kids.push(Element(xe(NS_M, "strikeTLBR", [mc_attr("val", "1")], [])))
  }
  xe(NS_M, "borderBox", [], [
    Element(xe(NS_M, "borderBoxPr", [], pr_kids)),
    Element(m_arg("e", e)),
  ])
}

///|
/// §22.1.2.34 `<m:groupChr>` — Group-Character object.  Places a
/// stretching character (typically a brace `⏞` `⏟` or arrow) above
/// or below the base.  `pos` is "top" or "bot"; `vert_jc` controls
/// where the base aligns relative to the group character.
fn mc_group_chr(
  chr : String,
  pos : String,
  vert_jc : String,
  e : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if chr != "" {
    pr_kids.push(Element(mc_chr(chr)))
  }
  if pos != "" {
    pr_kids.push(Element(xe(NS_M, "pos", [mc_attr("val", pos)], [])))
  }
  if vert_jc != "" {
    pr_kids.push(Element(xe(NS_M, "vertJc", [mc_attr("val", vert_jc)], [])))
  }
  xe(NS_M, "groupChr", [], [
    Element(xe(NS_M, "groupChrPr", [], pr_kids)),
    Element(m_arg("e", e)),
  ])
}

///|
/// §22.1.2.101 `<m:sPre>` — Pre-script object: subscript and
/// superscript BEFORE the base.  Used for isotope notation like
/// `¹⁴₆C` (mass 14, atomic 6 on Carbon).
fn mc_spre(
  sub : @xml.Element,
  sup : @xml.Element,
  e : @xml.Element,
) -> @xml.Element {
  xe(NS_M, "sPre", [], [
    Element(xe(NS_M, "sPrePr", [], [])),
    Element(m_arg("sub", sub)),
    Element(m_arg("sup", sup)),
    Element(m_arg("e", e)),
  ])
}

///|
/// Delimiter with explicit begin/end characters and an optional
/// `<m:shp>` shape value (`"match"` stretches to content height,
/// `"centered"` is fixed-height centred — neither is exercised in
/// the existing OMML files).
fn mc_delim_shp(
  beg : String,
  end : String,
  shp : String,
  grow : Bool,
  inner : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if beg != "" {
    pr_kids.push(Element(xe(NS_M, "begChr", [mc_attr("val", beg)], [])))
  }
  if end != "" {
    pr_kids.push(Element(xe(NS_M, "endChr", [mc_attr("val", end)], [])))
  }
  if grow {
    pr_kids.push(Element(xe(NS_M, "grow", [mc_attr("val", "1")], [])))
  }
  if shp != "" {
    pr_kids.push(Element(xe(NS_M, "shp", [mc_attr("val", shp)], [])))
  }
  let kids : Array[@xml.Node] = [Element(xe(NS_M, "dPr", [], pr_kids))]
  kids.push(Element(m_arg("e", inner)))
  xe(NS_M, "d", [], kids)
}

///|
/// `<m:sSub>` — base with subscript (local helper to keep this file
/// independent of the other OMML extender modules).
fn mc_sub(e : @xml.Element, sub : @xml.Element) -> @xml.Element {
  xe(NS_M, "sSub", [], [Element(m_arg("e", e)), Element(m_arg("sub", sub))])
}

///|
/// `<m:sSup>` — base with superscript (local helper).
fn mc_sup(e : @xml.Element, sup : @xml.Element) -> @xml.Element {
  xe(NS_M, "sSup", [], [Element(m_arg("e", e)), Element(m_arg("sup", sup))])
}

///|
/// `<m:r>` with `<m:rPr><m:nor/></m:rPr>` — literal text such as
/// "sin", "log", "det" used as function names (local helper).
fn mc_r_nor(text : String) -> @xml.Element {
  let rpr = xe(NS_M, "rPr", [], [Element(xe(NS_M, "nor", [], []))])
  xe(NS_M, "r", [], [Element(rpr), Element(m_t(text))])
}

///|
/// `<m:nary>` with `m:grow`, `m:subHide`, `m:supHide` properties —
/// used to exercise the three n-ary flags that the existing OMML
/// files never set.
fn mc_nary_flags(
  op : String,
  lim_loc : String,
  grow : Bool,
  sub_hide : Bool,
  sup_hide : Bool,
  sub : @xml.Element,
  sup : @xml.Element,
  e : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if op != "" {
    pr_kids.push(Element(mc_chr(op)))
  }
  if lim_loc != "" {
    pr_kids.push(Element(xe(NS_M, "limLoc", [mc_attr("val", lim_loc)], [])))
  }
  if grow {
    pr_kids.push(Element(xe(NS_M, "grow", [mc_attr("val", "1")], [])))
  }
  if sub_hide {
    pr_kids.push(Element(xe(NS_M, "subHide", [mc_attr("val", "1")], [])))
  }
  if sup_hide {
    pr_kids.push(Element(xe(NS_M, "supHide", [mc_attr("val", "1")], [])))
  }
  xe(NS_M, "nary", [], [
    Element(xe(NS_M, "naryPr", [], pr_kids)),
    Element(m_arg("sub", sub)),
    Element(m_arg("sup", sup)),
    Element(m_arg("e", e)),
  ])
}

///|
/// `<m:phant>` with the full suite of phantom flags —
/// `show`, `zeroWid`, `zeroAsc`, `zeroDesc`, `transp`.  Each toggles
/// a property the existing `extras_omml`/`extras_omml_extras` `phant`
/// fixture leaves at its default.
fn mc_phant_flags(
  show : Bool,
  zero_wid : Bool,
  zero_asc : Bool,
  zero_desc : Bool,
  transp : Bool,
  e : @xml.Element,
) -> @xml.Element {
  let pr_kids : Array[@xml.Node] = []
  if show {
    pr_kids.push(Element(xe(NS_M, "show", [mc_attr("val", "1")], [])))
  }
  if zero_wid {
    pr_kids.push(Element(xe(NS_M, "zeroWid", [mc_attr("val", "1")], [])))
  }
  if zero_asc {
    pr_kids.push(Element(xe(NS_M, "zeroAsc", [mc_attr("val", "1")], [])))
  }
  if zero_desc {
    pr_kids.push(Element(xe(NS_M, "zeroDesc", [mc_attr("val", "1")], [])))
  }
  if transp {
    pr_kids.push(Element(xe(NS_M, "transp", [mc_attr("val", "1")], [])))
  }
  xe(NS_M, "phant", [], [
    Element(xe(NS_M, "phantPr", [], pr_kids)),
    Element(m_arg("e", e)),
  ])
}

///|
/// `<m:sSubSup>` with `m:alnScr m:val="1"/>` — script-alignment flag
/// that aligns sub and sup with their script position rather than
/// vertically-centred about the base.
fn mc_subsup_aln(
  e : @xml.Element,
  sub : @xml.Element,
  sup : @xml.Element,
) -> @xml.Element {
  xe(NS_M, "sSubSup", [], [
    Element(
      xe(NS_M, "sSubSupPr", [], [
        Element(xe(NS_M, "alnScr", [mc_attr("val", "1")], [])),
      ]),
    ),
    Element(m_arg("e", e)),
    Element(m_arg("sub", sub)),
    Element(m_arg("sup", sup)),
  ])
}

///|
/// OMML completion fixtures — one (or more) visual case per §22.1.2
/// element identified as a coverage gap, plus property-level edge
/// cases for elements whose properties were never exercised.
fn extras_omml_complete(cases : Array[VisualCase]) -> Unit {
  //
  // ---- §22.1.2.39 m:limUpp — Upper-Limit object ----
  //

  // 1. Upper-limit union — `⋃ₙ Aₙ` with `n` ABOVE the union sign.
  //    Spec §22.1.2.39 m:limUpp pairs a base (`m:e`) with a limit
  //    (`m:lim`) drawn above it; this is the OMML counterpart of
  //    `\bigcup\limits^{n} A_n` in TeX.  Renderer must position
  //    `n` above the base, not as a superscript.
  cases.push({
    id: "math-limupp-union",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(mc_lim_upp(m_r("⋃"), m_r("n"))),
      Element(mc_sub(m_r("A"), m_r("n"))),
    ]),
  })

  // 2. Upper-limit with multi-character limit — `⋂_{i=1}^{N}` with
  //    `i=1..N` ABOVE the intersection.  Verifies wide limits render
  //    centred over a single-character base.
  cases.push({
    id: "math-limupp-wide",
    format: "docx",
    category: "math",
    content: mc_body(mc_lim_upp(m_r("⋂"), m_r("i = 1, …, N"))),
  })

  //
  // ---- §22.1.2.31 m:func — Functional Apply ----
  //

  // 3. sin(x) via m:func — the canonical functional-apply form (a
  //    `<m:nor>` "sin" paired with parenthesised `x` as the operand).
  //    Spec §22.1.2.31: the function name is treated as an upright
  //    label, the operand renders inline, no implicit multiplication
  //    is inserted between them.
  cases.push({
    id: "math-func-sin",
    format: "docx",
    category: "math",
    content: mc_body(mc_func(mc_r_nor("sin"), m_r("(x)"))),
  })

  // 4. log_b(x) — log with subscript base via m:func, exercising a
  //    structured function name (sSub) and a parenthesised operand.
  cases.push({
    id: "math-func-log-base",
    format: "docx",
    category: "math",
    content: mc_body(mc_func(mc_sub(mc_r_nor("log"), m_r("b")), m_r("(x)"))),
  })

  // 5. det(A) via m:func — function name "det" applied to matrix A.
  //    Tests m:func with a non-trig function and a single-letter
  //    operand (no parentheses inside the operand).
  cases.push({
    id: "math-func-det",
    format: "docx",
    category: "math",
    content: mc_body(mc_func(mc_r_nor("det"), m_r(" A"))),
  })

  //
  // ---- §22.1.2.13 m:box — Box object ----
  //

  // 6. Box with default properties — wraps `a + b` as a logical unit
  //    with no special operator/break behaviour.  Spec §22.1.2.13:
  //    the default-property box renders identically to its contents
  //    but participates in operator-spacing rules as an atom.
  cases.push({
    id: "math-box-default",
    format: "docx",
    category: "math",
    content: mc_body(mc_box(false, false, false, m_r("a + b"))),
  })

  // 7. Box with `m:opEmu=1` — operator emulator.  The box behaves
  //    like a single operator with respect to surrounding spacing,
  //    used to wrap multi-character operators like `mod`.
  cases.push({
    id: "math-box-opemu",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(m_r("a ")),
      Element(mc_box(true, false, false, mc_r_nor("mod"))),
      Element(m_r(" b")),
    ]),
  })

  // 8. Box with `m:noBreak=1` — the line-break engine is forbidden
  //    from splitting the box's contents across lines.  Exercises
  //    `<m:noBreak>` which appears in no other OMML fixture.
  cases.push({
    id: "math-box-nobreak",
    format: "docx",
    category: "math",
    content: mc_body(mc_box(false, true, false, m_r("never break here"))),
  })

  // 9. Box with `m:diff=1` — differential marker (`dx` in `∫f dx`).
  //    Tells the renderer this run is a differential operator, which
  //    affects its spacing and (in some engines) its style.
  cases.push({
    id: "math-box-diff",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(m_r("∫ f(x) ")),
      Element(mc_box(false, false, true, m_r("dx"))),
    ]),
  })

  //
  // ---- §22.1.2.12 m:borderBox — Bordered box ----
  //

  // 10. Bordered box around an expression — `[a + b]`-style with a
  //     RECTANGULAR border (not a delimiter).  Default properties =
  //     all four sides drawn, no strikethrough.  Spec §22.1.2.12.
  cases.push({
    id: "math-borderbox-default",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_border_box(
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        m_r("a + b = c"),
      ),
    ),
  })

  // 11. Bordered box with horizontal strikethrough — exercises
  //     `m:strikeH=1`.  Visually: a boxed expression with a line
  //     through the middle (used for "cancelled" expressions in
  //     teaching texts).
  cases.push({
    id: "math-borderbox-strikeh",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_border_box(
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        false,
        m_r("x = 0"),
      ),
    ),
  })

  // 12. Bordered box with diagonal BL→TR strikethrough — exercises
  //     `m:strikeBLTR=1`.  This is the "diagonal cancel" notation
  //     `\cancel{x}` familiar from textbook simplifications.
  cases.push({
    id: "math-borderbox-strike-bltr",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_border_box(
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        m_r("x"),
      ),
    ),
  })

  // 13. Bordered box with TL→BR strikethrough plus vertical strike —
  //     exercises both `m:strikeTLBR` and `m:strikeV` at once.  An
  //     edge case stress: two cancellation lines on one box.
  cases.push({
    id: "math-borderbox-strike-multi",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_border_box(
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        true,
        m_r("y"),
      ),
    ),
  })

  // 14. Bordered box with only the LEFT side visible — hides top,
  //     bottom, and right sides.  Standard notation for an absolute
  //     value with a left bar but no right bar (rare, but lets the
  //     renderer exercise the hide flags independently).
  cases.push({
    id: "math-borderbox-left-only",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_border_box(
        true,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        m_r("a + b"),
      ),
    ),
  })

  //
  // ---- §22.1.2.34 m:groupChr — Group-Character object ----
  //

  // 15. Over-brace — `⏞` above `a + b + c + d` ("4 terms").  Spec
  //     §22.1.2.34: a stretching character is rendered above (pos="top",
  //     default) or below (pos="bot") the grouped expression.  Used
  //     for under/over-brace annotations.
  cases.push({
    id: "math-groupchr-overbrace",
    format: "docx",
    category: "math",
    content: mc_body(mc_group_chr("⏞", "top", "", m_r("a + b + c + d"))),
  })

  // 16. Under-brace — `⏟` below `1 + 2 + 3` ("3 terms").  Same
  //     element as above but with `m:pos m:val="bot"` to place the
  //     bracket UNDER the expression.
  cases.push({
    id: "math-groupchr-underbrace",
    format: "docx",
    category: "math",
    content: mc_body(mc_group_chr("⏟", "bot", "", m_r("1 + 2 + 3"))),
  })

  // 17. Over-arrow `→` as a group character — the grouped expression
  //     `AB` denotes a directed segment from A to B; the over-arrow
  //     stretches across both letters.  Exercises a non-brace chr.
  cases.push({
    id: "math-groupchr-overarrow",
    format: "docx",
    category: "math",
    content: mc_body(mc_group_chr("→", "top", "", m_r("AB"))),
  })

  // 18. Over-brace with `m:vertJc="bot"` — vertical justification
  //     pinning the base to the bottom of the group-char's bounding
  //     box.  Exercises the `m:vertJc` property which no other OMML
  //     fixture in the catalog touches.
  cases.push({
    id: "math-groupchr-vertjc",
    format: "docx",
    category: "math",
    content: mc_body(mc_group_chr("⏜", "top", "bot", m_r("x + y"))),
  })

  //
  // ---- §22.1.2.101 m:sPre — Pre-script object ----
  //

  // 19. Carbon-14 isotope — `¹⁴₆C`.  Mass number 14 in the SUP slot
  //     and atomic number 6 in the SUB slot, BEFORE the element
  //     letter `C`.  Spec §22.1.2.101: the pre-script renders both
  //     scripts to the LEFT of the base — distinct from sSubSup
  //     which renders them to the RIGHT.
  cases.push({
    id: "math-spre-isotope",
    format: "docx",
    category: "math",
    content: mc_body(mc_spre(m_r("6"), m_r("14"), m_r("C"))),
  })

  // 20. Empty pre-sup with non-empty pre-sub — `₂H` (deuterium, no
  //     mass-number superscript).  Tests that an empty `<m:sup>`
  //     leaves no leading gap above the base.
  cases.push({
    id: "math-spre-emptysup",
    format: "docx",
    category: "math",
    content: mc_body(mc_spre(m_r("2"), xe(NS_M, "r", [], []), m_r("H"))),
  })

  // 21. Combined pre-script + post-superscript — `¹⁴C²⁺` (carbon-14
  //    ion).  The pre-script provides the isotope mass and a normal
  //    sSup provides the ionic charge.  Stresses the renderer's
  //    side-by-side handling of m:sPre and m:sSup on related bases.
  cases.push({
    id: "math-spre-and-sup",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(mc_spre(xe(NS_M, "r", [], []), m_r("14"), m_r("C"))),
      Element(mc_sup(xe(NS_M, "r", [], []), m_r("2+"))),
    ]),
  })

  //
  // ---- §22.1.2.51-§22.1.2.55 m:m matrix sub-properties ----
  //

  // 22. Matrix with explicit `<m:mcs>` column-spec — defines a 1-of-2
  //     matrix-column with count=2 and right-alignment via `m:mcJc`.
  //     Exercises `m:mcs`, `m:mc`, `m:mcPr`, `m:count`, `m:mcJc`
  //     which together control per-column alignment in `<m:m>` and
  //     do not appear in any other OMML fixture.
  let mcs = xe(NS_M, "mcs", [], [
    Element(
      xe(NS_M, "mc", [], [
        Element(
          xe(NS_M, "mcPr", [], [
            Element(xe(NS_M, "count", [mc_attr("val", "2")], [])),
            Element(xe(NS_M, "mcJc", [mc_attr("val", "right")], [])),
          ]),
        ),
      ]),
    ),
  ])
  let m_with_mcs = xe(NS_M, "m", [], [
    Element(xe(NS_M, "mPr", [], [Element(mcs)])),
    Element(xe(NS_M, "mr", [], [Element(m_e("a₁")), Element(m_e("b₁"))])),
    Element(xe(NS_M, "mr", [], [Element(m_e("a₂")), Element(m_e("b₂"))])),
  ])
  cases.push({
    id: "math-matrix-mcs",
    format: "docx",
    category: "math",
    content: mc_body(mc_delim_shp("[", "]", "", false, m_with_mcs)),
  })

  // 23. Matrix with placeholder-hide flag (`m:plcHide=1`) on `m:mPr`
  //     — suppresses the default placeholder dot that some math
  //     renderers draw in empty cells.  Combined with one empty cell
  //     to make the effect visible.
  let m_plchide = xe(NS_M, "m", [], [
    Element(
      xe(NS_M, "mPr", [], [
        Element(xe(NS_M, "plcHide", [mc_attr("val", "1")], [])),
      ]),
    ),
    Element(
      xe(NS_M, "mr", [], [
        Element(m_e("x")),
        Element(xe(NS_M, "e", [], [Element(xe(NS_M, "r", [], []))])),
      ]),
    ),
    Element(
      xe(NS_M, "mr", [], [
        Element(xe(NS_M, "e", [], [Element(xe(NS_M, "r", [], []))])),
        Element(m_e("y")),
      ]),
    ),
  ])
  cases.push({
    id: "math-matrix-plchide",
    format: "docx",
    category: "math",
    content: mc_body(mc_delim_shp("(", ")", "", false, m_plchide)),
  })

  //
  // ---- Delimiter shape and grow flags ----
  //

  // 24. Delimiter with `m:shp m:val="match"` — bracket height stretches
  //     to match the inner content's height.  Visible difference
  //     against the default fixed-height bracket when wrapping a tall
  //     fraction.
  cases.push({
    id: "math-delim-shp-match",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_delim_shp(
        "(",
        ")",
        "match",
        false,
        xe(NS_M, "f", [], [
          Element(xe(NS_M, "fPr", [], [])),
          Element(m_arg("num", m_r("a + b"))),
          Element(m_arg("den", m_r("c + d"))),
        ]),
      ),
    ),
  })

  // 25. Delimiter with `m:shp m:val="centered"` — fixed-height
  //     bracket centred vertically about the math axis even when the
  //     inner content is shorter.  Counterpart of the "match" variant.
  cases.push({
    id: "math-delim-shp-centered",
    format: "docx",
    category: "math",
    content: mc_body(mc_delim_shp("[", "]", "centered", false, m_r("x"))),
  })

  // 26. Delimiter with `m:grow=1` — alternate stretchy bracket flag
  //     (older OMML files used this instead of `m:shp m:val="match"`).
  //     Renders identically to a `match` shape but exercises the
  //     `m:grow` element specifically.
  cases.push({
    id: "math-delim-grow",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_delim_shp(
        "(",
        ")",
        "",
        true,
        xe(NS_M, "rad", [], [
          Element(
            xe(NS_M, "radPr", [], [
              Element(xe(NS_M, "degHide", [mc_attr("val", "1")], [])),
            ]),
          ),
          Element(m_arg("deg", xe(NS_M, "r", [], []))),
          Element(m_arg("e", m_r("x"))),
        ]),
      ),
    ),
  })

  //
  // ---- N-ary script-hide and grow flags ----
  //

  // 27. n-ary sum with `m:supHide=1` — hides the upper limit slot
  //     entirely (the element is present but suppressed).  Visually
  //     equivalent to omitting the `<m:sup>` but exercises the
  //     `m:supHide` property explicitly.
  cases.push({
    id: "math-nary-suphide",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_nary_flags(
        "∑",
        "subSup",
        false,
        false,
        true,
        m_r("k=1"),
        m_r("∞"),
        mc_sub(m_r("a"), m_r("k")),
      ),
    ),
  })

  // 28. n-ary product with `m:subHide=1` — hides the lower-limit
  //     slot.  Useful for "from this index up to infinity" forms
  //     where only the upper bound is interesting in context.
  cases.push({
    id: "math-nary-subhide",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_nary_flags(
        "∏",
        "subSup",
        false,
        true,
        false,
        m_r("i"),
        m_r("n"),
        mc_sub(m_r("x"), m_r("i")),
      ),
    ),
  })

  // 29. n-ary `m:grow=1` — the operator stretches to match the
  //     summand's height (e.g. a big-Σ that fits a tall fraction).
  cases.push({
    id: "math-nary-grow",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_nary_flags(
        "∑",
        "subSup",
        true,
        false,
        false,
        m_r("k=0"),
        m_r("n"),
        xe(NS_M, "f", [], [
          Element(xe(NS_M, "fPr", [], [])),
          Element(m_arg("num", m_r("k(k+1)"))),
          Element(m_arg("den", m_r("2"))),
        ]),
      ),
    ),
  })

  //
  // ---- Phantom property flags ----
  //

  // 30. Phantom with `m:show=1` — explicitly visible phantom (the
  //     content is drawn AND its metrics are used).  Lets the
  //     renderer differentiate the show-vs-hide case from the
  //     default phantom (which uses metrics only).
  cases.push({
    id: "math-phant-show",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(m_r("A + ")),
      Element(mc_phant_flags(true, false, false, false, false, m_r("xyz"))),
    ]),
  })

  // 31. Zero-width phantom — `m:zeroWid=1` zeroes the horizontal
  //     advance so the content contributes height but not width.
  //     Useful for aligning baselines without occupying space.
  cases.push({
    id: "math-phant-zerowid",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(m_r("|")),
      Element(mc_phant_flags(false, true, false, false, false, m_r("xyz"))),
      Element(m_r("|")),
    ]),
  })

  // 32. Zero-ascent + zero-descent phantom — `zeroAsc=1` + `zeroDesc=1`
  //     give a vertically-collapsed phantom that contributes width
  //     only.  Pair-test for the two zero-vertical flags.
  cases.push({
    id: "math-phant-zero-vert",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(m_r("[")),
      Element(mc_phant_flags(false, false, true, true, false, m_r("Wp"))),
      Element(m_r("]")),
    ]),
  })

  // 33. Transparent phantom — `m:transp=1` keeps the content invisible
  //    but renders the surrounding spacing as if it were drawn.
  //    Functionally similar to a default phantom, but the spec calls
  //    it out as a separate property and we want both paths exercised.
  cases.push({
    id: "math-phant-transp",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(m_r("a = ")),
      Element(mc_phant_flags(false, false, false, false, true, m_r("XYZ"))),
      Element(m_r(" + b")),
    ]),
  })

  //
  // ---- sSubSup alignment flag ----
  //

  // 34. `<m:sSubSup>` with `m:alnScr=1` — script-align flag aligning
  //     the sub/sup to script position (typically: vertically
  //     stacked so the sub directly under the sup) rather than the
  //     usual offset layout.  Stress-test for the alnScr code path.
  cases.push({
    id: "math-ssubsup-alnscr",
    format: "docx",
    category: "math",
    content: mc_body(mc_subsup_aln(m_r("X"), m_r("ij"), m_r("kl"))),
  })

  //
  // ---- Composite — exercise multiple new elements at once ----
  //

  // 35. Composite showcase — `func(sin)(x) + ⏞{a+b} + ¹⁴C` rendered
  //     in a single `<m:oMath>` paragraph.  Stress-test that m:func,
  //     m:groupChr, and m:sPre coexist with the existing renderer
  //     pipeline without layout interference.
  cases.push({
    id: "math-complete-composite",
    format: "docx",
    category: "math",
    content: mc_body_many([
      Element(mc_func(mc_r_nor("sin"), m_r("(x)"))),
      Element(m_r(" + ")),
      Element(mc_group_chr("⏞", "top", "", m_r("a + b"))),
      Element(m_r(" + ")),
      Element(mc_spre(xe(NS_M, "r", [], []), m_r("14"), m_r("C"))),
    ]),
  })

  // 36. Composite §22.1.2.39 `m:limUpp` nested inside `m:func` —
  //     `lim_{n→∞}(f)` styled as a function application where the
  //     "function" itself is an upper-limit construction.  Verifies
  //     that the renderer recurses correctly through both new
  //     element families.
  cases.push({
    id: "math-limupp-in-func",
    format: "docx",
    category: "math",
    content: mc_body(
      mc_func(mc_lim_upp(mc_r_nor("lim"), m_r("n→∞")), m_r("(f)")),
    ),
  })
}
