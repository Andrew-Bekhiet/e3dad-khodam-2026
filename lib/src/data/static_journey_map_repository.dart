import 'package:e3dad_khodam_2026/src/data/st_paul_map_dataset.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_tree.dart';
import 'package:e3dad_khodam_2026/src/domain/non_geographic_group.dart';

/// [JourneyMapRepository] backed by the static, compile-time
/// [StPaulMapDataset] — there is no I/O, so every call is synchronous and
/// cheap.
final class StaticJourneyMapRepository implements JourneyMapRepository {
  /// Creates a repository over the built-in dataset.
  const StaticJourneyMapRepository();

  @override
  JourneyMapTree loadTree() => JourneyMapTree(StPaulMapDataset.roots);

  @override
  List<String?> loadSlideshow() => StPaulMapDataset.slideshow;

  @override
  List<NonGeographicGroup> loadNonGeographicGroups() =>
      StPaulMapDataset.nonGeographicGroups;
}
