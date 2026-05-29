// §21.2.2.211 / §21.2.2.213 — trendline regression is a real
// least-squares fit per type (linear / poly / exp / log / power),
// not a linear fit reused with fudge factors.

///|
fn approx(a : Double, b : Double, eps : Double) -> Bool {
  let d = a - b
  (if d < 0.0 { -d } else { d }) < eps
}

///|
test "solve_linear_system solves a known 3x3 system" {
  // x + y + z = 6 ; 2y + 5z = -4 ; 2x + 5y - z = 27
  // solution: x=5, y=3, z=-2
  let a = [[1.0, 1.0, 1.0], [0.0, 2.0, 5.0], [2.0, 5.0, -1.0]]
  let b = [6.0, -4.0, 27.0]
  match solve_linear_system(a, b) {
    Some(x) => {
      assert_true(approx(x[0], 5.0, 1.0e-9))
      assert_true(approx(x[1], 3.0, 1.0e-9))
      assert_true(approx(x[2], -2.0, 1.0e-9))
    }
    None => fail("system should be solvable")
  }
}

///|
test "poly_fit recovers an exact linear relationship" {
  // y = 2x + 1 on x = 1..5.
  let xs = [1.0, 2.0, 3.0, 4.0, 5.0]
  let ys = [3.0, 5.0, 7.0, 9.0, 11.0]
  match poly_fit(xs, ys, 1, None) {
    Some(c) => {
      assert_true(approx(c[0], 1.0, 1.0e-6))
      assert_true(approx(c[1], 2.0, 1.0e-6))
    }
    None => fail("linear fit failed")
  }
}

///|
test "poly_fit recovers an exact quadratic" {
  // y = x^2 - 2x + 1 on x = 1..6.
  let xs = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
  let ys : Array[Double] = []
  for x in xs {
    ys.push(x * x - 2.0 * x + 1.0)
  }
  match poly_fit(xs, ys, 2, None) {
    Some(c) => {
      assert_true(approx(c[0], 1.0, 1.0e-4))
      assert_true(approx(c[1], -2.0, 1.0e-4))
      assert_true(approx(c[2], 1.0, 1.0e-4))
      // poly_eval round-trips.
      assert_true(approx(poly_eval(c, 7.0), 36.0, 1.0e-3))
    }
    None => fail("quadratic fit failed")
  }
}

///|
test "poly_fit honours a fixed intercept" {
  // Force the line through (0, 0): y = 2x with intercept 0.
  let xs = [1.0, 2.0, 3.0, 4.0]
  let ys = [2.1, 3.9, 6.0, 8.0]
  match poly_fit(xs, ys, 1, Some(0.0)) {
    Some(c) => {
      assert_eq(c[0], 0.0)
      // slope close to 2.
      assert_true(approx(c[1], 2.0, 0.1))
    }
    None => fail("fixed-intercept fit failed")
  }
}

///|
test "exponential data is fit in log space, not linearly" {
  // y = 3·e^{0.4x}.  Linearised: ln y = ln 3 + 0.4 x.
  let xs = [1.0, 2.0, 3.0, 4.0, 5.0]
  let ly : Array[Double] = []
  for x in xs {
    ly.push(@math.ln(3.0 * @math.exp(0.4 * x)))
  }
  match poly_fit(xs, ly, 1, None) {
    Some(c) => {
      let b = @math.exp(c[0])
      assert_true(approx(b, 3.0, 1.0e-3))
      assert_true(approx(c[1], 0.4, 1.0e-3))
    }
    None => fail("exp log-space fit failed")
  }
}
