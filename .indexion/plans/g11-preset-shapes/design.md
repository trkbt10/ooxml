# G11 — Design

New package: `src/ecma376/drawing_ml/preset_geometry/`.

## File layout

```
preset_geometry/
  moon.pkg                     -- depends on @xml, @opc_errors
  types.mbt                    -- PresetShape (187 variants),
                                  PresetShapeFamily, Adjustment,
                                  PathCommand, ShapeGeometry,
                                  PresetGeometry struct + section_name
  decode.mbt                   -- decode_preset_geometry,
                                  decode_adjustment, attr helpers,
                                  unsigned-int parser
  geometry.mbt                 -- build_geometry dispatcher +
                                  rectangular_fallback + supports()
  shapes_rect.mbt              -- rect, roundRect, ellipse, triangle,
                                  rtTriangle, parallelogram, trapezoid,
                                  diamond, pentagon, hexagon, heptagon,
                                  octagon, decagon, dodecagon, plaque,
                                  heart, cloud, smileyFace, plus,
                                  math* (plus/minus/multiply/divide/
                                  equal/notEqual)
  shapes_arrows.mbt            -- rightArrow, leftArrow, upArrow,
                                  downArrow, leftRightArrow,
                                  upDownArrow
  shapes_callouts.mbt          -- callout1, callout2, callout3
  shapes_stars.mbt             -- star4..star32 (8 sizes) +
                                  shared n_pointed_star helper
  shapes_flowchart.mbt         -- flowChartProcess, flowChartDecision,
                                  flowChartTerminator,
                                  flowChartConnector,
                                  flowChartInputOutput
  geometry_wbtest.mbt          -- decoder, family, build_geometry per
                                  family, fallback, section_name
```

## Type sketch

