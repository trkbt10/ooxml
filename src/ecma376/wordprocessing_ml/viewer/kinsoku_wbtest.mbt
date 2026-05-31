// Integration check: the WML line breaker decomposes run text via the
// shared `@glyph.linebreak_segments` source of truth, so every segment
// boundary it can wrap at is a kinsoku-legal break point.  (The
// segmentation rules themselves are unit-tested in
// src/util/glyph/kinsoku_wbtest.mbt; here we only confirm the WML
// breaker consumes that SoT — no private re-implementation.)

///|
/// Assert no segment boundary produced for `text` is a kinsoku-illegal
/// break point, walking the shared segmenter's output.
fn assert_wml_no_illegal_boundary(text : String) -> Unit {
  let segs = @glyph.linebreak_segments(text)
  for i in 1..<segs.length() {
    let prev = segs[i - 1]
    let cur = segs[i]
    let mut prev_last = ' '
    for c in prev {
      prev_last = c
    }
    let mut cur_first = ' '
    for c in cur {
      cur_first = c
      break
    }
    if !@glyph.kinsoku_break_allowed(prev_last, cur_first) {
      abort("illegal kinsoku boundary between '\{prev}' and '\{cur}'")
    }
  }
}

///|
test "WML run segmentation honours kinsoku across a realistic sentence" {
  assert_wml_no_illegal_boundary(
    "本日は、晴天なり。（晴れ）また「明日」も雨。続く……",
  )
}

///|
test "WML run segmentation keeps ASCII word wrapping intact" {
  let segs = @glyph.linebreak_segments("the lazy dog")
  // "the", " ", "lazy", " ", "dog"
  inspect(segs.length(), content="5")
}

///|
/// Inject the deterministic test font so `measure_run_text` returns
/// real metrics — without it the host may lack "Noto Sans" and every
/// measurement degrades to 0, defeating any wrap assertion.  Mirrors
/// the PML viewer's `ensure_test_font`.
let wml_test_font_ready : Ref[Bool] = { val: false }

///|
fn ensure_wml_test_font() -> Unit {
  if wml_test_font_ready.val {
    return
  }
  wml_test_font_ready.val = true
  let bytes = try
    @fs.read_file_to_bytes("src/util/glyph/fixtures/subset.ttf")
  catch {
    _ => abort("cannot load test font src/util/glyph/fixtures/subset.ttf")
  } noraise {
    b => b
  }
  @glyph.set_default_font_set(
    @glyph.FontSet::new(
      resolver=@glyph.FontResolver::in_memory(
        Map([("Noto Sans", bytes)], capacity=1),
      ),
    ),
  )
}

///|
/// Emergency character-level wrap (CSS overflow-wrap: anywhere): a long
/// run with no internal break opportunity, on a narrow page, must wrap
/// across several lines rather than overrun the column.  Each wrapped
/// line is emitted as its own `<text>` element, so more than one
/// `<text>` proves the emergency split fired.
test "render_svg wraps an unbreakable long run per character" {
  ensure_wml_test_font()
  // 200 'a's: a single segment with no space / CJK / hyphen break.
  let long = StringBuilder::new()
  for _ in 0..<200 {
    long.write_char('a')
  }
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
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
                    children: [@xml.Node::Text(long.to_string())],
                  }),
                ],
              }),
            ],
          }),
          // Narrow page so 200 glyphs cannot fit one line.
          @xml.Node::Element({
            name: name("sectPr"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pgSz"),
                attributes: [attr("w", "3000"), attr("h", "16838")],
                children: [],
              }),
              @xml.Node::Element({
                name: name("pgMar"),
                attributes: [
                  attr("top", "720"),
                  attr("right", "720"),
                  attr("bottom", "720"),
                  attr("left", "720"),
                  attr("header", "360"),
                  attr("footer", "360"),
                  attr("gutter", "0"),
                ],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // The single unbreakable run must have been split across multiple
  // lines: more than one <text> element.
  assert_true(count_occurrences(svg, "<text ") > 1)
}

///|
/// §17.3.1.10/.11 autoSpaceDE/DN (和欧間隔): a run mixing East Asian and
/// Latin glyphs must paint the 四分アキ gap, which the emitter renders
/// as a `<tspan dx="…">` at the script boundary.
test "render_svg inserts 和欧間隔 between East Asian and Latin" {
  ensure_wml_test_font()
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
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
                    children: [@xml.Node::Text("日本語ABC")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  // The 語|A boundary produces a dx-shifted tspan.
  assert_true(svg.contains("<tspan dx="))
}

///|
/// A pure-Latin or pure-Japanese run has no script boundary and must
/// NOT be split into dx tspans (no spurious 和欧間隔).
test "render_svg adds no 和欧間隔 within a single script" {
  ensure_wml_test_font()
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
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
                    children: [@xml.Node::Text("日本語")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(!svg.contains("<tspan dx="))
}

///|
/// §17.3.1.10 — an explicit `<w:autoSpaceDE w:val="false"/>` in the
/// paragraph disables the East-Asian↔Latin 和欧間隔, so the mixed run
/// must NOT be split into dx tspans.
test "render_svg respects autoSpaceDE=false (no 和欧間隔)" {
  ensure_wml_test_font()
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("autoSpaceDE"),
                    attributes: [attr("val", "false")],
                    children: [],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("日本語ABC")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let svg = render_svg(document).pages[0].svg
  assert_true(!svg.contains("<tspan dx="))
}
