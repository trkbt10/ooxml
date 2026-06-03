///|
/// SpreadsheetML style types wrappers generated from sml.xsd complex type identifiers.

///|
pub fn style_type_group_name() -> String {
  "spreadsheet_ml.style"
}

///|
/// XSD complex type CT_SheetProtection — Part 1 §18.3.1.85 (`<sheetProtection>`
/// Sheet Protection Options). Attribute-only complex type: optional cryptographic
/// attributes `@algorithmName` (s:ST_Xstring), `@hashValue` (xsd:base64Binary),
/// `@saltValue` (xsd:base64Binary), `@spinCount` (xsd:unsignedInt); plus
/// boolean lockable-action flags with default values per XSD.
pub(all) struct CT_SheetProtection {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @algorithmName (s:ST_Xstring) — optional hash algorithm identifier.
  algorithm_name : String?
  /// @hashValue (xsd:base64Binary) — optional password hash.
  hash_value : String?
  /// @saltValue (xsd:base64Binary) — optional salt for the hash.
  salt_value : String?
  /// @spinCount (xsd:unsignedInt) — optional hash iteration count.
  spin_count : Int?
  /// @sheet (xsd:boolean) — optional, default false.
  sheet : Bool
  /// @objects (xsd:boolean) — optional, default false.
  objects : Bool
  /// @scenarios (xsd:boolean) — optional, default false.
  scenarios : Bool
  /// @formatCells (xsd:boolean) — optional, default true.
  format_cells : Bool
  /// @formatColumns (xsd:boolean) — optional, default true.
  format_columns : Bool
  /// @formatRows (xsd:boolean) — optional, default true.
  format_rows : Bool
  /// @insertColumns (xsd:boolean) — optional, default true.
  insert_columns : Bool
  /// @insertRows (xsd:boolean) — optional, default true.
  insert_rows : Bool
  /// @insertHyperlinks (xsd:boolean) — optional, default true.
  insert_hyperlinks : Bool
  /// @deleteColumns (xsd:boolean) — optional, default true.
  delete_columns : Bool
  /// @deleteRows (xsd:boolean) — optional, default true.
  delete_rows : Bool
  /// @selectLockedCells (xsd:boolean) — optional, default false.
  select_locked_cells : Bool
  /// @sort (xsd:boolean) — optional, default true.
  sort : Bool
  /// @autoFilter (xsd:boolean) — optional, default true.
  auto_filter : Bool
  /// @pivotTables (xsd:boolean) — optional, default true.
  pivot_tables : Bool
  /// @selectUnlockedCells (xsd:boolean) — optional, default false.
  select_unlocked_cells : Bool
  /// @password (ST_UnsignedShortHex) — legacy 16-bit verifier hash,
  /// deprecated in favour of the algorithm/hash/salt/spin attributes
  /// above; `None` when absent.
  legacy_password : String?
} derive(Eq, Debug)

///|
pub fn CT_SheetProtection::new(element : @xml.Element) -> CT_SheetProtection {
  let legacy_password = attr(element, "password")
  let algorithm_name = attr(element, "algorithmName")
  let hash_value = attr(element, "hashValue")
  let salt_value = attr(element, "saltValue")
  let spin_count = attr_uint_opt(element, "spinCount")
  let sheet = attr_bool(element, "sheet", false)
  let objects = attr_bool(element, "objects", false)
  let scenarios = attr_bool(element, "scenarios", false)
  let format_cells = attr_bool(element, "formatCells", true)
  let format_columns = attr_bool(element, "formatColumns", true)
  let format_rows = attr_bool(element, "formatRows", true)
  let insert_columns = attr_bool(element, "insertColumns", true)
  let insert_rows = attr_bool(element, "insertRows", true)
  let insert_hyperlinks = attr_bool(element, "insertHyperlinks", true)
  let delete_columns = attr_bool(element, "deleteColumns", true)
  let delete_rows = attr_bool(element, "deleteRows", true)
  let select_locked_cells = attr_bool(element, "selectLockedCells", false)
  let sort = attr_bool(element, "sort", true)
  let auto_filter = attr_bool(element, "autoFilter", true)
  let pivot_tables = attr_bool(element, "pivotTables", true)
  let select_unlocked_cells = attr_bool(element, "selectUnlockedCells", false)
  {
    element,
    algorithm_name,
    hash_value,
    salt_value,
    spin_count,
    sheet,
    objects,
    scenarios,
    format_cells,
    format_columns,
    format_rows,
    insert_columns,
    insert_rows,
    insert_hyperlinks,
    delete_columns,
    delete_rows,
    select_locked_cells,
    sort,
    auto_filter,
    pivot_tables,
    select_unlocked_cells,
    legacy_password,
  }
}

///|
/// XSD complex type CT_ChartsheetProtection — Part 1 §18.3.1.84
/// (`<sheetProtection>` Chart Sheet Protection). Attribute-only complex type:
/// optional cryptographic `@algorithmName` (s:ST_Xstring), `@hashValue`
/// (xsd:base64Binary), `@saltValue` (xsd:base64Binary), `@spinCount`
/// (xsd:unsignedInt); plus `@content` (xsd:boolean, default false) and
/// `@objects` (xsd:boolean, default false) lock toggles.
pub(all) struct CT_ChartsheetProtection {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @algorithmName (s:ST_Xstring) — optional.
  algorithm_name : String?
  /// @hashValue (xsd:base64Binary) — optional password hash.
  hash_value : String?
  /// @saltValue (xsd:base64Binary) — optional salt.
  salt_value : String?
  /// @spinCount (xsd:unsignedInt) — optional iteration count.
  spin_count : Int?
  /// @content (xsd:boolean) — optional, default false.
  content : Bool
  /// @objects (xsd:boolean) — optional, default false.
  objects : Bool
  /// @password (ST_UnsignedShortHex) — legacy 16-bit verifier hash,
  /// deprecated; `None` when absent.
  legacy_password : String?
} derive(Eq, Debug)

///|
pub fn CT_ChartsheetProtection::new(
  element : @xml.Element,
) -> CT_ChartsheetProtection {
  let algorithm_name = attr(element, "algorithmName")
  let hash_value = attr(element, "hashValue")
  let salt_value = attr(element, "saltValue")
  let spin_count = attr_uint_opt(element, "spinCount")
  let content = attr_bool(element, "content", false)
  let objects = attr_bool(element, "objects", false)
  let legacy_password = attr(element, "password")
  {
    element,
    algorithm_name,
    hash_value,
    salt_value,
    spin_count,
    content,
    objects,
    legacy_password,
  }
}

