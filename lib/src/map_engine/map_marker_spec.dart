import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:equatable/equatable.dart';

/// A provider-agnostic description of one marker to render on the map.
///
/// Pure data with no Flutter widget in sight: markers are handed to the
/// renderer as GeoJSON features drawn by a symbol layer, so everything
/// here has to survive being serialised into a feature's properties or
/// resolved from its [style].
final class MapMarkerSpec extends Equatable {
  /// Stable identifier, typically the corresponding map node's id. Also
  /// what a tap on this marker reports back, so it must round-trip
  /// through the feature's properties unchanged.
  final String id;

  /// Where the marker is anchored geographically.
  final GeoPosition position;

  /// Text drawn beneath the marker's shape.
  final String label;

  /// How the marker looks. Markers sharing a style share one style
  /// image.
  final MapMarkerStyle style;

  /// Whether tapping this marker should be reported. Leaf markers are
  /// inert, and excluding them here keeps them out of the tap query
  /// rather than relying on the caller to ignore the result.
  final bool isInteractive;

  /// Extra logical pixels to push the label down by, beyond what the
  /// style's own shape needs.
  ///
  /// Something drawn on top of the marker — a character's portrait, say
  /// — is not part of the style, so only the caller knows the label has
  /// more than the shape to clear.
  final double labelClearance;

  @override
  List<Object?> get props => [
    id,
    position,
    label,
    style,
    isInteractive,
    labelClearance,
  ];

  /// Creates a marker spec.
  const MapMarkerSpec({
    required this.id,
    required this.position,
    required this.label,
    required this.style,
    required this.isInteractive,
    this.labelClearance = 0,
  });
}
