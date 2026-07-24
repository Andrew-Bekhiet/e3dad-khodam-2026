import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';

/// The "بلاد" (countries) root category and its two levels of children:
/// countries, then the cities within Asia Minor, Greece, and Italy.
final class CountriesBranch {
  static const GeoPosition _countriesPosition = GeoPosition(
    latitude: 31.0,
    longitude: 26.0,
  );
  static const GeoPosition _asiaMinorPosition = GeoPosition(
    latitude: 38.6,
    longitude: 31.0,
  );
  static const GeoPosition _greecePosition = GeoPosition(
    latitude: 39.0,
    longitude: 22.0,
  );
  static const GeoPosition _italyPosition = GeoPosition(
    latitude: 42.5,
    longitude: 12.5,
  );
  static const GeoPosition _galatiaPosition = GeoPosition(
    latitude: 39.9334,
    longitude: 32.8597,
  );
  static const GeoPosition _ephesusPosition = GeoPosition(
    latitude: 37.9395,
    longitude: 27.3417,
  );
  static const GeoPosition _colossaePosition = GeoPosition(
    latitude: 37.7543,
    longitude: 29.2598,
  );
  static const GeoPosition _philippiPosition = GeoPosition(
    latitude: 41.0131,
    longitude: 24.2864,
  );
  static const GeoPosition _corinthPosition = GeoPosition(
    latitude: 37.9061,
    longitude: 22.8783,
  );
  static const GeoPosition _thessalonicaPosition = GeoPosition(
    latitude: 40.6401,
    longitude: 22.9444,
  );
  static const GeoPosition _romePosition = GeoPosition(
    latitude: 41.8925,
    longitude: 12.4853,
  );

  /// The root category node, positioned as the bottom arm of the cross.
  /// This is a mnemonic cross anchor, not the real location of anything.
  static const CategoryNode node = CategoryNode(
    id: 'countries',
    label: 'بلاد',
    position: _countriesPosition,
    arm: CrossArm.bottom,
    children: [
      PlaceNode(
        id: 'asia_minor',
        label: 'آسيا الصغرى',
        position: _asiaMinorPosition,
        kind: PlaceKind.country,
        children: [
          PlaceNode(
            id: 'galatia',
            label: 'غلاطية',
            position: _galatiaPosition,
            kind: PlaceKind.city,
            children: [],
          ),
          PlaceNode(
            id: 'ephesus',
            label: 'أفسس',
            position: _ephesusPosition,
            kind: PlaceKind.city,
            children: [],
          ),
          PlaceNode(
            id: 'colossae',
            label: 'كولوسي',
            position: _colossaePosition,
            kind: PlaceKind.city,
            children: [],
          ),
        ],
      ),
      PlaceNode(
        id: 'greece',
        label: 'اليونان',
        position: _greecePosition,
        kind: PlaceKind.country,
        children: [
          PlaceNode(
            id: 'philippi',
            label: 'فيلبي',
            position: _philippiPosition,
            kind: PlaceKind.city,
            children: [],
          ),
          PlaceNode(
            id: 'corinth',
            label: 'كورنثوس',
            position: _corinthPosition,
            kind: PlaceKind.city,
            children: [],
          ),
          PlaceNode(
            id: 'thessalonica',
            label: 'تسالونيكي',
            position: _thessalonicaPosition,
            kind: PlaceKind.city,
            children: [],
          ),
        ],
      ),
      PlaceNode(
        id: 'italy',
        label: 'إيطاليا',
        position: _italyPosition,
        kind: PlaceKind.country,
        children: [
          PlaceNode(
            id: 'rome',
            label: 'رومية',
            position: _romePosition,
            kind: PlaceKind.city,
            children: [],
          ),
        ],
      ),
    ],
  );
}
