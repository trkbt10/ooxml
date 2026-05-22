///|
/// Part 1 §17.16 — construct a `FieldRegistry` populated with the
/// canonical evaluators from §17.16.5.*. Renderers can call this once
/// at start-up and then register additional product-specific
/// instructions on top.
pub fn FieldRegistry::with_builtins() -> FieldRegistry {
  let registry = FieldRegistry::new()
  registry.register("AUTHOR", evaluate_author)
  registry.register("COMMENTS", evaluate_comments)
  registry.register("CREATEDATE", evaluate_create_date)
  registry.register("DATE", evaluate_date)
  registry.register("EDITTIME", evaluate_edit_time)
  registry.register("FILENAME", evaluate_filename)
  registry.register("HYPERLINK", evaluate_hyperlink)
  registry.register("IF", evaluate_if)
  registry.register("INCLUDETEXT", evaluate_include_text)
  registry.register("KEYWORDS", evaluate_keywords)
  registry.register("MERGEFIELD", evaluate_merge_field)
  registry.register("NUMPAGES", evaluate_num_pages)
  registry.register("PAGE", evaluate_page)
  registry.register("PAGEREF", evaluate_page_ref)
  registry.register("PRINTDATE", evaluate_print_date)
  registry.register("REF", evaluate_ref)
  registry.register("REVNUM", evaluate_rev_num)
  registry.register("SAVEDATE", evaluate_save_date)
  registry.register("SECTION", evaluate_section)
  registry.register("SECTIONPAGES", evaluate_section_pages)
  registry.register("SEQ", evaluate_seq)
  registry.register("SUBJECT", evaluate_subject)
  registry.register("TIME", evaluate_time)
  registry.register("TITLE", evaluate_title)
  registry.register("USERADDRESS", evaluate_user_address)
  registry.register("USERINITIALS", evaluate_user_initials)
  registry.register("USERNAME", evaluate_user_name)
  // §17.16.5.66 TOC — table-of-contents field. The rendered
  // content is the cached runs assembled by Word, NOT something
  // the evaluator can synthesise without a full document scan.
  // Return Empty so the caller's cached-run fallback wins.
  registry.register("TOC", evaluate_empty_field)
  // §17.16.5.65 TC — TOC entry marker. Spec: emits NO visible
  // text; the TOC field reads these to assemble its result.
  registry.register("TC", evaluate_empty_field)
  // §17.16.5.34 INDEX — same shape as TOC; cached runs hold the result.
  registry.register("INDEX", evaluate_empty_field)
  // §17.16.5.84 XE — index entry marker; emits no visible text.
  registry.register("XE", evaluate_empty_field)
  // §17.16.5.71 STYLEREF — references the nearest paragraph
  // applying the named style.  Cached runs hold the resolved
  // reference; without re-walking the document we defer.
  registry.register("STYLEREF", evaluate_empty_field)
  // §17.16.5.49 NOTEREF — references a footnote/endnote mark.
  // Cached runs hold the resolved mark number.
  registry.register("NOTEREF", evaluate_empty_field)
  // §17.16.5.30 FORMTEXT, §17.16.5.31 FORMCHECKBOX,
  // §17.16.5.32 FORMDROPDOWN — form-field placeholders. The
  // cached runs hold the user's current input; preserve them.
  registry.register("FORMTEXT", evaluate_empty_field)
  registry.register("FORMCHECKBOX", evaluate_empty_field)
  registry.register("FORMDROPDOWN", evaluate_empty_field)
  registry
}

///|
/// §17.16.5 — evaluator that returns `Empty` so the renderer's
/// cached-run fallback takes over.  Used for structural fields
/// (TOC, TC, INDEX, XE, STYLEREF, NOTEREF, FORM*) whose visible
/// text is assembled by Word ahead of time and stored as cached
/// runs between fldChar separate/end.
fn evaluate_empty_field(_field : Field, _ctx : FieldContext) -> FieldResult {
  Empty
}

