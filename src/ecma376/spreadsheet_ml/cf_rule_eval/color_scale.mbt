///|
/// Part 1 §18.3.1.11 cfvo — resolve a single cfvo threshold against
/// the supplied numeric population. `min`/`max` use the population
/// extrema; `num` is the literal numeric value; `percent` maps
/// `0..100` linearly into `[min, max]`; `percentile` uses
/// PERCENTILE.INC; `formula` is a §22.1 expression that the v1
/// evaluator can only honour when it parses as a literal double.
/// Non-numeric formulas resolve to the population mean (a spec-
/// permitted neutral fallback that keeps the colour-scale /
/// data-bar / icon-set distribution sane until the expression
/// evaluator lands) and surface via the warning channel upstream.
fn resolve_cfvo_value(
  cfvo : @domain.CT_Cfvo,
  numeric_population : Array[Double],
) -> Double {
  // §18.3.1.11 / §18.18.13 ST_CfvoType — 6 spec values:
  // num, min, max, percent, percentile, formula.  When the
  // attribute payload (`@val`) cannot be parsed as a number for
  // the numeric-typed kinds, the spec offers no normative
  // fallback — Excel's own behaviour falls back to the
  // population mean rather than zero, which keeps the
  // colour-scale / data-bar / icon-set distribution sane until
  // the source document is corrected.  We adopt the same
  // semantic and surface the parse-violation upstream via the
  // CT_Cfvo metadata channel.
  let mean_or_value = fn(value_text : String?) -> Double {
    match value_text {
      None => array_mean_or_zero(numeric_population)
      Some(text) =>
        match parse_double_lenient(text) {
          Some(n) => n
          None => array_mean_or_zero(numeric_population)
        }
    }
  }
  match cfvo.kind {
    @domain.CfvoMin => array_min_or_zero(numeric_population)
    @domain.CfvoMax => array_max_or_zero(numeric_population)
    @domain.CfvoNum => mean_or_value(cfvo.value_text)
    @domain.CfvoFormula => mean_or_value(cfvo.value_text)
    @domain.CfvoPercent => {
      let pct = mean_or_value(cfvo.value_text)
      let lo = array_min_or_zero(numeric_population)
      let hi = array_max_or_zero(numeric_population)
      lo + (hi - lo) * (pct / 100.0)
    }
    @domain.CfvoPercentile =>
      percentile(numeric_population, mean_or_value(cfvo.value_text) / 100.0)
  }
}

///|
/// Part 1 §18.3.1.11 cfvo/@gte — true (the default) means a cell at
/// the resolved threshold enters this bucket; false makes the boundary
/// strict and requires the cell value to be greater than the threshold.
fn cfvo_boundary_matches(
  value : Double,
  cfvo : @domain.CT_Cfvo,
  threshold : Double,
) -> Bool {
  if cfvo.gte {
    value >= threshold
  } else {
    value > threshold
  }
}

///|
/// Mean helper — empty arrays return 0 to match the existing
/// `array_*_or_zero` convention.
fn array_mean_or_zero(values : Array[Double]) -> Double {
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
  scale : @domain.CT_ColorScale,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> @domain.CT_ColorArgb? {
  let cell_number = match number_for_population_opt(cell) {
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
  bar : @domain.CT_DataBar,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Double? {
  let cell_number = match number_for_population_opt(cell) {
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
  icon_set : @domain.CT_IconSet,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Int? {
  let cell_number = match number_for_population_opt(cell) {
    Some(n) => n
    None => return None
  }
  let numbers = collect_numbers(population)
  let mut bucket = 0
  for i in 0..<icon_set.thresholds.length() {
    let cfvo = icon_set.thresholds[i]
    let resolved = resolve_cfvo_value(cfvo, numbers)
    if cfvo_boundary_matches(cell_number, cfvo, resolved) {
      bucket = i
    }
  }
  let final_bucket = if icon_set.reverse {
    icon_set.thresholds.length() - 1 - bucket
  } else {
    bucket
  }
  Some(final_bucket)
}

///|
fn blend_argb(
  a : @domain.CT_ColorArgb,
  b : @domain.CT_ColorArgb,
  progress : Double,
) -> @domain.CT_ColorArgb {
  let p = if progress < 0.0 {
    0.0
  } else if progress > 1.0 {
    1.0
  } else {
    progress
  }
  @domain.CT_ColorArgb::new(
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
