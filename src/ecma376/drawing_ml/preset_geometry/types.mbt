///|
/// Part 1 §20.1.10.56 ST_ShapeType — the closed enumeration of preset
/// shape lexical forms allowed on the `prstGeom/@prst` attribute. The
/// XSD restricts an `xsd:token` to the 187 values reproduced here in
/// the same lexical order as the canonical schema (Annex A.4.1 lines
/// 1712..1898). Each variant carries the spec section that the renderer
/// can cite when raising compatibility warnings.
pub(all) enum PresetShape {
  /// §20.1.10.56 line — straight line connector.
  ShapeLine
  /// §20.1.10.56 lineInv — inverted line.
  ShapeLineInv
  /// §20.1.10.56 triangle — isoceles triangle.
  ShapeTriangle
  /// §20.1.10.56 rtTriangle — right triangle.
  ShapeRtTriangle
  /// §20.1.10.56 rect — rectangle.
  ShapeRect
  /// §20.1.10.56 diamond — diamond / rhombus.
  ShapeDiamond
  /// §20.1.10.56 parallelogram — slanted rectangle.
  ShapeParallelogram
  /// §20.1.10.56 trapezoid — isoceles trapezoid.
  ShapeTrapezoid
  /// §20.1.10.56 nonIsoscelesTrapezoid — non-isoceles trapezoid.
  ShapeNonIsoscelesTrapezoid
  /// §20.1.10.56 pentagon — regular pentagon.
  ShapePentagon
  /// §20.1.10.56 hexagon — regular hexagon.
  ShapeHexagon
  /// §20.1.10.56 heptagon — regular heptagon.
  ShapeHeptagon
  /// §20.1.10.56 octagon — regular octagon.
  ShapeOctagon
  /// §20.1.10.56 decagon — regular decagon.
  ShapeDecagon
  /// §20.1.10.56 dodecagon — regular dodecagon.
  ShapeDodecagon
  /// §20.1.10.56 star4 — 4-pointed star.
  ShapeStar4
  /// §20.1.10.56 star5 — 5-pointed star.
  ShapeStar5
  /// §20.1.10.56 star6 — 6-pointed star.
  ShapeStar6
  /// §20.1.10.56 star7 — 7-pointed star.
  ShapeStar7
  /// §20.1.10.56 star8 — 8-pointed star.
  ShapeStar8
  /// §20.1.10.56 star10 — 10-pointed star.
  ShapeStar10
  /// §20.1.10.56 star12 — 12-pointed star.
  ShapeStar12
  /// §20.1.10.56 star16 — 16-pointed star.
  ShapeStar16
  /// §20.1.10.56 star24 — 24-pointed star.
  ShapeStar24
  /// §20.1.10.56 star32 — 32-pointed star.
  ShapeStar32
  /// §20.1.10.56 roundRect — rectangle with all four corners rounded.
  ShapeRoundRect
  /// §20.1.10.56 round1Rect — rectangle with one rounded corner.
  ShapeRound1Rect
  /// §20.1.10.56 round2SameRect — two same-side rounded corners.
  ShapeRound2SameRect
  /// §20.1.10.56 round2DiagRect — two diagonal rounded corners.
  ShapeRound2DiagRect
  /// §20.1.10.56 snipRoundRect — one snipped, three rounded corners.
  ShapeSnipRoundRect
  /// §20.1.10.56 snip1Rect — one snipped corner.
  ShapeSnip1Rect
  /// §20.1.10.56 snip2SameRect — two same-side snipped corners.
  ShapeSnip2SameRect
  /// §20.1.10.56 snip2DiagRect — two diagonal snipped corners.
  ShapeSnip2DiagRect
  /// §20.1.10.56 plaque — plaque (inverse rounded corners).
  ShapePlaque
  /// §20.1.10.56 ellipse — ellipse / circle.
  ShapeEllipse
  /// §20.1.10.56 teardrop — teardrop.
  ShapeTeardrop
  /// §20.1.10.56 homePlate — home-plate pentagon.
  ShapeHomePlate
  /// §20.1.10.56 chevron — chevron arrow head.
  ShapeChevron
  /// §20.1.10.56 pieWedge — pie wedge.
  ShapePieWedge
  /// §20.1.10.56 pie — pie slice.
  ShapePie
  /// §20.1.10.56 blockArc — block-arc.
  ShapeBlockArc
  /// §20.1.10.56 donut — donut / ring.
  ShapeDonut
  /// §20.1.10.56 noSmoking — no-smoking symbol.
  ShapeNoSmoking
  /// §20.1.10.56 rightArrow — right block arrow.
  ShapeRightArrow
  /// §20.1.10.56 leftArrow — left block arrow.
  ShapeLeftArrow
  /// §20.1.10.56 upArrow — up block arrow.
  ShapeUpArrow
  /// §20.1.10.56 downArrow — down block arrow.
  ShapeDownArrow
  /// §20.1.10.56 stripedRightArrow — striped right arrow.
  ShapeStripedRightArrow
  /// §20.1.10.56 notchedRightArrow — notched right arrow.
  ShapeNotchedRightArrow
  /// §20.1.10.56 bentUpArrow — bent up arrow.
  ShapeBentUpArrow
  /// §20.1.10.56 leftRightArrow — left-right block arrow.
  ShapeLeftRightArrow
  /// §20.1.10.56 upDownArrow — up-down block arrow.
  ShapeUpDownArrow
  /// §20.1.10.56 leftUpArrow — left-up block arrow.
  ShapeLeftUpArrow
  /// §20.1.10.56 leftRightUpArrow — left-right-up block arrow.
  ShapeLeftRightUpArrow
  /// §20.1.10.56 quadArrow — quad block arrow.
  ShapeQuadArrow
  /// §20.1.10.56 leftArrowCallout — left arrow callout.
  ShapeLeftArrowCallout
  /// §20.1.10.56 rightArrowCallout — right arrow callout.
  ShapeRightArrowCallout
  /// §20.1.10.56 upArrowCallout — up arrow callout.
  ShapeUpArrowCallout
  /// §20.1.10.56 downArrowCallout — down arrow callout.
  ShapeDownArrowCallout
  /// §20.1.10.56 leftRightArrowCallout — left-right arrow callout.
  ShapeLeftRightArrowCallout
  /// §20.1.10.56 upDownArrowCallout — up-down arrow callout.
  ShapeUpDownArrowCallout
  /// §20.1.10.56 quadArrowCallout — quad arrow callout.
  ShapeQuadArrowCallout
  /// §20.1.10.56 bentArrow — bent arrow.
  ShapeBentArrow
  /// §20.1.10.56 uturnArrow — U-turn arrow.
  ShapeUturnArrow
  /// §20.1.10.56 circularArrow — circular arrow.
  ShapeCircularArrow
  /// §20.1.10.56 leftCircularArrow — left circular arrow.
  ShapeLeftCircularArrow
  /// §20.1.10.56 leftRightCircularArrow — left-right circular arrow.
  ShapeLeftRightCircularArrow
  /// §20.1.10.56 curvedRightArrow — curved right arrow.
  ShapeCurvedRightArrow
  /// §20.1.10.56 curvedLeftArrow — curved left arrow.
  ShapeCurvedLeftArrow
  /// §20.1.10.56 curvedUpArrow — curved up arrow.
  ShapeCurvedUpArrow
  /// §20.1.10.56 curvedDownArrow — curved down arrow.
  ShapeCurvedDownArrow
  /// §20.1.10.56 swooshArrow — swoosh arrow.
  ShapeSwooshArrow
  /// §20.1.10.56 cube — cube (isometric).
  ShapeCube
  /// §20.1.10.56 can — can / cylinder.
  ShapeCan
  /// §20.1.10.56 lightningBolt — lightning bolt.
  ShapeLightningBolt
  /// §20.1.10.56 heart — heart.
  ShapeHeart
  /// §20.1.10.56 sun — sun.
  ShapeSun
  /// §20.1.10.56 moon — moon.
  ShapeMoon
  /// §20.1.10.56 smileyFace — smiley face.
  ShapeSmileyFace
  /// §20.1.10.56 irregularSeal1 — irregular seal 1.
  ShapeIrregularSeal1
  /// §20.1.10.56 irregularSeal2 — irregular seal 2.
  ShapeIrregularSeal2
  /// §20.1.10.56 foldedCorner — folded corner.
  ShapeFoldedCorner
  /// §20.1.10.56 bevel — bevel frame.
  ShapeBevel
  /// §20.1.10.56 frame — picture frame.
  ShapeFrame
  /// §20.1.10.56 halfFrame — half picture frame.
  ShapeHalfFrame
  /// §20.1.10.56 corner — corner.
  ShapeCorner
  /// §20.1.10.56 diagStripe — diagonal stripe.
  ShapeDiagStripe
  /// §20.1.10.56 chord — chord.
  ShapeChord
  /// §20.1.10.56 arc — arc.
  ShapeArc
  /// §20.1.10.56 leftBracket — left bracket.
  ShapeLeftBracket
  /// §20.1.10.56 rightBracket — right bracket.
  ShapeRightBracket
  /// §20.1.10.56 leftBrace — left brace.
  ShapeLeftBrace
  /// §20.1.10.56 rightBrace — right brace.
  ShapeRightBrace
  /// §20.1.10.56 bracketPair — bracket pair.
  ShapeBracketPair
  /// §20.1.10.56 bracePair — brace pair.
  ShapeBracePair
  /// §20.1.10.56 straightConnector1 — straight connector.
  ShapeStraightConnector1
  /// §20.1.10.56 bentConnector2 — bent connector with two segments.
  ShapeBentConnector2
  /// §20.1.10.56 bentConnector3 — bent connector with three segments.
  ShapeBentConnector3
  /// §20.1.10.56 bentConnector4 — bent connector with four segments.
  ShapeBentConnector4
  /// §20.1.10.56 bentConnector5 — bent connector with five segments.
  ShapeBentConnector5
  /// §20.1.10.56 curvedConnector2 — curved connector with two segments.
  ShapeCurvedConnector2
  /// §20.1.10.56 curvedConnector3 — curved connector with three segments.
  ShapeCurvedConnector3
  /// §20.1.10.56 curvedConnector4 — curved connector with four segments.
  ShapeCurvedConnector4
  /// §20.1.10.56 curvedConnector5 — curved connector with five segments.
  ShapeCurvedConnector5
  /// §20.1.10.56 callout1 — callout 1.
  ShapeCallout1
  /// §20.1.10.56 callout2 — callout 2.
  ShapeCallout2
  /// §20.1.10.56 callout3 — callout 3.
  ShapeCallout3
  /// §20.1.10.56 accentCallout1 — accent callout 1.
  ShapeAccentCallout1
  /// §20.1.10.56 accentCallout2 — accent callout 2.
  ShapeAccentCallout2
  /// §20.1.10.56 accentCallout3 — accent callout 3.
  ShapeAccentCallout3
  /// §20.1.10.56 borderCallout1 — border callout 1.
  ShapeBorderCallout1
  /// §20.1.10.56 borderCallout2 — border callout 2.
  ShapeBorderCallout2
  /// §20.1.10.56 borderCallout3 — border callout 3.
  ShapeBorderCallout3
  /// §20.1.10.56 accentBorderCallout1 — accent border callout 1.
  ShapeAccentBorderCallout1
  /// §20.1.10.56 accentBorderCallout2 — accent border callout 2.
  ShapeAccentBorderCallout2
  /// §20.1.10.56 accentBorderCallout3 — accent border callout 3.
  ShapeAccentBorderCallout3
  /// §20.1.10.56 wedgeRectCallout — wedge rectangular callout.
  ShapeWedgeRectCallout
  /// §20.1.10.56 wedgeRoundRectCallout — wedge round-rect callout.
  ShapeWedgeRoundRectCallout
  /// §20.1.10.56 wedgeEllipseCallout — wedge elliptical callout.
  ShapeWedgeEllipseCallout
  /// §20.1.10.56 cloudCallout — cloud callout.
  ShapeCloudCallout
  /// §20.1.10.56 cloud — cloud.
  ShapeCloud
  /// §20.1.10.56 ribbon — ribbon.
  ShapeRibbon
  /// §20.1.10.56 ribbon2 — ribbon 2.
  ShapeRibbon2
  /// §20.1.10.56 ellipseRibbon — elliptic ribbon.
  ShapeEllipseRibbon
  /// §20.1.10.56 ellipseRibbon2 — elliptic ribbon 2.
  ShapeEllipseRibbon2
  /// §20.1.10.56 leftRightRibbon — left-right ribbon.
  ShapeLeftRightRibbon
  /// §20.1.10.56 verticalScroll — vertical scroll.
  ShapeVerticalScroll
  /// §20.1.10.56 horizontalScroll — horizontal scroll.
  ShapeHorizontalScroll
  /// §20.1.10.56 wave — wave.
  ShapeWave
  /// §20.1.10.56 doubleWave — double wave.
  ShapeDoubleWave
  /// §20.1.10.56 plus — plus sign.
  ShapePlus
  /// §20.1.10.56 flowChartProcess — flow chart process.
  ShapeFlowChartProcess
  /// §20.1.10.56 flowChartDecision — flow chart decision.
  ShapeFlowChartDecision
  /// §20.1.10.56 flowChartInputOutput — flow chart input/output.
  ShapeFlowChartInputOutput
  /// §20.1.10.56 flowChartPredefinedProcess — flow chart predefined process.
  ShapeFlowChartPredefinedProcess
  /// §20.1.10.56 flowChartInternalStorage — flow chart internal storage.
  ShapeFlowChartInternalStorage
  /// §20.1.10.56 flowChartDocument — flow chart document.
  ShapeFlowChartDocument
  /// §20.1.10.56 flowChartMultidocument — flow chart multidocument.
  ShapeFlowChartMultidocument
  /// §20.1.10.56 flowChartTerminator — flow chart terminator.
  ShapeFlowChartTerminator
  /// §20.1.10.56 flowChartPreparation — flow chart preparation.
  ShapeFlowChartPreparation
  /// §20.1.10.56 flowChartManualInput — flow chart manual input.
  ShapeFlowChartManualInput
  /// §20.1.10.56 flowChartManualOperation — flow chart manual operation.
  ShapeFlowChartManualOperation
  /// §20.1.10.56 flowChartConnector — flow chart connector.
  ShapeFlowChartConnector
  /// §20.1.10.56 flowChartPunchedCard — flow chart punched card.
  ShapeFlowChartPunchedCard
  /// §20.1.10.56 flowChartPunchedTape — flow chart punched tape.
  ShapeFlowChartPunchedTape
  /// §20.1.10.56 flowChartSummingJunction — flow chart summing junction.
  ShapeFlowChartSummingJunction
  /// §20.1.10.56 flowChartOr — flow chart OR.
  ShapeFlowChartOr
  /// §20.1.10.56 flowChartCollate — flow chart collate.
  ShapeFlowChartCollate
  /// §20.1.10.56 flowChartSort — flow chart sort.
  ShapeFlowChartSort
  /// §20.1.10.56 flowChartExtract — flow chart extract.
  ShapeFlowChartExtract
  /// §20.1.10.56 flowChartMerge — flow chart merge.
  ShapeFlowChartMerge
  /// §20.1.10.56 flowChartOfflineStorage — flow chart offline storage.
  ShapeFlowChartOfflineStorage
  /// §20.1.10.56 flowChartOnlineStorage — flow chart online storage.
  ShapeFlowChartOnlineStorage
  /// §20.1.10.56 flowChartMagneticTape — flow chart magnetic tape.
  ShapeFlowChartMagneticTape
  /// §20.1.10.56 flowChartMagneticDisk — flow chart magnetic disk.
  ShapeFlowChartMagneticDisk
  /// §20.1.10.56 flowChartMagneticDrum — flow chart magnetic drum.
  ShapeFlowChartMagneticDrum
  /// §20.1.10.56 flowChartDisplay — flow chart display.
  ShapeFlowChartDisplay
  /// §20.1.10.56 flowChartDelay — flow chart delay.
  ShapeFlowChartDelay
  /// §20.1.10.56 flowChartAlternateProcess — flow chart alternate process.
  ShapeFlowChartAlternateProcess
  /// §20.1.10.56 flowChartOffpageConnector — flow chart offpage connector.
  ShapeFlowChartOffpageConnector
  /// §20.1.10.56 actionButtonBlank — action button (blank).
  ShapeActionButtonBlank
  /// §20.1.10.56 actionButtonHome — action button (home).
  ShapeActionButtonHome
  /// §20.1.10.56 actionButtonHelp — action button (help).
  ShapeActionButtonHelp
  /// §20.1.10.56 actionButtonInformation — action button (information).
  ShapeActionButtonInformation
  /// §20.1.10.56 actionButtonForwardNext — action button (forward / next).
  ShapeActionButtonForwardNext
  /// §20.1.10.56 actionButtonBackPrevious — action button (back / previous).
  ShapeActionButtonBackPrevious
  /// §20.1.10.56 actionButtonEnd — action button (end).
  ShapeActionButtonEnd
  /// §20.1.10.56 actionButtonBeginning — action button (beginning).
  ShapeActionButtonBeginning
  /// §20.1.10.56 actionButtonReturn — action button (return).
  ShapeActionButtonReturn
  /// §20.1.10.56 actionButtonDocument — action button (document).
  ShapeActionButtonDocument
  /// §20.1.10.56 actionButtonSound — action button (sound).
  ShapeActionButtonSound
  /// §20.1.10.56 actionButtonMovie — action button (movie).
  ShapeActionButtonMovie
  /// §20.1.10.56 gear6 — gear with six teeth.
  ShapeGear6
  /// §20.1.10.56 gear9 — gear with nine teeth.
  ShapeGear9
  /// §20.1.10.56 funnel — funnel.
  ShapeFunnel
  /// §20.1.10.56 mathPlus — mathematical plus sign.
  ShapeMathPlus
  /// §20.1.10.56 mathMinus — mathematical minus sign.
  ShapeMathMinus
  /// §20.1.10.56 mathMultiply — mathematical multiply sign.
  ShapeMathMultiply
  /// §20.1.10.56 mathDivide — mathematical divide sign.
  ShapeMathDivide
  /// §20.1.10.56 mathEqual — mathematical equal sign.
  ShapeMathEqual
  /// §20.1.10.56 mathNotEqual — mathematical not-equal sign.
  ShapeMathNotEqual
  /// §20.1.10.56 cornerTabs — corner tabs.
  ShapeCornerTabs
  /// §20.1.10.56 squareTabs — square tabs.
  ShapeSquareTabs
  /// §20.1.10.56 plaqueTabs — plaque tabs.
  ShapePlaqueTabs
  /// §20.1.10.56 chartX — chart X.
  ShapeChartX
  /// §20.1.10.56 chartStar — chart star.
  ShapeChartStar
  /// §20.1.10.56 chartPlus — chart plus.
  ShapeChartPlus
} derive(Eq, Debug)

