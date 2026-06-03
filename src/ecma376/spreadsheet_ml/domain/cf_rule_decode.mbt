///|
/// Part 1 §18.3.1.10 / §18.18.12 — citation helper exported so
/// callers can include the spec anchor in their own diagnostics.
let cf_rule_section : String = "Part 1 §18.3.1.10 / §18.18.12"

///|
let cfvo_section : String = "Part 1 §18.3.1.11 / §18.18.13"

///|
/// Part 1 §18.18.12 — decode a ST_CfType lexical attribute value to a
/// typed `ST_CfType`. Raises `@opc_errors.SchemaViolation` for any
/// non-spec lexical value.
pub fn decode_cf_type(
  value : String,
) -> ST_CfType raise @opc_errors.SchemaViolation {
  match value {
    "aboveAverage" => AboveAverage
    "beginsWith" => BeginsWith
    "cellIs" => CellIs
    "colorScale" => ColorScale
    "containsBlanks" => ContainsBlanks
    "containsErrors" => ContainsErrors
    "containsText" => ContainsText
    "dataBar" => DataBar
    "duplicateValues" => DuplicateValues
    "endsWith" => EndsWith
    "expression" => Expression
    "iconSet" => IconSet
    "notContainsBlanks" => NotContainsBlanks
    "notContainsErrors" => NotContainsErrors
    "notContainsText" => NotContainsText
    "timePeriod" => TimePeriod
    "top10" => Top10
    "uniqueValues" => UniqueValues
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@type",
        reason="unknown ST_CfType enumeration value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.15 — decode a ST_ConditionalFormattingOperator
/// lexical attribute value to a typed
/// `ST_ConditionalFormattingOperator`.
pub fn decode_cf_operator(
  value : String,
) -> ST_ConditionalFormattingOperator raise @opc_errors.SchemaViolation {
  match value {
    "beginsWith" => OpBeginsWith
    "between" => OpBetween
    "containsText" => OpContainsText
    "endsWith" => OpEndsWith
    "equal" => OpEqual
    "greaterThan" => OpGreaterThan
    "greaterThanOrEqual" => OpGreaterThanOrEqual
    "lessThan" => OpLessThan
    "lessThanOrEqual" => OpLessThanOrEqual
    "notBetween" => OpNotBetween
    "notContains" => OpNotContains
    "notEqual" => OpNotEqual
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@operator",
        reason="unknown ST_ConditionalFormattingOperator value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.82 — decode a ST_TimePeriod lexical value.
pub fn decode_time_period(
  value : String,
) -> ST_TimePeriod raise @opc_errors.SchemaViolation {
  match value {
    "today" => Today
    "yesterday" => Yesterday
    "tomorrow" => Tomorrow
    "last7Days" => Last7Days
    "lastWeek" => LastWeek
    "thisWeek" => ThisWeek
    "nextWeek" => NextWeek
    "lastMonth" => LastMonth
    "thisMonth" => ThisMonth
    "nextMonth" => NextMonth
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@timePeriod",
        reason="unknown ST_TimePeriod value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.13 — decode a ST_CfvoType lexical value.
pub fn decode_cfvo_type(
  value : String,
) -> ST_CfvoType raise @opc_errors.SchemaViolation {
  match value {
    "num" => CfvoNum
    "min" => CfvoMin
    "max" => CfvoMax
    "percent" => CfvoPercent
    "percentile" => CfvoPercentile
    "formula" => CfvoFormula
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cfvo_section,
        path="cfvo/@type",
        reason="unknown ST_CfvoType value: " + value,
      )
  }
}

///|
/// Part 1 §18.3.1.18 conditionalFormatting — decode the outer
/// CT_ConditionalFormatting element into a typed
/// `CT_ConditionalFormatting` whose rules are sorted ascending by
/// `@priority`. The `@sqref` attribute is `use="optional"` in the XSD:
/// when present it is parsed through `@address`; when absent the
/// conditional formatting block simply has no application target, so
/// an empty `Sqref` (`{ ranges: [] }`) is used.
pub fn CT_ConditionalFormatting::new(
  element : @xml.Element,
) -> CT_ConditionalFormatting raise @opc_errors.SchemaViolation {
  let pivot = cf_decode_bool_attr(element, "pivot", false)
  let sqref : @address.Sqref = match cf_attr(element, "sqref") {
    Some(sqref_text) => @address.Sqref::parse_a1(sqref_text)
    None => { ranges: [] }
  }
  let rules : Array[CT_CfRule] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "cfRule" {
          rules.push(CT_CfRule::new(child_element))
        }
      _ => ()
    }
  }
  rules.sort_by(fn(a, b) {
    if a.priority < b.priority {
      -1
    } else if a.priority > b.priority {
      1
    } else {
      0
    }
  })
  { pivot, sqref, rules }
}

///|
/// Part 1 §18.3.1.10 cfRule — decode a CT_CfRule element into the
/// typed `CT_CfRule` carrying every attribute defined in the section
/// table (type, dxfId, priority, stopIfTrue, aboveAverage, percent,
/// bottom, operator, text, timePeriod, rank, stdDev, equalAverage)
/// and the child `<formula>` / `<colorScale>` / `<dataBar>` /
/// `<iconSet>` elements.
pub fn CT_CfRule::new(
  element : @xml.Element,
) -> CT_CfRule raise @opc_errors.SchemaViolation {
  // §18.3.1.10 — `@type` is `use="optional"`. ST_CfType is a closed
  // 18-value enumeration with no "none" member, so a missing `@type`
  // is modelled as `None`: the rule carries no recognised type and
  // the evaluator/renderer treat it as inert.
  let cf_type : ST_CfType? = match cf_attr(element, "type") {
    Some(value) => Some(decode_cf_type(value))
    None => None
  }
  let priority = cf_decode_required_int(element, "priority", "cfRule/@priority")
  let dxf_id = cf_decode_optional_int(element, "dxfId", "cfRule/@dxfId")
  let stop_if_true = cf_decode_bool_attr(element, "stopIfTrue", false)
  let above_average = cf_decode_bool_attr(element, "aboveAverage", true)
  let equal_average = cf_decode_bool_attr(element, "equalAverage", false)
  let percent = cf_decode_bool_attr(element, "percent", false)
  let bottom = cf_decode_bool_attr(element, "bottom", false)
  let operator : ST_ConditionalFormattingOperator? = match
    cf_attr(element, "operator") {
    Some(value) => Some(decode_cf_operator(value))
    None => None
  }
  let time_period : ST_TimePeriod? = match cf_attr(element, "timePeriod") {
    Some(value) => Some(decode_time_period(value))
    None => None
  }
  let rank = cf_decode_optional_int(element, "rank", "cfRule/@rank")
  let std_dev = cf_decode_optional_int(element, "stdDev", "cfRule/@stdDev")
  let text = cf_attr(element, "text")
  let formulas : Array[String] = []
  let mut color_scale : CT_ColorScale? = None
  let mut data_bar : CT_DataBar? = None
  let mut icon_set : CT_IconSet? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let name = child_element.name.local_name
        if name == "formula" {
          formulas.push(cf_text_content(child_element))
        } else if name == "colorScale" {
          color_scale = Some(CT_ColorScale::new(child_element))
        } else if name == "dataBar" {
          data_bar = Some(CT_DataBar::new(child_element))
        } else if name == "iconSet" {
          icon_set = Some(CT_IconSet::new(child_element))
        }
      }
      _ => ()
    }
  }
  {
    cf_type,
    dxf_id,
    priority,
    stop_if_true,
    operator,
    text,
    time_period,
    rank,
    bottom,
    percent,
    above_average,
    equal_average,
    std_dev,
    formulas,
    color_scale,
    data_bar,
    icon_set,
  }
}

