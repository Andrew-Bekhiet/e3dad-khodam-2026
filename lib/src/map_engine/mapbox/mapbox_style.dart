/// The Mapbox Studio style this app's basemap renders, plus the access
/// token used to fetch its raster tiles.
///
/// The token is *not* checked in: it is read from the compile-time
/// environment, so builds supply it with
/// `flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk....`. A missing
/// token is reported loudly by `MapboxMapSurface` rather than silently
/// producing an empty basemap.
final class MapboxStyle {
  /// Owner of the Studio style — the `{username}` path segment of the
  /// Static Tiles API.
  static const String username = 'anderwbekhiet';

  /// The Studio style id, taken from its Studio URL.
  static const String styleId = 'cms775jc8003x01sd2mmyeczh';

  /// Tile edge length in pixels requested from Mapbox. 512 is the size
  /// the style's own label/icon sizes are authored against (it is what
  /// Studio and Mapbox GL render), and requires [zoomOffset] to keep
  /// flutter_map's 256px-based zoom levels aligned.
  static const int tileDimension = 512;

  /// Zoom correction for [tileDimension]: one 512px tile covers the same
  /// ground as four 256px tiles, i.e. one whole zoom level.
  static const double zoomOffset = -1.0;

  /// Public access token (`pk....`), or the empty string when the build
  /// did not define one.
  static const String accessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );

  /// Whether [accessToken] was supplied at build time.
  static bool get hasAccessToken => accessToken.isNotEmpty;

  /// The dart-define key [accessToken] is read from, named here so error
  /// messages and build docs cannot drift apart.
  static const String accessTokenEnvKey = 'MAPBOX_ACCESS_TOKEN';

  /// Raster tile template for [styleId], with flutter_map's `{r}`
  /// placeholder so high-density screens get `@2x` tiles.
  static const String tileUrlTemplate =
      'https://api.mapbox.com/styles/v1/$username/$styleId/tiles'
      '/$tileDimension/{z}/{x}/{y}{r}?access_token=$accessToken';

  const MapboxStyle._();
}