```
pub(all) enum PresetShape {
  ShapeLine
  ShapeLineInv
  ShapeTriangle
  ShapeRtTriangle
  ShapeRect
  ShapeDiamond
  ShapeParallelogram
  ShapeTrapezoid
  ShapeNonIsoscelesTrapezoid
  ShapePentagon
  ShapeHexagon
  ShapeHeptagon
  ShapeOctagon
  ShapeDecagon
  ShapeDodecagon
  ShapeStar4
  ShapeStar5
  ShapeStar6
  ShapeStar7
  ShapeStar8
  ShapeStar10
  ShapeStar12
  ShapeStar16
  ShapeStar24
  ShapeStar32
  ShapeRoundRect
  ShapeRound1Rect
  ShapeRound2SameRect
  ShapeRound2DiagRect
  ShapeSnipRoundRect
  ShapeSnip1Rect
  ShapeSnip2SameRect
  ShapeSnip2DiagRect
  ShapePlaque
  ShapeEllipse
  ShapeTeardrop
  ShapeHomePlate
  ShapeChevron
  ShapePieWedge
  ShapePie
  ShapeBlockArc
  ShapeDonut
  ShapeNoSmoking
  ShapeRightArrow
  ShapeLeftArrow
  ShapeUpArrow
  ShapeDownArrow
  ShapeStripedRightArrow
  ShapeNotchedRightArrow
  ShapeBentUpArrow
  ShapeLeftRightArrow
  ShapeUpDownArrow
  ShapeLeftUpArrow
  ShapeLeftRightUpArrow
  ShapeQuadArrow
  ShapeLeftArrowCallout
  ShapeRightArrowCallout
  ShapeUpArrowCallout
  ShapeDownArrowCallout
  ShapeLeftRightArrowCallout
  ShapeUpDownArrowCallout
  ShapeQuadArrowCallout
  ShapeBentArrow
  ShapeUturnArrow
  ShapeCircularArrow
  ShapeLeftCircularArrow
  ShapeLeftRightCircularArrow
  ShapeCurvedRightArrow
  ShapeCurvedLeftArrow
  ShapeCurvedUpArrow
  ShapeCurvedDownArrow
  ShapeSwooshArrow
  ShapeCube
  ShapeCan
  ShapeLightningBolt
  ShapeHeart
  ShapeSun
  ShapeMoon
  ShapeSmileyFace
  ShapeIrregularSeal1
  ShapeIrregularSeal2
  ShapeFoldedCorner
  ShapeBevel
  ShapeFrame
  ShapeHalfFrame
  ShapeCorner
  ShapeDiagStripe
  ShapeChord
  ShapeArc
  ShapeLeftBracket
  ShapeRightBracket
  ShapeLeftBrace
  ShapeRightBrace
  ShapeBracketPair
  ShapeBracePair
  ShapeStraightConnector1
  ShapeBentConnector2
  ShapeBentConnector3
  ShapeBentConnector4
  ShapeBentConnector5
  ShapeCurvedConnector2
  ShapeCurvedConnector3
  ShapeCurvedConnector4
  ShapeCurvedConnector5
  ShapeCallout1
  ShapeCallout2
  ShapeCallout3
  ShapeAccentCallout1
  ShapeAccentCallout2
  ShapeAccentCallout3
  ShapeBorderCallout1
  ShapeBorderCallout2
  ShapeBorderCallout3
  ShapeAccentBorderCallout1
  ShapeAccentBorderCallout2
  ShapeAccentBorderCallout3
  ShapeWedgeRectCallout
  ShapeWedgeRoundRectCallout
  ShapeWedgeEllipseCallout
  ShapeCloudCallout
  ShapeCloud
  ShapeRibbon
  ShapeRibbon2
  ShapeEllipseRibbon
  ShapeEllipseRibbon2
  ShapeLeftRightRibbon
  ShapeVerticalScroll
  ShapeHorizontalScroll
  ShapeWave
  ShapeDoubleWave
  ShapePlus
  ShapeFlowChartProcess
  ShapeFlowChartDecision
  ShapeFlowChartInputOutput
  ShapeFlowChartPredefinedProcess
  ShapeFlowChartInternalStorage
  ShapeFlowChartDocument
  ShapeFlowChartMultidocument
  ShapeFlowChartTerminator
  ShapeFlowChartPreparation
  ShapeFlowChartManualInput
  ShapeFlowChartManualOperation
  ShapeFlowChartConnector
  ShapeFlowChartPunchedCard
  ShapeFlowChartPunchedTape
  ShapeFlowChartSummingJunction
  ShapeFlowChartOr
  ShapeFlowChartCollate
  ShapeFlowChartSort
  ShapeFlowChartExtract
  ShapeFlowChartMerge
  ShapeFlowChartOfflineStorage
  ShapeFlowChartOnlineStorage
  ShapeFlowChartMagneticTape
  ShapeFlowChartMagneticDisk
  ShapeFlowChartMagneticDrum
  ShapeFlowChartDisplay
  ShapeFlowChartDelay
  ShapeFlowChartAlternateProcess
  ShapeFlowChartOffpageConnector
  ShapeActionButtonBlank
  ShapeActionButtonHome
  ShapeActionButtonHelp
  ShapeActionButtonInformation
  ShapeActionButtonForwardNext
  ShapeActionButtonBackPrevious
  ShapeActionButtonEnd
  ShapeActionButtonBeginning
  ShapeActionButtonReturn
  ShapeActionButtonDocument
  ShapeActionButtonSound
  ShapeActionButtonMovie
  ShapeGear6
  ShapeGear9
  ShapeFunnel
  ShapeMathPlus
  ShapeMathMinus
  ShapeMathMultiply
  ShapeMathDivide
  ShapeMathEqual
  ShapeMathNotEqual
  ShapeCornerTabs
  ShapeSquareTabs
  ShapePlaqueTabs
  ShapeChartX
  ShapeChartStar
  ShapeChartPlus
} derive(Eq, Debug)

pub(all) enum PresetShapeFamily {
  FamilyRectangular
  FamilyArrow
  FamilyCallout
  FamilyStar
  FamilyFlowChart
  FamilyActionButton
  FamilyConnector
  FamilyBracket
  FamilyMath
  FamilyBanner
  FamilyMisc
} derive(Eq, Debug)

pub(all) enum PathCommand {
  MoveTo(Int, Int)
  LineTo(Int, Int)
  QuadTo(Int, Int, Int, Int)
  CurveTo(Int, Int, Int, Int, Int, Int)
  ArcTo(Int, Int, Int, Bool, Bool, Int, Int)
  ClosePath
} derive(Eq, Debug)

pub(all) struct ShapeGeometry {
  commands : Array[PathCommand]
  width : Int
  height : Int
} derive(Eq, Debug)

pub(all) struct Adjustment {
  name : String
  raw_formula : String
  value : Int?
} derive(Eq, Debug)

pub(all) struct PresetGeometry {
  shape : PresetShape
  adjustments : Array[Adjustment]
} derive(Eq, Debug)
```

## Dispatch algorithm

