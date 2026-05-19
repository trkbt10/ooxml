# G13 — Design

New package: `src/ecma376/wordprocessing_ml/numbering_resolver/`.

## File layout

```
numbering_resolver/
  moon.pkg                   -- @hashmap, @xml, @opc_errors,
                                @domain
  types.mbt                  -- NumFormat (11), LvlJustification (5),
                                LvlSuffix (3), MultiLevelType (3),
                                Lvl, AbstractNum, LvlOverride, Num,
                                NumberingTable, ResolvedLvl,
                                LevelOrigin + from_attr methods +
                                NumFormat::format + section helper.
  decode.mbt                 -- decode_lvl, decode_abstract_num,
                                decode_num, decode_numbering,
                                attribute helpers.
  resolver.mbt               -- NumberingTable::resolve_level,
                                NumberingTable::level_for_paragraph,
                                with_override helpers,
                                follow_num_style_link.
  format_lvl_text.mbt        -- format_lvl_text(template, counters,
                                lvls) — applies the §17.9.11 template
                                substitution.
  resolver_wbtest.mbt        -- ≥6 test blocks
```

## Type sketch

```
pub(all) enum NumFormat {
  NfDecimal NfUpperRoman NfLowerRoman NfUpperLetter NfLowerLetter
  NfOrdinal NfCardinalText NfOrdinalText NfBullet NfNone NfDecimalZero
}

pub(all) struct Lvl {
  ilvl : Int
  start : Int?
  num_fmt : NumFormat?
  lvl_text : String?
  lvl_jc : LvlJustification?
  lvl_restart : Int?
  p_style : String?
  suff : LvlSuffix?
  is_lgl : Bool
  lvl_pic_bullet_id : Int?
  p_pr_element : @xml.Element?
  r_pr_element : @xml.Element?
}

pub(all) struct AbstractNum {
  abstract_num_id : Int
  multi_level_type : MultiLevelType?
  name : String?
  nsid : String?
  tmpl : String?
  style_link : String?
  num_style_link : String?
  lvls : Array[Lvl]
}

pub(all) struct LvlOverride {
  ilvl : Int
  start_override : Int?
  lvl : Lvl?
}

pub(all) struct Num {
  num_id : Int
  abstract_num_id : Int
  lvl_overrides : Array[LvlOverride]
}

pub(all) struct NumberingTable {
  abstract_nums : @hashmap.HashMap[Int, AbstractNum]
  nums : @hashmap.HashMap[Int, Num]
  pic_bullets : @hashmap.HashMap[Int, @xml.Element]  // see §17.9.20
}

pub(all) enum LevelOrigin {
  SourceOverride
  SourceAbstract
  SourceLinkedAbstract
}

pub(all) struct ResolvedLvl {
  lvl : Lvl
  origin : LevelOrigin
}
```

## Resolution algorithm

```
fn resolve_level(self, num_id, ilvl) -> ResolvedLvl?:
  let num = self.nums.get(num_id)?
  for ovr in num.lvl_overrides:
    if ovr.ilvl == ilvl:
      match ovr.lvl:
        Some(lvl) => return Some({ lvl, origin: SourceOverride })
        None =>
          if ovr.start_override is Some(start):
            let abs_lvl = self.find_abstract_lvl(num.abstract_num_id, ilvl)?
            return Some({ lvl: { ..abs_lvl, start: Some(start) },
                          origin: SourceOverride })
  let abs = self.abstract_nums.get(num.abstract_num_id)?
  match self.find_lvl(abs.lvls, ilvl):
    Some(lvl) => return Some({ lvl, origin: SourceAbstract })
    None => ()
  // numStyleLink follow-up
  match abs.num_style_link:
    Some(style_id) =>
      match self.find_abstract_by_style_link(style_id):
        Some(linked) =>
          match self.find_lvl(linked.lvls, ilvl):
            Some(lvl) => Some({ lvl, origin: SourceLinkedAbstract })
            None => None
        None => None
    None => None
```

`find_abstract_by_style_link(style_id)` scans every AbstractNum and
returns the first whose `style_link` equals `style_id`. The lookup is
small (numbering documents typically have <20 abstract nums) so a
linear scan is fine; if it becomes a hot path, a secondary
HashMap keyed by `style_link` can be added.

## NumFormat::format

Eleven formats. Decimal / decimalZero are arithmetic. Roman uses the
standard subtractive notation up to MMMM = 4000 (Excel/Word limit).
Letter uses A..Z then AA..ZZ in a 26-letter base (1 → A, 27 → AA).
Ordinal uses "1st / 2nd / 3rd / Nth". CardinalText / OrdinalText
cover 1..20 with a fall-back to decimal for higher numbers (Word's
actual behaviour). Bullet returns the lvl_text glyph unchanged so the
caller can drop it through. None returns the empty string.

## format_lvl_text

Walk the template; on `%N` (N = ASCII digit 1..9), substitute the
formatted counter for that level (1-based per §17.9.11). Counters
beyond the supplied array yield literal `%N`. Escaped `%%` collapses
to literal `%`.

## SHALLOW resolution

`types.mbt` carries `NumFormat::from_attr` (11-arm),
`NumFormat::format` (per-format branch), `LvlJustification::from_attr`,
`LvlSuffix::from_attr`, `MultiLevelType::from_attr`, and
`Lvl::has_pic_bullet`. Each is >4 lines so SHALLOW gate is satisfied.

## Test plan

- decode_lvl: full attribute set returns typed Lvl.
- decode_abstract_num: parses lvls and style links.
- decode_num: parses abstractNumId + lvlOverrides.
- resolve_level: direct abstract lookup.
- resolve_level: lvlOverride wins.
- resolve_level: numStyleLink follow.
- NumFormat::format: decimal / upperRoman / lowerLetter spot checks.
- format_lvl_text: `%1.%2.` template against counters [3, 5] → "3.5.".
