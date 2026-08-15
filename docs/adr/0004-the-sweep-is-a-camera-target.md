# The sweep is a camera target, not a sequence the cubit times

A sweep is three movements — out to the Sweep Frame, a pause during which the couriers walk their
leg, then in on the new Destination — and it takes about three seconds. It is expressed as one `SweepCameraTarget` in the sealed
`MapCameraTarget` set. `GameJourneyCubit` emits it and moves on; each map surface performs the three
parts.

The obvious alternative is for the cubit to emit an intermediate state showing the wide frame, wait,
then emit the arrival. It was rejected for two reasons. The widest point would become a real state
of the playthrough, which means it is somewhere the player can stop, step back into, and be handed
a half-finished journey. And the cubit's entire test suite is synchronous — it drives the real
shipped script with no mocks and no clock — so a timer would push fake async into every test in the
file to buy nothing the surfaces cannot do themselves.

This also follows `ADR 0002`: the spec says *what* to show and each provider decides *how*.

## Consequences

**Every surface must handle the new variant, and the compiler will insist.** `MapCameraTarget` is
sealed, so adding `SweepCameraTarget` broke both surfaces' switches until each grew a case. That is
the intended pressure — a surface that silently ignored sweeps would be a black screen on the night,
found late.

**A sweep ignores `MapSurfaceSpec.cameraAnimationDuration`.** It carries its own three durations, so
the spec-wide duration is meaningless for it. Any future target with internal timing will have the
same shape, and anything reading `cameraAnimationDuration` to reason about how long the camera will
take is already wrong.

**Both legs are concrete types, not nested `MapCameraTarget`s.** `widest` is a
`FitBoundsCameraTarget` and `arrival` a `CenterZoomCameraTarget`. This keeps the sealed type from
being recursive, which would have forced every surface to switch inside its own switch. The cost is
that a sweep can never end on fitted bounds; nothing wants that, and if something does, it is a new
variant rather than a loosened field.

**The cubit cannot know when a sweep has finished.** It emits and forgets. Anything that must
happen *after* the camera lands — the couriers arriving, the queue of presses made mid-flight —
lives in the widget layer with the clock, not in the cubit. `GameJourneyPage` owns that clock, and
it is deliberately the only one: the couriers walking, the trail drawing itself and the streaks over
the map are one movement and must not drift apart.

**Sweeping is decided per level, not per step.** Every step of a level answers the same camera
target, so the camera moves once and then holds while the guide talks. Two levels in the same city
answer a plain arrival instead, because a sweep between them would fly out to the whole basin and
return to an identical view.
