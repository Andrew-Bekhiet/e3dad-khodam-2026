# Spec — story presentation, narrator palette, sound, Ismailia opening, map sizing

Derived from the design interview of 2026-08-15/16. Supersedes `plan.md`.
Builds **on top of** the map-render + route-unification work currently uncommitted in
the working tree (`CourierParty` / `WalkedTrail` model, 26 analyzer issues,
114 tests passing / 1 pre-existing failure).

## Standing constraints

- **Enums over ints.** Where a value is a fixed set of named cases rather than a
  quantity, use an `enum` with exhaustive `switch` and no `default`; a sealed class
  where cases carry different data. Genuine counts and indices stay `int`.
- **Domain stays plugin-free.** `lib/src/domain/` must not import `audioplayers`, as
  it already must not import `mapbox_maps_flutter`.
- **Verification:** `dart analyze --plugins --fatal-infos` from the project root with
  no path arguments, plus `flutter test`. Path-scoped runs and `flutter analyze`
  silently skip the solid_lints plugin diagnostics.
- **Comments:** few, and only for non-obvious rationale.

---

## S1 — Guide speaks from the app bar

**Behaviour**

- The guide's portrait becomes a small permanent avatar in the `AppBar`.
- A guide beat opens either a **callout** whose tail points at that avatar, or the
  **full centred panel** (today's `GuideDialoguePanel`, which survives unchanged in
  layout).
- Which one is **explicit per beat**, never inferred:

  ```dart
  enum BeatEmphasis { callout, panel }
  ```

  `StoryBeat.guide(...)` defaults to `BeatEmphasis.callout`; a beat opts into
  `panel`. Rejected: a text-length threshold — Arabic character counts do not track
  rendered height (diacritics, ligatures, variable Cairo weight), rewording would
  silently flip presentation, and it repeats the `_standInFills[label.length % 5]`
  defect at `destination_card.dart:290`.
- **Modality is unchanged.** The scrim stays, the map stays dimmed and inert, and a
  tap anywhere still advances. `_pressesDuringSweep` and the operator's slideshow
  habit are untouched.
- **The narrator never uses the callout.** It always gets the cutscene card.

**Acceptance**

- A `callout` beat renders anchored to the app-bar avatar with a visible tail; a
  `panel` beat renders centred.
- Tapping anywhere advances in both cases.
- The narrator's presentation is unaffected by `BeatEmphasis`.
- A long `callout` beat scrolls inside the callout rather than overflowing.

---

## S2 — Narrator palette: illuminated manuscript

The near-black `narratorInk` (`#0B1220`) is the only element on screen belonging to
no material, which is what reads as alien. Replace it so the two voices separate by
**era** rather than light-vs-dark: the guide is a note passed to you now, the
narrator the chronicle it was copied from.

| `GamePalette` role | new value | replaces |
|---|---|---|
| narrator card fill | `#E4D2A8` vellum | `narratorInk #0B1220` |
| narrator body text | `#3B2412` sepia | `narratorText #F4E9D0` |
| narrator rules + border | `#A63A1E` ochre | `accent #C77B00` |
| narrator name + title | `#C08A2E` gilt | — |
| scrim | `#00000059` | `#66000000` |

The guide's parchment stays `#FFF6E0`. Separation now rests on the narrator's
existing centred portrait, italic body and horizontal rules — **the ochre rule and
border must stay strong**; softening them collapses the distinction.

**Acceptance**