///|
fn literal_or_argument(value : String?) -> FieldResult {
  match value {
    Some(text) => Literal(text)
    None => Empty
  }
}

///|
fn evaluate_author(_field : Field, ctx : FieldContext) -> FieldResult {
  literal_or_argument(ctx.author)
}

///|
fn evaluate_comments(_field : Field, ctx : FieldContext) -> FieldResult {
  literal_or_argument(ctx.comments)
}

///|
fn evaluate_create_date(field : Field, ctx : FieldContext) -> FieldResult {
  match ctx.create_date {
    Some(date) => date_with_default_format(date, field, "yyyy-MM-dd")
    None => Empty
  }
}

///|
fn evaluate_date(field : Field, ctx : FieldContext) -> FieldResult {
  date_with_default_format(ctx.current_date, field, "yyyy-MM-dd")
}

///|
fn evaluate_edit_time(_field : Field, ctx : FieldContext) -> FieldResult {
  match ctx.revision_number {
    Some(value) => Number(value.to_double())
    None => Number(0.0)
  }
}

///|
fn evaluate_filename(_field : Field, ctx : FieldContext) -> FieldResult {
  literal_or_argument(ctx.filename)
}

///|
/// §17.16.5.25 HYPERLINK — first positional argument is the URL; the
/// display text is captured by the renderer from the cached run
/// sequence so we pass the URL through as the display when no second
/// arg is present.
fn evaluate_hyperlink(field : Field, _ctx : FieldContext) -> FieldResult {
  let url = match field.arguments.get(0) {
    Some(text) => text
    None => ""
  }
  let display = match field.arguments.get(1) {
    Some(text) => text
    None => url
  }
  Hyperlink(url, display)
}

///|
/// §17.16.5.32 IF — minimal evaluator: compares two `field-argument`s
/// using the supplied `=`, `<>`, `<`, `<=`, `>`, `>=` operator (taken
/// from the third positional argument) and selects between the
/// fourth (then) and fifth (else) arguments. Returns Empty when the
/// arguments are insufficient.
fn evaluate_if(field : Field, _ctx : FieldContext) -> FieldResult {
  if field.arguments.length() < 5 {
    return Empty
  }
  let lhs = field.arguments[0]
  let op = field.arguments[1]
  let rhs = field.arguments[2]
  let then_value = field.arguments[3]
  let else_value = field.arguments[4]
  let outcome = compare_args(lhs, op, rhs)
  if outcome {
    Literal(then_value)
  } else {
    Literal(else_value)
  }
}

///|
fn compare_args(lhs : String, op : String, rhs : String) -> Bool {
  let lhs_num = parse_double_lenient(lhs)
  let rhs_num = parse_double_lenient(rhs)
  match (lhs_num, rhs_num) {
    (Some(l), Some(r)) =>
      match op {
        "=" => l == r
        "<>" => l != r
        "<" => l < r
        "<=" => l <= r
        ">" => l > r
        ">=" => l >= r
        _ => false
      }
    _ =>
      match op {
        "=" => lhs == rhs
        "<>" => lhs != rhs
        _ => false
      }
  }
}

///|
fn parse_double_lenient(text : String) -> Double? {
  match parse_int_lenient(text) {
    Some(n) => Some(n.to_double())
    None => None
  }
}

///|
fn evaluate_include_text(field : Field, _ctx : FieldContext) -> FieldResult {
  match field.arguments.get(0) {
    Some(path) => Literal("[INCLUDETEXT " + path + "]")
    None => Empty
  }
}

///|
fn evaluate_keywords(_field : Field, ctx : FieldContext) -> FieldResult {
  literal_or_argument(ctx.keywords)
}

