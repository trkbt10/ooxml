///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
/// Index of the first occurrence of `needle` in `haystack` at or
/// after `from`, or None.
fn find_from(haystack : String, needle : String, from : Int) -> Int? {
  let hn = haystack.length()
  let nn = needle.length()
  if nn == 0 {
    return Some(from)
  }
  let mut i = from
  while i + nn <= hn {
    let mut j = 0
    while j < nn && haystack.code_unit_at(i + j) == needle.code_unit_at(j) {
      j = j + 1
    }
    if j == nn {
      return Some(i)
    }
    i = i + 1
  }
  None
}

///|
/// Concatenate the text content of every `<text>` element in an SVG
/// string.  The SVG renderer lays a run out into one `<text>` per
/// glyph segment, so a logical word is split across several
/// elements; this helper rejoins them so a test can assert on the
/// rendered text without depending on element boundaries.
fn svg_text_content(svg : String) -> String {
  let out = StringBuilder::new()
  let mut i = 0
  let n = svg.length()
  while i < n {
    match find_from(svg, "<text", i) {
      None => break
      Some(tag_start) =>
        match find_from(svg, ">", tag_start) {
          None => break
          Some(gt) => {
            let content_start = gt + 1
            match find_from(svg, "</text>", content_start) {
              None => break
              Some(close) => {
                out.write_string(svg[content_start:close].to_owned())
                i = close + 7
              }
            }
          }
        }
    }
  }
  out.to_string()
}

///|
test "PresentationML viewer renders slide text" {
  // §19.3.1.x — a slide carries its shapes under <cSld>/<spTree>;
  // a shape's text lives in <txBody>/<p>/<r>/<t>.
  let run : @xml.Node = @xml.Node::Element({
    name: name("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("Title")],
      }),
    ],
  })
  let sp : @xml.Node = @xml.Node::Element({
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bodyPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [run],
          }),
        ],
      }),
    ],
  })
  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: [sp],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(slide)
  assert_true(svg.contains("<svg "))
  assert_true(svg.contains("data-ooxml=\"pml\""))
  // The renderer splits a run into per-glyph <text> elements;
  // verify the rejoined rendered text carries the slide content.
  assert_true(svg_text_content(svg).contains("Title"))
}

///|
/// §19.3.1.4 — `<p:bgRef>` with an inline `<a:srgbClr>` resolves to a
/// solid-fill background `<rect>` in the SVG output. The first phase
/// only resolves the explicit child color; the fmtScheme inheritance
/// pipeline (linking `@idx` to `<a:bgFillStyleLst>` / `phClr`) is
/// tracked by a follow-up theme-context wiring.
test "viewer §19.3.1.4 bgRef child srgbClr surfaces as solid background" {
  let bg_ref : @xml.Node = @xml.Node::Element({
    name: name("bgRef"),
    attributes: [{ name: name("idx"), value: "1001" }],
    children: [
      @xml.Node::Element({
        name: name("srgbClr"),
        attributes: [{ name: name("val"), value: "FF8800" }],
        children: [],
      }),
    ],
  })
  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bg"),
            attributes: [],
            children: [bg_ref],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(slide)
  // The synthetic `<a:solidFill>` wrapper feeds the color into the
  // standard fill pipeline, which emits a lowercase hex literal.
  assert_true(svg.contains("fill=\"#ff8800\""))
}

///|
/// §21.1.2.3.5 — a `<a:r>` whose `<a:rPr>` carries `<a:hlinkClick>`
/// renders the text wrapped in an `<a xlink:href="…">` anchor so the
/// browser can navigate to the link target. Mirrors web-pptx
/// slide-text.ts `wrapTextWithLinks` behaviour.
test "viewer §21.1.2.3.5 hlinkClick run emits xlink anchor" {
  let r : @xml.Node = @xml.Node::Element({
    name: name("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("rPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("hlinkClick"),
            attributes: [{ name: name("id"), value: "rId7" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("link")],
      }),
    ],
  })
  let sp : @xml.Node = @xml.Node::Element({
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xfrm"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("off"),
                attributes: [
                  { name: name("x"), value: "0" },
                  { name: name("y"), value: "0" },
                ],
                children: [],
              }),
              @xml.Node::Element({
                name: name("ext"),
                attributes: [
                  { name: name("cx"), value: "914400" },
                  { name: name("cy"), value: "457200" },
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bodyPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({ name: name("p"), attributes: [], children: [r] }),
        ],
      }),
    ],
  })
  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: [sp],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(slide)
  assert_true(svg.contains("xlink:href=\"rId7\""))
  // §21.1.2.3.5 — the raw r:id MUST also surface as data-ooxml-r-id
  // so consumers can apply the slide-rels lookup themselves.
  assert_true(svg.contains("data-ooxml-r-id=\"rId7\""))
  assert_true(svg.contains("</a>"))
}

///|
/// §21.1.2.3.32 + §21.1.2.3.28 — a run with both `u="sng"` and
/// `strike="sngStrike"` emits:
///   • `text-decoration="line-through"` on the `<text>` element
///     (the strikethrough is still drawn by librsvg / Pango at
///     the font's mid-glyph height, which matches the reference
///     renderer closely);
///   • an explicit `<line>` overlay for the underline at the
///     reference-matched offset (≈0.155 em below baseline) — see
///     `build_underline_overlay` for the why; the legacy
///     `text-decoration="underline"` shorthand was dropped because
///     librsvg placed the line 2-3 px above the reference PDF for
///     the body-face substitute the harness uses.
test "viewer u + strike combine: strike via CSS, underline via overlay" {
  fn run_with(rpr_attrs : Array[@xml.Attribute]) -> @xml.Node {
    @xml.Node::Element({
      name: name("r"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("rPr"),
          attributes: rpr_attrs,
          children: [],
        }),
        @xml.Node::Element({
          name: name("t"),
          attributes: [],
          children: [@xml.Node::Text("X")],
        }),
      ],
    })
  }

  let sp_with = fn(rpr_attrs : Array[@xml.Attribute]) -> @xml.Node {
    @xml.Node::Element({
      name: name("sp"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("spPr"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("xfrm"),
              attributes: [],
              children: [
                @xml.Node::Element({
                  name: name("off"),
                  attributes: [
                    { name: name("x"), value: "0" },
                    { name: name("y"), value: "0" },
                  ],
                  children: [],
                }),
                @xml.Node::Element({
                  name: name("ext"),
                  attributes: [
                    { name: name("cx"), value: "914400" },
                    { name: name("cy"), value: "457200" },
                  ],
                  children: [],
                }),
              ],
            }),
          ],
        }),
        @xml.Node::Element({
          name: name("txBody"),
          attributes: [],
          children: [
            @xml.Node::Element({
              name: name("bodyPr"),
              attributes: [],
              children: [],
            }),
            @xml.Node::Element({
              name: name("p"),
              attributes: [],
              children: [run_with(rpr_attrs)],
            }),
          ],
        }),
      ],
    })
  }

  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: [
              sp_with([
                { name: name("u"), value: "sng" },
                { name: name("strike"), value: "sngStrike" },
              ]),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(slide)
  // Strike kept as CSS text-decoration (librsvg renders it OK).
  assert_true(svg.contains("text-decoration=\"line-through\""))
  // Underline is drawn as an explicit `<line>` overlay.
  assert_true(svg.contains("<line"))
  // The compound `underline line-through` shorthand is NO LONGER
  // emitted — the explicit overlay replaces the underline half.
  assert_true(!svg.contains("underline line-through"))
}

