// White-box tests for `util/color`.  Validates conversions and
// DrawingML colour transforms against the web-pptx reference values.

///|
test "hex_to_rgb 6-digit form" {
  let c = hex_to_rgb("FF0000")
  inspect(c.r, content="255")
  inspect(c.g, content="0")
  inspect(c.b, content="0")
}

///|
test "hex_to_rgb 3-digit form expands to 6" {
  // #ABC → #AABBCC
  let c = hex_to_rgb("ABC")
  inspect(c.r, content="170")
  inspect(c.g, content="187")
  inspect(c.b, content="204")
}

///|
test "hex_to_rgb strips leading hash" {
  let c = hex_to_rgb("#00FF00")
  inspect(c.r, content="0")
  inspect(c.g, content="255")
  inspect(c.b, content="0")
}

///|
test "to_hex pads single digit" {
  inspect(to_hex(15.0), content="0f")
  inspect(to_hex(0.0), content="00")
  inspect(to_hex(255.0), content="ff")
}

///|
test "rgb_to_hex round trips primary colors" {
  inspect(rgb_to_hex(255.0, 0.0, 0.0), content="ff0000")
  inspect(rgb_to_hex(0.0, 255.0, 0.0), content="00ff00")
  inspect(rgb_to_hex(0.0, 0.0, 255.0), content="0000ff")
}

///|
test "rgb_to_hsl basic conversions" {
  // Pure red: H=0, S=1, L=0.5
  let red = rgb_to_hsl(255.0, 0.0, 0.0)
  inspect(red.h, content="0")
  inspect(red.s, content="1")
  inspect(red.l, content="0.5")
}

///|
test "apply_shade 50% halves RGB" {
  // Pure red shaded by 50% → (128, 0, 0) ≈ #800000
  inspect(apply_shade("ff0000", 0.5), content="800000")
}

///|
test "apply_shade 0 yields black" {
  inspect(apply_shade("ff0000", 0.0), content="000000")
}

///|
test "apply_tint 50% moves halfway to white" {
  // r' = 255 + 0 = 255; g' = 0 + 255 * 0.5 = 127.5 → 128
  inspect(apply_tint("ff0000", 0.5), content="ff8080")
}

///|
test "named color lookup returns lowercase hex" {
  inspect(get_color_name_to_hex("red"), content="Some(ff0000)")
  inspect(get_color_name_to_hex("RED"), content="Some(ff0000)")
  inspect(get_color_name_to_hex("Black"), content="Some(000000)")
  inspect(get_color_name_to_hex("rebeccapurple"), content="Some(663399)")
  inspect(get_color_name_to_hex("not-a-color"), content="None")
}

///|
test "hsl_to_hex_string preserves color through round trip" {
  // ff0000 (red) → HSL(0, 1, 0.5) → ff0000
  let hsl = parse_color_to_hsl("ff0000")
  inspect(hsl_to_hex_string(hsl, false), content="ff0000")
}

///|
test "apply_lum_off increases lightness" {
  // Pure red has L=0.5. lumOff +0.2 → L=0.7 (lighter red).
  let result = apply_lum_off("ff0000", 0.2)
  // Result should be lighter than ff0000: parse and check L > 0.5.
  let hsl = parse_color_to_hsl(result)
  assert_true(hsl.l > 0.5)
}
