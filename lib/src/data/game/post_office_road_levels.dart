import 'package:e3dad_khodam_2026/src/data/game/post_office_placements.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';

/// Levels ١–٧ of the post-office game: the letters written while بولس
/// was still on the road, in the order the play (`المسرحية.docx`) visits
/// them — تسالونيكي ثم كورنثوس ثم غلاطية ثم رومية ثم فيلبي.
///
/// Split from `PostOfficePrisonLevels` only to keep each file short; the
/// two are concatenated by `PostOfficeScript`.
final class PostOfficeRoadLevels {
  /// المرحلة ١ — تسالونيكي الأولى.
  static const GameLevel thessalonians1 = GameLevel(
    id: 'thessalonians-1',
    title: 'تسالونيكي الأولى',
    dateline: 'تسالونيكي · ٥٢ م',
    objective:
        'وصّل أول رسالة، وافهم إزاي بولس بيشجعهم على الثبات لحد مجيء الرب.',
    placements: PostOfficePlacements.thessalonica,
    briefing: [
      StoryBeat.narrator(
        'سنة ٥٢ ميلادية… باب قديم في مكتب البريد بيتفتح، وأول رسالة لبولس الرسول بتبدأ رحلتها.',
        title: 'بداية الرحلة',
      ),
      StoryBeat.guide(
        'أهلاً بيكم في لعبة post office! معاكم ١٤ رسالة متقسمين على ١٤ مرحلة، لازم تفهموهم كويس وتوصّلوهم عشان تعرفوا تخرجوا من اللعبة.',
      ),
      StoryBeat.guide(
        'احنا دلوقتي في تسالونيكي: مدينة كبيرة على ساحل مكدونية، فيها مركز تجاري كبير ويهود كتير أوي. أول مرحلتين هيكونوا معانا هنا.',
      ),
    ],
    clearance: [
      StoryBeat.guide(
        'برافو عليكم! اجتزتم المرحلة دي… وأهو الشاهد بتاعكم.',
        title: 'أحسنتم!',
      ),
    ],
  );

  /// المرحلة ٢ — تسالونيكي الثانية.
  static const GameLevel thessalonians2 = GameLevel(
    id: 'thessalonians-2',
    title: 'تسالونيكي الثانية',
    dateline: 'تسالونيكي · ٥٣ م',
    objective:
        'رسالة حزم لنفس المدينة: «إن كان أحد لا يريد أن يشتغل فلا يأكل أيضاً».',
    placements: PostOfficePlacements.thessalonica,
    briefing: [
      StoryBeat.narrator(
        'الناس فهمت إن مجيء الرب في أي لحظة، فسابت شغلها وقعدت تستنى… وكان لازم رسالة تانية.',
      ),
      StoryBeat.guide(
        'نفس المدينة، رسالة تانية. مهمتك توصّلها وتفهم ليه بولس اتكلم فيها بحزم عن الشغل والانتظار.',
      ),
    ],
    clearance: [
      StoryBeat.guide(
        'تمام! والرسالتين دول اتكتبوا من كورنثوس… ودي محطتنا الجاية.',
        title: 'المرحلة عدّت',
      ),
    ],
  );

  /// المرحلة ٣ — كورنثوس الأولى.
  static const GameLevel corinthians1 = GameLevel(
    id: 'corinthians-1',
    title: 'كورنثوس الأولى',
    dateline: 'كورنثوس · ٥٥ م',
    objective: 'كنيسة فيها انقسامات ومشاكل كتير — افهم إزاي بولس واجهها.',
    placements: PostOfficePlacements.corinth,
    briefing: [
      StoryBeat.narrator(
        'أول ما تتقال كلمة كورنثوس يتغيّر الديكور: ميناء رئيسية في العالم القديم، معابد يونانية وآلهة رومانية.',
      ),
      StoryBeat.guide(
        'قضى فيها بولس سنة ونص بيتعرّف على الناس ويكلمهم عن يسوع. وعشان تفهموا الرسالة أكتر، هبعتلكم حد يفهمكم.',
      ),
    ],
    clearance: [
      StoryBeat.guide('برافو! التحزّبات والانقسامات مركزها واحد: المسيح.'),
    ],
  );

