///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parse_root(source : String) -> @xml.Element {
  try! @xml.parse(bytes(source)).root
}

///|
fn sample_date() -> @date_serial.CalendarDateTime {
  {
    year: 2026,
    month: 5,
    day: 19,
    hour: 14,
    minute: 30,
    second: 45,
    millisecond: 0,
  }
}

///|
fn ctx_with(mutate : (FieldContext) -> FieldContext) -> FieldContext {
  let base = FieldContext::default(sample_date())
  mutate(base)
}

///|
test "§17.16.1 tokenizer splits words / quoted / switches" {
  let tokens = try! tokenize_instruction("DATE \\@ \"yyyy-MM-dd\"")
  assert_eq(tokens.length(), 3)
  assert_true(tokens[0] == TWord("DATE"))
  assert_true(tokens[1] == TSwitch('@'))
  assert_true(tokens[2] == TQuoted("yyyy-MM-dd"))
}

///|
test "§17.16.1 tokenizer handles escaped quotes inside literal" {
  let tokens = try! tokenize_instruction("REF \"a\\\"b\"")
  assert_eq(tokens.length(), 2)
  assert_true(tokens[1] == TQuoted("a\"b"))
}

///|
test "§17.16.1 tokenizer raises on unterminated quote" {
  let bad = try? tokenize_instruction("REF \"unterminated")
  assert_true(bad is Err(_))
}

///|
test "§17.16.1 parse_instruction discriminates field type and switches" {
  let field = try! parse_instruction("DATE \\@ \"yyyy-MM-dd\" \\* MERGEFORMAT")
  assert_true(field.instruction == Date)
  assert_eq(field.arguments.length(), 0)
  assert_eq(field.switches.length(), 2)
  assert_eq(field.switches[0].flag, '@')
  assert_eq(field.switches[0].argument, Some("yyyy-MM-dd"))
  assert_eq(field.switches[1].flag, '*')
  assert_eq(field.switches[1].argument, Some("MERGEFORMAT"))
}

///|
test "§17.16.1 user-defined and unknown instruction discrimination" {
  let userdef = try! parse_instruction("MYCUSTOM arg")
  assert_true(userdef.instruction == UserDefined("MYCUSTOM"))
  let unknown = try! parse_instruction("X1Y2")
  assert_true(unknown.instruction == Unknown("X1Y2"))
}

///|
test "§17.16.2 decode_simple_field reads w:fldSimple/@instr" {
  let element = parse_root("<fldSimple instr=\"PAGE\"/>")
  let field = try! decode_simple_field(@domain.CT_SimpleField::new(element))
  assert_true(field.instruction == Page)
}

///|
test "§17.16.2 decode_field_run_sequence walks begin/separate/end" {
  // Three runs: begin, instrText, separate + cached, end.
  let runs : Array[@domain.CT_R] = [
    try! @domain.CT_R::new(parse_root("<r><fldChar fldCharType=\"begin\"/></r>")),
    try! @domain.CT_R::new(parse_root("<r><instrText>NUMPAGES \\* Arabic</instrText></r>")),
    try! @domain.CT_R::new(parse_root("<r><fldChar fldCharType=\"separate\"/></r>")),
    try! @domain.CT_R::new(parse_root("<r><t>42</t></r>")),
    try! @domain.CT_R::new(parse_root("<r><fldChar fldCharType=\"end\"/></r>")),
  ]
  let decoded = try! decode_field_run_sequence(runs)
  assert_eq(decoded.length(), 1)
  assert_true(decoded[0].field.instruction == NumPages)
  assert_eq(decoded[0].cached_runs.length(), 1)
}

///|
test "§17.16.5.51 PAGE evaluator returns current_page" {
  let registry = FieldRegistry::with_builtins()
  let field = try! parse_instruction("PAGE")
  let ctx = ctx_with(fn(c) { { ..c, current_page: 7, total_pages: 12 } })
  let result = evaluate_field(field, ctx, registry)
  assert_eq(result.to_text(), "7")
}