///|
/// Helper for the bodyPr-transform tests below — builds a minimal slide
/// containing a single `<p:sp>` with the supplied `<a:bodyPr>`
/// attributes plus a one-character run so the text pipeline has
/// content to wrap.
fn sp_with_bodypr_attrs(
  body_pr_attrs : Array[@xml.Attribute],
) -> @domain.CT_Slide {
  let body_pr : @xml.Node = @xml.Node::Element({
    name: name("bodyPr"),
    attributes: body_pr_attrs,
    children: [],
  })
  let run : @xml.Node = @xml.Node::Element({
    name: name("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("X")],
      }),
    ],
  })
  let sp : @xml.Node = @xml.Node::Element({
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xfrm"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("off"),
                attributes: [
                  { name: name("x"), value: "0" },
                  { name: name("y"), value: "0" },
                ],
                children: [],
              }),
              @xml.Node::Element({
                name: name("ext"),
                attributes: [
                  { name: name("cx"), value: "914400" },
                  { name: name("cy"), value: "457200" },
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          body_pr,
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [run],
          }),
        ],
      }),
    ],
  })
  @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: [sp],
          }),
        ],
      }),
    ],
  })
}

///|
/// §21.1.2.1.7 `<a:bodyPr rot="…">` — body rotation wraps the text in a
/// `<g transform="rotate(deg, cx, cy)">`. 5400000 = 90°.
test "viewer §21.1.2.1.7 bodyPr rot wraps text in rotate()" {
  let slide = sp_with_bodypr_attrs([{ name: name("rot"), value: "5400000" }])
  let svg = render_svg(slide)
  // 90° → rotate(90, cx, cy). Both box width and height are scaled
  // from EMU (914400×457200) divided by 9525.
  assert_true(svg.contains("rotate(90"))
}

///|
/// §21.1.2.1.7 `<a:bodyPr vert="vert">` — 90° clockwise vertical text
/// uses a `translate(boxWidth, 0) rotate(90)` transform.
test "viewer §21.1.2.1.7 bodyPr vert=vert translates + rotates" {
  let slide = sp_with_bodypr_attrs([{ name: name("vert"), value: "vert" }])
  let svg = render_svg(slide)
  assert_true(svg.contains("rotate(90)"))
}

///|
/// §21.1.2.1.7 `<a:bodyPr horzOverflow="clip">` — emits a `<clipPath>`
/// def and wraps the text in `<g clip-path="url(#…)">`.
test "viewer §21.1.2.1.7 bodyPr horzOverflow=clip emits clipPath" {
  let slide = sp_with_bodypr_attrs([
    { name: name("horzOverflow"), value: "clip" },
  ])
  let svg = render_svg(slide)
  assert_true(svg.contains("<clipPath"))
  assert_true(svg.contains("clip-path=\"url(#"))
}

///|
/// §21.1.2.1.7 `<a:bodyPr forceAA="1">` — wraps the text in
/// `<g text-rendering="geometricPrecision">`.
test "viewer §21.1.2.1.7 bodyPr forceAA=1 sets text-rendering" {
  let slide = sp_with_bodypr_attrs([{ name: name("forceAA"), value: "1" }])
  let svg = render_svg(slide)
  assert_true(svg.contains("text-rendering=\"geometricPrecision\""))
}

///|
/// §19.3.1.4 + §20.1.4.1.7 — `<p:bgRef idx="1001">` resolves to the
/// first entry of `<a:bgFillStyleLst>` from the supplied theme. The
/// child color of `<p:bgRef>` substitutes for any `<a:schemeClr
/// val="phClr">` token inside the template, so a theme with a
/// `<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>` entry and
/// a slide-side override of `<a:srgbClr val="00AA00"/>` emits
/// `fill="#00aa00"` on the background rect.
test "viewer §19.3.1.4 bgRef idx=1001 + theme bgFillStyleLst[0] resolves phClr" {
  // Minimal §20.1.6 theme whose `bgFillStyleLst[0]` is a
  // `<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>` template
  // — the rest of the fmtScheme uses `<a:noFill/>` / empty `<a:ln/>`
  // placeholders to satisfy minOccurs=3 on each list.
  let prefix = "<a:theme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:themeElements>"
  let clr = "<a:clrScheme name=\"Office\">" +
    "<a:dk1><a:srgbClr val=\"000000\"/></a:dk1>" +
    "<a:lt1><a:srgbClr val=\"FFFFFF\"/></a:lt1>" +
    "<a:dk2><a:srgbClr val=\"000000\"/></a:dk2>" +
    "<a:lt2><a:srgbClr val=\"FFFFFF\"/></a:lt2>" +
    "<a:accent1><a:srgbClr val=\"FF0000\"/></a:accent1>" +
    "<a:accent2><a:srgbClr val=\"00FF00\"/></a:accent2>" +
    "<a:accent3><a:srgbClr val=\"0000FF\"/></a:accent3>" +
    "<a:accent4><a:srgbClr val=\"FFFF00\"/></a:accent4>" +
    "<a:accent5><a:srgbClr val=\"FF00FF\"/></a:accent5>" +
    "<a:accent6><a:srgbClr val=\"00FFFF\"/></a:accent6>" +
    "<a:hlink><a:srgbClr val=\"0000EE\"/></a:hlink>" +
    "<a:folHlink><a:srgbClr val=\"551A8B\"/></a:folHlink>" +
    "</a:clrScheme>"
  let font = "<a:fontScheme name=\"Office\">" +
    "<a:majorFont><a:latin typeface=\"Calibri\"/><a:ea typeface=\"-\"/><a:cs typeface=\"-\"/></a:majorFont>" +
    "<a:minorFont><a:latin typeface=\"Calibri\"/><a:ea typeface=\"-\"/><a:cs typeface=\"-\"/></a:minorFont>" +
    "</a:fontScheme>"
  let fmt = "<a:fmtScheme name=\"Office\">" +
    "<a:fillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:fillStyleLst>" +
    "<a:lnStyleLst><a:ln/><a:ln/><a:ln/></a:lnStyleLst>" +
    "<a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst>" +
    "<a:bgFillStyleLst><a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill><a:noFill/><a:noFill/></a:bgFillStyleLst>" +
    "</a:fmtScheme>"
  let theme_xml = prefix + clr + font + fmt + "</a:themeElements></a:theme>"
  let theme_ok = try? @theme.read_theme(@utf8.encode(theme_xml[:]))
  let theme_ok = match theme_ok {
    Ok(t) => t
    Err(_) => abort("theme construction failed")
  }
  // Slide with `<p:bgRef idx="1001"><a:srgbClr val="00AA00"/></p:bgRef>`.
  let bg_ref : @xml.Node = @xml.Node::Element({
    name: name("bgRef"),
    attributes: [{ name: name("idx"), value: "1001" }],
    children: [
      @xml.Node::Element({
        name: name("srgbClr"),
        attributes: [{ name: name("val"), value: "00AA00" }],
        children: [],
      }),
    ],
  })
  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bg"),
            attributes: [],
            children: [bg_ref],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(slide, theme=Some(theme_ok))
  // The bgFillStyleLst[0] template is `<a:solidFill><a:schemeClr
  // val="phClr"/></a:solidFill>` and the bgRef override is #00AA00,
  // so the rendered background `<rect>` carries fill="#00aa00".
  assert_true(svg.contains("fill=\"#00aa00\""))
}

