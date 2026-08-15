# Spec: The Sweep and the Destination Card

Status: ready-for-agent

## Problem Statement

The Post Office Game moves between Levels without any sense of travel, and tells the player
almost nothing about where they have arrived.

Four things are wrong from the player's seat:

1. **Nothing moves between Levels.** The camera slides from one framing to the next in 550ms,
   fitting a box around the new Destination and the previous one. The two places are on screen at
   once, so the player never sees the distance closed. The Couriers do not travel — their Tokens
   are simply drawn in the new place on the next frame. The Trail is drawn complete the instant
   the Level changes. Nobody journeys anywhere; the picture is just replaced.

   The Trail's shape is wrong as well as its timing. It is a cardinal spline sampled through the
   Stops — a mathematical arc that knows nothing about geography. It cuts across Greece on a leg
   that was sailed, and across open sea on a leg that was walked. It bows the same way whether
   the ground between two Stops is a Roman road or the Aegean.

2. **The screen never says where the player is.** The panel at the top shows `مرحلة ٣ / ١٤`, the
   Letter's title, and a progress bar. The Destination's name appears only in small text inside
   the Destination Card, and the Card itself is invisible until the first Verse is revealed. The
   year is nowhere at all, although the Play Script opens the game by putting the audience `في
   زمن ٥٢ م`.

3. **The Play Script asks for something the app does not do.** The Script stages this exact
   feature and the app ignores it:

   > (أول ما يتنقلوا نعرض على الشاشة لافتة كبيرة مكتوب عليها تسالونيكي 52م وتنزل خريطة عليها
   > إشارة بتشاور على مدينة تسالونيكي)

   A large لافتة carrying the Destination and the year, then a map pointing at the place. The app
   has neither the لافتة nor the year.

4. **The Level's artwork is buried.** `GameLevel.imageAsset` exists and every Level names a file,
   but the Destination Card draws the picture as a 260px band above the text, and hides the whole
   Card until a Verse is revealed. The artwork is meant to set the mood of the city; it is
   currently a thumbnail that most Levels never reach.

The game runs on a projector, in front of a room, driven by one person pressing a key. It needs
to read as a journey, and each arrival needs a moment.

## Solution

Two changes, and a set of motion decisions that follow from them.

**The Sweep.** When the Journey reaches a new Destination, the camera pulls out to the
Mediterranean, holds there for a moment, then comes in to the new Destination and centres it. The
Couriers walk the Trail while the camera comes in, and the Trail draws itself behind them as they
go. The screen carries nothing else while this runs — no Card, no Story Beat, no Sign. The player
sees the whole basin, then falls into one city.

**Real routes.** The Trail stops being a mathematical arc. Every Leg between two Stops is typed as
land or sea. Land Legs take their shape from the Mapbox Directions API, simplified. Sea Legs
follow hand-picked coastal waypoints, so the line stays on the water and threads between islands
rather than crossing a peninsula. Both are generated once, offline, and baked into the app as
static data — so the game needs no network and no token to draw its own history.

**The Destination Card.** After the Sweep lands, the Card opens in the centre of the screen and
grows on each press:

1. The **Sign** — the Destination name and the year, `تسالونيكي ٥٢م`.
2. The **background image** — the Level's artwork, filling the Card behind its text.
3. The **Verses**, one at a time, as now.

The Card replaces the top panel entirely. There is no level counter and no progress bar. The
name and year appear exactly once on screen, at the top of the Card, and stay for the whole
Level.

Every one of these steps happens on a key press. Nothing reveals itself on a timer. The whole
playthrough behaves like a slideshow, because that is how it is driven on the night.

## User Stories

### Arriving at a Destination

1. As a player, I want the camera to pull back to the whole Mediterranean when the Journey moves
   on, so that I understand how far the Letter has to travel.
2. As a player, I want the camera to hold at its widest point for a moment, so that the region
   registers before the camera dives again.
3. As a player, I want the camera to come in to the new Destination and centre it, so that I know
   exactly which place this Level is about.
4. As a player, I want the arrival to take longer than the departure, so that the moment of
   landing is the part I watch.
5. As a player, I want the screen to be completely clear while the camera moves, so that nothing
   covers the map during the one moment it is worth watching.
6. As a player, I want the camera to land at the same zoom for every Destination, so that no city
   looks more important than another because of framing.
