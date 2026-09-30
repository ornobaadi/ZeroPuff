import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_accents.dart';
import 'package:zeropuff/core/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final entry in {'light': AppTheme.light, 'dark': AppTheme.dark}.entries) {
    final theme = entry.value;
    final scheme = theme.colorScheme;
    final accents = theme.extension<AppAccents>()!;

    group('${entry.key} theme', () {
      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('text colors meet 4.5:1 on their surfaces', () {
        final pairs = <String, (Color, Color)>{
          'onSurface/surface': (scheme.onSurface, scheme.surface),
          'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
          'onSurface/surfaceContainerLow': (
            scheme.onSurface,
            scheme.surfaceContainerLow,
          ),
          'onPrimary/primary': (scheme.onPrimary, scheme.primary),
          'onPrimaryContainer/primaryContainer': (
            scheme.onPrimaryContainer,
            scheme.primaryContainer,
          ),
          'onSecondaryContainer/secondaryContainer': (
            scheme.onSecondaryContainer,
            scheme.secondaryContainer,
          ),
          'onError/error': (scheme.onError, scheme.error),
          'onInverseSurface/inverseSurface': (
            scheme.onInverseSurface,
            scheme.inverseSurface,
          ),
          'onMoneyContainer/moneyContainer': (
            accents.onMoneyContainer,
            accents.moneyContainer,
          ),
          'onStreakContainer/streakContainer': (
            accents.onStreakContainer,
            accents.streakContainer,
          ),
          'onCravingContainer/cravingContainer': (
            accents.onCravingContainer,
            accents.cravingContainer,
          ),
          'onWarningContainer/warningContainer': (
            accents.onWarningContainer,
            accents.warningContainer,
          ),
        };

        for (final pair in pairs.entries) {
          final ratio = _contrast(pair.value.$1, pair.value.$2);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '${pair.key} contrast is ${ratio.toStringAsFixed(2)}',
          );
        }
      });

      test('accent icon colors meet 3:1 on the page surface', () {
        final accentColors = <String, Color>{
          'money': accents.money,
          'streak': accents.streak,
          'craving': accents.craving,
          'warning': accents.warning,
          'primary': scheme.primary,
        };

        for (final accent in accentColors.entries) {
          final ratio = _contrast(accent.value, scheme.surface);
          expect(
            ratio,
            greaterThanOrEqualTo(3),
            reason: '${accent.key} contrast is ${ratio.toStringAsFixed(2)}',
          );
        }
      });

      test('navigation bar always shows labels', () {
        expect(
          theme.navigationBarTheme.labelBehavior,
          NavigationDestinationLabelBehavior.alwaysShow,
        );
      });
    });
  }
}
