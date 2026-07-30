# Design Spec — خريطة رحلات بولس الرسول

Arabic-only, RTL, single-purpose map app over `flutter_map` + a custom Mapbox Studio basemap
style (`anderwbekhiet/cms775jc8003x01sd2mmyeczh`), served as raster tiles.
This document is normative for implementation: use the numbers given, don't re-derive them.

---

## 1. Cross anchor coordinates (Level 0)

### Projection math

Web Mercator y (unitless, Earth-radius-normalized): `y = ln(tan(π/4 + lat/2))`, lat in radians.
x is linear in longitude: `x = lng` (radians). x and y share the same scale factor (Earth
radius × zoom), so **equal Mercator-y offsets and equal longitude-radian offsets produce equal
on-screen pixel distances** at any zoom — the only invariant needed to make the four arms equal
length on screen.

Target: a true equal-arm ("Greek cross") layout — top/bottom symmetric around a center latitude
in **y-space**; left/right symmetric around the same center in **longitude** (already linear,
trivially symmetric in degrees).

Chosen center: `lat_c = 37.5°N, lng_c = 18.0°E` (tighter mid-Mediterranean point — revised down
from an earlier Δlng=12° draft that pushed بلاد into the Libyan Sahara and جزر over mainland
Anatolia instead of open sea/islands). Chosen horizontal half-arm `Δlng = 8.0°` →
`h = radians(8.0) = 0.139626` Mercator-y units. Reusing the same h for the vertical half-arm
keeps the cross equal-armed:

```
y_c        = ln(tan(45° + 37.5°/2))              = 0.706951
y_top      = y_c + h                              = 0.846578  →  lat = 43.57°N
y_bottom   = y_c − h                               = 0.567325  →  lat = 30.89°N
lng_left   = lng_c − 8.0                           = 10.0°E
lng_right  = lng_c + 8.0                           = 26.0°E
```

