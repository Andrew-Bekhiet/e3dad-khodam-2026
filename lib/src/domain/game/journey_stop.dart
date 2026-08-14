import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';

/// A place the journey passes through: where a letter is delivered, and
/// where the characters carrying it stand while it is read.
///
/// Deliberately separate from the `MapNode` hierarchy: that tree is the
/// mnemonic cross (قارات/بلاد/بحار/جزر) used by the reference map, while
/// this is the route the play actually walks — which visits places the
/// cross never mentions, such as أورشليم.
final class JourneyStop extends Equatable {
  /// Stable identifier, unique across the journey.
  final String id;

  /// The place's Arabic name, shown on its map marker.
  final String label;

  /// Where the stop sits on the map.
  final GeoPosition position;

  @override
  List<Object?> get props => [id, label, position];

  /// Creates a stop.
  const JourneyStop({
    required this.id,
    required this.label,
    required this.position,
  });
}
