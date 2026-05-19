///|
/// SpreadsheetML style types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn style_type_group_name() -> String {
  "spreadsheet_ml.style"
}

///|
/// XSD complex type CT_SheetProtection.
pub(all) struct CT_SheetProtection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SheetProtection::new(element : @xml.Element) -> CT_SheetProtection {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ChartsheetProtection.
pub(all) struct CT_ChartsheetProtection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ChartsheetProtection::new(
  element : @xml.Element,
) -> CT_ChartsheetProtection {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Stylesheet.
pub(all) struct CT_Stylesheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Stylesheet::new(element : @xml.Element) -> CT_Stylesheet {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellAlignment.
pub(all) struct CT_CellAlignment {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellAlignment::new(element : @xml.Element) -> CT_CellAlignment {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Borders.
pub(all) struct CT_Borders {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Borders::new(element : @xml.Element) -> CT_Borders {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Border: style border with start, end, top, bottom, diagonal, vertical, horizontal edges and diagonalUp, diagonalDown, outline attributes.
pub(all) struct CT_Border {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Border::new(element : @xml.Element) -> CT_Border {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_BorderPr.
pub(all) struct CT_BorderPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BorderPr::new(element : @xml.Element) -> CT_BorderPr {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellProtection.
pub(all) struct CT_CellProtection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellProtection::new(element : @xml.Element) -> CT_CellProtection {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Fonts.
pub(all) struct CT_Fonts {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Fonts::new(element : @xml.Element) -> CT_Fonts {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Fills.
pub(all) struct CT_Fills {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Fills::new(element : @xml.Element) -> CT_Fills {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Fill.
pub(all) struct CT_Fill {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Fill::new(element : @xml.Element) -> CT_Fill {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PatternFill.
pub(all) struct CT_PatternFill {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PatternFill::new(element : @xml.Element) -> CT_PatternFill {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_GradientFill.
pub(all) struct CT_GradientFill {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GradientFill::new(element : @xml.Element) -> CT_GradientFill {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_NumFmts.
pub(all) struct CT_NumFmts {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NumFmts::new(element : @xml.Element) -> CT_NumFmts {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_NumFmt.
pub(all) struct CT_NumFmt {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NumFmt::new(element : @xml.Element) -> CT_NumFmt {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellStyleXfs.
pub(all) struct CT_CellStyleXfs {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellStyleXfs::new(element : @xml.Element) -> CT_CellStyleXfs {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellXfs.
pub(all) struct CT_CellXfs {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellXfs::new(element : @xml.Element) -> CT_CellXfs {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Xf: cell format with alignment, protection, extLst children and numFmtId, fontId, fillId, borderId, xfId, apply* attributes.
pub(all) struct CT_Xf {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Xf::new(element : @xml.Element) -> CT_Xf {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellStyles.
pub(all) struct CT_CellStyles {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellStyles::new(element : @xml.Element) -> CT_CellStyles {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CellStyle.
pub(all) struct CT_CellStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellStyle::new(element : @xml.Element) -> CT_CellStyle {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Dxfs: Schema sml.xsd complex type `CT_Dxfs` has
/// attribute `count` and `dxf` children of type CT_Dxf; CT_Dxfs and
/// CT_Dxfs::new own that differential-format collection.
pub(all) struct CT_Dxfs {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Dxfs::new(element : @xml.Element) -> CT_Dxfs {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Dxf: differential format with font, numFmt, fill, alignment, border, protection, extLst children.
pub(all) struct CT_Dxf {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Dxf::new(element : @xml.Element) -> CT_Dxf {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Colors.
pub(all) struct CT_Colors {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Colors::new(element : @xml.Element) -> CT_Colors {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_IndexedColors.
pub(all) struct CT_IndexedColors {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_IndexedColors::new(element : @xml.Element) -> CT_IndexedColors {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MRUColors.
pub(all) struct CT_MRUColors {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MRUColors::new(element : @xml.Element) -> CT_MRUColors {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RgbColor.
pub(all) struct CT_RgbColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RgbColor::new(element : @xml.Element) -> CT_RgbColor {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableStyles.
pub(all) struct CT_TableStyles {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyles::new(element : @xml.Element) -> CT_TableStyles {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableStyle.
pub(all) struct CT_TableStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyle::new(element : @xml.Element) -> CT_TableStyle {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableStyleElement.
pub(all) struct CT_TableStyleElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyleElement::new(
  element : @xml.Element,
) -> CT_TableStyleElement {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_BooleanProperty.
pub(all) struct CT_BooleanProperty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BooleanProperty::new(element : @xml.Element) -> CT_BooleanProperty {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FontSize.
pub(all) struct CT_FontSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontSize::new(element : @xml.Element) -> CT_FontSize {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_IntProperty.
pub(all) struct CT_IntProperty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_IntProperty::new(element : @xml.Element) -> CT_IntProperty {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FontName.
pub(all) struct CT_FontName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontName::new(element : @xml.Element) -> CT_FontName {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_VerticalAlignFontProperty.
pub(all) struct CT_VerticalAlignFontProperty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VerticalAlignFontProperty::new(
  element : @xml.Element,
) -> CT_VerticalAlignFontProperty {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FontScheme.
pub(all) struct CT_FontScheme {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontScheme::new(element : @xml.Element) -> CT_FontScheme {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_UnderlineProperty.
pub(all) struct CT_UnderlineProperty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_UnderlineProperty::new(
  element : @xml.Element,
) -> CT_UnderlineProperty {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_FontFamily.
pub(all) struct CT_FontFamily {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FontFamily::new(element : @xml.Element) -> CT_FontFamily {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Font: stylesheet font with name, charset, family, bold, italic, strike, color, size, underline, vertical alignment, scheme children.
pub(all) struct CT_Font {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Font::new(element : @xml.Element) -> CT_Font {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TableStyleInfo.
pub(all) struct CT_TableStyleInfo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyleInfo::new(element : @xml.Element) -> CT_TableStyleInfo {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_WorkbookProtection.
pub(all) struct CT_WorkbookProtection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WorkbookProtection::new(
  element : @xml.Element,
) -> CT_WorkbookProtection {
  let group_name = style_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}
