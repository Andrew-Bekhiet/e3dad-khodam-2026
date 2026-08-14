import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';

/// The cast of the post-office game.
///
/// Portrait paths are stable even when the file is not there yet — the
/// map token and the dialogue overlay both degrade to a placeholder — so
/// artwork can be dropped into `assets/characters/` later without any
/// code change.
final class PostOfficeCharacters {
  /// The postman the player follows across the map; the one carrying the
  /// letters, and the only character with a token on the map today.
  static const GameCharacter courier = GameCharacter(
    id: 'courier',
    name: 'ساعي البريد',
    portraitAsset: 'assets/characters/beshoy.png',
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
