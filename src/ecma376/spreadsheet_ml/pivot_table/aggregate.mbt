///|
/// Part 1 §18.18.17 — apply a `DataConsolidateFunction` to a
/// bucket of `@formula.FormulaValue`s, producing the per-cell
/// aggregate the materializer writes to the
/// `PivotResultCell.aggregated_value` slot. The function follows
/// Excel's PivotTable semantics for empty buckets:
///
/// - `Sum`, `Product` — return `VNumber(0.0)` on an empty bucket
///   (Excel displays a blank cell, but renderers test the bucket
///   size separately; emitting `VEmpty` here would lose the
///   distinction between "no records matched" and "every record
///   summed to zero").
/// - `Count`, `CountNums` — return `VNumber(0.0)`.
/// - `Average`, `StdDev`, `StdDevP`, `Var`, `VarP` — return
///   `VError(DivZero)` when the divisor would be zero (Excel
///   surfaces `#DIV/0!`).
/// - `Min`, `Max` — return `VEmpty` when no numeric value is
///   present (matches Excel's behaviour of leaving the cell
///   blank).
pub fn aggregate(
  values : Array[@formula.FormulaValue],
  function : DataConsolidateFunction,
) -> @formula.FormulaValue {
  match function {
    Sum => @formula.VNumber(sum_of_numbers(values))
    Count => @formula.VNumber(count_total(values).to_double())
    CountNums => @formula.VNumber(count_nums(values).to_double())
    Average => aggregate_average(values)
    Max => aggregate_max(values)
    Min => aggregate_min(values)
    Product => @formula.VNumber(product_of_numbers(values))
    StdDev => aggregate_std_dev_sample(values)
    StdDevP => aggregate_std_dev_pop(values)
    Var => aggregate_var_sample(values)
    VarP => aggregate_var_pop(values)
  }
}

///|
/// Sum of every value in the bucket that coerces to a number.
/// Empty bucket → 0.0 per §18.18.17 sum.
fn sum_of_numbers(values : Array[@formula.FormulaValue]) -> Double {
  let mut total = 0.0
  for value in values {
    match coerce_value_to_number(value) {
      Some(n) => total = total + n
      None => ()
    }
  }
  total
}

///|
/// COUNTA semantics — count every non-blank, non-error cell in
/// the bucket. Errors and blanks are excluded; strings count.
fn count_total(values : Array[@formula.FormulaValue]) -> Int {
  let mut count = 0
  for value in values {
    let counts = match value {
      @formula.VEmpty => false
      @formula.VError(_) => false
      _ => true
    }
    if counts {
      count = count + 1
    }
  }
  count
}

///|
/// COUNT semantics — count only the values that successfully
/// coerce to a finite number. Booleans count (TRUE→1, FALSE→0),
/// strings that parse as numbers count, errors do not.
fn count_nums(values : Array[@formula.FormulaValue]) -> Int {
  let mut count = 0
  for value in values {
    match coerce_value_to_number(value) {
      Some(_) => count = count + 1
      None => ()
    }
  }
  count
}

///|
/// Arithmetic mean — Sum / CountNums. Empty bucket → #DIV/0!.
fn aggregate_average(
  values : Array[@formula.FormulaValue],
) -> @formula.FormulaValue {
  let total = sum_of_numbers(values)
  let count = count_nums(values)
  if count == 0 {
    return @formula.VError(@formula.FormulaError::DivZero)
  }
  @formula.VNumber(total / count.to_double())
}

///|
/// Repeated multiplication of every numeric value in the bucket.
/// Empty bucket → 0.0 (matches Excel's PRODUCT behaviour for
/// blank pivot cells; PRODUCT() returns 0 over an empty range).
fn product_of_numbers(values : Array[@formula.FormulaValue]) -> Double {
  let mut acc = 1.0
  let mut count = 0
  for value in values {
    match coerce_value_to_number(value) {
      Some(n) => {
        acc = acc * n
        count = count + 1
      }
      None => ()
    }
  }
  if count == 0 {
    return 0.0
  }
  acc
}

///|
/// Largest numeric value in the bucket. Empty numeric set →
/// VEmpty.
fn aggregate_max(
  values : Array[@formula.FormulaValue],
) -> @formula.FormulaValue {
  let mut current : Double? = None
  for value in values {
    match coerce_value_to_number(value) {
      Some(n) =>
        current = match current {
          Some(best) => if n > best { Some(n) } else { Some(best) }
          None => Some(n)
        }
      None => ()
    }
  }
  match current {
    Some(n) => @formula.VNumber(n)
    None => @formula.VEmpty
  }
}

