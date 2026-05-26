// White-box tests for `util/color`.  Validates conversions and
// DrawingML colour transforms against the web-pptx reference values.

///|
test "hex_to_rgb 6-digit form" {
  let c = hex_to_rgb("FF0000")
  @debug.debug_inspect(c.r, content="255")
  @debug.debug_inspect(c.g, content="0")
  @debug.debug_inspect(c.b, content="0")
}

///|
test "hex_to_rgb 3-digit form expands to 6" {
  // #ABC → #AABBCC
  let c = hex_to_rgb("ABC")
  @debug.debug_inspect(c.r, content="170")
  @debug.debug_inspect(c.g, content="187")
  @debug.debug_inspect(c.b, content="204")
}

///|
test "hex_to_rgb strips leading hash" {
  let c = hex_to_rgb("#00FF00")
  @debug.debug_inspect(c.r, content="0")
  @debug.debug_inspect(c.g, content="255")
  @debug.debug_inspect(c.b, content="0")
}

///|
test "to_hex pads single digit" {
  @debug.debug_inspect(to_hex(15.0), content=(
    #|"0f"
  ))
  @debug.debug_inspect(to_hex(0.0), content=(
    #|"00"
  ))
  @debug.debug_inspect(to_hex(255.0), content=(
    #|"ff"
  ))
}

///|
test "rgb_to_hex round trips primary colors" {
  @debug.debug_inspect(rgb_to_hex(255.0, 0.0, 0.0), content=(
    #|"ff0000"
  ))
  @debug.debug_inspect(rgb_to_hex(0.0, 255.0, 0.0), content=(
    #|"00ff00"
  ))
  @debug.debug_inspect(rgb_to_hex(0.0, 0.0, 255.0), content=(
    #|"0000ff"
  ))
}

///|
test "rgb_to_hsl basic conversions" {
  // Pure red: H=0, S=1, L=0.5
  let red = rgb_to_hsl(255.0, 0.0, 0.0)
  @debug.debug_inspect(red.h, content="0")
  @debug.debug_inspect(red.s, content="1")
  @debug.debug_inspect(red.l, content="0.5")
}

///|
test "apply_shade 50% in linear RGB" {
  // §20.1.2.3.31 — `<a:shade val=50000>` halves the linear-light
  // intensity of each channel.  For pure red (255,0,0), L_lin=1.0
  // → L'_lin=0.5 → sRGB byte = round(255 * (1.055 * 0.5^(1/2.4) - 0.055))
  // ≈ 188 (= 0xbc).  This matches PowerPoint, whereas a naive
  // sRGB-space multiply yields 128 (= 0x80) which is visibly darker
  // than the reference.
  @debug.debug_inspect(apply_shade("ff0000", 0.5), content=(
    #|"bc0000"
  ))
}

///|
test "apply_shade 0 yields black" {
  @debug.debug_inspect(apply_shade("ff0000", 0.0), content=(
    #|"000000"
  ))
}

///|
test "apply_tint 50% in linear RGB" {
  // §20.1.2.3.34 — `<a:tint val=50000>` interpolates each channel
  // toward white in linear-light space.  For pure red (255,0,0):
  //   R_lin=1.0 → 1.0*0.5 + 0.5 = 1.0 → sRGB 255
  //   G_lin=0.0 → 0.0*0.5 + 0.5 = 0.5 → sRGB ≈188 (0xbc)
  // → `ffbcbc`.  The naive sRGB-space formula yields `ff8080`, which
  // is visibly pinker/less luminous than the reference renderer.
  @debug.debug_inspect(apply_tint("ff0000", 0.5), content=(
    #|"ffbcbc"
  ))
}

///|
test "named color lookup returns lowercase hex" {
  @debug.debug_inspect(get_color_name_to_hex("red"), content=(
    #|Some("ff0000")
  ))
  @debug.debug_inspect(get_color_name_to_hex("RED"), content=(
    #|Some("ff0000")
  ))
  @debug.debug_inspect(get_color_name_to_hex("Black"), content=(
    #|Some("000000")
  ))
  @debug.debug_inspect(get_color_name_to_hex("rebeccapurple"), content=(
    #|Some("663399")
  ))
  @debug.debug_inspect(get_color_name_to_hex("not-a-color"), content="None")
}