///|
/// XSD complex type CT_Stylesheet — Part 1 §18.8.39 (`<styleSheet>`).
/// Root stylesheet container. Sequence children, all optional:
/// `<numFmts>`, `<fonts>`, `<fills>`, `<borders>`, `<cellStyleXfs>`,
/// `<cellXfs>`, `<cellStyles>`, `<dxfs>`, `<tableStyles>`, `<colors>`,
/// `<extLst>`.
pub(all) struct CT_Stylesheet {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <numFmts> (CT_NumFmts) — optional number-format table.
  num_fmts : CT_NumFmts?
  /// <fonts> (CT_Fonts) — optional font table.
  fonts : CT_Fonts?
  /// <fills> (CT_Fills) — optional fill table.
  fills : CT_Fills?
  /// <borders> (CT_Borders) — optional border table.
  borders : CT_Borders?
  /// <cellStyleXfs> (CT_CellStyleXfs) — optional named-style xf table.
  cell_style_xfs : CT_CellStyleXfs?
  /// <cellXfs> (CT_CellXfs) — optional cell-format xf table.
  cell_xfs : CT_CellXfs?
  /// <cellStyles> (CT_CellStyles) — optional named-style table.
  cell_styles : CT_CellStyles?
  /// <dxfs> (CT_Dxfs) — optional differential-format table.
  dxfs : CT_Dxfs?
  /// <tableStyles> (CT_TableStyles) — optional table-style collection.
  table_styles : CT_TableStyles?
  /// <colors> (CT_Colors) — optional workbook color overrides.
  colors : CT_Colors?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Stylesheet::new(element : @xml.Element) -> CT_Stylesheet {
  let mut num_fmts : CT_NumFmts? = None
  let mut fonts : CT_Fonts? = None
  let mut fills : CT_Fills? = None
  let mut borders : CT_Borders? = None
  let mut cell_style_xfs : CT_CellStyleXfs? = None
  let mut cell_xfs : CT_CellXfs? = None
  let mut cell_styles : CT_CellStyles? = None
  let mut dxfs : CT_Dxfs? = None
  let mut table_styles : CT_TableStyles? = None
  let mut colors : CT_Colors? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "numFmts" => num_fmts = Some(CT_NumFmts::new(child_element))
        "fonts" => fonts = Some(CT_Fonts::new(child_element))
        "fills" => fills = Some(CT_Fills::new(child_element))
        "borders" => borders = Some(CT_Borders::new(child_element))
        "cellStyleXfs" =>
          cell_style_xfs = Some(CT_CellStyleXfs::new(child_element))
        "cellXfs" => cell_xfs = Some(CT_CellXfs::new(child_element))
        "cellStyles" => cell_styles = Some(CT_CellStyles::new(child_element))
        "dxfs" => dxfs = Some(CT_Dxfs::new(child_element))
        "tableStyles" => table_styles = Some(CT_TableStyles::new(child_element))
        "colors" => colors = Some(CT_Colors::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    num_fmts,
    fonts,
    fills,
    borders,
    cell_style_xfs,
    cell_xfs,
    cell_styles,
    dxfs,
    table_styles,
    colors,
    ext_lst,
  }
}

///|
/// XSD complex type CT_CellAlignment — Part 1 §18.8.1 (`<alignment>`).
/// Attribute-only complex type that controls cell-content placement. All
/// attributes optional per the XSD; `@vertical` carries default `bottom`.
pub(all) struct CT_CellAlignment {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @horizontal (ST_HorizontalAlignment) — optional horizontal placement.
  horizontal : String?
  /// @vertical (ST_VerticalAlignment) — optional, default "bottom".
  vertical : String
  /// @textRotation (ST_TextRotation, xsd:nonNegativeInteger ≤180 or 255) — optional.
  text_rotation : Int?
  /// @wrapText (xsd:boolean) — optional.
  wrap_text : Bool?
  /// @indent (xsd:unsignedInt) — optional.
  indent : Int?
  /// @relativeIndent (xsd:int) — optional.
  relative_indent : Int?
  /// @justifyLastLine (xsd:boolean) — optional.
  justify_last_line : Bool?
  /// @shrinkToFit (xsd:boolean) — optional.
  shrink_to_fit : Bool?
  /// @readingOrder (xsd:unsignedInt) — optional.
  reading_order : Int?
} derive(Eq, Debug)

///|
pub fn CT_CellAlignment::new(element : @xml.Element) -> CT_CellAlignment {
  let horizontal = attr(element, "horizontal")
  let vertical = match attr(element, "vertical") {
    Some(value) => value
    None => "bottom"
  }
  let text_rotation = attr_uint_opt(element, "textRotation")
  let wrap_text = attr_bool_opt(element, "wrapText")
  let indent = attr_uint_opt(element, "indent")
  let relative_indent = attr_int_opt(element, "relativeIndent")
  let justify_last_line = attr_bool_opt(element, "justifyLastLine")
  let shrink_to_fit = attr_bool_opt(element, "shrinkToFit")
  let reading_order = attr_uint_opt(element, "readingOrder")
  {
    element,
    horizontal,
    vertical,
    text_rotation,
    wrap_text,
    indent,
    relative_indent,
    justify_last_line,
    shrink_to_fit,
    reading_order,
  }
}

///|
/// XSD complex type CT_Borders — Part 1 §18.8.5 (`<borders>`). Container for
/// `<border>` (CT_Border) entries (minOccurs=0, maxOccurs=unbounded). Optional
/// `@count` (xsd:unsignedInt) records the declared collection size for fast
/// consumers but may differ from the actual entry count per spec.
pub(all) struct CT_Borders {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional declared entry count.
  count : Int?
  /// <border>* (CT_Border) — zero or more border records in document order.
  border : Array[CT_Border]
} derive(Eq, Debug)

///|
pub fn CT_Borders::new(element : @xml.Element) -> CT_Borders {
  let count = attr_uint_opt(element, "count")
  let border : Array[CT_Border] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "border" {
        border.push(CT_Border::new(child_element))
      }
    }
  }
  { element, count, border }
}

///|
/// XSD complex type CT_Border — Part 1 §18.8.4 (`<border>`). Cell border
/// record. Sequence of optional edges `<start>`, `<end>`, `<top>`,
/// `<bottom>`, `<diagonal>`, `<vertical>`, `<horizontal>` (all CT_BorderPr).
/// Optional attributes: `@diagonalUp` (xsd:boolean), `@diagonalDown`
/// (xsd:boolean), `@outline` (xsd:boolean, default true).
pub(all) struct CT_Border {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <start> (CT_BorderPr) — optional leading edge.
  start : CT_BorderPr?
  /// <end> (CT_BorderPr) — optional trailing edge.
  end : CT_BorderPr?
  /// <top> (CT_BorderPr) — optional top edge.
  top : CT_BorderPr?
  /// <bottom> (CT_BorderPr) — optional bottom edge.
  bottom : CT_BorderPr?
  /// <diagonal> (CT_BorderPr) — optional diagonal stroke.
  diagonal : CT_BorderPr?
  /// <vertical> (CT_BorderPr) — optional inner vertical stroke.
  vertical : CT_BorderPr?
  /// <horizontal> (CT_BorderPr) — optional inner horizontal stroke.
  horizontal : CT_BorderPr?
  /// @diagonalUp (xsd:boolean) — optional.
  diagonal_up : Bool?
  /// @diagonalDown (xsd:boolean) — optional.
  diagonal_down : Bool?
  /// @outline (xsd:boolean) — optional, default true.
  outline : Bool
} derive(Eq, Debug)

///|
pub fn CT_Border::new(element : @xml.Element) -> CT_Border {
  let mut start : CT_BorderPr? = None
  let mut end : CT_BorderPr? = None
  let mut top : CT_BorderPr? = None
  let mut bottom : CT_BorderPr? = None
  let mut diagonal : CT_BorderPr? = None
  let mut vertical : CT_BorderPr? = None
  let mut horizontal : CT_BorderPr? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "start" => start = Some(CT_BorderPr::new(child_element))
        "end" => end = Some(CT_BorderPr::new(child_element))
        "top" => top = Some(CT_BorderPr::new(child_element))
        "bottom" => bottom = Some(CT_BorderPr::new(child_element))
        "diagonal" => diagonal = Some(CT_BorderPr::new(child_element))
        "vertical" => vertical = Some(CT_BorderPr::new(child_element))
        "horizontal" => horizontal = Some(CT_BorderPr::new(child_element))
        _ => ()
      }
    }
  }
  let diagonal_up = attr_bool_opt(element, "diagonalUp")
  let diagonal_down = attr_bool_opt(element, "diagonalDown")
  let outline = attr_bool(element, "outline", true)
  {
    element,
    start,
    end,
    top,
    bottom,
    diagonal,
    vertical,
    horizontal,
    diagonal_up,
    diagonal_down,
    outline,
  }
}

