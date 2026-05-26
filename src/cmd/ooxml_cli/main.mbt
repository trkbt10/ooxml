///|
priv enum Format {
  Docx
  Xlsx
  Pptx
}

///|
fn main {
  let args = @env.args()
  if args.length() <= 1 {
    print_help()
  } else {
    match args[1] {
      "--help" | "-h" => print_help()
      "help" => print_help()
      "info" => run_info(args)
      "open" => run_open(args)
      "svg" => run_svg(args)
      "save" => run_save(args)
      "list" => run_list(args)
      "show" => run_show(args)
      "extract" => run_extract(args)
      "verify" => run_verify(args)
      "parts" => run_parts(args)
      "set-cell" => run_set_cell(args)
      "clear-cell" => run_clear_cell(args)
      "append-paragraph" => run_append_paragraph(args)
      "remove-paragraph" => run_remove_paragraph(args)
      "append-text-to-slide" => run_append_text_to_slide(args)
      "append-slide" => run_append_slide(args)
      "remove-slide" => run_remove_slide(args)
      "append-sheet" => run_append_sheet(args)
      "remove-sheet" => run_remove_sheet(args)
      "svg-for-slide" => run_svg_for_slide(args)
      "set-cell-formula" => run_set_cell_formula(args)
      "merge-cells" => run_merge_cells(args)
      "rename-sheet" => run_rename_sheet(args)
      "set-paragraph-text" => run_set_paragraph_text(args)
      "set-paragraph-alignment" => run_set_paragraph_alignment(args)
      "add-textbox" => run_add_textbox(args)
      "remove-shape" => run_remove_shape(args)
      command => print_usage_error("unknown subcommand: " + command)
    }
  }
}

///|
fn print_help() -> Unit {
  println("trkbt10/ooxml " + @ooxml.version())
  println("Usage: ooxml <command> <file> [output]")
  println("")
  println("Commands:")
  println("  info <file>             detect format and print summary")
  println("  open <file>             parse and assert round-trip")
  println("  svg <file>              render to SVG and print to stdout")
  println("  save <file> <output>    round-trip parse and re-emit")
  println("  list <file>             list top-level structural items")
  println(
    "                          (docx: paragraphs, xlsx: sheets, pptx: slides)",
  )
  println("  show <file> <index>     show details of item N (1-based)")
  println("  parts <file>            list OPC parts with content-types")
  println("  extract <file> <part>   write part content to stdout")
  println("  verify <file>           parse, save, re-parse and report drift")
  println("")
  println("Edit commands (write a new package to <output>):")
  println("  set-cell <file> <sheet#> <ref> <text> <output>")
  println(
    "                          set xlsx cell ref (e.g. A1) on sheet N (1-based)",
  )
  println("  append-paragraph <file> <text> <output>")
  println("                          append a docx paragraph at end of body")
  println("  append-text-to-slide <file> <slide#> <text> <output>")
  println(
    "                          append a:p paragraph to first txBody on pptx slide N",
  )
  println("  append-slide <file> <output>")
  println("                          add an empty new slide to a pptx")
  println("  remove-slide <file> <slide#> <output>")
  println("                          remove slide N (1-based) from a pptx")
  println("  append-sheet <file> <name> <output>")
  println("                          add an empty new worksheet to an xlsx")
  println("  remove-sheet <file> <sheet#> <output>")
  println("                          remove sheet N (1-based) from an xlsx")
  println("  clear-cell <file> <sheet#> <ref> <output>")
  println(
    "                          clear xlsx cell ref (e.g. A1) on sheet N (1-based)",
  )
  println("  remove-paragraph <file> <index> <output>")
  println(
    "                          remove docx paragraph at index (1-based) of body",
  )
  println("  svg-for-slide <file> <slide#>")
  println(
    "                          render pptx slide N (1-based) as SVG to stdout",
  )
  println("  set-cell-formula <file> <sheet#> <ref> <formula> <output>")
  println("                          set xlsx <f> formula on a cell")
  println("  merge-cells <file> <sheet#> <range> <output>")
  println(
    "                          add xlsx mergeCells entry for A1:B2-style range",
  )
  println("  rename-sheet <file> <sheet#> <new-name> <output>")
  println("                          set xlsx sheet@name")
  println("  set-paragraph-text <file> <index> <text> <output>")
  println("                          replace docx paragraph N text run")
  println("  set-paragraph-alignment <file> <index> <value> <output>")
  println(
    "                          set docx jc value (left/center/right/both/...)",
  )
  println("  add-textbox <file> <slide#> <x> <y> <w> <h> <text> <output>")
  println(
    "                          add pptx <p:sp> textbox at EMU coordinates",
  )
  println("  remove-shape <file> <slide#> <shape#> <output>")
  println("                          remove pptx shape from spTree")
}

