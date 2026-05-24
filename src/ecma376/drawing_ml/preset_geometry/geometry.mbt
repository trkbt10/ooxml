///|
/// Part 1 §20.1.10.56 — generate the path commands for a preset
/// shape on a `[0, width] × [0, height]` bounding box. The dispatch
/// routes each preset to its per-family constructor; shapes outside
/// the canonical-30 catalogue (see `.indexion/plans/g11-preset-shapes`)
/// fall through to `rectangular_fallback` so the renderer never sees
/// an empty geometry — the fallback preserves the bounding box and
/// the document still round-trips.
///
/// `width` and `height` must be positive; non-positive values return
/// an empty fallback geometry rather than risk integer overflow in
/// the per-shape constructors.
pub fn build_geometry(
  shape : PresetShape,
  width : Int,
  height : Int,
) -> ShapeGeometry {
  if width <= 0 || height <= 0 {
    return { commands: [], width: 0, height: 0 }
  }
  match shape {
    ShapeRect
    | ShapeFlowChartProcess
    | ShapeFlowChartPredefinedProcess
    | ShapeFlowChartInternalStorage => build_rect(width, height)
    ShapeRoundRect
    | ShapeFlowChartTerminator
    | ShapeFlowChartAlternateProcess => build_round_rect(width, height)
    ShapePlaque => build_plaque(width, height)
    ShapeEllipse | ShapeFlowChartConnector => build_ellipse(width, height)
    ShapeTriangle => build_triangle(width, height)
    ShapeRtTriangle => build_right_triangle(width, height)
    ShapeParallelogram | ShapeFlowChartInputOutput =>
      build_parallelogram(width, height)
    ShapeTrapezoid => build_trapezoid(width, height)
    ShapeDiamond | ShapeFlowChartDecision => build_diamond(width, height)
    ShapePentagon => build_regular_polygon(5, width, height)
    ShapeHexagon => build_regular_polygon(6, width, height)
    ShapeHeptagon => build_regular_polygon(7, width, height)
    ShapeOctagon => build_regular_polygon(8, width, height)
    ShapeDecagon => build_regular_polygon(10, width, height)
    ShapeDodecagon => build_regular_polygon(12, width, height)
    ShapeStar4 => build_star(4, width, height)
    ShapeStar5 => build_star(5, width, height)
    ShapeStar6 => build_star(6, width, height)
    ShapeStar7 => build_star(7, width, height)
    ShapeStar8 => build_star(8, width, height)
    ShapeStar10 => build_star(10, width, height)
    ShapeStar12 => build_star(12, width, height)
    ShapeStar16 => build_star(16, width, height)
    ShapeStar24 => build_star(24, width, height)
    ShapeStar32 => build_star(32, width, height)
    ShapeRightArrow => build_right_arrow(width, height)
    ShapeLeftArrow => build_left_arrow(width, height)
    ShapeUpArrow => build_up_arrow(width, height)
    ShapeDownArrow => build_down_arrow(width, height)
    ShapeLeftRightArrow => build_left_right_arrow(width, height)
    ShapeUpDownArrow => build_up_down_arrow(width, height)
    ShapeNotchedRightArrow => build_notched_right_arrow(width, height)
    ShapeStripedRightArrow => build_striped_right_arrow(width, height)
    ShapeBentArrow => build_bent_arrow(width, height)
    ShapeBentUpArrow => build_bent_up_arrow(width, height)
    ShapeUturnArrow => build_uturn_arrow(width, height)
    ShapeLeftRightUpArrow => build_left_right_up_arrow(width, height)
    ShapeLeftUpArrow => build_left_up_arrow(width, height)
    ShapeQuadArrow => build_quad_arrow(width, height)
    ShapeRightArrowCallout => build_right_arrow_callout(width, height)
    ShapeLeftArrowCallout => build_left_arrow_callout(width, height)
    ShapeUpArrowCallout => build_up_arrow_callout(width, height)
    ShapeDownArrowCallout => build_down_arrow_callout(width, height)
    ShapeLeftRightArrowCallout => build_left_right_arrow_callout(width, height)
    ShapeUpDownArrowCallout => build_up_down_arrow_callout(width, height)
    ShapeQuadArrowCallout => build_quad_arrow_callout(width, height)
    ShapeCallout1 => build_callout1(width, height)
    ShapeCallout2 => build_callout2(width, height)
    ShapeCallout3 => build_callout3(width, height)
    ShapeHeart => build_heart(width, height)
    ShapeCloud => build_cloud(width, height)
    ShapeSmileyFace => build_smiley_face(width, height)
    ShapePlus | ShapeMathPlus => build_plus(width, height)
    ShapeMathMinus => build_minus(width, height)
    ShapeMathMultiply => build_multiply(width, height)
    ShapeMathDivide => build_divide(width, height)
    ShapeMathEqual => build_equal(width, height)
    ShapeHomePlate => build_home_plate(width, height)
    ShapeChevron => build_chevron(width, height)
    ShapeFrame => build_frame(width, height)
    ShapeHalfFrame => build_half_frame(width, height)
    ShapeCorner => build_corner(width, height)
    ShapeDiagStripe => build_diag_stripe(width, height)
    ShapeCube => build_cube(width, height)
    ShapeCan => build_can(width, height)
    ShapeBevel => build_bevel(width, height)
    ShapeFoldedCorner => build_folded_corner(width, height)
    ShapeChartX => build_chart_x(width, height)
    ShapeChartPlus => build_chart_plus(width, height)
    ShapeChartStar => build_chart_star(width, height)
    ShapeFlowChartDocument => build_flow_chart_document(width, height)
    ShapeFlowChartMultidocument => build_flow_chart_multidocument(width, height)
    ShapeFlowChartPreparation => build_flow_chart_preparation(width, height)
    ShapeFlowChartManualInput => build_flow_chart_manual_input(width, height)
    ShapeFlowChartManualOperation =>
      build_flow_chart_manual_operation(width, height)
    ShapeFlowChartExtract => build_flow_chart_extract(width, height)
    ShapeFlowChartMerge => build_flow_chart_merge(width, height)
    ShapeFlowChartPunchedCard => build_flow_chart_punched_card(width, height)
    ShapeFlowChartPunchedTape => build_flow_chart_punched_tape(width, height)
    ShapeFlowChartSort => build_flow_chart_sort(width, height)
    ShapeFlowChartCollate => build_flow_chart_collate(width, height)
    ShapeFlowChartOr => build_flow_chart_or(width, height)
    ShapeFlowChartSummingJunction =>
      build_flow_chart_summing_junction(width, height)
    ShapeFlowChartOfflineStorage =>
      build_flow_chart_offline_storage(width, height)
    ShapeFlowChartOnlineStorage =>
      build_flow_chart_online_storage(width, height)
    ShapeFlowChartMagneticDisk => build_flow_chart_magnetic_disk(width, height)
    ShapeFlowChartMagneticDrum => build_flow_chart_magnetic_drum(width, height)
    ShapeFlowChartMagneticTape => build_flow_chart_magnetic_tape(width, height)
    ShapeFlowChartDelay => build_flow_chart_delay(width, height)
    ShapeFlowChartDisplay => build_flow_chart_display(width, height)
    ShapeFlowChartOffpageConnector =>
      build_flow_chart_offpage_connector(width, height)
    ShapeRound1Rect => build_round1_rect(width, height)
    ShapeRound2SameRect => build_round2_same_rect(width, height)
    ShapeRound2DiagRect => build_round2_diag_rect(width, height)
    ShapeSnip1Rect => build_snip1_rect(width, height)
    ShapeSnip2SameRect => build_snip2_same_rect(width, height)
    ShapeSnip2DiagRect => build_snip2_diag_rect(width, height)
    ShapeSnipRoundRect => build_snip_round_rect(width, height)
    ShapeWedgeRectCallout => build_wedge_rect_callout(width, height)
    ShapeWedgeRoundRectCallout => build_wedge_round_rect_callout(width, height)
    ShapeWedgeEllipseCallout => build_wedge_ellipse_callout(width, height)
    ShapeBracketPair => build_bracket_pair(width, height)
    ShapeLeftBracket => build_left_bracket(width, height)
    ShapeRightBracket => build_right_bracket(width, height)
    ShapeBracePair => build_brace_pair(width, height)
    ShapeLeftBrace => build_left_brace(width, height)
    ShapeRightBrace => build_right_brace(width, height)
    ShapeBorderCallout1 => build_border_callout1(width, height)
    ShapeBorderCallout2 => build_border_callout2(width, height)
    ShapeBorderCallout3 => build_border_callout3(width, height)
    ShapeAccentCallout1 => build_accent_callout1(width, height)
    ShapeAccentCallout2 => build_accent_callout2(width, height)
    ShapeAccentCallout3 => build_accent_callout3(width, height)
    ShapeAccentBorderCallout1 => build_accent_border_callout1(width, height)
    ShapeAccentBorderCallout2 => build_accent_border_callout2(width, height)
    ShapeAccentBorderCallout3 => build_accent_border_callout3(width, height)
    ShapeCloudCallout => build_cloud_callout(width, height)
    ShapeDonut => build_donut(width, height)
    ShapeBlockArc => build_block_arc(width, height)
    ShapeArc => build_arc(width, height)
    ShapeChord => build_chord(width, height)
    ShapePie => build_pie(width, height)
    ShapePieWedge => build_pie_wedge(width, height)
    ShapeNoSmoking => build_no_smoking(width, height)
    ShapeTeardrop => build_teardrop(width, height)
    ShapeMoon => build_moon(width, height)
    ShapeSun => build_sun(width, height)
    ShapeActionButtonBlank => build_action_button_blank(width, height)
    ShapeActionButtonHome => build_action_button_home(width, height)
    ShapeActionButtonHelp => build_action_button_help(width, height)
    ShapeActionButtonInformation =>
      build_action_button_information(width, height)
    ShapeActionButtonForwardNext =>
      build_action_button_forward_next(width, height)
    ShapeActionButtonBackPrevious =>
      build_action_button_back_previous(width, height)
    ShapeActionButtonBeginning => build_action_button_beginning(width, height)
    ShapeActionButtonEnd => build_action_button_end(width, height)
    ShapeActionButtonReturn => build_action_button_return(width, height)
    ShapeActionButtonDocument => build_action_button_document(width, height)
    ShapeActionButtonSound => build_action_button_sound(width, height)
    ShapeActionButtonMovie => build_action_button_movie(width, height)
    ShapeGear6 => build_gear6(width, height)
    ShapeGear9 => build_gear9(width, height)
    ShapeFunnel => build_funnel(width, height)
    ShapeLightningBolt => build_lightning_bolt(width, height)
    ShapeIrregularSeal1 => build_irregular_seal1(width, height)
    ShapeIrregularSeal2 => build_irregular_seal2(width, height)
    ShapeCurvedRightArrow => build_curved_right_arrow(width, height)
    ShapeCurvedLeftArrow => build_curved_left_arrow(width, height)
    ShapeCurvedUpArrow => build_curved_up_arrow(width, height)
    ShapeCurvedDownArrow => build_curved_down_arrow(width, height)
    ShapeCircularArrow => build_circular_arrow(width, height)
    ShapeRibbon => build_ribbon(width, height)
    ShapeRibbon2 => build_ribbon2(width, height)
    ShapeEllipseRibbon => build_ellipse_ribbon(width, height)
    ShapeEllipseRibbon2 => build_ellipse_ribbon2(width, height)
    ShapeLeftRightRibbon => build_left_right_ribbon(width, height)
    ShapeWave => build_wave(width, height)
    ShapeDoubleWave => build_double_wave(width, height)
    ShapeVerticalScroll => build_vertical_scroll(width, height)
    ShapeHorizontalScroll => build_horizontal_scroll(width, height)
    ShapeLine => build_line(width, height)
    ShapeLineInv => build_line_inv(width, height)
    ShapeStraightConnector1 => build_straight_connector1(width, height)
    ShapeBentConnector2 => build_bent_connector2(width, height)
    ShapeBentConnector3 => build_bent_connector3(width, height)
    ShapeBentConnector4 => build_bent_connector4(width, height)
    ShapeBentConnector5 => build_bent_connector5(width, height)
    ShapeCurvedConnector2 => build_curved_connector2(width, height)
    ShapeCurvedConnector3 => build_curved_connector3(width, height)
    ShapeCurvedConnector4 => build_curved_connector4(width, height)
    ShapeCurvedConnector5 => build_curved_connector5(width, height)
    ShapeCornerTabs => build_corner_tabs(width, height)
    ShapeSquareTabs => build_square_tabs(width, height)
    ShapePlaqueTabs => build_plaque_tabs(width, height)
    ShapeNonIsoscelesTrapezoid => build_non_isosceles_trapezoid(width, height)
    ShapeMathNotEqual => build_math_not_equal(width, height)
    ShapeSwooshArrow => build_swoosh_arrow(width, height)
    ShapeLeftCircularArrow => build_left_circular_arrow(width, height)
    ShapeLeftRightCircularArrow =>
      build_left_right_circular_arrow(width, height)
    _ => rectangular_fallback(width, height)
  }
}

