///|
fn n(value : Double) -> @formula.FormulaValue {
  @formula.FormulaValue::VNumber(value)
}

///|
fn s(value : String) -> @formula.FormulaValue {
  @formula.FormulaValue::VString(value)
}

///|
fn err(literal : String) -> @formula.FormulaValue {
  let parsed = @formula.FormulaError::from_literal(literal).unwrap()
  @formula.FormulaValue::VError(parsed)
}

///|
fn no_formula() -> (String) -> @formula.FormulaValue {
  fn(_ : String) { @formula.FormulaValue::VEmpty }
}

///|
fn fixed_today(
  year : Int,
  month : Int,
  day : Int,
) -> @date_serial.CalendarDateTime {
  { year, month, day, hour: 0, minute: 0, second: 0, millisecond: 0 }
}

///|
fn context(
  today : @date_serial.CalendarDateTime,
  evaluate_formula : (String) -> @formula.FormulaValue,
) -> EvalContext {
  EvalContext::new(today, @date_serial.DateSystem::Serial1900, evaluate_formula)
}

///|
fn rule_for_test(
  cf_type : @domain.ST_CfType,
  priority : Int,
  customize : (@domain.CT_CfRule) -> @domain.CT_CfRule,
) -> @domain.CT_CfRule {
  let base : @domain.CT_CfRule = {
    cf_type,
    dxf_id: Some(0),
    priority,
    stop_if_true: false,
    operator: None,
    text: None,
    time_period: None,
    rank: None,
    bottom: false,
    percent: false,
    above_average: true,
    equal_average: false,
    std_dev: None,
    formulas: [],
    color_scale: None,
    data_bar: None,
    icon_set: None,
  }
  customize(base)
}

///|
test "§18.3.1.10 cellIs greaterThan picks numbers above the literal" {
  let rule = rule_for_test(@domain.CellIs, 1, fn(base) {
    { ..base, operator: Some(@domain.OpGreaterThan), formulas: ["0.5"] }
  })
  let formula_eval = fn(_text : String) { @formula.FormulaValue::VNumber(0.5) }
  let ctx = context(fixed_today(2026, 5, 19), formula_eval)
  assert_true(evaluate_rule(rule, n(0.7), [n(0.7), n(0.3)], ctx))
  assert_true(!evaluate_rule(rule, n(0.3), [n(0.7), n(0.3)], ctx))
}

///|
test "§18.18.15 cellIs between is inclusive" {
  let rule = rule_for_test(@domain.CellIs, 1, fn(base) {
    { ..base, operator: Some(@domain.OpBetween), formulas: ["1", "5"] }
  })
  let formula_eval = fn(text : String) {
    if text == "1" {
      @formula.FormulaValue::VNumber(1.0)
    } else {
      @formula.FormulaValue::VNumber(5.0)
    }
  }
  let ctx = context(fixed_today(2026, 5, 19), formula_eval)
  assert_true(evaluate_rule(rule, n(1.0), [n(1.0), n(5.0)], ctx))
  assert_true(evaluate_rule(rule, n(3.0), [n(1.0), n(5.0)], ctx))
  assert_true(evaluate_rule(rule, n(5.0), [n(1.0), n(5.0)], ctx))
  assert_true(!evaluate_rule(rule, n(6.0), [n(1.0), n(5.0)], ctx))
}

///|
test "§18.18.12 containsText is case-insensitive" {
  let rule = rule_for_test(@domain.ContainsText, 1, fn(base) {
    { ..base, text: Some("foo") }
  })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  assert_true(evaluate_rule(rule, s("FOOBAR"), [], ctx))
  assert_true(evaluate_rule(rule, s("xyfooyz"), [], ctx))
  assert_true(!evaluate_rule(rule, s("barbaz"), [], ctx))
}

///|
test "§18.18.12 beginsWith and endsWith" {
  let begins = rule_for_test(@domain.BeginsWith, 1, fn(base) {
    { ..base, text: Some("Mr") }
  })
  let ends = rule_for_test(@domain.EndsWith, 1, fn(base) {
    { ..base, text: Some("son") }
  })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  assert_true(evaluate_rule(begins, s("Mr Smith"), [], ctx))
  assert_true(evaluate_rule(begins, s("Mrs Smith"), [], ctx)) // also begins with Mr
  assert_true(!evaluate_rule(begins, s("Dr Smith"), [], ctx))
  assert_true(evaluate_rule(ends, s("Wilson"), [], ctx))
  assert_true(!evaluate_rule(ends, s("Wilkes"), [], ctx))
}

