///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
test "Office Math viewer renders text as MathML" {
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("r"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("t"),
            attributes: [],
            children: [@xml.Node::Text("x")],
          }),
        ],
      }),
    ],
  })
  let html = render_html(math)
  assert_true(html.contains("data-ooxml=\"omml\""))
  assert_true(html.contains("<mtext>x</mtext>"))
}

///|
/// §22.1.2.79 nary + §22.1.2.80 naryPr/@chr — the n-ary operator
/// glyph MUST surface inside the rendered MathML.  Default is ∑;
/// @chr overrides with the actual operator (∏, ∫, etc.).
test "Office Math viewer §22.1.2.79 nary emits operator glyph" {
  // <m:nary>
  //   <m:naryPr><m:chr val="∏"/></m:naryPr>
  //   <m:sub><m:r><m:t>i=1</m:t></m:r></m:sub>
  //   <m:sup><m:r><m:t>n</m:t></m:r></m:sup>
  //   <m:e><m:r><m:t>x</m:t></m:r></m:e>
  // </m:nary>
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let nary : @xml.Element = {
    name: name("nary"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("naryPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("chr"),
            attributes: [{ name: name("val"), value: "\u{220F}" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("sub"),
        attributes: [],
        children: [mk_text("i=1")],
      }),
      @xml.Node::Element({
        name: name("sup"),
        attributes: [],
        children: [mk_text("n")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(nary)],
  })
  let html = render_html(math)
  // The operator U+220F (∏ product) MUST appear.
  assert_true(html.contains("\u{220F}"))
  assert_true(html.contains("<munderover>"))
  // Default ∑ when @chr is absent.
  let nary_default : @xml.Element = {
    name: name("nary"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sub"),
        attributes: [],
        children: [mk_text("i")],
      }),
      @xml.Node::Element({
        name: name("sup"),
        attributes: [],
        children: [mk_text("n")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let math2 = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(nary_default)],
  })
  let html2 = render_html(math2)
  assert_true(html2.contains("\u{2211}"))
}

///|
/// §22.1.2.81 phant — phantom space.  Maps to MathML <mphantom>
/// so layout reserves space without rendering ink.
test "Office Math viewer §22.1.2.81 phant emits mphantom" {
  let phant : @xml.Element = {
    name: name("phant"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("r"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("t"),
            attributes: [],
            children: [@xml.Node::Text("x")],
          }),
        ],
      }),
    ],
  }
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(phant)],
  })
  let html = render_html(math)
  assert_true(html.contains("<mphantom>"))
}

///|
/// §22.1.2.99 sPre — pre-script pair.  Maps to MathML
/// <mmultiscripts> with <mprescripts/> separator.
test "Office Math viewer §22.1.2.99 sPre emits mmultiscripts with mprescripts" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let s_pre : @xml.Element = {
    name: name("sPre"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sub"),
        attributes: [],
        children: [mk_text("a")],
      }),
      @xml.Node::Element({
        name: name("sup"),
        attributes: [],
        children: [mk_text("b")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("X")],
      }),
    ],
  }
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(s_pre)],
  })
  let html = render_html(math)
  assert_true(html.contains("<mmultiscripts>"))
  assert_true(html.contains("<mprescripts/>"))
}

///|
/// §22.1.2.80 naryPr/@subHide & @supHide — hidden bounds MUST NOT
/// render.  subHide → <mover> (only upper); supHide → <munder>
/// (only lower); both → bare <mo>.
test "Office Math viewer §22.1.2.80 nary subHide/supHide drop bounds" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let mk_nary = fn(sub_hide : Bool, sup_hide : Bool) -> @xml.Element {
    let pr_children : Array[@xml.Node] = []
    if sub_hide {
      pr_children.push(@xml.Node::Element({
        name: name("subHide"),
        attributes: [{ name: name("val"), value: "1" }],
        children: [],
      }))
    }
    if sup_hide {
      pr_children.push(@xml.Node::Element({
        name: name("supHide"),
        attributes: [{ name: name("val"), value: "1" }],
        children: [],
      }))
    }
    {
      name: name("nary"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("naryPr"),
          attributes: [],
          children: pr_children,
        }),
        @xml.Node::Element({
          name: name("sub"),
          attributes: [],
          children: [mk_text("lo")],
        }),
        @xml.Node::Element({
          name: name("sup"),
          attributes: [],
          children: [mk_text("hi")],
        }),
        @xml.Node::Element({
          name: name("e"),
          attributes: [],
          children: [mk_text("x")],
        }),
      ],
    }
  }
  // subHide → <mover>, "lo" gone.
  let h1 = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_nary(true, false))],
  }))
  assert_true(h1.contains("<mover>"))
  assert_false(h1.contains("lo"))
  assert_true(h1.contains("hi"))
  // supHide → <munder>, "hi" gone.
  let h2 = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_nary(false, true))],
  }))
  assert_true(h2.contains("<munder>"))
  assert_false(h2.contains("hi"))
  assert_true(h2.contains("lo"))
}