///|
/// §20.1.10.56 ST_PresetGeometry — bounding-box fallback for
/// presets whose dedicated path generator has not yet been
/// authored.  Returns the canonical four-corner rectangle so
/// renderers still get a non-empty, bounding-box-correct path
/// (the document round-trips without loss because the spec
/// preset name is preserved on the source `<a:prstGeom>`).
///
/// Consumers that need to know whether the returned geometry
/// is the faithful spec path or the bounding-box fallback can
/// call `supports(shape)` first — `false` means the renderer
/// is using this fallback and the consumer can surface the
/// preset name as `data-ooxml-prst="<name>"` metadata in their
/// own emission layer.
///
/// The fallback is also returned for degenerate inputs
/// (`width` or `height` ≤ 0).
pub fn rectangular_fallback(width : Int, height : Int) -> ShapeGeometry {
  if width <= 0 || height <= 0 {
    return { commands: [], width: 0, height: 0 }
  }
  build_rect(width, height)
}

///|
/// Report whether `build_geometry` has a faithful (non-fallback)
/// geometry generator for the supplied preset. Useful for audit
/// tooling and for renderers that want to know whether the result
/// can be trusted as a pixel-faithful representation of the spec
/// shape image.
pub fn supports(shape : PresetShape) -> Bool {
  match shape {
    ShapeRect
    | ShapeRoundRect
    | ShapePlaque
    | ShapeEllipse
    | ShapeTriangle
    | ShapeRtTriangle
    | ShapeParallelogram
    | ShapeTrapezoid
    | ShapeDiamond
    | ShapePentagon
    | ShapeHexagon
    | ShapeHeptagon
    | ShapeOctagon
    | ShapeDecagon
    | ShapeDodecagon
    | ShapeStar4
    | ShapeStar5
    | ShapeStar6
    | ShapeStar7
    | ShapeStar8
    | ShapeStar10
    | ShapeStar12
    | ShapeStar16
    | ShapeStar24
    | ShapeStar32
    | ShapeRightArrow
    | ShapeLeftArrow
    | ShapeUpArrow
    | ShapeDownArrow
    | ShapeLeftRightArrow
    | ShapeUpDownArrow
    | ShapeNotchedRightArrow
    | ShapeStripedRightArrow
    | ShapeBentArrow
    | ShapeBentUpArrow
    | ShapeUturnArrow
    | ShapeLeftRightUpArrow
    | ShapeLeftUpArrow
    | ShapeQuadArrow
    | ShapeRightArrowCallout
    | ShapeLeftArrowCallout
    | ShapeUpArrowCallout
    | ShapeDownArrowCallout
    | ShapeLeftRightArrowCallout
    | ShapeUpDownArrowCallout
    | ShapeQuadArrowCallout
    | ShapeCallout1
    | ShapeCallout2
    | ShapeCallout3
    | ShapeHeart
    | ShapeCloud
    | ShapeSmileyFace
    | ShapePlus
    | ShapeMathPlus
    | ShapeMathMinus
    | ShapeMathMultiply
    | ShapeMathDivide
    | ShapeMathEqual
    | ShapeFlowChartProcess
    | ShapeFlowChartPredefinedProcess
    | ShapeFlowChartInternalStorage
    | ShapeFlowChartDecision
    | ShapeFlowChartTerminator
    | ShapeFlowChartAlternateProcess
    | ShapeFlowChartConnector
    | ShapeFlowChartInputOutput
    | ShapeHomePlate
    | ShapeChevron
    | ShapeFrame
    | ShapeHalfFrame
    | ShapeCorner
    | ShapeDiagStripe
    | ShapeCube
    | ShapeCan
    | ShapeBevel
    | ShapeFoldedCorner
    | ShapeChartX
    | ShapeChartPlus
    | ShapeChartStar
    | ShapeFlowChartDocument
    | ShapeFlowChartMultidocument
    | ShapeFlowChartPreparation
    | ShapeFlowChartManualInput
    | ShapeFlowChartManualOperation
    | ShapeFlowChartExtract
    | ShapeFlowChartMerge
    | ShapeFlowChartPunchedCard
    | ShapeFlowChartPunchedTape
    | ShapeFlowChartSort
    | ShapeFlowChartCollate
    | ShapeFlowChartOr
    | ShapeFlowChartSummingJunction
    | ShapeFlowChartOfflineStorage
    | ShapeFlowChartOnlineStorage
    | ShapeFlowChartMagneticDisk
    | ShapeFlowChartMagneticDrum
    | ShapeFlowChartMagneticTape
    | ShapeFlowChartDelay
    | ShapeFlowChartDisplay
    | ShapeFlowChartOffpageConnector
    | ShapeRound1Rect
    | ShapeRound2SameRect
    | ShapeRound2DiagRect
    | ShapeSnip1Rect
    | ShapeSnip2SameRect
    | ShapeSnip2DiagRect
    | ShapeSnipRoundRect
    | ShapeWedgeRectCallout
    | ShapeWedgeRoundRectCallout
    | ShapeWedgeEllipseCallout
    | ShapeBracketPair
    | ShapeLeftBracket
    | ShapeRightBracket
    | ShapeBracePair
    | ShapeLeftBrace
    | ShapeRightBrace
    | ShapeBorderCallout1
    | ShapeBorderCallout2
    | ShapeBorderCallout3
    | ShapeAccentCallout1
    | ShapeAccentCallout2
    | ShapeAccentCallout3
    | ShapeAccentBorderCallout1
    | ShapeAccentBorderCallout2
    | ShapeAccentBorderCallout3
    | ShapeCloudCallout
    | ShapeDonut
    | ShapeBlockArc
    | ShapeArc
    | ShapeChord
    | ShapePie
    | ShapePieWedge
    | ShapeNoSmoking
    | ShapeTeardrop
    | ShapeMoon
    | ShapeSun
    | ShapeActionButtonBlank
    | ShapeActionButtonHome
    | ShapeActionButtonHelp
    | ShapeActionButtonInformation
    | ShapeActionButtonForwardNext
    | ShapeActionButtonBackPrevious
    | ShapeActionButtonBeginning
    | ShapeActionButtonEnd
    | ShapeActionButtonReturn
    | ShapeActionButtonDocument
    | ShapeActionButtonSound
    | ShapeActionButtonMovie
    | ShapeGear6
    | ShapeGear9
    | ShapeFunnel
    | ShapeLightningBolt
    | ShapeIrregularSeal1
    | ShapeIrregularSeal2
    | ShapeCurvedRightArrow
    | ShapeCurvedLeftArrow
    | ShapeCurvedUpArrow
    | ShapeCurvedDownArrow
    | ShapeCircularArrow
    | ShapeRibbon
    | ShapeRibbon2
    | ShapeEllipseRibbon
    | ShapeEllipseRibbon2
    | ShapeLeftRightRibbon
    | ShapeWave
    | ShapeDoubleWave
    | ShapeVerticalScroll
    | ShapeHorizontalScroll
    | ShapeLine
    | ShapeLineInv
    | ShapeStraightConnector1
    | ShapeBentConnector2
    | ShapeBentConnector3
    | ShapeBentConnector4
    | ShapeBentConnector5
    | ShapeCurvedConnector2
    | ShapeCurvedConnector3
    | ShapeCurvedConnector4
    | ShapeCurvedConnector5
    | ShapeCornerTabs
    | ShapeSquareTabs
    | ShapePlaqueTabs
    | ShapeNonIsoscelesTrapezoid
    | ShapeMathNotEqual
    | ShapeSwooshArrow
    | ShapeLeftCircularArrow
    | ShapeLeftRightCircularArrow => true
    _ => false
  }
}

