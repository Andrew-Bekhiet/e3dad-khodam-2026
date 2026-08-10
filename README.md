# e3dad_khodam_2026

An interactive Arabic map of the cities of St Paul's journeys, drawn over a
pixel-art Mapbox basemap.

## Running

### 1. Access token (all platforms)

The basemap needs a Mapbox **public** token (`pk.…`). It is never committed —
pass it at build time:

```sh
flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token_here
```

Same flag for `flutter build`. Without it the app runs but paints a "missing
access token" notice where the map would be, rather than a blank screen.

### 2. SDK download token (android/ios only)

The Mapbox Maps SDK is served from Mapbox's private Maven/CocoaPods registry,
which needs a **secret** token (`sk.…`) with the `DOWNLOADS:READ` scope —
create one at <https://console.mapbox.com/account/access-tokens/>. This is a
one-time machine setup, not part of the repo:

```sh
# Android
echo "SDK_REGISTRY_TOKEN=sk.your_secret_token" >> ~/.gradle/gradle.properties

# iOS
printf 'machine api.mapbox.com\n  login mapbox\n  password sk.your_secret_token\n' >> ~/.netrc
chmod 600 ~/.netrc
```

Web needs none of this: Mapbox GL JS is loaded from a `<script>` tag in
`web/index.html`.

## How the map is built

| Layer | Where |
|---|---|
| Pixel-art recipe (palette, sprites, style rewriting) | [lib/src/map_engine/pixel_style/](lib/src/map_engine/pixel_style/) — pure Dart, shared |
| Camera and marker projection | [lib/src/map_engine/camera/](lib/src/map_engine/camera/) |
| Renderer, android/ios | [mapbox_map_surface_native.dart](lib/src/map_engine/mapbox/mapbox_map_surface_native.dart) — Mapbox Maps SDK |
| Renderer, web | [mapbox_map_surface_web.dart](lib/src/map_engine/mapbox/mapbox_map_surface_web.dart) — Mapbox GL JS |

The basemap look is defined once, in Dart, and applied to both renderers as a
single style document; see §10 of the design spec.

## Docs

- [`docs/design.md`](docs/design.md) — normative design spec (coordinates,
  marker visuals, palette, typography, pixel basemap).
