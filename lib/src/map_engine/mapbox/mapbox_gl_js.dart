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

/// Installs the plugin that shapes and reorders right-to-left scripts.
///
/// Without it GL JS draws Arabic as isolated glyphs in logical order, so
/// a label reads back to front with no letters joined. The native SDKs
/// ship this support built in; only GL JS makes you ask. Throws if called
/// more than once per page, hence [ensureRtlTextPluginSet].
@JS('setRTLTextPlugin')
external void _setRtlTextPlugin(String _, JSFunction? __, bool ___);

bool _rtlTextPluginSet = false;

/// Installs the RTL text plugin once per page, before the first map is
/// created. Later calls are no-ops.
void ensureRtlTextPluginSet() {
  if (_rtlTextPluginSet) {
    return;
  }
  _rtlTextPluginSet = true;
  // Eager rather than lazy: lazy defers the download until RTL text is
  // first encountered, which is the very first frame here and shows the
  // labels unshaped until it lands.
  _setRtlTextPlugin(rtlTextPluginUrl, null, false);
}

/// The Mapbox-hosted RTL text plugin bundle.
const String rtlTextPluginUrl =
    'https://api.mapbox.com/mapbox-gl-js/plugins/mapbox-gl-rtl-text/v0.3.0/mapbox-gl-rtl-text.js';

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

  /// Registers [listener] for [event] on features of [layerId] only.
  @JS('on')
  external void onLayer(String event, String layerId, JSFunction listener);

  /// Moves the camera immediately, with no animation.
  external void jumpTo(GlCameraOptions options);

  /// Eases the camera to [options] over its `duration`.
  external void easeTo(GlCameraOptions options);

  /// Frames [bounds] — `[[west, south], [east, north]]` — inside the
  /// current viewport, honouring [options]' padding and duration.
  external void fitBounds(
    JSArray<JSArray<JSNumber>> bounds,
    GlFitBoundsOptions options,
  );

  /// Features of [options]' layers rendered under [point].
  ///
  /// Used to tell a tap on a marker from a tap on the map: GL JS reports
  /// both through the same `click`, and only the renderer knows where the
  /// markers ended up on screen.
  external JSArray<GlMapFeature> queryRenderedFeatures(
    JSAny point,
    GlQueryOptions options,
  );

  /// The source registered under [id], or undefined before the style has
  /// loaded.
  external GlGeoJsonSource? getSource(String id);

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

  /// Adds [control] at [position] — one of `top-left`, `top-right`,
  /// `bottom-left`, `bottom-right`.
  ///
  /// The only way to place the attribution anywhere but its default
  /// corner: GL JS takes `logoPosition` as a map option but offers no
  /// matching option for the attribution, so it has to be switched off
  /// in [GlMapOptions] and re-added here.
  external void addControl(JSObject control, String position);
}

/// GL JS's attribution control — the `©` line the tile terms require.
@JS('AttributionControl')
extension type GlAttributionControl._(JSObject _) implements JSObject {
  /// Creates a collapsed attribution control.
  external GlAttributionControl();
}

/// A `geojson` source, whose features can be replaced wholesale.
extension type GlGeoJsonSource._(JSObject _) implements JSObject {
  /// Replaces the source's data with [featureCollection].
  external void setData(JSAny featureCollection);
}

/// Options for [GlMap.fitBounds].
extension type GlFitBoundsOptions._(JSObject _) implements JSObject {
  /// Creates fit options. [padding] is `{top,right,bottom,left}` in
  /// pixels; a [duration] of zero fits without animating.
  factory GlFitBoundsOptions({
    required JSObject padding,
    required double duration,
    required double maxZoom,
  }) {
    final options = JSObject()
      ..['padding'] = padding
      ..['duration'] = duration.toJS
      ..['maxZoom'] = maxZoom.toJS;

    return GlFitBoundsOptions._(options);
  }
}

/// Options for [GlMap.queryRenderedFeatures].
extension type GlQueryOptions._(JSObject _) implements JSObject {
  /// Creates query options restricted to [layers].
  factory GlQueryOptions({required JSArray<JSString> layers}) =>
      GlQueryOptions._(JSObject()..['layers'] = layers);
}

/// The event GL JS passes to a click listener.
extension type GlMapMouseEvent._(JSObject _) implements JSObject {
  /// Features under the pointer, topmost first. Always present on a
  /// layer-scoped listener, which only fires when something was hit, and
  /// absent on a listener for the whole map.
  external JSArray<GlMapFeature>? get features;

  /// Where the click landed, in pixels from the container's top left.
  external JSAny get point;
}

/// A rendered feature as surfaced by [GlMapMouseEvent].
extension type GlMapFeature._(JSObject _) implements JSObject {
  /// The feature's `properties` object.
  external JSObject get properties;
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

/// Constructor options for [GlMap].
extension type GlMapOptions._(JSObject _) implements JSObject {
  /// Creates options.
  ///
  /// [style] is a decoded style document rather than a URL, so the pixel
  /// style is applied on the very first frame — there is no plain basemap
  /// to flash past first.
  ///
  /// Built by hand from a plain [JSObject] rather than an `external
  /// factory`: GL JS reads these off one flat object, so [viewport] is
  /// grouped here for readability and unpacked into that flat shape.
  factory GlMapOptions({
    required JSObject container,
    required JSAny style,
    required GlViewport viewport,
    bool antialias = false,
    bool attributionControl = false,
    String logoPosition = 'bottom-left',
  }) {
    final options = JSObject()
      ..['container'] = container
      ..['style'] = style
      ..['center'] = viewport.center
      ..['zoom'] = viewport.zoom.toJS
      ..['minZoom'] = viewport.minZoom.toJS
      ..['maxZoom'] = viewport.maxZoom.toJS
      ..['antialias'] = antialias.toJS
      ..['attributionControl'] = attributionControl.toJS
      ..['logoPosition'] = logoPosition.toJS;

    return GlMapOptions._(options);
  }
}

/// Camera options for [GlMap.jumpTo] and [GlMap.easeTo].
///
/// Built by hand rather than as an object-literal constructor so an
/// omitted `center` is genuinely absent: GL JS treats a present-but-null
/// `center` as a request to move to null, not as "leave it alone".
extension type GlCameraOptions._(JSObject _) implements JSObject {
  /// Creates camera options. [duration] is only read by [GlMap.easeTo].
  factory GlCameraOptions({
    required double zoom,
    double duration = 0,
    JSArray<JSNumber>? center,
  }) {
    final options = JSObject()
      ..['zoom'] = zoom.toJS
      ..['duration'] = duration.toJS;
    if (center != null) {
      options['center'] = center;
    }

    return GlCameraOptions._(options);
  }
}

/// A `{lng, lat}` pair as returned by [GlMap.getCenter].
extension type GlLngLat._(JSObject _) implements JSObject {
  /// Longitude in degrees.
  external double get lng;

  /// Latitude in degrees.
  external double get lat;
}
