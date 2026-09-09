import 'package:e3dad_khodam_2026/src/data/history/historical_stops.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_leg.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_kind.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// The legs of the voyage to رومية, all one continuous crossing from
/// قيصرية and, per Acts 27, told by the reference the contract points at.
final class HistoricalLegsRomeJourney {
  /// قيصرية → صيدا, up the Phoenician coast.
  static const JourneyLeg caesareaToSidon = JourneyLeg(
    from: HistoricalStops.caesarea,
    to: HistoricalStops.sidon,
    kind: LegKind.sea,
    chart: [
      // Tyre, on the Phoenician coast.
      GeoPosition(latitude: 33.27, longitude: 35.2),
    ],
  );

  /// صيدا → ميرا: under the lee of Cyprus, then along Cilicia and
  /// Pamphylia (Acts 27:4-5).
  static const JourneyLeg sidonToMyra = JourneyLeg(
    from: HistoricalStops.sidon,
    to: HistoricalStops.myra,
    kind: LegKind.sea,
    chart: [
      // The lee shore of Cyprus.
      GeoPosition(latitude: 35.0, longitude: 34.3),
      // The sea off Cilicia.
      GeoPosition(latitude: 36.3, longitude: 33.5),
      // The sea off Pamphylia, off Attaleia.
      GeoPosition(latitude: 36.4, longitude: 30.7),
    ],
  );

  /// ميرا → كنيدس, along the Lycian coast (Acts 27:7).
  static const JourneyLeg myraToCnidus = JourneyLeg(
    from: HistoricalStops.myra,
    to: HistoricalStops.cnidus,
    kind: LegKind.sea,
    chart: [
      // Patara, on the Lycian coast.
      GeoPosition(latitude: 36.27, longitude: 29.32),
    ],
  );

  /// كنيدس → الموانئ الحسنة: under the lee of كريت, past Cape Salmone
  /// (Acts 27:7-8).
  static const JourneyLeg cnidusToFairHavens = JourneyLeg(
    from: HistoricalStops.cnidus,
    to: HistoricalStops.fairHavens,
    kind: LegKind.sea,
    chart: [
      // Cape Salmone, Crete's eastern tip.
      GeoPosition(latitude: 35.3, longitude: 26.3),
      // Along Crete's south coast, in the lee of the island.
      GeoPosition(latitude: 35.0, longitude: 25.3),
    ],
  );

  /// الموانئ الحسنة → مليطة: the Euroclydon, driven past Clauda and
  /// adrift for fourteen days (Acts 27:14-17, 27).
  static const JourneyLeg fairHavensToMalta = JourneyLeg(
    from: HistoricalStops.fairHavens,
    to: HistoricalStops.malta,
    kind: LegKind.sea,
    chart: [
      // Clauda, the last shelter before the storm.
      GeoPosition(latitude: 34.83, longitude: 24.08),
      // Adrift on the open sea, the fourteen days of Acts 27.
      GeoPosition(latitude: 35.2, longitude: 19.0),
      // The approach to Malta from the east.
      GeoPosition(latitude: 36.0, longitude: 15.3),
    ],
  );

  /// مليطة → سيراكوسا, a short crossing north over open water.
  static const JourneyLeg maltaToSyracuse = JourneyLeg(
    from: HistoricalStops.malta,
    to: HistoricalStops.syracuse,
    kind: LegKind.sea,
  );

  /// سيراكوسا → ريغيون, along Sicily's east coast to the Strait of
  /// Messina.
  static const JourneyLeg syracuseToRhegium = JourneyLeg(
    from: HistoricalStops.syracuse,
    to: HistoricalStops.rhegium,
    kind: LegKind.sea,
    chart: [
      // Off Catania, following Sicily's east coast.
      GeoPosition(latitude: 37.6, longitude: 15.3),
    ],
  );

  /// ريغيون → بوطيولي, north up the Tyrrhenian Sea.
  static const JourneyLeg rhegiumToPuteoli = JourneyLeg(
    from: HistoricalStops.rhegium,
    to: HistoricalStops.puteoli,
    kind: LegKind.sea,
    chart: [
      // Into the Tyrrhenian Sea, off Cape Vaticano.
      GeoPosition(latitude: 39.0, longitude: 15.6),
      // North up the Tyrrhenian Sea.
      GeoPosition(latitude: 39.5, longitude: 15.0),
    ],
  );

  /// بوطيولي → رومية, overland up the Via Appia — the road Paul actually
  /// walked into Rome.
  static const JourneyLeg puteoliToRome = JourneyLeg(
    from: HistoricalStops.puteoli,
    to: JourneyStops.rome,
    kind: LegKind.land,
  );

  /// Every leg the voyage to رومية travels, in order.
  static const List<JourneyLeg> all = [
    caesareaToSidon,
    sidonToMyra,
    myraToCnidus,
    cnidusToFairHavens,
    fairHavensToMalta,
    maltaToSyracuse,
    syracuseToRhegium,
    rhegiumToPuteoli,
    puteoliToRome,
  ];

  const HistoricalLegsRomeJourney._();
}
