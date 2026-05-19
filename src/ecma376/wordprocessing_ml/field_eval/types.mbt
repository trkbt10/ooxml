///|
/// Part 1 §17.16.1 — typed view of a WordprocessingML field
/// instruction name. The variants mirror the §17.16.1 EBNF
/// productions (date-and-time, document-automation,
/// document-information, document-property, equations-and-formulas,
/// index-and-tables, links-and-references, mail-merge, numbering,
/// user-information, form-field) and the §17.16.5.* per-field
/// definitions; `UserDefined` carries a non-standard letter-only name
/// from §17.16.1 `user-defined-field`; `Unknown` carries any other
/// lexical instruction so the renderer can pass the literal field
/// through unchanged.
pub(all) enum FieldInstruction {
  /// §17.16.5.4 AUTHOR — document author.
  Author
  /// §17.16.5.9 COMMENTS — document comments.
  Comments
  /// §17.16.5.11 CREATEDATE — creation timestamp.
  CreateDate
  /// §17.16.5.13 DATE — current date / time.
  Date
  /// §17.16.5.14 DOCPROPERTY — built-in or custom doc property.
  DocProperty
  /// §17.16.5.15 DOCVARIABLE — `w:docVars` lookup.
  DocVariable
  /// §17.16.5.16 EDITTIME — total editing time in minutes.
  EditTime
  /// §17.16.5.18 FILENAME — current file name.
  FileName
  /// §17.16.5.25 HYPERLINK — anchor URL + display.
  Hyperlink
  /// §17.16.5.32 IF — conditional expression.
  If
  /// §17.16.5.36 INCLUDETEXT — embed external WML.
  IncludeText
  /// §17.16.5.41 KEYWORDS — document keywords.
  Keywords
  /// §17.16.5.45 MERGEFIELD — mail-merge value.
  MergeField
  /// §17.16.5.50 NUMPAGES — total page count.
  NumPages
  /// §17.16.5.51 PAGE — current page number.
  Page
  /// §17.16.5.52 PAGEREF — page number of a bookmark.
  PageRef
  /// §17.16.5.55 PRINTDATE — last print timestamp.
  PrintDate
  /// §17.16.5.58 REF — bookmark text.
  Ref
  /// §17.16.5.60 REVNUM — revision number.
  RevNum
  /// §17.16.5.62 SAVEDATE — last save timestamp.
  SaveDate
  /// §17.16.5.63 SECTION — current section number.
  Section
  /// §17.16.5.64 SECTIONPAGES — pages in the current section.
  SectionPages
  /// §17.16.5.65 SEQ — named counter.
  Seq
  /// §17.16.5.71 SUBJECT — document subject.
  Subject
  /// §17.16.5.78 TIME — current time.
  Time
  /// §17.16.5.79 TITLE — document title.
  Title
  /// §17.16.5.* USERADDRESS — user address.
  UserAddress
  /// §17.16.5.* USERINITIALS — user initials.
  UserInitials
  /// §17.16.5.* USERNAME — user name.
  UserName
  /// §17.16.1 user-defined-field — letter-only custom name.
  UserDefined(String)
  /// §17.16.1 unknown instruction — preserved for round-trip.
  Unknown(String)
} derive(Eq, Debug)

///|
/// Part 1 §17.16.1 — match an uppercased instruction name against the
/// canonical list. Unknown lexical forms are returned as `Unknown(name)`
/// so the evaluator can pass the literal field through.
pub fn FieldInstruction::from_name(name : String) -> FieldInstruction {
  let upper = name.to_upper()
  match upper {
    "AUTHOR" => Author
    "COMMENTS" => Comments
    "CREATEDATE" => CreateDate
    "DATE" => Date
    "DOCPROPERTY" => DocProperty
    "DOCVARIABLE" => DocVariable
    "EDITTIME" => EditTime
    "FILENAME" => FileName
    "HYPERLINK" => Hyperlink
    "IF" => If
    "INCLUDETEXT" => IncludeText
    "KEYWORDS" => Keywords
    "MERGEFIELD" => MergeField
    "NUMPAGES" => NumPages
    "PAGE" => Page
    "PAGEREF" => PageRef
    "PRINTDATE" => PrintDate
    "REF" => Ref
    "REVNUM" => RevNum
    "SAVEDATE" => SaveDate
    "SECTION" => Section
    "SECTIONPAGES" => SectionPages
    "SEQ" => Seq
    "SUBJECT" => Subject
    "TIME" => Time
    "TITLE" => Title
    "USERADDRESS" => UserAddress
    "USERINITIALS" => UserInitials
    "USERNAME" => UserName
    _ => if is_letter_only(upper) { UserDefined(upper) } else { Unknown(upper) }
  }
}