  /// المرحلة ٤ — كورنثوس الثانية.
  static const GameLevel corinthians2 = GameLevel(
    id: 'corinthians-2',
    title: 'كورنثوس الثانية',
    dateline: 'كورنثوس · ٥٦ م',
    objective: 'رسالة قلب مفتوح: التعزية وسط الضيق، والخدمة اللي بتتحمّل.',
    placements: PostOfficePlacements.corinth,
    briefing: [
      StoryBeat.narrator('الجواب التاني في نفس الصندوق… وبنفس العنوان.'),
      StoryBeat.guide(
        'الرسالة دي مختلفة: بولس بيدافع فيها عن خدمته، ويحكي عن ضيقاته بصراحة. وصّلها وافهمها.',
      ),
    ],
    clearance: [
      StoryBeat.guide('عاش! يلا بينا شرق ناحية غلاطية.'),
    ],
  );

  /// المرحلة ٥ — غلاطية.
  static const GameLevel galatians = GameLevel(
    id: 'galatians',
    title: 'غلاطية',
    dateline: 'غلاطية · ٥٧ م',
    objective: 'ثلاث مواضيع: سلطان الرسول، الحرية من الناموس، والحياة بالروح.',
    placements: PostOfficePlacements.galatia,
    briefing: [
      StoryBeat.narrator('الجواب طلع من وسط شنطة تيتا… والخط مش سهل.'),
      StoryBeat.guide(
        'دي رسالة بولس لأهل غلاطية. أول موضوع فيها إنه بيدافع عن سلطته كرسول: «بولس رسول لا من الناس ولا بإنسان».',
      ),
      StoryBeat.guide(
        'والموضوع التاني إننا اتنقلنا من عبيد لأبناء: «لما جاء ملء الزمان أرسل الله ابنه».',
      ),
    ],
    clearance: [
      StoryBeat.guide(
        'برافو عليكم! أنتم كده اجتزتم المرحلة دي.',
        title: 'أحسنتم!',
      ),
    ],
  );

  /// المرحلة ٦ — رومية.
  static const GameLevel romans = GameLevel(
    id: 'romans',
    title: 'رومية',
    dateline: 'رومية · ٥٨ م',
    objective: 'قضية في المحكمة: اليهود والأمم، والاتنين محتاجين المسيح.',
    placements: PostOfficePlacements.rome,
    briefing: [
      StoryBeat.narrator(
        'تخيّل معايا قاعة محكمة: على اليمين اليهود، وعلى الشمال الأمم، وكل فريق شايف نفسه أحسن من التاني.',
        title: 'رسالة رومية',
      ),
      StoryBeat.guide(
        'بولس بيدخل مش عشان يشجّع فريق ضد التاني، لكن عشان يوصّل الاتنين لنفس الحكم. وصّل الرسالة وافهم المرافعة.',
      ),
    ],
    clearance: [
      StoryBeat.guide('ممتاز! أصعب رسالة في الصندوق اتسلّمت.'),
    ],
  );

  /// المرحلة ٧ — فيلبي.
  static const GameLevel philippians = GameLevel(
    id: 'philippians',
    title: 'فيلبي',
    dateline: 'فيلبي · ٦١ م',
    objective: 'رسالة فرح… مكتوبة من جوه السجن.',
    placements: PostOfficePlacements.philippi,
    briefing: [
      StoryBeat.narrator(
        'الإضاءة بتخفت… واحنا بقينا جوّه السجن مع اللي بيكتب.',
      ),
      StoryBeat.guide(
        'بولس مقيّد، وبيكتب رسالة فرح لأهل فيلبي. مهمتك توصّلها وتفهم إزاي الفرح مش مرتبط بالظروف.',
      ),
    ],
    clearance: [
      StoryBeat.guide('برافو! الفرح وصل لفيلبي.', title: 'المرحلة عدّت'),
    ],
  );

  /// Levels ١–٧ in play order.
  static const List<GameLevel> all = [
    thessalonians1,
    thessalonians2,
    corinthians1,
    corinthians2,
    galatians,
    romans,
    philippians,
  ];

  const PostOfficeRoadLevels._();
}
