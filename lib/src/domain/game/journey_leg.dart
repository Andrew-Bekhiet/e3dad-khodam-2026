import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_kind.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';

/// The stretch of the journey between two consecutive stops.
///
/// A leg is the unit route geometry is generated for. Legs are
/// directional in name only: the journey sails أفسس → كريت and back
/// again along the same water, so the reverse of a known leg is that
/// leg's geometry read backwards rather than a second chart.
final class JourneyLeg extends Equatable {
  /// Where the leg starts.
  final JourneyStop from;

  /// Where the leg ends.
  final JourneyStop to;

  /// How it was travelled, which decides where its geometry comes from.
  final LegKind kind;

  /// The waypoints a sea leg is charted through, in order, excluding the
  /// two stops themselves — the generator adds those.
  ///
  /// Empty for a land leg, whose shape is fetched from the road service
  /// instead. Chosen to keep the line on water, round the headlands and
  /// pass between the islands, which is how first-century ships sailed.
  final List<GeoPosition> chart;

  /// The id route geometry is stored and looked up under.
  String get id => '${from.id}>${to.id}';

  @override
  List<Object?> get props => [from, to, kind, chart];

  /// Creates a leg.
  const JourneyLeg({
    required this.from,
    required this.to,
    required this.kind,
    this.chart = const [],
  });
}
