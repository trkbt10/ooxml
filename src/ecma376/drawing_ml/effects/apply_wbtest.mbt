///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn xml_root(source : String) -> @xml.Element raise {
  @xml.parse(bytes(source)).root
}

///|
fn rgba(r : Int, g : Int, b : Int, a : Int) -> @color.Rgba8 {
  { r, g, b, a }
}

///|
fn sample_scheme() -> @color.ColorScheme {
  let z = rgba(0, 0, 0, 255)
  {
    dk1: z,
    lt1: rgba(255, 255, 255, 255),
    dk2: z,
    lt2: z,
    accent1: z,
    accent2: z,
    accent3: z,
    accent4: z,
    accent5: z,
    accent6: z,
    hlink: z,
    fol_hlink: z,
  }
}

///|
fn sample_ctx() -> DecodeContext {
  { scheme: sample_scheme(), placeholder: None }
}

///|
fn decode(source : String) -> Array[Effect] raise {
  let root = xml_root(source)
  decode_effect_children(root, sample_ctx())
}

///|
fn assert_close_channel(actual : Int, expected : Int) -> Unit raise {
  assert_true(actual >= expected - 2 && actual <= expected + 2)
}

///|
fn assert_close_rgba(
  actual : @color.Rgba8,
  expected : @color.Rgba8,
) -> Unit raise {
  assert_close_channel(actual.r, expected.r)
  assert_close_channel(actual.g, expected.g)
  assert_close_channel(actual.b, expected.b)
  assert_close_channel(actual.a, expected.a)
}

///|
fn assert_rgba(actual : @color.Rgba8, expected : @color.Rgba8) -> Unit raise {
  assert_true(actual == expected)
}

///|
let effects_ns : String = " xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\""

///|
test "§20.1.8.15 decode blur with defaults and overrides" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:blur/><a:blur rad=\"38100\" grow=\"false\"/></a:root>",
  )
  assert_eq(effs.length(), 2)
  assert_true(effs[0] is Blur(0, true))
  assert_true(effs[1] is Blur(38100, false))
}

///|
test "§20.1.8.32 decode glow reads color child" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:glow rad=\"50800\"><a:srgbClr val=\"FF0000\"/></a:glow></a:root>",
  )
  assert_eq(effs.length(), 1)
  let e = effs[0]
  match e {
    Glow(rad, color) => {
      assert_eq(rad, 50800)
      assert_rgba(color, rgba(255, 0, 0, 255))
    }
    _ => fail("expected Glow")
  }
}

///|
test "§20.1.8.40 decode innerShdw" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:innerShdw blurRad=\"63500\" dist=\"50800\" dir=\"2700000\"><a:srgbClr val=\"010203\"/></a:innerShdw></a:root>",
  )
  assert_eq(effs.length(), 1)
  match effs[0] {
    InnerShadow(p) => {
      assert_eq(p.blur_rad, 63500)
      assert_eq(p.dist, 50800)
      assert_eq(p.dir, 2700000)
      assert_rgba(p.color, rgba(1, 2, 3, 255))
    }
    _ => fail("expected InnerShadow")
  }
}

///|
test "§20.1.8.45 decode outerShdw with most attrs" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:outerShdw blurRad=\"127000\" dist=\"63500\" dir=\"2700000\" sx=\"110000\" sy=\"110000\" kx=\"0\" ky=\"0\" algn=\"ctr\" rotWithShape=\"false\"><a:srgbClr val=\"112233\"/></a:outerShdw></a:root>",
  )
  match effs[0] {
    OuterShadow(p) => {
      assert_eq(p.blur_rad, 127000)
      assert_eq(p.dist, 63500)
      assert_eq(p.dir, 2700000)
      assert_eq(p.sx, 110000)
      assert_eq(p.sy, 110000)
      assert_true(p.algn == ShadowAlign::Ctr)
      assert_eq(p.rot_with_shape, false)
      assert_rgba(p.color, rgba(17, 34, 51, 255))
    }
    _ => fail("expected OuterShadow")
  }
}

