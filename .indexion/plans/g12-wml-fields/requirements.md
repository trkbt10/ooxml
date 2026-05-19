# G12 — WordprocessingML Field Code Evaluator

Tracks the Tier-3 gap "WML field code parsing/evaluation" from
`.indexion/plans/shallow-audit/audit.md` (#14). Depends on G9 (style
inheritance, completed) — some fields format their result through
styles.

## Source sections

- Part 1 §17.16.1 Syntax — EBNF for `field`, `field-type`,
  `field-argument`, `field-specific-switch`, `formatting-switch`,
  `comparison`, `expression`, `function`, `cell-reference`, …
- Part 1 §17.16.2 XML representation — `w:fldSimple` (one-shot
  `@w:instr`) and `w:fldChar` (Begin / Separate / End with intervening
  `w:instrText` runs).
- Part 1 §17.16.4.1 Date and time formatting — `\@` switch with the
  spec's format-code grammar (`yyyy MM dd HH hh mm ss am/pm dddd MMM
  MMMM Q WW` and literals).
- Part 1 §17.16.4.2 Numeric formatting — `\#` switch grammar
  (`0 # ?  . , -  +` placeholders, currency symbol, leading literal,
  trailing literal).
- Part 1 §17.16.4.3 General formatting — `\*` switch (`Upper Lower
  FirstCap Caps Roman roman Arabic ArabicDash AlphabeticUpper
  alphabetic CardText OrdText Ordinal Hex DollarText MERGEFORMAT
  CHARFORMAT`).
- Part 1 §17.16.5.* — field-specific definitions for at least the
  canonical instructions: AUTHOR, CREATEDATE, DATE, EDITTIME, FILENAME,
  HYPERLINK, IF, INCLUDETEXT, KEYWORDS, MERGEFIELD, NUMPAGES, PAGE,
  PAGEREF, PRINTDATE, REF, REVNUM, SAVEDATE, SECTION, SECTIONPAGES,
  SEQ, SUBJECT, TIME, TITLE.

## Functional requirements

### Requirement 1: Instruction tokenizer

`tokenize_instruction(text)` shall lex the §17.16.1 instruction
syntax into a sequence of `InstructionToken` values:

- `TWord(String)` — bare identifier (field name or argument).
- `TQuoted(String)` — `"…"` text with backslash escapes processed.
- `TSwitch(Char)` — `\X` switch flag (single character after `\`).
- `TEnd` — virtual end-of-stream token.

Whitespace is significant only as a separator; consecutive runs
collapse. The tokenizer shall raise `@opc_errors.SchemaViolation` for
unterminated quoted strings.

### Requirement 2: Instruction parser

`parse_instruction(text)` shall return a typed `Field` carrying:

- `instr_text : String` (original text for diagnostics)
- `instruction : FieldInstruction` (typed discriminator covering the
  spec's field-type enumeration)
- `arguments : Array[String]` (positional field-arguments, in
  document order)
- `switches : Array[FieldSwitch]` (`\@`, `\#`, `\*`, `\b`, `\f`, `\h`,
  `\l`, `\m`, `\n`, `\o`, `\p`, `\s`, `\t`, `\u`, `\w`, `\y`, …
  carrying their optional argument text)

Unknown instruction names shall produce `FieldInstruction::Unknown(name)`
so the renderer can pass the literal field through unchanged.

### Requirement 3: XML decoding

`decode_simple_field(@domain.CT_SimpleField)` shall return a `Field`
parsed from `w:fldSimple/@w:instr`.

`decode_field_run_sequence(elements)` shall walk a `w:r` sequence that
contains `w:fldChar w:fldCharType="begin"` … `w:instrText` … `w:fldChar
w:fldCharType="separate"` … (cached result runs) … `w:fldChar
w:fldCharType="end"` and return one `Field` per begin/end pair plus the
cached result runs (the renderer falls back on them when evaluation
is not possible).

### Requirement 4: FieldContext

`FieldContext` shall carry the evaluator-side state needed by the
canonical evaluators:

- `current_page : Int`
- `total_pages : Int`
- `section_pages : Int`
- `current_section : Int`
- `current_date : @date_serial.CalendarDateTime`
- `author : String?`
- `title : String?`
- `subject : String?`
- `keywords : String?`
- `comments : String?`
- `filename : String?`
- `last_modified_by : String?`
- `revision_number : Int?`
- `create_date : @date_serial.CalendarDateTime?`
- `print_date : @date_serial.CalendarDateTime?`
- `save_date : @date_serial.CalendarDateTime?`
- `bookmarks : @hashmap.HashMap[String, BookmarkValue]`
  — page number + cached text per bookmark for REF / PAGEREF.
