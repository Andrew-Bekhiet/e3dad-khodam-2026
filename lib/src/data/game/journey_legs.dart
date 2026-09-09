import 'package:e3dad_khodam_2026/src/data/game/route_geometry.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_leg.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_kind.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_trail.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/routing/charted_legs.dart';

/// Every leg the post-office journey travels, and how each was travelled.
///
/// Only one of them is land: تسالونيكي → كورنثوس inside Greece. The rest
/// are chiefly by ship, so asking a road service for them would draw the
/// couriers on a motorway through the Balkans — plausible-looking and
/// false. Their charts are picked by hand instead, tracing the coast and
/// the islands.
///
/// The return journey أورشليم → أفسس is not listed: the same water read
/// backwards is the same route, and [JourneyLegs.geometryBetween] reverses
/// a known leg rather than duplicating its chart.
final class JourneyLegs {
  /// تسالونيكي → كورنثوس, overland through Greece.
  static const JourneyLeg thessalonicaToCorinth = JourneyLeg(
    from: JourneyStops.thessalonica,
    to: JourneyStops.corinth,
    kind: LegKind.land,
  );

  /// كورنثوس → غلاطية: out of the Saronic Gulf, east through the
  /// Cyclades to the Ionian coast, then inland to أنقرة.
  static const JourneyLeg corinthToGalatia = JourneyLeg(
    from: JourneyStops.corinth,
    to: JourneyStops.galatia,
    kind: LegKind.sea,
    chart: [
      // Cape Sounion, leaving the Saronic Gulf.
      GeoPosition(latitude: 37.65, longitude: 24.03),
      // Syros, in the Cyclades.
      GeoPosition(latitude: 37.44, longitude: 24.95),
      // Ikaria.
      GeoPosition(latitude: 37.6, longitude: 26.2),
      // Landfall on the Ionian coast at أفسس.
      GeoPosition(latitude: 37.94, longitude: 27.15),
      // Overland: the Meander headwaters near Uşak.
      GeoPosition(latitude: 38.68, longitude: 29.4),
      // The Anatolian plateau at Afyon.
      GeoPosition(latitude: 38.76, longitude: 30.54),
      // Polatlı, on the approach to أنقرة.
      GeoPosition(latitude: 39.58, longitude: 32.15),
    ],
  );

  /// غلاطية → رومية: back down to the coast, west through the Aegean and
  /// the Gulf of Corinth, round the toe of Italy to Puteoli, then up the
  /// Via Appia — the road Paul actually walked into Rome.
  static const JourneyLeg galatiaToRome = JourneyLeg(
    from: JourneyStops.galatia,
    to: JourneyStops.rome,
    kind: LegKind.sea,
    chart: [
      // Overland back across the plateau.
      GeoPosition(latitude: 38.76, longitude: 30.54),
      // The Ionian coast again.
      GeoPosition(latitude: 37.94, longitude: 27.15),
      // Chios.
      GeoPosition(latitude: 38.3, longitude: 25.9),
      // North of the Cyclades, off Andros.
      GeoPosition(latitude: 37.9, longitude: 24.6),
      // Cape Sounion.
      GeoPosition(latitude: 37.6, longitude: 23.9),
      // The Isthmus at كورنثوس.
      GeoPosition(latitude: 37.94, longitude: 22.95),
      // Out along the Gulf of Corinth.
      GeoPosition(latitude: 38.25, longitude: 21.7),
      // The Ionian Sea off Zakynthos.
      GeoPosition(latitude: 37.8, longitude: 20.7),
      // The Strait of Otranto.
      GeoPosition(latitude: 39.6, longitude: 18.6),
      // The Strait of Messina.
      GeoPosition(latitude: 38.2, longitude: 15.6),
      // North up the Tyrrhenian Sea.
      GeoPosition(latitude: 39.5, longitude: 15.0),
      // Puteoli, where Paul landed in Italy.
      GeoPosition(latitude: 40.82, longitude: 14.12),
      // The Via Appia at Terracina.
      GeoPosition(latitude: 41.29, longitude: 13.25),
    ],
  );

  /// رومية → كريت: out of the Tiber, south down the Tyrrhenian, through
  /// the Strait of Messina, then east across the Ionian to Crete's north
  /// coast.
  static const JourneyLeg romeToCrete = JourneyLeg(
    from: JourneyStops.rome,
    to: JourneyStops.crete,
    kind: LegKind.sea,
    chart: [
      // Ostia, the Tiber mouth.
      GeoPosition(latitude: 41.75, longitude: 12.28),
      // Off Anzio.
      GeoPosition(latitude: 41.35, longitude: 12.55),
      // Off Ischia, clear of the bay.
      GeoPosition(latitude: 40.7, longitude: 13.75),
      // The Gulf of Salerno approach.
      GeoPosition(latitude: 40.45, longitude: 14.6),
      // The Strait of Messina.
      GeoPosition(latitude: 38.2, longitude: 15.6),
      // Off Cape Spartivento.
      GeoPosition(latitude: 37.9, longitude: 16.1),
      // The open Ionian.
      GeoPosition(latitude: 36.6, longitude: 19.5),
      // South-west of Cape Malea.
      GeoPosition(latitude: 35.9, longitude: 22.0),
      // Off Phalasarna, Crete's north-west.
      GeoPosition(latitude: 35.55, longitude: 23.6),
      // Off Chania.
      GeoPosition(latitude: 35.52, longitude: 24.1),
    ],
  );

