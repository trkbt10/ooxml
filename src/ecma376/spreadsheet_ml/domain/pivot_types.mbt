///|
/// SpreadsheetML pivot typed domain wrappers from sml.xsd. CT_*
/// identifiers in this file bind the ECMA-376 Part 1 §18.10 (pivot
/// table / pivot cache) and §18.12 (query table) complex types. The
/// source `@xml.Element` is preserved on every typed record so the
/// builder can emit byte-identical round-trip output via `value.element`.

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
) -> CT_PivotCacheDefinition raise @opc_errors.SchemaViolation {
  let r_id = attr_with_ns(element, "id")
  let invalid = attr_bool_schema(
    element, "invalid", false, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let save_data = attr_bool_schema(
    element, "saveData", true, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let refresh_on_load = attr_bool_schema(
    element, "refreshOnLoad", false, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let optimize_memory = attr_bool_schema(
    element, "optimizeMemory", false, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let enable_refresh = attr_bool_schema(
    element, "enableRefresh", true, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let refreshed_by = attr(element, "refreshedBy")
  let refreshed_date_iso = attr(element, "refreshedDateIso")
  let background_query = attr_bool_schema(
    element, "backgroundQuery", false, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let missing_items_limit = attr_uint_opt_schema(element, "missingItemsLimit")
  let created_version = attr_uint_schema(element, "createdVersion", 0)
  let refreshed_version = attr_uint_schema(element, "refreshedVersion", 0)
  let min_refreshable_version = attr_uint_schema(
    element, "minRefreshableVersion", 0,
  )
  let record_count = attr_uint_opt_schema(element, "recordCount")
  let upgrade_on_refresh = attr_bool_schema(
    element, "upgradeOnRefresh", false, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let tuple_cache_attr = attr_bool_schema(
    element, "tupleCache", false, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let support_subquery = attr_bool_schema(
    element, "supportSubquery", false, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
  let support_advanced_drill = attr_bool_schema(
    element, "supportAdvancedDrill", false, "Part 1 §18.10.1.67", "pivotCacheDefinition",
  )
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
pub fn CT_CacheFields::new(
  element : @xml.Element,
) -> CT_CacheFields raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
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
pub fn CT_CacheField::new(
  element : @xml.Element,
) -> CT_CacheField raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let caption = attr(element, "caption")
  let property_name = attr(element, "propertyName")
  let server_field = attr_bool_schema(
    element, "serverField", false, "Part 1 §18.10.1.3", "cacheField",
  )
  let unique_list = attr_bool_schema(
    element, "uniqueList", true, "Part 1 §18.10.1.3", "cacheField",
  )
  let num_fmt_id = attr(element, "numFmtId")
  let formula = attr(element, "formula")
  let sql_type = attr_int_schema(element, "sqlType", 0)
  let hierarchy = attr_int_schema(element, "hierarchy", 0)
  let level = attr_uint_schema(element, "level", 0)
  let database_field = attr_bool_schema(
    element, "databaseField", true, "Part 1 §18.10.1.3", "cacheField",
  )
  let mapping_count = attr_uint_opt_schema(element, "mappingCount")
  let member_property_field = attr_bool_schema(
    element, "memberPropertyField", false, "Part 1 §18.10.1.3", "cacheField",
  )
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
pub fn CT_CacheSource::new(
  element : @xml.Element,
) -> CT_CacheSource raise @opc_errors.SchemaViolation {
  let type_ = match attr(element, "type") {
    Some(v) => v
    None => ""
  }
  let connection_id = attr_uint_schema(element, "connectionId", 0)
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
) -> CT_PivotCacheRecords raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
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
pub fn CT_CacheHierarchies::new(
  element : @xml.Element,
) -> CT_CacheHierarchies raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
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
pub fn CT_CacheHierarchy::new(
  element : @xml.Element,
) -> CT_CacheHierarchy raise @opc_errors.SchemaViolation {
  let unique_name = match attr(element, "uniqueName") {
    Some(v) => v
    None => ""
  }
  let caption = attr(element, "caption")
  let measure = attr_bool_schema(
    element, "measure", false, "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let set_ = attr_bool_schema(
    element, "set", false, "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let parent_set = attr_uint_opt_schema(element, "parentSet")
  let icon_set = attr_int_schema(element, "iconSet", 0)
  let attribute = attr_bool_schema(
    element, "attribute", false, "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let time = attr_bool_schema(
    element, "time", false, "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let key_attribute = attr_bool_schema(
    element, "keyAttribute", false, "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let default_member_unique_name = attr(element, "defaultMemberUniqueName")
  let all_unique_name = attr(element, "allUniqueName")
  let all_caption = attr(element, "allCaption")
  let dimension_unique_name = attr(element, "dimensionUniqueName")
  let display_folder = attr(element, "displayFolder")
  let measure_group = attr(element, "measureGroup")
  let measures = attr_bool_schema(
    element, "measures", false, "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let count = attr_uint_schema(element, "count", 0)
  let one_field = attr_bool_schema(
    element, "oneField", false, "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let member_value_datatype = attr_uint_opt_schema(
    element, "memberValueDatatype",
  )
  let unbalanced = attr_bool_schema_opt(
    element, "unbalanced", "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let unbalanced_group = attr_bool_schema_opt(
    element, "unbalancedGroup", "Part 1 §18.10.1.6", "cacheHierarchy",
  )
  let hidden = attr_bool_schema(
    element, "hidden", false, "Part 1 §18.10.1.6", "cacheHierarchy",
  )
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
pub fn CT_GroupMembers::new(
  element : @xml.Element,
) -> CT_GroupMembers raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
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
pub fn CT_GroupMember::new(
  element : @xml.Element,
) -> CT_GroupMember raise @opc_errors.SchemaViolation {
  let unique_name = match attr(element, "uniqueName") {
    Some(v) => v
    None => ""
  }
  let group = attr_bool_schema(
    element, "group", false, "Part 1 §18.10.1.41", "groupMember",
  )
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
pub fn CT_TupleCache::new(
  element : @xml.Element,
) -> CT_TupleCache raise @opc_errors.SchemaViolation {
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
pub fn CT_PCDSDTCEntries::new(
  element : @xml.Element,
) -> CT_PCDSDTCEntries raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
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
/// Schema sml.xsd complex type `CT_Sets`. Attributes: `count`. Child
/// elements: `set`. Child types: `CT_Set`.
///
/// XSD complex type CT_Sets — Part 1 §18.10.1.88 (sets parent). OLAP
/// set list: optional `@count` (xsd:unsignedInt) and one or more
/// `<set>` (CT_Set) children.
pub(all) struct CT_Sets {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional.
  count : Int?
  /// <set>+ (CT_Set) — one or more sets.
  sets : Array[CT_Set]
} derive(Eq, Debug)

///|
pub fn CT_Sets::new(
  element : @xml.Element,
) -> CT_Sets raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
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
pub fn CT_Set::new(
  element : @xml.Element,
) -> CT_Set raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
  let max_rank = attr_int_schema(element, "maxRank", 0)
  let set_definition = match attr(element, "setDefinition") {
    Some(v) => v
    None => ""
  }
  let sort_type = attr(element, "sortType")
  let query_failed = attr_bool_schema(
    element, "queryFailed", false, "Part 1 §18.10.1.88", "set",
  )
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
/// Schema sml.xsd complex type `CT_Query`. Attributes: `mdx`. Child
/// elements: `tpls`. Child types: `CT_Tuples`.
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
pub fn CT_CalculatedItems::new(
  element : @xml.Element,
) -> CT_CalculatedItems raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
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
pub fn CT_CalculatedItem::new(
  element : @xml.Element,
) -> CT_CalculatedItem raise @opc_errors.SchemaViolation {
  let field = attr_uint_opt_schema(element, "field")
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
) -> CT_CalculatedMembers raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
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
pub fn CT_CalculatedMember::new(
  element : @xml.Element,
) -> CT_CalculatedMember raise @opc_errors.SchemaViolation {
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
  let solve_order = attr_int_schema(element, "solveOrder", 0)
  let set_ = attr_bool_schema(
    element, "set", false, "Part 1 §18.10.1.10", "calculatedMember",
  )
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
fn pivot_table_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.10.1.73", "pivotTableDefinition",
  )
}

///|
pub fn CT_pivotTableDefinition::new(
  element : @xml.Element,
) -> CT_pivotTableDefinition raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(v) => v
    None => ""
  }
  let cache_id = attr_uint_schema(element, "cacheId", 0)
  let data_on_rows = pivot_table_bool(element, "dataOnRows", false)
  let data_position = attr_uint_opt_schema(element, "dataPosition")
  let data_caption = match attr(element, "dataCaption") {
    Some(v) => v
    None => ""
  }
  let grand_total_caption = attr(element, "grandTotalCaption")
  let error_caption = attr(element, "errorCaption")
  let show_error = pivot_table_bool(element, "showError", false)
  let missing_caption = attr(element, "missingCaption")
  let show_missing = pivot_table_bool(element, "showMissing", true)
  let page_style = attr(element, "pageStyle")
  let pivot_table_style = attr(element, "pivotTableStyle")
  let vacated_style = attr(element, "vacatedStyle")
  let tag = attr(element, "tag")
  let updated_version = attr_uint_schema(element, "updatedVersion", 0)
  let min_refreshable_version = attr_uint_schema(
    element, "minRefreshableVersion", 0,
  )
  let asterisk_totals = pivot_table_bool(element, "asteriskTotals", false)
  let show_items = pivot_table_bool(element, "showItems", true)
  let edit_data = pivot_table_bool(element, "editData", false)
  let disable_field_list = pivot_table_bool(element, "disableFieldList", false)
  let show_calc_mbrs = pivot_table_bool(element, "showCalcMbrs", true)
  let visual_totals = pivot_table_bool(element, "visualTotals", true)
  let show_multiple_label = pivot_table_bool(element, "showMultipleLabel", true)
  let show_data_drop_down = pivot_table_bool(element, "showDataDropDown", true)
  let show_drill = pivot_table_bool(element, "showDrill", true)
  let print_drill = pivot_table_bool(element, "printDrill", false)
  let show_member_property_tips = pivot_table_bool(
    element, "showMemberPropertyTips", true,
  )
  let show_data_tips = pivot_table_bool(element, "showDataTips", true)
  let enable_wizard = pivot_table_bool(element, "enableWizard", true)
  let enable_drill = pivot_table_bool(element, "enableDrill", true)
  let enable_field_properties = pivot_table_bool(
    element, "enableFieldProperties", true,
  )
  let preserve_formatting = pivot_table_bool(
    element, "preserveFormatting", true,
  )
  let use_auto_formatting = pivot_table_bool(
    element, "useAutoFormatting", false,
  )
  let page_wrap = attr_uint_schema(element, "pageWrap", 0)
  let page_over_then_down = pivot_table_bool(element, "pageOverThenDown", false)
  let subtotal_hidden_items = pivot_table_bool(
    element, "subtotalHiddenItems", false,
  )
  let row_grand_totals = pivot_table_bool(element, "rowGrandTotals", true)
  let col_grand_totals = pivot_table_bool(element, "colGrandTotals", true)
  let field_print_titles = pivot_table_bool(element, "fieldPrintTitles", false)
  let item_print_titles = pivot_table_bool(element, "itemPrintTitles", false)
  let merge_item = pivot_table_bool(element, "mergeItem", false)
  let show_drop_zones = pivot_table_bool(element, "showDropZones", true)
  let created_version = attr_uint_schema(element, "createdVersion", 0)
  let indent = attr_uint_schema(element, "indent", 1)
  let show_empty_row = pivot_table_bool(element, "showEmptyRow", false)
  let show_empty_col = pivot_table_bool(element, "showEmptyCol", false)
  let show_headers = pivot_table_bool(element, "showHeaders", true)
  let compact = pivot_table_bool(element, "compact", true)
  let outline = pivot_table_bool(element, "outline", false)
  let outline_data = pivot_table_bool(element, "outlineData", false)
  let compact_data = pivot_table_bool(element, "compactData", true)
  let published = pivot_table_bool(element, "published", false)
  let grid_drop_zones = pivot_table_bool(element, "gridDropZones", false)
  let immersive = pivot_table_bool(element, "immersive", true)
  let multiple_field_filters = pivot_table_bool(
    element, "multipleFieldFilters", true,
  )
  let chart_format = attr_uint_schema(element, "chartFormat", 0)
  let row_header_caption = attr(element, "rowHeaderCaption")
  let col_header_caption = attr(element, "colHeaderCaption")
  let field_list_sort_ascending = pivot_table_bool(
    element, "fieldListSortAscending", false,
  )
  let mdx_subqueries = pivot_table_bool(element, "mdxSubqueries", false)
  let custom_list_sort = pivot_table_bool(element, "customListSort", true)
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
pub fn CT_PivotFields::new(
  element : @xml.Element,
) -> CT_PivotFields raise @opc_errors.SchemaViolation {
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
fn pivot_field_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.10.1.69", "pivotField",
  )
}

///|
fn pivot_field_bool_opt(
  element : @xml.Element,
  local_name : String,
) -> Bool? raise @opc_errors.SchemaViolation {
  attr_bool_schema_opt(element, local_name, "Part 1 §18.10.1.69", "pivotField")
}

///|
pub fn CT_PivotField::new(
  element : @xml.Element,
) -> CT_PivotField raise @opc_errors.SchemaViolation {
  let name = attr(element, "name")
  let axis = attr(element, "axis")
  let data_field = pivot_field_bool(element, "dataField", false)
  let subtotal_caption = attr(element, "subtotalCaption")
  let show_drop_downs = pivot_field_bool(element, "showDropDowns", true)
  let hidden_level = pivot_field_bool(element, "hiddenLevel", false)
  let unique_member_property = attr(element, "uniqueMemberProperty")
  let compact = pivot_field_bool(element, "compact", true)
  let all_drilled = pivot_field_bool(element, "allDrilled", false)
  let num_fmt_id = attr(element, "numFmtId")
  let outline = pivot_field_bool(element, "outline", true)
  let subtotal_top = pivot_field_bool(element, "subtotalTop", true)
  let drag_to_row = pivot_field_bool(element, "dragToRow", true)
  let drag_to_col = pivot_field_bool(element, "dragToCol", true)
  let multiple_item_selection_allowed = pivot_field_bool(
    element, "multipleItemSelectionAllowed", false,
  )
  let drag_to_page = pivot_field_bool(element, "dragToPage", true)
  let drag_to_data = pivot_field_bool(element, "dragToData", true)
  let drag_off = pivot_field_bool(element, "dragOff", true)
  let show_all = pivot_field_bool(element, "showAll", true)
  let insert_blank_row = pivot_field_bool(element, "insertBlankRow", false)
  let server_field = pivot_field_bool(element, "serverField", false)
  let insert_page_break = pivot_field_bool(element, "insertPageBreak", false)
  let auto_show = pivot_field_bool(element, "autoShow", false)
  let top_auto_show = pivot_field_bool(element, "topAutoShow", true)
  let hide_new_items = pivot_field_bool(element, "hideNewItems", false)
  let measure_filter = pivot_field_bool(element, "measureFilter", false)
  let include_new_items_in_filter = pivot_field_bool(
    element, "includeNewItemsInFilter", false,
  )
  let item_page_count = attr_uint(element, "itemPageCount", 10)
  let sort_type = attr(element, "sortType")
  let data_source_sort = pivot_field_bool_opt(element, "dataSourceSort")
  let non_auto_sort_default = pivot_field_bool(
    element, "nonAutoSortDefault", false,
  )
  let rank_by = attr_uint_opt(element, "rankBy")
  let default_subtotal = pivot_field_bool(element, "defaultSubtotal", true)
  let sum_subtotal = pivot_field_bool(element, "sumSubtotal", false)
  let count_a_subtotal = pivot_field_bool(element, "countASubtotal", false)
  let avg_subtotal = pivot_field_bool(element, "avgSubtotal", false)
  let max_subtotal = pivot_field_bool(element, "maxSubtotal", false)
  let min_subtotal = pivot_field_bool(element, "minSubtotal", false)
  let product_subtotal = pivot_field_bool(element, "productSubtotal", false)
  let count_subtotal = pivot_field_bool(element, "countSubtotal", false)
  let std_dev_subtotal = pivot_field_bool(element, "stdDevSubtotal", false)
  let std_dev_p_subtotal = pivot_field_bool(element, "stdDevPSubtotal", false)
  let var_subtotal = pivot_field_bool(element, "varSubtotal", false)
  let var_p_subtotal = pivot_field_bool(element, "varPSubtotal", false)
  let show_prop_cell = pivot_field_bool(element, "showPropCell", false)
  let show_prop_tip = pivot_field_bool(element, "showPropTip", false)
  let show_prop_as_caption = pivot_field_bool(
    element, "showPropAsCaption", false,
  )
  let default_attribute_drill_state = pivot_field_bool(
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
pub fn CT_PivotAreas::new(
  element : @xml.Element,
) -> CT_PivotAreas raise @opc_errors.SchemaViolation {
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
pub fn CT_PivotHierarchies::new(
  element : @xml.Element,
) -> CT_PivotHierarchies raise @opc_errors.SchemaViolation {
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
fn pivot_hierarchy_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.10.1.72", "pivotHierarchy",
  )
}

///|
pub fn CT_PivotHierarchy::new(
  element : @xml.Element,
) -> CT_PivotHierarchy raise @opc_errors.SchemaViolation {
  let outline = pivot_hierarchy_bool(element, "outline", false)
  let multiple_item_selection_allowed = pivot_hierarchy_bool(
    element, "multipleItemSelectionAllowed", false,
  )
  let subtotal_top = pivot_hierarchy_bool(element, "subtotalTop", false)
  let show_in_field_list = pivot_hierarchy_bool(
    element, "showInFieldList", true,
  )
  let drag_to_row = pivot_hierarchy_bool(element, "dragToRow", true)
  let drag_to_col = pivot_hierarchy_bool(element, "dragToCol", true)
  let drag_to_page = pivot_hierarchy_bool(element, "dragToPage", true)
  let drag_to_data = pivot_hierarchy_bool(element, "dragToData", false)
  let drag_off = pivot_hierarchy_bool(element, "dragOff", true)
  let include_new_items_in_filter = pivot_hierarchy_bool(
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
/// XSD complex type CT_ColHierarchiesUsage — Part 1 §18.10.1.14. Column
/// hierarchies usage container. Optional `@count` (xsd:unsignedInt) and
/// one or more `<colHierarchyUsage>` (CT_HierarchyUsage) children.
pub(all) struct CT_ColHierarchiesUsage {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional aggregate count.
  count : Int?
  /// <colHierarchyUsage>+ (CT_HierarchyUsage) — one or more entries.
  col_hierarchy_usage : Array[CT_HierarchyUsage]
} derive(Eq, Debug)

///|
pub fn CT_ColHierarchiesUsage::new(
  element : @xml.Element,
) -> CT_ColHierarchiesUsage {
  let count = attr_uint_opt(element, "count")
  let col_hierarchy_usage : Array[CT_HierarchyUsage] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "colHierarchyUsage" {
        col_hierarchy_usage.push(CT_HierarchyUsage::new(child_element))
      }
    }
  }
  { element, count, col_hierarchy_usage }
}

///|
/// XSD complex type CT_HierarchyUsage — Part 1 §18.10.1.40. Pivot-table
/// hierarchy usage entry. Single required `@hierarchyUsage` (xsd:int)
/// referencing a cache hierarchy slot.
pub(all) struct CT_HierarchyUsage {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @hierarchyUsage (xsd:int) — required cache hierarchy reference.
  hierarchy_usage : Int
} derive(Eq, Debug)

///|
pub fn CT_HierarchyUsage::new(element : @xml.Element) -> CT_HierarchyUsage {
  let hierarchy_usage = attr_int(element, "hierarchyUsage", 0)
  { element, hierarchy_usage }
}

///|
/// XSD complex type CT_MemberProperties — Part 1 §18.10.1.55. Container
/// for OLAP member-property elements. Optional `@count` (xsd:unsignedInt)
/// and one or more `<mp>` (CT_MemberProperty) children.
pub(all) struct CT_MemberProperties {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional aggregate count.
  count : Int?
  /// <mp>+ (CT_MemberProperty) — one or more member property entries.
  mp : Array[CT_MemberProperty]
} derive(Eq, Debug)

///|
pub fn CT_MemberProperties::new(
  element : @xml.Element,
) -> CT_MemberProperties raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt(element, "count")
  let mp : Array[CT_MemberProperty] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "mp" {
        mp.push(CT_MemberProperty::new(child_element))
      }
    }
  }
  { element, count, mp }
}

///|
/// XSD complex type CT_MemberProperty — Part 1 §18.10.1.56. OLAP member
/// property reference on a pivot field. Required `@field` (xsd:unsignedInt)
/// links to the parent cache field; the optional `@name` (s:ST_Xstring),
/// presentation flags `@showCell`, `@showTip`, `@showAsCaption`
/// (xsd:boolean, default false), and source-layout fields `@nameLen`,
/// `@pPos`, `@pLen`, `@level` (xsd:unsignedInt) are all optional.
pub(all) struct CT_MemberProperty {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — optional caption.
  name : String?
  /// @showCell (xsd:boolean) — optional, default false.
  show_cell : Bool
  /// @showTip (xsd:boolean) — optional, default false.
  show_tip : Bool
  /// @showAsCaption (xsd:boolean) — optional, default false.
  show_as_caption : Bool
  /// @nameLen (xsd:unsignedInt) — optional name length hint.
  name_len : Int?
  /// @pPos (xsd:unsignedInt) — optional source position.
  p_pos : Int?
  /// @pLen (xsd:unsignedInt) — optional source length.
  p_len : Int?
  /// @level (xsd:unsignedInt) — optional cache hierarchy level.
  level : Int?
  /// @field (xsd:unsignedInt) — required parent field reference.
  field : Int
} derive(Eq, Debug)

///|
fn member_property_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(element, local_name, default, "Part 1 §18.10.1.56", "mp")
}

///|
pub fn CT_MemberProperty::new(
  element : @xml.Element,
) -> CT_MemberProperty raise @opc_errors.SchemaViolation {
  let name = attr(element, "name")
  let show_cell = member_property_bool(element, "showCell", false)
  let show_tip = member_property_bool(element, "showTip", false)
  let show_as_caption = member_property_bool(element, "showAsCaption", false)
  let name_len = attr_uint_opt(element, "nameLen")
  let p_pos = attr_uint_opt(element, "pPos")
  let p_len = attr_uint_opt(element, "pLen")
  let level = attr_uint_opt(element, "level")
  let field = attr_uint(element, "field", 0)
  {
    element,
    name,
    show_cell,
    show_tip,
    show_as_caption,
    name_len,
    p_pos,
    p_len,
    level,
    field,
  }
}

///|
/// XSD complex type CT_Members — Part 1 §18.10.1.57. OLAP member set
/// container. Optional `@count` (xsd:unsignedInt) and `@level`
/// (xsd:unsignedInt). Sequence of one or more `<member>` (CT_Member)
/// children.
pub(all) struct CT_Members {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional aggregate count.
  count : Int?
  /// @level (xsd:unsignedInt) — optional cache hierarchy level.
  level : Int?
  /// <member>+ (CT_Member) — one or more member entries.
  member_entries : Array[CT_Member]
} derive(Eq, Debug)

///|
pub fn CT_Members::new(element : @xml.Element) -> CT_Members {
  let count = attr_uint_opt(element, "count")
  let level = attr_uint_opt(element, "level")
  let member_entries : Array[CT_Member] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "member" {
        member_entries.push(CT_Member::new(child_element))
      }
    }
  }
  { element, count, level, member_entries }
}

///|
/// XSD complex type CT_Member — Part 1 §18.10.1.54. Single OLAP member
/// entry. Required `@name` (s:ST_Xstring) caption.
/// Schema sml.xsd complex type `CT_Member`. Attributes: `name`.
pub(all) struct CT_Member {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required member caption.
  name : String
} derive(Eq, Debug)

///|
pub fn CT_Member::new(element : @xml.Element) -> CT_Member {
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  { element, name }
}

///|
/// XSD complex type CT_PivotDimension — Part 1 §18.10.1.64. OLAP cube
/// dimension descriptor. Optional `@measure` (xsd:boolean, default false)
/// marks measure dimensions; required `@name`, `@uniqueName`, `@caption`
/// (s:ST_Xstring) name the dimension.
pub(all) struct CT_PivotDimension {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @measure (xsd:boolean) — optional, default false.
  measure : Bool
  /// @name (s:ST_Xstring) — required dimension name.
  name : String
  /// @uniqueName (s:ST_Xstring) — required MDX unique name.
  unique_name : String
  /// @caption (s:ST_Xstring) — required display caption.
  caption : String
} derive(Eq, Debug)

///|
fn pivot_dimension_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.10.1.64", "dimension",
  )
}

///|
pub fn CT_PivotDimension::new(
  element : @xml.Element,
) -> CT_PivotDimension raise @opc_errors.SchemaViolation {
  let measure = pivot_dimension_bool(element, "measure", false)
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let unique_name = match attr(element, "uniqueName") {
    Some(value) => value
    None => ""
  }
  let caption = match attr(element, "caption") {
    Some(value) => value
    None => ""
  }
  { element, measure, name, unique_name, caption }
}

///|
/// XSD complex type CT_MeasureGroups — Part 1 §18.10.1.51. Container for
/// OLAP measure-group descriptors. Optional `@count` (xsd:unsignedInt)
/// and zero or more `<measureGroup>` (CT_MeasureGroup) children.
pub(all) struct CT_MeasureGroups {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional aggregate count.
  count : Int?
  /// <measureGroup>* (CT_MeasureGroup) — zero or more entries.
  measure_group : Array[CT_MeasureGroup]
} derive(Eq, Debug)

///|
pub fn CT_MeasureGroups::new(element : @xml.Element) -> CT_MeasureGroups {
  let count = attr_uint_opt(element, "count")
  let measure_group : Array[CT_MeasureGroup] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "measureGroup" {
        measure_group.push(CT_MeasureGroup::new(child_element))
      }
    }
  }
  { element, count, measure_group }
}

///|
/// XSD complex type CT_MeasureDimensionMaps — Part 1 §18.10.1.49. Container
/// linking OLAP measures to dimensions. Optional `@count`
/// (xsd:unsignedInt) and zero or more `<map>` (CT_MeasureDimensionMap)
/// children.
pub(all) struct CT_MeasureDimensionMaps {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional aggregate count.
  count : Int?
  /// <map>* (CT_MeasureDimensionMap) — zero or more measure→dimension
  /// linkages.
  map : Array[CT_MeasureDimensionMap]
} derive(Eq, Debug)

///|
pub fn CT_MeasureDimensionMaps::new(
  element : @xml.Element,
) -> CT_MeasureDimensionMaps {
  let count = attr_uint_opt(element, "count")
  let map : Array[CT_MeasureDimensionMap] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "map" {
        map.push(CT_MeasureDimensionMap::new(child_element))
      }
    }
  }
  { element, count, map }
}

///|
/// XSD complex type CT_MeasureGroup — Part 1 §18.10.1.50. OLAP measure
/// group descriptor. Required `@name` (s:ST_Xstring) and `@caption`
/// (s:ST_Xstring).
pub(all) struct CT_MeasureGroup {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required measure group name.
  name : String
  /// @caption (s:ST_Xstring) — required display caption.
  caption : String
} derive(Eq, Debug)

///|
pub fn CT_MeasureGroup::new(element : @xml.Element) -> CT_MeasureGroup {
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let caption = match attr(element, "caption") {
    Some(value) => value
    None => ""
  }
  { element, name, caption }
}

///|
/// XSD complex type CT_MeasureDimensionMap — Part 1 §18.10.1.48. OLAP
/// measure-to-dimension binding. Optional `@measureGroup`
/// (xsd:unsignedInt) and `@dimension` (xsd:unsignedInt) reference the
/// parent CT_MeasureGroups / CT_PivotDimension slots respectively.
pub(all) struct CT_MeasureDimensionMap {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @measureGroup (xsd:unsignedInt) — optional measure group index.
  measure_group : Int?
  /// @dimension (xsd:unsignedInt) — optional dimension index.
  dimension : Int?
} derive(Eq, Debug)

///|
pub fn CT_MeasureDimensionMap::new(
  element : @xml.Element,
) -> CT_MeasureDimensionMap {
  let measure_group = attr_uint_opt(element, "measureGroup")
  let dimension = attr_uint_opt(element, "dimension")
  { element, measure_group, dimension }
}

///|
/// XSD complex type CT_PivotTableStyle — Part 1 §18.10.1.74. Pivot table
/// presentation style overrides. All attributes optional: `@name`
/// (xsd:string) names the referenced table style; `@showRowHeaders`,
/// `@showColHeaders`, `@showRowStripes`, `@showColStripes`,
/// `@showLastColumn` (xsd:boolean) toggle row/column emphasis.
pub(all) struct CT_PivotTableStyle {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (xsd:string) — optional referenced TableStyle name.
  name : String?
  /// @showRowHeaders (xsd:boolean) — optional.
  show_row_headers : Bool?
  /// @showColHeaders (xsd:boolean) — optional.
  show_col_headers : Bool?
  /// @showRowStripes (xsd:boolean) — optional.
  show_row_stripes : Bool?
  /// @showColStripes (xsd:boolean) — optional.
  show_col_stripes : Bool?
  /// @showLastColumn (xsd:boolean) — optional.
  show_last_column : Bool?
} derive(Eq, Debug)

///|
fn pivot_table_style_bool_opt(
  element : @xml.Element,
  local_name : String,
) -> Bool? raise @opc_errors.SchemaViolation {
  attr_bool_schema_opt(
    element, local_name, "Part 1 §18.10.1.74", "pivotTableStyleInfo",
  )
}

///|
pub fn CT_PivotTableStyle::new(
  element : @xml.Element,
) -> CT_PivotTableStyle raise @opc_errors.SchemaViolation {
  let name = attr(element, "name")
  let show_row_headers = pivot_table_style_bool_opt(element, "showRowHeaders")
  let show_col_headers = pivot_table_style_bool_opt(element, "showColHeaders")
  let show_row_stripes = pivot_table_style_bool_opt(element, "showRowStripes")
  let show_col_stripes = pivot_table_style_bool_opt(element, "showColStripes")
  let show_last_column = pivot_table_style_bool_opt(element, "showLastColumn")
  {
    element,
    name,
    show_row_headers,
    show_col_headers,
    show_row_stripes,
    show_col_stripes,
    show_last_column,
  }
}

///|
/// XSD complex type CT_PivotFilters — Part 1 §18.10.1.69. Container for
/// pivot-table filter rules. Optional `@count` (xsd:unsignedInt, default
/// 0) and zero or more `<filter>` (CT_PivotFilter) children.
pub(all) struct CT_PivotFilters {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
  /// <filter>* (CT_PivotFilter) — zero or more pivot filter entries.
  filter : Array[CT_PivotFilter]
} derive(Eq, Debug)

///|
pub fn CT_PivotFilters::new(element : @xml.Element) -> CT_PivotFilters {
  let count = attr_uint(element, "count", 0)
  let filter : Array[CT_PivotFilter] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "filter" {
        filter.push(CT_PivotFilter::new(child_element))
      }
    }
  }
  { element, count, filter }
}

///|
/// XSD complex type CT_PivotFilter — Part 1 §18.10.1.68. Single pivot
/// filter rule. Required `@fld` (xsd:unsignedInt) target field, `@type`
/// (ST_PivotFilterType lexical token), `@id` (xsd:unsignedInt) unique id.
/// Optional `@mpFld`, `@iMeasureHier`, `@iMeasureFld` (xsd:unsignedInt)
/// linkages; `@evalOrder` (xsd:int, default 0) sequencing; descriptive
/// `@name`, `@description`, `@stringValue1`, `@stringValue2`
/// (s:ST_Xstring). Sequence child `<autoFilter>` (CT_AutoFilter) carries
/// the underlying AutoFilter rule, with optional `<extLst>`
/// (CT_ExtensionList). The autoFilter child stays as a raw
/// `@xml.Element` so callers may pipe it through `@autofilter`'s typed
/// parser as needed.
pub(all) struct CT_PivotFilter {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @fld (xsd:unsignedInt) — required parent field index.
  fld : Int
  /// @mpFld (xsd:unsignedInt) — optional member-property field index.
  mp_fld : Int?
  /// @type (ST_PivotFilterType) — required filter kind token.
  type_ : String
  /// @evalOrder (xsd:int) — optional evaluation order, default 0.
  eval_order : Int
  /// @id (xsd:unsignedInt) — required unique filter id.
  id : Int
  /// @iMeasureHier (xsd:unsignedInt) — optional measure hierarchy index.
  i_measure_hier : Int?
  /// @iMeasureFld (xsd:unsignedInt) — optional measure field index.
  i_measure_fld : Int?
  /// @name (s:ST_Xstring) — optional caption.
  name : String?
  /// @description (s:ST_Xstring) — optional description.
  description : String?
  /// @stringValue1 (s:ST_Xstring) — optional comparand 1.
  string_value1 : String?
  /// @stringValue2 (s:ST_Xstring) — optional comparand 2 (between forms).
  string_value2 : String?
  /// <autoFilter> (CT_AutoFilter) — required AutoFilter payload retained
  /// as a raw element for downstream typed parsing in `@autofilter`.
  auto_filter : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PivotFilter::new(element : @xml.Element) -> CT_PivotFilter {
  let fld = attr_uint(element, "fld", 0)
  let mp_fld = attr_uint_opt(element, "mpFld")
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => ""
  }
  let eval_order = attr_int(element, "evalOrder", 0)
  let id = attr_uint(element, "id", 0)
  let i_measure_hier = attr_uint_opt(element, "iMeasureHier")
  let i_measure_fld = attr_uint_opt(element, "iMeasureFld")
  let name = attr(element, "name")
  let description = attr(element, "description")
  let string_value1 = attr(element, "stringValue1")
  let string_value2 = attr(element, "stringValue2")
  let mut auto_filter : @xml.Element? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "autoFilter" => auto_filter = Some(child_element)
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    fld,
    mp_fld,
    type_,
    eval_order,
    id,
    i_measure_hier,
    i_measure_fld,
    name,
    description,
    string_value1,
    string_value2,
    auto_filter,
    ext_lst,
  }
}

