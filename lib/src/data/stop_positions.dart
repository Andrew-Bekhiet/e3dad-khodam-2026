import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// The app's single gazetteer: where every real place it names actually
/// sits.
///
/// Canonical for both experiences. `JourneyStops` builds the journey's
/// stops on these, and the mnemonic cross's branch files read the ones it
/// also lists off the very same constants, so a city cannot sit in two
/// places at once.
///
/// Separate from [JourneyStops] because a `const` expression may not read
/// a field off a const object: the cross needs the bare [GeoPosition], not
/// a whole [JourneyStop], and this is the only way to hand it one without
/// restating the numbers. Cross-only positions — the four arm anchors, the
/// continents, the seas, the countries — are deliberately absent: they are
/// mnemonic placements, not the real location of anything, so they stay in
/// their branch files. See `docs/adr/0001`.
final class StopPositions {
  /// الإسماعيلية — the couriers' own post office, and the only place
  /// here that Paul never went. From 30°35'53.3"N 32°16'12.2"E.
  static const GeoPosition ismailia = GeoPosition(
    latitude: 30.598139,
    longitude: 32.270056,
  );

  /// تسالونيكي.
  static const GeoPosition thessalonica = GeoPosition(
    latitude: 40.6401,
    longitude: 22.9444,
  );

  /// كورنثوس.
  static const GeoPosition corinth = GeoPosition(
    latitude: 37.9061,
    longitude: 22.8783,
  );

  /// غلاطية — a Roman province rather than a city, pinned at its capital
  /// Ancyra, the one point in it that can be named.
  static const GeoPosition galatia = GeoPosition(
    latitude: 39.9334,
    longitude: 32.8597,
  );

  /// رومية.
  static const GeoPosition rome = GeoPosition(
    latitude: 41.8925,
    longitude: 12.4853,
  );

  /// فيلبي.
  static const GeoPosition philippi = GeoPosition(
    latitude: 41.0131,
    longitude: 24.2864,
  );

  /// كولوسي.
  static const GeoPosition colossae = GeoPosition(
    latitude: 37.7543,
    longitude: 29.2598,
  );

  /// أفسس.
  static const GeoPosition ephesus = GeoPosition(
    latitude: 37.9395,
    longitude: 27.3417,
  );

  /// كريت.
  static const GeoPosition crete = GeoPosition(
    latitude: 35.2401,
    longitude: 24.8093,
  );

  /// أورشليم — the one stop the mnemonic cross never lists.
  static const GeoPosition jerusalem = GeoPosition(
    latitude: 31.7683,
    longitude: 35.2137,
  );

  const StopPositions._();
}