  /// كريت → أفسس, through the southern Aegean from Crete's north coast.
  static const JourneyLeg creteToEphesus = JourneyLeg(
    from: JourneyStops.crete,
    to: JourneyStops.ephesus,
    kind: LegKind.sea,
    chart: [
      // Off Heraklion, before turning north.
      GeoPosition(latitude: 35.35, longitude: 25.15),
      // The approach to Crete's north coast.
      GeoPosition(latitude: 35.75, longitude: 25.5),
      // South of the Cyclades, off Astypalaia.
      GeoPosition(latitude: 36.3, longitude: 25.9),
      // Off Kos, in the Dodecanese.
      GeoPosition(latitude: 36.9, longitude: 26.3),
      // Off Patmos.
      GeoPosition(latitude: 37.3, longitude: 26.55),
      // The strait between Samos and Mycale.
      GeoPosition(latitude: 37.7, longitude: 26.75),
      // The Cayster mouth, where the ship is met.
      GeoPosition(latitude: 37.85, longitude: 27.05),
    ],
  );

  /// أفسس → أورشليم, by the ports in Acts 21.
  static const JourneyLeg ephesusToJerusalem = JourneyLeg(
    from: JourneyStops.ephesus,
    to: JourneyStops.jerusalem,
    kind: LegKind.sea,
    chart: [
      // The Cayster mouth.
      GeoPosition(latitude: 37.85, longitude: 27.05),
      // Off Miletus.
      GeoPosition(latitude: 37.55, longitude: 27.0),
      // Cos.
      GeoPosition(latitude: 36.9, longitude: 27.3),
      // Rhodes.
      GeoPosition(latitude: 36.3, longitude: 28.1),
      // Patara, on the Lycian coast.
      GeoPosition(latitude: 36.27, longitude: 29.32),
      // South-west of Cyprus.
      GeoPosition(latitude: 35.1, longitude: 32.3),
      // South of Cyprus.
      GeoPosition(latitude: 34.6, longitude: 33.5),
      // Tyre.
      GeoPosition(latitude: 33.27, longitude: 35.2),
      // Caesarea, where the ship is left for the road inland.
      GeoPosition(latitude: 32.5, longitude: 34.89),
    ],
  );

  /// أفسس → رومية: out through the Aegean, round the Peloponnese and
  /// across the Ionian, then up the Via Appia from Brundisium.
  static const JourneyLeg ephesusToRome = JourneyLeg(
    from: JourneyStops.ephesus,
    to: JourneyStops.rome,
    kind: LegKind.sea,
    chart: [
      // Samos.
      GeoPosition(latitude: 37.7, longitude: 26.9),
      // Naxos, in the Cyclades.
      GeoPosition(latitude: 37.1, longitude: 25.38),
      // Cape Malea, rounding the Peloponnese.
      GeoPosition(latitude: 36.45, longitude: 23.2),
      // Corfu, at the mouth of the Adriatic.
      GeoPosition(latitude: 39.62, longitude: 19.92),
      // Brundisium, where the Via Appia begins.
      GeoPosition(latitude: 40.63, longitude: 17.94),
      // Via Appia: Tarentum.
      GeoPosition(latitude: 40.47, longitude: 17.24),
      // Via Appia: Beneventum.
      GeoPosition(latitude: 41.13, longitude: 14.78),
      // Via Appia: Terracina.
      GeoPosition(latitude: 41.29, longitude: 13.25),
    ],
  );

  /// Every charted leg, in the order the journey first travels them.
  static const List<JourneyLeg> all = [
    thessalonicaToCorinth,
    corinthToGalatia,
    galatiaToRome,
    romeToCrete,
    creteToEphesus,
    ephesusToJerusalem,
    ephesusToRome,
  ];

  /// Legs the journey crosses without tracing anything.
  ///
  /// Only the opening hop. The couriers set out from home in
  /// الإسماعيلية, and the story starts at تسالونيكي — the distance
  /// between the two is how they got to work, not part of the journey
  /// the map is a record of.
  static const Set<String> undrawnLegIds = {'ismailia>thessalonica'};

  /// The atlas the journey's trails are joined out of.
  static const ChartedLegs charted = ChartedLegs(
    byLegId: RouteGeometry.byLegId,
    undrawnLegIds: undrawnLegIds,
  );

  /// Whether the leg between [fromId] and [toId] leaves a line behind it.
  static LegTrail trailOf(String fromId, String toId) =>
      charted.trailOf(fromId, toId);

  /// The line to draw between the stops [fromId] and [toId], or null
  /// when no leg joins them.
  static List<GeoPosition>? geometryBetween(String fromId, String toId) =>
      charted.geometryBetween(fromId, toId);

  const JourneyLegs._();
}
