import 'package:e3dad_khodam_2026/src/app/app_features.dart';
import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/pages/game_journey_page.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/journey_map_view.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/map_arrow_controls.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/non_geographic_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The app's single screen: owns the [MapHierarchyCubit], the app bar
/// (static title at the root, `" / "`-joined breadcrumb once drilled in,
/// per spec §6/§9), and routes the Android system-back gesture through
/// [MapHierarchyCubit.goBack] instead of closing the app.
final class JourneyMapPage extends StatelessWidget {
  static const Duration _titleSwitchDuration = Duration(milliseconds: 200);
  static const String _breadcrumbSeparator = ' / ';

  /// Creates the journey map page.
  const JourneyMapPage({super.key});

  static String? _breadcrumbText(List<String> ancestorLabels) =>
      ancestorLabels.isEmpty ? null : ancestorLabels.join(_breadcrumbSeparator);

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        MapHierarchyCubit(context.read<JourneyMapRepository>()),
    child: const _JourneyMapView(),
  );

  /// Opens the guided game. It reads its script and map provider from the
  /// same ambient providers this page does, so the route needs nothing
  /// passed into it.
  static void _openGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GameJourneyPage()),
    );
  }

  static void _showNonGeographicSheet(BuildContext context) {
    final groups = context
        .read<JourneyMapRepository>()
        .loadNonGeographicGroups();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => NonGeographicSheet(groups: groups),
    );
  }
}

/// The Cross Map body, split out so its focus node survives map surface
/// updates while the hierarchy cubit emits new camera targets.
final class _JourneyMapView extends StatefulWidget {
  const _JourneyMapView();

  @override
  State<_JourneyMapView> createState() => _JourneyMapViewState();
}

final class _JourneyMapViewState extends State<_JourneyMapView> {
  static final Set<LogicalKeyboardKey> _forwardKeys = Set.unmodifiable([
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.arrowDown,
  ]);
  static final Set<LogicalKeyboardKey> _backwardKeys = Set.unmodifiable([
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.backspace,
    LogicalKeyboardKey.arrowUp,
  ]);

  final FocusNode _focusNode = FocusNode(debugLabel: 'journey-map-keys');

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MapHierarchyCubit, MapHierarchyState>(
        builder: (context, state) {
          final cubit = context.read<MapHierarchyCubit>();
          final breadcrumbText = JourneyMapPage._breadcrumbText(
            state.breadcrumb.map((node) => node.label).toList(growable: false),
          );

          return PopScope(
            canPop: state.isAtRoot,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) {
                return;
              }
              cubit.goBack();
            },
            child: Scaffold(
              appBar: AppBar(
                leading: state.isAtRoot
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: AppStrings.backButtonTooltip,
                        onPressed: cubit.goBack,
                      ),
                title: AnimatedSwitcher(
                  duration: JourneyMapPage._titleSwitchDuration,
                  child: Text(
                    breadcrumbText ?? AppStrings.appTitle,
                    key: ValueKey(breadcrumbText ?? AppStrings.appTitle),
                    style: breadcrumbText == null
                        ? TextTheme.of(
                            context,
                          ).titleLarge?.copyWith(fontWeight: FontWeight.w700)
                        : TextTheme.of(
                            context,
                          ).titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.videogame_asset_outlined),
                    tooltip: AppStrings.gameTitle,
                    onPressed: () => JourneyMapPage._openGame(context),
                  ),
                  if (AppFeatures.showNonGeographicGroups)
                    IconButton(
                      icon: const Icon(Icons.people_outline),
                      tooltip: AppStrings.nonGeographicSheetTitle,
                      onPressed: () => JourneyMapPage._showNonGeographicSheet(
                        context,
                      ),
                    ),
                ],
              ),
              body: Focus(
                focusNode: _focusNode,
                autofocus: true,
                onKeyEvent: (_, event) => _onKeyEvent(cubit, event),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: AlignmentDirectional.center,
                  children: [
                    const JourneyMapView(),
                    PositionedDirectional(
                      end: 16,
                      bottom: 16,
                      child: SafeArea(
                        child: MapArrowControls(
                          onBackward: () => _step(cubit, forward: false),
                          onForward: () => _step(cubit, forward: true),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(MapHierarchyCubit cubit, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    switch (_stepForKey(event.logicalKey)) {
      case _MapStep.forward:
        _step(cubit, forward: true);
      case _MapStep.backward:
        _step(cubit, forward: false);
      case null:
        return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  _MapStep? _stepForKey(LogicalKeyboardKey key) {
    if (_forwardKeys.contains(key)) {
      return _MapStep.forward;
    }
    if (_backwardKeys.contains(key)) {
      return _MapStep.backward;
    }

    return null;
  }

  void _step(MapHierarchyCubit cubit, {required bool forward}) {
    _focusNode.requestFocus();
    if (forward) {
      cubit.forward();

      return;
    }
    cubit.backward();
  }
}

enum _MapStep { forward, backward }
