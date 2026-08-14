import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/marker_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bridges the navigation cubit's `MapHierarchyState` to the
/// provider-agnostic map seam: turns each visible `MapNode` into a
/// [MapMarkerSpec] and hands the resulting [MapSurfaceSpec] to the
/// injected [MapSurfaceBuilder].
final class JourneyMapView extends StatelessWidget {
  static const double _minZoom = 4.0;
  static const double _maxZoom = 18.0;

  /// Creates the map view; reads its data from ambient providers.
  const JourneyMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MapHierarchyCubit>();
    final surfaceBuilder = context.read<MapSurfaceBuilder>();
    final state = cubit.state;
    final spec = MapSurfaceSpec(
      markers: [
        for (final node in state.visibleNodes)
          MapMarkerSpec(
            id: node.id,
            position: node.position,
            label: node.label,
            style: MarkerStyles.forNode(node),
            isInteractive: node.isExpandable,
          ),
      ],
      camera: state.camera,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
      cameraAnimationDuration: state.cameraAnimationDuration,
      onMarkerTap: cubit.drillDown,
    );

    return surfaceBuilder(spec);
  }
}
