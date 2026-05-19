///|
/// Part 1 §18.18.12 aboveAverage / top10 — collect every numeric cell
/// in a population as a `Double` array. Non-numeric and error cells are
/// excluded per Excel's AVERAGE() / LARGE() conventions cited by
/// §18.18.12 ("equivalent to using the AVERAGE() function").
fn collect_numbers(population : Array[@formula.FormulaValue]) -> Array[Double] {
  let result : Array[Double] = []
  for value in population {
    match to_number_opt(value) {
      Some(n) => if !n.is_nan() { result.push(n) }
      None => ()
    }
  }
  result
}

///|
/// Part 1 §18.18.12 aboveAverage — arithmetic mean of a numeric
/// population. Returns 0.0 when the population is empty so callers can
/// short-circuit on `population.length() == 0`.
fn mean(values : Array[Double]) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  let mut sum = 0.0
  for v in values {
    sum = sum + v
  }
  sum / values.length().to_double()
}

///|
/// Part 1 §18.18.12 aboveAverage with @stdDev — population standard
/// deviation `sqrt(sum((x - mean)^2) / n)`. Uses the population formula
/// (n, not n-1) because the rule treats the supplied range as the
/// entire population, matching Excel's STDEVP semantics.
fn population_std_dev(values : Array[Double], mean_value : Double) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  let mut sum_sq = 0.0
  for v in values {
    let diff = v - mean_value
    sum_sq = sum_sq + diff * diff
  }
  (sum_sq / values.length().to_double()).sqrt()
}

///|
/// Part 1 §18.18.12 top10 — the inclusive threshold value such that
/// "top N" cells are those `>= threshold` (or `<= threshold` for
/// `bottom=true`). Returns None when the population is empty or `n` is
/// non-positive.
fn top_n_threshold(values : Array[Double], n : Int, bottom : Bool) -> Double? {
  if values.length() == 0 || n <= 0 {
    return None
  }
  let sorted = values.copy()
  sorted.sort_by(fn(a, b) {
    if bottom {
      if a < b {
        -1
      } else if a > b {
        1
      } else {
        0
      }
    } else if a > b {
      -1
    } else if a < b {
      1
    } else {
      0
    }
  })
  let rank = if n > sorted.length() { sorted.length() - 1 } else { n - 1 }
  Some(sorted[rank])
}

///|
/// Part 1 §18.18.12 top10 with @percent — clamp the percentage to
/// 1..100, multiply by population size, truncate (Excel's documented
/// behaviour), and floor to at least 1.
fn percent_to_count(percent : Int, population : Int) -> Int {
  let clamped = if percent < 1 {
    1
  } else if percent > 100 {
    100
  } else {
    percent
  }
  let raw = clamped * population / 100
  if raw < 1 {
    1
  } else {
    raw
  }
}

///|
/// Part 1 §18.3.1.11 cfvo type=percentile — linear-interpolation
/// percentile per NIST / Excel PERCENTILE.INC. `p` is a 0..1 fraction.
fn percentile(values : Array[Double], p : Double) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  if values.length() == 1 {
    return values[0]
  }
  let sorted = values.copy()
  sorted.sort_by(fn(a, b) { if a < b { -1 } else if a > b { 1 } else { 0 } })
  let pp = if p < 0.0 { 0.0 } else if p > 1.0 { 1.0 } else { p }
  let rank = pp * (sorted.length() - 1).to_double()
  let lo = rank.to_int()
  let frac = rank - lo.to_double()
  if lo + 1 >= sorted.length() {
    sorted[sorted.length() - 1]
  } else {
    sorted[lo] + (sorted[lo + 1] - sorted[lo]) * frac
  }
}

///|
/// Stable lexical key for a scalar formula value. Numbers and strings
/// are case-folded so `"FOO"`, `"foo"`, and `"Foo"` collide for
/// duplicate detection per §18.18.12.
fn value_key(value : @formula.FormulaValue) -> String {
  match value {
    @formula.VNumber(n) => "n:" + format_number_for_display(n)
    @formula.VBool(true) => "b:1"
    @formula.VBool(false) => "b:0"
    @formula.VString(text) => "s:" + text.to_upper()
    @formula.VError(err) => "e:" + err.to_literal()
    @formula.VEmpty => "0"
    @formula.VArray(_) => "a"
  }
}