///|
test "§18.18.12 containsBlanks and notContainsBlanks" {
  let blanks = rule_for_test(@domain.ContainsBlanks, 1, fn(base) { base })
  let not_blanks = rule_for_test(@domain.NotContainsBlanks, 1, fn(base) { base })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  assert_true(evaluate_rule(blanks, @formula.FormulaValue::VEmpty, [], ctx))
  assert_true(evaluate_rule(blanks, s("   "), [], ctx))
  assert_true(!evaluate_rule(blanks, s("data"), [], ctx))
  assert_true(evaluate_rule(not_blanks, s("data"), [], ctx))
  assert_true(
    !evaluate_rule(not_blanks, @formula.FormulaValue::VEmpty, [], ctx),
  )
}

///|
test "§18.18.12 containsErrors flags VError" {
  let rule = rule_for_test(@domain.ContainsErrors, 1, fn(base) { base })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  assert_true(evaluate_rule(rule, err("#DIV/0!"), [], ctx))
  assert_true(!evaluate_rule(rule, n(1.0), [], ctx))
}

///|
test "§18.18.12 duplicateValues and uniqueValues" {
  let pop = [n(1.0), n(2.0), n(2.0), n(3.0)]
  let dup = rule_for_test(@domain.DuplicateValues, 1, fn(base) { base })
  let uniq = rule_for_test(@domain.UniqueValues, 1, fn(base) { base })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  assert_true(evaluate_rule(dup, n(2.0), pop, ctx))
  assert_true(!evaluate_rule(dup, n(1.0), pop, ctx))
  assert_true(evaluate_rule(uniq, n(1.0), pop, ctx))
  assert_true(!evaluate_rule(uniq, n(2.0), pop, ctx))
}

///|
test "§18.18.12 top10 selects top N (and bottom variant)" {
  let pop = [n(10.0), n(20.0), n(30.0), n(40.0), n(50.0)]
  let top2 = rule_for_test(@domain.Top10, 1, fn(base) {
    { ..base, rank: Some(2) }
  })
  let bottom2 = rule_for_test(@domain.Top10, 1, fn(base) {
    { ..base, rank: Some(2), bottom: true }
  })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  assert_true(evaluate_rule(top2, n(50.0), pop, ctx))
  assert_true(evaluate_rule(top2, n(40.0), pop, ctx))
  assert_true(!evaluate_rule(top2, n(30.0), pop, ctx))
  assert_true(evaluate_rule(bottom2, n(10.0), pop, ctx))
  assert_true(evaluate_rule(bottom2, n(20.0), pop, ctx))
  assert_true(!evaluate_rule(bottom2, n(30.0), pop, ctx))
}

///|
test "§18.18.12 top10 percent" {
  let pop = [
    n(1.0),
    n(2.0),
    n(3.0),
    n(4.0),
    n(5.0),
    n(6.0),
    n(7.0),
    n(8.0),
    n(9.0),
    n(10.0),
  ]
  // 20% of 10 = 2 cells
  let rule = rule_for_test(@domain.Top10, 1, fn(base) {
    { ..base, rank: Some(20), percent: true }
  })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  assert_true(evaluate_rule(rule, n(10.0), pop, ctx))
  assert_true(evaluate_rule(rule, n(9.0), pop, ctx))
  assert_true(!evaluate_rule(rule, n(8.0), pop, ctx))
}

///|
test "§18.18.12 aboveAverage exclusive vs inclusive" {
  let pop = [n(2.0), n(4.0), n(6.0)] // mean = 4
  let above = rule_for_test(@domain.AboveAverage, 1, fn(base) {
    { ..base, above_average: true, equal_average: false }
  })
  let at_or_above = rule_for_test(@domain.AboveAverage, 1, fn(base) {
    { ..base, above_average: true, equal_average: true }
  })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  assert_true(evaluate_rule(above, n(5.0), pop, ctx))
  assert_true(!evaluate_rule(above, n(4.0), pop, ctx))
  assert_true(evaluate_rule(at_or_above, n(4.0), pop, ctx))
  assert_true(!evaluate_rule(at_or_above, n(3.0), pop, ctx))
}

