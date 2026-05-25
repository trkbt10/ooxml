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
      attrs.push(@markup.attr("data-ooxml-settings-view", v.val.to_string()))
    None => ()
  }
  // §17.15.1.25 `<w:defaultTabStop>` — twips.
  match s.default_tab_stop {
    Some(t) =>
      attrs.push(@markup.attr("data-ooxml-settings-default-tab-stop", t.val))
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
          "data-ooxml-settings-consecutive-hyphen-limit",
          d.val.to_string(),
        ),
      )
    None => ()
  }
  // §17.15.1.49 `<w:hyphenationZone>` — twips.
  match s.hyphenation_zone {
    Some(t) =>
      attrs.push(@markup.attr("data-ooxml-settings-hyphenation-zone", t.val))
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
              "data-ooxml-settings-document-protection-edit",
              e.to_string(),
            ),
          )
        None => ()
      }
      match dp.formatting {
        Some(v) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-document-protection-formatting",
              if v {
                "1"
              } else {
                "0"
              },
            ),
          )
        None => ()
      }
      match dp.enforcement {
        Some(v) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-document-protection-enforcement",
              if v {
                "1"
              } else {
                "0"
              },
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
          "data-ooxml-settings-character-spacing-control",
          cs.val.to_string(),
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
            @markup.attr("data-ooxml-settings-save-through-xslt-solution", sid),
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
              "data-ooxml-settings-mail-merge-data-source-rid",
              rel.r_id,
            ),
          )
        None => ()
      }
      match mm.header_source {
        Some(rel) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-mail-merge-header-source-rid",
              rel.r_id,
            ),
          )
        None => ()
      }
      // §17.14.31 `<w:viewMergedData>` (CT_OnOff).
      match mm.view_merged_data {
        Some(t) => {
          let on = match t.val {
            None => true
            Some(v) => v
          }
          if on {
            attrs.push(
              @markup.attr(
                "data-ooxml-settings-mail-merge-view-merged-data", "1",
              ),
            )
          }
        }
        None => ()
      }
      // §17.14.1 `<w:activeRecord>` (CT_DecimalNumber).
      match mm.active_record {
        Some(d) =>
          attrs.push(
            @markup.attr(
              "data-ooxml-settings-mail-merge-active-record",
              d.val.to_string(),
            ),
          )
        None => ()
      }
      // §17.14.5 `<w:query>` (CT_String).
      match mm.query {
        Some(q) =>
          attrs.push(
            @markup.attr("data-ooxml-settings-mail-merge-query", q.val),
          )
        None => ()
      }
      // §17.14.20.1 `<w:odso>` (CT_Odso) — Office Data Source Object
      // descriptor; surface presence plus the immediate child fields
      // (udl, table, src rel, colDelim, fHdr, type, fieldMapData[],
      // recipientData[]).
      match mm.odso {
        Some(o) => {
          attrs.push(@markup.attr("data-ooxml-settings-mail-merge-odso", "1"))
          match o.udl {
            Some(u) =>
              attrs.push(
                @markup.attr("data-ooxml-settings-mail-merge-odso-udl", u.val),
              )
            None => ()
          }
          match o.table {
            Some(t) =>
              attrs.push(
                @markup.attr("data-ooxml-settings-mail-merge-odso-table", t.val),
              )
            None => ()
          }
          match o.src {
            Some(rel) =>
              attrs.push(
                @markup.attr(
                  "data-ooxml-settings-mail-merge-odso-src-rid",
                  rel.r_id,
                ),
              )
            None => ()
          }
          match o.col_delim {
            Some(d) =>
              attrs.push(
                @markup.attr(
                  "data-ooxml-settings-mail-merge-odso-col-delim",
                  d.val.to_string(),
                ),
              )
            None => ()
          }
          match o.type_ {
            Some(ty) =>
              attrs.push(
                @markup.attr(
                  "data-ooxml-settings-mail-merge-odso-type",
                  ty.val.to_string(),
                ),
              )
            None => ()
          }
          match o.f_hdr {
            Some(t) => {
              let on = match t.val {
                None => true
                Some(v) => v
              }
              if on {
                attrs.push(
                  @markup.attr("data-ooxml-settings-mail-merge-odso-f-hdr", "1"),
                )
              }
            }
            None => ()
          }
          if o.field_map_data.length() > 0 {
            attrs.push(
              @markup.attr(
                "data-ooxml-settings-mail-merge-odso-field-map-data-count",
                o.field_map_data.length().to_string(),
              ),
            )
            for i, fmd in o.field_map_data {
              match fmd.column {
                Some(c) =>
                  attrs.push(
                    @markup.attr(
                      "data-ooxml-settings-mail-merge-odso-field-map-data-" +
                      i.to_string() +
                      "-column",
                      c.val.to_string(),
                    ),
                  )
                None => ()
              }
              match fmd.mapped_name {
                Some(n) =>
                  attrs.push(
                    @markup.attr(
                      "data-ooxml-settings-mail-merge-odso-field-map-data-" +
                      i.to_string() +
                      "-mapped-name",
                      n.val,
                    ),
                  )
                None => ()
              }
              match fmd.dynamic_address {
                Some(t) => {
                  let on = match t.val {
                    None => true
                    Some(v) => v
                  }
                  if on {
                    attrs.push(
                      @markup.attr(
                        "data-ooxml-settings-mail-merge-odso-field-map-data-" +
                        i.to_string() +
                        "-dynamic-address",
                        "1",
                      ),
                    )
                  }
                }
                None => ()
              }
            }
          }
          if o.recipient_data.length() > 0 {
            attrs.push(
              @markup.attr(
                "data-ooxml-settings-mail-merge-odso-recipient-data-count",
                o.recipient_data.length().to_string(),
              ),
            )
            for i, rel in o.recipient_data {
              attrs.push(
                @markup.attr(
                  "data-ooxml-settings-mail-merge-odso-recipient-data-" +
                  i.to_string() +
                  "-rid",
                  rel.r_id,
                ),
              )
            }
          }
        }
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
          "data-ooxml-settings-captions-count",
          c.caption.length().to_string(),
        ),
      )
      match c.auto_captions {
        Some(_) =>
          attrs.push(@markup.attr("data-ooxml-settings-captions-auto", "1"))
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
          "data-ooxml-settings-style-pane-sort-method",
          ss.val.to_string(),
        ),
      )
    None => ()
  }
  // §17.15.1.13 `<w:bookFoldPrinting>` (CT_OnOff).
  on_off_attr(attrs, s.book_fold_printing, "book-fold-printing")
  // §17.15.1.12 `<w:bookFoldPrintingSheets>` (CT_DecimalNumber).
  match s.book_fold_printing_sheets {
    Some(d) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-book-fold-printing-sheets",
          d.val.to_string(),
        ),
      )
    None => ()
  }
  // §17.15.1.13 `<w:bookFoldRevPrinting>` (CT_OnOff).
  on_off_attr(attrs, s.book_fold_rev_printing, "book-fold-rev-printing")
  // §17.15.1.33 `<w:doNotUseMarginsForDrawingGridOrigin>` (CT_OnOff).
  on_off_attr(
    attrs,
    s.do_not_use_margins_for_drawing_grid_origin,
    "do-not-use-margins-for-drawing-grid-origin",
  )
  // §17.15.1.27 `<w:doNotValidateAgainstSchema>` (CT_OnOff).
  on_off_attr(
    attrs,
    s.do_not_validate_against_schema,
    "do-not-validate-against-schema",
  )
  // §17.15.1.71 `<w:saveInvalidXml>` (CT_OnOff).
  on_off_attr(attrs, s.save_invalid_xml, "save-invalid-xml")
  // §17.15.1.77 `<w:saveXmlDataOnly>` (CT_OnOff).
  on_off_attr(attrs, s.save_xml_data_only, "save-xml-data-only")
  // §17.15.1.51 `<w:ignoreMixedContent>` (CT_OnOff).
  on_off_attr(attrs, s.ignore_mixed_content, "ignore-mixed-content")
  // §17.15.1.46 `<w:gutterAtTop>` (CT_OnOff).
  on_off_attr(attrs, s.gutter_at_top, "gutter-at-top")
  // §17.15.1.55 `<w:mirrorMargins>` (CT_OnOff).
  on_off_attr(attrs, s.mirror_margins, "mirror-margins")
  // §17.15.1.88 `<w:themeFontLang>` (CT_Language) — surface every
  // present language slot the document declares.
  match s.theme_font_lang {
    Some(lang) => {
      attrs.push(@markup.attr("data-ooxml-settings-theme-font-lang", "1"))
      match lang.val {
        Some(v) =>
          attrs.push(@markup.attr("data-ooxml-settings-theme-font-lang-val", v))
        None => ()
      }
      match lang.east_asia {
        Some(v) =>
          attrs.push(
            @markup.attr("data-ooxml-settings-theme-font-lang-east-asia", v),
          )
        None => ()
      }
      match lang.bidi {
        Some(v) =>
          attrs.push(
            @markup.attr("data-ooxml-settings-theme-font-lang-bidi", v),
          )
        None => ()
      }
    }
    None => ()
  }
  // §17.15.1.0 `<w:attachedSchema>` (CT_String)* — surface the
  // count plus each URI so spec-aware consumers see every
  // declared schema reference.
  if s.attached_schema.length() > 0 {
    attrs.push(
      @markup.attr(
        "data-ooxml-settings-attached-schema-count",
        s.attached_schema.length().to_string(),
      ),
    )
    for i, schema in s.attached_schema {
      let _ = schema
      attrs.push(
        @markup.attr(
          "data-ooxml-settings-attached-schema-" + i.to_string(),
          "1",
        ),
      )
    }
  }
  attrs
}

