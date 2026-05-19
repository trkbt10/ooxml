///|
/// Part 1 §17.9.16 numbering — decode the root CT_Numbering element
/// into a `NumberingTable` keyed by `abstractNumId` and `numId`.
pub fn NumberingTable::from_numbering(
  numbering : @domain.CT_Numbering,
) -> NumberingTable raise @opc_errors.SchemaViolation {
  let abstract_nums : @hashmap.HashMap[Int, AbstractNum] = @hashmap.HashMap::new()
  let nums : @hashmap.HashMap[Int, Num] = @hashmap.HashMap::new()
  let pic_bullets : @hashmap.HashMap[Int, @xml.Element] = @hashmap.HashMap::new()
  for child in numbering.element.children {
    match child {
      @xml.Element(element) => {
        let name = element.name.local_name
        if name == "abstractNum" {
          let abs = decode_abstract_num_element(element)
          abstract_nums.set(abs.abstract_num_id, abs)
        } else if name == "num" {
          let num = decode_num_element(element)
          nums.set(num.num_id, num)
        } else if name == "numPicBullet" {
          let id = decode_required_int(
            element, "numPicBulletId", "numPicBullet/@numPicBulletId",
          )
          pic_bullets.set(id, element)
        }
      }
      _ => ()
    }
  }
  { abstract_nums, nums, pic_bullets }
}

///|
/// Part 1 §17.9.1 abstractNum — typed decoder.
pub fn decode_abstract_num(
  abs : @domain.CT_AbstractNum,
) -> AbstractNum raise @opc_errors.SchemaViolation {
  decode_abstract_num_element(abs.element)
}

///|
/// Part 1 §17.9.15 num — typed decoder.
pub fn decode_num(
  num : @domain.CT_Num,
) -> Num raise @opc_errors.SchemaViolation {
  decode_num_element(num.element)
}

///|
/// Part 1 §17.9.6 lvl — typed decoder.
pub fn decode_lvl(
  lvl : @domain.CT_Lvl,
) -> Lvl raise @opc_errors.SchemaViolation {
  decode_lvl_element(lvl.element)
}

///|
fn decode_abstract_num_element(
  element : @xml.Element,
) -> AbstractNum raise @opc_errors.SchemaViolation {
  let abstract_num_id = decode_required_int(
    element, "abstractNumId", "abstractNum/@abstractNumId",
  )
  let mut multi_level_type : MultiLevelType? = None
  let mut name : String? = None
  let mut nsid : String? = None
  let mut tmpl : String? = None
  let mut style_link : String? = None
  let mut num_style_link : String? = None
  let lvls : Array[Lvl] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let local = child_element.name.local_name
        if local == "multiLevelType" {
          match attr(child_element, "val") {
            Some(value) =>
              multi_level_type = Some(MultiLevelType::from_attr(value))
            None => ()
          }
        } else if local == "name" {
          name = attr(child_element, "val")
        } else if local == "nsid" {
          nsid = attr(child_element, "val")
        } else if local == "tmpl" {
          tmpl = attr(child_element, "val")
        } else if local == "styleLink" {
          style_link = attr(child_element, "val")
        } else if local == "numStyleLink" {
          num_style_link = attr(child_element, "val")
        } else if local == "lvl" {
          lvls.push(decode_lvl_element(child_element))
        }
      }
      _ => ()
    }
  }
  lvls.sort_by(fn(a, b) {
    if a.ilvl < b.ilvl {
      -1
    } else if a.ilvl > b.ilvl {
      1
    } else {
      0
    }
  })
  {
    abstract_num_id,
    multi_level_type,
    name,
    nsid,
    tmpl,
    style_link,
    num_style_link,
    lvls,
  }
}

///|
fn decode_num_element(
  element : @xml.Element,
) -> Num raise @opc_errors.SchemaViolation {
  let num_id = decode_required_int(element, "numId", "num/@numId")
  let mut abstract_num_id_opt : Int? = None
  let lvl_overrides : Array[LvlOverride] = []
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let local = child_element.name.local_name
        if local == "abstractNumId" {
          abstract_num_id_opt = Some(
            decode_required_int(child_element, "val", "num/abstractNumId/@val"),
          )
        } else if local == "lvlOverride" {
          lvl_overrides.push(decode_lvl_override(child_element))
        }
      }
      _ => ()
    }
  }
  let abstract_num_id = match abstract_num_id_opt {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=numbering_section,
        path="num/abstractNumId",
        reason="required child abstractNumId is missing",
      )
  }
  { num_id, abstract_num_id, lvl_overrides }
}