(Note the asymmetric degree-spans: +6.07° up vs −6.61° down for the *same* screen distance —
the latitude-stretch effect. Independently re-derived from scratch with three separate methods
— direct `ln(tan(π/4+φ/2))`, the degree-input form, and the equivalent `asinh(tan φ)` identity,
all agreeing to 6 decimal places — `y_c = 0.706951`, giving `lat_top = 43.57°N` and
`lat_bottom = 30.89°N`. This differs slightly, by ~0.13–0.15°, from a `y_c ≈ 0.709211` figure
floated during review that would give 43.70°N/30.98°N; the arithmetic here is the verified one
and is used below. The difference doesn't change which region each marker lands in.)

### Final coordinates

| Node (Arabic) | Kind | lat | lng | Semantic placement |
|---|---|---|---|---|
| قارات | category | **43.57** | **18.00** | North, over Bosnia/the Balkans — reads as "continents/north" |
| بلاد | category | **30.89** | **18.00** | South, over the Libyan coast at the Gulf of Sidra — basin edge, not deep desert |
| بحار | category | **37.50** | **10.00** | West, open water between Sardinia and Tunisia |
| جزر | category | **37.50** | **26.00** | East, in the Aegean beside Ikaria/Samos — actual islands |

### Root camera bounds

```
SW = (lat: 30.89, lng: 10.00)
NE = (lat: 43.57, lng: 26.00)
```

`CameraFit.bounds(bounds: LatLngBounds(SW, NE), padding: EdgeInsets.only(top: 100, left: 32, right: 32, bottom: 56))`
— top padding is larger to clear the app bar + status bar + breadcrumb region; the extra
top/bottom asymmetry keeps the visual center of the cross vertically centered in the *visible*
map viewport (below the app bar), not in the raw bounds box.

---

## 2. Marker visual spec

All markers are circular unless noted. Sizes are the *painted* diameter; tap target is the
actual `GestureDetector`/`InkResponse` hit area, which pads outward to the 48dp Material minimum
where the visual is smaller.

| Kind | Visual size | Tap target | Shape | Fill | Icon | Elevation |
|---|---|---|---|---|---|---|
| category | 56dp | 56dp | circle | solid, kind color | 28dp Material icon, white | shadow blur 8, offset (0,2), 30% opacity black |
| continent | 44dp | 48dp | circle | solid, kind color | none (plain disc) | shadow blur 6, offset (0,2), 22% opacity |
| country | 44dp | 48dp | rounded square, 10dp corner radius | solid, kind color | none | shadow blur 6, offset (0,2), 22% opacity |
| sea | 40dp | 48dp | teardrop/diamond (`Icons.waves` inset) | solid, kind color | 18dp `Icons.waves`, white | shadow blur 5, offset (0,1), 18% opacity |
| island | 40dp | 48dp | circle | solid, kind color | 18dp `Icons.terrain`, white | shadow blur 5, offset (0,1), 18% opacity |
| city | 18dp | **none** (see below) | filled dot, no icon | solid, kind color | — | flat, no shadow |

Category icons (Material): قارات → `Icons.public`, بلاد → `Icons.flag`, بحار → `Icons.waves`,
جزر → `Icons.beach_access`. Each rendered white, 28dp, centered.

City (leaf) markers: per decision #2, tapping a leaf does nothing. Wrap its hit-testing in
`IgnorePointer` so it never intercepts pan/zoom gestures underneath, and give it no ripple/tap
feedback — a non-interactive marker shouldn't visually invite a tap.

**Label placement & legibility.** Label sits directly below the marker, 4dp gap, centered, in a
**white pill background** (`0xFFFFFFFF` @ 90% opacity, 8dp/2dp padding, 6dp radius, 1dp shadow
blur 2 @ 15%). Justification: text halos/outlines render inconsistently with Arabic script
(diacritics, joining forms make stroked outlines look muddy); a solid pill is the same technique
Google/Apple Maps use and stays legible over any tile color without per-tile-color logic. Pill
color is fixed white regardless of app theme brightness (see §3) since tiles are always light.
City labels skip the pill — dark text directly on the tile inside a **white halo** (5 white
`Shadow`s: blur 3 at the four ±1.5dp diagonals plus one centered) — still the quietest element
so the busy leaf level doesn't compete with the still-visible parent marker, but sized and
haloed to stay readable over the basemap's own labels and coastlines. A halo, not a stroked
outline: the Arabic-script objection above is about strokes, which a blurred glow avoids.

Label text color: `#1A1A1A` on the pill (all non-city kinds); `#14243A` in the halo for city.

---

## 3. Colour palette

Material 3 seed: **`#1B6CA8`** (Mediterranean blue) — `ColorScheme.fromSeed(seedColor: Color(0xFF1B6CA8))`.

**Design decision:** marker fill colors are fixed and do NOT change between light/dark app
theme — the Mapbox basemap style is always light-colored (no dark style in scope), so markers keep
one fixed, tile-legible palette. Only the surrounding chrome (app bar, breadcrumb, sheet,
scaffold background) follows the M3 `ColorScheme` and switches with brightness. This is a
deliberate deviation from a literal "colors per kind in light and dark" reading — flagged here
as a judgement call, not an oversight.

### Marker fill colors (fixed, both themes)

| Kind | Hex | Notes |
|---|---|---|
| category | `#123C69` | deep navy — heaviest, most saturated/dark, reads as "primary" |
| continent | `#2E7D32` | forest green |
| country | `#C77B00` | amber/ochre |
| sea | `#0288D1` | azure — distinct from category navy |
| island | `#C2703D` | terracotta/sand |
| city | `#455A64` | blue-grey, small flat dot |

Icon/stroke on all filled markers: white `#FFFFFF`. Category markers additionally get a 2dp
white ring (`Border.all(color: Colors.white, width: 2)`) to separate them from the tile
underneath and visually rank them above level-1/2 markers.

### UI chrome ColorScheme (M3, generated from seed)

| Role | Light | Dark |
|---|---|---|
| primary | `#0B61A4` | `#9ECAFF` |
| onPrimary | `#FFFFFF` | `#00325A` |
| surface | `#F8F9FF` | `#101418` |
| onSurface | `#181C20` | `#E1E2E8` |
| appBarBackground | `primary` (`#0B61A4`) | `surface` (`#101418`) with `onSurface` text |
| breadcrumb text | `onPrimary` (`#FFFFFF`) | `onSurface` (`#E1E2E8`) |

Use `ColorScheme.fromSeed(seedColor: Color(0xFF1B6CA8), brightness: Brightness.light/dark)` for
everything not listed explicitly above — the table only pins the roles that are load-bearing for
this app's three chrome surfaces (app bar, breadcrumb, sheet).

---

## 4. Typography (Cairo, `assets/fonts/Cairo-VariableFont.ttf`)

| Element | Size | Weight |
|---|---|---|
| category marker label | 15sp | 700 (Bold) |
| level-1 marker label (continent/country/sea/island) | 13sp | 600 (SemiBold) |
| city (leaf) marker label | 14sp | 700 (Bold) |
| app bar title (root, static title) | 20sp | 700 (Bold) |
| breadcrumb (app bar title when depth > 0) | 16sp | 600 (SemiBold) |
| bottom sheet title | 16sp | 700 (Bold) |
| bottom sheet list item | 15sp | 500 (Medium) |
| bottom sheet group header | 13sp | 600 (SemiBold), `onSurfaceVariant` color |

Register `FontFamily: 'Cairo'` in `pubspec.yaml`; set as `ThemeData.fontFamily` app-wide, except
the basemap attribution string (§8), which stays in the system/Latin font.

---

## 5. Camera animation

flutter_map has no built-in animated `move` — implement via a `TickerProvider` +
`Tween<LatLngBounds>`/`Tween<double>` on zoom+center (`flutter_map_animations` pattern), not
`MapController.move` called directly (which jumps).

- **Drill down** (tap a node → fit children bounds): duration **500ms**, `Curves.easeInOutCubic`.
- **Back** (up one level → fit parent's sibling-set bounds): duration **400ms**,
  `Curves.easeInOutCubic` (same curve family for consistency; shorter because it's a more
  "familiar" direction of travel for the user).
- **Fit padding**: `EdgeInsets.only(top: 100, left: 32, right: 32, bottom: 56)` for every
  drill/back fit (not just root) — constant across levels so the app bar/breadcrumb clearance is
  always respected.

**Marker enter/exit**, sequenced relative to the camera move (total perceived transition should
stay under ~700ms so it reads as "quick"):

1. Outgoing siblings: fade 1→0 + scale 1.0→0.8, **150ms**, `Curves.easeIn`, starting immediately
   on tap (before the camera starts moving) so the screen "clears" before it pans.
2. Camera move: starts ~50ms after step 1 begins (small overlap, not a hard sequential wait),
   500ms/400ms per direction as above.
3. Incoming children: fade 0→1 + scale 0.6→1.0, **250ms**, `Curves.easeOut`, starting once the
   camera move is ~60% complete (roughly 300ms into a 500ms drill-down) so markers "arrive" as
   the pan settles rather than popping in mid-flight. Stagger each child by **40ms** (max 3-4
   children per level → ≤160ms total stagger spread).

Keep it tasteful: no bounce/elastic curves, no rotation, no overshoot — this is a Bible-study
reference tool, not a game.

---

## 6. Navigation chrome

**Decision: AppBar-based, not a floating breadcrumb bar.** Simpler, platform-idiomatic, fewer
custom RTL edge cases than a floating pill widget.

- **Depth 0 (root)**: `AppBar.title` = static app title (§9). No leading widget.
- **Depth > 0**: `AppBar.title` = breadcrumb string built by joining the ancestor chain with
  `" / "` in normal logical (Arabic reading) order, e.g. `"بلاد / آسيا الصغرى"`. Arabic characters
  are strong-RTL, so the Unicode bidi algorithm right-aligns and orders this correctly under
  `Directionality.rtl` with no manual reversal — build it as plain concatenation.
  - Separator: plain `" / "` (slash), not a directional chevron (`›`/`‹`) — a slash carries no
    left/right semantic, avoiding "which way does the arrow point in RTL" ambiguity.
  - `AppBar.leading`: `IconButton(icon: Icon(Icons.arrow_back, matchTextDirection: true))` for
    "go up one level". `matchTextDirection: true` is the documented Flutter `Icon` property that
    mirrors the icon when ambient `Directionality` is RTL — makes it point right, no manual
    rotation/Transform needed.

Both title states use `AnimatedSwitcher` (200ms, fade) when swapping between static title and
breadcrumb, and between breadcrumb depths, so the app bar doesn't hard-cut.

---

## 7. RTL specifics

- App-wide: `MaterialApp(locale: Locale('ar'), supportedLocales: [Locale('ar')])` plus standard
  `GlobalMaterialLocalizations`/`GlobalWidgetsLocalizations`/`GlobalCupertinoLocalizations`
  delegates. Force `ar` explicitly rather than relying on device locale.
- **Must mirror**: the back icon (`matchTextDirection: true`, §6); standard widget layout
  (AppBar `actions` end-alignment, `Row`/`ListTile` leading/trailing) — automatic under
  `Directionality.rtl`, no extra code needed.
- **Must NOT mirror, ever**:
  - The `FlutterMap` widget and all tile/marker rendering — geographic lat/lng math is
    orientation-agnostic. No `Transform.flip` on the map, no ancestor directionality-aware
    mirroring transform between `Directionality` and `FlutterMap`.
  - Marker shapes: circles/discs are symmetric by construction. Any future directional glyph
    must use `matchTextDirection: true` or, better, be avoided on the map layer.
  - Basemap attribution (§8) — force `textDirection: TextDirection.ltr` explicitly; it's a legal
    English string and must not be bidi-reordered despite its RTL ambient container.

---

## 8. Basemap attribution

Required by Mapbox's terms of service (which also cover the OpenStreetMap data behind the
style). Use flutter_map's built-in `RichAttributionWidget` rather than hand-rolling it:

- **Text**: two entries, `"© Mapbox"` and `"© OpenStreetMap"`.
- **Placement**: bottom-right corner of the map viewport, 8dp margin — the flutter_map default
  and standard slippy-map convention; kept regardless of app RTL since it's a map-layer element,
  not app chrome, so it doesn't follow reading direction.
- **Style**: 10sp/400 (Regular), color `#333333`, **system/default font — not Cairo** (Latin
  legal string). White pill background, 60–70% opacity, 4dp/2dp padding, 4dp radius — small,
  unobtrusive, still legible over dark water tiles.
- Not tappable for now: linking out (`TextSourceAttribution.onTap`) needs a URL launcher, and
  no such dependency is in scope. The text alone satisfies the required credit; wire
  `https://www.mapbox.com/about/maps/` and `https://www.openstreetmap.org/copyright` when a
  launcher is added.

---

## 9. App bar

- **Title (root/static)**: `"خريطة رحلات بولس الرسول"` — matches the app's framing ("St Paul's
  journeys' cities") and is already used in `web/index.html` and `web/manifest.json`. 20sp/700
  per §4.
- **Background**: `ColorScheme.primary` (light `#0B61A4`) / `ColorScheme.surface` (dark
  `#101418`) per §3.
- **Trailing action (flag-gated)**: only rendered when `AppFeatures.showNonGeographicGroups ==
  true`. `IconButton(icon: Icon(Icons.people_outline))`, tooltip `"أشخاص وموضوعات أخرى"`. Opens
  the bottom sheet below. Standard `AppBar.actions:` list — Flutter auto-flips actions to the
  RTL "end" side, no manual placement logic needed.

### Bottom sheet (non-geographic entries) — minimal

`showModalBottomSheet`, rounded top corners 20dp. Contents, top to bottom:

1. Drag handle: 32×4dp grey bar, centered, 12dp top margin.
2. Title `"أشخاص وموضوعات أخرى"`, 16dp padding, per §4.
3. Group "أشخاص" (icon `Icons.person`, 15sp/500 per row): تيموثاوس، تيطس، فليمون.
4. `Divider()`.
5. Group "العبرانيين" (icon `Icons.groups`): اليهود.

Rows are flat `ListTile`s with no subtitle, no trailing chevron, no navigation — tapping does
nothing (these entries have no children and no map presence by design). Dismiss via standard
drag-down or scrim tap.

---

## Appendix: real-world coordinates for levels 1–2

Not explicitly requested but needed downstream for "true coordinates" (decision #2) — included so
the implementing agent doesn't have to invent these.

| Node | lat | lng |
|---|---|---|
| أسيا (continent) | 39.0 | 35.0 |
| أفريقيا (continent) | 32.0 | 10.0 |
| أوروبا (continent) | 42.0 | 15.0 |
| البحر المتوسط (sea) | 35.0 | 18.0 |
| بحر إيجه (sea) | 38.5 | 25.0 |
| البحر الأدرياتيكي (sea) | 43.0 | 15.5 |
| كريت (island) | 35.24 | 24.81 |
| قبرص (island) | 35.13 | 33.43 |
| مالطة (island) | 35.94 | 14.38 |
| آسيا الصغرى (country) | 38.5 | 32.0 |
| اليونان (country) | 39.5 | 22.0 |
| إيطاليا (country) | 42.5 | 12.5 |
| غلاطية (city) | 39.5 | 32.9 |
| أفسس (city) | 37.94 | 27.34 |
| كولوسي (city) | 37.78 | 29.38 |
| فيلبي (city) | 41.01 | 24.29 |
| كورنثوس (city) | 37.91 | 22.88 |
| تسالونيكي (city) | 40.64 | 22.94 |
| رومية (city) | 41.90 | 12.50 |
