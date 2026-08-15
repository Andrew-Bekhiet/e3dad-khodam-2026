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

  /// The place this level is about: where its letter is delivered, where
  /// the camera settles, and the next point on the party's route.
  ///
  /// Who is standing there is not a property of the level. The whole
  /// cast travels together for the whole journey, so the roster lives
  /// once on `LevelScript.travellers`.
  final JourneyStop destination;

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

  @override
  List<Object?> get props => [
    id,
    title,
    destination,
    briefing,
    clearance,
    verses,
    imageAsset,
    year,
  ];

  /// Creates a level.
  const GameLevel({
    required this.id,
    required this.title,
    required this.destination,
    required this.imageAsset,
    this.briefing = const [],
    this.clearance = const [],
    this.verses = const [],
    this.year,
  });
}