///|
/// §22.1.2.90 radPr/degHide — square root (<msqrt>) vs nth-root
/// (<mroot> with the degree index).
test "Office Math viewer §22.1.2.90 rad degHide selects msqrt vs mroot" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  // degHide="1" → <msqrt>.
  let sqrt_rad : @xml.Element = {
    name: name("rad"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("radPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("degHide"),
            attributes: [{ name: name("val"), value: "1" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let h1 = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(sqrt_rad)],
  }))
  assert_true(h1.contains("<msqrt>"))
  assert_false(h1.contains("<mroot>"))
  // No degHide + non-empty <m:deg> → <mroot>.
  let nth_rad : @xml.Element = {
    name: name("rad"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("deg"),
        attributes: [],
        children: [mk_text("3")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let h2 = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(nth_rad)],
  }))
  assert_true(h2.contains("<mroot>"))
}

///|
/// §22.1.2.52 groupChrPr/pos — pos="bot" places the group char
/// below the base (<munder>); pos="top" places it above (<mover>).
test "Office Math viewer §22.1.2.52 groupChr pos selects mover vs munder" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let mk_group = fn(pos : String) -> @xml.Element {
    {
      name: name("groupChr"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("groupChrPr"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("pos"),
              attributes: [{ name: name("val"), value: pos }],
              children: [],
            }),
          ],
        }),
        @xml.Node::Element({
          name: name("e"),
          attributes: [],
          children: [mk_text("ab")],
        }),
      ],
    }
  }
  let h_top = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_group("top"))],
  }))
  assert_true(h_top.contains("<mover>"))
  let h_bot = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_group("bot"))],
  }))
  assert_true(h_bot.contains("<munder>"))
}

///|
/// §22.1.2.66 eqArr + §22.1.2.35 eqArrPr — equation array: each
/// <m:e> is a ROW (→ <mtr><mtd>); baseJc surfaces as <mtable>
/// @align; rSp surfaces as data-ooxml-eqarr-rsp.
test "Office Math viewer §22.1.2.66 eqArr emits rows + baseJc/rSp" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let eq_arr : @xml.Element = {
    name: name("eqArr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("eqArrPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("baseJc"),
            attributes: [{ name: name("val"), value: "center" }],
            children: [],
          }),
          @xml.Node::Element({
            name: name("rSp"),
            attributes: [{ name: name("val"), value: "1440" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("row1")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("row2")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(eq_arr)],
  }))
  // Each <m:e> wraps in <mtr><mtd>.
  assert_true(html.contains("<mtr><mtd>"))
  assert_true(html.contains("row1"))
  assert_true(html.contains("row2"))
  // baseJc → align attribute.
  assert_true(html.contains("align=\"center\""))
  // rSp surfaces.
  assert_true(html.contains("data-ooxml-eqarr-rsp=\"1440\""))
}

///|
/// §22.1.2.82 phantPr — `<m:show val="1">` makes the phantom
/// content VISIBLE while `<m:zeroWid>` etc. zero its box.  The
/// renderer MUST emit `<mpadded>` (content visible) rather than
/// `<mphantom>` (content hidden) in that case.
test "Office Math viewer §22.1.2.82 phant show=1 emits mpadded not mphantom" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let phant : @xml.Element = {
    name: name("phant"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("phantPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("show"),
            attributes: [{ name: name("val"), value: "1" }],
            children: [],
          }),
          @xml.Node::Element({
            name: name("zeroWid"),
            attributes: [{ name: name("val"), value: "1" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("y")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(phant)],
  }))
  // show="1" → content visible via <mpadded>, NOT <mphantom>.
  assert_true(html.contains("<mpadded"))
  assert_false(html.contains("<mphantom>"))
  // zeroWid → width="0".
  assert_true(html.contains("width=\"0\""))
  // The content "y" is rendered (not phantomed away).
  assert_true(html.contains("y"))
}

