///|
/// SpreadsheetML pivot types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn pivot_type_group_name() -> String {
  "spreadsheet_ml.pivot"
}

///|
/// XSD complex type CT_PivotCacheDefinition.
pub(all) struct CT_PivotCacheDefinition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotCacheDefinition::new(
  element : @xml.Element,
) -> CT_PivotCacheDefinition {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CacheFields.
pub(all) struct CT_CacheFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CacheFields::new(element : @xml.Element) -> CT_CacheFields {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CacheField.
pub(all) struct CT_CacheField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CacheField::new(element : @xml.Element) -> CT_CacheField {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CacheSource.
pub(all) struct CT_CacheSource {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CacheSource::new(element : @xml.Element) -> CT_CacheSource {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PCDSCPage.
pub(all) struct CT_PCDSCPage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PCDSCPage::new(element : @xml.Element) -> CT_PCDSCPage {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RangeSets.
pub(all) struct CT_RangeSets {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RangeSets::new(element : @xml.Element) -> CT_RangeSets {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RangeSet.
pub(all) struct CT_RangeSet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RangeSet::new(element : @xml.Element) -> CT_RangeSet {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotCacheRecords.
pub(all) struct CT_PivotCacheRecords {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotCacheRecords::new(
  element : @xml.Element,
) -> CT_PivotCacheRecords {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PCDKPIs.
pub(all) struct CT_PCDKPIs {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PCDKPIs::new(element : @xml.Element) -> CT_PCDKPIs {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PCDKPI: pivot cache KPI with uniqueName, caption, displayFolder, measureGroup, parent, value, goal, status, trend, weight, time attributes.
pub(all) struct CT_PCDKPI {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PCDKPI::new(element : @xml.Element) -> CT_PCDKPI {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CacheHierarchies.
pub(all) struct CT_CacheHierarchies {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CacheHierarchies::new(element : @xml.Element) -> CT_CacheHierarchies {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CacheHierarchy.
pub(all) struct CT_CacheHierarchy {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CacheHierarchy::new(element : @xml.Element) -> CT_CacheHierarchy {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_GroupMembers.
pub(all) struct CT_GroupMembers {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupMembers::new(element : @xml.Element) -> CT_GroupMembers {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_GroupMember.
pub(all) struct CT_GroupMember {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupMember::new(element : @xml.Element) -> CT_GroupMember {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_TupleCache.
pub(all) struct CT_TupleCache {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TupleCache::new(element : @xml.Element) -> CT_TupleCache {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PCDSDTCEntries.
pub(all) struct CT_PCDSDTCEntries {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PCDSDTCEntries::new(element : @xml.Element) -> CT_PCDSDTCEntries {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Tuples.
pub(all) struct CT_Tuples {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Tuples::new(element : @xml.Element) -> CT_Tuples {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Tuple.
pub(all) struct CT_Tuple {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Tuple::new(element : @xml.Element) -> CT_Tuple {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Sets.
pub(all) struct CT_Sets {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Sets::new(element : @xml.Element) -> CT_Sets {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Set: pivot tuple set with tpls and sortByTuple children plus count, maxRank, setDefinition, sortType, queryFailed attributes.
pub(all) struct CT_Set {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Set::new(element : @xml.Element) -> CT_Set {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_QueryCache.
pub(all) struct CT_QueryCache {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_QueryCache::new(element : @xml.Element) -> CT_QueryCache {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Query.
pub(all) struct CT_Query {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Query::new(element : @xml.Element) -> CT_Query {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CalculatedItems.
pub(all) struct CT_CalculatedItems {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CalculatedItems::new(element : @xml.Element) -> CT_CalculatedItems {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CalculatedItem.
pub(all) struct CT_CalculatedItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CalculatedItem::new(element : @xml.Element) -> CT_CalculatedItem {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CalculatedMembers.
pub(all) struct CT_CalculatedMembers {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CalculatedMembers::new(
  element : @xml.Element,
) -> CT_CalculatedMembers {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CalculatedMember.
pub(all) struct CT_CalculatedMember {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CalculatedMember::new(element : @xml.Element) -> CT_CalculatedMember {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_pivotTableDefinition.
pub(all) struct CT_pivotTableDefinition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_pivotTableDefinition::new(
  element : @xml.Element,
) -> CT_pivotTableDefinition {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotFields.
pub(all) struct CT_PivotFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotFields::new(element : @xml.Element) -> CT_PivotFields {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotField.
pub(all) struct CT_PivotField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotField::new(element : @xml.Element) -> CT_PivotField {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotAreas.
pub(all) struct CT_PivotAreas {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotAreas::new(element : @xml.Element) -> CT_PivotAreas {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotHierarchies.
pub(all) struct CT_PivotHierarchies {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotHierarchies::new(element : @xml.Element) -> CT_PivotHierarchies {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotHierarchy.
pub(all) struct CT_PivotHierarchy {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotHierarchy::new(element : @xml.Element) -> CT_PivotHierarchy {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RowHierarchiesUsage.
pub(all) struct CT_RowHierarchiesUsage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RowHierarchiesUsage::new(
  element : @xml.Element,
) -> CT_RowHierarchiesUsage {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ColHierarchiesUsage.
pub(all) struct CT_ColHierarchiesUsage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColHierarchiesUsage::new(
  element : @xml.Element,
) -> CT_ColHierarchiesUsage {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_HierarchyUsage.
pub(all) struct CT_HierarchyUsage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HierarchyUsage::new(element : @xml.Element) -> CT_HierarchyUsage {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MemberProperties.
pub(all) struct CT_MemberProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MemberProperties::new(element : @xml.Element) -> CT_MemberProperties {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MemberProperty.
pub(all) struct CT_MemberProperty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MemberProperty::new(element : @xml.Element) -> CT_MemberProperty {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Members.
pub(all) struct CT_Members {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Members::new(element : @xml.Element) -> CT_Members {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Member.
pub(all) struct CT_Member {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Member::new(element : @xml.Element) -> CT_Member {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotDimension.
pub(all) struct CT_PivotDimension {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotDimension::new(element : @xml.Element) -> CT_PivotDimension {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MeasureGroups.
pub(all) struct CT_MeasureGroups {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MeasureGroups::new(element : @xml.Element) -> CT_MeasureGroups {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MeasureDimensionMaps.
pub(all) struct CT_MeasureDimensionMaps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MeasureDimensionMaps::new(
  element : @xml.Element,
) -> CT_MeasureDimensionMaps {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MeasureGroup.
pub(all) struct CT_MeasureGroup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MeasureGroup::new(element : @xml.Element) -> CT_MeasureGroup {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MeasureDimensionMap.
pub(all) struct CT_MeasureDimensionMap {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MeasureDimensionMap::new(
  element : @xml.Element,
) -> CT_MeasureDimensionMap {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotTableStyle.
pub(all) struct CT_PivotTableStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotTableStyle::new(element : @xml.Element) -> CT_PivotTableStyle {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotFilters.
pub(all) struct CT_PivotFilters {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotFilters::new(element : @xml.Element) -> CT_PivotFilters {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotFilter.
pub(all) struct CT_PivotFilter {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotFilter::new(element : @xml.Element) -> CT_PivotFilter {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotArea.
pub(all) struct CT_PivotArea {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotArea::new(element : @xml.Element) -> CT_PivotArea {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotAreaReferences.
pub(all) struct CT_PivotAreaReferences {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotAreaReferences::new(
  element : @xml.Element,
) -> CT_PivotAreaReferences {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotAreaReference.
pub(all) struct CT_PivotAreaReference {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotAreaReference::new(
  element : @xml.Element,
) -> CT_PivotAreaReference {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_QueryTable.
pub(all) struct CT_QueryTable {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_QueryTable::new(element : @xml.Element) -> CT_QueryTable {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_QueryTableRefresh.
pub(all) struct CT_QueryTableRefresh {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_QueryTableRefresh::new(
  element : @xml.Element,
) -> CT_QueryTableRefresh {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_QueryTableDeletedFields.
pub(all) struct CT_QueryTableDeletedFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_QueryTableDeletedFields::new(
  element : @xml.Element,
) -> CT_QueryTableDeletedFields {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_QueryTableFields.
pub(all) struct CT_QueryTableFields {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_QueryTableFields::new(element : @xml.Element) -> CT_QueryTableFields {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_QueryTableField.
pub(all) struct CT_QueryTableField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_QueryTableField::new(element : @xml.Element) -> CT_QueryTableField {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RevisionQueryTableField.
pub(all) struct CT_RevisionQueryTableField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RevisionQueryTableField::new(
  element : @xml.Element,
) -> CT_RevisionQueryTableField {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotSelection.
pub(all) struct CT_PivotSelection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotSelection::new(element : @xml.Element) -> CT_PivotSelection {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PageSetUpPr.
pub(all) struct CT_PageSetUpPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageSetUpPr::new(element : @xml.Element) -> CT_PageSetUpPr {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PageSetup.
pub(all) struct CT_PageSetup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageSetup::new(element : @xml.Element) -> CT_PageSetup {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_CsPageSetup.
pub(all) struct CT_CsPageSetup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CsPageSetup::new(element : @xml.Element) -> CT_CsPageSetup {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MdxMetadata.
pub(all) struct CT_MdxMetadata {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MdxMetadata::new(element : @xml.Element) -> CT_MdxMetadata {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Mdx.
pub(all) struct CT_Mdx {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Mdx::new(element : @xml.Element) -> CT_Mdx {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MdxTuple.
pub(all) struct CT_MdxTuple {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MdxTuple::new(element : @xml.Element) -> CT_MdxTuple {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MdxSet.
pub(all) struct CT_MdxSet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MdxSet::new(element : @xml.Element) -> CT_MdxSet {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MdxMemeberProp.
pub(all) struct CT_MdxMemeberProp {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MdxMemeberProp::new(element : @xml.Element) -> CT_MdxMemeberProp {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_MdxKPI.
pub(all) struct CT_MdxKPI {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MdxKPI::new(element : @xml.Element) -> CT_MdxKPI {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_ExternalSheetDataSet.
pub(all) struct CT_ExternalSheetDataSet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExternalSheetDataSet::new(
  element : @xml.Element,
) -> CT_ExternalSheetDataSet {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotCaches.
pub(all) struct CT_PivotCaches {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotCaches::new(element : @xml.Element) -> CT_PivotCaches {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PivotCache.
pub(all) struct CT_PivotCache {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PivotCache::new(element : @xml.Element) -> CT_PivotCache {
  let group_name = pivot_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}
