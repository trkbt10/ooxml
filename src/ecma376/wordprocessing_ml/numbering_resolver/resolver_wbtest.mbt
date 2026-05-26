///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parse_root(source : String) -> @xml.Element {
  try! @xml.parse(bytes(source)).root
}

///|
fn sample_numbering() -> @domain.CT_Numbering raise {
  let xml = "<numbering>" +
    "<abstractNum abstractNumId=\"0\"><multiLevelType val=\"multilevel\"/>" +
    "<lvl ilvl=\"0\"><start val=\"1\"/><numFmt val=\"decimal\"/><lvlText val=\"%1.\"/></lvl>" +
    "<lvl ilvl=\"1\"><start val=\"1\"/><numFmt val=\"lowerLetter\"/><lvlText val=\"%2)\"/></lvl>" +
    "</abstractNum>" +
    "<abstractNum abstractNumId=\"7\"><styleLink val=\"List7\"/>" +
    "<lvl ilvl=\"0\"><start val=\"5\"/><numFmt val=\"upperRoman\"/><lvlText val=\"%1.\"/></lvl>" +
    "</abstractNum>" +
    "<abstractNum abstractNumId=\"8\"><numStyleLink val=\"List7\"/></abstractNum>" +
    "<num numId=\"1\"><abstractNumId val=\"0\"/></num>" +
    "<num numId=\"2\"><abstractNumId val=\"0\"/>" +
    "<lvlOverride ilvl=\"0\"><lvl ilvl=\"0\"><start val=\"4\"/><numFmt val=\"decimal\"/><lvlText val=\"%1)\"/></lvl></lvlOverride>" +
    "<lvlOverride ilvl=\"1\"><startOverride val=\"10\"/></lvlOverride>" +
    "</num>" +
    "<num numId=\"3\"><abstractNumId val=\"8\"/></num>" +
    "</numbering>"
  @domain.CT_Numbering::parse(parse_root(xml))
}

///|
test "§17.9.6 CT_Lvl::parse populates every typed field" {
  let lvl_xml = "<lvl ilvl=\"2\"><start val=\"3\"/><numFmt val=\"upperRoman\"/>" +
    "<lvlText val=\"%3.\"/><lvlJc val=\"end\"/><lvlRestart val=\"1\"/>" +
    "<pStyle val=\"H3\"/><suff val=\"space\"/><isLgl/>" +
    "<lvlPicBulletId val=\"7\"/>" +
    "<pPr><ind start=\"720\"/></pPr><rPr><b/></rPr></lvl>"
  let lvl = try! @domain.CT_Lvl::parse(parse_root(lvl_xml))
  @debug.assert_eq(lvl.ilvl, 2)
  @debug.assert_eq(lvl.start, Some(3))
  assert_true(lvl.num_fmt == Some(@domain.NumFmtUpperRoman))
  @debug.assert_eq(lvl.lvl_text, Some("%3."))
  assert_true(lvl.lvl_jc == Some(@domain.JcEnd))
  @debug.assert_eq(lvl.lvl_restart, Some(1))
  @debug.assert_eq(lvl.p_style, Some("H3"))
  assert_true(lvl.suff == Some(@domain.LevelSuffixSpace))
  assert_true(lvl.is_lgl)
  @debug.assert_eq(lvl.lvl_pic_bullet_id, Some(7))
  assert_true(lvl.p_pr_element is Some(_))
  assert_true(lvl.r_pr_element is Some(_))
  assert_true(lvl.has_pic_bullet())
}

///|
test "§17.9.15 CT_Num::parse via CT_Numbering reads abstractNumId + overrides" {
  let table = try! sample_numbering()
  let num2 = table.nums.get(2).unwrap()
  @debug.assert_eq(num2.abstract_num_id, 0)
  @debug.assert_eq(num2.lvl_overrides.length(), 2)
  let ovr0 = num2.lvl_overrides[0]
  @debug.assert_eq(ovr0.ilvl, 0)
  assert_true(ovr0.lvl is Some(_))
  let ovr1 = num2.lvl_overrides[1]
  @debug.assert_eq(ovr1.ilvl, 1)
  @debug.assert_eq(ovr1.start_override, Some(10))
}

///|
test "§17.9 resolve_level reads abstractNum directly" {
  let table = try! sample_numbering()
  let resolved = resolve_level(table, 1, 0).unwrap()
  @debug.assert_eq(resolved.lvl.ilvl, 0)
  assert_true(resolved.origin == SourceAbstract)
  assert_true(resolved.lvl.num_fmt == Some(@domain.NumFmtDecimal))
}

///|
test "§17.9.8 lvlOverride wins over abstract" {
  let table = try! sample_numbering()
  let resolved = resolve_level(table, 2, 0).unwrap()
  assert_true(resolved.origin == SourceOverride)
  @debug.assert_eq(resolved.lvl.start, Some(4))
  @debug.assert_eq(resolved.lvl.lvl_text, Some("%1)"))
}

///|
test "§17.9.8 startOverride re-uses abstract lvl with new start" {
  let table = try! sample_numbering()
  let resolved = resolve_level(table, 2, 1).unwrap()
  assert_true(resolved.origin == SourceOverride)
  @debug.assert_eq(resolved.lvl.start, Some(10))
  assert_true(resolved.lvl.num_fmt == Some(@domain.NumFmtLowerLetter))
}

///|
test "§17.9.21 numStyleLink resolves through styleLink" {
  let table = try! sample_numbering()
  let resolved = resolve_level(table, 3, 0).unwrap()
  assert_true(resolved.origin == SourceLinkedAbstract)
  assert_true(resolved.lvl.num_fmt == Some(@domain.NumFmtUpperRoman))
  @debug.assert_eq(resolved.lvl.start, Some(5))
}

