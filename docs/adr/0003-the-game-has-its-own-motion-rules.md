# The Post Office Game has its own motion rules

`docs/design.md` §5 ends by ruling out expressive motion: *"no bounce/elastic curves, no rotation, no
overshoot — this is a Bible-study reference tool, not a game."* That rule now binds the **Cross Map
only**. The Post Office Game is allowed overshoot, staggered reveals, streak overlays and a
near-two-second camera sweep between levels, and `docs/design.md` carries a game-motion section
saying so.

The rule was written when the app was one screen. The Cross Map is a memorisation aid someone reads
at their own pace; a restrained camera is correct there. The Post Office Game is played from a
laptop onto a projector, in front of a room, by an operator pressing a key — and it is a game, which
is what `CONTEXT.md` has called it since it existed. Applying one motion vocabulary to both was
tried on paper and rejected: it either makes the reference tool frivolous or the game inert.

## Consequences

**A reader will find the two documents in apparent contradiction.** Someone landing in
`docs/design.md` §5 and then opening `SweepOverlay` or `DestinationCard` will think the game breaks
the house style. It does not; the rule's scope is narrower than its wording once was. This ADR is
the thing that says so, and it is why the §5 sentence now names the Cross Map explicitly.

**Motion numbers live in two places on purpose.** The Cross Map's drill/back durations stay in §5.
The game's — sweep frame, arrival zoom, the three sweep durations — sit in the game-motion section
and are mirrored as named constants on `GameJourneyCamera`. Tuning one must not silently tune the
other.

**"Tasteful" is no longer the test for game chrome.** The test is whether it reads from the back of
a room. That admits things the Cross Map would never do — a blurred map, streaks over it, a card
that scales past its final size before settling — and it will keep admitting more. Reviewers should
not cite §5 against game widgets.

**The Cross Map is not a fallback style for the game.** Reusing `MapHierarchyCubit`'s camera
durations or its root bounds in the game looks like sensible reuse and is not: they are tuned for a
different job, and the root bounds are derived from Mnemonic Placements, which are not real
positions. The game's sweep frame is a separate constant even though it currently holds the same
four numbers.
