///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn xml_root(source : String) -> @xml.Element raise {
  @xml.parse(bytes(source)).root
}

///|
fn sample_scheme() -> ColorScheme {
  {
    dk1: rgba(0, 0, 0, 255),
    lt1: rgba(255, 255, 255, 255),
    dk2: rgba(31, 73, 125, 255),
    lt2: rgba(238, 236, 225, 255),
    accent1: rgba(68, 114, 196, 255),
    accent2: rgba(237, 125, 49, 255),
    accent3: rgba(165, 165, 165, 255),
    accent4: rgba(255, 192, 0, 255),
    accent5: rgba(91, 155, 213, 255),
    accent6: rgba(112, 173, 71, 255),
    hlink: rgba(5, 99, 193, 255),
    fol_hlink: rgba(149, 79, 114, 255),
  }
}

///|
fn assert_close_channel(actual : Int, expected : Int) -> Unit raise {
  assert_true(actual >= expected - 1 && actual <= expected + 1)
}

///|
fn assert_close_rgba(actual : Rgba8, expected : Rgba8) -> Unit raise {
  assert_close_channel(actual.r, expected.r)
  assert_close_channel(actual.g, expected.g)
  assert_close_channel(actual.b, expected.b)
  assert_close_channel(actual.a, expected.a)
}