7. As a player, I want to see the centred Destination with nothing over it before anything opens,
   so that I get one clean look at where I am.
8. As a player, I want no Sweep when the next Level is in the same Destination, so that the camera
   does not fly out and back to the identical view between the two Letters to تسالونيكي.
9. As a player, I want the Sweep to run when I step backwards too, so that going back through the
   Journey feels like travel and not like an undo.
10. As a player, I want the Sweep to run when I tap a cleared Stop on the map, so that jumping
    back to a city I have visited looks the same as reaching it the first time.
11. As a player, I want the map to blur while the camera is at its fastest, so that the movement
    reads as speed rather than as a slide.
12. As a player, I want streaks and a darkened edge during the Sweep, so that the movement feels
    like falling into the city.

### The Couriers

13. As a player, I want the Couriers to walk from the old Stop to the new one, so that the Letters
    are carried rather than teleported.
14. As a player, I want the Couriers to walk the Trail rather than a straight line, so that the
    route looks like a journey by road and sea.
15. As a player, I want the Trail to draw itself behind the Couriers as they walk, so that the
    line is a record of travel and not a diagram that appears whole.
16. As a player, I want the Couriers to walk while the camera comes in, so that the two movements
    read as one arrival.
17. As a player, I want the paired Couriers to stay side by side as they walk, so that they still
    read as two people travelling together.

### The route

18. As a player, I want a Leg travelled by road to follow a real road, so that the line bends
    around mountains and along valleys the way a journey on the ground does.
19. As a player, I want a Leg travelled by sea to stay on the water, so that the Trail never draws
    a ship crossing a peninsula.
20. As a player, I want a sea Leg to hug the coast and pass between the islands, so that the route
    looks like first-century sailing rather than a modern open-water crossing.
21. As a player, I want the Trail to reach كريت at all, so that an island Destination is not the
    one place the Journey cannot draw a line to.
22. As a player, I want the Trail readable when the camera is at its widest, so that the whole
    route is legible during the Sweep and not a dense scribble.
23. As the operator, I want the routes stored in the app, so that the game needs no network on the
    night and cannot fail because an API is down or a token expired.
24. As a developer, I want the routes generated by a script I can re-run, so that changing a Stop
    does not mean redrawing a line by hand.
25. As a developer, I want each Leg to declare whether it is land or sea, so that the generator
    never asks a road service for a route across the Aegean.

### The Destination Card

26. As a player, I want the Destination name and the year on screen after I arrive, so that I know
    both where and when this Letter belongs.
27. As a player, I want that name and year to appear once and in one place, so that I am not
    reading the same thing in two panels.
28. As a player, I want the name and year to stay on screen for the whole Level, so that I can
    look up at any point in a long discussion and know where I am.
29. As a player, I want the Card to appear only when the operator presses a key, so that my clean
    look at the city is not cut short.
30. As a player, I want the Level's artwork to fill the Card behind the text, so that the city has
    a mood and not just a name.
31. As a player, I want the artwork to appear only on a press, so that it lands as a deliberate
    reveal in the same way the Verses do.
32. As a player, I want the text over the artwork to stay readable whatever the picture is, so
    that a bright or busy image does not cost me the words.
33. As a player, I want the Verses revealed one at a time after the artwork, so that each one is
    the reward for the part of the Level just understood.
34. As a player, I want the Card to grow smoothly as each part opens, so that the panel does not
    jump.
35. As a player, I want the Card to close before the Journey moves on, so that the map is clear
    for the next Sweep.
36. As a player, I want no progress bar and no level counter, so that the screen carries the story
    and not a status readout.

### Running the show

37. As the operator, I want every change on screen to happen on a key press, so that I can pace
    the game to the room instead of racing an animation.
38. As the operator, I want a press during the Sweep to be remembered and applied when it lands,
    so that an early press is never simply lost.
39. As the operator, I want the same number of presses per Level whether or not the artwork file
    exists, so that my timing does not change when an image is added.
40. As the operator, I want the game to look the same on the projector as it did when I rehearsed
    it, so that the two platforms do not animate differently.
41. As the operator, I want stepping backwards to undo the Card one part at a time, so that I can
    return to a Verse I moved past too quickly.

### Missing artwork

