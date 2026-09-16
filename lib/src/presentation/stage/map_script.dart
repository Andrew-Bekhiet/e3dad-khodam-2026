import 'package:e3dad_khodam_2026/src/app/app_strings.dart';

/// The five scripts the map stage can play, sharing one Mapbox surface.
enum MapScript {
  /// The Cross Map: the app's original reference hierarchy.
  crossMap,

  /// Paul's second journey.
  secondJourney,

  /// Paul's third journey.
  thirdJourney,

  /// The voyage to رومية.
  romeJourney,

  /// The guided Post Office game, opened as its own screen.
  postOfficeGame;

  /// The button label the stage shows for this script.
  String get label => switch (this) {
    MapScript.crossMap => AppStrings.crossMapScriptLabel,
    MapScript.secondJourney => 'الرحلة التبشيرية الثانية',
    MapScript.thirdJourney => 'الرحلة التبشيرية الثالثة',
    MapScript.romeJourney => 'الرحلة إلى رومية',
    MapScript.postOfficeGame => AppStrings.gameTitle,
  };

  String get shortLabel => switch (this) {
    MapScript.crossMap => AppStrings.crossMapScriptLabel,
    MapScript.secondJourney => 'الرحلة ٢',
    MapScript.thirdJourney => 'الرحلة ٣',
    MapScript.romeJourney => 'إلى رومية',
    MapScript.postOfficeGame => '',
  };
}
