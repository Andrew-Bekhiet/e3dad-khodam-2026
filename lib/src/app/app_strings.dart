/// Arabic chrome copy — everything the UI says that isn't a place name.
/// Place names live in the dataset (they're data, not chrome); this class
/// only holds fixed app strings so translators/reviewers have one place
/// to check them against the design spec.
final class AppStrings {
  /// Root app-bar title (spec §9), also the `MaterialApp.title`.
  static const String appTitle = 'خريطة رحلات بولس الرسول';

  /// Title of the non-geographic-recipients bottom sheet (spec §9), and
  /// the tooltip on the app-bar action that opens it — spec uses the
  /// same string for both.
  static const String nonGeographicSheetTitle = 'أشخاص وموضوعات أخرى';

  /// Tooltip on the app-bar "go up one level" back button. Not pinned by
  /// the design spec's text; chosen as the conventional Arabic label for
  /// this action.
  static const String backButtonTooltip = 'رجوع';

  /// Title of the guided game screen, and the tooltip on the app-bar
  /// action that opens it.
  static const String gameTitle = 'لعبة post office';

  /// The word "level", prefixed to the level counter in the game HUD.
  static const String levelWord = 'المرحلة';

  /// Cue under a story line telling the player how to move on.
  static const String continueHint = 'اضغط للمتابعة';

  /// Tooltip on the "step back" arrow, on both the map and the game.
  static const String backwardTooltip = 'السابق';

  /// Tooltip on the "step forward" arrow, on both the map and the game.
  static const String forwardTooltip = 'التالي';

  /// Tooltip on the game's "start over" action.
  static const String restartTooltip = 'من البداية';

  /// Exact OSM attribution string required by the tile usage policy
  /// (spec §8). The OSM map surface renders this itself; kept here too
  /// as the single catalog entry for the app's fixed copy.
  static const String attributionText = '© OpenStreetMap contributors';
}
