// §20.1.10.47 ST_PresetCameraType — every named camera preset maps to
// a concrete 2D approximation; only the head-on `*Front` cameras stay
// at identity, and unknown values fall back to identity.

///|
test "every directional camera preset yields a non-identity transform" {
  let directional = [
    // isometric
    "isometricTopUp", "isometricTopDown", "isometricBottomUp",
    "isometricBottomDown", "isometricLeftUp", "isometricLeftDown",
    "isometricRightUp", "isometricRightDown", "isometricOffAxis1Left",
    "isometricOffAxis1Right", "isometricOffAxis1Top", "isometricOffAxis2Left",
    "isometricOffAxis2Right", "isometricOffAxis2Top", "isometricOffAxis3Left",
    "isometricOffAxis3Right", "isometricOffAxis3Bottom",
    "isometricOffAxis4Left", "isometricOffAxis4Right",
    "isometricOffAxis4Bottom",
    // oblique + legacy oblique (Front excluded)
    "obliqueTopLeft", "obliqueTop", "obliqueTopRight", "obliqueLeft",
    "obliqueRight", "obliqueBottomLeft", "obliqueBottom", "obliqueBottomRight",
    "legacyObliqueTopLeft", "legacyObliqueTop", "legacyObliqueTopRight",
    "legacyObliqueLeft", "legacyObliqueRight", "legacyObliqueBottomLeft",
    "legacyObliqueBottom", "legacyObliqueBottomRight",
    // perspective + legacy perspective (Front excluded)
    "perspectiveRelaxed", "perspectiveRelaxedModerately", "perspectiveAbove",
    "perspectiveBelow", "perspectiveLeft", "perspectiveRight",
    "legacyPerspectiveTop", "legacyPerspectiveBottom", "legacyPerspectiveLeft",
    "legacyPerspectiveRight", "legacyPerspectiveTopLeft",
    "legacyPerspectiveTopRight", "legacyPerspectiveBottomLeft",
    "legacyPerspectiveBottomRight", "perspectiveAboveLeftFacing",
    "perspectiveAboveRightFacing", "perspectiveContrastingLeftFacing",
    "perspectiveContrastingRightFacing", "perspectiveHeroicLeftFacing",
    "perspectiveHeroicRightFacing", "perspectiveHeroicExtremeLeftFacing",
    "perspectiveHeroicExtremeRightFacing",
  ]
  for p in directional {
    let t = calculate_camera_transform(p)
    if transform3d_is_identity(t) {
      fail("camera preset \{p} unexpectedly mapped to the identity transform")
    }
  }
}

///|
test "head-on and unknown camera presets are identity" {
  // The head-on cameras are genuinely a straight projection.
  for p in ["orthographicFront", "legacyObliqueFront"] {
    assert_true(transform3d_is_identity(calculate_camera_transform(p)))
  }
  // `perspectiveFront` / `legacyPerspectiveFront` apply only a depth
  // scale, so they ARE non-identity (foreshortened) — sanity check the
  // boundary.
  assert_true(!transform3d_is_identity(calculate_camera_transform("perspectiveFront")))
  // A schema-violating value falls back to identity.
  assert_true(transform3d_is_identity(calculate_camera_transform("notACamera")))
}
