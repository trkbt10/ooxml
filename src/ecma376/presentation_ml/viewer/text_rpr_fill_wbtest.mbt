// White-box tests for §21.1.2.3.7 / §A.4.1 EG_FillProperties rich
// text fills and §20.1.2.2.24 `<a:ln>` text outline rendered from
// `<a:rPr>` via `build_run_span` into `LayoutSpan.text_outline` /
// `text_fill`.

///|
fn parse_run(source : String) -> @xml.Element raise {
  @xml.parse(@utf8.encode(source[:])).root
}

///|
fn empty_ctx() -> ColorResolveContext {
  ColorResolveContext::empty()
}

///|
test "build_run_span resolves a:ln solidFill into text_outline" {
  // §20.1.2.2.24 ln — `@w` (ST_LineWidth, EMU), `@cap` rnd, miter
  // join (EG_LineJoinProperties §20.1.8.43), solidFill colour.
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr><a:ln w=\"19050\" cap=\"rnd\"><a:solidFill><a:srgbClr val=\"FF0000\"/></a:solidFill><a:miter/></a:ln></a:rPr><a:t>hi</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  match span.text_outline {
    None => fail("expected text_outline to be populated")
    Some(o) => {
      // 19050 EMU / 9525 EMU per px = 2.0 px
      assert_true(o.width == 2.0)
      // ST_LineCap "rnd" → SVG stroke-linecap "round"
      assert_eq(o.cap, "round")
      // <a:miter/> child → SVG stroke-linejoin "miter"
      assert_eq(o.join, "miter")
      assert_eq(o.color, "#ff0000")
    }
  }
}

///|
test "build_run_span maps ST_LineCap sq → square and bevel join" {
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr><a:ln cap=\"sq\"><a:bevel/></a:ln></a:rPr><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  match span.text_outline {
    None => fail("expected text_outline")
    Some(o) => {
      assert_eq(o.cap, "square")
      assert_eq(o.join, "bevel")
    }
  }
}

///|
test "build_run_span without a:ln leaves text_outline None" {
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr/><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  assert_true(span.text_outline is None)
}

///|
test "build_run_span resolves a:noFill into TextFillNone" {
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr><a:noFill/></a:rPr><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  match span.text_fill {
    Some(TextFillNone) => ()
    _ => fail("expected TextFillNone")
  }
}

///|
test "build_run_span resolves a:gradFill with int (1000ths) gs@pos" {
  // §20.1.8.33 gradFill with transitional 1000ths-of-percent stops.
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr><a:gradFill><a:gsLst><a:gs pos=\"0\"><a:srgbClr val=\"ff0000\"/></a:gs><a:gs pos=\"100000\"><a:srgbClr val=\"00ff00\"/></a:gs></a:gsLst><a:lin ang=\"5400000\"/></a:gradFill></a:rPr><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  match span.text_fill {
    Some(TextFillGradient(stops, angle, is_radial, _, _)) => {
      assert_eq(stops.length(), 2)
      // 100000 (1000ths of percent) → 100 percent
      assert_true(stops[1].position == 100.0)
      // 5400000 60000ths-of-degree → 90 degrees
      assert_true(angle == 90.0)
      assert_eq(is_radial, false)
    }
    _ => fail("expected TextFillGradient")
  }
}

///|
test "build_run_span resolves a:gradFill with strict (%) gs@pos" {
  // §22.9.2.10 strict ST_PositiveFixedPercentage `"50%"` form.
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr><a:gradFill><a:gsLst><a:gs pos=\"0%\"><a:srgbClr val=\"ff0000\"/></a:gs><a:gs pos=\"50%\"><a:srgbClr val=\"00ff00\"/></a:gs></a:gsLst></a:gradFill></a:rPr><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  match span.text_fill {
    Some(TextFillGradient(stops, _, _, _, _)) => {
      assert_true(stops[1].position == 50.0)
    }
    _ => fail("expected TextFillGradient")
  }
}

///|
test "build_run_span treats a:gradFill with <a:path> as radial" {
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr><a:gradFill><a:gsLst><a:gs pos=\"0\"><a:srgbClr val=\"ff0000\"/></a:gs><a:gs pos=\"100000\"><a:srgbClr val=\"00ff00\"/></a:gs></a:gsLst><a:path path=\"circle\"/></a:gradFill></a:rPr><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  match span.text_fill {
    Some(TextFillGradient(_, _, is_radial, _, _)) => assert_eq(is_radial, true)
    _ => fail("expected TextFillGradient")
  }
}

///|
test "build_run_span resolves a:pattFill into TextFillPattern" {
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr><a:pattFill prst=\"dkVert\"><a:fgClr><a:srgbClr val=\"ff0000\"/></a:fgClr><a:bgClr><a:srgbClr val=\"00ff00\"/></a:bgClr></a:pattFill></a:rPr><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  match span.text_fill {
    Some(TextFillPattern(fg, bg, prst)) => {
      assert_eq(fg, "#ff0000")
      assert_eq(bg, "#00ff00")
      assert_eq(prst, "dkVert")
    }
    _ => fail("expected TextFillPattern")
  }
}

///|
test "build_run_span resolves a:blipFill into TextFillImage carrying r:embed" {
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" xmlns:r=\"http://purl.oclc.org/ooxml/officeDocument/relationships\"><a:rPr><a:blipFill><a:blip r:embed=\"rId7\"/></a:blipFill></a:rPr><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  match span.text_fill {
    Some(TextFillImage(rid)) => assert_eq(rid, "rId7")
    _ => fail("expected TextFillImage")
  }
}

///|
test "build_run_span returns None for a:grpFill (inherits from parent group)" {
  let r = parse_run(
    "<a:r xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:rPr><a:grpFill/></a:rPr><a:t>x</a:t></a:r>",
  )
  let span = build_run_span(r, empty_ctx(), None)
  // grpFill defers to the plain solid-colour cascade; text_fill stays None.
  assert_true(span.text_fill is None)
}