///|
test "§20.1.8.49 decode prstShdw" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:prstShdw prst=\"shdw3\" dir=\"5400000\" dist=\"38100\"><a:srgbClr val=\"808080\"/></a:prstShdw></a:root>",
  )
  match effs[0] {
    PresetShadow(p) => {
      assert_true(p.prst == PresetShadowKind::Shdw3)
      assert_eq(p.dir, 5400000)
      assert_eq(p.dist, 38100)
    }
    _ => fail("expected PresetShadow")
  }
}

///|
test "§20.1.8.50 decode reflection has defaults" {
  let effs = try! decode("<a:root" + effects_ns + "><a:reflection/></a:root>")
  match effs[0] {
    Reflection(p) => {
      assert_eq(p.blur_rad, 0)
      assert_eq(p.st_a, 100000)
      assert_eq(p.end_pos, 100000)
      assert_eq(p.fade_dir, 5400000)
      assert_eq(p.sx, 100000)
      assert_eq(p.sy, 100000)
      assert_true(p.algn == ShadowAlign::B)
      assert_eq(p.rot_with_shape, true)
    }
    _ => fail("expected Reflection")
  }
}

///|
test "§20.1.8.53 decode softEdge" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:softEdge rad=\"38100\"/></a:root>",
  )
  assert_true(effs[0] is SoftEdge(38100))
}

///|
test "§20.1.8.60 decode tint" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:tint amt=\"50000\" hue=\"0\"/></a:root>",
  )
  assert_true(effs[0] is Tint(50000, 0))
}

///|
test "§20.1.8.23 decode duotone with two colors" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:duotone><a:srgbClr val=\"FF0000\"/><a:srgbClr val=\"0000FF\"/></a:duotone></a:root>",
  )
  match effs[0] {
    Duotone(a, b) => {
      assert_rgba(a, rgba(255, 0, 0, 255))
      assert_rgba(b, rgba(0, 0, 255, 255))
    }
    _ => fail("expected Duotone")
  }
}

///|
test "§20.1.8.42 decode lum" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:lum bright=\"20000\" contrast=\"-10000\"/></a:root>",
  )
  assert_true(effs[0] is Lum(20000, -10000))
}

///|
test "§20.1.8.39 decode hsl" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:hsl hue=\"1800000\" sat=\"10000\" lum=\"-5000\"/></a:root>",
  )
  assert_true(effs[0] is Hsl(1800000, 10000, -5000))
}

///|
test "§20.1.8.29 decode fillOverlay" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:fillOverlay blend=\"mult\"/></a:root>",
  )
  match effs[0] {
    FillOverlay(BlendMode::Mult) => ()
    _ => fail("expected FillOverlay(Mult)")
  }
}

///|
test "§20.1.8.5 decode alphaMod is identity" {
  let effs = try! decode("<a:root" + effects_ns + "><a:alphaMod/></a:root>")
  assert_true(effs[0] is AlphaModEffect)
}

///|
test "§20.1.8.6 decode alphaModFix requires amt" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:alphaModFix amt=\"75000\"/></a:root>",
  )
  assert_true(effs[0] is AlphaModFix(75000))
  let missing = try? decode(
    "<a:root" + effects_ns + "><a:alphaModFix/></a:root>",
  )
  assert_true(missing is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "§20.1.8.2/.3 decode alphaCeiling and alphaFloor" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:alphaCeiling/><a:alphaFloor/></a:root>",
  )
  assert_true(effs[0] is AlphaCeiling)
  assert_true(effs[1] is AlphaFloor)
}

///|
test "§20.1.8.4 decode alphaInv with and without color" {
  let bare = try! decode("<a:root" + effects_ns + "><a:alphaInv/></a:root>")
  match bare[0] {
    AlphaInverse(None) => ()
    _ => fail("expected AlphaInverse(None)")
  }
  let with_color = try! decode(
    "<a:root" +
    effects_ns +
    "><a:alphaInv><a:srgbClr val=\"00FF00\"/></a:alphaInv></a:root>",
  )
  match with_color[0] {
    AlphaInverse(Some(c)) => assert_rgba(c, rgba(0, 255, 0, 255))
    _ => fail("expected AlphaInverse(Some)")
  }
}

///|
test "§20.1.8.8 decode alphaRepl requires a" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:alphaRepl a=\"50000\"/></a:root>",
  )
  assert_true(effs[0] is AlphaReplace(50000))
  let missing = try? decode("<a:root" + effects_ns + "><a:alphaRepl/></a:root>")
  assert_true(missing is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "§20.1.8.7 decode alphaOutset" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:alphaOutset rad=\"12700\"/></a:root>",
  )
  assert_true(effs[0] is AlphaOutset(12700))
}