///|
fn print_usage_error(message : String) -> Unit {
  println("error: " + message)
  println("run `ooxml --help` for usage")
}

///|
fn run_info(args : Array[String]) -> Unit {
  if args.length() != 3 {
    print_usage_error("info expects <file>")
  } else {
    try {
      let path = args[2]
      let bytes = @fs.read_file_to_bytes(path)
      match detect_format(path, bytes) {
        Docx => {
          let document = @wml_context.open(bytes)
          println("format: docx")
          println("main_part: " + document.main_part)
          println("headers: " + document.headers.length().to_string())
          println("footers: " + document.footers.length().to_string())
        }
        Xlsx => {
          let workbook = @sml_context.open(bytes)
          let shared_strings = if workbook.shared_strings is Some(_) {
            "yes"
          } else {
            "no"
          }
          println("format: xlsx")
          println("workbook_part: " + workbook.workbook_part)
          println("worksheets: " + workbook.worksheets.length().to_string())
          println("shared_strings: " + shared_strings)
        }
        Pptx => {
          let presentation = @pml_context.open(bytes)
          println("format: pptx")
          println("presentation_part: " + presentation.presentation_part)
          println("slides: " + presentation.slides.length().to_string())
          println(
            "slide_masters: " + presentation.slide_masters.length().to_string(),
          )
        }
      }
    } catch {
      @wml_context.OpenError(kind~, path~, reason~) =>
        println("error: docx: \{kind} @ \{path}: \{reason}")
      @sml_context.OpenError(kind~, path~, reason~) =>
        println("error: xlsx: \{kind} @ \{path}: \{reason}")
      @pml_context.OpenError(kind~, path~, reason~) =>
        println("error: pptx: \{kind} @ \{path}: \{reason}")
      _ => println("error: failed to inspect file")
    }
  }
}

///|
fn run_open(args : Array[String]) -> Unit {
  if args.length() != 3 {
    print_usage_error("open expects <file>")
  } else {
    try {
      let path = args[2]
      let bytes = @fs.read_file_to_bytes(path)
      match detect_format(path, bytes) {
        Docx => {
          let document = @wml_context.open(bytes)
          ignore(@wml_context.open(document.save()))
          println("ok: docx round-trip")
        }
        Xlsx => {
          let workbook = @sml_context.open(bytes)
          ignore(@sml_context.open(workbook.save()))
          println("ok: xlsx round-trip")
        }
        Pptx => {
          let presentation = @pml_context.open(bytes)
          ignore(@pml_context.open(presentation.save()))
          println("ok: pptx round-trip")
        }
      }
    } catch {
      _ => println("error: failed to open file")
    }
  }
}

///|
fn run_svg(args : Array[String]) -> Unit {
  if args.length() != 3 {
    print_usage_error("svg expects <file>")
  } else {
    try {
      let path = args[2]
      let bytes = @fs.read_file_to_bytes(path)
      match detect_format(path, bytes) {
        Docx => println(@wml_context.open(bytes).to_svg())
        Xlsx => println(@sml_context.open(bytes).to_svg())
        Pptx => println(@pml_context.open(bytes).to_svg())
      }
    } catch {
      _ => println("error: failed to convert file to SVG")
    }
  }
}

