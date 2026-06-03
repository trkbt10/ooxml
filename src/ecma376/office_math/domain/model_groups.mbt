///|
/// Schema shared-math.xsd model group EG_ScriptStyle with scr CT_Script and
/// sty CT_Style children (§22.1.x).
/// OMML script style model group with optional scr CT_Script and sty CT_Style children.
pub(all) struct EG_ScriptStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct EG_ScriptStyle from the XML element carrying the group content.
pub fn EG_ScriptStyle::new(element : @xml.Element) -> EG_ScriptStyle {
  { element, }
}

///|
/// Construct XSD model group EG_ScriptStyle (§22.1.x).
pub fn eg_script_style(element : @xml.Element) -> EG_ScriptStyle {
  EG_ScriptStyle::new(element)
}

///|
/// Return EG_ScriptStyle child names for scr CT_Script and sty CT_Style.
pub fn EG_ScriptStyle::child_names(self : EG_ScriptStyle) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    match child {
      Element(element) =>
        match element.name.local_name {
          "scr" | "sty" => names.push(element.name.local_name)
          _ => ()
        }
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_OMathMathElements (§22.1.x).
/// OMML math-element model group choice over CT_Acc, CT_Bar, CT_Box,
/// CT_BorderBox, CT_D, CT_EqArr, CT_F, CT_Func, CT_GroupChr, CT_LimLow,
/// CT_LimUpp, CT_M, CT_Nary, CT_Phant, CT_Rad, script objects, and CT_R.
pub(all) struct EG_OMathMathElements {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct EG_OMathMathElements from the XML element selected by the group.
pub fn EG_OMathMathElements::new(
  element : @xml.Element,
) -> EG_OMathMathElements {
  { element, }
}

///|
/// Parse EG_OMathMathElements by validating the selected OMML math arm.
pub fn EG_OMathMathElements::parse(
  element : @xml.Element,
) -> EG_OMathMathElements raise SchemaViolation {
  match element.name.local_name {
    "acc" => {
      let _ = CT_Acc::new(element)
    }
    "bar" => {
      let _ = CT_Bar::new(element)
    }
    "box" => {
      let _ = CT_Box::new(element)
    }
    "borderBox" => {
      let _ = CT_BorderBox::new(element)
    }
    "d" => {
      let _ = CT_D::new(element)
    }
    "eqArr" => {
      let _ = CT_EqArr::new(element)
    }
    "f" => {
      let _ = CT_F::new(element)
    }
    "func" => {
      let _ = CT_Func::new(element)
    }
    "groupChr" => {
      let _ = CT_GroupChr::new(element)
    }
    "limLow" => {
      let _ = CT_LimLow::new(element)
    }
    "limUpp" => {
      let _ = CT_LimUpp::new(element)
    }
    "m" => {
      let _ = CT_M::new(element)
    }
    "nary" => {
      let _ = CT_Nary::new(element)
    }
    "phant" => {
      let _ = CT_Phant::new(element)
    }
    "rad" => {
      let _ = CT_Rad::new(element)
    }
    "sPre" => {
      let _ = CT_SPre::new(element)
    }
    "sSub" => {
      let _ = CT_SSub::new(element)
    }
    "sSubSup" => {
      let _ = CT_SSubSup::new(element)
    }
    "sSup" => {
      let _ = CT_SSup::new(element)
    }
    "r" => {
      let _ = CT_R::new(element)
    }
    other =>
      raise SchemaViolation(type_name="EG_OMathMathElements", value=other)
  }
  { element, }
}

///|
/// Construct XSD model group EG_OMathMathElements (§22.1.x).
pub fn eg_o_math_math_elements(element : @xml.Element) -> EG_OMathMathElements {
  EG_OMathMathElements::new(element)
}

///|
/// Return the local element name selected by this math-element model group.
pub fn EG_OMathMathElements::selected_name(
  self : EG_OMathMathElements,
) -> String {
  let name = self.element.name.local_name
  match name {
    "acc"
    | "bar"
    | "box"
    | "borderBox"
    | "d"
    | "eqArr"
    | "f"
    | "func"
    | "groupChr"
    | "limLow"
    | "limUpp"
    | "m"
    | "nary"
    | "phant"
    | "rad"
    | "sPre"
    | "sSub"
    | "sSubSup"
    | "sSup"
    | "r" => name
    other => other
  }
}

///|
/// Return nested XML element children carried by the selected math element.
pub fn EG_OMathMathElements::child_elements(
  self : EG_OMathMathElements,
) -> Array[@xml.Element] {
  let children : Array[@xml.Element] = []
  for child in self.element.children {
    match child {
      Element(element) => children.push(element)
      _ => ()
    }
  }
  children
}

///|
/// XSD model group EG_OMathElements (§22.1.x).
/// OMML model group combining EG_OMathMathElements and w:EG_PContentMath.
pub(all) struct EG_OMathElements {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct EG_OMathElements from the XML element selected by the group.
pub fn EG_OMathElements::new(element : @xml.Element) -> EG_OMathElements {
  { element, }
}

///|
/// Parse EG_OMathElements, validating OMML math arms and preserving
/// non-OMML paragraph content for the WordprocessingML-owned side of
/// the choice.
pub fn EG_OMathElements::parse(
  element : @xml.Element,
) -> EG_OMathElements raise SchemaViolation {
  let group = EG_OMathElements::new(element)
  if group.is_math_element() {
    let _ = EG_OMathMathElements::parse(element)
  }
  group
}

///|
/// Construct XSD model group EG_OMathElements (§22.1.x).
pub fn eg_o_math_elements(element : @xml.Element) -> EG_OMathElements {
  EG_OMathElements::new(element)
}

///|
/// Classify this oMath child as OMML math or paragraph content by local name.
pub fn EG_OMathElements::is_math_element(self : EG_OMathElements) -> Bool {
  match self.element.name.local_name {
    "acc"
    | "bar"
    | "box"
    | "borderBox"
    | "d"
    | "eqArr"
    | "f"
    | "func"
    | "groupChr"
    | "limLow"
    | "limUpp"
    | "m"
    | "nary"
    | "phant"
    | "rad"
    | "sPre"
    | "sSub"
    | "sSubSup"
    | "sSup"
    | "r" => true
    _ => false
  }
}

///|
/// Return the selected math element when this group member is an OMML object.
pub fn EG_OMathElements::math_element(
  self : EG_OMathElements,
) -> EG_OMathMathElements? {
  if self.is_math_element() {
    Some(EG_OMathMathElements::new(self.element))
  } else {
    None
  }
}