- `merge_record : @hashmap.HashMap[String, String]`
  — per-record MERGEFIELD values.
- `seq_counters : @hashmap.HashMap[String, Int]` — SEQ counter store.

### Requirement 5: Built-in evaluator registry

`FieldRegistry::with_builtins()` shall register evaluators for at
least the following instructions per §17.16.5.*:

- AUTHOR — context.author with `\*` upper/lower/FirstCap support.
- CREATEDATE / PRINTDATE / SAVEDATE — formatted via the `\@` switch.
- DATE / TIME — context.current_date via `\@` switch (TIME defaults
  to `h:mm am/pm`).
- EDITTIME — context.revision_number minutes.
- FILENAME — context.filename.
- HYPERLINK — produces a `FieldResult::Hyperlink { url, display }`
  using the first argument as the URL and the cached display runs as
  the visible text.
- IF — comparison parser + then/else argument selection per §17.16.5.32.
- INCLUDETEXT — passes through; the renderer is expected to resolve
  the referenced file in a future pass.
- KEYWORDS / SUBJECT / TITLE / COMMENTS — context.* fields.
- MERGEFIELD — context.merge_record[name] with `\*` formatting.
- NUMPAGES / PAGE / SECTION / SECTIONPAGES — context counters.
- PAGEREF — `bookmarks[name].page`, formatted via `\@`/`\*`.
- REF — `bookmarks[name].text`.
- REVNUM — context.revision_number.
- SEQ — increments `seq_counters[name]` and renders via NumFormat.
- USERADDRESS / USERINITIALS / USERNAME — fall back to "User"
  literals (the spec assigns these to user-information; the renderer
  feeds real values once available).

`Unknown` and any unregistered names shall return
`FieldResult::Literal(field.instr_text)` so the renderer can drop
back to the cached result.

### Requirement 6: Date and time formatting

`format_date_time(template, date)` shall implement the §17.16.4.1
format-code grammar for the canonical placeholders:

- `yyyy` → 4-digit year, `yy` → last two digits.
- `M` / `MM` / `MMM` / `MMMM` → month (numeric / padded / short name /
  full name).
- `d` / `dd` / `ddd` / `dddd` → day-of-month or day-of-week.
- `H` / `HH` (24-hour), `h` / `hh` (12-hour).
- `m` / `mm` — minute (positional context — after `h*` or `H*`).
- `s` / `ss` — second.
- `am/pm` (case-insensitive) → AM/PM marker.
- Literal text inside single quotes (`'literal'`) is preserved.

### Requirement 7: NumFormat passthrough

`apply_general_switch(value, "Roman")` / `"roman"` / `"AlphabeticUpper"`
/ `"alphabetic"` / `"Arabic"` / `"CardText"` / `"OrdText"` / `"Ordinal"`
/ `"Hex"` / `"DollarText"` / `"Upper"` / `"Lower"` / `"FirstCap"` /
`"Caps"` shall produce the formatted scalar per §17.16.4.3. Numeric
formats reuse `@numbering_resolver.NumFormat::format` to avoid
re-implementing roman / letter / ordinal logic.

### Requirement 8: Section-name citation helper

`field_part1_17_16_section_name()` shall return `Part 1 §17.16`.

## Non-functional requirements

- Pure functions on `@xml.Element` / `@domain.CT_*` wrappers + the
  supplied `FieldContext`.
- `pub fn` bodies satisfy SHALLOW (>4 lines of non-trivial logic).
- Tests cover instruction tokenizer + parser, each of the ≥15
  built-in evaluators, the `\@` date formatter (yyyy MM dd HH mm ss
  ampm), and the `\*` Upper/Lower/Roman/Ordinal pathways.

## Out of scope

- Equation and formula evaluation (= field) — needs a full formula
  parser; placeholder evaluator returns `FieldResult::Literal` for
  now.
- Mail-merge engine state machine (NEXT / NEXTIF / SKIPIF) — covered
  later when the wider mail-merge driver lands.
- TOC / INDEX / TOA layout — these are renderer-side concerns and the
  field evaluator only records their presence.
- Index-and-tables XE / TC entry recording.
- Form-field interactivity (FORMTEXT / FORMCHECKBOX / FORMDROPDOWN).