///|
test "§17.16.5.50 NUMPAGES via \\* Roman switch renders roman" {
  let registry = FieldRegistry::with_builtins()
  let field = try! parse_instruction("NUMPAGES \\* Roman")
  let ctx = ctx_with(fn(c) { { ..c, total_pages: 14 } })
  let result = evaluate_field(field, ctx, registry)
  assert_eq(result.to_text(), "XIV")
}

///|
test "§17.16.5.13 DATE uses \\@ template" {
  let registry = FieldRegistry::with_builtins()
  let field = try! parse_instruction("DATE \\@ \"yyyy-MM-dd\"")
  let ctx = ctx_with(fn(c) { c })
  let result = evaluate_field(field, ctx, registry)
  assert_eq(result.to_text(), "2026-05-19")
}

///|
test "§17.16.4.1 format_date_time covers yyyy/MM/dd/HH/mm/ampm/literals" {
  let date = sample_date()
  assert_eq(format_date_time("yyyy", date), "2026")
  assert_eq(format_date_time("yy", date), "26")
  assert_eq(format_date_time("MMMM", date), "May")
  assert_eq(format_date_time("MMM", date), "May")
  assert_eq(format_date_time("MM", date), "05")
  assert_eq(format_date_time("M", date), "5")
  assert_eq(format_date_time("dd", date), "19")
  assert_eq(format_date_time("d", date), "19")
  assert_eq(format_date_time("HH:mm:ss", date), "14:30:45")
  assert_eq(format_date_time("h:mm am/pm", date), "2:30 pm")
  assert_eq(format_date_time("h:mm AM/PM", date), "2:30 PM")
  assert_eq(format_date_time("'on' yyyy", date), "on 2026")
  // Weekday: 2026-05-19 is a Tuesday (verified via Julian-day formula).
  assert_eq(format_date_time("dddd", date), "Tuesday")
  assert_eq(format_date_time("ddd", date), "Tue")
}

///|
test "§17.16.5.78 TIME defaults to h:mm am/pm" {
  let registry = FieldRegistry::with_builtins()
  let field = try! parse_instruction("TIME")
  let ctx = ctx_with(fn(c) { c })
  let result = evaluate_field(field, ctx, registry)
  assert_eq(result.to_text(), "2:30 pm")
}

///|
test "§17.16.5.4 AUTHOR + \\* Upper switch" {
  let registry = FieldRegistry::with_builtins()
  let field = try! parse_instruction("AUTHOR \\* Upper")
  let ctx = ctx_with(fn(c) { { ..c, author: Some("Ada Lovelace") } })
  let result = evaluate_field(field, ctx, registry)
  assert_eq(result.to_text(), "ADA LOVELACE")
}

///|
test "§17.16.5.25 HYPERLINK returns FieldResult::Hyperlink" {
  let registry = FieldRegistry::with_builtins()
  let field = try! parse_instruction(
    "HYPERLINK \"https://example.com\" \"Click\"",
  )
  let ctx = ctx_with(fn(c) { c })
  let result = evaluate_field(field, ctx, registry)
  match result {
    Hyperlink(url, display) => {
      assert_eq(url, "https://example.com")
      assert_eq(display, "Click")
    }
    _ => assert_true(false)
  }
}

///|
test "§17.16.5.58 REF reads bookmarks[name].text" {
  let registry = FieldRegistry::with_builtins()
  let ctx = ctx_with(fn(c) {
    c.bookmarks.set("Heading1", BookmarkValue::new("Introduction", 3))
    c
  })
  let ref_field = try! parse_instruction("REF Heading1")
  let result = evaluate_field(ref_field, ctx, registry)
  assert_eq(result.to_text(), "Introduction")
  let page_ref_field = try! parse_instruction("PAGEREF Heading1")
  let page_result = evaluate_field(page_ref_field, ctx, registry)
  assert_eq(page_result.to_text(), "3")
}

