import 'package:equatable/equatable.dart';

/// A geographic coordinate expressed in decimal degrees, independent of
/// any specific map-provider coordinate type.
final class GeoPosition extends Equatable {
  /// Degrees north (positive) or south (negative) of the equator.
  /// Expected to fall within `-90.0..90.0`.
  final double latitude;

  /// Degrees east (positive) or west (negative) of the prime meridian.
  /// Expected to fall within `-180.0..180.0`.
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];

  /// Creates a coordinate from decimal-degree latitude and longitude.
  const GeoPosition({required this.latitude, required this.longitude});
}
