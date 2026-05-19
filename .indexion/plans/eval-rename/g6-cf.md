# G6 cf_rule_eval rename mapping

仕様準拠 (Part 1 §18.18 / §18.3.1) で評価器命名を正す。

## Type renames (in-place)

| 現在 | 仕様準拠名 | §-anchor |
|---|---|---|
| CfType | ST_CfType | §18.18.12 |
| CfOperator | ST_ConditionalFormattingOperator | §18.18.15 |
| TimePeriod | ST_TimePeriod | §18.18.82 |
| CfvoType | ST_CfvoType | §18.18.13 |
| CfvoThreshold | CT_Cfvo | §18.3.1.11 |
| CfArgb | CT_Color (CT_Color w/ ARGB-only carrier) | §18.3.1.15 |
| CfColorScale | CT_ColorScale | §18.3.1.16 |
| CfDataBar | CT_DataBar | §18.3.1.28 |
| CfIconSet | CT_IconSet | §18.3.1.49 |
| CfRule | CT_CfRule | §18.3.1.10 |
| CfBlock | CT_ConditionalFormatting | §18.3.1.18 |

## Spec-only (evaluator runtime, no spec equivalent)

これらは spec に対応せず "evaluator-internal" なので prefix 'Cf' を残す:
- CfEvalContext (実行時 context, spec なし)
- CfHit (実行結果)
- LevelOrigin (ない、spec 用語ではない)

ただしユーザ大方針は spec 準拠なので、これらも `Cf` prefix を削って
`EvalContext`, `MatchHit`, `MatchOrigin` 等 spec-neutral 名に。

## Conflict: 既存 @domain.CT_CfRule / CT_ConditionalFormatting / CT_ColorScale
/ CT_DataBar / CT_IconSet / CT_Cfvo / CT_Color が存在 (element wrapper stub)

解決方針: domain stub を削除し、evaluator の typed view を `@domain` 名前空間
に統合する。これは #19 (CT_ wrapper in-place 型化) の先取り。具体的には:
- domain stub `pub struct CT_CfRule { element : @xml.Element }` を削除
- evaluator の typed `CT_CfRule { cf_type, dxf_id, priority, ... }` を
  cf_rule_eval から domain に "publish" し、cf_rule_eval は decoder/evaluator
  のみ持つ
- もしくは domain stub は残しつつ cf_rule_eval を `@domain` の wrapper として
  典型 attribute fields に置換 (in-place 型化)

最小衝突: domain stub を消し、cf_rule_eval を decoder package として
保ち、CT_* は domain に re-locate する。
