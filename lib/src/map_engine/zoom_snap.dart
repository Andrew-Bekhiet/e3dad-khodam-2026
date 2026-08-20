/// Calculates the pixel-art zoom level nearest to a gesture's endpoint.
final class ZoomSnap {
  /// Returns the nearest snap level when [zoom] is far enough away to move.
  static double? targetFor(
    double zoom, {
    required double increment,
    required double epsilon,
  }) {
    if (increment <= 0) {
      return null;
    }
    final snapped = (zoom / increment).roundToDouble() * increment;

    return (snapped - zoom).abs() < epsilon ? null : snapped;
  }

  const ZoomSnap._();
}
