# Game Journey camera policy is separate from navigation

`GameJourneyCubit` originally held the flattened Play Script, map projection, camera decisions,
motion constants, and the player's navigation intents. The camera is presentation policy: it is the
only part that needs `EdgeInsets`, while navigation must remain synchronous and independent of a
map surface.

## Consequences

`GameJourneyCamera` owns the game’s sweep frame, arrival zoom, durations, framing, and choice
between arrival and sweep targets. `GameJourneyCubit` retains only the index, player intents, and
state emission. The cubit still emits one `SweepCameraTarget` and forgets it, as required by ADR
0004; no timer or asynchronous state was introduced.