///|
/// XSD complex type CT_PivotArea — Part 1 §18.10.1.65. Pivot area
/// descriptor used by formats / styles / selections. Optional `@field`
/// (xsd:int) target field, `@type` (ST_PivotAreaType lexical token,
/// default "normal"), `@dataOnly` (xsd:boolean, default true),
/// `@labelOnly` / `@grandRow` / `@grandCol` / `@cacheIndex`
/// (xsd:boolean, default false), `@outline` (xsd:boolean, default true),
/// `@offset` (ST_Ref), `@collapsedLevelsAreSubtotals` (xsd:boolean,
/// default false), `@axis` (ST_Axis lexical token), `@fieldPosition`
/// (xsd:unsignedInt). Sequence children: `<references>`
/// (CT_PivotAreaReferences) and `<extLst>` (CT_ExtensionList).
pub(all) struct CT_PivotArea {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @field (xsd:int) — optional pivot field index.
  field : Int?
  /// @type (ST_PivotAreaType) — optional, default "normal".
  type_ : String
  /// @dataOnly (xsd:boolean) — optional, default true.
  data_only : Bool
  /// @labelOnly (xsd:boolean) — optional, default false.
  label_only : Bool
  /// @grandRow (xsd:boolean) — optional, default false.
  grand_row : Bool
  /// @grandCol (xsd:boolean) — optional, default false.
  grand_col : Bool
  /// @cacheIndex (xsd:boolean) — optional, default false.
  cache_index : Bool
  /// @outline (xsd:boolean) — optional, default true.
  outline : Bool
  /// @offset (ST_Ref) — optional A1 offset.
  offset : String?
  /// @collapsedLevelsAreSubtotals (xsd:boolean) — optional, default false.
  collapsed_levels_are_subtotals : Bool
  /// @axis (ST_Axis) — optional axis token (axisRow/axisCol/axisPage/axisValues).
  axis : String?
  /// @fieldPosition (xsd:unsignedInt) — optional field position.
  field_position : Int?
  /// <references> (CT_PivotAreaReferences) — optional reference list.
  references : CT_PivotAreaReferences?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
fn pivot_area_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.10.1.65", "pivotArea",
  )
}

