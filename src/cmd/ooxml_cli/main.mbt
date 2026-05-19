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
      "html" => run_html(args)
      "svg" => run_svg(args)
      "save" => run_save(args)
      "list" => run_list(args)
      "show" => run_show(args)
      "extract" => run_extract(args)
      "verify" => run_verify(args)
      "parts" => run_parts(args)
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
  println("  html <file>             convert to HTML and print to stdout")
  println("  svg <file>              convert to SVG and print to stdout")
  println("  save <file> <output>    round-trip parse and re-emit")
  println("  list <file>             list top-level structural items")
  println(
    "                          (docx: paragraphs, xlsx: sheets, pptx: slides)",
  )
  println("  show <file> <index>     show details of item N (1-based)")
  println("  parts <file>            list OPC parts with content-types")
  println("  extract <file> <part>   write part content to stdout")
  println("  verify <file>           parse, save, re-parse and report drift")
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
          let document = @docx.open(bytes)
          println("format: docx")
          println("main_part: " + document.main_part)
          println("headers: " + document.headers.length().to_string())
          println("footers: " + document.footers.length().to_string())
        }
        Xlsx => {
          let workbook = @xlsx.open(bytes)
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
          let presentation = @pptx.open(bytes)
          println("format: pptx")
          println("presentation_part: " + presentation.presentation_part)
          println("slides: " + presentation.slides.length().to_string())
          println(
            "slide_masters: " + presentation.slide_masters.length().to_string(),
          )
        }
      }
    } catch {
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
          let document = @docx.open(bytes)
          ignore(@docx.open(document.save()))
          println("ok: docx round-trip")
        }
        Xlsx => {
          let workbook = @xlsx.open(bytes)
          ignore(@xlsx.open(workbook.save()))
          println("ok: xlsx round-trip")
        }
        Pptx => {
          let presentation = @pptx.open(bytes)
          ignore(@pptx.open(presentation.save()))
          println("ok: pptx round-trip")
        }
      }
    } catch {
      _ => println("error: failed to open file")
    }
  }
}

///|
fn run_html(args : Array[String]) -> Unit {
  if args.length() != 3 {
    print_usage_error("html expects <file>")
  } else {
    try {
      let path = args[2]
      let bytes = @fs.read_file_to_bytes(path)
      match detect_format(path, bytes) {
        Docx => println(@docx.open(bytes).to_html())
        Xlsx => println(@xlsx.open(bytes).to_html())
        Pptx => println(@pptx.open(bytes).to_html())
      }
    } catch {
      _ => println("error: failed to convert file to HTML")
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
        Docx => println(@docx.open(bytes).to_svg())
        Xlsx => println(@xlsx.open(bytes).to_svg())
        Pptx => println(@pptx.open(bytes).to_svg())
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
        Docx => @docx.open(bytes).save()
        Xlsx => @xlsx.open(bytes).save()
        Pptx => @pptx.open(bytes).save()
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
          let document = @docx.open(bytes)
          match document.main.body {
            Some(body) => {
              println(
                "paragraphs: " +
                body.block_level_elts.elements.length().to_string(),
              )
              let mut i = 0
              for elt in body.block_level_elts.elements {
                i = i + 1
                println(i.to_string() + ": " + elt.name.local_name)
              }
            }
            None => println("paragraphs: 0 (no body)")
          }
        }
        Xlsx => {
          let workbook = @xlsx.open(bytes)
          println("sheets: " + workbook.worksheets.length().to_string())
          let mut i = 0
          for sheet in workbook.worksheets {
            i = i + 1
            println(i.to_string() + ": " + sheet.name)
          }
        }
        Pptx => {
          let presentation = @pptx.open(bytes)
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
      let index = @strconv.parse_int(index_text)
      if index < 1 {
        print_usage_error("index must be >= 1")
      } else {
        let bytes = @fs.read_file_to_bytes(path)
        match detect_format(path, bytes) {
          Docx => {
            let document = @docx.open(bytes)
            match document.main.body {
              Some(body) => {
                let elts = body.block_level_elts.elements
                if index > elts.length() {
                  println("error: paragraph index out of range")
                } else {
                  show_xml_outline(elts[index - 1], 0)
                }
              }
              None => println("error: document has no body")
            }
          }
          Xlsx => {
            let workbook = @xlsx.open(bytes)
            if index > workbook.worksheets.length() {
              println("error: sheet index out of range")
            } else {
              let sheet = workbook.worksheets[index - 1]
              println("name: " + sheet.name)
              show_xml_outline(sheet.value.element, 0)
            }
          }
          Pptx => {
            let presentation = @pptx.open(bytes)
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
          let document = @docx.open(bytes)
          let saved = document.save()
          let reopened = @docx.open(saved)
          let parts_before = part_count(@opc.Package::open(bytes))
          let parts_after = part_count(reopened.package)
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
          let workbook = @xlsx.open(bytes)
          let saved = workbook.save()
          let reopened = @xlsx.open(saved)
          let parts_before = part_count(@opc.Package::open(bytes))
          let parts_after = part_count(reopened.package)
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
          let presentation = @pptx.open(bytes)
          let saved = presentation.save()
          let reopened = @pptx.open(saved)
          let parts_before = part_count(@opc.Package::open(bytes))
          let parts_after = part_count(reopened.package)
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