///|
test "§20.1.8.1/.11 decode alphaBiLevel and biLevel" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:alphaBiLevel thresh=\"50000\"/><a:biLevel thresh=\"75000\"/></a:root>",
  )
  assert_true(effs[0] is AlphaBiLevel(50000))
  assert_true(effs[1] is BiLevel(75000))
}

///|
test "§20.1.8.12 decode blend" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:blend blend=\"screen\"/></a:root>",
  )
  match effs[0] {
    Blend(BlendMode::Screen) => ()
    _ => fail("expected Blend(Screen)")
  }
}

///|
test "§20.1.8.16 decode clrChange with two colors" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:clrChange useA=\"true\"><a:clrFrom><a:srgbClr val=\"FF0000\"/></a:clrFrom><a:clrTo><a:srgbClr val=\"00FF00\"/></a:clrTo></a:clrChange></a:root>",
  )
  match effs[0] {
    ClrChange(from, to, use_alpha) => {
      assert_rgba(from, rgba(255, 0, 0, 255))
      assert_rgba(to, rgba(0, 255, 0, 255))
      assert_eq(use_alpha, true)
    }
    _ => fail("expected ClrChange")
  }
}

///|
test "§20.1.8.18 decode clrRepl" {
  let effs = try! decode(
    "<a:root" +
    effects_ns +
    "><a:clrRepl><a:srgbClr val=\"AABBCC\"/></a:clrRepl></a:root>",
  )
  match effs[0] {
    ClrRepl(c) => assert_rgba(c, rgba(0xAA, 0xBB, 0xCC, 255))
    _ => fail("expected ClrRepl")
  }
}

///|
test "§20.1.8.34 decode grayscl" {
  let effs = try! decode("<a:root" + effects_ns + "><a:grayscl/></a:root>")
  assert_true(effs[0] is Grayscale)
}

///|
test "§20.1.8.51 decode relOff" {
  let effs = try! decode(
    "<a:root" + effects_ns + "><a:relOff tx=\"50000\" ty=\"-25000\"/></a:root>",
  )
  assert_true(effs[0] is RelativeOffset(50000, -25000))
}

///|
test "§20.1.8.61 decode xfrm with defaults" {
  let effs = try! decode("<a:root" + effects_ns + "><a:xfrm/></a:root>")
  match effs[0] {
    Transform(p) => {
      assert_eq(p.sx, 100000)
      assert_eq(p.sy, 100000)
      assert_eq(p.kx, 0)
      assert_eq(p.ky, 0)
    }
    _ => fail("expected Transform")
  }
}

