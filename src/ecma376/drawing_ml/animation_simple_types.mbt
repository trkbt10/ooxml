// trkbt10/ooxml/ecma376/drawing_ml — animation & blip simple types
//
// ECMA-376 Part 1 §20.1.2 / §20.1.8 simple-type enumerations consumed
// by the chunk1 typed CT_* wrappers. Each enum mirrors the closed
// xsd:restriction token list verbatim from Annex A.4.1 dml-main.xsd so
// the implementation cannot drift away from the schema text.

///|
/// XSD simple type ST_DgmBuildStep — Part 1 §20.1.10.20. Annex A.4.1
/// lines 864..869. Used by `dgm/@bldStep` (CT_AnimationDgmElement) to
/// pick between animating the shape body (`sp`) or background (`bg`).
pub(all) enum ST_DgmBuildStep {
  /// `sp` — animate the diagram shape body.
  DgmBuildSp
  /// `bg` — animate the diagram background.
  DgmBuildBg
} derive(Eq, Debug)

///|
/// Decode a lexical token into ST_DgmBuildStep. Unknown lexical forms
/// raise SchemaViolation with the canonical schema/path.
pub fn ST_DgmBuildStep::parse(
  value : String,
) -> ST_DgmBuildStep raise SchemaViolation {
  match value {
    "sp" => DgmBuildSp
    "bg" => DgmBuildBg
    _ =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="ST_DgmBuildStep",
        reason="unknown ST_DgmBuildStep lexical value: " + value,
      )
  }
}

///|
/// Re-encode ST_DgmBuildStep into its canonical lexical form.
pub fn ST_DgmBuildStep::to_string(self : ST_DgmBuildStep) -> String {
  match self {
    DgmBuildSp => "sp"
    DgmBuildBg => "bg"
  }
}

///|
/// XSD simple type ST_ChartBuildStep — Part 1 §20.1.10.13. Annex A.4.1
/// lines 854..863. Used by `chart/@bldStep`
/// (CT_AnimationChartElement) to pick which axis of a chart animation
/// step is being driven.
pub(all) enum ST_ChartBuildStep {
  /// `category` — animate by chart category.
  ChartBuildCategory
  /// `ptInCategory` — animate by point within a category.
  ChartBuildPtInCategory
  /// `series` — animate by chart series.
  ChartBuildSeries
  /// `ptInSeries` — animate by point within a series.
  ChartBuildPtInSeries
  /// `allPts` — animate every data point.
  ChartBuildAllPts
  /// `gridLegend` — animate the grid and legend together.
  ChartBuildGridLegend
} derive(Eq, Debug)

///|
pub fn ST_ChartBuildStep::parse(
  value : String,
) -> ST_ChartBuildStep raise SchemaViolation {
  match value {
    "category" => ChartBuildCategory
    "ptInCategory" => ChartBuildPtInCategory
    "series" => ChartBuildSeries
    "ptInSeries" => ChartBuildPtInSeries
    "allPts" => ChartBuildAllPts
    "gridLegend" => ChartBuildGridLegend
    _ =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="ST_ChartBuildStep",
        reason="unknown ST_ChartBuildStep lexical value: " + value,
      )
  }
}

///|
pub fn ST_ChartBuildStep::to_string(self : ST_ChartBuildStep) -> String {
  match self {
    ChartBuildCategory => "category"
    ChartBuildPtInCategory => "ptInCategory"
    ChartBuildSeries => "series"
    ChartBuildPtInSeries => "ptInSeries"
    ChartBuildAllPts => "allPts"
    ChartBuildGridLegend => "gridLegend"
  }
}

///|
/// XSD simple type ST_AnimationDgmBuildType — Part 1 §20.1.10.6.
/// Annex A.4.1 line 898 union of ST_AnimationBuildType ("allAtOnce")
/// and ST_AnimationDgmOnlyBuildType ("one", "lvlOne", "lvlAtOnce").
/// Used by `bldDgm/@bld` (CT_AnimationDgmBuildProperties).
pub(all) enum ST_AnimationDgmBuildType {
  /// `allAtOnce` — single-pass build (shared with ST_AnimationBuildType).
  DgmBuildAllAtOnce
  /// `one` — build each shape in succession.
  DgmBuildOne
  /// `lvlOne` — build one level at a time.
  DgmBuildLvlOne
  /// `lvlAtOnce` — build all shapes of a level simultaneously.
  DgmBuildLvlAtOnce
} derive(Eq, Debug)

