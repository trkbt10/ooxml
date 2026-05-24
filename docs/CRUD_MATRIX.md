# trkbt10/ooxml CRUD coverage matrix

## Package layout (parser → context → builder | renderer)

```
src/ecma376/{wordprocessing_ml, spreadsheet_ml, presentation_ml}/
  domain/   ← typed CT_* projection         (parser output)
  reader/   ← bytes → CT_* (parser)
  builder/  ← CT_* → bytes (serializer)
  viewer/   ← CT_* → html / svg (renderer)
  context/  ← Document / Workbook / Presentation: parser-built tree +
              IO (open / save) + render queries + pure read API
  edit/     ← B-layer mutators (top-level functions) consuming context

src/edit/         ← A-layer XML primitives (ML-agnostic)
src/ecma376/opc/  ← OPC package + A-layer OPC primitives
                    (add_part / with_relationship / ...)

src/{docx, xlsx, pptx}/   ← thin facade re-exporting Document /
                            Workbook / Presentation + `open(bytes)`
                            (<= 50 lines each)
```

Mutation always flows **context → edit → context** as new value. No
mutator method lives on `Document` / `Workbook` / `Presentation`
itself; mutators are top-level functions in the `edit` packages.

## A-layer primitives

### XML primitives (`src/edit/edit.mbt`)

| Primitive | Signature | Use |
|---|---|---|
| `by_local_name` | `String -> ElementPredicate` | Match by local_name. |
| `by_qname` | `String, String -> ElementPredicate` | Match by full QName. |
| `by_local_name_with_attr` | `String, String, String -> ElementPredicate` | local_name + attr. |
| `find_first` | `Element, Predicate -> Element?` | First descendant. |
| `find_all` | `Element, Predicate -> Array[Element]` | All descendants. |
| `direct_children` | `Element, Predicate -> Array[Element]` | Immediate match. |
| `append_child` | `Element, Node -> Element` | Append node. |
| `insert_child` | `Element, Int, Node -> Element` | Insert at index. |
| `remove_children` | `Element, Predicate -> Element` | Drop matches. |
| `replace_children` | `Element, Predicate, Element -> Element` | Replace matches. |
| `set_attribute` | `Element, Attribute -> Element` | Set/replace attribute. |
| `remove_attribute` | `Element, QName -> Element` | Drop attribute. |
| `update_first` | `Element, Predicate, (E -> E) -> Element` | Patch first match. |
| `map_subtree` | `Element, (E -> E) -> Element` | Recursive transform. |
| `text_content` | `Element -> String` | Concatenated text. |
| `attribute` / `attribute_by_local_name` | `Element, ... -> String?` | Attribute lookup. |
| `qname_like` / `empty_element` | `QName, String -> ...` | QName / Element builders. |
| `unprefixed_attribute` | `String, String -> Attribute` | Build attribute. |

### OPC primitives (`src/ecma376/opc/package.mbt`)

| Primitive | ECMA-376 § | Use |
|---|---|---|
| `Package::part` | §6.3.3 | Look up part by name. |
| `Package::with_part` | §7.3.2 | Replace part payload. |
| `Package::add_part` | §6.3.2 + §10.1.2.3 | Add new part + Override. |
| `Package::remove_part` | §6.3.2 | Remove part + Override + rels. |
| `Package::with_relationship` | §9.3 | Append relationship. |
| `Package::remove_relationship` | §9.3 | Drop relationship. |
| `Package::with_content_type_override` | §10.1.2.3 | Set Override. |
| `Package::with_optional_part` | §7.3.2 | Conditional replace. |
| `Package::required_part` | §6.3.3 | Lookup-or-raise. |
| `Package::read_optional` | §6.3.3 | Lookup-and-parse. |
| `Package::relationships` | §6.4.2 | Get rels. |

### Facade-edit primitives (each ML's `edit/` package, top-level fns)

