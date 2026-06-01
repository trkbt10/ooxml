///|
/// Ranking used only to choose among alternative containment ancestry
/// candidates for one catalog target.  The verdict strings themselves
/// remain owned by `verify_entry`; this helper keeps the "strongest
/// usable candidate" policy in one place.
fn verification_outcome_rank(outcome : String) -> Int {
  match outcome {
    "rendered" => 4
    "parsed" => 3
    "render-crash" => 2
    "open-fail" => 1
    _ => 0
  }
}

///|
fn verification_outcome_is_stronger(next : String, current : String) -> Bool {
  verification_outcome_rank(next) > verification_outcome_rank(current)
}