///|
/// Part 1 §18.3.1.16 colorScale — decode the gradient.
pub fn CT_ColorScale::new(
  element : @xml.Element,
) -> CT_ColorScale raise @opc_errors.SchemaViolation {
  let thresholds : Array[CT_Cfvo] = []
  let colors : Array[CT_ColorArgb] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let name = child_element.name.local_name
        if name == "cfvo" {
          thresholds.push(CT_Cfvo::new(child_element))
        } else if name == "color" {
          colors.push(cf_decode_color(child_element))
        }
      }
      _ => ()
    }
  }
  if thresholds.length() < 2 {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.3.1.16",
      path="colorScale/cfvo",
      reason="colorScale requires at least two cfvo thresholds",
    )
  }
  if colors.length() != thresholds.length() {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.3.1.16",
      path="colorScale",
      reason="cfvo and color child counts must match",
    )
  }
  { thresholds, colors }
}

///|
/// Part 1 §18.3.1.28 dataBar — decode min/max cfvo pair plus the bar
/// fill color.
pub fn CT_DataBar::new(
  element : @xml.Element,
) -> CT_DataBar raise @opc_errors.SchemaViolation {
  let thresholds : Array[CT_Cfvo] = []
  let mut color_value : CT_ColorArgb? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let name = child_element.name.local_name
        if name == "cfvo" {
          thresholds.push(CT_Cfvo::new(child_element))
        } else if name == "color" {
          color_value = Some(cf_decode_color(child_element))
        }
      }
      _ => ()
    }
  }
  if thresholds.length() != 2 {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.3.1.28",
      path="dataBar/cfvo",
      reason="dataBar requires exactly two cfvo thresholds (min, max)",
    )
  }
  let color = match color_value {
    Some(c) => c
    None =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.1.28",
        path="dataBar/color",
        reason="dataBar requires a color element",
      )
  }
  let min_length = cf_decode_optional_int(
    element, "minLength", "dataBar/@minLength",
  ).unwrap_or(10)
  let max_length = cf_decode_optional_int(
    element, "maxLength", "dataBar/@maxLength",
  ).unwrap_or(90)
  let axis_position = cf_attr_or(element, "axisPosition", "automatic")
  let direction = cf_attr_or(element, "direction", "context")
  let negative_color = cf_decode_data_bar_negative_color(element)
  let axis_color = cf_decode_data_bar_axis_color(element)
  {
    element,
    min_threshold: thresholds[0],
    max_threshold: thresholds[1],
    color,
    min_length,
    max_length,
    show_value: cf_decode_bool_attr(element, "showValue", true),
    axis_position,
    direction,
    negative_color,
    axis_color,
  }
}

