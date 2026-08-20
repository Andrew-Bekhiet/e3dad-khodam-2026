import 'package:e3dad_khodam_2026/src/data/game/post_office_characters.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_prison_levels.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_road_levels.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';

/// The post-office playthrough: ١٤ رسالة على ١٤ مرحلة, in the order the
/// play script (`المسرحية.docx`) delivers them.
final class PostOfficeScript {
  static const GameLevel finaleInRome = GameLevel(
    id: 'finale',
    title: 'الفينال',
    year: 67,
    destination: JourneyStops.rome,
    briefing: [
      StoryBeat.guide(
        'خلاص كده اللعبة خلصت، وعلشان تعرفوا ترجعوا لازم تكملوا آخر تاسك بعد الرسائل: إنكم تشرحوا ملخص سريع لكل الرسائل',
      ),
    ],
  );

  /// The fourteen levels, road letters then prison letters.
  static const List<GameLevel> levels = [
    ...PostOfficeRoadLevels.all,
    ...PostOfficePrisonLevels.all,
    finaleInRome,
  ];

  /// The finished script.
  ///
  /// The opening beats are the game's own opening lines in the play, and
  /// the closing beat is the verse the narrator reads over the last
  /// scene.
  static const LevelScript script = LevelScript(
    guide: PostOfficeCharacters.guide,
    narrator: PostOfficeCharacters.narrator,
    letterWriter: PostOfficeCharacters.paul,
    couriers: PostOfficeCharacters.couriers,
    home: JourneyStops.ismailia,
    prologue: [
      // The two lines that set the whole game up, so they take the screen
      // rather than arriving as an aside from the app bar.
      StoryBeat.guide(
        'هلا بيكم في لعبة post office. لو إنتوا سامعيني دلوقتي فأكيد إنتوا مش عارفين إنتوا فين وجيتوا هنا إزاي. الصندوق اللي كان فيه الرسايل واللي إنتوا فتحتوه مكانش صندوق عادي، ده كان اللعبة بتاعتنا، وإنتوا دلوقتي جوه اللعبة في زمن ٥٢ م، ودة عصر أول رسالة لبولس الرسول',
      ),
      StoryBeat.guide(
        'علشان ترجعوا بلدكم لازم تكسبوا اللعبة، وعلشان تكسبوا لازم تعدوا الـ١٤ مرحلة وتجمعوا الـ١٤ رسالة وترجعوها للصندوق. ومتقلقوش، معاكوا ٣ وسايل مساعدة علشان المراحل الصعبة',
      ),
    ],
    levels: levels,
    epilogue: [
      StoryBeat.narrator(
        '«أَنْتُمْ رِسَالَتُنَا مَكْتُوبَةً فِي قُلُوبِنَا... وَمَقْرُوءَةً مِنْ جَمِيعِ النَّاسِ»\n(2 كو 3: 2)',
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