///|
/// §22.1.2.42 func — a function-apply node inserts the invisible
/// U+2061 FUNCTION APPLICATION operator between the function name
/// and its argument.
test "Office Math viewer §22.1.2.42 func emits ApplyFunction operator" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let func : @xml.Element = {
    name: name("func"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("fName"),
        attributes: [],
        children: [mk_text("sin")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(func)],
  }))
  // The ApplyFunction operator U+2061 sits between fName and arg.
  assert_true(html.contains("\u{2061}"))
  assert_true(html.contains("sin"))
  assert_true(html.contains("x"))
}

///|
/// §22.1.2.4 acc + §22.1.2.24 accPr/chr — the accent glyph MUST
/// render in the <mover> second slot; the @chr override wins,
/// and the default is U+0302 circumflex.
test "Office Math viewer §22.1.2.4 acc renders accent glyph" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  // Explicit accent char U+2192 (rightwards arrow — vector accent).
  let acc : @xml.Element = {
    name: name("acc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("accPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("chr"),
            attributes: [{ name: name("val"), value: "\u{2192}" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("v")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(acc)],
  }))
  assert_true(html.contains("<mover accent=\"true\">"))
  assert_true(html.contains("\u{2192}"))
  assert_true(html.contains("v"))
  // No accPr → default U+0302 circumflex.
  let acc_default : @xml.Element = {
    name: name("acc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let html2 = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(acc_default)],
  }))
  assert_true(html2.contains("\u{0302}"))
}

///|
/// §22.1.2.94 scr + §22.1.2.111 sty — an OMML run's script /
/// style MUST map to a MathML `mathvariant` wrapper.
test "Office Math viewer §22.1.2.94 run scr/sty maps to mathvariant" {
  let mk_run = fn(scr : String, sty : String) -> @xml.Element {
    let rpr_children : Array[@xml.Node] = []
    if scr != "" {
      rpr_children.push(@xml.Node::Element({
        name: name("scr"),
        attributes: [{ name: name("val"), value: scr }],
        children: [],
      }))
    }
    if sty != "" {
      rpr_children.push(@xml.Node::Element({
        name: name("sty"),
        attributes: [{ name: name("val"), value: sty }],
        children: [],
      }))
    }
    {
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("rPr"),
          attributes: [],
          children: rpr_children,
        }),
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text("Z")],
        }),
      ],
    }
  }
  // double-struck → mathvariant="double-struck".
  let h1 = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_run("double-struck", ""))],
  }))
  assert_true(h1.contains("mathvariant=\"double-struck\""))
  // script + b → bold-script.
  let h2 = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_run("script", "b"))],
  }))
  assert_true(h2.contains("mathvariant=\"bold-script\""))
  // roman + b → bold.
  let h3 = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_run("roman", "b"))],
  }))
  assert_true(h3.contains("mathvariant=\"bold\""))
}

///|
/// §22.1.2.118 fPr/type — fraction type controls the rendered
/// form: `noBar` → mfrac linethickness="0"; `lin` → inline `/`.
test "Office Math viewer §22.1.2.118 fraction type noBar/lin" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let mk_frac = fn(ty : String) -> @xml.Element {
    {
      name: name("f"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("fPr"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("type"),
              attributes: [{ name: name("val"), value: ty }],
              children: [],
            }),
          ],
        }),
        @xml.Node::Element({
          name: name("num"),
          attributes: [],
          children: [mk_text("a")],
        }),
        @xml.Node::Element({
          name: name("den"),
          attributes: [],
          children: [mk_text("b")],
        }),
      ],
    }
  }
  // noBar → linethickness="0".
  let h_nobar = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_frac("noBar"))],
  }))
  assert_true(h_nobar.contains("linethickness=\"0\""))
  // lin → inline slash, no <mfrac>.
  let h_lin = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_frac("lin"))],
  }))
  assert_true(h_lin.contains("<mo>/</mo>"))
  assert_false(h_lin.contains("<mfrac>"))
}

