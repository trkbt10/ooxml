///|
/// Schema validation error for ECMA-376 SpreadsheetML (§18).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
pub struct ST_FilterOperator {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FilterOperator::parse(
  s : String,
) -> ST_FilterOperator raise SchemaViolation {
  match s {
    "equal" => ()
    "lessThan" => ()
    "lessThanOrEqual" => ()
    "notEqual" => ()
    "greaterThanOrEqual" => ()
    "greaterThan" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_FilterOperator",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_FilterOperator::new(
  s : String,
) -> ST_FilterOperator raise SchemaViolation {
  ST_FilterOperator::parse(s)
}

///|
pub fn ST_FilterOperator::to_string(self : ST_FilterOperator) -> String {
  self.value
}

///|
pub struct ST_DynamicFilterType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DynamicFilterType::parse(
  s : String,
) -> ST_DynamicFilterType raise SchemaViolation {
  match s {
    "null" => ()
    "aboveAverage" => ()
    "belowAverage" => ()
    "tomorrow" => ()
    "today" => ()
    "yesterday" => ()
    "nextWeek" => ()
    "thisWeek" => ()
    "lastWeek" => ()
    "nextMonth" => ()
    "thisMonth" => ()
    "lastMonth" => ()
    "nextQuarter" => ()
    "thisQuarter" => ()
    "lastQuarter" => ()
    "nextYear" => ()
    "thisYear" => ()
    "lastYear" => ()
    "yearToDate" => ()
    "Q1" => ()
    "Q2" => ()
    "Q3" => ()
    "Q4" => ()
    "M1" => ()
    "M2" => ()
    "M3" => ()
    "M4" => ()
    "M5" => ()
    "M6" => ()
    "M7" => ()
    "M8" => ()
    "M9" => ()
    "M10" => ()
    "M11" => ()
    "M12" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DynamicFilterType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DynamicFilterType::new(
  s : String,
) -> ST_DynamicFilterType raise SchemaViolation {
  ST_DynamicFilterType::parse(s)
}

///|
pub fn ST_DynamicFilterType::to_string(self : ST_DynamicFilterType) -> String {
  self.value
}

///|
pub struct ST_IconSetType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_IconSetType::parse(
  s : String,
) -> ST_IconSetType raise SchemaViolation {
  match s {
    "3Arrows" => ()
    "3ArrowsGray" => ()
    "3Flags" => ()
    "3TrafficLights1" => ()
    "3TrafficLights2" => ()
    "3Signs" => ()
    "3Symbols" => ()
    "3Symbols2" => ()
    "4Arrows" => ()
    "4ArrowsGray" => ()
    "4RedToBlack" => ()
    "4Rating" => ()
    "4TrafficLights" => ()
    "5Arrows" => ()
    "5ArrowsGray" => ()
    "5Rating" => ()
    "5Quarters" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_IconSetType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_IconSetType::new(s : String) -> ST_IconSetType raise SchemaViolation {
  ST_IconSetType::parse(s)
}

///|
pub fn ST_IconSetType::to_string(self : ST_IconSetType) -> String {
  self.value
}

///|
pub struct ST_SortBy {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SortBy::parse(s : String) -> ST_SortBy raise SchemaViolation {
  match s {
    "value" => ()
    "cellColor" => ()
    "fontColor" => ()
    "icon" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_SortBy",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_SortBy::new(s : String) -> ST_SortBy raise SchemaViolation {
  ST_SortBy::parse(s)
}

///|
pub fn ST_SortBy::to_string(self : ST_SortBy) -> String {
  self.value
}

///|
pub struct ST_SortMethod {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SortMethod::parse(s : String) -> ST_SortMethod raise SchemaViolation {
  match s {
    "stroke" => ()
    "pinYin" => ()
    "none" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_SortMethod",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_SortMethod::new(s : String) -> ST_SortMethod raise SchemaViolation {
  ST_SortMethod::parse(s)
}

///|
pub fn ST_SortMethod::to_string(self : ST_SortMethod) -> String {
  self.value
}

///|
pub struct ST_DateTimeGrouping {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DateTimeGrouping::parse(
  s : String,
) -> ST_DateTimeGrouping raise SchemaViolation {
  match s {
    "year" => ()
    "month" => ()
    "day" => ()
    "hour" => ()
    "minute" => ()
    "second" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DateTimeGrouping",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DateTimeGrouping::new(
  s : String,
) -> ST_DateTimeGrouping raise SchemaViolation {
  ST_DateTimeGrouping::parse(s)
}

///|
pub fn ST_DateTimeGrouping::to_string(self : ST_DateTimeGrouping) -> String {
  self.value
}

///|
pub struct ST_CellRef {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CellRef::parse(s : String) -> ST_CellRef raise SchemaViolation {
  validate_non_empty_token("ST_CellRef", s)
  { value: s }
}

///|
pub fn ST_CellRef::new(s : String) -> ST_CellRef raise SchemaViolation {
  ST_CellRef::parse(s)
}

///|
pub fn ST_CellRef::to_string(self : ST_CellRef) -> String {
  self.value
}

///|
pub struct ST_Ref {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Ref::parse(s : String) -> ST_Ref raise SchemaViolation {
  validate_non_empty_token("ST_Ref", s)
  { value: s }
}

///|
pub fn ST_Ref::new(s : String) -> ST_Ref raise SchemaViolation {
  ST_Ref::parse(s)
}

///|
pub fn ST_Ref::to_string(self : ST_Ref) -> String {
  self.value
}

///|
pub struct ST_RefA {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RefA::parse(s : String) -> ST_RefA raise SchemaViolation {
  validate_non_empty_token("ST_RefA", s)
  { value: s }
}

///|
pub fn ST_RefA::new(s : String) -> ST_RefA raise SchemaViolation {
  ST_RefA::parse(s)
}

///|
pub fn ST_RefA::to_string(self : ST_RefA) -> String {
  self.value
}

///|
pub struct ST_Sqref {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Sqref::parse(s : String) -> ST_Sqref raise SchemaViolation {
  validate_non_empty_token("ST_Sqref", s)
  { value: s }
}

///|
pub fn ST_Sqref::new(s : String) -> ST_Sqref raise SchemaViolation {
  ST_Sqref::parse(s)
}

///|
pub fn ST_Sqref::to_string(self : ST_Sqref) -> String {
  self.value
}

///|
pub struct ST_Formula {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Formula::parse(s : String) -> ST_Formula raise SchemaViolation {
  validate_non_empty_token("ST_Formula", s)
  { value: s }
}

///|
pub fn ST_Formula::new(s : String) -> ST_Formula raise SchemaViolation {
  ST_Formula::parse(s)
}

///|
pub fn ST_Formula::to_string(self : ST_Formula) -> String {
  self.value
}

///|
/// SpreadsheetML shared xstring value.
pub struct ST_Xstring {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Xstring::parse(s : String) -> ST_Xstring raise SchemaViolation {
  validate_xsd_string("ST_Xstring", s)
  { value: s }
}

///|
pub fn ST_Xstring::new(s : String) -> ST_Xstring raise SchemaViolation {
  ST_Xstring::parse(s)
}

///|
pub fn ST_Xstring::to_string(self : ST_Xstring) -> String {
  self.value
}

///|
pub struct ST_UnsignedIntHex {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_UnsignedIntHex::parse(
  s : String,
) -> ST_UnsignedIntHex raise SchemaViolation {
  validate_hex_token("ST_UnsignedIntHex", s)
  { value: s }
}

///|
pub fn ST_UnsignedIntHex::new(
  s : String,
) -> ST_UnsignedIntHex raise SchemaViolation {
  ST_UnsignedIntHex::parse(s)
}

///|
pub fn ST_UnsignedIntHex::to_string(self : ST_UnsignedIntHex) -> String {
  self.value
}

///|
pub struct ST_TextHAlign {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextHAlign::parse(s : String) -> ST_TextHAlign raise SchemaViolation {
  match s {
    "left" => ()
    "center" => ()
    "right" => ()
    "justify" => ()
    "distributed" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_TextHAlign",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_TextHAlign::new(s : String) -> ST_TextHAlign raise SchemaViolation {
  ST_TextHAlign::parse(s)
}

///|
pub fn ST_TextHAlign::to_string(self : ST_TextHAlign) -> String {
  self.value
}

///|
pub struct ST_TextVAlign {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextVAlign::parse(s : String) -> ST_TextVAlign raise SchemaViolation {
  match s {
    "top" => ()
    "center" => ()
    "bottom" => ()
    "justify" => ()
    "distributed" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_TextVAlign",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_TextVAlign::new(s : String) -> ST_TextVAlign raise SchemaViolation {
  ST_TextVAlign::parse(s)
}

///|
pub fn ST_TextVAlign::to_string(self : ST_TextVAlign) -> String {
  self.value
}

///|
pub struct ST_CredMethod {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CredMethod::parse(s : String) -> ST_CredMethod raise SchemaViolation {
  match s {
    "integrated" => ()
    "none" => ()
    "stored" => ()
    "prompt" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_CredMethod",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_CredMethod::new(s : String) -> ST_CredMethod raise SchemaViolation {
  ST_CredMethod::parse(s)
}

///|
pub fn ST_CredMethod::to_string(self : ST_CredMethod) -> String {
  self.value
}

///|
/// SpreadsheetML HTML import/export format values: none, rtf, all.
pub struct ST_HtmlFmt {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HtmlFmt::parse(s : String) -> ST_HtmlFmt raise SchemaViolation {
  match s {
    "none" => ()
    "rtf" => ()
    "all" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_HtmlFmt",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_HtmlFmt::new(s : String) -> ST_HtmlFmt raise SchemaViolation {
  ST_HtmlFmt::parse(s)
}

///|
pub fn ST_HtmlFmt::to_string(self : ST_HtmlFmt) -> String {
  self.value
}

///|
pub struct ST_ParameterType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ParameterType::parse(
  s : String,
) -> ST_ParameterType raise SchemaViolation {
  match s {
    "prompt" => ()
    "value" => ()
    "cell" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_ParameterType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_ParameterType::new(
  s : String,
) -> ST_ParameterType raise SchemaViolation {
  ST_ParameterType::parse(s)
}

///|
pub fn ST_ParameterType::to_string(self : ST_ParameterType) -> String {
  self.value
}

///|
pub struct ST_FileType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FileType::parse(s : String) -> ST_FileType raise SchemaViolation {
  match s {
    "mac" => ()
    "win" => ()
    "dos" => ()
    "lin" => ()
    "other" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_FileType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_FileType::new(s : String) -> ST_FileType raise SchemaViolation {
  ST_FileType::parse(s)
}

///|
pub fn ST_FileType::to_string(self : ST_FileType) -> String {
  self.value
}

///|
pub struct ST_Qualifier {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Qualifier::parse(s : String) -> ST_Qualifier raise SchemaViolation {
  match s {
    "doubleQuote" => ()
    "singleQuote" => ()
    "none" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Qualifier",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Qualifier::new(s : String) -> ST_Qualifier raise SchemaViolation {
  ST_Qualifier::parse(s)
}

///|
pub fn ST_Qualifier::to_string(self : ST_Qualifier) -> String {
  self.value
}

///|
pub struct ST_ExternalConnectionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ExternalConnectionType::parse(
  s : String,
) -> ST_ExternalConnectionType raise SchemaViolation {
  match s {
    "general" => ()
    "text" => ()
    "MDY" => ()
    "DMY" => ()
    "YMD" => ()
    "MYD" => ()
    "DYM" => ()
    "YDM" => ()
    "skip" => ()
    "EMD" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_ExternalConnectionType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_ExternalConnectionType::new(
  s : String,
) -> ST_ExternalConnectionType raise SchemaViolation {
  ST_ExternalConnectionType::parse(s)
}

///|
pub fn ST_ExternalConnectionType::to_string(
  self : ST_ExternalConnectionType,
) -> String {
  self.value
}

///|
pub struct ST_SourceType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SourceType::parse(s : String) -> ST_SourceType raise SchemaViolation {
  match s {
    "worksheet" => ()
    "external" => ()
    "consolidation" => ()
    "scenario" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_SourceType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_SourceType::new(s : String) -> ST_SourceType raise SchemaViolation {
  ST_SourceType::parse(s)
}

///|
pub fn ST_SourceType::to_string(self : ST_SourceType) -> String {
  self.value
}

///|
pub struct ST_GroupBy {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_GroupBy::parse(s : String) -> ST_GroupBy raise SchemaViolation {
  match s {
    "range" => ()
    "seconds" => ()
    "minutes" => ()
    "hours" => ()
    "days" => ()
    "months" => ()
    "quarters" => ()
    "years" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_GroupBy",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_GroupBy::new(s : String) -> ST_GroupBy raise SchemaViolation {
  ST_GroupBy::parse(s)
}

///|
pub fn ST_GroupBy::to_string(self : ST_GroupBy) -> String {
  self.value
}

///|
pub struct ST_SortType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SortType::parse(s : String) -> ST_SortType raise SchemaViolation {
  match s {
    "none" => ()
    "ascending" => ()
    "descending" => ()
    "ascendingAlpha" => ()
    "descendingAlpha" => ()
    "ascendingNatural" => ()
    "descendingNatural" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_SortType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_SortType::new(s : String) -> ST_SortType raise SchemaViolation {
  ST_SortType::parse(s)
}

///|
pub fn ST_SortType::to_string(self : ST_SortType) -> String {
  self.value
}

///|
pub struct ST_Scope {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Scope::parse(s : String) -> ST_Scope raise SchemaViolation {
  match s {
    "selection" => ()
    "data" => ()
    "field" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Scope",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Scope::new(s : String) -> ST_Scope raise SchemaViolation {
  ST_Scope::parse(s)
}

///|
pub fn ST_Scope::to_string(self : ST_Scope) -> String {
  self.value
}

///|
pub struct ST_Type {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Type::parse(s : String) -> ST_Type raise SchemaViolation {
  match s {
    "none" => ()
    "all" => ()
    "row" => ()
    "column" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Type",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Type::new(s : String) -> ST_Type raise SchemaViolation {
  ST_Type::parse(s)
}

///|
pub fn ST_Type::to_string(self : ST_Type) -> String {
  self.value
}

///|
pub struct ST_ShowDataAs {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ShowDataAs::parse(s : String) -> ST_ShowDataAs raise SchemaViolation {
  match s {
    "normal" => ()
    "difference" => ()
    "percent" => ()
    "percentDiff" => ()
    "runTotal" => ()
    "percentOfRow" => ()
    "percentOfCol" => ()
    "percentOfTotal" => ()
    "index" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_ShowDataAs",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_ShowDataAs::new(s : String) -> ST_ShowDataAs raise SchemaViolation {
  ST_ShowDataAs::parse(s)
}

///|
pub fn ST_ShowDataAs::to_string(self : ST_ShowDataAs) -> String {
  self.value
}

///|
pub struct ST_ItemType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ItemType::parse(s : String) -> ST_ItemType raise SchemaViolation {
  match s {
    "data" => ()
    "default" => ()
    "sum" => ()
    "countA" => ()
    "avg" => ()
    "max" => ()
    "min" => ()
    "product" => ()
    "count" => ()
    "stdDev" => ()
    "stdDevP" => ()
    "var" => ()
    "varP" => ()
    "grand" => ()
    "blank" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_ItemType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_ItemType::new(s : String) -> ST_ItemType raise SchemaViolation {
  ST_ItemType::parse(s)
}

///|
pub fn ST_ItemType::to_string(self : ST_ItemType) -> String {
  self.value
}

///|
pub struct ST_FormatAction {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FormatAction::parse(
  s : String,
) -> ST_FormatAction raise SchemaViolation {
  match s {
    "blank" => ()
    "formatting" => ()
    "drill" => ()
    "formula" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_FormatAction",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_FormatAction::new(
  s : String,
) -> ST_FormatAction raise SchemaViolation {
  ST_FormatAction::parse(s)
}

///|
pub fn ST_FormatAction::to_string(self : ST_FormatAction) -> String {
  self.value
}

///|
pub struct ST_FieldSortType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FieldSortType::parse(
  s : String,
) -> ST_FieldSortType raise SchemaViolation {
  match s {
    "manual" => ()
    "ascending" => ()
    "descending" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_FieldSortType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_FieldSortType::new(
  s : String,
) -> ST_FieldSortType raise SchemaViolation {
  ST_FieldSortType::parse(s)
}

///|
pub fn ST_FieldSortType::to_string(self : ST_FieldSortType) -> String {
  self.value
}

///|
pub struct ST_PivotFilterType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PivotFilterType::parse(
  s : String,
) -> ST_PivotFilterType raise SchemaViolation {
  match s {
    "unknown" => ()
    "count" => ()
    "percent" => ()
    "sum" => ()
    "captionEqual" => ()
    "captionNotEqual" => ()
    "captionBeginsWith" => ()
    "captionNotBeginsWith" => ()
    "captionEndsWith" => ()
    "captionNotEndsWith" => ()
    "captionContains" => ()
    "captionNotContains" => ()
    "captionGreaterThan" => ()
    "captionGreaterThanOrEqual" => ()
    "captionLessThan" => ()
    "captionLessThanOrEqual" => ()
    "captionBetween" => ()
    "captionNotBetween" => ()
    "valueEqual" => ()
    "valueNotEqual" => ()
    "valueGreaterThan" => ()
    "valueGreaterThanOrEqual" => ()
    "valueLessThan" => ()
    "valueLessThanOrEqual" => ()
    "valueBetween" => ()
    "valueNotBetween" => ()
    "dateEqual" => ()
    "dateNotEqual" => ()
    "dateOlderThan" => ()
    "dateOlderThanOrEqual" => ()
    "dateNewerThan" => ()
    "dateNewerThanOrEqual" => ()
    "dateBetween" => ()
    "dateNotBetween" => ()
    "tomorrow" => ()
    "today" => ()
    "yesterday" => ()
    "nextWeek" => ()
    "thisWeek" => ()
    "lastWeek" => ()
    "nextMonth" => ()
    "thisMonth" => ()
    "lastMonth" => ()
    "nextQuarter" => ()
    "thisQuarter" => ()
    "lastQuarter" => ()
    "nextYear" => ()
    "thisYear" => ()
    "lastYear" => ()
    "yearToDate" => ()
    "Q1" => ()
    "Q2" => ()
    "Q3" => ()
    "Q4" => ()
    "M1" => ()
    "M2" => ()
    "M3" => ()
    "M4" => ()
    "M5" => ()
    "M6" => ()
    "M7" => ()
    "M8" => ()
    "M9" => ()
    "M10" => ()
    "M11" => ()
    "M12" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_PivotFilterType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_PivotFilterType::new(
  s : String,
) -> ST_PivotFilterType raise SchemaViolation {
  ST_PivotFilterType::parse(s)
}

///|
pub fn ST_PivotFilterType::to_string(self : ST_PivotFilterType) -> String {
  self.value
}

///|
pub struct ST_PivotAreaType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PivotAreaType::parse(
  s : String,
) -> ST_PivotAreaType raise SchemaViolation {
  match s {
    "none" => ()
    "normal" => ()
    "data" => ()
    "all" => ()
    "origin" => ()
    "button" => ()
    "topEnd" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_PivotAreaType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_PivotAreaType::new(
  s : String,
) -> ST_PivotAreaType raise SchemaViolation {
  ST_PivotAreaType::parse(s)
}

///|
pub fn ST_PivotAreaType::to_string(self : ST_PivotAreaType) -> String {
  self.value
}

///|
pub struct ST_Axis {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Axis::parse(s : String) -> ST_Axis raise SchemaViolation {
  match s {
    "axisRow" => ()
    "axisCol" => ()
    "axisPage" => ()
    "axisValues" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Axis",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Axis::new(s : String) -> ST_Axis raise SchemaViolation {
  ST_Axis::parse(s)
}

///|
pub fn ST_Axis::to_string(self : ST_Axis) -> String {
  self.value
}

///|
pub struct ST_GrowShrinkType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_GrowShrinkType::parse(
  s : String,
) -> ST_GrowShrinkType raise SchemaViolation {
  match s {
    "insertDelete" => ()
    "insertClear" => ()
    "overwriteClear" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_GrowShrinkType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_GrowShrinkType::new(
  s : String,
) -> ST_GrowShrinkType raise SchemaViolation {
  ST_GrowShrinkType::parse(s)
}

///|
pub fn ST_GrowShrinkType::to_string(self : ST_GrowShrinkType) -> String {
  self.value
}

///|
pub struct ST_PhoneticType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PhoneticType::parse(
  s : String,
) -> ST_PhoneticType raise SchemaViolation {
  match s {
    "halfwidthKatakana" => ()
    "fullwidthKatakana" => ()
    "Hiragana" => ()
    "noConversion" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_PhoneticType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_PhoneticType::new(
  s : String,
) -> ST_PhoneticType raise SchemaViolation {
  ST_PhoneticType::parse(s)
}

///|
pub fn ST_PhoneticType::to_string(self : ST_PhoneticType) -> String {
  self.value
}

///|
pub struct ST_PhoneticAlignment {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PhoneticAlignment::parse(
  s : String,
) -> ST_PhoneticAlignment raise SchemaViolation {
  match s {
    "noControl" => ()
    "left" => ()
    "center" => ()
    "distributed" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_PhoneticAlignment",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_PhoneticAlignment::new(
  s : String,
) -> ST_PhoneticAlignment raise SchemaViolation {
  ST_PhoneticAlignment::parse(s)
}

///|
pub fn ST_PhoneticAlignment::to_string(self : ST_PhoneticAlignment) -> String {
  self.value
}

///|
pub struct ST_rwColActionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_rwColActionType::parse(
  s : String,
) -> ST_rwColActionType raise SchemaViolation {
  match s {
    "insertRow" => ()
    "deleteRow" => ()
    "insertCol" => ()
    "deleteCol" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_rwColActionType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_rwColActionType::new(
  s : String,
) -> ST_rwColActionType raise SchemaViolation {
  ST_rwColActionType::parse(s)
}

///|
pub fn ST_rwColActionType::to_string(self : ST_rwColActionType) -> String {
  self.value
}

///|
pub struct ST_RevisionAction {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RevisionAction::parse(
  s : String,
) -> ST_RevisionAction raise SchemaViolation {
  match s {
    "add" => ()
    "delete" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_RevisionAction",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_RevisionAction::new(
  s : String,
) -> ST_RevisionAction raise SchemaViolation {
  ST_RevisionAction::parse(s)
}

///|
pub fn ST_RevisionAction::to_string(self : ST_RevisionAction) -> String {
  self.value
}

///|
pub struct ST_FormulaExpression {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FormulaExpression::parse(
  s : String,
) -> ST_FormulaExpression raise SchemaViolation {
  match s {
    "ref" => ()
    "refError" => ()
    "area" => ()
    "areaError" => ()
    "computedArea" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_FormulaExpression",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_FormulaExpression::new(
  s : String,
) -> ST_FormulaExpression raise SchemaViolation {
  ST_FormulaExpression::parse(s)
}

///|
pub fn ST_FormulaExpression::to_string(self : ST_FormulaExpression) -> String {
  self.value
}

///|
pub struct ST_CellSpan {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CellSpan::parse(s : String) -> ST_CellSpan raise SchemaViolation {
  validate_non_empty_token("ST_CellSpan", s)
  { value: s }
}

///|
pub fn ST_CellSpan::new(s : String) -> ST_CellSpan raise SchemaViolation {
  ST_CellSpan::parse(s)
}

///|
pub fn ST_CellSpan::to_string(self : ST_CellSpan) -> String {
  self.value
}

///|
pub struct ST_CellSpans {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CellSpans::parse(s : String) -> ST_CellSpans raise SchemaViolation {
  validate_non_empty_token("ST_CellSpans", s)
  { value: s }
}

///|
pub fn ST_CellSpans::new(s : String) -> ST_CellSpans raise SchemaViolation {
  ST_CellSpans::parse(s)
}

///|
pub fn ST_CellSpans::to_string(self : ST_CellSpans) -> String {
  self.value
}

///|
pub struct ST_CellType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CellType::parse(s : String) -> ST_CellType raise SchemaViolation {
  match s {
    "b" => ()
    "d" => ()
    "n" => ()
    "e" => ()
    "s" => ()
    "str" => ()
    "inlineStr" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_CellType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_CellType::new(s : String) -> ST_CellType raise SchemaViolation {
  ST_CellType::parse(s)
}

///|
pub fn ST_CellType::to_string(self : ST_CellType) -> String {
  self.value
}

///|
pub struct ST_CellFormulaType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CellFormulaType::parse(
  s : String,
) -> ST_CellFormulaType raise SchemaViolation {
  match s {
    "normal" => ()
    "array" => ()
    "dataTable" => ()
    "shared" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_CellFormulaType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_CellFormulaType::new(
  s : String,
) -> ST_CellFormulaType raise SchemaViolation {
  ST_CellFormulaType::parse(s)
}

///|
pub fn ST_CellFormulaType::to_string(self : ST_CellFormulaType) -> String {
  self.value
}

///|
pub struct ST_Pane {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Pane::parse(s : String) -> ST_Pane raise SchemaViolation {
  match s {
    "bottomRight" => ()
    "topRight" => ()
    "bottomLeft" => ()
    "topLeft" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Pane",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Pane::new(s : String) -> ST_Pane raise SchemaViolation {
  ST_Pane::parse(s)
}

///|
pub fn ST_Pane::to_string(self : ST_Pane) -> String {
  self.value
}

///|
pub struct ST_SheetViewType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SheetViewType::parse(
  s : String,
) -> ST_SheetViewType raise SchemaViolation {
  match s {
    "normal" => ()
    "pageBreakPreview" => ()
    "pageLayout" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_SheetViewType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_SheetViewType::new(
  s : String,
) -> ST_SheetViewType raise SchemaViolation {
  ST_SheetViewType::parse(s)
}

///|
pub fn ST_SheetViewType::to_string(self : ST_SheetViewType) -> String {
  self.value
}

///|
pub struct ST_DataConsolidateFunction {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DataConsolidateFunction::parse(
  s : String,
) -> ST_DataConsolidateFunction raise SchemaViolation {
  match s {
    "average" => ()
    "count" => ()
    "countNums" => ()
    "max" => ()
    "min" => ()
    "product" => ()
    "stdDev" => ()
    "stdDevp" => ()
    "sum" => ()
    "var" => ()
    "varp" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DataConsolidateFunction",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DataConsolidateFunction::new(
  s : String,
) -> ST_DataConsolidateFunction raise SchemaViolation {
  ST_DataConsolidateFunction::parse(s)
}

///|
pub fn ST_DataConsolidateFunction::to_string(
  self : ST_DataConsolidateFunction,
) -> String {
  self.value
}

///|
pub struct ST_DataValidationType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DataValidationType::parse(
  s : String,
) -> ST_DataValidationType raise SchemaViolation {
  match s {
    "none" => ()
    "whole" => ()
    "decimal" => ()
    "list" => ()
    "date" => ()
    "time" => ()
    "textLength" => ()
    "custom" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DataValidationType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DataValidationType::new(
  s : String,
) -> ST_DataValidationType raise SchemaViolation {
  ST_DataValidationType::parse(s)
}

///|
pub fn ST_DataValidationType::to_string(self : ST_DataValidationType) -> String {
  self.value
}

///|
pub struct ST_DataValidationOperator {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DataValidationOperator::parse(
  s : String,
) -> ST_DataValidationOperator raise SchemaViolation {
  match s {
    "between" => ()
    "notBetween" => ()
    "equal" => ()
    "notEqual" => ()
    "lessThan" => ()
    "lessThanOrEqual" => ()
    "greaterThan" => ()
    "greaterThanOrEqual" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DataValidationOperator",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DataValidationOperator::new(
  s : String,
) -> ST_DataValidationOperator raise SchemaViolation {
  ST_DataValidationOperator::parse(s)
}

///|
pub fn ST_DataValidationOperator::to_string(
  self : ST_DataValidationOperator,
) -> String {
  self.value
}

///|
pub struct ST_DataValidationErrorStyle {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DataValidationErrorStyle::parse(
  s : String,
) -> ST_DataValidationErrorStyle raise SchemaViolation {
  match s {
    "stop" => ()
    "warning" => ()
    "information" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DataValidationErrorStyle",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DataValidationErrorStyle::new(
  s : String,
) -> ST_DataValidationErrorStyle raise SchemaViolation {
  ST_DataValidationErrorStyle::parse(s)
}

///|
pub fn ST_DataValidationErrorStyle::to_string(
  self : ST_DataValidationErrorStyle,
) -> String {
  self.value
}

///|
pub struct ST_DataValidationImeMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DataValidationImeMode::parse(
  s : String,
) -> ST_DataValidationImeMode raise SchemaViolation {
  match s {
    "noControl" => ()
    "off" => ()
    "on" => ()
    "disabled" => ()
    "hiragana" => ()
    "fullKatakana" => ()
    "halfKatakana" => ()
    "fullAlpha" => ()
    "halfAlpha" => ()
    "fullHangul" => ()
    "halfHangul" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DataValidationImeMode",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DataValidationImeMode::new(
  s : String,
) -> ST_DataValidationImeMode raise SchemaViolation {
  ST_DataValidationImeMode::parse(s)
}

///|
pub fn ST_DataValidationImeMode::to_string(
  self : ST_DataValidationImeMode,
) -> String {
  self.value
}

///|
pub struct ST_CfType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CfType::parse(s : String) -> ST_CfType raise SchemaViolation {
  match s {
    "expression" => ()
    "cellIs" => ()
    "colorScale" => ()
    "dataBar" => ()
    "iconSet" => ()
    "top10" => ()
    "uniqueValues" => ()
    "duplicateValues" => ()
    "containsText" => ()
    "notContainsText" => ()
    "beginsWith" => ()
    "endsWith" => ()
    "containsBlanks" => ()
    "notContainsBlanks" => ()
    "containsErrors" => ()
    "notContainsErrors" => ()
    "timePeriod" => ()
    "aboveAverage" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_CfType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_CfType::new(s : String) -> ST_CfType raise SchemaViolation {
  ST_CfType::parse(s)
}

///|
pub fn ST_CfType::to_string(self : ST_CfType) -> String {
  self.value
}

///|
pub struct ST_TimePeriod {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TimePeriod::parse(s : String) -> ST_TimePeriod raise SchemaViolation {
  match s {
    "today" => ()
    "yesterday" => ()
    "tomorrow" => ()
    "last7Days" => ()
    "thisMonth" => ()
    "lastMonth" => ()
    "nextMonth" => ()
    "thisWeek" => ()
    "lastWeek" => ()
    "nextWeek" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_TimePeriod",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_TimePeriod::new(s : String) -> ST_TimePeriod raise SchemaViolation {
  ST_TimePeriod::parse(s)
}

///|
pub fn ST_TimePeriod::to_string(self : ST_TimePeriod) -> String {
  self.value
}

///|
pub struct ST_ConditionalFormattingOperator {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ConditionalFormattingOperator::parse(
  s : String,
) -> ST_ConditionalFormattingOperator raise SchemaViolation {
  match s {
    "lessThan" => ()
    "lessThanOrEqual" => ()
    "equal" => ()
    "notEqual" => ()
    "greaterThanOrEqual" => ()
    "greaterThan" => ()
    "between" => ()
    "notBetween" => ()
    "containsText" => ()
    "notContains" => ()
    "beginsWith" => ()
    "endsWith" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_ConditionalFormattingOperator",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_ConditionalFormattingOperator::new(
  s : String,
) -> ST_ConditionalFormattingOperator raise SchemaViolation {
  ST_ConditionalFormattingOperator::parse(s)
}

///|
pub fn ST_ConditionalFormattingOperator::to_string(
  self : ST_ConditionalFormattingOperator,
) -> String {
  self.value
}

///|
pub struct ST_CfvoType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CfvoType::parse(s : String) -> ST_CfvoType raise SchemaViolation {
  match s {
    "num" => ()
    "percent" => ()
    "max" => ()
    "min" => ()
    "formula" => ()
    "percentile" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_CfvoType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_CfvoType::new(s : String) -> ST_CfvoType raise SchemaViolation {
  ST_CfvoType::parse(s)
}

///|
pub fn ST_CfvoType::to_string(self : ST_CfvoType) -> String {
  self.value
}

///|
pub struct ST_PageOrder {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PageOrder::parse(s : String) -> ST_PageOrder raise SchemaViolation {
  match s {
    "downThenOver" => ()
    "overThenDown" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_PageOrder",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_PageOrder::new(s : String) -> ST_PageOrder raise SchemaViolation {
  ST_PageOrder::parse(s)
}

///|
pub fn ST_PageOrder::to_string(self : ST_PageOrder) -> String {
  self.value
}

///|
pub struct ST_Orientation {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Orientation::parse(
  s : String,
) -> ST_Orientation raise SchemaViolation {
  match s {
    "default" => ()
    "portrait" => ()
    "landscape" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Orientation",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Orientation::new(s : String) -> ST_Orientation raise SchemaViolation {
  ST_Orientation::parse(s)
}

///|
pub fn ST_Orientation::to_string(self : ST_Orientation) -> String {
  self.value
}

///|
pub struct ST_CellComments {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CellComments::parse(
  s : String,
) -> ST_CellComments raise SchemaViolation {
  match s {
    "none" => ()
    "asDisplayed" => ()
    "atEnd" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_CellComments",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_CellComments::new(
  s : String,
) -> ST_CellComments raise SchemaViolation {
  ST_CellComments::parse(s)
}

///|
pub fn ST_CellComments::to_string(self : ST_CellComments) -> String {
  self.value
}

///|
pub struct ST_PrintError {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PrintError::parse(s : String) -> ST_PrintError raise SchemaViolation {
  match s {
    "displayed" => ()
    "blank" => ()
    "dash" => ()
    "NA" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_PrintError",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_PrintError::new(s : String) -> ST_PrintError raise SchemaViolation {
  ST_PrintError::parse(s)
}

///|
pub fn ST_PrintError::to_string(self : ST_PrintError) -> String {
  self.value
}

///|
pub struct ST_DvAspect {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DvAspect::parse(s : String) -> ST_DvAspect raise SchemaViolation {
  match s {
    "DVASPECT_CONTENT" => ()
    "DVASPECT_ICON" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DvAspect",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DvAspect::new(s : String) -> ST_DvAspect raise SchemaViolation {
  ST_DvAspect::parse(s)
}

///|
pub fn ST_DvAspect::to_string(self : ST_DvAspect) -> String {
  self.value
}

///|
pub struct ST_OleUpdate {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_OleUpdate::parse(s : String) -> ST_OleUpdate raise SchemaViolation {
  match s {
    "OLEUPDATE_ALWAYS" => ()
    "OLEUPDATE_ONCALL" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_OleUpdate",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_OleUpdate::new(s : String) -> ST_OleUpdate raise SchemaViolation {
  ST_OleUpdate::parse(s)
}

///|
pub fn ST_OleUpdate::to_string(self : ST_OleUpdate) -> String {
  self.value
}

///|
pub struct ST_WebSourceType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_WebSourceType::parse(
  s : String,
) -> ST_WebSourceType raise SchemaViolation {
  match s {
    "sheet" => ()
    "printArea" => ()
    "autoFilter" => ()
    "range" => ()
    "chart" => ()
    "pivotTable" => ()
    "query" => ()
    "label" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_WebSourceType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_WebSourceType::new(
  s : String,
) -> ST_WebSourceType raise SchemaViolation {
  ST_WebSourceType::parse(s)
}

///|
pub fn ST_WebSourceType::to_string(self : ST_WebSourceType) -> String {
  self.value
}

///|
pub struct ST_PaneState {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PaneState::parse(s : String) -> ST_PaneState raise SchemaViolation {
  match s {
    "split" => ()
    "frozen" => ()
    "frozenSplit" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_PaneState",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_PaneState::new(s : String) -> ST_PaneState raise SchemaViolation {
  ST_PaneState::parse(s)
}

///|
pub fn ST_PaneState::to_string(self : ST_PaneState) -> String {
  self.value
}

///|
pub struct ST_MdxFunctionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MdxFunctionType::parse(
  s : String,
) -> ST_MdxFunctionType raise SchemaViolation {
  match s {
    "m" => ()
    "v" => ()
    "s" => ()
    "c" => ()
    "r" => ()
    "p" => ()
    "k" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_MdxFunctionType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_MdxFunctionType::new(
  s : String,
) -> ST_MdxFunctionType raise SchemaViolation {
  ST_MdxFunctionType::parse(s)
}

///|
pub fn ST_MdxFunctionType::to_string(self : ST_MdxFunctionType) -> String {
  self.value
}

///|
pub struct ST_MdxSetOrder {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MdxSetOrder::parse(
  s : String,
) -> ST_MdxSetOrder raise SchemaViolation {
  match s {
    "u" => ()
    "a" => ()
    "d" => ()
    "aa" => ()
    "ad" => ()
    "na" => ()
    "nd" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_MdxSetOrder",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_MdxSetOrder::new(s : String) -> ST_MdxSetOrder raise SchemaViolation {
  ST_MdxSetOrder::parse(s)
}

///|
pub fn ST_MdxSetOrder::to_string(self : ST_MdxSetOrder) -> String {
  self.value
}

///|
pub struct ST_MdxKPIProperty {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MdxKPIProperty::parse(
  s : String,
) -> ST_MdxKPIProperty raise SchemaViolation {
  match s {
    "v" => ()
    "g" => ()
    "s" => ()
    "t" => ()
    "w" => ()
    "m" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_MdxKPIProperty",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_MdxKPIProperty::new(
  s : String,
) -> ST_MdxKPIProperty raise SchemaViolation {
  ST_MdxKPIProperty::parse(s)
}

///|
pub fn ST_MdxKPIProperty::to_string(self : ST_MdxKPIProperty) -> String {
  self.value
}

///|
pub struct ST_TextRotation {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextRotation::parse(
  s : String,
) -> ST_TextRotation raise SchemaViolation {
  match s {
    "255" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_TextRotation",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_TextRotation::new(
  s : String,
) -> ST_TextRotation raise SchemaViolation {
  ST_TextRotation::parse(s)
}

///|
pub fn ST_TextRotation::to_string(self : ST_TextRotation) -> String {
  self.value
}

///|
pub struct ST_BorderStyle {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_BorderStyle::parse(
  s : String,
) -> ST_BorderStyle raise SchemaViolation {
  match s {
    "none" => ()
    "thin" => ()
    "medium" => ()
    "dashed" => ()
    "dotted" => ()
    "thick" => ()
    "double" => ()
    "hair" => ()
    "mediumDashed" => ()
    "dashDot" => ()
    "mediumDashDot" => ()
    "dashDotDot" => ()
    "mediumDashDotDot" => ()
    "slantDashDot" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_BorderStyle",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_BorderStyle::new(s : String) -> ST_BorderStyle raise SchemaViolation {
  ST_BorderStyle::parse(s)
}

///|
pub fn ST_BorderStyle::to_string(self : ST_BorderStyle) -> String {
  self.value
}

///|
pub struct ST_PatternType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PatternType::parse(
  s : String,
) -> ST_PatternType raise SchemaViolation {
  match s {
    "none" => ()
    "solid" => ()
    "mediumGray" => ()
    "darkGray" => ()
    "lightGray" => ()
    "darkHorizontal" => ()
    "darkVertical" => ()
    "darkDown" => ()
    "darkUp" => ()
    "darkGrid" => ()
    "darkTrellis" => ()
    "lightHorizontal" => ()
    "lightVertical" => ()
    "lightDown" => ()
    "lightUp" => ()
    "lightGrid" => ()
    "lightTrellis" => ()
    "gray125" => ()
    "gray0625" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_PatternType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_PatternType::new(s : String) -> ST_PatternType raise SchemaViolation {
  ST_PatternType::parse(s)
}

///|
pub fn ST_PatternType::to_string(self : ST_PatternType) -> String {
  self.value
}

///|
pub struct ST_GradientType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_GradientType::parse(
  s : String,
) -> ST_GradientType raise SchemaViolation {
  match s {
    "linear" => ()
    "path" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_GradientType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_GradientType::new(
  s : String,
) -> ST_GradientType raise SchemaViolation {
  ST_GradientType::parse(s)
}

///|
pub fn ST_GradientType::to_string(self : ST_GradientType) -> String {
  self.value
}

///|
pub struct ST_HorizontalAlignment {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HorizontalAlignment::parse(
  s : String,
) -> ST_HorizontalAlignment raise SchemaViolation {
  match s {
    "general" => ()
    "left" => ()
    "center" => ()
    "right" => ()
    "fill" => ()
    "justify" => ()
    "centerContinuous" => ()
    "distributed" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_HorizontalAlignment",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_HorizontalAlignment::new(
  s : String,
) -> ST_HorizontalAlignment raise SchemaViolation {
  ST_HorizontalAlignment::parse(s)
}

///|
pub fn ST_HorizontalAlignment::to_string(
  self : ST_HorizontalAlignment,
) -> String {
  self.value
}

///|
pub struct ST_VerticalAlignment {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_VerticalAlignment::parse(
  s : String,
) -> ST_VerticalAlignment raise SchemaViolation {
  match s {
    "top" => ()
    "center" => ()
    "bottom" => ()
    "justify" => ()
    "distributed" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_VerticalAlignment",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_VerticalAlignment::new(
  s : String,
) -> ST_VerticalAlignment raise SchemaViolation {
  ST_VerticalAlignment::parse(s)
}

///|
pub fn ST_VerticalAlignment::to_string(self : ST_VerticalAlignment) -> String {
  self.value
}

///|
pub struct ST_NumFmtId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_NumFmtId::parse(s : String) -> ST_NumFmtId raise SchemaViolation {
  validate_non_negative_integer("ST_NumFmtId", s)
  { value: s }
}

///|
pub fn ST_NumFmtId::new(s : String) -> ST_NumFmtId raise SchemaViolation {
  ST_NumFmtId::parse(s)
}

///|
pub fn ST_NumFmtId::to_string(self : ST_NumFmtId) -> String {
  self.value
}

///|
pub struct ST_FontId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FontId::parse(s : String) -> ST_FontId raise SchemaViolation {
  validate_non_negative_integer("ST_FontId", s)
  { value: s }
}

///|
pub fn ST_FontId::new(s : String) -> ST_FontId raise SchemaViolation {
  ST_FontId::parse(s)
}

///|
pub fn ST_FontId::to_string(self : ST_FontId) -> String {
  self.value
}

///|
pub struct ST_FillId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FillId::parse(s : String) -> ST_FillId raise SchemaViolation {
  validate_non_negative_integer("ST_FillId", s)
  { value: s }
}

///|
pub fn ST_FillId::new(s : String) -> ST_FillId raise SchemaViolation {
  ST_FillId::parse(s)
}

///|
pub fn ST_FillId::to_string(self : ST_FillId) -> String {
  self.value
}

///|
pub struct ST_BorderId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_BorderId::parse(s : String) -> ST_BorderId raise SchemaViolation {
  validate_non_negative_integer("ST_BorderId", s)
  { value: s }
}

///|
pub fn ST_BorderId::new(s : String) -> ST_BorderId raise SchemaViolation {
  ST_BorderId::parse(s)
}

///|
pub fn ST_BorderId::to_string(self : ST_BorderId) -> String {
  self.value
}

///|
pub struct ST_CellStyleXfId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CellStyleXfId::parse(
  s : String,
) -> ST_CellStyleXfId raise SchemaViolation {
  validate_non_negative_integer("ST_CellStyleXfId", s)
  { value: s }
}

///|
pub fn ST_CellStyleXfId::new(
  s : String,
) -> ST_CellStyleXfId raise SchemaViolation {
  ST_CellStyleXfId::parse(s)
}

///|
pub fn ST_CellStyleXfId::to_string(self : ST_CellStyleXfId) -> String {
  self.value
}

///|
pub struct ST_DxfId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DxfId::parse(s : String) -> ST_DxfId raise SchemaViolation {
  validate_non_negative_integer("ST_DxfId", s)
  { value: s }
}

///|
pub fn ST_DxfId::new(s : String) -> ST_DxfId raise SchemaViolation {
  ST_DxfId::parse(s)
}

///|
pub fn ST_DxfId::to_string(self : ST_DxfId) -> String {
  self.value
}

///|
pub struct ST_TableStyleType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TableStyleType::parse(
  s : String,
) -> ST_TableStyleType raise SchemaViolation {
  match s {
    "wholeTable" => ()
    "headerRow" => ()
    "totalRow" => ()
    "firstColumn" => ()
    "lastColumn" => ()
    "firstRowStripe" => ()
    "secondRowStripe" => ()
    "firstColumnStripe" => ()
    "secondColumnStripe" => ()
    "firstHeaderCell" => ()
    "lastHeaderCell" => ()
    "firstTotalCell" => ()
    "lastTotalCell" => ()
    "firstSubtotalColumn" => ()
    "secondSubtotalColumn" => ()
    "thirdSubtotalColumn" => ()
    "firstSubtotalRow" => ()
    "secondSubtotalRow" => ()
    "thirdSubtotalRow" => ()
    "blankRow" => ()
    "firstColumnSubheading" => ()
    "secondColumnSubheading" => ()
    "thirdColumnSubheading" => ()
    "firstRowSubheading" => ()
    "secondRowSubheading" => ()
    "thirdRowSubheading" => ()
    "pageFieldLabels" => ()
    "pageFieldValues" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_TableStyleType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_TableStyleType::new(
  s : String,
) -> ST_TableStyleType raise SchemaViolation {
  ST_TableStyleType::parse(s)
}

///|
pub fn ST_TableStyleType::to_string(self : ST_TableStyleType) -> String {
  self.value
}

///|
pub struct ST_FontScheme {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FontScheme::parse(s : String) -> ST_FontScheme raise SchemaViolation {
  match s {
    "none" => ()
    "major" => ()
    "minor" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_FontScheme",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_FontScheme::new(s : String) -> ST_FontScheme raise SchemaViolation {
  ST_FontScheme::parse(s)
}

///|
pub fn ST_FontScheme::to_string(self : ST_FontScheme) -> String {
  self.value
}

///|
pub struct ST_UnderlineValues {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_UnderlineValues::parse(
  s : String,
) -> ST_UnderlineValues raise SchemaViolation {
  match s {
    "single" => ()
    "double" => ()
    "singleAccounting" => ()
    "doubleAccounting" => ()
    "none" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_UnderlineValues",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_UnderlineValues::new(
  s : String,
) -> ST_UnderlineValues raise SchemaViolation {
  ST_UnderlineValues::parse(s)
}

///|
pub fn ST_UnderlineValues::to_string(self : ST_UnderlineValues) -> String {
  self.value
}

///|
pub struct ST_FontFamily {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FontFamily::parse(s : String) -> ST_FontFamily raise SchemaViolation {
  validate_integer("ST_FontFamily", s)
  { value: s }
}

///|
pub fn ST_FontFamily::new(s : String) -> ST_FontFamily raise SchemaViolation {
  ST_FontFamily::parse(s)
}

///|
pub fn ST_FontFamily::to_string(self : ST_FontFamily) -> String {
  self.value
}

///|
pub struct ST_DdeValueType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DdeValueType::parse(
  s : String,
) -> ST_DdeValueType raise SchemaViolation {
  match s {
    "nil" => ()
    "b" => ()
    "n" => ()
    "e" => ()
    "str" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_DdeValueType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_DdeValueType::new(
  s : String,
) -> ST_DdeValueType raise SchemaViolation {
  ST_DdeValueType::parse(s)
}

///|
pub fn ST_DdeValueType::to_string(self : ST_DdeValueType) -> String {
  self.value
}

///|
pub struct ST_TableType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TableType::parse(s : String) -> ST_TableType raise SchemaViolation {
  match s {
    "worksheet" => ()
    "xml" => ()
    "queryTable" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_TableType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_TableType::new(s : String) -> ST_TableType raise SchemaViolation {
  ST_TableType::parse(s)
}

///|
pub fn ST_TableType::to_string(self : ST_TableType) -> String {
  self.value
}

///|
pub struct ST_TotalsRowFunction {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TotalsRowFunction::parse(
  s : String,
) -> ST_TotalsRowFunction raise SchemaViolation {
  match s {
    "none" => ()
    "sum" => ()
    "min" => ()
    "max" => ()
    "average" => ()
    "count" => ()
    "countNums" => ()
    "stdDev" => ()
    "var" => ()
    "custom" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_TotalsRowFunction",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_TotalsRowFunction::new(
  s : String,
) -> ST_TotalsRowFunction raise SchemaViolation {
  ST_TotalsRowFunction::parse(s)
}

///|
pub fn ST_TotalsRowFunction::to_string(self : ST_TotalsRowFunction) -> String {
  self.value
}

///|
pub struct ST_XmlDataType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_XmlDataType::parse(
  s : String,
) -> ST_XmlDataType raise SchemaViolation {
  validate_non_empty_token("ST_XmlDataType", s)
  { value: s }
}

///|
pub fn ST_XmlDataType::new(s : String) -> ST_XmlDataType raise SchemaViolation {
  ST_XmlDataType::parse(s)
}

///|
pub fn ST_XmlDataType::to_string(self : ST_XmlDataType) -> String {
  self.value
}

///|
pub struct ST_VolDepType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_VolDepType::parse(s : String) -> ST_VolDepType raise SchemaViolation {
  match s {
    "realTimeData" => ()
    "olapFunctions" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_VolDepType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_VolDepType::new(s : String) -> ST_VolDepType raise SchemaViolation {
  ST_VolDepType::parse(s)
}

///|
pub fn ST_VolDepType::to_string(self : ST_VolDepType) -> String {
  self.value
}

///|
pub struct ST_VolValueType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_VolValueType::parse(
  s : String,
) -> ST_VolValueType raise SchemaViolation {
  match s {
    "b" => ()
    "n" => ()
    "e" => ()
    "s" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_VolValueType",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_VolValueType::new(
  s : String,
) -> ST_VolValueType raise SchemaViolation {
  ST_VolValueType::parse(s)
}

///|
pub fn ST_VolValueType::to_string(self : ST_VolValueType) -> String {
  self.value
}

///|
pub struct ST_Visibility {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Visibility::parse(s : String) -> ST_Visibility raise SchemaViolation {
  match s {
    "visible" => ()
    "hidden" => ()
    "veryHidden" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Visibility",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Visibility::new(s : String) -> ST_Visibility raise SchemaViolation {
  ST_Visibility::parse(s)
}

///|
pub fn ST_Visibility::to_string(self : ST_Visibility) -> String {
  self.value
}

///|
pub struct ST_Comments {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Comments::parse(s : String) -> ST_Comments raise SchemaViolation {
  match s {
    "commNone" => ()
    "commIndicator" => ()
    "commIndAndComment" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Comments",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Comments::new(s : String) -> ST_Comments raise SchemaViolation {
  ST_Comments::parse(s)
}

///|
pub fn ST_Comments::to_string(self : ST_Comments) -> String {
  self.value
}

///|
pub struct ST_Objects {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Objects::parse(s : String) -> ST_Objects raise SchemaViolation {
  match s {
    "all" => ()
    "placeholders" => ()
    "none" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_Objects",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_Objects::new(s : String) -> ST_Objects raise SchemaViolation {
  ST_Objects::parse(s)
}

///|
pub fn ST_Objects::to_string(self : ST_Objects) -> String {
  self.value
}

///|
pub struct ST_SheetState {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SheetState::parse(s : String) -> ST_SheetState raise SchemaViolation {
  match s {
    "visible" => ()
    "hidden" => ()
    "veryHidden" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_SheetState",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_SheetState::new(s : String) -> ST_SheetState raise SchemaViolation {
  ST_SheetState::parse(s)
}

///|
pub fn ST_SheetState::to_string(self : ST_SheetState) -> String {
  self.value
}

///|
pub struct ST_UpdateLinks {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_UpdateLinks::parse(
  s : String,
) -> ST_UpdateLinks raise SchemaViolation {
  match s {
    "userSet" => ()
    "never" => ()
    "always" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_UpdateLinks",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_UpdateLinks::new(s : String) -> ST_UpdateLinks raise SchemaViolation {
  ST_UpdateLinks::parse(s)
}

///|
pub fn ST_UpdateLinks::to_string(self : ST_UpdateLinks) -> String {
  self.value
}

///|
pub struct ST_SmartTagShow {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SmartTagShow::parse(
  s : String,
) -> ST_SmartTagShow raise SchemaViolation {
  match s {
    "all" => ()
    "none" => ()
    "noIndicator" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_SmartTagShow",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_SmartTagShow::new(
  s : String,
) -> ST_SmartTagShow raise SchemaViolation {
  ST_SmartTagShow::parse(s)
}

///|
pub fn ST_SmartTagShow::to_string(self : ST_SmartTagShow) -> String {
  self.value
}

///|
pub struct ST_CalcMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CalcMode::parse(s : String) -> ST_CalcMode raise SchemaViolation {
  match s {
    "manual" => ()
    "auto" => ()
    "autoNoTable" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_CalcMode",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_CalcMode::new(s : String) -> ST_CalcMode raise SchemaViolation {
  ST_CalcMode::parse(s)
}

///|
pub fn ST_CalcMode::to_string(self : ST_CalcMode) -> String {
  self.value
}

///|
/// SpreadsheetML formula reference mode values: A1 and R1C1.
pub struct ST_RefMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RefMode::parse(s : String) -> ST_RefMode raise SchemaViolation {
  match s {
    "A1" => ()
    "R1C1" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_RefMode",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_RefMode::new(s : String) -> ST_RefMode raise SchemaViolation {
  ST_RefMode::parse(s)
}

///|
pub fn ST_RefMode::to_string(self : ST_RefMode) -> String {
  self.value
}

///|
pub struct ST_TargetScreenSize {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TargetScreenSize::parse(
  s : String,
) -> ST_TargetScreenSize raise SchemaViolation {
  match s {
    "544x376" => ()
    "640x480" => ()
    "720x512" => ()
    "800x600" => ()
    "1024x768" => ()
    "1152x882" => ()
    "1152x900" => ()
    "1280x1024" => ()
    "1600x1200" => ()
    "1800x1440" => ()
    "1920x1200" => ()
    _ =>
      raise SchemaViolation(
        schema="sml.xsd",
        path="ST_TargetScreenSize",
        reason="value is outside the allowed enumeration",
      )
  }
  { value: s }
}

///|
pub fn ST_TargetScreenSize::new(
  s : String,
) -> ST_TargetScreenSize raise SchemaViolation {
  ST_TargetScreenSize::parse(s)
}

///|
pub fn ST_TargetScreenSize::to_string(self : ST_TargetScreenSize) -> String {
  self.value
}

///|
/// Schema sml.xsd simple type `ST_UnsignedShortHex` — §18.18.94. Base
/// `xsd:hexBinary` with `length=2` (exactly two hex octets, i.e. four hex
/// digits) representing an unsigned 16-bit value stored as the lexical
/// hex token. The constructor enforces the four-hex-digit length and the
/// hex-digit charset; case is preserved verbatim.
pub struct ST_UnsignedShortHex {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_UnsignedShortHex lexical value, requiring exactly two
/// hex octets (four hex digits).
pub fn ST_UnsignedShortHex::parse(
  s : String,
) -> ST_UnsignedShortHex raise SchemaViolation {
  if s.length() != 4 || !is_hex_digits(s) {
    raise SchemaViolation(
      schema="sml.xsd",
      path="ST_UnsignedShortHex",
      reason="value must be exactly four hexadecimal digits",
    )
  }
  { value: s }
}

///|
pub fn ST_UnsignedShortHex::new(
  s : String,
) -> ST_UnsignedShortHex raise SchemaViolation {
  ST_UnsignedShortHex::parse(s)
}

///|
pub fn ST_UnsignedShortHex::to_string(self : ST_UnsignedShortHex) -> String {
  self.value
}

///|
fn validate_non_empty_token(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="sml.xsd",
      path=type_name,
      reason="empty token",
    )
  }
}

///|
fn validate_xsd_string(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() < 0 {
    raise SchemaViolation(
      schema="sml.xsd",
      path=type_name,
      reason="invalid xsd:string token",
    )
  }
}

///|
fn validate_integer(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if !is_signed_digits(value) {
    raise SchemaViolation(
      schema="sml.xsd",
      path=type_name,
      reason="invalid integer token",
    )
  }
}

///|
fn validate_non_negative_integer(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  validate_integer(type_name, value)
  if value.length() > 0 && value[0:1] == "-" {
    raise SchemaViolation(
      schema="sml.xsd",
      path=type_name,
      reason="negative value is not allowed",
    )
  }
}

///|
fn validate_hex_token(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 || value.length() % 2 != 0 || !is_hex_digits(value) {
    raise SchemaViolation(
      schema="sml.xsd",
      path=type_name,
      reason="invalid hexadecimal token",
    )
  }
}

///|
fn is_signed_digits(value : String) -> Bool {
  if value.length() == 0 {
    false
  } else {
    let mut start = 0
    if value[0:1] == "-" || value[0:1] == "+" {
      start = 1
    }
    let mut ok = start < value.length()
    for i in start..<value.length() {
      let ch = value[i:i + 1]
      ok = ok && ch >= "0" && ch <= "9"
    }
    ok
  }
}

///|
fn is_hex_digits(value : String) -> Bool {
  let mut ok = true
  for i in 0..<value.length() {
    let ch = value[i:i + 1]
    ok = ok &&
      (
        (ch >= "0" && ch <= "9") ||
        (ch >= "a" && ch <= "f") ||
        (ch >= "A" && ch <= "F")
      )
  }
  ok
}
