import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// Every place the post-office journey stops at, with its real-world
/// coordinates.
///
/// The shared cities repeat the numbers in the design spec's coordinate
/// appendix rather than reading them off `StPaulMapDataset`: the game is
/// free to visit places the mnemonic cross never lists (أورشليم), so it
/// keeps its own gazetteer instead of half-depending on the tree's.
final class JourneyStops {
  /// تسالونيكي — the first two letters.
  static const JourneyStop thessalonica = JourneyStop(
    id: 'thessalonica',
    label: 'تسالونيكي',
    position: GeoPosition(latitude: 40.64, longitude: 22.94),
  );

  /// كورنثوس — the two Corinthian letters, and where both letters to
  /// Thessalonica were written from.
  static const JourneyStop corinth = JourneyStop(
    id: 'corinth',
    label: 'كورنثوس',
    position: GeoPosition(latitude: 37.91, longitude: 22.88),
  );

  /// غلاطية.
  static const JourneyStop galatia = JourneyStop(
    id: 'galatia',
    label: 'غلاطية',
    position: GeoPosition(latitude: 39.5, longitude: 32.9),
  );

  /// رومية.
  static const JourneyStop rome = JourneyStop(
    id: 'rome',
    label: 'رومية',
    position: GeoPosition(latitude: 41.9, longitude: 12.5),
  );

  /// فيلبي.
  static const JourneyStop philippi = JourneyStop(
    id: 'philippi',
    label: 'فيلبي',
    position: GeoPosition(latitude: 41.01, longitude: 24.29),
  );

  /// كولوسي — where both فليمون and أهل كولوسي received their letters.
  static const JourneyStop colossae = JourneyStop(
    id: 'colossae',
    label: 'كولوسي',
    position: GeoPosition(latitude: 37.78, longitude: 29.38),
  );

  /// أفسس — also where تيموثاوس was serving.
  static const JourneyStop ephesus = JourneyStop(
    id: 'ephesus',
    label: 'أفسس',
    position: GeoPosition(latitude: 37.94, longitude: 27.34),
  );

  /// كريت — where تيطس was left to finish the work.
  static const JourneyStop crete = JourneyStop(
    id: 'crete',
    label: 'كريت',
    position: GeoPosition(latitude: 35.24, longitude: 24.81),
  );

  /// أورشليم — the letter to العبرانيين, and the only stop with no
  /// counterpart on the mnemonic cross.
  static const JourneyStop jerusalem = JourneyStop(
    id: 'jerusalem',
    label: 'أورشليم',
    position: GeoPosition(latitude: 31.78, longitude: 35.22),
  );

  const JourneyStops._();
}
