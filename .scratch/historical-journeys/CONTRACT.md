# Historical Journeys — shared contract

One artifact every delegate on this feature reads. Do not edit it; if something here is wrong,
say so in your report and stop.

## What is being built

A second experience over the same pixel Mapbox basemap: **Simplified Historical Journeys** — a
pure animation of trails, stops and flashing cities. Three journeys: Paul's 2nd, his 3rd, and the
voyage to Rome. No dialogue, no verses, no destination card, no sounds, no couriers, no tokens.
Trail + markers + camera only.

The existing Post Office Game and Cross Map stay exactly as they are. New behaviour arrives as new
classes beside them; refactoring shared code so both can exist is allowed and expected, but no
change may alter what the game or the cross map does today.

## House rules (non-negotiable)

- Arabic, RTL UI strings. Identifiers and technical terms in English.
- Write **few or no comments**. Only rationale the code cannot state itself — why a value is what
  it is, or why an obvious approach was rejected. Never narrate what the code does.
- Files stay under 350 lines.
- Widgets are classes, never methods returning a widget. A widget under ~100 lines with one call
  site is inlined at that call site rather than extracted.
- Text styles from `TextTheme.of(context)`, colours from the theme or the existing palette
  classes. No inline `TextStyle`, no hard-coded colours outside a palette/style class.
- `final class` + `Equatable` for value types, matching the surrounding code exactly.
- Fix lints, never suppress them. An `// ignore:` needs a reason line above it.
- Verify with `dart analyze --plugins` from the project root, **no path arguments** (path args and
  `flutter analyze` silently skip the solid_lints plugin diagnostics and give a false pass), plus
  `flutter test`.
- Stay inside the file fences your task gives you. Touching a file outside them is a failure, not
  an initiative.

## Domain shape

A journey is an origin, then an ordered list of rests. A **rest** is a place the animation stops
at; the cities on the way to it are **via** points the trail passes through without stopping. A
rest may name a **beacon**: another city that flashes like a bulb while the animation rests there,
meaning a letter was sent to it.

```dart
final class HistoricalJourney {   // lib/src/domain/history/historical_journey.dart
  final String id;
  final String title;             // Arabic
  final JourneyStop origin;
  final List<JourneyRest> rests;
}

final class JourneyRest {
  final JourneyStop stop;
  final List<JourneyStop> via;    // passed through, never rested at
  final JourneyStop? beacon;      // flashes while resting at `stop`
}
```

`JourneyStop` is the existing `lib/src/domain/game/journey_stop.dart` — reused, not copied.

## The three journeys

Every coordinate below is authoritative. Do not look any of them up, and do not invent one.

### Gazetteer additions (`StopPositions`, `lib/src/data/stop_positions.dart`)

Append these; leave every existing entry untouched.

| id | Arabic | lat | lon |
|---|---|---|---|
| antioch | أنطاكية | 36.2021 | 36.1603 |
| tarsus | طرسوس | 36.9177 | 34.8925 |
| derbe | دربة | 37.3506 | 33.2833 |
| lystra | لسترة | 37.5786 | 32.4531 |
| iconium | إيقونية | 37.8746 | 32.4932 |
| pisidianAntioch | أنطاكية بيسيدية | 38.305 | 31.1897 |
| troas | ترواس | 39.7503 | 26.1594 |
| samothrace | ساموثراكي | 40.4667 | 25.5333 |
| neapolis | نيابوليس | 40.9375 | 24.4128 |
| amphipolis | أمفيبوليس | 40.8225 | 23.8447 |
| apollonia | أبولونيا | 40.6167 | 23.45 |
| berea | بيرية | 40.5236 | 22.2028 |
| athens | أثينا | 37.9838 | 23.7275 |
| miletus | ميليتس | 37.5306 | 27.2775 |
| caesarea | قيصرية | 32.5019 | 34.8917 |
| sidon | صيدا | 33.5571 | 35.3729 |
| myra | ميرا | 36.2586 | 29.985 |
| cnidus | كنيدس | 36.6853 | 27.3742 |
| fairHavens | الموانئ الحسنة | 34.9333 | 24.8 |
| malta | مليطة | 35.95 | 14.4 |
| syracuse | سيراكوسا | 37.0755 | 15.2866 |
| rhegium | ريغيون | 38.1113 | 15.6473 |
| puteoli | بوطيولي | 40.8236 | 14.121 |