///|
test "§18.18.12 aboveAverage with stdDev shifts threshold" {
  let pop = [n(0.0), n(2.0), n(4.0), n(6.0), n(8.0)] // mean = 4, sd ≈ 2.83
  let rule = rule_for_test(@domain.AboveAverage, 1, fn(base) {
    { ..base, above_average: true, std_dev: Some(1) }
  })
  let ctx = context(fixed_today(2026, 5, 19), no_formula())
  // 4 + 2.83 ≈ 6.83
  assert_true(evaluate_rule(rule, n(8.0), pop, ctx))
  assert_true(!evaluate_rule(rule, n(6.0), pop, ctx))
}

///|
test "§18.18.82 timePeriod today / yesterday / last7Days" {
  let today = fixed_today(2026, 5, 19)
  let today_serial = try! @date_serial.date_time_to_serial(
    today,
    @date_serial.DateSystem::Serial1900,
  )
  let today_rule = rule_for_test(@domain.TimePeriod, 1, fn(base) {
    { ..base, time_period: Some(@domain.Today) }
  })
  let yesterday_rule = rule_for_test(@domain.TimePeriod, 1, fn(base) {
    { ..base, time_period: Some(@domain.Yesterday) }
  })
  let last7_rule = rule_for_test(@domain.TimePeriod, 1, fn(base) {
    { ..base, time_period: Some(@domain.Last7Days) }
  })
  let ctx = context(today, no_formula())
  assert_true(evaluate_rule(today_rule, n(today_serial), [], ctx))
  assert_true(evaluate_rule(yesterday_rule, n(today_serial - 1.0), [], ctx))
  assert_true(evaluate_rule(last7_rule, n(today_serial - 3.0), [], ctx))
  assert_true(!evaluate_rule(last7_rule, n(today_serial + 1.0), [], ctx))
}

///|
test "§18.18.12 expression uses the evaluator callback" {
  let formula_eval = fn(text : String) {
    if text == "TRUE_BRANCH" {
      @formula.FormulaValue::VBool(true)
    } else {
      @formula.FormulaValue::VBool(false)
    }
  }
  let true_rule = rule_for_test(@domain.Expression, 1, fn(base) {
    { ..base, formulas: ["TRUE_BRANCH"] }
  })
  let false_rule = rule_for_test(@domain.Expression, 1, fn(base) {
    { ..base, formulas: ["FALSE_BRANCH"] }
  })
  let ctx = context(fixed_today(2026, 5, 19), formula_eval)
  assert_true(evaluate_rule(true_rule, n(0.0), [], ctx))
  assert_true(!evaluate_rule(false_rule, n(0.0), [], ctx))
}

///|
test "§18.3.1.16 colorScale interpolates between stops" {
  let scale : @domain.CT_ColorScale = {
    thresholds: [
      { kind: @domain.CfvoMin, value_text: None },
      { kind: @domain.CfvoMax, value_text: None },
    ],
    colors: [
      @domain.CT_Color::new(255, 0, 0, 0),
      @domain.CT_Color::new(255, 255, 255, 255),
    ],
  }
  let pop = [n(0.0), n(50.0), n(100.0)]
  let mid = evaluate_color_scale(scale, n(50.0), pop).unwrap()
  // Midpoint of 0..100 maps near gray ~127.
  assert_true(mid.red >= 120 && mid.red <= 135)
  assert_true(mid.green >= 120 && mid.green <= 135)
  assert_true(mid.blue >= 120 && mid.blue <= 135)
  let low = evaluate_color_scale(scale, n(0.0), pop).unwrap()
  assert_eq(low.red, 0)
  let high = evaluate_color_scale(scale, n(100.0), pop).unwrap()
  assert_eq(high.red, 255)
}

///|
test "§18.3.1.28 dataBar ratio saturates outside min/max" {
  let bar : @domain.CT_DataBar = {
    min_threshold: { kind: @domain.CfvoNum, value_text: Some("0") },
    max_threshold: { kind: @domain.CfvoNum, value_text: Some("100") },
    color: @domain.CT_Color::new(255, 0, 0, 255),
  }
  assert_eq(evaluate_bar_ratio(bar, n(-5.0), []).unwrap(), 0.0)
  assert_eq(evaluate_bar_ratio(bar, n(200.0), []).unwrap(), 1.0)
  let mid = evaluate_bar_ratio(bar, n(25.0), []).unwrap()
  assert_true(mid > 0.24 && mid < 0.26)
}

