import 'package:e3dad_khodam_2026/src/data/history/historical_journeys.dart';
import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/presentation/pages/game_journey_page.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/cross_map_presenter.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/historical_journey_presenter.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/map_script.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/map_script_presenter.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/step_focus.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_step_controls.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/platform_view_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The app's home screen: one Mapbox surface shared by five scripts —
/// the Cross Map, Paul's second and third journeys, the voyage to رومية,
/// and the Post Office game — switched with the buttons this page pins
/// to the physical top-left of its body.
///
/// Switching a script only ever hands the surface a new `MapSurfaceSpec`:
/// the surface widget itself stays at one fixed slot in the tree across
/// every switch, so the platform view underneath it is never torn down.
/// The game is the one script that opens as its own route instead of
/// joining the shared surface — see `historical-journeys/CONTRACT.md`.
final class MapStagePage extends StatefulWidget {
  /// Creates the map stage.
  const MapStagePage({super.key});

  @override
  State<MapStagePage> createState() => _MapStagePageState();
}

class _MapStagePageState extends State<MapStagePage>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(debugLabel: 'map-stage-keys');
  final Map<MapScript, MapScriptPresenter> _presenters = {};
  MapScript _selected = MapScript.crossMap;

  MapScriptPresenter get _current => _presenterFor(_selected);

  @override
  Widget build(BuildContext context) {
    final presenter = _current;
    final surfaceBuilder = context.read<MapSurfaceBuilder>();

    return PopScope(
      canPop: presenter.canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        presenter.onPopBlocked();
      },
      child: Scaffold(
        appBar: AppBar(centerTitle: false, title: Text(_selected.label)),
        body: StepFocus(
          focusNode: _focusNode,
          onForward: _forward,
          onBackward: _backward,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ListenableBuilder(
                listenable: presenter,
                builder: (context, _) =>
                    surfaceBuilder(presenter.buildSpec(context)),
              ),
              presenter.buildOverlay(context),
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: _ScriptButtons(
                    selected: _selected,
                    onSelect: _select,
                  ),
                ),
              ),
              PositionedDirectional(
                end: 12,
                bottom: 12,
                child: SafeArea(
                  child: GameStepControls(
                    onBackward: _backward,
                    onForward: _forward,
                    canGoBackward: presenter.canGoBackward,
                    canGoForward: presenter.canGoForward,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final presenter in _presenters.values) {
      presenter.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _forward() {
    _focusNode.requestFocus();
    _current.forward();
  }

  void _backward() {
    _focusNode.requestFocus();
    _current.backward();
  }

  void _select(MapScript script) {
    if (script == MapScript.postOfficeGame) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const GameJourneyPage()));

      return;
    }
    if (script == _selected) {
      return;
    }
    setState(() => _selected = script);
    _focusNode.requestFocus();
  }

  MapScriptPresenter _presenterFor(MapScript script) =>
      _presenters.putIfAbsent(script, () => _createPresenter(script));

  MapScriptPresenter _createPresenter(MapScript script) => switch (script) {
    MapScript.crossMap => CrossMapPresenter(
      repository: context.read<JourneyMapRepository>(),
    ),
    MapScript.secondJourney => _historicalPresenter(
      HistoricalJourneys.secondJourney,
    ),
    MapScript.thirdJourney => _historicalPresenter(
      HistoricalJourneys.thirdJourney,
    ),
    MapScript.romeJourney => _historicalPresenter(
      HistoricalJourneys.romeJourney,
    ),
    MapScript.postOfficeGame => throw UnsupportedError(
      'the game opens as its own route and never joins the stage',
    ),
  };

  HistoricalJourneyPresenter _historicalPresenter(
    HistoricalJourney journey,
  ) => HistoricalJourneyPresenter(
    journey: journey,
    vsync: this,
    focusNode: _focusNode,
  );
}

/// The five script buttons, pinned to the stage's physical top-left —
/// `Positioned(top:, left:)`, not `PositionedDirectional`, so they hold
/// their corner regardless of the app's RTL layout.
final class _ScriptButtons extends StatelessWidget {
  final MapScript selected;
  final void Function(MapScript script) onSelect;

  const _ScriptButtons({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => PlatformViewInterceptor(
    child: PixelPanel(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final script in MapScript.values)
            _ScriptButton(
              script: script,
              isSelected: script == selected,
              onPressed: () => onSelect(script),
            ),
        ],
      ),
    ),
  );
}

final class _ScriptButton extends StatelessWidget {
  final MapScript script;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ScriptButton({
    required this.script,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isSelected ? colors.primary : colors.surface,
        foregroundColor: isSelected ? colors.onPrimary : colors.onSurface,
      ),
      child: Text(script.label, style: TextTheme.of(context).labelMedium),
    );
  }
}
