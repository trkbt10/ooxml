///|
/// Part 1 §17.9 — resolve `(numId, ilvl)` to a `ResolvedLvl` by
/// chasing the num → abstractNum → optional numStyleLink chain. The
/// resolution order is, per §17.9.8 / §17.9.15:
///
/// 1. If the num carries a matching `lvlOverride` with a `lvl` body,
///    use it (origin = SourceOverride).
/// 2. If the num carries a matching `lvlOverride` with only
///    `startOverride`, return the abstract definition's lvl with
///    `start` replaced (origin = SourceOverride).
/// 3. Else, return the abstract definition's lvl (origin =
///    SourceAbstract).
/// 4. Else, if the abstract definition has `numStyleLink`, follow it
///    to another abstract definition whose `styleLink` matches and
///    return that definition's lvl (origin = SourceLinkedAbstract).
pub fn NumberingTable::resolve_level(
  self : NumberingTable,
  num_id : Int,
  ilvl : Int,
) -> ResolvedLvl? {
  let num = match self.nums.get(num_id) {
    Some(value) => value
    None => return None
  }
  for ovr in num.lvl_overrides {
    if ovr.ilvl == ilvl {
      match ovr.lvl {
        Some(lvl) => return Some({ lvl, origin: SourceOverride })
        None =>
          match ovr.start_override {
            Some(start_value) =>
              match self.find_abstract_lvl(num.abstract_num_id, ilvl) {
                Some(abs_lvl) =>
                  return Some({
                    lvl: { ..abs_lvl, start: Some(start_value) },
                    origin: SourceOverride,
                  })
                None => ()
              }
            None => ()
          }
      }
    }
  }
  match self.find_abstract_lvl(num.abstract_num_id, ilvl) {
    Some(lvl) => return Some({ lvl, origin: SourceAbstract })
    None => ()
  }
  let abs = match self.abstract_nums.get(num.abstract_num_id) {
    Some(value) => value
    None => return None
  }
  match abs.num_style_link {
    Some(style_id) =>
      match self.find_abstract_by_style_link(style_id) {
        Some(linked) =>
          match find_lvl(linked.lvls, ilvl) {
            Some(lvl) => Some({ lvl, origin: SourceLinkedAbstract })
            None => None
          }
        None => None
      }
    None => None
  }
}

///|
/// Return the abstract numbering definition referenced by `numId` (one
/// link hop). Used by clients that want to inspect the
/// `multiLevelType` or the full `lvls` array.
pub fn NumberingTable::abstract_for_num(
  self : NumberingTable,
  num_id : Int,
) -> AbstractNum? {
  let num = match self.nums.get(num_id) {
    Some(value) => value
    None => return None
  }
  self.abstract_nums.get(num.abstract_num_id)
}

///|
/// Find the abstract definition's lvl whose `ilvl` matches `target`.
/// Helper used by `resolve_level`.
fn NumberingTable::find_abstract_lvl(
  self : NumberingTable,
  abstract_num_id : Int,
  target : Int,
) -> Lvl? {
  let abs = match self.abstract_nums.get(abstract_num_id) {
    Some(value) => value
    None => return None
  }
  find_lvl(abs.lvls, target)
}

///|
fn NumberingTable::find_abstract_by_style_link(
  self : NumberingTable,
  style_id : String,
) -> AbstractNum? {
  let mut found : AbstractNum? = None
  for entry in self.abstract_nums {
    let (_, abs) = entry
    match abs.style_link {
      Some(link) => if link == style_id { found = Some(abs) }
      None => ()
    }
  }
  found
}

///|
fn find_lvl(lvls : Array[Lvl], target : Int) -> Lvl? {
  for lvl in lvls {
    if lvl.ilvl == target {
      return Some(lvl)
    }
  }
  None
}

///|
/// Convenience: read a paragraph's `numPr` (numId + ilvl) and return
/// the resolved level. `num_pr` is the `p:pPr/p:numPr` element from
/// §17.3.1.19; missing or malformed children yield `None`.
pub fn NumberingTable::level_for_paragraph(
  self : NumberingTable,
  num_pr : @xml.Element,
) -> ResolvedLvl? {
  let mut num_id_opt : Int? = None
  let mut ilvl_opt : Int? = None
  for child in num_pr.children {
    match child {
      @xml.Element(child_element) => {
        let local = child_element.name.local_name
        if local == "numId" {
          num_id_opt = paragraph_val_int(child_element)
        } else if local == "ilvl" {
          ilvl_opt = paragraph_val_int(child_element)
        }
      }
      _ => ()
    }
  }
  let num_id = match num_id_opt {
    Some(value) => value
    None => return None
  }
  let ilvl = match ilvl_opt {
    Some(value) => value
    None => 0
  }
  self.resolve_level(num_id, ilvl)
}

///|
fn paragraph_val_int(element : @xml.Element) -> Int? {
  match attr(element, "val") {
    Some(text) => parse_int(text)
    None => None
  }
}
