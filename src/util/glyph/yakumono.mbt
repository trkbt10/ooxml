// JIS X 4051 約物 (yakumono — punctuation) spacing classification.
//
// JIS X 4051 §4.x models Japanese punctuation as occupying a full
// em-square cell in which the ink sits in one half, leaving a half-em
// 空き (aki) in the other:
//
//   * 始め括弧類 (cl-01, opening brackets （「『【〔《…): ink in the
//     RIGHT half → a trimmable half-em aki on the LEFT.
//   * 終わり括弧類 (cl-02, closing brackets ）」』】〕》…): ink in the
//     LEFT half → a trimmable half-em aki on the RIGHT.
//   * 句点・読点 (cl-06/07, 。、．，): ink in the LEFT half → a
//     trimmable half-em aki on the RIGHT.
//   * 中点類 (cl-05, ・：；): ink centred → a quarter-em aki on BOTH
//     sides.
//
// This module is the single source of truth for THOSE CLASSES.  It
// deliberately does NOT decide how much aki to trim at a given
// position: correct trimming (CSS `text-spacing-trim`) is font-metric
// dependent — it must compare the glyph's real advance against the em
// to know whether the aki is physically present — and is layered on
// top of this classification, not encoded here.  The line-EDGE aki
// rules (no aki before a line-leading closing mark / after a
// line-trailing opening mark) are already enforced structurally by the
// kinsoku break logic in kinsoku.mbt.

///|
/// Aki side of a 約物 character: which half-cell carries the trimmable
/// empty space.
pub(all) enum YakumonoAki {
  /// No trimmable aki (not a spacing 約物).
  NoAki
  /// Half-em aki on the left of the glyph (始め括弧類).
  Left
  /// Half-em aki on the right of the glyph (終わり括弧類 / 句読点).
  Right
  /// Quarter-em aki on both sides (中点類).
  Both
} derive(Eq, Debug)

///|
/// Classify `c` into its JIS X 4051 約物 aki class (see the file
/// header).  Non-punctuation and punctuation without trimmable aki
/// return `YakumonoAki::NoAki`.
pub fn yakumono_aki(c : Char) -> YakumonoAki {
  let cp = c.to_int()
  // 始め括弧類 (cl-01) — ink right, aki LEFT.
  if cp == 0xFF08 || // （
    cp == 0xFF3B || // ［
    cp == 0xFF5B || // ｛
    cp == 0x300C || // 「
    cp == 0x300E || // 『
    cp == 0x3010 || // 【
    cp == 0x3014 || // 〔
    cp == 0x3008 || // 〈
    cp == 0x300A || // 《
    cp == 0x3016 || // 〖
    cp == 0x3018 || // 〘
    cp == 0x301A {
    // 〚
    return Left
  }
  // 終わり括弧類 (cl-02) — ink left, aki RIGHT.
  if cp == 0xFF09 || // ）
    cp == 0xFF3D || // ］
    cp == 0xFF5D || // ｝
    cp == 0x300D || // 」
    cp == 0x300F || // 』
    cp == 0x3011 || // 】
    cp == 0x3015 || // 〕
    cp == 0x3009 || // 〉
    cp == 0x300B || // 》
    cp == 0x3017 || // 〗
    cp == 0x3019 || // 〙
    cp == 0x301B {
    // 〛
    return Right
  }
  // 句点・読点 (cl-06/07) — ink left, aki RIGHT.
  if cp == 0x3002 || // 。
    cp == 0x3001 || // 、
    cp == 0xFF0E || // ．
    cp == 0xFF0C {
    // ，
    return Right
  }
  // 中点類 (cl-05) — ink centred, quarter-em aki BOTH sides.
  if cp == 0x30FB || // ・
    cp == 0xFF1A || // ：
    cp == 0xFF1B {
    // ；
    return Both
  }
  NoAki
}

///|
/// True when `c` is a 約物 with a trimmable aki (any class other than
/// `NoAki`).
pub fn is_yakumono(c : Char) -> Bool {
  yakumono_aki(c) != NoAki
}
