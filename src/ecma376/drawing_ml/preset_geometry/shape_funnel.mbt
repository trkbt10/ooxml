// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `funnel`.

///|
/// §20.1.10.56 `funnel` — a funnel: a wide ellipse rim at the top that
/// tapers down to a narrow vertical tube at the bottom.
///
/// FAITHFUL transcription of the spec path, evaluated by the
/// data-driven `guide_engine` from the verbatim spec definition. The
/// body is the rim arc (radii `wd2 × hd4`) tapering via a `lnTo` down
/// to the spout arc (radii `rw3 × rh3`), and the rim opening is a
/// second full ellipse (radii `rw2 × rh2`, the rim minus the wall
/// thickness `d = ss/20`). The taper angle `da = at2(wd2, hd4)` and the
/// ellipse-radius-at-angle corrections `n1`/`n3` come from
/// `at2`/`mod`/`cos`/`sin`. No avLst adjustments.
pub fn build_funnel(width : Int, height : Int) -> ShapeGeometry {
  build_from_definition(
    {
      adjusts: [],
      guides: [
        ("d", "*/ ss 1 20"),
        ("rw2", "+- wd2 0 d"),
        ("rh2", "+- hd4 0 d"),
        ("t1", "cos wd2 480000"),
        ("t2", "sin hd4 480000"),
        ("da", "at2 t1 t2"),
        ("2da", "*/ da 2 1"),
        ("stAng1", "+- cd2 0 da"),
        ("swAng1", "+- cd2 2da 0"),
        ("swAng3", "+- cd2 0 2da"),
        ("rw3", "*/ wd2 1 4"),
        ("rh3", "*/ hd4 1 4"),
        ("ct1", "cos hd4 stAng1"),
        ("st1", "sin wd2 stAng1"),
        ("m1", "mod ct1 st1 0"),
        ("n1", "*/ wd2 hd4 m1"),
        ("dx1", "cos n1 stAng1"),
        ("dy1", "sin n1 stAng1"),
        ("x1", "+- hc dx1 0"),
        ("y1", "+- hd4 dy1 0"),
        ("ct3", "cos rh3 da"),
        ("st3", "sin rw3 da"),
        ("m3", "mod ct3 st3 0"),
        ("n3", "*/ rw3 rh3 m3"),
        ("dx3", "cos n3 da"),
        ("dy3", "sin n3 da"),
        ("x3", "+- hc dx3 0"),
        ("vc3", "+- b 0 rh3"),
        ("y2", "+- vc3 dy3 0"),
        ("x2", "+- wd2 0 rw2"),
        ("cd", "*/ cd2 2 1"),
      ],
      path: [
        PMoveTo("x1", "y1"),
        PArcTo("wd2", "hd4", "stAng1", "swAng1"),
        PLnTo("x3", "y2"),
        PArcTo("rw3", "rh3", "da", "swAng3"),
        PClose,
        PMoveTo("x2", "hd4"),
        PArcTo("rw2", "rh2", "cd2", "-21600000"),
        PClose,
      ],
    },
    width,
    height,
    [],
  )
}
