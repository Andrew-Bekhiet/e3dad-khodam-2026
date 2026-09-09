import 'package:e3dad_khodam_2026/src/data/stop_positions.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';

/// Every place the three historical journeys stop at or pass through,
/// named and positioned from the gazetteer in [StopPositions].
///
/// Places the post-office journey already stops at — تسالونيكي، كورنثوس،
/// أفسس، رومية — are not redeclared here: they stay `JourneyStops`'
/// constants, referenced directly where a journey needs them, so a city
/// cannot end up with two ids.
final class HistoricalStops {
  /// أنطاكية — where the 2nd and 3rd journeys both set out.
  static const JourneyStop antioch = JourneyStop(
    id: 'antioch',
    label: 'أنطاكية',
    position: StopPositions.antioch,
  );

  /// طرسوس.
  static const JourneyStop tarsus = JourneyStop(
    id: 'tarsus',
    label: 'طرسوس',
    position: StopPositions.tarsus,
  );

  /// دربة.
  static const JourneyStop derbe = JourneyStop(
    id: 'derbe',
    label: 'دربة',
    position: StopPositions.derbe,
  );

  /// لسترة.
  static const JourneyStop lystra = JourneyStop(
    id: 'lystra',
    label: 'لسترة',
    position: StopPositions.lystra,
  );

  /// إيقونية.
  static const JourneyStop iconium = JourneyStop(
    id: 'iconium',
    label: 'إيقونية',
    position: StopPositions.iconium,
  );

  /// أنطاكية بيسيدية — distinct from [antioch] on the Orontes.
  static const JourneyStop pisidianAntioch = JourneyStop(
    id: 'pisidianAntioch',
    label: 'أنطاكية بيسيدية',
    position: StopPositions.pisidianAntioch,
  );

  /// ترواس.
  static const JourneyStop troas = JourneyStop(
    id: 'troas',
    label: 'ترواس',
    position: StopPositions.troas,
  );

  /// ساموثراكي.
  static const JourneyStop samothrace = JourneyStop(
    id: 'samothrace',
    label: 'ساموثراكي',
    position: StopPositions.samothrace,
  );

  /// نيابوليس.
  static const JourneyStop neapolis = JourneyStop(
    id: 'neapolis',
    label: 'نيابوليس',
    position: StopPositions.neapolis,
  );

  /// فيلبي.
  static const JourneyStop philippi = JourneyStop(
    id: 'philippi',
    label: 'فيلبي',
    position: StopPositions.philippi,
  );

  /// أمفيبوليس.
  static const JourneyStop amphipolis = JourneyStop(
    id: 'amphipolis',
    label: 'أمفيبوليس',
    position: StopPositions.amphipolis,
  );

  /// أبولونيا.
  static const JourneyStop apollonia = JourneyStop(
    id: 'apollonia',
    label: 'أبولونيا',
    position: StopPositions.apollonia,
  );

  /// بيرية.
  static const JourneyStop berea = JourneyStop(
    id: 'berea',
    label: 'بيرية',
    position: StopPositions.berea,
  );

  /// أثينا.
  static const JourneyStop athens = JourneyStop(
    id: 'athens',
    label: 'أثينا',
    position: StopPositions.athens,
  );

  /// قيصرية — where the voyage to رومية sets out.
  static const JourneyStop caesarea = JourneyStop(
    id: 'caesarea',
    label: 'قيصرية',
    position: StopPositions.caesarea,
  );

  /// صيدا.
  static const JourneyStop sidon = JourneyStop(
    id: 'sidon',
    label: 'صيدا',
    position: StopPositions.sidon,
  );

  /// ميرا.
  static const JourneyStop myra = JourneyStop(
    id: 'myra',
    label: 'ميرا',
    position: StopPositions.myra,
  );

  /// كنيدس.
  static const JourneyStop cnidus = JourneyStop(
    id: 'cnidus',
    label: 'كنيدس',
    position: StopPositions.cnidus,
  );

  /// الموانئ الحسنة — Fair Havens, on كريت's south coast; a different
  /// stop from `JourneyStops.crete`.
  static const JourneyStop fairHavens = JourneyStop(
    id: 'fairHavens',
    label: 'الموانئ الحسنة',
    position: StopPositions.fairHavens,
  );

  /// مليطة.
  static const JourneyStop malta = JourneyStop(
    id: 'malta',
    label: 'مليطة',
    position: StopPositions.malta,
  );

  /// سيراكوسا.
  static const JourneyStop syracuse = JourneyStop(
    id: 'syracuse',
    label: 'سيراكوسا',
    position: StopPositions.syracuse,
  );

  /// ريغيون.
  static const JourneyStop rhegium = JourneyStop(
    id: 'rhegium',
    label: 'ريغيون',
    position: StopPositions.rhegium,
  );

  /// بوطيولي.
  static const JourneyStop puteoli = JourneyStop(
    id: 'puteoli',
    label: 'بوطيولي',
    position: StopPositions.puteoli,
  );

  const HistoricalStops._();
}
