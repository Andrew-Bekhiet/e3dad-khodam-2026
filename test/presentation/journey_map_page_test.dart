import 'package:e3dad_khodam_2026/src/data/static_journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/pages/journey_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final class JourneyMapPageTest extends StatelessWidget {
  const JourneyMapPageTest();

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<JourneyMapRepository>.value(
        value: const StaticJourneyMapRepository(),
      ),
      RepositoryProvider<MapSurfaceBuilder>.value(value: _blankSurface),
    ],
    child: const MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: JourneyMapPage(),
      ),
    ),
  );
}

final class _BlankSurface extends StatelessWidget {
  const _BlankSurface(this.spec);

  final MapSurfaceSpec spec;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

const MapSurfaceBuilder _blankSurface = _BlankSurface.new;

MapHierarchyCubit _cubitOf(WidgetTester tester) =>
    tester.element(find.byType(Scaffold)).read<MapHierarchyCubit>();

void main() {
  testWidgets('JourneyMapPage_arrowKeys_stepTheCrossMapInRtl', (tester) async {
    await tester.pumpWidget(const JourneyMapPageTest());
    await tester.pump();

    final cubit = _cubitOf(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();

    expect(cubit.state.focusedNode?.id, 'continents');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(cubit.state.isAtRoot, isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);

    expect(cubit.state.focusedNode?.id, 'asia');
  });

  testWidgets('JourneyMapPage_usesTheProjectorLabelScale', (tester) async {
    await tester.pumpWidget(const JourneyMapPageTest());
    await tester.pump();

    final cubit = _cubitOf(tester);
    cubit.drillDown('seas');
    await tester.pump();
    await tester.pump();

    final surface = tester
        .widgetList<_BlankSurface>(find.byType(_BlankSurface))
        .last;
    final longestLabel = surface.spec.markers.singleWhere(
      (marker) => marker.label == 'البحر المتوسط',
    );
    final camera = surface.spec.camera as FitBoundsCameraTarget;

    expect(longestLabel.style.label.fontSize, 34);
    expect(camera.padding.left, greaterThanOrEqualTo(138));
    expect(camera.padding.right, greaterThanOrEqualTo(138));
  });
}
