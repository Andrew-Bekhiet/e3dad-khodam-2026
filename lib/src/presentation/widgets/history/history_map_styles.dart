import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/marker_glyph.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/marker_styles.dart';
import 'package:flutter/material.dart';

/// The five states a stop can be in on the historical map.
///
/// Kept to a closed set for the same reason `GameMapStyles` is: one style
/// id is one rasterised image. `beaconBright`/`beaconDim` is two styles
/// rather than one animated opacity for the same constraint — the flash
/// is a swap between two rasters, not a live-painted marker.
final class HistoryMapStyles {
  /// The biggest marker on the map: the rest the journey stands at now.
  ///
  /// Sized for a TV projected across a hall, not a phone in the hand: an
  /// audience standing up to 10 metres back needs the shape and its ring
  /// to still read as a shape, not a smudge.
  static const MapMarkerStyle current = MapMarkerStyle(
    id: 'history-stop-current',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 130,
      color: GamePalette.accent,
      ringWidth: 7,
    ),
    shadow: MapMarkerShadow(blur: 22, offsetDy: 5, opacity: 0.36),
    glyph: null,
    label: _label,
  );

  /// A rest already arrived at and left behind.
  static const MapMarkerStyle rest = MapMarkerStyle(
    id: 'history-stop-rest',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 70,
      color: GamePalette.cleared,
      ringWidth: 5,
    ),
    shadow: MapMarkerShadow(blur: 13, offsetDy: 3, opacity: 0.24),
    glyph: null,
    label: _label,
  );

  /// Where the journey set out from.
  static final MapMarkerStyle origin = MapMarkerStyle(
    id: 'history-stop-origin',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.diamond,
      diameter: 80,
      color: GamePalette.ink,
      ringWidth: 5,
    ),
    shadow: const MapMarkerShadow(blur: 15, offsetDy: 3, opacity: 0.3),
    glyph: iconGlyph(Icons.trip_origin, size: 32, color: GamePalette.white),
    label: _label,
  );

  /// The beacon, lit — the state the flash spends half its time in. The
  /// glyph is a mailed letter, not a bulb: the beacon means a letter was
  /// sent to this city, and the flash is how that reads as "just
  /// happened" from across the room.
  ///
  /// Sized between [origin] and [current] so it catches the eye without
  /// competing with the rest the journey is actually standing at.
  static final MapMarkerStyle beaconBright = MapMarkerStyle(
    id: 'history-beacon-bright',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 100,
      color: HistoryPalette.beaconBright,
      ringWidth: 7,
    ),
    shadow: const MapMarkerShadow(blur: 34, offsetDy: 0, opacity: 0.55),
    glyph: iconGlyph(Icons.mail, size: 46, color: GamePalette.white),
    label: _label,
  );

  /// The beacon, unlit. Same size as [beaconBright] so the flash reads as
  /// a change in light rather than a marker growing and shrinking.
  static const MapMarkerStyle beaconDim = MapMarkerStyle(
    id: 'history-beacon-dim',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 100,
      color: HistoryPalette.beaconDim,
      ringWidth: 5,
    ),
    shadow: null,
    glyph: null,
    label: _label,
  );

  /// Labels read the same as the intro map's, so the two maps feel like
  /// one atlas.
  static const MapMarkerLabelStyle _label = MarkerStyles.placeLabel;

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