///|
/// §22.1.2.52 limLoc — n-ary with `limLoc="subSup"` attaches the
/// bounds as scripts (`<msubsup>`) instead of under/over
/// (`<munderover>`).
test "Office Math viewer §22.1.2.52 nary limLoc subSup uses scripts" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let nary : @xml.Element = {
    name: name("nary"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("naryPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("limLoc"),
            attributes: [{ name: name("val"), value: "subSup" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("sub"),
        attributes: [],
        children: [mk_text("0")],
      }),
      @xml.Node::Element({
        name: name("sup"),
        attributes: [],
        children: [mk_text("n")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(nary)],
  }))
  // subSup → <msubsup>, NOT <munderover>.
  assert_true(html.contains("<msubsup>"))
  assert_false(html.contains("<munderover>"))
}

///|
/// §22.1.2.9 barPr/pos — bar accent below the base when
/// `pos="bot"` (→ <munder>) instead of above (→ <mover>).
test "Office Math viewer §22.1.2.9 bar pos selects mover vs munder" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let mk_bar = fn(pos : String) -> @xml.Element {
    {
      name: name("bar"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("barPr"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("pos"),
              attributes: [{ name: name("val"), value: pos }],
              children: [],
            }),
          ],
        }),
        @xml.Node::Element({
          name: name("e"),
          attributes: [],
          children: [mk_text("x")],
        }),
      ],
    }
  }
  let h_top = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_bar("top"))],
  }))
  assert_true(h_top.contains("<mover>"))
  let h_bot = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(mk_bar("bot"))],
  }))
  assert_true(h_bot.contains("<munder>"))
}

///|
/// §22.1.2.13 borderBoxPr — hide flags suppress individual
/// `<menclose>` edges; strike flags add strike notation.
test "Office Math viewer §22.1.2.13 borderBox hide/strike flags" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  // Hide top + bottom, add a horizontal strike → notation should
  // contain "left right horizontalstrike" but not "top"/"bottom".
  let bb : @xml.Element = {
    name: name("borderBox"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("borderBoxPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("hideTop"),
            attributes: [{ name: name("val"), value: "1" }],
            children: [],
          }),
          @xml.Node::Element({
            name: name("hideBot"),
            attributes: [{ name: name("val"), value: "1" }],
            children: [],
          }),
          @xml.Node::Element({
            name: name("strikeH"),
            attributes: [{ name: name("val"), value: "1" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("y")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(bb)],
  }))
  assert_true(html.contains("horizontalstrike"))
  assert_true(html.contains("left"))
  assert_true(html.contains("right"))
  // top / bottom edges are hidden.
  assert_false(html.contains("notation=\"top"))
}

///|
/// §22.1.2.67 mcs/mcJc — matrix column justification becomes
/// MathML `columnalign` on the <mtable>.
test "Office Math viewer §22.1.2.67 matrix mcs maps to columnalign" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  // <m:mPr><m:mcs><m:mc><m:mcPr><m:count val="2"/><m:mcJc val="left"/>
  let mcs : @xml.Node = @xml.Node::Element({
    name: name("mcs"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("mc"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("mcPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("count"),
                attributes: [{ name: name("val"), value: "2" }],
                children: [],
              }),
              @xml.Node::Element({
                name: name("mcJc"),
                attributes: [{ name: name("val"), value: "left" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let mr : @xml.Node = @xml.Node::Element({
    name: name("mr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("a")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("b")],
      }),
    ],
  })
  let matrix : @xml.Element = {
    name: name("m"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("mPr"),
        attributes: [],
        children: [mcs],
      }),
      mr,
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(matrix)],
  }))
  // count=2 + mcJc=left → columnalign="left left".
  assert_true(html.contains("columnalign=\"left left\""))
}

///|
/// §22.1.2.31 d — a delimiter with no dPr uses the spec-default
/// `(` / `)` brackets and emits a well-formed <mfenced> whose
/// argument is wrapped in <mrow> (NOT <mtd> — the generic <m:e>
/// must not be treated as a matrix cell here).
test "Office Math viewer §22.1.2.31 d default brackets" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let delim : @xml.Element = {
    name: name("d"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(delim)],
  }))
  assert_true(html.contains("open=\"(\""))
  assert_true(html.contains("close=\")\""))
  // The argument is an <mrow>, never an <mtd> outside a matrix.
  assert_false(html.contains("<mtd>"))
}

