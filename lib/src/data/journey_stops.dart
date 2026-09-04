import 'package:e3dad_khodam_2026/src/data/stop_positions.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';

/// Every place the post-office journey stops at, named and positioned
/// from the gazetteer in [StopPositions].
final class JourneyStops {
  /// الإسماعيلية — where the couriers work, and where the map opens.
  /// Never a destination: no letter was ever addressed here.
  static const JourneyStop ismailia = JourneyStop(
    id: 'ismailia',
    label: 'الإسماعيلية',
    position: StopPositions.ismailia,
  );

  /// تسالونيكي — the first two letters.
  static const JourneyStop thessalonica = JourneyStop(
    id: 'thessalonica',
    label: 'تسالونيكي',
    position: StopPositions.thessalonica,
  );

  /// كورنثوس — the two Corinthian letters.
  static const JourneyStop corinth = JourneyStop(
    id: 'corinth',
    label: 'كورنثوس',
    position: StopPositions.corinth,
  );

  /// غلاطية — a Roman province rather than a city; pinned at its capital
  /// Ancyra, the one point in it that can be named.
  static const JourneyStop galatia = JourneyStop(
    id: 'galatia',
    label: 'غلاطية',
    position: StopPositions.galatia,
  );

  /// رومية — where five letters land: the letter to أهل رومية itself,
  /// and, since فيلبي، فليمون، كولوسي and أفسس were all written from
  /// بولس's first Roman imprisonment, every letter whose recipient never
  /// received it in person.
  static const JourneyStop rome = JourneyStop(
    id: 'rome',
    label: 'رومية',
    position: StopPositions.rome,
  );

  /// أفسس — the letter to أهل أفسس.
  static const JourneyStop ephesus = JourneyStop(
    id: 'ephesus',
    label: 'أفسس',
    position: StopPositions.ephesus,
  );

  /// كريت.
  static const JourneyStop crete = JourneyStop(
    id: 'crete',
    label: 'كريت',
    position: StopPositions.crete,
  );

  /// أورشليم — the letter to العبرانيين, and the only stop the mnemonic
  /// cross never lists.
  static const JourneyStop jerusalem = JourneyStop(
    id: 'jerusalem',
    label: 'أورشليم',
    position: StopPositions.jerusalem,
  );

  const JourneyStops._();
}
