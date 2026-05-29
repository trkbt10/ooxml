///|
/// SpreadsheetML §18.3.2 AutoFilter typed domain types: enumerations and
/// element wrappers for the autoFilter / filterColumn rule choice.
///
/// XSD simple type ST_FilterOperator — Part 1 §18.18.31.
/// XSD simple type ST_DynamicFilterType — Part 1 §18.18.26.
/// XSD simple type ST_DateTimeGrouping — Part 1 §18.18.22.
/// XSD complex type CT_AutoFilter — Part 1 §18.3.1.2.
/// XSD complex type CT_FilterColumn — Part 1 §18.3.2.7.
/// XSD complex type CT_Filters — Part 1 §18.3.2.8.
/// XSD complex type CT_Filter — Part 1 §18.3.2.6.
/// XSD complex type CT_CustomFilters — Part 1 §18.3.2.3.
/// XSD complex type CT_CustomFilter — Part 1 §18.3.2.2.
/// XSD complex type CT_DynamicFilter — Part 1 §18.3.2.5.
/// XSD complex type CT_ColorFilter — Part 1 §18.3.2.1.
/// XSD complex type CT_IconFilter — Part 1 §18.3.2.9.
/// XSD complex type CT_Top10 — Part 1 §18.3.2.10.
/// XSD complex type CT_DateGroupItem — Part 1 §18.3.2.4.
pub fn auto_filter_type_group_name() -> String {
  "spreadsheet_ml.auto_filter"
}

///|
/// XSD simple type ST_FilterOperator — Part 1 §18.18.31. Operator
/// enumerations for filtering: `equal`, `lessThan`, `lessThanOrEqual`,
/// `notEqual`, `greaterThanOrEqual`, `greaterThan`.
pub(all) enum ST_FilterOperator {
  Equal
  LessThan
  LessThanOrEqual
  NotEqual
  GreaterThanOrEqual
  GreaterThan
} derive(Eq, Debug)

///|
/// XSD simple type ST_FilterOperator — Part 1 §18.18.31. Return the
/// SpreadsheetML enumeration token for this operator.
pub fn ST_FilterOperator::to_ooxml(self : ST_FilterOperator) -> String {
  match self {
    Equal => "equal"
    LessThan => "lessThan"
    LessThanOrEqual => "lessThanOrEqual"
    NotEqual => "notEqual"
    GreaterThanOrEqual => "greaterThanOrEqual"
    GreaterThan => "greaterThan"
  }
}

///|
/// XSD simple type ST_DynamicFilterType — Part 1 §18.18.26. Dynamic filter
/// kinds whose result set can change with the data or system date.
/// Enumeration values: `null`, `aboveAverage`, `belowAverage`, `tomorrow`,
/// `today`, `yesterday`, `nextWeek`, `thisWeek`, `lastWeek`, `nextMonth`,
/// `thisMonth`, `lastMonth`, `nextQuarter`, `thisQuarter`, `lastQuarter`,
/// `nextYear`, `thisYear`, `lastYear`, `yearToDate`, `Q1`-`Q4`, `M1`-`M12`.
pub(all) enum ST_DynamicFilterType {
  Null
  AboveAverage
  BelowAverage
  Tomorrow
  Today
  Yesterday
  NextWeek
  ThisWeek
  LastWeek
  NextMonth
  ThisMonth
  LastMonth
  NextQuarter
  ThisQuarter
  LastQuarter
  NextYear
  ThisYear
  LastYear
  YearToDate
  Q1
  Q2
  Q3
  Q4
  M1
  M2
  M3
  M4
  M5
  M6
  M7
  M8
  M9
  M10
  M11
  M12
} derive(Eq, Debug)

///|
/// XSD simple type ST_DynamicFilterType — Part 1 §18.18.26. True for
/// `aboveAverage` and `belowAverage`, which evaluate against the full
/// column instead of a date interval.
pub fn ST_DynamicFilterType::is_average(self : ST_DynamicFilterType) -> Bool {
  match self {
    AboveAverage => true
    BelowAverage => true
    _ => false
  }
}

///|
/// XSD simple type ST_DateTimeGrouping — Part 1 §18.18.22. Grouping level
/// for `dateGroupItem`: `year`, `month`, `day`, `hour`, `minute`, `second`.
pub(all) enum ST_DateTimeGrouping {
  Year
  Month
  Day
  Hour
  Minute
  Second
} derive(Eq, Debug)

///|
/// XSD complex type CT_DateGroupItem — Part 1 §18.3.2.4. Date or time
/// grouping criterion inside a `<filters>` element. `year` is required;
/// `month`, `day`, `hour`, `minute`, `second` are optional. The
/// `dateTimeGrouping` attribute selects the comparison granularity.
pub(all) struct CT_DateGroupItem {
  year : Int
  month : Int?
  day : Int?
  hour : Int?
  minute : Int?
  second : Int?
  date_time_grouping : ST_DateTimeGrouping
} derive(Eq, Debug)

