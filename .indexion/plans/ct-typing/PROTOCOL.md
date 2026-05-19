# CT_ wrapper in-place 型化 プロトコル

## 大方針 (絶対遵守)

**仕様は通すものではなく束縛されるもの**。

`pub struct CT_X { element : @xml.Element }` という element-only wrapper は
**「実装できていない」状態**。仕様 (ECMA-376) は CT_X の各 attribute と
child element を定義しており、それらが typed fields として struct に
存在しなければ仕様準拠ではない。

drift gate「PASS」は vocab 一致しか見ていないので element-only wrapper を
見逃す。本プロトコルが対象とする `pub struct CT_X { element : @xml.Element }`
パターンは「PASS と表示されていても実装できていない箇所」を指す。

**軽微なズレ・少件数の SPEC_ONLY / SHALLOW も「実装できていない」と認識する。
PASS 判定とは無関係に、対象 wrapper を一つでも見逃したら不合格。**

## 「下駄」とは

```moonbit
pub(all) struct CT_FooBar {
  element : @xml.Element     // ← spec attribute/child elements がないことが下駄
} derive(Eq, Debug)

pub fn CT_FooBar::new(element : @xml.Element) -> CT_FooBar {
  { element, }
}
```

これを以下の typed struct に置換:

```moonbit
/// XSD complex type CT_FooBar — Part 1 §N.N.N.N.
pub(all) struct CT_FooBar {
  /// @attr1 (xsd:int)
  attr1 : Int
  /// @attr2 (ST_FooEnum)
  attr2 : ST_FooEnum?
  /// <child1> (CT_Child) — optional
  child1 : CT_Child?
  /// <child2>* (zero or more)
  child2 : Array[CT_Child2]
  /// Preserve source element for builder round-trip if necessary
  // (optional — only if writer needs raw round-trip)
}

pub fn CT_FooBar::new(element : @xml.Element) -> CT_FooBar raise SchemaViolation {
  let attr1 = parse_required_int(element, "attr1", "CT_FooBar/@attr1")
  let attr2 = match attr(element, "attr2") {
    Some(v) => Some(ST_FooEnum::from_attr(v))
    None => None
  }
  let child1 = first_child(element, "child1").map(CT_Child::new)
  let child2 = children(element, "child2").map(CT_Child2::new)
  { attr1, attr2, child1, child2 }
}

pub fn CT_FooBar::to_element(self : CT_FooBar) -> @xml.Element {
  // build @xml.Element from typed fields
  ...
}
```

## 置換手順 (1 CT_X あたり)

1. **仕様セクションを引く** — `references/spec/part1/part1.full.txt` から
   `grep -n "^.*CT_X\b"` で XSD definition (`xsd:complexType name="CT_X"`)
   と prose 説明を発見。
2. **attribute list と child element list を抽出** — XSD prose の table
   から正確に読む。spec が示す attribute optional / required と type を
   typed field の `Option` / 非 Option / Array に反映。
3. **typed struct に書き換え** — `element : @xml.Element` を削除し、attribute
   ごとの typed field を追加。
4. **doc comment 1行目に §-anchor 必須** — `XSD complex type CT_X — Part 1 §N.N.N.N`。
5. **`new` decoder を typed parsing に書き換え** — 各 attribute / child を
   parse、不正値は `SchemaViolation` で reject。
6. **`to_element` writer を typed fields から構築** — round-trip 必須。
7. **caller (reader/builder/wbtest/外部) を typed accessor 経由に追従**。

## 厳格仕様検証ルール

- 各 attribute を一個も落とさない (XSD の `xsd:attribute name="..."` を
  すべて拾う)。
- 各 child element を一個も落とさない (`xsd:element name="..." minOccurs/maxOccurs`)。
- minOccurs=0 → `Option`, maxOccurs="unbounded" → `Array`、デフォルトの
  場合は非 Option。
- `pub typealias` で旧名を残す救済策禁止。
- type alias / re-export 禁止。
- 「動く」「pass する」を目標にしない。「仕様通りに書く」のみ。

## 検証コマンド

```bash
# (1) 担当パッケージ内に element-only wrapper が残っていないこと
python3 << 'PY'
import re, glob
ok = True
for path in glob.glob('src/ecma376/<pkg>/**/*.mbt', recursive=True):
    if '_wbtest' in path or 'pkg.generated' in path: continue
    with open(path) as f: text = f.read()
    for m in re.finditer(r'^(pub(\(all\))?)\s+struct\s+(CT_[A-Za-z0-9_]+)\s*\{([^}]*)\}', text, re.MULTILINE):
        body = m.group(4).strip()
        fields = [ln.strip().rstrip(',') for ln in body.split('\n') if ln.strip() and not ln.strip().startswith('//')]
        if len(fields) == 1 and 'element : @xml.Element' in fields[0]:
            print(f'下駄残存: {m.group(3)} at {path}')
            ok = False
print('OK' if ok else 'FAIL')
PY

# (2) ビルド
moon check --target native
moon check --target wasm-gc
moon fmt
moon info

# (3) テスト
moon test --target native

# (4) Drift gate
.kiro/scripts/drift.sh --pkg ecma376/<pkg>
# 期待: 0 drifted / 0 spec_only / 0 shallow
```

## 並列化方針

ML chapter ごとに sub-agent。各 sub-agent は worktree 内で当該パッケージ
のみを変更。完了時に 1 commit で main へ取り込む。

## 完了条件

- 対象パッケージ内の element-only wrapper = 0 件
- moon check / moon test 全 green
- drift gate (担当パッケージ) **PASS かつ drifted=0 / spec_only=0 / shallow=0**
- 1 commit per sub-agent
