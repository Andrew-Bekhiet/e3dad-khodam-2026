import 'package:equatable/equatable.dart';

/// Someone who takes part in the game: a traveller who moves across the
/// map, the guide who explains it, or the narrator who frames it.
///
/// The same portrait serves both the round map token and the dialogue
/// overlay, so a new character is one entry plus one image file.
final class GameCharacter extends Equatable {
  /// Stable identifier, also used as the map token's id and as part of
  /// its sprite id.
  final String id;

  /// The character's Arabic name, shown above their dialogue.
  final String name;

  /// Asset path of the portrait. May point at a file that does not exist
  /// yet: the map token falls back to a plain disc and the dialogue
  /// overlay to a framed placeholder, so a character can be scripted
  /// before their artwork arrives.
  final String portraitAsset;

  @override
  List<Object?> get props => [id, name, portraitAsset];

  /// Creates a character.
  const GameCharacter({
    required this.id,
    required this.name,
    required this.portraitAsset,
  });
}
