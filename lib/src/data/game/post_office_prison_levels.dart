import 'package:e3dad_khodam_2026/src/data/game/letter_years.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';

/// Levels ٨–١٤ of the post-office game, in the order the play
/// (`المسرحية.docx`) lists them — فيلمون، كولوسي، افسس، تيطس،
/// تيمثاوس ١، عبرانيين، تيمثاوس ٢.
///
/// Most of these are headings in that document with the scene still to
/// be written, so most levels here are a city card and nothing else.
/// When the script grows, its lines and verses drop straight in.
final class PostOfficePrisonLevels {
  /// المرحلة ٨ — فيلمون.
  static const GameLevel philemon = GameLevel(
    id: 'philemon',
    title: 'فيلمون',
    year: LetterYears.philemon,
    destination: JourneyStops.colossae,
    verses: [
      '1 بُولُسُ، أَسِيرُ يَسُوعَ الْمَسِيحِ، وَتِيمُوثَاوُسُ الأَخُ، إِلَى فِلِيمُونَ الْمَحْبُوبِ وَالْعَامِلِ مَعَنَا',
      '16 لاَ كَعَبْدٍ فِي مَا بَعْدُ، بَلْ أَفْضَلَ مِنْ عَبْدٍ: أَخًا مَحْبُوبًا، وَلاَ سِيَّمَا إِلَيَّ، فَكَمْ بِالْحَرِيِّ إِلَيْكَ فِي الْجَسَدِ وَالرَّبِّ جَمِيعًا',
      '18 ثُمَّ إِنْ كَانَ قَدْ ظَلَمَكَ بِشَيْءٍ، أَوْ لَكَ عَلَيْهِ دَيْنٌ، فَاحْسِبْ ذلِكَ عَلَيَّ.\n(الرسالة إلى فليمون 1: 1، 16، 18)',
    ],
  );

  /// المرحلة ٩ — كولوسي.
  static const GameLevel colossians = GameLevel(
    id: 'colossians',
    title: 'كولوسي',
    year: LetterYears.colossians,
    destination: JourneyStops.colossae,
  );

  /// المرحلة ١٠ — افسس.
  static const GameLevel ephesians = GameLevel(
    id: 'ephesians',
    title: 'افسس',
    year: LetterYears.ephesians,
    destination: JourneyStops.ephesus,
  );

  /// المرحلة ١١ — تيطس.
  static const GameLevel titus = GameLevel(
    id: 'titus',
    title: 'تيطس',
    year: LetterYears.titus,
    destination: JourneyStops.crete,
  );

  /// المرحلة ١٢ — تيمثاوس ١.
  static const GameLevel timothy1 = GameLevel(
    id: 'timothy-1',
    title: 'تيمثاوس ١',
    year: LetterYears.timothy1,
    destination: JourneyStops.ephesus,
  );

  /// المرحلة ١٣ — عبرانيين.
  static const GameLevel hebrews = GameLevel(
    id: 'hebrews',
    title: 'عبرانيين',
    year: LetterYears.hebrews,
    destination: JourneyStops.jerusalem,
  );

  /// المرحلة ١٤ — تيمثاوس ٢.
  static const GameLevel timothy2 = GameLevel(
    id: 'timothy-2',
    title: 'تيمثاوس ٢',
    year: LetterYears.timothy2,
    destination: JourneyStops.ephesus,
    verses: [
      'فَلاَ تَخْجَلْ بِشَهَادَةِ رَبِّنَا، وَلاَ بِي أَنَا أَسِيرَهُ، بَلِ اشْتَرِكْ فِي احْتِمَالِ الْمَشَقَّاتِ لأَجْلِ الإِنْجِيلِ بِحَسَبِ قُوَّةِ اللهِ',
      'لأَنَّ اللهَ لَمْ يُعْطِنَا رُوحَ الْفَشَلِ، بَلْ رُوحَ الْقُوَّةِ وَالْمَحَبَّةِ وَالنُّصْحِ',
      'كُلُّ الْكِتَابِ هُوَ مُوحًى بِهِ مِنَ اللهِ، وَنَافِعٌ لِلتَّعْلِيمِ وَالتَّوْبِيخِ، لِلتَّقْوِيمِ وَالتَّأْدِيبِ الَّذِي فِي الْبِرِّ، لِكَيْ يَكُونَ إِنْسَانُ اللهِ كَامِلاً، مُتَأَهِّبًا لِكُلِّ عَمَل صَالِحٍ',
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