| ML | Primitive | Domain | Use |
|---|---|---|---|
| wml | `edit_main(d, fn)` | `/word/document.xml` | Funnel for body-level helpers. |
| wml | `edit_styles(d, fn)` | `/word/styles.xml` | Styles part rewrite. |
| wml | `edit_numbering(d, fn)` | `/word/numbering.xml` | Numbering part rewrite. |
| wml | `edit_paragraph(d, idx, fn)` | one paragraph | Per-paragraph helper. |
| wml | `with_package(d, pkg)` | OPC reinstall | After add_part/with_rel. |
| sml | `edit_workbook(w, fn)` | `/xl/workbook.xml` | Funnel for workbook helpers. |
| sml | `edit_worksheet(w, idx, fn)` | per-sheet | Per-sheet helper. |
| sml | `edit_styles(w, fn)` | `/xl/styles.xml` | Styles synth + rewrite. |
| sml | `bind_cell_style(w, idx, addr, n)` | cell `@s` | Bind cell to xf index. |
| sml | `with_package(w, pkg)` | OPC reinstall | After add_part/with_rel. |
| pml | `edit_presentation(p, fn)` | `/ppt/presentation.xml` | Funnel for presentation. |
| pml | `edit_slide(p, idx, fn)` | per-slide | Per-slide helper. |
| pml | `edit_text_run(p, s, sh, pa, r, fn)` | per-run rPr | Per-run rPr helper. |
| pml | `with_package(p, pkg)` | OPC reinstall | After add_part/with_rel. |

Total A-layer: **20 XML + 11 OPC + 14 facade-edit = 45 primitives**.

## B-layer (Office Object Model helpers)

### docx (Word.Document) — `@wml_edit` package

| Office method | ECMA-376 § | Helper | A-layer composition |
|---|---|---|---|
| `Paragraphs.Add` | §17.3.1.22 | `append_paragraph(d, text)` | `edit_main` + `update_first(body)` + `append_child` |
| `Paragraphs(n).Delete` | §17.3.1.22 | `remove_paragraph(d, idx)` | `edit_main` + index-tracked filter |
| `Paragraphs(n).Range.Text = "..."` | §17.3.1.22 | `set_paragraph_text(d, idx, text)` | `edit_paragraph` + `remove_children(r)` + `append_child` |
| `Paragraphs(n).Style = "..."` | §17.3.1.27 pStyle | `set_paragraph_style(d, idx, style_id)` | `edit_paragraph` + `edit_paragraph_p_pr` + `set_attribute` |
| `Paragraphs(n).Alignment = ...` | §17.3.1.13 jc | `set_paragraph_alignment(d, idx, val)` | `edit_paragraph` + `update_first(pPr)` |
| `Paragraphs.Insert(at)` | §17.3.1.22 | `insert_paragraph_at(d, pos, text)` | `edit_main` + index-tracked insert |
| `Range.Bold = True` | §17.3.2.1 b | `set_run_bold(d, p, r, bool)` | `edit_paragraph` + `edit_run_r_pr` |
| `Range.Font.Color = ...` | §17.3.2.6 color | `set_run_color(d, p, r, hex)` | `edit_paragraph` + `edit_run_r_pr` |
| `Range.Font.Size = ...` | §17.3.2.38 sz | `set_run_font_size(d, p, r, hps)` | `edit_paragraph` + `edit_run_r_pr` |
| `Hyperlinks.Add` | §17.16.22 | `insert_hyperlink(d, p, url, text)` | `with_relationship` + `edit_paragraph` |
| `Tables.Add` | §17.4.38 tbl | `append_table(d, rows, cols)` | `edit_main` + element construction |
| `Tables(n).Delete` | §17.4.38 tbl | `remove_table(d, idx)` | `edit_main` + index-tracked filter |
| `Pictures.Insert(file)` | §20.4 pic | `insert_picture(d, p, bytes, mime, w, h)` | `add_part` + `with_relationship` + `edit_paragraph` + `with_package` |
| `Document.Save` | §11 ZIP | `Document::save` (context) | OPC `Package::save` |
| Embedded font open | §17.8.3 | `open_embedded_font(d, name)` (context) | `Package::part` + `mizchi/font` |

