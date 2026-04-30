///|
/// XSD model group EG_PContentMath from wml.xsd (§17).
pub(all) struct EG_PContentMath {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_PContentMath::new(elements : Array[@xml.Element]) -> EG_PContentMath {
  { elements, }
}

///|
pub fn EG_PContentMath::count(self : EG_PContentMath) -> Int {
  self.elements.length()
}

///|
pub fn EG_PContentMath::contains(
  self : EG_PContentMath,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_PContentMath::member_names(self : EG_PContentMath) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_PContentBase from wml.xsd (§17).
pub(all) struct EG_PContentBase {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_PContentBase::new(elements : Array[@xml.Element]) -> EG_PContentBase {
  { elements, }
}

///|
pub fn EG_PContentBase::count(self : EG_PContentBase) -> Int {
  self.elements.length()
}

///|
pub fn EG_PContentBase::contains(
  self : EG_PContentBase,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_PContentBase::member_names(self : EG_PContentBase) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_ContentRunContentBase from wml.xsd (§17).
pub(all) struct EG_ContentRunContentBase {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_ContentRunContentBase::new(
  elements : Array[@xml.Element],
) -> EG_ContentRunContentBase {
  { elements, }
}

///|
pub fn EG_ContentRunContentBase::count(self : EG_ContentRunContentBase) -> Int {
  self.elements.length()
}

///|
pub fn EG_ContentRunContentBase::contains(
  self : EG_ContentRunContentBase,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_ContentRunContentBase::member_names(
  self : EG_ContentRunContentBase,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_CellMarkupElements from wml.xsd (§17).
pub(all) struct EG_CellMarkupElements {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_CellMarkupElements::new(
  elements : Array[@xml.Element],
) -> EG_CellMarkupElements {
  { elements, }
}

///|
pub fn EG_CellMarkupElements::count(self : EG_CellMarkupElements) -> Int {
  self.elements.length()
}

///|
pub fn EG_CellMarkupElements::contains(
  self : EG_CellMarkupElements,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_CellMarkupElements::member_names(
  self : EG_CellMarkupElements,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_RangeMarkupElements from wml.xsd (§17).
pub(all) struct EG_RangeMarkupElements {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_RangeMarkupElements::new(
  elements : Array[@xml.Element],
) -> EG_RangeMarkupElements {
  { elements, }
}

///|
pub fn EG_RangeMarkupElements::count(self : EG_RangeMarkupElements) -> Int {
  self.elements.length()
}

///|
pub fn EG_RangeMarkupElements::contains(
  self : EG_RangeMarkupElements,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_RangeMarkupElements::member_names(
  self : EG_RangeMarkupElements,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_HdrFtrReferences from wml.xsd (§17).
pub(all) struct EG_HdrFtrReferences {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_HdrFtrReferences::new(
  elements : Array[@xml.Element],
) -> EG_HdrFtrReferences {
  { elements, }
}

///|
pub fn EG_HdrFtrReferences::count(self : EG_HdrFtrReferences) -> Int {
  self.elements.length()
}

///|
pub fn EG_HdrFtrReferences::contains(
  self : EG_HdrFtrReferences,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_HdrFtrReferences::member_names(
  self : EG_HdrFtrReferences,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_SectPrContents from wml.xsd (§17).
pub(all) struct EG_SectPrContents {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_SectPrContents::new(
  elements : Array[@xml.Element],
) -> EG_SectPrContents {
  { elements, }
}

///|
pub fn EG_SectPrContents::count(self : EG_SectPrContents) -> Int {
  self.elements.length()
}

///|
pub fn EG_SectPrContents::contains(
  self : EG_SectPrContents,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_SectPrContents::member_names(
  self : EG_SectPrContents,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_RunInnerContent from wml.xsd (§17).
pub(all) struct EG_RunInnerContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_RunInnerContent::new(
  elements : Array[@xml.Element],
) -> EG_RunInnerContent {
  { elements, }
}

///|
pub fn EG_RunInnerContent::count(self : EG_RunInnerContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_RunInnerContent::contains(
  self : EG_RunInnerContent,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_RunInnerContent::member_names(
  self : EG_RunInnerContent,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_RPrBase from wml.xsd (§17).
pub(all) struct EG_RPrBase {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_RPrBase::new(elements : Array[@xml.Element]) -> EG_RPrBase {
  { elements, }
}

///|
pub fn EG_RPrBase::count(self : EG_RPrBase) -> Int {
  self.elements.length()
}

///|
pub fn EG_RPrBase::contains(self : EG_RPrBase, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_RPrBase::member_names(self : EG_RPrBase) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_RPrContent from wml.xsd (§17).
pub(all) struct EG_RPrContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_RPrContent::new(elements : Array[@xml.Element]) -> EG_RPrContent {
  { elements, }
}

///|
pub fn EG_RPrContent::count(self : EG_RPrContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_RPrContent::contains(
  self : EG_RPrContent,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_RPrContent::member_names(self : EG_RPrContent) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_RPr from wml.xsd (§17).
pub(all) struct EG_RPr {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_RPr::new(elements : Array[@xml.Element]) -> EG_RPr {
  { elements, }
}

///|
pub fn EG_RPr::count(self : EG_RPr) -> Int {
  self.elements.length()
}

///|
pub fn EG_RPr::contains(self : EG_RPr, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_RPr::member_names(self : EG_RPr) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_RPrMath from wml.xsd (§17).
pub(all) struct EG_RPrMath {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_RPrMath::new(elements : Array[@xml.Element]) -> EG_RPrMath {
  { elements, }
}

///|
pub fn EG_RPrMath::count(self : EG_RPrMath) -> Int {
  self.elements.length()
}

///|
pub fn EG_RPrMath::contains(self : EG_RPrMath, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_RPrMath::member_names(self : EG_RPrMath) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_ParaRPrTrackChanges from wml.xsd (§17).
pub(all) struct EG_ParaRPrTrackChanges {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_ParaRPrTrackChanges::new(
  elements : Array[@xml.Element],
) -> EG_ParaRPrTrackChanges {
  { elements, }
}

///|
pub fn EG_ParaRPrTrackChanges::count(self : EG_ParaRPrTrackChanges) -> Int {
  self.elements.length()
}

///|
pub fn EG_ParaRPrTrackChanges::contains(
  self : EG_ParaRPrTrackChanges,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_ParaRPrTrackChanges::member_names(
  self : EG_ParaRPrTrackChanges,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_RubyContent from wml.xsd (§17).
pub(all) struct EG_RubyContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_RubyContent::new(elements : Array[@xml.Element]) -> EG_RubyContent {
  { elements, }
}

///|
pub fn EG_RubyContent::count(self : EG_RubyContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_RubyContent::contains(
  self : EG_RubyContent,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_RubyContent::member_names(self : EG_RubyContent) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_ContentRunContent from wml.xsd (§17).
pub(all) struct EG_ContentRunContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_ContentRunContent::new(
  elements : Array[@xml.Element],
) -> EG_ContentRunContent {
  { elements, }
}

///|
pub fn EG_ContentRunContent::count(self : EG_ContentRunContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_ContentRunContent::contains(
  self : EG_ContentRunContent,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_ContentRunContent::member_names(
  self : EG_ContentRunContent,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_ContentBlockContent from wml.xsd (§17).
pub(all) struct EG_ContentBlockContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_ContentBlockContent::new(
  elements : Array[@xml.Element],
) -> EG_ContentBlockContent {
  { elements, }
}

///|
pub fn EG_ContentBlockContent::count(self : EG_ContentBlockContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_ContentBlockContent::contains(
  self : EG_ContentBlockContent,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_ContentBlockContent::member_names(
  self : EG_ContentBlockContent,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_ContentRowContent from wml.xsd (§17).
pub(all) struct EG_ContentRowContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_ContentRowContent::new(
  elements : Array[@xml.Element],
) -> EG_ContentRowContent {
  { elements, }
}

///|
pub fn EG_ContentRowContent::count(self : EG_ContentRowContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_ContentRowContent::contains(
  self : EG_ContentRowContent,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_ContentRowContent::member_names(
  self : EG_ContentRowContent,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_ContentCellContent from wml.xsd (§17).
pub(all) struct EG_ContentCellContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_ContentCellContent::new(
  elements : Array[@xml.Element],
) -> EG_ContentCellContent {
  { elements, }
}

///|
pub fn EG_ContentCellContent::count(self : EG_ContentCellContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_ContentCellContent::contains(
  self : EG_ContentCellContent,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_ContentCellContent::member_names(
  self : EG_ContentCellContent,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_PContent from wml.xsd (§17).
pub(all) struct EG_PContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_PContent::new(elements : Array[@xml.Element]) -> EG_PContent {
  { elements, }
}

///|
pub fn EG_PContent::count(self : EG_PContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_PContent::contains(self : EG_PContent, local_name : String) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_PContent::member_names(self : EG_PContent) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_FtnEdnNumProps from wml.xsd (§17).
pub(all) struct EG_FtnEdnNumProps {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_FtnEdnNumProps::new(
  elements : Array[@xml.Element],
) -> EG_FtnEdnNumProps {
  { elements, }
}

///|
pub fn EG_FtnEdnNumProps::count(self : EG_FtnEdnNumProps) -> Int {
  self.elements.length()
}

///|
pub fn EG_FtnEdnNumProps::contains(
  self : EG_FtnEdnNumProps,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_FtnEdnNumProps::member_names(
  self : EG_FtnEdnNumProps,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_MathContent from wml.xsd (§17).
pub(all) struct EG_MathContent {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_MathContent::new(elements : Array[@xml.Element]) -> EG_MathContent {
  { elements, }
}

///|
pub fn EG_MathContent::count(self : EG_MathContent) -> Int {
  self.elements.length()
}

///|
pub fn EG_MathContent::contains(
  self : EG_MathContent,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_MathContent::member_names(self : EG_MathContent) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_BlockLevelChunkElts from wml.xsd (§17).
pub(all) struct EG_BlockLevelChunkElts {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_BlockLevelChunkElts::new(
  elements : Array[@xml.Element],
) -> EG_BlockLevelChunkElts {
  { elements, }
}

///|
pub fn EG_BlockLevelChunkElts::count(self : EG_BlockLevelChunkElts) -> Int {
  self.elements.length()
}

///|
pub fn EG_BlockLevelChunkElts::contains(
  self : EG_BlockLevelChunkElts,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_BlockLevelChunkElts::member_names(
  self : EG_BlockLevelChunkElts,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_BlockLevelElts from wml.xsd (§17).
pub(all) struct EG_BlockLevelElts {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_BlockLevelElts::new(
  elements : Array[@xml.Element],
) -> EG_BlockLevelElts {
  { elements, }
}

///|
pub fn EG_BlockLevelElts::count(self : EG_BlockLevelElts) -> Int {
  self.elements.length()
}

///|
pub fn EG_BlockLevelElts::contains(
  self : EG_BlockLevelElts,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_BlockLevelElts::member_names(
  self : EG_BlockLevelElts,
) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}

///|
/// XSD model group EG_RunLevelElts from wml.xsd (§17).
pub(all) struct EG_RunLevelElts {
  elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn EG_RunLevelElts::new(elements : Array[@xml.Element]) -> EG_RunLevelElts {
  { elements, }
}

///|
pub fn EG_RunLevelElts::count(self : EG_RunLevelElts) -> Int {
  self.elements.length()
}

///|
pub fn EG_RunLevelElts::contains(
  self : EG_RunLevelElts,
  local_name : String,
) -> Bool {
  let mut found = false
  for element in self.elements {
    if element.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
pub fn EG_RunLevelElts::member_names(self : EG_RunLevelElts) -> Array[String] {
  let names = []
  for element in self.elements {
    names.push(element.name.local_name)
  }
  names
}
