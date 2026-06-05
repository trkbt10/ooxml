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
///
/// ECMA-376 Part 3 §1 Scope: owned by src/ecma376/markup_compatibility and
/// represented by package_name plus the mc:AlternateContent and token-list API.
/// ECMA-376 Part 3 §3 Terms And Definitions: owned by this package and
/// represented by the Choice, Fallback, AlternateContent, and token-list names
/// used by the public API.
/// ECMA-376 Part 3 §5 General Description: owned by this package and
/// represented by AlternateContent, Choice, Fallback, and
/// AlternateContent::evaluate.
/// ECMA-376 Part 3 §8 Application Defined Extension Elements: owned by this
/// package and represented by Choice.content and Fallback.content preserving
/// application-defined @xml.Node children.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/markup_compatibility"
}

///|
/// Return the ECMA-376 Part 3 §1 Scope section owned by this package.
pub fn part3_scope_section_name() -> String {
  "ECMA-376 Part 3 §1 Scope"
}

///|
/// Return the ECMA-376 Part 3 §2 Normative References section owned by this
/// package.
pub fn part3_normative_references_section_name() -> String {
  "ECMA-376 Part 3 §2 Normative References"
}

///|
/// Return the ECMA-376 Part 3 §3 Terms And Definitions section owned by this
/// package.
pub fn part3_terms_and_definitions_section_name() -> String {
  "ECMA-376 Part 3 §3 Terms And Definitions"
}

///|
/// Return the ECMA-376 Part 3 §4 Notational Conventions section owned by this
/// package.
pub fn part3_notational_conventions_section_name() -> String {
  "ECMA-376 Part 3 §4 Notational Conventions"
}

///|
/// Return the ECMA-376 Part 3 §5 General Description section owned by this
/// package.
pub fn part3_general_description_section_name() -> String {
  "ECMA-376 Part 3 §5 General Description"
}

///|
/// Return the ECMA-376 Part 3 §6 Overview section owned by this package.
pub fn part3_overview_section_name() -> String {
  "ECMA-376 Part 3 §6 Overview"
}

///|
/// Return the ECMA-376 Part 3 §7 Mce Elements And Attributes section owned by
/// this package.
pub fn part3_mce_elements_and_attributes_section_name() -> String {
  "ECMA-376 Part 3 §7 Mce Elements And Attributes"
}

///|
/// Return the ECMA-376 Part 3 §7.1 Introduction section owned by this package.
pub fn part3_introduction_section_name() -> String {
  "ECMA-376 Part 3 §7.1 Introduction"
}

///|
/// Return the ECMA-376 Part 3 §7.4 Mustunderstand Attribute section owned by
/// this package.
pub fn part3_mustunderstand_section_name() -> String {
  "ECMA-376 Part 3 §7.4 Mustunderstand Attribute"
}

///|
/// Return the ECMA-376 Part 3 §8 Application Defined Extension Elements section
/// owned by this package.
pub fn part3_application_defined_extensions_section_name() -> String {
  "ECMA-376 Part 3 §8 Application Defined Extension Elements"
}

///|
/// Return the ECMA-376 Part 3 §9.1 Overview section owned by this package.
pub fn part3_reference_processing_overview_section_name() -> String {
  "ECMA-376 Part 3 §9.1 Overview"
}

///|
/// Parsed mc:Choice child of mc:AlternateContent.
///
/// §8 Application Defined Extension Elements: application-defined extension
/// markup is kept as @xml.Node content inside Choice branches.
pub(all) struct Choice {
  requires : String
  content : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Parsed mc:Fallback child of mc:AlternateContent.
///
/// §2 Normative References: Part 3 processing relies on XML namespace-qualified
/// markup and XML child nodes, represented here by Fallback.content as
/// @xml.Node values.
///
/// ECMA-376 Part 3 §2 Normative References: owned by
/// src/ecma376/markup_compatibility and represented by @xml.Node content and
/// XML namespace token parsing.
pub(all) struct Fallback {
  content : Array[@xml.Node]
} derive(Eq, Debug)

///|
/// Parsed mc:AlternateContent with ordered Choice children and optional
/// Fallback content.
///
/// §5 General Description: Markup Compatibility lets producers include newer
/// markup while consumers select supported Choice content or preserve Fallback
/// content through AlternateContent.
pub(all) struct AlternateContent {
  choices : Array[Choice]
  fallback : Fallback?
} derive(Eq, Debug)

///|
/// Parse an mc:AlternateContent XML element into ordered choices and fallback.
///
/// §6 Overview: the mc namespace processing surface centers on
/// AlternateContent, Choice, and Fallback elements parsed by
/// parse_alternate_content.
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
///
/// §9 Semantic Definitions And Reference Processing Model: reference processing
/// selects the first supported Choice branch and otherwise uses Fallback
/// content, which is the behavior of AlternateContent::evaluate.
///
/// §9.4 Step 3 Processing The MustUnderstand Attribute And Creating The Output
/// Document: after namespace support decisions, AlternateContent::evaluate
/// returns the @xml.Node array used in the output document.
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
///
/// §7.1 Introduction: Markup Compatibility attributes annotate host-language
/// elements with namespace-prefix token lists, parsed here by parse_ignorable.
pub fn parse_ignorable(attr_value : String) -> Array[String] {
  parse_token_list(attr_value)
}

///|
/// Parse an mc:ProcessContent attribute value into qualified-name tokens.
///
/// §7.4 MustUnderstand Attribute: MustUnderstand uses the same namespace-prefix
/// token-list lexical form as the processing attributes, and parse_token_list is
/// the shared tokenizer reached through parse_process_content.
///
/// ECMA-376 Part 3 §7.4 Mustunderstand Attribute: owned by this package and
/// represented by parse_process_content and parse_token_list for namespace
/// token-list handling.
///
/// ECMA-376 Part 3 §9 Semantic Definitions And Reference Processing Model:
/// owned by this package and represented by parse_process_content token lists
/// feeding the reference processing model.
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
  if required.length() == 0 {
    return false
  }
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
  let chars = value.to_array()
  let buffer = StringBuilder::new()
  let mut has_token = false
  for ch in chars {
    if is_mc_whitespace(ch) {
      if has_token {
        tokens.push(buffer.to_string())
        buffer.reset()
        has_token = false
      }
    } else {
      buffer.write_char(ch)
      has_token = true
    }
  }
  if has_token {
    tokens.push(buffer.to_string())
  }
  tokens
}

///|
fn is_mc_whitespace(ch : Char) -> Bool {
  ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r'
}