///|
pub fn ST_AnimationDgmBuildType::parse(
  value : String,
) -> ST_AnimationDgmBuildType raise SchemaViolation {
  match value {
    "allAtOnce" => DgmBuildAllAtOnce
    "one" => DgmBuildOne
    "lvlOne" => DgmBuildLvlOne
    "lvlAtOnce" => DgmBuildLvlAtOnce
    _ =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="ST_AnimationDgmBuildType",
        reason="unknown ST_AnimationDgmBuildType lexical value: " + value,
      )
  }
}

///|
pub fn ST_AnimationDgmBuildType::to_string(
  self : ST_AnimationDgmBuildType,
) -> String {
  match self {
    DgmBuildAllAtOnce => "allAtOnce"
    DgmBuildOne => "one"
    DgmBuildLvlOne => "lvlOne"
    DgmBuildLvlAtOnce => "lvlAtOnce"
  }
}

///|
/// XSD simple type ST_AnimationChartBuildType — Part 1 §20.1.10.4.
/// Annex A.4.1 line 913 union of ST_AnimationBuildType ("allAtOnce")
/// and ST_AnimationChartOnlyBuildType ("series", "category",
/// "seriesEl", "categoryEl"). Used by `bldChart/@bld`
/// (CT_AnimationChartBuildProperties).
pub(all) enum ST_AnimationChartBuildType {
  /// `allAtOnce` — single-pass build.
  ChartBuildAllAtOnce
  /// `series` — build each series in succession.
  ChartBuildBySeries
  /// `category` — build each category in succession.
  ChartBuildByCategory
  /// `seriesEl` — build each element of a series.
  ChartBuildBySeriesEl
  /// `categoryEl` — build each element of a category.
  ChartBuildByCategoryEl
} derive(Eq, Debug)

///|
pub fn ST_AnimationChartBuildType::parse(
  value : String,
) -> ST_AnimationChartBuildType raise SchemaViolation {
  match value {
    "allAtOnce" => ChartBuildAllAtOnce
    "series" => ChartBuildBySeries
    "category" => ChartBuildByCategory
    "seriesEl" => ChartBuildBySeriesEl
    "categoryEl" => ChartBuildByCategoryEl
    _ =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="ST_AnimationChartBuildType",
        reason="unknown ST_AnimationChartBuildType lexical value: " + value,
      )
  }
}

///|
pub fn ST_AnimationChartBuildType::to_string(
  self : ST_AnimationChartBuildType,
) -> String {
  match self {
    ChartBuildAllAtOnce => "allAtOnce"
    ChartBuildBySeries => "series"
    ChartBuildByCategory => "category"
    ChartBuildBySeriesEl => "seriesEl"
    ChartBuildByCategoryEl => "categoryEl"
  }
}

///|
/// XSD simple type ST_BlipCompression — Part 1 §20.1.10.12. Annex
/// A.4.1 lines 1465..1474. Used by `blip/@cstate` (CT_Blip) to mark
/// the compression target / fidelity of the embedded media.
pub(all) enum ST_BlipCompression {
  /// `email` — heavily compressed for e-mail attachment fidelity.
  BlipCstateEmail
  /// `screen` — compressed for on-screen display fidelity.
  BlipCstateScreen
  /// `print` — compressed for print fidelity.
  BlipCstatePrint
  /// `hqprint` — high-quality print fidelity.
  BlipCstateHqPrint
  /// `none` — no compression applied (default).
  BlipCstateNone
} derive(Eq, Debug)

///|
pub fn ST_BlipCompression::parse(
  value : String,
) -> ST_BlipCompression raise SchemaViolation {
  match value {
    "email" => BlipCstateEmail
    "screen" => BlipCstateScreen
    "print" => BlipCstatePrint
    "hqprint" => BlipCstateHqPrint
    "none" => BlipCstateNone
    _ =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="ST_BlipCompression",
        reason="unknown ST_BlipCompression lexical value: " + value,
      )
  }
}

///|
pub fn ST_BlipCompression::to_string(self : ST_BlipCompression) -> String {
  match self {
    BlipCstateEmail => "email"
    BlipCstateScreen => "screen"
    BlipCstatePrint => "print"
    BlipCstateHqPrint => "hqprint"
    BlipCstateNone => "none"
  }
}
