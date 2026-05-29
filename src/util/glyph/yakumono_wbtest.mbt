// Tests for JIS X 4051 約物 (punctuation) aki classification.

///|
test "yakumono_aki: opening brackets carry a LEFT aki" {
  for c in "（［｛「『【〔〈《".iter() {
    assert_true(yakumono_aki(c) == Left)
  }
}

///|
test "yakumono_aki: closing brackets carry a RIGHT aki" {
  for c in "）］｝」』】〕〉》".iter() {
    assert_true(yakumono_aki(c) == Right)
  }
}

///|
test "yakumono_aki: 句読点 carry a RIGHT aki" {
  for c in "。、．，".iter() {
    assert_true(yakumono_aki(c) == Right)
  }
}

///|
test "yakumono_aki: 中点類 carry aki on BOTH sides" {
  for c in "・：；".iter() {
    assert_true(yakumono_aki(c) == Both)
  }
}

///|
test "yakumono_aki: ordinary characters have no aki" {
  for c in "日本語あいうABC123".iter() {
    assert_true(yakumono_aki(c) == NoAki)
    assert_true(!is_yakumono(c))
  }
}

///|
test "is_yakumono: true for punctuation, false otherwise" {
  assert_true(is_yakumono('。'))
  assert_true(is_yakumono('「'))
  assert_true(is_yakumono('・'))
  assert_true(!is_yakumono('字'))
}
