import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

part 'center_zoom_camera_target.dart';
part 'fit_bounds_camera_target.dart';

/// Where a map surface's camera should be, expressed provider-agnostically
/// so a map-surface widget can diff camera changes across rebuilds and
/// animate accordingly.
///
/// Sealed so `OsmMapSurface` can switch exhaustively over its variants.
/// Split across `part` files (one class per file) since Dart requires a
/// sealed type's direct subtypes to live in the same library.
sealed class MapCameraTarget extends Equatable {
  /// Const constructor for subclasses.
  const MapCameraTarget();
}
