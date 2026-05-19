///|
/// SpreadsheetML pivot types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn pivot_type_group_name() -> String {
  "spreadsheet_ml.pivot"
}

// =============================================================================
// chunk2 typed wrappers — XSD complex types now carry every spec-defined
// attribute and child element. The reader/builder still access `.element`
// for byte-identical round-trip, so the raw element is preserved on each
// record. chunk3..9 wrappers below remain element-only until claimed.
// =============================================================================

///|
/// XSD complex type CT_PivotCacheDefinition — Part 1 §18.10.1.67.
/// Root descriptor of a pivot cache part. Carries an optional `@r:id`
/// pointing at the bound `pivotCacheRecords` part, the refresh-state
/// boolean / version attributes, and a sequence of optional child
/// elements: required `<cacheSource>` (CT_CacheSource) and
/// `<cacheFields>` (CT_CacheFields) followed by optional
/// `<cacheHierarchies>`, `<kpis>`, `<tupleCache>`, `<calculatedItems>`,
/// `<calculatedMembers>`, `<dimensions>`, `<measureGroups>`, `<maps>`
/// and `<extLst>` children.
pub(all) struct CT_PivotCacheDefinition {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (relationship id) — optional.
  r_id : String?
  /// @invalid (xsd:boolean) — optional, default false.
  invalid : Bool
  /// @saveData (xsd:boolean) — optional, default true.
  save_data : Bool
  /// @refreshOnLoad (xsd:boolean) — optional, default false.
  refresh_on_load : Bool
  /// @optimizeMemory (xsd:boolean) — optional, default false.
  optimize_memory : Bool
  /// @enableRefresh (xsd:boolean) — optional, default true.
  enable_refresh : Bool
  /// @refreshedBy (s:ST_Xstring) — optional.
  refreshed_by : String?
  /// @refreshedDateIso (xsd:dateTime) — optional.
  refreshed_date_iso : String?
  /// @backgroundQuery (xsd:boolean) — optional, default false.
  background_query : Bool
  /// @missingItemsLimit (xsd:unsignedInt) — optional.
  missing_items_limit : Int?
  /// @createdVersion (xsd:unsignedByte) — optional, default 0.
  created_version : Int
  /// @refreshedVersion (xsd:unsignedByte) — optional, default 0.
  refreshed_version : Int
  /// @minRefreshableVersion (xsd:unsignedByte) — optional, default 0.
  min_refreshable_version : Int
  /// @recordCount (xsd:unsignedInt) — optional.
  record_count : Int?
  /// @upgradeOnRefresh (xsd:boolean) — optional, default false.
  upgrade_on_refresh : Bool
  /// @tupleCache (xsd:boolean) — optional, default false.
  tuple_cache_attr : Bool
  /// @supportSubquery (xsd:boolean) — optional, default false.
  support_subquery : Bool
  /// @supportAdvancedDrill (xsd:boolean) — optional, default false.
  support_advanced_drill : Bool
  /// <cacheSource> (CT_CacheSource) — required (treated as optional here
  /// to remain lenient; real workbooks always emit it).
  cache_source : CT_CacheSource?
  /// <cacheFields> (CT_CacheFields) — required (treated as optional).
  cache_fields : CT_CacheFields?
  /// <cacheHierarchies> (CT_CacheHierarchies) — optional.
  cache_hierarchies : CT_CacheHierarchies?
  /// <kpis> (CT_PCDKPIs) — optional.
  kpis : CT_PCDKPIs?
  /// <tupleCache> (CT_TupleCache) — optional.
  tuple_cache : CT_TupleCache?
  /// <calculatedItems> (CT_CalculatedItems) — optional.
  calculated_items : CT_CalculatedItems?
  /// <calculatedMembers> (CT_CalculatedMembers) — optional.
  calculated_members : CT_CalculatedMembers?
  /// <dimensions> (CT_Dimensions) — optional.
  dimensions : CT_Dimensions?
  /// <measureGroups> (CT_MeasureGroups) — optional.
  measure_groups : CT_MeasureGroups?
  /// <maps> (CT_MeasureDimensionMaps) — optional.
  maps : CT_MeasureDimensionMaps?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PivotCacheDefinition::new(
  element : @xml.Element,
) -> CT_PivotCacheDefinition {
  let r_id = attr_with_ns(element, "id")
  let invalid = attr_bool(element, "invalid", false)
  let save_data = attr_bool(element, "saveData", true)
  let refresh_on_load = attr_bool(element, "refreshOnLoad", false)
  let optimize_memory = attr_bool(element, "optimizeMemory", false)
  let enable_refresh = attr_bool(element, "enableRefresh", true)
  let refreshed_by = attr(element, "refreshedBy")
  let refreshed_date_iso = attr(element, "refreshedDateIso")
  let background_query = attr_bool(element, "backgroundQuery", false)
  let missing_items_limit = attr_uint_opt(element, "missingItemsLimit")
  let created_version = attr_uint(element, "createdVersion", 0)
  let refreshed_version = attr_uint(element, "refreshedVersion", 0)
  let min_refreshable_version = attr_uint(element, "minRefreshableVersion", 0)
  let record_count = attr_uint_opt(element, "recordCount")
  let upgrade_on_refresh = attr_bool(element, "upgradeOnRefresh", false)
  let tuple_cache_attr = attr_bool(element, "tupleCache", false)
  let support_subquery = attr_bool(element, "supportSubquery", false)
  let support_advanced_drill = attr_bool(element, "supportAdvancedDrill", false)
  let mut cache_source : CT_CacheSource? = None
  let mut cache_fields : CT_CacheFields? = None
  let mut cache_hierarchies : CT_CacheHierarchies? = None
  let mut kpis : CT_PCDKPIs? = None
  let mut tuple_cache : CT_TupleCache? = None
  let mut calculated_items : CT_CalculatedItems? = None
  let mut calculated_members : CT_CalculatedMembers? = None
  let mut dimensions : CT_Dimensions? = None
  let mut measure_groups : CT_MeasureGroups? = None
  let mut maps : CT_MeasureDimensionMaps? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "cacheSource" => cache_source = Some(CT_CacheSource::new(child_element))
        "cacheFields" => cache_fields = Some(CT_CacheFields::new(child_element))
        "cacheHierarchies" =>
          cache_hierarchies = Some(CT_CacheHierarchies::new(child_element))
        "kpis" => kpis = Some(CT_PCDKPIs::new(child_element))
        "tupleCache" => tuple_cache = Some(CT_TupleCache::new(child_element))
        "calculatedItems" =>
          calculated_items = Some(CT_CalculatedItems::new(child_element))
        "calculatedMembers" =>
          calculated_members = Some(CT_CalculatedMembers::new(child_element))
        "dimensions" => dimensions = Some(CT_Dimensions::new(child_element))
        "measureGroups" =>
          measure_groups = Some(CT_MeasureGroups::new(child_element))
        "maps" => maps = Some(CT_MeasureDimensionMaps::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    r_id,
    invalid,
    save_data,
    refresh_on_load,
    optimize_memory,
    enable_refresh,
    refreshed_by,
    refreshed_date_iso,
    background_query,
    missing_items_limit,
    created_version,
    refreshed_version,
    min_refreshable_version,
    record_count,
    upgrade_on_refresh,
    tuple_cache_attr,
    support_subquery,
    support_advanced_drill,
    cache_source,
    cache_fields,
    cache_hierarchies,
    kpis,
    tuple_cache,
    calculated_items,
    calculated_members,
    dimensions,
    measure_groups,
    maps,
    ext_lst,
  }
}

///|
/// XSD complex type CT_CacheFields — Part 1 §18.10.1.4. Pivot cache field
/// list: optional `@count` (xsd:unsignedInt) and zero or more
/// `<cacheField>` (CT_CacheField) children — the cached schema columns.
pub(all) struct CT_CacheFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <cacheField>* (CT_CacheField) — zero or more.
  cache_fields : Array[CT_CacheField]
} derive(Eq, Debug)

///|
pub fn CT_CacheFields::new(element : @xml.Element) -> CT_CacheFields {
  let count = attr_uint_opt(element, "count")
  let cache_fields : Array[CT_CacheField] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "cacheField" {
        cache_fields.push(CT_CacheField::new(child_element))
      }
    }
  }
  { element, count, cache_fields }
}

