///|
/// Schema validation error for ECMA-376 DrawingML Main (§20.1).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="unexpected element name",
    )
  }
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}

///|
fn read_main_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name, local_name)
  validate_main_element(root)
  root
}

///|
fn validate_main_element(element : @xml.Element) -> Unit raise SchemaViolation {
  validate_main_attributes(element)
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      validate_main_element(child_element)
    }
  }
}

///|
fn validate_main_attributes(
  element : @xml.Element,
) -> Unit raise SchemaViolation {
  for attribute in element.attributes {
    let name = attribute.name.local_name
    let value = attribute.value
    match (element.name.local_name, name) {
      ("sysClr", "val") => ST_SystemColorVal::parse(value) |> ignore
      ("schemeClr", "val") => ST_SchemeColorVal::parse(value) |> ignore
      ("prstClr", "val") => ST_PresetColorVal::parse(value) |> ignore
      ("gradFill", "flip") | ("tile", "flip") =>
        ST_TileFlipMode::parse(value) |> ignore
      ("tile", "algn") => ST_RectAlignment::parse(value) |> ignore
      ("path", "path") => ST_PathShadeType::parse(value) |> ignore
      ("pattFill", "prst") => ST_PresetPatternVal::parse(value) |> ignore
      ("ln", "cap") => ST_LineCap::parse(value) |> ignore
      ("ln", "cmpd") => ST_CompoundLine::parse(value) |> ignore
      ("ln", "algn") => ST_PenAlignment::parse(value) |> ignore
      ("headEnd", "type") | ("tailEnd", "type") =>
        ST_LineEndType::parse(value) |> ignore
      ("headEnd", "w") | ("tailEnd", "w") =>
        ST_LineEndWidth::parse(value) |> ignore
      ("headEnd", "len") | ("tailEnd", "len") =>
        ST_LineEndLength::parse(value) |> ignore
      ("prstDash", "val") => ST_PresetLineDashVal::parse(value) |> ignore
      ("bodyPr", "anchor") => ST_TextAnchoringType::parse(value) |> ignore
      ("bodyPr", "vertOverflow") =>
        ST_TextVertOverflowType::parse(value) |> ignore
      ("bodyPr", "horzOverflow") =>
        ST_TextHorzOverflowType::parse(value) |> ignore
      ("bodyPr", "vert") => ST_TextVerticalType::parse(value) |> ignore
      ("bodyPr", "wrap") => ST_TextWrappingType::parse(value) |> ignore
      ("bodyPr", "numCol") => ST_TextColumnCount::parse(value) |> ignore
      ("normAutofit", "fontScale") =>
        ST_TextFontScalePercentOrPercentString::parse(value) |> ignore
      ("normAutofit", "lnSpcReduction") =>
        ST_TextSpacingPercentOrPercentString::parse(value) |> ignore
      ("prstTxWarp", "prst") => ST_TextShapeType::parse(value) |> ignore
      ("buAutoNum", "type") => ST_TextAutonumberScheme::parse(value) |> ignore
      ("buAutoNum", "startAt") =>
        ST_TextBulletStartAtNum::parse(value) |> ignore
      ("buSzPct", "val") => ST_TextBulletSizePercent::parse(value) |> ignore
      ("buSzPts", "val") => ST_TextPoint::parse(value) |> ignore
      ("spcPct", "val") =>
        ST_TextSpacingPercentOrPercentString::parse(value) |> ignore
      ("spcPts", "val") => ST_TextSpacingPoint::parse(value) |> ignore
      ("tab", "algn") => ST_TextTabAlignType::parse(value) |> ignore
      ("tab", "pos") => ST_TextPointUnqualified::parse(value) |> ignore
      ("pPr", "algn") => ST_TextAlignType::parse(value) |> ignore
      ("pPr", "fontAlgn") => ST_TextFontAlignType::parse(value) |> ignore
      ("pPr", "lvl") => ST_TextIndentLevelType::parse(value) |> ignore
      ("pPr", "marL") | ("pPr", "marR") | ("pPr", "defTabSz") =>
        ST_TextMargin::parse(value) |> ignore
      ("pPr", "indent") => ST_TextIndent::parse(value) |> ignore
      ("rPr", "sz") | ("endParaRPr", "sz") =>
        ST_TextFontSize::parse(value) |> ignore
      ("rPr", "u") | ("endParaRPr", "u") =>
        ST_TextUnderlineType::parse(value) |> ignore
      ("rPr", "strike") | ("endParaRPr", "strike") =>
        ST_TextStrikeType::parse(value) |> ignore
      ("rPr", "cap") | ("endParaRPr", "cap") =>
        ST_TextCapsType::parse(value) |> ignore
      ("clrMap", "bg1")
      | ("clrMap", "tx1")
      | ("clrMap", "bg2")
      | ("clrMap", "tx2")
      | ("clrMap", "accent1")
      | ("clrMap", "accent2")
      | ("clrMap", "accent3")
      | ("clrMap", "accent4")
      | ("clrMap", "accent5")
      | ("clrMap", "accent6")
      | ("clrMap", "hlink")
      | ("clrMap", "folHlink") => ST_ColorSchemeIndex::parse(value) |> ignore
      (_, "x")
      | (_, "y")
      | (_, "cx")
      | (_, "cy")
      | (_, "chOff")
      | (_, "chExt")
      | (_, "w")
      | (_, "h")
      | (_, "l")
      | (_, "t")
      | (_, "r")
      | (_, "g")
      | (_, "b")
      | (_, "rad")
      | (_, "dist")
      | (_, "blurRad")
      | (_, "sx")
      | (_, "sy")
      | (_, "kx")
      | (_, "ky")
      | (_, "amt")
      | (_, "pos")
      | (_, "algn")
      | (_, "rot")
      | (_, "lat")
      | (_, "lon")
      | (_, "rev")
      | (_, "ang")
      | (_, "idx")
      | (_, "fmla")
      | (_, "prst")
      | (_, "path")
      | (_, "fill")
      | (_, "val")
      | (_, "lastClr")
      | (_, "hue")
      | (_, "sat")
      | (_, "lum")
      | (_, "useA")
      | (_, "name") => validate_non_empty_attr(name, value)
      (_, "typeface") => ST_TextTypeface::parse(value) |> ignore
      (_, "pitchFamily") => ST_PitchFamily::parse(value) |> ignore
      (_, "charset") | (_, "panose") | (_, "script") | (_, "uri") =>
        validate_non_empty_attr(name, value)
      _ => ()
    }
  }
}

///|
fn validate_non_empty_attr(
  path : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="empty attribute value",
    )
  }
}
