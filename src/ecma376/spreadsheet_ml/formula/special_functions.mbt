// §18.17 — numerical helpers for statistical distribution functions.
// Private to the formula package; consumed by functions_statistical_dist.mbt
// and functions_engineering.mbt.

///|
fn gamma_ln(x : Double) -> Double {
  // Lanczos approximation (g=7, n=9) for ln(Γ(x)), valid for x > 0.
  let g = 7.0
  let c : FixedArray[Double] = [
    0.99999999999980993, 676.5203681218851, -1259.1392167224028,
    771.32342877765313, -176.61502916214059, 12.507343278686905,
    -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7,
  ]
  if x < 0.5 {
    // Reflection formula: Γ(x)Γ(1−x) = π/sin(πx)
    let lsin = @math.ln(sin_raw(trig_pi * x).abs())
    @math.ln(trig_pi) - lsin - gamma_ln(1.0 - x)
  } else {
    let x = x - 1.0
    let mut a = c[0]
    let t = x + g + 0.5
    for i in 1..=8 {
      a = a + c[i] / (x + i.to_double())
    }
    0.5 * @math.ln(2.0 * trig_pi) + (x + 0.5) * @math.ln(t) - t + @math.ln(a)
  }
}

///|
fn gamma_func(x : Double) -> Double {
  @math.exp(gamma_ln(x))
}

///|
fn erf_raw(x : Double) -> Double {
  // Abramowitz & Stegun 7.1.28 — rational approximation, |ε| < 1.5e-7.
  // Extended to use the complementary form for |x| > 4 for better accuracy.
  let sign = if x < 0.0 { -1.0 } else { 1.0 }
  let a = x.abs()
  if a < 1.0e-10 {
    return 0.0
  }
  let t = 1.0 / (1.0 + 0.3275911 * a)
  let poly = t *
    (0.254829592 +
    t *
    (-0.284496736 +
    t * (1.421413741 + t * (-1.453152027 + t * 1.061405429))))
  let result = 1.0 - poly * @math.exp(-a * a)
  sign * result
}

///|
fn erfc_raw(x : Double) -> Double {
  1.0 - erf_raw(x)
}

///|
fn norm_cdf(x : Double) -> Double {
  0.5 * (1.0 + erf_raw(x / (2.0 : Double).sqrt()))
}

