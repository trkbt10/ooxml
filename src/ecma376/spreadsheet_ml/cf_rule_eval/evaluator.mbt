///|
/// Part 1 §18.3.1.10 cfRule — apply a single rule to a single cell.
/// Population-aware rules (top10, aboveAverage, duplicate/unique,
/// colorScale, dataBar, iconSet) read the supplied `population` to
/// derive thresholds; cellIs / text predicate / blank / error /
/// timePeriod / expression rules ignore the population.
pub fn evaluate_rule(
  rule : @domain.CT_CfRule,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
  ctx : EvalContext,
) -> Bool {
  match rule.cf_type {
    // §18.3.1.10 — `@type` is `use="optional"`. A type-less rule has
    // no predicate to evaluate, so it never matches any cell.
    None => false
    Some(@domain.CellIs) => evaluate_cellis(rule, cell, ctx)
    Some(@domain.ContainsText) =>
      evaluate_text_predicate(rule, cell, contains_text_match)
    Some(@domain.NotContainsText) =>
      !evaluate_text_predicate(rule, cell, contains_text_match)
    Some(@domain.BeginsWith) =>
      evaluate_text_predicate(rule, cell, begins_with_match)
    Some(@domain.EndsWith) =>
      evaluate_text_predicate(rule, cell, ends_with_match)
    Some(@domain.ContainsBlanks) => is_blank_value(cell)
    Some(@domain.NotContainsBlanks) => !is_blank_value(cell)
    Some(@domain.ContainsErrors) => is_error_value(cell)
    Some(@domain.NotContainsErrors) => !is_error_value(cell)
    Some(@domain.DuplicateValues) => occurrence_of(cell, population) > 1
    Some(@domain.UniqueValues) => occurrence_of(cell, population) == 1
    Some(@domain.Top10) => evaluate_top10(rule, cell, population)
    Some(@domain.AboveAverage) => evaluate_above_average(rule, cell, population)
    Some(@domain.TimePeriod) => evaluate_time_period(rule, cell, ctx)
    Some(@domain.Expression) => evaluate_expression(rule, ctx)
    Some(@domain.ColorScale) | Some(@domain.DataBar) | Some(@domain.IconSet) =>
      match number_for_population_opt(cell) {
        Some(_) => true
        None => false
      }
  }
}

///|
fn contains_text_match(haystack : String, needle : String) -> Bool {
  contains_ci(haystack, needle)
}

///|
fn begins_with_match(haystack : String, needle : String) -> Bool {
  starts_with_ci(haystack, needle)
}

///|
fn ends_with_match(haystack : String, needle : String) -> Bool {
  ends_with_ci(haystack, needle)
}

///|
fn evaluate_text_predicate(
  rule : @domain.CT_CfRule,
  cell : @formula.FormulaValue,
  matcher : (String, String) -> Bool,
) -> Bool {
  let needle = match rule.text {
    Some(text) => text
    None =>
      match rule.formulas.get(0) {
        Some(text) => text
        None => return false
      }
  }
  matcher(to_display_string(cell), needle)
}

///|
fn evaluate_cellis(
  rule : @domain.CT_CfRule,
  cell : @formula.FormulaValue,
  ctx : EvalContext,
) -> Bool {
  let op = match rule.operator {
    Some(o) => o
    None => return false
  }
  let rhs_first = match rule.formulas.get(0) {
    Some(text) => (ctx.evaluate_formula)(text)
    None =>
      match rule.text {
        Some(text) => @formula.VString(text)
        None => return false
      }
  }
  let rhs_second = match rule.formulas.get(1) {
    Some(text) => Some((ctx.evaluate_formula)(text))
    None => None
  }
  cellis_match(cell, op, rhs_first, rhs_second)
}