///|
fn cf_decode_data_bar_negative_color(
  data_bar : @xml.Element,
) -> CT_ColorArgb? raise @opc_errors.SchemaViolation {
  match cf_first_child_named(data_bar, "negativeFillColor") {
    Some(color_el) =>
      return cf_decode_data_bar_color(color_el, "dataBar/negativeFillColor")
    None => ()
  }
  // Some producers write the DrawingML-style colour child directly
  // inside dataBar. Preserve that legacy variant in the typed SoT.
  match cf_first_child_named(data_bar, "srgbClr") {
    Some(srgb) => cf_decode_srgb_color(srgb, "dataBar/srgbClr/@val")
    None => None
  }
}

///|
fn cf_decode_data_bar_axis_color(
  data_bar : @xml.Element,
) -> CT_ColorArgb? raise @opc_errors.SchemaViolation {
  match cf_first_child_named(data_bar, "axisColor") {
    Some(color_el) => cf_decode_data_bar_color(color_el, "dataBar/axisColor")
    None => None
  }
}

///|
fn cf_decode_data_bar_color(
  element : @xml.Element,
  path : String,
) -> CT_ColorArgb? raise @opc_errors.SchemaViolation {
  match cf_attr(element, "rgb") {
    Some(value) => return Some(cf_parse_argb_hex(value))
    None => ()
  }
  match cf_first_child_named(element, "srgbClr") {
    Some(srgb) => cf_decode_srgb_color(srgb, path + "/srgbClr/@val")
    None => None
  }
}

///|
fn cf_decode_srgb_color(
  element : @xml.Element,
  path : String,
) -> CT_ColorArgb? raise @opc_errors.SchemaViolation {
  match cf_attr(element, "val") {
    Some(value) => Some(cf_parse_srgb_hex(value, path))
    None => None
  }
}

