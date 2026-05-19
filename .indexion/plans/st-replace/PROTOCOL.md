# ST_ 下駄置換プロトコル

## 大方針

仕様は **通すものではなく束縛されるもの**。`pub struct ST_X { value : String }` の
下駄ラッパが残っている限り、コードは仕様に従っていない (型情報の精度が
落ちている)。本プロトコルはそれらを一切例外なく仕様で定義された typed 表現に
置換する作業の手順を定める。

## 「下駄」とは

```moonbit
pub struct ST_BrType {
  value : String          // ← 仕様は 'page|column|textWrapping' の3値enum、これは下駄
} derive(Eq, Debug)

pub fn ST_BrType::parse(s : String) -> ST_BrType raise SchemaViolation {
  validate_wml_simple_type("ST_BrType", s)
  { value: s }                                              // ← 制約検査せず素通し
}
```

仕様で **enum** / **numeric** / **union** が定義されている ST_X に対し、

- `{ value : String }` で String を素持ち
- `parse(s)` で lexical 制約を呼ぶだけで pattern matching しない
- `to_string(self)` で `self.value` をそのまま返す

の組み合わせを「下駄」と呼ぶ。

## 置換の原則

1. **下駄を取り除く**。`{ value : String }` を仕様の真の表現 (`pub(all) enum
   ST_X { ... }` / `pub struct ST_X { N : Int }` / `pub enum ST_X { A(...);
   B(...) }`) に in-place で置き換える。`pub typealias` で旧名を残すような救済
   は禁止。
2. **仕様セクションを必ず引く**。`references/spec/part1/part1.full.txt` から
   §N.N.N の definition を読み、enumeration values / lexical constraint / base
   type を抽出してコードに反映。
3. **doc comment に §-anchor を残す**。"XSD simple type ST_X — Part 1 §N.N.N"
   形式で1行目に書く (drift gate vocab 一致のため必須)。
4. **`new` / `parse` のシグネチャは仕様準拠**。`raise SchemaViolation`
   は spec が制約を持つ型のみ。制約なし `xsd:string` は `raise` なし。
5. **`to_string` は canonical lexical form を返す**。`new` の入力と一致するとは
   限らないが、再度 `new` できることは保証。
6. **wbtest は typed accessor 経由で書く**。round-trip テストではなく、内部値
   の検査をする。

## 一品目の作業手順

1. リスト (.indexion/plans/st-replace/lists/<pkg>.txt) から 1 ST_ を選ぶ。
2. `references/spec/part1/part1.full.txt` から §-section を grep し、
   enumeration / restriction / union / base type を読む。
3. 仕様の真の型を決定 (enum / struct / typed union)。
4. 既存の `pub struct ST_X { value : String }` を rewrite。
5. caller (reader/builder/wbtest/他 evaluator) を新型に追従させる。
6. `moon check --target native` 0 errors を保つ。
7. wbtest を typed accessor 経由で書き直す。
8. `moon test --target native -p trkbt10/ooxml/<pkg>` all green を保つ。

## 並列化方針

各 sub-agent はパッケージ単位で worktree に作業し、当該パッケージ
ディレクトリ内 (`.mbt` + `pkg.generated.mbti`) のみ変更可。caller を別パッケージ
で持つ場合、その caller も変更可だが、新型化が caller 側に波及して別パッケージ
の振る舞いを変えないことを `moon test` で必ず検証する。

完了条件:
- リストの全 ST_ が typed (下駄ゼロ)。
- `.kiro/scripts/drift.sh --pkg <package>` PASS。
- `moon test --target native` 全テスト green。
- single commit per sub-agent。

## 検証スクリプト

下駄が残っていないことを確認:

```bash
grep -B1 -A3 "^pub struct ST_" src/ecma376/<pkg>/*.mbt | grep -B3 "value : String"
```

出力が空なら下駄ゼロ。