///|
/// XSD complex type CT_CacheField — Part 1 §18.10.1.3. Single cached
/// column descriptor. Required `@name` (s:ST_Xstring) plus the optional
/// attribute bundle described in the spec (caption, propertyName,
/// serverField, uniqueList=true default, numFmtId, formula, sqlType=0,
/// hierarchy=0, level=0, databaseField=true, mappingCount,
/// memberPropertyField). Optional ordered children: `<sharedItems>`
/// (CT_SharedItems), `<fieldGroup>` (CT_FieldGroup), unbounded `<mpMap>`
/// (CT_X) member-property maps, and `<extLst>` (CT_ExtensionList).
pub(all) struct CT_CacheField {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required.
  name : String
  /// @caption (s:ST_Xstring) — optional.
  caption : String?
  /// @propertyName (s:ST_Xstring) — optional.
  property_name : String?
  /// @serverField (xsd:boolean) — optional, default false.
  server_field : Bool
  /// @uniqueList (xsd:boolean) — optional, default true.
  unique_list : Bool
  /// @numFmtId (ST_NumFmtId) — optional. Preserved as String for lenient
  /// representation pending ST_NumFmtId typing.
  num_fmt_id : String?
  /// @formula (s:ST_Xstring) — optional.
  formula : String?
  /// @sqlType (xsd:int) — optional, default 0.
  sql_type : Int
  /// @hierarchy (xsd:int) — optional, default 0.
  hierarchy : Int
  /// @level (xsd:unsignedInt) — optional, default 0.
  level : Int
  /// @databaseField (xsd:boolean) — optional, default true.
  database_field : Bool
  /// @mappingCount (xsd:unsignedInt) — optional.
  mapping_count : Int?
  /// @memberPropertyField (xsd:boolean) — optional, default false.
  member_property_field : Bool
  /// <sharedItems> (CT_SharedItems) — optional.
  shared_items : CT_SharedItems?
  /// <fieldGroup> (CT_FieldGroup) — optional.
  field_group : CT_FieldGroup?
  /// <mpMap>* (CT_X) — zero or more member-property maps.
  mp_maps : Array[CT_X]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CacheField::new(element : @xml.Element) -> CT_CacheField {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let caption = attr(element, "caption")
  let property_name = attr(element, "propertyName")
  let server_field = attr_bool(element, "serverField", false)
  let unique_list = attr_bool(element, "uniqueList", true)
  let num_fmt_id = attr(element, "numFmtId")
  let formula = attr(element, "formula")
  let sql_type = attr_int(element, "sqlType", 0)
  let hierarchy = attr_int(element, "hierarchy", 0)
  let level = attr_uint(element, "level", 0)
  let database_field = attr_bool(element, "databaseField", true)
  let mapping_count = attr_uint_opt(element, "mappingCount")
  let member_property_field = attr_bool(element, "memberPropertyField", false)
  let mut shared_items : CT_SharedItems? = None
  let mut field_group : CT_FieldGroup? = None
  let mp_maps : Array[CT_X] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sharedItems" => shared_items = Some(CT_SharedItems::new(child_element))
        "fieldGroup" => field_group = Some(CT_FieldGroup::new(child_element))
        "mpMap" => mp_maps.push(CT_X::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    name,
    caption,
    property_name,
    server_field,
    unique_list,
    num_fmt_id,
    formula,
    sql_type,
    hierarchy,
    level,
    database_field,
    mapping_count,
    member_property_field,
    shared_items,
    field_group,
    mp_maps,
    ext_lst,
  }
}

///|
/// XSD complex type CT_CacheSource — Part 1 §18.10.1.7. Origin descriptor
/// for a pivot cache. Required `@type` (ST_SourceType ∈ {worksheet,
/// external, consolidation, scenario}); optional `@connectionId`
/// (xsd:unsignedInt, default 0). Choice of optional children:
/// `<worksheetSource>` (CT_WorksheetSource), `<consolidation>`
/// (CT_Consolidation), or `<extLst>` (CT_ExtensionList).
pub(all) struct CT_CacheSource {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @type (ST_SourceType) — required. Lexical preserved.
  type_ : String
  /// @connectionId (xsd:unsignedInt) — optional, default 0.
  connection_id : Int
  /// <worksheetSource> (CT_WorksheetSource) — optional.
  worksheet_source : CT_WorksheetSource?
  /// <consolidation> (CT_Consolidation) — optional.
  consolidation : CT_Consolidation?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CacheSource::new(element : @xml.Element) -> CT_CacheSource {
  let type_ = match attr(element, "type") {
    Some(v) => v
    None => ""
  }
  let connection_id = attr_uint(element, "connectionId", 0)
  let mut worksheet_source : CT_WorksheetSource? = None
  let mut consolidation : CT_Consolidation? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "worksheetSource" =>
          worksheet_source = Some(CT_WorksheetSource::new(child_element))
        "consolidation" =>
          consolidation = Some(CT_Consolidation::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, type_, connection_id, worksheet_source, consolidation, ext_lst }
}

///|
/// XSD complex type CT_PCDSCPage — Part 1 §18.10.1.64 (page). Pivot cache
/// consolidation page: optional `@count` (xsd:unsignedInt) and zero or
/// more `<pageItem>` (CT_PageItem) children.
pub(all) struct CT_PCDSCPage {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <pageItem>* (CT_PageItem) — zero or more.
  page_items : Array[CT_PageItem]
} derive(Eq, Debug)

///|
pub fn CT_PCDSCPage::new(element : @xml.Element) -> CT_PCDSCPage {
  let count = attr_uint_opt(element, "count")
  let page_items : Array[CT_PageItem] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pageItem" {
        page_items.push(CT_PageItem::new(child_element))
      }
    }
  }
  { element, count, page_items }
}

///|
/// XSD complex type CT_RangeSets — Part 1 §18.10.1.80. Container for
/// consolidation range sets: optional `@count` (xsd:unsignedInt) and one
/// or more `<rangeSet>` (CT_RangeSet) children.
pub(all) struct CT_RangeSets {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <rangeSet>+ (CT_RangeSet) — one or more.
  range_sets : Array[CT_RangeSet]
} derive(Eq, Debug)

///|
pub fn CT_RangeSets::new(element : @xml.Element) -> CT_RangeSets {
  let count = attr_uint_opt(element, "count")
  let range_sets : Array[CT_RangeSet] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "rangeSet" {
        range_sets.push(CT_RangeSet::new(child_element))
      }
    }
  }
  { element, count, range_sets }
}

///|
/// XSD complex type CT_RangeSet — Part 1 §18.10.1.79. Consolidation
/// range-set entry: optional `@i1`..`@i4` (xsd:unsignedInt) page-item
/// indices, optional `@ref` (ST_Ref) cell range, optional `@name` and
/// `@sheet` (s:ST_Xstring), and optional `@r:id` relationship id. No
/// child elements.
pub(all) struct CT_RangeSet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @i1 (xsd:unsignedInt) — optional.
  i1 : Int?
  /// @i2 (xsd:unsignedInt) — optional.
  i2 : Int?
  /// @i3 (xsd:unsignedInt) — optional.
  i3 : Int?
  /// @i4 (xsd:unsignedInt) — optional.
  i4 : Int?
  /// @ref (ST_Ref) — optional cell range.
  ref_ : String?
  /// @name (s:ST_Xstring) — optional.
  name : String?
  /// @sheet (s:ST_Xstring) — optional.
  sheet : String?
  /// @r:id (relationship id) — optional.
  r_id : String?
} derive(Eq, Debug)

///|
pub fn CT_RangeSet::new(element : @xml.Element) -> CT_RangeSet {
  let i1 = attr_uint_opt(element, "i1")
  let i2 = attr_uint_opt(element, "i2")
  let i3 = attr_uint_opt(element, "i3")
  let i4 = attr_uint_opt(element, "i4")
  let ref_ = attr(element, "ref")
  let name = attr(element, "name")
  let sheet = attr(element, "sheet")
  let r_id = attr_with_ns(element, "id")
  { element, i1, i2, i3, i4, ref_, name, sheet, r_id }
}

///|
/// XSD complex type CT_PivotCacheRecords — Part 1 §18.10.1.68. Pivot
/// cache record stream: optional `@count` (xsd:unsignedInt) and zero or
/// more `<r>` (CT_Record) children plus an optional `<extLst>`
/// (CT_ExtensionList).
pub(all) struct CT_PivotCacheRecords {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <r>* (CT_Record) — zero or more cached records.
  records : Array[CT_Record]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PivotCacheRecords::new(
  element : @xml.Element,
) -> CT_PivotCacheRecords {
  let count = attr_uint_opt(element, "count")
  let records : Array[CT_Record] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "r" => records.push(CT_Record::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, count, records, ext_lst }
}

///|
/// XSD complex type CT_PCDKPIs — Part 1 §18.10.1.48 (kpis). KPI list
/// container: optional `@count` (xsd:unsignedInt) and zero or more
/// `<kpi>` (CT_PCDKPI) children.
pub(all) struct CT_PCDKPIs {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <kpi>* (CT_PCDKPI) — zero or more KPIs.
  kpis : Array[CT_PCDKPI]
} derive(Eq, Debug)

///|
pub fn CT_PCDKPIs::new(element : @xml.Element) -> CT_PCDKPIs {
  let count = attr_uint_opt(element, "count")
  let kpis : Array[CT_PCDKPI] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "kpi" {
        kpis.push(CT_PCDKPI::new(child_element))
      }
    }
  }
  { element, count, kpis }
}