///|
fn run_save(args : Array[String]) -> Unit {
  if args.length() != 4 {
    print_usage_error("save expects <file> <output>")
  } else {
    try {
      let path = args[2]
      let output = args[3]
      let bytes = @fs.read_file_to_bytes(path)
      let saved = match detect_format(path, bytes) {
        Docx => @wml_context.open(bytes).save()
        Xlsx => @sml_context.open(bytes).save()
        Pptx => @pml_context.open(bytes).save()
      }
      @fs.write_bytes_to_file(output, saved)
      println("saved: " + output)
    } catch {
      _ => println("error: failed to save file")
    }
  }
}

///|
fn run_list(args : Array[String]) -> Unit {
  if args.length() != 3 {
    print_usage_error("list expects <file>")
  } else {
    try {
      let path = args[2]
      let bytes = @fs.read_file_to_bytes(path)
      match detect_format(path, bytes) {
        Docx => {
          let document = @wml_context.open(bytes)
          match document.main.body {
            Some(body) => {
              println(
                "paragraphs: " + body.block_level_elts.length().to_string(),
              )
              let mut i = 0
              for elt in body.block_level_elts {
                i = i + 1
                println(
                  i.to_string() + ": " + elt.source_element().name.local_name,
                )
              }
            }
            None => println("paragraphs: 0 (no body)")
          }
        }
        Xlsx => {
          let workbook = @sml_context.open(bytes)
          println("sheets: " + workbook.worksheets.length().to_string())
          let mut i = 0
          for sheet in workbook.worksheets {
            i = i + 1
            println(i.to_string() + ": " + sheet.name)
          }
        }
        Pptx => {
          let presentation = @pml_context.open(bytes)
          println("slides: " + presentation.slides.length().to_string())
          let mut i = 0
          for slide in presentation.slides {
            i = i + 1
            println(i.to_string() + ": " + slide.name)
          }
        }
      }
    } catch {
      _ => println("error: failed to list file")
    }
  }
}

///|
fn run_show(args : Array[String]) -> Unit {
  if args.length() != 4 {
    print_usage_error("show expects <file> <index>")
  } else {
    try {
      let path = args[2]
      let index_text = args[3]
      let index = @string.parse_int(index_text)
      if index < 1 {
        print_usage_error("index must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        match detect_format(path, bytes) {
          Docx => {
            let document = @wml_context.open(bytes)
            match document.main.body {
              Some(body) => {
                let elts = body.block_level_elts
                if index > elts.length() {
                  println("error: paragraph index out of range")
                } else {
                  show_xml_outline(elts[index - 1].source_element(), 0)
                }
              }
              None => println("error: document has no body")
            }
          }
          Xlsx => {
            let workbook = @sml_context.open(bytes)
            if index > workbook.worksheets.length() {
              println("error: sheet index out of range")
            } else {
              let sheet = workbook.worksheets[index - 1]
              println("name: " + sheet.name)
              show_xml_outline(sheet.value.element, 0)
            }
          }
          Pptx => {
            let presentation = @pml_context.open(bytes)
            if index > presentation.slides.length() {
              println("error: slide index out of range")
            } else {
              let slide = presentation.slides[index - 1]
              println("name: " + slide.name)
              show_xml_outline(slide.value.element, 0)
            }
          }
        }
      }
    } catch {
      _ => println("error: failed to show item")
    }
  }
}

///|
fn run_parts(args : Array[String]) -> Unit {
  if args.length() != 3 {
    print_usage_error("parts expects <file>")
  } else {
    try {
      let path = args[2]
      let bytes = @fs.read_file_to_bytes(path)
      let pkg = @opc.Package::open(bytes)
      for part in pkg.parts {
        println(part.name + "  " + part.content_type)
      }
    } catch {
      _ => println("error: failed to enumerate parts")
    }
  }
}

