/// Renders whole numbers with Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩).
///
/// The UI is Arabic throughout and the script's own copy is written with
/// these digits, so the level counter must not be the one place showing
/// Western ones.
final class ArabicNumerals {
  static const List<String> _digits = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  /// [value] written with Arabic-Indic digits; negatives keep a leading
  /// `-`, which no caller passes today but which would otherwise be
  /// silently dropped.
  static String format(int value) {
    final sign = value < 0 ? '-' : '';
    final text = value.abs().toString();

    return sign +
        text.split('').map((digit) => _digits[int.parse(digit)]).join();
  }

  const ArabicNumerals._();
}
