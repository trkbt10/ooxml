///|
/// XSD complex type CT_ComplementTransform — Part 1 §20.1.8.19 comp.
/// Annex A.4.1 line 270. Empty complex type: the `comp` element's
/// presence alone signals "complement the color"; no attributes or
/// children are allowed. The struct carries a marker so the typed
/// projection is distinguishable from raw XML and survives the
/// ct-typing gate.
pub(all) struct CT_ComplementTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ComplementTransform::new(
  element : @xml.Element,
) -> CT_ComplementTransform {
  { transform: true, element }
}

///|
pub fn CT_ComplementTransform::to_element(
  self : CT_ComplementTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_InverseTransform — Part 1 §20.1.8.41 inv. Annex
/// A.4.1 line 271. Empty complex type (no attributes/children) per
/// EG_ColorTransform choice arm.
pub(all) struct CT_InverseTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_InverseTransform::new(element : @xml.Element) -> CT_InverseTransform {
  { transform: true, element }
}

///|
pub fn CT_InverseTransform::to_element(
  self : CT_InverseTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GrayscaleTransform — Part 1 §20.1.8.35 gray.
/// Annex A.4.1 line 272. Empty complex type per EG_ColorTransform
/// choice arm.
pub(all) struct CT_GrayscaleTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GrayscaleTransform::new(
  element : @xml.Element,
) -> CT_GrayscaleTransform {
  { transform: true, element }
}

///|
pub fn CT_GrayscaleTransform::to_element(
  self : CT_GrayscaleTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GammaTransform — Part 1 §20.1.8.31 gamma. Annex
/// A.4.1 line 273. Empty complex type per EG_ColorTransform choice arm.
pub(all) struct CT_GammaTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GammaTransform::new(element : @xml.Element) -> CT_GammaTransform {
  { transform: true, element }
}

///|
pub fn CT_GammaTransform::to_element(self : CT_GammaTransform) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_InverseGammaTransform — Part 1 §20.1.8.42
/// invGamma. Annex A.4.1 line 274. Empty complex type per
/// EG_ColorTransform choice arm.
pub(all) struct CT_InverseGammaTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_InverseGammaTransform::new(
  element : @xml.Element,
) -> CT_InverseGammaTransform {
  { transform: true, element }
}

///|
pub fn CT_InverseGammaTransform::to_element(
  self : CT_InverseGammaTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaBiLevelEffect — Part 1 §20.1.8.1
/// alphaBiLevel. Annex A.4.1 lines 1242..1244. Required `thresh`
/// (ST_PositiveFixedPercentage) — the threshold at or above which
/// alpha snaps to fully opaque.
pub(all) struct CT_AlphaBiLevelEffect {
  /// @thresh — ST_PositiveFixedPercentage (required).
  thresh : ST_PositiveFixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaBiLevelEffect::new(
  element : @xml.Element,
) -> CT_AlphaBiLevelEffect raise SchemaViolation {
  let thresh_lex = ct_required_string(
    element, "thresh", "CT_AlphaBiLevelEffect/@thresh",
  )
  let thresh = ST_PositiveFixedPercentage::parse(thresh_lex)
  { thresh, element }
}

///|
pub fn CT_AlphaBiLevelEffect::to_element(
  self : CT_AlphaBiLevelEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaCeilingEffect — Part 1 §20.1.8.2
/// alphaCeiling. Annex A.4.1 line 1245. Empty complex type — alpha
/// is forced to fully opaque whenever it is non-zero.
pub(all) struct CT_AlphaCeilingEffect {
  /// Empty-XSD-type marker (always true once decoded).
  effect : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaCeilingEffect::new(
  element : @xml.Element,
) -> CT_AlphaCeilingEffect {
  { effect: true, element }
}

///|
pub fn CT_AlphaCeilingEffect::to_element(
  self : CT_AlphaCeilingEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaFloorEffect — Part 1 §20.1.8.3 alphaFloor.
/// Annex A.4.1 line 1246. Empty complex type — alpha is forced to
/// fully transparent whenever it is below full.
pub(all) struct CT_AlphaFloorEffect {
  /// Empty-XSD-type marker (always true once decoded).
  effect : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaFloorEffect::new(element : @xml.Element) -> CT_AlphaFloorEffect {
  { effect: true, element }
}

///|
pub fn CT_AlphaFloorEffect::to_element(
  self : CT_AlphaFloorEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaInverseEffect — Part 1 §20.1.8.4 alphaInv.
/// Annex A.4.1 lines 1247..1251. Optional EG_ColorChoice arm: when
/// present the inverted alpha is replaced with the supplied colour.
pub(all) struct CT_AlphaInverseEffect {
  /// Optional EG_ColorChoice arm captured as a CT_Color projection.
  color : CT_Color?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaInverseEffect::new(
  element : @xml.Element,
) -> CT_AlphaInverseEffect raise SchemaViolation {
  let color = if has_any_color_choice_child(element) {
    Some(CT_Color::new(element))
  } else {
    None
  }
  { color, element }
}

///|
pub fn CT_AlphaInverseEffect::to_element(
  self : CT_AlphaInverseEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaModulateFixedEffect — Part 1 §20.1.8.6
/// alphaModFix. Annex A.4.1 lines 1252..1254. Optional `amt`
/// (ST_PositivePercentage, default 100%) — multiplicative alpha
/// modulation amount.
pub(all) struct CT_AlphaModulateFixedEffect {
  /// @amt — ST_PositivePercentage (optional, default 100%).
  amt : ST_PositivePercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaModulateFixedEffect::new(
  element : @xml.Element,
) -> CT_AlphaModulateFixedEffect raise SchemaViolation {
  let amt = match ct_attr(element, "amt") {
    Some(v) => ST_PositivePercentage::parse(v)
    None => ST_PositivePercentage::parse("100%")
  }
  { amt, element }
}

///|
pub fn CT_AlphaModulateFixedEffect::to_element(
  self : CT_AlphaModulateFixedEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaOutsetEffect — Part 1 §20.1.8.7
/// alphaOutset. Annex A.4.1 lines 1255..1257. Optional `rad`
/// (ST_Coordinate, default 0) — radius of the alpha outset in
/// EMU.
pub(all) struct CT_AlphaOutsetEffect {
  /// @rad — ST_Coordinate (optional, default 0 EMU).
  rad : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaOutsetEffect::new(
  element : @xml.Element,
) -> CT_AlphaOutsetEffect raise SchemaViolation {
  let rad = match ct_attr(element, "rad") {
    Some(v) => ST_Coordinate::parse(v)
    None => ST_Coordinate::parse("0")
  }
  { rad, element }
}

///|
pub fn CT_AlphaOutsetEffect::to_element(
  self : CT_AlphaOutsetEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaReplaceEffect — Part 1 §20.1.8.8 alphaRepl.
/// Annex A.4.1 lines 1258..1260. Required `a`
/// (ST_PositiveFixedPercentage) — the replacement opacity to write into
/// every non-zero source alpha value.
pub(all) struct CT_AlphaReplaceEffect {
  /// @a — ST_PositiveFixedPercentage (required).
  a : ST_PositiveFixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaReplaceEffect::new(
  element : @xml.Element,
) -> CT_AlphaReplaceEffect raise SchemaViolation {
  let a_lex = ct_required_string(element, "a", "CT_AlphaReplaceEffect/@a")
  let a = ST_PositiveFixedPercentage::parse(a_lex)
  { a, element }
}

///|
pub fn CT_AlphaReplaceEffect::to_element(
  self : CT_AlphaReplaceEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BiLevelEffect — Part 1 §20.1.8.11 biLevel. Annex
/// A.4.1 lines 1261..1263. Required `thresh`
/// (ST_PositiveFixedPercentage) — luminance threshold above which the
/// pixel is forced to white (otherwise black).
pub(all) struct CT_BiLevelEffect {
  /// @thresh — ST_PositiveFixedPercentage (required).
  thresh : ST_PositiveFixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BiLevelEffect::new(
  element : @xml.Element,
) -> CT_BiLevelEffect raise SchemaViolation {
  let thresh_lex = ct_required_string(
    element, "thresh", "CT_BiLevelEffect/@thresh",
  )
  let thresh = ST_PositiveFixedPercentage::parse(thresh_lex)
  { thresh, element }
}

///|
pub fn CT_BiLevelEffect::to_element(self : CT_BiLevelEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BlurEffect — Part 1 §20.1.8.15 blur. Annex A.4.1
/// lines 1264..1267. Optional `rad` (ST_PositiveCoordinate, default 0)
/// — blur radius in EMU — and optional `grow` (xsd:boolean, default
/// true) — whether the bounding box expands with the blur.
pub(all) struct CT_BlurEffect {
  /// @rad — ST_PositiveCoordinate (optional, default 0 EMU).
  rad : ST_PositiveCoordinate
  /// @grow — xsd:boolean (optional, default true).
  grow : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BlurEffect::new(
  element : @xml.Element,
) -> CT_BlurEffect raise SchemaViolation {
  let rad = match ct_attr(element, "rad") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let grow = ct_optional_bool(
    element,
    "grow",
    default=true,
    "CT_BlurEffect/@grow",
  )
  { rad, grow, element }
}

///|
pub fn CT_BlurEffect::to_element(self : CT_BlurEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DuotoneEffect — Part 1 §20.1.8.23 duotone. Annex
/// A.4.1 lines 1280..1284. Exactly two EG_ColorChoice arms in document
/// order; each captured as a `CT_Color` projection so caller code can
/// read both endpoints.
pub(all) struct CT_DuotoneEffect {
  /// EG_ColorChoice (×2). Captured as CT_Color projections of the two
  /// color choice children in document order.
  colors : Array[CT_Color]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DuotoneEffect::new(
  element : @xml.Element,
) -> CT_DuotoneEffect raise SchemaViolation {
  let colors : Array[CT_Color] = []
  for node in element.children {
    match node {
      @xml.Element(child) => {
        let name = child.name.local_name
        match name {
          "scrgbClr"
          | "srgbClr"
          | "hslClr"
          | "sysClr"
          | "schemeClr"
          | "prstClr" => colors.push(CT_Color::new(child))
          _ => ()
        }
      }
      _ => ()
    }
  }
  { colors, element }
}

///|
pub fn CT_DuotoneEffect::to_element(self : CT_DuotoneEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GlowEffect — Part 1 §20.1.8.32 glow. Annex A.4.1
/// lines 1285..1290. Required single EG_ColorChoice arm (glow colour)
/// and optional `rad` (ST_PositiveCoordinate, default 0 EMU) — glow
/// radius.
pub(all) struct CT_GlowEffect {
  /// EG_ColorChoice (required) captured as a CT_Color projection.
  color : CT_Color
  /// @rad — ST_PositiveCoordinate (optional, default 0 EMU).
  rad : ST_PositiveCoordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GlowEffect::new(
  element : @xml.Element,
) -> CT_GlowEffect raise SchemaViolation {
  let color = CT_Color::new(element)
  let rad = match ct_attr(element, "rad") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  { color, rad, element }
}

///|
pub fn CT_GlowEffect::to_element(self : CT_GlowEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GrayscaleEffect — Part 1 §20.1.8.34 grayscl.
/// Annex A.4.1 line 1291. Empty complex type — the `grayscl` element's
/// presence alone applies the greyscale conversion.
pub(all) struct CT_GrayscaleEffect {
  /// Empty-XSD-type marker (always true once decoded).
  effect : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GrayscaleEffect::new(element : @xml.Element) -> CT_GrayscaleEffect {
  { effect: true, element }
}

///|
pub fn CT_GrayscaleEffect::to_element(
  self : CT_GrayscaleEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HSLEffect — Part 1 §20.1.8.39 hsl. Annex A.4.1
/// lines 1292..1296. Three optional shift attributes: `hue`
/// (ST_PositiveFixedAngle, default 0), `sat` (ST_FixedPercentage,
/// default 0%), `lum` (ST_FixedPercentage, default 0%).
pub(all) struct CT_HSLEffect {
  /// @hue — ST_PositiveFixedAngle (optional, default 0).
  hue : ST_PositiveFixedAngle
  /// @sat — ST_FixedPercentage (optional, default 0%).
  sat : ST_FixedPercentage
  /// @lum — ST_FixedPercentage (optional, default 0%).
  lum : ST_FixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HSLEffect::new(
  element : @xml.Element,
) -> CT_HSLEffect raise SchemaViolation {
  let hue = match ct_attr(element, "hue") {
    Some(v) => ST_PositiveFixedAngle::parse(v)
    None => ST_PositiveFixedAngle::parse("0")
  }
  let sat = match ct_attr(element, "sat") {
    Some(v) => ST_FixedPercentage::parse(v)
    None => ST_FixedPercentage::parse("0%")
  }
  let lum = match ct_attr(element, "lum") {
    Some(v) => ST_FixedPercentage::parse(v)
    None => ST_FixedPercentage::parse("0%")
  }
  { hue, sat, lum, element }
}

///|
pub fn CT_HSLEffect::to_element(self : CT_HSLEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_InnerShadowEffect — Part 1 §20.1.8.40 innerShdw.
/// Annex A.4.1 lines 1297..1304. Required EG_ColorChoice (shadow
/// colour) plus three optional shadow geometry attributes: `blurRad`,
/// `dist` (both ST_PositiveCoordinate, default 0 EMU) and `dir`
/// (ST_PositiveFixedAngle, default 0 sixty-thousandths of a degree).
pub(all) struct CT_InnerShadowEffect {
  /// EG_ColorChoice (required) captured as a CT_Color projection.
  color : CT_Color
  /// @blurRad — ST_PositiveCoordinate (optional, default 0 EMU).
  blur_rad : ST_PositiveCoordinate
  /// @dist — ST_PositiveCoordinate (optional, default 0 EMU).
  dist : ST_PositiveCoordinate
  /// @dir — ST_PositiveFixedAngle (optional, default 0).
  dir : ST_PositiveFixedAngle
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_InnerShadowEffect::new(
  element : @xml.Element,
) -> CT_InnerShadowEffect raise SchemaViolation {
  let color = CT_Color::new(element)
  let blur_rad = match ct_attr(element, "blurRad") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let dist = match ct_attr(element, "dist") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let dir = match ct_attr(element, "dir") {
    Some(v) => ST_PositiveFixedAngle::parse(v)
    None => ST_PositiveFixedAngle::parse("0")
  }
  { color, blur_rad, dist, dir, element }
}

///|
pub fn CT_InnerShadowEffect::to_element(
  self : CT_InnerShadowEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LuminanceEffect — Part 1 §20.1.8.42 lum. Annex
/// A.4.1 lines 1305..1308. Two optional luminance shift attributes:
/// `bright` and `contrast` (both ST_FixedPercentage, default 0%).
pub(all) struct CT_LuminanceEffect {
  /// @bright — ST_FixedPercentage (optional, default 0%).
  bright : ST_FixedPercentage
  /// @contrast — ST_FixedPercentage (optional, default 0%).
  contrast : ST_FixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LuminanceEffect::new(
  element : @xml.Element,
) -> CT_LuminanceEffect raise SchemaViolation {
  let bright = match ct_attr(element, "bright") {
    Some(v) => ST_FixedPercentage::parse(v)
    None => ST_FixedPercentage::parse("0%")
  }
  let contrast = match ct_attr(element, "contrast") {
    Some(v) => ST_FixedPercentage::parse(v)
    None => ST_FixedPercentage::parse("0%")
  }
  { bright, contrast, element }
}

///|
pub fn CT_LuminanceEffect::to_element(
  self : CT_LuminanceEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OuterShadowEffect — Part 1 §20.1.8.45 outerShdw.
/// Annex A.4.1 lines 1309..1322. Required EG_ColorChoice (shadow
/// colour) plus nine optional geometry / scale / skew / alignment
/// attributes.
pub(all) struct CT_OuterShadowEffect {
  /// EG_ColorChoice (required) captured as a CT_Color projection.
  color : CT_Color
  /// @blurRad — ST_PositiveCoordinate (optional, default 0 EMU).
  blur_rad : ST_PositiveCoordinate
  /// @dist — ST_PositiveCoordinate (optional, default 0 EMU).
  dist : ST_PositiveCoordinate
  /// @dir — ST_PositiveFixedAngle (optional, default 0).
  dir : ST_PositiveFixedAngle
  /// @sx — ST_Percentage (optional, default 100%).
  sx : ST_Percentage
  /// @sy — ST_Percentage (optional, default 100%).
  sy : ST_Percentage
  /// @kx — ST_FixedAngle (optional, default 0).
  kx : ST_FixedAngle
  /// @ky — ST_FixedAngle (optional, default 0).
  ky : ST_FixedAngle
  /// @algn — ST_RectAlignment (optional, default b).
  algn : ST_RectAlignment
  /// @rotWithShape — xsd:boolean (optional, default true).
  rot_with_shape : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OuterShadowEffect::new(
  element : @xml.Element,
) -> CT_OuterShadowEffect raise SchemaViolation {
  let color = CT_Color::new(element)
  let blur_rad = match ct_attr(element, "blurRad") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let dist = match ct_attr(element, "dist") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let dir = match ct_attr(element, "dir") {
    Some(v) => ST_PositiveFixedAngle::parse(v)
    None => ST_PositiveFixedAngle::parse("0")
  }
  let sx = match ct_attr(element, "sx") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("100%")
  }
  let sy = match ct_attr(element, "sy") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("100%")
  }
  let kx = match ct_attr(element, "kx") {
    Some(v) => ST_FixedAngle::parse(v)
    None => ST_FixedAngle::parse("0")
  }
  let ky = match ct_attr(element, "ky") {
    Some(v) => ST_FixedAngle::parse(v)
    None => ST_FixedAngle::parse("0")
  }
  let algn = match ct_attr(element, "algn") {
    Some(v) => ST_RectAlignment::parse(v)
    None => RectBottom
  }
  let rot_with_shape = ct_optional_bool(
    element,
    "rotWithShape",
    default=true,
    "CT_OuterShadowEffect/@rotWithShape",
  )
  { color, blur_rad, dist, dir, sx, sy, kx, ky, algn, rot_with_shape, element }
}

///|
pub fn CT_OuterShadowEffect::to_element(
  self : CT_OuterShadowEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresetShadowEffect — Part 1 §20.1.8.49 prstShdw.
/// Annex A.4.1 lines 1347..1354. Required EG_ColorChoice (shadow
/// colour) and required `prst` (ST_PresetShadowVal). Two optional
/// geometry attributes: `dist` (ST_PositiveCoordinate, default 0) and
/// `dir` (ST_PositiveFixedAngle, default 0).
pub(all) struct CT_PresetShadowEffect {
  /// EG_ColorChoice (required) captured as a CT_Color projection.
  color : CT_Color
  /// @prst — ST_PresetShadowVal (required).
  prst : ST_PresetShadowVal
  /// @dist — ST_PositiveCoordinate (optional, default 0 EMU).
  dist : ST_PositiveCoordinate
  /// @dir — ST_PositiveFixedAngle (optional, default 0).
  dir : ST_PositiveFixedAngle
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetShadowEffect::new(
  element : @xml.Element,
) -> CT_PresetShadowEffect raise SchemaViolation {
  let color = CT_Color::new(element)
  let prst_lex = ct_required_string(
    element, "prst", "CT_PresetShadowEffect/@prst",
  )
  let prst = ST_PresetShadowVal::parse(prst_lex)
  let dist = match ct_attr(element, "dist") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let dir = match ct_attr(element, "dir") {
    Some(v) => ST_PositiveFixedAngle::parse(v)
    None => ST_PositiveFixedAngle::parse("0")
  }
  { color, prst, dist, dir, element }
}

///|
pub fn CT_PresetShadowEffect::to_element(
  self : CT_PresetShadowEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ReflectionEffect — Part 1 §20.1.8.50 reflection.
/// Annex A.4.1 lines 1355..1370. Thirteen optional geometry / scale /
/// fade attributes; no child elements.
pub(all) struct CT_ReflectionEffect {
  /// @blurRad — ST_PositiveCoordinate (optional, default 0 EMU).
  blur_rad : ST_PositiveCoordinate
  /// @stA — ST_PositiveFixedPercentage (optional, default 100%).
  st_a : ST_PositiveFixedPercentage
  /// @stPos — ST_PositiveFixedPercentage (optional, default 0%).
  st_pos : ST_PositiveFixedPercentage
  /// @endA — ST_PositiveFixedPercentage (optional, default 0%).
  end_a : ST_PositiveFixedPercentage
  /// @endPos — ST_PositiveFixedPercentage (optional, default 100%).
  end_pos : ST_PositiveFixedPercentage
  /// @dist — ST_PositiveCoordinate (optional, default 0 EMU).
  dist : ST_PositiveCoordinate
  /// @dir — ST_PositiveFixedAngle (optional, default 0).
  dir : ST_PositiveFixedAngle
  /// @fadeDir — ST_PositiveFixedAngle (optional, default 5400000).
  fade_dir : ST_PositiveFixedAngle
  /// @sx — ST_Percentage (optional, default 100%).
  sx : ST_Percentage
  /// @sy — ST_Percentage (optional, default 100%).
  sy : ST_Percentage
  /// @kx — ST_FixedAngle (optional, default 0).
  kx : ST_FixedAngle
  /// @ky — ST_FixedAngle (optional, default 0).
  ky : ST_FixedAngle
  /// @algn — ST_RectAlignment (optional, default b).
  algn : ST_RectAlignment
  /// @rotWithShape — xsd:boolean (optional, default true).
  rot_with_shape : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ReflectionEffect::new(
  element : @xml.Element,
) -> CT_ReflectionEffect raise SchemaViolation {
  let blur_rad = match ct_attr(element, "blurRad") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let st_a = match ct_attr(element, "stA") {
    Some(v) => ST_PositiveFixedPercentage::parse(v)
    None => ST_PositiveFixedPercentage::parse("100%")
  }
  let st_pos = match ct_attr(element, "stPos") {
    Some(v) => ST_PositiveFixedPercentage::parse(v)
    None => ST_PositiveFixedPercentage::parse("0%")
  }
  let end_a = match ct_attr(element, "endA") {
    Some(v) => ST_PositiveFixedPercentage::parse(v)
    None => ST_PositiveFixedPercentage::parse("0%")
  }
  let end_pos = match ct_attr(element, "endPos") {
    Some(v) => ST_PositiveFixedPercentage::parse(v)
    None => ST_PositiveFixedPercentage::parse("100%")
  }
  let dist = match ct_attr(element, "dist") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let dir = match ct_attr(element, "dir") {
    Some(v) => ST_PositiveFixedAngle::parse(v)
    None => ST_PositiveFixedAngle::parse("0")
  }
  let fade_dir = match ct_attr(element, "fadeDir") {
    Some(v) => ST_PositiveFixedAngle::parse(v)
    None => ST_PositiveFixedAngle::parse("5400000")
  }
  let sx = match ct_attr(element, "sx") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("100%")
  }
  let sy = match ct_attr(element, "sy") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("100%")
  }
  let kx = match ct_attr(element, "kx") {
    Some(v) => ST_FixedAngle::parse(v)
    None => ST_FixedAngle::parse("0")
  }
  let ky = match ct_attr(element, "ky") {
    Some(v) => ST_FixedAngle::parse(v)
    None => ST_FixedAngle::parse("0")
  }
  let algn = match ct_attr(element, "algn") {
    Some(v) => ST_RectAlignment::parse(v)
    None => RectBottom
  }
  let rot_with_shape = ct_optional_bool(
    element,
    "rotWithShape",
    default=true,
    "CT_ReflectionEffect/@rotWithShape",
  )
  {
    blur_rad,
    st_a,
    st_pos,
    end_a,
    end_pos,
    dist,
    dir,
    fade_dir,
    sx,
    sy,
    kx,
    ky,
    algn,
    rot_with_shape,
    element,
  }
}

///|
pub fn CT_ReflectionEffect::to_element(
  self : CT_ReflectionEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RelativeOffsetEffect — Part 1 §20.1.8.51 relOff.
/// Annex A.4.1 lines 1371..1374. Two optional percentage offsets `tx`
/// and `ty` (ST_Percentage, both default 0%).
pub(all) struct CT_RelativeOffsetEffect {
  /// @tx — ST_Percentage (optional, default 0%).
  tx : ST_Percentage
  /// @ty — ST_Percentage (optional, default 0%).
  ty : ST_Percentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RelativeOffsetEffect::new(
  element : @xml.Element,
) -> CT_RelativeOffsetEffect raise SchemaViolation {
  let tx = match ct_attr(element, "tx") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("0%")
  }
  let ty = match ct_attr(element, "ty") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("0%")
  }
  { tx, ty, element }
}

///|
pub fn CT_RelativeOffsetEffect::to_element(
  self : CT_RelativeOffsetEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SoftEdgesEffect — Part 1 §20.1.8.53 softEdge.
/// Annex A.4.1 lines 1375..1377. Required `rad`
/// (ST_PositiveCoordinate) — soft edge radius in EMU.
pub(all) struct CT_SoftEdgesEffect {
  /// @rad — ST_PositiveCoordinate (required).
  rad : ST_PositiveCoordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SoftEdgesEffect::new(
  element : @xml.Element,
) -> CT_SoftEdgesEffect raise SchemaViolation {
  let rad_lex = ct_required_string(element, "rad", "CT_SoftEdgesEffect/@rad")
  let rad = ST_PositiveCoordinate::parse(rad_lex)
  { rad, element }
}

///|
pub fn CT_SoftEdgesEffect::to_element(
  self : CT_SoftEdgesEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TintEffect — Part 1 §20.1.8.60 tint. Annex A.4.1
/// lines 1378..1381. Two optional shift attributes: `hue`
/// (ST_PositiveFixedAngle, default 0) and `amt` (ST_FixedPercentage,
/// default 0%).
pub(all) struct CT_TintEffect {
  /// @hue — ST_PositiveFixedAngle (optional, default 0).
  hue : ST_PositiveFixedAngle
  /// @amt — ST_FixedPercentage (optional, default 0%).
  amt : ST_FixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TintEffect::new(
  element : @xml.Element,
) -> CT_TintEffect raise SchemaViolation {
  let hue = match ct_attr(element, "hue") {
    Some(v) => ST_PositiveFixedAngle::parse(v)
    None => ST_PositiveFixedAngle::parse("0")
  }
  let amt = match ct_attr(element, "amt") {
    Some(v) => ST_FixedPercentage::parse(v)
    None => ST_FixedPercentage::parse("0%")
  }
  { hue, amt, element }
}

///|
pub fn CT_TintEffect::to_element(self : CT_TintEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TransformEffect — Part 1 §20.1.8.61 xfrm. Annex
/// A.4.1 lines 1382..1389. Six optional 2D affine attributes: scale
/// `sx`/`sy` (ST_Percentage, default 100%), skew `kx`/`ky`
/// (ST_FixedAngle, default 0) and translation `tx`/`ty`
/// (ST_Coordinate, default 0).
pub(all) struct CT_TransformEffect {
  /// @sx — ST_Percentage (optional, default 100%).
  sx : ST_Percentage
  /// @sy — ST_Percentage (optional, default 100%).
  sy : ST_Percentage
  /// @kx — ST_FixedAngle (optional, default 0).
  kx : ST_FixedAngle
  /// @ky — ST_FixedAngle (optional, default 0).
  ky : ST_FixedAngle
  /// @tx — ST_Coordinate (optional, default 0 EMU).
  tx : ST_Coordinate
  /// @ty — ST_Coordinate (optional, default 0 EMU).
  ty : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TransformEffect::new(
  element : @xml.Element,
) -> CT_TransformEffect raise SchemaViolation {
  let sx = match ct_attr(element, "sx") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("100%")
  }
  let sy = match ct_attr(element, "sy") {
    Some(v) => ST_Percentage::parse(v)
    None => ST_Percentage::parse("100%")
  }
  let kx = match ct_attr(element, "kx") {
    Some(v) => ST_FixedAngle::parse(v)
    None => ST_FixedAngle::parse("0")
  }
  let ky = match ct_attr(element, "ky") {
    Some(v) => ST_FixedAngle::parse(v)
    None => ST_FixedAngle::parse("0")
  }
  let tx = match ct_attr(element, "tx") {
    Some(v) => ST_Coordinate::parse(v)
    None => ST_Coordinate::parse("0")
  }
  let ty = match ct_attr(element, "ty") {
    Some(v) => ST_Coordinate::parse(v)
    None => ST_Coordinate::parse("0")
  }
  { sx, sy, kx, ky, tx, ty, element }
}

///|
pub fn CT_TransformEffect::to_element(
  self : CT_TransformEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FillEffect — Part 1 §20.1.8.28 fill. Annex A.4.1
/// lines 1592..1596. Single required EG_FillProperties choice arm
/// (`noFill`, `solidFill`, `gradFill`, `blipFill`, `pattFill`, or
/// `grpFill`) captured via a CT_FillProperties projection.
pub(all) struct CT_FillEffect {
  /// EG_FillProperties choice arm (required) wrapped as
  /// CT_FillProperties for the fill choice container access.
  fill : CT_FillProperties
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FillEffect::new(
  element : @xml.Element,
) -> CT_FillEffect raise SchemaViolation {
  let fill = CT_FillProperties::new(element)
  { fill, element }
}

///|
pub fn CT_FillEffect::to_element(self : CT_FillEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FillOverlayEffect — Part 1 §20.1.8.29
/// fillOverlay. Annex A.4.1 lines 1606..1611. Required EG_FillProperties
/// choice arm and required `blend` (ST_BlendMode) — composition mode
/// between the overlay fill and the existing pixels.
pub(all) struct CT_FillOverlayEffect {
  /// EG_FillProperties choice arm (required).
  fill : CT_FillProperties
  /// @blend — ST_BlendMode (required).
  blend : ST_BlendMode
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FillOverlayEffect::new(
  element : @xml.Element,
) -> CT_FillOverlayEffect raise SchemaViolation {
  let fill = CT_FillProperties::new(element)
  let blend_lex = ct_required_string(
    element, "blend", "CT_FillOverlayEffect/@blend",
  )
  let blend = ST_BlendMode::parse(blend_lex)
  { fill, blend, element }
}

///|
pub fn CT_FillOverlayEffect::to_element(
  self : CT_FillOverlayEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EffectReference — Part 1 §20.1.8.24 effect. Annex
/// A.4.1 lines 1612..1614. Required `ref` (xsd:token) — name of the
/// effect being referenced within an effect DAG.
pub(all) struct CT_EffectReference {
  /// @ref — xsd:token (required).
  ref_ : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectReference::new(
  element : @xml.Element,
) -> CT_EffectReference raise SchemaViolation {
  let ref_ = ct_required_string(element, "ref", "CT_EffectReference/@ref")
  { ref_, element }
}

///|
pub fn CT_EffectReference::to_element(
  self : CT_EffectReference,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EffectContainer — Part 1 §20.1.8.20 cont. Annex
/// A.4.1 lines 1655..1659. Aggregates the EG_Effect choice group
/// (zero or more, typed via the `EG_Effect` sum) plus two optional
/// attributes: `type` (ST_EffectContainerType, default sib) and
/// `name` (xsd:token, optional).
pub(all) struct CT_EffectContainer {
  /// EG_Effect choice group, typed per Annex A.4.1 lines 1620..1654.
  effects : Array[EG_Effect]
  /// @type — ST_EffectContainerType (optional, default sib).
  type_ : ST_EffectContainerType
  /// @name — xsd:token (optional).
  name : String?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectContainer::new(
  element : @xml.Element,
) -> CT_EffectContainer raise SchemaViolation {
  let effects = collect_effects(element)
  let type_ = match ct_attr(element, "type") {
    Some(v) => ST_EffectContainerType::parse(v)
    None => EffectContainerSib
  }
  let name = ct_attr(element, "name")
  { effects, type_, name, element }
}

///|
pub fn CT_EffectContainer::to_element(
  self : CT_EffectContainer,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaModulateEffect — Part 1 §20.1.8.5 alphaMod.
/// Annex A.4.1 lines 1660..1664. Required single `cont`
/// (CT_EffectContainer) child whose enclosed effect tree supplies the
/// alpha modulation source.
pub(all) struct CT_AlphaModulateEffect {
  /// <cont> (CT_EffectContainer) — required.
  cont : CT_EffectContainer
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaModulateEffect::new(
  element : @xml.Element,
) -> CT_AlphaModulateEffect raise SchemaViolation {
  let cont = match ct_first_child(element, "cont") {
    Some(c) => CT_EffectContainer::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_AlphaModulateEffect/cont",
        reason="missing required child element <cont>",
      )
  }
  { cont, element }
}

///|
pub fn CT_AlphaModulateEffect::to_element(
  self : CT_AlphaModulateEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BlendEffect — Part 1 §20.1.8.12 blend. Annex
/// A.4.1 lines 1665..1670. Required `cont` (CT_EffectContainer) child
/// and required `blend` (ST_BlendMode) attribute.
pub(all) struct CT_BlendEffect {
  /// <cont> (CT_EffectContainer) — required.
  cont : CT_EffectContainer
  /// @blend — ST_BlendMode (required).
  blend : ST_BlendMode
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BlendEffect::new(
  element : @xml.Element,
) -> CT_BlendEffect raise SchemaViolation {
  let cont = match ct_first_child(element, "cont") {
    Some(c) => CT_EffectContainer::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_BlendEffect/cont",
        reason="missing required child element <cont>",
      )
  }
  let blend_lex = ct_required_string(element, "blend", "CT_BlendEffect/@blend")
  let blend = ST_BlendMode::parse(blend_lex)
  { cont, blend, element }
}

///|
pub fn CT_BlendEffect::to_element(self : CT_BlendEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EffectList — Part 1 §20.1.8.26 effectLst. Annex
/// A.4.1 lines 1671..1682. Eight optional child elements in fixed
/// order: `blur`, `fillOverlay`, `glow`, `innerShdw`, `outerShdw`,
/// `prstShdw`, `reflection`, `softEdge`.
pub(all) struct CT_EffectList {
  /// <blur> (CT_BlurEffect) — optional.
  blur : CT_BlurEffect?
  /// <fillOverlay> (CT_FillOverlayEffect) — optional.
  fill_overlay : CT_FillOverlayEffect?
  /// <glow> (CT_GlowEffect) — optional.
  glow : CT_GlowEffect?
  /// <innerShdw> (CT_InnerShadowEffect) — optional.
  inner_shdw : CT_InnerShadowEffect?
  /// <outerShdw> (CT_OuterShadowEffect) — optional.
  outer_shdw : CT_OuterShadowEffect?
  /// <prstShdw> (CT_PresetShadowEffect) — optional.
  prst_shdw : CT_PresetShadowEffect?
  /// <reflection> (CT_ReflectionEffect) — optional.
  reflection : CT_ReflectionEffect?
  /// <softEdge> (CT_SoftEdgesEffect) — optional.
  soft_edge : CT_SoftEdgesEffect?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectList::new(
  element : @xml.Element,
) -> CT_EffectList raise SchemaViolation {
  let blur = match ct_first_child(element, "blur") {
    Some(c) => Some(CT_BlurEffect::new(c))
    None => None
  }
  let fill_overlay = match ct_first_child(element, "fillOverlay") {
    Some(c) => Some(CT_FillOverlayEffect::new(c))
    None => None
  }
  let glow = match ct_first_child(element, "glow") {
    Some(c) => Some(CT_GlowEffect::new(c))
    None => None
  }
  let inner_shdw = match ct_first_child(element, "innerShdw") {
    Some(c) => Some(CT_InnerShadowEffect::new(c))
    None => None
  }
  let outer_shdw = match ct_first_child(element, "outerShdw") {
    Some(c) => Some(CT_OuterShadowEffect::new(c))
    None => None
  }
  let prst_shdw = match ct_first_child(element, "prstShdw") {
    Some(c) => Some(CT_PresetShadowEffect::new(c))
    None => None
  }
  let reflection = match ct_first_child(element, "reflection") {
    Some(c) => Some(CT_ReflectionEffect::new(c))
    None => None
  }
  let soft_edge = match ct_first_child(element, "softEdge") {
    Some(c) => Some(CT_SoftEdgesEffect::new(c))
    None => None
  }
  {
    blur,
    fill_overlay,
    glow,
    inner_shdw,
    outer_shdw,
    prst_shdw,
    reflection,
    soft_edge,
    element,
  }
}

///|
pub fn CT_EffectList::to_element(self : CT_EffectList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EffectProperties — Part 1 §20.1.8 EG_EffectProperties.
/// Annex A.4.1 lines 1683..1693. Single required EG_EffectProperties
/// choice arm (`effectLst` or `effectDag`); the projection holds at
/// most one of the two arms.
pub(all) struct CT_EffectProperties {
  /// <effectLst> (CT_EffectList) choice arm — present when chosen.
  effect_lst : CT_EffectList?
  /// <effectDag> (CT_EffectContainer) choice arm — present when chosen.
  effect_dag : CT_EffectContainer?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectProperties::new(
  element : @xml.Element,
) -> CT_EffectProperties raise SchemaViolation {
  let effect_lst = match ct_first_child(element, "effectLst") {
    Some(c) => Some(CT_EffectList::new(c))
    None => None
  }
  let effect_dag = match ct_first_child(element, "effectDag") {
    Some(c) => Some(CT_EffectContainer::new(c))
    None => None
  }
  { effect_lst, effect_dag, element }
}

///|
pub fn CT_EffectProperties::to_element(
  self : CT_EffectProperties,
) -> @xml.Element {
  self.element
}

///|
pub fn read_blur_effect(bytes : Bytes) -> CT_BlurEffect raise {
  CT_BlurEffect::new(read_main_root(bytes, "blur"))
}

///|
pub fn write_blur_effect(value : CT_BlurEffect) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_outer_shadow_effect(bytes : Bytes) -> CT_OuterShadowEffect raise {
  CT_OuterShadowEffect::new(read_main_root(bytes, "outerShdw"))
}

///|
pub fn write_outer_shadow_effect(value : CT_OuterShadowEffect) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_effect_list(bytes : Bytes) -> CT_EffectList raise {
  CT_EffectList::new(read_main_root(bytes, "effectLst"))
}

///|
pub fn write_effect_list(value : CT_EffectList) -> Bytes {
  write_element(value.element)
}
