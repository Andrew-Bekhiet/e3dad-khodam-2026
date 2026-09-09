import 'package:e3dad_khodam_2026/src/data/history/historical_stops.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_leg.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_kind.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// The legs of Paul's 2nd journey, from أنطاكية to كورنثوس.
///
/// The opening chain أنطاكية→...→أنطاكية بيسيدية and the closing hop
/// نيابوليس→فيلبي are also travelled by the 3rd journey; they are
/// declared once here and reused rather than charted twice.
final class HistoricalLegsSecondJourney {
  /// أنطاكية → طرسوس, overland along the coastal route into Cilicia.
  static const JourneyLeg antiochToTarsus = JourneyLeg(
    from: HistoricalStops.antioch,
    to: HistoricalStops.tarsus,
    kind: LegKind.land,
  );

  /// طرسوس → دربة, overland through the Cilician Gates.
  static const JourneyLeg tarsusToDerbe = JourneyLeg(
    from: HistoricalStops.tarsus,
    to: HistoricalStops.derbe,
    kind: LegKind.land,
  );

  /// دربة → لسترة, overland across the Lycaonian plain.
  static const JourneyLeg derbeToLystra = JourneyLeg(
    from: HistoricalStops.derbe,
    to: HistoricalStops.lystra,
    kind: LegKind.land,
  );

  /// لسترة → إيقونية, overland.
  static const JourneyLeg lystraToIconium = JourneyLeg(
    from: HistoricalStops.lystra,
    to: HistoricalStops.iconium,
    kind: LegKind.land,
  );

  /// إيقونية → أنطاكية بيسيدية, overland.
  static const JourneyLeg iconiumToPisidianAntioch = JourneyLeg(
    from: HistoricalStops.iconium,
    to: HistoricalStops.pisidianAntioch,
    kind: LegKind.land,
  );

  /// أنطاكية بيسيدية → ترواس, overland to the Aegean coast.
  static const JourneyLeg pisidianAntiochToTroas = JourneyLeg(
    from: HistoricalStops.pisidianAntioch,
    to: HistoricalStops.troas,
    kind: LegKind.land,
  );

  /// ترواس → ساموثراكي, north-west between the Trojan coast and Imbros.
  static const JourneyLeg troasToSamothrace = JourneyLeg(
    from: HistoricalStops.troas,
    to: HistoricalStops.samothrace,
    kind: LegKind.sea,
    chart: [
      // North of Imbros, in the channel toward Samothrace.
      GeoPosition(latitude: 40.15, longitude: 25.85),
    ],
  );

  /// ساموثراكي → نيابوليس, past Thasos to the Macedonian coast.
  static const JourneyLeg samothraceToNeapolis = JourneyLeg(
    from: HistoricalStops.samothrace,
    to: HistoricalStops.neapolis,
    kind: LegKind.sea,
    chart: [
      // South of Thasos.
      GeoPosition(latitude: 40.65, longitude: 24.75),
    ],
  );

  /// نيابوليس → فيلبي, overland up from the port.
  static const JourneyLeg neapolisToPhilippi = JourneyLeg(
    from: HistoricalStops.neapolis,
    to: HistoricalStops.philippi,
    kind: LegKind.land,
  );

  /// فيلبي → أمفيبوليس, overland on the Via Egnatia.
  static const JourneyLeg philippiToAmphipolis = JourneyLeg(
    from: HistoricalStops.philippi,
    to: HistoricalStops.amphipolis,
    kind: LegKind.land,
  );

  /// أمفيبوليس → أبولونيا, overland on the Via Egnatia.
  static const JourneyLeg amphipolisToApollonia = JourneyLeg(
    from: HistoricalStops.amphipolis,
    to: HistoricalStops.apollonia,
    kind: LegKind.land,
  );

  /// أبولونيا → تسالونيكي, overland on the Via Egnatia.
  static const JourneyLeg apolloniaToThessalonica = JourneyLeg(
    from: HistoricalStops.apollonia,
    to: JourneyStops.thessalonica,
    kind: LegKind.land,
  );

  /// تسالونيكي → بيرية, overland.
  static const JourneyLeg thessalonicaToBerea = JourneyLeg(
    from: JourneyStops.thessalonica,
    to: HistoricalStops.berea,
    kind: LegKind.land,
  );

  /// بيرية → أثينا: overland to the coast at Methone, then south by ship
  /// past Euboea into the Saronic Gulf.
  static const JourneyLeg bereaToAthens = JourneyLeg(
    from: HistoricalStops.berea,
    to: HistoricalStops.athens,
    kind: LegKind.sea,
    chart: [
      // Methone, the coast nearest Berea, where a ship was found.
      GeoPosition(latitude: 40.38, longitude: 22.5),
      // Clearing Mount Pelion into the open Aegean.
      GeoPosition(latitude: 39.35, longitude: 23.5),
      // East of Euboea.
      GeoPosition(latitude: 38.5, longitude: 24.2),
      // Cape Sounion, entering the Saronic Gulf.
      GeoPosition(latitude: 37.65, longitude: 24.03),
    ],
  );

  /// أثينا → كورنثوس, overland across the Isthmus.
  static const JourneyLeg athensToCorinth = JourneyLeg(
    from: HistoricalStops.athens,
    to: JourneyStops.corinth,
    kind: LegKind.land,
  );

  /// Every leg the 2nd journey travels, in order.
  static const List<JourneyLeg> all = [
    antiochToTarsus,
    tarsusToDerbe,
    derbeToLystra,
    lystraToIconium,
    iconiumToPisidianAntioch,
    pisidianAntiochToTroas,
    troasToSamothrace,
    samothraceToNeapolis,
    neapolisToPhilippi,
    philippiToAmphipolis,
    amphipolisToApollonia,
    apolloniaToThessalonica,
    thessalonicaToBerea,
    bereaToAthens,
    athensToCorinth,
  ];

  const HistoricalLegsSecondJourney._();
}