///|
/// §22.1.2.32 dPr — begChr / endChr / sepChr override the bracket
/// and separator glyphs; two <m:e> arguments are joined by the
/// custom separator.
test "Office Math viewer §22.1.2.32 dPr begChr/endChr/sepChr" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let d_pr : @xml.Node = @xml.Node::Element({
    name: name("dPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("begChr"),
        attributes: [{ name: name("val"), value: "[" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("endChr"),
        attributes: [{ name: name("val"), value: "]" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("sepChr"),
        attributes: [{ name: name("val"), value: ";" }],
        children: [],
      }),
    ],
  })
  let delim : @xml.Element = {
    name: name("d"),
    attributes: [],
    children: [
      d_pr,
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("a")],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("b")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(delim)],
  }))
  // Custom bracket + separator glyphs surface on the <mfenced>.
  assert_true(html.contains("open=\"[\""))
  assert_true(html.contains("close=\"]\""))
  assert_true(html.contains("separators=\";\""))
  assert_true(html.contains("a"))
  assert_true(html.contains("b"))
}

///|
/// §22.1.2.20 m:box — the box is a grouping container, NOT a
/// bordered frame (the frame is §22.1.2.12 m:borderBox).  The
/// output must be a plain <mrow>, never <menclose>, and the inner
/// <m:e> must render as <mrow> (not <mtd> — that is matrix-cell
/// only).
test "Office Math viewer §22.1.2.20 box renders borderless mrow" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let box : @xml.Element = {
    name: name("box"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("x")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(box)],
  }))
  // m:box must NOT draw a border.
  assert_false(html.contains("menclose"))
  // The inner <m:e> is a grouping <mrow>, never a matrix cell.
  assert_false(html.contains("<mtd>"))
  assert_true(html.contains("<mrow>"))
  assert_true(html.contains("x"))
}

///|
/// §22.1.2.7 boxPr — `brk` emits an MathML <mspace
/// linebreak="newline">; `aln` emits <malignmark>.  `opEmu` and
/// `noBreak` have no MathML realisation and are surfaced as
/// data-ooxml-box-* attributes.
test "Office Math viewer §22.1.2.7 boxPr brk/aln/opEmu" {
  let mk_text = fn(text : String) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text(text)],
        }),
      ],
    })
  }
  let box_pr : @xml.Node = @xml.Node::Element({
    name: name("boxPr"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("brk"),
        attributes: [],
        children: [],
      }),
      @xml.Node::Element({
        name: name("aln"),
        attributes: [],
        children: [],
      }),
      @xml.Node::Element({
        name: name("opEmu"),
        attributes: [],
        children: [],
      }),
    ],
  })
  let box : @xml.Element = {
    name: name("box"),
    attributes: [],
    children: [
      box_pr,
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [mk_text("y")],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(box)],
  }))
  // brk → MathML newline; aln → alignment mark.
  assert_true(html.contains("linebreak=\"newline\""))
  assert_true(html.contains("malignmark"))
  // opEmu has no MathML form — surfaced as a spec attribute.
  assert_true(html.contains("data-ooxml-box-opemu=\"1\""))
}

///|
/// The renderer builds a structured node tree and serialises it
/// through @xml.escape_*; markup inside an <m:t> text run or an
/// <m:chr> attribute can never break out of its context.
test "Office Math viewer escapes markup in text and attributes" {
  // A text run carrying an XML-significant payload.
  let run : @xml.Node = @xml.Node::Element({
    name: name("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("a < b & \"c\" > d")],
      }),
    ],
  })
  // An accent whose @chr glyph carries a double-quote — it lands
  // in a MathML attribute slot at one point and as text at
  // another; either way it must be escaped.
  let acc : @xml.Element = {
    name: name("acc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("accPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("chr"),
            attributes: [{ name: name("val"), value: "\"><script>" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("e"),
        attributes: [],
        children: [run],
      }),
    ],
  }
  let html = render_html(@domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [@xml.Node::Element(acc)],
  }))
  // The literal text payload must be entity-escaped: `<` and `&`
  // become entity refs (XML 1.0 §2.4 / `@xml.escape_text` — `>`
  // is left verbatim, which is well-formed in text content).
  assert_true(html.contains("a &lt; b &amp; \"c\" > d"))
  assert_false(html.contains("a < b & \"c\" > d"))
  // The injected `<script>` sequence must NOT survive as live
  // markup — the `<` is escaped wherever the glyph is emitted.
  assert_false(html.contains("<script>"))
}