### xlsx (Excel.Worksheet/Range) — `@sml_edit` package

| Office method | ECMA-376 § | Helper | A-layer composition |
|---|---|---|---|
| `Range(addr).Value = ...` | §18.3.1.4 c | `set_cell_value(w, s, addr, text)` | `edit_worksheet` + nested `update_first` |
| `Range(addr).Clear` | §18.3.1.4 c | `clear_cell(w, s, addr)` | `edit_worksheet` + `map_subtree` |
| `Range(addr).Formula = ...` | §18.3.1.40 f | `set_cell_formula(w, s, addr, formula)` | `edit_worksheet` + `update_first` |
| `Range(a:b).Merge` | §18.3.1.55 | `merge_cells(w, s, range)` | `edit_worksheet` + `update_first(mergeCells)` |
| `Range(a:b).UnMerge` | §18.3.1.55 | `unmerge_cells(w, s, range)` | `edit_worksheet` + `remove_children` |
| `Rows(n).Insert` | §18.3.1.73 | `insert_row(w, s, n)` | `edit_worksheet` + `append_child` |
| `Rows(n).Delete` | §18.3.1.73 | `remove_row(w, s, n)` | `edit_worksheet` + `remove_children` |
| `Rows(n).Hidden = True` | §18.3.1.73 @hidden | `set_row_hidden(w, s, n, bool)` | `edit_worksheet` + `set_attribute` |
| `Rows(n).RowHeight = ...` | §18.3.1.73 @ht | `set_row_height(w, s, n, pt)` | `edit_worksheet` + `set_attribute` |
| `Columns(n).Insert` | §18.3.1.13 | `insert_column(w, s, idx)` | `edit_worksheet` + `update_first(cols)` |
| `Columns(n).Delete` | §18.3.1.13 | `remove_column(w, s, idx)` | `edit_worksheet` + `remove_children` |
| `Columns(n).ColumnWidth = ...` | §18.3.1.13 @width | `set_column_width(w, s, idx, val)` | `edit_worksheet` + `update_first(cols)` |
| `Range.NumberFormat = ...` | §18.8.30 | `set_cell_number_format(w, s, addr, fmt)` | `edit_styles` + `allocate_num_fmt` + `bind_cell_style` |
| `Range.Font.Bold = ...` | §18.8.20 | `set_cell_font(w, s, addr, name, sz)` | `edit_styles` + `allocate_font` + `bind_cell_style` |
| `Range.Interior.Color = ...` | §18.8.20 | `set_cell_fill(w, s, addr, hex)` | `edit_styles` + `allocate_fill` + `bind_cell_style` |
| `AutoFilter` apply | §18.3.1.2 | `set_auto_filter(w, s, range)` | `edit_worksheet` + `append_child` |
| `AutoFilter` remove | §18.3.1.2 | `clear_auto_filter(w, s)` | `edit_worksheet` + `remove_children` |
| `Workbook.Worksheets.Add` | §18.2.19 sheet | `append_sheet(w, name)` | `add_part` + `with_relationship` + `edit_workbook` |
| `Worksheets(n).Delete` | §18.2.19 sheet | `remove_sheet(w, idx)` | `remove_part` + `remove_relationship` + `edit_workbook` |
| `Worksheet.Name = ...` | §18.2.19 @name | `rename_sheet(w, idx, name)` | `edit_workbook` + `set_attribute` |
| `Worksheet.Visible = ...` | §18.2.19 @state | `set_sheet_visible(w, idx, state)` | `edit_workbook` + `set_attribute` |
| `Workbook.SaveAs` | §11 ZIP | `Workbook::save` (context) | OPC `Package::save` |

### pptx (PowerPoint.Slide/Shape) — `@pml_edit` package