`philippi` (41.0131, 24.2864), `thessalonica`, `corinth`, `ephesus`, `rome`, `crete` and
`jerusalem` are already in `StopPositions` — reuse them.

### 2nd journey — `secondJourney`, title `رحلة بولس الرسول الثانية`

Origin: أنطاكية. One rest, كورنثوس, with beacon تسالونيكي.

via, in order: طرسوس، دربة، لسترة، إيقونية، أنطاكية بيسيدية، ترواس، ساموثراكي، نيابوليس، فيلبي،
أمفيبوليس، أبولونيا، تسالونيكي، بيرية، أثينا.

The journey ends at كورنثوس. No return leg.

### 3rd journey — `thirdJourney`, title `رحلة بولس الرسول الثالثة`

Origin: أنطاكية. Two rests:

1. أفسس — via طرسوس، دربة، لسترة، إيقونية، أنطاكية بيسيدية. No beacon.
2. فيلبي — via ترواس، نيابوليس. Beacon: **رومية**.

### Journey to Rome — `romeJourney`, title `رحلة بولس الرسول إلى رومية`

Origin: قيصرية. One rest, رومية, no beacon, and no intermediate rests — one continuous voyage.

via, in order: صيدا، ميرا، كنيدس، الموانئ الحسنة (Crete)، مليطة، سيراكوسا، ريغيون، بوطيولي.

## Leg kinds

`LegKind.land` where the stretch was walked, `LegKind.sea` where it was sailed. Land legs get
their geometry from the Mapbox Directions API through the existing generator; sea legs are charted
by hand in the leg definition and smoothed through `TrailCurve`.