///|
/// XSD complex type CT_PCDKPI — Part 1 §18.10.1.47 (kpi). OLAP KPI entry:
/// required `@uniqueName` and `@value` (s:ST_Xstring); optional
/// `@caption`, `@displayFolder`, `@measureGroup`, `@parent`, `@goal`,
/// `@status`, `@trend`, `@weight`, `@time` (all s:ST_Xstring). No child
/// elements.
pub(all) struct CT_PCDKPI {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @uniqueName (s:ST_Xstring) — required.
  unique_name : String
  /// @caption (s:ST_Xstring) — optional.
  caption : String?
  /// @displayFolder (s:ST_Xstring) — optional.
  display_folder : String?
  /// @measureGroup (s:ST_Xstring) — optional.
  measure_group : String?
  /// @parent (s:ST_Xstring) — optional.
  parent : String?
  /// @value (s:ST_Xstring) — required.
  value : String
  /// @goal (s:ST_Xstring) — optional.
  goal : String?
  /// @status (s:ST_Xstring) — optional.
  status : String?
  /// @trend (s:ST_Xstring) — optional.
  trend : String?
  /// @weight (s:ST_Xstring) — optional.
  weight : String?
  /// @time (s:ST_Xstring) — optional.
  time : String?
} derive(Eq, Debug)

///|
pub fn CT_PCDKPI::new(element : @xml.Element) -> CT_PCDKPI {
  let unique_name = match attr(element, "uniqueName") {
    Some(v) => v
    None => ""
  }
  let caption = attr(element, "caption")
  let display_folder = attr(element, "displayFolder")
  let measure_group = attr(element, "measureGroup")
  let parent = attr(element, "parent")
  let value = match attr(element, "value") {
    Some(v) => v
    None => ""
  }
  let goal = attr(element, "goal")
  let status = attr(element, "status")
  let trend = attr(element, "trend")
  let weight = attr(element, "weight")
  let time = attr(element, "time")
  {
    element,
    unique_name,
    caption,
    display_folder,
    measure_group,
    parent,
    value,
    goal,
    status,
    trend,
    weight,
    time,
  }
}

///|
/// XSD complex type CT_CacheHierarchies — Part 1 §18.10.1.5. OLAP cache
/// hierarchy list: optional `@count` (xsd:unsignedInt) and zero or more
/// `<cacheHierarchy>` (CT_CacheHierarchy) children.
pub(all) struct CT_CacheHierarchies {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <cacheHierarchy>* (CT_CacheHierarchy) — zero or more.
  cache_hierarchies : Array[CT_CacheHierarchy]
} derive(Eq, Debug)

///|
pub fn CT_CacheHierarchies::new(element : @xml.Element) -> CT_CacheHierarchies {
  let count = attr_uint_opt(element, "count")
  let cache_hierarchies : Array[CT_CacheHierarchy] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "cacheHierarchy" {
        cache_hierarchies.push(CT_CacheHierarchy::new(child_element))
      }
    }
  }
  { element, count, cache_hierarchies }
}

///|
/// XSD complex type CT_CacheHierarchy — Part 1 §18.10.1.6. Single OLAP
/// cache hierarchy. Required `@uniqueName` (s:ST_Xstring) and `@count`
/// (xsd:unsignedInt); optional caption, descriptor flags (measure, set,
/// attribute, time, keyAttribute, measures, hidden, oneField, unbalanced,
/// unbalancedGroup), `@parentSet` (xsd:unsignedInt), `@iconSet`
/// (xsd:int, default 0), `@defaultMemberUniqueName`, `@allUniqueName`,
/// `@allCaption`, `@dimensionUniqueName`, `@displayFolder`,
/// `@measureGroup` (all s:ST_Xstring), and `@memberValueDatatype`
/// (xsd:unsignedShort). Optional ordered children: `<fieldsUsage>`
/// (CT_FieldsUsage), `<groupLevels>` (CT_GroupLevels), `<extLst>`
/// (CT_ExtensionList).
pub(all) struct CT_CacheHierarchy {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @uniqueName (s:ST_Xstring) — required.
  unique_name : String
  /// @caption (s:ST_Xstring) — optional.
  caption : String?
  /// @measure (xsd:boolean) — optional, default false.
  measure : Bool
  /// @set (xsd:boolean) — optional, default false.
  set_ : Bool
  /// @parentSet (xsd:unsignedInt) — optional.
  parent_set : Int?
  /// @iconSet (xsd:int) — optional, default 0.
  icon_set : Int
  /// @attribute (xsd:boolean) — optional, default false.
  attribute : Bool
  /// @time (xsd:boolean) — optional, default false.
  time : Bool
  /// @keyAttribute (xsd:boolean) — optional, default false.
  key_attribute : Bool
  /// @defaultMemberUniqueName (s:ST_Xstring) — optional.
  default_member_unique_name : String?
  /// @allUniqueName (s:ST_Xstring) — optional.
  all_unique_name : String?
  /// @allCaption (s:ST_Xstring) — optional.
  all_caption : String?
  /// @dimensionUniqueName (s:ST_Xstring) — optional.
  dimension_unique_name : String?
  /// @displayFolder (s:ST_Xstring) — optional.
  display_folder : String?
  /// @measureGroup (s:ST_Xstring) — optional.
  measure_group : String?
  /// @measures (xsd:boolean) — optional, default false.
  measures : Bool
  /// @count (xsd:unsignedInt) — required.
  count : Int
  /// @oneField (xsd:boolean) — optional, default false.
  one_field : Bool
  /// @memberValueDatatype (xsd:unsignedShort) — optional.
  member_value_datatype : Int?
  /// @unbalanced (xsd:boolean) — optional.
  unbalanced : Bool?
  /// @unbalancedGroup (xsd:boolean) — optional.
  unbalanced_group : Bool?
  /// @hidden (xsd:boolean) — optional, default false.
  hidden : Bool
  /// <fieldsUsage> (CT_FieldsUsage) — optional.
  fields_usage : CT_FieldsUsage?
  /// <groupLevels> (CT_GroupLevels) — optional.
  group_levels : CT_GroupLevels?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CacheHierarchy::new(element : @xml.Element) -> CT_CacheHierarchy {
  let unique_name = match attr(element, "uniqueName") {
    Some(v) => v
    None => ""
  }
  let caption = attr(element, "caption")
  let measure = attr_bool(element, "measure", false)
  let set_ = attr_bool(element, "set", false)
  let parent_set = attr_uint_opt(element, "parentSet")
  let icon_set = attr_int(element, "iconSet", 0)
  let attribute = attr_bool(element, "attribute", false)
  let time = attr_bool(element, "time", false)
  let key_attribute = attr_bool(element, "keyAttribute", false)
  let default_member_unique_name = attr(element, "defaultMemberUniqueName")
  let all_unique_name = attr(element, "allUniqueName")
  let all_caption = attr(element, "allCaption")
  let dimension_unique_name = attr(element, "dimensionUniqueName")
  let display_folder = attr(element, "displayFolder")
  let measure_group = attr(element, "measureGroup")
  let measures = attr_bool(element, "measures", false)
  let count = attr_uint(element, "count", 0)
  let one_field = attr_bool(element, "oneField", false)
  let member_value_datatype = attr_uint_opt(element, "memberValueDatatype")
  let unbalanced = attr_bool_opt(element, "unbalanced")
  let unbalanced_group = attr_bool_opt(element, "unbalancedGroup")
  let hidden = attr_bool(element, "hidden", false)
  let mut fields_usage : CT_FieldsUsage? = None
  let mut group_levels : CT_GroupLevels? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "fieldsUsage" => fields_usage = Some(CT_FieldsUsage::new(child_element))
        "groupLevels" => group_levels = Some(CT_GroupLevels::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    unique_name,
    caption,
    measure,
    set_,
    parent_set,
    icon_set,
    attribute,
    time,
    key_attribute,
    default_member_unique_name,
    all_unique_name,
    all_caption,
    dimension_unique_name,
    display_folder,
    measure_group,
    measures,
    count,
    one_field,
    member_value_datatype,
    unbalanced,
    unbalanced_group,
    hidden,
    fields_usage,
    group_levels,
    ext_lst,
  }
}

///|
/// XSD complex type CT_GroupMembers — Part 1 §18.10.1.42. OLAP group
/// member list: optional `@count` (xsd:unsignedInt) and one or more
/// `<groupMember>` (CT_GroupMember) children.
pub(all) struct CT_GroupMembers {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <groupMember>+ (CT_GroupMember) — one or more.
  group_members : Array[CT_GroupMember]
} derive(Eq, Debug)

///|
pub fn CT_GroupMembers::new(element : @xml.Element) -> CT_GroupMembers {
  let count = attr_uint_opt(element, "count")
  let group_members : Array[CT_GroupMember] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "groupMember" {
        group_members.push(CT_GroupMember::new(child_element))
      }
    }
  }
  { element, count, group_members }
}

///|
/// XSD complex type CT_GroupMember — Part 1 §18.10.1.41. OLAP group
/// member entry: required `@uniqueName` (s:ST_Xstring) and optional
/// `@group` (xsd:boolean, default false). No child elements.
pub(all) struct CT_GroupMember {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @uniqueName (s:ST_Xstring) — required.
  unique_name : String
  /// @group (xsd:boolean) — optional, default false.
  group : Bool
} derive(Eq, Debug)

///|
pub fn CT_GroupMember::new(element : @xml.Element) -> CT_GroupMember {
  let unique_name = match attr(element, "uniqueName") {
    Some(v) => v
    None => ""
  }
  let group = attr_bool(element, "group", false)
  { element, unique_name, group }
}