42. As the operator, I want a Level with no artwork file to draw a deliberate placeholder, so that
    the screen never looks broken in front of the room.
43. As the artist, I want to drop a file into the Level artwork directory and have it appear with
    no code change, so that pictures can arrive right up to the night.

### Terminology and documents

44. As a developer, I want the panel named for the Destination rather than for a city, so that the
    code agrees with the glossary about غلاطية and كريت not being cities.
45. As a developer, I want the Sweep expressed as a Camera Target rather than as timers in the
    cubit, so that the playthrough stays synchronous and testable.
46. As a developer, I want the Post Office Game's motion rules written down separately from the
    Cross Map's, so that a future reader does not think the game breaks the design document.
47. As a developer, I want the Sweep Frame to be the Journey's own constant, so that the Cross
    Map's mnemonic geometry does not leak into the game.
48. As a reviewer, I want the fourteen years in one place, so that I can check the dates without
    reading fourteen Level definitions.

## Implementation Decisions

### Vocabulary

Seven terms enter `CONTEXT.md`:

- **Sweep** — the camera movement between Destinations: out to the Sweep Frame, a hold, then in
  to the new Destination.
- **Sweep Frame** — the widest bounds the Sweep reaches. Provisionally the same four numbers as
  the Cross Map's root bounds, but a separate constant belonging to the Journey.
- **Sweep Camera Target** — the Camera Target variant that describes a Sweep.
- **Sign (لافتة)** — the Destination name and year shown at the top of the Destination Card. The
  Play Script's own word.
- **Leg** — the stretch of the Journey between two consecutive Stops. Every Leg is either a **Land
  Leg** or a **Sea Leg**, and that is a property of the Leg itself, not of how it is drawn.
- **Route Geometry** — the fixed line a Leg is drawn along: a list of positions, generated once
  and stored with the app. Not computed at run time.
- **Trail** keeps its meaning — the dashed line marking where a Courier has been — but is now
  drawn along Route Geometry rather than along a curve fitted to the Stops.

The existing **Destination Card** entry is extended to describe its three states.

`CityOverlay` is renamed `DestinationCard`, and `cityLabel` becomes `destinationLabel`. The
glossary's position is unchanged: not every Destination is a city.

### The Camera Target seam

`MapCameraTarget` gains a fourth variant describing a Sweep. It carries the Sweep Frame to reach
at its widest point, the final target to settle on, and a duration for each of the three parts.

This follows ADR 0002: the Surface Spec says *what* to show, and each provider decides *how*. A
Sweep is a *what*. The alternative — the cubit emitting an intermediate state on a timer — is
rejected because it would put timers into a cubit whose entire test suite is synchronous, and
because the widest point would become a real Step the player could stop on.

Each Map Surface runs the Sweep as two sequenced camera moves with a wait between them. Both
platforms run the same shape. This also removes an existing inconsistency: the native surface
uses `flyTo` and the web surface uses `easeTo`, so the camera already moves differently on the two
platforms today.

Native's animation options carry only a duration and a start delay — there is no easing
parameter. Each leg is therefore split into a small number of sub-moves with different durations,
which synthesises a fast start and a hard stop on both platforms.

### When a Sweep runs

The Sweep runs on entering the **first Step of a new Level**, and not on any other Step. Story
Beats within a Level do not move the camera.

Three rules qualify it:

- The Destination did not change from the previous Level → no Sweep. The camera holds.
- A backward Step into a previous Level runs a Sweep.
- A tap on a cleared Stop's Marker runs a Sweep.

### Camera values

- The Sweep Frame is `SW (30.89, 10.00)`, `NE (43.57, 26.00)`. Its own constant, marked
  provisional in a comment. It does not contain أورشليم, غلاطية or كولوسي; that is accepted.
- The Sweep settles centred on the Destination at zoom **8.0**.
- Durations: out **700ms**, hold **150ms**, in **900ms**.
- No padding is applied to the settled target. The Destination sits in the centre of the screen,
  and the Card later covers that centre by design — the player has already had their clear look.

### Reveal within a Step

The state's existing `versesShown` counter generalises into a single **Reveal** value describing
how far the Destination Card is open on the current Step:

| Reveal | Card |
|---|---|
| swept | nothing — the Sweep is running or has just landed |
| sign | the Destination name and the year |
| image | the above, plus the background artwork |
| verse *n* | the above, plus *n* Verses |

