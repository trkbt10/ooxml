///|
fn dt(
  year : Int,
  month : Int,
  day : Int,
  hour? : Int = 0,
  minute? : Int = 0,
  second? : Int = 0,
  millisecond? : Int = 0,
) -> CalendarDateTime {
  { year, month, day, hour, minute, second, millisecond }
}

///|
fn assert_close(actual : Double, expected : Double) -> Unit raise {
  assert_true(actual.is_close(expected, absolute_tolerance=0.0000001))
}

///|
fn assert_same_datetime(
  actual : CalendarDateTime,
  expected : CalendarDateTime,
) -> Unit raise {
  assert_true(actual == expected)
}

///|
fn assert_round_trip(
  value : CalendarDateTime,
  system : DateSystem,
) -> Unit raise {
  let serial = try! date_time_to_serial(value, system)
  assert_same_datetime(try! serial_to_date_time(serial, system), value)
}

///|
test "§18.17.4.1 1900 base serial maps to 1899-12-30" {
  let value = dt(1899, 12, 30)
  assert_same_datetime(try! serial_to_date_time(0.0, Serial1900), value)
  assert_close(try! date_time_to_serial(value, Serial1900), 0.0)
}

///|
test "§18.17.4.1 1900 fractional serial stores time of day" {
  let value = dt(1899, 12, 31, hour=12)
  assert_same_datetime(try! serial_to_date_time(1.5, Serial1900), value)
  assert_close(try! date_time_to_serial(value, Serial1900), 1.5)
}

///|
test "§18.17.4.1 1900 Lotus phantom day is serial 60" {
  let value = dt(1900, 2, 29)
  assert_same_datetime(try! serial_to_date_time(60.0, Serial1900), value)
  assert_close(try! date_time_to_serial(value, Serial1900), 60.0)
}

///|
test "§18.17.4.1 1900 serial 61 maps to 1900-03-01" {
  let value = dt(1900, 3, 1)
  assert_same_datetime(try! serial_to_date_time(61.0, Serial1900), value)
  assert_close(try! date_time_to_serial(value, Serial1900), 61.0)
}

///|
test "§18.17.4.1 1900 serial 2 maps to 1900-01-01" {
  let value = dt(1900, 1, 1)
  assert_same_datetime(try! serial_to_date_time(2.0, Serial1900), value)
  assert_close(try! date_time_to_serial(value, Serial1900), 2.0)
}

///|
test "§18.17.4.1 1904 base serial maps to 1904-01-01" {
  let value = dt(1904, 1, 1)
  assert_same_datetime(try! serial_to_date_time(0.0, Serial1904), value)
  assert_close(try! date_time_to_serial(value, Serial1904), 0.0)
}

///|
test "§18.17.4.1 1904 typical serial maps to 1904-12-31" {
  let value = dt(1904, 12, 31)
  assert_same_datetime(try! serial_to_date_time(365.0, Serial1904), value)
  assert_close(try! date_time_to_serial(value, Serial1904), 365.0)
}

///|
test "§18.17.4.1 round trips representative modern dates" {
  let samples = [
    dt(1950, 1, 2, hour=3, minute=4, second=5, millisecond=6),
    dt(1975, 10, 5, hour=8, minute=30),
    dt(1999, 12, 31, hour=23, minute=59, second=59, millisecond=123),
    dt(2024, 2, 29, hour=6, minute=15, second=30, millisecond=500),
    dt(2050, 7, 14, hour=18, minute=45, second=1, millisecond=999),
  ]
  for sample in samples {
    assert_round_trip(sample, Serial1900)
    assert_round_trip(sample, Serial1904)
  }
}

///|
test "§18.17.4.1 lower bound round trips in both date systems" {
  let value = dt(1, 1, 1)
  assert_close(try! date_time_to_serial(value, Serial1900), -693593.0)
  assert_close(try! date_time_to_serial(value, Serial1904), -695055.0)
  assert_same_datetime(try! serial_to_date_time(-693593.0, Serial1900), value)
  assert_same_datetime(try! serial_to_date_time(-695055.0, Serial1904), value)
}

///|
test "§18.17.4.1 upper bound round trips in both date systems" {
  let value = dt(9999, 12, 31, hour=23, minute=59, second=59, millisecond=999)
  assert_round_trip(value, Serial1900)
  assert_round_trip(value, Serial1904)
  assert_true(is_valid_serial(2958465.9999884, Serial1900))
  assert_true(is_valid_serial(2957003.9999884, Serial1904))
}

///|
test "§18.17.4.1 invalid serial and invalid date raise SchemaViolation" {
  assert_true(
    (try? serial_to_date_time(-693594.0, Serial1900))
    is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? serial_to_date_time(-695056.0, Serial1904))
    is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? date_time_to_serial(dt(2023, 2, 29), Serial1900))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}