```
fn build_geometry(shape, width, height):
  match shape {
    ShapeRect | ShapePlaque => build_rect(width, height)
    ShapeRoundRect          => build_round_rect(width, height)
    ShapeEllipse | ShapeFlowChartConnector => build_ellipse(width, height)
    ShapeTriangle           => build_triangle(width, height)
    ShapeRtTriangle         => build_right_triangle(width, height)
    ShapeParallelogram | ShapeFlowChartInputOutput => build_parallelogram(...)
    ShapeTrapezoid          => build_trapezoid(...)
    ShapeDiamond | ShapeFlowChartDecision => build_diamond(...)
    ShapePentagon           => build_polygon(5, ...)
    ShapeHexagon            => build_polygon(6, ...)
    ShapeHeptagon           => build_polygon(7, ...)
    ShapeOctagon            => build_polygon(8, ...)
    ShapeDecagon            => build_polygon(10, ...)
    ShapeDodecagon          => build_polygon(12, ...)
    ShapeStar4              => build_star(4, ...)
    ... etc star N ...
    ShapeRightArrow         => build_right_arrow(...)
    ShapeLeftArrow          => build_left_arrow(...)
    ShapeUpArrow            => build_up_arrow(...)
    ShapeDownArrow          => build_down_arrow(...)
    ShapeLeftRightArrow     => build_left_right_arrow(...)
    ShapeUpDownArrow        => build_up_down_arrow(...)
    ShapeCallout1           => build_callout1(...)
    ShapeCallout2           => build_callout2(...)
    ShapeCallout3           => build_callout3(...)
    ShapeHeart              => build_heart(...)
    ShapeCloud              => build_cloud(...)
    ShapeSmileyFace         => build_smiley_face(...)
    ShapePlus | ShapeMathPlus => build_plus(...)
    ShapeMathMinus          => build_minus(...)
    ShapeMathMultiply       => build_multiply(...)
    ShapeMathDivide         => build_divide(...)
    ShapeMathEqual          => build_equal(...)
    ShapeFlowChartProcess   => build_rect(...)
    ShapeFlowChartTerminator => build_round_rect(...)
    _ => rectangular_fallback(width, height)
  }
```

## Coordinate system

DrawingML's preset coordinate system is `(0,0)` top-left to `(w,h)`
bottom-right with EMUs. Our `build_geometry` works in the supplied
`width`/`height` integer space — the caller normalises afterwards.
For pure geometric ratios we use integer math: `(width * n) / d` to
preserve precision.

## SHALLOW resolution

- `types.mbt` — `PresetShape::from_attr` is the 187-arm decoder; >800
  lines but mostly short cases. `family(self)` adds the 187-arm
  classifier. Both well exceed the 4-line SHALLOW threshold.
- `decode.mbt` — `decode_preset_geometry`, `decode_adjustment`,
  `parse_val_formula` are non-trivial.
- `geometry.mbt` — `build_geometry` dispatcher, `rectangular_fallback`,
  `supports`.
- Each `shapes_*.mbt` file holds the per-shape geometry constructors,
  each with non-trivial coordinate math and `Array::push` sequences.

## Test plan

- decode_preset_geometry: `<prstGeom prst="rect"/>` yields
  `ShapeRect` + empty adjustments.
- decode_preset_geometry with avLst: a `gd name="adj1" fmla="val
  25000"/>` is decoded into `Adjustment { value : Some(25000) }`.
- decoder rejects missing `@prst` (SchemaViolation).
- decoder rejects unknown `@prst`.
- `PresetShape::from_attr` round-trips ≥10 random values from each
  family.
- `build_geometry(ShapeRect, 100, 50)` returns 4 LineTo/MoveTo +
  ClosePath, ending at `ClosePath`.
- `build_geometry(ShapeEllipse, 200, 100)` returns an ArcTo sequence
  closing back to the start point.
- `build_geometry(ShapeTriangle, 100, 100)` returns 3 line edges +
  close.
- `build_geometry(ShapeRightArrow, 200, 100)` returns 7 vertices + a
  close (shaft + head).
- `build_geometry(ShapeStar5, 100, 100)` returns 10 vertices (5
  outer + 5 inner) + close.
- `build_geometry(ShapeCallout1, 200, 200)` returns the rounded-rect
  body plus the leader line.
- `build_geometry(ShapeFlowChartProcess, 100, 50)` returns a
  rectangle.
- `build_geometry(ShapeFunnel, 100, 100)` returns the rectangular
  fallback (4 vertices + ClosePath).
- `preset_geometry_part1_20_1_10_56_section_name()` returns the
  canonical citation.

## Cross-package contracts

- The package only consumes `@xml.Element` and only raises
  `@opc_errors.SchemaViolation`.
- The package does NOT touch the existing `@drawing_ml`
  `CT_PresetGeometry2D` element wrapper — the new decoder is an
  enrichment layer that operates on the raw element so other
  packages can keep using the wrapper as-is.