///|
pub fn CT_PivotArea::new(
  element : @xml.Element,
) -> CT_PivotArea raise @opc_errors.SchemaViolation {
  let field = attr_int_opt(element, "field")
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => "normal"
  }
  let data_only = pivot_area_bool(element, "dataOnly", true)
  let label_only = pivot_area_bool(element, "labelOnly", false)
  let grand_row = pivot_area_bool(element, "grandRow", false)
  let grand_col = pivot_area_bool(element, "grandCol", false)
  let cache_index = pivot_area_bool(element, "cacheIndex", false)
  let outline = pivot_area_bool(element, "outline", true)
  let offset = attr(element, "offset")
  let collapsed_levels_are_subtotals = pivot_area_bool(
    element, "collapsedLevelsAreSubtotals", false,
  )
  let axis = attr(element, "axis")
  let field_position = attr_uint_opt(element, "fieldPosition")
  let mut references : CT_PivotAreaReferences? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "references" =>
          references = Some(CT_PivotAreaReferences::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    field,
    type_,
    data_only,
    label_only,
    grand_row,
    grand_col,
    cache_index,
    outline,
    offset,
    collapsed_levels_are_subtotals,
    axis,
    field_position,
    references,
    ext_lst,
  }
}

///|
/// XSD complex type CT_PivotAreaReferences — Part 1 §18.10.1.67. Container
/// for pivot-area reference entries. Optional `@count` (xsd:unsignedInt)
/// and one or more `<reference>` (CT_PivotAreaReference) children.
pub(all) struct CT_PivotAreaReferences {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional aggregate count.
  count : Int?
  /// <reference>+ (CT_PivotAreaReference) — one or more reference entries.
  reference : Array[CT_PivotAreaReference]
} derive(Eq, Debug)

