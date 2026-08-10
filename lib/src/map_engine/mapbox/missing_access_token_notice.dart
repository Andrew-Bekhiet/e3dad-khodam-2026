import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_style.dart';
import 'package:flutter/widgets.dart';

/// Painted in place of the map when the build defined no Mapbox access
/// token, so the cause of a blank screen is stated on the screen itself
/// instead of being swallowed as an endless stream of failed requests.
final class MissingAccessTokenNotice extends StatelessWidget {
  static const Color _background = Color(0xFFFFF4E5);
  static const Color _textColor = Color(0xFF8A4B00);
  static const double _fontSize = 12.0;
  static const EdgeInsets _padding = EdgeInsets.all(24.0);
  static const String _message =
      'Missing Mapbox access token. Run with '
      '--dart-define=${MapboxStyle.accessTokenEnvKey}=pk.<your token>';

  /// Creates the notice.
  const MissingAccessTokenNotice({super.key});

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: _background,
    child: Padding(
      padding: _padding,
      child: Center(
        child: Text(
          _message,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(color: _textColor, fontSize: _fontSize),
        ),
      ),
    ),
  );
}
