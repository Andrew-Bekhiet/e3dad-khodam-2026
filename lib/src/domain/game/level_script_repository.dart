import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';

/// Source of the guided playthrough's script. Synchronous for the same
/// reason `JourneyMapRepository` is: the script is a compile-time
/// constant, not a network or disk resource.
abstract interface class LevelScriptRepository {
  /// Loads the full ordered script: prologue, levels, epilogue.
  LevelScript loadLevelScript();
}
