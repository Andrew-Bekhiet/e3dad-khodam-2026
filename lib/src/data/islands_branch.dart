import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';

/// The "جزر" (islands) root category and its leaf children.
final class IslandsBranch {
  static const GeoPosition _islandsPosition = GeoPosition(
    latitude: 36.5,
    longitude: 34.5,
  );
  static const GeoPosition _cretePosition = GeoPosition(
    latitude: 35.2401,
    longitude: 24.8093,
  );
  static const GeoPosition _cyprusPosition = GeoPosition(
    latitude: 35.1264,
    longitude: 33.4299,
  );
  static const GeoPosition _maltaPosition = GeoPosition(
    latitude: 35.9375,
    longitude: 14.3754,
  );

  /// The root category node, positioned as the right arm of the cross.
  /// Coordinates are provisional pending final design sign-off.
  static const CategoryNode node = CategoryNode(
    id: 'islands',
    label: 'جزر',
    position: _islandsPosition,
    arm: CrossArm.right,
    children: [
      PlaceNode(
        id: 'crete',
        label: 'كريت',
        position: _cretePosition,
        kind: PlaceKind.island,
        children: [],
      ),
      PlaceNode(
        id: 'cyprus',
        label: 'قبرص',
        position: _cyprusPosition,
        kind: PlaceKind.island,
        children: [],
      ),
      PlaceNode(
        id: 'malta',
        label: 'مالطة',
        position: _maltaPosition,
        kind: PlaceKind.island,
        children: [],
      ),
    ],
  );
}
