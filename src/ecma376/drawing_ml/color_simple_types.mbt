// ECMA-376 Part 1 §20.1.10 colour-related simple types — typed forms.

///|
/// XSD simple type ST_FontCollectionIndex — Part 1 §20.1.10.25. Selects one
/// of the major / minor / none font slots from the theme's font scheme.
pub(all) enum ST_FontCollectionIndex {
  /// §20.1.10.25 "major"
  FontMajor
  /// §20.1.10.25 "minor"
  FontMinor
  /// §20.1.10.25 "none"
  FontNone
} derive(Eq, Debug)

///|
pub fn ST_FontCollectionIndex::parse(
  s : String,
) -> ST_FontCollectionIndex raise SchemaViolation {
  match s {
    "major" => FontMajor
    "minor" => FontMinor
    "none" => FontNone
    _ => color_enum_violation("ST_FontCollectionIndex")
  }
}

///|
pub fn ST_FontCollectionIndex::new(
  s : String,
) -> ST_FontCollectionIndex raise SchemaViolation {
  ST_FontCollectionIndex::parse(s)
}

///|
pub fn ST_FontCollectionIndex::to_string(
  self : ST_FontCollectionIndex,
) -> String {
  match self {
    FontMajor => "major"
    FontMinor => "minor"
    FontNone => "none"
  }
}

///|
/// XSD simple type ST_ColorSchemeIndex — Part 1 §20.1.10.14. References one
/// of the theme palette's twelve named slots from a colour mapping element.
pub(all) enum ST_ColorSchemeIndex {
  /// §20.1.10.14 "dk1"
  SchemeIdxDk1
  /// §20.1.10.14 "lt1"
  SchemeIdxLt1
  /// §20.1.10.14 "dk2"
  SchemeIdxDk2
  /// §20.1.10.14 "lt2"
  SchemeIdxLt2
  /// §20.1.10.14 "accent1"
  SchemeIdxAccent1
  /// §20.1.10.14 "accent2"
  SchemeIdxAccent2
  /// §20.1.10.14 "accent3"
  SchemeIdxAccent3
  /// §20.1.10.14 "accent4"
  SchemeIdxAccent4
  /// §20.1.10.14 "accent5"
  SchemeIdxAccent5
  /// §20.1.10.14 "accent6"
  SchemeIdxAccent6
  /// §20.1.10.14 "hlink"
  SchemeIdxHlink
  /// §20.1.10.14 "folHlink"
  SchemeIdxFolHlink
} derive(Eq, Debug)

///|
pub fn ST_ColorSchemeIndex::parse(
  s : String,
) -> ST_ColorSchemeIndex raise SchemaViolation {
  match s {
    "dk1" => SchemeIdxDk1
    "lt1" => SchemeIdxLt1
    "dk2" => SchemeIdxDk2
    "lt2" => SchemeIdxLt2
    "accent1" => SchemeIdxAccent1
    "accent2" => SchemeIdxAccent2
    "accent3" => SchemeIdxAccent3
    "accent4" => SchemeIdxAccent4
    "accent5" => SchemeIdxAccent5
    "accent6" => SchemeIdxAccent6
    "hlink" => SchemeIdxHlink
    "folHlink" => SchemeIdxFolHlink
    _ => color_enum_violation("ST_ColorSchemeIndex")
  }
}

///|
pub fn ST_ColorSchemeIndex::new(
  s : String,
) -> ST_ColorSchemeIndex raise SchemaViolation {
  ST_ColorSchemeIndex::parse(s)
}

///|
pub fn ST_ColorSchemeIndex::to_string(self : ST_ColorSchemeIndex) -> String {
  match self {
    SchemeIdxDk1 => "dk1"
    SchemeIdxLt1 => "lt1"
    SchemeIdxDk2 => "dk2"
    SchemeIdxLt2 => "lt2"
    SchemeIdxAccent1 => "accent1"
    SchemeIdxAccent2 => "accent2"
    SchemeIdxAccent3 => "accent3"
    SchemeIdxAccent4 => "accent4"
    SchemeIdxAccent5 => "accent5"
    SchemeIdxAccent6 => "accent6"
    SchemeIdxHlink => "hlink"
    SchemeIdxFolHlink => "folHlink"
  }
}

///|
/// XSD simple type ST_SystemColorVal — Part 1 §20.1.10.58. Windows
/// system-colour palette names that the spec enumerates verbatim.
pub(all) enum ST_SystemColorVal {
  /// §20.1.10.58 "scrollBar"
  SysScrollBar
  /// §20.1.10.58 "background"
  SysBackground
  /// §20.1.10.58 "activeCaption"
  SysActiveCaption
  /// §20.1.10.58 "inactiveCaption"
  SysInactiveCaption
  /// §20.1.10.58 "menu"
  SysMenu
  /// §20.1.10.58 "window"
  SysWindow
  /// §20.1.10.58 "windowFrame"
  SysWindowFrame
  /// §20.1.10.58 "menuText"
  SysMenuText
  /// §20.1.10.58 "windowText"
  SysWindowText
  /// §20.1.10.58 "captionText"
  SysCaptionText
  /// §20.1.10.58 "activeBorder"
  SysActiveBorder
  /// §20.1.10.58 "inactiveBorder"
  SysInactiveBorder
  /// §20.1.10.58 "appWorkspace"
  SysAppWorkspace
  /// §20.1.10.58 "highlight"
  SysHighlight
  /// §20.1.10.58 "highlightText"
  SysHighlightText
  /// §20.1.10.58 "btnFace"
  SysBtnFace
  /// §20.1.10.58 "btnShadow"
  SysBtnShadow
  /// §20.1.10.58 "grayText"
  SysGrayText
  /// §20.1.10.58 "btnText"
  SysBtnText
  /// §20.1.10.58 "inactiveCaptionText"
  SysInactiveCaptionText
  /// §20.1.10.58 "btnHighlight"
  SysBtnHighlight
  /// §20.1.10.58 "3dDkShadow"
  Sys3dDkShadow
  /// §20.1.10.58 "3dLight"
  Sys3dLight
  /// §20.1.10.58 "infoText"
  SysInfoText
  /// §20.1.10.58 "infoBk"
  SysInfoBk
  /// §20.1.10.58 "hotLight"
  SysHotLight
  /// §20.1.10.58 "gradientActiveCaption"
  SysGradientActiveCaption
  /// §20.1.10.58 "gradientInactiveCaption"
  SysGradientInactiveCaption
  /// §20.1.10.58 "menuHighlight"
  SysMenuHighlight
  /// §20.1.10.58 "menuBar"
  SysMenuBar
} derive(Eq, Debug)

