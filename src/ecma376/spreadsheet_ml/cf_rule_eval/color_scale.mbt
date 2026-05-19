///|
/// Part 1 §18.3.1.11 cfvo — resolve a single cfvo threshold against
/// the supplied numeric population. `min` and `max` look at the
/// population extrema; `num` is the literal numeric value; `percent`
/// maps `0..100` linearly into `[min, max]`; `percentile` uses the
/// `percentile` helper (PERCENTILE.INC); `formula` is parsed as a
/// literal double for the v1 evaluator (a TODO in the design file
/// notes that full formula evaluation remains future work).
fn resolve_cfvo_value(
  cfvo : CfvoThreshold,
  numeric_population : Array[Double],
) -> Double {
  match cfvo.kind {
    CfvoMin => array_min_or_zero(numeric_population)
    CfvoMax => array_max_or_zero(numeric_population)
    CfvoNum => parse_double_lenient_or_zero(cfvo.value_text)
    CfvoFormula => parse_double_lenient_or_zero(cfvo.value_text)
    CfvoPercent => {
      let pct = parse_double_lenient_or_zero(cfvo.value_text)
      let lo = array_min_or_zero(numeric_population)
      let hi = array_max_or_zero(numeric_population)
      lo + (hi - lo) * (pct / 100.0)
    }
    CfvoPercentile =>
      percentile(
        numeric_population,
        parse_double_lenient_or_zero(cfvo.value_text) / 100.0,
      )
  }
}

///|
fn parse_double_lenient_or_zero(text : String?) -> Double {
  match text {
    Some(value) =>
      match parse_double_lenient(value) {
        Some(n) => n
        None => 0.0
      }
    None => 0.0
  }
}

///|
fn array_min_or_zero(values : Array[Double]) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  let mut acc = values[0]
  for v in values {
    if v < acc {
      acc = v
    }
  }
  acc
}

///|
fn array_max_or_zero(values : Array[Double]) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  let mut acc = values[0]
  for v in values {
    if v > acc {
      acc = v
    }
  }
  acc
}

///|
/// Part 1 §18.3.1.16 colorScale — interpolate a cell value's ARGB
/// from the cfvo thresholds and matching colors. Stops are scanned in
/// order; the cell's numeric value is placed into the segment that
/// contains it and the channels are mixed linearly with the segment
/// progress (0..1). Returns None when the cell carries no numeric
/// value (e.g. text or error), matching Excel's behaviour of
/// suppressing the scale color for non-numeric cells.
pub fn evaluate_color_scale(
  scale : CfColorScale,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> CfArgb? {
  let cell_number = match to_number_opt(cell) {
    Some(n) => n
    None => return None
  }
  let numbers = collect_numbers(population)
  let resolved : Array[Double] = []
  for cfvo in scale.thresholds {
    resolved.push(resolve_cfvo_value(cfvo, numbers))
  }
  if cell_number <= resolved[0] {
    return Some(scale.colors[0])
  }
  let last_index = resolved.length() - 1
  if cell_number >= resolved[last_index] {
    return Some(scale.colors[last_index])
  }
  for i in 0..<last_index {
    let lo = resolved[i]
    let hi = resolved[i + 1]
    if cell_number >= lo && cell_number <= hi {
      let span = hi - lo
      let progress = if span == 0.0 { 0.0 } else { (cell_number - lo) / span }
      return Some(blend_argb(scale.colors[i], scale.colors[i + 1], progress))
    }
  }
  Some(scale.colors[last_index])
}

///|
/// Part 1 §18.3.1.28 dataBar — bar fill ratio (0..1) of a cell value
/// relative to the min/max cfvo thresholds. Returns None when the
/// cell is non-numeric. Values below min collapse to 0, above max
/// saturate at 1, matching Excel's data bar rendering.
pub fn evaluate_bar_ratio(
  bar : CfDataBar,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Double? {
  let cell_number = match to_number_opt(cell) {
    Some(n) => n
    None => return None
  }
  let numbers = collect_numbers(population)
  let lo = resolve_cfvo_value(bar.min_threshold, numbers)
  let hi = resolve_cfvo_value(bar.max_threshold, numbers)
  if cell_number <= lo {
    return Some(0.0)
  }
  if cell_number >= hi {
    return Some(1.0)
  }
  let span = hi - lo
  if span == 0.0 {
    Some(0.0)
  } else {
    Some((cell_number - lo) / span)
  }
}

///|
/// Part 1 §18.3.1.49 iconSet — pick an icon bucket (0..thresholds-1)
/// for a numeric cell value. The thresholds are sorted ascending
/// after resolution, so the lowest icon is bucket 0; when @reverse is
/// true the bucket index is flipped so the highest icon becomes 0.
pub fn evaluate_icon_bucket(
  icon_set : CfIconSet,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Int? {
  let cell_number = match to_number_opt(cell) {
    Some(n) => n
    None => return None
  }
  let numbers = collect_numbers(population)
  let resolved : Array[Double] = []
  for cfvo in icon_set.thresholds {
    resolved.push(resolve_cfvo_value(cfvo, numbers))
  }
  let mut bucket = 0
  for i in 0..<resolved.length() {
    if cell_number >= resolved[i] {
      bucket = i
    }
  }
  let final_bucket = if icon_set.reverse {
    resolved.length() - 1 - bucket
  } else {
    bucket
  }
  Some(final_bucket)
}

///|
fn blend_argb(a : CfArgb, b : CfArgb, progress : Double) -> CfArgb {
  let p = if progress < 0.0 {
    0.0
  } else if progress > 1.0 {
    1.0
  } else {
    progress
  }
  CfArgb::new(
    blend_channel(a.alpha, b.alpha, p),
    blend_channel(a.red, b.red, p),
    blend_channel(a.green, b.green, p),
    blend_channel(a.blue, b.blue, p),
  )
}

///|
fn blend_channel(lo : Int, hi : Int, progress : Double) -> Int {
  let lo_d = lo.to_double()
  let hi_d = hi.to_double()
  (lo_d + (hi_d - lo_d) * progress).to_int()
}
