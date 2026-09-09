import 'package:e3dad_khodam_2026/src/data/history/historical_legs_rome_journey.dart';
import 'package:e3dad_khodam_2026/src/data/history/historical_legs_second_journey.dart';
import 'package:e3dad_khodam_2026/src/data/history/historical_legs_third_journey.dart';
import 'package:e3dad_khodam_2026/src/data/history/historical_route_geometry.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_leg.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_trail.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/routing/charted_legs.dart';

/// Every leg the three historical journeys travel, gathered from
/// `HistoricalLegsSecondJourney`, `HistoricalLegsThirdJourney` and
/// `HistoricalLegsRomeJourney` — split by journey, the way `HistoricalLegs`
/// itself would otherwise run well past 350 lines.
final class HistoricalLegs {
  /// Every charted leg, across all three journeys.
  static const List<JourneyLeg> all = [
    ...HistoricalLegsSecondJourney.all,
    ...HistoricalLegsThirdJourney.all,
    ...HistoricalLegsRomeJourney.all,
  ];

  /// The atlas the journeys' trails are joined out of.
  ///
  /// No undrawn legs: unlike the post-office journey, every leg of every
  /// historical journey draws.
  static const ChartedLegs charted = ChartedLegs(
    byLegId: HistoricalRouteGeometry.byLegId,
  );

  /// Whether the leg between [fromId] and [toId] leaves a line behind it.
  static LegTrail trailOf(String fromId, String toId) =>
      charted.trailOf(fromId, toId);

  /// The line to draw between the stops [fromId] and [toId], or null
  /// when no leg joins them.
  static List<GeoPosition>? geometryBetween(String fromId, String toId) =>
      charted.geometryBetween(fromId, toId);

  const HistoricalLegs._();
}