///|
/// XSD complex type CT_TupleCache — Part 1 §18.10.1.94. OLAP tuple cache
/// container. No attributes. Optional ordered children: `<entries>`
/// (CT_PCDSDTCEntries), `<sets>` (CT_Sets), `<queryCache>`
/// (CT_QueryCache), `<serverFormats>` (CT_ServerFormats), `<extLst>`
/// (CT_ExtensionList).
pub(all) struct CT_TupleCache {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <entries> (CT_PCDSDTCEntries) — optional.
  entries : CT_PCDSDTCEntries?
  /// <sets> (CT_Sets) — optional.
  sets : CT_Sets?
  /// <queryCache> (CT_QueryCache) — optional.
  query_cache : CT_QueryCache?
  /// <serverFormats> (CT_ServerFormats) — optional.
  server_formats : CT_ServerFormats?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_TupleCache::new(element : @xml.Element) -> CT_TupleCache {
  let mut entries : CT_PCDSDTCEntries? = None
  let mut sets : CT_Sets? = None
  let mut query_cache : CT_QueryCache? = None
  let mut server_formats : CT_ServerFormats? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "entries" => entries = Some(CT_PCDSDTCEntries::new(child_element))
        "sets" => sets = Some(CT_Sets::new(child_element))
        "queryCache" => query_cache = Some(CT_QueryCache::new(child_element))
        "serverFormats" =>
          server_formats = Some(CT_ServerFormats::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, entries, sets, query_cache, server_formats, ext_lst }
}

///|
/// XSD complex type CT_PCDSDTCEntries — Part 1 §18.10.1.18 (entries).
/// Pivot cache shared-tuple entries: optional `@count` (xsd:unsignedInt)
/// followed by an unbounded choice of `<m>` (CT_Missing), `<n>`
/// (CT_Number), `<e>` (CT_Error), `<s>` (CT_String) children. Children
/// are decoded into separate per-kind arrays to preserve the spec's
/// choice variants without lossy collapsing.
pub(all) struct CT_PCDSDTCEntries {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <m>* (CT_Missing) — zero or more missing entries.
  missings : Array[CT_Missing]
  /// <n>* (CT_Number) — zero or more number entries.
  numbers : Array[CT_Number]
  /// <e>* (CT_Error) — zero or more error entries.
  errors : Array[CT_Error]
  /// <s>* (CT_String) — zero or more string entries.
  strings : Array[CT_String]
} derive(Eq, Debug)

///|
pub fn CT_PCDSDTCEntries::new(element : @xml.Element) -> CT_PCDSDTCEntries {
  let count = attr_uint_opt(element, "count")
  let missings : Array[CT_Missing] = []
  let numbers : Array[CT_Number] = []
  let errors : Array[CT_Error] = []
  let strings : Array[CT_String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "m" => missings.push(CT_Missing::new(child_element))
        "n" => numbers.push(CT_Number::new(child_element))
        "e" => errors.push(CT_Error::new(child_element))
        "s" => strings.push(CT_String::new(child_element))
        _ => ()
      }
    }
  }
  { element, count, missings, numbers, errors, strings }
}

///|
/// XSD complex type CT_Tuples — Part 1 §18.10.1.93 (tpls). Sequence of
/// pivot tuples: optional `@c` (xsd:unsignedInt) count, one or more
/// `<tpl>` (CT_Tuple) children.
pub(all) struct CT_Tuples {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @c (xsd:unsignedInt) — optional count.
  c : Int?
  /// <tpl>+ (CT_Tuple) — one or more tuples.
  tpls : Array[CT_Tuple]
} derive(Eq, Debug)

///|
pub fn CT_Tuples::new(element : @xml.Element) -> CT_Tuples {
  let c = attr_uint_opt(element, "c")
  let tpls : Array[CT_Tuple] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "tpl" {
        tpls.push(CT_Tuple::new(child_element))
      }
    }
  }
  { element, c, tpls }
}

///|
/// XSD complex type CT_Tuple — Part 1 §18.10.1.92 (tpl). Pivot tuple
/// entry: required `@item` (xsd:unsignedInt) item index; optional `@fld`
/// (xsd:unsignedInt) field index and `@hier` (xsd:unsignedInt) hierarchy
/// index. No child elements.
pub(all) struct CT_Tuple {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @fld (xsd:unsignedInt) — optional field index.
  fld : Int?
  /// @hier (xsd:unsignedInt) — optional hierarchy index.
  hier : Int?
  /// @item (xsd:unsignedInt) — required item index.
  item : Int
} derive(Eq, Debug)

///|
pub fn CT_Tuple::new(element : @xml.Element) -> CT_Tuple {
  let fld = attr_uint_opt(element, "fld")
  let hier = attr_uint_opt(element, "hier")
  let item = attr_uint(element, "item", 0)
  { element, fld, hier, item }
}

///|
/// XSD complex type CT_Sets — Part 1 §18.10.1.88 (sets parent). OLAP set
/// list: optional `@count` (xsd:unsignedInt) and one or more `<set>`
/// (CT_Set) children.
pub(all) struct CT_Sets {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <set>+ (CT_Set) — one or more sets.
  sets : Array[CT_Set]
} derive(Eq, Debug)

///|
pub fn CT_Sets::new(element : @xml.Element) -> CT_Sets {
  let count = attr_uint_opt(element, "count")
  let sets : Array[CT_Set] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "set" {
        sets.push(CT_Set::new(child_element))
      }
    }
  }
  { element, count, sets }
}

///|
/// XSD complex type CT_Set — Part 1 §18.10.1.88. OLAP tuple set: required
/// `@maxRank` (xsd:int) and `@setDefinition` (s:ST_Xstring); optional
/// `@count` (xsd:unsignedInt), `@sortType` (ST_SortType, default "none"),
/// `@queryFailed` (xsd:boolean, default false). Optional children: zero
/// or more `<tpls>` (CT_Tuples) tuple-list bundles and a single
/// `<sortByTuple>` (CT_Tuples) sort key.
pub(all) struct CT_Set {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// @maxRank (xsd:int) — required.
  max_rank : Int
  /// @setDefinition (s:ST_Xstring) — required.
  set_definition : String
  /// @sortType (ST_SortType) — optional, default "none".
  sort_type : String?
  /// @queryFailed (xsd:boolean) — optional, default false.
  query_failed : Bool
  /// <tpls>* (CT_Tuples) — zero or more tuple bundles.
  tpls : Array[CT_Tuples]
  /// <sortByTuple> (CT_Tuples) — optional.
  sort_by_tuple : CT_Tuples?
} derive(Eq, Debug)

///|
pub fn CT_Set::new(element : @xml.Element) -> CT_Set {
  let count = attr_uint_opt(element, "count")
  let max_rank = attr_int(element, "maxRank", 0)
  let set_definition = match attr(element, "setDefinition") {
    Some(v) => v
    None => ""
  }
  let sort_type = attr(element, "sortType")
  let query_failed = attr_bool(element, "queryFailed", false)
  let tpls : Array[CT_Tuples] = []
  let mut sort_by_tuple : CT_Tuples? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "tpls" => tpls.push(CT_Tuples::new(child_element))
        "sortByTuple" => sort_by_tuple = Some(CT_Tuples::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    count,
    max_rank,
    set_definition,
    sort_type,
    query_failed,
    tpls,
    sort_by_tuple,
  }
}

///|
/// XSD complex type CT_QueryCache — Part 1 §18.10.1.76 (queryCache). OLAP
/// query cache: optional `@count` (xsd:unsignedInt) and one or more
/// `<query>` (CT_Query) children.
pub(all) struct CT_QueryCache {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <query>+ (CT_Query) — one or more queries.
  queries : Array[CT_Query]
} derive(Eq, Debug)

///|
pub fn CT_QueryCache::new(element : @xml.Element) -> CT_QueryCache {
  let count = attr_uint_opt(element, "count")
  let queries : Array[CT_Query] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "query" {
        queries.push(CT_Query::new(child_element))
      }
    }
  }
  { element, count, queries }
}

///|
/// XSD complex type CT_Query — Part 1 §18.10.1.75 (query). OLAP query
/// entry: required `@mdx` (s:ST_Xstring) MDX text; optional `<tpls>`
/// (CT_Tuples) child supplying the tuple bindings.
pub(all) struct CT_Query {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @mdx (s:ST_Xstring) — required MDX text.
  mdx : String
  /// <tpls> (CT_Tuples) — optional.
  tpls : CT_Tuples?
} derive(Eq, Debug)

///|
pub fn CT_Query::new(element : @xml.Element) -> CT_Query {
  let mdx = match attr(element, "mdx") {
    Some(v) => v
    None => ""
  }
  let mut tpls : CT_Tuples? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "tpls" {
        tpls = Some(CT_Tuples::new(child_element))
      }
    }
  }
  { element, mdx, tpls }
}

///|
/// XSD complex type CT_CalculatedItems — Part 1 §18.10.1.9. Calculated
/// item list: optional `@count` (xsd:unsignedInt) and one or more
/// `<calculatedItem>` (CT_CalculatedItem) children.
pub(all) struct CT_CalculatedItems {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <calculatedItem>+ (CT_CalculatedItem) — one or more.
  calculated_items : Array[CT_CalculatedItem]
} derive(Eq, Debug)

