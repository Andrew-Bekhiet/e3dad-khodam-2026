/// Compile-time feature flags. Kept as a dedicated class, rather than
/// scattered booleans, so every toggle affecting shipped behavior is
/// visible in one place.
final class AppFeatures {
  /// Whether the app bar exposes the "أشخاص وموضوعات أخرى" action that
  /// opens the non-geographic recipients sheet. Off by default: those
  /// entries have no map presence, so surfacing them is optional chrome.
  static const bool showNonGeographicGroups = false;
}
