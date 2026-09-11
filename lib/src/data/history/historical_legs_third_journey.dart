import 'package:e3dad_khodam_2026/src/data/history/historical_stops.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_leg.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_kind.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// The legs unique to Paul's 3rd journey.
///
/// Its opening chain أنطاكية→...→أنطاكية بيسيدية and its closing hop
/// نيابوليس→فيلبي are the same ground the 2nd journey covers, so those
/// legs live in `HistoricalLegsSecondJourney` and are reused rather than
/// declared twice.
final class HistoricalLegsThirdJourney {
  /// أنطاكية بيسيدية → أفسس, overland down the Meander valley.
  static const JourneyLeg pisidianAntiochToEphesus = JourneyLeg(
    from: HistoricalStops.pisidianAntioch,
    to: JourneyStops.ephesus,
    kind: LegKind.land,
  );

  /// أفسس → ترواس, north along the Aegean coast of Asia Minor.
  static const JourneyLeg ephesusToTroas = JourneyLeg(
    from: JourneyStops.ephesus,
    to: HistoricalStops.troas,
    kind: LegKind.sea,
    chart: [
      // Off Chios.
      GeoPosition(latitude: 38.37, longitude: 26.14),
      // Off Mytilene, on Lesbos.
      GeoPosition(latitude: 39.1, longitude: 26.35),
      // The Adramyttian Gulf, before the Troad.
      GeoPosition(latitude: 39.5, longitude: 26.6),
    ],
  );

  /// ترواس → نيابوليس: the 3rd journey crosses directly, without landing
  /// at ساموثراكي the way the 2nd journey does on the same water.
  static const JourneyLeg troasToNeapolis = JourneyLeg(
    from: HistoricalStops.troas,
    to: HistoricalStops.neapolis,
    kind: LegKind.sea,
    chart: [
      // South of Imbros.
      GeoPosition(latitude: 40.0, longitude: 25.7),
      // South of Samothrace, sailing past without landing.
      GeoPosition(latitude: 40.3, longitude: 25.0),
      // South of Thasos.
      GeoPosition(latitude: 40.65, longitude: 24.75),
    ],
  );

  /// Every leg unique to the 3rd journey, in order.
  /// كورنثوس → ريغيون, west out of the Gulf of Corinth and across the
  /// Ionian Sea to the Strait of Messina. From there the voyage to رومية's
  /// own legs carry it on to بوطيولي and رومية.
  static const JourneyLeg corinthToRhegium = JourneyLeg(
    from: JourneyStops.corinth,
    to: HistoricalStops.rhegium,
    kind: LegKind.sea,
    chart: [
      // Out of the Gulf of Corinth, past Patras.
      GeoPosition(latitude: 38.3, longitude: 21.5),
      // Off Cephalonia, into the open Ionian Sea.
      GeoPosition(latitude: 38.4, longitude: 20.2),
      // Mid-Ionian, closing on the toe of Italy.
      GeoPosition(latitude: 38.2, longitude: 17.5),
    ],
  );

  static const List<JourneyLeg> all = [
    pisidianAntiochToEphesus,
    ephesusToTroas,
    troasToNeapolis,
    corinthToRhegium,
  ];

  const HistoricalLegsThirdJourney._();
}