///|
pub fn CT_CalculatedItems::new(element : @xml.Element) -> CT_CalculatedItems {
  let count = attr_uint_opt(element, "count")
  let calculated_items : Array[CT_CalculatedItem] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "calculatedItem" {
        calculated_items.push(CT_CalculatedItem::new(child_element))
      }
    }
  }
  { element, count, calculated_items }
}

///|
/// XSD complex type CT_CalculatedItem — Part 1 §18.10.1.8. Single
/// calculated item entry: optional `@field` (xsd:unsignedInt) and
/// `@formula` (s:ST_Xstring). Required `<pivotArea>` (CT_PivotArea)
/// child and optional `<extLst>` (CT_ExtensionList).
pub(all) struct CT_CalculatedItem {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @field (xsd:unsignedInt) — optional.
  field : Int?
  /// @formula (s:ST_Xstring) — optional.
  formula : String?
  /// <pivotArea> (CT_PivotArea) — required.
  pivot_area : CT_PivotArea?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CalculatedItem::new(element : @xml.Element) -> CT_CalculatedItem {
  let field = attr_uint_opt(element, "field")
  let formula = attr(element, "formula")
  let mut pivot_area : CT_PivotArea? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "pivotArea" => pivot_area = Some(CT_PivotArea::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, field, formula, pivot_area, ext_lst }
}

///|
/// XSD complex type CT_CalculatedMembers — Part 1 §18.10.1.11. Calculated
/// member list: optional `@count` (xsd:unsignedInt) and one or more
/// `<calculatedMember>` (CT_CalculatedMember) children.
pub(all) struct CT_CalculatedMembers {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <calculatedMember>+ (CT_CalculatedMember) — one or more.
  calculated_members : Array[CT_CalculatedMember]
} derive(Eq, Debug)

///|
pub fn CT_CalculatedMembers::new(
  element : @xml.Element,
) -> CT_CalculatedMembers {
  let count = attr_uint_opt(element, "count")
  let calculated_members : Array[CT_CalculatedMember] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "calculatedMember" {
        calculated_members.push(CT_CalculatedMember::new(child_element))
      }
    }
  }
  { element, count, calculated_members }
}

