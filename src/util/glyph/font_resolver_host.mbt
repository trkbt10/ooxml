// Host-OS FontResolver driver.
//
// Uses `trkbt10/osenv` to detect the running platform and locate
// the OS-canonical font directories without hard-coding paths.
// The driver scans those dirs (cached at construction time),
// indexing every `.ttf` / `.ttc` it finds by the same
// filename convention `font_resolver_envdir.mbt` uses.
//
// Discovery dirs:
//
//   MacOS:   /System/Library/Fonts (+ Supplemental), /Library/Fonts,
//            $HOME/Library/Fonts
//   Linux:   /usr/share/fonts (+ truetype/opentype/TTF/OTF),
//            /usr/local/share/fonts, $HOME/.local/share/fonts,
//            $HOME/.fonts
//   Windows: %SYSTEMROOT%\Fonts,
//            %LOCALAPPDATA%\Microsoft\Windows\Fonts
//
// The renderer-side ECMA-376 substitution chain (embedded → name →
// altName → panose → family-generic) is applied BEFORE this
// driver runs; here we only answer "does the host carry this
// family at this weight/italic".

///|
/// Build a resolver that scans the host's OS-canonical font dirs.
/// The driver label names the platform that was detected so a
/// missing-font error message reads e.g.
/// `composite(envdir(...), host(MacOS), ...)`.
pub fn FontResolver::host() -> FontResolver {
  let platform = @platform.platform()
  let dirs = host_font_dirs(platform)
  let font_index : Map[String, String] = Map([], capacity=32)
  for dir in dirs {
    populate_font_index(font_index, dir)
  }
  let label = "host(" + platform.to_string() + ")"
  {
    label,
    resolve: request => {
      match request.embedded_bytes {
        Some(b) =>
          return { bytes: b, ttc_index: None, source_label: "embedded" }
        None => ()
      }
      if font_index.is_empty() {
        raise FontUnresolvedError(request~, driver_labels=[label])
      }
      for candidate in request.stack {
        match candidate {
          Name(n) => {
            let key = font_index_key_for(n, request.weight, request.italic)
            match font_index.get(key) {
              Some(path) =>
                match try_read_resource(path) {
                  Some(res) => return res
                  None => continue
                }
              None => continue
            }
          }
          Generic(_) => continue
        }
      }
      raise FontUnresolvedError(request~, driver_labels=[label])
    },
  }
}

///|
/// OS-canonical font directories for `platform`. The `home_dir()`
/// lookup is best-effort: when osenv cannot determine the home
/// directory the user-scoped dirs are silently dropped.
fn host_font_dirs(platform : @platform.Platform) -> Array[String] {
  let home_opt = @dirs.home_dir()
  let dirs : Array[String] = []
  match platform {
    @platform.MacOS => {
      dirs.push("/System/Library/Fonts")
      dirs.push("/System/Library/Fonts/Supplemental")
      dirs.push("/Library/Fonts")
      match home_opt {
        Some(h) =>
          try @path.join([h, "Library", "Fonts"]) catch {
            _ => ()
          } noraise {
            p => dirs.push(p)
          }
        None => ()
      }
    }
    @platform.Linux => {
      // Most distros install fonts under /usr/share/fonts and its
      // typed subdirs; the indexer does not recurse, so the common
      // subdirs are enumerated explicitly.
      dirs.push("/usr/share/fonts")
      dirs.push("/usr/share/fonts/truetype")
      dirs.push("/usr/share/fonts/opentype")
      dirs.push("/usr/share/fonts/TTF")
      dirs.push("/usr/share/fonts/OTF")
      dirs.push("/usr/local/share/fonts")
      match home_opt {
        Some(h) => {
          try @path.join([h, ".local", "share", "fonts"]) catch {
            _ => ()
          } noraise {
            p => dirs.push(p)
          }
          try @path.join([h, ".fonts"]) catch {
            _ => ()
          } noraise {
            p => dirs.push(p)
          }
        }
        None => ()
      }
    }
    @platform.Windows => {
      let sysroot = @env.get_env_var("SYSTEMROOT").unwrap_or("C:\\Windows")
      try @path.join([sysroot, "Fonts"]) catch {
        _ => ()
      } noraise {
        p => dirs.push(p)
      }
      match @env.get_env_var("LOCALAPPDATA") {
        Some(la) =>
          try @path.join([la, "Microsoft", "Windows", "Fonts"]) catch {
            _ => ()
          } noraise {
            p => dirs.push(p)
          }
        None => ()
      }
    }
    @platform.Unknown => ()
  }
  dirs
}

///|
/// Standard wiring point: EnvDir first (operator-supplied font
/// directories take precedence), then the host driver. Both raise
/// on miss so the composite walks them in order and the caller sees
/// a single well-formed error naming every driver consulted.
pub fn create_host_font_resolver() -> FontResolver {
  FontResolver::compose([FontResolver::env_dir(), FontResolver::host()])
}
