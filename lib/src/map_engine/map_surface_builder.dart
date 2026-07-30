import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:flutter/widgets.dart';

/// Renders a [MapSurfaceSpec] using some concrete map provider.
///
/// This is a function type rather than an interface: an interface exposing
/// a single `Widget`-returning method is banned by `avoid_returning_widgets`
/// (which exempts only `@override`), and a one-method interface is
/// functionally a function anyway — implementations are supplied as
/// constructor tear-offs, e.g. `MapboxMapSurface.new`.
typedef MapSurfaceBuilder = Widget Function(MapSurfaceSpec spec);
