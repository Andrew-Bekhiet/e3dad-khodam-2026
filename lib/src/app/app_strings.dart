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

  /// Exact OSM attribution string required by the tile usage policy
  /// (spec §8). The OSM map surface renders this itself; kept here too
  /// as the single catalog entry for the app's fixed copy.
  static const String attributionText = '© OpenStreetMap contributors';
}
