import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:flutter/material.dart';

/// The pair of on-screen step arrows shared by the reference map and the
/// game: left steps back, right steps forward, in that order.
///
/// The order is fixed rather than direction-aware so the two screens can
/// never disagree about which arrow does what — and so it matches the
/// left/right arrow keys, which are not mirrored in RTL either.
final class MapArrowControls extends StatelessWidget {
  /// Steps one position back.
  final VoidCallback onBackward;

  /// Steps one position forward.
  final VoidCallback onForward;

  /// Whether there is anything to step back to.
  final bool canGoBackward;

  /// Whether there is anything to step forward to.
  final bool canGoForward;

  /// Creates the arrow pair.
  const MapArrowControls({
    required this.onBackward,
    required this.onForward,
    this.canGoBackward = true,
    this.canGoForward = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_left),
        tooltip: AppStrings.backwardTooltip,
        onPressed: canGoBackward ? onBackward : null,
      ),
      IconButton(
        icon: const Icon(Icons.arrow_right),
        tooltip: AppStrings.forwardTooltip,
        onPressed: canGoForward ? onForward : null,
      ),
    ],
  );
}
