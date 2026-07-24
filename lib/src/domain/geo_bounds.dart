import 'package:collection/collection.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';

/// An axis-aligned rectangle in decimal-degree coordinates, used to frame
/// a set of [GeoPosition]s when asking a map surface to fit its camera.
final class GeoBounds extends Equatable {
  /// Southern edge latitude.
  final double south;

  /// Western edge longitude.
  final double west;

  /// Northern edge latitude.
  final double north;

  /// Eastern edge longitude.
  final double east;

  /// The midpoint between the box's edges.
  GeoPosition get center => GeoPosition(
    // ignore: no_magic_number
    latitude: (south + north) / 2,
    // ignore: no_magic_number
    longitude: (west + east) / 2,
  );

  @override
  List<Object?> get props => [south, west, north, east];

  /// Creates a bounding box from its four edges.
  const GeoBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  /// Computes the smallest [GeoBounds] enclosing every position in
  /// [positions].
  ///
  /// Throws [ArgumentError] if [positions] is empty, since no box can
  /// enclose zero points.
  factory GeoBounds.containing(Iterable<GeoPosition> positions) {
    final positionList = positions.toList();
    if (positionList.isEmpty) {
      throw ArgumentError.value(positions, 'positions', 'must not be empty');
    }
    final latitudes = positionList.map((position) => position.latitude);
    final longitudes = positionList.map((position) => position.longitude);

    return GeoBounds(
      south: latitudes.min,
      north: latitudes.max,
      west: longitudes.min,
      east: longitudes.max,
    );
  }

  /// Returns a copy expanded outward by [degrees] on every edge.
  GeoBounds padded(double degrees) => GeoBounds(
    south: south - degrees,
    west: west - degrees,
    north: north + degrees,
    east: east + degrees,
  );
}
