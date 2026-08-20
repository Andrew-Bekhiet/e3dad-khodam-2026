import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';

/// The "بحار" (seas) root category and its leaf children.
final class SeasBranch {
  static const GeoPosition _seasPosition = GeoPosition(
    latitude: 36.5,
    longitude: 19.0,
  );
  static const GeoPosition _mediterraneanSeaPosition = GeoPosition(
    latitude: 34.5,
    longitude: 18.0,
  );
  static const GeoPosition _aegeanSeaPosition = GeoPosition(
    latitude: 38.5,
    longitude: 25.0,
  );
  static const GeoPosition _adriaticSeaPosition = GeoPosition(
    latitude: 43.0,
    longitude: 15.3,
  );

  /// The root category node, positioned as the left arm of the cross.
  /// This is a mnemonic cross anchor, not the real location of anything.
  static const CategoryNode node = CategoryNode(
    id: 'seas',
    label: 'بحار',
    position: _seasPosition,
    arm: CrossArm.left,
    children: [
      PlaceNode(
        id: 'mediterranean_sea',
        label: 'البحر المتوسط',
        position: _mediterraneanSeaPosition,
        kind: PlaceKind.sea,
        children: [],
      ),
      PlaceNode(
        id: 'aegean_sea',
        label: 'بحر إيجه',
        position: _aegeanSeaPosition,
        kind: PlaceKind.sea,
        children: [],
      ),
      PlaceNode(
        id: 'adriatic_sea',
        label: 'بحر ادريا',
        position: _adriaticSeaPosition,
        kind: PlaceKind.sea,
        children: [],
      ),
    ],
  );
}