///|
pub fn CT_PivotAreaReferences::new(
  element : @xml.Element,
) -> CT_PivotAreaReferences raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt(element, "count")
  let reference : Array[CT_PivotAreaReference] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "reference" {
        reference.push(CT_PivotAreaReference::new(child_element))
      }
    }
  }
  { element, count, reference }
}

///|
/// XSD complex type CT_PivotAreaReference — Part 1 §18.10.1.66. Single
/// pivot area reference. Optional `@field` (xsd:unsignedInt) target field
/// and `@count` (xsd:unsignedInt) child count. Boolean flags `@selected`
/// (default true), `@byPosition`, `@relative`, `@defaultSubtotal`,
/// `@sumSubtotal`, `@countASubtotal`, `@avgSubtotal`, `@maxSubtotal`,
/// `@minSubtotal`, `@productSubtotal`, `@countSubtotal`,
/// `@stdDevSubtotal`, `@stdDevPSubtotal`, `@varSubtotal`,
/// `@varPSubtotal` (default false). Sequence children: zero or more
/// `<x>` (CT_Index) item references and optional `<extLst>`
/// (CT_ExtensionList).
pub(all) struct CT_PivotAreaReference {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @field (xsd:unsignedInt) — optional pivot field index.
  field : Int?
  /// @count (xsd:unsignedInt) — optional child count.
  count : Int?
  /// @selected (xsd:boolean) — optional, default true.
  selected : Bool
  /// @byPosition (xsd:boolean) — optional, default false.
  by_position : Bool
  /// @relative (xsd:boolean) — optional, default false.
  relative : Bool
  /// @defaultSubtotal (xsd:boolean) — optional, default false.
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
  /// <x>* (CT_Index) — zero or more item index references.
  x : Array[CT_Index]
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
fn pivot_area_reference_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.10.1.66", "reference",
  )
}

