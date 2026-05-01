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
  println("  info <file>          detect format and print summary")
  println("  open <file>          parse and assert round-trip")
  println("  html <file>          convert to HTML and print to stdout")
  println("  svg <file>           convert to SVG and print to stdout")
  println("  save <file> <output> round-trip parse and re-emit")
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