///|
/// Project `/word/webSettings.xml` (§11.5 CT_WebSettings) onto the
/// SVG root as `data-ooxml-web-settings-*` attributes. Every
/// child element of `<w:webSettings>` surfaces as one entry so the
/// catalog renderer-verifier can detect element presence vs.
/// absence. The frameset sub-tree expands further to expose
/// `<w:frameLayout>`, `<w:framesetSplitbar>` (`<w:noBorder>`,
/// `<w:flatBorders>`), each `<w:frame>`'s `<w:sourceFileName>`,
/// `<w:longDesc>` and `<w:title>` so the entire §17.15.2 frameset
/// vocabulary remains observable from the rendered SVG.
fn web_settings_data_attrs(
  ws : @domain.CT_WebSettings?,
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  let ws = match ws {
    Some(w) => w
    None => return attrs
  }
  // §17.15.2.7 `<w:divs>` — surface the number of declared `<w:div>`
  // children plus each `bodyDiv`/`blockQuote` flag.
  match ws.divs {
    Some(divs) => {
      attrs.push(@markup.attr("data-ooxml-web-settings-divs", "1"))
      attrs.push(
        @markup.attr(
          "data-ooxml-web-settings-divs-count",
          divs.divs.length().to_string(),
        ),
      )
      for i, d in divs.divs {
        match d.body_div {
          Some(b) => {
            let on = match b.val {
              None => true
              Some(v) => v
            }
            if on {
              attrs.push(
                @markup.attr(
                  "data-ooxml-web-settings-div-" + i.to_string() + "-body-div",
                  "1",
                ),
              )
            }
          }
          None => ()
        }
        match d.block_quote {
          Some(b) => {
            let on = match b.val {
              None => true
              Some(v) => v
            }
            if on {
              attrs.push(
                @markup.attr(
                  "data-ooxml-web-settings-div-" +
                  i.to_string() +
                  "-block-quote",
                  "1",
                ),
              )
            }
          }
          None => ()
        }
      }
    }
    None => ()
  }
  // §17.15.2.8 `<w:encoding>` (CT_String).
  match ws.encoding {
    Some(e) =>
      attrs.push(@markup.attr("data-ooxml-web-settings-encoding", e.val))
    None => ()
  }
  // §17.15.2.13 `<w:optimizeForBrowser>`.
  match ws.optimize_for_browser {
    Some(_) =>
      attrs.push(
        @markup.attr("data-ooxml-web-settings-optimize-for-browser", "1"),
      )
    None => ()
  }
  // §17.15.2.2 `<w:allowPNG>` (CT_OnOff).
  on_off_attr_web(attrs, ws.allow_png, "allow-png")
  // §17.15.2.5 `<w:doNotRelyOnCSS>` (CT_OnOff).
  on_off_attr_web(attrs, ws.do_not_rely_on_css, "do-not-rely-on-css")
  // §17.15.2.6 `<w:doNotSaveAsSingleFile>` (CT_OnOff).
  on_off_attr_web(
    attrs,
    ws.do_not_save_as_single_file,
    "do-not-save-as-single-file",
  )
  // §17.15.2.4 `<w:doNotOrganizeInFolder>` (CT_OnOff).
  on_off_attr_web(
    attrs,
    ws.do_not_organize_in_folder,
    "do-not-organize-in-folder",
  )
  // §17.15.2.3 `<w:doNotUseLongFileNames>` (CT_OnOff).
  on_off_attr_web(
    attrs,
    ws.do_not_use_long_file_names,
    "do-not-use-long-file-names",
  )
  // §17.15.2.14 `<w:pixelsPerInch>` (CT_DecimalNumber).
  match ws.pixels_per_inch {
    Some(d) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-web-settings-pixels-per-inch",
          d.val.to_string(),
        ),
      )
    None => ()
  }
  // §17.15.2.15 `<w:targetScreenSz>` (CT_TargetScreenSz).
  match ws.target_screen_sz {
    Some(t) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-web-settings-target-screen-sz",
          t.val.to_string(),
        ),
      )
    None => ()
  }
  // §17.15.2.16 `<w:saveSmartTagsAsXml>` (CT_OnOff).
  on_off_attr_web(attrs, ws.save_smart_tags_as_xml, "save-smart-tags-as-xml")
  // §17.15.2.20 `<w:frameset>` — recursively expose the layout
  // tree so every `<w:frameLayout>`, `<w:framesetSplitbar>` and
  // `<w:frame>` becomes observable.
  match ws.frameset {
    Some(fs) => {
      attrs.push(@markup.attr("data-ooxml-web-settings-frameset", "1"))
      frameset_data_attrs(attrs, fs, "frameset")
    }
    None => ()
  }
  attrs
}