///|
fn norm_inv(p : Double) -> Double {
  // Rational approximation (Peter Acklam) for the inverse standard
  // normal CDF, accurate to ~1.15e-9 over the full (0,1) domain.
  let a : FixedArray[Double] = [
    -3.969683028665376e+1, 2.209460984245205e+2, -2.759285104469687e+2,
    1.383577518672690e+2, -3.066479806614716e+1, 2.506628277459239e+0,
  ]
  let b : FixedArray[Double] = [
    -5.447609879822406e+1, 1.615858368580409e+2, -1.556989798598866e+2,
    6.680131188771972e+1, -1.328068155288572e+1,
  ]
  let c : FixedArray[Double] = [
    -7.784894002430293e-3, -3.223964580411365e-1, -2.400758277161838e+0,
    -2.549732539343734e+0, 4.374664141464968e+0, 2.938163982698783e+0,
  ]
  let d : FixedArray[Double] = [
    7.784695709041462e-3, 3.224671290700398e-1, 2.445134137142996e+0,
    3.754408661907416e+0,
  ]
  let p_low = 0.02425
  let p_high = 1.0 - p_low
  if p < p_low {
    let q = (-2.0 * @math.ln(p)).sqrt()
    (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
      ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1.0)
  } else if p <= p_high {
    let q = p - 0.5
    let r = q * q
    (((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r + a[5]) *
      q /
      (((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1.0)
  } else {
    let q = (-2.0 * @math.ln(1.0 - p)).sqrt()
    -(((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
      ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1.0)
  }
}

///|
fn lower_gamma_regularized(a : Double, x : Double) -> Double {
  // Regularized lower incomplete gamma P(a,x) = γ(a,x)/Γ(a)
  // Uses series expansion for x < a+1, continued fraction otherwise.
  if x <= 0.0 {
    return 0.0
  }
  if x < a + 1.0 {
    lower_gamma_series(a, x)
  } else {
    1.0 - upper_gamma_cf(a, x)
  }
}

fn lower_gamma_series(a : Double, x : Double) -> Double {
  let mut term = 1.0 / a
  let mut sum = term
  for n in 1..=200 {
    term = term * x / (a + n.to_double())
    sum = sum + term
    if term.abs() < sum.abs() * 1.0e-15 {
      break
    }
  }
  sum * @math.exp(-x + a * @math.ln(x) - gamma_ln(a))
}

fn upper_gamma_cf(a : Double, x : Double) -> Double {
  // Lentz's continued fraction for Q(a,x) = 1 - P(a,x)
  let mut c = 1.0e-30
  let mut d = 1.0 / (x + 1.0 - a)
  let mut h = d
  for n in 1..=200 {
    let an = n.to_double() * (a - n.to_double())
    let bn = x + (2 * n + 1).to_double() - a
    d = bn + an * d
    if d.abs() < 1.0e-30 {
      d = 1.0e-30
    }
    c = bn + an / c
    if c.abs() < 1.0e-30 {
      c = 1.0e-30
    }
    d = 1.0 / d
    let del = d * c
    h = h * del
    if (del - 1.0).abs() < 1.0e-15 {
      break
    }
  }
  h * @math.exp(-x + a * @math.ln(x) - gamma_ln(a))
}

///|
fn beta_regularized(x : Double, a : Double, b : Double) -> Double {
  // Regularized incomplete beta I_x(a,b) via continued fraction (Lentz).
  if x <= 0.0 {
    return 0.0
  }
  if x >= 1.0 {
    return 1.0
  }
  // Use symmetry: I_x(a,b) = 1 - I_{1-x}(b,a) when x > (a+1)/(a+b+2)
  if x > (a + 1.0) / (a + b + 2.0) {
    return 1.0 - beta_regularized(1.0 - x, b, a)
  }
  let lbeta = gamma_ln(a) + gamma_ln(b) - gamma_ln(a + b)
  let front = @math.exp(
    @math.ln(x) * a + @math.ln(1.0 - x) * b - lbeta,
  ) / a
  beta_cf(x, a, b) * front * a
}

fn beta_cf(x : Double, a : Double, b : Double) -> Double {
  let mut c = 1.0
  let mut d = 1.0 / (1.0 - (a + b) * x / (a + 1.0)).abs().max(1.0e-30)
  let mut h = d
  for m in 1..=200 {
    let mf = m.to_double()
    // Even step
    let num_even = mf * (b - mf) * x / ((a + 2.0 * mf - 1.0) * (a + 2.0 * mf))
    d = 1.0 + num_even * d
    if d.abs() < 1.0e-30 { d = 1.0e-30 }
    c = 1.0 + num_even / c
    if c.abs() < 1.0e-30 { c = 1.0e-30 }
    d = 1.0 / d
    h = h * d * c
    // Odd step
    let num_odd = -((a + mf) * (a + b + mf) * x) / ((a + 2.0 * mf) * (a + 2.0 * mf + 1.0))
    d = 1.0 + num_odd * d
    if d.abs() < 1.0e-30 { d = 1.0e-30 }
    c = 1.0 + num_odd / c
    if c.abs() < 1.0e-30 { c = 1.0e-30 }
    d = 1.0 / d
    let del = d * c
    h = h * del
    if (del - 1.0).abs() < 1.0e-15 {
      break
    }
  }
  h
}

///|
fn chi2_cdf(x : Double, df : Double) -> Double {
  if x <= 0.0 {
    0.0
  } else {
    lower_gamma_regularized(df / 2.0, x / 2.0)
  }
}

///|
fn f_cdf(x : Double, df1 : Double, df2 : Double) -> Double {
  if x <= 0.0 {
    0.0
  } else {
    beta_regularized(
      df1 * x / (df1 * x + df2), df1 / 2.0, df2 / 2.0,
    )
  }
}

///|
fn t_cdf(x : Double, df : Double) -> Double {
  let p = beta_regularized(
    df / (df + x * x), df / 2.0, 0.5,
  )
  if x >= 0.0 {
    1.0 - 0.5 * p
  } else {
    0.5 * p
  }
}

///|
fn poisson_cdf(x : Int, mean : Double) -> Double {
  if x < 0 {
    return 0.0
  }
  1.0 - lower_gamma_regularized(
    (x + 1).to_double(), mean,
  )
}

///|
fn poisson_pmf(x : Int, mean : Double) -> Double {
  if x < 0 || mean <= 0.0 {
    return 0.0
  }
  @math.exp(
    x.to_double() * @math.ln(mean) - mean - gamma_ln(
      (x + 1).to_double(),
    ),
  )
}

///|
fn binom_pmf(k : Int, n : Int, p : Double) -> Double {
  if k < 0 || k > n {
    return 0.0
  }
  @math.exp(
    gamma_ln((n + 1).to_double()) -
    gamma_ln((k + 1).to_double()) -
    gamma_ln((n - k + 1).to_double()) +
    k.to_double() * @math.ln(p) +
    (n - k).to_double() * @math.ln(1.0 - p),
  )
}

///|
fn binom_cdf(k : Int, n : Int, p : Double) -> Double {
  if k < 0 {
    return 0.0
  }
  if k >= n {
    return 1.0
  }
  1.0 - beta_regularized(p, (k + 1).to_double(), (n - k).to_double())
}
