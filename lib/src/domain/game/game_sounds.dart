/// Plays the game's sound effects.
///
/// An interface with a silent default because none of the audio is in the
/// repository yet: every call site below already fires at the exact moment
/// its sound belongs, so dropping the files in later is a one-class change
/// with no call-site edits.
///
/// Deliberately free of any audio package. A real implementation holds a
/// player and therefore native resources, which is why it lives outside
/// `domain/` and why [GameSounds] says nothing about how a sound is made.
abstract interface class GameSounds {
  /// Plays the "level cleared" sting, once, when a level is passed.
  void playLevelCleared();

  /// Plays the arrival sting, once, when the party lands somewhere new.
  void playLevelReached();

  /// Plays the departure sting, once, as the party sets off.
  void playDeparture();

  /// Starts the travelling loop, and keeps it running until
  /// [stopWalking]. Calling it while it already runs changes nothing.
  void startWalking();

  /// Stops the travelling loop. Safe to call when nothing is playing —
  /// every path that can end a journey calls it, including the ones that
  /// cut one short.
  void stopWalking();
}

/// The no-op [GameSounds] used until the audio files arrive.
final class SilentGameSounds implements GameSounds {
  /// Creates the silent player.
  const SilentGameSounds();

  @override
  void playLevelCleared() {
    // Intentionally silent — see [GameSounds].
  }

  @override
  void playLevelReached() {
    // Intentionally silent — see [GameSounds].
  }

  @override
  void playDeparture() {
    // Intentionally silent — see [GameSounds].
  }

  @override
  void startWalking() {
    // Intentionally silent — see [GameSounds].
  }

  @override
  void stopWalking() {
    // Intentionally silent — see [GameSounds].
  }
}
