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
import 'package:flutter_bloc/flutter_bloc.dart';

/// The app's single screen: owns the [MapHierarchyCubit], the app bar
/// (static title at the root, `" / "`-joined breadcrumb once drilled in,
/// per spec §6/§9), and routes the Android system-back gesture through
/// [MapHierarchyCubit.goBack] instead of closing the app.
final class JourneyMapPage extends StatelessWidget {
  static const Duration _titleSwitchDuration = Duration(milliseconds: 200);
  static const double _rootTitleFontSize = 20.0;
  static const double _breadcrumbFontSize = 16.0;
  static const String _breadcrumbSeparator = ' / ';

  /// Creates the journey map page.
  const JourneyMapPage({super.key});

  static String? _breadcrumbText(List<String> ancestorLabels) =>
      ancestorLabels.isEmpty ? null : ancestorLabels.join(_breadcrumbSeparator);

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        MapHierarchyCubit(context.read<JourneyMapRepository>()),
    child: BlocBuilder<MapHierarchyCubit, MapHierarchyState>(
      builder: (context, state) {
        final cubit = context.read<MapHierarchyCubit>();

        final breadcrumbText = _breadcrumbText(
          state.breadcrumb.map((node) => node.label).toList(growable: false),
        );

        return PopScope(
          canPop: state.isAtRoot,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;

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
                duration: _titleSwitchDuration,
                child: Text(
                  breadcrumbText ?? AppStrings.appTitle,
                  key: ValueKey(breadcrumbText ?? AppStrings.appTitle),
                  style: TextStyle(
                    fontSize: breadcrumbText == null
                        ? _rootTitleFontSize
                        : _breadcrumbFontSize,
                    fontWeight: breadcrumbText == null
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.videogame_asset_outlined),
                  tooltip: AppStrings.gameTitle,
                  onPressed: () => _openGame(context),
                ),
                if (AppFeatures.showNonGeographicGroups)
                  IconButton(
                    icon: const Icon(Icons.people_outline),
                    tooltip: AppStrings.nonGeographicSheetTitle,
                    onPressed: () => _showNonGeographicSheet(context),
                  ),
              ],
            ),
            body: Stack(
              fit: StackFit.expand,
              alignment: AlignmentDirectional.center,
              children: [
                const JourneyMapView(),
                PositionedDirectional(
                  end: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: MapArrowControls(
                      onBackward: cubit.backward,
                      onForward: cubit.forward,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
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
