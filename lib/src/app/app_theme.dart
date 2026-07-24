import 'package:flutter/material.dart';

/// Builds the app's light/dark `ThemeData` from the design spec's M3 seed
/// (§3), pinning the handful of roles the spec calls "load-bearing" (app
/// bar background/foreground) and leaving everything else to
/// `ColorScheme.fromSeed`.
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

  /// The light theme: app bar uses `primary`/`onPrimary` (spec §3 table).
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seedColor).copyWith(
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
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
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }
}