///|
/// XSD complex type CT_CalculatedMember — Part 1 §18.10.1.10. Single
/// calculated member descriptor: required `@name` and `@mdx`
/// (s:ST_Xstring); optional `@memberName`, `@hierarchy`, `@parent`
/// (s:ST_Xstring), `@solveOrder` (xsd:int, default 0), `@set`
/// (xsd:boolean, default false). Optional `<extLst>` (CT_ExtensionList)
/// child.
pub(all) struct CT_CalculatedMember {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required.
  name : String
  /// @mdx (s:ST_Xstring) — required.
  mdx : String
  /// @memberName (s:ST_Xstring) — optional.
  member_name : String?
  /// @hierarchy (s:ST_Xstring) — optional.
  hierarchy : String?
  /// @parent (s:ST_Xstring) — optional.
  parent : String?
  /// @solveOrder (xsd:int) — optional, default 0.
  solve_order : Int
  /// @set (xsd:boolean) — optional, default false.
  set_ : Bool
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CalculatedMember::new(element : @xml.Element) -> CT_CalculatedMember {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let mdx = match attr(element, "mdx") {
    Some(v) => v
    None => ""
  }
  let member_name = attr(element, "memberName")
  let hierarchy = attr(element, "hierarchy")
  let parent = attr(element, "parent")
  let solve_order = attr_int(element, "solveOrder", 0)
  let set_ = attr_bool(element, "set", false)
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  {
    element,
    name,
    mdx,
    member_name,
    hierarchy,
    parent,
    solve_order,
    set_,
    ext_lst,
  }
}

///|
/// XSD complex type CT_pivotTableDefinition — Part 1 §18.10.1.73. Root of
/// a pivotTable part. Required `@name`, `@dataCaption` (s:ST_Xstring),
/// `@cacheId` (xsd:unsignedInt). Carries the full spec attribute bundle
/// describing layout, totals, drill, and version state. Ordered optional
/// child elements include `<location>` (CT_Location, required by the
/// XSD), `<pivotFields>`, `<rowFields>`, `<rowItems>`, `<colFields>`,
/// `<colItems>`, `<pageFields>`, `<dataFields>`, `<formats>`,
/// `<conditionalFormats>`, `<chartFormats>`, `<pivotHierarchies>`,
/// `<pivotTableStyleInfo>`, `<filters>`, `<rowHierarchiesUsage>`,
/// `<colHierarchiesUsage>`, `<extLst>`.
pub(all) struct CT_pivotTableDefinition {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required.
  name : String
  /// @cacheId (xsd:unsignedInt) — required.
  cache_id : Int
  /// @dataOnRows (xsd:boolean) — optional, default false.
  data_on_rows : Bool
  /// @dataPosition (xsd:unsignedInt) — optional.
  data_position : Int?
  /// @dataCaption (s:ST_Xstring) — required.
  data_caption : String
  /// @grandTotalCaption (s:ST_Xstring) — optional.
  grand_total_caption : String?
  /// @errorCaption (s:ST_Xstring) — optional.
  error_caption : String?
  /// @showError (xsd:boolean) — optional, default false.
  show_error : Bool
  /// @missingCaption (s:ST_Xstring) — optional.
  missing_caption : String?
  /// @showMissing (xsd:boolean) — optional, default true.
  show_missing : Bool
  /// @pageStyle (s:ST_Xstring) — optional.
  page_style : String?
  /// @pivotTableStyle (s:ST_Xstring) — optional.
  pivot_table_style : String?
  /// @vacatedStyle (s:ST_Xstring) — optional.
  vacated_style : String?
  /// @tag (s:ST_Xstring) — optional.
  tag : String?
  /// @updatedVersion (xsd:unsignedByte) — optional, default 0.
  updated_version : Int
  /// @minRefreshableVersion (xsd:unsignedByte) — optional, default 0.
  min_refreshable_version : Int
  /// @asteriskTotals (xsd:boolean) — optional, default false.
  asterisk_totals : Bool
  /// @showItems (xsd:boolean) — optional, default true.
  show_items : Bool
  /// @editData (xsd:boolean) — optional, default false.
  edit_data : Bool
  /// @disableFieldList (xsd:boolean) — optional, default false.
  disable_field_list : Bool
  /// @showCalcMbrs (xsd:boolean) — optional, default true.
  show_calc_mbrs : Bool
  /// @visualTotals (xsd:boolean) — optional, default true.
  visual_totals : Bool
  /// @showMultipleLabel (xsd:boolean) — optional, default true.
  show_multiple_label : Bool
  /// @showDataDropDown (xsd:boolean) — optional, default true.
  show_data_drop_down : Bool
  /// @showDrill (xsd:boolean) — optional, default true.
  show_drill : Bool
  /// @printDrill (xsd:boolean) — optional, default false.
  print_drill : Bool
  /// @showMemberPropertyTips (xsd:boolean) — optional, default true.
  show_member_property_tips : Bool
  /// @showDataTips (xsd:boolean) — optional, default true.
  show_data_tips : Bool
  /// @enableWizard (xsd:boolean) — optional, default true.
  enable_wizard : Bool
  /// @enableDrill (xsd:boolean) — optional, default true.
  enable_drill : Bool
  /// @enableFieldProperties (xsd:boolean) — optional, default true.
  enable_field_properties : Bool
  /// @preserveFormatting (xsd:boolean) — optional, default true.
  preserve_formatting : Bool
  /// @useAutoFormatting (xsd:boolean) — optional, default false.
  use_auto_formatting : Bool
  /// @pageWrap (xsd:unsignedInt) — optional, default 0.
  page_wrap : Int
  /// @pageOverThenDown (xsd:boolean) — optional, default false.
  page_over_then_down : Bool
  /// @subtotalHiddenItems (xsd:boolean) — optional, default false.
  subtotal_hidden_items : Bool
  /// @rowGrandTotals (xsd:boolean) — optional, default true.
  row_grand_totals : Bool
  /// @colGrandTotals (xsd:boolean) — optional, default true.
  col_grand_totals : Bool
  /// @fieldPrintTitles (xsd:boolean) — optional, default false.
  field_print_titles : Bool
  /// @itemPrintTitles (xsd:boolean) — optional, default false.
  item_print_titles : Bool
  /// @mergeItem (xsd:boolean) — optional, default false.
  merge_item : Bool
  /// @showDropZones (xsd:boolean) — optional, default true.
  show_drop_zones : Bool
  /// @createdVersion (xsd:unsignedByte) — optional, default 0.
  created_version : Int
  /// @indent (xsd:unsignedInt) — optional, default 1.
  indent : Int
  /// @showEmptyRow (xsd:boolean) — optional, default false.
  show_empty_row : Bool
  /// @showEmptyCol (xsd:boolean) — optional, default false.
  show_empty_col : Bool
  /// @showHeaders (xsd:boolean) — optional, default true.
  show_headers : Bool
  /// @compact (xsd:boolean) — optional, default true.
  compact : Bool
  /// @outline (xsd:boolean) — optional, default false.
  outline : Bool
  /// @outlineData (xsd:boolean) — optional, default false.
  outline_data : Bool
  /// @compactData (xsd:boolean) — optional, default true.
  compact_data : Bool
  /// @published (xsd:boolean) — optional, default false.
  published : Bool
  /// @gridDropZones (xsd:boolean) — optional, default false.
  grid_drop_zones : Bool
  /// @immersive (xsd:boolean) — optional, default true.
  immersive : Bool
  /// @multipleFieldFilters (xsd:boolean) — optional, default true.
  multiple_field_filters : Bool
  /// @chartFormat (xsd:unsignedInt) — optional, default 0.
  chart_format : Int
  /// @rowHeaderCaption (s:ST_Xstring) — optional.
  row_header_caption : String?
  /// @colHeaderCaption (s:ST_Xstring) — optional.
  col_header_caption : String?
  /// @fieldListSortAscending (xsd:boolean) — optional, default false.
  field_list_sort_ascending : Bool
  /// @mdxSubqueries (xsd:boolean) — optional, default false.
  mdx_subqueries : Bool
  /// @customListSort (xsd:boolean) — optional, default true.
  custom_list_sort : Bool
  /// <location> (CT_Location) — required (treated optional here).
  location : CT_Location?
  /// <pivotFields> (CT_PivotFields) — optional.
  pivot_fields : CT_PivotFields?
  /// <rowFields> (CT_RowFields) — optional.
  row_fields : CT_RowFields?
  /// <rowItems> (CT_rowItems) — optional.
  row_items : CT_rowItems?
  /// <colFields> (CT_ColFields) — optional.
  col_fields : CT_ColFields?
  /// <colItems> (CT_colItems) — optional.
  col_items : CT_colItems?
  /// <pageFields> (CT_PageFields) — optional.
  page_fields : CT_PageFields?
  /// <dataFields> (CT_DataFields) — optional.
  data_fields : CT_DataFields?
  /// <formats> (CT_Formats) — optional.
  formats : CT_Formats?
  /// <conditionalFormats> (CT_ConditionalFormats) — optional.
  conditional_formats : CT_ConditionalFormats?
  /// <chartFormats> (CT_ChartFormats) — optional.
  chart_formats : CT_ChartFormats?
  /// <pivotHierarchies> (CT_PivotHierarchies) — optional.
  pivot_hierarchies : CT_PivotHierarchies?
  /// <pivotTableStyleInfo> (CT_PivotTableStyle) — optional.
  pivot_table_style_info : CT_PivotTableStyle?
  /// <filters> (CT_PivotFilters) — optional.
  filters : CT_PivotFilters?
  /// <rowHierarchiesUsage> (CT_RowHierarchiesUsage) — optional.
  row_hierarchies_usage : CT_RowHierarchiesUsage?
  /// <colHierarchiesUsage> (CT_ColHierarchiesUsage) — optional.
  col_hierarchies_usage : CT_ColHierarchiesUsage?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_pivotTableDefinition::new(
  element : @xml.Element,
) -> CT_pivotTableDefinition {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let cache_id = attr_uint(element, "cacheId", 0)
  let data_on_rows = attr_bool(element, "dataOnRows", false)
  let data_position = attr_uint_opt(element, "dataPosition")
  let data_caption = match attr(element, "dataCaption") {
    Some(v) => v
    None => ""
  }
  let grand_total_caption = attr(element, "grandTotalCaption")
  let error_caption = attr(element, "errorCaption")
  let show_error = attr_bool(element, "showError", false)
  let missing_caption = attr(element, "missingCaption")
  let show_missing = attr_bool(element, "showMissing", true)
  let page_style = attr(element, "pageStyle")
  let pivot_table_style = attr(element, "pivotTableStyle")
  let vacated_style = attr(element, "vacatedStyle")
  let tag = attr(element, "tag")
  let updated_version = attr_uint(element, "updatedVersion", 0)
  let min_refreshable_version = attr_uint(element, "minRefreshableVersion", 0)
  let asterisk_totals = attr_bool(element, "asteriskTotals", false)
  let show_items = attr_bool(element, "showItems", true)
  let edit_data = attr_bool(element, "editData", false)
  let disable_field_list = attr_bool(element, "disableFieldList", false)
  let show_calc_mbrs = attr_bool(element, "showCalcMbrs", true)
  let visual_totals = attr_bool(element, "visualTotals", true)
  let show_multiple_label = attr_bool(element, "showMultipleLabel", true)
  let show_data_drop_down = attr_bool(element, "showDataDropDown", true)
  let show_drill = attr_bool(element, "showDrill", true)
  let print_drill = attr_bool(element, "printDrill", false)
  let show_member_property_tips = attr_bool(
    element, "showMemberPropertyTips", true,
  )
  let show_data_tips = attr_bool(element, "showDataTips", true)
  let enable_wizard = attr_bool(element, "enableWizard", true)
  let enable_drill = attr_bool(element, "enableDrill", true)
  let enable_field_properties = attr_bool(
    element, "enableFieldProperties", true,
  )
  let preserve_formatting = attr_bool(element, "preserveFormatting", true)
  let use_auto_formatting = attr_bool(element, "useAutoFormatting", false)
  let page_wrap = attr_uint(element, "pageWrap", 0)
  let page_over_then_down = attr_bool(element, "pageOverThenDown", false)
  let subtotal_hidden_items = attr_bool(element, "subtotalHiddenItems", false)
  let row_grand_totals = attr_bool(element, "rowGrandTotals", true)
  let col_grand_totals = attr_bool(element, "colGrandTotals", true)
  let field_print_titles = attr_bool(element, "fieldPrintTitles", false)
  let item_print_titles = attr_bool(element, "itemPrintTitles", false)
  let merge_item = attr_bool(element, "mergeItem", false)
  let show_drop_zones = attr_bool(element, "showDropZones", true)
  let created_version = attr_uint(element, "createdVersion", 0)
  let indent = attr_uint(element, "indent", 1)
  let show_empty_row = attr_bool(element, "showEmptyRow", false)
  let show_empty_col = attr_bool(element, "showEmptyCol", false)
  let show_headers = attr_bool(element, "showHeaders", true)
  let compact = attr_bool(element, "compact", true)
  let outline = attr_bool(element, "outline", false)
  let outline_data = attr_bool(element, "outlineData", false)
  let compact_data = attr_bool(element, "compactData", true)
  let published = attr_bool(element, "published", false)
  let grid_drop_zones = attr_bool(element, "gridDropZones", false)
  let immersive = attr_bool(element, "immersive", true)
  let multiple_field_filters = attr_bool(element, "multipleFieldFilters", true)
  let chart_format = attr_uint(element, "chartFormat", 0)
  let row_header_caption = attr(element, "rowHeaderCaption")
  let col_header_caption = attr(element, "colHeaderCaption")
  let field_list_sort_ascending = attr_bool(
    element, "fieldListSortAscending", false,
  )
  let mdx_subqueries = attr_bool(element, "mdxSubqueries", false)
  let custom_list_sort = attr_bool(element, "customListSort", true)
  let mut location : CT_Location? = None
  let mut pivot_fields : CT_PivotFields? = None
  let mut row_fields : CT_RowFields? = None
  let mut row_items : CT_rowItems? = None
  let mut col_fields : CT_ColFields? = None
  let mut col_items : CT_colItems? = None
  let mut page_fields : CT_PageFields? = None
  let mut data_fields : CT_DataFields? = None
  let mut formats : CT_Formats? = None
  let mut conditional_formats : CT_ConditionalFormats? = None
  let mut chart_formats : CT_ChartFormats? = None
  let mut pivot_hierarchies : CT_PivotHierarchies? = None
  let mut pivot_table_style_info : CT_PivotTableStyle? = None
  let mut filters : CT_PivotFilters? = None
  let mut row_hierarchies_usage : CT_RowHierarchiesUsage? = None
  let mut col_hierarchies_usage : CT_ColHierarchiesUsage? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "location" => location = Some(CT_Location::new(child_element))
        "pivotFields" => pivot_fields = Some(CT_PivotFields::new(child_element))
        "rowFields" => row_fields = Some(CT_RowFields::new(child_element))
        "rowItems" => row_items = Some(CT_rowItems::new(child_element))
        "colFields" => col_fields = Some(CT_ColFields::new(child_element))
        "colItems" => col_items = Some(CT_colItems::new(child_element))
        "pageFields" => page_fields = Some(CT_PageFields::new(child_element))
        "dataFields" => data_fields = Some(CT_DataFields::new(child_element))
        "formats" => formats = Some(CT_Formats::new(child_element))
        "conditionalFormats" =>
          conditional_formats = Some(CT_ConditionalFormats::new(child_element))
        "chartFormats" =>
          chart_formats = Some(CT_ChartFormats::new(child_element))
        "pivotHierarchies" =>
          pivot_hierarchies = Some(CT_PivotHierarchies::new(child_element))
        "pivotTableStyleInfo" =>
          pivot_table_style_info = Some(CT_PivotTableStyle::new(child_element))
        "filters" => filters = Some(CT_PivotFilters::new(child_element))
        "rowHierarchiesUsage" =>
          row_hierarchies_usage = Some(
            CT_RowHierarchiesUsage::new(child_element),
          )
        "colHierarchiesUsage" =>
          col_hierarchies_usage = Some(
            CT_ColHierarchiesUsage::new(child_element),
          )
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    name,
    cache_id,
    data_on_rows,
    data_position,
    data_caption,
    grand_total_caption,
    error_caption,
    show_error,
    missing_caption,
    show_missing,
    page_style,
    pivot_table_style,
    vacated_style,
    tag,
    updated_version,
    min_refreshable_version,
    asterisk_totals,
    show_items,
    edit_data,
    disable_field_list,
    show_calc_mbrs,
    visual_totals,
    show_multiple_label,
    show_data_drop_down,
    show_drill,
    print_drill,
    show_member_property_tips,
    show_data_tips,
    enable_wizard,
    enable_drill,
    enable_field_properties,
    preserve_formatting,
    use_auto_formatting,
    page_wrap,
    page_over_then_down,
    subtotal_hidden_items,
    row_grand_totals,
    col_grand_totals,
    field_print_titles,
    item_print_titles,
    merge_item,
    show_drop_zones,
    created_version,
    indent,
    show_empty_row,
    show_empty_col,
    show_headers,
    compact,
    outline,
    outline_data,
    compact_data,
    published,
    grid_drop_zones,
    immersive,
    multiple_field_filters,
    chart_format,
    row_header_caption,
    col_header_caption,
    field_list_sort_ascending,
    mdx_subqueries,
    custom_list_sort,
    location,
    pivot_fields,
    row_fields,
    row_items,
    col_fields,
    col_items,
    page_fields,
    data_fields,
    formats,
    conditional_formats,
    chart_formats,
    pivot_hierarchies,
    pivot_table_style_info,
    filters,
    row_hierarchies_usage,
    col_hierarchies_usage,
    ext_lst,
  }
}

///|
/// XSD complex type CT_PivotFields — Part 1 §18.10.1.70. Pivot table
/// field list: optional `@count` (xsd:unsignedInt) and one or more
/// `<pivotField>` (CT_PivotField) children.
pub(all) struct CT_PivotFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <pivotField>+ (CT_PivotField) — one or more.
  pivot_fields : Array[CT_PivotField]
} derive(Eq, Debug)

