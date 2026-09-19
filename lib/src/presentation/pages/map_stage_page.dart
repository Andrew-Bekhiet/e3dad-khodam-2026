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
import 'package:flutter/services.dart';
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
  bool _blackedOut = false;
  bool _beaconFlashing = true;

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
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onStageKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Scaffold(
              appBar: AppBar(
                centerTitle: false,
                title: Text(_selected.label),
                bottom: _ScriptButtons(selected: _selected, onSelect: _select),
              ),
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
            if (_blackedOut)
              const PlatformViewInterceptor(
                child: SizedBox.expand(child: ColoredBox(color: Colors.black)),
              ),
          ],
        ),
      ),
    );
  }

  /// Stage-wide keys, reached only after `StepFocus` ignores an event:
  /// `.`/`b` blackout, `f` beacon flash, `1`–`4` pick a script.
  KeyEventResult _onStageKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.period || key == LogicalKeyboardKey.keyB) {
      setState(() => _blackedOut = !_blackedOut);

      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyF) {
      _setBeaconFlashing(!_beaconFlashing);

      return KeyEventResult.handled;
    }
    final script = _scriptForKey(key);
    if (script == null) {
      return KeyEventResult.ignored;
    }
    _select(script);

    return KeyEventResult.handled;
  }

  MapScript? _scriptForKey(LogicalKeyboardKey key) => switch (key) {
    LogicalKeyboardKey.digit1 ||
    LogicalKeyboardKey.numpad1 => MapScript.crossMap,
    LogicalKeyboardKey.digit2 ||
    LogicalKeyboardKey.numpad2 => MapScript.secondJourney,
    LogicalKeyboardKey.digit3 ||
    LogicalKeyboardKey.numpad3 => MapScript.thirdJourney,
    LogicalKeyboardKey.digit4 ||
    LogicalKeyboardKey.numpad4 => MapScript.romeJourney,
    _ => null,
  };

  void _setBeaconFlashing(bool value) {
    _beaconFlashing = value;
    for (final presenter in _presenters.values) {
      if (presenter is HistoricalJourneyPresenter) {
        presenter.isBeaconFlashing = value;
      }
    }
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
  )..isBeaconFlashing = _beaconFlashing;
}

/// The five script buttons, pinned to the stage's physical top-left —
/// `Positioned(top:, left:)`, not `PositionedDirectional`, so they hold
/// their corner regardless of the app's RTL layout.
final class _ScriptButtons extends StatelessWidget
    implements PreferredSizeWidget {
  final MapScript selected;
  final void Function(MapScript script) onSelect;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  const _ScriptButtons({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => PlatformViewInterceptor(
    child: PixelPanel(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final script in MapScript.values)
              if (script != MapScript.postOfficeGame)
                _ScriptButton(
                  script: script,
                  isSelected: script == selected,
                  onPressed: () => onSelect(script),
                ),
          ],
        ),
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
      child: Text(script.shortLabel, style: TextTheme.of(context).labelMedium),
    );
  }
}