///|
/// §20.1.4.1.8 — a shape whose `<p:spPr>` declares no `<a:effectLst>`
/// but whose `<p:style>` carries `<a:effectRef idx="2">` resolves
/// the effect through the theme's `<a:effectStyleLst>` entry 2.
/// That entry holds an `<a:outerShdw>`, so the shape's wrapping
/// `<g>` gains a `filter` whose `<filter>` def carries the shadow
/// primitives — exactly the cascade applied to a direct effect.
test "viewer §20.1.4.1.8 effectRef resolves theme effectStyleLst entry" {
  let prefix = "<a:theme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:themeElements>"
  let clr = "<a:clrScheme name=\"Office\">" +
    "<a:dk1><a:srgbClr val=\"000000\"/></a:dk1>" +
    "<a:lt1><a:srgbClr val=\"FFFFFF\"/></a:lt1>" +
    "<a:dk2><a:srgbClr val=\"000000\"/></a:dk2>" +
    "<a:lt2><a:srgbClr val=\"FFFFFF\"/></a:lt2>" +
    "<a:accent1><a:srgbClr val=\"FF0000\"/></a:accent1>" +
    "<a:accent2><a:srgbClr val=\"00FF00\"/></a:accent2>" +
    "<a:accent3><a:srgbClr val=\"0000FF\"/></a:accent3>" +
    "<a:accent4><a:srgbClr val=\"FFFF00\"/></a:accent4>" +
    "<a:accent5><a:srgbClr val=\"FF00FF\"/></a:accent5>" +
    "<a:accent6><a:srgbClr val=\"00FFFF\"/></a:accent6>" +
    "<a:hlink><a:srgbClr val=\"0000EE\"/></a:hlink>" +
    "<a:folHlink><a:srgbClr val=\"551A8B\"/></a:folHlink>" +
    "</a:clrScheme>"
  let font = "<a:fontScheme name=\"Office\">" +
    "<a:majorFont><a:latin typeface=\"Calibri\"/><a:ea typeface=\"-\"/><a:cs typeface=\"-\"/></a:majorFont>" +
    "<a:minorFont><a:latin typeface=\"Calibri\"/><a:ea typeface=\"-\"/><a:cs typeface=\"-\"/></a:minorFont>" +
    "</a:fontScheme>"
  // effectStyleLst entry 2 (idx="2") carries an outerShdw.
  let fmt = "<a:fmtScheme name=\"Office\">" +
    "<a:fillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:fillStyleLst>" +
    "<a:lnStyleLst><a:ln/><a:ln/><a:ln/></a:lnStyleLst>" +
    "<a:effectStyleLst>" +
    "<a:effectStyle><a:effectLst/></a:effectStyle>" +
    "<a:effectStyle><a:effectLst><a:outerShdw blurRad=\"40000\" dist=\"20000\" dir=\"5400000\"><a:srgbClr val=\"000000\"/></a:outerShdw></a:effectLst></a:effectStyle>" +
    "<a:effectStyle><a:effectLst/></a:effectStyle>" +
    "</a:effectStyleLst>" +
    "<a:bgFillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:bgFillStyleLst>" +
    "</a:fmtScheme>"
  let theme_xml = prefix + clr + font + fmt + "</a:themeElements></a:theme>"
  let theme_ok = try @theme.read_theme(@utf8.encode(theme_xml[:])) catch {
    _ => abort("theme construction failed")
  } noraise {
    t => t
  }
  // Shape: spPr has geometry but no effectLst; style has effectRef.
  let sp : @xml.Node = @xml.Node::Element({
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xfrm"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("off"),
                attributes: [
                  { name: name("x"), value: "0" },
                  { name: name("y"), value: "0" },
                ],
                children: [],
              }),
              @xml.Node::Element({
                name: name("ext"),
                attributes: [
                  { name: name("cx"), value: "914400" },
                  { name: name("cy"), value: "457200" },
                ],
                children: [],
              }),
            ],
          }),
          @xml.Node::Element({
            name: name("prstGeom"),
            attributes: [{ name: name("prst"), value: "rect" }],
            children: [
              @xml.Node::Element({
                name: name("avLst"),
                attributes: [],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("style"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("effectRef"),
            attributes: [{ name: name("idx"), value: "2" }],
            children: [
              @xml.Node::Element({
                name: name("schemeClr"),
                attributes: [{ name: name("val"), value: "accent1" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: [sp],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(slide, theme=Some(theme_ok))
  // The theme effectStyleLst[1] outerShdw is applied: a <filter>
  // def with the shadow blur primitive, referenced from the shape.
  assert_true(svg.contains("<filter"))
  assert_true(svg.contains("feGaussianBlur"))
  assert_true(svg.contains("filter=\"url(#"))
}

///|
/// §20.1.10.49 + §20.1.8.57 — a `<p:cxnSp>` whose `<a:ln>` declares
/// `<a:prstDash val="dash"/>` and `<a:tailEnd type="triangle"/>` emits
/// both `stroke-dasharray=…` and `marker-end="url(#…)"` on the path.
test "viewer connector emits prstDash + tailEnd marker" {
  let line_child : @xml.Node = @xml.Node::Element({
    name: name("ln"),
    attributes: [{ name: name("w"), value: "12700" }],
    children: [
      @xml.Node::Element({
        name: name("solidFill"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("srgbClr"),
            attributes: [{ name: name("val"), value: "0000FF" }],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("prstDash"),
        attributes: [{ name: name("val"), value: "dash" }],
        children: [],
      }),
      @xml.Node::Element({
        name: name("tailEnd"),
        attributes: [{ name: name("type"), value: "triangle" }],
        children: [],
      }),
    ],
  })
  let cxn : @xml.Node = @xml.Node::Element({
    name: name("cxnSp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xfrm"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("off"),
                attributes: [
                  { name: name("x"), value: "0" },
                  { name: name("y"), value: "0" },
                ],
                children: [],
              }),
              @xml.Node::Element({
                name: name("ext"),
                attributes: [
                  { name: name("cx"), value: "914400" },
                  { name: name("cy"), value: "457200" },
                ],
                children: [],
              }),
            ],
          }),
          @xml.Node::Element({
            name: name("prstGeom"),
            attributes: [{ name: name("prst"), value: "line" }],
            children: [],
          }),
          line_child,
        ],
      }),
    ],
  })
  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: [cxn],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(slide)
  assert_true(svg.contains("stroke-dasharray="))
  assert_true(svg.contains("marker-end=\"url(#"))
  assert_true(svg.contains("stroke=\"#0000ff\""))
}

///|
/// §19.3.1.16 — a `<p:graphicFrame>` whose `<a:graphic>/<a:graphicData
/// uri=ole/...>` contains a `<p:oleObj><p:pic>` preview is rendered as
/// an `<image>` (mirrors web-pptx renderOleObjectImage). When the
/// supplied `image_resolver` returns a base64 payload the embed id is
/// surfaced inline.
test "viewer §19.3.1.16 OLE preview image surfaces through image_resolver" {
  let pic_inside_ole : @xml.Node = @xml.Node::Element({
    name: name("oleObj"),
    attributes: [{ name: name("progId"), value: "Excel.Sheet.12" }],
    children: [
      @xml.Node::Element({
        name: name("pic"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("blipFill"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("blip"),
                attributes: [{ name: name("embed"), value: "rId42" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let graphic : @xml.Node = @xml.Node::Element({
    name: name("graphic"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("graphicData"),
        attributes: [
          {
            name: name("uri"),
            value: "http://schemas.openxmlformats.org/presentationml/2006/ole",
          },
        ],
        children: [pic_inside_ole],
      }),
    ],
  })
  let frame : @xml.Node = @xml.Node::Element({
    name: name("graphicFrame"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("xfrm"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("off"),
            attributes: [
              { name: name("x"), value: "0" },
              { name: name("y"), value: "0" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("ext"),
            attributes: [
              { name: name("cx"), value: "914400" },
              { name: name("cy"), value: "457200" },
            ],
            children: [],
          }),
        ],
      }),
      graphic,
    ],
  })
  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: [frame],
          }),
        ],
      }),
    ],
  })
  let resolver = fn(rid : String) -> ResolvedImage? {
    if rid == "rId42" {
      Some({ mime_type: "image/png", base64_data: "AAAA" })
    } else {
      None
    }
  }
  let svg = render_svg(slide, image_resolver=resolver)
  assert_true(svg.contains("<image href=\"data:image/png;base64,AAAA\""))
}

