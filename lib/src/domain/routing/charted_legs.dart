import 'package:e3dad_khodam_2026/src/domain/game/leg_trail.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/routing/leg_atlas.dart';

/// A [LegAtlas] over a table of baked leg geometry.
///
/// Both journeys' legs are looked up the same way, so the lookup lives
/// once here and each journey supplies only its own table.
final class ChartedLegs implements LegAtlas {
  /// Every charted leg, by `from>to` id.
  final Map<String, List<GeoPosition>> byLegId;

  /// Legs crossed without tracing anything.
  final Set<String> undrawnLegIds;

  /// Creates an atlas over [byLegId].
  const ChartedLegs({required this.byLegId, this.undrawnLegIds = const {}});

  @override
  LegTrail trailOf(String fromId, String toId) =>
      undrawnLegIds.contains('$fromId>$toId') ||
          undrawnLegIds.contains('$toId>$fromId')
      ? LegTrail.undrawn
      : LegTrail.drawn;

  /// The line to draw between the stops [fromId] and [toId], or null when
  /// no leg joins them.
  ///
  /// A leg travelled the other way returns the same geometry reversed:
  /// أفسس → أورشليم and أورشليم → أفسس are one stretch of water, and
  /// charting it twice would only invite the two copies to drift apart.
  @override
  List<GeoPosition>? geometryBetween(String fromId, String toId) {
    final forward = byLegId['$fromId>$toId'];
    if (forward != null) {
      return forward;
    }

    return byLegId['$toId>$fromId']?.reversed.toList();
  }
}
