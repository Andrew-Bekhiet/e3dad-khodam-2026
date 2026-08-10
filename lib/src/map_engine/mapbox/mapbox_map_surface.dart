/// The Mapbox-backed `MapSurfaceBuilder`, resolved per platform.
///
/// Mobile renders with Mapbox's Maps SDK and web with Mapbox GL JS —
/// both official Mapbox renderers, both driving the same pixel style
/// built by `PixelStyleSource`. Neither SDK exists on the other's
/// platform, so the two implementations are kept in separate libraries
/// and selected here; nothing else in the app imports either directly.
library;

export 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_map_surface_native.dart'
    if (dart.library.js_interop) 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_map_surface_web.dart'
    show configureMapboxRenderer, mapboxMapSurface;
