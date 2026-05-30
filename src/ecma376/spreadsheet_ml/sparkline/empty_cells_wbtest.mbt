// §[MS-XLSX] 2.6.5 displayEmptyCellsAs — empty (NaN) data points are
// resolved per the group policy before the glyph renderer runs.

///|
test "EmptyZero replaces gaps with zero" {
  let out = apply_empty_cells([1.0, Double::nan(), 3.0], EmptyZero)
  assert_eq(out[0], 1.0)
  assert_eq(out[1], 0.0)
  assert_eq(out[2], 3.0)
}

///|
test "EmptyGap preserves the NaN gap for the renderer to skip" {
  let out = apply_empty_cells([1.0, Double::nan(), 3.0], EmptyGap)
  assert_eq(out[0], 1.0)
  assert_true(out[1].is_nan())
  assert_eq(out[2], 3.0)
}

///|
test "EmptySpan linearly interpolates an interior gap" {
  let out = apply_empty_cells([1.0, Double::nan(), 3.0], EmptySpan)
  // Midpoint of 1 and 3.
  assert_eq(out[1], 2.0)
  // A two-wide gap interpolates evenly.
  let out2 = apply_empty_cells(
    [0.0, Double::nan(), Double::nan(), 3.0],
    EmptySpan,
  )
  assert_eq(out2[1], 1.0)
  assert_eq(out2[2], 2.0)
}

///|
test "EmptySpan clamps leading and trailing gaps to the nearest value" {
  let out = apply_empty_cells(
    [Double::nan(), 2.0, Double::nan()],
    EmptySpan,
  )
  assert_eq(out[0], 2.0) // leading clamps to first finite
  assert_eq(out[1], 2.0)
  assert_eq(out[2], 2.0) // trailing clamps to last finite
}

///|
test "EmptySpan on an all-empty series collapses to zeros" {
  let out = apply_empty_cells(
    [Double::nan(), Double::nan()],
    EmptySpan,
  )
  assert_eq(out[0], 0.0)
  assert_eq(out[1], 0.0)
}

///|
test "apply_empty_cells leaves gap-free data untouched" {
  let out = apply_empty_cells([1.0, 2.0, 3.0], EmptyGap)
  assert_eq(out.length(), 3)
  assert_eq(out[2], 3.0)
}
