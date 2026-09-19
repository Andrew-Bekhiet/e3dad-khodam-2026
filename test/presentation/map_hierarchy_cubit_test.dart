import 'package:bloc_test/bloc_test.dart';
import 'package:e3dad_khodam_2026/src/data/static_journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The dataset is a compile-time constant, so a real repository exercises
// exactly the same tree every test would get from a mock — mocking it
// would only add indirection, not isolation.
const _repository = StaticJourneyMapRepository();

// Pins the exact fixed root camera the cubit is documented to always
// return at the root cross; mirrors MapHierarchyCubit's own private
// `_rootBounds`/`_fitPadding` constants.
const _rootCamera = FitBoundsCameraTarget(
  bounds: GeoBounds(south: 28.5, west: 15.0, north: 46.5, east: 37.0),
  padding: EdgeInsets.only(top: 100, left: 144, right: 144, bottom: 144),
);

/// Matches a [MapHierarchyState] back at the root cross — shared by the
/// tests that return to it via different paths ([MapHierarchyCubit.reset],
/// wrapping [MapHierarchyCubit.backward] past the first depth-first node).
Matcher _isRootState() => isA<MapHierarchyState>()
    .having((state) => state.isAtRoot, 'isAtRoot', isTrue)
    .having((state) => state.breadcrumb, 'breadcrumb', isEmpty);

void main() {
  _constructionAndDrillDownTests();
  _goBackAndResetTests();
  _traversalTests();
}

void _constructionAndDrillDownTests() {
  test('MapHierarchyCubit_construction_startsAtRootWithFourCategories', () {
    final cubit = MapHierarchyCubit(_repository);
    addTearDown(cubit.close);

    expect(cubit.state.isAtRoot, isTrue);
    expect(cubit.state.breadcrumb, isEmpty);
    expect(
      cubit.state.visibleNodes.map((node) => node.id).toList(),
      ['continents', 'countries', 'seas', 'islands'],
    );
    expect(cubit.state.camera, equals(_rootCamera));
  });

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_drillDownIntoCategory_showsChildrenAndBreadcrumb',
    build: () => MapHierarchyCubit(_repository),
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
    build: () => MapHierarchyCubit(_repository),
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
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) => cubit.drillDown('rome'),
    expect: () => <MapHierarchyState>[],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_drillDownOnUnknownId_emitsNothing',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) => cubit.drillDown('atlantis'),
    expect: () => <MapHierarchyState>[],
  );
}

void _goBackAndResetTests() {
  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_goBackFromDepthOne_returnsToRoot',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) {
      cubit.drillDown('countries');
      cubit.goBack();
    },
    skip: 1,
    expect: () => [
      isA<MapHierarchyState>()
          .having((state) => state.isAtRoot, 'isAtRoot', isTrue)
          .having((state) => state.breadcrumb, 'breadcrumb', isEmpty)
          .having((state) => state.camera, 'camera', equals(_rootCamera)),
    ],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_goBackFromDepthTwo_returnsToDepthOne',
    build: () => MapHierarchyCubit(_repository),
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
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) => cubit.goBack(),
    expect: () => <MapHierarchyState>[],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_resetFromDepthTwo_returnsToRootInOneEmission',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) {
      cubit.drillDown('countries');
      cubit.drillDown('asia_minor');
      cubit.reset();
    },
    skip: 2,
    expect: () => [_isRootState()],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_drillDownToSingleChildCountry_hasNonDegenerateBounds',
    build: () => MapHierarchyCubit(_repository),
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

/// The ids [MapHierarchyCubit.forward] focuses in turn from the root
/// cross, `null` being the cross itself.
const List<String?> _slideshow = [
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
  null,
];

Matcher _focuses(String? id) => id == null
    ? _isRootState()
    : isA<MapHierarchyState>().having(
        (state) => state.focusedNode?.id,
        'focused node id',
        id,
      );

void _traversalTests() {
  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_forwardFromOverview_walksSlideshowAndWraps',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) {
      for (var i = 0; i < _slideshow.length; i++) {
        cubit.forward();
      }
    },
    expect: () => _slideshow.map(_focuses).toList(),
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_forwardIntoContinents_showsItsChildren',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) => cubit.forward(),
    expect: () => [
      isA<MapHierarchyState>()
          .having(
            (state) => state.visibleNodes.map((node) => node.id).toList(),
            'visible node ids',
            ['asia', 'africa', 'europe'],
          )
          .having(
            (state) => state.breadcrumb.map((node) => node.id).toList(),
            'breadcrumb ids',
            ['continents'],
          ),
    ],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_backwardFromOverview_walksSlideshowReversed',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) {
      for (var i = 0; i < _slideshow.length; i++) {
        cubit.backward();
      }
    },
    expect: () => _slideshow.reversed.skip(1).map(_focuses).toList()
      ..add(_isRootState()),
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_forwardAfterDrillDown_continuesFromThatSlide',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) {
      cubit.drillDown('seas');
      cubit.forward();
      cubit.forward();
    },
    skip: 1,
    expect: () => [_isRootState(), _focuses('islands')],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_forwardFromNodeOffSlideshow_continuesFromAncestor',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) {
      cubit.drillDown('countries');
      cubit.drillDown('asia_minor');
      cubit.forward();
    },
    skip: 2,
    expect: () => [_focuses('greece')],
  );

  blocTest<MapHierarchyCubit, MapHierarchyState>(
    'MapHierarchyCubit_forwardThenBackward_returnsToSameState',
    build: () => MapHierarchyCubit(_repository),
    act: (cubit) {
      cubit.drillDown('countries');
      cubit.forward();
      cubit.backward();
    },
    skip: 2,
    expect: () => [
      isA<MapHierarchyState>()
          .having(
            (state) => state.focusedNode?.id,
            'focused node id',
            'countries',
          )
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
}
