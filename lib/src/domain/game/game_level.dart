import 'package:e3dad_khodam_2026/src/domain/game/character_placement.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:equatable/equatable.dart';

/// One level of the guided game: a letter to deliver, the place it is
/// delivered to, and the story beats played before it ([briefing]) and
/// once it is cleared ([clearance]).
///
/// Every string here comes from the play script (`المسرحية.docx`); a
/// level the script says nothing about simply has empty lists, and shows
/// its city card and verses alone.
final class GameLevel extends Equatable {
  /// Stable identifier, used for lookups and as a widget key.
  final String id;

  /// The letter's name, as the play script names it.
  final String title;

  /// Where every character on the map stands during this level, in draw
  /// order. Never empty: the first entry's stop is the level's
  /// [destination], which the camera frames and the letter is addressed
  /// to. Extra entries are how a second group travels its own route
  /// through the same levels.
  final List<CharacterPlacement> placements;

  /// Beats played before the level's map is handed to the player.
  final List<StoryBeat> briefing;

  /// Beats played once the player steps past the level's map.
  final List<StoryBeat> clearance;

  /// The verses the script quotes for this letter, in the order it
  /// quotes them. Revealed one at a time on the level's city card.
  final List<String> verses;

  /// Artwork for the level's destination card, shown over the map while
  /// the level is being played. May point at a file that does not exist
  /// yet: the card falls back to a placeholder carrying the name alone.
  final String imageAsset;

  /// The year the letter was written, in AD, shown beside the
  /// destination's name on the card's sign.
  ///
  /// Null where no year is claimed for it. Every letter carries one
  /// today, but the play script only dates تسالونيكي, so a level with
  /// nothing to say about when it happened must be able to say nothing.
  final int? year;

  /// The place this level is about: where its leading group stands.
  JourneyStop get destination => placements.first.stop;

  @override
  List<Object?> get props => [
    id,
    title,
    placements,
    briefing,
    clearance,
    verses,
    imageAsset,
    year,
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
    required this.placements,
    required this.imageAsset,
    this.briefing = const [],
    this.clearance = const [],
    this.verses = const [],
    this.year,
  });
}
