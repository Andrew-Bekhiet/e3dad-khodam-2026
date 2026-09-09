import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:flutter/widgets.dart';

/// Builds the glyph a marker style draws over its shape, from a Material
/// icon. Shared by `GameMapStyles` and `HistoryMapStyles`, whose marker
/// sets each rasterise a closed handful of icons the same way.
MapMarkerGlyph iconGlyph(
  IconData icon, {
  required double size,
  required Color color,
}) => MapMarkerGlyph(
  codePoint: icon.codePoint,
  fontFamily: icon.fontFamily ?? 'MaterialIcons',
  fontPackage: icon.fontPackage,
  size: size,
  color: color,
);
