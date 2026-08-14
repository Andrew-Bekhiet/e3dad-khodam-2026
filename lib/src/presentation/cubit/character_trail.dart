import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:equatable/equatable.dart';

/// Where one character has been so far, and therefore where they are now.
///
/// One of these per character on the move, so the map draws a dashed
/// trail and a portrait token for each of them without the widgets
/// needing to know anything about levels.
final class CharacterTrail extends Equatable {
  /// Whose route this is.
  final GameCharacter character;

  /// Every stop they have stood at, oldest first, with consecutive
  /// repeats collapsed — two levels in the same city are one point on
  /// the map, not two. Never empty.
  final List<JourneyStop> path;

  /// Where they are standing right now.
  JourneyStop get position => path.last;

  @override
  List<Object?> get props => [character, path];

  /// Creates a trail. [path] must not be empty — [position] reads its
  /// last entry.
  const CharacterTrail({required this.character, required this.path});
}