///|
/// Part 1 §17.16.1 — canonical (uppercase) lexical name for a
/// FieldInstruction. Used as the lookup key in `FieldRegistry`.
pub fn FieldInstruction::canonical_name(self : FieldInstruction) -> String {
  match self {
    Author => "AUTHOR"
    Comments => "COMMENTS"
    CreateDate => "CREATEDATE"
    Date => "DATE"
    DocProperty => "DOCPROPERTY"
    DocVariable => "DOCVARIABLE"
    EditTime => "EDITTIME"
    FileName => "FILENAME"
    Hyperlink => "HYPERLINK"
    If => "IF"
    IncludeText => "INCLUDETEXT"
    Keywords => "KEYWORDS"
    MergeField => "MERGEFIELD"
    NumPages => "NUMPAGES"
    Page => "PAGE"
    PageRef => "PAGEREF"
    PrintDate => "PRINTDATE"
    Ref => "REF"
    RevNum => "REVNUM"
    SaveDate => "SAVEDATE"
    Section => "SECTION"
    SectionPages => "SECTIONPAGES"
    Seq => "SEQ"
    Subject => "SUBJECT"
    Time => "TIME"
    Title => "TITLE"
    UserAddress => "USERADDRESS"
    UserInitials => "USERINITIALS"
    UserName => "USERNAME"
    UserDefined(name) => name
    Unknown(name) => name
  }
}

///|
fn is_letter_only(text : String) -> Bool {
  if text.length() == 0 {
    return false
  }
  for i in 0..<text.length() {
    let unit = text.code_unit_at(i).to_int()
    let is_upper = unit >= 0x41 && unit <= 0x5A
    let is_lower = unit >= 0x61 && unit <= 0x7A
    if !is_upper && !is_lower {
      return false
    }
  }
  true
}

///|
/// Part 1 §17.16.1 — `field-specific-switch` token. `flag` is the
/// character after `\` (e.g. `@`, `#`, `*`, `b`, `f`, `h`, `l`, `m`,
/// `n`, `o`, `p`, `s`, `t`, `u`, `w`, `y`); `argument` is the
/// switch's argument when present (e.g. for `\@ "yyyy"` the argument
/// is `"yyyy"`).
pub(all) struct FieldSwitch {
  flag : Char
  argument : String?
} derive(Eq, Debug)

///|
/// Part 1 §17.16.1 — typed view of a field instruction:
///
/// - `instr_text` — original instruction string for diagnostics and
///   round-trip when the evaluator falls back.
/// - `instruction` — canonical `FieldInstruction` discriminator.
/// - `arguments` — positional field-arguments in document order.
/// - `switches` — `\X` switches in document order with optional args.
pub(all) struct Field {
  instr_text : String
  instruction : FieldInstruction
  arguments : Array[String]
  switches : Array[FieldSwitch]
} derive(Eq, Debug)

///|
/// Find the first switch with the given flag. Returns the matching
/// `FieldSwitch` or `None`. Used by the evaluator to read the `\@`,
/// `\#`, `\*` formatting switches.
pub fn Field::find_switch(self : Field, flag : Char) -> FieldSwitch? {
  for entry in self.switches {
    if entry.flag == flag {
      return Some(entry)
    }
  }
  None
}

///|
/// Part 1 §17.16.5.25 — bookmark cache entry. The evaluator reads
/// `text` for `REF` results and `page` for `PAGEREF` results.
pub(all) struct BookmarkValue {
  text : String
  page : Int
} derive(Eq, Debug)

///|
/// BookmarkValue::new — convenience constructor.
pub fn BookmarkValue::new(text : String, page : Int) -> BookmarkValue {
  { text, page }
}