///|
fn decode_lvl_override(
  element : @xml.Element,
) -> LvlOverride raise @opc_errors.SchemaViolation {
  let ilvl = decode_required_int(element, "ilvl", "lvlOverride/@ilvl")
  let mut start_override : Int? = None
  let mut lvl : Lvl? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let local = child_element.name.local_name
        if local == "startOverride" {
          start_override = Some(
            decode_required_int(
              child_element, "val", "lvlOverride/startOverride/@val",
            ),
          )
        } else if local == "lvl" {
          lvl = Some(decode_lvl_element(child_element))
        }
      }
      _ => ()
    }
  }
  { ilvl, start_override, lvl }
}

///|
fn decode_lvl_element(
  element : @xml.Element,
) -> Lvl raise @opc_errors.SchemaViolation {
  let ilvl = decode_required_int(element, "ilvl", "lvl/@ilvl")
  let mut start : Int? = None
  let mut num_fmt : NumFormat? = None
  let mut lvl_text : String? = None
  let mut lvl_jc : LvlJustification? = None
  let mut lvl_restart : Int? = None
  let mut p_style : String? = None
  let mut suff : LvlSuffix? = None
  let mut is_lgl = false
  let mut lvl_pic_bullet_id : Int? = None
  let mut p_pr_element : @xml.Element? = None
  let mut r_pr_element : @xml.Element? = None
  for child in element.children {
    match child {
      @xml.Element(child_element) => {
        let local = child_element.name.local_name
        if local == "start" {
          match attr(child_element, "val") {
            Some(value) => start = parse_int(value)
            None => ()
          }
        } else if local == "numFmt" {
          match attr(child_element, "val") {
            Some(value) => num_fmt = Some(NumFormat::from_attr(value))
            None => ()
          }
        } else if local == "lvlText" {
          lvl_text = attr(child_element, "val")
        } else if local == "lvlJc" {
          match attr(child_element, "val") {
            Some(value) => lvl_jc = Some(LvlJustification::from_attr(value))
            None => ()
          }
        } else if local == "lvlRestart" {
          match attr(child_element, "val") {
            Some(value) => lvl_restart = parse_int(value)
            None => ()
          }
        } else if local == "pStyle" {
          p_style = attr(child_element, "val")
        } else if local == "suff" {
          match attr(child_element, "val") {
            Some(value) => suff = Some(LvlSuffix::from_attr(value))
            None => ()
          }
        } else if local == "isLgl" {
          is_lgl = true
        } else if local == "lvlPicBulletId" {
          match attr(child_element, "val") {
            Some(value) => lvl_pic_bullet_id = parse_int(value)
            None => ()
          }
        } else if local == "pPr" {
          p_pr_element = Some(child_element)
        } else if local == "rPr" {
          r_pr_element = Some(child_element)
        }
      }
      _ => ()
    }
  }
  {
    ilvl,
    start,
    num_fmt,
    lvl_text,
    lvl_jc,
    lvl_restart,
    p_style,
    suff,
    is_lgl,
    lvl_pic_bullet_id,
    p_pr_element,
    r_pr_element,
  }
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
fn decode_required_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  let value = match attr(element, local_name) {
    Some(text) => text
    None =>
      raise @opc_errors.SchemaViolation(
        section=numbering_section,
        path~,
        reason="required attribute is missing",
      )
  }
  match parse_int(value) {
    Some(n) => n
    None =>
      raise @opc_errors.SchemaViolation(
        section=numbering_section,
        path~,
        reason="integer attribute is malformed: " + value,
      )
  }
}

///|
fn parse_int(text : String) -> Int? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  let mut start_index = 0
  let mut negative = false
  let first = trimmed.code_unit_at(0).to_int()
  if first == 0x2D {
    negative = true
    start_index = 1
  } else if first == 0x2B {
    start_index = 1
  }
  if start_index >= trimmed.length() {
    return None
  }
  let mut value = 0
  for i in start_index..<trimmed.length() {
    let unit = trimmed.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
  }
  if negative {
    Some(-value)
  } else {
    Some(value)
  }
}

///|
fn trim_whitespace(text : String) -> String {
  let mut start = 0
  while start < text.length() {
    let unit = text.code_unit_at(start).to_int()
    if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
      break
    }
    start = start + 1
  }
  let mut end = text.length()
  while end > start {
    let unit = text.code_unit_at(end - 1).to_int()
    if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
      break
    }
    end = end - 1
  }
  text.unsafe_substring(start~, end~)
}