///|
pub fn CT_PivotFields::new(element : @xml.Element) -> CT_PivotFields {
  let count = attr_uint_opt(element, "count")
  let pivot_fields : Array[CT_PivotField] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pivotField" {
        pivot_fields.push(CT_PivotField::new(child_element))
      }
    }
  }
  { element, count, pivot_fields }
}

///|
/// XSD complex type CT_PivotField — Part 1 §18.10.1.69. Single PivotTable
/// field descriptor carrying the full spec attribute bundle (axis,
/// dataField, subtotalCaption, layout toggles, drag toggles, autoShow
/// rule, sortType, subtotal aggregates, member-property prop flags,
/// numFmtId, defaultAttributeDrillState). Optional ordered children:
/// `<items>` (CT_Items), `<autoSortScope>` (CT_AutoSortScope),
/// `<extLst>` (CT_ExtensionList).
pub(all) struct CT_PivotField {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — optional.
  name : String?
  /// @axis (ST_Axis) — optional. Lexical preserved.
  axis : String?
  /// @dataField (xsd:boolean) — optional, default false.
  data_field : Bool
  /// @subtotalCaption (s:ST_Xstring) — optional.
  subtotal_caption : String?
  /// @showDropDowns (xsd:boolean) — optional, default true.
  show_drop_downs : Bool
  /// @hiddenLevel (xsd:boolean) — optional, default false.
  hidden_level : Bool
  /// @uniqueMemberProperty (s:ST_Xstring) — optional.
  unique_member_property : String?
  /// @compact (xsd:boolean) — optional, default true.
  compact : Bool
  /// @allDrilled (xsd:boolean) — optional, default false.
  all_drilled : Bool
  /// @numFmtId (ST_NumFmtId) — optional.
  num_fmt_id : String?
  /// @outline (xsd:boolean) — optional, default true.
  outline : Bool
  /// @subtotalTop (xsd:boolean) — optional, default true.
  subtotal_top : Bool
  /// @dragToRow (xsd:boolean) — optional, default true.
  drag_to_row : Bool
  /// @dragToCol (xsd:boolean) — optional, default true.
  drag_to_col : Bool
  /// @multipleItemSelectionAllowed (xsd:boolean) — optional, default false.
  multiple_item_selection_allowed : Bool
  /// @dragToPage (xsd:boolean) — optional, default true.
  drag_to_page : Bool
  /// @dragToData (xsd:boolean) — optional, default true.
  drag_to_data : Bool
  /// @dragOff (xsd:boolean) — optional, default true.
  drag_off : Bool
  /// @showAll (xsd:boolean) — optional, default true.
  show_all : Bool
  /// @insertBlankRow (xsd:boolean) — optional, default false.
  insert_blank_row : Bool
  /// @serverField (xsd:boolean) — optional, default false.
  server_field : Bool
  /// @insertPageBreak (xsd:boolean) — optional, default false.
  insert_page_break : Bool
  /// @autoShow (xsd:boolean) — optional, default false.
  auto_show : Bool
  /// @topAutoShow (xsd:boolean) — optional, default true.
  top_auto_show : Bool
  /// @hideNewItems (xsd:boolean) — optional, default false.
  hide_new_items : Bool
  /// @measureFilter (xsd:boolean) — optional, default false.
  measure_filter : Bool
  /// @includeNewItemsInFilter (xsd:boolean) — optional, default false.
  include_new_items_in_filter : Bool
  /// @itemPageCount (xsd:unsignedInt) — optional, default 10.
  item_page_count : Int
  /// @sortType (ST_FieldSortType) — optional, default "manual".
  sort_type : String?
  /// @dataSourceSort (xsd:boolean) — optional.
  data_source_sort : Bool?
  /// @nonAutoSortDefault (xsd:boolean) — optional, default false.
  non_auto_sort_default : Bool
  /// @rankBy (xsd:unsignedInt) — optional.
  rank_by : Int?
  /// @defaultSubtotal (xsd:boolean) — optional, default true.
  default_subtotal : Bool
  /// @sumSubtotal (xsd:boolean) — optional, default false.
  sum_subtotal : Bool
  /// @countASubtotal (xsd:boolean) — optional, default false.
  count_a_subtotal : Bool
  /// @avgSubtotal (xsd:boolean) — optional, default false.
  avg_subtotal : Bool
  /// @maxSubtotal (xsd:boolean) — optional, default false.
  max_subtotal : Bool
  /// @minSubtotal (xsd:boolean) — optional, default false.
  min_subtotal : Bool
  /// @productSubtotal (xsd:boolean) — optional, default false.
  product_subtotal : Bool
  /// @countSubtotal (xsd:boolean) — optional, default false.
  count_subtotal : Bool
  /// @stdDevSubtotal (xsd:boolean) — optional, default false.
  std_dev_subtotal : Bool
  /// @stdDevPSubtotal (xsd:boolean) — optional, default false.
  std_dev_p_subtotal : Bool
  /// @varSubtotal (xsd:boolean) — optional, default false.
  var_subtotal : Bool
  /// @varPSubtotal (xsd:boolean) — optional, default false.
  var_p_subtotal : Bool
  /// @showPropCell (xsd:boolean) — optional, default false.
  show_prop_cell : Bool
  /// @showPropTip (xsd:boolean) — optional, default false.
  show_prop_tip : Bool
  /// @showPropAsCaption (xsd:boolean) — optional, default false.
  show_prop_as_caption : Bool
  /// @defaultAttributeDrillState (xsd:boolean) — optional, default false.
  default_attribute_drill_state : Bool
  /// <items> (CT_Items) — optional.
  items : CT_Items?
  /// <autoSortScope> (CT_AutoSortScope) — optional.
  auto_sort_scope : CT_AutoSortScope?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PivotField::new(element : @xml.Element) -> CT_PivotField {
  let name = attr(element, "name")
  let axis = attr(element, "axis")
  let data_field = attr_bool(element, "dataField", false)
  let subtotal_caption = attr(element, "subtotalCaption")
  let show_drop_downs = attr_bool(element, "showDropDowns", true)
  let hidden_level = attr_bool(element, "hiddenLevel", false)
  let unique_member_property = attr(element, "uniqueMemberProperty")
  let compact = attr_bool(element, "compact", true)
  let all_drilled = attr_bool(element, "allDrilled", false)
  let num_fmt_id = attr(element, "numFmtId")
  let outline = attr_bool(element, "outline", true)
  let subtotal_top = attr_bool(element, "subtotalTop", true)
  let drag_to_row = attr_bool(element, "dragToRow", true)
  let drag_to_col = attr_bool(element, "dragToCol", true)
  let multiple_item_selection_allowed = attr_bool(
    element, "multipleItemSelectionAllowed", false,
  )
  let drag_to_page = attr_bool(element, "dragToPage", true)
  let drag_to_data = attr_bool(element, "dragToData", true)
  let drag_off = attr_bool(element, "dragOff", true)
  let show_all = attr_bool(element, "showAll", true)
  let insert_blank_row = attr_bool(element, "insertBlankRow", false)
  let server_field = attr_bool(element, "serverField", false)
  let insert_page_break = attr_bool(element, "insertPageBreak", false)
  let auto_show = attr_bool(element, "autoShow", false)
  let top_auto_show = attr_bool(element, "topAutoShow", true)
  let hide_new_items = attr_bool(element, "hideNewItems", false)
  let measure_filter = attr_bool(element, "measureFilter", false)
  let include_new_items_in_filter = attr_bool(
    element, "includeNewItemsInFilter", false,
  )
  let item_page_count = attr_uint(element, "itemPageCount", 10)
  let sort_type = attr(element, "sortType")
  let data_source_sort = attr_bool_opt(element, "dataSourceSort")
  let non_auto_sort_default = attr_bool(element, "nonAutoSortDefault", false)
  let rank_by = attr_uint_opt(element, "rankBy")
  let default_subtotal = attr_bool(element, "defaultSubtotal", true)
  let sum_subtotal = attr_bool(element, "sumSubtotal", false)
  let count_a_subtotal = attr_bool(element, "countASubtotal", false)
  let avg_subtotal = attr_bool(element, "avgSubtotal", false)
  let max_subtotal = attr_bool(element, "maxSubtotal", false)
  let min_subtotal = attr_bool(element, "minSubtotal", false)
  let product_subtotal = attr_bool(element, "productSubtotal", false)
  let count_subtotal = attr_bool(element, "countSubtotal", false)
  let std_dev_subtotal = attr_bool(element, "stdDevSubtotal", false)
  let std_dev_p_subtotal = attr_bool(element, "stdDevPSubtotal", false)
  let var_subtotal = attr_bool(element, "varSubtotal", false)
  let var_p_subtotal = attr_bool(element, "varPSubtotal", false)
  let show_prop_cell = attr_bool(element, "showPropCell", false)
  let show_prop_tip = attr_bool(element, "showPropTip", false)
  let show_prop_as_caption = attr_bool(element, "showPropAsCaption", false)
  let default_attribute_drill_state = attr_bool(
    element, "defaultAttributeDrillState", false,
  )
  let mut items : CT_Items? = None
  let mut auto_sort_scope : CT_AutoSortScope? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "items" => items = Some(CT_Items::new(child_element))
        "autoSortScope" =>
          auto_sort_scope = Some(CT_AutoSortScope::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    name,
    axis,
    data_field,
    subtotal_caption,
    show_drop_downs,
    hidden_level,
    unique_member_property,
    compact,
    all_drilled,
    num_fmt_id,
    outline,
    subtotal_top,
    drag_to_row,
    drag_to_col,
    multiple_item_selection_allowed,
    drag_to_page,
    drag_to_data,
    drag_off,
    show_all,
    insert_blank_row,
    server_field,
    insert_page_break,
    auto_show,
    top_auto_show,
    hide_new_items,
    measure_filter,
    include_new_items_in_filter,
    item_page_count,
    sort_type,
    data_source_sort,
    non_auto_sort_default,
    rank_by,
    default_subtotal,
    sum_subtotal,
    count_a_subtotal,
    avg_subtotal,
    max_subtotal,
    min_subtotal,
    product_subtotal,
    count_subtotal,
    std_dev_subtotal,
    std_dev_p_subtotal,
    var_subtotal,
    var_p_subtotal,
    show_prop_cell,
    show_prop_tip,
    show_prop_as_caption,
    default_attribute_drill_state,
    items,
    auto_sort_scope,
    ext_lst,
  }
}

///|
/// XSD complex type CT_PivotAreas — Part 1 §18.10.1.66. Container for
/// pivot areas used by conditional formats: optional `@count`
/// (xsd:unsignedInt) and zero or more `<pivotArea>` (CT_PivotArea)
/// children.
pub(all) struct CT_PivotAreas {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <pivotArea>* (CT_PivotArea) — zero or more.
  pivot_areas : Array[CT_PivotArea]
} derive(Eq, Debug)

///|
pub fn CT_PivotAreas::new(element : @xml.Element) -> CT_PivotAreas {
  let count = attr_uint_opt(element, "count")
  let pivot_areas : Array[CT_PivotArea] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pivotArea" {
        pivot_areas.push(CT_PivotArea::new(child_element))
      }
    }
  }
  { element, count, pivot_areas }
}