`forward()` and `backward()` already walk `versesShown` within a Step before moving to the next
Step. That mechanism is kept and widened to walk the whole Reveal sequence. No new stepping
concept is introduced.

Reveal per Phase:

- **First Step of a Level** — starts at *swept*. One press moves it to *sign*, which also brings
  in that Step's Briefing Story Beat. So one press both lands the Level and starts the Guide.
- **Remaining briefing Steps** — *sign*. The Card carries the name and year while the Guide
  speaks.
- **Playing Step** — starts at *sign*. Presses walk it to *image*, then through the Verses.
- **Clearance Steps and the epilogue** — *swept*. The Card is closed.

A press arriving while the Sweep is still running is queued and applied when it lands.

### The Destination Card

- One panel, centred. It grows as the Reveal advances, keeping the existing `AnimatedSize`.
- The Sign — name and year — is the Card's top line, and is present in every open state.
- The artwork is the Card's background, with a dark screen layer between it and the text.
- A missing artwork file draws a generated placeholder: a flat pixel-art panel in the Level's own
  colour carrying the Destination name. The press count for a Level does not depend on whether
  the file exists.
- `LevelHud` is deleted. Nothing is drawn at the top of the screen. There is no progress bar and
  no level counter. `GameJourneyState.progress` loses its only consumer and goes with it.

### Data

`GameLevel` gains a nullable year. Only `thessalonians-1` has one in the Play Script (`٥٢م`); the
other thirteen take standard scholarly dates supplied with this work and collected in one place
for later review. A Level with no year shows the Destination name alone.

### Route Geometry

The Trail stops being computed from the Stops. Each Leg gets a fixed Route Geometry, generated
once, offline, and stored as static Dart data alongside the Gazetteer. Nothing is fetched at run
time: the app ships its routes, needs no network on the night, and cannot fail because a token
expired.

**Every Leg declares whether it is land or sea**, and the generator treats the two differently.
This is required, not a refinement: the Journey visits كريت, an island, and no road service can
answer a route to it. Two of the ten Legs cannot be routed by road at all, and four more return a
modern motorway detour for a crossing Paul made by ship.

- **Land Legs** are fetched from the **Mapbox Directions API**, driving profile, with
  `geometries=geojson` and `overview=simplified`. The simplification you asked for is that
  parameter — the API returns a low-resolution geometry sized for display, so no client-side
  Douglas-Peucker pass is written. Only two Legs qualify: تسالونيكي → كورنثوس, and كولوسي → أفسس.
- **Sea Legs** are built from a short hand-picked list of coastal waypoints and run through the
  existing `TrailCurve` spline. Waypoints are chosen so the line stays on water, rounds the
  headlands and threads between the islands, matching how first-century ships actually sailed —
  coastal and island-hopping, not open water.

The generator is a script under `tool/`, run by hand, that reads the Legs and writes one Dart data
file. It takes the Mapbox token from the environment. Re-running it is how a changed Stop gets a
new line; no line is ever edited by hand in the generated file.

`TrailCurve` survives and keeps its test, but its role moves: it is used by the generator to
smooth sea waypoints, not by the app at run time. At run time a Trail is a lookup of stored
positions.

If a Land Leg's request fails when the generator runs, the script fails loudly with the Leg named.
It does not silently fall back to a straight line — a wrong route that looks plausible is worse
than a stopped build.

### Motion

- **Couriers walk.** During the Sweep's inward leg the Courier Tokens move along the Leg's Route
  Geometry from the previous Stop to the new one. Paired Couriers keep their existing screen-space
  separation as they go.
- **The Trail draws itself.** The Trail's leading end follows the Couriers. One animation drives
  both: the Courier's position along the Route Geometry *is* the Trail's end, so the two are one
  computation, not two.
- **Sweep overlay.** A Flutter-drawn layer above the map during the Sweep: fine streaks running
  outward from the centre, plus a vignette. Strongest at the fastest part of the movement, gone
  by the time the camera settles. Runs on every platform.
- **Map blur, web only.** The web surface already holds the map's container element. A CSS filter
  on that element blurs the real map during the Sweep. Neither `ImageFiltered` nor `BackdropFilter`
  can do this — the map is a platform view whose pixels Flutter never draws — so this is the only
  real blur available, and it is one line on an element already in hand. Native gets the overlay
  alone.