///|
test "§17.18.59 ST_NumberFormat::format covers decimal / roman / letter / ordinal" {
  @debug.assert_eq(@domain.NumFmtDecimal.format(7), "7")
  @debug.assert_eq(@domain.NumFmtDecimalZero.format(7), "07")
  @debug.assert_eq(@domain.NumFmtDecimalZero.format(15), "15")
  @debug.assert_eq(@domain.NumFmtUpperRoman.format(4), "IV")
  @debug.assert_eq(@domain.NumFmtLowerRoman.format(9), "ix")
  @debug.assert_eq(@domain.NumFmtUpperLetter.format(1), "A")
  @debug.assert_eq(@domain.NumFmtUpperLetter.format(27), "AA")
  @debug.assert_eq(@domain.NumFmtLowerLetter.format(28), "ab")
  @debug.assert_eq(@domain.NumFmtOrdinal.format(1), "1st")
  @debug.assert_eq(@domain.NumFmtOrdinal.format(11), "11th")
  @debug.assert_eq(@domain.NumFmtOrdinal.format(22), "22nd")
  @debug.assert_eq(@domain.NumFmtCardinalText.format(3), "Three")
  @debug.assert_eq(@domain.NumFmtOrdinalText.format(3), "Third")
  @debug.assert_eq(@domain.NumFmtBullet.format(7), "")
  @debug.assert_eq(@domain.NumFmtNone.format(7), "")
}

///|
test "§17.9.11 format_lvl_text substitutes %N placeholders" {
  let counters = [3, 5]
  let formats : Array[@domain.ST_NumberFormat] = [
    @domain.NumFmtDecimal,
    @domain.NumFmtDecimal,
  ]
  @debug.assert_eq(format_lvl_text("%1.%2.", counters, formats), "3.5.")
  @debug.assert_eq(format_lvl_text("%1)", counters, formats), "3)")
  @debug.assert_eq(
    format_lvl_text("%%1 is literal", counters, formats),
    "%1 is literal",
  )
  // Roman + letter
  let formats2 : Array[@domain.ST_NumberFormat] = [
    @domain.NumFmtUpperRoman,
    @domain.NumFmtLowerLetter,
  ]
  @debug.assert_eq(format_lvl_text("%1.%2", [4, 2], formats2), "IV.b")
  // Out-of-range level index leaves zero counter
  let fallback_formats : Array[@domain.ST_NumberFormat] = [
    @domain.NumFmtDecimal,
  ]
  @debug.assert_eq(format_lvl_text("%9", [1], fallback_formats), "0")
}

///|
test "§17.9 level_for_paragraph reads numId + ilvl" {
  let table = try! sample_numbering()
  let num_pr_element = parse_root(
    "<numPr><ilvl val=\"1\"/><numId val=\"2\"/></numPr>",
  )
  let resolved = level_for_paragraph(table, num_pr_element).unwrap()
  @debug.assert_eq(resolved.lvl.ilvl, 1)
  assert_true(resolved.origin == SourceOverride)
}

///|
test "§17.9 numbering_part1_17_9_section_name citation" {
  @debug.assert_eq(numbering_part1_17_9_section_name(), "Part 1 §17.9")
}

///|
/// §17.9.21 — chain of numStyleLinks of length 2.  abstract 9 links
/// to style "ListA" → abstract 10 (no concrete lvl, links to "ListB")
/// → abstract 11 (concrete lvl, decimal "%1)").  The resolver MUST
/// walk both hops and return the lvl from abstract 11.
test "§17.9.21 numStyleLink follows chain of length 2" {
  let xml = "<numbering>" +
    "<abstractNum abstractNumId=\"9\"><numStyleLink val=\"ListA\"/></abstractNum>" +
    "<abstractNum abstractNumId=\"10\"><styleLink val=\"ListA\"/>" +
    "<numStyleLink val=\"ListB\"/></abstractNum>" +
    "<abstractNum abstractNumId=\"11\"><styleLink val=\"ListB\"/>" +
    "<lvl ilvl=\"0\"><start val=\"3\"/><numFmt val=\"decimal\"/><lvlText val=\"%1)\"/></lvl>" +
    "</abstractNum>" +
    "<num numId=\"9\"><abstractNumId val=\"9\"/></num>" +
    "</numbering>"
  let table = try! @domain.CT_Numbering::parse(parse_root(xml))
  let resolved = resolve_level(table, 9, 0).unwrap()
  assert_true(resolved.origin == SourceLinkedAbstract)
  assert_true(resolved.lvl.num_fmt == Some(@domain.NumFmtDecimal))
  @debug.assert_eq(resolved.lvl.start, Some(3))
}

///|
/// §17.9.21 — cyclic numStyleLink chain (abstract A ↔ abstract B).
/// The resolver MUST detect the cycle and return None rather than
/// looping forever.
test "§17.9.21 numStyleLink cycle terminates with None" {
  let xml = "<numbering>" +
    "<abstractNum abstractNumId=\"20\"><styleLink val=\"X\"/>" +
    "<numStyleLink val=\"Y\"/></abstractNum>" +
    "<abstractNum abstractNumId=\"21\"><styleLink val=\"Y\"/>" +
    "<numStyleLink val=\"X\"/></abstractNum>" +
    "<num numId=\"20\"><abstractNumId val=\"20\"/></num>" +
    "</numbering>"
  let table = try! @domain.CT_Numbering::parse(parse_root(xml))
  let resolved = resolve_level(table, 20, 0)
  assert_true(resolved is None)
}
