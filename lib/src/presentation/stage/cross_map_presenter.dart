import 'dart:async';

import 'package:e3dad_khodam_2026/src/app/app_features.dart';
import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/map_script_presenter.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/journey_map_view.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/non_geographic_sheet.dart';
import 'package:flutter/material.dart';

/// Plays the Cross Map — the app's original reference hierarchy — on the
/// stage's shared map surface.
///
/// Never sweeps and never queues a press, unlike the historical journeys:
/// `MapHierarchyCubit.forward`/`.backward` always land immediately, so
/// there is nothing here for a `SweepStepQueue` to do.
final class CrossMapPresenter extends MapScriptPresenter {
  final MapHierarchyCubit _cubit;
  final JourneyMapRepository _repository;

  // Cancelled from `dispose`, not from the constructor that creates it —
  // the standard subscribe-in-constructor/cancel-in-dispose shape the
  // checker doesn't trace across methods.
  // ignore: cancel_subscriptions
  StreamSubscription<MapHierarchyState>? _subscription;

  @override
  bool get canGoForward => true;

  @override
  bool get canGoBackward => true;

  @override
  bool get canPop => _cubit.state.isAtRoot;

  @override
  ScriptOverlayBuilder get buildOverlay => (context) {
    if (!AppFeatures.showNonGeographicGroups) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: IconButton(
          icon: const Icon(Icons.people_outline),
          tooltip: AppStrings.nonGeographicSheetTitle,
          onPressed: () => _showNonGeographicSheet(context),
        ),
      ),
    );
  };

  /// Plays the hierarchy loaded from [repository].
  CrossMapPresenter({required JourneyMapRepository repository})
    : _cubit = MapHierarchyCubit(repository),
      _repository = repository {
    _subscription = _cubit.stream.listen((_) => notifyListeners());
  }

  @override
  MapSurfaceSpec buildSpec(BuildContext context) =>
      JourneyMapView.specFor(_cubit.state, onMarkerTap: _cubit.drillDown);

  @override
  void forward() => _cubit.forward();

  @override
  void backward() => _cubit.backward();

  @override
  void onPopBlocked() => _cubit.goBack();

  @override
  void dispose() {
    final subscription = _subscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    unawaited(_cubit.close());
    super.dispose();
  }

  void _showNonGeographicSheet(BuildContext context) {
    final groups = _repository.loadNonGeographicGroups();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => NonGeographicSheet(groups: groups),
    );
  }
}