///|
/// XSD complex type CT_BorderPr — Part 1 §18.8.4 (border edge sub-element
/// definition shared by `<start>`/`<end>`/`<top>`/`<bottom>`/`<diagonal>`/
/// `<vertical>`/`<horizontal>` in §18.8.4). Optional `<color>` (CT_Color)
/// child and optional `@style` (ST_BorderStyle, default "none").
pub(all) struct CT_BorderPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <color> (CT_Color, §18.8.3) — optional stroke colour. Typed
  /// projection of the auto/indexed/rgb/theme/tint attribute set.
  color : CT_Color?
  /// @style (ST_BorderStyle) — optional, default "none".
  style : String
} derive(Eq, Debug)

///|
pub fn CT_BorderPr::new(element : @xml.Element) -> CT_BorderPr {
  let mut color : CT_Color? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "color" {
        color = Some(CT_Color::new(child_element))
      }
    }
  }
  let style = match attr(element, "style") {
    Some(value) => value
    None => "none"
  }
  { element, color, style }
}

///|
/// XSD complex type CT_CellProtection — Part 1 §18.8.33 (`<protection>`).
/// Attribute-only complex type expressing cell-level lock/hide overrides
/// applied to a cell format. Both attributes optional with no XSD default.
pub(all) struct CT_CellProtection {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @locked (xsd:boolean) — optional override of cell-lock state.
  locked : Bool?
  /// @hidden (xsd:boolean) — optional override of formula visibility.
  hidden : Bool?
} derive(Eq, Debug)

///|
pub fn CT_CellProtection::new(element : @xml.Element) -> CT_CellProtection {
  let locked = attr_bool_opt(element, "locked")
  let hidden = attr_bool_opt(element, "hidden")
  { element, locked, hidden }
}

///|
/// Schema sml.xsd complex type `CT_Fonts`. Attributes: `count`. Child
/// elements: `font`. Child types: `CT_Font`.
///
/// XSD complex type CT_Fonts — Part 1 §18.8.23 (`<fonts>`). Container
/// for `<font>` (CT_Font) entries (minOccurs=0, maxOccurs=unbounded).
/// Optional `@count` (xsd:unsignedInt) reports the declared total.
pub(all) struct CT_Fonts {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional declared font count.
  count : Int?
  /// <font>* (CT_Font) — zero or more font entries in document order.
  font : Array[CT_Font]
} derive(Eq, Debug)

///|
pub fn CT_Fonts::new(element : @xml.Element) -> CT_Fonts {
  let count = attr_uint_opt(element, "count")
  let font : Array[CT_Font] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "font" {
        font.push(CT_Font::new(child_element))
      }
    }
  }
  { element, count, font }
}

///|
/// Schema sml.xsd complex type `CT_Fills`. Attributes: `count`. Child
/// elements: `fill`. Child types: `CT_Fill`.
///
/// XSD complex type CT_Fills — Part 1 §18.8.21 (`<fills>`). Container
/// for `<fill>` (CT_Fill) entries (minOccurs=0, maxOccurs=unbounded).
/// Optional `@count` (xsd:unsignedInt) declares the total.
pub(all) struct CT_Fills {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional declared fill count.
  count : Int?
  /// <fill>* (CT_Fill) — zero or more fill entries in document order.
  fill : Array[CT_Fill]
} derive(Eq, Debug)

///|
pub fn CT_Fills::new(element : @xml.Element) -> CT_Fills {
  let count = attr_uint_opt(element, "count")
  let fill : Array[CT_Fill] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "fill" {
        fill.push(CT_Fill::new(child_element))
      }
    }
  }
  { element, count, fill }
}

///|
/// XSD complex type CT_Fill — Part 1 §18.8.20 (`<fill>`). Single-choice
/// container: either a `<patternFill>` (CT_PatternFill) or a `<gradientFill>`
/// (CT_GradientFill). The XSD models both arms as minOccurs=0 within the
/// choice, so either may be absent on round-trip; consumers must read the
/// arm that is present per choice semantics.
/// Schema sml.xsd complex type `CT_Fill`. Child elements: `patternFill`,
/// `gradientFill`. Child types: `CT_PatternFill`, `CT_GradientFill`.
pub(all) struct CT_Fill {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <patternFill> (CT_PatternFill) — optional choice arm.
  pattern_fill : CT_PatternFill?
  /// <gradientFill> (CT_GradientFill) — optional choice arm.
  gradient_fill : CT_GradientFill?
} derive(Eq, Debug)

///|
pub fn CT_Fill::new(element : @xml.Element) -> CT_Fill {
  let mut pattern_fill : CT_PatternFill? = None
  let mut gradient_fill : CT_GradientFill? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "patternFill" => pattern_fill = Some(CT_PatternFill::new(child_element))
        "gradientFill" =>
          gradient_fill = Some(CT_GradientFill::new(child_element))
        _ => ()
      }
    }
  }
  { element, pattern_fill, gradient_fill }
}

///|
/// XSD complex type CT_PatternFill — Part 1 §18.8.32 (`<patternFill>`).
/// Pattern-style fill. Sequence of optional `<fgColor>` (CT_Color) and
/// `<bgColor>` (CT_Color). Optional `@patternType` (ST_PatternType) names
/// the pattern (e.g. "solid", "gray125"). The colour children are preserved
/// as raw XML elements because the domain's typed CT_Color is an ARGB tuple
/// (per §18.3.1.15) constructed via CT_Color::new(a, r, g, b) rather than
/// from XML; these fields preserve the `<fgColor>`/`<bgColor>` references
/// until colour resolution converts them.
pub(all) struct CT_PatternFill {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <fgColor> (CT_Color element) — optional foreground colour, preserved as
  /// raw XML for downstream colour resolution.
  fg_color : @xml.Element?
  /// <bgColor> (CT_Color element) — optional background colour, preserved as
  /// raw XML for downstream colour resolution.
  bg_color : @xml.Element?
  /// @patternType (ST_PatternType) — optional pattern name.
  pattern_type : String?
} derive(Eq, Debug)

///|
pub fn CT_PatternFill::new(element : @xml.Element) -> CT_PatternFill {
  let mut fg_color : @xml.Element? = None
  let mut bg_color : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "fgColor" => fg_color = Some(child_element)
        "bgColor" => bg_color = Some(child_element)
        _ => ()
      }
    }
  }
  let pattern_type = attr(element, "patternType")
  { element, fg_color, bg_color, pattern_type }
}

