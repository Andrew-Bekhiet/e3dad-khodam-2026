import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/platform_view_interceptor.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/map_arrow_controls.dart';
import 'package:flutter/widgets.dart';

/// The game's step arrows, isolated from the platform map behind them.
final class GameStepControls extends StatelessWidget {
  /// Steps the script back.
  final VoidCallback onBackward;

  /// Steps the script forward.
  final VoidCallback onForward;

  /// Whether there is a previous position.
  final bool canGoBackward;

  /// Whether there is a following position.
  final bool canGoForward;

  /// Creates the game step controls.
  const GameStepControls({
    required this.onBackward,
    required this.onForward,
    required this.canGoBackward,
    required this.canGoForward,
    super.key,
  });

  @override
  Widget build(BuildContext context) => PlatformViewInterceptor(
    child: PixelPanel(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: MapArrowControls(
        onBackward: onBackward,
        onForward: onForward,
        canGoBackward: canGoBackward,
        canGoForward: canGoForward,
      ),
    ),
  );
}
