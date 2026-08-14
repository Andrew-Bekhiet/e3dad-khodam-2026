import 'package:e3dad_khodam_2026/src/data/game/post_office_placements.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';

/// Levels ٨–١٤ of the post-office game: the letters from prison and the
/// letters to the shepherds, in the order the play (`المسرحية.docx`)
/// visits them — فليمون، كولوسي، أفسس، تيطس، تيموثاوس الأولى،
/// العبرانيين، تيموثاوس الثانية.
final class PostOfficePrisonLevels {
  /// المرحلة ٨ — فليمون.
  static const GameLevel philemon = GameLevel(
    id: 'philemon',
    title: 'فليمون',
    dateline: 'كولوسي · ٦١ م',
    objective: 'جواب شخصي عن عبد هارب رجع أخ محبوب.',
    placements: PostOfficePlacements.colossae,
    briefing: [
      StoryBeat.narrator('في السجن، بولس بيقابل أنسيموس… اللي سرق سيده فليمون وهرب.'),
      StoryBeat.guide(
        'الرسالة دي أقصر رسالة في الصندوق، وأصعب طلب فيها: «لا كعبد فيما بعد، بل أفضل من عبد: أخاً محبوباً».',
      ),
    ],
    clearance: [
      StoryBeat.guide('برافو! أصعب مصالحة في اللعبة اتسلّمت بإيدك.'),
    ],
  );

  /// المرحلة ٩ — كولوسي.
  static const GameLevel colossians = GameLevel(
    id: 'colossians',
    title: 'كولوسي',
    dateline: 'كولوسي · ٦٢ م',
    objective: 'المسيح هو الكل: صورة الله غير المنظور، ورأس الكنيسة.',
    placements: PostOfficePlacements.colossae,
    briefing: [
      StoryBeat.narrator('نفس المدينة، وجواب تاني في نفس الشوال.'),
      StoryBeat.guide(
        'تعاليم غريبة دخلت الكنيسة، فبولس بيرجّعهم لمركز واحد: المسيح. وصّل الرسالة وافهم مين هو.',
      ),
    ],
    clearance: [
      StoryBeat.guide('عاش! اتنين ورا بعض من نفس المدينة.'),
    ],
  );

  /// المرحلة ١٠ — أفسس.
  static const GameLevel ephesians = GameLevel(
    id: 'ephesians',
    title: 'أفسس',
    dateline: 'أفسس · ٦٢ م',
    objective: 'سرّ الكنيسة: واحد جديد من اليهود والأمم، وسلاح الله الكامل.',
    placements: PostOfficePlacements.ephesus,
    briefing: [
      StoryBeat.narrator('الصندوق اللي خبطنا فيه من الأول كان مكتوب عليه: أفسس.'),
      StoryBeat.guide(
        'المدينة دي قضى فيها بولس أطول وقت في خدمته. الرسالة بتتكلم عن الكنيسة كجسد واحد، وعن اللبس اللي بنحارب بيه.',
      ),
    ],
    clearance: [
      StoryBeat.guide('برافو عليكم!', title: 'أحسنتم!'),
    ],
  );

  /// المرحلة ١١ — تيطس.
  static const GameLevel titus = GameLevel(
    id: 'titus',
    title: 'تيطس',
    dateline: 'كريت · ٦٣ م',
    objective: 'ترتيب الكنيسة في جزيرة كريت، وتعليم يليق بالإيمان.',
    placements: PostOfficePlacements.crete,
    briefing: [
      StoryBeat.narrator('الرحلة بتقطع البحر ناحية الجنوب… لجزيرة كريت.'),
      StoryBeat.guide(
        'تيطس اتساب في كريت عشان يكمّل الناقص ويقيم شيوخاً في كل مدينة. الرسالة دي هي التعليمات بتاعته.',
      ),
    ],
    clearance: [
      StoryBeat.guide('تمام! جزيرة كاملة اتسلّمت جوابها.'),
    ],
  );

  /// المرحلة ١٢ — تيموثاوس الأولى.
  static const GameLevel timothy1 = GameLevel(
    id: 'timothy-1',
    title: 'تيموثاوس الأولى',
    dateline: 'أفسس · ٦٤ م',
    objective: 'وصايا لراعٍ شاب: التعليم، والصلاة، والقدوة.',
    placements: PostOfficePlacements.ephesus,
    briefing: [
      StoryBeat.narrator('رجوع تاني لأفسس، بس المرة دي الجواب باسم شخص واحد.'),
      StoryBeat.guide(
        'تيموثاوس ابن بولس في الإيمان، وبيخدم في أفسس. الرسالة دي بتعلّمه إزاي يتصرّف في بيت الله.',
      ),
    ],
    clearance: [
      StoryBeat.guide('برافو! باقي تلات جوابات بس.'),
    ],
  );

  /// المرحلة ١٣ — العبرانيين.
  static const GameLevel hebrews = GameLevel(
    id: 'hebrews',
    title: 'العبرانيين',
    dateline: 'أورشليم · ٦٥ م',
    objective: 'لناس على وشك الرجوع للهيكل: المسيح أفضل… وكفى.',
    placements: PostOfficePlacements.jerusalem,
    briefing: [
      StoryBeat.narrator(
        'شمعون راجل كبير من العبرانيين، على وشك يرجع للهيكل. جوعه: حاجة يشوفها ويلمسها… وأمان.',
      ),
      StoryBeat.guide(
        'الرسالة دي مش لمدينة، دي لناس تعبانة. مهمتك توصّلها وتفهم ليه الرجوع لورا مش هيفيد.',
      ),
    ],
    clearance: [
      StoryBeat.guide('عاش! أصعب رسالة على القلب اتسلّمت.'),
    ],
  );

  /// المرحلة ١٤ — تيموثاوس الثانية.
  static const GameLevel timothy2 = GameLevel(
    id: 'timothy-2',
    title: 'تيموثاوس الثانية',
    dateline: 'أفسس · ٦٧ م',
    objective: 'آخر جواب في الشوال: «جاهدت الجهاد الحسن».',
    placements: PostOfficePlacements.ephesus,
    briefing: [
      StoryBeat.narrator(
        'في يوم وصلت لتيموثاوس آخر رسالة، وكان عارف إنها مش زي أي رسالة قبلها: معلمه في السجن، وأيامه على الأرض قرّبت تخلص.',
        title: 'آخر رسالة',
      ),
      StoryBeat.guide(
        '«لأن الله لم يعطنا روح الفشل، بل روح القوة والمحبة والنصح». وصّلها… ودي آخر مرحلة.',
      ),
    ],
    clearance: [
      StoryBeat.guide('برافو عليكم! الشوال فضي.', title: 'المرحلة الأخيرة'),
    ],
  );

  /// Levels ٨–١٤ in play order.
  static const List<GameLevel> all = [
    philemon,
    colossians,
    ephesians,
    titus,
    timothy1,
    hebrews,
    timothy2,
  ];

  const PostOfficePrisonLevels._();
}
