import 'package:e3dad_khodam_2026/src/data/continents_branch.dart';
import 'package:e3dad_khodam_2026/src/data/countries_branch.dart';
import 'package:e3dad_khodam_2026/src/data/islands_branch.dart';
import 'package:e3dad_khodam_2026/src/data/seas_branch.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/non_geographic_group.dart';

/// The complete, compile-time-constant St Paul journey-map dataset: the
/// four-armed root hierarchy plus the recipient groups that have no map
/// location.
final class StPaulMapDataset {
  /// The four root category nodes, forming the cross layout (top, bottom,
  /// left, right) once placed on the map.
  static const List<MapNode> roots = [
    ContinentsBranch.node,
    CountriesBranch.node,
    SeasBranch.node,
    IslandsBranch.node,
  ];

  /// The order the arrow keys walk the map in: each category is shown and
  /// then the cross comes back, so every arm is read against the whole,
  /// before the three countries' cities close the tour. `null` is the
  /// root cross.
  static const List<String?> slideshow = [
    null,
    'continents',
    null,
    'countries',
    null,
    'seas',
    null,
    'islands',
    null,
    'asia_minor',
    'greece',
    'italy',
  ];

  /// Epistle recipients addressed as people or ethnic groups rather than
  /// places, shown outside the map.
  static const List<NonGeographicGroup> nonGeographicGroups = [
    NonGeographicGroup(
      label: 'أشخاص',
      members: ['تيموثاوس', 'تيطس', 'فليمون'],
    ),
    NonGeographicGroup(
      label: 'العبرانيين',
      members: ['اليهود'],
    ),
  ];
}
