import 'dart:math' as math;

import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/camera/web_mercator_camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _viewport = Size(400, 800);
const _center = GeoPosition(latitude: 37.5, longitude: 18.0);

WebMercatorCamera _camera({double zoom = 5}) =>
    WebMercatorCamera(center: _center, zoom: zoom, viewport: _viewport);

void main() {
  group('WebMercatorCamera', () {
    test('projectsItsOwnCentreToTheViewportCentre', () {
      final offset = _camera().offsetOf(_center);

      expect(offset.dx, closeTo(_viewport.width / 2, 1e-9));
      expect(offset.dy, closeTo(_viewport.height / 2, 1e-9));
    });

    test('putsEastRightAndNorthUp', () {
      final camera = _camera();
      final east = camera.offsetOf(
        const GeoPosition(latitude: 37.5, longitude: 20.0),
      );
      final north = camera.offsetOf(
        const GeoPosition(latitude: 40.0, longitude: 18.0),
      );

      expect(east.dx, greaterThan(_viewport.width / 2));
      expect(east.dy, closeTo(_viewport.height / 2, 1e-9));
      expect(north.dy, lessThan(_viewport.height / 2));
      expect(north.dx, closeTo(_viewport.width / 2, 1e-9));
    });

    test('doublesPixelDistancePerZoomLevel', () {
      const target = GeoPosition(latitude: 37.5, longitude: 20.0);
      final near = _camera().offsetOf(target).dx - _viewport.width / 2;
      final far = _camera(zoom: 6).offsetOf(target).dx - _viewport.width / 2;

      expect(far, closeTo(near * 2, 1e-6));
    });

    test('spacesEqualMercatorOffsetsEqually', () {
      // The design spec's cross is built on this invariant: equal
      // Mercator-y offsets and equal longitude offsets must cover the
      // same number of pixels.
      final camera = _camera();
      final center = camera.offsetOf(_center);
      final top = camera.offsetOf(
        const GeoPosition(latitude: 43.57, longitude: 18.0),
      );
      final bottom = camera.offsetOf(
        const GeoPosition(latitude: 30.89, longitude: 18.0),
      );
      final left = camera.offsetOf(
        const GeoPosition(latitude: 37.5, longitude: 10.0),
      );
      final right = camera.offsetOf(
        const GeoPosition(latitude: 37.5, longitude: 26.0),
      );

      final up = center.dy - top.dy;
      final down = bottom.dy - center.dy;
      final west = center.dx - left.dx;
      final east = right.dx - center.dx;

      expect(up, closeTo(down, 0.5));
      expect(west, closeTo(east, 1e-9));
      expect(up, closeTo(west, 0.5));
    });

    group('fitting', () {
      const bounds = GeoBounds(
        south: 30.89,
        west: 10.0,
        north: 43.57,
        east: 26.0,
      );

      test('framesTheBoundsInsideTheViewport', () {
        final camera = WebMercatorCamera.fitting(
          bounds,
          viewport: _viewport,
          padding: EdgeInsets.zero,
          minZoom: 0,
          maxZoom: 22,
        );
        final northWest = camera.offsetOf(
          const GeoPosition(latitude: 43.57, longitude: 10.0),
        );
        final southEast = camera.offsetOf(
          const GeoPosition(latitude: 30.89, longitude: 26.0),
        );

        expect(northWest.dx, greaterThanOrEqualTo(-0.01));
        expect(northWest.dy, greaterThanOrEqualTo(-0.01));
        expect(southEast.dx, lessThanOrEqualTo(_viewport.width + 0.01));
        expect(southEast.dy, lessThanOrEqualTo(_viewport.height + 0.01));
      });

      test('touchesTheTighterAxis', () {
        final camera = WebMercatorCamera.fitting(
          bounds,
          viewport: _viewport,
          padding: EdgeInsets.zero,
          minZoom: 0,
          maxZoom: 22,
        );
        final west = camera.offsetOf(
          const GeoPosition(latitude: 37.5, longitude: 10.0),
        );
        final east = camera.offsetOf(
          const GeoPosition(latitude: 37.5, longitude: 26.0),
        );

        // The box is far wider than tall relative to this viewport, so
        // the fit is width-limited and must reach both side edges.
        expect(west.dx, closeTo(0, 0.01));
        expect(east.dx, closeTo(_viewport.width, 0.01));
      });

      test('shiftsTheCentreByPaddingImbalance', () {
        const padding = EdgeInsets.only(top: 100);
        final plain = WebMercatorCamera.fitting(
          bounds,
          viewport: _viewport,
          padding: EdgeInsets.zero,
          minZoom: 0,
          maxZoom: 22,
        );
        final padded = WebMercatorCamera.fitting(
          bounds,
          viewport: _viewport,
          padding: padding,
          minZoom: 0,
          maxZoom: 22,
        );

        // Top-only padding pushes the content down the screen.
        expect(padded.zoom, lessThanOrEqualTo(plain.zoom));
        expect(
          padded.offsetOf(bounds.center).dy,
          greaterThan(plain.offsetOf(bounds.center).dy),
        );
      });

      test('respectsZoomLimits', () {
        const tiny = GeoBounds(
          south: 37.4999,
          west: 17.9999,
          north: 37.5001,
          east: 18.0001,
        );
        final camera = WebMercatorCamera.fitting(
          tiny,
          viewport: _viewport,
          padding: EdgeInsets.zero,
          minZoom: 4,
          maxZoom: 9,
        );

        expect(camera.zoom, 9);
      });
    });

    test('worldSizeFollowsTheTileSize', () {
      expect(
        _camera(zoom: 3).worldSize,
        WebMercatorCamera.tileSize * math.pow(2, 3),
      );
    });
  });
}
