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

  /// The finished script, with the beats that open and close the game.
  static const LevelScript script = LevelScript(
    guide: PostOfficeCharacters.guide,
    narrator: PostOfficeCharacters.narrator,
    prologue: [
      StoryBeat.narrator(
        'مكتب بريد قديم، وباب محدش بيفتحه… وجوّه صندوق فيه أربعتاشر جواب مستنيين من ألفين سنة.',
        title: 'post office',
      ),
      StoryBeat.guide(
        'انتو دلوقتي في زمن ٥٢ م، عصر أول رسالة لبولس الرسول. معاكم ١٤ رسالة متقسمين على ١٤ مرحلة… يلا نبتدي.',
      ),
    ],
    levels: levels,
    epilogue: [
      StoryBeat.guide(
        'أربعتاشر جواب اتسلّموا كلهم. أنتم كده خرجتم من اللعبة… بس الرسايل فضلت معاكم.',
        title: 'خلصت اللعبة',
      ),
      StoryBeat.narrator(
        'البوسطة طول عمرها بتبعت إخطارات… لكن الطرد ده اتسلّم لحد باب البيت.',
      ),
    ],
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
