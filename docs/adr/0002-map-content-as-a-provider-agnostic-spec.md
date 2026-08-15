# Map content is a provider-agnostic spec, rendered by Mapbox's own engines

Markers, trails and character tokens are not Flutter widgets positioned over a map. Each frame the
app builds a `MapSurfaceSpec` — plain data describing what should be on the map — and the surface
hands it to Mapbox to draw natively: GeoJSON sources with symbol and line layers on the Maps SDK for
android/ios, and Mapbox GL JS on web. Overlaying Flutter widgets was the obvious alternative and is
what an unfamiliar reader will expect; it was rejected because widgets do not stay glued to the map
during a gesture (they lag a pan or pinch by a frame), cannot be interleaved with the basemap's own
layers, and cost a rebuild per marker per frame.

## Consequences

**Everything on the map has to survive serialisation.** A `MapMarkerSpec` becomes a GeoJSON feature,
so its every field has to round-trip through feature properties or be resolvable from its style. This
is why the spec types are pure data with no `Widget`, no callback and no closure in them — a
constraint that looks like excessive purity until you know it is load-bearing. `MapMarkerSpec.id` in
particular must round-trip unchanged, because it is what a tap reports back.

**Some styling cannot be data-driven and must be fixed per layer.** `line-dasharray` is the case that
already bit: Mapbox will not drive it from feature data, so the trail dash pattern lives style-wide in
`TrailLayer` rather than on `MapTrailSpec`. Expect more of these; the fix is to lift the property to
the layer, not to reach for a widget.

**The app cannot ask the surface "what changed?"** The surface diffs specs across rebuilds itself,
which is why `MapCameraTarget` is sealed and comparable, and why camera animation *duration* is
supplied by the cubit rather than inferred — the surface has no notion of "drilling down" versus
"going back", and guessing it from a coordinate delta would be wrong.

**Provider-specific concerns stay out of the spec.** Tile URLs, access tokens and attribution belong
to whichever `MapSurfaceBuilder` implementation is in play, not to the description of the app's
content. Keeping that line clean is what makes the native/web split two implementations of one
interface rather than two codebases.
