# G13 — tasks

1. `src/ecma376/wordprocessing_ml/numbering_resolver/moon.pkg`:
   import `@hashmap`, `@xml`, `@opc_errors`, `@domain`.
2. `types.mbt` — enums + structs + non-trivial methods (>4 lines).
3. `decode.mbt` — decode_lvl, decode_abstract_num, decode_num,
   decode_numbering, decode_lvl_override + attribute helpers.
4. `resolver.mbt` — NumberingTable::resolve_level,
   NumberingTable::level_for_paragraph, follow_num_style_link.
5. `format_lvl_text.mbt` — format_lvl_text helper.
6. `resolver_wbtest.mbt` — 8 test blocks per design plan.
7. `moon fmt && moon info && moon check --target native && moon test`.
8. `.kiro/scripts/drift.sh --pkg ecma376/wordprocessing_ml --strict`.
9. Commit as `g13-wml-numbering: §17.9 numbering inheritance`.
