// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartMagneticTape`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartMagneticTape` — a circle with a short
/// straight "foot" extending out of its lower-right side, denoting a
/// magnetic tape in a flow chart.
///
/// Spec path: the body sweeps 270° around the bounding-box ellipse
/// from the bottom point (hc,b) anticlockwise through the left and
/// top to the right point (r,vc), then a partial arc of `ang1 =
/// atan2(w,h)`, then lnTo (r,ib) and lnTo (r,b) forming the foot.
///
/// FAITHFUL transcription of the spec path, evaluated by the
/// data-driven `guide_engine` from the verbatim spec definition: the
/// body is three quarter `arcTo`s (bottom → left → top → right) plus a
/// partial `arcTo` of `ang1 = at2(w, h)` that meets the foot, then
/// `lnTo (r, ib)` and `lnTo (r, b)` close the small lower-right foot
/// (`ib = vc + sin(45°)·hd2`). No avLst adjustments.
pub fn build_flow_chart_magnetic_tape(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  build_from_definition(
    {
      adjusts: [],
      guides: [
        ("idx", "cos wd2 2700000"),
        ("idy", "sin hd2 2700000"),
        ("il", "+- hc 0 idx"),
        ("ir", "+- hc idx 0"),
        ("it", "+- vc 0 idy"),
        ("ib", "+- vc idy 0"),
        ("ang1", "at2 w h"),
      ],
      path: [
        PMoveTo("hc", "b"),
        PArcTo("wd2", "hd2", "cd4", "cd4"),
        PArcTo("wd2", "hd2", "cd2", "cd4"),
        PArcTo("wd2", "hd2", "3cd4", "cd4"),
        PArcTo("wd2", "hd2", "0", "ang1"),
        PLnTo("r", "ib"),
        PLnTo("r", "b"),
        PClose,
      ],
    },
    width,
    height,
    [],
  )
}
