///|
/// Schema validation error for ECMA-376 DrawingML color (§20.1.2).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD simple type ST_FontCollectionIndex (§20.1.4).
pub struct ST_FontCollectionIndex {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FontCollectionIndex::parse(
  s : String,
) -> ST_FontCollectionIndex raise SchemaViolation {
  validate_enum("ST_FontCollectionIndex", s, ["major", "minor", "none"])
  { value: s }
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
  self.value
}

///|
/// XSD simple type ST_ColorSchemeIndex (§20.1.2).
pub struct ST_ColorSchemeIndex {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ColorSchemeIndex::parse(
  s : String,
) -> ST_ColorSchemeIndex raise SchemaViolation {
  validate_enum("ST_ColorSchemeIndex", s, [
    "dk1", "lt1", "dk2", "lt2", "accent1", "accent2", "accent3", "accent4", "accent5",
    "accent6", "hlink", "folHlink",
  ])
  { value: s }
}

///|
pub fn ST_ColorSchemeIndex::new(
  s : String,
) -> ST_ColorSchemeIndex raise SchemaViolation {
  ST_ColorSchemeIndex::parse(s)
}

///|
pub fn ST_ColorSchemeIndex::to_string(self : ST_ColorSchemeIndex) -> String {
  self.value
}

///|
/// XSD simple type ST_SystemColorVal (§20.1.2).
pub struct ST_SystemColorVal {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SystemColorVal::parse(
  s : String,
) -> ST_SystemColorVal raise SchemaViolation {
  validate_enum("ST_SystemColorVal", s, [
    "scrollBar", "background", "activeCaption", "inactiveCaption", "menu", "window",
    "windowFrame", "menuText", "windowText", "captionText", "activeBorder", "inactiveBorder",
    "appWorkspace", "highlight", "highlightText", "btnFace", "btnShadow", "grayText",
    "btnText", "inactiveCaptionText", "btnHighlight", "3dDkShadow", "3dLight", "infoText",
    "infoBk", "hotLight", "gradientActiveCaption", "gradientInactiveCaption", "menuHighlight",
    "menuBar",
  ])
  { value: s }
}

///|
pub fn ST_SystemColorVal::new(
  s : String,
) -> ST_SystemColorVal raise SchemaViolation {
  ST_SystemColorVal::parse(s)
}

///|
pub fn ST_SystemColorVal::to_string(self : ST_SystemColorVal) -> String {
  self.value
}

///|
/// XSD simple type ST_SchemeColorVal (§20.1.2).
pub struct ST_SchemeColorVal {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SchemeColorVal::parse(
  s : String,
) -> ST_SchemeColorVal raise SchemaViolation {
  validate_enum("ST_SchemeColorVal", s, [
    "bg1", "tx1", "bg2", "tx2", "accent1", "accent2", "accent3", "accent4", "accent5",
    "accent6", "hlink", "folHlink", "phClr", "dk1", "lt1", "dk2", "lt2",
  ])
  { value: s }
}

///|
pub fn ST_SchemeColorVal::new(
  s : String,
) -> ST_SchemeColorVal raise SchemaViolation {
  ST_SchemeColorVal::parse(s)
}

///|
pub fn ST_SchemeColorVal::to_string(self : ST_SchemeColorVal) -> String {
  self.value
}

///|
/// XSD simple type ST_PresetColorVal (§20.1.2).
pub struct ST_PresetColorVal {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PresetColorVal::parse(
  s : String,
) -> ST_PresetColorVal raise SchemaViolation {
  validate_enum("ST_PresetColorVal", s, [
    "aliceBlue", "antiqueWhite", "aqua", "aquamarine", "azure", "beige", "bisque",
    "black", "blanchedAlmond", "blue", "blueViolet", "brown", "burlyWood", "cadetBlue",
    "chartreuse", "chocolate", "coral", "cornflowerBlue", "cornsilk", "crimson",
    "cyan", "darkBlue", "darkCyan", "darkGoldenrod", "darkGray", "darkGrey", "darkGreen",
    "darkKhaki", "darkMagenta", "darkOliveGreen", "darkOrange", "darkOrchid", "darkRed",
    "darkSalmon", "darkSeaGreen", "darkSlateBlue", "darkSlateGray", "darkSlateGrey",
    "darkTurquoise", "darkViolet", "dkBlue", "dkCyan", "dkGoldenrod", "dkGray", "dkGrey",
    "dkGreen", "dkKhaki", "dkMagenta", "dkOliveGreen", "dkOrange", "dkOrchid", "dkRed",
    "dkSalmon", "dkSeaGreen", "dkSlateBlue", "dkSlateGray", "dkSlateGrey", "dkTurquoise",
    "dkViolet", "deepPink", "deepSkyBlue", "dimGray", "dimGrey", "dodgerBlue", "firebrick",
    "floralWhite", "forestGreen", "fuchsia", "gainsboro", "ghostWhite", "gold", "goldenrod",
    "gray", "grey", "green", "greenYellow", "honeydew", "hotPink", "indianRed", "indigo",
    "ivory", "khaki", "lavender", "lavenderBlush", "lawnGreen", "lemonChiffon", "lightBlue",
    "lightCoral", "lightCyan", "lightGoldenrodYellow", "lightGray", "lightGrey",
    "lightGreen", "lightPink", "lightSalmon", "lightSeaGreen", "lightSkyBlue", "lightSlateGray",
    "lightSlateGrey", "lightSteelBlue", "lightYellow", "ltBlue", "ltCoral", "ltCyan",
    "ltGoldenrodYellow", "ltGray", "ltGrey", "ltGreen", "ltPink", "ltSalmon", "ltSeaGreen",
    "ltSkyBlue", "ltSlateGray", "ltSlateGrey", "ltSteelBlue", "ltYellow", "lime",
    "limeGreen", "linen", "magenta", "maroon", "medAquamarine", "medBlue", "medOrchid",
    "medPurple", "medSeaGreen", "medSlateBlue", "medSpringGreen", "medTurquoise",
    "medVioletRed", "mediumAquamarine", "mediumBlue", "mediumOrchid", "mediumPurple",
    "mediumSeaGreen", "mediumSlateBlue", "mediumSpringGreen", "mediumTurquoise",
    "mediumVioletRed", "midnightBlue", "mintCream", "mistyRose", "moccasin", "navajoWhite",
    "navy", "oldLace", "olive", "oliveDrab", "orange", "orangeRed", "orchid", "paleGoldenrod",
    "paleGreen", "paleTurquoise", "paleVioletRed", "papayaWhip", "peachPuff", "peru",
    "pink", "plum", "powderBlue", "purple", "red", "rosyBrown", "royalBlue", "saddleBrown",
    "salmon", "sandyBrown", "seaGreen", "seaShell", "sienna", "silver", "skyBlue",
    "slateBlue", "slateGray", "slateGrey", "snow", "springGreen", "steelBlue", "tan",
    "teal", "thistle", "tomato", "turquoise", "violet", "wheat", "white", "whiteSmoke",
    "yellow", "yellowGreen",
  ])
  { value: s }
}

///|
pub fn ST_PresetColorVal::new(
  s : String,
) -> ST_PresetColorVal raise SchemaViolation {
  ST_PresetColorVal::parse(s)
}

///|
pub fn ST_PresetColorVal::to_string(self : ST_PresetColorVal) -> String {
  self.value
}

///|
fn validate_enum(
  type_name : String,
  value : String,
  allowed : Array[String],
) -> Unit raise SchemaViolation {
  let mut found = false
  for item in allowed {
    found = found || item == value
  }
  if !found {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path=type_name,
      reason="invalid enumeration value",
    )
  }
}