- Guide and narrator remain unmistakable at a glance without reading the name.
- The map stays legible through the lighter scrim.
- Both read correctly in light and dark app themes (the palette is deliberately
  theme-independent, as `GamePalette`'s doc comment states).

---

## S3 — `GameSounds`

**Interface** (stays in `lib/src/domain/game/game_sounds.dart`, plugin-free):

```dart
abstract interface class GameSounds {
  void playLevelCleared();
  void playLevelReached();
  void playDeparture();
  void startWalking();
  void stopWalking();
}
```

`SilentGameSounds` remains the default implementation, so tests and CI need no audio
and every asset can arrive later without a call-site edit.

**Implementation** `AudioPlayersGameSounds` in `lib/src/data/audio/`:

- one `AudioPlayer` in `PlayerMode.lowLatency` with `ReleaseMode.loop` for the walk;
- a pool for one-shots, so a clearance sting can overlap the walk;
- `Future<void> dispose()`.

Name rejected: `GameSoundsManager`. "Manager" describes nothing, and the codebase's
idiom is interface + named implementation (`MapSurfaceBuilder`,
`JourneyMapRepository`, `SilentGameSounds`).

**Lifecycle — load-bearing.** `e3dad_khodam_app.dart:48` uses
`RepositoryProvider.value`, which does **not** dispose its value. It must become
`RepositoryProvider(create:, dispose:)` or the native audio handles leak.

**Call sites.** `startWalking`/`stopWalking` bind to the sweep clock that already
exists — `_sweep.forward(from: 0)` … `.then`, the `_sweep.stop()` path in
`_onCameraChanged`, and `dispose`. Every path that stops the clock must stop the loop.

Per the audioplayers docs, native looping has audible gaps on some format/platform
combinations — acceptable for intermittent SFX, noticeable on a continuous bed.
Choose the walk asset accordingly.

**Acceptance**

- With `SilentGameSounds` (the default) nothing plays and no test changes.
- The walk loop starts when a walk starts and is stopped on completion, on
  interruption, on restart mid-walk, and on dispose — no path leaves it running.
- Disposing the app releases the players.

**Assets required, none of which exist yet:** walk loop, level-cleared sting,
level-reached, departure.

---

## S4 — The Ismailia opening

**Behaviour**

- **Ismailia is a real `JourneyStop`**, first in the party's route.
  - `id: 'ismailia'`, label `الإسماعيلية`
  - position: **30.598139 N, 32.270056 E** (from 30°35'53.3"N 32°16'12.2"E)
- **The map opens already framed on Ismailia.** There is *no* initial camera flight
  to it — it is the starting view, not a destination.
- **The first leg draws no trail.**
- **The party does not walk it.** The camera flies Ismailia → Thessalonica; the
  tokens are simply at Thessalonica when it lands.
- The guide then explains what happened, as a beat (S1).

**The rule to state plainly in code:** *a leg with no geometry is neither walked nor
drawn.*

**Trap.** `CourierRoute._leg` currently falls back to a straight hop
(`[from.position, to.position]`) whenever geometry is absent. That single fallback
must now split into two distinct cases:

| case | meaning | behaviour |
|---|---|---|
| geometry *missing* | a chart nobody has drawn yet | blunt straight line (current behaviour) |
| geometry *declared none* | Ismailia → Thessalonica | skipped entirely: no walk, no line |

Without the split, Ismailia draws a straight line across Libya.

**Needs:** `StopPositions.ismailia`, `JourneyStops.ismailia`, an explicit
"no geometry" entry in `JourneyLegs`, and the suppression concept expressed in the
`CourierParty` / `WalkedTrail` model rather than special-cased at the render layer.

**Acceptance**

- First frame of the game shows Ismailia, with no flight into it.
- No line is ever drawn between Ismailia and Thessalonica.
- The party's tokens never appear between the two.
- Stepping backward to the opening returns to Ismailia framed, still with no trail.
- Every other leg is unaffected: geometry-backed legs still walk and draw.

---

## S5 — Bug: map renders tiny on the first frame, then fills

**Symptom.** The map appears very small for the first frame(s), then snaps to fill
the screen.

**Mechanism (web — confirmed by reading the code).** In
`mapbox_map_surface_web.dart`:

1. `build` wraps the view in a `LayoutBuilder` that calls `_scheduleResize(...)`,
   which posts a post-frame callback doing `_map?.resize()`.
2. `_map` is assigned on the **last line** of `_onPlatformViewCreated`, after two
   `await`s (`PixelStyleSource.load`, plus the async gap).
3. So when the first post-frame callback runs, **`_map` is still null** and the
   resize is a no-op.
4. Meanwhile `GlMap(...)` was constructed against a container that Flutter had not
   yet given its final size, so GL JS cached a small canvas.
5. Nothing corrects it until some *later* build triggers another `_scheduleResize`
   with `_map` non-null. In the game the animation clock and cubit cause frequent
   rebuilds, so it self-heals quickly — which is exactly "small at first, fills
   later". On `JourneyMapPage`, where rebuilds are rarer, it should persist longer.

**Fix (web).** Call `resize()` once immediately after `_map = map`, and make
`_scheduleResize` remember the last size it applied so a genuine size change still
resizes. Do not rely on an incidental rebuild to correct the initial layout.

**Hypothesis (native — unverified).** `_onStyleLoaded` calls
`_moveCamera(spec.camera, Duration.zero)`; a `FitBoundsCameraTarget` resolves through
`cameraForCoordinateBounds`, which needs the real viewport. If the style loads before
the first layout settles, the fit is computed against a stale viewport and the
*content* reads as too small until something moves the camera again. This presents
similarly but has a different cause and a different fix (re-fit once the viewport is
known). **Confirm which platform the symptom was observed on before fixing this half.**

**Acceptance**

- The map fills its allotted space on the very first painted frame, on the game page
  and the hierarchy page alike, with no visible resize.
- Rotating / resizing the window still resizes the map correctly.

---

## Sequencing

1. **S5** (sizing bug) — independent, small, and currently visible on every launch.
2. **S2** (narrator palette) — isolated; touches `GamePalette` and `NarratorCard`.
3. **S3** (`GameSounds`) — interface and call sites; `SilentGameSounds` stays default.
4. **S1** (callout + `BeatEmphasis`).
5. **S4** (Ismailia) — **last**: it lands on the newest route code and on the step
   list, and it consumes the callout S1 provides.

**Recommended before S4**, from the architecture survey: seal `GameStep` and replace
`GameJourneyState`'s int `reveal` with an enum/sealed `CardState`. S4 adds a case to
the step list, which is precisely what sealing makes safe; and `signReveal ==
imageReveal == 1` today means `showsSign` and `showsImage` are silently the same
predicate.

## Also outstanding (not in this spec)

- `JourneyMapPage` pushes the game as a `MaterialPageRoute` without disposing the
  route beneath, so **two full map instances are alive whenever the game is open**.
- Missing `buffer.dispose()` in `PixelSpritePng.toPng`.
- Unguarded `_onStyleImageMissing` on native (re-rasterises on every event).
- `_flySweep` has no cancellation on either surface.
