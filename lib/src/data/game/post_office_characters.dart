import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';

/// The cast of the post-office game.
///
/// Portrait paths are stable even when the file is not there yet — the
/// map token and the dialogue overlay both degrade to a placeholder — so
/// artwork can be dropped into `assets/characters/` later without any
/// code change.
final class PostOfficeCharacters {
  static const List<GameCharacter> couriers = [courier1, courier2];

  /// The postman the player follows across the map; the one carrying the
  /// letters, and the only character with a token on the map today.
  static const GameCharacter courier1 = GameCharacter(
    id: 'courier1',
    name: 'ساعي البريد ١',
    portraitAsset: 'assets/characters/postman1-avatar.jpg',
  );

  static const GameCharacter courier2 = GameCharacter(
    id: 'courier2',
    name: 'ساعي البريد ٢',
    portraitAsset: 'assets/characters/postman2-avatar.jpg',
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
    name: 'صوت اللعبة',
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