///|
/// XSD complex type CT_GradientFill — Part 1 §18.8.24 (`<gradientFill>`).
/// Gradient fill. Sequence of `<stop>` (CT_GradientStop, zero or more) plus
/// optional attributes: `@type` (ST_GradientType, default "linear"),
/// `@degree` (xsd:double, default 0), and four positional doubles `@left`,
/// `@right`, `@top`, `@bottom` (default 0).
pub(all) struct CT_GradientFill {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <stop>* (CT_GradientStop) — zero or more gradient stops.
  stop : Array[CT_GradientStop]
  /// @type (ST_GradientType) — optional, default "linear".
  type_ : String
  /// @degree (xsd:double) — optional, default 0.
  degree : Double
  /// @left (xsd:double) — optional, default 0.
  left : Double
  /// @right (xsd:double) — optional, default 0.
  right : Double
  /// @top (xsd:double) — optional, default 0.
  top : Double
  /// @bottom (xsd:double) — optional, default 0.
  bottom : Double
} derive(Eq, Debug)

///|
pub fn CT_GradientFill::new(element : @xml.Element) -> CT_GradientFill {
  let stop : Array[CT_GradientStop] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "stop" {
        stop.push(CT_GradientStop::new(child_element))
      }
    }
  }
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => "linear"
  }
  let degree = attr_double(element, "degree", 0.0)
  let left = attr_double(element, "left", 0.0)
  let right = attr_double(element, "right", 0.0)
  let top = attr_double(element, "top", 0.0)
  let bottom = attr_double(element, "bottom", 0.0)
  { element, stop, type_, degree, left, right, top, bottom }
}

