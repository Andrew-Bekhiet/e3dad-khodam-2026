import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:equatable/equatable.dart';

/// The whole guided playthrough: an opening set of beats, the ordered
/// levels, and a closing set of beats.
final class LevelScript extends Equatable {
  /// The character whose portrait and name front the guide overlay.
  final GameCharacter guide;

  /// The character credited for the narrator overlay.
  final GameCharacter narrator;

  /// Whose words the levels' verses are; shown on the city card that
  /// quotes them.
  final GameCharacter letterWriter;

  /// Everyone who walks the route, in the order they are drawn.
  ///
  /// One list for the whole script, not one per level: the party travels
  /// together from the first letter to the last, so there is a single
  /// route and this is who is on it.
  final List<GameCharacter> couriers;

  /// Beats played once, before the first level's briefing.
  final List<StoryBeat> prologue;

  /// The levels, in play order.
  final List<GameLevel> levels;

  /// Beats played once, after the last level is cleared.
  final List<StoryBeat> epilogue;

  @override
  List<Object?> get props => [
    guide,
    narrator,
    letterWriter,
    couriers,
    prologue,
    levels,
    epilogue,
  ];

  /// Creates a script.
  const LevelScript({
    required this.guide,
    required this.narrator,
    required this.letterWriter,
    required this.couriers,
    required this.prologue,
    required this.levels,
    required this.epilogue,
  });
}