///|
/// Part 1 §20.1.10.56 — decode a `prstGeom/@prst` lexical value into
/// the typed `PresetShape`. The match table mirrors Annex A.4.1 lines
/// 1712..1898 verbatim so the implementation stays bit-for-bit aligned
/// with the XSD restriction. Unknown lexical forms raise
/// `SchemaViolation` so callers see exactly which token tripped the
/// decoder.
pub fn PresetShape::from_attr(
  value : String,
) -> PresetShape raise @opc_errors.SchemaViolation {
  match value {
    "line" => ShapeLine
    "lineInv" => ShapeLineInv
    "triangle" => ShapeTriangle
    "rtTriangle" => ShapeRtTriangle
    "rect" => ShapeRect
    "diamond" => ShapeDiamond
    "parallelogram" => ShapeParallelogram
    "trapezoid" => ShapeTrapezoid
    "nonIsoscelesTrapezoid" => ShapeNonIsoscelesTrapezoid
    "pentagon" => ShapePentagon
    "hexagon" => ShapeHexagon
    "heptagon" => ShapeHeptagon
    "octagon" => ShapeOctagon
    "decagon" => ShapeDecagon
    "dodecagon" => ShapeDodecagon
    "star4" => ShapeStar4
    "star5" => ShapeStar5
    "star6" => ShapeStar6
    "star7" => ShapeStar7
    "star8" => ShapeStar8
    "star10" => ShapeStar10
    "star12" => ShapeStar12
    "star16" => ShapeStar16
    "star24" => ShapeStar24
    "star32" => ShapeStar32
    "roundRect" => ShapeRoundRect
    "round1Rect" => ShapeRound1Rect
    "round2SameRect" => ShapeRound2SameRect
    "round2DiagRect" => ShapeRound2DiagRect
    "snipRoundRect" => ShapeSnipRoundRect
    "snip1Rect" => ShapeSnip1Rect
    "snip2SameRect" => ShapeSnip2SameRect
    "snip2DiagRect" => ShapeSnip2DiagRect
    "plaque" => ShapePlaque
    "ellipse" => ShapeEllipse
    "teardrop" => ShapeTeardrop
    "homePlate" => ShapeHomePlate
    "chevron" => ShapeChevron
    "pieWedge" => ShapePieWedge
    "pie" => ShapePie
    "blockArc" => ShapeBlockArc
    "donut" => ShapeDonut
    "noSmoking" => ShapeNoSmoking
    "rightArrow" => ShapeRightArrow
    "leftArrow" => ShapeLeftArrow
    "upArrow" => ShapeUpArrow
    "downArrow" => ShapeDownArrow
    "stripedRightArrow" => ShapeStripedRightArrow
    "notchedRightArrow" => ShapeNotchedRightArrow
    "bentUpArrow" => ShapeBentUpArrow
    "leftRightArrow" => ShapeLeftRightArrow
    "upDownArrow" => ShapeUpDownArrow
    "leftUpArrow" => ShapeLeftUpArrow
    "leftRightUpArrow" => ShapeLeftRightUpArrow
    "quadArrow" => ShapeQuadArrow
    "leftArrowCallout" => ShapeLeftArrowCallout
    "rightArrowCallout" => ShapeRightArrowCallout
    "upArrowCallout" => ShapeUpArrowCallout
    "downArrowCallout" => ShapeDownArrowCallout
    "leftRightArrowCallout" => ShapeLeftRightArrowCallout
    "upDownArrowCallout" => ShapeUpDownArrowCallout
    "quadArrowCallout" => ShapeQuadArrowCallout
    "bentArrow" => ShapeBentArrow
    "uturnArrow" => ShapeUturnArrow
    "circularArrow" => ShapeCircularArrow
    "leftCircularArrow" => ShapeLeftCircularArrow
    "leftRightCircularArrow" => ShapeLeftRightCircularArrow
    "curvedRightArrow" => ShapeCurvedRightArrow
    "curvedLeftArrow" => ShapeCurvedLeftArrow
    "curvedUpArrow" => ShapeCurvedUpArrow
    "curvedDownArrow" => ShapeCurvedDownArrow
    "swooshArrow" => ShapeSwooshArrow
    "cube" => ShapeCube
    "can" => ShapeCan
    "lightningBolt" => ShapeLightningBolt
    "heart" => ShapeHeart
    "sun" => ShapeSun
    "moon" => ShapeMoon
    "smileyFace" => ShapeSmileyFace
    "irregularSeal1" => ShapeIrregularSeal1
    "irregularSeal2" => ShapeIrregularSeal2
    "foldedCorner" => ShapeFoldedCorner
    "bevel" => ShapeBevel
    "frame" => ShapeFrame
    "halfFrame" => ShapeHalfFrame
    "corner" => ShapeCorner
    "diagStripe" => ShapeDiagStripe
    "chord" => ShapeChord
    "arc" => ShapeArc
    "leftBracket" => ShapeLeftBracket
    "rightBracket" => ShapeRightBracket
    "leftBrace" => ShapeLeftBrace
    "rightBrace" => ShapeRightBrace
    "bracketPair" => ShapeBracketPair
    "bracePair" => ShapeBracePair
    "straightConnector1" => ShapeStraightConnector1
    "bentConnector2" => ShapeBentConnector2
    "bentConnector3" => ShapeBentConnector3
    "bentConnector4" => ShapeBentConnector4
    "bentConnector5" => ShapeBentConnector5
    "curvedConnector2" => ShapeCurvedConnector2
    "curvedConnector3" => ShapeCurvedConnector3
    "curvedConnector4" => ShapeCurvedConnector4
    "curvedConnector5" => ShapeCurvedConnector5
    "callout1" => ShapeCallout1
    "callout2" => ShapeCallout2
    "callout3" => ShapeCallout3
    "accentCallout1" => ShapeAccentCallout1
    "accentCallout2" => ShapeAccentCallout2
    "accentCallout3" => ShapeAccentCallout3
    "borderCallout1" => ShapeBorderCallout1
    "borderCallout2" => ShapeBorderCallout2
    "borderCallout3" => ShapeBorderCallout3
    "accentBorderCallout1" => ShapeAccentBorderCallout1
    "accentBorderCallout2" => ShapeAccentBorderCallout2
    "accentBorderCallout3" => ShapeAccentBorderCallout3
    "wedgeRectCallout" => ShapeWedgeRectCallout
    "wedgeRoundRectCallout" => ShapeWedgeRoundRectCallout
    "wedgeEllipseCallout" => ShapeWedgeEllipseCallout
    "cloudCallout" => ShapeCloudCallout
    "cloud" => ShapeCloud
    "ribbon" => ShapeRibbon
    "ribbon2" => ShapeRibbon2
    "ellipseRibbon" => ShapeEllipseRibbon
    "ellipseRibbon2" => ShapeEllipseRibbon2
    "leftRightRibbon" => ShapeLeftRightRibbon
    "verticalScroll" => ShapeVerticalScroll
    "horizontalScroll" => ShapeHorizontalScroll
    "wave" => ShapeWave
    "doubleWave" => ShapeDoubleWave
    "plus" => ShapePlus
    "flowChartProcess" => ShapeFlowChartProcess
    "flowChartDecision" => ShapeFlowChartDecision
    "flowChartInputOutput" => ShapeFlowChartInputOutput
    "flowChartPredefinedProcess" => ShapeFlowChartPredefinedProcess
    "flowChartInternalStorage" => ShapeFlowChartInternalStorage
    "flowChartDocument" => ShapeFlowChartDocument
    "flowChartMultidocument" => ShapeFlowChartMultidocument
    "flowChartTerminator" => ShapeFlowChartTerminator
    "flowChartPreparation" => ShapeFlowChartPreparation
    "flowChartManualInput" => ShapeFlowChartManualInput
    "flowChartManualOperation" => ShapeFlowChartManualOperation
    "flowChartConnector" => ShapeFlowChartConnector
    "flowChartPunchedCard" => ShapeFlowChartPunchedCard
    "flowChartPunchedTape" => ShapeFlowChartPunchedTape
    "flowChartSummingJunction" => ShapeFlowChartSummingJunction
    "flowChartOr" => ShapeFlowChartOr
    "flowChartCollate" => ShapeFlowChartCollate
    "flowChartSort" => ShapeFlowChartSort
    "flowChartExtract" => ShapeFlowChartExtract
    "flowChartMerge" => ShapeFlowChartMerge
    "flowChartOfflineStorage" => ShapeFlowChartOfflineStorage
    "flowChartOnlineStorage" => ShapeFlowChartOnlineStorage
    "flowChartMagneticTape" => ShapeFlowChartMagneticTape
    "flowChartMagneticDisk" => ShapeFlowChartMagneticDisk
    "flowChartMagneticDrum" => ShapeFlowChartMagneticDrum
    "flowChartDisplay" => ShapeFlowChartDisplay
    "flowChartDelay" => ShapeFlowChartDelay
    "flowChartAlternateProcess" => ShapeFlowChartAlternateProcess
    "flowChartOffpageConnector" => ShapeFlowChartOffpageConnector
    "actionButtonBlank" => ShapeActionButtonBlank
    "actionButtonHome" => ShapeActionButtonHome
    "actionButtonHelp" => ShapeActionButtonHelp
    "actionButtonInformation" => ShapeActionButtonInformation
    "actionButtonForwardNext" => ShapeActionButtonForwardNext
    "actionButtonBackPrevious" => ShapeActionButtonBackPrevious
    "actionButtonEnd" => ShapeActionButtonEnd
    "actionButtonBeginning" => ShapeActionButtonBeginning
    "actionButtonReturn" => ShapeActionButtonReturn
    "actionButtonDocument" => ShapeActionButtonDocument
    "actionButtonSound" => ShapeActionButtonSound
    "actionButtonMovie" => ShapeActionButtonMovie
    "gear6" => ShapeGear6
    "gear9" => ShapeGear9
    "funnel" => ShapeFunnel
    "mathPlus" => ShapeMathPlus
    "mathMinus" => ShapeMathMinus
    "mathMultiply" => ShapeMathMultiply
    "mathDivide" => ShapeMathDivide
    "mathEqual" => ShapeMathEqual
    "mathNotEqual" => ShapeMathNotEqual
    "cornerTabs" => ShapeCornerTabs
    "squareTabs" => ShapeSquareTabs
    "plaqueTabs" => ShapePlaqueTabs
    "chartX" => ShapeChartX
    "chartStar" => ShapeChartStar
    "chartPlus" => ShapeChartPlus
    _ =>
      raise @opc_errors.SchemaViolation(
        section=preset_shape_section,
        path="prstGeom/@prst",
        reason="unknown ST_ShapeType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §20.1.10.56 — classify a preset shape into a render family.
/// Used by `build_geometry` to dispatch to the right per-family file
/// and by renderers to pick a default fill / stroke for the shape.
pub fn PresetShape::family(self : PresetShape) -> PresetShapeFamily {
  match self {
    ShapeLine
    | ShapeLineInv
    | ShapeStraightConnector1
    | ShapeBentConnector2
    | ShapeBentConnector3
    | ShapeBentConnector4
    | ShapeBentConnector5
    | ShapeCurvedConnector2
    | ShapeCurvedConnector3
    | ShapeCurvedConnector4
    | ShapeCurvedConnector5 => FamilyConnector
    ShapeLeftBracket
    | ShapeRightBracket
    | ShapeLeftBrace
    | ShapeRightBrace
    | ShapeBracketPair
    | ShapeBracePair => FamilyBracket
    ShapeStar4
    | ShapeStar5
    | ShapeStar6
    | ShapeStar7
    | ShapeStar8
    | ShapeStar10
    | ShapeStar12
    | ShapeStar16
    | ShapeStar24
    | ShapeStar32 => FamilyStar
    ShapeRightArrow
    | ShapeLeftArrow
    | ShapeUpArrow
    | ShapeDownArrow
    | ShapeStripedRightArrow
    | ShapeNotchedRightArrow
    | ShapeBentUpArrow
    | ShapeLeftRightArrow
    | ShapeUpDownArrow
    | ShapeLeftUpArrow
    | ShapeLeftRightUpArrow
    | ShapeQuadArrow
    | ShapeLeftArrowCallout
    | ShapeRightArrowCallout
    | ShapeUpArrowCallout
    | ShapeDownArrowCallout
    | ShapeLeftRightArrowCallout
    | ShapeUpDownArrowCallout
    | ShapeQuadArrowCallout
    | ShapeBentArrow
    | ShapeUturnArrow
    | ShapeCircularArrow
    | ShapeLeftCircularArrow
    | ShapeLeftRightCircularArrow
    | ShapeCurvedRightArrow
    | ShapeCurvedLeftArrow
    | ShapeCurvedUpArrow
    | ShapeCurvedDownArrow
    | ShapeSwooshArrow
    | ShapeChevron
    | ShapeHomePlate => FamilyArrow
    ShapeCallout1
    | ShapeCallout2
    | ShapeCallout3
    | ShapeAccentCallout1
    | ShapeAccentCallout2
    | ShapeAccentCallout3
    | ShapeBorderCallout1
    | ShapeBorderCallout2
    | ShapeBorderCallout3
    | ShapeAccentBorderCallout1
    | ShapeAccentBorderCallout2
    | ShapeAccentBorderCallout3
    | ShapeWedgeRectCallout
    | ShapeWedgeRoundRectCallout
    | ShapeWedgeEllipseCallout
    | ShapeCloudCallout => FamilyCallout
    ShapeFlowChartProcess
    | ShapeFlowChartDecision
    | ShapeFlowChartInputOutput
    | ShapeFlowChartPredefinedProcess
    | ShapeFlowChartInternalStorage
    | ShapeFlowChartDocument
    | ShapeFlowChartMultidocument
    | ShapeFlowChartTerminator
    | ShapeFlowChartPreparation
    | ShapeFlowChartManualInput
    | ShapeFlowChartManualOperation
    | ShapeFlowChartConnector
    | ShapeFlowChartPunchedCard
    | ShapeFlowChartPunchedTape
    | ShapeFlowChartSummingJunction
    | ShapeFlowChartOr
    | ShapeFlowChartCollate
    | ShapeFlowChartSort
    | ShapeFlowChartExtract
    | ShapeFlowChartMerge
    | ShapeFlowChartOfflineStorage
    | ShapeFlowChartOnlineStorage
    | ShapeFlowChartMagneticTape
    | ShapeFlowChartMagneticDisk
    | ShapeFlowChartMagneticDrum
    | ShapeFlowChartDisplay
    | ShapeFlowChartDelay
    | ShapeFlowChartAlternateProcess
    | ShapeFlowChartOffpageConnector => FamilyFlowChart
    ShapeActionButtonBlank
    | ShapeActionButtonHome
    | ShapeActionButtonHelp
    | ShapeActionButtonInformation
    | ShapeActionButtonForwardNext
    | ShapeActionButtonBackPrevious
    | ShapeActionButtonEnd
    | ShapeActionButtonBeginning
    | ShapeActionButtonReturn
    | ShapeActionButtonDocument
    | ShapeActionButtonSound
    | ShapeActionButtonMovie => FamilyActionButton
    ShapeMathPlus
    | ShapeMathMinus
    | ShapeMathMultiply
    | ShapeMathDivide
    | ShapeMathEqual
    | ShapeMathNotEqual
    | ShapePlus => FamilyMath
    ShapeRibbon
    | ShapeRibbon2
    | ShapeEllipseRibbon
    | ShapeEllipseRibbon2
    | ShapeLeftRightRibbon
    | ShapeVerticalScroll
    | ShapeHorizontalScroll
    | ShapeWave
    | ShapeDoubleWave => FamilyBanner
    ShapeRect
    | ShapeRoundRect
    | ShapeRound1Rect
    | ShapeRound2SameRect
    | ShapeRound2DiagRect
    | ShapeSnipRoundRect
    | ShapeSnip1Rect
    | ShapeSnip2SameRect
    | ShapeSnip2DiagRect
    | ShapePlaque
    | ShapeEllipse
    | ShapeTriangle
    | ShapeRtTriangle
    | ShapeDiamond
    | ShapeParallelogram
    | ShapeTrapezoid
    | ShapeNonIsoscelesTrapezoid
    | ShapePentagon
    | ShapeHexagon
    | ShapeHeptagon
    | ShapeOctagon
    | ShapeDecagon
    | ShapeDodecagon
    | ShapeFrame
    | ShapeHalfFrame
    | ShapeBevel
    | ShapeHeart
    | ShapeSmileyFace
    | ShapeCloud => FamilyRectangular
    _ => FamilyMisc
  }
}

///|
/// Part 1 §20.1.10.56 — render-family classification for the
/// `PresetShape::family` accessor. Eleven families partition the 187
/// ST_ShapeType values into renderer-meaningful buckets so dispatch
/// stays compact and the audit tooling can report coverage per family.
pub(all) enum PresetShapeFamily {
  /// Rectangular bodies — rectangles, polygons, ellipses, hearts,
  /// clouds and the smiley face.
  FamilyRectangular
  /// Arrow bodies — block, callout, bent, curved arrows + chevron /
  /// homePlate.
  FamilyArrow
  /// Callout bodies — speech-bubble + line-leader callouts and the
  /// cloud callout.
  FamilyCallout
  /// N-pointed star bodies — `star4`..`star32`.
  FamilyStar
  /// Flow-chart bodies — every `flowChart*` shape.
  FamilyFlowChart
  /// Action-button bodies — every `actionButton*` shape.
  FamilyActionButton
  /// Connector lines — straight, bent, curved connectors and the
  /// degenerate `line` / `lineInv` shapes.
  FamilyConnector
  /// Bracket-style decorations — left/right bracket and brace pairs.
  FamilyBracket
  /// Math symbols — `mathPlus`..`mathNotEqual` and `plus`.
  FamilyMath
  /// Ribbon and wave decorations — `ribbon*`, `wave`, `doubleWave`,
  /// scrolls.
  FamilyBanner
  /// Anything else that does not fit the above buckets.
  FamilyMisc
} derive(Eq, Debug)

///|
/// Part 1 §20.1.9.11 gd — typed adjustment-handle override decoded
/// from an `avLst/gd` element. `raw_formula` preserves the original
/// fmla string so renderers that understand more than `val` can still
/// dispatch on it; `value` carries the integer payload of `val n`
/// formulas, the only formula form a preset shape's `avLst` is allowed
/// to use per §20.1.10.56 ("the necessary guides should have the
/// following values").
pub(all) struct Adjustment {
  name : String
  raw_formula : String
  value : Int?
} derive(Eq, Debug)

///|
/// Part 1 §20.1.9.18 prstGeom — typed decoder result. `shape` is the
/// resolved §20.1.10.56 preset; `adjustments` is the (possibly empty)
/// list of `avLst/gd` overrides supplied by the document.
pub(all) struct PresetGeometry {
  shape : PresetShape
  adjustments : Array[Adjustment]
} derive(Eq, Debug)

///|
/// Vector path primitive used by every preset geometry. Coordinates
/// are integers in the caller-supplied bounding-box space (typically
/// `0..width` × `0..height`). All values follow the SVG convention of
/// `(0, 0)` at top-left and `(width, height)` at bottom-right.
pub(all) enum PathCommand {
  /// Move the pen to absolute `(x, y)` without drawing.
  MoveTo(Int, Int)
  /// Straight line from the current point to `(x, y)`.
  LineTo(Int, Int)
  /// Quadratic Bezier from the current point to `(x, y)` via control
  /// point `(cpx, cpy)`.
  QuadTo(Int, Int, Int, Int)
  /// Cubic Bezier from the current point to `(x, y)` via control
  /// points `(cp1x, cp1y)` and `(cp2x, cp2y)`.
  CurveTo(Int, Int, Int, Int, Int, Int)
  /// Elliptical arc from the current point to `(x, y)` along an
  /// ellipse of radii `(rx, ry)` rotated by `x_axis_rotation` degrees.
  /// `large_arc` selects the arc spanning more than 180°, `sweep`
  /// selects the clockwise sweep direction.
  ArcTo(Int, Int, Int, Bool, Bool, Int, Int)
  /// Close the current sub-path back to the most recent `MoveTo`.
  ClosePath
} derive(Eq, Debug)

///|
/// Materialised preset shape: the resolved path commands plus the
/// bounding-box dimensions the commands were generated for. Renderers
/// can scale the integer coordinates to the actual output unit (EMU,
/// pixels) by treating the box as a `[0, width] × [0, height]`
/// coordinate frame.
pub(all) struct ShapeGeometry {
  commands : Array[PathCommand]
  width : Int
  height : Int
} derive(Eq, Debug)

///|
/// `ShapeGeometry::command_count` — convenience accessor that returns
/// the number of path commands in the geometry. Renderers use this to
/// detect the fallback-rectangle case (5 commands: MoveTo + 3 LineTo +
/// ClosePath).
pub fn ShapeGeometry::command_count(self : ShapeGeometry) -> Int {
  self.commands.length()
}

///|
/// `ShapeGeometry::is_closed` — true when the last command is
/// `ClosePath`. Open connector shapes (line / straight / bent / curved
/// connectors) return `false`.
pub fn ShapeGeometry::is_closed(self : ShapeGeometry) -> Bool {
  let n = self.commands.length()
  if n == 0 {
    return false
  }
  match self.commands[n - 1] {
    ClosePath => true
    _ => false
  }
}

///|
let preset_shape_section : String = "Part 1 §20.1.10.56"

///|
/// Part 1 §20.1.10.56 — citation helper exposed so callers can include
/// the canonical section anchor in their own diagnostics. Returns the
/// string `"Part 1 §20.1.10.56"`.
pub fn preset_geometry_part1_20_1_10_56_section_name() -> String {
  preset_shape_section
}
