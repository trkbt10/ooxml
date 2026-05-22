///|
/// Part 1 §21.4.7.1 lin — equally divide the parent bounds into N
/// boxes along the major axis (row → x, col → y). The major axis
/// is selected by the `linDir` parameter (default `fromL`).
/// Sibling spacing is taken from the `sp` (or synonym `sibSp`)
/// constraint; when absent the boxes touch edge-to-edge.
///
/// The function returns the per-child bounds in source order, so
/// the caller can pair them with the layout-node iteration result
/// without re-keying.
pub fn layout_lin(
  inner : BoundsRect,
  algorithm : Algorithm,
  constraints : Array[Constraint],
  child_count : Int,
) -> Array[BoundsRect] {
  let result : Array[BoundsRect] = []
  if child_count <= 0 {
    return result
  }
  let dir = algorithm.param("linDir").unwrap_or("fromL")
  let is_horizontal = match dir {
    "fromR" | "fromL" => true
    "fromT" | "fromB" => false
    _ => true
  }
  let reversed = match dir {
    "fromR" | "fromB" => true
    _ => false
  }
  let spacing = sibling_spacing(constraints)
  let n = child_count
  let total_spacing = spacing * (n - 1).to_double()
  if is_horizontal {
    let unit_w = (inner.width - total_spacing) / n.to_double()
    let safe_w = if unit_w < 0.0 { 0.0 } else { unit_w }
    for i in 0..<n {
      let logical_index = if reversed { n - 1 - i } else { i }
      let bounds = {
        x: inner.x + logical_index.to_double() * (safe_w + spacing),
        y: inner.y,
        width: safe_w,
        height: inner.height,
      }
      result.push(bounds)
    }
  } else {
    let unit_h = (inner.height - total_spacing) / n.to_double()
    let safe_h = if unit_h < 0.0 { 0.0 } else { unit_h }
    for i in 0..<n {
      let logical_index = if reversed { n - 1 - i } else { i }
      let bounds = {
        x: inner.x,
        y: inner.y + logical_index.to_double() * (safe_h + spacing),
        width: inner.width,
        height: safe_h,
      }
      result.push(bounds)
    }
  }
  result
}

///|
/// Part 1 §21.4.7.1 snake — wrap the linear arrangement at a
/// configurable column count. The column count comes from the
/// `bkpt` parameter when present, the explicit `bkpt` integer
/// override, or `ceil(sqrt(n))` as a fallback. Cells flow
/// left-to-right then top-to-bottom (`grDir = tL` default).
///
/// The function returns the per-child bounds in source order so
/// the caller can dispatch them straight to `apply_child`.
pub fn layout_snake(
  inner : BoundsRect,
  algorithm : Algorithm,
  constraints : Array[Constraint],
  child_count : Int,
) -> Array[BoundsRect] {
  let result : Array[BoundsRect] = []
  if child_count <= 0 {
    return result
  }
  let n = child_count
  let cols_param = match algorithm.param("bkpt") {
    Some(value) => parse_positive_int_or(value, 0)
    None => 0
  }
  let cols = if cols_param > 0 { cols_param } else { int_ceil_sqrt(n) }
  let actual_cols = if cols > n { n } else { cols }
  let rows = if actual_cols == 0 {
    1
  } else {
    (n + actual_cols - 1) / actual_cols
  }
  let spacing = sibling_spacing(constraints)
  let col_total_spacing = spacing * (actual_cols - 1).to_double()
  let row_total_spacing = spacing * (rows - 1).to_double()
  let cell_w = (inner.width - col_total_spacing) / actual_cols.to_double()
  let cell_h = (inner.height - row_total_spacing) / rows.to_double()
  let safe_w = if cell_w < 0.0 { 0.0 } else { cell_w }
  let safe_h = if cell_h < 0.0 { 0.0 } else { cell_h }
  for i in 0..<n {
    let row = i / actual_cols
    let col = i % actual_cols
    let bounds = {
      x: inner.x + col.to_double() * (safe_w + spacing),
      y: inner.y + row.to_double() * (safe_h + spacing),
      width: safe_w,
      height: safe_h,
    }
    result.push(bounds)
  }
  result
}

///|
/// Sum of the `sp` and `sibSp` constraint values, taking the
/// first non-`None` numeric value the engine encounters. The
/// schema permits both keys for sibling spacing; the canonical
/// layouts use `sp` while the legacy ones use `sibSp`.
pub fn sibling_spacing(constraints : Array[Constraint]) -> Double {
  for c in constraints {
    match c.kind {
      ConstrSp | ConstrSibSp =>
        match c.val {
          Some(value) => return value
          None => ()
        }
      _ => ()
    }
  }
  0.0
}

///|
/// §21.4.7.4 ST_DiagramBkpt — the `bkpt` parameter is the union
/// of `xsd:int` (column-count override) and the enum literals
/// `"ctr"` / `"off"` (centring / disable hints).  This helper
/// extracts the integer branch and returns `fallback` for the
/// enum literals; the caller's snake-layout heuristic uses
/// `fallback = 0` to mean "no explicit column count requested",
/// letting `ceil_sqrt` pick the column count from the child
/// count.  Schema-violating non-numeric / non-`ctr`/`off`
/// values land in the same fallback path.
fn parse_positive_int_or(value : String, fallback : Int) -> Int {
  let mut i = 0
  let mut acc = 0
  let len = value.length()
  while i < len {
    let unit = value.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return fallback
    }
    acc = acc * 10 + (unit - 0x30)
    i = i + 1
  }
  if acc <= 0 {
    fallback
  } else {
    acc
  }
}

///|
/// Integer ceiling square root used by the snake algorithm to
/// pick a column count when `bkpt` is absent. The result is
/// always >= 1; for `n = 0` we still return 1 to avoid a divide
/// by zero in the caller.
pub fn int_ceil_sqrt(n : Int) -> Int {
  if n <= 1 {
    return 1
  }
  let mut k = 1
  while k * k < n {
    k = k + 1
  }
  k
}
