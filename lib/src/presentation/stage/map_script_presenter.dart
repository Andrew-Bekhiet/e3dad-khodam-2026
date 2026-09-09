import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:flutter/widgets.dart';

/// Renders a script's overlay chrome for the current [BuildContext].
///
/// A function type rather than an abstract method returning `Widget` —
/// see `MapSurfaceBuilder`'s own doc for why: `avoid_returning_widgets`
/// exempts only `@override`, and a method returning a widget is
/// functionally a callback anyway, so [MapScriptPresenter.buildOverlay]
/// exposes one instead of returning a widget directly.
typedef ScriptOverlayBuilder = Widget Function(BuildContext context);

/// One script the map stage can show: what the surface should draw, its
/// own overlay chrome, and how it walks forward and backward.
///
/// A [ChangeNotifier] rather than a bare `Listenable`: every implementation
/// needs to notify on its own cubit's emissions and its own clocks, and
/// `ChangeNotifier` is the listener bookkeeping and `dispose()` contract
/// they would otherwise each reimplement.
///
/// `canPop` and `onPopBlocked` exist for the cross map alone, which is the
/// only script with an internal drill-down stack the Android back gesture
/// should unwind one level at a time before it is allowed to leave the
/// stage; every other script accepts the default and never blocks a pop.
abstract base class MapScriptPresenter extends ChangeNotifier {
  /// Whether [forward] currently has anywhere to go.
  bool get canGoForward;

  /// Whether [backward] currently has anywhere to go — named to pair with
  /// [canGoForward] rather than for its own alphabetical place.
  bool get canGoBackward;

  /// Whether a system back gesture should be allowed to leave the stage.
  bool get canPop => true;

  /// Chrome specific to this script, drawn over the shared map surface.
  /// Most scripts have none — return `(_) => const SizedBox.shrink()`.
  ScriptOverlayBuilder get buildOverlay;

  /// The map content this script wants drawn right now.
  MapSurfaceSpec buildSpec(BuildContext context);

  /// Steps the script forward one position.
  void forward();

  /// Steps the script backward one position.
  void backward();

  /// Called when a system back gesture was blocked by [canPop]; only ever
  /// invoked while it returns false. Empty for every script but the cross
  /// map, which is the only one that ever returns false from [canPop].
  void onPopBlocked() {
    // Nothing to unwind by default — see the class doc.
  }
}
