@JS('mapboxgl')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Minimal bindings to the parts of Mapbox GL JS this app drives.
///
/// Hand-written rather than pulled from a package: the surface used here
/// is a dozen calls, and a binding generator's output would be far more
/// to review than the calls themselves.
///
/// The library is loaded by a `<script>` tag in `web/index.html`; every
/// member below is undefined until that has run, which is why
/// [isMapboxGlLoaded] is checked before any of it is touched.
@JS()
external set accessToken(String _);

/// Whether the `mapboxgl` global exists — i.e. whether the script tag in
/// `web/index.html` loaded.
///
/// Read off the global object rather than declared as an external here:
/// this library is annotated `@JS('mapboxgl')`, so a member named
/// `mapboxgl` would resolve to `mapboxgl.mapboxgl`.
bool get isMapboxGlLoaded => globalContext.has('mapboxgl');

/// A Mapbox GL JS map instance.
@JS('Map')
extension type GlMap._(JSObject _) implements JSObject {
  /// Creates a map inside the given container element.
  external GlMap(GlMapOptions options);

  /// Registers [listener] for [event].
  external void on(String event, JSFunction listener);

  /// Releases the map's WebGL context and DOM nodes.
  external void remove();

  /// Moves the camera immediately, with no animation. The app animates
  /// its own camera and pushes each frame, so GL JS never eases.
  external void jumpTo(GlCameraOptions options);

  /// Registers a pattern image under [id].
  external void addImage(String id, GlImageData image, GlImageOptions options);

  /// Whether an image is already registered under [id].
  external bool hasImage(String id);

  /// The current camera centre.
  external GlLngLat getCenter();

  /// The current zoom level.
  external double getZoom();

  /// Recomputes the map's size from its container. Needed whenever the
  /// Flutter view resizes the hosting element.
  external void resize();

  /// The pinch gesture handler, whose rotation half this app switches
  /// off — as it does every other rotation and pitch control.
  external GlTouchZoomRotateHandler get touchZoomRotate;
}

/// The pinch-zoom/rotate gesture handler.
extension type GlTouchZoomRotateHandler._(JSObject _) implements JSObject {
  /// Stops two-finger twists from rotating the map, leaving pinch-zoom.
  external void disableRotation();
}

/// An image passed to [GlMap.addImage]: raw RGBA plus its dimensions.
extension type GlImageData._(JSObject _) implements JSObject {
  /// Wraps [data] as the `{width, height, data}` shape GL JS expects.
  external factory GlImageData({
    int width,
    int height,
    JSUint8Array data,
  });
}

/// Options for [GlMap.addImage].
extension type GlImageOptions._(JSObject _) implements JSObject {
  /// Creates image options.
  external factory GlImageOptions({double pixelRatio});
}

/// Camera framing for [GlMapOptions]: where the map opens and how far it
/// may zoom.
typedef GlViewport = ({
  JSArray<JSNumber> center,
  double zoom,
  double minZoom,
  double maxZoom,
});

/// Gesture toggles for [GlMapOptions] — the fixed set the app disables on
/// both platforms so its own Web Mercator projection, which every marker
/// position depends on, is never invalidated by a rotated or pitched
/// camera.
typedef GlGestureOptions = ({
  bool dragRotate,
  bool pitchWithRotate,
  bool touchPitch,
});

/// Constructor options for [GlMap].
extension type GlMapOptions._(JSObject _) implements JSObject {
  /// Creates options.
  ///
  /// [style] is a decoded style document rather than a URL, so the pixel
  /// style is applied on the very first frame — there is no plain basemap
  /// to flash past first.
  ///
  /// Built by hand from a plain [JSObject] rather than an `external
  /// factory`: GL JS reads these off one flat object, so [viewport] and
  /// [gestures] are grouped here for readability and unpacked into that
  /// same flat shape below.
  factory GlMapOptions({
    required JSObject container,
    required JSAny style,
    required GlViewport viewport,
    required GlGestureOptions gestures,
    bool antialias = false,
    bool attributionControl = false,
  }) {
    final options = JSObject()
      ..['container'] = container
      ..['style'] = style
      ..['center'] = viewport.center
      ..['zoom'] = viewport.zoom.toJS
      ..['minZoom'] = viewport.minZoom.toJS
      ..['maxZoom'] = viewport.maxZoom.toJS
      ..['dragRotate'] = gestures.dragRotate.toJS
      ..['pitchWithRotate'] = gestures.pitchWithRotate.toJS
      ..['touchPitch'] = gestures.touchPitch.toJS
      ..['antialias'] = antialias.toJS
      ..['attributionControl'] = attributionControl.toJS;

    return GlMapOptions._(options);
  }
}

/// Camera options for [GlMap.jumpTo].
extension type GlCameraOptions._(JSObject _) implements JSObject {
  /// Creates camera options.
  external factory GlCameraOptions({
    JSArray<JSNumber> center,
    double zoom,
    double bearing,
    double pitch,
  });
}

/// A `{lng, lat}` pair as returned by [GlMap.getCenter].
extension type GlLngLat._(JSObject _) implements JSObject {
  /// Longitude in degrees.
  external double get lng;

  /// Latitude in degrees.
  external double get lat;
}