///|
/// Schema sml.xsd complex type `CT_NumFmts`. Attributes: `count`.
/// Child elements: `numFmt`. Child types: `CT_NumFmt`.
///
/// XSD complex type CT_NumFmts — Part 1 §18.8.31 numFmts (NumFmts).
/// Schema sml.xsd complex type `CT_NumFmts` is a `<xsd:complexType
/// name="CT_NumFmts">` declaration with attribute `count`
/// (xsd:unsignedInt) and `<xsd:element name="numFmt" type="CT_NumFmt"
/// minOccurs="0" maxOccurs="unbounded"/>`. CT_NumFmts and
/// CT_NumFmts::new bind this numFmts container collection.
pub(all) struct CT_NumFmts {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <numFmt>* (CT_NumFmt) — zero or more number-format entries.
  num_fmt : Array[CT_NumFmt]
  /// @count (xsd:unsignedInt) — optional declared entry count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_NumFmts::new(element : @xml.Element) -> CT_NumFmts {
  let num_fmt : Array[CT_NumFmt] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "numFmt" {
        num_fmt.push(CT_NumFmt::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, num_fmt, count }
}

///|
/// XSD complex type CT_NumFmt — Part 1 §18.8.30. Single number-format
/// definition. Required `@numFmtId` (ST_NumFmtId / xsd:unsignedInt) and
/// `@formatCode` (s:ST_Xstring) format code string.
pub(all) struct CT_NumFmt {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @numFmtId (ST_NumFmtId / xsd:unsignedInt) — required.
  num_fmt_id : Int
  /// @formatCode (s:ST_Xstring) — required format code.
  format_code : String
} derive(Eq, Debug)

///|
/// §18.8.30 CT_NumFmt — `@numFmtId` and `@formatCode` are both
/// `use="required"` per the schema.  Missing attributes default
/// to `0` / `""` here to keep the parser tolerant of malformed
/// stylesheet parts (Excel's strict validator accepts these as
/// degenerate but consumers should treat them as schema
/// violations).  A stricter SchemaViolation-raising
/// constructor is tracked as Round 13 #303 — promoting this
/// helper requires raise-propagation through every styles.xml
/// caller (CT_Stylesheet::new ← read_style_sheet ← context
/// open), which is out of scope here.
pub fn CT_NumFmt::new(element : @xml.Element) -> CT_NumFmt {
  let num_fmt_id = attr_uint(element, "numFmtId", 0)
  let format_code = match attr(element, "formatCode") {
    Some(value) => value
    None => ""
  }
  { element, num_fmt_id, format_code }
}

///|
/// XSD complex type CT_CellStyleXfs — Part 1 §18.8.9. Cell style format
/// table. Sequence: `<xf>+` (CT_Xf, one or more). Optional `@count`
/// (xsd:unsignedInt) declared entry count.
pub(all) struct CT_CellStyleXfs {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <xf>+ (CT_Xf) — one or more cell style format records.
  xf : Array[CT_Xf]
  /// @count (xsd:unsignedInt) — optional declared entry count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_CellStyleXfs::new(element : @xml.Element) -> CT_CellStyleXfs {
  let xf : Array[CT_Xf] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "xf" {
        xf.push(CT_Xf::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, xf, count }
}

///|
/// XSD complex type CT_CellXfs — Part 1 §18.8.10. Cell format table.
/// Schema sml.xsd complex type `CT_CellXfs`. Attributes: `count`. Child
/// elements: `xf`. Child types: `CT_Xf`. Sequence: `<xf>+` (CT_Xf, one
/// or more). Optional `@count` (xsd:unsignedInt) declared entry count.
pub(all) struct CT_CellXfs {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <xf>+ (CT_Xf) — one or more cell format records.
  xf : Array[CT_Xf]
  /// @count (xsd:unsignedInt) — optional declared entry count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_CellXfs::new(element : @xml.Element) -> CT_CellXfs {
  let xf : Array[CT_Xf] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "xf" {
        xf.push(CT_Xf::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, xf, count }
}

///|
/// XSD complex type CT_Xf — Part 1 §18.8.45. Cell format record. Sequence
/// children: optional `<alignment>` (CT_CellAlignment), optional
/// `<protection>` (CT_CellProtection), optional `<extLst>`
/// (CT_ExtensionList). Optional attributes: `@numFmtId` (ST_NumFmtId),
/// `@fontId` (ST_FontId), `@fillId` (ST_FillId), `@borderId` (ST_BorderId),
/// `@xfId` (ST_CellStyleXfId), `@quotePrefix` (xsd:boolean, default false),
/// `@pivotButton` (xsd:boolean, default false), `@applyNumberFormat`,
/// `@applyFont`, `@applyFill`, `@applyBorder`, `@applyAlignment`,
/// `@applyProtection` (xsd:boolean, optional with no default).
pub(all) struct CT_Xf {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <alignment> (CT_CellAlignment) — optional.
  alignment : CT_CellAlignment?
  /// <protection> (CT_CellProtection) — optional.
  protection : CT_CellProtection?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
  /// @numFmtId (ST_NumFmtId) — optional number-format table index.
  num_fmt_id : Int?
  /// @fontId (ST_FontId) — optional font-table index.
  font_id : Int?
  /// @fillId (ST_FillId) — optional fill-table index.
  fill_id : Int?
  /// @borderId (ST_BorderId) — optional border-table index.
  border_id : Int?
  /// @xfId (ST_CellStyleXfId) — optional parent cell-style index.
  xf_id : Int?
  /// @quotePrefix (xsd:boolean) — optional, default false.
  quote_prefix : Bool
  /// @pivotButton (xsd:boolean) — optional, default false.
  pivot_button : Bool
  /// @applyNumberFormat (xsd:boolean) — optional (no default).
  apply_number_format : Bool?
  /// @applyFont (xsd:boolean) — optional (no default).
  apply_font : Bool?
  /// @applyFill (xsd:boolean) — optional (no default).
  apply_fill : Bool?
  /// @applyBorder (xsd:boolean) — optional (no default).
  apply_border : Bool?
  /// @applyAlignment (xsd:boolean) — optional (no default).
  apply_alignment : Bool?
  /// @applyProtection (xsd:boolean) — optional (no default).
  apply_protection : Bool?
} derive(Eq, Debug)

///|
pub fn CT_Xf::new(element : @xml.Element) -> CT_Xf {
  let mut alignment : CT_CellAlignment? = None
  let mut protection : CT_CellProtection? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "alignment" => alignment = Some(CT_CellAlignment::new(child_element))
        "protection" => protection = Some(CT_CellProtection::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  let num_fmt_id = attr_uint_opt(element, "numFmtId")
  let font_id = attr_uint_opt(element, "fontId")
  let fill_id = attr_uint_opt(element, "fillId")
  let border_id = attr_uint_opt(element, "borderId")
  let xf_id = attr_uint_opt(element, "xfId")
  let quote_prefix = attr_bool(element, "quotePrefix", false)
  let pivot_button = attr_bool(element, "pivotButton", false)
  let apply_number_format = attr_bool_opt(element, "applyNumberFormat")
  let apply_font = attr_bool_opt(element, "applyFont")
  let apply_fill = attr_bool_opt(element, "applyFill")
  let apply_border = attr_bool_opt(element, "applyBorder")
  let apply_alignment = attr_bool_opt(element, "applyAlignment")
  let apply_protection = attr_bool_opt(element, "applyProtection")
  {
    element,
    alignment,
    protection,
    ext_lst,
    num_fmt_id,
    font_id,
    fill_id,
    border_id,
    xf_id,
    quote_prefix,
    pivot_button,
    apply_number_format,
    apply_font,
    apply_fill,
    apply_border,
    apply_alignment,
    apply_protection,
  }
}

///|
/// XSD complex type CT_CellStyles — Part 1 §18.8.8. Cell-style table.
/// Sequence: `<cellStyle>+` (CT_CellStyle, one or more). Optional
/// `@count` (xsd:unsignedInt) declared entry count.
pub(all) struct CT_CellStyles {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cellStyle>+ (CT_CellStyle) — one or more cell-style entries.
  cell_style : Array[CT_CellStyle]
  /// @count (xsd:unsignedInt) — optional declared entry count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_CellStyles::new(element : @xml.Element) -> CT_CellStyles {
  let cell_style : Array[CT_CellStyle] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "cellStyle" {
        cell_style.push(CT_CellStyle::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, cell_style, count }
}

///|
/// XSD complex type CT_CellStyle — Part 1 §18.8.8. Single cell-style
/// entry. Sequence: optional `<extLst>` (CT_ExtensionList). Required
/// `@xfId` (ST_CellStyleXfId) parent cell-style format index. Optional
/// `@name` (s:ST_Xstring), `@builtinId` (xsd:unsignedInt), `@iLevel`
/// (xsd:unsignedInt), `@hidden` (xsd:boolean), `@customBuiltin`
/// (xsd:boolean).
pub(all) struct CT_CellStyle {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
  /// @name (s:ST_Xstring) — optional style display name.
  name : String?
  /// @xfId (ST_CellStyleXfId) — required parent cell-style format index.
  xf_id : Int
  /// @builtinId (xsd:unsignedInt) — optional built-in style identifier.
  builtin_id : Int?
  /// @iLevel (xsd:unsignedInt) — optional outline level.
  i_level : Int?
  /// @hidden (xsd:boolean) — optional hidden flag (no default).
  hidden : Bool?
  /// @customBuiltin (xsd:boolean) — optional custom-builtin flag.
  custom_builtin : Bool?
} derive(Eq, Debug)

///|
pub fn CT_CellStyle::new(element : @xml.Element) -> CT_CellStyle {
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "extLst" {
        ext_lst = Some(CT_ExtensionList::new(child_element))
      }
    }
  }
  let name = attr(element, "name")
  let xf_id = attr_uint(element, "xfId", 0)
  let builtin_id = attr_uint_opt(element, "builtinId")
  let i_level = attr_uint_opt(element, "iLevel")
  let hidden = attr_bool_opt(element, "hidden")
  let custom_builtin = attr_bool_opt(element, "customBuiltin")
  { element, ext_lst, name, xf_id, builtin_id, i_level, hidden, custom_builtin }
}

///|
/// XSD complex type CT_Dxfs — Part 1 §18.8.15. Differential-format table.
/// Schema sml.xsd complex type `CT_Dxfs`. Attributes: `count`. Child
/// elements: `dxf`. Child types: `CT_Dxf`. Sequence: `<dxf>*` (CT_Dxf,
/// zero or more). Optional `@count` (xsd:unsignedInt) declared entry
/// count.
pub(all) struct CT_Dxfs {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <dxf>* (CT_Dxf) — zero or more differential format records.
  dxf : Array[CT_Dxf]
  /// @count (xsd:unsignedInt) — optional declared entry count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_Dxfs::new(element : @xml.Element) -> CT_Dxfs {
  let dxf : Array[CT_Dxf] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "dxf" {
        dxf.push(CT_Dxf::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  { element, dxf, count }
}

///|
/// XSD complex type CT_Dxf — Part 1 §18.8.14. Single differential format
/// record. Sequence children, each optional: `<font>` (CT_Font),
/// `<numFmt>` (CT_NumFmt), `<fill>` (CT_Fill), `<alignment>`
/// (CT_CellAlignment), `<border>` (CT_Border), `<protection>`
/// (CT_CellProtection), `<extLst>` (CT_ExtensionList). No attributes.
pub(all) struct CT_Dxf {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <font> (CT_Font) — optional.
  font : CT_Font?
  /// <numFmt> (CT_NumFmt) — optional.
  num_fmt : CT_NumFmt?
  /// <fill> (CT_Fill) — optional.
  fill : CT_Fill?
  /// <alignment> (CT_CellAlignment) — optional.
  alignment : CT_CellAlignment?
  /// <border> (CT_Border) — optional.
  border : CT_Border?
  /// <protection> (CT_CellProtection) — optional.
  protection : CT_CellProtection?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Dxf::new(element : @xml.Element) -> CT_Dxf {
  let mut font : CT_Font? = None
  let mut num_fmt : CT_NumFmt? = None
  let mut fill : CT_Fill? = None
  let mut alignment : CT_CellAlignment? = None
  let mut border : CT_Border? = None
  let mut protection : CT_CellProtection? = None
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "font" => font = Some(CT_Font::new(child_element))
        "numFmt" => num_fmt = Some(CT_NumFmt::new(child_element))
        "fill" => fill = Some(CT_Fill::new(child_element))
        "alignment" => alignment = Some(CT_CellAlignment::new(child_element))
        "border" => border = Some(CT_Border::new(child_element))
        "protection" => protection = Some(CT_CellProtection::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, font, num_fmt, fill, alignment, border, protection, ext_lst }
}

///|
/// XSD complex type CT_Colors — Part 1 §18.8.11. Custom color section.
/// Sequence: optional `<indexedColors>` (CT_IndexedColors) and optional
/// `<mruColors>` (CT_MRUColors). No attributes.
pub(all) struct CT_Colors {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <indexedColors> (CT_IndexedColors) — optional.
  indexed_colors : CT_IndexedColors?
  /// <mruColors> (CT_MRUColors) — optional.
  mru_colors : CT_MRUColors?
} derive(Eq, Debug)

///|
pub fn CT_Colors::new(element : @xml.Element) -> CT_Colors {
  let mut indexed_colors : CT_IndexedColors? = None
  let mut mru_colors : CT_MRUColors? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "indexedColors" =>
          indexed_colors = Some(CT_IndexedColors::new(child_element))
        "mruColors" => mru_colors = Some(CT_MRUColors::new(child_element))
        _ => ()
      }
    }
  }
  { element, indexed_colors, mru_colors }
}

///|
/// XSD complex type CT_IndexedColors — Part 1 §18.8.17. Indexed color
/// palette. Sequence: `<rgbColor>+` (CT_RgbColor, one or more entries).
/// No attributes.
pub(all) struct CT_IndexedColors {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <rgbColor>+ (CT_RgbColor) — one or more palette entries.
  rgb_color : Array[CT_RgbColor]
} derive(Eq, Debug)

///|
pub fn CT_IndexedColors::new(element : @xml.Element) -> CT_IndexedColors {
  let rgb_color : Array[CT_RgbColor] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "rgbColor" {
        rgb_color.push(CT_RgbColor::new(child_element))
      }
    }
  }
  { element, rgb_color }
}

///|
/// XSD complex type CT_MRUColors — Part 1 §18.8.21. Most-recently-used
/// color list. Sequence: `<color>+` (CT_Color §18.8.3 stylesheet
/// colour, one or more entries) typed via the spec-shaped projection.
pub(all) struct CT_MRUColors {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <color>+ (CT_Color §18.8.3) — one or more recent-color entries.
  color : Array[CT_Color]
} derive(Eq, Debug)

///|
pub fn CT_MRUColors::new(element : @xml.Element) -> CT_MRUColors {
  let color : Array[CT_Color] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "color" {
        color.push(CT_Color::new(child_element))
      }
    }
  }
  { element, color }
}

