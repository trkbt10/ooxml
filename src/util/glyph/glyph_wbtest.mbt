// White-box tests for the public surface of `util/glyph`.
//
// Real-font measurement tests live in `gpos_extract_wbtest.mbt` and
// `font_measurer_wbtest.mbt`; this file covers only the type-level
// behaviours that don't depend on a host font catalogue.

///|
test "is_cjk_code_point classifies Unicode ranges" {
  // CJK Unified Ideographs (e.g. 漢)
  assert_true(is_cjk_code_point(0x6F22))
  // Hiragana (e.g. あ)
  assert_true(is_cjk_code_point(0x3042))
  // Katakana (e.g. ア)
  assert_true(is_cjk_code_point(0x30A2))
  // Halfwidth / Fullwidth Forms (full-width digit ０ U+FF10)
  assert_true(is_cjk_code_point(0xFF10))
  // Latin 'A' must not be CJK.
  assert_false(is_cjk_code_point(0x0041))
  // ASCII space must not be CJK.
  assert_false(is_cjk_code_point(0x0020))
}

///|
test "normalize_family lowercases and collapses internal whitespace" {
  inspect(normalize_family("Noto Sans"), content="noto sans")
  inspect(normalize_family("  Noto   Sans  "), content="noto sans")
  inspect(normalize_family("NotoSerif"), content="notoserif")
}

///|
test "parse_font_stack tokenises a CSS font-family value" {
  let stack = parse_font_stack("\"Noto Sans\", Helvetica, sans-serif")
  inspect(stack.length(), content="3")
  // First candidate: explicit Name (stripped of quotes).
  match stack[0] {
    Name(n) => inspect(n, content="Noto Sans")
    Generic(_) => fail("expected Name for first candidate")
  }
  // Second candidate: explicit Name.
  match stack[1] {
    Name(n) => inspect(n, content="Helvetica")
    Generic(_) => fail("expected Name for second candidate")
  }
  // Third candidate: Generic(SansSerif).
  match stack[2] {
    Generic(g) => inspect(g, content="SansSerif")
    Name(_) => fail("expected Generic for third candidate")
  }
}

///|
test "FontResolver::in_memory matches by case-insensitive family" {
  let resolver = FontResolver::in_memory(
    Map([("Noto Sans", b"FAKE")], capacity=1),
  )
  let request = FontFaceRequest::of_name("noto sans")
  let resource = (resolver.resolve)(request)
  inspect(resource.source_label, content="in-memory:noto sans")
}

///|
test "FontResolver::in_memory raises when family is absent" {
  let resolver = FontResolver::in_memory(
    Map([("Noto Sans", b"FAKE")], capacity=1),
  )
  let request = FontFaceRequest::of_name("Helvetica")
  match (try? (resolver.resolve)(request)) {
    Ok(_) => fail("expected FontUnresolvedError")
    Err(FontUnresolvedError(driver_labels=labels, ..)) =>
      inspect(labels.length(), content="1")
  }
}

///|
test "FontResolver::in_memory honours embedded_bytes ahead of the catalogue" {
  let resolver = FontResolver::in_memory(
    Map([("Noto Sans", b"CATALOG")], capacity=1),
  )
  let request : FontFaceRequest = {
    stack: [Name("Helvetica")],
    weight: 400,
    italic: false,
    embedded_bytes: Some(b"EMBEDDED"),
  }
  let resource = (resolver.resolve)(request)
  inspect(resource.source_label, content="embedded")
}

///|
test "FontResolver::compose walks drivers in order" {
  let first = FontResolver::in_memory(Map([], capacity=0))
  let second = FontResolver::in_memory(
    Map([("Noto Sans", b"SECOND")], capacity=1),
  )
  let composed = FontResolver::compose([first, second])
  let request = FontFaceRequest::of_name("Noto Sans")
  let resource = (composed.resolve)(request)
  inspect(resource.source_label, content="in-memory:Noto Sans")
}

///|
test "extract_gpos_kern_pairs returns empty for too-short bytes" {
  let extracted = extract_gpos_kern_pairs(b"abc")
  inspect(extracted.length(), content="0")
}
