// @source web-pptx packages/@aurochs/color/src/types.ts

///|
/// RGB color in the 0-255 range per channel. Carrying `Double` (not
/// `Int`) lets intermediate arithmetic accumulate fractional values
/// before the final rounding.  Mirrors `RgbColor` in `types.ts:14`.
pub(all) struct RgbColor {
  r : Double
  g : Double
  b : Double
} derive(Eq)

///|
/// HSL color. `h` in degrees [0, 360), `s` and `l` in [0, 1].
/// `a` is optional alpha in [0, 1].  Mirrors `HslColor` in
/// `types.ts:6`.
pub(all) struct HslColor {
  h : Double
  s : Double
  l : Double
  a : Double?
} derive(Eq)
