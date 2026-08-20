import 'package:e3dad_khodam_2026/src/data/game/letter_years.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';

/// Levels ١–٧ of the post-office game: the letters the play
/// (`المسرحية.docx`) walks through first — تسالونيكي ×٢، كورنثوس ×٢،
/// غلاطية، رومية، فيلبي.
///
/// Every line and every verse below is copied from that document. Where
/// it stages a scene rather than the game's own voice, the level carries
/// only its verses — nothing is written to fill the gap.
final class PostOfficeRoadLevels {
  /// The clearance line the script gives after a section is understood.
  static const StoryBeat _cleared = StoryBeat.guide(
    'برافو عليكم 🙌 🔥 أنتم كدة اجتزتم المرحلة دي، ودلوقتي هديكم الشاهد',
  );

  /// المرحلة ١ — الرسالة الأولى لتسالونيكي.
  static const GameLevel thessalonians1 = GameLevel(
    id: 'thessalonians-1',
    title: 'الرسالة الأولى لتسالونيكي',
    year: LetterYears.thessalonians1,
    destination: JourneyStops.thessalonica,
    briefing: [
      StoryBeat.guide(
        'احنا دلوقتي في تسالونيكي مدينة كبيرة على ساحل بحر مكدونية وبها مركز تجاري كبير، وعايش فيها كثير يهود كتير اوي. أول مرحلتين هيكونوا معانا هنا في نفس المدينة. مهمتكم في المدينة دي انكم تفهموا محتوى الرسالتين عشان تعرفوا تعدوا للمرحلة الجاية',
      ),
    ],
    verses: [
      'وكان يحاجهم ثلاثة سبوت من الكتب، موضحاً ومبيناً أنه كان ينبغي أن المسيح يتألم ويقوم من الأموات، وأن: هذا هو المسيح يسوع الذي أنا أنادي لكم به.\n(أع 17: 3)',
      '"وَتَنْتَظِرُوا ابْنَهُ مِنَ السَّمَاءِ، الَّذِي أَقَامَهُ مِنَ الأَمْوَاتِ، يَسُوعَ، الَّذِي يُنْقِذُنَا مِنَ الْغَضَبِ الآتِي."\n(1 تس 1: 10)',
      '"لأَنْ مَنْ هُوَ رَجَاؤُنَا وَفَرَحُنَا وَإِكْلِيلُ افْتِخَارِنَا؟ أَمْ لَسْتُمْ أَنْتُمْ أَيْضًا أَمَامَ رَبِّنَا يَسُوعَ الْمَسِيحِ فِي مَجِيئِهِ؟"\n(1 تس 2: 19)',
      '"لِكَيْ يُثَبِّتَ قُلُوبَكُمْ بِلاَ لَوْمٍ فِي الْقَدَاسَةِ، أَمَامَ اللهِ أَبِينَا فِي مَجِيءِ رَبِّنَا يَسُوعَ الْمَسِيحِ مَعَ جَمِيعِ قِدِّيسِيهِ."\n(1 تس 3: 13)',
    ],
  );

  /// المرحلة ٢ — الرسالة التانية لتسالونيكي.
  static const GameLevel thessalonians2 = GameLevel(
    id: 'thessalonians-2',
    title: 'الرسالة التانية لتسالونيكي',
    year: LetterYears.thessalonians2,
    destination: JourneyStops.thessalonica,
    briefing: [
      StoryBeat.narrator(
        'معلمنا بولس الرسول لما كتب الرسالة الأولى لتسالونيكي ذكر أن مجئ الرب في أي لحظة، فبدأت الناس تسيب أشغالها وقعدوا مستنين المجئ الثاني وكان مبررهم أنهم عايزين يتفرغوا للحياة الروحية\n'
        'وكان لازم معلمنا بولس يبعتلهم رسالة تانيه كلها حزم',
      ),
    ],
    verses: [
      '"«أَنَّهُ إِنْ كَانَ أَحَدٌ لَا يُرِيدُ أَنْ يَشْتَغِلَ فَلَا يَأْكُلْ أَيْضًا»."\n(2 تس 3: 10)',
      '"أَنْ لَا تَتَزَعْزَعُوا سَرِيعًا عَنْ ذِهْنِكُمْ، وَلَا تَرْتَاعُوا، لَا بِرُوحٍ وَلَا بِكَلِمَةٍ وَلَا بِرِسَالَةٍ كَأَنَّهَا مِنَّا: أَيْ أَنَّ يَوْمَ الْمَسِيحِ قَدْ حَضَرَ."\n(2 تس 2: 2)',
    ],
    clearance: [_cleared],
  );