///|
pub fn CT_PivotAreaReference::new(
  element : @xml.Element,
) -> CT_PivotAreaReference raise @opc_errors.SchemaViolation {
  let field = attr_uint_opt(element, "field")
  let count = attr_uint_opt(element, "count")
  let selected = pivot_area_reference_bool(element, "selected", true)
  let by_position = pivot_area_reference_bool(element, "byPosition", false)
  let relative = pivot_area_reference_bool(element, "relative", false)
  let default_subtotal = pivot_area_reference_bool(
    element, "defaultSubtotal", false,
  )
  let sum_subtotal = pivot_area_reference_bool(element, "sumSubtotal", false)
  let count_a_subtotal = pivot_area_reference_bool(
    element, "countASubtotal", false,
  )
  let avg_subtotal = pivot_area_reference_bool(element, "avgSubtotal", false)
  let max_subtotal = pivot_area_reference_bool(element, "maxSubtotal", false)
  let min_subtotal = pivot_area_reference_bool(element, "minSubtotal", false)
  let product_subtotal = pivot_area_reference_bool(
    element, "productSubtotal", false,
  )
  let count_subtotal = pivot_area_reference_bool(
    element, "countSubtotal", false,
  )
  let std_dev_subtotal = pivot_area_reference_bool(
    element, "stdDevSubtotal", false,
  )
  let std_dev_p_subtotal = pivot_area_reference_bool(
    element, "stdDevPSubtotal", false,
  )
  let var_subtotal = pivot_area_reference_bool(element, "varSubtotal", false)
  let var_p_subtotal = pivot_area_reference_bool(element, "varPSubtotal", false)
  let x : Array[CT_Index] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "x" => x.push(CT_Index::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    field,
    count,
    selected,
    by_position,
    relative,
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
    x,
    ext_lst,
  }
}

///|
/// XSD complex type CT_QueryTable — Part 1 §18.12.5. External query table.
/// Required `@name` (s:ST_Xstring) and `@connectionId` (xsd:unsignedInt)
/// referencing CT_Connections. Optional behaviour flags `@headers`
/// (default true), `@rowNumbers`, `@disableRefresh`, `@backgroundRefresh`
/// (default true), `@firstBackgroundRefresh`, `@refreshOnLoad`,
/// `@growShrinkType` (ST_GrowShrinkType, default "insertDelete"),
/// `@fillFormulas`, `@removeDataOnSave`, `@disableEdit`,
/// `@preserveFormatting` (default true), `@adjustColumnWidth` (default
/// true), `@intermediate` (xsd:boolean). The AG_AutoFormat attribute
/// group adds optional `@autoFormatId` (xsd:unsignedInt) and five
/// `@apply*Formats` (xsd:boolean) booleans. Sequence: optional
/// `<queryTableRefresh>` (CT_QueryTableRefresh) and `<extLst>`
/// (CT_ExtensionList).
pub(all) struct CT_QueryTable {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — required query table name.
  name : String
  /// @headers (xsd:boolean) — optional, default true.
  headers : Bool
  /// @rowNumbers (xsd:boolean) — optional, default false.
  row_numbers : Bool
  /// @disableRefresh (xsd:boolean) — optional, default false.
  disable_refresh : Bool
  /// @backgroundRefresh (xsd:boolean) — optional, default true.
  background_refresh : Bool
  /// @firstBackgroundRefresh (xsd:boolean) — optional, default false.
  first_background_refresh : Bool
  /// @refreshOnLoad (xsd:boolean) — optional, default false.
  refresh_on_load : Bool
  /// @growShrinkType (ST_GrowShrinkType) — optional, default "insertDelete".
  grow_shrink_type : String
  /// @fillFormulas (xsd:boolean) — optional, default false.
  fill_formulas : Bool
  /// @removeDataOnSave (xsd:boolean) — optional, default false.
  remove_data_on_save : Bool
  /// @disableEdit (xsd:boolean) — optional, default false.
  disable_edit : Bool
  /// @preserveFormatting (xsd:boolean) — optional, default true.
  preserve_formatting : Bool
  /// @adjustColumnWidth (xsd:boolean) — optional, default true.
  adjust_column_width : Bool
  /// @intermediate (xsd:boolean) — optional, default false.
  intermediate : Bool
  /// @connectionId (xsd:unsignedInt) — required connection reference.
  connection_id : Int
  /// AG_AutoFormat @autoFormatId (xsd:unsignedInt) — optional.
  auto_format_id : Int?
  /// AG_AutoFormat @applyNumberFormats (xsd:boolean) — optional.
  apply_number_formats : Bool?
  /// AG_AutoFormat @applyBorderFormats (xsd:boolean) — optional.
  apply_border_formats : Bool?
  /// AG_AutoFormat @applyFontFormats (xsd:boolean) — optional.
  apply_font_formats : Bool?
  /// AG_AutoFormat @applyPatternFormats (xsd:boolean) — optional.
  apply_pattern_formats : Bool?
  /// AG_AutoFormat @applyAlignmentFormats (xsd:boolean) — optional.
  apply_alignment_formats : Bool?
  /// AG_AutoFormat @applyWidthHeightFormats (xsd:boolean) — optional.
  apply_width_height_formats : Bool?
  /// <queryTableRefresh> (CT_QueryTableRefresh) — optional refresh metadata.
  query_table_refresh : CT_QueryTableRefresh?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
fn query_table_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.12.5", "queryTable",
  )
}

///|
fn query_table_bool_opt(
  element : @xml.Element,
  local_name : String,
) -> Bool? raise @opc_errors.SchemaViolation {
  attr_bool_schema_opt(element, local_name, "Part 1 §18.12.5", "queryTable")
}

///|
pub fn CT_QueryTable::new(
  element : @xml.Element,
) -> CT_QueryTable raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let headers = query_table_bool(element, "headers", true)
  let row_numbers = query_table_bool(element, "rowNumbers", false)
  let disable_refresh = query_table_bool(element, "disableRefresh", false)
  let background_refresh = query_table_bool(element, "backgroundRefresh", true)
  let first_background_refresh = query_table_bool(
    element, "firstBackgroundRefresh", false,
  )
  let refresh_on_load = query_table_bool(element, "refreshOnLoad", false)
  let grow_shrink_type = match attr(element, "growShrinkType") {
    Some(value) => value
    None => "insertDelete"
  }
  let fill_formulas = query_table_bool(element, "fillFormulas", false)
  let remove_data_on_save = query_table_bool(element, "removeDataOnSave", false)
  let disable_edit = query_table_bool(element, "disableEdit", false)
  let preserve_formatting = query_table_bool(
    element, "preserveFormatting", true,
  )
  let adjust_column_width = query_table_bool(element, "adjustColumnWidth", true)
  let intermediate = query_table_bool(element, "intermediate", false)
  let connection_id = attr_uint_schema(element, "connectionId", 0)
  let auto_format_id = attr_uint_opt_schema(element, "autoFormatId")
  let apply_number_formats = query_table_bool_opt(element, "applyNumberFormats")
  let apply_border_formats = query_table_bool_opt(element, "applyBorderFormats")
  let apply_font_formats = query_table_bool_opt(element, "applyFontFormats")
  let apply_pattern_formats = query_table_bool_opt(
    element, "applyPatternFormats",
  )
  let apply_alignment_formats = query_table_bool_opt(
    element, "applyAlignmentFormats",
  )
  let apply_width_height_formats = query_table_bool_opt(
    element, "applyWidthHeightFormats",
  )
  let mut query_table_refresh : CT_QueryTableRefresh? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "queryTableRefresh" =>
          query_table_refresh = Some(CT_QueryTableRefresh::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    name,
    headers,
    row_numbers,
    disable_refresh,
    background_refresh,
    first_background_refresh,
    refresh_on_load,
    grow_shrink_type,
    fill_formulas,
    remove_data_on_save,
    disable_edit,
    preserve_formatting,
    adjust_column_width,
    intermediate,
    connection_id,
    auto_format_id,
    apply_number_formats,
    apply_border_formats,
    apply_font_formats,
    apply_pattern_formats,
    apply_alignment_formats,
    apply_width_height_formats,
    query_table_refresh,
    ext_lst,
  }
}

///|
/// XSD complex type CT_QueryTableRefresh — Part 1 §18.12.7. Query table
/// refresh metadata. Optional flags `@preserveSortFilterLayout` (default
/// true), `@fieldIdWrapped`, `@headersInLastRefresh` (default true),
/// `@minimumVersion` (xsd:unsignedByte, default 0), `@nextId`
/// (xsd:unsignedInt, default 1), `@unboundColumnsLeft` /
/// `@unboundColumnsRight` (xsd:unsignedInt, default 0). Sequence:
/// required `<queryTableFields>` (CT_QueryTableFields), optional
/// `<queryTableDeletedFields>` (CT_QueryTableDeletedFields), `<sortState>`
/// (CT_SortState), and `<extLst>` (CT_ExtensionList).
pub(all) struct CT_QueryTableRefresh {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @preserveSortFilterLayout (xsd:boolean) — optional, default true.
  preserve_sort_filter_layout : Bool
  /// @fieldIdWrapped (xsd:boolean) — optional, default false.
  field_id_wrapped : Bool
  /// @headersInLastRefresh (xsd:boolean) — optional, default true.
  headers_in_last_refresh : Bool
  /// @minimumVersion (xsd:unsignedByte) — optional, default 0.
  minimum_version : Int
  /// @nextId (xsd:unsignedInt) — optional, default 1.
  next_id : Int
  /// @unboundColumnsLeft (xsd:unsignedInt) — optional, default 0.
  unbound_columns_left : Int
  /// @unboundColumnsRight (xsd:unsignedInt) — optional, default 0.
  unbound_columns_right : Int
  /// <queryTableFields> (CT_QueryTableFields) — required field set.
  query_table_fields : CT_QueryTableFields?
  /// <queryTableDeletedFields> (CT_QueryTableDeletedFields) — optional.
  query_table_deleted_fields : CT_QueryTableDeletedFields?
  /// <sortState> (CT_SortState) — optional sort state metadata.
  sort_state : CT_SortState?
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
fn query_table_refresh_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.12.7", "queryTableRefresh",
  )
}

