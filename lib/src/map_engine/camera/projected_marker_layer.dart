import 'package:e3dad_khodam_2026/src/map_engine/camera/web_mercator_camera.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:flutter/widgets.dart';

/// Lays marker widgets over a map surface at the screen positions
/// [camera] projects their coordinates to.
///
/// Replaces what flutter_map's `MarkerLayer` used to do, now that the
/// basemap is drawn by a platform view that knows nothing about Flutter
/// widgets. The positioning formula is deliberately the one that layer
/// used, so `MapMarkerSpec.alignment` keeps its meaning and marker
/// anchoring is unchanged by the move.
final class ProjectedMarkerLayer extends StatelessWidget {
  static const double _half = 0.5;

  /// Camera the marker positions are projected through.
  final WebMercatorCamera camera;

  /// Markers to place.
  final List<MapMarkerSpec> markers;

  /// Creates a marker overlay.
  const ProjectedMarkerLayer({
    required this.camera,
    required this.markers,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Stack(
    // Markers near an edge legitimately overhang the viewport; clipping
    // them to it would chop labels off rather than let them run over.
    clipBehavior: Clip.none,
    children: [
      for (final marker in markers)
        if (_positionOf(marker) case final position)
          Positioned(
            key: ValueKey(marker.id),
            left: position.dx,
            top: position.dy,
            width: marker.size.width,
            height: marker.size.height,
            child: Builder(builder: marker.builder),
          ),
    ],
  );

  /// Top-left corner of [marker]'s box.
  ///
  /// `alignment` names the point *inside the box* that sits on the
  /// coordinate: `(0, 0)` centres the box on it, `(0, 1)` puts the
  /// coordinate at the box's bottom edge.
  Offset _positionOf(MapMarkerSpec marker) {
    final anchor = camera.offsetOf(marker.position);
    final fromRight = marker.size.width * _half * (1 - marker.alignment.x);
    final fromBottom = marker.size.height * _half * (1 - marker.alignment.y);

    return Offset(anchor.dx - fromRight, anchor.dy - fromBottom);
  }
}