///|
/// XSD complex type CT_RgbColor — Part 1 §18.8.34. Single palette entry.
/// Optional `@rgb` (ST_UnsignedIntHex / xsd:hexBinary length=4) ARGB
/// color value packed as 8 hex digits.
pub(all) struct CT_RgbColor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @rgb (ST_UnsignedIntHex) — optional packed ARGB hex value.
  rgb : Int?
} derive(Eq, Debug)

///|
pub fn CT_RgbColor::new(element : @xml.Element) -> CT_RgbColor {
  let rgb = attr_hex_uint_opt(element, "rgb")
  { element, rgb }
}

///|
/// XSD complex type CT_TableStyles — Part 1 §18.8.42. Table style table.
/// Sequence: `<tableStyle>*` (CT_TableStyle, zero or more). Optional
/// `@count` (xsd:unsignedInt) declared entry count;
/// `@defaultTableStyle` (xsd:string) and `@defaultPivotStyle`
/// (xsd:string) name the default table / pivot style.
pub(all) struct CT_TableStyles {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <tableStyle>* (CT_TableStyle) — zero or more table-style entries.
  table_style : Array[CT_TableStyle]
  /// @count (xsd:unsignedInt) — optional declared entry count.
  count : Int?
  /// @defaultTableStyle (xsd:string) — optional default table style name.
  default_table_style : String?
  /// @defaultPivotStyle (xsd:string) — optional default pivot style name.
  default_pivot_style : String?
} derive(Eq, Debug)

///|
pub fn CT_TableStyles::new(element : @xml.Element) -> CT_TableStyles {
  let table_style : Array[CT_TableStyle] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "tableStyle" {
        table_style.push(CT_TableStyle::new(child_element))
      }
    }
  }
  let count = attr_uint_opt(element, "count")
  let default_table_style = attr(element, "defaultTableStyle")
  let default_pivot_style = attr(element, "defaultPivotStyle")
  { element, table_style, count, default_table_style, default_pivot_style }
}

///|
/// XSD complex type CT_TableStyle — Part 1 §18.8.40. Single table-style
/// definition. Sequence: `<tableStyleElement>*` (CT_TableStyleElement,
/// zero or more). Required `@name` (xsd:string). Optional `@pivot`
/// (xsd:boolean, default true), `@table` (xsd:boolean, default true),
/// `@count` (xsd:unsignedInt) declared element count.
pub(all) struct CT_TableStyle {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <tableStyleElement>* (CT_TableStyleElement) — zero or more elements.
  table_style_element : Array[CT_TableStyleElement]
  /// @name (xsd:string) — required style name.
  name : String
  /// @pivot (xsd:boolean) — optional, default true.
  pivot : Bool
  /// @table (xsd:boolean) — optional, default true.
  table : Bool
  /// @count (xsd:unsignedInt) — optional declared entry count.
  count : Int?
} derive(Eq, Debug)

///|
pub fn CT_TableStyle::new(element : @xml.Element) -> CT_TableStyle {
  let table_style_element : Array[CT_TableStyleElement] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "tableStyleElement" {
        table_style_element.push(CT_TableStyleElement::new(child_element))
      }
    }
  }
  let name = match attr(element, "name") {
    Some(value) => value
    None => ""
  }
  let pivot = attr_bool(element, "pivot", true)
  let table = attr_bool(element, "table", true)
  let count = attr_uint_opt(element, "count")
  { element, table_style_element, name, pivot, table, count }
}

///|
/// XSD complex type CT_TableStyleElement — Part 1 §18.8.39. Single
/// styled-region descriptor. Required `@type` (ST_TableStyleType
/// enumeration). Optional `@size` (xsd:unsignedInt, default 1) and
/// `@dxfId` (ST_DxfId / xsd:unsignedInt) differential-format reference.
pub(all) struct CT_TableStyleElement {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @type (ST_TableStyleType) — required region kind.
  type_ : String
  /// @size (xsd:unsignedInt) — optional stripe width, default 1.
  size : Int
  /// @dxfId (ST_DxfId) — optional differential-format index.
  dxf_id : Int?
} derive(Eq, Debug)

///|
pub fn CT_TableStyleElement::new(
  element : @xml.Element,
) -> CT_TableStyleElement {
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => ""
  }
  let size = attr_uint(element, "size", 1)
  let dxf_id = attr_uint_opt(element, "dxfId")
  { element, type_, size, dxf_id }
}

///|
/// XSD complex type CT_Color — Part 1 §18.8.3 (`<color>` style colour
/// reference). Five optional attributes that together pick a single
/// colour: `@auto` (xsd:boolean), `@indexed` (xsd:unsignedInt),
/// `@rgb` (ST_UnsignedIntHex), `@theme` (xsd:unsignedInt), `@tint`
/// (xsd:double, default 0.0). Used by `<rPr>` font color, `<border>`
/// stroke colour, `<fill>/<patternFill>/<fgColor>` etc.
pub(all) struct CT_Color {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @auto (xsd:boolean) — optional, default false.
  auto_ : Bool
  /// @indexed (xsd:unsignedInt) — optional palette index.
  indexed : Int?
  /// @rgb (ST_UnsignedIntHex) — optional AARRGGBB hex literal.
  rgb : String?
  /// @theme (xsd:unsignedInt) — optional theme-colour index.
  theme : Int?
  /// @tint (xsd:double) — optional luminance shift, default 0.0.
  tint : Double
} derive(Eq, Debug)

///|
pub fn CT_Color::new(element : @xml.Element) -> CT_Color {
  let auto_ = attr_bool(element, "auto", false)
  let indexed = attr_uint_opt(element, "indexed")
  let rgb = attr(element, "rgb")
  let theme = attr_uint_opt(element, "theme")
  let tint = attr_double(element, "tint", 0.0)
  { element, auto_, indexed, rgb, theme, tint }
}