///|
fn run_extract(args : Array[String]) -> Unit {
  if args.length() != 4 {
    print_usage_error("extract expects <file> <part>")
  } else {
    try {
      let path = args[2]
      let target = args[3]
      let bytes = @fs.read_file_to_bytes(path)
      let pkg = @opc.Package::open(bytes)
      match pkg.part(target) {
        Some(part) => {
          let view = part.data.to_unchecked_string()
          println(view)
        }
        None => println("error: part not found: " + target)
      }
    } catch {
      _ => println("error: failed to extract part")
    }
  }
}

///|
fn run_verify(args : Array[String]) -> Unit {
  if args.length() != 3 {
    print_usage_error("verify expects <file>")
  } else {
    try {
      let path = args[2]
      let bytes = @fs.read_file_to_bytes(path)
      match detect_format(path, bytes) {
        Docx => {
          let document = @wml_context.open(bytes)
          let saved = document.save()
          let reopened = @wml_context.open(saved)
          let parts_before = part_count(@opc.Package::open(bytes))
          let parts_after = part_count(reopened.opc_package)
          println(
            "parts: " +
            parts_before.to_string() +
            " -> " +
            parts_after.to_string(),
          )
          println(
            "headers: " +
            document.headers.length().to_string() +
            ", footers: " +
            document.footers.length().to_string(),
          )
          println("ok: docx verify")
        }
        Xlsx => {
          let workbook = @sml_context.open(bytes)
          let saved = workbook.save()
          let reopened = @sml_context.open(saved)
          let parts_before = part_count(@opc.Package::open(bytes))
          let parts_after = part_count(reopened.opc_package)
          println(
            "parts: " +
            parts_before.to_string() +
            " -> " +
            parts_after.to_string(),
          )
          println("sheets: " + workbook.worksheets.length().to_string())
          println("ok: xlsx verify")
        }
        Pptx => {
          let presentation = @pml_context.open(bytes)
          let saved = presentation.save()
          let reopened = @pml_context.open(saved)
          let parts_before = part_count(@opc.Package::open(bytes))
          let parts_after = part_count(reopened.opc_package)
          println(
            "parts: " +
            parts_before.to_string() +
            " -> " +
            parts_after.to_string(),
          )
          println("slides: " + presentation.slides.length().to_string())
          println("ok: pptx verify")
        }
      }
    } catch {
      _ => println("error: failed to verify file")
    }
  }
}

///|
fn part_count(pkg : @opc.Package) -> Int {
  let mut count = 0
  for _ in pkg.parts {
    count = count + 1
  }
  count
}

///|
fn show_xml_outline(element : @xml.Element, depth : Int) -> Unit {
  if depth > 3 {
    return
  }
  let mut indent = ""
  for _ in 0..<depth {
    indent = indent + "  "
  }
  println(indent + element.name.local_name)
  for child in element.children {
    match child {
      @xml.Element(e) => show_xml_outline(e, depth + 1)
      _ => ()
    }
  }
}

