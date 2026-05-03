# Design

The implementation extends the existing eager built-in function registry with two cohesive package-local files:

- `functions_financial.mbt` contains time-value-of-money helpers, iterative root solvers, depreciation helpers, and financial function registrations.
- `functions_statistical.mbt` contains numeric collection, rank/percentile selection, linear/exponential regression, covariance/correlation, and criteria matching for conditional aggregates.

The financial functions share the standard Excel-compatible time-value-of-money equation:

`pv * (1 + rate)^nper + pmt * (1 + rate * type) * (((1 + rate)^nper - 1) / rate) + fv = 0`

Zero-rate cases use the corresponding linear equation to avoid division by zero. RATE and IRR use Newton-Raphson with the required 50-iteration cap and `1e-7` tolerance; a near-zero derivative or failure to converge returns `#NUM!`.

Statistical functions flatten only numeric values from arrays/ranges and propagate errors. Direct scalar arguments use the package's existing scalar number coercion so literal numeric text and booleans behave consistently with the earlier aggregate functions.

Conditional aggregate criteria support plain equality and comparison operators. Wildcards (`*` and `?`) are not implemented in this phase; criteria containing them are treated as plain text equality unless paired with an explicit comparison operator.