///|
/// Part 1 §18.3.1.49 iconSet — decode the icon set name, the cfvo
/// thresholds, and the `reverse` / `showValue` presentation flags.
pub fn CT_IconSet::new(
  element : @xml.Element,
) -> CT_IconSet raise @opc_errors.SchemaViolation {
  let set_name = cf_decode_icon_set_type(
    cf_attr_or(element, "iconSet", "3TrafficLights1"),
  )
  let reverse = cf_decode_bool_attr(element, "reverse", false)
  let show_value = cf_decode_bool_attr(element, "showValue", true)
  let percent = cf_decode_bool_attr(element, "percent", true)
  let thresholds : Array[CT_Cfvo] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "cfvo" {
          thresholds.push(CT_Cfvo::new(child_element))
        }
      _ => ()
    }
  }
  if thresholds.length() < 2 {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.3.1.49",
      path="iconSet/cfvo",
      reason="iconSet requires at least two cfvo thresholds",
    )
  }
  { set_name, thresholds, reverse, show_value, percent }
}

///|
fn cf_decode_icon_set_type(
  value : String,
) -> String raise @opc_errors.SchemaViolation {
  try @sml_types.ST_IconSetType::new(value) catch {
    @sml_types.SchemaViolation(_) =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.3.1.49 / §18.18.42",
        path="iconSet/@iconSet",
        reason="value is outside ST_IconSetType enumeration",
      )
  } noraise {
    parsed => parsed.to_string()
  }
}

///|
/// Part 1 §18.3.1.11 cfvo — decode a single conditional formatting
/// value object. The @type attribute is required; @val is required
/// for `num`, `percent`, `percentile`, `formula` and ignored for
/// `min`, `max`.
pub fn CT_Cfvo::new(
  element : @xml.Element,
) -> CT_Cfvo raise @opc_errors.SchemaViolation {
  // §A.2 — `CT_Cfvo/@val` is `use="optional"` in the schema.  Word
  // and the spec's own examples always pair a threshold `@type` with
  // a `@val`, but a conforming reader MUST NOT reject its absence;
  // an absent value simply leaves the threshold unset and a consumer
  // treats that rule arm as inert.
  let kind = decode_cfvo_type(cf_require_attr(element, "type", "cfvo/@type"))
  let value_text = cf_attr(element, "val")
  { kind, value_text, gte: cf_decode_bool_attr(element, "gte", true) }
}

///|
/// Part 1 §18.3.1.15 color — decode a CT_Color element to an ARGB
/// tuple. Theme / indexed / tint resolution lives in the renderer;
/// the evaluator accepts the @rgb hex literal directly and falls back
/// to opaque black when no rgb is present.
fn cf_decode_color(
  element : @xml.Element,
) -> CT_ColorArgb raise @opc_errors.SchemaViolation {
  match cf_attr(element, "rgb") {
    Some(value) => cf_parse_argb_hex(value)
    None => CT_ColorArgb::new(255, 0, 0, 0)
  }
}

///|
fn cf_parse_argb_hex(
  value : String,
) -> CT_ColorArgb raise @opc_errors.SchemaViolation {
  if value.length() != 8 {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.3.1.15",
      path="color/@rgb",
      reason="ARGB hex must be exactly 8 characters",
    )
  }
  let alpha = cf_hex_pair(value, 0)
  let red = cf_hex_pair(value, 2)
  let green = cf_hex_pair(value, 4)
  let blue = cf_hex_pair(value, 6)
  CT_ColorArgb::new(alpha, red, green, blue)
}

///|
fn cf_parse_srgb_hex(
  value : String,
  path : String,
) -> CT_ColorArgb raise @opc_errors.SchemaViolation {
  if value.length() != 6 {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.3.1.15",
      path~,
      reason="sRGB hex must be exactly 6 characters",
    )
  }
  let red = cf_hex_pair(value, 0)
  let green = cf_hex_pair(value, 2)
  let blue = cf_hex_pair(value, 4)
  CT_ColorArgb::new(255, red, green, blue)
}