///|
fn run_set_cell(args : Array[String]) -> Unit {
  if args.length() != 7 {
    print_usage_error("set-cell expects <file> <sheet#> <ref> <text> <output>")
  } else {
    try {
      let path = args[2]
      let sheet_text = args[3]
      let cell_ref = args[4]
      let text = args[5]
      let output = args[6]
      let sheet_index = @string.parse_int(sheet_text)
      if sheet_index < 1 {
        print_usage_error("sheet# must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        let workbook = @sml_context.open(bytes)
        let modified = @sml_edit.set_cell_value(
          workbook,
          sheet_index - 1,
          cell_ref,
          text,
        )
        @fs.write_bytes_to_file(output, modified.save())
        println(
          "saved: " +
          output +
          " (sheet " +
          sheet_index.to_string() +
          ", " +
          cell_ref +
          ")",
        )
      }
    } catch {
      _ => println("error: failed to set cell")
    }
  }
}

///|
fn run_append_paragraph(args : Array[String]) -> Unit {
  if args.length() != 5 {
    print_usage_error("append-paragraph expects <file> <text> <output>")
  } else {
    try {
      let path = args[2]
      let text = args[3]
      let output = args[4]
      let bytes = @fs.read_file_to_bytes(path)
      let document = @wml_context.open(bytes)
      let modified = @wml_edit.append_paragraph(document, text)
      @fs.write_bytes_to_file(output, modified.save())
      println("saved: " + output)
    } catch {
      _ => println("error: failed to append paragraph")
    }
  }
}

///|
fn run_append_text_to_slide(args : Array[String]) -> Unit {
  if args.length() != 6 {
    print_usage_error(
      "append-text-to-slide expects <file> <slide#> <text> <output>",
    )
  } else {
    try {
      let path = args[2]
      let slide_text = args[3]
      let text = args[4]
      let output = args[5]
      let slide_index = @string.parse_int(slide_text)
      if slide_index < 1 {
        print_usage_error("slide# must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        let presentation = @pml_context.open(bytes)
        let modified = @pml_edit.append_text_to_slide(
          presentation,
          slide_index - 1,
          text,
        )
        @fs.write_bytes_to_file(output, modified.save())
        println("saved: " + output + " (slide " + slide_index.to_string() + ")")
      }
    } catch {
      _ => println("error: failed to append text to slide")
    }
  }
}

///|
fn run_clear_cell(args : Array[String]) -> Unit {
  if args.length() != 6 {
    print_usage_error("clear-cell expects <file> <sheet#> <ref> <output>")
  } else {
    try {
      let path = args[2]
      let sheet_text = args[3]
      let cell_ref = args[4]
      let output = args[5]
      let sheet_index = @string.parse_int(sheet_text)
      if sheet_index < 1 {
        print_usage_error("sheet# must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        let workbook = @sml_context.open(bytes)
        let cleared = @sml_edit.clear_cell(workbook, sheet_index - 1, cell_ref)
        @fs.write_bytes_to_file(output, cleared.save())
        println("saved: " + output)
      }
    } catch {
      _ => println("error: failed to clear cell")
    }
  }
}

///|
fn run_remove_paragraph(args : Array[String]) -> Unit {
  if args.length() != 5 {
    print_usage_error("remove-paragraph expects <file> <index> <output>")
  } else {
    try {
      let path = args[2]
      let index_text = args[3]
      let output = args[4]
      let index = @string.parse_int(index_text)
      if index < 1 {
        print_usage_error("index must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        let document = @wml_context.open(bytes)
        let modified = @wml_edit.remove_paragraph(document, index - 1)
        @fs.write_bytes_to_file(output, modified.save())
        println("saved: " + output)
      }
    } catch {
      _ => println("error: failed to remove paragraph")
    }
  }
}

///|
fn run_append_slide(args : Array[String]) -> Unit {
  if args.length() != 4 {
    print_usage_error("append-slide expects <file> <output>")
  } else {
    try {
      let path = args[2]
      let output = args[3]
      let bytes = @fs.read_file_to_bytes(path)
      let presentation = @pml_context.open(bytes)
      let modified = @pml_edit.append_slide(presentation)
      @fs.write_bytes_to_file(output, modified.save())
      println("saved: " + output)
    } catch {
      _ => println("error: failed to append slide")
    }
  }
}

///|
fn run_remove_slide(args : Array[String]) -> Unit {
  if args.length() != 5 {
    print_usage_error("remove-slide expects <file> <slide#> <output>")
  } else {
    try {
      let path = args[2]
      let slide_text = args[3]
      let output = args[4]
      let slide_index = @string.parse_int(slide_text)
      if slide_index < 1 {
        print_usage_error("slide# must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        let presentation = @pml_context.open(bytes)
        let modified = @pml_edit.remove_slide(presentation, slide_index - 1)
        @fs.write_bytes_to_file(output, modified.save())
        println("saved: " + output)
      }
    } catch {
      _ => println("error: failed to remove slide")
    }
  }
}

///|
fn run_append_sheet(args : Array[String]) -> Unit {
  if args.length() != 5 {
    print_usage_error("append-sheet expects <file> <name> <output>")
  } else {
    try {
      let path = args[2]
      let name = args[3]
      let output = args[4]
      let bytes = @fs.read_file_to_bytes(path)
      let workbook = @sml_context.open(bytes)
      let modified = @sml_edit.append_sheet(workbook, name)
      @fs.write_bytes_to_file(output, modified.save())
      println("saved: " + output)
    } catch {
      _ => println("error: failed to append sheet")
    }
  }
}

///|
fn run_remove_sheet(args : Array[String]) -> Unit {
  if args.length() != 5 {
    print_usage_error("remove-sheet expects <file> <sheet#> <output>")
  } else {
    try {
      let path = args[2]
      let sheet_text = args[3]
      let output = args[4]
      let sheet_index = @string.parse_int(sheet_text)
      if sheet_index < 1 {
        print_usage_error("sheet# must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        let workbook = @sml_context.open(bytes)
        let modified = @sml_edit.remove_sheet(workbook, sheet_index - 1)
        @fs.write_bytes_to_file(output, modified.save())
        println("saved: " + output)
      }
    } catch {
      _ => println("error: failed to remove sheet")
    }
  }
}

///|
fn run_svg_for_slide(args : Array[String]) -> Unit {
  if args.length() != 4 {
    print_usage_error("svg-for-slide expects <file> <slide#>")
  } else {
    try {
      let path = args[2]
      let slide_text = args[3]
      let slide_index = @string.parse_int(slide_text)
      if slide_index < 1 {
        print_usage_error("slide# must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        let presentation = @pml_context.open(bytes)
        println(presentation.to_svg_for_slide(slide_index - 1))
      }
    } catch {
      _ => println("error: failed to render svg for slide")
    }
  }
}

///|
fn run_set_cell_formula(args : Array[String]) -> Unit {
  if args.length() != 7 {
    print_usage_error(
      "set-cell-formula expects <file> <sheet#> <ref> <formula> <output>",
    )
  } else {
    try {
      let bytes = @fs.read_file_to_bytes(args[2])
      let sheet_index = @string.parse_int(args[3])
      if sheet_index < 1 {
        print_usage_error("sheet# must be >= 1")
      } else {
        let w = @sml_edit.set_cell_formula(
          @sml_context.open(bytes),
          sheet_index - 1,
          args[4],
          args[5],
        )
        @fs.write_bytes_to_file(args[6], w.save())
        println("saved: " + args[6])
      }
    } catch {
      _ => println("error: failed to set formula")
    }
  }
}

///|
fn run_merge_cells(args : Array[String]) -> Unit {
  if args.length() != 6 {
    print_usage_error("merge-cells expects <file> <sheet#> <range> <output>")
  } else {
    try {
      let bytes = @fs.read_file_to_bytes(args[2])
      let sheet_index = @string.parse_int(args[3])
      if sheet_index < 1 {
        print_usage_error("sheet# must be >= 1")
      } else {
        let w = @sml_edit.merge_cells(
          @sml_context.open(bytes),
          sheet_index - 1,
          args[4],
        )
        @fs.write_bytes_to_file(args[5], w.save())
        println("saved: " + args[5])
      }
    } catch {
      _ => println("error: failed to merge cells")
    }
  }
}

///|
fn run_rename_sheet(args : Array[String]) -> Unit {
  if args.length() != 6 {
    print_usage_error(
      "rename-sheet expects <file> <sheet#> <new-name> <output>",
    )
  } else {
    try {
      let bytes = @fs.read_file_to_bytes(args[2])
      let sheet_index = @string.parse_int(args[3])
      if sheet_index < 1 {
        print_usage_error("sheet# must be >= 1")
      } else {
        let w = @sml_edit.rename_sheet(
          @sml_context.open(bytes),
          sheet_index - 1,
          args[4],
        )
        @fs.write_bytes_to_file(args[5], w.save())
        println("saved: " + args[5])
      }
    } catch {
      _ => println("error: failed to rename sheet")
    }
  }
}

///|
fn run_set_paragraph_text(args : Array[String]) -> Unit {
  if args.length() != 6 {
    print_usage_error(
      "set-paragraph-text expects <file> <index> <text> <output>",
    )
  } else {
    try {
      let bytes = @fs.read_file_to_bytes(args[2])
      let index = @string.parse_int(args[3])
      if index < 1 {
        print_usage_error("index must be >= 1")
      } else {
        let d = @wml_edit.set_paragraph_text(
          @wml_context.open(bytes),
          index - 1,
          args[4],
        )
        @fs.write_bytes_to_file(args[5], d.save())
        println("saved: " + args[5])
      }
    } catch {
      _ => println("error: failed to set paragraph text")
    }
  }
}

///|
fn run_set_paragraph_alignment(args : Array[String]) -> Unit {
  if args.length() != 6 {
    print_usage_error(
      "set-paragraph-alignment expects <file> <index> <value> <output>",
    )
  } else {
    try {
      let bytes = @fs.read_file_to_bytes(args[2])
      let index = @string.parse_int(args[3])
      if index < 1 {
        print_usage_error("index must be >= 1")
      } else {
        let d = @wml_edit.set_paragraph_alignment(
          @wml_context.open(bytes),
          index - 1,
          args[4],
        )
        @fs.write_bytes_to_file(args[5], d.save())
        println("saved: " + args[5])
      }
    } catch {
      _ => println("error: failed to set paragraph alignment")
    }
  }
}

///|
fn run_add_textbox(args : Array[String]) -> Unit {
  if args.length() != 10 {
    print_usage_error(
      "add-textbox expects <file> <slide#> <x> <y> <w> <h> <text> <output>",
    )
  } else {
    try {
      let bytes = @fs.read_file_to_bytes(args[2])
      let slide_index = @string.parse_int(args[3])
      let x = @string.parse_int(args[4])
      let y = @string.parse_int(args[5])
      let w = @string.parse_int(args[6])
      let h = @string.parse_int(args[7])
      if slide_index < 1 {
        print_usage_error("slide# must be >= 1")
      } else {
        let p = @pml_edit.add_textbox(
          @pml_context.open(bytes),
          slide_index - 1,
          x,
          y,
          w,
          h,
          args[8],
        )
        @fs.write_bytes_to_file(args[9], p.save())
        println("saved: " + args[9])
      }
    } catch {
      _ => println("error: failed to add textbox")
    }
  }
}

///|
fn run_remove_shape(args : Array[String]) -> Unit {
  if args.length() != 6 {
    print_usage_error("remove-shape expects <file> <slide#> <shape#> <output>")
  } else {
    try {
      let bytes = @fs.read_file_to_bytes(args[2])
      let slide_index = @string.parse_int(args[3])
      let shape_index = @string.parse_int(args[4])
      if slide_index < 1 || shape_index < 1 {
        print_usage_error("indices must be >= 1")
      } else {
        let p = @pml_edit.remove_shape(
          @pml_context.open(bytes),
          slide_index - 1,
          shape_index - 1,
        )
        @fs.write_bytes_to_file(args[5], p.save())
        println("saved: " + args[5])
      }
    } catch {
      _ => println("error: failed to remove shape")
    }
  }
}

///|
fn detect_format(path : String, bytes : Bytes) -> Format raise {
  let lower = path.to_lower()
  if lower.has_suffix(".docx") {
    Docx
  } else if lower.has_suffix(".xlsx") {
    Xlsx
  } else if lower.has_suffix(".pptx") {
    Pptx
  } else {
    detect_format_by_content_types(bytes)
  }
}

///|
fn detect_format_by_content_types(bytes : Bytes) -> Format raise {
  let pkg = @opc.Package::open(bytes)
  for part in pkg.parts {
    if part.content_type ==
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml" {
      return Docx
    }
    if part.content_type ==
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml" {
      return Xlsx
    }
    if part.content_type ==
      "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml" {
      return Pptx
    }
  }
  fail("unknown OOXML format")
}
