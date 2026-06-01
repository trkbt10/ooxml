///|
test "catalog verification outcome ranking keeps parsed above open-fail" {
  assert_eq(verification_outcome_rank("rendered"), 4)
  assert_eq(verification_outcome_rank("parsed"), 3)
  assert_eq(verification_outcome_rank("render-crash"), 2)
  assert_eq(verification_outcome_rank("open-fail"), 1)
  assert_true(verification_outcome_is_stronger("parsed", "open-fail"))
  assert_true(verification_outcome_is_stronger("rendered", "parsed"))
  assert_false(verification_outcome_is_stronger("open-fail", "parsed"))
}