///|
/// Part 1 §17.16 — evaluator-side state. Built by the renderer from
/// the document's core properties, page counters, bookmarks, and
/// mail-merge record. All fields are explicit so the evaluator never
/// needs to reach back to the source XML.
pub(all) struct FieldContext {
  current_page : Int
  total_pages : Int
  section_pages : Int
  current_section : Int
  current_date : @date_serial.CalendarDateTime
  author : String?
  title : String?
  subject : String?
  keywords : String?
  comments : String?
  filename : String?
  last_modified_by : String?
  revision_number : Int?
  create_date : @date_serial.CalendarDateTime?
  print_date : @date_serial.CalendarDateTime?
  save_date : @date_serial.CalendarDateTime?
  bookmarks : @hashmap.HashMap[String, BookmarkValue]
  merge_record : @hashmap.HashMap[String, String]
  seq_counters : @hashmap.HashMap[String, Int]
}

///|
/// FieldContext::default — construct a minimal context anchored at
/// `today` with empty properties / bookmarks / merge record. Useful
/// for tests and for renderers that have not yet loaded core props.
pub fn FieldContext::default(
  today : @date_serial.CalendarDateTime,
) -> FieldContext {
  {
    current_page: 1,
    total_pages: 1,
    section_pages: 1,
    current_section: 1,
    current_date: today,
    author: None,
    title: None,
    subject: None,
    keywords: None,
    comments: None,
    filename: None,
    last_modified_by: None,
    revision_number: None,
    create_date: None,
    print_date: None,
    save_date: None,
    bookmarks: @hashmap.HashMap::new(),
    merge_record: @hashmap.HashMap::new(),
    seq_counters: @hashmap.HashMap::new(),
  }
}

///|
/// Result of evaluating a field. `Literal` covers most fields after
/// formatting; `Hyperlink` carries the URL + display text so the
/// renderer can emit `<w:hyperlink>` markup; `Number` and `Date`
/// retain the raw value so formatting switches can be re-applied.
pub(all) enum FieldResult {
  Literal(String)
  Hyperlink(String, String)
  Number(Double)
  DateResult(@date_serial.CalendarDateTime, String)
  Empty
} derive(Eq, Debug)

///|
/// Convert a `FieldResult` to its rendered text form. `Hyperlink`
/// returns the display text; `Number` uses the standard `Double`
/// rendering; `DateResult` carries an already-formatted string from
/// the `\@` switch.
pub fn FieldResult::to_text(self : FieldResult) -> String {
  match self {
    Literal(text) => text
    Hyperlink(_, display) => display
    Number(value) => format_double(value)
    DateResult(_, formatted) => formatted
    Empty => ""
  }
}

///|
fn format_double(value : Double) -> String {
  if value.is_nan() || value.is_inf() {
    return value.to_string()
  }
  if value == value.trunc() && value.abs() < 1.0e15 {
    value.to_int64().to_string()
  } else {
    value.to_string()
  }
}

///|
/// Part 1 §17.16 — registry of canonical evaluators keyed by
/// uppercase instruction name. The evaluator closure takes a parsed
/// field and the active FieldContext and returns the raw FieldResult;
/// formatting switches are applied by the driver, not by individual
/// evaluators. `with_builtins` is implemented in `builtins.mbt` so
/// this file stays focused on the type surface.
pub(all) struct FieldRegistry {
  entries : @hashmap.HashMap[String, (Field, FieldContext) -> FieldResult]
}

///|
/// Construct an empty registry. Callers can register their own
/// evaluators (e.g. for product-specific field codes).
pub fn FieldRegistry::new() -> FieldRegistry {
  { entries: @hashmap.HashMap::new() }
}

///|
/// Register an evaluator under an uppercase instruction name. The
/// caller is expected to upper-case the name to match the lookup
/// performed by `evaluate_field`.
pub fn FieldRegistry::register(
  self : FieldRegistry,
  name : String,
  evaluator : (Field, FieldContext) -> FieldResult,
) -> Unit {
  self.entries.set(name.to_upper(), evaluator)
}

///|
/// Look up an evaluator by uppercase instruction name. Returns
/// `None` when no evaluator is registered, in which case
/// `evaluate_field` falls back to the cached field result.
pub fn FieldRegistry::lookup(
  self : FieldRegistry,
  name : String,
) -> ((Field, FieldContext) -> FieldResult)? {
  self.entries.get(name.to_upper())
}

///|
let field_section : String = "Part 1 §17.16"

///|
/// Part 1 §17.16 — citation helper exported so callers can include
/// the canonical section anchor in their diagnostics.
pub fn field_part1_17_16_section_name() -> String {
  field_section
}