- `ImageFiltered` is preferred over `BackdropFilter` for anything Flutter does draw.

Explicitly not built: a pulsing Destination Marker, an idle bob on standing Couriers, and a stamp
animation on the Sign. The first two were judged to add no information; the idle bob would also
rewrite a GeoJSON source every frame for the whole session, including while Verses are being read.

### Cost accepted

Walking the Couriers means rewriting a GeoJSON source every frame while the Sweep runs. On web
this is a small `setData` call and is well within budget. On native it is a platform channel call
per frame and may stutter. This is accepted: the show runs on web, with desktop possible later,
and mobile only for previews.

### Documents

Three ADRs:

- The Cross Map's "no bounce, no overshoot — this is not a game" rule binds the Cross Map only.
  The Post Office Game gets its own motion rules. A game motion section is added to
  `docs/design.md`.
- The Sweep is expressed as a Camera Target rather than as sequenced states from the cubit.
- Trails are baked Route Geometry, generated offline from typed Legs, rather than a curve computed
  from the Stops at run time. This one records why the Legs are typed at all, and why the Directions
  API is used for two Legs and refused for the other eight — otherwise a future reader will try to
  "finish the job" and route the whole Journey by road.

`docs/design.md` gains the Sweep's numbers — frame, zoom, durations — so they can be tuned in one
place.

## Testing Decisions

A good test here states what the player or operator would observe, and would still pass if the
widgets were rebuilt differently. It does not assert on widget trees, animation controllers, or
the order of internal calls.

### Seam 1 — `GameJourneyCubit` to `GameJourneyState` (existing, primary)

Every decision worth testing is a decision this cubit makes. Prior art is
`test/presentation/game_journey_cubit_test.dart`, which drives the real shipped Script with no
mocks, synchronously, and names its tests
`GameJourneyCubit_<situation>_<expectation>`. That file is the model to follow, and the cubit
stays synchronous so it keeps working.

Cases to cover:

- Entering a new Level emits a Sweep Camera Target whose final target is centred on that Level's
  Destination.
- Entering a Level whose Destination equals the previous Level's does **not** emit a Sweep. Levels
  ١→٢ (تسالونيكي) and ٣→٤ (كورنثوس) are the concrete cases already present in the Script.
- Story Beats within a Level do not change the Camera Target.
- Stepping backwards into a previous Level emits a Sweep.
- `goToStop` onto a cleared Stop emits a Sweep; onto a Stop not yet reached it still does nothing.
- The Reveal sequence: a Level's first Step starts *swept*; one press reaches *sign* and brings in
  the Briefing Beat; the playing Step walks *sign* → *image* → each Verse in the Script's order.
- `backward()` walks the Reveal down before leaving the Step.
- Clearance Steps and the epilogue report the Card closed.
- The Reveal resets when the Step changes, as `versesShown` does today.
- A Level with a year reports it; a Level without one reports null.

### Seam 2 — the walk (new, one pure function)

The only new seam. Given a Leg's Route Geometry and a progress value from 0 to 1, it returns where
the Courier stands and how much of the Trail is drawn. Pure, synchronous, no Flutter. It does not
care whether the geometry came from the Directions API or from hand-picked sea waypoints, which is
exactly why the typing of Legs stays out of it.

Prior art is `test/map_engine/trail_curve_test.dart`, which tests `TrailCurve` the same way.

Cases to cover:

- Progress 0 puts the Courier on the previous Stop; progress 1 puts them exactly on the new one.
- The drawn Trail always ends where the Courier stands.
- The Courier follows the Route Geometry's points, not the straight line between Stops.
- Progress advances by distance along the geometry, not by point index, so a Leg whose points
  bunch at one end does not make the Courier crawl there and sprint elsewhere.
- A Leg with a single position is handled without error.

### The generated route data

The Route Geometry file is generated, so its *content* is not asserted point by point — that
would be a test of the Directions API. What is worth holding is that the data set is complete and
usable:

- Every consecutive pair of Stops in the shipped Script has a Route Geometry.
- Every Route Geometry starts at its Leg's first Stop and ends at its second.
- No Route Geometry is empty or a single point.
- Every Leg is typed either land or sea; none is untyped.