///|
fn evaluate_top10(
  rule : @domain.CT_CfRule,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Bool {
  let numbers = collect_numbers(population)
  let n_attr = rule.rank.unwrap_or(0)
  let count = if rule.percent {
    percent_to_count(n_attr, numbers.length())
  } else if n_attr > 0 {
    n_attr
  } else {
    return false
  }
  let threshold = match top_n_threshold(numbers, count, rule.bottom) {
    Some(t) => t
    None => return false
  }
  match number_for_population_opt(cell) {
    Some(value) =>
      if rule.bottom {
        value <= threshold
      } else {
        value >= threshold
      }
    None => false
  }
}

///|
fn evaluate_above_average(
  rule : @domain.CT_CfRule,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Bool {
  let numbers = collect_numbers(population)
  if numbers.length() == 0 {
    return false
  }
  let avg = mean(numbers)
  let target = match rule.std_dev {
    Some(steps) => {
      let sd = population_std_dev(numbers, avg)
      if rule.above_average {
        avg + sd * steps.to_double()
      } else {
        avg - sd * steps.to_double()
      }
    }
    None => avg
  }
  let value = match number_for_population_opt(cell) {
    Some(v) => v
    None => return false
  }
  if rule.above_average {
    if rule.equal_average {
      value >= target
    } else {
      value > target
    }
  } else if rule.equal_average {
    value <= target
  } else {
    value < target
  }
}

///|
fn evaluate_time_period(
  rule : @domain.CT_CfRule,
  cell : @formula.FormulaValue,
  ctx : EvalContext,
) -> Bool {
  let period = match rule.time_period {
    Some(p) => p
    None => return false
  }
  let serial = match number_for_population_opt(cell) {
    Some(n) => n
    None => return false
  }
  // §18.3.1.10 timePeriod — when the cell's serial is outside
  // the §18.17.4 serial-date epoch (EpochOutOfRange) the cell
  // cannot satisfy any time-window predicate, so the rule does
  // NOT match.  Treating the conversion failure as "no match"
  // is the spec-permitted safe default; the data fault itself
  // is preserved on the cell's @v attribute for upstream
  // diagnostics.
  let cell_date = try
    @date_serial.serial_to_date_time(serial, ctx.date_system)
  catch {
    _ => return false
  } noraise {
    parsed => parsed
  }
  // Same defensive handling for the "today" anchor — a corrupt
  // calendar context cannot satisfy any time-window predicate.
  let today_serial = try
    @date_serial.date_time_to_serial(ctx.today, ctx.date_system)
  catch {
    _ => return false
  } noraise {
    parsed => parsed
  }
  let diff_days = serial.trunc().to_int() - today_serial.trunc().to_int()
  match period {
    @domain.Today => diff_days == 0
    @domain.Yesterday => diff_days == -1
    @domain.Tomorrow => diff_days == 1
    @domain.Last7Days => diff_days <= 0 && diff_days >= -6
    @domain.LastWeek => same_iso_week_offset(ctx.today, cell_date, -1)
    @domain.ThisWeek => same_iso_week_offset(ctx.today, cell_date, 0)
    @domain.NextWeek => same_iso_week_offset(ctx.today, cell_date, 1)
    @domain.LastMonth => same_month_offset(ctx.today, cell_date, -1)
    @domain.ThisMonth => same_month_offset(ctx.today, cell_date, 0)
    @domain.NextMonth => same_month_offset(ctx.today, cell_date, 1)
  }
}

///|
/// Compute the Sunday-anchored week offset between two
/// CalendarDateTime values.  Returns true when `cell` falls in
/// the week that is `offset` weeks from `today`.
///
/// §18.3.1.10 `timePeriod` does not pin a week-start day; Excel
/// uses Sunday..Saturday weeks by default (matching §22.4.2.1
/// ST_Workday's `firstDayOfWeek="0"` ≡ Sunday convention).  The
/// function name retains "iso" for source-history continuity but
/// the algorithm is Sunday-anchored, NOT ISO-8601 (which would
/// be Monday-anchored).
fn same_iso_week_offset(
  today : @date_serial.CalendarDateTime,
  cell : @date_serial.CalendarDateTime,
  offset : Int,
) -> Bool {
  let today_idx = julian_day_number(today.year, today.month, today.day)
  let cell_idx = julian_day_number(cell.year, cell.month, cell.day)
  let today_dow = (today_idx + 1) % 7
  let week_start = today_idx - today_dow + offset * 7
  let week_end = week_start + 6
  cell_idx >= week_start && cell_idx <= week_end
}

///|
fn same_month_offset(
  today : @date_serial.CalendarDateTime,
  cell : @date_serial.CalendarDateTime,
  offset : Int,
) -> Bool {
  let mut target_year = today.year
  let mut target_month = today.month + offset
  while target_month < 1 {
    target_month = target_month + 12
    target_year = target_year - 1
  }
  while target_month > 12 {
    target_month = target_month - 12
    target_year = target_year + 1
  }
  cell.year == target_year && cell.month == target_month
}

///|
/// Standard Fliegel/Van Flandern Julian day number. Returned as an Int
/// so the time-period helpers can compare day offsets without going
/// through `@date_serial`.
fn julian_day_number(year : Int, month : Int, day : Int) -> Int {
  let a = (14 - month) / 12
  let y = year + 4800 - a
  let m = month + 12 * a - 3
  day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
}

///|
fn evaluate_expression(rule : @domain.CT_CfRule, ctx : EvalContext) -> Bool {
  let text = match rule.formulas.get(0) {
    Some(t) => t
    None => return false
  }
  let value = (ctx.evaluate_formula)(text)
  match value {
    @formula.VBool(true) => true
    @formula.VBool(false) => false
    @formula.VNumber(n) => n != 0.0 && !n.is_nan()
    @formula.VString(s) => s.length() > 0
    @formula.VEmpty => false
    @formula.VError(_) => false
    @formula.VArray(_) => false
  }
}

///|
fn occurrence_of(
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Int {
  let target = value_key(cell)
  let mut count = 0
  for value in population {
    if value_key(value) == target {
      count = count + 1
    }
  }
  count
}

///|
/// Part 1 §18.3.1.10 — bucket index for a colorScale rule (0..k-1).
/// Returns None when `rule.color_scale is None` or the cell carries
/// no numeric value. Useful for renderers that pre-resolve theme
/// colors and want the segment index rather than the blended ARGB.
pub fn evaluate_bucket(
  rule : @domain.CT_CfRule,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Int? {
  match rule.cf_type {
    Some(@domain.ColorScale) =>
      match rule.color_scale {
        Some(scale) => {
          let cell_number = match number_for_population_opt(cell) {
            Some(n) => n
            None => return None
          }
          let numbers = collect_numbers(population)
          let mut bucket = 0
          for i in 0..<scale.thresholds.length() {
            let cfvo = scale.thresholds[i]
            let resolved = resolve_cfvo_value(cfvo, numbers)
            if cfvo_boundary_matches(cell_number, cfvo, resolved) {
              bucket = i
            }
          }
          Some(bucket)
        }
        None => None
      }
    Some(@domain.IconSet) =>
      match rule.icon_set {
        Some(icon_set) => evaluate_icon_bucket(icon_set, cell, population)
        None => None
      }
    // Any other type, or a type-less rule (§18.3.1.10 `@type`
    // optional), has no bucket projection.
    _ => None
  }
}

///|
/// Part 1 §18.3.1.10 / §18.3.1.18 — evaluate every rule in a
/// `CT_ConditionalFormatting` against the supplied cell snapshot and
/// return one `MatchHit` per (cell, matched rule) pair. Rules are
/// scanned in ascending priority order (already pre-sorted by
/// `decode_cf_block`); when a rule's @stopIfTrue is set and the rule
/// matches a cell, no lower-precedence rules are recorded for that
/// cell.
pub fn evaluate_cf_block(
  block : @domain.CT_ConditionalFormatting,
  cells : Array[(@address.CellAddress, @formula.FormulaValue)],
  ctx : EvalContext,
) -> Array[MatchHit] {
  let population : Array[@formula.FormulaValue] = []
  for entry in cells {
    population.push(entry.1)
  }
  let hits : Array[MatchHit] = []
  let stopped : Array[Bool] = Array::make(cells.length(), false)
  for rule in block.rules {
    for i in 0..<cells.length() {
      if stopped[i] {
        continue
      }
      let (address, value) = cells[i]
      if evaluate_rule(rule, value, population, ctx) {
        let argb = match rule.cf_type {
          Some(@domain.ColorScale) =>
            match rule.color_scale {
              Some(scale) => evaluate_color_scale(scale, value, population)
              None => None
            }
          _ => None
        }
        let bar_ratio = match rule.cf_type {
          Some(@domain.DataBar) =>
            match rule.data_bar {
              Some(bar) =>
                match evaluate_data_bar_geometry(bar, value, population) {
                  Some(geometry) =>
                    Some((geometry.end_ratio - geometry.start_ratio).abs())
                  None => None
                }
              None => None
            }
          _ => None
        }
        let icon_index = match rule.cf_type {
          Some(@domain.IconSet) =>
            match rule.icon_set {
              Some(set) => evaluate_icon_bucket(set, value, population)
              None => None
            }
          _ => None
        }
        hits.push({
          cell: address,
          rule_priority: rule.priority,
          cf_type: rule.cf_type,
          dxf_id: rule.dxf_id,
          argb,
          bar_ratio,
          icon_index,
        })
        if rule.stop_if_true {
          stopped[i] = true
        }
      }
    }
  }
  hits
}