- **Land**: أنطاكية→طرسوس→دربة→لسترة→إيقونية→أنطاكية بيسيدية→ترواس (2nd/3rd journeys' opening),
  نيابوليس→فيلبي→أمفيبوليس→أبولونيا→تسالونيكي→بيرية, أثينا→كورنثوس, أنطاكية بيسيدية→أفسس,
  نيابوليس→فيلبي (3rd), بوطيولي→رومية (Via Appia).
- **Sea**: ترواس→ساموثراكي→نيابوليس, بيرية→أثينا, أفسس→ترواس, and every leg of the Rome voyage
  from قيصرية to بوطيولي.

A sea leg's `chart` keeps the line on water: round the headlands, between the islands, the way
first-century ships sailed. Follow the reference maps' shape.

## Camera

Both the current rest and its beacon must be on screen at once. So a rest with a beacon frames
`GeoBounds.containing([rest, beacon])`, padded; a rest without one centres on the rest.

Motion reuses the existing `SweepCameraTarget`: pull out to the whole stretch, hold while the
trail draws itself, then come in to the arrival frame. Backward moves land directly, no sweep.

## Advancing

Manual, exactly like the game: tap the map, arrow keys, space, enter. Forward walks to the next
rest; backward steps back one.

## Switching

Five buttons pinned to the **physical** top-left of the stage: الشرح المبدئي (the Cross Map, as it
exists today), الرحلة الثانية, الرحلة الثالثة, الرحلة إلى رومية, لعبة post office (the existing
game). Physical left, not directional — the user asked for top-left on screen.

## Files: who owns what

Each task names its own fences. Nothing outside them is yours.

---

# Presentation design (wave 2)

## Steps

A journey is a flat list of steps, so forward and backward are always one move — the same principle
`GameScript` is built on. Read `lib/src/presentation/cubit/game_script.dart` and
`lib/src/presentation/cubit/game_step.dart` before writing this.

```
JourneyOpeningStep            // parked at the origin, whole journey framed
RestStep(restIndex)           // arrived at rests[restIndex]
```

So a journey of one rest has two steps; the 3rd journey has three.

## State

`HistoricalJourneyState` carries what the map draws and where the camera looks — the same division
`GameJourneyState` makes, minus everything about cards, beats and levels:

- `step`, `stepIndex`, `stepCount`
- `origin`
- `visitedRests` — rests already arrived at, excluding the current one
- `currentStop` — the origin on the opening step, otherwise `rests[i].stop`
- `beacon` — the flashing city, or null
- `revealedVia` — every via point from the origin through the current rest, in order; the cities
  the trail has actually passed. Nothing beyond the current rest is drawn.
- `trace` — the polyline behind the animation and the stretch being drawn now
- `camera`, `cameraAnimationDuration`

## Trace

`JourneyTrace` is to the historical journeys what `CourierParty` is to the game: it holds the line
already drawn and the stretch being drawn now, and answers `traceAt(progress)` on every frame of
the animation. Read `lib/src/presentation/cubit/courier_party.dart` — including its note on why the
heavy geometry is computed once per instance rather than once per frame, which applies here
verbatim — and reuse `WalkedTrail` and `TrailWalk.along` rather than restating them.

It joins its geometry with `RouteLine` over a `HistoricalLegAtlas`, the historical counterpart of
`GameLegAtlas`.

The stretch being drawn now is the whole run of legs from the previous rest through its via points
to the current rest — one continuous movement, because the via cities are passed, not stopped at.

## Camera — `HistoricalJourneyCamera`

Model it on `lib/src/presentation/cubit/game_journey_camera.dart`; it is a separate policy class
for the same reason ADR 0006 gives for the game's.

- `JourneyOpeningStep` → `FitBoundsCameraTarget` over every point the journey names (origin, all
  via, all rests, all beacons), padded.
- Arriving at a rest **with** a beacon → `FitBoundsCameraTarget(GeoBounds.containing([rest,
  beacon]).padded(...))`. Both must be comfortably on screen; that is the whole point of the
  beacon, and a frame that clips it is a bug.
- Arriving at a rest **without** one → `CenterZoomCameraTarget` at a zoom that still reads as a
  map of the Mediterranean, not a street (the game's `arrivalZoom` of 10 is far too close here —
  around 6 is the right order).
- A forward move into a rest → `SweepCameraTarget`: out to the bounds of the stretch about to be
  drawn, hold while the trail draws itself, then in to the arrival frame above. The hold is
  materially longer than the game's 1000ms — these stretches are the length of the Aegean and the
  trail drawing itself IS the content.
- A backward move → the arrival frame directly, no sweep. Same rule as the game.

## Markers — `HistoryMapStyles`

Model on `lib/src/presentation/widgets/game/game_map_styles.dart`: a closed set of styles, because
one style id is one rasterised image.

- `origin` — where the journey set out from
- `rest` — a rest already arrived at
- `current` — the rest the journey is at now, the largest
- `waypoint` — a via city the trail has passed: a small dot with a small label
- `beaconBright` / `beaconDim` — the flashing city, two styles swapped on a clock

Labels come from the stop. Colours from `GamePalette` where they fit, extended there if they do
not — never inline.

## The flash

The beacon flashes like a bulb: the marker alternates between `beaconBright` and `beaconDim` on a
repeating clock, roughly two states a second. Drive it from a repeating `AnimationController` and
quantise to the two states, so the surface is handed a changed spec twice a second rather than
sixty times — the same reasoning `_walkSteps` in `game_map_view.dart` is built on. Read that file's
comment before writing this.

Nothing else on the historical map moves except the trail.

## What the historical map does NOT have

No tokens (`tokens: const []`), no couriers, no portraits, no destination card, no story overlay,
no narrator, no sounds, no level counter, no verses. If you are writing any of those, you have
misread the task.

## The stage and the five buttons

`MapStagePage` hosts all five scripts and owns the switcher. The scripts:

```
MapScript { crossMap, secondJourney, thirdJourney, romeJourney, postOfficeGame }
```

labelled الشرح المبدئي، الرحلة الثانية، الرحلة الثالثة، الرحلة إلى رومية، لعبة post office.

The buttons sit at the **physical** top-left of the stage body — `Positioned(top:, left:)`, not
`PositionedDirectional`. They must not collide with the app bar's actions, and they must stay
legible over the map (they sit on top of it).

Reusing one Mapbox map across the switch is worth real effort: switching script should update the
map's annotations, not tear down and rebuild the GL map. The way to get that is for the surface
widget to stay at one stable slot in the element tree across every script — same widget type, same
key, same parent chain — with only the `MapSurfaceSpec` handed to it changing. That means the stage
owns the single call to `MapSurfaceBuilder`, and each script contributes a spec plus its own
overlay chrome, rather than each script building its own surface as `GameMapView` and
`JourneyMapView` do today.

If that unification cannot be made to work without changing what the game or the cross map does,
stop and say so: falling back to separate routes for those two is explicitly allowed, and a broken
game is not.