///|
/// Schema sml.xsd complex type `CT_Filter`. Attributes: `val`.
///
/// XSD complex type CT_Filter — Part 1 §18.3.2.6. A single filter
/// literal value carried by `<filter val="..."/>` inside `<filters>`.
pub(all) struct CT_Filter {
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Filters — Part 1 §18.3.2.8. Groups multiple literal
/// `<filter>` values and/or `<dateGroupItem>` groupings together. The
/// `blank` attribute (default `false`) toggles whether blank cells pass.
pub(all) struct CT_Filters {
  filters : Array[CT_Filter]
  date_group_items : Array[CT_DateGroupItem]
  blank : Bool
  /// @calendarType (ST_CalendarType) — non-Gregorian grouping calendar;
  /// default "none" (§18.3.2.7).
  calendar_type : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustomFilter — Part 1 §18.3.2.2. Custom AutoFilter
/// criterion with `operator` (ST_FilterOperator, default `equal`) and `val`
/// payload.
pub(all) struct CT_CustomFilter {
  operator : ST_FilterOperator
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustomFilters — Part 1 §18.3.2.3. Groups one or two
/// `<customFilter>` criteria. `and_op` (the XML `and` attribute, default
/// `false`) selects conjunction over disjunction.
pub(all) struct CT_CustomFilters {
  criteria : Array[CT_CustomFilter]
  and_op : Bool
} derive(Eq, Debug)

///|
/// XSD complex type CT_DynamicFilter — Part 1 §18.3.2.5. Dynamic filter
/// criterion. `kind` (the required XML `type` attribute) selects the
/// ST_DynamicFilterType variant; `val` is the optional numeric lower bound
/// (or aboveAverage/belowAverage threshold); `max_val` carries the optional
/// computed upper bound used by date-interval variants.
pub(all) struct CT_DynamicFilter {
  kind : ST_DynamicFilterType
  val : Double?
  max_val : Double?
} derive(Eq, Debug)

///|
/// XSD complex type CT_ColorFilter — Part 1 §18.3.2.1. `dxf_id` references
/// a differential format record; `cell_color` (default `true`) selects fill
/// color over font color.
pub(all) struct CT_ColorFilter {
  dxf_id : Int
  cell_color : Bool
} derive(Eq, Debug)

///|
/// XSD complex type CT_IconFilter — Part 1 §18.3.2.9. `icon_set` is the
/// required ST_IconSetType token; `icon_id` is the zero-based icon index.
pub(all) struct CT_IconFilter {
  icon_set : String
  icon_id : Int
} derive(Eq, Debug)

///|
/// Schema sml.xsd complex type `CT_Top10`. Attributes: `top`,
/// `percent`, `val`, `filterVal`.
///
/// XSD complex type CT_Top10 — Part 1 §18.3.2.10. `top` (default
/// `true`) selects top vs bottom ordering; `percent` (default `false`)
/// selects percent vs item count; `val` is the required threshold;
/// `filter_val` is the optional cached comparison value.
pub(all) struct CT_Top10 {
  top : Bool
  percent : Bool
  val : Double
  filter_val : Double?
} derive(Eq, Debug)

///|
/// XSD `<xsd:choice>` inside CT_FilterColumn — Part 1 §18.3.2.7. Selects
/// which of the six rule sub-elements (`filters`, `top10`, `customFilters`,
/// `dynamicFilter`, `colorFilter`, `iconFilter`) is active for this column.
pub(all) enum CT_FilterColumn_Choice {
  Filters(CT_Filters)
  Top10(CT_Top10)
  CustomFilters(CT_CustomFilters)
  DynamicFilter(CT_DynamicFilter)
  ColorFilter(CT_ColorFilter)
  IconFilter(CT_IconFilter)
} derive(Eq, Debug)

///|
/// XSD `<xsd:choice>` inside CT_FilterColumn — Part 1 §18.3.2.7. True if
/// the active choice is `dynamicFilter`.
pub fn CT_FilterColumn_Choice::is_dynamic_filter(
  self : CT_FilterColumn_Choice,
) -> Bool {
  match self {
    DynamicFilter(_) => true
    _ => false
  }
}

///|
/// XSD complex type CT_FilterColumn — Part 1 §18.3.2.7. `col_id` is the
/// zero-based AutoFilter column index; `hidden_button` (default `false`)
/// and `show_button` (default `true`) carry the presentation flags; `rule`
/// is the optional choice sub-element.
pub(all) struct CT_FilterColumn {
  col_id : Int
  hidden_button : Bool
  show_button : Bool
  rule : CT_FilterColumn_Choice?
} derive(Eq, Debug)

///|
/// XSD complex type CT_AutoFilter — Part 1 §18.3.1.2. AutoFilter scope:
/// `range` is the inclusive A1 cell range covered by the filter;
/// `filter_columns` holds per-column criteria.
pub(all) struct CT_AutoFilter {
  range : @address.CellRange
  filter_columns : Array[CT_FilterColumn]
} derive(Eq, Debug)
