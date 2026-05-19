///|
/// Part 1 §18.3.1.18 conditionalFormatting — decode the outer CT_ConditionalFormatting
/// element into a typed `CfBlock` whose rules are sorted ascending by
/// `@priority`. The `@sqref` attribute is parsed through `@address`.
pub fn decode_cf_block(
  block : @domain.CT_ConditionalFormatting,
) -> CfBlock raise @opc_errors.SchemaViolation {
  let element = block.element
  let pivot = decode_bool_attr(element, "pivot", false)
  let sqref_text = require_attr(
    element, "sqref", "conditionalFormatting/@sqref",
  )
  let sqref = @address.Sqref::parse_a1(sqref_text)
  let rules : Array[CfRule] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "cfRule" {
          rules.push(decode_cf_rule(@domain.CT_CfRule::new(child_element)))
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
/// typed `CfRule` carrying every attribute defined in the section
/// table (type, dxfId, priority, stopIfTrue, aboveAverage, percent,
/// bottom, operator, text, timePeriod, rank, stdDev, equalAverage) and
/// the child `<formula>` / `<colorScale>` / `<dataBar>` / `<iconSet>`
/// elements.
pub fn decode_cf_rule(
  rule : @domain.CT_CfRule,
) -> CfRule raise @opc_errors.SchemaViolation {
  let element = rule.element
  let cf_type = CfType::from_attr(require_attr(element, "type", "cfRule/@type"))
  let priority = decode_required_int(element, "priority", "cfRule/@priority")
  let dxf_id = decode_optional_int(element, "dxfId", "cfRule/@dxfId")
  let stop_if_true = decode_bool_attr(element, "stopIfTrue", false)
  let above_average = decode_bool_attr(element, "aboveAverage", true)
  let equal_average = decode_bool_attr(element, "equalAverage", false)
  let percent = decode_bool_attr(element, "percent", false)
  let bottom = decode_bool_attr(element, "bottom", false)
  let operator : CfOperator? = match attr(element, "operator") {
    Some(value) => Some(CfOperator::from_attr(value))
    None => None
  }
  let time_period : TimePeriod? = match attr(element, "timePeriod") {
    Some(value) => Some(TimePeriod::from_attr(value))
    None => None
  }
  let rank = decode_optional_int(element, "rank", "cfRule/@rank")
  let std_dev = decode_optional_int(element, "stdDev", "cfRule/@stdDev")
  let text = attr(element, "text")
  let formulas : Array[String] = []
  let mut color_scale : CfColorScale? = None
  let mut data_bar : CfDataBar? = None
  let mut icon_set : CfIconSet? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let name = child_element.name.local_name
        if name == "formula" {
          formulas.push(text_content(child_element))
        } else if name == "colorScale" {
          color_scale = Some(decode_color_scale(child_element))
        } else if name == "dataBar" {
          data_bar = Some(decode_data_bar(child_element))
        } else if name == "iconSet" {
          icon_set = Some(decode_icon_set(child_element))
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
/// Part 1 §18.3.1.16 colorScale — decode the gradient. Order matters:
/// the first cfvo pairs with the first color, second with second, etc.
fn decode_color_scale(
  element : @xml.Element,
) -> CfColorScale raise @opc_errors.SchemaViolation {
  let thresholds : Array[CfvoThreshold] = []
  let colors : Array[CfArgb] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let name = child_element.name.local_name
        if name == "cfvo" {
          thresholds.push(decode_cfvo(child_element))
        } else if name == "color" {
          colors.push(decode_color(child_element))
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
/// fill color. The dataBar element accepts the `showValue`,
/// `minLength`, `maxLength` attributes which the renderer interprets;
/// the evaluator only needs the thresholds and color.
fn decode_data_bar(
  element : @xml.Element,
) -> CfDataBar raise @opc_errors.SchemaViolation {
  let thresholds : Array[CfvoThreshold] = []
  let mut color_value : CfArgb? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let name = child_element.name.local_name
        if name == "cfvo" {
          thresholds.push(decode_cfvo(child_element))
        } else if name == "color" {
          color_value = Some(decode_color(child_element))
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
  { min_threshold: thresholds[0], max_threshold: thresholds[1], color }
}

///|
/// Part 1 §18.3.1.49 iconSet — decode the icon set name, the cfvo
/// thresholds, and the `reverse` / `showValue` presentation flags.
fn decode_icon_set(
  element : @xml.Element,
) -> CfIconSet raise @opc_errors.SchemaViolation {
  let set_name = attr_or(element, "iconSet", "3TrafficLights1")
  let reverse = decode_bool_attr(element, "reverse", false)
  let show_value = decode_bool_attr(element, "showValue", true)
  let thresholds : Array[CfvoThreshold] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) =>
        if child_element.name.local_name == "cfvo" {
          thresholds.push(decode_cfvo(child_element))
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
  { set_name, thresholds, reverse, show_value }
}

///|
/// Part 1 §18.3.1.11 cfvo — decode a single conditional formatting
/// value object. The @type attribute is required; @val is required
/// for `num`, `percent`, `percentile`, `formula` and ignored for
/// `min`, `max`.
fn decode_cfvo(
  element : @xml.Element,
) -> CfvoThreshold raise @opc_errors.SchemaViolation {
  let kind = CfvoType::from_attr(require_attr(element, "type", "cfvo/@type"))
  let value_text = attr(element, "val")
  match kind {
    CfvoMin | CfvoMax => ()
    _ =>
      if value_text is None {
        raise @opc_errors.SchemaViolation(
          section="Part 1 §18.3.1.11",
          path="cfvo/@val",
          reason="cfvo type=" +
            kind_to_lexical(kind) +
            " requires @val attribute",
        )
      }
  }
  { kind, value_text }
}

///|
fn kind_to_lexical(kind : CfvoType) -> String {
  match kind {
    CfvoNum => "num"
    CfvoMin => "min"
    CfvoMax => "max"
    CfvoPercent => "percent"
    CfvoPercentile => "percentile"
    CfvoFormula => "formula"
  }
}

///|
/// Part 1 §18.3.1.15 color — decode a CT_Color element to an ARGB
/// tuple. Theme / indexed / tint resolution lives in the renderer;
/// the evaluator accepts the @rgb hex literal directly and falls back
/// to opaque black when no rgb is present (callers feed pre-resolved
/// theme colors as @rgb hex strings).
fn decode_color(
  element : @xml.Element,
) -> CfArgb raise @opc_errors.SchemaViolation {
  match attr(element, "rgb") {
    Some(value) => parse_argb_hex(value)
    None => CfArgb::new(255, 0, 0, 0)
  }
}

///|
fn parse_argb_hex(value : String) -> CfArgb raise @opc_errors.SchemaViolation {
  if value.length() != 8 {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.3.1.15",
      path="color/@rgb",
      reason="ARGB hex must be exactly 8 characters",
    )
  }
  let alpha = hex_pair(value, 0)
  let red = hex_pair(value, 2)
  let green = hex_pair(value, 4)
  let blue = hex_pair(value, 6)
  CfArgb::new(alpha, red, green, blue)
}

///|
fn hex_pair(value : String, offset : Int) -> Int {
  let hi = hex_digit(value.code_unit_at(offset).to_int())
  let lo = hex_digit(value.code_unit_at(offset + 1).to_int())
  hi * 16 + lo
}

///|
fn hex_digit(unit : Int) -> Int {
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
fn text_content(element : @xml.Element) -> String {
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
fn attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
fn attr_or(
  element : @xml.Element,
  local_name : String,
  fallback : String,
) -> String {
  attr(element, local_name).unwrap_or(fallback)
}

///|
fn require_attr(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path~,
        reason="required attribute is missing",
      )
  }
}

///|
fn decode_bool_attr(
  element : @xml.Element,
  local_name : String,
  fallback : Bool,
) -> Bool {
  match attr(element, local_name) {
    Some("1") => true
    Some("true") => true
    Some("0") => false
    Some("false") => false
    _ => fallback
  }
}

///|
fn decode_required_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  let value = require_attr(element, local_name, path)
  match parse_int(value) {
    Some(n) => n
    None =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path~,
        reason="integer attribute is malformed: " + value,
      )
  }
}

///|
fn decode_optional_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match attr(element, local_name) {
    Some(value) =>
      match parse_int(value) {
        Some(n) => Some(n)
        None =>
          raise @opc_errors.SchemaViolation(
            section=cf_rule_section,
            path~,
            reason="integer attribute is malformed: " + value,
          )
      }
    None => None
  }
}

///|
fn parse_int(text : String) -> Int? {
  let trimmed = trim_whitespace(text)
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
