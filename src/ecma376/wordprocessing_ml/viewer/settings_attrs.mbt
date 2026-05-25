// ECMA-376 Part 1 §17.15 (Settings) -> SVG root `data-ooxml-*`
// attribute projection.
//
// Most `<w:settings>` children are non-visual document metadata
// (track-revisions toggle, default tab stop, document-protection
// state, theme colour map, mail-merge descriptor, etc.). The
// renderer surfaces each present element as a `data-ooxml-*`
// attribute on the root `<svg>` so spec-aware consumers can
// inspect the document metadata without re-walking the package,
// and so a renderer differential check (catalog/tests) can detect
// the element's presence vs. absence.

///|
/// Project the top-level settings declared in `/word/settings.xml`
/// onto a flat attribute list, in spec-canonical declaration order
/// where it matters (so adjacent values stay grouped in the SVG
/// header). When `settings` is `None` the function returns an
/// empty array — the renderer then emits no settings metadata.
///
/// Each present element contributes ONE attribute whose name is
/// `data-ooxml-settings-<localname>` and whose value is either the
/// element's primary `@val` (for the typed wrapper CTs) or `"1"`
/// (for the bare on/off toggles).  Sub-attributes that the spec
/// surfaces separately (e.g. `<w:documentProtection w:edit="...">`)
/// receive their own `data-ooxml-settings-<el>-<attr>` entry so
/// consumers do not have to re-parse the wrapper value.
///
/// `<w:embedTrueTypeFonts>` is per spec a CT_OnOff toggle in
/// settings.xml (§17.8.1.2). `<w:docDefaults>` lives in
/// `/word/styles.xml` (§17.7.5.1) so it is surfaced from the styles
/// part rather than here.
fn settings_data_attrs(
  settings : @domain.CT_Settings?,
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  let s = match settings {
    Some(s) => s
    None => return attrs
  }
  // §17.15.1.93 `<w:view>` — view mode.
  match s.view {
    Some(v) =>
      attrs.push(
        @markup.attr("data-ooxml-settings-view", v.val.to_string()),
      )
    None => ()
  }
  // §17.15.1.25 `<w:defaultTabStop>` — twips.
  match s.default_tab_stop {
    Some(t) =>
      attrs.push(
        @markup.attr("data-ooxml-settings-default-tab-stop", t.val),
      )
    None => ()
  }
  // §17.15.1.11 `<w:autoHyphenation>` — toggle.
  on_off_attr(attrs, s.auto_hyphenation, "auto-hyphenation")
  // §17.15.1.34 `<w:doNotHyphenateCaps>`.
  on_off_attr(attrs, s.do_not_hyphenate_caps, "do-not-hyphenate-caps")
  // §17.15.1.18 `<w:consecutiveHyphenLimit>` — integer count.
  match s.consecutive_hyphen_limit {
    Some(d) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-consecutive-hyphen-limit", d.val.to_string(),
        ),
      )
    None => ()
  }
  // §17.15.1.49 `<w:hyphenationZone>` — twips.
  match s.hyphenation_zone {
    Some(t) =>
      attrs.push(
        @markup.attr("data-ooxml-settings-hyphenation-zone", t.val),
      )
    None => ()
  }
  // §17.15.1.89 `<w:trackRevisions>` — toggle.
  on_off_attr(attrs, s.track_revisions, "track-revisions")
  // §17.15.1.29 `<w:documentProtection>` — surface the sub-attributes
  // separately so consumers do not need to re-parse the wrapper.
  match s.document_protection {
    Some(dp) => {
      attrs.push(@markup.attr("data-ooxml-settings-document-protection", "1"))
      match dp.edit {
        Some(e) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-document-protection-edit", e.to_string(),
            ),
          )
        None => ()
      }
      match dp.formatting {
        Some(v) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-document-protection-formatting",
              if v { "1" } else { "0" },
            ),
          )
        None => ()
      }
      match dp.enforcement {
        Some(v) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-document-protection-enforcement",
              if v { "1" } else { "0" },
            ),
          )
        None => ()
      }
    }
    None => ()
  }
  // §17.15.1.6 `<w:attachedTemplate r:id="..."/>`.
  match s.attached_template {
    Some(rel) =>
      attrs.push(
        @markup.attr("data-ooxml-settings-attached-template", rel.r_id),
      )
    None => ()
  }
  // §17.15.1.14 `<w:clrSchemeMapping>` — surface each mapping slot
  // that the document explicitly bound; absent slots stay implicit.
  match s.clr_scheme_mapping {
    Some(cm) => {
      attrs.push(@markup.attr("data-ooxml-settings-clr-scheme-mapping", "1"))
      clr_scheme_attr(attrs, cm.bg1, "bg1")
      clr_scheme_attr(attrs, cm.t1, "t1")
      clr_scheme_attr(attrs, cm.bg2, "bg2")
      clr_scheme_attr(attrs, cm.t2, "t2")
      clr_scheme_attr(attrs, cm.accent1, "accent1")
      clr_scheme_attr(attrs, cm.accent2, "accent2")
      clr_scheme_attr(attrs, cm.accent3, "accent3")
      clr_scheme_attr(attrs, cm.accent4, "accent4")
      clr_scheme_attr(attrs, cm.accent5, "accent5")
      clr_scheme_attr(attrs, cm.accent6, "accent6")
      clr_scheme_attr(attrs, cm.hyperlink, "hyperlink")
      clr_scheme_attr(attrs, cm.followed_hyperlink, "followed-hyperlink")
    }
    None => ()
  }
  // §17.15.1.4 `<w:characterSpacingControl>` — compression rule.
  match s.character_spacing_control {
    Some(cs) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-character-spacing-control", cs.val.to_string(),
        ),
      )
    None => ()
  }
  // §17.15.1.30 `<w:evenAndOddHeaders>` — toggle; the renderer also
  // honours this in `resolve_header_footer_decoration` so the metadata
  // here merely documents the source flag.
  on_off_attr(attrs, s.even_and_odd_headers, "even-and-odd-headers")
  // §17.15.1.91 `<w:useXSLTWhenSaving>` — toggle.
  on_off_attr(attrs, s.use_xslt_when_saving, "use-xslt-when-saving")
  // §17.15.1.74 `<w:saveThroughXslt>` — XSLT relationship.
  match s.save_through_xslt {
    Some(xs) => {
      attrs.push(@markup.attr("data-ooxml-settings-save-through-xslt", "1"))
      match xs.r_id {
        Some(id) =>
          attrs.push(
            @markup.attr("data-ooxml-settings-save-through-xslt-rid", id),
          )
        None => ()
      }
      match xs.solution_id {
        Some(sid) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-save-through-xslt-solution", sid,
            ),
          )
        None => ()
      }
    }
    None => ()
  }
  // §17.8.1.2 `<w:embedTrueTypeFonts>`.
  on_off_attr(attrs, s.embed_true_type_fonts, "embed-true-type-fonts")
  on_off_attr(attrs, s.embed_system_fonts, "embed-system-fonts")
  on_off_attr(attrs, s.save_subset_fonts, "save-subset-fonts")
  // §17.14.20 `<w:mailMerge>` — surface the required documentType
  // and dataType so consumers see the merge source kind.
  match s.mail_merge {
    Some(mm) => {
      attrs.push(@markup.attr("data-ooxml-settings-mail-merge", "1"))
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-mail-merge-main-document-type",
          mm.main_document_type.val.to_string(),
        ),
      )
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-mail-merge-data-type",
          mm.data_type.val.to_string(),
        ),
      )
      match mm.destination {
        Some(d) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-mail-merge-destination",
              d.val.to_string(),
            ),
          )
        None => ()
      }
      match mm.data_source {
        Some(rel) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-mail-merge-data-source-rid", rel.r_id,
            ),
          )
        None => ()
      }
      match mm.header_source {
        Some(rel) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-mail-merge-header-source-rid", rel.r_id,
            ),
          )
        None => ()
      }
    }
    None => ()
  }
  // §17.11.5 `<w:captions>` — `<w:caption>`+ and optional `<w:autoCaptions>`.
  match s.captions {
    Some(c) => {
      attrs.push(@markup.attr("data-ooxml-settings-captions", "1"))
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-captions-count", c.caption.length().to_string(),
        ),
      )
      match c.auto_captions {
        Some(_) =>
          attrs.push(
            @markup.attr("data-ooxml-settings-captions-auto", "1"),
          )
        None => ()
      }
    }
    None => ()
  }
  // §17.15.1.84 `<w:stylePaneFormatFilter>` — bare presence is the
  // useful signal here (each individual ST_OnOff would explode the
  // attribute count without adding render-relevant information).
  match s.style_pane_format_filter {
    Some(_) =>
      attrs.push(
        @markup.attr("data-ooxml-settings-style-pane-format-filter", "1"),
      )
    None => ()
  }
  // §17.15.1.85 `<w:stylePaneSortMethod>` — sort kind.
  match s.style_pane_sort_method {
    Some(ss) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-style-pane-sort-method", ss.val.to_string(),
        ),
      )
    None => ()
  }
  attrs
}

