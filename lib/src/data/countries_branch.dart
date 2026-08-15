import 'package:e3dad_khodam_2026/src/data/stop_positions.dart';
import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';

/// The "بلاد" (countries) root category and its two levels of children:
/// countries, then the cities within Asia Minor, Greece, and Italy.
///
/// The cities read their coordinates from `JourneyStops`, the app's one
/// gazetteer, so they cannot drift from where the game puts them. The
/// country positions below are mnemonic placements and stay here.
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
  static const GeoPosition _galatiaPosition = StopPositions.galatia;
  static const GeoPosition _ephesusPosition = StopPositions.ephesus;
  static const GeoPosition _colossaePosition = StopPositions.colossae;
  static const GeoPosition _philippiPosition = StopPositions.philippi;
  static const GeoPosition _corinthPosition = StopPositions.corinth;
  static const GeoPosition _thessalonicaPosition = StopPositions.thessalonica;
  static const GeoPosition _romePosition = StopPositions.rome;

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
