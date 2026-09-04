import 'package:e3dad_khodam_2026/src/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The app runs Arabic-only, which resolves to the `tall` geometry — the
/// one the projector scaling has to reach.
const Locale _arabic = Locale('ar');

const Key _probe = Key('probe');

Future<TextTheme> _resolvedTextTheme(
  WidgetTester tester,
  ThemeData theme,
) async {
  await tester.pumpWidget(
    MaterialApp(
      // A fresh key per pump. `MaterialApp.home` becomes a route the
      // Navigator builds once and caches, so without this a second theme
      // would be read back as the first one.
      key: UniqueKey(),
      locale: _arabic,
      supportedLocales: const [_arabic],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme,
      home: const SizedBox.shrink(key: _probe),
    ),
  );

  return TextTheme.of(tester.element(find.byKey(_probe)));
}

Future<TextTheme> _baseline(WidgetTester tester) =>
    _resolvedTextTheme(tester, ThemeData(useMaterial3: true));

double _size(TextStyle? style) {
  final size = style?.fontSize;
  if (size == null) {
    fail('a theme role reached the screen with no font size');
  }

  return size;
}

int _weight(TextStyle? style) {
  final weight = style?.fontWeight;
  if (weight == null) {
    fail('a theme role reached the screen with no font weight');
  }

  return weight.value;
}

/// One role per band of the scale; enough to catch a `copyWith` that
/// missed a row without restating all fifteen.
const List<TextStyle? Function(TextTheme)> _sampledRoles = [
  _displayLarge,
  _headlineMedium,
  _titleLarge,
  _bodyLarge,
  _labelSmall,
];

TextStyle? _displayLarge(TextTheme theme) => theme.displayLarge;
TextStyle? _headlineMedium(TextTheme theme) => theme.headlineMedium;
TextStyle? _titleLarge(TextTheme theme) => theme.titleLarge;
TextStyle? _bodyLarge(TextTheme theme) => theme.bodyLarge;
TextStyle? _labelSmall(TextTheme theme) => theme.labelSmall;

void main() {
  // The scaling used to be applied to `ThemeData.textTheme`, whose sizes
  // are still null before `MaterialApp` localises the geometry in, and
  // `TextStyle.apply` asserts rather than scale a size it cannot see.
  testWidgets('AppTheme_built_doesNotAssertOnUnsizedStyles', (tester) async {
    await _resolvedTextTheme(tester, AppTheme.light());
    await _resolvedTextTheme(tester, AppTheme.dark());
  });

  testWidgets('AppTheme_everyRole_isHalfAgainAsLarge', (tester) async {
    final base = await _baseline(tester);
    final light = await _resolvedTextTheme(tester, AppTheme.light());
    final dark = await _resolvedTextTheme(tester, AppTheme.dark());

    for (final role in _sampledRoles) {
      final expected = _size(role(base)) * 1.5;
      expect(_size(role(light)), closeTo(expected, 0.001));
      expect(_size(role(dark)), closeTo(expected, 0.001));
    }
  });

  testWidgets('AppTheme_everyRole_isBolderThanMaterialDefault', (
    tester,
  ) async {
    final base = await _baseline(tester);
    final light = await _resolvedTextTheme(tester, AppTheme.light());
    final dark = await _resolvedTextTheme(tester, AppTheme.dark());

    for (final role in _sampledRoles) {
      final expected = greaterThan(_weight(role(base)));
      expect(_weight(role(light)), expected);
      expect(_weight(role(dark)), expected);
    }
  });
}
