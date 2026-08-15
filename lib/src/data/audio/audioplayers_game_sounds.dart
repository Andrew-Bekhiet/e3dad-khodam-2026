import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';

/// [GameSounds] played through `audioplayers`.
///
/// Lives outside `domain/` because it holds players, and therefore native
/// resources: the interface it implements must stay free of any audio
/// package, exactly as the domain types stay free of the map SDK.
///
/// One player per sound rather than a pool. A pool exists to overlap a
/// sound with *itself* — a game firing the same shot ten times a second —
/// which this never does. Separate players still let a clearance sting
/// ring over the travelling loop, which is the only overlap that happens.
///
/// **The audio files do not exist yet.** Until they are added under
/// `assets/audio/` and declared in `pubspec.yaml`, [SilentGameSounds]
/// remains the default and nothing constructs this.
final class AudioPlayersGameSounds implements GameSounds {
  /// Looped while the party is travelling.
  static const String walkingAsset = 'audio/walking.mp3';

  /// Rung once when a level is passed.
  static const String levelClearedAsset = 'audio/level_cleared.mp3';

  /// Rung once when the party lands somewhere new.
  static const String levelReachedAsset = 'audio/level_reached.mp3';

  /// Rung once as the party sets off.
  static const String departureAsset = 'audio/departure.mp3';

  /// Loads every sound and returns a player ready to ring them.
  ///
  /// Sources are set up front rather than at each call: a sting fetched
  /// when it is wanted arrives after the moment it belonged to.
  static Future<AudioPlayersGameSounds> create() async =>
      AudioPlayersGameSounds._(
        await _prepare(walkingAsset, loop: true),
        await _prepare(levelClearedAsset),
        await _prepare(levelReachedAsset),
        await _prepare(departureAsset),
      );

  static Future<AudioPlayer> _prepare(String asset, {bool loop = false}) async {
    final player = AudioPlayer();
    // Deliberately not `PlayerMode.lowLatency`, tempting though it is for
    // game effects: that mode has no seeking and no playback-completion
    // event, so `_ring` could not rewind a sting that had already played
    // — each would sound once per session — and looping, which is built
    // on that event, would be unreliable.
    await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    await player.setSource(AssetSource(asset));

    return player;
  }

  /// Plays [player] from its start, whether or not it is already going.
  ///
  /// Unawaited at the call sites on purpose, and safe to be: these fire
  /// once per press or once per journey, never once per frame, so nothing
  /// can queue up behind them.
  static Future<void> _ring(AudioPlayer player) async {
    await player.seek(Duration.zero);
    await player.resume();
  }

  final AudioPlayer _walking;
  final AudioPlayer _levelCleared;
  final AudioPlayer _levelReached;
  final AudioPlayer _departure;

  bool _isWalking = false;

  /// Takes its players positionally because a named parameter may not
  /// start with an underscore, and these fields are private. The only
  /// caller is [create], directly above, where the order is plain.
  AudioPlayersGameSounds._(
    this._walking,
    this._levelCleared,
    this._levelReached,
    this._departure,
  );

  @override
  void playLevelCleared() => unawaited(_ring(_levelCleared));

  @override
  void playLevelReached() => unawaited(_ring(_levelReached));

  @override
  void playDeparture() => unawaited(_ring(_departure));

  @override
  void startWalking() {
    if (_isWalking) {
      return;
    }
    _isWalking = true;
    unawaited(_ring(_walking));
  }

  @override
  void stopWalking() {
    if (!_isWalking) {
      return;
    }
    _isWalking = false;
    unawaited(_walking.stop());
  }

  /// Releases every player. Whoever created this must call it: the app is
  /// handed a [GameSounds] rather than building one, so it does not own
  /// this and must not dispose it.
  Future<void> dispose() async {
    _isWalking = false;
    await Future.wait([
      _walking.dispose(),
      _levelCleared.dispose(),
      _levelReached.dispose(),
      _departure.dispose(),
    ]);
  }
}