///|
test "§17.16.5.65 SEQ increments named counter" {
  let registry = FieldRegistry::with_builtins()
  let ctx = ctx_with(fn(c) { c })
  let field = try! parse_instruction("SEQ Figure")
  let first = evaluate_field(field, ctx, registry).to_text()
  let second = evaluate_field(field, ctx, registry).to_text()
  let third = evaluate_field(field, ctx, registry).to_text()
  assert_eq(first, "1")
  assert_eq(second, "2")
  assert_eq(third, "3")
}

///|
test "§17.16.5.45 MERGEFIELD looks up merge record" {
  let registry = FieldRegistry::with_builtins()
  let ctx = ctx_with(fn(c) {
    c.merge_record.set("FullName", "Alan Turing")
    c
  })
  let field = try! parse_instruction("MERGEFIELD FullName")
  let result = evaluate_field(field, ctx, registry)
  assert_eq(result.to_text(), "Alan Turing")
}

///|
test "§17.16.5.32 IF compares positional arguments" {
  let registry = FieldRegistry::with_builtins()
  let ctx = ctx_with(fn(c) { c })
  let yes = try! parse_instruction("IF 5 > 3 \"yes\" \"no\"")
  assert_eq(evaluate_field(yes, ctx, registry).to_text(), "yes")
  let no = try! parse_instruction("IF 5 < 3 \"yes\" \"no\"")
  assert_eq(evaluate_field(no, ctx, registry).to_text(), "no")
}

///|
test "§17.16 unknown instruction falls back to literal" {
  let registry = FieldRegistry::with_builtins()
  let field = try! parse_instruction("WIDGET 42")
  let result = evaluate_field(
    field,
    FieldContext::default(sample_date()),
    registry,
  )
  assert_eq(result.to_text(), "WIDGET 42")
}

///|
test "§17.16.4.3 apply_general_switch covers Upper / Lower / Roman / Ordinal" {
  assert_eq(apply_general_switch("hello", "Upper"), "HELLO")
  assert_eq(apply_general_switch("HELLO", "Lower"), "hello")
  assert_eq(apply_general_switch("hello world", "FirstCap"), "Hello world")
  assert_eq(apply_general_switch("hello world", "Caps"), "Hello World")
  assert_eq(apply_general_switch("4", "Roman"), "IV")
  assert_eq(apply_general_switch("4", "roman"), "iv")
  assert_eq(apply_general_switch("21", "Ordinal"), "21st")
  assert_eq(apply_general_switch("3", "CardText"), "Three")
  assert_eq(apply_general_switch("255", "Hex"), "FF")
}

///|
test "§17.16 field_part1_17_16_section_name citation" {
  assert_eq(field_part1_17_16_section_name(), "Part 1 §17.16")
}

///|
/// §17.16.5.66 TOC / §17.16.5.65 TC / §17.16.5.34 INDEX /
/// §17.16.5.84 XE / §17.16.5.71 STYLEREF / §17.16.5.49 NOTEREF /
/// §17.16.5.30-.32 FORM* — structural field instructions whose
/// rendered text is the cached runs assembled by Word ahead of
/// time.  The evaluator MUST return `Empty` so the renderer's
/// cached-run fallback wins; without this the registry would
/// fall through to the unknown-instruction Literal path and emit
/// the raw instruction text as visible content.
test "§17.16.5 structural fields evaluate to Empty (cached-run pass-through)" {
  let registry = FieldRegistry::with_builtins()
  let ctx = ctx_with(fn(c) { c })
  for instr in [
    "TOC", "TC \"Chapter 1\"", "INDEX", "XE \"entry\"",
    "STYLEREF \"Heading 1\"", "NOTEREF _RefNote",
    "FORMTEXT", "FORMCHECKBOX", "FORMDROPDOWN",
  ] {
    let field = try! parse_instruction(instr)
    let result = evaluate_field(field, ctx, registry)
    assert_true(result is Empty)
  }
}