///|
/// XSD complex type CT_PivotHierarchies — Part 1 §18.10.1.71. OLAP
/// hierarchy list for a PivotTable: optional `@count` (xsd:unsignedInt)
/// and one or more `<pivotHierarchy>` (CT_PivotHierarchy) children.
pub(all) struct CT_PivotHierarchies {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <pivotHierarchy>+ (CT_PivotHierarchy) — one or more.
  pivot_hierarchies : Array[CT_PivotHierarchy]
} derive(Eq, Debug)

///|
pub fn CT_PivotHierarchies::new(element : @xml.Element) -> CT_PivotHierarchies {
  let count = attr_uint_opt(element, "count")
  let pivot_hierarchies : Array[CT_PivotHierarchy] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pivotHierarchy" {
        pivot_hierarchies.push(CT_PivotHierarchy::new(child_element))
      }
    }
  }
  { element, count, pivot_hierarchies }
}

///|
/// XSD complex type CT_PivotHierarchy — Part 1 §18.10.1.72. OLAP
/// hierarchy entry on a PivotTable: all attributes optional with
/// documented defaults (outline=false, multipleItemSelectionAllowed=false,
/// subtotalTop=false, showInFieldList=true, dragToRow/Col/Page=true,
/// dragToData=false, dragOff=true, includeNewItemsInFilter=false,
/// caption=s:ST_Xstring). Optional ordered children: `<mps>`
/// (CT_MemberProperties), zero or more `<members>` (CT_Members),
/// `<extLst>` (CT_ExtensionList).
pub(all) struct CT_PivotHierarchy {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @outline (xsd:boolean) — optional, default false.
  outline : Bool
  /// @multipleItemSelectionAllowed (xsd:boolean) — optional, default false.
  multiple_item_selection_allowed : Bool
  /// @subtotalTop (xsd:boolean) — optional, default false.
  subtotal_top : Bool
  /// @showInFieldList (xsd:boolean) — optional, default true.
  show_in_field_list : Bool
  /// @dragToRow (xsd:boolean) — optional, default true.
  drag_to_row : Bool
  /// @dragToCol (xsd:boolean) — optional, default true.
  drag_to_col : Bool
  /// @dragToPage (xsd:boolean) — optional, default true.
  drag_to_page : Bool
  /// @dragToData (xsd:boolean) — optional, default false.
  drag_to_data : Bool
  /// @dragOff (xsd:boolean) — optional, default true.
  drag_off : Bool
  /// @includeNewItemsInFilter (xsd:boolean) — optional, default false.
  include_new_items_in_filter : Bool
  /// @caption (s:ST_Xstring) — optional.
  caption : String?
  /// <mps> (CT_MemberProperties) — optional.
  mps : CT_MemberProperties?
  /// <members>* (CT_Members) — zero or more.
  members : Array[CT_Members]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PivotHierarchy::new(element : @xml.Element) -> CT_PivotHierarchy {
  let outline = attr_bool(element, "outline", false)
  let multiple_item_selection_allowed = attr_bool(
    element, "multipleItemSelectionAllowed", false,
  )
  let subtotal_top = attr_bool(element, "subtotalTop", false)
  let show_in_field_list = attr_bool(element, "showInFieldList", true)
  let drag_to_row = attr_bool(element, "dragToRow", true)
  let drag_to_col = attr_bool(element, "dragToCol", true)
  let drag_to_page = attr_bool(element, "dragToPage", true)
  let drag_to_data = attr_bool(element, "dragToData", false)
  let drag_off = attr_bool(element, "dragOff", true)
  let include_new_items_in_filter = attr_bool(
    element, "includeNewItemsInFilter", false,
  )
  let caption = attr(element, "caption")
  let mut mps : CT_MemberProperties? = None
  let members : Array[CT_Members] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "mps" => mps = Some(CT_MemberProperties::new(child_element))
        "members" => members.push(CT_Members::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    outline,
    multiple_item_selection_allowed,
    subtotal_top,
    show_in_field_list,
    drag_to_row,
    drag_to_col,
    drag_to_page,
    drag_to_data,
    drag_off,
    include_new_items_in_filter,
    caption,
    mps,
    members,
    ext_lst,
  }
}

///|
/// XSD complex type CT_RowHierarchiesUsage — Part 1 §18.10.1.82.
/// Container for row-axis OLAP hierarchy references: optional `@count`
/// (xsd:unsignedInt) and one or more `<rowHierarchyUsage>`
/// (CT_HierarchyUsage) children.
pub(all) struct CT_RowHierarchiesUsage {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <rowHierarchyUsage>+ (CT_HierarchyUsage) — one or more.
  row_hierarchy_usages : Array[CT_HierarchyUsage]
} derive(Eq, Debug)

///|
pub fn CT_RowHierarchiesUsage::new(
  element : @xml.Element,
) -> CT_RowHierarchiesUsage {
  let count = attr_uint_opt(element, "count")
  let row_hierarchy_usages : Array[CT_HierarchyUsage] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "rowHierarchyUsage" {
        row_hierarchy_usages.push(CT_HierarchyUsage::new(child_element))
      }
    }
  }
  { element, count, row_hierarchy_usages }
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