///|
test "§20.1.2.3.32 parse srgb hex" {
  assert_true(try! (parse_srgb_hex("FF0000") == rgba(255, 0, 0, 255)))
  assert_true(try! (parse_srgb_hex("00FF0080") == rgba(0, 255, 0, 128)))
  assert_true(
    (try? parse_srgb_hex("ZZZ")) is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? parse_srgb_hex("FF00")) is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
test "§20.1.2.3.22 preset color lookup" {
  assert_true(try! (preset_color("red") == rgba(255, 0, 0, 255)))
  assert_true(try! (preset_color("blue") == rgba(0, 0, 255, 255)))
  assert_true(try! (preset_color("transparent") == rgba(0, 0, 0, 0)))
  assert_true(
    (try? preset_color("notAColor")) is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
test "§20.1.2.3.13 hsl round trip representative colors" {
  let colors = [
    rgba(255, 0, 0, 255),
    rgba(0, 255, 0, 255),
    rgba(0, 0, 255, 255),
    rgba(68, 114, 196, 200),
    rgba(128, 128, 128, 255),
  ]
  for color in colors {
    let (h, s, l) = rgb_to_hsl(color)
    assert_close_rgba(hsl_to_rgb(h, s, l, color.a), color)
  }
}

///|
test "§20.1.2.3.34 tint lightens through HSL luminance" {
  let resolved = try! resolve_color(
    Srgb(rgba(255, 0, 0, 255)),
    [Tint(50000)],
    sample_scheme(),
    None,
  )
  assert_close_rgba(resolved, rgba(255, 128, 128, 255))
}

///|
test "§20.1.2.3.31 shade darkens through HSL luminance" {
  let resolved = try! resolve_color(
    Srgb(rgba(255, 0, 0, 255)),
    [Shade(50000)],
    sample_scheme(),
    None,
  )
  assert_close_rgba(resolved, rgba(128, 0, 0, 255))
}

///|
test "§20.1.2.3.20 and §20.1.2.3.21 compose luminance transforms in order" {
  let resolved = try! resolve_color(
    Srgb(rgba(255, 0, 0, 255)),
    [LumMod(50000), LumOff(25000)],
    sample_scheme(),
    None,
  )
  assert_close_rgba(resolved, rgba(255, 0, 0, 255))
}

///|
test "§20.1.2.3.27 satMod zero produces grayscale" {
  let resolved = try! resolve_color(
    Srgb(rgba(100, 200, 50, 255)),
    [SatMod(0)],
    sample_scheme(),
    None,
  )
  assert_close_rgba(resolved, rgba(125, 125, 125, 255))
}

///|
test "§20.1.2.3.1 alpha family resolves opacity" {
  let resolved = try! resolve_color(
    Srgb(rgba(10, 20, 30, 255)),
    [Alpha(50000), AlphaMod(50000), AlphaOff(25000)],
    sample_scheme(),
    None,
  )
  assert_close_rgba(resolved, rgba(10, 20, 30, 128))
}

///|
test "§20.1.2.3.29 scheme color resolves then applies tint" {
  let resolved = try! resolve_color(
    Scheme(Accent1),
    [Tint(40000)],
    sample_scheme(),
    None,
  )
  assert_close_rgba(resolved, rgba(143, 171, 220, 255))
}

///|
test "§20.1.6 read color scheme entries" {
  let scheme = try! read_color_scheme(
    xml_root(
      "<a:clrScheme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:dk1><a:sysClr val=\"windowText\" lastClr=\"000000\"/></a:dk1><a:lt1><a:sysClr val=\"window\" lastClr=\"FFFFFF\"/></a:lt1><a:dk2><a:srgbClr val=\"1F497D\"/></a:dk2><a:lt2><a:srgbClr val=\"EEECE1\"/></a:lt2><a:accent1><a:srgbClr val=\"4472C4\"/></a:accent1><a:accent2><a:srgbClr val=\"ED7D31\"/></a:accent2><a:accent3><a:srgbClr val=\"A5A5A5\"/></a:accent3><a:accent4><a:srgbClr val=\"FFC000\"/></a:accent4><a:accent5><a:srgbClr val=\"5B9BD5\"/></a:accent5><a:accent6><a:srgbClr val=\"70AD47\"/></a:accent6><a:hlink><a:srgbClr val=\"0563C1\"/></a:hlink><a:folHlink><a:srgbClr val=\"954F72\"/></a:folHlink></a:clrScheme>",
    ),
  )
  assert_true(scheme.accent1 == rgba(68, 114, 196, 255))
  assert_true(scheme.dk1 == rgba(0, 0, 0, 255))
  assert_true(scheme.fol_hlink == rgba(149, 79, 114, 255))
}

///|
test "§20.1.2.3 read scheme color reference and transform list" {
  let (base, transforms) = try! read_color_ref(
    xml_root(
      "<a:schemeClr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" val=\"accent1\"><a:lumMod val=\"60000\"/><a:lumOff val=\"40000\"/></a:schemeClr>",
    ),
  )
  assert_true(base == Scheme(Accent1))
  assert_true(transforms == [LumMod(60000), LumOff(40000)])
}

///|
test "§20.1.2.3.33 read system color uses lastClr fallback" {
  let (base, transforms) = try! read_color_ref(
    xml_root(
      "<a:sysClr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" val=\"windowText\" lastClr=\"112233\"><a:alpha val=\"50000\"/></a:sysClr>",
    ),
  )
  assert_true(base == Sys("windowText", rgba(17, 34, 51, 255)))
  assert_true(transforms == [Alpha(50000)])
  assert_close_rgba(
    try! resolve_color(base, transforms, sample_scheme(), None),
    rgba(17, 34, 51, 128),
  )
}

///|
test "§20.1.2.3.29 phClr requires placeholder color" {
  assert_true(
    (try? resolve_color(Scheme(PhClr), [], sample_scheme(), None))
    is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    try! (resolve_color(
      Scheme(PhClr),
      [],
      sample_scheme(),
      Some(rgba(10, 20, 30, 255)),
    ) ==
    rgba(10, 20, 30, 255)),
  )
}

///|
test "§20.1.2.3.14-.17 hue and inverse transforms" {
  assert_close_rgba(
    try! resolve_color(
      Srgb(rgba(0, 255, 0, 255)),
      [HueMod(50000)],
      sample_scheme(),
      None,
    ),
    rgba(255, 255, 0, 255),
  )
  assert_true(
    try! (resolve_color(
      Srgb(rgba(255, 0, 0, 255)),
      [Inv],
      sample_scheme(),
      None,
    ) ==
    rgba(0, 255, 255, 255)),
  )
}

///|
/// §20.1.2.3.30 scrgbClr — linear-RGB colour.  `read_color_ref`
/// MUST accept the element (not raise SchemaViolation) and the
/// channels MUST be gamma-encoded to sRGB.  A 50% linear channel
/// maps to ≈188 (not 128) after the IEC 61966-2-1 transfer.
test "§20.1.2.3.30 scrgbClr resolves with linear→sRGB gamma" {
  let ns = " xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\""
  let el = xml_root("<a:scrgbClr" + ns + " r=\"50000\" g=\"50000\" b=\"50000\"/>")
  let (base, transforms) = read_color_ref(el)
  let resolved = resolve_color(base, transforms, sample_scheme(), None)
  // 50% linear → ≈188 sRGB.  (Straight linear scaling would
  // wrongly produce 128.)
  assert_close_channel(resolved.r, 188)
  assert_close_channel(resolved.g, 188)
  assert_close_channel(resolved.b, 188)
  // Full intensity stays 255, zero stays 0.
  let white = xml_root(
    "<a:scrgbClr" + ns + " r=\"100000\" g=\"100000\" b=\"100000\"/>",
  )
  let (wb, wt) = read_color_ref(white)
  let w = resolve_color(wb, wt, sample_scheme(), None)
  assert_eq(w.r, 255)
  let black = xml_root("<a:scrgbClr" + ns + " r=\"0\" g=\"0\" b=\"0\"/>")
  let (bb, bt) = read_color_ref(black)
  let bk = resolve_color(bb, bt, sample_scheme(), None)
  assert_eq(bk.r, 0)
}
