# One gazetteer, shared by both maps

The app draws two maps over the same part of the world — the mnemonic cross and the post-office
game — and for a while each kept its own copy of where the shared cities are. They drifted: غلاطية
ended up ~48 km apart between the two, and كولوسي ~11 km, with the cross also silently deviating from
the coordinate appendix in `docs/design.md` that both were supposed to follow. We now keep a single
gazetteer, `StopPositions` in `lib/src/data/journey_stops.dart`, and both maps read the shared places
off it.

## Considered Options

The original arrangement was deliberate, and its reasoning is worth keeping: the game visits places
the cross never lists (أورشليم), so making the game depend on the cross's tree would have produced
partial reuse plus a special case — *half-depending*, which is worse than either clean option. That
argument is sound but it argued against the wrong direction of dependency. Inverting it — the
gazetteer is its own thing, and the cross is one of its two consumers — gets single-sourcing without
the special case, because the gazetteer is not obliged to have the same shape as the cross's tree.

## Consequences

The gazetteer holds **only real places**. The cross's four arm anchors, its continents, its seas and
its countries are not in it and must not be added: those are mnemonic placements chosen to make an
equal-armed cross render nicely, explicitly "not the real location of anything". Only entries that
answer "where is this place, really?" belong.

`StopPositions` is separate from `JourneyStops` — a class of bare `GeoPosition`s alongside the class
of `JourneyStop`s — purely because Dart forbids reading a field off a const object inside a const
expression. The cross needs a `GeoPosition` in a `const PlaceNode(...)`, and it cannot get there via
`JourneyStops.galatia.position`. Merging the two classes would mean restating every coordinate, which
is the thing this ADR exists to prevent.

`docs/design.md`'s appendix was amended to match, and now carries full-precision coordinates for the
shared places rather than the 2-decimal values it originally supplied. That appendix and the
gazetteer must be changed together.