///|
test "§18.3.1.49 iconSet bucket forward and reverse" {
  let icon : @domain.CT_IconSet = {
    set_name: "3TrafficLights1",
    thresholds: [
      { kind: @domain.CfvoPercent, value_text: Some("0") },
      { kind: @domain.CfvoPercent, value_text: Some("33") },
      { kind: @domain.CfvoPercent, value_text: Some("67") },
    ],
    reverse: false,
    show_value: true,
  }
  let pop = [n(0.0), n(50.0), n(100.0)]
  assert_eq(evaluate_icon_bucket(icon, n(10.0), pop).unwrap(), 0)
  assert_eq(evaluate_icon_bucket(icon, n(40.0), pop).unwrap(), 1)
  assert_eq(evaluate_icon_bucket(icon, n(80.0), pop).unwrap(), 2)
  let reversed : @domain.CT_IconSet = { ..icon, reverse: true }
  assert_eq(evaluate_icon_bucket(reversed, n(10.0), pop).unwrap(), 2)
}

///|
test "§18.3.1.10 evaluate_cf_block respects priority and stopIfTrue" {
  let rule_high = rule_for_test(@domain.CellIs, 1, fn(base) {
    {
      ..base,
      operator: Some(@domain.OpGreaterThan),
      formulas: ["50"],
      dxf_id: Some(7),
      stop_if_true: true,
    }
  })
  let rule_low = rule_for_test(@domain.CellIs, 2, fn(base) {
    {
      ..base,
      operator: Some(@domain.OpGreaterThan),
      formulas: ["10"],
      dxf_id: Some(8),
    }
  })
  let block : @domain.CT_ConditionalFormatting = {
    pivot: false,
    sqref: try! @address.Sqref::parse_a1("A1:A3"),
    rules: [rule_high, rule_low],
  }
  let formula_eval = fn(text : String) {
    if text == "50" {
      @formula.FormulaValue::VNumber(50.0)
    } else {
      @formula.FormulaValue::VNumber(10.0)
    }
  }
  let ctx = context(fixed_today(2026, 5, 19), formula_eval)
  let cells : Array[(@address.CellAddress, @formula.FormulaValue)] = [
    (try! @address.CellAddress::parse_a1("A1"), n(100.0)),
    (try! @address.CellAddress::parse_a1("A2"), n(40.0)),
    (try! @address.CellAddress::parse_a1("A3"), n(5.0)),
  ]
  let hits = evaluate_cf_block(block, cells, ctx)
  // A1 (100) → matched by priority 1 (stops); A2 (40) → matched by
  // priority 2 only; A3 (5) → no match.
  let mut hits_for_a1 = 0
  let mut hits_for_a2 = 0
  for hit in hits {
    if hit.cell.to_a1() == "A1" {
      hits_for_a1 = hits_for_a1 + 1
      assert_eq(hit.dxf_id.unwrap(), 7)
    }
    if hit.cell.to_a1() == "A2" {
      hits_for_a2 = hits_for_a2 + 1
      assert_eq(hit.dxf_id.unwrap(), 8)
    }
  }
  assert_eq(hits_for_a1, 1)
  assert_eq(hits_for_a2, 1)
}

///|
test "§18.18.12 decode_cf_type rejects bogus values" {
  let bad = try? decode_cf_type("notARealType")
  assert_true(bad is Err(_))
}

///|
test "§18.18.15 decode_cf_operator handles all 12 values" {
  let mappings : Array[(String, @domain.ST_ConditionalFormattingOperator)] = [
    ("beginsWith", @domain.OpBeginsWith),
    ("between", @domain.OpBetween),
    ("containsText", @domain.OpContainsText),
    ("endsWith", @domain.OpEndsWith),
    ("equal", @domain.OpEqual),
    ("greaterThan", @domain.OpGreaterThan),
    ("greaterThanOrEqual", @domain.OpGreaterThanOrEqual),
    ("lessThan", @domain.OpLessThan),
    ("lessThanOrEqual", @domain.OpLessThanOrEqual),
    ("notBetween", @domain.OpNotBetween),
    ("notContains", @domain.OpNotContains),
    ("notEqual", @domain.OpNotEqual),
  ]
  for entry in mappings {
    let (lex, expected) = entry
    let got = try! decode_cf_operator(lex)
    assert_true(got == expected)
  }
}
