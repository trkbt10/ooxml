# Evaluator rename + domain typing プロトコル

## 目的

仕様 (ECMA-376) で `ST_X` / `CT_X` と定義された型は、実装上もその名前で
存在しなければならない。現状 G6/G7/G9/G13/G14/G15 の evaluator パッケージ
が独自命名 (CfType / Placeholder / NumFormat 等) を使っていて違反。
同時に domain には `pub struct CT_X { element : @xml.Element }` の空 wrapper
が同名で居て、2つの実装が並列している。

これを一括是正:
1. evaluator の typed type を仕様の ST_/CT_ 名に rename。
2. domain 側の同名 wrapper を削除し、evaluator の typed view を **domain に
   move** する。
3. evaluator 側は decoder/evaluator/runtime types のみ持つ。
4. caller を全て追従。typealias / re-export 救済 禁止。

## 手順 (1 evaluator package あたり)

1. evaluator の types.mbt を読む。
2. 仕様 ST_*/CT_* マッピングを確認 (各 plan file 参照)。
3. evaluator の type definitions を `src/ecma376/<MLkid>/domain/` の対応
   ファイル (新規 or 既存) に **move**、struct/enum name を ST_*/CT_* に
   rename。
4. 既存の domain wrapper (`pub struct CT_X { element : @xml.Element }`) を
   削除。
5. evaluator は decoder/evaluator/runtime context のみ保持。型は `@domain.CT_X`
   から import。
6. caller (reader/builder/wbtest/外部) を全部追従。
7. moon check / moon test / drift gate 全 green。
8. 1 commit per evaluator package。

## 検証

- typealias 救済ゼロ: `grep -rn '^pub typealias' src/` で旧名 alias が出ない
- domain wrapper 削除: `grep -n "^pub.*struct CT_<X> {$" src/ecma376/<ml>/domain/`
  が evaluator 移植後の typed struct のみ
- caller 全更新: build error なし
- drift gate PASS
