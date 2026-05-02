# G4 Theme Color Design

## Package

`src/ecma376/drawing_ml/color_resolution` is a self-contained DrawingML subpackage. It owns the public resolver types (`Rgba8`, `ColorScheme`, `ColorRef`, `ColorTransform`, and `SchemeColorVal`) and XML readers for color references and theme color schemes.

## Resolution Model

`resolve_color` first materializes a base color:

- `Srgb` returns its parsed RGBA value.
- `Scheme` indexes the supplied `ColorScheme`; `bg1`, `tx1`, `bg2`, and `tx2` follow the standard DrawingML mapping to `lt1`, `dk1`, `lt2`, and `dk2`.
- `PhClr` uses the caller's `placeholder_color`, because §20.1.2.3.29 defines it as a placeholder sentinel rather than a concrete theme color.
- `Sys` uses `lastClr` when present and otherwise falls back to black; this keeps host OS color lookup outside the pure resolver.
- `Preset` maps the named preset to RGBA.
- `Hsl` converts the raw DrawingML hue angle and percentage fields to sRGB.

Transforms are then applied in document order.

## HSL Math

The resolver uses standard sRGB to HSL conversion with hue represented as a turn in `[0, 1)`. `tint`, `shade`, `lumMod`, `lumOff`, and `satMod` update HSL channels and convert back to 8-bit sRGB with rounding and clamping:

- `tint(v)`: `L = L * (1 - v / 100000) + v / 100000`
- `shade(v)`: `L = L * v / 100000`
- `lumMod(v)`: `L = L * v / 100000`
- `lumOff(v)`: `L = clamp(L + v / 100000, 0, 1)`
- `satMod(v)`: `S = clamp(S * v / 100000, 0, 1)`

## Transform Coverage

Effective transforms implemented: `tint`, `shade`, `lumMod`, `lumOff`, `satMod`, `hue`, `hueMod`, `hueOff`, `alpha`, `alphaMod`, `alphaOff`, `gamma`, `inv`, `comp`, and `gray`.

The public API does not currently model the component assignment/offset/modulation transforms (`red`, `redMod`, `redOff`, `green`, `greenMod`, `greenOff`, `blue`, `blueMod`, `blueOff`), `lum`, `sat`, `satOff`, or `invGamma`. `read_color_ref` rejects those elements with `SchemaViolation` instead of silently treating them as identity.
