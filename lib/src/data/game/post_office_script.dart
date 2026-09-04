import 'package:e3dad_khodam_2026/src/data/game/post_office_characters.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_prison_levels.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_road_levels.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';

/// The post-office playthrough: ١٤ رسالة على ١٣ مرحلة, then the finale, in
/// the order the play script (`المسرحية.docx`) delivers them.
///
/// The letters outnumber the levels because تسالونيكي delivers two: the
/// play stages both of its letters as one scene, with one set of the
/// three questions at its end.
final class PostOfficeScript {
  static const GameLevel finaleInRome = GameLevel(
    id: 'finale',
    signLabel: 'الفينال',
    year: 67,
    destination: JourneyStops.rome,
    briefing: [
      StoryBeat.guide(
        'خلاص كده اللعبة خلصت، وعلشان تعرفوا ترجعوا لازم تكملوا آخر تاسك بعد الرسائل: إنكم تشرحوا ملخص سريع لكل الرسائل',
      ),
      StoryBeat.narrator(
        'يمكن الرحلة اللي مشيناها لحد هنا ما كانتش مجرد رحلة بين أماكن ورسائل… لكن كانت رحلة ربنا بيكلّمنا فيها إحنا كمان… كخدام',
      ),
      StoryBeat.narrator(
        'ومن خلال رسائل معلمنا بولس لتلميذه تيموثاوس، ربنا بيدينا طريق نمشي فيه… عشر كلمات، كل كلمة فيهم دعوة للخادم',
      ),
    ],
    verses: [
      'لاحِظ!\n"لاَحِظْ نَفْسَكَ وَالتَّعْلِيمَ وَدَاوِمْ عَلَى ذَلِكَ"\n(1 تي 4: 16)',
      'اتْبَع!\n"وَاتْبَعِ الْبِرَّ وَالإِيمَانَ وَالْمَحَبَّةَ وَالسَّلاَمَ"\n(2 تي 2: 22)',
      'جاهِد!\n"جَاهِدْ جِهَادَ الإِيمَانِ الْحَسَنَ"\n(1 تي 6: 12)',
      'أمسِك!\n"وَأَمْسِكْ بِالْحَيَاةِ الأَبَدِيَّةِ الَّتِي إِلَيْهَا دُعِيتَ أَيْضًا"\n(1 تي 6: 12)',
      'اجتهِد!\n"اجْتَهِدْ أَنْ تُقِيمَ نَفْسَكَ للهِ مُزَكًّى"\n(2 تي 2: 15)',
      'اكرِز!\n"اكْرِزْ بِالْكَلِمَةِ... فِي وَقْتٍ مُنَاسِبٍ وَغَيْرِ مُنَاسِبٍ"\n(2 تي 4: 2)',
      'كُن قدوة!\n"كُنْ قُدْوَةً لِلْمُؤْمِنِينَ فِي الْكَلاَمِ، فِي التَّصَرُّفِ، فِي الْمَحَبَّةِ، فِي الرُّوحِ، فِي الإِيمَانِ، فِي الطَّهَارَةِ"\n(1 تي 4: 12)',
      'تَقَوَّ!\n"فَتَقَوَّ أَنْتَ يَا ابْنِي بِالنِّعْمَةِ الَّتِي فِي الْمَسِيحِ يَسُوعَ"\n(2 تي 2: 1)',
      'احتمِل!\n"احْتَمِلِ الْمَشَقَّاتِ. اعْمَلْ عَمَلَ الْمُبَشِّرِ. تَمِّمْ خِدْمَتَكَ"\n(2 تي 4: 5)',
      'لا تُهمِل!\n"لَا تُهْمِلِ الْمَوْهِبَةَ الَّتِي فِيكَ"\n(1 تي 4: 14)',
    ],
  );

  /// The thirteen levels, road letters then prison letters, plus the finale.
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
      // Spoken over the time jump, before the تسالونيكي sign drops — which
      // is the flight the prologue steps are.
      StoryBeat.guide(
        'اهلا بيكم في رحلة بوست أوفيس لو أنتوا سامعني دلوقتي فا أكيد إنتوا مش عارفين إنتوا فين و جيتوا هنا ازاي'
        '\n'
        'الموضوع كله ان الصندوق اللي كان فيه الرسايل اللي إنتوا فتحتوه مكانش صندوق عادي ده كان الرحلة بتاعتنا'
        '\n'
        'و أنتوا دلوقتي جوه الرحلة في عصر اول و تاني رسالة لبولس الرسول اللي هما تسالونيكي الاولى و التانيه اللي كتبهم و هو في كورنثوس اثناء الرحله التبشيريه التانيه'
        '\n'
        'و علشان تعدوا المرحله دي لازم تجاوبوا على 3 اسئله مهمين جدا (الرساله اتكتبت من فين؟ اتكتبت لمين؟ و ليه؟)',
      ),
    ],
    levels: levels,
    epilogue: [
      StoryBeat.narrator(
        'عشر كلمات… وعشر وصايا للخادم. مش مجرد كلمات نسمعها… لكن طريق نعيشه',
      ),
      StoryBeat.narrator('دي مش نهاية الرحلة… دي بداية رسالتنا'),
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
