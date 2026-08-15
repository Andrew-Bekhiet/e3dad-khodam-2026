import 'package:e3dad_khodam_2026/src/data/game/route_geometry.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_leg.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_kind.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_trail.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// Every leg the post-office journey travels, and how each was travelled.
///
/// Only two of them are land: تسالونيكي → كورنثوس inside Greece, and
/// كولوسي → أفسس down the Meander valley. Paul made the rest by ship, so
/// asking a road service for them would draw him on a motorway through
/// the Balkans — plausible-looking and false. Their charts are picked by
/// hand instead, tracing the coast and the islands.
///
/// The two return journeys (كريت → أفسس, أورشليم → أفسس) are not listed:
/// the same water read backwards is the same route, and
/// [JourneyLegs.geometryBetween] reverses a known leg rather than
/// duplicating its chart.
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

  /// رومية → فيلبي: the Via Appia south to Brundisium, across to
  /// Dyrrachium, then the Via Egnatia east — the standard road between
  /// Italy and Macedonia.
  static const JourneyLeg romeToPhilippi = JourneyLeg(
    from: JourneyStops.rome,
    to: JourneyStops.philippi,
    kind: LegKind.sea,
    chart: [
      // Via Appia: Terracina.
      GeoPosition(latitude: 41.29, longitude: 13.25),
      // Via Appia: Beneventum.
      GeoPosition(latitude: 41.13, longitude: 14.78),
      // Via Appia: Venusia.
      GeoPosition(latitude: 40.96, longitude: 15.82),
      // Via Appia: Tarentum.
      GeoPosition(latitude: 40.47, longitude: 17.24),
      // Brundisium, where the road meets the sea.
      GeoPosition(latitude: 40.63, longitude: 17.94),
      // The Adriatic crossing.
      GeoPosition(latitude: 40.95, longitude: 18.8),
      // Dyrrachium, where the Via Egnatia begins.
      GeoPosition(latitude: 41.32, longitude: 19.45),
      // Via Egnatia: Lychnidos, by Lake Ohrid.
      GeoPosition(latitude: 41.12, longitude: 20.8),
      // Via Egnatia: Heraclea Lyncestis.
      GeoPosition(latitude: 41.03, longitude: 21.34),
      // Via Egnatia: Edessa.
      GeoPosition(latitude: 40.8, longitude: 22.05),
      // Via Egnatia: تسالونيكي.
      GeoPosition(latitude: 40.64, longitude: 22.94),
      // Via Egnatia: Amphipolis.
      GeoPosition(latitude: 40.82, longitude: 23.84),
    ],
  );

  /// فيلبي → كولوسي: down from Neapolis through the north Aegean islands
  /// to أفسس, then inland up the Meander.
  static const JourneyLeg philippiToColossae = JourneyLeg(
    from: JourneyStops.philippi,
    to: JourneyStops.colossae,
    kind: LegKind.sea,
    chart: [
      // Neapolis, the port of فيلبي.
      GeoPosition(latitude: 40.94, longitude: 24.41),
      // Thasos.
      GeoPosition(latitude: 40.7, longitude: 24.65),
      // Lemnos.
      GeoPosition(latitude: 39.9, longitude: 25.25),
      // Lesbos.
      GeoPosition(latitude: 39.1, longitude: 26.3),
      // Chios.
      GeoPosition(latitude: 38.35, longitude: 26.05),
      // أفسس.
      GeoPosition(latitude: 37.94, longitude: 27.15),
      // Inland along the Meander.
      GeoPosition(latitude: 37.85, longitude: 28.3),
    ],
  );

  /// كولوسي → أفسس, overland down the Meander valley.
  static const JourneyLeg colossaeToEphesus = JourneyLeg(
    from: JourneyStops.colossae,
    to: JourneyStops.ephesus,
    kind: LegKind.land,
  );

  /// أفسس → كريت: south past Samos and the Dodecanese, then west along
  /// the Cretan Sea. Also travelled in reverse.
  static const JourneyLeg ephesusToCrete = JourneyLeg(
    from: JourneyStops.ephesus,
    to: JourneyStops.crete,
    kind: LegKind.sea,
    chart: [
      // Samos.
      GeoPosition(latitude: 37.7, longitude: 26.9),
      // Kos.
      GeoPosition(latitude: 36.85, longitude: 27.2),
      // Karpathos, between Rhodes and Crete.
      GeoPosition(latitude: 35.7, longitude: 27.15),
      // The eastern cape of Crete, off Sitia.
      GeoPosition(latitude: 35.25, longitude: 26.1),
    ],
  );

  /// أفسس → أورشليم: down the Ionian coast, along Lycia, past Cyprus to
  /// the Syrian shore, then inland from Caesarea. The route of Acts 21.
  /// Also travelled in reverse.
  static const JourneyLeg ephesusToJerusalem = JourneyLeg(
    from: JourneyStops.ephesus,
    to: JourneyStops.jerusalem,
    kind: LegKind.sea,
    chart: [
      // Miletus, where Paul met the Ephesian elders.
      GeoPosition(latitude: 37.53, longitude: 27.28),
      // Kos.
      GeoPosition(latitude: 36.85, longitude: 27.25),
      // Rhodes.
      GeoPosition(latitude: 36.2, longitude: 28.05),
      // Patara, on the Lycian coast.
      GeoPosition(latitude: 36.27, longitude: 29.32),
      // South of Cyprus.
      GeoPosition(latitude: 34.6, longitude: 33.0),
      // Tyre.
      GeoPosition(latitude: 33.27, longitude: 35.2),
      // Ptolemais.
      GeoPosition(latitude: 32.92, longitude: 35.07),
      // Caesarea, where the ship was left for the road inland.
      GeoPosition(latitude: 32.5, longitude: 34.89),
    ],
  );

  /// Every charted leg, in the order the journey first travels them.
  static const List<JourneyLeg> all = [
    thessalonicaToCorinth,
    corinthToGalatia,
    galatiaToRome,
    romeToPhilippi,
    philippiToColossae,
    colossaeToEphesus,
    ephesusToCrete,
    ephesusToJerusalem,
  ];

  /// Legs the journey crosses without tracing anything.
  ///
  /// Only the opening hop. The couriers set out from home in
  /// الإسماعيلية, and the story starts at تسالونيكي — the distance
  /// between the two is how they got to work, not part of the journey
  /// the map is a record of.
  static const Set<String> undrawnLegIds = {'ismailia>thessalonica'};

  /// Whether the leg between [fromId] and [toId] leaves a line behind it.
  ///
  /// Direction-insensitive, like [geometryBetween]: the same stretch read
  /// backwards is the same stretch.
  static LegTrail trailOf(String fromId, String toId) =>
      undrawnLegIds.contains('$fromId>$toId') ||
          undrawnLegIds.contains('$toId>$fromId')
      ? LegTrail.undrawn
      : LegTrail.drawn;

  /// The line to draw between the stops [fromId] and [toId], or null
  /// when no leg joins them.
  ///
  /// A leg travelled the other way returns the same geometry reversed:
  /// أفسس → كريت and كريت → أفسس are one stretch of water, and charting
  /// it twice would only invite the two copies to drift apart.
  static List<GeoPosition>? geometryBetween(String fromId, String toId) {
    final forward = RouteGeometry.byLegId['$fromId>$toId'];
    if (forward != null) {
      return forward;
    }

    return RouteGeometry.byLegId['$toId>$fromId']?.reversed.toList();
  }

  const JourneyLegs._();
}
