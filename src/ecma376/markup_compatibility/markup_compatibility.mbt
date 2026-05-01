///|
/// ECMA-376 Part 3 Markup Compatibility and Extensibility.
///
/// This package implements the core compatibility processing surface for
/// mc:AlternateContent (§7.5), mc:Choice (§7.6), mc:Fallback (§7.7), and the
/// token-list attributes used by the Part 3 processing model: Ignorable and
/// ProcessContent (§9.2), PreserveAttributes/PreserveElements, and
/// AlternateContent choice evaluation (§9.3).
///
/// §3 TOC coverage from .kiro/specs/ecma376/markup_compatibility/coverage.json
/// includes Part 3 §1-§6, §7.1, §7.4-§7.7, §8, and §9.1-§9.4.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/markup_compatibility"
}

///|
/// Parsed mc:Choice child of mc:AlternateContent.
pub(all) struct Choice {
  requires : String
  content : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Parsed mc:Fallback child of mc:AlternateContent.
pub(all) struct Fallback {
  content : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Parsed mc:AlternateContent with ordered Choice children and optional
/// Fallback content.
pub(all) struct AlternateContent {
  choices : Array[Choice]
  fallback : Fallback?
} derive(Eq, Debug)

///|
/// Parse an mc:AlternateContent XML element into ordered choices and fallback.
pub fn parse_alternate_content(element : @xml.Element) -> AlternateContent {
  let choices : Array[Choice] = []
  let mut fallback : Fallback? = None
  for child in element.children {
    match child {
      Element(element) =>
        if element.name.local_name == "Choice" {
          choices.push({
            requires: optional_attribute(element, "Requires"),
            content: element.children,
          })
        } else if element.name.local_name == "Fallback" {
          fallback = Some({ content: element.children })
        }
      _ => ()
    }
  }
  { choices, fallback }
}

///|
/// Evaluate AlternateContent against supported namespace prefixes.
///
/// Returns the first Choice whose Requires token list is wholly supported, or
/// the Fallback content when no Choice matches.
pub fn AlternateContent::evaluate(
  self : AlternateContent,
  supported_namespaces : Array[String],
) -> Array[@xml.Node] {
  for choice in self.choices {
    if all_supported(parse_token_list(choice.requires), supported_namespaces) {
      return choice.content
    }
  }
  match self.fallback {
    Some(fallback) => fallback.content
    None => []
  }
}

///|
/// Parse an mc:Ignorable attribute value into namespace-prefix tokens.
pub fn parse_ignorable(attr_value : String) -> Array[String] {
  parse_token_list(attr_value)
}

///|
/// Parse an mc:ProcessContent attribute value into qualified-name tokens.
pub fn parse_process_content(attr_value : String) -> Array[String] {
  parse_token_list(attr_value)
}

///|
/// Parse an mc:PreserveAttributes attribute value into qualified-name tokens.
pub fn parse_preserve_attributes(attr_value : String) -> Array[String] {
  parse_token_list(attr_value)
}

///|
/// Parse an mc:PreserveElements attribute value into qualified-name tokens.
pub fn parse_preserve_elements(attr_value : String) -> Array[String] {
  parse_token_list(attr_value)
}

///|
fn optional_attribute(element : @xml.Element, local_name : String) -> String {
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return attr.value
    }
  }
  ""
}

///|
fn all_supported(required : Array[String], supported : Array[String]) -> Bool {
  let mut ok = true
  for token in required {
    if !supported.contains(token) {
      ok = false
    }
  }
  ok
}

///|
fn parse_token_list(value : String) -> Array[String] {
  let tokens : Array[String] = []
  for token in value.trim().split(" ") {
    let clean = token.trim().to_owned()
    if clean != "" {
      tokens.push(clean)
    }
  }
  tokens
}