///|
/// Smallest numeric value in the bucket. Empty numeric set →
/// VEmpty.
fn aggregate_min(
  values : Array[@formula.FormulaValue],
) -> @formula.FormulaValue {
  let mut current : Double? = None
  for value in values {
    match coerce_value_to_number(value) {
      Some(n) =>
        current = match current {
          Some(best) => if n < best { Some(n) } else { Some(best) }
          None => Some(n)
        }
      None => ()
    }
  }
  match current {
    Some(n) => @formula.VNumber(n)
    None => @formula.VEmpty
  }
}

///|
/// Population variance: sum((x - mean)^2) / n. Returns DivZero
/// when n is zero.
fn aggregate_var_pop(
  values : Array[@formula.FormulaValue],
) -> @formula.FormulaValue {
  let numbers = collect_numbers(values)
  let n = numbers.length()
  if n == 0 {
    return @formula.VError(@formula.FormulaError::DivZero)
  }
  let mean_value = mean(numbers)
  let mut acc = 0.0
  for entry in numbers {
    let diff = entry - mean_value
    acc = acc + diff * diff
  }
  @formula.VNumber(acc / n.to_double())
}

///|
/// Sample variance: sum((x - mean)^2) / (n - 1). Returns DivZero
/// for n < 2.
fn aggregate_var_sample(
  values : Array[@formula.FormulaValue],
) -> @formula.FormulaValue {
  let numbers = collect_numbers(values)
  let n = numbers.length()
  if n < 2 {
    return @formula.VError(@formula.FormulaError::DivZero)
  }
  let mean_value = mean(numbers)
  let mut acc = 0.0
  for entry in numbers {
    let diff = entry - mean_value
    acc = acc + diff * diff
  }
  @formula.VNumber(acc / (n - 1).to_double())
}

///|
/// Population standard deviation: sqrt(VarP).
fn aggregate_std_dev_pop(
  values : Array[@formula.FormulaValue],
) -> @formula.FormulaValue {
  match aggregate_var_pop(values) {
    @formula.VNumber(var_value) => @formula.VNumber(var_value.sqrt())
    other => other
  }
}

///|
/// Sample standard deviation: sqrt(Var).
fn aggregate_std_dev_sample(
  values : Array[@formula.FormulaValue],
) -> @formula.FormulaValue {
  match aggregate_var_sample(values) {
    @formula.VNumber(var_value) => @formula.VNumber(var_value.sqrt())
    other => other
  }
}

///|
/// Collect every value in the bucket that coerces to a number into
/// a flat `Array[Double]`. Used by the variance / standard
/// deviation helpers so they share a single numeric-coercion
/// pass.
fn collect_numbers(values : Array[@formula.FormulaValue]) -> Array[Double] {
  let result : Array[Double] = []
  for value in values {
    match coerce_value_to_number(value) {
      Some(n) => result.push(n)
      None => ()
    }
  }
  result
}

///|
/// Arithmetic mean of an already-numeric array. Caller is expected
/// to guarantee `numbers.length() > 0` (the variance helpers gate
/// the call already).
fn mean(numbers : Array[Double]) -> Double {
  let mut total = 0.0
  for entry in numbers {
    total = total + entry
  }
  total / numbers.length().to_double()
}

///|
/// Project a `@formula.FormulaValue` into a `Double` for numeric
/// aggregation. Booleans become 1.0 / 0.0 per the §18.18.17
/// "Count Nums works like COUNT" worksheet-function equivalence;
/// strings that parse as a number are accepted (matches Excel's
/// PivotTable behaviour when a column is mostly numeric but has a
/// few text-formatted entries); errors and blanks return None so
/// the caller can skip them.
pub fn coerce_value_to_number(value : @formula.FormulaValue) -> Double? {
  match value {
    @formula.VNumber(n) => Some(n)
    @formula.VBool(true) => Some(1.0)
    @formula.VBool(false) => Some(0.0)
    @formula.VString(text) => parse_double(text)
    @formula.VEmpty => None
    @formula.VError(_) => None
    @formula.VArray(_) => None
  }
}