///|
/// §19.3.1.36 / §19.3.1.45 — layout-defined title placeholder inherits
/// onto the rendered slide even when the slide has no corresponding
/// `<p:sp>`. The slide here carries only the boilerplate `<p:cSld>/
/// <p:spTree>` skeleton with no shapes; the layout supplies a title
/// placeholder bearing the text "Layout Title", and the master
/// supplies a body placeholder so the chain is well-formed. We assert
/// that "Layout Title" surfaces in the resulting SVG.
test "viewer §19.3.1.36 layout-only placeholder renders via chain" {
  // Build a shape tree skeleton (used by slide / layout / master).
  let title_layout_sp = ph_title_shape(
    "Layout Title",
    x_emu=914400,
    y_emu=914400,
    w_emu=4572000,
    h_emu=914400,
  )
  let body_master_sp = ph_body_shape("Master Body")
  let slide = @domain.CT_Slide::new(empty_slide_like("sld"))
  let layout = @domain.CT_SlideLayout::new(
    slide_like_with_shapes("sldLayout", [title_layout_sp]),
  )
  let master = @domain.CT_SlideMaster::new(
    slide_like_with_shapes("sldMaster", [body_master_sp]),
  )
  let chain = @ph_resolver.SlideChain::from_parts(
    master,
    Some(layout),
    Some(slide),
  )
  let svg = render_svg(slide, chain=Some(chain))
  assert_true(svg.contains("Layout Title"))
}