///|
fn cf_hex_pair(value : String, offset : Int) -> Int {
  let hi = cf_hex_digit(value.code_unit_at(offset).to_int())
  let lo = cf_hex_digit(value.code_unit_at(offset + 1).to_int())
  hi * 16 + lo
}

///|
fn cf_hex_digit(unit : Int) -> Int {
  if unit >= 0x30 && unit <= 0x39 {
    unit - 0x30
  } else if unit >= 0x41 && unit <= 0x46 {
    unit - 0x41 + 10
  } else if unit >= 0x61 && unit <= 0x66 {
    unit - 0x61 + 10
  } else {
    0
  }
}

///|
fn cf_text_content(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Text(text) => buf.write_string(text)
      @xml.CData(text) => buf.write_string(text)
      _ => ()
    }
  }
  buf.to_string()
}

///|
fn cf_attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
fn cf_first_child_named(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == local_name {
          return Some(child_element)
        }
      _ => ()
    }
  }
  None
}

///|
fn cf_attr_or(
  element : @xml.Element,
  local_name : String,
  fallback : String,
) -> String {
  cf_attr(element, local_name).unwrap_or(fallback)
}

///|
fn cf_require_attr(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise @opc_errors.SchemaViolation {
  match cf_attr(element, local_name) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=cf_decode_section_for_element(element),
        path~,
        reason="required attribute is missing",
      )
  }
}

///|
fn cf_decode_bool_text(
  text : String,
  path : String,
  section : String,
) -> Bool raise @opc_errors.SchemaViolation {
  match text {
    "1" => true
    "true" => true
    "0" => false
    "false" => false
    _ =>
      raise @opc_errors.SchemaViolation(
        section~,
        path~,
        reason="xsd:boolean value is malformed: " + text,
      )
  }
}

///|
fn cf_decode_bool_attr(
  element : @xml.Element,
  local_name : String,
  fallback : Bool,
) -> Bool raise @opc_errors.SchemaViolation {
  match cf_attr(element, local_name) {
    Some(value) =>
      cf_decode_bool_text(
        value,
        element.name.local_name + "/@" + local_name,
        cf_decode_section_for_element(element),
      )
    None => fallback
  }
}

///|
fn cf_decode_section_for_element(element : @xml.Element) -> String {
  match element.name.local_name {
    "conditionalFormatting" => "Part 1 §18.3.1.18"
    "cfRule" => cf_rule_section
    "cfvo" => cfvo_section
    "colorScale" => "Part 1 §18.3.1.16"
    "dataBar" => "Part 1 §18.3.1.28"
    "iconSet" => "Part 1 §18.3.1.49"
    _ => cf_rule_section
  }
}

///|
fn cf_decode_required_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  let value = cf_require_attr(element, local_name, path)
  match cf_parse_int(value) {
    Some(n) => n
    None =>
      raise @opc_errors.SchemaViolation(
        section=cf_decode_section_for_element(element),
        path~,
        reason="integer attribute is malformed: " + value,
      )
  }
}

///|
fn cf_decode_optional_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match cf_attr(element, local_name) {
    Some(value) =>
      match cf_parse_int(value) {
        Some(n) => Some(n)
        None =>
          raise @opc_errors.SchemaViolation(
            section=cf_decode_section_for_element(element),
            path~,
            reason="integer attribute is malformed: " + value,
          )
      }
    None => None
  }
}

///|
fn cf_parse_int(text : String) -> Int? {
  let trimmed = cf_trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try {
    let value : Int64 = @strconv.from_str(trimmed)
    Some(value.to_int())
  } catch {
    _ => None
  }
}

///|
fn cf_trim_whitespace(text : String) -> String {
  let len = text.length()
  let mut start = 0
  while start < len {
    let c = text.code_unit_at(start).to_int()
    if c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let c = text.code_unit_at(end - 1).to_int()
    if c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D {
      end = end - 1
    } else {
      break
    }
  }
  text[start:end].to_owned()
}