///|
pub fn ST_SystemColorVal::parse(
  s : String,
) -> ST_SystemColorVal raise SchemaViolation {
  match s {
    "scrollBar" => SysScrollBar
    "background" => SysBackground
    "activeCaption" => SysActiveCaption
    "inactiveCaption" => SysInactiveCaption
    "menu" => SysMenu
    "window" => SysWindow
    "windowFrame" => SysWindowFrame
    "menuText" => SysMenuText
    "windowText" => SysWindowText
    "captionText" => SysCaptionText
    "activeBorder" => SysActiveBorder
    "inactiveBorder" => SysInactiveBorder
    "appWorkspace" => SysAppWorkspace
    "highlight" => SysHighlight
    "highlightText" => SysHighlightText
    "btnFace" => SysBtnFace
    "btnShadow" => SysBtnShadow
    "grayText" => SysGrayText
    "btnText" => SysBtnText
    "inactiveCaptionText" => SysInactiveCaptionText
    "btnHighlight" => SysBtnHighlight
    "3dDkShadow" => Sys3dDkShadow
    "3dLight" => Sys3dLight
    "infoText" => SysInfoText
    "infoBk" => SysInfoBk
    "hotLight" => SysHotLight
    "gradientActiveCaption" => SysGradientActiveCaption
    "gradientInactiveCaption" => SysGradientInactiveCaption
    "menuHighlight" => SysMenuHighlight
    "menuBar" => SysMenuBar
    _ => color_enum_violation("ST_SystemColorVal")
  }
}

///|
pub fn ST_SystemColorVal::new(
  s : String,
) -> ST_SystemColorVal raise SchemaViolation {
  ST_SystemColorVal::parse(s)
}

///|
pub fn ST_SystemColorVal::to_string(self : ST_SystemColorVal) -> String {
  match self {
    SysScrollBar => "scrollBar"
    SysBackground => "background"
    SysActiveCaption => "activeCaption"
    SysInactiveCaption => "inactiveCaption"
    SysMenu => "menu"
    SysWindow => "window"
    SysWindowFrame => "windowFrame"
    SysMenuText => "menuText"
    SysWindowText => "windowText"
    SysCaptionText => "captionText"
    SysActiveBorder => "activeBorder"
    SysInactiveBorder => "inactiveBorder"
    SysAppWorkspace => "appWorkspace"
    SysHighlight => "highlight"
    SysHighlightText => "highlightText"
    SysBtnFace => "btnFace"
    SysBtnShadow => "btnShadow"
    SysGrayText => "grayText"
    SysBtnText => "btnText"
    SysInactiveCaptionText => "inactiveCaptionText"
    SysBtnHighlight => "btnHighlight"
    Sys3dDkShadow => "3dDkShadow"
    Sys3dLight => "3dLight"
    SysInfoText => "infoText"
    SysInfoBk => "infoBk"
    SysHotLight => "hotLight"
    SysGradientActiveCaption => "gradientActiveCaption"
    SysGradientInactiveCaption => "gradientInactiveCaption"
    SysMenuHighlight => "menuHighlight"
    SysMenuBar => "menuBar"
  }
}

///|
/// XSD simple type ST_SchemeColorVal — Part 1 §20.1.10.54. Theme palette
/// references including the placeholder colour and the eight + four named
/// slots.
pub(all) enum ST_SchemeColorVal {
  /// §20.1.10.54 "bg1"
  SchemeBg1
  /// §20.1.10.54 "tx1"
  SchemeTx1
  /// §20.1.10.54 "bg2"
  SchemeBg2
  /// §20.1.10.54 "tx2"
  SchemeTx2
  /// §20.1.10.54 "accent1"
  SchemeAccent1
  /// §20.1.10.54 "accent2"
  SchemeAccent2
  /// §20.1.10.54 "accent3"
  SchemeAccent3
  /// §20.1.10.54 "accent4"
  SchemeAccent4
  /// §20.1.10.54 "accent5"
  SchemeAccent5
  /// §20.1.10.54 "accent6"
  SchemeAccent6
  /// §20.1.10.54 "hlink"
  SchemeHlink
  /// §20.1.10.54 "folHlink"
  SchemeFolHlink
  /// §20.1.10.54 "phClr"
  SchemePhClr
  /// §20.1.10.54 "dk1"
  SchemeDk1
  /// §20.1.10.54 "lt1"
  SchemeLt1
  /// §20.1.10.54 "dk2"
  SchemeDk2
  /// §20.1.10.54 "lt2"
  SchemeLt2
} derive(Eq, Debug)

///|
pub fn ST_SchemeColorVal::parse(
  s : String,
) -> ST_SchemeColorVal raise SchemaViolation {
  match s {
    "bg1" => SchemeBg1
    "tx1" => SchemeTx1
    "bg2" => SchemeBg2
    "tx2" => SchemeTx2
    "accent1" => SchemeAccent1
    "accent2" => SchemeAccent2
    "accent3" => SchemeAccent3
    "accent4" => SchemeAccent4
    "accent5" => SchemeAccent5
    "accent6" => SchemeAccent6
    "hlink" => SchemeHlink
    "folHlink" => SchemeFolHlink
    "phClr" => SchemePhClr
    "dk1" => SchemeDk1
    "lt1" => SchemeLt1
    "dk2" => SchemeDk2
    "lt2" => SchemeLt2
    _ => color_enum_violation("ST_SchemeColorVal")
  }
}