///|
/// §19.3.1.36 — when a slide-side `<p:sp>` carries `<p:ph idx="0"/>`
/// but has no `<p:spPr>/<a:xfrm>`, the geometry is inherited from the
/// layout placeholder with the matching `idx`. We assert that the
/// inherited transform actually drives the emitted `<g>` wrapper —
/// the layout xfrm width should appear in the rendered SVG.
test "viewer §19.3.1.36 slide ph inherits spPr from layout by idx" {
  let layout_sp : @xml.Element = {
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("nvSpPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("cNvPr"),
            attributes: [
              { name: name("id"), value: "2" },
              { name: name("name"), value: "TitlePh" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("cNvSpPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("nvPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("ph"),
                attributes: [
                  { name: name("type"), value: "title" },
                  { name: name("idx"), value: "0" },
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xfrm"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("off"),
                attributes: [
                  { name: name("x"), value: "457200" },
                  { name: name("y"), value: "457200" },
                ],
                children: [],
              }),
              @xml.Node::Element({
                name: name("ext"),
                attributes: [
                  { name: name("cx"), value: "8229600" },
                  { name: name("cy"), value: "1143000" },
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  }
  let slide_sp : @xml.Element = {
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("nvSpPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("cNvPr"),
            attributes: [
              { name: name("id"), value: "3" },
              { name: name("name"), value: "SlideTitle" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("cNvSpPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("nvPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("ph"),
                attributes: [
                  { name: name("type"), value: "title" },
                  { name: name("idx"), value: "0" },
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
      // No spPr / no xfrm — must inherit from layout.
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bodyPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Slide Title")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  }
  let slide = @domain.CT_Slide::new(slide_like_with_shapes("sld", [slide_sp]))
  let layout = @domain.CT_SlideLayout::new(
    slide_like_with_shapes("sldLayout", [layout_sp]),
  )
  let master = @domain.CT_SlideMaster::new(
    slide_like_with_shapes("sldMaster", []),
  )
  let chain = @ph_resolver.SlideChain::from_parts(
    master,
    Some(layout),
    Some(slide),
  )
  let svg = render_svg(slide, chain=Some(chain))
  assert_true(svg.contains("Slide Title"))
  // Inherited width (8229600 EMU) should drive the rendered geometry —
  // it must show up somewhere in the SVG via translate / scale on
  // either a wrapping <g> or a child element.
  assert_true(svg.contains("8229600") || svg.contains("864"))
}

///|
/// Helper — build a `<p:sld>`-like element with no shape children at
/// all (just the boilerplate `<p:cSld>/<p:spTree>` skeleton). The
/// minimum required content per §19.3.1.45 is a `<p:nvGrpSpPr>` and
/// `<p:grpSpPr>` inside `<p:spTree>`.
fn empty_slide_like(root_local : String) -> @xml.Element {
  slide_like_with_shapes(root_local, [])
}

///|
/// Helper — build a `<p:sld>`-/`<p:sldLayout>`-/`<p:sldMaster>`-like
/// XML element whose `<p:cSld>/<p:spTree>` carries the supplied
/// shapes alongside the minimum required `<p:nvGrpSpPr>` and
/// `<p:grpSpPr>` (§19.3.1.45).
fn slide_like_with_shapes(
  root_local : String,
  shapes : Array[@xml.Element],
) -> @xml.Element {
  let sp_tree_children : Array[@xml.Node] = [
    @xml.Node::Element({
      name: name("nvGrpSpPr"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name("cNvPr"),
          attributes: [
            { name: name("id"), value: "1" },
            { name: name("name"), value: "" },
          ],
          children: [],
        }),
        @xml.Node::Element({
          name: name("cNvGrpSpPr"),
          attributes: [],
          children: [],
        }),
        @xml.Node::Element({ name: name("nvPr"), attributes: [], children: [] }),
      ],
    }),
    @xml.Node::Element({ name: name("grpSpPr"), attributes: [], children: [] }),
  ]
  for s in shapes {
    sp_tree_children.push(@xml.Node::Element(s))
  }
  {
    name: name(root_local),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("cSld"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("spTree"),
            attributes: [],
            children: sp_tree_children,
          }),
        ],
      }),
    ],
  }
}

///|
/// Helper — a `<p:sp>` carrying `<p:ph type="title">` and a `<a:t>`
/// with `text`. Supplies an `<a:xfrm>` so the rendered shape has a
/// position the SVG engine can use.
fn ph_title_shape(
  text : String,
  x_emu? : Int = 0,
  y_emu? : Int = 0,
  w_emu? : Int = 8229600,
  h_emu? : Int = 1143000,
) -> @xml.Element {
  {
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("nvSpPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("cNvPr"),
            attributes: [
              { name: name("id"), value: "2" },
              { name: name("name"), value: "Title" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("cNvSpPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("nvPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("ph"),
                attributes: [{ name: name("type"), value: "title" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xfrm"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("off"),
                attributes: [
                  { name: name("x"), value: x_emu.to_string() },
                  { name: name("y"), value: y_emu.to_string() },
                ],
                children: [],
              }),
              @xml.Node::Element({
                name: name("ext"),
                attributes: [
                  { name: name("cx"), value: w_emu.to_string() },
                  { name: name("cy"), value: h_emu.to_string() },
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bodyPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
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
              }),
            ],
          }),
        ],
      }),
    ],
  }
}

///|
/// Helper — a `<p:sp>` carrying `<p:ph type="body">` and a `<a:t>`
/// with `text`. Used as a stand-in master body placeholder so the
/// layout-only-title resolution test has a non-empty master.
fn ph_body_shape(text : String) -> @xml.Element {
  {
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("nvSpPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("cNvPr"),
            attributes: [
              { name: name("id"), value: "3" },
              { name: name("name"), value: "Body" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("cNvSpPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("nvPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("ph"),
                attributes: [{ name: name("type"), value: "body" }],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("spPr"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("xfrm"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("off"),
                attributes: [
                  { name: name("x"), value: "0" },
                  { name: name("y"), value: "0" },
                ],
                children: [],
              }),
              @xml.Node::Element({
                name: name("ext"),
                attributes: [
                  { name: name("cx"), value: "1000000" },
                  { name: name("cy"), value: "1000000" },
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bodyPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
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
              }),
            ],
          }),
        ],
      }),
    ],
  }
}

///|
/// §21.1.2.3.18 cap="all" — the upper-case mapper must preserve
/// non-ASCII code points (no surrogate-pair shredding) and fold
/// the Latin-1 / Latin Extended-A ranges spec-correctly.
test "to_upper_ascii preserves non-ASCII and folds Latin-1" {
  inspect(to_upper_ascii("abc"), content="ABC")
  inspect(to_upper_ascii("àéîõü"), content="ÀÉÎÕÜ")
  inspect(to_upper_ascii("ā"), content="Ā")
  inspect(to_upper_ascii("ÿ"), content="Ÿ")
  // ß (U+00DF) intentionally untouched per locale-defined folding.
  inspect(to_upper_ascii("ß"), content="ß")
  inspect(to_upper_ascii("日本語"), content="日本語")
  inspect(to_upper_ascii("あア한"), content="あア한")
  // Supplementary plane code point survives code-point iteration.
  inspect(to_upper_ascii("😀"), content="😀")
}

///|
/// §21.1.2.3.18 cap — lowercase counterpart mirror.
test "to_lower_ascii preserves non-ASCII and folds Latin-1" {
  inspect(to_lower_ascii("ABC"), content="abc")
  inspect(to_lower_ascii("ÀÉÎÕÜ"), content="àéîõü")
  inspect(to_lower_ascii("Ā"), content="ā")
  inspect(to_lower_ascii("Ÿ"), content="ÿ")
  inspect(to_lower_ascii("日本語"), content="日本語")
  inspect(to_lower_ascii("😀"), content="😀")
}

///|
/// §19.5.50 `<p:transition>` — `render_svg` must surface every
/// transition attribute as `data-ooxml-transition*` so consumers
/// can drive animation.
test "viewer §19.5.50 slide transition surfaces data attributes" {
  // Build the minimum spec-required slide subtree.
  //   <p:sld>
  //     <p:cSld>
  //       <p:spTree>
  //         <p:nvGrpSpPr><p:cNvPr id="1" name=""/>
  //                       <p:cNvGrpSpPr/>
  //                       <p:nvPr/></p:nvGrpSpPr>
  //         <p:grpSpPr/>
  //       </p:spTree>
  //     </p:cSld>
  //     <p:transition spd="fast" advClick="1"><p:fade/></p:transition>
  //   </p:sld>
  let elem : (String, Array[@xml.Attribute], Array[@xml.Node]) -> @xml.Element = fn(
    local_name,
    attrs,
    children,
  ) {
    { name: name(local_name), attributes: attrs, children }
  }
  let c_nv_pr = elem(
    "cNvPr",
    [{ name: name("id"), value: "1" }, { name: name("name"), value: "" }],
    [],
  )
  let c_nv_grp_sp_pr = elem("cNvGrpSpPr", [], [])
  let nv_pr = elem("nvPr", [], [])
  let nv_grp_sp_pr = elem("nvGrpSpPr", [], [
    @xml.Node::Element(c_nv_pr),
    @xml.Node::Element(c_nv_grp_sp_pr),
    @xml.Node::Element(nv_pr),
  ])
  let grp_sp_pr = elem("grpSpPr", [], [])
  let sp_tree = elem("spTree", [], [
    @xml.Node::Element(nv_grp_sp_pr),
    @xml.Node::Element(grp_sp_pr),
  ])
  let c_sld = elem("cSld", [], [@xml.Node::Element(sp_tree)])
  let fade = elem("fade", [], [])
  let transition = elem(
    "transition",
    [
      { name: name("spd"), value: "fast" },
      { name: name("advClick"), value: "1" },
    ],
    [@xml.Node::Element(fade)],
  )
  let slide_root = elem("sld", [], [
    @xml.Node::Element(c_sld),
    @xml.Node::Element(transition),
  ])
  let slide = @domain.CT_Slide::new(slide_root)
  let svg = render_svg(slide)
  // Every transition attribute must show up on the SVG root.
  assert_true(svg.contains("data-ooxml-transition=\"fade\""))
  assert_true(svg.contains("data-ooxml-transition-spd=\"fast\""))
  assert_true(svg.contains("data-ooxml-transition-adv-click=\"1\""))
}

///|
/// §19.3.1.6 `<p:clrMap>` — the slide-master's clrMap remaps the
/// abstract slot names (bg1/tx1/bg2/tx2/accent1..6/hlink/folHlink)
/// onto concrete clrScheme slots.  A slide whose background uses
/// `<a:schemeClr val="tx1"/>` MUST first resolve `tx1` through the
/// master clrMap (e.g. `tx1="dk2"`), then through the §20.1.6.2
/// clrScheme (e.g. `<a:dk2><a:srgbClr val="123456"/></a:dk2>`),
/// producing fill `#123456`.  Verifies the full bg1/tx1 cascade
/// against the master.
test "viewer §19.3.1.6 clrMap tx1→dk2 cascades to theme dk2 hex" {
  // Theme — dk2 carries the distinguishing hex so we know the
  // cascade went through the clrMap.
  let prefix = "<a:theme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:themeElements>"
  let clr = "<a:clrScheme name=\"Office\">" +
    "<a:dk1><a:srgbClr val=\"000000\"/></a:dk1>" +
    "<a:lt1><a:srgbClr val=\"FFFFFF\"/></a:lt1>" +
    "<a:dk2><a:srgbClr val=\"123456\"/></a:dk2>" +
    "<a:lt2><a:srgbClr val=\"FFFFFF\"/></a:lt2>" +
    "<a:accent1><a:srgbClr val=\"FF0000\"/></a:accent1>" +
    "<a:accent2><a:srgbClr val=\"00FF00\"/></a:accent2>" +
    "<a:accent3><a:srgbClr val=\"0000FF\"/></a:accent3>" +
    "<a:accent4><a:srgbClr val=\"FFFF00\"/></a:accent4>" +
    "<a:accent5><a:srgbClr val=\"FF00FF\"/></a:accent5>" +
    "<a:accent6><a:srgbClr val=\"00FFFF\"/></a:accent6>" +
    "<a:hlink><a:srgbClr val=\"0000EE\"/></a:hlink>" +
    "<a:folHlink><a:srgbClr val=\"551A8B\"/></a:folHlink>" +
    "</a:clrScheme>"
  let font = "<a:fontScheme name=\"Office\">" +
    "<a:majorFont><a:latin typeface=\"Calibri\"/><a:ea typeface=\"-\"/><a:cs typeface=\"-\"/></a:majorFont>" +
    "<a:minorFont><a:latin typeface=\"Calibri\"/><a:ea typeface=\"-\"/><a:cs typeface=\"-\"/></a:minorFont>" +
    "</a:fontScheme>"
  let fmt = "<a:fmtScheme name=\"Office\">" +
    "<a:fillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:fillStyleLst>" +
    "<a:lnStyleLst><a:ln/><a:ln/><a:ln/></a:lnStyleLst>" +
    "<a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst>" +
    "<a:bgFillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:bgFillStyleLst>" +
    "</a:fmtScheme>"
  let theme_xml = prefix + clr + font + fmt + "</a:themeElements></a:theme>"
  let theme_raw = try? @theme.read_theme(@utf8.encode(theme_xml[:]))
  let theme_ok = match theme_raw {
    Ok(t) => t
    Err(_) => abort("theme construction failed")
  }
  // Master root carrying `<p:clrMap>` as sibling of `<p:cSld>`.
  // The §19.3.1.6 spec lists exactly 12 required attributes.
  let clr_map : @xml.Element = {
    name: name("clrMap"),
    attributes: [
      { name: name("bg1"), value: "lt1" },
      // tx1 remapped to dk2 — the slot that carries #123456.
      { name: name("tx1"), value: "dk2" },
      { name: name("bg2"), value: "lt2" },
      { name: name("tx2"), value: "dk1" },
      { name: name("accent1"), value: "accent1" },
      { name: name("accent2"), value: "accent2" },
      { name: name("accent3"), value: "accent3" },
      { name: name("accent4"), value: "accent4" },
      { name: name("accent5"), value: "accent5" },
      { name: name("accent6"), value: "accent6" },
      { name: name("hlink"), value: "hlink" },
      { name: name("folHlink"), value: "folHlink" },
    ],
    children: [],
  }
  let master_root = slide_like_with_shapes("sldMaster", [])
  let master_with_clrmap : @xml.Element = {
    ..master_root,
    children: master_root.children + [@xml.Node::Element(clr_map)],
  }
  let master = @domain.CT_SlideMaster::new(master_with_clrmap)
  // Slide carrying `<p:bg><p:bgPr><a:solidFill><a:schemeClr val="tx1"/></a:solidFill></p:bgPr></p:bg>`.
  let scheme_clr : @xml.Node = @xml.Node::Element({
    name: name("schemeClr"),
    attributes: [{ name: name("val"), value: "tx1" }],
    children: [],
  })
  let solid_fill : @xml.Node = @xml.Node::Element({
    name: name("solidFill"),
    attributes: [],
    children: [scheme_clr],
  })
  let bg_pr : @xml.Node = @xml.Node::Element({
    name: name("bgPr"),
    attributes: [],
    children: [solid_fill],
  })
  let bg : @xml.Node = @xml.Node::Element({
    name: name("bg"),
    attributes: [],
    children: [bg_pr],
  })
  let slide_root = slide_like_with_shapes("sld", [])
  // Inject <p:bg> as the first child of <p:cSld>.
  let new_children : Array[@xml.Node] = []
  for child in slide_root.children {
    match child {
      @xml.Node::Element(e) =>
        if e.name.local_name == "cSld" {
          let cs_children : Array[@xml.Node] = [bg]
          for c in e.children {
            cs_children.push(c)
          }
          new_children.push(@xml.Node::Element({ ..e, children: cs_children }))
        } else {
          new_children.push(child)
        }
      _ => new_children.push(child)
    }
  }
  let slide_with_bg : @xml.Element = { ..slide_root, children: new_children }
  let slide = @domain.CT_Slide::new(slide_with_bg)
  let chain = @ph_resolver.SlideChain::from_parts(master, None, Some(slide))
  let svg = render_svg(slide, theme=Some(theme_ok), chain=Some(chain))
  // tx1 → dk2 → #123456 (lowercased per sRGB normalisation).
  assert_true(svg.contains("#123456"))
}

///|
/// §19.5.93 `<p:timing>/<p:tnLst>` — root time-node children
/// (par / seq / excl / anim ...) MUST surface as
/// `data-ooxml-timing-tnLst` on the SVG root so downstream
/// consumers can drive an animation engine without re-parsing.
test "viewer §19.5.93 timing tnLst surfaces as data attribute" {
  // <p:sld>
  //   <p:cSld><p:spTree>...</p:spTree></p:cSld>
  //   <p:timing>
  //     <p:tnLst><p:par/><p:seq/></p:tnLst>
  //   </p:timing>
  // </p:sld>
  let par_tn : @xml.Node = @xml.Node::Element({
    name: name("par"),
    attributes: [],
    children: [],
  })
  let seq_tn : @xml.Node = @xml.Node::Element({
    name: name("seq"),
    attributes: [],
    children: [],
  })
  let tn_lst : @xml.Node = @xml.Node::Element({
    name: name("tnLst"),
    attributes: [],
    children: [par_tn, seq_tn],
  })
  let timing : @xml.Node = @xml.Node::Element({
    name: name("timing"),
    attributes: [],
    children: [tn_lst],
  })
  let slide_root = slide_like_with_shapes("sld", [])
  let slide_with_timing : @xml.Element = {
    ..slide_root,
    children: slide_root.children + [timing],
  }
  let slide = @domain.CT_Slide::new(slide_with_timing)
  let svg = render_svg(slide)
  assert_true(svg.contains("data-ooxml-timing-tnLst=\"par seq\""))
  assert_true(svg.contains("data-ooxml-timing-count=\"2\""))
}

///|
/// §20.1.9.8 `<a:stCxn id idx/>` / `<a:endCxn id idx/>` — the
/// connector endpoint metadata MUST surface as
/// `data-ooxml-cxn-st-id` / `-st-idx` / `-end-id` / `-end-idx`
/// on the SVG group so consumers can reroute the connector when
/// the connected shape moves.
test "viewer §20.1.9.8 cxnSp endpoints surface as data attributes" {
  let st_cxn : @xml.Node = @xml.Node::Element({
    name: name("stCxn"),
    attributes: [
      { name: name("id"), value: "5" },
      { name: name("idx"), value: "2" },
    ],
    children: [],
  })
  let end_cxn : @xml.Node = @xml.Node::Element({
    name: name("endCxn"),
    attributes: [
      { name: name("id"), value: "9" },
      { name: name("idx"), value: "0" },
    ],
    children: [],
  })
  let c_nv_pr : @xml.Node = @xml.Node::Element({
    name: name("cNvPr"),
    attributes: [
      { name: name("id"), value: "7" },
      { name: name("name"), value: "C1" },
    ],
    children: [],
  })
  let c_nv_cxn_sp_pr : @xml.Node = @xml.Node::Element({
    name: name("cNvCxnSpPr"),
    attributes: [],
    children: [st_cxn, end_cxn],
  })
  let nv_cxn_sp_pr : @xml.Node = @xml.Node::Element({
    name: name("nvCxnSpPr"),
    attributes: [],
    children: [
      c_nv_pr,
      c_nv_cxn_sp_pr,
      @xml.Node::Element({ name: name("nvPr"), attributes: [], children: [] }),
    ],
  })
  // Minimal `<p:cxnSp>` with the nvCxnSpPr block + an spPr.
  let xfrm : @xml.Node = @xml.Node::Element({
    name: name("xfrm"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("off"),
        attributes: [
          { name: name("x"), value: "0" },
          { name: name("y"), value: "0" },
        ],
        children: [],
      }),
      @xml.Node::Element({
        name: name("ext"),
        attributes: [
          { name: name("cx"), value: "914400" },
          { name: name("cy"), value: "457200" },
        ],
        children: [],
      }),
    ],
  })
  let sp_pr : @xml.Node = @xml.Node::Element({
    name: name("spPr"),
    attributes: [],
    children: [xfrm],
  })
  let cxn_sp : @xml.Node = @xml.Node::Element({
    name: name("cxnSp"),
    attributes: [],
    children: [nv_cxn_sp_pr, sp_pr],
  })
  let slide_root = slide_like_with_shapes("sld", [])
  // Splice the cxnSp into the spTree.
  let new_children : Array[@xml.Node] = []
  for ch in slide_root.children {
    match ch {
      @xml.Node::Element(e) =>
        if e.name.local_name == "cSld" {
          let cs_new : Array[@xml.Node] = []
          for c2 in e.children {
            match c2 {
              @xml.Node::Element(e2) =>
                if e2.name.local_name == "spTree" {
                  let new_st_kids : Array[@xml.Node] = []
                  for k in e2.children {
                    new_st_kids.push(k)
                  }
                  new_st_kids.push(cxn_sp)
                  cs_new.push(
                    @xml.Node::Element({ ..e2, children: new_st_kids }),
                  )
                } else {
                  cs_new.push(c2)
                }
              _ => cs_new.push(c2)
            }
          }
          new_children.push(@xml.Node::Element({ ..e, children: cs_new }))
        } else {
          new_children.push(ch)
        }
      _ => new_children.push(ch)
    }
  }
  let slide_el : @xml.Element = { ..slide_root, children: new_children }
  let slide = @domain.CT_Slide::new(slide_el)
  let svg = render_svg(slide)
  // All four endpoint attributes surface.
  assert_true(svg.contains("data-ooxml-cxn-st-id=\"5\""))
  assert_true(svg.contains("data-ooxml-cxn-st-idx=\"2\""))
  assert_true(svg.contains("data-ooxml-cxn-end-id=\"9\""))
  assert_true(svg.contains("data-ooxml-cxn-end-idx=\"0\""))
}

