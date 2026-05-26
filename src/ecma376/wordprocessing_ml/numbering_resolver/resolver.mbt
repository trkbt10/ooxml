// Part 1 §17.9 numbering inheritance: num -> abstractNum -> lvl
// resolution with §17.9.8 lvlOverride wins and §17.9.21 numStyleLink
// follow-up. Operates on `@domain.CT_Numbering` typed view.
//
// These resolvers are free functions because §17.9 resolution is an
// evaluator concern, not a spec-defined CT_Numbering operation; the
// CT_* typed views in `@domain` only carry the inline-decoded child
// state.

///|
/// Part 1 §17.9 — resolve `(numId, ilvl)` to a `ResolvedLvl` by
/// chasing the num -> abstractNum -> optional numStyleLink chain. The
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
pub fn resolve_level(
  table : @domain.CT_Numbering,
  num_id : Int,
  ilvl : Int,
) -> ResolvedLvl? {
  let num = match table.nums.get(num_id) {
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
              match find_abstract_lvl(table, num.abstract_num_id, ilvl) {
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
  match find_abstract_lvl(table, num.abstract_num_id, ilvl) {
    Some(lvl) => return Some({ lvl, origin: SourceAbstract })
    None => ()
  }
  let abs = match table.abstract_nums.get(num.abstract_num_id) {
    Some(value) => value
    None => return None
  }
  // §17.9.21 numStyleLink — the spec permits chains of
  // `numStyleLink` references (style A → abstract X →
  // numStyleLink → style B → abstract Y → …).  Walk the chain
  // iteratively, terminating when we reach an abstract that
  // carries a concrete lvl for the requested `ilvl` (or runs
  // out of numStyleLink links).  Cycle detection: keep a set
  // of visited abstractNumId values and stop if we revisit one
  // — pathological numbering parts with mutual style links
  // would otherwise loop forever.  §17.9.15 `lvlOverride`s on
  // the referring num still apply via the early-return at the
  // top of `find_lvl` above; we explicitly re-apply nothing in
  // the linked path because lvlOverrides are gated by the
  // original num's id, not the linked abstract.
  let visited : Map[Int, Unit] = Map([], capacity=0)
  visited.set(abs.abstract_num_id, ())
  let mut cursor = abs
  while true {
    match cursor.num_style_link {
      None => return None
      Some(style_id) =>
        match find_abstract_by_style_link(table, style_id) {
          None => return None
          Some(linked) => {
            if visited.contains(linked.abstract_num_id) {
              // Cycle — give up.
              return None
            }
            visited.set(linked.abstract_num_id, ())
            match find_lvl(linked.lvls, ilvl) {
              Some(lvl) => return Some({ lvl, origin: SourceLinkedAbstract })
              None => cursor = linked
            }
          }
        }
    }
  }
  // Unreachable, but the compiler insists on a tail expression.
  None
}

///|
/// Return the abstract numbering definition referenced by `numId` (one
/// link hop). Used by clients that want to inspect the
/// `multiLevelType` or the full `lvls` array.
pub fn abstract_for_num(
  table : @domain.CT_Numbering,
  num_id : Int,
) -> @domain.CT_AbstractNum? {
  let num = match table.nums.get(num_id) {
    Some(value) => value
    None => return None
  }
  table.abstract_nums.get(num.abstract_num_id)
}

///|
/// Find the abstract definition's lvl whose `ilvl` matches `target`.
/// Helper used by `resolve_level`.
fn find_abstract_lvl(
  table : @domain.CT_Numbering,
  abstract_num_id : Int,
  target : Int,
) -> @domain.CT_Lvl? {
  let abs = match table.abstract_nums.get(abstract_num_id) {
    Some(value) => value
    None => return None
  }
  find_lvl(abs.lvls, target)
}

///|
fn find_abstract_by_style_link(
  table : @domain.CT_Numbering,
  style_id : String,
) -> @domain.CT_AbstractNum? {
  let mut found : @domain.CT_AbstractNum? = None
  for entry in table.abstract_nums {
    let (_, abs) = entry
    match abs.style_link {
      Some(link) => if link == style_id { found = Some(abs) }
      None => ()
    }
  }
  found
}

///|
fn find_lvl(lvls : Array[@domain.CT_Lvl], target : Int) -> @domain.CT_Lvl? {
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
pub fn level_for_paragraph(
  table : @domain.CT_Numbering,
  num_pr : @xml.Element,
) -> ResolvedLvl? {
  let mut num_id_opt : Int? = None
  let mut ilvl_opt : Int? = None
  for child in num_pr.children {
    match child {
      @xml.Element(child_element) => {
        let local_name = child_element.name.local_name
        if local_name == "numId" {
          num_id_opt = paragraph_val_int(child_element)
        } else if local_name == "ilvl" {
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
  resolve_level(table, num_id, ilvl)
}

///|
fn paragraph_val_int(element : @xml.Element) -> Int? {
  for a in element.attributes {
    if a.name.local_name == "val" {
      return @domain.numbering_parse_int(a.value)
    }
  }
  None
}
