// WML run-level fixtures — character formatting variants.
//
// Add new fixtures by inserting `cases.push({...})` into
// `extras_wml_run`.  Use the top-level helpers in
// `fixtures_helpers.mbt` (`w_run`, `w_rpr`, `w_flag`, `w_val`,
// `w_rfonts`, `w_p`, `w_t`, `xe`, `xa`).  The host-package builder
// wraps the content in a docx body automatically.

///|
fn extras_wml_run(cases : Array[VisualCase]) -> Unit {
  // Local helpers for multi-attribute run-level property elements
  // (`<w:shd>`, `<w:bdr>`).  These cannot be expressed with `w_val`
  // alone because they carry several `w:`-prefixed attributes.
  let w_attr = fn(local : String, value : String) -> @xml.Attribute {
    { name: { prefix: Some("w"), local_name: local, ns: Some(NS_W) }, value }
  }
  let w_shd = fn(val : String, color : String, fill : String) -> @xml.Element {
    xe(
      NS_W,
      "shd",
      [w_attr("val", val), w_attr("color", color), w_attr("fill", fill)],
      [],
    )
  }
  let w_bdr = fn(
    val : String,
    sz : String,
    space : String,
    color : String,
  ) -> @xml.Element {
    xe(
      NS_W,
      "bdr",
      [
        w_attr("val", val),
        w_attr("sz", sz),
        w_attr("space", space),
        w_attr("color", color),
      ],
      [],
    )
  }

  // ---- Less-common toggle effects (§17.3.2 run property toggles) ----

  // Double strikethrough — `<w:dstrike/>`.
  cases.push({
    id: "run-dstrike",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "normal "),
          w_run(Some(w_rpr([w_flag("dstrike")])), "double-struck"),
          w_run(None, " trailing"),
        ]),
      ),
    ]),
  })

  // Outline — `<w:outline/>`.
  cases.push({
    id: "run-outline",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_flag("outline"), w_val("sz", "72")])),
            "Outlined glyphs",
          ),
        ]),
      ),
    ]),
  })

  // Shadow — `<w:shadow/>`.
  cases.push({
    id: "run-shadow",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_flag("shadow"), w_val("sz", "60")])),
            "Shadowed text",
          ),
        ]),
      ),
    ]),
  })

  // Imprint (engraved) — `<w:imprint/>`.
  cases.push({
    id: "run-imprint",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_flag("imprint"), w_val("sz", "48")])),
            "Engraved text",
          ),
        ]),
      ),
    ]),
  })

  // Emboss — `<w:emboss/>`.
  cases.push({
    id: "run-emboss",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_flag("emboss"), w_val("sz", "48")])),
            "Embossed text",
          ),
        ]),
      ),
    ]),
  })

  // Plain single strikethrough on its own (no bold).
  cases.push({
    id: "run-strike-only",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_flag("strike")])), "Just struck through"),
        ]),
      ),
    ]),
  })

  // ---- Shading + border on runs (§17.3.2.{32,4}) ----

  // `<w:shd>` directly inside `<w:rPr>` — run-level background fill.
  cases.push({
    id: "run-shd",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Before "),
          w_run(
            Some(w_rpr([w_shd("clear", "auto", "FFFF99")])),
            "highlighted-via-shd",
          ),
          w_run(None, " after"),
        ]),
      ),
    ]),
  })

  // `<w:bdr>` — a border drawn around the run text (text in a box).
  cases.push({
    id: "run-bdr",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Outside "),
          w_run(Some(w_rpr([w_bdr("single", "8", "0", "000000")])), "boxed-run"),
          w_run(None, " trailing text"),
        ]),
      ),
    ]),
  })

  // Combined shd + bdr — boxed and shaded together.
  cases.push({
    id: "run-shd-bdr",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(
              w_rpr([
                w_shd("clear", "auto", "FFE699"),
                w_bdr("single", "12", "0", "C00000"),
              ]),
            ),
            "Boxed + shaded run",
          ),
        ]),
      ),
    ]),
  })

  // ---- Color auto vs explicit ----

  // `<w:color w:val="auto"/>` — auto (theme/default) colour.
  cases.push({
    id: "run-color-auto",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("color", "auto")])), "auto-colored "),
          w_run(Some(w_rpr([w_val("color", "7030A0")])), "explicit purple"),
        ]),
      ),
    ]),
  })

  // ---- Vertical position (raised / lowered) — §17.3.2.{24} ----

  // `<w:position w:val="6"/>` — raise 3pt (val is half-points).
  cases.push({
    id: "run-position-raised",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "baseline "),
          w_run(Some(w_rpr([w_val("position", "6")])), "raised"),
          w_run(None, " baseline"),
        ]),
      ),
    ]),
  })

  // `<w:position w:val="-6"/>` — lower 3pt.
  cases.push({
    id: "run-position-lowered",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "baseline "),
          w_run(Some(w_rpr([w_val("position", "-6")])), "lowered"),
          w_run(None, " baseline"),
        ]),
      ),
    ]),
  })

  // ---- Font-size extremes (sz is half-points) ----

  // Very small — `sz="8"` = 4pt.
  cases.push({
    id: "run-size-tiny",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_val("sz", "8")])),
            "Tiny 4pt text (legalese-sized).",
          ),
        ]),
      ),
    ]),
  })

  // Very large — `sz="144"` = 72pt.
  cases.push({
    id: "run-size-huge",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(Some(w_rpr([w_val("sz", "144")])), "72pt")])),
    ]),
  })

  // ---- Language tagging / proofing (§17.3.2.{20,18}) ----

  // `<w:lang w:val="en-US"/>` — language attribute on the run.
  cases.push({
    id: "run-lang",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("lang", "en-US")])), "Tagged as en-US."),
        ]),
      ),
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_val("lang", "ja-JP")])),
            "日本語タグ付き。",
          ),
        ]),
      ),
    ]),
  })

  // `<w:noProof/>` — disable spell/grammar proofing on this run.
  cases.push({
    id: "run-noproof",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Normal "),
          w_run(
            Some(w_rpr([w_flag("noProof")])),
            "asdfqwer not-proofed gibberish",
          ),
          w_run(None, " end."),
        ]),
      ),
    ]),
  })

  // ---- Character compression / expansion — `<w:w w:val="…"/>` ----

  // Compressed to 80%.
  cases.push({
    id: "run-compress-80",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("w", "80")])), "Compressed at 80% width."),
        ]),
      ),
    ]),
  })

  // Expanded to 200%.
  cases.push({
    id: "run-expand-200",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [w_run(Some(w_rpr([w_val("w", "200")])), "Expanded 200%")]),
      ),
    ]),
  })

  // ---- RTL / complex-script toggles (§17.3.2.{29,7}) ----

  // `<w:rtl/>` — right-to-left run direction.
  cases.push({
    id: "run-rtl",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [w_run(Some(w_rpr([w_flag("rtl")])), "Right-to-left run")]),
      ),
    ]),
  })

  // `<w:cs/>` complex-script toggle (uses cs-prefixed properties).
  cases.push({
    id: "run-cs-toggle",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(w_rpr([w_flag("cs"), w_flag("bCs"), w_val("szCs", "40")])),
            "Complex-script bolded run",
          ),
        ]),
      ),
    ]),
  })

  // ---- Unicode coverage — emoji and dingbats ----

  cases.push({
    id: "run-emoji-symbols",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "Symbols: ☃ ♥ ♠ ♦ ♣ © ® ™ → ⇒ ≡ ∞"),
        ]),
      ),
      Element(
        w_p(None, [w_run(None, "Mathy: α β γ ∑ ∫ √ ∈ ⊆ ±")]),
      ),
    ]),
  })

  // ---- Combined effects ----

  // Shadow + bold + large — stacking effects.
  cases.push({
    id: "run-shadow-bold-large",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(
            Some(
              w_rpr([
                w_flag("shadow"),
                w_flag("b"),
                w_val("sz", "72"),
                w_val("color", "1F4E79"),
              ]),
            ),
            "Bold Shadow 36pt",
          ),
        ]),
      ),
    ]),
  })

  // Rainbow — many distinct-color runs in one paragraph.
  cases.push({
    id: "run-rainbow",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_val("color", "FF0000")])), "R"),
          w_run(Some(w_rpr([w_val("color", "FF7F00")])), "a"),
          w_run(Some(w_rpr([w_val("color", "FFD300")])), "i"),
          w_run(Some(w_rpr([w_val("color", "00B050")])), "n"),
          w_run(Some(w_rpr([w_val("color", "00B0F0")])), "b"),
          w_run(Some(w_rpr([w_val("color", "0070C0")])), "o"),
          w_run(Some(w_rpr([w_val("color", "7030A0")])), "w"),
          w_run(None, " across runs"),
        ]),
      ),
    ]),
  })

  // Markdown-style sentence: bold + italic + strike + monospace.
  cases.push({
    id: "run-markdown-mix",
    format: "docx",
    category: "run",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(Some(w_rpr([w_flag("b")])), "Bold"),
          w_run(None, " and "),
          w_run(Some(w_rpr([w_flag("i")])), "italic"),
          w_run(None, " and "),
          w_run(Some(w_rpr([w_flag("strike")])), "strike"),
          w_run(None, " and "),
          w_run(Some(w_rpr([w_rfonts("Courier New")])), "code()"),
          w_run(None, "."),
        ]),
      ),
    ]),
  })
}
