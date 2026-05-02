# XML Escape SoT Design

## Ownership

`src/xml/` owns XML serialization primitives because XML 1.0 and Canonical XML
1.0 are W3C concepts below the ECMA-376 layer. The XML package remains
independent of `src/ecma376/`; ECMA-376 packages may depend on `@xml`, but `@xml`
does not depend on ECMA-376 packages.

## Public API

- `escape_text(value : String) -> String`
  - Existing writer behavior made public.
  - Escapes `&`, `<`, and splits `]]>` to `]]&gt;`.
- `escape_attribute(value : String) -> String`
  - Existing writer behavior made public.
  - Escapes all five XML predefined entities.
- `escape_attribute_c14n(value : String) -> String`
  - Moved from OPC digital signature canonicalization.
  - Escapes `&`, `<`, `"`, tab, LF, and CR per W3C C14N §2.3.
- `escape_text_c14n(value : String) -> String`
  - Moved from OPC digital signature canonicalization.
  - Escapes `&`, `<`, `>`, and CR per W3C C14N §2.3.
- `is_xml_char(ch : Char) -> Bool`
  - Implements the XML 1.0 §2.2 Char production over codepoints.

## Migration

The document facades use `@xml.escape_text` for minimal HTML/SVG labels where
they previously had identical local three-entity escapers. OPC digital
signature canonicalization uses the new `@xml.escape_attribute_c14n` and
`@xml.escape_text_c14n` functions with no behavior change.

Generated interfaces are updated with `moon info`.
