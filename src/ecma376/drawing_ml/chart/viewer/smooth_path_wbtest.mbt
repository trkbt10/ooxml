// §21.2.2.220 `<c:smooth>` / §21.2.2.181 ST_ScatterStyle — the shared
// Catmull-Rom spline builder used by the line chart and the scatter
// chart.  A smoothed series must emit a cubic-Bezier `<path>` (M…C…),
// not a straight polyline.

///|
/// Count occurrences of `needle` in `s`.
fn smooth_count_substr(s : String, needle : String) -> Int {
  let mut count = 0
  let mut idx = 0
  let nlen = needle.length()
  while idx + nlen <= s.length() {
    if s[idx:idx + nlen].to_owned() == needle {
      count = count + 1
      idx = idx + nlen
    } else {
      idx = idx + 1
    }
  }
  count
}

///|
test "catmull_rom_path needs at least two points" {
  // Degenerate inputs produce no path (caller falls back to markers).
  assert_eq(catmull_rom_path([]), "")
  assert_eq(catmull_rom_path([(0.0, 0.0)]), "")
}

///|
test "catmull_rom_path emits one cubic segment per interval" {
  // Three points → a single "M" move plus two "C" cubic segments
  // (n-1 intervals).  This is the curve a smoothMarker scatter or a
  // <c:smooth> line series now renders instead of straight segments.
  let d = catmull_rom_path([(0.0, 0.0), (10.0, 10.0), (20.0, 0.0)])
  assert_eq(d.unsafe_substring(start=0, end=1), "M")
  assert_eq(smooth_count_substr(d, " C"), 2)
  // Four points → three cubic segments.
  let d4 = catmull_rom_path([
    (0.0, 0.0),
    (10.0, 10.0),
    (20.0, 0.0),
    (30.0, 10.0),
  ])
  assert_eq(smooth_count_substr(d4, " C"), 3)
}
