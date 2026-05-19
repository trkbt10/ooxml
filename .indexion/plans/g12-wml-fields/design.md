# G12 — Design

New package: `src/ecma376/wordprocessing_ml/field_eval/`.

## File layout

```
field_eval/
  moon.pkg                   -- @hashmap, @xml, @opc_errors, @domain,
                                @date_serial, @numbering_resolver
  types.mbt                  -- FieldInstruction enum (45+ variants),
                                FieldSwitch, FieldFormat, Field,
                                FieldContext, BookmarkValue,
                                FieldResult, FieldRegistry,
                                FieldEvaluator (closure type) +
                                non-trivial methods (>4 lines).
  tokenizer.mbt              -- tokenize_instruction (lexer).
  parser.mbt                 -- parse_instruction (token → Field) +
                                FieldInstruction::from_name lookup.
  decode.mbt                 -- decode_simple_field,
                                decode_field_run_sequence, helpers.
  format_date_time.mbt       -- §17.16.4.1 `\@` switch implementation.
  format_general.mbt         -- §17.16.4.3 `\*` switch implementation,
                                shared text-casing helpers.
  evaluator.mbt              -- evaluate_field driver +
                                FieldRegistry::with_builtins.
  builtins.mbt               -- 20 canonical evaluators
                                (PAGE, NUMPAGES, DATE, TIME, AUTHOR …).
  evaluator_wbtest.mbt       -- ≥10 test blocks.
```

## Type sketch

```
pub(all) enum FieldInstruction {
  Author Comments CreateDate Date DocProperty DocVariable EditTime
  FileName Hyperlink If IncludeText Keywords MergeField NumPages
  Page PageRef PrintDate Ref RevNum SaveDate Section SectionPages
  Seq Subject Time Title
  GoToButton MacroButton Print Private
  AddressBlock Ask Database Fillin GreetingLine MergeRec MergeSeq
  Next NextIf Set SkipIf
  AutoText AutoTextList Bibliography Citation IncludePicture Link
  NoteRef Quote StyleRef
  Index Rd Ta Tc Toa Toc Xe
  Equation Symbol Advance
  ListNum
  UserAddress UserInitials UserName
  FormCheckBox FormDropDown FormText
  UserDefined(String)
  Unknown(String)
}

pub(all) struct FieldSwitch {
  flag : Char
  argument : String?
}

pub(all) struct Field {
  instr_text : String
  instruction : FieldInstruction
  arguments : Array[String]
  switches : Array[FieldSwitch]
}

pub(all) enum FieldResult {
  Literal(String)
  Hyperlink(String, String)
  Number(Double)
  Date(@date_serial.CalendarDateTime, String)
  Empty
}

pub(all) struct BookmarkValue {
  text : String
  page : Int
}

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

pub(all) struct FieldRegistry {
  entries : @hashmap.HashMap[String, FieldEvaluator]
}

pub typealias FieldEvaluator = (Field, FieldContext) -> FieldResult
```

## Tokenizer

A single pass over the instruction text:

- Skip leading whitespace.
- `\` + char → emit `TSwitch(c)`, then read the optional switch
  argument as the next word / quoted string.
- `"` → read until the matching unescaped `"`, handling `\"` and
  `\\` escapes inside.
- Bare identifiers and arguments → read until whitespace or `\`.

The tokenizer keeps switch arguments attached to their `TSwitch` so
the parser does not need to re-stitch them.

## Parser

The first non-switch token is the instruction name. Subsequent
non-switch tokens are positional arguments. Switches accumulate as
`Array[FieldSwitch]` in the order they appear (some fields are
order-sensitive, e.g. `\@` followed by its arg).

## XML decoding

`decode_simple_field` reads `@w:instr` (already namespace-stripped by
the existing domain helpers — falls back to the local name `instr`).

`decode_field_run_sequence` walks an array of `w:r` elements:

1. Find a `w:fldChar w:fldCharType="begin"` — start a new `Field`.
2. Concatenate subsequent `w:instrText` content into `instr_text`
   until either `w:fldChar w:fldCharType="separate"` (cached result
   runs follow) or `w:fldChar w:fldCharType="end"`.
3. On `end`, parse `instr_text` and emit a `(Field, Array[@xml.Element])`
   tuple where the second value is the cached run sequence between
   `separate` and `end`.

Nested fields are supported: when a second `begin` appears before a
matching `end`, the inner field is parsed first, leaving the outer
field's `instr_text` containing the inner field's literal result
placeholder (per the spec's "nested" semantics).

## Evaluator driver

```
fn evaluate_field(field, ctx, registry) -> FieldResult:
  let lookup_key = canonical_instruction_name(field.instruction)
  match registry.entries.get(lookup_key):
    Some(evaluator) =>
      let raw = evaluator(field, ctx)
      apply_formatting_switches(raw, field.switches, ctx)
    None => FieldResult::Literal(field.instr_text)
```

`apply_formatting_switches` chains:

- `\@` — applied to `FieldResult::Date` and any Number/Literal that
  parses to a date via `@date_serial`.
- `\#` — applied to `FieldResult::Number` (TODO: spec's `\#` grammar
  is large; the v1 implementation supports `0`, `0.0`, `0%`, plus
  literal prefix / suffix; richer formats fall through).
- `\*` — applied to text results (`Literal` and the rendered form of
  the others).

The v1 evaluator delegates roman / letter / ordinal formatting to
`@numbering_resolver.NumFormat::format` so we don't duplicate logic.

## SHALLOW resolution

`types.mbt` carries non-trivial methods on the canonical types:

- `FieldInstruction::from_name(String) -> FieldInstruction` (45-arm match)
- `FieldInstruction::canonical_name(self) -> String`
- `Field::find_switch(self, Char) -> FieldSwitch?` (loop over switches)
- `FieldContext::default(date) -> FieldContext` (>4 lines of struct
  initialisation)
- `FieldRegistry::register / lookup / with_builtins` (with_builtins
  registers ≥20 evaluators)
- `BookmarkValue::new(text, page) -> BookmarkValue`

Each is >4 lines so SHALLOW gate is satisfied in `types.mbt`.

## Test plan

- Tokenizer: bare word + quoted + switch + switch with argument.
- Parser: `DATE \@ "yyyy-MM-dd"` → FieldInstruction::Date, arg list
  empty, switch list [`\@` with `"yyyy-MM-dd"`].
- decode_simple_field: round-trips through w:fldSimple/@w:instr.
- decode_field_run_sequence: w:r sequence with begin/separate/end →
  Field + cached runs.
- PAGE / NUMPAGES / SECTION / SECTIONPAGES evaluators.
- DATE / TIME formatter.
- AUTHOR / TITLE with `\*` Upper / Lower.
- HYPERLINK returns FieldResult::Hyperlink.
- REF / PAGEREF read from bookmarks map.
- SEQ increments counter.
- MERGEFIELD looks up merge_record.
- Unknown instruction falls back to Literal.
- format_date_time: yyyy / MM / dd / HH / mm / ampm / literal text.
- apply general switch Upper / Lower / Roman / Ordinal.
