// Tests for 和欧間隔 (inter-script spacing) — ECMA-376 autoSpaceDE/DN,
// JIS X 4051 §4.3 四分アキ.

///|
test "inter_script_space_em: kanji↔Latin letter gets a quarter em" {
  inspect(inter_script_space_em('語', 'A'), content="0.25")
  inspect(inter_script_space_em('A', '語'), content="0.25")
}

///|
test "inter_script_space_em: kana↔digit gets a quarter em" {
  inspect(inter_script_space_em('あ', '3'), content="0.25")
  inspect(inter_script_space_em('7', 'ア'), content="0.25")
}

///|
test "inter_script_space_em: no gap within the same script" {
  inspect(inter_script_space_em('日', '本'), content="0")
  inspect(inter_script_space_em('A', 'B'), content="0")
  inspect(inter_script_space_em('1', '2'), content="0")
}

///|
test "inter_script_space_em: autoSpaceDE toggle gates letters" {
  inspect(inter_script_space_em('語', 'A', auto_space_de=false), content="0")
  // Digits still spaced when DN remains on.
  inspect(inter_script_space_em('語', '5', auto_space_de=false), content="0.25")
}

///|
test "inter_script_space_em: autoSpaceDN toggle gates digits" {
  inspect(inter_script_space_em('語', '5', auto_space_dn=false), content="0")
  inspect(inter_script_space_em('語', 'A', auto_space_dn=false), content="0.25")
}

///|
test "inter_script_space_em: CJK punctuation is not a spacing trigger" {
  // 。and （ are punctuation classes, not 和欧間隔 East-Asian chars.
  inspect(inter_script_space_em('。', 'A'), content="0")
  inspect(inter_script_space_em('A', '、'), content="0")
}

///|
test "inter_script_advance_px sums internal boundaries" {
  // "語A語" has TWO boundaries (語|A and A|語) → 2 × 0.25 em.
  // At 40pt that is 2 × 0.25 × 40 = 20.0 px.
  inspect(inter_script_advance_px("語A語", font_size_pt=40.0), content="20")
  // Pure Latin / pure Japanese accrue nothing.
  inspect(inter_script_advance_px("ABC", font_size_pt=40.0), content="0")
  inspect(inter_script_advance_px("日本語", font_size_pt=40.0), content="0")
}

///|
test "inter_script_advance_px: realistic mixed string" {
  // "日本語ABC123" — the only East-Asian↔Western boundary is 語|A
  // (C|1 is letter↔digit, both Western → no gap).  One gap at 20pt:
  // 0.25 × 20 = 5.0 px.
  inspect(inter_script_advance_px("日本語ABC123", font_size_pt=20.0), content="5")
}