  /// المرحلة ٣ — رسالة كورنثوس.
  static const GameLevel corinthians1 = GameLevel(
    id: 'corinthians-1',
    title: 'رسالة كورنثوس',
    year: LetterYears.corinthians1,
    destination: JourneyStops.corinth,
    briefing: [
      StoryBeat.guide(
        'احنا هنا في كورنثوس ودي كانت تعتبر ميناء رئيسية في العالم القديم، وكانت مليانة بالمعابد اليونانية والآلهة الرومانية، وكانت مركز اقتصادي كبير. قضى فيها بولس سنة ونص بيتعرف على الناس وبيكلمهم عن يسوع',
      ),
    ],
    verses: [
      '"فَمَنْ هُوَ بُولُسُ؟ وَمَنْ هُوَ أَبُلُّوسُ؟ بَلْ خَادِمَانِ آمَنْتُمْ بِوَاسِطَتِهِمَا، وَكَمَا أَعْطَى الرَّبُّ لِكُلِّ وَاحِدٍ" "أَنَا غَرَسْتُ وَأَبُلُّوسُ سَقَى، لكِنَّ الله كَانَ يُنْمِي."',
    ],
  );

  /// المرحلة ٤ — رسالة كورنثوس الثانية. The script names it without
  /// staging it, so the level is its city card alone.
  static const GameLevel corinthians2 = GameLevel(
    id: 'corinthians-2',
    title: 'رسالة كورنثوس الثانية',
    year: LetterYears.corinthians2,
    destination: JourneyStops.corinth,
  );

  /// المرحلة ٥ — رسالة غلاطية.
  static const GameLevel galatians = GameLevel(
    id: 'galatians',
    title: 'رسالة غلاطية',
    year: LetterYears.galatians,
    destination: JourneyStops.galatia,
    verses: [
      'بُولُسُ، رَسُولٌ لَا مِنَ النَّاسِ وَلَا بِإِنْسَانٍ، بَلْ بِيَسُوعَ الْمَسِيحِ وَاللهِ الآبِ الَّذِي أَقَامَهُ مِنَ الأَمْوَاتِ.',
      'وَلكِنْ إِنْ بَشَّرْنَاكُمْ نَحْنُ أَوْ مَلاَكٌ مِنَ السَّمَاءِ بِغَيْرِ مَا بَشَّرْنَاكُمْ، فَلْيَكُنْ محروما!',
    ],
    clearance: [_cleared],
  );

  /// المرحلة ٦ — الرسالة الى رومية.
  static const GameLevel romans = GameLevel(
    id: 'romans',
    title: 'الرسالة الى رومية',
    year: LetterYears.romans,
    destination: JourneyStops.rome,
    verses: [
      '"إذ معرفة الله ظاهرة فيهم... لأن أموره غير المنظورة تُرى منذ خلق العالم."\n(رومية 1: 19-20)',
      '"عبدوا المخلوق دون الخالق."\n(رومية 1: 25)',
      '',
    ],
  );

  /// المرحلة ٧ — رسالة فيلبي.
  static const GameLevel philippians = GameLevel(
    id: 'philippians',
    title: 'رسالة فيلبي',
    year: LetterYears.philippians,
    destination: JourneyStops.philippi,
    verses: [
      '"لأن لي الحياة هي المسيح والموت هو ربح"',
      '"افرحوا في الرب كل حين"',
      '7 لكِنْ مَا كَانَ لِي رِبْحًا، فَهذَا قَدْ حَسِبْتُهُ مِنْ أَجْلِ الْمَسِيحِ خَسَارَةً. 8 بَلْ إِنِّي أَحْسِبُ كُلَّ شَيْءٍ أَيْضًا خَسَارَةً مِنْ أَجْلِ فَضْلِ مَعْرِفَةِ الْمَسِيحِ يَسُوعَ رَبِّي، الَّذِي مِنْ أَجْلِهِ خَسِرْتُ كُلَّ الأَشْيَاءِ، وَأَنَا أَحْسِبُهَا نُفَايَةً لِكَيْ أَرْبَحَ الْمَسِيحَ.\n(الرسالة إلى فيلبى 3: 7-8)',
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
