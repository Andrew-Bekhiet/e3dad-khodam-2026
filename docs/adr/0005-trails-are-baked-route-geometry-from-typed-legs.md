# Trails are baked route geometry, generated from typed legs

A trail used to be a cardinal spline sampled through the stops a courier had halted at. It is now a
fixed list of positions per leg, generated once by `tool/generate_route_geometry.dart` and committed
as `lib/src/data/game/route_geometry.dart`. Every leg declares itself **land** or **sea**, and the
generator treats the two differently: land legs come from the Mapbox Directions API with
`overview=simplified`, sea legs from waypoints charted by hand and smoothed through `TrailCurve`.

The spline was wrong in a way that is easy to miss: it bowed the same amount whether the ground
between two stops was a Roman road or the Aegean, so it cut across Greece on a leg that was sailed
and across open water on a leg that was walked.

**Only one of the journey's seven legs is land.** تسالونيكي → كورنثوس. Paul made the other six by
ship. The count fell from ten legs to seven when the four prison Letters stopped standing at the
cities they were addressed to and started standing in رومية, where they were written: فيلبي،
كولوسي and أفسس are no longer Stops, so the legs that reached them are gone and رومية → كريت is
new.

## Consequences

**Do not "finish the job" by routing the rest through the Directions API.** This is the mistake this
ADR exists to prevent. It fails outright on two legs — كريت is an island and no road route to it
exists — and on the rest it succeeds while lying: أنقرة → رومية comes back as 2,800 km of motorway
through the Balkans. A plausible-looking wrong route is worse than an obviously hand-drawn one. The
generator throws on a failed land leg rather than falling back to a straight line, for the same
reason.

**`TrailCurve` is no longer used at run time.** It survives, and keeps its test, but only the
generator calls it — to smooth sea waypoints. `TrailLayer` used to run it over every trail and no
longer does: smoothing a road only bends it off the road. Anyone reintroducing a spline in the
render path will silently un-straighten every motorway.

**Sea waypoints are a judgement call, and are meant to be edited.** They trace the coast and pass
between the islands because that is how first-century ships sailed, and because a line near land
reads better than one across empty blue at the sweep's widest zoom. Correcting a lane means editing
one short list in `JourneyLegs` and re-running the generator — never editing the generated file.

**A leg travelled backwards is the same leg reversed.** أفسس ↔ أورشليم is charted once and walked
both ways. Adding the reverse as its own entry would let the two copies drift apart. A leg the
journey only ever walks in one direction is declared in that direction, which is why كريت → أفسس
is named for the way it is travelled rather than for the way it was first charted.

**Land legs are pinned to the gazetteer at both ends.** The directions service snaps to the nearest
road, landing a few metres off. Invisible, except that it would leave a courier standing just beside
their own marker, so the generator overwrites both endpoints.

**The generated file must pass the same analyzer as everything else.** This is why the generator
trims trailing zeros from its literals — `double_literal_format` rejects `40.64010`. A generator
that emits code has to know the lint rules.
