///|
/// Part 1 §19.5.33 cTn — apply the accel / decel ease envelope to a
/// raw progress value in [0, 1]. The spec defines accel as the
/// fraction of duration spent accelerating from 0 to the run rate,
/// and decel as the fraction spent decelerating back to 0; the
/// remaining middle plays at constant rate. The areas under each
/// segment sum to the total displacement, normalised so the eased
/// curve at progress=1 still equals 1.
pub fn ease_progress(
  raw_progress : Double,
  accel : Double,
  decel : Double,
) -> Double {
  let clamped = if raw_progress < 0.0 {
    0.0
  } else if raw_progress > 1.0 {
    1.0
  } else {
    raw_progress
  }
  let a = clamp_unit(accel)
  let d = clamp_unit(decel)
  if a == 0.0 && d == 0.0 {
    return clamped
  }
  // Run rate r so total displacement is 1: r * (1 - a/2 - d/2) = 1.
  let denom = 1.0 - a / 2.0 - d / 2.0
  if denom <= 0.0 {
    return clamped
  }
  let r = 1.0 / denom
  if clamped < a {
    // Acceleration phase: instantaneous rate ramps from 0 → r over
    // the first `a` units of normalised time.
    let phase = clamped / a
    0.5 * r * a * phase * phase
  } else if clamped < 1.0 - d {
    // Constant phase: full rate r.
    0.5 * r * a + r * (clamped - a)
  } else {
    // Deceleration phase: rate ramps from r → 0 over the last
    // `d` units of normalised time.
    let phase = (1.0 - clamped) / d
    1.0 - 0.5 * r * d * phase * phase
  }
}

///|
/// Apply the repeat / auto-reverse rules to a raw progress value
/// before any easing. Returns the local progress within the active
/// cycle plus a flag indicating whether the snapshot has run past
/// every repeat (so the caller can honour `fill`).
pub fn effective_progress(
  raw_progress : Double,
  repeat_count : @domain.ST_TLTime?,
  auto_reverse : Bool,
) -> (Double, Bool) {
  if raw_progress < 0.0 {
    return (0.0, false)
  }
  let iterations = @domain.ct_tl_common_time_node_repeat_iterations(
    repeat_count,
  )
  if iterations == 1 && !auto_reverse {
    if raw_progress > 1.0 {
      return (1.0, true)
    }
    return (raw_progress, false)
  }
  let max_cycle = if iterations < 0 {
    // RepeatIndefinite — never finishes; treat exhausted as false.
    -1
  } else if auto_reverse {
    iterations * 2
  } else {
    iterations
  }
  if max_cycle > 0 && raw_progress >= max_cycle.to_double() {
    if auto_reverse && max_cycle % 2 == 0 {
      return (0.0, true)
    }
    return (1.0, true)
  }
  let cycle = raw_progress.floor().to_int()
  let local_t = raw_progress - cycle.to_double()
  if auto_reverse && cycle % 2 == 1 {
    (1.0 - local_t, false)
  } else {
    (local_t, false)
  }
}

///|
/// Interpolate a numeric value across two adjacent tav keypoints
/// using the calc mode. For `CalcModeDiscrete` the lower keypoint's
/// value is returned; for `CalcModeLin` / `CalcModeFmla` (treated as
/// linear when no formula is present) a linear ramp is applied.
pub fn interpolate_numeric_tav(
  low_value : Double,
  high_value : Double,
  local_progress : Double,
  calc_mode : @domain.ST_TLAnimateBehaviorCalcMode,
) -> Double {
  match calc_mode {
    @domain.CalcModeDiscrete => low_value
    _ => low_value + (high_value - low_value) * local_progress
  }
}

///|
/// Interpolate two `CT_TLAnimVariant`s using the supplied calc mode
/// and local progress. Numeric variants interpolate linearly; non-
/// numeric variants step from the low value to the high value at
/// progress=1.
pub fn interpolate_variant(
  low : @domain.CT_TLAnimVariant,
  high : @domain.CT_TLAnimVariant,
  local_progress : Double,
  calc_mode : @domain.ST_TLAnimateBehaviorCalcMode,
) -> @domain.CT_TLAnimVariant {
  let lo_opt = low.as_double()
  let hi_opt = high.as_double()
  match (lo_opt, hi_opt) {
    (Some(lo), Some(hi)) => {
      let value = interpolate_numeric_tav(lo, hi, local_progress, calc_mode)
      match low {
        @domain.AnimVariantInt(_) =>
          match high {
            @domain.AnimVariantInt(_) => @domain.AnimVariantInt(value.to_int())
            _ => @domain.AnimVariantFloat(value)
          }
        @domain.AnimVariantFloat(_) => @domain.AnimVariantFloat(value)
        _ => @domain.AnimVariantFloat(value)
      }
    }
    _ =>
      // Non-numeric pair: step. Honour discrete by sticking to the
      // low value; honour linear by switching at progress >= 1.0.
      match calc_mode {
        @domain.CalcModeDiscrete => low
        _ => if local_progress >= 1.0 { high } else { low }
      }
  }
}

///|
/// Evaluate a behaviour's tavLst at a local progress value. Returns
/// the interpolated variant and the absolute keypoint progress so
/// callers can report it.
pub fn evaluate_tav_list(
  tav_list : Array[@domain.CT_TLTimeAnimateValue],
  local_progress : Double,
  calc_mode : @domain.ST_TLAnimateBehaviorCalcMode,
) -> @domain.CT_TLAnimVariant? {
  let usable : Array[@domain.CT_TLTimeAnimateValue] = []
  for tav in tav_list {
    match (tav.tm_percent, tav.value) {
      (Some(_), Some(_)) => usable.push(tav)
      _ => ()
    }
  }
  if usable.length() == 0 {
    return None
  }
  if usable.length() == 1 {
    return usable[0].value
  }
  // Sort copy by tm_percent ascending.
  let sorted = usable.copy()
  sorted.sort_by(fn(a, b) {
    let ap = match a.tm_percent {
      Some(v) => v
      None => 0.0
    }
    let bp = match b.tm_percent {
      Some(v) => v
      None => 0.0
    }
    if ap < bp {
      -1
    } else if ap > bp {
      1
    } else {
      0
    }
  })
  let first = sorted[0]
  let last = sorted[sorted.length() - 1]
  let first_tm = unwrap_or_zero(first.tm_percent)
  let last_tm = unwrap_or_zero(last.tm_percent)
  if local_progress <= first_tm {
    return first.value
  }
  if local_progress >= last_tm {
    return last.value
  }
  let mut idx = 0
  while idx + 1 < sorted.length() {
    let lo_tm = unwrap_or_zero(sorted[idx].tm_percent)
    let hi_tm = unwrap_or_zero(sorted[idx + 1].tm_percent)
    if local_progress >= lo_tm && local_progress <= hi_tm {
      let span = hi_tm - lo_tm
      let lp = if span == 0.0 { 0.0 } else { (local_progress - lo_tm) / span }
      let lo_value = match sorted[idx].value {
        Some(v) => v
        None => return None
      }
      let hi_value = match sorted[idx + 1].value {
        Some(v) => v
        None => return None
      }
      return Some(interpolate_variant(lo_value, hi_value, lp, calc_mode))
    }
    idx = idx + 1
  }
  last.value
}

///|
fn clamp_unit(value : Double) -> Double {
  if value < 0.0 {
    0.0
  } else if value > 1.0 {
    1.0
  } else {
    value
  }
}

///|
fn unwrap_or_zero(value : Double?) -> Double {
  match value {
    Some(v) => v
    None => 0.0
  }
}
