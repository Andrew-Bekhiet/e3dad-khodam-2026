import 'package:e3dad_khodam_2026/src/domain/game/character_placement.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:equatable/equatable.dart';

/// One level of the guided game: a letter to deliver, the place it is
/// delivered to, and the story beats played before it ([briefing]) and
/// once it is cleared ([clearance]).
final class GameLevel extends Equatable {
  /// Stable identifier, used for lookups and as a widget key.
  final String id;

  /// The level's Arabic name — normally the letter being delivered.
  final String title;

  /// Short Arabic dateline for the level, e.g. `'تسالونيكي · ٥٢ م'`.
  final String dateline;

  /// One short Arabic line telling the player what this level is about.
  final String objective;

  /// Where every character on the map stands during this level, in draw
  /// order. Never empty: the first entry's stop is the level's
  /// [destination], which the camera frames and the letter is addressed
  /// to. Extra entries are how a second or third character travels their
  /// own route through the same levels.
  final List<CharacterPlacement> placements;

  /// Beats played before the level's map is handed to the player.
  final List<StoryBeat> briefing;

  /// Beats played once the player steps past the level's map.
  final List<StoryBeat> clearance;

  /// The place this level is about: where its leading character stands.
  JourneyStop get destination => placements.first.stop;

  @override
  List<Object?> get props => [
    id,
    title,
    dateline,
    objective,
    placements,
    briefing,
    clearance,
  ];

  /// Creates a level.
  ///
  /// [placements] must not be empty — [destination] reads its first
  /// entry. It cannot be asserted here: a list's length is not reachable
  /// from a `const` constructor, and every level is a compile-time
  /// constant.
  const GameLevel({
    required this.id,
    required this.title,
    required this.dateline,
    required this.objective,
    required this.placements,
    required this.briefing,
    required this.clearance,
  });
}