///|
/// §21.1.2.1.2 `<a:bodyPr><a:normAutofit fontScale lnSpcReduction>` —
/// when a shape's text body declares an auto-fit, the parser MUST
/// honour fontScale + lnSpcReduction.  Direct unit test on the
/// parse_body_pr_auto_fit helper since the full layout effect
/// requires deep plumbing.
test "viewer §21.1.2.1.2 parse_body_pr_auto_fit handles normAutofit/spAutoFit/noAutofit" {
  let mk_bp = fn(
    child_local : String,
    attrs : Array[@xml.Attribute],
  ) -> @xml.Element {
    {
      name: name("bodyPr"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: name(child_local),
          attributes: attrs,
          children: [],
        }),
      ],
    }
  }
  // noAutofit -> AutoFitNone
  let r1 = parse_body_pr_auto_fit(mk_bp("noAutofit", []))
  assert_true(r1 is AutoFitNone)
  // spAutoFit -> AutoFitShape
  let r2 = parse_body_pr_auto_fit(mk_bp("spAutoFit", []))
  assert_true(r2 is AutoFitShape)
  // normAutofit fontScale="80000" lnSpcReduction="20000"
  //   → font_scale=0.8, ln_spc=0.2 (per ST_TextFontScalePercent/SpacingPercent).
  let bp_norm = mk_bp("normAutofit", [
    { name: name("fontScale"), value: "80000" },
    { name: name("lnSpcReduction"), value: "20000" },
  ])
  let r3 = parse_body_pr_auto_fit(bp_norm)
  match r3 {
    AutoFitNormal(fs, ls) => {
      // 80000 / 100000 = 0.8.
      assert_true(fs >= 0.79 && fs <= 0.81)
      // 20000 / 100000 = 0.2.
      assert_true(ls >= 0.19 && ls <= 0.21)
    }
    _ => fail("expected AutoFitNormal")
  }
  // Empty bodyPr → AutoFitNone.
  let bp_empty : @xml.Element = {
    name: name("bodyPr"),
    attributes: [],
    children: [],
  }
  let r4 = parse_body_pr_auto_fit(bp_empty)
  assert_true(r4 is AutoFitNone)
}

