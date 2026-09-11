import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:flutter/material.dart';

/// The fixed, per-node-kind marker recipe from the design spec's marker
/// table (§2–§4), expressed as the map engine's [MapMarkerStyle].
///
/// Each distinct [MapMarkerStyle.id] becomes exactly one style image in
/// the renderer, so keeping this a small closed set is what keeps marker
/// rendering cheap: a level showing thirty cities still costs one image.
final class MarkerStyles {
  /// Continent marker.
  static const MapMarkerStyle continent = MapMarkerStyle(
    id: 'marker-continent',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: _placeIconSize,
      color: Color(0xFFE23C13),
    ),
    shadow: MapMarkerShadow(blur: 6, offsetDy: 2, opacity: 0.7),
    glyph: null,
    label: placeLabel,
  );

  /// Country marker.
  static const MapMarkerStyle country = MapMarkerStyle(
    id: 'marker-country',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.roundedSquare,
      diameter: _placeIconSize,
      color: Color(0xFFE23C13),
    ),
    shadow: MapMarkerShadow(blur: 6, offsetDy: 2, opacity: 0.7),
    glyph: null,
    label: placeLabel,
  );

  /// Sea marker.
  static final MapMarkerStyle sea = MapMarkerStyle(
    id: 'marker-sea',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.diamond,
      diameter: _placeIconSize,
      color: Color(0xFFE8720F),
      cornerRadius: 6,
    ),
    shadow: const MapMarkerShadow(blur: 5, offsetDy: 1, opacity: 0.7),
    glyph: _glyph(Icons.waves, size: _placeIconSize),
    label: placeLabel,
  );

  /// Island marker.
  static final MapMarkerStyle island = MapMarkerStyle(
    id: 'marker-island',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: _placeIconSize,
      color: Color(0xFFE8720F),
    ),
    shadow: const MapMarkerShadow(blur: 5, offsetDy: 1, opacity: 0.7),
    glyph: _glyph(Icons.terrain, size: _placeIconSize),
    label: placeLabel,
  );

  /// City marker: a small dot with a bare label, the only leaf kind.
  static const MapMarkerStyle city = MapMarkerStyle(
    id: 'marker-city',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: _placeIconSize,
      color: Color(0xFFE23C13),
    ),
    shadow: MapMarkerShadow(blur: 5, offsetDy: 1, opacity: 0.7),
    glyph: null,
    label: MapMarkerLabelStyle(
      fontSize: _placeIconSize * 0.9,
      haloColor: Colors.black,
      color: _white,
      haloWidth: 2,
      gap: 3,
    ),
  );

  static const Color _white = Color(0xFFFFFFFF);
  static const double _placeIconSize = 90;
  static const double _categoryIconSize = 90;

  static const MapMarkerLabelStyle _categoryLabel = MapMarkerLabelStyle(
    fontSize: _categoryIconSize * 0.9,
    haloColor: Colors.black,
    color: _white,
    haloWidth: 2,
    gap: 4,
  );

  /// The label under every place marker; the historical map borrows it
  /// too.
  static const MapMarkerLabelStyle placeLabel = MapMarkerLabelStyle(
    fontSize: _placeIconSize * 1.1,
    color: _white,
    haloWidth: 1,
    haloColor: Colors.black,
    gap: 4,
  );

  /// Picks the profile for [node]'s kind: one per arm of the root cross
  /// for [CategoryNode]s, and one per [PlaceKind] for [PlaceNode]s.
  static MapMarkerStyle forNode(MapNode node) => switch (node) {
    CategoryNode(:final arm) => categoryFor(arm),
    PlaceNode(:final kind) => switch (kind) {
      PlaceKind.continent => continent,
      PlaceKind.country => country,
      PlaceKind.sea => sea,
      PlaceKind.island => island,
      PlaceKind.city => city,
    },
  };

  /// The root category marker for [arm]: the largest, ringed circle,
  /// carrying that arm's own icon.
  ///
  /// The arm is folded into the style id because a style id maps
  /// one-to-one onto a rasterised image — four ids, four images, rather
  /// than one id whose artwork depends on who asked for it last.
  static MapMarkerStyle categoryFor(CrossArm arm) => MapMarkerStyle(
    id: 'marker-category-${arm.name}',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: _placeIconSize,
      color: Color(0xFF123C69),
      ringWidth: 2,
    ),
    shadow: const MapMarkerShadow(blur: 8, offsetDy: 2, opacity: 07),
    glyph: _glyph(_iconForArm(arm), size: _categoryIconSize),
    label: _categoryLabel,
  );

  static IconData _iconForArm(CrossArm arm) => switch (arm) {
    CrossArm.top => Icons.public,
    CrossArm.bottom => Icons.flag,
    CrossArm.left => Icons.waves,
    CrossArm.right => Icons.beach_access,
  };

  static MapMarkerGlyph _glyph(IconData icon, {required double size}) =>
      MapMarkerGlyph(
        codePoint: icon.codePoint,
        fontFamily: icon.fontFamily ?? 'MaterialIcons',
        fontPackage: icon.fontPackage,
        size: size,
        color: _white,
      );

  const MarkerStyles._();
}
