import 'package:e3dad_khodam_2026/src/domain/journey_map_tree.dart';
import 'package:e3dad_khodam_2026/src/domain/non_geographic_group.dart';

/// Source of the journey-map hierarchy and its non-geographic companion
/// data. Both loads are synchronous because the dataset is a compile-time
/// constant, not a network or disk resource.
abstract interface class JourneyMapRepository {
  /// Loads the full three-level hierarchy of categories and places.
  JourneyMapTree loadTree();

  /// Loads the slideshow order: node ids to focus in turn, with `null`
  /// standing for the root cross.
  List<String?> loadSlideshow();

  /// Loads the recipient groups that never appear on the map.
  List<NonGeographicGroup> loadNonGeographicGroups();
}