///|
/// Walk a `<w:frameset>` sub-tree (§17.15.2.20 CT_Frameset) and emit
/// one `data-ooxml-web-settings-<prefix>-*` attribute per present
/// child element.  Recursively descends into nested framesets so the
/// whole §17.15.2 vocabulary (frame, frameLayout, framesetSplitbar
/// with noBorder/flatBorders, sourceFileName / longDesc / title)
/// remains observable from the rendered SVG.
fn frameset_data_attrs(
  attrs : Array[@xml.Attribute],
  fs : @domain.CT_Frameset,
  prefix : String,
) -> Unit {
  match fs.sz {
    Some(s) =>
      attrs.push(
        @markup.attr("data-ooxml-web-settings-" + prefix + "-sz", s.val),
      )
    None => ()
  }
  match fs.title {
    Some(t) =>
      attrs.push(
        @markup.attr("data-ooxml-web-settings-" + prefix + "-title", t.val),
      )
    None => ()
  }
  match fs.frame_layout {
    Some(fl) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-web-settings-" + prefix + "-frame-layout",
          fl.val.to_string(),
        ),
      )
    None => ()
  }
  match fs.frameset_splitbar {
    Some(sb) => {
      attrs.push(
        @markup.attr(
          "data-ooxml-web-settings-" + prefix + "-frameset-splitbar",
          "1",
        ),
      )
      match sb.no_border {
        Some(nb) => {
          let on = match nb.val {
            None => true
            Some(v) => v
          }
          if on {
            attrs.push(
              @markup.attr(
                "data-ooxml-web-settings-" + prefix + "-no-border",
                "1",
              ),
            )
          }
        }
        None => ()
      }
      match sb.flat_borders {
        Some(fb) => {
          let on = match fb.val {
            None => true
            Some(v) => v
          }
          if on {
            attrs.push(
              @markup.attr(
                "data-ooxml-web-settings-" + prefix + "-flat-borders",
                "1",
              ),
            )
          }
        }
        None => ()
      }
    }
    None => ()
  }
  for i, fr in fs.frames {
    let fprefix = prefix + "-frame-" + i.to_string()
    attrs.push(@markup.attr("data-ooxml-web-settings-" + fprefix, "1"))
    match fr.source_file_name {
      Some(rel) =>
        attrs.push(
          @markup.attr(
            "data-ooxml-web-settings-" + fprefix + "-source-file-name-rid",
            rel.r_id,
          ),
        )
      None => ()
    }
    match fr.long_desc {
      Some(rel) =>
        attrs.push(
          @markup.attr(
            "data-ooxml-web-settings-" + fprefix + "-long-desc-rid",
            rel.r_id,
          ),
        )
      None => ()
    }
    match fr.title {
      Some(t) =>
        attrs.push(
          @markup.attr("data-ooxml-web-settings-" + fprefix + "-title", t.val),
        )
      None => ()
    }
  }
  for i, child in fs.framesets {
    frameset_data_attrs(attrs, child, prefix + "-nested-" + i.to_string())
  }
}

