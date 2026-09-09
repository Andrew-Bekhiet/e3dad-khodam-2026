import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/marker_glyph.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:flutter/material.dart';

/// The six states a stop can be in on the historical map.
///
/// Kept to a closed set for the same reason `GameMapStyles` is: one style
/// id is one rasterised image. `beaconBright`/`beaconDim` is two styles
/// rather than one animated opacity for the same constraint — the flash
/// is a swap between two rasters, not a live-painted marker.
final class HistoryMapStyles {
  /// The biggest marker on the map: the rest the journey stands at now.
  static const MapMarkerStyle current = MapMarkerStyle(
    id: 'history-stop-current',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 52,
      color: GamePalette.accent,
      ringWidth: 3,
    ),
    shadow: MapMarkerShadow(blur: 9, offsetDy: 2, opacity: 0.34),
    glyph: null,
    label: _labelLarge,
  );

  /// A rest already arrived at and left behind.
  static const MapMarkerStyle rest = MapMarkerStyle(
    id: 'history-stop-rest',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 28,
      color: GamePalette.cleared,
      ringWidth: 2,
    ),
    shadow: MapMarkerShadow(blur: 5, offsetDy: 1, opacity: 0.22),
    glyph: null,
    label: _label,
  );

  /// Where the journey set out from.
  static final MapMarkerStyle origin = MapMarkerStyle(
    id: 'history-stop-origin',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.diamond,
      diameter: 34,
      color: GamePalette.ink,
      ringWidth: 2,
    ),
    shadow: const MapMarkerShadow(blur: 6, offsetDy: 1, opacity: 0.28),
    glyph: iconGlyph(Icons.trip_origin, size: 14, color: GamePalette.white),
    label: _label,
  );

  /// A city the trail has passed through without stopping: a small dot
  /// with a small label, well under [rest] in weight.
  static const MapMarkerStyle waypoint = MapMarkerStyle(
    id: 'history-stop-waypoint',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 10,
      color: GamePalette.locked,
    ),
    shadow: null,
    glyph: null,
    label: _labelSmall,
  );

  /// The beacon, lit — the state the flash spends half its time in.
  /// Sized between [origin] and [current] so it catches the eye without
  /// competing with the rest the journey is actually standing at.
  static final MapMarkerStyle beaconBright = MapMarkerStyle(
    id: 'history-beacon-bright',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 34,
      color: HistoryPalette.beaconBright,
      ringWidth: 3,
    ),
    shadow: const MapMarkerShadow(blur: 14, offsetDy: 0, opacity: 0.55),
    glyph: iconGlyph(Icons.lightbulb, size: 16, color: GamePalette.white),
    label: _label,
  );

  /// The beacon, unlit. Same size as [beaconBright] so the flash reads as
  /// a change in light rather than a marker growing and shrinking.
  static const MapMarkerStyle beaconDim = MapMarkerStyle(
    id: 'history-beacon-dim',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 34,
      color: HistoryPalette.beaconDim,
      ringWidth: 2,
    ),
    shadow: null,
    glyph: null,
    label: _label,
  );

  static const MapMarkerLabelStyle _labelLarge = MapMarkerLabelStyle(
    fontSize: 32,
    color: GamePalette.ink,
    haloColor: GamePalette.white,
    haloWidth: 2,
    gap: 4,
  );

  static const MapMarkerLabelStyle _label = MapMarkerLabelStyle(
    fontSize: 24,
    color: GamePalette.ink,
    haloColor: GamePalette.white,
    haloWidth: 2,
    gap: 4,
  );

  static const MapMarkerLabelStyle _labelSmall = MapMarkerLabelStyle(
    fontSize: 14,
    color: GamePalette.ink,
    haloColor: GamePalette.white,
    haloWidth: 1.5,
    gap: 2,
  );

  const HistoryMapStyles._();
}

/// Colours the historical map needs that [GamePalette] has no equivalent
/// for. `GamePalette` itself lives under `widgets/game/`, which this
/// feature does not touch, so the beacon's own warmths live here instead.
final class HistoryPalette {
  /// The beacon, lit.
  static const Color beaconBright = Color(0xFFFF6A3D);

  /// The beacon, unlit — the same hue, banked down.
  static const Color beaconDim = Color(0xFF7A3320);

  const HistoryPalette._();
}
