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

  /// أنطاكية — Antioch on the Orontes, whence the historical journeys set
  /// out. Not to be confused with [pisidianAntioch].
  static const GeoPosition antioch = GeoPosition(
    latitude: 36.2021,
    longitude: 36.1603,
  );

  /// طرسوس.
  static const GeoPosition tarsus = GeoPosition(
    latitude: 36.9177,
    longitude: 34.8925,
  );

  /// دربة.
  static const GeoPosition derbe = GeoPosition(
    latitude: 37.3506,
    longitude: 33.2833,
  );

  /// لسترة.
  static const GeoPosition lystra = GeoPosition(
    latitude: 37.5786,
    longitude: 32.4531,
  );

  /// إيقونية.
  static const GeoPosition iconium = GeoPosition(
    latitude: 37.8746,
    longitude: 32.4932,
  );

  /// أنطاكية بيسيدية — Pisidian Antioch, distinct from [antioch] on the
  /// Orontes.
  static const GeoPosition pisidianAntioch = GeoPosition(
    latitude: 38.305,
    longitude: 31.1897,
  );

  /// ترواس.
  static const GeoPosition troas = GeoPosition(
    latitude: 39.7503,
    longitude: 26.1594,
  );

  /// ساموثراكي.
  static const GeoPosition samothrace = GeoPosition(
    latitude: 40.4667,
    longitude: 25.5333,
  );

  /// نيابوليس.
  static const GeoPosition neapolis = GeoPosition(
    latitude: 40.9375,
    longitude: 24.4128,
  );

  /// أمفيبوليس.
  static const GeoPosition amphipolis = GeoPosition(
    latitude: 40.8225,
    longitude: 23.8447,
  );

  /// أبولونيا.
  static const GeoPosition apollonia = GeoPosition(
    latitude: 40.6167,
    longitude: 23.45,
  );

  /// بيرية.
  static const GeoPosition berea = GeoPosition(
    latitude: 40.5236,
    longitude: 22.2028,
  );

  /// أثينا.
  static const GeoPosition athens = GeoPosition(
    latitude: 37.9838,
    longitude: 23.7275,
  );

  /// قيصرية.
  static const GeoPosition caesarea = GeoPosition(
    latitude: 32.5019,
    longitude: 34.8917,
  );

  /// صيدا.
  static const GeoPosition sidon = GeoPosition(
    latitude: 33.5571,
    longitude: 35.3729,
  );

  /// ميرا.
  static const GeoPosition myra = GeoPosition(
    latitude: 36.2586,
    longitude: 29.985,
  );

  /// كنيدس.
  static const GeoPosition cnidus = GeoPosition(
    latitude: 36.6853,
    longitude: 27.3742,
  );

  /// الموانئ الحسنة — Fair Havens, on كريت's south coast; a different
  /// point from [crete] itself.
  static const GeoPosition fairHavens = GeoPosition(
    latitude: 34.9333,
    longitude: 24.8,
  );

  /// مليطة.
  static const GeoPosition malta = GeoPosition(
    latitude: 35.95,
    longitude: 14.4,
  );

  /// سيراكوسا.
  static const GeoPosition syracuse = GeoPosition(
    latitude: 37.0755,
    longitude: 15.2866,
  );

  /// ريغيون.
  static const GeoPosition rhegium = GeoPosition(
    latitude: 38.1113,
    longitude: 15.6473,
  );

  /// بوطيولي.
  static const GeoPosition puteoli = GeoPosition(
    latitude: 40.8236,
    longitude: 14.121,
  );

  const StopPositions._();
}
