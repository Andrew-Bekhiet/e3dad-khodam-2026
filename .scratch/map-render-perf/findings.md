# Map render: memory growth and code-quality findings

Audit of `lib/` against Dart/Flutter best practices, 2026-08-15, at `fc75953`.
Working tree clean; everything below is pre-existing on `main`.

## Summary

There is no leaked `AnimationController`, `Ticker`, `Timer`, or `StreamSubscription` —
every disposable in the codebase is disposed. The memory growth is not a classic
leak; it is **unbounded fire-and-forget async work issued at 60 fps**, whose pending
futures retain their captured payloads faster than the platform channel drains them.

## 1. The memory finding

### Mechanism

`GameMapView.build` wraps the whole surface in an `AnimatedBuilder` on the sweep
clock (`game_map_view.dart:53`). Every frame of a sweep it constructs a brand-new
`MapSurfaceSpec` with brand-new `markers`, `trails`, and `tokens` lists.

`MapSurfaceStateMixin.didUpdateWidget` then decides what to push
(`map_surface_state_mixin.dart:36-47`):

```dart
if (spec.markers != previous.markers) { pushMarkers(spec.markers); }
if (spec.trails  != previous.trails)  { pushTrails(spec.trails); }
if (spec.tokens  != previous.tokens)  { pushTokens(spec.tokens); }
```

`spec.markers` is a `List<MapMarkerSpec>`. **Dart's `List` does not override `==`**,
so two distinct list instances are always `!=` regardless of their contents. All
three branches therefore fire on **every single frame**.

This is a sharp bug rather than a design choice: `MapSurfaceSpec` *is* `Equatable`,
and Equatable compares iterable `props` with deep equality — so `spec == previous`
would have been correct. The mixin bypasses the deep equality the types already
provide by reaching past the spec into its raw `List` fields.

### Why it grows rather than merely churns

`pushMarkers`/`pushTokens` are `void` in the mixin but `async` in both surfaces, so
each call is **fire-and-forget with no in-flight guard**
(`mapbox_map_surface_native.dart:264-310`, `mapbox_map_surface_web.dart:300-327`).

Per frame, the native surface issues:

- one `map.style.hasStyleImage(...)` platform round-trip **per marker style**
  (`:270`) and **per token style** (`:295`) — the result is discarded and
  recomputed next frame, though sprite registration is idempotent and the style
  set is tiny and known up front;
- three `jsonEncode` + `setStyleSourceProperty` calls (`:314-323`).

A sweep is 700 + 1400 + 900 ms = **3 s** (`game_journey_cubit.dart:48-59`). At
60 fps that is ~180 frames × (6-8 channel round-trips + 3 `jsonEncode`) ≈
**400-480 platform-channel calls per second**, none awaited, none cancelled.

The payload grows as the game progresses. `_routeOf` prepends
`CourierRoute.beforeLastLeg(trail.path)` — the entire accumulated route so far
(`game_map_view.dart:118`) — and `route_geometry.dart` holds 991 real coordinates.
By the late levels each frame's trail JSON is tens of KB, allocated fresh 60×/s and
**retained by the pending future until the channel drains it**. When the channel
drains slower than 60/s, the backlog accumulates for the whole sweep and across all
14 levels. That is the growth being observed.

### Fixes, highest leverage first

1. **Cache sprite registration.** Replace the per-frame `hasStyleImage` round-trips
   with a local `Set<String> _registeredImages` in each surface state. Removes
   ~all per-frame channel traffic on the sprite path. Cheapest fix, biggest win.
2. **Guard overlapping pushes.** Keep an in-flight flag per source; drop or coalesce
   a push while one is outstanding. Bounds the queue no matter the frame rate.
3. **Compare with the deep equality the types already have.** In the mixin, gate on
   element-wise equality (`const DeepCollectionEquality().equals(...)`, or compare
   the specs) instead of raw `List` identity.
4. **Take markers off the animation clock.** Markers are recomputed every frame
   (`_markersFor`, `:183`) though only `labelClearance` can move during a walk.
   Hoist marker construction outside the `AnimatedBuilder`.
5. **Push geometry on movement, not on frames.** Emit a trail/token update only when
   the walked position has advanced past an epsilon, or throttle to ~20-30 Hz. The
   couriers walk slowly; 60 Hz geometry uploads buy nothing visible.

Note (4) and (5) are the design fix; (1) and (2) are the safety net that keeps the
queue bounded even if a future change reintroduces per-frame pushes.

### Secondary

`_flySweep` has no cancellation on either surface
(`mapbox_map_surface_native.dart:344`, `mapbox_map_surface_web.dart:357`). Stepping
faster than a sweep completes starts overlapping `Future.delayed` chains that each
still fire their inward leg. `_step` guards the *cubit* against this
(`game_journey_page.dart:200`) but nothing guards the surface, and `goToStop` from a
marker tap bypasses the guard entirely.

## 2. Code quality

Baseline from `dart analyze --plugins --fatal-infos`: **34 issues**.

### Blocking

- **`lib/firebase_options.dart` is untracked, unreferenced, and does not compile** —
  6 hard `error`s (`firebase_core` is not in `pubspec.yaml`). It is not imported
  anywhere in `lib/` or `test/`. It appears to be a stray generated file. Deleting it
  takes the analyzer from 6 errors to 0.
- **5 tests fail on a clean `main`.** `test/presentation/game_journey_cubit_test.dart`
  (4) and `test/map_engine/pixel_style_test.dart` (1). The cubit failures are stale
  expectations: the tests assert 2 couriers, the code now produces 3 (grandma was
  added). These need updating to match, or the tests are not a gate at all.

### Against the patterns skill

- **`avoid_non_null_assertion` (§1 Null safety)** — `state.level!`
  (`game_journey_page.dart:92`), `game_journey_cubit.dart:388-389`,
  `destination_card.dart:171`. All are the "checked a flag, then bang the field"
  shape, which pattern matching removes: destructure the state once into a local
  non-null binding instead of testing `showsCard` and banging `level`.
- **`avoid_returning_widgets` (§4 Extract to classes, not methods)** —
  `character_portrait.dart:57`.
- **`cyclomatic_complexity` (§4)** — `_onKeyEvent` (`game_journey_page.dart:158`).
  A `const Map<LogicalKeyboardKey, _Intent>` collapses the switch.
- **`number_of_parameters` > 7 (§2 Immutable state)** — `game_level.dart:71`,
  `map_surface_spec.dart:63`, `game_journey_state.dart:189`,
  `destination_card.dart:50`. Candidates for grouped value objects.
- **`avoid_duplicate_code`** — the `_hex` colour helper is duplicated between
  `marker_layer.dart:163` and `trail_layer.dart:96`.
- **`prefer_match_file_name`** — `game_step.dart`,
  `test/presentation/game_journey_cubit_test.dart`.
- **`double_literal_format`** — `sweep_overlay.dart:72`.
- **`prefer_first`** — `tool/generate_route_geometry.dart:110`.

## Verification

- `dart analyze --plugins --fatal-infos` from the repo root (per `CLAUDE.md`) — 34 issues.
- `flutter test` — 101 passing, 5 failing, all pre-existing at `fc75953`.