///|
pub fn CT_QueryTableRefresh::new(
  element : @xml.Element,
) -> CT_QueryTableRefresh raise @opc_errors.SchemaViolation {
  let preserve_sort_filter_layout = query_table_refresh_bool(
    element, "preserveSortFilterLayout", true,
  )
  let field_id_wrapped = query_table_refresh_bool(
    element, "fieldIdWrapped", false,
  )
  let headers_in_last_refresh = query_table_refresh_bool(
    element, "headersInLastRefresh", true,
  )
  let minimum_version = attr_uint_schema(element, "minimumVersion", 0)
  let next_id = attr_uint_schema(element, "nextId", 1)
  let unbound_columns_left = attr_uint_schema(element, "unboundColumnsLeft", 0)
  let unbound_columns_right = attr_uint_schema(
    element, "unboundColumnsRight", 0,
  )
  let mut query_table_fields : CT_QueryTableFields? = None
  let mut query_table_deleted_fields : CT_QueryTableDeletedFields? = None
  let mut sort_state : CT_SortState? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "queryTableFields" =>
          query_table_fields = Some(CT_QueryTableFields::new(child_element))
        "queryTableDeletedFields" =>
          query_table_deleted_fields = Some(
            CT_QueryTableDeletedFields::new(child_element),
          )
        "sortState" => sort_state = Some(CT_SortState::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    preserve_sort_filter_layout,
    field_id_wrapped,
    headers_in_last_refresh,
    minimum_version,
    next_id,
    unbound_columns_left,
    unbound_columns_right,
    query_table_fields,
    query_table_deleted_fields,
    sort_state,
    ext_lst,
  }
}

///|
/// XSD complex type CT_QueryTableDeletedFields — Part 1 §18.12.6. Tracks
/// query table columns deleted since the last refresh. Optional `@count`
/// (xsd:unsignedInt) and one or more `<deletedField>` (CT_DeletedField)
/// children.
pub(all) struct CT_QueryTableDeletedFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional aggregate count.
  count : Int?
  /// <deletedField>+ (CT_DeletedField) — one or more deleted-field entries.
  deleted_field : Array[CT_DeletedField]
} derive(Eq, Debug)

///|
pub fn CT_QueryTableDeletedFields::new(
  element : @xml.Element,
) -> CT_QueryTableDeletedFields raise @opc_errors.SchemaViolation {
  let count = attr_uint_opt_schema(element, "count")
  let deleted_field : Array[CT_DeletedField] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "deletedField" {
        deleted_field.push(CT_DeletedField::new(child_element))
      }
    }
  }
  { element, count, deleted_field }
}

///|
/// XSD complex type CT_QueryTableFields — Part 1 §18.12.8. Container for
/// query table columns. Optional `@count` (xsd:unsignedInt, default 0)
/// and zero or more `<queryTableField>` (CT_QueryTableField) children.
pub(all) struct CT_QueryTableFields {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
  /// <queryTableField>* (CT_QueryTableField) — zero or more field entries.
  query_table_field : Array[CT_QueryTableField]
} derive(Eq, Debug)

///|
pub fn CT_QueryTableFields::new(
  element : @xml.Element,
) -> CT_QueryTableFields raise @opc_errors.SchemaViolation {
  let count = attr_uint_schema(element, "count", 0)
  let query_table_field : Array[CT_QueryTableField] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "queryTableField" {
        query_table_field.push(CT_QueryTableField::new(child_element))
      }
    }
  }
  { element, count, query_table_field }
}

///|
/// XSD complex type CT_QueryTableField — Part 1 §18.12.4. Single column
/// inside a query table. Required `@id` (xsd:unsignedInt). Optional
/// `@name` (s:ST_Xstring), `@dataBound` (xsd:boolean, default true),
/// `@rowNumbers`, `@fillFormulas`, `@clipped` (xsd:boolean, default
/// false), `@tableColumnId` (xsd:unsignedInt, default 0). Sequence:
/// optional `<extLst>` (CT_ExtensionList).
pub(all) struct CT_QueryTableField {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @id (xsd:unsignedInt) — required field id.
  id : Int
  /// @name (s:ST_Xstring) — optional caption.
  name : String?
  /// @dataBound (xsd:boolean) — optional, default true.
  data_bound : Bool
  /// @rowNumbers (xsd:boolean) — optional, default false.
  row_numbers : Bool
  /// @fillFormulas (xsd:boolean) — optional, default false.
  fill_formulas : Bool
  /// @clipped (xsd:boolean) — optional, default false.
  clipped : Bool
  /// @tableColumnId (xsd:unsignedInt) — optional, default 0.
  table_column_id : Int
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
fn query_table_field_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.12.4", "queryTableField",
  )
}

///|
pub fn CT_QueryTableField::new(
  element : @xml.Element,
) -> CT_QueryTableField raise @opc_errors.SchemaViolation {
  let id = attr_uint_schema(element, "id", 0)
  let name = attr(element, "name")
  let data_bound = query_table_field_bool(element, "dataBound", true)
  let row_numbers = query_table_field_bool(element, "rowNumbers", false)
  let fill_formulas = query_table_field_bool(element, "fillFormulas", false)
  let clipped = query_table_field_bool(element, "clipped", false)
  let table_column_id = attr_uint_schema(element, "tableColumnId", 0)
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
    id,
    name,
    data_bound,
    row_numbers,
    fill_formulas,
    clipped,
    table_column_id,
    ext_lst,
  }
}

///|
/// XSD complex type CT_RevisionQueryTableField — Part 1 §18.11.1.16.
/// Shared workbook revision entry tracking a query table field change.
/// Required `@sheetId` (xsd:unsignedInt) target sheet, `@ref` (ST_Ref)
/// affected range, `@fieldId` (xsd:unsignedInt) query table column id.
pub(all) struct CT_RevisionQueryTableField {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @sheetId (xsd:unsignedInt) — required sheet reference.
  sheet_id : Int
  /// @ref (ST_Ref) — required A1 range affected.
  ref_ : String
  /// @fieldId (xsd:unsignedInt) — required query table field id.
  field_id : Int
} derive(Eq, Debug)

///|
pub fn CT_RevisionQueryTableField::new(
  element : @xml.Element,
) -> CT_RevisionQueryTableField {
  let sheet_id = attr_uint(element, "sheetId", 0)
  let ref_ = match attr(element, "ref") {
    Some(value) => value
    None => ""
  }
  let field_id = attr_uint(element, "fieldId", 0)
  { element, sheet_id, ref_, field_id }
}

///|
/// XSD complex type CT_PivotSelection — Part 1 §18.18.71 (referenced
/// from §18.3.1.74). Pivot view selection state. All attributes optional:
/// `@pane` (ST_Pane lexical token, default "topLeft"); booleans
/// `@showHeader`, `@label`, `@data`, `@extendable` (default false);
/// counters `@count`, `@dimension`, `@start`, `@min`, `@max`,
/// `@activeRow`, `@activeCol`, `@previousRow`, `@previousCol`, `@click`
/// (xsd:unsignedInt, default 0); `@axis` (ST_Axis lexical token); and
/// optional relationship `r:id`. Sequence: required `<pivotArea>`
/// (CT_PivotArea) selection geometry.
pub(all) struct CT_PivotSelection {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @pane (ST_Pane) — optional, default "topLeft".
  pane : String
  /// @showHeader (xsd:boolean) — optional, default false.
  show_header : Bool
  /// @label (xsd:boolean) — optional, default false.
  label : Bool
  /// @data (xsd:boolean) — optional, default false.
  data : Bool
  /// @extendable (xsd:boolean) — optional, default false.
  extendable : Bool
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
  /// @axis (ST_Axis) — optional axis token.
  axis : String?
  /// @dimension (xsd:unsignedInt) — optional, default 0.
  dimension : Int
  /// @start (xsd:unsignedInt) — optional, default 0.
  start : Int
  /// @min (xsd:unsignedInt) — optional, default 0.
  min_ : Int
  /// @max (xsd:unsignedInt) — optional, default 0.
  max_ : Int
  /// @activeRow (xsd:unsignedInt) — optional, default 0.
  active_row : Int
  /// @activeCol (xsd:unsignedInt) — optional, default 0.
  active_col : Int
  /// @previousRow (xsd:unsignedInt) — optional, default 0.
  previous_row : Int
  /// @previousCol (xsd:unsignedInt) — optional, default 0.
  previous_col : Int
  /// @click (xsd:unsignedInt) — optional, default 0.
  click : Int
  /// @r:id (relationship reference) — optional rId pointer.
  r_id : String?
  /// <pivotArea> (CT_PivotArea) — required selection geometry.
  pivot_area : CT_PivotArea?
} derive(Eq, Debug)

///|
fn pivot_selection_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.18.71", "pivotSelection",
  )
}

///|
pub fn CT_PivotSelection::new(
  element : @xml.Element,
) -> CT_PivotSelection raise @opc_errors.SchemaViolation {
  let pane = match attr(element, "pane") {
    Some(value) => value
    None => "topLeft"
  }
  let show_header = pivot_selection_bool(element, "showHeader", false)
  let label = pivot_selection_bool(element, "label", false)
  let data = pivot_selection_bool(element, "data", false)
  let extendable = pivot_selection_bool(element, "extendable", false)
  let count = attr_uint(element, "count", 0)
  let axis = attr(element, "axis")
  let dimension = attr_uint(element, "dimension", 0)
  let start = attr_uint(element, "start", 0)
  let min_ = attr_uint(element, "min", 0)
  let max_ = attr_uint(element, "max", 0)
  let active_row = attr_uint(element, "activeRow", 0)
  let active_col = attr_uint(element, "activeCol", 0)
  let previous_row = attr_uint(element, "previousRow", 0)
  let previous_col = attr_uint(element, "previousCol", 0)
  let click = attr_uint(element, "click", 0)
  let r_id = attr_with_ns(element, "id")
  let mut pivot_area : CT_PivotArea? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pivotArea" {
        pivot_area = Some(CT_PivotArea::new(child_element))
      }
    }
  }
  {
    element,
    pane,
    show_header,
    label,
    data,
    extendable,
    count,
    axis,
    dimension,
    start,
    min_,
    max_,
    active_row,
    active_col,
    previous_row,
    previous_col,
    click,
    r_id,
    pivot_area,
  }
}

///|
/// XSD complex type CT_PageSetUpPr — Part 1 §18.3.1.60. SheetPr page-setup
/// hints. Optional `@autoPageBreaks` (xsd:boolean, default true) and
/// `@fitToPage` (xsd:boolean, default false).
pub(all) struct CT_PageSetUpPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @autoPageBreaks (xsd:boolean) — optional, default true.
  auto_page_breaks : Bool
  /// @fitToPage (xsd:boolean) — optional, default false.
  fit_to_page : Bool
} derive(Eq, Debug)

///|
fn page_set_up_pr_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.60", "pageSetUpPr",
  )
}

