# G1.8 Formula Functions: Financial and Statistical

## Requirements

- Implement SpreadsheetML built-in functions from ECMA-376 Part 1 §18.17.7 for the financial family PMT, PV, FV, NPER, RATE, NPV, IRR, MIRR, IPMT, PPMT, CUMIPMT, CUMPRINC, SLN, SYD, DB, DDB, EFFECT, and NOMINAL.
- Implement the statistical and conditional aggregate family STDEV, STDEVP, STDEV.S, STDEV.P, VAR, VARP, VAR.S, VAR.P, MEDIAN, MODE, MODE.SNGL, PERCENTILE, PERCENTILE.INC, PERCENTILE.EXC, QUARTILE, QUARTILE.INC, QUARTILE.EXC, RANK, RANK.EQ, RANK.AVG, LARGE, SMALL, CORREL, COVAR, COVARIANCE.P, COVARIANCE.S, SLOPE, INTERCEPT, TREND, FORECAST, GROWTH, GEOMEAN, HARMEAN, AVEDEV, DEVSQ, SUMIF, SUMIFS, COUNTIF, COUNTIFS, AVERAGEIF, and AVERAGEIFS.
- Register all functions through `register_builtin_functions`.
- Keep changes inside `src/ecma376/spreadsheet_ml/formula/` plus this `.indexion/plans/` directory.
- Each function implementation doc-comment cites its §18.17.7 anchor.
- Newton-Raphson functions use tolerance `1e-7`, cap `50`, and return `#NUM!` on non-convergence.
- Criteria parsing supports plain equality and comparison operators `=`, `<>`, `<`, `<=`, `>`, `>=`.

## Non-Requirements

- Shared formula expansion is reserved for G1.9.
- End-to-end workbook integration tests are reserved for G1.10.
- Wildcard criteria are optional in this phase and are not required for acceptance.
