/// The year each letter was written, in AD.
///
/// Collected here rather than spread through the level files so the whole
/// set can be checked in one read. Only تسالونيكي's date comes from the
/// play script, which puts the audience `في زمن ٥٢ م`; the rest are the
/// commonly cited scholarly datings and are **pending review**.
///
/// The sequence is not monotonic, and that is not a mistake: غلاطية is
/// widely dated to ٤٩, earlier than either letter to تسالونيكي, even
/// though the game plays it fifth. The game's order follows the play, not
/// the calendar.
final class LetterYears {
  /// ٥٢ — from the play script itself.
  static const int thessalonians1 = 52;

  /// ٥٢ — written from كورنثوس soon after the first.
  static const int thessalonians2 = 52;

  /// ٥٥ — from أفسس.
  static const int corinthians1 = 55;

  /// ٥٦ — from مكدونية.
  static const int corinthians2 = 56;

  /// ٤٩ — on the early (South Galatian) dating, the first letter Paul
  /// wrote. Earlier than everything else the game shows.
  static const int galatians = 49;

  /// ٥٧ — from كورنثوس.
  static const int romans = 57;

  /// ٦٢ — from the Roman imprisonment, with the three below it.
  static const int philippians = 62;

  /// ٦٢ — carried with كولوسي by the same messenger.
  static const int philemon = 62;

  /// ٦٢.
  static const int colossians = 62;

  /// ٦٢.
  static const int ephesians = 62;

  /// ٦٤ — after the first Roman imprisonment.
  static const int titus = 64;

  /// ٦٤.
  static const int timothy1 = 64;

  /// ٦٧ — authorship and date are both debated; this is the traditional
  /// placing.
  static const int hebrews = 67;

  /// ٦٧ — the last letter, from the second imprisonment.
  static const int timothy2 = 67;

  const LetterYears._();
}
