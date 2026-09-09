import 'package:e3dad_khodam_2026/src/presentation/stage/step_keys.dart';
import 'package:flutter/widgets.dart';

/// Wraps [child] in the keyboard focus every step-driven screen needs:
/// autofocused, routing left/space/enter/down to [onForward] and
/// right/backspace/up to [onBackward].
final class StepFocus extends StatelessWidget {
  final FocusNode focusNode;
  final VoidCallback onForward;
  final VoidCallback onBackward;
  final Widget child;

  /// Creates the focus wrapper.
  const StepFocus({
    required this.focusNode,
    required this.onForward,
    required this.onBackward,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: focusNode,
    autofocus: true,
    onKeyEvent: (node, event) => StepKeys.onKeyEvent(
      event,
      onForward: onForward,
      onBackward: onBackward,
    ),
    child: child,
  );
}
