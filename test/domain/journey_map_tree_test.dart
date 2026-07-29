import 'package:collection/collection.dart';
import 'package:e3dad_khodam_2026/src/data/static_journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Read-only fixture: nothing under test mutates the tree, so one shared
  // instance is safe across every test below without `setUp`/`late`.
  const repository = StaticJourneyMapRepository();
  final tree = repository.loadTree();

  List<MapNode> collectAllNodes(Iterable<MapNode> nodes) => [
    for (final node in nodes) ...[node, ...collectAllNodes(node.children)],
  ];

  test('JourneyMapTree_allNodeIds_areUnique', () {
    final ids = collectAllNodes(tree.roots).map((node) => node.id).toList();
    final duplicates = groupBy(ids, (id) => id).entries
        .where((entry) => entry.value.length > 1)
        .map((entry) => entry.key);

    expect(duplicates, isEmpty);
  });

  test('JourneyMapTree_rootCategories_coverAllFourCrossArmsOnce', () {
    final arms = tree.roots
        .whereType<CategoryNode>()
        .map((node) => node.arm)
        .toList();

    expect(arms.length, CrossArm.values.length);
    expect(arms.toSet(), CrossArm.values.toSet());
  });

  test('JourneyMapTree_findById_returnsDeepNodeByExactId', () {
    final node = tree.findById('colossae');

    expect(node?.id, 'colossae');
    expect(node?.label, 'كولوسي');
  });

  test('JourneyMapTree_findById_returnsNullForUnknownId', () {
    expect(tree.findById('atlantis'), isNull);
  });

  test('JourneyMapTree_pathTo_returnsFullAncestorChainInOrder', () {
    final path = tree.pathTo('colossae').map((node) => node.id).toList();

    expect(path, ['countries', 'asia_minor', 'colossae']);
  });

  test('JourneyMapTree_childrenOfNull_returnsFourRoots', () {
    final ids = tree.childrenOf(null).map((node) => node.id).toSet();

    expect(ids, {'continents', 'countries', 'seas', 'islands'});
  });

  test('JourneyMapTree_childrenOfGreece_returnsThreeGreekCities', () {
    final ids = tree.childrenOf('greece').map((node) => node.id).toList();

    expect(ids, ['philippi', 'corinth', 'thessalonica']);
  });

  test('JourneyMapTree_childrenOfLeafCity_returnsEmpty', () {
    expect(tree.childrenOf('rome'), isEmpty);
  });

  test('JourneyMapTree_everyCityNode_isLeaf', () {
    final cityNodes = collectAllNodes(
      tree.roots,
    ).whereType<PlaceNode>().where((node) => node.kind == PlaceKind.city);

    for (final city in cityNodes) {
      expect(city.children, isEmpty, reason: 'city ${city.id} has children');
    }
  });

  test('JourneyMapTree_knownParents_haveExpectedChildCounts', () {
    const expectedCounts = {
      'continents': 3,
      'countries': 3,
      'seas': 3,
      'islands': 3,
      'asia_minor': 3,
      'greece': 3,
      'italy': 1,
    };

    for (final entry in expectedCounts.entries) {
      final node = tree.findById(entry.key);
      expect(
        node?.children.length,
        entry.value,
        reason: 'unexpected child count for ${entry.key}',
      );
    }
  });

  test('JourneyMapTree_everyNodePosition_isWithinMediterraneanEnvelope', () {
    final positions = collectAllNodes(
      tree.roots,
    ).map((node) => node.position);

    for (final position in positions) {
      expect(position.latitude, inInclusiveRange(29.0, 48.0));
      expect(position.longitude, inInclusiveRange(5.0, 40.0));
    }
  });

  test('JourneyMapTree_depthFirstNodes_matchesExactPreOrderSequence', () {
    final ids = tree.depthFirstNodes.map((node) => node.id).toList();

    // Also pins length (23), first id ('continents') and last id
    // ('malta'), since a full-sequence match implies all three.
    expect(ids, [
      'continents',
      'asia',
      'africa',
      'europe',
      'countries',
      'asia_minor',
      'galatia',
      'ephesus',
      'colossae',
      'greece',
      'philippi',
      'corinth',
      'thessalonica',
      'italy',
      'rome',
      'seas',
      'mediterranean_sea',
      'aegean_sea',
      'adriatic_sea',
      'islands',
      'crete',
      'cyprus',
      'malta',
    ]);
  });

  test('JourneyMapTree_depthFirstNodes_hasNoDuplicateNodes', () {
    final ids = tree.depthFirstNodes.map((node) => node.id).toList();

    expect(ids.toSet().length, ids.length);
  });
}
