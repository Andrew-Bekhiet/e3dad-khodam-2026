/// Plays the game's sound effects.
///
/// An interface with a silent default because the clearance jingle is not
/// in the repository yet: the cubit already calls [playLevelCleared] at
/// the exact moment the sound belongs, so dropping the file in later is a
/// one-class change with no call-site edits.
abstract interface class GameSounds {
  /// Plays the "level cleared" sting, once, when a level is passed.
  void playLevelCleared();
}

/// The no-op [GameSounds] used until the audio file arrives.
final class SilentGameSounds implements GameSounds {
  /// Creates the silent player.
  const SilentGameSounds();

  @override
  void playLevelCleared() {
    // Intentionally silent — see [GameSounds].
  }
}
