import 'package:e3dad_khodam_2026/src/map_engine/zoom_snap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rounds a gesture endpoint to the nearest increment', () {
    expect(
      ZoomSnap.targetFor(5.026, increment: 0.05, epsilon: 0.001),
      closeTo(5.05, 1e-12),
    );
    expect(
      ZoomSnap.targetFor(5.024, increment: 0.05, epsilon: 0.001),
      closeTo(5.0, 1e-12),
    );
  });

  test('does not request a snap already within the feedback threshold', () {
    expect(
      ZoomSnap.targetFor(5.0005, increment: 0.05, epsilon: 0.001),
      isNull,
    );
  });

  test('does not snap when snapping is disabled', () {
    expect(
      ZoomSnap.targetFor(5.026, increment: 0, epsilon: 0.001),
      isNull,
    );
  });
}
