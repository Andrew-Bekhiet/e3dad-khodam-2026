import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Key classification shared by every screen that walks a script one step
/// at a time: left, space, enter and down move forward, right, backspace
/// and up move backward.
///
/// Not mirrored for RTL: these match the on-screen arrows, which are not
/// mirrored either.
final class StepKeys {
  /// Routes a key event to [onForward] or [onBackward], or ignores it.
  static KeyEventResult onKeyEvent(
    KeyEvent event, {
    required VoidCallback onForward,
    required VoidCallback onBackward,
  }) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (_isForward(key)) {
      onForward();

      return KeyEventResult.handled;
    }
    if (_isBackward(key)) {
      onBackward();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  static bool _isForward(LogicalKeyboardKey key) => switch (key) {
    LogicalKeyboardKey.arrowLeft ||
    LogicalKeyboardKey.space ||
    LogicalKeyboardKey.enter ||
    LogicalKeyboardKey.arrowDown => true,
    _ => false,
  };

  static bool _isBackward(LogicalKeyboardKey key) => switch (key) {
    LogicalKeyboardKey.arrowRight ||
    LogicalKeyboardKey.backspace ||
    LogicalKeyboardKey.arrowUp => true,
    _ => false,
  };

  const StepKeys._();
}
