import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';

/// The "قارات" (continents) root category and its leaf children.
///
/// Split into its own file, alongside the other three category branches,
/// so `st_paul_map_dataset.dart` stays under the project's line-count
/// limit.
final class ContinentsBranch {
  static const GeoPosition _continentsPosition = GeoPosition(
    latitude: 47.5,
    longitude: 18.0,
  );
  static const GeoPosition _asiaPosition = GeoPosition(
    latitude: 38.5,
    longitude: 38.0,
  );
  static const GeoPosition _africaPosition = GeoPosition(
    latitude: 29.0,
    longitude: 21.0,
  );
  static const GeoPosition _europePosition = GeoPosition(
    latitude: 46.0,
    longitude: 15.0,
  );

  /// The root category node, positioned as the top arm of the cross.
  /// Coordinates are provisional pending final design sign-off.
  static const CategoryNode node = CategoryNode(
    id: 'continents',
    label: 'قارات',
    position: _continentsPosition,
    arm: CrossArm.top,
    children: [
      PlaceNode(
        id: 'asia',
        label: 'أسيا',
        position: _asiaPosition,
        kind: PlaceKind.continent,
        children: [],
      ),
      PlaceNode(
        id: 'africa',
        label: 'أفريقيا',
        position: _africaPosition,
        kind: PlaceKind.continent,
        children: [],
      ),
      PlaceNode(
        id: 'europe',
        label: 'أوروبا',
        position: _europePosition,
        kind: PlaceKind.continent,
        children: [],
      ),
    ],
  );
}