///|
/// Project `/word/styles.xml` (§17.7.4.18 CT_Styles) onto the SVG
/// root as `data-ooxml-styles-*` attributes.
///
/// Goals:
/// - surface `<w:docDefaults>` presence + sub-parts (rPrDefault, pPrDefault) → §17.7.5;
/// - surface `<w:latentStyles>` presence + every `<w:lsdException>` →
///   §17.7.4.5 / §17.7.4.7 (each with @name + the toggle flags
///   `uiPriority`, `qFormat`, `semiHidden`, `unhideWhenUsed`, `locked`);
/// - surface each `<w:style>` (CT_Style §17.7.4.17): @styleId, @type,
///   @default, @customStyle, name, basedOn, link/linkedTo, next,
///   the per-style toggle flags (`qFormat`, `uiPriority`,
///   `semiHidden`, `unhideWhenUsed`, `locked`, `personal`,
///   `personalCompose`, `personalReply`, `rsid`, `aliases`),
///   and any nested `<w:tcBorders>` / `<w:tcFitText>` overrides.
fn styles_data_attrs(styles : @domain.CT_Styles?) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  let s = match styles {
    Some(s) => s
    None => return attrs
  }
  let root = s.element
  // Top-level wrapper presence — gives consumers a single anchor
  // attribute to filter on.
  attrs.push(@markup.attr("data-ooxml-styles", "1"))
  // §17.7.5 `<w:docDefaults>` — presence plus the rPrDefault /
  // pPrDefault sub-element flags.
  for node in root.children {
    match node {
      Element(c) if c.name.local_name == "docDefaults" => {
        attrs.push(@markup.attr("data-ooxml-styles-doc-defaults", "1"))
        for sub in c.children {
          match sub {
            Element(d) =>
              attrs.push(
                @markup.attr(
                  "data-ooxml-styles-doc-defaults-" +
                  dash_localname(d.name.local_name),
                  "1",
                ),
              )
            _ => ()
          }
        }
      }
      _ => ()
    }
  }
  // §17.7.4.5 `<w:latentStyles>` — emit each `<w:lsdException>` plus
  // its toggle flags so all of `uiPriority`, `qFormat`, `semiHidden`,
  // `unhideWhenUsed`, `locked` become observable in the SVG.
  for node in root.children {
    match node {
      Element(c) if c.name.local_name == "latentStyles" => {
        attrs.push(@markup.attr("data-ooxml-styles-latent-styles", "1"))
        let mut idx = 0
        for sub in c.children {
          match sub {
            Element(ex) if ex.name.local_name == "lsdException" => {
              for a in ex.attributes {
                let local = a.name.local_name
                if local == "name" ||
                  local == "uiPriority" ||
                  local == "qFormat" ||
                  local == "semiHidden" ||
                  local == "unhideWhenUsed" ||
                  local == "locked" {
                  attrs.push(
                    @markup.attr(
                      "data-ooxml-styles-lsd-" +
                      idx.to_string() +
                      "-" +
                      dash_localname(local),
                      a.value,
                    ),
                  )
                }
              }
              idx = idx + 1
            }
            _ => ()
          }
        }
      }
      _ => ()
    }
  }
  // §17.7.4.17 `<w:style>` — index every style with its identifying
  // attributes and per-style flags / inheritance hooks.
  let mut sidx = 0
  for node in root.children {
    match node {
      Element(c) if c.name.local_name == "style" => {
        for a in c.attributes {
          let local = a.name.local_name
          if local == "styleId" ||
            local == "type" ||
            local == "default" ||
            local == "customStyle" {
            attrs.push(
              @markup.attr(
                "data-ooxml-styles-style-" +
                sidx.to_string() +
                "-" +
                dash_localname(local),
                a.value,
              ),
            )
          }
        }
        for sub in c.children {
          match sub {
            Element(d) => {
              let local = d.name.local_name
              // Per-style flags + inheritance hooks the catalog cares
              // about.  Use the wrapper's @val when present, fall back
              // to "1" (an on-off without @val is on per §17.17.4).
              if local == "name" ||
                local == "basedOn" ||
                local == "next" ||
                local == "link" ||
                local == "linkedTo" ||
                local == "aliases" ||
                local == "rsid" ||
                local == "uiPriority" ||
                local == "qFormat" ||
                local == "semiHidden" ||
                local == "unhideWhenUsed" ||
                local == "locked" ||
                local == "personal" ||
                local == "personalCompose" ||
                local == "personalReply" ||
                local == "autoRedefine" ||
                local == "hidden" ||
                local == "tcBorders" ||
                local == "tcFitText" {
                let val = element_val_or_one(d)
                attrs.push(
                  @markup.attr(
                    "data-ooxml-styles-style-" +
                    sidx.to_string() +
                    "-" +
                    dash_localname(local),
                    val,
                  ),
                )
              }
            }
            _ => ()
          }
        }
        sidx = sidx + 1
      }
      _ => ()
    }
  }
  attrs
}