///|
pub fn ST_SchemeColorVal::new(
  s : String,
) -> ST_SchemeColorVal raise SchemaViolation {
  ST_SchemeColorVal::parse(s)
}

///|
pub fn ST_SchemeColorVal::to_string(self : ST_SchemeColorVal) -> String {
  match self {
    SchemeBg1 => "bg1"
    SchemeTx1 => "tx1"
    SchemeBg2 => "bg2"
    SchemeTx2 => "tx2"
    SchemeAccent1 => "accent1"
    SchemeAccent2 => "accent2"
    SchemeAccent3 => "accent3"
    SchemeAccent4 => "accent4"
    SchemeAccent5 => "accent5"
    SchemeAccent6 => "accent6"
    SchemeHlink => "hlink"
    SchemeFolHlink => "folHlink"
    SchemePhClr => "phClr"
    SchemeDk1 => "dk1"
    SchemeLt1 => "lt1"
    SchemeDk2 => "dk2"
    SchemeLt2 => "lt2"
  }
}

///|
/// XSD simple type ST_PresetColorVal — Part 1 §20.1.10.48. Named CSS-style
/// colour identifiers. The schema lists 175 names verbatim (including the
/// `dk*` / `lt*` and `med*` short forms).
pub(all) enum ST_PresetColorVal {
  /// §20.1.10.48 "aliceBlue"
  PresetAliceBlue
  /// §20.1.10.48 "antiqueWhite"
  PresetAntiqueWhite
  /// §20.1.10.48 "aqua"
  PresetAqua
  /// §20.1.10.48 "aquamarine"
  PresetAquamarine
  /// §20.1.10.48 "azure"
  PresetAzure
  /// §20.1.10.48 "beige"
  PresetBeige
  /// §20.1.10.48 "bisque"
  PresetBisque
  /// §20.1.10.48 "black"
  PresetBlack
  /// §20.1.10.48 "blanchedAlmond"
  PresetBlanchedAlmond
  /// §20.1.10.48 "blue"
  PresetBlue
  /// §20.1.10.48 "blueViolet"
  PresetBlueViolet
  /// §20.1.10.48 "brown"
  PresetBrown
  /// §20.1.10.48 "burlyWood"
  PresetBurlyWood
  /// §20.1.10.48 "cadetBlue"
  PresetCadetBlue
  /// §20.1.10.48 "chartreuse"
  PresetChartreuse
  /// §20.1.10.48 "chocolate"
  PresetChocolate
  /// §20.1.10.48 "coral"
  PresetCoral
  /// §20.1.10.48 "cornflowerBlue"
  PresetCornflowerBlue
  /// §20.1.10.48 "cornsilk"
  PresetCornsilk
  /// §20.1.10.48 "crimson"
  PresetCrimson
  /// §20.1.10.48 "cyan"
  PresetCyan
  /// §20.1.10.48 "darkBlue"
  PresetDarkBlue
  /// §20.1.10.48 "darkCyan"
  PresetDarkCyan
  /// §20.1.10.48 "darkGoldenrod"
  PresetDarkGoldenrod
  /// §20.1.10.48 "darkGray"
  PresetDarkGray
  /// §20.1.10.48 "darkGrey"
  PresetDarkGrey
  /// §20.1.10.48 "darkGreen"
  PresetDarkGreen
  /// §20.1.10.48 "darkKhaki"
  PresetDarkKhaki
  /// §20.1.10.48 "darkMagenta"
  PresetDarkMagenta
  /// §20.1.10.48 "darkOliveGreen"
  PresetDarkOliveGreen
  /// §20.1.10.48 "darkOrange"
  PresetDarkOrange
  /// §20.1.10.48 "darkOrchid"
  PresetDarkOrchid
  /// §20.1.10.48 "darkRed"
  PresetDarkRed
  /// §20.1.10.48 "darkSalmon"
  PresetDarkSalmon
  /// §20.1.10.48 "darkSeaGreen"
  PresetDarkSeaGreen
  /// §20.1.10.48 "darkSlateBlue"
  PresetDarkSlateBlue
  /// §20.1.10.48 "darkSlateGray"
  PresetDarkSlateGray
  /// §20.1.10.48 "darkSlateGrey"
  PresetDarkSlateGrey
  /// §20.1.10.48 "darkTurquoise"
  PresetDarkTurquoise
  /// §20.1.10.48 "darkViolet"
  PresetDarkViolet
  /// §20.1.10.48 "dkBlue"
  PresetDkBlue
  /// §20.1.10.48 "dkCyan"
  PresetDkCyan
  /// §20.1.10.48 "dkGoldenrod"
  PresetDkGoldenrod
  /// §20.1.10.48 "dkGray"
  PresetDkGray
  /// §20.1.10.48 "dkGrey"
  PresetDkGrey
  /// §20.1.10.48 "dkGreen"
  PresetDkGreen
  /// §20.1.10.48 "dkKhaki"
  PresetDkKhaki
  /// §20.1.10.48 "dkMagenta"
  PresetDkMagenta
  /// §20.1.10.48 "dkOliveGreen"
  PresetDkOliveGreen
  /// §20.1.10.48 "dkOrange"
  PresetDkOrange
  /// §20.1.10.48 "dkOrchid"
  PresetDkOrchid
  /// §20.1.10.48 "dkRed"
  PresetDkRed
  /// §20.1.10.48 "dkSalmon"
  PresetDkSalmon
  /// §20.1.10.48 "dkSeaGreen"
  PresetDkSeaGreen
  /// §20.1.10.48 "dkSlateBlue"
  PresetDkSlateBlue
  /// §20.1.10.48 "dkSlateGray"
  PresetDkSlateGray
  /// §20.1.10.48 "dkSlateGrey"
  PresetDkSlateGrey
  /// §20.1.10.48 "dkTurquoise"
  PresetDkTurquoise
  /// §20.1.10.48 "dkViolet"
  PresetDkViolet
  /// §20.1.10.48 "deepPink"
  PresetDeepPink
  /// §20.1.10.48 "deepSkyBlue"
  PresetDeepSkyBlue
  /// §20.1.10.48 "dimGray"
  PresetDimGray
  /// §20.1.10.48 "dimGrey"
  PresetDimGrey
  /// §20.1.10.48 "dodgerBlue"
  PresetDodgerBlue
  /// §20.1.10.48 "firebrick"
  PresetFirebrick
  /// §20.1.10.48 "floralWhite"
  PresetFloralWhite
  /// §20.1.10.48 "forestGreen"
  PresetForestGreen
  /// §20.1.10.48 "fuchsia"
  PresetFuchsia
  /// §20.1.10.48 "gainsboro"
  PresetGainsboro
  /// §20.1.10.48 "ghostWhite"
  PresetGhostWhite
  /// §20.1.10.48 "gold"
  PresetGold
  /// §20.1.10.48 "goldenrod"
  PresetGoldenrod
  /// §20.1.10.48 "gray"
  PresetGray
  /// §20.1.10.48 "grey"
  PresetGrey
  /// §20.1.10.48 "green"
  PresetGreen
  /// §20.1.10.48 "greenYellow"
  PresetGreenYellow
  /// §20.1.10.48 "honeydew"
  PresetHoneydew
  /// §20.1.10.48 "hotPink"
  PresetHotPink
  /// §20.1.10.48 "indianRed"
  PresetIndianRed
  /// §20.1.10.48 "indigo"
  PresetIndigo
  /// §20.1.10.48 "ivory"
  PresetIvory
  /// §20.1.10.48 "khaki"
  PresetKhaki
  /// §20.1.10.48 "lavender"
  PresetLavender
  /// §20.1.10.48 "lavenderBlush"
  PresetLavenderBlush
  /// §20.1.10.48 "lawnGreen"
  PresetLawnGreen
  /// §20.1.10.48 "lemonChiffon"
  PresetLemonChiffon
  /// §20.1.10.48 "lightBlue"
  PresetLightBlue
  /// §20.1.10.48 "lightCoral"
  PresetLightCoral
  /// §20.1.10.48 "lightCyan"
  PresetLightCyan
  /// §20.1.10.48 "lightGoldenrodYellow"
  PresetLightGoldenrodYellow
  /// §20.1.10.48 "lightGray"
  PresetLightGray
  /// §20.1.10.48 "lightGrey"
  PresetLightGrey
  /// §20.1.10.48 "lightGreen"
  PresetLightGreen
  /// §20.1.10.48 "lightPink"
  PresetLightPink
  /// §20.1.10.48 "lightSalmon"
  PresetLightSalmon
  /// §20.1.10.48 "lightSeaGreen"
  PresetLightSeaGreen
  /// §20.1.10.48 "lightSkyBlue"
  PresetLightSkyBlue
  /// §20.1.10.48 "lightSlateGray"
  PresetLightSlateGray
  /// §20.1.10.48 "lightSlateGrey"
  PresetLightSlateGrey
  /// §20.1.10.48 "lightSteelBlue"
  PresetLightSteelBlue
  /// §20.1.10.48 "lightYellow"
  PresetLightYellow
  /// §20.1.10.48 "ltBlue"
  PresetLtBlue
  /// §20.1.10.48 "ltCoral"
  PresetLtCoral
  /// §20.1.10.48 "ltCyan"
  PresetLtCyan
  /// §20.1.10.48 "ltGoldenrodYellow"
  PresetLtGoldenrodYellow
  /// §20.1.10.48 "ltGray"
  PresetLtGray
  /// §20.1.10.48 "ltGrey"
  PresetLtGrey
  /// §20.1.10.48 "ltGreen"
  PresetLtGreen
  /// §20.1.10.48 "ltPink"
  PresetLtPink
  /// §20.1.10.48 "ltSalmon"
  PresetLtSalmon
  /// §20.1.10.48 "ltSeaGreen"
  PresetLtSeaGreen
  /// §20.1.10.48 "ltSkyBlue"
  PresetLtSkyBlue
  /// §20.1.10.48 "ltSlateGray"
  PresetLtSlateGray
  /// §20.1.10.48 "ltSlateGrey"
  PresetLtSlateGrey
  /// §20.1.10.48 "ltSteelBlue"
  PresetLtSteelBlue
  /// §20.1.10.48 "ltYellow"
  PresetLtYellow
  /// §20.1.10.48 "lime"
  PresetLime
  /// §20.1.10.48 "limeGreen"
  PresetLimeGreen
  /// §20.1.10.48 "linen"
  PresetLinen
  /// §20.1.10.48 "magenta"
  PresetMagenta
  /// §20.1.10.48 "maroon"
  PresetMaroon
  /// §20.1.10.48 "medAquamarine"
  PresetMedAquamarine
  /// §20.1.10.48 "medBlue"
  PresetMedBlue
  /// §20.1.10.48 "medOrchid"
  PresetMedOrchid
  /// §20.1.10.48 "medPurple"
  PresetMedPurple
  /// §20.1.10.48 "medSeaGreen"
  PresetMedSeaGreen
  /// §20.1.10.48 "medSlateBlue"
  PresetMedSlateBlue
  /// §20.1.10.48 "medSpringGreen"
  PresetMedSpringGreen
  /// §20.1.10.48 "medTurquoise"
  PresetMedTurquoise
  /// §20.1.10.48 "medVioletRed"
  PresetMedVioletRed
  /// §20.1.10.48 "mediumAquamarine"
  PresetMediumAquamarine
  /// §20.1.10.48 "mediumBlue"
  PresetMediumBlue
  /// §20.1.10.48 "mediumOrchid"
  PresetMediumOrchid
  /// §20.1.10.48 "mediumPurple"
  PresetMediumPurple
  /// §20.1.10.48 "mediumSeaGreen"
  PresetMediumSeaGreen
  /// §20.1.10.48 "mediumSlateBlue"
  PresetMediumSlateBlue
  /// §20.1.10.48 "mediumSpringGreen"
  PresetMediumSpringGreen
  /// §20.1.10.48 "mediumTurquoise"
  PresetMediumTurquoise
  /// §20.1.10.48 "mediumVioletRed"
  PresetMediumVioletRed
  /// §20.1.10.48 "midnightBlue"
  PresetMidnightBlue
  /// §20.1.10.48 "mintCream"
  PresetMintCream
  /// §20.1.10.48 "mistyRose"
  PresetMistyRose
  /// §20.1.10.48 "moccasin"
  PresetMoccasin
  /// §20.1.10.48 "navajoWhite"
  PresetNavajoWhite
  /// §20.1.10.48 "navy"
  PresetNavy
  /// §20.1.10.48 "oldLace"
  PresetOldLace
  /// §20.1.10.48 "olive"
  PresetOlive
  /// §20.1.10.48 "oliveDrab"
  PresetOliveDrab
  /// §20.1.10.48 "orange"
  PresetOrange
  /// §20.1.10.48 "orangeRed"
  PresetOrangeRed
  /// §20.1.10.48 "orchid"
  PresetOrchid
  /// §20.1.10.48 "paleGoldenrod"
  PresetPaleGoldenrod
  /// §20.1.10.48 "paleGreen"
  PresetPaleGreen
  /// §20.1.10.48 "paleTurquoise"
  PresetPaleTurquoise
  /// §20.1.10.48 "paleVioletRed"
  PresetPaleVioletRed
  /// §20.1.10.48 "papayaWhip"
  PresetPapayaWhip
  /// §20.1.10.48 "peachPuff"
  PresetPeachPuff
  /// §20.1.10.48 "peru"
  PresetPeru
  /// §20.1.10.48 "pink"
  PresetPink
  /// §20.1.10.48 "plum"
  PresetPlum
  /// §20.1.10.48 "powderBlue"
  PresetPowderBlue
  /// §20.1.10.48 "purple"
  PresetPurple
  /// §20.1.10.48 "red"
  PresetRed
  /// §20.1.10.48 "rosyBrown"
  PresetRosyBrown
  /// §20.1.10.48 "royalBlue"
  PresetRoyalBlue
  /// §20.1.10.48 "saddleBrown"
  PresetSaddleBrown
  /// §20.1.10.48 "salmon"
  PresetSalmon
  /// §20.1.10.48 "sandyBrown"
  PresetSandyBrown
  /// §20.1.10.48 "seaGreen"
  PresetSeaGreen
  /// §20.1.10.48 "seaShell"
  PresetSeaShell
  /// §20.1.10.48 "sienna"
  PresetSienna
  /// §20.1.10.48 "silver"
  PresetSilver
  /// §20.1.10.48 "skyBlue"
  PresetSkyBlue
  /// §20.1.10.48 "slateBlue"
  PresetSlateBlue
  /// §20.1.10.48 "slateGray"
  PresetSlateGray
  /// §20.1.10.48 "slateGrey"
  PresetSlateGrey
  /// §20.1.10.48 "snow"
  PresetSnow
  /// §20.1.10.48 "springGreen"
  PresetSpringGreen
  /// §20.1.10.48 "steelBlue"
  PresetSteelBlue
  /// §20.1.10.48 "tan"
  PresetTan
  /// §20.1.10.48 "teal"
  PresetTeal
  /// §20.1.10.48 "thistle"
  PresetThistle
  /// §20.1.10.48 "tomato"
  PresetTomato
  /// §20.1.10.48 "turquoise"
  PresetTurquoise
  /// §20.1.10.48 "violet"
  PresetViolet
  /// §20.1.10.48 "wheat"
  PresetWheat
  /// §20.1.10.48 "white"
  PresetWhite
  /// §20.1.10.48 "whiteSmoke"
  PresetWhiteSmoke
  /// §20.1.10.48 "yellow"
  PresetYellow
  /// §20.1.10.48 "yellowGreen"
  PresetYellowGreen
} derive(Eq, Debug)