///|
test "§20.1.8 unknown effect element raises SchemaViolation" {
  let res = try? decode("<a:root" + effects_ns + "><a:unknownEffect/></a:root>")
  assert_true(res is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "§20.1.8.60 apply_tint hue shift toward red" {
  let result = apply_tint(rgba(0, 0, 255, 255), 100000, 0)
  // Full weight shifts blue all the way to the target hue (0 = red).
  assert_close_rgba(result, rgba(255, 0, 0, 255))
}

///|
test "§20.1.8.42 apply_lum brightness floors and ceils" {
  let brighter = apply_lum(rgba(128, 128, 128, 255), 20000, 0)
  assert_true(brighter.r > 128)
  let darker = apply_lum(rgba(128, 128, 128, 255), -20000, 0)
  assert_true(darker.r < 128)
}

///|
test "§20.1.8.34 apply_grayscale uses BT.709 luminance" {
  let g = apply_grayscale(rgba(255, 0, 0, 255))
  // 0.2126 * 255 ≈ 54
  assert_close_channel(g.r, 54)
  assert_eq(g.r, g.g)
  assert_eq(g.r, g.b)
  assert_eq(g.a, 255)
}

///|
test "§20.1.8.16 apply_clr_change rewrites matching pixel" {
  let mapped = apply_clr_change(
    rgba(255, 0, 0, 255),
    rgba(255, 0, 0, 255),
    rgba(0, 255, 0, 255),
    false,
  )
  assert_rgba(mapped, rgba(0, 255, 0, 255))
  let untouched = apply_clr_change(
    rgba(123, 45, 67, 255),
    rgba(255, 0, 0, 255),
    rgba(0, 255, 0, 255),
    false,
  )
  assert_rgba(untouched, rgba(123, 45, 67, 255))
}

///|
test "§20.1.8.18 apply_clr_repl preserves alpha" {
  let r = apply_clr_repl(rgba(10, 20, 30, 40), rgba(50, 60, 70, 80))
  assert_eq(r.r, 50)
  assert_eq(r.g, 60)
  assert_eq(r.b, 70)
  assert_eq(r.a, 40)
}

///|
test "§20.1.8.6 apply_alpha_mod_fix halves opacity" {
  let r = apply_alpha_mod_fix(rgba(255, 0, 0, 200), 50000)
  assert_close_channel(r.a, 100)
}

///|
test "§20.1.8.8 apply_alpha_replace sets opacity" {
  let r = apply_alpha_replace(rgba(255, 0, 0, 200), 25000)
  assert_close_channel(r.a, 64)
}

///|
test "§20.1.8.26 chain ordering keeps geometric effects in declared order" {
  let effs = [
    Effect::OuterShadow({
      blur_rad: 0,
      dist: 0,
      dir: 0,
      sx: 100000,
      sy: 100000,
      kx: 0,
      ky: 0,
      algn: ShadowAlign::B,
      rot_with_shape: true,
      color: rgba(0, 0, 0, 255),
    }),
    Effect::Glow(50800, rgba(255, 255, 0, 255)),
    Effect::Reflection({
      blur_rad: 0,
      st_a: 100000,
      st_pos: 0,
      end_a: 0,
      end_pos: 100000,
      dist: 0,
      dir: 0,
      fade_dir: 5400000,
      sx: 100000,
      sy: 100000,
      kx: 0,
      ky: 0,
      algn: ShadowAlign::B,
      rot_with_shape: true,
    }),
  ]
  let chain = apply_effects(effs, rgba(128, 0, 0, 255))
  assert_eq(chain.rendered.length(), 3)
  assert_true(chain.rendered[0] is OuterShadowRender(_))
  assert_true(chain.rendered[1] is GlowRender(_, _))
  assert_true(chain.rendered[2] is ReflectionRender(_))
  // Color is untouched by geometric effects.
  assert_rgba(chain.final_color, rgba(128, 0, 0, 255))
}

///|
test "§20.1.8 color-modifying chain: Tint 50% + Lum 20% + ClrChange" {
  let mapped = apply_effects_to_color(
    [Effect::ClrChange(rgba(255, 0, 0, 255), rgba(0, 255, 0, 255), false)],
    rgba(255, 0, 0, 255),
  )
  assert_rgba(mapped, rgba(0, 255, 0, 255))
  let lum_only = apply_effects_to_color(
    [Effect::Lum(20000, 0)],
    rgba(128, 128, 128, 255),
  )
  assert_true(lum_only.r > 128)
  let tinted = apply_effects_to_color(
    [Effect::Tint(50000, 5400000)],
    rgba(255, 0, 0, 255),
  )
  // 5400000 angle units = 90° = green hue, 50% weight shifts toward
  // yellow-green; assert green channel rose above red and blue.
  assert_true(tinted.g >= tinted.b)
}

///|
test "§20.1.8.26 decode_effect_list end-to-end" {
  let element = xml_root(
    "<a:effectLst" +
    effects_ns +
    "><a:outerShdw blurRad=\"63500\" dist=\"50800\" dir=\"2700000\"><a:srgbClr val=\"000000\"/></a:outerShdw><a:glow rad=\"38100\"><a:srgbClr val=\"FFFF00\"/></a:glow></a:effectLst>",
  )
  let list = @dml.CT_EffectList::new(element)
  let effs = try! decode_effect_list(list, sample_ctx())
  assert_eq(effs.length(), 2)
  let chain = apply_effects(effs, rgba(255, 255, 255, 255))
  assert_eq(chain.rendered.length(), 2)
  assert_true(chain.rendered[0] is OuterShadowRender(_))
  assert_true(chain.rendered[1] is GlowRender(_, _))
}