///|
/// Compute `(numerator * scalar) / denominator` with integer math
/// while keeping the intermediate product in a 64-bit-safe range
/// (DrawingML's preset coordinate space tops out at 100000 so a
/// `width * 100000` product fits in an Int64). The helper centralises
/// the rounding policy: round half-to-zero.
fn fraction(scalar : Int, numerator : Int, denominator : Int) -> Int {
  if denominator == 0 {
    return 0
  }
  let big = scalar.to_int64() * numerator.to_int64()
  let div = big / denominator.to_int64()
  div.to_int()
}

///|
/// Compute `(scalar * percent) / 100000`. The DrawingML preset
/// adjustment guides express their default values as parts of
/// 100000 (e.g. roundRect's `adj = 16667` ≈ 1/6 of the side length).
fn percent(scalar : Int, parts_per_hundred_thousand : Int) -> Int {
  fraction(scalar, parts_per_hundred_thousand, 100000)
}

///|
/// Integer sine of `degrees` scaled by 10000. Used by the polygon and
/// star constructors to place vertices on a circle without pulling in
/// floating-point math. Values are precomputed for every 1-degree step
/// in the first quadrant and reflected into the remaining three.
fn sin10000(degrees : Int) -> Int {
  let normalized = (degrees % 360 + 360) % 360
  if normalized < 90 {
    sin_table_q1[normalized]
  } else if normalized < 180 {
    sin_table_q1[180 - normalized]
  } else if normalized < 270 {
    -sin_table_q1[normalized - 180]
  } else {
    -sin_table_q1[360 - normalized]
  }
}