///|
/// XSD complex type CT_BooleanProperty — Part 1 §18.8.2 (boolean style
/// property). Optional `@val` (xsd:boolean, default true).
pub(all) struct CT_BooleanProperty {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (xsd:boolean) — optional, default true.
  val : Bool
} derive(Eq, Debug)

///|
pub fn CT_BooleanProperty::new(element : @xml.Element) -> CT_BooleanProperty {
  let val = attr_bool(element, "val", true)
  { element, val }
}

///|
/// XSD complex type CT_FontSize — Part 1 §18.8.22 (`<sz>` font size).
/// Required `@val` (xsd:double) point size.
pub(all) struct CT_FontSize {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (xsd:double) — required font point size.
  val : Double
} derive(Eq, Debug)

///|
pub fn CT_FontSize::new(element : @xml.Element) -> CT_FontSize {
  let val = attr_double(element, "val", 0.0)
  { element, val }
}

///|
/// XSD complex type CT_IntProperty — Part 1 §18.8 (integer style
/// property used for `<charset>` and `<family>` children of `<font>`).
/// Required `@val` (xsd:int).
pub(all) struct CT_IntProperty {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (xsd:int) — required integer payload.
  val : Int
} derive(Eq, Debug)

///|
pub fn CT_IntProperty::new(element : @xml.Element) -> CT_IntProperty {
  let val = attr_int(element, "val", 0)
  { element, val }
}

///|
/// XSD complex type CT_FontName — Part 1 §18.8.29 (`<name>` font name).
/// Required `@val` (s:ST_Xstring) typeface family name.
pub(all) struct CT_FontName {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (s:ST_Xstring) — required typeface family name.
  val : String
} derive(Eq, Debug)

///|
pub fn CT_FontName::new(element : @xml.Element) -> CT_FontName {
  let val = match attr(element, "val") {
    Some(value) => value
    None => ""
  }
  { element, val }
}

///|
/// XSD complex type CT_VerticalAlignFontProperty — Part 1 §18.4.13
/// (`<vertAlign>`). Required `@val` (s:ST_VerticalAlignRun) vertical-align
/// token (`baseline`, `superscript`, `subscript`).
pub(all) struct CT_VerticalAlignFontProperty {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (s:ST_VerticalAlignRun) — required vertical-align token.
  val : String
} derive(Eq, Debug)

///|
pub fn CT_VerticalAlignFontProperty::new(
  element : @xml.Element,
) -> CT_VerticalAlignFontProperty {
  let val = match attr(element, "val") {
    Some(value) => value
    None => ""
  }
  { element, val }
}

///|
/// XSD complex type CT_FontScheme — Part 1 §18.8.35 (`<scheme>` font
/// scheme). Required `@val` (ST_FontScheme enumeration: `none`, `major`,
/// `minor`).
pub(all) struct CT_FontScheme {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (ST_FontScheme) — required scheme token.
  val : String
} derive(Eq, Debug)

///|
pub fn CT_FontScheme::new(element : @xml.Element) -> CT_FontScheme {
  let val = match attr(element, "val") {
    Some(value) => value
    None => ""
  }
  { element, val }
}

///|
/// XSD complex type CT_UnderlineProperty — Part 1 §18.4.12 (`<u>`
/// underline). Optional `@val` (ST_UnderlineValues enumeration), default
/// `single`.
pub(all) struct CT_UnderlineProperty {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (ST_UnderlineValues) — optional, default `single`.
  val : String
} derive(Eq, Debug)

///|
pub fn CT_UnderlineProperty::new(
  element : @xml.Element,
) -> CT_UnderlineProperty {
  let val = match attr(element, "val") {
    Some(value) => value
    None => "single"
  }
  { element, val }
}

///|
/// XSD complex type CT_FontFamily — Part 1 §18.8.18 (`<family>` font
/// family). Required `@val` (ST_FontFamily / xsd:integer in 0..14).
pub(all) struct CT_FontFamily {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @val (ST_FontFamily / xsd:integer 0..14) — required family code.
  val : Int
} derive(Eq, Debug)

///|
pub fn CT_FontFamily::new(element : @xml.Element) -> CT_FontFamily {
  let val = attr_int(element, "val", 0)
  { element, val }
}

///|
/// XSD complex type CT_Font — Part 1 §18.8.22. Stylesheet font record.
/// Schema sml.xsd complex type `CT_Font`. Child elements: `name`,
/// `charset`, `family`, `b`, `i`, `strike`, `outline`, `shadow`,
/// `condense`, `extend`, `color`, `sz`, `u`, `vertAlign`, `scheme`.
/// Child types: `CT_FontName`, `CT_IntProperty`, `CT_FontFamily`,
/// `CT_BooleanProperty`, `CT_Color`, `CT_FontSize`,
/// `CT_UnderlineProperty`, `CT_VerticalAlignFontProperty`,
/// `CT_FontScheme`. Unbounded choice of formatting child elements
/// (every element is optional, but the XSD permits multiple of any one
/// kind under `xsd:choice maxOccurs="unbounded"`). Per-name arrays
/// preserve every observed child. Each child element is stored as a
/// typed wrapper of the matching CT type from this package; `<color>`
/// children are preserved as raw `@xml.Element` because the package's
/// CT_Color is the ARGB-only conditional-formatting representation
/// rather than the full stylesheet color carrier.
pub(all) struct CT_Font {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <name>* (CT_FontName) — zero or more name entries.
  name : Array[CT_FontName]
  /// <charset>* (CT_IntProperty) — zero or more charset entries.
  charset : Array[CT_IntProperty]
  /// <family>* (CT_FontFamily) — zero or more family entries.
  family : Array[CT_FontFamily]
  /// <b>* (CT_BooleanProperty) — zero or more bold entries.
  b : Array[CT_BooleanProperty]
  /// <i>* (CT_BooleanProperty) — zero or more italic entries.
  i : Array[CT_BooleanProperty]
  /// <strike>* (CT_BooleanProperty) — zero or more strike entries.
  strike : Array[CT_BooleanProperty]
  /// <outline>* (CT_BooleanProperty) — zero or more outline entries.
  outline : Array[CT_BooleanProperty]
  /// <shadow>* (CT_BooleanProperty) — zero or more shadow entries.
  shadow : Array[CT_BooleanProperty]
  /// <condense>* (CT_BooleanProperty) — zero or more condense entries.
  condense : Array[CT_BooleanProperty]
  /// <extend>* (CT_BooleanProperty) — zero or more extend entries.
  extend : Array[CT_BooleanProperty]
  /// <color>* (CT_Color §18.8.3) — zero or more colour entries.
  color : Array[CT_Color]
  /// <sz>* (CT_FontSize) — zero or more size entries.
  sz : Array[CT_FontSize]
  /// <u>* (CT_UnderlineProperty) — zero or more underline entries.
  u : Array[CT_UnderlineProperty]
  /// <vertAlign>* (CT_VerticalAlignFontProperty) — zero or more vertical
  /// alignment entries.
  vert_align : Array[CT_VerticalAlignFontProperty]
  /// <scheme>* (CT_FontScheme) — zero or more scheme entries.
  scheme : Array[CT_FontScheme]
} derive(Eq, Debug)