///|
pub fn ST_PresetColorVal::parse(
  s : String,
) -> ST_PresetColorVal raise SchemaViolation {
  match s {
    "aliceBlue" => PresetAliceBlue
    "antiqueWhite" => PresetAntiqueWhite
    "aqua" => PresetAqua
    "aquamarine" => PresetAquamarine
    "azure" => PresetAzure
    "beige" => PresetBeige
    "bisque" => PresetBisque
    "black" => PresetBlack
    "blanchedAlmond" => PresetBlanchedAlmond
    "blue" => PresetBlue
    "blueViolet" => PresetBlueViolet
    "brown" => PresetBrown
    "burlyWood" => PresetBurlyWood
    "cadetBlue" => PresetCadetBlue
    "chartreuse" => PresetChartreuse
    "chocolate" => PresetChocolate
    "coral" => PresetCoral
    "cornflowerBlue" => PresetCornflowerBlue
    "cornsilk" => PresetCornsilk
    "crimson" => PresetCrimson
    "cyan" => PresetCyan
    "darkBlue" => PresetDarkBlue
    "darkCyan" => PresetDarkCyan
    "darkGoldenrod" => PresetDarkGoldenrod
    "darkGray" => PresetDarkGray
    "darkGrey" => PresetDarkGrey
    "darkGreen" => PresetDarkGreen
    "darkKhaki" => PresetDarkKhaki
    "darkMagenta" => PresetDarkMagenta
    "darkOliveGreen" => PresetDarkOliveGreen
    "darkOrange" => PresetDarkOrange
    "darkOrchid" => PresetDarkOrchid
    "darkRed" => PresetDarkRed
    "darkSalmon" => PresetDarkSalmon
    "darkSeaGreen" => PresetDarkSeaGreen
    "darkSlateBlue" => PresetDarkSlateBlue
    "darkSlateGray" => PresetDarkSlateGray
    "darkSlateGrey" => PresetDarkSlateGrey
    "darkTurquoise" => PresetDarkTurquoise
    "darkViolet" => PresetDarkViolet
    "dkBlue" => PresetDkBlue
    "dkCyan" => PresetDkCyan
    "dkGoldenrod" => PresetDkGoldenrod
    "dkGray" => PresetDkGray
    "dkGrey" => PresetDkGrey
    "dkGreen" => PresetDkGreen
    "dkKhaki" => PresetDkKhaki
    "dkMagenta" => PresetDkMagenta
    "dkOliveGreen" => PresetDkOliveGreen
    "dkOrange" => PresetDkOrange
    "dkOrchid" => PresetDkOrchid
    "dkRed" => PresetDkRed
    "dkSalmon" => PresetDkSalmon
    "dkSeaGreen" => PresetDkSeaGreen
    "dkSlateBlue" => PresetDkSlateBlue
    "dkSlateGray" => PresetDkSlateGray
    "dkSlateGrey" => PresetDkSlateGrey
    "dkTurquoise" => PresetDkTurquoise
    "dkViolet" => PresetDkViolet
    "deepPink" => PresetDeepPink
    "deepSkyBlue" => PresetDeepSkyBlue
    "dimGray" => PresetDimGray
    "dimGrey" => PresetDimGrey
    "dodgerBlue" => PresetDodgerBlue
    "firebrick" => PresetFirebrick
    "floralWhite" => PresetFloralWhite
    "forestGreen" => PresetForestGreen
    "fuchsia" => PresetFuchsia
    "gainsboro" => PresetGainsboro
    "ghostWhite" => PresetGhostWhite
    "gold" => PresetGold
    "goldenrod" => PresetGoldenrod
    "gray" => PresetGray
    "grey" => PresetGrey
    "green" => PresetGreen
    "greenYellow" => PresetGreenYellow
    "honeydew" => PresetHoneydew
    "hotPink" => PresetHotPink
    "indianRed" => PresetIndianRed
    "indigo" => PresetIndigo
    "ivory" => PresetIvory
    "khaki" => PresetKhaki
    "lavender" => PresetLavender
    "lavenderBlush" => PresetLavenderBlush
    "lawnGreen" => PresetLawnGreen
    "lemonChiffon" => PresetLemonChiffon
    "lightBlue" => PresetLightBlue
    "lightCoral" => PresetLightCoral
    "lightCyan" => PresetLightCyan
    "lightGoldenrodYellow" => PresetLightGoldenrodYellow
    "lightGray" => PresetLightGray
    "lightGrey" => PresetLightGrey
    "lightGreen" => PresetLightGreen
    "lightPink" => PresetLightPink
    "lightSalmon" => PresetLightSalmon
    "lightSeaGreen" => PresetLightSeaGreen
    "lightSkyBlue" => PresetLightSkyBlue
    "lightSlateGray" => PresetLightSlateGray
    "lightSlateGrey" => PresetLightSlateGrey
    "lightSteelBlue" => PresetLightSteelBlue
    "lightYellow" => PresetLightYellow
    "ltBlue" => PresetLtBlue
    "ltCoral" => PresetLtCoral
    "ltCyan" => PresetLtCyan
    "ltGoldenrodYellow" => PresetLtGoldenrodYellow
    "ltGray" => PresetLtGray
    "ltGrey" => PresetLtGrey
    "ltGreen" => PresetLtGreen
    "ltPink" => PresetLtPink
    "ltSalmon" => PresetLtSalmon
    "ltSeaGreen" => PresetLtSeaGreen
    "ltSkyBlue" => PresetLtSkyBlue
    "ltSlateGray" => PresetLtSlateGray
    "ltSlateGrey" => PresetLtSlateGrey
    "ltSteelBlue" => PresetLtSteelBlue
    "ltYellow" => PresetLtYellow
    "lime" => PresetLime
    "limeGreen" => PresetLimeGreen
    "linen" => PresetLinen
    "magenta" => PresetMagenta
    "maroon" => PresetMaroon
    "medAquamarine" => PresetMedAquamarine
    "medBlue" => PresetMedBlue
    "medOrchid" => PresetMedOrchid
    "medPurple" => PresetMedPurple
    "medSeaGreen" => PresetMedSeaGreen
    "medSlateBlue" => PresetMedSlateBlue
    "medSpringGreen" => PresetMedSpringGreen
    "medTurquoise" => PresetMedTurquoise
    "medVioletRed" => PresetMedVioletRed
    "mediumAquamarine" => PresetMediumAquamarine
    "mediumBlue" => PresetMediumBlue
    "mediumOrchid" => PresetMediumOrchid
    "mediumPurple" => PresetMediumPurple
    "mediumSeaGreen" => PresetMediumSeaGreen
    "mediumSlateBlue" => PresetMediumSlateBlue
    "mediumSpringGreen" => PresetMediumSpringGreen
    "mediumTurquoise" => PresetMediumTurquoise
    "mediumVioletRed" => PresetMediumVioletRed
    "midnightBlue" => PresetMidnightBlue
    "mintCream" => PresetMintCream
    "mistyRose" => PresetMistyRose
    "moccasin" => PresetMoccasin
    "navajoWhite" => PresetNavajoWhite
    "navy" => PresetNavy
    "oldLace" => PresetOldLace
    "olive" => PresetOlive
    "oliveDrab" => PresetOliveDrab
    "orange" => PresetOrange
    "orangeRed" => PresetOrangeRed
    "orchid" => PresetOrchid
    "paleGoldenrod" => PresetPaleGoldenrod
    "paleGreen" => PresetPaleGreen
    "paleTurquoise" => PresetPaleTurquoise
    "paleVioletRed" => PresetPaleVioletRed
    "papayaWhip" => PresetPapayaWhip
    "peachPuff" => PresetPeachPuff
    "peru" => PresetPeru
    "pink" => PresetPink
    "plum" => PresetPlum
    "powderBlue" => PresetPowderBlue
    "purple" => PresetPurple
    "red" => PresetRed
    "rosyBrown" => PresetRosyBrown
    "royalBlue" => PresetRoyalBlue
    "saddleBrown" => PresetSaddleBrown
    "salmon" => PresetSalmon
    "sandyBrown" => PresetSandyBrown
    "seaGreen" => PresetSeaGreen
    "seaShell" => PresetSeaShell
    "sienna" => PresetSienna
    "silver" => PresetSilver
    "skyBlue" => PresetSkyBlue
    "slateBlue" => PresetSlateBlue
    "slateGray" => PresetSlateGray
    "slateGrey" => PresetSlateGrey
    "snow" => PresetSnow
    "springGreen" => PresetSpringGreen
    "steelBlue" => PresetSteelBlue
    "tan" => PresetTan
    "teal" => PresetTeal
    "thistle" => PresetThistle
    "tomato" => PresetTomato
    "turquoise" => PresetTurquoise
    "violet" => PresetViolet
    "wheat" => PresetWheat
    "white" => PresetWhite
    "whiteSmoke" => PresetWhiteSmoke
    "yellow" => PresetYellow
    "yellowGreen" => PresetYellowGreen
    _ => color_enum_violation("ST_PresetColorVal")
  }
}