///|
pub fn CT_PageSetUpPr::new(
  element : @xml.Element,
) -> CT_PageSetUpPr raise @opc_errors.SchemaViolation {
  let auto_page_breaks = page_set_up_pr_bool(element, "autoPageBreaks", true)
  let fit_to_page = page_set_up_pr_bool(element, "fitToPage", false)
  { element, auto_page_breaks, fit_to_page }
}

///|
/// XSD complex type CT_PageSetup — Part 1 §18.3.1.63. Worksheet page setup.
/// All attributes optional: `@paperSize` (xsd:unsignedInt, default 1),
/// `@paperHeight` / `@paperWidth` (s:ST_PositiveUniversalMeasure custom
/// paper override), `@scale` (xsd:unsignedInt, default 100),
/// `@firstPageNumber` (default 1), `@fitToWidth`, `@fitToHeight`
/// (default 1), `@pageOrder` (ST_PageOrder, default "downThenOver"),
/// `@orientation` (ST_Orientation, default "default"),
/// `@usePrinterDefaults` (default true), `@blackAndWhite`, `@draft`
/// (default false), `@cellComments` (ST_CellComments, default "none"),
/// `@useFirstPageNumber` (default false), `@errors` (ST_PrintError,
/// default "displayed"), `@horizontalDpi` / `@verticalDpi` (default
/// 600), `@copies` (default 1), and optional relationship `r:id`.
pub(all) struct CT_PageSetup {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @paperSize (xsd:unsignedInt) — optional, default 1.
  paper_size : Int
  /// @paperHeight (s:ST_PositiveUniversalMeasure) — optional custom paper height.
  paper_height : String?
  /// @paperWidth (s:ST_PositiveUniversalMeasure) — optional custom paper width.
  paper_width : String?
  /// @scale (xsd:unsignedInt) — optional, default 100.
  scale : Int
  /// @firstPageNumber (xsd:unsignedInt) — optional, default 1.
  first_page_number : Int
  /// @fitToWidth (xsd:unsignedInt) — optional, default 1.
  fit_to_width : Int
  /// @fitToHeight (xsd:unsignedInt) — optional, default 1.
  fit_to_height : Int
  /// @pageOrder (ST_PageOrder) — optional, default "downThenOver".
  page_order : String
  /// @orientation (ST_Orientation) — optional, default "default".
  orientation : String
  /// @usePrinterDefaults (xsd:boolean) — optional, default true.
  use_printer_defaults : Bool
  /// @blackAndWhite (xsd:boolean) — optional, default false.
  black_and_white : Bool
  /// @draft (xsd:boolean) — optional, default false.
  draft : Bool
  /// @cellComments (ST_CellComments) — optional, default "none".
  cell_comments : String
  /// @useFirstPageNumber (xsd:boolean) — optional, default false.
  use_first_page_number : Bool
  /// @errors (ST_PrintError) — optional, default "displayed".
  errors : String
  /// @horizontalDpi (xsd:unsignedInt) — optional, default 600.
  horizontal_dpi : Int
  /// @verticalDpi (xsd:unsignedInt) — optional, default 600.
  vertical_dpi : Int
  /// @copies (xsd:unsignedInt) — optional, default 1.
  copies : Int
  /// @r:id (relationship reference) — optional rId pointer.
  r_id : String?
} derive(Eq, Debug)

///|
fn page_setup_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.63", "pageSetup",
  )
}

///|
pub fn CT_PageSetup::new(
  element : @xml.Element,
) -> CT_PageSetup raise @opc_errors.SchemaViolation {
  let paper_size = attr_uint(element, "paperSize", 1)
  let paper_height = attr(element, "paperHeight")
  let paper_width = attr(element, "paperWidth")
  let scale = attr_uint(element, "scale", 100)
  let first_page_number = attr_uint(element, "firstPageNumber", 1)
  let fit_to_width = attr_uint(element, "fitToWidth", 1)
  let fit_to_height = attr_uint(element, "fitToHeight", 1)
  let page_order = match attr(element, "pageOrder") {
    Some(value) => value
    None => "downThenOver"
  }
  let orientation = match attr(element, "orientation") {
    Some(value) => value
    None => "default"
  }
  let use_printer_defaults = page_setup_bool(
    element, "usePrinterDefaults", true,
  )
  let black_and_white = page_setup_bool(element, "blackAndWhite", false)
  let draft = page_setup_bool(element, "draft", false)
  let cell_comments = match attr(element, "cellComments") {
    Some(value) => value
    None => "none"
  }
  let use_first_page_number = page_setup_bool(
    element, "useFirstPageNumber", false,
  )
  let errors = match attr(element, "errors") {
    Some(value) => value
    None => "displayed"
  }
  let horizontal_dpi = attr_uint(element, "horizontalDpi", 600)
  let vertical_dpi = attr_uint(element, "verticalDpi", 600)
  let copies = attr_uint(element, "copies", 1)
  let r_id = attr_with_ns(element, "id")
  {
    element,
    paper_size,
    paper_height,
    paper_width,
    scale,
    first_page_number,
    fit_to_width,
    fit_to_height,
    page_order,
    orientation,
    use_printer_defaults,
    black_and_white,
    draft,
    cell_comments,
    use_first_page_number,
    errors,
    horizontal_dpi,
    vertical_dpi,
    copies,
    r_id,
  }
}

///|
/// XSD complex type CT_CsPageSetup — Part 1 §18.3.1.13. Chartsheet page
/// setup (subset of CT_PageSetup without paging/print-cell-comments).
/// All attributes optional: `@paperSize` (xsd:unsignedInt, default 1),
/// `@paperHeight`, `@paperWidth` (s:ST_PositiveUniversalMeasure),
/// `@firstPageNumber` (default 1), `@orientation` (ST_Orientation,
/// default "default"), `@usePrinterDefaults` (default true),
/// `@blackAndWhite`, `@draft` (default false), `@useFirstPageNumber`
/// (default false), `@horizontalDpi`, `@verticalDpi` (default 600),
/// `@copies` (default 1), and optional relationship `r:id`.
pub(all) struct CT_CsPageSetup {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @paperSize (xsd:unsignedInt) — optional, default 1.
  paper_size : Int
  /// @paperHeight (s:ST_PositiveUniversalMeasure) — optional.
  paper_height : String?
  /// @paperWidth (s:ST_PositiveUniversalMeasure) — optional.
  paper_width : String?
  /// @firstPageNumber (xsd:unsignedInt) — optional, default 1.
  first_page_number : Int
  /// @orientation (ST_Orientation) — optional, default "default".
  orientation : String
  /// @usePrinterDefaults (xsd:boolean) — optional, default true.
  use_printer_defaults : Bool
  /// @blackAndWhite (xsd:boolean) — optional, default false.
  black_and_white : Bool
  /// @draft (xsd:boolean) — optional, default false.
  draft : Bool
  /// @useFirstPageNumber (xsd:boolean) — optional, default false.
  use_first_page_number : Bool
  /// @horizontalDpi (xsd:unsignedInt) — optional, default 600.
  horizontal_dpi : Int
  /// @verticalDpi (xsd:unsignedInt) — optional, default 600.
  vertical_dpi : Int
  /// @copies (xsd:unsignedInt) — optional, default 1.
  copies : Int
  /// @r:id (relationship reference) — optional rId pointer.
  r_id : String?
} derive(Eq, Debug)

///|
fn cs_page_setup_bool(
  element : @xml.Element,
  local_name : String,
  default : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  attr_bool_schema(
    element, local_name, default, "Part 1 §18.3.1.13", "pageSetup",
  )
}

///|
pub fn CT_CsPageSetup::new(
  element : @xml.Element,
) -> CT_CsPageSetup raise @opc_errors.SchemaViolation {
  let paper_size = attr_uint(element, "paperSize", 1)
  let paper_height = attr(element, "paperHeight")
  let paper_width = attr(element, "paperWidth")
  let first_page_number = attr_uint(element, "firstPageNumber", 1)
  let orientation = match attr(element, "orientation") {
    Some(value) => value
    None => "default"
  }
  let use_printer_defaults = cs_page_setup_bool(
    element, "usePrinterDefaults", true,
  )
  let black_and_white = cs_page_setup_bool(element, "blackAndWhite", false)
  let draft = cs_page_setup_bool(element, "draft", false)
  let use_first_page_number = cs_page_setup_bool(
    element, "useFirstPageNumber", false,
  )
  let horizontal_dpi = attr_uint(element, "horizontalDpi", 600)
  let vertical_dpi = attr_uint(element, "verticalDpi", 600)
  let copies = attr_uint(element, "copies", 1)
  let r_id = attr_with_ns(element, "id")
  {
    element,
    paper_size,
    paper_height,
    paper_width,
    first_page_number,
    orientation,
    use_printer_defaults,
    black_and_white,
    draft,
    use_first_page_number,
    horizontal_dpi,
    vertical_dpi,
    copies,
    r_id,
  }
}

///|
/// XSD complex type CT_MdxMetadata — Part 1 §18.9.7. MDX metadata
/// container inside CT_Metadata. Optional `@count` (xsd:unsignedInt,
/// default 0) and one or more `<mdx>` (CT_Mdx) children.
pub(all) struct CT_MdxMetadata {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional, default 0.
  count : Int
  /// <mdx>+ (CT_Mdx) — one or more MDX metadata records.
  mdx : Array[CT_Mdx]
} derive(Eq, Debug)

///|
pub fn CT_MdxMetadata::new(
  element : @xml.Element,
) -> CT_MdxMetadata raise @opc_errors.SchemaViolation {
  let count = attr_uint(element, "count", 0)
  let mdx : Array[CT_Mdx] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "mdx" {
        mdx.push(CT_Mdx::new(child_element))
      }
    }
  }
  { element, count, mdx }
}

///|
/// XSD complex type CT_Mdx — Part 1 §18.9.5. Single MDX metadata record.
/// Required `@n` (xsd:unsignedInt) MDX metadata index and `@f`
/// (ST_MdxFunctionType: `m`, `v`, `s`, `c`, `r`, `p`, `k`) function
/// kind. Choice of exactly one of `<t>` (CT_MdxTuple), `<ms>`
/// (CT_MdxSet), `<p>` (CT_MdxMemeberProp), `<k>` (CT_MdxKPI), preserved
/// as the populated variant of CT_Mdx_Choice.
pub(all) struct CT_Mdx {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @n (xsd:unsignedInt) — required MDX metadata index.
  n : Int
  /// @f (ST_MdxFunctionType) — required function kind token.
  f : String
  /// Required choice variant.
  choice : CT_Mdx_Choice?
} derive(Eq, Debug)