///|
pub fn CT_Font::new(element : @xml.Element) -> CT_Font {
  let name : Array[CT_FontName] = []
  let charset : Array[CT_IntProperty] = []
  let family : Array[CT_FontFamily] = []
  let b : Array[CT_BooleanProperty] = []
  let i : Array[CT_BooleanProperty] = []
  let strike : Array[CT_BooleanProperty] = []
  let outline : Array[CT_BooleanProperty] = []
  let shadow : Array[CT_BooleanProperty] = []
  let condense : Array[CT_BooleanProperty] = []
  let extend : Array[CT_BooleanProperty] = []
  let color : Array[CT_Color] = []
  let sz : Array[CT_FontSize] = []
  let u : Array[CT_UnderlineProperty] = []
  let vert_align : Array[CT_VerticalAlignFontProperty] = []
  let scheme : Array[CT_FontScheme] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "name" => name.push(CT_FontName::new(child_element))
        "charset" => charset.push(CT_IntProperty::new(child_element))
        "family" => family.push(CT_FontFamily::new(child_element))
        "b" => b.push(CT_BooleanProperty::new(child_element))
        "i" => i.push(CT_BooleanProperty::new(child_element))
        "strike" => strike.push(CT_BooleanProperty::new(child_element))
        "outline" => outline.push(CT_BooleanProperty::new(child_element))
        "shadow" => shadow.push(CT_BooleanProperty::new(child_element))
        "condense" => condense.push(CT_BooleanProperty::new(child_element))
        "extend" => extend.push(CT_BooleanProperty::new(child_element))
        "color" => color.push(CT_Color::new(child_element))
        "sz" => sz.push(CT_FontSize::new(child_element))
        "u" => u.push(CT_UnderlineProperty::new(child_element))
        "vertAlign" =>
          vert_align.push(CT_VerticalAlignFontProperty::new(child_element))
        "scheme" => scheme.push(CT_FontScheme::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    name,
    charset,
    family,
    b,
    i,
    strike,
    outline,
    shadow,
    condense,
    extend,
    color,
    sz,
    u,
    vert_align,
    scheme,
  }
}

///|
/// XSD complex type CT_TableStyleInfo — Part 1 §18.8.41. Table style
/// reference attached to a `<table>` or pivot. Attribute-only. Optional
/// `@name` (s:ST_Xstring) table-style name; optional
/// `@showFirstColumn`, `@showLastColumn`, `@showRowStripes`,
/// `@showColumnStripes` (xsd:boolean, no defaults).
pub(all) struct CT_TableStyleInfo {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @name (s:ST_Xstring) — optional table style name reference.
  name : String?
  /// @showFirstColumn (xsd:boolean) — optional.
  show_first_column : Bool?
  /// @showLastColumn (xsd:boolean) — optional.
  show_last_column : Bool?
  /// @showRowStripes (xsd:boolean) — optional.
  show_row_stripes : Bool?
  /// @showColumnStripes (xsd:boolean) — optional.
  show_column_stripes : Bool?
} derive(Eq, Debug)

///|
pub fn CT_TableStyleInfo::new(
  element : @xml.Element,
) -> CT_TableStyleInfo raise @opc_errors.SchemaViolation {
  let name = attr(element, "name")
  let show_first_column = attr_bool_schema_opt(
    element, "showFirstColumn", "Part 1 §18.8.41", "tableStyleInfo",
  )
  let show_last_column = attr_bool_schema_opt(
    element, "showLastColumn", "Part 1 §18.8.41", "tableStyleInfo",
  )
  let show_row_stripes = attr_bool_schema_opt(
    element, "showRowStripes", "Part 1 §18.8.41", "tableStyleInfo",
  )
  let show_column_stripes = attr_bool_schema_opt(
    element, "showColumnStripes", "Part 1 §18.8.41", "tableStyleInfo",
  )
  {
    element,
    name,
    show_first_column,
    show_last_column,
    show_row_stripes,
    show_column_stripes,
  }
}

///|
/// XSD complex type CT_WorkbookProtection — Part 1 §18.2.29. Workbook
/// protection record. Attribute-only complex type. Optional
/// `@lockStructure`, `@lockWindows`, `@lockRevision` (xsd:boolean,
/// default false). Optional revision-password attributes:
/// `@revisionsAlgorithmName` (s:ST_Xstring), `@revisionsHashValue`
/// (xsd:base64Binary), `@revisionsSaltValue` (xsd:base64Binary),
/// `@revisionsSpinCount` (xsd:unsignedInt). Optional workbook-password
/// attributes: `@workbookAlgorithmName`, `@workbookHashValue`,
/// `@workbookSaltValue`, `@workbookSpinCount` (xsd:unsignedInt).
pub(all) struct CT_WorkbookProtection {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @lockStructure (xsd:boolean) — optional, default false.
  lock_structure : Bool
  /// @lockWindows (xsd:boolean) — optional, default false.
  lock_windows : Bool
  /// @lockRevision (xsd:boolean) — optional, default false.
  lock_revision : Bool
  /// @revisionsAlgorithmName (s:ST_Xstring) — optional algorithm name.
  revisions_algorithm_name : String?
  /// @revisionsHashValue (xsd:base64Binary) — optional revision hash.
  revisions_hash_value : String?
  /// @revisionsSaltValue (xsd:base64Binary) — optional revision salt.
  revisions_salt_value : String?
  /// @revisionsSpinCount (xsd:unsignedInt) — optional spin count.
  revisions_spin_count : Int?
  /// @workbookAlgorithmName (s:ST_Xstring) — optional algorithm name.
  workbook_algorithm_name : String?
  /// @workbookHashValue (xsd:base64Binary) — optional workbook hash.
  workbook_hash_value : String?
  /// @workbookSaltValue (xsd:base64Binary) — optional workbook salt.
  workbook_salt_value : String?
  /// @workbookSpinCount (xsd:unsignedInt) — optional spin count.
  workbook_spin_count : Int?
  /// @revisionsPassword / @workbookPassword (ST_UnsignedShortHex) —
  /// legacy 16-bit verifier hashes, deprecated in favour of the
  /// algorithm/hash/salt/spin attributes; `None` when absent.
  revisions_password : String?
  workbook_password : String?
} derive(Eq, Debug)

///|
pub fn CT_WorkbookProtection::new(
  element : @xml.Element,
) -> CT_WorkbookProtection {
  let lock_structure = attr_bool(element, "lockStructure", false)
  let lock_windows = attr_bool(element, "lockWindows", false)
  let lock_revision = attr_bool(element, "lockRevision", false)
  let revisions_password = attr(element, "revisionsPassword")
  let workbook_password = attr(element, "workbookPassword")
  let revisions_algorithm_name = attr(element, "revisionsAlgorithmName")
  let revisions_hash_value = attr(element, "revisionsHashValue")
  let revisions_salt_value = attr(element, "revisionsSaltValue")
  let revisions_spin_count = attr_uint_opt(element, "revisionsSpinCount")
  let workbook_algorithm_name = attr(element, "workbookAlgorithmName")
  let workbook_hash_value = attr(element, "workbookHashValue")
  let workbook_salt_value = attr(element, "workbookSaltValue")
  let workbook_spin_count = attr_uint_opt(element, "workbookSpinCount")
  {
    element,
    lock_structure,
    lock_windows,
    lock_revision,
    revisions_algorithm_name,
    revisions_hash_value,
    revisions_salt_value,
    revisions_spin_count,
    workbook_algorithm_name,
    workbook_hash_value,
    workbook_salt_value,
    workbook_spin_count,
    revisions_password,
    workbook_password,
  }
}
