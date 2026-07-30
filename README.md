# e3dad_khodam_2026

An interactive Arabic map of the cities of St Paul's journeys.

## Running

The basemap is a custom Mapbox Studio style
(`anderwbekhiet/cms775jc8003x01sd2mmyeczh`) fetched as raster tiles, so a
Mapbox **public** access token (`pk....`) is required at build time. The
token is never committed — pass it as a dart-define:

```sh
flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token_here
```

Same flag for `flutter build`. Without it the app runs but paints a
"missing access token" notice where the basemap would be, instead of an
empty map.

## Docs

- [`docs/design.md`](docs/design.md) — normative design spec (coordinates,
  marker visuals, palette, typography, attribution).
