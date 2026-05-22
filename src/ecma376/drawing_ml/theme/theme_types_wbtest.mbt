///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
///|
/// Build a minimal §20.1.6 theme fixture that satisfies every
/// required CT_BaseStyles / CT_ColorScheme / CT_FontScheme /
/// CT_StyleMatrix sub-tree. The shape is:
///   theme
///     themeElements
///       clrScheme name="x" (12 srgbClr children)
///       fontScheme name="x" majorFont minorFont
///       fmtScheme fillStyleLst (>=3) lnStyleLst (>=3) effectStyleLst (>=3) bgFillStyleLst (>=3)
fn minimal_theme_xml() -> String {
  let prefix = "<a:theme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:themeElements>"
  let clr = "<a:clrScheme name=\"Office\">" +
    "<a:dk1><a:srgbClr val=\"000000\"/></a:dk1>" +
    "<a:lt1><a:srgbClr val=\"FFFFFF\"/></a:lt1>" +
    "<a:dk2><a:srgbClr val=\"000000\"/></a:dk2>" +
    "<a:lt2><a:srgbClr val=\"FFFFFF\"/></a:lt2>" +
    "<a:accent1><a:srgbClr val=\"FF0000\"/></a:accent1>" +
    "<a:accent2><a:srgbClr val=\"00FF00\"/></a:accent2>" +
    "<a:accent3><a:srgbClr val=\"0000FF\"/></a:accent3>" +
    "<a:accent4><a:srgbClr val=\"FFFF00\"/></a:accent4>" +
    "<a:accent5><a:srgbClr val=\"FF00FF\"/></a:accent5>" +
    "<a:accent6><a:srgbClr val=\"00FFFF\"/></a:accent6>" +
    "<a:hlink><a:srgbClr val=\"0000EE\"/></a:hlink>" +
    "<a:folHlink><a:srgbClr val=\"551A8B\"/></a:folHlink>" +
    "</a:clrScheme>"
  let font = "<a:fontScheme name=\"Office\">" +
    "<a:majorFont><a:latin typeface=\"Calibri\"/><a:ea typeface=\"-\"/><a:cs typeface=\"-\"/></a:majorFont>" +
    "<a:minorFont><a:latin typeface=\"Calibri\"/><a:ea typeface=\"-\"/><a:cs typeface=\"-\"/></a:minorFont>" +
    "</a:fontScheme>"
  let fmt = "<a:fmtScheme name=\"Office\">" +
    "<a:fillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:fillStyleLst>" +
    "<a:lnStyleLst><a:ln/><a:ln/><a:ln/></a:lnStyleLst>" +
    "<a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst>" +
    "<a:bgFillStyleLst><a:noFill/><a:noFill/><a:noFill/></a:bgFillStyleLst>" +
    "</a:fmtScheme>"
  prefix + clr + font + fmt + "</a:themeElements></a:theme>"
}

///|
test "round-trip DrawingML theme" {
  let v = read_theme(bytes(minimal_theme_xml()))
  assert_eq(v.element.name.local_name, "theme")
  // Verify the typed projection actually walks down into the spec —
  // a meaningful round-trip needs the typed sub-trees to be present.
  assert_eq(v.theme_elements.clr_scheme.element.name.local_name, "clrScheme")
  assert_eq(v.theme_elements.font_scheme.element.name.local_name, "fontScheme")
  assert_eq(v.theme_elements.fmt_scheme.element.name.local_name, "fmtScheme")
  let reparsed = read_theme(write_theme(v))
  assert_eq(reparsed.element.name.local_name, "theme")
}

///|
test "round-trip DrawingML theme override" {
  // CT_BaseStylesOverride: all three sub-elements are optional, so an
  // empty themeOverride is schema-valid.
  let value = read_theme_override(
    bytes(
      "<a:themeOverride xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "themeOverride")
  let reparsed = read_theme_override(write_theme_override(value))
  assert_eq(reparsed.element.name.local_name, "themeOverride")
}

///|
test "round-trip DrawingML theme manager" {
  let value = read_theme_manager(
    bytes(
      "<a:themeManager xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "themeManager")
  let reparsed = read_theme_manager(write_theme_manager(value))
  assert_eq(reparsed.element.name.local_name, "themeManager")
}