///|
/// §20.1.4.2.18 CT_TableCellProperties — `<a:tcPr @marL @marR
/// @marT @marB @anchor>` MUST surface as `data-ooxml-cell-mar-*`
/// + `data-ooxml-cell-anchor` data attributes on the SVG `<g>`
/// wrapping the cell's text body.
test "viewer §20.1.4.2.18 a:tcPr margins + anchor surface as data-ooxml-cell-*" {
  // <a:tbl>
  //   <a:tblPr/>
  //   <a:tblGrid><a:gridCol w="914400"/></a:tblGrid>
  //   <a:tr h="457200">
  //     <a:tc>
  //       <a:txBody><a:bodyPr/><a:p><a:r><a:t>X</a:t></a:r></a:p></a:txBody>
  //       <a:tcPr marL="180000" marR="60000" marT="30000" marB="20000" anchor="ctr"/>
  //     </a:tc>
  //   </a:tr>
  // </a:tbl>
  let cell : @xml.Node = @xml.Node::Element({
    name: name("tc"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("txBody"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("bodyPr"),
            attributes: [],
            children: [],
          }),
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("X")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: name("tcPr"),
        attributes: [
          { name: name("marL"), value: "180000" },
          { name: name("marR"), value: "60000" },
          { name: name("marT"), value: "30000" },
          { name: name("marB"), value: "20000" },
          { name: name("anchor"), value: "ctr" },
        ],
        children: [],
      }),
    ],
  })
  let row : @xml.Node = @xml.Node::Element({
    name: name("tr"),
    attributes: [{ name: name("h"), value: "457200" }],
    children: [cell],
  })
  let tbl_pr : @xml.Node = @xml.Node::Element({
    name: name("tblPr"),
    attributes: [],
    children: [],
  })
  let tbl_grid : @xml.Node = @xml.Node::Element({
    name: name("tblGrid"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("gridCol"),
        attributes: [{ name: name("w"), value: "914400" }],
        children: [],
      }),
    ],
  })
  let tbl : @xml.Node = @xml.Node::Element({
    name: name("tbl"),
    attributes: [],
    children: [tbl_pr, tbl_grid, row],
  })
  let graphic : @xml.Node = @xml.Node::Element({
    name: name("graphic"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("graphicData"),
        attributes: [
          {
            name: name("uri"),
            value: "http://schemas.openxmlformats.org/drawingml/2006/table",
          },
        ],
        children: [tbl],
      }),
    ],
  })
  let frame : @xml.Node = @xml.Node::Element({
    name: name("graphicFrame"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("xfrm"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("off"),
            attributes: [
              { name: name("x"), value: "0" },
              { name: name("y"), value: "0" },
            ],
            children: [],
          }),
          @xml.Node::Element({
            name: name("ext"),
            attributes: [
              { name: name("cx"), value: "914400" },
              { name: name("cy"), value: "457200" },
            ],
            children: [],
          }),
        ],
      }),
      graphic,
    ],
  })
  let slide_root = slide_like_with_shapes("sld", [])
  // Splice the graphicFrame into the spTree.
  let new_children : Array[@xml.Node] = []
  for ch in slide_root.children {
    match ch {
      @xml.Node::Element(e) =>
        if e.name.local_name == "cSld" {
          let cs_new : Array[@xml.Node] = []
          for c2 in e.children {
            match c2 {
              @xml.Node::Element(e2) =>
                if e2.name.local_name == "spTree" {
                  let new_st_kids : Array[@xml.Node] = []
                  for k in e2.children {
                    new_st_kids.push(k)
                  }
                  new_st_kids.push(frame)
                  cs_new.push(
                    @xml.Node::Element({ ..e2, children: new_st_kids }),
                  )
                } else {
                  cs_new.push(c2)
                }
              _ => cs_new.push(c2)
            }
          }
          new_children.push(@xml.Node::Element({ ..e, children: cs_new }))
        } else {
          new_children.push(ch)
        }
      _ => new_children.push(ch)
    }
  }
  let slide_el : @xml.Element = { ..slide_root, children: new_children }
  let slide = @domain.CT_Slide::new(slide_el)
  let svg = render_svg(slide)
  // All four margin attrs surface, in EMU.
  assert_true(svg.contains("data-ooxml-cell-mar-l=\"180000\""))
  assert_true(svg.contains("data-ooxml-cell-mar-r=\"60000\""))
  assert_true(svg.contains("data-ooxml-cell-mar-t=\"30000\""))
  assert_true(svg.contains("data-ooxml-cell-mar-b=\"20000\""))
  // Anchor surfaces.
  assert_true(svg.contains("data-ooxml-cell-anchor=\"ctr\""))
}