These read the shipped data with no network, in the same spirit as
`test/presentation/game_journey_cubit_test.dart` driving the real Script rather than a fixture.

### Not tested

Running the two camera legs, the CSS blur, and the streak overlay are provider and widget work,
driven by an animation controller that reads seam 2. They are not unit tested. This matches the
codebase as it stands: no test covers either Map Surface today.

The generator script itself is not tested. It is run by hand, it talks to a network service, and
its output is reviewed by looking at the map. A test would only restate the script.

`TrailLayer` and `TokenLayer` are unchanged — they still receive a list of positions and build
GeoJSON from it. The walk changes what positions they are given, not how they build.

## Out of Scope

- **Blank-screen keys.** Copying `b`, `w` and `.` from presentation software for black and white
  screens. Agreed as a separate session.
- **Real Level artwork.** No file exists for any of the fourteen. The placeholder covers this
  until pictures arrive.
- **Reviewing the fourteen years.** The dates ship unreviewed by agreement, in one place, for
  checking later.
- **Refining the "falling" feel.** The streak overlay and blur ship at judged values. Tuning them
  happens after the effect has been seen running, so that the feel is not drifted towards blind.
- **The Cross Map.** Its camera, its motion rules and its root bounds are untouched.
- **Sound.** `GameSounds` is unchanged; no sound accompanies the Sweep.
- **Renaming Destination to City.** Considered and rejected; the glossary's position stands.
- **Routing at run time.** The app never calls the Directions API. Routes are generated once and
  shipped.
- **Historically reconstructed Roman roads.** Land Legs follow modern roads as the Directions API
  reports them. Tracing the Via Egnatia and the Via Appia from archaeology is a bigger job than
  this feature, and the two Land Legs here are short enough that the modern road and the ancient
  one run through the same valleys.
- **Reviewing the sea waypoints.** They ship at my judgement, like the years. Correcting a lane is
  editing one short list and re-running the generator.

## Further Notes

**The Play Script is the source.** `~/Documents/اعداد خدام/play.docx` was re-read for this work
and is newer than the `المسرحية.docx` named in `CONTEXT.md`. It supplies both the لافتة staging
and the only year the game has. Nothing here invents Script content.

**Two Levels still look alike.** With the Sign showing the Destination alone, Levels ١ and ٢ show
`تسالونيكي` with the same year, and Levels ٣ and ٤ show `كورنثوس`. The Letter's title is not on
screen anywhere. This was raised and accepted: the Guide names the Letter in the Briefing
immediately before, and every Verse carries its own citation.

**أورشليم falls outside the Sweep Frame.** A Sweep to أورشليم reaches its widest point with the
target off screen, then finds it on the way in. Raised and accepted; the Journey leaving the frame
at the end suits the story.

**The Sweep Frame is provisional.** It currently copies the Cross Map's root bounds by decision,
"until further notice". It is a separate constant precisely so that notice costs one line.

**Where the years live.** They are collected in one place rather than spread across the two Level
data files, so the review that was deferred is a single read.

**The Directions API earns only two Legs.** The Journey's ten Legs were walked one by one before
this was decided:

| Leg | Type | Source |
|---|---|---|
| تسالونيكي → كورنثوس | Land | Directions API |
| كورنثوس → غلاطية | Sea | Aegean waypoints |
| غلاطية → رومية | Sea | Aegean, Ionian, Adriatic waypoints |
| رومية → فيلبي | Sea | Adriatic waypoints |
| فيلبي → كولوسي | Sea | Aegean waypoints |
| كولوسي → أفسس | Land | Directions API |
| أفسس → كريت | Sea | Aegean waypoints |
| كريت → أفسس | Sea | Aegean waypoints |
| أفسس → أورشليم | Sea | Eastern Mediterranean waypoints |
| أورشليم → أفسس | Sea | Eastern Mediterranean waypoints |

Two Legs are the API's whole contribution. This is not a limitation of the API; it is a fact about
Paul, who travelled by ship. Routing the rest by road would draw him on a motorway through the
Balkans, which looks real and is false. This is what the third ADR exists to record.

**Sea Legs hug the coast.** The waypoints keep the line near land, rounding headlands and passing
between islands, because that is how ships sailed in the first century and because a line near the
coast reads better at the Sweep's widest zoom than one across empty blue. Open-water lanes were
offered and not chosen.