| Office method | ECMA-376 § | Helper | A-layer composition |
|---|---|---|---|
| `Slides.Add` | §19.3.1.38 sld | `append_slide(p)` | `add_part` + `with_relationship` + `edit_presentation` |
| `Slides(n).Delete` | §19.3.1.38 sld | `remove_slide(p, idx)` | `remove_part` + `remove_relationship` + `edit_presentation` |
| `Slides(n).Duplicate` | §19.3.1.38 sld | `duplicate_slide(p, idx)` | `add_part` (copy bytes) + `with_relationship` + `edit_presentation` |
| `Slides.MoveSlide` | §19.3.1.38 sld order | `reorder_slides(p, from, to)` | `edit_presentation` + `update_first(sldIdLst)` |
| `Slide.Shapes.AddTextbox` | §19.3.1.43 sp + §21.1.2.1.1 | `add_textbox(p, s, x, y, w, h, text)` | `edit_slide` + `update_first(spTree)` |
| `TextRange.Text = ...` | §21.1.2.2.6 a:p | `append_text_to_slide(p, s, text)` | `edit_slide` + `update_first(txBody)` |
| `TextRange.Font.Bold` | §21.1.2.3.9 @b | `set_text_bold(p, s, sh, pa, r, bool)` | `edit_text_run` + `set_attribute` |
| `TextRange.Font.Color` | §21.1.2.3.9 solidFill | `set_text_color(p, s, sh, pa, r, hex)` | `edit_text_run` + element insertion |
| `TextRange.Font.Size` | §21.1.2.3.9 @sz | `set_text_font_size(p, s, sh, pa, r, hps)` | `edit_text_run` + `set_attribute` |
| `Shape.{Left,Top,Width,Height} = ...` | §20.1.7.6 xfrm | `set_shape_xfrm(p, s, idx, x, y, w, h)` | `edit_slide` + nested `update_first(xfrm)` |
| `Slide.Shapes.AddPicture(file)` | §19.3.1.37 + §20.1.8.13 | `add_picture(p, s, bytes, mime, x, y, w, h)` | `add_part(/ppt/media)` + `with_relationship` + `edit_slide` + `with_package` |
| `Shape.Delete` | §19.3.1.43 sp | `remove_shape(p, s, idx)` | `edit_slide` + index-tracked filter |
| `Slide.Shapes.AddConnector` | §20.1.2.2.10 cxnSp | `add_connector(p, s, prst, x, y, w, h)` | `edit_slide` + `update_first(spTree)` |
| `Slide.Background.Fill` | §19.3.1.1 bg | `set_slide_background(p, s, hex)` | `edit_slide` + `update_first(cSld)` |
| `Slide.Layout` | §19.3.1.39 sldLayout | `set_slide_layout(p, s, layout_idx)` | `remove_relationship` + `with_relationship` + `with_package` |
| `Presentation.SaveAs` | §11 ZIP | `Presentation::save` (context) | OPC `Package::save` |
| `Slide` → SVG render | §19 / §20 | `Presentation::to_svg_for_slide(idx)` (context) | viewer + base64 + OPC rels |
| `Document` → SVG render | §17.6 / §17.3 / §17.4 | `@wml_viewer.render_svg(domain)` → `DocumentSvgResult` (per-page SVG) | wml/viewer + util/glyph + util/color |
| `Worksheet` → SVG render | §18.3 / §18.8 / §18.18 | `@sml_viewer.render_svg(domain, ~shared_strings, ~options)` → `SheetSvgResult` | sml/viewer + util/glyph + util/color |

## Operation totals

- A-layer primitives: **45**
- B-layer operations: **53 DONE / 53 (100%)**
  - docx: 17
  - xlsx: 22
  - pptx: 14
- Every B-layer helper composes A-layer primitives — no helper builds
  `@xml.Element` trees or touches OPC outside the A-layer.

## Discipline

- `src/{docx, xlsx, pptx}/*.mbt` ≤ 50 lines: only `open(bytes)` and
  re-exports.
- `src/ecma376/<ml>/context/`: parser-built tree, IO, render, pure
  read. No mutation.
- `src/ecma376/<ml>/edit/`: top-level mutator functions consuming
  context, composed entirely from A-layer primitives.
- New Office Object Model operations: identify primitives, add
  primitive if missing, then compose the B-layer helper. The matrix
  is the discipline check.