///|
pub fn ST_PresetColorVal::new(
  s : String,
) -> ST_PresetColorVal raise SchemaViolation {
  ST_PresetColorVal::parse(s)
}

///|
pub fn ST_PresetColorVal::to_string(self : ST_PresetColorVal) -> String {
  match self {
    PresetAliceBlue => "aliceBlue"
    PresetAntiqueWhite => "antiqueWhite"
    PresetAqua => "aqua"
    PresetAquamarine => "aquamarine"
    PresetAzure => "azure"
    PresetBeige => "beige"
    PresetBisque => "bisque"
    PresetBlack => "black"
    PresetBlanchedAlmond => "blanchedAlmond"
    PresetBlue => "blue"
    PresetBlueViolet => "blueViolet"
    PresetBrown => "brown"
    PresetBurlyWood => "burlyWood"
    PresetCadetBlue => "cadetBlue"
    PresetChartreuse => "chartreuse"
    PresetChocolate => "chocolate"
    PresetCoral => "coral"
    PresetCornflowerBlue => "cornflowerBlue"
    PresetCornsilk => "cornsilk"
    PresetCrimson => "crimson"
    PresetCyan => "cyan"
    PresetDarkBlue => "darkBlue"
    PresetDarkCyan => "darkCyan"
    PresetDarkGoldenrod => "darkGoldenrod"
    PresetDarkGray => "darkGray"
    PresetDarkGrey => "darkGrey"
    PresetDarkGreen => "darkGreen"
    PresetDarkKhaki => "darkKhaki"
    PresetDarkMagenta => "darkMagenta"
    PresetDarkOliveGreen => "darkOliveGreen"
    PresetDarkOrange => "darkOrange"
    PresetDarkOrchid => "darkOrchid"
    PresetDarkRed => "darkRed"
    PresetDarkSalmon => "darkSalmon"
    PresetDarkSeaGreen => "darkSeaGreen"
    PresetDarkSlateBlue => "darkSlateBlue"
    PresetDarkSlateGray => "darkSlateGray"
    PresetDarkSlateGrey => "darkSlateGrey"
    PresetDarkTurquoise => "darkTurquoise"
    PresetDarkViolet => "darkViolet"
    PresetDkBlue => "dkBlue"
    PresetDkCyan => "dkCyan"
    PresetDkGoldenrod => "dkGoldenrod"
    PresetDkGray => "dkGray"
    PresetDkGrey => "dkGrey"
    PresetDkGreen => "dkGreen"
    PresetDkKhaki => "dkKhaki"
    PresetDkMagenta => "dkMagenta"
    PresetDkOliveGreen => "dkOliveGreen"
    PresetDkOrange => "dkOrange"
    PresetDkOrchid => "dkOrchid"
    PresetDkRed => "dkRed"
    PresetDkSalmon => "dkSalmon"
    PresetDkSeaGreen => "dkSeaGreen"
    PresetDkSlateBlue => "dkSlateBlue"
    PresetDkSlateGray => "dkSlateGray"
    PresetDkSlateGrey => "dkSlateGrey"
    PresetDkTurquoise => "dkTurquoise"
    PresetDkViolet => "dkViolet"
    PresetDeepPink => "deepPink"
    PresetDeepSkyBlue => "deepSkyBlue"
    PresetDimGray => "dimGray"
    PresetDimGrey => "dimGrey"
    PresetDodgerBlue => "dodgerBlue"
    PresetFirebrick => "firebrick"
    PresetFloralWhite => "floralWhite"
    PresetForestGreen => "forestGreen"
    PresetFuchsia => "fuchsia"
    PresetGainsboro => "gainsboro"
    PresetGhostWhite => "ghostWhite"
    PresetGold => "gold"
    PresetGoldenrod => "goldenrod"
    PresetGray => "gray"
    PresetGrey => "grey"
    PresetGreen => "green"
    PresetGreenYellow => "greenYellow"
    PresetHoneydew => "honeydew"
    PresetHotPink => "hotPink"
    PresetIndianRed => "indianRed"
    PresetIndigo => "indigo"
    PresetIvory => "ivory"
    PresetKhaki => "khaki"
    PresetLavender => "lavender"
    PresetLavenderBlush => "lavenderBlush"
    PresetLawnGreen => "lawnGreen"
    PresetLemonChiffon => "lemonChiffon"
    PresetLightBlue => "lightBlue"
    PresetLightCoral => "lightCoral"
    PresetLightCyan => "lightCyan"
    PresetLightGoldenrodYellow => "lightGoldenrodYellow"
    PresetLightGray => "lightGray"
    PresetLightGrey => "lightGrey"
    PresetLightGreen => "lightGreen"
    PresetLightPink => "lightPink"
    PresetLightSalmon => "lightSalmon"
    PresetLightSeaGreen => "lightSeaGreen"
    PresetLightSkyBlue => "lightSkyBlue"
    PresetLightSlateGray => "lightSlateGray"
    PresetLightSlateGrey => "lightSlateGrey"
    PresetLightSteelBlue => "lightSteelBlue"
    PresetLightYellow => "lightYellow"
    PresetLtBlue => "ltBlue"
    PresetLtCoral => "ltCoral"
    PresetLtCyan => "ltCyan"
    PresetLtGoldenrodYellow => "ltGoldenrodYellow"
    PresetLtGray => "ltGray"
    PresetLtGrey => "ltGrey"
    PresetLtGreen => "ltGreen"
    PresetLtPink => "ltPink"
    PresetLtSalmon => "ltSalmon"
    PresetLtSeaGreen => "ltSeaGreen"
    PresetLtSkyBlue => "ltSkyBlue"
    PresetLtSlateGray => "ltSlateGray"
    PresetLtSlateGrey => "ltSlateGrey"
    PresetLtSteelBlue => "ltSteelBlue"
    PresetLtYellow => "ltYellow"
    PresetLime => "lime"
    PresetLimeGreen => "limeGreen"
    PresetLinen => "linen"
    PresetMagenta => "magenta"
    PresetMaroon => "maroon"
    PresetMedAquamarine => "medAquamarine"
    PresetMedBlue => "medBlue"
    PresetMedOrchid => "medOrchid"
    PresetMedPurple => "medPurple"
    PresetMedSeaGreen => "medSeaGreen"
    PresetMedSlateBlue => "medSlateBlue"
    PresetMedSpringGreen => "medSpringGreen"
    PresetMedTurquoise => "medTurquoise"
    PresetMedVioletRed => "medVioletRed"
    PresetMediumAquamarine => "mediumAquamarine"
    PresetMediumBlue => "mediumBlue"
    PresetMediumOrchid => "mediumOrchid"
    PresetMediumPurple => "mediumPurple"
    PresetMediumSeaGreen => "mediumSeaGreen"
    PresetMediumSlateBlue => "mediumSlateBlue"
    PresetMediumSpringGreen => "mediumSpringGreen"
    PresetMediumTurquoise => "mediumTurquoise"
    PresetMediumVioletRed => "mediumVioletRed"
    PresetMidnightBlue => "midnightBlue"
    PresetMintCream => "mintCream"
    PresetMistyRose => "mistyRose"
    PresetMoccasin => "moccasin"
    PresetNavajoWhite => "navajoWhite"
    PresetNavy => "navy"
    PresetOldLace => "oldLace"
    PresetOlive => "olive"
    PresetOliveDrab => "oliveDrab"
    PresetOrange => "orange"
    PresetOrangeRed => "orangeRed"
    PresetOrchid => "orchid"
    PresetPaleGoldenrod => "paleGoldenrod"
    PresetPaleGreen => "paleGreen"
    PresetPaleTurquoise => "paleTurquoise"
    PresetPaleVioletRed => "paleVioletRed"
    PresetPapayaWhip => "papayaWhip"
    PresetPeachPuff => "peachPuff"
    PresetPeru => "peru"
    PresetPink => "pink"
    PresetPlum => "plum"
    PresetPowderBlue => "powderBlue"
    PresetPurple => "purple"
    PresetRed => "red"
    PresetRosyBrown => "rosyBrown"
    PresetRoyalBlue => "royalBlue"
    PresetSaddleBrown => "saddleBrown"
    PresetSalmon => "salmon"
    PresetSandyBrown => "sandyBrown"
    PresetSeaGreen => "seaGreen"
    PresetSeaShell => "seaShell"
    PresetSienna => "sienna"
    PresetSilver => "silver"
    PresetSkyBlue => "skyBlue"
    PresetSlateBlue => "slateBlue"
    PresetSlateGray => "slateGray"
    PresetSlateGrey => "slateGrey"
    PresetSnow => "snow"
    PresetSpringGreen => "springGreen"
    PresetSteelBlue => "steelBlue"
    PresetTan => "tan"
    PresetTeal => "teal"
    PresetThistle => "thistle"
    PresetTomato => "tomato"
    PresetTurquoise => "turquoise"
    PresetViolet => "violet"
    PresetWheat => "wheat"
    PresetWhite => "white"
    PresetWhiteSmoke => "whiteSmoke"
    PresetYellow => "yellow"
    PresetYellowGreen => "yellowGreen"
  }
}

///|
fn[T] color_enum_violation(type_name : String) -> T raise SchemaViolation {
  raise SchemaViolation(
    schema="dml-main.xsd",
    path=type_name,
    reason="invalid enumeration value",
  )
}