///|
/// Append a `data-ooxml-settings-<suffix>` attribute when the
/// CT_OnOff toggle is present and not explicitly off.  A CT_OnOff
/// with `@val` absent means the property is on per §17.17.4; an
/// explicit `@val="false"` / `"0"` / `"off"` means the property is
/// off and we emit no attribute (preserving the symmetric
/// "absent = off" convention the SVG metadata layer uses).
fn on_off_attr(
  attrs : Array[@xml.Attribute],
  toggle : @domain.CT_OnOff?,
  suffix : String,
) -> Unit {
  match toggle {
    Some(t) => {
      let on = match t.val {
        None => true
        Some(v) => v
      }
      if on {
        attrs.push(@markup.attr("data-ooxml-settings-" + suffix, "1"))
      }
    }
    None => ()
  }
}

///|
/// Project the WML font-table (`/word/fontTable.xml`) onto a flat
/// `data-ooxml-fonts-*` attribute list. Each `<w:font>` entry
/// contributes one attribute per declared sub-element so the
/// catalog verifier can see the `<w:embedRegular>` / `<w:embedBold>`
/// / `<w:embedItalic>` / `<w:embedBoldItalic>` / `<w:altName>` /
/// `<w:family>` / `<w:panose1>` / `<w:pitch>` / `<w:charset>` /
/// `<w:sig>` presence — every one of those names is a section
/// in §17.8.2 and the rendered SVG is the only evidence channel.
///
/// The attribute key is `data-ooxml-fonts-<name>-<index>` where
/// `<index>` is the 1-based position of the carrying `<w:font>` in
/// the document order. Without the index two fonts with the same
/// embedded face name would collapse into one attribute.
fn fonts_data_attrs(
  fonts : @domain.CT_FontsList?,
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  let f = match fonts {
    Some(f) => f
    None => return attrs
  }
  attrs.push(
    @markup.attr("data-ooxml-fonts-count", f.fonts.length().to_string()),
  )
  let mut idx = 1
  for entry in f.fonts {
    let i = idx.to_string()
    attrs.push(@markup.attr("data-ooxml-fonts-name-" + i, entry.name))
    match entry.alt_name {
      Some(a) =>
        attrs.push(@markup.attr("data-ooxml-fonts-alt-name-" + i, a.val))
      None => ()
    }
    match entry.family {
      Some(fam) =>
        attrs.push(
          @markup.attr("data-ooxml-fonts-family-" + i, fam.val.to_string()),
        )
      None => ()
    }
    match entry.panose1 {
      Some(p) =>
        attrs.push(@markup.attr("data-ooxml-fonts-panose1-" + i, p.val))
      None => ()
    }
    match entry.pitch {
      Some(p) =>
        attrs.push(
          @markup.attr("data-ooxml-fonts-pitch-" + i, p.val.to_string()),
        )
      None => ()
    }
    match entry.charset {
      Some(c) =>
        match c.val {
          Some(v) =>
            attrs.push(
              @markup.attr("data-ooxml-fonts-charset-" + i, v.to_string()),
            )
          None => attrs.push(@markup.attr("data-ooxml-fonts-charset-" + i, "0"))
        }
      None => ()
    }
    match entry.sig {
      Some(s) => {
        attrs.push(
          @markup.attr("data-ooxml-fonts-sig-usb0-" + i, s.usb0.to_string()),
        )
        attrs.push(
          @markup.attr("data-ooxml-fonts-sig-csb0-" + i, s.csb0.to_string()),
        )
      }
      None => ()
    }
    match entry.embed_regular {
      Some(e) =>
        attrs.push(
          @markup.attr("data-ooxml-fonts-embed-regular-rid-" + i, e.r_id),
        )
      None => ()
    }
    match entry.embed_bold {
      Some(e) =>
        attrs.push(@markup.attr("data-ooxml-fonts-embed-bold-rid-" + i, e.r_id))
      None => ()
    }
    match entry.embed_italic {
      Some(e) =>
        attrs.push(
          @markup.attr("data-ooxml-fonts-embed-italic-rid-" + i, e.r_id),
        )
      None => ()
    }
    match entry.embed_bold_italic {
      Some(e) =>
        attrs.push(
          @markup.attr("data-ooxml-fonts-embed-bold-italic-rid-" + i, e.r_id),
        )
      None => ()
    }
    match entry.not_true_type {
      Some(t) => {
        let on = match t.val {
          None => true
          Some(v) => v
        }
        if on {
          attrs.push(
            @markup.attr("data-ooxml-fonts-not-true-type-" + i, "1"),
          )
        }
      }
      None => ()
    }
    idx = idx + 1
  }
  attrs
}

///|
/// Append a `data-ooxml-settings-clr-scheme-<slot>` attribute when
/// the colour-scheme mapping declared a value for that slot.
fn clr_scheme_attr(
  attrs : Array[@xml.Attribute],
  slot : @domain.ST_WmlColorSchemeIndex?,
  name : String,
) -> Unit {
  match slot {
    Some(v) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-clr-scheme-" + name, v.to_string(),
        ),
      )
    None => ()
  }
}
