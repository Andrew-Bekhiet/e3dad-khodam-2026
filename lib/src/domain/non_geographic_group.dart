import 'package:equatable/equatable.dart';

/// A thematic grouping of epistle recipients that have no map location
/// (e.g. people addressed personally rather than places), shown outside
/// the map view.
final class NonGeographicGroup extends Equatable {
  /// The Arabic heading for this group, e.g. "أشخاص".
  final String label;

  /// The Arabic names belonging to this group.
  final List<String> members;

  @override
  List<Object?> get props => [label, members];

  /// Creates a non-geographic group.
  const NonGeographicGroup({required this.label, required this.members});
}
