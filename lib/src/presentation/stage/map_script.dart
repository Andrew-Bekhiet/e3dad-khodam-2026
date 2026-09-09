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
    MapScript.secondJourney => AppStrings.secondJourneyScriptLabel,
    MapScript.thirdJourney => AppStrings.thirdJourneyScriptLabel,
    MapScript.romeJourney => AppStrings.romeJourneyScriptLabel,
    MapScript.postOfficeGame => AppStrings.gameTitle,
  };
}