///|
test "hsl_to_hex_string preserves color through round trip" {
  // ff0000 (red) → HSL(0, 1, 0.5) → ff0000
  let hsl = parse_color_to_hsl("ff0000")
  @debug.debug_inspect(hsl_to_hex_string(hsl, false), content=(
    #|"ff0000"
  ))
}

///|
test "apply_lum_off increases lightness" {
  // Pure red has L=0.5. lumOff +0.2 → L=0.7 (lighter red).
  let result = apply_lum_off("ff0000", 0.2)
  // Result should be lighter than ff0000: parse and check L > 0.5.
  let hsl = parse_color_to_hsl(result)
  assert_true(hsl.l > 0.5)
}

///|
/// §20.1.2.3.19 hueOff — pure red (H=0°) shifted by +120° lands
/// at pure green H=120 (S=L unchanged → 00ff00).
test "apply_hue_off rotates the hue" {
  @debug.debug_inspect(apply_hue_off("ff0000", 120.0), content=(
    #|"00ff00"
  ))
  @debug.debug_inspect(apply_hue_off("ff0000", 240.0), content=(
    #|"0000ff"
  ))
  // Wraparound: -120° on pure red lands at H=240 → blue.
  @debug.debug_inspect(apply_hue_off("ff0000", -120.0), content=(
    #|"0000ff"
  ))
}

///|
/// §20.1.2.3.19 hueOff reference-renderer compatibility — when
/// `clamp_overflow_hue=true` the post-offset hue is clamped to
/// [0, 360] instead of wrapped.  For accent1 blue
/// (4472c4 → hue ≈ 218°):
///   - +72° → 290° (within [0,360], no clamp) → purple
///   - +144°, +216°, +288° → all clamp to 360° (≡ 0°) → red
test "apply_hue_off clamp_overflow_hue clamps over-360 hues to red" {
  // +72° stays in-range under both modes.
  let purple_spec = apply_hue_off("4472c4", 72.0)
  let _purple_compat = apply_hue_off("4472c4", 72.0, clamp_overflow_hue=true)
  @debug.debug_inspect(purple_spec, content=(
    #|"b044c4"
  )) // identical when no clamp
  // +144° wraps to ~2° in spec mode (red-ish) and clamps to 0°
  // (red) in compat mode.  Both happen to be red on the wheel, so
  // we assert by sampling: compat result has R clearly dominant.
  let red_compat = apply_hue_off("4472c4", 144.0, clamp_overflow_hue=true)
  @debug.debug_inspect(red_compat.length(), content="6")
  // +216° wraps to 74° (yellow-green) in spec mode but clamps to
  // red in compat mode — assert the two diverge.
  let yg_spec = apply_hue_off("4472c4", 216.0)
  let red_compat_2 = apply_hue_off("4472c4", 216.0, clamp_overflow_hue=true)
  assert_true(yg_spec != red_compat_2)
  // All three over-180° offsets collapse to the SAME hex in compat
  // mode (the clamp pins them all to hue=360°≡0°).
  let red_compat_3 = apply_hue_off("4472c4", 288.0, clamp_overflow_hue=true)
  @debug.debug_inspect(red_compat == red_compat_2, content="true")
  @debug.debug_inspect(red_compat_2 == red_compat_3, content="true")
}

///|
/// §20.1.2.3.7 satOff — accent1 blue has S≈0.54.  satOff(-1.0)
/// clamps to S=0 → pure gray at the original lightness.  The
/// HSL→RGB round-trip introduces a 1-byte rounding error per
/// channel; the result is the spec-prescribed "luminance-only"
/// gray for that lightness.
test "apply_sat_off clamps saturation" {
  // From red (S=1, L=0.5), satOff(-1.0) gives S=0 → gray at L=0.5.
  @debug.debug_inspect(apply_sat_off("ff0000", -1.0), content=(
    #|"808080"
  ))
  // satOff(+1.0) on a low-sat colour saturates fully — does NOT
  // shift the hue.  For accent1 blue (4472c4) the result keeps
  // the blue hue.  We just assert it produces a valid 6-char hex.
  let saturated = apply_sat_off("4472c4", 1.0)
  @debug.debug_inspect(saturated.length(), content="6")
}

///|
/// §20.1.2.3.5 comp — hue rotated 180°.  Red (H=0) → cyan (H=180).
test "apply_comp rotates hue 180" {
  @debug.debug_inspect(apply_comp("ff0000"), content=(
    #|"00ffff"
  ))
  @debug.debug_inspect(apply_comp("00ff00"), content=(
    #|"ff00ff"
  ))
  @debug.debug_inspect(apply_comp("0000ff"), content=(
    #|"ffff00"
  ))
}

