import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';

/// The cast of the post-office game.
///
/// Portrait paths are stable even when the file is not there yet — the
/// map token and the dialogue overlay both degrade to a placeholder — so
/// artwork can be dropped into `assets/characters/` later without any
/// code change.
final class PostOfficeCharacters {
  /// Everyone who travels, in the order their portraits are laid out on
  /// the map. They go everywhere together, so this is the whole script's
  /// roster rather than anything a level decides.
  static const List<GameCharacter> couriers = [grandma, courier2, courier1];

  /// The postman the player follows across the map; the one carrying the
  /// letters.
  static const GameCharacter courier1 = GameCharacter(
    id: 'courier1',
    name: 'ساعي البريد ١',
    portraitAsset: 'assets/characters/postman1-avatar.png',
  );

  static const GameCharacter courier2 = GameCharacter(
    id: 'courier2',
    name: 'ساعي البريد ٢',
    portraitAsset: 'assets/characters/postman2-avatar.jpg',
  );

  static const GameCharacter grandma = GameCharacter(
    id: 'grandma',
    name: 'تيتا',
    portraitAsset: 'assets/characters/grandma-avatar.png',
  );

  /// The writer of every letter in the game. He has no token on the map
  /// — the couriers are the ones travelling — but the verses on a city
  /// card are his words, so the card is signed with his portrait.
  static const GameCharacter paul = GameCharacter(
    id: 'paul',
    name: 'بولس الرسول',
    portraitAsset: 'assets/characters/paul-avatar.jpg',
  );

  /// The in-world voice of the game that explains each level.
  static const GameCharacter guide = GameCharacter(
    id: 'guide',
    name: 'اللعبة',
    portraitAsset: 'assets/characters/guide.png',
  );

  /// The out-of-world voice that frames the journey between levels.
  static const GameCharacter narrator = GameCharacter(
    id: 'narrator',
    name: 'الراوي',
    portraitAsset: 'assets/characters/narrator.png',
  );

  const PostOfficeCharacters._();
}
