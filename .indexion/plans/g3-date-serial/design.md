# G3 SpreadsheetML Date Serial Design

## Package

The implementation lives in `src/ecma376/spreadsheet_ml/date_serial`, a
standalone SpreadsheetML package. It imports only
`trkbt10/ooxml/ecma376/opc/errors` as `@opc_errors` so later formula, cell
coercion, and rendering code can depend on it without pulling reader or domain
packages across chapter boundaries.

## Algorithm

Date conversion uses Howard Hinnant-style closed-form Gregorian conversion:

- `days_from_civil(year, month, day)` converts a proleptic Gregorian calendar
  date to an absolute day number relative to Unix day zero.
- `civil_from_days(day)` converts that absolute day number back to
  year/month/day.

Serial conversion subtracts the selected base day (`1899-12-30` for 1900,
`1904-01-01` for 1904). Fractional serial values are converted by rounding to
milliseconds within the day and decomposing that value into hour, minute,
second, and millisecond fields.

## Lotus 1-2-3 Compatibility Note

The 1900 date system preserves the historical Excel/Lotus phantom leap day.
This is intentionally represented in `CalendarDateTime` even though
`1900-02-29` is not a true Gregorian date:

- `serial_to_date_time(60, Serial1900)` returns `1900-02-29T00:00:00`.
- `date_time_to_serial(1900-02-29T00:00:00, Serial1900)` returns `60`.

The public `is_leap_year_gregorian` helper remains true Gregorian and reports
1900 as non-leap. The quirk is isolated to serial conversion.

## Upper Bound Note

ECMA-376 §18.17.4 allows the latest date-time
`9999-12-31T23:59:59.999`, while §18.17.4.1 publishes upper serial constants
ending in `.9999884`. The package treats those constants as the valid serial
range ceiling and maps the maximum calendar date-time explicitly to that
ceiling for round-trip behavior.