///|
/// Integer cosine of `degrees` scaled by 10000, expressed as a
/// sine-with-phase-shift so the table is shared with `sin10000`.
fn cos10000(degrees : Int) -> Int {
  sin10000(degrees + 90)
}

///|
/// First-quadrant sine table, scaled by 10000. Indices 0..90 inclusive
/// give the sine of an integer degree from 0° to 90°. Values are exact
/// to within a unit-in-the-last-place which is more than enough for
/// integer-coordinate preset shape generation.
let sin_table_q1 : Array[Int] = [
  0, 175, 349, 523, 698, 872, 1045, 1219, 1392, 1564, 1736, 1908, 2079, 2250, 2419,
  2588, 2756, 2924, 3090, 3256, 3420, 3584, 3746, 3907, 4067, 4226, 4384, 4540, 4695,
  4848, 5000, 5150, 5299, 5446, 5592, 5736, 5878, 6018, 6157, 6293, 6428, 6561, 6691,
  6820, 6947, 7071, 7193, 7314, 7431, 7547, 7660, 7771, 7880, 7986, 8090, 8192, 8290,
  8387, 8480, 8572, 8660, 8746, 8829, 8910, 8988, 9063, 9135, 9205, 9272, 9336, 9397,
  9455, 9511, 9563, 9613, 9659, 9703, 9744, 9781, 9816, 9848, 9877, 9903, 9925, 9945,
  9962, 9976, 9986, 9994, 9998, 10000,
]