///|
/// §17.16.5.45 MERGEFIELD — looks up the first positional argument as
/// a key in the mail-merge record. Missing keys evaluate to Empty so
/// the renderer can fall back to the cached run.
fn evaluate_merge_field(field : Field, ctx : FieldContext) -> FieldResult {
  match field.arguments.get(0) {
    Some(name) =>
      match ctx.merge_record.get(name) {
        Some(value) => Literal(value)
        None => Empty
      }
    None => Empty
  }
}

///|
fn evaluate_num_pages(_field : Field, ctx : FieldContext) -> FieldResult {
  Number(ctx.total_pages.to_double())
}

///|
fn evaluate_page(_field : Field, ctx : FieldContext) -> FieldResult {
  Number(ctx.current_page.to_double())
}

///|
fn evaluate_page_ref(field : Field, ctx : FieldContext) -> FieldResult {
  match field.arguments.get(0) {
    Some(name) =>
      match ctx.bookmarks.get(name) {
        Some(value) => Number(value.page.to_double())
        None => Empty
      }
    None => Empty
  }
}

///|
fn evaluate_print_date(field : Field, ctx : FieldContext) -> FieldResult {
  match ctx.print_date {
    Some(date) => date_with_default_format(date, field, "yyyy-MM-dd")
    None => Empty
  }
}

///|
fn evaluate_ref(field : Field, ctx : FieldContext) -> FieldResult {
  match field.arguments.get(0) {
    Some(name) =>
      match ctx.bookmarks.get(name) {
        Some(value) => Literal(value.text)
        None => Empty
      }
    None => Empty
  }
}

///|
fn evaluate_rev_num(_field : Field, ctx : FieldContext) -> FieldResult {
  match ctx.revision_number {
    Some(value) => Number(value.to_double())
    None => Number(0.0)
  }
}

///|
fn evaluate_save_date(field : Field, ctx : FieldContext) -> FieldResult {
  match ctx.save_date {
    Some(date) => date_with_default_format(date, field, "yyyy-MM-dd")
    None => Empty
  }
}

///|
fn evaluate_section(_field : Field, ctx : FieldContext) -> FieldResult {
  Number(ctx.current_section.to_double())
}

///|
fn evaluate_section_pages(_field : Field, ctx : FieldContext) -> FieldResult {
  Number(ctx.section_pages.to_double())
}

///|
/// §17.16.5.65 SEQ — named counter. Reads `seq_counters[name]`,
/// increments it, and renders via `\* Arabic` (default) or the
/// supplied switch.
fn evaluate_seq(field : Field, ctx : FieldContext) -> FieldResult {
  let name = match field.arguments.get(0) {
    Some(text) => text
    None => return Empty
  }
  let current = ctx.seq_counters.get(name).unwrap_or(0)
  let next = current + 1
  ctx.seq_counters.set(name, next)
  Number(next.to_double())
}

///|
fn evaluate_subject(_field : Field, ctx : FieldContext) -> FieldResult {
  literal_or_argument(ctx.subject)
}

///|
fn evaluate_time(field : Field, ctx : FieldContext) -> FieldResult {
  date_with_default_format(ctx.current_date, field, "h:mm am/pm")
}

///|
fn evaluate_title(_field : Field, ctx : FieldContext) -> FieldResult {
  literal_or_argument(ctx.title)
}

///|
fn evaluate_user_address(_field : Field, _ctx : FieldContext) -> FieldResult {
  Empty
}

///|
fn evaluate_user_initials(_field : Field, _ctx : FieldContext) -> FieldResult {
  Empty
}

///|
fn evaluate_user_name(_field : Field, _ctx : FieldContext) -> FieldResult {
  Empty
}

///|
fn date_with_default_format(
  date : @date_serial.CalendarDateTime,
  field : Field,
  default_template : String,
) -> FieldResult {
  let template = match field.find_switch('@') {
    Some(entry) =>
      match entry.argument {
        Some(text) => text
        None => default_template
      }
    None => default_template
  }
  DateResult(date, format_date_time(template, date))
}