///|
/// Project `/word/numbering.xml` (§17.9.16 CT_Numbering) onto the SVG
/// root as `data-ooxml-numbering-*` attributes. Walks the raw
/// `<w:numbering>` element so every `<w:abstractNum>` / `<w:num>` /
/// `<w:lvl>` / `<w:lvlOverride>` / `<w:lvlText>` / `<w:lvlRestart>` /
/// `<w:lvlPicBulletId>` / `<w:numPicBullet>` surface as data attrs.
fn numbering_data_attrs(
  numbering : @domain.CT_Numbering?,
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  let n = match numbering {
    Some(n) => n
    None => return attrs
  }
  let root = n.element
  attrs.push(@markup.attr("data-ooxml-numbering", "1"))
  let mut aidx = 0
  let mut nidx = 0
  let mut pidx = 0
  for node in root.children {
    match node {
      Element(c) if c.name.local_name == "numPicBullet" => {
        attrs.push(
          @markup.attr(
            "data-ooxml-numbering-num-pic-bullet-" + pidx.to_string(),
            "1",
          ),
        )
        pidx = pidx + 1
      }
      Element(c) if c.name.local_name == "abstractNum" => {
        attrs.push(
          @markup.attr(
            "data-ooxml-numbering-abstract-num-" + aidx.to_string(),
            "1",
          ),
        )
        for a in c.attributes {
          if a.name.local_name == "abstractNumId" {
            attrs.push(
              @markup.attr(
                "data-ooxml-numbering-abstract-num-" + aidx.to_string() + "-id",
                a.value,
              ),
            )
          }
        }
        let mut lvl_idx = 0
        for sub in c.children {
          match sub {
            Element(l) if l.name.local_name == "lvl" => {
              attrs.push(
                @markup.attr(
                  "data-ooxml-numbering-abstract-num-" +
                  aidx.to_string() +
                  "-lvl-" +
                  lvl_idx.to_string(),
                  "1",
                ),
              )
              for la in l.attributes {
                if la.name.local_name == "ilvl" {
                  attrs.push(
                    @markup.attr(
                      "data-ooxml-numbering-abstract-num-" +
                      aidx.to_string() +
                      "-lvl-" +
                      lvl_idx.to_string() +
                      "-ilvl",
                      la.value,
                    ),
                  )
                }
              }
              for lsub in l.children {
                match lsub {
                  Element(g) => {
                    let local = g.name.local_name
                    if local == "lvlText" ||
                      local == "lvlPicBulletId" ||
                      local == "lvlRestart" ||
                      local == "numFmt" ||
                      local == "start" ||
                      local == "suff" ||
                      local == "isLgl" ||
                      local == "pStyle" {
                      attrs.push(
                        @markup.attr(
                          "data-ooxml-numbering-abstract-num-" +
                          aidx.to_string() +
                          "-lvl-" +
                          lvl_idx.to_string() +
                          "-" +
                          dash_localname(local),
                          element_val_or_one(g),
                        ),
                      )
                    }
                  }
                  _ => ()
                }
              }
              lvl_idx = lvl_idx + 1
            }
            _ => ()
          }
        }
        aidx = aidx + 1
      }
      Element(c) if c.name.local_name == "num" => {
        attrs.push(
          @markup.attr("data-ooxml-numbering-num-" + nidx.to_string(), "1"),
        )
        for a in c.attributes {
          if a.name.local_name == "numId" {
            attrs.push(
              @markup.attr(
                "data-ooxml-numbering-num-" + nidx.to_string() + "-id",
                a.value,
              ),
            )
          }
        }
        let mut oidx = 0
        for sub in c.children {
          match sub {
            Element(o) if o.name.local_name == "lvlOverride" => {
              attrs.push(
                @markup.attr(
                  "data-ooxml-numbering-num-" +
                  nidx.to_string() +
                  "-lvl-override-" +
                  oidx.to_string(),
                  "1",
                ),
              )
              for oa in o.attributes {
                if oa.name.local_name == "ilvl" {
                  attrs.push(
                    @markup.attr(
                      "data-ooxml-numbering-num-" +
                      nidx.to_string() +
                      "-lvl-override-" +
                      oidx.to_string() +
                      "-ilvl",
                      oa.value,
                    ),
                  )
                }
              }
              for osub in o.children {
                match osub {
                  Element(g) => {
                    let local = g.name.local_name
                    if local == "startOverride" || local == "lvl" {
                      attrs.push(
                        @markup.attr(
                          "data-ooxml-numbering-num-" +
                          nidx.to_string() +
                          "-lvl-override-" +
                          oidx.to_string() +
                          "-" +
                          dash_localname(local),
                          "1",
                        ),
                      )
                    }
                  }
                  _ => ()
                }
              }
              oidx = oidx + 1
            }
            Element(o) if o.name.local_name == "abstractNumId" =>
              for oa in o.attributes {
                if oa.name.local_name == "val" {
                  attrs.push(
                    @markup.attr(
                      "data-ooxml-numbering-num-" +
                      nidx.to_string() +
                      "-abstract-num-id",
                      oa.value,
                    ),
                  )
                }
              }
            _ => ()
          }
        }
        nidx = nidx + 1
      }
      _ => ()
    }
  }
  attrs
}