///|
/// XSD `<xsd:choice>` inside CT_Mdx — Part 1 §18.9.5. Exactly one of
/// `<t>` (CT_MdxTuple), `<ms>` (CT_MdxSet), `<p>` (CT_MdxMemeberProp),
/// `<k>` (CT_MdxKPI).
pub(all) enum CT_Mdx_Choice {
  T(CT_MdxTuple)
  Ms(CT_MdxSet)
  P(CT_MdxMemeberProp)
  K(CT_MdxKPI)
} derive(Eq, Debug)

///|
pub fn CT_Mdx::new(
  element : @xml.Element,
) -> CT_Mdx raise @opc_errors.SchemaViolation {
  let n = attr_uint(element, "n", 0)
  let f = match attr(element, "f") {
    Some(value) => value
    None => ""
  }
  let mut choice : CT_Mdx_Choice? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "t" => choice = Some(CT_Mdx_Choice::T(CT_MdxTuple::new(child_element)))
        "ms" => choice = Some(CT_Mdx_Choice::Ms(CT_MdxSet::new(child_element)))
        "p" =>
          choice = Some(CT_Mdx_Choice::P(CT_MdxMemeberProp::new(child_element)))
        "k" => choice = Some(CT_Mdx_Choice::K(CT_MdxKPI::new(child_element)))
        _ => ()
      }
    }
  }
  { element, n, f, choice }
}

///|
/// XSD complex type CT_MdxTuple — Part 1 §18.9.9. MDX tuple metadata.
/// Optional `@c` (xsd:unsignedInt, default 0) cube count, `@ct`
/// (s:ST_Xstring) cube text, `@si` (xsd:unsignedInt) string index,
/// `@fi` (xsd:unsignedInt) format index, `@bc` (ST_UnsignedIntHex)
/// background ARGB, `@fc` (ST_UnsignedIntHex) foreground ARGB, and
/// formatting flags `@i`, `@u`, `@st`, `@b` (xsd:boolean, default
/// false). Sequence: zero or more `<n>` (CT_MetadataStringIndex)
/// children that name the tuple members.
pub(all) struct CT_MdxTuple {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @c (xsd:unsignedInt) — optional, default 0.
  c : Int
  /// @ct (s:ST_Xstring) — optional cube text.
  ct : String?
  /// @si (xsd:unsignedInt) — optional string index.
  si : Int?
  /// @fi (xsd:unsignedInt) — optional format index.
  fi : Int?
  /// @bc (ST_UnsignedIntHex) — optional background ARGB.
  bc : Int?
  /// @fc (ST_UnsignedIntHex) — optional foreground ARGB.
  fc : Int?
  /// @i (xsd:boolean) — optional italic, default false.
  i : Bool
  /// @u (xsd:boolean) — optional underline, default false.
  u : Bool
  /// @st (xsd:boolean) — optional strike-through, default false.
  st : Bool
  /// @b (xsd:boolean) — optional bold, default false.
  b : Bool
  /// <n>* (CT_MetadataStringIndex) — zero or more member name indices.
  n : Array[CT_MetadataStringIndex]
} derive(Eq, Debug)

///|
pub fn CT_MdxTuple::new(
  element : @xml.Element,
) -> CT_MdxTuple raise @opc_errors.SchemaViolation {
  let c = attr_uint(element, "c", 0)
  let ct = attr(element, "ct")
  let si = attr_uint_opt(element, "si")
  let fi = attr_uint_opt(element, "fi")
  let bc = attr_hex_uint_opt(element, "bc")
  let fc = attr_hex_uint_opt(element, "fc")
  let i = attr_bool_schema(element, "i", false, "Part 1 §18.9.9", "t")
  let u = attr_bool_schema(element, "u", false, "Part 1 §18.9.9", "t")
  let st = attr_bool_schema(element, "st", false, "Part 1 §18.9.9", "t")
  let b = attr_bool_schema(element, "b", false, "Part 1 §18.9.9", "t")
  let n : Array[CT_MetadataStringIndex] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "n" {
        n.push(CT_MetadataStringIndex::new(child_element))
      }
    }
  }
  { element, c, ct, si, fi, bc, fc, i, u, st, b, n }
}

///|
/// Schema sml.xsd complex type `CT_MdxSet`. Attributes: `ns`, `c`,
/// `o`. Child elements: `n`. Child types: `CT_MetadataStringIndex`.
///
/// XSD complex type CT_MdxSet — Part 1 §18.9.8. MDX set metadata.
/// Required `@ns` (xsd:unsignedInt) parent set reference. Optional
/// `@c` (xsd:unsignedInt, default 0) count and `@o` (ST_MdxSetOrder,
/// default "u") order token from {`u`, `a`, `d`, `aa`, `ad`, `na`,
/// `nd`}. Sequence: zero or more `<n>` (CT_MetadataStringIndex)
/// members.
pub(all) struct CT_MdxSet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ns (xsd:unsignedInt) — required parent set reference.
  ns : Int
  /// @c (xsd:unsignedInt) — optional, default 0.
  c : Int
  /// @o (ST_MdxSetOrder) — optional ordering token, default "u".
  o : String
  /// <n>* (CT_MetadataStringIndex) — zero or more member name indices.
  n : Array[CT_MetadataStringIndex]
} derive(Eq, Debug)

///|
pub fn CT_MdxSet::new(
  element : @xml.Element,
) -> CT_MdxSet raise @opc_errors.SchemaViolation {
  let ns = attr_uint(element, "ns", 0)
  let c = attr_uint(element, "c", 0)
  let o = match attr(element, "o") {
    Some(value) => value
    None => "u"
  }
  let n : Array[CT_MetadataStringIndex] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "n" {
        n.push(CT_MetadataStringIndex::new(child_element))
      }
    }
  }
  { element, ns, c, o, n }
}

///|
/// XSD complex type CT_MdxMemeberProp — Part 1 §18.9.6. MDX member
/// property metadata. Required `@n` (xsd:unsignedInt) name index and
/// `@np` (xsd:unsignedInt) property index. (XSD spelling "Memeber"
/// preserved verbatim.)
pub(all) struct CT_MdxMemeberProp {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @n (xsd:unsignedInt) — required name index.
  n : Int
  /// @np (xsd:unsignedInt) — required property index.
  np : Int
} derive(Eq, Debug)

///|
pub fn CT_MdxMemeberProp::new(element : @xml.Element) -> CT_MdxMemeberProp {
  let n = attr_uint(element, "n", 0)
  let np = attr_uint(element, "np", 0)
  { element, n, np }
}

///|
/// XSD complex type CT_MdxKPI — Part 1 §18.9.4. MDX KPI metadata.
/// Required `@n` (xsd:unsignedInt) name index, `@np` (xsd:unsignedInt)
/// property index, and `@p` (ST_MdxKPIProperty token from
/// {`v`, `g`, `s`, `t`, `w`, `m`}).
/// Schema sml.xsd complex type `CT_MdxKPI`. Attributes: `n`, `np`, `p`.
pub(all) struct CT_MdxKPI {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @n (xsd:unsignedInt) — required name index.
  n : Int
  /// @np (xsd:unsignedInt) — required property index.
  np : Int
  /// @p (ST_MdxKPIProperty) — required KPI property selector token.
  p : String
} derive(Eq, Debug)

///|
pub fn CT_MdxKPI::new(element : @xml.Element) -> CT_MdxKPI {
  let n = attr_uint(element, "n", 0)
  let np = attr_uint(element, "np", 0)
  let p = match attr(element, "p") {
    Some(value) => value
    None => ""
  }
  { element, n, np, p }
}

///|
/// XSD complex type CT_ExternalSheetDataSet — Part 1 §18.14.7. Container
/// for cached external workbook sheet data. Sequence: one or more
/// `<sheetData>` (CT_ExternalSheetData) children. No attributes.
pub(all) struct CT_ExternalSheetDataSet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <sheetData>+ (CT_ExternalSheetData) — one or more cached sheet snapshots.
  sheet_data : Array[CT_ExternalSheetData]
} derive(Eq, Debug)

///|
pub fn CT_ExternalSheetDataSet::new(
  element : @xml.Element,
) -> CT_ExternalSheetDataSet raise @opc_errors.SchemaViolation {
  let sheet_data : Array[CT_ExternalSheetData] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "sheetData" {
        sheet_data.push(CT_ExternalSheetData::new(child_element))
      }
    }
  }
  { element, sheet_data }
}

///|
/// XSD complex type CT_PivotCaches — Part 1 §18.2.19. Workbook-level
/// container for pivot cache references. Sequence: one or more
/// `<pivotCache>` (CT_PivotCache) children. No attributes.
pub(all) struct CT_PivotCaches {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pivotCache>+ (CT_PivotCache) — one or more pivot cache entries.
  pivot_cache : Array[CT_PivotCache]
} derive(Eq, Debug)

///|
pub fn CT_PivotCaches::new(element : @xml.Element) -> CT_PivotCaches {
  let pivot_cache : Array[CT_PivotCache] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "pivotCache" {
        pivot_cache.push(CT_PivotCache::new(child_element))
      }
    }
  }
  { element, pivot_cache }
}

///|
/// XSD complex type CT_PivotCache — Part 1 §18.2.18. Single pivot cache
/// reference inside CT_PivotCaches. Required `@cacheId` (xsd:unsignedInt)
/// workbook-unique cache slot and `r:id` (relationship reference)
/// pointing at the cache definition part.
pub(all) struct CT_PivotCache {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @cacheId (xsd:unsignedInt) — required workbook-unique cache id.
  cache_id : Int
  /// @r:id (relationship reference) — required rId pointer to the cache
  /// definition part.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_PivotCache::new(element : @xml.Element) -> CT_PivotCache {
  let cache_id = attr_uint(element, "cacheId", 0)
  let r_id = match attr_with_ns(element, "id") {
    Some(value) => value
    None => ""
  }
  { element, cache_id, r_id }
}
