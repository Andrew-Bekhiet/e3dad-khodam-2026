/// Identifies the Mapbox account and style the basemap is built from,
/// and carries the access token the renderers authenticate with.
///
/// The token is *not* checked in: it is read from the compile-time
/// environment, so builds supply it with
/// `flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk....`. A missing
/// token is reported by `MissingAccessTokenNotice` rather than silently
/// producing an empty basemap.
final class MapboxStyle {
  /// Whether [accessToken] was supplied at build time.
  static bool get hasAccessToken => accessToken.isNotEmpty;

  /// Owner of the Studio style — the `{username}` path segment of the
  /// Static Tiles API.
  static const String username = 'anderwbekhiet';

  /// The Studio style id, taken from its Studio URL.
  static const String styleId = 'cms775jc8003x01sd2mmyeczh';

  /// The style's `mapbox://` URI.
  ///
  /// Only used as the placeholder the native SDK insists on at
  /// construction; what actually gets rendered is the pixel style built
  /// by `PixelStyleSource`.
  static const String styleUri = 'mapbox://styles/$username/$styleId';

  /// Public access token (`pk....`), or the empty string when the build
  /// did not define one.
  static const String accessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );

  /// The dart-define key [accessToken] is read from, named here so error
  /// messages and build docs cannot drift apart.
  static const String accessTokenEnvKey = 'MAPBOX_ACCESS_TOKEN';

  const MapboxStyle._();
}
