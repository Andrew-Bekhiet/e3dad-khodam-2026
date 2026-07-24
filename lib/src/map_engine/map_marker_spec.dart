import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// A provider-agnostic description of one marker to render on the map,
/// consumed by a `MapSurfaceBuilder` implementation.
final class MapMarkerSpec extends Equatable {
  /// Stable identifier, typically the corresponding map node's id.
  final String id;

  /// Where the marker is anchored geographically.
  final GeoPosition position;

  /// The marker widget's footprint, used by the map engine to lay it out.
  final Size size;

  /// The point within [size] that lines up with [position], e.g.
  /// [Alignment.bottomCenter] for a pin whose tip should touch the ground.
  final Alignment alignment;

  /// Builds the marker's visual content.
  final WidgetBuilder builder;

  @override
  List<Object?> get props => [id, position, size, alignment];

  /// Creates a marker spec. [builder] is excluded from equality since
  /// closures are never structurally comparable.
  const MapMarkerSpec({
    required this.id,
    required this.position,
    required this.size,
    required this.alignment,
    required this.builder,
  });
}