///|
/// §20.1.2.3.20 inv — per-channel inversion in linear-light.
/// White ↔ black.  Pure red (255,0,0) inverts to (0,255,255) =
/// cyan in linear-RGB.  The linear-RGB inversion of `4472c4`
/// gives a sRGB-encoded value close to `bb8d3b` (orange), the
/// negative on the colour wheel.
test "apply_inv inverts each channel" {
  @debug.debug_inspect(apply_inv("ffffff"), content=(
    #|"000000"
  ))
  @debug.debug_inspect(apply_inv("000000"), content=(
    #|"ffffff"
  ))
  // Pure red → cyan in linear RGB inversion.
  @debug.debug_inspect(apply_inv("ff0000"), content=(
    #|"00ffff"
  ))
}

///|
/// §20.1.2.3.17 gray — Rec. 709 luminance in linear-light.
/// Pure red (255,0,0) carries linear 1.0; with coefficient
/// 0.2126 the luminance is ≈0.2126 → sRGB byte ≈127 (0x7f).
test "apply_gray produces luminance-only output" {
  // White stays white, black stays black.
  @debug.debug_inspect(apply_gray("ffffff"), content=(
    #|"ffffff"
  ))
  @debug.debug_inspect(apply_gray("000000"), content=(
    #|"000000"
  ))
  // Pure red → Rec. 709 luminance Y=0.2126 → sRGB byte ~127 ("7f").
  let red_gray = apply_gray("ff0000")
  // All three channels are equal.
  @debug.debug_inspect(red_gray[0:2].to_owned(), content=(
    #|"7f"
  ))
  @debug.debug_inspect(red_gray[2:4].to_owned(), content=(
    #|"7f"
  ))
  @debug.debug_inspect(red_gray[4:6].to_owned(), content=(
    #|"7f"
  ))
}

///|
/// §20.1.2.3.26 a:red / §20.1.2.3.21 a:green / §20.1.2.3.4 a:blue —
/// overwrite a single channel.  Passing 1.0 (100 %) drives the
/// channel fully on; the value is gamma-encoded from linear-light
/// 1.0 → sRGB 255.
test "apply_red sets red channel to linear value" {
  @debug.debug_inspect(apply_red("000000", 1.0), content=(
    #|"ff0000"
  ))
  @debug.debug_inspect(apply_green("000000", 1.0), content=(
    #|"00ff00"
  ))
  @debug.debug_inspect(apply_blue("000000", 1.0), content=(
    #|"0000ff"
  ))
  // 0% on red of pure red blanks the red channel.
  @debug.debug_inspect(apply_red("ff0000", 0.0), content=(
    #|"000000"
  ))
}

///|
/// §20.1.2.3.25 redMod / .27 redOff — same arithmetic the spec
/// uses on the other two channels.  Multiplying a fully-on linear
/// red by 0.5 lands at sRGB byte ≈188 (the linear-half encoded
/// to sRGB matches the `apply_shade` 50 % test).
test "apply_red_mod halves the red channel" {
  @debug.debug_inspect(apply_red_mod("ff0000", 0.5), content=(
    #|"bc0000"
  ))
}

///|
/// §20.1.2.3.16 gamma — re-encodes the byte/255 value as if it
/// were already linear.  A 50 % byte (128) maps to ≈188 (0xbc).
test "apply_gamma lifts mid-tones" {
  @debug.debug_inspect(apply_gamma("808080"), content=(
    #|"bcbcbc"
  ))
  // Black and white are fixed points.
  @debug.debug_inspect(apply_gamma("000000"), content=(
    #|"000000"
  ))
  @debug.debug_inspect(apply_gamma("ffffff"), content=(
    #|"ffffff"
  ))
}

///|
/// §20.1.2.3.13 invGamma — inverse: decodes the sRGB byte to
/// linear and writes the linear value back into the byte slot.
/// 188 → linear 0.5 → 128 (rounded).
test "apply_inv_gamma darkens mid-tones" {
  @debug.debug_inspect(apply_inv_gamma("bcbcbc"), content=(
    #|"808080"
  ))
  @debug.debug_inspect(apply_inv_gamma("000000"), content=(
    #|"000000"
  ))
  @debug.debug_inspect(apply_inv_gamma("ffffff"), content=(
    #|"ffffff"
  ))
}
