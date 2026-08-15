import 'package:e3dad_khodam_2026/src/data/game/post_office_characters.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_prison_levels.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_road_levels.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';

/// The post-office playthrough: ١٤ رسالة على ١٤ مرحلة, in the order the
/// play script (`المسرحية.docx`) delivers them.
final class PostOfficeScript {
  /// The fourteen levels, road letters then prison letters.
  static const List<GameLevel> levels = [
    ...PostOfficeRoadLevels.all,
    ...PostOfficePrisonLevels.all,
  ];

  /// The finished script.
  ///
  /// The opening beat is the game's own opening line in the play; the
  /// play has no closing narration yet, so the game simply ends on its
  /// last level rather than inventing one.
  static const LevelScript script = LevelScript(
    guide: PostOfficeCharacters.guide,
    narrator: PostOfficeCharacters.narrator,
    letterWriter: PostOfficeCharacters.paul,
    couriers: PostOfficeCharacters.couriers,
    prologue: [
      StoryBeat.guide(
        'أهلا بكم في لعبة post office. انتو دلوقتي في زمن ٥٢ م، ودة عصر اول رسالة لبولس الرسول. انتو دلوقتي معاكم ١٤ رسالة متقسمين ل١٤ مرحلة، لازم تفهموهم كويس اوي وتوصلوهم عشان تعرفوا تطلعوا من اللعبة',
      ),
    ],
    levels: levels,
    epilogue: [],
  );

  const PostOfficeScript._();
}

/// [LevelScriptRepository] backed by the compile-time [PostOfficeScript];
/// there is no I/O, so the load is synchronous and cheap.
final class StaticLevelScriptRepository implements LevelScriptRepository {
  /// Creates a repository over the built-in script.
  const StaticLevelScriptRepository();

  @override
  LevelScript loadLevelScript() => PostOfficeScript.script;
}
