# G9 WordprocessingML Style Inheritance Design

## Package

`src/ecma376/wordprocessing_ml/style_resolver` is a self-contained
WordprocessingML package. It depends only on OPC errors, XML DOM types, and the
WordprocessingML domain wrappers.

## Typed View

`Style::from_element` turns a raw `<w:style>` element into a typed `Style`.
The resolver reads XML by local names because the XML reader has already
resolved namespaces and the WordprocessingML wrappers preserve the original DOM.

`StyleTable::from_element` indexes styles by `styleId.value` in a
`HashMap[String, Style]` and stores `docDefaults/pPrDefault/pPr` and
`docDefaults/rPrDefault/rPr` for implicit inheritance.

## Inheritance

`resolve_chain` starts at the requested style id and follows `basedOn`. It
returns the visited style objects from most-derived to root. Missing bases stop
resolution without error. A visited id map prevents cycles; for `A -> B -> A`,
the returned chain is `A, B`.

`effective_properties` applies the chain in reverse order so roots are merged
first and derived styles override base properties. `docDefaults` are applied
before the style chain for paragraph and run properties.

## Merge Rule

Property containers are merged at the child element level. The resulting
container keeps the base container's element name and attributes, then groups
children by `name.local_name`. If a derived container defines the same child
local name, the derived child replaces the base child; otherwise the base child
is retained. This is sufficient for current renderer consumers.

ECMA-376 has some additive nested properties, such as `w:tabs/w:tab` entries
that should merge by attributes such as `w:pos`. This G9 implementation
deliberately performs child-element replacement only; callers needing full
additive collection behavior should add that as a follow-up spec-driven change.

## Direct Formatting

`resolve_paragraph` reads `w:pStyle/@w:val` from direct paragraph properties,
resolves that style, and overlays the direct `pPr`. `resolve_run` does the same
for `w:rStyle/@w:val` and direct `rPr`.
