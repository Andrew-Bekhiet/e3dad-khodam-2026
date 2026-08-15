/// Compile-time feature flags. Kept as a dedicated class, rather than
/// scattered booleans, so every toggle affecting shipped behavior is
/// visible in one place.
final class AppFeatures {
  /// Whether the app bar exposes the "أشخاص وموضوعات أخرى" action that
  /// opens the non-geographic recipients sheet. Off by default: those
  /// entries have no map presence, so surfacing them is optional chrome.
  static const bool showNonGeographicGroups = false;

  /// Whether the map itself blurs while the camera sweeps between
  /// destinations. **Set this to `false` to turn the motion blur off.**
  ///
  /// Web only, and not for want of trying elsewhere: the map is a
  /// platform view, so Flutter never owns its pixels and neither
  /// `ImageFiltered` nor `BackdropFilter` can reach it. On web the
  /// surface blurs the map's own container through CSS instead.
  ///
  /// Turning this off leaves the streaks and the vignette
  /// (`SweepOverlay`) running — they are drawn by Flutter and are what
  /// carries the motion on every other platform.
  static const bool sweepMotionBlur = false;
}
