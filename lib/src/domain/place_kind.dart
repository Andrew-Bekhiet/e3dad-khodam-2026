/// The map-marker taxonomy for a `PlaceNode`, driving icon and styling
/// choices in the presentation layer.
enum PlaceKind {
  /// A landmass-scale region, e.g. Asia or Europe.
  continent,

  /// A modern or historical country-scale territory.
  country,

  /// A body of water.
  sea,

  /// An island.
  island,

  /// A city-scale settlement.
  city,
}
