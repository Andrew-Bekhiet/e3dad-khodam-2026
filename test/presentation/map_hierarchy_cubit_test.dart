import 'package:bloc_test/bloc_test.dart';
import 'package:e3dad_khodam_2026/src/data/static_journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The dataset is a compile-time constant, so a real repository exercises
  // exactly the same tree every test would get from a mock — mocking it
  // would only add indirection, not isolation.
  const repository = StaticJourneyMapRepository();

  // Pins the exact fixed root camera the cubit is documented to always
  // return at the root cross; mirrors MapHierarchyCubit's own private
  // `_rootBounds`/`_fitPadding` constants.
  const rootCamera = FitBoundsCameraTarget(
    bounds: GeoBounds(south: 30.89, west: 10.00, north: 43.57, east: 26.00),
    padding: EdgeInsets.only(top: 100, left: 84, right: 84, bottom: 56),
  );

  test('MapHierarchyCubit_construction_startsAtRootWithFourCategories', () {
    final cubit = MapHierarchyCubit(repository);
    addTearDown(cubit.close);

    expect(cubit.state.isAtRoot, isTrue);
    expect(cubit.state.breadcrumb, isEmpty);
    expect(
      cubit.state.visibleNodes.map((node) => node.id).toList(),
      ['continents', 'countries', 'seas', 'islands'],
    );
    expect(cubit.state.camera, equals(rootCamera));
  });

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_drillDownIntoCategory_showsChildrenAndBreadcrumb',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) => cubit.drillDown('countries'),
    expect: () => [
      isA<MapHierarchyState>()
          .having(
            (state) => state.visibleNodes.map((node) => node.id).toList(),
            'visible node ids',
            ['asia_minor', 'greece', 'italy'],
          )
          .having(
            (state) => state.breadcrumb.map((node) => node.id).toList(),
            'breadcrumb ids',
            ['countries'],
          ),
    ],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_drillDownTwoLevels_showsCitiesAndFocusesParent',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) {
      cubit.drillDown('countries');
      cubit.drillDown('asia_minor');
    },
    skip: 1,
    expect: () => [
      isA<MapHierarchyState>()
          .having(
            (state) => state.visibleNodes.map((node) => node.id).toList(),
            'visible city ids',
            ['galatia', 'ephesus', 'colossae'],
          )
          .having(
            (state) => state.breadcrumb.map((node) => node.id).toList(),
            'breadcrumb ids',
            ['countries', 'asia_minor'],
          )
          .having(
            (state) => state.focusedNode?.id,
            'focused node id',
            'asia_minor',
          ),
    ],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_drillDownOnLeafCity_emitsNothing',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) => cubit.drillDown('rome'),
    expect: () => <MapHierarchyState>[],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_drillDownOnUnknownId_emitsNothing',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) => cubit.drillDown('atlantis'),
    expect: () => <MapHierarchyState>[],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_goBackFromDepthOne_returnsToRoot',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) {
      cubit.drillDown('countries');
      cubit.goBack();
    },
    skip: 1,
    expect: () => [
      isA<MapHierarchyState>()
          .having((state) => state.isAtRoot, 'isAtRoot', isTrue)
          .having((state) => state.breadcrumb, 'breadcrumb', isEmpty)
          .having((state) => state.camera, 'camera', equals(rootCamera)),
    ],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_goBackFromDepthTwo_returnsToDepthOne',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) {
      cubit.drillDown('countries');
      cubit.drillDown('asia_minor');
      cubit.goBack();
    },
    skip: 2,
    expect: () => [
      isA<MapHierarchyState>()
          .having(
            (state) => state.breadcrumb.map((node) => node.id).toList(),
            'breadcrumb ids',
            ['countries'],
          )
          .having(
            (state) => state.visibleNodes.map((node) => node.id).toList(),
            'visible node ids',
            ['asia_minor', 'greece', 'italy'],
          ),
    ],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_goBackAtRoot_emitsNothing',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) => cubit.goBack(),
    expect: () => <MapHierarchyState>[],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_resetFromDepthTwo_returnsToRootInOneEmission',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) {
      cubit.drillDown('countries');
      cubit.drillDown('asia_minor');
      cubit.reset();
    },
    skip: 2,
    expect: () => [
      isA<MapHierarchyState>()
          .having((state) => state.isAtRoot, 'isAtRoot', isTrue)
          .having((state) => state.breadcrumb, 'breadcrumb', isEmpty),
    ],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_drillDownToSingleChildCountry_hasNonDegenerateBounds',
    build: () => MapHierarchyCubit(repository),
    act: (cubit) => cubit.drillDown('italy'),
    expect: () => [
      isA<MapHierarchyState>().having(
        (state) => state.camera,
        'camera',
        isA<FitBoundsCameraTarget>().having(
          (camera) =>
              camera.bounds.north != camera.bounds.south &&
              camera.bounds.east != camera.bounds.west,
          'non-degenerate bounds',
          isTrue,
        ),
      ),
    ],
  );
}