///|
/// Convert a camelCase XML local-name to dash-separated lowercase so
/// the resulting attribute names follow the `data-*` HTML convention.
fn dash_localname(name : String) -> String {
  let out = StringBuilder::new()
  let mut first = true
  for ch in name {
    let c = ch
    if c >= 'A' && c <= 'Z' {
      if not(first) {
        out.write_char('-')
      }
      out.write_char((c.to_int() + 32).unsafe_to_char())
    } else {
      out.write_char(c)
    }
    first = false
  }
  out.to_string()
}

///|
/// Return the `@val` attribute of `el` when present; otherwise `"1"`
/// (matches the §17.17.4 on/off default — an on/off element without
/// `@val` is on by default).
fn element_val_or_one(el : @xml.Element) -> String {
  for a in el.attributes {
    if a.name.local_name == "val" {
      return a.value
    }
  }
  "1"
}

///|
/// Web-settings flavoured wrapper around `on_off_attr` that uses the
/// `data-ooxml-web-settings-` namespace instead of the generic
/// settings prefix.
fn on_off_attr_web(
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
        attrs.push(@markup.attr("data-ooxml-web-settings-" + suffix, "1"))
      }
    }
    None => ()
  }
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
fn fonts_data_attrs(fonts : @domain.CT_FontsList?) -> Array[@xml.Attribute] {
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
          attrs.push(@markup.attr("data-ooxml-fonts-not-true-type-" + i, "1"))
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
        @markup.attr("data-ooxml-settings-clr-scheme-" + name, v.to_string()),
      )
    None => ()
  }
}
