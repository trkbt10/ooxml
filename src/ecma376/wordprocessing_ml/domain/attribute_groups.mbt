///|
/// XSD attribute group AG_Password from wml.xsd (§17).
pub(all) struct AG_Password {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Password::new(element : @xml.Element) -> AG_Password {
  { element, }
}

///|
pub fn AG_Password::attribute_names(self : AG_Password) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_Password::has_attribute(
  self : AG_Password,
  local_name : String,
) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// XSD attribute group AG_SectPrAttributes from wml.xsd (§17).
pub(all) struct AG_SectPrAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_SectPrAttributes::new(element : @xml.Element) -> AG_SectPrAttributes {
  { element, }
}

///|
pub fn AG_SectPrAttributes::attribute_names(
  self : AG_SectPrAttributes,
) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_SectPrAttributes::has_attribute(
  self : AG_SectPrAttributes,
  local_name : String,
) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}
