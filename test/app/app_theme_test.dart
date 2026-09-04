import 'package:e3dad_khodam_2026/src/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The app runs Arabic-only, which resolves to the `tall` geometry — the
/// one the projector scaling has to reach.
const Locale _arabic = Locale('ar');

Future<TextTheme> _resolvedTextTheme(
  WidgetTester tester,
  ThemeData theme,
) async {
  late TextTheme resolved;
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
      home: Builder(
        builder: (context) {
          resolved = TextTheme.of(context);

          return const SizedBox.shrink();
        },
      ),
    ),
  );

  return resolved;
}

Future<TextTheme> _baseline(WidgetTester tester) =>
    _resolvedTextTheme(tester, ThemeData(useMaterial3: true));

void main() {
  // The scaling used to be applied to `ThemeData.textTheme`, whose sizes
  // are still null before `MaterialApp` localises the geometry in, and
  // `TextStyle.apply` asserts rather than scale a size it cannot see.
  testWidgets('AppTheme_built_doesNotAssertOnUnsizedStyles', (tester) async {
    expect(AppTheme.light, returnsNormally);
    expect(AppTheme.dark, returnsNormally);

    await _resolvedTextTheme(tester, AppTheme.light());
    await _resolvedTextTheme(tester, AppTheme.dark());
  });

  testWidgets('AppTheme_everyRole_isHalfAgainAsLarge', (tester) async {
    final base = await _baseline(tester);
    final light = await _resolvedTextTheme(tester, AppTheme.light());
    final dark = await _resolvedTextTheme(tester, AppTheme.dark());

    for (final roles in [
      (base.displayLarge, light.displayLarge, dark.displayLarge),
      (base.headlineMedium, light.headlineMedium, dark.headlineMedium),
      (base.titleLarge, light.titleLarge, dark.titleLarge),
      (base.bodyLarge, light.bodyLarge, dark.bodyLarge),
      (base.labelSmall, light.labelSmall, dark.labelSmall),
    ]) {
      final (baseRole, lightRole, darkRole) = roles;
      expect(baseRole?.fontSize, isNotNull);
      expect(lightRole?.fontSize, closeTo(baseRole!.fontSize! * 1.5, 0.001));
      expect(darkRole?.fontSize, closeTo(baseRole.fontSize! * 1.5, 0.001));
    }
  });

  testWidgets('AppTheme_everyRole_isBolderThanMaterialDefault', (
    tester,
  ) async {
    final base = await _baseline(tester);
    final scaled = await _resolvedTextTheme(tester, AppTheme.light());

    for (final roles in [
      (base.displayLarge, scaled.displayLarge),
      (base.headlineMedium, scaled.headlineMedium),
      (base.titleLarge, scaled.titleLarge),
      (base.bodyLarge, scaled.bodyLarge),
      (base.labelSmall, scaled.labelSmall),
    ]) {
      final (baseRole, scaledRole) = roles;

      expect(
        scaledRole?.fontWeight?.value,
        greaterThan(baseRole!.fontWeight!.value),
      );
    }
  });
}
