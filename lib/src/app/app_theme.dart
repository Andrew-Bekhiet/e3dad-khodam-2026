import 'package:flutter/material.dart';

/// Builds the app's light/dark `ThemeData` from the design spec's M3 seed
/// (§3), pinning the handful of roles the spec calls "load-bearing" (app
/// bar background/foreground) and leaving everything else to
/// `ColorScheme.fromSeed`. The typography is then scaled and bolded for
/// projection on a church-hall screen (see `_forProjector`).
final class AppTheme {
  static const Color _seedColor = Color(0xFF1B6CA8);
  static const Color _lightPrimary = Color(0xFF0B61A4);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFF8F9FF);
  static const Color _lightOnSurface = Color(0xFF181C20);
  static const Color _darkPrimary = Color(0xFF9ECAFF);
  static const Color _darkOnPrimary = Color(0xFF00325A);
  static const Color _darkSurface = Color(0xFF101418);
  static const Color _darkOnSurface = Color(0xFFE1E2E8);
  static const String _fontFamily = 'Cairo';

  /// The app is read off a projector across a church hall; the Material
  /// default sizes are too small at that distance.
  static const double _projectorFontScale = 1.5;

  /// The light theme: app bar uses `primary`/`onPrimary` (spec §3 table).
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seedColor).copyWith(
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );

    return _forProjector(theme);
  }

  /// The dark theme: app bar uses `surface`/`onSurface` (spec §3 table) —
  /// the seed's `primary` role is reserved for interactive accents, not
  /// the app bar, when dark.
  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _darkPrimary,
          onPrimary: _darkOnPrimary,
          surface: _darkSurface,
          onSurface: _darkOnSurface,
        );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );

    return _forProjector(theme);
  }

  /// Rebuilds the theme's typography for projection: every size up by
  /// [_projectorFontScale], every weight two Material steps heavier and
  /// clamped at `w900`. `Cairo` is a variable font (see `pubspec.yaml`),
  /// so the intermediate weights this produces render correctly.
  ///
  /// The **geometry**, not `ThemeData.textTheme`. A text theme read here
  /// still has null sizes — `MaterialApp` only merges the geometry in
  /// when it localises the theme for the script — and `TextStyle.apply`
  /// asserts rather than scale a size it cannot see. The geometry is also
  /// where the sizes and weights actually live, so this is the one place
  /// that has to change.
  static ThemeData _forProjector(ThemeData theme) {
    final typography = theme.typography;

    return theme.copyWith(
      typography: typography.copyWith(
        englishLike: _projectorGeometry(typography.englishLike),
        dense: _projectorGeometry(typography.dense),
        tall: _projectorGeometry(typography.tall),
      ),
    );
  }

  static TextTheme _projectorGeometry(TextTheme base) {
    final scaled = base.apply(fontSizeFactor: _projectorFontScale);

    return scaled.copyWith(
      displayLarge: _bolder(scaled.displayLarge),
      displayMedium: _bolder(scaled.displayMedium),
      displaySmall: _bolder(scaled.displaySmall),
      headlineLarge: _bolder(scaled.headlineLarge),
      headlineMedium: _bolder(scaled.headlineMedium),
      headlineSmall: _bolder(scaled.headlineSmall),
      titleLarge: _bolder(scaled.titleLarge),
      titleMedium: _bolder(scaled.titleMedium),
      titleSmall: _bolder(scaled.titleSmall),
      bodyLarge: _bolder(scaled.bodyLarge),
      bodyMedium: _bolder(scaled.bodyMedium),
      bodySmall: _bolder(scaled.bodySmall),
      labelLarge: _bolder(scaled.labelLarge),
      labelMedium: _bolder(scaled.labelMedium),
      labelSmall: _bolder(scaled.labelSmall),
    );
  }

  static TextStyle? _bolder(TextStyle? style) {
    if (style == null) return null;
    final weight = style.fontWeight ?? FontWeight.w400;
    final index = FontWeight.values.indexOf(weight);
    final bolderIndex = (index + 2).clamp(0, FontWeight.values.length - 1);

    return style.copyWith(fontWeight: FontWeight.values[bolderIndex]);
  }
}
